-- =====================================================================
--  Contabilidad - FASE 7: nomina en dos pasos (pre-ejecutar + autorizar)
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-30_contabilidad_nomina.sql
--    sql/2026-08-30_contabilidad_isr.sql
--
--  Hasta ahora "Registrar nomina" calculaba Y contabilizaba en un solo
--  paso. Se separa en dos para que alguien pueda revisar el calculo
--  antes de que se contabilice:
--
--    1. precalcular_nomina(p_datos)  -> inserta la nomina y su detalle
--       por empleado con estatus 'borrador' (mismos calculos de
--       subtotal/IMSS/ISR que antes) pero SIN generar poliza contable.
--    2. autorizar_nomina(p_nomina_id) -> toma un borrador existente,
--       arma y postea la poliza (misma logica que antes tenia
--       registrar_nomina) y la pasa a estatus 'registrada'.
--
--  registrar_nomina (una sola llamada, calcula + contabiliza) se deja
--  intacta por compatibilidad, pero la app ya no la usa para el flujo
--  normal - todas las nominas nuevas pasan por el borrador.
--
--  cancelar_nomina se amplia para poder cancelar tambien un borrador
--  (nunca genero poliza, asi que no hay nada que revertir contablemente,
--  solo se marca 'cancelada').
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- estatus admite 'borrador' ademas de 'registrada'/'cancelada'
-- ---------------------------------------------------------------------
alter table public.nominas drop constraint if exists nominas_estatus_check;
alter table public.nominas
    add constraint nominas_estatus_check check (estatus in ('borrador', 'registrada', 'cancelada'));

-- ---------------------------------------------------------------------
-- precalcular_nomina(p_datos jsonb) -> { nomina_id, subtotal, total,
--                                         isr_retenido, isr_tarifa_fuente,
--                                         isr_tarifa_vigente_desde }
--   Mismo p_datos que registrar_nomina. Valida, calcula ISR con la
--   tarifa vigente, y guarda la nomina y su detalle por empleado como
--   'borrador' - no toca la contabilidad todavia.
-- ---------------------------------------------------------------------
create or replace function public.precalcular_nomina(p_datos jsonb)
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
    v_total          numeric(14,2);
    v_cuenta         public.cuentas_contables%rowtype;
    v_empleado       public.empleados%rowtype;
    v_nomina_id      bigint;
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

    if exists (
        select 1 from public.nominas
         where estatus <> 'cancelada'
           and periodo_inicio = v_periodo_inicio
           and periodo_fin = v_periodo_fin
    ) then
        raise exception 'Ya existe una nomina (borrador o registrada) para ese mismo periodo.';
    end if;

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

    -- ---- ISR (se calcula siempre, aunque venga un override manual, para
    -- guardar el detalle por empleado y declarar la tabla usada) ----
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

    v_total := round(v_subtotal + v_cuotas_imss, 2);

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco de la que sale el pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- insertar la nomina como borrador (sin poliza) ----
    insert into public.nominas
        (periodo_inicio, periodo_fin, fecha_pago, condicion, cuenta_pago_id, subtotal, cuotas_imss, isr_retenido, total, isr_tarifa_id, estatus)
    values (
        v_periodo_inicio, v_periodo_fin, v_fecha_pago, v_condicion,
        case when v_condicion = 'contado' then v_cta_pago else null end,
        v_subtotal, v_cuotas_imss, v_isr_retenido, v_total, v_isr_tarifa_id, 'borrador'
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

    return jsonb_build_object(
        'nomina_id', v_nomina_id,
        'subtotal', v_subtotal,
        'total', v_total,
        'isr_retenido', v_isr_retenido,
        'isr_tarifa_fuente', v_isr_calc->>'tarifa_fuente',
        'isr_tarifa_vigente_desde', v_isr_calc->>'tarifa_vigente_desde'
    );
end;
$$;

revoke all     on function public.precalcular_nomina(jsonb) from public;
grant  execute on function public.precalcular_nomina(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- autorizar_nomina(p_nomina_id) -> { nomina_id, poliza_id, total }
--   Toma un borrador ya guardado (con su detalle por empleado) y arma /
--   postea la poliza de Egreso, con la MISMA logica de cuentas que
--   antes tenia registrar_nomina. Solo procede si sigue en 'borrador'.
-- ---------------------------------------------------------------------
create or replace function public.autorizar_nomina(p_nomina_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_nomina    public.nominas%rowtype;
    v_cuenta    public.cuentas_contables%rowtype;
    v_movs      jsonb;
    v_id        bigint;
    v_neto      numeric(14,2);
    v_poliza_id bigint;
begin
    select * into v_nomina from public.nominas where id = p_nomina_id;
    if not found then raise exception 'La nomina no existe.'; end if;
    if v_nomina.estatus <> 'borrador' then
        raise exception 'La nomina ya esta %; solo se puede autorizar un borrador pendiente.', v_nomina.estatus;
    end if;

    if v_nomina.condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_nomina.cuenta_pago_id;
        if not found then raise exception 'La cuenta de pago de esta nomina ya no existe.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % ya no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    v_neto := round(v_nomina.subtotal - v_nomina.isr_retenido, 2);

    v_id := public._cuenta_id('601.01');
    if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.01 (Sueldos y salarios).'; end if;
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_id, 'cargo', v_nomina.subtotal, 'concepto', 'Nomina ' || v_nomina.periodo_inicio || ' a ' || v_nomina.periodo_fin)
    );

    if v_nomina.cuotas_imss > 0 then
        v_id := public._cuenta_id('601.59');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.59 (Cuotas IMSS/INFONAVIT patronales).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_nomina.cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT patronales');
    end if;

    if v_nomina.isr_retenido > 0 then
        v_id := public._cuenta_id('216.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.01 (ISR retenido por sueldos).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_nomina.isr_retenido, 'concepto', 'ISR retenido por sueldos');
    end if;

    if v_nomina.cuotas_imss > 0 then
        v_id := public._cuenta_id('219.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_nomina.cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT por pagar');
    end if;

    if v_neto > 0 then
        if v_nomina.condicion = 'contado' then
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_nomina.cuenta_pago_id, 'abono', v_neto, 'concepto', 'Pago de nomina neta');
        else
            v_id := public._cuenta_id('219.01');
            if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_neto, 'concepto', 'Sueldos netos por pagar');
        end if;
    end if;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_nomina.fecha_pago,
        'tipo', 'Egreso',
        'concepto', 'Nomina ' || v_nomina.periodo_inicio || ' a ' || v_nomina.periodo_fin,
        'origen', 'nomina',
        'origen_tabla', 'nominas',
        'origen_id', v_nomina.id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.nominas set poliza_id = v_poliza_id, estatus = 'registrada' where id = v_nomina.id;

    return jsonb_build_object('nomina_id', v_nomina.id, 'poliza_id', v_poliza_id, 'total', v_nomina.total);
end;
$$;

revoke all     on function public.autorizar_nomina(bigint) from public;
grant  execute on function public.autorizar_nomina(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- cancelar_nomina: ahora tambien puede cancelar un borrador (nunca
-- genero poliza, asi que no hay nada que revertir contablemente).
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
    if v_nomina.estatus not in ('registrada', 'borrador') then
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
