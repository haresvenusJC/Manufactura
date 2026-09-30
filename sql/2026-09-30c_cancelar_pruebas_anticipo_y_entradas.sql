-- =====================================================================
--  Cancela las pruebas de funcionamiento del 2026-09-30 (confirmado por
--  el usuario): los 2 anticipos duplicados de OC-000017 y las 2 entradas
--  directas de prueba.
--  Fecha: 2026-09-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Orden obligatorio (no se puede cambiar): el anticipo Egreso #57 ya
--  tiene $0.14 "aplicado" contra la recepción de prueba de OC-000017
--  (documento #49, los residuos de gramos) — cancelar_pago_proveedor()
--  rechaza cancelar un anticipo con algo aplicado ("cancela primero esa
--  recepción"). Por eso primero se cancela el documento #49 (libera el
--  anticipo) y DESPUÉS los dos anticipos.
--
--  Qué hace cada cancelación (todas via las funciones ya existentes,
--  "Cancelar = contra-asiento" — nunca se edita/borra nada a mano):
--    · Documento OC-000017 (folio ENT? no — es la recepción, ver abajo):
--      cancelar_recibo_inventario() revierte el inventario (0 kg Glicerina,
--      -0.003 Sorbitol, -0.004 Monopropilenglicol) Y cancela su póliza
--      Diario #26 (contra-asiento) Y libera el $0.14 de anticipo aplicado.
--    · Egreso #57 y #58 (anticipos): cancelar_pago_proveedor() cancela su
--      póliza (contra-asiento: Cargo Bancos / Abono 109.01, devuelve el
--      dinero a Bancos en el registro) y marca el pago 'cancelado' (ya no
--      cuenta para _saldo_anticipo_oc()).
--    · ENT-000001 y ENT-000003: cancelar_recibo_inventario() revierte su
--      inventario y cancela su póliza Diario (#24 y #25).
--
--  Cada paso va en su propio bloque con EXCEPTION: si uno falla, los
--  demás se intentan igual y el motivo queda en el aviso (raise notice).
--  Localiza los ids por folio/numero de póliza — no se adivinan a mano.
-- =====================================================================

begin;

do $$
declare
    v_doc_oc49  bigint := 49;
    v_pol57_id  bigint;
    v_pol58_id  bigint;
    v_pago57_id bigint;
    v_pago58_id bigint;
    v_doc_ent1  bigint;
    v_doc_ent3  bigint;
    v_res       jsonb;
begin
    select id into v_pol57_id from public.polizas where numero = 57 and tipo = 'Egreso' and origen = 'pago';
    select id into v_pol58_id from public.polizas where numero = 58 and tipo = 'Egreso' and origen = 'pago';
    select pp.id into v_pago57_id from public.pagos_proveedor pp where pp.poliza_id = v_pol57_id;
    select pp.id into v_pago58_id from public.pagos_proveedor pp where pp.poliza_id = v_pol58_id;
    select d.id into v_doc_ent1 from public.documentos d where d.folio = 'ENT-000001';
    select d.id into v_doc_ent3 from public.documentos d where d.folio = 'ENT-000003';

    raise notice 'Localizado -> poliza Egreso#57=% (pago %) | poliza Egreso#58=% (pago %) | ENT-000001 doc=% | ENT-000003 doc=%',
        v_pol57_id, v_pago57_id, v_pol58_id, v_pago58_id, v_doc_ent1, v_doc_ent3;

    -- 1) Recepcion de prueba OC-000017 (documento #49) — PRIMERO, libera el
    --    anticipo aplicado antes de poder cancelar el Egreso #57.
    begin
        v_res := public.cancelar_recibo_inventario(v_doc_oc49, 'Prueba de funcionamiento (residuos de gramos) - se cancela');
        raise notice 'Documento #49 (recepcion de prueba OC-000017) cancelado: %', v_res->>'mensaje';
    exception when others then
        raise notice 'Documento #49: NO se pudo cancelar - %  (si es por esto, los anticipos de abajo tampoco van a poder cancelarse)', sqlerrm;
    end;

    -- 2) Anticipo Egreso #57
    if v_pago57_id is not null then
        begin
            perform public.cancelar_pago_proveedor(v_pago57_id);
            raise notice 'Anticipo Egreso #57 (pago %) cancelado.', v_pago57_id;
        exception when others then
            raise notice 'Anticipo Egreso #57: NO se pudo cancelar - %', sqlerrm;
        end;
    else
        raise notice 'No se encontro el pago de la poliza Egreso #57 - se omite.';
    end if;

    -- 3) Anticipo Egreso #58 (sin nada aplicado, deberia cancelar directo)
    if v_pago58_id is not null then
        begin
            perform public.cancelar_pago_proveedor(v_pago58_id);
            raise notice 'Anticipo Egreso #58 (pago %) cancelado.', v_pago58_id;
        exception when others then
            raise notice 'Anticipo Egreso #58: NO se pudo cancelar - %', sqlerrm;
        end;
    else
        raise notice 'No se encontro el pago de la poliza Egreso #58 - se omite.';
    end if;

    -- 4) Entrada directa ENT-000001
    if v_doc_ent1 is not null then
        begin
            v_res := public.cancelar_recibo_inventario(v_doc_ent1, 'Prueba de funcionamiento - se cancela');
            raise notice 'ENT-000001 (documento %) cancelado: %', v_doc_ent1, v_res->>'mensaje';
        exception when others then
            raise notice 'ENT-000001: NO se pudo cancelar - %', sqlerrm;
        end;
    else
        raise notice 'No se encontro el documento ENT-000001 - se omite.';
    end if;

    -- 5) Entrada directa ENT-000003
    if v_doc_ent3 is not null then
        begin
            v_res := public.cancelar_recibo_inventario(v_doc_ent3, 'Prueba de funcionamiento - se cancela');
            raise notice 'ENT-000003 (documento %) cancelado: %', v_doc_ent3, v_res->>'mensaje';
        exception when others then
            raise notice 'ENT-000003: NO se pudo cancelar - %', sqlerrm;
        end;
    else
        raise notice 'No se encontro el documento ENT-000003 - se omite.';
    end if;
end $$;

commit;


-- =====================================================================
-- Verificación (opcional) — todo lo cancelado debe salir 'cancelada'
-- (con su reverso) y las cuentas volver a su saldo de antes de las pruebas:
-- select p.numero, p.tipo, p.concepto, p.estatus
--   from public.polizas p
--  where (p.numero in (57,58) and p.tipo = 'Egreso' and p.origen = 'pago')
--     or (p.numero in (24,25,26) and p.tipo = 'Diario')
--  order by p.numero;
-- =====================================================================
