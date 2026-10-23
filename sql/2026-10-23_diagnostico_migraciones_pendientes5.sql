-- =====================================================================
--  Diagnóstico: ¿qué migraciones faltan por correr? (parte 5)
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  SOLO LECTURA — no modifica nada. Pégalo completo en Supabase -> SQL Editor.
--  Primera fila = resumen; cada fila "FALTA" es un archivo sin correr (o a medias).
--
--  Cubre las migraciones del 21 y 22 de octubre (activos fijos en compras, categorías
--  fiscales, código agrupador SAT, cuentas por tipo, apertura/baja de activos, redondeo de ODC).
--  Continúa a 2026-10-16_diagnostico_migraciones_pendientes4.sql.
--  Orden de ejecución recomendado de las que falten:
--    2026-10-21 -> 2026-10-22 -> 2026-10-22b -> 2026-10-22d -> 2026-10-22f -> 2026-10-22g
--  (2026-10-22c y 2026-10-22e son de solo lectura, no se "corren" para dejar nada.)
-- =====================================================================
with c(orden, archivo, ok) as (
    values
    (1, 'sql/2026-10-21_activo_fijo_en_compras.sql (tipo "activo_fijo" + alta automática del activo al recibir)',
        exists (select 1 from pg_proc where proname = '_alta_activos_desde_recepcion')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='documento_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='orden_compra_id')),

    (2, 'sql/2026-10-22_categorias_depreciacion_fiscal.sql (tabla c_categoria_depreciacion + % fiscal en el activo)',
        to_regclass('public.c_categoria_depreciacion') is not null
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='categoria_depreciacion_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='productos' and column_name='categoria_depreciacion_id')),

    (3, 'sql/2026-10-22b_codigo_agrupador_sat_2026.sql (código agrupador SAT: 152.01 -> 153.01)',
        exists (select 1 from public.cuentas_contables where codigo = '152.01' and codigo_agrupador = '153.01')),

    (4, 'sql/2026-10-22d_cuentas_depreciacion_por_tipo.sql (cuentas de activo/dep. acumulada/gasto por categoría)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='c_categoria_depreciacion' and column_name='cuenta_activo_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='c_categoria_depreciacion' and column_name='cuenta_gasto_cif_id')),

    (5, 'sql/2026-10-22f_activos_apertura_baja.sql (pólizas APE de apertura y BAJ de baja de activos)',
        exists (select 1 from pg_proc where proname = 'activo_fijo_apertura')
        and exists (select 1 from pg_proc where proname = 'activo_fijo_baja')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='activos_fijos' and column_name='poliza_apertura_id')),

    (6, 'sql/2026-10-22g_odc_importes_redondeo.sql (ODC: importe de cada partida redondeado a 2 decimales)',
        exists (select 1 from pg_proc where proname = 'odc_generar'
                 and prosrc like '%v_sub := v_sub + round((l->>''cantidad'')::numeric * (l->>''costo'')::numeric, 2)%'))
)
select orden, case when ok then 'OK' else 'FALTA' end as estado, archivo
  from c
union all
select 0, case when bool_and(ok) then 'TODO AL DÍA' else 'HAY ' || count(*) filter (where not ok) || ' PENDIENTE(S)' end,
       'Resumen (revisa las filas FALTA)'
  from c
order by orden;
