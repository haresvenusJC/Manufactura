-- =====================================================================
--  Liga cada unidad del ERP (unidades_medida) con su clave SAT (c_ClaveUnidad)
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  ENTREGA 1 de 5. Correr DESPUÉS de cargar los datos de c_clave_unidad
--  (sql/2026-10-23_catalogos_sat_datos_unidad.sql).
--
--  - Agrega unidades_medida.clave_sat (opcional, llave foránea al catálogo).
--  - Propone la clave de las unidades más comunes SOLO donde está vacía,
--    por nombre (Piezas → H87, Kilogramos → KGM...). No pisa nada que ya
--    hayas puesto y no inventa unidades. Lo propuesto se revisa y corrige
--    en Configuración → Tablas → Unidades de medida → "✏️ Editar / agregar".
--  - Las unidades que no reconoce las lista en un NOTICE para ligarlas a mano.
--  Idempotente.
-- =====================================================================
begin;

alter table public.unidades_medida
    add column if not exists clave_sat text;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'unidades_medida_clave_sat_fk') then
        alter table public.unidades_medida
            add constraint unidades_medida_clave_sat_fk
            foreign key (clave_sat) references public.c_clave_unidad (clave);
    end if;
end $$;

comment on column public.unidades_medida.clave_sat is
  'ClaveUnidad del SAT (c_ClaveUnidad) que se imprime y se espera en los CFDI para esta unidad.';

do $$
declare
    v_n int;
    r record;
begin
    if (select count(*) from public.c_clave_unidad) = 0 then
        raise exception 'Primero carga sql/2026-10-23_catalogos_sat_datos_unidad.sql (c_clave_unidad está vacía).';
    end if;

    with mapa(patron, clave) as (values
        ('pieza|piezas|pza|pzas|pz|unidad|unidades', 'H87'),
        ('kilogramo|kilogramos|kilo|kilos|kg|kgs', 'KGM'),
        ('gramo|gramos|g|gr|grs', 'GRM'),
        ('miligramo|miligramos|mg|mgs', 'MGM'),
        ('litro|litros|l|lt|lts', 'LTR'),
        ('mililitro|mililitros|ml|mls|cc', 'MLT'),
        ('metro|metros|m|mt|mts', 'MTR'),
        ('centimetro|centimetros|cm|cms', 'CMT'),
        ('milimetro|milimetros|mm|mms', 'MMT'),
        ('caja|cajas', 'XBX'),
        ('paquete|paquetes', 'XPK'),
        ('kit|kits', 'KT'),
        ('millar|millares|mil', 'MIL'),
        ('docena|docenas', 'DZN'),
        ('tonelada|toneladas|ton|tons', 'TNE'),
        ('libra|libras|lb|lbs', 'LBR'),
        ('onza|onzas|oz', 'ONZ'),
        ('galon|galones|gal|gals', 'GLL'),
        ('par|pares', 'PR'),
        ('rollo|rollos', 'XRO'),
        ('tambo|tambos|tambor|tambores', 'XDR'),
        ('saco|sacos', 'XSA'),
        ('bolsa|bolsas', 'XBG'),
        ('botella|botellas', 'XBO'),
        ('tubo|tubos', 'XTU'),
        ('juego|juegos|conjunto|conjuntos', 'SET'),
        ('metro cuadrado|metros cuadrados|m2', 'MTK'),
        ('tarima|tarimas|pallet|pallets', 'XPX')
    )
    update public.unidades_medida u
       set clave_sat = m.clave
      from mapa m
     where u.clave_sat is null
       and public._sat_norm(u.nombre) = any (string_to_array(m.patron, '|'))
       and exists (select 1 from public.c_clave_unidad c where c.clave = m.clave);
    get diagnostics v_n = row_count;
    raise notice 'Unidades con clave SAT propuesta: %', v_n;

    for r in select nombre from public.unidades_medida where clave_sat is null order by nombre loop
        raise notice 'Sin clave SAT (ligar a mano): %', r.nombre;
    end loop;
end $$;

commit;
