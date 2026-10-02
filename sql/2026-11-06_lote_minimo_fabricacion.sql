-- =====================================================================
--  Lote mínimo de fabricación (referencia por producto)
--  Fecha: 2026-11-06  ·  Proyecto: Hares de México (Supabase)
--
--  Un solo número por producto, en SU unidad de medida: lo mínimo que
--  conviene fabricar por orden. No obliga nada: al generar una orden de
--  producción desde un pedido (o desde "Faltantes"), si lo que falta es
--  MENOS que este mínimo, Producción pregunta si fabricas el lote mínimo
--  (y lo que sobra queda en inventario) o solo lo necesario.
--  Se captura en Productos → ☰ → Editar artículo. Idempotente.
-- =====================================================================
begin;

alter table public.productos
    add column if not exists lote_minimo_fabricacion numeric;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'productos_lote_minimo_fabricacion_chk') then
        alter table public.productos
            add constraint productos_lote_minimo_fabricacion_chk check (lote_minimo_fabricacion is null or lote_minimo_fabricacion > 0);
    end if;
end $$;

comment on column public.productos.lote_minimo_fabricacion is
    'Lote mínimo de fabricación en la unidad del producto (solo referencia; Producción pregunta si lo que falta es menor).';

commit;
