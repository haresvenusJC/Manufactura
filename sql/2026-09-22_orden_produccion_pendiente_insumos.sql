-- =====================================================================
--  Órdenes de producción que no se pueden completar por falta de
--  insumos: en vez de solo fallar sin dejar rastro, se guardan con
--  estado 'borrador' (ya permitido por ordenes_produccion_estado_chk,
--  no se usaba) junto con el detalle de qué faltaba, para poder
--  continuarlas después sin volver a capturar procesos/equipo.
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

alter table public.ordenes_produccion
    add column if not exists faltantes_insumos jsonb;

comment on column public.ordenes_produccion.faltantes_insumos is
    'Snapshot ([{id,nombre,unidad,requerido,disponible}, ...]) de lo que faltaba la última vez que se revisó una orden en estado borrador. Null cuando no aplica (en_proceso/cerrada/cancelada).';

commit;
