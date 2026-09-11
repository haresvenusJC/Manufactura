-- =====================================================================
--  Cuentas por pagar: ya no oculta canceladas por accidente, ahora trae
--  estatus (pendiente / pagado / cancelado) para poder FILTRAR en la
--  pantalla, en vez de ver siempre solo lo pendiente.
--  Fecha: 2026-09-10  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Bug que corrige: sql/2026-09-02_pagos_proveedor.sql creó
--  v_cuentas_por_pagar filtrando por tipo_movimiento/condicion/poliza_id
--  y saldo > 0, pero SIN excluir documentos.estado = 'cancelado'.
--  Cancelar un recibo (sql/2026-09-21_reversa_inventario_recibo.sql) no
--  toca total/total_pagado, así que el documento cancelado se seguía
--  viendo "por pagar" para siempre — si además recapturaste el recibo,
--  se veía el mismo saldo dos (o más) veces.
--
--  En vez de solo excluir las canceladas, se agrega poliza_id (para el
--  enlace "Ver póliza") y estatus_cxp = pendiente / pagado / cancelado,
--  y la pantalla trae un filtro para elegir cuál ver.
--
--  Idempotente (CREATE OR REPLACE VIEW).
-- =====================================================================

begin;

create or replace view public.v_cuentas_por_pagar as
    select 'compra'::text as tipo, d.id, d.folio,
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
           end as estatus_cxp
      from public.documentos d
      left join public.proveedores p on p.id = d.proveedor_id
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
           end
      from public.gastos g
      left join public.proveedores p on p.id = g.proveedor_id
     where g.condicion = 'credito';

grant select on public.v_cuentas_por_pagar to authenticated;

commit;

-- =====================================================================
-- select tipo, estatus_cxp, count(*) from v_cuentas_por_pagar group by 1,2;
-- =====================================================================
