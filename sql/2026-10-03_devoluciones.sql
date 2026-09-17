-- =====================================================================
--  Devoluciones a proveedor y de cliente
--  Fecha: 2026-10-03  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  No existía ningún módulo de devoluciones — solo las cuentas 402/402.01
--  "Devoluciones y descuentos s/ ventas" sembradas desde el plan de
--  cuentas inicial, sin usar. Este archivo agrega:
--
--  · Devolución de cliente: el cliente regresa producto. Entra de vuelta
--    al inventario como un LOTE NUEVO (no se intenta encontrar el lote
--    original — puede ya no existir o estar mezclado), a su costo
--    original de venta. Póliza: Cargo 402.01 Devoluciones s/ventas +
--    Abono 105.01 Clientes (revierte el ingreso), y Cargo <inventario
--    del producto> + Abono 501.01 Costo de venta (revierte el costo).
--  · Devolución a proveedor: tú regresas producto que ya tenías en
--    inventario. Sale de un LOTE EXISTENTE que elige el usuario (debe
--    tener suficiente stock_actual Y stock_costeo). Póliza: Cargo 201.01
--    Proveedores (reduce lo que le debes) + Abono <inventario del
--    producto> (reduce el activo, a costo del lote).
--
--  Simplificación consciente: NO se recalcula IVA/IEPS de la devolución
--  ni se emite CFDI de nota de crédito — es el efecto de inventario y el
--  asiento base. Si el proveedor/cliente exige ajuste fiscal, se
--  complementa a mano en la póliza generada.
--
--  Idempotente.
-- =====================================================================

begin;

insert into public.tipos_movimiento (codigo, nombre, naturaleza)
values
    ('devolucion_cliente', 'Devolución de cliente', 'entrada'),
    ('devolucion_proveedor', 'Devolución a proveedor', 'salida')
on conflict (codigo) do nothing;

-- =====================================================================
--  1. Devolución de cliente
-- =====================================================================
create table if not exists public.devoluciones_cliente (
    id                  bigint generated always as identity primary key,
    folio               text not null,
    fecha               date not null default current_date,
    cliente_id          bigint references public.clientes (id) on delete set null,
    documento_venta_id  bigint references public.documentos (id) on delete set null,
    documento_id        bigint references public.documentos (id) on delete set null,
    motivo              text,
    estatus             text not null default 'registrada' check (estatus in ('registrada', 'cancelada')),
    poliza_id           bigint references public.polizas (id),
    notas               text,
    created_at          timestamptz not null default now()
);

create table if not exists public.devoluciones_cliente_detalle (
    id               bigint generated always as identity primary key,
    devolucion_id    bigint not null references public.devoluciones_cliente (id) on delete cascade,
    producto_id      bigint references public.productos (id),
    cantidad         numeric not null check (cantidad > 0),
    costo_unitario   numeric not null default 0,
    precio_unitario  numeric not null default 0,
    unidad_medida_id bigint references public.unidades_medida (id),
    lote_nuevo_id    bigint references public.lotes_inventario (id)
);

alter table public.devoluciones_cliente          enable row level security;
alter table public.devoluciones_cliente_detalle  enable row level security;
drop policy if exists admin_all on public.devoluciones_cliente;
drop policy if exists admin_all on public.devoluciones_cliente_detalle;
create policy admin_all on public.devoluciones_cliente
    for all to authenticated using (true) with check (true);
create policy admin_all on public.devoluciones_cliente_detalle
    for all to authenticated using (true) with check (true);
grant all on public.devoluciones_cliente, public.devoluciones_cliente_detalle to authenticated;

drop trigger if exists trg_bitacora_devoluciones_cliente on public.devoluciones_cliente;
create trigger trg_bitacora_devoluciones_cliente
    after insert or update or delete on public.devoluciones_cliente
    for each row execute function public.fn_bitacora_generica();

-- registrar_devolucion_cliente(p_datos jsonb) -> { devolucion_id, documento_id, poliza_id, total_venta, total_costo }
--   p_datos: { fecha, cliente_id, documento_venta_id, motivo, notas,
--              partidas: [{ producto_id, cantidad, costo_unitario, precio_unitario, unidad_medida_id }] }
create or replace function public.registrar_devolucion_cliente(p_datos jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_fecha         date := coalesce((p_datos->>'fecha')::date, current_date);
    v_cliente_id    bigint := (p_datos->>'cliente_id')::bigint;
    v_partidas      jsonb := coalesce(p_datos->'partidas', '[]'::jsonb);
    v_folio         text;
    v_devolucion_id bigint;
    v_documento_id  bigint;
    v_p             record;
    v_lote_id       bigint;
    v_total_venta   numeric(14,2) := 0;
    v_total_costo   numeric(14,2) := 0;
    v_movs          jsonb := '[]'::jsonb;
    v_costo_por_cta jsonb := '{}'::jsonb;
    v_cta_inv       bigint;
    v_cta_dev       bigint := public._cuenta_id('402.01');
    v_cta_cli       bigint := public._cuenta_id('105.01');
    v_cta_costo     bigint := public._cuenta_id('501.01');
    v_poliza        jsonb;
    v_poliza_id     bigint;
    v_stock_prod    numeric;
    v_key           text;
begin
    if jsonb_array_length(v_partidas) = 0 then raise exception 'La devolución no tiene partidas.'; end if;
    if v_cta_dev is null then raise exception 'Falta la cuenta 402.01 (Devoluciones sobre ventas) en el plan de cuentas.'; end if;
    if v_cta_cli is null then raise exception 'Falta la cuenta 105.01 (Clientes) en el plan de cuentas.'; end if;
    if v_cta_costo is null then raise exception 'Falta la cuenta 501.01 (Costo de venta) en el plan de cuentas.'; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    v_folio := 'DEVCLI-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('devolucion_cliente', v_folio, v_fecha, coalesce(nullif(trim(p_datos->>'notas'), ''), 'Devolución de cliente'), 'completado')
    returning id into v_documento_id;

    insert into public.devoluciones_cliente (folio, fecha, cliente_id, documento_venta_id, documento_id, motivo, notas)
    values (v_folio, v_fecha, v_cliente_id, (p_datos->>'documento_venta_id')::bigint, v_documento_id,
            nullif(trim(p_datos->>'motivo'), ''), nullif(trim(p_datos->>'notas'), ''))
    returning id into v_devolucion_id;

    for v_p in select * from jsonb_to_recordset(v_partidas) as x(
        producto_id bigint, cantidad numeric, costo_unitario numeric, precio_unitario numeric, unidad_medida_id bigint)
    loop
        if v_p.producto_id is null or v_p.cantidad is null or v_p.cantidad <= 0 then
            raise exception 'Cada partida necesita producto y cantidad mayor a 0.';
        end if;

        insert into public.lotes_inventario (producto_id, numero_lote, fecha_ingreso, stock_actual, stock_costeo, costo_unitario_final, documento_id)
        values (v_p.producto_id, 'DEV-' || v_devolucion_id || '-' || v_p.producto_id, v_fecha,
                v_p.cantidad, v_p.cantidad, coalesce(v_p.costo_unitario, 0), v_documento_id)
        returning id into v_lote_id;

        insert into public.devoluciones_cliente_detalle
            (devolucion_id, producto_id, cantidad, costo_unitario, precio_unitario, unidad_medida_id, lote_nuevo_id)
        values (v_devolucion_id, v_p.producto_id, v_p.cantidad, coalesce(v_p.costo_unitario, 0), coalesce(v_p.precio_unitario, 0), v_p.unidad_medida_id, v_lote_id);

        select coalesce(stock_actual, 0) into v_stock_prod from public.productos where id = v_p.producto_id;
        update public.productos set stock_actual = v_stock_prod + v_p.cantidad where id = v_p.producto_id;

        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        values (v_p.producto_id, 'devolucion_cliente', v_p.cantidad, v_stock_prod, v_stock_prod + v_p.cantidad, coalesce(v_p.costo_unitario, 0), v_documento_id);

        v_total_venta := v_total_venta + (v_p.cantidad * coalesce(v_p.precio_unitario, 0));
        v_total_costo := v_total_costo + (v_p.cantidad * coalesce(v_p.costo_unitario, 0));

        select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.04')) into v_cta_inv
          from public.productos pr where pr.id = v_p.producto_id;
        v_key := v_cta_inv::text;
        v_costo_por_cta := jsonb_set(v_costo_por_cta, array[v_key],
            to_jsonb(coalesce((v_costo_por_cta->>v_key)::numeric, 0) + (v_p.cantidad * coalesce(v_p.costo_unitario, 0))));
    end loop;

    if v_total_venta <= 0 then raise exception 'El importe de la devolución debe ser mayor a 0.'; end if;

    v_movs := v_movs || jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_dev, 'cargo', v_total_venta, 'abono', 0, 'concepto', 'Devolución cliente ' || v_folio, 'cliente_id', v_cliente_id),
        jsonb_build_object('cuenta_id', v_cta_cli, 'cargo', 0, 'abono', v_total_venta, 'concepto', 'Devolución cliente ' || v_folio, 'cliente_id', v_cliente_id)
    );

    if v_total_costo > 0 then
        for v_key in select jsonb_object_keys(v_costo_por_cta) loop
            v_movs := v_movs || jsonb_build_array(
                jsonb_build_object('cuenta_id', v_key::bigint, 'cargo', (v_costo_por_cta->>v_key)::numeric, 'abono', 0,
                                    'concepto', 'Devolución cliente ' || v_folio || ' — regresa a inventario')
            );
        end loop;
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_costo, 'cargo', 0, 'abono', v_total_costo, 'concepto', 'Devolución cliente ' || v_folio || ' — revierte costo de venta')
        );
    end if;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Diario', 'concepto', 'Devolución de cliente ' || v_folio,
        'origen', 'devolucion_cliente', 'origen_tabla', 'devoluciones_cliente', 'origen_id', v_devolucion_id,
        'movimientos', v_movs
    ));
    v_poliza_id := (v_poliza->>'poliza_id')::bigint;
    update public.devoluciones_cliente set poliza_id = v_poliza_id where id = v_devolucion_id;

    return jsonb_build_object('devolucion_id', v_devolucion_id, 'documento_id', v_documento_id, 'poliza_id', v_poliza_id, 'total_venta', v_total_venta, 'total_costo', v_total_costo);
end;
$$;

-- cancelar_devolucion_cliente(p_id, p_motivo): revierte póliza + descuenta el lote nuevo de vuelta.
create or replace function public.cancelar_devolucion_cliente(p_devolucion_id bigint, p_motivo text)
returns void
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_dev    record;
    v_d      record;
    v_stock  numeric;
begin
    select * into v_dev from public.devoluciones_cliente where id = p_devolucion_id;
    if v_dev is null then raise exception 'La devolución % no existe.', p_devolucion_id; end if;
    if v_dev.estatus <> 'registrada' then raise exception 'Esta devolución ya está "%".', v_dev.estatus; end if;

    for v_d in select * from public.devoluciones_cliente_detalle where devolucion_id = p_devolucion_id loop
        if v_d.lote_nuevo_id is not null then
            select coalesce(stock_actual, 0) into v_stock from public.lotes_inventario where id = v_d.lote_nuevo_id;
            if v_stock < v_d.cantidad then
                raise exception 'El lote de la devolución de "%" ya se movió (quedan %, se necesitan %) — no se puede cancelar.',
                    v_d.producto_id, v_stock, v_d.cantidad;
            end if;
            update public.lotes_inventario set stock_actual = stock_actual - v_d.cantidad, stock_costeo = stock_costeo - v_d.cantidad
             where id = v_d.lote_nuevo_id;
        end if;
        update public.productos set stock_actual = greatest(0, stock_actual - v_d.cantidad) where id = v_d.producto_id;
        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        select v_d.producto_id, 'cancelacion_devolucion_cliente', -v_d.cantidad, stock_actual + v_d.cantidad, stock_actual, v_d.costo_unitario, v_dev.documento_id
          from public.productos where id = v_d.producto_id;
    end loop;

    if v_dev.poliza_id is not null then
        perform public.cancelar_poliza(v_dev.poliza_id, p_motivo);
    end if;
    update public.documentos set estado = 'cancelado' where id = v_dev.documento_id;
    update public.devoluciones_cliente set estatus = 'cancelada' where id = p_devolucion_id;
end;
$$;

grant execute on function public.registrar_devolucion_cliente(jsonb) to authenticated;
grant execute on function public.cancelar_devolucion_cliente(bigint, text) to authenticated;

-- =====================================================================
--  2. Devolución a proveedor
-- =====================================================================
create table if not exists public.devoluciones_proveedor (
    id                    bigint generated always as identity primary key,
    folio                 text not null,
    fecha                 date not null default current_date,
    proveedor_id          bigint references public.proveedores (id) on delete set null,
    documento_compra_id   bigint references public.documentos (id) on delete set null,
    documento_id          bigint references public.documentos (id) on delete set null,
    motivo                text,
    estatus               text not null default 'registrada' check (estatus in ('registrada', 'cancelada')),
    poliza_id             bigint references public.polizas (id),
    notas                 text,
    created_at            timestamptz not null default now()
);

create table if not exists public.devoluciones_proveedor_detalle (
    id               bigint generated always as identity primary key,
    devolucion_id    bigint not null references public.devoluciones_proveedor (id) on delete cascade,
    producto_id      bigint references public.productos (id),
    lote_id          bigint references public.lotes_inventario (id),
    cantidad         numeric not null check (cantidad > 0),
    costo_unitario   numeric not null default 0,
    unidad_medida_id bigint references public.unidades_medida (id)
);

alter table public.devoluciones_proveedor          enable row level security;
alter table public.devoluciones_proveedor_detalle  enable row level security;
drop policy if exists admin_all on public.devoluciones_proveedor;
drop policy if exists admin_all on public.devoluciones_proveedor_detalle;
create policy admin_all on public.devoluciones_proveedor
    for all to authenticated using (true) with check (true);
create policy admin_all on public.devoluciones_proveedor_detalle
    for all to authenticated using (true) with check (true);
grant all on public.devoluciones_proveedor, public.devoluciones_proveedor_detalle to authenticated;

drop trigger if exists trg_bitacora_devoluciones_proveedor on public.devoluciones_proveedor;
create trigger trg_bitacora_devoluciones_proveedor
    after insert or update or delete on public.devoluciones_proveedor
    for each row execute function public.fn_bitacora_generica();

-- registrar_devolucion_proveedor(p_datos jsonb) -> { devolucion_id, documento_id, poliza_id, total }
--   p_datos: { fecha, proveedor_id, documento_compra_id, motivo, notas,
--              partidas: [{ producto_id, lote_id, cantidad, unidad_medida_id }] }
--   El costo se toma del lote (costo_unitario_final), no se captura a mano.
create or replace function public.registrar_devolucion_proveedor(p_datos jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_fecha         date := coalesce((p_datos->>'fecha')::date, current_date);
    v_proveedor_id  bigint := (p_datos->>'proveedor_id')::bigint;
    v_partidas      jsonb := coalesce(p_datos->'partidas', '[]'::jsonb);
    v_folio         text;
    v_devolucion_id bigint;
    v_documento_id  bigint;
    v_p             record;
    v_lote          record;
    v_total         numeric(14,2) := 0;
    v_movs          jsonb := '[]'::jsonb;
    v_costo_por_cta jsonb := '{}'::jsonb;
    v_cta_inv       bigint;
    v_cta_prov      bigint := public._cuenta_id('201.01');
    v_poliza        jsonb;
    v_poliza_id     bigint;
    v_stock_prod    numeric;
    v_key           text;
    v_costo         numeric;
begin
    if jsonb_array_length(v_partidas) = 0 then raise exception 'La devolución no tiene partidas.'; end if;
    if v_cta_prov is null then raise exception 'Falta la cuenta 201.01 (Proveedores) en el plan de cuentas.'; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    v_folio := 'DEVPROV-' || right((extract(epoch from clock_timestamp()) * 1000)::bigint::text, 6);

    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('devolucion_proveedor', v_folio, v_fecha, coalesce(nullif(trim(p_datos->>'notas'), ''), 'Devolución a proveedor'), 'completado')
    returning id into v_documento_id;

    insert into public.devoluciones_proveedor (folio, fecha, proveedor_id, documento_compra_id, documento_id, motivo, notas)
    values (v_folio, v_fecha, v_proveedor_id, (p_datos->>'documento_compra_id')::bigint, v_documento_id,
            nullif(trim(p_datos->>'motivo'), ''), nullif(trim(p_datos->>'notas'), ''))
    returning id into v_devolucion_id;

    for v_p in select * from jsonb_to_recordset(v_partidas) as x(
        producto_id bigint, lote_id bigint, cantidad numeric, unidad_medida_id bigint)
    loop
        if v_p.producto_id is null or v_p.lote_id is null or v_p.cantidad is null or v_p.cantidad <= 0 then
            raise exception 'Cada partida necesita producto, lote y cantidad mayor a 0.';
        end if;

        select * into v_lote from public.lotes_inventario where id = v_p.lote_id for update;
        if v_lote is null then raise exception 'El lote % no existe.', v_p.lote_id; end if;
        if v_lote.stock_actual < v_p.cantidad or v_lote.stock_costeo < v_p.cantidad then
            raise exception 'El lote % (%) no tiene suficiente stock para devolver % — disponible físico %, disponible costeo %.',
                v_lote.numero_lote, v_p.producto_id, v_p.cantidad, v_lote.stock_actual, v_lote.stock_costeo;
        end if;

        update public.lotes_inventario set stock_actual = stock_actual - v_p.cantidad, stock_costeo = stock_costeo - v_p.cantidad
         where id = v_p.lote_id;

        v_costo := coalesce(v_lote.costo_unitario_final, 0);

        insert into public.devoluciones_proveedor_detalle (devolucion_id, producto_id, lote_id, cantidad, costo_unitario, unidad_medida_id)
        values (v_devolucion_id, v_p.producto_id, v_p.lote_id, v_p.cantidad, v_costo, v_p.unidad_medida_id);

        select coalesce(stock_actual, 0) into v_stock_prod from public.productos where id = v_p.producto_id;
        update public.productos set stock_actual = greatest(0, v_stock_prod - v_p.cantidad) where id = v_p.producto_id;

        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        values (v_p.producto_id, 'devolucion_proveedor', -v_p.cantidad, v_stock_prod, greatest(0, v_stock_prod - v_p.cantidad), v_costo, v_documento_id);

        v_total := v_total + (v_p.cantidad * v_costo);

        select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.01')) into v_cta_inv
          from public.productos pr where pr.id = v_p.producto_id;
        v_key := v_cta_inv::text;
        v_costo_por_cta := jsonb_set(v_costo_por_cta, array[v_key],
            to_jsonb(coalesce((v_costo_por_cta->>v_key)::numeric, 0) + (v_p.cantidad * v_costo)));
    end loop;

    if v_total <= 0 then raise exception 'El importe de la devolución debe ser mayor a 0.'; end if;

    v_movs := v_movs || jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_prov, 'cargo', v_total, 'abono', 0, 'concepto', 'Devolución a proveedor ' || v_folio, 'proveedor_id', v_proveedor_id)
    );
    for v_key in select jsonb_object_keys(v_costo_por_cta) loop
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_key::bigint, 'cargo', 0, 'abono', (v_costo_por_cta->>v_key)::numeric,
                                'concepto', 'Devolución a proveedor ' || v_folio || ' — sale de inventario')
        );
    end loop;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Diario', 'concepto', 'Devolución a proveedor ' || v_folio,
        'origen', 'devolucion_proveedor', 'origen_tabla', 'devoluciones_proveedor', 'origen_id', v_devolucion_id,
        'movimientos', v_movs
    ));
    v_poliza_id := (v_poliza->>'poliza_id')::bigint;
    update public.devoluciones_proveedor set poliza_id = v_poliza_id where id = v_devolucion_id;

    return jsonb_build_object('devolucion_id', v_devolucion_id, 'documento_id', v_documento_id, 'poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

-- cancelar_devolucion_proveedor(p_id, p_motivo): revierte póliza + regresa el stock al lote original.
create or replace function public.cancelar_devolucion_proveedor(p_devolucion_id bigint, p_motivo text)
returns void
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
    v_dev record;
    v_d   record;
begin
    select * into v_dev from public.devoluciones_proveedor where id = p_devolucion_id;
    if v_dev is null then raise exception 'La devolución % no existe.', p_devolucion_id; end if;
    if v_dev.estatus <> 'registrada' then raise exception 'Esta devolución ya está "%".', v_dev.estatus; end if;

    for v_d in select * from public.devoluciones_proveedor_detalle where devolucion_id = p_devolucion_id loop
        update public.lotes_inventario set stock_actual = stock_actual + v_d.cantidad, stock_costeo = stock_costeo + v_d.cantidad
         where id = v_d.lote_id;
        update public.productos set stock_actual = stock_actual + v_d.cantidad where id = v_d.producto_id;
        insert into public.movimientos_inventario (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id)
        select v_d.producto_id, 'cancelacion_devolucion_proveedor', v_d.cantidad, stock_actual - v_d.cantidad, stock_actual, v_d.costo_unitario, v_dev.documento_id
          from public.productos where id = v_d.producto_id;
    end loop;

    if v_dev.poliza_id is not null then
        perform public.cancelar_poliza(v_dev.poliza_id, p_motivo);
    end if;
    update public.documentos set estado = 'cancelado' where id = v_dev.documento_id;
    update public.devoluciones_proveedor set estatus = 'cancelada' where id = p_devolucion_id;
end;
$$;

grant execute on function public.registrar_devolucion_proveedor(jsonb) to authenticated;
grant execute on function public.cancelar_devolucion_proveedor(bigint, text) to authenticated;

-- =====================================================================
--  3. Candado de cierre: devoluciones sin póliza (defensivo, aunque las
--     dos funciones de arriba siempre generan la póliza en la misma
--     transacción — por si algún día se capturan en dos pasos).
-- =====================================================================
create or replace function public._candados_cierre_periodo(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_desde    date := make_date(p_anio, p_mes, 1);
    v_hasta    date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
    v_candados jsonb := '[]'::jsonb;
    v_cant     integer;
    v_detalle  jsonb;
begin
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'documento_id', d.id, 'folio', d.folio, 'tipo', d.tipo_movimiento) order by d.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.documentos d
     where d.fecha_emision::date between v_desde and v_hasta
       and d.tipo_movimiento in ('entrada_compra', 'salida_venta', 'entrada_produccion', 'salida_produccion')
       and coalesce(d.estado, '') <> 'cancelado'
       and d.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'documentos_sin_poliza',
            'descripcion', v_cant || ' documento(s) de compra/venta/producción del periodo sin contabilizar (sin póliza).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'gasto_id', g.id, 'concepto', g.concepto) order by g.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.gastos g
     where g.fecha between v_desde and v_hasta
       and g.estatus <> 'cancelado'
       and g.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'gastos_sin_poliza',
            'descripcion', v_cant || ' gasto(s) del periodo sin contabilizar (sin póliza).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'nomina_id', n.id, 'periodo_inicio', n.periodo_inicio, 'periodo_fin', n.periodo_fin) order by n.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.nominas n
     where n.fecha_pago between v_desde and v_hasta
       and n.estatus = 'borrador';
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'nominas_borrador',
            'descripcion', v_cant || ' nómina(s) del periodo todavía en borrador (falta autorizar).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object('nomina_id', n.id) order by n.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.nominas n
     where n.fecha_pago between v_desde and v_hasta
       and n.estatus = 'registrada'
       and n.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'nominas_sin_poliza',
            'descripcion', v_cant || ' nómina(s) registrada(s) sin póliza asociada (revisar antes de cerrar).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'cobro_id', c.id, 'referencia', c.referencia) order by c.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.cobros_cliente c
     where c.fecha between v_desde and v_hasta
       and c.estatus <> 'cancelado'
       and c.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'cobros_sin_poliza',
            'descripcion', v_cant || ' cobro(s) a clientes del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'pago_id', p.id, 'referencia', p.referencia) order by p.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.pagos_proveedor p
     where p.fecha between v_desde and v_hasta
       and p.estatus <> 'cancelado'
       and p.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'pagos_sin_poliza',
            'descripcion', v_cant || ' pago(s) a proveedores del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'auditoria_id', a.id, 'nombre', a.nombre) order by a.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.auditorias_inventario a
     where a.fecha between v_desde and v_hasta
       and a.estatus = 'abierta';
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'auditorias_abiertas',
            'descripcion', v_cant || ' auditoría(s) de inventario del periodo sin cerrar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'poliza_id', s.poliza_id, 'diferencia', s.diferencia) order by s.poliza_id), '[]'::jsonb)
      into v_cant, v_detalle
      from (
          select pm.poliza_id, round(sum(pm.cargo) - sum(pm.abono), 2) as diferencia
            from public.poliza_movimientos pm
            join public.polizas p on p.id = pm.poliza_id
           where p.fecha between v_desde and v_hasta
             and p.estatus = 'contabilizada'
           group by pm.poliza_id
          having round(sum(pm.cargo) - sum(pm.abono), 2) <> 0
      ) s;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'polizas_descuadradas',
            'descripcion', v_cant || ' póliza(s) del periodo con cargos distintos a abonos. Revisar de inmediato.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object('devolucion_id', dc.id, 'folio', dc.folio) order by dc.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.devoluciones_cliente dc
     where dc.fecha between v_desde and v_hasta
       and dc.estatus <> 'cancelada'
       and dc.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'devoluciones_cliente_sin_poliza',
            'descripcion', v_cant || ' devolución(es) de cliente del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    select count(*), coalesce(jsonb_agg(jsonb_build_object('devolucion_id', dp.id, 'folio', dp.folio) order by dp.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.devoluciones_proveedor dp
     where dp.fecha between v_desde and v_hasta
       and dp.estatus <> 'cancelada'
       and dp.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'devoluciones_proveedor_sin_poliza',
            'descripcion', v_cant || ' devolución(es) a proveedor del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    return v_candados;
end;
$$;
revoke all     on function public._candados_cierre_periodo(integer, integer) from public;
grant  execute on function public._candados_cierre_periodo(integer, integer) to authenticated;

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select * from public.devoluciones_cliente order by created_at desc limit 20;
-- select * from public.devoluciones_proveedor order by created_at desc limit 20;
