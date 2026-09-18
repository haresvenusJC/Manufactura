-- =====================================================================
--  Devoluciones: ahora sí reflejan IVA (subtotal / IVA / total)
--  Fecha: 2026-10-08  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  sql/2026-10-03_devoluciones.sql dejó una simplificación consciente:
--  la devolución solo revertía inventario + el neto (sin IVA). Eso deja
--  mal la cuenta de IVA: si el cliente te regresa algo que pagó con IVA,
--  el "IVA trasladado" (209.01/209.02) que ya reconociste sigue de alta
--  aunque ya no vas a cobrar (ni le vas a deber a SAT) ese impuesto sobre
--  lo devuelto. Simétrico para devolución a proveedor con "IVA
--  acreditable" (118.01/119.01): si regresas mercancía, ya no te
--  corresponde acreditar el IVA de lo que regresaste.
--
--  Cambios:
--  · Devolución de cliente: la tasa de IVA se toma de productos.tasa_iva
--    (no se captura a mano). Cargo 402.01 sigue siendo el SUBTOTAL;
--    se agrega Cargo <209.01/209.02 IVA trasladado> por el IVA; el
--    Abono a 105.01 Clientes ahora es el TOTAL (subtotal + IVA) — es lo
--    que de verdad se le regresa/deja de cobrar al cliente.
--  · Devolución a proveedor: mismo criterio con IVA acreditable
--    (118.01 contado / 119.01 crédito). Cargo a 201.01 Proveedores ahora
--    es el TOTAL; Abono a IVA acreditable por el IVA además del Abono a
--    inventario por el subtotal.
--  · Ambas funciones ahora guardan subtotal/iva/total en el documento
--    generado (documentos.subtotal/iva/total) — con eso, la vista
--    Documentos ya los muestra igual que a compras/ventas.
--  · Nuevo parámetro opcional p_datos.condicion ('contado'|'credito')
--    para elegir la cuenta correcta de IVA; si no se manda, cliente usa
--    'contado' y proveedor usa 'credito' (mismos defaults que
--    contabilizar_venta / contabilizar_compra).
--
--  Idempotente.
-- =====================================================================

begin;

-- =====================================================================
--  1. Devolución de cliente
-- =====================================================================
create or replace function public.registrar_devolucion_cliente(p_datos jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_fecha         date := coalesce((p_datos->>'fecha')::date, current_date);
    v_cliente_id    bigint := (p_datos->>'cliente_id')::bigint;
    v_condicion     text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'contado');
    v_partidas      jsonb := coalesce(p_datos->'partidas', '[]'::jsonb);
    v_folio         text;
    v_devolucion_id bigint;
    v_documento_id  bigint;
    v_p             record;
    v_lote_id       bigint;
    v_subtotal      numeric(14,2) := 0;
    v_iva           numeric(14,2) := 0;
    v_total         numeric(14,2) := 0;
    v_total_costo   numeric(14,2) := 0;
    v_movs          jsonb := '[]'::jsonb;
    v_costo_por_cta jsonb := '{}'::jsonb;
    v_cta_inv       bigint;
    v_tasa_iva      numeric;
    v_iva_partida   numeric(14,2);
    v_cta_dev       bigint := public._cuenta_id('402.01');
    v_cta_cli       bigint := public._cuenta_id('105.01');
    v_cta_costo     bigint := public._cuenta_id('501.01');
    v_cta_iva       bigint;
    v_poliza        jsonb;
    v_poliza_id     bigint;
    v_stock_prod    numeric;
    v_key           text;
begin
    if jsonb_array_length(v_partidas) = 0 then raise exception 'La devolución no tiene partidas.'; end if;
    if v_cta_dev is null then raise exception 'Falta la cuenta 402.01 (Devoluciones sobre ventas) en el plan de cuentas.'; end if;
    if v_cta_cli is null then raise exception 'Falta la cuenta 105.01 (Clientes) en el plan de cuentas.'; end if;
    if v_cta_costo is null then raise exception 'Falta la cuenta 501.01 (Costo de venta) en el plan de cuentas.'; end if;
    if v_condicion not in ('contado', 'credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    v_folio := 'DEVCLI-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('devolucion_cliente', v_folio, v_fecha, coalesce(nullif(trim(p_datos->>'notas'), ''), 'Devolución de cliente'), 'completado')
    returning id into v_documento_id;

    insert into public.devoluciones_cliente (folio, fecha, cliente_id, documento_venta_id, documento_id, motivo, notas)
    values (v_folio, v_fecha, v_cliente_id, (p_datos->>'documento_venta_id')::bigint, v_documento_id,
            nullif(trim(p_datos->>'motivo'), ''), nullif(trim(p_datos->>'notas'), ''))
    returning id into v_devolucion_id;

    for v_p in select * from jsonb_to_recordset(v_partidas) as x(
        producto_id bigint, cantidad numeric, costo_unitario numeric, precio_unitario numeric, unidad_medida_id bigint)
    loop
        if v_p.producto_id is null or v_p.cantidad is null or v_p.cantidad <= 0 then
            raise exception 'Cada partida necesita producto y cantidad mayor a 0.';
        end if;

        insert into public.lotes_inventario (producto_id, numero_lote, fecha_ingreso, stock_actual, stock_costeo, costo_unitario_final, documento_id)
        values (v_p.producto_id, 'DEV-' || v_devolucion_id || '-' || v_p.producto_id, v_fecha,
                v_p.cantidad, v_p.cantidad, coalesce(v_p.costo_unitario, 0), v_documento_id)
        returning id into v_lote_id;

        insert into public.devoluciones_cliente_detalle
            (devolucion_id, producto_id, cantidad, costo_unitario, precio_unitario, unidad_medida_id, lote_nuevo_id)
        values (v_devolucion_id, v_p.producto_id, v_p.cantidad, coalesce(v_p.costo_unitario, 0), coalesce(v_p.precio_unitario, 0), v_p.unidad_medida_id, v_lote_id);

        select coalesce(stock_actual, 0) into v_stock_prod from public.productos where id = v_p.producto_id;
        update public.productos set stock_actual = v_stock_prod + v_p.cantidad where id = v_p.producto_id;

        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        values (v_p.producto_id, 'devolucion_cliente', v_p.cantidad, v_stock_prod, v_stock_prod + v_p.cantidad, coalesce(v_p.costo_unitario, 0), v_documento_id);

        select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.04')), coalesce(pr.tasa_iva, 0)
          into v_cta_inv, v_tasa_iva
          from public.productos pr where pr.id = v_p.producto_id;

        v_subtotal := v_subtotal + (v_p.cantidad * coalesce(v_p.precio_unitario, 0));
        v_iva_partida := round(v_p.cantidad * coalesce(v_p.precio_unitario, 0) * v_tasa_iva, 2);
        v_iva := v_iva + v_iva_partida;
        v_total_costo := v_total_costo + (v_p.cantidad * coalesce(v_p.costo_unitario, 0));

        v_key := v_cta_inv::text;
        v_costo_por_cta := jsonb_set(v_costo_por_cta, array[v_key],
            to_jsonb(coalesce((v_costo_por_cta->>v_key)::numeric, 0) + (v_p.cantidad * coalesce(v_p.costo_unitario, 0))));
    end loop;

    if v_subtotal <= 0 then raise exception 'El importe de la devolución debe ser mayor a 0.'; end if;
    v_total := round(v_subtotal + v_iva, 2);

    v_movs := v_movs || jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_dev, 'cargo', v_subtotal, 'abono', 0, 'concepto', 'Devolución cliente ' || v_folio, 'cliente_id', v_cliente_id)
    );

    if v_iva > 0 then
        v_cta_iva := public._cuenta_id(case when v_condicion = 'contado' then '209.01' else '209.02' end);
        if v_cta_iva is null then raise exception 'Falta la cuenta % (IVA trasladado) en el plan de cuentas.',
            case when v_condicion = 'contado' then '209.01' else '209.02' end; end if;
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_iva, 'cargo', v_iva, 'abono', 0, 'concepto', 'Devolución cliente ' || v_folio || ' — revierte IVA trasladado')
        );
    end if;

    v_movs := v_movs || jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_cli, 'cargo', 0, 'abono', v_total, 'concepto', 'Devolución cliente ' || v_folio, 'cliente_id', v_cliente_id)
    );

    if v_total_costo > 0 then
        for v_key in select jsonb_object_keys(v_costo_por_cta) loop
            v_movs := v_movs || jsonb_build_array(
                jsonb_build_object('cuenta_id', v_key::bigint, 'cargo', (v_costo_por_cta->>v_key)::numeric, 'abono', 0,
                                    'concepto', 'Devolución cliente ' || v_folio || ' — regresa a inventario')
            );
        end loop;
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_costo, 'cargo', 0, 'abono', v_total_costo, 'concepto', 'Devolución cliente ' || v_folio || ' — revierte costo de venta')
        );
    end if;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Diario', 'concepto', 'Devolución de cliente ' || v_folio,
        'origen', 'devolucion_cliente', 'origen_tabla', 'devoluciones_cliente', 'origen_id', v_devolucion_id,
        'movimientos', v_movs
    ));
    v_poliza_id := (v_poliza->>'poliza_id')::bigint;
    update public.devoluciones_cliente set poliza_id = v_poliza_id where id = v_devolucion_id;
    update public.documentos set subtotal = v_subtotal, iva = v_iva, total = v_total where id = v_documento_id;

    return jsonb_build_object('devolucion_id', v_devolucion_id, 'documento_id', v_documento_id, 'poliza_id', v_poliza_id,
        'subtotal', v_subtotal, 'iva', v_iva, 'total', v_total, 'total_venta', v_subtotal, 'total_costo', v_total_costo);
end;
$$;

grant execute on function public.registrar_devolucion_cliente(jsonb) to authenticated;

-- =====================================================================
--  2. Devolución a proveedor
-- =====================================================================
create or replace function public.registrar_devolucion_proveedor(p_datos jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_fecha         date := coalesce((p_datos->>'fecha')::date, current_date);
    v_proveedor_id  bigint := (p_datos->>'proveedor_id')::bigint;
    v_condicion     text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'credito');
    v_partidas      jsonb := coalesce(p_datos->'partidas', '[]'::jsonb);
    v_folio         text;
    v_devolucion_id bigint;
    v_documento_id  bigint;
    v_p             record;
    v_lote          record;
    v_subtotal      numeric(14,2) := 0;
    v_iva           numeric(14,2) := 0;
    v_total         numeric(14,2) := 0;
    v_movs          jsonb := '[]'::jsonb;
    v_costo_por_cta jsonb := '{}'::jsonb;
    v_cta_inv       bigint;
    v_tasa_iva      numeric;
    v_cta_prov      bigint := public._cuenta_id('201.01');
    v_cta_iva       bigint;
    v_poliza        jsonb;
    v_poliza_id     bigint;
    v_stock_prod    numeric;
    v_key           text;
    v_costo         numeric;
begin
    if jsonb_array_length(v_partidas) = 0 then raise exception 'La devolución no tiene partidas.'; end if;
    if v_cta_prov is null then raise exception 'Falta la cuenta 201.01 (Proveedores) en el plan de cuentas.'; end if;
    if v_condicion not in ('contado', 'credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    v_folio := 'DEVPROV-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('devolucion_proveedor', v_folio, v_fecha, coalesce(nullif(trim(p_datos->>'notas'), ''), 'Devolución a proveedor'), 'completado')
    returning id into v_documento_id;

    insert into public.devoluciones_proveedor (folio, fecha, proveedor_id, documento_compra_id, documento_id, motivo, notas)
    values (v_folio, v_fecha, v_proveedor_id, (p_datos->>'documento_compra_id')::bigint, v_documento_id,
            nullif(trim(p_datos->>'motivo'), ''), nullif(trim(p_datos->>'notas'), ''))
    returning id into v_devolucion_id;

    for v_p in select * from jsonb_to_recordset(v_partidas) as x(
        producto_id bigint, lote_id bigint, cantidad numeric, unidad_medida_id bigint)
    loop
        if v_p.producto_id is null or v_p.lote_id is null or v_p.cantidad is null or v_p.cantidad <= 0 then
            raise exception 'Cada partida necesita producto, lote y cantidad mayor a 0.';
        end if;

        select * into v_lote from public.lotes_inventario where id = v_p.lote_id for update;
        if v_lote is null then raise exception 'El lote % no existe.', v_p.lote_id; end if;
        if v_lote.stock_actual < v_p.cantidad or v_lote.stock_costeo < v_p.cantidad then
            raise exception 'El lote % (%) no tiene suficiente stock para devolver % — disponible físico %, disponible costeo %.',
                v_lote.numero_lote, v_p.producto_id, v_p.cantidad, v_lote.stock_actual, v_lote.stock_costeo;
        end if;

        update public.lotes_inventario set stock_actual = stock_actual - v_p.cantidad, stock_costeo = stock_costeo - v_p.cantidad
         where id = v_p.lote_id;

        v_costo := coalesce(v_lote.costo_unitario_final, 0);

        insert into public.devoluciones_proveedor_detalle (devolucion_id, producto_id, lote_id, cantidad, costo_unitario, unidad_medida_id)
        values (v_devolucion_id, v_p.producto_id, v_p.lote_id, v_p.cantidad, v_costo, v_p.unidad_medida_id);

        select coalesce(stock_actual, 0) into v_stock_prod from public.productos where id = v_p.producto_id;
        update public.productos set stock_actual = greatest(0, v_stock_prod - v_p.cantidad) where id = v_p.producto_id;

        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        values (v_p.producto_id, 'devolucion_proveedor', -v_p.cantidad, v_stock_prod, greatest(0, v_stock_prod - v_p.cantidad), v_costo, v_documento_id);

        select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.01')), coalesce(pr.tasa_iva, 0)
          into v_cta_inv, v_tasa_iva
          from public.productos pr where pr.id = v_p.producto_id;

        v_subtotal := v_subtotal + (v_p.cantidad * v_costo);
        v_iva := v_iva + round(v_p.cantidad * v_costo * v_tasa_iva, 2);

        v_key := v_cta_inv::text;
        v_costo_por_cta := jsonb_set(v_costo_por_cta, array[v_key],
            to_jsonb(coalesce((v_costo_por_cta->>v_key)::numeric, 0) + (v_p.cantidad * v_costo)));
    end loop;

    if v_subtotal <= 0 then raise exception 'El importe de la devolución debe ser mayor a 0.'; end if;
    v_total := round(v_subtotal + v_iva, 2);

    v_movs := v_movs || jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_prov, 'cargo', v_total, 'abono', 0, 'concepto', 'Devolución a proveedor ' || v_folio, 'proveedor_id', v_proveedor_id)
    );
    for v_key in select jsonb_object_keys(v_costo_por_cta) loop
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_key::bigint, 'cargo', 0, 'abono', (v_costo_por_cta->>v_key)::numeric,
                                'concepto', 'Devolución a proveedor ' || v_folio || ' — sale de inventario')
        );
    end loop;

    if v_iva > 0 then
        v_cta_iva := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_cta_iva is null then raise exception 'Falta la cuenta % (IVA acreditable) en el plan de cuentas.',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_iva, 'cargo', 0, 'abono', v_iva, 'concepto', 'Devolución a proveedor ' || v_folio || ' — revierte IVA acreditable')
        );
    end if;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Diario', 'concepto', 'Devolución a proveedor ' || v_folio,
        'origen', 'devolucion_proveedor', 'origen_tabla', 'devoluciones_proveedor', 'origen_id', v_devolucion_id,
        'movimientos', v_movs
    ));
    v_poliza_id := (v_poliza->>'poliza_id')::bigint;
    update public.devoluciones_proveedor set poliza_id = v_poliza_id where id = v_devolucion_id;
    update public.documentos set subtotal = v_subtotal, iva = v_iva, total = v_total where id = v_documento_id;

    return jsonb_build_object('devolucion_id', v_devolucion_id, 'documento_id', v_documento_id, 'poliza_id', v_poliza_id,
        'subtotal', v_subtotal, 'iva', v_iva, 'total', v_total);
end;
$$;

grant execute on function public.registrar_devolucion_proveedor(jsonb) to authenticated;

commit;
