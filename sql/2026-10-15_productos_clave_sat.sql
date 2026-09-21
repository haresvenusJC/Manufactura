-- =====================================================================
--  Productos: clave de producto/servicio del SAT (ClaveProdServ)
--  Fecha: 2026-10-15  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Hasta ahora la ClaveProdServ del CFDI solo se guardaba dentro de
--  "Claves de proveedor" (producto_claves_proveedor.clave_sat), es decir,
--  por proveedor. El producto en sí no tenía dónde llevar SU clave del
--  catálogo c_ClaveProdServ del SAT. Esta columna es esa: una sola clave
--  por producto (8 dígitos), la que se usa al facturar/contabilizar.
--
--  Backfill: solo cuando el producto tiene UNA sola clave SAT distinta
--  entre todas sus claves de proveedor (sin ambigüedad). Si sus proveedores
--  le ponen claves distintas, se deja vacío para que la elijas tú.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.productos
    add column if not exists clave_sat text;

comment on column public.productos.clave_sat is
  'ClaveProdServ del catálogo c_ClaveProdServ del SAT (8 dígitos) de este producto.';

update public.productos p
   set clave_sat = s.clave_sat
  from (
      select producto_id, min(trim(clave_sat)) as clave_sat
        from public.producto_claves_proveedor
       where nullif(trim(clave_sat), '') is not null
       group by producto_id
      having count(distinct trim(clave_sat)) = 1
  ) s
 where s.producto_id = p.id
   and nullif(trim(p.clave_sat), '') is null;

commit;
