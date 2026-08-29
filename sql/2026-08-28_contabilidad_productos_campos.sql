-- =====================================================================
--  Contabilidad - FASE 4a: campos contables en productos
--  Fecha: 2026-08-28   Proyecto: Hares de Mexico (Supabase)
--
--  Se pega y corre a mano en:  Supabase -> SQL Editor
--  Requiere: sql/2026-08-28_contabilidad_cuentas.sql
--
--  Agrega a productos:
--   - tasa_iva   (null = exento, 0 = tasa 0%, 0.16 / 0.08 = gravado)
--   - tasa_ieps  (0 por defecto)
--   - cuenta_inventario_id  (a que cuenta de activo entra al comprarlo)
--   - cuenta_costo_id       (a que cuenta de costo va al consumirlo / venderlo)
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.productos
    add column if not exists tasa_iva             numeric(5,4) default 0.16,
    add column if not exists tasa_ieps            numeric(5,4) not null default 0,
    add column if not exists cuenta_inventario_id bigint references public.cuentas_contables(id),
    add column if not exists cuenta_costo_id      bigint references public.cuentas_contables(id);

-- Defaults por tipo, solo donde este null ------------------------------
update public.productos p
   set cuenta_inventario_id = (select id from public.cuentas_contables where codigo = '115.01')
 where p.cuenta_inventario_id is null and p.tipo in ('materia_prima','insumo');

update public.productos p
   set cuenta_inventario_id = (select id from public.cuentas_contables where codigo = '115.04')
 where p.cuenta_inventario_id is null and p.tipo = 'producto';

update public.productos p
   set cuenta_costo_id = (select id from public.cuentas_contables where codigo = '502.01')
 where p.cuenta_costo_id is null and p.tipo in ('materia_prima','insumo');

update public.productos p
   set cuenta_costo_id = (select id from public.cuentas_contables where codigo = '501.01')
 where p.cuenta_costo_id is null and p.tipo = 'producto';

commit;
