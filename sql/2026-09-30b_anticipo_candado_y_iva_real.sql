-- =====================================================================
--  3 correcciones encontradas al auditar el flujo de OC-000017:
--   1. pagar_anticipo_oc() sin tope: permitió pagar $16,801.28 de anticipo
--      (dos pagos idénticos de $8,400.64) contra una OC de $9,744.74.
--   2. contabilizar_compra() decidía 118.01 (IVA pagado) / 119.01 (IVA
--      pendiente) por el combo Contado/Crédito crudo, no por si de
--      verdad queda algo pendiente tras aplicar el anticipo — la misma
--      clase de bug que ya se corrigió para el TIPO de póliza, pero que
--      se quedó sin corregir en esta otra decisión de la misma función.
--   3. El mensaje de "Recibir mercancía" siempre decía "Póliza de Egreso
--      generada" así hubiera salido Diario — porque contabilizar_compra()
--      nunca regresaba qué tipo decidió.
--  Fecha: 2026-09-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Compatible con sql/2026-09-28_reclasificar_compras_contado_no_pagadas.sql,
--  sql/2026-09-29_prerecibo_resumen_oc.sql y
--  sql/2026-09-30_entrada_directa_candado_neteo.sql (ninguna toca
--  contabilizar_compra ni pagar_anticipo_oc; se pueden correr en
--  cualquier orden).
--
--  Idempotente (create or replace function).
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. pagar_anticipo_oc — tope: lo ya pagado + lo nuevo no puede exceder
--    el total ESTIMADO de la OC (subtotal de ordenes_compra_detalle,
--    con un margen del 30% para cubrir IVA/landed cost que aún no se
--    conocen a esta altura — no es un cálculo exacto, es un candado
--    contra errores groseros como pagar el mismo anticipo dos veces).
-- ---------------------------------------------------------------------
create or replace function public.pagar_anticipo_oc(p_oc_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_oc        public.ordenes_compra%rowtype;
    v_fecha     date := (p_datos->>'fecha')::date;
    v_cta_pago  bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_forma     text := nullif(trim(p_datos->>'forma_pago'), '');
    v_ref       text := nullif(trim(p_datos->>'referencia'), '');
    v_notas     text := nullif(trim(p_datos->>'notas'), '');
    v_monto     numeric(14,2) := round(coalesce((p_datos->>'monto')::numeric, 0), 2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_cta109    bigint;
    v_pago_id   bigint;
    v_poliza_id bigint;
    v_subtotal_oc numeric(14,2);
    v_tope        numeric(14,2);
    v_ya_pagado   numeric(14,2);
begin
    if v_fecha is null then raise exception 'La fecha del anticipo es obligatoria.'; end if;
    if v_monto <= 0 then raise exception 'El monto del anticipo debe ser mayor a cero.'; end if;

    select * into v_oc from public.ordenes_compra where id = p_oc_id;
    if not found then raise exception 'La orden de compra no existe.'; end if;
    if v_oc.estatus not in ('abierta', 'recibida_parcial') then
        raise exception 'Solo se puede pagar un anticipo a una orden de compra abierta o parcialmente recibida (estatus actual: %).', v_oc.estatus;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
    if not found then raise exception 'Selecciona la cuenta de caja / banco.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    -- Candado: no dejar que el anticipo acumulado de esta OC exceda un
    -- techo razonable de su total (evita el caso real encontrado: pagar
    -- el mismo anticipo dos veces sin que nada avisara).
    select coalesce(sum(d.cantidad * d.costo_unitario_estimado), 0) into v_subtotal_oc
      from public.ordenes_compra_detalle d where d.orden_compra_id = p_oc_id;
    if v_subtotal_oc > 0 then
        v_tope := round(v_subtotal_oc * 1.30, 2); -- subtotal + margen generoso de IVA/landed cost
        select coalesce(sum(a.monto), 0) into v_ya_pagado
          from public.pagos_proveedor_aplicaciones a
          join public.pagos_proveedor pp on pp.id = a.pago_id
         where a.tipo = 'anticipo_oc' and a.orden_compra_id = p_oc_id and pp.estatus = 'registrado';
        if (v_ya_pagado + v_monto) > v_tope then
            raise exception 'El anticipo de % excede el total estimado de la OC % (subtotal $%, tope con margen $%). Ya pagaste $% de anticipo a esta OC; como mucho puedes agregar $% mas. Revisa si este anticipo ya se habia pagado antes.',
                to_char(v_monto, 'FM999999990.00'), coalesce(v_oc.folio, '#' || p_oc_id),
                to_char(v_subtotal_oc, 'FM999999990.00'), to_char(v_tope, 'FM999999990.00'),
                to_char(v_ya_pagado, 'FM999999990.00'), to_char(greatest(v_tope - v_ya_pagado, 0), 'FM999999990.00');
        end if;
    end if;

    v_cta109 := public._cuenta_id('109.01');
    if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores) en el plan de cuentas.'; end if;

    insert into public.pagos_proveedor (fecha, cuenta_pago_id, forma_pago, referencia, proveedor_id, total, notas)
    values (v_fecha, v_cta_pago, v_forma, v_ref, v_oc.proveedor_id, v_monto, v_notas)
    returning id into v_pago_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Egreso',
        'concepto', 'Anticipo a proveedor - OC ' || coalesce(v_oc.folio, '#' || p_oc_id) || coalesce(' - ' || v_ref, ''),
        'origen', 'pago', 'origen_tabla', 'pagos_proveedor', 'origen_id', v_pago_id,
        'movimientos', jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta109, 'cargo', v_monto,
                'concepto', 'Anticipo OC ' || coalesce(v_oc.folio, '#' || p_oc_id), 'proveedor_id', v_oc.proveedor_id),
            jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_monto,
                'concepto', 'Anticipo a proveedor' || coalesce(' - ' || v_ref, ''))
        )
    ))->>'poliza_id')::bigint;

    update public.pagos_proveedor set poliza_id = v_poliza_id where id = v_pago_id;

    insert into public.pagos_proveedor_aplicaciones (pago_id, tipo, orden_compra_id, monto)
    values (v_pago_id, 'anticipo_oc', p_oc_id, v_monto);

    return jsonb_build_object('pago_id', v_pago_id, 'poliza_id', v_poliza_id, 'total', v_monto);
end $$;

revoke all     on function public.pagar_anticipo_oc(bigint, jsonb) from public, anon;
grant  execute on function public.pagar_anticipo_oc(bigint, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 2 y 3. contabilizar_compra — IVA pagado/pendiente por si de verdad se
--    pagó (no por el combo crudo) + regresa tipo_poliza en el resultado.
--    Copia exacta de sql/2026-10-27_anticipo_proveedores.sql con esos
--    dos cambios puntuales.
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    v_subtotal   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'subtotal')::numeric, 0), 2));
    v_iva        numeric(14,2) := greatest(0, round(coalesce((p_datos->>'iva')::numeric, 0), 2));
    v_ieps       numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ieps')::numeric, 0), 2));
    v_ret_iva    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2));
    v_ret_isr    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2));
    v_condicion  text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'credito');
    v_cta_pago   bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_total      numeric(14,2);
    v_sum_det    numeric(14,2);
    v_movs       jsonb := '[]'::jsonb;
    v_id         bigint;
    v_cta_inv_def bigint := public._cuenta_id('115.01');
    v_cuenta     public.cuentas_contables%rowtype;
    r            record;
    v_acum       numeric(14,2) := 0;
    v_base_inv   numeric(14,2);
    v_tolerancia constant numeric(14,2) := 5.00;
    v_msg        text;

    v_ext        jsonb := coalesce(p_datos->'costos_adicionales', '[]'::jsonb);
    v_ext_cap    numeric(14,2) := 0;
    v_ext_nocap  numeric(14,2) := 0;
    v_cta_flete    bigint := public._cuenta_id('601.14');
    v_cta_seguro   bigint := public._cuenta_id('601.61');
    v_cta_maniobra bigint := public._cuenta_id('601.62');
    v_cta_aduana   bigint := public._cuenta_id('601.63');
    v_cta_otros    bigint := public._cuenta_id('601.99');
    e            record;

    v_cta201        bigint;
    v_cta109        bigint;
    v_anticipo_disp numeric(14,2);
    v_anticipo_usar numeric(14,2) := 0;
    v_resto         numeric(14,2);
    v_pagado_total  numeric(14,2) := 0;
    v_tipo_poliza   text;
    v_iva_pagado    boolean;
    v_falta         numeric(14,2);
    v_take          numeric(14,2);
    rA           record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select coalesce(sum(subtotal), 0) into v_sum_det from public.documento_detalles where documento_id = p_documento_id;
    if v_subtotal <= 0 then v_subtotal := round(v_sum_det, 2); end if;
    if v_subtotal <= 0 then raise exception 'La compra no tiene importe (subtotal 0).'; end if;

    select coalesce(sum((x->>'monto')::numeric), 0)
      into v_ext_cap
      from jsonb_array_elements(v_ext) x
     where coalesce((x->>'capitaliza')::boolean, true);
    select coalesce(sum((x->>'monto')::numeric), 0)
      into v_ext_nocap
      from jsonb_array_elements(v_ext) x
     where not coalesce((x->>'capitaliza')::boolean, true);
    v_ext_cap := round(v_ext_cap, 2);
    v_ext_nocap := round(v_ext_nocap, 2);

    v_total := round(v_subtotal + v_ext_cap + v_ext_nocap + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden superar subtotal + impuestos.'; end if;

    v_anticipo_disp := coalesce(public._saldo_anticipo_oc(v_doc.orden_compra_id), 0);
    v_anticipo_usar := least(v_anticipo_disp, v_total);
    v_resto := round(v_total - v_anticipo_usar, 2);

    -- Si tras aplicar el anticipo ya no queda nada vivo en 201.01 (v_resto=0)
    -- o el resto se paga aqui mismo (contado), la compra completa quedo
    -- pagada -- el IVA va a "pagado" (118.01), no a "pendiente" (119.01),
    -- SIN IMPORTAR que casilla haya quedado marcada en pantalla. Antes se
    -- decidia solo por v_condicion = 'contado', lo cual clasificaba mal el
    -- IVA cuando un anticipo cubria el 100% y se habia dejado en "Credito".
    v_iva_pagado := (v_resto = 0) or (v_condicion = 'contado');

    if v_condicion = 'contado' and v_resto > 0 then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    v_base_inv := round(v_subtotal + v_ext_cap, 2);
    for r in
        select coalesce(pr.cuenta_inventario_id, v_cta_inv_def) as cta_id,
               sum(coalesce(li.costo_unitario * dd.cantidad, dd.subtotal)) as monto_real
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
          left join public.lotes_inventario li on li.id = dd.lote_id
         where dd.documento_id = p_documento_id
         group by coalesce(pr.cuenta_inventario_id, v_cta_inv_def)
         order by 1
    loop
        v_acum := v_acum + round(r.monto_real, 2);
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', round(r.monto_real, 2), 'concepto', 'Inventario ' || coalesce(v_doc.folio, ''));
    end loop;

    if abs(v_acum - v_base_inv) > v_tolerancia and jsonb_array_length(v_movs) > 0 then
        v_msg := format(
            'Lo que se va a recibir a inventario ($%s) no coincide con el subtotal de la factura ($%s) — diferencia de $%s, mayor a la tolerancia de redondeo ($%s). '
            'Esto pasa cuando llegó menos (o más) de lo facturado. Dos salidas: '
            '1) Ajusta aquí el campo "Subtotal" al valor de lo que sí vas a contabilizar ahora, y gestiona la diferencia con el proveedor aparte (normalmente pidiendo una nota de crédito) — cuando llegue, se contabiliza por separado; '
            'o 2) si el proveedor ya confirmó que la diferencia no se repone ni se descuenta, captúrala aparte como Gasto (merma) en vez de forzarla en esta compra.',
            round(v_acum, 2), round(v_base_inv, 2), round(v_acum - v_base_inv, 2), v_tolerancia
        );
        raise exception using message = v_msg;
    end if;
    if v_acum <> v_base_inv and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_base_inv - v_acum), 2))
        );
    end if;

    if v_ext_nocap > 0 then
        for e in
            select coalesce(
                     (x->>'cuenta_gasto_id')::bigint,
                     case lower(coalesce(x->>'concepto', ''))
                         when 'flete' then v_cta_flete
                         when 'seguro' then v_cta_seguro
                         when 'maniobras' then v_cta_maniobra
                         when 'aduana / pedimento' then v_cta_aduana
                         else v_cta_otros
                     end,
                     v_cta_flete
                   ) as cta,
                   sum((x->>'monto')::numeric) as monto
              from jsonb_array_elements(v_ext) x
             where not coalesce((x->>'capitaliza')::boolean, true)
             group by 1
        loop
            if e.cta is null then raise exception 'Un cargo adicional no capitalizable no tiene cuenta de gasto y falta su cuenta de respaldo en el plan de cuentas.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', e.cta, 'cargo', round(e.monto, 2),
                        'concepto', 'Cargo de compra (no inventariable) ' || coalesce(v_doc.folio, ''));
        end loop;
    end if;

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_iva_pagado then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA acreditable) en el plan de cuentas.',
            case when v_iva_pagado then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva, 'concepto', 'IVA acreditable');
    end if;

    if v_ieps > 0 then
        v_id := public._cuenta_id('118.03');
        if v_id is null then raise exception 'Falta la cuenta 118.03 (IEPS acreditable).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_ieps, 'concepto', 'IEPS acreditable');
    end if;

    if v_ret_iva > 0 then
        v_id := public._cuenta_id('216.05');
        if v_id is null then raise exception 'Falta la cuenta 216.05 (IVA retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_iva, 'concepto', 'IVA retenido');
    end if;

    if v_ret_isr > 0 then
        v_id := public._cuenta_id('216.10');
        if v_id is null then raise exception 'Falta la cuenta 216.10 (ISR retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_isr, 'concepto', 'ISR retenido');
    end if;

    v_cta201 := public._cuenta_id('201.01');
    if v_cta201 is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;

    v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'abono', v_total,
                'concepto', 'Compra ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);

    if v_anticipo_usar > 0 then
        v_cta109 := public._cuenta_id('109.01');
        if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_anticipo_usar,
                    'concepto', 'Aplicacion de anticipo - ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta109, 'abono', v_anticipo_usar,
                    'concepto', 'Anticipo aplicado a ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_pagado_total := v_pagado_total + v_anticipo_usar;
    end if;

    if v_resto > 0 and v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_resto,
                    'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_resto,
                    'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''));
        v_pagado_total := v_pagado_total + v_resto;
    end if;

    v_tipo_poliza := case when v_resto > 0 and v_condicion = 'contado' then 'Egreso' else 'Diario' end;

    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', v_tipo_poliza,
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),
        'folio', v_doc.folio,
        'origen', 'compra',
        'origen_tabla', 'documentos',
        'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    if jsonb_array_length(v_ext) > 0 then
        insert into public.recibo_costos_adicionales (documento_id, concepto, monto, capitaliza, cuenta_gasto_id)
        select p_documento_id,
               coalesce(nullif(trim(x->>'concepto'), ''), 'otro'),
               round((x->>'monto')::numeric, 2),
               coalesce((x->>'capitaliza')::boolean, true),
               (x->>'cuenta_gasto_id')::bigint
          from jsonb_array_elements(v_ext) x
         where (x->>'monto')::numeric > 0;
    end if;

    update public.documentos
       set subtotal = v_subtotal, iva = v_iva, ieps = v_ieps, ret_iva = v_ret_iva, ret_isr = v_ret_isr,
           total = v_total, condicion = v_condicion,
           total_pagado = v_pagado_total,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = case when v_resto > 0 and v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    if v_anticipo_usar > 0 then
        v_falta := v_anticipo_usar;
        for rA in
            select a.id as aplic_id, a.pago_id,
                   round(a.monto - coalesce((
                       select sum(a2.monto) from public.pagos_proveedor_aplicaciones a2
                        where a2.tipo = 'anticipo_aplicado' and a2.aplicacion_origen_id = a.id
                   ), 0), 2) as disponible
              from public.pagos_proveedor_aplicaciones a
              join public.pagos_proveedor pp on pp.id = a.pago_id
             where a.tipo = 'anticipo_oc' and a.orden_compra_id = v_doc.orden_compra_id and pp.estatus = 'registrado'
             order by a.id
        loop
            exit when v_falta <= 0;
            if rA.disponible <= 0 then continue; end if;
            v_take := least(rA.disponible, v_falta);
            insert into public.pagos_proveedor_aplicaciones (pago_id, tipo, documento_id, aplicacion_origen_id, monto)
            values (rA.pago_id, 'anticipo_aplicado', p_documento_id, rA.aplic_id, v_take);
            v_falta := v_falta - v_take;
        end loop;
    end if;

    return jsonb_build_object('poliza_id', v_id, 'tipo_poliza', v_tipo_poliza, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap,
        'anticipo_aplicado', v_anticipo_usar);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;
