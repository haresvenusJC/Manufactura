-- =====================================================================
--  Tareas / alertas de CADUCIDAD por lote — umbrales configurables
--  Fecha: 2026-09-09  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere:
--    · sql/2026-09-02_caducidad_lotes.sql  (lotes_inventario.fecha_caducidad)
--    · sql/2026-09-06_tareas_sistema.sql   (tabla public.tareas + índice
--      único parcial tareas_entidad_viva_uq)
--
--  Qué agrega:
--    1. public.alertas_caducidad_umbrales — 1 fila por umbral de aviso.
--       Semilla: 180 d (6 meses), 90 d (3 meses), 30 d (1 mes). El
--       usuario prende/apaga o agrega filas desde la pantalla de Tareas.
--    2. public.tareas_sync_caducidad(p_lote_id) — revisa lotes con
--       fecha_caducidad y existencia > 0; para cada uno crea/actualiza
--       UNA tarea 'caducidad_proxima' con la banda de umbral más ajustada
--       que ya se alcanzó. Cuando el lote se agota, se vence del todo y
--       se saca, o se borra, la tarea se archiva sola. p_lote_id NULL =
--       todos.
--    3. trigger en lotes_inventario (fecha_caducidad / stock_actual) que
--       llama al sync en tiempo real al recibir o mover un lote.
--    4. job de pg_cron diario 07:20 CDMX (13:20 UTC) — es el motor real,
--       porque una caducidad se "cruza" por el paso del tiempo, no por
--       un cambio en la base.
--    5. backfill al final.
--
--  Flujo de estatus: el mismo de public.tareas
--    pendiente -> atendida / pospuesta -> archivada.
--
--  Idempotente. No toca estructura de tablas existentes salvo agregar
--  el trigger; ninguna columna, función previa, policy ni dato se pierde.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Umbrales de aviso (catálogo editable)
-- ---------------------------------------------------------------------
create table if not exists public.alertas_caducidad_umbrales (
    dias      integer  primary key check (dias >= 0),
    etiqueta  text     not null,
    prioridad smallint not null default 2 check (prioridad between 1 and 3),  -- 1 alta · 2 normal · 3 baja
    activo    boolean  not null default true
);

insert into public.alertas_caducidad_umbrales (dias, etiqueta, prioridad) values
    (180, '6 meses de vida', 3),
    (90,  '3 meses de vida', 2),
    (30,  '1 mes de vida',   1)
on conflict (dias) do nothing;

alter table public.alertas_caducidad_umbrales enable row level security;
drop policy if exists admin_all on public.alertas_caducidad_umbrales;
create policy admin_all on public.alertas_caducidad_umbrales for all to authenticated using (true) with check (true);
grant all on public.alertas_caducidad_umbrales to authenticated;

comment on table public.alertas_caducidad_umbrales is
  'Umbrales (en días) para las alertas de caducidad por lote. El sync usa el menor "dias" activo que sea >= a los días restantes del lote.';


-- ---------------------------------------------------------------------
-- 2. Sincronizador de tareas de caducidad
--    p_lote_id NULL = recorre todos los lotes con fecha_caducidad.
--    Devuelve cuántos lotes tocó (creó/actualizó/archivó).
-- ---------------------------------------------------------------------
create or replace function public.tareas_sync_caducidad(p_lote_id bigint default null)
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    r        record;
    v_dias   integer;
    v_umb    record;
    v_tot    integer := 0;
begin
    for r in
        select l.id                          as lote_id,
               l.numero_lote,
               l.lote_proveedor,
               l.fecha_caducidad,
               coalesce(l.stock_actual, 0)   as stock_actual,
               p.id                          as producto_id,
               p.nombre                      as producto_nombre,
               p.sku
        from public.lotes_inventario l
        join public.productos p on p.id = l.producto_id
        where l.fecha_caducidad is not null
          and (p_lote_id is null or l.id = p_lote_id)
    loop
        v_dias := r.fecha_caducidad - current_date;

        -- umbral activo más ajustado que ya se alcanzó:
        -- el menor 'dias' de la tabla que sea >= días restantes del lote
        select * into v_umb
        from public.alertas_caducidad_umbrales
        where activo and dias >= v_dias
        order by dias asc
        limit 1;

        if r.stock_actual > 0 and v_umb.dias is not null then
            insert into public.tareas
                (tipo, estatus, prioridad, titulo, detalle,
                 entidad_tipo, entidad_id, datos, origen, accion_sugerida)
            values (
                'caducidad_proxima',
                'pendiente',
                case when v_dias <= 0 then 1 else coalesce(v_umb.prioridad, 2) end,
                'Caducidad: ' || r.producto_nombre
                    || ' — lote ' || coalesce(nullif(trim(r.numero_lote), ''),
                                              nullif(trim(r.lote_proveedor), ''), '(s/n)'),
                case
                    when v_dias < 0 then 'VENCIÓ hace ' || abs(v_dias) || ' días (el ' || r.fecha_caducidad || ')'
                    when v_dias = 0 then 'VENCE HOY (' || r.fecha_caducidad || ')'
                    else 'Vence el ' || r.fecha_caducidad || ' · faltan ' || v_dias
                         || ' días · umbral: ' || v_umb.etiqueta
                end
                || ' · existencia en lote ' || trim(to_char(r.stock_actual, 'FM999999990.####')),
                'lote', r.lote_id,
                jsonb_build_object(
                    'producto_id',    r.producto_id,
                    'sku',            r.sku,
                    'lote_id',        r.lote_id,
                    'numero_lote',    r.numero_lote,
                    'lote_proveedor', r.lote_proveedor,
                    'fecha_caducidad',r.fecha_caducidad,
                    'dias_restantes', v_dias,
                    'umbral_dias',    v_umb.dias,
                    'umbral_etiqueta',v_umb.etiqueta,
                    'stock_lote',     r.stock_actual,
                    'vencido',        (v_dias < 0)),
                'sistema', 'revisar_lote')
            on conflict (tipo, entidad_tipo, entidad_id) where estatus <> 'archivada'
            do update set
                prioridad      = excluded.prioridad,
                titulo         = excluded.titulo,
                detalle        = excluded.detalle,
                datos          = excluded.datos,
                actualizada_en = now(),
                estatus        = case
                    when tareas.estatus = 'pospuesta'
                     and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now()
                    then 'pendiente' else tareas.estatus end,
                posponer_hasta = case
                    when tareas.estatus = 'pospuesta'
                     and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now()
                    then null else tareas.posponer_hasta end;

            v_tot := v_tot + 1;

        else
            update public.tareas
            set estatus         = 'archivada',
                resuelta_en     = now(),
                actualizada_en  = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    case when r.stock_actual <= 0
                         then 'Archivada automáticamente: el lote se agotó.'
                         else 'Archivada automáticamente: la caducidad volvió a estar fuera de los umbrales activos.' end)
            where tipo = 'caducidad_proxima'
              and entidad_tipo = 'lote'
              and entidad_id = r.lote_id
              and estatus <> 'archivada';
            if found then v_tot := v_tot + 1; end if;
        end if;
    end loop;

    -- lotes que ya no existen: archivar su tarea viva
    if p_lote_id is null then
        update public.tareas t
        set estatus         = 'archivada',
            resuelta_en     = now(),
            actualizada_en  = now(),
            nota_resolucion = coalesce(nota_resolucion, 'Archivada automáticamente: el lote ya no existe.')
        where t.tipo = 'caducidad_proxima'
          and t.entidad_tipo = 'lote'
          and t.estatus <> 'archivada'
          and not exists (select 1 from public.lotes_inventario l where l.id = t.entidad_id);
    end if;

    return v_tot;
end $$;

grant execute on function public.tareas_sync_caducidad(bigint) to authenticated;


-- ---------------------------------------------------------------------
-- 3. Trigger en lotes_inventario — sync en tiempo real
-- ---------------------------------------------------------------------
create or replace function public.fn_lotes_tareas_caducidad()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    perform public.tareas_sync_caducidad(new.id);
    return null;   -- AFTER trigger
end $$;

drop trigger if exists trg_lotes_tareas_caducidad on public.lotes_inventario;
create trigger trg_lotes_tareas_caducidad
    after insert or update of fecha_caducidad, stock_actual on public.lotes_inventario
    for each row execute function public.fn_lotes_tareas_caducidad();


-- ---------------------------------------------------------------------
-- 4. Job diario de pg_cron (07:20 hora centro = 13:20 UTC)
--    Motor real de estas alertas: la caducidad se cruza por el tiempo.
-- ---------------------------------------------------------------------
do $$
begin
    if exists (select 1 from pg_extension where extname = 'pg_cron') then
        perform cron.schedule(
            'tareas_caducidad_diario',
            '20 13 * * *',
            'select public.tareas_sync_caducidad(null);'
        );
        raise notice 'Job pg_cron "tareas_caducidad_diario" programado (13:20 UTC).';
    else
        raise notice 'pg_cron no instalado: se omite el job. El trigger igual crea las tareas al recibir/mover lotes.';
    end if;
end $$;


-- ---------------------------------------------------------------------
-- 5. Backfill: crea las tareas de lo que HOY ya cae en algún umbral
-- ---------------------------------------------------------------------
select public.tareas_sync_caducidad(null) as lotes_evaluados;

commit;


-- =====================================================================
--  Consultas útiles (opcionales)
-- =====================================================================
-- select * from public.alertas_caducidad_umbrales order by dias desc;
--
-- select id, prioridad, titulo, estatus, (datos->>'fecha_caducidad') venc,
--        (datos->>'dias_restantes') dias
-- from public.tareas
-- where tipo = 'caducidad_proxima' and estatus <> 'archivada'
-- order by prioridad, (datos->>'dias_restantes')::int;
--
-- -- desactivar un umbral:
-- update public.alertas_caducidad_umbrales set activo = false where dias = 180;
-- -- agregar uno nuevo (ej. 15 días):
-- insert into public.alertas_caducidad_umbrales (dias, etiqueta, prioridad)
-- values (15, '15 días de vida', 1) on conflict (dias) do nothing;
-- -- re-evaluar tras cambiar umbrales:
-- select public.tareas_sync_caducidad(null);
