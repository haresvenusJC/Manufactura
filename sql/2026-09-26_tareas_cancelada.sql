-- =====================================================================
--  Tareas: nuevo estatus 'cancelada' (distinto de 'archivada')
--  Fecha: 2026-09-26  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-06_tareas_sistema.sql, sql/2026-09-10_caducidad_
--  solo_obligatorios.sql, sql/2026-10-12_sugerido_pedir_entero.sql.
--
--  El usuario reportó que el botón "🚫 Cancelar" (agregado en la sesión
--  anterior, ver CLAUDE.md) guardaba la tarea con estatus 'archivada' —
--  el mismo que usa el sistema para "la condición ya no aplica" (stock
--  recuperado, fecha de caducidad capturada...). En el Historial de
--  tareas ambos casos se veían idénticos ("Archivada"), sin poder
--  distinguir "el sistema la cerró sola" de "el usuario la canceló a
--  mano porque ya se atendió por otro medio".
--
--  Qué agrega: estatus 'cancelada' (constraint + `tarea_resolver`,
--  acción 'cancelar'). El índice único parcial "una tarea viva por
--  tipo+entidad" y los dos sincronizadores (inventario / caducidad) ya
--  trataban 'archivada' como "no viva" para poder volver a crear la
--  tarea si la condición reaparece — se amplía esa misma regla a
--  'cancelada' (mismo comportamiento: cancelar NO apaga la alerta para
--  siempre, si sigue aplicando vuelve a aparecer sola).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Constraint de estatus
-- ---------------------------------------------------------------------
alter table public.tareas drop constraint if exists tareas_estatus_check;
alter table public.tareas add constraint tareas_estatus_check
    check (estatus in ('pendiente','atendida','pospuesta','archivada','cancelada'));

-- ---------------------------------------------------------------------
-- 2. Índice único parcial: "cancelada" también deja de contar como viva
--    (igual que "archivada"), para que el sincronizador pueda volver a
--    crear la tarea si la condición original sigue vigente.
-- ---------------------------------------------------------------------
drop index if exists public.tareas_entidad_viva_uq;
create unique index tareas_entidad_viva_uq
    on public.tareas (tipo, entidad_tipo, entidad_id)
    where estatus not in ('archivada', 'cancelada');

-- ---------------------------------------------------------------------
-- 3. tareas_sync_inventario — misma versión vigente (sql/2026-10-12_...),
--    solo con "estatus <> 'archivada'" ampliado a "not in ('archivada','cancelada')".
-- ---------------------------------------------------------------------
create or replace function public.tareas_sync_inventario(p_producto_id bigint default null)
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    r        record;
    v_bajo   boolean;
    v_falt   numeric;
    v_sug    numeric;
    v_tot    integer := 0;
begin
    for r in
        select p.id, p.nombre, p.sku, coalesce(p.activo, true) as activo,
               coalesce(p.stock_actual, 0)  as stock_actual,
               coalesce(p.stock_minimo, 0)  as stock_minimo,
               p.cantidad_minima_compra, p.tiempo_entrega_dias, p.proveedor_id,
               coalesce(um.es_fraccionable, false) as unidad_fraccionable
        from public.productos p
        left join public.unidades_medida um on um.id = p.unidad_medida_id
        where p_producto_id is null or p.id = p_producto_id
    loop
        v_bajo := r.activo and r.stock_minimo > 0 and r.stock_actual <= r.stock_minimo;

        if v_bajo then
            v_falt := r.stock_minimo - r.stock_actual;
            v_sug  := greatest(coalesce(r.cantidad_minima_compra, 0), v_falt);
            -- Unidad no fraccionable (piezas, cajas, docenas...): no se puede
            -- pedir una fracción — se redondea siempre hacia arriba, nunca
            -- hacia abajo (quedarse corto del mínimo no resuelve la alerta).
            if not r.unidad_fraccionable then
                v_sug := ceil(v_sug);
            end if;

            insert into public.tareas
                (tipo, estatus, prioridad, titulo, detalle,
                 entidad_tipo, entidad_id, datos, origen, accion_sugerida)
            values
                ('inventario_bajo_minimo',
                 'pendiente',
                 case when r.stock_actual <= 0 then 1 else 2 end,
                 'Comprar: ' || r.nombre,
                 'Existencia ' || trim(to_char(r.stock_actual, 'FM999999990.####'))
                    || ' · mínimo ' || trim(to_char(r.stock_minimo, 'FM999999990.####'))
                    || ' · sugerido pedir ' || trim(to_char(v_sug, 'FM999999990.####')),
                 'producto', r.id,
                 jsonb_build_object(
                    'sku', r.sku,
                    'stock_actual', r.stock_actual,
                    'stock_minimo', r.stock_minimo,
                    'faltante', v_falt,
                    'sugerido_pedir', v_sug,
                    'proveedor_id', r.proveedor_id,
                    'tiempo_entrega_dias', r.tiempo_entrega_dias),
                 'sistema', 'crear_orden_compra')
            on conflict (tipo, entidad_tipo, entidad_id) where estatus not in ('archivada', 'cancelada')
            do update set
                prioridad      = excluded.prioridad,
                titulo         = excluded.titulo,
                detalle        = excluded.detalle,
                datos          = excluded.datos,
                actualizada_en = now(),
                -- si estaba pospuesta y ya venció el aplazamiento, reactivar
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
            -- ya no aplica: archivar cualquier tarea viva de este producto
            -- (una ya 'cancelada' a mano NO se toca — no se le pisa el estatus).
            update public.tareas
            set estatus         = 'archivada',
                resuelta_en     = now(),
                actualizada_en  = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    'Archivada automáticamente: la existencia dejó de estar bajo el mínimo.')
            where tipo = 'inventario_bajo_minimo'
              and entidad_tipo = 'producto'
              and entidad_id = r.id
              and estatus not in ('archivada', 'cancelada');
            if found then v_tot := v_tot + 1; end if;
        end if;
    end loop;

    return v_tot;
end $$;

grant execute on function public.tareas_sync_inventario(bigint) to authenticated;


-- ---------------------------------------------------------------------
-- 4. tareas_sync_caducidad — misma versión vigente (sql/2026-09-10_...),
--    mismo cambio de predicado en los 7 sitios que tocaban 'archivada'.
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
               p.sku,
               coalesce(p.requiere_caducidad, false) as requiere_caducidad
        from public.lotes_inventario l
        join public.productos p on p.id = l.producto_id
        where p_lote_id is null or l.id = p_lote_id
    loop
        -- ── Caso A: el producto NO requiere caducidad, o el lote ya no
        --    tiene existencia → no debe haber ninguna tarea de caducidad
        --    para este lote; se archiva lo que hubiera vivo (lo cancelado
        --    a mano se deja igual).
        if not r.requiere_caducidad or r.stock_actual <= 0 then
            update public.tareas
            set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    case when not r.requiere_caducidad
                         then 'Archivada automáticamente: el producto dejó de requerir control de caducidad.'
                         else 'Archivada automáticamente: el lote se agotó.' end)
            where tipo in ('caducidad_proxima', 'caducidad_sin_fecha')
              and entidad_tipo = 'lote' and entidad_id = r.lote_id
              and estatus not in ('archivada', 'cancelada');
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
              and entidad_id = r.lote_id and estatus not in ('archivada', 'cancelada');

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
            on conflict (tipo, entidad_tipo, entidad_id) where estatus not in ('archivada', 'cancelada')
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
          and entidad_id = r.lote_id and estatus not in ('archivada', 'cancelada');

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
            on conflict (tipo, entidad_tipo, entidad_id) where estatus not in ('archivada', 'cancelada')
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
              and entidad_id = r.lote_id and estatus not in ('archivada', 'cancelada');
            if found then v_tot := v_tot + 1; end if;
        end if;
    end loop;

    -- lotes que ya no existen: archivar sus tareas vivas (ambos tipos)
    if p_lote_id is null then
        update public.tareas t
        set estatus = 'archivada', resuelta_en = now(), actualizada_en = now(),
            nota_resolucion = coalesce(nota_resolucion, 'Archivada automáticamente: el lote ya no existe.')
        where t.tipo in ('caducidad_proxima', 'caducidad_sin_fecha')
          and t.entidad_tipo = 'lote' and t.estatus not in ('archivada', 'cancelada')
          and not exists (select 1 from public.lotes_inventario l where l.id = t.entidad_id);
    end if;

    return v_tot;
end $$;

grant execute on function public.tareas_sync_caducidad(bigint) to authenticated;


-- ---------------------------------------------------------------------
-- 5. tarea_resolver — nueva acción 'cancelar' -> estatus 'cancelada'.
-- ---------------------------------------------------------------------
create or replace function public.tarea_resolver(
    p_id     bigint,
    p_accion text,
    p_nota   text     default null,
    p_dias   integer  default null
)
returns public.tareas
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_row     public.tareas;
    v_estatus text;
begin
    v_estatus := case p_accion
        when 'atender'  then 'atendida'
        when 'posponer' then 'pospuesta'
        when 'archivar' then 'archivada'
        when 'cancelar' then 'cancelada'
        when 'reabrir'  then 'pendiente'
        else null end;

    if v_estatus is null then
        raise exception 'Acción no válida: %  (usa atender | posponer | archivar | cancelar | reabrir)', p_accion;
    end if;

    update public.tareas
    set estatus         = v_estatus,
        nota_resolucion  = coalesce(p_nota, nota_resolucion),
        posponer_hasta   = case when p_accion = 'posponer'
                                then now() + (coalesce(p_dias, 7) || ' days')::interval
                                else null end,
        resuelta_en      = case when v_estatus in ('atendida','archivada','cancelada') then now() else null end,
        resuelta_por     = case when v_estatus <> 'pendiente' then auth.uid() else resuelta_por end,
        actualizada_en   = now()
    where id = p_id
    returning * into v_row;

    if not found then
        raise exception 'La tarea % no existe', p_id;
    end if;
    return v_row;
end $$;

grant execute on function public.tarea_resolver(bigint, text, text, integer) to authenticated;

commit;
