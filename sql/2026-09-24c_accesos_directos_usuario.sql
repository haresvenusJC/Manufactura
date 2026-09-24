-- Accesos rápidos de Inicio, por usuario (js/bienvenida.js).
-- Una fila por usuario con su lista de tarjetas en jsonb: [{v, t, s, i}]
--   v = vista (window.loadView), t = título, s = subtítulo, i = ícono de la galería.
-- Sin fila = el usuario ve los accesos por defecto de la app. Idempotente.
begin;

create table if not exists public.accesos_directos_usuario (
    user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
    accesos    jsonb not null default '[]'::jsonb,
    updated_at timestamptz not null default now()
);

alter table public.accesos_directos_usuario enable row level security;

-- Cada quien ve y edita solo lo suyo.
drop policy if exists accesos_propios_select on public.accesos_directos_usuario;
create policy accesos_propios_select on public.accesos_directos_usuario
    for select to authenticated using (user_id = auth.uid());

drop policy if exists accesos_propios_insert on public.accesos_directos_usuario;
create policy accesos_propios_insert on public.accesos_directos_usuario
    for insert to authenticated with check (user_id = auth.uid());

drop policy if exists accesos_propios_update on public.accesos_directos_usuario;
create policy accesos_propios_update on public.accesos_directos_usuario
    for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists accesos_propios_delete on public.accesos_directos_usuario;
create policy accesos_propios_delete on public.accesos_directos_usuario
    for delete to authenticated using (user_id = auth.uid());

revoke all on public.accesos_directos_usuario from anon;
grant select, insert, update, delete on public.accesos_directos_usuario to authenticated;

commit;
