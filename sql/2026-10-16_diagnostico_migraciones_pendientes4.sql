-- =====================================================================
--  Diagnóstico: ¿qué migraciones faltan por correr? (parte 4)
--  Fecha: 2026-10-16  ·  Proyecto: Hares de México (Supabase)
--
--  SOLO LECTURA — no modifica nada. Pégalo completo en Supabase -> SQL Editor.
--  Primera fila = resumen; cada fila "FALTA" es un archivo sin correr (o a medias).
--
--  Cubre lo que NO cubrían las partes 1-3 (2026-10-28, 2026-10-16, 2026-10-07c):
--  de 2026-10-07d a 2026-11-06 (series de pólizas, ODC formal, odc_generar,
--  prorrateo de depreciación, IVA de anticipo, equipos unificados, lote mínimo).
--  Las migraciones de un solo uso (08_fix_dias_credito_legacy, 14_ajuste_unico…)
--  se marcan "informativo": no hay forma confiable de saber si se corrieron.
-- =====================================================================
with c(orden, archivo, ok) as (
    values
    (1,  'sql/2026-10-07d_polizas_series_y_visto_bueno.sql',
         to_regclass('public.contadores_folios_poliza') is not null
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='polizas' and column_name='folio_poliza')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='pagos_proveedor' and column_name='visto_bueno_empleado_id')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name='solicitante_empleado_id')),

    (2,  'sql/2026-10-08_fix_dias_credito_legacy.sql (dias_credito debe ser NULLABLE)',
         exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra'
                  and column_name='dias_credito' and is_nullable='YES')),

    (3,  'sql/2026-10-09_odc_formal.sql (cotización, condiciones y anticipo en la ODC)',
         exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name like 'cotizacion%')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name='condicion_pago')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name='anticipo_pct')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='ordenes_compra' and column_name='anticipo_monto')),

    (4,  'sql/2026-10-09_recepcion_serie_rec.sql (serie REC en la recepción)',
         exists (select 1 from pg_proc where proname='contabilizar_compra' and prosrc like '%REC%')),

    (5,  'sql/2026-10-12_odc_generar.sql (odc_generar + candado ×1.30 en pagar_anticipo_oc)',
         exists (select 1 from pg_proc where proname='odc_generar')
         and exists (select 1 from pg_proc where proname='pagar_anticipo_oc' and prosrc like '%1.3%')),

    (6,  'sql/2026-10-13_series_polizas.sql (catálogo de series de pólizas)',
         to_regclass('public.polizas_series_origen') is not null),

    (7,  'sql/2026-10-13b_autor_registros_preparacion.sql (columna "Creó", sin prisa)',
         exists (select 1 from information_schema.columns where table_schema='public' and table_name='empleados' and column_name='usuario_id')
         and exists (select 1 from pg_proc where proname='autor_de')),

    (8,  'sql/2026-10-14_depreciacion_al_prorrateo.sql',
         to_regclass('public.activos_fijos_centros') is not null
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='gasto_aplicaciones' and column_name='depreciacion_id')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos_depreciaciones' and column_name='prorrateo_estatus')),

    (9,  'sql/2026-10-14b_iva_anticipo_recepcion.sql (IVA del anticipo a 118.01 en la recepción)',
         exists (select 1 from pg_proc where proname='contabilizar_compra' and prosrc like '%Con anticipo = 100%')),

    (10, 'sql/2026-10-14c_cxp_vence.sql (Vence: contado sin vencimiento)',
         exists (select 1 from pg_views where schemaname='public' and viewname='v_cuentas_por_pagar'
                  and definition like '%credito%' and definition like '%dias_credito%')),

    (11, 'sql/2026-10-15_equipos_unificados.sql (alta única de equipos en Activos fijos)',
         exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='depreciable')
         and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='potencia_kw')),

    (12, 'sql/2026-11-06_lote_minimo_fabricacion.sql',
         exists (select 1 from information_schema.columns where table_schema='public' and table_name='productos' and column_name='lote_minimo_fabricacion'))
)
select orden, case when ok then 'OK' else 'FALTA' end as estado, archivo
  from c
union all
select 0, case when bool_and(ok) then 'TODO AL DÍA' else 'HAY ' || count(*) filter (where not ok) || ' PENDIENTE(S)' end,
       'Resumen (revisa las filas FALTA)'
  from c
order by orden;
