-- =====================================================================
--  Cuentas por pagar: "Vence" correcto
--  Fecha: 2026-10-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Hallazgo (ODC-000010, contado): Vence salía igual a la fecha de la ODC
--  (dias_credito = 0) aunque la entrega esperada era una semana después.
--  Ahora: contado = sin vencimiento ("—"); crédito = fecha de la factura /
--  recepción + días de crédito de la ODC. Misma vista de 2026-10-08, solo
--  cambia la columna "vence". DROP + CREATE (mismas columnas y orden).
-- =====================================================================
begin;

drop view if exists public.v_cuentas_por_pagar;
create view public.v_cuentas_por_pagar as
    select 'compra'::text as tipo, d.id, coalesce(oc.folio, d.folio) as folio,
           d.fecha_emision::date as fecha,
           d.proveedor_id, p.nombre as proveedor_nombre,
           coalesce(d.total, 0) as total,
           coalesce(d.total_pagado, 0) as pagado,
           round(coalesce(d.total, 0) - coalesce(d.total_pagado, 0), 2) as saldo,
           d.orden_compra_id,
           d.poliza_id,
           case
               when coalesce(d.estado, '') = 'cancelado' then 'cancelado'
               when round(coalesce(d.total, 0) - coalesce(d.total_pagado, 0), 2) <= 0.005 then 'pagado'
               else 'pendiente'
           end as estatus_cxp,
           -- Contado: no hay vencimiento. Crédito: fecha de la factura/recepción + días de crédito pactados
           -- (antes se contaba desde la fecha de la ODC y una orden de contado salía "vence hoy").
           case when coalesce(oc.condicion_pago, '') = 'credito' and oc.dias_credito is not null
                then (d.fecha_emision::date + oc.dias_credito)::date else null end as vence
      from public.documentos d
      left join public.proveedores p on p.id = d.proveedor_id
      left join public.ordenes_compra oc on oc.id = d.orden_compra_id
     where d.tipo_movimiento = 'entrada_compra'
       and coalesce(d.condicion, '') = 'credito'
       and d.poliza_id is not null
    union all
    select 'gasto'::text, g.id, g.folio_factura,
           g.fecha,
           g.proveedor_id, p.nombre,
           coalesce(g.total, 0),
           coalesce(g.total_pagado, 0),
           round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2),
           null::bigint,
           g.poliza_id,
           case
               when g.estatus = 'cancelado' then 'cancelado'
               when round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2) <= 0.005 then 'pagado'
               else 'pendiente'
           end,
           null::date
      from public.gastos g
      left join public.proveedores p on p.id = g.proveedor_id
     where g.condicion = 'credito';

grant select on public.v_cuentas_por_pagar to authenticated;

commit;
