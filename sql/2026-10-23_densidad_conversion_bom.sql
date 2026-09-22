-- =====================================================================
--  Densidad para convertir BOM en volumen ↔ inventario en peso
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  Contexto: las recetas (BOM) están capturadas en volumen (Litros/mL) —
--  más práctico en planta que pesar cada insumo—, pero varios insumos se
--  llevan en inventario por peso (Kilogramos/gramos). Sin la densidad del
--  insumo, litros y kilos no son convertibles, así que hasta ahora
--  Producción los tomaba 1 a 1 (1 L = 1 kg), lo que descuadra el
--  requerimiento, el descuento de inventario y el costo del lote.
--
--  Qué agrega:
--   1. productos.densidad_kg_l (opcional). Un litro de ese insumo pesa
--      tantos kilos. Se captura en Catálogo -> Más detalles -> "Densidad
--      (kg por litro)".
--   2. El cálculo de necesidades (js/produccion.js) ya usa esta columna:
--      si el BOM está en volumen y el inventario en peso (o al revés) y hay
--      densidad, convierte exacto; si no hay densidad, sigue tomando 1 a 1
--      y lo avisa en el panel.
--   3. Siembra OPCIONAL: valores de referencia (fichas técnicas / bibliografía
--      química, ~20-25 °C) para los insumos de `ejemplos/materias_primas_LOVLUB.csv`
--      que son sustancias químicas estándar con densidad bien documentada y
--      poca variación entre proveedores. SOLO donde la columna esté vacía —
--      no pisa lo que ya hayas capturado a mano. Son valores de referencia,
--      no un certificado de tu lote: verifícalos contra la ficha técnica
--      (COA) de tu proveedor si te interesa la exactitud fina, y ajústalos
--      en Catálogo si difieren.
--      NO se siembran (demasiado variables entre marca/lote, o polvos que
--      normalmente ya se pesan en kg y no lo necesitan): saborizantes/aromas,
--      colorantes, feromonas, Biocare ITH (blend de marca), CMC, ácido
--      cítrico, L-arginina, EDTA, mentol, lauril sulfato de amonio.
--
--  Esto NO toca tus recetas: los renglones del BOM se quedan en Litros tal
--  como los capturas hoy. Es idempotente — correrlo de nuevo no cambia lo
--  que ya tenga un valor.
--
--  Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

alter table public.productos
    add column if not exists densidad_kg_l numeric;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'productos_densidad_kg_l_check') then
        alter table public.productos
            add constraint productos_densidad_kg_l_check
            check (densidad_kg_l is null or densidad_kg_l > 0);
    end if;
end $$;

comment on column public.productos.densidad_kg_l is
    'Kilogramos que pesa 1 litro de este insumo. Opcional: solo para insumos cuyo BOM está en volumen y el inventario en peso (o al revés). La usa Producción para convertir bien cuánto pedir/descontar.';

-- Siembra de referencia — valores típicos, no pisa lo ya capturado.
-- (fuente: fichas técnicas de fabricante / bibliografía química estándar)
update public.productos set densidad_kg_l = 1.00  where densidad_kg_l is null and nombre ilike '%agua%destilada%';                 -- agua: 1.00 kg/L (constante)
update public.productos set densidad_kg_l = 1.26  where densidad_kg_l is null and nombre ilike '%glicerina%';                      -- glicerina USP: ~1.26 kg/L a 20 °C
update public.productos set densidad_kg_l = 1.04  where densidad_kg_l is null and (nombre ilike '%propilenglicol%' or nombre ilike '%propylene glycol%');  -- propilenglicol USP: ~1.036 kg/L a 20 °C
update public.productos set densidad_kg_l = 1.29  where densidad_kg_l is null and nombre ilike '%sorbitol%';                       -- sorbitol solución 70%: ~1.29 kg/L a 20 °C (asume grado 70%, el usual)
update public.productos set densidad_kg_l = 1.36  where densidad_kg_l is null and nombre ilike '%sorbato%potasio%';                -- sorbato de potasio (polvo): ~1.36 kg/L — solo aplica si algún BOM lo llegara a medir por volumen
update public.productos set densidad_kg_l = 0.97  where densidad_kg_l is null and nombre ilike '%dimeticona%';                     -- dimeticona (silicona, grado cosmético ~350 cSt): ~0.96-1.00 kg/L según viscosidad — verifica la de tu grado
update public.productos set densidad_kg_l = 1.00  where densidad_kg_l is null and nombre ilike '%dimeticonol%';                    -- dimeticonol: ~1.00 kg/L (±0.1 según grado)
update public.productos set densidad_kg_l = 0.958 where densidad_kg_l is null and nombre ilike '%ciclopentasiloxano%';             -- ciclopentasiloxano (D5): ~0.958 kg/L
update public.productos set densidad_kg_l = 1.10  where densidad_kg_l is null and nombre ilike '%fenoxietanol%';                   -- fenoxietanol: ~1.10 kg/L
update public.productos set densidad_kg_l = 0.81  where densidad_kg_l is null and nombre = 'ALCOHOL';                              -- alcohol etílico ~96°: ~0.81 kg/L — AJUSTA si tu grado/concentración es otro (etanol puro: 0.789)
update public.productos set densidad_kg_l = 1.05  where densidad_kg_l is null and nombre ilike '%lauril%sulfato%';                 -- lauril (éter) sulfato de sodio/amonio, solución ~70%: ~1.05 kg/L
update public.productos set densidad_kg_l = 0.98  where densidad_kg_l is null and nombre ilike '%cloruro%benzalconio%';            -- cloruro de benzalconio, solución 50%: ~0.98 kg/L
update public.productos set densidad_kg_l = 1.10  where densidad_kg_l is null and (nombre ilike '%tween%20%' or nombre ilike '%polisorbato%20%');  -- polisorbato 20 (Tween 20): ~1.10 kg/L
update public.productos set densidad_kg_l = 1.12  where densidad_kg_l is null and nombre ilike '%trietanolamina%';                 -- trietanolamina: ~1.12 kg/L
update public.productos set densidad_kg_l = 1.04  where densidad_kg_l is null and nombre ilike '%betaina%';                        -- betaína de coco, solución ~30%: ~1.04 kg/L
update public.productos set densidad_kg_l = 1.00  where densidad_kg_l is null and nombre ilike '%lidocaina%';                      -- lidocaína: ~1.00 kg/L (dato de menor certeza — normalmente se pesa como polvo, revisa si tu BOM la mide por volumen)

commit;

-- Revisión: qué quedó sembrado y qué insumos del BOM siguen sin densidad
-- (BOM en volumen, inventario en peso, y densidad vacía = se sigue tomando 1 a 1).
select p.nombre, p.densidad_kg_l
  from public.productos p
 where p.densidad_kg_l is not null
 order by p.nombre;

select distinct c.nombre as insumo, um.nombre as unidad_inventario
  from public.bom b
  join public.productos c on c.id = b.componente_id
  join public.unidades_medida um on um.id = c.unidad_medida_id
 where (um.nombre ilike '%kilo%' or um.nombre ilike '%gramo%')
   and c.densidad_kg_l is null
 order by 1;
