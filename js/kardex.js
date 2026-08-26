import { supabaseClient } from './supabase.js';

let productosCache = [];

export async function cargarVistaKardex() {
    await precargarProductosKardex();
    inicializarBuscadorAjax();
}

async function precargarProductosKardex() {
    try {
        const { data: productos, error } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku, tipo, stock_actual')
            .order('nombre', { ascending: true });

        if (error) throw error;
        productosCache = productos || [];
    } catch (err) {
        console.error("Error al precargar productos para el kardex:", err);
    }
}

function inicializarBuscadorAjax() {
    const contenedorFiltro = document.getElementById('selectProductoKardex')?.parentElement || document.getElementById('contenedorBuscadorKardex');
    
    if (!contenedorFiltro || document.getElementById('inputBuscadorKardex')) return;

    contenedorFiltro.innerHTML = `
        <label class="block text-xs uppercase tracking-wider text-slate-400 mb-1 font-semibold">Buscar Producto o Insumo:</label>
        <div class="relative">
            <input 
                type="text" 
                id="inputBuscadorKardex" 
                placeholder="Escribe el nombre o SKU del producto..." 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-slate-200 text-sm focus:outline-none focus:border-indigo-500 transition shadow-inner"
                autocomplete="off"
            >
            <input type="hidden" id="selectProductoKardex" value="">
            <div id="listaResultadosAjax" class="absolute z-50 left-0 right-0 mt-1 bg-slate-950 border border-slate-800 rounded-xl shadow-2xl max-h-60 overflow-y-auto hidden divide-y divide-slate-800/60"></div>
        </div>
    `;

    const inputBuscador = document.getElementById('inputBuscadorKardex');
    const listaResultados = document.getElementById('listaResultadosAjax');
    const inputHiddenId = document.getElementById('selectProductoKardex');

    // Delegación de eventos única para las sugerencias
    listaResultados.addEventListener('click', (e) => {
        const item = e.target.closest('.item-sugerencia-kardex');
        if (!item) return;

        inputBuscador.value = item.getAttribute('data-nombre');
        inputHiddenId.value = item.getAttribute('data-id');
        listaResultados.classList.add('hidden');
        window.consultarKardexProducto();
    });

    inputBuscador.addEventListener('input', (e) => {
        const busqueda = e.target.value.toLowerCase().trim();
        inputHiddenId.value = ""; 

        if (!busqueda) {
            listaResultados.classList.add('hidden');
            return;
        }

        // Búsqueda segura evitando errores si un producto tiene campos nulos
        const filtrados = productosCache.filter(p => {
            const nombre = (p.nombre || '').toLowerCase();
            const sku = (p.sku || '').toLowerCase();
            return nombre.includes(busqueda) || sku.includes(busqueda);
        });

        if (filtrados.length === 0) {
            listaResultados.innerHTML = `<div class="p-3 text-xs text-slate-500 text-center">No se encontraron productos</div>`;
            listaResultados.classList.remove('hidden');
            return;
        }

        listaResultados.innerHTML = filtrados.map(p => `
            <div class="p-3 hover:bg-indigo-600/20 cursor-pointer transition flex justify-between items-center item-sugerencia-kardex" 
                 data-id="${p.id}" 
                 data-nombre="${p.nombre || 'Sin nombre'} ${p.sku ? '(' + p.sku + ')' : ''}">
                <div>
                    <span class="text-sm font-medium text-slate-200 block">${p.nombre || 'Sin nombre'}</span>
                    <span class="text-xs text-slate-400 font-mono">SKU: ${p.sku || 'N/D'} | Tipo: ${p.tipo || 'N/D'}</span>
                </div>
                <span class="text-xs font-mono bg-slate-900 px-2 py-1 rounded text-emerald-400 border border-slate-800">Stock: ${p.stock_actual ?? 0}</span>
            </div>
        `).join('');

        listaResultados.classList.remove('hidden');
    });

    document.addEventListener('click', (e) => {
        if (!inputBuscador.contains(e.target) && !listaResultados.contains(e.target)) {
            listaResultados.classList.add('hidden');
        }
    });
}

window.consultarKardexProducto = async function() {
    let productoId = document.getElementById('selectProductoKardex')?.value;
    const contenedorResultado = document.getElementById('resultadoKardex');

    if (!productoId || !contenedorResultado) {
        alert("Por favor selecciona un producto válido de la lista del buscador.");
        return;
    }

    productoId = String(productoId).replace('eq.', '').trim();
    contenedorResultado.innerHTML = `<div class="bg-slate-900 border border-slate-800 p-8 rounded-xl text-center text-slate-400 text-sm">Consultando movimientos y existencias...</div>`;

    try {
        const { data: productoInfo, error: errProdInfo } = await supabaseClient
            .from('productos')
            .select('nombre, stock_actual, sku')
            .eq('id', productoId)
            .single();

        if (errProdInfo) throw errProdInfo;

        const { data: movimientos, error } = await supabaseClient
            .from('movimientos_inventario')
            .select(`
                id, 
                tipo_movimiento, 
                cantidad, 
                stock_anterior, 
                stock_resultante, 
                costo_unitario, 
                created_at, 
                documento_id,
                lote_id,
                lotes_inventario ( numero_lote )
            `)
            .eq('producto_id', productoId)
            .order('created_at', { ascending: false });

        if (error) throw error;

        let html = `
            <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-4 shadow-lg">
                <div>
                    <h4 class="text-sm font-semibold text-slate-300">Producto Seleccionado:</h4>
                    <span class="text-base font-bold text-amber-400">${productoInfo.nombre || 'Sin nombre'}</span>
                    <span class="text-xs text-slate-500 block">SKU: ${productoInfo.sku || 'N/D'}</span>
                </div>
                <div class="bg-slate-950 px-5 py-2.5 rounded-lg border border-slate-800 text-right w-full sm:w-auto">
                    <span class="text-xs text-slate-400 block uppercase tracking-wider font-medium">Stock Actual en Almacén</span>
                    <span class="text-2xl font-mono font-bold text-emerald-400">${productoInfo.stock_actual ?? 0} <span class="text-xs text-slate-400 font-normal">unidades</span></span>
                </div>
            </div>
        `;

        if (!movimientos || movimientos.length === 0) {
            html += `<div class="bg-slate-900 border border-slate-800 p-6 rounded-xl text-center text-slate-500 text-sm">No hay registros de movimientos en el Kardex para este producto.</div>`;
            contenedorResultado.innerHTML = html;
            return;
        }

        html += `
            <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-900 shadow-xl">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-950 text-indigo-400 border-b border-slate-800 text-xs uppercase">
                        <tr>
                            <th class="p-3">Doc ID</th>
                            <th class="p-3">Fecha y Hora</th>
                            <th class="p-3">Operación</th>
                            <th class="p-3">Lote</th>
                            <th class="p-3">Costo Unit.</th>
                            <th class="p-3 text-center">Stock Ant.</th>
                            <th class="p-3 text-center">Cantidad</th>
                            <th class="p-3 text-center">Stock Nuevo</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        movimientos.forEach(m => {
            const fechaHora = m.created_at ? new Date(m.created_at).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' }) : 'N/D';
            const docId = m.documento_id;
            const cantNum = Number(m.cantidad || 0);
            const esEntrada = cantNum >= 0;
            const claseCantidad = esEntrada ? 'text-emerald-400 font-bold' : 'text-rose-400 font-bold';
            const signo = esEntrada ? '+' : '';
            const numeroLote = m.lotes_inventario?.numero_lote || 'N/D';

            const colDocId = docId ? `
                <button onclick="window.abrirDetalleDocumento('${docId}')" class="font-mono text-xs text-indigo-400 hover:text-indigo-300 hover:underline bg-indigo-950/50 hover:bg-indigo-900/50 px-2 py-1 rounded border border-indigo-800/50 transition flex items-center gap-1 w-fit cursor-pointer">
                    <span>#${docId}</span>
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                </button>
            ` : `<span class="text-slate-500">N/D</span>`;

            html += `
                <tr class="border-b border-slate-800/60 hover:bg-slate-800/40 transition">
                    <td class="p-3">${colDocId}</td>
                    <td class="p-3 text-xs text-slate-400 font-mono">${fechaHora}</td>
                    <td class="p-3 text-xs uppercase font-semibold text-indigo-300">${m.tipo_movimiento || 'N/D'}</td>
                    <td class="p-3 text-xs font-mono text-amber-300">${numeroLote}</td>
                    <td class="p-3 font-mono text-slate-300">$${Number(m.costo_unitario || 0).toFixed(2)}</td>
                    <td class="p-3 text-center font-mono text-slate-400">${m.stock_anterior ?? 0}</td>
                    <td class="p-3 text-center font-mono ${claseCantidad}">${signo}${cantNum}</td>
                    <td class="p-3 text-center font-mono text-amber-300 font-semibold">${m.stock_resultante ?? 0}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorResultado.innerHTML = html;

    } catch (err) {
        console.error("Error al consultar kardex:", err);
        contenedorResultado.innerHTML = `<div class="bg-rose-950/40 border border-rose-900 p-6 rounded-xl text-center text-rose-300 text-sm">Ocurrió un error al consultar los movimientos del kardex.</div>`;
    }
};

window.abrirDetalleDocumento = async function(docId) {
    let modalContainer = document.getElementById('modalDetalleDocKardex');
    if (!modalContainer) {
        modalContainer = document.createElement('div');
        modalContainer.id = 'modalDetalleDocKardex';
        modalContainer.className = 'fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-sm p-4';
        document.body.appendChild(modalContainer);
    }

    modalContainer.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
            <div class="bg-slate-950 px-6 py-4 border-b border-slate-800 flex justify-between items-center">
                <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-indigo-500"></span>
                    Documento Oficial #${docId}
                </h3>
                <button onclick="window.cerrarDetalleDocumento()" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2">&times;</button>
            </div>
            <div class="p-6 text-slate-300 text-sm max-h-[75vh] overflow-y-auto space-y-6" id="contenidoModalDoc">
                <div class="text-center py-8 text-slate-500">Consultando datos del documento en la base de datos...</div>
            </div>
            <div class="bg-slate-950 px-6 py-3 border-t border-slate-800 flex justify-between items-center">
                <span class="text-[11px] text-slate-500 font-mono">ID Registro: ${docId}</span>
                <button onclick="window.cerrarDetalleDocumento()" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-xl text-xs font-semibold transition">Cerrar</button>
            </div>
        </div>
    `;
    modalContainer.classList.remove('hidden');

    try {
        const { data: docInfo, error: errDoc } = await supabaseClient
            .from('documentos')
            .select('*, proveedores ( nombre, contacto, telefono )')
            .eq('id', docId)
            .single();

        if (errDoc) throw errDoc;

        const { data: detalles, error: errDetalles } = await supabaseClient
            .from('documento_detalles')
            .select('*, productos ( nombre, sku, tipo ), lotes_inventario ( numero_lote )')
            .eq('documento_id', docId);

        if (errDetalles) throw errDetalles;

        const contenidoModal = document.getElementById('contenidoModalDoc');
        const fechaEmision = docInfo.fecha_emision ? new Date(docInfo.fecha_emision).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' }) : 'N/D';
        const proveedorNombre = docInfo.proveedores?.nombre || docInfo.proveedor_cliente || 'N/D';

        let html = `
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-slate-950 p-4 rounded-xl border border-slate-800/80">
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Tipo de Movimiento</span>
                    <span class="text-sm font-bold text-indigo-400 uppercase">${docInfo.tipo_movimiento || 'N/D'}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Folio</span>
                    <span class="text-sm font-mono text-slate-200">${docInfo.folio || 'Sin Folio'}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Fecha de Emisión</span>
                    <span class="text-xs font-mono text-slate-300">${fechaEmision}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Estado</span>
                    <span class="text-xs font-semibold text-emerald-400 uppercase">${docInfo.estado || 'N/D'}</span>
                </div>
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Proveedor / Tercero</span>
                    <span class="text-xs font-medium text-slate-200">${proveedorNombre}</span>
                </div>
                ${docInfo.descripcion ? `
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Descripción / Observaciones</span>
                    <span class="text-xs text-slate-300">${docInfo.descripcion}</span>
                </div>` : ''}
            </div>

            <div>
                <h4 class="text-xs uppercase tracking-wider text-slate-400 font-bold mb-3">Partidas del Documento</h4>
                <div class="space-y-3">
        `;

        if (!detalles || detalles.length === 0) {
            html += `<div class="p-4 text-center text-slate-500 text-xs bg-slate-950 rounded-xl border border-slate-800">No hay detalles registrados para este documento.</div>`;
        } else {
            detalles.forEach((det, index) => {
                const prod = det.productos || {};
                const loteNum = det.lotes_inventario?.numero_lote ? `Lote: ${det.lotes_inventario.numero_lote}` : '';

                html += `
                    <div class="bg-slate-950 border border-slate-800 p-3.5 rounded-xl space-y-2">
                        <div class="flex justify-between items-start border-b border-slate-800/60 pb-2">
                            <div>
                                <span class="text-xs font-bold text-amber-400 block">${index + 1}. ${prod.nombre || 'Producto Desconocido'}</span>
                                <span class="text-[10px] text-slate-500 font-mono">SKU: ${prod.sku || 'N/D'} ${loteNum ? '| ' + loteNum : ''}</span>
                            </div>
                            <div class="text-right font-mono">
                                <span class="text-sm font-bold text-slate-200">${det.cantidad ?? 0}</span>
                                <span class="text-[10px] text-slate-500 block">Cantidad</span>
                            </div>
                        </div>
                        <div class="flex justify-between items-center text-xs font-mono pt-1">
                            <span class="text-slate-400">Costo Unitario: <strong class="text-emerald-400">$${Number(det.costo_unitario || 0).toFixed(2)}</strong></span>
                            <span class="text-slate-400">Subtotal: <strong class="text-amber-300">$${Number(det.subtotal || 0).toFixed(2)}</strong></span>
                        </div>
                    </div>
                `;
            });
        }

        html += `</div></div>`;
        contenidoModal.innerHTML = html;

    } catch (err) {
        console.error("Error al obtener el documento completo:", err);
        const contenidoModal = document.getElementById('contenidoModalDoc');
        if (contenidoModal) {
            contenidoModal.innerHTML = `<div class="text-rose-400 text-center py-6">Error al consultar la información del documento en la base de datos.</div>`;
        }
    }
};

window.cerrarDetalleDocumento = function() {
    const modalContainer = document.getElementById('modalDetalleDocKardex');
    if (modalContainer) {
        modalContainer.classList.add('hidden');
    }
};