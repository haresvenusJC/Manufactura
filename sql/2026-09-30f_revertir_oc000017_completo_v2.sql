-- =====================================================================
--  Reversa COMPLETA de OC-000017 (ambiente de pruebas): TODO pago ligado
--  a la orden (anticipo y/o pago directo de la compra), el recibo, el
--  pre-recibo y la orden de compra misma.
--  Fecha: 2026-09-30 (v2)  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere sql/2026-10-09_prerecibo_candado_editar_cancelar.sql (agrega
--  el estatus 'cancelado' a pre_recibos) — ya deberia estar corrida.
--
--  REEMPLAZA a sql/2026-09-30d_cancelar_oc000017_prueba.sql Y a
--  sql/2026-09-30e_revertir_oc000017_completo.sql — NO corras esos dos,
--  este los deja sin efecto.
--
--  Por que un v2: 30e identificaba el "pago" por numero de poliza fijo
--  (Egreso #59) — se verifico en Supabase que la Egreso #59 actual NO
--  tiene nada que ver con OC-000017 (es un pago bancario distinto, ya
--  cancelado por su cuenta; el consecutivo de polizas avanzo entre
--  sesiones). Este script ya no asume ningun numero: localiza TODOS los
--  pagos ligados a la orden por relacion real (pagos_proveedor_
--  aplicaciones.orden_compra_id / documento_id), no por numero de folio.
--
--  Tambien corrige el ORDEN: cancelar_pago_proveedor() rechaza cancelar
--  un anticipo que siga "aplicado" a una recepcion viva (candado de
--  integridad, sql/2026-10-27_anticipo_proveedores.sql) — por eso el
--  RECIBO se cancela ANTES que el anticipo (al cancelar el recibo se
--  libera el anticipo aplicado), igual que se hizo con el documento #49
--  en sql/2026-09-30c_cancelar_pruebas_anticipo_y_entradas.sql. 30e
--  traia el orden al reves (pago antes que recibo).
--
--  Orden real (cada paso aislado con EXCEPTION; si uno falla, los demas
--  se intentan igual y el motivo queda en el aviso):
--    1) Pago(s) DIRECTOS de la compra (tipo='compra') ligados al
--       documento del Recibo #15 — sin candado, se pueden cancelar ya.
--    2) Recibo #15 (documento) — revierte inventario + su propia poliza
--       de compra, y libera cualquier anticipo que tuviera "aplicado".
--    3) Anticipo(s) (tipo='anticipo_oc') ligados a la ORDEN DE COMPRA —
--       ya sin candado tras el paso 2.
--    4) Pre-recibo(s) de esa OC que sigan vivos.
--    5) La Orden de Compra misma — SIEMPRE AL FINAL (si se pusiera antes
--       del paso 2, el recalculo automatico de estatus del paso 2 la
--       regresaria a 'abierta', pisando esto).
-- =====================================================================

begin;

do $$
declare
    v_oc_id     bigint;
    v_doc_r15   bigint;
    v_pr        record;
    v_pg        record;
    v_res       jsonb;
begin
    select id into v_oc_id from public.ordenes_compra where folio = 'OC-000017';
    if v_oc_id is null then
        raise notice 'No se encontro la OC-000017 - nada que hacer.';
        return;
    end if;

    select d.id into v_doc_r15
      from public.documentos d
     where d.folio = 'OC-000017'
       and d.tipo_movimiento in ('entrada_compra', 'entrada')
       and coalesce(d.estado, '') <> 'cancelado'
       and d.total = 9744.74
     order by d.id
     limit 1;

    raise notice 'Localizado -> OC id=% | Recibo #15 doc=%', v_oc_id, v_doc_r15;

    -- 1) Pago(s) directos de la compra (tipo='compra') ligados al Recibo #15
    if v_doc_r15 is not null then
        for v_pg in
            select distinct pp.id
              from public.pagos_proveedor_aplicaciones a
              join public.pagos_proveedor pp on pp.id = a.pago_id
             where a.tipo = 'compra' and a.documento_id = v_doc_r15 and pp.estatus = 'registrado'
        loop
            begin
                perform public.cancelar_pago_proveedor(v_pg.id);
                raise notice 'Pago directo de la compra (pago %) cancelado.', v_pg.id;
            exception when others then
                raise notice 'Pago directo (pago %): NO se pudo cancelar - %', v_pg.id, sqlerrm;
            end;
        end loop;
    end if;

    -- 2) Recibo #15 (documento) -- libera cualquier anticipo "aplicado"
    if v_doc_r15 is not null then
        begin
            v_res := public.cancelar_recibo_inventario(v_doc_r15, 'Prueba de funcionamiento - se revierte para repetir la prueba');
            raise notice 'Recibo #15 (documento %) cancelado: %', v_doc_r15, v_res->>'mensaje';
        exception when others then
            raise notice 'Recibo #15: NO se pudo cancelar - %', sqlerrm;
        end;
    else
        raise notice 'No se encontro el documento del Recibo #15 (folio OC-000017, $9,744.74) - se omite.';
    end if;

    -- 3) Anticipo(s) ligados a la ORDEN DE COMPRA -- ya sin candado tras el paso 2
    for v_pg in
        select distinct pp.id
          from public.pagos_proveedor_aplicaciones a
          join public.pagos_proveedor pp on pp.id = a.pago_id
         where a.tipo = 'anticipo_oc' and a.orden_compra_id = v_oc_id and pp.estatus = 'registrado'
    loop
        begin
            perform public.cancelar_pago_proveedor(v_pg.id);
            raise notice 'Anticipo (pago %) cancelado.', v_pg.id;
        exception when others then
            raise notice 'Anticipo (pago %): NO se pudo cancelar - %', v_pg.id, sqlerrm;
        end;
    end loop;

    -- 4) Pre-recibo(s) de esta OC que sigan vivos
    for v_pr in
        select id from public.pre_recibos
         where orden_compra_id = v_oc_id
           and estatus not in ('cancelado', 'rechazado')
    loop
        begin
            perform public.prerecibo_validar(v_pr.id, 'cancelar', 'Prueba de funcionamiento - se revierte para repetir la prueba');
            raise notice 'Pre-recibo % cancelado.', v_pr.id;
        exception when others then
            raise notice 'Pre-recibo %: NO se pudo cancelar - %', v_pr.id, sqlerrm;
        end;
    end loop;

    -- 5) La Orden de Compra misma -- AL FINAL
    update public.ordenes_compra
       set estatus = 'cancelada',
           notas = trim(both ' · ' from coalesce(notas || ' · ', '')
               || 'Cancelada 2026-09-30 (ambiente de pruebas): se revirtio completa -- pago(s), '
               || 'recibo y pre-recibo -- para repetir la prueba con el codigo ya corregido.')
     where id = v_oc_id;
    raise notice 'OC-000017 marcada cancelada.';
end $$;

commit;


-- =====================================================================
-- Verificación (opcional):
-- select folio, estatus from public.ordenes_compra where folio = 'OC-000017';  -- debe quedar 'cancelada'
--
-- select d.id, d.estado from public.documentos where folio = 'OC-000017';  -- 'cancelado'
--
-- select id, estatus, documento_id from public.pre_recibos
--  where orden_compra_id = (select id from public.ordenes_compra where folio = 'OC-000017');
--
-- select pp.id, pp.estatus from public.pagos_proveedor pp
--  join public.pagos_proveedor_aplicaciones a on a.pago_id = pp.id
--  where (a.tipo = 'anticipo_oc' and a.orden_compra_id = (select id from public.ordenes_compra where folio = 'OC-000017'))
--     or (a.tipo = 'compra' and a.documento_id in (select id from public.documentos where folio = 'OC-000017'));
--
-- select d.cantidad, d.cantidad_recibida from public.ordenes_compra_detalle d
--  where d.orden_compra_id = (select id from public.ordenes_compra where folio = 'OC-000017');  -- recibida en 0
-- =====================================================================
