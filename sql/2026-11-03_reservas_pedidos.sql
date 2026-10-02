-- =====================================================================
--  Reservas de inventario para Pedidos de venta  (ENTREGA 1 de 4)
--  Fecha: 2026-11-03  ·  Proyecto: Hares de México (Supabase)
--
--  Un pedido pendiente ya "aparta" mercancía: cada renglón guarda cuánto
--  tiene reservado (pedidos_venta_detalle.cantidad_reservada). Lo
--  disponible de un producto = existencia en lotes − lo reservado.
--
--  Reglas:
--   - Prioridad: pedido más antiguo primero (fecha, id, renglón).
--   - Se recalcula SOLA cuando cambia el stock de un lote (llega una
--     compra, cierra una orden de producción, sale una venta...), cuando
--     se captura/cambia/surte un renglón o cambia el estatus del pedido
--     (cancelar libera). El recálculo es completo e idempotente: si algo
--     queda desfasado, el siguiente evento lo corrige.
--   - A PRUEBA DE FALLOS: los triggers atrapan cualquier error y solo lo
--     avisan (WARNING); un problema aquí nunca bloquea una recepción, una
--     venta ni el cierre de una orden.
--   - Dos pedidos guardados al mismo tiempo no se pisan: el recálculo
--     toma un candado por producto (pg_advisory_xact_lock).
--
--  Esta entrega NO bloquea nada en la base (el candado contra salidas
--  llega en la entrega 2). Las pantallas avisan y bloquean por su cuenta.
--  No toca inventario ni contabilidad. Idempotente. Pégalo completo en
--  Supabase -> SQL Editor.
-- =====================================================================
begin;

alter table public.pedidos_venta_detalle
    add column if not exists cantidad_reservada numeric not null default 0;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'pedidos_venta_detalle_reservada_chk') then
        alter table public.pedidos_venta_detalle
            add constraint pedidos_venta_detalle_reservada_chk check (cantidad_reservada >= 0);
    end if;
end $$;

comment on column public.pedidos_venta_detalle.cantidad_reservada is
    'Mercancía apartada para este renglón (≤ lo pendiente por surtir). La mantiene reservas_reasignar().';

create index if not exists pedidos_venta_detalle_producto_idx on public.pedidos_venta_detalle (producto_id);

-- ---------------------------------------------------------------------
-- Recalcula las reservas de UN producto, en orden de prioridad.
-- ---------------------------------------------------------------------
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
         order by p.fecha, p.id, d.id
    loop
        v_res := least(r.pendiente, v_resto);
        v_resto := v_resto - v_res;
        update public.pedidos_venta_detalle
           set cantidad_reservada = v_res
         where id = r.id and cantidad_reservada is distinct from v_res;
    end loop;

    -- Renglones de pedidos que ya no están vivos (surtidos / cancelados): sin reserva.
    update public.pedidos_venta_detalle d
       set cantidad_reservada = 0
      from public.pedidos_venta p
     where p.id = d.pedido_id
       and d.producto_id = p_producto_id
       and d.cantidad_reservada <> 0
       and p.estatus not in ('pendiente', 'parcial');
end;
$$;

grant execute on function public.reservas_reasignar(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- Existencia / reservado / disponible por producto.
-- ---------------------------------------------------------------------
create or replace view public.v_stock_disponible as
select p.id as producto_id,
       coalesce(l.stock, 0)                                         as stock,
       coalesce(r.reservado, 0)                                     as reservado,
       greatest(coalesce(l.stock, 0) - coalesce(r.reservado, 0), 0) as disponible
  from public.productos p
  left join (select producto_id, sum(stock_actual) as stock
               from public.lotes_inventario group by producto_id) l on l.producto_id = p.id
  left join (select d.producto_id, sum(d.cantidad_reservada) as reservado
               from public.pedidos_venta_detalle d
               join public.pedidos_venta v on v.id = d.pedido_id
              where v.estatus in ('pendiente', 'parcial')
              group by d.producto_id) r on r.producto_id = p.id;

grant select on public.v_stock_disponible to authenticated;

-- ---------------------------------------------------------------------
-- Para la pantalla: asegura las reservas de un pedido y devuelve, por renglón,
-- cuánto se apartó y cuánto FALTA (lo que hay que fabricar o comprar).
-- ---------------------------------------------------------------------
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
           greatest(d.cantidad - d.cantidad_surtida - d.cantidad_reservada, 0),
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

grant execute on function public.pedido_venta_reservar(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- Triggers (a prueba de fallos: nunca bloquean la operación original)
-- ---------------------------------------------------------------------
create or replace function public.trg_reservas_por_lote()
returns trigger
language plpgsql
as $$
begin
    begin
        if tg_op = 'DELETE' then
            perform public.reservas_reasignar(old.producto_id);
        else
            perform public.reservas_reasignar(new.producto_id);
        end if;
    exception when others then
        raise warning 'reservas_por_lote: % (se ignora, no bloquea la operación)', sqlerrm;
    end;
    return null;
end;
$$;

drop trigger if exists trg_reservas_lotes on public.lotes_inventario;
create trigger trg_reservas_lotes
    after insert or update of stock_actual, producto_id or delete on public.lotes_inventario
    for each row execute function public.trg_reservas_por_lote();

create or replace function public.trg_reservas_por_detalle()
returns trigger
language plpgsql
as $$
begin
    begin
        if tg_op = 'DELETE' then
            perform public.reservas_reasignar(old.producto_id);
        else
            perform public.reservas_reasignar(new.producto_id);
            if tg_op = 'UPDATE' and old.producto_id is distinct from new.producto_id then
                perform public.reservas_reasignar(old.producto_id);
            end if;
        end if;
    exception when others then
        raise warning 'reservas_por_detalle: % (se ignora, no bloquea la operación)', sqlerrm;
    end;
    return null;
end;
$$;

-- OJO: la lista de columnas excluye cantidad_reservada a propósito (el recálculo la actualiza; sin esto se llamaría a sí mismo).
drop trigger if exists trg_reservas_detalle on public.pedidos_venta_detalle;
create trigger trg_reservas_detalle
    after insert or update of cantidad, cantidad_surtida, producto_id or delete on public.pedidos_venta_detalle
    for each row execute function public.trg_reservas_por_detalle();

create or replace function public.trg_reservas_por_pedido()
returns trigger
language plpgsql
as $$
declare
    v_prod bigint;
begin
    begin
        for v_prod in select distinct producto_id from public.pedidos_venta_detalle
                       where pedido_id = new.id and producto_id is not null
        loop
            perform public.reservas_reasignar(v_prod);
        end loop;
    exception when others then
        raise warning 'reservas_por_pedido: % (se ignora, no bloquea la operación)', sqlerrm;
    end;
    return null;
end;
$$;

drop trigger if exists trg_reservas_pedido on public.pedidos_venta;
create trigger trg_reservas_pedido
    after update of estatus on public.pedidos_venta
    for each row execute function public.trg_reservas_por_pedido();

-- ---------------------------------------------------------------------
-- Pedidos que ya estaban pendientes: se les aparta lo que hay.
-- ---------------------------------------------------------------------
select public.reservas_reasignar(x.producto_id)
  from (select distinct producto_id from public.pedidos_venta_detalle where producto_id is not null) x;

commit;

-- Revisión:
--   select * from public.v_stock_disponible where reservado > 0;
--   select d.id, p.folio, d.producto_id, d.cantidad, d.cantidad_surtida, d.cantidad_reservada
--     from public.pedidos_venta_detalle d join public.pedidos_venta p on p.id = d.pedido_id
--    where p.estatus in ('pendiente','parcial') order by p.fecha, p.id;
