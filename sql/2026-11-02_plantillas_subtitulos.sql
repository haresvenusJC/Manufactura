-- =====================================================================
--  Plantillas de impresión: subtítulo propio para CADA tipo de documento
--  Fecha: 2026-11-02  ·  Proyecto: Hares de México (Supabase)
--
--  Hasta hoy casi todos los documentos imprimían bajo el subtítulo de la plantilla
--  genérica ("Comprobante de Movimiento de Almacén"), incluso una póliza, una
--  nómina o un reporte. Este archivo:
--   1. Crea la plantilla de CADA tipo que aún no la tenga (21 tipos + la genérica de respaldo), copiando logo, título,
--      color, pie y opciones de la plantilla 'generico' (si no existe, usa valores
--      por omisión) y poniéndole su subtítulo correcto.
--   2. En las plantillas que YA existen, solo corrige el subtítulo si está vacío o
--      si dice "Comprobante de Movimiento de Almacén" en un documento que no es de
--      almacén (requisición, orden de compra, nómina, póliza...). Lo que hayas
--      escrito a mano NO se toca.
--  Todo se edita después en Configuración → Plantillas. Idempotente.
-- =====================================================================
begin;

with subs (tipo_documento, nombre_plantilla, subtitulo) as (values
    ('requisicion_compra', 'Plantilla Requisición de compra', 'Requisición de compra'),
    ('orden_compra', 'Plantilla Orden de compra', 'Orden de compra'),
    ('entrada_compra', 'Plantilla Entrada por Compra', 'Entrada de almacén por compra'),
    ('entrada', 'Plantilla Entrada Directa', 'Entrada directa de almacén'),
    ('entrada_produccion', 'Plantilla Entrada por Producción', 'Entrada de almacén por producción'),
    ('salida_venta', 'Plantilla Salida por Venta', 'Salida de almacén por venta'),
    ('salida', 'Plantilla Salida General', 'Salida de almacén'),
    ('merma', 'Plantilla Salida por Merma', 'Salida de almacén por merma'),
    ('ajuste', 'Plantilla Ajuste de Inventario', 'Ajuste de inventario'),
    ('nomina', 'Plantilla Nómina', 'Recibo de nómina'),
    ('orden_produccion', 'Plantilla Estado de la orden de producción', 'Estado de la orden de producción'),
    ('poliza', 'Plantilla Póliza contable', 'Póliza contable'),
    ('pedido_venta', 'Plantilla Pedido de venta', 'Pedido de venta'),
    ('pago_proveedor', 'Plantilla Pago a proveedor', 'Comprobante de pago a proveedor'),
    ('cobro_cliente', 'Plantilla Cobro de cliente', 'Recibo de cobro de cliente'),
    ('conteo_auditoria', 'Plantilla Auditoría de inventario', 'Auditoría de inventario'),
    ('salida_produccion', 'Plantilla Salida por Producción', 'Salida de almacén por producción (consumo de materia prima)'),
    ('devolucion_cliente', 'Plantilla Devolución de cliente', 'Devolución de cliente'),
    ('devolucion_proveedor', 'Plantilla Devolución a proveedor', 'Devolución a proveedor'),
    ('cancelacion_recibo', 'Plantilla Cancelación de recibo', 'Cancelación de recibo de compra'),
    ('generico', 'Plantilla General (respaldo para todos)', 'Documento'),
    ('reporte', 'Plantilla Reportes', 'Reporte')
),
base as (
    select * from public.plantillas_documentos where tipo_documento = 'generico' limit 1
)
insert into public.plantillas_documentos
    (tipo_documento, nombre_plantilla, logo_url, titulo_encabezado, subtitulo_encabezado,
     color_acento, mostrar_costos, mostrar_lote, notas_legales, texto_pie, updated_at)
select s.tipo_documento, s.nombre_plantilla,
       b.logo_url,
       coalesce(b.titulo_encabezado, 'Hares de México'),
       s.subtitulo,
       coalesce(b.color_acento, '#4f46e5'),
       coalesce(b.mostrar_costos, true),
       coalesce(b.mostrar_lote, true),
       b.notas_legales,
       b.texto_pie,
       now()
  from subs s
  left join base b on true
on conflict (tipo_documento) do nothing;

-- Plantillas existentes: corregir solo subtítulos vacíos o el de almacén en documentos que no son de almacén.
update public.plantillas_documentos p
   set subtitulo_encabezado = s.subtitulo, updated_at = now()
  from (values
    ('requisicion_compra', 'Requisición de compra', 'Requisición de compra'),
    ('orden_compra', 'Orden de compra', 'Orden de compra'),
    ('entrada_compra', 'Entrada por Compra', 'Entrada de almacén por compra'),
    ('entrada', 'Entrada Directa', 'Entrada directa de almacén'),
    ('entrada_produccion', 'Entrada por Producción', 'Entrada de almacén por producción'),
    ('salida_venta', 'Salida por Venta', 'Salida de almacén por venta'),
    ('salida', 'Salida General', 'Salida de almacén'),
    ('merma', 'Salida por Merma', 'Salida de almacén por merma'),
    ('ajuste', 'Ajuste de Inventario', 'Ajuste de inventario'),
    ('nomina', 'Nómina', 'Recibo de nómina'),
    ('orden_produccion', 'Estado de la orden de producción', 'Estado de la orden de producción'),
    ('poliza', 'Póliza contable', 'Póliza contable'),
    ('pedido_venta', 'Pedido de venta', 'Pedido de venta'),
    ('pago_proveedor', 'Pago a proveedor', 'Comprobante de pago a proveedor'),
    ('cobro_cliente', 'Cobro de cliente', 'Recibo de cobro de cliente'),
    ('conteo_auditoria', 'Auditoría de inventario', 'Auditoría de inventario'),
    ('salida_produccion', 'Salida por Producción', 'Salida de almacén por producción (consumo de materia prima)'),
    ('devolucion_cliente', 'Devolución de cliente', 'Devolución de cliente'),
    ('devolucion_proveedor', 'Devolución a proveedor', 'Devolución a proveedor'),
    ('cancelacion_recibo', 'Cancelación de recibo', 'Cancelación de recibo de compra'),
    ('generico', 'General (respaldo para todos)', 'Documento'),
    ('reporte', 'Reportes', 'Reporte')
  ) as s (tipo_documento, nombre_plantilla, subtitulo)
 where p.tipo_documento = s.tipo_documento
   and p.tipo_documento <> 'generico'      -- la genérica (respaldo de todo) la editas tú; aquí solo se crea si no existe
   and (coalesce(trim(p.subtitulo_encabezado), '') = ''
        or (p.subtitulo_encabezado = 'Comprobante de Movimiento de Almacén'
            and s.tipo_documento not in ('entrada_compra','entrada','entrada_produccion','salida_venta','salida','merma','ajuste')));

commit;

-- Revisión:
--   select tipo_documento, nombre_plantilla, subtitulo_encabezado from public.plantillas_documentos order by tipo_documento;
