-- =====================================================================
--  ODC: la cotización del proveedor con SU unidad, SU clave SAT y SU precio,
--  convertida a la unidad del inventario con el factor.
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  ENTREGA 3 de 5 de "cotización del proveedor con su unidad y su factor".
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Correr DESPUÉS de sql/2026-10-23_catalogos_sat_* y 2026-10-23b_claves_proveedor_unidad_sat.sql.
--
--  Regla (el stock y el BOM solo conocen UNA unidad por producto):
--    factor              = unidades de INVENTARIO por 1 unidad del proveedor (1 MIL = 1,000 piezas -> 1000)
--    cantidad interna    = cantidad del proveedor x factor            (21 MIL      -> 21,000 piezas)
--    costo interno       = precio del proveedor ÷ factor, 4 decimales  ($3,560.5689 ÷ 1000 -> $3.5606)
--    importe OFICIAL     = round(cantidad proveedor x precio proveedor, 2)  (21 x 3,560.5689 = 74,771.95)
--  El subtotal, el IVA y el anticipo salen de esos importes del proveedor; el costo interno se DERIVA
--  (cantidad interna x costo interno puede diferir unos centavos del importe oficial, y está bien).
--  Sin clave de unidad SAT la partida va como siempre: cantidad = cantidad del proveedor, factor 1.
--  Se guarda además lo SOLICITADO en la requisición (cantidad y costo) y, si el comprador aceptó
--  diferencias, quién, cuándo y su nota.
--  odc_generar se reescribe COMPLETA. Idempotente.
-- =====================================================================
begin;

do $$
begin
    if to_regclass('public.c_clave_unidad') is null then
        raise exception 'Primero carga los catálogos SAT (sql/2026-10-23_catalogos_sat_estructura.sql y …_datos_unidad.sql).';
    end if;
end $$;

alter table public.ordenes_compra_detalle
    add column if not exists cantidad_solicitada  numeric,
    add column if not exists costo_solicitado     numeric,
    add column if not exists cantidad_proveedor   numeric,
    add column if not exists clave_unidad_sat     text,
    add column if not exists clave_prod_serv_sat  text,
    add column if not exists precio_proveedor     numeric,
    add column if not exists importe_proveedor    numeric(14,2);

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'odc_detalle_unidad_sat_fk') then
        alter table public.ordenes_compra_detalle
            add constraint odc_detalle_unidad_sat_fk foreign key (clave_unidad_sat) references public.c_clave_unidad (clave);
    end if;
    if not exists (select 1 from pg_constraint where conname = 'odc_detalle_prod_serv_chk') then
        alter table public.ordenes_compra_detalle
            add constraint odc_detalle_prod_serv_chk check (clave_prod_serv_sat is null or clave_prod_serv_sat ~ '^[0-9]{8}$');
    end if;
end $$;

alter table public.ordenes_compra
    add column if not exists diferencias_cotizacion jsonb,
    add column if not exists diferencias_nota       text,
    add column if not exists diferencias_por        text,
    add column if not exists diferencias_en         timestamptz;

comment on column public.ordenes_compra_detalle.cantidad is 'Cantidad en la unidad del INVENTARIO (cantidad_proveedor x factor_conversion_proveedor).';
comment on column public.ordenes_compra_detalle.costo_unitario_estimado is 'Costo por unidad del INVENTARIO, 4 decimales (precio_proveedor ÷ factor). Derivado; el importe oficial es importe_proveedor.';
comment on column public.ordenes_compra_detalle.cantidad_proveedor is 'Cantidad cotizada en la unidad del proveedor (ej. 21.782 MIL).';
comment on column public.ordenes_compra_detalle.precio_proveedor is 'Precio por unidad del proveedor (ej. $3,004.00 por MIL).';
comment on column public.ordenes_compra_detalle.importe_proveedor is 'Importe OFICIAL de la partida: round(cantidad_proveedor x precio_proveedor, 2).';

create or replace function public.odc_generar(p_datos jsonb)
returns jsonb
language plpgsql
volatile
set search_path = public
as $$
declare
    v_req_id    bigint  := nullif(p_datos->>'requisicion_id', '')::bigint;
    v_prov      bigint  := nullif(p_datos->>'proveedor_id', '')::bigint;
    v_cond      text    := nullif(trim(p_datos->>'condicion_pago'), '');
    v_dias      integer := coalesce(nullif(p_datos->>'dias_credito', '')::integer, 0);
    v_pct       numeric(6,2) := nullif(p_datos->>'anticipo_pct', '')::numeric;
    v_cot_folio text    := nullif(trim(p_datos->>'cotizacion_folio'), '');
    v_cot_cont  text    := nullif(trim(p_datos->>'cotizacion_contacto'), '');
    v_cot_fecha date    := nullif(p_datos->>'cotizacion_fecha', '')::date;
    v_cot_vig   date    := nullif(p_datos->>'cotizacion_vigencia', '')::date;
    v_fecha_esp date    := nullif(p_datos->>'fecha_esperada', '')::date;
    v_notas_usr text    := nullif(trim(p_datos->>'notas'), '');
    v_dif       jsonb   := case when jsonb_typeof(p_datos->'diferencias') = 'array' and jsonb_array_length(p_datos->'diferencias') > 0
                                then p_datos->'diferencias' end;
    v_req       public.requisiciones_compra%rowtype;
    v_lineas    jsonb;
    v_ln        jsonb := '[]'::jsonb;
    l           jsonb;
    v_cant_prov numeric;
    v_precio    numeric;
    v_clave_um  text;
    v_factor    numeric;
    v_cant_int  numeric;
    v_costo_int numeric;
    v_importe   numeric(14,2);
    v_sub       numeric(14,2) := 0;
    v_total     numeric(14,2);
    v_anticipo  numeric(14,2);
    v_oc_id     bigint;
    v_folio     text;
begin
    -- ---- Encabezado ----
    if v_prov is null then raise exception 'Elige el proveedor con el que se va a comprar.'; end if;
    if v_cot_folio is null then raise exception 'Captura el N.º de cotización del proveedor.'; end if;
    if v_cot_cont is null then raise exception 'Captura el contacto que cotizó.'; end if;
    if v_cot_fecha is null or v_cot_vig is null then raise exception 'Captura la fecha de la cotización y hasta cuándo es vigente.'; end if;
    if v_cot_vig < v_cot_fecha then raise exception 'La vigencia de la cotización no puede ser anterior a su fecha.'; end if;
    if v_fecha_esp is null then raise exception 'Captura la fecha esperada de entrega.'; end if;
    if v_cond is null or v_cond not in ('contado', 'credito') then raise exception 'La condición de pago debe ser contado o crédito.'; end if;
    if v_cond = 'credito' then
        if v_dias not in (7, 15, 30, 60) then raise exception 'Elige el plazo de crédito (7, 15, 30 o 60 días).'; end if;
    else
        v_dias := 0;
    end if;
    if v_pct is not null and (v_pct < 0 or v_pct > 100) then raise exception 'El porcentaje de anticipo debe estar entre 0 y 100.'; end if;
    if not exists (select 1 from public.proveedores where id = v_prov) then raise exception 'El proveedor no existe.'; end if;

    -- ---- Partidas ----
    --  · Con requisición: producto, unidad y lo SOLICITADO salen de la requisición; de la pantalla vienen lo
    --    cotizado (cantidad, unidad SAT, clave SAT, número, descripción, precio y factor del proveedor).
    --  · Sin requisición (ODC manual): todo viene de la pantalla.
    if v_req_id is not null then
        select * into v_req from public.requisiciones_compra where id = v_req_id for update;
        if not found then raise exception 'La requisición % no existe.', v_req_id; end if;
        if v_req.estatus <> 'pendiente' then
            raise exception 'La requisición ya está en estatus "%": no se puede autorizar de nuevo.', v_req.estatus;
        end if;
        select jsonb_agg(jsonb_build_object(
                   'producto_id', d.producto_id, 'descripcion', d.descripcion,
                   'cant_solicitada', d.cantidad, 'costo_solicitado', d.costo_estimado,
                   'cant_prov', coalesce(nullif(o.x->>'cantidad_proveedor', '')::numeric, d.cantidad),
                   'precio_prov', coalesce(nullif(o.x->>'precio_proveedor', '')::numeric, nullif(o.x->>'costo', '')::numeric, d.costo_estimado),
                   'clave_um', upper(nullif(trim(o.x->>'clave_unidad_sat'), '')),
                   'clave_sat', nullif(trim(o.x->>'clave_prod_serv_sat'), ''),
                   'factor', nullif(o.x->>'factor_conversion_proveedor', '')::numeric,
                   'unidad_medida_id', d.unidad_medida_id, 'notas', d.notas,
                   'sku_proveedor', coalesce(nullif(trim(o.x->>'sku_proveedor'), ''), d.sku_proveedor),
                   'descripcion_proveedor', coalesce(nullif(trim(o.x->>'descripcion_proveedor'), ''), d.descripcion_proveedor),
                   'unidad_proveedor', coalesce(nullif(trim(o.x->>'unidad_proveedor'), ''), d.unidad_proveedor)) order by d.id)
          into v_lineas
          from public.requisiciones_compra_detalle d
          left join lateral (
                select e.x from jsonb_array_elements(coalesce(p_datos->'partidas', '[]'::jsonb)) as e(x)
                 where nullif(e.x->>'requisicion_detalle_id', '')::bigint = d.id limit 1) o on true
         where d.requisicion_id = v_req_id;
    else
        select jsonb_agg(jsonb_build_object(
                   'producto_id', nullif(e.x->>'producto_id', '')::bigint, 'descripcion', nullif(trim(e.x->>'descripcion'), ''),
                   'cant_solicitada', null, 'costo_solicitado', null,
                   'cant_prov', coalesce(nullif(e.x->>'cantidad_proveedor', '')::numeric, nullif(e.x->>'cantidad', '')::numeric),
                   'precio_prov', coalesce(nullif(e.x->>'precio_proveedor', '')::numeric, nullif(e.x->>'costo', '')::numeric),
                   'clave_um', upper(nullif(trim(e.x->>'clave_unidad_sat'), '')),
                   'clave_sat', nullif(trim(e.x->>'clave_prod_serv_sat'), ''),
                   'factor', nullif(e.x->>'factor_conversion_proveedor', '')::numeric,
                   'unidad_medida_id', nullif(e.x->>'unidad_medida_id', '')::bigint, 'notas', nullif(trim(e.x->>'notas'), ''),
                   'sku_proveedor', nullif(trim(e.x->>'sku_proveedor'), ''),
                   'descripcion_proveedor', nullif(trim(e.x->>'descripcion_proveedor'), ''),
                   'unidad_proveedor', nullif(trim(e.x->>'unidad_proveedor'), '')))
          into v_lineas
          from jsonb_array_elements(coalesce(p_datos->'partidas', '[]'::jsonb)) as e(x);
    end if;

    if v_lineas is null or jsonb_array_length(v_lineas) = 0 then raise exception 'La orden debe tener al menos una partida.'; end if;

    for l in select * from jsonb_array_elements(v_lineas)
    loop
        v_cant_prov := (l->>'cant_prov')::numeric;
        v_precio    := (l->>'precio_prov')::numeric;
        v_clave_um  := l->>'clave_um';
        v_factor    := (l->>'factor')::numeric;

        if coalesce(v_cant_prov, 0) <= 0 then raise exception 'Cada partida necesita la cantidad cotizada mayor a cero.'; end if;
        if coalesce(v_precio, 0) <= 0 then raise exception 'Captura el precio unitario cotizado de todas las partidas.'; end if;
        if (l->>'producto_id') is null and (l->>'descripcion') is null then raise exception 'Cada partida necesita un producto o una descripción.'; end if;
        if (l->>'clave_sat') is not null and (l->>'clave_sat') !~ '^[0-9]{8}$' then
            raise exception 'La clave SAT del producto debe tener 8 dígitos (partida "%").', coalesce(l->>'descripcion', l->>'sku_proveedor', 'sin nombre');
        end if;

        if v_clave_um is not null then
            if not exists (select 1 from public.c_clave_unidad where clave = v_clave_um) then
                raise exception 'La clave de unidad "%" no existe en el catálogo SAT.', v_clave_um;
            end if;
            -- Nunca se asume 1 a 1 en silencio: con unidad del proveedor, el factor es obligatorio.
            if coalesce(v_factor, 0) <= 0 then
                raise exception 'Captura el factor de la unidad % (cuántas unidades de tu inventario trae 1 %).', v_clave_um, v_clave_um;
            end if;
        else
            v_factor := 1;   -- sin unidad del proveedor la partida va en la unidad del inventario, como siempre
        end if;

        v_cant_int  := round(v_cant_prov * v_factor, 6);
        v_costo_int := round(v_precio / v_factor, 4);
        if v_cant_int <= 0 then raise exception 'La cantidad convertida a tu inventario quedó en cero; revisa el factor.'; end if;
        if v_costo_int <= 0 then raise exception 'El costo por unidad de tu inventario quedó en cero; revisa el factor o el precio.'; end if;

        v_importe := round(v_cant_prov * v_precio, 2);   -- importe OFICIAL de la partida (el del proveedor)
        v_sub := v_sub + v_importe;
        v_ln := v_ln || jsonb_build_array(l || jsonb_build_object(
                   'cantidad', v_cant_int, 'costo', v_costo_int, 'importe', v_importe, 'factor', v_factor));
    end loop;
    v_lineas   := v_ln;
    v_total    := round(v_sub * 1.16, 2);   -- IVA 16% estimado (el IVA real sale de la factura al recibir)
    v_anticipo := case when coalesce(v_pct, 0) > 0 then round(v_total * v_pct / 100, 2) else null end;

    -- ---- Orden de compra (ya autorizada: nace 'abierta') ----
    v_folio := public.siguiente_folio('ODC');
    insert into public.ordenes_compra (
        folio, proveedor_id, fecha, fecha_esperada, moneda_id, tipo_cambio, tipo_cambio_fuente, tipo_cambio_fecha,
        solicitante_empleado_id, estatus, notas,
        cotizacion_folio, cotizacion_contacto, cotizacion_telefono, cotizacion_email, cotizacion_fecha, cotizacion_vigencia,
        condicion_pago, dias_credito, forma_pago, anticipo_pct, anticipo_monto,
        diferencias_cotizacion, diferencias_nota, diferencias_por, diferencias_en)
    values (
        v_folio, v_prov, current_date, v_fecha_esp, nullif(p_datos->>'moneda_id', '')::bigint,
        nullif(p_datos->>'tipo_cambio', '')::numeric, nullif(p_datos->>'tipo_cambio_fuente', ''), nullif(p_datos->>'tipo_cambio_fecha', '')::date,
        nullif(p_datos->>'solicitante_empleado_id', '')::bigint, 'abierta',
        case when v_req_id is not null then 'Generada desde requisición ' || coalesce(v_req.folio, '#' || v_req_id) || coalesce(' · ' || v_notas_usr, '')
             else v_notas_usr end,
        v_cot_folio, v_cot_cont, nullif(trim(p_datos->>'cotizacion_telefono'), ''), nullif(trim(p_datos->>'cotizacion_email'), ''),
        v_cot_fecha, v_cot_vig,
        v_cond, v_dias, nullif(trim(p_datos->>'forma_pago'), ''), case when coalesce(v_pct, 0) > 0 then v_pct else null end, v_anticipo,
        v_dif, case when v_dif is not null then nullif(trim(p_datos->>'diferencias_nota'), '') end,
        case when v_dif is not null then nullif(trim(p_datos->>'revisada_por'), '') end,
        case when v_dif is not null then now() end)
    returning id into v_oc_id;

    insert into public.ordenes_compra_detalle (
        orden_compra_id, producto_id, descripcion, cantidad, cantidad_recibida, costo_unitario_estimado,
        unidad_medida_id, notas, sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor,
        cantidad_solicitada, costo_solicitado, cantidad_proveedor, clave_unidad_sat, clave_prod_serv_sat,
        precio_proveedor, importe_proveedor)
    select v_oc_id, (e.x->>'producto_id')::bigint, e.x->>'descripcion', (e.x->>'cantidad')::numeric, 0, (e.x->>'costo')::numeric,
           (e.x->>'unidad_medida_id')::bigint, e.x->>'notas', e.x->>'sku_proveedor', e.x->>'descripcion_proveedor',
           e.x->>'unidad_proveedor', case when e.x->>'clave_um' is not null then (e.x->>'factor')::numeric end,
           (e.x->>'cant_solicitada')::numeric, (e.x->>'costo_solicitado')::numeric, (e.x->>'cant_prov')::numeric,
           e.x->>'clave_um', e.x->>'clave_sat', (e.x->>'precio_prov')::numeric, (e.x->>'importe')::numeric
      from jsonb_array_elements(v_lineas) as e(x);

    if v_req_id is not null then
        update public.requisiciones_compra
           set estatus = 'autorizada', orden_compra_id = v_oc_id,
               revisada_por = nullif(trim(p_datos->>'revisada_por'), ''), revisada_en = now()
         where id = v_req_id;
    end if;

    return jsonb_build_object('oc_id', v_oc_id, 'oc_folio', v_folio, 'total_estimado', v_total, 'anticipo_monto', v_anticipo);
end;
$$;

revoke all     on function public.odc_generar(jsonb) from public, anon;
grant  execute on function public.odc_generar(jsonb) to authenticated;

commit;
