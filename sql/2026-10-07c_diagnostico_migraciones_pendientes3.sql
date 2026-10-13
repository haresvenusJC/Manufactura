-- =====================================================================
--  Diagnóstico: ¿qué migraciones recientes faltan por correr? (parte 3)
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  Es de SOLO LECTURA — no modifica nada. Pégalo completo en Supabase ->
--  SQL Editor y corre. La primera fila es el resumen; cada fila "FALTA"
--  es un archivo que todavía no se ha corrido (o se corrió a medias).
--
--  Continúa a sql/2026-10-28_diagnostico_migraciones_pendientes2.sql (esa
--  confirmó "TODO AL DÍA" hasta 2026-10-27). Esta cubre dos hilos que esa
--  no tocó: la maqueta de Pagos a proveedores v2 (2026-10-05/06/07) y
--  Reservas/resolución de anticipo (2026-10-29 a 2026-11-06).
-- =====================================================================

with c(orden, archivo, ok) as (
    values
    (1,  'sql/2026-10-05_series_3_letras.sql',
         exists (select 1 from public.contadores_folios where serie = 'ODC')),

    (2,  'sql/2026-10-05_acuerdo_pago_parcial.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pagos_proveedor' and column_name = 'acuerdo_proveedor')
         and exists (select 1 from pg_proc where proname = 'pago_proveedor_set_acuerdo')),

    (3,  'sql/2026-10-06_oc_tipo_cambio.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'ordenes_compra' and column_name = 'tipo_cambio_fuente')),

    (4,  'sql/2026-10-07_compras_notas_ajuste.sql',
         to_regclass('public.notas_compra') is not null
         and exists (select 1 from pg_proc where proname = 'contabilizar_compra' and prosrc like '%nota_ajuste%')),

    (5,  'sql/2026-10-07b_cxp_v2.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'ordenes_compra' and column_name = 'dias_credito')
         and exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'v_cuentas_por_pagar' and column_name = 'vence')),

    (6,  'sql/2026-10-29_resolucion_anticipo_oc.sql',
         to_regclass('public.anticipo_oc_resoluciones') is not null
         and exists (select 1 from pg_proc where proname = 'resolver_anticipo_oc')),

    (7,  'sql/2026-11-03_reservas_pedidos.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pedidos_venta_detalle' and column_name = 'cantidad_reservada')
         and exists (select 1 from pg_proc where proname = 'reservas_reasignar')),

    (8,  'sql/2026-11-03b_reservas_liberar.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'pedidos_venta_detalle' and column_name = 'apartar')
         and exists (select 1 from pg_proc where proname = 'pedido_venta_liberar_reserva')),

    (9,  'sql/2026-11-04_pedido_venta_cobertura.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'ordenes_produccion' and column_name = 'pedido_venta_id')
         and exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'requisiciones_compra' and column_name = 'pedido_venta_id')),

    (10, 'sql/2026-11-05_reservas_guardia_bd.sql',
         to_regclass('public.reservas_autorizaciones') is not null
         and exists (select 1 from pg_proc where proname = 'reserva_autorizar_salida')),

    (11, 'sql/2026-11-06_lote_minimo_fabricacion.sql',
         exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'productos' and column_name = 'lote_minimo_fabricacion'))
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

-- =====================================================================
--  Nota: sql/2026-10-07_diagnostico_aju_egresos.sql no está en esta lista
--  a propósito — es de solo lectura, no crea nada que se pueda detectar
--  (correrlo o no correrlo no deja rastro en el esquema).
--
--  Si algo sale "FALTA", corre ese archivo completo en Supabase -> SQL
--  Editor, en el orden en que aparece aquí (van por fecha/dependencia).
-- =====================================================================
