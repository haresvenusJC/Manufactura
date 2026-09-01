import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto, registrarMovimientoAlmacen } from './inventario.js';

let partidasSalidaTemp = [];
let listaProductosGlobal = [];
let productoSeleccionadoActual = null;
let loteSeleccionadoActual = null;
let historialSalidasCache = [];

export async function cargarModuloSalidas() {
    const contenedor = document.getElementById('contenedorSalidas') || document.getElementById('contenedorPrincipal');
    
    try {
        if (!supabaseClient) return;

        if (contenedor) {
            contenedor.innerHTML = `
                <div class="space-y-6 max-w-5xl mx-auto">
                    <!-- Formulario Maestro de Salidas -->
                    <div class="bg-slate-950 border border-slate-800 p-6 rounded-xl shadow-xl">
                        <h3 class="text-lg font-semibold mb-4 text-red-400 flex items-center gap-2">📦 Registrar Salida de Inventario (Multi-Partida)</h3>
                        
                        <!-- Datos Generales del Documento -->
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6 bg-slate-900/60 p-4 rounded-lg border border-slate-800">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">TIPO DE SALIDA</label>
                                <select id="tipoSalida" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-red-500" required>
                                    <option value="salida_venta">Salida por Venta</option>
                                    <option value="merma">Salida por Merma</option>
                                    <option value="salida">Salida de Inventario (General)</option>
                                    <option value="ajuste">Ajuste de Inventario (Negativo)</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">FOLIO / REFERENCIA</label>
                                <input type="text" id="folioSalida" placeholder="Ej: VTA-2026-001" autocomplete="off" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-red-500" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">DESCRIPCIÓN / MOTIVO GENERAL</label>
                                <input type="text" id="descripcionSalida" placeholder="Motivo general del documento..." class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-red-500">
                            </div>
                        </div>

                        <!-- Sección de Búsqueda AJAX y Selección por Lotes -->
                        <div class="bg-slate-900 border border-slate-800 p-4 rounded-lg mb-6 relative">
                            <h4 class="text-xs font-semibold text-amber-400 mb-3 uppercase tracking-wider">🔍 1. Buscar Producto (Buscador AJAX)</h4>
                            
                            <div class="relative mb-3">
                                <input type="text" id="buscadorAjaxProducto" placeholder="Escribe el nombre o SKU del producto..." autocomplete="off" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2.5 text-sm text-slate-100 focus:outline-none focus:border-amber-500">
                                <div id="sugerenciasAjax" class="absolute left-0 right-0 top-full mt-1 bg-slate-950 border border-slate-800 rounded-lg shadow-2xl max-h-48 overflow-y-auto z-50 hidden"></div>
                            </div>

                            <!-- Producto Seleccionado Info -->
                            <div id="infoProductoSeleccionado" class="hidden mb-4 p-3 bg-slate-950 border border-amber-500/40 rounded-lg flex items-center justify-between">
                                <div>
                                    <span class="text-xs text-slate-400 block">Producto activo:</span>
                                    <span id="nombreProdSeleccionadoText" class="text-sm font-bold text-amber-300"></span>
                                </div>
                                <button type="button" id="btnCambiarProducto" class="text-xs text-slate-400 hover:text-white underline cursor-pointer">Cambiar</button>
                            </div>

                            <!-- 2. Seleccionar Lote -->
                            <div id="seccionLotesAjax" class="mb-4 hidden">
                                <label class="block text-xs font-semibold text-slate-400 mb-2 uppercase tracking-wider">📦 2. Selecciona el Lote a Afectar:</label>
                                <div id="contenedorListaLotes" class="grid grid-cols-1 sm:grid-cols-2 gap-2 max-h-44 overflow-y-auto"></div>
                            </div>

                            <!-- 3. Cantidad -->
                            <div id="seccionCantidadAjax" class="mb-4 hidden">
                                <label class="block text-xs font-semibold text-slate-400 mb-1 uppercase tracking-wider">🔢 3. Ingresa la Cantidad para este Lote:</label>
                                <div class="flex items-center gap-3">
                                    <input type="number" id="inputCantidadLote" min="0.0001" step="any" placeholder="Ej: 5" class="w-full md:w-1/3 bg-slate-950 border border-slate-800 rounded-lg p-2.5 text-sm text-slate-100 focus:outline-none focus:border-amber-500 font-mono">
                                    <span id="lblStockMaxLote" class="text-xs text-slate-400 font-mono"></span>
                                </div>
                            </div>

                            <button type="button" id="btnAgregarPartidaLista" class="hidden w-full bg-amber-600 hover:bg-amber-500 text-white font-semibold py-2.5 px-4 rounded-lg text-xs transition-all shadow-md cursor-pointer">
                                ➕ Añadir Partida al Documento Actual
                            </button>
                        </div>

                        <!-- Tabla de Partidas Agregadas -->
                        <div class="mb-6">
                            <h4 class="text-xs font-semibold text-slate-400 mb-2 uppercase tracking-wider">📋 Partidas en el Documento Actual</h4>
                            <div class="overflow-x-auto border border-slate-800 rounded-lg bg-slate-900">
                                <table class="w-full text-left text-sm text-slate-300">
                                    <thead class="bg-slate-950 text-slate-400 text-xs border-b border-slate-800">
                                        <tr>
                                            <th class="p-2.5">Producto</th>
                                            <th class="p-2.5">Lote Afectado</th>
                                            <th class="p-2.5">Cantidad</th>
                                            <th class="p-2.5">Costo Unit.</th>
                                            <th class="p-2.5 text-right">Acción</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tablaPartidasTempBody">
                                        <tr><td colspan="5" class="p-4 text-center text-slate-500 italic text-xs">No hay partidas agregadas todavía.</td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Bloque de contabilidad -->
                        <div id="salBloqueContable" class="bg-slate-950 border border-slate-800 p-4 rounded-lg mb-4 hidden">
                            <label class="flex items-center gap-2 text-sm font-semibold text-slate-200 mb-3">
                                <input type="checkbox" id="salContabilizar" checked class="accent-red-500"> Generar póliza contable
                            </label>
                            <div id="salCamposCosto" class="mb-3">
                                <label class="block text-xs text-slate-400 mb-1">Cuenta destino del costo (cargo)</label>
                                <select id="salCuentaCargo" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                                <p class="text-[11px] text-slate-500 mt-1">A dónde va el costo de lo que sale: 501.01 costo de venta, 601.xx merma, cuenta de ajuste… El inventario se abona a la cuenta de cada producto.</p>
                            </div>
                            <div id="salCamposVenta" class="hidden grid grid-cols-1 md:grid-cols-3 gap-3 border-t border-slate-800 pt-3">
                                <div><label class="block text-xs text-slate-400 mb-1">Cliente</label>
                                    <input type="text" id="salClienteNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                                <div><label class="block text-xs text-slate-400 mb-1">RFC cliente</label>
                                    <input type="text" id="salClienteRfc" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                                <div><label class="block text-xs text-slate-400 mb-1">Condición</label>
                                    <select id="salCondicion" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                        <option value="contado">Contado</option><option value="credito">Crédito (por cobrar)</option></select></div>
                                <div><label class="block text-xs text-slate-400 mb-1">Subtotal venta</label>
                                    <input type="number" step="0.01" min="0" id="salVentaSubtotal" value="0" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                                <div><label class="block text-xs text-slate-400 mb-1">IVA <button type="button" id="salIva16" class="text-[10px] text-red-400 hover:underline">16%</button></label>
                                    <input type="number" step="0.01" min="0" id="salVentaIva" value="0" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                                <div><label class="block text-xs text-slate-400 mb-1">Cobrar a (cuenta)</label>
                                    <select id="salCuentaCobro" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select></div>
                                <div class="md:col-span-3"><label class="block text-xs text-slate-400 mb-1">UUID CFDI</label>
                                    <input type="text" id="salUuid" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
                            </div>
                        </div>

                        <!-- Botón Final -->
                        <button type="button" id="btnProcesarSalidaFinal" class="w-full bg-red-600 hover:bg-red-500 text-white font-semibold py-3 px-4 rounded-lg transition-all text-sm shadow-lg cursor-pointer">
                            🚀 Procesar y Guardar Salida Completa
                        </button>
                    </div>

                    <!-- Historial -->
                    <div class="bg-slate-950 border border-slate-800 p-6 rounded-xl shadow-xl">
                        <h3 class="text-lg font-semibold text-red-400 flex items-center gap-2 mb-4">📋 Historial de Salidas Registradas</h3>
                        <div id="contenedorHistorialSalidas">
                            <p class="text-slate-400 text-sm">Cargando historial...</p>
                        </div>
                    </div>
                </div>
            `;

            partidasSalidaTemp = [];
            productoSeleccionadoActual = null;
            loteSeleccionadoActual = null;

            cargarBloqueContableSalidas();

            let { data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select('id, nombre, sku, stock_actual, precio_venta, tasa_iva');
            if (errProd) {
                // columnas nuevas aun no creadas: cae al select basico
                ({ data: productos, error: errProd } = await supabaseClient
                    .from('productos')
                    .select('id, nombre, sku, stock_actual'));
            }
            if (!errProd && productos) {
                listaProductosGlobal = productos;
            }

            const inputBuscador = document.getElementById('buscadorAjaxProducto');
            const contenedorSugerencias = document.getElementById('sugerenciasAjax');

            inputBuscador.oninput = (e) => {
                const termino = e.target.value.toLowerCase().trim();
                if (termino.length === 0) {
                    contenedorSugerencias.classList.add('hidden');
                    contenedorSugerencias.innerHTML = '';
                    return;
                }

                // Limitar a máximo 15 coincidencias para mejor rendimiento
                const filtrados = listaProductosGlobal.filter(p => 
                    (p.nombre && p.nombre.toLowerCase().includes(termino)) || 
                    (p.sku && p.sku.toLowerCase().includes(termino))
                ).slice(0, 15);

                if (filtrados.length === 0) {
                    contenedorSugerencias.innerHTML = `<div class="p-3 text-xs text-slate-400 italic">No se encontraron productos</div>`;
                    contenedorSugerencias.classList.remove('hidden');
                    return;
                }

                let htmlSugg = '';
                filtrados.forEach(p => {
                    htmlSugg += `
                        <div class="p-2.5 text-xs text-slate-200 hover:bg-slate-900 cursor-pointer border-b border-slate-900 flex justify-between items-center item-sugerencia-prod" data-id="${p.id}" data-nombre="${p.nombre.replace(/"/g, '&quot;')}">
                            <span class="font-medium">${p.nombre}</span>
                            <span class="text-emerald-400 font-mono">Stock: ${p.stock_actual || 0}</span>
                        </div>
                    `;
                });
                contenedorSugerencias.innerHTML = htmlSugg;
                contenedorSugerencias.classList.remove('hidden');

                document.querySelectorAll('.item-sugerencia-prod').forEach(el => {
                    el.onclick = () => {
                         seleccionarProducto(Number(el.dataset.id), el.dataset.nombre);
                         contenedorSugerencias.classList.add('hidden');
                         inputBuscador.value = '';
                    };
                });
            };

            document.addEventListener('click', (e) => {
                if (!inputBuscador.contains(e.target) && !contenedorSugerencias.contains(e.target)) {
                    contenedorSugerencias.classList.add('hidden');
                }
            });

            document.getElementById('btnCambiarProducto').onclick = () => {
                productoSeleccionadoActual = null;
                loteSeleccionadoActual = null;
                document.getElementById('infoProductoSeleccionado').classList.add('hidden');
                document.getElementById('buscadorAjaxProducto').parentElement.classList.remove('hidden');
                document.getElementById('seccionLotesAjax').classList.add('hidden');
                document.getElementById('seccionCantidadAjax').classList.add('hidden');
                document.getElementById('btnAgregarPartidaLista').classList.add('hidden');
            };

            document.getElementById('btnAgregarPartidaLista').onclick = () => {
                if (!productoSeleccionadoActual || !loteSeleccionadoActual) {
                    alert("⚠️ Selecciona un producto y un lote válido.");
                    return;
                }

                const cantidadReq = Number(document.getElementById('inputCantidadLote').value);
                if (isNaN(cantidadReq) || cantidadReq <= 0) {
                    alert("⚠️ Ingresa una cantidad válida mayor a 0.");
                    return;
                }

                // Verificar si ya se agregaron partidas previas de este mismo lote en la lista actual
                const yaAcumuladoEnLista = partidasSalidaTemp
                    .filter(p => p.loteId === loteSeleccionadoActual.id)
                    .reduce((acc, p) => acc + p.cantidad, 0);

                if ((cantidadReq + yaAcumuladoEnLista) > loteSeleccionadoActual.stock) {
                    alert(`⚠️ La cantidad total (${cantidadReq + yaAcumuladoEnLista}) excede el stock disponible en este lote (${loteSeleccionadoActual.stock}).`);
                    return;
                }

                const prodInfo = listaProductosGlobal.find(p => p.id === productoSeleccionadoActual.id) || {};
                partidasSalidaTemp.push({
                    productoId: productoSeleccionadoActual.id,
                    productoNombre: productoSeleccionadoActual.nombre,
                    loteId: loteSeleccionadoActual.id,
                    numeroLote: loteSeleccionadoActual.numeroLote,
                    cantidad: cantidadReq,
                    costoUnitario: loteSeleccionadoActual.costo,
                    precioVenta: (prodInfo.precio_venta === null || prodInfo.precio_venta === undefined) ? null : Number(prodInfo.precio_venta),
                    tasaIva: (prodInfo.tasa_iva === null || prodInfo.tasa_iva === undefined) ? null : Number(prodInfo.tasa_iva),
                });

                renderizarTablaPartidasTemp();
                recalcularVentaDesdePartidas();

                document.getElementById('inputCantidadLote').value = '';
                document.getElementById('seccionCantidadAjax').classList.add('hidden');
                document.getElementById('btnAgregarPartidaLista').classList.add('hidden');
                loteSeleccionadoActual = null;
                
                document.querySelectorAll('.card-lote-opcion').forEach(c => c.classList.remove('border-amber-500', 'bg-amber-950/25'));
            };

            document.getElementById('btnProcesarSalidaFinal').onclick = async () => {
                const tipoMovimiento = document.getElementById('tipoSalida').value;
                const folio = document.getElementById('folioSalida').value.trim();
                const descripcion = document.getElementById('descripcionSalida').value.trim();

                if (!folio) {
                    alert("❌ El campo Folio / Referencia es obligatorio.");
                    return;
                }

                if (partidasSalidaTemp.length === 0) {
                    alert("❌ Debes agregar al menos una partida a la lista antes de procesar.");
                    return;
                }

                const btnFinal = document.getElementById('btnProcesarSalidaFinal');
                btnFinal.disabled = true;
                btnFinal.textContent = "Procesando documento completo...";

                try {
                    const resultado = await registrarSalidaMultiPartida({
                        tipoMovimiento,
                        folio,
                        descripcion,
                        partidas: partidasSalidaTemp
                    });

                    if (resultado.success) {
                        const msgContab = await contabilizarSalidaUI(tipoMovimiento, resultado.documentoId);
                        alert("✅ " + resultado.mensaje + msgContab);
                        partidasSalidaTemp = [];
                        document.getElementById('folioSalida').value = '';
                        document.getElementById('descripcionSalida').value = '';
                        renderizarTablaPartidasTemp();
                        
                        document.getElementById('btnCambiarProducto').click();
                        await cargarHistorialSalidas();
                        if (typeof cargarInventarioCompleto === 'function') {
                            cargarInventarioCompleto();
                        }
                    } else {
                        alert("❌ Error: " + resultado.error);
                    }
                } catch (ex) {
                    alert("❌ Error crítico: " + ex.message);
                } finally {
                    btnFinal.disabled = false;
                    btnFinal.textContent = "🚀 Procesar y Guardar Salida Completa";
                }
            };
        }

        await cargarHistorialSalidas();

    } catch (err) {
        console.error("Error al inicializar salidas:", err);
    }
}

async function seleccionarProducto(id, nombre) {
    productoSeleccionadoActual = { id, nombre };
    
    document.getElementById('buscadorAjaxProducto').parentElement.classList.add('hidden');
    document.getElementById('nombreProdSeleccionadoText').textContent = nombre;
    document.getElementById('infoProductoSeleccionado').classList.remove('hidden');

    const contenedorLotes = document.getElementById('contenedorListaLotes');
    contenedorLotes.innerHTML = `<p class="text-xs text-slate-400 italic p-2">Cargando lotes disponibles...</p>`;
    document.getElementById('seccionLotesAjax').classList.remove('hidden');
    document.getElementById('seccionCantidadAjax').classList.add('hidden');
    document.getElementById('btnAgregarPartidaLista').classList.add('hidden');

    const { data: lotes, error } = await supabaseClient
        .from('lotes_inventario')
        .select('id, numero_lote, stock_actual, costo_unitario, fecha_ingreso')
        .eq('producto_id', id)
        .gt('stock_actual', 0)
        .order('fecha_ingreso', { ascending: true });

    if (error || !lotes || lotes.length === 0) {
        contenedorLotes.innerHTML = `<p class="text-xs text-red-400 p-2">⚠️ Este producto no cuenta con lotes activos con stock.</p>`;
        return;
    }

    let htmlLotes = '';
    lotes.forEach(l => {
        htmlLotes += `
            <div class="card-lote-opcion bg-slate-950 border border-slate-800 p-3 rounded-lg cursor-pointer hover:border-amber-500 transition" data-id="${l.id}" data-numero="${l.numero_lote || 'SIN-LOTE'}" data-stock="${l.stock_actual}" data-costo="${l.costo_unitario || 0}">
                <div class="flex justify-between items-center text-xs">
                    <span class="font-mono font-bold text-amber-300">Lote: ${l.numero_lote || 'SIN-LOTE'}</span>
                    <span class="font-mono text-emerald-400">${l.stock_actual} disp.</span>
                </div>
                <div class="text-[11px] text-slate-400 mt-1">Costo: $${Number(l.costo_unitario || 0).toFixed(2)} | Ingreso: ${l.fecha_ingreso ? new Date(l.fecha_ingreso).toLocaleDateString() : 'N/D'}</div>
            </div>
        `;
    });
    contenedorLotes.innerHTML = htmlLotes;

    document.querySelectorAll('.card-lote-opcion').forEach(card => {
        card.onclick = () => {
            document.querySelectorAll('.card-lote-opcion').forEach(c => c.classList.remove('border-amber-500', 'bg-amber-950/25'));
            card.classList.add('border-amber-500', 'bg-amber-950/25');

            loteSeleccionadoActual = {
                id: Number(card.dataset.id),
                numeroLote: card.dataset.numero,
                stock: Number(card.dataset.stock),
                costo: Number(card.dataset.costo)
            };

            const seccionCant = document.getElementById('seccionCantidadAjax');
            seccionCant.classList.remove('hidden');
            document.getElementById('lblStockMaxLote').textContent = `Máximo disponible: ${loteSeleccionadoActual.stock} unidades`;
            document.getElementById('inputCantidadLote').value = '';
            document.getElementById('inputCantidadLote').focus();
            document.getElementById('btnAgregarPartidaLista').classList.remove('hidden');
        };
    });
}

function renderizarTablaPartidasTemp() {
    const tbody = document.getElementById('tablaPartidasTempBody');
    if (!tbody) return;

    if (partidasSalidaTemp.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" class="p-4 text-center text-slate-500 italic text-xs">No hay partidas agregadas todavía.</td></tr>`;
        return;
    }

    let html = '';
    partidasSalidaTemp.forEach((p, index) => {
        html += `
            <tr class="border-b border-slate-800 text-xs">
                <td class="p-2.5 font-medium text-slate-100">${p.productoNombre}</td>
                <td class="p-2.5 font-mono text-amber-300">Lote: ${p.numeroLote}</td>
                <td class="p-2.5 font-mono text-red-400 font-bold">${p.cantidad} un.</td>
                <td class="p-2.5 font-mono text-slate-300">$${Number(p.costoUnitario).toFixed(2)}</td>
                <td class="p-2.5 text-right">
                    <button type="button" data-index="${index}" class="btn-eliminar-partida-temp text-red-400 hover:text-red-300 font-bold px-2 py-1 bg-red-950/40 rounded border border-red-900/50 cursor-pointer">🗑️</button>
                </td>
            </tr>
        `;
    });
    tbody.innerHTML = html;

    // Delegación limpia de eventos sin depender del scope global (window)
    tbody.querySelectorAll('.btn-eliminar-partida-temp').forEach(btn => {
        btn.onclick = (e) => {
            const idx = Number(e.currentTarget.dataset.index);
            partidasSalidaTemp.splice(idx, 1);
            renderizarTablaPartidasTemp();
            recalcularVentaDesdePartidas();
        };
    });
}

// Cuando el tipo es "Salida por Venta", precarga Subtotal e IVA del bloque
// contable a partir del precio de venta de cada producto (editable después).
function recalcularVentaDesdePartidas() {
    if (document.getElementById('tipoSalida')?.value !== 'salida_venta') return;
    const inpSub = document.getElementById('salVentaSubtotal');
    const inpIva = document.getElementById('salVentaIva');
    if (!inpSub || !inpIva) return;

    let subtotal = 0, iva = 0, sinPrecio = 0;
    for (const p of partidasSalidaTemp) {
        const pv = Number(p.precioVenta);
        if (!pv || pv <= 0) { sinPrecio++; continue; }
        const lineSub = p.cantidad * pv;
        subtotal += lineSub;
        const tasa = (p.tasaIva === null || p.tasaIva === undefined) ? 0 : Number(p.tasaIva);
        iva += lineSub * tasa;
    }
    inpSub.value = subtotal.toFixed(2);
    inpIva.value = iva.toFixed(2);

    let nota = document.getElementById('salVentaSinPrecioNota');
    if (!nota) {
        nota = document.createElement('p');
        nota.id = 'salVentaSinPrecioNota';
        nota.className = 'md:col-span-3 text-[11px] text-amber-400';
        document.getElementById('salCamposVenta')?.appendChild(nota);
    }
    nota.textContent = sinPrecio
        ? `⚠ ${sinPrecio} producto(s) sin precio de venta capturado — captúralo en Catálogos → Productos, o ajusta el subtotal a mano.`
        : '';
}

export async function registrarSalidaMultiPartida(datosDoc) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");
        const { tipoMovimiento, folio, descripcion, partidas } = datosDoc;

        const { data: docSalida, error: errDoc } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: tipoMovimiento,
                folio: folio,
                fecha_emision: new Date().toISOString(),
                descripcion: descripcion || 'Salida multi-partida',
                estado: 'completado'
            }])
            .select('id')
            .single();

        if (errDoc) throw errDoc;
        const documentoId = docSalida.id;
        const afectacionesProductos = {};

        for (const partida of partidas) {
            const { data: loteData, error: errLote } = await supabaseClient
                .from('lotes_inventario')
                .select('stock_actual')
                .eq('id', partida.loteId)
                .single();

            if (errLote) throw errLote;
            const stockLoteActual = Number(loteData?.stock_actual || 0);

            if (stockLoteActual < partida.cantidad) {
                throw new Error(`Stock insuficiente en el lote ${partida.numeroLote} para ${partida.productoNombre}.`);
            }

            const nuevoStockLote = stockLoteActual - partida.cantidad;

            const { error: errUpdLote } = await supabaseClient
                .from('lotes_inventario')
                .update({ stock_actual: nuevoStockLote })
                .eq('id', partida.loteId);

            if (errUpdLote) throw errUpdLote;

            const detalle = {
                documento_id: documentoId,
                producto_id: partida.productoId,
                lote_id: partida.loteId,
                cantidad: partida.cantidad,
                costo_unitario: partida.costoUnitario,
                subtotal: partida.cantidad * partida.costoUnitario
            };
            // precioVenta solo viene lleno si la columna existe (el select extendido funcionó)
            if (partida.precioVenta !== null && partida.precioVenta !== undefined) {
                detalle.precio_venta = partida.precioVenta;
            }
            const { error: errDetalle } = await supabaseClient.from('documento_detalles').insert([detalle]);

            if (errDetalle) throw errDetalle;

            if (!afectacionesProductos[partida.productoId]) {
                afectacionesProductos[partida.productoId] = { 
                    totalSalida: 0, 
                    ultimoCosto: partida.costoUnitario, 
                    numeroLote: partida.numeroLote 
                };
            }
            afectacionesProductos[partida.productoId].totalSalida += partida.cantidad;
            afectacionesProductos[partida.productoId].ultimoCosto = partida.costoUnitario;
            afectacionesProductos[partida.productoId].numeroLote = partida.numeroLote;
        }

        for (const [prodIdStr, info] of Object.entries(afectacionesProductos)) {
            const prodId = Number(prodIdStr);
            const { data: prodActual } = await supabaseClient
                .from('productos')
                .select('stock_actual')
                .eq('id', prodId)
                .single();

            const stockAnterior = Number(prodActual?.stock_actual || 0);

            const { data: lotesRestantes } = await supabaseClient
                .from('lotes_inventario')
                .select('stock_actual')
                .eq('producto_id', prodId);

            const nuevoStockGlobal = (lotesRestantes || []).reduce((acc, l) => acc + Number(l.stock_actual || 0), 0);

            await supabaseClient
                .from('productos')
                .update({ stock_actual: nuevoStockGlobal })
                .eq('id', prodId);

            await supabaseClient
                .from('movimientos_inventario')
                .insert([{
                    producto_id: prodId,
                    tipo_movimiento: tipoMovimiento,
                    cantidad: -Math.abs(info.totalSalida),
                    stock_anterior: stockAnterior,
                    stock_resultante: nuevoStockGlobal,
                    costo_unitario: info.ultimoCosto,
                    documento_id: documentoId
                }]);

            try {
                await registrarMovimientoAlmacen({
                    productoId: prodId,
                    cantidad: -Math.abs(info.totalSalida),
                    tipoMovimiento: tipoMovimiento,
                    documentoId: documentoId,
                    costoUnitario: info.ultimoCosto,
                    numeroLote: info.numeroLote
                });
            } catch (errReg) {
                console.warn("Aviso en registrarMovimientoAlmacen para salida:", errReg.message);
            }
        }

        return { success: true, mensaje: "Salida multi-partida procesada y registrada exitosamente.", documentoId };

    } catch (error) {
        console.error("Error al procesar salida multi-partida:", error.message);
        return { success: false, error: error.message };
    }
}

// Bloque de contabilidad de Salidas: se muestra solo si el modulo contable
// esta instalado. Para 'salida_venta' aparecen los campos de venta.
async function cargarBloqueContableSalidas() {
    const bloque = document.getElementById('salBloqueContable');
    if (!bloque) return;
    let ctas = [];
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('id, codigo, nombre, tipo')
            .eq('afectable', true).eq('activa', true)
            .order('codigo', { ascending: true });
        if (error) throw error;
        ctas = data || [];
    } catch (_) {
        return; // modulo de contabilidad no instalado
    }
    bloque.classList.remove('hidden');

    const opt = (arr, selCodigo) => '<option value="">— cuenta —</option>' +
        arr.map(c => `<option value="${c.id}" ${c.codigo === selCodigo ? 'selected' : ''}>${c.codigo} · ${c.nombre}</option>`).join('');

    const gastosYcostos = ctas.filter(c => c.tipo === 'gasto' || c.tipo === 'costo');
    const cobro = ctas.filter(c => c.tipo === 'activo' && /^(101|102|105)/.test(c.codigo));
    document.getElementById('salCuentaCargo').innerHTML = opt(gastosYcostos, '501.01');
    document.getElementById('salCuentaCobro').innerHTML = opt(cobro, '105.01');

    const tipoSel = document.getElementById('tipoSalida');
    const sync = () => {
        const esVenta = tipoSel.value === 'salida_venta';
        document.getElementById('salCamposVenta').classList.toggle('hidden', !esVenta);
        document.getElementById('salCamposCosto').classList.toggle('hidden', esVenta);
        if (esVenta) recalcularVentaDesdePartidas();
    };
    tipoSel.addEventListener('change', sync);
    sync();

    document.getElementById('salIva16').addEventListener('click', () => {
        const st = parseFloat(document.getElementById('salVentaSubtotal').value) || 0;
        document.getElementById('salVentaIva').value = (Math.round(st * 16) / 100).toFixed(2);
    });
    document.getElementById('salContabilizar').addEventListener('change', (e) => {
        document.getElementById('salCamposCosto').style.display = e.target.checked ? '' : 'none';
        document.getElementById('salCamposVenta').style.display = e.target.checked ? '' : 'none';
    });
}

// Postea la poliza de una salida ya registrada (segun su tipo).
async function contabilizarSalidaUI(tipoMovimiento, documentoId) {
    const chk = document.getElementById('salContabilizar');
    const bloqueVisible = document.getElementById('salBloqueContable') &&
        !document.getElementById('salBloqueContable').classList.contains('hidden');
    if (!bloqueVisible || !chk || !chk.checked || !documentoId) return '';

    try {
        if (tipoMovimiento === 'salida_venta') {
            const p_datos = {
                venta_subtotal: parseFloat(document.getElementById('salVentaSubtotal').value) || 0,
                venta_iva: parseFloat(document.getElementById('salVentaIva').value) || 0,
                condicion: document.getElementById('salCondicion').value,
                cuenta_cobro_id: document.getElementById('salCuentaCobro').value ? parseInt(document.getElementById('salCuentaCobro').value) : null,
                uuid_cfdi: document.getElementById('salUuid').value.trim() || null,
                cliente_nombre: document.getElementById('salClienteNombre').value.trim() || null,
                cliente_rfc: document.getElementById('salClienteRfc').value.trim() || null,
            };
            if (!p_datos.venta_subtotal || !p_datos.cuenta_cobro_id) {
                return '\nNo se contabilizó: falta el subtotal de venta o la cuenta de cobro.';
            }
            const { data, error } = await supabaseClient.rpc('contabilizar_venta', { p_documento_id: documentoId, p_datos });
            if (error) throw error;
            return `\nPóliza de venta #${data.poliza_id} generada (cobro $${Number(data.total).toFixed(2)}, costo $${Number(data.costo).toFixed(2)}).`;
        }
        // salida / merma / ajuste
        const ctaCargo = document.getElementById('salCuentaCargo').value;
        if (!ctaCargo) return '\nNo se contabilizó: falta la cuenta destino del costo.';
        const { data, error } = await supabaseClient.rpc('contabilizar_salida', {
            p_documento_id: documentoId, p_datos: { cuenta_cargo_id: parseInt(ctaCargo) }
        });
        if (error) throw error;
        return `\nPóliza #${data.poliza_id} generada (total $${Number(data.total).toFixed(2)}).`;
    } catch (e) {
        return `\nLa salida se registró, pero NO se contabilizó: ${e.message || e}`;
    }
}

async function cargarHistorialSalidas() {
    const contenedorHistorial = document.getElementById('contenedorHistorialSalidas');
    if (!contenedorHistorial) return;

    try {
        const cols = `
            id, folio, tipo_movimiento, fecha_emision, descripcion, poliza_id,
            documento_detalles (
                cantidad, costo_unitario, subtotal, precio_venta,
                productos ( nombre ),
                lotes_inventario ( numero_lote )
            )`;
        let { data: documentos, error } = await supabaseClient
            .from('documentos')
            .select(cols)
            .in('tipo_movimiento', ['salida', 'salida_venta', 'merma', 'ajuste'])
            .order('fecha_emision', { ascending: false })
            .limit(25);
        if (error) {
            // poliza_id / precio_venta aun no existen: cae al select sin contabilidad
            ({ data: documentos, error } = await supabaseClient
                .from('documentos')
                .select(`id, folio, tipo_movimiento, fecha_emision, descripcion,
                         documento_detalles ( cantidad, costo_unitario, subtotal, productos ( nombre ), lotes_inventario ( numero_lote ) )`)
                .in('tipo_movimiento', ['salida', 'salida_venta', 'merma', 'ajuste'])
                .order('fecha_emision', { ascending: false })
                .limit(25));
        }
        if (error) throw error;

        if (!documentos || documentos.length === 0) {
            contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">No hay salidas registradas recientemente.</p>`;
            return;
        }

        historialSalidasCache = documentos;

        let html = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900 text-red-400 text-xs uppercase border-b border-slate-800 sticky top-0">
                        <tr>
                            <th class="p-3">Folio</th>
                            <th class="p-3">Tipo</th>
                            <th class="p-3">Fecha</th>
                            <th class="p-3">Descripción</th>
                            <th class="p-3">Partidas / Lotes Afectados</th>
                            <th class="p-3">Contabilidad</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        documentos.forEach(doc => {
            let descDetalles = '';
            if (doc.documento_detalles && doc.documento_detalles.length > 0) {
                descDetalles = doc.documento_detalles.map(d =>
                    `<span class="block text-xs font-mono text-slate-300">• ${d.productos?.nombre || 'Prod'} (<b class="text-amber-300">Lote: ${d.lotes_inventario?.numero_lote || 'SIN-LOTE'}</b>): <b class="text-red-300">${d.cantidad} un.</b></span>`
                ).join('');
            }

            let contabCell;
            if (!('poliza_id' in doc)) {
                contabCell = `<span class="text-[11px] text-slate-600">—</span>`;
            } else if (doc.poliza_id) {
                contabCell = `<span class="text-[11px] text-emerald-400">Póliza #${doc.poliza_id}</span>`;
            } else {
                contabCell = `<button type="button" class="btn-contab-salida text-[11px] bg-sky-950 hover:bg-sky-900 text-sky-300 px-2 py-1 rounded border border-sky-800 cursor-pointer" data-id="${doc.id}">Contabilizar</button>`;
            }

            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                    <td class="p-3 font-mono text-xs text-red-400 font-bold">${doc.folio}</td>
                    <td class="p-3 text-xs uppercase font-semibold text-slate-400">${doc.tipo_movimiento}</td>
                    <td class="p-3 text-xs text-slate-400">${new Date(doc.fecha_emision).toLocaleDateString()}</td>
                    <td class="p-3 text-xs text-slate-200">${doc.descripcion || 'N/D'}</td>
                    <td class="p-3">${descDetalles}</td>
                    <td class="p-3">${contabCell}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorHistorial.innerHTML = html;

        contenedorHistorial.querySelectorAll('.btn-contab-salida').forEach(b => {
            b.addEventListener('click', () => {
                const doc = historialSalidasCache.find(d => d.id === Number(b.dataset.id));
                if (doc) abrirModalContabilizarSalida(doc);
            });
        });

    } catch (err) {
        console.error("Error al cargar historial:", err);
        contenedorHistorial.innerHTML = `<p class="text-red-400 text-sm">Error al cargar historial de salidas.</p>`;
    }
}

// Contabiliza (genera la póliza) de una salida ya registrada que no tiene póliza.
async function abrirModalContabilizarSalida(doc) {
    let ctas = [];
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables').select('id, codigo, nombre, tipo')
            .eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        ctas = data || [];
    } catch (_) {
        alert('Falta el módulo de contabilidad (corre los SQL).');
        return;
    }

    const esVenta = doc.tipo_movimiento === 'salida_venta';
    const subCalc = (doc.documento_detalles || []).reduce((a, d) => a + (Number(d.cantidad) || 0) * (Number(d.precio_venta) || 0), 0);
    const opt = (arr, selCod) => '<option value="">— cuenta —</option>' +
        arr.map(c => `<option value="${c.id}" ${c.codigo === selCod ? 'selected' : ''}>${c.codigo} · ${c.nombre}</option>`).join('');
    const gastosYcostos = ctas.filter(c => c.tipo === 'gasto' || c.tipo === 'costo');
    const cobro = ctas.filter(c => c.tipo === 'activo' && /^(101|102|105)/.test(c.codigo));

    const modal = document.createElement('div');
    modal.className = 'fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 p-4';
    modal.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-md shadow-2xl overflow-hidden">
            <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-center">
                <h3 class="text-sm font-bold text-slate-200">Contabilizar ${esVenta ? 'venta' : doc.tipo_movimiento} — ${doc.folio}</h3>
                <button type="button" id="cbxCerrar" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer">&times;</button>
            </div>
            <div class="p-5 space-y-3 text-sm">
                ${esVenta ? `
                    <div class="grid grid-cols-2 gap-2">
                        <div><label class="block text-xs text-slate-400 mb-1">Cliente</label>
                            <input type="text" id="cbxCliente" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                        <div><label class="block text-xs text-slate-400 mb-1">RFC</label>
                            <input type="text" id="cbxRfc" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                        <div><label class="block text-xs text-slate-400 mb-1">Subtotal</label>
                            <input type="number" step="0.01" id="cbxSub" value="${subCalc > 0 ? subCalc.toFixed(2) : ''}" placeholder="del precio de venta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                        <div><label class="block text-xs text-slate-400 mb-1">IVA <button type="button" id="cbxIva16" class="text-[10px] text-sky-400 hover:underline">16%</button></label>
                            <input type="number" step="0.01" id="cbxIva" placeholder="auto por producto" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                        <div><label class="block text-xs text-slate-400 mb-1">Condición</label>
                            <select id="cbxCond" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="contado">Contado</option><option value="credito">Crédito</option></select></div>
                        <div><label class="block text-xs text-slate-400 mb-1">Cobrar a</label>
                            <select id="cbxCuenta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${opt(cobro, '105.01')}</select></div>
                        <div class="col-span-2"><label class="block text-xs text-slate-400 mb-1">UUID CFDI</label>
                            <input type="text" id="cbxUuid" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
                    </div>
                    <p class="text-[11px] text-slate-500">Si dejas Subtotal/IVA vacíos, se calculan del precio de venta y la tasa de IVA de cada producto.</p>
                ` : `
                    <div><label class="block text-xs text-slate-400 mb-1">Cuenta destino del costo (cargo)</label>
                        <select id="cbxCuenta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${opt(gastosYcostos, doc.tipo_movimiento === 'merma' ? '601.99' : '501.01')}</select></div>
                    <p class="text-[11px] text-slate-500">El inventario se abona a la cuenta de cada producto, al costo FIFO ya registrado.</p>
                `}
                <p id="cbxMsg" class="text-xs min-h-[1rem]"></p>
            </div>
            <div class="bg-slate-950 px-5 py-3 border-t border-slate-800 flex justify-end gap-2">
                <button type="button" id="cbxCancelar" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Cancelar</button>
                <button type="button" id="cbxGuardar" class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg text-xs font-semibold cursor-pointer">Generar póliza</button>
            </div>
        </div>`;
    document.body.appendChild(modal);
    const cerrar = () => modal.remove();
    modal.querySelector('#cbxCerrar').onclick = cerrar;
    modal.querySelector('#cbxCancelar').onclick = cerrar;
    modal.addEventListener('click', (e) => { if (e.target === modal) cerrar(); });
    if (esVenta) {
        modal.querySelector('#cbxIva16').onclick = () => {
            const s = parseFloat(modal.querySelector('#cbxSub').value) || 0;
            modal.querySelector('#cbxIva').value = (Math.round(s * 16) / 100).toFixed(2);
        };
    }

    modal.querySelector('#cbxGuardar').onclick = async () => {
        const msg = modal.querySelector('#cbxMsg');
        const ctaVal = modal.querySelector('#cbxCuenta').value;
        if (!ctaVal) { msg.textContent = 'Elige la cuenta.'; msg.className = 'text-xs text-rose-400'; return; }
        try {
            modal.querySelector('#cbxGuardar').disabled = true;
            let res;
            if (esVenta) {
                const subV = modal.querySelector('#cbxSub').value.trim();
                const ivaV = modal.querySelector('#cbxIva').value.trim();
                const p_datos = {
                    condicion: modal.querySelector('#cbxCond').value,
                    cuenta_cobro_id: parseInt(ctaVal),
                    cliente_nombre: modal.querySelector('#cbxCliente').value.trim() || null,
                    cliente_rfc: modal.querySelector('#cbxRfc').value.trim() || null,
                    uuid_cfdi: modal.querySelector('#cbxUuid').value.trim() || null,
                };
                if (subV !== '') p_datos.venta_subtotal = parseFloat(subV);
                if (ivaV !== '') p_datos.venta_iva = parseFloat(ivaV);
                res = await supabaseClient.rpc('contabilizar_venta', { p_documento_id: doc.id, p_datos });
            } else {
                res = await supabaseClient.rpc('contabilizar_salida', {
                    p_documento_id: doc.id, p_datos: { cuenta_cargo_id: parseInt(ctaVal) }
                });
            }
            if (res.error) throw res.error;
            cerrar();
            await cargarHistorialSalidas();
        } catch (e) {
            msg.textContent = e.message || String(e);
            msg.className = 'text-xs text-rose-400';
            modal.querySelector('#cbxGuardar').disabled = false;
        }
    };
}