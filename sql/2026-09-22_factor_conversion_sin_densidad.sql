-- =====================================================================
--  factor_conversion_bom(): sin densidad capturada, volumen <-> masa se
--  toma como agua (1 kg/L) RESPETANDO la escala de cada unidad.
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Idempotente (create or replace). La vista v_ot_orden_componentes
--  (sql/2026-09-22_ot_componentes_conversion.sql) la usa tal cual: no hay
--  que volver a crearla.
--
--  Problema: sin densidad se tomaba el NÚMERO 1 a 1 aunque las unidades
--  fueran de distinta escala: "Sabor Fresa Kiwi 41 Mililitros" con
--  inventario en Kilogramos pedía 41 kg en vez de 0.041 kg.
--  Réplica de factorConversion() de js/conversion-unidades.js — si se
--  cambia una, cambiar la otra.
-- =====================================================================

begin;

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
        -- Sin densidad: como agua (1 kg/L) respetando la escala (41 mL -> 0.041 kg, no 41 kg).
        return bo / bd;
    end if;
    return 1;   -- unidades no convertibles (ej. Piezas vs kg): 1 a 1 (Producción avisa en pantalla)
end;
$$;

grant execute on function public.factor_conversion_bom(text, text, text, text, numeric, numeric) to anon, authenticated;

commit;
