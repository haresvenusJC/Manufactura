-- =====================================================================
--  registrar_salida_fifo: 'column reference "costo_unitario" is ambiguous'
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Idempotente (create or replace, misma firma -> conserva los grants).
--
--  Síntoma: al "Cerrar orden" de producción: "Error al descontar Glicerina
--  Vegetal Usp (FIFO): column reference "costo_unitario" is ambiguous".
--
--  Causa: la versión que está en la base (costeo PEPS estricto con cursor
--  de capas, cambiada fuera de este repo) abre el cursor con
--      SELECT id, stock_costeo, costo_unitario FROM public.lotes_inventario
--  sin alias, y la función devuelve RETURNS TABLE(... costo_unitario ...):
--  esa columna de salida es también una variable de PL/pgSQL, así que
--  Postgres no sabe si "costo_unitario" es la columna del lote o la variable.
--
--  Arreglo: el mismo cuerpo que está hoy en la base (copiado con
--  pg_get_functiondef el 2026-09-22), cambiando SOLO esa consulta para
--  calificar las columnas con alias (lc.). Nada más cambia.
-- =====================================================================

begin;

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
    v_total_stock_lotes numeric;
    v_criterio text;
    v_es_fefo boolean;

    -- costeo PEPS estricto, independiente del lote físico
    v_capa_cur refcursor;
    v_capa record;
    v_capa_id bigint;
    v_capa_resto numeric := 0;
    v_capa_costo numeric := 0;
    v_necesita numeric;
    v_tomar numeric;
    v_costo_acumulado numeric;
BEGIN
    SELECT stock_actual INTO v_stock_anterior_prod
    FROM public.productos
    WHERE id = p_producto_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto con ID % no existe.', p_producto_id;
    END IF;

    IF v_stock_anterior_prod < p_cantidad_salida THEN
        RAISE EXCEPTION 'Stock insuficiente en producto ID %. Solicitado: %, Disponible global: %', p_producto_id, p_cantidad_salida, v_stock_anterior_prod;
    END IF;

    -- cursor de capas de costo PEPS: siempre por fecha_ingreso, nunca se
    -- adelanta por caducidad (eso solo aplica a la selección física).
    -- (2026-09-22) columnas calificadas con "lc.": sin alias, "costo_unitario"
    -- chocaba con la columna de salida del mismo nombre (RETURNS TABLE).
    OPEN v_capa_cur FOR
        SELECT lc.id, lc.stock_costeo, lc.costo_unitario
        FROM public.lotes_inventario lc
        WHERE lc.producto_id = p_producto_id AND lc.stock_costeo > 0
        ORDER BY lc.fecha_ingreso ASC, lc.created_at ASC;

    FOR v_lote IN
        SELECT li.id, li.numero_lote, li.stock_actual, li.fecha_ingreso, li.created_at
        FROM public.lotes_inventario li
        WHERE li.producto_id = p_producto_id AND li.stock_actual > 0
        ORDER BY date_trunc('month', li.fecha_caducidad) ASC NULLS LAST,
                 li.fecha_ingreso ASC, li.created_at ASC
    LOOP
        EXIT WHEN v_cantidad_pendiente <= 0;

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

        UPDATE public.lotes_inventario
        SET stock_actual = stock_actual - v_a_descontar
        WHERE id = v_lote.id;

        -- costeo PEPS: cubrir v_a_descontar jalando de la cola de capas
        -- (puede abarcar más de una capa; el costo queda blend-eado).
        v_necesita := v_a_descontar;
        v_costo_acumulado := 0;
        WHILE v_necesita > 0 LOOP
            IF v_capa_resto <= 0 THEN
                FETCH v_capa_cur INTO v_capa;
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Error de consistencia PEPS: no hay suficientes capas de costo activas para el producto %.', p_producto_id;
                END IF;
                v_capa_id := v_capa.id;
                v_capa_resto := v_capa.stock_costeo;
                v_capa_costo := coalesce(v_capa.costo_unitario, 0);
            END IF;

            v_tomar := LEAST(v_necesita, v_capa_resto);
            v_costo_acumulado := v_costo_acumulado + v_tomar * v_capa_costo;
            UPDATE public.lotes_inventario SET stock_costeo = stock_costeo - v_tomar WHERE id = v_capa_id;
            v_capa_resto := v_capa_resto - v_tomar;
            v_necesita := v_necesita - v_tomar;
        END LOOP;

        -- Registrar el movimiento en el Kardex: lote_id = el que salió
        -- FÍSICAMENTE; costo_unitario = el que le tocó por la cola PEPS
        -- (pueden no coincidir con el costo propio de ese lote_id).
        INSERT INTO public.movimientos_inventario (
            producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante,
            costo_unitario, documento_id, lote_id, criterio_lote
        ) VALUES (
            p_producto_id, p_tipo_movimiento, -ABS(v_a_descontar),
            v_stock_anterior_prod, v_stock_anterior_prod - v_a_descontar,
            round(v_costo_acumulado / v_a_descontar, 4),
            p_documento_id, v_lote.id, v_criterio
        );

        lote_id := v_lote.id;
        numero_lote := v_lote.numero_lote;
        cantidad := v_a_descontar;
        costo_unitario := round(v_costo_acumulado / v_a_descontar, 4);
        RETURN NEXT;

    END LOOP;

    CLOSE v_capa_cur;

    IF v_cantidad_pendiente > 0 THEN
        RAISE EXCEPTION 'Error de consistencia: No hay suficientes lotes activos para descontar la cantidad total.';
    END IF;

    SELECT COALESCE(SUM(li.stock_actual), 0) INTO v_total_stock_lotes
    FROM public.lotes_inventario li
    WHERE li.producto_id = p_producto_id;

    v_stock_nuevo_prod := v_total_stock_lotes;

    UPDATE public.productos
    SET stock_actual = v_stock_nuevo_prod
    WHERE id = p_producto_id;

END;
$function$;

commit;
