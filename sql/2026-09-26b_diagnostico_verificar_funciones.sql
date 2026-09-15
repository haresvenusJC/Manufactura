-- =====================================================================
--  Diagnóstico (SOLO LECTURA): revisa el código de las funciones
--  REALMENTE instaladas en esta base y dice si tienen el bug o ya
--  están corregidas. No modifica nada — es seguro correrlo las veces
--  que quieras.
--  Fecha: 2026-09-26  ·  Proyecto: Hares de México (Supabase)
--
--  Úsalo ANTES de decidir si corres sql/2026-09-26_fix_unificado_costeo_recepcion.sql.
--  Pégalo tal cual en Supabase -> SQL Editor y corre. Verás 5 filas.
-- =====================================================================

select 'registrar_movimiento_inventario_fifo' as funcion,
    case
        when s is null then 'NO ENCONTRADA'
        when s ilike '%v_costo_aplicado := coalesce(p_costo_unitario, v_costo_aplicado)%' then 'CORREGIDA'
        else 'CON BUG'
    end as estado,
    case
        when s is null then 'La función no existe en esta base.'
        when s ilike '%v_costo_aplicado := coalesce(p_costo_unitario, v_costo_aplicado)%'
            then 'OK: el Kardex ya registra el costo real del lote en cada entrada.'
        else 'BUG: el Kardex muestra el costo VIEJO del producto en cada entrada, no el del lote recién recibido (no afecta dinero real, solo el reporte de Kardex).'
    end as detalle
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'registrar_movimiento_inventario_fifo' limit 1
))) t(s)

union all

select 'recibo_reversible',
    case
        when s is null then 'NO ENCONTRADA'
        when s ilike '%costeo_disponible%' then 'CORREGIDA'
        else 'CON BUG'
    end,
    case
        when s is null then 'La función no existe en esta base.'
        when s ilike '%costeo_disponible%'
            then 'OK: valida tanto stock_actual (físico) como stock_costeo (cola PEPS) antes de permitir revertir un recibo.'
        else 'BUG: solo valida stock_actual — puede dejar cancelar un recibo cuyo costo ya fue consumido por otra salida, rompiendo la cola de costeo PEPS.'
    end
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'recibo_reversible' limit 1
))) t(s)

union all

select 'cancelar_recibo_inventario',
    case
        when s is null then 'NO ENCONTRADA'
        when s ilike '%exception when others%' then 'CON BUG'
        when s ilike '%stock_costeo = greatest%' then 'CORREGIDA'
        else 'REVISAR MANUAL'
    end,
    case
        when s is null then 'La función no existe en esta base.'
        when s ilike '%exception when others%'
            then 'BUG: se traga CUALQUIER error al cancelar la póliza del recibo (no solo "ya estaba cancelada"), y no ajusta stock_costeo al revertir.'
        when s ilike '%stock_costeo = greatest%'
            then 'OK: ajusta stock_costeo al revertir y ya no se traga errores al cancelar la póliza.'
        else 'No calzó con ningún patrón conocido — revísala a mano.'
    end
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'cancelar_recibo_inventario' limit 1
))) t(s)

union all

select 'contabilizar_compra',
    case
        when s is null then 'NO ENCONTRADA'
        when s ilike '%v_reparto := round(v_base_inv%' then 'CON BUG'
        when s ilike '%li.costo_unitario * dd.cantidad%' then 'CORREGIDA'
        else 'REVISAR MANUAL'
    end,
    case
        when s is null then 'La función no existe en esta base.'
        when s ilike '%v_reparto := round(v_base_inv%'
            then 'BUG: reparte el cargo a inventario proporcional al subtotal (no al costo real por lote), y manda todos los cargos no capitalizables a una sola cuenta.'
        when s ilike '%li.costo_unitario * dd.cantidad%'
            then 'OK: reparte por el costo real grabado en cada lote y usa una cuenta por concepto (seguro/maniobras/aduana) para los cargos no capitalizables.'
        else 'No calzó con ningún patrón conocido — revísala a mano.'
    end
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'contabilizar_compra' limit 1
))) t(s)

union all

select 'editar_lineas_recepcion',
    case
        when s is null then 'NO ENCONTRADA (no has corrido 2026-09-25 todavía)'
        when s ilike '%stock_costeo%' then 'CORREGIDA'
        else 'CON BUG'
    end,
    case
        when s is null then 'La función no existe en esta base — instala primero sql/2026-09-25_editar_lineas_recepcion.sql.'
        when s ilike '%stock_costeo%'
            then 'OK: al editar una cantidad ya capturada, ajusta stock_costeo además de stock_actual.'
        else 'BUG: al editar una cantidad ya capturada, solo ajusta stock_actual — deja stock_costeo desincronizado.'
    end
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'editar_lineas_recepcion' limit 1
))) t(s);
