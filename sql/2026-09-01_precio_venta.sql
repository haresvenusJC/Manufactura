-- =====================================================================
--  Precio de venta por producto  +  ajuste a contabilizar_venta
--  Fecha: 2026-09-01   Proyecto: Hares de Mexico (Supabase)
--
--  Se pega y corre a mano en:  Supabase -> SQL Editor
--  Requiere: sql/2026-08-31_contabilidad_operaciones.sql (contabilizar_venta)
--
--  - productos.precio_venta       : precio de lista de venta (sin IVA).
--  - documento_detalles.precio_venta : precio unitario de venta con el que
--                                   se registro cada partida (snapshot).
--  - contabilizar_venta ahora calcula solo el subtotal y el IVA cuando no
--    se los pasan, a partir de documento_detalles.precio_venta y de
--    productos.tasa_iva. Asi una venta ya registrada se puede contabilizar
--    despues sin recapturar importes.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.productos
    add column if not exists precio_venta numeric(14,4)
        check (precio_venta is null or precio_venta >= 0);

alter table public.documento_detalles
    add column if not exists precio_venta numeric(14,4);

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
    v_iva_dada boolean := (p_datos ? 'venta_iva') and nullif(trim(p_datos->>'venta_iva'), '') is not null;
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

    -- Si no pasan el subtotal, se calcula de las partidas (cantidad * precio_venta).
    if v_sub <= 0 then
        select round(coalesce(sum(dd.cantidad * coalesce(dd.precio_venta, 0)), 0), 2)
          into v_sub
          from public.documento_detalles dd
         where dd.documento_id = p_documento_id;
    end if;
    if v_sub <= 0 then
        raise exception 'La venta no tiene precio: captura precio_venta en los productos o pasa el subtotal.';
    end if;

    -- Si no pasan el IVA, se calcula por partida con la tasa de cada producto
    -- (tasa_iva NULL = exento = 0).
    if not v_iva_dada then
        select round(coalesce(sum(
                   round(dd.cantidad * coalesce(dd.precio_venta, 0) * coalesce(pr.tasa_iva, 0), 2)
               ), 0), 2)
          into v_iva
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
         where dd.documento_id = p_documento_id;
    end if;

    if v_cond not in ('contado','credito') then raise exception 'Condicion invalida: %', v_cond; end if;
    if v_cta_ing is null then raise exception 'Falta la cuenta 401.01 (Ventas) en el plan de cuentas.'; end if;
    if v_cta_cv  is null then raise exception 'Falta la cuenta 501.01 (Costo de venta) en el plan de cuentas.'; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cobro;
    if not found then raise exception 'Selecciona la cuenta de cobro (clientes / banco / caja).'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    v_totcob := round(v_sub + v_iva, 2);

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
        'concepto', 'Venta ' || coalesce(v_doc.folio, '') || coalesce(' - ' || (p_datos->>'cliente_nombre'), ''),
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

    return jsonb_build_object('poliza_id', v_pid, 'total', v_totcob, 'costo', v_costo, 'subtotal', v_sub, 'iva', v_iva);
end;
$$;

revoke all     on function public.contabilizar_venta(bigint, jsonb) from public;
grant  execute on function public.contabilizar_venta(bigint, jsonb) to authenticated;

commit;
