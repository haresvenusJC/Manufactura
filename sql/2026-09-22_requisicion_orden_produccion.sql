-- =====================================================================
--  Requisiciones de compra ligadas a una orden de producción
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Idempotente.
--
--  Cuando una orden de producción queda "Pendiente por insumos" y desde ahí
--  se genera la requisición de lo faltante, la requisición guarda de qué
--  orden salió. Con eso:
--   · "Faltantes para producir" descuenta lo que ya está pedido para esa
--     orden (no se vuelve a pedir cada vez que se pulsa "Revisar y continuar");
--   · el documento "Estado de la orden" (Consulta de órdenes de producción →
--     Detalle) lista sus requisiciones y en qué van.
--  Sin esta migración la app sigue funcionando igual que antes (sin liga).
-- =====================================================================

begin;

alter table public.requisiciones_compra
    add column if not exists orden_produccion_id bigint
        references public.ordenes_produccion (id) on delete set null;

create index if not exists requisiciones_compra_orden_prod_idx
    on public.requisiciones_compra (orden_produccion_id);

comment on column public.requisiciones_compra.orden_produccion_id is
    'Orden de producción cuyos faltantes originaron esta requisición (NULL = manual / desde Tareas).';

commit;
