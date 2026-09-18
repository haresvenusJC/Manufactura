-- =====================================================================
--  contabilizar_compra: ya no absorbe en silencio una diferencia grande
--  entre lo facturado y lo físicamente recibido
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Contexto: 2026-10-01 corrigió Recibo de mercancía para que, si un
--  operador ya contó físicamente una partida (pre-recibo), esa cantidad
--  mande sobre lo que traiga el XML — correcto a nivel INVENTARIO: solo
--  entra lo que de verdad llegó. Pero a nivel CONTABLE, la factura se
--  sigue contabilizando tal como el proveedor la emitió (eso ya lo hacía
--  bien contabilizar_compra: usa el Subtotal/IVA del XML, no la suma de
--  documento_detalles) — la diferencia entre lo facturado y lo recibido
--  es un asunto a resolver CON EL PROVEEDOR (normalmente pidiéndole una
--  nota de crédito/complemento por la merma), no algo que el sistema deba
--  decidir solo.
--
--  El bug: el "reparto real" de contabilizar_compra ajustaba (ver
--  comentario "Reparto REAL") el cargo a inventario para que sumara
--  exacto contra el subtotal de la factura, sin límite. Eso estaba
--  pensado para centavos de redondeo entre lotes — pero con una
--  diferencia FÍSICA real (ej. llegaron 810 piezas y se facturaron 910),
--  el ajuste absorbía TODA la diferencia hacia la cuenta de inventario:
--  el Balance mostraría más valor de inventario del que de verdad existe
--  en el almacén, sin ningún aviso.
--
--  Fix: el ajuste automático ahora solo se permite hasta $5.00 MXN (
--  redondeo real entre lotes, nunca tanto). Si la diferencia es mayor,
--  la función se detiene con un mensaje explicando las dos salidas:
--  1) Ajustar el campo "Subtotal" de esta pantalla al valor de lo que
--     de verdad se va a poder deducir/pagar por ahora (lo demás se
--     contabiliza cuando llegue la nota de crédito o el resto de la
--     mercancía), o
--  2) Si el proveedor ya confirmó que no va a reponer ni descontar la
--     diferencia, capturar esa merma aparte como un Gasto (o una
--     Devolución a proveedor si corresponde) en vez de forzarla aquí.
--
--  Es la MISMA función completa de 2026-09-26_fix_unificado_costeo_
--  recepcion.sql — solo cambia el bloque del "Reparto REAL".
--
--  Idempotente.
-- =====================================================================

begin;

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

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

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

    -- FIX 2026-10-07: si lo que de verdad entró a inventario (v_acum, por
    -- cantidad física) difiere del subtotal facturado (v_base_inv) por más
    -- que un redondeo de centavos, NO se absorbe en silencio hacia la
    -- cuenta de inventario — se detiene y se explica qué hacer. El ajuste
    -- automático solo cubre diferencias de centavos entre lotes.
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

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA acreditable) en el plan de cuentas.',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
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

    if v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total, 'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''));
    else
        v_id := public._cuenta_id('201.01');
        if v_id is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_total,
                    'concepto', 'Compra a credito ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
    end if;

    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', 'Egreso',
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
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = case when v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;
