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

async function actualizarSelectProveedores() {
    const selectProveedor = document.getElementById('prodProveedorId');
    if (!selectProveedor) return;

    try {
        const { data: listaProveedores, error: errProv } = await supabaseClient
            .from('proveedores')
            .select('id, nombre')
            .order('nombre', { ascending: true });

        if (errProv) throw errProv;

        let opcionesProveedoresHtml = '<option value="">Seleccione proveedor...</option>';
        if (listaProveedores && listaProveedores.length > 0) {
            listaProveedores.forEach(prov => {
                opcionesProveedoresHtml += `<option value="${prov.id}">${prov.nombre}</option>`;
            });
        }
        
        selectProveedor.innerHTML = opcionesProveedoresHtml;
    } catch (err) {
        console.error("Error al actualizar la lista de proveedores:", err);
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
        
        contenedor.innerHTML = `<p class="text-slate-400 text-sm p-4">Cargando catálogo con arquitectura normalizada...</p>`;

        // 1. Cargar unidades de medida
        let unidadesMedida = [];
        const mapaUnidades = {};
        const { data: resUm, error: errUm } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('id', { ascending: true });

        if (errUm) {
            throw errUm;
        } else if (resUm) {
            unidadesMedida = resUm;
            unidadesMedida.forEach(u => {
                mapaUnidades[u.id] = u.nombre;
            });
        }

        let opcionesUnidades = '<option value="">Seleccione unidad...</option>';
        unidadesMedida.forEach(u => {
            opcionesUnidades += `<option value="${u.id}">${u.nombre}</option>`;
        });

        // 2. Cargar monedas dinámicamente desde la tabla monedas (id, codigo)
        let monedasList = [];
        const mapaMonedas = {};
        const { data: resMon, error: errMon } = await supabaseClient
            .from('monedas')
            .select('id, codigo')
            .order('id', { ascending: true });

        if (errMon) {
            throw errMon;
        } else if (resMon) {
            monedasList = resMon;
            monedasList.forEach(m => {
                mapaMonedas[m.id] = m.codigo;
            });
        }

        let opcionesMonedas = '<option value="">Seleccione moneda...</option>';
        monedasList.forEach(m => {
            opcionesMonedas += `<option value="${m.id}">${m.codigo}</option>`;
        });

        // 3. Obtener artículos (usando '*' para garantizar que traiga 'moneda_id' y todos los campos nuevos del esquema)
        const { data: todosArticulos, error: errArtList } = await supabaseClient
            .from('productos')
            .select('*');

        if (errArtList) throw errArtList;

        // 4. Cargar proveedores
        const { data: listaProveedores, error: errProv } = await supabaseClient
            .from('proveedores')
            .select('id, nombre')
            .order('nombre', { ascending: true });

        if (errProv) throw errProv;

        const mapaProveedores = {};
        let opcionesProveedoresHtml = '<option value="">Seleccione proveedor...</option>';
        if (listaProveedores && listaProveedores.length > 0) {
            listaProveedores.forEach(prov => {
                mapaProveedores[prov.id] = prov.nombre;
                opcionesProveedoresHtml += `<option value="${prov.id}">${prov.nombre}</option>`;
            });
        }

        // 5. Cargar cuentas contables (si el modulo de contabilidad ya esta instalado)
        let cuentasContables = [];
        try {
            const { data: resCtas } = await supabaseClient
                .from('cuentas_contables')
                .select('id, codigo, nombre, tipo')
                .eq('afectable', true).eq('activa', true)
                .order('codigo', { ascending: true });
            cuentasContables = resCtas || [];
        } catch (_) { /* modulo de contabilidad aun no instalado */ }

        const opcionesCuentas = (tiposPreferidos = []) => {
            const pref = cuentasContables.filter(c => tiposPreferidos.includes(c.tipo));
            const resto = cuentasContables.filter(c => !tiposPreferidos.includes(c.tipo));
            const linea = c => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`;
            return '<option value="">(sin cuenta)</option>' + pref.map(linea).join('') +
                (pref.length && resto.length ? '<option disabled>──────</option>' : '') + resto.map(linea).join('');
        };

        const mapaArticulos = {};
        let opcionesBomHtml = '<option value="">Seleccione insumo o componente...</option>';
        if (todosArticulos && todosArticulos.length > 0) {
            const materiasPrimas = todosArticulos.filter(a => a.tipo === 'materia_prima');
            const productosTerminados = todosArticulos.filter(a => a.tipo !== 'materia_prima');

            if (materiasPrimas.length > 0) {
                opcionesBomHtml += '<optgroup label="Materias Primas">';
                materiasPrimas.forEach(m => {
                    mapaArticulos[m.id] = m;
                    const nombreUni = mapaUnidades[m.unidad_medida_id] || 'ud';
                    opcionesBomHtml += `<option value="${m.id}">${m.nombre} (${nombreUni})</option>`;
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

        contenedor.innerHTML = `
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
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
                            <input type="text" id="prodNombre" placeholder="Ej. Artículo o Material" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 autocomplete-input" autocomplete="off" required>
                            <div id="sugerenciasProductos" class="absolute z-50 left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl hidden max-h-48 overflow-y-auto"></div>
                        </div>

                        <div class="grid grid-cols-2 gap-2">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">SKU / Código</label>
                                <input type="text" id="prodSku" placeholder="Ej. SKU-001" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono">
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">Unidad de Medida</label>
                                <select id="prodUnidadMedidaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
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
                                <select id="prodMonedaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-medium" required>
                                    ${opcionesMonedas}
                                </select>
                            </div>
                        </div>

                        <div>
                            <div class="flex justify-between items-center mb-1">
                                <label class="block text-xs font-medium text-slate-400">Proveedor</label>
                                <button type="button" id="btnRefrescarProveedores" class="text-[10px] text-sky-400 hover:underline">🔄 Actualizar lista</button>
                            </div>
                            <select id="prodProveedorId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                ${opcionesProveedoresHtml}
                            </select>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">Descripción / Notas</label>
                            <textarea id="prodDesc" placeholder="Especificaciones adicionales" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" rows="2"></textarea>
                        </div>

                        <details class="bg-slate-900/40 border border-slate-800 rounded-lg" ${cuentasContables.length ? '' : 'hidden'}>
                            <summary class="cursor-pointer select-none text-xs font-semibold text-sky-400 px-3 py-2">Datos contables</summary>
                            <div class="p-3 pt-0 grid grid-cols-2 gap-2">
                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Tasa IVA</label>
                                    <select id="prodTasaIva" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                        <option value="0.16">16%</option>
                                        <option value="0.08">8%</option>
                                        <option value="0">0%</option>
                                        <option value="">Exento</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Tasa IEPS</label>
                                    <input type="number" step="0.0001" min="0" id="prodTasaIeps" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                </div>
                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Cuenta de inventario</label>
                                    <select id="prodCtaInventario" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${opcionesCuentas(['activo'])}</select>
                                </div>
                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Cuenta de costo</label>
                                    <select id="prodCtaCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${opcionesCuentas(['costo', 'gasto'])}</select>
                                </div>
                            </div>
                        </details>

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
                                        <input type="number" step="0.0001" id="bomCantidad" placeholder="Ej. 1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Unidad Consumo</label>
                                        <select id="bomUnidadMedidaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                            ${opcionesUnidades}
                                        </select>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-[10px] text-slate-400 mb-0.5">Merma (%)</label>
                                    <input type="number" step="0.01" id="bomMerma" placeholder="Ej. 0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
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
        const btnRefrescarProveedores = document.getElementById('btnRefrescarProveedores');
        const tituloForm = document.getElementById('tituloFormProducto');
        const btnGuardar = document.getElementById('btnGuardarProd');
        const btnAddBom = document.getElementById('btnAgregarItemBom');
        const listaTempEl = document.getElementById('listaBomTemporal');
        const selectTipoElemento = document.getElementById('tipoElemento');
        const seccionBomContainer = document.getElementById('seccionBomContainer');

        if (btnRefrescarProveedores) {
            btnRefrescarProveedores.addEventListener('click', async () => {
                await actualizarSelectProveedores();
            });
        }

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
                await actualizarSelectProveedores();

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
                document.getElementById('prodUnidadMedidaId').value = art.unidad_medida_id || '';
                document.getElementById('prodCosto').value = art.costo_unitario || 0;
                
                // Asignación directa y robusta del ID de la moneda mapeada en la BD
                const selectMoneda = document.getElementById('prodMonedaId');
                selectMoneda.value = art.moneda_id ? art.moneda_id : "";

                document.getElementById('prodProveedorId').value = art.proveedor_id || '';
                document.getElementById('prodDesc').value = art.descripcion || '';

                // Datos contables (si el modulo esta instalado)
                const elTasaIva = document.getElementById('prodTasaIva');
                if (elTasaIva) {
                    elTasaIva.value = (art.tasa_iva === null || art.tasa_iva === undefined) ? '' : String(art.tasa_iva);
                    document.getElementById('prodTasaIeps').value = art.tasa_ieps || 0;
                    document.getElementById('prodCtaInventario').value = art.cuenta_inventario_id || '';
                    document.getElementById('prodCtaCosto').value = art.cuenta_costo_id || '';
                }

                tituloForm.textContent = "Modificar Artículo Existente";
                btnGuardar.textContent = "Actualizar Artículo";
                btnNuevoModo.classList.remove('hidden');

                if (art.tipo === 'producto') {
                    seccionBomContainer.classList.remove('hidden');
                    
                    const { data: bomItems, error: errBom } = await supabaseClient
                        .from('bom')
                        .select('*')
                        .eq('producto_id', id);

                    if (errBom) {
                        console.warn("Error al consultar BOM:", errBom.message);
                    }

                    itemsBomTemp = [];
                    if (bomItems && bomItems.length > 0) {
                        bomItems.forEach(b => {
                            const infoComp = mapaArticulos[b.componente_id] || { nombre: `Elemento ID: ${b.componente_id}` };
                            itemsBomTemp.push({
                                componenteId: b.componente_id,
                                componenteNombre: infoComp.nombre,
                                cantidad: b.cantidad_requerida,
                                unidadId: b.unidad_medida, 
                                unidadNombre: mapaUnidades[b.unidad_medida] || '',
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

        btnNuevoModo.addEventListener('click', async () => {
            productoSeleccionadoId = null;
            document.getElementById('formCrearProducto').reset();
            itemsBomTemp = [];
            actualizarListaBomVisual();
            seccionBomContainer.classList.remove('hidden');
            tituloForm.textContent = "Registro General de Artículos";
            btnGuardar.textContent = "Guardar Artículo";
            btnNuevoModo.classList.add('hidden');
            
            await actualizarSelectProveedores();
        });

        function actualizarListaBomVisual() {
            if (itemsBomTemp.length === 0) {
                listaTempEl.innerHTML = "Sin elementos agregados.";
                return;
            }
            listaTempEl.innerHTML = itemsBomTemp.map((item, idx) => `
                <div class="flex justify-between items-center py-1 border-b border-slate-800 last:border-0">
                    <span>${item.componenteNombre} - <strong>${item.cantidad} ${item.unidadNombre || ''}</strong> (Merma: ${item.merma})</span>
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
            const unidadSelect = document.getElementById('bomUnidadMedidaId');
            const unidadId = unidadSelect.value ? parseInt(unidadSelect.value) : null;
            const unidadNombre = unidadSelect.options[unidadSelect.selectedIndex]?.text || '';

            const merma = parseFloat(document.getElementById('bomMerma').value) || 0;

            if (cantidad <= 0) {
                alert("Ingrese una cantidad mayor a 0.");
                return;
            }

            itemsBomTemp.push({
                componenteId,
                componenteNombre: nombreInsumo, 
                cantidad, 
                unidadId,
                unidadNombre,
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
            const unidadMedidaIdVal = document.getElementById('prodUnidadMedidaId').value;
            const unidad_medida_id = unidadMedidaIdVal ? parseInt(unidadMedidaIdVal) : null;
            const costoUnitario = parseFloat(document.getElementById('prodCosto').value) || 0;
            const monedaIdVal = document.getElementById('prodMonedaId').value;
            const moneda_id = monedaIdVal ? parseInt(monedaIdVal) : null;
            const proveedorIdVal = document.getElementById('prodProveedorId').value;
            const proveedor_id = proveedorIdVal ? parseInt(proveedorIdVal) : null;
            const descripcion = document.getElementById('prodDesc').value.trim();

            // Datos contables (opcionales; solo si el modulo esta instalado)
            const elTasaIva = document.getElementById('prodTasaIva');
            const datosContables = {};
            if (elTasaIva) {
                datosContables.tasa_iva = elTasaIva.value === '' ? null : parseFloat(elTasaIva.value);
                datosContables.tasa_ieps = parseFloat(document.getElementById('prodTasaIeps').value) || 0;
                const ci = document.getElementById('prodCtaInventario').value;
                const cc = document.getElementById('prodCtaCosto').value;
                datosContables.cuenta_inventario_id = ci ? parseInt(ci) : null;
                datosContables.cuenta_costo_id = cc ? parseInt(cc) : null;
            }

            if (!nombre) {
                alert("El nombre del artículo es obligatorio.");
                return;
            }

            try {
                let articuloId = productoSeleccionadoId;

                const payload = {
                    tipo,
                    nombre,
                    sku: sku || null,
                    unidad_medida_id,
                    costo_unitario: costoUnitario,
                    moneda_id,
                    proveedor_id,
                    descripcion: descripcion || null,
                    ...datosContables
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
                        unidad_medida: i.unidadId ? i.unidadId.toString() : null,
                        factor_merma: i.merma
                    }));

                    const { error: errB } = await supabaseClient.from('bom').insert(itemsBom);
                    if (errB) throw errB;
                }

                alert(productoSeleccionadoId ? "¡Artículo actualizado con éxito!" : "¡Artículo registrado con éxito!");
                
                btnNuevoModo.click();
                await renderizarTablaProductos(mapaUnidades);

            } catch (err) {
                console.error("Error al guardar el artículo:", err);
                if (err.code === '23505') {
                    alert('Error al guardar el artículo: El SKU o clave ya está registrado.');
                } else {
                    alert("Error al procesar la operación en la base de datos: " + (err.message || err));
                }
            }
        });

        await renderizarTablaProductos(mapaUnidades);

    } catch (err) {
        console.error("Error crítico al inicializar el catálogo:", err);
        if (contenedor) {
            contenedor.innerHTML = `<div class="p-4 bg-red-950/40 border border-red-800 rounded-xl text-red-300 text-sm">
                <strong>Error al cargar la sección de catálogo:</strong> ${err.message || err}
            </div>`;
        }
    }
}

async function renderizarTablaProductos(mapaUnidades = {}) {
    const contenedorTabla = document.getElementById('tablaProductosContainer');
    if (!contenedorTabla) return;

    try {
        const [resProd, resProv] = await Promise.all([
            supabaseClient.from('productos').select('id, nombre, sku, tipo, unidad_medida_id, proveedor_id').order('id', { ascending: true }),
            supabaseClient.from('proveedores').select('id, nombre')
        ]);

        if (resProd.error) throw resProd.error;
        const productosData = resProd.data;

        const mapaProvNombres = {};
        if (resProv.data) {
            resProv.data.forEach(p => { mapaProvNombres[p.id] = p.nombre; });
        }

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

            const nombreProveedor = mapaProvNombres[item.proveedor_id] || 'N/D';
            const nombreUnidad = mapaUnidades[item.unidad_medida_id] || 'N/D';

            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition">
                    <td class="p-3 font-mono text-xs text-sky-300">${item.sku || 'N/D'}</td>
                    <td class="p-3"><span class="text-[10px] px-2 py-0.5 rounded border ${badgeColor} uppercase">${item.tipo || 'producto'}</span></td>
                    <td class="p-3 font-medium text-slate-100">${item.nombre || 'Sin nombre'}</td>
                    <td class="p-3 text-slate-400 text-xs">${nombreUnidad}</td>
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