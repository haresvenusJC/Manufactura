-- =====================================================================
--  Diagnóstico (SOLO LECTURA): confirma si _candados_cierre_periodo ya
--  incluye entrada_produccion/salida_produccion en el candado 1.
--  No modifica nada.
-- =====================================================================

select
    case
        when s is null then 'NO ENCONTRADA'
        when s ilike '%entrada_produccion%' and s ilike '%salida_produccion%' then 'CORREGIDA'
        else 'CON HUECO (todavía no revisa producción)'
    end as estado,
    case
        when s is null then 'La función _candados_cierre_periodo no existe en esta base.'
        when s ilike '%entrada_produccion%' and s ilike '%salida_produccion%'
            then 'OK: el candado 1 ya revisa entrada_produccion y salida_produccion, además de entrada_compra/salida_venta.'
        else 'El candado 1 solo revisa entrada_compra/salida_venta — producción sin contabilizar no se detecta antes de cerrar el mes.'
    end as detalle
from (select pg_get_functiondef((
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = '_candados_cierre_periodo' limit 1
))) t(s);
