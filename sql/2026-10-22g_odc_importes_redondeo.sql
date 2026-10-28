-- =====================================================================
--  ODC: el importe de cada partida se redondea a 2 decimales ANTES de sumar.
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Regla acordada con el usuario (costos unitarios hasta diezmilésimas):
--    importe de partida = round(cantidad x costo, 2)   (redondeo comercial: 5 sube)
--    subtotal = suma de esos importes · IVA 16 % y total = round(subtotal x 1.16, 2)
--    (igual a subtotal + round(subtotal x 0.16, 2) porque el subtotal ya tiene 2 decimales).
--  Antes el subtotal acumulaba cantidad x costo SIN redondear cada partida (y lo recortaba a
--  2 decimales en cada suma por la variable numeric(14,2)), lo que podía diferir un centavo de lo
--  impreso. odc_generar se reescribe COMPLETA (única diferencia: esa línea).
--  Idempotente (create or replace).
-- =====================================================================

begin;

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
    v_req       public.requisiciones_compra%rowtype;
    v_lineas    jsonb;
    l           jsonb;
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

    -- ---- Partidas: de la requisición (cantidad fija; solo costo y SKU proveedor vienen de la pantalla)
    --      o capturadas a mano (ODC sin requisición) ----
    if v_req_id is not null then
        select * into v_req from public.requisiciones_compra where id = v_req_id for update;
        if not found then raise exception 'La requisición % no existe.', v_req_id; end if;
        if v_req.estatus <> 'pendiente' then
            raise exception 'La requisición ya está en estatus "%": no se puede autorizar de nuevo.', v_req.estatus;
        end if;
        select jsonb_agg(jsonb_build_object(
                   'producto_id', d.producto_id, 'descripcion', d.descripcion, 'cantidad', d.cantidad,
                   'costo', coalesce(nullif(o.x->>'costo', '')::numeric, d.costo_estimado),
                   'unidad_medida_id', d.unidad_medida_id, 'notas', d.notas,
                   'sku_proveedor', coalesce(nullif(trim(o.x->>'sku_proveedor'), ''), d.sku_proveedor),
                   'descripcion_proveedor', d.descripcion_proveedor, 'unidad_proveedor', d.unidad_proveedor,
                   'factor', d.factor_conversion_proveedor) order by d.id)
          into v_lineas
          from public.requisiciones_compra_detalle d
          left join lateral (
                select e.x from jsonb_array_elements(coalesce(p_datos->'partidas', '[]'::jsonb)) as e(x)
                 where nullif(e.x->>'requisicion_detalle_id', '')::bigint = d.id limit 1) o on true
         where d.requisicion_id = v_req_id;
    else
        select jsonb_agg(jsonb_build_object(
                   'producto_id', nullif(e.x->>'producto_id', '')::bigint, 'descripcion', nullif(trim(e.x->>'descripcion'), ''),
                   'cantidad', nullif(e.x->>'cantidad', '')::numeric, 'costo', nullif(e.x->>'costo', '')::numeric,
                   'unidad_medida_id', nullif(e.x->>'unidad_medida_id', '')::bigint, 'notas', nullif(trim(e.x->>'notas'), ''),
                   'sku_proveedor', nullif(trim(e.x->>'sku_proveedor'), ''),
                   'descripcion_proveedor', nullif(trim(e.x->>'descripcion_proveedor'), ''),
                   'unidad_proveedor', nullif(trim(e.x->>'unidad_proveedor'), ''),
                   'factor', nullif(e.x->>'factor_conversion_proveedor', '')::numeric))
          into v_lineas
          from jsonb_array_elements(coalesce(p_datos->'partidas', '[]'::jsonb)) as e(x);
    end if;

    if v_lineas is null or jsonb_array_length(v_lineas) = 0 then raise exception 'La orden debe tener al menos una partida.'; end if;
    for l in select * from jsonb_array_elements(v_lineas)
    loop
        if coalesce((l->>'cantidad')::numeric, 0) <= 0 then raise exception 'Cada partida necesita una cantidad mayor a cero.'; end if;
        if coalesce((l->>'costo')::numeric, 0) <= 0 then raise exception 'Captura el costo unitario cotizado de todas las partidas.'; end if;
        if (l->>'producto_id') is null and (l->>'descripcion') is null then raise exception 'Cada partida necesita un producto o una descripción.'; end if;
        v_sub := v_sub + round((l->>'cantidad')::numeric * (l->>'costo')::numeric, 2);   -- importe de CADA partida a 2 decimales (redondeo comercial); el subtotal suma esos importes
    end loop;
    v_total    := round(v_sub * 1.16, 2);   -- IVA 16% estimado (el IVA real sale de la factura al recibir)
    v_anticipo := case when coalesce(v_pct, 0) > 0 then round(v_total * v_pct / 100, 2) else null end;

    -- ---- Orden de compra (ya autorizada: nace 'abierta') ----
    v_folio := public.siguiente_folio('ODC');
    insert into public.ordenes_compra (
        folio, proveedor_id, fecha, fecha_esperada, moneda_id, tipo_cambio, tipo_cambio_fuente, tipo_cambio_fecha,
        solicitante_empleado_id, estatus, notas,
        cotizacion_folio, cotizacion_contacto, cotizacion_telefono, cotizacion_email, cotizacion_fecha, cotizacion_vigencia,
        condicion_pago, dias_credito, forma_pago, anticipo_pct, anticipo_monto)
    values (
        v_folio, v_prov, current_date, v_fecha_esp, nullif(p_datos->>'moneda_id', '')::bigint,
        nullif(p_datos->>'tipo_cambio', '')::numeric, nullif(p_datos->>'tipo_cambio_fuente', ''), nullif(p_datos->>'tipo_cambio_fecha', '')::date,
        nullif(p_datos->>'solicitante_empleado_id', '')::bigint, 'abierta',
        case when v_req_id is not null then 'Generada desde requisición ' || coalesce(v_req.folio, '#' || v_req_id) || coalesce(' · ' || v_notas_usr, '')
             else v_notas_usr end,
        v_cot_folio, v_cot_cont, nullif(trim(p_datos->>'cotizacion_telefono'), ''), nullif(trim(p_datos->>'cotizacion_email'), ''),
        v_cot_fecha, v_cot_vig,
        v_cond, v_dias, nullif(trim(p_datos->>'forma_pago'), ''), case when coalesce(v_pct, 0) > 0 then v_pct else null end, v_anticipo)
    returning id into v_oc_id;

    insert into public.ordenes_compra_detalle (
        orden_compra_id, producto_id, descripcion, cantidad, cantidad_recibida, costo_unitario_estimado,
        unidad_medida_id, notas, sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor)
    select v_oc_id, (e.x->>'producto_id')::bigint, e.x->>'descripcion', (e.x->>'cantidad')::numeric, 0, (e.x->>'costo')::numeric,
           (e.x->>'unidad_medida_id')::bigint, e.x->>'notas', e.x->>'sku_proveedor', e.x->>'descripcion_proveedor',
           e.x->>'unidad_proveedor', (e.x->>'factor')::numeric
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
