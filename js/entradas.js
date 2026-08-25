import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

let partidasEntradaDirecta = [];
let catalogoInsumosCache = [];
let catalogoUnidadesCache = [];

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
                        <input type="text" id="entradaDirectaFolio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" placeholder="Ej. ENT-DIR-001" required>
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
                                <th class="p-3 text-center">Acción</th>
                            </tr>
                        </thead>
                        <tbody id="tablaEDPartidasBody">
                            <tr><td colspan="6" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium p-3 rounded-lg transition shadow-md text-sm" style="cursor: pointer;">
                Registrar Entrada Directa al Inventario
            </button>
        `;
    }

    const inputFecha = document.getElementById('entradaDirectaFecha');
    if (inputFecha) inputFecha.value = new Date().toISOString().split('T')[0];

    await Promise.allSettled([
        cargarUnidadesMedidaSelectED(),
        configurarDatalistInsumosED()
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
                caducidad: caducidad || null
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

    formEntradasDirectas.onsubmit = async (e) => {
        e.preventDefault();

        if (partidasEntradaDirecta.length === 0) {
            alert("Debe agregar al menos una partida a la entrada directa.");
            return;
        }

        const fecha = document.getElementById('entradaDirectaFecha').value;
        const folio = document.getElementById('entradaDirectaFolio').value.trim();
        const motivo = document.getElementById('entradaDirectaMotivo').value;
        const notas = document.getElementById('entradaDirectaDescripcion').value.trim();
        const descripcion = `[${motivo}] ${notas}`.trim();

        if (!confirm(`¿Confirma el registro de esta Entrada Directa (${folio}) con ${partidasEntradaDirecta.length} partida(s)?`)) {
            return;
        }

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

            alert("¡Entrada directa registrada en inventario correctamente!");
            partidasEntradaDirecta = [];
            formEntradasDirectas.reset();

            if (inputFecha) inputFecha.value = new Date().toISOString().split('T')[0];
            renderizarTablaEDPartidas();

            if (typeof cargarInventarioCompleto === 'function') {
                await cargarInventarioCompleto();
            }

        } catch (error) {
            console.error("Error en Entrada Directa:", error);
            alert("Error al procesar la entrada directa: " + error.message);
        }
    };
}

function renderizarTablaEDPartidas() {
    const tbody = document.getElementById('tablaEDPartidasBody');
    if (!tbody) return;

    if (partidasEntradaDirecta.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>`;
        return;
    }

    tbody.innerHTML = partidasEntradaDirecta.map((item, index) => `
        <tr class="border-b border-slate-900 hover:bg-slate-900/50 transition">
            <td class="p-3 font-medium text-slate-100">${item.nombre}</td>
            <td class="p-3 text-slate-300">${item.cantidad}</td>
            <td class="p-3 text-slate-400 text-xs">${item.unidadNombre}</td>
            <td class="p-3 text-emerald-400 font-mono">$${item.costo.toFixed(2)}</td>
            <td class="p-3 font-mono text-xs text-emerald-300">${item.lote || 'SIN-LOTE'}</td>
            <td class="p-3 text-center">
                <button type="button" onclick="window.eliminarPartidaED(${index})" class="text-red-400 hover:text-red-300 font-bold px-2 py-1 rounded bg-red-950 border border-red-900 text-xs" style="cursor: pointer;">✕</button>
            </td>
        </tr>
    `).join('');
}

window.eliminarPartidaED = function(index) {
    partidasEntradaDirecta.splice(index, 1);
    renderizarTablaEDPartidas();
};

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
                .select('nombre, unidad_medida_id, costo_unitario');

            if (error) throw error;
            catalogoInsumosCache = data || [];
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