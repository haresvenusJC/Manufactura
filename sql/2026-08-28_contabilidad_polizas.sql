-- =====================================================================
--  Contabilidad - FASE 2: Polizas (asientos de partida doble)
--  Fecha: 2026-08-28   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes: sql/2026-08-28_contabilidad_cuentas.sql
--
--  Crea:
--   - polizas               (encabezado del asiento)
--   - poliza_movimientos    (renglones: cargo / abono)
--   - RPC registrar_poliza  (valida que cuadre y las cuentas antes de guardar)
--   - RPC cancelar_poliza   (genera poliza de reverso y marca la original)
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.polizas (
    id                bigint generated always as identity primary key,
    fecha             date    not null,
    tipo              text    not null default 'Diario' check (tipo in ('Ingreso','Egreso','Diario')),
    numero            integer not null default 0,          -- consecutivo por (tipo, año); lo asigna el RPC
    concepto          text    not null,
    folio             text,
    estatus           text    not null default 'contabilizada'
                        check (estatus in ('borrador','contabilizada','cancelada')),
    origen            text    not null default 'manual'
                        check (origen in ('manual','gasto','compra','venta','nomina','ajuste')),
    origen_tabla      text,
    origen_id         bigint,
    poliza_reversa_id bigint  references public.polizas(id) on delete set null,
    moneda_id         bigint  references public.monedas(id),
    tipo_cambio       numeric(14,6) not null default 1,
    creado_por        uuid    default auth.uid(),
    created_at        timestamptz not null default now()
);
create index if not exists idx_polizas_fecha  on public.polizas(fecha);
create index if not exists idx_polizas_origen on public.polizas(origen_tabla, origen_id);

create table if not exists public.poliza_movimientos (
    id             bigint generated always as identity primary key,
    poliza_id      bigint not null references public.polizas(id) on delete cascade,
    orden          smallint not null default 1,
    cuenta_id      bigint not null references public.cuentas_contables(id) on delete restrict,
    cargo          numeric(14,2) not null default 0 check (cargo >= 0),
    abono          numeric(14,2) not null default 0 check (abono >= 0),
    concepto       text,
    proveedor_id   bigint references public.proveedores(id) on delete set null,
    cliente_id     bigint,
    tercero_rfc    text,
    tercero_nombre text,
    uuid_cfdi      text,          -- folio fiscal del CFDI (nodo CompNal del XML de polizas SAT)
    forma_pago     text,
    metodo_pago    text,
    constraint chk_un_solo_lado check ( (cargo > 0 and abono = 0) or (abono > 0 and cargo = 0) )
);
create index if not exists idx_polmov_poliza on public.poliza_movimientos(poliza_id);
create index if not exists idx_polmov_cuenta on public.poliza_movimientos(cuenta_id);

alter table public.polizas            enable row level security;
alter table public.poliza_movimientos enable row level security;
drop policy if exists admin_all on public.polizas;
create policy admin_all on public.polizas            for all to authenticated using (true) with check (true);
drop policy if exists admin_all on public.poliza_movimientos;
create policy admin_all on public.poliza_movimientos for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- registrar_poliza(p_datos jsonb) -> { poliza_id, numero }
--   p_datos: { fecha, tipo, concepto, folio, origen, origen_tabla,
--              origen_id, moneda_id, tipo_cambio,
--              movimientos: [ { cuenta_id, cargo, abono, concepto,
--                proveedor_id, cliente_id, tercero_rfc, tercero_nombre,
--                uuid_cfdi, forma_pago, metodo_pago } ] }
-- ---------------------------------------------------------------------
create or replace function public.registrar_poliza(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_fecha     date := (p_datos->>'fecha')::date;
    v_tipo      text := coalesce(nullif(trim(p_datos->>'tipo'), ''), 'Diario');
    v_concepto  text := nullif(trim(p_datos->>'concepto'), '');
    v_movs      jsonb := coalesce(p_datos->'movimientos', '[]'::jsonb);
    v_sum_cargo numeric(14,2) := 0;
    v_sum_abono numeric(14,2) := 0;
    v_numero    int;
    v_poliza_id bigint;
    v_cargo     numeric(14,2);
    v_abono     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_i         int := 0;
    r           jsonb;
begin
    if v_fecha is null then raise exception 'La fecha de la poliza es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto de la poliza es obligatorio.'; end if;
    if v_tipo not in ('Ingreso','Egreso','Diario') then raise exception 'Tipo de poliza invalido: %', v_tipo; end if;
    if jsonb_array_length(v_movs) < 2 then raise exception 'La poliza necesita al menos 2 movimientos.'; end if;

    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        v_cargo := round(coalesce((r->>'cargo')::numeric, 0), 2);
        v_abono := round(coalesce((r->>'abono')::numeric, 0), 2);

        if v_cargo < 0 or v_abono < 0 then
            raise exception 'Renglon %: cargo y abono no pueden ser negativos.', v_i;
        end if;
        if (v_cargo > 0 and v_abono > 0) or (v_cargo = 0 and v_abono = 0) then
            raise exception 'Renglon %: pon importe en cargo O en abono (no ambos, no ninguno).', v_i;
        end if;

        select * into v_cuenta from public.cuentas_contables where id = (r->>'cuenta_id')::bigint;
        if not found then raise exception 'Renglon %: la cuenta indicada no existe.', v_i; end if;
        if not v_cuenta.afectable then
            raise exception 'Renglon %: la cuenta % (%) es de mayor y no acepta movimientos.', v_i, v_cuenta.codigo, v_cuenta.nombre;
        end if;
        if not v_cuenta.activa then
            raise exception 'Renglon %: la cuenta % esta inactiva.', v_i, v_cuenta.codigo;
        end if;

        v_sum_cargo := v_sum_cargo + v_cargo;
        v_sum_abono := v_sum_abono + v_abono;
    end loop;

    if v_sum_cargo <> v_sum_abono then
        raise exception 'La poliza no cuadra: cargos %  vs  abonos %.', v_sum_cargo, v_sum_abono;
    end if;
    if v_sum_cargo = 0 then
        raise exception 'La poliza no puede sumar cero.';
    end if;

    select coalesce(max(numero), 0) + 1 into v_numero
    from public.polizas
    where tipo = v_tipo and extract(year from fecha) = extract(year from v_fecha);

    insert into public.polizas
        (fecha, tipo, numero, concepto, folio, origen, origen_tabla, origen_id, moneda_id, tipo_cambio)
    values (
        v_fecha, v_tipo, v_numero, v_concepto,
        nullif(trim(p_datos->>'folio'), ''),
        coalesce(nullif(trim(p_datos->>'origen'), ''), 'manual'),
        nullif(trim(p_datos->>'origen_tabla'), ''),
        (p_datos->>'origen_id')::bigint,
        (p_datos->>'moneda_id')::bigint,
        coalesce((p_datos->>'tipo_cambio')::numeric, 1)
    )
    returning id into v_poliza_id;

    v_i := 0;
    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        insert into public.poliza_movimientos
            (poliza_id, orden, cuenta_id, cargo, abono, concepto, proveedor_id, cliente_id,
             tercero_rfc, tercero_nombre, uuid_cfdi, forma_pago, metodo_pago)
        values (
            v_poliza_id, v_i, (r->>'cuenta_id')::bigint,
            round(coalesce((r->>'cargo')::numeric, 0), 2),
            round(coalesce((r->>'abono')::numeric, 0), 2),
            nullif(trim(r->>'concepto'), ''),
            (r->>'proveedor_id')::bigint,
            (r->>'cliente_id')::bigint,
            nullif(trim(r->>'tercero_rfc'), ''),
            nullif(trim(r->>'tercero_nombre'), ''),
            nullif(trim(r->>'uuid_cfdi'), ''),
            nullif(trim(r->>'forma_pago'), ''),
            nullif(trim(r->>'metodo_pago'), '')
        );
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'numero', v_numero);
end;
$$;

revoke all     on function public.registrar_poliza(jsonb) from public;
grant  execute on function public.registrar_poliza(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- cancelar_poliza(p_poliza_id, p_motivo) -> { poliza_reversa_id }
--   Genera una poliza con los cargos/abonos invertidos y marca la
--   original como 'cancelada'. Solo aplica a polizas 'contabilizada'.
-- ---------------------------------------------------------------------
create or replace function public.cancelar_poliza(p_poliza_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_orig   public.polizas%rowtype;
    v_numero int;
    v_rev_id bigint;
    v_i      int := 0;
    m        public.poliza_movimientos%rowtype;
begin
    select * into v_orig from public.polizas where id = p_poliza_id;
    if not found then raise exception 'La poliza no existe.'; end if;
    if v_orig.estatus <> 'contabilizada' then
        raise exception 'Solo se puede cancelar una poliza contabilizada (estatus actual: %).', v_orig.estatus;
    end if;

    select coalesce(max(numero), 0) + 1 into v_numero
    from public.polizas
    where tipo = v_orig.tipo and extract(year from fecha) = extract(year from current_date);

    insert into public.polizas
        (fecha, tipo, numero, concepto, origen, origen_tabla, origen_id, poliza_reversa_id, moneda_id, tipo_cambio)
    values (
        current_date, v_orig.tipo, v_numero,
        'Cancelacion de poliza ' || v_orig.tipo || ' #' || v_orig.numero || coalesce(' - ' || p_motivo, ''),
        'ajuste', 'polizas', v_orig.id, v_orig.id, v_orig.moneda_id, v_orig.tipo_cambio
    )
    returning id into v_rev_id;

    for m in select * from public.poliza_movimientos where poliza_id = v_orig.id order by orden
    loop
        v_i := v_i + 1;
        insert into public.poliza_movimientos (poliza_id, orden, cuenta_id, cargo, abono, concepto, proveedor_id, cliente_id)
        values (v_rev_id, v_i, m.cuenta_id, m.abono, m.cargo,           -- invertido
                'Reverso: ' || coalesce(m.concepto, ''), m.proveedor_id, m.cliente_id);
    end loop;

    update public.polizas set estatus = 'cancelada' where id = v_orig.id;

    return jsonb_build_object('poliza_reversa_id', v_rev_id);
end;
$$;

revoke all     on function public.cancelar_poliza(bigint, text) from public;
grant  execute on function public.cancelar_poliza(bigint, text) to authenticated;

commit;
