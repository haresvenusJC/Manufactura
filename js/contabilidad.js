import { supabaseClient } from './supabase.js';
import { imprimirConPlantilla } from './impresion.js';

// =====================================================================
//  Contabilidad - FASE 1: Plan de cuentas
//  Alta / edicion / consulta del catalogo (tabla cuentas_contables).
//  Requiere correr antes: sql/2026-08-28_contabilidad_cuentas.sql
// =====================================================================

const TIPOS = ['activo', 'pasivo', 'capital', 'ingreso', 'costo', 'gasto'];
const TIPO_LABEL = {
    activo: 'Activo', pasivo: 'Pasivo', capital: 'Capital',
    ingreso: 'Ingresos', costo: 'Costos', gasto: 'Gastos',
};
// Naturaleza tipica por tipo (solo sugerencia al capturar).
const NATURALEZA_POR_TIPO = { activo: 'D', pasivo: 'A', capital: 'A', ingreso: 'A', costo: 'D', gasto: 'D' };

let cuentas = [];       // cache del catalogo
let edicionId = null;   // id de la cuenta en edicion, o null

export async function cargarModuloContabilidad() {
    const cont = document.getElementById('contenedorPlanCuentas');
    if (!cont) return;

    cont.innerHTML = `
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Formulario -->
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <div class="flex justify-between items-center">
                <h3 id="ctaFormTitulo" class="text-md font-semibold text-sky-400">Nueva cuenta</h3>
                <button type="button" id="ctaNueva" class="hidden text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2.5 py-1 rounded-lg border border-slate-700 cursor-pointer">Nueva</button>
            </div>
            <form id="ctaForm" class="space-y-3">
                <input type="hidden" id="ctaId">
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Codigo <span class="text-rose-400">*</span></label>
                        <input type="text" id="ctaCodigo" placeholder="601.17" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono focus:outline-none focus:border-sky-500" required>
                    </div>
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Cod. agrupador SAT</label>
                        <input type="text" id="ctaAgrup" placeholder="601.17" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono focus:outline-none focus:border-sky-500">
                    </div>
                </div>
                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Nombre <span class="text-rose-400">*</span></label>
                    <input type="text" id="ctaNombre" placeholder="Energia electrica" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-sky-500" required>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Tipo</label>
                        <select id="ctaTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            ${TIPOS.map((t) => `<option value="${t}">${TIPO_LABEL[t]}</option>`).join('')}
                        </select>
                    </div>
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Naturaleza</label>
                        <select id="ctaNaturaleza" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="D">Deudora</option>
                            <option value="A">Acreedora</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Cuenta mayor (padre)</label>
                    <select id="ctaPadre" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        <option value="">(ninguna — es cuenta de mayor)</option>
                    </select>
                </div>
                <div class="flex gap-4 text-xs text-slate-300">
                    <label class="flex items-center gap-2"><input type="checkbox" id="ctaAfectable" checked class="accent-sky-500"> Acepta movimientos</label>
                    <label class="flex items-center gap-2"><input type="checkbox" id="ctaActiva" checked class="accent-sky-500"> Activa</label>
                </div>
                <button type="submit" id="ctaGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Guardar cuenta</button>
            </form>
        </div>

        <!-- Listado -->
        <div class="lg:col-span-2 space-y-3">
            <div class="flex flex-col sm:flex-row justify-between sm:items-center gap-2">
                <h3 class="text-md font-semibold text-slate-200">Catalogo de cuentas</h3>
                <div class="flex gap-2">
                    <input type="text" id="ctaFiltro" placeholder="filtrar codigo o nombre..." class="bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 w-56 focus:outline-none focus:border-sky-500">
                    <label class="flex items-center gap-1 text-[11px] text-slate-400"><input type="checkbox" id="ctaSoloAfectables" class="accent-sky-500"> solo de detalle</label>
                </div>
            </div>
            <div id="ctaTabla" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-center text-slate-500 text-sm">Cargando catalogo...</div>
        </div>
    </div>
    `;

    cablear();
    await recargar();
}

function cablear() {
    const $ = (id) => document.getElementById(id);

    $('ctaTipo').addEventListener('change', (e) => {
        // sugiere naturaleza segun tipo (no fuerza)
        $('ctaNaturaleza').value = NATURALEZA_POR_TIPO[e.target.value] || 'D';
    });

    $('ctaForm').addEventListener('submit', guardar);
    $('ctaNueva').addEventListener('click', limpiarForm);
    $('ctaFiltro').addEventListener('input', renderTabla);
    $('ctaSoloAfectables').addEventListener('change', renderTabla);
}

async function recargar() {
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('*')
            .order('codigo', { ascending: true });
        if (error) throw error;
        cuentas = data || [];
        poblarSelectPadre();
        renderTabla();
    } catch (err) {
        console.error('Error al cargar cuentas_contables:', err);
        document.getElementById('ctaTabla').innerHTML =
            `<p class="text-rose-400 text-xs">No se pudo cargar el catalogo. ¿Ya corriste <span class="font-mono">sql/2026-08-28_contabilidad_cuentas.sql</span> en Supabase?<br>${err.message || err}</p>`;
    }
}

function poblarSelectPadre() {
    const sel = document.getElementById('ctaPadre');
    const mayores = cuentas.filter((c) => !c.afectable);
    sel.innerHTML = `<option value="">(ninguna — es cuenta de mayor)</option>` +
        mayores.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
    if (edicionId) {
        const actual = cuentas.find((c) => c.id === edicionId);
        if (actual?.cuenta_padre_id) sel.value = actual.cuenta_padre_id;
    }
}

function renderTabla() {
    const cont = document.getElementById('ctaTabla');
    const q = (document.getElementById('ctaFiltro').value || '').trim().toLowerCase();
    const soloAfect = document.getElementById('ctaSoloAfectables').checked;

    let lista = cuentas;
    if (q) lista = lista.filter((c) => `${c.codigo} ${c.nombre} ${c.codigo_agrupador || ''}`.toLowerCase().includes(q));
    if (soloAfect) lista = lista.filter((c) => c.afectable);

    if (lista.length === 0) {
        cont.innerHTML = `<p class="text-slate-400 text-sm">Sin cuentas que coincidan.</p>`;
        return;
    }

    let html = '';
    for (const tipo of TIPOS) {
        const delTipo = lista.filter((c) => c.tipo === tipo);
        if (delTipo.length === 0) continue;
        html += `
        <div class="mb-4">
            <div class="text-xs uppercase text-sky-400 font-semibold mb-1">${TIPO_LABEL[tipo]}</div>
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-[11px] text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr>
                            <th class="p-2">Codigo</th><th class="p-2">Nombre</th>
                            <th class="p-2">Agrup. SAT</th><th class="p-2">Nat.</th>
                            <th class="p-2">Detalle</th><th class="p-2 text-right">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${delTipo.map((c) => `
                            <tr class="border-b border-slate-900 hover:bg-slate-900/40 ${c.activa ? '' : 'opacity-40'}">
                                <td class="p-2 font-mono ${c.afectable ? 'text-slate-300' : 'text-sky-300 font-semibold'}" style="padding-left:${8 + (c.nivel - 1) * 16}px">${c.codigo}</td>
                                <td class="p-2">${c.nombre}${c.activa ? '' : ' <span class="text-slate-600">(inactiva)</span>'}</td>
                                <td class="p-2 font-mono text-slate-500">${c.codigo_agrupador || '—'}</td>
                                <td class="p-2">${c.naturaleza}</td>
                                <td class="p-2">${c.afectable ? '<span class="text-emerald-500">sí</span>' : '<span class="text-slate-600">mayor</span>'}</td>
                                <td class="p-2 text-right space-x-1">
                                    <button data-edit="${c.id}" class="cta-edit text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Editar</button>
                                    <button data-del="${c.id}" class="cta-del text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Eliminar</button>
                                </td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>
        </div>`;
    }
    cont.innerHTML = html;

    cont.querySelectorAll('.cta-edit').forEach((b) => b.addEventListener('click', () => editar(Number(b.dataset.edit))));
    cont.querySelectorAll('.cta-del').forEach((b) => b.addEventListener('click', () => eliminar(Number(b.dataset.del))));
}

function limpiarForm() {
    edicionId = null;
    document.getElementById('ctaForm').reset();
    document.getElementById('ctaId').value = '';
    document.getElementById('ctaAfectable').checked = true;
    document.getElementById('ctaActiva').checked = true;
    document.getElementById('ctaFormTitulo').textContent = 'Nueva cuenta';
    document.getElementById('ctaGuardar').textContent = 'Guardar cuenta';
    document.getElementById('ctaNueva').classList.add('hidden');
}

function editar(id) {
    const c = cuentas.find((x) => x.id === id);
    if (!c) return;
    edicionId = id;
    document.getElementById('ctaId').value = id;
    document.getElementById('ctaCodigo').value = c.codigo;
    document.getElementById('ctaAgrup').value = c.codigo_agrupador || '';
    document.getElementById('ctaNombre').value = c.nombre;
    document.getElementById('ctaTipo').value = c.tipo;
    document.getElementById('ctaNaturaleza').value = c.naturaleza;
    document.getElementById('ctaPadre').value = c.cuenta_padre_id || '';
    document.getElementById('ctaAfectable').checked = c.afectable;
    document.getElementById('ctaActiva').checked = c.activa;
    document.getElementById('ctaFormTitulo').textContent = `Editar ${c.codigo}`;
    document.getElementById('ctaGuardar').textContent = 'Actualizar cuenta';
    document.getElementById('ctaNueva').classList.remove('hidden');
    document.getElementById('contenedorPlanCuentas').scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function guardar(e) {
    e.preventDefault();
    const padreVal = document.getElementById('ctaPadre').value;
    const padre = padreVal ? cuentas.find((c) => c.id === Number(padreVal)) : null;

    const payload = {
        codigo: document.getElementById('ctaCodigo').value.trim(),
        codigo_agrupador: document.getElementById('ctaAgrup').value.trim() || null,
        nombre: document.getElementById('ctaNombre').value.trim(),
        tipo: document.getElementById('ctaTipo').value,
        naturaleza: document.getElementById('ctaNaturaleza').value,
        cuenta_padre_id: padre ? padre.id : null,
        nivel: padre ? (padre.nivel || 1) + 1 : 1,
        afectable: document.getElementById('ctaAfectable').checked,
        activa: document.getElementById('ctaActiva').checked,
    };
    if (!payload.codigo || !payload.nombre) { alert('Codigo y nombre son obligatorios.'); return; }

    try {
        if (edicionId) {
            const { error } = await supabaseClient.from('cuentas_contables').update(payload).eq('id', edicionId);
            if (error) throw error;
        } else {
            const { error } = await supabaseClient.from('cuentas_contables').insert([payload]);
            if (error) throw error;
        }
        limpiarForm();
        await recargar();
    } catch (err) {
        if (err.code === '23505') alert('Ya existe una cuenta con ese codigo.');
        else alert('Error al guardar: ' + (err.message || err));
    }
}

async function eliminar(id) {
    const c = cuentas.find((x) => x.id === id);
    if (!c) return;
    if (cuentas.some((x) => x.cuenta_padre_id === id)) {
        alert('No se puede eliminar: tiene subcuentas. Reasigna o borra primero las subcuentas.');
        return;
    }
    if (!confirm(`¿Eliminar la cuenta ${c.codigo} · ${c.nombre}?`)) return;
    try {
        const { error } = await supabaseClient.from('cuentas_contables').delete().eq('id', id);
        if (error) throw error;
        if (edicionId === id) limpiarForm();
        await recargar();
    } catch (err) {
        // 23503 = foreign key (ya usada en polizas, cuando existan)
        if (err.code === '23503') alert('No se puede eliminar: la cuenta ya tiene movimientos. Marca la cuenta como inactiva en su lugar.');
        else alert('Error al eliminar: ' + (err.message || err));
    }
}

// =====================================================================
//  Contabilidad - FASE 2: Polizas
//  Captura manual de polizas de partida doble (valida cuadre via RPC
//  registrar_poliza). Requiere: sql/2026-08-28_contabilidad_polizas.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };

let polCuentas = [];            // cuentas afectables (para los selects)
let polCuentasMapa = new Map(); // id -> cuenta
let polLineas = [];             // borrador de la poliza nueva
let polExpandida = null;        // id de poliza con detalle abierto

export async function cargarModuloPolizas() {
    const cont = document.getElementById('contenedorPolizas');
    if (!cont) return;

    cont.innerHTML = `
    <div class="space-y-4">
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl flex flex-wrap items-end gap-3">
            <div><label class="block text-[11px] text-slate-400 mb-1">Desde</label>
                <input type="date" id="polDesde" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Hasta</label>
                <input type="date" id="polHasta" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Tipo</label>
                <select id="polTipoF" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                    <option value="">Todos</option><option>Ingreso</option><option>Egreso</option><option>Diario</option></select></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Estatus</label>
                <select id="polEstatusF" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                    <option value="">Todos</option><option value="contabilizada">Contabilizada</option><option value="cancelada">Cancelada</option></select></div>
            <button type="button" id="polBuscarBtn" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">Buscar</button>
            <button type="button" id="polNuevaBtn" class="ml-auto text-xs bg-sky-600 hover:bg-sky-500 text-white px-3 py-2 rounded-lg cursor-pointer">+ Nueva poliza</button>
        </div>

        <div id="polForm" class="hidden bg-slate-950 border border-sky-900 p-4 rounded-xl space-y-3">
            <div class="grid grid-cols-1 sm:grid-cols-4 gap-3">
                <div><label class="block text-[11px] text-slate-400 mb-1">Fecha</label>
                    <input type="date" id="polFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Tipo</label>
                    <select id="polTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        <option>Diario</option><option>Ingreso</option><option>Egreso</option></select></div>
                <div class="sm:col-span-2"><label class="block text-[11px] text-slate-400 mb-1">Concepto</label>
                    <input type="text" id="polConcepto" placeholder="Descripcion del asiento" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
            </div>
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr><th class="p-2 w-2/5">Cuenta</th><th class="p-2">Concepto</th><th class="p-2 text-right">Cargo</th><th class="p-2 text-right">Abono</th><th class="p-2"></th></tr>
                    </thead>
                    <tbody id="polLineasBody"></tbody>
                    <tfoot class="border-t border-slate-800 bg-slate-900/60">
                        <tr class="font-mono">
                            <td class="p-2 text-right text-slate-400" colspan="2">Totales</td>
                            <td class="p-2 text-right" id="polSumCargo">$0.00</td>
                            <td class="p-2 text-right" id="polSumAbono">$0.00</td>
                            <td class="p-2"></td>
                        </tr>
                        <tr><td class="p-2 text-right text-slate-400" colspan="2">Diferencia</td>
                            <td class="p-2 text-right font-mono" id="polDif" colspan="2">$0.00</td><td></td></tr>
                    </tfoot>
                </table>
            </div>
            <div class="flex flex-wrap gap-2">
                <button type="button" id="polAddLinea" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">+ renglon</button>
                <button type="button" id="polGuardar" class="text-xs bg-sky-600 hover:bg-sky-500 disabled:opacity-40 disabled:cursor-not-allowed text-white px-4 py-1.5 rounded-lg cursor-pointer">Guardar poliza</button>
                <button type="button" id="polCancelarForm" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">Cerrar</button>
                <span id="polFormMsg" class="text-xs self-center"></span>
            </div>
        </div>

        <div id="polLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando polizas...</div>
    </div>`;

    document.getElementById('polDesde').value = primerDiaMesISO();
    document.getElementById('polHasta').value = hoyISO();
    document.getElementById('polFecha').value = hoyISO();

    polCablear();
    await polCargarCuentas();
    await polBuscar();
}

function polCablear() {
    const $ = (id) => document.getElementById(id);
    $('polBuscarBtn').addEventListener('click', polBuscar);
    $('polNuevaBtn').addEventListener('click', () => {
        const f = $('polForm');
        f.classList.toggle('hidden');
        if (!f.classList.contains('hidden') && polLineas.length === 0) {
            polLineas = [nuevaLinea(), nuevaLinea()];
            renderLineas();
        }
    });
    $('polCancelarForm').addEventListener('click', () => { $('polForm').classList.add('hidden'); });
    $('polAddLinea').addEventListener('click', () => { polLineas.push(nuevaLinea()); renderLineas(); });
    $('polGuardar').addEventListener('click', guardarPoliza);
}

function nuevaLinea() { return { cuenta_id: '', concepto: '', cargo: '', abono: '' }; }

async function polCargarCuentas() {
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('id, codigo, nombre, tipo, afectable, activa')
            .eq('afectable', true).eq('activa', true)
            .order('codigo', { ascending: true });
        if (error) throw error;
        polCuentas = data || [];
        polCuentasMapa = new Map(polCuentas.map((c) => [c.id, c]));
    } catch (err) {
        console.error('Error al cargar cuentas para polizas:', err);
    }
}

function opcionesCuenta(sel) {
    const grupos = {};
    for (const c of polCuentas) (grupos[c.tipo] ||= []).push(c);
    let html = `<option value="">— cuenta —</option>`;
    for (const [tipo, arr] of Object.entries(grupos)) {
        html += `<optgroup label="${TIPO_LABEL[tipo] || tipo}">`;
        html += arr.map((c) => `<option value="${c.id}" ${String(c.id) === String(sel) ? 'selected' : ''}>${c.codigo} · ${c.nombre}</option>`).join('');
        html += `</optgroup>`;
    }
    return html;
}

function renderLineas() {
    const body = document.getElementById('polLineasBody');
    body.innerHTML = polLineas.map((l, i) => `
        <tr class="border-b border-slate-900">
            <td class="p-1"><select data-i="${i}" data-f="cuenta_id" class="pol-l w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-xs text-slate-100">${opcionesCuenta(l.cuenta_id)}</select></td>
            <td class="p-1"><input data-i="${i}" data-f="concepto" value="${(l.concepto || '').replace(/"/g, '&quot;')}" class="pol-l w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-xs text-slate-100"></td>
            <td class="p-1"><input data-i="${i}" data-f="cargo" type="number" step="0.01" min="0" value="${l.cargo}" class="pol-l w-24 bg-slate-900 border border-slate-800 rounded p-1.5 text-xs text-slate-100 text-right font-mono"></td>
            <td class="p-1"><input data-i="${i}" data-f="abono" type="number" step="0.01" min="0" value="${l.abono}" class="pol-l w-24 bg-slate-900 border border-slate-800 rounded p-1.5 text-xs text-slate-100 text-right font-mono"></td>
            <td class="p-1 text-center"><button type="button" data-del="${i}" class="pol-del text-rose-400 hover:text-rose-300 text-xs px-1.5">✕</button></td>
        </tr>`).join('');

    body.querySelectorAll('.pol-l').forEach((el) => {
        el.addEventListener('input', (e) => {
            const { i, f } = e.target.dataset;
            polLineas[i][f] = e.target.value;
            if (f === 'cargo' && parseFloat(e.target.value) > 0) polLineas[i].abono = '';
            if (f === 'abono' && parseFloat(e.target.value) > 0) polLineas[i].cargo = '';
            recalcularTotales();
        });
        el.addEventListener('change', (e) => {
            if (e.target.dataset.f === 'cargo' || e.target.dataset.f === 'abono') renderLineas();
        });
    });
    body.querySelectorAll('.pol-del').forEach((b) => b.addEventListener('click', () => {
        polLineas.splice(Number(b.dataset.del), 1);
        if (polLineas.length === 0) polLineas.push(nuevaLinea());
        renderLineas();
    }));

    recalcularTotales();
}

function recalcularTotales() {
    const sc = polLineas.reduce((a, l) => a + (parseFloat(l.cargo) || 0), 0);
    const sa = polLineas.reduce((a, l) => a + (parseFloat(l.abono) || 0), 0);
    const dif = Math.round((sc - sa) * 100) / 100;
    document.getElementById('polSumCargo').textContent = money(sc);
    document.getElementById('polSumAbono').textContent = money(sa);
    const difEl = document.getElementById('polDif');
    difEl.textContent = money(dif);
    difEl.className = 'p-2 text-right font-mono ' + (dif === 0 && sc > 0 ? 'text-emerald-400' : 'text-rose-400');

    const validas = polLineas.filter((l) => l.cuenta_id && ((parseFloat(l.cargo) || 0) > 0 || (parseFloat(l.abono) || 0) > 0));
    document.getElementById('polGuardar').disabled = !(dif === 0 && sc > 0 && validas.length >= 2);
}

async function guardarPoliza() {
    const msg = document.getElementById('polFormMsg');
    msg.textContent = ''; msg.className = 'text-xs self-center';

    const movimientos = polLineas
        .filter((l) => l.cuenta_id && ((parseFloat(l.cargo) || 0) > 0 || (parseFloat(l.abono) || 0) > 0))
        .map((l) => ({
            cuenta_id: Number(l.cuenta_id),
            cargo: parseFloat(l.cargo) || 0,
            abono: parseFloat(l.abono) || 0,
            concepto: l.concepto || null,
        }));

    const p_datos = {
        fecha: document.getElementById('polFecha').value,
        tipo: document.getElementById('polTipo').value,
        concepto: document.getElementById('polConcepto').value.trim(),
        origen: 'manual',
        movimientos,
    };

    try {
        document.getElementById('polGuardar').disabled = true;
        const { data, error } = await supabaseClient.rpc('registrar_poliza', { p_datos });
        if (error) throw error;
        msg.textContent = `Poliza ${p_datos.tipo} #${data.numero} registrada.`;
        msg.className = 'text-xs self-center text-emerald-400';
        polLineas = [nuevaLinea(), nuevaLinea()];
        document.getElementById('polConcepto').value = '';
        renderLineas();
        await polBuscar();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs self-center text-rose-400';
        recalcularTotales();
    }
}

async function polBuscar() {
    const cont = document.getElementById('polLista');
    cont.innerHTML = `<p class="text-slate-500">Buscando...</p>`;
    try {
        let q = supabaseClient
            .from('polizas')
            .select('*, poliza_movimientos(id, orden, cuenta_id, cargo, abono, concepto)')
            .gte('fecha', document.getElementById('polDesde').value)
            .lte('fecha', document.getElementById('polHasta').value)
            .order('fecha', { ascending: false })
            .order('id', { ascending: false })
            .limit(300);
        const tf = document.getElementById('polTipoF').value;
        const ef = document.getElementById('polEstatusF').value;
        if (tf) q = q.eq('tipo', tf);
        if (ef) q = q.eq('estatus', ef);

        const { data, error } = await q;
        if (error) throw error;

        if (!data || data.length === 0) {
            cont.innerHTML = `<p class="text-slate-400 text-sm">Sin polizas en el rango.</p>`;
            return;
        }

        cont.innerHTML = `
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr><th class="p-2">Fecha</th><th class="p-2">Poliza</th><th class="p-2">Concepto</th>
                            <th class="p-2 text-right">Importe</th><th class="p-2">Estatus</th><th class="p-2">Origen</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((p) => renderFilaPoliza(p)).join('')}
                    </tbody>
                </table>
            </div>`;

        cont.querySelectorAll('.pol-row').forEach((tr) => tr.addEventListener('click', (e) => {
            if (e.target.closest('.pol-cancel')) return;
            polExpandida = polExpandida === Number(tr.dataset.id) ? null : Number(tr.dataset.id);
            polBuscarRerender(data);
        }));
        cont.querySelectorAll('.pol-cancel').forEach((b) => b.addEventListener('click', () => cancelarPoliza(Number(b.dataset.id))));
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar polizas. ¿Corriste <span class="font-mono">sql/2026-08-28_contabilidad_polizas.sql</span>?<br>${err.message || err}</p>`;
    }
}

function polBuscarRerender(data) {
    const cont = document.getElementById('polLista');
    const tbody = cont.querySelector('tbody');
    if (!tbody) return;
    tbody.innerHTML = data.map((p) => renderFilaPoliza(p)).join('');
    tbody.querySelectorAll('.pol-row').forEach((tr) => tr.addEventListener('click', (e) => {
        if (e.target.closest('.pol-cancel')) return;
        polExpandida = polExpandida === Number(tr.dataset.id) ? null : Number(tr.dataset.id);
        polBuscarRerender(data);
    }));
    tbody.querySelectorAll('.pol-cancel').forEach((b) => b.addEventListener('click', () => cancelarPoliza(Number(b.dataset.id))));
}

function renderFilaPoliza(p) {
    const total = (p.poliza_movimientos || []).reduce((a, m) => a + Number(m.cargo || 0), 0);
    const estColor = p.estatus === 'contabilizada' ? 'text-emerald-400' : p.estatus === 'cancelada' ? 'text-rose-400' : 'text-amber-400';
    let html = `
        <tr class="pol-row border-b border-slate-900 hover:bg-slate-900/40 cursor-pointer ${p.estatus === 'cancelada' ? 'opacity-50' : ''}" data-id="${p.id}">
            <td class="p-2 whitespace-nowrap">${p.fecha}</td>
            <td class="p-2 font-mono">${p.tipo} #${p.numero}</td>
            <td class="p-2">${p.concepto || ''}</td>
            <td class="p-2 text-right font-mono">${money(total)}</td>
            <td class="p-2 ${estColor}">${p.estatus}</td>
            <td class="p-2 text-slate-500">${p.origen}</td>
        </tr>`;
    if (polExpandida === p.id) {
        const movs = (p.poliza_movimientos || []).slice().sort((a, b) => (a.orden || 0) - (b.orden || 0));
        html += `
        <tr class="bg-slate-900/40"><td colspan="6" class="p-3">
            <table class="w-full text-[11px] text-slate-300">
                <thead class="text-slate-500 uppercase"><tr><th class="p-1 text-left">Cuenta</th><th class="p-1 text-left">Concepto</th><th class="p-1 text-right">Cargo</th><th class="p-1 text-right">Abono</th></tr></thead>
                <tbody>
                    ${movs.map((m) => {
                        const c = polCuentasMapa.get(m.cuenta_id);
                        return `<tr>
                            <td class="p-1 font-mono">${c ? c.codigo + ' · ' + c.nombre : 'cuenta ' + m.cuenta_id}</td>
                            <td class="p-1">${m.concepto || ''}</td>
                            <td class="p-1 text-right font-mono">${Number(m.cargo) ? money(m.cargo) : ''}</td>
                            <td class="p-1 text-right font-mono">${Number(m.abono) ? money(m.abono) : ''}</td>
                        </tr>`;
                    }).join('')}
                </tbody>
            </table>
            ${p.estatus === 'contabilizada'
                ? `<button type="button" data-id="${p.id}" class="pol-cancel mt-2 text-[11px] bg-rose-950 hover:bg-rose-900 text-rose-300 px-3 py-1 rounded border border-rose-900 cursor-pointer">Cancelar poliza (genera reverso)</button>`
                : ''}
        </td></tr>`;
    }
    return html;
}

async function cancelarPoliza(id) {
    const motivo = prompt('Motivo de la cancelacion (opcional):', '');
    if (motivo === null) return;
    try {
        const { error } = await supabaseClient.rpc('cancelar_poliza', { p_poliza_id: id, p_motivo: motivo || null });
        if (error) throw error;
        polExpandida = null;
        await polBuscar();
    } catch (err) {
        alert('No se pudo cancelar: ' + (err.message || err));
    }
}

// =====================================================================
//  Contabilidad - FASE 3: Gastos
//  Captura de gastos (factura de proveedor sin inventario). Al guardar,
//  el RPC registrar_gasto inserta el gasto y postea su poliza de Egreso.
//  Requiere: sql/2026-08-28_contabilidad_gastos.sql
// =====================================================================

let gaProveedores = [];
let gaCtasGasto = [];   // cuentas tipo gasto/costo, afectables
let gaCtasPago = [];    // cuentas de caja/banco (101x / 102x)

export async function cargarModuloGastos() {
    const cont = document.getElementById('contenedorGastos');
    if (!cont) return;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Formulario -->
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <h3 class="text-md font-semibold text-sky-400">Registrar gasto</h3>
            <form id="gaForm" class="space-y-3">
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Fecha</label>
                        <input type="date" id="gaFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Condicion</label>
                        <select id="gaCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="contado">Contado</option><option value="credito">Credito (por pagar)</option>
                        </select></div>
                </div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Concepto <span class="text-rose-400">*</span></label>
                    <input type="text" id="gaConcepto" placeholder="Renta local agosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Proveedor</label>
                    <select id="gaProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">(sin proveedor)</option></select></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de gasto <span class="text-rose-400">*</span></label>
                    <select id="gaCuentaGasto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></select></div>

                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Subtotal</label>
                        <input type="number" step="0.01" min="0" id="gaSubtotal" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">IVA <button type="button" id="gaIva16" class="text-[10px] text-sky-400 hover:underline">16%</button></label>
                        <input type="number" step="0.01" min="0" id="gaIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">IEPS</label>
                        <input type="number" step="0.01" min="0" id="gaIeps" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Ret. IVA</label>
                        <input type="number" step="0.01" min="0" id="gaRetIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Ret. ISR</label>
                        <input type="number" step="0.01" min="0" id="gaRetIsr" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Total</label>
                        <input type="text" id="gaTotal" readonly class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-emerald-400 text-right font-mono" value="$0.00"></div>
                </div>

                <div id="gaPagoWrap">
                    <label class="block text-[11px] text-slate-400 mb-1">Pagado desde (caja / banco)</label>
                    <select id="gaCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Forma de pago</label>
                        <select id="gaFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">—</option><option>efectivo</option><option>transferencia</option><option>tarjeta</option><option>cheque</option>
                        </select></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Folio factura</label>
                        <input type="text" id="gaFolio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">UUID CFDI</label>
                        <input type="text" id="gaUuid" placeholder="folio fiscal" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">RFC emisor</label>
                        <input type="text" id="gaRfc" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                </div>
                <button type="submit" id="gaGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Guardar gasto</button>
                <p id="gaMsg" class="text-xs min-h-[1rem]"></p>
            </form>
        </div>

        <!-- Listado -->
        <div class="xl:col-span-2 space-y-3">
            <div class="flex flex-wrap items-end gap-3">
                <div><label class="block text-[11px] text-slate-400 mb-1">Desde</label>
                    <input type="date" id="gaDesde" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Hasta</label>
                    <input type="date" id="gaHasta" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
                <button type="button" id="gaBuscar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">Buscar</button>
                <span id="gaTotales" class="ml-auto text-xs text-slate-400 self-center"></span>
            </div>
            <div id="gaLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando gastos...</div>
        </div>
    </div>`;

    document.getElementById('gaFecha').value = hoyISO();
    document.getElementById('gaDesde').value = primerDiaMesISO();
    document.getElementById('gaHasta').value = hoyISO();

    gaCablear();
    await gaCargarCatalogos();
    await gaBuscar();
}

function gaCablear() {
    const $ = (id) => document.getElementById(id);
    ['gaSubtotal', 'gaIva', 'gaIeps', 'gaRetIva', 'gaRetIsr'].forEach((id) => $(id).addEventListener('input', gaCalcTotal));
    $('gaIva16').addEventListener('click', () => {
        const st = parseFloat($('gaSubtotal').value) || 0;
        $('gaIva').value = (Math.round(st * 16) / 100).toFixed(2);
        gaCalcTotal();
    });
    $('gaCondicion').addEventListener('change', () => {
        $('gaPagoWrap').style.display = $('gaCondicion').value === 'contado' ? '' : 'none';
    });
    $('gaForm').addEventListener('submit', gaGuardar);
    $('gaBuscar').addEventListener('click', gaBuscar);
}

function gaCalcTotal() {
    const n = (id) => parseFloat(document.getElementById(id).value) || 0;
    const total = n('gaSubtotal') + n('gaIva') + n('gaIeps') - n('gaRetIva') - n('gaRetIsr');
    document.getElementById('gaTotal').value = money(total);
}

async function gaCargarCatalogos() {
    try {
        const [prov, ctas] = await Promise.all([
            supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo, afectable, activa').eq('afectable', true).eq('activa', true).order('codigo'),
        ]);
        if (prov.error) throw prov.error;
        if (ctas.error) throw ctas.error;

        gaProveedores = prov.data || [];
        const todas = ctas.data || [];
        gaCtasGasto = todas.filter((c) => c.tipo === 'gasto' || c.tipo === 'costo');
        gaCtasPago = todas.filter((c) => c.tipo === 'activo' && /^(101|102)/.test(c.codigo));

        document.getElementById('gaProveedor').innerHTML = `<option value="">(sin proveedor)</option>` +
            gaProveedores.map((p) => `<option value="${p.id}">${p.nombre}</option>`).join('');
        document.getElementById('gaCuentaGasto').innerHTML = `<option value="">— cuenta de gasto —</option>` +
            gaCtasGasto.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
        document.getElementById('gaCuentaPago').innerHTML = `<option value="">— caja / banco —</option>` +
            gaCtasPago.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
    } catch (err) {
        console.error('Error al cargar catalogos de gastos:', err);
        document.getElementById('gaLista').innerHTML =
            `<p class="text-rose-400 text-xs">¿Corriste los 3 SQL de contabilidad en Supabase?<br>${err.message || err}</p>`;
    }
}

async function gaGuardar(e) {
    e.preventDefault();
    const msg = document.getElementById('gaMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';
    const $ = (id) => document.getElementById(id);
    const num = (id) => parseFloat($(id).value) || 0;

    const condicion = $('gaCondicion').value;
    const p_datos = {
        fecha: $('gaFecha').value,
        concepto: $('gaConcepto').value.trim(),
        proveedor_id: $('gaProveedor').value ? Number($('gaProveedor').value) : null,
        cuenta_gasto_id: $('gaCuentaGasto').value ? Number($('gaCuentaGasto').value) : null,
        subtotal: num('gaSubtotal'),
        iva: num('gaIva'),
        ieps: num('gaIeps'),
        ret_iva: num('gaRetIva'),
        ret_isr: num('gaRetIsr'),
        condicion,
        forma_pago: $('gaFormaPago').value || null,
        cuenta_pago_id: condicion === 'contado' && $('gaCuentaPago').value ? Number($('gaCuentaPago').value) : null,
        folio_factura: $('gaFolio').value.trim() || null,
        uuid_cfdi: $('gaUuid').value.trim() || null,
        rfc_emisor: $('gaRfc').value.trim() || null,
    };
    if (!p_datos.concepto || !p_datos.cuenta_gasto_id || p_datos.subtotal <= 0) {
        msg.textContent = 'Faltan concepto, cuenta de gasto o subtotal.'; msg.className = 'text-xs text-rose-400'; return;
    }

    try {
        $('gaGuardar').disabled = true;
        const { data, error } = await supabaseClient.rpc('registrar_gasto', { p_datos });
        if (error) throw error;
        msg.textContent = `Gasto #${data.gasto_id} registrado — poliza Egreso generada (total ${money(data.total)}).`;
        msg.className = 'text-xs text-emerald-400';
        $('gaForm').reset();
        $('gaFecha').value = hoyISO();
        $('gaCondicion').value = condicion;
        $('gaPagoWrap').style.display = condicion === 'contado' ? '' : 'none';
        gaCalcTotal();
        await gaBuscar();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs text-rose-400';
    } finally {
        $('gaGuardar').disabled = false;
    }
}

async function gaBuscar() {
    const cont = document.getElementById('gaLista');
    cont.innerHTML = `<p class="text-slate-500">Buscando...</p>`;
    try {
        const { data, error } = await supabaseClient
            .from('gastos')
            .select('*, proveedores(nombre), cuentas_contables!cuenta_gasto_id(codigo, nombre), polizas(tipo, numero, estatus)')
            .gte('fecha', document.getElementById('gaDesde').value)
            .lte('fecha', document.getElementById('gaHasta').value)
            .order('fecha', { ascending: false }).order('id', { ascending: false })
            .limit(300);
        if (error) throw error;

        if (!data || data.length === 0) {
            cont.innerHTML = `<p class="text-slate-400 text-sm">Sin gastos en el rango.</p>`;
            document.getElementById('gaTotales').textContent = '';
            return;
        }

        const totVigentes = data.filter((g) => g.estatus === 'registrado').reduce((a, g) => a + Number(g.total || 0), 0);
        document.getElementById('gaTotales').textContent = `Total registrado: ${money(totVigentes)}  ·  ${data.length} gasto(s)`;

        cont.innerHTML = `
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr><th class="p-2">Fecha</th><th class="p-2">Concepto</th><th class="p-2">Proveedor</th>
                            <th class="p-2">Cuenta</th><th class="p-2 text-right">Total</th><th class="p-2">Poliza</th>
                            <th class="p-2">Estatus</th><th class="p-2 text-right">Accion</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((g) => `
                            <tr class="border-b border-slate-900 ${g.estatus === 'cancelado' ? 'opacity-50' : ''}">
                                <td class="p-2 whitespace-nowrap">${g.fecha}</td>
                                <td class="p-2">${g.concepto}</td>
                                <td class="p-2 text-slate-400">${g.proveedores?.nombre || '—'}</td>
                                <td class="p-2 font-mono text-slate-500">${g.cuentas_contables ? g.cuentas_contables.codigo : '—'}</td>
                                <td class="p-2 text-right font-mono">${money(g.total)}</td>
                                <td class="p-2 font-mono text-slate-500">${g.polizas ? g.polizas.tipo + ' #' + g.polizas.numero : '—'}</td>
                                <td class="p-2 ${g.estatus === 'registrado' ? 'text-emerald-400' : 'text-rose-400'}">${g.estatus}</td>
                                <td class="p-2 text-right">
                                    ${g.estatus === 'registrado'
                                        ? `<button data-cancel="${g.id}" class="ga-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Cancelar</button>`
                                        : ''}
                                </td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>`;

        cont.querySelectorAll('.ga-cancel').forEach((b) => b.addEventListener('click', () => gaCancelar(Number(b.dataset.cancel))));
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar gastos. ¿Corriste <span class="font-mono">sql/2026-08-28_contabilidad_gastos.sql</span>?<br>${err.message || err}</p>`;
    }
}

async function gaCancelar(id) {
    if (!confirm('¿Cancelar este gasto? Se generara la poliza de reverso.')) return;
    try {
        const { error } = await supabaseClient.rpc('cancelar_gasto', { p_gasto_id: id });
        if (error) throw error;
        await gaBuscar();
    } catch (err) {
        alert('No se pudo cancelar: ' + (err.message || err));
    }
}

// =====================================================================
//  Contabilidad - FASE 5: Reportes contables
//  Balanza de comprobacion + Estado de resultados, a partir de las
//  polizas 'contabilizada'. Requiere: fases 1 y 2.
// =====================================================================

const primerDiaAnioISO = () => new Date(new Date().getFullYear(), 0, 1).toISOString().slice(0, 10);
const rcFmt = (n) => {
    const v = Math.round((Number(n) || 0) * 100) / 100;
    const s = Math.abs(v).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return v < 0 ? `(${s})` : s;
};

let rcTab = 'balanza';
let rcCache = null; // { desde, hasta, ctas, movs }

export async function cargarModuloReportesContables() {
    const cont = document.getElementById('contenedorReportesContables');
    if (!cont) return;

    cont.innerHTML = `
    <div class="space-y-4">
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl flex flex-wrap items-end gap-3">
            <div><label class="block text-[11px] text-slate-400 mb-1">Desde</label>
                <input type="date" id="rcDesde" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Hasta</label>
                <input type="date" id="rcHasta" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <button type="button" id="rcGenerar" class="text-xs bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg font-semibold cursor-pointer">Generar</button>
            <div class="ml-auto flex gap-2">
                <button type="button" id="rcCsv" class="text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">Exportar CSV</button>
                <button type="button" id="rcPrint" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">Imprimir</button>
            </div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-1 flex flex-wrap gap-1" id="rcTabs"></div>
        <div id="rcResultado" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Elige el periodo y pulsa Generar.</div>
    </div>`;

    document.getElementById('rcDesde').value = primerDiaAnioISO();
    document.getElementById('rcHasta').value = hoyISO();
    rcRenderTabs();

    document.getElementById('rcGenerar').addEventListener('click', () => rcGenerar(true));
    document.getElementById('rcCsv').addEventListener('click', rcExportarCSV);
    document.getElementById('rcPrint').addEventListener('click', () => {
        const titulo = rcTab === 'balanza' ? 'Balanza de comprobacion' : 'Estado de resultados';
        imprimirConPlantilla('generico', titulo, 'rcTabla');
    });

    await rcGenerar(true);
}

function rcRenderTabs() {
    const el = document.getElementById('rcTabs');
    const tabs = [{ id: 'balanza', t: 'Balanza de comprobación' }, { id: 'resultados', t: 'Estado de resultados' }];
    el.innerHTML = tabs.map((x) => `
        <button data-tab="${x.id}" class="rc-tab text-xs font-semibold px-3 py-2 rounded-lg transition ${x.id === rcTab ? 'bg-sky-600 text-white' : 'text-slate-400 hover:bg-slate-800'}" style="cursor:pointer">${x.t}</button>`).join('');
    el.querySelectorAll('.rc-tab').forEach((b) => b.addEventListener('click', () => { rcTab = b.dataset.tab; rcRenderTabs(); rcPintar(); }));
}

async function rcGenerar(forzar) {
    const desde = document.getElementById('rcDesde').value;
    const hasta = document.getElementById('rcHasta').value;
    if (!desde || !hasta) { alert('Indica el periodo.'); return; }
    const res = document.getElementById('rcResultado');

    if (forzar || !rcCache || rcCache.desde !== desde || rcCache.hasta !== hasta) {
        res.innerHTML = '<p class="text-slate-500">Consultando pólizas...</p>';
        try {
            const [ctasR, movsR] = await Promise.all([
                supabaseClient.from('cuentas_contables')
                    .select('id, codigo, nombre, tipo, naturaleza, nivel, cuenta_padre_id, afectable')
                    .order('codigo', { ascending: true }),
                supabaseClient.from('poliza_movimientos')
                    .select('cuenta_id, cargo, abono, polizas!inner(fecha, estatus)')
                    .eq('polizas.estatus', 'contabilizada')
                    .lte('polizas.fecha', hasta)
                    .limit(50000),
            ]);
            if (ctasR.error) throw ctasR.error;
            if (movsR.error) throw movsR.error;
            const movs = movsR.data || [];
            rcCache = { desde, hasta, ctas: ctasR.data || [], movs, truncado: movs.length >= 1000 };
        } catch (err) {
            res.innerHTML = `<p class="text-rose-400 text-xs">No se pudo generar. ¿Corriste los SQL de contabilidad (fases 1-2)?<br>${err.message || err}</p>`;
            rcCache = null;
            return;
        }
    }
    rcPintar();
}

// Acumula por cuenta: saldo inicial (antes de 'desde') y movimientos del periodo.
function rcAcumular() {
    const { desde, hasta, ctas, movs } = rcCache;
    const porCuenta = new Map(); // id -> { iniC, iniA, perC, perA }
    const get = (id) => {
        if (!porCuenta.has(id)) porCuenta.set(id, { iniC: 0, iniA: 0, perC: 0, perA: 0 });
        return porCuenta.get(id);
    };
    for (const m of movs) {
        const f = m.polizas?.fecha;
        const a = get(m.cuenta_id);
        const c = Number(m.cargo) || 0, ab = Number(m.abono) || 0;
        if (f < desde) { a.iniC += c; a.iniA += ab; }
        else if (f <= hasta) { a.perC += c; a.perA += ab; }
    }
    return { ctas, porCuenta };
}

function rcPintar() {
    if (!rcCache) return;
    if (rcTab === 'balanza') rcPintarBalanza();
    else rcPintarResultados();
    if (rcCache.truncado) {
        const res = document.getElementById('rcResultado');
        res.insertAdjacentHTML('afterbegin',
            '<p class="text-amber-400 text-[11px] mb-2">⚠ Se alcanzó el tope de 1000 movimientos; el reporte puede estar incompleto. Acota el periodo o pide la versión con RPC.</p>');
    }
}

function rcPintarBalanza() {
    const res = document.getElementById('rcResultado');
    const { ctas, porCuenta } = rcAcumular();
    const afect = ctas.filter((c) => c.afectable);

    let tIni = 0, tCargo = 0, tAbono = 0, tFin = 0;
    const filas = afect.map((c) => {
        const a = porCuenta.get(c.id) || { iniC: 0, iniA: 0, perC: 0, perA: 0 };
        const saldoIni = a.iniC - a.iniA;                 // + deudor / - acreedor
        const saldoFin = saldoIni + a.perC - a.perA;
        tIni += saldoIni; tCargo += a.perC; tAbono += a.perA; tFin += saldoFin;
        return { c, saldoIni, cargo: a.perC, abono: a.perA, saldoFin };
    }).filter((r) => r.saldoIni || r.cargo || r.abono || r.saldoFin);

    if (filas.length === 0) { res.innerHTML = '<p class="text-slate-400">Sin movimientos contabilizados en el periodo.</p>'; return; }

    res.innerHTML = `
        <div id="rcTabla" class="overflow-x-auto">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-sky-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr><th class="p-2">Código</th><th class="p-2">Cuenta</th>
                        <th class="p-2 text-right">Saldo inicial</th><th class="p-2 text-right">Cargos</th>
                        <th class="p-2 text-right">Abonos</th><th class="p-2 text-right">Saldo final</th></tr>
                </thead>
                <tbody>
                    ${filas.map((r) => `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 font-mono text-slate-400">${r.c.codigo}</td>
                            <td class="p-2">${r.c.nombre}</td>
                            <td class="p-2 text-right font-mono ${r.saldoIni < 0 ? 'text-rose-400' : ''}">${rcFmt(r.saldoIni)}</td>
                            <td class="p-2 text-right font-mono">${rcFmt(r.cargo)}</td>
                            <td class="p-2 text-right font-mono">${rcFmt(r.abono)}</td>
                            <td class="p-2 text-right font-mono ${r.saldoFin < 0 ? 'text-rose-400' : ''}">${rcFmt(r.saldoFin)}</td>
                        </tr>`).join('')}
                </tbody>
                <tfoot class="bg-slate-900 font-semibold border-t border-slate-700">
                    <tr>
                        <td class="p-2" colspan="2">Totales</td>
                        <td class="p-2 text-right font-mono ${Math.abs(tIni) > 0.005 ? 'text-rose-400' : 'text-emerald-400'}">${rcFmt(tIni)}</td>
                        <td class="p-2 text-right font-mono">${rcFmt(tCargo)}</td>
                        <td class="p-2 text-right font-mono">${rcFmt(tAbono)}</td>
                        <td class="p-2 text-right font-mono ${Math.abs(tFin) > 0.005 ? 'text-rose-400' : 'text-emerald-400'}">${rcFmt(tFin)}</td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <p class="text-[11px] text-slate-500 mt-2">Saldo inicial = movimientos anteriores a ${rcCache.desde}. Positivo = deudor, (rojo) = acreedor. Los totales de saldo deben dar 0 si la contabilidad cuadra.</p>`;
}

function rcPintarResultados() {
    const res = document.getElementById('rcResultado');
    const { ctas, porCuenta } = rcAcumular();
    const netoPeriodo = (c) => {
        const a = porCuenta.get(c.id) || { perC: 0, perA: 0 };
        return c.naturaleza === 'A' ? (a.perA - a.perC) : (a.perC - a.perA);
    };

    const bloque = (tipo) => {
        const items = ctas.filter((c) => c.afectable && c.tipo === tipo)
            .map((c) => ({ c, monto: netoPeriodo(c) }))
            .filter((x) => Math.abs(x.monto) > 0.005);
        const total = items.reduce((s, x) => s + x.monto, 0);
        return { items, total };
    };

    const ing = bloque('ingreso');
    const cos = bloque('costo');
    const gas = bloque('gasto');
    const utilidadBruta = ing.total - cos.total;
    const resultado = utilidadBruta - gas.total;

    const seccion = (titulo, b) => `
        <tr class="bg-slate-900/60"><td class="p-2 font-semibold text-sky-400" colspan="2">${titulo}</td></tr>
        ${b.items.map((x) => `<tr class="border-b border-slate-900"><td class="p-2 pl-6"><span class="font-mono text-slate-500">${x.c.codigo}</span> ${x.c.nombre}</td><td class="p-2 text-right font-mono">${rcFmt(x.monto)}</td></tr>`).join('') || '<tr><td class="p-2 pl-6 text-slate-600" colspan="2">(sin movimientos)</td></tr>'}
        <tr class="border-b border-slate-800"><td class="p-2 pl-6 font-semibold">Total ${titulo.toLowerCase()}</td><td class="p-2 text-right font-mono font-semibold">${rcFmt(b.total)}</td></tr>`;

    res.innerHTML = `
        <div id="rcTabla" class="overflow-x-auto">
            <table class="w-full text-left text-xs text-slate-300 max-w-2xl">
                <thead class="bg-slate-900 text-sky-400 uppercase border-b border-slate-800">
                    <tr><th class="p-2">Concepto (${rcCache.desde} a ${rcCache.hasta})</th><th class="p-2 text-right">Importe</th></tr>
                </thead>
                <tbody>
                    ${seccion('Ingresos', ing)}
                    ${seccion('Costos', cos)}
                    <tr class="bg-slate-800/40"><td class="p-2 font-semibold">Utilidad bruta</td><td class="p-2 text-right font-mono font-semibold ${utilidadBruta < 0 ? 'text-rose-400' : 'text-emerald-400'}">${rcFmt(utilidadBruta)}</td></tr>
                    ${seccion('Gastos', gas)}
                    <tr class="bg-slate-800 text-base"><td class="p-3 font-bold">Utilidad (pérdida) de operación</td><td class="p-3 text-right font-mono font-bold ${resultado < 0 ? 'text-rose-400' : 'text-emerald-400'}">${rcFmt(resultado)}</td></tr>
                </tbody>
            </table>
        </div>`;
}

function rcExportarCSV() {
    const tabla = document.querySelector('#rcTabla table');
    if (!tabla) { alert('Genera primero un reporte.'); return; }
    const filas = [];
    tabla.querySelectorAll('tr').forEach((tr) => {
        filas.push([...tr.children].map((td) => {
            const s = (td.textContent || '').trim().replace(/\s+/g, ' ');
            return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
        }).join(','));
    });
    const csv = '﻿' + filas.join('\r\n');
    const a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8;' }));
    a.download = `${rcTab === 'balanza' ? 'balanza' : 'estado_resultados'}_${document.getElementById('rcHasta').value}.csv`;
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}
