-- =====================================================================
--  Corrección unificada: repara 3 regresiones encontradas en la
--  auditoría del recorrido compra -> recepción -> inventario ->
--  producción, más un hueco nuevo en la edición de líneas de recepción.
--  Fecha: 2026-09-26  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere (en este orden): sql/2026-09-14c_costeo_peps_desacoplado_fefo.sql
--            sql/2026-09-20_landed_cost.sql
--            sql/2026-09-21_reversa_inventario_recibo.sql
--            sql/2026-09-25_editar_lineas_recepcion.sql
--
--  Por qué existe este archivo: varias migraciones posteriores a
--  2026-09-14c reescribieron por completo funciones que ya habían sido
--  corregidas, sin conocer la corrección previa, y sin querer las
--  revirtieron. Este archivo se corre AL FINAL (su fecha es la más
--  reciente) para que el simple orden alfabético/por fecha de los
--  archivos vuelva a producir el estado correcto, sin depender de
--  "Requiere" hacia adelante como quedó en 2026-09-14_fix_hallazgos_contabilidad.sql.
--
--  Qué corrige:
--
--  1. registrar_movimiento_inventario_fifo — el Kardex (movimientos_inventario)
--     volvía a mostrar el costo VIEJO del producto en cada ENTRADA en vez
--     del costo real aplicado al lote. Ya se había corregido en
--     sql/2026-09-10b_fix_kardex_costo_entrada.sql; sql/2026-09-13_salidas_fefo.sql
--     y sql/2026-09-14c_costeo_peps_desacoplado_fefo.sql reescribieron la
--     función entera para FEFO/PEPS partiendo de una copia sin ese fix.
--     El lote y la contabilidad siempre tuvieron el costo correcto; solo
--     el renglón del Kardex quedaba mal. Este archivo NO reescribe
--     históricos, solo corrige hacia adelante.
--
--  2. recibo_reversible / cancelar_recibo_inventario — sql/2026-09-21_reversa_inventario_recibo.sql
--     reescribió ambas funciones con la lógica ANTERIOR a 2026-09-14c,
--     perdiendo: (a) el chequeo de que stock_costeo (no solo stock_actual)
--     siga íntegro antes de permitir revertir un recibo — si otra salida
--     ya "cobró" de la capa de costo PEPS de este lote, revertir el
--     recibo rompería la cola de costeo de otras salidas ya
--     contabilizadas; (b) el ajuste de stock_costeo al cancelar (antes
--     solo tocaba stock_actual, dejando stock_costeo huérfano); y
--     (c) la corrección de "no tragar cualquier error al cancelar la
--     póliza" de sql/2026-09-14_fix_hallazgos_contabilidad.sql (volvía al
--     "exception when others then v_pol_rev := null").
--
--  3. contabilizar_compra — sql/2026-09-20_landed_cost.sql reescribió la
--     función citando como único requisito sql/2026-08-28_contabilidad_compras.sql
--     (sin conocer sql/2026-09-14_fix_hallazgos_contabilidad.sql) y volvió a:
--     repartir el cargo a inventario PROPORCIONALMENTE al subtotal
--     facturado (en vez de sumar el costo real grabado por lote), y
--     mandar TODOS los cargos no capitalizables a una sola cuenta default
--     (en vez de una cuenta por concepto: 601.61 seguro / 601.62 maniobras
--     / 601.63 aduana). Se restaura el reparto real + las cuentas por
--     concepto, conservando el soporte de costos_adicionales / landed
--     cost que agregó 2026-09-20.
--
--  4. editar_lineas_recepcion (2026-09-25, la función más nueva) corrige
--     lotes_inventario.stock_actual al editar una cantidad ya capturada,
--     pero nunca toca stock_costeo — mismo tipo de desincronización que
--     el punto 2, en código que nunca tuvo oportunidad de "romperse"
--     porque nunca estuvo arreglado. Se agrega el mismo ajuste simétrico
--     a stock_costeo, con su propio candado (no se puede bajar una línea
--     por debajo de lo que ya se consumió del costeo PEPS de ese lote).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. registrar_movimiento_inventario_fifo — fix Kardex costo en ENTRADA
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.registrar_movimiento_inventario_fifo(p_producto_id bigint, p_cantidad numeric, p_tipo_movimiento text, p_documento_id bigint, p_costo_unitario numeric DEFAULT NULL::numeric, p_numero_lote text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    v_naturaleza text;
    v_stock_anterior numeric;
    v_stock_nuevo numeric;
    v_cantidad_efectiva numeric;
    v_lote record;
    v_cantidad_pendiente numeric;
    v_a_descontar numeric;
    v_costo_aplicado numeric;
    v_total_lotes numeric;
    v_nuevo_lote_id bigint;
    v_algun_fefo boolean := false;
    v_criterio_mov text;
    v_es_fefo boolean;

    v_capa record;
    v_a_costear numeric;
    v_costo_total numeric;
begin
    -- 1. Determinar la naturaleza del movimiento desde el catálogo de tipos
    select naturaleza into v_naturaleza
    from public.tipos_movimiento
    where codigo = p_tipo_movimiento;

    if not found then
        if p_tipo_movimiento in ('entrada', 'entrada_compra', 'entrada_produccion') then
            v_naturaleza := 'entrada';
        elsif p_tipo_movimiento in ('merma', 'salida', 'salida_venta') then
            v_naturaleza := 'salida';
        else
            v_naturaleza := 'neutro';
        end if;
    end if;

    -- 2. Obtener stock global actual
    select coalesce(stock_actual, 0), coalesce(costo_unitario, 0)
    into v_stock_anterior, v_costo_aplicado
    from public.productos
    where id = p_producto_id;

    if not found then
        raise exception 'El producto con ID % no existe.', p_producto_id;
    end if;

    -- 3. Procesar según la naturaleza del movimiento
    if v_naturaleza in ('entrada', 'positivo') then
        -- ENTRADA: crea un lote nuevo con sus dos contadores iguales
        -- (stock_actual físico y stock_costeo para la cola PEPS).
        v_cantidad_efectiva := abs(p_cantidad);

        -- FIX (2026-09-26, reincorpora sql/2026-09-10b_fix_kardex_costo_entrada.sql):
        -- el Kardex debe registrar el costo REAL aplicado a este lote, no el
        -- costo anterior del producto. Se reasigna v_costo_aplicado ANTES del
        -- insert final a movimientos_inventario.
        v_costo_aplicado := coalesce(p_costo_unitario, v_costo_aplicado);

        insert into public.lotes_inventario (
            producto_id,
            numero_lote,
            stock_actual,
            stock_costeo,
            costo_unitario,
            fecha_ingreso,
            documento_id
        ) values (
            p_producto_id,
            coalesce(nullif(p_numero_lote, ''), 'LOTE-' || to_char(now(), 'YYYYMMDD-HH24MISS')),
            v_cantidad_efectiva,
            v_cantidad_efectiva,
            v_costo_aplicado,
            now(),
            p_documento_id
        )
        RETURNING id INTO v_nuevo_lote_id;

        if p_documento_id is not null then
            update public.documento_detalles
            set lote_id = v_nuevo_lote_id
            where documento_id = p_documento_id
              and producto_id = p_producto_id
              and lote_id is NULL;
        end if;

    elsif v_naturaleza in ('salida', 'negativo') then
        -- 3a. Descuento FÍSICO (equilibrio FEFO/FIFO por caducidad) —
        --     decide qué lote sale del almacén; YA NO decide el costo.
        v_cantidad_efectiva := -abs(p_cantidad);
        v_cantidad_pendiente := abs(p_cantidad);

        if v_stock_anterior < v_cantidad_pendiente then
            raise exception 'Stock insuficiente. Solicitado: %, Disponible global: %', v_cantidad_pendiente, v_stock_anterior;
        end if;

        for v_lote in
            select id, stock_actual, fecha_ingreso, created_at
            from public.lotes_inventario
            where producto_id = p_producto_id and stock_actual > 0
            order by date_trunc('month', fecha_caducidad) asc nulls last,
                     fecha_ingreso asc, created_at asc
        loop
            exit when v_cantidad_pendiente <= 0;

            select exists (
                select 1 from public.lotes_inventario o
                where o.producto_id = p_producto_id
                  and o.stock_actual > 0
                  and o.id <> v_lote.id
                  and (o.fecha_ingreso < v_lote.fecha_ingreso
                       or (o.fecha_ingreso = v_lote.fecha_ingreso and o.created_at < v_lote.created_at))
            ) into v_es_fefo;
            if v_es_fefo then v_algun_fefo := true; end if;

            if v_lote.stock_actual >= v_cantidad_pendiente then
                v_a_descontar := v_cantidad_pendiente;
                v_cantidad_pendiente := 0;
            else
                v_a_descontar := v_lote.stock_actual;
                v_cantidad_pendiente := v_cantidad_pendiente - v_a_descontar;
            end if;

            update public.lotes_inventario
            set stock_actual = stock_actual - v_a_descontar
            where id = v_lote.id;
        end loop;

        if v_cantidad_pendiente > 0 then
            raise exception 'Error de consistencia FIFO: No hay suficientes lotes con stock activo para cubrir la salida.';
        end if;

        v_criterio_mov := case when v_algun_fefo then 'FEFO' else 'FIFO' end;

        -- 3b. Costeo PEPS estricto (por fecha_ingreso) — decide QUÉ COSTO se
        --     aplica a la salida, independiente de qué lote salió físicamente.
        v_cantidad_pendiente := abs(p_cantidad);
        v_costo_total := 0;
        for v_capa in
            select id, stock_costeo, costo_unitario
            from public.lotes_inventario
            where producto_id = p_producto_id and stock_costeo > 0
            order by fecha_ingreso asc, created_at asc
        loop
            exit when v_cantidad_pendiente <= 0;

            if v_capa.stock_costeo >= v_cantidad_pendiente then
                v_a_costear := v_cantidad_pendiente;
                v_cantidad_pendiente := 0;
            else
                v_a_costear := v_capa.stock_costeo;
                v_cantidad_pendiente := v_cantidad_pendiente - v_a_costear;
            end if;

            v_costo_total := v_costo_total + v_a_costear * coalesce(v_capa.costo_unitario, 0);

            update public.lotes_inventario set stock_costeo = stock_costeo - v_a_costear where id = v_capa.id;
        end loop;

        if v_cantidad_pendiente > 0 then
            raise exception 'Error de consistencia PEPS: no hay suficientes capas de costo activas para cubrir la salida.';
        end if;

        v_costo_aplicado := round(v_costo_total / abs(p_cantidad), 4);
    else
        v_cantidad_efectiva := p_cantidad;
    end if;

    select coalesce(sum(stock_actual), 0) into v_total_lotes
    from public.lotes_inventario
    where producto_id = p_producto_id;

    v_stock_nuevo := v_total_lotes;

    update public.productos
    set stock_actual = v_stock_nuevo,
        costo_unitario = coalesce(p_costo_unitario, costo_unitario)
    where id = p_producto_id;

    insert into public.movimientos_inventario (
        producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante,
        costo_unitario, documento_id, lote_id, criterio_lote
    ) values (
        p_producto_id, p_tipo_movimiento, v_cantidad_efectiva, v_stock_anterior, v_stock_nuevo,
        v_costo_aplicado, p_documento_id, v_nuevo_lote_id, v_criterio_mov
    );
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. recibo_reversible — restaura el chequeo de stock_costeo (drop +
--    create porque cambia la forma de salida respecto a 2026-09-21)
-- ---------------------------------------------------------------------
drop function if exists public.recibo_reversible(bigint);

create function public.recibo_reversible(p_documento_id bigint)
returns table (
    producto_id        bigint,
    producto_nombre    text,
    lote_id            bigint,
    numero_lote        text,
    recibido           numeric,
    disponible         numeric,
    consumido          numeric,
    costeo_disponible  numeric,
    costeo_consumido   numeric,
    ok                 boolean
)
language sql
stable
security definer
set search_path = public, extensions
as $$
    with ent as (
        select mi.lote_id, mi.producto_id,
               coalesce(sum(mi.cantidad) filter (where mi.cantidad > 0), 0) as recibido
        from public.movimientos_inventario mi
        where mi.documento_id = p_documento_id
        group by mi.lote_id, mi.producto_id
    )
    select e.producto_id,
           p.nombre,
           e.lote_id,
           coalesce(l.numero_lote, '(sin lote)'),
           round(e.recibido, 4),
           round(coalesce(l.stock_actual, 0), 4),
           round(greatest(e.recibido - coalesce(l.stock_actual, 0), 0), 4),
           round(coalesce(l.stock_costeo, 0), 4),
           round(greatest(e.recibido - coalesce(l.stock_costeo, 0), 0), 4),
           (coalesce(l.stock_actual, 0) >= e.recibido - 0.0001
            and coalesce(l.stock_costeo, 0) >= e.recibido - 0.0001)
    from ent e
    join public.productos p on p.id = e.producto_id
    left join public.lotes_inventario l on l.id = e.lote_id
    where e.recibido > 0
    order by p.nombre;
$$;

grant execute on function public.recibo_reversible(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- 3. cancelar_recibo_inventario — restaura el ajuste de stock_costeo Y
--    el no-swallow-exception al cancelar la póliza
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

    -- guarda: nada del inventario recibido debe haberse consumido, ni
    -- físicamente (stock_actual) ni de la cola de costeo PEPS (stock_costeo)
    select string_agg(
             format('· %s lote %s: recibiste %s; físico disponible %s (consumido %s); costeo disponible %s (consumido %s)',
                    d.producto_nombre, d.numero_lote, d.recibido, d.disponible, d.consumido,
                    d.costeo_disponible, d.costeo_consumido), E'\n')
      into v_bloqueo
      from public.recibo_reversible(p_documento_id) d
     where not d.ok;
    if v_bloqueo is not null then
        raise exception E'No se puede revertir el inventario del recibo %: ya se consumió stock (físico o de costeo).\n%', p_documento_id, v_bloqueo;
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

    -- 2) revertir el inventario lote por lote (físico Y costeo)
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
               set stock_actual = greatest(coalesce(stock_actual, 0) - r.recibido, 0),
                   stock_costeo = greatest(coalesce(stock_costeo, 0) - r.recibido, 0)
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
-- 4. contabilizar_compra — restaura reparto real por lote + cuentas por
--    concepto en cargos no capitalizables (conserva costos_adicionales
--    / landed cost de sql/2026-09-20_landed_cost.sql)
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
    -- vía documento_detalles.lote_id) agrupado por cuenta de inventario —
    -- elimina el riesgo de que el auxiliar de lotes se desvíe por
    -- centavos del saldo de la cuenta 115.xx en la Balanza.
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

-- ---------------------------------------------------------------------
-- 5. editar_lineas_recepcion — agrega el mismo ajuste a stock_costeo
--    que ya aplica cancelar_recibo_inventario, con su propio candado
--
--    Se agrega también el catálogo 'ajuste_recepcion' aquí mismo (no
--    solo en sql/2026-09-25_editar_lineas_recepcion.sql) para que este
--    archivo no dependa de que esa migración se haya corrido antes —
--    movimientos_inventario.tipo_movimiento tiene FK a tipos_movimiento,
--    y sin este catálogo la función fallaría al usarse (mismo tipo de
--    bug que sql/2026-09-10_fix_tipos_movimiento_cancelacion_recibo.sql).
-- ---------------------------------------------------------------------
insert into public.tipos_movimiento (codigo, nombre, naturaleza)
values ('ajuste_recepcion', 'Ajuste de líneas de una recepción', 'neutro')
on conflict (codigo) do nothing;

create or replace function public.editar_lineas_recepcion(p_documento_id bigint, p_lineas jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    r            jsonb;
    v_det        public.documento_detalles%rowtype;
    v_lote       public.lotes_inventario%rowtype;
    v_cant_nueva numeric;
    v_costo_nuevo numeric;
    v_delta      numeric;
    v_stock_ant  numeric;
    v_stock_res  numeric;
    v_costeo_ant numeric;
    v_costeo_res numeric;
    v_oc         bigint;
    v_estatus    text;
    v_n          integer := 0;
    v_resultado  jsonb := '[]'::jsonb;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento % no existe.', p_documento_id; end if;
    if coalesce(v_doc.estado, '') = 'cancelado' then
        raise exception 'El documento % ya está cancelado.', p_documento_id;
    end if;
    if coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada') then
        raise exception 'Solo se pueden editar líneas de un recibo de compra (tipo actual: %).', coalesce(v_doc.tipo_movimiento, 'N/D');
    end if;
    if v_doc.poliza_id is not null then
        raise exception 'Esta recepción ya está contabilizada (póliza %). Cancélala primero (cancelar_recibo_inventario) si necesitas corregir cantidades o costos, y vuelve a capturarla.', v_doc.poliza_id;
    end if;

    if p_lineas is null or jsonb_typeof(p_lineas) <> 'array' or jsonb_array_length(p_lineas) < 1 then
        raise exception 'No se recibieron líneas para editar.';
    end if;

    v_oc := v_doc.orden_compra_id;

    for r in select * from jsonb_array_elements(p_lineas)
    loop
        select * into v_det
          from public.documento_detalles
         where id = (r->>'documento_detalle_id')::bigint
           and documento_id = p_documento_id;
        if not found then
            raise exception 'La línea % no pertenece a este documento.', r->>'documento_detalle_id';
        end if;

        v_cant_nueva := round(coalesce((r->>'cantidad')::numeric, v_det.cantidad), 4);
        v_costo_nuevo := round(coalesce((r->>'costo_unitario')::numeric, v_det.costo_unitario), 4);
        if v_cant_nueva < 0 then raise exception 'La cantidad de una línea no puede ser negativa.'; end if;
        if v_costo_nuevo < 0 then raise exception 'El costo de una línea no puede ser negativo.'; end if;

        v_delta := round(v_cant_nueva - coalesce(v_det.cantidad, 0), 4);

        if v_delta <> 0 then
            if v_det.lote_id is not null then
                select * into v_lote from public.lotes_inventario where id = v_det.lote_id;
                if not found then raise exception 'El lote de la línea % ya no existe.', v_det.id; end if;

                v_stock_ant := coalesce(v_lote.stock_actual, 0);
                v_stock_res := v_stock_ant + v_delta;
                if v_stock_res < -0.0001 then
                    raise exception 'No se puede reducir la línea % a %: ya se consumieron % (de % recibidas originalmente); el mínimo al que puedes bajarla es %.',
                        v_det.id, v_cant_nueva, round(coalesce(v_det.cantidad, 0) - v_stock_ant, 4), v_det.cantidad,
                        round(coalesce(v_det.cantidad, 0) - v_stock_ant, 4);
                end if;
                v_stock_res := greatest(v_stock_res, 0);

                -- FIX (2026-09-26): el mismo delta debe reflejarse en
                -- stock_costeo (cola de costeo PEPS), no solo en
                -- stock_actual — si no, este lote queda con más (o menos)
                -- "cantidad de costo disponible" que unidades físicas
                -- reales, y una salida futura podría costear de un lote
                -- que ya no tiene tanto inventario (o dejar cantidades
                -- fantasma sin costo asociado).
                v_costeo_ant := coalesce(v_lote.stock_costeo, 0);
                v_costeo_res := v_costeo_ant + v_delta;
                if v_costeo_res < -0.0001 then
                    raise exception 'No se puede reducir la línea % a %: ya se consumió % del costeo PEPS de este lote (quedan % disponibles); el mínimo al que puedes bajarla es %.',
                        v_det.id, v_cant_nueva, round(coalesce(v_det.cantidad, 0) - v_costeo_ant, 4), v_costeo_ant,
                        round(coalesce(v_det.cantidad, 0) - v_costeo_ant, 4);
                end if;
                v_costeo_res := greatest(v_costeo_res, 0);

                update public.lotes_inventario
                   set stock_actual = v_stock_res,
                       stock_costeo = v_costeo_res,
                       costo_unitario = v_costo_nuevo
                 where id = v_det.lote_id;

                update public.productos p
                   set stock_actual = (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = p.id)
                 where p.id = v_det.producto_id;
            else
                select coalesce(stock_actual, 0) into v_stock_ant from public.productos where id = v_det.producto_id;
                v_stock_res := v_stock_ant + v_delta;
                if v_stock_res < -0.0001 then
                    raise exception 'No se puede reducir la línea % a %: ya se consumió ese inventario (solo quedan % disponibles).',
                        v_det.id, v_cant_nueva, v_stock_ant;
                end if;
                v_stock_res := greatest(v_stock_res, 0);
                update public.productos set stock_actual = v_stock_res where id = v_det.producto_id;
            end if;

            insert into public.movimientos_inventario
                (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id, lote_id)
            values (
                v_det.producto_id, 'ajuste_recepcion', v_delta,
                v_stock_ant, v_stock_res, v_costo_nuevo, p_documento_id, v_det.lote_id
            );

            -- refleja el mismo delta en lo ya recibido de la orden de compra
            if v_oc is not null then
                update public.ordenes_compra_detalle ocd
                   set cantidad_recibida = greatest(coalesce(ocd.cantidad_recibida, 0) + v_delta, 0)
                 where ocd.orden_compra_id = v_oc and ocd.producto_id = v_det.producto_id;
            end if;
        elsif v_costo_nuevo <> coalesce(v_det.costo_unitario, 0) and v_det.lote_id is not null then
            -- solo cambió el costo, no la cantidad: igual se actualiza el costo del lote
            update public.lotes_inventario set costo_unitario = v_costo_nuevo where id = v_det.lote_id;
        end if;

        update public.documento_detalles
           set cantidad = v_cant_nueva, costo_unitario = v_costo_nuevo, subtotal = round(v_cant_nueva * v_costo_nuevo, 2)
         where id = v_det.id;

        v_n := v_n + 1;
        v_resultado := v_resultado || jsonb_build_object(
            'documento_detalle_id', v_det.id, 'cantidad_anterior', v_det.cantidad, 'cantidad_nueva', v_cant_nueva,
            'costo_anterior', v_det.costo_unitario, 'costo_nuevo', v_costo_nuevo);
    end loop;

    if v_oc is not null then
        select case
                 when bool_and(coalesce(cantidad_recibida, 0) >= coalesce(cantidad, 0)) then 'recibida'
                 when bool_and(coalesce(cantidad_recibida, 0) = 0) then 'abierta'
                 else 'recibida_parcial'
               end
          into v_estatus
          from public.ordenes_compra_detalle where orden_compra_id = v_oc;
        update public.ordenes_compra set estatus = coalesce(v_estatus, estatus) where id = v_oc;
    end if;

    return jsonb_build_object('documento_id', p_documento_id, 'lineas_editadas', v_n, 'detalle', v_resultado);
end $$;

revoke all     on function public.editar_lineas_recepcion(bigint, jsonb) from public, anon;
grant  execute on function public.editar_lineas_recepcion(bigint, jsonb) to authenticated;

commit;
