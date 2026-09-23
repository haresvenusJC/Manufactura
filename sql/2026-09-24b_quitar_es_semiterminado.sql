-- =====================================================================
--  Paso 2 de 2: borrar la bandera productos.es_semiterminado
--  Fecha: 2026-09-24  ·  Proyecto: Hares de México (Supabase)
--
--  Correr SOLO después de:
--   1) sql/2026-09-24_tipo_semiterminado.sql, y
--   2) publicar el código que ya usa tipo = 'semiterminado' (ninguna
--      pantalla vuelve a leer ni a mandar es_semiterminado).
--  Si alguna función viva de la base todavía usa la columna, se detiene y
--  dice cuál (no borra nada). Idempotente.
-- =====================================================================
begin;

do $$
declare
    v_quien text;
begin
    select string_agg(p.proname, ', ') into v_quien
      from pg_proc p
     where p.pronamespace = 'public'::regnamespace
       and p.proname <> '_puente_tipo_semiterminado'
       and p.prosrc ilike '%es_semiterminado%';
    if v_quien is not null then
        raise exception 'Todavía usan es_semiterminado: %. Corrígelas antes de borrar la columna.', v_quien;
    end if;
    if exists (select 1 from public.productos where es_semiterminado and tipo is distinct from 'semiterminado') then
        raise exception 'Hay productos con es_semiterminado = true que no son tipo semiterminado; corre primero sql/2026-09-24_tipo_semiterminado.sql.';
    end if;
end $$;

drop trigger  if exists _a_puente_tipo_semiterminado on public.productos;
drop function if exists public._puente_tipo_semiterminado();

alter table public.productos drop column if exists es_semiterminado;

commit;

select tipo, count(*) from public.productos group by tipo order by tipo;
