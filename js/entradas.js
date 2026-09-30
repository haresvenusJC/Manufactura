import { supabaseClient } from './supabase.js';
import { siguienteFolio, proximoFolio } from './folios.js';
import { cargarInventarioCompleto } from './inventario.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { linkDoc, linkPoliza } from './enlaces-reporte.js';

let partidasEntradaDirecta = [];
let catalogoInsumosCache = [];
let catalogoUnidadesCache = [];
let cuentasContablesCache = []; // {id, codigo, nombre} afectables/activas, cargadas una vez en cargarBloqueContableED
const histEntradasOrden = crearOrdenTabla('fecha', 'desc');
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Sugerencia de contrapartida por "Motivo de Entrada" (criterio contable,
// no un candado: se puede cambiar). Sin entrada aquí = sin sugerencia
// automática, requiere criterio del usuario (Devolución de Producción,
// Otro, o sin motivo elegido todavía).
const SUGERENCIA_ABONO_ED = {
    'Inventario Inicial': { codigo: '304.01', texto: 'Es un saldo de arranque: no es una venta del periodo ni una aportación de socios nueva — afecta Resultado de ejercicios anteriores, no el resultado del periodo actual ni Capital social.' },
    'Ajuste de Inventario (+)': { codigo: '403.01', texto: 'Sobrante sin causa conocida: entra como Otros ingresos. Si en realidad corrige una merma que ya registraste como gasto, abona esa MISMA cuenta de gasto en vez de esta — no crees un ingreso nuevo por algo que ya se había registrado.' },
    'Sobrante de Calibración': { codigo: '403.01', texto: 'Mismo criterio que un ajuste de inventario: sobrante sin causa conocida entra como Otros ingresos.' },
};

export async function configurarFormularioEntradasDirectas() {
    const formEntradasDirectas = document.getElementById('formEntradasDirectas');
    if (!formEntradasDirectas) return;

    if (!document.getElementById('contenedorPartidasEntradaDirecta')) {
        formEntradasDirectas.innerHTML = `
            <div class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800 shadow-xl">
                <h3 class="text-md font-semibold text-slate-200 mb-3">1. Datos de la Entrada Directa</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Fecha de Entrada</label>
                        <input type="date" id="entradaDirectaFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Folio / Documento Interno</label>
                        <input type="text" id="entradaDirectaFolio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" placeholder="Automático">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Motivo de Entrada</label>
                        <select id="entradaDirectaMotivo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            <option value="">Seleccione un motivo...</option>
                            <option value="Ajuste de Inventario (+)">Ajuste de Inventario (+)</option>
                            <option value="Devolución de Producción">Devolución de Producción</option>
                            <option value="Sobrante de Calibración">Sobrante de Calibración</option>
                            <option value="Inventario Inicial">Inventario Inicial</option>
                            <option value="Otro">Otro</option>
                        </select>
                    </div>
                </div>
                <div class="mt-3">
                    <label class="block text-xs font-medium text-slate-400 mb-1">Notas u Observaciones</label>
                    <textarea id="entradaDirectaDescripcion" rows="2" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="Detalle la razón del ajuste..."></textarea>
                </div>
            </div>

            <div class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800">
                <h3 class="text-md font-semibold text-slate-200 mb-3">2. Insumos o Productos a Ingresar</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Insumo / Producto</label>
                        <input type="text" id="inputEDNombre" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="Nombre o código de barras">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Unidad de Medida</label>
                        <select id="inputEDUnidadId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">Seleccione unidad...</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Cantidad</label>
                        <input type="number" step="any" id="inputEDCantidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="0.00">
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-3 mb-3">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Costo Estimado/Unitario</label>
                        <input type="number" step="any" id="inputEDCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="0.00">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Número de Lote</label>
                        <input type="text" id="inputEDLote" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" placeholder="Ej. LOTE-AJUSTE">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Fecha de Caducidad (opcional)</label>
                        <input type="date" id="inputEDCaducidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                    <div class="flex items-end">
                        <button type="button" id="btnAgregarPartidaED" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium p-2.5 rounded-lg text-xs transition shadow-md" style="cursor: pointer;">
                            ＋ Agregar Partida
                        </button>
                    </div>
                </div>
            </div>

            <div id="contenedorPartidasEntradaDirecta" class="mb-4 space-y-2">
                <h3 class="text-md font-semibold text-slate-200 mb-2">3. Partidas en esta Entrada Directa</h3>
                <div class="overflow-x-auto border border-slate-800 rounded-xl">
                    <table class="w-full text-left text-sm text-slate-300 bg-slate-950">
                        <thead class="bg-slate-900 text-xs uppercase text-emerald-400 border-b border-slate-800">
                            <tr>
                                <th class="p-3">Insumo</th>
                                <th class="p-3">Cantidad</th>
                                <th class="p-3">Unidad</th>
                                <th class="p-3">Costo U.</th>
                                <th class="p-3">Lote</th>
                                <th class="p-3">Se carga a</th>
                                <th class="p-3 text-center">Acción</th>
                            </tr>
                        </thead>
                        <tbody id="tablaEDPartidasBody">
                            <tr><td colspan="7" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="edBloqueContable" class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800 hidden">
                <label class="flex items-center gap-2 text-sm font-semibold text-slate-200 mb-2">
                    <input type="checkbox" id="edContabilizar" checked class="accent-emerald-500"> 4. Generar póliza contable
                </label>
                <div id="edCamposContables">
                    <label class="block text-xs text-slate-400 mb-1">Cuenta de contrapartida (abono)</label>
                    <select id="edCuentaAbono" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                    <p id="edCuentaAbonoHint" class="text-[11px] text-slate-500 mt-1">Ej. 205.01 Acreedores, o una cuenta de ajuste / capital. El inventario se carga a la cuenta contable de cada producto — por eso esa(s) cuenta(s) no aparecen aquí como opción (cargo y abono a la misma cuenta se neutralizarían).</p>
                </div>
            </div>

            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium p-3 rounded-lg transition shadow-md text-sm" style="cursor: pointer;">
                Registrar Entrada Directa al Inventario
            </button>

            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl mt-4">
                <h3 class="text-md font-semibold text-emerald-400 flex items-center gap-2 mb-3">📋 Historial de Entradas Directas Registradas</h3>
                <div id="contenedorHistorialEntradas">
                    <p class="text-slate-400 text-sm">Cargando historial...</p>
                </div>
            </div>
        `;
    }

    const inputFecha = document.getElementById('entradaDirectaFecha');
    if (inputFecha) inputFecha.value = new Date().toISOString().split('T')[0];

    await Promise.allSettled([
        cargarUnidadesMedidaSelectED(),
        configurarDatalistInsumosED(),
        cargarBloqueContableED(),
        cargarHistorialEntradas()
    ]);

    const oldBtn = document.getElementById('btnAgregarPartidaED');
    if (oldBtn) {
        const btnAgregar = oldBtn.cloneNode(true);
        oldBtn.parentNode.replaceChild(btnAgregar, oldBtn);

        let procesando = false;
        btnAgregar.addEventListener('click', () => {
            if (procesando) return;
            procesando = true;

            const nombre = document.getElementById('inputEDNombre').value.trim();
            const unidadIdVal = document.getElementById('inputEDUnidadId').value;
            const unidad_medida_id = unidadIdVal ? parseInt(unidadIdVal) : null;
            const cantidad = parseFloat(document.getElementById('inputEDCantidad').value) || 0;
            const costo = parseFloat(document.getElementById('inputEDCosto').value) || 0;
            const lote = document.getElementById('inputEDLote').value.trim();
            const caducidad = document.getElementById('inputEDCaducidad').value;

            const uMatch = catalogoUnidadesCache.find(u => u.id === unidad_medida_id);
            const unidadNombre = uMatch ? uMatch.nombre : `ID: ${unidad_medida_id}`;

            if (!nombre || !unidad_medida_id || cantidad <= 0) {
                alert("Ingrese el nombre, la unidad de medida y una cantidad mayor a 0.");
                procesando = false;
                return;
            }

            partidasEntradaDirecta.push({
                nombre,
                unidad_medida_id,
                unidadNombre,
                cantidad,
                costo,
                lote: lote || null,
                caducidad: caducidad || null,
                cuentaCargo: resolverCuentaCargoED(nombre)   // {id, codigo, nombre} o null (sin módulo contable / sin catálogo cargado)
            });

            renderizarTablaEDPartidas();

            document.getElementById('inputEDNombre').value = '';
            document.getElementById('inputEDUnidadId').value = '';
            document.getElementById('inputEDCantidad').value = '';
            document.getElementById('inputEDCosto').value = '';
            document.getElementById('inputEDLote').value = '';
            document.getElementById('inputEDCaducidad').value = '';
            document.getElementById('inputEDNombre').focus();

            setTimeout(() => { procesando = false; }, 300);
        });
    }

    // Sugerencia: muestra en el campo cuál será el folio automático (no lo consume).
    const mostrarProximoFolioEntrada = async () => {
        const f = await proximoFolio('ENT');
        const inp = document.getElementById('entradaDirectaFolio');
        if (f && inp) inp.placeholder = `Automático: ${f} (o escribe el tuyo)`;
    };
    mostrarProximoFolioEntrada();

    formEntradasDirectas.onsubmit = async (e) => {
        e.preventDefault();

        if (partidasEntradaDirecta.length === 0) {
            alert("Debe agregar al menos una partida a la entrada directa.");
            return;
        }

        const fecha = document.getElementById('entradaDirectaFecha').value;
        const folioCapturado = document.getElementById('entradaDirectaFolio').value.trim();
        const motivo = document.getElementById('entradaDirectaMotivo').value;
        const notas = document.getElementById('entradaDirectaDescripcion').value.trim();
        const descripcion = `[${motivo}] ${notas}`.trim();

        if (!confirm(`¿Confirma el registro de esta Entrada Directa (${folioCapturado || 'folio automático'}) con ${partidasEntradaDirecta.length} partida(s)?`)) {
            return;
        }

        // Folio vacío: se asigna el siguiente consecutivo (ENT-000001...) hasta confirmar, para no dejar huecos.
        const folio = folioCapturado || await siguienteFolio('ENT');

        try {
            // 1. Crear el documento general de la entrada
            const { data: nuevoDoc, error: errDoc } = await supabaseClient
                .from('documentos')
                .insert([{
                    tipo_movimiento: 'entrada',
                    folio: folio,
                    fecha_emision: fecha,
                    descripcion: descripcion,
                    estado: 'completado'
                }])
                .select('id')
                .single();

            if (errDoc) throw errDoc;
            const documentoId = nuevoDoc.id;

            // 2. Procesar cada partida usando el RPC nativo de Supabase
            for (let item of partidasEntradaDirecta) {
                let { data: existente, error: errBusq } = await supabaseClient
                    .from('productos')
                    .select('id')
                    .ilike('nombre', item.nombre)
                    .maybeSingle();

                if (errBusq) throw errBusq;
                let productoId;

                if (existente) {
                    productoId = existente.id;
                    if (item.costo > 0) {
                        await supabaseClient
                            .from('productos')
                            .update({ costo_unitario: item.costo })
                            .eq('id', productoId);
                    }
                } else {
                    const { data: nuevoProd, error: errIns } = await supabaseClient
                        .from('productos')
                        .insert([{
                            nombre: item.nombre,
                            tipo: 'materia_prima',
                            unidad_medida_id: item.unidad_medida_id,
                            stock_actual: 0,
                            costo_unitario: item.costo
                        }])
                        .select('id')
                        .single();

                    if (errIns) throw errIns;
                    productoId = nuevoProd.id;
                }

                // Inserción en detalles del documento
                const subtotal = item.cantidad * item.costo;
                const { error: errDetalle } = await supabaseClient
                    .from('documento_detalles')
                    .insert([{
                        documento_id: documentoId,
                        producto_id: productoId,
                        cantidad: item.cantidad,
                        costo_unitario: item.costo,
                        subtotal: subtotal
                    }]);

                if (errDetalle) throw errDetalle;

                // LLAMADA DIRECTA AL RPC DE LA BASE DE DATOS (Maneja lotes y existencias automáticamente)
                const { error: errRpc } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
                    p_producto_id: productoId,
                    p_cantidad: item.cantidad,
                    p_tipo_movimiento: 'entrada',
                    p_documento_id: documentoId,
                    p_costo_unitario: item.costo,
                    p_numero_lote: item.lote || 'LOTE-DIRECTO'
                });

                if (errRpc) throw errRpc;
            }

            // Contabilizar (póliza de entrada) si el bloque está activo
            let msgContab = '';
            const edChk = document.getElementById('edContabilizar');
            const edVis = document.getElementById('edBloqueContable') && !document.getElementById('edBloqueContable').classList.contains('hidden');
            if (edVis && edChk && edChk.checked) {
                const ctaAbono = document.getElementById('edCuentaAbono').value;
                if (!ctaAbono) {
                    msgContab = '\nNo se contabilizó: falta elegir la cuenta de contrapartida.';
                } else {
                    try {
                        const { data: cc, error: eCC } = await supabaseClient.rpc('contabilizar_entrada_directa', {
                            p_documento_id: documentoId, p_datos: { cuenta_abono_id: parseInt(ctaAbono) }
                        });
                        if (eCC) throw eCC;
                        msgContab = `\nPóliza de entrada generada (total $${Number(cc.total).toFixed(2)}).`;
                    } catch (e) {
                        msgContab = `\nEntrada OK, pero NO se contabilizó: ${e.message || e}`;
                    }
                }
            }

            alert("¡Entrada directa registrada en inventario correctamente!" + msgContab);
            partidasEntradaDirecta = [];
            formEntradasDirectas.reset();
            mostrarProximoFolioEntrada();   // el siguiente folio sugerido

            if (inputFecha) inputFecha.value = new Date().toISOString().split('T')[0];
            renderizarTablaEDPartidas();

            if (typeof cargarInventarioCompleto === 'function') {
                await cargarInventarioCompleto();
            }
            await cargarHistorialEntradas();

        } catch (error) {
            console.error("Error en Entrada Directa:", error);
            alert("Error al procesar la entrada directa: " + error.message);
        }
    };
}

async function cargarHistorialEntradas() {
    const cont = document.getElementById('contenedorHistorialEntradas');
    if (!cont) return;
    try {
        const { data: documentos, error } = await supabaseClient
            .from('documentos')
            .select(`id, folio, fecha_emision, descripcion, poliza_id,
                     documento_detalles ( cantidad, costo_unitario, subtotal, productos ( nombre ), lotes_inventario ( numero_lote ) )`)
            .eq('tipo_movimiento', 'entrada')
            .order('fecha_emision', { ascending: false })
            .limit(25);
        if (error) throw error;

        if (!documentos || documentos.length === 0) {
            cont.innerHTML = `<p class="text-slate-400 text-sm">No hay entradas directas registradas recientemente.</p>`;
            return;
        }

        aplicarOrden(histEntradasOrden, documentos, (doc, campo) => {
            switch (campo) {
                case 'folio': return (doc.folio || '').toLowerCase();
                case 'fecha': return doc.fecha_emision || '';
                case 'descripcion': return (doc.descripcion || '').toLowerCase();
                default: return doc.id;
            }
        });

        let html = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900 text-emerald-400 text-xs uppercase border-b border-slate-800">
                        <tr>
                            ${thOrden(histEntradasOrden, 'folio', 'Folio')}
                            ${thOrden(histEntradasOrden, 'fecha', 'Fecha')}
                            ${thOrden(histEntradasOrden, 'descripcion', 'Descripción')}
                            <th class="p-3">Partidas / Lotes</th>
                            <th class="p-3">Póliza</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        documentos.forEach((doc) => {
            let descDetalles = '';
            if (doc.documento_detalles && doc.documento_detalles.length > 0) {
                descDetalles = doc.documento_detalles.map((d) =>
                    `<span class="block text-xs font-mono text-slate-300">• ${d.productos?.nombre || 'Prod'} (<b class="text-amber-300">Lote: ${d.lotes_inventario?.numero_lote || 'SIN-LOTE'}</b>): <b class="text-emerald-300">${d.cantidad} un.</b></span>`
                ).join('');
            }
            const polCell = doc.poliza_id
                ? `<button type="button" onclick="window.verPolizaDeDocumento(${doc.poliza_id}, '${doc.fecha_emision || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${doc.poliza_id}</button>`
                : `<span class="text-[11px] text-slate-600">— sin póliza —</span>`;

            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                    <td class="p-3">${linkDoc(doc.id, doc.folio || 'Sin Folio', 'font-mono text-xs text-emerald-400 font-bold')}</td>
                    <td class="p-3 text-xs text-slate-400">${doc.fecha_emision ? new Date(doc.fecha_emision).toLocaleDateString() : ''}</td>
                    <td class="p-3 text-xs text-slate-200">${doc.descripcion || 'N/D'}</td>
                    <td class="p-3">${descDetalles}</td>
                    <td class="p-3">${polCell}</td>
                </tr>`;
        });

        html += `</tbody></table></div>`;
        cont.innerHTML = html;
        wireOrdenTabla(cont, histEntradasOrden, cargarHistorialEntradas);
    } catch (err) {
        console.error("Error al cargar historial de entradas:", err);
        cont.innerHTML = `<p class="text-red-400 text-sm">Error al cargar historial de entradas.</p>`;
    }
}

function renderizarTablaEDPartidas() {
    const tbody = document.getElementById('tablaEDPartidasBody');
    if (!tbody) return;

    if (partidasEntradaDirecta.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>`;
    } else {
        tbody.innerHTML = partidasEntradaDirecta.map((item, index) => `
            <tr class="border-b border-slate-900 hover:bg-slate-900/50 transition">
                <td class="p-3 font-medium text-slate-100">${esc(item.nombre)}</td>
                <td class="p-3 text-slate-300">${item.cantidad}</td>
                <td class="p-3 text-slate-400 text-xs">${esc(item.unidadNombre)}</td>
                <td class="p-3 text-emerald-400 font-mono">$${item.costo.toFixed(2)}</td>
                <td class="p-3 font-mono text-xs text-emerald-300">${esc(item.lote || 'SIN-LOTE')}</td>
                <td class="p-3 text-xs text-sky-300">${item.cuentaCargo ? esc(item.cuentaCargo.codigo + ' · ' + item.cuentaCargo.nombre) : '<span class="text-slate-600">—</span>'}</td>
                <td class="p-3 text-center">
                    <button type="button" onclick="window.eliminarPartidaED(${index})" class="text-red-400 hover:text-red-300 font-bold px-2 py-1 rounded bg-red-950 border border-red-900 text-xs" style="cursor: pointer;">✕</button>
                </td>
            </tr>
        `).join('');
    }
    renderSelectAbonoED();   // las cuentas de cargo pudieron cambiar (partida agregada/quitada)
}

window.eliminarPartidaED = function(index) {
    partidasEntradaDirecta.splice(index, 1);
    renderizarTablaEDPartidas();
};

// Misma cuenta que usaría contabilizar_entrada_directa -> _inv_por_cuenta:
// la propia del producto si ya existe en el catálogo, si no el default por
// tipo (producto -> 115.04, semiterminado -> 115.02, el resto -> 115.01).
// Si el nombre no coincide con ningún producto existente, se creará nuevo
// como 'materia_prima' al guardar (ver el submit más abajo) -> 115.01.
function resolverCuentaCargoED(nombre) {
    if (!cuentasContablesCache.length) return null; // sin módulo contable instalado
    const enc = catalogoInsumosCache.find(i => i.nombre && i.nombre.toLowerCase() === String(nombre).toLowerCase());
    const tipo = enc?.tipo || 'materia_prima';
    const codigoDefault = tipo === 'producto' ? '115.04' : tipo === 'semiterminado' ? '115.02' : '115.01';
    const ctaId = enc?.cuenta_inventario_id || cuentasContablesCache.find(c => c.codigo === codigoDefault)?.id;
    return cuentasContablesCache.find(c => c.id === ctaId) || null;
}

async function cargarUnidadesMedidaSelectED() {
    const selectUnidad = document.getElementById('inputEDUnidadId');
    if (!selectUnidad) return;

    try {
        const { data, error } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('id', { ascending: true });

        if (error) throw error;

        catalogoUnidadesCache = data || [];

        let html = '<option value="">Seleccione unidad...</option>';
        if (catalogoUnidadesCache.length > 0) {
            catalogoUnidadesCache.forEach(u => { html += `<option value="${u.id}">${u.nombre}</option>`; });
        }
        selectUnidad.innerHTML = html;
    } catch (err) {
        console.warn("Aviso al cargar unidades:", err);
    }
}

async function configurarDatalistInsumosED() {
    const inputInsumo = document.getElementById('inputEDNombre');
    if (!inputInsumo) return;

    let datalist = document.getElementById('listaInsumosDatalistED');
    if (!datalist) {
        datalist = document.createElement('datalist');
        datalist.id = 'listaInsumosDatalistED';
        document.body.appendChild(datalist);
    }
    inputInsumo.setAttribute('list', 'listaInsumosDatalistED');

    const refrescarCatalogo = async () => {
        try {
            const { data, error } = await supabaseClient
                .from('productos')
                .select('nombre, unidad_medida_id, costo_unitario, tipo, cuenta_inventario_id');

            if (error) throw error;
            catalogoInsumosCache = data || [];
            renderizarTablaEDPartidas(); // ya se puede resolver "Se carga a" de las partidas que ya estaban agregadas
            let nombres = [...new Set(catalogoInsumosCache.map(i => i.nombre).filter(n => n && n.trim() !== ''))];
            nombres.sort((a, b) => a.localeCompare(b, 'es', { sensitivity: 'base' }));

            datalist.innerHTML = nombres.map(ins => `<option value="${ins}">`).join('');
        } catch (err) {
            console.warn("Aviso al refrescar datalist:", err);
        }
    };

    inputInsumo.addEventListener('focus', refrescarCatalogo);
    inputInsumo.addEventListener('change', () => {
        const val = inputInsumo.value.trim();
        const enc = catalogoInsumosCache.find(i => i.nombre && i.nombre.toLowerCase() === val.toLowerCase());
        if (enc) {
            const unit = document.getElementById('inputEDUnidadId');
            if (unit && enc.unidad_medida_id) unit.value = enc.unidad_medida_id;
            const cost = document.getElementById('inputEDCosto');
            if (cost && enc.costo_unitario !== undefined) cost.value = enc.costo_unitario;
        }
    });

    await refrescarCatalogo();
}

// Bloque de contabilidad: se muestra solo si el modulo contable esta instalado.
async function cargarBloqueContableED() {
    const bloque = document.getElementById('edBloqueContable');
    if (!bloque) return;
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('id, codigo, nombre')
            .eq('afectable', true).eq('activa', true)
            .order('codigo', { ascending: true });
        if (error) throw error;
        cuentasContablesCache = data || [];
    } catch (_) {
        return; // modulo de contabilidad no instalado
    }
    bloque.classList.remove('hidden');
    renderSelectAbonoED();
    document.getElementById('edContabilizar').onchange = (e) => {
        document.getElementById('edCamposContables').style.display = e.target.checked ? '' : 'none';
    };
    document.getElementById('entradaDirectaMotivo').addEventListener('change', () => renderSelectAbonoED({ sugerirPorMotivo: true }));
}

// Llena el select de contrapartida SIN las cuentas de inventario que las
// partidas actuales ya van a cargar (evita el neteo: cargo y abono a la
// misma cuenta), y sugiere una cuenta según el "Motivo de Entrada" elegido
// (ver SUGERENCIA_ABONO_ED) — es una sugerencia, no un candado, se puede
// cambiar libremente.
function renderSelectAbonoED(opts = {}) {
    const sel = document.getElementById('edCuentaAbono');
    const hint = document.getElementById('edCuentaAbonoHint');
    if (!sel) return;

    const excluir = new Set(partidasEntradaDirecta.filter(p => p.cuentaCargo).map(p => p.cuentaCargo.id));
    const disponibles = cuentasContablesCache.filter(c => !excluir.has(c.id));
    const valorPrevio = sel.value;

    sel.innerHTML = '<option value="">— cuenta —</option>' +
        disponibles.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    const motivo = document.getElementById('entradaDirectaMotivo')?.value || '';
    const sugerencia = SUGERENCIA_ABONO_ED[motivo];
    const ctaSugerida = sugerencia && disponibles.find(c => c.codigo === sugerencia.codigo);

    if (opts.sugerirPorMotivo && ctaSugerida) {
        sel.value = String(ctaSugerida.id);
    } else if (valorPrevio && disponibles.some(c => String(c.id) === valorPrevio)) {
        sel.value = valorPrevio; // conserva lo ya elegido si sigue siendo válido
    } else if (!motivo) {
        const def = disponibles.find(c => c.codigo === '205.01');
        if (def) sel.value = String(def.id);
    }

    if (hint) {
        hint.textContent = sugerencia
            ? sugerencia.texto
            : motivo === 'Devolución de Producción'
                ? 'Sin sugerencia automática: abona la MISMA cuenta que se cargó al cerrar esa orden de producción (normalmente 115.04) — revisa el costeo de esa orden antes de elegir, no inventes una cuenta distinta.'
                : motivo === 'Otro'
                    ? 'Sin sugerencia automática para "Otro": explica en Notas qué pasó de verdad antes de elegir la cuenta.'
                    : 'Ej. 205.01 Acreedores, o una cuenta de ajuste / capital. Las cuentas de inventario que ya se van a cargar no aparecen aquí (cargo y abono a la misma cuenta se neutralizarían).';
    }
}