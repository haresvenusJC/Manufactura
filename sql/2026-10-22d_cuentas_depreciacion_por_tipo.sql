-- =====================================================================
--  Cuentas contables por TIPO de bien, ligadas a la categoría fiscal
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: 2026-10-21_activo_fijo_en_compras, 2026-10-22_categorias_depreciacion_fiscal
--  (y conviene haber corrido antes 2026-10-22b_codigo_agrupador_sat_2026).
--
--  Para qué: que al elegir la categoría de un equipo (mezcladora = Maquinaria y
--  equipo, laptop = Equipo de cómputo...) el sistema ya sepa, SIN captura:
--    · la cuenta de ACTIVO donde se carga la compra (REC),
--    · la cuenta de DEPRECIACIÓN ACUMULADA (Abono mensual),
--    · el GASTO de depreciación: si el equipo está en un área de PRODUCCIÓN va a
--      un 503.xx (costo indirecto, SAT 504.xx, se prorratea) y si es de oficina /
--      no producción va a un 613.xx (SAT 613 "Depreciación contable").
--  Fuente de los códigos agrupador: Anexo 24 RMF 2026 (DOF 13-ene-2026).
--
--  Qué deja:
--    1. c_categoria_depreciacion gana 4 columnas de cuenta (editables en
--       Configuración -> Tablas -> SAT · Depreciación fiscal).
--    2. Cuentas nuevas (solo si no existen): activo 155.01-159.01, depreciación
--       acumulada 153.03-153.07, CIF 503.20-503.25 y gasto 613.01-613.17.
--       Si un código YA existe con otro nombre, NO se toca (se avisa por NOTICE) y
--       esa categoría queda sin esa cuenta para que la elijas a mano.
--    3. _alta_activos_desde_recepcion reescrita COMPLETA: el equipo que nace de
--       una compra ya trae su cuenta de depreciación acumulada.
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Columnas de cuenta por categoría
-- ---------------------------------------------------------------------
alter table public.c_categoria_depreciacion
    add column if not exists cuenta_activo_id       bigint references public.cuentas_contables (id),
    add column if not exists cuenta_dep_acum_id     bigint references public.cuentas_contables (id),
    add column if not exists cuenta_gasto_cif_id    bigint references public.cuentas_contables (id),
    add column if not exists cuenta_gasto_admin_id  bigint references public.cuentas_contables (id);

comment on column public.c_categoria_depreciacion.cuenta_gasto_cif_id is
  'Gasto de depreciación si el equipo está en un área de PRODUCCIÓN (503.xx, costo indirecto que se prorratea).';
comment on column public.c_categoria_depreciacion.cuenta_gasto_admin_id is
  'Gasto de depreciación si el equipo está en un área que NO es de producción (613.xx).';

-- ---------------------------------------------------------------------
-- 2. Cuentas nuevas (no pisa nada existente)
-- ---------------------------------------------------------------------
create temp table _cta_dep (
    codigo text primary key, nombre text not null, agrup text not null,
    nat char(1) not null, tipo text not null, nivel smallint not null, padre text, cif text
) on commit drop;

insert into _cta_dep (codigo, nombre, agrup, nat, tipo, nivel, padre, cif) values
    -- Mayores
    ('155', 'Mobiliario y equipo de oficina',          '155', 'D', 'activo', 1, null, null),
    ('156', 'Equipo de transporte',                    '154', 'D', 'activo', 1, null, null),
    ('157', 'Equipo de comunicación',                  '157', 'D', 'activo', 1, null, null),
    ('158', 'Edificios y construcciones',              '152', 'D', 'activo', 1, null, null),
    ('159', 'Adaptaciones y mejoras',                  '170', 'D', 'activo', 1, null, null),
    ('613', 'Depreciación contable (administración)',  '613', 'D', 'gasto',  1, null, null),
    -- Activo
    ('155.01', 'Mobiliario y equipo de oficina',                       '155.01', 'D', 'activo', 2, '155', null),
    ('156.01', 'Equipo de transporte (automóviles, camiones)',         '154.01', 'D', 'activo', 2, '156', null),
    ('157.01', 'Equipo de comunicación',                               '157.01', 'D', 'activo', 2, '157', null),
    ('158.01', 'Edificios y construcciones',                           '152.01', 'D', 'activo', 2, '158', null),
    ('159.01', 'Adaptaciones y mejoras',                               '170.01', 'D', 'activo', 2, '159', null),
    -- Depreciación acumulada
    ('153.03', 'Depreciación acumulada de mobiliario y equipo de oficina',     '171.04', 'A', 'activo', 2, '153', null),
    ('153.04', 'Depreciación acumulada de equipo de transporte',               '171.03', 'A', 'activo', 2, '153', null),
    ('153.05', 'Depreciación acumulada de equipo de comunicación',             '171.06', 'A', 'activo', 2, '153', null),
    ('153.06', 'Depreciación acumulada de edificios y construcciones',         '171.01', 'A', 'activo', 2, '153', null),
    ('153.07', 'Depreciación acumulada de adaptaciones y mejoras',             '171.17', 'A', 'activo', 2, '153', null),
    -- Gasto de depreciación en PRODUCCIÓN (CIF fijo; 503.04 ya existe = maquinaria)
    ('503.20', 'Depreciación de equipo de cómputo (planta)',           '504.11', 'D', 'costo', 2, '503', 'fijo'),
    ('503.21', 'Depreciación de mobiliario y equipo (planta)',         '504.10', 'D', 'costo', 2, '503', 'fijo'),
    ('503.22', 'Depreciación de equipo de transporte (planta)',        '504.09', 'D', 'costo', 2, '503', 'fijo'),
    ('503.23', 'Depreciación de equipo de comunicación (planta)',      '504.12', 'D', 'costo', 2, '503', 'fijo'),
    ('503.24', 'Depreciación de edificios y construcciones (planta)',  '504.07', 'D', 'costo', 2, '503', 'fijo'),
    ('503.25', 'Depreciación de adaptaciones y mejoras (planta)',      '504.23', 'D', 'costo', 2, '503', 'fijo'),
    -- Gasto de depreciación en ADMINISTRACIÓN / no producción
    ('613.01', 'Depreciación de edificios y construcciones',           '613.01', 'D', 'gasto', 2, '613', null),
    ('613.02', 'Depreciación de maquinaria y equipo',                  '613.02', 'D', 'gasto', 2, '613', null),
    ('613.03', 'Depreciación de equipo de transporte',                 '613.03', 'D', 'gasto', 2, '613', null),
    ('613.04', 'Depreciación de mobiliario y equipo de oficina',       '613.04', 'D', 'gasto', 2, '613', null),
    ('613.05', 'Depreciación de equipo de cómputo',                    '613.05', 'D', 'gasto', 2, '613', null),
    ('613.06', 'Depreciación de equipo de comunicación',               '613.06', 'D', 'gasto', 2, '613', null),
    ('613.17', 'Depreciación de adaptaciones y mejoras',               '613.17', 'D', 'gasto', 2, '613', null);

do $$
declare
    r record; v_padre bigint; v_n integer := 0;
begin
    for r in select * from _cta_dep order by nivel, codigo loop
        select id, nombre into v_padre from public.cuentas_contables where false;   -- reset
        if exists (select 1 from public.cuentas_contables where codigo = r.codigo) then
            if not exists (select 1 from public.cuentas_contables where codigo = r.codigo and nombre = r.nombre) then
                raise notice 'La cuenta % ya existe con OTRO nombre: no se toca. Elige a mano la cuenta de esa categoría en Tablas.', r.codigo;
            end if;
            continue;
        end if;
        select id into v_padre from public.cuentas_contables where codigo = r.padre;
        insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, cuenta_padre_id, afectable, activa)
        values (r.codigo, r.nombre, r.agrup, r.nat, r.tipo, r.nivel, v_padre, r.nivel > 1, true);
        if r.cif is not null then
            update public.cuentas_contables set cif_tipo = r.cif where codigo = r.codigo;
        end if;
        v_n := v_n + 1;
    end loop;
    raise notice 'Cuentas creadas: %', v_n;
end $$;

-- ---------------------------------------------------------------------
-- 3. Cuentas por categoría (solo donde aún no hay una elegida)
--    Un renglón por GRUPO de tipo de bien; la categoría se reconoce por su nombre.
-- ---------------------------------------------------------------------
create temp table _cat_cta (patron text, activo text, acum text, cif text, adm text) on commit drop;
insert into _cat_cta values
    ('Maquinaria%',                          '152.01', '153.01', '503.04', '613.02'),
    ('Equipo de cómputo%',                   '154.01', '153.02', '503.20', '613.05'),
    ('Mobiliario%',                          '155.01', '153.03', '503.21', '613.04'),
    ('Equipo de transporte%',                '156.01', '153.04', '503.22', '613.03'),
    ('Automóviles%',                         '156.01', '153.04', '503.22', '613.03'),
    ('Equipo de comunicación%',              '157.01', '153.05', '503.23', '613.06'),
    ('Edificios y construcciones%',          '158.01', '153.06', '503.24', '613.01'),
    ('Adaptaciones%',                        '159.01', '153.07', '503.25', '613.17');

update public.c_categoria_depreciacion c
   set cuenta_activo_id      = coalesce(c.cuenta_activo_id,      (select id from public.cuentas_contables where codigo = m.activo)),
       cuenta_dep_acum_id    = coalesce(c.cuenta_dep_acum_id,    (select id from public.cuentas_contables where codigo = m.acum)),
       cuenta_gasto_cif_id   = coalesce(c.cuenta_gasto_cif_id,   (select id from public.cuentas_contables where codigo = m.cif)),
       cuenta_gasto_admin_id = coalesce(c.cuenta_gasto_admin_id, (select id from public.cuentas_contables where codigo = m.adm))
  from _cat_cta m
 where c.grupo = 'depreciacion' and c.categoria ilike m.patron;

-- ---------------------------------------------------------------------
-- 4. _alta_activos_desde_recepcion — cuerpo COMPLETO (base: 2026-10-22)
--    Cambio: el activo que nace de la compra copia de su categoría la cuenta de
--    depreciación acumulada (el gasto depende del área y se fija al "Completar").
--    La cuenta de activo es la del artículo (la misma que ya cargó la póliza REC);
--    si el artículo no tiene, usa la de su categoría y, al final, 152.01.
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
    v_cat_id bigint; v_cat_nom text; v_cat_pct numeric; v_cat_tope numeric; v_cat_activo bigint; v_cat_acum bigint;
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

        v_cat_id := null; v_cat_nom := null; v_cat_pct := null; v_cat_tope := null; v_cat_activo := null; v_cat_acum := null;
        if r.categoria_depreciacion_id is not null then
            select c2.id, c2.categoria, c2.pct_anual, c2.tope_deducible, c2.cuenta_activo_id, c2.cuenta_dep_acum_id
              into v_cat_id, v_cat_nom, v_cat_pct, v_cat_tope, v_cat_activo, v_cat_acum
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
             cuenta_depreciacion_acumulada_id,
             pendiente, depreciable, producto_id, documento_id, documento_detalle_id,
             orden_compra_id, proveedor_id, poliza_compra_id,
             categoria_depreciacion_id, pct_fiscal, tope_fiscal, ejercicio_fiscal, notas)
        values
            (r.nombre, v_cat_nom, v_doc.fecha_emision, v_costo, 0, coalesce(r.cuenta_inventario_id, v_cat_activo, v_cta_def),
             v_cat_acum,
             true, true, r.producto_id, p_documento_id, r.det_id,
             v_doc.orden_compra_id, v_doc.proveedor_id, p_poliza_id,
             v_cat_id, v_cat_pct, v_cat_tope, case when v_cat_id is not null then v_anio end,
             'Alta automática al recibir ' || coalesce(v_doc.folio, '#' || p_documento_id)
                 || '. Falta completar: área, etapas y si se deprecia.');
        v_n := v_n + 1;
    end loop;

    return v_n;
end;
$$;

revoke all on function public._alta_activos_desde_recepcion(bigint, bigint) from public, anon;

commit;

-- Verificación (opcional):
-- select c.categoria, a.codigo as activo, d.codigo as acumulada, g.codigo as gasto_prod, m.codigo as gasto_admin
--   from public.c_categoria_depreciacion c
--   left join public.cuentas_contables a on a.id = c.cuenta_activo_id
--   left join public.cuentas_contables d on d.id = c.cuenta_dep_acum_id
--   left join public.cuentas_contables g on g.id = c.cuenta_gasto_cif_id
--   left join public.cuentas_contables m on m.id = c.cuenta_gasto_admin_id
--  order by c.orden;
