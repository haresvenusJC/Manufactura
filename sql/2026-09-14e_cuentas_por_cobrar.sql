-- =====================================================================
--  Cuentas por Cobrar / Cobros a clientes
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: contabilidad fases 1-6 (cuentas, polizas, gastos, compras,
--            operaciones — por contabilizar_venta y registrar_poliza).
--
--  Espejo de sql/2026-09-02_pagos_proveedor.sql pero del otro lado: una
--  venta 'salida_venta' a crédito abona a 105.01 Clientes (vía
--  contabilizar_venta). Este módulo registra el COBRO posterior:
--    Cargo  <banco / caja>       (total del cobro)
--    Abono  105.01 Clientes      (por cada documento aplicado)
--  Póliza de Ingreso vía registrar_poliza. Soporta cobro parcial y de
--  varias ventas en un solo cobro.
-- =====================================================================

begin;

-- 1. polizas.origen: agrega 'cobro' (conserva todo lo ya permitido)
do $$
declare c record;
begin
    for c in select conname from pg_constraint
             where conrelid = 'public.polizas'::regclass and contype = 'c'
               and pg_get_constraintdef(oid) ilike '%origen%'
    loop execute format('alter table public.polizas drop constraint %I', c.conname); end loop;
end $$;
alter table public.polizas add constraint polizas_origen_check
    check (origen in ('manual','gasto','compra','venta','nomina','ajuste','salida','entrada','produccion','pago','prorrateo','cobro'));

-- 2. saldo cobrado acumulado en el documento de venta
alter table public.documentos add column if not exists total_cobrado numeric(14,2) not null default 0;

-- 3. tablas de cobros
create table if not exists public.cobros_cliente (
    id              bigint generated always as identity primary key,
    fecha           date not null,
    cuenta_cobro_id bigint references public.cuentas_contables (id),
    forma_pago      text,
    referencia      text,
    cliente_id      bigint references public.clientes (id) on delete set null,
    total           numeric(14,2) not null default 0,
    poliza_id       bigint references public.polizas (id) on delete set null,
    notas           text,
    estatus         text not null default 'registrado' check (estatus in ('registrado','cancelado')),
    created_at      timestamptz not null default now()
);

create table if not exists public.cobros_cliente_aplicaciones (
    id           bigint generated always as identity primary key,
    cobro_id     bigint not null references public.cobros_cliente (id) on delete cascade,
    documento_id bigint references public.documentos (id) on delete set null,
    monto        numeric(14,2) not null check (monto > 0)
);
create index if not exists cobros_cliente_aplic_cobro_idx on public.cobros_cliente_aplicaciones (cobro_id);

alter table public.cobros_cliente              enable row level security;
alter table public.cobros_cliente_aplicaciones enable row level security;
drop policy if exists admin_all on public.cobros_cliente;
drop policy if exists admin_all on public.cobros_cliente_aplicaciones;
create policy admin_all on public.cobros_cliente              for all to authenticated using (true) with check (true);
create policy admin_all on public.cobros_cliente_aplicaciones for all to authenticated using (true) with check (true);
grant all on public.cobros_cliente, public.cobros_cliente_aplicaciones to authenticated;

-- 4. vista: ventas a crédito con saldo pendiente
create or replace view public.v_cuentas_por_cobrar as
    select d.id, d.folio,
           d.fecha_emision::date as fecha,
           d.cliente_id, coalesce(c.nombre, d.cliente_nombre, 'Sin cliente') as cliente_nombre,
           coalesce(d.venta_total, d.total, 0) as total,
           coalesce(d.total_cobrado, 0) as cobrado,
           round(coalesce(d.venta_total, d.total, 0) - coalesce(d.total_cobrado, 0), 2) as saldo,
           d.poliza_id,
           case
               when coalesce(d.estado, '') = 'cancelado' then 'cancelado'
               when round(coalesce(d.venta_total, d.total, 0) - coalesce(d.total_cobrado, 0), 2) <= 0.005 then 'pagado'
               else 'pendiente'
           end as estatus_cxc
      from public.documentos d
      left join public.clientes c on c.id = d.cliente_id
     where d.tipo_movimiento = 'salida_venta'
       and coalesce(d.condicion, '') = 'credito'
       and d.poliza_id is not null;

grant select on public.v_cuentas_por_cobrar to authenticated;

-- 5. RPC registrar_cobro_cliente(p_datos) -> { cobro_id, poliza_id, total }
--    p_datos: { fecha, cuenta_cobro_id, forma_pago, referencia, notas,
--               aplicaciones: [ { id (documento_id), monto } ] }
create or replace function public.registrar_cobro_cliente(p_datos jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_fecha     date   := (p_datos->>'fecha')::date;
    v_cta_cobro bigint := (p_datos->>'cuenta_cobro_id')::bigint;
    v_forma     text   := nullif(trim(p_datos->>'forma_pago'), '');
    v_ref       text   := nullif(trim(p_datos->>'referencia'), '');
    v_notas     text   := nullif(trim(p_datos->>'notas'), '');
    v_apps      jsonb  := coalesce(p_datos->'aplicaciones', '[]'::jsonb);
    v_cuenta    public.cuentas_contables%rowtype;
    v_total     numeric(14,2) := 0;
    v_movs      jsonb := '[]'::jsonb;
    v_cobro_id  bigint;
    v_poliza_id bigint;
    v_cli_ok    bigint := null;
    v_cli_set   boolean := false;
    v_cta105    bigint;
    r           jsonb;
    v_id        bigint;
    v_monto     numeric(14,2);
    v_saldo     numeric(14,2);
    v_cli       bigint;
    v_folio     text;
    d           public.documentos%rowtype;
begin
    if v_fecha is null then raise exception 'La fecha del cobro es obligatoria.'; end if;
    if jsonb_array_length(v_apps) < 1 then raise exception 'Selecciona al menos una venta a cobrar.'; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_cobro;
    if not found then raise exception 'Selecciona la cuenta de caja / banco donde entra el cobro.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    v_cta105 := public._cuenta_id('105.01');
    if v_cta105 is null then raise exception 'Falta la cuenta 105.01 (Clientes) en el plan de cuentas.'; end if;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_id    := (r->>'id')::bigint;
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        if v_monto <= 0 then raise exception 'Cada monto aplicado debe ser mayor a cero.'; end if;

        select * into d from public.documentos where id = v_id;
        if not found then raise exception 'El documento de venta #% no existe.', v_id; end if;
        if coalesce(d.condicion, '') <> 'credito' then raise exception 'La venta % no es a credito.', coalesce(d.folio, '#'||v_id); end if;
        v_saldo := round(coalesce(d.venta_total, d.total, 0) - coalesce(d.total_cobrado, 0), 2);
        v_cli   := d.cliente_id;
        v_folio := coalesce(d.folio, '#'||v_id);

        if v_monto > v_saldo + 0.01 then
            raise exception 'El monto (%) supera el saldo pendiente (%) de la venta %.', v_monto, v_saldo, v_folio;
        end if;

        if not v_cli_set then v_cli_ok := v_cli; v_cli_set := true;
        elsif v_cli_ok is distinct from v_cli then v_cli_ok := null;
        end if;

        v_total := v_total + v_monto;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta105, 'abono', v_monto,
                    'concepto', 'Cobro venta ' || v_folio, 'cliente_id', v_cli);
    end loop;

    v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_cobro, 'cargo', v_total,
                'concepto', 'Cobro a clientes' || coalesce(' - ' || v_ref, ''))) || v_movs;

    insert into public.cobros_cliente (fecha, cuenta_cobro_id, forma_pago, referencia, cliente_id, total, notas)
    values (v_fecha, v_cta_cobro, v_forma, v_ref, v_cli_ok, v_total, v_notas)
    returning id into v_cobro_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Ingreso',
        'concepto', 'Cobro a clientes' || coalesce(' - ' || v_ref, ''),
        'origen', 'cobro', 'origen_tabla', 'cobros_cliente', 'origen_id', v_cobro_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.cobros_cliente set poliza_id = v_poliza_id where id = v_cobro_id;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_id    := (r->>'id')::bigint;
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        insert into public.cobros_cliente_aplicaciones (cobro_id, documento_id, monto)
        values (v_cobro_id, v_id, v_monto);
        update public.documentos set total_cobrado = round(coalesce(total_cobrado, 0) + v_monto, 2) where id = v_id;
    end loop;

    return jsonb_build_object('cobro_id', v_cobro_id, 'poliza_id', v_poliza_id, 'total', v_total);
end $$;

revoke all     on function public.registrar_cobro_cliente(jsonb) from public;
grant  execute on function public.registrar_cobro_cliente(jsonb) to authenticated;

-- 6. RPC cancelar_cobro_cliente(p_cobro_id) -> { poliza_reversa_id }
create or replace function public.cancelar_cobro_cliente(p_cobro_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_cobro public.cobros_cliente%rowtype;
    a       public.cobros_cliente_aplicaciones%rowtype;
    v_res   jsonb := '{}'::jsonb;
begin
    select * into v_cobro from public.cobros_cliente where id = p_cobro_id;
    if not found then raise exception 'El cobro no existe.'; end if;
    if v_cobro.estatus <> 'registrado' then raise exception 'El cobro ya esta %.', v_cobro.estatus; end if;

    if v_cobro.poliza_id is not null then
        v_res := public.cancelar_poliza(v_cobro.poliza_id, 'Cancelacion de cobro a cliente #' || v_cobro.id);
    end if;

    for a in select * from public.cobros_cliente_aplicaciones where cobro_id = p_cobro_id
    loop
        if a.documento_id is not null then
            update public.documentos set total_cobrado = greatest(0, round(coalesce(total_cobrado, 0) - a.monto, 2)) where id = a.documento_id;
        end if;
    end loop;

    update public.cobros_cliente set estatus = 'cancelado' where id = p_cobro_id;
    return v_res;
end $$;

revoke all     on function public.cancelar_cobro_cliente(bigint) from public, anon;
grant  execute on function public.cancelar_cobro_cliente(bigint) to authenticated;

commit;

-- =====================================================================
-- select estatus_cxc, count(*) from v_cuentas_por_cobrar group by 1;
-- =====================================================================
