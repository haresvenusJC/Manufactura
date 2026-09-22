-- =====================================================================
--  Ajuste de BOM: los 3 granel de aceite, de Litros a Kilogramos
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  AJUSTE ÚNICO. Corregir los renglones del BOM que dicen "Litros" cuando
--  el inventario del insumo se lleva en Kilogramos (glicerina,
--  monopropilenglicol, sorbitol y sabores). El sistema no puede convertir
--  litros a kilos sin la densidad, así que hoy los toma 1 a 1 y descuenta
--  de menos. Aquí se reescriben en kilogramos.
--
--  ANTES DE CORRERLO — llena los kilos:
--    Donde dice  null  en la lista de abajo, escribe los KILOS REALES de ese
--    insumo para la fórmula completa (lo que pesas, o litros × densidad de la
--    ficha técnica del insumo). Las filas que dejes en  null  NO se tocan,
--    así que puedes correr el archivo por partes.
--
--  LITROS POR FÓRMULA (v_litros_por_lote):
--    El BOM de un producto describe UNA unidad de ese producto. Estos granel
--    se llevan en Litros y su fórmula suma ~14.6 L (rinde 15 L), o sea que está
--    capturada por LOTE, no por litro. Con 15, cada renglón se guarda por
--    litro de granel (kilos ÷ 15): así "cantidad a producir = 15" (litros)
--    pide justo los kilos del lote, y el terminado consume su granel en
--    litros con el costo por litro correcto. Si prefieres dejar la fórmula
--    por lote (producir "1"), pon 1.
--
--  Idempotente: correrlo de nuevo con los mismos kilos deja lo mismo.
--  Pégalo en Supabase -> SQL Editor.
-- =====================================================================
begin;

do $$
declare
    v_litros_por_lote numeric := 15;     -- ver la nota de arriba (1 = dejar por lote)
    v_kg_id           text;
    r                 record;
begin
    select id::text into v_kg_id
      from public.unidades_medida
     where lower(nombre) like 'kilogramo%'
     limit 1;
    if v_kg_id is null then
        raise exception 'No encontré la unidad "Kilogramos" en unidades_medida.';
    end if;

    for r in
        select * from (values
            -- (producto que lleva la fórmula,                          componente,               kilos por fórmula completa)
            ('Granel Aceite Lov/Hot Kiss Fresa Kiwi 15 Litros', 'Glicerina Vegetal Usp',    null::numeric),   -- hoy: 13.7 Litros
            ('Granel Aceite Lov/Hot Kiss Fresa Kiwi 15 Litros', 'Monopropilenglicol Usp',   null::numeric),   -- hoy: 0.547 Litros
            ('Granel Aceite Lov/Hot Kiss Fresa Kiwi 15 Litros', 'Sabor Fresa Kiwi',         null::numeric),   -- hoy: 0.041 Litros
            ('Granel Aceite Lov/Hot Kiss Fresa Kiwi 15 Litros', 'Sorbitol 70%',             null::numeric),   -- hoy: 0.342 Litros

            ('Granel Aceite Lov/Hot Piña Colada 15 Litros',     'Glicerina Vegetal Usp',    null::numeric),   -- hoy: 13.7 Litros
            ('Granel Aceite Lov/Hot Piña Colada 15 Litros',     'Monopropilenglicol Usp',   null::numeric),   -- hoy: 0.547 Litros
            ('Granel Aceite Lov/Hot Piña Colada 15 Litros',     'Sabor Piña Colada',        null::numeric),   -- hoy: 0.041 Litros
            ('Granel Aceite Lov/Hot Piña Colada 15 Litros',     'Sorbitol 70%',             null::numeric),   -- hoy: 0.342 Litros

            ('Granel Aceite Sey Chocolate 15 Litros',           'Glicerina Vegetal Usp',    null::numeric),   -- hoy: 13.7 Litros
            ('Granel Aceite Sey Chocolate 15 Litros',           'Monopropilenglicol Usp',   null::numeric),   -- hoy: 0.547 Litros
            ('Granel Aceite Sey Chocolate 15 Litros',           'Sabor Chocolate',          null::numeric),   -- hoy: 0.041 Litros
            ('Granel Aceite Sey Chocolate 15 Litros',           'Sorbitol 70%',             null::numeric)    -- hoy: 0.342 Litros
        ) as t(producto, componente, kg_por_formula)
    loop
        if r.kg_por_formula is null then
            continue;                                   -- sin kilos capturados: no se toca
        end if;
        if r.kg_por_formula <= 0 then
            raise exception 'Los kilos de "% / %" deben ser mayores a 0.', r.producto, r.componente;
        end if;

        update public.bom b
           set cantidad_requerida = round(r.kg_por_formula / v_litros_por_lote, 6),
               unidad_medida      = v_kg_id
          from public.productos p, public.productos c
         where b.producto_id = p.id
           and b.componente_id = c.id
           and p.nombre = r.producto
           and c.nombre = r.componente;

        if not found then
            raise notice 'No encontré el renglón: % / % (¿cambió el nombre?)', r.producto, r.componente;
        else
            raise notice 'Actualizado: % / % -> % kg por formula', r.producto, r.componente, r.kg_por_formula;
        end if;
    end loop;
end $$;

commit;

-- Revisión: cómo quedaron los granel (las unidades ya deben coincidir con el inventario).
select p.nombre as producto, c.nombre as componente, b.cantidad_requerida,
       ub.nombre as unidad_bom, us.nombre as unidad_inventario,
       case when b.unidad_medida = c.unidad_medida_id::text then 'OK' else 'PENDIENTE' end as estado
  from public.bom b
  join public.productos p  on p.id = b.producto_id
  join public.productos c  on c.id = b.componente_id
  left join public.unidades_medida ub on ub.id::text = b.unidad_medida
  left join public.unidades_medida us on us.id = c.unidad_medida_id
 where p.nombre like 'Granel Aceite%'
 order by p.nombre, c.nombre;
