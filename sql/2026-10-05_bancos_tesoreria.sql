-- =====================================================================
--  Bancos y Tesorería: catálogo de cuentas bancarias + conciliación
--  Fecha: 2026-10-05  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Hoy "cuenta de banco" es directo una fila de cuentas_contables
--  (código 101.xx/102.xx) elegida por prefijo en 3 pantallas distintas
--  (Gastos, Cuentas por pagar, Cuentas por cobrar) — no hay dónde
--  capturar el banco/número de cuenta/CLABE reales, ni forma de marcar
--  qué movimientos ya salieron en el estado de cuenta del banco
--  (conciliación). Este archivo agrega ambas cosas SIN tocar el diseño
--  contable existente: cuentas_bancarias se liga 1:1 a una cuenta
--  contable ya existente (no la sustituye), y la conciliación son solo
--  3 columnas nuevas en poliza_movimientos (el libro mayor que ya existe
--  — no se duplica en una tabla aparte).
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.cuentas_bancarias (
    id                  bigint generated always as identity primary key,
    banco               text not null,
    alias               text not null,
    numero_cuenta       text,
    clabe               text,
    cuenta_contable_id  bigint not null references public.cuentas_contables (id),
    activa              boolean not null default true,
    notas               text,
    created_at          timestamptz not null default now()
);

create unique index if not exists cuentas_bancarias_cuenta_contable_uq on public.cuentas_bancarias (cuenta_contable_id);

alter table public.cuentas_bancarias enable row level security;
drop policy if exists admin_all on public.cuentas_bancarias;
create policy admin_all on public.cuentas_bancarias
    for all to authenticated using (true) with check (true);
grant all on public.cuentas_bancarias to authenticated;

drop trigger if exists trg_bitacora_cuentas_bancarias on public.cuentas_bancarias;
create trigger trg_bitacora_cuentas_bancarias
    after insert or update or delete on public.cuentas_bancarias
    for each row execute function public.fn_bitacora_generica();

-- Conciliación bancaria: 3 columnas sobre el libro mayor que ya existe.
alter table public.poliza_movimientos
    add column if not exists conciliado         boolean not null default false,
    add column if not exists fecha_conciliacion date,
    add column if not exists referencia_banco   text;

commit;

-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select * from public.cuentas_bancarias order by created_at desc;
