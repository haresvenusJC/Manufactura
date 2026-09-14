-- =====================================================================
--  Auditoría de inventarios: captura la caducidad del lote contado +
--  la pantalla del operador ya usa la unidad real del producto (antes
--  decía "pieza" genérico aunque el producto fuera litros, kilos, etc.)
--  Fecha: 2026-09-15  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-14f_auditoria_inventarios.sql
--
--  auditoria_conteos.fecha_caducidad (nueva, opcional): un mismo SKU
--  puede tener varios lotes físicos con caducidades distintas — el
--  operador la anota por captura, no por renglón completo.
--
--  Se usa DROP + CREATE (no un simple CREATE OR REPLACE) porque cambia
--  la firma/forma de salida de las dos funciones, y Postgres no permite
--  eso con un remplazo simple (ver la misma lección con recibo_reversible
--  en sql/2026-09-14_fix_hallazgos_contabilidad.sql).
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.auditoria_conteos add column if not exists fecha_caducidad date;

drop function if exists public.registrar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text);
create function public.registrar_conteo_auditoria(
    p_token uuid, p_item_id bigint, p_cantidad numeric,
    p_tipo_captura text default 'pieza', p_piezas_por_caja numeric default 1,
    p_nota text default null, p_fecha_caducidad date default null
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
        (item_id, empleado_id, cantidad, tipo_captura, piezas_por_caja, cantidad_equivalente, nota, fecha_caducidad)
    values
        (p_item_id, v_empleado_id, v_cant, v_tipo, case when v_tipo = 'caja' then v_ppc else 1 end, v_equiv, nullif(trim(p_nota), ''), p_fecha_caducidad)
    returning id into v_conteo_id;

    select coalesce(sum(cantidad_equivalente), 0) into v_acum
      from public.auditoria_conteos where item_id = p_item_id;

    return jsonb_build_object('conteo_id', v_conteo_id, 'cantidad_equivalente', v_equiv, 'acumulado', v_acum);
end $$;

revoke all     on function public.registrar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text, date) from public;
grant  execute on function public.registrar_conteo_auditoria(uuid, bigint, numeric, text, numeric, text, date) to anon, authenticated;


drop function if exists public.capturas_item_auditoria(uuid, bigint);
create function public.capturas_item_auditoria(p_token uuid, p_item_id bigint)
returns table (id bigint, cantidad numeric, tipo_captura text, piezas_por_caja numeric,
                cantidad_equivalente numeric, nota text, fecha_caducidad date,
                capturado_en timestamptz, empleado_nombre text)
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
               ac.cantidad_equivalente, ac.nota, ac.fecha_caducidad, ac.capturado_en, e.nombre
          from public.auditoria_conteos ac
          left join public.empleados e on e.id = ac.empleado_id
         where ac.item_id = p_item_id
         order by ac.capturado_en desc;
end $$;

revoke all     on function public.capturas_item_auditoria(uuid, bigint) from public;
grant  execute on function public.capturas_item_auditoria(uuid, bigint) to anon, authenticated;

commit;
