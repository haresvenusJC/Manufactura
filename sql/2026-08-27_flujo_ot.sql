-- =====================================================================
--  Migración: dividir el flujo de Producción (orden  <->  orden de trabajo móvil)
--  Fecha: 2026-08-27
--  Proyecto: Hares de México (Supabase)
--
--  Este archivo NO lo ejecuta la aplicación. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--
--  Está dividido en 2 partes:
--    PARTE 1  -> columnas, tablas, vistas, funciones y permisos de admin.
--                NO rompe la app actual (anon sigue funcionando).
--    PARTE 2  -> activa RLS y quita el acceso directo de 'anon' a las tablas
--                base. A partir de aquí la app admin EXIGE login. Correr esta
--                parte solo cuando el nuevo front (login + móvil) ya esté
--                desplegado y exista el usuario admin.
--
--  NOTA sobre tipos: se asume que las PK 'id' de las tablas existentes son
--  bigint (int8), que es el default de Supabase. Si en tu esquema son int4,
--  cambia los 'bigint' de las FKs nuevas por 'integer'.
-- =====================================================================


-- =====================================================================
--  PARTE 1  (no destructiva)
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Extensiones
-- ---------------------------------------------------------------------
create extension if not exists pgcrypto;      -- crypt() / gen_salt() para el PIN


-- ---------------------------------------------------------------------
-- 1. empleados: hash del PIN (nunca se expone a 'anon')
-- ---------------------------------------------------------------------
alter table public.empleados
    add column if not exists pin_hash text;


-- ---------------------------------------------------------------------
-- 2. ordenes_produccion: ciclo de vida
-- ---------------------------------------------------------------------
alter table public.ordenes_produccion
    add column if not exists estado      text        not null default 'borrador',
    add column if not exists folio       text,
    add column if not exists abierta_at  timestamptz,
    add column if not exists cerrada_at  timestamptz;

-- Todas las órdenes que ya existían estaban efectivamente cerradas
-- (antes de este cambio la orden se creaba recién al terminar la producción).
update public.ordenes_produccion
   set estado = 'cerrada'
 where estado = 'borrador';

-- Folio legible para las que no tengan.
update public.ordenes_produccion
   set folio = 'OP-' || lpad(id::text, 6, '0')
 where folio is null;

alter table public.ordenes_produccion
    drop constraint if exists ordenes_produccion_estado_chk;
alter table public.ordenes_produccion
    add  constraint ordenes_produccion_estado_chk
         check (estado in ('borrador','en_proceso','cerrada','cancelada'));

-- Los costos se llenan al CERRAR: ya no son obligatorios al crear.
alter table public.ordenes_produccion alter column costo_unitario_final    drop not null;
alter table public.ordenes_produccion alter column costo_total_materiales  drop not null;
alter table public.ordenes_produccion alter column costo_total_mano_obra   drop not null;
alter table public.ordenes_produccion alter column empleados_involucrados  drop not null;


-- ---------------------------------------------------------------------
-- 3. orden_produccion_procesos: se crean al generar la orden;
--    los tiempos/costos se llenan al cerrar.
-- ---------------------------------------------------------------------
alter table public.orden_produccion_procesos alter column segundos_transcurridos drop not null;
alter table public.orden_produccion_procesos alter column costo_calculado        drop not null;


-- ---------------------------------------------------------------------
-- 4. registros_tiempo: intervalos de inicio/paro por empleado y proceso
-- ---------------------------------------------------------------------
create table if not exists public.registros_tiempo (
    id                          bigint generated always as identity primary key,
    orden_produccion_proceso_id bigint not null
        references public.orden_produccion_procesos (id) on delete cascade,
    empleado_id                 bigint not null
        references public.empleados (id),
    inicio                      timestamptz not null default now(),
    fin                         timestamptz,
    fuente                      text not null default 'movil'
        check (fuente in ('movil','admin')),
    created_at                  timestamptz not null default now(),
    check (fin is null or fin >= inicio)
);

create index if not exists registros_tiempo_proceso_idx
    on public.registros_tiempo (orden_produccion_proceso_id);

-- Un empleado no puede tener 2 cronómetros abiertos en el mismo proceso.
create unique index if not exists registros_tiempo_abierto_uq
    on public.registros_tiempo (orden_produccion_proceso_id, empleado_id)
    where fin is null;


-- ---------------------------------------------------------------------
-- 5. sesiones_ot: sesión ligera del móvil (el PIN viaja una sola vez)
-- ---------------------------------------------------------------------
create table if not exists public.sesiones_ot (
    token       uuid primary key default gen_random_uuid(),
    empleado_id bigint not null references public.empleados (id),
    creada_at   timestamptz not null default now(),
    expira_at   timestamptz not null default (now() + interval '12 hours')
);

create index if not exists sesiones_ot_empleado_idx on public.sesiones_ot (empleado_id);


-- ---------------------------------------------------------------------
-- 6. Vistas públicas para 'anon' (SIN columnas de costo)
--    Corren con permisos del dueño => no las filtra RLS.
-- ---------------------------------------------------------------------
create or replace view public.v_ot_empleados as
    select e.id, e.nombre
      from public.empleados e
     where e.activo is true
       and e.pin_hash is not null;

create or replace view public.v_ot_ordenes as
    select op.id,
           op.folio,
           op.numero_lote,
           op.cantidad_producida,
           p.nombre  as producto_nombre,
           op.abierta_at
      from public.ordenes_produccion op
      join public.productos p on p.id = op.producto_id
     where op.estado = 'en_proceso';

create or replace view public.v_ot_procesos as
    select opp.id,
           opp.orden_produccion_id,
           opp.proceso_nombre
      from public.orden_produccion_procesos opp;

create or replace view public.v_ot_proceso_empleados as
    select ope.orden_produccion_proceso_id,
           ope.empleado_id,
           e.nombre as empleado_nombre
      from public.orden_produccion_proceso_empleados ope
      join public.empleados e on e.id = ope.empleado_id;

create or replace view public.v_ot_registros as
    select rt.id,
           rt.orden_produccion_proceso_id,
           rt.empleado_id,
           rt.inicio,
           rt.fin
      from public.registros_tiempo rt;

grant select on
    public.v_ot_empleados,
    public.v_ot_ordenes,
    public.v_ot_procesos,
    public.v_ot_proceso_empleados,
    public.v_ot_registros
to anon, authenticated;


-- ---------------------------------------------------------------------
-- 7. RPCs
-- ---------------------------------------------------------------------

-- 7.1 set_pin_empleado: SOLO admin autenticado. Guarda el hash bcrypt.
create or replace function public.set_pin_empleado(p_empleado_id bigint, p_pin text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if coalesce(auth.role(), '') <> 'authenticated' then
        raise exception 'No autorizado.';
    end if;
    if p_pin !~ '^[0-9]{4}$' then
        raise exception 'El PIN debe tener exactamente 4 dígitos.';
    end if;

    update public.empleados
       set pin_hash = crypt(p_pin, gen_salt('bf'))
     where id = p_empleado_id;

    if not found then
        raise exception 'Empleado no encontrado.';
    end if;
end;
$$;

revoke all     on function public.set_pin_empleado(bigint, text) from public, anon;
grant  execute on function public.set_pin_empleado(bigint, text) to authenticated;


-- 7.2 ot_login: valida nombre(id)+PIN, crea sesión y devuelve el token.
create or replace function public.ot_login(p_empleado_id bigint, p_pin text)
returns table (token uuid, empleado_id bigint, empleado_nombre text)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_nombre text;
begin
    delete from public.sesiones_ot where expira_at < now();   -- limpieza oportunista

    select e.nombre
      into v_nombre
      from public.empleados e
     where e.id = p_empleado_id
       and e.activo is true
       and e.pin_hash is not null
       and e.pin_hash = crypt(p_pin, e.pin_hash);

    if v_nombre is null then
        raise exception 'Nombre o PIN incorrecto.';
    end if;

    return query
    insert into public.sesiones_ot (empleado_id)
    values (p_empleado_id)
    returning sesiones_ot.token, p_empleado_id, v_nombre;
end;
$$;

revoke all     on function public.ot_login(bigint, text) from public;
grant  execute on function public.ot_login(bigint, text) to anon, authenticated;


-- 7.3 ot_marcar: registra inicio/paro de un empleado en un proceso.
create or replace function public.ot_marcar(p_token uuid, p_proceso_id bigint, p_accion text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_estado_orden text;
    v_reg record;
begin
    select s.empleado_id
      into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token
       and s.expira_at > now();

    if v_empleado_id is null then
        raise exception 'SESION_EXPIRADA';
    end if;

    select op.estado
      into v_estado_orden
      from public.orden_produccion_procesos opp
      join public.ordenes_produccion op on op.id = opp.orden_produccion_id
     where opp.id = p_proceso_id;

    if v_estado_orden is null then
        raise exception 'El proceso no existe.';
    end if;
    if v_estado_orden <> 'en_proceso' then
        raise exception 'La orden ya no está en proceso.';
    end if;

    if not exists (
        select 1 from public.orden_produccion_proceso_empleados ope
         where ope.orden_produccion_proceso_id = p_proceso_id
           and ope.empleado_id = v_empleado_id
    ) then
        raise exception 'No estás asignado a este proceso.';
    end if;

    if p_accion = 'iniciar' then
        begin
            insert into public.registros_tiempo (orden_produccion_proceso_id, empleado_id, fuente)
            values (p_proceso_id, v_empleado_id, 'movil')
            returning * into v_reg;
        exception when unique_violation then
            raise exception 'Ya tienes un cronómetro abierto en este proceso.';
        end;
        return jsonb_build_object('estado', 'trabajando', 'registro_id', v_reg.id, 'inicio', v_reg.inicio);

    elsif p_accion = 'parar' then
        update public.registros_tiempo rt
           set fin = now()
         where rt.orden_produccion_proceso_id = p_proceso_id
           and rt.empleado_id = v_empleado_id
           and rt.fin is null
        returning * into v_reg;

        if not found then
            raise exception 'No tenías un cronómetro abierto en este proceso.';
        end if;
        return jsonb_build_object('estado', 'detenido', 'registro_id', v_reg.id,
                                  'inicio', v_reg.inicio, 'fin', v_reg.fin);
    else
        raise exception 'Acción inválida.';
    end if;
end;
$$;

revoke all     on function public.ot_marcar(uuid, bigint, text) from public;
grant  execute on function public.ot_marcar(uuid, bigint, text) to anon, authenticated;


-- ---------------------------------------------------------------------
-- 8. Permisos para el admin autenticado (aditivo; no quita nada a anon todavía)
-- ---------------------------------------------------------------------
grant all on all tables    in schema public to authenticated;
grant all on all sequences in schema public to authenticated;

commit;


-- =====================================================================
--  PARTE 2  (DESTRUCTIVA para la app sin login)
--  Correr SOLO cuando el nuevo front y el usuario admin ya existan.
-- =====================================================================
/*
begin;

-- Activa RLS + política "admin puede todo" en cada tabla de la app,
-- y quita el acceso directo de 'anon' (que pasará a usar solo vistas + RPCs).
do $$
declare
    t text;
    tablas text[] := array[
        'productos','proveedores','bom','unidades_medida','monedas',
        'lotes_inventario','movimientos_inventario','documentos','documento_detalles',
        'tipos_movimiento','plantillas_documentos','plantillas_impresion',
        'ordenes_produccion','orden_produccion_procesos','orden_produccion_proceso_empleados',
        'procesos_produccion','empleados','registros_tiempo','sesiones_ot'
    ];
begin
    foreach t in array tablas loop
        if to_regclass('public.' || t) is null then
            continue;   -- la tabla no existe en este esquema, se ignora
        end if;

        execute format('alter table public.%I enable row level security', t);
        execute format('alter table public.%I force row level security', t);

        execute format('drop policy if exists admin_all on public.%I', t);
        execute format(
            'create policy admin_all on public.%I for all to authenticated using (true) with check (true)', t);

        execute format('revoke all on public.%I from anon', t);
    end loop;
end $$;

commit;
*/

-- ---------------------------------------------------------------------
--  Rollback de la PARTE 2 (si algo sale mal): volver a abrir 'anon'
-- ---------------------------------------------------------------------
/*
do $$
declare
    t text;
    tablas text[] := array[
        'productos','proveedores','bom','unidades_medida','monedas',
        'lotes_inventario','movimientos_inventario','documentos','documento_detalles',
        'tipos_movimiento','plantillas_documentos','plantillas_impresion',
        'ordenes_produccion','orden_produccion_procesos','orden_produccion_proceso_empleados',
        'procesos_produccion','empleados','registros_tiempo','sesiones_ot'
    ];
begin
    foreach t in array tablas loop
        if to_regclass('public.' || t) is null then continue; end if;
        execute format('alter table public.%I disable row level security', t);
        execute format('grant all on public.%I to anon', t);
    end loop;
end $$;
*/
