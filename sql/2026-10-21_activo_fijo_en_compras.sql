-- =====================================================================
--  Activo fijo en el proceso de compra
--  Fecha: 2026-10-21  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere (ya corridas): sql/2026-10-02_activos_fijos.sql,
--  sql/2026-10-14_depreciacion_al_prorrateo.sql,
--  sql/2026-10-15_equipos_unificados.sql,
--  sql/2026-10-14b_iva_anticipo_recepcion.sql,
--  sql/2026-10-27_anticipo_proveedores.sql
--
--  Problema: un equipo comprado seguía el mismo camino que la materia prima
--  (requisición -> ODC -> recepción), pero al recibirlo se metía al
--  inventario (lote, kardex, existencia) y luego había que darlo de alta a
--  mano en Activos fijos, volviendo a teclear el costo.
--
--  Qué hace (decisiones del usuario 2026-10-21):
--    1. Nuevo TIPO de producto 'activo_fijo'. El equipo se pide como
--       cualquier producto (si no existe, se crea desde la requisición).
--    2. Al RECIBIR una partida 'activo_fijo' NO entra al inventario: la póliza
--       de la recepción carga la cuenta de ACTIVO (152.xx; por default 152.01)
--       contra Proveedores (o Anticipos 109.01), con su IVA, igual que siempre.
--    3. La misma recepción da de alta el activo en Activos fijos con el costo
--       y la fecha reales de la compra, ligado a proveedor, ODC, recepción y
--       póliza, en estado PENDIENTE DE COMPLETAR: faltan los datos que solo
--       el usuario sabe (área, vida útil, etapas, si se deprecia). Mientras
--       esté pendiente no se deprecia ni entra al prorrateo.
--    4. Un equipo por partida: la recepción exige cantidad 1 para este tipo.
--    5. Cancelar la recepción retira el activo (si ya se depreció, no deja).
--
--  Funciones reescritas COMPLETAS (create or replace, sin parches de texto):
--    · contabilizar_compra   = versión de 2026-10-14b + cuenta de activo
--                              fijo + alta automática del activo
--    · cancelar_recibo_inventario = versión de 2026-10-27 + retiro de activos
--  Funciones nuevas: _alta_activos_desde_recepcion
--
--  Idempotente. Las recepciones ya hechas no se tocan.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. productos.tipo acepta 'activo_fijo'
-- ---------------------------------------------------------------------
do $$
declare
    v_tipo_dato text;
    r record;
    v_valores text[];
    v_ajustada boolean := false;
begin
    select format_type(a.atttypid, a.atttypmod) into v_tipo_dato
      from pg_attribute a
     where a.attrelid = 'public.productos'::regclass and a.attname = 'tipo' and not a.attisdropped;

    if exists (select 1 from pg_attribute a join pg_type t on t.oid = a.atttypid
                where a.attrelid = 'public.productos'::regclass and a.attname = 'tipo' and t.typtype = 'e') then
        raise exception 'productos.tipo es un ENUM (%). Corre primero, sola: alter type % add value if not exists ''activo_fijo''; y luego esta migración.',
            v_tipo_dato, v_tipo_dato;
    end if;

    -- Reglas CHECK que limitan los valores de tipo (la vigente lista producto,
    -- semiterminado, materia_prima, insumo): se recrea con 'activo_fijo' agregado.
    for r in
        select c.conname, pg_get_constraintdef(c.oid) as def
          from pg_constraint c
         where c.conrelid = 'public.productos'::regclass
           and c.contype = 'c'
           and pg_get_constraintdef(c.oid) ~* '\ytipo\y'
           and pg_get_constraintdef(c.oid) ~* '''(producto|materia_prima|insumo)'''
           and pg_get_constraintdef(c.oid) !~* '''activo_fijo'''
    loop
        select array_agg(distinct m[1]) into v_valores
          from regexp_matches(r.def, '''([^'']+)''', 'g') as m;
        v_valores := array_append(v_valores, 'activo_fijo');
        execute format('alter table public.productos drop constraint %I', r.conname);
        execute format('alter table public.productos add constraint %I check (tipo is null or tipo = any (%L::text[]))',
                       r.conname, v_valores);
        raise notice 'Regla % ampliada: %', r.conname, v_valores;
        v_ajustada := true;
    end loop;
    if not v_ajustada then
        raise notice 'productos.tipo no tiene regla CHECK que ampliar (o ya aceptaba activo_fijo).';
    end if;
end $$;


-- ---------------------------------------------------------------------
-- 2. activos_fijos: pendiente de completar + ligas a la compra
-- ---------------------------------------------------------------------
alter table public.activos_fijos
    add column if not exists pendiente            boolean not null default false,
    add column if not exists producto_id          bigint  references public.productos (id),
    add column if not exists documento_id         bigint  references public.documentos (id),
    add column if not exists documento_detalle_id bigint,
    add column if not exists orden_compra_id      bigint  references public.ordenes_compra (id),
    add column if not exists proveedor_id         bigint  references public.proveedores (id),
    add column if not exists poliza_compra_id     bigint  references public.polizas (id);

comment on column public.activos_fijos.pendiente is
  'true = lo dio de alta una recepción de compra y falta completar sus datos (área, vida útil, etapas, depreciable). Mientras sea true no se deprecia ni entra al prorrateo.';
comment on column public.activos_fijos.documento_id is
  'Recepción (documento entrada_compra) de la que nació este activo; null si se dio de alta a mano.';

create index if not exists activos_fijos_documento_idx on public.activos_fijos (documento_id);
create unique index if not exists activos_fijos_detalle_uq
    on public.activos_fijos (documento_detalle_id) where documento_detalle_id is not null;

-- Las reglas de "depreciable necesita costo y vida útil" y "no depreciable
-- necesita área y potencia" no aplican mientras el activo está pendiente.
alter table public.activos_fijos drop constraint if exists activos_fijos_dep_chk;
alter table public.activos_fijos add  constraint activos_fijos_dep_chk
    check (pendiente or depreciable = false or (coalesce(costo_adquisicion, 0) > 0 and coalesce(vida_util_meses, 0) > 0));

alter table public.activos_fijos drop constraint if exists activos_fijos_nodep_chk;
alter table public.activos_fijos add  constraint activos_fijos_nodep_chk
    check (pendiente or depreciable = true or (area_id is not null and potencia_kw is not null));


-- ---------------------------------------------------------------------
-- 3. _alta_activos_desde_recepcion — da de alta el activo (pendiente) de cada
--    partida 'activo_fijo' de una recepción. La llama contabilizar_compra.
-- ---------------------------------------------------------------------
create or replace function public._alta_activos_desde_recepcion(p_documento_id bigint, p_poliza_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc    public.documentos%rowtype;
    r        record;
    v_n      integer := 0;
    v_cta_def bigint := public._cuenta_id('152.01');
    v_costo  numeric(14,2);
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra % no existe.', p_documento_id; end if;

    for r in
        select dd.id as det_id, dd.producto_id, dd.cantidad, dd.subtotal,
               p.nombre, p.cuenta_inventario_id
          from public.documento_detalles dd
          join public.productos p on p.id = dd.producto_id
         where dd.documento_id = p_documento_id
           and p.tipo = 'activo_fijo'
         order by dd.id
    loop
        if r.cantidad is distinct from 1 then
            raise exception 'El activo fijo «%» se recibe de uno en uno por partida (cantidad: %). Si compraste varios equipos, captura una partida por cada uno.',
                r.nombre, r.cantidad;
        end if;
        continue when exists (select 1 from public.activos_fijos where documento_detalle_id = r.det_id);

        v_costo := round(coalesce(r.subtotal, 0), 2);
        if v_costo <= 0 then
            raise exception 'El activo fijo «%» llegó sin costo; captura el costo real en la recepción.', r.nombre;
        end if;

        insert into public.activos_fijos
            (nombre, fecha_adquisicion, costo_adquisicion, valor_residual, cuenta_activo_id,
             pendiente, depreciable, producto_id, documento_id, documento_detalle_id,
             orden_compra_id, proveedor_id, poliza_compra_id, notas)
        values
            (r.nombre, v_doc.fecha_emision, v_costo, 0, coalesce(r.cuenta_inventario_id, v_cta_def),
             true, true, r.producto_id, p_documento_id, r.det_id,
             v_doc.orden_compra_id, v_doc.proveedor_id, p_poliza_id,
             'Alta automática al recibir ' || coalesce(v_doc.folio, '#' || p_documento_id)
                 || '. Falta completar: área, vida útil, etapas y si se deprecia.');
        v_n := v_n + 1;
    end loop;

    return v_n;
end;
$$;

revoke all on function public._alta_activos_desde_recepcion(bigint, bigint) from public, anon;


-- ---------------------------------------------------------------------
-- 4. contabilizar_compra — cuerpo COMPLETO (base: 2026-10-14b)
--    · el producto 'activo_fijo' sin cuenta propia carga 152.01 (no 115.01)
--    · al terminar, da de alta los activos fijos de la recepción (pendientes)
--    Lo demás es idéntico: anticipo, IVA 118.01/119.01, notas NDC/NDP, serie REC.
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_iva_pag numeric(14,2);
    v_iva_pen numeric(14,2);
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
    v_cta_af_def  bigint := public._cuenta_id('152.01');   -- activo fijo sin cuenta propia
    v_n_af        integer := 0;                            -- activos fijos dados de alta (pendientes de completar)
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
        select coalesce(pr.cuenta_inventario_id, case when pr.tipo = 'activo_fijo' then v_cta_af_def else v_cta_inv_def end) as cta_id,
               coalesce(bool_or(pr.tipo = 'activo_fijo'), false) as es_af,
               sum(coalesce(li.costo_unitario * dd.cantidad, dd.subtotal)) as monto_real
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
          left join public.lotes_inventario li on li.id = dd.lote_id
         where dd.documento_id = p_documento_id
         group by coalesce(pr.cuenta_inventario_id, case when pr.tipo = 'activo_fijo' then v_cta_af_def else v_cta_inv_def end)
         order by 1
    loop
        if r.cta_id is null then
            raise exception 'Falta la cuenta contable de esta compra: el producto no tiene cuenta y no existe la de respaldo (115.01 inventario / 152.01 activo fijo) en el plan de cuentas.';
        end if;
        v_acum := v_acum + round(r.monto_real, 2);
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', round(r.monto_real, 2),
                    'concepto', case when r.es_af then 'Activo fijo ' else 'Inventario ' end || coalesce(v_doc.folio, ''));
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

    -- IVA acreditable (LIVA: solo es acreditable el IVA efectivamente pagado).
    -- La parte del IVA que corresponde a lo YA pagado con anticipo (v_anticipo_usar
    -- del total) va directo a 118.01 (pagado); el resto queda en 119.01 (pendiente)
    -- y se reclasifica al pagar el saldo (registrar_pago_proveedor, proporcional).
    -- Con anticipo = 100% todo va a 118.01.
    if v_iva > 0 then
        v_iva_pag := case when v_total > 0 then round(v_iva * v_anticipo_usar / v_total, 2) else 0 end;
        if v_resto = 0 then v_iva_pag := v_iva; end if;
        v_iva_pen := round(v_iva - v_iva_pag, 2);
        if v_iva_pag > 0 then
            v_id := public._cuenta_id('118.01');
            if v_id is null then raise exception 'Falta la cuenta 118.01 (IVA acreditable pagado) en el plan de cuentas.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva_pag, 'concepto', 'IVA acreditable (cubierto con anticipo)');
        end if;
        if v_iva_pen > 0 then
            v_id := public._cuenta_id('119.01');
            if v_id is null then raise exception 'Falta la cuenta 119.01 (IVA acreditable pendiente de pago) en el plan de cuentas.'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva_pen, 'concepto', 'IVA acreditable');
        end if;
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
        'serie', 'REC',
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

    -- Activos fijos que llegaron en esta recepción: se dan de alta solos, PENDIENTES
    -- de completar (área, vida útil, etapas...) en Finanzas -> Activos fijos.
    -- No pasan por el inventario: su costo ya quedó en la cuenta de activo (152.xx).
    v_n_af := public._alta_activos_desde_recepcion(p_documento_id, v_id);

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
        'anticipo_aplicado', v_anticipo_usar, 'nota_folio', v_nota_folio, 'activos_creados', v_n_af);
end;
$$;

grant execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- 5. cancelar_recibo_inventario — cuerpo COMPLETO (base: 2026-10-27)
--    · una recepción solo de activos fijos (sin movimientos de inventario) ya se
--      puede cancelar
--    · retira los activos fijos que dio de alta; si alguno ya se depreció, no deja
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
    v_n_af        integer := 0;
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

    -- guarda de activos fijos: si alguno de los que llegaron en este recibo ya
    -- empezó a depreciarse, no se puede deshacer la compra sin antes revertir eso.
    select string_agg('· ' || a.nombre, E'\n') into v_bloqueo
      from public.activos_fijos a
     where a.documento_id = p_documento_id
       and exists (select 1 from public.activos_fijos_depreciaciones d where d.activo_id = a.id);
    if v_bloqueo is not null then
        raise exception E'No se puede cancelar el recibo %: ya se aplicó depreciación a un activo fijo que llegó en él.\n%\nCancela primero esa depreciación (Activos fijos).', p_documento_id, v_bloqueo;
    end if;

    if not exists (select 1 from public.recibo_reversible(p_documento_id))
       and not exists (select 1 from public.activos_fijos where documento_id = p_documento_id) then
        raise exception 'El recibo % no tiene movimientos de inventario ni activos fijos que revertir.', p_documento_id;
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

    -- 1c) los activos fijos que dio de alta esta recepción (pendientes o ya
    -- completados, pero sin depreciación) se retiran junto con la compra.
    delete from public.activos_fijos where documento_id = p_documento_id;
    get diagnostics v_n_af = row_count;

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
        'activos_fijos_retirados', v_n_af,
        'mensaje', format('Recibo #%s cancelado. Revertidos %s movimiento(s) de inventario%s%s.',
                          p_documento_id, v_n,
                          case when v_n_af > 0 then format(' y retirado(s) %s activo(s) fijo(s)', v_n_af) else '' end,
                          case when v_doc.poliza_id is not null then ' y cancelada su póliza' else '' end)
    );
end;
$$;

revoke all     on function public.cancelar_recibo_inventario(bigint, text) from public;
grant  execute on function public.cancelar_recibo_inventario(bigint, text) to authenticated;

commit;


-- =====================================================================
--  Verificación (opcional, solo lectura)
-- =====================================================================
-- select pg_get_constraintdef(oid) from pg_constraint where conrelid = 'public.productos'::regclass and contype = 'c' and pg_get_constraintdef(oid) ~* 'tipo';
-- select id, nombre, costo_adquisicion, pendiente, documento_id, orden_compra_id from public.activos_fijos where pendiente order by id;
