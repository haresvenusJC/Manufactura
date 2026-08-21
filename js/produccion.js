import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');
    
    try {
        if (!supabaseClient) return;

        if (contenedorProd) {
            contenedorProd.innerHTML = `
                <div class="space-y-6 max-w-4xl mx-auto">
                    <!-- Formulario de Ejecución -->
                    <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                        <h3 class="text-lg font-semibold mb-4 text-amber-400 flex items-center gap-2">⚙️ Ejecutar Orden y Costos de Producción</h3>
                        <form id="formOrdenProduccion" class="space-y-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">PRODUCTO A PRODUCIR</label>
                                <select id="productoProducirId" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                    <option value="">Seleccione un producto...</option>
                                </select>
                            </div>
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-medium text-slate-400 mb-1">CANTIDAD A PRODUCIR</label>
                                    <input type="number" id="cantidadProducida" min="1" step="any" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                </div>
                                <div>
                                    <label class="block text-xs font-medium text-slate-400 mb-1">NÚMERO DE LOTE RESULTANTE</label>
                                    <input type="text" id="numeroLoteResultante" placeholder="Ej: LOTE-PT-2026-001" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                </div>
                            </div>
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-medium text-slate-400 mb-1">EMPLEADOS</label>
                                    <input type="number" id="empleadosInvolucrados" min="1" value="1" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                </div>
                                <div>
                                    <label class="block text-xs font-medium text-slate-400 mb-1">MANO DE OBRA TOTAL ($)</label>
                                    <input type="number" id="costoManoObra" min="0" step="0.01" value="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                </div>
                            </div>
                            <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-semibold py-2 px-4 rounded-lg transition-all text-sm shadow-lg">
                                🚀 Registrar Producción y Descontar Insumos (FIFO)
                            </button>
                        </form>
                    </div>

                    <!-- Panel de Resumen Ejecutivo y Detalle por ID -->
                    <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-4">
                            <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">📊 Resumen Ejecutivo y Costos por Orden</h3>
                            <div class="flex items-center gap-2 w-full md:w-auto">
                                <select id="selectOrdenId" class="w-full md:w-72 bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-amber-300 font-mono">
                                    <option value="">Seleccione orden por ID...</option>
                                </select>
                                <button id="btnImprimirOrden" class="bg-slate-800 hover:bg-slate-700 text-amber-400 p-2 rounded-lg border border-slate-700 transition-all text-sm flex items-center gap-1 title="Ventana Imprimible" disabled>
                                    🖨️
                                </button>
                            </div>
                        </div>
                        <div id="detalleResumenOrden" class="bg-slate-950 border border-slate-800/60 p-4 rounded-lg text-sm text-slate-300 mb-6">
                            <p class="text-slate-500 italic text-center">Seleccione una orden de producción o ejecute una nueva para ver su desglose ejecutivo.</p>
                        </div>
                        <div id="contenedorHistorialProduccion"></div>
                    </div>
                </div>
            `;

            const { data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select('id, nombre, sku')
                .eq('tipo', 'producto');

            const selectProd = document.getElementById('productoProducirId');
            if (!errProd && productos) {
                selectProd.innerHTML = '<option value="">Seleccione un producto...</option>';
                productos.forEach(p => {
                    selectProd.innerHTML += `<option value="${p.id}">${p.nombre} (${p.sku || 'Sin SKU'})</option>`;
                });
            }

            const formOrden = document.getElementById('formOrdenProduccion');
            if (formOrden) {
                formOrden.onsubmit = async (e) => {
                    e.preventDefault();
                    
                    const datosOrden = {
                        productoId: document.getElementById('productoProducirId').value,
                        cantidadProducida: parseFloat(document.getElementById('cantidadProducida').value),
                        numeroLote: document.getElementById('numeroLoteResultante').value.trim(),
                        empleadosInvolucrados: parseInt(document.getElementById('empleadosInvolucrados').value) || 1,
                        costoTotalManoObra: parseFloat(document.getElementById('costoManoObra').value) || 0,
                        moneda: 'MXN'
                    };

                    const btnSubmit = formOrden.querySelector('button[type="submit"]');
                    btnSubmit.disabled = true;
                    btnSubmit.textContent = "Procesando inventario (FIFO)...";

                    try {
                        const resultado = await registrarOrdenDeProduccionCompleta(datosOrden);
                        if (resultado.success) {
                            alert("✅ " + resultado.mensaje);
                            formOrden.reset();
                            await cargarHistorialProduccion(resultado.ordenIdCreada);
                            if (typeof cargarInventarioCompleto === 'function') {
                                cargarInventarioCompleto();
                            }
                        } else {
                            alert("❌ Error: " + resultado.error);
                        }
                    } catch (ex) {
                        alert("❌ Error crítico: " + ex.message);
                    } finally {
                        btnSubmit.disabled = false;
                        btnSubmit.textContent = "🚀 Registrar Producción y Descontar Insumos (FIFO)";
                    }
                };
            }
        }

        await cargarHistorialProduccion();

    } catch (err) {
        console.error("Error al inicializar el módulo de producción:", err);
    }
}

export async function registrarOrdenDeProduccionCompleta(datosOrden) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");

        const productoId = Number(datosOrden.productoId);
        const cantidadProducida = Number(datosOrden.cantidadProducida) || 0;
        const numeroLote = String(datosOrden.numeroLote || '').trim();
        const moneda = String(datosOrden.moneda || 'MXN');
        const empleadosInvolucrados = Number(datosOrden.empleadosInvolucrados) || 1;
        const costoTotalManoObra = Number(datosOrden.costoTotalManoObra) || 0;

        if (!productoId || cantidadProducida <= 0 || !numeroLote) {
            throw new Error("Faltan datos obligatorios o la cantidad a producir es inválida.");
        }

        let costoTotalMateriales = 0;

        const { data: componentes, error: errComp } = await supabaseClient
            .from('bom')
            .select(`
                componente_id, 
                cantidad_requerida, 
                factor_merma,
                productos:componente_id ( id, nombre )
            `)
            .eq('producto_id', productoId);

        if (errComp) throw errComp;

        if (!componentes || componentes.length === 0) {
            throw new Error("El producto seleccionado no tiene una receta o BOM registrada.");
        }

        for (const comp of componentes) {
            const componenteTargetId = Number(comp.componente_id);
            const nombreComponente = comp.productos?.nombre || `ID: ${componenteTargetId}`;

            if (!componenteTargetId) {
                throw new Error("Error en la receta (BOM): Se encontró un componente sin un identificador válido.");
            }

            const merma = Number(comp.factor_merma || 1);
            const cantidadTotalRequerida = Number(comp.cantidad_requerida) * cantidadProducida * merma;
            let cantidadPendienteDescontar = cantidadTotalRequerida;

            const { data: lotesEncontrados, error: errLotes } = await supabaseClient
                .from('lotes_inventario')
                .select('id, producto_id, stock_actual, costo_unitario, fecha_ingreso')
                .eq('producto_id', componenteTargetId)
                .gt('stock_actual', 0)
                .order('fecha_ingreso', { ascending: true });

            if (errLotes) throw errLotes;

            if (!lotesEncontrados || lotesEncontrados.length === 0) {
                throw new Error(`Stock insuficiente: El componente "${nombreComponente}" no cuenta con lotes activos en inventario.`);
            }

            for (const lote of lotesEncontrados) {
                if (cantidadPendienteDescontar <= 0) break;

                const stockLote = Number(lote.stock_actual);
                let aDescontar = stockLote >= cantidadPendienteDescontar ? cantidadPendienteDescontar : stockLote;

                cantidadPendienteDescontar -= aDescontar;
                const nuevoStockLote = stockLote - aDescontar;

                costoTotalMateriales += (aDescontar * Number(lote.costo_unitario || 0));

                const { error: errUpLote } = await supabaseClient
                    .from('lotes_inventario')
                    .update({ stock_actual: nuevoStockLote })
                    .eq('id', lote.id);

                if (errUpLote) throw errUpLote;
            }

            if (cantidadPendienteDescontar > 0) {
                throw new Error(`Stock insuficiente: No hay suficientes existencias de "${nombreComponente}" para completar la cantidad requerida.`);
            }

            const { data: lotesRestantes, error: errRestantes } = await supabaseClient
                .from('lotes_inventario')
                .select('stock_actual')
                .eq('producto_id', componenteTargetId);

            if (errRestantes) throw errRestantes;

            const nuevoStockGlobalComp = (lotesRestantes || []).reduce((acc, l) => acc + Number(l.stock_actual || 0), 0);

            const { error: errProdSync } = await supabaseClient
                .from('productos')
                .update({ stock_actual: nuevoStockGlobalComp })
                .eq('id', componenteTargetId);

            if (errProdSync) throw errProdSync;
        }

        const costoTotalGeneral = costoTotalMateriales + costoTotalManoObra;
        const costoUnitarioFinal = cantidadProducida > 0 ? (costoTotalGeneral / cantidadProducida) : 0;

        const { data: ordenInsertada, error: errOrden } = await supabaseClient
            .from('ordenes_produccion')
            .insert([{
                producto_id: productoId,
                cantidad_producida: cantidadProducida,
                costo_unitario_final: costoUnitarioFinal,
                numero_lote: numeroLote,
                empleados_involucrados: empleadosInvolucrados,
                costo_total_mano_obra: costoTotalManoObra,
                costo_total_materiales: costoTotalMateriales
            }])
            .select('id')
            .single();

        if (errOrden) throw errOrden;
        const ordenIdCreada = ordenInsertada?.id;

        const { error: errLoteProd } = await supabaseClient
            .from('lotes_inventario')
            .insert([{
                producto_id: productoId,
                numero_lote: numeroLote,
                stock_actual: cantidadProducida,
                costo_unitario: costoUnitarioFinal,
                moneda: moneda,
                fecha_ingreso: new Date().toISOString().split('T')[0]
            }]);

        if (errLoteProd) throw errLoteProd;

        const { data: lotesProdActuales, error: errProdActuales } = await supabaseClient
            .from('lotes_inventario')
            .select('stock_actual')
            .eq('producto_id', productoId);

        if (errProdActuales) throw errProdActuales;

        const nuevoStockGlobalProd = (lotesProdActuales || []).reduce((acc, l) => acc + Number(l.stock_actual || 0), 0);

        const { error: errSyncPT } = await supabaseClient
            .from('productos')
            .update({ 
                stock_actual: nuevoStockGlobalProd,
                costo_unitario: costoUnitarioFinal 
            })
            .eq('id', productoId);

        if (errSyncPT) throw errSyncPT;

        return { 
            success: true, 
            ordenIdCreada: ordenIdCreada,
            mensaje: "Orden ejecutada con éxito, costos calculados por componentes FIFO, stock global sincronizado y lote registrado, mi lord." 
        };

    } catch (error) {
        console.error("Error en orden de producción:", error.message);
        return { success: false, error: error.message };
    }
}

async function cargarHistorialProduccion(idSeleccionarReciente = null) {
    const contenedorHistorial = document.getElementById('contenedorHistorialProduccion');
    const selectOrdenId = document.getElementById('selectOrdenId');
    const detalleResumenOrden = document.getElementById('detalleResumenOrden');
    const btnImprimirOrden = document.getElementById('btnImprimirOrden');

    try {
        if (!contenedorHistorial) return;
        contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">Cargando historial...</p>`;

        const { data: ordenes, error } = await supabaseClient
            .from('ordenes_produccion')
            .select(`
                id,
                producto_id,
                numero_lote,
                cantidad_producida,
                costo_unitario_final,
                costo_total_materiales,
                costo_total_mano_obra,
                empleados_involucrados,
                created_at,
                productos ( id, nombre, sku )
            `)
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!ordenes || ordenes.length === 0) {
            contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">No hay órdenes de producción registradas.</p>`;
            if (selectOrdenId) selectOrdenId.innerHTML = '<option value="">No hay órdenes disponibles</option>';
            if (btnImprimirOrden) btnImprimirOrden.disabled = true;
            return;
        }

        if (selectOrdenId) {
            selectOrdenId.innerHTML = '<option value="">Seleccione orden por ID...</option>';
            ordenes.forEach(o => {
                selectOrdenId.innerHTML += `<option value="${o.id}">ID #${o.id} - ${o.numero_lote || 'Sin Lote'} (${o.productos?.nombre || 'Producto'})</option>`;
            });

            selectOrdenId.onchange = async (e) => {
                const val = Number(e.target.value);
                if (btnImprimirOrden) btnImprimirOrden.disabled = !val;
                await renderizarDetalleOrden(val, ordenes, detalleResumenOrden);
            };
        }

        if (btnImprimirOrden) {
            btnImprimirOrden.onclick = async () => {
                const ordenIdActiva = Number(selectOrdenId.value);
                if (!ordenIdActiva) return;
                await abrirVentanaImprimible(ordenIdActiva, ordenes);
            };
        }

        let html = `
            <h4 class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Historial General de Órdenes</h4>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-amber-400">
                            <th class="p-2">ID</th>
                            <th class="p-2">Fecha</th>
                            <th class="p-2">Lote PT</th>
                            <th class="p-2">Producto</th>
                            <th class="p-2">Cantidad</th>
                            <th class="p-2">Costo Unit. Final</th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        ordenes.forEach(o => {
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition-colors cursor-pointer" onclick="document.getElementById('selectOrdenId').value='${o.id}'; document.getElementById('selectOrdenId').dispatchEvent(new Event('change'));">
                    <td class="p-2 font-mono text-xs text-amber-300">#${o.id}</td>
                    <td class="p-2 text-xs text-slate-400">${new Date(o.created_at).toLocaleDateString()}</td>
                    <td class="p-2 font-mono text-xs text-slate-200">${o.numero_lote || 'N/D'}</td>
                    <td class="p-2 font-medium text-slate-100">${o.productos?.nombre || 'Desconocido'}</td>
                    <td class="p-2 font-mono">${o.cantidad_producida}</td>
                    <td class="p-2 font-mono text-emerald-400 font-semibold">$${Number(o.costo_unitario_final || 0).toFixed(2)}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorHistorial.innerHTML = html;

        if (idSeleccionarReciente && selectOrdenId) {
            selectOrdenId.value = idSeleccionarReciente;
            if (btnImprimirOrden) btnImprimirOrden.disabled = false;
            await renderizarDetalleOrden(idSeleccionarReciente, ordenes, detalleResumenOrden);
        } else if (ordenes.length > 0 && selectOrdenId) {
            selectOrdenId.value = ordenes[0].id;
            if (btnImprimirOrden) btnImprimirOrden.disabled = false;
            await renderizarDetalleOrden(ordenes[0].id, ordenes, detalleResumenOrden);
        }

    } catch (err) {
        console.error("Error al cargar historial de producción:", err);
        contenedorHistorial.innerHTML = `<p class="text-red-400 text-sm">Error al cargar historial.</p>`;
    }
}

async function renderizarDetalleOrden(idSeleccionado, ordenes, contenedorDetalle) {
    if (!idSeleccionado || !contenedorDetalle) {
        contenedorDetalle.innerHTML = `<p class="text-slate-500 italic text-center">Seleccione una orden de producción para ver su desglose ejecutivo.</p>`;
        return;
    }

    const orden = ordenes.find(item => item.id === idSeleccionado);
    if (!orden) return;

    contenedorDetalle.innerHTML = `<p class="text-slate-400 text-sm text-center py-2">Cargando desglose de componentes y costos de la orden...</p>`;

    try {
        const { data: bomComponentes, error: errBom } = await supabaseClient
            .from('bom')
            .select(`
                componente_id,
                cantidad_requerida,
                factor_merma,
                unidad_medida,
                productos:componente_id ( id, nombre, costo_unitario )
            `)
            .eq('producto_id', orden.producto_id);

        if (errBom) throw errBom;

        const cant = Number(orden.cantidad_producida || 1);
        const unitFinal = Number(orden.costo_unitario_final || 0);
        const costoTotalGlobal = cant * unitFinal;
        const matTotal = Number(orden.costo_total_materiales || 0);
        const mobTotal = Number(orden.costo_total_mano_obra || 0);

        let htmlComponentes = '';
        if (bomComponentes && bomComponentes.length > 0) {
            bomComponentes.forEach(comp => {
                const merma = Number(comp.factor_merma || 1);
                const cantReqUnit = Number(comp.cantidad_requerida || 0);
                const cantidadTotalNec = cantReqUnit * cant * merma;
                const costoUnitComponente = Number(comp.productos?.costo_unitario || 0);
                const subtotalComponente = cantidadTotalNec * costoUnitComponente;
                const nombreComp = comp.productos?.nombre || 'Componente desconocido';

                htmlComponentes += `
                    <tr class="border-b border-slate-900/60 text-xs">
                        <td class="py-2 px-3 text-slate-200 font-medium">${nombreComp}</td>
                        <td class="py-2 px-3 font-mono text-slate-300">${cantReqUnit} ${comp.unidad_medida || ''}</td>
                        <td class="py-2 px-3 font-mono text-amber-300">${cantidadTotalNec.toFixed(2)}</td>
                        <td class="py-2 px-3 font-mono text-slate-300">$${costoUnitComponente.toFixed(2)}</td>
                        <td class="py-2 px-3 font-mono text-emerald-400 font-semibold text-right">$${subtotalComponente.toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            htmlComponentes = `<tr><td colspan="5" class="py-3 text-center text-slate-500 italic">No hay componentes registrados en el BOM para este producto.</td></tr>`;
        }

        contenedorDetalle.innerHTML = `
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4 pb-4 border-b border-slate-800">
                <div>
                    <span class="text-xs text-slate-400 block">ORDEN / LOTE</span>
                    <span class="font-mono font-bold text-amber-400">ID #${orden.id} | ${orden.numero_lote || 'N/D'}</span>
                </div>
                <div>
                    <span class="text-xs text-slate-400 block">PRODUCTO</span>
                    <span class="font-medium text-slate-100">${orden.productos?.nombre || 'N/D'}</span>
                </div>
                <div>
                    <span class="text-xs text-slate-400 block">CANTIDAD PRODUCIDA</span>
                    <span class="font-mono text-slate-200">${cant} unidades</span>
                </div>
                <div>
                    <span class="text-xs text-slate-400 block">FECHA DE REGISTRO</span>
                    <span class="text-slate-300">${new Date(orden.created_at).toLocaleString()}</span>
                </div>
            </div>

            <h4 class="text-xs font-semibold text-amber-400 uppercase tracking-wider mb-2">Desglose de Componentes Necesitados (BOM)</h4>
            <div class="overflow-x-auto mb-4">
                <table class="w-full text-left text-sm text-slate-300 bg-slate-900 rounded-lg overflow-hidden">
                    <thead>
                        <tr class="border-b border-slate-800 text-xs text-slate-400 bg-slate-950">
                            <th class="py-2 px-3">Componente</th>
                            <th class="py-2 px-3">Cant. Unit.</th>
                            <th class="py-2 px-3">Cant. Total Req.</th>
                            <th class="py-2 px-3">Costo Unit.</th>
                            <th class="py-2 px-3 text-right">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${htmlComponentes}
                    </tbody>
                </table>
            </div>
            
            <h4 class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Resumen Financiero Ejecutivo</h4>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-3">
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800">
                    <span class="text-xs text-slate-400 block">Total Materiales</span>
                    <span class="font-mono text-base text-slate-200 font-bold">$${matTotal.toFixed(2)}</span>
                </div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800">
                    <span class="text-xs text-slate-400 block">Mano de Obra (${orden.empleados_involucrados || 1} pers.)</span>
                    <span class="font-mono text-base text-slate-200 font-bold">$${mobTotal.toFixed(2)}</span>
                </div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800">
                    <span class="text-xs text-slate-400 block">Costo Unitario Final</span>
                    <span class="font-mono text-base text-emerald-400 font-bold">$${unitFinal.toFixed(2)} / u</span>
                </div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800">
                    <span class="text-xs text-slate-400 block">Costo Total del Lote</span>
                    <span class="font-mono text-base text-amber-300 font-bold">$${costoTotalGlobal.toFixed(2)}</span>
                </div>
            </div>
        `;
    } catch (err) {
        console.error("Error al renderizar el detalle de la orden:", err);
        contenedorDetalle.innerHTML = `<p class="text-red-400 text-sm text-center">Error al cargar el desglose detallado de la orden.</p>`;
    }
}

async function abrirVentanaImprimible(idSeleccionado, ordenes) {
    const orden = ordenes.find(item => item.id === idSeleccionado);
    if (!orden) return;

    try {
        const { data: bomComponentes, error: errBom } = await supabaseClient
            .from('bom')
            .select(`
                componente_id,
                cantidad_requerida,
                factor_merma,
                unidad_medida,
                productos:componente_id ( id, nombre, costo_unitario )
            `)
            .eq('producto_id', orden.producto_id);

        if (errBom) throw errBom;

        const cant = Number(orden.cantidad_producida || 1);
        const unitFinal = Number(orden.costo_unitario_final || 0);
        const costoTotalGlobal = cant * unitFinal;
        const matTotal = Number(orden.costo_total_materiales || 0);
        const mobTotal = Number(orden.costo_total_mano_obra || 0);

        let filasComponentes = '';
        if (bomComponentes && bomComponentes.length > 0) {
            bomComponentes.forEach(comp => {
                const merma = Number(comp.factor_merma || 1);
                const cantReqUnit = Number(comp.cantidad_requerida || 0);
                const cantidadTotalNec = cantReqUnit * cant * merma;
                const costoUnitComponente = Number(comp.productos?.costo_unitario || 0);
                const subtotalComponente = cantidadTotalNec * costoUnitComponente;
                const nombreComp = comp.productos?.nombre || 'Componente desconocido';

                filasComponentes += `
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #cbd5e1;">${nombreComp}</td>
                        <td style="padding: 8px; border-bottom: 1px solid #cbd5e1; text-align: center;">${cantReqUnit} ${comp.unidad_medida || ''}</td>
                        <td style="padding: 8px; border-bottom: 1px solid #cbd5e1; text-align: center; font-weight: bold;">${cantidadTotalNec.toFixed(2)}</td>
                        <td style="padding: 8px; border-bottom: 1px solid #cbd5e1; text-align: right;">$${costoUnitComponente.toFixed(2)}</td>
                        <td style="padding: 8px; border-bottom: 1px solid #cbd5e1; text-align: right; font-weight: bold;">$${subtotalComponente.toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            filasComponentes = `<tr><td colspan="5" style="padding: 12px; text-align: center; color: #64748b; font-style: italic;">No hay componentes registrados en el BOM.</td></tr>`;
        }

        const ventanaPrint = window.open('', '_blank', 'width=900,height=700');
        if (!ventanaPrint) {
            alert("⚠️ El navegador bloqueó la ventana emergente. Por favor permita las ventanas emergentes para este sitio.");
            return;
        }

        ventanaPrint.document.write(`
            <!DOCTYPE html>
            <html lang="es">
            <head>
                <meta charset="UTF-8">
                <title>Reporte Ejecutivo - Orden #${orden.id}</title>
                <style>
                    body { font-family: Arial, sans-serif; color: #1e293b; margin: 20px; font-size: 14px; }
                    h2 { color: #0f172a; border-bottom: 2px solid #0f172a; padding-bottom: 8px; margin-bottom: 16px; }
                    .header-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-bottom: 24px; background: #f8fafc; padding: 12px; border: 1px solid #e2e8f0; border-radius: 6px; }
                    .header-item span { display: block; font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: bold; }
                    .header-item strong { font-size: 14px; color: #0f172a; }
                    table { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
                    th { background: #0f172a; color: #ffffff; padding: 10px; font-size: 12px; text-align: left; }
                    .totales-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-top: 20px; }
                    .total-card { background: #f8fafc; border: 1px solid #cbd5e1; padding: 12px; border-radius: 6px; text-align: center; }
                    .total-card span { display: block; font-size: 11px; color: #64748b; margin-bottom: 4px; text-transform: uppercase; font-weight: bold; }
                    .total-card strong { font-size: 16px; color: #0f172a; }
                    @media print {
                        body { margin: 0; font-size: 12px; }
                        .no-print { display: none !important; }
                    }
                </style>
            </head>
            <body>
                <h2>📊 Resumen Ejecutivo de Orden de Producción</h2>
                
                <div class="header-grid">
                    <div class="header-item">
                        <span>Orden / Lote Resultante</span>
                        <strong>ID #${orden.id} | ${orden.numero_lote || 'N/D'}</strong>
                    </div>
                    <div class="header-item">
                        <span>Producto Producido</span>
                        <strong>${orden.productos?.nombre || 'N/D'}</strong>
                    </div>
                    <div class="header-item">
                        <span>Cantidad Producida</span>
                        <strong>${cant} unidades</strong>
                    </div>
                    <div class="header-item">
                        <span>Fecha de Registro</span>
                        <strong>${new Date(orden.created_at).toLocaleString()}</strong>
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #334155; margin-bottom: 8px; text-transform: uppercase;">Desglose de Componentes (BOM)</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Componente</th>
                            <th style="text-align: center;">Cant. Unit.</th>
                            <th style="text-align: center;">Cant. Total Req.</th>
                            <th style="text-align: right;">Costo Unit.</th>
                            <th style="text-align: right;">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${filasComponentes}
                    </tbody>
                </table>

                <h3 style="font-size: 14px; color: #334155; margin-bottom: 8px; text-transform: uppercase;">Resumen Financiero Ejecutivo</h3>
                <div class="totales-grid">
                    <div class="total-card">
                        <span>Total Materiales</span>
                        <strong>$${matTotal.toFixed(2)}</strong>
                    </div>
                    <div class="total-card">
                        <span>Mano de Obra (${orden.empleados_involucrados || 1} pers.)</span>
                        <strong>$${mobTotal.toFixed(2)}</strong>
                    </div>
                    <div class="total-card">
                        <span>Costo Unitario Final</span>
                        <strong style="color: #059669;">$${unitFinal.toFixed(2)} / u</strong>
                    </div>
                    <div class="total-card">
                        <span>Costo Total del Lote</span>
                        <strong style="color: #d97706;">$${costoTotalGlobal.toFixed(2)}</strong>
                    </div>
                </div>

                <div style="margin-top: 40px; text-align: center;" class="no-print">
                    <button onclick="window.print();" style="background: #0f172a; color: white; border: none; padding: 10px 20px; font-size: 14px; border-radius: 6px; cursor: pointer; font-weight: bold;">🖨️ Imprimir / Guardar PDF</button>
                </div>
            </body>
            </html>
        `);
        ventanaPrint.document.close();
    } catch (err) {
        console.error("Error al generar ventana imprimible:", err);
        alert("❌ Error al abrir la ventana emergente imprimible.");
    }
}