-- =====================================================================
--  Nomenclatura de pólizas por serie (BAN/VAE/DIA/ING/CMP) + groundwork
--  de "visto bueno" ligado a un usuario real (quien solicitó la compra).
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-10-27_anticipo_proveedores.sql, sql/2026-09-19_
--  semiterminados_115_02.sql, sql/2026-10-13_pago_reclasifica_iva.sql,
--  sql/2026-09-14e_cuentas_por_cobrar.sql (todas ya corridas).
--
--  Decisiones ya tomadas con el usuario (ver CLAUDE.md "EN DISCUSIÓN"):
--  serie de 3 letras por quién EMITE la póliza, además del tipo SAT
--  (Ingreso/Egreso/Diario, que se sigue reportando igual que siempre):
--    BAN = pago por banco          VAE = pago en efectivo
--    ING = cobro a clientes        DIA = cancelación de cualquier póliza
--    CMP = consumo de materia prima al cerrar una orden de producción
--  Consecutivo POR AÑO (ej. BAN-2027-00001, se reinicia cada enero —
--  distinto al folio de documentos, que es continuo). Solo estos 5 flujos
--  llevan serie; compras, gastos, nómina, activos fijos, devoluciones y
--  prorrateo se quedan como "Diario #N" / "Egreso #N", sin tocarse.
--
--  "Visto bueno": sigue siendo informativo (no bloquea nada), pero ya NO
--  es texto libre — ordenes_compra.solicitante_empleado_id liga a un
--  empleado real; pagos_proveedor.visto_bueno_empleado_id/_at registran
--  quién y cuándo lo confirmó. Falta (consciente, no es de hoy): que
--  aparezca solo en el menú de Tareas de ESE empleado — por ahora se
--  marca a mano desde Pagos a proveedores.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Folio de póliza por serie, consecutivo POR AÑO (se reinicia cada
--    enero — distinto de contadores_folios, que es continuo).
-- ---------------------------------------------------------------------
create table if not exists public.contadores_folios_poliza (
    serie  text   not null,
    anio   int    not null,
    ultimo bigint not null default 0,
    primary key (serie, anio)
);

alter table public.contadores_folios_poliza enable row level security;
drop policy if exists solo_lectura on public.contadores_folios_poliza;
create policy solo_lectura on public.contadores_folios_poliza for select to authenticated using (true);
revoke all    on public.contadores_folios_poliza from anon, authenticated;
grant  select on public.contadores_folios_poliza to authenticated;

create or replace function public._siguiente_folio_poliza(p_serie text, p_fecha date)
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_serie text := upper(trim(coalesce(p_serie, '')));
    v_anio  int  := extract(year from coalesce(p_fecha, current_date))::int;
    v_n     bigint;
begin
    if v_serie = '' then return null; end if;
    if v_serie !~ '^[A-Z]{2,8}$' then
        raise exception 'Serie de poliza no valida: "%"', p_serie;
    end if;
    insert into public.contadores_folios_poliza (serie, anio, ultimo)
    values (v_serie, v_anio, 1)
    on conflict (serie, anio) do update set ultimo = public.contadores_folios_poliza.ultimo + 1
    returning ultimo into v_n;
    return v_serie || '-' || v_anio::text || '-' || lpad(v_n::text, 5, '0');
end;
$$;

revoke all     on function public._siguiente_folio_poliza(text, date) from public, anon;
grant  execute on function public._siguiente_folio_poliza(text, date) to authenticated;

alter table public.polizas add column if not exists folio_poliza text;
comment on column public.polizas.folio_poliza is
  'Serie propia por quién emite la póliza (BAN/VAE/ING/DIA/CMP), consecutivo por año. Null = sin serie (compras, gastos, nómina...), se sigue mostrando como "Tipo #número".';


-- ---------------------------------------------------------------------
-- 2. registrar_poliza(): gana p_datos->>'serie' opcional. Si viene,
--    asigna folio_poliza; si no, igual que siempre (null).
--    Copia exacta de la versión vigente (sql/2026-09-22_fix_hallazgos_
--    seguridad_contabilidad.sql) con solo esto agregado.
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
    v_serie     text := nullif(upper(trim(coalesce(p_datos->>'serie', ''))), '');
    v_folio_pol text;
begin
    if v_fecha is null then raise exception 'La fecha de la poliza es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto de la poliza es obligatorio.'; end if;
    if v_tipo not in ('Ingreso','Egreso','Diario') then raise exception 'Tipo de poliza invalido: %', v_tipo; end if;
    if jsonb_array_length(v_movs) < 2 then raise exception 'La poliza necesita al menos 2 movimientos.'; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        v_cargo := round(coalesce((r->>'cargo')::numeric, 0), 2);
        v_abono := round(coalesce((r->>'abono')::numeric, 0), 2);

        if v_cargo < 0 or v_abono < 0 then
            raise exception 'Renglon %: cargo y abono no pueden ser negativos. cargo=%, abono=%, movimiento=%', v_i, v_cargo, v_abono, r;
        end if;
        if (v_cargo > 0 and v_abono > 0) or (v_cargo = 0 and v_abono = 0) then
            raise exception 'Renglon %: pon importe en cargo O en abono (no ambos, no ninguno). cargo=%, abono=%, movimiento=%', v_i, v_cargo, v_abono, r;
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

    v_numero := public._siguiente_numero_poliza(v_tipo, v_fecha);
    if v_serie is not null then
        v_folio_pol := public._siguiente_folio_poliza(v_serie, v_fecha);
    end if;

    insert into public.polizas
        (fecha, tipo, numero, concepto, folio, origen, origen_tabla, origen_id, moneda_id, tipo_cambio, folio_poliza)
    values (
        v_fecha, v_tipo, v_numero, v_concepto,
        nullif(trim(p_datos->>'folio'), ''),
        coalesce(nullif(trim(p_datos->>'origen'), ''), 'manual'),
        nullif(trim(p_datos->>'origen_tabla'), ''),
        (p_datos->>'origen_id')::bigint,
        (p_datos->>'moneda_id')::bigint,
        coalesce((p_datos->>'tipo_cambio')::numeric, 1),
        v_folio_pol
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

    return jsonb_build_object('poliza_id', v_poliza_id, 'numero', v_numero, 'folio_poliza', v_folio_pol);
end;
$$;

revoke all     on function public.registrar_poliza(jsonb) from public;
grant  execute on function public.registrar_poliza(jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- 3. cancelar_poliza(): la cancelación SIEMPRE lleva serie DIA (no llama
--    a registrar_poliza, inserta directo — mismo patrón, solo se agrega
--    folio_poliza). Copia exacta de la vigente con ese único agregado.
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
    v_folio_pol text;
begin
    select * into v_orig from public.polizas where id = p_poliza_id;
    if not found then raise exception 'La poliza no existe.'; end if;
    if v_orig.estatus <> 'contabilizada' then
        raise exception 'Solo se puede cancelar una poliza contabilizada (estatus actual: %).', v_orig.estatus;
    end if;
    if v_orig.origen = 'ajuste' and v_orig.origen_tabla = 'polizas' then
        raise exception 'La poliza #% ya es un reverso (generado al cancelar la poliza #%). No se puede cancelar un reverso — revisa directamente la poliza original #% si necesitas deshacer esa cancelación.',
            v_orig.numero, v_orig.origen_id, v_orig.origen_id;
    end if;

    perform public._verificar_periodo_abierto(v_orig.fecha);
    perform public._verificar_periodo_abierto(current_date);

    v_numero := public._siguiente_numero_poliza(v_orig.tipo, current_date);
    v_folio_pol := public._siguiente_folio_poliza('DIA', current_date);

    insert into public.polizas
        (fecha, tipo, numero, concepto, origen, origen_tabla, origen_id, poliza_reversa_id, moneda_id, tipo_cambio, folio_poliza)
    values (
        current_date, v_orig.tipo, v_numero,
        'Cancelacion de poliza ' || v_orig.tipo || ' #' || v_orig.numero || coalesce(' - ' || p_motivo, ''),
        'ajuste', 'polizas', v_orig.id, v_orig.id, v_orig.moneda_id, v_orig.tipo_cambio, v_folio_pol
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

    return jsonb_build_object('poliza_reversa_id', v_rev_id, 'folio_poliza', v_folio_pol);
end;
$$;

revoke all     on function public.cancelar_poliza(bigint, text) from public;
grant  execute on function public.cancelar_poliza(bigint, text) to authenticated;


-- ---------------------------------------------------------------------
-- 4. Los 4 flujos que SÍ llevan serie: solo se agrega 'serie' al mismo
--    jsonb que ya le mandaban a registrar_poliza — nada más cambia.
-- ---------------------------------------------------------------------

-- 4a. pagar_anticipo_oc(): BAN si la cuenta es banco (102.x), VAE si es caja (101.x).
create or replace function public.pagar_anticipo_oc(p_oc_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_oc        public.ordenes_compra%rowtype;
    v_fecha     date := (p_datos->>'fecha')::date;
    v_cta_pago  bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_forma     text := nullif(trim(p_datos->>'forma_pago'), '');
    v_ref       text := nullif(trim(p_datos->>'referencia'), '');
    v_notas     text := nullif(trim(p_datos->>'notas'), '');
    v_monto     numeric(14,2) := round(coalesce((p_datos->>'monto')::numeric, 0), 2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_cta109    bigint;
    v_pago_id   bigint;
    v_poliza_id bigint;
    v_serie     text;
begin
    if v_fecha is null then raise exception 'La fecha del anticipo es obligatoria.'; end if;
    if v_monto <= 0 then raise exception 'El monto del anticipo debe ser mayor a cero.'; end if;

    select * into v_oc from public.ordenes_compra where id = p_oc_id;
    if not found then raise exception 'La orden de compra no existe.'; end if;
    if v_oc.estatus not in ('abierta', 'recibida_parcial') then
        raise exception 'Solo se puede pagar un anticipo a una orden de compra abierta o parcialmente recibida (estatus actual: %).', v_oc.estatus;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
    if not found then raise exception 'Selecciona la cuenta de caja / banco.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;
    v_serie := case when v_cuenta.codigo like '101%' then 'VAE' else 'BAN' end;

    v_cta109 := public._cuenta_id('109.01');
    if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores) en el plan de cuentas.'; end if;

    insert into public.pagos_proveedor (fecha, cuenta_pago_id, forma_pago, referencia, proveedor_id, total, notas)
    values (v_fecha, v_cta_pago, v_forma, v_ref, v_oc.proveedor_id, v_monto, v_notas)
    returning id into v_pago_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Egreso', 'serie', v_serie,
        'concepto', 'Anticipo a proveedor - OC ' || coalesce(v_oc.folio, '#' || p_oc_id) || coalesce(' - ' || v_ref, ''),
        'origen', 'pago', 'origen_tabla', 'pagos_proveedor', 'origen_id', v_pago_id,
        'movimientos', jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta109, 'cargo', v_monto,
                'concepto', 'Anticipo OC ' || coalesce(v_oc.folio, '#' || p_oc_id), 'proveedor_id', v_oc.proveedor_id),
            jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_monto,
                'concepto', 'Anticipo a proveedor' || coalesce(' - ' || v_ref, ''))
        )
    ))->>'poliza_id')::bigint;

    update public.pagos_proveedor set poliza_id = v_poliza_id where id = v_pago_id;

    insert into public.pagos_proveedor_aplicaciones (pago_id, tipo, orden_compra_id, monto)
    values (v_pago_id, 'anticipo_oc', p_oc_id, v_monto);

    return jsonb_build_object('pago_id', v_pago_id, 'poliza_id', v_poliza_id, 'total', v_monto);
end $$;

revoke all     on function public.pagar_anticipo_oc(bigint, jsonb) from public, anon;
grant  execute on function public.pagar_anticipo_oc(bigint, jsonb) to authenticated;


-- 4b. registrar_pago_proveedor(): mismo criterio BAN/VAE. Copia exacta de
--     la vigente (sql/2026-10-13_pago_reclasifica_iva.sql) + 'serie' +
--     visto bueno (p_datos->>'visto_bueno_empleado_id', opcional).
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
    v_cta118    bigint := public._cuenta_id('118.01');
    v_cta119    bigint := public._cuenta_id('119.01');
    r           jsonb;
    v_tipo      text;
    v_id        bigint;
    v_monto     numeric(14,2);
    v_saldo     numeric(14,2);
    v_prov      bigint;
    v_folio     text;
    v_iva_doc   numeric(14,2);
    v_total_doc numeric(14,2);
    v_iva_prop  numeric(14,2);
    d           public.documentos%rowtype;
    g           public.gastos%rowtype;
    v_serie     text;
    v_visto     bigint := (p_datos->>'visto_bueno_empleado_id')::bigint;
begin
    if v_fecha is null then raise exception 'La fecha del pago es obligatoria.'; end if;
    if jsonb_array_length(v_apps) < 1 then raise exception 'Selecciona al menos un documento a pagar.'; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
    if not found then raise exception 'Selecciona la cuenta de caja / banco.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;
    v_serie := case when v_cuenta.codigo like '101%' then 'VAE' else 'BAN' end;

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
            v_iva_doc := coalesce(d.iva, 0);
            v_total_doc := coalesce(d.total, 0);
        elsif v_tipo = 'gasto' then
            select * into g from public.gastos where id = v_id;
            if not found then raise exception 'El gasto #% no existe.', v_id; end if;
            if g.estatus <> 'registrado' then raise exception 'El gasto % esta %.', v_id, g.estatus; end if;
            if g.condicion <> 'credito' then raise exception 'El gasto % no es a credito.', v_id; end if;
            v_saldo := round(coalesce(g.total, 0) - coalesce(g.total_pagado, 0), 2);
            v_prov  := g.proveedor_id;
            v_folio := coalesce(g.folio_factura, g.concepto);
            v_iva_doc := coalesce(g.iva, 0);
            v_total_doc := coalesce(g.total, 0);
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

        if v_iva_doc > 0 and v_total_doc > 0 then
            v_iva_prop := round(v_iva_doc * v_monto / v_total_doc, 2);
            if v_iva_prop > 0 then
                if v_cta118 is null then raise exception 'Falta la cuenta 118.01 (IVA acreditable pagado) en el plan de cuentas.'; end if;
                if v_cta119 is null then raise exception 'Falta la cuenta 119.01 (IVA acreditable pendiente de pago) en el plan de cuentas.'; end if;
                v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta118, 'cargo', v_iva_prop,
                            'concepto', 'IVA pagado ' || v_tipo || ' ' || v_folio);
                v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta119, 'abono', v_iva_prop,
                            'concepto', 'Reclasifica IVA pendiente ' || v_tipo || ' ' || v_folio);
            end if;
        end if;
    end loop;

    v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total,
                'concepto', 'Pago a proveedores' || coalesce(' - ' || v_ref, ''));

    insert into public.pagos_proveedor (fecha, cuenta_pago_id, forma_pago, referencia, proveedor_id, total, notas,
                                         visto_bueno_empleado_id, visto_bueno_at)
    values (v_fecha, v_cta_pago, v_forma, v_ref, v_prov_ok, v_total, v_notas,
            v_visto, case when v_visto is not null then now() else null end)
    returning id into v_pago_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Egreso', 'serie', v_serie,
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


-- 4c. registrar_cobro_cliente(): siempre serie ING (es Ingreso). Copia
--     exacta de la vigente (sql/2026-09-14e_cuentas_por_cobrar.sql) + 'serie'.
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
        'fecha', v_fecha, 'tipo', 'Ingreso', 'serie', 'ING',
        'concepto', 'Cobro a clientes' || coalesce(' - ' || v_ref, ''),
        'origen', 'cobro', 'origen_tabla', 'cobros_cliente', 'origen_id', v_cobro_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.cobros_cliente set poliza_id = v_poliza_id where id = v_cobro_id;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_id := (r->>'id')::bigint;
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        insert into public.cobros_cliente_aplicaciones (cobro_id, documento_id, monto)
        values (v_cobro_id, v_id, v_monto);
        update public.documentos set total_cobrado = round(coalesce(total_cobrado, 0) + v_monto, 2) where id = v_id;
    end loop;

    return jsonb_build_object('cobro_id', v_cobro_id, 'poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

revoke all     on function public.registrar_cobro_cliente(jsonb) from public, anon;
grant  execute on function public.registrar_cobro_cliente(jsonb) to authenticated;


-- 4d. contabilizar_produccion(): siempre serie CMP. Mismo patch que los
--     anteriores — se busca 'tipo', 'Diario' dentro de su llamado a
--     registrar_poliza y se agrega 'serie', 'CMP' justo ahí (parche de
--     texto, sin reescribir toda la función — es larga y no cambia nada más).
do $$
declare
    r     record;
    v_def text;
    v_old constant text := $a$'tipo', 'Diario',
        'concepto', 'Produccion ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, '')$a$;
    v_new constant text := $b$'tipo', 'Diario', 'serie', 'CMP',
        'concepto', 'Produccion ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, '')$b$;
begin
    for r in
        select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'contabilizar_produccion'
    loop
        v_def := pg_get_functiondef(r.oid);
        if position(v_old in v_def) = 0 then
            raise notice 'contabilizar_produccion: ya tiene serie CMP (o el texto cambió) — no se toca.';
        else
            execute replace(v_def, v_old, v_new);
            raise notice 'contabilizar_produccion: serie CMP aplicada.';
        end if;
    end loop;
end $$;


-- ---------------------------------------------------------------------
-- 5. Visto bueno ligado a un usuario real (groundwork, informativo):
--    quién solicitó la OC (empleado real, no texto libre) y quién dio
--    el visto bueno al pago, y cuándo.
-- ---------------------------------------------------------------------
alter table public.ordenes_compra add column if not exists solicitante_empleado_id bigint references public.empleados (id);
comment on column public.ordenes_compra.solicitante_empleado_id is
  'Empleado que solicitó esta compra. Informativo — no bloquea nada. Fuente del "visto bueno" al pagar.';

alter table public.pagos_proveedor add column if not exists visto_bueno_empleado_id bigint references public.empleados (id);
alter table public.pagos_proveedor add column if not exists visto_bueno_at timestamptz;
comment on column public.pagos_proveedor.visto_bueno_empleado_id is
  'Quién confirmó el visto bueno de este pago (informativo, no bloquea). Pendiente: que llegue por el menú de Tareas de ese empleado en vez de marcarse a mano aquí.';

commit;

-- =====================================================================
--  Para revisar después de correrla:
--   select * from public.contadores_folios_poliza order by serie, anio;
--   select folio_poliza, tipo, numero from public.polizas where folio_poliza is not null order by id desc limit 10;
-- =====================================================================
