-- =====================================================================
--  Sugerencia de pedido (Tareas): entera si la unidad no es fraccionable
--  Fecha: 2026-10-12  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-06_tareas_sistema.sql
--
--  tareas_sync_inventario calculaba "sugerido pedir" como
--  greatest(cantidad_minima_compra, faltante) tal cual, en decimales. Para
--  una unidad como "Piezas" eso puede sugerir comprar 1.5 piezas, algo que
--  no existe — no puedes pedirle al proveedor media pieza. Para unidades
--  fraccionables de verdad (kilogramos, litros, etc.) sí tiene sentido un
--  decimal.
--
--  Se agrega unidades_medida.es_fraccionable (default false) y se marca
--  true en las unidades de peso/volumen/longitud/tiempo ya sembradas. Si
--  agregas una unidad nueva que también sea fraccionable (ej. "Metros"),
--  márcala a mano:
--    update public.unidades_medida set es_fraccionable = true where nombre = 'Metros';
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.unidades_medida
    add column if not exists es_fraccionable boolean not null default false;

comment on column public.unidades_medida.es_fraccionable is
  'true = admite decimales al sugerir cuánto comprar (kilogramos, litros...). false = solo enteros (piezas, cajas, docenas...).';

update public.unidades_medida
   set es_fraccionable = true
 where es_fraccionable = false
   and (
       nombre ilike '%kilo%' or nombre ilike 'kg%' or nombre ilike '%gramo%' or nombre = 'g'
    or nombre ilike '%litro%' or nombre ilike 'lt%' or nombre = 'l' or nombre ilike '%mililitro%' or nombre ilike 'ml%'
    or nombre ilike '%tonelada%'
    or nombre ilike '%metro%' or nombre = 'm' or nombre ilike '%m2%' or nombre ilike '%m3%'
    or nombre ilike '%hora%'
   );

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
            on conflict (tipo, entidad_tipo, entidad_id) where estatus <> 'archivada'
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
            update public.tareas
            set estatus         = 'archivada',
                resuelta_en     = now(),
                actualizada_en  = now(),
                nota_resolucion = coalesce(nota_resolucion,
                    'Archivada automáticamente: la existencia dejó de estar bajo el mínimo.')
            where tipo = 'inventario_bajo_minimo'
              and entidad_tipo = 'producto'
              and entidad_id = r.id
              and estatus <> 'archivada';
            if found then v_tot := v_tot + 1; end if;
        end if;
    end loop;

    return v_tot;
end $$;

grant execute on function public.tareas_sync_inventario(bigint) to authenticated;

-- Re-evalúa todo lo ya bajo mínimo con la nueva regla de redondeo.
select public.tareas_sync_inventario(null) as productos_reevaluados;

commit;
