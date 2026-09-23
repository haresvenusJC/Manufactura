-- =====================================================================
--  "Semiterminado" pasa a ser un TIPO propio: productos.tipo = 'semiterminado'
--  Fecha: 2026-09-24  ·  Proyecto: Hares de México (Supabase)
--
--  Antes: semiterminado = tipo 'producto' + es_semiterminado = true.
--  Ahora: tipo 'semiterminado' (siempre abastecimiento 'fabricado').
--
--  Esta migración (paso 1 de 2):
--   1) Deja que la columna tipo acepte 'semiterminado' (si tiene una regla
--      de valores permitidos, la amplía conservando los que ya tenía).
--   2) Convierte a tipo 'semiterminado' los productos FABRICADOS que ya
--      eran semiterminados o cuyo nombre dice "granel".
--   3) Cuenta de inventario 115.02 solo si no tienen existencia
--      (los que tengan existencia en otra cuenta se ajustan a mano).
--   4) Reglas: semiterminado ⇒ fabricado; el trigger de altas lo respeta.
--   5) Puente temporal: mantiene es_semiterminado = (tipo = 'semiterminado')
--      mientras se publica el código nuevo (y convierte lo que mande una
--      pantalla vieja en caché). La columna se borra en el paso 2:
--      sql/2026-09-24b_quitar_es_semiterminado.sql
--   6) Vista v_productos_bom y cuadre kardex vs. balanza leen el tipo
--      (semiterminado sin cuenta → 115.02).
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
--  Al final lista funciones/vistas VIVAS que comparan el tipo o usan la
--  bandera: revisarlas antes del paso 2.
-- =====================================================================
begin;

-- Si el paso 2 ya se corrió (no existe la bandera), esta no hace falta.
do $$
begin
    if not exists (select 1 from information_schema.columns
                    where table_schema = 'public' and table_name = 'productos' and column_name = 'es_semiterminado') then
        raise exception 'productos.es_semiterminado ya no existe: el cambio a tipo semiterminado ya está aplicado (paso 2 corrido). No hace falta correr esta migración.';
    end if;
end $$;

-- ---------------------------------------------------------------------
-- 1. La columna tipo acepta 'semiterminado'
-- ---------------------------------------------------------------------
do $$
declare
    v_tipo_dato text;
    r record;
    v_valores text[];
begin
    select format_type(a.atttypid, a.atttypmod) into v_tipo_dato
      from pg_attribute a
     where a.attrelid = 'public.productos'::regclass and a.attname = 'tipo' and not a.attisdropped;

    if exists (select 1 from pg_attribute a join pg_type t on t.oid = a.atttypid
                where a.attrelid = 'public.productos'::regclass and a.attname = 'tipo' and t.typtype = 'e') then
        raise exception 'productos.tipo es un ENUM (%). Corre primero, sola: alter type % add value if not exists ''semiterminado''; y luego esta migración.',
            v_tipo_dato, v_tipo_dato;
    end if;

    -- Reglas CHECK de la tabla que limitan los valores de tipo (sin tocar la vieja de semiterminado).
    for r in
        select c.conname, pg_get_constraintdef(c.oid) as def
          from pg_constraint c
         where c.conrelid = 'public.productos'::regclass
           and c.contype = 'c'
           and c.conname <> 'productos_semiterminado_check'
           and pg_get_constraintdef(c.oid) ~* '\ytipo\y'
           and pg_get_constraintdef(c.oid) ~* '''(producto|materia_prima|insumo)'''
           and pg_get_constraintdef(c.oid) !~* '''semiterminado'''
    loop
        select array_agg(distinct m[1]) into v_valores
          from regexp_matches(r.def, '''([^'']+)''', 'g') as m;
        v_valores := array_append(v_valores, 'semiterminado');
        execute format('alter table public.productos drop constraint %I', r.conname);
        execute format('alter table public.productos add constraint %I check (tipo is null or tipo = any (%L::text[]))',
                       r.conname, v_valores);
        raise notice 'Regla % ampliada: %', r.conname, v_valores;
    end loop;
end $$;

-- La regla vieja exigía tipo = 'producto' para ser semiterminado.
alter table public.productos drop constraint if exists productos_semiterminado_check;

-- ---------------------------------------------------------------------
-- 2. Convertir los semiterminados/graneles que se FABRICAN
-- ---------------------------------------------------------------------
--    Por nombre ("granel") solo la PRIMERA vez que se corre (aún no existe el
--    puente del punto 5): si la vuelves a correr no regresa a semiterminado un
--    granel que después cambiaste a mano.
do $$
declare
    v_primera boolean := not exists (select 1 from pg_trigger
                                      where tgname = '_a_puente_tipo_semiterminado'
                                        and tgrelid = 'public.productos'::regclass);
begin
    update public.productos
       set tipo = 'semiterminado',
           abastecimiento = 'fabricado',
           es_semiterminado = true
     where tipo = 'producto'
       and coalesce(abastecimiento, 'fabricado') = 'fabricado'
       and (coalesce(es_semiterminado, false) or (v_primera and nombre ilike '%granel%'));
end $$;

-- ---------------------------------------------------------------------
-- 3. Cuenta 115.02 (inventario de semiterminados) solo sin existencia
-- ---------------------------------------------------------------------
update public.productos p
   set cuenta_inventario_id = c.id
  from public.cuentas_contables c
 where c.codigo = '115.02'
   and p.tipo = 'semiterminado'
   and coalesce(p.stock_actual, 0) = 0
   and p.cuenta_inventario_id is distinct from c.id;

-- ---------------------------------------------------------------------
-- 4. Reglas: semiterminado siempre fabricado; default de altas
-- ---------------------------------------------------------------------
do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'productos_semiterminado_fabricado_check') then
        alter table public.productos
            add constraint productos_semiterminado_fabricado_check
            check (tipo is distinct from 'semiterminado' or abastecimiento = 'fabricado');
    end if;
end $$;

create or replace function public.trg_productos_abastecimiento_default()
returns trigger
language plpgsql
as $$
begin
    if new.abastecimiento is null then
        new.abastecimiento := case when new.tipo in ('producto', 'semiterminado') then 'fabricado' else 'comprado' end;
    end if;
    return new;
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Puente temporal tipo <-> es_semiterminado (se quita en el paso 2)
--    Corre ANTES que el default de abastecimiento (orden alfabético: _a... < trg_...).
-- ---------------------------------------------------------------------
create or replace function public._puente_tipo_semiterminado()
returns trigger
language plpgsql
as $$
begin
    if tg_op = 'UPDATE' and new.tipo is distinct from old.tipo then
        null;                                   -- cambió el tipo: manda el tipo
    elsif coalesce(new.es_semiterminado, false) and new.tipo = 'producto' then
        new.tipo := 'semiterminado';            -- pantalla vieja marcó la casilla
    elsif tg_op = 'UPDATE' and not coalesce(new.es_semiterminado, false)
          and coalesce(old.es_semiterminado, false) and new.tipo = 'semiterminado' then
        new.tipo := 'producto';                 -- pantalla vieja quitó la casilla
    end if;
    new.es_semiterminado := (new.tipo = 'semiterminado');
    if new.tipo = 'semiterminado' then
        new.abastecimiento := 'fabricado';
    end if;
    return new;
end;
$$;

drop trigger if exists _a_puente_tipo_semiterminado on public.productos;
create trigger _a_puente_tipo_semiterminado
    before insert or update on public.productos
    for each row execute function public._puente_tipo_semiterminado();

-- ---------------------------------------------------------------------
-- 6a. Vista de clasificación: por tipo (sin la bandera)
-- ---------------------------------------------------------------------
drop view if exists public.v_productos_bom;
create view public.v_productos_bom
with (security_invoker = true) as
select p.id,
       p.sku,
       p.nombre,
       p.tipo,
       p.abastecimiento,
       case
           when coalesce(p.tipo, 'materia_prima') = 'materia_prima'          then 'Materia prima'
           when p.tipo = 'semiterminado'                                     then 'Semiterminado'
           when p.tipo <> 'producto'                                         then 'Insumo / componente'
           when p.abastecimiento = 'comprado'                                then 'Terminado comprado (reventa)'
           else                                                                   'Terminado fabricado'
       end as clasificacion,
       coalesce(c.n, 0) as n_componentes,
       coalesce(u.n, 0) as usado_en_n_productos,
       case
           when coalesce(p.tipo, 'materia_prima') not in ('producto', 'semiterminado') then 'no aplica'
           when p.abastecimiento = 'comprado' and coalesce(c.n, 0) > 0       then 'revisar: comprado con BOM'
           when p.abastecimiento = 'comprado'                                then 'no aplica'
           when coalesce(c.n, 0) > 0                                         then 'con BOM'
           else                                                                   'SIN BOM'
       end as estado_bom
  from public.productos p
  left join (select producto_id,   count(*) as n from public.bom group by producto_id)   c on c.producto_id   = p.id
  left join (select componente_id, count(*) as n from public.bom group by componente_id) u on u.componente_id = p.id;

revoke all    on public.v_productos_bom from anon;
grant  select on public.v_productos_bom to authenticated;

-- ---------------------------------------------------------------------
-- 6b. Cuadre kardex vs. balanza (copia de 2026-09-23_candados_cuadre_inventario.sql;
--     único cambio: semiterminado sin cuenta → 115.02)
-- ---------------------------------------------------------------------
create or replace function public.cuadre_inventario_contable(p_hasta date)
returns table (cuenta_id bigint, codigo text, nombre text, kardex numeric, balanza numeric, diferencia numeric)
language sql
stable
security definer
set search_path = public, extensions
as $$
    with c as (
        select (select id from public.cuentas_contables where codigo = '115.01') as c01,
               (select id from public.cuentas_contables where codigo = '115.02') as c02,
               (select id from public.cuentas_contables where codigo = '115.04') as c04
    ),
    prod as (
        select p.id, coalesce(p.cuenta_inventario_id,
                              case p.tipo when 'producto' then c.c04
                                          when 'semiterminado' then coalesce(c.c02, c.c04)
                                          else c.c01 end) as cta
          from public.productos p cross join c
    ),
    kx as (
        select pr.cta, sum(coalesce(mi.cantidad, 0) * coalesce(mi.costo_unitario, 0)) as valor
          from public.movimientos_inventario mi
          join prod pr on pr.id = mi.producto_id
         where mi.created_at < ((p_hasta + 1)::timestamp at time zone 'America/Mexico_City')
         group by pr.cta
    ),
    bz as (
        select pm.cuenta_id as cta, sum(coalesce(pm.cargo, 0) - coalesce(pm.abono, 0)) as neto
          from public.poliza_movimientos pm
          join public.polizas p on p.id = pm.poliza_id
         where p.fecha <= p_hasta
           and pm.cuenta_id in (select distinct cta from prod where cta is not null)
           and public.poliza_en_saldo(p.id)
         group by pm.cuenta_id
    )
    select cc.id, cc.codigo::text, cc.nombre::text,
           round(coalesce(kx.valor, 0), 2),
           round(coalesce(bz.neto, 0) * case when cc.naturaleza = 'A' then -1 else 1 end, 2),
           round(coalesce(bz.neto, 0) * case when cc.naturaleza = 'A' then -1 else 1 end - coalesce(kx.valor, 0), 2)
      from public.cuentas_contables cc
      left join kx on kx.cta = cc.id
      left join bz on bz.cta = cc.id
     where cc.id in (select distinct cta from prod where cta is not null);
$$;
revoke all     on function public.cuadre_inventario_contable(date) from public;
grant  execute on function public.cuadre_inventario_contable(date) to authenticated;

comment on column public.productos.tipo is
    'producto (terminado) | semiterminado (granel: se fabrica y lo consumen otros) | materia_prima | insumo';

commit;

-- ---------------------------------------------------------------------
-- Revisión (se ve en Supabase porque es lo último que corre):
-- funciones y vistas VIVAS que comparan el tipo o usan es_semiterminado.
-- Si sale alguna distinta de _puente_tipo_semiterminado, pásamela antes del paso 2.
-- ---------------------------------------------------------------------
select 'funcion' as que, p.proname::text as nombre
  from pg_proc p
 where p.pronamespace = 'public'::regnamespace
   and p.proname not in ('_puente_tipo_semiterminado', 'trg_productos_abastecimiento_default', 'cuadre_inventario_contable')
   and (p.prosrc ilike '%es_semiterminado%'
        or p.prosrc ~* 'tipo\s*(=|<>|!=|in)\s*\(?\s*''(producto|materia_prima|insumo)''')
union all
select 'vista', v.table_name::text
  from information_schema.views v
 where v.table_schema = 'public'
   and v.table_name <> 'v_productos_bom'
   and (v.view_definition ilike '%es_semiterminado%'
        or v.view_definition ~* 'tipo\s*(=|<>|in)\s*\(?\s*''producto''')
union all
select 'semiterminados ahora', count(*)::text from public.productos where tipo = 'semiterminado';
