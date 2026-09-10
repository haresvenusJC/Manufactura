import { supabaseClient } from './supabase.js';
import { imprimirConPlantilla } from './impresion.js';
import { montarGuia, crearPanelAsistente, abrirManual } from './asistente-contable.js';
import { parsearCfdi, formaPagoSimple } from './cfdi.js';
import { REGIMENES } from './proveedores.js';

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

    <details class="mt-6 bg-slate-950 border border-slate-800 rounded-xl">
        <summary class="cursor-pointer select-none px-4 py-3 text-md font-semibold text-sky-400">Uso CFDI → cuenta por defecto</summary>
        <div class="px-4 pb-4">
            <p class="text-[11px] text-slate-400 mb-3">Al importar una factura, si el producto no trae cuenta de inventario propia, la contabilización usa la cuenta que asignes aquí al <span class="font-mono">UsoCFDI</span> del CFDI.</p>
            <div id="usoCfdiTabla" class="text-sm text-slate-500">Cargando…</div>
        </div>
    </details>
    `;

    cablear();
    await recargar();
    await cargarMapeoUsoCfdi();
    montarGuia(cont, 'plan-cuentas');
}

async function cargarMapeoUsoCfdi() {
    const cont = document.getElementById('usoCfdiTabla');
    if (!cont) return;
    try {
        const [usoR, ctasR] = await Promise.all([
            supabaseClient.from('c_uso_cfdi').select('clave, descripcion, cuenta_id, activo').order('clave'),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo'),
        ]);
        if (usoR.error) throw usoR.error;
        const usos = usoR.data || [];
        const ctas = ctasR.data || [];
        if (!usos.length) { cont.innerHTML = '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-03_cfdi_catalogos.sql</span> en Supabase.</p>'; return; }

        const opts = (sel) => '<option value="">— sin cuenta —</option>' +
            ctas.map((c) => `<option value="${c.id}" ${String(c.id) === String(sel) ? 'selected' : ''}>${c.codigo} · ${c.nombre}</option>`).join('');

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr><th class="p-2">Clave</th><th class="p-2">Descripción</th><th class="p-2">Cuenta por defecto</th></tr></thead>
            <tbody>
              ${usos.map((u) => `
                <tr class="border-b border-slate-900 ${u.activo === false ? 'opacity-50' : ''}">
                  <td class="p-2 font-mono text-sky-300">${u.clave}</td>
                  <td class="p-2">${u.descripcion}</td>
                  <td class="p-2"><select class="uso-cta bg-slate-900 border border-slate-800 rounded p-1.5 text-xs text-slate-100" data-clave="${u.clave}">${opts(u.cuenta_id)}</select></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;

        cont.querySelectorAll('.uso-cta').forEach((sel) => {
            sel.addEventListener('change', async () => {
                const { error } = await supabaseClient.from('c_uso_cfdi')
                    .update({ cuenta_id: sel.value ? Number(sel.value) : null })
                    .eq('clave', sel.dataset.clave);
                if (error) { alert('No se pudo guardar: ' + error.message); return; }
                sel.classList.add('border-emerald-600');
                setTimeout(() => sel.classList.remove('border-emerald-600'), 800);
            });
        });
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">No disponible: ${err.message || err}</p>`;
    }
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
                            <th class="p-2 text-left">Acciones</th><th class="p-2">Codigo</th><th class="p-2">Nombre</th>
                            <th class="p-2">Agrup. SAT</th><th class="p-2">Nat.</th>
                            <th class="p-2">Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${delTipo.map((c) => `
                            <tr class="border-b border-slate-900 hover:bg-slate-900/40 ${c.activa ? '' : 'opacity-40'}">
                                <td class="p-2 space-x-1">
                                    <button data-edit="${c.id}" class="cta-edit text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Editar</button>
                                    <button data-del="${c.id}" class="cta-del text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Eliminar</button>
                                </td>
                                <td class="p-2 font-mono ${c.afectable ? 'text-slate-300' : 'text-sky-300 font-semibold'}" style="padding-left:${8 + (c.nivel - 1) * 16}px">${c.codigo}</td>
                                <td class="p-2">${c.nombre}${c.activa ? '' : ' <span class="text-slate-600">(inactiva)</span>'}</td>
                                <td class="p-2 font-mono text-slate-500">${c.codigo_agrupador || '—'}</td>
                                <td class="p-2">${c.naturaleza}</td>
                                <td class="p-2">${c.afectable ? '<span class="text-emerald-500">sí</span>' : '<span class="text-slate-600">mayor</span>'}</td>
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
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
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

    // Enfoque a una póliza concreta (link desde Documentos u otras pantallas)
    const polFoco = window.__polFoco;
    window.__polFoco = null;
    polExpandida = null;
    if (polFoco && polFoco.id) {
        document.getElementById('polDesde').value = '2020-01-01';
        document.getElementById('polHasta').value = hoyISO();
        document.getElementById('polTipoF').value = '';
        document.getElementById('polEstatusF').value = '';
        polExpandida = Number(polFoco.id);
    }

    polCablear();
    await polCargarCuentas();
    await polBuscar();

    if (polFoco && polFoco.id) {
        const row = document.querySelector(`.pol-row[data-id="${polFoco.id}"]`);
        if (row) {
            row.scrollIntoView({ block: 'center', behavior: 'smooth' });
            row.classList.add('ring-2', 'ring-sky-500');
            setTimeout(() => row.classList.remove('ring-2', 'ring-sky-500'), 2500);
        } else {
            const cont = document.getElementById('polLista');
            if (cont) cont.insertAdjacentHTML('afterbegin',
                `<p class="text-amber-400 text-xs mb-2">No se encontró la póliza #${polFoco.id} (¿cancelada o el documento no se contabilizó?).</p>`);
        }
    }
    montarGuia(document.getElementById('contenedorPolizas'), 'polizas');
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
        cont.querySelectorAll('.pol-cancel').forEach((b) => b.addEventListener('click', () => cancelarPoliza(Number(b.dataset.id), b.dataset)));
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
    tbody.querySelectorAll('.pol-cancel').forEach((b) => b.addEventListener('click', () => cancelarPoliza(Number(b.dataset.id), b.dataset)));
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
                ? `<button type="button" data-id="${p.id}" data-origen="${esc(p.origen || '')}" data-origtabla="${esc(p.origen_tabla || '')}" data-origid="${p.origen_id || ''}" class="pol-cancel mt-2 text-[11px] bg-rose-950 hover:bg-rose-900 text-rose-300 px-3 py-1 rounded border border-rose-900 cursor-pointer">${p.origen === 'compra' && p.origen_tabla === 'documentos' ? 'Cancelar recibo (revierte inventario + póliza)' : 'Cancelar poliza (genera reverso)'}</button>`
                : ''}
        </td></tr>`;
    }
    return html;
}

async function cancelarPoliza(id, ds) {
    const esRecibo = ds && ds.origen === 'compra' && ds.origtabla === 'documentos' && ds.origid;

    if (esRecibo) {
        const docId = Number(ds.origid);
        // 1) confirmar que es reversible (ningún lote consumido)
        const { data: diag, error: eDiag } = await supabaseClient.rpc('recibo_reversible', { p_documento_id: docId });
        if (eDiag) { alert('No se pudo verificar el recibo #' + docId + ':\n' + (eDiag.message || eDiag)); return; }
        if (!diag || !diag.length) { alert('El recibo #' + docId + ' no tiene movimientos de inventario que revertir.'); return; }

        const consumidos = diag.filter((d) => !d.ok);
        if (consumidos.length) {
            alert('⛔ NO se puede revertir el inventario del recibo #' + docId + ' — ya se consumió stock:\n\n' +
                consumidos.map((d) => `· ${d.producto_nombre} · lote ${d.numero_lote}: recibiste ${d.recibido}, quedan ${d.disponible} (consumido ${d.consumido})`).join('\n') +
                '\n\nPrimero cancela las salidas / órdenes de producción que consumieron esos lotes.');
            return;
        }

        const resumen = diag.map((d) => `· ${d.producto_nombre} · lote ${d.numero_lote}: −${d.recibido}`).join('\n');
        if (!confirm(`✅ El recibo #${docId} SÍ es cancelable: ningún lote se ha consumido.\n\nSe cancelará la póliza (contra-asiento) y se revertirá el inventario:\n${resumen}\n\n¿Continuar?`)) return;

        const motivo = prompt('Motivo de la cancelación:', 'Cancelación de recibo');
        if (motivo === null) return;
        try {
            const { data, error } = await supabaseClient.rpc('cancelar_recibo_inventario', { p_documento_id: docId, p_motivo: motivo || null });
            if (error) throw error;
            const movs = (data && data.movimientos) || [];
            alert('✅ ' + ((data && data.mensaje) || 'Recibo cancelado.') +
                (movs.length ? '\n\nMovimientos revertidos:\n' + movs.map((m) => `· ${m.producto} · lote ${m.lote}: ${m.cantidad} ${m.unidad || ''}`).join('\n') : ''));
            polExpandida = null;
            await polBuscar();
        } catch (err) {
            alert('No se pudo cancelar el recibo: ' + (err.message || err));
        }
        return;
    }

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
let gaCtasGasto = [];   // cuentas tipo gasto/costo, afectables (con cif_tipo)
let gaCtasPago = [];    // cuentas de caja/banco (101x / 102x)
let gaCentros = [];     // centros de costo activos (Fase 1 costos de producción)
let gaOrdenes = [];     // órdenes de producción para gasto directo
let gaPlantillas = [];  // plantillas de reparto (Tanda 2)
let gaBases = [];       // v_bases_prorrateo, para la vista previa del reparto
let gaUmbral = 0;       // umbral de materialidad (costos_config)
let gaCfdiActual = null; // último CFDI importado (para que el asistente sugiera cuenta)
let gaWizGrupo = null;   // grupo del asistente ('prod'|'admin'|'venta'|'fin') para re-sugerir tras importar XML

// globo de ayuda al pasar por encima. Los textos son literales controlados (sin < > " &).
const gHint = (t) => `<span class="hint" tabindex="0" role="note" aria-label="${t}" data-tip="${t}">?</span>`;

export async function cargarModuloGastos() {
    const cont = document.getElementById('contenedorGastos');
    if (!cont) return;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Formulario -->
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <div class="flex items-center justify-between gap-2">
                <h3 class="text-md font-semibold text-sky-400">Registrar gasto</h3>
                <button type="button" id="gaManualBtn" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2.5 py-1 rounded-lg whitespace-nowrap cursor-pointer">📖 Cómo llenar esta pantalla</button>
            </div>
            <form id="gaForm" class="space-y-3">
                <div class="flex items-center gap-2 flex-wrap">
                    <input type="file" id="gaXmlFile" accept=".xml,text/xml,application/xml" class="hidden">
                    <button type="button" id="gaBtnXml" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-2 rounded-lg cursor-pointer">📄 Importar XML del CFDI</button>
                    <span id="gaCfdiInfo" class="text-[11px] text-slate-400"></span>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Fecha${gHint('La fecha de la factura. Define en qué mes se prorratea el gasto.')}</label>
                        <input type="date" id="gaFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Condicion${gHint('Contado = ya lo pagaste. Crédito = queda por pagar (aparece en Cuentas por pagar).')}</label>
                        <select id="gaCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="contado">Contado</option><option value="credito">Credito (por pagar)</option>
                        </select></div>
                </div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Concepto <span class="text-rose-400">*</span>${gHint('Descripción corta y clara. Ej. Renta nave — septiembre, Mantenimiento correctivo mezcladora.')}</label>
                    <input type="text" id="gaConcepto" placeholder="Renta local agosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Proveedor${gHint('El que diste de alta en Compras → Proveedores. Escribe y elígelo de la lista. Si tiene cuenta de gasto por defecto, se pone sola abajo.')}</label>
                    <select id="gaProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">(sin proveedor)</option></select></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de gasto <span class="text-rose-400">*</span>${gHint('El cajón contable donde cae este gasto. Para la renta de planta: 503.05. La lista indica si la cuenta es CIF fijo o variable.')}</label>
                    <select id="gaCuentaGasto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></select></div>

                <div class="border border-slate-800 rounded-lg p-3 bg-slate-900/40 space-y-2">
                    <p class="text-[11px] font-semibold text-sky-400">Costeo de producción${gHint('Dice si este gasto entra al costo de lo que fabricas y cómo. Si no sabes cuál elegir, mira el globo de Clasificación.')}</p>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Clasificación${gHint('¿Sirve a UNA sola orden y lo puedes señalar con el dedo? → Directo a una orden. ¿Sirve a la planta en general (renta, luz, mtto., supervisión)? → Indirecto (CIF). ¿Oficina, ventas o banco? → No producción.')}</label>
                        <select id="gaClasif" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="no_produccion">No producción (admin / venta / financiero)</option>
                            <option value="indirecto_produccion">Indirecto de fabricación (CIF) — se prorratea</option>
                            <option value="directo_produccion">Directo a una orden de producción</option>
                        </select></div>
                    <div id="gaRepartoWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">¿Cómo se reparte?${gHint('Todo a un centro: el gasto es de una sola etapa (mtto. de la llenadora → ENV). Repartir con plantilla: gasto compartido (renta, luz, servicios) que se divide entre SURT/MEZ/ENV y, si aplica, entre fábrica y oficina, según las áreas.')}</label>
                        <select id="gaReparto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="centro_unico">Todo a un centro</option>
                            <option value="plantilla">Repartir con una plantilla</option>
                        </select></div>
                    <div id="gaCentroWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">Centro de costo${gHint('La etapa que acumula este gasto: SURT (surtido), MEZ (mezclado) o ENV (envasado).')}</label>
                        <select id="gaCentro" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select></div>
                    <div id="gaPlantillaWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">Plantilla de reparto${gHint('Define la base (m² / kW / personas) y a qué cuenta de oficina va la parte de no producción. Se administran en Configuración → Reparto de gastos compartidos.')}</label>
                        <select id="gaPlantilla" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select></div>
                    <div id="gaCifTipoWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">Tipo de CIF${gHint('Fijo = el monto es parejo produzcas mucho o poco (renta, depreciación, supervisión). Variable = sube y baja con el volumen (energía, insumos indirectos, mtto. por uso). Se hereda de la cuenta; cámbialo si aplica.')}</label>
                        <select id="gaCifTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">— (según la cuenta) —</option>
                            <option value="fijo">Fijo (renta, depreciación, supervisión)</option>
                            <option value="variable">Variable (energía, insumos indirectos, mtto. por uso)</option>
                        </select></div>
                    <div id="gaOrdenWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">Orden de producción${gHint('La orden concreta a la que se carga este gasto directo. Se sumará a su costo cuando la orden se cierre.')}</label>
                        <select id="gaOrden" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select></div>
                    <div id="gaResumenWrap" class="hidden text-[11px] bg-slate-950 border border-slate-800 rounded-lg p-2 text-slate-400"></div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Subtotal${gHint('El importe antes de impuestos, tal como viene en la factura.')}</label>
                        <input type="number" step="0.01" min="0" id="gaSubtotal" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">IVA <button type="button" id="gaIva16" class="text-[10px] text-sky-400 hover:underline">16%</button>${gHint('El IVA de la factura. El botón 16% lo calcula sobre el subtotal.')}</label>
                        <input type="number" step="0.01" min="0" id="gaIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">IEPS${gHint('Solo si la factura lo trae (bebidas, combustibles, etc.). Normalmente 0.')}</label>
                        <input type="number" step="0.01" min="0" id="gaIeps" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Ret. IVA${gHint('Retención de IVA, solo si la factura la trae (fletes, servicios de personas físicas).')}</label>
                        <input type="number" step="0.01" min="0" id="gaRetIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Ret. ISR${gHint('Retención de ISR, solo si la factura la trae (honorarios, fletes, arrendamiento a persona física).')}</label>
                        <input type="number" step="0.01" min="0" id="gaRetIsr" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Total${gHint('Se calcula solo: subtotal + IVA + IEPS − retenciones. Debe cuadrar con el total de la factura.')}</label>
                        <input type="text" id="gaTotal" readonly class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-emerald-400 text-right font-mono" value="$0.00"></div>
                </div>

                <div id="gaPagoWrap">
                    <label class="block text-[11px] text-slate-400 mb-1">Pagado desde (caja / banco)${gHint('La cuenta de caja o banco de donde salió el pago. Solo aplica si la condición es Contado.')}</label>
                    <select id="gaCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Forma de pago${gHint('Cómo se pagó o se pagará: efectivo, transferencia, tarjeta, cheque.')}</label>
                        <select id="gaFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">—</option><option>efectivo</option><option>transferencia</option><option>tarjeta</option><option>cheque</option>
                        </select></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Folio factura${gHint('El folio o serie-folio que muestra la factura. Opcional, ayuda a rastrearla.')}</label>
                        <input type="text" id="gaFolio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">UUID CFDI${gHint('El folio fiscal (UUID) del CFDI. Da trazabilidad fiscal al gasto y su póliza.')}</label>
                        <input type="text" id="gaUuid" placeholder="folio fiscal" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">RFC emisor${gHint('El RFC de quien emitió la factura. Debe coincidir con el del proveedor que elegiste.')}</label>
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
    gaMontarAsistente();
}

// --- Asistente de captura de Gastos (árbol de preguntas que llena los campos) ---
let gaAsistBody = null;
let gaWizPaso = 'q1';

function gaMontarAsistente() {
    const cont = document.getElementById('contenedorGastos');
    if (!cont || cont.querySelector(':scope > .asist-panel')) return;
    const { wrap, body } = crearPanelAsistente({
        clave: 'gastos-wizard', titulo: 'Captura de gastos',
        subtitulo: 'te dice qué campos poner', abiertoPorDefecto: true,
    });
    gaAsistBody = body;
    cont.prepend(wrap);
    gaWizPaso = 'q1';
    gaWizRender();
}

function gaWizIr(paso) { gaWizPaso = paso; gaWizRender(); }

function gaWizAplicar(clasif, modo, tip, grupo) {
    const $ = (id) => document.getElementById(id);
    if ($('gaClasif')) $('gaClasif').value = clasif;
    if (modo && $('gaReparto')) $('gaReparto').value = modo;
    gaAplicarClasif();
    gaWizGrupo = grupo || null;
    if (grupo) gaSugerirCuenta(grupo);
    if (modo === 'plantilla') gaSugerirPlantilla(true);
    gaResumen();
    gaWizPaso = 'done';
    gaWizRender(tip);
    document.getElementById('gaForm')?.scrollIntoView({ block: 'nearest' });
}

// Reglas concepto/proveedor -> cuenta. Se aplican solo si la cuenta está vacía.
const GA_CUENTA_REGLAS = {
    prod: [
        [/energ[ií]a|\bluz\b|electric|\bcfe\b|comisi[oó]n federal de electric/i, '503.01'],
        [/renta|arrend|predio|\bnave\b|inmobil|\blocal\b/i, '503.05'],
        [/\bagua\b|drenaje|potable|\bgas\b/i, '503.07'],
        [/manten|refacc|reparac|servicio t[eé]cnico|conservaci/i, '503.03'],
        [/deprecia|amortiz/i, '503.04'],
        [/supervis|jefe de produc|mano de obra indirect|coordinador de planta/i, '503.02'],
        [/guante|cofia|cubrebocas|cloro|sanitiz|insumo indirect|limpieza/i, '503.06'],
        [/vigilanc|seguridad|guardia|alarma/i, '503.08'],
    ],
    admin: [
        [/papel|t[oó]ner|tinta|art[ií]culos de oficina/i, '601.50'],
        [/honorari|contad|legal|abogad|notari|audit/i, '601.06'],
        [/sueldo|n[oó]mina|salari|imss|infonavit|prestacion/i, '601.01'],
        [/internet|tel[eé]fon|celular|datos m[oó]viles/i, '601.18'],
        [/renta|arrend/i, '601.24'],
        [/energ[ií]a|\bluz\b|electric|\bcfe\b/i, '601.17'],
        [/\bagua\b/i, '601.19'],
        [/manten|limpieza|conservaci/i, '601.52'],
        [/publicid|propagand|marketing/i, '601.83'],
    ],
    venta: [
        [/publicid|propagand|\bredes\b|marketing|anunci|promoci/i, '601.83'],
        [/flete|paqueter|env[ií]o|mensajer[ií]a|acarreo|transporte de/i, '601.14'],
        [/comisi[oó]n.*(vent|agente)/i, '601.99'],
    ],
    fin: [
        [/comisi[oó]n.*(banc|transfer)|gasto.*banc|manejo de cuenta|anualidad tarjeta/i, '701.01'],
        [/cambiar[io]|tipo de cambio|cambiari|diferencia cambiaria|p[eé]rdida cambiaria/i, '701.04'],
        [/inter[eé]s|financiamiento|factoraje/i, '701.01'],
    ],
};
const GA_CUENTA_FALLBACK = { prod: '503.99', admin: '601.99', venta: '601.99', fin: '701.01' };

function gaSugerirCuenta(grupo) {
    const sel = document.getElementById('gaCuentaGasto');
    if (!sel || sel.value) return;   // no piso una cuenta ya elegida
    const prov = gaProveedores.find((p) => p.id === Number(document.getElementById('gaProveedor').value));
    const txt = [
        document.getElementById('gaConcepto').value,
        prov && prov.nombre,
        gaCfdiActual && gaCfdiActual.nombreEmisor,
    ].filter(Boolean).join(' ');
    if (!txt.trim()) return;
    let codigo = null;
    for (const [re, cod] of (GA_CUENTA_REGLAS[grupo] || [])) { if (re.test(txt)) { codigo = cod; break; } }
    if (!codigo) codigo = GA_CUENTA_FALLBACK[grupo];
    const cta = gaCtasGasto.find((c) => c.codigo === codigo);
    if (!cta) return;
    sel.value = String(cta.id);
    const ct = document.getElementById('gaCifTipo');
    if (cta.cif_tipo && ct && !ct.value) ct.value = cta.cif_tipo;
}

function gaWizRender(tipFinal) {
    if (!gaAsistBody) return;
    const P = gaWizPaso;
    const opt = (act, label) => `<button type="button" data-act="${act}" class="text-left text-xs bg-slate-900 hover:bg-slate-800 border border-slate-700 rounded-lg px-3 py-2">${label}</button>`;
    const atras = (act) => `<button type="button" data-act="${act}" class="text-[11px] text-sky-400 hover:underline mt-1">← Atrás</button>`;
    let html = '';
    if (P === 'q1') {
        gaWizGrupo = null;
        html = `<p class="text-slate-100 font-semibold">1 · ¿Es una compra de inventario? (materia prima, material de empaque)</p>
          <div class="grid gap-2 mt-1">${opt('inv', 'Sí, es inventario')}${opt('q2', 'No')}</div>`;
    } else if (P === 'inv') {
        html = `<p>Eso NO se captura aquí. Va en <b>Compras → Órdenes de compra</b> y luego <b>Recibo de mercancía</b>, para que entre al inventario con su lote y su costo.</p>
          ${atras('q1')}`;
    } else if (P === 'q2') {
        html = `<p class="text-slate-100 font-semibold">2 · ¿Con qué tiene que ver el gasto?</p>
          <div class="grid gap-2 mt-1">
            ${opt('fab', '🏭 Fabricar un producto / operar la planta')}
            ${opt('ofi', '🗂️ Oficina, administración, contabilidad, legal')}
            ${opt('ven', '📣 Vender: publicidad, fletes a clientes, comisiones')}
            ${opt('ban', '🏦 Bancos: intereses, comisiones, tipo de cambio')}
            ${opt('mix', '⚡ Mixto: fábrica Y oficina (la luz, la renta del predio completo)')}
          </div>${atras('q1')}`;
    } else if (P === 'q3a') {
        html = `<p class="text-slate-100 font-semibold">3 · ¿Es para UNA orden de producción concreta y solo esa?</p>
          <p class="text-slate-400">Ej: un molde rentado solo para ese lote, el análisis de laboratorio de ese lote.</p>
          <div class="grid gap-2 mt-1">${opt('directo', 'Sí, una orden')}${opt('q3b', 'No, sirve a la planta en general')}</div>${atras('q2')}`;
    } else if (P === 'q3b') {
        html = `<p class="text-slate-100 font-semibold">4 · ¿De qué parte de la planta es el gasto?</p>
          <p class="text-slate-400">¿Sale de un solo lugar (una máquina o una zona) o sirve a toda la planta?</p>
          <div class="grid gap-2 mt-1">${opt('centro', 'De un solo lugar — ej: mantenimiento de la llenadora, refacción del reactor, una báscula')}${opt('plantilla', 'De toda la planta o de varias zonas — ej: renta, luz general, vigilancia, limpieza')}</div>${atras('q3a')}`;
    } else if (P === 'done') {
        html = `<p class="text-emerald-400 font-semibold">Listo — campos configurados.</p>
          <p>${tipFinal || ''}</p>
          <button type="button" data-act="q1" class="text-[11px] text-sky-400 hover:underline mt-1">Volver a empezar</button>`;
    }
    gaAsistBody.innerHTML = html;
    gaAsistBody.querySelectorAll('[data-act]').forEach((b) => b.addEventListener('click', () => gaWizAccion(b.dataset.act)));
}

function gaWizAccion(act) {
    switch (act) {
        case 'q1': case 'q2': case 'q3a': case 'q3b': case 'inv': gaWizIr(act); break;
        case 'fab': gaWizIr('q3a'); break;
        case 'ofi': gaWizAplicar('no_produccion', null, 'Propuse una <b>cuenta 601.xx de administración</b> según el concepto — revísala y cámbiala si no es la correcta.', 'admin'); break;
        case 'ven': gaWizAplicar('no_produccion', null, 'Propuse una <b>cuenta 601.xx de venta</b> según el concepto — revísala.', 'venta'); break;
        case 'ban': gaWizAplicar('no_produccion', null, 'Propuse una cuenta <b>701.xx</b> (gastos financieros) según el concepto — revísala.', 'fin'); break;
        case 'directo': gaWizAplicar('directo_produccion', null, 'Abajo, en <b>Orden de producción</b>, elige la orden. Propuse la <b>cuenta de gasto</b> — revísala. Se suma al costo de la orden al cerrarla.', 'prod'); break;
        case 'centro': gaWizAplicar('indirecto_produccion', 'centro_unico', 'Propuse la <b>cuenta 503.xx</b> según el concepto. Abajo elige el <b>lugar</b> (SURT / MEZ / ENV) y revisa el <b>fijo/variable</b>.', 'prod'); break;
        case 'plantilla': gaWizAplicar('indirecto_produccion', 'plantilla', 'Propuse la <b>cuenta 503.xx</b> y la <b>plantilla</b> que mejor calza — revisa ambas y el panel de impacto. Si no hay plantilla adecuada, créala en Configuración → Reparto de gastos compartidos.', 'prod'); break;
        case 'mix': gaWizAplicar('indirecto_produccion', 'plantilla', 'Gasto mixto: propuse la <b>cuenta</b> y una <b>plantilla</b> con base m²/kW/personas que separa la parte de fábrica (a las etapas) de la de oficina (a resultados). Revísalas.', 'prod'); break;
    }
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
    $('gaClasif').addEventListener('change', gaAplicarClasif);
    $('gaReparto').addEventListener('change', gaAplicarClasif);
    $('gaPlantilla').addEventListener('change', gaResumen);
    ['gaSubtotal', 'gaCentro'].forEach((id) => $(id) && $(id).addEventListener('input', gaResumen));
    $('gaCuentaGasto').addEventListener('change', () => {
        // pista de fijo/variable desde la cuenta elegida
        const c = gaCtasGasto.find((x) => x.id === Number($('gaCuentaGasto').value));
        if (c && c.cif_tipo && $('gaCifTipo') && !$('gaCifTipo').value) $('gaCifTipo').value = c.cif_tipo;
        // proponer la plantilla ligada a esa cuenta / proveedor
        gaSugerirPlantilla();
        gaResumen();
    });
    $('gaProveedor').addEventListener('change', () => { gaSugerirPlantilla(); gaResumen(); });
    $('gaForm').addEventListener('submit', gaGuardar);
    $('gaBuscar').addEventListener('click', gaBuscar);
    const xmlIn = $('gaXmlFile');
    $('gaBtnXml').addEventListener('click', () => xmlIn.click());
    $('gaManualBtn').addEventListener('click', () => gaAbrirManual('#p4'));
    xmlIn.addEventListener('change', () => {
        const f = xmlIn.files && xmlIn.files[0];
        if (!f) return;
        const r = new FileReader();
        r.onload = () => { gaImportarCfdi(String(r.result || '')); xmlIn.value = ''; };
        r.readAsText(f);
    });
    gaAplicarClasif();
}

// --- Importar XML del CFDI: prellena los campos fiscales del gasto ---
async function gaImportarCfdi(text) {
    const info = document.getElementById('gaCfdiInfo');
    const $ = (id) => document.getElementById(id);
    const c = parsearCfdi(text);
    if (c.error) { info.textContent = c.error; info.className = 'text-[11px] text-rose-400'; return; }
    gaCfdiActual = c;

    const setV = (id, v) => { if ($(id)) $(id).value = Number(v || 0).toFixed(2); };
    if (c.fecha) $('gaFecha').value = c.fecha;
    setV('gaSubtotal', Math.max(0, (c.subtotal || 0) - (c.descuento || 0)));
    setV('gaIva', c.iva); setV('gaIeps', c.ieps); setV('gaRetIva', c.retIva); setV('gaRetIsr', c.retIsr);
    if (c.folio) $('gaFolio').value = c.folio;
    if (c.uuid) $('gaUuid').value = c.uuid;
    if (c.rfcEmisor) $('gaRfc').value = c.rfcEmisor;

    $('gaCondicion').value = c.metodoPago === 'PPD' ? 'credito' : 'contado';
    $('gaPagoWrap').style.display = $('gaCondicion').value === 'contado' ? '' : 'none';
    const fp = formaPagoSimple(c.formaPago);
    if (fp && $('gaFormaPago')) $('gaFormaPago').value = fp;

    if (!$('gaConcepto').value.trim() && c.conceptos.length) {
        const d = (c.conceptos[0].descripcion || '').trim();
        $('gaConcepto').value = c.conceptos.length > 1 ? `${d} (+${c.conceptos.length - 1} conceptos)` : d;
    }
    gaCalcTotal();

    let provTxt = '', provFound = false;
    if (c.rfcEmisor) {
        try {
            const { data } = await supabaseClient.from('proveedores').select('id, nombre').ilike('rfc', c.rfcEmisor).limit(1).maybeSingle();
            if (data) {
                $('gaProveedor').value = String(data.id);
                provFound = true;
                provTxt = ` &middot; Proveedor: <b>${esc(data.nombre)}</b>`;
                gaSugerirPlantilla();
            } else {
                provTxt = ` &middot; <span class="text-amber-400">RFC ${esc(c.rfcEmisor)} no está en Proveedores</span>`;
            }
        } catch (_) { /* proveedores sin columna rfc */ }
    }

    const calc = (c.subtotal - (c.descuento || 0)) + c.iva + c.ieps - c.retIva - c.retIsr;
    const warns = [];
    if (c.tipoComprobante && c.tipoComprobante !== 'I') warns.push(`el CFDI es tipo "${esc(c.tipoComprobante)}", no de Ingreso (I)`);
    if (c.moneda && c.moneda !== 'MXN') warns.push(`moneda ${esc(c.moneda)}: captura los montos en pesos`);
    if (Math.abs(calc - c.total) > 0.05) warns.push(`el total del CFDI ($${c.total.toFixed(2)}) no cuadra con el desglose ($${calc.toFixed(2)})`);
    const warnTxt = warns.length ? ` &middot; <span class="text-amber-400">&#9888; ${warns.join(' &middot; ')}</span>` : '';
    const altaBtn = (!provFound && c.rfcEmisor) ? ` &middot; <button type="button" id="gaAltaProv" class="text-sky-400 hover:underline">+ dar de alta el proveedor</button>` : '';

    info.className = 'text-[11px] text-emerald-400';
    info.innerHTML = `📄 CFDI de <b>${esc(c.nombreEmisor || c.rfcEmisor || '—')}</b> &middot; Folio ${esc(c.folio || '—')} &middot; Total $${c.total.toFixed(2)}${provTxt}${warnTxt}${altaBtn}`;
    if (!provFound && c.rfcEmisor) {
        const b = document.getElementById('gaAltaProv');
        if (b) b.onclick = () => gaAbrirAltaProveedor(c);
    }

    // Si el asistente ya se corrió, ahora que el XML puso concepto/proveedor, vuelve a sugerir la cuenta y la plantilla.
    if (gaWizGrupo) {
        gaSugerirCuenta(gaWizGrupo);
        if ($('gaReparto') && $('gaReparto').value === 'plantilla') gaSugerirPlantilla(true);
    }
    gaResumen();
}

// --- Manual en subventana: usa el helper compartido de asistente-contable.js ---
function gaAbrirManual(hash) { abrirManual(hash, 'Capturar un gasto'); }

// --- Alta rápida de proveedor desde el CFDI (subventana modal) ---
function gaAbrirAltaProveedor(c) {
    if (document.getElementById('gaAltaModal')) return;
    const cond = c.metodoPago === 'PPD' ? 'credito' : 'contado';
    const optReg = '<option value="">— régimen —</option>' + REGIMENES.map(([k, v]) =>
        `<option value="${esc(k)}"${k === (c.regimenEmisor || '') ? ' selected' : ''}>${esc(k)} · ${esc(v)}</option>`).join('');
    const ov = document.createElement('div');
    ov.id = 'gaAltaModal';
    ov.className = 'fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4';
    ov.innerHTML = `
      <div class="bg-slate-950 border border-slate-700 rounded-xl w-full max-w-md p-4 space-y-3 max-h-[90vh] overflow-y-auto">
        <div class="flex items-center justify-between">
          <h3 class="text-sm font-semibold text-sky-400">Alta rápida de proveedor</h3>
          <button type="button" id="gaApX" class="text-slate-500 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <p class="text-[11px] text-amber-300">Datos leídos del CFDI — revisa y ajusta si hace falta.</p>
        <div class="grid grid-cols-2 gap-2">
          <div class="col-span-2"><label class="block text-[10px] text-slate-400 mb-0.5">Nombre / Razón social <span class="text-rose-400">*</span></label>
            <input id="gaApNombre" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100" value="${esc(c.nombreEmisor || '')}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">RFC</label>
            <input id="gaApRfc" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono uppercase" value="${esc(c.rfcEmisor || '')}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">C.P.</label>
            <input id="gaApCp" maxlength="5" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono" value="${esc(c.lugarExpedicion || '')}"></div>
          <div class="col-span-2"><label class="block text-[10px] text-slate-400 mb-0.5">Régimen fiscal</label>
            <select id="gaApRegimen" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100">${optReg}</select></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">Uso CFDI</label>
            <input id="gaApUso" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono uppercase" value="${esc(c.usoCfdi || 'G03')}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">Condición de pago</label>
            <select id="gaApCond" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100">
              <option value="contado"${cond === 'contado' ? ' selected' : ''}>Contado</option>
              <option value="credito"${cond === 'credito' ? ' selected' : ''}>Crédito</option>
            </select></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">Forma de pago (clave SAT)</label>
            <input id="gaApForma" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono" value="${esc(c.formaPago || '')}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">Método de pago</label>
            <input id="gaApMetodo" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono" value="${esc(c.metodoPago || '')}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-0.5">Moneda</label>
            <input id="gaApMoneda" class="w-full bg-slate-900 border border-slate-800 rounded px-2 py-1.5 text-xs text-slate-100 font-mono uppercase" value="${esc(c.moneda || 'MXN')}"></div>
        </div>
        <div class="flex gap-2 pt-1">
          <button type="button" id="gaApGuardar" class="text-xs bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded cursor-pointer">Guardar y usar</button>
          <button type="button" id="gaApCancel" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded cursor-pointer">Cancelar</button>
        </div>
        <p id="gaApMsg" class="text-[11px] min-h-[1rem]"></p>
      </div>`;
    document.body.appendChild(ov);
    const close = () => ov.remove();
    ov.addEventListener('click', (e) => { if (e.target === ov) close(); });
    document.getElementById('gaApX').onclick = close;
    document.getElementById('gaApCancel').onclick = close;
    document.getElementById('gaApGuardar').onclick = () => gaGuardarProveedorNuevo(c, close);
}

async function gaGuardarProveedorNuevo(c, close) {
    const $ = (id) => document.getElementById(id);
    const msg = $('gaApMsg');
    const nombre = $('gaApNombre').value.trim();
    if (!nombre) { msg.textContent = 'El nombre es obligatorio.'; msg.className = 'text-[11px] text-rose-400'; return; }
    const payload = {
        nombre, razon_social: nombre,
        rfc: $('gaApRfc').value.trim().toUpperCase() || null,
        regimen_fiscal: $('gaApRegimen').value.trim() || null,
        uso_cfdi: $('gaApUso').value.trim().toUpperCase() || null,
        condicion_pago: $('gaApCond').value || 'contado',
        dias_credito: 0,
        forma_pago: $('gaApForma').value.trim() || null,
        metodo_pago: $('gaApMetodo').value.trim() || null,
        moneda: $('gaApMoneda').value.trim().toUpperCase() || 'MXN',
        cp: $('gaApCp').value.trim() || null,
        activo: true,
    };
    $('gaApGuardar').disabled = true;
    try {
        const { data, error } = await supabaseClient.from('proveedores').insert([payload]).select('id, nombre').single();
        if (error) throw error;
        gaProveedores.push({ id: data.id, nombre: data.nombre });
        gaProveedores.sort((a, b) => String(a.nombre).localeCompare(String(b.nombre)));
        const sel = document.getElementById('gaProveedor');
        sel.innerHTML = `<option value="">(sin proveedor)</option>` +
            gaProveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
        sel.value = String(data.id);
        const info = document.getElementById('gaCfdiInfo');
        if (info) {
            info.className = 'text-[11px] text-emerald-400';
            info.innerHTML = `📄 CFDI de <b>${esc(c.nombreEmisor || c.rfcEmisor || '—')}</b> &middot; Folio ${esc(c.folio || '—')} &middot; Total $${c.total.toFixed(2)} &middot; <span class="text-emerald-400">✔ Proveedor ${esc(data.nombre)} dado de alta</span>`;
        }
        gaSugerirPlantilla();
        gaResumen();
        close();
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-[11px] text-rose-400';
        $('gaApGuardar').disabled = false;
    }
}

function gaAplicarClasif() {
    const v = document.getElementById('gaClasif')?.value || 'no_produccion';
    const modo = document.getElementById('gaReparto')?.value || 'centro_unico';
    const show = (id, on) => { const el = document.getElementById(id); if (el) el.classList.toggle('hidden', !on); };
    const esIndirecto = v === 'indirecto_produccion';
    const hayPlantillas = gaPlantillas.length > 0;
    show('gaRepartoWrap', esIndirecto && hayPlantillas);
    show('gaCentroWrap', esIndirecto && (!hayPlantillas || modo === 'centro_unico'));
    show('gaPlantillaWrap', esIndirecto && hayPlantillas && modo === 'plantilla');
    show('gaCifTipoWrap', esIndirecto);
    show('gaOrdenWrap', v === 'directo_produccion');
    gaResumen();
}

// elige automáticamente la plantilla más específica (proveedor > cuenta > genérica)
function gaSugerirPlantilla(force) {
    const sel = document.getElementById('gaPlantilla');
    if (!sel || !gaPlantillas.length) return;
    const cta = Number(document.getElementById('gaCuentaGasto').value) || null;
    const prov = Number(document.getElementById('gaProveedor').value) || null;
    const cand = gaPlantillas.filter((p) => p.activo &&
        (!p.cuenta_id || p.cuenta_id === cta) && (!p.proveedor_id || p.proveedor_id === prov));
    cand.sort((a, b) => ((b.proveedor_id ? 2 : 0) + (b.cuenta_id ? 1 : 0)) - ((a.proveedor_id ? 2 : 0) + (a.cuenta_id ? 1 : 0)));
    if (!cand.length) return;
    // sin cuenta ni proveedor no hay con qué acertar: no clavamos una plantilla genérica al azar
    if (!sel.value && !cta && !prov) return;
    // fuerza la selección si no hay ninguna, o si la actual es genérica y ahora hay una más específica
    const actual = gaPlantillas.find((p) => p.id === Number(sel.value));
    const puedeMejorar = force && actual && !actual.cuenta_id && !actual.proveedor_id && (cand[0].cuenta_id || cand[0].proveedor_id);
    if (!sel.value || puedeMejorar) sel.value = String(cand[0].id);
}

// vista previa del impacto del gasto
function gaResumen() {
    const wrap = document.getElementById('gaResumenWrap');
    if (!wrap) return;
    const clasif = document.getElementById('gaClasif').value;
    const modo = document.getElementById('gaReparto')?.value || 'centro_unico';
    const st = parseFloat(document.getElementById('gaSubtotal').value) || 0;
    if (st <= 0) { wrap.classList.add('hidden'); wrap.innerHTML = ''; return; }
    const ctaSel = gaCtasGasto.find((x) => x.id === Number(document.getElementById('gaCuentaGasto').value));
    const ctaTxt = ctaSel ? `${ctaSel.codigo}` : 'la cuenta de gasto';

    if (clasif === 'no_produccion') {
        wrap.classList.remove('hidden');
        wrap.innerHTML = `Impacto: <b>${money(st)}</b> a <b>${ctaTxt}</b> — resultados del periodo. No entra al costo de los lotes.`;
        return;
    }
    if (clasif === 'directo_produccion') {
        wrap.classList.remove('hidden');
        wrap.innerHTML = `Impacto: <b>${money(st)}</b> completo a la orden elegida. Se suma a su costo al cerrarla.`;
        return;
    }
    // indirecto
    if (modo === 'centro_unico' || !gaPlantillas.length) {
        const c = gaCentros.find((x) => x.id === Number(document.getElementById('gaCentro').value));
        wrap.classList.remove('hidden');
        wrap.innerHTML = `Impacto: <b>${money(st)}</b> como CIF de <b>${c ? c.codigo : 'un centro'}</b>, pendiente de prorrateo a fin de mes.`;
        return;
    }
    // plantilla
    const pl = gaPlantillas.find((x) => x.id === Number(document.getElementById('gaPlantilla').value));
    if (!pl) { wrap.classList.remove('hidden'); wrap.innerHTML = 'Elige una plantilla de reparto.'; return; }
    const r = gaResolverBase(pl.base);
    let html = '';
    if (pl.base === 'manual') {
        html = `Plantilla <b>manual</b>: el reparto sale de sus líneas fijas.`;
    } else if (pl.base === 'partes_iguales') {
        const n = gaCentros.length || 1;
        html = `${money(st)} ÷ ${n} centros = <b>${money(st / n)}</b> a cada uno. Sin parte de oficina.`;
    } else if (!r.hay) {
        html = `<span class="text-amber-400">Faltan datos de ${pl.base} en las áreas.</span> Captúralos en "Áreas y bases de prorrateo".`;
    } else {
        const prod = 1 - r.noProd;
        const partes = Object.entries(r.porCentro).map(([id, f]) => {
            const c = gaCentros.find((x) => x.id === Number(id));
            return `${c ? c.codigo : id} ${money(st * f)}`;
        }).join(' · ');
        html = `Fábrica <b>${money(st * prod)}</b> (${partes}) → CIF pendiente de prorrateo`;
        if (r.noProd > 0) html += `<br>Oficina <b>${money(st * r.noProd)}</b> → resultados`;
    }
    if (gaUmbral > 0 && st > 0 && st < gaUmbral && pl.base !== 'partes_iguales') {
        html += `<br><span class="text-amber-400">Monto menor al umbral de materialidad (${money(gaUmbral)}). Considera asignarlo completo a un centro para simplificar.</span>`;
    }
    wrap.classList.remove('hidden');
    wrap.innerHTML = html;
}

function gaResolverBase(base) {
    const rows = gaBases.filter((x) => x.base === base);
    const porCentro = {};
    let noProd = 0;
    rows.forEach((x) => {
        if (x.rol === 'produccion' && x.centro_costo_id) porCentro[x.centro_costo_id] = (porCentro[x.centro_costo_id] || 0) + Number(x.fraccion || 0);
        else if (x.rol === 'no_produccion') noProd += Number(x.fraccion || 0);
    });
    return { porCentro, noProd, hay: rows.some((x) => Number(x.valor || 0) > 0) };
}

function gaCalcTotal() {
    const n = (id) => parseFloat(document.getElementById(id).value) || 0;
    const total = n('gaSubtotal') + n('gaIva') + n('gaIeps') - n('gaRetIva') - n('gaRetIsr');
    document.getElementById('gaTotal').value = money(total);
}

async function gaCargarCatalogos() {
    try {
        // cuentas: se pide cif_tipo aparte para degradar si falta la columna (Fase 1)
        let ctasSel = 'id, codigo, nombre, tipo, afectable, activa, cif_tipo';
        let ctas = await supabaseClient.from('cuentas_contables').select(ctasSel).eq('afectable', true).eq('activa', true).order('codigo');
        if (ctas.error && /cif_tipo|column .* does not exist/i.test(ctas.error.message || '')) {
            ctasSel = 'id, codigo, nombre, tipo, afectable, activa';
            ctas = await supabaseClient.from('cuentas_contables').select(ctasSel).eq('afectable', true).eq('activa', true).order('codigo');
        }
        const [prov, centros, ordenes, plant, bases, cfg] = await Promise.all([
            supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
            supabaseClient.from('centros_costo').select('id, codigo, nombre').eq('activo', true).order('codigo'),
            supabaseClient.from('ordenes_produccion').select('id, folio, numero_lote, estado, productos(nombre)').in('estado', ['en_proceso', 'cerrada']).order('id', { ascending: false }).limit(60),
            supabaseClient.from('reparto_plantillas').select('*').eq('activo', true).order('id'),
            supabaseClient.from('v_bases_prorrateo').select('base, rol, centro_costo_id, valor, fraccion'),
            supabaseClient.from('costos_config').select('clave, valor').eq('clave', 'umbral_materialidad_mxn').maybeSingle(),
        ]);
        if (prov.error) throw prov.error;
        if (ctas.error) throw ctas.error;

        gaProveedores = prov.data || [];
        gaCentros = (centros.error ? [] : centros.data) || [];
        gaOrdenes = (ordenes.error ? [] : ordenes.data) || [];
        gaPlantillas = (plant.error ? [] : plant.data) || [];
        gaBases = (bases.error ? [] : bases.data) || [];
        gaUmbral = cfg.error || !cfg.data ? 0 : (parseFloat(cfg.data.valor) || 0);
        const todas = ctas.data || [];
        gaCtasGasto = todas.filter((c) => c.tipo === 'gasto' || c.tipo === 'costo');
        gaCtasPago = todas.filter((c) => c.tipo === 'activo' && /^(101|102)/.test(c.codigo));

        document.getElementById('gaProveedor').innerHTML = `<option value="">(sin proveedor)</option>` +
            gaProveedores.map((p) => `<option value="${p.id}">${p.nombre}</option>`).join('');
        document.getElementById('gaCuentaGasto').innerHTML = `<option value="">— cuenta de gasto —</option>` +
            gaCtasGasto.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}${c.cif_tipo ? ' · CIF ' + c.cif_tipo : ''}</option>`).join('');
        document.getElementById('gaCuentaPago').innerHTML = `<option value="">— caja / banco —</option>` +
            gaCtasPago.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');

        const selC = document.getElementById('gaCentro');
        if (selC) selC.innerHTML = `<option value="">— centro de costo —</option>` +
            gaCentros.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
        const selO = document.getElementById('gaOrden');
        if (selO) selO.innerHTML = `<option value="">— orden —</option>` +
            gaOrdenes.map((o) => `<option value="${o.id}">${o.folio || ('#' + o.id)} · ${o.productos?.nombre || 'producto'} · ${o.estado}</option>`).join('');
        const selP = document.getElementById('gaPlantilla');
        if (selP) selP.innerHTML = `<option value="">— plantilla —</option>` +
            gaPlantillas.map((p) => `<option value="${p.id}">${p.nombre}</option>`).join('');
        gaAplicarClasif();
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
        clasificacion: $('gaClasif').value,
    };

    // --- reparto (Tanda 2): modo directo / centro_unico / plantilla / ninguno ---
    const clasif = $('gaClasif').value;
    const modoReparto = $('gaReparto').value;
    const usaPlantilla = clasif === 'indirecto_produccion' && gaPlantillas.length && modoReparto === 'plantilla';
    if (clasif === 'directo_produccion') {
        p_datos.reparto = {
            modo: 'directo',
            orden_produccion_id: $('gaOrden').value ? Number($('gaOrden').value) : null,
        };
    } else if (clasif === 'indirecto_produccion' && usaPlantilla) {
        p_datos.reparto = {
            modo: 'plantilla',
            plantilla_id: $('gaPlantilla').value ? Number($('gaPlantilla').value) : null,
            cif_tipo: $('gaCifTipo').value || null,
        };
    } else if (clasif === 'indirecto_produccion') {
        p_datos.reparto = {
            modo: 'centro_unico',
            centro_costo_id: $('gaCentro').value ? Number($('gaCentro').value) : null,
            cif_tipo: $('gaCifTipo').value || null,
        };
    } else {
        p_datos.reparto = { modo: 'ninguno' };
    }

    if (!p_datos.concepto || !p_datos.cuenta_gasto_id || p_datos.subtotal <= 0) {
        msg.textContent = 'Faltan concepto, cuenta de gasto o subtotal.'; msg.className = 'text-xs text-rose-400'; return;
    }
    if (p_datos.reparto.modo === 'centro_unico' && !p_datos.reparto.centro_costo_id) {
        msg.textContent = 'Un gasto indirecto de fabricación necesita un centro de costo.'; msg.className = 'text-xs text-rose-400'; return;
    }
    if (p_datos.reparto.modo === 'plantilla' && !p_datos.reparto.plantilla_id) {
        msg.textContent = 'Elige la plantilla de reparto.'; msg.className = 'text-xs text-rose-400'; return;
    }
    if (p_datos.reparto.modo === 'directo' && !p_datos.reparto.orden_produccion_id) {
        msg.textContent = 'Un gasto directo necesita la orden de producción.'; msg.className = 'text-xs text-rose-400'; return;
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
        const infoCfdi = $('gaCfdiInfo'); if (infoCfdi) infoCfdi.textContent = '';
        gaCfdiActual = null; gaWizGrupo = null;
        gaAplicarClasif();
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
                                <td class="p-2 font-mono">${g.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${g.poliza_id}, '${g.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 ${g.polizas ? g.polizas.tipo + ' #' + g.polizas.numero : 'Póliza #' + g.poliza_id}</button>` : '<span class="text-slate-500">—</span>'}</td>
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
let rcCache = null; // { desde, hasta, ctas, movs, sinDetalle }
let rcCuentaExpandida = null; // id de cuenta con el desglose abierto

// Movimientos de UNA cuenta dentro del periodo (para el desglose por cuenta).
function rcMovsDeCuenta(cuentaId) {
    const { desde, hasta, movs } = rcCache;
    return movs
        .filter((m) => m.cuenta_id === cuentaId && m.polizas && m.polizas.fecha >= desde && m.polizas.fecha <= hasta)
        .sort((a, b) => (a.polizas.fecha < b.polizas.fecha ? -1 : a.polizas.fecha > b.polizas.fecha ? 1 : (a.id || 0) - (b.id || 0)));
}

// Movimientos de pólizas ya canceladas que tocan esta cuenta — solo para
// mostrar (no se suman a ningún saldo).
function rcMovsCanceladosDeCuenta(cuentaId) {
    const lista = rcCache.movsCancelados || [];
    return lista
        .filter((m) => m.cuenta_id === cuentaId)
        .sort((a, b) => (a.polizas.fecha < b.polizas.fecha ? -1 : a.polizas.fecha > b.polizas.fecha ? 1 : (a.id || 0) - (b.id || 0)));
}

// Fila expandible con el detalle de movimientos de la cuenta + enlace a su póliza.
function rcFilaDetalleCuenta(cuenta, colspan) {
    if (rcCache.sinDetalle) {
        return `<tr class="rc-detalle-row bg-slate-900/40"><td colspan="${colspan}" class="p-3 text-[11px] text-amber-400">
            El desglose por documento necesita el último SQL de contabilidad. Vuelve a generar el reporte tras correrlo.</td></tr>`;
    }
    const lista = rcMovsDeCuenta(cuenta.id);
    const listaCancelados = rcMovsCanceladosDeCuenta(cuenta.id);
    if (!lista.length && !listaCancelados.length) {
        return `<tr class="rc-detalle-row bg-slate-900/40"><td colspan="${colspan}" class="p-3 text-[11px] text-slate-500">Sin movimientos en el periodo.</td></tr>`;
    }
    let sc = 0, sa = 0;
    const filaMov = (m) => {
        const p = m.polizas || {};
        return `<tr class="border-b border-slate-900/60">
            <td class="p-1.5 whitespace-nowrap text-slate-400">${p.fecha || ''}</td>
            <td class="p-1.5">
                <button type="button" class="rc-ver-pol text-sky-400 hover:underline font-mono" data-pol="${p.id}">${p.tipo || '?'} #${p.numero ?? '?'}</button>
                ${p.origen && p.origen !== 'manual' ? `<span class="text-[10px] text-slate-600 ml-1">(${p.origen})</span>` : ''}
            </td>
            <td class="p-1.5 text-slate-400">${(m.concepto || p.concepto || '').replace(/</g, '&lt;')}</td>
            <td class="p-1.5 text-right font-mono">${Number(m.cargo) ? rcFmt(m.cargo) : ''}</td>
            <td class="p-1.5 text-right font-mono">${Number(m.abono) ? rcFmt(m.abono) : ''}</td>
        </tr>`;
    };
    const filas = lista.map((m) => {
        sc += Number(m.cargo) || 0; sa += Number(m.abono) || 0;
        return filaMov(m);
    }).join('');

    const bloqueCancelados = listaCancelados.length ? `
        <div class="text-[11px] text-rose-400/80 mt-3 mb-1 font-semibold">⚠ Movimientos de pólizas canceladas — no se suman al saldo (${listaCancelados.length})</div>
        <div class="overflow-x-auto opacity-60">
        <table class="w-full text-left text-[11px] text-slate-400">
            <tbody>${listaCancelados.map(filaMov).join('')}</tbody>
        </table>
        </div>` : '';

    return `<tr class="rc-detalle-row bg-slate-900/30"><td colspan="${colspan}" class="p-2">
        <div class="text-[11px] text-slate-500 mb-1 font-semibold">${cuenta.codigo} · ${cuenta.nombre} — ${lista.length} movimiento(s)</div>
        ${lista.length ? `<div class="overflow-x-auto">
        <table class="w-full text-left text-[11px] text-slate-300">
            <thead class="text-slate-500 uppercase"><tr>
                <th class="p-1.5 text-left">Fecha</th><th class="p-1.5 text-left">Póliza</th>
                <th class="p-1.5 text-left">Concepto</th><th class="p-1.5 text-right">Cargo</th><th class="p-1.5 text-right">Abono</th>
            </tr></thead>
            <tbody>${filas}</tbody>
            <tfoot class="border-t border-slate-800 font-mono"><tr>
                <td class="p-1.5" colspan="3">Suma del periodo</td>
                <td class="p-1.5 text-right">${rcFmt(sc)}</td>
                <td class="p-1.5 text-right">${rcFmt(sa)}</td>
            </tr></tfoot>
        </table>
        </div>` : ''}
        ${bloqueCancelados}
    </td></tr>`;
}

// Enlaza los click de "desglose por cuenta" y "ver póliza" tras cada render.
function rcCablearDesglose() {
    const res = document.getElementById('rcResultado');
    if (!res) return;
    res.querySelectorAll('.rc-cuenta-row').forEach((tr) => {
        tr.addEventListener('click', (e) => {
            if (e.target.closest('.rc-ver-pol')) return;
            const id = Number(tr.dataset.cuenta);
            rcCuentaExpandida = (rcCuentaExpandida === id) ? null : id;
            rcPintar();
        });
    });
    res.querySelectorAll('.rc-ver-pol').forEach((b) => {
        b.addEventListener('click', (e) => {
            e.stopPropagation();
            window.rcVerPoliza(Number(b.dataset.pol));
        });
    });
}

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
    montarGuia(document.getElementById('contenedorReportesContables'), 'reportes-contables');
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
        rcCuentaExpandida = null;
        try {
            const ctasR = await supabaseClient.from('cuentas_contables')
                .select('id, codigo, nombre, tipo, naturaleza, nivel, cuenta_padre_id, afectable')
                .order('codigo', { ascending: true });
            if (ctasR.error) throw ctasR.error;

            // Movimientos con datos suficientes para el desglose por cuenta.
            let movsR = await supabaseClient.from('poliza_movimientos')
                .select('id, cuenta_id, cargo, abono, concepto, polizas!inner(id, fecha, estatus, tipo, numero, concepto, origen)')
                .eq('polizas.estatus', 'contabilizada')
                .lte('polizas.fecha', hasta)
                .limit(50000);
            let sinDetalle = false;
            if (movsR.error) {
                // esquema viejo: cae al select mínimo (sin desglose por documento)
                sinDetalle = true;
                movsR = await supabaseClient.from('poliza_movimientos')
                    .select('cuenta_id, cargo, abono, polizas!inner(fecha, estatus)')
                    .eq('polizas.estatus', 'contabilizada')
                    .lte('polizas.fecha', hasta)
                    .limit(50000);
            }
            if (movsR.error) throw movsR.error;
            const movs = movsR.data || [];

            // Movimientos de pólizas YA canceladas en el periodo: no cuentan
            // para el saldo, pero se muestran aparte al expandir la cuenta
            // para que quede claro que se canceló y no que "desapareció".
            let movsCancelados = [];
            if (!sinDetalle) {
                const cancR = await supabaseClient.from('poliza_movimientos')
                    .select('id, cuenta_id, cargo, abono, concepto, polizas!inner(id, fecha, estatus, tipo, numero, concepto, origen)')
                    .eq('polizas.estatus', 'cancelada')
                    .gte('polizas.fecha', desde)
                    .lte('polizas.fecha', hasta)
                    .limit(2000);
                if (!cancR.error) movsCancelados = cancR.data || [];
            }

            rcCache = { desde, hasta, ctas: ctasR.data || [], movs, movsCancelados, truncado: movs.length >= 1000, sinDetalle };
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
    rcCablearDesglose();
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
        const cancelados = rcMovsCanceladosDeCuenta(c.id).length;
        return { c, saldoIni, cargo: a.perC, abono: a.perA, saldoFin, cancelados };
    }).filter((r) => r.saldoIni || r.cargo || r.abono || r.saldoFin || r.cancelados);

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
                        <tr class="rc-cuenta-row border-b border-slate-900 cursor-pointer hover:bg-slate-900/40" data-cuenta="${r.c.id}">
                            <td class="p-2 font-mono text-slate-400">${rcCuentaExpandida === r.c.id ? '▾' : '▸'} ${r.c.codigo}</td>
                            <td class="p-2">${r.c.nombre}${(r.cancelados && !r.saldoIni && !r.cargo && !r.abono && !r.saldoFin) ? ` <span class="text-[10px] text-rose-400/80">· solo pólizas canceladas</span>` : ''}</td>
                            <td class="p-2 text-right font-mono ${r.saldoIni < 0 ? 'text-rose-400' : ''}">${rcFmt(r.saldoIni)}</td>
                            <td class="p-2 text-right font-mono">${rcFmt(r.cargo)}</td>
                            <td class="p-2 text-right font-mono">${rcFmt(r.abono)}</td>
                            <td class="p-2 text-right font-mono ${r.saldoFin < 0 ? 'text-rose-400' : ''}">${rcFmt(r.saldoFin)}</td>
                        </tr>
                        ${rcCuentaExpandida === r.c.id ? rcFilaDetalleCuenta(r.c, 6) : ''}`).join('')}
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
            .map((c) => ({ c, monto: netoPeriodo(c), cancelados: rcMovsCanceladosDeCuenta(c.id).length }))
            .filter((x) => Math.abs(x.monto) > 0.005 || x.cancelados);
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
        ${b.items.map((x) => `
            <tr class="rc-cuenta-row border-b border-slate-900 cursor-pointer hover:bg-slate-900/40" data-cuenta="${x.c.id}">
                <td class="p-2 pl-6"><span class="text-slate-600">${rcCuentaExpandida === x.c.id ? '▾' : '▸'}</span> <span class="font-mono text-slate-500">${x.c.codigo}</span> ${x.c.nombre}${(x.cancelados && Math.abs(x.monto) <= 0.005) ? ` <span class="text-[10px] text-rose-400/80">· solo pólizas canceladas</span>` : ''}</td>
                <td class="p-2 text-right font-mono">${rcFmt(x.monto)}</td>
            </tr>
            ${rcCuentaExpandida === x.c.id ? rcFilaDetalleCuenta(x.c, 2) : ''}`).join('') || '<tr><td class="p-2 pl-6 text-slate-600" colspan="2">(sin movimientos)</td></tr>'}
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

// Modal: detalle completo de una póliza + enlaces a su documento / gasto de origen.
window.rcCerrarModalPoliza = function () {
    document.getElementById('rcModalPoliza')?.remove();
};

window.rcVerPoliza = async function (polId) {
    let cont = document.getElementById('rcModalPoliza');
    if (!cont) {
        cont = document.createElement('div');
        cont.id = 'rcModalPoliza';
        cont.className = 'fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/80 backdrop-blur-sm p-4';
        cont.addEventListener('click', (e) => { if (e.target === cont) window.rcCerrarModalPoliza(); });
        document.body.appendChild(cont);
    }
    cont.innerHTML = `<div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-xl p-6 text-sm text-slate-300">
        <p class="text-slate-500">Cargando póliza #${polId}...</p></div>`;

    const ctaMapa = new Map((rcCache?.ctas || []).map((c) => [c.id, c]));
    try {
        const { data: pol, error } = await supabaseClient
            .from('polizas')
            .select('*, poliza_movimientos(id, orden, cuenta_id, cargo, abono, concepto)')
            .eq('id', polId).single();
        if (error) throw error;

        // Documento(s) y gasto de origen (best-effort; columnas pueden no existir)
        let docs = [], gasto = null;
        try {
            const r = await supabaseClient.from('documentos').select('id, folio, tipo_movimiento').eq('poliza_id', polId);
            if (!r.error) docs = r.data || [];
        } catch (_) {}
        try {
            const r = await supabaseClient.from('gastos').select('id, concepto, folio_factura').eq('poliza_id', polId);
            if (!r.error && r.data && r.data.length) gasto = r.data[0];
        } catch (_) {}

        const movs = (pol.poliza_movimientos || []).slice().sort((a, b) => (a.orden || 0) - (b.orden || 0));
        const totC = movs.reduce((s, m) => s + (Number(m.cargo) || 0), 0);
        const totA = movs.reduce((s, m) => s + (Number(m.abono) || 0), 0);

        const enlacesDoc = docs.map((d) => `
            <button type="button" onclick="window.rcCerrarModalPoliza(); window.loadView('documentos'); window.abrirDetalleDocumentoGlobal(${d.id});"
                class="text-xs bg-indigo-600/20 hover:bg-indigo-600/40 text-indigo-300 border border-indigo-800/60 px-3 py-1.5 rounded-lg font-semibold cursor-pointer">
                Abrir documento #${d.id}${d.folio ? ' · ' + d.folio : ''}
            </button>`).join(' ');

        cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
            <div class="bg-slate-950 px-5 py-3 border-b border-slate-800 flex justify-between items-center">
                <h3 class="text-sm font-bold text-slate-200">Póliza ${pol.tipo} #${pol.numero} · ${pol.fecha}</h3>
                <button onclick="window.rcCerrarModalPoliza()" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2">&times;</button>
            </div>
            <div class="p-5 space-y-3 overflow-y-auto text-sm">
                <div class="text-xs text-slate-400">
                    <span class="font-semibold text-slate-300">Concepto:</span> ${(pol.concepto || '—')}<br>
                    <span class="font-semibold text-slate-300">Estatus:</span> <span class="${pol.estatus === 'contabilizada' ? 'text-emerald-400' : 'text-rose-400'}">${pol.estatus}</span>
                    · <span class="font-semibold text-slate-300">Origen:</span> ${pol.origen || 'manual'}
                </div>
                <div class="overflow-x-auto border border-slate-800 rounded-lg">
                    <table class="w-full text-left text-[11px] text-slate-300">
                        <thead class="bg-slate-950 text-slate-500 uppercase"><tr>
                            <th class="p-2">Cuenta</th><th class="p-2">Concepto</th>
                            <th class="p-2 text-right">Cargo</th><th class="p-2 text-right">Abono</th>
                        </tr></thead>
                        <tbody>
                            ${movs.map((m) => {
                                const c = ctaMapa.get(m.cuenta_id);
                                return `<tr class="border-b border-slate-900">
                                    <td class="p-2 font-mono">${c ? c.codigo + ' · ' + c.nombre : 'cuenta ' + m.cuenta_id}</td>
                                    <td class="p-2 text-slate-400">${(m.concepto || '').replace(/</g, '&lt;')}</td>
                                    <td class="p-2 text-right font-mono">${Number(m.cargo) ? rcFmt(m.cargo) : ''}</td>
                                    <td class="p-2 text-right font-mono">${Number(m.abono) ? rcFmt(m.abono) : ''}</td>
                                </tr>`;
                            }).join('')}
                        </tbody>
                        <tfoot class="bg-slate-950 font-mono border-t border-slate-700"><tr>
                            <td class="p-2" colspan="2">Totales</td>
                            <td class="p-2 text-right">${rcFmt(totC)}</td>
                            <td class="p-2 text-right">${rcFmt(totA)}</td>
                        </tr></tfoot>
                    </table>
                </div>
                ${gasto ? `<div class="text-xs text-slate-400"><span class="font-semibold text-slate-300">Gasto de origen:</span> #${gasto.id} · ${gasto.concepto || ''}${gasto.folio_factura ? ' · ' + gasto.folio_factura : ''}</div>` : ''}
                ${enlacesDoc ? `<div class="flex flex-wrap gap-2 pt-1">${enlacesDoc}</div>`
                    : `<p class="text-[11px] text-slate-500">Esta póliza no tiene un documento de almacén enlazado (origen: ${pol.origen || 'manual'}).</p>`}
            </div>
            <div class="bg-slate-950 px-5 py-3 border-t border-slate-800 text-right">
                <button onclick="window.rcCerrarModalPoliza()" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 px-4 py-2 rounded-xl font-semibold cursor-pointer">Cerrar</button>
            </div>
        </div>`;
    } catch (err) {
        cont.innerHTML = `<div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-xl p-6 text-sm">
            <p class="text-rose-400">No se pudo cargar la póliza #${polId}.<br>${err.message || err}</p>
            <div class="text-right mt-3"><button onclick="window.rcCerrarModalPoliza()" class="text-xs bg-slate-800 px-4 py-2 rounded-xl text-slate-200">Cerrar</button></div>
        </div>`;
    }
};

function rcExportarCSV() {
    const tabla = document.querySelector('#rcTabla table');
    if (!tabla) { alert('Genera primero un reporte.'); return; }
    const filas = [];
    tabla.querySelectorAll('tr').forEach((tr) => {
        if (tr.classList.contains('rc-detalle-row') || tr.closest('.rc-detalle-row')) return;
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
