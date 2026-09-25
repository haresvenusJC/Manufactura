-- =====================================================================
--  Diagnóstico: ¿qué migraciones recientes faltan por correr? (parte 2)
--  Fecha: 2026-10-28  ·  Proyecto: Hares de México (Supabase)
--
--  Es de SOLO LECTURA — no modifica nada. Pégalo completo en Supabase ->
--  SQL Editor y corre. La primera fila es el resumen; cada fila "FALTA"
--  es un archivo que todavía no se ha corrido (o se corrió a medias).
--
--  Continúa a sql/2026-10-16_diagnostico_migraciones_pendientes.sql
--  (esa cubre hasta 2026-10-15). Esta cubre de 2026-09-24c en adelante.
--  Corre los que digan FALTA en el orden en que aparecen (van por fecha).
-- =====================================================================

with c(orden, archivo, ok) as (
    values
    (1,  'sql/2026-09-24c_accesos_directos_usuario.sql',
         to_regclass('public.accesos_directos_usuario') is not null),

    (2,  'sql/2026-09-23d_rendimiento_real_orden.sql (opcional)',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'ordenes_produccion' and column_name = 'cantidad_planeada')),

    (3,  'sql/2026-10-21_folios_consecutivos.sql',
         exists (select 1 from pg_proc where proname = 'siguiente_folio')),

    (5,  'sql/2026-10-23_densidad_conversion_bom.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'productos' and column_name = 'densidad_kg_l')),

    (6,  'sql/2026-10-25_unidades_medida_editable.sql',
         exists (select 1 from pg_policies
                  where schemaname = 'public' and tablename = 'unidades_medida' and cmd = 'UPDATE')
         or exists (select 1 from pg_policies
                  where schemaname = 'public' and tablename = 'unidades_medida' and cmd = 'ALL')),

    (7,  'sql/2026-10-26_prerecibo_documento_id.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pre_recibos' and column_name = 'documento_id')),

    (8,  'sql/2026-10-27_anticipo_proveedores.sql',
         exists (select 1 from public.cuentas_contables where codigo = '109.01')
         and exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pagos_proveedor_aplicaciones' and column_name = 'orden_compra_id')
         and exists (select 1 from pg_proc where proname = 'pagar_anticipo_oc')
         and exists (select 1 from pg_proc where proname = 'contabilizar_compra' and prosrc like '%v_anticipo_usar%')
         and to_regclass('public.v_anticipos_oc') is not null)
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
