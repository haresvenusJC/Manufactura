-- =====================================================================
--  Equipos unificados: todo equipo se da de alta en Activos fijos
--  Fecha: 2026-10-15  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-17_areas_bases_prorrateo.sql (areas_fisicas, v_areas_carga)
--            sql/2026-10-02_activos_fijos.sql (activos_fijos)
--            sql/2026-10-14_depreciacion_al_prorrateo.sql
--
--  Problema: un mismo equipo vivía en dos lugares sin relación —
--  Activos fijos (para depreciar) y areas_fisicas_cargas (para repartir la
--  luz). El Asistente de prorrateo capturaba la carga eléctrica aparte y
--  Activos fijos no la veía.
--
--  Decisiones del usuario (2026-10-15):
--    1. TODO equipo se da de alta en Activos fijos. La etiqueta
--       Depreciable / No depreciable decide si se le aplica depreciación.
--    2. Las cargas eléctricas que ya existían (todas con kW placeholder,
--       incluido el túnel de vapor de prueba) se BORRAN; los equipos se
--       dan de alta de nuevo, a mano, con la guía del Asistente.
--    3. El Asistente no deja guardar si falta ese alta.
--
--  Qué deja:
--    1. activos_fijos gana: depreciable, area_id, tipo_carga, potencia_kw
--       (kW por unidad), cantidad y factor_uso. costo y vida útil solo son
--       obligatorios si el equipo es depreciable; un NO depreciable exige
--       área y potencia (alta mínima).
--    2. v_areas_carga (kW por área) pasa a sumar desde activos_fijos
--       (activos vigentes): potencia_kw × cantidad × factor_uso. Mismas
--       columnas, así que v_bases_prorrateo no se toca.
--    3. Se borran las filas de areas_fisicas_cargas (la tabla queda sin uso).
--    4. depreciacion_calcular() reescrita COMPLETA: ignora los NO
--       depreciables. depreciacion_aplicar() no cambia (lee de esa función).
--
--  Idempotente. Antes de borrar las cargas, las lista en un NOTICE.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. activos_fijos: equipo con ubicación y potencia
-- ---------------------------------------------------------------------
alter table public.activos_fijos
    add column if not exists depreciable boolean  not null default true,
    add column if not exists area_id     bigint   references public.areas_fisicas (id),
    add column if not exists tipo_carga  text,
    add column if not exists potencia_kw numeric(10,3),
    add column if not exists cantidad    smallint not null default 1,
    add column if not exists factor_uso  numeric(4,3) not null default 1;

comment on column public.activos_fijos.depreciable is
  'true = se le aplica depreciación (necesita costo y vida útil). false = equipo que solo se controla (luz, ubicación): exige área y potencia.';
comment on column public.activos_fijos.potencia_kw is
  'Potencia de placa por UNIDAD, en kW (HP × 0.746; W ÷ 1000). 0 si el equipo no consume electricidad. Null = sin capturar.';
comment on column public.activos_fijos.factor_uso is
  'Fracción del tiempo/carga que realmente demanda (1 = siempre a plena carga). kW efectivo = potencia_kw × cantidad × factor_uso.';

-- costo y vida útil dejan de ser obligatorios para todos: solo para los depreciables
alter table public.activos_fijos alter column costo_adquisicion drop not null;
alter table public.activos_fijos alter column vida_util_meses  drop not null;

do $$
declare r record;
begin
    for r in
        select c.conname
          from pg_constraint c
         where c.conrelid = 'public.activos_fijos'::regclass
           and c.contype = 'c'
           and c.conname not in ('activos_fijos_dep_chk', 'activos_fijos_nodep_chk', 'activos_fijos_costo_nonneg_chk',
                                 'activos_fijos_tipo_carga_chk', 'activos_fijos_potencia_chk',
                                 'activos_fijos_cantidad_chk', 'activos_fijos_factor_uso_chk')
           and (pg_get_constraintdef(c.oid) like '%costo_adquisicion%>%0%'
             or pg_get_constraintdef(c.oid) like '%vida_util_meses%>%0%')
    loop
        execute format('alter table public.activos_fijos drop constraint %I', r.conname);
    end loop;
end $$;

alter table public.activos_fijos drop constraint if exists activos_fijos_dep_chk;
alter table public.activos_fijos add  constraint activos_fijos_dep_chk
    check (depreciable = false or (coalesce(costo_adquisicion, 0) > 0 and coalesce(vida_util_meses, 0) > 0));

alter table public.activos_fijos drop constraint if exists activos_fijos_nodep_chk;
alter table public.activos_fijos add  constraint activos_fijos_nodep_chk
    check (depreciable = true or (area_id is not null and potencia_kw is not null));

alter table public.activos_fijos drop constraint if exists activos_fijos_costo_nonneg_chk;
alter table public.activos_fijos add  constraint activos_fijos_costo_nonneg_chk
    check (costo_adquisicion is null or costo_adquisicion >= 0);

alter table public.activos_fijos drop constraint if exists activos_fijos_tipo_carga_chk;
alter table public.activos_fijos add  constraint activos_fijos_tipo_carga_chk
    check (tipo_carga is null or tipo_carga in ('equipo', 'iluminacion', 'clima', 'otro'));

alter table public.activos_fijos drop constraint if exists activos_fijos_potencia_chk;
alter table public.activos_fijos add  constraint activos_fijos_potencia_chk
    check (potencia_kw is null or potencia_kw >= 0);

alter table public.activos_fijos drop constraint if exists activos_fijos_cantidad_chk;
alter table public.activos_fijos add  constraint activos_fijos_cantidad_chk
    check (cantidad >= 1);

alter table public.activos_fijos drop constraint if exists activos_fijos_factor_uso_chk;
alter table public.activos_fijos add  constraint activos_fijos_factor_uso_chk
    check (factor_uso > 0 and factor_uso <= 1);

create index if not exists activos_fijos_area_idx on public.activos_fijos (area_id);


-- ---------------------------------------------------------------------
-- 2. v_areas_carga — kW efectivo por área, ahora desde Activos fijos
-- ---------------------------------------------------------------------
create or replace view public.v_areas_carga as
select a.id as area_id,
       coalesce(sum(f.potencia_kw * f.cantidad * f.factor_uso), 0)::numeric(12,3) as kw_efectivo
from public.areas_fisicas a
left join public.activos_fijos f
       on f.area_id = a.id
      and f.activo
      and f.potencia_kw is not null
group by a.id;

grant select on public.v_areas_carga to authenticated;


-- ---------------------------------------------------------------------
-- 3. Cargas eléctricas anteriores: se listan y se borran (decisión del usuario)
-- ---------------------------------------------------------------------
do $$
declare
    r record;
    n integer := 0;
begin
    if to_regclass('public.areas_fisicas_cargas') is null then
        return;
    end if;
    for r in
        select a.codigo, c.descripcion, c.kw_unitario, c.cantidad, c.factor_uso
          from public.areas_fisicas_cargas c
          join public.areas_fisicas a on a.id = c.area_id
         order by a.codigo, c.id
    loop
        n := n + 1;
        raise notice 'Se borra carga: % · % (% kW × % × uso %)', r.codigo, r.descripcion, r.kw_unitario, r.cantidad, r.factor_uso;
    end loop;
    delete from public.areas_fisicas_cargas;
    raise notice 'Cargas eléctricas borradas: %', n;
    execute 'comment on table public.areas_fisicas_cargas is ' ||
            quote_literal('SIN USO desde 2026-10-15: los equipos y su potencia viven en activos_fijos (area_id, potencia_kw, cantidad, factor_uso).');
end $$;


-- ---------------------------------------------------------------------
-- 4. depreciacion_calcular — ignora los equipos NO depreciables
--    (depreciacion_aplicar la usa, así que tampoco los toca)
-- ---------------------------------------------------------------------
create or replace function public.depreciacion_calcular(p_anio integer, p_mes integer)
returns table (
    activo_id bigint, nombre text, costo_adquisicion numeric, valor_residual numeric,
    vida_util_meses integer, meses_depreciados integer, depreciacion_acumulada_previa numeric,
    monto_mes numeric, valor_en_libros numeric
)
language plpgsql
stable
set search_path = public
as $$
declare
    v_hasta date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
begin
    return query
    select
        a.id,
        a.nombre,
        a.costo_adquisicion,
        a.valor_residual,
        a.vida_util_meses,
        coalesce((select count(*) from public.activos_fijos_depreciaciones d
                   where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0)::int,
        coalesce((select sum(d.monto) from public.activos_fijos_depreciaciones d
                   where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0),
        least(
            round((a.costo_adquisicion - a.valor_residual) / a.vida_util_meses, 2),
            greatest(0, (a.costo_adquisicion - a.valor_residual) - coalesce((select sum(d.monto) from public.activos_fijos_depreciaciones d
                       where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0))
        ),
        a.costo_adquisicion - coalesce((select sum(d.monto) from public.activos_fijos_depreciaciones d
                   where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0)
      from public.activos_fijos a
     where a.activo = true
       and a.depreciable = true
       and a.costo_adquisicion is not null
       and a.vida_util_meses is not null
       and a.fecha_adquisicion <= v_hasta
       and (a.fecha_baja is null or a.fecha_baja > v_hasta)
       and not exists (select 1 from public.activos_fijos_depreciaciones d2
                         where d2.activo_id = a.id and d2.anio = p_anio and d2.mes = p_mes)
       and a.cuenta_depreciacion_gasto_id is not null
       and a.cuenta_depreciacion_acumulada_id is not null
     order by a.nombre;
end;
$$;

grant execute on function public.depreciacion_calcular(integer, integer) to authenticated;

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select nombre, depreciable, area_id, tipo_carga, potencia_kw, cantidad, factor_uso from public.activos_fijos order by id;
-- select a.codigo, v.kw_efectivo from public.v_areas_carga v join public.areas_fisicas a on a.id = v.area_id order by a.codigo;
