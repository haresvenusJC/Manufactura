-- =====================================================================
--  Horario laboral del empleado (días de la semana, entrada, salida y receso)
--  Fecha: 2026-10-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  empleados.horario_laboral (jsonb) = lista con un renglón por día que labora:
--    [{"dia": 1, "entrada": "08:00", "salida": "17:00", "receso_min": 60}, ...]
--  dia: 1 = lunes … 7 = domingo. Hora en formato 24 h. Si la salida es menor que la
--  entrada, el turno cruza la medianoche. receso_min = minutos de receso dentro del turno.
--
--  Regla de integridad en la base (no solo en pantalla): días entre 1 y 7 y SIN repetirse,
--  horas con formato HH:MM, entrada distinta de salida y receso entero >= 0.
--
--  Idempotente. No cambia datos existentes.
-- =====================================================================

begin;

alter table public.empleados
    add column if not exists horario_laboral jsonb;

comment on column public.empleados.horario_laboral is
  'Horario semanal: [{dia 1-7, entrada HH:MM, salida HH:MM, receso_min}], un renglón por día laborado. Null = sin horario capturado.';

create or replace function public._empleado_horario_valido()
returns trigger
language plpgsql
as $$
declare
    v_el   jsonb;
    v_dias integer[] := '{}';
    v_dia  integer;
begin
    if new.horario_laboral is null then
        return new;
    end if;
    if jsonb_typeof(new.horario_laboral) <> 'array' then
        raise exception 'El horario laboral debe ser una lista de días.';
    end if;
    for v_el in select * from jsonb_array_elements(new.horario_laboral) loop
        begin
            v_dia := (v_el->>'dia')::integer;
        exception when others then
            raise exception 'Horario laboral: día inválido.';
        end;
        if v_dia is null or v_dia < 1 or v_dia > 7 then
            raise exception 'Horario laboral: el día debe ser de 1 (lunes) a 7 (domingo).';
        end if;
        if v_dia = any (v_dias) then
            raise exception 'Horario laboral: el día % está repetido.', v_dia;
        end if;
        v_dias := v_dias || v_dia;
        if coalesce(v_el->>'entrada', '') !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'
           or coalesce(v_el->>'salida', '') !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' then
            raise exception 'Horario laboral: las horas deben ir en formato 24 h (HH:MM).';
        end if;
        if (v_el->>'entrada') = (v_el->>'salida') then
            raise exception 'Horario laboral: la entrada y la salida no pueden ser la misma hora.';
        end if;
        if coalesce(v_el->>'receso_min', '0') !~ '^[0-9]+$' then
            raise exception 'Horario laboral: el receso debe ser un número entero de minutos (0 o más).';
        end if;
    end loop;
    return new;
end $$;

drop trigger if exists trg_empleado_horario_valido on public.empleados;
create trigger trg_empleado_horario_valido
    before insert or update of horario_laboral on public.empleados
    for each row execute function public._empleado_horario_valido();

commit;

-- Verificación (opcional):
-- select id, nombre, horario_laboral from public.empleados where horario_laboral is not null;
