import { supabaseClient } from './supabase.js';

// =====================================================================
//  Cómo IDENTIFICA Y VENDE un proveedor específico un producto del
//  catálogo: su propia clave/SKU, su descripción de factura y su unidad
//  de venta (tabla producto_claves_proveedor — ver "Claves de proveedor"
//  en Productos), más el precio unitario de la última compra REAL que se
//  le hizo a ESE proveedor (documento_detalles de un recibo de compra no
//  cancelado). Es la forma de hablar con el proveedor en sus propios
//  términos al armar una requisición o una orden de compra — no aplica
//  en ningún otro módulo (al importar su XML, la factura ya trae sus
//  propios datos; aquí se da entrada tal cual se tiene en el ERP).
// =====================================================================

export async function obtenerInfoProveedorProducto(productoId, proveedorId) {
    if (!productoId || !proveedorId) return null;

    const [clave, docs] = await Promise.all([
        supabaseClient.from('producto_claves_proveedor')
            .select('clave, descripcion_factura, unidad_factura')
            .eq('producto_id', productoId)
            .eq('proveedor_id', proveedorId)
            .limit(1),
        supabaseClient.from('documento_detalles')
            .select('costo_unitario, documentos!inner( fecha_emision, proveedor_id, tipo_movimiento, estado )')
            .eq('producto_id', productoId)
            .eq('documentos.proveedor_id', proveedorId)
            .eq('documentos.tipo_movimiento', 'entrada_compra')
            .neq('documentos.estado', 'cancelado')
            .order('id', { ascending: false })
            .limit(20),
    ]);

    let ultimoPrecio = null;
    let ultimaFecha = null;
    if (docs.data && docs.data.length) {
        const ordenado = [...docs.data].sort((a, b) =>
            (b.documentos?.fecha_emision || '').localeCompare(a.documentos?.fecha_emision || ''));
        ultimoPrecio = ordenado[0].costo_unitario;
        ultimaFecha = ordenado[0].documentos?.fecha_emision || null;
    }

    const claveRow = clave.data?.[0] || null;
    return {
        claveProveedor: claveRow?.clave || null,
        descripcionProveedor: claveRow?.descripcion_factura || null,
        unidadProveedor: claveRow?.unidad_factura || null,
        ultimoPrecio,
        ultimaFecha,
    };
}
