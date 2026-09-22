-- =====================================================================
--  Unidades de medida: editable desde la app (Catálogo → "📏 Unidades")
--  Fecha: 2026-10-25  ·  Proyecto: Hares de México (Supabase)
--
--  public.unidades_medida ya existía (no la crea ningún archivo de este
--  repo) y hasta hoy solo se leía desde la app — para agregar o corregir
--  una unidad había que entrar a Supabase → Table Editor a mano. Este
--  archivo:
--   1. Se asegura de que 'authenticated' pueda insertar/editar (mismo
--      patrón admin_all que el resto de los catálogos de la app).
--   2. Agrega un índice único por nombre (sin importar mayúsculas/acentos
--      simples de más/menos espacios) para que la pantalla nueva no deje
--      crear "Litros" dos veces — solo si hoy no hay ya nombres
--      duplicados; si los hay, no falla, simplemente no se crea el índice
--      (corrígelos a mano y vuelve a correr este archivo).
--
--  No inventa ni borra ninguna unidad existente.
--  Idempotente. Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

alter table public.unidades_medida enable row level security;

drop policy if exists admin_all on public.unidades_medida;
create policy admin_all on public.unidades_medida
    for all to authenticated using (true) with check (true);

grant select, insert, update on public.unidades_medida to authenticated;
grant usage on all sequences in schema public to authenticated;

do $$
begin
    if not exists (select 1 from pg_indexes where indexname = 'unidades_medida_nombre_uidx') then
        if not exists (
            select 1 from public.unidades_medida
            group by lower(trim(nombre))
            having count(*) > 1
        ) then
            create unique index unidades_medida_nombre_uidx on public.unidades_medida (lower(trim(nombre)));
        else
            raise notice 'Hay nombres de unidad duplicados (sin distinguir mayúsculas); corrígelos y vuelve a correr este archivo para crear el índice único.';
        end if;
    end if;
end $$;

commit;

-- Revisión:
--   select id, nombre, es_fraccionable from public.unidades_medida order by nombre;
