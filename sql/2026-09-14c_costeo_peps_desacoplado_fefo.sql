-- =====================================================================
--  Desacopla el costeo PEPS del criterio FEFO de salida física — NIF C-4
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--  (Reducida el 2026-09-25: ahora SOLO crea la columna; SEGURA de correr
--   en cualquier momento, cuantas veces sea.)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Idea original: registrar_salida_fifo y registrar_movimiento_inventario_fifo
--  elegían con el MISMO orden (FIFO/FEFO por caducidad) tanto QUÉ LOTE sale
--  físicamente como QUÉ COSTO se aplica. NIF C-4 solo permite PEPS o costo
--  promedio, así que se separan:
--    · Salida FÍSICA — equilibrio FIFO/FEFO por caducidad (menos merma).
--    · Costeo — cola PEPS ESTRICTA por fecha_ingreso, sobre la columna nueva
--      lotes_inventario.stock_costeo.
--
--  Cada lote lleva DOS contadores:
--    · stock_actual = cantidad física restante.
--    · stock_costeo = cantidad aún no "cobrada" por la cola PEPS.
--  Coinciden en el TOTAL por producto; pueden diferir lote por lote.
--
--  QUÉ HACE ESTE ARCHIVO: agrega la columna stock_costeo (idempotente).
--
--  QUÉ YA NO HACE (se quitó a propósito): redefinir las funciones
--    registrar_salida_fifo, registrar_movimiento_inventario_fifo,
--    recibo_reversible y cancelar_recibo_inventario. Sus versiones vigentes
--    viven en:
--      · sql/2026-09-22_fix_salida_fifo_costo_ambiguo.sql  (registrar_salida_fifo)
--      · sql/2026-09-26_fix_unificado_costeo_recepcion.sql (las otras tres)
--    Volver a crearlas aquí las regresaría a una versión con errores
--    (p. ej. "column reference costo_unitario is ambiguous" al cerrar órdenes).
--
--  Requiere: sql/2026-09-13_salidas_fefo.sql (tabla lotes_inventario)
-- =====================================================================

begin;

alter table public.lotes_inventario
    add column if not exists stock_costeo numeric(14,4);

-- Lotes existentes: no hay forma de reconstruir su historial de costeo,
-- arrancan con stock_costeo = stock_actual. Solo toca filas aún sin valor,
-- así que en una base que ya la tiene no cambia nada.
update public.lotes_inventario set stock_costeo = stock_actual where stock_costeo is null;

alter table public.lotes_inventario alter column stock_costeo set default 0;
alter table public.lotes_inventario alter column stock_costeo set not null;

comment on column public.lotes_inventario.stock_costeo is
  'Cantidad de este lote AÚN no consumida por la cola de costeo PEPS estricta (por fecha_ingreso) — independiente de stock_actual (cantidad física restante, que se descuenta en orden FEFO). Ambas coinciden en total por producto; pueden diferir lote por lote.';

commit;


-- =====================================================================
-- Verificación (opcional) — el total de stock_actual y stock_costeo por
-- producto debe coincidir siempre (si devuelve filas, hay descuadre):
-- select producto_id, sum(stock_actual) fisico, sum(stock_costeo) costeo
--   from public.lotes_inventario group by producto_id
--  having sum(stock_actual) <> sum(stock_costeo);
-- =====================================================================
