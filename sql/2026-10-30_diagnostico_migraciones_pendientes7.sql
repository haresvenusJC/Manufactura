-- =====================================================================
--  Diagnóstico: ¿qué migraciones faltan por correr? (parte 7)
--  Fecha: 2026-10-30  ·  Proyecto: Hares de México (Supabase)
--
--  SOLO LECTURA — no modifica nada. Pégalo completo en Supabase -> SQL Editor.
--  Primera fila = resumen; cada fila "FALTA" es un archivo sin correr (o a medias).
--
--  Cubre Recursos humanos (departamentos, Gerente, foto, firmas, jerarquía y rol) y la zona horaria.
--  Continúa a 2026-10-24_diagnostico_migraciones_pendientes6.sql.
--  Orden de ejecución de las que falten: 1 -> 2 -> 3 (la 4 es independiente).
-- =====================================================================
with c(orden, archivo, ok) as (
    select 1, '1 sql/2026-10-28_departamentos_gerente_foto.sql (departamentos, gerente_id, foto)',
        to_regclass('public.departamentos') is not null
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='empleados' and column_name='gerente_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='empleados' and column_name='departamento_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='empleados' and column_name='foto_path')
        and exists (select 1 from storage.buckets where id = 'fotos-personal')
    union all
    select 2, '2 sql/2026-10-28b_firmas_requisicion.sql (requisición: departamento, solicita, autoriza)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='requisiciones_compra' and column_name='solicitante_empleado_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='requisiciones_compra' and column_name='autorizada_por_empleado_id')
    union all
    select 3, '3 sql/2026-10-30_departamento_superior_rol.sql (departamento superior + rol Responsable/Colaborador)',
        exists (select 1 from information_schema.columns where table_schema='public' and table_name='departamentos' and column_name='departamento_padre_id')
        and exists (select 1 from information_schema.columns where table_schema='public' and table_name='empleados' and column_name='rol_departamento')
        and exists (select 1 from pg_proc where proname = '_empleado_sincroniza_responsable')
    union all
    select 4, '4 sql/2026-10-16_zona_horaria_mexico.sql (base en America/Mexico_City; hoy: ' || current_setting('TimeZone') || ')',
        current_setting('TimeZone') = 'America/Mexico_City'
)
select orden, case when ok then 'OK' else 'FALTA' end as estado, archivo
  from c
union all
select 0, case when bool_and(ok) then 'TODO AL DÍA' else 'HAY ' || count(*) filter (where not ok) || ' PENDIENTE(S)' end,
       'Resumen (revisa las filas FALTA)'
  from c
order by orden;
