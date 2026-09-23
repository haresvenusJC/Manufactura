-- =====================================================================
--  APLICAR a todos los graneles con BOM lo que marca la revisión
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  Correr DESPUÉS de revisar sql/2026-09-23e_graneles_revision.sql.
--  Para cada producto cuyo nombre dice "granel" (o ya es semiterminado) y
--  tiene BOM, y cuya Unidad de Medida es de volumen o peso:
--   1) tipo = 'semiterminado', abastecimiento = 'fabricado' (solo si era producto o ya semiterminado)
--   2) rendimiento_lote_bom = lo que suma la receta (misma cuenta que 🧮)
--   3) cuenta de inventario = 115.02, SOLO si no tiene existencia (si tiene,
--      cambiarla descuadra el Auxiliar de inventarios: se deja igual)
--  No toca los que tienen la unidad en Pieza u otra no medible.
--  Idempotente: correrlo otra vez deja lo mismo. Al final muestra el resultado.
-- =====================================================================
drop table if exists _granel_sug;

begin;

create temporary table _granel_sug as
with um as (
    select id::text as id, nombre,
           case
             when lower(nombre) ~ '^(mililitros?|mls?|cc|litros?|lts?|l)$' then 'volumen'
             when lower(nombre) ~ '^(miligramos?|mgs?|kilogramos?|kilos?|kgs?|gramos?|grs?|g)$' then 'masa'
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
    select p.id, p.tipo, p.stock_actual, p.cuenta_inventario_id, up.familia, up.a_base
      from public.productos p
      join um up on up.id = p.unidad_medida_id::text
     where (p.nombre ilike '%granel%' or p.tipo = 'semiterminado')
       and p.tipo in ('producto', 'semiterminado')
       and up.familia is not null
       and exists (select 1 from public.bom b where b.producto_id = p.id)
),
suma as (
    select b.producto_id,
           sum(case when ub.familia = 'volumen' then b.cantidad_requerida * ub.a_base
                    when ub.familia = 'masa'    then b.cantidad_requerida * ub.a_base / coalesce(nullif(c.densidad_kg_l, 0), 1) end) as ml,
           sum(case when ub.familia = 'volumen' then b.cantidad_requerida * ub.a_base * coalesce(nullif(c.densidad_kg_l, 0), 1)
                    when ub.familia = 'masa'    then b.cantidad_requerida * ub.a_base end) as g
      from public.bom b
      join granel g on g.id = b.producto_id
      join public.productos c on c.id = b.componente_id
      left join um ub on ub.id = b.unidad_medida or lower(ub.nombre) = lower(b.unidad_medida)
     group by b.producto_id
)
select g.id,
       round(case g.familia when 'volumen' then s.ml / g.a_base else s.g / g.a_base end, 2) as rendimiento,
       coalesce(g.stock_actual, 0) > 0 as con_existencia
  from granel g join suma s on s.producto_id = g.id;

update public.productos p
   set tipo             = 'semiterminado',
       abastecimiento   = 'fabricado',
       rendimiento_lote_bom = case when t.rendimiento > 0 then t.rendimiento else p.rendimiento_lote_bom end
  from _granel_sug t
 where p.id = t.id;

update public.productos p
   set cuenta_inventario_id = (select id from public.cuentas_contables where codigo = '115.02')
  from _granel_sug t
 where p.id = t.id
   and not t.con_existencia
   and exists (select 1 from public.cuentas_contables where codigo = '115.02');

commit;

-- Resultado (se ve en Supabase porque es lo último que corre)
select p.id, p.nombre, p.tipo, p.rendimiento_lote_bom, cc.codigo as cuenta,
       case when t.con_existencia and cc.codigo is distinct from '115.02'
            then 'cuenta sin cambiar: tiene existencia (pedir póliza de reclasificación)' else 'ok' end as nota
  from _granel_sug t
  join public.productos p on p.id = t.id
  left join public.cuentas_contables cc on cc.id = p.cuenta_inventario_id
 order by p.nombre;

