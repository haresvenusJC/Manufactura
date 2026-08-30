-- =====================================================================
--  Contabilidad - FASE 6e: segunda correccion de la tabla ISR "vigente hoy"
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-30_contabilidad_isr.sql
--    sql/2026-08-30_contabilidad_isr_periodicidad.sql
--    sql/2026-08-30_contabilidad_isr_diagnostico.sql
--    sql/2026-08-30b_contabilidad_isr_correccion.sql
--
--  Despues de correr la correccion anterior (2026-08-30b), se guardo
--  otra prueba del extractor de PDF que volvio a quedar como "vigente
--  hoy" (por created_at mas reciente) - esta vez trajo la tarifa ANUAL
--  del Anexo 8 (topes ~52x los de la tabla semanal, la razon exacta de
--  365/7 dias) en vez de la de periodo de 7 dias. La app ya no debe
--  volver a equivocarse de tabla al extraer (parsearTextoATramos ahora
--  filtra por magnitud esperada segun la periodicidad seleccionada),
--  pero la version ya guardada con datos malos sigue "vigente" hasta
--  que se inserte una mas reciente que la tape.
--
--  Misma tabla semanal verificada digito por digito contra el PDF
--  oficial (Anexo 8 RMF 2026, DOF 28/12/2025, apartado B.II), sembrada
--  de nuevo con fecha de hoy para volver a ganar el desempate.
--
--  Idempotente (no duplica si ya se corrio).
-- =====================================================================

begin;

do $$
declare
    v_tarifa_id bigint;
    v_fuente text := 'Anexo 8 RMF 2026, DOF 28/12/2025 (tarifa periodo de 7 dias) - correccion 2 2026-08-30';
begin
    if not exists (
        select 1 from public.isr_tarifas where fuente = v_fuente
    ) then
        insert into public.isr_tarifas (vigente_desde, fuente, dias_periodo)
        values (current_date, v_fuente, 7)
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
