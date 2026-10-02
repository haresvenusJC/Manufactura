-- =====================================================================
--  Reclasifica 16 recepciones de compra capturadas "Contado" que en
--  realidad NUNCA se pagaron (confirmado por el usuario 2026-09-28).
--  Fecha: 2026-09-28  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Qué pasó: al capturar la recepción se dejó/marcó "Condición: Contado"
--  sin que de verdad saliera dinero del banco o la caja. contabilizar_compra
--  hizo bien su trabajo con el dato que recibió: generó el abono a
--  Banco/Caja como si se hubiera pagado, y la póliza salió tipo "Egreso".
--
--  Primera versión de este script (ya descartada) solo AGREGABA una póliza
--  correctora sin tocar la original — los números cuadraban, pero la
--  póliza original se quedaba etiquetada "Egreso" para siempre, inflando
--  cualquier reporte que cuente pólizas por tipo. Esta versión corrige
--  bien: CANCELA la póliza Egreso original (contra-asiento, mismo mecanismo
--  de siempre — "Cancelar = contra-asiento", ver CLAUDE.md) y la reemplaza
--  por una póliza DIARIO nueva con los movimientos correctos (todo lo que
--  no sea la parte de "pago" de la original, más el pasivo con el
--  proveedor si la original ni siquiera lo reconocía — versión vieja de
--  contabilizar_compra, antes del módulo de Anticipos, que en Contado
--  nunca tocaba 201.01).
--
--  NO toca inventario ni el costeo PEPS: cancelar_poliza es solo capa
--  contable, no dispara reversión de inventario.
--
--  El documento pasa a condicion='credito', total_pagado=0, sin cuenta de
--  pago, y su poliza_id queda apuntando a la nueva póliza Diario (correcta).
--
--  Candado: si un documento ya tiene su póliza de reclasificación
--  (origen = 'ajuste_condicion_compra'), se omite — se puede correr
--  varias veces sin duplicar.
--
--  Documentos incluidos (id, folio): 38 F-2407 · 39 OC-000033 ·
--  37 OC-000031 · 10 OC-000015 · 15 OC-000017 · 12 OC-787934 ·
--  11 OC-000014 · 16 OC-000018 · 20 OC-000020 · 21 OC-000021 ·
--  6 OC-560863 · 7 OC-608975 · 8 OC-582217 · 9 OC-571433 ·
--  4 OC-308006 · 3 OC-016018.
-- =====================================================================

begin;

do $$
declare
    v_id        bigint;
    v_ids       constant bigint[] := array[38,39,37,10,15,12,11,16,20,21,6,7,8,9,4,3];
    v_doc       public.documentos%rowtype;
    v_pol       public.polizas%rowtype;
    v_cta201    bigint := public._cuenta_id('201.01');
    v_movs      jsonb;
    v_sum_cargo numeric(14,2);
    v_sum_abono numeric(14,2);
    v_falta     numeric(14,2);
    v_nueva_id  bigint;
    v_ya_existe boolean;
begin
    if v_cta201 is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;

    foreach v_id in array v_ids loop
        select * into v_doc from public.documentos where id = v_id;
        if not found then
            raise notice 'Documento % no existe, se omite.', v_id;
            continue;
        end if;

        select exists(
            select 1 from public.polizas
             where origen = 'ajuste_condicion_compra' and origen_tabla = 'documentos' and origen_id = v_id
        ) into v_ya_existe;
        if v_ya_existe then
            raise notice 'Documento % (%): ya tiene su reclasificacion, se omite.', v_id, v_doc.folio;
            continue;
        end if;

        select * into v_pol from public.polizas where id = v_doc.poliza_id;
        if not found or v_pol.estatus <> 'contabilizada' then
            raise notice 'Documento % (%): su poliza no esta contabilizada (o no existe), se omite.', v_id, v_doc.folio;
            continue;
        end if;

        -- Todo lo de la poliza original MENOS la parte de "pago" (el cargo
        -- a 201.01 y/o el abono a banco/caja que generó contabilizar_compra
        -- con concepto 'Pago compra ...' — según la version que la generó,
        -- puede ser 1 o 2 renglones).
        select coalesce(jsonb_agg(jsonb_build_object(
                   'cuenta_id', pm.cuenta_id, 'cargo', pm.cargo, 'abono', pm.abono,
                   'concepto', pm.concepto, 'proveedor_id', pm.proveedor_id
               ) order by pm.orden), '[]'::jsonb),
               coalesce(sum(pm.cargo), 0), coalesce(sum(pm.abono), 0)
          into v_movs, v_sum_cargo, v_sum_abono
          from public.poliza_movimientos pm
         where pm.poliza_id = v_doc.poliza_id
           and coalesce(pm.concepto, '') not ilike 'Pago compra%';

        if jsonb_array_length(v_movs) = 0 then
            raise notice 'Documento % (%): no quedo ningun movimiento al quitar el pago, se omite (revisar a mano).', v_id, v_doc.folio;
            continue;
        end if;

        -- Si la poliza original (version vieja, antes de Anticipos) nunca
        -- reconocio el pasivo en 201.01 -- en Contado iba directo Inventario
        -- = Banco, sin tocar Proveedores -- faltara un abono aqui: se agrega
        -- por el importe que deja de cuadrar.
        v_falta := round(v_sum_cargo - v_sum_abono, 2);
        if v_falta < 0 then
            raise notice 'Documento % (%): la poliza sin el pago queda descuadrada al reves (abonos > cargos), se omite (revisar a mano).', v_id, v_doc.folio;
            continue;
        elsif v_falta > 0 then
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'abono', v_falta,
                        'concepto', 'Queda a credito - ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        end if;

        -- 1) Cancela la Egreso original (contra-asiento -- no se edita a mano).
        perform public.cancelar_poliza(v_doc.poliza_id,
            'Se capturo Contado sin haberse pagado - se reclasifica a credito (' || coalesce(v_doc.folio, '') || ')');

        -- 2) Poliza Diario nueva, ya correcta.
        v_nueva_id := (public.registrar_poliza(jsonb_build_object(
            'fecha', current_date,
            'tipo', 'Diario',
            'concepto', 'Compra ' || coalesce(v_doc.folio, '') || ' (reclasificada a credito - no se pago de contado)',
            'folio', v_doc.folio,
            'origen', 'ajuste_condicion_compra',
            'origen_tabla', 'documentos',
            'origen_id', v_id,
            'movimientos', v_movs
        ))->>'poliza_id')::bigint;

        -- 3) El documento apunta ya a la poliza correcta y queda a credito.
        update public.documentos
           set poliza_id = v_nueva_id, condicion = 'credito', total_pagado = 0, cuenta_pago_id = null
         where id = v_id;

        raise notice 'Documento % (%): Egreso #% cancelada, Diario id % generada.', v_id, v_doc.folio, v_pol.numero, v_nueva_id;
    end loop;
end $$;

commit;


-- =====================================================================
-- Verificación (opcional) — por cada documento: su Egreso original debe
-- salir 'cancelada' (+ su reverso) y la Diario nueva 'contabilizada':
-- select d.id, d.folio, d.condicion, d.poliza_id as poliza_vigente,
--        p.tipo, p.numero, p.estatus, p.concepto
--   from public.documentos d
--   join public.polizas p on p.origen_tabla = 'documentos' and p.origen_id = d.id
--                          or p.id = d.poliza_id
--  where d.id = any(array[38,39,37,10,15,12,11,16,20,21,6,7,8,9,4,3])
--  order by d.id, p.id;
-- =====================================================================
