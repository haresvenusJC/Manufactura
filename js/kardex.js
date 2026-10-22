import { supabaseClient } from './supabase.js';
import { montarBuscadorProductos } from './buscador-productos.js';
import { imprimirConPlantilla } from './impresion.js';
import { hoyISO } from './fechas.js';
import { thColumna, wireFiltrosColumna } from './filtro-columna.js';
import { crearOrdenTabla, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';


import { money, money4, importe, redondear2 } from './formato.js';
// Folio del documento de cada movimiento (OPC-000001, ENT-000001, ODC-…): una sola consulta por los ids distintos.
// Si falla, la fila sigue mostrando "#id" como antes. Modifica y devuelve el mismo arreglo.
export async function adjuntarFoliosDocumento(movs) {
    try {
        const ids = [...new Set((movs || []).map((m) => m.documento_id).filter(Boolean))];
        if (!ids.length) return movs;
        const { data } = await supabaseClient.from('documentos').select('id, folio').in('id', ids);
        const folios = new Map((data || []).map((d) => [d.id, d.folio]));
        movs.forEach((m) => { if (m.documento_id && folios.get(m.documento_id)) m.doc_folio = folios.get(m.documento_id); });
    } catch (_) { /* sin folio: se queda el #id */ }
    return movs;
}
// Una fila de la tabla de movimientos del Kardex (la usan el Kardex embebido de Productos y el visor de Inventario → Kardex).
export function filaMovimientoKardex(m) {
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
                                        <button onclick="window.abrirDetalleDocumento('${docId}')" class="print-keep font-mono text-xs text-indigo-400 hover:text-indigo-300 hover:underline bg-indigo-950/50 hover:bg-indigo-900/50 px-2 py-1 rounded border border-indigo-800/50 transition flex items-center gap-1 w-fit cursor-pointer">
                                            <span>${esc(m.doc_folio || ("#" + docId))}</span>
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
                                                ${money4(m.costo_unitario)}
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
}

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

        await adjuntarFoliosDocumento(movimientos);
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
                                ${movimientosFiltrados.map(filaMovimientoKardex).join('')}
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
                            <span class="text-slate-400">Costo Unitario: <strong class="text-emerald-400">${money4(det.costo_unitario)}</strong></span>
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

// =====================================================================
//  Inventario → Kardex: visor por RANGO DE FECHAS y uno o varios PRODUCTOS.
//  Por cada producto: saldo inicial (todo lo anterior a "Desde"), sus movimientos del periodo en orden cronológico
//  (el saldo corriente de cada fila es por lote, igual que en el Kardex de Productos), entradas, salidas y saldo final.
//  Pide al menos un producto: el saldo corriente exige el historial completo de cada uno.
// =====================================================================
const esc = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fmtNum = (n) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 4 });
const inicioMesISO = () => hoyISO().slice(0, 8) + '01';
const MAX_PRODUCTOS_KARDEX = 10;

let kdxProductos = [];          // [{ id, sku, nombre }] elegidos
let kdxUltimo = null;           // { bloques, desde, hasta } para exportar a CSV

// Mismos degradados que el Kardex de Productos si faltan columnas de migraciones viejas.
async function consultarMovimientosKardex(productoId) {
    const cols = `id, tipo_movimiento, cantidad, stock_anterior, stock_resultante, costo_unitario, created_at,
        documento_id, lote_id, criterio_lote, lotes_inventario ( id, numero_lote, costo_adicional_unitario )`;
    const intentos = [cols, cols.replace('criterio_lote,', ''), cols.replace('criterio_lote,', '').replace(', costo_adicional_unitario', '')];
    let ultimoError = null;
    for (const c of intentos) {
        const { data, error } = await supabaseClient.from('movimientos_inventario').select(c)
            .eq('producto_id', productoId).order('created_at', { ascending: true }).order('id', { ascending: true });
        if (!error) return await adjuntarFoliosDocumento(data || []);
        ultimoError = error;
        if (!/criterio_lote|costo_adicional_unitario|column .* does not exist/i.test(error.message || '')) break;
    }
    throw ultimoError;
}

// Filtros por columna del visor (menú ▼ en el encabezado) y orden de las filas DENTRO de cada producto.
const kdxOrden = crearOrdenTabla('fecha', 'asc'); // por default lo más antiguo arriba (el saldo corriente se lee de arriba hacia abajo)
const kdxFiltros = { op: '', lote: '', mov: '' };
const KDX_ANCHOS = [12, 15, 17, 14, 12, 10, 10, 10];

// Tabla con un solo renglón de mensaje (vacío, consultando, error): el aviso se centra en el marco (lista-completa + estado-vacio.js).
function kdxTablaMensaje(texto, clase = 'text-slate-500') {
    return `<table class="w-full table-fixed text-left text-sm text-slate-300">
        <colgroup>${KDX_ANCHOS.map((a) => `<col style="width:${a}%">`).join('')}</colgroup>
        <thead class="bg-slate-900 text-slate-300 border-b border-slate-800 text-xs"><tr>
            <th class="p-3">Doc ID</th><th class="p-3">Fecha y hora</th><th class="p-3">Operación</th><th class="p-3">Lote</th>
            <th class="p-3">Costo unit.</th><th class="p-3 text-center">Stock ant.</th><th class="p-3 text-center">Cantidad</th><th class="p-3 text-center">Stock nuevo</th>
        </tr></thead>
        <tbody><tr><td colspan="8" class="p-4 text-center ${clase} text-sm">${esc(texto)}</td></tr></tbody></table>`;
}

function pintarResultadoKardex(cont) {
    const res = cont.querySelector('#kdxResultado');
    const info = cont.querySelector('#kdxInfo');
    if (!kdxUltimo) {
        res.innerHTML = kdxTablaMensaje('Sin consulta todavía: elige el periodo y al menos un producto, y da "Consultar".');
        info.innerHTML = '';
        return;
    }
    const bloques = kdxUltimo.bloques;
    const cumple = (m, excepto) => {
        if (excepto !== 'op' && kdxFiltros.op && (m.tipo_movimiento || 'N/D') !== kdxFiltros.op) return false;
        if (excepto !== 'lote' && kdxFiltros.lote && (m.lotes_inventario?.numero_lote || 'N/D') !== kdxFiltros.lote) return false;
        if (excepto !== 'mov' && kdxFiltros.mov && (Number(m.cantidad || 0) >= 0) !== (kdxFiltros.mov === 'entrada')) return false;
        return true;
    };
    const todas = bloques.flatMap((b) => b.filas);
    const cuenta = (excepto, fn) => todas.filter((m) => cumple(m, excepto) && fn(m)).length;
    const unicos = (fn) => [...new Set(todas.map(fn))].sort((a, b) => String(a).localeCompare(String(b), 'es'));

    const th = [
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'doc', titulo: 'Doc ID', filtro: { id: 'orden', valor: kdxOrden.campo === 'fecha' ? kdxOrden.dir : '', opciones: [
            { v: 'asc', t: 'Más antiguo arriba' },
            { v: 'desc', t: 'Más nuevo arriba' },
        ] } }),
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'fecha', titulo: 'Fecha y hora' }),
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'op', titulo: 'Operación', filtro: { id: 'op', valor: kdxFiltros.op, opciones: [
            { v: '', t: 'Todas', n: cuenta('op', () => true) },
            ...unicos((m) => m.tipo_movimiento || 'N/D').map((o) => ({ v: o, t: o, n: cuenta('op', (m) => (m.tipo_movimiento || 'N/D') === o) })),
        ] } }),
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'lote', titulo: 'Lote', filtro: { id: 'lote', valor: kdxFiltros.lote, opciones: [
            { v: '', t: 'Todos', n: cuenta('lote', () => true) },
            ...unicos((m) => m.lotes_inventario?.numero_lote || 'N/D').map((l) => ({ v: l, t: l, n: cuenta('lote', (m) => (m.lotes_inventario?.numero_lote || 'N/D') === l) })),
        ] } }),
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'costo', titulo: 'Costo unit.' }),
        '<th class="px-3 py-2 text-center">Stock ant.</th>',
        thColumna({ orden: kdxOrden, pad: 'px-3 py-2', campo: 'cantidad', titulo: 'Cantidad', clase: 'text-center', filtro: { id: 'mov', valor: kdxFiltros.mov, opciones: [
            { v: '', t: 'Todos', n: cuenta('mov', () => true) },
            { v: 'entrada', t: 'Entradas', n: cuenta('mov', (m) => Number(m.cantidad || 0) >= 0) },
            { v: 'salida', t: 'Salidas', n: cuenta('mov', (m) => Number(m.cantidad || 0) < 0) },
        ] } }),
        '<th class="px-3 py-2 text-center">Stock nuevo</th>',
    ].join('');

    const tarjeta = (titulo, valor, clase) => `<span class="px-2 py-0.5 rounded-md bg-slate-950 border border-slate-800 text-right leading-tight"><span class="block text-[9px] text-slate-400">${titulo}</span><span class="font-mono text-xs font-semibold ${clase}">${fmtNum(valor)}</span></span>`;
    let visibles = 0;
    // Orden visual: PRIMERO el resumen del producto (nombre, SKU, saldo inicial, entradas, salidas, saldo final) y DEBAJO los
    // encabezados de columna y sus movimientos. Con un solo producto ambos van en el <thead> (quedan fijos al desplazar);
    // con varios, cada producto trae su propio resumen + encabezados dentro del cuerpo.
    const unico = bloques.length === 1;
    const resumenTr = (b) => `
        <tr class="bg-slate-900"><td colspan="8" class="px-3 py-1.5 border-t border-slate-700 text-left">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div><span class="text-sm font-bold text-amber-400">${esc(b.producto.nombre)}</span>
                    <span class="block text-[11px] leading-tight text-slate-500 font-normal">SKU: ${esc(b.producto.sku || 'N/D')} · Unidad: ${esc(b.unidad)} · Stock actual: <span class="font-mono text-emerald-400">${fmtNum(b.producto.stock_actual)}</span></span></div>
                <div class="flex flex-wrap gap-2">${tarjeta('Saldo inicial', b.saldoInicial, 'text-slate-200')}${tarjeta('Entradas', b.entradas, 'text-emerald-400')}${tarjeta('Salidas', b.salidas, 'text-rose-400')}${tarjeta('Saldo final', b.saldoFinal, 'text-amber-300')}</div>
            </div>
        </td></tr>`;
    const encabezadoTr = `<tr class="bg-slate-900 text-slate-300 border-b border-slate-800 text-xs">${th}</tr>`;
    const cuerpo = bloques.map((b) => {
        const filas = b.filas.filter((m) => cumple(m, null));
        aplicarOrden(kdxOrden, filas, (m, campo) => {
            switch (campo) {
                case 'fecha': return new Date(m.created_at).getTime();
                case 'doc': return Number(m.documento_id || 0);
                case 'op': return (m.tipo_movimiento || '').toLowerCase();
                case 'lote': return (m.lotes_inventario?.numero_lote || '').toLowerCase();
                case 'costo': return Number(m.costo_unitario || 0);
                case 'cantidad': return Number(m.cantidad || 0);
                default: return 0;
            }
        });
        visibles += filas.length;
        return `${unico ? '' : resumenTr(b) + encabezadoTr}
            ${filas.length ? filas.map(filaMovimientoKardex).join('')
                : `<tr><td colspan="8" class="p-3 text-center text-xs text-slate-500">${b.filas.length ? 'Ningún movimiento coincide con los filtros.' : 'Sin movimientos en el periodo.'}</td></tr>`}`;
    }).join('');

    const hayFiltros = Object.values(kdxFiltros).some(Boolean);
    info.innerHTML = `<span>${visibles} de ${todas.length} movimientos · ${bloques.length} producto(s). Los saldos y totales de cada producto son del periodo completo; los filtros solo ocultan filas.</span>
        ${hayFiltros ? '<button type="button" id="kdxLimpiarFiltros" class="text-sky-300 hover:text-sky-200 underline shrink-0">Quitar filtros</button>' : ''}`;
    res.innerHTML = `<table class="w-full table-fixed text-left text-sm text-slate-300">
        <colgroup>${KDX_ANCHOS.map((a) => `<col style="width:${a}%">`).join('')}</colgroup>
        ${unico ? `<thead class="bg-slate-900 text-slate-300 text-xs">${resumenTr(bloques[0])}${encabezadoTr}</thead>` : ''}
        <tbody>${cuerpo}</tbody></table>`;

    wireOrdenTabla(res, kdxOrden, () => pintarResultadoKardex(cont));
    wireFiltrosColumna(res, (id, valor) => {
        if (id === 'orden') { kdxOrden.campo = 'fecha'; kdxOrden.dir = valor; } // menú de Doc ID: antiguo o nuevo arriba
        else kdxFiltros[id] = valor;
        pintarResultadoKardex(cont);
    });
    info.querySelector('#kdxLimpiarFiltros')?.addEventListener('click', () => {
        Object.keys(kdxFiltros).forEach((k) => { kdxFiltros[k] = ''; });
        pintarResultadoKardex(cont);
    });
}

export async function cargarModuloKardex() {
    const cont = document.getElementById('contenedorKardexVisor');
    if (!cont) return;
    if (!cont.dataset.armado) {
        cont.dataset.armado = '1';
        cont.innerHTML = `
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-3 mb-2 space-y-2">
                <div class="flex flex-wrap items-end gap-3">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Desde:</label>
                        <input type="date" id="kdxDesde" value="${inicioMesISO()}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-3 py-1.5"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Hasta:</label>
                        <input type="date" id="kdxHasta" value="${hoyISO()}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-3 py-1.5"></div>
                    <div class="relative flex-1 min-w-[16rem]">
                        <label class="block text-[11px] text-slate-400 mb-1">Producto (SKU o nombre) — puedes elegir varios:</label>
                        <input type="text" id="kdxBuscar" autocomplete="off" placeholder="🔍 Escribe para buscar y elige de la lista…" class="w-full bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-3 py-1.5">
                        <div id="kdxSug" class="hidden absolute left-0 right-0 top-full mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-2xl max-h-60 overflow-y-auto z-30"></div>
                    </div>
                    <button type="button" id="kdxConsultar" class="bg-indigo-600 hover:bg-indigo-500 text-white text-xs px-4 py-2 rounded-lg font-medium">Consultar</button>
                    <button type="button" id="kdxImprimir" disabled class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 disabled:opacity-40">🖨️ Imprimir</button>
                    <button type="button" id="kdxCsv" disabled class="text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 px-3 py-2 rounded-lg border border-slate-700 disabled:opacity-40">⬇ CSV</button>
                </div>
                <div id="kdxChips" class="flex flex-wrap gap-1.5 empty:hidden"></div>
            </div>
            <div id="kdxInfo" class="flex items-center justify-between gap-3 text-[11px] text-slate-500 mb-1 min-h-[1rem]"></div>
            <div id="kdxResultado" class="border border-slate-800 rounded-xl bg-slate-950"></div>`;
        montarGuia(cont, 'kardex');
        pintarResultadoKardex(cont);

        const pintarChips = () => {
            cont.querySelector('#kdxChips').innerHTML = kdxProductos.map((p) => `
                <span class="inline-flex items-center gap-1.5 bg-indigo-950/60 border border-indigo-800 text-indigo-200 text-[11px] rounded-full pl-3 pr-1.5 py-1">
                    ${esc(p.nombre)} <span class="font-mono text-indigo-400/70">${esc(p.sku || '')}</span>
                    <button type="button" data-quitar="${p.id}" class="text-indigo-300 hover:text-white px-1" title="Quitar">&times;</button>
                </span>`).join('');
            cont.querySelectorAll('[data-quitar]').forEach((b) => b.addEventListener('click', () => {
                kdxProductos = kdxProductos.filter((x) => String(x.id) !== b.dataset.quitar);
                pintarChips();
            }));
        };
        montarBuscadorProductos({
            input: cont.querySelector('#kdxBuscar'), caja: cont.querySelector('#kdxSug'),
            alElegir: (p) => {
                if (kdxProductos.some((x) => x.id === p.id)) return;
                if (kdxProductos.length >= MAX_PRODUCTOS_KARDEX) { alert(`Máximo ${MAX_PRODUCTOS_KARDEX} productos por consulta.`); return; }
                kdxProductos.push(p);
                pintarChips();
                cont.querySelector('#kdxBuscar').focus();
            },
        });
        cont.querySelector('#kdxConsultar').addEventListener('click', () => consultarKardexVisor(cont));
        cont.querySelector('#kdxImprimir').addEventListener('click', () => {
            if (!kdxUltimo) return;
            imprimirConPlantilla('reporte', `Kardex ${kdxUltimo.desde} a ${kdxUltimo.hasta}`, cont.querySelector('#kdxResultado'));
        });
        cont.querySelector('#kdxCsv').addEventListener('click', () => exportarKardexCsv());
    }
}

async function consultarKardexVisor(cont) {
    const res = cont.querySelector('#kdxResultado');
    const desde = cont.querySelector('#kdxDesde').value;
    const hasta = cont.querySelector('#kdxHasta').value;
    if (!kdxProductos.length) { res.innerHTML = kdxTablaMensaje('Elige al menos un producto.', 'text-amber-300'); return; }
    if (desde && hasta && desde > hasta) { res.innerHTML = kdxTablaMensaje('"Desde" no puede ser posterior a "Hasta".', 'text-amber-300'); return; }
    const ini = desde ? new Date(desde + 'T00:00:00') : null;
    const fin = hasta ? new Date(hasta + 'T23:59:59.999') : null;

    res.innerHTML = kdxTablaMensaje('Consultando movimientos…', 'text-slate-400');
    cont.querySelector('#kdxInfo').innerHTML = '';
    cont.querySelector('#kdxImprimir').disabled = true; cont.querySelector('#kdxCsv').disabled = true;
    try {
        // Todos los productos en paralelo (antes uno tras otro: el tiempo crecía con cada producto elegido).
        const bloques = await Promise.all(kdxProductos.map(async (p) => {
            const [{ data: info, error: eInfo }, movs] = await Promise.all([
                supabaseClient.from('productos').select('nombre, sku, stock_actual, unidades_medida ( nombre )').eq('id', p.id).single(),
                consultarMovimientosKardex(p.id),
            ]);
            if (eInfo) throw eInfo;
            // Saldo corriente del PRODUCTO (todos sus lotes juntos) sobre TODO el historial, en orden cronológico: cada fila parte
            // del saldo que dejó la anterior (así la primera fila del periodo arranca en el saldo inicial real y la última cierra en el saldo final).
            let corriente = 0;
            const filas = movs.map((m) => {
                const ant = corriente;
                corriente += Number(m.cantidad || 0);
                return { ...m, stock_anterior_calc: Number(ant.toFixed(4)), stock_resultante_calc: Number(corriente.toFixed(4)) };
            });
            const t = (m) => new Date(m.created_at).getTime();
            const antes = filas.filter((m) => ini && t(m) < ini.getTime());
            const enRango = filas.filter((m) => (!ini || t(m) >= ini.getTime()) && (!fin || t(m) <= fin.getTime()));
            const suma = (arr, f) => arr.reduce((a, m) => a + f(Number(m.cantidad || 0)), 0);
            const saldoInicial = suma(antes, (c) => c);
            const entradas = suma(enRango, (c) => (c > 0 ? c : 0));
            const salidas = suma(enRango, (c) => (c < 0 ? -c : 0));
            return { producto: { ...p, ...info }, unidad: info.unidades_medida?.nombre || 'unidad', filas: enRango, saldoInicial, entradas, salidas, saldoFinal: saldoInicial + entradas - salidas };
        }));
        kdxUltimo = { bloques, desde, hasta };
        kdxOrden.campo = 'fecha'; kdxOrden.dir = 'asc'; // cada consulta nueva vuelve al orden cronológico (antiguo arriba)
        Object.keys(kdxFiltros).forEach((k) => { kdxFiltros[k] = ''; });
        pintarResultadoKardex(cont);
        cont.querySelector('#kdxImprimir').disabled = false; cont.querySelector('#kdxCsv').disabled = false;
    } catch (err) {
        console.error('Error en el visor de Kardex:', err);
        res.innerHTML = kdxTablaMensaje(`No se pudo consultar el Kardex: ${err.message || err}`, 'text-rose-300');
    }
}

function exportarKardexCsv() {
    if (!kdxUltimo) return;
    const q = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const filas = [['Producto', 'SKU', 'Fecha', 'Documento', 'Operación', 'Lote', 'Costo unitario', 'Stock anterior (lote)', 'Cantidad', 'Stock nuevo (lote)']];
    kdxUltimo.bloques.forEach((b) => {
        filas.push([b.producto.nombre, b.producto.sku, `Saldo inicial al ${kdxUltimo.desde}`, '', '', '', '', '', b.saldoInicial, '']);
        b.filas.forEach((m) => filas.push([b.producto.nombre, b.producto.sku, m.created_at ? new Date(m.created_at).toLocaleString('es-MX') : '', m.doc_folio || m.documento_id || '',
            m.tipo_movimiento || '', m.lotes_inventario?.numero_lote || '', m.costo_unitario ?? '', m.stock_anterior_calc, m.cantidad, m.stock_resultante_calc]));
        filas.push([b.producto.nombre, b.producto.sku, `Saldo final al ${kdxUltimo.hasta}`, '', '', '', '', '', b.saldoFinal, '']);
    });
    const blob = new Blob(['\ufeff' + filas.map((r) => r.map(q).join(',')).join('\r\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `kardex_${kdxUltimo.desde}_a_${kdxUltimo.hasta}.csv`;
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}
