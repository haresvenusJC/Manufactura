-- =====================================================================
--  Tipo SAT (Ingreso / Egreso / Diario) de cada serie de póliza
--  Fecha: 2026-10-13  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere (ya corrida): 2026-10-13_series_polizas.sql
--
--  Agrega la columna `tipo` a polizas_series_origen para que la pantalla
--  Configuración -> Tablas -> Series de pólizas muestre qué tipo SAT genera
--  cada origen. Es informativa: el tipo real de cada póliza lo sigue
--  decidiendo la función que la crea. Idempotente.
-- =====================================================================
begin;

alter table public.polizas_series_origen add column if not exists tipo text;

update public.polizas_series_origen set tipo = v.tipo
  from (values
    ('pago',                 'Egreso'),
    ('cobro',                'Ingreso'),
    ('produccion',           'Diario'),
    ('compra',               'Diario'),
    ('gasto',                'Egreso / Diario'),
    ('nomina',               'Egreso'),
    ('depreciacion',         'Diario'),
    ('venta',                'Ingreso / Diario'),
    ('salida',               'Diario'),
    ('entrada',              'Diario'),
    ('devolucion_cliente',   'Diario'),
    ('devolucion_proveedor', 'Diario'),
    ('prorrateo',            'Diario'),
    ('anticipo_reembolso',   'Ingreso'),
    ('anticipo_baja',        'Diario'),
    ('manual',               'A elección')
  ) as v(origen, tipo)
 where polizas_series_origen.origen = v.origen;

commit;

-- Para revisar:  select origen, serie, tipo, que_es from public.polizas_series_origen order by serie, origen;
