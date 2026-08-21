import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');
    
    try {
        if (!supabaseClient) return;

        // 1. Renderizar el formulario de ejecución de órdenes incluyendo Costos Indirectos[cite: 6]
        if (contenedorProd) {
            contenedorProd.innerHTML = `
                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl max-w-2xl mx-auto">
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
                        <div class="grid grid-cols-3 gap-3">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">EMPLEADOS</label>
                                <input type="number" id="empleadosInvolucrados" min="1" value="1" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">MANO DE OBRA ($)</label>
                                <input type="number" id="costoManoObra" min="0" step="0.01" value="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">COSTOS INDIRECTOS ($)</label>
                                <input type="number" id="costosIndirectos" min="0" step="0.01" value="0.00" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                        </div>
                        <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-semibold py-2 px-4 rounded-lg transition-all text-sm shadow-lg">
                            🚀 Registrar Producción y Descontar Insumos (FIFO)
                        </button>
                    </form>
                </div>
            `;

            // Poblar el selector de productos terminados[cite: 6]
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

            // Escuchar el evento submit del formulario[cite: 6]
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
                        costoTotalIndirectos: parseFloat(document.getElementById('costosIndirectos').value) || 0,
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
                            cargarHistorialProduccion();
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

        cargarHistorialProduccion();

    } catch (err) {
        console.error("Error al inicializar el módulo de producción:", err);
    }
}

// Función principal transaccional adaptada al esquema exacto de Supabase
export async function registrarOrdenDeProduccionCompleta(datosOrden) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");

        const productoId = Number(datosOrden.productoId);
        const cantidadProducida = Number(datosOrden.cantidadProducida) || 0;
        const numeroLote = String(datosOrden.numeroLote || '').trim();
        const moneda = String(datosOrden.moneda || 'MXN');
        const empleadosInvolucrados = Number(datosOrden.empleadosInvolucrados) || 1;
        const costoTotalManoObra = Number(datosOrden.costoTotalManoObra) || 0;
        const costoTotalIndirectos = Number(datosOrden.costoTotalIndirectos) || 0;

        if (!productoId || cantidadProducida <= 0 || !numeroLote) {
            throw new Error("Faltan datos obligatorios o la cantidad a producir es inválida.");
        }

        let costoTotalMateriales = 0;

        // 1. Obtener la lista de materiales (BOM) del producto usando las relaciones oficiales[cite: 6]
        const { data: componentes, error: errComp } = await supabaseClient
            .from('bom')
            .select(`
                materia_prima_id, 
                hijo_producto_id, 
                cantidad_requerida, 
                factor_merma,
                materias_primas ( id, nombre ),
                productos:hijo_producto_id ( id, nombre )
            `)
            .eq('producto_id', productoId);

        if (errComp) throw errComp;

        if (!componentes || componentes.length === 0) {
            throw new Error("El producto seleccionado no tiene una receta o BOM registrada.");
        }

        for (const comp of componentes) {
            const esMateriaPrima = Boolean(comp.materia_prima_id);
            const componenteTargetId = Number(comp.materia_prima_id || comp.hijo_producto_id);
            const nombreComponente = comp.materias_primas?.nombre || comp.productos?.nombre || `ID: ${componenteTargetId}`;

            if (!componenteTargetId) {
                throw new Error("Error en la receta (BOM): Se encontró un componente sin un identificador válido.");
            }

            const merma = Number(comp.factor_merma || 1);
            const cantidadTotalRequerida = Number(comp.cantidad_requerida) * cantidadProducida * merma;
            let cantidadPendienteDescontar = cantidadTotalRequerida;

            let lotesEncontrados = [];
            let tablaDestino = '';

            // 2. Consultar lotes selectivamente según la tabla de origen correspondiente
            if (esMateriaPrima) {
                tablaDestino = 'lotes_materias_primas';
                const { data: lotesMP, error: errMP } = await supabaseClient
                    .from(tablaDestino)
                    .select('id, materia_prima_id, stock_actual, costo_unitario, fecha_ingreso')
                    .eq('materia_prima_id', componenteTargetId)
                    .gt('stock_actual', 0)
                    .order('fecha_ingreso', { ascending: true });

                if (!errMP && lotesMP) {
                    lotesEncontrados = lotesMP;
                }
            } else {
                tablaDestino = 'lotes_producto_terminado';
                const { data: lotesPT, error: errPT } = await supabaseClient
                    .from(tablaDestino)
                    .select('id, producto_id, stock_actual, costo_unitario, created_at')
                    .eq('producto_id', componenteTargetId)
                    .gt('stock_actual', 0)
                    .order('created_at', { ascending: true });

                if (!errPT && lotesPT) {
                    lotesEncontrados = lotesPT;
                }
            }

            if (!lotesEncontrados || lotesEncontrados.length === 0) {
                throw new Error(`Stock insuficiente: El componente "${nombreComponente}" no cuenta con lotes activos en inventario.`);
            }

            // 3. Aplicar descuento estricto por FIFO sobre los lotes encontrados
            for (const lote of lotesEncontrados) {
                if (cantidadPendienteDescontar <= 0) break;

                const stockLote = Number(lote.stock_actual);
                let aDescontar = stockLote >= cantidadPendienteDescontar ? cantidadPendienteDescontar : stockLote;

                cantidadPendienteDescontar -= aDescontar;
                const nuevoStockLote = stockLote - aDescontar;

                costoTotalMateriales += (aDescontar * Number(lote.costo_unitario || 0));

                const { error: errUpLote } = await supabaseClient
                    .from(tablaDestino)
                    .update({ stock_actual: nuevoStockLote })
                    .eq('id', lote.id);

                if (errUpLote) throw errUpLote;
            }

            if (cantidadPendienteDescontar > 0) {
                throw new Error(`Stock insuficiente: No hay suficientes existencias de "${nombreComponente}" para completar la cantidad requerida.`);
            }
        }

        // 4. Calcular costo unitario final integrando Materiales + Mano de Obra + Costos Indirectos[cite: 6]
        const costoUnitarioFinal = cantidadProducida > 0 
            ? ((costoTotalMateriales + costoTotalManoObra + costoTotalIndirectos) / cantidadProducida) 
            : 0;

        // 5. Registrar la Orden de Producción oficial[cite: 6]
        const { error: errOrden } = await supabaseClient
            .from('ordenes_produccion')
            .insert([{
                producto_id: productoId,
                cantidad_producida: cantidadProducida,
                empleados_involucrados: empleadosInvolucrados,
                costo_total_mano_obra: costoTotalManoObra,
                costo_total_materiales: costoTotalMateriales,
                costo_unitario_final: costoUnitarioFinal,
                numero_lote: numeroLote
            }]);

        if (errOrden) throw errOrden;

        // 6. Registrar el nuevo lote de producto terminado resultante[cite: 6]
        const { error: errLoteProd } = await supabaseClient
            .from('lotes_producto_terminado')
            .insert([{
                producto_id: productoId,
                numero_lote: numeroLote,
                stock_actual: cantidadProducida,
                costo_unitario: costoUnitarioFinal,
                moneda: moneda,
                fecha_produccion: new Date().toISOString().split('T')[0]
            }]);

        if (errLoteProd) throw errLoteProd;

        return { 
            success: true, 
            mensaje: "Orden ejecutada con éxito, componentes descontados por FIFO, costos agregados y nuevo lote registrado." 
        };

    } catch (error) {
        console.error("Error en orden de producción:", error.message);
        return { success: false, error: error.message };
    }
}

// Cargar Historial de Órdenes[cite: 6]
async function cargarHistorialProduccion() {
    const contenedorHistorial = document.getElementById('contenedorHistorialProduccion');
    try {
        if (!contenedorHistorial) return;

        const { data: ordenes, error } = await supabaseClient
            .from('ordenes_produccion')
            .select(`
                id,
                numero_lote,
                cantidad_producida,
                costo_unitario_final,
                created_at,
                productos ( nombre, sku )
            `)
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!ordenes || ordenes.length === 0) {
            contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">No hay órdenes de producción registradas.</p>`;
            return;
        }

        let html = `
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-amber-400">
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
                <tr class="border-b border-slate-900">
                    <td class="p-2 text-xs text-slate-400">${new Date(o.created_at).toLocaleDateString()}</td>
                    <td class="p-2 font-mono text-xs text-amber-300">${o.numero_lote || 'N/D'}</td>
                    <td class="p-2 font-medium text-slate-100">${o.productos?.nombre || 'Desconocido'}</td>
                    <td class="p-2 font-mono">${o.cantidad_producida}</td>
                    <td class="p-2 font-mono text-emerald-400">$${Number(o.costo_unitario_final || 0).toFixed(2)}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorHistorial.innerHTML = html;

    } catch (err) {
        console.error("Error al cargar historial de producción:", err);
        contenedorHistorial.innerHTML = `<p class="text-red-400 text-sm">Error al cargar historial.</p>`;
    }
}