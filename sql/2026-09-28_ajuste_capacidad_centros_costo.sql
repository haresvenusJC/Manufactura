-- =====================================================================
--  Ajusta la capacidad normal de SURT/MEZ/ENV a la operación real:
--  2 operadoras TOTALES (Michelle Carrera y Sol Lipa) rotando entre las
--  tres etapas — no 2 operadoras DEDICADAS a cada una (6 en total), que
--  es lo que sembró la migración por default.
--  Fecha: 2026-09-28  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Cálculo (ver manual-costos-produccion.html, Parte 3):
--    2 operadoras × 8 h × 24 días × 0.90 × 0.80 × 0.96 = 265.42 h/mes
--    de TODA la planta, repartidas 15% SURT / 25% MEZ / 60% ENV:
--      SURT  39.81 h/mes
--      MEZ   66.36 h/mes
--      ENV  159.25 h/mes
--
--  cap_operadores se deja en NULL a propósito en los tres: como el
--  personal rota, el sub-cálculo de "operadores por centro" no aplica
--  aquí (asumiría gente dedicada) — capacidad_normal_horas es el único
--  número que de verdad usa el prorrateo. Ajusta el % de reparto (y
--  estos tres valores) si tu contador y tú deciden uno distinto.
--
--  Idempotente.
-- =====================================================================

begin;

update public.centros_costo
   set capacidad_normal_horas = 39.81,
       cap_operadores = null
 where codigo = 'SURT';

update public.centros_costo
   set capacidad_normal_horas = 66.36,
       cap_operadores = null
 where codigo = 'MEZ';

update public.centros_costo
   set capacidad_normal_horas = 159.25,
       cap_operadores = null
 where codigo = 'ENV';

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select codigo, nombre, capacidad_normal_horas, cap_operadores from public.centros_costo order by codigo;
