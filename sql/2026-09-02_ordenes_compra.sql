-- =====================================================================
--  Órdenes de compra + Recibo de mercancía  (Fase 1)
--  Fecha: 2026-09-02  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  La OC es solo el paso previo. El recibo reutiliza el flujo de Compras:
--  crea un documento 'entrada_compra' (documentos + documento_detalles +
--  registrar_movimiento_inventario_fifo) y, si el módulo contable está,
--  lo contabiliza con contabilizar_compra. No hay RPC nueva.
-- =====================================================================

begin;

create table if not exists public.ordenes_compra (
    id             bigint generated always as identity primary key,
    folio          text,
    proveedor_id   bigint references public.proveedores (id) on delete set null,
    fecha          date not null default current_date,
    fecha_esperada date,
    moneda_id      bigint references public.monedas (id),
    estatus        text not null default 'abierta'
        check (estatus in ('borrador','abierta','recibida_parcial','recibida','cancelada')),
    notas          text,
    created_at     timestamptz not null default now()
);

create table if not exists public.ordenes_compra_detalle (
    id                       bigint generated always as identity primary key,
    orden_compra_id          bigint not null references public.ordenes_compra (id) on delete cascade,
    producto_id              bigint references public.productos (id) on delete set null,
    descripcion              text,                     -- si el producto aún no existe en el catálogo
    cantidad                 numeric not null default 0,
    cantidad_recibida        numeric not null default 0,
    costo_unitario_estimado  numeric not null default 0,
    unidad_medida_id         bigint references public.unidades_medida (id),
    notas                    text
);

create index if not exists ordenes_compra_detalle_oc_idx
    on public.ordenes_compra_detalle (orden_compra_id);
create index if not exists ordenes_compra_proveedor_idx
    on public.ordenes_compra (proveedor_id);

-- Enlace recepción -> documento de entrada (reusa el flujo de Compras).
alter table public.documentos
    add column if not exists orden_compra_id bigint references public.ordenes_compra (id) on delete set null;

alter table public.ordenes_compra          enable row level security;
alter table public.ordenes_compra_detalle  enable row level security;
drop policy if exists admin_all on public.ordenes_compra;
drop policy if exists admin_all on public.ordenes_compra_detalle;
create policy admin_all on public.ordenes_compra
    for all to authenticated using (true) with check (true);
create policy admin_all on public.ordenes_compra_detalle
    for all to authenticated using (true) with check (true);
grant all on public.ordenes_compra, public.ordenes_compra_detalle to authenticated;

commit;
