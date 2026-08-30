-- =====================================================================
--  Productos - campos vitales de ERP: stock minimo, compra, activo
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--
--  Agrega a productos:
--   - stock_minimo           umbral para avisar "hay que comprar" en
--                             Inventario/Kardex (no habia ninguna alerta
--                             de nivel bajo todavia).
--   - tiempo_entrega_dias    dias que tarda el proveedor en surtir, para
--                             saber CUANDO pedir (no solo cuanto).
--   - cantidad_minima_compra cantidad minima que el proveedor vende
--                             (MOQ), para no capturar compras por debajo
--                             de lo que realmente se puede comprar.
--   - activo                 igual que empleados.activo: poder
--                             descontinuar un articulo sin borrarlo
--                             (borrarlo rompería BOM/compras historicas).
--
--  No se agrega ningun campo de existencia inicial capturable a mano:
--  stock_actual (columna ya existente, usada por inventario/kardex/
--  salidas) solo se debe mover via el flujo real de compras - por
--  diseño del negocio, nunca se edita directo al dar de alta un
--  articulo.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.productos
    add column if not exists stock_minimo           numeric(14,4) not null default 0 check (stock_minimo >= 0),
    add column if not exists tiempo_entrega_dias     smallint check (tiempo_entrega_dias is null or tiempo_entrega_dias >= 0),
    add column if not exists cantidad_minima_compra  numeric(14,4) check (cantidad_minima_compra is null or cantidad_minima_compra >= 0),
    add column if not exists activo                  boolean not null default true;

commit;
