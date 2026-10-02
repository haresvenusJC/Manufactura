-- =====================================================================
--  Plantillas de impresión: opción "Vista compacta al imprimir"
--  Fecha: 2026-11-01  ·  Proyecto: Hares de México (Supabase)
--
--  Todas las impresiones de la app comparten un mismo estilo (carta, margen de
--  10 mm, encabezado de una franja, tablas compactas). Esta columna permite
--  apagar la compactación por tipo de documento (Configuración → Plantillas).
--  Por defecto ENCENDIDA. No toca datos. Idempotente.
-- =====================================================================
begin;
alter table public.plantillas_documentos add column if not exists compacto boolean not null default true;
commit;
