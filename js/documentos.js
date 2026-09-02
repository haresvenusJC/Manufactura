import { supabaseClient } from './supabase.js';
import { imprimirConPlantilla } from './impresion.js';

let documentosCache = [];
let docActualParaImprimir = null;

export async function cargarVistaDocumentos() {
    const contenedorPrincipal = document.getElementById('view-documentos');
    if (!contenedorPrincipal) return;
    
    contenedorPrincipal.innerHTML = `
        <div class="space-y-6 animate-in fade-in duration-300">
            <!-- Cabecera del Módulo -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <div>
                    <h2 class="text-xl font-bold text-slate-100 flex items-center gap-2">
                        <svg class="w-6 h-6 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                        Módulo Central de Documentos y Folios
                    </h2>
                    <p class="text-xs text-slate-400 mt-1">Control integral de la tabla maestra de documentos, consecutivos y trazabilidad de almacén.</p>
                </div>
                <div class="flex items-center gap-3 w-full sm:w-auto">
                    <button onclick="window.cargarListaDocumentos()" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2.5 rounded-xl text-xs font-semibold transition flex items-center gap-2 border border-slate-700" style="cursor: pointer;">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                        Sincronizar
                    </button>
                </div>
            </div>

            <!-- Filtros Avanzados -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 bg-slate-900 border border-slate-800 p-4 rounded-xl">
                <div>
                    <label class="block text-xs uppercase tracking-wider text-slate-400 mb-1 font-semibold">Buscar por Folio o ID:</label>
                    <input type="text" id="filtroBuscadorDoc" placeholder="Ej. FAC000069 o #15..." class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-slate-200 text-sm focus:outline-none focus:border-indigo-500">
                </div>
                <div>
                    <label class="block text-xs uppercase tracking-wider text-slate-400 mb-1 font-semibold">Filtrar por Tipo de Movimiento:</label>
                    <select id="filtroTipoDoc" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-slate-200 text-sm focus:outline-none focus:border-indigo-500">
                        <option value="">Cargando tipos...</option>
                    </select>
                </div>
                <div class="flex items-end">
                    <button onclick="window.filtrarDocumentosTabla()" class="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-semibold py-2 px-4 rounded-xl text-sm transition shadow-lg shadow-indigo-600/20" style="cursor: pointer;">
                        Aplicar Filtros
                    </button>
                </div>
            </div>

            <!-- Tabla Principal -->
            <div class="bg-slate-900 border border-slate-800 rounded-2xl shadow-xl overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-950 text-indigo-400 border-b border-slate-800 text-xs uppercase font-mono">
                            <tr>
                                <th class="p-4">ID / Consecutivo</th>
                                <th class="p-4">Folio Comercial</th>
                                <th class="p-4">Tipo Movimiento</th>
                                <th class="p-4">Fecha de Emisión</th>
                                <th class="p-4">Proveedor / Cliente</th>
                                <th class="p-4 text-center">Estado</th>
                                <th class="p-4 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaDocumentosCuerpo">
                            <tr>
                                <td colspan="7" class="p-8 text-center text-slate-500">Cargando registros de documentos...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    `;

    await window.cargarTiposMovimientoFiltro();
    await window.cargarListaDocumentos();
}

// Consulta exacta a la tabla tipos_movimiento utilizando codigo, nombre y naturaleza
window.cargarTiposMovimientoFiltro = async function() {
    try {
        const select = document.getElementById('filtroTipoDoc');
        if (!select) return;

        const { data: tipos, error } = await supabaseClient
            .from('tipos_movimiento')
            .select('codigo, nombre, naturaleza')
            .order('nombre', { ascending: true });

        if (error) throw error;

        let opcionesHtml = '<option value="">Todos los tipos</option>';
        (tipos || []).forEach(tipo => {
            const naturalezaLabel = tipo.naturaleza ? ` (${tipo.naturaleza})` : '';
            opcionesHtml += `<option value="${tipo.codigo}">${tipo.nombre}${naturalezaLabel}</option>`;
        });

        select.innerHTML = opcionesHtml;
    } catch (err) {
        console.error("Error al cargar tipos de movimiento en el filtro:", err);
        const select = document.getElementById('filtroTipoDoc');
        if (select) {
            select.innerHTML = '<option value="">Error al cargar tipos</option>';
        }
    }
};

window.cargarListaDocumentos = async function() {
    try {
        const { data: documentos, error } = await supabaseClient
            .from('documentos')
            .select(`
                id,
                tipo_movimiento,
                folio,
                fecha_emision,
                proveedor_cliente,
                cliente_nombre,
                estado,
                descripcion,
                created_at,
                proveedores ( id, nombre )
            `)
            .order('id', { ascending: false });

        if (error) throw error;
        documentosCache = documentos || [];
        window.renderizarTablaDocumentos(documentosCache);

    } catch (err) {
        console.error("Error al cargar documentos:", err);
        const cuerpo = document.getElementById('tablaDocumentosCuerpo');
        if (cuerpo) {
            cuerpo.innerHTML = `<tr><td colspan="7" class="p-8 text-center text-rose-400">Error al consultar la tabla 'documentos' en Supabase.</td></tr>`;
        }
    }
};

window.renderizarTablaDocumentos = function(lista) {
    const cuerpo = document.getElementById('tablaDocumentosCuerpo');
    if (!cuerpo) return;

    if (!lista || lista.length === 0) {
        cuerpo.innerHTML = `<tr><td colspan="7" class="p-8 text-center text-slate-500">No hay documentos registrados en el sistema.</td></tr>`;
        return;
    }

    let html = '';
    lista.forEach(doc => {
        const fecha = doc.fecha_emision ? new Date(doc.fecha_emision).toLocaleString() : 'N/D';
        const tercero = doc.proveedores?.nombre || doc.proveedor_cliente || doc.cliente_nombre || 'N/D';
        const estadoClase = doc.estado === 'completado' ? 'text-emerald-400 bg-emerald-950/40 border-emerald-900/50' : 'text-amber-400 bg-amber-950/40 border-amber-900/50';

        html += `
            <tr class="border-b border-slate-800/60 hover:bg-slate-800/30 transition">
                <td class="p-4 font-mono">
                    <span class="font-bold text-indigo-400">#${doc.id}</span>
                </td>
                <td class="p-4 font-mono font-semibold text-slate-200">
                    ${doc.folio || '<span class="text-slate-500 font-normal">S/Folio</span>'}
                </td>
                <td class="p-4 text-xs font-semibold uppercase text-slate-300">${doc.tipo_movimiento}</td>
                <td class="p-4 text-xs font-mono text-slate-400">${fecha}</td>
                <td class="p-4 text-xs text-slate-300 font-medium">${tercero}</td>
                <td class="p-4 text-center">
                    <span class="text-[10px] font-mono uppercase px-2.5 py-1 rounded-full border ${estadoClase}">${doc.estado || 'N/D'}</span>
                </td>
                <td class="p-4 text-right">
                    <button onclick="window.abrirDetalleDocumentoGlobal(${doc.id})" class="bg-indigo-600/20 hover:bg-indigo-600/40 text-indigo-300 border border-indigo-800/60 px-3 py-1.5 rounded-xl text-xs font-semibold transition inline-flex items-center gap-1.5" style="cursor: pointer;">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                        Ver Detalle
                    </button>
                </td>
            </tr>
        `;
    });

    cuerpo.innerHTML = html;
};

window.filtrarDocumentosTabla = function() {
    const texto = document.getElementById('filtroBuscadorDoc')?.value.toLowerCase().trim() || '';
    const tipo = document.getElementById('filtroTipoDoc')?.value || '';

    const filtrados = documentosCache.filter(doc => {
        const coincideTexto = String(doc.id).includes(texto) || (doc.folio && doc.folio.toLowerCase().includes(texto));
        const coincideTipo = tipo === '' || doc.tipo_movimiento === tipo;
        return coincideTexto && coincideTipo;
    });

    window.renderizarTablaDocumentos(filtrados);
};

// Modal de Expediente con formato imprimible
window.abrirDetalleDocumentoGlobal = async function(docId) {
    let modalContainer = document.getElementById('modalDetalleDocKardex');
    if (!modalContainer) {
        modalContainer = document.createElement('div');
        modalContainer.id = 'modalDetalleDocKardex';
        modalContainer.className = 'fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-sm p-4';
        document.body.appendChild(modalContainer);
    }

    modalContainer.innerHTML = `
        <div id="modalImprimibleArea" class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200 flex flex-col max-h-[90vh]">
            <!-- Cabecera del Modal (No se imprime) -->
            <div class="bg-slate-950 px-6 py-4 border-b border-slate-800 flex justify-between items-center no-print">
                <h3 class="text-sm font-bold text-slate-200 uppercase tracking-wider flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-indigo-500"></span>
                    Documento Oficial #${docId}
                </h3>
                <div class="flex items-center gap-2">
                    <button onclick="window.imprimirDocumentoActual()" class="bg-sky-600 hover:bg-sky-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold transition flex items-center gap-1.5 shadow-sm" style="cursor: pointer;">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path></svg>
                        Imprimir
                    </button>
                    <button onclick="window.cerrarDetalleDocumento()" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2">&times;</button>
                </div>
            </div>

            <!-- Cuerpo del Documento -->
            <div class="p-6 text-slate-300 text-sm overflow-y-auto space-y-6 flex-1 print:p-2 print:text-black print:bg-white" id="contenidoModalDoc">
                <div class="text-center py-8 text-slate-500">Consultando datos y partidas...</div>
            </div>

            <!-- Pie del Modal (No se imprime) -->
            <div class="bg-slate-950 px-6 py-3 border-t border-slate-800 flex justify-between items-center no-print">
                <span class="text-[11px] text-slate-500 font-mono">ID Consecutivo Global: ${docId}</span>
                <button onclick="window.cerrarDetalleDocumento()" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-xl text-xs font-semibold transition" style="cursor: pointer;">Cerrar</button>
            </div>
        </div>
    `;
    modalContainer.classList.remove('hidden');

    try {
        const { data: docInfo, error: errDoc } = await supabaseClient
            .from('documentos')
            .select(`*, proveedores ( nombre, contacto, telefono )`)
            .eq('id', docId)
            .single();

        if (errDoc) throw errDoc;

        let { data: detalles, error: errDetalles } = await supabaseClient
            .from('documento_detalles')
            .select(`
                id,
                cantidad,
                costo_unitario,
                subtotal,
                precio_venta,
                productos ( nombre, sku, tipo, descripcion, tasa_iva, unidades_medida ( nombre ) ),
                lotes_inventario ( numero_lote, fecha_ingreso, tipo_cambio, monedas ( codigo ) )
            `)
            .eq('documento_id', docId);

        if (errDetalles) {
            // columnas nuevas (precio_venta / tasa_iva) aún no existen: select básico
            ({ data: detalles, error: errDetalles } = await supabaseClient
                .from('documento_detalles')
                .select(`
                    id, cantidad, costo_unitario, subtotal,
                    productos ( nombre, sku, tipo, descripcion, unidades_medida ( nombre ) ),
                    lotes_inventario ( numero_lote, fecha_ingreso, tipo_cambio, monedas ( codigo ) )
                `)
                .eq('documento_id', docId));
        }

        if (errDetalles) throw errDetalles;

        const esVenta = (docInfo.tipo_movimiento === 'salida_venta');
        let ventaSubtotalCalc = 0, ventaIvaCalc = 0;

        const contenidoModal = document.getElementById('contenidoModalDoc');
        const fechaEmision = docInfo.fecha_emision ? new Date(docInfo.fecha_emision).toLocaleString() : 'N/D';
        const tercero = docInfo.proveedores?.nombre || docInfo.proveedor_cliente || docInfo.cliente_nombre || 'N/D';

        // Se guarda para que window.imprimirDocumentoActual sepa qué plantilla y título usar
        docActualParaImprimir = { tipoDocumento: docInfo.tipo_movimiento || 'generico', titulo: `Folio: ${docInfo.folio || 'S/Folio'} (Doc #${docId})` };

        let html = `
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-slate-950 p-4 rounded-xl border border-slate-800/80 print:bg-white print:border-black print:text-black">
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Tipo de Movimiento</span>
                    <span class="text-sm font-bold text-indigo-400 uppercase print:text-black">${docInfo.tipo_movimiento || 'N/D'}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Folio Asignado</span>
                    <span class="text-sm font-mono text-slate-200 font-bold print:text-black">${docInfo.folio || 'Sin Folio'}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Fecha de Emisión</span>
                    <span class="text-xs font-mono text-slate-300 print:text-black">${fechaEmision}</span>
                </div>
                <div>
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Estado Actual</span>
                    <span class="text-xs font-semibold text-emerald-400 uppercase print:text-black">${docInfo.estado || 'N/D'}</span>
                </div>
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">${esVenta ? 'Cliente' : 'Proveedor / Tercero / Cliente'}</span>
                    <span class="text-xs font-medium text-slate-200 print:text-black">${tercero}</span>
                    ${(docInfo.proveedores?.contacto || docInfo.proveedores?.telefono) ? `
                    <span class="text-[11px] text-slate-400 block print:text-gray-700">
                        ${docInfo.proveedores?.contacto ? `Contacto: ${docInfo.proveedores.contacto}` : ''}
                        ${docInfo.proveedores?.telefono ? ` · Tel: ${docInfo.proveedores.telefono}` : ''}
                    </span>` : ''}
                    ${esVenta && (docInfo.cliente_rfc || docInfo.condicion || docInfo.uuid_cfdi) ? `
                    <span class="text-[11px] text-slate-400 block print:text-gray-700 font-mono">
                        ${docInfo.cliente_rfc ? `RFC: ${docInfo.cliente_rfc}` : ''}
                        ${docInfo.condicion ? ` · ${String(docInfo.condicion).toUpperCase()}` : ''}
                        ${docInfo.uuid_cfdi ? `<span class="block">UUID: ${docInfo.uuid_cfdi}</span>` : ''}
                    </span>` : ''}
                </div>
                ${(!esVenta && (docInfo.moneda || docInfo.uso_cfdi || docInfo.metodo_pago || docInfo.rfc_emisor || docInfo.uuid_cfdi)) ? `
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Datos fiscales del CFDI</span>
                    <span class="text-[11px] text-slate-400 block print:text-gray-700 font-mono">
                        ${docInfo.rfc_emisor ? `RFC emisor: ${docInfo.rfc_emisor}` : ''}
                        ${docInfo.uso_cfdi ? ` · Uso: ${docInfo.uso_cfdi}` : ''}
                        ${docInfo.metodo_pago ? ` · ${docInfo.metodo_pago}` : ''}
                        ${(docInfo.moneda && docInfo.moneda !== 'MXN') ? ` · ${docInfo.moneda} @ TC ${Number(docInfo.tipo_cambio || 1)} (importes en MXN)` : ''}
                        ${docInfo.uuid_cfdi ? `<span class="block">UUID: ${docInfo.uuid_cfdi}</span>` : ''}
                    </span>
                </div>` : ''}
                ${docInfo.descripcion ? `
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Descripción / Observaciones</span>
                    <span class="text-xs text-slate-300 print:text-black">${docInfo.descripcion}</span>
                </div>` : ''}
                ${docInfo.notas ? `
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Notas</span>
                    <span class="text-xs text-slate-300 print:text-black">${docInfo.notas}</span>
                </div>` : ''}
                <div class="sm:col-span-2">
                    <span class="text-[10px] uppercase tracking-wider text-slate-500 block font-semibold print:text-gray-600">Documento / Registro</span>
                    <span class="text-[11px] font-mono text-slate-400 print:text-gray-700">ID #${docInfo.id} · Registrado: ${docInfo.created_at ? new Date(docInfo.created_at).toLocaleString() : 'N/D'}</span>
                </div>
            </div>

            <div>
                <h4 class="text-xs uppercase tracking-wider text-slate-400 font-bold mb-3 print:text-black">Partidas del Documento</h4>
                <div class="space-y-3">
        `;

        if (!detalles || detalles.length === 0) {
            html += `<div class="p-4 text-center text-slate-500 text-xs bg-slate-950 rounded-xl border border-slate-800 print:bg-white print:border-black print:text-black">No hay partidas registradas para este documento.</div>`;
        } else {
            detalles.forEach((det, index) => {
                const prod = det.productos || {};
                const lote = det.lotes_inventario || {};
                const loteNum = lote.numero_lote ? `Lote: ${lote.numero_lote}` : 'Lote: SIN-LOTE';
                const unidad = prod.unidades_medida?.nombre || '';
                const fechaIngresoLote = lote.fecha_ingreso ? new Date(lote.fecha_ingreso).toLocaleDateString() : null;
                const monedaCodigo = lote.monedas?.codigo;
                const tipoCambio = Number(lote.tipo_cambio || 1);

                // Cifras de venta (si es salida por venta y hay precio capturado)
                const pv = Number(det.precio_venta || 0);
                const importeVenta = Number(det.cantidad || 0) * pv;
                const tIva = (prod.tasa_iva === null || prod.tasa_iva === undefined || prod.tasa_iva === '') ? 0 : Number(prod.tasa_iva);
                if (esVenta) {
                    ventaSubtotalCalc += importeVenta;
                    ventaIvaCalc += importeVenta * tIva;
                }

                const filaImporte = esVenta
                    ? `<div class="flex justify-between items-center text-xs font-mono pt-1">
                            <span class="text-slate-400 print:text-gray-700">Precio unitario: <strong class="text-slate-200 print:text-black">$${pv.toFixed(2)}</strong>${pv <= 0 ? ` <span class="text-[10px] text-rose-400">(sin precio)</span>` : ''}</span>
                            <span class="text-slate-400 print:text-gray-700">Importe: <strong class="text-emerald-400 print:text-black">$${importeVenta.toFixed(2)}</strong></span>
                        </div>`
                    : `<div class="flex justify-between items-center text-xs font-mono pt-1 campo-costo">
                            <span class="text-slate-400 print:text-gray-700">Costo Unitario: <strong class="text-emerald-400 print:text-black">$${Number(det.costo_unitario || 0).toFixed(2)}${monedaCodigo ? ` ${monedaCodigo}` : ''}</strong>${(monedaCodigo && tipoCambio !== 1) ? ` <span class="text-[10px] text-slate-500">(TC: ${tipoCambio})</span>` : ''}</span>
                            <span class="text-slate-400 print:text-gray-700">Subtotal: <strong class="text-amber-300 print:text-black">$${Number(det.subtotal || 0).toFixed(2)}</strong></span>
                        </div>`;

                html += `
                    <div class="bg-slate-950 border border-slate-800 p-3.5 rounded-xl space-y-2 print:bg-white print:border-black print:text-black print:mb-2">
                        <div class="flex justify-between items-start border-b border-slate-800/60 pb-2 print:border-gray-400">
                            <div>
                                <span class="text-xs font-bold text-amber-400 block print:text-black">${index + 1}. ${prod.nombre || 'Producto Desconocido'}</span>
                                <span class="text-[10px] text-slate-500 font-mono print:text-gray-600">SKU: ${prod.sku || 'N/D'} <span class="campo-lote">| ${loteNum}</span></span>
                                ${prod.descripcion ? `<span class="text-[10px] text-slate-500 block print:text-gray-600">${prod.descripcion}</span>` : ''}
                                ${fechaIngresoLote ? `<span class="text-[10px] text-slate-500 block campo-lote print:text-gray-600">Ingreso de lote: ${fechaIngresoLote}</span>` : ''}
                            </div>
                            <div class="text-right font-mono">
                                <span class="text-sm font-bold text-slate-200 print:text-black">${det.cantidad} ${unidad}</span>
                                <span class="text-[10px] text-slate-500 block print:text-gray-600">Cantidad</span>
                            </div>
                        </div>
                        ${filaImporte}
                    </div>
                `;
            });
        }

        html += `</div>`;

        if (esVenta && detalles && detalles.length) {
            let subFinal = Number(docInfo.venta_subtotal || 0);
            if (!subFinal) subFinal = ventaSubtotalCalc;
            let ivaFinal = Number(docInfo.venta_iva || 0);
            if (!ivaFinal) ivaFinal = ventaIvaCalc;
            let totFinal = Number(docInfo.venta_total || 0);
            if (!totFinal) totFinal = subFinal + ivaFinal;

            html += `
                <div class="mt-4 ml-auto w-full sm:w-72 border-t-2 border-slate-700 pt-3 space-y-1.5 font-mono print:border-black print:text-black">
                    <div class="flex justify-between text-xs"><span class="text-slate-400 print:text-gray-700">Subtotal</span><strong class="text-slate-200 print:text-black">$${subFinal.toFixed(2)}</strong></div>
                    <div class="flex justify-between text-xs"><span class="text-slate-400 print:text-gray-700">IVA</span><strong class="text-slate-200 print:text-black">$${ivaFinal.toFixed(2)}</strong></div>
                    <div class="flex justify-between text-base border-t border-slate-700 pt-1.5 print:border-gray-400"><span class="font-bold text-slate-100 print:text-black">TOTAL</span><strong class="text-emerald-400 print:text-black">$${totFinal.toFixed(2)}</strong></div>
                </div>
            `;
        }

        html += `</div>`;
        contenidoModal.innerHTML = html;

    } catch (err) {
        console.error("Error al consultar el expediente completo:", err);
        document.getElementById('contenidoModalDoc').innerHTML = `<div class="text-rose-400 text-center py-6">Ocurrió un error al consultar los detalles en la base de datos.</div>`;
    }
};

window.imprimirDocumentoActual = function() {
    if (!docActualParaImprimir) {
        window.print();
        return;
    }
    imprimirConPlantilla(docActualParaImprimir.tipoDocumento, docActualParaImprimir.titulo, 'contenidoModalDoc');
};

window.cerrarDetalleDocumento = function() {
    const modalContainer = document.getElementById('modalDetalleDocKardex');
    if (modalContainer) {
        modalContainer.classList.add('hidden');
    }
};