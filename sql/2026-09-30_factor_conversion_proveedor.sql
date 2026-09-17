-- =====================================================================
--  Factor de conversión de la unidad de venta del proveedor
--  Fecha: 2026-09-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  producto_claves_proveedor.unidad_factura ya guardaba la unidad tal como
--  la vende el proveedor (antes solo se llenaba sola al importar un XML).
--  Ahora también se captura a mano desde Productos -> "Claves de
--  proveedor", con presets (Millar, Tambo, Saco...) — y ese preset trae
--  su factor de conversión a la unidad interna, que es lo que agrega esta
--  columna: cuántas unidades internas (pieza, kilo, litro...) hay en 1
--  unidad de venta del proveedor. Ej. proveedor vende "Millar" de piezas
--  -> factor_conversion = 1000; proveedor vende "Tambo 200 L" -> 200.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.producto_claves_proveedor
    add column if not exists factor_conversion numeric;

comment on column public.producto_claves_proveedor.factor_conversion is
    'Unidades internas por 1 unidad de venta del proveedor (unidad_factura). NULL o 1 = misma unidad, sin conversión.';

commit;
