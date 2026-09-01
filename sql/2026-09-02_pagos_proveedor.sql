-- =====================================================================
--  Cuentas por pagar / Pagos a proveedores
--  Fecha: 2026-09-02  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: contabilidad fases 1-4 (cuentas, polizas, gastos, compras).
--
--  Una compra 'entrada_compra' a crédito o un gasto a crédito abonan a
--  201.01 Proveedores. Este módulo registra el PAGO posterior:
--    Cargo  201.01 Proveedores   (por cada documento aplicado)
--    Abono  <banco / caja>       (total del pago)
--  Póliza de Egreso vía registrar_poliza. Soporta pago parcial y de
--  varios documentos en un solo pago.
-- =====================================================================

begin;

-- 1. polizas.origen: agrega 'pago'
do $$
declare c record;
begin
    for c in select conname from pg_constraint
             where conrelid = 'public.polizas'::regclass and contype = 'c'
               and pg_get_constraintdef(oid) ilike '%origen%'
    loop execute format('alter table public.polizas drop constraint %I', c.conname); end loop;
end $$;
alter table public.polizas add constraint polizas_origen_check
    check (origen in ('manual','gasto','compra','venta','nomina','ajuste','salida','entrada','produccion','pago'));

-- 2. saldo pagado acumulado en cada documento fuente
alter table public.documentos add column if not exists total_pagado numeric(14,2) not null default 0;
alter table public.gastos     add column if not exists total_pagado numeric(14,2) not null default 0;

-- 3. tablas de pagos
create table if not exists public.pagos_proveedor (
    id             bigint generated always as identity primary key,
    fecha          date not null,
    cuenta_pago_id bigint references public.cuentas_contables (id),
    forma_pago     text,
    referencia     text,
    proveedor_id   bigint references public.proveedores (id) on delete set null,
    total          numeric(14,2) not null default 0,
    poliza_id      bigint references public.polizas (id) on delete set null,
    notas          text,
    estatus        text not null default 'registrado' check (estatus in ('registrado','cancelado')),
    created_at     timestamptz not null default now()
);

create table if not exists public.pagos_proveedor_aplicaciones (
    id           bigint generated always as identity primary key,
    pago_id      bigint not null references public.pagos_proveedor (id) on delete cascade,
    tipo         text not null check (tipo in ('compra','gasto')),
    documento_id bigint references public.documentos (id) on delete set null,
    gasto_id     bigint references public.gastos (id) on delete set null,
    monto        numeric(14,2) not null check (monto > 0)
);
create index if not exists pagos_proveedor_aplic_pago_idx on public.pagos_proveedor_aplicaciones (pago_id);

alter table public.pagos_proveedor              enable row level security;
alter table public.pagos_proveedor_aplicaciones enable row level security;
drop policy if exists admin_all on public.pagos_proveedor;
drop policy if exists admin_all on public.pagos_proveedor_aplicaciones;
create policy admin_all on public.pagos_proveedor              for all to authenticated using (true) with check (true);
create policy admin_all on public.pagos_proveedor_aplicaciones for all to authenticated using (true) with check (true);
grant all on public.pagos_proveedor, public.pagos_proveedor_aplicaciones to authenticated;

-- 4. vista: documentos a crédito con saldo pendiente
create or replace view public.v_cuentas_por_pagar as
    select 'compra'::text as tipo, d.id, d.folio,
           d.fecha_emision::date as fecha,
           d.proveedor_id, p.nombre as proveedor_nombre,
           coalesce(d.total, 0) as total,
           coalesce(d.total_pagado, 0) as pagado,
           round(coalesce(d.total, 0) - coalesce(d.total_pagado, 0), 2) as saldo,
           d.orden_compra_id
      from public.documentos d
      left join public.proveedores p on p.id = d.proveedor_id
     where d.tipo_movimiento = 'entrada_compra'
       and coalesce(d.condicion, '') = 'credito'
       and d.poliza_id is not null
       and round(coalesce(d.total, 0) - coalesce(d.total_pagado, 0), 2) > 0.005
    union all
    select 'gasto'::text, g.id, g.folio_factura,
           g.fecha,
           g.proveedor_id, p.nombre,
           coalesce(g.total, 0),
           coalesce(g.total_pagado, 0),
           round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2),
           null::bigint
      from public.gastos g
      left join public.proveedores p on p.id = g.proveedor_id
     where g.estatus = 'registrado'
       and g.condicion = 'credito'
       and round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2) > 0.005;

grant select on public.v_cuentas_por_pagar to authenticated;

-- 5. RPC registrar_pago_proveedor(p_datos) -> { pago_id, poliza_id, total }
--    p_datos: { fecha, cuenta_pago_id, forma_pago, referencia, notas,
--               aplicaciones: [ { tipo:'compra'|'gasto', id, monto } ] }
create or replace function public.registrar_pago_proveedor(p_datos jsonb)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_fecha     date   := (p_datos->>'fecha')::date;
    v_cta_pago  bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_forma     text   := nullif(trim(p_datos->>'forma_pago'), '');
    v_ref       text   := nullif(trim(p_datos->>'referencia'), '');
    v_notas     text   := nullif(trim(p_datos->>'notas'), '');
    v_apps      jsonb  := coalesce(p_datos->'aplicaciones', '[]'::jsonb);
    v_cuenta    public.cuentas_contables%rowtype;
    v_total     numeric(14,2) := 0;
    v_movs      jsonb := '[]'::jsonb;
    v_pago_id   bigint;
    v_poliza_id bigint;
    v_prov_ok   bigint := null;
    v_prov_set  boolean := false;
    v_cta201    bigint;
    r           jsonb;
    v_tipo      text;
    v_id        bigint;
    v_monto     numeric(14,2);
    v_saldo     numeric(14,2);
    v_prov      bigint;
    v_folio     text;
    d           public.documentos%rowtype;
    g           public.gastos%rowtype;
begin
    if v_fecha is null then raise exception 'La fecha del pago es obligatoria.'; end if;
    if jsonb_array_length(v_apps) < 1 then raise exception 'Selecciona al menos un documento a pagar.'; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
    if not found then raise exception 'Selecciona la cuenta de caja / banco.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    v_cta201 := public._cuenta_id('201.01');
    if v_cta201 is null then raise exception 'Falta la cuenta 201.01 (Proveedores) en el plan de cuentas.'; end if;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_tipo  := r->>'tipo';
        v_id    := (r->>'id')::bigint;
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        if v_monto <= 0 then raise exception 'Cada monto aplicado debe ser mayor a cero.'; end if;

        if v_tipo = 'compra' then
            select * into d from public.documentos where id = v_id;
            if not found then raise exception 'El documento de compra #% no existe.', v_id; end if;
            if coalesce(d.condicion, '') <> 'credito' then raise exception 'La compra % no es a credito.', coalesce(d.folio, '#'||v_id); end if;
            v_saldo := round(coalesce(d.total, 0) - coalesce(d.total_pagado, 0), 2);
            v_prov  := d.proveedor_id;
            v_folio := coalesce(d.folio, '#'||v_id);
        elsif v_tipo = 'gasto' then
            select * into g from public.gastos where id = v_id;
            if not found then raise exception 'El gasto #% no existe.', v_id; end if;
            if g.estatus <> 'registrado' then raise exception 'El gasto % esta %.', v_id, g.estatus; end if;
            if g.condicion <> 'credito' then raise exception 'El gasto % no es a credito.', v_id; end if;
            v_saldo := round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2);
            v_prov  := g.proveedor_id;
            v_folio := coalesce(g.folio_factura, g.concepto);
        else
            raise exception 'Tipo de aplicacion invalido: %', v_tipo;
        end if;

        if v_monto > v_saldo + 0.01 then
            raise exception 'El monto (%) supera el saldo pendiente (%) de % %.', v_monto, v_saldo, v_tipo, v_folio;
        end if;

        if not v_prov_set then v_prov_ok := v_prov; v_prov_set := true;
        elsif v_prov_ok is distinct from v_prov then v_prov_ok := null;
        end if;

        v_total := v_total + v_monto;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_monto,
                    'concepto', 'Pago ' || v_tipo || ' ' || v_folio, 'proveedor_id', v_prov);
    end loop;

    v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total,
                'concepto', 'Pago a proveedores' || coalesce(' - ' || v_ref, ''));

    insert into public.pagos_proveedor (fecha, cuenta_pago_id, forma_pago, referencia, proveedor_id, total, notas)
    values (v_fecha, v_cta_pago, v_forma, v_ref, v_prov_ok, v_total, v_notas)
    returning id into v_pago_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Egreso',
        'concepto', 'Pago a proveedores' || coalesce(' - ' || v_ref, ''),
        'origen', 'pago', 'origen_tabla', 'pagos_proveedor', 'origen_id', v_pago_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.pagos_proveedor set poliza_id = v_poliza_id where id = v_pago_id;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_tipo  := r->>'tipo';
        v_id    := (r->>'id')::bigint;
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        insert into public.pagos_proveedor_aplicaciones (pago_id, tipo, documento_id, gasto_id, monto)
        values (v_pago_id, v_tipo,
                case when v_tipo = 'compra' then v_id else null end,
                case when v_tipo = 'gasto'  then v_id else null end,
                v_monto);
        if v_tipo = 'compra' then
            update public.documentos set total_pagado = round(coalesce(total_pagado, 0) + v_monto, 2) where id = v_id;
        else
            update public.gastos set total_pagado = round(coalesce(total_pagado, 0) + v_monto, 2) where id = v_id;
        end if;
    end loop;

    return jsonb_build_object('pago_id', v_pago_id, 'poliza_id', v_poliza_id, 'total', v_total);
end $$;

revoke all     on function public.registrar_pago_proveedor(jsonb) from public;
grant  execute on function public.registrar_pago_proveedor(jsonb) to authenticated;

-- 6. RPC cancelar_pago_proveedor(p_pago_id) -> { poliza_reversa_id }
create or replace function public.cancelar_pago_proveedor(p_pago_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_pago public.pagos_proveedor%rowtype;
    a      public.pagos_proveedor_aplicaciones%rowtype;
    v_res  jsonb := '{}'::jsonb;
begin
    select * into v_pago from public.pagos_proveedor where id = p_pago_id;
    if not found then raise exception 'El pago no existe.'; end if;
    if v_pago.estatus <> 'registrado' then raise exception 'El pago ya esta %.', v_pago.estatus; end if;

    if v_pago.poliza_id is not null then
        v_res := public.cancelar_poliza(v_pago.poliza_id, 'Cancelacion de pago a proveedor #' || v_pago.id);
    end if;

    for a in select * from public.pagos_proveedor_aplicaciones where pago_id = p_pago_id
    loop
        if a.tipo = 'compra' and a.documento_id is not null then
            update public.documentos set total_pagado = greatest(0, round(coalesce(total_pagado, 0) - a.monto, 2)) where id = a.documento_id;
        elsif a.tipo = 'gasto' and a.gasto_id is not null then
            update public.gastos set total_pagado = greatest(0, round(coalesce(total_pagado, 0) - a.monto, 2)) where id = a.gasto_id;
        end if;
    end loop;

    update public.pagos_proveedor set estatus = 'cancelado' where id = p_pago_id;
    return v_res;
end $$;

revoke all     on function public.cancelar_pago_proveedor(bigint) from public, anon;
grant  execute on function public.cancelar_pago_proveedor(bigint) to authenticated;

commit;
