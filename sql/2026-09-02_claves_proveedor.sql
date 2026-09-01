-- =====================================================================
--  Claves de proveedor por producto
--  Fecha: 2026-09-02  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Un producto puede tener VARIAS claves de proveedor: cómo lo identifica
--  cada proveedor en sus facturas (NoIdentificacion del CFDI), su
--  ClaveProdServ del SAT y la descripción tal como llega en el XML.
--  Sirve para, más adelante, resolver automáticamente los conceptos de
--  una factura XML contra el catálogo interno.
-- =====================================================================

begin;

create table if not exists public.producto_claves_proveedor (
    id                  bigint generated always as identity primary key,
    producto_id         bigint not null references public.productos (id) on delete cascade,
    proveedor_id        bigint references public.proveedores (id) on delete set null,
    clave               text not null,     -- código del proveedor (NoIdentificacion del CFDI)
    clave_sat           text,              -- ClaveProdServ (c_ClaveProdServ) del CFDI
    descripcion_factura text,              -- descripción tal como aparece en la factura
    unidad_factura      text,              -- ClaveUnidad / unidad del concepto en el CFDI
    notas               text,
    created_at          timestamptz not null default now()
);

create index if not exists producto_claves_proveedor_prod_idx
    on public.producto_claves_proveedor (producto_id);
create index if not exists producto_claves_proveedor_busqueda_idx
    on public.producto_claves_proveedor (proveedor_id, lower(clave));

-- La misma clave de un proveedor no puede apuntar a dos productos.
create unique index if not exists producto_claves_proveedor_uq
    on public.producto_claves_proveedor (proveedor_id, lower(clave))
    where proveedor_id is not null;

alter table public.producto_claves_proveedor enable row level security;
drop policy if exists admin_all on public.producto_claves_proveedor;
create policy admin_all on public.producto_claves_proveedor
    for all to authenticated using (true) with check (true);
grant all on public.producto_claves_proveedor to authenticated;

commit;
