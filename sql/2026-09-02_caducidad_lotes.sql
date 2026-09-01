-- =====================================================================
--  Caducidad y lote del proveedor por lote recibido
--  Fecha: 2026-09-02  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  - lotes_inventario.fecha_caducidad : vencimiento de ESE lote (cada
--    recepción tiene su propia fecha).
--  - lotes_inventario.lote_proveedor  : número de lote tal como lo marca
--    el proveedor (se captura a mano en "Recibo de mercancía").
--  - productos.requiere_caducidad     : bandera para saber a qué productos
--    hay que pedir la caducidad al recibir.
-- =====================================================================

begin;

alter table public.lotes_inventario
    add column if not exists fecha_caducidad date,
    add column if not exists lote_proveedor  text;

alter table public.productos
    add column if not exists requiere_caducidad boolean not null default false;

create index if not exists lotes_inventario_caducidad_idx
    on public.lotes_inventario (fecha_caducidad)
    where fecha_caducidad is not null;

commit;
