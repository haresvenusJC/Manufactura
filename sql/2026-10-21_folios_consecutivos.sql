-- =====================================================================
--  Folios consecutivos (ascendentes) en lugar de folios aleatorios
--  Fecha: 2026-10-21  ·  Proyecto: Hares de México (Supabase)
--
--  Hasta hoy varios folios se armaban con los últimos 6 dígitos de la hora
--  en milisegundos ('OC-482913'): no crecen, no se ubican fácil. Ahora todos
--  salen de un contador por serie:  OC-000001, OC-000002, OC-000003 ...
--
--  Series:
--    OC       órdenes de compra          (app + al autorizar una requisición)
--    REQ      requisiciones de compra
--    PED      pedidos de venta
--    DEVCLI   devoluciones de cliente
--    DEVPROV  devoluciones a proveedor
--    PROD     documentos de cierre de producción (entrada y consumo de MP)
--    VTA / MER / SAL / AJU   salidas (venta, merma, general, ajuste) cuando el
--                            folio se deja vacío
--    ENT      entradas directas cuando el folio se deja vacío
--  (Las órdenes de producción ya eran consecutivas: OP-000001 ...)
--
--  Qué hace este archivo:
--   1. Tabla contadores_folios + siguiente_folio(serie) (asigna y avanza,
--      atómico: dos personas a la vez nunca reciben el mismo) y
--      proximo_folio(serie) (solo lo muestra, no avanza).
--   2. Siembra cada contador con lo que ya existe, para que el siguiente
--      folio continúe y no arranque en 1 con cientos de registros.
--   3. Cambia, dentro de las funciones ya existentes, el folio aleatorio de
--      la OC (requisicion_autorizar) y de las devoluciones por el
--      consecutivo — sin reescribir las funciones.
--
--  Los folios que ya existen NO se renombran (están citados en pólizas,
--  documentos y notas); solo los nuevos salen consecutivos.
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- 1. Contador por serie
-- ---------------------------------------------------------------------
create table if not exists public.contadores_folios (
    serie  text primary key,
    ultimo bigint not null default 0
);

alter table public.contadores_folios enable row level security;
drop policy if exists solo_lectura on public.contadores_folios;
create policy solo_lectura on public.contadores_folios for select to authenticated using (true);
revoke all    on public.contadores_folios from anon, authenticated;
grant  select on public.contadores_folios to authenticated;

create or replace function public.siguiente_folio(p_serie text)
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_serie text := upper(trim(coalesce(p_serie, '')));
    v_n     bigint;
begin
    if v_serie !~ '^[A-Z]{2,8}$' then
        raise exception 'Serie de folio no válida: "%"', p_serie;
    end if;
    insert into public.contadores_folios (serie, ultimo)
    values (v_serie, 1)
    on conflict (serie) do update set ultimo = public.contadores_folios.ultimo + 1
    returning ultimo into v_n;
    return v_serie || '-' || lpad(v_n::text, 6, '0');
end;
$$;

-- Solo muestra cuál sería el siguiente (no lo consume): sirve para ponerlo de sugerencia en un campo.
create or replace function public.proximo_folio(p_serie text)
returns text
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
    v_serie text := upper(trim(coalesce(p_serie, '')));
    v_n     bigint;
begin
    if v_serie !~ '^[A-Z]{2,8}$' then
        raise exception 'Serie de folio no válida: "%"', p_serie;
    end if;
    select coalesce((select ultimo from public.contadores_folios where serie = v_serie), 0) + 1 into v_n;
    return v_serie || '-' || lpad(v_n::text, 6, '0');
end;
$$;

revoke all     on function public.siguiente_folio(text) from public, anon;
grant  execute on function public.siguiente_folio(text) to authenticated;
revoke all     on function public.proximo_folio(text)   from public, anon;
grant  execute on function public.proximo_folio(text)   to authenticated;


-- ---------------------------------------------------------------------
-- 2. Siembra: cada contador arranca en lo que ya hay registrado
-- ---------------------------------------------------------------------
do $$
declare
    r   record;
    v_n bigint;
begin
    for r in
        select * from (values
            ('OC',      'ordenes_compra'),
            ('REQ',     'requisiciones_compra'),
            ('PED',     'pedidos_venta'),
            ('DEVCLI',  'devoluciones_cliente'),
            ('DEVPROV', 'devoluciones_proveedor')
        ) as t(serie, tabla)
    loop
        if to_regclass('public.' || r.tabla) is not null then
            execute format('select count(*) from public.%I', r.tabla) into v_n;
            insert into public.contadores_folios (serie, ultimo) values (r.serie, v_n)
            on conflict (serie) do update set ultimo = greatest(public.contadores_folios.ultimo, excluded.ultimo);
        end if;
    end loop;

    -- Documentos de cierre de producción: uno por cada orden cerrada.
    if to_regclass('public.documentos') is not null then
        select count(*) into v_n from public.documentos where tipo_movimiento = 'entrada_produccion';
        insert into public.contadores_folios (serie, ultimo) values ('PROD', v_n)
        on conflict (serie) do update set ultimo = greatest(public.contadores_folios.ultimo, excluded.ultimo);
    end if;
end $$;


-- ---------------------------------------------------------------------
-- 3. Funciones existentes: reemplaza el folio aleatorio por el consecutivo
--    (parche sobre el texto de la función, para no reescribirla entera).
-- ---------------------------------------------------------------------
do $$
declare
    r       record;
    v_def   text;
    v_nuevo text;
    v_par   text[];
    v_pares text[][] := array[
        -- [función, texto viejo, texto nuevo]
        ['requisicion_autorizar',           $a$'OC-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6)$a$,      $b$public.siguiente_folio('OC')$b$],
        ['registrar_devolucion_cliente',    $a$'DEVCLI-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6)$a$,  $b$public.siguiente_folio('DEVCLI')$b$],
        ['registrar_devolucion_proveedor',  $a$'DEVPROV-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6)$a$, $b$public.siguiente_folio('DEVPROV')$b$]
    ];
    i int;
begin
    for i in 1 .. array_length(v_pares, 1) loop
        for r in
            select p.oid
              from pg_proc p
              join pg_namespace n on n.oid = p.pronamespace
             where n.nspname = 'public' and p.proname = v_pares[i][1]
        loop
            v_def := pg_get_functiondef(r.oid);
            if position(v_pares[i][2] in v_def) = 0 then
                raise notice 'Función %: ya usa folio consecutivo (o su texto es distinto); no se toca.', v_pares[i][1];
            else
                v_nuevo := replace(v_def, v_pares[i][2], v_pares[i][3]);
                execute v_nuevo;
                raise notice 'Función %: folio consecutivo aplicado.', v_pares[i][1];
            end if;
        end loop;
    end loop;
end $$;

commit;

-- Para revisar después de correrla:
--   select * from public.contadores_folios order by serie;
--   select public.proximo_folio('OC');
