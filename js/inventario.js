import { supabaseClient } from './supabase.js';

/**
 * Función auxiliar centralizada para registrar movimientos de almacén mediante FIFO (RPC de Supabase).
 * Soporta de manera inteligente entradas y salidas (como producción o ventas).
 */
export async function registrarMovimientoAlmacen({ productoId, cantidad, tipoMovimiento, documentoId, costoUnitario, numeroLote }) {
    let rpcNombre = 'registrar_movimiento_inventario_fifo';
    let parametros = {};

    if (Number(cantidad) < 0 || (tipoMovimiento && tipoMovimiento.startsWith('salida'))) {
        rpcNombre = 'registrar_salida_fifo';
        parametros = {
            p_producto_id: Number(productoId),
            p_cantidad_salida: Math.abs(Number(cantidad)),
            p_tipo_movimiento: tipoMovimiento,
            p_documento_id: documentoId ? Number(documentoId) : null,
            p_costo_unitario_fijo: costoUnitario ? Number(costoUnitario) : null
        };
    } else {
        parametros = {
            p_producto_id: Number(productoId),
            p_cantidad: Number(cantidad),
            p_tipo_movimiento: tipoMovimiento,
            p_documento_id: documentoId ? Number(documentoId) : null,
            p_costo_unitario: costoUnitario ? Number(costoUnitario) : null,
            p_numero_lote: numeroLote || null
        };
    }

    const { error } = await supabaseClient.rpc(rpcNombre, parametros);

    if (error) {
        throw new Error(`Error en inventario [${tipoMovimiento}] (RPC: ${rpcNombre}): ` + error.message);
    }
}

// Variables de estado para la paginación y filtros de lotes
let paginaActualLotes = 1;
const porPaginaLotes = 50;
let fechaInicioFiltro = '';
let fechaFinFiltro = '';

export async function cargarInventarioCompleto() {
    const contenedorInv = document.getElementById('contenedorInventario');
    const contenedorLotes = document.getElementById('contenedorExistenciasLote');
    
    try {
        if (!supabaseClient) return;
        
        if (contenedorInv) {
            const { data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select(`
                    id, nombre, sku, tipo, costo_unitario, stock_actual, unidad_medida_id, moneda_id,
                    unidades_medida ( nombre ),
                    monedas ( codigo )
                `)
                .order('id', { ascending: true });
            
            if (errProd) throw errProd;

            const productosTerminados = (productos || []).filter(p => p.tipo === 'producto');
            const materiasPrimas = (productos || []).filter(p => p.tipo === 'materia_prima' || !p.tipo);
            const componentes = (productos || []).filter(p => p.tipo === 'componente' || p.tipo === 'refaccion' || p.tipo === 'insumo');

            let html = ``;

            // Renderizado optimizado de secciones
            const renderSeccion = (titulo, colorClass, lista) => {
                if (lista.length === 0) return '';
                let sectionHtml = `
                    <div class="mb-6">
                        <h4 class="text-xs font-bold ${colorClass} uppercase tracking-wider mb-2">${titulo}</h4>
                        <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                            <table class="w-full text-left text-sm text-slate-300">
                                <thead class="bg-slate-900 ${colorClass} border-b border-slate-800 text-xs uppercase">
                                    <tr>
                                        <th class="p-3">Elemento / SKU</th>
                                        <th class="p-3">Unidad</th>
                                        <th class="p-3">Stock Disponible</th>
                                        <th class="p-3">Costo Unitario</th>
                                    </tr>
                                </thead>
                                <tbody>
                `;
                lista.forEach(item => {
                    const nombreUnidad = item.unidades_medida?.nombre || 'N/D';
                    const codigoMoneda = item.monedas?.codigo || 'MXN';
                    sectionHtml += `
                        <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                            <td class="p-3 font-medium text-slate-100">${item.nombre} <span class="text-xs text-slate-500 font-mono">(${item.sku || 'N/D'})</span></td>
                            <td class="p-3 text-slate-400 text-xs">${nombreUnidad}</td>
                            <td class="p-3 font-mono font-semibold">${item.stock_actual || 0}</td>
                            <td class="p-3 font-mono text-slate-300">$${Number(item.costo_unitario || 0).toFixed(2)} <span class="text-[10px] text-slate-500">${codigoMoneda}</span></td>
                        </tr>
                    `;
                });
                sectionHtml += `</tbody></table></div></div>`;
                return sectionHtml;
            };

            html += renderSeccion('📦 Productos Terminados', 'text-amber-400', productosTerminados);
            html += renderSeccion('🧪 Materias Primas e Insumos', 'text-sky-400', materiasPrimas);
            html += renderSeccion('⚙️ Componentes y Refacciones', 'text-emerald-400', componentes);

            contenedorInv.innerHTML = html;
        }

        if (contenedorLotes) {
            await renderizarTablaLotes(contenedorLotes);
        }

    } catch (err) {
        console.error("Error al cargar inventario o lotes:", err);
    }
}

async function renderizarTablaLotes(contenedorLotes) {
    let query = supabaseClient
        .from('lotes_inventario')
        .select(`
            id, numero_lote, stock_actual, costo_unitario, fecha_ingreso,
            productos ( nombre, tipo )
        `, { count: 'exact' })
        .order('fecha_ingreso', { ascending: false })
        .order('id', { ascending: false });

    if (fechaInicioFiltro) query = query.gte('fecha_ingreso', fechaInicioFiltro);
    if (fechaFinFiltro) query = query.lte('fecha_ingreso', fechaFinFiltro);

    const desde = (paginaActualLotes - 1) * porPaginaLotes;
    const hasta = desde + porPaginaLotes - 1;
    query = query.range(desde, hasta);

    const { data: lotes, count, error: errLotes } = await query;
    if (errLotes) throw errLotes;

    const totalRegistros = count || 0;
    const totalPaginas = Math.ceil(totalRegistros / porPaginaLotes) || 1;

    let htmlLotes = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl mb-4 flex flex-wrap gap-4 items-center justify-between">
            <div class="flex flex-wrap items-center gap-3">
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Desde:</label>
                    <input type="date" id="filtroFechaInicio" value="${fechaInicioFiltro}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-indigo-500">
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Hasta:</label>
                    <input type="date" id="filtroFechaFin" value="${fechaFinFiltro}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-indigo-500">
                </div>
                <div class="flex items-end h-full pt-5">
                    <button type="button" onclick="window.aplicarFiltroFechasLotes()" class="bg-indigo-600 hover:bg-indigo-500 text-white text-xs px-4 py-1.5 rounded-lg transition font-medium shadow-sm">Filtrar</button>
                    <button type="button" onclick="window.limpiarFiltroFechasLotes()" class="ml-2 bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs px-3 py-1.5 rounded-lg transition border border-slate-700">Limpiar</button>
                </div>
            </div>
            <div class="text-xs text-slate-400 font-mono">Total partidas: <span class="text-indigo-400 font-bold">${totalRegistros}</span></div>
        </div>
    `;

    if (!lotes || lotes.length === 0) {
        htmlLotes += `<div class="bg-slate-950 border border-slate-800 p-6 rounded-xl text-center text-slate-500 text-sm">No se encontraron lotes de inventario con los filtros seleccionados.</div>`;
    } else {
        htmlLotes += `
            <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900 text-indigo-400 border-b border-slate-800 text-xs uppercase">
                        <tr>
                            <th class="p-3">Lote / Ref</th>
                            <th class="p-3">Insumo / Producto</th>
                            <th class="p-3">Tipo</th>
                            <th class="p-3">Stock Lote</th>
                            <th class="p-3">Costo U.</th>
                            <th class="p-3">Ingreso</th>
                            <th class="p-3 text-center">Acción</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        lotes.forEach(l => {
            const nombreProd = l.productos?.nombre || 'Desconocido';
            const tipoProd = l.productos?.tipo || 'General';
            const fechaIng = l.fecha_ingreso ? new Date(l.fecha_ingreso).toLocaleDateString() : 'N/D';

            htmlLotes += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                    <td class="p-3 font-mono text-xs text-indigo-300">#${l.id} - ${l.numero_lote || 'S/N'}</td>
                    <td class="p-3 font-medium text-slate-100">${nombreProd}</td>
                    <td class="p-3 text-xs uppercase text-slate-400">${tipoProd}</td>
                    <td class="p-3 font-mono text-amber-300 font-semibold">${l.stock_actual}</td>
                    <td class="p-3 font-mono text-slate-300">$${Number(l.costo_unitario || 0).toFixed(2)}</td>
                    <td class="p-3 text-xs text-slate-400">${fechaIng}</td>
                    <td class="p-3 text-center">
                        <button type="button" onclick="window.verDetalleLoteMovimiento(${l.id})" class="bg-slate-800 hover:bg-slate-700 text-indigo-300 text-xs px-2.5 py-1 rounded-lg border border-slate-700 transition font-medium">🔍 Documento</button>
                    </td>
                </tr>
            `;
        });
        htmlLotes += `</tbody></table></div>`;

        htmlLotes += `
            <div class="flex items-center justify-between mt-4 px-2">
                <span class="text-xs text-slate-400">Página <strong class="text-slate-200">${paginaActualLotes}</strong> de <strong class="text-slate-200">${totalPaginas}</strong></span>
                <div class="flex gap-2">
                    <button type="button" onclick="window.cambiarPaginaLotes(${paginaActualLotes - 1})" ${paginaActualLotes <= 1 ? 'disabled class="opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800 text-xs px-3 py-1.5 rounded-lg"' : 'class="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-xs px-3 py-1.5 rounded-lg transition"'}>← Anterior</button>
                    <button type="button" onclick="window.cambiarPaginaLotes(${paginaActualLotes + 1})" ${paginaActualLotes >= totalPaginas ? 'disabled class="opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800 text-xs px-3 py-1.5 rounded-lg"' : 'class="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-xs px-3 py-1.5 rounded-lg transition"'}>Siguiente →</button>
                </div>
            </div>
        `;
    }

    contenedorLotes.innerHTML = htmlLotes;
}

window.aplicarFiltroFechasLotes = function() {
    fechaInicioFiltro = document.getElementById('filtroFechaInicio')?.value || '';
    fechaFinFiltro = document.getElementById('filtroFechaFin')?.value || '';
    paginaActualLotes = 1;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

window.limpiarFiltroFechasLotes = function() {
    fechaInicioFiltro = '';
    fechaFinFiltro = '';
    paginaActualLotes = 1;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

window.cambiarPaginaLotes = function(nuevaPagina) {
    paginaActualLotes = nuevaPagina;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

window.verDetalleLoteMovimiento = async function(loteId) {
    try {
        if (!supabaseClient) return;
        const { data: loteInfo, error: errLote } = await supabaseClient
            .from('lotes_inventario')
            .select(`id, numero_lote, stock_actual, costo_unitario, fecha_ingreso, productos ( id, nombre, tipo )`)
            .eq('id', loteId)
            .single();

        if (errLote || !loteInfo) { alert("No se encontró información para este lote."); return; }

        let documentoIdEncontrado = null;
        let infoDetalle = null;

        const { data: detData } = await supabaseClient
            .from('documento_detalles')
            .select('cantidad, costo_unitario, subtotal, documento_id')
            .eq('lote_id', loteId)
            .maybeSingle();

        if (detData && detData.documento_id) {
            documentoIdEncontrado = detData.documento_id;
            infoDetalle = detData;
        } else {
            const { data: movData } = await supabaseClient
                .from('movimientos_inventario')
                .select('cantidad, costo_unitario, documento_id')
                .eq('lote_id', loteId)
                .not('documento_id', 'is', null)
                .limit(1)
                .maybeSingle();

            if (movData && movData.documento_id) {
                documentoIdEncontrado = movData.documento_id;
                infoDetalle = {
                    cantidad: movData.cantidad,
                    costo_unitario: movData.costo_unitario,
                    subtotal: Number(movData.cantidad || 0) * Number(movData.costo_unitario || 0)
                };
            }
        }

        let doc = null;
        if (documentoIdEncontrado) {
            const { data: docData } = await supabaseClient
                .from('documentos')
                .select(`id, tipo_movimiento, folio, fecha_emision, descripcion, estado, proveedores ( nombre )`)
                .eq('id', documentoIdEncontrado)
                .maybeSingle();
            doc = docData;
        }

        const nombreProd = loteInfo.productos?.nombre || 'N/D';
        const numLoteStr = loteInfo.numero_lote || `Lote #${loteInfo.id}`;
        
        let info = `📋 INFORMACIÓN DEL LOTE / TRAZABILIDAD\n-----------------------------------\n` +
                   `• Producto: ${nombreProd}\n• Identificador de Lote: ${numLoteStr}\n` +
                   `• Stock Actual en Lote: ${loteInfo.stock_actual}\n` +
                   `• Costo Unitario: $${Number(loteInfo.costo_unitario || 0).toFixed(2)}\n` +
                   `• Fecha de Ingreso: ${loteInfo.fecha_ingreso ? new Date(loteInfo.fecha_ingreso).toLocaleDateString() : 'N/D'}\n\n`;

        if (doc) {
            info += `📄 DOCUMENTO VINCULADO:\n• ID Documento: #${doc.id}\n• Tipo de Movimiento: ${doc.tipo_movimiento.toUpperCase()}\n` +
                    `• Folio: ${doc.folio || 'N/D'}\n• Proveedor: ${doc.proveedores?.nombre || 'N/D'}\n` +
                    `• Estado: ${doc.estado}\n• Descripción: ${doc.descripcion || 'Sin descripción'}`;
        } else {
            info += `⚠️ Nota: Este lote no cuenta con un documento de entrada/compra formal asociado.`;
        }

        alert(info);
    } catch (err) {
        console.error("Error al consultar detalle del lote:", err);
    }
};

document.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && (e.target.id === 'filtroFechaInicio' || e.target.id === 'filtroFechaFin')) {
        window.aplicarFiltroFechasLotes();
    }
});