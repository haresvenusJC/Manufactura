-- =====================================================================
--  Régimen fiscal: llave foránea a c_regimen_fiscal
--  Fecha: 2026-10-30  ·  Proyecto: Hares de México (Supabase)
--
--  PASO 2 de 2. Corre DESPUÉS de sql/2026-10-30_c_regimen_fiscal.sql y de
--  confirmar en la app que Proveedores / Clientes ya leen el catálogo.
--  Hace que proveedores.regimen_fiscal y clientes.regimen_fiscal solo
--  acepten claves que existan en el catálogo (o vacío). Una clave se puede
--  retirar con "activo = false" sin romper nada; no se puede BORRAR una
--  clave que alguien use (on delete restrict). Renombrar la clave se
--  propaga sola (on update cascade).
--
--  Si hay claves huérfanas NO se crea nada: la migración se detiene y
--  lista cuáles son. Corrígelas (o agrégalas al catálogo desde
--  Configuración → Tablas → SAT · Regímenes fiscales) y vuelve a correrla.
--  Idempotente.
-- =====================================================================
begin;

do $$
declare v_huerfanas text;
begin
    select string_agg(t || ' #' || id || ' "' || coalesce(nombre, '') || '" → ' || regimen_fiscal, E'\n')
      into v_huerfanas
      from (
        select 'proveedores' as t, id, nombre, regimen_fiscal from public.proveedores
         where regimen_fiscal is not null and regimen_fiscal <> ''
           and regimen_fiscal not in (select clave from public.c_regimen_fiscal)
        union all
        select 'clientes', id, nombre, regimen_fiscal from public.clientes
         where regimen_fiscal is not null and regimen_fiscal <> ''
           and regimen_fiscal not in (select clave from public.c_regimen_fiscal)
      ) x;
    if v_huerfanas is not null then
        raise exception E'Hay regímenes en uso que no están en c_regimen_fiscal. Agrégalos al catálogo o corrígelos y vuelve a correr:\n%', v_huerfanas;
    end if;

    -- Cadena vacía → null (la FK no la aceptaría y en la app "sin régimen" es null).
    update public.proveedores set regimen_fiscal = null where regimen_fiscal = '';
    update public.clientes    set regimen_fiscal = null where regimen_fiscal = '';

    if not exists (select 1 from pg_constraint where conname = 'proveedores_regimen_fiscal_fk') then
        alter table public.proveedores add constraint proveedores_regimen_fiscal_fk
            foreign key (regimen_fiscal) references public.c_regimen_fiscal (clave)
            on update cascade on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'clientes_regimen_fiscal_fk') then
        alter table public.clientes add constraint clientes_regimen_fiscal_fk
            foreign key (regimen_fiscal) references public.c_regimen_fiscal (clave)
            on update cascade on delete restrict;
    end if;
end $$;

commit;
