-- =====================================================================
--  Fix: política RLS faltante para escritura directa en registros_tiempo
--  Fecha: 2026-08-28
--  Proyecto: Hares de México (Supabase)
--
--  Este archivo NO lo ejecuta la aplicación. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--
--  Motivo: el botón "✎ Ajustar tiempo manualmente" del panel admin
--  (js/produccion.js) inserta directo en registros_tiempo con la sesión
--  autenticada del admin. Falla con:
--    "new row violates row-level security policy for table registros_tiempo"
--  Las RPC ot_marcar / ot_finalizar sí funcionan porque son
--  "security definer" (se ejecutan con permisos del dueño y se saltan RLS),
--  pero un insert/update directo desde el cliente pasa por PostgREST con el
--  JWT del admin y sí queda sujeto a RLS. Esta tabla tiene RLS activo (por
--  eso el error) pero le falta una política que permita al rol
--  'authenticated' leer/escribir, igual que las demás tablas de la app
--  (mismo patrón "admin_all" de la PARTE 2 de 2026-08-27_flujo_ot.sql).
--
--  Idempotente: se puede correr varias veces sin romper nada.
-- =====================================================================

begin;

drop policy if exists admin_all on public.registros_tiempo;
create policy admin_all on public.registros_tiempo
    for all
    to authenticated
    using (true)
    with check (true);

commit;
