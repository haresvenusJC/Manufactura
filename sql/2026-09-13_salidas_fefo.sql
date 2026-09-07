-- =====================================================================
--  Salidas de inventario: equilibrio FIFO / FEFO + traza del criterio
--  Fecha: 2026-09-13  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Cambia el ORDER BY con el que se eligen los lotes al hacer una SALIDA
--  y deja registrado en el kardex qué criterio aplicó a cada lote.
--
--  Política de EQUILIBRIO (FEFO con tolerancia mensual):
--      order by date_trunc('month', fecha_caducidad) asc nulls last,
--               fecha_ingreso asc, created_at asc
--    · Lotes que caducan el MISMO mes  -> se consumen FIFO (por antigüedad).
--    · Un lote que caduca un mes ANTES -> se adelanta (FEFO), por convenir
--      a producción (evita merma por caducidad).
--    · Lotes sin caducidad             -> al final, FIFO.
--
--  Traza: movimientos_inventario.criterio_lote = 'FIFO' | 'FEFO' por cada
--  renglón de salida. 'FEFO' = ese lote se adelantó a otro más antiguo por
--  ingreso que caducaba después (o no caducaba).
--
--  Reemplaza dos funciones del esquema base SIN tocar su lógica de kardex
--  / costos / recálculo de stock. 'create or replace' conserva los grants.
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Columna de traza en el kardex
-- ---------------------------------------------------------------------
alter table public.movimientos_inventario
    add column if not exists criterio_lote text;

comment on column public.movimientos_inventario.criterio_lote is
  'En salidas por lote: FIFO (salió por antigüedad) o FEFO (se adelantó por caducidad, conviene a producción). NULL en entradas.';


-- ---------------------------------------------------------------------
-- 1. registrar_salida_fifo  ->  equilibrio FIFO/FEFO + criterio por lote
--    (idéntica a la versión previa salvo el ORDER BY y el sello de criterio)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.registrar_salida_fifo(p_producto_id bigint, p_cantidad_salida numeric, p_tipo_movimiento text, p_documento_id bigint, p_costo_unitario_fijo numeric DEFAULT NULL::numeric)
 RETURNS TABLE(lote_id bigint, numero_lote text, cantidad numeric, costo_unitario numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_lote record;
    v_cantidad_pendiente numeric := p_cantidad_salida;
    v_a_descontar numeric;
    v_stock_anterior_prod numeric;
    v_stock_nuevo_prod numeric;
    v_costo_aplicado numeric;
    v_total_stock_lotes numeric;
    v_criterio text;
    v_es_fefo boolean;
BEGIN
    -- 1. Obtener el stock actual global del producto
    SELECT stock_actual INTO v_stock_anterior_prod
    FROM public.productos
    WHERE id = p_producto_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto con ID % no existe.', p_producto_id;
    END IF;

    IF v_stock_anterior_prod < p_cantidad_salida THEN
        RAISE EXCEPTION 'Stock insuficiente en producto ID %. Solicitado: %, Disponible global: %', p_producto_id, p_cantidad_salida, v_stock_anterior_prod;
    END IF;

    -- 2. Recorrer los lotes activos con equilibrio FIFO/FEFO
    --    (mismo mes de caducidad -> FIFO; mes anterior -> FEFO; sin caducidad -> al final)
    FOR v_lote IN
        SELECT li.id, li.numero_lote, li.stock_actual, li.costo_unitario,
               li.fecha_ingreso, li.created_at
        FROM public.lotes_inventario li
        WHERE li.producto_id = p_producto_id AND li.stock_actual > 0
        ORDER BY date_trunc('month', li.fecha_caducidad) ASC NULLS LAST,
                 li.fecha_ingreso ASC, li.created_at ASC
    LOOP
        EXIT WHEN v_cantidad_pendiente <= 0;

        -- ¿este lote se está adelantando a otro más antiguo por ingreso
        --  que sigue con stock? -> salió por FEFO
        SELECT EXISTS (
            SELECT 1 FROM public.lotes_inventario o
            WHERE o.producto_id = p_producto_id
              AND o.stock_actual > 0
              AND o.id <> v_lote.id
              AND (o.fecha_ingreso < v_lote.fecha_ingreso
                   OR (o.fecha_ingreso = v_lote.fecha_ingreso AND o.created_at < v_lote.created_at))
        )
        INTO v_es_fefo;
        v_criterio := CASE WHEN v_es_fefo THEN 'FEFO' ELSE 'FIFO' END;

        IF v_lote.stock_actual >= v_cantidad_pendiente THEN
            v_a_descontar := v_cantidad_pendiente;
            v_cantidad_pendiente := 0;
        ELSE
            v_a_descontar := v_lote.stock_actual;
            v_cantidad_pendiente := v_cantidad_pendiente - v_a_descontar;
        END IF;

        -- Priorizar estrictamente el costo real del lote de compra
        v_costo_aplicado := COALESCE(v_lote.costo_unitario, p_costo_unitario_fijo, 0);

        -- Actualizar el stock del lote individual
        UPDATE public.lotes_inventario
        SET stock_actual = stock_actual - v_a_descontar
        WHERE id = v_lote.id;

        -- Registrar el movimiento en el Kardex por cada lote afectado individualmente
        INSERT INTO public.movimientos_inventario (
            producto_id,
            tipo_movimiento,
            cantidad,
            stock_anterior,
            stock_resultante,
            costo_unitario,
            documento_id,
            lote_id,
            criterio_lote
        ) VALUES (
            p_producto_id,
            p_tipo_movimiento,
            -ABS(v_a_descontar),
            v_stock_anterior_prod,
            v_stock_anterior_prod - v_a_descontar,
            v_costo_aplicado,
            p_documento_id,
            v_lote.id,
            v_criterio
        );

        -- Asignación explícita para evitar conflictos de nombres
        lote_id := v_lote.id;
        numero_lote := v_lote.numero_lote;
        cantidad := v_a_descontar;
        costo_unitario := v_costo_aplicado;
        RETURN NEXT;

    END LOOP;

    -- Si aún queda cantidad pendiente, error de consistencia
    IF v_cantidad_pendiente > 0 THEN
        RAISE EXCEPTION 'Error de consistencia: No hay suficientes lotes activos para descontar la cantidad total.';
    END IF;

    -- 3. Calcular el stock global real sumando todos los lotes restantes
    SELECT COALESCE(SUM(li.stock_actual), 0) INTO v_total_stock_lotes
    FROM public.lotes_inventario li
    WHERE li.producto_id = p_producto_id;

    v_stock_nuevo_prod := v_total_stock_lotes;

    -- 4. Actualizar la tabla productos con el nuevo stock real
    UPDATE public.productos
    SET stock_actual = v_stock_nuevo_prod
    WHERE id = p_producto_id;

END;
$function$;


-- ---------------------------------------------------------------------
-- 2. registrar_movimiento_inventario_fifo  ->  rama de SALIDA con equilibrio
--    (idéntica salvo el ORDER BY del loop y el sello de criterio en el kardex)
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
            coalesce(p_costo_unitario, v_costo_aplicado),
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
