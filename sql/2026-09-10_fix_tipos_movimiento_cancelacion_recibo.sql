-- =====================================================================
--  Fix: falta 'cancelacion_recibo' en el catálogo tipos_movimiento
--  Fecha: 2026-09-10  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  sql/2026-09-21_reversa_inventario_recibo.sql agregó
--  cancelar_recibo_inventario(), que inserta movimientos_inventario con
--  tipo_movimiento = 'cancelacion_recibo'. Esa columna tiene una llave
--  foránea a public.tipos_movimiento(codigo), y ese código nunca se dio
--  de alta ahí — la función fallaba con:
--    "insert or update on table movimientos_inventario violates foreign
--     key constraint movimientos_inventario_tipo_movimiento_fkey"
--
--  Idempotente (on conflict do nothing).
-- =====================================================================

begin;

insert into public.tipos_movimiento (codigo, nombre, naturaleza)
values ('cancelacion_recibo', 'Cancelación de Recibo de Compra', 'salida')
on conflict (codigo) do nothing;

commit;
