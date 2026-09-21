-- =====================================================================
--  Diagnóstico: ¿qué migraciones recientes faltan por correr?
--  Fecha: 2026-10-16  ·  Proyecto: Hares de México (Supabase)
--
--  Es de SOLO LECTURA — no modifica nada. Pégalo completo en Supabase ->
--  SQL Editor y corre. La primera fila es el resumen; cada fila "FALTA"
--  es un archivo que todavía no se ha corrido (o se corrió a medias).
--
--  Cubre de 2026-09-24 a 2026-10-15. Corre los que digan FALTA en el
--  orden en que aparecen (van por fecha).
--
--  Nota: 2026-10-14 (ajuste único del IVA de OC-966924) se marca OK solo
--  si ya existe esa póliza contabilizada. Si después la cancelas, volverá
--  a decir FALTA.
-- =====================================================================

with c(orden, archivo, ok) as (
    values
    (1,  'sql/2026-09-24_validador_piezas_prerecibo.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pre_recibos' and column_name = 'lineas')),

    (2,  'sql/2026-09-29_requisiciones_compra.sql',
         to_regclass('public.requisiciones_compra') is not null
         and exists (select 1 from pg_proc where proname = 'requisicion_autorizar')),

    (3,  'sql/2026-09-30_factor_conversion_proveedor.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'producto_claves_proveedor' and column_name = 'factor_conversion')),

    (4,  'sql/2026-10-01_datos_proveedor_en_partidas.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'requisiciones_compra_detalle' and column_name = 'sku_proveedor')
         and exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'ordenes_compra_detalle' and column_name = 'sku_proveedor')),

    (5,  'sql/2026-10-02_activos_fijos.sql',
         to_regclass('public.activos_fijos') is not null
         and exists (select 1 from pg_proc where proname = 'depreciacion_aplicar')),

    (6,  'sql/2026-10-03_devoluciones.sql',
         to_regclass('public.devoluciones_cliente') is not null
         and to_regclass('public.devoluciones_proveedor') is not null
         and exists (select 1 from pg_proc where proname = 'registrar_devolucion_cliente')
         and exists (select 1 from pg_proc where proname = 'registrar_devolucion_proveedor')),

    (7,  'sql/2026-10-04_pedidos_venta.sql',
         to_regclass('public.pedidos_venta') is not null
         and exists (select 1 from information_schema.columns
                      where table_schema = 'public' and table_name = 'documentos' and column_name = 'pedido_venta_id')),

    (8,  'sql/2026-10-05_bancos_tesoreria.sql',
         to_regclass('public.cuentas_bancarias') is not null
         and exists (select 1 from information_schema.columns
                      where table_schema = 'public' and table_name = 'poliza_movimientos' and column_name = 'conciliado')),

    (9,  'sql/2026-10-07_candado_diferencia_fisica_factura.sql (tolerancia $5 en contabilizar_compra)',
         exists (select 1 from pg_proc where proname = 'contabilizar_compra' and prosrc like '%v_tolerancia%')),

    (10, 'sql/2026-10-08_devoluciones_iva.sql (IVA en devoluciones)',
         exists (select 1 from pg_proc where proname = 'registrar_devolucion_cliente'   and prosrc like '%v_tasa_iva%')
         and exists (select 1 from pg_proc where proname = 'registrar_devolucion_proveedor' and prosrc like '%v_tasa_iva%')),

    (11, 'sql/2026-10-09_prerecibo_candado_editar_cancelar.sql',
         exists (select 1 from pg_constraint
                  where conrelid = 'public.pre_recibos'::regclass
                    and conname = 'pre_recibos_estatus_check'
                    and pg_get_constraintdef(oid) like '%cancelado%')
         and exists (select 1 from pg_proc where proname = 'prerecibo_editar')
         and exists (select 1 from pg_trigger where tgname = 'trg_candado_recibo_prerecibo' and not tgisinternal)),

    (12, 'sql/2026-10-10_prerecibo_oc_ya_capturada.sql (v_recibo_ocs)',
         exists (select 1 from pg_views
                  where schemaname = 'public' and viewname = 'v_recibo_ocs' and definition like '%pre_recibos%')),

    (13, 'sql/2026-10-11_requisicion_cancelar.sql',
         exists (select 1 from pg_proc where proname = 'requisicion_cancelar')),

    (14, 'sql/2026-10-12_sugerido_pedir_entero.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'unidades_medida' and column_name = 'es_fraccionable')),

    (15, 'sql/2026-10-13_pago_reclasifica_iva.sql',
         exists (select 1 from pg_proc where proname = 'registrar_pago_proveedor' and prosrc like '%v_cta118%')),

    (16, 'sql/2026-10-14_ajuste_unico_iva_oc966924.sql (ajuste único, se corre una sola vez)',
         exists (select 1 from public.polizas
                  where concepto = 'Ajuste único: reclasifica IVA pagado OC-966924' and estatus = 'contabilizada')),

    (17, 'sql/2026-10-15_productos_clave_sat.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'productos' and column_name = 'clave_sat'))
)
select archivo, estatus
  from (
      select 0 as ord,
             '>>> RESUMEN: faltan ' || count(*) filter (where not ok) || ' de ' || count(*) || ' migraciones' as archivo,
             case when count(*) filter (where not ok) = 0 then 'TODO AL DÍA' else 'REVISAR' end as estatus
        from c
      union all
      select orden, archivo, case when ok then 'OK' else 'FALTA' end from c
  ) t
 order by ord;
