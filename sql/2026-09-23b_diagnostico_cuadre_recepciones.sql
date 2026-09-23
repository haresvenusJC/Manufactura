-- =====================================================================
--  DIAGNÓSTICO (solo lectura — no cambia nada): recepciones duplicadas y
--  cuadre inventario vs. balanza.
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  Pegar en Supabase -> SQL Editor DESPUÉS de correr
--  sql/2026-09-23_candados_cuadre_inventario.sql. Cada bloque se puede
--  correr por separado.
-- =====================================================================

-- 1) Partidas de OC recibidas de más: cada documento de recepción vivo
--    con su póliza, sus lotes y si todavía se puede cancelar (nada consumido).
--    Los que sobran se cancelan en Documentos -> "Cancelar recibo" (deja
--    póliza de reverso + movimiento 'cancelacion_recibo' en el kardex).
with recibido as (
    select d.orden_compra_id, dd.producto_id, sum(dd.cantidad) as recibido
      from public.documento_detalles dd
      join public.documentos d on d.id = dd.documento_id
     where d.orden_compra_id is not null
       and d.tipo_movimiento in ('entrada_compra', 'entrada')
       and coalesce(d.estado, '') <> 'cancelado'
     group by d.orden_compra_id, dd.producto_id
), pedido as (
    select orden_compra_id, producto_id, sum(cantidad) as pedido, sum(cantidad_recibida) as recibido_en_oc
      from public.ordenes_compra_detalle
     where producto_id is not null
     group by orden_compra_id, producto_id
)
select oc.folio                           as orden,
       p.nombre                           as producto,
       pe.pedido,
       r.recibido                         as recibido_segun_documentos,
       pe.recibido_en_oc                  as recibido_segun_oc,
       d.id                               as documento_id,
       d.fecha_emision::date              as fecha,
       d.poliza_id,
       (select string_agg(distinct l.numero_lote, ', ')
          from public.movimientos_inventario mi
          left join public.lotes_inventario l on l.id = mi.lote_id
         where mi.documento_id = d.id and mi.producto_id = p.id) as lotes,
       (select bool_and(x.ok) from public.recibo_reversible(d.id) x) as se_puede_cancelar
  from recibido r
  join pedido pe on pe.orden_compra_id = r.orden_compra_id and pe.producto_id = r.producto_id
  join public.ordenes_compra oc on oc.id = r.orden_compra_id
  join public.productos p on p.id = r.producto_id
  join public.documentos d on d.orden_compra_id = r.orden_compra_id
                          and d.tipo_movimiento in ('entrada_compra', 'entrada')
                          and coalesce(d.estado, '') <> 'cancelado'
                          and exists (select 1 from public.documento_detalles dd
                                       where dd.documento_id = d.id and dd.producto_id = r.producto_id)
 where r.recibido > pe.pedido + 0.01   -- tolera el redondeo a 2 decimales de documento_detalles
    or abs(r.recibido - coalesce(pe.recibido_en_oc, 0)) > 0.01
 order by oc.folio, p.nombre, d.id;

-- 2) Pólizas canceladas y su reverso (contra-asiento). Ambas cuentan para
--    saldo; "sin reverso" = cancelada que NO cuenta (no debería haber).
select o.id as poliza_original, o.tipo || ' #' || o.numero as original, o.fecha, o.concepto,
       r.id as poliza_reverso, r.tipo || ' #' || r.numero as reverso, r.fecha as fecha_reverso,
       case when r.id is null then 'SIN REVERSO' else 'ok' end as estado
  from public.polizas o
  left join public.polizas r on r.origen_tabla = 'polizas' and r.origen_id = o.id and r.estatus = 'contabilizada'
 where o.estatus = 'cancelada'
 order by o.fecha, o.id;

-- 3) Cuadre por cuenta de inventario a hoy (diferencia debe ser 0).
select * from public.cuadre_inventario_contable(current_date) order by codigo;
