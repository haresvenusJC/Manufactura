-- =====================================================================
--  Semiterminados / producto a granel — cuenta 115.02 y consumo por
--  cuenta de inventario de cada componente.
--  Fecha: 2026-09-19  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-08-28_contabilidad_cuentas.sql
--            sql/2026-09-15_costos_produccion_fase2y3.sql
--
--  Contexto: el granel es un semiterminado (lleva materiales + mano de
--  obra + CIF). Se quiere verlo en su propia cuenta de inventario,
--  115.02, separada de materia prima (115.01) y de la cuenta de
--  tránsito del CIF (115.03).
--
--  Hasta ahora, al CERRAR una orden que consume componentes,
--  contabilizar_produccion abonaba TODO el material a 115.01, sin
--  importar de qué cuenta salía cada componente. Con este cambio, el
--  abono se hace a la cuenta de inventario de CADA componente
--  (productos.cuenta_inventario_id), con fallback a 115.01. Así, si el
--  granel tiene cuenta_inventario_id = 115.02, esa cuenta se abona al
--  consumirlo y queda cuadrada.
--
--  El desglose real se toma de movimientos_inventario del documento de
--  salida que arma js/produccion.js (p_datos->>'documento_salida_id').
--  Si ese dato no viene (llamadas antiguas), el comportamiento es el de
--  antes: todo a 115.01.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Cuenta 115.02 — Inventario de productos en proceso (semiterminados)
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select '115.02', 'Inventario de productos en proceso (semiterminados)', '115.02', 'D', 'activo', 2, true
where not exists (select 1 from public.cuentas_contables where codigo = '115.02');

update public.cuentas_contables c
set cuenta_padre_id = p.id
from public.cuentas_contables p
where c.codigo = '115.02' and c.cuenta_padre_id is null
  and p.codigo = '115' and p.nivel = 1;

comment on column public.productos.cuenta_inventario_id is
  'Cuenta de inventario del producto. MP -> 115.01, granel / semiterminado -> 115.02, producto terminado -> 115.04. Se usa al PRODUCIRLO (cargo) y al CONSUMIRLO en otra orden (abono).';


-- ---------------------------------------------------------------------
-- 2. contabilizar_produccion — abono de MP consumida por cuenta de
--    inventario de cada componente (idéntica a la previa salvo ese bloque)
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_produccion(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc    public.documentos%rowtype;
    v_mat    numeric(14,2) := round(coalesce((p_datos->>'costo_materiales')::numeric, 0), 2);
    v_mo     numeric(14,2) := round(coalesce((p_datos->>'costo_mano_obra')::numeric, 0), 2);
    v_total  numeric(14,2);
    v_cta_pt bigint;
    v_cta_mp bigint := public._cuenta_id('115.01');
    v_cta_mo bigint := public._cuenta_id('601.01');
    v_cta_wip bigint := public._cuenta_id('115.03');
    v_movs   jsonb  := '[]'::jsonb;
    v_pid    bigint;

    v_orden  bigint := (p_datos->>'orden_produccion_id')::bigint;
    v_doc_salida bigint := (p_datos->>'documento_salida_id')::bigint;
    v_ind    numeric(14,2) := 0;
    v_dir    numeric(14,2) := 0;
    v_qty    numeric;
    v_prod   bigint;
    v_lote   text;

    v_mat_desglose jsonb := '[]'::jsonb;
    v_mat_sum      numeric(14,2) := 0;
    r        record;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de produccion no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta produccion ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;

    select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.04')) into v_cta_pt
    from public.documento_detalles dd
    left join public.productos pr on pr.id = dd.producto_id
    where dd.documento_id = p_documento_id
    limit 1;
    if v_cta_pt is null then raise exception 'Falta la cuenta 115.04 (Productos terminados) en el plan de cuentas.'; end if;

    -- ---- Fase 3: CIF ya aplicado (en 115.03) + gastos directos de la orden ----
    if v_orden is not null then
        v_ind := (select coalesce(costo_total_indirecto - costo_indirecto_contabilizado, 0)
                  from public.ordenes_produccion where id = v_orden);
        v_ind := greatest(v_ind, 0);

        v_dir := (select coalesce(sum(g.subtotal), 0)
                  from public.gastos g
                  where g.clasificacion = 'directo_produccion' and g.orden_produccion_id = v_orden
                    and g.estatus = 'registrado')
               - (select coalesce(costo_gasto_directo_contabilizado, 0)
                  from public.ordenes_produccion where id = v_orden);
        v_dir := greatest(v_dir, 0);
    end if;

    -- ---- MP consumida: desglose por cuenta de inventario de cada componente ----
    if v_mat > 0 and v_doc_salida is not null then
        for r in
            select coalesce(pr.cuenta_inventario_id, v_cta_mp) as cta,
                   round(sum(abs(mi.cantidad) * coalesce(mi.costo_unitario, 0)), 2) as monto
            from public.movimientos_inventario mi
            join public.productos pr on pr.id = mi.producto_id
            where mi.documento_id = v_doc_salida
              and mi.tipo_movimiento = 'salida_produccion'
            group by 1
        loop
            if r.cta is null then
                raise exception 'Un componente consumido no tiene cuenta de inventario y falta la 115.01 de respaldo. Asigna la cuenta al producto o crea la 115.01.';
            end if;
            if r.monto > 0 then
                v_mat_desglose := v_mat_desglose || jsonb_build_object('cuenta_id', r.cta, 'monto', r.monto);
                v_mat_sum := v_mat_sum + r.monto;
            end if;
        end loop;
        -- el desglose real es la fuente de verdad de la parte material
        if jsonb_array_length(v_mat_desglose) > 0 then
            v_mat := round(v_mat_sum, 2);
        end if;
    end if;

    v_total := round(v_mat + v_mo + v_ind + v_dir, 2);
    if v_total <= 0 then raise exception 'La produccion no tiene costo.'; end if;

    -- Cargo al producto terminado por el costo total
    v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_pt, 'cargo', v_total,
                'concepto', 'Producto terminado ' || coalesce(v_doc.folio, '')));

    -- Abono de la MP: por el desglose de cuentas, o todo a 115.01 si no hay desglose
    if v_mat > 0 then
        if jsonb_array_length(v_mat_desglose) > 0 then
            for r in select * from jsonb_to_recordset(v_mat_desglose) as x(cuenta_id bigint, monto numeric)
            loop
                v_movs := v_movs || jsonb_build_object('cuenta_id', r.cuenta_id, 'abono', r.monto,
                            'concepto', 'Componente consumido ' || coalesce(v_doc.folio, ''));
            end loop;
        else
            if v_cta_mp is null then raise exception 'Falta la cuenta 115.01 (Inventario materia prima).'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_mp, 'abono', v_mat, 'concepto', 'MP consumida ' || coalesce(v_doc.folio, ''));
        end if;
    end if;

    if v_mo > 0 then
        if v_cta_mo is null then raise exception 'Falta la cuenta 601.01 (Sueldos y salarios).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_mo, 'abono', v_mo, 'concepto', 'Mano de obra aplicada ' || coalesce(v_doc.folio, ''));
    end if;
    if v_ind > 0 then
        if v_cta_wip is null then raise exception 'Falta la cuenta 115.03 (Produccion en proceso).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_wip, 'abono', v_ind, 'concepto', 'CIF de proceso a terminado ' || coalesce(v_doc.folio, ''));
    end if;
    if v_dir > 0 then
        for r in
            select g.cuenta_gasto_id as cta, sum(g.subtotal) as monto
            from public.gastos g
            where g.clasificacion = 'directo_produccion' and g.orden_produccion_id = v_orden and g.estatus = 'registrado'
            group by g.cuenta_gasto_id
        loop
            v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta, 'abono',
                        round(r.monto * v_dir / nullif((select sum(g2.subtotal) from public.gastos g2
                              where g2.clasificacion = 'directo_produccion' and g2.orden_produccion_id = v_orden and g2.estatus='registrado'), 0), 2),
                        'concepto', 'Gasto directo a producto terminado ' || coalesce(v_doc.folio, ''));
        end loop;
    end if;

    if jsonb_array_length(v_movs) < 2 then
        v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_pt, 'cargo', v_total),
                                    jsonb_build_object('cuenta_id', v_cta_mp, 'abono', v_total));
    end if;

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Diario',
        'concepto', 'Produccion ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, ''),
        'folio', v_doc.folio,
        'origen', 'produccion', 'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos set poliza_id = v_pid, total = v_total where id = p_documento_id;

    -- marcar en la orden lo que se acaba de incorporar + costo unitario
    if v_orden is not null then
        select cantidad_producida, producto_id, numero_lote into v_qty, v_prod, v_lote
        from public.ordenes_produccion where id = v_orden;
        update public.ordenes_produccion
        set costo_indirecto_contabilizado = costo_indirecto_contabilizado + v_ind,
            costo_gasto_directo_contabilizado = costo_gasto_directo_contabilizado + v_dir,
            costo_total_gasto_directo = (select coalesce(sum(subtotal),0) from public.gastos
                where clasificacion = 'directo_produccion' and orden_produccion_id = v_orden and estatus='registrado'),
            costo_total_materiales = v_mat,
            costo_unitario_final = round(v_total / nullif(v_qty, 0), 4)
        where id = v_orden;

        if v_qty is not null and v_qty > 0 then
            update public.lotes_inventario set costo_unitario = round(v_total / v_qty, 4)
            where producto_id = v_prod and numero_lote = v_lote and documento_id = p_documento_id;
            update public.productos set costo_unitario = round(v_total / v_qty, 4) where id = v_prod;
        end if;
    end if;

    return jsonb_build_object('poliza_id', v_pid, 'total', v_total,
        'costo_materiales', v_mat, 'costo_mano_obra', v_mo, 'costo_indirecto', v_ind, 'costo_directo', v_dir);
end $$;

revoke all     on function public.contabilizar_produccion(bigint, jsonb) from public;
grant  execute on function public.contabilizar_produccion(bigint, jsonb) to authenticated;

commit;


-- =====================================================================
--  Después de correr esto:
--   1. En Catálogo, edita cada producto a granel y pon su
--      "Cuenta de inventario" = 115.02.
--   2. Los envases/tapas/cajas dejan su cuenta vacía (usan 115.01).
--   3. Al cerrar la orden del producto terminado, la póliza abonará
--      115.02 por el granel consumido y 115.01 por el material de empaque.
-- =====================================================================
-- select codigo, nombre, cuenta_padre_id from public.cuentas_contables where codigo like '115%' order by codigo;
