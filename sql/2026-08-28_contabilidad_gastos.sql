-- =====================================================================
--  Contabilidad - FASE 3: Gastos
--  Fecha: 2026-08-28   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-28_contabilidad_cuentas.sql
--    sql/2026-08-28_contabilidad_polizas.sql
--
--  Crea:
--   - gastos                 (documento fuente: factura de proveedor sin inventario)
--   - _cuenta_id(codigo)     (helper: id de cuenta por codigo)
--   - RPC registrar_gasto    (inserta el gasto y postea su poliza de Egreso)
--   - RPC cancelar_gasto     (cancela la poliza y marca el gasto)
--
--  La poliza que genera un gasto (contado):
--    Cargo  <cuenta de gasto>          subtotal
--    Cargo  118.01 IVA acred. pagado   iva
--    Cargo  118.03 IEPS acred. pagado  ieps
--    Abono  216.05 IVA retenido        ret_iva
--    Abono  216.10 ISR retenido        ret_isr
--    Abono  <caja / banco>             total
--  (a credito: el IVA va a 119.01 y el neto se abona a 201.01 Proveedores)
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.gastos (
    id              bigint generated always as identity primary key,
    fecha           date    not null,
    concepto        text    not null,
    proveedor_id    bigint  references public.proveedores(id) on delete set null,
    cuenta_gasto_id bigint  not null references public.cuentas_contables(id) on delete restrict,
    subtotal        numeric(14,2) not null check (subtotal >= 0),
    iva             numeric(14,2) not null default 0 check (iva >= 0),
    ieps            numeric(14,2) not null default 0 check (ieps >= 0),
    ret_iva         numeric(14,2) not null default 0 check (ret_iva >= 0),
    ret_isr         numeric(14,2) not null default 0 check (ret_isr >= 0),
    total           numeric(14,2) not null check (total >= 0),
    condicion       text    not null default 'contado' check (condicion in ('contado','credito')),
    forma_pago      text,
    cuenta_pago_id  bigint  references public.cuentas_contables(id) on delete restrict,
    folio_factura   text,
    uuid_cfdi       text,
    rfc_emisor      text,
    documento_id    bigint  references public.documentos(id) on delete set null,
    notas           text,
    poliza_id       bigint  references public.polizas(id) on delete set null,
    estatus         text    not null default 'registrado' check (estatus in ('registrado','cancelado')),
    creado_por      uuid    default auth.uid(),
    created_at      timestamptz not null default now()
);
create index if not exists idx_gastos_fecha     on public.gastos(fecha);
create index if not exists idx_gastos_proveedor on public.gastos(proveedor_id);

alter table public.gastos enable row level security;
drop policy if exists admin_all on public.gastos;
create policy admin_all on public.gastos for all to authenticated using (true) with check (true);

-- helper -------------------------------------------------------------
create or replace function public._cuenta_id(p_codigo text)
returns bigint
language sql stable
set search_path = public
as $$
    select id from public.cuentas_contables where codigo = p_codigo and activa limit 1;
$$;

-- ---------------------------------------------------------------------
-- registrar_gasto(p_datos jsonb) -> { gasto_id, poliza_id, total }
--   p_datos: { fecha, concepto, proveedor_id, cuenta_gasto_id,
--              subtotal, iva, ieps, ret_iva, ret_isr,
--              condicion ('contado'|'credito'), forma_pago,
--              cuenta_pago_id, folio_factura, uuid_cfdi, rfc_emisor,
--              documento_id, notas }
-- ---------------------------------------------------------------------
create or replace function public.registrar_gasto(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_fecha     date          := (p_datos->>'fecha')::date;
    v_concepto  text          := nullif(trim(p_datos->>'concepto'), '');
    v_prov      bigint        := (p_datos->>'proveedor_id')::bigint;
    v_cta_gasto bigint        := (p_datos->>'cuenta_gasto_id')::bigint;
    v_subtotal  numeric(14,2) := round(coalesce((p_datos->>'subtotal')::numeric, 0), 2);
    v_iva       numeric(14,2) := round(coalesce((p_datos->>'iva')::numeric, 0), 2);
    v_ieps      numeric(14,2) := round(coalesce((p_datos->>'ieps')::numeric, 0), 2);
    v_ret_iva   numeric(14,2) := round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2);
    v_ret_isr   numeric(14,2) := round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2);
    v_condicion text          := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'contado');
    v_cta_pago  bigint        := (p_datos->>'cuenta_pago_id')::bigint;
    v_total     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_movs      jsonb;
    v_gasto_id  bigint;
    v_poliza_id bigint;
    v_id        bigint;
begin
    if v_fecha is null then raise exception 'La fecha del gasto es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto del gasto es obligatorio.'; end if;
    if v_subtotal <= 0 then raise exception 'El subtotal debe ser mayor a cero.'; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_gasto;
    if not found then raise exception 'La cuenta de gasto no existe.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de gasto % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;
    if v_cuenta.tipo not in ('gasto','costo') then
        raise exception 'La cuenta % no es de gasto ni de costo.', v_cuenta.codigo;
    end if;

    v_total := round(v_subtotal + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden ser mayores que subtotal + impuestos.'; end if;

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco de la que sale el pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- armar movimientos de la poliza (Egreso) ----
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_gasto, 'cargo', v_subtotal, 'concepto', v_concepto)
    );

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta % (IVA acreditable).',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva, 'concepto', 'IVA acreditable');
    end if;

    if v_ieps > 0 then
        v_id := public._cuenta_id('118.03');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 118.03 (IEPS acreditable).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_ieps, 'concepto', 'IEPS acreditable');
    end if;

    if v_ret_iva > 0 then
        v_id := public._cuenta_id('216.05');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.05 (IVA retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_iva, 'concepto', 'IVA retenido');
    end if;

    if v_ret_isr > 0 then
        v_id := public._cuenta_id('216.10');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.10 (ISR retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_isr, 'concepto', 'ISR retenido');
    end if;

    if v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total, 'concepto', 'Pago ' || v_concepto);
    else
        v_id := public._cuenta_id('201.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 201.01 (Proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_total, 'concepto', 'Por pagar ' || v_concepto, 'proveedor_id', v_prov);
    end if;

    -- ---- insertar el gasto (sin poliza todavia) ----
    insert into public.gastos
        (fecha, concepto, proveedor_id, cuenta_gasto_id, subtotal, iva, ieps, ret_iva, ret_isr, total,
         condicion, forma_pago, cuenta_pago_id, folio_factura, uuid_cfdi, rfc_emisor, documento_id, notas)
    values (
        v_fecha, v_concepto, v_prov, v_cta_gasto, v_subtotal, v_iva, v_ieps, v_ret_iva, v_ret_isr, v_total,
        v_condicion,
        nullif(trim(p_datos->>'forma_pago'), ''),
        case when v_condicion = 'contado' then v_cta_pago else null end,
        nullif(trim(p_datos->>'folio_factura'), ''),
        nullif(trim(p_datos->>'uuid_cfdi'), ''),
        nullif(trim(p_datos->>'rfc_emisor'), ''),
        (p_datos->>'documento_id')::bigint,
        nullif(trim(p_datos->>'notas'), '')
    )
    returning id into v_gasto_id;

    -- ---- postear la poliza (reusa la validacion de cuadre) ----
    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha,
        'tipo', 'Egreso',
        'concepto', v_concepto,
        'origen', 'gasto',
        'origen_tabla', 'gastos',
        'origen_id', v_gasto_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.gastos set poliza_id = v_poliza_id where id = v_gasto_id;

    return jsonb_build_object('gasto_id', v_gasto_id, 'poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

revoke all     on function public.registrar_gasto(jsonb) from public;
grant  execute on function public.registrar_gasto(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- cancelar_gasto(p_gasto_id) -> { poliza_reversa_id }
-- ---------------------------------------------------------------------
create or replace function public.cancelar_gasto(p_gasto_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_gasto public.gastos%rowtype;
    v_res   jsonb := '{}'::jsonb;
begin
    select * into v_gasto from public.gastos where id = p_gasto_id;
    if not found then raise exception 'El gasto no existe.'; end if;
    if v_gasto.estatus <> 'registrado' then
        raise exception 'El gasto ya esta %.', v_gasto.estatus;
    end if;

    if v_gasto.poliza_id is not null then
        v_res := public.cancelar_poliza(v_gasto.poliza_id, 'Cancelacion de gasto #' || v_gasto.id);
    end if;

    update public.gastos set estatus = 'cancelado' where id = p_gasto_id;
    return v_res;
end;
$$;

revoke all     on function public.cancelar_gasto(bigint) from public;
grant  execute on function public.cancelar_gasto(bigint) to authenticated;

commit;
