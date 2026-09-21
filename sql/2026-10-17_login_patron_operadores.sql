-- =====================================================================
--  Login por patrón (como el desbloqueo del celular) en las apps móviles
--  de operador: Orden de Trabajo, Pre-recibo y Conteo de inventario.
--  Fecha: 2026-10-17  ·  Proyecto: Hares de México (Supabase)
--
--  El patrón es una segunda forma de entrar del MISMO empleado que ya tiene
--  PIN: una secuencia de puntos de la cuadrícula 3x3 ("1-2-5-8", mínimo 4,
--  sin repetir). Se guarda con hash bcrypt (igual que el PIN), se verifica
--  en el servidor y comparte el bloqueo de 5 intentos / 15 minutos.
--
--  - El operador crea su patrón solo, después de entrar con su PIN.
--  - Si el admin restablece el PIN (🔑 en Empleados), el patrón se borra.
--  - El PIN sigue funcionando siempre.
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

alter table public.empleados
    add column if not exists patron_hash text;

comment on column public.empleados.patron_hash is
    'Hash bcrypt del patrón de acceso móvil (secuencia 1-9 unida con guiones). Se borra al restablecer el PIN.';


-- ---------------------------------------------------------------------
-- Restablecer el PIN borra el patrón (credencial olvidada o comprometida)
-- ---------------------------------------------------------------------
create or replace function public.trg_empleados_pin_limpia_patron()
returns trigger
language plpgsql
as $$
begin
    if new.pin_hash is distinct from old.pin_hash then
        new.patron_hash := null;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_empleados_pin_limpia_patron on public.empleados;
create trigger trg_empleados_pin_limpia_patron
    before update of pin_hash on public.empleados
    for each row execute function public.trg_empleados_pin_limpia_patron();


-- ---------------------------------------------------------------------
-- Validación de formato (uso interno): 4 a 9 puntos del 1 al 9, sin repetir
-- ---------------------------------------------------------------------
create or replace function public._patron_valido(p_patron text)
returns boolean
language sql
immutable
as $$
    select coalesce(p_patron ~ '^[1-9](-[1-9]){3,8}$', false)
       and (select count(distinct x) = count(*) from unnest(string_to_array(p_patron, '-')) as x);
$$;


-- ---------------------------------------------------------------------
-- ¿Este empleado ya tiene patrón? (para elegir la pantalla de acceso)
-- ---------------------------------------------------------------------
create or replace function public.ot_tiene_patron(p_empleado_id bigint)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
    select coalesce(
        (select e.patron_hash is not null
           from public.empleados e
          where e.id = p_empleado_id
            and e.activo is true
            and e.pin_hash is not null),
        false);
$$;

revoke all     on function public.ot_tiene_patron(bigint) from public;
grant  execute on function public.ot_tiene_patron(bigint) to anon, authenticated;


-- ---------------------------------------------------------------------
-- ot_login_patron: igual que ot_login, pero con el patrón.
-- Comparte contador de intentos y bloqueo con el PIN.
-- ---------------------------------------------------------------------
create or replace function public.ot_login_patron(p_empleado_id bigint, p_patron text)
returns table (token uuid, empleado_id bigint, empleado_nombre text)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_emp          public.empleados%rowtype;
    v_max_intentos constant integer  := 5;
    v_bloqueo      constant interval := interval '15 minutes';
begin
    delete from public.sesiones_ot where expira_at < now();   -- limpieza oportunista

    select e.* into v_emp
      from public.empleados e
     where e.id = p_empleado_id
       and e.activo is true
       and e.pin_hash is not null;

    if not found then
        raise exception 'Nombre o patrón incorrecto.';
    end if;

    if v_emp.bloqueado_hasta is not null and v_emp.bloqueado_hasta > now() then
        raise exception 'Demasiados intentos fallidos. Vuelve a intentar después de las %.',
            to_char(v_emp.bloqueado_hasta, 'HH24:MI');
    end if;

    if v_emp.patron_hash is null then
        raise exception 'Todavía no tienes patrón. Entra con tu PIN y créalo.';
    end if;

    if not public._patron_valido(p_patron)
       or v_emp.patron_hash <> crypt(p_patron, v_emp.patron_hash) then
        update public.empleados
           set intentos_fallidos = coalesce(intentos_fallidos, 0) + 1,
               bloqueado_hasta   = case when coalesce(intentos_fallidos, 0) + 1 >= v_max_intentos
                                         then now() + v_bloqueo
                                         else bloqueado_hasta
                                    end
         where id = p_empleado_id;
        raise exception 'Nombre o patrón incorrecto.';
    end if;

    update public.empleados
       set intentos_fallidos = 0, bloqueado_hasta = null
     where id = p_empleado_id;

    return query
    insert into public.sesiones_ot (empleado_id)
    values (p_empleado_id)
    returning sesiones_ot.token, p_empleado_id, v_emp.nombre;
end;
$$;

revoke all     on function public.ot_login_patron(bigint, text) from public;
grant  execute on function public.ot_login_patron(bigint, text) to anon, authenticated;


-- ---------------------------------------------------------------------
-- ot_set_patron: el operador (con sesión de PIN ya abierta) crea o cambia
-- su patrón.
-- ---------------------------------------------------------------------
create or replace function public.ot_set_patron(p_token uuid, p_patron text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
begin
    select s.empleado_id
      into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token
       and s.expira_at > now();

    if v_empleado_id is null then
        raise exception 'SESION_EXPIRADA';
    end if;

    if not public._patron_valido(p_patron) then
        raise exception 'El patrón debe unir de 4 a 9 puntos sin repetir ninguno.';
    end if;

    update public.empleados
       set patron_hash = crypt(p_patron, gen_salt('bf'))
     where id = v_empleado_id;
end;
$$;

revoke all     on function public.ot_set_patron(uuid, text) from public;
grant  execute on function public.ot_set_patron(uuid, text) to anon, authenticated;

commit;
