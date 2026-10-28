-- =====================================================================
--  Activos fijos: carga de equipos existentes (póliza APE) y baja (póliza BAJ)
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: 2026-10-15_equipos_unificados, 2026-10-21_activo_fijo_en_compras,
--            2026-10-22_categorias_depreciacion_fiscal, 2026-10-22d_cuentas_depreciacion_por_tipo.
--
--  Qué resuelve:
--   1. Un equipo que YA tenías (carga inicial) no puede darse de alta como
--      "depreciable" sin más: el sistema volvería a depreciar su costo completo.
--      Ahora se registra con su depreciación acumulada al corte y los meses ya
--      depreciados; la depreciación mensual continúa desde ahí.
--      Póliza APE (Diario): Cargo cuenta de activo (costo) / Abono depreciación
--      acumulada / Abono contrapartida (valor en libros; 304.01 por defecto).
--      Si el equipo ya está 100 % depreciado no hay renglón de contrapartida.
--   2. La baja de un equipo solo marcaba la fecha. Ahora genera la póliza BAJ
--      (Diario): Cargo depreciación acumulada + Cargo pérdida por el valor en
--      libros (601.99 por defecto) / Abono cuenta de activo (costo).
--      Esta versión cubre la baja SIN venta; si lo vendes, registra la venta y su
--      IVA con la salida de ventas y da de baja con valor en libros 0 solo si
--      el contador lo indica.
--   3. depreciacion_calcular reescrita COMPLETA: suma la acumulada inicial y los
--      meses iniciales, y empieza después de la fecha de corte.
--   4. Series de póliza: APE (apertura de activo fijo) y BAJ (baja de activo fijo).
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Series de póliza
-- ---------------------------------------------------------------------
insert into public.polizas_series_origen (origen, serie, que_es) values
    ('apertura_activo', 'APE', 'Apertura (carga inicial) de un activo fijo que ya existía'),
    ('baja_activo',     'BAJ', 'Baja de un activo fijo')
on conflict (origen) do update set serie = excluded.serie, que_es = excluded.que_es;

-- ---------------------------------------------------------------------
-- 2. Columnas nuevas
-- ---------------------------------------------------------------------
alter table public.activos_fijos
    add column if not exists modelo                 text,
    add column if not exists numero_serie           text,
    add column if not exists garantia_vence         date,
    add column if not exists usado                  boolean not null default false,
    add column if not exists acum_inicial           numeric(14,2) not null default 0 check (acum_inicial >= 0),
    add column if not exists meses_dep_inicial      integer       not null default 0 check (meses_dep_inicial >= 0),
    add column if not exists fecha_corte_apertura   date,
    add column if not exists poliza_apertura_id     bigint,
    add column if not exists poliza_baja_id         bigint;

comment on column public.activos_fijos.acum_inicial is
  'Depreciación acumulada con la que entró el equipo al ERP (carga inicial). La depreciación mensual del ERP se suma a esta cifra.';
comment on column public.activos_fijos.fecha_corte_apertura is
  'Fecha de corte de la carga inicial: la depreciación del ERP empieza el mes siguiente.';

-- ---------------------------------------------------------------------
-- 3. depreciacion_calcular — cuerpo COMPLETO (base: 2026-10-15)
--    Cambios: acumulada y meses previos incluyen los iniciales de la carga;
--    no deprecia meses anteriores o iguales a la fecha de corte; nunca pasa
--    de (costo - residual).
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
    with base as (
        select a.id as aid, a.nombre as anombre, a.costo_adquisicion as acosto, a.valor_residual as ares,
               a.vida_util_meses as avida,
               (coalesce((select count(*) from public.activos_fijos_depreciaciones d
                           where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0)
                + coalesce(a.meses_dep_inicial, 0))::int as meses_prev,
               (coalesce((select sum(d.monto) from public.activos_fijos_depreciaciones d
                           where d.activo_id = a.id and (d.anio < p_anio or (d.anio = p_anio and d.mes < p_mes))), 0)
                + coalesce(a.acum_inicial, 0)) as acum_prev
          from public.activos_fijos a
         where a.activo = true
           and a.depreciable = true
           and a.costo_adquisicion is not null
           and a.vida_util_meses is not null
           and a.fecha_adquisicion <= v_hasta
           and (a.fecha_baja is null or a.fecha_baja > v_hasta)
           and (a.fecha_corte_apertura is null or v_hasta > a.fecha_corte_apertura)
           and not exists (select 1 from public.activos_fijos_depreciaciones d2
                            where d2.activo_id = a.id and d2.anio = p_anio and d2.mes = p_mes)
           and a.cuenta_depreciacion_gasto_id is not null
           and a.cuenta_depreciacion_acumulada_id is not null
    )
    select b.aid, b.anombre, b.acosto, b.ares, b.avida, b.meses_prev, b.acum_prev,
           least(round((b.acosto - b.ares) / b.avida, 2), greatest(0, (b.acosto - b.ares) - b.acum_prev)),
           b.acosto - b.acum_prev
      from base b
     order by b.anombre;
end;
$$;

grant execute on function public.depreciacion_calcular(integer, integer) to authenticated;

-- ---------------------------------------------------------------------
-- 4. activo_fijo_apertura — alta de un equipo existente (+ póliza APE opcional)
--    p_datos: nombre, categoria_depreciacion_id, fecha_adquisicion, costo, vida_util_meses,
--      valor_residual, fecha_corte, meses_depreciados (opcional: si falta se calcula),
--      area_id, tipo_carga, potencia_kw, cantidad, factor_uso, modelo, numero_serie,
--      proveedor_id, notas, cuenta_activo_id, cuenta_dep_acum_id, cuenta_gasto_id,
--      cuenta_contrapartida_id (default 304.01), generar_poliza (default true), etapas [ids]
-- ---------------------------------------------------------------------
create or replace function public.activo_fijo_apertura(p_datos jsonb)
returns jsonb
language plpgsql
volatile
set search_path = public
as $$
declare
    v_nombre   text    := nullif(trim(p_datos->>'nombre'), '');
    v_adq      date    := (p_datos->>'fecha_adquisicion')::date;
    v_corte    date    := (p_datos->>'fecha_corte')::date;
    v_costo    numeric(14,2) := round(coalesce((p_datos->>'costo')::numeric, 0), 2);
    v_res      numeric(14,2) := round(coalesce((p_datos->>'valor_residual')::numeric, 0), 2);
    v_vida     integer := (p_datos->>'vida_util_meses')::integer;
    v_meses    integer;
    v_mensual  numeric(14,2);
    v_acum     numeric(14,2);
    v_vl       numeric(14,2);
    v_cat      record;
    v_cta_act  bigint  := (p_datos->>'cuenta_activo_id')::bigint;
    v_cta_acum bigint  := (p_datos->>'cuenta_dep_acum_id')::bigint;
    v_cta_gas  bigint  := (p_datos->>'cuenta_gasto_id')::bigint;
    v_cta_cont bigint  := coalesce((p_datos->>'cuenta_contrapartida_id')::bigint, public._cuenta_id('304.01'));
    v_gen      boolean := coalesce((p_datos->>'generar_poliza')::boolean, true);
    v_id       bigint;
    v_pol      jsonb;
    v_pol_id   bigint;
    v_movs     jsonb;
    e          bigint;
begin
    if v_nombre is null then raise exception 'El nombre del equipo es obligatorio.'; end if;
    if v_adq is null or v_corte is null then raise exception 'La fecha de adquisición y la fecha de corte son obligatorias.'; end if;
    if v_corte < v_adq then raise exception 'La fecha de corte no puede ser anterior a la adquisición.'; end if;
    if v_costo <= 0 then raise exception 'El costo histórico debe ser mayor a 0.'; end if;
    if coalesce(v_vida, 0) <= 0 then raise exception 'La vida útil original debe ser mayor a 0 meses.'; end if;
    if v_res < 0 or v_res >= v_costo then raise exception 'El valor residual debe ser menor al costo.'; end if;
    if v_cta_act is null or v_cta_acum is null or v_cta_gas is null then
        raise exception 'Faltan las cuentas del equipo (activo, depreciación acumulada y gasto de depreciación).';
    end if;
    if (p_datos->>'area_id') is null then raise exception 'Elige el área donde está el equipo.'; end if;

    -- Meses ya depreciados al corte: por default desde el mes de adquisición (inclusive) hasta el mes del corte.
    v_meses := coalesce((p_datos->>'meses_depreciados')::integer,
                        ((extract(year from v_corte) - extract(year from v_adq)) * 12
                         + extract(month from v_corte) - extract(month from v_adq) + 1)::integer);
    v_meses := greatest(0, least(v_meses, v_vida));
    v_mensual := round((v_costo - v_res) / v_vida, 2);
    v_acum := case when v_meses >= v_vida then v_costo - v_res else least(v_costo - v_res, round(v_mensual * v_meses, 2)) end;
    v_vl := v_costo - v_acum;

    select * into v_cat from public.c_categoria_depreciacion where id = (p_datos->>'categoria_depreciacion_id')::bigint;

    insert into public.activos_fijos
        (nombre, categoria, fecha_adquisicion, costo_adquisicion, valor_residual, vida_util_meses,
         cuenta_activo_id, cuenta_depreciacion_gasto_id, cuenta_depreciacion_acumulada_id,
         depreciable, pendiente, area_id, tipo_carga, potencia_kw, cantidad, factor_uso,
         categoria_depreciacion_id, pct_fiscal, tope_fiscal, ejercicio_fiscal,
         modelo, numero_serie, proveedor_id, notas,
         acum_inicial, meses_dep_inicial, fecha_corte_apertura)
    values
        (v_nombre, v_cat.categoria, v_adq, v_costo, v_res, v_vida,
         v_cta_act, v_cta_gas, v_cta_acum,
         true, false, (p_datos->>'area_id')::bigint, coalesce(nullif(p_datos->>'tipo_carga', ''), 'equipo'),
         coalesce((p_datos->>'potencia_kw')::numeric, 0), coalesce((p_datos->>'cantidad')::smallint, 1),
         coalesce((p_datos->>'factor_uso')::numeric, 1),
         v_cat.id, v_cat.pct_anual, v_cat.tope_deducible,
         case when v_cat.id is not null then extract(year from v_adq)::smallint end,
         nullif(p_datos->>'modelo', ''), nullif(p_datos->>'numero_serie', ''),
         (p_datos->>'proveedor_id')::bigint, nullif(p_datos->>'notas', ''),
         v_acum, v_meses, v_corte)
    returning id into v_id;

    if p_datos ? 'etapas' and jsonb_typeof(p_datos->'etapas') = 'array' then
        for e in select (x)::bigint from jsonb_array_elements_text(p_datos->'etapas') x loop
            insert into public.activos_fijos_centros (activo_id, centro_costo_id) values (v_id, e);
        end loop;
    end if;

    if v_gen then
        if v_vl > 0 and v_cta_cont is null then
            raise exception 'No hay cuenta de contrapartida para el valor en libros (304.01 no existe): elige una.';
        end if;
        v_movs := jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_act,  'cargo', v_costo, 'abono', 0, 'concepto', 'Apertura ' || v_nombre));
        if v_acum > 0 then
            v_movs := v_movs || jsonb_build_array(
                jsonb_build_object('cuenta_id', v_cta_acum, 'cargo', 0, 'abono', v_acum, 'concepto', 'Depreciación acumulada al corte · ' || v_nombre));
        end if;
        if v_vl > 0 then
            v_movs := v_movs || jsonb_build_array(
                jsonb_build_object('cuenta_id', v_cta_cont, 'cargo', 0, 'abono', v_vl, 'concepto', 'Valor en libros de apertura · ' || v_nombre));
        end if;
        v_pol := public.registrar_poliza(jsonb_build_object(
            'fecha', v_corte, 'tipo', 'Diario',
            'concepto', 'Apertura de activo fijo · ' || v_nombre,
            'origen', 'apertura_activo', 'origen_tabla', 'activos_fijos', 'origen_id', v_id,
            'movimientos', v_movs));
        v_pol_id := (v_pol->>'poliza_id')::bigint;
        update public.activos_fijos set poliza_apertura_id = v_pol_id where id = v_id;
    end if;

    return jsonb_build_object('activo_id', v_id, 'poliza_id', v_pol_id, 'meses_depreciados', v_meses,
                              'depreciacion_acumulada', v_acum, 'valor_en_libros', v_vl,
                              'meses_por_depreciar', greatest(0, v_vida - v_meses));
end;
$$;

grant execute on function public.activo_fijo_apertura(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 5. activo_fijo_baja — baja SIN venta con póliza BAJ
--    p_datos: activo_id, fecha_baja, motivo, cuenta_perdida_id (default 601.99)
-- ---------------------------------------------------------------------
create or replace function public.activo_fijo_baja(p_datos jsonb)
returns jsonb
language plpgsql
volatile
set search_path = public
as $$
declare
    v_id     bigint := (p_datos->>'activo_id')::bigint;
    v_fecha  date   := coalesce((p_datos->>'fecha_baja')::date, current_date);
    v_motivo text   := nullif(trim(p_datos->>'motivo'), '');
    v_a      public.activos_fijos%rowtype;
    v_acum   numeric(14,2);
    v_vl     numeric(14,2);
    v_perd   bigint := coalesce((p_datos->>'cuenta_perdida_id')::bigint, public._cuenta_id('601.99'));
    v_movs   jsonb;
    v_pol    jsonb;
    v_pol_id bigint;
begin
    select * into v_a from public.activos_fijos where id = v_id for update;
    if not found then raise exception 'El activo % no existe.', v_id; end if;
    if v_a.fecha_baja is not null then raise exception 'Este activo ya está dado de baja (%).', v_a.fecha_baja; end if;
    if v_motivo is null then raise exception 'Escribe el motivo de la baja.'; end if;

    -- Un equipo que nunca se activó (pendiente de completar) no tiene costo en libros que dar de baja con acumulada.
    v_acum := coalesce(v_a.acum_inicial, 0)
              + coalesce((select sum(d.monto) from public.activos_fijos_depreciaciones d where d.activo_id = v_id), 0);
    v_vl := coalesce(v_a.costo_adquisicion, 0) - v_acum;

    if coalesce(v_a.costo_adquisicion, 0) > 0 and v_a.cuenta_activo_id is not null then
        if v_vl > 0 and v_perd is null then
            raise exception 'No hay cuenta de pérdida (601.99 no existe): elige una.';
        end if;
        v_movs := '[]'::jsonb;
        if v_acum > 0 then
            if v_a.cuenta_depreciacion_acumulada_id is null then
                raise exception 'El activo tiene depreciación acumulada pero no su cuenta de depreciación acumulada.';
            end if;
            v_movs := v_movs || jsonb_build_array(jsonb_build_object(
                'cuenta_id', v_a.cuenta_depreciacion_acumulada_id, 'cargo', v_acum, 'abono', 0, 'concepto', 'Baja · depreciación acumulada ' || v_a.nombre));
        end if;
        if v_vl > 0 then
            v_movs := v_movs || jsonb_build_array(jsonb_build_object(
                'cuenta_id', v_perd, 'cargo', v_vl, 'abono', 0, 'concepto', 'Pérdida por baja de ' || v_a.nombre));
        end if;
        v_movs := v_movs || jsonb_build_array(jsonb_build_object(
            'cuenta_id', v_a.cuenta_activo_id, 'cargo', 0, 'abono', v_a.costo_adquisicion, 'concepto', 'Baja de ' || v_a.nombre));
        v_pol := public.registrar_poliza(jsonb_build_object(
            'fecha', v_fecha, 'tipo', 'Diario',
            'concepto', 'Baja de activo fijo · ' || v_a.nombre || ' · ' || v_motivo,
            'origen', 'baja_activo', 'origen_tabla', 'activos_fijos', 'origen_id', v_id,
            'movimientos', v_movs));
        v_pol_id := (v_pol->>'poliza_id')::bigint;
    end if;

    update public.activos_fijos
       set activo = false, fecha_baja = v_fecha, motivo_baja = v_motivo, poliza_baja_id = v_pol_id
     where id = v_id;

    return jsonb_build_object('poliza_id', v_pol_id, 'depreciacion_acumulada', v_acum, 'valor_en_libros', v_vl);
end;
$$;

grant execute on function public.activo_fijo_baja(jsonb) to authenticated;

commit;
