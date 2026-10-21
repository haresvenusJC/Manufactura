import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { linkDoc, linkPoliza } from './enlaces-reporte.js';
import { ordenarCentrosProduccion } from './centros-costo.js';
import { cargarCategoriasDep, opcionesCategoriaDep, textoCategoriaDep, vidaMesesDePct } from './categorias-depreciacion.js';

// =====================================================================
//  Activos fijos y depreciación (NIF C-6, línea recta): catálogo de
//  activos (maquinaria, equipo, vehículos...) y la corrida mensual de
//  depreciación — una póliza por mes (cargo a gasto de depreciación,
//  abono a depreciación acumulada), con su historial y cancelación.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
import { hoyISO } from './fechas.js';
const afOrden = crearOrdenTabla('id', 'desc');

let afCuentas = [];
let afCentros = [];          // etapas de producción (para repartir la depreciación al CIF)
let afTieneEtapas = false;   // false si falta correr sql/2026-10-14_depreciacion_al_prorrateo.sql
let afEtapasPorActivo = new Map();
let afActivoEditId = null;
let afAreas = [];            // áreas físicas (dónde está cada equipo)
let afNuevo = false;         // false si falta correr sql/2026-10-15_equipos_unificados.sql
let afPend = false;          // false si falta correr sql/2026-10-21_activo_fijo_en_compras.sql (activos que nacen de una compra)
let afSoloPend = false;      // la lista muestra solo los pendientes de completar
let afEditPendiente = false; // el activo que se edita nació de una compra y está pendiente de completar
let afCatsDep = [];          // categorías fiscales (LISR); vacío si falta sql/2026-10-22_categorias_depreciacion_fiscal.sql
let afCatOrig = null;        // categoría/% que el activo ya traía al editarlo (se conserva su copia del año)
let afEditLigado = false;    // el activo que se edita viene de una compra: su costo y fecha no se editan aquí
const UNIDAD_KW = { kW: 1, HP: 0.746, W: 0.001 };
const TIPOS_CARGA = [['equipo', 'Equipo'], ['clima', 'Clima / HVAC'], ['iluminacion', 'Iluminación'], ['otro', 'Otro']];
const afIdCuenta = (cod) => afCuentas.find((c) => c.codigo === cod)?.id || '';
const esCuentaCif = (id) => String(afCuentas.find((c) => c.id === Number(id))?.codigo || '').startsWith('503.');

export async function cargarModuloActivosFijos() {
    const cont = document.getElementById('contenedorActivosFijos');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const { data } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo').eq('afectable', true).eq('activa', true).order('codigo');
        afCuentas = data || [];
        const [ce, et, nu, ar, pe, cd] = await Promise.all([
            supabaseClient.from('centros_costo').select('id, codigo, nombre').eq('tipo', 'produccion').eq('activo', true),
            supabaseClient.from('activos_fijos_centros').select('id').limit(1),
            supabaseClient.from('activos_fijos').select('depreciable').limit(1),
            supabaseClient.from('areas_fisicas').select('id, codigo, nombre').eq('activo', true).order('codigo'),
            supabaseClient.from('activos_fijos').select('pendiente').limit(1),
            cargarCategoriasDep(),
        ]);
        afCatsDep = cd || [];
        afCentros = ordenarCentrosProduccion(ce.data || []);
        afTieneEtapas = !et.error;
        afNuevo = !nu.error && !ar.error;
        afPend = !pe.error;
        afAreas = ar.data || [];
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`;
        return;
    }

    const optsActivo = afCuentas.filter((c) => c.tipo === 'activo').map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const optsGasto = afCuentas.filter((c) => c.tipo === 'gasto' || (c.tipo === 'costo' && String(c.codigo).startsWith('503.'))).map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 id="afFormTitulo" class="text-md font-semibold text-emerald-400 mb-3">Nuevo activo fijo</h3>
        <div id="afPendAviso" class="hidden mb-3 bg-amber-950/30 border border-amber-800/50 text-amber-200 rounded-lg p-2.5 text-xs"></div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div class="md:col-span-2"><label class="block text-xs text-slate-400 mb-1">Nombre</label>
            <input type="text" id="afNombre" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Categoría${afCatsDep.length ? ' fiscal <span class="text-slate-600">· LISR, define el % máximo</span>' : ''}</label>
            <input type="text" id="afCategoria" placeholder="Ej. Maquinaria" class="${afCatsDep.length ? 'hidden ' : ''}w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            ${afCatsDep.length ? '<select id="afCatDep" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>' : ''}</div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha de alta / adquisición</label>
            <input type="date" id="afFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          ${afNuevo ? `
          <div><label class="block text-xs text-slate-400 mb-1">Área donde está <span class="text-rose-400">*</span></label>
            <select id="afArea" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${afAreas.map((a) => `<option value="${a.id}">${esc(a.codigo)} · ${esc(a.nombre)}</option>`).join('')}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Tipo de carga</label>
            <select id="afTipoCarga" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${TIPOS_CARGA.map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Potencia de placa (por unidad) <span class="text-rose-400">*</span> <span class="text-slate-600">· 0 si no usa electricidad</span></label>
            <div class="flex gap-1"><input type="number" step="any" min="0" id="afPot" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <select id="afPotU" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option>kW</option><option>HP</option><option>W</option></select></div></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cantidad de piezas iguales</label>
            <input type="number" step="1" min="1" id="afCant" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Factor de uso <span class="text-slate-600">· 1 = siempre a plena carga</span></label>
            <input type="number" step="0.01" min="0.01" max="1" id="afFu" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="md:col-span-3 border border-slate-800 rounded-lg p-3 bg-slate-900/40">
            <div class="text-xs text-slate-300 font-medium mb-1">¿Este equipo se deprecia? <span class="text-rose-400">*</span></div>
            <label class="flex items-start gap-2 text-xs text-slate-200 mb-1"><input type="radio" name="afDep" value="si" class="mt-0.5"> <span><b>Depreciable</b> — lo compraste y vale dinero que se va desgastando (maquinaria, equipo de cómputo). Pide costo y vida útil; cada mes genera su póliza de depreciación.</span></label>
            <label class="flex items-start gap-2 text-xs text-slate-200"><input type="radio" name="afDep" value="no" class="mt-0.5"> <span><b>No depreciable</b> — solo quieres controlarlo (dónde está y cuánta luz usa): equipo ya depreciado, de bajo valor o que no se activa. No genera depreciación.</span></label>
          </div>` : ''}
          ${afCatsDep.length ? '<div id="afCatDepInfo" class="md:col-span-3 hidden text-[11px] text-teal-200 bg-teal-950/30 border border-teal-900/60 rounded-lg px-3 py-2"></div>' : ''}
          <div id="afHistWrap" class="md:col-span-3 hidden">
            <label class="block text-xs text-slate-400 mb-1">Costo histórico <span class="text-slate-600">· opcional: lo que costó el equipo, solo para verlo en el listado (no genera póliza ni depreciación)</span></label>
            <input type="number" step="any" min="0" id="afCostoHist" class="w-full md:w-1/3 bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
          </div>
          <div id="afDepWrap" class="md:col-span-3 grid grid-cols-1 md:grid-cols-3 gap-3 ${afNuevo ? 'hidden' : ''}">
          <div><label class="block text-xs text-slate-400 mb-1">Costo de adquisición</label>
            <input type="number" step="any" min="0" id="afCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Valor residual</label>
            <input type="number" step="any" min="0" id="afResidual" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Vida útil (meses)</label>
            <input type="number" step="1" min="1" id="afVidaUtil" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de activo</label>
            <select id="afCtaActivo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsActivo}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de gasto de depreciación</label>
            <select id="afCtaGasto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsGasto}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de depreciación acumulada</label>
            <select id="afCtaAcumulada" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsActivo}</select></div>
          </div>
          <div id="afEtapasWrap" class="md:col-span-3 hidden border border-slate-800 rounded-lg p-3 bg-slate-900/40">
            <div class="text-xs text-slate-300 font-medium mb-1">¿En qué etapas se usa esta máquina?</div>
            <div class="text-[11px] text-slate-500 mb-2">Su depreciación mensual es costo indirecto de fabricación (CIF fijo): al hacer el prorrateo del mes se reparte en <b>partes iguales</b> entre las etapas que marques y de ahí a las órdenes de producción. Si no marcas ninguna, no se prorratea.</div>
            ${afTieneEtapas
                ? `<div class="flex flex-wrap gap-4">${afCentros.map((c) => `<label class="flex items-center gap-1.5 text-xs text-slate-200"><input type="checkbox" class="afEtapaChk accent-emerald-500" value="${c.id}"> ${esc(c.codigo)} · ${esc(c.nombre)}</label>`).join('') || '<span class="text-xs text-amber-400">No hay etapas de producción: créalas en Centros de costo.</span>'}</div>`
                : '<div class="text-xs text-amber-400">Falta correr <span class="font-mono">sql/2026-10-14_depreciacion_al_prorrateo.sql</span> en Supabase para poder asignar etapas.</div>'}
          </div>
          <div class="md:col-span-3"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="afNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="flex gap-2">
          <button type="button" id="afGuardar" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar activo</button>
          <button type="button" id="afCancelarEdicion" class="hidden bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 px-4 rounded-lg text-sm">Cancelar</button>
        </div>
        <p id="afMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Catálogo de activos fijos</h3>
        <div id="afLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Depreciación del mes</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Año</label>
            <input type="number" id="afAnio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Mes</label>
            <input type="number" min="1" max="12" id="afMes" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="flex items-end"><button type="button" id="afCalcular" class="w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-2 rounded-lg text-sm">Calcular</button></div>
        </div>
        <div id="afPreview" class="text-sm text-slate-500">Elige año y mes, y pulsa "Calcular".</div>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Historial de depreciación aplicada</h3>
        <div id="afHistorial" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    const hoy = new Date();
    document.getElementById('afFecha').value = hoyISO();
    document.getElementById('afAnio').value = hoy.getFullYear();
    document.getElementById('afMes').value = hoy.getMonth() + 1;

    document.getElementById('afVidaUtil').addEventListener('input', (e) => { delete e.target.dataset.auto; });
    document.getElementById('afGuardar').onclick = afGuardarActivo;
    document.getElementById('afCancelarEdicion').onclick = afResetForm;
    document.getElementById('afCalcular').onclick = afCalcularDepreciacion;
    document.getElementById('afCtaGasto').addEventListener('change', afMostrarEtapas);
    if (afCatsDep.length) {
        afPintarCatDep(null);
        document.getElementById('afCatDep').addEventListener('change', () => afAlElegirCategoria(true));
        document.getElementById('afFecha').addEventListener('change', () => afPintarCatDep(document.getElementById('afCatDep').value || null));
        document.getElementById('afCosto').addEventListener('input', () => afAlElegirCategoria(false));
    }
    document.querySelectorAll('input[name="afDep"]').forEach((r) => r.addEventListener('change', afMostrarDep));

    await afRenderLista();
    await afRenderHistorial();
    montarGuia(cont, 'activos-fijos');
}

// Categorías que rigen en el ejercicio de la fecha de adquisición (conserva la elegida aunque ya no rija).
function afPintarCatDep(sel) {
    const el = document.getElementById('afCatDep');
    if (!el) return;
    const anio = Number(String(document.getElementById('afFecha').value || '').slice(0, 4)) || new Date().getFullYear();
    el.innerHTML = opcionesCategoriaDep(afCatsDep, anio, sel);
    el.value = sel ? String(sel) : '';
    afAlElegirCategoria(false);
}

// Muestra el fundamento, tope y parte no deducible; con `precargar` sugiere la vida útil (editable) y el nombre de la categoría.
function afAlElegirCategoria(precargar) {
    const el = document.getElementById('afCatDep');
    const info = document.getElementById('afCatDepInfo');
    if (!el || !info) return;
    const fila = afCatsDep.find((c) => c.id === Number(el.value));
    if (!fila) { info.classList.add('hidden'); if (precargar) document.getElementById('afCategoria').value = ''; return; }
    if (precargar) {
        document.getElementById('afCategoria').value = fila.categoria;
        const vida = document.getElementById('afVidaUtil');
        if (vida && (!vida.value || vida.dataset.auto === '1')) { vida.value = vidaMesesDePct(fila.pct_anual); vida.dataset.auto = '1'; }
    }
    const costo = parseFloat(document.getElementById('afCosto').value) || 0;
    const noDed = fila.tope_deducible && costo > fila.tope_deducible ? ` · <b class="text-amber-300">parte no deducible para ISR: ${money(costo - fila.tope_deducible)}</b>` : '';
    info.innerHTML = `${textoCategoriaDep(fila)}${noDed}<br><span class="text-slate-500">El % es un tope: la vida útil de abajo (sugerida de ese %) es la que usa la depreciación contable y puedes ajustarla.</span>`;
    info.classList.remove('hidden');
}

const afEsDep = () => !afNuevo || document.querySelector('input[name="afDep"]:checked')?.value === 'si';

function afMostrarEtapas() {
    const wrap = document.getElementById('afEtapasWrap');
    if (wrap) wrap.classList.toggle('hidden', !afEsDep() || !esCuentaCif(document.getElementById('afCtaGasto').value));
}

// Muestra el bloque de costo/vida/cuentas solo si el equipo es depreciable y precarga las cuentas de siempre
function afMostrarDep() {
    if (!afNuevo) return;
    const dep = afEsDep();
    document.getElementById('afDepWrap').classList.toggle('hidden', !dep);
    // "Costo histórico" solo para el que se marca No depreciable (y no viene de una compra: ese ya trae su costo real).
    document.getElementById('afHistWrap')?.classList.toggle('hidden', dep || afEditLigado || document.querySelector('input[name="afDep"]:checked')?.value !== 'no');
    if (dep) {
        const pon = (id, cod) => { const el = document.getElementById(id); if (el && !el.value) el.value = afIdCuenta(cod); };
        pon('afCtaActivo', '152.01'); pon('afCtaGasto', '503.04'); pon('afCtaAcumulada', '153.01');
    }
    afMostrarEtapas();
}

function afResetForm() {
    afActivoEditId = null;
    afEditPendiente = false; afEditLigado = false;
    document.getElementById('afPendAviso')?.classList.add('hidden');
    ['afCosto', 'afFecha'].forEach((id) => { const el = document.getElementById(id); if (el) { el.readOnly = false; el.classList.remove('opacity-60'); } });
    document.getElementById('afFormTitulo').textContent = 'Nuevo activo fijo';
    document.getElementById('afNombre').value = '';
    document.getElementById('afCategoria').value = '';
    afCatOrig = null;
    document.getElementById('afFecha').value = hoyISO();
    document.getElementById('afCosto').value = '';
    const hist0 = document.getElementById('afCostoHist'); if (hist0) hist0.value = '';
    document.getElementById('afResidual').value = '0';
    document.getElementById('afVidaUtil').value = '';
    delete document.getElementById('afVidaUtil').dataset.auto;
    document.getElementById('afCtaActivo').value = '';
    document.getElementById('afCtaGasto').value = '';
    document.getElementById('afCtaAcumulada').value = '';
    document.getElementById('afNotas').value = '';
    document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = false; });
    if (afNuevo) {
        document.getElementById('afArea').value = '';
        document.getElementById('afTipoCarga').value = 'equipo';
        document.getElementById('afPot').value = '';
        document.getElementById('afPotU').value = 'kW';
        document.getElementById('afCant').value = '1';
        document.getElementById('afFu').value = '1';
        document.querySelectorAll('input[name="afDep"]').forEach((r) => { r.checked = false; });
    }
    afMostrarDep();
    afMostrarEtapas();
    if (afCatsDep.length) afPintarCatDep(null);
    document.getElementById('afGuardar').textContent = 'Guardar activo';
    document.getElementById('afCancelarEdicion').classList.add('hidden');
}

async function afGuardarActivo() {
    const msg = document.getElementById('afMsg');
    const nombre = document.getElementById('afNombre').value.trim();
    const costo = parseFloat(document.getElementById('afCosto').value) || 0;
    const vidaUtil = parseInt(document.getElementById('afVidaUtil').value) || 0;
    const dep = afEsDep();
    const falla = (t) => { msg.textContent = t; msg.className = 'text-xs mt-2 text-rose-400'; };
    if (!nombre) return falla('El nombre es obligatorio.');
    if (afNuevo) {
        if (!document.getElementById('afArea').value) return falla('Elige el área donde está el equipo.');
        if (document.getElementById('afPot').value === '' || !(parseFloat(document.getElementById('afPot').value) >= 0)) return falla('Captura la potencia de placa (pon 0 si no usa electricidad).');
        if (!(parseInt(document.getElementById('afCant').value) >= 1)) return falla('La cantidad debe ser al menos 1.');
        const fu = parseFloat(document.getElementById('afFu').value);
        if (!(fu > 0 && fu <= 1)) return falla('El factor de uso debe estar entre 0.01 y 1.');
        if (!document.querySelector('input[name="afDep"]:checked')) return falla('Indica si el equipo es Depreciable o No depreciable.');
    }
    if (dep) {
        if (costo <= 0) return falla('El costo de adquisición debe ser mayor a 0.');
        if (vidaUtil <= 0) return falla('La vida útil debe ser mayor a 0 meses.');
        if (afNuevo && !(document.getElementById('afCtaActivo').value && document.getElementById('afCtaGasto').value && document.getElementById('afCtaAcumulada').value)) {
            return falla('Un equipo depreciable necesita sus tres cuentas (activo, gasto de depreciación y depreciación acumulada).');
        }
    }

    const payload = {
        nombre,
        categoria: document.getElementById('afCategoria').value.trim() || null,
        fecha_adquisicion: document.getElementById('afFecha').value || hoyISO(),
        // Un activo que viene de una compra conserva su costo aunque no se deprecie (ya está en la cuenta de activo).
        // No depreciable sin compra: el costo histórico es opcional (solo para el listado).
        costo_adquisicion: (dep || afEditLigado) ? costo : (parseFloat(document.getElementById('afCostoHist')?.value) > 0 ? parseFloat(document.getElementById('afCostoHist').value) : null),
        valor_residual: dep ? (parseFloat(document.getElementById('afResidual').value) || 0) : 0,
        vida_util_meses: dep ? vidaUtil : null,
        cuenta_activo_id: dep && document.getElementById('afCtaActivo').value ? parseInt(document.getElementById('afCtaActivo').value) : null,
        cuenta_depreciacion_gasto_id: dep && document.getElementById('afCtaGasto').value ? parseInt(document.getElementById('afCtaGasto').value) : null,
        cuenta_depreciacion_acumulada_id: dep && document.getElementById('afCtaAcumulada').value ? parseInt(document.getElementById('afCtaAcumulada').value) : null,
        notas: document.getElementById('afNotas').value.trim() || null,
    };
    if (afCatsDep.length) {
        const catId = Number(document.getElementById('afCatDep')?.value) || null;
        if (catId && afCatOrig && afCatOrig.id === catId) {
            // misma categoría que ya traía: se conserva la copia del % y tope de su ejercicio
            Object.assign(payload, { categoria_depreciacion_id: catId, pct_fiscal: afCatOrig.pct, tope_fiscal: afCatOrig.tope, ejercicio_fiscal: afCatOrig.ej });
        } else if (catId) {
            const f = afCatsDep.find((c) => c.id === catId);
            Object.assign(payload, { categoria_depreciacion_id: catId, pct_fiscal: f.pct_anual, tope_fiscal: f.tope_deducible,
                ejercicio_fiscal: Number(String(payload.fecha_adquisicion).slice(0, 4)) || new Date().getFullYear() });
        } else {
            Object.assign(payload, { categoria_depreciacion_id: null, pct_fiscal: null, tope_fiscal: null, ejercicio_fiscal: null });
        }
    }
    if (afPend && afActivoEditId && afEditPendiente) payload.pendiente = false;   // ya se completó: entra a la depreciación
    if (afNuevo) {
        Object.assign(payload, {
            depreciable: dep,
            area_id: parseInt(document.getElementById('afArea').value),
            tipo_carga: document.getElementById('afTipoCarga').value,
            potencia_kw: Math.round(parseFloat(document.getElementById('afPot').value) * (UNIDAD_KW[document.getElementById('afPotU').value] || 1) * 1000) / 1000,
            cantidad: parseInt(document.getElementById('afCant').value),
            factor_uso: parseFloat(document.getElementById('afFu').value),
        });
    }

    try {
        let error, activoId = afActivoEditId;
        if (afActivoEditId) {
            ({ error } = await supabaseClient.from('activos_fijos').update(payload).eq('id', afActivoEditId));
        } else {
            const ins = await supabaseClient.from('activos_fijos').insert([payload]).select('id').single();
            error = ins.error; activoId = ins.data?.id;
        }
        if (error) throw error;
        // etapas donde se usa (solo si la cuenta de gasto es 503.xx y la migración está corrida)
        let sinEtapas = false;
        if (afTieneEtapas && activoId) {
            const marcadas = dep && esCuentaCif(payload.cuenta_depreciacion_gasto_id)
                ? [...document.querySelectorAll('.afEtapaChk:checked')].map((c) => Number(c.value)) : [];
            const del = await supabaseClient.from('activos_fijos_centros').delete().eq('activo_id', activoId);
            if (del.error) throw del.error;
            if (marcadas.length) {
                const ins2 = await supabaseClient.from('activos_fijos_centros').insert(marcadas.map((c) => ({ activo_id: activoId, centro_costo_id: c })));
                if (ins2.error) throw ins2.error;
            }
            sinEtapas = dep && esCuentaCif(payload.cuenta_depreciacion_gasto_id) && !marcadas.length;
        }
        const completado = !!(afActivoEditId && afEditPendiente);
        msg.textContent = (completado ? 'Activo completado: ya entra a la depreciación del mes.' : (afActivoEditId ? 'Activo actualizado.' : 'Activo guardado.'))
            + (sinEtapas ? ' ⚠ Sin etapas: su depreciación NO se repartirá al prorrateo hasta que las marques.' : '');
        msg.className = 'text-xs mt-2 ' + (sinEtapas ? 'text-amber-400' : 'text-emerald-400');
        afResetForm();
        await afRenderLista();
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    }
}

async function afRenderLista() {
    const cont = document.getElementById('afLista');
    try {
        const { data, error } = await supabaseClient
            .from('activos_fijos')
            .select('id, nombre, categoria, fecha_adquisicion, costo_adquisicion, valor_residual, vida_util_meses, activo, fecha_baja, cuenta_depreciacion_gasto_id' + (afNuevo ? ', depreciable, area_id, potencia_kw, cantidad, factor_uso' : '') + (afCatsDep.length ? ', pct_fiscal' : '') + (afPend ? ', pendiente, documento_id' : ''))
            .order('id', { ascending: false });
        if (error) throw error;
        afEtapasPorActivo = new Map();
        if (afTieneEtapas) {
            const { data: et } = await supabaseClient.from('activos_fijos_centros').select('activo_id, centro_costo_id');
            (et || []).forEach((r) => {
                const cod = afCentros.find((c) => c.id === r.centro_costo_id)?.codigo || ('#' + r.centro_costo_id);
                afEtapasPorActivo.set(r.activo_id, [...(afEtapasPorActivo.get(r.activo_id) || []), cod]);
            });
        }
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin activos fijos registrados.</p>'; return; }
        const nPend = data.filter((a) => a.pendiente).length;
        if (!nPend) afSoloPend = false;
        const avisoPend = nPend ? `
        <div class="mb-2 flex flex-wrap items-center gap-3 bg-amber-950/30 border border-amber-800/50 text-amber-200 rounded-lg p-2.5 text-xs">
          <span>⏳ <b>${nPend}</b> activo(s) fijo(s) llegaron de una compra y están <b>pendientes de completar</b> (área, si se deprecia, vida útil y etapas). Mientras tanto no se deprecian.</span>
          <button type="button" onclick="window.afFiltrarPend()" class="text-[11px] bg-amber-900/60 hover:bg-amber-800 text-amber-100 border border-amber-700 px-2 py-1 rounded">${afSoloPend ? 'Ver todos' : 'Ver solo pendientes'}</button>
        </div>` : '';
        const visibles = afSoloPend ? data.filter((a) => a.pendiente) : data;

        aplicarOrden(afOrden, data, (a, campo) => {
            switch (campo) {
                case 'nombre': return (a.nombre || '').toLowerCase();
                case 'fecha': return a.fecha_adquisicion || '';
                case 'costo': return Number(a.costo_adquisicion || 0);
                default: return a.id;
            }
        });

        cont.innerHTML = `${avisoPend}
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Acción</th>${thOrden(afOrden, 'nombre', 'Nombre')}<th class="p-2">Categoría</th>
              ${thOrden(afOrden, 'fecha', 'Adquisición')}${thOrden(afOrden, 'costo', 'Costo', 'text-right justify-end')}
              ${afNuevo ? '<th class="p-2">Área</th><th class="p-2 text-right">kW efect.</th><th class="p-2">Depreciación</th>' : ''}
              <th class="p-2 text-right">Vida útil</th><th class="p-2">Etapas (CIF)</th><th class="p-2">Estatus</th>
            </tr></thead>
            <tbody>
              ${visibles.map((a) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 whitespace-nowrap">
                    ${a.pendiente
                        ? `<button type="button" onclick="window.afEditar(${a.id})" class="text-[11px] bg-amber-700 hover:bg-amber-600 text-white border border-amber-600 px-2 py-1 rounded font-semibold">Completar</button>`
                        : `<button type="button" onclick="window.afEditar(${a.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">Editar</button>`}
                    ${a.activo ? `<button type="button" onclick="window.afDarBaja(${a.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded ml-1">Dar de baja</button>` : ''}
                  </td>
                  <td class="p-2 text-slate-100">${esc(a.nombre)}${a.documento_id ? `<span class="block text-[10px] text-slate-500">Compra · ${linkDoc(a.documento_id, 'recepción #' + a.documento_id, 'font-mono text-sky-300')}</span>` : ''}</td>
                  <td class="p-2 text-slate-400">${esc(a.categoria || '—')}${a.pct_fiscal != null ? `<span class="block text-[10px] text-slate-500">LISR máx. ${Number(a.pct_fiscal)}%</span>` : ''}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${a.fecha_adquisicion || ''}</td>
                  <td class="p-2 text-right font-mono">${a.costo_adquisicion == null ? '—' : money(a.costo_adquisicion)}</td>
                  ${afNuevo ? `
                  <td class="p-2 whitespace-nowrap">${a.area_id ? esc(afAreas.find((x) => x.id === a.area_id)?.codigo || '#' + a.area_id) : (a.pendiente ? '<span class="text-slate-600">—</span>' : '<span class="text-amber-400" title="Sin área no cuenta para la luz">⚠ sin área</span>')}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${a.potencia_kw == null ? (a.pendiente ? '<span class="text-slate-600">—</span>' : '<span class="text-amber-400" title="Sin potencia no cuenta para la luz">⚠</span>') : (Number(a.potencia_kw) * Number(a.cantidad || 1) * Number(a.factor_uso || 1)).toLocaleString('es-MX', { maximumFractionDigits: 3 })}</td>
                  <td class="p-2">${a.pendiente ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-amber-300 bg-amber-950/40">Por definir</span>' : a.depreciable ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-sky-300 bg-sky-950/40">Depreciable</span>' : '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-slate-300 bg-slate-800">No depreciable</span>'}</td>` : ''}
                  <td class="p-2 text-right font-mono text-slate-400">${a.vida_util_meses ?? '—'}</td>
                  <td class="p-2 text-xs">${a.pendiente ? '<span class="text-slate-600">—</span>' : (afNuevo && !a.depreciable) ? '<span class="text-slate-600">no aplica</span>' : esCuentaCif(a.cuenta_depreciacion_gasto_id)
                      ? ((afEtapasPorActivo.get(a.id) || []).length ? `<span class="text-emerald-400">${esc(afEtapasPorActivo.get(a.id).join(', '))}</span>` : (afTieneEtapas ? '<span class="text-amber-400" title="Sin etapas no se prorratea">⚠ sin etapas</span>' : '<span class="text-slate-500">—</span>'))
                      : '<span class="text-slate-600">no aplica</span>'}</td>
                  <td class="p-2">${a.pendiente ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-amber-300 bg-amber-950/40">⏳ pendiente de completar</span>' : a.activo ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-emerald-300 bg-emerald-950/40">activo</span>' : `<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-slate-400 bg-slate-800">de baja${a.fecha_baja ? ' ' + a.fecha_baja : ''}</span>`}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, afOrden, afRenderLista);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.afEditar = async (id) => {
    const { data: a, error } = await supabaseClient.from('activos_fijos').select('*').eq('id', id).single();
    if (error || !a) { alert('No se pudo cargar el activo: ' + (error?.message || 'no encontrado')); return; }
    afActivoEditId = id;
    afEditPendiente = !!a.pendiente;
    afEditLigado = !!a.documento_id;
    document.getElementById('afFormTitulo').textContent = a.pendiente ? 'Completar activo fijo (viene de una compra)' : 'Editar activo fijo';
    const avisoP = document.getElementById('afPendAviso');
    if (avisoP) {
        if (a.documento_id) {
            avisoP.innerHTML = `Este equipo llegó de la compra · recepción ${linkDoc(a.documento_id, '#' + a.documento_id, 'font-mono text-sky-300')}. Su <b>costo</b> y su <b>fecha</b> vienen de esa compra y no se editan aquí.`
                + (a.pendiente ? ' <b>Falta:</b> área donde está, potencia, si se deprecia y, si se deprecia, su vida útil, cuentas y etapas.' : '');
            avisoP.classList.remove('hidden');
        } else avisoP.classList.add('hidden');
    }
    ['afCosto', 'afFecha'].forEach((cid) => { const el = document.getElementById(cid); if (el) { el.readOnly = afEditLigado; el.classList.toggle('opacity-60', afEditLigado); } });
    document.getElementById('afNombre').value = a.nombre || '';
    document.getElementById('afCategoria').value = a.categoria || '';
    document.getElementById('afFecha').value = a.fecha_adquisicion || '';
    document.getElementById('afCosto').value = a.costo_adquisicion || '';
    document.getElementById('afResidual').value = a.valor_residual || 0;
    document.getElementById('afVidaUtil').value = a.vida_util_meses || '';
    document.getElementById('afCtaActivo').value = a.cuenta_activo_id || '';
    document.getElementById('afCtaGasto').value = a.cuenta_depreciacion_gasto_id || '';
    document.getElementById('afCtaAcumulada').value = a.cuenta_depreciacion_acumulada_id || '';
    document.getElementById('afNotas').value = a.notas || '';
    afCatOrig = a.categoria_depreciacion_id ? { id: a.categoria_depreciacion_id, pct: a.pct_fiscal, tope: a.tope_fiscal, ej: a.ejercicio_fiscal } : null;
    if (afCatsDep.length) afPintarCatDep(a.categoria_depreciacion_id || null);
    if (afCatsDep.length && a.pendiente && afCatOrig && !a.vida_util_meses && a.pct_fiscal) {
        const vida = document.getElementById('afVidaUtil');
        vida.value = vidaMesesDePct(a.pct_fiscal); vida.dataset.auto = '1';   // sugerida de su categoría; editable
    }
    if (afNuevo) {
        document.getElementById('afArea').value = a.area_id || '';
        document.getElementById('afTipoCarga').value = a.tipo_carga || 'equipo';
        document.getElementById('afPot').value = a.potencia_kw ?? '';
        document.getElementById('afPotU').value = 'kW';
        document.getElementById('afCant').value = a.cantidad || 1;
        document.getElementById('afFu').value = a.factor_uso ?? 1;
        // Pendiente de completar: el usuario decide explícitamente si se deprecia (no se asume).
        document.querySelectorAll('input[name="afDep"]').forEach((r) => { r.checked = !a.pendiente && r.value === (a.depreciable ? 'si' : 'no'); });
        document.getElementById('afDepWrap').classList.toggle('hidden', !!a.pendiente || !a.depreciable);
        const hist = document.getElementById('afCostoHist');
        if (hist) hist.value = (!a.depreciable && !a.documento_id && a.costo_adquisicion != null) ? a.costo_adquisicion : '';
        afMostrarDep();
    }
    document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = false; });
    if (afTieneEtapas) {
        const { data: et } = await supabaseClient.from('activos_fijos_centros').select('centro_costo_id').eq('activo_id', id);
        const ids = new Set((et || []).map((r) => r.centro_costo_id));
        document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = ids.has(Number(c.value)); });
    }
    afMostrarEtapas();
    document.getElementById('afGuardar').textContent = a.pendiente ? 'Completar y guardar activo' : 'Actualizar activo';
    document.getElementById('afCancelarEdicion').classList.remove('hidden');
    document.getElementById('afNombre').scrollIntoView({ behavior: 'smooth', block: 'start' });
};

window.afFiltrarPend = async () => { afSoloPend = !afSoloPend; await afRenderLista(); };

window.afDarBaja = async (id) => {
    const motivo = prompt('¿Por qué se da de baja este activo? (venta, obsolescencia, siniestro...)');
    if (motivo === null) return;
    const fecha = prompt('Fecha de baja (AAAA-MM-DD):', hoyISO());
    if (fecha === null) return;
    const { error } = await supabaseClient.from('activos_fijos')
        .update({ activo: false, fecha_baja: fecha || hoyISO(), motivo_baja: motivo || null })
        .eq('id', id);
    if (error) { alert('No se pudo dar de baja: ' + error.message); return; }
    await afRenderLista();
};

async function afCalcularDepreciacion() {
    const cont = document.getElementById('afPreview');
    const anio = parseInt(document.getElementById('afAnio').value) || new Date().getFullYear();
    const mes = parseInt(document.getElementById('afMes').value) || (new Date().getMonth() + 1);
    cont.innerHTML = '<p class="text-slate-500 text-sm">Calculando...</p>';
    try {
        const { data, error } = await supabaseClient.rpc('depreciacion_calcular', { p_anio: anio, p_mes: mes });
        if (error) throw error;
        const filas = (data || []).filter((f) => Number(f.monto_mes) > 0);
        if (!filas.length) {
            cont.innerHTML = '<p class="text-slate-500 text-sm">No hay depreciación pendiente de aplicar para ese mes (o ya se aplicó).</p>';
            return;
        }
        const total = filas.reduce((a, f) => a + Number(f.monto_mes || 0), 0);
        cont.innerHTML = `
          <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
            <table class="w-full text-left text-xs text-slate-300">
              <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
                <th class="p-2">Activo</th><th class="p-2 text-right">Valor en libros</th><th class="p-2 text-right">Depreciación del mes</th>
              </tr></thead>
              <tbody>
                ${filas.map((f) => `
                  <tr class="border-b border-slate-900">
                    <td class="p-2 text-slate-100">${esc(f.nombre)}</td>
                    <td class="p-2 text-right font-mono text-slate-400">${money(f.valor_en_libros)}</td>
                    <td class="p-2 text-right font-mono text-emerald-400">${money(f.monto_mes)}</td>
                  </tr>`).join('')}
              </tbody>
              <tfoot><tr><td class="p-2 text-right font-semibold text-slate-400" colspan="2">Total</td><td class="p-2 text-right font-mono font-semibold text-emerald-300">${money(total)}</td></tr></tfoot>
            </table>
          </div>
          <button type="button" id="afAplicar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Aplicar depreciación de ${mes}/${anio}</button>
          <p id="afMsgAplicar" class="text-xs mt-2 min-h-[1rem]"></p>`;
        document.getElementById('afAplicar').onclick = async () => {
            const msgA = document.getElementById('afMsgAplicar');
            if (!confirm(`¿Aplicar la depreciación de ${mes}/${anio} por un total de ${money(total)}? Se generará una póliza.`)) return;
            try {
                const { error: eAp } = await supabaseClient.rpc('depreciacion_aplicar', { p_anio: anio, p_mes: mes });
                if (eAp) throw eAp;
                msgA.textContent = 'Depreciación aplicada.';
                msgA.className = 'text-xs mt-2 text-emerald-400';
                await afCalcularDepreciacion();
                await afRenderHistorial();
            } catch (err) {
                msgA.textContent = 'No se pudo aplicar: ' + (err.message || err);
                msgA.className = 'text-xs mt-2 text-rose-400';
            }
        };
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

async function afRenderHistorial() {
    const cont = document.getElementById('afHistorial');
    try {
        const { data, error } = await supabaseClient
            .from('activos_fijos_depreciaciones')
            .select('anio, mes, monto, poliza_id, activos_fijos ( nombre )')
            .order('anio', { ascending: false })
            .order('mes', { ascending: false })
            .limit(300);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Todavía no se ha aplicado ninguna depreciación.</p>'; return; }

        const porMes = new Map();
        data.forEach((d) => {
            const key = `${d.anio}-${String(d.mes).padStart(2, '0')}`;
            if (!porMes.has(key)) porMes.set(key, { anio: d.anio, mes: d.mes, total: 0, polizaId: d.poliza_id, n: 0 });
            const g = porMes.get(key);
            g.total += Number(d.monto || 0);
            g.n += 1;
        });
        const meses = [...porMes.values()].sort((a, b) => (b.anio - a.anio) || (b.mes - a.mes));

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Mes</th><th class="p-2 text-right">Activos</th><th class="p-2 text-right">Total</th><th class="p-2">Póliza</th><th class="p-2"></th>
            </tr></thead>
            <tbody>
              ${meses.map((m) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 text-slate-100">${String(m.mes).padStart(2, '0')}/${m.anio}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${m.n}</td>
                  <td class="p-2 text-right font-mono">${money(m.total)}</td>
                  <td class="p-2">${linkPoliza(m.polizaId)}</td>
                  <td class="p-2 text-right"><button type="button" onclick="window.afCancelarMes(${m.anio}, ${m.mes})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded">Cancelar</button></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.afCancelarMes = async (anio, mes) => {
    if (!confirm(`¿Cancelar la depreciación aplicada de ${mes}/${anio}? Se revertirá la póliza.`)) return;
    const { error } = await supabaseClient.rpc('depreciacion_cancelar', { p_anio: anio, p_mes: mes });
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await afRenderHistorial();
    await afCalcularDepreciacion();
};
