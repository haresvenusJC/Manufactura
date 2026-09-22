-- =====================================================================
--  Antecedentes entre órdenes de producción (y hacia requisiciones de
--  compra que disparen).
--  Fecha: 2026-10-27  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Problema: cuando a una orden de producción le falta un semiterminado
--  (se genera una orden hija para fabricarlo) y/o materia prima (se
--  genera una requisición de compra), no quedaba registro de QUÉ orden
--  disparó esas hijas/requisiciones — solo una nota de texto libre.
--
--  Fix: dos columnas de "antecedente":
--    - ordenes_produccion.orden_origen_id -> la orden de producción que
--      disparó esta (null si se creó directo, sin cascada).
--    - requisiciones_compra.orden_produccion_origen_id -> la orden de
--      producción que disparó esta requisición (null si es manual o por
--      stock bajo mínimo, como ya existía).
--  Se agrega 'orden_produccion' al catálogo de valores de
--  requisiciones_compra.origen.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.ordenes_produccion
    add column if not exists orden_origen_id bigint references public.ordenes_produccion (id) on delete set null;

create index if not exists ordenes_produccion_origen_idx
    on public.ordenes_produccion (orden_origen_id);

alter table public.requisiciones_compra
    add column if not exists orden_produccion_origen_id bigint references public.ordenes_produccion (id) on delete set null;

create index if not exists requisiciones_compra_orden_produccion_origen_idx
    on public.requisiciones_compra (orden_produccion_origen_id);

alter table public.requisiciones_compra drop constraint if exists requisiciones_compra_origen_check;
alter table public.requisiciones_compra add constraint requisiciones_compra_origen_check
    check (origen in ('manual', 'stock_bajo_minimo', 'orden_produccion'));

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select column_name from information_schema.columns
--  where table_name = 'ordenes_produccion' and column_name = 'orden_origen_id';
-- select column_name from information_schema.columns
--  where table_name = 'requisiciones_compra' and column_name = 'orden_produccion_origen_id';
