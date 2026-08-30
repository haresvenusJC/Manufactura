import { supabaseClient } from './supabase.js';

// =====================================================================
// Contabilidad · Nómina — arma y postea la póliza de sueldos y salarios
// (mismo patrón que Gastos en contabilidad.js: registrar_nomina/
// cancelar_nomina hacen el trabajo contable en Supabase, este módulo
// solo captura los datos y muestra el historial).
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };

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
            <h3 class="text-md font-semibold text-sky-400">Registrar nómina</h3>
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
                    <div><label class="block text-[11px] text-slate-400 mb-1">ISR retenido <span class="text-slate-600">(% <input type="number" step="0.01" min="0" id="nomIsrPct" value="0" class="w-12 bg-slate-950 border border-slate-800 rounded p-0.5 text-slate-300 font-mono text-center"> aprox.)</span></label>
                        <input type="number" step="0.01" min="0" id="nomIsrRetenido" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                </div>
                <p class="text-[10px] text-slate-500 -mt-1">ISR es una tabla progresiva por persona, no un % parejo — el % de arriba es solo una aproximación proporcional al subtotal. Los montos se recalculan solos; edítalos directo si ya traes la cifra exacta.</p>

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

                <button type="submit" id="nomGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Registrar nómina</button>
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
    </div>`;

    const hoy = hoyISO();
    document.getElementById('nomPeriodoInicio').value = primerDiaMesISO();
    document.getElementById('nomPeriodoFin').value = hoy;
    document.getElementById('nomFechaPago').value = hoy;
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

    $('nomIsrPct').addEventListener('input', () => { nomIsrEditadoManualmente = false; nomRecalcularImpuestos(); });
    $('nomCuotasImss').addEventListener('input', () => { nomImssEditadoManualmente = true; });
    $('nomIsrRetenido').addEventListener('input', () => { nomIsrEditadoManualmente = true; });
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
    nomRecalcularImpuestos();
}

// Suma el desglose de conceptos patronales IMSS/INFONAVIT y refleja el
// total; de ahí dispara el recálculo del monto en pesos.
function nomActualizarTotalImss() {
    const total = [...document.querySelectorAll('.nom-imss-concepto')]
        .reduce((a, el) => a + (parseFloat(el.value) || 0), 0);
    const el = document.getElementById('nomImssPctTotal');
    if (el) el.textContent = total.toFixed(5) + '%';
    nomRecalcularImpuestos();
}

// Recalcula Cuotas IMSS / ISR retenido como % del subtotal marcado, salvo
// que el usuario haya editado ese monto a mano (mismo criterio que el
// subtotal/IVA automático de Compras).
function nomRecalcularImpuestos() {
    const subtotal = nomSubtotalMarcado();
    const pctImss = [...document.querySelectorAll('.nom-imss-concepto')]
        .reduce((a, el) => a + (parseFloat(el.value) || 0), 0);
    const pctIsr = parseFloat(document.getElementById('nomIsrPct')?.value) || 0;

    if (!nomImssEditadoManualmente) {
        const el = document.getElementById('nomCuotasImss');
        if (el) el.value = (Math.round(subtotal * pctImss) / 100).toFixed(2);
    }
    if (!nomIsrEditadoManualmente) {
        const el = document.getElementById('nomIsrRetenido');
        if (el) el.value = (Math.round(subtotal * pctIsr) / 100).toFixed(2);
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
        isr_retenido: parseFloat($('nomIsrRetenido').value) || 0,
        empleados,
    };

    try {
        $('nomGuardar').disabled = true;
        const { data, error } = await supabaseClient.rpc('registrar_nomina', { p_datos });
        if (error) throw error;
        msg.textContent = `Nómina #${data.nomina_id} registrada — póliza Egreso generada (total ${money(data.total)}).`;
        msg.className = 'text-xs text-emerald-400';

        const hoy = hoyISO();
        $('nomPeriodoInicio').value = primerDiaMesISO();
        $('nomPeriodoFin').value = hoy;
        $('nomFechaPago').value = hoy;
        nomImssEditadoManualmente = false;
        nomIsrEditadoManualmente = false;
        await nomCargarCatalogos();
        await nomBuscar();
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
                                <td class="p-2 ${n.estatus === 'registrada' ? 'text-emerald-400' : 'text-rose-400'}">${n.estatus}</td>
                                <td class="p-2 text-right">
                                    ${n.estatus === 'registrada'
                                        ? `<button data-cancel="${n.id}" class="nom-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Cancelar</button>`
                                        : ''}
                                </td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>`;

        cont.querySelectorAll('.nom-cancel').forEach((b) => b.addEventListener('click', () => nomCancelar(Number(b.dataset.cancel))));
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar nómina. ¿Corriste <span class="font-mono">sql/2026-08-30_contabilidad_nomina.sql</span>?<br>${err.message || err}</p>`;
    }
}

async function nomCancelar(id) {
    if (!confirm('¿Cancelar esta nómina? Se generará la póliza de reverso.')) return;
    try {
        const { error } = await supabaseClient.rpc('cancelar_nomina', { p_nomina_id: id });
        if (error) throw error;
        await nomBuscar();
    } catch (err) {
        alert('No se pudo cancelar: ' + (err.message || err));
    }
}
