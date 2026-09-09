-- =====================================================================
--  Costos de producción — FASE 2b: un centro de costo POR PROCESO
--  (surtido de MP · mezclado · envasado), no uno por orden completa.
--  Fecha: 2026-09-16  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-14_costos_produccion_fase1.sql
--            sql/2026-09-15_costos_produccion_fase2y3.sql
--
--  Qué cambia y por qué:
--    Hasta ahora el prorrateo del CIF agrupaba las horas de mano de obra
--    por el centro de la ORDEN (uno solo por orden). Como el trabajo ya
--    está partido en procesos con muy distinta carga de mano de obra por
--    unidad (pesar materia prima != fabricar el granel != envasar y
--    encajar), conviene que cada proceso lleve su propio centro para que
--    el CIF fijo/variable aterrice donde de verdad se consumió capacidad.
--
--    1. procesos_produccion.centro_costo_id  -> mapa canónico proceso→centro
--    2. orden_produccion_procesos.centro_costo_id -> foto al crear la orden
--    3. 3 centros de costo de producción con capacidad NORMAL sugerida
--       (2 operadores por etapa, que es como opera hoy la planta):
--         SURT (Surtido de MP)   ~265 h/mes   (2 operadores)
--         MEZ  (Mezclado)        ~265 h/mes   (2 operadores)
--         ENV  (Envasado)        ~265 h/mes   (2 operadores)
--       Son ESTIMACIONES iniciales "de la nómina hacia abajo"
--       (op x 8h x 24d x 0.90 ausentismo x 0.80 no-productivo x 0.96 paros).
--       Ajusta cap_operadores de cada centro si cambia tu plantilla y pulsa
--       "usar sugerido" en el módulo de Centros de costo.
--    4. Se mapea el catálogo de procesos existente a esos 3 centros por
--       nombre, y se rellena el centro en los procesos de órdenes que aún
--       no están cerradas.
--    5. Trigger: al insertar un proceso de orden sin centro, lo hereda del
--       catálogo.
--    6. _horas_mo_periodo agrupa por el centro del PROCESO
--       (coalesce: proceso de la orden -> catálogo -> centro de la orden
--        -> centro de producción por defecto).
--
--  El centro 'PROD' que sembró la Fase 1 se conserva como comodín / red de
--  seguridad (es el _centro_prod_default: el de menor id).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Columnas de centro en el catálogo y en el proceso de la orden
-- ---------------------------------------------------------------------
alter table public.procesos_produccion
    add column if not exists centro_costo_id bigint
        references public.centros_costo(id) on delete set null;

alter table public.orden_produccion_procesos
    add column if not exists centro_costo_id bigint
        references public.centros_costo(id) on delete set null;

create index if not exists idx_opp_centro on public.orden_produccion_procesos(centro_costo_id);

comment on column public.procesos_produccion.centro_costo_id is
  'Centro de costo donde se acumula la mano de obra y el CIF de este proceso. Se hereda a orden_produccion_procesos al crear la orden.';


-- ---------------------------------------------------------------------
-- 2. Los 3 centros de costo de producción, con capacidad NORMAL sugerida
--    (fórmula: operadores x jornada x días x ausentismo x no-productivo x paros)
--    2 operadores x 8h x 24d x 0.90 x 0.80 x 0.96 = 265.4208  (por etapa)
-- ---------------------------------------------------------------------
insert into public.centros_costo
    (codigo, nombre, tipo, cuenta_cif_default_id,
     capacidad_normal_horas,
     cap_operadores, cap_horas_jornada, cap_dias_habiles_mes,
     cap_factor_ausentismo, cap_factor_no_productivo, cap_factor_paros_planeados,
     metodo_cif, activo, notas)
select v.codigo, v.nombre, 'produccion',
       (select id from public.cuentas_contables where codigo = '503.99'),
       265.42::numeric, 2::smallint, 8, 24, 0.90, 0.80, 0.96,
       'real', true, v.notas
from (values
    ('SURT', 'Surtido de MP',
     'Pesaje y preparación de materia prima por fórmula. 2 operadores. Ajusta cap_operadores si cambia tu plantilla.'),
    ('MEZ',  'Mezclado',
     'Fabricación del granel (reactor, homogeneizado, control de pH/viscosidad). 2 operadores. Ajusta cap_operadores si cambia tu plantilla.'),
    ('ENV',  'Envasado',
     'Llenado, tapado, etiquetado y encajado. 2 operadores. Ajusta cap_operadores si cambia tu plantilla.')
) as v(codigo, nombre, notas)
where not exists (select 1 from public.centros_costo c where c.codigo = v.codigo);


-- ---------------------------------------------------------------------
-- 3. Catálogo de procesos: filas canónicas + mapeo a centro por nombre
-- ---------------------------------------------------------------------
insert into public.procesos_produccion (nombre)
select v.nombre
from (values ('Surtido de MP'), ('Mezclado'), ('Envasado')) as v(nombre)
where not exists (
    select 1 from public.procesos_produccion p where lower(p.nombre) = lower(v.nombre)
);

update public.procesos_produccion p
set centro_costo_id = c.id
from public.centros_costo c
where p.centro_costo_id is null
  and c.codigo = case
      when p.nombre ilike '%surt%' or p.nombre ilike '%pesaj%' or p.nombre ilike '%pesad%'
           or p.nombre ilike '%materia prima%' or p.nombre ilike '%dispens%'          then 'SURT'
      when p.nombre ilike '%mezcl%' or p.nombre ilike '%fabrica%' or p.nombre ilike '%granel%'
           or p.nombre ilike '%homogen%' or p.nombre ilike '%reactor%' or p.nombre ilike '%batch%'
           or p.nombre ilike '%emulsi%'                                               then 'MEZ'
      when p.nombre ilike '%envas%' or p.nombre ilike '%llen%' or p.nombre ilike '%etiquet%'
           or p.nombre ilike '%tapad%' or p.nombre ilike '%empaqu%' or p.nombre ilike '%encaj%'
           or p.nombre ilike '%acondicion%'                                           then 'ENV'
      else null
  end;


-- ---------------------------------------------------------------------
-- 4. Rellenar el centro en los procesos de órdenes NO cerradas
--    (las cerradas ya están costeadas; se dejan como están y el motor
--     usa el nombre como respaldo si hiciera falta)
-- ---------------------------------------------------------------------
update public.orden_produccion_procesos opp
set centro_costo_id = pp.centro_costo_id
from public.procesos_produccion pp,
     public.ordenes_produccion op
where opp.centro_costo_id is null
  and op.id = opp.orden_produccion_id
  and op.estado in ('borrador', 'en_proceso')
  and lower(pp.nombre) = lower(opp.proceso_nombre)
  and pp.centro_costo_id is not null;


-- ---------------------------------------------------------------------
-- 5. Trigger: heredar el centro del catálogo al crear el proceso de orden
-- ---------------------------------------------------------------------
create or replace function public._opp_hereda_centro()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    if new.centro_costo_id is null and new.proceso_nombre is not null then
        select centro_costo_id into new.centro_costo_id
        from public.procesos_produccion
        where lower(nombre) = lower(new.proceso_nombre)
        limit 1;
    end if;
    return new;
end $$;

drop trigger if exists trg_opp_hereda_centro on public.orden_produccion_procesos;
create trigger trg_opp_hereda_centro
    before insert on public.orden_produccion_procesos
    for each row execute function public._opp_hereda_centro();


-- ---------------------------------------------------------------------
-- 6. _horas_mo_periodo — agrupa por el centro del PROCESO
--    coalesce: centro del proceso de la orden
--           -> centro del catálogo (por nombre)
--           -> centro de la orden
--           -> centro de producción por defecto
-- ---------------------------------------------------------------------
create or replace function public._horas_mo_periodo(p_ini date, p_fin date)
returns table (orden_id bigint, centro_id bigint, horas numeric)
language sql stable set search_path = public as $$
    select opp.orden_produccion_id,
           coalesce(opp.centro_costo_id,
                    pp.centro_costo_id,
                    op.centro_costo_id,
                    public._centro_prod_default()) as centro_id,
           sum(extract(epoch from (rt.fin - rt.inicio)) / 3600.0)::numeric as horas
    from public.registros_tiempo rt
    join public.orden_produccion_procesos opp on opp.id = rt.orden_produccion_proceso_id
    join public.ordenes_produccion op on op.id = opp.orden_produccion_id
    left join public.procesos_produccion pp on lower(pp.nombre) = lower(opp.proceso_nombre)
    where rt.fin is not null
      and rt.inicio >= p_ini and rt.inicio < p_fin
    group by 1, 2
    having sum(extract(epoch from (rt.fin - rt.inicio)) / 3600.0) > 0;
$$;

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select codigo, nombre, capacidad_normal_horas, cap_operadores from public.centros_costo order by codigo;
-- select nombre, centro_costo_id from public.procesos_produccion order by nombre;
-- select * from public._horas_mo_periodo(date_trunc('month', now())::date,
--                                        (date_trunc('month', now()) + interval '1 month')::date);
