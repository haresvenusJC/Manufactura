-- =====================================================================
--  La depreciación de la maquinaria productiva entra al prorrateo del CIF
--  Fecha: 2026-10-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-15_costos_produccion_fase2y3.sql (prorrateo)
--            sql/2026-10-02_activos_fijos.sql (activos fijos)
--
--  Problema: depreciacion_aplicar() carga la depreciación directo a la cuenta
--  503.04 con su propia póliza y NO crea un gasto, así que el prorrateo (que
--  solo lee `gastos`) nunca la repartía a las órdenes de producción.
--
--  Qué deja:
--    1. activos_fijos_centros — las etapas (centros de costo) donde se usa
--       cada máquina. Sin porcentajes: se reparte en partes iguales.
--    2. activos_fijos_depreciaciones.prorrateo_estatus — 'no_aplica'
--       (equipo de oficina o sin etapas), 'pendiente' o 'prorrateado'.
--    3. gasto_aplicaciones.depreciacion_id — una aplicación puede venir de un
--       gasto O de una depreciación (gasto_id deja de ser obligatorio).
--    4. Funciones reescritas COMPLETAS (sin parches):
--         depreciacion_aplicar, depreciacion_cancelar,
--         prorrateo_calcular, prorrateo_aplicar, prorrateo_cancelar.
--
--  Cómo se reparte la depreciación de una máquina en un mes:
--    en PARTES IGUALES entre las etapas que se marcan para esa máquina
--    (decisión del usuario 2026-10-14: más simple que por horas de uso).
--    Después es CIF FIJO de cada etapa: se aplica a las órdenes por horas
--    contra la capacidad normal y lo no utilizado va a 503.98.
--
--  Contabilidad (NIF C-4 / C-6): la depreciación de maquinaria productiva es
--  CIF. Al depreciar: Cargo 503.04 / Abono 153.xx (póliza de depreciación).
--  Al prorratear: Cargo 115.03 (o 503.98 si es capacidad no utilizada) /
--  Abono 503.04 (póliza de traspaso). 503.04 queda en cero.
--
--  Solo entran al prorrateo las máquinas cuya cuenta de gasto es 503.xx y
--  que tienen etapas capturadas; lo demás sigue como hasta hoy.
--  Idempotente. Sin datos que corregir hacia atrás.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Etapas donde se usa cada máquina
-- ---------------------------------------------------------------------
create table if not exists public.activos_fijos_centros (
    id               bigint generated always as identity primary key,
    activo_id        bigint not null references public.activos_fijos(id) on delete cascade,
    centro_costo_id  bigint not null references public.centros_costo(id) on delete cascade,
    unique (activo_id, centro_costo_id)
);
create index if not exists idx_afc_activo on public.activos_fijos_centros(activo_id);

comment on table public.activos_fijos_centros is
  'Etapas (centros de costo) donde se usa una máquina. Su depreciación mensual se reparte entre ellas en partes iguales (ver prorrateo_calcular).';

alter table public.activos_fijos_centros enable row level security;
drop policy if exists admin_all on public.activos_fijos_centros;
create policy admin_all on public.activos_fijos_centros for all to authenticated using (true) with check (true);
grant all on public.activos_fijos_centros to authenticated;

drop trigger if exists trg_bitacora_activos_fijos_centros on public.activos_fijos_centros;
create trigger trg_bitacora_activos_fijos_centros
    after insert or update or delete on public.activos_fijos_centros
    for each row execute function public.fn_bitacora_generica();


-- ---------------------------------------------------------------------
-- 2. Estado de prorrateo de cada depreciación mensual
-- ---------------------------------------------------------------------
alter table public.activos_fijos_depreciaciones
    add column if not exists prorrateo_estatus text not null default 'no_aplica';

alter table public.activos_fijos_depreciaciones
    drop constraint if exists activos_fijos_depreciaciones_prorrateo_estatus_chk;
alter table public.activos_fijos_depreciaciones
    add constraint activos_fijos_depreciaciones_prorrateo_estatus_chk
    check (prorrateo_estatus in ('no_aplica', 'pendiente', 'prorrateado'));


-- ---------------------------------------------------------------------
-- 3. gasto_aplicaciones: origen = gasto O depreciación
-- ---------------------------------------------------------------------
alter table public.gasto_aplicaciones alter column gasto_id drop not null;

alter table public.gasto_aplicaciones
    add column if not exists depreciacion_id bigint
        references public.activos_fijos_depreciaciones(id) on delete cascade;

alter table public.gasto_aplicaciones drop constraint if exists gasto_aplicaciones_origen_chk;
alter table public.gasto_aplicaciones
    add constraint gasto_aplicaciones_origen_chk
    check (num_nonnulls(gasto_id, depreciacion_id) = 1);

create index if not exists idx_gaap_deprec on public.gasto_aplicaciones(depreciacion_id)
    where depreciacion_id is not null;


-- ---------------------------------------------------------------------
-- 4. depreciacion_aplicar — póliza del mes + marca cuáles pasan al prorrateo
-- ---------------------------------------------------------------------
create or replace function public.depreciacion_aplicar(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
volatile
set search_path = public
as $$
declare
    v_fecha          date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
    v_fila           record;
    v_movs           jsonb := '[]'::jsonb;
    v_activos_montos jsonb := '[]'::jsonb;
    v_total          numeric(14,2) := 0;
    v_poliza         jsonb;
    v_poliza_id      bigint;
    v_activo_montos  record;
    v_estatus        text;
begin
    for v_fila in
        select c.*, a.cuenta_depreciacion_gasto_id, a.cuenta_depreciacion_acumulada_id,
               (cg.codigo like '503.%' and exists (select 1 from public.activos_fijos_centros ac
                                                    where ac.activo_id = c.activo_id)) as va_a_prorrateo
          from public.depreciacion_calcular(p_anio, p_mes) c
          join public.activos_fijos a on a.id = c.activo_id
          join public.cuentas_contables cg on cg.id = a.cuenta_depreciacion_gasto_id
         where c.monto_mes > 0
    loop
        v_movs := v_movs || jsonb_build_array(
            jsonb_build_object('cuenta_id', v_fila.cuenta_depreciacion_gasto_id,
                                'cargo', v_fila.monto_mes, 'abono', 0,
                                'concepto', 'Depreciación ' || v_fila.nombre || ' ' || p_mes || '/' || p_anio),
            jsonb_build_object('cuenta_id', v_fila.cuenta_depreciacion_acumulada_id,
                                'cargo', 0, 'abono', v_fila.monto_mes,
                                'concepto', 'Depreciación ' || v_fila.nombre || ' ' || p_mes || '/' || p_anio)
        );
        v_activos_montos := v_activos_montos || jsonb_build_object(
            'activo_id', v_fila.activo_id, 'monto', v_fila.monto_mes,
            'estatus', case when v_fila.va_a_prorrateo then 'pendiente' else 'no_aplica' end);
        v_total := v_total + v_fila.monto_mes;
    end loop;

    if v_total = 0 then
        raise exception 'No hay depreciación pendiente de aplicar para %/%.', p_mes, p_anio;
    end if;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha,
        'tipo', 'Diario',
        'concepto', 'Depreciación de activos fijos ' || p_mes || '/' || p_anio,
        'origen', 'depreciacion',
        'origen_tabla', 'activos_fijos_depreciaciones',
        'movimientos', v_movs
    ));
    v_poliza_id := (v_poliza->>'poliza_id')::bigint;

    for v_activo_montos in
        select * from jsonb_to_recordset(v_activos_montos) as x(activo_id bigint, monto numeric, estatus text)
    loop
        insert into public.activos_fijos_depreciaciones (activo_id, anio, mes, monto, poliza_id, prorrateo_estatus)
        values (v_activo_montos.activo_id, p_anio, p_mes, v_activo_montos.monto, v_poliza_id, v_activo_montos.estatus);
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

grant execute on function public.depreciacion_aplicar(integer, integer) to authenticated;


-- ---------------------------------------------------------------------
-- 5. depreciacion_cancelar — no deja cancelar lo que ya se prorrateó
-- ---------------------------------------------------------------------
create or replace function public.depreciacion_cancelar(p_anio integer, p_mes integer)
returns void
language plpgsql
volatile
set search_path = public
as $$
declare
    v_poliza_id bigint;
begin
    select distinct poliza_id into v_poliza_id
      from public.activos_fijos_depreciaciones
     where anio = p_anio and mes = p_mes and poliza_id is not null
     limit 1;

    if v_poliza_id is null then
        raise exception 'No hay depreciación aplicada en %/% para cancelar.', p_mes, p_anio;
    end if;

    if exists (select 1 from public.activos_fijos_depreciaciones
                where anio = p_anio and mes = p_mes and prorrateo_estatus = 'prorrateado') then
        raise exception 'La depreciación de %/% ya se repartió en el prorrateo de gastos. Cancela primero el prorrateo de ese mes.', p_mes, p_anio;
    end if;

    perform public.cancelar_poliza(v_poliza_id, 'Cancelación de depreciación ' || p_mes || '/' || p_anio);
    delete from public.activos_fijos_depreciaciones where anio = p_anio and mes = p_mes;
end;
$$;

grant execute on function public.depreciacion_cancelar(integer, integer) to authenticated;


-- ---------------------------------------------------------------------
-- 6. prorrateo_calcular — PREVIEW (no escribe). Orígenes: gastos indirectos
--    y depreciación de maquinaria. Cambia el tipo de retorno (agrega
--    depreciacion_id), por eso se recrea.
-- ---------------------------------------------------------------------
drop function if exists public.prorrateo_calcular(date);

create function public.prorrateo_calcular(p_periodo date)
returns table (
    gasto_id            bigint,
    depreciacion_id     bigint,
    concepto            text,
    cuenta_codigo       text,
    cif_tipo            text,
    centro_costo_id     bigint,
    orden_produccion_id bigint,
    orden_folio         text,
    factor              numeric,
    horas_orden         numeric,
    horas_centro        numeric,
    capacidad_normal    numeric,
    utilizacion         numeric,
    monto               numeric,
    es_capacidad_ociosa boolean
)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_ini   date := date_trunc('month', p_periodo)::date;
    v_fin   date := (date_trunc('month', p_periodo) + interval '1 month')::date;
    sc      record;
    ho      record;
    v_slice numeric;
    v_htot  numeric;
    v_capn  numeric;
    v_util  numeric;
    v_aplic numeric;
    v_ocio  numeric;
begin
    for sc in
        with
        -- gastos indirectos del mes: por % si hay reglas; si no, 100% a su centro
        gst as (
            select gg.id as gid, gg.concepto as gconcepto, gg.subtotal as gmonto,
                   cc.codigo as gcuenta_codigo,
                   coalesce(nullif(trim(gg.cif_tipo), ''), cc.cif_tipo, 'variable') as gcif_tipo,
                   coalesce(gg.centro_costo_id, public._centro_prod_default()) as centro_id_default,
                   gg.base_prorrateo as gbase
              from public.gastos gg
              join public.cuentas_contables cc on cc.id = gg.cuenta_gasto_id
             where gg.clasificacion = 'indirecto_produccion'
               and gg.estatus = 'registrado'
               and gg.prorrateo_estatus = 'pendiente'
               and gg.fecha >= v_ini and gg.fecha < v_fin
        ),
        gst_slices as (
            select g.gid as src_gasto_id, null::bigint as src_dep_id, g.gconcepto as src_concepto,
                   g.gcuenta_codigo as src_cuenta, g.gcif_tipo as src_tipo,
                   r.centro_costo_id as src_centro, round(g.gmonto * r.porcentaje / 100.0, 2) as src_slice
              from gst g
              join public.gasto_prorrateo_reglas r on r.gasto_id = g.gid
             where g.gbase = 'porcentaje_centros'
            union all
            select g.gid, null::bigint, g.gconcepto, g.gcuenta_codigo, g.gcif_tipo,
                   g.centro_id_default, g.gmonto
              from gst g
             where g.gbase <> 'porcentaje_centros'
                or not exists (select 1 from public.gasto_prorrateo_reglas r2 where r2.gasto_id = g.gid)
        ),
        -- depreciación de maquinaria: en partes iguales entre las etapas marcadas para la máquina
                dep_base as (
            select d.id as dep_id, d.monto as dmonto, a.id as activo_id, a.nombre as anombre, cc.codigo as dcuenta
              from public.activos_fijos_depreciaciones d
              join public.activos_fijos a on a.id = d.activo_id
              join public.cuentas_contables cc on cc.id = a.cuenta_depreciacion_gasto_id
             where d.prorrateo_estatus = 'pendiente'
               and d.anio = extract(year from v_ini)::int
               and d.mes = extract(month from v_ini)::int
        ),
        dep_w as (
            select b.dep_id, b.dmonto, b.anombre, b.dcuenta, ac.centro_costo_id as centro_id,
                   count(*) over (partition by b.dep_id) as n_centros
              from dep_base b
              join public.activos_fijos_centros ac on ac.activo_id = b.activo_id
        ),
        dep_s as (
            select w.*,
                   round(w.dmonto / w.n_centros, 2) as s0,
                   row_number() over (partition by w.dep_id order by w.centro_id) as rn
              from dep_w w
        ),
        dep_slices as (
            -- el centavo de redondeo se lo lleva la primera etapa: la suma es exactamente la depreciación
            select null::bigint as src_gasto_id, s.dep_id as src_dep_id,
                   'Depreciación ' || s.anombre as src_concepto, s.dcuenta as src_cuenta,
                   'fijo'::text as src_tipo, s.centro_id as src_centro,
                   s.s0 + case when s.rn = 1 then s.dmonto - sum(s.s0) over (partition by s.dep_id) else 0 end as src_slice
              from dep_s s
        )
        select * from gst_slices
        union all
        select * from dep_slices
    loop
        v_slice := sc.src_slice;
        select coalesce(sum(h.horas), 0) into v_htot
          from public._horas_mo_periodo(v_ini, v_fin) h where h.centro_id = sc.src_centro;
        select coalesce(capacidad_normal_horas, 0) into v_capn
          from public.centros_costo where id = sc.src_centro;
        v_util := case when v_capn > 0 then round(v_htot / v_capn, 4) else null end;

        if sc.src_tipo = 'fijo' and v_capn > 0 then
            v_aplic := round(v_slice * least(v_htot / v_capn, 1), 2);
        else
            v_aplic := case when v_htot > 0 then v_slice else 0 end;
        end if;
        v_ocio := round(v_slice - v_aplic, 2);

        -- parte aplicada -> repartida entre las órdenes por horas
        if v_aplic > 0 and v_htot > 0 then
            for ho in
                select h.orden_id, h.horas, op.folio
                from public._horas_mo_periodo(v_ini, v_fin) h
                join public.ordenes_produccion op on op.id = h.orden_id
                where h.centro_id = sc.src_centro
            loop
                gasto_id := sc.src_gasto_id; depreciacion_id := sc.src_dep_id;
                concepto := sc.src_concepto; cuenta_codigo := sc.src_cuenta;
                cif_tipo := sc.src_tipo; centro_costo_id := sc.src_centro;
                orden_produccion_id := ho.orden_id; orden_folio := ho.folio;
                factor := round(ho.horas / v_htot, 8);
                horas_orden := round(ho.horas, 4); horas_centro := round(v_htot, 4);
                capacidad_normal := round(v_capn, 2); utilizacion := v_util;
                monto := round(v_aplic * ho.horas / v_htot, 2);
                es_capacidad_ociosa := false;
                return next;
            end loop;
        end if;

        -- ociosidad (o el total si no hubo producción) -> línea sin orden
        if v_ocio <> 0 or v_aplic = 0 then
            gasto_id := sc.src_gasto_id; depreciacion_id := sc.src_dep_id;
            concepto := sc.src_concepto; cuenta_codigo := sc.src_cuenta;
            cif_tipo := sc.src_tipo; centro_costo_id := sc.src_centro;
            orden_produccion_id := null; orden_folio := null;
            factor := null; horas_orden := null; horas_centro := round(v_htot, 4);
            capacidad_normal := round(v_capn, 2); utilizacion := v_util;
            monto := round(case when v_aplic = 0 then v_slice else v_ocio end, 2);
            es_capacidad_ociosa := true;
            return next;
        end if;
    end loop;
end $$;

grant execute on function public.prorrateo_calcular(date) to authenticated;


-- ---------------------------------------------------------------------
-- 7. prorrateo_aplicar — gasto_aplicaciones + póliza de traspaso + costo de órdenes
-- ---------------------------------------------------------------------
create or replace function public.prorrateo_aplicar(p_periodo date)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_ini date := date_trunc('month', p_periodo)::date;
    v_movs jsonb := '[]'::jsonb;
    v_aplicado numeric := 0;
    v_ocioso   numeric := 0;
    v_ngastos  integer := 0;
    v_poliza_id bigint;
    v_cta_wip  bigint := public._cuenta_id('115.03');
    v_cta_pt_def bigint := public._cuenta_id('115.04');
    v_cta_ocio bigint := public._cuenta_id('503.98');
    r record;
    v_ind_pend numeric;
    v_new_unit numeric;
    v_corrida_id bigint;
begin
    if exists (select 1 from public.prorrateo_corridas where periodo = v_ini and estatus = 'aplicado') then
        raise exception 'El mes % ya tiene un prorrateo aplicado. Cancélalo primero si quieres rehacerlo.', to_char(v_ini, 'YYYY-MM');
    end if;
    if v_cta_wip is null or v_cta_pt_def is null or v_cta_ocio is null then
        raise exception 'Faltan cuentas del costeo (115.03 / 115.04 / 503.98). Corre sql/2026-09-14_costos_produccion_fase1.sql.';
    end if;

    -- 7.1 volcar el cálculo a gasto_aplicaciones (gastos y depreciación)
    insert into public.gasto_aplicaciones
        (gasto_id, depreciacion_id, orden_produccion_id, centro_costo_id, periodo, base, cif_tipo, factor, monto, es_capacidad_ociosa)
    select c.gasto_id, c.depreciacion_id, c.orden_produccion_id, c.centro_costo_id, v_ini, 'horas_mano_obra',
           c.cif_tipo, c.factor, c.monto, c.es_capacidad_ociosa
    from public.prorrateo_calcular(p_periodo) c;

    if not found then
        raise exception 'No hay gastos indirectos pendientes en %.', to_char(v_ini, 'YYYY-MM');
    end if;

    select coalesce(sum(monto) filter (where not es_capacidad_ociosa), 0),
           coalesce(sum(monto) filter (where es_capacidad_ociosa), 0),
           count(distinct gasto_id) + count(distinct depreciacion_id)
      into v_aplicado, v_ocioso, v_ngastos
    from public.gasto_aplicaciones where periodo = v_ini;

    -- 7.2 armar la póliza de traspaso
    if v_aplicado > 0 then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_wip, 'cargo', v_aplicado,
                    'concepto', 'CIF aplicado a producción en proceso ' || to_char(v_ini,'YYYY-MM'));
    end if;
    if v_ocioso > 0 then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_ocio, 'cargo', v_ocioso,
                    'concepto', 'Costo de capacidad no utilizada ' || to_char(v_ini,'YYYY-MM'));
    end if;
    -- abonos: cada cuenta 503.xx por su total del mes (la de los gastos, o la de depreciación del activo)
    for r in
        select coalesce(g.cuenta_gasto_id, a.cuenta_depreciacion_gasto_id) as cta, sum(ga.monto) as monto
        from public.gasto_aplicaciones ga
        left join public.gastos g on g.id = ga.gasto_id
        left join public.activos_fijos_depreciaciones d on d.id = ga.depreciacion_id
        left join public.activos_fijos a on a.id = d.activo_id
        where ga.periodo = v_ini
        group by coalesce(g.cuenta_gasto_id, a.cuenta_depreciacion_gasto_id)
    loop
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta, 'abono', r.monto,
                    'concepto', 'Traspaso CIF del mes ' || to_char(v_ini,'YYYY-MM'));
    end loop;

    -- 7.3 órdenes tocadas: acumular indirecto y, si están cerradas,
    --     mover el CIF de proceso (115.03) a terminado (115.04) en esta misma póliza
    for r in
        select ga.orden_produccion_id as orden_id,
               sum(ga.monto) as monto_periodo,
               op.estado, op.cantidad_producida, op.numero_lote, op.producto_id,
               op.costo_total_materiales, op.costo_total_mano_obra,
               coalesce(op.costo_indirecto_contabilizado, 0) as ind_contab,
               coalesce(pr.cuenta_inventario_id, v_cta_pt_def) as cta_pt
        from public.gasto_aplicaciones ga
        join public.ordenes_produccion op on op.id = ga.orden_produccion_id
        left join public.productos pr on pr.id = op.producto_id
        where ga.periodo = v_ini and ga.orden_produccion_id is not null and not ga.es_capacidad_ociosa
        group by ga.orden_produccion_id, op.estado, op.cantidad_producida, op.numero_lote,
                 op.producto_id, op.costo_total_materiales, op.costo_total_mano_obra,
                 op.costo_indirecto_contabilizado, pr.cuenta_inventario_id
    loop
        -- indirecto total acumulado de la orden (todos los meses)
        update public.ordenes_produccion o
        set costo_total_indirecto = (
                select coalesce(sum(monto), 0) from public.gasto_aplicaciones
                where orden_produccion_id = r.orden_id and not es_capacidad_ociosa)
        where o.id = r.orden_id;

        if r.estado = 'cerrada' then
            v_ind_pend := (select costo_total_indirecto - costo_indirecto_contabilizado
                           from public.ordenes_produccion where id = r.orden_id);
            if v_ind_pend > 0 then
                v_movs := v_movs
                    || jsonb_build_object('cuenta_id', r.cta_pt, 'cargo', v_ind_pend,
                         'concepto', 'CIF a producto terminado — orden ' || coalesce((select folio from public.ordenes_produccion where id = r.orden_id), r.orden_id::text))
                    || jsonb_build_object('cuenta_id', v_cta_wip, 'abono', v_ind_pend,
                         'concepto', 'CIF de proceso a terminado');

                -- recomputar costo unitario y actualizar lote + producto
                v_new_unit := round((coalesce(r.costo_total_materiales,0) + coalesce(r.costo_total_mano_obra,0)
                              + (select costo_total_indirecto from public.ordenes_produccion where id = r.orden_id)
                              + (select costo_total_gasto_directo from public.ordenes_produccion where id = r.orden_id))
                              / nullif(r.cantidad_producida, 0), 4);
                update public.ordenes_produccion
                set costo_indirecto_contabilizado = costo_indirecto_contabilizado + v_ind_pend,
                    costo_unitario_final = coalesce(v_new_unit, costo_unitario_final)
                where id = r.orden_id;

                if v_new_unit is not null then
                    update public.lotes_inventario
                    set costo_unitario = v_new_unit
                    where producto_id = r.producto_id and numero_lote = r.numero_lote;
                    update public.productos set costo_unitario = v_new_unit where id = r.producto_id;
                end if;
            end if;
        end if;
    end loop;

    -- 7.4 registrar la corrida primero (para tener el origen_id de la póliza)
    insert into public.prorrateo_corridas (periodo, total_aplicado, total_ocioso, gastos_incluidos)
    values (v_ini, v_aplicado, v_ocioso, v_ngastos)
    returning id into v_corrida_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', (v_ini + interval '1 month' - interval '1 day')::date,
        'tipo', 'Diario',
        'concepto', 'Prorrateo de gastos indirectos de fabricación ' || to_char(v_ini, 'YYYY-MM'),
        'origen', 'prorrateo', 'origen_tabla', 'prorrateo_corridas', 'origen_id', v_corrida_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.prorrateo_corridas set poliza_id = v_poliza_id where id = v_corrida_id;
    update public.gasto_aplicaciones set poliza_id = v_poliza_id where periodo = v_ini;
    update public.gastos set prorrateo_estatus = 'prorrateado'
     where id in (select distinct gasto_id from public.gasto_aplicaciones where periodo = v_ini and gasto_id is not null);
    update public.activos_fijos_depreciaciones set prorrateo_estatus = 'prorrateado'
     where id in (select distinct depreciacion_id from public.gasto_aplicaciones where periodo = v_ini and depreciacion_id is not null);

    return jsonb_build_object('periodo', to_char(v_ini,'YYYY-MM'), 'poliza_id', v_poliza_id,
        'total_aplicado', v_aplicado, 'total_ocioso', v_ocioso, 'gastos', v_ngastos);
end $$;

grant execute on function public.prorrateo_aplicar(date) to authenticated;


-- ---------------------------------------------------------------------
-- 8. prorrateo_cancelar — revierte la póliza y devuelve todo a "pendiente"
-- ---------------------------------------------------------------------
create or replace function public.prorrateo_cancelar(p_periodo date)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_ini date := date_trunc('month', p_periodo)::date;
    v_cor public.prorrateo_corridas%rowtype;
    r record;
begin
    select * into v_cor from public.prorrateo_corridas where periodo = v_ini and estatus = 'aplicado';
    if not found then raise exception 'No hay un prorrateo aplicado para %.', to_char(v_ini,'YYYY-MM'); end if;

    if v_cor.poliza_id is not null then
        perform public.cancelar_poliza(v_cor.poliza_id, 'Cancelación de prorrateo ' || to_char(v_ini,'YYYY-MM'));
    end if;

    -- revertir el contabilizado de indirecto en las órdenes cerradas tocadas
    for r in
        select distinct orden_produccion_id as orden_id
        from public.gasto_aplicaciones
        where periodo = v_ini and orden_produccion_id is not null and not es_capacidad_ociosa
    loop
        update public.ordenes_produccion o
        set costo_indirecto_contabilizado = greatest(0, costo_indirecto_contabilizado -
                (select coalesce(sum(monto),0) from public.gasto_aplicaciones
                 where periodo = v_ini and orden_produccion_id = r.orden_id and not es_capacidad_ociosa)),
            costo_total_indirecto = (
                select coalesce(sum(monto),0) from public.gasto_aplicaciones
                where orden_produccion_id = r.orden_id and periodo <> v_ini and not es_capacidad_ociosa)
        where o.id = r.orden_id;
    end loop;

    -- la depreciación vuelve a quedar pendiente de prorrateo (antes de borrar las aplicaciones)
    update public.activos_fijos_depreciaciones set prorrateo_estatus = 'pendiente'
     where id in (select distinct depreciacion_id from public.gasto_aplicaciones where periodo = v_ini and depreciacion_id is not null);

    delete from public.gasto_aplicaciones where periodo = v_ini;
    update public.gastos set prorrateo_estatus = 'pendiente'
     where clasificacion = 'indirecto_produccion' and prorrateo_estatus = 'prorrateado'
       and fecha >= v_ini and fecha < (v_ini + interval '1 month');
    update public.prorrateo_corridas set estatus = 'cancelado' where id = v_cor.id;

    return jsonb_build_object('periodo', to_char(v_ini,'YYYY-MM'), 'cancelado', true);
end $$;

grant execute on function public.prorrateo_cancelar(date) to authenticated;

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select a.nombre, c.codigo from public.activos_fijos_centros ac
--   join public.activos_fijos a on a.id = ac.activo_id join public.centros_costo c on c.id = ac.centro_costo_id;
-- select anio, mes, prorrateo_estatus, count(*), sum(monto) from public.activos_fijos_depreciaciones group by 1,2,3;
