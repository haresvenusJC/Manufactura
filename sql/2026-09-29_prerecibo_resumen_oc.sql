-- =====================================================================
--  Pre-recibo (operador): tarjeta-resumen al elegir la orden de compra
--  (Proveedor / Fecha / Partidas y unidades / Total estimado).
--  Fecha: 2026-09-29  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  v_recibo_ocs (sql/2026-09-11_prerecibo_operador.sql) NO traía ningún
--  monto a propósito ("NO se muestran costos" al operador anónimo). El
--  usuario pidió agregar el total al elegir la OC — se expone como
--  "estimado" (viene de ordenes_compra_detalle.costo_unitario_estimado,
--  no del costo real PEPS) y solo el TOTAL de la orden completa, nunca el
--  costo unitario por partida (v_recibo_oc_lineas sigue sin tocarse).
--
--  Idempotente (create or replace view, agrega columnas al final).
-- =====================================================================

begin;

create or replace view public.v_recibo_ocs as
    select oc.id,
           oc.folio,
           oc.fecha,
           oc.fecha_esperada,
           oc.estatus,
           pr.nombre as proveedor_nombre,
           (select count(*) from public.ordenes_compra_detalle d
             where d.orden_compra_id = oc.id) as partidas,
           (select coalesce(sum(d.cantidad), 0) from public.ordenes_compra_detalle d
             where d.orden_compra_id = oc.id) as unidades_totales,
           (select coalesce(sum(d.cantidad * d.costo_unitario_estimado), 0) from public.ordenes_compra_detalle d
             where d.orden_compra_id = oc.id) as total_estimado
      from public.ordenes_compra oc
      left join public.proveedores pr on pr.id = oc.proveedor_id
     where oc.estatus in ('abierta', 'recibida_parcial');

grant select on public.v_recibo_ocs to anon, authenticated;

commit;
