-- =====================================================================
--  Reservas: liberar / volver a apartar a mano, y recalcular todo
--  Fecha: 2026-11-03  ·  Proyecto: Hares de México (Supabase)
--  Corre DESPUÉS de sql/2026-11-03_reservas_pedidos.sql.
--
--  Las reservas se recalculan solas con cada movimiento, así que "des-apartar"
--  no puede ser solo poner el número en 0 (el siguiente recálculo lo volvería a
--  apartar). Se guarda como una MARCA en el renglón: apartar = false → el
--  recálculo lo salta y esa mercancía queda libre para los demás pedidos.
--
--   - pedido_venta_liberar_reserva(pedido, renglón|null, motivo)  → des-aparta (motivo obligatorio)
--   - pedido_venta_reactivar_reserva(pedido, renglón|null)        → vuelve a apartar (si hay stock)
--   - reservas_recalcular_todo()                                  → botón de reparación: recalcula
--                                                                    todos los productos de golpe
--  Cada liberación/reactivación deja una línea en las notas del pedido (y por tanto en la
--  Bitácora de cambios). Un renglón liberado NO cuenta como "falta".
--  No toca inventario ni contabilidad. Idempotente.
-- =====================================================================
begin;

alter table public.pedidos_venta_detalle
    add column if not exists apartar boolean not null default true,
    add column if not exists motivo_liberacion text;

comment on column public.pedidos_venta_detalle.apartar is
    'false = el renglón se liberó a mano: el recálculo de reservas lo salta y no aparta mercancía.';

-- El recálculo respeta la marca (misma firma que la versión anterior).
create or replace function public.reservas_reasignar(p_producto_id bigint)
returns void
language plpgsql
volatile
set search_path = public
as $$
declare
    v_resto numeric;
    r       record;
    v_res   numeric;
begin
    if p_producto_id is null then return; end if;
    perform pg_advisory_xact_lock(7001000000000 + p_producto_id);

    select greatest(coalesce(sum(stock_actual), 0), 0) into v_resto
      from public.lotes_inventario where producto_id = p_producto_id;

    for r in
        select d.id, greatest(d.cantidad - d.cantidad_surtida, 0) as pendiente
          from public.pedidos_venta_detalle d
          join public.pedidos_venta p on p.id = d.pedido_id
         where d.producto_id = p_producto_id
           and p.estatus in ('pendiente', 'parcial')
           and d.apartar
         order by p.fecha, p.id, d.id
    loop
        v_res := least(r.pendiente, v_resto);
        v_resto := v_resto - v_res;
        update public.pedidos_venta_detalle
           set cantidad_reservada = v_res
         where id = r.id and cantidad_reservada is distinct from v_res;
    end loop;

    -- Sin reserva: pedidos que ya no están vivos (surtidos / cancelados) y renglones liberados a mano.
    update public.pedidos_venta_detalle d
       set cantidad_reservada = 0
      from public.pedidos_venta p
     where p.id = d.pedido_id
       and d.producto_id = p_producto_id
       and d.cantidad_reservada <> 0
       and (p.estatus not in ('pendiente', 'parcial') or not d.apartar);
end;
$$;

-- Un renglón liberado no cuenta como faltante (misma firma que la versión anterior).
create or replace function public.pedido_venta_reservar(p_pedido_id bigint)
returns table (
    detalle_id bigint, producto_id bigint, producto text, pendiente numeric,
    reservado numeric, faltante numeric, stock numeric, apartado_otros numeric
)
language plpgsql
volatile
set search_path = public
as $$
declare
    v_prod bigint;
begin
    for v_prod in
        select distinct d.producto_id from public.pedidos_venta_detalle d
         where d.pedido_id = p_pedido_id and d.producto_id is not null
    loop
        perform public.reservas_reasignar(v_prod);
    end loop;

    return query
    select d.id, d.producto_id, pr.nombre::text,
           greatest(d.cantidad - d.cantidad_surtida, 0),
           d.cantidad_reservada,
           case when d.apartar then greatest(d.cantidad - d.cantidad_surtida - d.cantidad_reservada, 0) else 0 end,
           coalesce((select sum(l.stock_actual) from public.lotes_inventario l where l.producto_id = d.producto_id), 0),
           coalesce((select sum(o.cantidad_reservada)
                       from public.pedidos_venta_detalle o
                       join public.pedidos_venta v on v.id = o.pedido_id
                      where o.producto_id = d.producto_id and o.id <> d.id
                        and v.estatus in ('pendiente', 'parcial')), 0)
      from public.pedidos_venta_detalle d
      left join public.productos pr on pr.id = d.producto_id
     where d.pedido_id = p_pedido_id
     order by d.id;
end;
$$;

-- ---------------------------------------------------------------------
-- Des-apartar (un renglón, o todos los del pedido si p_detalle_id es null)
-- ---------------------------------------------------------------------
create or replace function public.pedido_venta_liberar_reserva(p_pedido_id bigint, p_detalle_id bigint, p_motivo text)
returns integer
language plpgsql
volatile
set search_path = public
as $$
declare
    v_folio text;
    v_estatus text;
    v_n integer;
    v_prod bigint;
begin
    if coalesce(trim(p_motivo), '') = '' then
        raise exception 'Escribe el motivo de la liberación.';
    end if;
    select folio, estatus into v_folio, v_estatus from public.pedidos_venta where id = p_pedido_id;
    if not found then raise exception 'El pedido no existe.'; end if;
    if v_estatus not in ('pendiente', 'parcial') then
        raise exception 'Solo se libera la reserva de pedidos pendientes o parciales (este está %).', v_estatus;
    end if;

    update public.pedidos_venta_detalle
       set apartar = false, cantidad_reservada = 0, motivo_liberacion = trim(p_motivo)
     where pedido_id = p_pedido_id and (p_detalle_id is null or id = p_detalle_id) and apartar;
    get diagnostics v_n = row_count;
    if v_n = 0 then return 0; end if;

    for v_prod in select distinct producto_id from public.pedidos_venta_detalle
                   where pedido_id = p_pedido_id and producto_id is not null loop
        perform public.reservas_reasignar(v_prod);   -- lo liberado se reparte entre los demás pedidos
    end loop;

    update public.pedidos_venta
       set notas = coalesce(notas || ' — ', '')
                   || 'Reserva liberada (' || case when p_detalle_id is null then 'todo el pedido' else 'renglón #' || p_detalle_id end || '): ' || trim(p_motivo)
     where id = p_pedido_id;
    return v_n;
end;
$$;

-- ---------------------------------------------------------------------
-- Volver a apartar (se aparta lo que haya disponible, por prioridad)
-- ---------------------------------------------------------------------
create or replace function public.pedido_venta_reactivar_reserva(p_pedido_id bigint, p_detalle_id bigint)
returns integer
language plpgsql
volatile
set search_path = public
as $$
declare
    v_n integer;
    v_prod bigint;
begin
    if not exists (select 1 from public.pedidos_venta where id = p_pedido_id and estatus in ('pendiente', 'parcial')) then
        raise exception 'Solo se aparta mercancía para pedidos pendientes o parciales.';
    end if;

    update public.pedidos_venta_detalle
       set apartar = true, motivo_liberacion = null
     where pedido_id = p_pedido_id and (p_detalle_id is null or id = p_detalle_id) and not apartar;
    get diagnostics v_n = row_count;
    if v_n = 0 then return 0; end if;

    for v_prod in select distinct producto_id from public.pedidos_venta_detalle
                   where pedido_id = p_pedido_id and producto_id is not null loop
        perform public.reservas_reasignar(v_prod);
    end loop;

    update public.pedidos_venta
       set notas = coalesce(notas || ' — ', '')
                   || 'Se volvió a apartar (' || case when p_detalle_id is null then 'todo el pedido' else 'renglón #' || p_detalle_id end || ')'
     where id = p_pedido_id;
    return v_n;
end;
$$;

-- ---------------------------------------------------------------------
-- Reparación: recalcula las reservas de TODOS los productos con pedidos.
-- ---------------------------------------------------------------------
create or replace function public.reservas_recalcular_todo()
returns integer
language plpgsql
volatile
set search_path = public
as $$
declare
    v_prod bigint;
    v_n integer := 0;
begin
    for v_prod in select distinct producto_id from public.pedidos_venta_detalle where producto_id is not null loop
        perform public.reservas_reasignar(v_prod);
        v_n := v_n + 1;
    end loop;
    return v_n;
end;
$$;

grant execute on function public.reservas_reasignar(bigint) to authenticated;
grant execute on function public.pedido_venta_reservar(bigint) to authenticated;
grant execute on function public.pedido_venta_liberar_reserva(bigint, bigint, text) to authenticated;
grant execute on function public.pedido_venta_reactivar_reserva(bigint, bigint) to authenticated;
grant execute on function public.reservas_recalcular_todo() to authenticated;

commit;
