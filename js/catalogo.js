import { supabaseClient } from './supabase.js';
import { renderizarKardexProducto } from './kardex.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { factorConversion, tamanoTeoricoTanda, familiaDeUnidad } from './conversion-unidades.js';
import { opcionesPresentacionHtml } from './presentaciones-proveedor.js';

let catBusqueda = ''; // texto del buscador en vivo del Catálogo General (SKU y/o nombre)
const catOrden = crearOrdenTabla('nombre', 'asc'); // ordenamiento de la tabla del Catálogo: alfabético por Nombre por defecto (clic en otra columna lo cambia)

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

// Alta de artículo: SOLO el formulario (crear, o editar si el nombre coincide con uno
// existente), sin el listado de abajo — pantalla dedicada para no distraer con la tabla
// mientras se está capturando (ver "Catálogo y Kardex" para el listado general).
export async function cargarModuloAltaArticulo() {
    const contenedor = document.getElementById('contenedorAltaArticulo');
    if (!contenedor) {
        console.error("No se encontró el elemento #contenedorAltaArticulo en el DOM.");
        return;
    }

    try {
        if (!supabaseClient) throw new Error("Cliente Supabase no disponible.");

        contenedor.innerHTML = `<p class="text-slate-400 text-sm p-4">Cargando formulario...</p>`;

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
                        <span id="tituloFormProducto" class="text-md font-semibold text-sky-400">Alta de productos</span>
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
                                <option value="semiterminado">Semiterminado (granel)</option>
                                <option value="materia_prima">Materia Prima</option>
                                <option value="insumo">Insumo / Componente Auxiliar</option>
                            </select>
                            <div id="tipoElementoBotones" class="grid grid-cols-1 sm:grid-cols-4 gap-1.5">
                                <button type="button" data-tipo="producto" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Producto terminado</button>
                                <button type="button" data-tipo="semiterminado" title="Se fabrica y se usa como componente de otros productos (ej. granel). Un granel se da de alta aquí, con Unidad de Medida en Litros o Kilogramos." class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Semiterminado</button>
                                <button type="button" data-tipo="materia_prima" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Materia prima</button>
                                <button type="button" data-tipo="insumo" class="tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition">Insumo</button>
                            </div>
                        </div>

                        <div id="bloqueAbastecimiento" class="rounded-lg border border-slate-800 bg-slate-900/40 p-2.5 space-y-2">
                            <div>
                                <label class="block text-[11px] text-slate-400 mb-1">¿Cómo se obtiene?</label>
                                <input type="hidden" id="prodAbastecimiento" value="fabricado">
                                <div class="grid grid-cols-1 sm:grid-cols-2 gap-1.5">
                                    <button type="button" data-abast="fabricado" class="abast-btn text-xs font-medium py-2 rounded-lg border transition">Lo fabrico (lleva BOM)</button>
                                    <button type="button" data-abast="comprado" class="abast-btn text-xs font-medium py-2 rounded-lg border transition">Lo compro y lo revendo (sin BOM)</button>
                                </div>
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
                                <label class="block text-[11px] text-slate-400 mb-1" title="La unidad en que se cuenta en almacén y en que se descuenta. Un granel va en Litros (o Kilogramos), nunca en Pieza: así el producto terminado le descuenta mL o g.">Unidad de Medida <span class="text-slate-500 cursor-help">ⓘ</span></label>
                                <select id="prodUnidadMedidaId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100" required title="La unidad en que se cuenta en almacén y en que se descuenta. Un granel va en Litros (o Kilogramos), nunca en Pieza.">
                                    ${opcionesUnidades}
                                </select>
                                <p class="text-[10px] text-slate-500 mt-0.5">Granel: Litros o Kilogramos, nunca Pieza.</p>
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

                        <label id="bloqueProdCaducidad" class="flex items-start gap-2 text-xs text-slate-300 bg-slate-900/40 border border-slate-800 rounded-lg px-3 py-2">
                            <input type="checkbox" id="prodRequiereCaducidad" class="accent-emerald-500 w-4 h-4 mt-0.5 shrink-0">
                            <span>Requiere control de <strong>caducidad</strong> — al recibir cada lote se pedirá la fecha de vencimiento y ese lote entrará a las alertas de caducidad. Déjalo sin marcar para materias primas / insumos que no caducan.</span>
                        </label>

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

                                <div>
                                    <label class="block text-[11px] text-slate-400 mb-1">Clave SAT (ClaveProdServ)</label>
                                    <input type="text" id="prodClaveSat" inputmode="numeric" maxlength="8" placeholder="8 dígitos del catálogo c_ClaveProdServ" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    <p class="text-[10px] text-slate-500 mt-0.5">La del producto en sí. También se llena sola al importar facturas XML de tus proveedores.</p>
                                </div>

                                <div id="bloqueProdDensidad">
                                    <label class="block text-[11px] text-slate-400 mb-1">Densidad (kg por litro)</label>
                                    <input type="number" step="0.0001" min="0" id="prodDensidad" placeholder="Ej. 1.26 (déjalo vacío si no aplica)" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    <p class="text-[10px] text-slate-500 mt-0.5">Solo para insumos cuya fórmula (BOM) está en volumen (Litros/mL) pero se llevan en inventario por peso (Kilogramos/gramos), o al revés. Con ella, Producción convierte bien cuánto pedir y descontar; sin ella, se toma como agua (1 kg/L) y se avisa. Ej.: Glicerina Vegetal Usp = 1.26 (la fórmula dice 13.7 L y se descuentan 17.262 kg). <b class="text-slate-400">En un granel se calcula sola</b> con su fórmula (densidad de la mezcla) al capturar el BOM; si la cambias a mano, se respeta.</p>
                                </div>

                                <div id="bloqueProdRendimientoLote">
                                    <label class="block text-[11px] text-slate-400 mb-1">Rendimiento del lote (para el BOM)</label>
                                    <input type="number" step="0.0001" min="0" id="prodRendimientoLote" placeholder="Déjalo vacío si el BOM ya está por 1 unidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    <p class="text-[10px] text-slate-500 mt-0.5"><b class="text-slate-400">Para graneles:</b> cuántos Litros (o Kilos, según la Unidad de Medida de arriba) salen de UNA tanda de la fórmula del BOM — lo que mides en el tanque al terminar. Ej.: Granel Aceite Sey Fresa Kiwi → <b>15</b>. Luego en Producción, "CANTIDAD A PRODUCIR" va en esa misma unidad: 15 = 1 tanda, 30 = 2 tandas, 7.5 = media. Vacío = el BOM está escrito para 1 unidad (ej. 1 pieza de producto terminado); si dejas vacío un granel cuya fórmula es de tanda, Producción pide los insumos multiplicados de más.</p>
                                    <p class="text-[10px] text-slate-500 mt-1"><b class="text-slate-400">¿Por qué importa si la materia prima ya se descuenta a su costo real?</b> La fórmula decide cuánto se <b>gasta</b> en la tanda; el rendimiento decide <b>entre cuántos litros</b> se reparte ese gasto y cuántos litros dice el sistema que hay. Ej.: tanda de $1,000 → con 15 L el litro cuesta $66.67 y cada tanda deja 0.36 L que no existen; con 14.64 L cuesta $68.31 (el real). Un número inflado da inventario fantasma y un costo del terminado más bajo que el real (<a href="manual-costos-produccion.html#m-granel-rendimiento" target="_blank" class="text-sky-400 underline">ver manual</a>).</p>
                                </div>

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
                                <p class="text-[10px] text-slate-500">Cómo identifica y vende cada proveedor este producto — su código, descripción y presentación. Puedes guardar varias, una por proveedor. La Clave SAT no se vuelve a pedir: si la dejas vacía, usa la de arriba; solo escríbela aparte si ese proveedor la reporta distinta en su factura.</p>
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
                                        <input type="text" id="cpClaveSat" placeholder="Vacío = igual a la del producto (arriba)" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    </div>
                                    <div class="col-span-2">
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Descripción en la factura</label>
                                        <input type="text" id="cpDescFactura" placeholder="Opcional · texto tal como llega en el XML" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Unidad de venta del proveedor</label>
                                        <select id="cpUnidadPreset" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                            <option value="">Otra / escribir abajo…</option>
                                            ${opcionesPresentacionHtml()}
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Factor (unidades internas por unidad del proveedor)</label>
                                        <input type="number" step="any" min="0.0001" id="cpFactor" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                                    </div>
                                    <div class="col-span-2">
                                        <label class="block text-[10px] text-slate-400 mb-0.5">Unidad (texto, si elegiste "Otra")</label>
                                        <input type="text" id="cpUnidadTexto" placeholder="Ej. Rollo 500 m" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    </div>
                                </div>
                                <p class="text-[10px] text-slate-500">Ej. el proveedor vende por "Millar" y tú le das entrada en piezas: elige el preset Millar — el factor (1000) queda listo para cuando conviertas la recepción en Recibo de mercancía.</p>
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
                                <div id="analisisTandaForm" class="hidden mt-2"></div>
                            </div>
                        </details>

                        <button type="submit" id="btnGuardarProd" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Guardar Artículo</button>
                        </form>
                    </div>
                </details>
            </div>
        `;

        // Pantalla dedicada solo al formulario: arranca abierto (antes se dejaba
        // contraído para que el Catálogo de abajo se viera completo; ya no aplica).
        const detRegistro = document.getElementById('detRegistroProducto');
        const chevronRegistro = document.getElementById('detRegistroChevron');
        detRegistro.open = true;
        chevronRegistro.textContent = '▾ Cerrar';
        detRegistro.addEventListener('toggle', () => {
            chevronRegistro.textContent = detRegistro.open ? '▾ Cerrar' : '▸ Abrir';
        });

        let itemsBomTemp = [];
        let clavesProvTemp = [];   // claves de proveedor del artículo en edición
        let productoSeleccionadoId = null;
        // Antes de sincronizarAbastecimiento(), que la usa al abrir el formulario.
        let ultimoResForm = null;   // último análisis de la fórmula (para explicar la densidad si la cambian a mano)

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
        const formArticulo = document.getElementById('formCrearProducto');
        const bloqueAbast = document.getElementById('bloqueAbastecimiento');
        const inputAbast = document.getElementById('prodAbastecimiento');
        // Semiterminado (granel) es un tipo propio: productos.tipo = 'semiterminado'.
        const esSemiForm = () => selectTipoElemento.value === 'semiterminado';

        if (btnRefrescarProveedores) {
            btnRefrescarProveedores.addEventListener('click', async () => {
                await actualizarSelectProveedores();
            });
        }

        selectTipoElemento.addEventListener('change', () => sincronizarAbastecimiento());

        // Qué se muestra depende del tipo y de cómo se obtiene: el bloque
        // "¿Cómo se obtiene?" es solo para productos, y el BOM solo para los
        // que se fabrican (un producto comprado para reventa no lleva fórmula).
        function marcarBotonAbast(valor) {
            document.querySelectorAll('.abast-btn').forEach((b) => {
                const activo = b.dataset.abast === valor;
                b.className = `abast-btn text-xs font-medium py-2 rounded-lg border transition ${activo
                    ? 'bg-sky-600 border-sky-500 text-white'
                    : 'bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-800'}`;
            });
        }
        function sincronizarAbastecimiento() {
            const esProducto = selectTipoElemento.value === 'producto';
            const semi = esSemiForm();
            if (semi) inputAbast.value = 'fabricado';          // un semiterminado siempre se fabrica
            const comprado = esProducto && inputAbast.value === 'comprado';
            // "¿Cómo se obtiene?" solo aplica a Producto terminado (el semiterminado no lo pregunta)
            bloqueAbast.classList.toggle('hidden', !esProducto);
            // Densidad es para lo que se fabrica en granel (semiterminado) y también para materia
            // prima/insumo cuando la fórmula del granel los pide en otra unidad — un Producto
            // terminado ya recibe el granel en la unidad que necesita su BOM, no aplica.
            document.getElementById('bloqueProdDensidad')?.classList.toggle('hidden', esProducto);
            // Rendimiento del lote es SOLO de quien tiene su propia fórmula/BOM (el semiterminado);
            // materia prima e insumo son componentes de esa fórmula, no aplica.
            document.getElementById('bloqueProdRendimientoLote')?.classList.toggle('hidden', !semi);
            // Control de caducidad tampoco se pregunta para Producto terminado en esta pantalla.
            document.getElementById('bloqueProdCaducidad')?.classList.toggle('hidden', esProducto);
            const llevaBom = semi || (esProducto && !comprado);
            seccionBomContainer.classList.toggle('hidden', !llevaBom);
            if (!llevaBom) {
                itemsBomTemp = [];
                actualizarListaBomVisual();
            }
            marcarBotonAbast(inputAbast.value);
            marcarBotonTipoActivo();
            pintarAnalisisTandaForm();
        }
        document.querySelectorAll('.abast-btn').forEach((b) => {
            b.addEventListener('click', () => {
                inputAbast.value = b.dataset.abast;
                sincronizarAbastecimiento();
            });
        });

        // Botones de tipo (reemplazan visualmente al <select> oculto, que
        // sigue siendo la fuente de verdad para el resto del formulario —
        // así no hay que tocar la lógica de guardar/cargar/BOM de abajo).
        const botonesTipoElemento = document.querySelectorAll('.tipo-elemento-btn');
        function marcarBotonTipoActivo() {
            const clave = selectTipoElemento.value || 'producto';
            botonesTipoElemento.forEach((b) => {
                const activo = b.dataset.tipo === clave;
                b.className = `tipo-elemento-btn text-xs font-medium py-2 rounded-lg border transition ${activo
                    ? 'bg-sky-600 border-sky-500 text-white'
                    : 'bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-800'}`;
            });
        }
        botonesTipoElemento.forEach((b) => {
            b.addEventListener('click', () => {
                selectTipoElemento.value = b.dataset.tipo;
                if (esSemiForm()) inputAbast.value = 'fabricado';
                selectTipoElemento.dispatchEvent(new Event('change'));   // -> sincronizarAbastecimiento()
            });
        });
        sincronizarAbastecimiento();

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
                inputAbast.value = art.abastecimiento || 'fabricado';
                formArticulo.dataset.tieneAbast = ('abastecimiento' in art) ? '1' : '';   // ¿ya está la migración 2026-10-18?
                sincronizarAbastecimiento();
                inputNombre.value = art.nombre;
                document.getElementById('prodSku').value = art.sku || '';
                document.getElementById('prodUnidadMedidaId').value = art.unidad_medida_id || '';
                document.getElementById('prodCosto').value = art.costo_unitario || 0;
                document.getElementById('prodPrecioVenta').value = art.precio_venta ?? '';
                document.getElementById('prodStockMinimo').value = art.stock_minimo || 0;
                document.getElementById('prodTiempoEntrega').value = art.tiempo_entrega_dias ?? '';
                document.getElementById('prodCantidadMinimaCompra').value = art.cantidad_minima_compra ?? '';
                document.getElementById('prodClaveSat').value = art.clave_sat || '';
                document.getElementById('prodClaveSat').dataset.tenia = art.clave_sat ? '1' : '';
                document.getElementById('prodDensidad').value = art.densidad_kg_l ?? '';
                delete document.getElementById('prodDensidad').dataset.auto;
                delete document.getElementById('prodDensidad').dataset.manual;
                document.getElementById('prodDensidad').dataset.tenia = (art.densidad_kg_l !== null && art.densidad_kg_l !== undefined) ? '1' : '';
                document.getElementById('prodRendimientoLote').value = art.rendimiento_lote_bom ?? '';
                document.getElementById('prodRendimientoLote').dataset.tenia = (art.rendimiento_lote_bom !== null && art.rendimiento_lote_bom !== undefined) ? '1' : '';

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

                if (art.tipo === 'semiterminado' || (art.tipo === 'producto' && inputAbast.value === 'fabricado')) {
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
                    let { data: cps, error: errCps } = await supabaseClient
                        .from('producto_claves_proveedor')
                        .select('proveedor_id, clave, clave_sat, descripcion_factura, unidad_factura, factor_conversion')
                        .eq('producto_id', id);
                    if (errCps) {
                        // factor_conversion aún no existe: cae al select sin ella.
                        ({ data: cps, error: errCps } = await supabaseClient
                            .from('producto_claves_proveedor')
                            .select('proveedor_id, clave, clave_sat, descripcion_factura, unidad_factura')
                            .eq('producto_id', id));
                    }
                    if (!errCps && cps) {
                        const mapProv = new Map((listaProveedores || []).map(p => [p.id, p.nombre]));
                        clavesProvTemp = cps.map(c => ({
                            proveedorId: c.proveedor_id,
                            proveedorNombre: mapProv.get(c.proveedor_id) || '',
                            clave: c.clave,
                            claveSat: c.clave_sat || '',
                            descFactura: c.descripcion_factura || '',
                            unidadFactura: c.unidad_factura || '',
                            factorConversion: c.factor_conversion ?? null,
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
            document.getElementById('prodClaveSat').dataset.tenia = '';
            document.getElementById('prodDensidad').dataset.tenia = '';
            delete document.getElementById('prodDensidad').dataset.auto;
            delete document.getElementById('prodDensidad').dataset.manual;
            document.getElementById('prodRendimientoLote').dataset.tenia = '';
            itemsBomTemp = [];
            actualizarListaBomVisual();
            clavesProvTemp = [];
            renderClavesProv();
            document.getElementById('detClavesProv')?.removeAttribute('open');
            selectTipoElemento.value = 'producto';
            marcarBotonTipoActivo('producto');
            inputAbast.value = 'fabricado';
            formArticulo.dataset.tieneAbast = '';
            sincronizarAbastecimiento();
            document.getElementById('prodExistenciaActual').classList.add('hidden');
            tituloForm.textContent = "Alta de productos";
            btnGuardar.textContent = "Guardar Artículo";
            btnNuevoModo.classList.add('hidden');

            await actualizarSelectProveedores();
        });

        // Semiterminado (granel) con fórmula: tamaño real de la tanda y propuesta de "Rendimiento del lote".
        function pintarAnalisisTandaForm() {
            const cont = document.getElementById('analisisTandaForm');
            if (!cont) return;
            if (!esSemiForm() || !itemsBomTemp.length) { ultimoResForm = null; cont.classList.add('hidden'); cont.innerHTML = ''; return; }
            const selUni = document.getElementById('prodUnidadMedidaId');
            const unidadNombre = selUni.value ? (selUni.options[selUni.selectedIndex]?.text || '') : '';
            const res = ultimoResForm = tamanoTeoricoTanda(itemsBomTemp.map((i) => ({
                nombre: i.componenteNombre, cantidad: i.cantidad,
                unidadNombre: i.unidadNombre || mapaUnidades[i.unidadId] || '',
                densidad: mapaArticulos[i.componenteId]?.densidad_kg_l,
            })), unidadNombre);
            const elRend = document.getElementById('prodRendimientoLote');
            // Densidad del granel = la de su mezcla: se llena sola mientras el campo esté vacío o conserve
            // el último valor calculado; si la escriben a mano, se respeta y solo se ofrece el botón.
            const elDens = document.getElementById('prodDensidad');
            if (res.densidadCalculada && !elDens.dataset.manual && (!elDens.value || elDens.dataset.auto === elDens.value)) {
                elDens.value = String(res.densidadCalculada);
                elDens.dataset.auto = elDens.value;
            }
            cont.innerHTML = htmlAnalisisTanda(res, unidadNombre, elRend.value, elDens.value);
            cont.classList.remove('hidden');
            cont.querySelector('.btn-usar-dens')?.addEventListener('click', (e) => {
                elDens.value = e.currentTarget.dataset.valor;
                elDens.dataset.auto = elDens.value;
                delete elDens.dataset.manual;
                elDens.classList.add('ring-2', 'ring-sky-500');
                setTimeout(() => elDens.classList.remove('ring-2', 'ring-sky-500'), 1500);
                pintarAnalisisTandaForm();
            });
            cont.querySelector('.btn-usar-rend')?.addEventListener('click', (e) => {
                elRend.value = e.currentTarget.dataset.valor;
                const det = elRend.closest('details');
                if (det) det.open = true;
                elRend.classList.add('ring-2', 'ring-sky-500');
                setTimeout(() => elRend.classList.remove('ring-2', 'ring-sky-500'), 1500);
                pintarAnalisisTandaForm();
            });
        }
        document.getElementById('prodUnidadMedidaId').addEventListener('change', () => pintarAnalisisTandaForm());
        document.getElementById('prodRendimientoLote').addEventListener('input', () => pintarAnalisisTandaForm());
        // Cambio a mano de la densidad de un semiterminado: se advierte (cómo se calculó y por qué no conviene);
        // si no confirma, regresa a la calculada.
        document.getElementById('prodDensidad').addEventListener('change', (e) => {
            const el = e.target;
            if (esSemiForm() && ultimoResForm?.densidadCalculada && el.dataset.auto !== el.value) {
                if (!confirmarCambioDensidad(ultimoResForm, el.value, document.getElementById('prodNombre')?.value)) {
                    el.value = String(ultimoResForm.densidadCalculada);
                    el.dataset.auto = el.value;
                    pintarAnalisisTandaForm();
                    return;
                }
            }
            delete el.dataset.auto;
            el.dataset.manual = '1';   // la escribió (o vació) a mano y lo confirmó: ya no se llena sola
            pintarAnalisisTandaForm();
        });

        function actualizarListaBomVisual() {
            pintarAnalisisTandaForm();
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

        // Empuja a itemsBomTemp lo que haya capturado en los campos del BOM.
        // Se usa tanto en el clic explícito de "＋ Agregar Componente al BOM"
        // (con alertas si falta algo) como, en modo silencioso, justo antes
        // de guardar el artículo — así, si el usuario llenó insumo/cantidad
        // pero olvidó dar clic en "Agregar", esa fila no se pierde sin más.
        function agregarItemBomPendiente({ mostrarAlertas } = { mostrarAlertas: true }) {
            const insumoSelect = document.getElementById('bomInsumo');
            const cantidadInput = document.getElementById('bomCantidad');
            const unidadSelect = document.getElementById('bomUnidadMedidaId');

            if (!mostrarAlertas && !insumoSelect.value && !cantidadInput.value) {
                return true; // nada pendiente, no hay nada que agregar
            }

            const componenteId = parseInt(insumoSelect.value);
            if (!componenteId || isNaN(componenteId)) {
                if (mostrarAlertas) alert("Seleccione un componente válido de la lista.");
                return false;
            }

            const cantidad = parseFloat(cantidadInput.value) || 0;
            if (cantidad <= 0) {
                if (mostrarAlertas) alert("Ingrese una cantidad mayor a 0.");
                return false;
            }

            const selectedOption = insumoSelect.options[insumoSelect.selectedIndex];
            const nombreInsumo = selectedOption.text.split(' [')[0];
            const unidadId = unidadSelect.value ? parseInt(unidadSelect.value) : null;
            const unidadNombre = unidadSelect.options[unidadSelect.selectedIndex]?.text || '';

            itemsBomTemp.push({
                componenteId,
                componenteNombre: nombreInsumo,
                cantidad,
                unidadId,
                unidadNombre
            });

            actualizarListaBomVisual();

            cantidadInput.value = '';
            insumoSelect.value = '';
            unidadSelect.value = '';
            return true;
        }

        btnAddBom.addEventListener('click', () => agregarItemBomPendiente({ mostrarAlertas: true }));

        window.removerItemBom = function(index) {
            itemsBomTemp.splice(index, 1);
            actualizarListaBomVisual();
        };

        // La subventana "Editar o ver BOM" (menú ☰ de la tabla) guarda el BOM por su
        // cuenta. Si ese mismo producto está cargado en el formulario de arriba, se
        // recarga para que su lista no quede vieja: "Actualizar Artículo" reescribe
        // el BOM con lo que tenga el formulario y pisaría el cambio recién guardado.
        window.refrescarFormularioSiEsProducto = async function(id) {
            if (productoSeleccionadoId !== null && Number(productoSeleccionadoId) === Number(id)) {
                await cargarDetalleArticuloExistente(id);
            }
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
                        ${c.unidadFactura ? `<span class="text-slate-500 block">Unidad proveedor: ${escaparHtml(c.unidadFactura)}${c.factorConversion ? ` (factor ${c.factorConversion})` : ''}</span>` : ''}
                    </span>
                    <button type="button" onclick="window.removerClaveProv(${i})" class="text-red-400 hover:text-red-300 text-xs shrink-0">Eliminar</button>
                </div>`).join('');
        }

        window.removerClaveProv = function(i) {
            clavesProvTemp.splice(i, 1);
            renderClavesProv();
        };

        const selUnidadPreset = document.getElementById('cpUnidadPreset');
        if (selUnidadPreset) {
            selUnidadPreset.addEventListener('change', () => {
                const factorInput = document.getElementById('cpFactor');
                const textoInput = document.getElementById('cpUnidadTexto');
                if (selUnidadPreset.value) {
                    factorInput.value = selUnidadPreset.value;
                    textoInput.value = '';
                    textoInput.disabled = true;
                } else {
                    textoInput.disabled = false;
                }
            });
        }

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

                const unidadPreset = selUnidadPreset.value ? (selUnidadPreset.options[selUnidadPreset.selectedIndex]?.dataset.etiqueta || selUnidadPreset.options[selUnidadPreset.selectedIndex]?.text) : '';
                const unidadTexto = document.getElementById('cpUnidadTexto').value.trim();
                const unidadFactura = unidadPreset || unidadTexto || '';
                const factorVal = parseFloat(document.getElementById('cpFactor').value);
                const factorConversion = unidadFactura && factorVal > 0 ? factorVal : null;

                clavesProvTemp.push({
                    proveedorId,
                    proveedorNombre,
                    clave,
                    // Vacío = usa la Clave SAT del producto (arriba); solo se escribe aparte cuando
                    // ESE proveedor la reporta distinta en su factura (pasa: cada quien clasifica a su modo).
                    claveSat: document.getElementById('cpClaveSat').value.trim() || document.getElementById('prodClaveSat').value.trim(),
                    descFactura: document.getElementById('cpDescFactura').value.trim(),
                    unidadFactura,
                    factorConversion,
                });
                renderClavesProv();
                document.getElementById('cpClave').value = '';
                document.getElementById('cpClaveSat').value = '';
                document.getElementById('cpDescFactura').value = '';
                selUnidadPreset.value = '';
                document.getElementById('cpUnidadTexto').value = '';
                document.getElementById('cpUnidadTexto').disabled = false;
                document.getElementById('cpFactor').value = '1';
            });
        }

        const formProducto = document.getElementById('formCrearProducto');
        formProducto.addEventListener('submit', async (e) => {
            e.preventDefault();

            // Si quedó un insumo/cantidad capturado en el BOM pero el usuario
            // no dio clic en "＋ Agregar Componente al BOM", lo sumamos aquí
            // en silencio para que no se pierda al guardar (ver definición
            // de agregarItemBomPendiente más arriba).
            if (['producto', 'semiterminado'].includes(selectTipoElemento.value) && inputAbast.value === 'fabricado' && !agregarItemBomPendiente({ mostrarAlertas: false })) {
                alert("Revisa el componente del BOM que estás agregando: falta seleccionar un insumo válido o poner una cantidad mayor a 0.");
                return;
            }

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

            // Clave SAT (ClaveProdServ): 8 dígitos del catálogo c_ClaveProdServ.
            // Solo se manda si hay algo que guardar (o borrar) — así el guardado
            // de productos no depende de haber corrido sql/2026-10-15_productos_clave_sat.sql.
            const elClaveSat = document.getElementById('prodClaveSat');
            const claveSatVal = elClaveSat.value.trim();
            if (claveSatVal && !/^\d{8}$/.test(claveSatVal)) {
                alert('La Clave SAT (ClaveProdServ) debe ser de 8 dígitos, como en el catálogo del SAT (ej. 24122000).');
                elClaveSat.focus();
                return;
            }
            const claveSatPayload = (claveSatVal || elClaveSat.dataset.tenia === '1') ? { clave_sat: claveSatVal || null } : {};

            // Densidad (kg/L): igual patrón que la clave SAT — solo se manda si hay algo que
            // guardar (o borrar), así el guardado no depende de haber corrido
            // sql/2026-10-23_densidad_conversion_bom.sql.
            const elDensidad = document.getElementById('prodDensidad');
            const densidadVal = elDensidad.value.trim();
            if (densidadVal && !(parseFloat(densidadVal) > 0)) {
                alert('La densidad debe ser un número mayor a 0 (kg por litro).');
                elDensidad.focus();
                return;
            }
            const densidadPayload = (densidadVal || elDensidad.dataset.tenia === '1') ? { densidad_kg_l: densidadVal ? parseFloat(densidadVal) : null } : {};

            // Rendimiento del lote (BOM por lote completo, ej. "Granel ... 15 Litros"): mismo
            // patrón que Densidad — solo se manda si hay algo que guardar (o borrar), así no
            // depende de haber corrido sql/2026-09-22_rendimiento_lote_bom.sql.
            const elRendLote = document.getElementById('prodRendimientoLote');
            const rendLoteVal = elRendLote.value.trim();
            if (rendLoteVal && !(parseFloat(rendLoteVal) > 0)) {
                alert('El rendimiento del lote debe ser un número mayor a 0.');
                elRendLote.focus();
                return;
            }
            const rendimientoLotePayload = (rendLoteVal || elRendLote.dataset.tenia === '1') ? { rendimiento_lote_bom: rendLoteVal ? parseFloat(rendLoteVal) : null } : {};

            // Cómo se obtiene (fabricado / comprado). Igual que la clave SAT: solo se manda si
            // se sale del valor por defecto o si el artículo ya tenía el dato. El semiterminado
            // es un tipo propio (productos.tipo = 'semiterminado') y siempre es fabricado.
            const esProductoTipo = tipo === 'producto';
            const esSemiTipo = tipo === 'semiterminado';
            const abastVal = esSemiTipo ? 'fabricado' : esProductoTipo ? inputAbast.value : 'comprado';
            const abastPayload = ((esProductoTipo && abastVal !== 'fabricado') || esSemiTipo || formArticulo.dataset.tieneAbast === '1')
                ? { abastecimiento: abastVal }
                : {};

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
                    ...claveSatPayload,
                    ...densidadPayload,
                    ...rendimientoLotePayload,
                    ...abastPayload,
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

                if ((tipo === 'producto' || tipo === 'semiterminado') && abastVal === 'fabricado' && itemsBomTemp.length > 0) {
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
                            unidad_factura: c.unidadFactura || null,
                            factor_conversion: c.factorConversion ?? null,
                        }));
                        let { error: errCp } = await supabaseClient.from('producto_claves_proveedor').insert(filasCp);
                        if (errCp && /does not exist|schema cache|could not find/i.test(errCp.message || '')) {
                            // factor_conversion aún no existe: reintenta sin ella (falta correr el SQL).
                            const filasCpSinFactor = filasCp.map(({ factor_conversion, ...resto }) => resto);
                            ({ error: errCp } = await supabaseClient.from('producto_claves_proveedor').insert(filasCpSinFactor));
                        }
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

                if (typeof window.refrescarBomSiEsProducto === 'function') await window.refrescarBomSiEsProducto(articuloId);
                if (typeof window.refrescarResumenSiEsProducto === 'function') await window.refrescarResumenSiEsProducto(articuloId);
                btnNuevoModo.click();
                await renderizarTablaProductos(mapaUnidades);

            } catch (err) {
                console.error("Error al guardar el artículo:", err);
                if (err.code === '23505') {
                    alert('Error al guardar el artículo: El SKU o clave ya está registrado.');
                } else if (/semiterminado|tipo_check/.test(err.message || '')) {
                    alert('Falta correr la migración sql/2026-09-24_tipo_semiterminado.sql en Supabase (SQL Editor) para guardar el tipo "Semiterminado".');
                } else if (/abastecimiento/.test(err.message || '')) {
                    alert('Falta correr la migración sql/2026-10-18_producto_abastecimiento_semiterminado.sql en Supabase (SQL Editor) para guardar "Cómo se obtiene".');
                } else if (/densidad_kg_l/.test(err.message || '')) {
                    alert('Falta correr la migración sql/2026-10-23_densidad_conversion_bom.sql en Supabase (SQL Editor) para guardar la Densidad.');
                } else if (/rendimiento_lote_bom/.test(err.message || '')) {
                    alert('Falta correr la migración sql/2026-09-22_rendimiento_lote_bom.sql en Supabase (SQL Editor) para guardar el Rendimiento del lote.');
                } else {
                    alert("Error al procesar la operación en la base de datos: " + (err.message || err));
                }
            }
        });

    } catch (err) {
        console.error("Error crítico al inicializar el formulario de alta:", err);
        if (contenedor) {
            contenedor.innerHTML = `<div class="p-4 bg-red-950/40 border border-red-800 rounded-xl text-red-300 text-sm">
                <strong>Error al cargar el formulario de alta:</strong> ${err.message || err}
            </div>`;
        }
    }
}

// =====================================================================
// Catálogo y Kardex: listado general de artículos (buscar, exportar,
// ☰ acciones por fila) fusionado con el Kardex — al elegir "Kardex de
// este producto" los movimientos se despliegan en esta misma pantalla,
// sin navegar a otra vista.
// =====================================================================
export async function cargarModuloCatalogoKardex() {
    const contenedor = document.getElementById('contenedorCatalogoKardex');
    if (!contenedor) {
        console.error("No se encontró el elemento #contenedorCatalogoKardex en el DOM.");
        return;
    }

    try {
        if (!supabaseClient) throw new Error("Cliente Supabase no disponible.");

        contenedor.innerHTML = `<p class="text-slate-400 text-sm p-4">Cargando catálogo...</p>`;

        const mapaUnidades = {};
        const { data: resUm, error: errUm } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('id', { ascending: true });
        if (errUm) throw errUm;
        (resUm || []).forEach((u) => { mapaUnidades[u.id] = u.nombre; });

        contenedor.innerHTML = `
            <div class="space-y-3">
                <div class="flex flex-wrap justify-between items-center gap-2">
                    <h3 class="text-md font-semibold text-slate-300">Catálogo General de Artículos</h3>
                    <div class="flex flex-wrap gap-2 items-center">
                        <button type="button" id="btnExportProdXlsx" class="text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">⬇️ Excel</button>
                        <button type="button" id="btnExportProdCsv" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">⬇️ CSV</button>
                        <button type="button" id="btnTablaDensidades" title="Kilogramos que pesa 1 litro de cada insumo — para convertir fórmulas en volumen contra inventario en peso" class="text-xs bg-slate-800 hover:bg-slate-700 text-amber-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">⚖️ Densidades</button>
                        <button type="button" id="btnTablaUnidades" title="Ver, editar y agregar unidades de medida (Piezas, Kilogramos, Litros...)" class="text-xs bg-slate-800 hover:bg-slate-700 text-indigo-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">📏 Unidades</button>
                    </div>
                </div>
                <input type="text" id="catBuscador" placeholder="🔍 Buscar por SKU o nombre..." value="${escaparHtml(catBusqueda)}"
                    class="w-full bg-slate-900 border border-slate-800 rounded-lg px-3 py-2 text-sm text-slate-100 placeholder-slate-500 focus:outline-none focus:border-sky-500">
                <div id="tablaProductosContainer">Cargando listado...</div>
                <div id="panelKardexProducto" class="hidden mt-4 border-t border-slate-800 pt-4">
                    <div class="flex justify-between items-center mb-2">
                        <h3 class="text-sm font-semibold text-sky-400">📦 Kardex — <span id="kpxNombreProducto"></span></h3>
                        <button type="button" id="btnCerrarKardexInline" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700 cursor-pointer">✕ Cerrar</button>
                    </div>
                    <div id="kpxContenido"></div>
                </div>
            </div>
        `;

        document.getElementById('btnExportProdCsv').addEventListener('click', () => exportarCatalogoProductos('csv'));
        document.getElementById('btnExportProdXlsx').addEventListener('click', () => exportarCatalogoProductos('xlsx'));
        document.getElementById('btnTablaDensidades').addEventListener('click', abrirTablaDensidades);
        document.getElementById('btnTablaUnidades').addEventListener('click', abrirTablaUnidades);
        document.getElementById('catBuscador').addEventListener('input', (e) => {
            catBusqueda = e.target.value;
            aplicarFiltroCatalogo();
        });
        document.getElementById('btnCerrarKardexInline').addEventListener('click', () => {
            const panel = document.getElementById('panelKardexProducto');
            panel.classList.add('hidden');
            document.getElementById('kpxContenido').innerHTML = '';
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

// Muestra el Kardex de un producto en el panel de esta misma pantalla (sin
// navegar a otra vista) — usado desde el ☰ "Kardex de este producto".
async function mostrarKardexInlineProducto(producto) {
    const panel = document.getElementById('panelKardexProducto');
    const contenido = document.getElementById('kpxContenido');
    if (!panel || !contenido) return;
    document.getElementById('kpxNombreProducto').textContent = producto.nombre || 'Sin nombre';
    panel.classList.remove('hidden');
    panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
    await renderizarKardexProducto(producto.id, contenido);
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
            'id', 'sku', 'nombre', 'tipo', 'descripcion', 'clave_sat',
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

// Filtra en vivo las filas ya renderizadas del Catálogo por SKU y/o nombre
// (búsqueda local, sin volver a consultar Supabase en cada tecleo).
function aplicarFiltroCatalogo() {
    const cont = document.getElementById('tablaProductosContainer');
    if (!cont) return;
    const term = catBusqueda.trim().toLowerCase();
    const filas = [...cont.querySelectorAll('tbody tr')];
    let visibles = 0;
    filas.forEach((tr) => {
        const coincide = !term || tr.dataset.sku.includes(term) || tr.dataset.nombre.includes(term);
        tr.classList.toggle('hidden', !coincide);
        if (coincide) visibles++;
    });
    const msg = document.getElementById('catSinResultados');
    if (msg) msg.classList.toggle('hidden', filas.length === 0 || visibles > 0);
}

async function renderizarTablaProductos(mapaUnidades = {}) {
    const contenedorTabla = document.getElementById('tablaProductosContainer');
    if (!contenedorTabla) return;

    try {
        // Con "abastecimiento" (migración 2026-10-18); si aún no está, sin él.
        const colsProd = 'id, nombre, sku, tipo, unidad_medida_id, proveedor_id, stock_actual, stock_minimo, activo';
        const consultarProductos = async () => {
            let r = await supabaseClient.from('productos').select(colsProd + ', abastecimiento').order('id', { ascending: true });
            if (r.error) r = await supabaseClient.from('productos').select(colsProd).order('id', { ascending: true });
            return r;
        };
        const [resProd, resProv] = await Promise.all([
            consultarProductos(),
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

        // Ordenamiento en vivo de la tabla (client-side, sobre los datos ya
        // traídos): cada encabezado clicleable alterna asc/desc.
        const COLUMNAS_ORDEN = [
            { campo: 'estado', label: 'Estado', clase: '' },
            { campo: 'sku', label: 'SKU', clase: '' },
            { campo: 'tipo', label: 'Tipo', clase: '' },
            { campo: 'nombre', label: 'Nombre', clase: '' },
            { campo: 'unidad', label: 'Unidad', clase: '' },
            { campo: 'proveedor', label: 'Proveedor', clase: '' },
            { campo: 'existencia', label: 'Existencia', clase: 'text-right justify-end' },
        ];

        let html = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-sky-400 bg-slate-950">
                            <th class="p-3 text-center">Acciones</th>
                            ${COLUMNAS_ORDEN.map((c) => thOrden(catOrden, c.campo, c.label, c.clase)).join('')}
                        </tr>
                    </thead>
                    <tbody>
        `;

        const mapaProductosPorId = {};
        productosData.forEach((p) => {
            mapaProductosPorId[p.id] = p;
            p._activo = p.activo !== false;
            p._nombreProveedor = mapaProvNombres[p.proveedor_id] || 'N/D';
            p._nombreUnidad = mapaUnidades[p.unidad_medida_id] || 'N/D';
        });

        aplicarOrden(catOrden, productosData, (p, campo) => {
            switch (campo) {
                case 'estado': return p._activo ? 1 : 0;
                case 'sku': return (p.sku || '').toLowerCase();
                case 'tipo': return p.tipo || 'producto';
                case 'nombre': return (p.nombre || '').toLowerCase();
                case 'unidad': return p._nombreUnidad.toLowerCase();
                case 'proveedor': return p._nombreProveedor.toLowerCase();
                case 'existencia': return Number(p.stock_actual || 0);
                default: return p.id;
            }
        });

        const OPCIONES_TIPO_LABEL = {
            producto: 'Producto terminado',
            semiterminado: 'Semiterminado',
            materia_prima: 'Materia prima',
            insumo: 'Insumo',
        };

        productosData.forEach(item => {
            const tipoActual = item.tipo || 'producto';
            let tipoColor = "text-sky-400 border-sky-800";
            if (tipoActual === 'materia_prima') tipoColor = "text-amber-400 border-amber-800";
            if (tipoActual === 'insumo') tipoColor = "text-emerald-400 border-emerald-800";
            let etiquetaTipo = OPCIONES_TIPO_LABEL[tipoActual] || tipoActual;
            if (tipoActual === 'semiterminado') {
                tipoColor = "text-indigo-400 border-indigo-800";
            } else if (tipoActual === 'producto' && item.abastecimiento === 'comprado') {
                etiquetaTipo = 'Terminado (reventa)';
                tipoColor = "text-rose-400 border-rose-800";
            }

            const nombreProveedor = mapaProvNombres[item.proveedor_id] || 'N/D';
            const nombreUnidad = mapaUnidades[item.unidad_medida_id] || 'N/D';
            const activo = item.activo !== false;
            const stockActual = Number(item.stock_actual || 0);
            const stockMinimo = Number(item.stock_minimo || 0);
            const stockBajo = stockMinimo > 0 && stockActual < stockMinimo;

            const skuBusq = (item.sku || '').toLowerCase();
            const nombreBusq = (item.nombre || '').toLowerCase();
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition ${activo ? '' : 'opacity-50'}" data-sku="${escaparHtml(skuBusq)}" data-nombre="${escaparHtml(nombreBusq)}">
                    <td class="p-3 text-center">
                        <button type="button" class="btn-menu-prod text-slate-400 hover:text-slate-100 hover:bg-slate-800 rounded px-2 py-1 cursor-pointer" data-id="${item.id}" title="Más acciones">☰</button>
                    </td>
                    <td class="p-3">
                        <span class="inline-block text-[10px] px-2 py-0.5 rounded border ${activo ? 'bg-emerald-950 text-emerald-400 border-emerald-800' : 'bg-slate-800 text-slate-400 border-slate-700'}" title="Para activar o desactivar el artículo, entra a Editar artículo">${activo ? 'Activo' : 'Inactivo'}</span>
                    </td>
                    <td class="p-3 font-mono text-xs text-sky-300">${item.sku || 'N/D'}</td>
                    <td class="p-3">
                        <span class="inline-block bg-slate-950 border ${tipoColor} rounded px-1.5 py-0.5 text-[10px] font-medium" title="El tipo se define al crear el artículo y no se puede cambiar aquí">${etiquetaTipo}</span>
                    </td>
                    <td class="p-3 font-medium text-slate-100">${item.nombre || 'Sin nombre'}</td>
                    <td class="p-3 text-slate-400 text-xs">${nombreUnidad}</td>
                    <td class="p-3 text-slate-300 text-xs">${nombreProveedor}</td>
                    <td class="p-3 text-right font-mono text-xs ${stockBajo ? 'text-rose-400 font-semibold' : 'text-slate-300'}" title="${stockBajo ? 'Por debajo del stock mínimo (' + stockMinimo + ')' : ''}">${stockActual.toLocaleString('es-MX', { maximumFractionDigits: 4 })}${stockBajo ? ' ⚠' : ''}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div><p id="catSinResultados" class="hidden text-slate-500 text-xs p-3">Sin resultados.</p>`;
        contenedorTabla.innerHTML = html;
        aplicarFiltroCatalogo();

        contenedorTabla.querySelectorAll('.btn-menu-prod').forEach((btn) => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const producto = mapaProductosPorId[Number(btn.dataset.id)];
                if (producto) abrirMenuAccionesProducto(producto, btn);
            });
        });

        wireOrdenTabla(contenedorTabla, catOrden, () => renderizarTablaProductos(mapaUnidades));

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
// Columnas que "Editar artículo" no muestra (es_semiterminado: la reemplazó tipo = 'semiterminado'; se borra en
// sql/2026-09-24b_quitar_es_semiterminado.sql, mientras tanto la base la mantiene sola).
const CAMPOS_OCULTOS_PRODUCTO = new Set(['es_semiterminado']);

// Orden lógico del formulario "Editar artículo" — identificación primero,
// luego catálogos/relaciones, costos/precios, inventario, y por último
// las banderas. Los que no estén aquí (columnas nuevas a futuro) caen
// después, en orden alfabético; los de solo lectura siempre van al final.
const ORDEN_CAMPOS_PRODUCTO = [
    'sku', 'nombre', 'tipo', 'descripcion', 'clave_sat', 'densidad_kg_l', 'rendimiento_lote_bom',
    'unidad_medida_id', 'proveedor_id', 'moneda_id',
    'costo_unitario', 'precio_venta', 'tasa_iva', 'tasa_ieps',
    'cuenta_inventario_id', 'cuenta_costo_id',
    'stock_actual', 'stock_minimo', 'cantidad_minima_compra', 'tiempo_entrega_dias',
    'requiere_caducidad',
];

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

    // El BOM solo aplica a lo que se fabrica: producto que no está marcado como comprado para reventa.
    const llevaBom = ['producto', 'semiterminado'].includes(producto.tipo || 'producto') && producto.abastecimiento !== 'comprado';

    menu.innerHTML = `
        <button type="button" id="btnMenuProdKardex" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 flex items-center gap-2 cursor-pointer">
            <span>📦</span><span>Kardex de este producto</span>
        </button>
        <button type="button" id="btnMenuProdVer" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 border-t border-slate-800 flex items-center gap-2 cursor-pointer">
            <span>👁️</span><span>Ver artículo</span>
        </button>
        <button type="button" id="btnMenuProdResumen" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 border-t border-slate-800 flex items-center gap-2 cursor-pointer">
            <span>✏️</span><span>Editar artículo</span>
        </button>
        ${llevaBom ? `
        <button type="button" id="btnMenuProdBom" class="w-full text-left px-3 py-2.5 hover:bg-slate-800 text-slate-200 border-t border-slate-800 flex items-center gap-2 cursor-pointer">
            <span>🧪</span><span>Editar o ver BOM</span>
        </button>` : ''}
    `;
    document.body.appendChild(menu);

    document.getElementById('btnMenuProdKardex').addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        mostrarKardexInlineProducto(producto);
    });
    document.getElementById('btnMenuProdVer').addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        abrirResumenCompletoProducto(producto.id, producto.nombre, producto.sku, true);
    });
    document.getElementById('btnMenuProdResumen').addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        abrirResumenCompletoProducto(producto.id, producto.nombre, producto.sku);
    });
    document.getElementById('btnMenuProdBom')?.addEventListener('click', () => {
        cerrarMenuAccionesProducto();
        abrirVentanaBom(producto);
    });

    // Cerrar al hacer clic afuera o con Escape; se difiere un tick para
    // que no capture el mismo clic que acaba de abrir el menú.
    setTimeout(() => {
        document.addEventListener('click', cerrarMenuAccionesProducto);
        document.addEventListener('keydown', cerrarMenuAccionesProductoEsc);
    }, 0);
}

// =====================================================================
// Subventana "Editar o ver BOM" (menú ☰): solo los componentes de ese
// producto — sin el resto del formulario. Se edita en la lista (cantidad,
// unidad, quitar) y se agrega con un solo selector. Al guardar aplica solo
// las diferencias (borra, actualiza, inserta) sobre la tabla `bom`; las
// reglas de la base (sin ciclos, sin fórmula a un producto comprado) avisan
// con su propio mensaje si algo no procede.
// =====================================================================
async function abrirVentanaBom(producto) {
    // Ctrl/Cmd + clic en "Editar o ver BOM": abre una instancia aparte, sin
    // tocar la que ya esté abierta (window.idSubventana, subventanas-movibles.js).
    const idModal = window.idSubventana('modalBomProducto');
    if (idModal === 'modalBomProducto') document.getElementById('modalBomProducto')?.remove();
    const id = Number(producto.id);

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '8vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '40rem';
    const etiquetaProd = producto.tipo === 'semiterminado' ? 'Semiterminado' : 'Producto terminado';
    modal.innerHTML = `
        <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-start rounded-t-2xl gap-3">
            <div class="min-w-0">
                <h3 class="text-sm font-bold text-slate-200 truncate">🧪 BOM — ${escaparHtml(producto.nombre || '')}</h3>
                <p class="text-[11px] text-slate-500 mt-0.5 truncate">${escaparHtml(producto.sku || 'sin SKU')} · ${etiquetaProd}</p>
            </div>
            <button type="button" id="bomBtnX" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer shrink-0">&times;</button>
        </div>
        <div id="bomCuerpo" class="p-5 overflow-y-auto flex-1 text-sm text-slate-300">Cargando…</div>
        <div class="bg-slate-950 px-5 py-3 border-t border-slate-800 flex justify-between items-center gap-3 rounded-b-2xl">
            <span id="bomMsg" class="text-xs text-slate-500 min-w-0"></span>
            <div class="flex gap-2 shrink-0">
                <button type="button" id="bomBtnCerrar" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Cerrar</button>
                <button type="button" id="bomBtnGuardar" disabled class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Guardar</button>
            </div>
        </div>`;
    document.body.appendChild(modal);

    const cuerpo = modal.querySelector('#bomCuerpo');
    const msg = modal.querySelector('#bomMsg');
    const btnGuardar = modal.querySelector('#bomBtnGuardar');

    // Si este mismo producto se guarda desde otra subventana abierta a la vez
    // (Alta de artículo o ☰ "Editar artículo" — Densidad/Rendimiento del lote
    // también se editan ahí), la "Revisión del granel" de aquí se refresca sola
    // en vez de quedarse con el dato viejo con el que se abrió.
    window.refrescarBomSiEsProducto = async function(idAfectado) {
        if (!document.getElementById('modalBomProducto') || Number(idAfectado) !== id) return;
        const { data } = await supabaseClient.from('productos')
            .select('rendimiento_lote_bom, densidad_kg_l, tipo, unidad_medida_id, cuenta_inventario_id, stock_actual')
            .eq('id', id).single();
        if (data) Object.assign(producto, data);
        refrescarAnalisisModal();
    };

    let filas = [];              // { id (bom.id o null), compId, cantidad (texto), unidad (texto), base }
    let productos = [];          // candidatos a componente
    let unidades = [];
    let nombreUnidadPorId = new Map();
    let sucio = false;

    const nombreDe = (compId) => productos.find((p) => p.id === compId);

    const hayCambios = () => {
        const idsAhora = new Set(filas.filter((f) => f.id).map((f) => f.id));
        if (baseIds.some((b) => !idsAhora.has(b))) return true;
        return filas.some((f) => !f.id
            || Number(f.cantidad) !== Number(f.base.cantidad)
            || String(f.unidad || '') !== String(f.base.unidad || ''));
    };
    let baseIds = [];
    let ultimaDensidadCalculada = null;   // densidad de la mezcla según la fórmula en pantalla (granel)

    const actualizarEstado = () => {
        sucio = hayCambios();
        btnGuardar.disabled = !sucio;
        if (sucio) { msg.dataset.fijo = ''; msg.className = 'text-xs text-amber-400 min-w-0'; msg.textContent = 'Hay cambios sin guardar.'; }
        else if (!msg.dataset.fijo) { msg.className = 'text-xs text-slate-500 min-w-0'; msg.textContent = ''; }
        refrescarAnalisisModal();
    };

    const opcionesUnidad = (sel) => `<option value="">(sin unidad)</option>` +
        unidades.map((u) => `<option value="${u.id}" ${String(u.id) === String(sel) ? 'selected' : ''}>${escaparHtml(u.nombre)}</option>`).join('');

    // "Fórmula: 13.7 Litros → se descontarán 17.262 Kilogramos (densidad 1.26 kg/L)" — el mismo aviso
    // que verá Producción, pero aquí, al capturar la fórmula, antes de que falte algo el día del lote.
    const fmtNum = (n) => Number(Number(n || 0).toFixed(4)).toString();
    function notaConversionFila(f) {
        const p = nombreDe(f.compId);
        const cant = Number(f.cantidad);
        if (!p || !f.unidad || !(cant > 0)) return '';
        const stockId = String(p.unidad_medida_id ?? '');
        if (!stockId || f.unidad === stockId) return '';   // misma unidad: no hay nada que convertir
        const nombreUnidadReceta = nombreUnidadPorId.get(f.unidad) || '';
        const nombreUnidadStock = p.unidades_medida?.nombre || nombreUnidadPorId.get(stockId) || '';
        const conv = factorConversion(f.unidad, stockId, nombreUnidadPorId, nombreUnidadStock, cant, p.densidad_kg_l);
        const convertido = cant * conv.factor;
        const detalle = conv.tipo === 'aviso'
            ? 'sin densidad capturada — se toma como agua (1 kg/L), agrégala en ⚖️ Densidades'
            : (conv.nota ? conv.nota.replace(/^Convertido con /, '').replace(/\.$/, '') : 'conversión exacta de unidad');
        const clase = conv.tipo === 'aviso' ? 'text-amber-400' : 'text-emerald-400';
        return `<span class="${clase}">Fórmula: ${fmtNum(cant)} ${escaparHtml(nombreUnidadReceta)} → se descontarán ${fmtNum(convertido)} ${escaparHtml(nombreUnidadStock)} (${detalle})</span>`;
    }
    // Actualiza SOLO el renglón de aviso de una fila (sin repintar toda la tabla, para no
    // perder el foco/cursor mientras el usuario está escribiendo la cantidad).
    function refrescarNotaFila(i) {
        const el = cuerpo.querySelector(`#bomNota${i}`);
        if (!el) return;
        const html = notaConversionFila(filas[i]);
        el.innerHTML = html;
        el.closest('tr')?.classList.toggle('hidden', !html);
    }

    const opcionesComponente = () => {
        const usados = new Set(filas.map((f) => f.compId));
        const libres = productos.filter((p) => !usados.has(p.id));
        const mp = libres.filter((p) => p.tipo === 'materia_prima');
        const otros = libres.filter((p) => p.tipo !== 'materia_prima');
        const opt = (p) => `<option value="${p.id}">${escaparHtml(p.nombre)}${p.sku ? ' [' + escaparHtml(p.sku) + ']' : ''}</option>`;
        return `<option value="">＋ Agregar componente…</option>`
            + (mp.length ? `<optgroup label="Materias primas">${mp.map(opt).join('')}</optgroup>` : '')
            + (otros.length ? `<optgroup label="Insumos, semiterminados y productos">${otros.map(opt).join('')}</optgroup>` : '');
    };

    // Pista de cómo se lee esta fórmula: por tanda (semiterminado con "Rendimiento del lote")
    // o por 1 unidad del producto.
    function pistaReceta() {
        const uni = nombreUnidadPorId.get(String(producto.unidad_medida_id ?? '')) || 'unidad';
        const rend = Number(producto.rendimiento_lote_bom) || 0;
        if (rend > 0) {
            return `<p class="text-[11px] text-sky-300/90 bg-sky-950/30 border border-sky-900/60 rounded-lg px-3 py-2 mb-3">📐 <b>Fórmula de UNA tanda:</b> captura cada insumo como lo pones en el tanque para una tanda completa, en la unidad en que lo mides (L, mL, kg, g) — el sistema convierte solo a la unidad en que lo tienes en inventario. Esta tanda rinde <b>${escaparHtml(String(rend))} ${escaparHtml(uni)}</b> ("Rendimiento del lote" en Más detalles). En Producción, ${escaparHtml(String(rend))} = 1 tanda.</p>`;
        }
        if (producto.tipo === 'semiterminado') {
            return `<p class="text-[11px] text-amber-300/90 bg-amber-950/30 border border-amber-900/60 rounded-lg px-3 py-2 mb-3">⚠ Este semiterminado no tiene <b>"Rendimiento del lote"</b>: esta fórmula se toma como la de <b>1 ${escaparHtml(uni)}</b>. Si la escribiste para una tanda completa, captura cuánto rinde en Catálogo → Más detalles → "Rendimiento del lote (para el BOM)", o Producción pedirá los insumos multiplicados de más.</p>`;
        }
        return `<p class="text-[11px] text-slate-400 bg-slate-950/60 border border-slate-800 rounded-lg px-3 py-2 mb-3">Fórmula para <b>1 ${escaparHtml(uni)}</b> de este producto: cada componente en la unidad en que lo mides (un granel en mL, un frasco en Pieza); el sistema convierte solo a la unidad de inventario de cada componente.</p>`;
    }

    // Granel: tamaño real de la tanda según lo capturado (se recalcula al editar).
    function refrescarAnalisisModal() {
        const cont = cuerpo.querySelector('#bomAnalisis');
        if (!cont) return;
        const esGranel = producto.tipo === 'semiterminado' || Number(producto.rendimiento_lote_bom) > 0 || /granel/i.test(producto.nombre || '');
        if (!esGranel) { cont.innerHTML = ''; return; }
        const uni = nombreUnidadPorId.get(String(producto.unidad_medida_id ?? '')) || '';
        const res = tamanoTeoricoTanda(filas.map((f) => {
            const p = nombreDe(f.compId);
            const raw = String(f.unidad || '');
            return { nombre: p ? p.nombre : `#${f.compId}`, cantidad: f.cantidad,
                unidadNombre: /^\d+$/.test(raw) ? (nombreUnidadPorId.get(raw) || '') : raw, densidad: p?.densidad_kg_l };
        }), uni);
        cont.innerHTML = htmlGuiaGranel({
            esSemi: producto.tipo === 'semiterminado', unidadNombre: uni, nComponentes: filas.length,
            rend: producto.rendimiento_lote_bom, res: filas.length ? res : null, cuentaConocida: false, enBom: true,
        }) + (filas.length ? htmlAnalisisTanda(res, uni, producto.rendimiento_lote_bom, producto.tipo === 'semiterminado' ? (producto.densidad_kg_l ?? '') : undefined) : '');
        ultimaDensidadCalculada = (filas.length && producto.tipo === 'semiterminado') ? res.densidadCalculada : null;
        cont.querySelector('.btn-usar-dens')?.addEventListener('click', async (e) => {
            e.stopPropagation();
            const valor = Number(e.currentTarget.dataset.valor);
            if (!confirm(`¿Guardar ${valor} kg/L como "Densidad" de ${producto.nombre}?\n\nEs la densidad de la mezcla según la fórmula.`)) return;
            const { error } = await supabaseClient.from('productos').update({ densidad_kg_l: valor }).eq('id', id);
            if (error) { alert('No se pudo guardar la Densidad: ' + error.message); return; }
            producto.densidad_kg_l = valor;
            pintar();
            if (typeof window.refrescarFormularioSiEsProducto === 'function') await window.refrescarFormularioSiEsProducto(id);
            if (typeof window.refrescarResumenSiEsProducto === 'function') await window.refrescarResumenSiEsProducto(id);
        });
        cont.querySelector('.btn-usar-rend')?.addEventListener('click', async (e) => {
            const valor = Number(e.currentTarget.dataset.valor);
            if (!confirm(`¿Guardar ${valor} ${uni} como "Rendimiento del lote" de ${producto.nombre}?\n\nProducción tomará esta fórmula como UNA tanda que rinde ${valor} ${uni}.`)) return;
            const { error } = await supabaseClient.from('productos').update({ rendimiento_lote_bom: valor }).eq('id', id);
            if (error) { alert('No se pudo guardar el Rendimiento del lote: ' + error.message); return; }
            producto.rendimiento_lote_bom = valor;
            pintar();
            if (typeof window.refrescarFormularioSiEsProducto === 'function') await window.refrescarFormularioSiEsProducto(id);
            if (typeof window.refrescarResumenSiEsProducto === 'function') await window.refrescarResumenSiEsProducto(id);
        });
    }

    function pintar(enfocarIdx = -1) {
        const cls = 'bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-sm text-slate-100';
        cuerpo.innerHTML = `
            ${pistaReceta()}
            <div id="bomAnalisis" class="mb-3"></div>
            ${filas.length ? `
            <div class="overflow-x-auto">
              <table class="w-full text-left">
                <thead>
                    <tr class="text-[10px] uppercase tracking-wider text-slate-500">
                        <th class="pb-2 pr-2 font-semibold">Componente</th>
                        <th class="pb-2 pr-2 font-semibold w-28">Cantidad</th>
                        <th class="pb-2 pr-2 font-semibold w-36">Unidad</th>
                        <th class="pb-2 w-8"></th>
                    </tr>
                </thead>
                <tbody>
                    ${filas.map((f, i) => {
                        const p = nombreDe(f.compId);
                        const nota = notaConversionFila(f);
                        return `
                    <tr class="border-t border-slate-800">
                        <td class="py-2 pr-2 text-slate-100">${escaparHtml(p ? p.nombre : `Elemento ID: ${f.compId}`)}${p && p.sku ? `<span class="block text-[10px] font-mono text-slate-500">${escaparHtml(p.sku)}</span>` : ''}</td>
                        <td class="py-2 pr-2"><input type="number" min="0" step="any" data-i="${i}" class="bom-cant w-full font-mono ${cls}" value="${escaparHtml(f.cantidad)}"></td>
                        <td class="py-2 pr-2"><select data-i="${i}" class="bom-uni w-full ${cls}">${opcionesUnidad(f.unidad)}</select></td>
                        <td class="py-2 text-right"><button type="button" data-i="${i}" class="bom-quitar text-slate-500 hover:text-rose-400 cursor-pointer" title="Quitar del BOM">✕</button></td>
                    </tr>
                    <tr class="${nota ? '' : 'hidden'}"><td></td><td colspan="3" class="pb-2 -mt-1 text-[10px] font-normal" id="bomNota${i}">${nota}</td></tr>`;
                    }).join('')}
                </tbody>
              </table>
            </div>`
            : `<p class="text-xs text-slate-500 italic py-2">Este producto todavía no tiene componentes.</p>`}
            <div class="mt-4">
                <select id="bomAgregar" class="w-full ${cls}">${opcionesComponente()}</select>
            </div>`;

        cuerpo.querySelectorAll('.bom-cant').forEach((el) => el.addEventListener('input', () => {
            const i = Number(el.dataset.i);
            filas[i].cantidad = el.value; actualizarEstado(); refrescarNotaFila(i);
        }));
        cuerpo.querySelectorAll('.bom-uni').forEach((el) => el.addEventListener('change', () => {
            const i = Number(el.dataset.i);
            filas[i].unidad = el.value; actualizarEstado(); refrescarNotaFila(i);
        }));
        cuerpo.querySelectorAll('.bom-quitar').forEach((el) => el.addEventListener('click', () => {
            filas.splice(Number(el.dataset.i), 1); pintar(); actualizarEstado();
        }));
        cuerpo.querySelector('#bomAgregar').addEventListener('change', (e) => {
            const compId = Number(e.target.value);
            const p = nombreDe(compId);
            if (!p) return;
            filas.push({ id: null, compId, cantidad: '', unidad: p.unidad_medida_id ? String(p.unidad_medida_id) : '', base: {} });
            pintar(filas.length - 1); actualizarEstado();
        });
        if (enfocarIdx >= 0) cuerpo.querySelector(`.bom-cant[data-i="${enfocarIdx}"]`)?.focus();
        refrescarAnalisisModal();
    }

    async function cargar() {
        const rUm = await supabaseClient.from('unidades_medida').select('id, nombre').order('nombre', { ascending: true });
        if (rUm.error) throw rUm.error;
        unidades = rUm.data || [];
        nombreUnidadPorId = new Map(unidades.map((u) => [String(u.id), u.nombre]));

        // Con densidad_kg_l (migración 2026-10-23); si aún no está, sin ella — el aviso de
        // conversión por densidad simplemente no aparece hasta que se corra.
        let rProd = await supabaseClient.from('productos')
            .select('id, nombre, sku, tipo, unidad_medida_id, densidad_kg_l, unidades_medida ( nombre )')
            .neq('id', id).order('nombre', { ascending: true });
        if (rProd.error) {
            rProd = await supabaseClient.from('productos')
                .select('id, nombre, sku, tipo, unidad_medida_id, unidades_medida ( nombre )')
                .neq('id', id).order('nombre', { ascending: true });
        }
        const rBom = await supabaseClient.from('bom').select('id, componente_id, cantidad_requerida, unidad_medida').eq('producto_id', id).order('id', { ascending: true });
        for (const r of [rBom, rProd]) if (r.error) throw r.error;
        productos = rProd.data || [];
        filas = (rBom.data || []).map((b) => ({
            id: b.id, compId: b.componente_id,
            cantidad: String(b.cantidad_requerida ?? ''),
            unidad: b.unidad_medida ? String(b.unidad_medida) : '',
            base: { cantidad: b.cantidad_requerida, unidad: b.unidad_medida ? String(b.unidad_medida) : '' },
        }));
        baseIds = filas.map((f) => f.id);
        pintar();
    }

    function cerrar(forzar = false) {
        if (!forzar && sucio && !confirm('Tienes cambios sin guardar. ¿Cerrar de todos modos?')) return;
        modal.remove();
        document.removeEventListener('keydown', alEscape);
    }
    function alEscape(e) { if (e.key === 'Escape') cerrar(); }
    document.addEventListener('keydown', alEscape);
    modal.querySelector('#bomBtnX').addEventListener('click', () => cerrar());
    modal.querySelector('#bomBtnCerrar').addEventListener('click', () => cerrar());

    btnGuardar.addEventListener('click', async () => {
        for (const f of filas) {
            const n = Number(f.cantidad);
            if (!(n > 0)) {
                const p = nombreDe(f.compId);
                msg.dataset.fijo = '';
                msg.className = 'text-xs text-rose-400 min-w-0';
                msg.textContent = `Falta la cantidad de "${p ? p.nombre : f.compId}" (debe ser mayor a 0).`;
                return;
            }
        }
        btnGuardar.disabled = true;
        msg.className = 'text-xs text-slate-400 min-w-0'; msg.textContent = 'Guardando…';
        try {
            const idsAhora = new Set(filas.filter((f) => f.id).map((f) => f.id));
            const borrar = baseIds.filter((b) => !idsAhora.has(b));
            if (borrar.length) {
                const { error } = await supabaseClient.from('bom').delete().in('id', borrar);
                if (error) throw error;
            }
            for (const f of filas.filter((x) => x.id)) {
                if (Number(f.cantidad) === Number(f.base.cantidad) && String(f.unidad || '') === String(f.base.unidad || '')) continue;
                const { error } = await supabaseClient.from('bom')
                    .update({ cantidad_requerida: Number(f.cantidad), unidad_medida: f.unidad ? String(f.unidad) : null })
                    .eq('id', f.id);
                if (error) throw error;
            }
            const nuevos = filas.filter((f) => !f.id).map((f) => ({
                producto_id: id, componente_id: f.compId,
                cantidad_requerida: Number(f.cantidad), unidad_medida: f.unidad ? String(f.unidad) : null,
            }));
            if (nuevos.length) {
                const { error } = await supabaseClient.from('bom').insert(nuevos);
                if (error) throw error;
            }
            // Granel sin densidad: se guarda sola la de la mezcla (si ya tiene una, solo se ofrece el botón).
            let notaDens = '';
            const densNueva = ultimaDensidadCalculada;
            if (densNueva && 'densidad_kg_l' in producto && !(Number(producto.densidad_kg_l) > 0)) {
                const { error } = await supabaseClient.from('productos').update({ densidad_kg_l: densNueva }).eq('id', id);
                if (!error) { producto.densidad_kg_l = densNueva; notaDens = ` · Densidad ${densNueva} kg/L calculada de la fórmula`; }
            }
            await cargar();
            if (typeof window.refrescarFormularioSiEsProducto === 'function') await window.refrescarFormularioSiEsProducto(id);
            if (typeof window.refrescarResumenSiEsProducto === 'function') await window.refrescarResumenSiEsProducto(id);
            sucio = false;
            btnGuardar.disabled = true;
            msg.dataset.fijo = '1';
            msg.className = 'text-xs text-emerald-400 min-w-0'; msg.textContent = 'BOM guardado ✓' + notaDens;
        } catch (err) {
            console.error('Error al guardar el BOM:', err);
            msg.dataset.fijo = '';
            msg.className = 'text-xs text-rose-400 min-w-0';
            msg.textContent = err.message || 'No se pudo guardar el BOM.';
            // Se deja la lista como está para poder corregir y volver a guardar
            // (borrar/actualizar dos veces lo mismo es inofensivo).
            btnGuardar.disabled = false;
        }
    });

    try {
        await cargar();
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">No se pudo cargar el BOM: ${escaparHtml(err.message || err)}</p>`;
    }
}

// =====================================================================
// Tabla de densidades: catálogo consultable y editable de "cuántos kilos
// pesa 1 litro" de cada insumo. Es la referencia que usa la conversión de
// unidades (BOM en volumen ↔ inventario en peso) en Producción y en la
// ventana de BOM de arriba. Requiere sql/2026-10-23_densidad_conversion_bom.sql.
// =====================================================================
const densOrden = crearOrdenTabla('nombre', 'asc');
let densFiltro = '';
let densFilas = [];

async function abrirTablaDensidades() {
    const idModal = window.idSubventana('modalDensidades');
    if (idModal === 'modalDensidades') document.getElementById('modalDensidades')?.remove();
    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/40 p-4';
    modal.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl max-h-[85vh] flex flex-col">
            <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-start gap-3 rounded-t-2xl">
                <div class="min-w-0">
                    <h3 class="text-sm font-bold text-slate-100">⚖️ Tabla de densidades</h3>
                    <p class="text-[11px] text-slate-500 mt-0.5">Kilogramos que pesa 1 litro de cada insumo. Se usa para convertir cuando la fórmula (BOM) está en volumen (Litros/mL) y el insumo se lleva en inventario por peso (Kilogramos/gramos), o al revés. Los cambios se guardan solos.</p>
                </div>
                <button type="button" id="densBtnX" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer shrink-0">&times;</button>
            </div>
            <div class="p-4 pb-2 shrink-0">
                <input type="text" id="densBuscar" placeholder="🔍 Buscar por nombre o SKU…" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            </div>
            <div id="densCuerpo" class="px-4 pb-4 overflow-y-auto flex-1 text-sm text-slate-300">Cargando…</div>
        </div>`;
    document.body.appendChild(modal);

    const cerrar = () => modal.remove();
    modal.addEventListener('click', (e) => { if (e.target === modal) cerrar(); });
    modal.querySelector('#densBtnX').addEventListener('click', cerrar);

    const cuerpo = modal.querySelector('#densCuerpo');
    modal.querySelector('#densBuscar').addEventListener('input', (e) => {
        densFiltro = e.target.value.trim().toLowerCase();
        densPintar(cuerpo);
    });

    try {
        const { data, error } = await supabaseClient.from('productos')
            .select('id, sku, nombre, tipo, densidad_kg_l, unidades_medida ( nombre )')
            .order('nombre', { ascending: true });
        if (error) throw error;
        densFilas = data || [];
        densPintar(cuerpo);
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">No se pudo cargar. ¿Corriste sql/2026-10-23_densidad_conversion_bom.sql en Supabase?<br>${escaparHtml(err.message || err)}</p>`;
    }
}

function densPintar(cuerpo) {
    const filtro = densFiltro;
    const filas = densFilas.filter((p) => !filtro || (p.nombre || '').toLowerCase().includes(filtro) || (p.sku || '').toLowerCase().includes(filtro));
    aplicarOrden(densOrden, filas, (p, campo) => {
        switch (campo) {
            case 'nombre': return (p.nombre || '').toLowerCase();
            case 'unidad': return (p.unidades_medida?.nombre || '').toLowerCase();
            case 'densidad': return p.densidad_kg_l === null || p.densidad_kg_l === undefined ? -1 : Number(p.densidad_kg_l);
            default: return p.id;
        }
    });
    if (!filas.length) { cuerpo.innerHTML = '<p class="text-slate-500 text-xs italic py-3">Sin resultados.</p>'; return; }
    cuerpo.innerHTML = `
        <table class="w-full text-left text-xs">
            <thead class="text-slate-500 uppercase sticky top-0 bg-slate-900"><tr>
                ${thOrden(densOrden, 'nombre', 'Nombre')}${thOrden(densOrden, 'unidad', 'Unidad de inventario')}${thOrden(densOrden, 'densidad', 'Densidad (kg/L)')}<th class="p-2"></th>
            </tr></thead>
            <tbody>
                ${filas.map((p) => `
                <tr class="border-t border-slate-800" data-id="${p.id}">
                    <td class="p-2 text-slate-100">${escaparHtml(p.nombre)}${p.sku ? `<span class="block text-[10px] font-mono text-slate-500">${escaparHtml(p.sku)}</span>` : ''}</td>
                    <td class="p-2 text-slate-400">${escaparHtml(p.unidades_medida?.nombre || '—')}</td>
                    <td class="p-2"><input type="number" step="0.0001" min="0" placeholder="—" class="dens-input w-24 bg-slate-950 border border-slate-800 rounded p-1 text-xs text-slate-100 font-mono" value="${p.densidad_kg_l ?? ''}"></td>
                    <td class="p-2 text-[10px] dens-estado text-slate-600"></td>
                </tr>`).join('')}
            </tbody>
        </table>`;
    wireOrdenTabla(cuerpo, densOrden, () => densPintar(cuerpo));
    cuerpo.querySelectorAll('.dens-input').forEach((inp) => {
        inp.addEventListener('change', async () => {
            const tr = inp.closest('tr');
            const id = Number(tr.dataset.id);
            const estado = tr.querySelector('.dens-estado');
            const val = inp.value.trim();
            if (val && !(parseFloat(val) > 0)) {
                estado.textContent = 'Debe ser > 0'; estado.className = 'p-2 text-[10px] dens-estado text-rose-400';
                return;
            }
            // Semiterminado: su densidad sale de la fórmula; cambiarla a mano pide confirmación con la explicación.
            const filaDens = densFilas.find((p) => p.id === id);
            if (filaDens?.tipo === 'semiterminado') {
                const res = await analizarFormulaGuardada(id);
                if (res?.densidadCalculada && !confirmarCambioDensidad(res, val, filaDens.nombre)) {
                    inp.value = filaDens.densidad_kg_l ?? '';
                    estado.textContent = 'Sin cambios'; estado.className = 'p-2 text-[10px] dens-estado text-slate-500';
                    return;
                }
            }
            estado.textContent = 'Guardando…'; estado.className = 'p-2 text-[10px] dens-estado text-slate-500';
            try {
                const { error } = await supabaseClient.from('productos').update({ densidad_kg_l: val ? parseFloat(val) : null }).eq('id', id);
                if (error) throw error;
                const fila = densFilas.find((p) => p.id === id);
                if (fila) fila.densidad_kg_l = val ? parseFloat(val) : null;
                estado.textContent = 'Guardado ✓'; estado.className = 'p-2 text-[10px] dens-estado text-emerald-400';
            } catch (err) {
                estado.textContent = /densidad_kg_l/.test(err.message || '') ? 'Falta la migración 2026-10-23' : (err.message || 'Error al guardar');
                estado.className = 'p-2 text-[10px] dens-estado text-rose-400';
            }
        });
    });
}

// =====================================================================
// Tabla de unidades de medida: catálogo consultable, editable y ampliable
// (Piezas, Kilogramos, Litros...). Antes solo se podía tocar entrando a
// Supabase -> Table Editor; ahora se ve, se corrige y se agregan nuevas
// desde aquí. Requiere sql/2026-10-25_unidades_medida_editable.sql para
// poder guardar (RLS de 'authenticated' sobre esa tabla).
// =====================================================================
const unidOrden = crearOrdenTabla('nombre', 'asc');
let unidFiltro = '';
let unidFilas = [];

async function abrirTablaUnidades() {
    const idModal = window.idSubventana('modalUnidades');
    if (idModal === 'modalUnidades') document.getElementById('modalUnidades')?.remove();
    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/40 p-4';
    modal.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-2xl max-h-[85vh] flex flex-col">
            <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-start gap-3 rounded-t-2xl">
                <div class="min-w-0">
                    <h3 class="text-sm font-bold text-slate-100">📏 Tabla de unidades de medida</h3>
                    <p class="text-[11px] text-slate-500 mt-0.5">Piezas, Kilogramos, Litros... Los cambios se guardan solos. "Fraccionable" controla si se puede pedir/producir en decimales (Kilogramos) o solo enteros (Piezas).</p>
                </div>
                <button type="button" id="unidBtnX" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer shrink-0">&times;</button>
            </div>
            <div class="p-4 pb-2 shrink-0 space-y-2">
                <input type="text" id="unidBuscar" placeholder="🔍 Buscar por nombre…" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <div class="flex flex-wrap gap-2 items-center bg-slate-950/60 border border-slate-800 rounded-lg p-2">
                    <input type="text" id="unidNueva" placeholder="Nueva unidad (ej. Metros)" class="flex-1 min-w-[10rem] bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
                    <label class="flex items-center gap-1.5 text-[11px] text-slate-300 cursor-pointer"><input type="checkbox" id="unidNuevaFrac" class="accent-sky-500"> Fraccionable</label>
                    <button type="button" id="unidAgregar" class="text-xs bg-sky-600 hover:bg-sky-500 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">＋ Agregar</button>
                </div>
                <p id="unidMsg" class="text-[11px] min-h-[1rem]"></p>
            </div>
            <div id="unidCuerpo" class="px-4 pb-4 overflow-y-auto flex-1 text-sm text-slate-300">Cargando…</div>
        </div>`;
    document.body.appendChild(modal);

    const cerrar = () => modal.remove();
    modal.addEventListener('click', (e) => { if (e.target === modal) cerrar(); });
    modal.querySelector('#unidBtnX').addEventListener('click', cerrar);

    const cuerpo = modal.querySelector('#unidCuerpo');
    const msg = modal.querySelector('#unidMsg');
    modal.querySelector('#unidBuscar').addEventListener('input', (e) => { unidFiltro = e.target.value.trim().toLowerCase(); unidPintar(cuerpo); });

    modal.querySelector('#unidAgregar').addEventListener('click', async () => {
        const inp = modal.querySelector('#unidNueva');
        const nombre = inp.value.trim();
        msg.textContent = ''; msg.className = 'text-[11px] min-h-[1rem]';
        if (!nombre) { msg.textContent = 'Escribe el nombre de la unidad.'; msg.className = 'text-[11px] min-h-[1rem] text-rose-400'; return; }
        if (unidFilas.some((u) => u.nombre.trim().toLowerCase() === nombre.toLowerCase())) {
            msg.textContent = `"${nombre}" ya existe.`; msg.className = 'text-[11px] min-h-[1rem] text-rose-400'; return;
        }
        try {
            const { data, error } = await supabaseClient.from('unidades_medida')
                .insert([{ nombre, es_fraccionable: modal.querySelector('#unidNuevaFrac').checked }])
                .select('id, nombre, es_fraccionable').single();
            if (error) throw error;
            unidFilas.push({ ...data, _uso: 0 });
            inp.value = ''; modal.querySelector('#unidNuevaFrac').checked = false;
            msg.textContent = `"${data.nombre}" agregada ✓`; msg.className = 'text-[11px] min-h-[1rem] text-emerald-400';
            unidPintar(cuerpo);
        } catch (err) {
            const m = err.message || String(err);
            msg.textContent = /row-level security|permission denied/i.test(m)
                ? 'Falta correr sql/2026-10-25_unidades_medida_editable.sql en Supabase (SQL Editor).'
                : (/duplicate key|unique/i.test(m) ? `"${nombre}" ya existe.` : m);
            msg.className = 'text-[11px] min-h-[1rem] text-rose-400';
        }
    });

    try {
        const [rUnid, rProd] = await Promise.all([
            supabaseClient.from('unidades_medida').select('id, nombre, es_fraccionable').order('nombre', { ascending: true }),
            supabaseClient.from('productos').select('unidad_medida_id'),
        ]);
        if (rUnid.error) throw rUnid.error;
        const usoPorId = new Map();
        (rProd.data || []).forEach((p) => { if (p.unidad_medida_id) usoPorId.set(p.unidad_medida_id, (usoPorId.get(p.unidad_medida_id) || 0) + 1); });
        unidFilas = (rUnid.data || []).map((u) => ({ ...u, _uso: usoPorId.get(u.id) || 0 }));
        unidPintar(cuerpo);
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">No se pudo cargar.<br>${escaparHtml(err.message || err)}</p>`;
    }
}

function unidPintar(cuerpo) {
    const filtro = unidFiltro;
    const filas = unidFilas.filter((u) => !filtro || u.nombre.toLowerCase().includes(filtro));
    aplicarOrden(unidOrden, filas, (u, campo) => {
        switch (campo) {
            case 'nombre': return u.nombre.toLowerCase();
            case 'fraccionable': return u.es_fraccionable ? 1 : 0;
            case 'uso': return u._uso;
            default: return u.id;
        }
    });
    if (!filas.length) { cuerpo.innerHTML = '<p class="text-slate-500 text-xs italic py-3">Sin resultados.</p>'; return; }
    cuerpo.innerHTML = `
        <table class="w-full text-left text-xs">
            <thead class="text-slate-500 uppercase sticky top-0 bg-slate-900"><tr>
                ${thOrden(unidOrden, 'nombre', 'Nombre')}${thOrden(unidOrden, 'fraccionable', 'Fraccionable', 'text-center justify-center')}${thOrden(unidOrden, 'uso', 'En uso', 'text-right justify-end')}<th class="p-2"></th>
            </tr></thead>
            <tbody>
                ${filas.map((u) => `
                <tr class="border-t border-slate-800" data-id="${u.id}">
                    <td class="p-2"><input type="text" class="unid-nombre w-full bg-slate-950 border border-slate-800 rounded p-1 text-xs text-slate-100" value="${escaparHtml(u.nombre)}"></td>
                    <td class="p-2 text-center"><input type="checkbox" class="unid-frac accent-sky-500" ${u.es_fraccionable ? 'checked' : ''}></td>
                    <td class="p-2 text-right font-mono text-slate-400" title="Productos que usan esta unidad">${u._uso}</td>
                    <td class="p-2 text-[10px] unid-estado text-slate-600"></td>
                </tr>`).join('')}
            </tbody>
        </table>`;
    wireOrdenTabla(cuerpo, unidOrden, () => unidPintar(cuerpo));

    const guardar = async (tr, campos) => {
        const id = Number(tr.dataset.id);
        const estado = tr.querySelector('.unid-estado');
        estado.textContent = 'Guardando…'; estado.className = 'p-2 text-[10px] unid-estado text-slate-500';
        try {
            const { error } = await supabaseClient.from('unidades_medida').update(campos).eq('id', id);
            if (error) throw error;
            const fila = unidFilas.find((u) => u.id === id);
            if (fila) Object.assign(fila, campos);
            estado.textContent = 'Guardado ✓'; estado.className = 'p-2 text-[10px] unid-estado text-emerald-400';
        } catch (err) {
            const m = err.message || String(err);
            estado.textContent = /row-level security|permission denied/i.test(m) ? 'Falta la migración 2026-10-25'
                : (/duplicate key|unique/i.test(m) ? 'Ese nombre ya existe' : (m || 'Error al guardar'));
            estado.className = 'p-2 text-[10px] unid-estado text-rose-400';
        }
    };
    cuerpo.querySelectorAll('.unid-nombre').forEach((inp) => {
        inp.addEventListener('change', () => {
            const nombre = inp.value.trim();
            if (!nombre) { inp.focus(); return; }
            guardar(inp.closest('tr'), { nombre });
        });
    });
    cuerpo.querySelectorAll('.unid-frac').forEach((chk) => {
        chk.addEventListener('change', () => guardar(chk.closest('tr'), { es_fraccionable: chk.checked }));
    });
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

// Nombres legibles para las columnas que muestra "Editar artículo" (el resto se arma del nombre de la columna).
const ETIQUETAS_CAMPO_PRODUCTO = {
    sku: 'SKU / Código', clave_sat: 'Clave SAT (ClaveProdServ)', densidad_kg_l: 'Densidad (kg por litro)',
    rendimiento_lote_bom: 'Rendimiento del lote (para el BOM)', unidad_medida_id: 'Unidad de Medida',
    descripcion: 'Descripción',
};
// Pistas bajo cada campo de "Editar artículo" (las mismas ideas que el formulario del Catálogo).
const PISTAS_CAMPO_PRODUCTO = {
    tipo: 'Un granel es "Semiterminado": se fabrica (lleva fórmula) y lo consumen otros productos; no se vende.',
    unidad_medida_id: 'En qué se cuenta en almacén y se descuenta. Granel: Litros o Kilogramos, nunca Pieza.',
    densidad_kg_l: 'Kilos que pesa 1 litro. Solo para insumos que la fórmula pide en volumen y se llevan en peso (o al revés). Ej.: Glicerina Vegetal Usp = 1.26. En un granel se calcula sola con su fórmula (densidad de la mezcla); el botón "Usar X kg/L como Densidad" la actualiza.',
    rendimiento_lote_bom: 'Granel: Litros (o Kilos) que salen de UNA tanda de la fórmula. Usa el tamaño real que calcula el análisis 🧮 de abajo (Fresa Kiwi: 14.64). En Producción: 1 tanda = este número. Vacío = el BOM es para 1 unidad (ej. 1 pieza). ¿Por qué importa si la materia prima ya se descuenta a su costo real? La fórmula decide cuánto se GASTA en la tanda; el rendimiento decide ENTRE CUÁNTOS LITROS se reparte ese gasto y cuántos litros dice el sistema que hay. Ej.: tanda de $1,000 → con 15 L el litro cuesta $66.67 y cada tanda deja 0.36 L que no existen; con 14.64 L cuesta $68.31 (el real). Un número inflado da inventario fantasma y costo del terminado más bajo que el real.',
    costo_unitario: 'Se actualiza solo con compras y al cerrar cada orden; normalmente no se edita a mano.',
    stock_actual: 'Se mueve solo con entradas y salidas; no se edita aquí.',
};
function pistaCampo(clave) {
    const t = PISTAS_CAMPO_PRODUCTO[clave];
    return t ? `<p class="text-[10px] text-slate-500 mt-0.5 leading-snug">${escaparHtml(t)}</p>` : '';
}
function etiquetaCampo(clave) {
    return ETIQUETAS_CAMPO_PRODUCTO[clave] || clave.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

const ETIQUETA_TIPO_PRODUCTO = {
    producto: 'Producto terminado',
    semiterminado: 'Semiterminado (granel)',
    materia_prima: 'Materia prima',
    insumo: 'Insumo / componente',
};


// Revisión de un granel (semiterminado): cada punto que lo deja bien armado, con ✅ / ⚠ y qué hacer.
// Lo usan "Editar artículo" y "Editar o ver BOM".
//  d = { esSemi, unidadNombre, nComponentes, rend, res (tamanoTeoricoTanda o null), cuentaCodigo,
//        cuentaNombre, cuentaConocida, enBom, stock }
function htmlGuiaGranel(d) {
    const fmt = (n, dec = 2) => Number(n).toLocaleString('es-MX', { maximumFractionDigits: dec });
    const u = d.unidadNombre || '';
    const items = [];
    const ok = (t) => items.push({ ok: true, t });
    const mal = (t, como) => items.push({ ok: false, t, como });

    if (d.esSemi) ok('Marcado como <b>semiterminado (granel)</b>: se fabrica y lo consumen otros productos.');
    else mal('Su tipo no es Semiterminado.', d.enBom
        ? 'En ☰ → ✏️ Editar artículo cambia "Tipo" a "Semiterminado (granel)" y guarda.'
        : 'Cambia "Tipo" a "Semiterminado (granel)" y da "Guardar cambios".');

    const fam = familiaDeUnidad(u);
    if (fam) ok(`Unidad de Medida: <b>${escaparHtml(u)}</b> — el granel se cuenta en ${fam.familia === 'volumen' ? 'volumen' : 'peso'} y el terminado le descuenta ${fam.familia === 'volumen' ? 'mL' : 'g'}.`);
    else mal(`Unidad de Medida: "${escaparHtml(u || 'sin unidad')}".`, 'Cámbiala a <b>Litros</b> (o Kilogramos). En Pieza, el producto terminado no le puede descontar mL.');

    if (d.nComponentes > 0) ok(`Fórmula (BOM) con ${d.nComponentes} componente(s), escrita para <b>UNA tanda</b>.`);
    else mal('Sin fórmula (BOM).', 'Captúrala en ☰ → 🧪 Editar o ver BOM, tal como preparas UNA tanda en el tanque.');

    const rend = Number(d.rend) || 0;
    const sug = d.res && d.res.total != null ? Math.round(d.res.total * 100) / 100 : null;
    if (!(rend > 0)) {
        mal('Sin "Rendimiento del lote".', sug ? `Usa <b>${fmt(sug)} ${escaparHtml(u)}</b> (lo que suma la fórmula) con el botón 🧮 "Usar ${fmt(sug)} …" de abajo.` : 'Captura cuántos litros (o kilos) salen de UNA tanda.');
    } else if (sug && Math.abs(rend - sug) / sug >= 0.005) {
        const dif = (rend - sug) / sug * 100;
        mal(`Rendimiento del lote: ${fmt(rend)} ${escaparHtml(u)} — ${fmt(Math.abs(dif), 1)}% ${dif > 0 ? 'MÁS' : 'menos'} que lo que suma la fórmula (${fmt(sug)}).`, `Usa el botón 🧮 "Usar ${fmt(sug)} …" o captura lo que mediste en el tanque.`);
    } else {
        ok(`Rendimiento del lote: <b>${fmt(rend)} ${escaparHtml(u)}</b> = 1 tanda en Producción ("TANDAS A PREPARAR").`);
    }

    if (d.res && d.nComponentes > 0) {
        if (d.res.sinDensidad.length) mal(`Insumos sin densidad: ${d.res.sinDensidad.map(escaparHtml).join(', ')} (se tomaron como agua).`, 'Captúrala en Catálogo → ⚖️ Densidades. Solo importa si la fórmula los pide en otra unidad (ej. en L y se compran en kg).');
        else ok('Todos los insumos se convierten a la unidad del granel (densidades completas).');
        if (d.res.ignorados.length) mal(`La fórmula lleva piezas: ${d.res.ignorados.map(escaparHtml).join(', ')}.`, 'Un granel normalmente no lleva frascos ni etiquetas: esos van en el BOM del producto terminado.');
    }

    if (d.cuentaConocida) {
        if (d.cuentaCodigo === '115.02') ok('Cuenta de inventario: <b>115.02</b> · Inventario de productos en proceso (semiterminados).');
        else mal(`Cuenta de inventario: ${d.cuentaCodigo ? `${escaparHtml(d.cuentaCodigo)} ${escaparHtml(d.cuentaNombre || '')}` : 'sin cuenta (se usaría 115.04 Productos terminados)'}.`, 'Elige <b>115.02 · Inventario de productos en proceso (semiterminados)</b>, así la póliza de producción lo registra como granel.'
            + (Number(d.stock) > 0 ? ' <span class="text-amber-300">Ojo: ya tiene existencia; lo que ya está en la otra cuenta necesita una póliza de reclasificación para que el Auxiliar de inventarios siga cuadrando.</span>' : ''));
    }

    const listos = items.filter((i) => i.ok).length;
    const todoBien = listos === items.length;
    return `<div class="text-[11px] rounded-lg border ${todoBien ? 'border-emerald-900/70 bg-emerald-950/20' : 'border-amber-900/70 bg-amber-950/20'} px-3 py-2 mb-3">
        <p class="font-semibold ${todoBien ? 'text-emerald-300' : 'text-amber-300'} mb-1">🧪 Revisión del granel — ${listos} de ${items.length} listos${todoBien ? ': ya se puede producir por tandas.' : ''}</p>
        <ul class="space-y-1">${items.map((i) => `<li class="flex gap-1.5"><span class="shrink-0">${i.ok ? '✅' : '⚠️'}</span><span class="${i.ok ? 'text-slate-300' : 'text-amber-200'}">${i.t}${i.como ? `<span class="block text-slate-400">→ ${i.como}</span>` : ''}</span></li>`).join('')}</ul>
    </div>`;
}

// Análisis del tamaño real de una tanda (suma de la fórmula con densidades) para proponer el
// "Rendimiento del lote" de un granel. Lo usan el formulario del Catálogo y "Editar o ver BOM".
// El botón lleva la clase `btn-usar-rend` y `data-valor`; quien lo pinta decide qué hace al clic.
function htmlAnalisisTanda(res, unidadNombre, rendActual, densActual) {
    const fmt = (n, d = 3) => Number(n).toLocaleString('es-MX', { maximumFractionDigits: d });
    if (res.total == null) {
        return `<div class="text-[11px] text-amber-300/90 bg-amber-950/30 border border-amber-900/60 rounded-lg px-3 py-2">🧮 Para calcular el tamaño real de la tanda, la Unidad de Medida del granel debe ser de volumen o de peso (Litros, Kilogramos…), no "${escaparHtml(unidadNombre || 'sin unidad')}".</div>`;
    }
    const sugerido = Math.round(res.total * 100) / 100;
    const u = escaparHtml(unidadNombre || '');
    const rend = Number(rendActual) || 0;
    let comparacion;
    if (rend > 0) {
        const dif = (rend - sugerido) / sugerido * 100;
        comparacion = Math.abs(dif) < 0.5
            ? `<span class="text-emerald-400">✅ Coincide con el Rendimiento del lote capturado (${fmt(rend)} ${u}).</span>`
            : `<span class="text-amber-300">Rendimiento del lote capturado: ${fmt(rend)} ${u} — ${fmt(Math.abs(dif), 1)}% ${dif > 0 ? 'MÁS' : 'menos'} que lo que suma la fórmula.${dif > 0 ? ' Entrarían al inventario litros/kilos que no existen y el costo por unidad saldría bajo.' : ''}</span>`;
    } else {
        comparacion = '<span class="text-amber-300">Aún no tiene "Rendimiento del lote": sin él, Producción toma esta fórmula como la de 1 unidad.</span>';
    }
    return `<div class="text-[11px] text-slate-300 bg-sky-950/20 border border-sky-900/60 rounded-lg px-3 py-2 space-y-1">
        <p>🧮 <b>Tamaño real de la tanda (suma de la fórmula):</b> <b class="text-sky-300 font-mono">${fmt(res.total)} ${u}</b>
           <span class="text-slate-500">· ≈ ${fmt(res.litros)} L / ${fmt(res.kilos)} kg${res.densidadMezcla ? ` · densidad estimada de la mezcla ${fmt(res.densidadMezcla, 3)} kg/L` : ''}</span></p>
        <p>${comparacion}</p>
        ${res.sinDensidad.length ? `<p class="text-amber-400/90">⚠ Sin densidad (se tomó como agua, 1 kg/L): ${res.sinDensidad.map(escaparHtml).join(', ')} — captúrala en ⚖️ Densidades para afinar el cálculo.</p>` : ''}
        ${res.ignorados.length ? `<p class="text-slate-500">No cuentan para el tamaño (no son volumen ni peso): ${res.ignorados.map(escaparHtml).join(', ')}.</p>` : ''}
        <p class="text-slate-500">Es teórico: al mezclar, el volumen real puede salir un poco menor. Mide la primera tanda en el tanque y, si difiere, captura lo medido. <a href="manual-costos-produccion.html#m-granel-rendimiento" target="_blank" class="text-sky-400 underline">¿Por qué importa el rendimiento?</a></p>
        ${densActual === undefined ? '' : htmlDensidadMezcla(res, densActual)}
        ${Math.abs(rend - sugerido) >= 0.005 ? `<button type="button" class="btn-usar-rend mt-1 text-[11px] bg-sky-700 hover:bg-sky-600 text-white font-semibold px-3 py-1 rounded-lg cursor-pointer" data-valor="${sugerido}">Usar ${fmt(sugerido, 2)} ${u} como Rendimiento del lote</button>` : ''}
    </div>`;
}

// Análisis de la fórmula GUARDADA de un producto (tamanoTeoricoTanda), para pantallas que no la traen cargada.
async function analizarFormulaGuardada(productoId) {
    try {
        const [rProd, rBom, rUm] = await Promise.all([
            supabaseClient.from('productos').select('unidad_medida_id').eq('id', productoId).single(),
            supabaseClient.from('bom').select('componente_id, cantidad_requerida, unidad_medida').eq('producto_id', productoId),
            supabaseClient.from('unidades_medida').select('id, nombre'),
        ]);
        if (rProd.error || rBom.error || rUm.error || !(rBom.data || []).length) return null;
        const mapaUni = new Map((rUm.data || []).map((u) => [String(u.id), u.nombre]));
        const ids = [...new Set(rBom.data.map((b) => b.componente_id))];
        const { data: comps } = await supabaseClient.from('productos').select('id, nombre, densidad_kg_l').in('id', ids);
        const porId = new Map((comps || []).map((c) => [c.id, c]));
        return tamanoTeoricoTanda(rBom.data.map((b) => {
            const c = porId.get(b.componente_id);
            const raw = String(b.unidad_medida ?? '');
            return { nombre: c ? c.nombre : `#${b.componente_id}`, cantidad: b.cantidad_requerida,
                unidadNombre: /^\d+$/.test(raw) ? (mapaUni.get(raw) || '') : raw, densidad: c?.densidad_kg_l };
        }), mapaUni.get(String(rProd.data.unidad_medida_id ?? '')) || '');
    } catch (_) { return null; }
}

// Advertencia al cambiar a mano la densidad de un semiterminado que ya se calcula de su fórmula: explica
// cómo salió y por qué no conviene cambiarla. Devuelve true si el usuario confirma el cambio.
function confirmarCambioDensidad(res, valorNuevo, nombreProducto) {
    const d = res?.densidadCalculada;
    const nuevo = Number(valorNuevo) || 0;
    if (!d || Math.abs(nuevo - d) < 0.0005) return true;
    const n = (x, dec = 3) => Number(x).toLocaleString('es-MX', { maximumFractionDigits: dec });
    const lineas = (res.detalle || []).map((r) =>
        `  • ${r.nombre}: ${n(r.litros)} L × ${n(r.densidad)}${r.supuesta ? ' (sin densidad, se tomó como agua)' : ''} = ${n(r.kilos)} kg`);
    const msg = `⚠ ${nombreProducto ? nombreProducto + ': l' : 'L'}a densidad de este semiterminado se calcula sola con su fórmula.\n\n`
        + `CÓMO SE CALCULÓ (${n(d)} kg/L):\n${lineas.join('\n')}\n  Total: ${n(res.kilos)} kg ÷ ${n(res.litros)} L = ${n(d)} kg/L\n\n`
        + `POR QUÉ NO CONVIENE CAMBIARLA${nuevo ? ` a ${n(nuevo, 4)}` : ' (dejarla vacía)'}:\n`
        + `  • Producción la usa para convertir litros ↔ kilos cuando un terminado pide este granel en otra unidad: un número distinto descuenta de más o de menos del inventario y el costo del terminado sale mal.\n`
        + `  • La calculada se actualiza sola si cambias la fórmula; una escrita a mano se queda fija y deja de coincidir con lo que realmente se mezcla.\n`
        + `  • Si el número no te cuadra, lo que hay que corregir es la densidad del insumo (⚖️ Densidades)${res.densidadFaltante?.length ? ` — sin densidad: ${res.densidadFaltante.join(', ')}` : ''}, no la del granel.\n`
        + `  • Solo conviene cambiarla si mediste la mezcla real (pesaste 1 litro del tanque).\n\n`
        + `¿Cambiarla de todos modos?`;
    return confirm(msg);
}

// Densidad del granel calculada de su fórmula (kg/L de la mezcla). `densActual` = lo capturado en "Densidad".
// Solo semiterminados: un producto terminado no la necesita (quien lo consume ya lo pide en su propia unidad);
// en htmlAnalisisTanda, densActual === undefined = no mostrar esta parte.
function htmlDensidadMezcla(res, densActual) {
    const fmt = (n) => Number(n).toLocaleString('es-MX', { maximumFractionDigits: 3 });
    const d = res.densidadCalculada;
    if (!d) {
        return res.densidadFaltante?.length
            ? '<p class="text-slate-500">⚖️ Densidad de la mezcla: no se puede calcular — ningún insumo de la fórmula tiene su densidad capturada (⚖️ Densidades).</p>'
            : '';
    }
    const actual = Number(densActual) || 0;
    const faltan = res.densidadFaltante.length
        ? `<span class="block text-amber-400/90">Sin densidad (contados como agua, 1 kg/L): ${res.densidadFaltante.map(escaparHtml).join(', ')}.</span>` : '';
    const estado = !actual
        ? '<span class="text-amber-300">— la "Densidad" del granel está vacía.</span>'
        : Math.abs(actual - d) < 0.0005
            ? '<span class="text-emerald-400">✅ Coincide con la "Densidad" capturada.</span>'
            : `<span class="text-amber-300">— capturada: ${fmt(actual)} kg/L.</span>`;
    const boton = Math.abs(actual - d) >= 0.0005
        ? `<button type="button" class="btn-usar-dens mt-1 mr-2 text-[11px] bg-sky-700 hover:bg-sky-600 text-white font-semibold px-3 py-1 rounded-lg cursor-pointer" data-valor="${d}">Usar ${fmt(d)} kg/L como Densidad</button>` : '';
    return `<p>⚖️ <b>Densidad de la mezcla (calculada de la fórmula):</b> <b class="text-sky-300 font-mono">${fmt(d)} kg/L</b> ${estado}${faltan}</p>${boton}`;
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

// Muestra, de solo lectura, las filas de producto_claves_proveedor de este
// producto (una por proveedor) — el SKU/UPC, descripción y unidad con que
// CADA proveedor lo vende. Genérico igual que la cuadrícula de arriba: no
// hay una lista fija de columnas, así que cualquier columna que se agregue
// después a esa tabla aparece sola, sin tocar este código. Para editarlas
// se usa el bloque "Claves de proveedor" del formulario de alta/edición
// (clic en la fila del producto) — aquí es solo consulta rápida.
function renderClavesProveedorResumen(filas, proveedores) {
    const mapaProv = new Map((proveedores || []).map((p) => [String(p.id), p.nombre]));
    const camposOcultos = new Set(['id', 'producto_id', 'proveedor_id']);
    const tarjeta = (fila) => {
        const claves = Object.keys(fila).filter((c) => !camposOcultos.has(c));
        return `
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3">
                <p class="text-xs font-semibold text-sky-300 mb-2">${escaparHtml(mapaProv.get(String(fila.proveedor_id)) || '(sin proveedor)')}</p>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    ${claves.map((clave) => `
                        <div>
                            <label class="block text-[10px] text-slate-500 mb-0.5">${etiquetaCampo(clave)}</label>
                            <p class="text-xs font-mono text-slate-300 break-all">${escaparHtml(fila[clave] ?? '—')}</p>
                        </div>`).join('')}
                </div>
            </div>`;
    };
    return `
        <div class="mt-4 pt-4 border-t border-slate-800">
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-2">Claves de proveedor <span class="font-normal">(edítalas desde el formulario de alta/edición — clic en la fila del producto)</span></p>
            ${filas && filas.length
                ? `<div class="grid grid-cols-1 sm:grid-cols-2 gap-3">${filas.map(tarjeta).join('')}</div>`
                : '<p class="text-xs text-slate-500 italic">Sin claves de proveedor capturadas para este producto.</p>'}
        </div>`;
}

// Componentes del BOM de este producto, solo consulta (se editan desde ☰ → Editar o ver BOM).
function renderBomResumen(filas, componentesPorId, unidades) {
    const mapaUni = new Map((unidades || []).map((u) => [String(u.id), u.nombre]));
    const fila = (b) => {
        const c = componentesPorId.get(b.componente_id);
        return `
            <tr class="border-t border-slate-800">
                <td class="py-1.5 px-3 text-slate-100">${escaparHtml(c ? c.nombre : `Elemento ID: ${b.componente_id}`)}${c && c.sku ? `<span class="block text-[10px] font-mono text-slate-500">${escaparHtml(c.sku)}</span>` : ''}</td>
                <td class="py-1.5 px-3 text-right font-mono text-slate-200">${escaparHtml(b.cantidad_requerida ?? '—')}</td>
                <td class="py-1.5 px-3 text-slate-400">${escaparHtml(mapaUni.get(String(b.unidad_medida)) || '—')}</td>
            </tr>`;
    };
    return `
        <div class="mt-4 pt-4 border-t border-slate-800">
            <p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-2">Componentes del BOM${filas.length ? ` (${filas.length})` : ''} <span class="font-normal normal-case">(para cambiarlos: menú ☰ → 🧪 Editar o ver BOM)</span></p>
            ${filas.length ? `
            <div class="bg-slate-900 border border-slate-800 rounded-lg overflow-hidden">
                <table class="w-full text-xs">
                    <thead>
                        <tr class="text-[10px] uppercase tracking-wider text-slate-500">
                            <th class="py-1.5 px-3 text-left font-semibold">Componente</th>
                            <th class="py-1.5 px-3 text-right font-semibold">Cantidad</th>
                            <th class="py-1.5 px-3 text-left font-semibold">Unidad</th>
                        </tr>
                    </thead>
                    <tbody>${filas.map(fila).join('')}</tbody>
                </table>
            </div>`
            : '<p class="text-xs text-slate-500 italic">Sin componentes: este producto todavía no tiene BOM.</p>'}
        </div>`;
}

async function abrirResumenCompletoProducto(id, nombreConocido, skuConocido, soloLectura = false) {
    // Ctrl/Cmd + clic en "Ver"/"Editar artículo": abre una instancia aparte, sin
    // tocar la que ya esté abierta (window.idSubventana, subventanas-movibles.js).
    const idModal = window.idSubventana('modalResumenProducto');
    let modal = document.getElementById(idModal);
    if (!modal) {
        modal = document.createElement('div');
        modal.id = idModal;
        document.body.appendChild(modal);
    }
    // Subventana flotante (no un modal de pantalla completa): sin fondo
    // oscuro que tape el resto de la app — los menús/riel de atrás se
    // siguen viendo y usando.
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '42rem';
    modal.innerHTML = `
        <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-center rounded-t-2xl gap-3">
            <h3 class="text-sm font-bold text-slate-200 truncate">${soloLectura ? 'Ver artículo' : 'Editar artículo'}<span id="tituloEditarProdSub" class="text-slate-500 font-normal"> — #${id}${skuConocido ? ' · ' + escaparHtml(skuConocido) : ''}${nombreConocido ? ' · ' + escaparHtml(nombreConocido) : ''}</span></h3>
            <button type="button" id="btnCerrarResumenProd" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer shrink-0">&times;</button>
        </div>
        <div id="cuerpoResumenProd" class="p-5 overflow-y-auto flex-1 text-sm text-slate-300">Cargando…</div>
        <div class="bg-slate-950 px-5 py-3 border-t border-slate-800 flex justify-between items-center rounded-b-2xl">
            ${soloLectura
                ? `<span id="rc_activo_texto" class="text-xs text-slate-300">Activo: —</span>`
                : `<label class="flex items-center gap-2 text-xs text-slate-300 cursor-pointer">
                    <input type="checkbox" id="rc_activo" data-campo="activo" data-tipo="boolean" class="campo-resumen-prod w-4 h-4">
                    Activo
                   </label>`}
            <div class="flex gap-2">
                <button type="button" id="btnCancelarResumenProd" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Cerrar</button>
                ${soloLectura ? '' : '<button type="button" id="btnGuardarResumenProd" class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Guardar cambios</button>'}
            </div>
        </div>
    `;
    modal.classList.remove('hidden');

    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('#btnCerrarResumenProd').addEventListener('click', cerrar);
    modal.querySelector('#btnCancelarResumenProd').addEventListener('click', cerrar);
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    // Ids internos del template (cuerpoResumenProd, rc_activo...) se repiten
    // literalmente si hay una segunda instancia abierta con Ctrl+clic — SIEMPRE
    // se buscan escopados a "modal" (esta instancia), nunca por document.getElementById.
    const cuerpo = modal.querySelector('#cuerpoResumenProd');
    // Si este mismo producto se guarda desde otra subventana abierta a la vez
    // (Alta de artículo o ☰ "Editar o ver BOM"), esta se vuelve a pintar con el
    // dato fresco en vez de quedarse con el que tenía al abrirse.
    window.refrescarResumenSiEsProducto = async function(idAfectado) {
        if (!document.getElementById('modalResumenProducto') || Number(idAfectado) !== Number(id)) return;
        await abrirResumenCompletoProducto(id, nombreConocido, skuConocido, soloLectura);
    };
    try {
        const [{ data: art, error }, resProv, resMon, resUm, resCta, resClaves, resBom] = await Promise.all([
            supabaseClient.from('productos').select('*').eq('id', id).single(),
            supabaseClient.from('proveedores').select('id, nombre').order('nombre', { ascending: true }),
            supabaseClient.from('monedas').select('id, codigo').order('id', { ascending: true }),
            supabaseClient.from('unidades_medida').select('id, nombre').order('id', { ascending: true }),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre').order('codigo', { ascending: true }),
            supabaseClient.from('producto_claves_proveedor').select('*').eq('producto_id', id),
            supabaseClient.from('bom').select('componente_id, cantidad_requerida, unidad_medida').eq('producto_id', id).order('id', { ascending: true }),
        ]);
        if (error) throw error;

        // Componentes del BOM (solo lectura) — únicamente para lo que se fabrica.
        const llevaBom = ['producto', 'semiterminado'].includes(art.tipo || 'producto') && art.abastecimiento !== 'comprado';
        const bomFilas = llevaBom ? (resBom.data || []) : [];
        let componentesPorId = new Map();
        if (bomFilas.length) {
            const idsComp = [...new Set(bomFilas.map((b) => b.componente_id))];
            let { data: comps, error: errComps } = await supabaseClient.from('productos').select('id, nombre, sku, densidad_kg_l').in('id', idsComp);
            if (errComps) ({ data: comps } = await supabaseClient.from('productos').select('id, nombre, sku').in('id', idsComp));
            componentesPorId = new Map((comps || []).map((c) => [c.id, c]));
        }

        const tituloSub = modal.querySelector('#tituloEditarProdSub');
        if (tituloSub) tituloSub.textContent = ` — #${art.id} · ${art.sku || 'sin SKU'} · ${art.nombre || 'sin nombre'}`;

        // "Activo" vive fijo en el pie (no se va con el scroll) — se marca
        // aparte, no como un campo más de la cuadrícula de abajo.
        const chkActivo = modal.querySelector('#rc_activo');
        if (chkActivo) chkActivo.checked = !!art.activo;
        const txtActivo = modal.querySelector('#rc_activo_texto');
        if (txtActivo) txtActivo.textContent = `Activo: ${art.activo ? 'Sí' : 'No'}`;

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

        // Solo para "Ver artículo": el texto ya resuelto de cada llave
        // foránea, para no mostrar el número interno en modo lectura.
        const buscarEnLista = (lista, valorId, textoFn) => {
            const fila = (lista || []).find((r) => String(r.id) === String(valorId));
            return fila ? textoFn(fila) : null;
        };
        const etiquetaSelectPorCampo = {
            proveedor_id: buscarEnLista(resProv.data, art.proveedor_id, (r) => r.nombre),
            moneda_id: buscarEnLista(resMon.data, art.moneda_id, (r) => r.codigo),
            unidad_medida_id: buscarEnLista(resUm.data, art.unidad_medida_id, (r) => r.nombre),
            cuenta_inventario_id: buscarEnLista(resCta.data, art.cuenta_inventario_id, (r) => `${r.codigo} · ${r.nombre}`),
            cuenta_costo_id: buscarEnLista(resCta.data, art.cuenta_costo_id, (r) => `${r.codigo} · ${r.nombre}`),
        };

        // "activo" ya no va en la cuadrícula: vive fijo en el pie del modal
        // (ver checkbox #rc_activo), siempre visible sin importar el scroll.
        // El resto sigue el orden lógico de ORDEN_CAMPOS_PRODUCTO; los de
        // solo lectura (id, created_at, updated_at) siempre al final.
        // Densidad y Requiere caducidad no aplican a Producto terminado (ver bloqueProdDensidad/
        // bloqueProdCaducidad en el formulario de alta): el granel ya llega en la unidad que pide
        // su BOM. Rendimiento del lote es solo de quien tiene su propia fórmula/BOM (el
        // semiterminado) — materia prima e insumo son componentes de esa fórmula, no aplica.
        const camposOcultosPorTipo = new Set(
            art.tipo === 'producto' ? ['densidad_kg_l', 'rendimiento_lote_bom', 'requiere_caducidad'] : []
        );
        if (art.tipo !== 'semiterminado') camposOcultosPorTipo.add('rendimiento_lote_bom');
        const claves = Object.keys(art)
            .filter((c) => c !== 'activo' && !CAMPOS_OCULTOS_PRODUCTO.has(c) && !camposOcultosPorTipo.has(c))
            .sort((a, b) => {
                const soloLecturaA = CAMPOS_NO_EDITABLES_PRODUCTO.has(a);
                const soloLecturaB = CAMPOS_NO_EDITABLES_PRODUCTO.has(b);
                if (soloLecturaA !== soloLecturaB) return soloLecturaA ? 1 : -1;
                const iA = ORDEN_CAMPOS_PRODUCTO.indexOf(a);
                const iB = ORDEN_CAMPOS_PRODUCTO.indexOf(b);
                if (iA === -1 && iB === -1) return a.localeCompare(b);
                if (iA === -1) return 1;
                if (iB === -1) return -1;
                return iA - iB;
            });
        cuerpo.innerHTML = `
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                ${claves.map((clave) => {
                    const valor = art[clave];
                    const campoSoloLectura = soloLectura || CAMPOS_NO_EDITABLES_PRODUCTO.has(clave);
                    const tipo = tipoDeCampo(valor);

                    if (campoSoloLectura) {
                        let textoMostrado = valor;
                        if (clave === 'tipo') textoMostrado = ETIQUETA_TIPO_PRODUCTO[valor] || valor;
                        else if (etiquetaSelectPorCampo[clave] !== undefined) textoMostrado = etiquetaSelectPorCampo[clave];
                        else if (tipo === 'boolean') textoMostrado = valor ? 'Sí' : 'No';
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-500 mb-1">${etiquetaCampo(clave)}</label>
                                <p class="text-xs font-mono text-slate-200 bg-slate-800 border border-slate-700 rounded-lg px-2 py-1.5 break-all">${escaparHtml(textoMostrado ?? '—')}</p>
                                ${pistaCampo(clave)}
                            </div>`;
                    }
                    if (clave === 'tipo') {
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                                <select id="rc_${clave}" data-campo="${clave}" data-tipo="text" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    <option value="producto" ${valor === 'producto' ? 'selected' : ''}>Producto terminado</option>
                                    <option value="semiterminado" ${valor === 'semiterminado' ? 'selected' : ''}>Semiterminado (granel)</option>
                                    <option value="materia_prima" ${valor === 'materia_prima' ? 'selected' : ''}>Materia prima</option>
                                    <option value="insumo" ${valor === 'insumo' ? 'selected' : ''}>Insumo</option>
                                </select>
                                ${pistaCampo(clave)}
                            </div>`;
                    }
                    if (opcionesPorCampo[clave]) {
                        return `
                            <div>
                                <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                                <select id="rc_${clave}" data-campo="${clave}" data-tipo="number" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                                    ${opcionesPorCampo[clave]}
                                </select>
                                ${pistaCampo(clave)}
                            </div>`;
                    }
                    if (tipo === 'boolean') {
                        return `
                            <div class="pt-4">
                                <div class="flex items-center gap-2">
                                    <input type="checkbox" id="rc_${clave}" data-campo="${clave}" data-tipo="boolean" class="campo-resumen-prod w-4 h-4" ${valor ? 'checked' : ''}>
                                    <label for="rc_${clave}" class="text-xs text-slate-300">${etiquetaCampo(clave)}</label>
                                </div>
                                ${pistaCampo(clave)}
                            </div>`;
                    }
                    return `
                        <div>
                            <label class="block text-[10px] text-slate-400 mb-1">${etiquetaCampo(clave)}</label>
                            <input type="${tipo === 'number' ? 'number' : 'text'}" ${tipo === 'number' ? 'step="any"' : ''} id="rc_${clave}" data-campo="${clave}" data-tipo="${tipo}" value="${escaparHtml(valor ?? '')}" class="campo-resumen-prod w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                            ${pistaCampo(clave)}
                        </div>`;
                }).join('')}
            </div>
            ${llevaBom ? renderBomResumen(bomFilas, componentesPorId, resUm.data) : ''}
            ${renderClavesProveedorResumen(resClaves.data, resProv.data)}`;

        // Granel: revisión arriba (✅/⚠ por punto) + tamaño real de la tanda junto al campo "Rendimiento del
        // lote", con botón que lo llena (se guarda con "Guardar cambios"). Se recalcula al editar los campos.
        const esGranel = art.tipo === 'semiterminado' || /granel/i.test(art.nombre || '');
        if (esGranel && llevaBom) {
            const mapaUni = new Map((resUm.data || []).map((u) => [String(u.id), u.nombre]));
            const mapaCta = new Map((resCta.data || []).map((c) => [String(c.id), c]));
            const val = (campo, porDefecto) => {
                const el = cuerpo.querySelector(`#rc_${campo}`);
                if (!el) return porDefecto;
                return el.type === 'checkbox' ? el.checked : el.value;
            };
            const calcular = (uniProd) => bomFilas.length ? tamanoTeoricoTanda(bomFilas.map((b) => {
                const c = componentesPorId.get(b.componente_id);
                const raw = String(b.unidad_medida ?? '');
                return { nombre: c ? c.nombre : `#${b.componente_id}`, cantidad: b.cantidad_requerida,
                    unidadNombre: /^\d+$/.test(raw) ? (mapaUni.get(raw) || '') : raw, densidad: c?.densidad_kg_l };
            }), uniProd) : null;

            const contGuia = document.createElement('div');
            contGuia.id = 'rcGuiaGranel';
            cuerpo.prepend(contGuia);
            // Justo antes del campo "Densidad" (a todo lo ancho): declara en qué Unidad de Medida quedó el
            // artículo, porque ese selector vive más abajo (ORDEN_CAMPOS_PRODUCTO) y sin esto Densidad y
            // Rendimiento del lote se capturan "a ciegas" sin ver qué unidad aplica.
            const campoDens = cuerpo.querySelector('#rc_densidad_kg_l');
            const contUnidad = document.createElement('div');
            contUnidad.id = 'rcUnidadDeclarada';
            contUnidad.className = 'sm:col-span-2';
            if (campoDens?.parentElement) campoDens.parentElement.insertAdjacentElement('beforebegin', contUnidad);
            else cuerpo.appendChild(contUnidad);
            // Justo debajo del campo "Rendimiento del lote", a todo lo ancho: ahí es donde se decide el número.
            const campoRend = cuerpo.querySelector('#rc_rendimiento_lote_bom');
            const contAn = document.createElement('div');
            contAn.id = 'rcAnalisisTanda';
            contAn.className = 'sm:col-span-2';
            if (campoRend?.parentElement) campoRend.parentElement.insertAdjacentElement('afterend', contAn);
            else cuerpo.appendChild(contAn);

            const pintarGranel = () => {
                const uniProd = mapaUni.get(String(val('unidad_medida_id', art.unidad_medida_id) ?? '')) || '';
                contUnidad.innerHTML = uniProd
                    ? `<p class="text-[11px] bg-sky-950/40 border border-sky-800/60 text-sky-300 rounded-lg px-2.5 py-1.5">📏 Unidad de medida preseleccionada: <b>${escaparHtml(uniProd)}</b> — Densidad y Rendimiento del lote (de abajo) se declaran en esa unidad.</p>`
                    : `<p class="text-[11px] bg-amber-950/40 border border-amber-800/60 text-amber-300 rounded-lg px-2.5 py-1.5">⚠ Aún sin Unidad de Medida — elígela abajo primero: Densidad y Rendimiento del lote dependen de ella.</p>`;
                const res = calcular(uniProd);
                const rend = val('rendimiento_lote_bom', art.rendimiento_lote_bom);
                // Densidad vacía: se llena sola con la de la mezcla (se guarda con "Guardar cambios").
                const elDens = cuerpo.querySelector('#rc_densidad_kg_l');
                const esSemi = val('tipo', art.tipo) === 'semiterminado';
                if (esSemi && elDens && !soloLectura && res?.densidadCalculada && !elDens.dataset.manual && (!elDens.value || elDens.dataset.auto === elDens.value)) {
                    elDens.value = String(res.densidadCalculada);
                    elDens.dataset.auto = elDens.value;
                }
                const cta = mapaCta.get(String(val('cuenta_inventario_id', art.cuenta_inventario_id) ?? ''));
                contGuia.innerHTML = htmlGuiaGranel({
                    esSemi: val('tipo', art.tipo) === 'semiterminado', unidadNombre: uniProd,
                    nComponentes: bomFilas.length, rend, res,
                    cuentaCodigo: cta?.codigo || '', cuentaNombre: cta?.nombre || '',
                    cuentaConocida: 'cuenta_inventario_id' in art, enBom: false, stock: art.stock_actual,
                });
                contAn.innerHTML = res ? htmlAnalisisTanda(res, uniProd, rend, esSemi ? (val('densidad_kg_l', art.densidad_kg_l) ?? '') : undefined) : '';
                const btnDens = contAn.querySelector('.btn-usar-dens');
                if (btnDens && soloLectura) btnDens.remove();
                else btnDens?.addEventListener('click', (e) => {
                    e.stopPropagation();   // el recuadro se re-dibuja: que no cuente como "clic fuera" de la subventana
                    const el = cuerpo.querySelector('#rc_densidad_kg_l');
                    if (!el) return;
                    el.value = e.currentTarget.dataset.valor;
                    el.dataset.auto = el.value;
                    delete el.dataset.manual;
                    el.classList.add('ring-2', 'ring-sky-500');
                    setTimeout(() => el.classList.remove('ring-2', 'ring-sky-500'), 1500);
                    pintarGranel();
                });
                const btn = contAn.querySelector('.btn-usar-rend');
                if (!btn) return;
                if (soloLectura) { btn.remove(); return; }
                btn.insertAdjacentHTML('afterend', '<span class="text-[10px] text-slate-500 ml-2">Luego da "Guardar cambios".</span>');
                btn.addEventListener('click', (e) => {
                    e.stopPropagation();   // el recuadro se re-dibuja: que no cuente como "clic fuera" de la subventana
                    const elRend = cuerpo.querySelector('#rc_rendimiento_lote_bom');
                    if (!elRend) return;
                    elRend.value = e.currentTarget.dataset.valor;
                    elRend.classList.add('ring-2', 'ring-sky-500');
                    setTimeout(() => elRend.classList.remove('ring-2', 'ring-sky-500'), 1500);
                    pintarGranel();
                });
            };
            pintarGranel();
            cuerpo.querySelector('#rc_densidad_kg_l')?.addEventListener('change', (e) => {
                const el = e.target;
                const uniProd = mapaUni.get(String(val('unidad_medida_id', art.unidad_medida_id) ?? '')) || '';
                const res = calcular(uniProd);
                if (val('tipo', art.tipo) === 'semiterminado' && res?.densidadCalculada && el.dataset.auto !== el.value
                    && !confirmarCambioDensidad(res, el.value, art.nombre)) {
                    el.value = String(res.densidadCalculada);
                    el.dataset.auto = el.value;
                } else {
                    delete el.dataset.auto;
                    el.dataset.manual = '1';
                }
                pintarGranel();
            });
            ['unidad_medida_id', 'rendimiento_lote_bom', 'tipo', 'cuenta_inventario_id'].forEach((campo) => {
                const el = cuerpo.querySelector(`#rc_${campo}`);
                el?.addEventListener('input', pintarGranel);
                el?.addEventListener('change', pintarGranel);
            });
        }
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">No se pudo cargar el artículo: ${err.message || err}</p>`;
        return;
    }

    const btnGuardarResumenProd = modal.querySelector('#btnGuardarResumenProd');
    if (!btnGuardarResumenProd) return;
    btnGuardarResumenProd.addEventListener('click', async () => {
        const payload = {};
        modal.querySelectorAll('.campo-resumen-prod').forEach((input) => {
            const clave = input.dataset.campo;
            if (input.dataset.tipo === 'boolean') {
                payload[clave] = input.checked;
            } else if (input.dataset.tipo === 'number') {
                payload[clave] = input.value === '' ? null : Number(input.value);
            } else {
                payload[clave] = input.value === '' ? null : input.value;
            }
        });

        const btnGuardar = modal.querySelector('#btnGuardarResumenProd');
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
        if (typeof window.refrescarFormularioSiEsProducto === 'function') await window.refrescarFormularioSiEsProducto(id);
        if (typeof window.refrescarBomSiEsProducto === 'function') await window.refrescarBomSiEsProducto(id);
        const { data: mapaUnidadesActual } = await supabaseClient.from('unidades_medida').select('id, nombre');
        const mapaUnidades = {};
        (mapaUnidadesActual || []).forEach((u) => { mapaUnidades[u.id] = u.nombre; });
        await renderizarTablaProductos(mapaUnidades);
    });
}