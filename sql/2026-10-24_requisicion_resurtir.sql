-- =====================================================================
--  Requisición de compra: líneas "Resurtir" (precargadas de una compra anterior ya recibida y pagada)
--  Fecha: 2026-10-24  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Una línea de "Resurtir" guarda, junto a lo nuestro (producto, cantidad, costo), lo que el proveedor
--  usó en su última factura: Clave UM, Clave SAT, número, descripción, su precio y de qué factura salió.
--  La orden de compra (odc_generar, sin cambios) las usa como punto de partida; son editables ahí.
--  Una línea de "Compra nueva" (o una requisición vieja) deja estas columnas en null.
--  Idempotente.
-- =====================================================================

begin;

alter table public.requisiciones_compra_detalle
    add column if not exists modo_captura        text,
    add column if not exists clave_unidad_sat    text,
    add column if not exists clave_prod_serv_sat text,
    add column if not exists precio_proveedor    numeric(18,6),
    add column if not exists origen_factura      text;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'req_detalle_modo_captura_chk') then
        alter table public.requisiciones_compra_detalle
            add constraint req_detalle_modo_captura_chk
            check (modo_captura is null or modo_captura in ('resurtir', 'nueva'));
    end if;
end $$;

comment on column public.requisiciones_compra_detalle.modo_captura is 'resurtir = precargada de una compra anterior recibida y pagada; nueva/null = captura normal sin datos confirmados del proveedor.';
comment on column public.requisiciones_compra_detalle.precio_proveedor is 'Precio por UNA unidad del proveedor (clave_unidad_sat), como lo facturó la última vez.';
comment on column public.requisiciones_compra_detalle.origen_factura is 'Folio de la factura/recepción de la que se tomaron los datos (solo informativo).';

commit;
