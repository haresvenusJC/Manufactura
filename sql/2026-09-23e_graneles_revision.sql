-- =====================================================================
--  REVISIÓN (solo lectura) de todos los graneles con BOM
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  Correr ANTES de sql/2026-09-23f_graneles_aplicar.sql para ver qué va a
--  cambiar. No modifica nada.
--  "Granel" = producto cuyo nombre dice "granel" o ya marcado como
--  semiterminado, que tenga receta (BOM).
--  Tamaño de la tanda = misma cuenta que el análisis 🧮 del Catálogo: cada
--  renglón del BOM llevado a la unidad del granel con la densidad del
--  insumo (sin densidad = agua, 1 kg/L); piezas no cuentan.
-- =====================================================================
with um as (
    select id::text as id, nombre,
           case
             when lower(nombre) ~ '^(mililitros?|mls?|cc)$'      then 'volumen'
             when lower(nombre) ~ '^(litros?|lts?|l)$'           then 'volumen'
             when lower(nombre) ~ '^(miligramos?|mgs?)$'         then 'masa'
             when lower(nombre) ~ '^(kilogramos?|kilos?|kgs?)$'  then 'masa'
             when lower(nombre) ~ '^(gramos?|grs?|g)$'           then 'masa'
           end as familia,
           case
             when lower(nombre) ~ '^(mililitros?|mls?|cc)$'      then 1
             when lower(nombre) ~ '^(litros?|lts?|l)$'           then 1000
             when lower(nombre) ~ '^(miligramos?|mgs?)$'         then 0.001
             when lower(nombre) ~ '^(kilogramos?|kilos?|kgs?)$'  then 1000
             when lower(nombre) ~ '^(gramos?|grs?|g)$'           then 1
           end as a_base
      from public.unidades_medida
),
granel as (
    select p.*, up.nombre as unidad, up.familia, up.a_base
      from public.productos p
      left join um up on up.id = p.unidad_medida_id::text
     where (p.nombre ilike '%granel%' or coalesce(p.es_semiterminado, false))
       and exists (select 1 from public.bom b where b.producto_id = p.id)
),
renglon as (
    select b.producto_id, c.nombre as componente, b.cantidad_requerida as q,
           ub.familia, ub.a_base, c.densidad_kg_l as dens
      from public.bom b
      join granel g on g.id = b.producto_id
      join public.productos c on c.id = b.componente_id
      left join um ub on ub.id = b.unidad_medida or lower(ub.nombre) = lower(b.unidad_medida)
),
suma as (
    select producto_id,
           sum(case when familia = 'volumen' then q * a_base
                    when familia = 'masa'    then q * a_base / coalesce(nullif(dens, 0), 1) end) as ml,
           sum(case when familia = 'volumen' then q * a_base * coalesce(nullif(dens, 0), 1)
                    when familia = 'masa'    then q * a_base end) as g,
           string_agg(componente, ', ') filter (where familia is null) as sin_unidad_medible,
           string_agg(componente, ', ') filter (where familia is not null and coalesce(dens, 0) = 0) as sin_densidad,
           count(*) as componentes
      from renglon group by producto_id
)
select g.id, g.nombre, g.unidad,
       g.es_semiterminado                                   as semiterminado_hoy,
       g.rendimiento_lote_bom                               as rendimiento_hoy,
       case g.familia when 'volumen' then round(s.ml / g.a_base, 2)
                      when 'masa'    then round(s.g  / g.a_base, 2) end as rendimiento_sugerido,
       ci.codigo                                            as cuenta_hoy,
       g.stock_actual,
       case
         when g.familia is null then 'NO SE TOCA: la unidad no es de volumen/peso — cámbiala a Litros'
         when ci.codigo is distinct from '115.02' and coalesce(g.stock_actual, 0) > 0
              then 'Cuenta: se deja igual (tiene existencia; requiere póliza de reclasificación)'
         else 'ok'
       end                                                  as nota,
       s.componentes, s.sin_densidad, s.sin_unidad_medible
  from granel g
  join suma s on s.producto_id = g.id
  left join public.cuentas_contables ci on ci.id = g.cuenta_inventario_id
 order by g.nombre;
