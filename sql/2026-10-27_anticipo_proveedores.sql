-- =====================================================================
--  Anticipo a proveedores
--  Fecha: 2026-10-27  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-02_pagos_proveedor.sql, contabilidad fases 1-4.
--
--  Contexto: el flujo real es pagar la orden de compra ANTES de que
--  llegue la mercancía (a veces 7 días antes) — el proveedor no factura
--  sin cobrar primero. Hasta ahora el sistema solo sabía "Contado" (se
--  abona banco EN el momento de la recepción) o "Crédito" (se abona
--  201.01 Proveedores) — no había forma de reflejar el pago adelantado,
--  así que la recepción terminaba abonando banco de nuevo, como si el
--  dinero saliera ese día (nunca salió dos veces del banco real, pero
--  el registro contable sí lo hubiera hecho de haberse marcado "Contado"
--  otra vez al recibir).
--
--  Solución (aprobada por el usuario tras revisar los asientos):
--  1. Cuenta nueva 109.01 "Anticipos a proveedores" (activo circulante).
--  2. pagos_proveedor_aplicaciones ya soportaba pagar contra un documento
--     de compra o un gasto (tipo 'compra'/'gasto'); se agregan dos tipos:
--       - 'anticipo_oc': el pago del anticipo en sí, ligado a la OC
--         (orden_compra_id), antes de que exista ningún documento.
--       - 'anticipo_aplicado': el rastro de que ese anticipo se consumió
--         contra un documento de recepción (aplicacion_origen_id apunta
--         a la fila 'anticipo_oc' de origen; documento_id, al recibo).
--  3. pagar_anticipo_oc(oc_id, datos) — RPC nuevo: Cargo 109.01 / Abono
--     banco, póliza de Egreso (sí sale dinero real en ese momento).
--  4. contabilizar_compra() SIEMPRE reconoce el pasivo COMPLETO en 201.01
--     al recibir (control de proveedores intacto, auditable en su
--     auxiliar), y en la MISMA póliza lo cancela por la vía que
--     corresponda: contra el anticipo disponible de esa OC (Cargo 201.01
--     / Abono 109.01) y, si sobra, contra banco (si se paga ahí mismo) o
--     se deja pendiente en 201.01 (crédito). El tipo de póliza ya no
--     depende de la casilla "Contado/Crédito" sino de si ESA póliza
--     específica abona banco por algo: Egreso solo si sí, si no Diario.
--  5. cancelar_pago_proveedor() no deja cancelar un anticipo que ya se
--     aplicó a una recepción (hay que cancelar esa recepción primero).
--  6. cancelar_recibo_inventario() libera el anticipo que esa recepción
--     había consumido (borra su 'anticipo_aplicado'), para que quede
--     disponible de nuevo.
--  7. v_anticipos_oc — saldo de anticipo pagado/aplicado/disponible por
--     OC, para la pantalla (botón "💰 Anticipo" en Órdenes de compra).
--
--  Simulación completa (revisada con el usuario, cuadra en ambos):
--    Escenario 1 (anticipo cubre el 100%): Asiento 1 (pago, día 1) Cargo
--    109.01 $11,600 / Abono banco $11,600. Asiento 2 (recepción, día 8)
--    Cargo Inventario $10,000 + Cargo IVA $1,600, Abono 201.01 $11,600
--    (reconoce) + Cargo 201.01 $11,600 (cancela) + Abono 109.01 $11,600
--    (libera) — tipo Diario, nadie abonó banco aquí.
--    Escenario 2 (anticipo parcial $5,800, resto a crédito): igual pero
--    solo se cancelan $5,800 del 201.01 reconocido; quedan $5,800 vivos
--    en 201.01 (pendientes, visibles en Pagos a proveedor) — tipo Diario.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Cuenta 109 / 109.01 — Anticipos a proveedores
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select '109', 'Anticipos a proveedores', '109', 'D', 'activo', 1, false
where not exists (select 1 from public.cuentas_contables where codigo = '109');

insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select '109.01', 'Anticipos a proveedores', '109.01', 'D', 'activo', 2, true
where not exists (select 1 from public.cuentas_contables where codigo = '109.01');

update public.cuentas_contables c
   set cuenta_padre_id = p.id
  from public.cuentas_contables p
 where c.codigo = '109.01' and c.cuenta_padre_id is null
   and p.codigo = '109' and p.nivel = 1;

-- ---------------------------------------------------------------------
-- 2. pagos_proveedor_aplicaciones — dos columnas y dos tipos nuevos
-- ---------------------------------------------------------------------
alter table public.pagos_proveedor_aplicaciones add column if not exists orden_compra_id bigint references public.ordenes_compra (id) on delete set null;
alter table public.pagos_proveedor_aplicaciones add column if not exists aplicacion_origen_id bigint references public.pagos_proveedor_aplicaciones (id) on delete set null;
create index if not exists pagos_proveedor_aplic_oc_idx on public.pagos_proveedor_aplicaciones (orden_compra_id);
create index if not exists pagos_proveedor_aplic_origen_idx on public.pagos_proveedor_aplicaciones (aplicacion_origen_id);

do $$
declare c record;
begin
    for c in select conname from pg_constraint
             where conrelid = 'public.pagos_proveedor_aplicaciones'::regclass and contype = 'c'
               and pg_get_constraintdef(oid) ilike '%tipo%compra%gasto%'
    loop execute format('alter table public.pagos_proveedor_aplicaciones drop constraint %I', c.conname); end loop;
end $$;
alter table public.pagos_proveedor_aplicaciones add constraint pagos_proveedor_aplicaciones_tipo_check
    check (tipo in ('compra', 'gasto', 'anticipo_oc', 'anticipo_aplicado'));

-- Reglas de integridad en la base (no solo en pantalla): cada tipo trae
-- exactamente la referencia que le corresponde, nunca otra.
do $$
declare c record;
begin
    for c in select conname from pg_constraint
             where conrelid = 'public.pagos_proveedor_aplicaciones'::regclass and contype = 'c'
               and pg_get_constraintdef(oid) ilike '%anticipo_oc%orden_compra_id%'
    loop execute format('alter table public.pagos_proveedor_aplicaciones drop constraint %I', c.conname); end loop;
end $$;
alter table public.pagos_proveedor_aplicaciones add constraint pagos_proveedor_aplicaciones_consistencia_check
    check (
        (tipo = 'compra'            and documento_id is not null and gasto_id is null     and orden_compra_id is null and aplicacion_origen_id is null) or
        (tipo = 'gasto'             and gasto_id is not null     and documento_id is null  and orden_compra_id is null and aplicacion_origen_id is null) or
        (tipo = 'anticipo_oc'       and orden_compra_id is not null and documento_id is null and gasto_id is null and aplicacion_origen_id is null) or
        (tipo = 'anticipo_aplicado' and aplicacion_origen_id is not null and documento_id is not null and gasto_id is null and orden_compra_id is null)
    );

-- ---------------------------------------------------------------------
-- 3. Saldo de anticipo disponible de una OC (pagado - ya aplicado)
-- ---------------------------------------------------------------------
create or replace function public._saldo_anticipo_oc(p_oc_id bigint)
returns numeric
language sql
stable
as $$
    select round(
        coalesce((
            select sum(a.monto) from public.pagos_proveedor_aplicaciones a
            join public.pagos_proveedor pp on pp.id = a.pago_id
           where a.tipo = 'anticipo_oc' and a.orden_compra_id = p_oc_id and pp.estatus = 'registrado'
        ), 0)
        -
        coalesce((
            select sum(a2.monto) from public.pagos_proveedor_aplicaciones a2
            join public.pagos_proveedor_aplicaciones a1 on a1.id = a2.aplicacion_origen_id
           where a2.tipo = 'anticipo_aplicado' and a1.tipo = 'anticipo_oc' and a1.orden_compra_id = p_oc_id
        ), 0)
    , 2);
$$;

-- ---------------------------------------------------------------------
-- 4. pagar_anticipo_oc(oc_id, datos) -> { pago_id, poliza_id, total }
--    datos: { fecha, monto, cuenta_pago_id, forma_pago, referencia, notas }
-- ---------------------------------------------------------------------
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

    v_cta109 := public._cuenta_id('109.01');
    if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores) en el plan de cuentas.'; end if;

    insert into public.pagos_proveedor (fecha, cuenta_pago_id, forma_pago, referencia, proveedor_id, total, notas)
    values (v_fecha, v_cta_pago, v_forma, v_ref, v_oc.proveedor_id, v_monto, v_notas)
    returning id into v_pago_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha, 'tipo', 'Egreso',
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

-- ---------------------------------------------------------------------
-- 5. contabilizar_compra() — reconoce SIEMPRE el pasivo completo en
--    201.01 y lo cancela por la vía que corresponda (anticipo / banco /
--    queda a crédito). Copia de sql/2026-10-07_candado_diferencia_
--    fisica_factura.sql con ese único bloque cambiado.
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
    v_base_inv   numeric(14,2);
    v_tolerancia constant numeric(14,2) := 5.00;
    v_msg        text;

    v_ext        jsonb := coalesce(p_datos->'costos_adicionales', '[]'::jsonb);
    v_ext_cap    numeric(14,2) := 0;
    v_ext_nocap  numeric(14,2) := 0;
    v_cta_flete    bigint := public._cuenta_id('601.14');
    v_cta_seguro   bigint := public._cuenta_id('601.61');
    v_cta_maniobra bigint := public._cuenta_id('601.62');
    v_cta_aduana   bigint := public._cuenta_id('601.63');
    v_cta_otros    bigint := public._cuenta_id('601.99');
    e            record;

    -- Anticipo a proveedores (2026-09-25): siempre se reconoce el pasivo
    -- completo en 201.01 y luego se cancela por la vía que corresponda.
    v_cta201        bigint;
    v_cta109        bigint;
    v_anticipo_disp numeric(14,2);
    v_anticipo_usar numeric(14,2) := 0;
    v_resto         numeric(14,2);
    v_pagado_total  numeric(14,2) := 0;
    v_tipo_poliza   text;
    v_falta         numeric(14,2);
    v_take          numeric(14,2);
    rA           record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select coalesce(sum(subtotal), 0) into v_sum_det from public.documento_detalles where documento_id = p_documento_id;
    if v_subtotal <= 0 then v_subtotal := round(v_sum_det, 2); end if;
    if v_subtotal <= 0 then raise exception 'La compra no tiene importe (subtotal 0).'; end if;

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

    -- Cuanto de esta compra ya esta cubierto por un anticipo pagado antes
    -- (0 si la OC no tiene anticipo, o si la compra no viene de una OC).
    v_anticipo_disp := coalesce(public._saldo_anticipo_oc(v_doc.orden_compra_id), 0);
    v_anticipo_usar := least(v_anticipo_disp, v_total);
    v_resto := round(v_total - v_anticipo_usar, 2);

    -- La cuenta de banco solo es obligatoria si de verdad va a haber un
    -- abono a banco (el resto, marcado Contado, despues de aplicar el
    -- anticipo) — si el anticipo ya cubrio todo, no hace falta elegirla
    -- aunque el XML venga marcado PUE/Contado.
    if v_condicion = 'contado' and v_resto > 0 then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- Reparto REAL: suma lo que de verdad quedó grabado en cada lote
    -- (lotes_inventario.costo_unitario, ya con su landed cost aplicado,
    -- vía documento_detalles.lote_id) agrupado por cuenta de inventario.
    v_base_inv := round(v_subtotal + v_ext_cap, 2);
    for r in
        select coalesce(pr.cuenta_inventario_id, v_cta_inv_def) as cta_id,
               sum(coalesce(li.costo_unitario * dd.cantidad, dd.subtotal)) as monto_real
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
          left join public.lotes_inventario li on li.id = dd.lote_id
         where dd.documento_id = p_documento_id
         group by coalesce(pr.cuenta_inventario_id, v_cta_inv_def)
         order by 1
    loop
        v_acum := v_acum + round(r.monto_real, 2);
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', round(r.monto_real, 2), 'concepto', 'Inventario ' || coalesce(v_doc.folio, ''));
    end loop;

    -- Si lo que de verdad entró a inventario (v_acum, por cantidad física)
    -- difiere del subtotal facturado (v_base_inv) por más que un redondeo
    -- de centavos, NO se absorbe en silencio hacia la cuenta de inventario
    -- — se detiene y se explica qué hacer. El ajuste automático solo cubre
    -- diferencias de centavos entre lotes.
    if abs(v_acum - v_base_inv) > v_tolerancia and jsonb_array_length(v_movs) > 0 then
        v_msg := format(
            'Lo que se va a recibir a inventario ($%s) no coincide con el subtotal de la factura ($%s) — diferencia de $%s, mayor a la tolerancia de redondeo ($%s). '
            'Esto pasa cuando llegó menos (o más) de lo facturado. Dos salidas: '
            '1) Ajusta aquí el campo "Subtotal" al valor de lo que sí vas a contabilizar ahora, y gestiona la diferencia con el proveedor aparte (normalmente pidiendo una nota de crédito) — cuando llegue, se contabiliza por separado; '
            'o 2) si el proveedor ya confirmó que la diferencia no se repone ni se descuenta, captúrala aparte como Gasto (merma) en vez de forzarla en esta compra.',
            round(v_acum, 2), round(v_base_inv, 2), round(v_acum - v_base_inv, 2), v_tolerancia
        );
        raise exception using message = v_msg;
    end if;
    if v_acum <> v_base_inv and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs,
            array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_base_inv - v_acum), 2))
        );
    end if;

    -- Cargos no capitalizables: cada concepto a su propia cuenta de gasto
    -- (flete 601.14 / seguro 601.61 / maniobras 601.62 / aduana 601.63 /
    -- otro 601.99), no todos por default a 601.14.
    if v_ext_nocap > 0 then
        for e in
            select coalesce(
                     (x->>'cuenta_gasto_id')::bigint,
                     case lower(coalesce(x->>'concepto', ''))
                         when 'flete' then v_cta_flete
                         when 'seguro' then v_cta_seguro
                         when 'maniobras' then v_cta_maniobra
                         when 'aduana / pedimento' then v_cta_aduana
                         else v_cta_otros
                     end,
                     v_cta_flete
                   ) as cta,
                   sum((x->>'monto')::numeric) as monto
              from jsonb_array_elements(v_ext) x
             where not coalesce((x->>'capitaliza')::boolean, true)
             group by 1
        loop
            if e.cta is null then raise exception 'Un cargo adicional no capitalizable no tiene cuenta de gasto y falta su cuenta de respaldo en el plan de cuentas.'; end if;
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

    -- ---- Reconocimiento del pasivo + su cancelación (SIEMPRE por 201.01) ----
    v_cta201 := public._cuenta_id('201.01');
    if v_cta201 is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;

    -- 1) Se reconoce el pasivo COMPLETO, siempre — así el proveedor
    --    queda con su movimiento completo en su auxiliar, aunque el neto
    --    termine en cero por el anticipo (control de pasivos).
    v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'abono', v_total,
                'concepto', 'Compra ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);

    -- 2) Se cancela contra el anticipo disponible de esa OC (si hay).
    if v_anticipo_usar > 0 then
        v_cta109 := public._cuenta_id('109.01');
        if v_cta109 is null then raise exception 'Falta la cuenta 109.01 (Anticipos a proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_anticipo_usar,
                    'concepto', 'Aplicacion de anticipo - ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta109, 'abono', v_anticipo_usar,
                    'concepto', 'Anticipo aplicado a ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_pagado_total := v_pagado_total + v_anticipo_usar;
    end if;

    -- 3) Lo que sobra del anticipo: si se marca Contado, se paga ahí
    --    mismo (Cargo 201.01 / Abono banco); si es Crédito, se queda
    --    pendiente en 201.01 tal cual (nada más que hacer aquí).
    if v_resto > 0 and v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta201, 'cargo', v_resto,
                    'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_resto,
                    'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''));
        v_pagado_total := v_pagado_total + v_resto;
    end if;

    -- Tipo de póliza: Egreso solo si ESTA póliza abona banco por algo
    -- (el resto pagado ahí mismo); si el anticipo cubrió todo o el resto
    -- queda a crédito, es Diario — ya no depende del combo Contado/Crédito.
    v_tipo_poliza := case when v_resto > 0 and v_condicion = 'contado' then 'Egreso' else 'Diario' end;

    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', v_tipo_poliza,
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),
        'folio', v_doc.folio,
        'origen', 'compra',
        'origen_tabla', 'documentos',
        'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

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
           total_pagado = v_pagado_total,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = case when v_resto > 0 and v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = nullif(trim(p_datos->>'uuid_cfdi'), ''),
           rfc_emisor = nullif(trim(p_datos->>'rfc_emisor'), ''),
           poliza_id = v_id
     where id = p_documento_id;

    -- Consume el/los anticipo(s) de esa OC (FIFO por si hubo mas de un
    -- pago de anticipo) dejando el rastro en pagos_proveedor_aplicaciones
    -- para que _saldo_anticipo_oc() ya lo descuente la proxima vez.
    if v_anticipo_usar > 0 then
        v_falta := v_anticipo_usar;
        for rA in
            select a.id as aplic_id, a.pago_id,
                   round(a.monto - coalesce((
                       select sum(a2.monto) from public.pagos_proveedor_aplicaciones a2
                        where a2.tipo = 'anticipo_aplicado' and a2.aplicacion_origen_id = a.id
                   ), 0), 2) as disponible
              from public.pagos_proveedor_aplicaciones a
              join public.pagos_proveedor pp on pp.id = a.pago_id
             where a.tipo = 'anticipo_oc' and a.orden_compra_id = v_doc.orden_compra_id and pp.estatus = 'registrado'
             order by a.id
        loop
            exit when v_falta <= 0;
            if rA.disponible <= 0 then continue; end if;
            v_take := least(rA.disponible, v_falta);
            insert into public.pagos_proveedor_aplicaciones (pago_id, tipo, documento_id, aplicacion_origen_id, monto)
            values (rA.pago_id, 'anticipo_aplicado', p_documento_id, rA.aplic_id, v_take);
            v_falta := v_falta - v_take;
        end loop;
    end if;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap,
        'anticipo_aplicado', v_anticipo_usar);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 6. cancelar_pago_proveedor() — no deja cancelar un anticipo ya
--    aplicado a una recepción (hay que cancelar esa recepción primero).
-- ---------------------------------------------------------------------
create or replace function public.cancelar_pago_proveedor(p_pago_id bigint)
returns jsonb
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_pago public.pagos_proveedor%rowtype;
    a      public.pagos_proveedor_aplicaciones%rowtype;
    v_res  jsonb := '{}'::jsonb;
begin
    select * into v_pago from public.pagos_proveedor where id = p_pago_id;
    if not found then raise exception 'El pago no existe.'; end if;
    if v_pago.estatus <> 'registrado' then raise exception 'El pago ya esta %.', v_pago.estatus; end if;

    if exists (select 1 from public.pagos_proveedor_aplicaciones where pago_id = p_pago_id and tipo = 'anticipo_aplicado') then
        raise exception 'Este anticipo ya se aplico a una recepcion. Cancela primero esa recepcion (documento) para liberar el anticipo.';
    end if;

    if v_pago.poliza_id is not null then
        v_res := public.cancelar_poliza(v_pago.poliza_id, 'Cancelacion de pago a proveedor #' || v_pago.id);
    end if;

    for a in select * from public.pagos_proveedor_aplicaciones where pago_id = p_pago_id
    loop
        if a.tipo = 'compra' and a.documento_id is not null then
            update public.documentos set total_pagado = greatest(0, round(coalesce(total_pagado, 0) - a.monto, 2)) where id = a.documento_id;
        elsif a.tipo = 'gasto' and a.gasto_id is not null then
            update public.gastos set total_pagado = greatest(0, round(coalesce(total_pagado, 0) - a.monto, 2)) where id = a.gasto_id;
        end if;
        -- 'anticipo_oc': no toca total_pagado de nada; al quedar el pago
        -- 'cancelado', _saldo_anticipo_oc() ya lo excluye solo.
    end loop;

    update public.pagos_proveedor set estatus = 'cancelado' where id = p_pago_id;
    return v_res;
end $$;

revoke all     on function public.cancelar_pago_proveedor(bigint) from public, anon;
grant  execute on function public.cancelar_pago_proveedor(bigint) to authenticated;

-- ---------------------------------------------------------------------
-- 7. cancelar_recibo_inventario() — libera el anticipo que esa recepción
--    hubiera consumido. Copia de sql/2026-09-26_fix_unificado_costeo_
--    recepcion.sql con solo ese paso agregado (1b) y total_pagado a 0.
-- ---------------------------------------------------------------------
create or replace function public.cancelar_recibo_inventario(p_documento_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc         public.documentos%rowtype;
    v_bloqueo     text;
    v_pol_estatus text;
    v_pol_rev     bigint;
    v_movs        jsonb := '[]'::jsonb;
    v_n           integer := 0;
    r             record;
    v_stock       numeric;
    v_oc          bigint;
    v_estatus     text;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento % no existe.', p_documento_id; end if;
    if coalesce(v_doc.estado, '') = 'cancelado' then
        raise exception 'El documento % ya está cancelado.', p_documento_id;
    end if;
    if coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada') then
        raise exception 'Solo se puede revertir un recibo de compra (tipo actual: %).', coalesce(v_doc.tipo_movimiento, 'N/D');
    end if;

    -- guarda: nada del inventario recibido debe haberse consumido, ni
    -- físicamente (stock_actual) ni de la cola de costeo PEPS (stock_costeo)
    select string_agg(
             format('· %s lote %s: recibiste %s; físico disponible %s (consumido %s); costeo disponible %s (consumido %s)',
                    d.producto_nombre, d.numero_lote, d.recibido, d.disponible, d.consumido,
                    d.costeo_disponible, d.costeo_consumido), E'\n')
      into v_bloqueo
      from public.recibo_reversible(p_documento_id) d
     where not d.ok;
    if v_bloqueo is not null then
        raise exception E'No se puede revertir el inventario del recibo %: ya se consumió stock (físico o de costeo).\n%', p_documento_id, v_bloqueo;
    end if;

    if not exists (select 1 from public.recibo_reversible(p_documento_id)) then
        raise exception 'El recibo % no tiene movimientos de inventario que revertir.', p_documento_id;
    end if;

    -- 1) cancelar la póliza (si tiene). Solo se tolera explícitamente el
    --    caso "ya estaba cancelada" — cualquier otro problema real debe
    --    detener TODA la función, para no revertir inventario sin poder
    --    revertir su contabilidad.
    if v_doc.poliza_id is not null then
        select estatus into v_pol_estatus from public.polizas where id = v_doc.poliza_id;
        if v_pol_estatus is null then
            v_pol_rev := null;  -- la póliza referenciada ya no existe
        elsif v_pol_estatus = 'cancelada' then
            v_pol_rev := null;  -- ya estaba cancelada: caso tolerado a propósito
        else
            v_pol_rev := (public.cancelar_poliza(v_doc.poliza_id,
                coalesce(p_motivo, 'Cancelación de recibo ' || coalesce(v_doc.folio, p_documento_id::text)))
                ->>'poliza_reversa_id')::bigint;
        end if;
    end if;

    -- 1b) liberar cualquier anticipo que esta recepcion haya consumido
    -- (2026-09-25): sin esto, el saldo de anticipo de la OC se quedaria
    -- descontado para siempre aunque la recepcion se haya cancelado.
    delete from public.pagos_proveedor_aplicaciones
     where tipo = 'anticipo_aplicado' and documento_id = p_documento_id;

    -- 2) revertir el inventario lote por lote (físico Y costeo)
    for r in
        select d.producto_id, d.lote_id, d.numero_lote, d.recibido, p.nombre as producto_nombre,
               um.nombre as unidad
        from public.recibo_reversible(p_documento_id) d
        join public.productos p on p.id = d.producto_id
        left join public.unidades_medida um on um.id = p.unidad_medida_id
    loop
        select coalesce(stock_actual, 0) into v_stock
        from public.productos where id = r.producto_id;

        if r.lote_id is not null then
            update public.lotes_inventario
               set stock_actual = greatest(coalesce(stock_actual, 0) - r.recibido, 0),
                   stock_costeo = greatest(coalesce(stock_costeo, 0) - r.recibido, 0)
             where id = r.lote_id;
        end if;

        update public.productos p2
           set stock_actual = (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = r.producto_id)
         where p2.id = r.producto_id;

        insert into public.movimientos_inventario
            (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id, lote_id)
        values (
            r.producto_id, 'cancelacion_recibo', -abs(r.recibido),
            v_stock,
            (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = r.producto_id),
            coalesce((select costo_unitario from public.lotes_inventario where id = r.lote_id), 0),
            p_documento_id, r.lote_id
        );

        v_n := v_n + 1;
        v_movs := v_movs || jsonb_build_object(
            'producto', r.producto_nombre, 'lote', r.numero_lote,
            'cantidad', -abs(r.recibido), 'unidad', coalesce(r.unidad, ''));
    end loop;

    -- 3) revertir la orden de compra (cantidad_recibida + estatus)
    v_oc := v_doc.orden_compra_id;
    if v_oc is not null then
        update public.ordenes_compra_detalle ocd
           set cantidad_recibida = greatest(coalesce(ocd.cantidad_recibida, 0) - dd.q, 0)
          from (select producto_id, sum(cantidad) as q
                  from public.documento_detalles
                 where documento_id = p_documento_id and producto_id is not null
                 group by producto_id) dd
         where ocd.orden_compra_id = v_oc and ocd.producto_id = dd.producto_id;

        select case
                 when bool_and(coalesce(cantidad_recibida, 0) >= coalesce(cantidad, 0)) then 'recibida'
                 when bool_and(coalesce(cantidad_recibida, 0) = 0) then 'abierta'
                 else 'recibida_parcial'
               end
          into v_estatus
          from public.ordenes_compra_detalle where orden_compra_id = v_oc;
        update public.ordenes_compra set estatus = coalesce(v_estatus, estatus) where id = v_oc;
    end if;

    -- 4) marcar el documento (y limpiar total_pagado — su pago, si lo
    --    tenía, ya se liberó arriba)
    update public.documentos set estado = 'cancelado', total_pagado = 0 where id = p_documento_id;

    return jsonb_build_object(
        'documento_id', p_documento_id,
        'poliza_reversa_id', v_pol_rev,
        'movimientos', v_movs,
        'mensaje', format('Recibo #%s cancelado. Revertidos %s movimiento(s) de inventario%s.',
                          p_documento_id, v_n,
                          case when v_doc.poliza_id is not null then ' y cancelada su póliza' else '' end)
    );
end;
$$;

revoke all     on function public.cancelar_recibo_inventario(bigint, text) from public;
grant  execute on function public.cancelar_recibo_inventario(bigint, text) to authenticated;

-- ---------------------------------------------------------------------
-- 8. v_anticipos_oc — pagado / aplicado / disponible por OC (solo las
--    que tienen algún anticipo pagado, aunque ya esté todo aplicado).
-- ---------------------------------------------------------------------
create or replace view public.v_anticipos_oc as
    select oc.id as orden_compra_id, oc.folio, oc.proveedor_id, pv.nombre as proveedor_nombre,
           coalesce(sum(a.monto) filter (where pp.estatus = 'registrado'), 0) as pagado,
           coalesce(sum(a2.monto), 0) as aplicado,
           round(coalesce(sum(a.monto) filter (where pp.estatus = 'registrado'), 0) - coalesce(sum(a2.monto), 0), 2) as disponible
      from public.ordenes_compra oc
      join public.pagos_proveedor_aplicaciones a on a.orden_compra_id = oc.id and a.tipo = 'anticipo_oc'
      join public.pagos_proveedor pp on pp.id = a.pago_id
      left join public.proveedores pv on pv.id = oc.proveedor_id
      left join public.pagos_proveedor_aplicaciones a2 on a2.aplicacion_origen_id = a.id and a2.tipo = 'anticipo_aplicado'
     group by oc.id, oc.folio, oc.proveedor_id, pv.nombre;

grant select on public.v_anticipos_oc to authenticated;

commit;
