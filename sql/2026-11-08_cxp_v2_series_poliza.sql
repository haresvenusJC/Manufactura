-- =====================================================================
--  Cuentas por pagar v2: pago total / parcial, un proveedor por pago y
--  series de póliza BAN / VAE
--  Fecha: 2026-11-08  ·  Proyecto: Hares de México (Supabase)
--
--  1) Series de póliza por origen, ADEMÁS del tipo SAT (Egreso/Ingreso/Diario,
--     que se sigue reportando igual):
--       BAN = pago por banco (cuenta 102.xx)   VAE = pago en efectivo (caja 101.xx)
--     La serie sale de la cuenta de pago. Consecutivo CONTINUO por serie
--     (no reinicia por año), en contadores_folios con la clave 'POLBAN'/'POLVAE'.
--     Se guarda en polizas.serie / polizas.serie_folio ("BAN-00008"); las pólizas
--     anteriores NO se renumeran y siguen mostrándose como "Egreso #34".
--  2) pagos_proveedor.tipo_pago ('total' | 'parcial') y .acuerdo (texto del acuerdo
--     con el proveedor; obligatorio en pago parcial).
--  3) registrar_pago_proveedor_v2(p_datos) y pagar_anticipo_oc_v2(p_oc_id, p_datos):
--     envuelven las funciones vigentes (registrar_pago_proveedor / pagar_anticipo_oc,
--     que NO se tocan) en la MISMA transacción y agregan:
--       · un pago = un proveedor;
--       · Pago total = el saldo completo de cada documento / de la OC (no editable);
--       · Pago parcial = menor al saldo y con acuerdo escrito;
--       · asignan la serie BAN/VAE a la póliza que se generó.
--  No toca datos existentes. Idempotente. Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

alter table public.polizas add column if not exists serie       text;
alter table public.polizas add column if not exists serie_folio text;

alter table public.pagos_proveedor add column if not exists tipo_pago text;
alter table public.pagos_proveedor add column if not exists acuerdo   text;
do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'pagos_proveedor_tipo_pago_chk') then
        alter table public.pagos_proveedor
            add constraint pagos_proveedor_tipo_pago_chk check (tipo_pago is null or tipo_pago in ('total', 'parcial'));
    end if;
end $$;

-- Serie que le toca a una cuenta de pago: caja (101.xx) = VAE; cualquier otra (bancos) = BAN.
create or replace function public._serie_por_cuenta(p_cuenta_id bigint)
returns text
language sql stable
set search_path = public
as $$
    select case when c.codigo like '101%' then 'VAE' else 'BAN' end
      from public.cuentas_contables c where c.id = p_cuenta_id;
$$;

-- Asigna el siguiente consecutivo de la serie a una póliza y devuelve la etiqueta ("BAN-00008").
create or replace function public._poliza_asignar_serie(p_poliza_id bigint, p_serie text)
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_n     bigint;
    v_label text;
begin
    if p_poliza_id is null or coalesce(p_serie, '') = '' then return null; end if;
    insert into public.contadores_folios (serie, ultimo)
    values ('POL' || p_serie, 1)
    on conflict (serie) do update set ultimo = public.contadores_folios.ultimo + 1
    returning ultimo into v_n;
    v_label := p_serie || '-' || lpad(v_n::text, 5, '0');
    update public.polizas set serie = p_serie, serie_folio = v_label where id = p_poliza_id;
    return v_label;
end;
$$;

revoke all on function public._poliza_asignar_serie(bigint, text) from public, anon;
grant execute on function public._poliza_asignar_serie(bigint, text) to authenticated;

-- ---------------------------------------------------------------------
-- Pago a proveedor (deuda: compras recibidas y gastos a crédito)
-- ---------------------------------------------------------------------
create or replace function public.registrar_pago_proveedor_v2(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_tipo     text := coalesce(nullif(trim(p_datos->>'tipo_pago'), ''), 'total');
    v_acuerdo  text := nullif(trim(p_datos->>'acuerdo'), '');
    v_apps     jsonb := coalesce(p_datos->'aplicaciones', '[]'::jsonb);
    r          jsonb;
    v_prov     bigint;
    v_saldo    numeric(14,2);
    v_monto    numeric(14,2);
    v_sum_mto  numeric(14,2) := 0;
    v_sum_sdo  numeric(14,2) := 0;
    v_provs    bigint[] := '{}';
    v_res      jsonb;
    v_pago_id  bigint;
    v_pol_id   bigint;
    v_cta      bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_label    text;
begin
    if v_tipo not in ('total', 'parcial') then raise exception 'Tipo de pago no válido: %', v_tipo; end if;
    if jsonb_array_length(v_apps) < 1 then raise exception 'Selecciona al menos un documento a pagar.'; end if;
    if v_tipo = 'parcial' and v_acuerdo is null then
        raise exception 'El pago parcial exige escribir el acuerdo con el proveedor.';
    end if;

    for r in select * from jsonb_array_elements(v_apps)
    loop
        v_monto := round(coalesce((r->>'monto')::numeric, 0), 2);
        if r->>'tipo' = 'compra' then
            select proveedor_id, round(coalesce(total, 0) - coalesce(total_pagado, 0), 2) into v_prov, v_saldo
              from public.documentos where id = (r->>'id')::bigint;
        elsif r->>'tipo' = 'gasto' then
            select proveedor_id, round(coalesce(total, 0) - coalesce(total_pagado, 0), 2) into v_prov, v_saldo
              from public.gastos where id = (r->>'id')::bigint;
        else
            raise exception 'Tipo de aplicacion invalido: %', r->>'tipo';
        end if;
        if not found then raise exception 'El documento % #% no existe.', r->>'tipo', r->>'id'; end if;
        v_provs := v_provs || coalesce(v_prov, 0);
        v_sum_mto := v_sum_mto + v_monto;
        v_sum_sdo := v_sum_sdo + coalesce(v_saldo, 0);
        if v_tipo = 'total' and abs(v_monto - coalesce(v_saldo, 0)) > 0.01 then
            raise exception 'Pago total: cada documento se paga por su saldo completo (%). Para otro monto usa Pago parcial.', v_saldo;
        end if;
    end loop;

    if (select count(distinct x) from unnest(v_provs) x) > 1 then
        raise exception 'Un pago es de un solo proveedor: los documentos elegidos son de proveedores distintos.';
    end if;
    if v_tipo = 'parcial' and v_sum_mto >= v_sum_sdo - 0.005 then
        raise exception 'Para pagar el saldo completo usa Pago total; el pago parcial debe ser menor al saldo.';
    end if;

    v_res := public.registrar_pago_proveedor(p_datos);
    v_pago_id := (v_res->>'pago_id')::bigint;
    v_pol_id  := (v_res->>'poliza_id')::bigint;

    update public.pagos_proveedor set tipo_pago = v_tipo, acuerdo = v_acuerdo where id = v_pago_id;
    v_label := public._poliza_asignar_serie(v_pol_id, public._serie_por_cuenta(v_cta));

    return v_res || jsonb_build_object('serie_folio', v_label, 'tipo_pago', v_tipo);
end;
$$;

revoke all on function public.registrar_pago_proveedor_v2(jsonb) from public, anon;
grant execute on function public.registrar_pago_proveedor_v2(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- Anticipo a una OC que aún no se recibe (prepago contra la cotización)
-- ---------------------------------------------------------------------
create or replace function public.pagar_anticipo_oc_v2(p_oc_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_tipo     text := coalesce(nullif(trim(p_datos->>'tipo_pago'), ''), 'total');
    v_acuerdo  text := nullif(trim(p_datos->>'acuerdo'), '');
    v_monto    numeric(14,2) := round(coalesce((p_datos->>'monto')::numeric, 0), 2);
    v_total    numeric(14,2);
    v_pagado   numeric(14,2) := 0;
    v_saldo    numeric(14,2);
    v_res      jsonb;
    v_pago_id  bigint;
    v_pol_id   bigint;
    v_cta      bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_label    text;
begin
    if v_tipo not in ('total', 'parcial') then raise exception 'Tipo de pago no válido: %', v_tipo; end if;
    if v_tipo = 'parcial' and v_acuerdo is null then
        raise exception 'El pago parcial exige escribir el acuerdo con el proveedor.';
    end if;

    select coalesce(sum(d.cantidad * d.costo_unitario_estimado), 0) into v_total
      from public.ordenes_compra_detalle d where d.orden_compra_id = p_oc_id;
    begin
        select coalesce(pagado, 0) into v_pagado from public.v_anticipos_oc where orden_compra_id = p_oc_id;
    exception when others then v_pagado := 0;
    end;
    v_pagado := coalesce(v_pagado, 0);
    v_saldo := greatest(round(v_total - v_pagado, 2), 0);

    if v_tipo = 'total' and abs(v_monto - v_saldo) > 0.01 then
        raise exception 'Pago total: el anticipo es por el saldo de la OC (%). Para otro monto usa Pago parcial.', v_saldo;
    end if;
    if v_tipo = 'parcial' and v_saldo > 0 and v_monto >= v_saldo - 0.005 then
        raise exception 'Para pagar el saldo completo usa Pago total; el pago parcial debe ser menor al saldo.';
    end if;

    v_res := public.pagar_anticipo_oc(p_oc_id, p_datos);
    v_pago_id := (v_res->>'pago_id')::bigint;
    v_pol_id  := (v_res->>'poliza_id')::bigint;

    update public.pagos_proveedor set tipo_pago = v_tipo, acuerdo = v_acuerdo where id = v_pago_id;
    v_label := public._poliza_asignar_serie(v_pol_id, public._serie_por_cuenta(v_cta));

    return v_res || jsonb_build_object('serie_folio', v_label, 'tipo_pago', v_tipo);
end;
$$;

revoke all on function public.pagar_anticipo_oc_v2(bigint, jsonb) from public, anon;
grant execute on function public.pagar_anticipo_oc_v2(bigint, jsonb) to authenticated;

commit;

-- Revisión:
--   select id, tipo, numero, serie_folio, concepto from public.polizas where serie is not null order by id desc limit 10;
--   select id, fecha, total, tipo_pago, acuerdo from public.pagos_proveedor order by id desc limit 10;
