-- =====================================================================
--  Categorías de depreciación fiscal (LISR arts. 33, 34, 35 y 36)
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-10-02_activos_fijos.sql y sql/2026-10-21_activo_fijo_en_compras.sql
--
--  Para qué: al dar de alta un equipo (artículo tipo Activo fijo o Activos fijos)
--  se elige su CATEGORÍA fiscal y el sistema trae el % máximo anual de la LISR,
--  su tope deducible (si aplica) y el ejercicio en que rige. Todo es editable
--  en Configuración -> Tablas -> "SAT · Depreciación fiscal" porque cambia con
--  los años: al cambiar un % no se pisa el anterior, se cierra la fila
--  (vigente_hasta) y se agrega una nueva (vigente_desde).
--
--  Qué deja:
--    1. Tabla c_categoria_depreciacion (con la tabla de cpcongroup.mx, vigente 2026).
--    2. productos.categoria_depreciacion_id (plantilla del artículo) y
--       activos_fijos.categoria_depreciacion_id + COPIA del % y tope vigentes
--       (pct_fiscal, tope_fiscal, ejercicio_fiscal): un equipo conserva lo de su año.
--    3. _alta_activos_desde_recepcion reescrita COMPLETA: copia la categoría del
--       artículo al activo que nace de una compra.
--
--  Los % son TOPES: la depreciación contable (NIF C-6) sigue usando la vida útil
--  del activo; el % fiscal solo la sugiere y sirve para el reporte fiscal.
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Catálogo editable
-- ---------------------------------------------------------------------
create table if not exists public.c_categoria_depreciacion (
    id             bigserial primary key,
    grupo          text      not null default 'depreciacion' check (grupo in ('depreciacion', 'amortizacion')),
    articulo       text      not null,                        -- fundamento: 'Art. 34 Fracc. I a'
    categoria      text      not null,
    pct_anual      numeric(6,2) not null check (pct_anual > 0 and pct_anual <= 100),
    tope_deducible numeric(14,2) check (tope_deducible is null or tope_deducible > 0),
    vigente_desde  smallint  not null,                        -- ejercicio fiscal en que empieza a regir
    vigente_hasta  smallint,                                  -- null = sigue vigente
    activo         boolean   not null default true,
    orden          integer   not null default 0,
    notas          text,
    unique (articulo, categoria, vigente_desde),
    check (vigente_hasta is null or vigente_hasta >= vigente_desde)
);

comment on table public.c_categoria_depreciacion is
  'Tasas máximas anuales de deducción de inversiones (LISR arts. 33-36). Para cambiar un % año con año: cerrar la fila (vigente_hasta) y agregar otra con vigente_desde nuevo.';

alter table public.c_categoria_depreciacion enable row level security;
drop policy if exists admin_all on public.c_categoria_depreciacion;
create policy admin_all on public.c_categoria_depreciacion for all to authenticated using (true) with check (true);
grant all on public.c_categoria_depreciacion to authenticated;
grant usage, select on sequence public.c_categoria_depreciacion_id_seq to authenticated;

-- Siembra: tabla "SAT Vigente 2026" de cpcongroup.mx. No pisa lo que ya hayas editado.
insert into public.c_categoria_depreciacion (grupo, articulo, categoria, pct_anual, tope_deducible, vigente_desde, orden, notas)
select v.grupo, v.articulo, v.categoria, v.pct, v.tope, 2026, v.orden, v.notas
from (values
    ('depreciacion', 'Art. 34 Fracc. I a',  'Edificios y construcciones',                                        5::numeric,  null::numeric, 10, null),
    ('depreciacion', 'Art. 34 Fracc. I b',  'Construcciones en monumentos arqueológicos, artísticos o históricos', 10, null, 20, null),
    ('depreciacion', 'Art. 34 Fracc. II',   'Ferrocarriles, bombas de gasolina, vías férreas',                   5,  null, 30, null),
    ('depreciacion', 'Art. 34 Fracc. II',   'Adaptaciones e mejoras en instalaciones',                           10, null, 40, null),
    ('depreciacion', 'Art. 34 Fracc. III',  'Mobiliario y equipo de oficina',                                    10, null, 50, null),
    ('depreciacion', 'Art. 34 Fracc. III',  'Equipo de comunicación (telefonía, radio)',                         10, null, 60, 'Fundamento tal como lo cita cpcongroup.mx; verificar contra la LISR.'),
    ('depreciacion', 'Art. 34 Fracc. IV',   'Embarcaciones',                                                     6,  null, 70, null),
    ('depreciacion', 'Art. 34 Fracc. V',    'Aviones',                                                           25, null, 80, null),
    ('depreciacion', 'Art. 34 Fracc. VI',   'Equipo de transporte (camiones de carga y pasajeros)',              25, null, 90, null),
    ('depreciacion', 'Art. 34 Fracc. VI y Art. 36 Fracc. II', 'Automóviles (deducción limitada por tope de MOI)', 25, 175000, 100, 'Solo es deducible el MOI hasta el tope; el exceso no se deduce para ISR.'),
    ('depreciacion', 'Art. 34 Fracc. VII',  'Equipo de cómputo, servidores, impresoras, lectores ópticos',       30, null, 110, null),
    ('depreciacion', 'Art. 34 Fracc. VIII', 'Equipo de imagen, sonido y video',                                  30, null, 120, 'Fundamento tal como lo cita cpcongroup.mx; verificar contra la LISR.'),
    ('depreciacion', 'Art. 35',             'Maquinaria y equipo destinados a actividad industrial general',     10, null, 200, 'Tasa general de maquinaria: la que usa una planta de cosméticos/farmacéutica salvo fracción específica.'),
    ('depreciacion', 'Art. 35 Fracc. I',    'Maquinaria para generación y conducción de electricidad',           5,  null, 210, null),
    ('depreciacion', 'Art. 35 Fracc. II',   'Maquinaria sector molino de productos agrícolas',                   7,  null, 220, null),
    ('depreciacion', 'Art. 35 Fracc. III',  'Maquinaria sector pulpa, papel y similares',                        6,  null, 230, null),
    ('depreciacion', 'Art. 35 Fracc. IV',   'Maquinaria sector minero (excepto petróleo)',                       7,  null, 240, null),
    ('depreciacion', 'Art. 35 Fracc. V',    'Maquinaria fabricación de vehículos de motor y construcción de aeronaves', 11, null, 250, 'cpcongroup.mx la lista como 11 % / 10 %: se cargó 11 %; ajústala si aplica el 10 %.'),
    ('depreciacion', 'Art. 35 Fracc. VI',   'Maquinaria actividad agrícola, ganadera, silvícola o pesquera',     25, null, 260, null),
    ('amortizacion', 'Art. 33 Fracc. I',    'Activos intangibles deducibles',                                    15, null, 300, 'Amortización (no depreciación).'),
    ('amortizacion', 'Art. 33 Fracc. III',  'Cargos diferidos',                                                  5,  null, 310, 'Amortización (no depreciación).'),
    ('amortizacion', 'Art. 33 Fracc. IV',   'Erogaciones en periodos preoperativos',                             10, null, 320, 'Amortización (no depreciación).')
) as v(grupo, articulo, categoria, pct, tope, orden, notas)
where not exists (
    select 1 from public.c_categoria_depreciacion c
     where c.articulo = v.articulo and c.categoria = v.categoria and c.vigente_desde = 2026
);


-- ---------------------------------------------------------------------
-- 2. Ligas en el artículo y en el activo
-- ---------------------------------------------------------------------
alter table public.productos
    add column if not exists categoria_depreciacion_id bigint references public.c_categoria_depreciacion (id);

alter table public.activos_fijos
    add column if not exists categoria_depreciacion_id bigint references public.c_categoria_depreciacion (id),
    add column if not exists pct_fiscal       numeric(6,2),
    add column if not exists tope_fiscal      numeric(14,2),
    add column if not exists ejercicio_fiscal smallint;

comment on column public.activos_fijos.pct_fiscal is
  'Copia del % máximo anual de la LISR vigente en el ejercicio de adquisición (no cambia si después se edita la tabla).';

create index if not exists activos_fijos_cat_dep_idx on public.activos_fijos (categoria_depreciacion_id);


-- ---------------------------------------------------------------------
-- 3. _alta_activos_desde_recepcion — cuerpo COMPLETO (base: 2026-10-21)
--    Cambio único: copia la categoría fiscal del artículo al activo, con el %
--    y tope vigentes en el ejercicio de la recepción (si no hay fila vigente
--    ese año, usa la más reciente anterior).
-- ---------------------------------------------------------------------
create or replace function public._alta_activos_desde_recepcion(p_documento_id bigint, p_poliza_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc    public.documentos%rowtype;
    r        record;
    v_n      integer := 0;
    v_cta_def bigint := public._cuenta_id('152.01');
    v_costo  numeric(14,2);
    v_anio   smallint;
    v_cat_id bigint; v_cat_nom text; v_cat_pct numeric; v_cat_tope numeric;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra % no existe.', p_documento_id; end if;
    v_anio := extract(year from v_doc.fecha_emision)::smallint;

    for r in
        select dd.id as det_id, dd.producto_id, dd.cantidad, dd.subtotal,
               p.nombre, p.cuenta_inventario_id, p.categoria_depreciacion_id
          from public.documento_detalles dd
          join public.productos p on p.id = dd.producto_id
         where dd.documento_id = p_documento_id
           and p.tipo = 'activo_fijo'
         order by dd.id
    loop
        if r.cantidad is distinct from 1 then
            raise exception 'El activo fijo «%» se recibe de uno en uno por partida (cantidad: %). Si compraste varios equipos, captura una partida por cada uno.',
                r.nombre, r.cantidad;
        end if;
        continue when exists (select 1 from public.activos_fijos where documento_detalle_id = r.det_id);

        v_costo := round(coalesce(r.subtotal, 0), 2);
        if v_costo <= 0 then
            raise exception 'El activo fijo «%» llegó sin costo; captura el costo real en la recepción.', r.nombre;
        end if;

        -- Categoría fiscal del artículo: la fila vigente ese año de la misma categoría/fundamento.
        v_cat_id := null; v_cat_nom := null; v_cat_pct := null; v_cat_tope := null;
        if r.categoria_depreciacion_id is not null then
            select c2.id, c2.categoria, c2.pct_anual, c2.tope_deducible
              into v_cat_id, v_cat_nom, v_cat_pct, v_cat_tope
              from public.c_categoria_depreciacion c1
              join public.c_categoria_depreciacion c2
                on c2.articulo = c1.articulo and c2.categoria = c1.categoria
             where c1.id = r.categoria_depreciacion_id
               and c2.vigente_desde <= v_anio
             order by c2.vigente_desde desc
             limit 1;
        end if;

        insert into public.activos_fijos
            (nombre, categoria, fecha_adquisicion, costo_adquisicion, valor_residual, cuenta_activo_id,
             pendiente, depreciable, producto_id, documento_id, documento_detalle_id,
             orden_compra_id, proveedor_id, poliza_compra_id,
             categoria_depreciacion_id, pct_fiscal, tope_fiscal, ejercicio_fiscal, notas)
        values
            (r.nombre, v_cat_nom, v_doc.fecha_emision, v_costo, 0, coalesce(r.cuenta_inventario_id, v_cta_def),
             true, true, r.producto_id, p_documento_id, r.det_id,
             v_doc.orden_compra_id, v_doc.proveedor_id, p_poliza_id,
             v_cat_id, v_cat_pct, v_cat_tope, case when v_cat_id is not null then v_anio end,
             'Alta automática al recibir ' || coalesce(v_doc.folio, '#' || p_documento_id)
                 || '. Falta completar: área, vida útil, etapas y si se deprecia.');
        v_n := v_n + 1;
    end loop;

    return v_n;
end;
$$;

revoke all on function public._alta_activos_desde_recepcion(bigint, bigint) from public, anon;

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select grupo, articulo, categoria, pct_anual, tope_deducible, vigente_desde, vigente_hasta from public.c_categoria_depreciacion order by orden;
