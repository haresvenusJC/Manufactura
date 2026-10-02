import { supabaseClient } from './supabase.js';

// Kardex de un producto específico, embebido en la pantalla "Catálogo y
// Kardex" (js/catalogo.js, ☰ → "Kardex de este producto") — sin vista ni
// buscador propios: el producto ya se eligió en la tabla del Catálogo.
export async function renderizarKardexProducto(productoIdParam, contenedorResultado) {
    const productoId = String(productoIdParam).replace('eq.', '').trim();
    if (!productoId || !contenedorResultado) return;

    contenedorResultado.innerHTML = `<div class="bg-slate-900 border border-slate-800 p-8 rounded-xl text-center text-slate-400 text-sm">Consultando movimientos y existencias...</div>`;

    try {
        const { data: productoInfo, error: errProdInfo } = await supabaseClient
            .from('productos')
            .select('nombre, stock_actual, sku, unidades_medida ( nombre )')
            .eq('id', productoId)
            .single();

        if (errProdInfo) throw errProdInfo;
        const unidadNombre = productoInfo.unidades_medida?.nombre || 'unidad';

        const colsMov = `
                id,
                tipo_movimiento,
                cantidad,
                stock_anterior,
                stock_resultante,
                costo_unitario,
                created_at,
                documento_id,
                lote_id,
                criterio_lote,
                lotes_inventario ( id, numero_lote, costo_adicional_unitario )
            `;
        let { data: movimientos, error } = await supabaseClient
            .from('movimientos_inventario')
            .select(colsMov)
            .eq('producto_id', productoId)
            .order('created_at', { ascending: true });

        // Degradar si aún no existe movimientos_inventario.criterio_lote (falta sql/2026-09-13)
        if (error && /criterio_lote|column .* does not exist/i.test(error.message || '')) {
            ({ data: movimientos, error } = await supabaseClient
                .from('movimientos_inventario')
                .select(colsMov.replace('criterio_lote,', ''))
                .eq('producto_id', productoId)
                .order('created_at', { ascending: true }));
        }
        // Degradar si aún no existe lotes_inventario.costo_adicional_unitario (falta sql/2026-09-20)
        if (error && /costo_adicional_unitario|column .* does not exist/i.test(error.message || '')) {
            ({ data: movimientos, error } = await supabaseClient
                .from('movimientos_inventario')
                .select(colsMov.replace('criterio_lote,', '').replace(', costo_adicional_unitario', ''))
                .eq('producto_id', productoId)
                .order('created_at', { ascending: true }));
        }

        if (error) throw error;

        // Lotes que aparecen en los movimientos de este producto, para el filtro
        const lotesMap = new Map();
        movimientos.forEach(m => {
            if (m.lotes_inventario && m.lotes_inventario.id) {
                lotesMap.set(m.lotes_inventario.id, m.lotes_inventario.numero_lote);
            }
        });

        const htmlResumen = `
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
            contenedorResultado.innerHTML = htmlResumen + `<div class="bg-slate-900 border border-slate-800 p-6 rounded-xl text-center text-slate-500 text-sm">No hay registros de movimientos en el Kardex para este producto.</div>`;
            return;
        }

        // Cálculo acumulado de stock por lote independiente
        const stockAcumuladoLotes = {};
        const movimientosProcesados = movimientos.map(m => {
            const loteKey = m.lote_id || 'SIN_LOTE';
            if (stockAcumuladoLotes[loteKey] === undefined) {
                stockAcumuladoLotes[loteKey] = 0;
            }

            const stockAnt = stockAcumuladoLotes[loteKey];
            const cantNum = Number(m.cantidad || 0);
            const stockNuevo = stockAnt + cantNum;
            stockAcumuladoLotes[loteKey] = stockNuevo;

            return {
                ...m,
                stock_anterior_calc: stockAnt,
                stock_resultante_calc: stockNuevo
            };
        }).reverse();

        const htmlSelectLote = lotesMap.size ? `
            <div class="mb-3">
                <label class="block text-xs uppercase tracking-wider text-slate-400 mb-1 font-semibold">Filtrar por Lote:</label>
                <select id="kpxFiltroLote" class="w-full sm:w-72 bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-slate-300 text-sm focus:outline-none focus:border-indigo-500 transition">
                    <option value="">-- Todos los Lotes --</option>
                    ${[...lotesMap.entries()].map(([idLote, numeroLote]) => `<option value="${idLote}">Lote: ${numeroLote}</option>`).join('')}
                </select>
            </div>
        ` : '';

        // Pinta la tabla de movimientos para el lote elegido (sin volver a consultar Supabase).
        function pintar(filtroLoteId) {
            const movimientosFiltrados = filtroLoteId
                ? movimientosProcesados.filter(m => String(m.lote_id) === String(filtroLoteId))
                : movimientosProcesados;

            let htmlTabla;
            if (movimientosFiltrados.length === 0) {
                htmlTabla = `<div class="bg-slate-900 border border-slate-800 p-6 rounded-xl text-center text-slate-500 text-sm">No hay movimientos registrados para el lote seleccionado.</div>`;
            } else {
                htmlTabla = `
                    <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-900 shadow-xl">
                        <table class="w-full text-left text-sm text-slate-300">
                            <thead class="bg-slate-950 text-indigo-400 border-b border-slate-800 text-xs uppercase">
                                <tr>
                                    <th class="p-3">Doc ID</th>
                                    <th class="p-3">Fecha y Hora</th>
                                    <th class="p-3">Operación</th>
                                    <th class="p-3">Lote</th>
                                    <th class="p-3">Costo Unit. <span class="normal-case text-slate-500">(por ${unidadNombre})</span></th>
                                    <th class="p-3 text-center">Stock Ant.</th>
                                    <th class="p-3 text-center">Cantidad</th>
                                    <th class="p-3 text-center">Stock Nuevo</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${movimientosFiltrados.map((m) => {
                                    const fechaHora = m.created_at ? new Date(m.created_at).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' }) : 'N/D';
                                    const docId = m.documento_id;
                                    const cantNum = Number(m.cantidad || 0);
                                    const esEntrada = cantNum >= 0;
                                    const claseCantidad = esEntrada ? 'text-emerald-400 font-bold' : 'text-rose-400 font-bold';
                                    const signo = esEntrada ? '+' : '';
                                    const numeroLote = m.lotes_inventario?.numero_lote || 'N/D';
                                    const chipFefo = m.criterio_lote === 'FEFO'
                                        ? ' <span class="text-[9px] bg-amber-900/50 text-amber-300 border border-amber-700 rounded px-1 py-0.5 align-middle" title="Este lote se adelantó por caducidad (conviene a producción)">FEFO</span>'
                                        : '';

                                    const colDocId = docId ? `
                                        <button onclick="window.abrirDetalleDocumento('${docId}')" class="font-mono text-xs text-indigo-400 hover:text-indigo-300 hover:underline bg-indigo-950/50 hover:bg-indigo-900/50 px-2 py-1 rounded border border-indigo-800/50 transition flex items-center gap-1 w-fit cursor-pointer">
                                            <span>#${docId}</span>
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                                        </button>
                                    ` : `<span class="text-slate-500">N/D</span>`;

                                    return `
                                        <tr class="border-b border-slate-800/60 hover:bg-slate-800/40 transition">
                                            <td class="p-3">${colDocId}</td>
                                            <td class="p-3 text-xs text-slate-400 font-mono">${fechaHora}</td>
                                            <td class="p-3 text-xs uppercase font-semibold text-indigo-300">${m.tipo_movimiento || 'N/D'}</td>
                                            <td class="p-3 text-xs font-mono text-amber-300">${numeroLote}${chipFefo}</td>
                                            <td class="p-3 font-mono text-slate-300">
                                                $${Number(m.costo_unitario || 0).toFixed(4)}
                                                ${(() => {
                                                    const adic = Number(m.lotes_inventario?.costo_adicional_unitario || 0);
                                                    if (!adic) return '';
                                                    const mat = Number(m.costo_unitario || 0) - adic;
                                                    return `<span class="block text-[10px] text-sky-400 font-sans">incluye landed cost: mat. $${mat.toFixed(4)} + $${adic.toFixed(4)} flete/seguro</span>`;
                                                })()}
                                            </td>
                                            <td class="p-3 text-center font-mono text-slate-400">${m.stock_anterior_calc ?? 0}</td>
                                            <td class="p-3 text-center font-mono ${claseCantidad}">${signo}${cantNum}</td>
                                            <td class="p-3 text-center font-mono text-amber-300 font-semibold">${m.stock_resultante_calc ?? 0}</td>
                                        </tr>
                                    `;
                                }).join('')}
                            </tbody>
                        </table>
                    </div>
                `;
            }

            contenedorResultado.innerHTML = htmlResumen + htmlSelectLote + htmlTabla;
            document.getElementById('kpxFiltroLote')?.addEventListener('change', (e) => pintar(e.target.value));
        }

        pintar('');

    } catch (err) {
        console.error("Error al consultar kardex:", err);
        contenedorResultado.innerHTML = `<div class="bg-rose-950/40 border border-rose-900 p-6 rounded-xl text-center text-rose-300 text-sm">Ocurrió un error al consultar los movimientos del kardex.</div>`;
    }
}

// Ctrl/Cmd + clic en el "Doc ID" de una fila del Kardex: instancia aparte
// (window.idSubventana, subventanas-movibles.js) — window.cerrarDetalleDocumento
// (definición vigente: js/documentos.js, se carga después y pisa la de aquí)
// ya sabe cerrar tanto la de siempre como una abierta aparte.
window.abrirDetalleDocumento = async function(docId) {
    const idModal = window.idSubventana('modalDetalleDocKardex');
    const esPrincipal = idModal === 'modalDetalleDocKardex';
    const idContenido = esPrincipal ? 'contenidoModalDoc' : `contenidoModalDoc__${idModal}`;
    let modalContainer = esPrincipal ? document.getElementById(idModal) : null;
    if (!modalContainer) {
        modalContainer = document.createElement('div');
        modalContainer.id = idModal;
        modalContainer.className = 'fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 p-4';
        document.body.appendChild(modalContainer);
    }

    modalContainer.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
            <div class="bg-slate-950 px-6 py-4 border-b border-slate-800 flex justify-between items-center">
                <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-indigo-500"></span>
                    Documento Oficial #${docId}
                </h3>
                <button onclick="window.cerrarDetalleDocumento('${idModal}')" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2">&times;</button>
            </div>
            <div class="p-6 text-slate-300 text-sm max-h-[75vh] overflow-y-auto space-y-6" id="${idContenido}">
                <div class="text-center py-8 text-slate-500">Consultando datos del documento en la base de datos...</div>
            </div>
            <div class="bg-slate-950 px-6 py-3 border-t border-slate-800 flex justify-between items-center">
                <span class="text-[11px] text-slate-500 font-mono">ID Registro: ${docId}</span>
                <button onclick="window.cerrarDetalleDocumento('${idModal}')" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-xl text-xs font-semibold transition">Cerrar</button>
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

        const contenidoModal = document.getElementById(idContenido);
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
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold">Póliza contable</span>
                    ${docInfo.poliza_id
                        ? `<button onclick="window.verPolizaDeDocumento(${docInfo.poliza_id}, '${docInfo.fecha_emision || ''}')" class="mt-1 text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-3 py-1.5 rounded-lg inline-flex items-center gap-1.5" style="cursor:pointer;">🧾 Ver póliza #${docInfo.poliza_id}</button>`
                        : `<span class="text-xs text-amber-400">Sin póliza — este documento no se contabilizó.</span>`}
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
        const contenidoModal = document.getElementById(idContenido);
        if (contenidoModal) {
            contenidoModal.innerHTML = `<div class="text-rose-400 text-center py-6">Error al consultar la información del documento en la base de datos.</div>`;
        }
    }
};
// window.cerrarDetalleDocumento vive en js/documentos.js (se carga después y
// pisa cualquier definición de aquí) — cierra tanto esta como esa, no se repite.