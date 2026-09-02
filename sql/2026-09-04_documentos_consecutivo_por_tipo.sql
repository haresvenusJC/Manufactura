-- =====================================================================
--  Documentos: consecutivo automático por tipo de movimiento
--  Fecha: 2026-09-04  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  documentos.id ya es un consecutivo global autoincremental (y el
--  módulo Documentos siempre lo muestra), pero es UN solo contador
--  mezclando todos los tipos de movimiento. Este archivo agrega un
--  consecutivo propio por tipo_movimiento (entrada_compra #1, #2... /
--  salida_produccion #1, #2... etc.), asignado solo con un trigger al
--  insertar - ningún módulo de la app (compras, entradas, salidas,
--  producción, órdenes de compra) tiene que tocarse para esto.
--
--  Idempotente: columnas/tabla con IF NOT EXISTS, función con
--  CREATE OR REPLACE, trigger recreado, backfill solo de lo que falte.
-- =====================================================================

begin;

-- 1. Contador vivo por tipo de movimiento.
create table if not exists public.contadores_documentos (
    tipo_movimiento text primary key,
    ultimo          integer not null default 0
);

alter table public.contadores_documentos enable row level security;
drop policy if exists admin_all on public.contadores_documentos;
create policy admin_all on public.contadores_documentos for all to authenticated using (true) with check (true);
grant select on public.contadores_documentos to authenticated;

-- 2. Columna donde queda el consecutivo asignado a cada documento.
alter table public.documentos add column if not exists consecutivo integer;

-- 3. Trigger: al insertar, si no trae consecutivo, toma el siguiente
--    número para su tipo_movimiento (upsert atómico, sin choques entre
--    inserciones simultáneas del mismo tipo).
create or replace function public.fn_documentos_asignar_consecutivo()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if new.consecutivo is null and new.tipo_movimiento is not null then
        insert into public.contadores_documentos (tipo_movimiento, ultimo)
        values (new.tipo_movimiento, 1)
        on conflict (tipo_movimiento) do update set ultimo = contadores_documentos.ultimo + 1
        returning ultimo into new.consecutivo;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_documentos_consecutivo on public.documentos;
create trigger trg_documentos_consecutivo
    before insert on public.documentos
    for each row execute function public.fn_documentos_asignar_consecutivo();

-- 4. Backfill de documentos ya existentes: se numeran por tipo en el
--    orden en que se crearon (por id), y el contador de cada tipo
--    queda sembrado en el último número ya usado.
with numerados as (
    select id, row_number() over (partition by tipo_movimiento order by id) as rn
    from public.documentos
    where tipo_movimiento is not null and consecutivo is null
)
update public.documentos d
set consecutivo = n.rn
from numerados n
where d.id = n.id;

insert into public.contadores_documentos (tipo_movimiento, ultimo)
select tipo_movimiento, max(consecutivo)
from public.documentos
where tipo_movimiento is not null and consecutivo is not null
group by tipo_movimiento
on conflict (tipo_movimiento) do update
    set ultimo = greatest(contadores_documentos.ultimo, excluded.ultimo);

commit;
