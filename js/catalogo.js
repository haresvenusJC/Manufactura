import { supabaseClient } from './supabase.js';
import { irAKardexDeProducto } from './kardex.js';

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
            <div class="space-y-6">
                <details id="detRegistroProducto" class="bg-slate-950 border border-slate-800 rounded-xl overflow-hidden">
                    <summary class="cursor-pointer select-none p-4 flex justify-between items-center hover:bg-slate-900/40 transition">
                        <span id="tituloFormProducto" class="text-md font-semibold text-sky-400">Registro General de Artículos</span>
                        <span class="text-[11px] text-slate-500 flex items-center gap-1.5 shrink-0">
                            <span id="detRegistroChevron">▸ Abrir</span>
                        </span>
                    </summary>
                    <div class="p-4 pt-0 space-y-4 relative">
                        <div class="flex justify-end">
                            <button type="button" id="btnNuevoModo" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded hidden">Limpiar / Nuevo</button>
                        </div>

                        <form id="formCrearProducto" class="space-y-3">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">¿Qué estás dando de alta?</label>
                            <select id="tipoElemento" class="hidden">
                                <option value="producto">Producto (Terminado / Ensamblado)</option>
                                <option value="materia_prima">Materia Prima</option>
                                <option value="insumo">Insumo / Componente Auxiliar</option>
                            </select>
                            <div id="tipoElementoBotones" class="grid grid-cols-1 sm:grid-cols-3 gap-1.5">
                                <button type="button" data-tipo="producto" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Producto terminado</button>
                                <button type="button" data-tipo="materia_prima" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Materia prima</button>
                                <button type="button" data-tipo="insumo" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Insumo</button>
                            </div>
                        </div>

                        <div class="relative">
                            <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Artículo</label>
                            <input type="text" id="prodNombre" placeholder="Ej. Artículo o Material" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 autocomplete-input" autocomplete="off" required>
                            <div id="sugerenciasProductos" class="absolute z-50 left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl hidden max-h-48 overflow-y-auto"></div>
                        </div>

                        <p id="prodExistenciaActual" class="hidden text-[11px] text-slate-400 bg-slate-900/60 border border-slate-800 rounded-lg px-3 py-2"></p>

                        <div class="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-6 gap-2">
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">SKU / Código <span class="text-rose-400">*</span></label>
                                <input type="text" id="prodSku" placeholder="Ej. SKU-001" required class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Unidad de Medida</label>
                                <select id="prodUnidadMedidaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100" required>
                                    ${opcionesUnidades}
                                </select>
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Costo Unitario</label>
                                <input type="number" step="0.01" id="prodCosto" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Precio de venta</label>
                                <input type="number" step="0.01" min="0" id="prodPrecioVenta" placeholder="s/IVA" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">Moneda</label>
                                <select id="prodMonedaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-medium" required>
                                    ${opcionesMonedas}
                                </select>
                            </div>
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1" title="Cuando la existencia baje de aquí, Inventario lo marca como 'hay que comprar'.">Stock mínimo</label>
                                <input type="number" step="0.0001" min="0" id="prodStockMinimo" value="0" title="Cuando la existencia baje de aquí, Inventario lo marca como 'hay que comprar'." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                            </div>
                        </div>

                        <details class="bg-slate-900/40 border border-slate-800 rounded-lg">
                            <summary class="cursor-pointer select-none text-xs font-semibold text-sky-400 px-3 py-2">Más detalles (opcional)</summary>
                            <div class="p-3 pt-0 space-y-3">
                                <div>
                                    <div class="flex justify-between items-center mb-1">
                                        <label class="block text-[11px] text-slate-400">Proveedor</label>
                                        <button type="button" id="btnRefrescarProveedores" class="text-[10px] text-sky-400 hover:underline">Actualizar lista</button>
                                    </div>
                                    <select id="prodProveedorId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                        ${opcionesProveedoresHtml}
                                    </select>
                                </div>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-[11px] text-slate-400 mb-1">Tiempo de entrega (días)</label>
                                        <input type="number" step="1" min="0" id="prodTiempoEntrega" placeholder="Ej. 7" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    </div>
                                    <div>
                                        <label class="block text-[11px] text-slate-400 mb-1">Compra mínima (MOQ)</label>
                                        <input type="number" step="0.0001" min="0" id="prodCantidadMinimaCompra" placeholder="Ej. 100" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Descripción / Notas</label>
                                    <textarea id="prodDesc" placeholder="Especificaciones adicionales" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100" rows="2"></textarea>
                                </div>
                                <label class="flex items-center gap-2 text-[11px] text-slate-300">
                                    <input type="checkbox" id="prodRequiereCaducidad" class="accent-emerald-500 w-3.5 h-3.5">
                                    Requiere control de caducidad (se pedirá la fecha al recibir cada lote)
                                </label>

                                <div class="border-t border-slate-800 pt-3 ${cuentasContables.length ? '' : 'hidden'}">
                                    <p class="text-[11px] font-semibold text-sky-400 mb-2">Datos contables</p>
                                    <div class="grid grid-cols-2 gap-2">
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
                                </div>
                            </div>
                        </details>

                        <details id="detClavesProv" class="bg-slate-900/40 border border-slate-800 rounded-lg">
                            <summary class="cursor-pointer select-none text-xs font-semibold text-sky-400 px-3 py-2">Claves de proveedor (para importar facturas XML)</summary>
                            <div class="p-3 pt-0 space-y-2">
                                <p class="text-[10px] text-slate-500">Cómo identifica cada proveedor a este producto en sus facturas. Puedes guardar varias.</p>
                                <div class="grid grid-cols-2 gap-2">
                                    <div class="col-span-2">
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Proveedor</label>
                                        <select id="cpProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${opcionesProveedoresHtml}</select>
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Clave del proveedor <span class="text-rose-400">*</span></label>
                                        <input type="text" id="cpClave" placeholder="Su código / No. identificación" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Clave SAT (ClaveProdServ)</label>
                                        <input type="text" id="cpClaveSat" placeholder="Opcional · 8 dígitos" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    </div>
                                    <div class="col-span-2">
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Descripción en la factura</label>
                                        <input type="text" id="cpDescFactura" placeholder="Opcional · texto tal como llega en el XML" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    </div>
                                </div>
                                <button type="button" id="btnAgregarClaveProv" class="w-full bg-slate-800 hover:bg-slate-700 text-sky-300 font-medium py-1.5 rounded-lg text-xs transition">＋ Agregar clave de proveedor</button>
                                <div id="listaClavesProv" class="text-xs text-slate-400 bg-slate-900 p-2 rounded-lg border border-slate-800 min-h-[32px]">Sin claves registradas.</div>
                            </div>
                        </details>

                        <hr class="border-slate-800 my-2">

                        <details id="detBom" class="bg-slate-900/40 border border-slate-800 rounded-lg">
                            <summary class="cursor-pointer select-none text-xs font-semibold text-sky-400 px-3 py-2">Estructura de Componentes / BOM (opcional)</summary>
                            <div class="p-3 pt-0 space-y-2">
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

                                    <button type="button" id="btnAgregarItemBom" class="w-full bg-slate-800 hover:bg-slate-700 text-sky-300 font-medium py-1.5 rounded-lg text-xs transition">＋ Agregar Componente al BOM</button>
                                </div>

                                <div id="listaBomTemporal" class="text-xs text-slate-400 bg-slate-900 p-2 rounded-lg border border-slate-800 min-h-[40px]">
                                    Sin elementos agregados.
                                </div>
                            </div>
                        </details>

                        <button type="submit" id="btnGuardarProd" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Guardar Artículo</button>
                        </form>
                    </div>
                </details>

                <div class="space-y-3">
                    <div class="flex flex-wrap justify-between items-center gap-2">
                        <h3 class="text-md font-semibold text-slate-300">Catálogo General de Artículos</h3>
                        <div class="flex flex-wrap gap-2 items-center">
                            <button type="button" id="btnExportProdXlsx" class="text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">⬇️ Excel</button>
                            <button type="button" id="btnExportProdCsv" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">⬇️ CSV</button>
                            <span class="text-xs bg-slate-900 border border-slate-800 px-2 py-1 rounded text-slate-400">Sincronizado con Supabase</span>
                        </div>
                    </div>
                    <div id="tablaProductosContainer">Cargando listado...</div>
                </div>
            </div>
        `;

        // El "Registro General" arranca plegado (recuerda tu preferencia) para
        // que el Catálogo de abajo se vea completo sin desplazarte. Se abre
        // solo al elegir un artículo existente para editarlo.
        const detRegistro = document.getElementById('detRegistroProducto');
        const chevronRegistro = document.getElementById('detRegistroChevron');
        const LS_FORM_PRODUCTO_ABIERTO = 'hares_catalogo_form_abierto';
        try { detRegistro.open = localStorage.getItem(LS_FORM_PRODUCTO_ABIERTO) === '1'; } catch (_) { /* noop */ }
        chevronRegistro.textContent = detRegistro.open ? '▾ Cerrar' : '▸ Abrir';
        detRegistro.addEventListener('toggle', () => {
            chevronRegistro.textContent = detRegistro.open ? '▾ Cerrar' : '▸ Abrir';
            try { localStorage.setItem(LS_FORM_PRODUCTO_ABIERTO, detRegistro.open ? '1' : '0'); } catch (_) { /* noop */ }
        });

        document.getElementById('btnExportProdCsv').addEventListener('click', () => exportarCatalogoProductos('csv'));
        document.getElementById('btnExportProdXlsx').addEventListener('click', () => exportarCatalogoProductos('xlsx'));

        let itemsBomTemp = [];
        let clavesProvTemp = [];   // claves de proveedor del artículo en edición
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
        const seccionBomContainer = document.getElementById('detBom');

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

        // Botones de tipo (reemplazan visualmente al <select> oculto, que
        // sigue siendo la fuente de verdad para el resto del formulario —
        // así no hay que tocar la lógica de guardar/cargar/BOM de abajo).
        const botonesTipoElemento = document.querySelectorAll('.tipo-elemento-btn');
        function marcarBotonTipoActivo(tipo) {
            botonesTipoElemento.forEach((b) => {
                const activo = b.dataset.tipo === tipo;
                b.className = `tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition ${activo
                    ? 'bg-sky-600 border-sky-500 text-white'
                    : 'bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-800'}`;
            });
        }
        botonesTipoElemento.forEach((b) => {
            b.addEventListener('click', () => {
                selectTipoElemento.value = b.dataset.tipo;
                marcarBotonTipoActivo(b.dataset.tipo);
                selectTipoElemento.dispatchEvent(new Event('change'));
            });
        });
        marcarBotonTipoActivo(selectTipoElemento.value || 'producto');

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
                detRegistro.open = true; // se estaba editando: aseguramos que el formulario se vea

                await actualizarSelectProveedores();

                const { data: art, error: errA } = await supabaseClient
                    .from('productos')
                    .select('*')
                    .eq('id', id)
                    .single();

                if (errA) throw errA;

                productoSeleccionadoId = art.id;
                selectTipoElemento.value = art.tipo || 'producto';
                marcarBotonTipoActivo(art.tipo || 'producto');
                inputNombre.value = art.nombre;
                document.getElementById('prodSku').value = art.sku || '';
                document.getElementById('prodUnidadMedidaId').value = art.unidad_medida_id || '';
                document.getElementById('prodCosto').value = art.costo_unitario || 0;
                document.getElementById('prodPrecioVenta').value = art.precio_venta ?? '';
                document.getElementById('prodStockMinimo').value = art.stock_minimo || 0;
                document.getElementById('prodTiempoEntrega').value = art.tiempo_entrega_dias ?? '';
                document.getElementById('prodCantidadMinimaCompra').value = art.cantidad_minima_compra ?? '';

                const elExistencia = document.getElementById('prodExistenciaActual');
                elExistencia.textContent = `Existencia actual: ${Number(art.stock_actual || 0).toLocaleString('es-MX', { maximumFractionDigits: 4 })} — se actualiza sola con compras y salidas, no se edita aquí.`;
                elExistencia.classList.remove('hidden');

                // Asignación directa y robusta del ID de la moneda mapeada en la BD
                const selectMoneda = document.getElementById('prodMonedaId');
                selectMoneda.value = art.moneda_id ? art.moneda_id : "";

                document.getElementById('prodProveedorId').value = art.proveedor_id || '';
                document.getElementById('prodDesc').value = art.descripcion || '';
                document.getElementById('prodRequiereCaducidad').checked = !!art.requiere_caducidad;

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
                                unidadNombre: mapaUnidades[b.unidad_medida] || ''
                            });
                        });
                        seccionBomContainer.open = true;   // ya tiene componentes: mostrarlos
                    }
                    actualizarListaBomVisual();
                } else {
                    seccionBomContainer.classList.add('hidden');
                }

                // Claves de proveedor (degrada si la tabla aún no existe)
                clavesProvTemp = [];
                try {
                    const { data: cps, error: errCps } = await supabaseClient
                        .from('producto_claves_proveedor')
                        .select('proveedor_id, clave, clave_sat, descripcion_factura')
                        .eq('producto_id', id);
                    if (!errCps && cps) {
                        const mapProv = new Map((listaProveedores || []).map(p => [p.id, p.nombre]));
                        clavesProvTemp = cps.map(c => ({
                            proveedorId: c.proveedor_id,
                            proveedorNombre: mapProv.get(c.proveedor_id) || '',
                            clave: c.clave,
                            claveSat: c.clave_sat || '',
                            descFactura: c.descripcion_factura || '',
                        }));
                    }
                } catch (_) { clavesProvTemp = []; }
                renderClavesProv();
                const detCp = document.getElementById('detClavesProv');
                if (detCp) detCp.open = clavesProvTemp.length > 0;

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
            clavesProvTemp = [];
            renderClavesProv();
            document.getElementById('detClavesProv')?.removeAttribute('open');
            seccionBomContainer.classList.remove('hidden');
            selectTipoElemento.value = 'producto';
            marcarBotonTipoActivo('producto');
            document.getElementById('prodExistenciaActual').classList.add('hidden');
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
                    <span>${item.componenteNombre} - <strong>${item.cantidad} ${item.unidadNombre || ''}</strong></span>
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

            if (cantidad <= 0) {
                alert("Ingrese una cantidad mayor a 0.");
                return;
            }

            itemsBomTemp.push({
                componenteId,
                componenteNombre: nombreInsumo,
                cantidad,
                unidadId,
                unidadNombre
            });

            actualizarListaBomVisual();

            document.getElementById('bomCantidad').value = '';
            insumoSelect.value = '';
            unidadSelect.value = '';
        });

        window.removerItemBom = function(index) {
            itemsBomTemp.splice(index, 1);
            actualizarListaBomVisual();
        };

        // ---- Claves de proveedor (una a varias por producto) ----
        function renderClavesProv() {
            const cont = document.getElementById('listaClavesProv');
            if (!cont) return;
            if (!clavesProvTemp.length) { cont.innerHTML = 'Sin claves registradas.'; return; }
            cont.innerHTML = clavesProvTemp.map((c, i) => `
                <div class="flex justify-between items-start gap-2 py-1 border-b border-slate-800 last:border-0">
                    <span class="text-[11px]">
                        <span class="font-mono text-sky-300">${escaparHtml(c.clave)}</span>
                        <span class="text-slate-500"> · ${escaparHtml(c.proveedorNombre || 'sin proveedor')}</span>
                        ${c.claveSat ? `<span class="text-slate-500"> · SAT ${escaparHtml(c.claveSat)}</span>` : ''}
                        ${c.descFactura ? `<span class="text-slate-500 block">"${escaparHtml(c.descFactura)}"</span>` : ''}
                    </span>
                    <button type="button" onclick="window.removerClaveProv(${i})" class="text-red-400 hover:text-red-300 text-xs shrink-0">Eliminar</button>
                </div>`).join('');
        }

        window.removerClaveProv = function(i) {
            clavesProvTemp.splice(i, 1);
            renderClavesProv();
        };

        const btnAddClaveProv = document.getElementById('btnAgregarClaveProv');
        if (btnAddClaveProv) {
            btnAddClaveProv.addEventListener('click', () => {
                const selProv = document.getElementById('cpProveedor');
                const clave = document.getElementById('cpClave').value.trim();
                if (!clave) { alert('Escribe la clave del proveedor.'); return; }
                const proveedorId = selProv.value ? parseInt(selProv.value) : null;
                const proveedorNombre = selProv.value ? (selProv.options[selProv.selectedIndex]?.text || '') : '';
                const dup = clavesProvTemp.some(c =>
                    (c.proveedorId || null) === proveedorId && c.clave.toLowerCase() === clave.toLowerCase());
                if (dup) { alert('Esa clave ya está en la lista para ese proveedor.'); return; }
                clavesProvTemp.push({
                    proveedorId,
                    proveedorNombre,
                    clave,
                    claveSat: document.getElementById('cpClaveSat').value.trim(),
                    descFactura: document.getElementById('cpDescFactura').value.trim(),
                });
                renderClavesProv();
                document.getElementById('cpClave').value = '';
                document.getElementById('cpClaveSat').value = '';
                document.getElementById('cpDescFactura').value = '';
            });
        }

        const formProducto = document.getElementById('formCrearProducto');
        formProducto.addEventListener('submit', async (e) => {
            e.preventDefault();
            const tipo = selectTipoElemento.value;
            const nombre = inputNombre.value.trim();
            const sku = document.getElementById('prodSku').value.trim();
            const unidadMedidaIdVal = document.getElementById('prodUnidadMedidaId').value;
            const unidad_medida_id = unidadMedidaIdVal ? parseInt(unidadMedidaIdVal) : null;
            const costoUnitario = parseFloat(document.getElementById('prodCosto').value) || 0;
            const precioVentaVal = document.getElementById('prodPrecioVenta').value;
            const precio_venta = precioVentaVal === '' ? null : Math.max(0, parseFloat(precioVentaVal) || 0);
            const monedaIdVal = document.getElementById('prodMonedaId').value;
            const moneda_id = monedaIdVal ? parseInt(monedaIdVal) : null;
            const proveedorIdVal = document.getElementById('prodProveedorId').value;
            const proveedor_id = proveedorIdVal ? parseInt(proveedorIdVal) : null;
            const descripcion = document.getElementById('prodDesc').value.trim();
            const stock_minimo = Math.max(0, parseFloat(document.getElementById('prodStockMinimo').value) || 0);
            const tiempoEntregaVal = document.getElementById('prodTiempoEntrega').value;
            const tiempo_entrega_dias = tiempoEntregaVal === '' ? null : parseInt(tiempoEntregaVal);
            const cantidadMinimaVal = document.getElementById('prodCantidadMinimaCompra').value;
            const cantidad_minima_compra = cantidadMinimaVal === '' ? null : parseFloat(cantidadMinimaVal);

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
            if (!sku) {
                alert("El SKU / Código es obligatorio. No se puede registrar un artículo sin SKU.");
                document.getElementById('prodSku').focus();
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
                    precio_venta,
                    moneda_id,
                    proveedor_id,
                    descripcion: descripcion || null,
                    stock_minimo,
                    tiempo_entrega_dias,
                    cantidad_minima_compra,
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
                        unidad_medida: i.unidadId ? i.unidadId.toString() : null
                    }));

                    const { error: errB } = await supabaseClient.from('bom').insert(itemsBom);
                    if (errB) throw errB;
                }

                // Claves de proveedor: se reescriben (borrar + insertar).
                // Degrada sin romper el alta si la tabla aún no existe.
                try {
                    await supabaseClient.from('producto_claves_proveedor').delete().eq('producto_id', articuloId);
                    if (clavesProvTemp.length > 0) {
                        const filasCp = clavesProvTemp.map(c => ({
                            producto_id: articuloId,
                            proveedor_id: c.proveedorId || null,
                            clave: c.clave,
                            clave_sat: c.claveSat || null,
                            descripcion_factura: c.descFactura || null,
                        }));
                        const { error: errCp } = await supabaseClient.from('producto_claves_proveedor').insert(filasCp);
                        if (errCp) throw errCp;
                    }
                } catch (errCp) {
                    const m = errCp?.message || String(errCp);
                    if (/does not exist|schema cache|could not find/i.test(m)) {
                        alert('Aviso: falta correr el SQL de "claves de proveedor". El artículo se guardó, pero sus claves no.');
                    } else {
                        throw errCp;
                    }
                }

                // Bandera de caducidad (best-effort: se ignora si falta el SQL)
                await supabaseClient.from('productos')
                    .update({ requiere_caducidad: document.getElementById('prodRequiereCaducidad').checked })
                    .eq('id', articuloId);

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

// =====================================================================
// Reporteador: exporta TODOS los productos con todas sus columnas
// (más las llaves foráneas resueltas a nombre) a CSV o Excel.
// =====================================================================

function _csvCelda(v) {
    if (v === null || v === undefined) return '';
    const s = String(v);
    return /[",\n;]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

async function exportarCatalogoProductos(formato) {
    const btns = ['btnExportProdCsv', 'btnExportProdXlsx'].map((id) => document.getElementById(id));
    btns.forEach((b) => { if (b) b.disabled = true; });
    try {
        const [prod, prov, um, mon, ctas] = await Promise.all([
            supabaseClient.from('productos').select('*').order('id', { ascending: true }),
            supabaseClient.from('proveedores').select('id, nombre'),
            supabaseClient.from('unidades_medida').select('id, nombre'),
            supabaseClient.from('monedas').select('id, codigo'),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre'),
        ]);
        if (prod.error) throw prod.error;
        const filas = prod.data || [];
        if (!filas.length) { alert('No hay productos para exportar.'); return; }

        const mProv = new Map((prov.data || []).map((x) => [x.id, x.nombre]));
        const mUm = new Map((um.data || []).map((x) => [x.id, x.nombre]));
        const mMon = new Map((mon.data || []).map((x) => [x.id, x.codigo]));
        const mCta = new Map((ctas.data || []).map((x) => [x.id, `${x.codigo} · ${x.nombre}`]));

        // Cada fila: columnas crudas + columnas legibles de las FK.
        const registros = filas.map((p) => ({
            ...p,
            proveedor: mProv.get(p.proveedor_id) || '',
            unidad: mUm.get(p.unidad_medida_id) || '',
            moneda: mMon.get(p.moneda_id) || '',
            cuenta_inventario: mCta.get(p.cuenta_inventario_id) || '',
            cuenta_costo: mCta.get(p.cuenta_costo_id) || '',
        }));

        // Orden de columnas: primero las "legibles/útiles", luego el resto alfabético.
        const preferidas = [
            'id', 'sku', 'nombre', 'tipo', 'descripcion',
            'unidad', 'unidad_medida_id', 'costo_unitario', 'precio_venta',
            'moneda', 'moneda_id', 'proveedor', 'proveedor_id',
            'stock_actual', 'stock_minimo', 'tiempo_entrega_dias', 'cantidad_minima_compra',
            'tasa_iva', 'tasa_ieps',
            'cuenta_inventario', 'cuenta_inventario_id', 'cuenta_costo', 'cuenta_costo_id',
            'activo', 'created_at',
        ];
        const todas = new Set();
        registros.forEach((r) => Object.keys(r).forEach((k) => todas.add(k)));
        const columnas = [
            ...preferidas.filter((c) => todas.has(c)),
            ...[...todas].filter((c) => !preferidas.includes(c)).sort(),
        ];

        const stamp = new Date().toISOString().slice(0, 10);
        const nombreArchivo = `catalogo_productos_${stamp}`;

        if (formato === 'xlsx') {
            const XLSX = await import('https://cdn.sheetjs.com/xlsx-0.20.3/package/xlsx.mjs');
            const aoa = [columnas, ...registros.map((r) => columnas.map((c) => r[c] ?? ''))];
            const ws = XLSX.utils.aoa_to_sheet(aoa);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Productos');
            XLSX.writeFile(wb, `${nombreArchivo}.xlsx`);
        } else {
            const lineas = [columnas.map(_csvCelda).join(',')];
            registros.forEach((r) => lineas.push(columnas.map((c) => _csvCelda(r[c])).join(',')));
            const csv = '﻿' + lineas.join('\r\n');
            const a = document.createElement('a');
            a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8;' }));
            a.download = `${nombreArchivo}.csv`;
            document.body.appendChild(a); a.click(); a.remove();
            setTimeout(() => URL.revokeObjectURL(a.href), 1000);
        }
    } catch (err) {
        console.error('Error al exportar catálogo:', err);
        alert('No se pudo exportar: ' + (err.message || err));
    } finally {
        btns.forEach((b) => { if (b) b.disabled = false; });
    }
}

async function renderizarTablaProductos(mapaUnidades = {}) {
    const contenedorTabla = document.getElementById('tablaProductosContainer');
    if (!contenedorTabla) return;

    try {
        const [resProd, resProv] = await Promise.all([
            supabaseClient.from('productos').select('id, nombre, sku, tipo, unidad_medida_id, proveedor_id, stock_actual, stock_minimo, activo').order('id', { ascending: true }),
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
                            <th class="p-3 text-right">Existencia</th>
                            <th class="p-3">Estado</th>
                            <th class="p-3 text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        const mapaProductosPorId = {};
        productosData.forEach((p) => { mapaProductosPorId[p.id] = p; });

        const OPCIONES_TIPO = [
            { v: 'producto', t: 'Producto terminado' },
            { v: 'materia_prima', t: 'Materia prima' },
            { v: 'insumo', t: 'Insumo' },
        ];

        productosData.forEach(item => {
            const tipoActual = item.tipo || 'producto';
            let tipoColor = "text-sky-400 border-sky-800";
            if (tipoActual === 'materia_prima') tipoColor = "text-amber-400 border-amber-800";
            if (tipoActual === 'insumo') tipoColor = "text-emerald-400 border-emerald-800";

            const nombreProveedor = mapaProvNombres[item.proveedor_id] || 'N/D';
            const nombreUnidad = mapaUnidades[item.unidad_medida_id] || 'N/D';
            const activo = item.activo !== false;
            const stockActual = Number(item.stock_actual || 0);
            const stockMinimo = Number(item.stock_minimo || 0);
            const stockBajo = stockMinimo > 0 && stockActual < stockMinimo;

            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition ${activo ? '' : 'opacity-50'}">
                    <td class="p-3 font-mono text-xs text-sky-300">${item.sku || 'N/D'}</td>
                    <td class="p-3">
                        <select class="sel-tipo-prod bg-slate-950 border ${tipoColor} rounded px-1.5 py-0.5 text-[10px] font-medium cursor-pointer focus:outline-none focus:border-sky-500" data-id="${item.id}" title="Cambiar categoría">
                            ${OPCIONES_TIPO.map(o => `<option value="${o.v}" ${o.v === tipoActual ? 'selected' : ''}>${o.t}</option>`).join('')}
                        </select>
                    </td>
                    <td class="p-3 font-medium text-slate-100">${item.nombre || 'Sin nombre'}</td>
                    <td class="p-3 text-slate-400 text-xs">${nombreUnidad}</td>
                    <td class="p-3 text-slate-300 text-xs">${nombreProveedor}</td>
                    <td class="p-3 text-right font-mono text-xs ${stockBajo ? 'text-rose-400 font-semibold' : 'text-slate-300'}" title="${stockBajo ? 'Por debajo del stock mínimo (' + stockMinimo + ')' : ''}">${stockActual.toLocaleString('es-MX', { maximumFractionDigits: 4 })}${stockBajo ? ' ⚠' : ''}</td>
                    <td class="p-3">
                        <button type="button" class="btn-toggle-activo-prod text-[10px] px-2 py-0.5 rounded border cursor-pointer ${activo ? 'bg-emerald-950 text-emerald-400 border-emerald-800' : 'bg-slate-800 text-slate-400 border-slate-700'}" data-id="${item.id}" data-activo="${activo}">${activo ? 'Activo' : 'Inactivo'}</button>
                    </td>
                    <td class="p-3 text-center">
                        <button type="button" class="btn-menu-prod text-slate-400 hover:text-slate-100 hover:bg-slate-800 rounded px-2 py-1 cursor-pointer" data-id="${item.id}" title="Más acciones">☰</button>
                    </td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorTabla.innerHTML = html;

        contenedorTabla.querySelectorAll('.btn-toggle-activo-prod').forEach((btn) => {
            btn.addEventListener('click', async () => {
                const nuevoEstado = btn.dataset.activo !== 'true';
                const { error } = await supabaseClient.from('productos').update({ activo: nuevoEstado }).eq('id', Number(btn.dataset.id));
                if (error) { alert('No se pudo cambiar el estado: ' + error.message); return; }
                await renderizarTablaProductos(mapaUnidades);
            });
        });

        contenedorTabla.querySelectorAll('.sel-tipo-prod').forEach((sel) => {
            sel.addEventListener('change', async () => {
                const producto = mapaProductosPorId[Number(sel.dataset.id)];
                if (!producto) return;
                const aplicado = await cambiarCategoriaProducto(producto, sel.value, mapaUnidades);
                if (!aplicado) sel.value = producto.tipo || 'producto'; // cancelado: revertir
            });
        });

        contenedorTabla.querySelectorAll('.btn-menu-prod').forEach((btn) => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const producto = mapaProductosPorId[Number(btn.dataset.id)];
                if (producto) abrirMenuAccionesProducto(producto, btn);
            });
        });

    } catch (err) {
        console.error("Error al consultar el catálogo:", err);
        contenedorTabla.innerHTML = `<p class="text-red-400 text-sm">Error al consultar la tabla de productos: ${err.message || err}</p>`;
    }
}

// =====================================================================
// Menú de acciones por artículo (☰): atajos útiles que no ameritan su
// propio botón fijo en la tabla. Se posiciona con coordenadas fijas
// (no absolute dentro de la tabla) para que nunca quede recortado por
// el overflow-x-auto del contenedor.
// =====================================================================

const CAMPOS_NO_EDITABLES_PRODUCTO = new Set(['id', 'created_at', 'updated_at']);

function cerrarMenuAccionesProducto() {
    document.getElementById('menuAccionesProducto')?.remove();
    document.removeEventListener('click', cerrarMenuAccionesProducto);
    document.removeEventListener('keydown', cerrarMenuAccionesProductoEsc);
}

function cerrarMenuAccionesProductoEsc(e) {
    if (e.key === 'Escape') cerrarMenuAccionesProducto();
}

function abrirMenuAccionesProducto(producto, botonAncla) {
    cerrarMenuAccionesProducto();

    const rect = botonAncla.getBoundingClientRect();
    const menu = document.createElement('div');
    menu.id = 'menuAccionesProducto';
    menu.className = 'fixed z-50 bg-slate-900 border border-slate-700 rounded-lg shadow-2xl text-xs overflow-hidden w-56';
    menu.style.top = `${rect.bottom + 4}px`;
    menu.style.left = `${Math.max(8, rect.right - 224)}px`;

    menu.innerHTML = `
        <button type="button" id="btnMenuProdKardex" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 flex items-center gap-2 cursor-pointer">
            <span>📦</span><span>Kardex de este producto</span>
        </button>
        <button type="button" id="btnMenuProdResumen" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 border-t border-slate-800 flex items-center gap-2 cursor-pointer">
            <span>📋</span><span>Resumen completo (editable)</span>
        </button>
    `;
    document.body.appendChild(menu);

    document.getElementById('btnMenuProdKardex').addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        irAKardexDeProducto(producto.id, producto.nombre);
    });
    document.getElementById('btnMenuProdResumen').addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        abrirResumenCompletoProducto(producto.id);
    });

    // Cerrar al hacer clic afuera o con Escape; se difiere un tick para
    // que no capture el mismo clic que acaba de abrir el menú.
    setTimeout(() => {
        document.addEventListener('click', cerrarMenuAccionesProducto);
        document.addEventListener('keydown', cerrarMenuAccionesProductoEsc);
    }, 0);
}

// =====================================================================
// "Resumen completo (editable)": muestra y permite editar TODAS las
// columnas de productos para un artículo, incluidas las que el
// formulario simplificado de arriba no expone. Es una escotilla de
// escape deliberada — el formulario de alta se mantiene simple a
// propósito, pero aquí se puede tocar cualquier campo si hace falta.
// =====================================================================

function tipoDeCampo(valor) {
    if (typeof valor === 'boolean') return 'boolean';
    if (typeof valor === 'number') return 'number';
    return 'text';
}

function etiquetaCampo(clave) {
    return clave.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

const ETIQUETA_TIPO_PRODUCTO = {
    producto: 'Producto terminado',
    materia_prima: 'Materia prima',
    insumo: 'Insumo / componente',
};

// Reclasifica el articulo (productos.tipo). Devuelve true si se aplico el cambio.
async function cambiarCategoriaProducto(producto, nuevoTipo, mapaUnidades) {
    if (nuevoTipo === producto.tipo) return false;
    let aviso = '';
    if (producto.tipo === 'producto' && nuevoTipo !== 'producto') {
        aviso = '\n\nOjo: si tenía receta (BOM), dejará de usarse mientras no vuelva a ser "Producto terminado".';
    }
    if (!confirm(`¿Cambiar "${producto.nombre}" de ${ETIQUETA_TIPO_PRODUCTO[producto.tipo] || producto.tipo} a ${ETIQUETA_TIPO_PRODUCTO[nuevoTipo]}?${aviso}`)) return false;
    const { error } = await supabaseClient.from('productos').update({ tipo: nuevoTipo }).eq('id', producto.id);
    if (error) { alert('No se pudo cambiar la categoría: ' + (error.message || error)); return false; }
    let mapa = mapaUnidades;
    if (!mapa) {
        const { data: um } = await supabaseClient.from('unidades_medida').select('id, nombre');
        mapa = {};
        (um || []).forEach((u) => { mapa[u.id] = u.nombre; });
    }
    await renderizarTablaProductos(mapa);
    return true;
}

function escaparHtml(valor) {
    return String(valor).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// Arma un <option>...</option> con el registro actualmente seleccionado
// marcado — usado para que las llaves foráneas (proveedor_id, moneda_id,
// etc.) se vean y editen por nombre, no por su número interno.
function construirOpcionesSelector(lista, valorActual, textoFn, etiquetaVacio) {
    const esVacio = valorActual === null || valorActual === undefined || valorActual === '';
    let html = `<option value="" ${esVacio ? 'selected' : ''}>${etiquetaVacio}</option>`;
    (lista || []).forEach((r) => {
        const seleccionado = String(r.id) === String(valorActual) ? 'selected' : '';
        html += `<option value="${r.id}" ${seleccionado}>${escaparHtml(textoFn(r))}</option>`;
    });
    return html;
}

async function abrirResumenCompletoProducto(id) {
    let modal = document.getElementById('modalResumenProducto');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'modalResumenProducto';
        modal.className = 'fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-sm p-4';
        document.body.appendChild(modal);
    }
    modal.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
            <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-center">
                <h3 class="text-sm font-bold text-slate-200">Resumen completo del artículo</h3>
                <button type="button" id="btnCerrarResumenProd" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer">&times;</button>
            </div>
            <div id="cuerpoResumenProd" class="p-5 overflow-y-auto flex-1 text-sm text-slate-300">Cargando…</div>
            <div class="bg-slate-950 px-5 py-3 border-t border-slate-800 flex justify-end gap-2">
                <button type="button" id="btnCancelarResumenProd" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Cerrar</button>
                <button type="button" id="btnGuardarResumenProd" class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Guardar cambios</button>
            </div>
        </div>
    `;
    modal.classList.remove('hidden');

    const cerrar = () => modal.remove();
    document.getElementById('btnCerrarResumenProd').addEventListener('click', cerrar);
    document.getElementById('btnCancelarResumenProd').addEventListener('click', cerrar);
    modal.addEventListener('click', (e) => { if (e.target === modal) cerrar(); });

    const cuerpo = document.getElementById('cuerpoResumenProd');
    try {
        const [{ data: art, error }, resProv, resMon, resUm, resCta] = await Promise.all([
            supabaseClient.from('productos').select('*').eq('id', id).single(),
            supabaseClient.from('proveedores').select('id, nombre').order('nombre', { ascending: true }),
            supabaseClient.from('monedas').select('id, codigo').order('id', { ascending: true }),
            supabaseClient.from('unidades_medida').select('id, nombre').order('id', { ascending: true }),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre').order('codigo', { ascending: true }),
        ]);
        if (error) throw error;

        // Llaves foráneas conocidas: se muestran y editan como <select> por
        // nombre, no como el número interno. Cualquier otra columna que
        // termine en _id (o que se agregue a futuro) cae al input numérico
        // genérico de abajo.
        const opcionesPorCampo = {
            proveedor_id: construirOpcionesSelector(resProv.data, art.proveedor_id, (r) => r.nombre, '(sin proveedor)'),
            moneda_id: construirOpcionesSelector(resMon.data, art.moneda_id, (r) => r.codigo, '(sin moneda)'),
            unidad_medida_id: construirOpcionesSelector(resUm.data, art.unidad_medida_id, (r) => r.nombre, '(sin unidad)'),
            cuenta_inventario_id: construirOpcionesSelector(resCta.data, art.cuenta_inventario_id, (r) => `${r.codigo} · ${r.nombre}`, '(sin cuenta)'),
            cuenta_costo_id: construirOpcionesSelector(resCta.data, art.cuenta_costo_id, (r) => `${r.codigo} · ${r.nombre}`, '(sin cuenta)'),
        };

        const claves = Object.keys(art).sort();
        cuerpo.innerHTML = `
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                ${claves.map((clave) => {
                    const valor = art[clave];
                    const soloLectura = CAMPOS_NO_EDITABLES_PRODUCTO.has(clave);
                    const tipo = tipoDeCampo(valor);

                    if (soloLectura) {
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-500 mb-1">${etiquetaCampo(clave)}</label>
                                <p class="text-xs font-mono text-slate-400 bg-slate-950/60 border border-slate-800 rounded-lg px-2 py-1.5">${escaparHtml(valor ?? '—')}</p>
                            </div>`;
                    }
                    if (clave === 'tipo') {
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                                <select id="rc_${clave}" data-campo="${clave}" data-tipo="text" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    <option value="producto" ${valor === 'producto' ? 'selected' : ''}>Producto terminado</option>
                                    <option value="materia_prima" ${valor === 'materia_prima' ? 'selected' : ''}>Materia prima</option>
                                    <option value="insumo" ${valor === 'insumo' ? 'selected' : ''}>Insumo</option>
                                </select>
                            </div>`;
                    }
                    if (opcionesPorCampo[clave]) {
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                                <select id="rc_${clave}" data-campo="${clave}" data-tipo="number" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    ${opcionesPorCampo[clave]}
                                </select>
                            </div>`;
                    }
                    if (tipo === 'boolean') {
                        return `
                            <div class="flex items-center gap-2 pt-4">
                                <input type="checkbox" id="rc_${clave}" data-campo="${clave}" data-tipo="boolean" class="campo-resumen-prod w-4 h-4" ${valor ? 'checked' : ''}>
                                <label for="rc_${clave}" class="text-xs text-slate-300">${etiquetaCampo(clave)}</label>
                            </div>`;
                    }
                    return `
                        <div>
                            <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                            <input type="${tipo === 'number' ? 'number' : 'text'}" ${tipo === 'number' ? 'step="any"' : ''} id="rc_${clave}" data-campo="${clave}" data-tipo="${tipo}" value="${escaparHtml(valor ?? '')}" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                        </div>`;
                }).join('')}
            </div>`;
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">No se pudo cargar el artículo: ${err.message || err}</p>`;
        return;
    }

    document.getElementById('btnGuardarResumenProd').addEventListener('click', async () => {
        const payload = {};
        cuerpo.querySelectorAll('.campo-resumen-prod').forEach((input) => {
            const clave = input.dataset.campo;
            if (input.dataset.tipo === 'boolean') {
                payload[clave] = input.checked;
            } else if (input.dataset.tipo === 'number') {
                payload[clave] = input.value === '' ? null : Number(input.value);
            } else {
                payload[clave] = input.value === '' ? null : input.value;
            }
        });

        const btnGuardar = document.getElementById('btnGuardarResumenProd');
        btnGuardar.disabled = true;
        btnGuardar.textContent = 'Guardando…';
        const { error } = await supabaseClient.from('productos').update(payload).eq('id', id);
        if (error) {
            alert('No se pudo guardar: ' + error.message);
            btnGuardar.disabled = false;
            btnGuardar.textContent = 'Guardar cambios';
            return;
        }
        cerrar();
        const { data: mapaUnidadesActual } = await supabaseClient.from('unidades_medida').select('id, nombre');
        const mapaUnidades = {};
        (mapaUnidadesActual || []).forEach((u) => { mapaUnidades[u.id] = u.nombre; });
        await renderizarTablaProductos(mapaUnidades);
    });
}