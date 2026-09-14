-- =====================================================================
--  Candados de pre-cierre para el cierre de periodo contable
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  Este archivo NO lo ejecuta la app. Pegar y correr A MANO en:
--    Supabase -> SQL Editor
--
--  Requiere: sql/2026-09-22_fix_hallazgos_seguridad_contabilidad.sql
--            (crea periodos_contables, cerrar_periodo_contable,
--             bitacora_cambios)
--
--  cerrar_periodo_contable() cerraba el mes sin revisar nada. Esto
--  agrega los motivos comunes de contabilidad que normalmente impiden
--  un cierre de mes limpio:
--
--   1. Compras/ventas (documentos) del periodo sin llevar a póliza.
--   2. Gastos del periodo sin llevar a póliza.
--   3. Nóminas del periodo todavía en borrador (sin autorizar).
--   4. Nóminas "registradas" sin póliza asociada (dato inconsistente).
--   5. Cobros a clientes del periodo sin llevar a póliza.
--   6. Pagos a proveedores del periodo sin llevar a póliza.
--   7. Auditorías de inventario del periodo abiertas (conteo físico
--      pendiente de cerrar/conciliar).
--   8. Pólizas del periodo con cargos <> abonos (defensivo: no debería
--      pasar por cómo valida registrar_poliza, pero cubre datos viejos).
--
--  cerrar_periodo_contable(anio, mes) ahora corre estos candados antes
--  de cerrar y, si encuentra algo, RECHAZA el cierre mostrando la lista
--  de pendientes. Si de verdad se necesita cerrar con pendientes
--  (decisión de negocio), se llama con forzar=true; en ese caso el
--  cierre sí ocurre, pero la lista de advertencias que se ignoraron
--  queda guardada en periodos_contables.advertencias_forzadas y, por el
--  trigger ya existente, en bitacora_cambios — no es un cierre "silencioso".
--
--  precierre_periodo_contable(anio, mes) deja revisar los candados SIN
--  intentar cerrar, para usarlo como checklist antes de decidir.
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.periodos_contables
    add column if not exists advertencias_forzadas jsonb;

-- ---------------------------------------------------------------------
-- Candados: junta todos los pendientes de un periodo en un jsonb array.
-- Cada elemento: { motivo, descripcion, cantidad, detalle: [...] }.
-- Vacío = periodo limpio, listo para cerrar.
-- ---------------------------------------------------------------------
create or replace function public._candados_cierre_periodo(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_desde    date := make_date(p_anio, p_mes, 1);
    v_hasta    date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
    v_candados jsonb := '[]'::jsonb;
    v_cant     integer;
    v_detalle  jsonb;
begin
    -- 1. Compras / ventas capturadas sin llevar a póliza
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'documento_id', d.id, 'folio', d.folio, 'tipo', d.tipo_movimiento) order by d.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.documentos d
     where d.fecha_emision::date between v_desde and v_hasta
       and d.tipo_movimiento in ('entrada_compra', 'salida_venta')
       and coalesce(d.estado, '') <> 'cancelado'
       and d.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'documentos_sin_poliza',
            'descripcion', v_cant || ' documento(s) de compra/venta del periodo sin contabilizar (sin póliza).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 2. Gastos del periodo sin llevar a póliza
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'gasto_id', g.id, 'concepto', g.concepto) order by g.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.gastos g
     where g.fecha between v_desde and v_hasta
       and g.estatus <> 'cancelado'
       and g.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'gastos_sin_poliza',
            'descripcion', v_cant || ' gasto(s) del periodo sin contabilizar (sin póliza).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 3. Nóminas del periodo aún en borrador
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'nomina_id', n.id, 'periodo_inicio', n.periodo_inicio, 'periodo_fin', n.periodo_fin) order by n.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.nominas n
     where n.fecha_pago between v_desde and v_hasta
       and n.estatus = 'borrador';
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'nominas_borrador',
            'descripcion', v_cant || ' nómina(s) del periodo todavía en borrador (falta autorizar).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 4. Nóminas "registradas" sin póliza asociada (inconsistencia)
    select count(*), coalesce(jsonb_agg(jsonb_build_object('nomina_id', n.id) order by n.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.nominas n
     where n.fecha_pago between v_desde and v_hasta
       and n.estatus = 'registrada'
       and n.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'nominas_sin_poliza',
            'descripcion', v_cant || ' nómina(s) registrada(s) sin póliza asociada (revisar antes de cerrar).',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 5. Cobros a clientes del periodo sin llevar a póliza
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'cobro_id', c.id, 'referencia', c.referencia) order by c.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.cobros_cliente c
     where c.fecha between v_desde and v_hasta
       and c.estatus <> 'cancelado'
       and c.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'cobros_sin_poliza',
            'descripcion', v_cant || ' cobro(s) a clientes del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 6. Pagos a proveedores del periodo sin llevar a póliza
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'pago_id', p.id, 'referencia', p.referencia) order by p.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.pagos_proveedor p
     where p.fecha between v_desde and v_hasta
       and p.estatus <> 'cancelado'
       and p.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'pagos_sin_poliza',
            'descripcion', v_cant || ' pago(s) a proveedores del periodo sin contabilizar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 7. Auditorías de inventario del periodo todavía abiertas
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'auditoria_id', a.id, 'nombre', a.nombre) order by a.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.auditorias_inventario a
     where a.fecha between v_desde and v_hasta
       and a.estatus = 'abierta';
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'auditorias_abiertas',
            'descripcion', v_cant || ' auditoría(s) de inventario del periodo sin cerrar.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    -- 8. Pólizas del periodo con cargos <> abonos (defensivo / datos legado)
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'poliza_id', s.poliza_id, 'diferencia', s.diferencia) order by s.poliza_id), '[]'::jsonb)
      into v_cant, v_detalle
      from (
          select pm.poliza_id, round(sum(pm.cargo) - sum(pm.abono), 2) as diferencia
            from public.poliza_movimientos pm
            join public.polizas p on p.id = pm.poliza_id
           where p.fecha between v_desde and v_hasta
             and p.estatus = 'contabilizada'
           group by pm.poliza_id
          having round(sum(pm.cargo) - sum(pm.abono), 2) <> 0
      ) s;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'polizas_descuadradas',
            'descripcion', v_cant || ' póliza(s) del periodo con cargos distintos a abonos. Revisar de inmediato.',
            'cantidad', v_cant, 'detalle', v_detalle);
    end if;

    return v_candados;
end;
$$;
revoke all     on function public._candados_cierre_periodo(integer, integer) from public;
grant  execute on function public._candados_cierre_periodo(integer, integer) to authenticated;


-- ---------------------------------------------------------------------
-- precierre_periodo_contable: checklist de solo lectura, no cierra nada.
-- ---------------------------------------------------------------------
create or replace function public.precierre_periodo_contable(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_candados jsonb;
begin
    if p_mes not between 1 and 12 then raise exception 'Mes inválido: %.', p_mes; end if;

    v_candados := public._candados_cierre_periodo(p_anio, p_mes);

    return jsonb_build_object(
        'anio', p_anio, 'mes', p_mes,
        'listo_para_cerrar', (jsonb_array_length(v_candados) = 0),
        'candados', v_candados
    );
end;
$$;
revoke all     on function public.precierre_periodo_contable(integer, integer) from public;
grant  execute on function public.precierre_periodo_contable(integer, integer) to authenticated;


-- ---------------------------------------------------------------------
-- cerrar_periodo_contable: ahora corre los candados antes de cerrar.
--   forzar = false (default): si hay candados, RECHAZA el cierre y
--            explica cuáles son.
--   forzar = true: cierra de todos modos, pero guarda la lista de
--            advertencias ignoradas en periodos_contables.advertencias_forzadas
--            (y por el trigger de F8, en bitacora_cambios).
-- ---------------------------------------------------------------------
-- La versión anterior (2 parámetros, sin candados) queda reemplazada
-- por esta de 3. Si no se tira explícitamente, Postgres las trata como
-- sobrecargas distintas y una llamada con 2 argumentos seguiría
-- resolviendo a la versión vieja (sin candados) en vez de a esta.
drop function if exists public.cerrar_periodo_contable(integer, integer);

create or replace function public.cerrar_periodo_contable(p_anio integer, p_mes integer, p_forzar boolean default false)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_id       bigint;
    v_candados jsonb;
    v_detalle_txt text;
begin
    if p_mes not between 1 and 12 then raise exception 'Mes inválido: %.', p_mes; end if;
    if p_anio < 2000 then raise exception 'Año inválido: %.', p_anio; end if;

    v_candados := public._candados_cierre_periodo(p_anio, p_mes);

    if jsonb_array_length(v_candados) > 0 and not p_forzar then
        select string_agg('· ' || (c->>'descripcion'), E'\n')
          into v_detalle_txt
          from jsonb_array_elements(v_candados) c;

        raise exception E'No se puede cerrar el periodo %-%: hay % pendiente(s) contable(s).\n%\n\nSi de verdad necesitas cerrarlo así, llama cerrar_periodo_contable(%, %, true) — los pendientes ignorados quedan guardados y en la bitácora.',
            p_anio, lpad(p_mes::text, 2, '0'), jsonb_array_length(v_candados), v_detalle_txt, p_anio, p_mes;
    end if;

    insert into public.periodos_contables (anio, mes, cerrado, cerrado_por, cerrado_at, advertencias_forzadas)
    values (p_anio, p_mes, true, auth.uid(), now(), case when p_forzar then v_candados else null end)
    on conflict (anio, mes) do update
        set cerrado = true, cerrado_por = auth.uid(), cerrado_at = now(),
            advertencias_forzadas = case when p_forzar then v_candados else null end
    returning id into v_id;

    return jsonb_build_object(
        'periodo_id', v_id, 'anio', p_anio, 'mes', p_mes, 'cerrado', true,
        'forzado', p_forzar,
        'candados_ignorados', case when p_forzar then v_candados else '[]'::jsonb end
    );
end;
$$;
revoke all     on function public.cerrar_periodo_contable(integer, integer, boolean) from public;
grant  execute on function public.cerrar_periodo_contable(integer, integer, boolean) to authenticated;

commit;
