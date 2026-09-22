-- =====================================================================
--  BOM capturado "por lote completo" en vez de "por 1 unidad producida":
--  varios semiterminados (los "Granel ...") tienen su receta escrita para
--  un lote de referencia (ej. 15 Litros), no para 1 Litro. Sin este dato,
--  Producción multiplicaba esas cantidades directo por lo que se pide
--  producir (Litros) en vez de por cuántos lotes representa esa cantidad,
--  disparando requerimientos ~15 veces de más.
--
--  `productos.rendimiento_lote_bom`: cuántas unidades (en la unidad de
--  inventario del producto) rinde UNA corrida de la receta tal como está
--  capturada en el BOM. NULL o 0 = BOM capturado por 1 unidad (como hasta
--  ahora, sin cambio de comportamiento). Ej.: "Granel Aceite Sey Chocolate
--  15 Litros" -> 15 (el BOM ya escrito se pensó para rendir 15 Litros).
--
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

alter table public.productos
    add column if not exists rendimiento_lote_bom numeric;

comment on column public.productos.rendimiento_lote_bom is
    'Unidades (en la unidad de inventario del producto) que rinde UNA corrida del BOM tal como está capturado. NULL o 0 = BOM por 1 unidad (default). Ej. 15 para un "Granel ... 15 Litros" cuya receta se escribió para el lote completo.';

commit;
