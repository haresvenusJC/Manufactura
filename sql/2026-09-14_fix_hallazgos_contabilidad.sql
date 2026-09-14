-- =====================================================================
--  Correcciones a hallazgos del repaso de contabilidad / NIF C-4
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Corrige 4 de los 7 hallazgos señalados (el resto queda pendiente por
--  decisión de negocio o ya se atiende en otro archivo):
--
--  1. cancelar_recibo_inventario ya NO traga cualquier error al cancelar
--     la póliza del recibo. Antes: "exception when others then
--     v_pol_rev := null" seguía revirtiendo el inventario aunque
--     cancelar_poliza fallara por lo que fuera. Ahora: solo se tolera
--     el caso "la póliza ya estaba cancelada" (se detecta antes de
--     llamar, sin try/catch); cualquier otro problema real aborta TODA
--     la función — no revierte inventario sin poder revertir la póliza.
--
--  2. cancelar_poliza ya NO permite cancelar una póliza que es, ella
--     misma, un reverso (origen='ajuste', origen_tabla='polizas'). Esto
--     es justo lo que generó la cadena Egreso #2->#3->#4 de esta sesión:
--     cancelar el reverso de algo ya cancelado revive matemáticamente
--     el efecto original sin ningún aviso.
--
--  5. contabilizar_compra ya NO reparte el landed cost con una fórmula
--     propia (redondeada por separado); ahora SUMA lo que de verdad
--     quedó grabado en cada lote (lotes_inventario.costo_unitario vía
--     documento_detalles.lote_id) agrupado por cuenta de inventario.
--     Elimina el riesgo de que el auxiliar de lotes se desvíe por
--     centavos del saldo de la cuenta 115.xx en la Balanza.
--
--  6. Los cargos adicionales NO capitalizables (flete/seguro/maniobras/
--     aduana) ya NO caen todos en 601.14 (Fletes) por default — cada
--     concepto va a su propia cuenta de gasto. Se agregan las cuentas
--     que faltaban (601.61 Seguros, 601.62 Maniobras y almacenaje,
--     601.63 Gastos aduanales); "Otro" sigue cayendo en 601.99.
--
--  Requiere: sql/2026-08-28_contabilidad_polizas.sql
--            sql/2026-09-21_reversa_inventario_recibo.sql
--            sql/2026-09-20_landed_cost.sql
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Cuentas nuevas para el punto 6 (solo las que falten)
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select v.codigo, v.nombre, v.codigo, v.naturaleza, v.tipo, v.nivel, v.afectable
from (values
    ('601.61', 'Seguros de mercancía en tránsito', 'D', 'gasto', 2, true),
    ('601.62', 'Maniobras y almacenaje',            'D', 'gasto', 2, true),
    ('601.63', 'Gastos aduanales',                  'D', 'gasto', 2, true)
) as v(codigo, nombre, naturaleza, tipo, nivel, afectable)
where not exists (select 1 from public.cuentas_contables c where c.codigo = v.codigo);

update public.cuentas_contables c
set cuenta_padre_id = p.id
from public.cuentas_contables p
where c.nivel = 2 and c.cuenta_padre_id is null
  and p.nivel = 1 and p.codigo = split_part(c.codigo, '.', 1)
  and c.codigo in ('601.61', '601.62', '601.63');


-- ---------------------------------------------------------------------
-- 1. cancelar_recibo_inventario — sin try/catch que se trague errores
-- ---------------------------------------------------------------------
create or replace function public.cancelar_recibo_inventario(p_documento_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc         public.documentos%rowtype;
    v_bloqueo     text;
    v_pol_estatus text;
    v_pol_rev     bigint;
    v_movs        jsonb := '[]'::jsonb;
    v_n           integer := 0;
    r             record;
    v_stock       numeric;
    v_oc          bigint;
    v_estatus     text;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento % no existe.', p_documento_id; end if;
    if coalesce(v_doc.estado, '') = 'cancelado' then
        raise exception 'El documento % ya está cancelado.', p_documento_id;
    end if;
    if coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada') then
        raise exception 'Solo se puede revertir un recibo de compra (tipo actual: %).', coalesce(v_doc.tipo_movimiento, 'N/D');
    end if;

    -- guarda: nada del inventario recibido debe haberse consumido
    select string_agg(
             format('· %s lote %s: recibiste %s, quedan %s (consumido %s)',
                    d.producto_nombre, d.numero_lote, d.recibido, d.disponible, d.consumido), E'\n')
      into v_bloqueo
      from public.recibo_reversible(p_documento_id) d
     where not d.ok;
    if v_bloqueo is not null then
        raise exception E'No se puede revertir el inventario del recibo %: ya se consumió stock.\n%', p_documento_id, v_bloqueo;
    end if;

    if not exists (select 1 from public.recibo_reversible(p_documento_id)) then
        raise exception 'El recibo % no tiene movimientos de inventario que revertir.', p_documento_id;
    end if;

    -- 1) cancelar la póliza (si tiene). Solo se tolera explícitamente el
    --    caso "ya estaba cancelada" — cualquier otro problema real debe
    --    detener TODA la función, para no revertir inventario sin poder
    --    revertir su contabilidad.
    if v_doc.poliza_id is not null then
        select estatus into v_pol_estatus from public.polizas where id = v_doc.poliza_id;
        if v_pol_estatus is null then
            v_pol_rev := null;  -- la póliza referenciada ya no existe
        elsif v_pol_estatus = 'cancelada' then
            v_pol_rev := null;  -- ya estaba cancelada: caso tolerado a propósito
        else
            v_pol_rev := (public.cancelar_poliza(v_doc.poliza_id,
                coalesce(p_motivo, 'Cancelación de recibo ' || coalesce(v_doc.folio, p_documento_id::text)))
                ->>'poliza_reversa_id')::bigint;
        end if;
    end if;

    -- 2) revertir el inventario lote por lote
    for r in
        select d.producto_id, d.lote_id, d.numero_lote, d.recibido, p.nombre as producto_nombre,
               um.nombre as unidad
        from public.recibo_reversible(p_documento_id) d
        join public.productos p on p.id = d.producto_id
        left join public.unidades_medida um on um.id = p.unidad_medida_id
    loop
        select coalesce(stock_actual, 0) into v_stock
        from public.productos where id = r.producto_id;

        if r.lote_id is not null then
            update public.lotes_inventario
               set stock_actual = greatest(coalesce(stock_actual, 0) - r.recibido, 0)
             where id = r.lote_id;
        end if;

        update public.productos p2
           set stock_actual = (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = r.producto_id)
         where p2.id = r.producto_id;

        insert into public.movimientos_inventario
            (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id, lote_id)
        values (
            r.producto_id, 'cancelacion_recibo', -abs(r.recibido),
            v_stock,
            (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = r.producto_id),
            coalesce((select costo_unitario from public.lotes_inventario where id = r.lote_id), 0),
            p_documento_id, r.lote_id
        );

        v_n := v_n + 1;
        v_movs := v_movs || jsonb_build_object(
            'producto', r.producto_nombre, 'lote', r.numero_lote,
            'cantidad', -abs(r.recibido), 'unidad', coalesce(r.unidad, ''));
    end loop;

    -- 3) revertir la orden de compra (cantidad_recibida + estatus)
    v_oc := v_doc.orden_compra_id;
    if v_oc is not null then
        update public.ordenes_compra_detalle ocd
           set cantidad_recibida = greatest(coalesce(ocd.cantidad_recibida, 0) - dd.q, 0)
          from (select producto_id, sum(cantidad) as q
                  from public.documento_detalles
                 where documento_id = p_documento_id and producto_id is not null
                 group by producto_id) dd
         where ocd.orden_compra_id = v_oc and ocd.producto_id = dd.producto_id;

        select case
                 when bool_and(coalesce(cantidad_recibida, 0) >= coalesce(cantidad, 0)) then 'recibida'
                 when bool_and(coalesce(cantidad_recibida, 0) = 0) then 'abierta'
                 else 'recibida_parcial'
               end
          into v_estatus
          from public.ordenes_compra_detalle where orden_compra_id = v_oc;
        update public.ordenes_compra set estatus = coalesce(v_estatus, estatus) where id = v_oc;
    end if;

    -- 4) marcar el documento
    update public.documentos set estado = 'cancelado' where id = p_documento_id;

    return jsonb_build_object(
        'documento_id', p_documento_id,
        'poliza_reversa_id', v_pol_rev,
        'movimientos', v_movs,
        'mensaje', format('Recibo #%s cancelado. Revertidos %s movimiento(s) de inventario%s.',
                          p_documento_id, v_n,
                          case when v_doc.poliza_id is not null then ' y cancelada su póliza' else '' end)
    );
end;
$$;

revoke all     on function public.cancelar_recibo_inventario(bigint, text) from public;
grant  execute on function public.cancelar_recibo_inventario(bigint, text) to authenticated;


-- ---------------------------------------------------------------------
-- 2. cancelar_poliza — no se puede cancelar un reverso
-- ---------------------------------------------------------------------
create or replace function public.cancelar_poliza(p_poliza_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_orig   public.polizas%rowtype;
    v_numero int;
    v_rev_id bigint;
    v_i      int := 0;
    m        public.poliza_movimientos%rowtype;
begin
    select * into v_orig from public.polizas where id = p_poliza_id;
    if not found then raise exception 'La poliza no existe.'; end if;
    if v_orig.estatus <> 'contabilizada' then
        raise exception 'Solo se puede cancelar una poliza contabilizada (estatus actual: %).', v_orig.estatus;
    end if;
    if v_orig.origen = 'ajuste' and v_orig.origen_tabla = 'polizas' then
        raise exception 'La poliza #% ya es un reverso (generado al cancelar la poliza #%). No se puede cancelar un reverso — revisa directamente la poliza original #% si necesitas deshacer esa cancelación.',
            v_orig.numero, v_orig.origen_id, v_orig.origen_id;
    end if;

    select coalesce(max(numero), 0) + 1 into v_numero
    from public.polizas
    where tipo = v_orig.tipo and extract(year from fecha) = extract(year from current_date);

    insert into public.polizas
        (fecha, tipo, numero, concepto, origen, origen_tabla, origen_id, poliza_reversa_id, moneda_id, tipo_cambio)
    values (
        current_date, v_orig.tipo, v_numero,
        'Cancelacion de poliza ' || v_orig.tipo || ' #' || v_orig.numero || coalesce(' - ' || p_motivo, ''),
        'ajuste', 'polizas', v_orig.id, v_orig.id, v_orig.moneda_id, v_orig.tipo_cambio
    )
    returning id into v_rev_id;

    for m in select * from public.poliza_movimientos where poliza_id = v_orig.id order by orden
    loop
        v_i := v_i + 1;
        insert into public.poliza_movimientos (poliza_id, orden, cuenta_id, cargo, abono, concepto, proveedor_id, cliente_id)
        values (v_rev_id, v_i, m.cuenta_id, m.abono, m.cargo,           -- invertido
                'Reverso: ' || coalesce(m.concepto, ''), m.proveedor_id, m.cliente_id);
    end loop;

    update public.polizas set estatus = 'cancelada' where id = v_orig.id;

    return jsonb_build_object('poliza_reversa_id', v_rev_id);
end;
$$;

revoke all     on function public.cancelar_poliza(bigint, text) from public;
grant  execute on function public.cancelar_poliza(bigint, text) to authenticated;


-- ---------------------------------------------------------------------
-- 5 y 6. contabilizar_compra — landed cost tomado de los lotes reales
--    + cargos no capitalizables clasificados por concepto
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

    -- cargos adicionales de la factura
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

    -- ---- CARGOS de inventario: se SUMA lo que de verdad quedó grabado en
    --      cada lote (ya con landed cost aplicado por rmAplicarLanded/
    --      registrar_movimiento_inventario_fifo), agrupado por la cuenta
    --      de inventario de cada producto. Ya no se re-reparte con una
    --      fórmula propia — así nunca se desvía por redondeo del auxiliar
    --      de lotes.
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
    -- por si algún renglón viejo no tiene lote enlazado (dato de antes de
    -- landed cost) y el total real no cuadra exacto con material+capitalizable:
    -- el último renglón absorbe la diferencia, igual que antes.
    if v_acum <> v_base_inv and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_base_inv - v_acum), 2))
        );
    end if;

    -- ---- cargos adicionales NO capitalizables -> cada concepto a su
    --      propia cuenta de gasto (ya no todo cae en 601.14 por default) ----
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

    -- guardar el desglose de cargos adicionales para trazabilidad
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
