-- =====================================================================
--  Caducidad: las alertas aplican SOLO a productos marcados como
--  "requiere control de caducidad" (productos.requiere_caducidad)
--  Fecha: 2026-09-10  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere haber corrido antes:
--    · sql/2026-09-02_caducidad_lotes.sql   (productos.requiere_caducidad)
--    · sql/2026-09-09_tareas_caducidad.sql  (tabla umbrales + función v1)
--
--  Qué cambia respecto a la v1:
--    · El revisor SOLO mira lotes de productos con requiere_caducidad = true.
--      Los que no la requieren (materias primas / insumos que no caducan)
--      dejan de generar tareas y sus tareas vivas se archivan solas.
--    · Nuevo tipo de tarea 'caducidad_sin_fecha': si un producto SÍ
--      requiere caducidad y se recibió un lote SIN capturar la fecha de
--      vencimiento (y tiene existencia), sale una tarea para capturarla.
--      Al capturarla, esa tarea se archiva y (si aplica) nace la de
--      'caducidad_proxima'.
--
--  Solo reemplaza la función tareas_sync_caducidad (create or replace).
--  El trigger, el job de pg_cron y la tabla de umbrales de la v1 NO se
--  tocan — siguen llamando a esta misma función. Idempotente.
-- =====================================================================

begin;

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
               p.sku,
               coalesce(p.requiere_caducidad, false) as requiere_caducidad
        from public.lotes_inventario l
        join public.productos p on p.id = l.producto_id
        where p_lote_id is null or l.id = p_lote_id
    loop
        -- ── Caso A: el producto NO requiere caducidad, o el lote ya no
        --    tiene existencia → no debe haber ninguna tarea de caducidad
        --    para este lote; se archiva lo que hubiera vivo.
        if not r.requiere_caducidad or r.stock_actual <= 0 then
            update public.tareas
            set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    case when not r.requiere_caducidad
                         then 'Archivada automáticamente: el producto dejó de requerir control de caducidad.'
                         else 'Archivada automáticamente: el lote se agotó.' end)
            where tipo in ('caducidad_proxima', 'caducidad_sin_fecha')
              and entidad_tipo = 'lote' and entidad_id = r.lote_id
              and estatus <> 'archivada';
            if found then v_tot := v_tot + 1; end if;
            continue;
        end if;

        -- ── Caso B: requiere caducidad y hay existencia, pero NO se
        --    capturó la fecha de vencimiento del lote → tarea para pedirla.
        if r.fecha_caducidad is null then
            -- cerrar cualquier 'caducidad_proxima' viva (no aplica sin fecha)
            update public.tareas
            set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
                nota_resolucion = coalesce(nota_resolucion, 'Archivada: el lote quedó sin fecha de caducidad.')
            where tipo = 'caducidad_proxima' and entidad_tipo = 'lote'
              and entidad_id = r.lote_id and estatus <> 'archivada';

            insert into public.tareas
                (tipo, estatus, prioridad, titulo, detalle,
                 entidad_tipo, entidad_id, datos, origen, accion_sugerida)
            values (
                'caducidad_sin_fecha', 'pendiente', 2,
                'Falta caducidad: ' || r.producto_nombre
                    || ' — lote ' || coalesce(nullif(trim(r.numero_lote), ''),
                                              nullif(trim(r.lote_proveedor), ''), '(s/n)'),
                'Este producto requiere control de caducidad y el lote se recibió sin fecha de vencimiento · existencia '
                    || trim(to_char(r.stock_actual, 'FM999999990.####')),
                'lote', r.lote_id,
                jsonb_build_object(
                    'producto_id', r.producto_id, 'sku', r.sku, 'lote_id', r.lote_id,
                    'numero_lote', r.numero_lote, 'lote_proveedor', r.lote_proveedor,
                    'stock_lote', r.stock_actual, 'falta_fecha', true),
                'sistema', 'revisar_lote')
            on conflict (tipo, entidad_tipo, entidad_id) where estatus <> 'archivada'
            do update set
                titulo = excluded.titulo, detalle = excluded.detalle,
                datos = excluded.datos, actualizada_en = now(),
                estatus = case
                    when tareas.estatus = 'pospuesta' and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now() then 'pendiente' else tareas.estatus end,
                posponer_hasta = case
                    when tareas.estatus = 'pospuesta' and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now() then null else tareas.posponer_hasta end;
            v_tot := v_tot + 1;
            continue;
        end if;

        -- ── Caso C: requiere caducidad, hay existencia y hay fecha →
        --    lógica de umbrales. Primero cerrar la de 'sin fecha' si la hubo.
        update public.tareas
        set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
            nota_resolucion = coalesce(nota_resolucion, 'Archivada: ya se capturó la fecha de caducidad del lote.')
        where tipo = 'caducidad_sin_fecha' and entidad_tipo = 'lote'
          and entidad_id = r.lote_id and estatus <> 'archivada';

        v_dias := r.fecha_caducidad - current_date;

        select * into v_umb
        from public.alertas_caducidad_umbrales
        where activo and dias >= v_dias
        order by dias asc
        limit 1;

        if v_umb.dias is not null then
            insert into public.tareas
                (tipo, estatus, prioridad, titulo, detalle,
                 entidad_tipo, entidad_id, datos, origen, accion_sugerida)
            values (
                'caducidad_proxima', 'pendiente',
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
                    'producto_id', r.producto_id, 'sku', r.sku, 'lote_id', r.lote_id,
                    'numero_lote', r.numero_lote, 'lote_proveedor', r.lote_proveedor,
                    'fecha_caducidad', r.fecha_caducidad, 'dias_restantes', v_dias,
                    'umbral_dias', v_umb.dias, 'umbral_etiqueta', v_umb.etiqueta,
                    'stock_lote', r.stock_actual, 'vencido', (v_dias < 0)),
                'sistema', 'revisar_lote')
            on conflict (tipo, entidad_tipo, entidad_id) where estatus <> 'archivada'
            do update set
                prioridad = excluded.prioridad, titulo = excluded.titulo,
                detalle = excluded.detalle, datos = excluded.datos, actualizada_en = now(),
                estatus = case
                    when tareas.estatus = 'pospuesta' and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now() then 'pendiente' else tareas.estatus end,
                posponer_hasta = case
                    when tareas.estatus = 'pospuesta' and tareas.posponer_hasta is not null
                     and tareas.posponer_hasta <= now() then null else tareas.posponer_hasta end;
            v_tot := v_tot + 1;
        else
            -- fecha todavía lejos de cualquier umbral activo → archivar si había
            update public.tareas
            set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    'Archivada automáticamente: la caducidad volvió a estar fuera de los umbrales activos.')
            where tipo = 'caducidad_proxima' and entidad_tipo = 'lote'
              and entidad_id = r.lote_id and estatus <> 'archivada';
            if found then v_tot := v_tot + 1; end if;
        end if;
    end loop;

    -- lotes que ya no existen: archivar sus tareas vivas (ambos tipos)
    if p_lote_id is null then
        update public.tareas t
        set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
            nota_resolucion = coalesce(nota_resolucion, 'Archivada automáticamente: el lote ya no existe.')
        where t.tipo in ('caducidad_proxima', 'caducidad_sin_fecha')
          and t.entidad_tipo = 'lote' and t.estatus <> 'archivada'
          and not exists (select 1 from public.lotes_inventario l where l.id = t.entidad_id);
    end if;

    return v_tot;
end $$;

grant execute on function public.tareas_sync_caducidad(bigint) to authenticated;

-- re-evaluar todo con la nueva regla
select public.tareas_sync_caducidad(null) as lotes_evaluados;

commit;
