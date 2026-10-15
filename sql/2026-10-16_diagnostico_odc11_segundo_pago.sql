-- Solo lectura. Por qué ODC-000011 (recibida, anticipo $98.60, falta $394.40) no ofrece "Pagar".
select 'orden' as q, oc.id, oc.folio, oc.estatus, oc.condicion_pago, oc.anticipo_monto
  from ordenes_compra oc where oc.folio = 'ODC-000011';
select 'documento' as q, d.id, d.folio, d.tipo_movimiento, d.condicion, d.estado, d.total, d.total_pagado,
       d.poliza_id, d.orden_compra_id
  from documentos d where d.orden_compra_id = (select id from ordenes_compra where folio = 'ODC-000011');
select 'vista' as q, v.* from v_cuentas_por_pagar v where v.orden_compra_id = (select id from ordenes_compra where folio = 'ODC-000011');
select 'aplicaciones' as q, a.* from pagos_proveedor_aplicaciones a
 where a.orden_compra_id = (select id from ordenes_compra where folio = 'ODC-000011')
    or a.documento_id in (select id from documentos where orden_compra_id = (select id from ordenes_compra where folio = 'ODC-000011'));
