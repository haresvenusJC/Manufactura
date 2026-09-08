-- =====================================================================
--  Costos de producción — FASE 2 (prorrateo del CIF) + FASE 3
--  (integración del CIF y de los gastos directos al costo de la orden)
--  Fecha: 2026-09-15  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-14_costos_produccion_fase1.sql
--
--  FASE 2 — el motor de prorrateo mensual:
--    · gastos.base_prorrateo  (horas_mano_obra | porcentaje_centros | partes_iguales)
--    · gasto_prorrateo_reglas  (para 'porcentaje_centros': % por centro de costo)
--    · gasto_aplicaciones      (resultado: cuánto CIF le tocó a cada orden y
--                               cuánto quedó como capacidad ociosa)
--    · prorrateo_corridas      (una fila por mes aplicado; poliza + estatus)
--    · prorrateo_calcular(p_periodo)   -> PREVIEW, no escribe
--    · prorrateo_aplicar(p_periodo)    -> escribe gasto_aplicaciones + póliza
--    · prorrateo_cancelar(p_periodo)   -> revierte
--
--    Regla de equilibrio (elegida): base = horas de MANO DE OBRA.
--      CIF variable -> denominador = horas reales del mes  (todo a órdenes)
--      CIF fijo     -> denominador = CAPACIDAD NORMAL del centro
--                      aplicado = slice * min(horas_reales/cap_normal, 1) -> a órdenes
--                      ocioso   = slice - aplicado -> 503.98 (resultados, NO inventario)
--
--  FASE 3 — el CIF y el directo bajan al costo del lote:
--    · ordenes_produccion + costo_total_indirecto, costo_indirecto_contabilizado,
--      costo_total_gasto_directo, costo_gasto_directo_contabilizado
--    · prorrateo_aplicar recalcula el costo de las órdenes tocadas; para las
--      YA CERRADAS mueve el CIF de 115.03 (proceso) a 115.04 (terminado)
--      dentro de la misma póliza, y actualiza el costo del lote y del producto.
--    · contabilizar_produccion (cierre) ahora también incorpora el CIF ya
--      aplicado y los gastos DIRECTOS de esa orden. Necesita
--      p_datos->>'orden_produccion_id' (lo manda js/produccion.js). Si no
--      viene, se comporta igual que antes.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. polizas.origen admite 'prorrateo'
-- ---------------------------------------------------------------------
do $$
declare v_con text;
begin
    select conname into v_con
    from pg_constraint
    where conrelid = 'public.polizas'::regclass and contype = 'c'
      and pg_get_constraintdef(oid) ilike '%origen%';
    if v_con is not null then
        execute format('alter table public.polizas drop constraint %I', v_con);
    end if;
    alter table public.polizas
        add constraint polizas_origen_chk check (origen in
        ('manual','gasto','compra','venta','nomina','ajuste','salida','entrada','produccion','pago','prorrateo'));
exception when others then
    raise notice 'No se pudo ajustar el check de polizas.origen: %', sqlerrm;
end $$;


-- ---------------------------------------------------------------------
-- 1. gastos.base_prorrateo + reglas de % por centro
-- ---------------------------------------------------------------------
alter table public.gastos
    add column if not exists base_prorrateo text not null default 'horas_mano_obra'
        check (base_prorrateo in ('horas_mano_obra','porcentaje_centros','partes_iguales'));

create table if not exists public.gasto_prorrateo_reglas (
    id              bigint generated always as identity primary key,
    gasto_id        bigint not null references public.gastos(id) on delete cascade,
    centro_costo_id bigint not null references public.centros_costo(id) on delete cascade,
    porcentaje      numeric(7,4) not null check (porcentaje > 0 and porcentaje <= 100),
    unique (gasto_id, centro_costo_id)
);
alter table public.gasto_prorrateo_reglas enable row level security;
drop policy if exists admin_all on public.gasto_prorrateo_reglas;
create policy admin_all on public.gasto_prorrateo_reglas for all to authenticated using (true) with check (true);
grant all on public.gasto_prorrateo_reglas to authenticated;


-- ---------------------------------------------------------------------
-- 2. ordenes_produccion — nuevos acumuladores de costo (Fase 3)
-- ---------------------------------------------------------------------
alter table public.ordenes_produccion
    add column if not exists centro_costo_id                bigint references public.centros_costo(id) on delete set null,
    add column if not exists costo_total_indirecto          numeric(14,2) not null default 0,
    add column if not exists costo_indirecto_contabilizado  numeric(14,2) not null default 0,
    add column if not exists costo_total_gasto_directo       numeric(14,2) not null default 0,
    add column if not exists costo_gasto_directo_contabilizado numeric(14,2) not null default 0;


-- ---------------------------------------------------------------------
-- 3. gasto_aplicaciones + prorrateo_corridas
-- ---------------------------------------------------------------------
create table if not exists public.gasto_aplicaciones (
    id                   bigint generated always as identity primary key,
    gasto_id             bigint not null references public.gastos(id) on delete cascade,
    orden_produccion_id  bigint references public.ordenes_produccion(id) on delete set null,
    centro_costo_id      bigint references public.centros_costo(id) on delete set null,
    periodo              date not null,                      -- primer día del mes
    base                 text not null,
    cif_tipo             text,
    factor               numeric(16,8),                      -- proporción aplicada a esa orden
    monto                numeric(14,2) not null,
    es_capacidad_ociosa  boolean not null default false,
    poliza_id            bigint references public.polizas(id) on delete set null,
    creado_en            timestamptz not null default now(),
    creado_por           uuid default auth.uid()
);
create index if not exists idx_gaap_periodo on public.gasto_aplicaciones(periodo);
create index if not exists idx_gaap_orden   on public.gasto_aplicaciones(orden_produccion_id);
create index if not exists idx_gaap_gasto   on public.gasto_aplicaciones(gasto_id);

alter table public.gasto_aplicaciones enable row level security;
drop policy if exists admin_all on public.gasto_aplicaciones;
create policy admin_all on public.gasto_aplicaciones for all to authenticated using (true) with check (true);
grant all on public.gasto_aplicaciones to authenticated;

create table if not exists public.prorrateo_corridas (
    id             bigint generated always as identity primary key,
    periodo        date not null,
    estatus        text not null default 'aplicado' check (estatus in ('aplicado','cancelado')),
    total_aplicado numeric(14,2) not null default 0,
    total_ocioso   numeric(14,2) not null default 0,
    gastos_incluidos integer not null default 0,
    poliza_id      bigint references public.polizas(id) on delete set null,
    aplicado_en    timestamptz not null default now(),
    aplicado_por   uuid default auth.uid()
);
create unique index if not exists prorrateo_corridas_periodo_activa
    on public.prorrateo_corridas(periodo) where estatus = 'aplicado';

alter table public.prorrateo_corridas enable row level security;
drop policy if exists admin_all on public.prorrateo_corridas;
create policy admin_all on public.prorrateo_corridas for all to authenticated using (true) with check (true);
grant all on public.prorrateo_corridas to authenticated;


-- ---------------------------------------------------------------------
-- 4. Helpers
-- ---------------------------------------------------------------------
create or replace function public._centro_prod_default()
returns bigint language sql stable set search_path = public as $$
    select id from public.centros_costo
    where tipo = 'produccion' and activo
    order by id limit 1;
$$;

-- horas de mano de obra por orden en el periodo (intervalos cerrados)
create or replace function public._horas_mo_periodo(p_ini date, p_fin date)
returns table (orden_id bigint, centro_id bigint, horas numeric)
language sql stable set search_path = public as $$
    select opp.orden_produccion_id,
           coalesce(op.centro_costo_id, public._centro_prod_default()) as centro_id,
           sum(extract(epoch from (rt.fin - rt.inicio)) / 3600.0)::numeric as horas
    from public.registros_tiempo rt
    join public.orden_produccion_procesos opp on opp.id = rt.orden_produccion_proceso_id
    join public.ordenes_produccion op on op.id = opp.orden_produccion_id
    where rt.fin is not null
      and rt.inicio >= p_ini and rt.inicio < p_fin
    group by 1, 2
    having sum(extract(epoch from (rt.fin - rt.inicio)) / 3600.0) > 0;
$$;


-- ---------------------------------------------------------------------
-- 5. prorrateo_calcular — PREVIEW (no escribe)
-- ---------------------------------------------------------------------
create or replace function public.prorrateo_calcular(p_periodo date)
returns table (
    gasto_id            bigint,
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
    v_ini date := date_trunc('month', p_periodo)::date;
    v_fin date := (date_trunc('month', p_periodo) + interval '1 month')::date;
    g       record;
    sc      record;
    ho      record;
    v_slice numeric;
    v_htot  numeric;
    v_capn  numeric;
    v_util  numeric;
    v_aplic numeric;
    v_ocio  numeric;
begin
    for g in
        select gg.id, gg.concepto as gconcepto, gg.subtotal as gmonto,
               cc.codigo as gcuenta_codigo,
               coalesce(nullif(trim(gg.cif_tipo), ''), cc.cif_tipo, 'variable') as gcif_tipo,
               coalesce(gg.centro_costo_id, public._centro_prod_default()) as centro_id_default,
               gg.base_prorrateo
        from public.gastos gg
        join public.cuentas_contables cc on cc.id = gg.cuenta_gasto_id
        where gg.clasificacion = 'indirecto_produccion'
          and gg.estatus = 'registrado'
          and gg.prorrateo_estatus = 'pendiente'
          and gg.fecha >= v_ini and gg.fecha < v_fin
    loop
        -- repartir el gasto entre centros (por % si hay reglas; si no, 100% a su centro)
        for sc in
            select r.centro_costo_id as centro_id, round(g.gmonto * r.porcentaje / 100.0, 2) as slice
            from public.gasto_prorrateo_reglas r
            where g.base_prorrateo = 'porcentaje_centros' and r.gasto_id = g.id
            union all
            select g.centro_id_default, g.gmonto
            where g.base_prorrateo <> 'porcentaje_centros'
               or not exists (select 1 from public.gasto_prorrateo_reglas r2 where r2.gasto_id = g.id)
        loop
            v_slice := sc.slice;
            select coalesce(sum(h.horas), 0) into v_htot
              from public._horas_mo_periodo(v_ini, v_fin) h where h.centro_id = sc.centro_id;
            select coalesce(capacidad_normal_horas, 0) into v_capn
              from public.centros_costo where id = sc.centro_id;
            v_util := case when v_capn > 0 then round(v_htot / v_capn, 4) else null end;

            if g.gcif_tipo = 'fijo' and v_capn > 0 then
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
                    where h.centro_id = sc.centro_id
                loop
                    gasto_id := g.id; concepto := g.gconcepto; cuenta_codigo := g.gcuenta_codigo;
                    cif_tipo := g.gcif_tipo; centro_costo_id := sc.centro_id;
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
                gasto_id := g.id; concepto := g.gconcepto; cuenta_codigo := g.gcuenta_codigo;
                cif_tipo := g.gcif_tipo; centro_costo_id := sc.centro_id;
                orden_produccion_id := null; orden_folio := null;
                factor := null; horas_orden := null; horas_centro := round(v_htot, 4);
                capacidad_normal := round(v_capn, 2); utilizacion := v_util;
                monto := round(case when v_aplic = 0 then v_slice else v_ocio end, 2);
                es_capacidad_ociosa := true;
                return next;
            end if;
        end loop;
    end loop;
end $$;

grant execute on function public.prorrateo_calcular(date) to authenticated;


-- ---------------------------------------------------------------------
-- 6. prorrateo_aplicar — escribe gasto_aplicaciones + póliza + Fase 3
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

    -- 6.1 volcar el cálculo a gasto_aplicaciones
    insert into public.gasto_aplicaciones
        (gasto_id, orden_produccion_id, centro_costo_id, periodo, base, cif_tipo, factor, monto, es_capacidad_ociosa)
    select c.gasto_id, c.orden_produccion_id, c.centro_costo_id, v_ini, 'horas_mano_obra',
           c.cif_tipo, c.factor, c.monto, c.es_capacidad_ociosa
    from public.prorrateo_calcular(p_periodo) c;

    if not found then
        raise exception 'No hay gastos indirectos pendientes en %.', to_char(v_ini, 'YYYY-MM');
    end if;

    select coalesce(sum(monto) filter (where not es_capacidad_ociosa), 0),
           coalesce(sum(monto) filter (where es_capacidad_ociosa), 0),
           count(distinct gasto_id)
      into v_aplicado, v_ocioso, v_ngastos
    from public.gasto_aplicaciones where periodo = v_ini;

    -- 6.2 armar la póliza de traspaso
    if v_aplicado > 0 then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_wip, 'cargo', v_aplicado,
                    'concepto', 'CIF aplicado a producción en proceso ' || to_char(v_ini,'YYYY-MM'));
    end if;
    if v_ocioso > 0 then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_ocio, 'cargo', v_ocioso,
                    'concepto', 'Costo de capacidad no utilizada ' || to_char(v_ini,'YYYY-MM'));
    end if;
    -- abonos: cada cuenta 503.xx por su total del mes
    for r in
        select g.cuenta_gasto_id as cta, sum(ga.monto) as monto
        from public.gasto_aplicaciones ga
        join public.gastos g on g.id = ga.gasto_id
        where ga.periodo = v_ini
        group by g.cuenta_gasto_id
    loop
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta, 'abono', r.monto,
                    'concepto', 'Traspaso CIF del mes ' || to_char(v_ini,'YYYY-MM'));
    end loop;

    -- 6.3 FASE 3 — órdenes tocadas: acumular indirecto y, si están cerradas,
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

    -- 6.4 registrar la corrida primero (para tener el origen_id de la póliza)
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
     where id in (select distinct gasto_id from public.gasto_aplicaciones where periodo = v_ini);

    return jsonb_build_object('periodo', to_char(v_ini,'YYYY-MM'), 'poliza_id', v_poliza_id,
        'total_aplicado', v_aplicado, 'total_ocioso', v_ocioso, 'gastos', v_ngastos);
end $$;

grant execute on function public.prorrateo_aplicar(date) to authenticated;


-- ---------------------------------------------------------------------
-- 7. prorrateo_cancelar
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

    delete from public.gasto_aplicaciones where periodo = v_ini;
    update public.gastos set prorrateo_estatus = 'pendiente'
     where clasificacion = 'indirecto_produccion' and prorrateo_estatus = 'prorrateado'
       and fecha >= v_ini and fecha < (v_ini + interval '1 month');
    update public.prorrateo_corridas set estatus = 'cancelado' where id = v_cor.id;

    return jsonb_build_object('periodo', to_char(v_ini,'YYYY-MM'), 'cancelado', true);
end $$;

grant execute on function public.prorrateo_cancelar(date) to authenticated;


-- ---------------------------------------------------------------------
-- 8. FASE 3 — contabilizar_produccion incorpora CIF ya aplicado + directos
--    (idéntica a la previa salvo el bloque de la orden, que solo actúa si
--     p_datos trae 'orden_produccion_id')
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
    v_ind    numeric(14,2) := 0;
    v_dir    numeric(14,2) := 0;
    v_qty    numeric;
    v_prod   bigint;
    v_lote   text;
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

    v_total := round(v_mat + v_mo + v_ind + v_dir, 2);
    if v_total <= 0 then raise exception 'La produccion no tiene costo.'; end if;

    -- Cargo al producto terminado por el costo total
    v_movs := jsonb_build_array(jsonb_build_object('cuenta_id', v_cta_pt, 'cargo', v_total,
                'concepto', 'Producto terminado ' || coalesce(v_doc.folio, '')));

    if v_mat > 0 then
        if v_cta_mp is null then raise exception 'Falta la cuenta 115.01 (Inventario materia prima).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_mp, 'abono', v_mat, 'concepto', 'MP consumida ' || coalesce(v_doc.folio, ''));
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
--  Verificación (opcional) — cambia el mes
-- =====================================================================
-- select * from public.prorrateo_calcular('2026-09-01');
-- select * from public.prorrateo_corridas order by periodo desc;
-- select * from public.gasto_aplicaciones where periodo = '2026-09-01';
