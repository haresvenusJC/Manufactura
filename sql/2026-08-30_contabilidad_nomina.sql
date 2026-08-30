-- =====================================================================
--  Contabilidad - FASE 5: Nomina
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-28_contabilidad_cuentas.sql
--    sql/2026-08-28_contabilidad_polizas.sql
--    sql/2026-08-28_contabilidad_gastos.sql          (por el helper _cuenta_id)
--
--  Agrega campos de identificacion a empleados (fecha_ingreso, rfc, curp,
--  nss, departamento) y crea nominas / nomina_detalles + los RPC
--  registrar_nomina y cancelar_nomina, que arman y postean la poliza de
--  nomina reusando registrar_poliza/cancelar_poliza (igual que gastos).
--
--  Poliza que genera una nomina:
--    Cargo  601.01 Sueldos y salarios              subtotal
--    Cargo  601.59 Cuotas IMSS/INFONAVIT patronales cuotas_imss   (si > 0)
--    Abono  216.01 ISR retenido por sueldos         isr_retenido  (si > 0)
--    Abono  219.01 IMSS/INFONAVIT y nomina por pagar cuotas_imss  (si > 0)
--    Abono  <caja/banco> (contado) o 219.01 (credito)   subtotal - isr_retenido
--  cuotas_imss es la cuota PATRONAL (carga de la empresa) - no se descuenta
--  al empleado.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- Campos de identificacion en empleados (nulables, sin backfill)
-- ---------------------------------------------------------------------
alter table public.empleados
    add column if not exists fecha_ingreso date,
    add column if not exists rfc           text,
    add column if not exists curp          text,
    add column if not exists nss           text,
    add column if not exists departamento  text;

-- ---------------------------------------------------------------------
-- nominas / nomina_detalles
-- ---------------------------------------------------------------------
create table if not exists public.nominas (
    id             bigint generated always as identity primary key,
    periodo_inicio date    not null,
    periodo_fin    date    not null,
    fecha_pago     date    not null,
    condicion      text    not null default 'contado' check (condicion in ('contado','credito')),
    cuenta_pago_id bigint  references public.cuentas_contables(id) on delete restrict,
    subtotal       numeric(14,2) not null default 0 check (subtotal >= 0),
    cuotas_imss    numeric(14,2) not null default 0 check (cuotas_imss >= 0),
    isr_retenido   numeric(14,2) not null default 0 check (isr_retenido >= 0),
    total          numeric(14,2) not null default 0 check (total >= 0),
    poliza_id      bigint  references public.polizas(id) on delete set null,
    estatus        text    not null default 'registrada' check (estatus in ('registrada','cancelada')),
    creado_por     uuid    default auth.uid(),
    created_at     timestamptz not null default now()
);
create index if not exists idx_nominas_fecha_pago on public.nominas(fecha_pago);
create index if not exists idx_nominas_periodo    on public.nominas(periodo_inicio, periodo_fin);

create table if not exists public.nomina_detalles (
    id          bigint generated always as identity primary key,
    nomina_id   bigint not null references public.nominas(id) on delete cascade,
    empleado_id bigint not null references public.empleados(id) on delete restrict,
    sueldo      numeric(14,2) not null check (sueldo >= 0)
);
create index if not exists idx_nomdet_nomina   on public.nomina_detalles(nomina_id);
create index if not exists idx_nomdet_empleado on public.nomina_detalles(empleado_id);

alter table public.nominas enable row level security;
drop policy if exists admin_all on public.nominas;
create policy admin_all on public.nominas for all to authenticated using (true) with check (true);

alter table public.nomina_detalles enable row level security;
drop policy if exists admin_all on public.nomina_detalles;
create policy admin_all on public.nomina_detalles for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- registrar_nomina(p_datos jsonb) -> { nomina_id, poliza_id, total }
--   p_datos: { periodo_inicio, periodo_fin, fecha_pago, condicion,
--              cuenta_pago_id, cuotas_imss, isr_retenido,
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
    v_isr_retenido   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'isr_retenido')::numeric, 0), 2));
    v_empleados      jsonb         := coalesce(p_datos->'empleados', '[]'::jsonb);
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
        (periodo_inicio, periodo_fin, fecha_pago, condicion, cuenta_pago_id, subtotal, cuotas_imss, isr_retenido, total)
    values (
        v_periodo_inicio, v_periodo_fin, v_fecha_pago, v_condicion,
        case when v_condicion = 'contado' then v_cta_pago else null end,
        v_subtotal, v_cuotas_imss, v_isr_retenido, v_total
    )
    returning id into v_nomina_id;

    for e in select * from jsonb_array_elements(v_empleados)
    loop
        insert into public.nomina_detalles (nomina_id, empleado_id, sueldo)
        values (v_nomina_id, (e->>'empleado_id')::bigint, greatest(0, round(coalesce((e->>'sueldo')::numeric, 0), 2)));
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

    return jsonb_build_object('nomina_id', v_nomina_id, 'poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

revoke all     on function public.registrar_nomina(jsonb) from public;
grant  execute on function public.registrar_nomina(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- cancelar_nomina(p_nomina_id) -> { poliza_reversa_id }
-- ---------------------------------------------------------------------
create or replace function public.cancelar_nomina(p_nomina_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_nomina public.nominas%rowtype;
    v_res    jsonb := '{}'::jsonb;
begin
    select * into v_nomina from public.nominas where id = p_nomina_id;
    if not found then raise exception 'La nomina no existe.'; end if;
    if v_nomina.estatus <> 'registrada' then
        raise exception 'La nomina ya esta %.', v_nomina.estatus;
    end if;

    if v_nomina.poliza_id is not null then
        v_res := public.cancelar_poliza(v_nomina.poliza_id, 'Cancelacion de nomina #' || v_nomina.id);
    end if;

    update public.nominas set estatus = 'cancelada' where id = p_nomina_id;
    return v_res;
end;
$$;

revoke all     on function public.cancelar_nomina(bigint) from public;
grant  execute on function public.cancelar_nomina(bigint) to authenticated;

commit;
