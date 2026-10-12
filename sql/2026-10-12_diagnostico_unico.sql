-- =====================================================================
--  Diagnóstico ÚNICO (SOLO LECTURA) — AJU-000001 (Diario #33), Egreso #38,
--  #67 y #69 (+ cualquier póliza que mencione F-2407).
--  Fecha: 2026-10-12  ·  Proyecto: Hares de México (Supabase)
--
--  No modifica nada: es un solo SELECT. Pégalo completo en Supabase ->
--  SQL Editor, dale Run, abre la celda "diagnostico" (clic en ella, icono de
--  copiar) y pega el texto completo en el chat.
--  Reemplaza al de 2026-10-07 (que eran 6 bloques y el editor solo muestra el
--  último). Usa to_jsonb(fila) en las tablas cuyas columnas no están
--  verificadas, para no fallar si alguna se llama distinto.
-- =====================================================================
with pol as (
    select * from public.polizas
     where (tipo = 'Diario' and numero = 33)
        or (tipo = 'Egreso' and numero in (38, 67, 69))
        or concepto ilike '%F-2407%'
),
docs33 as (
    select d.* from public.documentos d join pol on pol.id = d.poliza_id
     where pol.tipo = 'Diario' and pol.numero = 33
),
prods33 as (
    select distinct mi.producto_id from public.movimientos_inventario mi join docs33 d on d.id = mi.documento_id
),
pagos as (
    select pp.* from public.pagos_proveedor pp join pol on pol.id = pp.poliza_id
)
select jsonb_pretty(jsonb_build_object(
  '1_polizas', (select coalesce(jsonb_agg(to_jsonb(p) order by p.id), '[]') from pol p),

  '2_movimientos_de_esas_polizas', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'poliza', p.tipo || ' #' || p.numero, 'estatus', p.estatus,
               'cuenta', cc.codigo || ' ' || cc.nombre, 'concepto', m.concepto,
               'cargo', m.cargo, 'abono', m.abono, 'proveedor_id', m.proveedor_id)
             order by p.id, m.id), '[]')
        from public.poliza_movimientos m
        join pol p on p.id = m.poliza_id
        join public.cuentas_contables cc on cc.id = m.cuenta_id),

  '3_cuadre_por_poliza', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'poliza', p.tipo || ' #' || p.numero, 'estatus', p.estatus,
               'cargos', s.cargos, 'abonos', s.abonos, 'diferencia', s.cargos - s.abonos)
             order by p.id), '[]')
        from pol p
        join lateral (select coalesce(sum(cargo), 0) as cargos, coalesce(sum(abono), 0) as abonos
                        from public.poliza_movimientos where poliza_id = p.id) s on true),

  '4_documento_y_movimientos_de_inventario_de_AJU', jsonb_build_object(
      'documentos', (select coalesce(jsonb_agg(to_jsonb(d)), '[]') from docs33 d),
      'movimientos', (select coalesce(jsonb_agg(to_jsonb(mi) order by mi.id), '[]')
                        from public.movimientos_inventario mi join docs33 d on d.id = mi.documento_id)),

  '5_movimientos_posteriores_de_esos_productos', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'id', mi.id, 'producto_id', mi.producto_id, 'producto', pr.nombre,
               'tipo_movimiento', mi.tipo_movimiento, 'cantidad', mi.cantidad, 'documento_id', mi.documento_id)
             order by mi.producto_id, mi.id), '[]')
        from public.movimientos_inventario mi
        join public.productos pr on pr.id = mi.producto_id
       where mi.producto_id in (select producto_id from prods33)
         and mi.id > coalesce((select min(mi3.id) from public.movimientos_inventario mi3 join docs33 d3 on d3.id = mi3.documento_id), 0)),

  '6_bitacora_de_las_polizas', (
      select coalesce(jsonb_agg(to_jsonb(b)), '[]')
        from public.bitacora_cambios b
       where to_jsonb(b)->>'tabla' = 'polizas'
         and (to_jsonb(b)->>'registro_id') in (select id::text from pol)),

  '7_pagos_proveedor_ligados', (select coalesce(jsonb_agg(to_jsonb(pg) order by pg.id), '[]') from pagos pg),

  '8_aplicaciones_de_esos_pagos', (
      select coalesce(jsonb_agg(to_jsonb(a) order by a.id), '[]')
        from public.pagos_proveedor_aplicaciones a join pagos pg on pg.id = a.pago_id),

  '9_OC_000001_y_OC_000002', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'folio', oc.folio, 'estatus', oc.estatus, 'moneda_id', oc.moneda_id, 'tipo_cambio', oc.tipo_cambio,
               'total_estimado', (select sum(d.cantidad * d.costo_unitario_estimado) from public.ordenes_compra_detalle d where d.orden_compra_id = oc.id),
               'documentos', (select coalesce(jsonb_agg(jsonb_build_object('id', dc.id, 'folio', dc.folio, 'tipo', dc.tipo_movimiento,
                                'estado', dc.estado, 'total', dc.total, 'total_pagado', dc.total_pagado, 'poliza_id', dc.poliza_id)), '[]')
                                from public.documentos dc where dc.orden_compra_id = oc.id))), '[]')
        from public.ordenes_compra oc where oc.folio in ('OC-000001', 'OC-000002')),

  '10_todo_lo_que_toca_la_cuenta_102_02', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'poliza', p.tipo || ' #' || p.numero, 'fecha', p.fecha, 'estatus', p.estatus, 'concepto', p.concepto,
               'cargo', m.cargo, 'abono', m.abono) order by p.id), '[]')
        from public.poliza_movimientos m
        join public.polizas p on p.id = m.poliza_id
        join public.cuentas_contables cc on cc.id = m.cuenta_id
       where cc.codigo = '102.02')
)) as diagnostico;
