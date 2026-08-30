-- =====================================================================
--  Contabilidad - FASE 6c: diagnostico de periodo en calcular_isr_nomina
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-30_contabilidad_isr_periodicidad.sql
--
--  calcular_isr_nomina ya reparte el ISR correctamente en proporcion a
--  los dias reales del periodo vs. los dias que representa la tabla
--  cargada (dias_periodo) - eso no cambia. Lo que faltaba es devolver
--  esos dos numeros para que la app pueda avisar cuando no coinciden
--  (ej. alguien deja el periodo en "todo el mes" con una tabla semanal
--  cargada, y el ISR se prorratea sin que se note).
--
--  Idempotente.
-- =====================================================================

begin;

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
    v_dias_nomina    numeric;
    v_tarifa_id      bigint;
    v_tarifa         public.isr_tarifas%rowtype;
    v_dias_tabla     numeric;
    v_factor         numeric; -- dias_tabla / dias_nomina: escala el ingreso al periodo de la tabla
    v_total          numeric(14,2) := 0;
    v_detalle        jsonb := '[]'::jsonb;
    v_sueldo         numeric(14,2);
    v_ingreso_equiv  numeric(14,2);
    v_isr_tabla      numeric(14,2);
    v_isr_periodo    numeric(14,2);
    e                jsonb;
begin
    v_dias_nomina := greatest(1, coalesce(v_periodo_fin, v_fecha_pago) - coalesce(v_periodo_inicio, v_fecha_pago) + 1);

    v_tarifa_id := public._isr_tarifa_vigente(v_fecha_pago);
    v_dias_tabla := 7;
    if v_tarifa_id is not null then
        select * into v_tarifa from public.isr_tarifas where id = v_tarifa_id;
        v_dias_tabla := coalesce(v_tarifa.dias_periodo, 7);
    end if;

    v_factor := v_dias_tabla / v_dias_nomina;

    for e in select * from jsonb_array_elements(v_empleados)
    loop
        v_sueldo := greatest(0, round(coalesce((e->>'sueldo')::numeric, 0), 2));
        v_ingreso_equiv := round(v_sueldo * v_factor, 2);
        v_isr_tabla := public._isr_calcular_monto(v_tarifa_id, v_ingreso_equiv);
        v_isr_periodo := case when v_factor > 0 then round(v_isr_tabla / v_factor, 2) else 0 end;
        v_total := v_total + v_isr_periodo;
        v_detalle := v_detalle || jsonb_build_object('empleado_id', (e->>'empleado_id')::bigint, 'isr', v_isr_periodo);
    end loop;

    return jsonb_build_object(
        'tarifa_id', v_tarifa_id,
        'tarifa_fuente', v_tarifa.fuente,
        'tarifa_vigente_desde', v_tarifa.vigente_desde,
        'dias_nomina', v_dias_nomina,
        'dias_tabla', v_dias_tabla,
        'total', round(v_total, 2),
        'detalle', v_detalle
    );
end;
$$;

revoke all     on function public.calcular_isr_nomina(jsonb) from public;
grant  execute on function public.calcular_isr_nomina(jsonb) to authenticated;

commit;
