-- =====================================================================
--  Diagnóstico: ¿ya se corrieron los SQL de Pedidos de venta,
--  Devoluciones, Activos fijos, Bancos y Tesorería, y los dos de datos
--  del proveedor por partida?
--  Fecha: 2026-10-06  ·  Proyecto: Hares de México (Supabase)
--
--  Es de SOLO LECTURA — no modifica nada. Pégalo completo en Supabase ->
--  SQL Editor y corre. Cada fila que diga "FALTA" es un archivo que
--  todavía no se ha corrido (o se corrió a medias).
-- =====================================================================

select 'sql/2026-09-30_factor_conversion_proveedor.sql' as archivo,
       case when exists (
           select 1 from information_schema.columns
            where table_schema = 'public' and table_name = 'producto_claves_proveedor' and column_name = 'factor_conversion'
       ) then 'OK' else 'FALTA' end as estatus

union all
select 'sql/2026-10-01_datos_proveedor_en_partidas.sql',
       case when exists (
           select 1 from information_schema.columns
            where table_schema = 'public' and table_name = 'requisiciones_compra_detalle' and column_name = 'sku_proveedor'
       ) and exists (
           select 1 from information_schema.columns
            where table_schema = 'public' and table_name = 'ordenes_compra_detalle' and column_name = 'sku_proveedor'
       ) then 'OK' else 'FALTA' end

union all
select 'sql/2026-10-02_activos_fijos.sql',
       case when exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'activos_fijos')
             and exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'activos_fijos_depreciaciones')
             and exists (select 1 from pg_proc where proname = 'depreciacion_aplicar')
             and exists (select 1 from public.cuentas_contables where codigo = '153.01')
       then 'OK' else 'FALTA' end

union all
select 'sql/2026-10-03_devoluciones.sql',
       case when exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'devoluciones_cliente')
             and exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'devoluciones_proveedor')
             and exists (select 1 from pg_proc where proname = 'registrar_devolucion_cliente')
             and exists (select 1 from pg_proc where proname = 'registrar_devolucion_proveedor')
       then 'OK' else 'FALTA' end

union all
select 'sql/2026-10-04_pedidos_venta.sql',
       case when exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'pedidos_venta')
             and exists (
                 select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'documentos' and column_name = 'pedido_venta_id'
             )
             and exists (select 1 from pg_proc where proname = 'pedido_venta_cancelar')
       then 'OK' else 'FALTA' end

union all
select 'sql/2026-10-05_bancos_tesoreria.sql',
       case when exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'cuentas_bancarias')
             and exists (
                 select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'poliza_movimientos' and column_name = 'conciliado'
             )
       then 'OK' else 'FALTA' end

order by 1;

-- =====================================================================
--  Extra: confirma que la bitácora ya cubre las 5 tablas nuevas
--  (activos_fijos, devoluciones_cliente, devoluciones_proveedor,
--  pedidos_venta, cuentas_bancarias) — parte de 2026-10-02 a 2026-10-05.
-- =====================================================================
select tgrelid::regclass::text as tabla, tgname as trigger
  from pg_trigger
 where tgname like 'trg_bitacora_%'
   and not tgisinternal
 order by 1;
