-- =====================================================================
--  Reservas de inventario — ENTREGA 2 de 4: guardia en la BASE
--  Fecha: 2026-11-05  ·  Proyecto: Hares de México (Supabase)
--
--  Hasta ahora el candado contra "llevarse mercancía apartada" vivía solo
--  en las pantallas. Ahora la base lo hace cumplir: un trigger BEFORE UPDATE
--  en lotes_inventario rechaza cualquier BAJA de stock que se meta en lo
--  apartado por pedidos pendientes, salvo que exista una AUTORIZACIÓN corta
--  (reserva_autorizar_salida) para ese producto.
--
--  Quién autoriza (lo hace la pantalla de Salidas antes de mover el stock):
--   - El surtido de un pedido de venta (la mercancía es de ese pedido).
--   - Merma / ajuste / cualquier salida que NO sea venta: son pérdidas
--     reales; se permiten y las reservas se recortan solas (el pedido más
--     nuevo primero), dejando una nota en ese pedido (→ Bitácora).
--   Una venta o salida directa NO se autoriza: la base la rechaza si toca
--   lo apartado ("RESERVA_PROTEGIDA").
--
--  Otras rutas que bajan stock (devolución a proveedor, cancelar recibo,
--  cancelar devolución de cliente) tampoco están autorizadas: si de verdad
--  se meten en lo apartado, la base avisa y hay que liberar la reserva
--  (Pedidos de venta → Liberar) o surtir/cancelar el pedido primero.
--
--  A prueba de fallos: solo el rechazo "RESERVA_PROTEGIDA" detiene la
--  operación; cualquier otro error interno de la guardia se ignora con
--  un WARNING. La autorización dura 2 minutos y se consume al usarse.
--  Requiere sql/2026-11-03 y 2026-11-03b. Idempotente. No toca contabilidad.
-- =====================================================================
begin;

create table if not exists public.reservas_autorizaciones (
    id          bigint generated always as identity primary key,
    producto_id bigint not null,
    restante    numeric not null check (restante >= 0),
    motivo      text,
    usuario     uuid default auth.uid(),
    creada      timestamptz not null default now(),
    expira      timestamptz not null default now() + interval '2 minutes'
);
create index if not exists reservas_autorizaciones_prod_idx on public.reservas_autorizaciones (producto_id, expira);

alter table public.reservas_autorizaciones enable row level security;
-- Sin políticas: nadie la toca directo; solo las funciones (security definer).

-- ---------------------------------------------------------------------
-- Autorización corta de salida para un producto.
-- ---------------------------------------------------------------------
create or replace function public.reserva_autorizar_salida(p_producto_id bigint, p_cantidad numeric, p_motivo text default null)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
    v_id bigint;
begin
    if p_producto_id is null or coalesce(p_cantidad, 0) <= 0 then
        raise exception 'Producto y cantidad son obligatorios.';
    end if;
    delete from public.reservas_autorizaciones where expira < now() - interval '1 day';
    insert into public.reservas_autorizaciones (producto_id, restante, motivo)
        values (p_producto_id, p_cantidad, p_motivo)
        returning id into v_id;
    return v_id;
end;
$$;

grant execute on function public.reserva_autorizar_salida(bigint, numeric, text) to authenticated;

-- ---------------------------------------------------------------------
-- La guardia: BEFORE UPDATE OF stock_actual en lotes_inventario.
-- ---------------------------------------------------------------------
create or replace function public.trg_guardia_reservas_lote()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_baja      numeric;
    v_stock     numeric;
    v_reservado numeric;
    v_libre     numeric;
    v_dip       numeric;
    v_aut       record;
begin
    begin
        v_baja := coalesce(old.stock_actual, 0) - coalesce(new.stock_actual, 0);
        if v_baja <= 0 or new.producto_id is null then
            return new;
        end if;

        select coalesce(sum(d.cantidad_reservada), 0) into v_reservado
          from public.pedidos_venta_detalle d
          join public.pedidos_venta v on v.id = d.pedido_id
         where d.producto_id = new.producto_id and v.estatus in ('pendiente', 'parcial');
        if v_reservado <= 0 then
            return new;
        end if;

        perform pg_advisory_xact_lock(7001000000000 + new.producto_id);

        select coalesce(sum(stock_actual), 0) into v_stock
          from public.lotes_inventario where producto_id = new.producto_id;

        v_libre := greatest(v_stock - v_reservado, 0);
        v_dip := v_baja - v_libre;               -- cuánto de la baja se mete en lo apartado
        if v_dip <= 0.000001 then
            return new;
        end if;

        select id, restante into v_aut
          from public.reservas_autorizaciones
         where producto_id = new.producto_id and expira > now() and restante >= v_dip - 0.000001
         order by id
         limit 1
         for update;

        if found then
            update public.reservas_autorizaciones
               set restante = greatest(restante - v_baja, 0)
             where id = v_aut.id;
            return new;
        end if;

        raise exception 'RESERVA_PROTEGIDA: el producto % tiene % apartadas por pedidos de venta pendientes y solo % libres; esta baja se llevaría % de lo apartado. Surte o cancela esos pedidos, o libera la reserva (Pedidos de venta → Liberar), y vuelve a intentar.',
            new.producto_id, v_reservado, v_libre, round(v_dip, 4);
    exception when others then
        if sqlerrm like 'RESERVA_PROTEGIDA%' then
            raise;
        end if;
        raise warning 'guardia_reservas_lote: % (se ignora, no bloquea la operación)', sqlerrm;
        return new;
    end;
end;
$$;

drop trigger if exists trg_guardia_reservas_lote on public.lotes_inventario;
create trigger trg_guardia_reservas_lote
    before update of stock_actual on public.lotes_inventario
    for each row execute function public.trg_guardia_reservas_lote();

-- ---------------------------------------------------------------------
-- Si una baja AUTORIZADA (merma/ajuste) recorta la reserva de un pedido que
-- todavía necesita la mercancía, queda una nota en ese pedido (→ Bitácora).
-- Surtir, liberar o cancelar NO generan nota: solo cuenta si hay una autorización vigente que no sea de surtido.
-- ---------------------------------------------------------------------
create or replace function public.trg_nota_reserva_recortada()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    begin
        if new.cantidad_reservada < old.cantidad_reservada
           and coalesce(new.apartar, true)
           and (new.cantidad - new.cantidad_surtida) >= old.cantidad_reservada - 0.000001
           and exists (select 1 from public.pedidos_venta v where v.id = new.pedido_id and v.estatus in ('pendiente', 'parcial'))
           and exists (select 1 from public.reservas_autorizaciones a
                        where a.producto_id = new.producto_id and a.expira > now() and coalesce(a.motivo, '') not like 'surtido%')
        then
            update public.pedidos_venta
               set notas = coalesce(nullif(notas, '') || E'\n', '')
                   || '[' || to_char(now() at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI') || '] Reserva recortada de '
                   || old.cantidad_reservada || ' a ' || new.cantidad_reservada
                   || ' por una baja de inventario (merma/ajuste) — producto ' || new.producto_id || '.'
             where id = new.pedido_id;
        end if;
    exception when others then
        raise warning 'nota_reserva_recortada: % (se ignora)', sqlerrm;
    end;
    return null;
end;
$$;

do $$
begin
    -- apartar existe desde 2026-11-03b; sin ella no se crea la nota (la guardia sigue funcionando).
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'pedidos_venta_detalle' and column_name = 'apartar') then
        drop trigger if exists trg_nota_reserva_recortada on public.pedidos_venta_detalle;
        create trigger trg_nota_reserva_recortada
            after update of cantidad_reservada on public.pedidos_venta_detalle
            for each row execute function public.trg_nota_reserva_recortada();
    end if;
end $$;

commit;

-- Revisión:
--   select * from public.reservas_autorizaciones order by id desc limit 10;
