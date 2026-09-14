-- =====================================================================
--  Auditoría de inventarios:
--   1) el operador puede EDITAR o BORRAR sus propias capturas (antes
--      solo podía agregar, nunca corregir un dato mal tecleado).
--   2) el operador puede CONFIRMAR su conteo de una auditoría (se
--      guarda con fecha/hora); antes de eso la app le muestra un
--      pre-resumen y le pregunta si está seguro.
--  Fecha: 2026-09-17  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-14f_auditoria_inventarios.sql
--            sql/2026-09-15_auditoria_caducidad_y_unidad.sql
--            sql/2026-09-16_resumen_capturas_operador.sql
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Confirmación del operador (una por auditoría + empleado).
-- ---------------------------------------------------------------------
create table if not exists public.auditoria_confirmaciones (
    id            bigint generated always as identity primary key,
    auditoria_id  bigint not null references public.auditorias_inventario(id) on delete cascade,
    empleado_id   bigint not null references public.empleados(id) on delete cascade,
    confirmado_en timestamptz not null default now(),
    unique (auditoria_id, empleado_id)
);
create index if not exists idx_auditconfirm_auditoria on public.auditoria_confirmaciones(auditoria_id);

alter table public.auditoria_confirmaciones enable row level security;
drop policy if exists admin_all on public.auditoria_confirmaciones;
create policy admin_all on public.auditoria_confirmaciones for all to authenticated using (true) with check (true);
grant all on public.auditoria_confirmaciones to authenticated;
-- El operador (anon) solo entra por las RPC de abajo, nunca directo a la tabla.

-- ---------------------------------------------------------------------
-- 2. Editar una captura propia (corrige cantidad/tipo/nota/caducidad).
-- ---------------------------------------------------------------------
create or replace function public.editar_conteo_auditoria(
    p_token uuid, p_conteo_id bigint, p_cantidad numeric,
    p_tipo_captura text default 'pieza', p_piezas_por_caja numeric default 1,
    p_nota text default null, p_fecha_caducidad date default null
)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_estatus     text;
    v_item_id     bigint;
    v_cant        numeric(14,4) := round(coalesce(p_cantidad, 0), 4);
    v_ppc         numeric(14,4) := round(coalesce(p_piezas_por_caja, 1), 4);
    v_tipo        text := coalesce(p_tipo_captura, 'pieza');
    v_equiv       numeric(14,4);
    v_acum        numeric(14,4);
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    if v_tipo not in ('pieza','caja') then raise exception 'Tipo de captura invalido: %', v_tipo; end if;
    if v_cant <= 0 then raise exception 'La cantidad debe ser mayor a cero.'; end if;
    if v_ppc <= 0 then raise exception 'Las piezas por caja deben ser mayor a cero.'; end if;

    select ac.item_id, a.estatus into v_item_id, v_estatus
      from public.auditoria_conteos ac
      join public.auditoria_items ai on ai.id = ac.item_id
      join public.auditorias_inventario a on a.id = ai.auditoria_id
     where ac.id = p_conteo_id and ac.empleado_id = v_empleado_id;
    if v_item_id is null then raise exception 'Esa captura no existe o no te pertenece.'; end if;
    if v_estatus <> 'abierta' then raise exception 'Esta auditoría ya no está abierta.'; end if;

    v_equiv := round(v_cant * (case when v_tipo = 'caja' then v_ppc else 1 end), 4);

    update public.auditoria_conteos set
        cantidad = v_cant,
        tipo_captura = v_tipo,
        piezas_por_caja = case when v_tipo = 'caja' then v_ppc else 1 end,
        cantidad_equivalente = v_equiv,
        nota = nullif(trim(p_nota), ''),
        fecha_caducidad = p_fecha_caducidad
     where id = p_conteo_id;

    select coalesce(sum(cantidad_equivalente), 0) into v_acum
      from public.auditoria_conteos where item_id = v_item_id;

    return jsonb_build_object('cantidad_equivalente', v_equiv, 'acumulado', v_acum);
end $$;

revoke all     on function public.editar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text, date) from public;
grant  execute on function public.editar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text, date) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Borrar una captura propia (se tecleó por error).
-- ---------------------------------------------------------------------
create or replace function public.eliminar_conteo_auditoria(p_token uuid, p_conteo_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_estatus     text;
    v_item_id     bigint;
    v_acum        numeric(14,4);
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    select ac.item_id, a.estatus into v_item_id, v_estatus
      from public.auditoria_conteos ac
      join public.auditoria_items ai on ai.id = ac.item_id
      join public.auditorias_inventario a on a.id = ai.auditoria_id
     where ac.id = p_conteo_id and ac.empleado_id = v_empleado_id;
    if v_item_id is null then raise exception 'Esa captura no existe o no te pertenece.'; end if;
    if v_estatus <> 'abierta' then raise exception 'Esta auditoría ya no está abierta.'; end if;

    delete from public.auditoria_conteos where id = p_conteo_id;

    select coalesce(sum(cantidad_equivalente), 0) into v_acum
      from public.auditoria_conteos where item_id = v_item_id;

    return jsonb_build_object('eliminado', true, 'acumulado', v_acum);
end $$;

revoke all     on function public.eliminar_conteo_auditoria(uuid, bigint) from public;
grant  execute on function public.eliminar_conteo_auditoria(uuid, bigint) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Confirmar ("enviar") mi conteo de una auditoría.
-- ---------------------------------------------------------------------
create or replace function public.confirmar_mi_conteo(p_token uuid, p_auditoria_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_ts          timestamptz;
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    if not exists (select 1 from public.auditorias_inventario where id = p_auditoria_id) then
        raise exception 'La auditoría no existe.';
    end if;

    insert into public.auditoria_confirmaciones (auditoria_id, empleado_id)
    values (p_auditoria_id, v_empleado_id)
    on conflict (auditoria_id, empleado_id) do update set confirmado_en = now()
    returning confirmado_en into v_ts;

    return jsonb_build_object('confirmado_en', v_ts);
end $$;

revoke all     on function public.confirmar_mi_conteo(uuid, bigint) from public;
grant  execute on function public.confirmar_mi_conteo(uuid, bigint) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 5. ¿Ya confirmé mi conteo de esta auditoría? (para pintar el banner)
-- ---------------------------------------------------------------------
create or replace function public.mi_confirmacion_auditoria(p_token uuid, p_auditoria_id bigint)
returns timestamptz
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
    v_ts          timestamptz;
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    select confirmado_en into v_ts
      from public.auditoria_confirmaciones
     where auditoria_id = p_auditoria_id and empleado_id = v_empleado_id;

    return v_ts;
end $$;

revoke all     on function public.mi_confirmacion_auditoria(uuid, bigint) from public;
grant  execute on function public.mi_confirmacion_auditoria(uuid, bigint) to anon, authenticated;

commit;
