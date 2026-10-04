-- =====================================================================
--  Cierre de órdenes de producción — ENTREGA 2 de 3: función atómica
--  Fecha: 2026-11-07  ·  Proyecto: Hares de México (Supabase)
--
--  Hasta ahora cerrarOrdenDeProduccion (js/produccion.js) hacía el cierre
--  desde el navegador en ~15 llamadas sueltas: si algo fallaba a la mitad
--  quedaban documentos vacíos o insumos descontados sin entrada al terminado.
--  Esta función hace TODO el cierre en UNA sola transacción: o se cierra
--  completo o no se toca nada. Es la única versión del cálculo: el botón
--  "🔒 Cerrar orden" (y en la entrega 3 el cierre automático) la llaman.
--
--  Reproduce exactamente el cierre actual:
--   1. Cierra cronómetros abiertos de la orden.
--   2. Mano de obra = Σ (horas del empleado × costo_hora_snapshot) por proceso.
--   3. Re-valida existencias con la MISMA cuenta de la vista
--      v_ot_orden_componentes (rendimiento del lote + conversión de unidades/
--      densidad vía factor_conversion_bom). Si falta algo: error, no se escribe nada.
--   4. Documento de salida PROD-…-MP (consumo de MP, PEPS) y de entrada PROD-…
--   5. Entrada del terminado con costo unitario = (MP + MO) ÷ cantidad real.
--   6. Marca la orden 'cerrada' (cantidad_producida = lo REAL, cantidad_planeada
--      = lo pedido) y genera la póliza con contabilizar_produccion(); si la
--      póliza falla NO se revierte el cierre (igual que antes) y se avisa.
--
--  p_cantidad_real: null = se cierra con lo planeado (como el botón).
--  Devuelve jsonb { ok, mensaje, costo_unitario, poliza_id, aviso_contable }.
--  Requiere sql/2026-09-22 (registrar_salida_fifo), 2026-10-21 (folios) y
--  2026-10-31 (factor_conversion_bom). Idempotente. No toca datos al correrse.
-- =====================================================================
begin;

alter table public.ordenes_produccion add column if not exists cantidad_planeada numeric;

create or replace function public.cerrar_orden_produccion(p_orden_id bigint, p_cantidad_real numeric default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_orden        record;
    v_cant_plan    numeric;
    v_cant_obt     numeric;
    v_lote         text;
    v_rend         numeric;
    v_factor_lote  numeric;
    v_mo           numeric := 0;
    v_emps         int;
    v_falt         text := '';
    v_folio        text;
    v_doc_sal      bigint;
    v_doc_ent      bigint;
    v_mat          numeric := 0;
    v_cu_final     numeric;
    v_lote_id      bigint;
    v_pol          jsonb;
    v_poliza_id    bigint;
    v_aviso        text := null;
    r              record;
    c              record;
    s              record;
    v_hay_salida   boolean;
begin
    select id, producto_id, cantidad_producida, numero_lote, estado
      into v_orden
      from public.ordenes_produccion
     where id = p_orden_id
     for update;
    if not found then raise exception 'Orden no encontrada.'; end if;
    if v_orden.estado <> 'en_proceso' then
        raise exception 'La orden ya está "%".', v_orden.estado;
    end if;

    v_cant_plan := coalesce(v_orden.cantidad_producida, 0);
    v_lote := trim(coalesce(v_orden.numero_lote, ''));
    if v_cant_plan <= 0 or v_lote = '' then
        raise exception 'La orden no tiene cantidad o lote válidos.';
    end if;
    v_cant_obt := case when coalesce(p_cantidad_real, 0) > 0 then p_cantidad_real else v_cant_plan end;

    -- 1) cronómetros abiertos
    update public.registros_tiempo rt
       set fin = now()
      from public.orden_produccion_procesos p
     where rt.orden_produccion_proceso_id = p.id
       and p.orden_produccion_id = p_orden_id
       and rt.fin is null;

    -- 2) mano de obra (por proceso y total)
    update public.orden_produccion_procesos p
       set segundos_transcurridos = x.seg, costo_calculado = x.costo
      from (
        select p2.id,
               round(coalesce(sum(extract(epoch from (rt.fin - rt.inicio))), 0)) as seg,
               coalesce(sum(extract(epoch from (rt.fin - rt.inicio)) / 3600.0
                            * coalesce(e.costo_hora_snapshot, 0)), 0) as costo
          from public.orden_produccion_procesos p2
          left join public.registros_tiempo rt on rt.orden_produccion_proceso_id = p2.id
          left join public.orden_produccion_proceso_empleados e
                 on e.orden_produccion_proceso_id = p2.id and e.empleado_id = rt.empleado_id
         where p2.orden_produccion_id = p_orden_id
         group by p2.id
      ) x
     where p.id = x.id;

    select coalesce(sum(costo_calculado), 0) into v_mo
      from public.orden_produccion_procesos where orden_produccion_id = p_orden_id;
    select count(distinct rt.empleado_id) into v_emps
      from public.registros_tiempo rt
      join public.orden_produccion_procesos p on p.id = rt.orden_produccion_proceso_id
     where p.orden_produccion_id = p_orden_id;

    -- 3) requerimientos (misma cuenta que v_ot_orden_componentes / calcularRequerimientosProduccion)
    if not exists (select 1 from public.bom where producto_id = v_orden.producto_id) then
        raise exception 'El producto seleccionado no tiene una fórmula o BOM registrada.';
    end if;
    select case when coalesce(rendimiento_lote_bom, 0) > 0 then rendimiento_lote_bom end
      into v_rend from public.productos where id = v_orden.producto_id;
    v_factor_lote := case when v_rend is not null then v_cant_plan / v_rend else v_cant_plan end;

    create temporary table if not exists _cop_req (
        componente_id bigint, nombre text, unidad text, costo_cat numeric, requerido numeric, disponible numeric
    ) on commit drop;
    truncate _cop_req;

    insert into _cop_req
    select pc.id, pc.nombre, umc.nombre, coalesce(pc.costo_unitario, 0),
           sum(b.cantidad_requerida * v_factor_lote
               * public.factor_conversion_bom(b.unidad_medida::text, umb.nombre, pc.unidad_medida_id::text,
                                              umc.nombre, b.cantidad_requerida, pc.densidad_kg_l)),
           coalesce((select sum(l.stock_actual) from public.lotes_inventario l where l.producto_id = pc.id), 0)
      from public.bom b
      join public.productos pc on pc.id = b.componente_id
      left join public.unidades_medida umc on umc.id = pc.unidad_medida_id
      left join public.unidades_medida umb on umb.id::text = trim(b.unidad_medida::text)
     where b.producto_id = v_orden.producto_id
     group by pc.id, pc.nombre, umc.nombre, pc.costo_unitario;

    for r in select * from _cop_req where disponible + 0.000001 < requerido order by nombre loop
        v_falt := v_falt || E'\n' || '• ' || r.nombre || ': requiere ' || round(r.requerido, 4)
                  || ' ' || coalesce(r.unidad, '') || ', hay ' || round(r.disponible, 4)
                  || ' (faltan ' || round(r.requerido - r.disponible, 4) || ')';
    end loop;
    if v_falt <> '' then
        raise exception 'Existencias insuficientes. La orden sigue en proceso:%', v_falt;
    end if;

    -- 4) documentos
    v_folio := public.siguiente_folio('PROD');
    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('salida_produccion', v_folio || '-MP', now(),
            'Consumo de materia prima — orden de producción, lote ' || v_lote, 'completado')
    returning id into v_doc_sal;
    insert into public.documentos (tipo_movimiento, folio, fecha_emision, descripcion, estado)
    values ('entrada_produccion', v_folio, now(),
            'Cierre de orden de producción — lote ' || v_lote || ' (consumo de materia prima: documento ' || v_folio || '-MP)',
            'completado')
    returning id into v_doc_ent;

    -- consumo PEPS por insumo
    for c in select * from _cop_req order by componente_id loop
        v_hay_salida := false;
        for s in select * from public.registrar_salida_fifo(c.componente_id, c.requerido, 'salida_produccion', v_doc_sal, null) loop
            v_hay_salida := true;
            v_mat := v_mat + coalesce(s.cantidad, 0) * coalesce(s.costo_unitario, c.costo_cat);
        end loop;
        if not v_hay_salida then
            v_mat := v_mat + c.requerido * c.costo_cat;
        end if;
    end loop;

    -- 5) entrada del terminado
    v_cu_final := (v_mat + v_mo) / v_cant_obt;
    perform public.registrar_movimiento_inventario_fifo(
        v_orden.producto_id, v_cant_obt, 'entrada_produccion', v_doc_ent, v_cu_final, v_lote);

    select id into v_lote_id from public.lotes_inventario
     where producto_id = v_orden.producto_id and numero_lote = v_lote and documento_id = v_doc_ent
     limit 1;

    insert into public.documento_detalles (documento_id, producto_id, lote_id, cantidad, costo_unitario, subtotal)
    values (v_doc_ent, v_orden.producto_id, v_lote_id, v_cant_obt, v_cu_final, v_cu_final * v_cant_obt);

    update public.productos set costo_unitario = v_cu_final where id = v_orden.producto_id;

    -- 6) cerrar la orden
    update public.ordenes_produccion
       set estado = 'cerrada',
           cerrada_at = now(),
           costo_unitario_final = v_cu_final,
           costo_total_materiales = v_mat,
           costo_total_mano_obra = v_mo,
           empleados_involucrados = v_emps,
           cantidad_producida = v_cant_obt,
           cantidad_planeada = v_cant_plan
     where id = p_orden_id;

    -- póliza: si falla, el cierre ya hecho se conserva (igual que antes) y se avisa
    begin
        v_pol := public.contabilizar_produccion(v_doc_ent, jsonb_build_object(
                    'costo_materiales', v_mat,
                    'costo_mano_obra', v_mo,
                    'orden_produccion_id', p_orden_id,
                    'documento_salida_id', v_doc_sal));
        v_poliza_id := nullif(v_pol ->> 'poliza_id', '')::bigint;
        if v_poliza_id is not null then
            update public.documentos set poliza_id = v_poliza_id where id = v_doc_sal;
        end if;
    exception
        when undefined_function then null;   -- módulo contable no instalado
        when others then
            v_aviso := sqlerrm;
    end;

    return jsonb_build_object(
        'ok', true,
        'orden_id', p_orden_id,
        'costo_unitario', v_cu_final,
        'costo_materiales', v_mat,
        'costo_mano_obra', v_mo,
        'cantidad_planeada', v_cant_plan,
        'cantidad_obtenida', v_cant_obt,
        'poliza_id', v_poliza_id,
        'aviso_contable', v_aviso
    );
end;
$$;

revoke all on function public.cerrar_orden_produccion(bigint, numeric) from public, anon;
grant execute on function public.cerrar_orden_produccion(bigint, numeric) to authenticated;

commit;
