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

// =====================================================================
//  Última compra YA RECIBIDA Y PAGADA de un producto (para "Resurtir" en la requisición): recepción de compra no cancelada
//  cuyo documento está liquidado (total_pagado >= total). Trae lo que ese proveedor facturó, en SU unidad: proveedor, Clave UM,
//  Clave SAT, número, descripción, factor y precio. Primero se toma de la ODC de esa recepción (la cotización exacta);
//  si no hay, de "Claves de proveedor" y del costo de la recepción. Devuelve null si el producto nunca se ha comprado y pagado.
// =====================================================================
export async function obtenerUltimaCompraPagada(productoId) {
    if (!productoId) return null;
    const q = await supabaseClient.from('documento_detalles')
        .select('costo_unitario, documentos!inner( id, folio, fecha_emision, proveedor_id, total, total_pagado, orden_compra_id, estado, tipo_movimiento )')
        .eq('producto_id', productoId)
        .eq('documentos.tipo_movimiento', 'entrada_compra')
        .neq('documentos.estado', 'cancelado')
        .order('id', { ascending: false })
        .limit(30);
    if (q.error || !q.data) return null;
    const pagadas = q.data
        .filter((r) => { const d = r.documentos; const t = Number(d?.total || 0); return t > 0 && Number(d.total_pagado || 0) >= t - 0.01 && d.proveedor_id; })
        .sort((a, b) => (b.documentos.fecha_emision || '').localeCompare(a.documentos.fecha_emision || ''));
    if (!pagadas.length) return null;
    const r = pagadas[0], d = r.documentos;

    const [prov, info, od] = await Promise.all([
        supabaseClient.from('proveedores').select('nombre').eq('id', d.proveedor_id).maybeSingle(),
        obtenerInfoProveedorProducto(productoId, d.proveedor_id).catch(() => null),
        (async () => {
            if (!d.orden_compra_id) return null;
            for (const cols of [
                'precio_proveedor, clave_unidad_sat, clave_prod_serv_sat, factor_conversion_proveedor, sku_proveedor, descripcion_proveedor',
                'sku_proveedor, descripcion_proveedor, factor_conversion_proveedor',
            ]) {
                const x = await supabaseClient.from('ordenes_compra_detalle').select(cols)
                    .eq('orden_compra_id', d.orden_compra_id).eq('producto_id', productoId).limit(1);
                if (!x.error) return x.data?.[0] || null;
                if (!/does not exist|schema cache|could not find/i.test(x.error.message || '')) return null;
            }
            return null;
        })().catch(() => null),
    ]);

    const claveUm = od?.clave_unidad_sat || info?.claveUnidadSat || '';
    const factor = Number(od?.factor_conversion_proveedor) > 0 ? Number(od.factor_conversion_proveedor)
        : (Number(info?.factorConversion) > 0 ? Number(info.factorConversion) : null);
    const costoInterno = Number(r.costo_unitario || 0);
    // Precio en la unidad del proveedor: el cotizado en la ODC; si no, el costo de la recepción × factor (a 4 decimales).
    const precioProveedor = od?.precio_proveedor != null ? Number(od.precio_proveedor)
        : (claveUm && factor ? Math.round(costoInterno * factor * 1e4) / 1e4 : Math.round(costoInterno * 1e4) / 1e4);
    return {
        proveedorId: d.proveedor_id,
        proveedorNombre: prov?.data?.nombre || '',
        folio: d.folio || ('#' + d.id),
        fecha: d.fecha_emision || null,
        claveUm: claveUm || '',
        claveSat: od?.clave_prod_serv_sat || info?.claveProdServSat || '',
        numero: od?.sku_proveedor || info?.claveProveedor || '',
        descripcion: od?.descripcion_proveedor || info?.descripcionProveedor || '',
        factor: claveUm ? factor : null,
        precioProveedor,
        costoInterno,
    };
}

export async function obtenerInfoProveedorProducto(productoId, proveedorId) {
    if (!productoId || !proveedorId) return null;

    // Del más completo al más viejo: cada migración agregó columnas (factor, unidad SAT) y se degrada sin ellas.
    const COLS = [
        'clave, descripcion_factura, unidad_factura, factor_conversion, clave_unidad_sat, clave_sat',
        'clave, descripcion_factura, unidad_factura, factor_conversion',
        'clave, descripcion_factura, unidad_factura',
    ];
    let clave = { data: null };
    for (const cols of COLS) {
        clave = await supabaseClient.from('producto_claves_proveedor')
            .select(cols)
            .eq('producto_id', productoId)
            .eq('proveedor_id', proveedorId)
            .limit(1);
        if (!clave.error || !/does not exist|schema cache|could not find/i.test(clave.error.message || '')) break;
    }

    const docs = await supabaseClient.from('documento_detalles')
        .select('costo_unitario, documentos!inner( fecha_emision, proveedor_id, tipo_movimiento, estado )')
        .eq('producto_id', productoId)
        .eq('documentos.proveedor_id', proveedorId)
        .eq('documentos.tipo_movimiento', 'entrada_compra')
        .neq('documentos.estado', 'cancelado')
        .order('id', { ascending: false })
        .limit(20);

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
        factorConversion: claveRow?.factor_conversion ?? null,
        claveUnidadSat: claveRow?.clave_unidad_sat || null,
        claveProdServSat: claveRow?.clave_sat || null,
        ultimoPrecio,
        ultimaFecha,
    };
}
