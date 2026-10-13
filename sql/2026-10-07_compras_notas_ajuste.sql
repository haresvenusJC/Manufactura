-- =====================================================================
--  Compras ya no decide el pago + Notas de crédito/cargo en la recepción
--  Fecha: 2026-10-07  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-10-27_anticipo_proveedores.sql (contabilizar_compra,
--  cancelar_recibo_inventario vigentes), sql/2026-10-21_folios_consecutivos.sql
--  (siguiente_folio).
--
--  Contexto (conversación con el usuario, 2026-10-06/07): Compras recibe
--  la mercancía y contabiliza la recepción (siempre lo hizo así: la
--  póliza nace al confirmar/validar el pre-recibo, que es la MISMA
--  pantalla y el MISMO botón — "Recibo de mercancía" nunca fue una
--  pantalla aparte de "Pre-recibos", solo lo parecía). Lo que Compras NO
--  debe decidir es CÓMO se paga: la ODC se paga de antemano como
--  anticipo (ya existe, contabilizar_compra ya lo aplica solo) y lo que
--  no cubre el anticipo se queda en 201.01 para que Finanzas lo pague
--  después desde Cuentas por pagar. Por eso aquí se quitan de
--  contabilizar_compra la Condición (contado/crédito) y la Cuenta de
--  pago: la póliza de la recepción YA NUNCA abona banco directo — es
--  Diario siempre. El banco solo se mueve en pagar_anticipo_oc (antes)
--  o registrar_pago_proveedor (después), que ya existían y ya generan
--  Egreso correctamente.
--
--  Notas de crédito/cargo (NDC/NDP): cuando lo que llegó físicamente no
--  coincide en valor con la factura (antes esto tronaba sin más —
--  sql/2026-09-26.../2026-10-07_candado_diferencia_fisica_factura.sql),
--  ahora se puede resolver en el momento, sin salir de la recepción: la
--  diferencia se registra como NDC (llegó menos / nos deben) o NDP
--  (llegó más / nos cobran más) con un motivo, y el pasivo (201.01) se
--  ajusta por ese monto en la MISMA póliza de la recepción — el
--  inventario siempre entra a lo que de verdad llegó, nunca al valor de
--  la factura. No hay "nota aparte" sobre mercancía ya consumida: el
--  usuario decidió que esto se resuelve aquí, no después.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Tabla de notas (solo metadatos + motivo; la contabilidad vive en la
--    MISMA póliza de la recepción — no tiene póliza propia).
-- ---------------------------------------------------------------------
create table if not exists public.notas_compra (
    id               bigint generated always as identity primary key,
    folio            text not null unique,
    tipo             text not null check (tipo in ('credito','cargo')),
    documento_id     bigint references public.documentos (id) on delete set null,
    orden_compra_id  bigint references public.ordenes_compra (id) on delete set null,
    proveedor_id     bigint references public.proveedores (id) on delete set null,
    monto            numeric(14,2) not null check (monto > 0),
    motivo           text not null check (motivo in (
                        'dañada en transporte', 'caducada o próxima a caducar',
                        'fuera de especificación de calidad', 'empaque roto',
                        'excedente (llegó más de lo ordenado)', 'producto distinto al de la OC', 'otro'
                      )),
    motivo_detalle   text,
    poliza_id        bigint references public.polizas (id) on delete set null,
    estatus          text not null default 'activa' check (estatus in ('activa','cancelada')),
    creado_en        timestamptz not null default now()
);

create index if not exists notas_compra_doc_idx on public.notas_compra (documento_id);
create index if not exists notas_compra_oc_idx  on public.notas_compra (orden_compra_id);

alter table public.notas_compra enable row level security;
drop policy if exists admin_all on public.notas_compra;
create policy admin_all on public.notas_compra for all to authenticated using (true) with check (true);
grant all on public.notas_compra to authenticated;
revoke all on public.notas_compra from anon;

comment on table public.notas_compra is
  'Nota de crédito (llegó menos / nos deben) o de cargo (llegó más / nos cobran más), registrada en el momento de validar la recepción. Ajusta el pasivo (201.01) en la misma póliza de la recepción — no tiene póliza propia.';

-- Rechazo/merma por partida, informativo (no mueve pasivo por sí solo —
-- la corrección de pasivo, si aplica, es la nota de arriba).
alter table public.documento_detalles add column if not exists motivo_rechazo text;
alter table public.documento_detalles add column if not exists motivo_rechazo_detalle text;


-- ---------------------------------------------------------------------
-- 2. contabilizar_compra(): ya no recibe condición ni cuenta de pago —
--    la recepción nunca paga directo, siempre es Diario. Gana
--    p_datos->'nota_ajuste' para resolver una diferencia física vs.
--    factura sin salir de la pantalla.
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
    v_total      numeric(14,2);
    v_sum_det    numeric(14,2);
    v_movs       jsonb := '[]'::jsonb;
    v_id         bigint;
    v_cta_inv_def bigint := public._cuenta_id('115.01');
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

    -- Nota de crédito/cargo (2026-10-07): resuelve la diferencia física
    -- vs. factura en el momento, sin salir de la recepción.
    v_nota          jsonb := p_datos->'nota_ajuste';
    v_nota_tipo     text;
    v_nota_monto    numeric(14,2);
    v_nota_motivo   text;
    v_nota_detalle  text;
    v_nota_dif      numeric(14,2);
    v_nota_folio    text;
    v_nota_pendiente boolean := false;

    -- Anticipo a proveedores: siempre se reconoce el pasivo completo en
    -- 201.01 y luego se cancela por la vía que corresponda.
    v_cta201        bigint;
    v_cta109        bigint;
    v_anticipo_disp numeric(14,2);
    v_anticipo_usar numeric(14,2) := 0;
    v_resto         numeric(14,2);
    v_pagado_total  numeric(14,2) := 0;
    v_falta         numeric(14,2);
    v_take          numeric(14,2);
    rA           record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;

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
    -- de centavos: se resuelve con una nota de crédito/cargo (si viene en
    -- p_datos->'nota_ajuste') o se detiene explicando qué hacer.
    if abs(v_acum - v_base_inv) > v_tolerancia and jsonb_array_length(v_movs) > 0 then
        v_nota_tipo := nullif(trim(v_nota->>'tipo'), '');
        v_nota_monto := round(coalesce((v_nota->>'monto')::numeric, 0), 2);
        v_nota_motivo := nullif(trim(v_nota->>'motivo'), '');
        v_nota_detalle := nullif(trim(v_nota->>'motivo_detalle'), '');
        v_nota_dif := round(v_base_inv - v_acum, 2);  -- > 0 = llego menos (credito) · < 0 = llego de mas (cargo)

        if v_nota_tipo is null or v_nota_motivo is null
           or (v_nota_tipo = 'credito' and v_nota_dif <= 0)
           or (v_nota_tipo = 'cargo' and v_nota_dif >= 0)
           or abs(v_nota_monto - abs(v_nota_dif)) > v_tolerancia
        then
            v_msg := format(
                'Lo que se va a recibir a inventario ($%s) no coincide con el subtotal de la factura ($%s) — diferencia de $%s, mayor a la tolerancia de redondeo ($%s). '
                'Esto pasa cuando llegó menos (o más) de lo facturado. Registra una Nota de %s por $%s con su motivo para resolverlo aquí mismo, '
                'o si el proveedor ya confirmó que la diferencia no se repone ni se descuenta, captúrala aparte como Gasto (merma) en vez de forzarla en esta compra.',
                round(v_acum, 2), round(v_base_inv, 2), round(v_acum - v_base_inv, 2), v_tolerancia,
                case when v_nota_dif > 0 then 'Crédito (NDC)' else 'Cargo (NDP)' end, abs(v_nota_dif)
            );
            raise exception using
                message = v_msg,
                detail = jsonb_build_object(
                    'necesita_nota', true,
                    'tipo', case when v_nota_dif > 0 then 'credito' else 'cargo' end,
                    'monto', abs(v_nota_dif)
                )::text;
        end if;
        if v_nota_motivo = 'otro' and v_nota_detalle is null then
            raise exception 'Motivo "Otro": especifica el detalle de la nota.';
        end if;

        -- La nota cubre la diferencia: el inventario se queda en lo REAL
        -- recibido (v_acum); el subtotal/total de la compra se ajustan por
        -- el monto de la nota (antes de IVA — simplificación: el IVA se
        -- sigue reconociendo tal cual lo trae la factura; confirmar con el
        -- contador si debe prorratearse).
        v_subtotal := round(v_subtotal - v_nota_dif, 2);
        v_base_inv := v_acum;
        v_total := round(v_subtotal + v_ext_cap + v_ext_nocap + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
        if v_total < 0 then raise exception 'La nota de ajuste deja el total de la compra en negativo.'; end if;
        v_nota_pendiente := true;
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

    -- Cuanto de esta compra ya esta cubierto por un anticipo pagado antes
    -- (0 si la OC no tiene anticipo, o si la compra no viene de una OC).
    -- Se calcula HASTA AQUI porque ya se conoce el v_total final (despues
    -- de aplicar, si hizo falta, la nota de ajuste de arriba).
    v_anticipo_disp := coalesce(public._saldo_anticipo_oc(v_doc.orden_compra_id), 0);
    v_anticipo_usar := least(v_anticipo_disp, v_total);
    v_resto := round(v_total - v_anticipo_usar, 2);

    -- IVA acreditable: 118.01 (ya pagado) solo si el anticipo cubrio TODO
    -- el total (resto = 0) — si queda algo vivo en 201.01, el IVA tambien
    -- esta pendiente de pago (119.01). Ya no depende de un combo Contado/
    -- Credito: la recepcion nunca decide el pago.
    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_resto = 0 then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA acreditable) en el plan de cuentas.',
            case when v_resto = 0 then '118.01' else '119.01' end; end if;
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

    -- 3) Lo que sobra (v_resto) se queda vivo en 201.01 — Finanzas lo paga
    --    despues desde Cuentas por pagar. La recepcion ya NUNCA abona
    --    banco directo, asi que la poliza siempre es Diario.
    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', 'Diario',
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
           total = v_total, condicion = 'credito',
           total_pagado = v_pagado_total,
           forma_pago = nullif(trim(p_datos->>'forma_pago'), ''),
           cuenta_pago_id = null,
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

    -- Nota de credito/cargo (si la diferencia fisica vs. factura se
    -- resolvio arriba): queda registrada con su folio propio, ligada a
    -- esta misma poliza (no tiene poliza aparte).
    if v_nota_pendiente then
        v_nota_folio := public.siguiente_folio(case when v_nota_tipo = 'credito' then 'NDC' else 'NDP' end);
        insert into public.notas_compra (folio, tipo, documento_id, orden_compra_id, proveedor_id, monto, motivo, motivo_detalle, poliza_id)
        values (v_nota_folio, v_nota_tipo, p_documento_id, v_doc.orden_compra_id, v_doc.proveedor_id, abs(v_nota_dif), v_nota_motivo, v_nota_detalle, v_id);
    end if;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total,
        'subtotal_material', v_subtotal, 'capitalizado', v_ext_cap, 'gasto', v_ext_nocap,
        'anticipo_aplicado', v_anticipo_usar, 'nota_folio', v_nota_folio);
end;
$$;

revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- 3. cancelar_recibo_inventario(): al cancelar la recepción, cualquier
--    nota de crédito/cargo que se haya registrado en esa recepción
--    (su efecto contable ya se revierte solo, viene en la MISMA póliza)
--    se marca 'cancelada' nada más para que no se vea como vigente.
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

    -- 1c) marcar cualquier nota de crédito/cargo de esta recepción como
    -- cancelada (2026-10-07): su efecto contable ya se revierte solo con
    -- la póliza de arriba (vivía en la misma póliza), esto es solo para
    -- que deje de aparecer como vigente.
    update public.notas_compra set estatus = 'cancelada' where documento_id = p_documento_id and estatus = 'activa';

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

commit;
