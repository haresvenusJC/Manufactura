-- =====================================================================
--  Activos fijos y depreciación (NIF C-6, línea recta)
--  Fecha: 2026-10-02  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Catálogo de activos fijos (maquinaria, equipo, vehículos...) con su
--  depreciación mensual en línea recta: (costo - valor residual) / vida
--  útil en meses, aplicada mes a mes con su propia póliza (cargo a gasto
--  de depreciación, abono a depreciación acumulada — nunca directo al
--  activo, para poder ver en el Balance cuánto vale en libros).
--
--  Ya existían cuentas de activo para maquinaria (152/152.01) y equipo de
--  cómputo (154/154.01), y el gasto de depreciación (503.04, para el CIF
--  de prorrateo) — pero NINGUNA cuenta de "depreciación acumulada"
--  (contra-activo). Este archivo la agrega.
--
--  Idempotente.
-- =====================================================================

begin;

-- =====================================================================
--  1. Cuentas de depreciación acumulada (contra-activo: naturaleza 'A'
--     aunque su tipo siga siendo 'activo' — es lo que hace que reste en
--     el Balance en vez de sumar).
-- =====================================================================
insert into public.cuentas_contables (codigo, nombre, naturaleza, tipo, nivel, afectable, activa)
values ('153', 'Depreciación acumulada', 'A', 'activo', 1, false, true)
on conflict (codigo) do nothing;

insert into public.cuentas_contables (codigo, nombre, naturaleza, tipo, nivel, cuenta_padre_id, afectable, activa)
select '153.01', 'Depreciación acumulada de maquinaria y equipo', 'A', 'activo', 2, id, true, true
  from public.cuentas_contables where codigo = '153'
on conflict (codigo) do nothing;

insert into public.cuentas_contables (codigo, nombre, naturaleza, tipo, nivel, cuenta_padre_id, afectable, activa)
select '153.02', 'Depreciación acumulada de equipo de cómputo', 'A', 'activo', 2, id, true, true
  from public.cuentas_contables where codigo = '153'
on conflict (codigo) do nothing;

-- =====================================================================
--  2. Catálogo de activos fijos
-- =====================================================================
create table if not exists public.activos_fijos (
    id                              bigint generated always as identity primary key,
    nombre                          text not null,
    categoria                       text,
    fecha_adquisicion               date not null,
    costo_adquisicion               numeric(14,2) not null check (costo_adquisicion > 0),
    valor_residual                  numeric(14,2) not null default 0,
    vida_util_meses                 integer not null check (vida_util_meses > 0),
    cuenta_activo_id                bigint references public.cuentas_contables (id),
    cuenta_depreciacion_gasto_id    bigint references public.cuentas_contables (id),
    cuenta_depreciacion_acumulada_id bigint references public.cuentas_contables (id),
    fecha_baja                      date,
    motivo_baja                     text,
    activo                          boolean not null default true,
    notas                           text,
    created_at                      timestamptz not null default now()
);

create index if not exists activos_fijos_activo_idx on public.activos_fijos (activo);

-- Historial de depreciación mensual ya aplicada (una fila por activo por mes).
create table if not exists public.activos_fijos_depreciaciones (
    id          bigint generated always as identity primary key,
    activo_id   bigint not null references public.activos_fijos (id) on delete cascade,
    anio        integer not null,
    mes         integer not null check (mes between 1 and 12),
    monto       numeric(14,2) not null,
    poliza_id   bigint references public.polizas (id),
    created_at  timestamptz not null default now(),
    unique (activo_id, anio, mes)
);

alter table public.activos_fijos               enable row level security;
alter table public.activos_fijos_depreciaciones enable row level security;
drop policy if exists admin_all on public.activos_fijos;
drop policy if exists admin_all on public.activos_fijos_depreciaciones;
create policy admin_all on public.activos_fijos
    for all to authenticated using (true) with check (true);
create policy admin_all on public.activos_fijos_depreciaciones
    for all to authenticated using (true) with check (true);
grant all on public.activos_fijos, public.activos_fijos_depreciaciones to authenticated;

-- Bitácora de cambios (reusa el trigger genérico que ya existe).
drop trigger if exists trg_bitacora_activos_fijos on public.activos_fijos;
create trigger trg_bitacora_activos_fijos
    after insert or update or delete on public.activos_fijos
    for each row execute function public.fn_bitacora_generica();

-- =====================================================================
--  3. depreciacion_calcular: vista previa de lo que tocaría aplicar en
--     un año-mes — no escribe nada.
-- =====================================================================
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
       and a.fecha_adquisicion <= v_hasta
       and (a.fecha_baja is null or a.fecha_baja > v_hasta)
       and not exists (select 1 from public.activos_fijos_depreciaciones d2
                         where d2.activo_id = a.id and d2.anio = p_anio and d2.mes = p_mes)
       and a.cuenta_depreciacion_gasto_id is not null
       and a.cuenta_depreciacion_acumulada_id is not null
     order by a.nombre;
end;
$$;

-- =====================================================================
--  4. depreciacion_aplicar: genera UNA póliza con el gasto de todos los
--     activos del mes y deja el historial por activo.
-- =====================================================================
create or replace function public.depreciacion_aplicar(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
volatile
set search_path = public
as $$
declare
    v_fecha         date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
    v_fila          record;
    v_movs          jsonb := '[]'::jsonb;
    v_activos_montos jsonb := '[]'::jsonb;
    v_total         numeric(14,2) := 0;
    v_poliza        jsonb;
    v_poliza_id     bigint;
    v_activo_montos record;
begin
    for v_fila in
        select c.*, a.cuenta_depreciacion_gasto_id, a.cuenta_depreciacion_acumulada_id
          from public.depreciacion_calcular(p_anio, p_mes) c
          join public.activos_fijos a on a.id = c.activo_id
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
        v_activos_montos := v_activos_montos || jsonb_build_object('activo_id', v_fila.activo_id, 'monto', v_fila.monto_mes);
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

    for v_activo_montos in select * from jsonb_to_recordset(v_activos_montos) as x(activo_id bigint, monto numeric)
    loop
        insert into public.activos_fijos_depreciaciones (activo_id, anio, mes, monto, poliza_id)
        values (v_activo_montos.activo_id, p_anio, p_mes, v_activo_montos.monto, v_poliza_id);
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'total', v_total);
end;
$$;

-- =====================================================================
--  5. depreciacion_cancelar: revierte la póliza del mes y borra el
--     historial de ese mes (para poder corregir y volver a aplicar).
-- =====================================================================
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

    perform public.cancelar_poliza(v_poliza_id, 'Cancelación de depreciación ' || p_mes || '/' || p_anio);
    delete from public.activos_fijos_depreciaciones where anio = p_anio and mes = p_mes;
end;
$$;

grant execute on function public.depreciacion_calcular(integer, integer) to authenticated;
grant execute on function public.depreciacion_aplicar(integer, integer) to authenticated;
grant execute on function public.depreciacion_cancelar(integer, integer) to authenticated;

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select codigo, nombre, naturaleza, tipo from public.cuentas_contables where codigo like '153%' order by codigo;
-- select * from public.depreciacion_calcular(extract(year from current_date)::int, extract(month from current_date)::int);
