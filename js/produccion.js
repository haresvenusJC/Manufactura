import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';
import { imprimirConPlantilla } from './impresion.js';

// Formatea cantidades evitando colas de decimales largas (10.0000001 -> "10").
function formatoCantidad(n) {
    return Number(Number(n || 0).toFixed(3)).toString();
}

/**
 * Para un producto y una cantidad a producir, calcula cuánto se requiere de
 * cada insumo del BOM (con conversión ml/g -> unidad base) y cuánto hay
 * disponible realmente (suma de stock por lote, que es lo que evalúa el RPC FIFO).
 * Lo usan tanto el panel de existencias del formulario como la validación final.
 *
 * @returns {Promise<{ error: string|null, filas: Array<{
 *   componenteId:number, nombre:string, unidad:string,
 *   costoUnitarioCatalogo:number, requerido:number, disponible:number, suficiente:boolean
 * }> }>}
 */
export async function calcularRequerimientosProduccion(productoId, cantidadProducida) {
    const pid = Number(productoId);
    const cantidad = Number(cantidadProducida) || 0;

    if (!pid || cantidad <= 0) {
        return { error: 'Selecciona un producto y una cantidad válida.', filas: [] };
    }

    const { data: componentes, error: errComp } = await supabaseClient
        .from('bom')
        .select('componente_id, cantidad_requerida, unidad_medida')
        .eq('producto_id', pid);

    if (errComp) return { error: errComp.message, filas: [] };
    if (!componentes || componentes.length === 0) {
        return { error: 'El producto seleccionado no tiene una receta o BOM registrada.', filas: [] };
    }

    const idsComponentes = componentes.map(c => c.componente_id);

    const { data: infoInsumos, error: errInsumos } = await supabaseClient
        .from('productos')
        .select('id, nombre, costo_unitario, unidades_medida ( nombre )')
        .in('id', idsComponentes);

    if (errInsumos) return { error: errInsumos.message, filas: [] };
    const mapaInsumos = new Map((infoInsumos || []).map(i => [i.id, i]));

    const { data: lotes, error: errLotes } = await supabaseClient
        .from('lotes_inventario')
        .select('producto_id, stock_actual')
        .in('producto_id', idsComponentes);

    if (errLotes) return { error: errLotes.message, filas: [] };

    const stockPorComponente = new Map();
    (lotes || []).forEach(l => {
        const k = Number(l.producto_id);
        stockPorComponente.set(k, (stockPorComponente.get(k) || 0) + Number(l.stock_actual || 0));
    });

    // Se agregan los requerimientos por componente (un insumo puede repetirse en el BOM).
    const acumulado = new Map();
    componentes.forEach(comp => {
        const componenteId = Number(comp.componente_id);
        const datosIns = mapaInsumos.get(componenteId) || {};

        const cantidadReqUnit = Number(comp.cantidad_requerida || 0);
        let requerido = cantidadReqUnit * cantidad;

        const unidadBom = String(comp.unidad_medida || '').toLowerCase().trim();
        const unidadCat = String(datosIns.unidades_medida?.nombre || '').toLowerCase().trim();
        if (unidadBom.includes('ml') || unidadBom.includes('g') || unidadCat.includes('ml') || unidadCat.includes('g') || cantidadReqUnit > 10) {
            requerido /= 1000;
        }

        const prev = acumulado.get(componenteId);
        if (prev) {
            prev.requerido += requerido;
        } else {
            acumulado.set(componenteId, {
                componenteId,
                nombre: datosIns.nombre || `Insumo ID ${componenteId}`,
                unidad: datosIns.unidades_medida?.nombre || '',
                costoUnitarioCatalogo: Number(datosIns.costo_unitario || 0),
                requerido
            });
        }
    });

    const filas = Array.from(acumulado.values()).map(f => {
        const disponible = stockPorComponente.get(f.componenteId) || 0;
        return { ...f, disponible, suficiente: disponible + 1e-6 >= f.requerido };
    });

    return { error: null, filas };
}

// Cronómetros del panel "Órdenes en Proceso" (viven mientras la vista está montada).
let tickerEnProceso = null;
let refetchEnProceso = null;

function formatoHHMMSS(totalSegundos) {
    const s = Math.max(0, Math.floor(totalSegundos));
    const hh = String(Math.floor(s / 3600)).padStart(2, '0');
    const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
    const ss = String(s % 60).padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
}

// Línea de detalle para un insumo que no alcanza (reusada al generar y al cerrar).
function fmtFaltante(f) {
    const u = f.unidad ? ` ${f.unidad}` : '';
    return `• ${f.nombre}: requerido ${formatoCantidad(f.requerido)}${u}, disponible ${formatoCantidad(f.disponible)}${u} (faltan ${formatoCantidad(f.requerido - f.disponible)}${u})`;
}

function segundosDeIntervalo(inicioISO, finISO) {
    const ini = new Date(inicioISO).getTime();
    const fin = finISO ? new Date(finISO).getTime() : Date.now();
    return Math.max(0, (fin - ini) / 1000);
}

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');

    // Al re-montar la vista, cortar los timers anteriores.
    clearInterval(tickerEnProceso); tickerEnProceso = null;
    clearInterval(refetchEnProceso); refetchEnProceso = null;

    try {
        if (!supabaseClient || !contenedorProd) return;

        contenedorProd.innerHTML = `
            <div class="space-y-6 max-w-4xl mx-auto">
                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <h3 class="text-lg font-semibold mb-1 text-amber-400 flex items-center gap-2">🧾 Generar Orden de Producción</h3>
                    <p class="text-xs text-slate-400 mb-4">Valida existencias y abre la orden en estado <b>"en proceso"</b>. Los tiempos de trabajo se registran desde la <b>Orden de Trabajo</b> en el celular; el inventario se descuenta (FIFO) al <b>cerrar</b> la orden.</p>
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
                        <div id="panelExistenciasBOM" class="hidden bg-slate-950 border border-slate-800 rounded-lg p-3">
                            <div class="flex justify-between items-center mb-2">
                                <span class="text-xs font-medium text-slate-400">EXISTENCIAS PARA ESTA PRODUCCIÓN (según receta / BOM)</span>
                                <span id="resumenExistenciasBOM" class="text-[11px] font-mono"></span>
                            </div>
                            <div id="tablaExistenciasBOM" class="space-y-1"></div>
                        </div>
                        <div>
                            <div class="flex justify-between items-center mb-2">
                                <label class="block text-xs font-medium text-slate-400">PROCESOS Y EQUIPO DE TRABAJO ASIGNADO</label>
                                <button type="button" id="btnAgregarProceso" class="text-xs bg-slate-800 hover:bg-slate-700 text-amber-400 px-2 py-1 rounded-lg border border-slate-700">+ Agregar Proceso</button>
                            </div>
                            <div id="listaProcesosOrden" class="space-y-3"></div>
                            <p id="avisoSinProcesos" class="text-slate-500 text-xs italic mt-1">Agrega al menos un proceso (ej. Pesaje, Mezclado, Envasado) y asígnale su equipo. Solo el equipo asignado podrá registrar tiempo en el celular.</p>
                        </div>
                        <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-semibold py-2 px-4 rounded-lg transition-all text-sm shadow-lg">
                            ✅ Generar Orden (en proceso)
                        </button>
                    </form>
                </div>

                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">⏱️ Órdenes en Proceso</h3>
                        <button type="button" id="btnRefrescarEnProceso" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700" title="Refrescar">↻</button>
                    </div>
                    <div id="contenedorOrdenesEnProceso"><p class="text-slate-500 text-xs italic">Cargando...</p></div>
                </div>

                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-4">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">📊 Historial de Órdenes Cerradas</h3>
                        <div class="flex items-center gap-2 w-full md:w-auto">
                            <select id="selectOrdenId" class="w-full md:w-72 bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-amber-300 font-mono">
                                <option value="">Seleccione orden por ID...</option>
                            </select>
                            <button id="btnImprimirOrden" class="bg-slate-800 hover:bg-slate-700 text-amber-400 p-2 rounded-lg border border-slate-700 transition-all text-sm flex items-center gap-1" title="Ventana Imprimible" disabled>🖨️</button>
                        </div>
                    </div>
                    <div id="detalleResumenOrden" class="bg-slate-950 border border-slate-800/60 p-4 rounded-lg text-sm text-slate-300 mb-6">
                        <p class="text-slate-500 italic text-center">Seleccione una orden cerrada para ver su desglose ejecutivo.</p>
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

        // --- Panel de existencias según BOM: se recalcula al cambiar producto o cantidad ---
        const inputCantidadProd = document.getElementById('cantidadProducida');
        const panelExistencias = document.getElementById('panelExistenciasBOM');
        const tablaExistencias = document.getElementById('tablaExistenciasBOM');
        const resumenExistencias = document.getElementById('resumenExistenciasBOM');
        let tokenPanelExistencias = 0;

        async function actualizarPanelExistencias() {
            const idProd = selectProd.value;
            const cant = parseFloat(inputCantidadProd.value);
            const miToken = ++tokenPanelExistencias;

            if (!idProd || !cant || cant <= 0) {
                panelExistencias.classList.add('hidden');
                return;
            }

            panelExistencias.classList.remove('hidden');
            tablaExistencias.innerHTML = '<p class="text-slate-500 text-xs italic">Calculando requerimientos...</p>';
            resumenExistencias.textContent = '';

            const { error, filas } = await calcularRequerimientosProduccion(idProd, cant);
            if (miToken !== tokenPanelExistencias) return; // llegó una respuesta obsoleta

            if (error) {
                tablaExistencias.innerHTML = `<p class="text-amber-400 text-xs">${error}</p>`;
                resumenExistencias.textContent = '';
                return;
            }

            const faltan = filas.filter(f => !f.suficiente);
            resumenExistencias.textContent = faltan.length ? `⛔ Faltan ${faltan.length} insumo(s)` : '✅ Existencias suficientes';
            resumenExistencias.className = `text-[11px] font-mono ${faltan.length ? 'text-rose-400' : 'text-emerald-400'}`;

            tablaExistencias.innerHTML = filas.map(f => {
                const u = f.unidad ? ` ${f.unidad}` : '';
                const color = f.suficiente ? 'text-emerald-400' : 'text-rose-400';
                const icono = f.suficiente ? '✅' : '⛔';
                const falta = f.suficiente ? '' : ` · faltan ${formatoCantidad(f.requerido - f.disponible)}${u}`;
                return `
                    <div class="flex justify-between items-center gap-2 text-xs border-b border-slate-900 last:border-0 py-1">
                        <span class="text-slate-200">${icono} ${f.nombre}</span>
                        <span class="font-mono ${color}">req ${formatoCantidad(f.requerido)}${u} · disp ${formatoCantidad(f.disponible)}${u}${falta}</span>
                    </div>`;
            }).join('');
        }

        selectProd.addEventListener('change', actualizarPanelExistencias);
        inputCantidadProd.addEventListener('input', actualizarPanelExistencias);

        // --- Catálogos para las tarjetas de proceso ---
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
        let procesoContador = 0;

        function crearTarjetaProceso() {
            if (!listaEmpleados.length) {
                alert('⚠️ No hay empleados activos en el catálogo. Ve a "Empleados" y registra al menos uno antes de agregar un proceso.');
                return;
            }
            procesoContador++;
            const uid = `proc-${procesoContador}`;

            const opcionesProcesos = listaProcesos.map(p => `<option value="${p.nombre}">${p.nombre}</option>`).join('');
            const casillasEmpleados = listaEmpleados.map(e => `
                <label class="flex items-center gap-2 text-xs text-slate-200 px-1.5 py-1 rounded hover:bg-slate-800 cursor-pointer">
                    <input type="checkbox" class="chkEmpleado accent-amber-500 w-3.5 h-3.5" value="${e.id}" data-costo-hora="${e.costo_hora}" data-nombre="${(e.nombre || '').replace(/"/g, '&quot;')}">
                    <span>${e.nombre} <span class="text-slate-500">($${Number(e.costo_hora).toFixed(2)}/hr)</span></span>
                </label>`).join('');

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
                    <label class="text-[10px] text-slate-500 block mb-1">EQUIPO DE TRABAJO (marca a quienes participan)</label>
                    <div class="equipoEmpleados max-h-28 overflow-y-auto bg-slate-900 border border-slate-800 rounded-lg p-1 space-y-0.5">
                        ${casillasEmpleados}
                    </div>
                    <p class="text-[10px] text-slate-500 mt-1"><span class="equipoCount text-amber-400 font-semibold">0</span> empleado(s) asignado(s)</p>
                </div>
            `;

            const selectProcesoNombre = div.querySelector('.selectProcesoNombre');
            const inputNuevoNombre = div.querySelector('.inputProcesoNuevoNombre');
            selectProcesoNombre.onchange = () => {
                inputNuevoNombre.classList.toggle('hidden', selectProcesoNombre.value !== '__otro__');
            };

            const contadorEquipo = div.querySelector('.equipoCount');
            div.querySelectorAll('.chkEmpleado').forEach(chk => {
                chk.addEventListener('change', () => {
                    contadorEquipo.textContent = div.querySelectorAll('.chkEmpleado:checked').length;
                });
            });

            div.querySelector('.btnQuitarProceso').onclick = () => {
                div.remove();
                if (!document.querySelectorAll('.proceso-item').length) {
                    document.getElementById('avisoSinProcesos').classList.remove('hidden');
                }
            };

            document.getElementById('listaProcesosOrden').appendChild(div);
            document.getElementById('avisoSinProcesos').classList.add('hidden');
        }

        document.getElementById('btnAgregarProceso').onclick = crearTarjetaProceso;

        function recolectarProcesosDefinidos() {
            const procesos = [];
            document.querySelectorAll('#listaProcesosOrden .proceso-item').forEach(div => {
                let nombre = div.querySelector('.selectProcesoNombre').value;
                if (nombre === '__otro__') {
                    nombre = div.querySelector('.inputProcesoNuevoNombre').value.trim() || 'Proceso sin nombre';
                }
                const empleados = Array.from(div.querySelectorAll('.chkEmpleado:checked')).map(chk => ({
                    id: Number(chk.value),
                    costoHora: Number(chk.dataset.costoHora || 0)
                }));
                procesos.push({ nombre, empleados });
            });
            return procesos;
        }

        const formOrden = document.getElementById('formOrdenProduccion');
        if (formOrden) {
            formOrden.onsubmit = async (e) => {
                e.preventDefault();
                const datos = {
                    productoId: document.getElementById('productoProducirId').value,
                    cantidadProducida: parseFloat(document.getElementById('cantidadProducida').value),
                    numeroLote: document.getElementById('numeroLoteResultante').value.trim(),
                    procesos: recolectarProcesosDefinidos()
                };

                const btnSubmit = formOrden.querySelector('button[type="submit"]');
                btnSubmit.disabled = true;
                btnSubmit.textContent = "Generando...";

                try {
                    const resultado = await generarOrdenDeProduccion(datos);
                    if (resultado.success) {
                        alert(`✅ Orden ${resultado.folio} generada y en proceso.\nLos operarios ya pueden registrar tiempos desde la Orden de Trabajo en el celular.`);
                        formOrden.reset();
                        document.getElementById('listaProcesosOrden').innerHTML = '';
                        document.getElementById('avisoSinProcesos').classList.remove('hidden');
                        panelExistencias.classList.add('hidden');
                        await cargarOrdenesEnProceso();
                    } else {
                        alert("❌ Error: " + resultado.error);
                    }
                } catch (ex) {
                    alert("❌ Error crítico: " + ex.message);
                } finally {
                    btnSubmit.disabled = false;
                    btnSubmit.textContent = "✅ Generar Orden (en proceso)";
                }
            };
        }

        document.getElementById('btnRefrescarEnProceso').onclick = cargarOrdenesEnProceso;

        await cargarOrdenesEnProceso();
        await cargarHistorialProduccion();

        tickerEnProceso = setInterval(tickEnProceso, 1000);
        refetchEnProceso = setInterval(cargarOrdenesEnProceso, 20000);
    } catch (err) {
        console.error("Error al inicializar el módulo de producción:", err);
    }
}

/**
 * Etapa 1: crea la orden en estado 'en_proceso' con sus procesos y equipos
 * asignados. NO mueve inventario ni calcula costos: eso ocurre al cerrarla.
 */
export async function generarOrdenDeProduccion(datos) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");

        const productoId = Number(datos.productoId);
        const cantidadProducida = Number(datos.cantidadProducida) || 0;
        const numeroLote = String(datos.numeroLote || '').trim();
        const procesos = Array.isArray(datos.procesos) ? datos.procesos : [];

        if (!productoId || cantidadProducida <= 0 || !numeroLote) {
            throw new Error("Faltan datos obligatorios o la cantidad a producir es inválida.");
        }
        if (!procesos.length) {
            throw new Error("Agrega al menos un proceso con su equipo de trabajo.");
        }
        if (procesos.some(p => !p.empleados || !p.empleados.length)) {
            throw new Error("Cada proceso debe tener al menos un empleado asignado (si no, nadie podrá registrar tiempo en el celular).");
        }

        // Validación de existencias (mismo cálculo que el panel del formulario).
        const { error: errReq, filas } = await calcularRequerimientosProduccion(productoId, cantidadProducida);
        if (errReq) throw new Error(errReq);
        const faltantes = filas.filter(f => !f.suficiente);
        if (faltantes.length > 0) {
            throw new Error(`Existencias insuficientes. No se generó la orden:\n${faltantes.map(fmtFaltante).join('\n')}`);
        }

        const { data: ordenNueva, error: errOrden } = await supabaseClient
            .from('ordenes_produccion')
            .insert([{
                producto_id: productoId,
                cantidad_producida: cantidadProducida,
                numero_lote: numeroLote,
                estado: 'en_proceso',
                abierta_at: new Date().toISOString()
            }])
            .select('id')
            .single();

        if (errOrden) throw errOrden;
        const ordenId = ordenNueva.id;
        const folio = 'OP-' + String(ordenId).padStart(6, '0');
        await supabaseClient.from('ordenes_produccion').update({ folio }).eq('id', ordenId);

        for (const proc of procesos) {
            const { data: procIns, error: errProc } = await supabaseClient
                .from('orden_produccion_procesos')
                .insert([{ orden_produccion_id: ordenId, proceso_nombre: proc.nombre }])
                .select('id')
                .single();

            if (errProc) throw new Error(`No se pudo crear el proceso "${proc.nombre}": ${errProc.message}`);

            const filasEmp = proc.empleados.map(emp => ({
                orden_produccion_proceso_id: procIns.id,
                empleado_id: emp.id,
                costo_hora_snapshot: emp.costoHora
            }));
            const { error: errEmp } = await supabaseClient.from('orden_produccion_proceso_empleados').insert(filasEmp);
            if (errEmp) throw new Error(`No se pudo asignar el equipo del proceso "${proc.nombre}": ${errEmp.message}`);

            await supabaseClient.from('procesos_produccion').upsert([{ nombre: proc.nombre }], { onConflict: 'nombre', ignoreDuplicates: true });
        }

        return { success: true, ordenId, folio };
    } catch (error) {
        console.error("Error al generar la orden:", error.message);
        return { success: false, error: error.message };
    }
}

/**
 * Etapa 3: cierra una orden 'en_proceso'. Cierra cronómetros abiertos, calcula
 * la mano de obra a partir de registros_tiempo, re-valida existencias, descuenta
 * insumos (FIFO), da entrada al producto terminado y marca la orden como cerrada.
 */
export async function cerrarOrdenDeProduccion(ordenId) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");
        ordenId = Number(ordenId);

        const { data: orden, error: errO } = await supabaseClient
            .from('ordenes_produccion')
            .select('id, producto_id, cantidad_producida, numero_lote, estado')
            .eq('id', ordenId)
            .single();

        if (errO) throw errO;
        if (!orden) throw new Error("Orden no encontrada.");
        if (orden.estado !== 'en_proceso') throw new Error(`La orden ya está "${orden.estado}".`);

        const productoId = Number(orden.producto_id);
        const cantidadProducida = Number(orden.cantidad_producida) || 0;
        const numeroLote = String(orden.numero_lote || '').trim();
        if (cantidadProducida <= 0 || !numeroLote) throw new Error("La orden no tiene cantidad o lote válidos.");

        const { data: procesos, error: errP } = await supabaseClient
            .from('orden_produccion_procesos')
            .select('id, proceso_nombre, orden_produccion_proceso_empleados ( empleado_id, costo_hora_snapshot )')
            .eq('orden_produccion_id', ordenId);

        if (errP) throw errP;
        const procIds = (procesos || []).map(p => p.id);

        // Cierra cualquier cronómetro que quedó abierto.
        if (procIds.length) {
            const { error: errCierre } = await supabaseClient.from('registros_tiempo')
                .update({ fin: new Date().toISOString() })
                .is('fin', null)
                .in('orden_produccion_proceso_id', procIds);
            if (errCierre) throw new Error(`No se pudieron cerrar los cronómetros abiertos: ${errCierre.message}`);
        }

        let registros = [];
        if (procIds.length) {
            const { data: regs, error: errR } = await supabaseClient.from('registros_tiempo')
                .select('orden_produccion_proceso_id, empleado_id, inicio, fin')
                .in('orden_produccion_proceso_id', procIds);
            if (errR) throw errR;
            registros = regs || [];
        }

        // Mano de obra por proceso = suma de (segundos del empleado / 3600) * costo_hora_snapshot.
        let costoTotalManoObra = 0;
        const empleadosSet = new Set();
        const actualizacionesProceso = [];
        for (const p of procesos) {
            const snap = new Map((p.orden_produccion_proceso_empleados || []).map(e => [Number(e.empleado_id), Number(e.costo_hora_snapshot || 0)]));
            let segProc = 0;
            let costoProc = 0;
            registros.filter(r => r.orden_produccion_proceso_id === p.id).forEach(r => {
                const seg = segundosDeIntervalo(r.inicio, r.fin);
                segProc += seg;
                empleadosSet.add(Number(r.empleado_id));
                costoProc += (seg / 3600) * (snap.get(Number(r.empleado_id)) || 0);
            });
            costoTotalManoObra += costoProc;
            actualizacionesProceso.push({ id: p.id, segundos: Math.round(segProc), costo: costoProc });
        }

        // Re-validación de existencias: si falta algo, no se escribe nada más.
        const { error: errReq, filas } = await calcularRequerimientosProduccion(productoId, cantidadProducida);
        if (errReq) throw new Error(errReq);
        const faltantes = filas.filter(f => !f.suficiente);
        if (faltantes.length > 0) {
            throw new Error(`Existencias insuficientes. La orden sigue en proceso:\n${faltantes.map(fmtFaltante).join('\n')}`);
        }

        // Dos documentos para que el movimiento se lea claro en Documentos/Kardex:
        // uno de SALIDA (la materia prima que se consume) y uno de ENTRADA (el
        // producto terminado que resulta). Contablemente siguen siendo una sola
        // transformación de inventario -una sola póliza-, así que al póliza que
        // genera contabilizar_produccion() se le liga también el documento de
        // salida (ver más abajo) en vez de duplicar el asiento.
        const folioBase = `PROD-${Date.now().toString().slice(-6)}`;
        const { data: docSalida, error: errDocSalida } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: 'salida_produccion',
                folio: `${folioBase}-MP`,
                fecha_emision: new Date().toISOString(),
                descripcion: `Consumo de materia prima — orden de producción, lote ${numeroLote}`,
                estado: 'completado'
            }])
            .select('id')
            .single();
        if (errDocSalida) throw errDocSalida;
        const documentoSalidaId = docSalida.id;

        const { data: docInsertado, error: errDoc } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: 'entrada_produccion',
                folio: folioBase,
                fecha_emision: new Date().toISOString(),
                descripcion: `Cierre de orden de producción — lote ${numeroLote} (consumo de materia prima: documento ${folioBase}-MP)`,
                estado: 'completado'
            }])
            .select('id')
            .single();

        if (errDoc) throw errDoc;
        const documentoId = docInsertado.id;

        let costoTotalMateriales = 0;
        for (const f of filas) {
            const { data: lotesConsumidos, error: errFifo } = await supabaseClient.rpc('registrar_salida_fifo', {
                p_producto_id: f.componenteId,
                p_cantidad_salida: Number(f.requerido),
                p_tipo_movimiento: 'salida_produccion',
                p_documento_id: documentoSalidaId,
                p_costo_unitario_fijo: null
            });

            if (errFifo) throw new Error(`Error al descontar ${f.nombre} (FIFO): ${errFifo.message}`);

            if (Array.isArray(lotesConsumidos) && lotesConsumidos.length > 0) {
                lotesConsumidos.forEach(l => {
                    costoTotalMateriales += Number(l.cantidad || 0) * Number(l.costo_unitario ?? f.costoUnitarioCatalogo);
                });
            } else {
                costoTotalMateriales += (f.requerido * f.costoUnitarioCatalogo);
            }
        }

        const costoUnitarioFinal = cantidadProducida > 0 ? (costoTotalMateriales + costoTotalManoObra) / cantidadProducida : 0;

        const { error: errEnt } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
            p_producto_id: productoId,
            p_cantidad: cantidadProducida,
            p_tipo_movimiento: 'entrada_produccion',
            p_documento_id: documentoId,
            p_costo_unitario: costoUnitarioFinal,
            p_numero_lote: numeroLote
        });

        if (errEnt) throw new Error(`Error al registrar entrada de producto terminado: ${errEnt.message}`);

        const { data: loteCreado } = await supabaseClient
            .from('lotes_inventario')
            .select('id')
            .eq('producto_id', productoId)
            .eq('numero_lote', numeroLote)
            .eq('documento_id', documentoId)
            .maybeSingle();

        await supabaseClient.from('documento_detalles').insert([{
            documento_id: documentoId,
            producto_id: productoId,
            lote_id: loteCreado?.id || null,
            cantidad: cantidadProducida,
            costo_unitario: costoUnitarioFinal,
            subtotal: costoUnitarioFinal * cantidadProducida
        }]);

        await supabaseClient.from('productos').update({ costo_unitario: costoUnitarioFinal }).eq('id', productoId);

        for (const a of actualizacionesProceso) {
            await supabaseClient.from('orden_produccion_procesos')
                .update({ segundos_transcurridos: a.segundos, costo_calculado: a.costo })
                .eq('id', a.id);
        }

        const { error: errUpd } = await supabaseClient.from('ordenes_produccion').update({
            estado: 'cerrada',
            cerrada_at: new Date().toISOString(),
            costo_unitario_final: costoUnitarioFinal,
            costo_total_materiales: costoTotalMateriales,
            costo_total_mano_obra: costoTotalManoObra,
            empleados_involucrados: empleadosSet.size
        }).eq('id', ordenId);

        if (errUpd) throw errUpd;

        // Contabilizar el cierre (Cargo 115.04 PT / Abono 115.01 MP + 601.01 mano de obra).
        // No bloquea el cierre si el modulo contable no esta instalado o falla.
        let msgContab = '';
        try {
            const { data: cc, error: errCC } = await supabaseClient.rpc('contabilizar_produccion', {
                p_documento_id: documentoId,
                p_datos: { costo_materiales: costoTotalMateriales, costo_mano_obra: costoTotalManoObra }
            });
            if (errCC) throw errCC;
            msgContab = ` Póliza de producción #${cc.poliza_id} generada.`;
            // La póliza queda ligada al documento de entrada (como ya hacía
            // contabilizar_produccion); se replica el mismo poliza_id en el
            // documento de salida para que ambos lados del movimiento se vean
            // contabilizados en Documentos, sin generar un segundo asiento.
            if (cc?.poliza_id) {
                await supabaseClient.from('documentos').update({ poliza_id: cc.poliza_id }).eq('id', documentoSalidaId);
            }
        } catch (e) {
            const m = e?.message || String(e);
            if (!/does not exist|could not find|schema cache/i.test(m)) {
                msgContab = ` (Cierre OK, pero no se contabilizó: ${m})`;
            }
        }

        return { success: true, mensaje: `Orden cerrada. Costo unitario: $${costoUnitarioFinal.toFixed(2)}.${msgContab}` };
    } catch (error) {
        console.error("Error al cerrar la orden:", error.message);
        return { success: false, error: error.message };
    }
}

// --- Panel "Órdenes en Proceso" (admin: sí muestra costos) -------------------

async function cargarOrdenesEnProceso() {
    const cont = document.getElementById('contenedorOrdenesEnProceso');
    if (!cont) return;

    const { data: ordenes, error } = await supabaseClient
        .from('ordenes_produccion')
        .select(`
            id, folio, numero_lote, cantidad_producida, abierta_at,
            productos ( nombre ),
            orden_produccion_procesos (
                id, proceso_nombre,
                orden_produccion_proceso_empleados ( empleado_id, costo_hora_snapshot, finalizado_at, empleados ( nombre ) )
            )
        `)
        .eq('estado', 'en_proceso')
        .order('abierta_at', { ascending: true });

    if (error) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${error.message}</p>`;
        return;
    }
    if (!ordenes || !ordenes.length) {
        cont.innerHTML = `<p class="text-slate-500 text-xs italic">No hay órdenes en proceso.</p>`;
        return;
    }

    const procIds = ordenes.flatMap(o => (o.orden_produccion_procesos || []).map(p => p.id));
    let registros = [];
    let solicitudes = [];
    if (procIds.length) {
        const { data: regs } = await supabaseClient.from('registros_tiempo')
            .select('orden_produccion_proceso_id, empleado_id, inicio, fin')
            .in('orden_produccion_proceso_id', procIds);
        registros = regs || [];
        // Solicitudes de reasignación pendientes (degrada si el SQL no está)
        try {
            const { data: sols, error: errSol } = await supabaseClient.from('solicitudes_reasignacion')
                .select('id, proceso_id, empleado_id, motivo, creada_at, empleados ( nombre )')
                .eq('estatus', 'pendiente')
                .in('proceso_id', procIds);
            if (!errSol) solicitudes = sols || [];
        } catch (_) { solicitudes = []; }
    }

    cont.innerHTML = ordenes.map(o => renderTarjetaOrdenEnProceso(o, registros, solicitudes)).join('');

    cont.querySelectorAll('.btn-resolver-sol').forEach(btn => {
        btn.onclick = async () => {
            const aprobar = btn.dataset.accion === 'aprobar';
            if (!confirm(aprobar
                ? `¿Asignar a ${btn.dataset.nombre} al proceso "${btn.dataset.proc}"?`
                : `¿Rechazar la solicitud de ${btn.dataset.nombre}?`)) return;
            btn.disabled = true;
            const { error } = await supabaseClient.rpc('resolver_reasignacion', {
                p_solicitud_id: Number(btn.dataset.id),
                p_aprobar: aprobar
            });
            if (error) { alert('No se pudo resolver: ' + error.message); btn.disabled = false; return; }
            await cargarOrdenesEnProceso();
        };
    });

    cont.querySelectorAll('.btn-ajuste-tiempo').forEach(btn => {
        btn.onclick = async () => {
            const resp = prompt(`Minutos trabajados a AGREGAR para "${btn.dataset.nombre}" en "${btn.dataset.procNombre}":`);
            if (resp === null) return;
            const min = parseFloat(resp);
            if (!min || Number.isNaN(min) || min <= 0) { alert('Ingresa un número de minutos mayor que 0.'); return; }

            const fin = new Date();
            const inicio = new Date(fin.getTime() - min * 60000);

            const { error: errIns } = await supabaseClient.from('registros_tiempo').insert([{
                orden_produccion_proceso_id: Number(btn.dataset.proceso),
                empleado_id: Number(btn.dataset.empleado),
                inicio: inicio.toISOString(),
                fin: fin.toISOString(),
                fuente: 'admin'
            }]);
            if (errIns) { alert('No se pudo registrar el ajuste: ' + errIns.message); return; }
            await cargarOrdenesEnProceso();
        };
    });

    cont.querySelectorAll('.btn-cerrar-orden').forEach(btn => {
        btn.onclick = async () => {
            if (!confirm(`¿Cerrar la orden ${btn.dataset.folio}? Se descontará el inventario (FIFO) y se calcularán los costos. Esto no se puede deshacer.`)) return;
            btn.disabled = true;
            btn.textContent = 'Cerrando...';
            const res = await cerrarOrdenDeProduccion(Number(btn.dataset.id));
            if (res.success) {
                alert('✅ ' + res.mensaje);
                await cargarOrdenesEnProceso();
                await cargarHistorialProduccion();
                if (typeof cargarInventarioCompleto === 'function') await cargarInventarioCompleto();
            } else {
                alert('❌ ' + res.error);
                btn.disabled = false;
                btn.textContent = '🔒 Cerrar orden';
            }
        };
    });
}

function renderTarjetaOrdenEnProceso(o, registros, solicitudes = []) {
    const abierta = o.abierta_at ? new Date(o.abierta_at).toLocaleString() : '';
    const folio = o.folio || ('#' + o.id);

    const procesosHtml = (o.orden_produccion_procesos || []).map(p => {
        const regsP = registros.filter(r => r.orden_produccion_proceso_id === p.id);
        const equipo = p.orden_produccion_proceso_empleados || [];

        const filasEmp = equipo.map(e => {
            const empId = Number(e.empleado_id);
            const snap = Number(e.costo_hora_snapshot || 0);
            const nombreEmp = e.empleados?.nombre || 'Empleado';
            let acumCerrado = 0;
            let inicioAbierto = '';
            regsP.filter(r => Number(r.empleado_id) === empId).forEach(r => {
                if (r.fin) acumCerrado += segundosDeIntervalo(r.inicio, r.fin);
                else inicioAbierto = r.inicio;
            });
            const activo = inicioAbierto ? '<span class="text-emerald-400">●</span> ' : '';
            const marca = e.finalizado_at ? ' <span class="text-emerald-400">✓ finalizada</span>' : '';
            return `
                <div class="flex justify-between items-center text-xs py-1">
                    <span class="text-slate-300">${activo}${nombreEmp}${marca}</span>
                    <span class="font-mono text-slate-400 flex items-center gap-1">
                        <span class="ot-timer" data-acum="${acumCerrado}" data-inicio="${inicioAbierto}">00:00:00</span>
                        · <span class="ot-costo text-emerald-400" data-card="${o.id}" data-acum="${acumCerrado}" data-inicio="${inicioAbierto}" data-costohora="${snap}">$0.00</span>
                        <button type="button" class="btn-ajuste-tiempo text-slate-500 hover:text-amber-400 ml-1" title="Ajustar tiempo manualmente"
                                data-proceso="${p.id}" data-empleado="${empId}" data-nombre="${nombreEmp.replace(/"/g, '&quot;')}" data-proc-nombre="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">✎</button>
                    </span>
                </div>`;
        }).join('');

        const solsP = solicitudes.filter(s => Number(s.proceso_id) === p.id);
        const solsHtml = solsP.map(s => `
            <div class="flex flex-wrap items-center justify-between gap-2 bg-amber-950/30 border border-amber-800/50 rounded-lg px-2.5 py-1.5 mt-1.5">
                <span class="text-[11px] text-amber-200">🙋 <b>${s.empleados?.nombre || 'Empleado'}</b> pide entrar a este proceso${s.motivo ? ` — <span class="text-amber-300/80">"${String(s.motivo).replace(/</g, '&lt;')}"</span>` : ''}</span>
                <span class="flex gap-1">
                    <button class="btn-resolver-sol text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded"
                            data-id="${s.id}" data-accion="aprobar" data-nombre="${(s.empleados?.nombre || '').replace(/"/g, '&quot;')}" data-proc="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">Aprobar</button>
                    <button class="btn-resolver-sol text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded"
                            data-id="${s.id}" data-accion="rechazar" data-nombre="${(s.empleados?.nombre || '').replace(/"/g, '&quot;')}" data-proc="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">Rechazar</button>
                </span>
            </div>`).join('');

        return `
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3">
                <p class="text-sm font-semibold text-slate-200 mb-1">${p.proceso_nombre}</p>
                ${filasEmp || '<p class="text-[11px] text-slate-500 italic">Sin equipo asignado.</p>'}
                ${solsHtml}
            </div>`;
    }).join('');

    return `
        <div class="border border-slate-800 rounded-xl p-4 mb-3">
            <div class="flex flex-wrap justify-between items-start gap-2 mb-3">
                <div>
                    <p class="font-mono font-bold text-amber-400 text-sm">${folio}</p>
                    <p class="text-xs text-slate-300">${o.productos?.nombre || 'Producto'} · ${o.cantidad_producida} u · Lote ${o.numero_lote || 'S/L'}</p>
                    <p class="text-[11px] text-slate-500">Abierta: ${abierta}</p>
                </div>
                <button type="button" class="btn-cerrar-orden bg-rose-700 hover:bg-rose-600 text-white text-xs px-3 py-1.5 rounded-lg" data-id="${o.id}" data-folio="${folio}">🔒 Cerrar orden</button>
            </div>
            <div class="space-y-2">${procesosHtml}</div>
            <div class="flex justify-between items-center text-xs mt-3 pt-2 border-t border-slate-800">
                <span class="text-slate-400">Mano de obra registrada (parcial)</span>
                <span class="ot-costo-total font-mono font-bold text-emerald-400" data-card="${o.id}">$0.00</span>
            </div>
        </div>`;
}

// Ticker de 1s: recalcula los cronómetros abiertos sin volver a consultar la BD.
function tickEnProceso() {
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-timer').forEach(el => {
        const acum = Number(el.dataset.acum || 0);
        const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
        el.textContent = formatoHHMMSS(acum + (ini ? (Date.now() - ini) / 1000 : 0));
    });
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-costo').forEach(el => {
        const acum = Number(el.dataset.acum || 0);
        const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
        const ch = Number(el.dataset.costohora || 0);
        const seg = acum + (ini ? (Date.now() - ini) / 1000 : 0);
        el.textContent = '$' + ((seg / 3600) * ch).toFixed(2);
    });
    // Subtotal de mano de obra por orden = suma de los costos de sus operarios.
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-costo-total').forEach(tot => {
        const card = tot.dataset.card;
        let sum = 0;
        document.querySelectorAll(`#contenedorOrdenesEnProceso .ot-costo[data-card="${card}"]`).forEach(el => {
            const acum = Number(el.dataset.acum || 0);
            const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
            const ch = Number(el.dataset.costohora || 0);
            sum += ((acum + (ini ? (Date.now() - ini) / 1000 : 0)) / 3600) * ch;
        });
        tot.textContent = '$' + sum.toFixed(2);
    });
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
            .select(`id, folio, producto_id, numero_lote, cantidad_producida, empleados_involucrados, costo_unitario_final, costo_total_materiales, costo_total_mano_obra, created_at, productos ( id, nombre, sku, descripcion, unidades_medida ( nombre ) )`)
            .eq('estado', 'cerrada')
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!ordenes || ordenes.length === 0) {
            contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">Todavía no hay órdenes cerradas.</p>`;
            if (selectOrdenId) selectOrdenId.innerHTML = '<option value="">No hay órdenes disponibles</option>';
            if (btnImprimirOrden) btnImprimirOrden.disabled = true;
            return;
        }

        if (selectOrdenId) {
            selectOrdenId.innerHTML = '<option value="">Seleccione orden por ID...</option>';
            ordenes.forEach(o => {
                selectOrdenId.innerHTML += `<option value="${o.id}">${o.folio || ('ID #' + o.id)} - ${o.numero_lote || 'Sin Lote'} (${o.productos?.nombre || 'Producto'})</option>`;
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
                    <th class="p-2">Folio</th><th class="p-2">Fecha</th><th class="p-2">Lote PT</th><th class="p-2">Producto</th><th class="p-2">Cantidad</th><th class="p-2">Costo Unit. Final</th>
                </tr></thead><tbody>
        `;

        ordenes.forEach(o => {
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition-colors cursor-pointer" onclick="document.getElementById('selectOrdenId').value='${o.id}'; document.getElementById('selectOrdenId').dispatchEvent(new Event('change'));">
                    <td class="p-2 font-mono text-xs text-amber-300">${o.folio || ('#' + o.id)}</td>
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