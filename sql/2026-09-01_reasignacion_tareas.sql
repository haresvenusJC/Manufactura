-- =====================================================================
--  Reasignación de tareas de producción
--  Fecha: 2026-09-01  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Objetivo: el operario ve TODAS las tareas de una orden pero solo puede
--  ejecutar las suyas. Para trabajar en otra, pide una reasignación que el
--  administrador aprueba o rechaza desde "Producción -> Órdenes en Proceso".
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Tabla de solicitudes
-- ---------------------------------------------------------------------
create table if not exists public.solicitudes_reasignacion (
    id          bigint generated always as identity primary key,
    proceso_id  bigint not null
        references public.orden_produccion_procesos (id) on delete cascade,
    empleado_id bigint not null
        references public.empleados (id),
    motivo      text,
    estatus     text not null default 'pendiente'
        check (estatus in ('pendiente','aprobada','rechazada')),
    creada_at   timestamptz not null default now(),
    resuelta_at timestamptz
);

create index if not exists solicitudes_reasignacion_proc_idx
    on public.solicitudes_reasignacion (proceso_id);

-- Una sola solicitud PENDIENTE por (proceso, empleado).
create unique index if not exists solicitudes_reasignacion_pend_uq
    on public.solicitudes_reasignacion (proceso_id, empleado_id)
    where estatus = 'pendiente';

alter table public.solicitudes_reasignacion enable row level security;
drop policy if exists admin_all on public.solicitudes_reasignacion;
create policy admin_all on public.solicitudes_reasignacion
    for all to authenticated using (true) with check (true);
grant all on public.solicitudes_reasignacion to authenticated;

-- ---------------------------------------------------------------------
-- 2. Vista pública: el operario ve sus solicitudes pendientes
-- ---------------------------------------------------------------------
create or replace view public.v_ot_solicitudes as
    select sr.id,
           sr.proceso_id,
           sr.empleado_id,
           e.nombre as empleado_nombre,
           sr.estatus,
           sr.creada_at
      from public.solicitudes_reasignacion sr
      join public.empleados e on e.id = sr.empleado_id
     where sr.estatus = 'pendiente';

grant select on public.v_ot_solicitudes to anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. RPC anónima (operario): pedir asignación a un proceso donde NO está
-- ---------------------------------------------------------------------
create or replace function public.ot_solicitar_reasignacion(
    p_token uuid, p_proceso_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer set search_path = public, extensions
as $$
declare
    v_emp    bigint;
    v_estado text;
    v_id     bigint;
begin
    select s.empleado_id into v_emp
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_emp is null then raise exception 'SESION_EXPIRADA'; end if;

    select op.estado into v_estado
      from public.orden_produccion_procesos opp
      join public.ordenes_produccion op on op.id = opp.orden_produccion_id
     where opp.id = p_proceso_id;
    if v_estado is null then raise exception 'El proceso no existe.'; end if;
    if v_estado <> 'en_proceso' then raise exception 'La orden ya no está en proceso.'; end if;

    if exists (select 1 from public.orden_produccion_proceso_empleados
                where orden_produccion_proceso_id = p_proceso_id and empleado_id = v_emp) then
        raise exception 'Ya estás asignado a este proceso.';
    end if;

    insert into public.solicitudes_reasignacion (proceso_id, empleado_id, motivo)
    values (p_proceso_id, v_emp, nullif(btrim(coalesce(p_motivo, '')), ''))
    on conflict (proceso_id, empleado_id) where estatus = 'pendiente'
        do update set motivo = excluded.motivo, creada_at = now()
    returning id into v_id;

    return jsonb_build_object('ok', true, 'solicitud_id', v_id);
end $$;

revoke all     on function public.ot_solicitar_reasignacion(uuid, bigint, text) from public;
grant  execute on function public.ot_solicitar_reasignacion(uuid, bigint, text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. RPC admin: aprobar (asigna al equipo) o rechazar
-- ---------------------------------------------------------------------
create or replace function public.resolver_reasignacion(
    p_solicitud_id bigint, p_aprobar boolean, p_costo_hora numeric default null)
returns jsonb
language plpgsql
security definer set search_path = public, extensions
as $$
declare
    v_sol   record;
    v_costo numeric;
begin
    if coalesce(auth.role(), '') <> 'authenticated' then
        raise exception 'No autorizado.';
    end if;

    select * into v_sol from public.solicitudes_reasignacion where id = p_solicitud_id;
    if v_sol is null then raise exception 'Solicitud no encontrada.'; end if;
    if v_sol.estatus <> 'pendiente' then raise exception 'La solicitud ya fue resuelta.'; end if;

    if p_aprobar then
        v_costo := coalesce(p_costo_hora,
                            (select costo_hora from public.empleados where id = v_sol.empleado_id),
                            0);
        if not exists (select 1 from public.orden_produccion_proceso_empleados
                        where orden_produccion_proceso_id = v_sol.proceso_id
                          and empleado_id = v_sol.empleado_id) then
            insert into public.orden_produccion_proceso_empleados
                        (orden_produccion_proceso_id, empleado_id, costo_hora_snapshot)
            values (v_sol.proceso_id, v_sol.empleado_id, v_costo);
        end if;
    end if;

    update public.solicitudes_reasignacion
       set estatus     = case when p_aprobar then 'aprobada' else 'rechazada' end,
           resuelta_at = now()
     where id = p_solicitud_id;

    return jsonb_build_object('ok', true, 'aprobada', p_aprobar);
end $$;

revoke all     on function public.resolver_reasignacion(bigint, boolean, numeric) from public, anon;
grant  execute on function public.resolver_reasignacion(bigint, boolean, numeric) to authenticated;

commit;
