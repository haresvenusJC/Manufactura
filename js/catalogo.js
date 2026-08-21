import { supabaseClient } from './supabase.js';

export async function verificarConexionReal() {
    const statusEl = document.getElementById('statusConexion');
    try {
        if (!supabaseClient) throw new Error("Cliente Supabase no inicializado");
        
        const { error } = await supabaseClient.from('productos').select('id', { count: 'exact', head: true });
        if (error) throw error;

        if (statusEl) {
            statusEl.textContent = "Estado: Conectado";
            statusEl.className = "text-xs bg-emerald-950 px-3 py-1.5 rounded-lg text-emerald-400 border border-emerald-800 text-center font-mono";
        }
    } catch (error) {
        console.error("Error de conexión:", error);
        if (statusEl) {
            statusEl.textContent = "Estado: Error de Conexión";
            statusEl.className = "text-xs bg-red-950 px-3 py-1.5 rounded-lg text-red-400 border border-red-800 text-center font-mono";
        }
    }
}

export async function cargarCatalogoInicial() {
    const contenedor = document.getElementById('contenedorCatalogo');
    if (!contenedor) {
        console.error("No se encontró el elemento #contenedorCatalogo en el DOM.");
        return;
    }

    try {
        if (!supabaseClient) throw new Error("Cliente Supabase no disponible.");
        
        contenedor.innerHTML = `<p class="text-slate-400 text-sm p-4">Cargando catálogo con arquitectura unificada...</p>`;

        // 1. Obtener todos los artículos de la tabla unificada 'productos'
        const { data: todosArticulos, error: errArtList } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku, tipo, unidad_medida, proveedor_id, proveedores(id, nombre)');

        if (errArtList) throw errArtList;

        // 2. Cargar catálogo de proveedores
        const { data: listaProveedores, error: errProv } = await supabaseClient
            .from('proveedores')
            .select('id, nombre');

        if (errProv) throw errProv;

        let opcionesProveedoresHtml = '<option value="">Seleccione proveedor...</option>';
        if (listaProveedores && listaProveedores.length > 0) {
            listaProveedores.forEach(prov => {
                opcionesProveedoresHtml += `<option value="${prov.id}">${prov.nombre}</option>`;
            });
        }

        // 3. Carga estricta desde la tabla unidades_medida (sin arreglos estáticos de respaldo)
        let unidadesMedida = [];
        const { data: resUm, error: errUm } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('id', { ascending: true });

        if (errUm) {
            console.error("Error al consultar unidades_medida:", errUm.message);
            throw errUm;
        } else if (resUm) {
            unidadesMedida = resUm;
        }

        const mapaArticulos = {};
        
        let opcionesBomHtml = '<option value="">Seleccione insumo o componente...</option>';
        if (todosArticulos && todosArticulos.length > 0) {
            const materiasPrimas = todosArticulos.filter(a => a.tipo === 'materia_prima');
            const productosTerminados = todosArticulos.filter(a => a.tipo !== 'materia_prima');

            if (materiasPrimas.length > 0) {
                opcionesBomHtml += '<optgroup label="Materias Primas">';
                materiasPrimas.forEach(m => {
                    mapaArticulos[m.id] = m;
                    opcionesBomHtml += `<option value="${m.id}">${m.nombre} (${m.unidad_medida || 'ud'})</option>`;
                });
                opcionesBomHtml += '</optgroup>';
            }

            if (productosTerminados.length > 0) {
                opcionesBomHtml += '<optgroup label="Productos / Subensambles">';
                productosTerminados.forEach(p => {
                    mapaArticulos[p.id] = p;
                    opcionesBomHtml += `<option value="${p.id}">${p.nombre} [SKU: ${p.sku || 'N/D'}]</option>`;
                });
                opcionesBomHtml += '</optgroup>';
            }
        }

        let opcionesUnidades = '<option value="">Seleccione unidad...</option>';
        unidadesMedida.forEach(u => {
            const nombreUnidad = u.nombre || '';
            opcionesUnidades += `<option value="${nombreUnidad}">${nombreUnidad}</option>`;
        });

        contenedor.innerHTML = `
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Formulario Maestro de Artículos, Productos e Insumos -->
                <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-4 relative">
                    <div class="flex justify-between items-center">
                        <h3 id="tituloFormProducto" class="text-md font-semibold text-sky-400">Registro General de Artículos</h3>
                        <button type="button" id="btnNuevoModo" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded hidden">Limpiar / Nuevo</button>
                    </div>

                    <form id="formCrearProducto" class="space-y-3">
                        <div>
                            <label class="block text-xs font-medium text-amber-400 mb-1">Tipo de Elemento / Segmentación</label>
                            <select id="tipoElemento" class="w-full bg-slate-900 border border-slate-700 rounded-lg p-2 text-sm text-slate-100 font-medium">
                                <option value="producto">Producto (Terminado / Ensamblado)</option>
                                <option value="materia_prima">Materia Prima</option>
                                <option value="insumo">Insumo / Componente Auxiliar</option>
                            </select>
                        </div>

                        <div class="relative">
                            <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Artículo</label>
                            <input type="text" id="prodNombre" placeholder="Ej. Agua purificada Nivel 1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 autocomplete-input" autocomplete="off" required>
                            <div id="sugerenciasProductos" class="absolute z-50 left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl hidden max-h-48 overflow-y-auto"></div>
                        </div>

                        <div class="grid grid-cols-2 gap-2">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">SKU / Código</label>
                                <input type="text" id="prodSku" placeholder="Ej. H2O" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">Unidad de Medida</label>
                                <select id="prodUnidadMedida" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                    ${opcionesUnidades}
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-2">
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Costo Unitario</label>
                                <input type="number" step="0.01" id="prodCosto" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Moneda</label>
                                <select id="prodMoneda" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-medium">
                                    <option value="MXN">MXN</option>
                                    <option value="USD">USD</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">Proveedor</label>
                            <select id="prodProveedorId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                ${opcionesProveedoresHtml}
                            </select>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">Descripción / Notas</label>
                            <textarea id="prodDesc" placeholder="Especificaciones adicionales" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" rows="2"></textarea>
                        </div>
                        
                        <hr class="border-slate-800 my-2">
                        
                        <div id="seccionBomContainer" class="space-y-2">
                            <div class="flex justify-between items-center">
                                <label class="block text-xs font-semibold text-sky-400">Estructura de Componentes / BOM Unificado</label>
                            </div>

                            <div class="grid grid-cols-1 gap-2 bg-slate-900/50 p-2.5 rounded-lg border border-slate-800">
                                <div class="flex gap-2">
                                    <select id="bomInsumo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                        ${opcionesBomHtml}
                                    </select>
                                </div>
                                
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Cantidad</label>
                                        <input type="number" step="0.0001" id="bomCantidad" placeholder="Ej. 500" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Unidad Consumo</label>
                                        <select id="bomUnidadMedida" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                            ${opcionesUnidades}
                                        </select>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-[10px] text-slate-400 mb-0.5">Merma (%)</label>
                                    <input type="number" step="0.01" id="bomMerma" placeholder="Ej. 0.05" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                </div>

                                <button type="button" id="btnAgregarItemBom" class="w-full bg-slate-800 hover:bg-slate-700 text-sky-300 font-medium py-1.5 rounded-lg text-xs transition">＋ Agregar Componente al BOM</button>
                            </div>

                            <div id="listaBomTemporal" class="text-xs text-slate-400 bg-slate-900 p-2 rounded-lg border border-slate-800 min-h-[40px]">
                                Sin elementos agregados.
                            </div>
                        </div>

                        <button type="submit" id="btnGuardarProd" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Guardar Artículo</button>
                    </form>
                </div>

                <!-- Tabla de Artículos General -->
                <div class="lg:col-span-2 space-y-3">
                    <div class="flex justify-between items-center">
                        <h3 class="text-md font-semibold text-slate-300">Catálogo General de Artículos</h3>
                        <div class="flex gap-2">
                            <span class="text-xs bg-slate-900 border border-slate-800 px-2 py-1 rounded text-slate-400">Sincronizado con Supabase</span>
                        </div>
                    </div>
                    <div id="tablaProductosContainer">Cargando listado...</div>
                </div>
            </div>
        `;

        let itemsBomTemp = [];
        let productoSeleccionadoId = null;
        
        const inputNombre = document.getElementById('prodNombre');
        const sugerenciasDiv = document.getElementById('sugerenciasProductos');
        const btnNuevoModo = document.getElementById('btnNuevoModo');
        const tituloForm = document.getElementById('tituloFormProducto');
        const btnGuardar = document.getElementById('btnGuardarProd');
        const btnAddBom = document.getElementById('btnAgregarItemBom');
        const listaTempEl = document.getElementById('listaBomTemporal');
        const selectTipoElemento = document.getElementById('tipoElemento');
        const seccionBomContainer = document.getElementById('seccionBomContainer');

        selectTipoElemento.addEventListener('change', (e) => {
            if (e.target.value === 'producto') {
                seccionBomContainer.classList.remove('hidden');
            } else {
                seccionBomContainer.classList.add('hidden');
                itemsBomTemp = [];
                actualizarListaBomVisual();
            }
        });

        inputNombre.addEventListener('input', async (e) => {
            const query = e.target.value.trim();
            if (query.length < 2) {
                sugerenciasDiv.classList.add('hidden');
                sugerenciasDiv.innerHTML = '';
                return;
            }

            try {
                const { data, error } = await supabaseClient
                    .from('productos')
                    .select('*')
                    .ilike('nombre', `%${query}%`)
                    .limit(5);

                if (error) throw error;

                if (!data || data.length === 0) {
                    sugerenciasDiv.classList.add('hidden');
                    return;
                }

                sugerenciasDiv.innerHTML = data.map(art => `
                    <div class="p-2 hover:bg-slate-800 cursor-pointer border-b border-slate-800 last:border-0 text-xs flex justify-between items-center" data-id="${art.id}">
                        <div>
                            <span class="font-medium text-sky-300">${art.nombre}</span>
                            <span class="text-slate-400 block font-mono">SKU: ${art.sku || 'N/D'} | Tipo: ${art.tipo || 'producto'}</span>
                        </div>
                        <span class="text-[10px] bg-sky-950 text-sky-400 px-1.5 py-0.5 rounded border border-sky-800">Seleccionar</span>
                    </div>
                `).join('');

                sugerenciasDiv.classList.remove('hidden');

                sugerenciasDiv.querySelectorAll('div[data-id]').forEach(itemEl => {
                    itemEl.addEventListener('click', async () => {
                        const artId = itemEl.getAttribute('data-id');
                        sugerenciasDiv.classList.add('hidden');
                        await cargarDetalleArticuloExistente(artId);
                    });
                });

            } catch (err) {
                console.error("Error en búsqueda AJAX:", err);
            }
        });

        document.addEventListener('click', (e) => {
            if (!inputNombre.contains(e.target) && !sugerenciasDiv.contains(e.target)) {
                sugerenciasDiv.classList.add('hidden');
            }
        });

        async function cargarDetalleArticuloExistente(id) {
            try {
                const { data: art, error: errA } = await supabaseClient
                    .from('productos')
                    .select('*')
                    .eq('id', id)
                    .single();

                if (errA) throw errA;

                productoSeleccionadoId = art.id;
                selectTipoElemento.value = art.tipo || 'producto';
                inputNombre.value = art.nombre;
                document.getElementById('prodSku').value = art.sku || '';
                document.getElementById('prodUnidadMedida').value = art.unidad_medida || '';
                document.getElementById('prodCosto').value = art.costo_unitario || 0;
                document.getElementById('prodMoneda').value = art.moneda || 'MXN';
                document.getElementById('prodProveedorId').value = art.proveedor_id || '';
                document.getElementById('prodDesc').value = art.descripcion || '';

                tituloForm.textContent = "Modificar Artículo Existente";
                btnGuardar.textContent = "Actualizar Artículo";
                btnNuevoModo.classList.remove('hidden');

                if (art.tipo === 'producto') {
                    seccionBomContainer.classList.remove('hidden');
                    
                    const { data: bomItems, error: errBom } = await supabaseClient
                        .from('bom')
                        .select('*, componente:productos!bom_componente_id_fkey(id, nombre, sku, unidad_medida)')
                        .eq('producto_id', id);

                    if (errBom) {
                        console.warn("Intentando consulta alternativa de BOM:", errBom.message);
                    }

                    itemsBomTemp = [];
                    if (bomItems && bomItems.length > 0) {
                        bomItems.forEach(b => {
                            const infoComp = b.componente || mapaArticulos[b.componente_id] || { nombre: `Elemento ID: ${b.componente_id}` };
                            itemsBomTemp.push({
                                componenteId: b.componente_id,
                                componenteNombre: infoComp.nombre,
                                cantidad: b.cantidad_requerida,
                                unidad: b.unidad_medida || 'g',
                                merma: b.factor_merma || 0
                            });
                        });
                    }
                    actualizarListaBomVisual();
                } else {
                    seccionBomContainer.classList.add('hidden');
                }

            } catch (err) {
                console.error("Error al cargar artículo existente:", err);
                alert("Error al recuperar los datos del artículo.");
            }
        }

        btnNuevoModo.addEventListener('click', () => {
            productoSeleccionadoId = null;
            document.getElementById('formCrearProducto').reset();
            itemsBomTemp = [];
            actualizarListaBomVisual();
            seccionBomContainer.classList.remove('hidden');
            tituloForm.textContent = "Registro General de Artículos";
            btnGuardar.textContent = "Guardar Artículo";
            btnNuevoModo.classList.add('hidden');
        });

        function actualizarListaBomVisual() {
            if (itemsBomTemp.length === 0) {
                listaTempEl.innerHTML = "Sin elementos agregados.";
                return;
            }
            listaTempEl.innerHTML = itemsBomTemp.map((item, idx) => `
                <div class="flex justify-between items-center py-1 border-b border-slate-800 last:border-0">
                    <span>${item.componenteNombre} - <strong>${item.cantidad} ${item.unidad}</strong> (Merma: ${item.merma})</span>
                    <button type="button" onclick="window.removerItemBom(${idx})" class="text-red-400 hover:text-red-300 text-xs">Eliminar</button>
                </div>
            `).join('');
        }

        btnAddBom.addEventListener('click', () => {
            const insumoSelect = document.getElementById('bomInsumo');
            const componenteId = parseInt(insumoSelect.value);
            
            if (!componenteId || isNaN(componenteId)) {
                alert("Seleccione un componente válido de la lista.");
                return;
            }

            const selectedOption = insumoSelect.options[insumoSelect.selectedIndex];
            const nombreInsumo = selectedOption.text.split(' [')[0];
            
            const cantidad = parseFloat(document.getElementById('bomCantidad').value) || 0;
            const unidadSelect = document.getElementById('bomUnidadMedida');
            const unidadConsumo = unidadSelect.value;

            if (!unidadConsumo) {
                alert("Seleccione la unidad de medida de consumo.");
                return;
            }

            const merma = parseFloat(document.getElementById('bomMerma').value) || 0;

            if (cantidad <= 0) {
                alert("Ingrese una cantidad mayor a 0.");
                return;
            }

            itemsBomTemp.push({
                componenteId,
                componenteNombre: nombreInsumo, 
                cantidad, 
                unidad: unidadConsumo,
                merma 
            });
            
            actualizarListaBomVisual();

            document.getElementById('bomCantidad').value = '';
            document.getElementById('bomMerma').value = '';
            insumoSelect.value = '';
            unidadSelect.value = '';
        });

        window.removerItemBom = function(index) {
            itemsBomTemp.splice(index, 1);
            actualizarListaBomVisual();
        };

        const formProducto = document.getElementById('formCrearProducto');
        formProducto.addEventListener('submit', async (e) => {
            e.preventDefault();
            const tipo = selectTipoElemento.value;
            const nombre = inputNombre.value.trim();
            const sku = document.getElementById('prodSku').value.trim();
            const unidadMedida = document.getElementById('prodUnidadMedida').value;
            const costoUnitario = parseFloat(document.getElementById('prodCosto').value) || 0;
            const moneda = document.getElementById('prodMoneda').value;
            const proveedorIdVal = document.getElementById('prodProveedorId').value;
            const proveedor_id = proveedorIdVal ? parseInt(proveedorIdVal) : null;
            const descripcion = document.getElementById('prodDesc').value.trim();

            if (!nombre || !sku || !unidadMedida) {
                alert("El nombre, el SKU y la unidad de medida son obligatorios.");
                return;
            }

            try {
                let articuloId = productoSeleccionadoId;
                const payload = {
                    tipo, 
                    nombre, 
                    sku, 
                    unidad_medida: unidadMedida, 
                    costo_unitario: costoUnitario,
                    moneda,
                    proveedor_id,
                    descripcion 
                };

                if (articuloId) {
                    const { error: errUpd } = await supabaseClient
                        .from('productos')
                        .update(payload)
                        .eq('id', articuloId);

                    if (errUpd) throw errUpd;

                    await supabaseClient.from('bom').delete().eq('producto_id', articuloId);

                } else {
                    const { data: artIns, error: errArt } = await supabaseClient
                        .from('productos')
                        .insert([payload])
                        .select('id')
                        .single();

                    if (errArt) throw errArt;
                    articuloId = artIns.id;
                }

                if (tipo === 'producto' && itemsBomTemp.length > 0) {
                    const itemsBom = itemsBomTemp.map(i => ({
                        producto_id: articuloId,
                        componente_id: i.componenteId,
                        cantidad_requerida: i.cantidad,
                        unidad_medida: i.unidad,
                        factor_merma: i.merma
                    }));

                    const { error: errB } = await supabaseClient.from('bom').insert(itemsBom);
                    if (errB) throw errB;
                }

                alert(productoSeleccionadoId ? "¡Artículo actualizado con éxito, mi lord!" : "¡Artículo registrado con éxito, mi lord!");
                
                btnNuevoModo.click();
                await renderizarTablaProductos();

            } catch (err) {
                console.error("Error al guardar el artículo:", err);
                if (err.code === '23505') {
                    alert('Error al guardar el artículo: El SKU o clave ya está registrado.');
                } else {
                    alert("Error al procesar la operación en la base de datos.");
                }
            }
        });

        await renderizarTablaProductos();

    } catch (err) {
        console.error("Error crítico al inicializar el catálogo:", err);
        if (contenedor) {
            contenedor.innerHTML = `<div class="p-4 bg-red-950/40 border border-red-800 rounded-xl text-red-300 text-sm">
                <strong>Error al cargar la sección de catálogo:</strong> ${err.message || err}
            </div>`;
        }
    }
}

async function renderizarTablaProductos() {
    const contenedorTabla = document.getElementById('tablaProductosContainer');
    if (!contenedorTabla) return;

    try {
        const { data: productosData, error: errProd } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku, tipo, unidad_medida, proveedor_id, proveedores(nombre)');

        if (errProd) throw errProd;

        if (!productosData || productosData.length === 0) {
            contenedorTabla.innerHTML = `<p class="text-slate-400 text-sm">No hay artículos registrados.</p>`;
            return;
        }

        let html = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-sky-400 bg-slate-950">
                            <th class="p-3">SKU</th>
                            <th class="p-3">Tipo</th>
                            <th class="p-3">Nombre</th>
                            <th class="p-3">Unidad</th>
                            <th class="p-3">Proveedor</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        productosData.forEach(item => {
            let badgeColor = "bg-sky-950 text-sky-400 border-sky-800";
            if (item.tipo === 'materia_prima') badgeColor = "bg-amber-950 text-amber-400 border-amber-800";
            if (item.tipo === 'insumo') badgeColor = "bg-emerald-950 text-emerald-400 border-emerald-800";

            const nombreProveedor = item.proveedores?.nombre || 'N/D';

            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition">
                    <td class="p-3 font-mono text-xs text-sky-300">${item.sku || 'N/D'}</td>
                    <td class="p-3"><span class="text-[10px] px-2 py-0.5 rounded border ${badgeColor} uppercase">${item.tipo || 'producto'}</span></td>
                    <td class="p-3 font-medium text-slate-100">${item.nombre || 'Sin nombre'}</td>
                    <td class="p-3 text-slate-400 text-xs">${item.unidad_medida || 'N/D'}</td>
                    <td class="p-3 text-slate-300 text-xs">${nombreProveedor}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorTabla.innerHTML = html;

    } catch (err) {
        console.error("Error al consultar el catálogo:", err);
        contenedorTabla.innerHTML = `<p class="text-red-400 text-sm">Error al consultar la tabla de productos: ${err.message || err}</p>`;
    }
}