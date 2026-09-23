-- =====================================================================
--  Rendimiento real al cerrar una orden de producción
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Al cerrar la orden, Producción pregunta "¿Cuánto salió realmente?"
--  (ej. planeado 15 L, real 14.6 L):
--   - los insumos se descuentan por lo PLANEADO (es lo que se usó);
--   - al inventario entra lo REAL y el costo unitario = costo total ÷ real.
--  Para no tener que reescribir contabilizar_produccion ni el prorrateo de
--  CIF (que dividen el costo entre ordenes_produccion.cantidad_producida),
--  al cerrar:  cantidad_planeada <- lo que se pidió,
--              cantidad_producida <- lo que salió de verdad.
--  Órdenes cerradas antes de esto: cantidad_planeada queda NULL (= igual a
--  cantidad_producida).
--
--  Sin esta migración la app sigue cerrando con lo real, solo no guarda
--  cuánto se había planeado.
--  Idempotente.
-- =====================================================================
begin;

alter table public.ordenes_produccion
    add column if not exists cantidad_planeada numeric;

comment on column public.ordenes_produccion.cantidad_planeada is
    'Cantidad pedida al abrir la orden (se llena al cerrar). cantidad_producida pasa a ser lo que salió de verdad. NULL = orden cerrada antes de 2026-09-23 (planeado = producido).';

commit;
