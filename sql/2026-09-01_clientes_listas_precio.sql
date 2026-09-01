-- =====================================================================
--  Catálogo de Clientes + Listas de precio
--  Fecha: 2026-09-01   Proyecto: Hares de Mexico (Supabase)
--
--  Se pega y corre a mano en:  Supabase -> SQL Editor
--  Requiere: sql/2026-08-28_contabilidad_cuentas.sql  (cuenta_cobro_id)
--            sql/2026-09-01_precio_venta.sql           (productos.precio_venta)
--
--  - listas_precio        : listas con nombre (Mayoreo, Cadenas, ...).
--  - lista_precio_items    : precio de cada producto en cada lista.
--  - clientes              : ficha del cliente (datos fiscales para CFDI +
--                            condición de pago + cuenta de cobro + lista).
--  - documentos.cliente_id : liga la venta al cliente.
--  - precio_venta_cliente(producto, cliente) : precio a usar (lista del
--    cliente -> productos.precio_venta como respaldo).
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.listas_precio (
    id          bigint generated always as identity primary key,
    nombre      text not null unique,
    descripcion text,
    moneda_id   bigint references public.monedas(id),
    incluye_iva boolean not null default false,   -- los precios ya traen IVA
    es_default  boolean not null default false,
    activa      boolean not null default true,
    created_at  timestamptz not null default now()
);

create table if not exists public.lista_precio_items (
    id          bigint generated always as identity primary key,
    lista_id    bigint not null references public.listas_precio(id) on delete cascade,
    producto_id bigint not null references public.productos(id)     on delete cascade,
    precio      numeric(14,4) not null check (precio >= 0),
    unique (lista_id, producto_id)
);
create index if not exists idx_lpi_lista    on public.lista_precio_items(lista_id);
create index if not exists idx_lpi_producto on public.lista_precio_items(producto_id);

create table if not exists public.clientes (
    id              bigint generated always as identity primary key,
    nombre          text not null,
    rfc             text,
    regimen_fiscal  text,                 -- SAT c_RegimenFiscal
    uso_cfdi        text default 'G03',   -- SAT c_UsoCFDI
    cp              text,                 -- codigo postal del receptor
    contacto        text,
    email           text,
    telefono        text,
    direccion       text,
    condicion_pago  text not null default 'contado' check (condicion_pago in ('contado','credito')),
    dias_credito    smallint not null default 0 check (dias_credito >= 0),
    cuenta_cobro_id bigint references public.cuentas_contables(id),
    lista_precio_id bigint references public.listas_precio(id) on delete set null,
    activo          boolean not null default true,
    notas           text,
    created_at      timestamptz not null default now()
);
create index if not exists idx_clientes_nombre on public.clientes(nombre);

alter table public.documentos
    add column if not exists cliente_id bigint references public.clientes(id) on delete set null;

alter table public.listas_precio      enable row level security;
alter table public.lista_precio_items enable row level security;
alter table public.clientes           enable row level security;
drop policy if exists admin_all on public.listas_precio;
create policy admin_all on public.listas_precio      for all to authenticated using (true) with check (true);
drop policy if exists admin_all on public.lista_precio_items;
create policy admin_all on public.lista_precio_items for all to authenticated using (true) with check (true);
drop policy if exists admin_all on public.clientes;
create policy admin_all on public.clientes           for all to authenticated using (true) with check (true);

-- Lista base "General" (solo si no hay ninguna).
insert into public.listas_precio (nombre, descripcion, es_default)
select 'General', 'Lista base — usa el precio de venta del producto cuando no hay renglon propio', true
where not exists (select 1 from public.listas_precio);

-- Precio de venta a usar para (producto, cliente):
--   1) renglon en la lista del cliente
--   2) productos.precio_venta como respaldo
create or replace function public.precio_venta_cliente(p_producto_id bigint, p_cliente_id bigint)
returns numeric
language sql stable
set search_path = public
as $$
    select coalesce(
        (select lpi.precio
           from public.lista_precio_items lpi
           join public.clientes c on c.id = p_cliente_id
          where lpi.producto_id = p_producto_id
            and lpi.lista_id = c.lista_precio_id
          limit 1),
        (select precio_venta from public.productos where id = p_producto_id)
    );
$$;

commit;
