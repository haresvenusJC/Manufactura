-- =====================================================================
--  PREPARACIÓN (no se usa todavía): "quién creó" cada registro, para cuando
--  se implementen los accesos por usuario.
--  Fecha: 2026-10-13  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor
--  cuando se vaya a activar (no tiene prisa; nada de la pantalla lo requiere aún).
--
--  Hoy: `polizas.creado_por` (uuid del usuario de acceso) ya se guarda, y la
--  bitácora (`bitacora_cambios.usuario_email`) registra el correo. Falta
--  poder mostrar UN nombre legible. Esta preparación deja:
--   1. empleados.usuario_id (uuid, único, opcional): liga a cada empleado con su
--      usuario de acceso. Se llena a mano o desde la pantalla de usuarios.
--   2. autor_de(uuid): devuelve el NOMBRE del empleado ligado a ese usuario; si no
--      está ligado, el correo del usuario; si no existe, null. La pantalla solo
--      tendrá que llamarla (o hacer join) para pintar la columna "Creó".
--
--  Idempotente. No cambia ningún dato ni comportamiento existente.
-- =====================================================================

begin;

alter table public.empleados add column if not exists usuario_id uuid;
create unique index if not exists empleados_usuario_id_uq on public.empleados (usuario_id) where usuario_id is not null;
comment on column public.empleados.usuario_id is
  'Usuario de acceso (auth.users.id) de este empleado. Opcional; sirve para mostrar el nombre en "Creó" de pólizas y documentos.';

create or replace function public.autor_de(p_usuario uuid)
returns text
language sql
stable
security definer
set search_path = public, auth
as $$
    select coalesce(
        (select e.nombre from public.empleados e where e.usuario_id = p_usuario limit 1),
        (select u.email::text from auth.users u where u.id = p_usuario)
    );
$$;

revoke all     on function public.autor_de(uuid) from public, anon;
grant  execute on function public.autor_de(uuid) to authenticated;

commit;

-- Uso futuro:  select p.folio_poliza, p.tipo, p.numero, public.autor_de(p.creado_por) as creo from public.polizas p order by p.id desc limit 10;
