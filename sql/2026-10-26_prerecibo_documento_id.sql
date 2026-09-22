-- =====================================================================
--  Pre-recibo: no desaparece de "Por validar" hasta que se reciba de verdad
--  Fecha: 2026-10-26  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-11_prerecibo_operador.sql,
--            sql/2026-10-09_prerecibo_candado_editar_cancelar.sql
--
--  Pedido: al pulsar "✔ Validar y recibir" en un pre-recibo, la base YA
--  exige marcarlo 'validado' antes de dejar registrar el recibo de
--  mercancía (candado de sql/2026-10-09, sin cambios aquí). El problema es
--  otro: en cuanto queda 'validado', la pantalla "Pre-recibos por validar"
--  dejaba de mostrarlo (solo listaba 'pendiente') — si el admin abría la
--  recepción y no la terminaba (cerraba la pestaña, se distraía), ese
--  pre-recibo quedaba validado, la mercancía NUNCA entraba al inventario,
--  y no había manera de notar que faltaba terminar.
--
--  Qué agrega:
--   1. pre_recibos.documento_id: se anota con el id del documento de
--      "entrada_compra" (Recibo de mercancía) SOLO cuando esa recepción se
--      completa de verdad (js/ordenes-compra.js, rmConfirmar()).
--   2. "Pre-recibos por validar" ahora incluye 'pendiente' Y 'validado' sin
--      documento_id — un pre-recibo ya validado sigue apareciendo ahí,
--      con el botón "📦 Continuar recepción", hasta que documento_id se
--      llene. Una vez recibido, solo queda en el Historial.
--
--  No toca el candado ni las reglas de validar/rechazar/cancelar.
--  Idempotente.
-- =====================================================================
begin;

alter table public.pre_recibos
    add column if not exists documento_id bigint references public.documentos(id);

comment on column public.pre_recibos.documento_id is
    'Documento de entrada_compra que completó la recepción real de este pre-recibo. NULL = aunque ya esté validado, la mercancía todavía no entra al inventario — sigue en "Por validar".';

create index if not exists pre_recibos_documento_idx on public.pre_recibos (documento_id);

commit;

-- Para revisar: pre-recibos validados que llevan tiempo sin recibirse de verdad.
--   select id, orden_compra_id, empleado_nombre, validado_en
--     from public.pre_recibos
--    where estatus = 'validado' and documento_id is null
--    order by validado_en;
