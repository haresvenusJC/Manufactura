-- =====================================================================
--  Tipo de cambio en la orden de compra (compras en dólares)
--  Proyecto: Hares de México (Supabase)
--
--  El tipo de cambio se trae del DOF (Edge Function tipo-cambio-dof) al
--  elegir una moneda distinta de MXN, pero queda editable en la OC.
--  Se guarda con su fuente y la fecha a la que corresponde.
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

alter table public.ordenes_compra add column if not exists tipo_cambio numeric(12, 6);
alter table public.ordenes_compra add column if not exists tipo_cambio_fuente text;
alter table public.ordenes_compra add column if not exists tipo_cambio_fecha date;

commit;
