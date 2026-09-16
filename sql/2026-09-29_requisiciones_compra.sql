-- =====================================================================
--  Requisiciones de compra (paso previo a la Orden de Compra)
--  Fecha: 2026-09-29  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Antes, "Inventario bajo mínimo" mandaba directo a crear una Orden de
--  Compra. Ahora primero genera una Requisición (estatus 'pendiente') que
--  el admin revisa: la autoriza (se convierte en Orden de Compra real,
--  eligiendo proveedor/fecha esperada/moneda) o la rechaza. También sirve
--  para requisiciones manuales, no solo las disparadas por stock bajo.
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.requisiciones_compra (
    id              bigint generated always as identity primary key,
    folio           text not null,
    fecha           date not null default current_date,
    origen          text not null default 'manual'
        check (origen in ('manual', 'stock_bajo_minimo')),
    estatus         text not null default 'pendiente'
        check (estatus in ('pendiente', 'autorizada', 'rechazada', 'cancelada')),
    solicitada_por  text,
    notas           text,
    revisada_por    text,
    revisada_en     timestamptz,
    motivo_rechazo  text,
    orden_compra_id bigint references public.ordenes_compra (id) on delete set null,
    created_at      timestamptz not null default now()
);

create table if not exists public.requisiciones_compra_detalle (
    id                     bigint generated always as identity primary key,
    requisicion_id         bigint not null references public.requisiciones_compra (id) on delete cascade,
    producto_id            bigint references public.productos (id) on delete set null,
    descripcion            text,               -- si el producto aún no existe en el catálogo
    cantidad               numeric not null check (cantidad > 0),
    unidad_medida_id       bigint references public.unidades_medida (id),
    proveedor_sugerido_id  bigint references public.proveedores (id) on delete set null,
    costo_estimado         numeric not null default 0,
    notas                  text
);

create index if not exists requisiciones_compra_detalle_req_idx
    on public.requisiciones_compra_detalle (requisicion_id);
create index if not exists requisiciones_compra_estatus_idx
    on public.requisiciones_compra (estatus);

alter table public.requisiciones_compra          enable row level security;
alter table public.requisiciones_compra_detalle  enable row level security;
drop policy if exists admin_all on public.requisiciones_compra;
drop policy if exists admin_all on public.requisiciones_compra_detalle;
create policy admin_all on public.requisiciones_compra
    for all to authenticated using (true) with check (true);
create policy admin_all on public.requisiciones_compra_detalle
    for all to authenticated using (true) with check (true);
grant all on public.requisiciones_compra, public.requisiciones_compra_detalle to authenticated;

-- =====================================================================
--  requisicion_autorizar: convierte una requisición 'pendiente' en una
--  Orden de Compra real (misma tabla/estructura que crea el formulario
--  manual de Órdenes de compra) y la marca 'autorizada'.
-- =====================================================================
create or replace function public.requisicion_autorizar(
    p_requisicion_id bigint,
    p_proveedor_id   bigint,
    p_fecha_esperada date default null,
    p_moneda_id      bigint default null,
    p_revisada_por   text default null
)
returns table (oc_id bigint, oc_folio text)
language plpgsql
volatile
set search_path = public
as $$
declare
    v_estatus text;
    v_oc_id   bigint;
    v_oc_folio text;
begin
    select estatus into v_estatus
      from public.requisiciones_compra
     where id = p_requisicion_id
       for update;

    if v_estatus is null then
        raise exception 'La requisición % no existe.', p_requisicion_id;
    end if;
    if v_estatus <> 'pendiente' then
        raise exception 'La requisición ya está en estatus "%": no se puede autorizar de nuevo.', v_estatus;
    end if;
    if p_proveedor_id is null then
        raise exception 'Elige el proveedor con el que se va a comprar.';
    end if;
    if not exists (select 1 from public.requisiciones_compra_detalle where requisicion_id = p_requisicion_id) then
        raise exception 'La requisición no tiene partidas.';
    end if;

    v_oc_folio := 'OC-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.ordenes_compra (folio, proveedor_id, fecha, fecha_esperada, moneda_id, estatus, notas)
    values (
        v_oc_folio, p_proveedor_id, current_date, p_fecha_esperada, p_moneda_id, 'abierta',
        'Generada desde requisición ' || (select folio from public.requisiciones_compra where id = p_requisicion_id)
    )
    returning id into v_oc_id;

    insert into public.ordenes_compra_detalle (orden_compra_id, producto_id, descripcion, cantidad, cantidad_recibida, costo_unitario_estimado, unidad_medida_id, notas)
    select v_oc_id, d.producto_id, d.descripcion, d.cantidad, 0, d.costo_estimado, d.unidad_medida_id, d.notas
      from public.requisiciones_compra_detalle d
     where d.requisicion_id = p_requisicion_id;

    update public.requisiciones_compra
       set estatus = 'autorizada',
           orden_compra_id = v_oc_id,
           revisada_por = p_revisada_por,
           revisada_en = now()
     where id = p_requisicion_id;

    return query select v_oc_id, v_oc_folio;
end;
$$;

-- =====================================================================
--  requisicion_rechazar: cierra una requisición 'pendiente' sin generar
--  Orden de Compra.
-- =====================================================================
create or replace function public.requisicion_rechazar(
    p_requisicion_id bigint,
    p_motivo         text,
    p_revisada_por   text default null
)
returns void
language plpgsql
volatile
set search_path = public
as $$
declare
    v_estatus text;
begin
    select estatus into v_estatus
      from public.requisiciones_compra
     where id = p_requisicion_id
       for update;

    if v_estatus is null then
        raise exception 'La requisición % no existe.', p_requisicion_id;
    end if;
    if v_estatus <> 'pendiente' then
        raise exception 'La requisición ya está en estatus "%": no se puede rechazar.', v_estatus;
    end if;

    update public.requisiciones_compra
       set estatus = 'rechazada',
           motivo_rechazo = p_motivo,
           revisada_por = p_revisada_por,
           revisada_en = now()
     where id = p_requisicion_id;
end;
$$;

grant execute on function public.requisicion_autorizar(bigint, bigint, date, bigint, text) to authenticated;
grant execute on function public.requisicion_rechazar(bigint, text, text) to authenticated;

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select * from public.requisiciones_compra order by created_at desc limit 20;
-- select p.prosrc is not null as existe from pg_proc p where p.proname = 'requisicion_autorizar';
