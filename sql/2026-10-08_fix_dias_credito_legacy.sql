-- =====================================================================
--  Corrige: las OC existentes (antes de "Días de crédito") quedaron en 0
--  por el backfill de ayer, y 0 = Inmediato = Vence el mismo día de la OC
--  -> TODAS salían "Vencida" de golpe (septiembre < hoy), aunque antes de
--  este campo no había ningún concepto de "vencida" para ellas.
--  Fecha: 2026-10-08  ·  Proyecto: Hares de México (Supabase)
--
--  Corrección: dias_credito vuelve a ser NULLABLE; las OC que tenían el
--  valor puesto por el backfill (0) regresan a NULL = "sin días de crédito
--  capturados" (Vence sale en blanco, nunca "Vencida"). El formulario
--  sigue exigiendo elegir un valor para las OC NUEVAS (eso es validación
--  de pantalla, no de la base) — las nuevas nunca se insertan en NULL.
--
--  OJO: esto solo es seguro correrlo HOY, antes de que exista una OC real
--  capturada con "Inmediato" (0) a propósito — de lo contrario también se
--  le borraría. Si ya pasó un día capturando OC reales, avisar antes de
--  correr este archivo.
--
--  Idempotente.
-- =====================================================================
begin;

alter table public.ordenes_compra alter column dias_credito drop not null;
alter table public.ordenes_compra alter column dias_credito drop default;

update public.ordenes_compra set dias_credito = null where dias_credito = 0;

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
           case when oc.dias_credito is not null then (oc.fecha + oc.dias_credito)::date else null end as vence
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
