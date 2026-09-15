-- =====================================================================
--  Editar líneas de una recepción ya capturada (solo admin) + candado
--  para no volver a recibir por accidente la misma orden de compra
--  Fecha: 2026-09-25  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-02_ordenes_compra.sql
--            sql/2026-09-21_reversa_inventario_recibo.sql  (recibo_reversible)
--
--  Caso real que lo motiva: se capturaron 2 recepciones para la misma
--  orden de compra (mismo folio del proveedor) porque no había forma de
--  corregir una partida mal capturada sin volver a recibir todo.
--
--  Agrega:
--   - Catálogo 'ajuste_recepcion' en tipos_movimiento (para el
--     movimiento de inventario que deja el ajuste).
--   - RPC editar_lineas_recepcion(documento_id, lineas): corrige
--     cantidad/costo de una o más partidas YA capturadas, ajustando el
--     lote, el stock del producto, la orden de compra y dejando su
--     propio movimiento de inventario como rastro. Solo 'authenticated'
--     (nunca 'anon') — el operador del móvil no tiene forma de llegar
--     aquí, esto vive únicamente en la pantalla de admin.
--   - Bloqueada si la recepción ya está contabilizada (tiene póliza) o
--     si ya se consumió inventario del lote que se quiere reducir — en
--     esos casos hay que cancelar_recibo_inventario primero.
--
--  El candado de "aviso" al seleccionar una OC que ya tiene una
--  recepción capturada (para no volver a recibirla por accidente) es
--  de interfaz (ordenes-compra.js) y no requiere SQL aparte — ya puede
--  consultarse con un simple select a documentos por orden_compra_id.
--
--  Idempotente.
-- =====================================================================

begin;

insert into public.tipos_movimiento (codigo, nombre, naturaleza)
values ('ajuste_recepcion', 'Ajuste de líneas de una recepción', 'neutro')
on conflict (codigo) do nothing;

create or replace function public.editar_lineas_recepcion(p_documento_id bigint, p_lineas jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    r            jsonb;
    v_det        public.documento_detalles%rowtype;
    v_lote       public.lotes_inventario%rowtype;
    v_cant_nueva numeric;
    v_costo_nuevo numeric;
    v_delta      numeric;
    v_stock_ant  numeric;
    v_stock_res  numeric;
    v_oc         bigint;
    v_estatus    text;
    v_n          integer := 0;
    v_resultado  jsonb := '[]'::jsonb;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento % no existe.', p_documento_id; end if;
    if coalesce(v_doc.estado, '') = 'cancelado' then
        raise exception 'El documento % ya está cancelado.', p_documento_id;
    end if;
    if coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada') then
        raise exception 'Solo se pueden editar líneas de un recibo de compra (tipo actual: %).', coalesce(v_doc.tipo_movimiento, 'N/D');
    end if;
    if v_doc.poliza_id is not null then
        raise exception 'Esta recepción ya está contabilizada (póliza %). Cancélala primero (cancelar_recibo_inventario) si necesitas corregir cantidades o costos, y vuelve a capturarla.', v_doc.poliza_id;
    end if;

    if p_lineas is null or jsonb_typeof(p_lineas) <> 'array' or jsonb_array_length(p_lineas) < 1 then
        raise exception 'No se recibieron líneas para editar.';
    end if;

    v_oc := v_doc.orden_compra_id;

    for r in select * from jsonb_array_elements(p_lineas)
    loop
        select * into v_det
          from public.documento_detalles
         where id = (r->>'documento_detalle_id')::bigint
           and documento_id = p_documento_id;
        if not found then
            raise exception 'La línea % no pertenece a este documento.', r->>'documento_detalle_id';
        end if;

        v_cant_nueva := round(coalesce((r->>'cantidad')::numeric, v_det.cantidad), 4);
        v_costo_nuevo := round(coalesce((r->>'costo_unitario')::numeric, v_det.costo_unitario), 4);
        if v_cant_nueva < 0 then raise exception 'La cantidad de una línea no puede ser negativa.'; end if;
        if v_costo_nuevo < 0 then raise exception 'El costo de una línea no puede ser negativo.'; end if;

        v_delta := round(v_cant_nueva - coalesce(v_det.cantidad, 0), 4);

        if v_delta <> 0 then
            if v_det.lote_id is not null then
                select * into v_lote from public.lotes_inventario where id = v_det.lote_id;
                if not found then raise exception 'El lote de la línea % ya no existe.', v_det.id; end if;

                v_stock_ant := coalesce(v_lote.stock_actual, 0);
                v_stock_res := v_stock_ant + v_delta;
                if v_stock_res < -0.0001 then
                    raise exception 'No se puede reducir la línea % a %: ya se consumieron % (de % recibidas originalmente); el mínimo al que puedes bajarla es %.',
                        v_det.id, v_cant_nueva, round(coalesce(v_det.cantidad, 0) - v_stock_ant, 4), v_det.cantidad,
                        round(coalesce(v_det.cantidad, 0) - v_stock_ant, 4);
                end if;
                v_stock_res := greatest(v_stock_res, 0);

                update public.lotes_inventario
                   set stock_actual = v_stock_res,
                       costo_unitario = v_costo_nuevo
                 where id = v_det.lote_id;

                update public.productos p
                   set stock_actual = (select coalesce(sum(stock_actual), 0) from public.lotes_inventario where producto_id = p.id)
                 where p.id = v_det.producto_id;
            else
                select coalesce(stock_actual, 0) into v_stock_ant from public.productos where id = v_det.producto_id;
                v_stock_res := v_stock_ant + v_delta;
                if v_stock_res < -0.0001 then
                    raise exception 'No se puede reducir la línea % a %: ya se consumió ese inventario (solo quedan % disponibles).',
                        v_det.id, v_cant_nueva, v_stock_ant;
                end if;
                v_stock_res := greatest(v_stock_res, 0);
                update public.productos set stock_actual = v_stock_res where id = v_det.producto_id;
            end if;

            insert into public.movimientos_inventario
                (producto_id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, documento_id, lote_id)
            values (
                v_det.producto_id, 'ajuste_recepcion', v_delta,
                v_stock_ant, v_stock_res, v_costo_nuevo, p_documento_id, v_det.lote_id
            );

            -- refleja el mismo delta en lo ya recibido de la orden de compra
            if v_oc is not null then
                update public.ordenes_compra_detalle ocd
                   set cantidad_recibida = greatest(coalesce(ocd.cantidad_recibida, 0) + v_delta, 0)
                 where ocd.orden_compra_id = v_oc and ocd.producto_id = v_det.producto_id;
            end if;
        elsif v_costo_nuevo <> coalesce(v_det.costo_unitario, 0) and v_det.lote_id is not null then
            -- solo cambió el costo, no la cantidad: igual se actualiza el costo del lote
            update public.lotes_inventario set costo_unitario = v_costo_nuevo where id = v_det.lote_id;
        end if;

        update public.documento_detalles
           set cantidad = v_cant_nueva, costo_unitario = v_costo_nuevo, subtotal = round(v_cant_nueva * v_costo_nuevo, 2)
         where id = v_det.id;

        v_n := v_n + 1;
        v_resultado := v_resultado || jsonb_build_object(
            'documento_detalle_id', v_det.id, 'cantidad_anterior', v_det.cantidad, 'cantidad_nueva', v_cant_nueva,
            'costo_anterior', v_det.costo_unitario, 'costo_nuevo', v_costo_nuevo);
    end loop;

    if v_oc is not null then
        select case
                 when bool_and(coalesce(cantidad_recibida, 0) >= coalesce(cantidad, 0)) then 'recibida'
                 when bool_and(coalesce(cantidad_recibida, 0) = 0) then 'abierta'
                 else 'recibida_parcial'
               end
          into v_estatus
          from public.ordenes_compra_detalle where orden_compra_id = v_oc;
        update public.ordenes_compra set estatus = coalesce(v_estatus, estatus) where id = v_oc;
    end if;

    return jsonb_build_object('documento_id', p_documento_id, 'lineas_editadas', v_n, 'detalle', v_resultado);
end $$;

revoke all     on function public.editar_lineas_recepcion(bigint, jsonb) from public, anon;
grant  execute on function public.editar_lineas_recepcion(bigint, jsonb) to authenticated;

commit;
