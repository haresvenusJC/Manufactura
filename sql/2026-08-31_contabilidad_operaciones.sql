-- =====================================================================
--  Contabilidad - FASE 6: pólizas de operaciones de inventario
--  Fecha: 2026-08-31   Proyecto: Hares de Mexico (Supabase)
--
--  Se pega y corre a mano en:  Supabase -> SQL Editor
--  Requiere (en este orden) los SQL de contabilidad de fases 1-4:
--    2026-08-28_contabilidad_cuentas / _polizas / _gastos /
--    _productos_campos / _compras   (por registrar_poliza y _cuenta_id)
--
--  Agrega columnas de venta a documentos y 4 RPC que postean pólizas:
--    - contabilizar_salida            (salida / merma / ajuste)
--    - contabilizar_entrada_directa   (entrada directa sin factura)
--    - contabilizar_produccion        (cierre de orden de producción)
--    - contabilizar_venta             (salida por venta: ingreso + costo)
--
--  Todas reparten el importe por la cuenta de inventario de cada
--  producto (productos.cuenta_inventario_id, default 115.01) y reusan
--  registrar_poliza, que valida el cuadre. Idempotente.
-- =====================================================================

begin;

-- Amplia los origenes permitidos de una poliza (quita cualquier CHECK
-- previo sobre polizas.origen, sin importar su nombre).
do $$
declare r record;
begin
    for r in
        select con.conname
        from pg_constraint con
        join pg_class c on c.oid = con.conrelid
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public' and c.relname = 'polizas' and con.contype = 'c'
          and pg_get_constraintdef(con.oid) ilike '%origen%'
    loop
        execute format('alter table public.polizas drop constraint %I', r.conname);
    end loop;
end $$;
alter table public.polizas add constraint polizas_origen_check
    check (origen in ('manual','gasto','compra','venta','nomina','ajuste','salida','entrada','produccion'));

alter table public.documentos
    add column if not exists cliente_nombre  text,
    add column if not exists cliente_rfc     text,
    add column if not exists venta_subtotal  numeric(14,2),
    add column if not exists venta_iva       numeric(14,2),
    add column if not exists venta_total     numeric(14,2);

-- ---------------------------------------------------------------------
-- Helper interno: renglones de inventario (uno por cuenta) para un
-- documento, a partir de documento_detalles.subtotal (que trae el costo).
-- Devuelve jsonb array de { cuenta_id, monto }.
-- ---------------------------------------------------------------------
create or replace function public._inv_por_cuenta(p_documento_id bigint)
returns jsonb
language sql stable
set search_path = public
as $$
    select coalesce(jsonb_agg(jsonb_build_object('cuenta_id', cta_id, 'monto', monto)), '[]'::jsonb)
    from (
        select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.01')) as cta_id,
               round(sum(dd.subtotal), 2) as monto
        from public.documento_detalles dd
        left join public.productos pr on pr.id = dd.producto_id
        where dd.documento_id = p_documento_id
        group by coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.01'))
    ) t
$$;

-- =====================================================================
-- contabilizar_salida(p_documento_id, p_datos) -> { poliza_id, total }
--   Salida / merma / ajuste (sin ingreso).
--   p_datos: { cuenta_cargo_id }  (a donde va el costo: 501.01, 601.xx, ...)
--   Poliza Diario:  Cargo <cuenta_cargo_id>  total
--                   Abono 115.xx inventario  (por cuenta de cada producto)
-- =====================================================================
create or replace function public.contabilizar_salida(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc     public.documentos%rowtype;
    v_cargo   bigint := (p_datos->>'cuenta_cargo_id')::bigint;
    v_inv     jsonb  := public._inv_por_cuenta(p_documento_id);
    v_total   numeric(14,2) := 0;
    v_movs    jsonb  := '[]'::jsonb;
    v_cuenta  public.cuentas_contables%rowtype;
    r         jsonb;
    v_pid     bigint;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Este documento ya esta contabilizado (poliza %).', v_doc.poliza_id; end if;
    if v_doc.tipo_movimiento not in ('salida','merma','ajuste') then
        raise exception 'contabilizar_salida solo aplica a salida / merma / ajuste (tipo actual: %).', v_doc.tipo_movimiento;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cargo;
    if not found then raise exception 'Selecciona la cuenta destino del costo (cargo).'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    for r in select * from jsonb_array_elements(v_inv)
    loop
        v_total := v_total + (r->>'monto')::numeric;
        v_movs  := v_movs || jsonb_build_object('cuenta_id', (r->>'cuenta_id')::bigint, 'abono', (r->>'monto')::numeric, 'concepto', 'Salida inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_total <= 0 then raise exception 'La salida no tiene costo (revisa los costos de las partidas).'; end if;

    v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cargo, 'cargo', v_total, 'concepto',
        coalesce(v_doc.descripcion, 'Salida') || ' ' || coalesce(v_doc.folio, ''))) || v_movs;

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Diario',
        'concepto', initcap(v_doc.tipo_movimiento) || ' ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, ''),
        'folio', v_doc.folio,
        'origen', 'salida',
        'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos set poliza_id = v_pid, total = v_total where id = p_documento_id;
    return jsonb_build_object('poliza_id', v_pid, 'total', v_total);
end;
$$;

-- =====================================================================
-- contabilizar_entrada_directa(p_documento_id, p_datos) -> { poliza_id, total }
--   p_datos: { cuenta_abono_id }  (contrapartida: 205.01, ajuste, capital...)
--   Poliza Diario:  Cargo 115.xx inventario (por producto)
--                   Abono <cuenta_abono_id>  total
-- =====================================================================
create or replace function public.contabilizar_entrada_directa(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc     public.documentos%rowtype;
    v_abono   bigint := (p_datos->>'cuenta_abono_id')::bigint;
    v_inv     jsonb  := public._inv_por_cuenta(p_documento_id);
    v_total   numeric(14,2) := 0;
    v_movs    jsonb  := '[]'::jsonb;
    v_cuenta  public.cuentas_contables%rowtype;
    r         jsonb;
    v_pid     bigint;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Este documento ya esta contabilizado (poliza %).', v_doc.poliza_id; end if;
    if v_doc.tipo_movimiento <> 'entrada' then
        raise exception 'contabilizar_entrada_directa solo aplica a entradas directas (tipo actual: %).', v_doc.tipo_movimiento;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_abono;
    if not found then raise exception 'Selecciona la cuenta de contrapartida (abono).'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    for r in select * from jsonb_array_elements(v_inv)
    loop
        v_total := v_total + (r->>'monto')::numeric;
        v_movs  := v_movs || jsonb_build_object('cuenta_id', (r->>'cuenta_id')::bigint, 'cargo', (r->>'monto')::numeric, 'concepto', 'Entrada inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_total <= 0 then raise exception 'La entrada no tiene costo (revisa los costos de las partidas).'; end if;

    v_movs := v_movs || jsonb_build_object('cuenta_id', v_abono, 'abono', v_total, 'concepto',
        coalesce(v_doc.descripcion, 'Entrada directa') || ' ' || coalesce(v_doc.folio, ''));

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Diario',
        'concepto', 'Entrada directa ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, ''),
        'folio', v_doc.folio,
        'origen', 'entrada', 'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos set poliza_id = v_pid, total = v_total where id = p_documento_id;
    return jsonb_build_object('poliza_id', v_pid, 'total', v_total);
end;
$$;

-- =====================================================================
-- contabilizar_produccion(p_documento_id, p_datos) -> { poliza_id, total }
--   p_datos: { costo_materiales, costo_mano_obra }
--   El documento (tipo entrada_produccion) trae en documento_detalles el
--   producto terminado con subtotal = costo total. La MP consumida ya se
--   descontó por FIFO con el mismo documento_id.
--   Poliza Diario:
--     Cargo 115.04 (o cuenta_inventario_id del PT)   materiales + mano de obra
--     Abono 115.01 (MP)                               materiales
--     Abono 601.01 (mano de obra aplicada)           mano de obra
-- =====================================================================
create or replace function public.contabilizar_produccion(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc    public.documentos%rowtype;
    v_mat    numeric(14,2) := round(coalesce((p_datos->>'costo_materiales')::numeric, 0), 2);
    v_mo     numeric(14,2) := round(coalesce((p_datos->>'costo_mano_obra')::numeric, 0), 2);
    v_total  numeric(14,2);
    v_cta_pt bigint;
    v_cta_mp bigint := public._cuenta_id('115.01');
    v_cta_mo bigint := public._cuenta_id('601.01');
    v_movs   jsonb  := '[]'::jsonb;
    v_pid    bigint;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de produccion no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta produccion ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;

    v_total := round(v_mat + v_mo, 2);
    if v_total <= 0 then raise exception 'La produccion no tiene costo (materiales + mano de obra = 0).'; end if;

    select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.04')) into v_cta_pt
    from public.documento_detalles dd
    left join public.productos pr on pr.id = dd.producto_id
    where dd.documento_id = p_documento_id
    limit 1;
    if v_cta_pt is null then raise exception 'Falta la cuenta 115.04 (Productos terminados) en el plan de cuentas.'; end if;

    v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_pt, 'cargo', v_total, 'concepto', 'Producto terminado ' || coalesce(v_doc.folio, '')));
    if v_mat > 0 then
        if v_cta_mp is null then raise exception 'Falta la cuenta 115.01 (Inventario materia prima).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_mp, 'abono', v_mat, 'concepto', 'MP consumida ' || coalesce(v_doc.folio, ''));
    end if;
    if v_mo > 0 then
        if v_cta_mo is null then raise exception 'Falta la cuenta 601.01 (Sueldos y salarios).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_mo, 'abono', v_mo, 'concepto', 'Mano de obra aplicada ' || coalesce(v_doc.folio, ''));
    end if;
    if jsonb_array_length(v_movs) < 2 then
        -- todo el costo era materiales: reabre el abono a MP
        v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_pt, 'cargo', v_total),
                                    jsonb_build_object('cuenta_id', v_cta_mp, 'abono', v_total));
    end if;

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Diario',
        'concepto', 'Produccion ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, ''),
        'folio', v_doc.folio,
        'origen', 'produccion', 'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos set poliza_id = v_pid, total = v_total where id = p_documento_id;
    return jsonb_build_object('poliza_id', v_pid, 'total', v_total);
end;
$$;

-- =====================================================================
-- contabilizar_venta(p_documento_id, p_datos) -> { poliza_id, total }
--   Documento tipo salida_venta. El costo (FIFO) esta en documento_detalles.
--   p_datos: { venta_subtotal, venta_iva, condicion ('contado'|'credito'),
--              cuenta_cobro_id, uuid_cfdi, cliente_nombre, cliente_rfc,
--              cuenta_ingreso_id (opcional, default 401.01) }
--   Poliza Ingreso (una sola, cuadra):
--     Cargo <cuenta_cobro_id: 105.01 clientes / 102.01 bancos>  subtotal+iva
--     Abono 401.01 ventas                                        subtotal
--     Abono 209.01/209.02 IVA trasladado                         iva
--     Cargo 501.01 costo de venta                                costo
--     Abono 115.xx inventario (por producto)                     costo
-- =====================================================================
create or replace function public.contabilizar_venta(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc     public.documentos%rowtype;
    v_sub     numeric(14,2) := round(coalesce((p_datos->>'venta_subtotal')::numeric, 0), 2);
    v_iva     numeric(14,2) := round(coalesce((p_datos->>'venta_iva')::numeric, 0), 2);
    v_cond    text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'contado');
    v_cobro   bigint := (p_datos->>'cuenta_cobro_id')::bigint;
    v_cta_ing bigint := coalesce((p_datos->>'cuenta_ingreso_id')::bigint, public._cuenta_id('401.01'));
    v_cta_cv  bigint := public._cuenta_id('501.01');
    v_inv     jsonb  := public._inv_por_cuenta(p_documento_id);
    v_costo   numeric(14,2) := 0;
    v_totcob  numeric(14,2);
    v_movs    jsonb := '[]'::jsonb;
    v_cuenta  public.cuentas_contables%rowtype;
    v_id      bigint;
    r         jsonb;
    v_pid     bigint;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de venta no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta venta ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_doc.tipo_movimiento <> 'salida_venta' then
        raise exception 'contabilizar_venta solo aplica a salida por venta (tipo actual: %).', v_doc.tipo_movimiento;
    end if;
    if v_sub <= 0 then raise exception 'Captura el subtotal de la venta.'; end if;
    if v_cond not in ('contado','credito') then raise exception 'Condicion invalida: %', v_cond; end if;
    if v_cta_ing is null then raise exception 'Falta la cuenta 401.01 (Ventas) en el plan de cuentas.'; end if;
    if v_cta_cv  is null then raise exception 'Falta la cuenta 501.01 (Costo de venta) en el plan de cuentas.'; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cobro;
    if not found then raise exception 'Selecciona la cuenta de cobro (clientes / banco / caja).'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    v_totcob := round(v_sub + v_iva, 2);

    -- ---- lado ingreso ----
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cobro, 'cargo', v_totcob, 'concepto', 'Venta ' || coalesce(v_doc.folio, '')),
        jsonb_build_object('cuenta_id', v_cta_ing, 'abono', v_sub, 'concepto', 'Ingreso por venta ' || coalesce(v_doc.folio, ''))
    );
    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_cond = 'contado' then '209.01' else '209.02' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA trasladado).',
            case when v_cond = 'contado' then '209.01' else '209.02' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_iva, 'concepto', 'IVA trasladado');
    end if;

    -- ---- lado costo ----
    for r in select * from jsonb_array_elements(v_inv)
    loop
        v_costo := v_costo + (r->>'monto')::numeric;
        v_movs  := v_movs || jsonb_build_object('cuenta_id', (r->>'cuenta_id')::bigint, 'abono', (r->>'monto')::numeric, 'concepto', 'Salida por venta ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_costo > 0 then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_cv, 'cargo', v_costo, 'concepto', 'Costo de venta ' || coalesce(v_doc.folio, ''));
    end if;

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Ingreso',
        'concepto', 'Venta ' || coalesce(v_doc.folio, '') || coalesce(' - ' || p_datos->>'cliente_nombre', ''),
        'folio', v_doc.folio,
        'origen', 'venta', 'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos
       set poliza_id = v_pid,
           venta_subtotal = v_sub, venta_iva = v_iva, venta_total = v_totcob,
           condicion = v_cond,
           cuenta_pago_id = v_cobro,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           cliente_nombre = nullif(trim(p_datos->>'cliente_nombre'), ''),
           cliente_rfc = nullif(trim(p_datos->>'cliente_rfc'), '')
     where id = p_documento_id;

    return jsonb_build_object('poliza_id', v_pid, 'total', v_totcob, 'costo', v_costo);
end;
$$;

revoke all on function public._inv_por_cuenta(bigint)                        from public;
revoke all on function public.contabilizar_salida(bigint, jsonb)            from public;
revoke all on function public.contabilizar_entrada_directa(bigint, jsonb)   from public;
revoke all on function public.contabilizar_produccion(bigint, jsonb)        from public;
revoke all on function public.contabilizar_venta(bigint, jsonb)             from public;
grant execute on function public.contabilizar_salida(bigint, jsonb)          to authenticated;
grant execute on function public.contabilizar_entrada_directa(bigint, jsonb) to authenticated;
grant execute on function public.contabilizar_produccion(bigint, jsonb)      to authenticated;
grant execute on function public.contabilizar_venta(bigint, jsonb)           to authenticated;

commit;
