import { supabaseClient } from './supabase.js';
import { imprimirConPlantilla } from './impresion.js';

// =====================================================================
// Contabilidad · Nómina — arma y postea la póliza de sueldos y salarios
// (mismo patrón que Gastos en contabilidad.js: registrar_nomina/
// cancelar_nomina hacen el trabajo contable en Supabase, este módulo
// solo captura los datos y muestra el historial).
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };

// Siguiente semana de nómina (lunes a domingo, coincide con como paga la
// empresa — sueldo_semanal): la que sigue al último periodo ya usado por
// cualquier nómina (borrador, registrada o cancelada, para no ofrecer dos
// veces la misma semana). Si no hay historial, ofrece la semana lunes-
// domingo que contiene o ya terminó hoy.
export async function siguientePeriodoSugerido() {
    let inicio;
    try {
        const { data } = await supabaseClient
            .from('nominas')
            .select('periodo_fin')
            .order('periodo_fin', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (data?.periodo_fin) {
            const d = new Date(data.periodo_fin + 'T00:00:00');
            d.setDate(d.getDate() + 1);
            inicio = d;
        }
    } catch { /* sigue al fallback de abajo */ }

    if (!inicio) {
        const hoy = new Date();
        const diaSemana = hoy.getDay(); // 0=domingo … 6=sábado
        const offsetALunes = diaSemana === 0 ? -6 : 1 - diaSemana;
        inicio = new Date(hoy);
        inicio.setDate(hoy.getDate() + offsetALunes);
    }

    const fin = new Date(inicio);
    fin.setDate(inicio.getDate() + 6);
    return { inicio: inicio.toISOString().slice(0, 10), fin: fin.toISOString().slice(0, 10) };
}

let nomEmpleados = []; // catálogo de empleados activos: {id, nombre}
let nomLineas = [];    // [{ empleado_id, nombre, incluido, sueldo }]
let nomCtasPago = [];
let nomImssEditadoManualmente = false; // true si el usuario escribió el monto de IMSS a mano (no seguir el % automático)
let nomIsrEditadoManualmente = false;  // idem para ISR retenido

export async function cargarModuloNomina() {
    const cont = document.getElementById('contenedorNomina');
    if (!cont) return;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Formulario -->
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <h3 class="text-md font-semibold text-sky-400">Nueva nómina (borrador)</h3>
            <p class="text-[11px] text-slate-500">El periodo se sugiere solo (semana lunes a domingo, la siguiente a la última ya usada) — cámbialo aquí si necesitas otro. Al guardar queda como <span class="text-amber-400 font-semibold">borrador</span>: no se contabiliza hasta que alguien la autorice abajo, en el historial.</p>
            <form id="nomForm" class="space-y-3">
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Periodo desde</label>
                        <input type="date" id="nomPeriodoInicio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Periodo hasta</label>
                        <input type="date" id="nomPeriodoFin" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Fecha de pago</label>
                        <input type="date" id="nomFechaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Condicion</label>
                        <select id="nomCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="contado">Contado</option><option value="credito">Credito (por pagar)</option>
                        </select></div>
                </div>
                <div id="nomPagoWrap">
                    <label class="block text-[11px] text-slate-400 mb-1">Pagado desde (caja / banco)</label>
                    <select id="nomCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                </div>
                <div class="bg-slate-900 border border-slate-800 rounded-lg p-3 space-y-2">
                    <div class="flex items-center justify-between">
                        <label class="text-[11px] text-slate-400 font-semibold">Cuotas patronales IMSS/INFONAVIT</label>
                        <button type="button" id="nomImssToggle" class="text-[10px] text-sky-400 hover:underline">Ver desglose ▾</button>
                    </div>
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Clase de riesgo de trabajo</label>
                        <select id="nomImssClase" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="0.54355">Clase I — Mínimo (0.54355%)</option>
                            <option value="1.13065">Clase II — Bajo (1.13065%)</option>
                            <option value="2.59840">Clase III — Medio (2.59840%)</option>
                            <option value="4.65325">Clase IV — Alto (4.65325%)</option>
                            <option value="7.58875">Clase V — Máximo (7.58875%)</option>
                        </select>
                    </div>

                    <div id="nomImssDesglose" class="hidden space-y-1.5 pt-2 border-t border-slate-800">
                        <p class="text-[10px] text-slate-500">Primas mínimas de la Ley del Seguro Social; ajusta cualquier renglón si tu contador te da un valor distinto (por ejemplo tu prima de riesgo registrada ante el IMSS). No incluye la cuota fija de Enfermedades y Maternidad (es un monto fijo en UMA, no un %); Cesantía y Vejez puede subir hasta 5.175% para sueldos mayores a 1 UMA.</p>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Riesgo de trabajo (según clase)</span>
                            <input type="number" step="0.00001" min="0" id="nomImssRiesgo" value="0.54355" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Enf. y maternidad — excedente 3 UMA</span>
                            <input type="number" step="0.01" min="0" id="nomImssExcedente" value="1.10" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Enf. y maternidad — especie (pensionados)</span>
                            <input type="number" step="0.01" min="0" id="nomImssEspecie" value="1.05" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Enf. y maternidad — dinero</span>
                            <input type="number" step="0.01" min="0" id="nomImssDinero" value="0.70" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Guarderías y prestaciones sociales</span>
                            <input type="number" step="0.01" min="0" id="nomImssGuarderias" value="1.00" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Invalidez y vida</span>
                            <input type="number" step="0.01" min="0" id="nomImssInvalidez" value="1.75" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Retiro</span>
                            <input type="number" step="0.01" min="0" id="nomImssRetiro" value="2.00" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">Cesantía en edad avanzada y vejez</span>
                            <input type="number" step="0.001" min="0" id="nomImssCesantia" value="3.150" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[11px] items-center">
                            <span class="text-slate-400">INFONAVIT</span>
                            <input type="number" step="0.01" min="0" id="nomImssInfonavit" value="5.00" class="bg-slate-950 border border-slate-800 rounded p-1 text-right font-mono text-slate-100 nom-imss-concepto">
                        </div>
                    </div>

                    <div class="flex justify-between items-center pt-1 border-t border-slate-800">
                        <span class="text-[11px] text-slate-300 font-semibold">Total % IMSS patronal</span>
                        <span id="nomImssPctTotal" class="font-mono text-sm text-emerald-400 font-semibold">0.00000%</span>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Cuotas IMSS/INFONAVIT patronales</label>
                        <input type="number" step="0.01" min="0" id="nomCuotasImss" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">ISR retenido</label>
                        <input type="number" step="0.01" min="0" id="nomIsrRetenido" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                </div>
                <p id="nomIsrTabla" class="text-[10px] text-slate-500 -mt-1">Calculando ISR con la tabla progresiva por empleado…</p>

                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Empleados a incluir</label>
                    <div id="nomEmpleadosWrap" class="border border-slate-800 rounded-lg overflow-hidden">
                        <table class="w-full text-xs">
                            <thead class="bg-slate-900 text-slate-400 uppercase">
                                <tr><th class="p-2 text-left w-8"></th><th class="p-2 text-left">Empleado</th><th class="p-2 text-right">Sueldo</th></tr>
                            </thead>
                            <tbody id="nomEmpleadosBody"><tr><td colspan="3" class="p-3 text-center text-slate-500">Cargando empleados...</td></tr></tbody>
                        </table>
                    </div>
                </div>

                <div class="bg-slate-900 border border-slate-800 rounded-lg p-3 flex justify-between items-center">
                    <span class="text-xs text-slate-400">Subtotal sueldos (marcados)</span>
                    <span id="nomSubtotalPreview" class="font-mono text-lg font-bold text-emerald-400">$0.00</span>
                </div>

                <button type="submit" id="nomGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Pre-ejecutar nómina (borrador)</button>
                <p id="nomMsg" class="text-xs min-h-[1rem]"></p>
            </form>
        </div>

        <!-- Historial -->
        <div class="xl:col-span-2 space-y-3">
            <div class="flex flex-wrap items-end gap-3">
                <div><label class="block text-[11px] text-slate-400 mb-1">Desde</label>
                    <input type="date" id="nomDesde" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Hasta</label>
                    <input type="date" id="nomHasta" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
                <button type="button" id="nomBuscar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">Buscar</button>
                <span id="nomTotales" class="ml-auto text-xs text-slate-400 self-center"></span>
            </div>
            <div id="nomLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando nómina...</div>
        </div>
    </div>
    <div id="nomImprimirArea" class="hidden"></div>`;

    const hoy = hoyISO();
    const sugerido = await siguientePeriodoSugerido();
    document.getElementById('nomPeriodoInicio').value = sugerido.inicio;
    document.getElementById('nomPeriodoFin').value = sugerido.fin;
    document.getElementById('nomFechaPago').value = sugerido.fin;
    document.getElementById('nomDesde').value = primerDiaMesISO();
    document.getElementById('nomHasta').value = hoy;

    nomCablear();
    await nomCargarCatalogos();
    await nomBuscar();
}

function nomCablear() {
    const $ = (id) => document.getElementById(id);
    $('nomCondicion').addEventListener('change', () => {
        $('nomPagoWrap').style.display = $('nomCondicion').value === 'contado' ? '' : 'none';
    });

    $('nomImssToggle').addEventListener('click', () => {
        const desglose = $('nomImssDesglose');
        const abierto = !desglose.classList.contains('hidden');
        desglose.classList.toggle('hidden');
        $('nomImssToggle').textContent = abierto ? 'Ver desglose ▾' : 'Ocultar desglose ▴';
    });
    $('nomImssClase').addEventListener('change', () => {
        $('nomImssRiesgo').value = $('nomImssClase').value;
        nomImssEditadoManualmente = false;
        nomActualizarTotalImss();
    });
    document.querySelectorAll('.nom-imss-concepto').forEach((el) => {
        el.addEventListener('input', () => { nomImssEditadoManualmente = false; nomActualizarTotalImss(); });
    });

    $('nomCuotasImss').addEventListener('input', () => { nomImssEditadoManualmente = true; });
    $('nomIsrRetenido').addEventListener('input', () => { nomIsrEditadoManualmente = true; });
    ['nomPeriodoInicio', 'nomPeriodoFin', 'nomFechaPago'].forEach((id) => {
        $(id).addEventListener('change', nomProgramarRecalculoIsr);
    });
    $('nomForm').addEventListener('submit', nomGuardar);
    $('nomBuscar').addEventListener('click', nomBuscar);

    nomActualizarTotalImss();
}

function nomRenderEmpleados() {
    const body = document.getElementById('nomEmpleadosBody');
    if (!body) return;

    if (nomLineas.length === 0) {
        body.innerHTML = `<tr><td colspan="3" class="p-3 text-center text-slate-500">No hay empleados activos.</td></tr>`;
        return;
    }

    body.innerHTML = nomLineas.map((l, i) => `
        <tr class="border-t border-slate-800">
            <td class="p-2"><input type="checkbox" class="nom-l" data-i="${i}" data-f="incluido" ${l.incluido ? 'checked' : ''}></td>
            <td class="p-2 text-slate-200">${l.nombre}</td>
            <td class="p-2 text-right">
                <input type="number" step="0.01" min="0" class="nom-l w-28 bg-slate-900 border border-slate-800 rounded p-1 text-right font-mono text-slate-100" data-i="${i}" data-f="sueldo" value="${l.sueldo}">
            </td>
        </tr>
    `).join('');

    body.querySelectorAll('.nom-l').forEach((el) => {
        el.addEventListener('input', nomActualizarLinea);
        el.addEventListener('change', nomActualizarLinea);
    });
    nomActualizarSubtotal();
}

function nomActualizarLinea(e) {
    const i = Number(e.target.dataset.i);
    const f = e.target.dataset.f;
    if (!nomLineas[i]) return;
    nomLineas[i][f] = f === 'incluido' ? e.target.checked : (parseFloat(e.target.value) || 0);
    nomActualizarSubtotal();
}

function nomSubtotalMarcado() {
    return nomLineas.filter((l) => l.incluido).reduce((a, l) => a + (Number(l.sueldo) || 0), 0);
}

function nomActualizarSubtotal() {
    const el = document.getElementById('nomSubtotalPreview');
    if (el) el.textContent = money(nomSubtotalMarcado());
    nomRecalcularImss();
    nomProgramarRecalculoIsr();
}

// Suma el desglose de conceptos patronales IMSS/INFONAVIT y refleja el
// total; de ahí dispara el recálculo del monto en pesos.
function nomActualizarTotalImss() {
    const total = [...document.querySelectorAll('.nom-imss-concepto')]
        .reduce((a, el) => a + (parseFloat(el.value) || 0), 0);
    const el = document.getElementById('nomImssPctTotal');
    if (el) el.textContent = total.toFixed(5) + '%';
    nomRecalcularImss();
}

// Recalcula Cuotas IMSS como % del subtotal marcado, salvo que el
// usuario haya editado ese monto a mano (mismo criterio que el
// subtotal/IVA automático de Compras).
function nomRecalcularImss() {
    const subtotal = nomSubtotalMarcado();
    const pctImss = [...document.querySelectorAll('.nom-imss-concepto')]
        .reduce((a, el) => a + (parseFloat(el.value) || 0), 0);

    if (!nomImssEditadoManualmente) {
        const el = document.getElementById('nomCuotasImss');
        if (el) el.value = (Math.round(subtotal * pctImss) / 100).toFixed(2);
    }
}

// ISR: llama al RPC calcular_isr_nomina (tarifa progresiva real, por
// empleado) en vez de un % aproximado. Se manda con un pequeño debounce
// para no disparar una consulta en cada tecla.
let nomIsrDebounce = null;
function nomProgramarRecalculoIsr() {
    clearTimeout(nomIsrDebounce);
    nomIsrDebounce = setTimeout(nomRecalcularIsr, 350);
}

async function nomRecalcularIsr() {
    const etiqueta = document.getElementById('nomIsrTabla');
    const empleados = nomLineas
        .filter((l) => l.incluido)
        .map((l) => ({ empleado_id: l.empleado_id, sueldo: Number(l.sueldo) || 0 }));

    if (empleados.length === 0) {
        if (!nomIsrEditadoManualmente) document.getElementById('nomIsrRetenido').value = '0.00';
        if (etiqueta) { etiqueta.textContent = 'Marca empleados para calcular el ISR.'; etiqueta.className = 'text-[10px] text-slate-500 -mt-1'; }
        return;
    }

    const p_datos = {
        periodo_inicio: document.getElementById('nomPeriodoInicio').value,
        periodo_fin: document.getElementById('nomPeriodoFin').value,
        fecha_pago: document.getElementById('nomFechaPago').value,
        empleados,
    };

    try {
        const { data, error } = await supabaseClient.rpc('calcular_isr_nomina', { p_datos });
        if (error) throw error;

        if (!nomIsrEditadoManualmente) {
            document.getElementById('nomIsrRetenido').value = (Number(data.total) || 0).toFixed(2);
        }
        if (etiqueta) {
            const diasNomina = Number(data.dias_nomina);
            const diasTabla = Number(data.dias_tabla);
            const periodoNoCoincide = data.tarifa_id && Number.isFinite(diasNomina) && Number.isFinite(diasTabla) && Math.abs(diasNomina - diasTabla) > 0.5;

            if (periodoNoCoincide) {
                etiqueta.textContent = `⚠ El periodo capturado dura ${diasNomina} día(s) pero la tabla ISR vigente es para periodos de ${diasTabla} día(s) — el ISR se está prorrateando proporcionalmente. Verifica que "Periodo desde/hasta" cubran una sola nómina antes de guardar.`;
                etiqueta.className = 'text-[10px] text-amber-500 -mt-1';
            } else if (data.tarifa_id) {
                etiqueta.textContent = `ISR calculado por empleado con la tabla vigente desde ${data.tarifa_vigente_desde}${data.tarifa_fuente ? ' (' + data.tarifa_fuente + ')' : ''}.`;
                etiqueta.className = 'text-[10px] text-emerald-500 -mt-1';
            } else {
                etiqueta.textContent = 'No hay tabla ISR cargada todavía (Contabilidad › Tabla ISR) — el monto queda en $0.00 hasta que subas una.';
                etiqueta.className = 'text-[10px] text-amber-500 -mt-1';
            }
        }
    } catch (err) {
        if (etiqueta) { etiqueta.textContent = 'No se pudo calcular el ISR: ' + (err.message || err); etiqueta.className = 'text-[10px] text-rose-400 -mt-1'; }
    }
}

async function nomCargarCatalogos() {
    try {
        const [emps, ctas] = await Promise.all([
            supabaseClient.from('empleados').select('id, nombre, sueldo_semanal').eq('activo', true).order('nombre'),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo, afectable, activa').eq('afectable', true).eq('activa', true).order('codigo'),
        ]);
        if (emps.error) throw emps.error;
        if (ctas.error) throw ctas.error;

        nomEmpleados = emps.data || [];
        nomLineas = nomEmpleados.map((e) => ({
            empleado_id: e.id,
            nombre: e.nombre,
            incluido: true,
            sueldo: Number(e.sueldo_semanal) || 0,
        }));

        const todas = ctas.data || [];
        nomCtasPago = todas.filter((c) => c.tipo === 'activo' && /^(101|102)/.test(c.codigo));
        document.getElementById('nomCuentaPago').innerHTML = `<option value="">— caja / banco —</option>` +
            nomCtasPago.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');

        nomRenderEmpleados();
    } catch (err) {
        console.error('Error al cargar catálogos de nómina:', err);
        document.getElementById('nomEmpleadosBody').innerHTML =
            `<tr><td colspan="3" class="p-3 text-rose-400">¿Corriste sql/2026-08-30_contabilidad_nomina.sql en Supabase?<br>${err.message || err}</td></tr>`;
    }
}

async function nomGuardar(e) {
    e.preventDefault();
    const msg = document.getElementById('nomMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';
    const $ = (id) => document.getElementById(id);

    const condicion = $('nomCondicion').value;
    const empleados = nomLineas
        .filter((l) => l.incluido)
        .map((l) => ({ empleado_id: l.empleado_id, sueldo: Number(l.sueldo) || 0 }));

    if (empleados.length === 0) {
        msg.textContent = 'Marca al menos un empleado.'; msg.className = 'text-xs text-rose-400'; return;
    }
    const subtotal = empleados.reduce((a, e) => a + e.sueldo, 0);
    if (subtotal <= 0) {
        msg.textContent = 'El subtotal de sueldos debe ser mayor a cero.'; msg.className = 'text-xs text-rose-400'; return;
    }

    const p_datos = {
        periodo_inicio: $('nomPeriodoInicio').value,
        periodo_fin: $('nomPeriodoFin').value,
        fecha_pago: $('nomFechaPago').value,
        condicion,
        cuenta_pago_id: condicion === 'contado' && $('nomCuentaPago').value ? Number($('nomCuentaPago').value) : null,
        cuotas_imss: parseFloat($('nomCuotasImss').value) || 0,
        // Solo se manda si el usuario lo editó a mano; si no, precalcular_nomina
        // lo calcula solo con la tabla ISR vigente (calcular_isr_nomina).
        isr_retenido: nomIsrEditadoManualmente ? (parseFloat($('nomIsrRetenido').value) || 0) : null,
        empleados,
    };

    try {
        $('nomGuardar').disabled = true;
        const { data, error } = await supabaseClient.rpc('precalcular_nomina', { p_datos });
        if (error) throw error;
        const tablaTxt = data.isr_tarifa_vigente_desde
            ? ` ISR calculado con la tabla vigente desde ${data.isr_tarifa_vigente_desde}${data.isr_tarifa_fuente ? ' (' + data.isr_tarifa_fuente + ')' : ''}.`
            : '';
        msg.textContent = `Nómina #${data.nomina_id} pre-ejecutada como borrador (total ${money(data.total)}) — todavía NO se contabilizó. Autorízala en el historial de abajo para generar la póliza.${tablaTxt}`;
        msg.className = 'text-xs text-amber-400';

        const sugerido = await siguientePeriodoSugerido();
        $('nomPeriodoInicio').value = sugerido.inicio;
        $('nomPeriodoFin').value = sugerido.fin;
        $('nomFechaPago').value = sugerido.fin;
        nomImssEditadoManualmente = false;
        nomIsrEditadoManualmente = false;
        await nomCargarCatalogos();
        await nomBuscar();
        await actualizarBannerNominaPendiente();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs text-rose-400';
    } finally {
        $('nomGuardar').disabled = false;
    }
}

async function nomBuscar() {
    const cont = document.getElementById('nomLista');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Buscando...</p>`;
    try {
        const { data, error } = await supabaseClient
            .from('nominas')
            .select('*, polizas(tipo, numero, estatus)')
            .gte('fecha_pago', document.getElementById('nomDesde').value)
            .lte('fecha_pago', document.getElementById('nomHasta').value)
            .order('fecha_pago', { ascending: false }).order('id', { ascending: false })
            .limit(300);
        if (error) throw error;

        if (!data || data.length === 0) {
            cont.innerHTML = `<p class="text-slate-400 text-sm">Sin nóminas en el rango.</p>`;
            document.getElementById('nomTotales').textContent = '';
            return;
        }

        const totVigentes = data.filter((n) => n.estatus === 'registrada').reduce((a, n) => a + Number(n.total || 0), 0);
        document.getElementById('nomTotales').textContent = `Total registrado: ${money(totVigentes)}  ·  ${data.length} nómina(s)`;

        cont.innerHTML = `
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr><th class="p-2">Periodo</th><th class="p-2">Fecha pago</th><th class="p-2 text-right">Subtotal</th>
                            <th class="p-2 text-right">Total</th><th class="p-2">Poliza</th>
                            <th class="p-2">Estatus</th><th class="p-2 text-right">Accion</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((n) => `
                            <tr class="border-b border-slate-900 ${n.estatus === 'cancelada' ? 'opacity-50' : ''}">
                                <td class="p-2 whitespace-nowrap">${n.periodo_inicio} a ${n.periodo_fin}</td>
                                <td class="p-2 whitespace-nowrap">${n.fecha_pago}</td>
                                <td class="p-2 text-right font-mono">${money(n.subtotal)}</td>
                                <td class="p-2 text-right font-mono">${money(n.total)}</td>
                                <td class="p-2 font-mono text-slate-500">${n.polizas ? n.polizas.tipo + ' #' + n.polizas.numero : '—'}</td>
                                <td class="p-2 ${n.estatus === 'registrada' ? 'text-emerald-400' : n.estatus === 'borrador' ? 'text-amber-400 font-semibold' : 'text-rose-400'}">${n.estatus === 'borrador' ? '⏳ pendiente de autorizar' : n.estatus}</td>
                                <td class="p-2 text-right whitespace-nowrap">
                                    <button data-print="${n.id}" class="nom-print text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer mr-1">🖨️ Imprimir</button>
                                    ${n.estatus === 'borrador'
                                        ? `<button data-autorizar="${n.id}" class="nom-autorizar text-[11px] bg-amber-800 hover:bg-amber-700 text-amber-100 px-2 py-1 rounded border border-amber-600 cursor-pointer mr-1">✔ Autorizar</button>`
                                        : ''}
                                    ${n.estatus === 'registrada' || n.estatus === 'borrador'
                                        ? `<button data-cancel="${n.id}" class="nom-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Cancelar</button>`
                                        : ''}
                                </td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>`;

        cont.querySelectorAll('.nom-cancel').forEach((b) => b.addEventListener('click', () => nomCancelar(Number(b.dataset.cancel))));
        cont.querySelectorAll('.nom-print').forEach((b) => b.addEventListener('click', () => nomImprimir(Number(b.dataset.print), b)));
        cont.querySelectorAll('.nom-autorizar').forEach((b) => b.addEventListener('click', () => nomAutorizar(Number(b.dataset.autorizar), b)));
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar nómina. ¿Corriste <span class="font-mono">sql/2026-08-30_contabilidad_nomina.sql</span>?<br>${err.message || err}</p>`;
    }
}

export async function nomCancelar(id) {
    if (!confirm('¿Cancelar esta nómina? Si ya está registrada se generará la póliza de reverso; si es un borrador solo se descarta (nunca se contabilizó).')) return;
    try {
        const { error } = await supabaseClient.rpc('cancelar_nomina', { p_nomina_id: id });
        if (error) throw error;
        await nomBuscar();
        await actualizarBannerNominaPendiente();
    } catch (err) {
        alert('No se pudo cancelar: ' + (err.message || err));
    }
}

// ---------------------------------------------------------------------
// Autoriza un borrador ya pre-ejecutado: arma y postea la póliza
// (autorizar_nomina) y pasa la nómina a 'registrada'. Es el paso que
// "confirma" el corte de nómina antes de contabilizarlo.
// ---------------------------------------------------------------------
export async function nomAutorizar(id, btn) {
    if (!confirm('¿Autorizar esta nómina? Se generará la póliza de Egreso y quedará contabilizada.')) return;
    const textoOriginal = btn ? btn.textContent : '';
    if (btn) { btn.disabled = true; btn.textContent = 'Autorizando…'; }
    try {
        const { data, error } = await supabaseClient.rpc('autorizar_nomina', { p_nomina_id: id });
        if (error) throw error;
        await nomBuscar();
        await actualizarBannerNominaPendiente();
        alert(`Nómina #${data.nomina_id} autorizada — póliza #${data.poliza_id} generada (total ${money(data.total)}).`);
    } catch (err) {
        alert('No se pudo autorizar: ' + (err.message || err));
    } finally {
        if (btn) { btn.disabled = false; btn.textContent = textoOriginal; }
    }
}

// ---------------------------------------------------------------------
// Consulta ligera (sin cargar todo el módulo) de nóminas en borrador
// pendientes de autorizar — usada para el aviso global que se muestra a
// quien inicie sesión, sin importar en qué pantalla esté.
// ---------------------------------------------------------------------
export async function contarNominasPendientes() {
    try {
        const { data, error } = await supabaseClient
            .from('nominas')
            .select('id, periodo_inicio, periodo_fin')
            .eq('estatus', 'borrador')
            .order('periodo_fin', { ascending: true });
        if (error) throw error;
        return data || [];
    } catch {
        return [];
    }
}

// Refresca el aviso amarillo global (fuera del módulo Nómina, visible en
// cualquier pantalla). Se dispara en dos momentos, encadenados sin
// estado propio (solo mira lo que ya hay en nominas):
//   1. Ya hay un borrador pre-ejecutado -> "pendiente de autorizar"
//      (esto es lo que manda: una vez que existe, se avisa siempre).
//   2. Todavía no hay borrador, pero ya es viernes de la semana
//      pendiente (lunes a domingo) -> "es viernes, pre-ejecuta y
//      autoriza" — recordatorio para que no se pase el corte.
// Se llama al iniciar sesión y después de cada acción que pueda cambiar
// el estado (guardar/autorizar/cancelar), así que el aviso se mantiene
// visible sin interrupción desde el viernes hasta que esa nómina quede
// autorizada (estatus 'registrada'), momento en el que desaparece solo.
export async function actualizarBannerNominaPendiente() {
    const banner = document.getElementById('bannerNominaPendiente');
    const texto = document.getElementById('bannerNominaPendienteTexto');
    if (!banner || !texto) return;

    const pendientes = await contarNominasPendientes();
    if (pendientes.length > 0) {
        if (pendientes.length === 1) {
            const p = pendientes[0];
            texto.textContent = `⏳ Tienes una nómina pendiente de autorizar: semana del ${p.periodo_inicio} al ${p.periodo_fin}.`;
        } else {
            texto.textContent = `⏳ Tienes ${pendientes.length} nóminas pendientes de autorizar.`;
        }
        banner.classList.remove('hidden');
        return;
    }

    const sugerido = await siguientePeriodoSugerido();
    const viernes = new Date(sugerido.inicio + 'T00:00:00');
    viernes.setDate(viernes.getDate() + 4); // lunes + 4 días = viernes de esa misma semana
    const hoy = new Date(hoyISO() + 'T00:00:00');

    if (hoy >= viernes) {
        texto.textContent = `📋 Ya es viernes de la semana del ${sugerido.inicio} al ${sugerido.fin} — pre-ejecuta y autoriza la nómina cuando puedas.`;
        banner.classList.remove('hidden');
    } else {
        banner.classList.add('hidden');
    }
}

// ---------------------------------------------------------------------
// Recibo imprimible de una nómina ya registrada: desglose por empleado
// (sueldo, ISR retenido, neto) + totales + cuotas patronales. Reusa el
// motor de impresión genérico (js/impresion.js) — mismo patrón que
// Reportes/Producción/Documentos.
// ---------------------------------------------------------------------
async function nomImprimir(id, btn) {
    const textoOriginal = btn ? btn.textContent : '';
    if (btn) { btn.disabled = true; btn.textContent = 'Preparando…'; }

    try {
        const { data: n, error: errN } = await supabaseClient
            .from('nominas')
            .select('*, polizas(tipo, numero), cuentas_contables(codigo, nombre), isr_tarifas(fuente, vigente_desde)')
            .eq('id', id)
            .single();
        if (errN) throw errN;

        const { data: detalles, error: errDet } = await supabaseClient
            .from('nomina_detalles')
            .select('sueldo, isr, empleados(nombre, puesto)')
            .eq('nomina_id', id);
        if (errDet) throw errDet;

        const filas = (detalles || [])
            .map((d) => ({
                nombre: d.empleados?.nombre || '—',
                puesto: d.empleados?.puesto || '',
                sueldo: Number(d.sueldo) || 0,
                isr: Number(d.isr) || 0,
            }))
            .sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'));

        const totalSueldo = filas.reduce((a, f) => a + f.sueldo, 0);
        const totalIsr = filas.reduce((a, f) => a + f.isr, 0);
        const totalNeto = totalSueldo - totalIsr;

        const cuentaPago = n.condicion === 'contado' && n.cuentas_contables
            ? `${n.cuentas_contables.codigo} — ${n.cuentas_contables.nombre}`
            : (n.condicion === 'credito' ? 'Crédito (por pagar)' : '—');

        const html = `
            <div style="font-family: Arial, sans-serif; color:#111;">
                <table style="width:100%; font-size:11px; margin-bottom:14px;">
                    <tr>
                        <td><strong>Periodo:</strong> ${n.periodo_inicio} a ${n.periodo_fin}</td>
                        <td><strong>Fecha de pago:</strong> ${n.fecha_pago}</td>
                    </tr>
                    <tr>
                        <td><strong>Condición:</strong> ${n.condicion === 'contado' ? 'Contado' : 'Crédito'}</td>
                        <td><strong>Pagado desde:</strong> ${cuentaPago}</td>
                    </tr>
                    <tr>
                        <td><strong>Póliza:</strong> ${n.polizas ? n.polizas.tipo + ' #' + n.polizas.numero : '—'}</td>
                        <td><strong>Estatus:</strong> ${n.estatus === 'registrada' ? 'Registrada' : 'Cancelada'}</td>
                    </tr>
                </table>

                <table style="width:100%; border-collapse:collapse; font-size:11px;">
                    <thead>
                        <tr style="background:#f0f0f0;">
                            <th style="text-align:left; padding:5px; border:1px solid #ccc;">Empleado</th>
                            <th style="text-align:left; padding:5px; border:1px solid #ccc;">Puesto</th>
                            <th style="text-align:right; padding:5px; border:1px solid #ccc;">Sueldo</th>
                            <th style="text-align:right; padding:5px; border:1px solid #ccc;">ISR retenido</th>
                            <th style="text-align:right; padding:5px; border:1px solid #ccc;">Neto pagado</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${filas.map((f) => `
                            <tr>
                                <td style="padding:5px; border:1px solid #ccc;">${f.nombre}</td>
                                <td style="padding:5px; border:1px solid #ccc;">${f.puesto}</td>
                                <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(f.sueldo)}</td>
                                <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(f.isr)}</td>
                                <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(f.sueldo - f.isr)}</td>
                            </tr>`).join('')}
                    </tbody>
                    <tfoot>
                        <tr style="font-weight:bold; background:#f7f7f7;">
                            <td style="padding:5px; border:1px solid #ccc;" colspan="2">Totales</td>
                            <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(totalSueldo)}</td>
                            <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(totalIsr)}</td>
                            <td style="text-align:right; padding:5px; border:1px solid #ccc; font-family:monospace;">${money(totalNeto)}</td>
                        </tr>
                    </tfoot>
                </table>

                <table style="width:100%; font-size:11px; margin-top:14px;">
                    <tr>
                        <td style="padding:3px 0;">Cuotas IMSS/INFONAVIT patronales</td>
                        <td style="text-align:right; padding:3px 0; font-family:monospace;">${money(n.cuotas_imss)}</td>
                    </tr>
                    <tr style="font-weight:bold;">
                        <td style="padding:3px 0; border-top:1px solid #ccc;">Total de la nómina (subtotal + cuotas patronales)</td>
                        <td style="text-align:right; padding:3px 0; border-top:1px solid #ccc; font-family:monospace;">${money(n.total)}</td>
                    </tr>
                </table>

                ${n.isr_tarifas ? `<p style="font-size:9px; color:#666; margin-top:14px;">ISR calculado con la tabla vigente desde ${n.isr_tarifas.vigente_desde}${n.isr_tarifas.fuente ? ' (' + n.isr_tarifas.fuente + ')' : ''}.</p>` : ''}
            </div>`;

        document.getElementById('nomImprimirArea').innerHTML = html;
        await imprimirConPlantilla('nomina', `Nómina ${n.periodo_inicio} a ${n.periodo_fin}`, 'nomImprimirArea');
    } catch (err) {
        alert('No se pudo preparar la impresión: ' + (err.message || err));
    } finally {
        if (btn) { btn.disabled = false; btn.textContent = textoOriginal; }
    }
}
