import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');
    const contenedorHistorial = document.getElementById('contenedorHistorialProduccion');
    
    try {
        if (!supabaseClient) return;

        if (contenedorProd) {
            contenedorProd.innerHTML = `
                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl max-w-2xl mx-auto">
                    <h3 class="text-lg font-semibold mb-4 text-amber-400 flex items-center gap-2">⚙️ Ejecutar Orden y Costos de Producción</h3>
                    <form id="formOrdenProduccion" class="space-y-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PRODUCTO A PRODUCIR</label>
                            <select id="productoProducirId" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                <option value="">Cargando productos...</option>
                            </select>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">CANTIDAD A PRODUCIR</label>
                                <input type="number" step="1" id="cantidadProducir" placeholder="0" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">EMPLEADOS INVOLUCRADOS</label>
                                <input type="number" step="1" id="empleadosProduccion" placeholder="1" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">COSTO TOTAL MANO DE OBRA (MXN)</label>
                                <input type="number" step="0.01" id="costoManoObra" placeholder="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">COSTOS INDIRECTOS / OTROS (MXN)</label>
                                <input type="number" step="0.01" id="costosIndirectos" placeholder="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" value="0">
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">NÚMERO DE LOTE DE PRODUCTO TERMINADO</label>
                            <input type="text" id="loteTerminado" placeholder="Ej. 444" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                        </div>
                        <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Calcular y Ejecutar Orden</button>
                    </form>
                </div>

                <!-- Modal de Desglose Analítico Profesional -->
                <div id="modalDesgloseOrden" class="fixed inset-0 bg-black/70 backdrop-blur-sm hidden items-center justify-center z-50 p-4">
                    <div class="bg-slate-900 border border-slate-800 rounded-xl shadow-2xl max-w-lg w-full p-6 text-slate-100">
                        <div class="flex justify-between items-center border-b border-slate-800 pb-3 mb-4">
                            <h4 class="text-amber-400 font-bold text-base flex items-center gap-2">📊 Desglose Analítico de Orden de Producción</h4>
                            <button id="cerrarModalDesglose" class="text-slate-400 hover:text-white text-lg font-bold px-2" style="cursor: pointer;">&times;</button>
                        </div>
                        <div id="contenidoDesgloseModal" class="space-y-3 text-sm">
                            <!-- Inyección dinámica de datos analíticos -->
                        </div>
                        <div class="mt-6 pt-3 border-t border-slate-800 text-right">
                            <button id="btnCerrarModal" class="bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-lg text-xs font-medium transition" style="cursor: pointer;">Cerrar Desglose</button>
                        </div>
                    </div>
                </div>
            `;
            
            // Configurar eventos de cierre del modal
            const modal = document.getElementById('modalDesgloseOrden');
            const cerrarModal = () => modal.classList.add('hidden');
            document.getElementById('cerrarModalDesglose').onclick = cerrarModal;
            document.getElementById('btnCerrarModal').onclick = cerrarModal;
            modal.onclick = (e) => { if (e.target === modal) cerrarModal(); };

            const formOrden = document.getElementById('formOrdenProduccion');
            formOrden.addEventListener('submit', async (e) => {
                e.preventDefault();
                const productoId = parseInt(document.getElementById('productoProducirId').value);
                const cantidad = parseFloat(document.getElementById('cantidadProducir').value) || 0;
                const empleados = parseInt(document.getElementById('empleadosProduccion').value) || 1;
                const costoManoObra = parseFloat(document.getElementById('costoManoObra').value) || 0;
                const costosIndirectos = parseFloat(document.getElementById('costosIndirectos').value) || 0;
                const loteTerminado = document.getElementById('loteTerminado').value.trim();

                try {
                    let costoTotalMateriales = 0;

                    async function calcularCostoLista(tabla) {
                        const { data: items, error } = await supabaseClient
                            .from(tabla)
                            .select('materia_prima_id, hijo_producto_id, cantidad_requerida, factor_merma')
                            .eq('producto_id', productoId);

                        if (!error && items && items.length > 0) {
                            for (const item of items) {
                                const cantReq = Number(item.cantidad_requerida || 0);
                                const merma = Number(item.factor_merma || 1) || 1;
                                let costoUnitario = 0;

                                if (item.materia_prima_id) {
                                    const { data: matData } = await supabaseClient
                                        .from('materias_primas')
                                        .select('costo_unitario')
                                        .eq('id', item.materia_prima_id)
                                        .single();
                                    costoUnitario = matData ? Number(matData.costo_unitario || 0) : 0;
                                } else if (item.hijo_producto_id) {
                                    const { data: prodData } = await supabaseClient
                                        .from('productos')
                                        .select('costo_unitario')
                                        .eq('id', item.hijo_producto_id)
                                        .single();
                                    costoUnitario = prodData ? Number(prodData.costo_unitario || 0) : 0;
                                }

                                costoTotalMateriales += (cantReq * merma * costoUnitario * cantidad);
                            }
                        }
                    }

                    await calcularCostoLista('bom');
                    await calcularCostoLista('componentes');

                    const costoTotalGlobal = costoTotalMateriales + costoManoObra + costosIndirectos;
                    const costoUnitarioFinal = cantidad > 0 ? costoTotalGlobal / cantidad : 0;

                    const confirmacion = confirm(
                        `--- RESUMEN DE PRODUCCIÓN ---\n` +
                        `• Costo Total de Materiales: $${costoTotalMateriales.toFixed(2)}\n` +
                        `• Costo de Mano de Obra: $${costoManoObra.toFixed(2)}\n` +
                        `• Costos Indirectos / Otros: $${costosIndirectos.toFixed(2)}\n` +
                        `-----------------------------------------\n` +
                        `• Costo Total de la Orden: $${costoTotalGlobal.toFixed(2)}\n` +
                        `• Costo Unitario Final: $${costoUnitarioFinal.toFixed(2)}\n\n` +
                        `¿Desea proceder a registrar la orden y el lote, mi lord?`
                    );

                    if (!confirmacion) return;

                    const { error: errLote } = await supabaseClient
                        .from('lotes_producto_terminado')
                        .insert([{
                            producto_id: productoId,
                            numero_lote: loteTerminado,
                            stock_actual: cantidad,
                            costo_unitario: costoUnitarioFinal,
                            moneda: 'MXN',
                            fecha_produccion: new Date().toISOString().split('T')[0]
                        }]);

                    if (errLote) throw errLote;

                    const { error: errInsert } = await supabaseClient
                        .from('ordenes_produccion')
                        .insert([{
                            producto_id: productoId,
                            cantidad_producida: cantidad,
                            empleados_involucrados: empleados,
                            costo_total_materiales: costoTotalMateriales,
                            costo_total_mano_obra: (costoManoObra + costosIndirectos),
                            costo_unitario_final: costoUnitarioFinal,
                            numero_lote: loteTerminado
                        }]);

                    if (errInsert) throw errInsert;

                    alert("¡Orden de producción, costos y lote registrados exitosamente, mi lord!");
                    formOrden.reset();
                    await cargarModuloProduccion();
                    await cargarInventarioCompleto();
                } catch (err) {
                    console.error("Error al ejecutar orden de producción:", err);
                    alert("Error al registrar la orden de producción. Verifique los datos en consola.");
                }
            });
        }

        const selectProducto = document.getElementById('productoProducirId');
        const { data: prods, error: errProds } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku');
        
        if (!errProds && prods && selectProducto) {
            let optionsHtml = '<option value="">Seleccione un producto...</option>';
            prods.forEach(p => {
                optionsHtml += `<option value="${p.id}">${p.nombre} ${p.sku ? '(' + p.sku + ')' : ''}</option>`;
            });
            selectProducto.innerHTML = optionsHtml;
        }

        // Consultar órdenes incluyendo la relación con productos para mostrar el nombre
        const { data: ordenes, error } = await supabaseClient
            .from('ordenes_produccion')
            .select('*, productos(nombre, sku)')
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (contenedorHistorial) {
            if (!ordenes || ordenes.length === 0) {
                contenedorHistorial.innerHTML = `
                    <div class="p-4 bg-slate-950/50 rounded-lg border border-slate-800">
                        <p class="text-slate-400 text-sm">No hay órdenes de producción registradas en la base de datos.</p>
                    </div>
                `;
                return;
            }

            let html = `
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead>
                            <tr class="border-b border-slate-800 text-sky-400">
                                <th class="p-3">ID Orden</th>
                                <th class="p-3">Producto</th>
                                <th class="p-3">Lote</th>
                                <th class="p-3">Cantidad</th>
                                <th class="p-3">Costo Materiales</th>
                                <th class="p-3">Mano de Obra</th>
                                <th class="p-3">Unitario Final</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            ordenes.forEach(o => {
                const nombreProd = o.productos?.nombre || 'Producto Desconocido';
                html += `
                    <tr class="border-b border-slate-900 hover:bg-slate-800/60 transition cursor-pointer fila-orden" data-orden-id="${o.id}">
                        <td class="p-3 font-mono text-xs text-sky-300">#${o.id}</td>
                        <td class="p-3 font-medium text-slate-100">${nombreProd}</td>
                        <td class="p-3 font-mono text-amber-300 font-semibold">${o.numero_lote || 'N/D'}</td>
                        <td class="p-3 font-mono text-slate-100">${o.cantidad_producida}</td>
                        <td class="p-3 font-mono">$${Number(o.costo_total_materiales || 0).toFixed(2)}</td>
                        <td class="p-3 font-mono">$${Number(o.costo_total_mano_obra || 0).toFixed(2)}</td>
                        <td class="p-3 font-mono font-bold text-emerald-400">$${Number(o.costo_unitario_final || 0).toFixed(2)}</td>
                    </tr>
                `;
            });

            html += `</tbody></table></div>`;
            contenedorHistorial.innerHTML = html;

            // Vincular el evento de clic para consultar y abrir el modal analítico con desglose de materiales
            document.querySelectorAll('.fila-orden').forEach(fila => {
                fila.addEventListener('click', async () => {
                    const ordenId = parseInt(fila.getAttribute('data-orden-id'));
                    const data = ordenes.find(item => item.id === ordenId);
                    if (!data) return;

                    const prodNombre = data.productos?.nombre || 'N/D';
                    const productoId = data.producto_id;
                    const cantidadProducida = Number(data.cantidad_producida || 1);
                    const costoMat = Number(data.costo_total_materiales || 0);
                    const costoMO = Number(data.costo_total_mano_obra || 0);
                    const costoTotal = costoMat + costoMO;
                    const costoUnit = Number(data.costo_unitario_final || 0);
                    const fecha = new Date(data.created_at).toLocaleString();

                    let componentesDetalleHtml = '';
                    try {
                        const { data: bomItems } = await supabaseClient
                            .from('bom')
                            .select(`
                                cantidad_requerida,
                                factor_merma,
                                materias_primas (nombre, costo_unitario),
                                productos:hijo_producto_id (nombre, costo_unitario)
                            `)
                            .eq('producto_id', productoId);

                        const { data: compItems } = await supabaseClient
                            .from('componentes')
                            .select(`
                                cantidad_requerida,
                                factor_merma,
                                materias_primas (nombre, costo_unitario),
                                productos:hijo_producto_id (nombre, costo_unitario)
                            `)
                            .eq('producto_id', productoId);

                        const todosLosInsumos = [...(bomItems || []), ...(compItems || [])];

                        if (todosLosInsumos.length > 0) {
                            todosLosInsumos.forEach(item => {
                                const cantReqUnit = Number(item.cantidad_requerida || 0);
                                const merma = Number(item.factor_merma || 1) || 1;
                                const cantTotalConsumida = cantReqUnit * merma * cantidadProducida;
                                
                                let nombreComponente = 'Insumo / Componente';
                                let costoUnitario = 0;

                                if (item.materias_primas) {
                                    nombreComponente = item.materias_primas.nombre + ' (Materia Prima)';
                                    costoUnitario = Number(item.materias_primas.costo_unitario || 0);
                                } else if (item.productos) {
                                    nombreComponente = item.productos.nombre + ' (Subensamble)';
                                    costoUnitario = Number(item.productos.costo_unitario || 0);
                                }

                                const subtotalComponente = cantTotalConsumida * costoUnitario;

                                componentesDetalleHtml += `
                                    <tr class="border-b border-slate-900 text-xs">
                                        <td class="p-2 text-slate-200">${nombreComponente}</td>
                                        <td class="p-2 font-mono text-center text-slate-300">${cantTotalConsumida.toFixed(2)}</td>
                                        <td class="p-2 font-mono text-right text-slate-300">$${costoUnitario.toFixed(2)}</td>
                                        <td class="p-2 font-mono text-right text-amber-400 font-semibold">$${subtotalComponente.toFixed(2)}</td>
                                    </tr>
                                `;
                            });
                        }
                    } catch (errDetalle) {
                        console.error("Error al obtener detalle de componentes:", errDetalle);
                    }

                    const modalContenido = document.getElementById('contenidoDesgloseModal');
                    if (!modalContenido) return;

                    modalContenido.innerHTML = `
                        <div class="bg-slate-950 p-4 rounded-lg border border-slate-800 space-y-2">
                            <div class="grid grid-cols-2 gap-2 text-xs">
                                <div><span class="text-slate-400">ID Orden:</span> <span class="font-mono text-sky-300">#${data.id}</span></div>
                                <div><span class="text-slate-400">Lote:</span> <span class="font-mono text-amber-300">${data.numero_lote || 'N/D'}</span></div>
                                <div class="col-span-2"><span class="text-slate-400">Producto:</span> <span class="font-semibold text-slate-100">${prodNombre}</span></div>
                                <div><span class="text-slate-400">Cantidad Producida:</span> <span class="font-mono text-slate-100">${cantidadProducida} u.</span></div>
                                <div><span class="text-slate-400">Operadores:</span> <span class="text-slate-100">${data.empleados_involucrados || '1'}</span></div>
                                <div class="col-span-2"><span class="text-slate-400">Fecha:</span> <span class="text-slate-300">${fecha}</span></div>
                            </div>
                        </div>

                        <div class="bg-slate-950 p-4 rounded-lg border border-slate-800">
                            <h5 class="text-xs font-bold text-sky-400 uppercase tracking-wider mb-2">Desglose de Materiales e Insumos Consumidos</h5>
                            ${componentesDetalleHtml ? `
                                <div class="overflow-x-auto max-h-48 overflow-y-auto">
                                    <table class="w-full text-left">
                                        <thead>
                                            <tr class="border-b border-slate-800 text-[11px] text-slate-400">
                                                <th class="p-2">Componente / Insumo</th>
                                                <th class="p-2 text-center">Cant. Gastada</th>
                                                <th class="p-2 text-right">Costo Unit.</th>
                                                <th class="p-2 text-right">Subtotal</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            ${componentesDetalleHtml}
                                        </tbody>
                                    </table>
                                </div>
                            ` : `
                                <p class="text-xs text-slate-500 italic">No se encontraron componentes asociados en la lista de materiales (BOM) para este producto.</p>
                            `}
                        </div>

                        <div class="bg-slate-950 p-4 rounded-lg border border-slate-800 space-y-2">
                            <h5 class="text-xs font-bold text-sky-400 uppercase tracking-wider mb-1">Resumen Financiero Global</h5>
                            <div class="flex justify-between text-xs">
                                <span class="text-slate-400">Costo Total Materiales:</span>
                                <span class="font-mono text-slate-200">$${costoMat.toFixed(2)}</span>
                            </div>
                            <div class="flex justify-between text-xs">
                                <span class="text-slate-400">Costo Mano de Obra e Indirectos:</span>
                                <span class="font-mono text-slate-200">$${costoMO.toFixed(2)}</span>
                            </div>
                            <div class="flex justify-between text-xs border-t border-slate-800 pt-2 font-semibold">
                                <span class="text-slate-300">Costo Global de la Orden:</span>
                                <span class="font-mono text-amber-400">$${costoTotal.toFixed(2)}</span>
                            </div>
                            <div class="flex justify-between text-xs border-t border-slate-800 pt-2 font-bold">
                                <span class="text-slate-200">Costo Unitario Final:</span>
                                <span class="font-mono text-emerald-400 text-sm">$${costoUnit.toFixed(2)} / u</span>
                            </div>
                        </div>
                    `;

                    const modal = document.getElementById('modalDesgloseOrden');
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                });
            });
        }
    } catch (err) {
        console.error("Error al cargar órdenes de producción:", err);
        if (contenedorHistorial) {
            contenedorHistorial.innerHTML = `<p class="text-red-400 text-sm">Error al cargar el historial de producción.</p>`;
        }
    }
}