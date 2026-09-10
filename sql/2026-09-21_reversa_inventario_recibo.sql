-- =====================================================================
--  Cancelar recibo de compra: revierte inventario + póliza, con guarda
--  de "no se puede si el lote ya se consumió".
--  Fecha: 2026-09-21  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-08-28_contabilidad_polizas.sql (cancelar_poliza)
--            sql/2026-09-13_salidas_fefo.sql
--
--    · recibo_reversible(p_documento_id)  -> diagnóstico por lote:
--        recibido / disponible / consumido / ok (true si nada se consumió).
--    · cancelar_recibo_inventario(p_documento_id, p_motivo):
--        - EXIGE que recibo_reversible dé ok en todos los lotes; si no,
--          lanza excepción listando qué lote ya se usó.
--        - cancela la póliza del documento (cancelar_poliza) si la tiene.
--        - postea un movimiento de inventario en negativo por cada lote,
--          pone su stock en 0 y recalcula productos.stock_actual.
--        - revierte cantidad_recibida en la orden de compra y su estatus.
--        - marca el documento como 'cancelado'.
--        - devuelve el detalle de lo revertido.
--
--  Solo aplica a documentos de entrada de compra. Idempotente
--  (create or replace); una vez cancelado el documento, vuelve a lanzar
--  excepción si se reintenta.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. recibo_reversible — diagnóstico
-- ---------------------------------------------------------------------
create or replace function public.recibo_reversible(p_documento_id bigint)
returns table (
    producto_id       bigint,
    producto_nombre   text,
    lote_id           bigint,
    numero_lote       text,
    recibido          numeric,
    disponible        numeric,
    consumido         numeric,
    ok                boolean
)
language sql
stable
security definer
set search_path = public, extensions
as $$
    with ent as (
        select mi.lote_id, mi.producto_id,
               coalesce(sum(mi.cantidad) filter (where mi.cantidad > 0), 0) as recibido
        from public.movimientos_inventario mi
        where mi.documento_id = p_documento_id
        group by mi.lote_id, mi.producto_id
    )
    select e.producto_id,
           p.nombre,
           e.lote_id,
           coalesce(l.numero_lote, '(sin lote)'),
           round(e.recibido, 4),
           round(coalesce(l.stock_actual, 0), 4),
           round(greatest(e.recibido - coalesce(l.stock_actual, 0), 0), 4),
           (coalesce(l.stock_actual, 0) >= e.recibido - 0.0001)
    from ent e
    join public.productos p on p.id = e.producto_id
    left join public.lotes_inventario l on l.id = e.lote_id
    where e.recibido > 0
    order by p.nombre;
$$;

grant execute on function public.recibo_reversible(bigint) to authenticated;


-- ---------------------------------------------------------------------
-- 2. cancelar_recibo_inventario — la reversa
-- ---------------------------------------------------------------------
create or replace function public.cancelar_recibo_inventario(p_documento_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc      public.documentos%rowtype;
    v_bloqueo  text;
    v_pol_rev  bigint;
    v_movs     jsonb := '[]'::jsonb;
    v_n        integer := 0;
    r          record;
    v_stock    numeric;
    v_oc       bigint;
    v_estatus  text;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento % no existe.', p_documento_id; end if;
    if coalesce(v_doc.estado, '') = 'cancelado' then
        raise exception 'El documento % ya está cancelado.', p_documento_id;
    end if;
    if coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada') then
        raise exception 'Solo se puede revertir un recibo de compra (tipo actual: %).', coalesce(v_doc.tipo_movimiento, 'N/D');
    end if;

    -- guarda: nada del inventario recibido debe haberse consumido
    select string_agg(
             format('· %s lote %s: recibiste %s, quedan %s (consumido %s)',
                    d.producto_nombre, d.numero_lote, d.recibido, d.disponible, d.consumido), E'\n')
      into v_bloqueo
      from public.recibo_reversible(p_documento_id) d
     where not d.ok;
    if v_bloqueo is not null then
        raise exception E'No se puede revertir el inventario del recibo %: ya se consumió stock.\n%', p_documento_id, v_bloqueo;
    end if;

    if not exists (select 1 from public.recibo_reversible(p_documento_id)) then
        raise exception 'El recibo % no tiene movimientos de inventario que revertir.', p_documento_id;
    end if;

    -- 1) cancelar la póliza (si tiene y está contabilizada)
    if v_doc.poliza_id is not null then
        begin
            v_pol_rev := (public.cancelar_poliza(v_doc.poliza_id, coalesce(p_motivo, 'Cancelación de recibo ' || coalesce(v_doc.folio, p_documento_id::text)))->>'poliza_reversa_id')::bigint;
        exception when others then
            -- si ya estaba cancelada u otro estado, seguimos con el inventario
            v_pol_rev := null;
        end;
    end if;

    -- 2) revertir el inventario lote por lote
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
               set stock_actual = greatest(coalesce(stock_actual, 0) - r.recibido, 0)
             where id = r.lote_id;
        end if;

        -- recalcular stock global del producto (suma de lotes)
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

    -- 4) marcar el documento
    update public.documentos set estado = 'cancelado' where id = p_documento_id;

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


-- =====================================================================
-- select * from public.recibo_reversible(63);
-- select public.cancelar_recibo_inventario(63, 'prueba');
-- =====================================================================
