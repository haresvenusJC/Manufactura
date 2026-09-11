-- =====================================================================
--  Fix: el Kardex mostraba el costo VIEJO del producto en cada ENTRADA,
--  no el costo real que se aplicó a ese lote.
--  Fecha: 2026-09-10  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  registrar_movimiento_inventario_fifo (sql/2026-09-13_salidas_fefo.sql)
--  lee, al inicio, productos.costo_unitario en v_costo_aplicado (paso 2).
--  En la rama de ENTRADA, el LOTE nuevo sí se crea con el costo correcto
--  (coalesce(p_costo_unitario, v_costo_aplicado)), pero al final la
--  función inserta el renglon de movimientos_inventario usando
--  v_costo_aplicado *sin actualizar* — es decir, el costo del producto
--  ANTES de esta entrada, no el que de verdad se acaba de aplicar al lote.
--
--  Efecto: el lote y la contabilidad (documento_detalles, landed cost,
--  polizas) siempre tuvieron el costo correcto — el numero mal mostrado
--  vivia SOLO en movimientos_inventario.costo_unitario, es decir, solo
--  en lo que ve el Kardex. No hay que corregir dinero, solo el Kardex
--  hacia adelante (los renglones historicos quedan como estan, para no
--  reescribir el log).
--
--  Fix: en la rama de ENTRADA, v_costo_aplicado se actualiza al mismo
--  valor que ya se usa para el lote (coalesce(p_costo_unitario, ...))
--  antes de llegar al insert final.
--
--  Idempotente (CREATE OR REPLACE).
-- =====================================================================

begin;

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
begin
    -- 1. Determinar la naturaleza del movimiento desde tu catálogo de tipos
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
        -- ENTRADA: Crea un lote nuevo y enlaza directamente el documento_id
        v_cantidad_efectiva := abs(p_cantidad);

        -- FIX: el costo real aplicado a ESTA entrada (y a su lote) es
        -- p_costo_unitario cuando viene informado — antes, el Kardex
        -- (mas abajo) seguia usando el costo VIEJO del producto.
        v_costo_aplicado := coalesce(p_costo_unitario, v_costo_aplicado);

        insert into public.lotes_inventario (
            producto_id,
            numero_lote,
            stock_actual,
            costo_unitario,
            fecha_ingreso,
            documento_id -- Enlace nativo directo al documento de compra/producción
        ) values (
            p_producto_id,
            coalesce(nullif(p_numero_lote, ''), 'LOTE-' || to_char(now(), 'YYYYMMDD-HH24MISS')),
            v_cantidad_efectiva,
            v_costo_aplicado,
            now(),
            p_documento_id
        )
        RETURNING id INTO v_nuevo_lote_id;

        -- Actualizar también el documento_detalles si existe el registro para este documento y producto,
        -- asegurando la doble vía de relación (lote_id en documento_detalles).
        if p_documento_id is not null then
            update public.documento_detalles
            set lote_id = v_nuevo_lote_id
            where documento_id = p_documento_id
              and producto_id = p_producto_id
              and lote_id is NULL;
        end if;

    elsif v_naturaleza in ('salida', 'negativo') then
        -- SALIDA: Descuenta de los lotes activos con equilibrio FIFO/FEFO
        v_cantidad_efectiva := -abs(p_cantidad);
        v_cantidad_pendiente := abs(p_cantidad);

        if v_stock_anterior < v_cantidad_pendiente then
            raise exception 'Stock insuficiente. Solicitado: %, Disponible global: %', v_cantidad_pendiente, v_stock_anterior;
        end if;

        for v_lote in
            select id, stock_actual, costo_unitario, fecha_ingreso, created_at
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

            if v_lote.costo_unitario is not null and v_lote.costo_unitario > 0 then
                v_costo_aplicado := v_lote.costo_unitario;
            end if;

            update public.lotes_inventario
            set stock_actual = stock_actual - v_a_descontar
            where id = v_lote.id;
        end loop;

        if v_cantidad_pendiente > 0 then
            raise exception 'Error de consistencia FIFO: No hay suficientes lotes con stock activo para cubrir la salida.';
        end if;

        v_criterio_mov := case when v_algun_fefo then 'FEFO' else 'FIFO' end;

    else
        v_cantidad_efectiva := p_cantidad;
    end if;

    -- 4. Recalcular el stock global real sumando todos los lotes vigentes
    select coalesce(sum(stock_actual), 0) into v_total_lotes
    from public.lotes_inventario
    where producto_id = p_producto_id;

    v_stock_nuevo := v_total_lotes;

    -- 5. Actualizar la tabla productos
    update public.productos
    set stock_actual = v_stock_nuevo,
        costo_unitario = coalesce(p_costo_unitario, costo_unitario)
    where id = p_producto_id;

    -- 6. Registrar en el Kardex (movimientos_inventario)
    insert into public.movimientos_inventario (
        producto_id,
        tipo_movimiento,
        cantidad,
        stock_anterior,
        stock_resultante,
        costo_unitario,
        documento_id,
        lote_id, -- Asociar también el lote al movimiento de inventario si se creó uno nuevo
        criterio_lote
    ) values (
        p_producto_id,
        p_tipo_movimiento,
        v_cantidad_efectiva,
        v_stock_anterior,
        v_stock_nuevo,
        v_costo_aplicado,
        p_documento_id,
        v_nuevo_lote_id,
        v_criterio_mov
    );

end;
$function$;

commit;

-- =====================================================================
-- Los renglones historicos de ENTRADA que ya quedaron con el costo viejo
-- en el Kardex se pueden corregir opcionalmente (no afecta nada mas,
-- solo el numero que se ve en el Kardex) igualando movimientos_inventario
-- al costo real del lote que se le asocio:
--
-- update public.movimientos_inventario mi
-- set costo_unitario = li.costo_unitario
-- from public.lotes_inventario li
-- where mi.lote_id = li.id
--   and mi.tipo_movimiento in ('entrada', 'entrada_compra', 'entrada_produccion')
--   and mi.costo_unitario is distinct from li.costo_unitario;
-- =====================================================================
