-- =====================================================================
--  IVA del anticipo en la recepción de mercancía
--  Fecha: 2026-10-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Hallazgo (ODC-000010): con anticipo del 30% ($369.75 de $1,232.50), la
--  recepción mandaba TODO el IVA ($170) a 119.01 (pendiente) y el pago final
--  reclasificaba solo en proporción a lo pagado entonces ($862.75 -> $119.00).
--  Los $51.00 de IVA ya pagados con el anticipo se quedaban para siempre en
--  119.01. Ahora la recepción manda a 118.01 (pagado) la parte del IVA cubierta
--  por el anticipo y a 119.01 el resto; el pago final reclasifica el resto.
--
--  contabilizar_compra: cuerpo COMPLETO = versión de 2026-10-07 +
--  'serie' = 'REC' (que 2026-10-09 había agregado por parche de texto) +
--  este cambio. Idempotente (create or replace). Solo afecta recepciones nuevas.
-- =====================================================================
begin;

create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_iva_pag numeric(14,2);
    v_iva_pen numeric(14,2);
    v_doc        public.documentos%rowtype;
    v_subtotal   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'subtotal')::numeric, 0), 2));
    v_iva        numeric(14,2) := greatest(0, round(coalesce((p_datos->>'iva')::numeric, 0), 2));
    v_ieps       numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ieps')::numeric, 0), 2));
    v_ret_iva    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2));
    v_ret_isr    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2));
    v_total      numeric(14,2);
    v_sum_det    numeric(14,2);
    v_movs       jsonb := '[]'::jsonb;
    v_id         bigint;
    v_cta_inv_def bigint := public._cuenta_id('115.01');
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

    -- Nota de crédito/cargo (2026-10-07): resuelve la diferencia física
    -- vs. factura en el momento, sin salir de la recepción.
    v_nota          jsonb := p_datos->'nota_ajuste';
    v_nota_tipo     text;
    v_nota_monto    numeric(14,2);
    v_nota_motivo   text;
    v_nota_detalle  text;
    v_nota_dif      numeric(14,2);
    v_nota_folio    text;
    v_nota_pendiente boolean := false;

    -- Anticipo a proveedores: siempre se reconoce el pasivo completo en
    -- 201.01 y luego se cancela por la vía que corresponda.
    v_cta201        bigint;
    v_cta109        bigint;
    v_anticipo_disp numeric(14,2);
    v_anticipo_usar numeric(14,2) := 0;
    v_resto         numeric(14,2);
    v_pagado_total  numeric(14,2) := 0;
    v_falta         numeric(14,2);
    v_take          numeric(14,2);
    rA           record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;

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

    -- Reparto REAL: suma lo que de verdad quedó grabado en cada lote
    -- (lotes_inventario.costo_unitario, ya con su landed cost aplicado,
    -- vía documento_detalles.lote_id) agrupado por cuenta de inventario.
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

    -- Si lo que de verdad entró a inventario (v_acum, por cantidad física)
    -- difiere del subtotal facturado (v_base_inv) por más que un redondeo
    -- de centavos: se resuelve con una nota de crédito/cargo (si viene en
    -- p_datos->'nota_ajuste') o se detiene explicando qué hacer.
    if abs(v_acum - v_base_inv) > v_tolerancia and jsonb_array_length(v_movs) > 0 then
        v_nota_tipo := nullif(trim(v_nota->>'tipo'), '');
        v_nota_monto := round(coalesce((v_nota->>'monto')::numeric, 0), 2);
        v_nota_motivo := nullif(trim(v_nota->>'motivo'), '');
        v_nota_detalle := nullif(trim(v_nota->>'motivo_detalle'), '');
        v_nota_dif := round(v_base_inv - v_acum, 2);  -- > 0 = llego menos (credito) · < 0 = llego de mas (cargo)

        if v_nota_tipo is null or v_nota_motivo is null
           or (v_nota_tipo = 'credito' and v_nota_dif <= 0)
           or (v_nota_tipo = 'cargo' and v_nota_dif >= 0)
           or abs(v_nota_monto - abs(v_nota_dif)) > v_tolerancia
        then
            v_msg := format(
                'Lo que se va a recibir a inventario ($%s) no coincide con el subtotal de la factura ($%s) — diferencia de $%s, mayor a la tolerancia de redondeo ($%s). '
                'Esto pasa cuando llegó menos (o más) de lo facturado. Registra una Nota de %s por $%s con su motivo para resolverlo aquí mismo, '
                'o si el proveedor ya confirmó que la diferencia no se repone ni se descuenta, captúrala aparte como Gasto (merma) en vez de forzarla en esta compra.',
                round(v_acum, 2), round(v_base_inv, 2), round(v_acum - v_base_inv, 2), v_tolerancia,
                case when v_nota_dif > 0 then 'Crédito (NDC)' else 'Cargo (NDP)' end, abs(v_nota_dif)
            );
            raise exception using
                message = v_msg,
                detail = jsonb_build_object(
                    'necesita_nota', true,
                    'tipo', case when v_nota_dif > 0 then 'credito' else 'cargo' end,
                    'monto', abs(v_nota_dif)
                )::text;
        end if;
        if v_nota_motivo = 'otro' and v_nota_detalle is null then
            raise exception 'Motivo "Otro": especifica el detalle de la nota.';
        end if;

        -- La nota cubre la diferencia: el inventario se queda en lo REAL
        -- recibido (v_acum); el subtotal/total de la compra se ajustan por
        -- el monto de la nota (antes de IVA — simplificación: el IVA se
        -- sigue reconociendo tal cual lo trae la factura; confirmar con el
        -- contador si debe prorratearse).
        v_subtotal := round(v_subtotal - v_nota_dif, 2);
        v_base_inv := v_acum;
        v_total := round(v_subtotal + v_ext_cap + v_ext_nocap + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
        if v_total < 0 then raise exception 'La nota de ajuste deja el total de la compra en negativo.'; end if;
        v_nota_pendiente := true;
    end if;
    if v_acum <> v_base_inv and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_base_inv - v_acum), 2))
        );
    end if;

    -- Cargos no capitalizables: cada concepto a su propia cuenta de gasto
    -- (flete 601.14 / seguro 601.61 / maniobras 601.62 / aduana 601.63 /
    -- otro 601.99), no todos por default a 601.14.
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

    -- Cuanto de esta compra ya esta cubierto por un anticipo pagado antes
    -- (0 si la OC no tiene anticipo, o si la compra no viene de una OC).
    -- Se calcula HASTA AQUI porque ya se conoce el v_total final (despues
    -- de aplicar, si hizo falta, la nota de ajuste de arriba).
    v_anticipo_disp := coalesce(public._saldo_anticipo_oc(v_doc.orden_compra_id), 0);
    v_anticipo_usar := least(v_anticipo_disp, v_total);
    v_resto := round(v_total - v_anticipo_usar, 2);

    -- IVA acreditable (LIVA: solo es acreditable el IVA efectivamente pagado).
    -- La parte del IVA que corresponde a lo YA pagado con anticipo (v_anticipo_usar
    -- del total) va directo a 118.01 (pagado); el resto queda en 119.01 (pendiente)
    -- y se reclasifica al pagar el saldo (registrar_pago_proveedor, proporcional).
    -- Con anticipo = 100% todo va a 118.01.
    if v_iva > 0 then
        v_iva_pag := case when v_total > 0 then round(v_iva * v_anticipo_usar / v_total, 2) else 0 end;
        if v_resto = 0 then v_iva_pag := v_iva; end if;
        v_iva_pen := round(v_iva - v_iva_pag, 2);
        if v_iva_pag > 0 then
            v_id := public._cuenta_id('118.01');
            if v_id is null then raise exception 'Falta la cuenta 118.01 (IVA acreditable pagado) en el plan de cuentas.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva_pag, 'concepto', 'IVA acreditable (cubierto con anticipo)');
        end if;
        if v_iva_pen > 0 then
            v_id := public._cuenta_id('119.01');
            if v_id is null then raise exception 'Falta la cuenta 119.01 (IVA acreditable pendiente de pago) en el plan de cuentas.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva_pen, 'concepto', 'IVA acreditable');
        end if;
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

    -- ---- Reconocimiento del pasivo + su cancelación (SIEMPRE por 201.01) ----
    v_cta201 := public._cuenta_id('201.01');
    if v_cta201 is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;

    -- 1) Se reconoce el pasivo COMPLETO, siempre — así el proveedor
    --    queda con su movimiento completo en su auxiliar, aunque el neto
    --    termine en cero por el anticipo (control de pasivos).
    v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'abono', v_total,
                'concepto', 'Compra ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);

    -- 2) Se cancela contra el anticipo disponible de esa OC (si hay).
    if v_anticipo_usar > 0 then
        v_cta109 := public._cuenta_id('109.01');
        if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_anticipo_usar,
                    'concepto', 'Aplicacion de anticipo - ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta109, 'abono', v_anticipo_usar,
                    'concepto', 'Anticipo aplicado a ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_pagado_total := v_pagado_total + v_anticipo_usar;
    end if;

    -- 3) Lo que sobra (v_resto) se queda vivo en 201.01 — Finanzas lo paga
    --    despues desde Cuentas por pagar. La recepcion ya NUNCA abona
    --    banco directo, asi que la poliza siempre es Diario.
    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', 'Diario',
        'serie', 'REC',
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
           total = v_total, condicion = 'credito',
           total_pagado = v_pagado_total,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = null,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    -- Consume el/los anticipo(s) de esa OC (FIFO por si hubo mas de un
    -- pago de anticipo) dejando el rastro en pagos_proveedor_aplicaciones
    -- para que _saldo_anticipo_oc() ya lo descuente la proxima vez.
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

    -- Nota de credito/cargo (si la diferencia fisica vs. factura se
    -- resolvio arriba): queda registrada con su folio propio, ligada a
    -- esta misma poliza (no tiene poliza aparte).
    if v_nota_pendiente then
        v_nota_folio := public.siguiente_folio(case when v_nota_tipo = 'credito' then 'NDC' else 'NDP' end);
        insert into public.notas_compra (folio, tipo, documento_id, orden_compra_id, proveedor_id, monto, motivo, motivo_detalle, poliza_id)
        values (v_nota_folio, v_nota_tipo, p_documento_id, v_doc.orden_compra_id, v_doc.proveedor_id, abs(v_nota_dif), v_nota_motivo, v_nota_detalle, v_id);
    end if;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap,
        'anticipo_aplicado', v_anticipo_usar, 'nota_folio', v_nota_folio);
end;
$$;

grant execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;
