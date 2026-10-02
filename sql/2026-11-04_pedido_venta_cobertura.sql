-- =====================================================================
--  Pedidos de venta ↔ Producción / Compras  (ENTREGA 3 de 4)
--  Fecha: 2026-11-04  ·  Proyecto: Hares de México (Supabase)
--
--  Cuando a un pedido le falta mercancía, el faltante se cubre con una
--  ORDEN DE PRODUCCIÓN (si el producto se fabrica) o una REQUISICIÓN de
--  compra (si se compra). Estas columnas dejan ligados esos documentos al
--  pedido, para poder seguirlos (entrega 4) y para no volver a pedir lo
--  que ya va en camino.
--
--   - ordenes_produccion.pedido_venta_id / pedido_venta_detalle_id
--   - requisiciones_compra.pedido_venta_id
--
--  Solo agrega columnas opcionales (null en todo lo existente). No toca
--  inventario, contabilidad ni reservas. Idempotente. Pégalo completo en
--  Supabase -> SQL Editor.
-- =====================================================================
begin;

alter table public.ordenes_produccion
    add column if not exists pedido_venta_id         bigint references public.pedidos_venta (id) on delete set null,
    add column if not exists pedido_venta_detalle_id bigint references public.pedidos_venta_detalle (id) on delete set null;

create index if not exists ordenes_produccion_pedido_idx on public.ordenes_produccion (pedido_venta_id);

comment on column public.ordenes_produccion.pedido_venta_id is
    'Pedido de venta cuyo faltante cubre esta orden (null = orden manual o de otro origen).';

alter table public.requisiciones_compra
    add column if not exists pedido_venta_id bigint references public.pedidos_venta (id) on delete set null;

create index if not exists requisiciones_compra_pedido_idx on public.requisiciones_compra (pedido_venta_id);

comment on column public.requisiciones_compra.pedido_venta_id is
    'Pedido de venta cuyo faltante cubre esta requisición (null = a mano o de otro origen).';

commit;
