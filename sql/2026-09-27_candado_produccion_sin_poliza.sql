-- =====================================================================
--  Cierre de periodo: el candado 1 ("documentos sin póliza") no
--  detectaba producción sin contabilizar.
--  Fecha: 2026-09-27  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-23_precierre_periodo_contable.sql
--
--  Problema: _candados_cierre_periodo solo revisaba
--  tipo_movimiento in ('entrada_compra', 'salida_venta'). Una orden de
--  producción (js/produccion.js, cerrarOrdenDeProduccion) genera
--  documentos 'entrada_produccion' / 'salida_produccion', y si
--  contabilizar_produccion falla al cerrar (el propio flujo tolera el
--  error sin revertir el movimiento físico ya hecho), esos documentos
--  se quedan sin poliza_id — pero ni precierre_periodo_contable ni
--  cerrar_periodo_contable lo detectaban: se podía cerrar el mes con
--  inventario ya movido a producto terminado y sin su póliza, sin
--  ninguna alerta.
--
--  Fix: el candado 1 ahora también revisa 'entrada_produccion' y
--  'salida_produccion'. Es la misma función completa de
--  sql/2026-09-23_precierre_periodo_contable.sql — solo cambia la
--  lista de tipos del candado 1 y su texto descriptivo.
--
--  Idempotente.
-- =====================================================================

begin;

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
    -- 1. Documentos operativos capturados sin llevar a póliza
    --    (compra, venta y producción — FIX 2026-09-27: antes solo
    --    revisaba entrada_compra/salida_venta, dejando pasar
    --    producciones sin contabilizar).
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'documento_id', d.id, 'folio', d.folio, 'tipo', d.tipo_movimiento) order by d.id), '[]'::jsonb)
      into v_cant, v_detalle
      from public.documentos d
     where d.fecha_emision::date between v_desde and v_hasta
       and d.tipo_movimiento in ('entrada_compra', 'salida_venta', 'entrada_produccion', 'salida_produccion')
       and coalesce(d.estado, '') <> 'cancelado'
       and d.poliza_id is null;
    if v_cant > 0 then
        v_candados := v_candados || jsonb_build_object(
            'motivo', 'documentos_sin_poliza',
            'descripcion', v_cant || ' documento(s) de compra/venta/producción del periodo sin contabilizar (sin póliza).',
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

commit;
