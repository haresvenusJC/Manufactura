-- =====================================================================
--  Departamento superior (jerarquía) y rol del empleado en su departamento
--  Fecha: 2026-10-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere haber corrido antes sql/2026-10-28_departamentos_gerente_foto.sql.
--
--  Modelo (pedido del usuario 2026-10-30):
--    · departamentos.departamento_padre_id: un departamento puede ser hijo de
--      otro (Finanzas -> Cuentas por pagar). Sin círculos.
--    · empleados.rol_departamento: 'responsable' o 'colaborador'. Es la ÚNICA
--      fuente de quién dirige un departamento (lo captura RH en la plantilla del
--      empleado). Solo puede haber UN responsable activo por departamento.
--    · departamentos.responsable_id se conserva, pero ahora lo calcula la base
--      desde el rol del empleado (así firmas.js, Organigrama y la sugerencia de
--      Gerente siguen funcionando sin cambios). La pantalla ya no lo escribe.
--
--  El puesto sigue siendo texto libre ("Jefe de Contabilidad"): la etiqueta
--  oficial la da el rol, el puesto solo describe.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Departamento superior, sin círculos
-- ---------------------------------------------------------------------
alter table public.departamentos
    add column if not exists departamento_padre_id bigint references public.departamentos (id) on delete set null;

create index if not exists departamentos_padre_idx on public.departamentos (departamento_padre_id);

comment on column public.departamentos.departamento_padre_id is
  'Departamento superior (jerarquía). Vacío = departamento de primer nivel.';

create or replace function public._departamento_padre_sin_ciclo()
returns trigger
language plpgsql
as $$
declare
    v_actual bigint := new.departamento_padre_id;
    v_pasos  integer := 0;
begin
    if new.departamento_padre_id is null then
        return new;
    end if;
    if new.departamento_padre_id = new.id then
        raise exception 'Un departamento no puede ser su propio superior.';
    end if;
    while v_actual is not null loop
        if v_actual = new.id then
            raise exception 'Ese departamento depende de este: la jerarquía quedaría en círculo.';
        end if;
        select d.departamento_padre_id into v_actual from public.departamentos d where d.id = v_actual;
        v_pasos := v_pasos + 1;
        if v_pasos > 50 then
            raise exception 'La jerarquía de departamentos es demasiado larga o ya estaba en círculo.';
        end if;
    end loop;
    return new;
end $$;

drop trigger if exists trg_departamento_padre_sin_ciclo on public.departamentos;
create trigger trg_departamento_padre_sin_ciclo
    before insert or update of departamento_padre_id on public.departamentos
    for each row execute function public._departamento_padre_sin_ciclo();

-- ---------------------------------------------------------------------
-- 2. Rol del empleado en su departamento
-- ---------------------------------------------------------------------
alter table public.empleados
    add column if not exists rol_departamento text;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'empleados_rol_departamento_chk') then
        alter table public.empleados
            add constraint empleados_rol_departamento_chk
            check (rol_departamento is null or rol_departamento in ('responsable', 'colaborador'));
    end if;
end $$;

comment on column public.empleados.rol_departamento is
  'Responsable de Departamento o Colaborador de Departamento. Define quién dirige el departamento (departamentos.responsable_id se calcula de aquí).';

-- Relleno inicial: el responsable que ya tenía cada departamento (si pertenece a él) y los demás, colaboradores.
update public.empleados e
   set rol_departamento = 'responsable'
  from public.departamentos d
 where d.responsable_id = e.id
   and e.departamento_id = d.id
   and e.activo
   and e.rol_departamento is null;

update public.empleados
   set rol_departamento = 'colaborador'
 where departamento_id is not null
   and rol_departamento is null;

-- Un solo responsable activo por departamento
create unique index if not exists empleados_un_responsable_por_departamento
    on public.empleados (departamento_id)
    where rol_departamento = 'responsable' and activo and departamento_id is not null;

-- ---------------------------------------------------------------------
-- 3. departamentos.responsable_id se calcula desde el rol
-- ---------------------------------------------------------------------
create or replace function public._departamento_recalcular_responsable(p_departamento_id bigint)
returns void
language plpgsql
as $$
begin
    if p_departamento_id is null then
        return;
    end if;
    update public.departamentos d
       set responsable_id = (
            select e.id from public.empleados e
             where e.departamento_id = d.id
               and e.rol_departamento = 'responsable'
               and e.activo
             order by e.id
             limit 1)
     where d.id = p_departamento_id;
end $$;

create or replace function public._empleado_sincroniza_responsable()
returns trigger
language plpgsql
as $$
begin
    if tg_op = 'UPDATE' and old.departamento_id is distinct from new.departamento_id then
        perform public._departamento_recalcular_responsable(old.departamento_id);
    end if;
    if tg_op = 'DELETE' then
        perform public._departamento_recalcular_responsable(old.departamento_id);
        return old;
    end if;
    perform public._departamento_recalcular_responsable(new.departamento_id);
    return new;
end $$;

drop trigger if exists trg_empleado_sincroniza_responsable on public.empleados;
create trigger trg_empleado_sincroniza_responsable
    after insert or delete or update of rol_departamento, departamento_id, activo on public.empleados
    for each row execute function public._empleado_sincroniza_responsable();

-- Alinear lo existente
update public.departamentos d
   set responsable_id = (
        select e.id from public.empleados e
         where e.departamento_id = d.id and e.rol_departamento = 'responsable' and e.activo
         order by e.id limit 1);

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select d.nombre, p.nombre as superior, r.nombre as responsable from public.departamentos d
--   left join public.departamentos p on p.id = d.departamento_padre_id
--   left join public.empleados r on r.id = d.responsable_id order by 1;
