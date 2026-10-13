-- =====================================================================
--  Diagnóstico (SOLO LECTURA) — AJU-000001, Egreso #67, Egreso #69
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  No modifica nada. Pégalo completo en Supabase -> SQL Editor y corre
--  cada bloque (o todo junto) para ver los resultados. Es el paso antes
--  de decidir si se cancela/archiva cada uno — sobre todo AJU-000001,
--  que no tiene un botón de "deshacer" en pantalla (las salidas de
--  ajuste de inventario no tienen función de cancelación propia; solo
--  las recepciones de compra, devoluciones y pólizas sí la tienen).
--
--  Qué busca cada bloque:
--   1. La póliza Diario #33 (AJU-000001) completa: cuentas, cargo/abono,
--      y el documento/movimientos de inventario que la originaron.
--   2. Quién y cuándo la creó (bitácora), para saber si fue una prueba.
--   3. Si algo de lo que esa salida movió ya se consumió después (en
--      producción u otra salida) — si sí, cancelarla a mano es más
--      delicado (el stock ya no está igual).
--   4. Egreso #69 (pago de OC-000001) completo, con su cuenta de banco.
--   5. Egreso #67 y Egreso #38, los dos "Pago compra F-2407" — para ver
--      si de verdad son dos pagos de lo mismo o cosas distintas.
--   6. Estatus de OC-000001 y OC-000002 (si su recepción ya se consumió,
--      cancelar_recibo_inventario la va a bloquear — es el candado de
--      integridad, a propósito, no un error).
-- =====================================================================

-- 1) Póliza Diario #33 (AJU-000001): cabecera + cada cuenta/cargo/abono
select p.id as poliza_id, p.tipo, p.numero, p.fecha, p.concepto, p.estatus, p.origen, p.origen_tabla, p.origen_id, p.created_at
  from public.polizas p
 where p.tipo = 'Diario' and p.numero = 33;

select m.poliza_id, cc.codigo, cc.nombre, m.concepto, m.cargo, m.abono, m.proveedor_id
  from public.poliza_movimientos m
  join public.cuentas_contables cc on cc.id = m.cuenta_id
  join public.polizas p on p.id = m.poliza_id
 where p.tipo = 'Diario' and p.numero = 33
 order by m.id;

-- El documento de la salida AJU-000001 (si polizas.origen_tabla lo liga) + sus movimientos de inventario
select d.id as documento_id, d.tipo_movimiento, d.folio, d.fecha_emision, d.descripcion, d.estado
  from public.documentos d
  join public.polizas p on p.id = d.poliza_id
 where p.tipo = 'Diario' and p.numero = 33;

select mi.*
  from public.movimientos_inventario mi
  join public.documentos d on d.id = mi.documento_id
  join public.polizas p on p.id = d.poliza_id
 where p.tipo = 'Diario' and p.numero = 33
 order by mi.id;

-- 2) Quién y cuándo — bitácora de esa póliza y de la salida de inventario alrededor de esa hora
select b.*
  from public.bitacora_cambios b
 where (b.tabla = 'polizas' and b.registro_id in (select id from public.polizas where tipo = 'Diario' and numero = 33))
    or (b.tabla ilike '%movimientos_inventario%' and b.creado_at::date = '2026-10-06')
 order by b.creado_at;

-- 3) ¿Algo de lo que movió AJU-000001 ya se consumió después? (por producto, movimientos
--    posteriores a esa salida — se compara por id, que es monotónico, sin asumir el nombre
--    exacto de la columna de fecha de movimientos_inventario)
select mi.id, mi.producto_id, p.nombre, mi.tipo_movimiento, mi.cantidad, mi.documento_id
  from public.movimientos_inventario mi
  join public.productos p on p.id = mi.producto_id
 where mi.producto_id in (
         select mi2.producto_id
           from public.movimientos_inventario mi2
           join public.documentos d2 on d2.id = mi2.documento_id
           join public.polizas p2 on p2.id = d2.poliza_id
          where p2.tipo = 'Diario' and p2.numero = 33
       )
   and mi.id > (
         select min(mi3.id)
           from public.movimientos_inventario mi3
           join public.documentos d3 on d3.id = mi3.documento_id
           join public.polizas p3 on p3.id = d3.poliza_id
          where p3.tipo = 'Diario' and p3.numero = 33
       )
 order by mi.producto_id, mi.id;

-- 4) Egreso #69 (pago de OC-000001) completo
select p.id as poliza_id, p.tipo, p.numero, p.fecha, p.concepto, p.estatus, p.origen, p.origen_tabla, p.origen_id
  from public.polizas p
 where p.tipo = 'Egreso' and p.numero = 69;

select m.poliza_id, cc.codigo, cc.nombre, m.concepto, m.cargo, m.abono, m.proveedor_id
  from public.poliza_movimientos m
  join public.cuentas_contables cc on cc.id = m.cuenta_id
  join public.polizas p on p.id = m.poliza_id
 where p.tipo = 'Egreso' and p.numero = 69
 order by m.id;

select oc.id, oc.folio, oc.proveedor_id, oc.moneda_id, oc.tipo_cambio, oc.estatus,
       (select sum(d.cantidad * d.costo_unitario_estimado) from public.ordenes_compra_detalle d where d.orden_compra_id = oc.id) as total_estimado
  from public.ordenes_compra oc where oc.folio = 'OC-000001';

-- 5) Egreso #67 y Egreso #38 — ambos "Pago compra F-2407": ¿son lo mismo pagado dos veces?
select p.id as poliza_id, p.tipo, p.numero, p.fecha, p.concepto, p.estatus, p.origen, p.origen_tabla, p.origen_id
  from public.polizas p
 where p.tipo = 'Egreso' and p.numero in (38, 67);

select m.poliza_id, cc.codigo, cc.nombre, m.concepto, m.cargo, m.abono, m.proveedor_id
  from public.poliza_movimientos m
  join public.cuentas_contables cc on cc.id = m.cuenta_id
  join public.polizas p on p.id = m.poliza_id
 where p.tipo = 'Egreso' and p.numero in (38, 67)
 order by p.numero, m.id;

-- pagos_proveedor ligados a esas dos pólizas (si el pago pasó por ese módulo)
select pp.id as pago_id, pp.fecha, pp.total, pp.cuenta_pago_id, pp.forma_pago, pp.referencia, pp.estatus, pp.poliza_id, pp.notas
  from public.pagos_proveedor pp
  join public.polizas p on p.id = pp.poliza_id
 where p.tipo = 'Egreso' and p.numero in (38, 67);

-- aplicaciones de esos pagos (a qué documento/OC se aplicaron)
select a.*
  from public.pagos_proveedor_aplicaciones a
  join public.pagos_proveedor pp on pp.id = a.pago_id
  join public.polizas p on p.id = pp.poliza_id
 where p.tipo = 'Egreso' and p.numero in (38, 67);

-- 6) ¿Se puede revertir la recepción de OC-000001 / OC-000002 sin bloqueo? (candado de integridad)
select d.id as documento_id, d.folio, d.tipo_movimiento, d.estado, d.orden_compra_id, rr.*
  from public.documentos d
  join public.ordenes_compra oc on oc.id = d.orden_compra_id
  join lateral public.recibo_reversible(d.id) rr on true
 where oc.folio in ('OC-000001', 'OC-000002') and d.tipo_movimiento = 'entrada_compra'
 order by d.id;
