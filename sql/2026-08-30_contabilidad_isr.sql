-- =====================================================================
--  Contabilidad - FASE 6: Tabla ISR editable + calculo progresivo
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-28_contabilidad_cuentas.sql
--    sql/2026-08-28_contabilidad_polizas.sql
--    sql/2026-08-30_contabilidad_nomina.sql
--
--  El ISR retenido de sueldos es una tarifa PROGRESIVA por persona
--  (Art. 96 LISR, Anexo 8 de la RMF), no un % parejo. En vez de que la
--  app traiga una tabla fija (que cambia cada año y que este entorno no
--  puede verificar por internet), se agrega una pantalla "Tabla ISR"
--  donde el usuario sube los tramos vigentes; el sistema calcula el ISR
--  real de cada empleado con la tabla vigente a la fecha de pago.
--
--  Agrega:
--   - isr_tarifas / isr_tarifa_tramos   (tabla ISR, versionada por fecha)
--   - nominas.isr_tarifa_id, nomina_detalles.isr   (trazabilidad)
--   - _isr_tarifa_vigente(fecha), _isr_calcular_monto(tarifa, ingreso)
--   - RPC calcular_isr_nomina   (preview en vivo + lo usa registrar_nomina)
--   - registrar_nomina se reemplaza: si no se manda isr_retenido a mano,
--     lo calcula solo con calcular_isr_nomina.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- Tabla ISR (versionada: nunca se sobreescribe, se agregan versiones)
-- ---------------------------------------------------------------------
create table if not exists public.isr_tarifas (
    id             bigint generated always as identity primary key,
    vigente_desde  date not null,
    fuente         text,
    creado_por     uuid default auth.uid(),
    created_at     timestamptz not null default now()
);
create index if not exists idx_isr_tarifas_vigente on public.isr_tarifas(vigente_desde);

create table if not exists public.isr_tarifa_tramos (
    id               bigint generated always as identity primary key,
    tarifa_id        bigint not null references public.isr_tarifas(id) on delete cascade,
    orden            smallint not null,
    limite_inferior  numeric(14,2) not null check (limite_inferior >= 0),
    limite_superior  numeric(14,2),
    cuota_fija       numeric(14,2) not null default 0 check (cuota_fija >= 0),
    porcentaje       numeric(6,3) not null check (porcentaje >= 0),
    unique (tarifa_id, orden)
);
create index if not exists idx_isr_tramos_tarifa on public.isr_tarifa_tramos(tarifa_id);

alter table public.isr_tarifas enable row level security;
drop policy if exists admin_all on public.isr_tarifas;
create policy admin_all on public.isr_tarifas for all to authenticated using (true) with check (true);

alter table public.isr_tarifa_tramos enable row level security;
drop policy if exists admin_all on public.isr_tarifa_tramos;
create policy admin_all on public.isr_tarifa_tramos for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- Trazabilidad en nomina / nomina_detalles
-- ---------------------------------------------------------------------
alter table public.nominas
    add column if not exists isr_tarifa_id bigint references public.isr_tarifas(id) on delete set null;

alter table public.nomina_detalles
    add column if not exists isr numeric(14,2) not null default 0;

-- ---------------------------------------------------------------------
-- helpers ---------------------------------------------------------------
-- ---------------------------------------------------------------------

-- Id de la tarifa vigente en una fecha: la de vigente_desde mas reciente
-- que sea <= esa fecha (permite cargar la del proximo año con anticipo
-- sin afectar nominas de hoy).
create or replace function public._isr_tarifa_vigente(p_fecha date)
returns bigint
language sql
stable
set search_path = public
as $$
    select id from public.isr_tarifas
     where vigente_desde <= p_fecha
     order by vigente_desde desc, created_at desc
     limit 1;
$$;

-- ISR mensual segun tramo: cuota_fija + (excedente sobre limite_inferior) x %.
-- Devuelve 0 si no hay tarifa o no hay tramo que cubra el ingreso.
create or replace function public._isr_calcular_monto(p_tarifa_id bigint, p_ingreso_mensual numeric)
returns numeric
language sql
stable
set search_path = public
as $$
    select coalesce(
        (select round(coalesce(t.cuota_fija, 0) + greatest(0, p_ingreso_mensual - t.limite_inferior) * (t.porcentaje / 100.0), 2)
           from public.isr_tarifa_tramos t
          where t.tarifa_id = p_tarifa_id
            and t.limite_inferior <= p_ingreso_mensual
            and (t.limite_superior is null or p_ingreso_mensual <= t.limite_superior)
          order by t.orden
          limit 1),
        0
    );
$$;

-- ---------------------------------------------------------------------
-- calcular_isr_nomina(p_datos jsonb)
--   -> { tarifa_id, tarifa_fuente, tarifa_vigente_desde, total, detalle }
--   p_datos: { periodo_inicio, periodo_fin, fecha_pago,
--              empleados: [ { empleado_id, sueldo } ] }
--
--   Sube el sueldo del periodo a un "mensual equivalente"
--   (sueldo x 365/12/dias_del_periodo, la misma proporcion que usa el
--   SAT para derivar sus tarifas semanal/quincenal de la mensual), le
--   aplica la tarifa vigente a fecha_pago, y baja el resultado de vuelta
--   a la escala del periodo. Es de solo lectura: se puede llamar tanto
--   para una vista previa en vivo desde el formulario como internamente
--   desde registrar_nomina.
-- ---------------------------------------------------------------------
create or replace function public.calcular_isr_nomina(p_datos jsonb)
returns jsonb
language plpgsql
stable
set search_path = public, extensions
as $$
declare
    v_periodo_inicio date := (p_datos->>'periodo_inicio')::date;
    v_periodo_fin    date := (p_datos->>'periodo_fin')::date;
    v_fecha_pago     date := coalesce((p_datos->>'fecha_pago')::date, (p_datos->>'periodo_fin')::date, current_date);
    v_empleados      jsonb := coalesce(p_datos->'empleados', '[]'::jsonb);
    v_dias           numeric;
    v_factor         numeric;
    v_tarifa_id      bigint;
    v_tarifa         public.isr_tarifas%rowtype;
    v_total          numeric(14,2) := 0;
    v_detalle        jsonb := '[]'::jsonb;
    v_sueldo         numeric(14,2);
    v_mensual        numeric(14,2);
    v_isr_mensual    numeric(14,2);
    v_isr_periodo    numeric(14,2);
    e                jsonb;
begin
    v_dias := greatest(1, coalesce(v_periodo_fin, v_fecha_pago) - coalesce(v_periodo_inicio, v_fecha_pago) + 1);
    v_factor := (365.0 / 12) / v_dias;

    v_tarifa_id := public._isr_tarifa_vigente(v_fecha_pago);
    if v_tarifa_id is not null then
        select * into v_tarifa from public.isr_tarifas where id = v_tarifa_id;
    end if;

    for e in select * from jsonb_array_elements(v_empleados)
    loop
        v_sueldo := greatest(0, round(coalesce((e->>'sueldo')::numeric, 0), 2));
        v_mensual := round(v_sueldo * v_factor, 2);
        v_isr_mensual := public._isr_calcular_monto(v_tarifa_id, v_mensual);
        v_isr_periodo := case when v_factor > 0 then round(v_isr_mensual / v_factor, 2) else 0 end;
        v_total := v_total + v_isr_periodo;
        v_detalle := v_detalle || jsonb_build_object('empleado_id', (e->>'empleado_id')::bigint, 'isr', v_isr_periodo);
    end loop;

    return jsonb_build_object(
        'tarifa_id', v_tarifa_id,
        'tarifa_fuente', v_tarifa.fuente,
        'tarifa_vigente_desde', v_tarifa.vigente_desde,
        'total', round(v_total, 2),
        'detalle', v_detalle
    );
end;
$$;

revoke all     on function public.calcular_isr_nomina(jsonb) from public;
grant  execute on function public.calcular_isr_nomina(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- registrar_nomina(p_datos jsonb) -> { nomina_id, poliza_id, total,
--                                       isr_retenido, isr_tarifa_fuente,
--                                       isr_tarifa_vigente_desde }
--   p_datos: { periodo_inicio, periodo_fin, fecha_pago, condicion,
--              cuenta_pago_id, cuotas_imss, isr_retenido (opcional: si
--              se manda, se usa tal cual como override manual; si se
--              omite, se calcula solo con calcular_isr_nomina),
--              empleados: [ { empleado_id, sueldo } ] }
-- ---------------------------------------------------------------------
create or replace function public.registrar_nomina(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_periodo_inicio date          := (p_datos->>'periodo_inicio')::date;
    v_periodo_fin    date          := (p_datos->>'periodo_fin')::date;
    v_fecha_pago     date          := (p_datos->>'fecha_pago')::date;
    v_condicion      text          := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'contado');
    v_cta_pago       bigint        := (p_datos->>'cuenta_pago_id')::bigint;
    v_cuotas_imss    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'cuotas_imss')::numeric, 0), 2));
    v_isr_manual     boolean       := (p_datos ? 'isr_retenido') and (p_datos->>'isr_retenido') is not null;
    v_isr_retenido   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'isr_retenido')::numeric, 0), 2));
    v_empleados      jsonb         := coalesce(p_datos->'empleados', '[]'::jsonb);
    v_isr_calc       jsonb;
    v_isr_tarifa_id  bigint;
    v_subtotal       numeric(14,2) := 0;
    v_neto           numeric(14,2);
    v_total          numeric(14,2);
    v_cuenta         public.cuentas_contables%rowtype;
    v_empleado       public.empleados%rowtype;
    v_movs           jsonb;
    v_nomina_id      bigint;
    v_poliza_id      bigint;
    v_id             bigint;
    v_sueldo         numeric(14,2);
    v_isr_emp        numeric(14,2);
    e                jsonb;
begin
    if v_periodo_inicio is null or v_periodo_fin is null then
        raise exception 'El periodo de la nomina es obligatorio.';
    end if;
    if v_periodo_inicio > v_periodo_fin then
        raise exception 'El periodo de la nomina es invalido (el inicio es posterior al fin).';
    end if;
    if v_fecha_pago is null then raise exception 'La fecha de pago es obligatoria.'; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;
    if jsonb_array_length(v_empleados) = 0 then raise exception 'Selecciona al menos un empleado.'; end if;

    -- ---- validar empleados y acumular subtotal ----
    for e in select * from jsonb_array_elements(v_empleados)
    loop
        select * into v_empleado from public.empleados where id = (e->>'empleado_id')::bigint;
        if not found then raise exception 'Uno de los empleados seleccionados ya no existe.'; end if;
        if not v_empleado.activo then raise exception 'El empleado % esta inactivo.', v_empleado.nombre; end if;

        v_sueldo := greatest(0, round(coalesce((e->>'sueldo')::numeric, 0), 2));
        v_subtotal := v_subtotal + v_sueldo;
    end loop;

    if v_subtotal <= 0 then raise exception 'El subtotal de sueldos debe ser mayor a cero.'; end if;

    -- ---- ISR: se calcula siempre (para guardar el detalle por empleado
    -- y declarar la tabla usada), pero solo se usa como monto final si
    -- no vino un override manual ----
    v_isr_calc := public.calcular_isr_nomina(jsonb_build_object(
        'periodo_inicio', v_periodo_inicio,
        'periodo_fin', v_periodo_fin,
        'fecha_pago', v_fecha_pago,
        'empleados', v_empleados
    ));
    v_isr_tarifa_id := (v_isr_calc->>'tarifa_id')::bigint;
    if not v_isr_manual then
        v_isr_retenido := greatest(0, round(coalesce((v_isr_calc->>'total')::numeric, 0), 2));
    end if;

    if v_isr_retenido > v_subtotal then
        raise exception 'La retencion de ISR no puede ser mayor que el subtotal de sueldos.';
    end if;

    v_neto  := round(v_subtotal - v_isr_retenido, 2);
    v_total := round(v_subtotal + v_cuotas_imss, 2);

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco de la que sale el pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- armar movimientos de la poliza (Egreso) ----
    v_id := public._cuenta_id('601.01');
    if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.01 (Sueldos y salarios).'; end if;
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_id, 'cargo', v_subtotal, 'concepto', 'Nomina ' || v_periodo_inicio || ' a ' || v_periodo_fin)
    );

    if v_cuotas_imss > 0 then
        v_id := public._cuenta_id('601.59');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.59 (Cuotas IMSS/INFONAVIT patronales).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT patronales');
    end if;

    if v_isr_retenido > 0 then
        v_id := public._cuenta_id('216.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.01 (ISR retenido por sueldos).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_isr_retenido, 'concepto', 'ISR retenido por sueldos');
    end if;

    if v_cuotas_imss > 0 then
        v_id := public._cuenta_id('219.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT por pagar');
    end if;

    if v_neto > 0 then
        if v_condicion = 'contado' then
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_neto, 'concepto', 'Pago de nomina neta');
        else
            v_id := public._cuenta_id('219.01');
            if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_neto, 'concepto', 'Sueldos netos por pagar');
        end if;
    end if;

    -- ---- insertar la nomina (sin poliza todavia) ----
    insert into public.nominas
        (periodo_inicio, periodo_fin, fecha_pago, condicion, cuenta_pago_id, subtotal, cuotas_imss, isr_retenido, total, isr_tarifa_id)
    values (
        v_periodo_inicio, v_periodo_fin, v_fecha_pago, v_condicion,
        case when v_condicion = 'contado' then v_cta_pago else null end,
        v_subtotal, v_cuotas_imss, v_isr_retenido, v_total, v_isr_tarifa_id
    )
    returning id into v_nomina_id;

    for e in select * from jsonb_array_elements(v_empleados)
    loop
        select coalesce((d->>'isr')::numeric, 0) into v_isr_emp
          from jsonb_array_elements(v_isr_calc->'detalle') d
         where (d->>'empleado_id')::bigint = (e->>'empleado_id')::bigint
         limit 1;

        insert into public.nomina_detalles (nomina_id, empleado_id, sueldo, isr)
        values (v_nomina_id, (e->>'empleado_id')::bigint, greatest(0, round(coalesce((e->>'sueldo')::numeric, 0), 2)), coalesce(v_isr_emp, 0));
    end loop;

    -- ---- postear la poliza (reusa la validacion de cuadre) ----
    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha_pago,
        'tipo', 'Egreso',
        'concepto', 'Nomina ' || v_periodo_inicio || ' a ' || v_periodo_fin,
        'origen', 'nomina',
        'origen_tabla', 'nominas',
        'origen_id', v_nomina_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.nominas set poliza_id = v_poliza_id where id = v_nomina_id;

    return jsonb_build_object(
        'nomina_id', v_nomina_id,
        'poliza_id', v_poliza_id,
        'total', v_total,
        'isr_retenido', v_isr_retenido,
        'isr_tarifa_fuente', v_isr_calc->>'tarifa_fuente',
        'isr_tarifa_vigente_desde', v_isr_calc->>'tarifa_vigente_desde'
    );
end;
$$;

revoke all     on function public.registrar_nomina(jsonb) from public;
grant  execute on function public.registrar_nomina(jsonb) to authenticated;

commit;
