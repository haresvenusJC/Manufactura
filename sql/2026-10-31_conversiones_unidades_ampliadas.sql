-- =====================================================================
--  Conversiones de unidades ampliadas (masa, volumen y longitud)
--  Fecha: 2026-10-31  ·  Proyecto: Hares de México (Supabase)
--
--  Réplica EXACTA de FAMILIAS_UNIDAD de js/conversion-unidades.js — si se
--  cambia una, cambiar la otra. Antes solo se conocían mg/g/kg y mL/L;
--  ahora también: tonelada, libra, onza (masa); centilitro, decilitro,
--  m³/dm³/cm³, onza fluida, galón US (volumen); mm, cm, m, km, pulgada,
--  pie y yarda (longitud, solo convierte con longitud).
--
--  - Nueva función public._unidad_familia_base(nombre): familia + factor a
--    la unidad base (g / mL / mm). Fuente única para origen y destino.
--  - public.factor_conversion_bom() se reemplaza (misma firma: la vista
--    v_ot_orden_componentes la sigue usando sin recrearla). Solo hay
--    "agua 1 kg/L / densidad" entre masa y volumen; longitud vs. masa/
--    volumen, o conteos (Piezas, Cajas, Paquetes), siguen 1 a 1.
--  - Onza = masa avoirdupois (28.349523125 g). Galón = US (3,785.411784 mL).
--    Tonelada = métrica (1,000 kg).
--  No toca datos. Idempotente. Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

create or replace function public._unidad_familia_base(p_nombre text)
returns table (familia text, a_base numeric)
language sql immutable as $$
    with n as (
        select regexp_replace(lower(translate(trim(coalesce(p_nombre, '')),
                   'ÁÉÍÓÚÜáéíóúü³', 'AEIOUUaeiouu3')), '\s+', ' ', 'g') as v
    )
    select f.familia, f.a_base::numeric from n, lateral (
        select case
            -- masa (g)
            when v ~ '^(miligramos?|mgs?)$'                          then 'masa'
            when v ~ '^(gramos?|grs?|g)$'                            then 'masa'
            when v ~ '^(kilogramos?|kilos?|kgs?)$'                   then 'masa'
            when v ~ '^(toneladas?|tons?)$'                          then 'masa'
            when v ~ '^(libras?|lbs?)$'                              then 'masa'
            when v ~ '^(onzas?|oz)$'                                 then 'masa'
            -- volumen (mL)
            when v ~ '^(mililitros?|mls?|cc|cm3|centimetros? cubicos?)$'          then 'volumen'
            when v ~ '^(centilitros?|cls?)$'                                      then 'volumen'
            when v ~ '^(decilitros?|dls?)$'                                       then 'volumen'
            when v ~ '^(litros?|lts?|l|dm3|decimetros? cubicos?)$'                then 'volumen'
            when v ~ '^(metros? cubicos?|m3)$'                                    then 'volumen'
            when v ~ '^(onzas? fluidas?|fl ?oz)$'                                 then 'volumen'
            when v ~ '^(galon|galones|gal|gals)$'                                 then 'volumen'
            -- longitud (mm)
            when v ~ '^(milimetros?|mms?)$'                          then 'longitud'
            when v ~ '^(centimetros?|cms?)$'                         then 'longitud'
            when v ~ '^(metros?|mts?|mtrs?|m)$'                      then 'longitud'
            when v ~ '^(kilometros?|kms?)$'                          then 'longitud'
            when v ~ '^(pulgadas?|pulg|in)$'                         then 'longitud'
            when v ~ '^(pies?|ft)$'                                  then 'longitud'
            when v ~ '^(yardas?|yds?)$'                              then 'longitud'
        end as familia,
        case
            when v ~ '^(miligramos?|mgs?)$'                          then 0.001
            when v ~ '^(gramos?|grs?|g)$'                            then 1
            when v ~ '^(kilogramos?|kilos?|kgs?)$'                   then 1000
            when v ~ '^(toneladas?|tons?)$'                          then 1000000
            when v ~ '^(libras?|lbs?)$'                              then 453.59237
            when v ~ '^(onzas?|oz)$'                                 then 28.349523125
            when v ~ '^(mililitros?|mls?|cc|cm3|centimetros? cubicos?)$'          then 1
            when v ~ '^(centilitros?|cls?)$'                                      then 10
            when v ~ '^(decilitros?|dls?)$'                                       then 100
            when v ~ '^(litros?|lts?|l|dm3|decimetros? cubicos?)$'                then 1000
            when v ~ '^(metros? cubicos?|m3)$'                                    then 1000000
            when v ~ '^(onzas? fluidas?|fl ?oz)$'                                 then 29.5735295625
            when v ~ '^(galon|galones|gal|gals)$'                                 then 3785.411784
            when v ~ '^(milimetros?|mms?)$'                          then 1
            when v ~ '^(centimetros?|cms?)$'                         then 10
            when v ~ '^(metros?|mts?|mtrs?|m)$'                      then 1000
            when v ~ '^(kilometros?|kms?)$'                          then 1000000
            when v ~ '^(pulgadas?|pulg|in)$'                         then 25.4
            when v ~ '^(pies?|ft)$'                                  then 304.8
            when v ~ '^(yardas?|yds?)$'                              then 914.4
        end as a_base
    ) f where f.familia is not null;
$$;

grant execute on function public._unidad_familia_base(text) to anon, authenticated;

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

    select f.familia, f.a_base into fo, bo from public._unidad_familia_base(v_orig) f;
    select f.familia, f.a_base into fd, bd from public._unidad_familia_base(coalesce(p_dest_nom, '')) f;

    if fo is not null and fd is not null then
        if fo = fd then return bo / bd; end if;
        if (fo = 'masa' and fd = 'volumen') or (fo = 'volumen' and fd = 'masa') then
            if v_dens > 0 then
                if fo = 'volumen' then return (bo * v_dens) / bd;    -- BOM en volumen, inventario en masa
                else return (bo / v_dens) / bd; end if;              -- BOM en masa, inventario en volumen
            end if;
            -- Sin densidad: como agua (1 kg/L) respetando la escala (41 mL -> 0.041 kg, no 41 kg).
            return bo / bd;
        end if;
    end if;
    return 1;   -- no convertibles (longitud vs. masa/volumen, Piezas vs. kg...): 1 a 1 (Producción avisa en pantalla)
end;
$$;

grant execute on function public.factor_conversion_bom(text, text, text, text, numeric, numeric) to anon, authenticated;

commit;
