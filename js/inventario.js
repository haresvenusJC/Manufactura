import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';

const invResumenOrden = crearOrdenTabla();
const invLotesOrden = crearOrdenTabla();
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

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

// Cache del resumen (productos) para poder filtrar/paginar/colapsar en
// cliente sin volver a golpear Supabase en cada tecleo del buscador.
let invProductosCache = [];
let invFiltroTexto = '';
const porPaginaResumen = 10;
const invSeccionEstado = {
    terminados: { pagina: 1, colapsada: true },
    semiterminados: { pagina: 1, colapsada: true },
    materias: { pagina: 1, colapsada: true },
    componentes: { pagina: 1, colapsada: true },
};

export async function cargarInventarioCompleto() {
    const contenedorInv = document.getElementById('contenedorInventario');
    const contenedorLotes = document.getElementById('contenedorExistenciasLote');

    try {
        if (!supabaseClient) return;

        if (contenedorInv) {
            // Con es_semiterminado (migración 2026-10-18); si aún no está, sin esa columna.
            const colsInv = `
                    id, nombre, sku, tipo, costo_unitario, stock_actual, unidad_medida_id, moneda_id,
                    unidades_medida ( nombre ),
                    monedas ( codigo )
                `;
            let { data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select(colsInv.replace('tipo,', 'tipo, es_semiterminado,'))
                .order('id', { ascending: true });
            if (errProd) {
                ({ data: productos, error: errProd } = await supabaseClient
                    .from('productos')
                    .select(colsInv)
                    .order('id', { ascending: true }));
            }

            if (errProd) throw errProd;

            invProductosCache = productos || [];

            const inputBuscar = document.getElementById('invBuscador');
            if (inputBuscar) {
                inputBuscar.value = invFiltroTexto;
                inputBuscar.oninput = () => {
                    invFiltroTexto = inputBuscar.value;
                    Object.keys(invSeccionEstado).forEach(k => { invSeccionEstado[k].pagina = 1; });
                    renderInventarioResumen();
                };
            }

            renderInventarioResumen();
        }

        if (contenedorLotes) {
            await renderizarTablaLotes(contenedorLotes);
        }

    } catch (err) {
        console.error("Error al cargar inventario o lotes:", err);
    }
}

function renderInventarioResumen() {
    const contenedorInv = document.getElementById('contenedorInventario');
    if (!contenedorInv) return;

    const filtro = invFiltroTexto.trim().toLowerCase();
    const pasaFiltro = (p) => !filtro
        || (p.nombre || '').toLowerCase().includes(filtro)
        || (p.sku || '').toLowerCase().includes(filtro);

    const productosTerminados = invProductosCache.filter(p => p.tipo === 'producto' && !p.es_semiterminado && pasaFiltro(p));
    const semiterminados = invProductosCache.filter(p => p.tipo === 'producto' && p.es_semiterminado && pasaFiltro(p));
    const materiasPrimas = invProductosCache.filter(p => (p.tipo === 'materia_prima' || !p.tipo) && pasaFiltro(p));
    const componentes = invProductosCache.filter(p => (p.tipo === 'componente' || p.tipo === 'refaccion' || p.tipo === 'insumo') && pasaFiltro(p));

    // Renderizado de sección: colapsable y paginada de 10 en 10.
    const renderSeccion = (titulo, colorClass, lista, key) => {
        if (lista.length === 0) return '';
        aplicarOrden(invResumenOrden, lista, (item, campo) => {
            switch (campo) {
                case 'nombre': return (item.nombre || '').toLowerCase();
                case 'unidad': return (item.unidades_medida?.nombre || '').toLowerCase();
                case 'stock': return Number(item.stock_actual || 0);
                case 'costo': return Number(item.costo_unitario || 0);
                default: return item.id;
            }
        });

        const estado = invSeccionEstado[key];
        const totalPaginas = Math.ceil(lista.length / porPaginaResumen) || 1;
        if (estado.pagina > totalPaginas) estado.pagina = totalPaginas;
        const desde = (estado.pagina - 1) * porPaginaResumen;
        const pagina = lista.slice(desde, desde + porPaginaResumen);

        let sectionHtml = `
            <div class="mb-6">
                <button type="button" class="inv-sec-toggle w-full flex items-center justify-between gap-2 mb-2 cursor-pointer" data-seccion="${key}">
                    <h4 class="text-xs font-bold ${colorClass} uppercase tracking-wider">${titulo} <span class="text-slate-500 normal-case font-normal">(${lista.length})</span></h4>
                    <span class="text-slate-500 text-xs">${estado.colapsada ? '▸ mostrar' : '▾ ocultar'}</span>
                </button>
        `;
        if (!estado.colapsada) {
            sectionHtml += `
                <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-900 ${colorClass} border-b border-slate-800 text-xs uppercase">
                            <tr>
                                ${thOrden(invResumenOrden, 'nombre', 'Elemento / SKU')}
                                ${thOrden(invResumenOrden, 'unidad', 'Unidad')}
                                ${thOrden(invResumenOrden, 'stock', 'Stock Disponible')}
                                ${thOrden(invResumenOrden, 'costo', 'Costo Unitario')}
                            </tr>
                        </thead>
                        <tbody>
            `;
            pagina.forEach(item => {
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
            sectionHtml += `</tbody></table></div>`;

            if (totalPaginas > 1) {
                sectionHtml += `
                    <div class="flex items-center justify-between mt-2 px-1">
                        <span class="text-[11px] text-slate-500">Página ${estado.pagina} de ${totalPaginas}</span>
                        <div class="flex gap-1.5">
                            <button type="button" class="inv-sec-pag text-[11px] ${estado.pagina <= 1 ? 'opacity-40 pointer-events-none' : ''} bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-2.5 py-1 rounded" data-seccion="${key}" data-pagina="${estado.pagina - 1}">← Anterior</button>
                            <button type="button" class="inv-sec-pag text-[11px] ${estado.pagina >= totalPaginas ? 'opacity-40 pointer-events-none' : ''} bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-2.5 py-1 rounded" data-seccion="${key}" data-pagina="${estado.pagina + 1}">Siguiente →</button>
                        </div>
                    </div>
                `;
            }
        }
        sectionHtml += `</div>`;
        return sectionHtml;
    };

    let html = '';
    html += renderSeccion('📦 Productos Terminados', 'text-amber-400', productosTerminados, 'terminados');
    html += renderSeccion('🧴 Semiterminados (granel y similares)', 'text-indigo-400', semiterminados, 'semiterminados');
    html += renderSeccion('🧪 Materias Primas e Insumos', 'text-sky-400', materiasPrimas, 'materias');
    html += renderSeccion('⚙️ Componentes y Refacciones', 'text-emerald-400', componentes, 'componentes');

    contenedorInv.innerHTML = html || '<p class="text-sm text-slate-500">No se encontraron artículos con ese criterio.</p>';

    wireOrdenTabla(contenedorInv, invResumenOrden, () => renderInventarioResumen());
    contenedorInv.querySelectorAll('.inv-sec-toggle').forEach(btn => {
        btn.onclick = () => {
            const key = btn.dataset.seccion;
            invSeccionEstado[key].colapsada = !invSeccionEstado[key].colapsada;
            renderInventarioResumen();
        };
    });
    contenedorInv.querySelectorAll('.inv-sec-pag').forEach(btn => {
        btn.onclick = () => {
            const key = btn.dataset.seccion;
            invSeccionEstado[key].pagina = Number(btn.dataset.pagina);
            renderInventarioResumen();
        };
    });
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

    aplicarOrden(invLotesOrden, lotes || [], (l, campo) => {
        switch (campo) {
            case 'lote': return (l.numero_lote || '').toLowerCase();
            case 'producto': return (l.productos?.nombre || '').toLowerCase();
            case 'tipo': return (l.productos?.tipo || '').toLowerCase();
            case 'stock': return Number(l.stock_actual || 0);
            case 'costo': return Number(l.costo_unitario || 0);
            case 'ingreso': return l.fecha_ingreso ? new Date(l.fecha_ingreso).getTime() : 0;
            default: return l.id;
        }
    });

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
                            <th class="p-3 text-left">Acción</th>
                            ${thOrden(invLotesOrden, 'lote', 'Lote / Ref')}
                            ${thOrden(invLotesOrden, 'producto', 'Insumo / Producto')}
                            ${thOrden(invLotesOrden, 'tipo', 'Tipo')}
                            ${thOrden(invLotesOrden, 'stock', 'Stock Lote')}
                            ${thOrden(invLotesOrden, 'costo', 'Costo U.')}
                            ${thOrden(invLotesOrden, 'ingreso', 'Ingreso')}
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
                    <td class="p-3 whitespace-nowrap">
                        <button type="button" onclick="window.verDetalleLoteMovimiento(${l.id})" class="bg-slate-800 hover:bg-slate-700 text-indigo-300 text-xs px-2.5 py-1 rounded-lg border border-slate-700 transition font-medium">🔍 Documento</button>
                        <button type="button" onclick="window.registrarDeterioroLote(${l.id}, '${String(l.numero_lote || 'S/N').replace(/'/g, "\\'")}', ${Number(l.costo_unitario || 0)})" title="Castigar el costo del lote por caducidad, daño u obsolescencia (NIF C-4: costo o valor neto de realización, el menor)" class="bg-slate-800 hover:bg-slate-700 text-amber-300 text-xs px-2.5 py-1 rounded-lg border border-slate-700 transition font-medium ml-1">📉 Deterioro</button>
                    </td>
                    <td class="p-3 font-mono text-xs text-indigo-300">#${l.id} - ${l.numero_lote || 'S/N'}</td>
                    <td class="p-3 font-medium text-slate-100">${nombreProd}</td>
                    <td class="p-3 text-xs uppercase text-slate-400">${tipoProd}</td>
                    <td class="p-3 font-mono text-amber-300 font-semibold">${l.stock_actual}</td>
                    <td class="p-3 font-mono text-slate-300">$${Number(l.costo_unitario || 0).toFixed(2)}</td>
                    <td class="p-3 text-xs text-slate-400">${fechaIng}</td>
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
    wireOrdenTabla(contenedorLotes, invLotesOrden, () => renderizarTablaLotes(contenedorLotes));
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

// Deterioro de inventario (NIF C-4: costo o valor neto de realización, el
// menor) — castiga el costo unitario de un lote específico por caducidad,
// daño u obsolescencia. Solo permite bajar el costo, nunca subirlo.
// Requiere sql/2026-09-14b_deterioro_inventario.sql.
window.registrarDeterioroLote = async function(loteId, numeroLote, costoActual) {
    const costoStr = prompt(
        `Lote ${numeroLote} — costo unitario actual: $${Number(costoActual).toFixed(4)}\n\n` +
        `¿Cuál es el nuevo costo unitario (valor neto de realización)? Debe ser MENOR al actual.`,
        ''
    );
    if (costoStr === null) return;
    const costoNuevo = parseFloat(costoStr);
    if (!Number.isFinite(costoNuevo) || costoNuevo < 0) { alert('Costo inválido.'); return; }
    if (costoNuevo >= Number(costoActual)) { alert('El nuevo costo debe ser menor al costo actual — esto solo registra deterioro (castigo hacia abajo), no una revaluación.'); return; }

    const motivo = prompt('Motivo del deterioro (caducidad, daño, obsolescencia, etc.):', '');
    if (motivo === null || !motivo.trim()) { alert('El motivo es obligatorio.'); return; }

    try {
        const { data, error } = await supabaseClient.rpc('registrar_deterioro_inventario', {
            p_lote_id: loteId, p_costo_nuevo: costoNuevo, p_motivo: motivo.trim(),
        });
        if (error) throw error;
        alert(`Deterioro registrado — castigo de ${money(data.monto_castigo)} (póliza #${data.poliza_id}). Nuevo costo del lote: $${Number(data.costo_nuevo).toFixed(4)}.`);
        await renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
    } catch (err) {
        const m = err?.message || String(err);
        if (/does not exist|schema cache|could not find/i.test(m)) {
            alert('Falta correr sql/2026-09-14b_deterioro_inventario.sql en Supabase.');
        } else {
            alert('No se pudo registrar el deterioro: ' + m);
        }
    }
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