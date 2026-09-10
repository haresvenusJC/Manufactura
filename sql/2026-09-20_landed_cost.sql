-- =====================================================================
--  Landed cost — flete, seguro y otros cargos de la factura se integran
--  al costo unitario del lote y se capitalizan al inventario.
--  Fecha: 2026-09-20  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-08-28_contabilidad_compras.sql
--
--  Ejemplo: 100 pzas x $10 = $1,000  +  flete $100  +  seguro $100.
--  Costo unitario "landed" = 1,200 / 100 = $12 (no $10). El reparto es
--  POR VALOR (subtotal de cada partida ÷ subtotal total).
--
--  Al confirmar el recibo:
--    · lotes_inventario.costo_unitario  = costo material + su parte de
--      los cargos capitalizables.
--    · lotes_inventario.costo_adicional_unitario  = solo esa parte
--      (para reportes: "de los $12, $2 fue flete/seguro").
--    · documento_detalles.subtotal  = costo MATERIAL (fiel a la factura).
--    · contabilizar_compra: Cargo 115.xx  por  subtotal_material +
--      cargos capitalizables; los NO capitalizables van a su cuenta
--      (601.14 fletes por defecto).
--
--  Compatible: si p_datos no trae 'costos_adicionales', se comporta
--  igual que antes.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Trazabilidad en el lote y tabla de cargos adicionales del recibo
-- ---------------------------------------------------------------------
alter table public.lotes_inventario
    add column if not exists costo_adicional_unitario numeric(14,4) not null default 0;

comment on column public.lotes_inventario.costo_adicional_unitario is
  'Parte del costo_unitario del lote que provino de cargos capitalizables de la factura (flete, seguro, maniobras). costo material = costo_unitario - costo_adicional_unitario.';

create table if not exists public.recibo_costos_adicionales (
    id              bigint generated always as identity primary key,
    documento_id    bigint not null references public.documentos(id) on delete cascade,
    concepto        text not null,                         -- flete / seguro / maniobras / aduana / otro
    monto           numeric(14,2) not null check (monto >= 0),
    capitaliza      boolean not null default true,
    cuenta_gasto_id bigint references public.cuentas_contables(id) on delete set null,  -- solo si NO capitaliza
    creado_en       timestamptz not null default now()
);
create index if not exists idx_rca_doc on public.recibo_costos_adicionales(documento_id);

alter table public.recibo_costos_adicionales enable row level security;
drop policy if exists admin_all on public.recibo_costos_adicionales;
create policy admin_all on public.recibo_costos_adicionales for all to authenticated using (true) with check (true);
grant all on public.recibo_costos_adicionales to authenticated;


-- ---------------------------------------------------------------------
-- 2. contabilizar_compra — capitaliza los cargos adicionales al inventario
--    (idéntica a la previa salvo el manejo de p_datos->'costos_adicionales')
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    v_subtotal   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'subtotal')::numeric, 0), 2));
    v_iva        numeric(14,2) := greatest(0, round(coalesce((p_datos->>'iva')::numeric, 0), 2));
    v_ieps       numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ieps')::numeric, 0), 2));
    v_ret_iva    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2));
    v_ret_isr    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2));
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

    v_ext        jsonb := coalesce(p_datos->'costos_adicionales', '[]'::jsonb);
    v_ext_cap    numeric(14,2) := 0;
    v_ext_nocap  numeric(14,2) := 0;
    v_base_inv   numeric(14,2);
    v_cta_flete  bigint := public._cuenta_id('601.14');
    e            record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select coalesce(sum(subtotal), 0) into v_sum_det from public.documento_detalles where documento_id = p_documento_id;
    if v_subtotal <= 0 then v_subtotal := round(v_sum_det, 2); end if;
    if v_subtotal <= 0 then raise exception 'La compra no tiene importe (subtotal 0).'; end if;

    -- cargos adicionales de la factura
    select coalesce(sum((x->>'monto')::numeric), 0)
      into v_ext_cap
      from jsonb_array_elements(v_ext) x
     where coalesce((x->>'capitaliza')::boolean, true);
    select coalesce(sum((x->>'monto')::numeric), 0)
      into v_ext_nocap
      from jsonb_array_elements(v_ext) x
     where not coalesce((x->>'capitaliza')::boolean, true);
    v_ext_cap := round(v_ext_cap, 2);
    v_ext_nocap := round(v_ext_nocap, 2);

    v_total := round(v_subtotal + v_ext_cap + v_ext_nocap + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden superar subtotal + impuestos.'; end if;

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- CARGOS de inventario (material + cargos capitalizables), repartidos
    --      por la cuenta de inventario de cada producto, proporcional al
    --      subtotal de sus partidas. El ultimo grupo absorbe el redondeo.
    v_base_inv := round(v_subtotal + v_ext_cap, 2);
    for r in
        select coalesce(pr.cuenta_inventario_id, v_cta_inv_def) as cta_id,
               sum(dd.subtotal) as monto_det
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
         where dd.documento_id = p_documento_id
         group by coalesce(pr.cuenta_inventario_id, v_cta_inv_def)
         order by 1
    loop
        if v_sum_det > 0 then
            v_reparto := round(v_base_inv * (r.monto_det / v_sum_det), 2);
        else
            v_reparto := v_base_inv;
        end if;
        v_acum := v_acum + v_reparto;
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', v_reparto, 'concepto', 'Inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_acum <> v_base_inv and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_base_inv - v_acum), 2))
        );
    end if;

    -- ---- cargos adicionales NO capitalizables -> a su cuenta de gasto ----
    if v_ext_nocap > 0 then
        for e in
            select coalesce((x->>'cuenta_gasto_id')::bigint, v_cta_flete) as cta,
                   sum((x->>'monto')::numeric) as monto
              from jsonb_array_elements(v_ext) x
             where not coalesce((x->>'capitaliza')::boolean, true)
             group by 1
        loop
            if e.cta is null then raise exception 'Un cargo adicional no capitalizable no tiene cuenta de gasto y falta la 601.14 de respaldo.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', e.cta, 'cargo', round(e.monto, 2),
                        'concepto', 'Cargo de compra (no inventariable) ' || coalesce(v_doc.folio, ''));
        end loop;
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

    -- guardar el desglose de cargos adicionales para trazabilidad
    if jsonb_array_length(v_ext) > 0 then
        insert into public.recibo_costos_adicionales (documento_id, concepto, monto, capitaliza, cuenta_gasto_id)
        select p_documento_id,
               coalesce(nullif(trim(x->>'concepto'), ''), 'otro'),
               round((x->>'monto')::numeric, 2),
               coalesce((x->>'capitaliza')::boolean, true),
               (x->>'cuenta_gasto_id')::bigint
          from jsonb_array_elements(v_ext) x
         where (x->>'monto')::numeric > 0;
    end if;

    update public.documentos
       set subtotal = v_subtotal, iva = v_iva, ieps = v_ieps, ret_iva = v_ret_iva, ret_isr = v_ret_isr,
           total = v_total, condicion = v_condicion,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = case when v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;


-- =====================================================================
-- select numero_lote, costo_unitario, costo_adicional_unitario
--   from public.lotes_inventario order by created_at desc limit 10;
-- select * from public.recibo_costos_adicionales order by id desc limit 10;
-- =====================================================================
