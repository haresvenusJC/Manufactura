import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');
    
    try {
        if (!supabaseClient || !contenedorProd) return;

        contenedorProd.innerHTML = `
            <div class="space-y-6 max-w-4xl mx-auto">
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

                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-4">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">📊 Resumen Ejecutivo y Costos por Orden</h3>
                        <div class="flex items-center gap-2 w-full md:w-auto">
                            <select id="selectOrdenId" class="w-full md:w-72 bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-amber-300 font-mono">
                                <option value="">Seleccione orden por ID...</option>
                            </select>
                            <button id="btnImprimirOrden" class="bg-slate-800 hover:bg-slate-700 text-amber-400 p-2 rounded-lg border border-slate-700 transition-all text-sm flex items-center gap-1" title="Ventana Imprimible" disabled>🖨️</button>
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
            .select('id, nombre, sku, tipo')
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
                    costoTotalManoObra: parseFloat(document.getElementById('costoManoObra').value) || 0
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
                        if (typeof cargarInventarioCompleto === 'function') await cargarInventarioCompleto();
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
        const empleadosInvolucrados = Number(datosOrden.empleadosInvolucrados) || 1;
        const costoTotalManoObra = Number(datosOrden.costoTotalManoObra) || 0;

        if (!productoId || cantidadProducida <= 0 || !numeroLote) {
            throw new Error("Faltan datos obligatorios o la cantidad a producir es inválida.");
        }

        const { data: componentes, error: errComp } = await supabaseClient
            .from('bom')
            .select('componente_id, cantidad_requerida, unidad_medida')
            .eq('producto_id', productoId);

        if (errComp) throw errComp;
        if (!componentes || componentes.length === 0) {
            throw new Error("El producto seleccionado no tiene una receta o BOM registrada.");
        }

        const idsComponentes = componentes.map(c => c.componente_id);
        const { data: infoInsumos, error: errInsumos } = await supabaseClient
            .from('productos')
            .select('id, nombre, costo_unitario, unidad_medida_id, unidades_medida ( id, nombre )')
            .in('id', idsComponentes);

        if (errInsumos) throw errInsumos;
        const mapaCostos = new Map(infoInsumos.map(i => [i.id, i]));

        const folioDocumento = `PROD-${Date.now().toString().slice(-6)}`;
        const { data: docInsertado, error: errDoc } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: 'entrada_produccion',
                folio: folioDocumento,
                fecha_emision: new Date().toISOString(),
                descripcion: `Orden de producción para lote ${numeroLote}`,
                estado: 'completado'
            }])
            .select('id')
            .single();

        if (errDoc) throw errDoc;
        const documentoIdCreado = docInsertado.id;

        let costoTotalMateriales = 0;

        for (const comp of componentes) {
            const componenteId = Number(comp.componente_id);
            const datosIns = mapaCostos.get(componenteId) || {};
            
            let cantidadReqUnit = Number(comp.cantidad_requerida || 0);
            let cantidadTotalRequerida = cantidadReqUnit * cantidadProducida;

            const unidadBom = String(comp.unidad_medida || '').toLowerCase().trim();
            const unidadCat = String(datosIns.unidades_medida?.nombre || '').toLowerCase().trim();

            if (unidadBom.includes('ml') || unidadBom.includes('g') || unidadCat.includes('ml') || unidadCat.includes('g') || cantidadReqUnit > 10) {
                cantidadTotalRequerida /= 1000;
            }

            const costoUnitarioCatalogo = Number(datosIns.costo_unitario || 0);

            // Se envía null en p_costo_unitario_fijo para que el RPC use el costo real y específico de cada lote
            const { data: lotesConsumidos, error: errRpcSalida } = await supabaseClient.rpc('registrar_salida_fifo', {
                p_producto_id: componenteId,
                p_cantidad_salida: Number(cantidadTotalRequerida),
                p_tipo_movimiento: 'salida_produccion',
                p_documento_id: documentoIdCreado,
                p_costo_unitario_fijo: null 
            });

            if (errRpcSalida) throw new Error(`Error al descontar insumo ID ${componenteId} (FIFO): ${errRpcSalida.message}`);

            if (Array.isArray(lotesConsumidos) && lotesConsumidos.length > 0) {
                lotesConsumidos.forEach(lote => {
                    const cantLote = Number(lote.cantidad || 0);
                    const costoLote = Number(lote.costo_unitario ?? costoUnitarioCatalogo);
                    costoTotalMateriales += (cantLote * costoLote);
                });
            } else {
                costoTotalMateriales += (cantidadTotalRequerida * costoUnitarioCatalogo);
            }
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

        const { error: errRpcEntrada } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
            p_producto_id: Number(productoId),
            p_cantidad: Number(cantidadProducida),
            p_tipo_movimiento: 'entrada_produccion',
            p_documento_id: Number(documentoIdCreado),
            p_costo_unitario: Number(costoUnitarioFinal),
            p_numero_lote: String(numeroLote)
        });

        if (errRpcEntrada) throw new Error(`Error al registrar entrada de producto terminado: ${errRpcEntrada.message}`);

        await supabaseClient.from('productos').update({ costo_unitario: costoUnitarioFinal }).eq('id', productoId);

        return { success: true, ordenIdCreada: ordenInsertada.id, mensaje: "Orden ejecutada e insumos descontados correctamente por lote (FIFO)." };
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
            .select(`id, producto_id, numero_lote, cantidad_producida, costo_unitario_final, costo_total_materiales, costo_total_mano_obra, created_at, productos ( id, nombre, sku )`)
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

        let html = `
            <h4 class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3 mt-6">Historial General de Órdenes</h4>
            <div class="overflow-x-auto"><table class="w-full text-left text-sm text-slate-300">
                <thead><tr class="border-b border-slate-800 text-amber-400">
                    <th class="p-2">ID</th><th class="p-2">Fecha</th><th class="p-2">Lote PT</th><th class="p-2">Producto</th><th class="p-2">Cantidad</th><th class="p-2">Costo Unit. Final</th>
                </tr></thead><tbody>
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

        const targetId = idSeleccionarReciente || ordenes[0].id;
        if (selectOrdenId) {
            selectOrdenId.value = targetId;
            if (btnImprimirOrden) btnImprimirOrden.disabled = false;
            await renderizarDetalleOrden(targetId, ordenes, detalleResumenOrden);
        }
    } catch (err) {
        console.error("Error al cargar historial:", err);
    }
}

async function renderizarDetalleOrden(idSeleccionado, ordenes, contenedorDetalle) {
    if (!idSeleccionado || !contenedorDetalle) return;
    const orden = ordenes.find(item => item.id === idSeleccionado);
    if (!orden) return;
    
    contenedorDetalle.innerHTML = `<p class="text-slate-400 text-sm text-center py-2">Cargando desglose de componentes por lote...</p>`;
    
    try {
        let docIdAUsar = null;
        const { data: loteOrden, error: errLote } = await supabaseClient
            .from('lotes_inventario')
            .select('documento_id')
            .eq('producto_id', orden.producto_id)
            .eq('numero_lote', orden.numero_lote)
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();

        if (!errLote && loteOrden) {
            docIdAUsar = loteOrden.documento_id;
        }

        let movimientosSalida = [];

        if (docIdAUsar) {
            const { data: movs, error: errMov } = await supabaseClient
                .from('movimientos_inventario')
                .select(`
                    cantidad,
                    costo_unitario,
                    lotes_inventario ( numero_lote ),
                    productos ( id, nombre, unidades_medida ( nombre ) )
                `)
                .eq('documento_id', docIdAUsar)
                .eq('tipo_movimiento', 'salida_produccion');

            if (!errMov && movs) {
                movimientosSalida = movs;
            }
        }

        const cantidadProducidaLote = Number(orden.cantidad_producida || 1);
        let htmlComponentes = '';
        let importeTotalFormula = 0;

        if (movimientosSalida && movimientosSalida.length > 0) {
            movimientosSalida.forEach(mov => {
                const nombreInsumo = mov.productos?.nombre || 'Insumo desconocido';
                const loteOrigen = mov.lotes_inventario?.numero_lote ? ` (Lote: ${mov.lotes_inventario.numero_lote})` : '';
                
                const cantidadDescontada = Math.abs(Number(mov.cantidad || 0));
                const costoUnitario = Number(mov.costo_unitario || 0);
                const subtotal = cantidadDescontada * costoUnitario;
                importeTotalFormula += subtotal;

                const unidadMedidaTexto = mov.productos?.unidades_medida?.nombre || 'Unid';

                htmlComponentes += `
                    <tr class="border-b border-slate-900/60 text-xs">
                        <td class="py-2.5 px-3 font-medium text-slate-200">
                            ${nombreInsumo} <span class="text-amber-400 font-mono text-[11px]">${loteOrigen}</span>
                        </td>
                        <td class="py-2.5 px-3 font-mono text-amber-300">${cantidadDescontada.toFixed(4)}</td>
                        <td class="py-2.5 px-3 text-slate-400">${unidadMedidaTexto}</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300">$${costoUnitario.toFixed(2)}</td>
                        <td class="py-2.5 px-3 font-mono text-emerald-400 text-right font-semibold">$${subtotal.toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            htmlComponentes = `
                <tr>
                    <td colspan="5" class="py-3 px-3 text-center text-slate-400 italic">
                        No se encontraron movimientos de lotes registrados para esta orden.
                    </td>
                </tr>
            `;
        }

        const mobTotal = Number(orden.costo_total_mano_obra || 0);
        const unitFinal = Number(orden.costo_unitario_final || 0);
        const materialTotalFinal = orden.costo_total_materiales ? Number(orden.costo_total_materiales) : importeTotalFormula;

        contenedorDetalle.innerHTML = `
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4 pb-4 border-b border-slate-800">
                <div><span class="text-xs text-slate-400 block">ORDEN / LOTE</span><span class="font-mono font-bold text-amber-400">ID #${orden.id} | ${orden.numero_lote}</span></div>
                <div><span class="text-xs text-slate-400 block">PRODUCTO</span><span class="font-medium text-slate-100">${orden.productos?.nombre}</span></div>
                <div><span class="text-xs text-slate-400 block">CANTIDAD</span><span class="font-mono text-slate-200">${cantidadProducidaLote}</span></div>
                <div><span class="text-xs text-slate-400 block">FECHA</span><span class="text-slate-300">${new Date(orden.created_at).toLocaleString()}</span></div>
            </div>
            
            <table class="w-full text-left text-sm text-slate-300 bg-slate-900 rounded-lg overflow-hidden mb-4">
                <thead>
                    <tr class="border-b border-slate-800 text-xs text-slate-400 bg-slate-950">
                        <th class="py-2.5 px-3">Materia Prima / Componente</th>
                        <th class="py-2.5 px-3">Cantidad</th>
                        <th class="py-2.5 px-3">Unidad</th>
                        <th class="py-2.5 px-3">Costo</th>
                        <th class="py-2.5 px-3 text-right">Subtotal</th>
                    </tr>
                </thead>
                <tbody>${htmlComponentes}</tbody>
            </table>

            <div class="bg-slate-950 border border-slate-800 p-4 rounded-lg mb-4 flex justify-between items-center">
                <span class="text-sm font-semibold text-amber-400">📊 Importe Total de todos los Componentes de la Fórmula:</span>
                <span class="text-lg font-mono font-bold text-emerald-400">$${importeTotalFormula.toFixed(2)}</span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-4 gap-3">
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Materiales</span><span class="font-mono text-base text-slate-200 font-bold">$${materialTotalFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Mano de Obra</span><span class="font-mono text-base text-slate-200 font-bold">$${mobTotal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Costo Unitario</span><span class="font-mono text-base text-emerald-400 font-bold">$${unitFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Total Lote</span><span class="font-mono text-base text-amber-300 font-bold">$${(cantidadProducidaLote * unitFinal).toFixed(2)}</span></div>
            </div>`;
    } catch (err) { 
        console.error("Error al renderizar el detalle de la orden:", err); 
    }
}