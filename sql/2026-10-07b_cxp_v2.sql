-- =====================================================================
--  Cuentas por pagar v2 — Días de crédito en la OC + Vence calculado +
--  el documento de la lista es siempre la OC, nunca el folio de recepción.
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Contexto (conversación con el usuario, 2026-10-07, maqueta
--  https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi): la pantalla de
--  Pagos a proveedores mostraba el folio del RECIBO de mercancía
--  (REC-...) como documento a pagar — el usuario pidió que sea siempre
--  el folio de la OC autorizada. También se agrega "Días de crédito"
--  como campo obligatorio de la OC (Inmediato/7/15/30/60), de donde sale
--  "Vence" = fecha de la OC + esos días. Las OC ya existentes quedan en
--  0 (Inmediato) — mismo comportamiento que tenían antes (vencía el
--  mismo día de la OC).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Días de crédito en la OC (obligatorio para capturas nuevas; las
--    existentes quedan en 0 = Inmediato, sin cambiar su comportamiento).
-- ---------------------------------------------------------------------
alter table public.ordenes_compra add column if not exists dias_credito integer;
update public.ordenes_compra set dias_credito = 0 where dias_credito is null;
alter table public.ordenes_compra alter column dias_credito set default 0;
alter table public.ordenes_compra alter column dias_credito set not null;

do $$
begin
    if not exists (
        select 1 from pg_constraint
         where conname = 'ordenes_compra_dias_credito_chk'
    ) then
        alter table public.ordenes_compra
            add constraint ordenes_compra_dias_credito_chk check (dias_credito in (0, 7, 15, 30, 60));
    end if;
end $$;

comment on column public.ordenes_compra.dias_credito is
  'Días de crédito pactados con el proveedor para esta OC (0 = Inmediato). Vence = fecha de la OC + estos días.';

-- ---------------------------------------------------------------------
-- 2. v_cuentas_por_pagar: el documento de cada fila es la OC autorizada
--    (nunca el folio de recepción), y se agrega "vence" calculado desde
--    la OC. Mismas columnas de siempre + "vence" al final.
--    DROP + CREATE (no "or replace"): el coalesce(oc.folio, d.folio)
--    cambia el tipo de la columna "folio" de varchar a text, y Postgres
--    no deja cambiar el tipo de una columna con "create or replace view".
--    Nada más depende de esta vista (verificado: solo la consume JS).
-- ---------------------------------------------------------------------
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
           (oc.fecha + coalesce(oc.dias_credito, 0))::date as vence
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

-- =====================================================================
-- select tipo, estatus_cxp, count(*) from v_cuentas_por_pagar group by 1,2;
-- select folio, vence from v_cuentas_por_pagar where tipo = 'compra' limit 10;
-- =====================================================================
