-- =====================================================================
--  Pago a proveedor: reclasifica IVA pendiente -> IVA pagado
--  Fecha: 2026-10-13  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-02_pagos_proveedor.sql
--
--  Bug: registrar_pago_proveedor solo generaba Cargo 201.01 Proveedores +
--  Abono banco/caja. Una compra o gasto a CRÉDITO contabiliza su IVA en
--  119.01 "IVA acreditable pendiente de pago" (correcto: por LIVA, el IVA
--  solo es acreditable hasta que la contraprestación se paga
--  efectivamente). Al pagar, ese IVA debe reclasificarse a 118.01 "IVA
--  acreditable pagado" — y eso nunca pasaba: el saldo se quedaba para
--  siempre en 119.01 aunque la factura ya estuviera liquidada.
--
--  Fix: por cada documento/gasto aplicado en el pago, si tiene IVA,
--  se agrega a la misma póliza:
--    Cargo 118.01 IVA acreditable pagado       (proporcional al monto pagado)
--    Abono 119.01 IVA acreditable pendiente de pago
--  Proporcional porque un pago puede ser parcial: si se paga la mitad de
--  la factura, se reclasifica la mitad de su IVA (documentos.iva /
--  gastos.iva * (monto pagado / total del documento)).
--
--  Idempotente.
-- =====================================================================

begin;

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

        -- Reclasifica el IVA de esta factura, proporcional a lo que se está
        -- pagando ahora: de "pendiente de pago" a "pagado" (ya es acreditable).
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

commit;
