-- =====================================================================
--  Orden de Trabajo (celular): la cantidad requerida de cada componente
--  ahora respeta el rendimiento del lote y la conversión de unidades
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Idempotente. Reemplaza la vista de sql/2026-09-12_ot_componentes_lotes.sql
--  (mismas columnas, misma política de lotes FIFO/FEFO).
--
--  Problema: v_ot_orden_componentes calculaba
--      bom.cantidad_requerida * orden.cantidad_producida
--  a secas, mientras Producción (calcularRequerimientosProduccion en
--  js/produccion.js) y el cierre de la orden además:
--    1) dividen la cantidad pedida entre productos.rendimiento_lote_bom
--       (BOM escrito para el lote completo, ej. "Granel ... 15 Litros"), y
--    2) convierten la unidad del renglón del BOM a la unidad de inventario
--       del insumo (g<->kg, mL<->L exacto; volumen<->masa con
--       productos.densidad_kg_l; sin densidad, 1 a 1).
--  Resultado: el celular pedía ~15x de más (ej. 12 L de granel ->
--  "Glicerina 164.4 kg" en vez de 13.81 kg) y marcaba faltantes falsos.
--
--  factor_conversion_bom() replica factorConversion() de
--  js/conversion-unidades.js — si se cambia una, cambiar la otra.
-- =====================================================================

begin;

-- Por si alguna de las dos migraciones previas no se ha corrido (no cambia nada si ya existen).
alter table public.productos add column if not exists rendimiento_lote_bom numeric;
alter table public.productos add column if not exists densidad_kg_l numeric;

-- Cuántas unidades de inventario del insumo equivale 1 unidad del renglón del BOM.
-- Recibe nombres ya resueltos (no consulta tablas) para que funcione igual con anon.
create or replace function public.factor_conversion_bom(
    p_bom_unidad       text,     -- bom.unidad_medida (id de la unidad como texto, o un nombre)
    p_bom_unidad_nom   text,     -- nombre de esa unidad si p_bom_unidad es un id
    p_dest_id          text,     -- productos.unidad_medida_id del insumo, como texto
    p_dest_nom         text,     -- nombre de la unidad de inventario del insumo
    p_cantidad         numeric,  -- bom.cantidad_requerida (solo para la regla histórica sin unidad)
    p_densidad         numeric   -- productos.densidad_kg_l del insumo
) returns numeric
language plpgsql immutable as $$
declare
    v_raw  text := trim(coalesce(p_bom_unidad, ''));
    v_orig text;
    v_dest text := lower(trim(coalesce(p_dest_nom, '')));
    fo text; bo numeric; fd text; bd numeric;
    v_dens numeric := coalesce(p_densidad, 0);
begin
    -- Renglones viejos sin unidad: regla histórica (mL/g -> kg/L, cantidades > 10 como mL/g).
    if v_raw = '' then
        if v_dest like '%ml%' or v_dest like '%g%' or coalesce(p_cantidad, 0) > 10 then return 0.001; end if;
        return 1;
    end if;
    if v_raw = coalesce(p_dest_id, '') then return 1; end if;

    v_orig := case when v_raw ~ '^\d+$' then coalesce(p_bom_unidad_nom, '') else v_raw end;

    select f.familia, f.a_base into fo, bo from (
        select case
            when n ~ '^(miligramos?|mgs?)$'        then 'masa'
            when n ~ '^(kilogramos?|kilos?|kgs?)$' then 'masa'
            when n ~ '^(gramos?|grs?|g)$'          then 'masa'
            when n ~ '^(mililitros?|mls?|cc)$'     then 'volumen'
            when n ~ '^(litros?|lts?|l)$'          then 'volumen' end as familia,
               case
            when n ~ '^(miligramos?|mgs?)$'        then 0.001
            when n ~ '^(kilogramos?|kilos?|kgs?)$' then 1000
            when n ~ '^(gramos?|grs?|g)$'          then 1
            when n ~ '^(mililitros?|mls?|cc)$'     then 1
            when n ~ '^(litros?|lts?|l)$'          then 1000 end::numeric as a_base
          from (select lower(translate(trim(v_orig), 'ÁÉÍÓÚáéíóú', 'AEIOUaeiou')) as n) x
    ) f;

    select f.familia, f.a_base into fd, bd from (
        select case
            when n ~ '^(miligramos?|mgs?)$'        then 'masa'
            when n ~ '^(kilogramos?|kilos?|kgs?)$' then 'masa'
            when n ~ '^(gramos?|grs?|g)$'          then 'masa'
            when n ~ '^(mililitros?|mls?|cc)$'     then 'volumen'
            when n ~ '^(litros?|lts?|l)$'          then 'volumen' end as familia,
               case
            when n ~ '^(miligramos?|mgs?)$'        then 0.001
            when n ~ '^(kilogramos?|kilos?|kgs?)$' then 1000
            when n ~ '^(gramos?|grs?|g)$'          then 1
            when n ~ '^(mililitros?|mls?|cc)$'     then 1
            when n ~ '^(litros?|lts?|l)$'          then 1000 end::numeric as a_base
          from (select lower(translate(trim(coalesce(p_dest_nom, '')), 'ÁÉÍÓÚáéíóú', 'AEIOUaeiou')) as n) x
    ) f;

    if fo is not null and fd is not null then
        if fo = fd then return bo / bd; end if;
        if v_dens > 0 then
            if fo = 'volumen' then return (bo * v_dens) / bd;    -- BOM en volumen, inventario en masa
            else return (bo / v_dens) / bd; end if;              -- BOM en masa, inventario en volumen
        end if;
    end if;
    return 1;   -- familias desconocidas o sin densidad: 1 a 1 (Producción avisa en pantalla)
end;
$$;

grant execute on function public.factor_conversion_bom(text, text, text, text, numeric, numeric) to anon, authenticated;

create or replace view public.v_ot_orden_componentes as
with req0 as (
    select op.id                                   as orden_id,
           op.folio                                 as orden_folio,
           b.componente_id                          as producto_id,
           pc.nombre                                as producto_nombre,
           pc.sku,
           umc.nombre                               as unidad,
           coalesce(pc.requiere_caducidad, false)   as requiere_caducidad,
           b.cantidad_requerida
             -- BOM por lote completo: cantidad pedida / rendimiento del lote = cuántas corridas de la receta
             * case when coalesce(pp.rendimiento_lote_bom, 0) > 0
                    then coalesce(op.cantidad_producida, 0) / pp.rendimiento_lote_bom
                    else coalesce(op.cantidad_producida, 0) end
             * public.factor_conversion_bom(b.unidad_medida::text, umb.nombre, pc.unidad_medida_id::text,
                                            umc.nombre, b.cantidad_requerida, pc.densidad_kg_l)
                                                    as cant
      from public.ordenes_produccion op
      join public.productos pp on pp.id = op.producto_id
      join public.bom b        on b.producto_id = op.producto_id
      join public.productos pc on pc.id = b.componente_id
      left join public.unidades_medida umc on umc.id = pc.unidad_medida_id
      left join public.unidades_medida umb on umb.id::text = trim(b.unidad_medida::text)
     where op.estado = 'en_proceso'
),
-- Un insumo puede repetirse en el BOM: se suma en un solo renglón (igual que en Producción).
req as (
    select orden_id, orden_folio, producto_id, producto_nombre, sku, unidad, requiere_caducidad,
           round(sum(cant)::numeric, 4) as cantidad_requerida
      from req0
     group by orden_id, orden_folio, producto_id, producto_nombre, sku, unidad, requiere_caducidad
),
lotes as (
    select l.producto_id,
           l.id                                     as lote_id,
           l.numero_lote,
           l.lote_proveedor,
           l.fecha_ingreso,
           l.fecha_caducidad,
           coalesce(l.stock_actual, 0)              as stock_actual,
           -- acumulado de lo que se consume ANTES de este lote, en el orden de equilibrio
           coalesce(sum(coalesce(l.stock_actual, 0)) over (
               partition by l.producto_id
               order by date_trunc('month', l.fecha_caducidad) asc nulls last,
                        l.fecha_ingreso asc, l.created_at asc
               rows between unbounded preceding and 1 preceding), 0) as acum_prev
      from public.lotes_inventario l
     where coalesce(l.stock_actual, 0) > 0
),
disp as (
    select producto_id, sum(stock_actual) as total_disponible
      from lotes
     group by producto_id
)
select r.orden_id,
       r.orden_folio,
       r.producto_id,
       r.producto_nombre,
       r.sku,
       r.unidad,
       r.requiere_caducidad,
       r.cantidad_requerida,
       coalesce(d.total_disponible, 0)                                     as total_disponible,
       greatest(0, r.cantidad_requerida - coalesce(d.total_disponible, 0)) as faltante,
       lo.lote_id,
       lo.numero_lote,
       lo.lote_proveedor,
       lo.fecha_ingreso,
       lo.fecha_caducidad,
       lo.stock_actual                                                     as stock_en_lote,
       case when lo.lote_id is null then null
            else greatest(0, least(lo.stock_actual, r.cantidad_requerida - lo.acum_prev))
       end                                                                 as tomar_de_lote,
       -- 'FEFO' si este lote se adelantó a otro más antiguo (por ingreso)
       -- que caduca un mes después o no caduca; 'FIFO' si salió por antigüedad.
       case
         when lo.lote_id is null then null
         when exists (
              select 1 from lotes o
               where o.producto_id = lo.producto_id
                 and o.fecha_ingreso < lo.fecha_ingreso
                 and (o.fecha_caducidad is null
                      or date_trunc('month', o.fecha_caducidad) > date_trunc('month', lo.fecha_caducidad))
         ) then 'FEFO'
         else 'FIFO'
       end                                                                 as criterio
  from req r
  left join disp d  on d.producto_id = r.producto_id
  left join lotes lo
    on lo.producto_id = r.producto_id
   and lo.acum_prev < r.cantidad_requerida            -- solo los lotes que entran en el requerimiento
 order by r.orden_id, r.producto_nombre,
          date_trunc('month', lo.fecha_caducidad) asc nulls last,
          lo.fecha_ingreso, lo.lote_id;

grant select on public.v_ot_orden_componentes to anon, authenticated;

comment on view public.v_ot_orden_componentes is
  'Por orden en proceso: componentes del BOM con cantidad requerida (con rendimiento del lote y conversión de unidades/densidad, igual que calcularRequerimientosProduccion en js/produccion.js), disponibilidad y lotes a surtir con política de equilibrio FIFO/FEFO. Columna criterio indica cuál aplicó.';

commit;

-- =====================================================================
--  Prueba (opcional) — cambia :id por una orden en proceso
-- =====================================================================
-- select producto_nombre, unidad, cantidad_requerida, total_disponible, faltante,
--        numero_lote, tomar_de_lote, fecha_caducidad, criterio
-- from public.v_ot_orden_componentes
-- where orden_id = :id
-- order by producto_nombre, fecha_caducidad;
