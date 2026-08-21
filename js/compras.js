import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

let partidasCompra = [];

export function toggleTipoCambio(selectId, contenedorId, inputId) {
    const select = document.getElementById(selectId);
    const contenedor = document.getElementById(contenedorId);
    const input = document.getElementById(inputId);
    
    if (select && contenedor) {
        if (select.value === 'USD') {
            contenedor.classList.remove('hidden');
            if (input) input.required = true;
        } else {
            contenedor.classList.add('hidden');
            if (input) {
                input.required = false;
                input.value = '';
            }
        }
    }
}

export async function configurarFormularioCompras() {
    const formCompras = document.getElementById('formCompras');
    if (!formCompras) return;

    if (!document.getElementById('contenedorPartidasCompra')) {
        formCompras.innerHTML = `
            <div class="bg-gray-800 p-4 rounded-lg mb-4 border border-gray-700">
                <h3 class="text-md font-semibold text-white mb-3">1. Datos Generales de la Factura</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-1">Fecha de Compra</label>
                        <input type="date" id="compraFecha" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-1">Factura o Remisión</label>
                        <input type="text" id="compraFactura" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white" placeholder="Ej. FAC-001" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-1">Proveedor</label>
                        <select id="compraProveedorId" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white" required>
                            <option value="">Seleccione un proveedor...</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-3">
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-1">Moneda</label>
                        <select id="compraMoneda" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white">
                            <option value="MXN">MXN</option>
                            <option value="USD">USD</option>
                        </select>
                    </div>
                    <div id="contenedorTipoCambio" class="hidden">
                        <label class="block text-sm font-medium text-gray-300 mb-1">Tipo de Cambio (MXN por USD)</label>
                        <input type="number" step="0.01" id="compraTipoCambio" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white" placeholder="0.00">
                    </div>
                </div>
            </div>

            <div class="bg-gray-800 p-4 rounded-lg mb-4 border border-gray-700">
                <h3 class="text-md font-semibold text-white mb-3">2. Agregar Insumos a la Partida</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Nombre del Insumo</label>
                        <input type="text" id="inputItemNombre" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white" placeholder="Artículo o producto">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Unidad de Medida</label>
                        <select id="inputItemUnidad" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white">
                            <option value="">Seleccione unidad...</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Cantidad</label>
                        <input type="number" step="any" id="inputItemCantidad" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white" placeholder="0.00">
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-3 mb-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Costo Unitario</label>
                        <input type="number" step="any" id="inputItemCosto" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white" placeholder="0.00">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Número de Lote</label>
                        <input type="text" id="inputItemLote" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white" placeholder="Ej. LOT-01">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-gray-300 mb-1">Fecha de Caducidad</label>
                        <input type="date" id="inputItemCaducidad" class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-sm text-white">
                    </div>
                    <div class="flex items-end">
                        <button type="button" id="btnAgregarPartida" class="w-full bg-green-600 hover:bg-green-700 text-white font-medium p-2 rounded text-sm transition">
                            + Agregar Partida
                        </button>
                    </div>
                </div>
            </div>

            <div id="contenedorPartidasCompra" class="mb-4">
                <h3 class="text-md font-semibold text-white mb-2">3. Partidas en esta Compra</h3>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-gray-300 bg-gray-900 rounded border border-gray-700">
                        <thead class="bg-gray-800 text-xs uppercase text-gray-400">
                            <tr>
                                <th class="p-2">Insumo</th>
                                <th class="p-2">Cantidad</th>
                                <th class="p-2">Unidad</th>
                                <th class="p-2">Costo U.</th>
                                <th class="p-2">Lote</th>
                                <th class="p-2">Caducidad</th>
                                <th class="p-2 text-center">Acción</th>
                            </tr>
                        </thead>
                        <tbody id="tablaPartidasBody">
                            <tr><td colspan="7" class="p-3 text-center text-gray-500">No hay partidas agregadas todavía.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold p-3 rounded transition">
                Cerrar y Registrar Compra Completa, mi lord
            </button>
        `;
    }

    const inputFecha = document.getElementById('compraFecha');
    if (inputFecha) {
        inputFecha.value = new Date().toISOString().split('T')[0];
    }

    await cargarSelectProveedores();
    await cargarUnidadesMedidaSelect();
    await configurarDatalistInsumosUnificados();

    const selectMoneda = document.getElementById('compraMoneda');
    if (selectMoneda) {
        selectMoneda.addEventListener('change', () => {
            toggleTipoCambio('compraMoneda', 'contenedorTipoCambio', 'compraTipoCambio');
        });
    }

    const btnAgregar = document.getElementById('btnAgregarPartida');
    if (btnAgregar) {
        btnAgregar.onclick = () => {
            const nombre = document.getElementById('inputItemNombre').value.trim();
            const unidad = document.getElementById('inputItemUnidad').value;
            const cantidad = parseFloat(document.getElementById('inputItemCantidad').value) || 0;
            const costo = parseFloat(document.getElementById('inputItemCosto').value) || 0;
            const lote = document.getElementById('inputItemLote').value.trim();
            const caducidad = document.getElementById('inputItemCaducidad').value;

            if (!nombre || !unidad || cantidad <= 0) {
                alert("Por favor ingrese el nombre, seleccione una unidad de medida y una cantidad válida, mi lord.");
                return;
            }

            partidasCompra.push({
                nombre,
                unidad,
                cantidad,
                costo,
                lote,
                caducidad: caducidad || null
            });

            renderizarTablaPartidas();

            document.getElementById('inputItemNombre').value = '';
            document.getElementById('inputItemUnidad').value = '';
            document.getElementById('inputItemCantidad').value = '';
            document.getElementById('inputItemCosto').value = '';
            document.getElementById('inputItemLote').value = '';
            document.getElementById('inputItemCaducidad').value = '';
            document.getElementById('inputItemNombre').focus();
        };
    }

    formCompras.onsubmit = async (e) => {
        e.preventDefault();

        if (partidasCompra.length === 0) {
            alert("Debe agregar al menos una partida a la compra, mi lord.");
            return;
        }

        const fechaCompra = document.getElementById('compraFecha').value;
        const factura = document.getElementById('compraFactura').value.trim();
        const proveedorIdVal = document.getElementById('compraProveedorId').value;
        const proveedor_id = proveedorIdVal ? parseInt(proveedorIdVal) : null;
        const moneda = document.getElementById('compraMoneda').value;
        const tipoCambio = moneda === 'USD' ? parseFloat(document.getElementById('compraTipoCambio').value) || 1 : 1;

        if (!proveedor_id) {
            alert("Por favor seleccione un proveedor válido, mi lord.");
            return;
        }

        if (!confirm(`¿Desea cerrar y registrar esta compra con ${partidasCompra.length} partida(s) bajo la factura ${factura}, mi lord?`)) {
            return;
        }

        try {
            for (let item of partidasCompra) {
                let { data: existente, error: errBusq } = await supabaseClient
                    .from('productos')
                    .select('id, stock_actual')
                    .ilike('nombre', item.nombre)
                    .maybeSingle();

                if (errBusq) throw errBusq;

                let productoId;

                if (existente) {
                    productoId = existente.id;
                    const stockActualTotal = Number(existente.stock_actual || 0) + item.cantidad;

                    const { error: errUpd } = await supabaseClient
                        .from('productos')
                        .update({
                            stock_actual: stockActualTotal,
                            costo_unitario: item.costo,
                            unidad_medida: item.unidad,
                            moneda: moneda,
                            proveedor_id: proveedor_id
                        })
                        .eq('id', productoId);

                    if (errUpd) throw errUpd;
                } else {
                    const { data: nuevoProd, error: errIns } = await supabaseClient
                        .from('productos')
                        .insert([{
                            nombre: item.nombre,
                            tipo: 'materia_prima',
                            unidad_medida: item.unidad,
                            stock_actual: item.cantidad,
                            costo_unitario: item.costo,
                            moneda: moneda,
                            proveedor_id: proveedor_id
                        }])
                        .select('id')
                        .single();

                    if (errIns) throw errIns;
                    productoId = nuevoProd.id;
                }

                const datosLote = {
                    producto_id: productoId,
                    numero_lote: item.lote || 'SIN-LOTE',
                    stock_actual: item.cantidad,
                    costo_unitario: item.costo,
                    moneda: moneda,
                    tipo_cambio: tipoCambio,
                    fecha_ingreso: fechaCompra
                };

                const { error: errLote } = await supabaseClient
                    .from('lotes_inventario')
                    .insert([datosLote]);

                if (errLote) throw errLote;
            }

            alert("¡Compra y partidas registradas exitosamente, mi lord!");
            partidasCompra = [];
            formCompras.reset();
            
            if (inputFecha) {
                inputFecha.value = new Date().toISOString().split('T')[0];
            }
            
            renderizarTablaPartidas();
            toggleTipoCambio('compraMoneda', 'contenedorTipoCambio', 'compraTipoCambio');
            await cargarSelectProveedores();
            await cargarUnidadesMedidaSelect();
            await configurarDatalistInsumosUnificados();
            cargarInventarioCompleto();

        } catch (error) {
            console.error("Error al procesar la compra múltiple:", error);
            alert("Ocurrió un error al registrar la compra en la base de datos, mi lord.");
        }
    };
}

function renderizarTablaPartidas() {
    const tbody = document.getElementById('tablaPartidasBody');
    if (!tbody) return;

    if (partidasCompra.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" class="p-3 text-center text-gray-500">No hay partidas agregadas todavía.</td></tr>`;
        return;
    }

    tbody.innerHTML = partidasCompra.map((item, index) => `
        <tr class="border-b border-gray-800">
            <td class="p-2 font-medium text-white">${item.nombre}</td>
            <td class="p-2">${item.cantidad}</td>
            <td class="p-2">${item.unidad}</td>
            <td class="p-2">$${item.costo.toFixed(2)}</td>
            <td class="p-2">${item.lote || 'N/D'}</td>
            <td class="p-2">${item.caducidad || 'N/D'}</td>
            <td class="p-2 text-center">
                <button type="button" onclick="window.eliminarPartidaCompra(${index})" class="text-red-400 hover:text-red-300 font-bold px-2 py-1 rounded bg-red-900/30">X</button>
            </td>
        </tr>
    `).join('');
}

window.eliminarPartidaCompra = function(index) {
    partidasCompra.splice(index, 1);
    renderizarTablaPartidas();
};

async function cargarSelectProveedores() {
    const selectProveedor = document.getElementById('compraProveedorId');
    if (!selectProveedor) return;

    try {
        const { data, error } = await supabaseClient
            .from('proveedores')
            .select('id, nombre')
            .order('nombre', { ascending: true });

        if (error) throw error;

        let html = '<option value="">Seleccione un proveedor...</option>';
        if (data && data.length > 0) {
            data.forEach(p => {
                html += `<option value="${p.id}">${p.nombre}</option>`;
            });
        }
        selectProveedor.innerHTML = html;
    } catch (err) {
        console.warn("Aviso al cargar proveedores:", err);
    }
}

async function cargarUnidadesMedidaSelect() {
    const selectUnidad = document.getElementById('inputItemUnidad');
    if (!selectUnidad) return;

    try {
        const { data, error } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('id', { ascending: true });

        if (error) throw error;

        let html = '<option value="">Seleccione unidad...</option>';
        if (data && data.length > 0) {
            data.forEach(u => {
                const nombreUnidad = u.nombre || '';
                html += `<option value="${nombreUnidad}">${nombreUnidad}</option>`;
            });
        }
        selectUnidad.innerHTML = html;
    } catch (err) {
        console.warn("Aviso al cargar unidades de medida:", err);
    }
}

async function configurarDatalistInsumosUnificados() {
    const inputInsumo = document.getElementById('inputItemNombre');
    if (!inputInsumo) return;

    try {
        const { data: resProd, error } = await supabaseClient
            .from('productos')
            .select('nombre, unidad_medida, costo_unitario');

        if (error) throw error;

        let catalogoUnificado = resProd || [];
        let nombresUnicos = [...new Set(catalogoUnificado.map(i => i.nombre).filter(n => n && n.trim() !== ''))];
        nombresUnicos.sort((a, b) => a.localeCompare(b, 'es', { sensitivity: 'base' }));

        const actualizarDatosInsumo = () => {
            const valorSeleccionado = inputInsumo.value.trim();
            const encontrado = catalogoUnificado.find(i => i.nombre && i.nombre.toLowerCase() === valorSeleccionado.toLowerCase());
            
            if (encontrado) {
                const unidadSelect = document.getElementById('inputItemUnidad');
                if (unidadSelect && encontrado.unidad_medida) {
                    unidadSelect.value = encontrado.unidad_medida;
                }

                const costoInput = document.getElementById('inputItemCosto');
                if (costoInput && encontrado.costo_unitario !== undefined && encontrado.costo_unitario !== null) {
                    costoInput.value = encontrado.costo_unitario;
                }
            }
        };

        inputInsumo.addEventListener('input', actualizarDatosInsumo);
        inputInsumo.addEventListener('change', actualizarDatosInsumo);

        let datalist = document.getElementById('listaInsumosDatalist');
        if (!datalist) {
            datalist = document.createElement('datalist');
            datalist.id = 'listaInsumosDatalist';
            document.body.appendChild(datalist);
        }

        datalist.innerHTML = nombresUnicos.map(ins => `<option value="${ins}">`).join('');
        inputInsumo.setAttribute('list', 'listaInsumosDatalist');

    } catch (err) {
        console.warn("Aviso al cargar insumos unificados:", err);
    }
}