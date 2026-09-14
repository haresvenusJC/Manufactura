-- =====================================================================
--  Auditoría de inventarios (toma física de materia prima, insumos,
--  producto terminado, equipos, etc.)
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-08-27_flujo_ot.sql (por sesiones_ot / ot_login /
--            v_ot_empleados — se reutiliza el mismo PIN de 4 dígitos de
--            los operadores de planta, no se crea un sistema aparte).
--
--  Reemplaza a la vieja pantalla "Auditoría" (que nunca se llegó a
--  construir — se quedaba pegada en "Cargando registros..." para
--  siempre) por un módulo de conteo físico:
--
--    · auditorias_inventario   — el encabezado ("Inventario general
--      septiembre 2026"), abierta / cerrada / cancelada.
--    · auditoria_items         — qué se va a contar en esa auditoría
--      (un producto del catálogo, o un renglón libre para cosas sin
--      catálogo como equipo). Guarda el stock del sistema como
--      referencia OCULTA al operador (conteo a ciegas).
--    · auditoria_conteos       — cada CAPTURA individual del operador:
--      cantidad + si fue por pieza o por caja (con cuántas piezas trae
--      esa caja) + hora exacta. Varias capturas de un mismo item se
--      SUMAN (conteo sumatorio), nunca se sobrescriben.
--
--  El operador entra por una página aparte (conteo-inventario.html),
--  se identifica con nombre + PIN (mismo mecanismo que Orden de
--  Trabajo) y solo ve qué falta contar — nunca el stock del sistema.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Encabezado de la auditoría
-- ---------------------------------------------------------------------
create table if not exists public.auditorias_inventario (
    id          bigint generated always as identity primary key,
    nombre      text not null,
    fecha       date not null default current_date,
    estatus     text not null default 'abierta' check (estatus in ('abierta','cerrada','cancelada')),
    notas       text,
    creado_por  uuid default auth.uid(),
    created_at  timestamptz not null default now(),
    cerrada_en  timestamptz
);

-- ---------------------------------------------------------------------
-- 2. Qué se va a contar (uno por producto del catálogo, o libre para
--    cosas sin catálogo — equipo, mobiliario, etc.)
-- ---------------------------------------------------------------------
create table if not exists public.auditoria_items (
    id                bigint generated always as identity primary key,
    auditoria_id      bigint not null references public.auditorias_inventario(id) on delete cascade,
    producto_id       bigint references public.productos(id) on delete set null,
    descripcion_libre text,
    unidad_nombre     text,             -- copia de la unidad, para mostrarla al operador sin exponer el producto completo
    stock_sistema     numeric(14,4),    -- referencia OCULTA al operador; solo la ve el admin al revisar
    created_at        timestamptz not null default now(),
    constraint auditoria_items_uno_u_otro check (producto_id is not null or descripcion_libre is not null)
);
create unique index if not exists auditoria_items_prod_unq
    on public.auditoria_items(auditoria_id, producto_id) where producto_id is not null;
create index if not exists idx_audititems_auditoria on public.auditoria_items(auditoria_id);

-- ---------------------------------------------------------------------
-- 3. Cada captura individual (conteo sumatorio + hora exacta)
-- ---------------------------------------------------------------------
create table if not exists public.auditoria_conteos (
    id                   bigint generated always as identity primary key,
    item_id              bigint not null references public.auditoria_items(id) on delete cascade,
    empleado_id          bigint references public.empleados(id) on delete set null,
    cantidad             numeric(14,4) not null check (cantidad > 0),
    tipo_captura         text not null default 'pieza' check (tipo_captura in ('pieza','caja')),
    piezas_por_caja      numeric(14,4) not null default 1 check (piezas_por_caja > 0),
    cantidad_equivalente numeric(14,4) not null,
    nota                 text,
    capturado_en         timestamptz not null default now()
);
create index if not exists idx_auditconteos_item on public.auditoria_conteos(item_id);

alter table public.auditorias_inventario enable row level security;
alter table public.auditoria_items       enable row level security;
alter table public.auditoria_conteos     enable row level security;
drop policy if exists admin_all on public.auditorias_inventario;
drop policy if exists admin_all on public.auditoria_items;
drop policy if exists admin_all on public.auditoria_conteos;
create policy admin_all on public.auditorias_inventario for all to authenticated using (true) with check (true);
create policy admin_all on public.auditoria_items       for all to authenticated using (true) with check (true);
create policy admin_all on public.auditoria_conteos     for all to authenticated using (true) with check (true);
grant all on public.auditorias_inventario, public.auditoria_items, public.auditoria_conteos to authenticated;

-- ---------------------------------------------------------------------
-- 4. Vistas públicas para el operador (SIN stock_sistema — conteo a
--    ciegas) y para el admin (con todo, incluida la diferencia).
-- ---------------------------------------------------------------------
create or replace view public.v_auditorias_abiertas as
    select a.id, a.nombre, a.fecha,
           (select count(*) from public.auditoria_items ai where ai.auditoria_id = a.id) as total_items,
           (select count(distinct ac.item_id) from public.auditoria_conteos ac
              join public.auditoria_items ai2 on ai2.id = ac.item_id
             where ai2.auditoria_id = a.id) as items_con_conteo
      from public.auditorias_inventario a
     where a.estatus = 'abierta'
     order by a.created_at desc;

grant select on public.v_auditorias_abiertas to anon, authenticated;

create or replace view public.v_auditoria_items_operador as
    select ai.id as item_id, ai.auditoria_id, a.nombre as auditoria_nombre,
           coalesce(p.nombre, ai.descripcion_libre) as descripcion,
           p.sku, coalesce(ai.unidad_nombre, '') as unidad_nombre,
           coalesce((select sum(ac.cantidad_equivalente) from public.auditoria_conteos ac where ac.item_id = ai.id), 0) as acumulado
      from public.auditoria_items ai
      join public.auditorias_inventario a on a.id = ai.auditoria_id
      left join public.productos p on p.id = ai.producto_id
     where a.estatus = 'abierta';

grant select on public.v_auditoria_items_operador to anon, authenticated;

create or replace view public.v_auditoria_resultado as
    select ai.id as item_id, ai.auditoria_id,
           coalesce(p.nombre, ai.descripcion_libre) as descripcion,
           p.sku, coalesce(ai.unidad_nombre, '') as unidad_nombre,
           coalesce(ai.stock_sistema, 0) as stock_sistema,
           coalesce((select sum(ac.cantidad_equivalente) from public.auditoria_conteos ac where ac.item_id = ai.id), 0) as contado,
           round(coalesce((select sum(ac.cantidad_equivalente) from public.auditoria_conteos ac where ac.item_id = ai.id), 0) - coalesce(ai.stock_sistema, 0), 4) as diferencia,
           (select count(*) from public.auditoria_conteos ac where ac.item_id = ai.id) as num_capturas
      from public.auditoria_items ai
      left join public.productos p on p.id = ai.producto_id;

grant select on public.v_auditoria_resultado to authenticated;

-- ---------------------------------------------------------------------
-- 5. crear_auditoria_inventario(p_datos) -> { auditoria_id, items }
--    p_datos: { nombre, notas, producto_ids: [..], libres: ["Equipo X", ...] }
-- ---------------------------------------------------------------------
create or replace function public.crear_auditoria_inventario(p_datos jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_nombre  text := nullif(trim(p_datos->>'nombre'), '');
    v_notas   text := nullif(trim(p_datos->>'notas'), '');
    v_prods   jsonb := coalesce(p_datos->'producto_ids', '[]'::jsonb);
    v_libres  jsonb := coalesce(p_datos->'libres', '[]'::jsonb);
    v_aud_id  bigint;
begin
    if v_nombre is null then raise exception 'El nombre de la auditoría es obligatorio.'; end if;
    if jsonb_array_length(v_prods) = 0 and jsonb_array_length(v_libres) = 0 then
        raise exception 'Agrega al menos un producto o un renglón libre a contar.';
    end if;

    insert into public.auditorias_inventario (nombre, notas)
    values (v_nombre, v_notas)
    returning id into v_aud_id;

    insert into public.auditoria_items (auditoria_id, producto_id, unidad_nombre, stock_sistema)
    select v_aud_id, p.id, um.nombre, coalesce(p.stock_actual, 0)
      from public.productos p
      left join public.unidades_medida um on um.id = p.unidad_medida_id
     where p.id in (select (jsonb_array_elements_text(v_prods))::bigint)
    on conflict (auditoria_id, producto_id) where producto_id is not null do nothing;

    insert into public.auditoria_items (auditoria_id, descripcion_libre)
    select v_aud_id, trim(x)
      from jsonb_array_elements_text(v_libres) x
     where trim(x) <> '';

    return jsonb_build_object('auditoria_id', v_aud_id,
        'items', (select count(*) from public.auditoria_items where auditoria_id = v_aud_id));
end $$;

revoke all     on function public.crear_auditoria_inventario(jsonb) from public;
grant  execute on function public.crear_auditoria_inventario(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 6. cerrar_auditoria_inventario(p_auditoria_id) -> { cerrada }
--    Solo cierra la captura (deja de aceptar conteos); NO ajusta
--    inventario ni contabilidad — eso se revisa y aplica aparte.
-- ---------------------------------------------------------------------
create or replace function public.cerrar_auditoria_inventario(p_auditoria_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
begin
    update public.auditorias_inventario
       set estatus = 'cerrada', cerrada_en = now()
     where id = p_auditoria_id and estatus = 'abierta';
    if not found then raise exception 'La auditoría no existe o ya no está abierta.'; end if;
    return jsonb_build_object('cerrada', true);
end $$;

revoke all     on function public.cerrar_auditoria_inventario(bigint) from public;
grant  execute on function public.cerrar_auditoria_inventario(bigint) to authenticated;

create or replace function public.reabrir_auditoria_inventario(p_auditoria_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
begin
    update public.auditorias_inventario set estatus = 'abierta', cerrada_en = null
     where id = p_auditoria_id and estatus = 'cerrada';
    if not found then raise exception 'La auditoría no existe o no está cerrada.'; end if;
    return jsonb_build_object('reabierta', true);
end $$;

revoke all     on function public.reabrir_auditoria_inventario(bigint) from public;
grant  execute on function public.reabrir_auditoria_inventario(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- 7. registrar_conteo_auditoria(p_token, p_item_id, p_cantidad,
--    p_tipo_captura, p_piezas_por_caja, p_nota) -> { conteo_id, acumulado }
--    La escribe el operador desde conteo-inventario.html, autenticado
--    con el mismo token de sesiones_ot que Orden de Trabajo.
-- ---------------------------------------------------------------------
create or replace function public.registrar_conteo_auditoria(
    p_token uuid, p_item_id bigint, p_cantidad numeric,
    p_tipo_captura text default 'pieza', p_piezas_por_caja numeric default 1,
    p_nota text default null
)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_estatus     text;
    v_cant        numeric(14,4) := round(coalesce(p_cantidad, 0), 4);
    v_ppc         numeric(14,4) := round(coalesce(p_piezas_por_caja, 1), 4);
    v_tipo        text := coalesce(p_tipo_captura, 'pieza');
    v_equiv       numeric(14,4);
    v_item_id     bigint;
    v_conteo_id   bigint;
    v_acum        numeric(14,4);
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    if v_tipo not in ('pieza','caja') then raise exception 'Tipo de captura invalido: %', v_tipo; end if;
    if v_cant <= 0 then raise exception 'La cantidad debe ser mayor a cero.'; end if;
    if v_ppc <= 0 then raise exception 'Las piezas por caja deben ser mayor a cero.'; end if;

    select ai.id, a.estatus into v_item_id, v_estatus
      from public.auditoria_items ai
      join public.auditorias_inventario a on a.id = ai.auditoria_id
     where ai.id = p_item_id;
    if v_item_id is null then raise exception 'El renglón a contar no existe.'; end if;
    if v_estatus <> 'abierta' then raise exception 'Esta auditoría ya no está abierta.'; end if;

    v_equiv := round(v_cant * (case when v_tipo = 'caja' then v_ppc else 1 end), 4);

    insert into public.auditoria_conteos
        (item_id, empleado_id, cantidad, tipo_captura, piezas_por_caja, cantidad_equivalente, nota)
    values
        (p_item_id, v_empleado_id, v_cant, v_tipo, case when v_tipo = 'caja' then v_ppc else 1 end, v_equiv, nullif(trim(p_nota), ''))
    returning id into v_conteo_id;

    select coalesce(sum(cantidad_equivalente), 0) into v_acum
      from public.auditoria_conteos where item_id = p_item_id;

    return jsonb_build_object('conteo_id', v_conteo_id, 'cantidad_equivalente', v_equiv, 'acumulado', v_acum);
end $$;

revoke all     on function public.registrar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text) from public;
grant  execute on function public.registrar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 8. Historial de capturas de un item, con hora exacta — para que el
--    operador vea lo que él mismo lleva capturado (nunca stock_sistema)
--    y el admin vea el detalle completo con empleado.
-- ---------------------------------------------------------------------
create or replace function public.capturas_item_auditoria(p_token uuid, p_item_id bigint)
returns table (id bigint, cantidad numeric, tipo_captura text, piezas_por_caja numeric,
                cantidad_equivalente numeric, nota text, capturado_en timestamptz, empleado_nombre text)
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
begin
    select s.empleado_id into v_empleado_id from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    return query
        select ac.id, ac.cantidad, ac.tipo_captura, ac.piezas_por_caja,
               ac.cantidad_equivalente, ac.nota, ac.capturado_en, e.nombre
          from public.auditoria_conteos ac
          left join public.empleados e on e.id = ac.empleado_id
         where ac.item_id = p_item_id
         order by ac.capturado_en desc;
end $$;

revoke all     on function public.capturas_item_auditoria(uuid, bigint) from public;
grant  execute on function public.capturas_item_auditoria(uuid, bigint) to anon, authenticated;

commit;

-- =====================================================================
-- select * from public.v_auditoria_resultado where auditoria_id = 1 order by descripcion;
-- =====================================================================
