-- =====================================================================
--  Costos de producción — Áreas físicas y bases de prorrateo
--  (la "pre-herramienta": declarar m², kW y personas por área para que
--   los % de reparto de gastos compartidos se deriven, no se tecleen)
--  Fecha: 2026-09-17  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-14_costos_produccion_fase1.sql
--            sql/2026-09-16_costos_centros_por_proceso.sql
--
--  Qué deja:
--    1. areas_fisicas          — cada área de la instalación (producción y
--                                no producción) con sus m², kWh medido
--                                (si hay submedidor) y nº de personas.
--    2. areas_fisicas_cargas   — el desglose de la carga eléctrica de cada
--                                área: {equipo, kW unitario, cantidad,
--                                factor de uso}. La suma es el kW del área.
--    3. v_areas_carga          — kW efectivo por área (Σ de sus cargas).
--    4. v_bases_prorrateo      — por cada base (m² / kW / personas), la
--                                fracción que le toca a cada área. De aquí
--                                salen los % de Nivel 1 (producción vs no
--                                producción) y Nivel 2 (SURT/MEZ/ENV).
--    5. Semilla con las 6 áreas de planta + Oficina, y los equipos
--       conocidos con kW PLACEHOLDER (ajústalos en la pantalla).
--
--  Mapeo área -> centro de costo (editable en la pantalla):
--    Almacén Insumos, Surtido MP        -> SURT
--    Cosméticos                          -> MEZ
--    Lotificación, Envasado, Acondic.    -> ENV
--    Oficina                             -> no producción (a resultados)
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. areas_fisicas
-- ---------------------------------------------------------------------
create table if not exists public.areas_fisicas (
    id                bigint generated always as identity primary key,
    codigo            text    not null unique,
    nombre            text    not null,
    rol               text    not null default 'produccion'
                      check (rol in ('produccion', 'no_produccion')),
    centro_costo_id   bigint  references public.centros_costo(id) on delete set null,
    m2                numeric(10,2) not null default 0 check (m2 >= 0),
    kwh_mensual       numeric(12,2) check (kwh_mensual is null or kwh_mensual >= 0),
    personas          smallint not null default 0 check (personas >= 0),
    activo            boolean not null default true,
    notas             text,
    created_at        timestamptz not null default now()
);

comment on table public.areas_fisicas is
  'Áreas físicas de la instalación para derivar bases de prorrateo. rol=produccion apunta a su centro (SURT/MEZ/ENV); rol=no_produccion va a resultados. kwh_mensual: solo si el área tiene submedidor (si está, se usa en vez del kW instalado calculado de las cargas).';

alter table public.areas_fisicas enable row level security;
drop policy if exists admin_all on public.areas_fisicas;
create policy admin_all on public.areas_fisicas for all to authenticated using (true) with check (true);
grant all on public.areas_fisicas to authenticated;


-- ---------------------------------------------------------------------
-- 2. areas_fisicas_cargas — desglose de la carga eléctrica del área
-- ---------------------------------------------------------------------
create table if not exists public.areas_fisicas_cargas (
    id            bigint generated always as identity primary key,
    area_id       bigint not null references public.areas_fisicas(id) on delete cascade,
    tipo          text not null default 'equipo'
                  check (tipo in ('equipo', 'iluminacion', 'clima', 'otro')),
    descripcion   text not null,
    kw_unitario   numeric(10,3) not null default 0 check (kw_unitario >= 0),
    cantidad      smallint not null default 1 check (cantidad >= 1),
    factor_uso    numeric(4,3) not null default 1.0 check (factor_uso > 0 and factor_uso <= 1),
    notas         text
);

comment on table public.areas_fisicas_cargas is
  'Cargas eléctricas de cada área. kw_efectivo = kw_unitario * cantidad * factor_uso. factor_uso = fracción del tiempo/carga que realmente demanda (1.0 = siempre a plena carga).';

create index if not exists idx_afc_area on public.areas_fisicas_cargas(area_id);

alter table public.areas_fisicas_cargas enable row level security;
drop policy if exists admin_all on public.areas_fisicas_cargas;
create policy admin_all on public.areas_fisicas_cargas for all to authenticated using (true) with check (true);
grant all on public.areas_fisicas_cargas to authenticated;


-- ---------------------------------------------------------------------
-- 3. v_areas_carga — kW efectivo por área
-- ---------------------------------------------------------------------
create or replace view public.v_areas_carga as
select a.id as area_id,
       coalesce(sum(c.kw_unitario * c.cantidad * c.factor_uso), 0)::numeric(12,3) as kw_efectivo
from public.areas_fisicas a
left join public.areas_fisicas_cargas c on c.area_id = a.id
group by a.id;

grant select on public.v_areas_carga to authenticated;


-- ---------------------------------------------------------------------
-- 4. v_bases_prorrateo — fracción por área para cada base
-- ---------------------------------------------------------------------
create or replace view public.v_bases_prorrateo as
with base as (
    select a.id, a.codigo, a.nombre, a.rol, a.centro_costo_id,
           a.m2,
           a.personas,
           coalesce(a.kwh_mensual, vc.kw_efectivo) as kw_base
    from public.areas_fisicas a
    join public.v_areas_carga vc on vc.area_id = a.id
    where a.activo
)
select 'm2'::text as base, b.id as area_id, b.codigo, b.nombre, b.rol, b.centro_costo_id,
       b.m2 as valor,
       case when sum(b.m2) over () > 0 then round(b.m2 / sum(b.m2) over (), 6) else 0 end as fraccion
from base b
union all
select 'kw', b.id, b.codigo, b.nombre, b.rol, b.centro_costo_id,
       b.kw_base,
       case when sum(b.kw_base) over () > 0 then round(b.kw_base / sum(b.kw_base) over (), 6) else 0 end
from base b
union all
select 'personas', b.id, b.codigo, b.nombre, b.rol, b.centro_costo_id,
       b.personas::numeric,
       case when sum(b.personas) over () > 0 then round(b.personas::numeric / sum(b.personas) over (), 6) else 0 end
from base b;

grant select on public.v_bases_prorrateo to authenticated;


-- ---------------------------------------------------------------------
-- 5. Semilla — 6 áreas de planta + Oficina
-- ---------------------------------------------------------------------
insert into public.areas_fisicas (codigo, nombre, rol, centro_costo_id, m2, personas, notas)
select v.codigo, v.nombre, v.rol,
       (select id from public.centros_costo c where c.codigo = v.centro),
       0, 0, v.notas
from (values
    ('ALM-INS', 'Almacén Insumos',    'produccion',    'SURT', 'Bodega de materia prima y material de empaque; adyacente al surtido.'),
    ('SURT',    'Surtido MP',         'produccion',    'SURT', 'Pesaje y preparación de materia prima por fórmula.'),
    ('COSM',    'Cosméticos',         'produccion',    'MEZ',  'Fabricación del granel (mezclado, emulsión, control de calidad en proceso).'),
    ('LOTIF',   'Lotificación',       'produccion',    'ENV',  'Marcado de lote y caducidad. Sub-etapa de envasado.'),
    ('ENV',     'Envasado',           'produccion',    'ENV',  'Llenado y tapado.'),
    ('ACOND',   'Acondicionamiento',  'produccion',    'ENV',  'Etiquetado, termoencogido, encajado (empaque secundario).'),
    ('OFIC',    'Oficina',            'no_produccion',  null,  'Administración, contabilidad, dirección. Su parte de servicios va a resultados (601.xx), no al costo de los lotes.')
) as v(codigo, nombre, rol, centro, notas)
where not exists (select 1 from public.areas_fisicas a where a.codigo = v.codigo);


-- ---------------------------------------------------------------------
-- 6. Semilla — equipos conocidos (kW PLACEHOLDER; ajustar en la pantalla)
-- ---------------------------------------------------------------------
insert into public.areas_fisicas_cargas (area_id, tipo, descripcion, kw_unitario, cantidad, factor_uso, notas)
select a.id, v.tipo, v.descripcion, v.kw, v.cant, v.fu, v.notas
from (values
    ('ENV',   'equipo', 'Llenadora',              2.200, 1::smallint, 0.700, 'kW placeholder — capturar de la placa.'),
    ('ENV',   'equipo', 'Llenadoras de pedal',    0.000, 2::smallint, 1.000, 'Operación manual/neumática; ajustar si son neumáticas.'),
    ('ENV',   'equipo', 'Banda transportadora',   0.750, 1::smallint, 0.800, 'kW placeholder.'),
    ('LOTIF', 'equipo', 'Lotificadora',           0.500, 1::smallint, 0.500, 'kW placeholder.'),
    ('ACOND', 'clima',  'Túnel de vapor',         9.000, 1::smallint, 0.300, 'Resistencias; alto consumo pero baja fracción de uso. Ajustar.'),
    ('COSM',  'equipo', 'Licuadora industrial',   4.000, 1::smallint, 0.500, 'kW placeholder.'),
    ('SURT',  'equipo', 'Básculas',               0.100, 2::smallint, 1.000, 'kW placeholder.'),
    ('COSM',  'clima',  'HVAC',                  15.000, 1::smallint, 0.700, 'Si el HVAC climatiza varias áreas, divídelo en una carga por área o muévelo a la de mayor beneficio.')
) as v(area_codigo, tipo, descripcion, kw, cant, fu, notas)
join public.areas_fisicas a on a.codigo = v.area_codigo
where not exists (
    select 1 from public.areas_fisicas_cargas c
    where c.area_id = a.id and c.descripcion = v.descripcion
);

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select codigo, nombre, rol, m2, personas from public.areas_fisicas order by codigo;
-- select a.codigo, vc.kw_efectivo from public.areas_fisicas a join public.v_areas_carga vc on vc.area_id = a.id order by 1;
-- select base, codigo, rol, valor, fraccion from public.v_bases_prorrateo order by base, codigo;
