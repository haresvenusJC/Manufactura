-- =====================================================================
--  Datos del proveedor (SKU, descripción, unidad, factor) congelados por
--  partida en Requisiciones y Órdenes de compra
--  Fecha: 2026-10-01  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Antes, el SKU/descripción/unidad del proveedor (tabla
--  producto_claves_proveedor) solo se veía como referencia en pantalla al
--  capturar. Ahora se GUARDA junto con la partida (igual que el costo
--  estimado ya se congela) para poder analizar la requisición con ambos
--  juegos de datos —el interno y el del proveedor— y para que, al
--  autorizarla, la Orden de compra que resulta ya traiga el dato del
--  proveedor listo para comunicarle a él (a quien no le interesa tu SKU
--  interno).
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.requisiciones_compra_detalle
    add column if not exists sku_proveedor              text,
    add column if not exists descripcion_proveedor       text,
    add column if not exists unidad_proveedor            text,
    add column if not exists factor_conversion_proveedor numeric;

alter table public.ordenes_compra_detalle
    add column if not exists sku_proveedor              text,
    add column if not exists descripcion_proveedor       text,
    add column if not exists unidad_proveedor            text,
    add column if not exists factor_conversion_proveedor numeric;

-- requisicion_autorizar: copia también estos 4 campos del proveedor al
-- crear la Orden de compra (antes solo copiaba producto/cantidad/costo).
create or replace function public.requisicion_autorizar(
    p_requisicion_id bigint,
    p_proveedor_id   bigint,
    p_fecha_esperada date default null,
    p_moneda_id      bigint default null,
    p_revisada_por   text default null
)
returns table (oc_id bigint, oc_folio text)
language plpgsql
volatile
set search_path = public
as $$
declare
    v_estatus text;
    v_oc_id   bigint;
    v_oc_folio text;
begin
    select estatus into v_estatus
      from public.requisiciones_compra
     where id = p_requisicion_id
       for update;

    if v_estatus is null then
        raise exception 'La requisición % no existe.', p_requisicion_id;
    end if;
    if v_estatus <> 'pendiente' then
        raise exception 'La requisición ya está en estatus "%": no se puede autorizar de nuevo.', v_estatus;
    end if;
    if p_proveedor_id is null then
        raise exception 'Elige el proveedor con el que se va a comprar.';
    end if;
    if not exists (select 1 from public.requisiciones_compra_detalle where requisicion_id = p_requisicion_id) then
        raise exception 'La requisición no tiene partidas.';
    end if;

    v_oc_folio := 'OC-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.ordenes_compra (folio, proveedor_id, fecha, fecha_esperada, moneda_id, estatus, notas)
    values (
        v_oc_folio, p_proveedor_id, current_date, p_fecha_esperada, p_moneda_id, 'abierta',
        'Generada desde requisición ' || (select folio from public.requisiciones_compra where id = p_requisicion_id)
    )
    returning id into v_oc_id;

    insert into public.ordenes_compra_detalle (
        orden_compra_id, producto_id, descripcion, cantidad, cantidad_recibida, costo_unitario_estimado,
        unidad_medida_id, notas, sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor
    )
    select v_oc_id, d.producto_id, d.descripcion, d.cantidad, 0, d.costo_estimado, d.unidad_medida_id, d.notas,
           d.sku_proveedor, d.descripcion_proveedor, d.unidad_proveedor, d.factor_conversion_proveedor
      from public.requisiciones_compra_detalle d
     where d.requisicion_id = p_requisicion_id;

    update public.requisiciones_compra
       set estatus = 'autorizada',
           orden_compra_id = v_oc_id,
           revisada_por = p_revisada_por,
           revisada_en = now()
     where id = p_requisicion_id;

    return query select v_oc_id, v_oc_folio;
end;
$$;

grant execute on function public.requisicion_autorizar(bigint, bigint, date, bigint, text) to authenticated;

commit;
