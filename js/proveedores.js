import { supabaseClient } from './supabase.js';

export async function cargarModuloProveedores() {
    const contenedor = document.getElementById('contenedorProveedores');
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Formulario de Altas y Modificaciones de Proveedores -->
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-4">
                <div class="flex justify-between items-center">
                    <h3 id="tituloFormProveedor" class="text-md font-semibold text-sky-400">Nuevo Proveedor</h3>
                    <button type="button" id="btnLimpiarProveedor" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded hidden" style="cursor: pointer;">Nuevo</button>
                </div>
                <form id="formProveedor" class="space-y-3 relative">
                    <input type="hidden" id="proveedorIdEdit">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Nombre / Razón Social</label>
                        <input type="text" id="provNombre" placeholder="Ej. Tuberías de México" autocomplete="off" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-sky-500" required>
                        <!-- Contenedor flotante para sugerencias AJAX -->
                        <div id="sugerenciasProveedores" class="absolute z-50 left-0 right-0 bg-slate-900 border border-slate-700 rounded-lg shadow-xl mt-1 hidden max-h-52 overflow-y-auto text-sm"></div>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Contacto / Responsable</label>
                        <input type="text" id="provContacto" placeholder="Ej. Ing. Martínez" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Teléfono</label>
                        <input type="text" id="provTelefono" placeholder="Ej. 81 2345 6789" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                    <button type="submit" id="btnGuardarProveedor" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Guardar Proveedor</button>
                </form>
            </div>

            <!-- Listado de Proveedores y Selector de Compras -->
            <div class="lg:col-span-2 space-y-4">
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
                    <h3 class="text-md font-semibold text-slate-300">Catálogo de Proveedores</h3>
                    <div class="w-full sm:w-auto">
                        <select id="selectFiltroProveedor" class="bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 w-full sm:w-64">
                            <option value="">Seleccione proveedor para ver compras...</option>
                        </select>
                    </div>
                </div>

                <div id="tablaProveedoresContainer">Cargando proveedores...</div>

                <div class="mt-6 space-y-2">
                    <h4 class="text-sm font-semibold text-sky-400">Historial de Compras al Proveedor Seleccionado</h4>
                    <div id="historialComprasProveedorContainer" class="bg-slate-950 border border-slate-800 p-3 rounded-xl min-h-[100px] text-xs text-slate-400">
                        Seleccione un proveedor en el menú superior o en la tabla para consultar su historial de compras.
                    </div>
                </div>
            </div>
        </div>
    `;

    await renderizarTablaProveedores();
    configurarLogicaProveedores();
}

async function renderizarTablaProveedores() {
    const contenedorTabla = document.getElementById('tablaProveedoresContainer');
    const selectFiltro = document.getElementById('selectFiltroProveedor');
    if (!contenedorTabla || !selectFiltro) return;

    try {
        const { data, error } = await supabaseClient
            .from('proveedores')
            .select('*')
            .order('nombre', { ascending: true });

        if (error) throw error;

        let optionsHtml = '<option value="">Seleccione proveedor para ver compras...</option>';
        if (data && data.length > 0) {
            data.forEach(p => {
                optionsHtml += `<option value="${p.nombre}">${p.nombre}</option>`;
            });
        }
        selectFiltro.innerHTML = optionsHtml;

        if (!data || data.length === 0) {
            contenedorTabla.innerHTML = `<p class="text-slate-400 text-sm">No hay proveedores registrados.</p>`;
            return;
        }

        let html = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl max-h-64 overflow-y-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-sky-400 bg-slate-950 sticky top-0">
                            <th class="p-2.5">Proveedor</th>
                            <th class="p-2.5">Contacto</th>
                            <th class="p-2.5">Teléfono</th>
                            <th class="p-2.5 text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        data.forEach(p => {
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition">
                    <td class="p-2.5 font-medium text-slate-100">${p.nombre}</td>
                    <td class="p-2.5 text-slate-400 text-xs">${p.contacto || 'N/D'}</td>
                    <td class="p-2.5 text-slate-400 text-xs">${p.telefono || 'N/D'}</td>
                    <td class="p-2.5 text-right">
                        <button onclick="window.verProveedor(${p.id}, '${p.nombre}', '${p.contacto || ''}', '${p.telefono || ''}')" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded mr-1" style="cursor: pointer;">Ver</button>
                        <button onclick="window.editarProveedor(${p.id}, '${p.nombre}', '${p.contacto || ''}', '${p.telefono || ''}')" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded mr-1" style="cursor: pointer;">Editar</button>
                        <button onclick="window.filtrarComprasProveedor('${p.nombre}')" class="text-xs bg-sky-950 hover:bg-sky-900 text-sky-400 px-2 py-1 rounded border border-sky-800" style="cursor: pointer;">Ver Compras</button>
                    </td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorTabla.innerHTML = html;

    } catch (err) {
        console.error("Error al cargar la tabla de proveedores:", err);
        contenedorTabla.innerHTML = `<p class="text-red-400 text-xs">Error al conectar con la tabla de proveedores.</p>`;
    }
}

function configurarLogicaProveedores() {
    const form = document.getElementById('formProveedor');
    const btnLimpiar = document.getElementById('btnLimpiarProveedor');
    const tituloForm = document.getElementById('tituloFormProveedor');
    const selectFiltro = document.getElementById('selectFiltroProveedor');
    const inputNombre = document.getElementById('provNombre');
    const inputContacto = document.getElementById('provContacto');
    const inputTelefono = document.getElementById('provTelefono');
    const dropdownSugerencias = document.getElementById('sugerenciasProveedores');
    const btnGuardar = document.getElementById('btnGuardarProveedor');

    function establecerModoEditable(habilitar) {
        inputContacto.disabled = !habilitar;
        inputTelefono.disabled = !habilitar;
        if (habilitar) {
            btnGuardar.classList.remove('hidden');
        } else {
            btnGuardar.classList.add('hidden');
        }
    }

    // Búsqueda AJAX con botones de acción directa ("Ver" y "Editar")
    inputNombre.addEventListener('input', async (e) => {
        const query = e.target.value.trim();
        if (query.length < 2) {
            dropdownSugerencias.classList.add('hidden');
            return;
        }

        try {
            const { data, error } = await supabaseClient
                .from('proveedores')
                .select('*')
                .ilike('nombre', `%${query}%`)
                .limit(5);

            if (error) throw error;

            if (data && data.length > 0) {
                dropdownSugerencias.innerHTML = data.map(prov => `
                    <div class="p-2.5 hover:bg-slate-800 border-b border-slate-800 text-slate-200 transition flex justify-between items-center">
                        <div>
                            <div class="font-semibold text-sky-400">${prov.nombre}</div>
                            <div class="text-xs text-slate-400">Contacto: ${prov.contacto || 'N/A'} | Tel: ${prov.telefono || 'N/A'}</div>
                        </div>
                        <div class="flex gap-1 shrink-0">
                            <button type="button" onclick="window.verProveedor(${prov.id}, '${prov.nombre}', '${prov.contacto || ''}', '${prov.telefono || ''}')" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded" style="cursor: pointer;">Ver</button>
                            <button type="button" onclick="window.editarProveedor(${prov.id}, '${prov.nombre}', '${prov.contacto || ''}', '${prov.telefono || ''}')" class="text-[11px] bg-sky-950 hover:bg-sky-900 text-sky-300 px-2 py-1 rounded border border-sky-800" style="cursor: pointer;">Editar</button>
                        </div>
                    </div>
                `).join('');
                dropdownSugerencias.classList.remove('hidden');
            } else {
                dropdownSugerencias.innerHTML = `<div class="p-2.5 text-xs text-slate-400">Sin coincidencias. Se registrará como nuevo proveedor.</div>`;
                dropdownSugerencias.classList.remove('hidden');
                establecerModoEditable(true);
            }
        } catch (err) {
            console.error("Error en búsqueda AJAX:", err);
        }
    });

    // Acción de solo ver (bloqueado para edición)
    window.verProveedor = function(id, nombre, contacto, telefono) {
        document.getElementById('proveedorIdEdit').value = id;
        inputNombre.value = nombre;
        inputContacto.value = contacto !== 'null' ? contacto : '';
        inputTelefono.value = telefono !== 'null' ? telefono : '';
        
        tituloForm.textContent = "Detalle de Proveedor (Solo Lectura)";
        establecerModoEditable(false);
        btnLimpiar.classList.remove('hidden');
        dropdownSugerencias.classList.add('hidden');
    };

    // Acción de editar (habilitado para cambios)
    window.editarProveedor = function(id, nombre, contacto, telefono) {
        document.getElementById('proveedorIdEdit').value = id;
        inputNombre.value = nombre;
        inputContacto.value = contacto !== 'null' ? contacto : '';
        inputTelefono.value = telefono !== 'null' ? telefono : '';
        
        tituloForm.textContent = "Modificar Proveedor";
        btnGuardar.textContent = "Actualizar Proveedor";
        establecerModoEditable(true);
        btnLimpiar.classList.remove('hidden');
        dropdownSugerencias.classList.add('hidden');
    };

    // Ocultar sugerencias al hacer clic fuera
    document.addEventListener('click', (e) => {
        if (!inputNombre.contains(e.target) && !dropdownSugerencias.contains(e.target)) {
            dropdownSugerencias.classList.add('hidden');
        }
    });

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const idEdit = document.getElementById('proveedorIdEdit').value;
        const nombre = inputNombre.value.trim();
        const contacto = inputContacto.value.trim();
        const telefono = inputTelefono.value.trim();

        try {
            const payload = { nombre, contacto, telefono };
            if (idEdit) {
                const { error } = await supabaseClient.from('proveedores').update(payload).eq('id', idEdit);
                if (error) throw error;
                alert("¡Proveedor actualizado con éxito, mi lord!");
            } else {
                const { error } = await supabaseClient.from('proveedores').insert([payload]);
                if (error) throw error;
                alert("¡Proveedor registrado con éxito, mi lord!");
            }

            form.reset();
            document.getElementById('proveedorIdEdit').value = '';
            tituloForm.textContent = "Nuevo Proveedor";
            btnGuardar.textContent = "Guardar Proveedor";
            establecerModoEditable(true);
            btnLimpiar.classList.add('hidden');
            await renderizarTablaProveedores();
        } catch (err) {
            console.error("Error al guardar proveedor:", err);
            alert("Error al procesar la operación en la base de datos.");
        }
    });

    btnLimpiar.addEventListener('click', () => {
        form.reset();
        document.getElementById('proveedorIdEdit').value = '';
        tituloForm.textContent = "Nuevo Proveedor";
        btnGuardar.textContent = "Guardar Proveedor";
        establecerModoEditable(true);
        btnLimpiar.classList.add('hidden');
        dropdownSugerencias.classList.add('hidden');
    });

    selectFiltro.addEventListener('change', (e) => {
        const proveedorNombre = e.target.value;
        if (proveedorNombre) {
            window.filtrarComprasProveedor(proveedorNombre);
        } else {
            document.getElementById('historialComprasProveedorContainer').innerHTML = `Seleccione un proveedor en el menú superior o en la tabla para consultar su historial de compras.`;
        }
    });

    window.filtrarComprasProveedor = async function(nombreProveedor) {
        const contenedorHistorial = document.getElementById('historialComprasProveedorContainer');
        if (!contenedorHistorial) return;

        contenedorHistorial.innerHTML = `<p class="text-slate-400 text-xs">Cargando compras para ${nombreProveedor}...</p>`;

        try {
            const { data, error } = await supabaseClient
                .from('materias_primas')
                .select(`
                    nombre,
                    unidad_medida,
                    lotes_materias_primas (
                        numero_lote,
                        stock_actual,
                        costo_unitario,
                        moneda,
                        fecha_ingreso
                    )
                `)
                .eq('proveedor', nombreProveedor);

            if (error) throw error;

            if (!data || data.length === 0) {
                contenedorHistorial.innerHTML = `<p class="text-slate-400 text-xs">No se encontraron registros de compras asociadas a este proveedor.</p>`;
                return;
            }

            let html = `
                <div class="overflow-x-auto max-h-48 overflow-y-auto">
                    <table class="w-full text-left text-slate-300">
                        <thead>
                            <tr class="border-b border-slate-800 text-sky-400 text-[11px]">
                                <th class="p-2">Insumo / Materia Prima</th>
                                <th class="p-2">Factura / Lote</th>
                                <th class="p-2">Cantidad</th>
                                <th class="p-2">Costo Unitario</th>
                                <th class="p-2">Fecha Ingreso</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            let totalCompras = 0;
            data.forEach(mp => {
                if (mp.lotes_materias_primas && mp.lotes_materias_primas.length > 0) {
                    mp.lotes_materias_primas.forEach(lote => {
                        totalCompras++;
                        html += `
                            <tr class="border-b border-slate-900 text-xs">
                                <td class="p-2 font-medium text-slate-100">${mp.nombre}</td>
                                <td class="p-2 font-mono text-sky-300">${lote.numero_lote}</td>
                                <td class="p-2 font-mono">${lote.stock_actual} ${mp.unidad_medida || ''}</td>
                                <td class="p-2 font-mono">$${Number(lote.costo_unitario || 0).toFixed(2)} ${lote.moneda || 'MXN'}</td>
                                <td class="p-2 text-slate-400">${lote.fecha_ingreso ? new Date(lote.fecha_ingreso).toLocaleDateString() : 'N/D'}</td>
                            </tr>
                        `;
                    });
                }
            });

            if (totalCompras === 0) {
                contenedorHistorial.innerHTML = `<p class="text-slate-400 text-xs">El proveedor existe pero no tiene lotes o compras registradas en el inventario actual.</p>`;
                return;
            }

            html += `</tbody></table></div>`;
            contenedorHistorial.innerHTML = html;

        } catch (err) {
            console.error("Error al filtrar compras del proveedor:", err);
            contenedorHistorial.innerHTML = `<p class="text-red-400 text-xs">Error al consultar el historial de compras.</p>`;
        }
    };
}