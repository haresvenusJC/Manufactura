-- =====================================================================
--  Contabilidad - FASE 4b: integracion de Compras
--  Fecha: 2026-08-28   Proyecto: Hares de Mexico (Supabase)
--
--  Se pega y corre a mano en:  Supabase -> SQL Editor
--  Requiere (en este orden):
--    sql/2026-08-28_contabilidad_cuentas.sql
--    sql/2026-08-28_contabilidad_polizas.sql
--    sql/2026-08-28_contabilidad_gastos.sql          (por el helper _cuenta_id)
--    sql/2026-08-28_contabilidad_productos_campos.sql
--
--  Agrega columnas fiscales a documentos (solo se usan en entrada_compra)
--  y el RPC contabilizar_compra, que arma y postea la poliza de la compra
--  repartiendo el subtotal por la cuenta de inventario de cada producto.
--
--  Poliza generada (compra a credito):
--    Cargo  115.xx  Inventario (por cuenta de cada producto)   subtotal
--    Cargo  118.01 / 119.01  IVA acreditable                    iva
--    Cargo  118.03  IEPS acreditable                            ieps
--    Abono  216.05 / 216.10  retenciones                        ret_iva / ret_isr
--    Abono  201.01 Proveedores  ó  <caja/banco>                 total
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.documentos
    add column if not exists subtotal       numeric(14,2),
    add column if not exists iva            numeric(14,2) default 0,
    add column if not exists ieps           numeric(14,2) default 0,
    add column if not exists ret_iva        numeric(14,2) default 0,
    add column if not exists ret_isr        numeric(14,2) default 0,
    add column if not exists total          numeric(14,2),
    add column if not exists condicion      text,
    add column if not exists forma_pago     text,
    add column if not exists cuenta_pago_id bigint references public.cuentas_contables(id),
    add column if not exists uuid_cfdi      text,
    add column if not exists rfc_emisor     text,
    add column if not exists poliza_id      bigint references public.polizas(id) on delete set null;

-- ---------------------------------------------------------------------
-- contabilizar_compra(p_documento_id, p_datos jsonb) -> { poliza_id, total }
--   p_datos: { subtotal, iva, ieps, ret_iva, ret_isr, condicion,
--              forma_pago, cuenta_pago_id, uuid_cfdi, rfc_emisor }
--   Si subtotal viene null/0, se toma la suma de documento_detalles.
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    v_subtotal   numeric(14,2) := round(coalesce((p_datos->>'subtotal')::numeric, 0), 2);
    v_iva        numeric(14,2) := round(coalesce((p_datos->>'iva')::numeric, 0), 2);
    v_ieps       numeric(14,2) := round(coalesce((p_datos->>'ieps')::numeric, 0), 2);
    v_ret_iva    numeric(14,2) := round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2);
    v_ret_isr    numeric(14,2) := round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2);
    v_condicion  text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'credito');
    v_cta_pago   bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_total      numeric(14,2);
    v_sum_det    numeric(14,2);
    v_movs       jsonb := '[]'::jsonb;
    v_id         bigint;
    v_cta_inv_def bigint := public._cuenta_id('115.01');
    v_cuenta     public.cuentas_contables%rowtype;
    r            record;
    v_acum       numeric(14,2) := 0;
    v_reparto    numeric(14,2);
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select coalesce(sum(subtotal), 0) into v_sum_det from public.documento_detalles where documento_id = p_documento_id;
    if v_subtotal <= 0 then v_subtotal := round(v_sum_det, 2); end if;
    if v_subtotal <= 0 then raise exception 'La compra no tiene importe (subtotal 0).'; end if;

    v_total := round(v_subtotal + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden superar subtotal + impuestos.'; end if;

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- CARGOS de inventario, repartidos por cuenta de cada producto ----
    -- (proporcional al subtotal de las partidas; el ultimo grupo absorbe el redondeo)
    for r in
        select coalesce(pr.cuenta_inventario_id, v_cta_inv_def) as cta_id,
               sum(dd.subtotal) as monto_det
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
         group by coalesce(pr.cuenta_inventario_id, v_cta_inv_def)
         order by 1
    loop
        if v_sum_det > 0 then
            v_reparto := round(v_subtotal * (r.monto_det / v_sum_det), 2);
        else
            v_reparto := v_subtotal;
        end if;
        v_acum := v_acum + v_reparto;
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', v_reparto, 'concepto', 'Inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    -- ajuste de redondeo en el ultimo renglon de inventario
    if v_acum <> v_subtotal and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_subtotal - v_acum), 2))
        );
    end if;

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA acreditable) en el plan de cuentas.',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva, 'concepto', 'IVA acreditable');
    end if;

    if v_ieps > 0 then
        v_id := public._cuenta_id('118.03');
        if v_id is null then raise exception 'Falta la cuenta 118.03 (IEPS acreditable).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_ieps, 'concepto', 'IEPS acreditable');
    end if;

    if v_ret_iva > 0 then
        v_id := public._cuenta_id('216.05');
        if v_id is null then raise exception 'Falta la cuenta 216.05 (IVA retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_iva, 'concepto', 'IVA retenido');
    end if;

    if v_ret_isr > 0 then
        v_id := public._cuenta_id('216.10');
        if v_id is null then raise exception 'Falta la cuenta 216.10 (ISR retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_isr, 'concepto', 'ISR retenido');
    end if;

    if v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total, 'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''));
    else
        v_id := public._cuenta_id('201.01');
        if v_id is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_total,
                    'concepto', 'Compra a credito ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
    end if;

    -- ---- postear poliza ----
    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', 'Egreso',
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),
        'folio', v_doc.folio,
        'origen', 'compra',
        'origen_tabla', 'documentos',
        'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos
       set subtotal = v_subtotal, iva = v_iva, ieps = v_ieps, ret_iva = v_ret_iva, ret_isr = v_ret_isr,
           total = v_total, condicion = v_condicion,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = case when v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;
