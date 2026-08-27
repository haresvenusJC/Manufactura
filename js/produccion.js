import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';
import { imprimirConPlantilla } from './impresion.js';

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
                        <div>
                            <div class="flex justify-between items-center mb-2">
                                <label class="block text-xs font-medium text-slate-400">EQUIPOS DE TRABAJO / CRONÓMETROS POR PROCESO</label>
                                <button type="button" id="btnAgregarProceso" class="text-xs bg-slate-800 hover:bg-slate-700 text-amber-400 px-2 py-1 rounded-lg border border-slate-700">+ Agregar Proceso</button>
                            </div>
                            <div id="listaProcesosOrden" class="space-y-3"></div>
                            <p id="avisoSinProcesos" class="text-slate-500 text-xs italic mt-1">Sin procesos agregados — la mano de obra se registrará en $0.00. Agrega al menos uno (ej. Pesaje, Mezclado, Envasado), elige el equipo y corre el cronómetro.</p>
                        </div>
                        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 flex justify-between items-center">
                            <span class="text-xs text-slate-400">Mano de obra total (suma de todos los procesos)</span>
                            <span id="totalManoObraPreview" class="font-mono text-lg font-bold text-emerald-400">$0.00</span>
                        </div>
                        <input type="hidden" id="empleadosInvolucrados" value="0">
                        <input type="hidden" id="costoManoObra" value="0.00">
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

        // --- Catálogos y estado de los cronómetros por proceso ---
        const { data: empleadosCatalogo } = await supabaseClient
            .from('empleados')
            .select('id, nombre, costo_hora')
            .eq('activo', true)
            .order('nombre', { ascending: true });

        const { data: procesosCatalogo } = await supabaseClient
            .from('procesos_produccion')
            .select('nombre')
            .order('nombre', { ascending: true });

        const listaEmpleados = empleadosCatalogo || [];
        const listaProcesos = procesosCatalogo || [];
        const procesosState = new Map();
        let procesoContador = 0;

        function formatoHHMMSS(totalSegundos) {
            const s = Math.max(0, Math.floor(totalSegundos));
            const hh = String(Math.floor(s / 3600)).padStart(2, '0');
            const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
            const ss = String(s % 60).padStart(2, '0');
            return `${hh}:${mm}:${ss}`;
        }

        function obtenerSegundosActuales(uid) {
            const st = procesosState.get(uid);
            if (!st) return 0;
            return st.accumSeconds + (st.running ? (Date.now() - st.startTs) / 1000 : 0);
        }

        function actualizarTotalManoObra() {
            let total = 0;
            document.querySelectorAll('.proceso-item').forEach(div => {
                const uid = div.dataset.uid;
                const segundos = obtenerSegundosActuales(uid);
                const seleccionados = Array.from(div.querySelector('.selectEmpleadosProceso').selectedOptions);
                const sumaCostoHora = seleccionados.reduce((acc, opt) => acc + Number(opt.dataset.costoHora || 0), 0);
                total += (segundos / 3600) * sumaCostoHora;
            });
            document.getElementById('totalManoObraPreview').textContent = `$${total.toFixed(2)}`;
            document.getElementById('costoManoObra').value = total.toFixed(2);
        }

        function actualizarCostoProceso(uid) {
            const div = document.querySelector(`.proceso-item[data-uid="${uid}"]`);
            if (!div) return;
            const segundos = obtenerSegundosActuales(uid);
            const seleccionados = Array.from(div.querySelector('.selectEmpleadosProceso').selectedOptions);
            const sumaCostoHora = seleccionados.reduce((acc, opt) => acc + Number(opt.dataset.costoHora || 0), 0);
            const costo = (segundos / 3600) * sumaCostoHora;
            div.querySelector('.costoProcesoDisplay').textContent = `Costo: $${costo.toFixed(2)}`;
            actualizarTotalManoObra();
        }

        function actualizarCronometro(uid) {
            const div = document.querySelector(`.proceso-item[data-uid="${uid}"]`);
            if (!div) return;
            div.querySelector('.cronometroDisplay').textContent = formatoHHMMSS(obtenerSegundosActuales(uid));
            actualizarCostoProceso(uid);
        }

        function crearTarjetaProceso() {
            if (!listaEmpleados.length) {
                alert('⚠️ No hay empleados activos en el catálogo. Ve a "Empleados" y registra al menos uno antes de agregar un proceso.');
                return;
            }
            procesoContador++;
            const uid = `proc-${procesoContador}`;
            procesosState.set(uid, { running: false, accumSeconds: 0, startTs: null, intervalId: null });

            const opcionesProcesos = listaProcesos.map(p => `<option value="${p.nombre}">${p.nombre}</option>`).join('');
            const opcionesEmpleados = listaEmpleados.map(e => `<option value="${e.id}" data-costo-hora="${e.costo_hora}">${e.nombre} ($${Number(e.costo_hora).toFixed(2)}/hr)</option>`).join('');

            const div = document.createElement('div');
            div.className = 'proceso-item bg-slate-950 border border-slate-800 rounded-lg p-3 space-y-2';
            div.dataset.uid = uid;
            div.innerHTML = `
                <div class="flex gap-2 items-center">
                    <select class="selectProcesoNombre flex-1 bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
                        ${opcionesProcesos}
                        <option value="__otro__">+ Otro proceso...</option>
                    </select>
                    <input type="text" class="inputProcesoNuevoNombre hidden flex-1 bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100" placeholder="Nombre del proceso nuevo">
                    <button type="button" class="btnQuitarProceso text-rose-400 hover:text-rose-300 text-xs px-1" title="Quitar proceso">✕</button>
                </div>
                <div>
                    <label class="text-[10px] text-slate-500 block mb-1">EQUIPO DE TRABAJO (Ctrl/Cmd+clic para varios)</label>
                    <select multiple class="selectEmpleadosProceso w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 h-20">
                        ${opcionesEmpleados}
                    </select>
                </div>
                <div class="flex items-center justify-between flex-wrap gap-2">
                    <div class="flex items-center gap-2">
                        <span class="cronometroDisplay font-mono text-base text-amber-300">00:00:00</span>
                        <button type="button" class="btnIniciarPausar bg-emerald-700 hover:bg-emerald-600 text-white text-xs px-2 py-1 rounded-lg">▶ Iniciar</button>
                        <button type="button" class="btnReiniciar bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs px-2 py-1 rounded-lg">↺</button>
                    </div>
                    <span class="costoProcesoDisplay font-mono text-xs text-emerald-400">Costo: $0.00</span>
                </div>
            `;

            const selectProcesoNombre = div.querySelector('.selectProcesoNombre');
            const inputNuevoNombre = div.querySelector('.inputProcesoNuevoNombre');
            selectProcesoNombre.onchange = () => {
                inputNuevoNombre.classList.toggle('hidden', selectProcesoNombre.value !== '__otro__');
            };

            div.querySelector('.selectEmpleadosProceso').onchange = () => actualizarCostoProceso(uid);

            div.querySelector('.btnQuitarProceso').onclick = () => {
                const st = procesosState.get(uid);
                if (st?.intervalId) clearInterval(st.intervalId);
                procesosState.delete(uid);
                div.remove();
                actualizarTotalManoObra();
                if (!document.querySelectorAll('.proceso-item').length) {
                    document.getElementById('avisoSinProcesos').classList.remove('hidden');
                }
            };

            const btnIniciarPausar = div.querySelector('.btnIniciarPausar');
            btnIniciarPausar.onclick = () => {
                const st = procesosState.get(uid);
                if (!st) return;
                if (st.running) {
                    st.accumSeconds += (Date.now() - st.startTs) / 1000;
                    st.running = false;
                    st.startTs = null;
                    clearInterval(st.intervalId);
                    st.intervalId = null;
                    btnIniciarPausar.textContent = '▶ Reanudar';
                    btnIniciarPausar.classList.remove('bg-rose-700', 'hover:bg-rose-600');
                    btnIniciarPausar.classList.add('bg-emerald-700', 'hover:bg-emerald-600');
                } else {
                    st.running = true;
                    st.startTs = Date.now();
                    st.intervalId = setInterval(() => actualizarCronometro(uid), 1000);
                    btnIniciarPausar.textContent = '⏸ Pausar';
                    btnIniciarPausar.classList.remove('bg-emerald-700', 'hover:bg-emerald-600');
                    btnIniciarPausar.classList.add('bg-rose-700', 'hover:bg-rose-600');
                }
            };

            div.querySelector('.btnReiniciar').onclick = () => {
                const st = procesosState.get(uid);
                if (!st) return;
                if (st.intervalId) clearInterval(st.intervalId);
                Object.assign(st, { running: false, accumSeconds: 0, startTs: null, intervalId: null });
                btnIniciarPausar.textContent = '▶ Iniciar';
                btnIniciarPausar.classList.remove('bg-rose-700', 'hover:bg-rose-600');
                btnIniciarPausar.classList.add('bg-emerald-700', 'hover:bg-emerald-600');
                actualizarCronometro(uid);
            };

            document.getElementById('listaProcesosOrden').appendChild(div);
            document.getElementById('avisoSinProcesos').classList.add('hidden');
            actualizarCostoProceso(uid);
        }

        document.getElementById('btnAgregarProceso').onclick = crearTarjetaProceso;

        function detenerTodosLosTimers() {
            procesosState.forEach(st => {
                if (st.running) {
                    st.accumSeconds += (Date.now() - st.startTs) / 1000;
                    st.running = false;
                    if (st.intervalId) clearInterval(st.intervalId);
                    st.intervalId = null;
                    st.startTs = null;
                }
            });
        }

        function recolectarProcesos() {
            detenerTodosLosTimers();
            const procesos = [];
            document.querySelectorAll('.proceso-item').forEach(div => {
                const uid = div.dataset.uid;
                const segundos = obtenerSegundosActuales(uid);
                let nombre = div.querySelector('.selectProcesoNombre').value;
                if (nombre === '__otro__') {
                    nombre = div.querySelector('.inputProcesoNuevoNombre').value.trim() || 'Proceso sin nombre';
                }
                const empleadosSeleccionados = Array.from(div.querySelector('.selectEmpleadosProceso').selectedOptions).map(opt => ({
                    id: Number(opt.value),
                    costoHora: Number(opt.dataset.costoHora || 0)
                }));
                const sumaCostoHora = empleadosSeleccionados.reduce((acc, e) => acc + e.costoHora, 0);
                const costo = (segundos / 3600) * sumaCostoHora;
                procesos.push({ nombre, segundos, costo, empleados: empleadosSeleccionados });
            });
            return procesos;
        }

        function limpiarProcesosUI() {
            procesosState.forEach(st => { if (st.intervalId) clearInterval(st.intervalId); });
            procesosState.clear();
            document.getElementById('listaProcesosOrden').innerHTML = '';
            document.getElementById('avisoSinProcesos').classList.remove('hidden');
            document.getElementById('totalManoObraPreview').textContent = '$0.00';
            document.getElementById('costoManoObra').value = '0.00';
        }

        const formOrden = document.getElementById('formOrdenProduccion');
        if (formOrden) {
            formOrden.onsubmit = async (e) => {
                e.preventDefault();
                const procesos = recolectarProcesos();
                const costoTotalManoObra = procesos.reduce((acc, p) => acc + p.costo, 0);
                const empleadosUnicos = new Set();
                procesos.forEach(p => p.empleados.forEach(emp => empleadosUnicos.add(emp.id)));

                const datosOrden = {
                    productoId: document.getElementById('productoProducirId').value,
                    cantidadProducida: parseFloat(document.getElementById('cantidadProducida').value),
                    numeroLote: document.getElementById('numeroLoteResultante').value.trim(),
                    empleadosInvolucrados: empleadosUnicos.size,
                    costoTotalManoObra: costoTotalManoObra,
                    procesos: procesos
                };

                const btnSubmit = formOrden.querySelector('button[type="submit"]');
                btnSubmit.disabled = true;
                btnSubmit.textContent = "Procesando inventario (FIFO)...";

                try {
                    const resultado = await registrarOrdenDeProduccionCompleta(datosOrden);
                    if (resultado.success) {
                        alert("✅ " + resultado.mensaje);
                        formOrden.reset();
                        limpiarProcesosUI();
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
        const ordenProduccionIdCreada = ordenInsertada.id;

        // Se guardan los procesos/cronómetros (Pesaje, Mezclado, Envasado, etc.)
        // con su equipo de trabajo, para el desglose de mano de obra por etapa.
        const procesos = Array.isArray(datosOrden.procesos) ? datosOrden.procesos : [];
        for (const proceso of procesos) {
            const { data: procesoInsertado, error: errProceso } = await supabaseClient
                .from('orden_produccion_procesos')
                .insert([{
                    orden_produccion_id: ordenProduccionIdCreada,
                    proceso_nombre: proceso.nombre,
                    segundos_transcurridos: proceso.segundos,
                    costo_calculado: proceso.costo
                }])
                .select('id')
                .single();

            if (errProceso) {
                console.error(`No se pudo guardar el proceso "${proceso.nombre}":`, errProceso.message);
                continue;
            }

            if (proceso.empleados && proceso.empleados.length > 0) {
                const filasEmpleados = proceso.empleados.map(emp => ({
                    orden_produccion_proceso_id: procesoInsertado.id,
                    empleado_id: emp.id,
                    costo_hora_snapshot: emp.costoHora
                }));
                await supabaseClient.from('orden_produccion_proceso_empleados').insert(filasEmpleados);
            }

            // Si el usuario escribió un nombre de proceso nuevo, se agrega al
            // catálogo para que aparezca sugerido la próxima vez (best-effort).
            await supabaseClient.from('procesos_produccion').upsert([{ nombre: proceso.nombre }], { onConflict: 'nombre', ignoreDuplicates: true });
        }

        const { error: errRpcEntrada } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
            p_producto_id: Number(productoId),
            p_cantidad: Number(cantidadProducida),
            p_tipo_movimiento: 'entrada_produccion',
            p_documento_id: Number(documentoIdCreado),
            p_costo_unitario: Number(costoUnitarioFinal),
            p_numero_lote: String(numeroLote)
        });

        if (errRpcEntrada) throw new Error(`Error al registrar entrada de producto terminado: ${errRpcEntrada.message}`);

        // Se registra la partida del producto terminado en documento_detalles
        // para que aparezca en el visor de Documentos (antes solo quedaba en
        // movimientos_inventario / lotes_inventario, invisible ahí).
        const { data: loteCreado } = await supabaseClient
            .from('lotes_inventario')
            .select('id')
            .eq('producto_id', productoId)
            .eq('numero_lote', numeroLote)
            .eq('documento_id', documentoIdCreado)
            .maybeSingle();

        await supabaseClient.from('documento_detalles').insert([{
            documento_id: documentoIdCreado,
            producto_id: productoId,
            lote_id: loteCreado?.id || null,
            cantidad: cantidadProducida,
            costo_unitario: costoUnitarioFinal,
            subtotal: costoUnitarioFinal * cantidadProducida
        }]);

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
            .select(`id, producto_id, numero_lote, cantidad_producida, empleados_involucrados, costo_unitario_final, costo_total_materiales, costo_total_mano_obra, created_at, productos ( id, nombre, sku, descripcion, unidades_medida ( nombre ) )`)
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
            btnImprimirOrden.onclick = () => {
                const idActual = Number(selectOrdenId?.value);
                const ordenActual = ordenes.find(o => o.id === idActual);
                if (!ordenActual) return;
                const titulo = `Orden de Producción #${ordenActual.id} — Lote ${ordenActual.numero_lote || 'S/L'}`;
                imprimirConPlantilla('entrada_produccion', titulo, 'detalleResumenOrden');
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
                            ${nombreInsumo} <span class="text-amber-400 font-mono text-[11px] campo-lote">${loteOrigen}</span>
                        </td>
                        <td class="py-2.5 px-3 font-mono text-amber-300">${cantidadDescontada.toFixed(4)}</td>
                        <td class="py-2.5 px-3 text-slate-400">${unidadMedidaTexto}</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300 campo-costo">$${costoUnitario.toFixed(2)}</td>
                        <td class="py-2.5 px-3 font-mono text-emerald-400 text-right font-semibold campo-costo">$${subtotal.toFixed(2)}</td>
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

        const { data: procesosOrden } = await supabaseClient
            .from('orden_produccion_procesos')
            .select(`
                id, proceso_nombre, segundos_transcurridos, costo_calculado,
                orden_produccion_proceso_empleados ( costo_hora_snapshot, empleados ( nombre ) )
            `)
            .eq('orden_produccion_id', orden.id)
            .order('created_at', { ascending: true });

        const formatoHHMMSS = (totalSegundos) => {
            const s = Math.max(0, Math.floor(totalSegundos));
            const hh = String(Math.floor(s / 3600)).padStart(2, '0');
            const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
            const ss = String(s % 60).padStart(2, '0');
            return `${hh}:${mm}:${ss}`;
        };

        let htmlProcesos = '';
        if (procesosOrden && procesosOrden.length > 0) {
            htmlProcesos = `
                <div class="mb-4 campo-costo">
                    <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">⏱️ Equipos de Trabajo por Proceso</h4>
                    <div class="space-y-2">
                        ${procesosOrden.map(p => {
                            const equipo = (p.orden_produccion_proceso_empleados || []).map(e => e.empleados?.nombre).filter(Boolean).join(', ') || 'Sin equipo asignado';
                            return `
                            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3 flex flex-wrap justify-between items-center gap-2">
                                <div>
                                    <span class="text-sm font-semibold text-slate-200">${p.proceso_nombre}</span>
                                    <span class="text-[11px] text-slate-500 block">${equipo}</span>
                                </div>
                                <div class="text-right">
                                    <span class="font-mono text-amber-300 text-sm block">${formatoHHMMSS(p.segundos_transcurridos)}</span>
                                    <span class="font-mono text-emerald-400 text-xs">$${Number(p.costo_calculado).toFixed(2)}</span>
                                </div>
                            </div>`;
                        }).join('')}
                    </div>
                </div>
            `;
        }

        const mobTotal = Number(orden.costo_total_mano_obra || 0);
        const unitFinal = Number(orden.costo_unitario_final || 0);
        const materialTotalFinal = orden.costo_total_materiales ? Number(orden.costo_total_materiales) : importeTotalFormula;

        const unidadProducto = orden.productos?.unidades_medida?.nombre || '';
        const empleados = orden.empleados_involucrados != null ? orden.empleados_involucrados : 'N/D';

        contenedorDetalle.innerHTML = `
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4 pb-4 border-b border-slate-800">
                <div class="campo-lote"><span class="text-xs text-slate-400 block">ORDEN / LOTE</span><span class="font-mono font-bold text-amber-400">ID #${orden.id} | ${orden.numero_lote}</span></div>
                <div><span class="text-xs text-slate-400 block">PRODUCTO</span><span class="font-medium text-slate-100">${orden.productos?.nombre}</span>${orden.productos?.sku ? `<span class="text-[10px] text-slate-500 block font-mono">SKU: ${orden.productos.sku}</span>` : ''}</div>
                <div><span class="text-xs text-slate-400 block">CANTIDAD</span><span class="font-mono text-slate-200">${cantidadProducidaLote} ${unidadProducto}</span></div>
                <div><span class="text-xs text-slate-400 block">EMPLEADOS</span><span class="font-mono text-slate-200">${empleados}</span></div>
                <div><span class="text-xs text-slate-400 block">FECHA</span><span class="text-slate-300">${new Date(orden.created_at).toLocaleString()}</span></div>
            </div>
            ${orden.productos?.descripcion ? `<p class="text-xs text-slate-400 mb-4 -mt-2">${orden.productos.descripcion}</p>` : ''}
            ${htmlProcesos}
            <table class="w-full text-left text-sm text-slate-300 bg-slate-900 rounded-lg overflow-hidden mb-4">
                <thead>
                    <tr class="border-b border-slate-800 text-xs text-slate-400 bg-slate-950">
                        <th class="py-2.5 px-3">Materia Prima / Componente</th>
                        <th class="py-2.5 px-3">Cantidad</th>
                        <th class="py-2.5 px-3">Unidad</th>
                        <th class="py-2.5 px-3 campo-costo">Costo</th>
                        <th class="py-2.5 px-3 text-right campo-costo">Subtotal</th>
                    </tr>
                </thead>
                <tbody>${htmlComponentes}</tbody>
            </table>

            <div class="bg-slate-950 border border-slate-800 p-4 rounded-lg mb-4 flex justify-between items-center campo-costo">
                <span class="text-sm font-semibold text-amber-400">📊 Importe Total de todos los Componentes de la Fórmula:</span>
                <span class="text-lg font-mono font-bold text-emerald-400">$${importeTotalFormula.toFixed(2)}</span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-4 gap-3 campo-costo">
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Materiales</span><span class="font-mono text-base text-slate-200 font-bold">$${materialTotalFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Mano de Obra</span><span class="font-mono text-base text-slate-200 font-bold">$${mobTotal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Costo Unitario</span><span class="font-mono text-base text-emerald-400 font-bold">$${unitFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Total Lote</span><span class="font-mono text-base text-amber-300 font-bold">$${(cantidadProducidaLote * unitFinal).toFixed(2)}</span></div>
            </div>`;
    } catch (err) { 
        console.error("Error al renderizar el detalle de la orden:", err); 
    }
}