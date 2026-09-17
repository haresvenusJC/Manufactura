-- =====================================================================
--  Pedidos de venta (cliente pide, se surte después — total o parcial)
--  Fecha: 2026-10-04  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  "Salidas / Ventas" siempre fue una salida inmediata y completa contra
--  el stock disponible — no había forma de anotar que un cliente pidió
--  algo que se le va a surtir después (total o en partes). Este archivo
--  agrega el Pedido: se captura, y cada vez que se surte (total o
--  parcialmente) genera una salida real de inventario reusando
--  registrarSalidaMultiPartida (js/salidas.js) — mismo motor de
--  inventario/kardex que ya existe, solo con el link nuevo al pedido.
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.pedidos_venta (
    id          bigint generated always as identity primary key,
    folio       text not null,
    fecha       date not null default current_date,
    cliente_id  bigint references public.clientes (id) on delete set null,
    estatus     text not null default 'pendiente'
        check (estatus in ('pendiente', 'parcial', 'surtido', 'cancelado')),
    notas       text,
    created_at  timestamptz not null default now()
);

create table if not exists public.pedidos_venta_detalle (
    id                bigint generated always as identity primary key,
    pedido_id         bigint not null references public.pedidos_venta (id) on delete cascade,
    producto_id       bigint references public.productos (id) on delete set null,
    descripcion       text,
    cantidad          numeric not null check (cantidad > 0),
    cantidad_surtida  numeric not null default 0,
    precio_unitario   numeric not null default 0,
    unidad_medida_id  bigint references public.unidades_medida (id)
);

create index if not exists pedidos_venta_detalle_pedido_idx on public.pedidos_venta_detalle (pedido_id);
create index if not exists pedidos_venta_estatus_idx on public.pedidos_venta (estatus);

-- Enlace salida -> pedido que la disparó (mismo patrón que documentos.orden_compra_id).
alter table public.documentos
    add column if not exists pedido_venta_id bigint references public.pedidos_venta (id) on delete set null;

alter table public.pedidos_venta          enable row level security;
alter table public.pedidos_venta_detalle  enable row level security;
drop policy if exists admin_all on public.pedidos_venta;
drop policy if exists admin_all on public.pedidos_venta_detalle;
create policy admin_all on public.pedidos_venta
    for all to authenticated using (true) with check (true);
create policy admin_all on public.pedidos_venta_detalle
    for all to authenticated using (true) with check (true);
grant all on public.pedidos_venta, public.pedidos_venta_detalle to authenticated;

drop trigger if exists trg_bitacora_pedidos_venta on public.pedidos_venta;
create trigger trg_bitacora_pedidos_venta
    after insert or update or delete on public.pedidos_venta
    for each row execute function public.fn_bitacora_generica();

-- pedido_venta_cancelar: solo si nada se ha surtido todavía (si ya se
-- surtió algo, hay que usar Devolución de cliente para lo entregado).
create or replace function public.pedido_venta_cancelar(p_pedido_id bigint, p_motivo text)
returns void
language plpgsql
volatile
set search_path = public
as $$
declare
    v_surtido numeric;
begin
    select coalesce(sum(cantidad_surtida), 0) into v_surtido
      from public.pedidos_venta_detalle where pedido_id = p_pedido_id;
    if v_surtido > 0 then
        raise exception 'Este pedido ya tiene mercancía surtida — cancela mediante una Devolución de cliente, no aquí.';
    end if;
    update public.pedidos_venta
       set estatus = 'cancelado', notas = coalesce(notas || ' — ', '') || 'Cancelado: ' || coalesce(p_motivo, 'sin motivo')
     where id = p_pedido_id and estatus <> 'cancelado';
end;
$$;

grant execute on function public.pedido_venta_cancelar(bigint, text) to authenticated;

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select * from public.pedidos_venta order by created_at desc limit 20;
