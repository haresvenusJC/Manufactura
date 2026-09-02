-- =====================================================================
--  Proveedores: datos fiscales (para conciliar CFDI por RFC y defaults)
--  Fecha: 2026-09-03  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Alinea proveedores con clientes: RFC, régimen fiscal, domicilio, y
--  valores por defecto para las compras (uso CFDI, condición, forma /
--  método de pago, moneda, cuenta de gasto/inventario).
-- =====================================================================

begin;

alter table public.proveedores
    add column if not exists rfc             text,
    add column if not exists razon_social    text,
    add column if not exists regimen_fiscal  text,
    add column if not exists cp              text,
    add column if not exists email           text,
    add column if not exists direccion       text,
    add column if not exists uso_cfdi        text default 'G03',
    add column if not exists condicion_pago  text default 'credito',
    add column if not exists dias_credito    integer default 0,
    add column if not exists cuenta_gasto_id bigint references public.cuentas_contables (id) on delete set null,
    add column if not exists forma_pago      text,
    add column if not exists metodo_pago     text,
    add column if not exists moneda          text default 'MXN',
    add column if not exists activo          boolean not null default true,
    add column if not exists notas           text;

-- El RFC identifica de forma única al proveedor (para el match del XML).
create unique index if not exists proveedores_rfc_uq
    on public.proveedores (lower(rfc))
    where rfc is not null and rfc <> '';

commit;
