-- =====================================================================
--  Corrección al candado "no recibir más de lo pedido"
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor,
--  DESPUÉS de sql/2026-09-23_candados_cuadre_inventario.sql.
--
--  documento_detalles.cantidad guarda 2 decimales: una recepción exacta de
--  152.015 (lo pedido) se guarda como 152.02, y el candado la rechazaba por
--  exceder lo pedido. Ahora tolera el redondeo (media centésima por
--  recepción). Solo cambia esa función; los triggers siguen igual.
--
--  Idempotente.
-- =====================================================================

begin;

create or replace function public._candado_recibo_no_excede_oc()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc      public.documentos%rowtype;
    v_pedido   numeric;
    v_recibido numeric;
    v_prod     text;
    v_folio    text;
    v_ndocs    integer;
begin
    if NEW.producto_id is null then return NEW; end if;
    if TG_OP = 'UPDATE' and coalesce(NEW.cantidad, 0) <= coalesce(OLD.cantidad, 0) then return NEW; end if;

    select * into v_doc from public.documentos where id = NEW.documento_id;
    if not found or v_doc.orden_compra_id is null
       or coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada')
       or coalesce(v_doc.estado, '') = 'cancelado' then
        return NEW;
    end if;

    select sum(coalesce(cantidad, 0)) into v_pedido
      from public.ordenes_compra_detalle
     where orden_compra_id = v_doc.orden_compra_id and producto_id = NEW.producto_id;
    if v_pedido is null then return NEW; end if;   -- producto fuera de la OC: no aplica

    select coalesce(sum(dd.cantidad), 0) into v_recibido
      from public.documento_detalles dd
      join public.documentos d on d.id = dd.documento_id
     where d.orden_compra_id = v_doc.orden_compra_id
       and d.tipo_movimiento in ('entrada_compra', 'entrada')
       and coalesce(d.estado, '') <> 'cancelado'
       and dd.producto_id = NEW.producto_id
       and dd.id is distinct from NEW.id;

    -- documento_detalles.cantidad guarda 2 decimales (152.015 -> 152.02): cada
    -- recepción puede redondear hasta media centésima hacia arriba.
    select count(distinct dd.documento_id) + 1 into v_ndocs
      from public.documento_detalles dd
      join public.documentos d on d.id = dd.documento_id
     where d.orden_compra_id = v_doc.orden_compra_id
       and d.tipo_movimiento in ('entrada_compra', 'entrada')
       and coalesce(d.estado, '') <> 'cancelado'
       and dd.producto_id = NEW.producto_id
       and dd.documento_id <> NEW.documento_id;

    if v_recibido + coalesce(NEW.cantidad, 0) > v_pedido + 0.005 * v_ndocs + 0.0005 then
        select nombre into v_prod from public.productos where id = NEW.producto_id;
        select folio into v_folio from public.ordenes_compra where id = v_doc.orden_compra_id;
        raise exception E'No se puede recibir % de "%": la orden % pidió % y ya se recibieron %.\nSi de verdad llegó de más, primero ajusta la cantidad de la orden de compra; si es una recepción repetida, no la vuelvas a capturar.',
            NEW.cantidad, coalesce(v_prod, NEW.producto_id::text), coalesce(v_folio, v_doc.orden_compra_id::text),
            v_pedido, v_recibido;
    end if;
    return NEW;
end;
$$;

commit;
