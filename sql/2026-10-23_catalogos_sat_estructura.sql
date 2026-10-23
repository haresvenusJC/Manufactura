-- =====================================================================
--  Catálogos SAT de unidades (c_ClaveUnidad) y de productos/servicios
--  (c_ClaveProdServ) — ESTRUCTURA, BUSCADORES Y LIGA CON unidades_medida
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  ENTREGA 1 de 5 de "cotización del proveedor con su unidad y su factor".
--  Orden de corrida (pegar completo en Supabase -> SQL Editor):
--    1) ESTE archivo (tablas, índices, buscadores).
--    2) sql/2026-10-23_catalogos_sat_datos_unidad.sql   (2,418 unidades).
--    3) sql/2026-10-23_catalogos_sat_datos_prodserv_01..05.sql (52,513 claves; en cualquier orden).
--    4) sql/2026-10-23_catalogos_sat_vinculo_unidades.sql (liga unidades_medida con su clave SAT).
--
--  Rapidez: el catálogo NUNCA se baja al navegador. La app consulta las
--  funciones sat_buscar_unidad() / sat_buscar_prod_serv() (máx. 20 renglones),
--  que usan un índice por clave y otro trigrama por texto sin acentos.
--  Las claves que ya usas en productos / claves de proveedor salen primero.
--  Idempotente.
-- =====================================================================
begin;

create extension if not exists pg_trgm with schema extensions;

-- Texto de búsqueda: minúsculas, sin acentos, solo letras/dígitos/espacios.
-- IMMUTABLE para poder usarse en una columna generada y en el índice.
create or replace function public._sat_norm(p_texto text)
returns text language sql immutable parallel safe as $$
    select btrim(regexp_replace(
               translate(lower(coalesce(p_texto, '')),
                         'áàäâãéèëêíìïîóòöôõúùüûñç',
                         'aaaaaeeeeiiiiooooouuuunc'),
               '[^a-z0-9]+', ' ', 'g'))
$$;

-- ---------------------------------------------------------------------
-- c_ClaveUnidad — unidades de medida del CFDI (H87 Pieza, KGM Kilogramo...)
-- ---------------------------------------------------------------------
create table if not exists public.c_clave_unidad (
    clave          text primary key,
    nombre         text not null,
    descripcion    text,
    simbolo        text,
    vigente_desde  date,
    vigente_hasta  date,
    comun          boolean not null default false,   -- las habituales salen primero en el buscador
    busqueda       text generated always as (public._sat_norm(clave || ' ' || nombre || ' ' || coalesce(simbolo, ''))) stored
);
create index if not exists c_clave_unidad_busqueda_trgm
    on public.c_clave_unidad using gin (busqueda extensions.gin_trgm_ops);

-- ---------------------------------------------------------------------
-- c_ClaveProdServ — productos y servicios del SAT (8 dígitos, SIEMPRE texto:
-- hay claves que empiezan con cero, como 01010101)
-- ---------------------------------------------------------------------
create table if not exists public.c_clave_prod_serv (
    clave              text primary key check (clave ~ '^[0-9]{8}$'),
    descripcion        text not null,
    incluir_iva        text,
    incluir_ieps       text,
    complemento        text,
    vigente_desde      date,
    vigente_hasta      date,
    franja_fronteriza  boolean not null default false,
    palabras_similares text,
    busqueda           text generated always as (public._sat_norm(descripcion || ' ' || coalesce(palabras_similares, ''))) stored
);
create index if not exists c_clave_prod_serv_busqueda_trgm
    on public.c_clave_prod_serv using gin (busqueda extensions.gin_trgm_ops);
-- "empieza con" por clave (la llave primaria no sirve para LIKE con otra collation)
create index if not exists c_clave_prod_serv_clave_pref
    on public.c_clave_prod_serv (clave text_pattern_ops);

-- ---------------------------------------------------------------------
-- Permisos: lectura para todos los usuarios; edición (agregar una clave nueva
-- del SAT sin esperar un archivo) como el resto de los catálogos de la app.
-- ---------------------------------------------------------------------
alter table public.c_clave_unidad enable row level security;
alter table public.c_clave_prod_serv enable row level security;
drop policy if exists admin_all on public.c_clave_unidad;
create policy admin_all on public.c_clave_unidad for all to authenticated using (true) with check (true);
drop policy if exists admin_all on public.c_clave_prod_serv;
create policy admin_all on public.c_clave_prod_serv for all to authenticated using (true) with check (true);
grant select, insert, update on public.c_clave_unidad to authenticated;
grant select, insert, update on public.c_clave_prod_serv to authenticated;

-- ---------------------------------------------------------------------
-- Buscador de productos/servicios SAT.
--   · Solo dígitos  → claves que EMPIEZAN con ellos (24121807, 2412...).
--   · Texto         → todas las palabras, en cualquier orden y sin acentos.
--   · Orden         → las que ya usas (productos / claves de proveedor) primero,
--                     luego las específicas antes que las familias (terminan en 00).
--   · Mínimo 2 caracteres y máximo p_limit (tope 50) renglones.
-- ---------------------------------------------------------------------
create or replace function public.sat_buscar_prod_serv(p_q text, p_limit int default 20)
returns table (clave text, descripcion text, usada boolean, vigente boolean,
               incluir_iva text, incluir_ieps text, complemento text)
language plpgsql stable security invoker as $$
declare
    v_norm   text := public._sat_norm(p_q);
    v_limite int  := least(greatest(coalesce(p_limit, 20), 1), 50);
    v_pal    text[];
begin
    if length(replace(v_norm, ' ', '')) < 2 then return; end if;

    if v_norm ~ '^[0-9 ]+$' then
        return query
            select c.clave, c.descripcion,
                   (c.clave in (select p.clave_sat from public.productos p where p.clave_sat is not null)
                    or c.clave in (select k.clave_sat from public.producto_claves_proveedor k where k.clave_sat is not null)),
                   (c.vigente_hasta is null or c.vigente_hasta >= current_date),
                   c.incluir_iva, c.incluir_ieps, c.complemento
              from public.c_clave_prod_serv c
             where c.clave like replace(v_norm, ' ', '') || '%'
             order by c.clave
             limit v_limite;
        return;
    end if;

    v_pal := string_to_array(v_norm, ' ');
    return query
        with coincide as (
            select c.*
              from public.c_clave_prod_serv c
             where not exists (select 1 from unnest(v_pal) w where c.busqueda not like '%' || w || '%')
        ), usadas as (
            select clave_sat as clave from public.productos where clave_sat is not null
            union
            select clave_sat from public.producto_claves_proveedor where clave_sat is not null
        )
        select c.clave, c.descripcion,
               (u.clave is not null) as usada,
               (c.vigente_hasta is null or c.vigente_hasta >= current_date) as vigente,
               c.incluir_iva, c.incluir_ieps, c.complemento
          from coincide c
          left join usadas u on u.clave = c.clave
         order by (u.clave is null), (right(c.clave, 2) = '00'), length(c.descripcion), c.clave
         limit v_limite;
end;
$$;

-- Buscador de unidades SAT: por clave o por nombre/símbolo; usadas y comunes primero.
create or replace function public.sat_buscar_unidad(p_q text, p_limit int default 20)
returns table (clave text, nombre text, simbolo text, usada boolean, comun boolean, vigente boolean)
language plpgsql stable security invoker as $$
declare
    v_norm   text := public._sat_norm(p_q);
    v_limite int  := least(greatest(coalesce(p_limit, 20), 1), 50);
    v_pal    text[];
    v_usadas text[];
begin
    if length(replace(v_norm, ' ', '')) < 1 then return; end if;
    v_pal := string_to_array(v_norm, ' ');
    -- Puede no existir todavía unidades_medida.clave_sat (se crea en el paso 4): se ignora.
    begin
        execute 'select coalesce(array_agg(distinct clave_sat), ''{}'') from public.unidades_medida where clave_sat is not null'
           into v_usadas;
    exception when undefined_column then v_usadas := '{}';
    end;
    return query
        select c.clave, c.nombre, c.simbolo,
               (c.clave = any (v_usadas)) as usada, c.comun,
               (c.vigente_hasta is null or c.vigente_hasta >= current_date) as vigente
          from public.c_clave_unidad c
         where not exists (select 1 from unnest(v_pal) w where c.busqueda not like '%' || w || '%')
         order by (lower(c.clave) <> v_norm), (not (c.clave = any (v_usadas))), (not c.comun),
                  length(c.nombre), c.clave
         limit v_limite;
end;
$$;

grant execute on function public.sat_buscar_prod_serv(text, int) to authenticated;
grant execute on function public.sat_buscar_unidad(text, int) to authenticated;

commit;
