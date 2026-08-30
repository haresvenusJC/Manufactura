-- =====================================================================
--  Contabilidad - FASE 6b: precision por periodicidad + siembra tabla 2026
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-30_contabilidad_isr.sql
--
--  El SAT no publica una sola tabla "mensual": publica tarifas
--  especificas por periodicidad (7, 10, 15 dias y mensual). Esta
--  empresa paga semanal (campo empleados.sueldo_semanal), asi que la
--  version anterior de calcular_isr_nomina (que siempre convertia a un
--  "mensual equivalente" via 365/12/dias) introducia un redondeo
--  innecesario. Ahora la tabla ISR guarda a cuantos dias corresponde
--  (dias_periodo) y el calculo escala proporcionalmente entre esos
--  dias y los dias reales de la nomina - si coinciden (nomina de 7
--  dias + tabla de 7 dias, el caso real de esta empresa), el factor es
--  exactamente 1 y no hay conversion de por medio.
--
--  Tambien siembra la tarifa oficial de retenciones para periodo de 7
--  dias, vigente 2026 (Anexo 8 RMF 2026, publicado en el DOF el
--  28/12/2025, apartado B.II), para que la nomina calcule bien sin
--  tener que capturar los 11 tramos a mano.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.isr_tarifas
    add column if not exists dias_periodo numeric(5,2) not null default 7;

-- ---------------------------------------------------------------------
-- calcular_isr_nomina: misma firma y contrato, formula corregida.
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
        -- sube (o baja) el sueldo del periodo real de la nomina al periodo
        -- que representa la tabla cargada; si coinciden, v_factor=1 y esto
        -- es el sueldo tal cual.
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
        'total', round(v_total, 2),
        'detalle', v_detalle
    );
end;
$$;

revoke all     on function public.calcular_isr_nomina(jsonb) from public;
grant  execute on function public.calcular_isr_nomina(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- Siembra: tarifa de retenciones para periodo de 7 dias, vigente 2026
-- (Anexo 8 RMF 2026, DOF 28/12/2025, apartado B.II). Solo se inserta si
-- no existe ya una tarifa con esta misma fuente (evita duplicar si el
-- archivo se corre mas de una vez).
-- ---------------------------------------------------------------------
do $$
declare
    v_tarifa_id bigint;
begin
    if not exists (
        select 1 from public.isr_tarifas
         where fuente = 'Anexo 8 RMF 2026, DOF 28/12/2025 (tarifa periodo de 7 dias)'
    ) then
        insert into public.isr_tarifas (vigente_desde, fuente, dias_periodo)
        values ('2026-01-01', 'Anexo 8 RMF 2026, DOF 28/12/2025 (tarifa periodo de 7 dias)', 7)
        returning id into v_tarifa_id;

        insert into public.isr_tarifa_tramos (tarifa_id, orden, limite_inferior, limite_superior, cuota_fija, porcentaje) values
            (v_tarifa_id, 1,     0.01,   194.46,    0.00, 1.92),
            (v_tarifa_id, 2,   194.47,  1650.67,    3.71, 6.40),
            (v_tarifa_id, 3,  1650.68,  2900.87,   96.95, 10.88),
            (v_tarifa_id, 4,  2900.88,  3372.11,  232.96, 16.00),
            (v_tarifa_id, 5,  3372.12,  4037.32,  308.35, 17.92),
            (v_tarifa_id, 6,  4037.33,  8142.75,  427.56, 21.36),
            (v_tarifa_id, 7,  8142.76, 12834.08, 1304.45, 23.52),
            (v_tarifa_id, 8, 12834.09, 24502.45, 2407.86, 30.00),
            (v_tarifa_id, 9, 24502.46, 32669.91, 5908.35, 32.00),
            (v_tarifa_id, 10, 32669.92, 98009.66, 8521.94, 34.00),
            (v_tarifa_id, 11, 98009.67,     null, 30737.49, 35.00);
    end if;
end;
$$;

commit;
