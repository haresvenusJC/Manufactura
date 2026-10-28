-- =====================================================================
--  Diagnóstico: ¿qué migraciones faltan por correr? (parte 6)
--  Fecha: 2026-10-24  ·  Proyecto: Hares de México (Supabase)
--
--  SOLO LECTURA — no modifica nada. Pégalo completo en Supabase -> SQL Editor.
--  Primera fila = resumen; cada fila "FALTA" es un archivo sin correr (o a medias).
--
--  Cubre la cotización del proveedor con su unidad SAT y la requisición Resurtir / Compra nueva
--  (catálogos SAT, unidad SAT + factor por proveedor, ODC con cotización, requisición Resurtir).
--  Continúa a 2026-10-23_diagnostico_migraciones_pendientes5.sql.
--  Orden de ejecución de las que falten (los números de los archivos descargados):
--    01 estructura -> 02 datos_unidad -> 03..12 datos_prodserv_01..10 -> 13 vinculo_unidades
--    -> 14 (2026-10-23b) -> 15 (2026-10-23c) -> 16 (2026-10-24)
--  Nota: 2026-10-22g quedó reemplazada por 2026-10-23c (odc_generar completa); ya no se revisa.
-- =====================================================================
with n as (
    -- query_to_xml evita que falle el análisis cuando la tabla aún no existe.
    select
        case when to_regclass('public.c_clave_unidad') is not null
             then (xpath('/row/c/text()', query_to_xml('select count(*) as c from public.c_clave_unidad', false, true, '')))[1]::text::bigint else 0 end as unidades,
        case when to_regclass('public.c_clave_prod_serv') is not null
             then (xpath('/row/c/text()', query_to_xml('select count(*) as c from public.c_clave_prod_serv', false, true, '')))[1]::text::bigint else 0 end as prodserv
), c(orden, archivo, ok) as (
    select 1, '01 sql/2026-10-23_catalogos_sat_estructura.sql (tablas y buscadores SAT)',
        to_regclass('public.c_clave_unidad') is not null and to_regclass('public.c_clave_prod_serv') is not null
        and exists (select 1 from pg_proc where proname = 'sat_buscar_unidad')
        and exists (select 1 from pg_proc where proname = 'sat_buscar_prod_serv')
    union all
    select 2, '02 sql/2026-10-23_catalogos_sat_datos_unidad.sql (c_ClaveUnidad: ' || unidades || ' de 2,418 filas)', unidades >= 2418 from n
    union all
    select 3, '03-12 sql/2026-10-23_catalogos_sat_datos_prodserv_01..10.sql (c_ClaveProdServ: ' || prodserv || ' de 52,513 filas; si es parcial, falta alguna parte)', prodserv >= 52513 from n
    union all
    select 13, '13 sql/2026-10-23_catalogos_sat_vinculo_unidades.sql (unidades_medida.clave_sat)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='unidades_medida' and column_name='clave_sat')
    union all
    select 14, '14 sql/2026-10-23b_claves_proveedor_unidad_sat.sql (unidad SAT + factor en Claves de proveedor)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='producto_claves_proveedor' and column_name='clave_unidad_sat')
    union all
    select 15, '15 sql/2026-10-23c_odc_cotizacion_proveedor.sql (ODC con la cotización del proveedor)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra_detalle' and column_name='importe_proveedor')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name='diferencias_cotizacion')
        and exists (select 1 from pg_proc where proname = 'odc_generar' and prosrc like '%importe_proveedor%')
    union all
    select 16, '16 sql/2026-10-24_requisicion_resurtir.sql (requisición: Resurtir / Compra nueva)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='requisiciones_compra_detalle' and column_name='modo_captura')
)
select orden, case when ok then 'OK' else 'FALTA' end as estado, archivo
  from c
union all
select 0, case when bool_and(ok) then 'TODO AL DÍA' else 'HAY ' || count(*) filter (where not ok) || ' PENDIENTE(S)' end,
       'Resumen (revisa las filas FALTA)'
  from c
order by orden;
