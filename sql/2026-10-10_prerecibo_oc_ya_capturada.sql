-- =====================================================================
--  Pre-recibo operador: no ofrecer una OC que ya tiene pre-recibo activo
--  Fecha: 2026-10-10  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-11_prerecibo_operador.sql
--
--  recibo-operador.html llenaba el selector de "Orden de compra" desde
--  v_recibo_ocs, que solo miraba el estatus de la OC (abierta /
--  recibida_parcial) — sin importar si esa OC YA tenía un pre-recibo
--  capturado. Un operador podía volver a "completar" (enviar otro
--  pre-recibo) sobre una orden que él mismo, u otro operador, ya había
--  llenado y que sigue pendiente de revisar o ya fue validada.
--
--  Ahora v_recibo_ocs excluye toda OC con un pre-recibo 'pendiente' o
--  'validado' vigente. Solo reaparece en el selector del operador si ese
--  pre-recibo se rechaza (hay que recontar) o se cancela (el admin lo
--  anuló). Correcciones o pre-recibos adicionales sobre una OC ya
--  capturada son trabajo exclusivo del admin, desde su panel (Ver /
--  Editar / Cancelar / "Nuevo pre-recibo (admin)" en Recibo de
--  mercancía) — no del operador.
--
--  Idempotente.
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
             where d.orden_compra_id = oc.id) as partidas
      from public.ordenes_compra oc
      left join public.proveedores pr on pr.id = oc.proveedor_id
     where oc.estatus in ('abierta', 'recibida_parcial')
       and not exists (
           select 1 from public.pre_recibos p
            where p.orden_compra_id = oc.id
              and p.estatus in ('pendiente', 'validado')
       );

grant select on public.v_recibo_ocs to anon, authenticated;

commit;
