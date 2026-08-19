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
                    <h3 class="text-lg font-semibold mb-4 text-amber-400 flex items-center gap-2">⚙️ Ejecutar Orden y Mano de Obra</h3>
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
                                <input type="text" id="empleadosProduccion" placeholder="1" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">COSTO TOTAL DE MANO DE OBRA (MXN)</label>
                            <input type="number" step="0.01" id="costoManoObra" placeholder="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">NÚMERO DE LOTE DE PRODUCTO TERMINADO</label>
                            <input type="text" id="loteTerminado" placeholder="Ej. 444" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                        </div>
                        <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-medium py-2 rounded-lg transition text-sm shadow-md" style="cursor: pointer;">Ejecutar Orden de Producción</button>
                    </form>
                </div>
            `;
            
            const formOrden = document.getElementById('formOrdenProduccion');
            formOrden.addEventListener('submit', async (e) => {
                e.preventDefault();
                const productoId = document.getElementById('productoProducirId').value;
                const cantidad = parseFloat(document.getElementById('cantidadProducir').value) || 0;
                const empleados = document.getElementById('empleadosProduccion').value;
                const costoManoObra = parseFloat(document.getElementById('costoManoObra').value) || 0;
                const loteTerminado = document.getElementById('loteTerminado').value;

                try {
                    const { error: errInsert } = await supabaseClient
                        .from('ordenes_produccion')
                        .insert([{
                            producto_id: productoId,
                            cantidad_producida: cantidad,
                            empleados_involucrados: empleados,
                            costo_total_mano_obra: costoManoObra,
                            numero_lote: loteTerminado
                        }]);

                    if (errInsert) throw errInsert;

                    alert("¡Orden de producción ejecutada exitosamente, mi lord!");
                    formOrden.reset();
                    cargarModuloProduccion();
                    cargarInventarioCompleto();
                } catch (err) {
                    console.error("Error al ejecutar orden de producción:", err);
                    alert("Error al registrar la orden de producción.");
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

        const { data: ordenes, error } = await supabaseClient
            .from('ordenes_produccion')
            .select('*')
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
                                <th class="p-3">Cantidad Producida</th>
                                <th class="p-3">Empleados</th>
                                <th class="p-3">Costo Materiales</th>
                                <th class="p-3">Costo Mano Obra</th>
                                <th class="p-3">Costo Unitario Final</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            ordenes.forEach(o => {
                html += `
                    <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition">
                        <td class="p-3 font-mono text-xs text-sky-300">${o.id}</td>
                        <td class="p-3 font-mono text-slate-100">${o.cantidad_producida}</td>
                        <td class="p-3 text-slate-400">${o.empleados_involucrados || 'N/D'}</td>
                        <td class="p-3 font-mono">$${Number(o.costo_total_materiales || 0).toFixed(2)}</td>
                        <td class="p-3 font-mono">$${Number(o.costo_total_mano_obra || 0).toFixed(2)}</td>
                        <td class="p-3 font-mono font-bold text-emerald-400">$${Number(o.costo_unitario_final || 0).toFixed(2)}</td>
                    </tr>
                `;
            });

            html += `</tbody></table></div>`;
            contenedorHistorial.innerHTML = html;
        }
    } catch (err) {
        console.error("Error al cargar órdenes de producción:", err);
        if (contenedorHistorial) {
            contenedorHistorial.innerHTML = `<p class="text-red-400 text-sm">Error al cargar el historial de producción.</p>`;
        }
    }
}