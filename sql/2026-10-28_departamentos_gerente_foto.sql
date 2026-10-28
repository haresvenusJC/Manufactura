-- =====================================================================
--  Recursos humanos: departamentos, Gerente de cada empleado y foto
--  Fecha: 2026-10-28  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Modelo (el que usa Odoo, pedido del usuario 2026-10-28):
--    · departamentos: catálogo propio (nombre, tipo, centro de costo y
--      responsable). Reemplaza al selector fijo de 4 valores de Empleados.
--    · empleados.gerente_id: UN solo gerente por empleado, elegido entre los
--      mismos empleados. Vacío = cabeza de la organización. De esa cadena sale
--      el organigrama y, más adelante, quién autoriza.
--    · empleados.foto_path: ruta de la foto en el bucket privado 'fotos-personal'.
--
--  Reglas de integridad en la base (no solo en pantalla):
--    · Nadie puede ser su propio gerente ni quedar en círculo (A -> B -> A).
--    · El nombre de un departamento no se repite (sin importar mayúsculas).
--
--  NO cambia datos existentes: la columna de texto empleados.departamento se
--  conserva (la pantalla seguirá escribiéndola con el nombre del departamento) y
--  los 4 valores que ya había se vuelven filas de departamentos.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. departamentos
-- ---------------------------------------------------------------------
create table if not exists public.departamentos (
    id              bigint generated always as identity primary key,
    nombre          text not null,
    tipo            text,
    centro_costo_id bigint references public.centros_costo (id) on delete set null,
    responsable_id  bigint,
    activo          boolean not null default true,
    notas           text,
    created_at      timestamptz not null default now()
);

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'departamentos_tipo_chk') then
        alter table public.departamentos
            add constraint departamentos_tipo_chk
            check (tipo is null or tipo in ('produccion', 'servicio', 'administracion', 'ventas'));
    end if;
    if not exists (select 1 from pg_constraint where conname = 'departamentos_responsable_fk') then
        alter table public.departamentos
            add constraint departamentos_responsable_fk
            foreign key (responsable_id) references public.empleados (id) on delete set null;
    end if;
end $$;

create unique index if not exists departamentos_nombre_uq on public.departamentos (lower(nombre));

comment on table public.departamentos is
  'Departamentos de la empresa. tipo = el mismo criterio que centros_costo (produccion/servicio/administracion/ventas); responsable = el empleado que lo dirige.';

alter table public.departamentos enable row level security;
drop policy if exists admin_all on public.departamentos;
create policy admin_all on public.departamentos for all to authenticated using (true) with check (true);
grant all on public.departamentos to authenticated;
revoke all on public.departamentos from anon;

drop trigger if exists trg_bitacora_departamentos on public.departamentos;
create trigger trg_bitacora_departamentos
    after insert or update or delete on public.departamentos
    for each row execute function public.fn_bitacora_generica();

-- ---------------------------------------------------------------------
-- 2. empleados: departamento, gerente y foto
-- ---------------------------------------------------------------------
alter table public.empleados
    add column if not exists departamento_id bigint references public.departamentos (id) on delete set null,
    add column if not exists gerente_id      bigint references public.empleados (id) on delete set null,
    add column if not exists foto_path       text;

comment on column public.empleados.gerente_id is
  'Gerente (jefe directo) de este empleado, otro empleado. Vacío = cabeza de la organización.';
comment on column public.empleados.foto_path is
  'Ruta de la foto en el bucket privado fotos-personal (se muestra con URL firmada).';

create index if not exists empleados_gerente_idx on public.empleados (gerente_id);
create index if not exists empleados_departamento_idx on public.empleados (departamento_id);

-- ---------------------------------------------------------------------
-- 3. Cadena de gerentes sin círculos
-- ---------------------------------------------------------------------
create or replace function public._empleado_gerente_sin_ciclo()
returns trigger
language plpgsql
as $$
declare
    v_actual bigint := new.gerente_id;
    v_pasos  integer := 0;
begin
    if new.gerente_id is null then
        return new;
    end if;
    if new.gerente_id = new.id then
        raise exception 'Un empleado no puede ser su propio gerente.';
    end if;
    while v_actual is not null loop
        if v_actual = new.id then
            raise exception 'Ese gerente depende de este empleado: la cadena de mando quedaría en círculo.';
        end if;
        select e.gerente_id into v_actual from public.empleados e where e.id = v_actual;
        v_pasos := v_pasos + 1;
        if v_pasos > 50 then
            raise exception 'La cadena de gerentes es demasiado larga o ya estaba en círculo.';
        end if;
    end loop;
    return new;
end $$;

drop trigger if exists trg_empleado_gerente_sin_ciclo on public.empleados;
create trigger trg_empleado_gerente_sin_ciclo
    before insert or update of gerente_id on public.empleados
    for each row execute function public._empleado_gerente_sin_ciclo();

-- ---------------------------------------------------------------------
-- 4. Los departamentos que ya estaban escritos en Empleados pasan a la tabla
--    (el tipo solo se llena donde no hay duda; Almacén se decide aparte)
-- ---------------------------------------------------------------------
insert into public.departamentos (nombre, tipo)
select x.d,
       case lower(x.d)
            when 'producción'     then 'produccion'
            when 'administración' then 'administracion'
            when 'ventas'         then 'ventas'
            else null
       end
  from (select distinct on (lower(trim(e.departamento))) trim(e.departamento) as d
          from public.empleados e
         where e.departamento is not null and trim(e.departamento) <> ''
         order by lower(trim(e.departamento)), trim(e.departamento)) x
 where not exists (select 1 from public.departamentos d where lower(d.nombre) = lower(x.d));

update public.empleados e
   set departamento_id = d.id
  from public.departamentos d
 where e.departamento_id is null
   and e.departamento is not null
   and lower(d.nombre) = lower(trim(e.departamento));

-- ---------------------------------------------------------------------
-- 5. Bucket privado para las fotos del personal
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('fotos-personal', 'fotos-personal', false)
on conflict (id) do nothing;

drop policy if exists fotos_personal_admin on storage.objects;
create policy fotos_personal_admin on storage.objects
    for all to authenticated
    using (bucket_id = 'fotos-personal')
    with check (bucket_id = 'fotos-personal');

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select d.nombre, d.tipo, count(e.id) as empleados from public.departamentos d left join public.empleados e on e.departamento_id = d.id group by 1, 2 order by 1;
-- select id, nombre, departamento, departamento_id, gerente_id from public.empleados order by id;
