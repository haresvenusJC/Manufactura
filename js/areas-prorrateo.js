import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';

const afOrden = crearOrdenTabla('codigo');
const afcOrden = crearOrdenTabla();

// =====================================================================
// Contabilidad · Áreas y bases de prorrateo (pre-herramienta)
//   Declara m², carga eléctrica (kW) y nº de personas por área. De aquí
//   se derivan los % de reparto de gastos compartidos (Nivel 1:
//   producción vs no producción · Nivel 2: SURT/MEZ/ENV), en vez de
//   teclearlos a mano.
//   Requiere sql/2026-09-17_areas_bases_prorrateo.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const num = (v, d = 0) => { const n = parseFloat(v); return Number.isFinite(n) ? n : d; };
const fnum = (n, d = 2) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: d });
const fpct = (f) => (Number(f || 0) * 100).toLocaleString('es-MX', { maximumFractionDigits: 1 }) + '%';
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

const MANUAL_URL = 'manual-costos-produccion.html';
const GUIA_URL = 'guia-costos-produccion.html';
const ROL_LABEL = { produccion: 'Producción', no_produccion: 'No producción' };
const TIPO_CARGA = { equipo: 'Equipo', iluminacion: 'Iluminación', clima: 'Clima / HVAC', otro: 'Otro' };

const hint = (t) => `<span class="hint" tabindex="0" role="note" aria-label="${esc(t)}" data-tip="${esc(t)}">?</span>`;

const estado = { areas: [], cargas: [], kw: {}, bases: [], centros: [] };
let areaEditId = null;
let cargaEditId = null;
let cargaAreaSel = null;

export async function cargarModuloAreasProrrateo() {
    const cont = document.getElementById('contenedorAreasProrrateo');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    try {
        const { data: centros, error: eC } = await supabaseClient
            .from('centros_costo').select('id, codigo, nombre, tipo, activo')
            .eq('tipo', 'produccion').eq('activo', true).order('codigo');
        if (eC) throw eC;
        estado.centros = centros || [];
    } catch (err) {
        if (TABLA_FALTA.test(err.message || '')) {
            cont.innerHTML = `<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-14_costos_produccion_fase1.sql</span> en Supabase.</p>`;
            return;
        }
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || String(err))}</p>`;
        return;
    }

    cont.innerHTML = `
    <div class="flex flex-wrap items-center justify-between gap-2 mb-4">
      <p class="text-xs text-slate-400 max-w-2xl">Declara las <span class="text-slate-300">áreas físicas</span> de la instalación con sus m², su carga eléctrica y su gente. Los % con que se reparten renta, energía y servicios se calculan de aquí — actualiza una vez y todos los repartos se recalculan.</p>
      <div class="shrink-0 flex gap-2">
        <a href="${GUIA_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">▶ Guía</a>
        <a href="${MANUAL_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">📖 Manual</a>
      </div>
    </div>
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
      <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
        <div class="flex items-center justify-between">
          <h3 class="text-md font-semibold text-sky-400" id="afFormTitulo">Nueva área</h3>
          <button type="button" id="afNuevo" class="hidden text-[11px] text-slate-400 hover:text-slate-200">+ Nueva</button>
        </div>
        <form id="afForm" class="space-y-3">
          <div class="grid grid-cols-2 gap-2">
            <div><label class="block text-[11px] text-slate-400 mb-1">Código <span class="text-rose-400">*</span>${hint('Corto y en mayúsculas. Ej. ENV, COSM, OFIC.')}</label>
              <input type="text" id="afCodigo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase" required></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Nombre <span class="text-rose-400">*</span></label>
              <input type="text" id="afNombre" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
          </div>
          <div class="grid grid-cols-2 gap-2">
            <div><label class="block text-[11px] text-slate-400 mb-1">Rol${hint('Producción: su gasto entra al costo de los lotes vía su centro. No producción: su parte de los servicios se va a resultados (601.xx), nunca al inventario.')}</label>
              <select id="afRol" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                ${Object.entries(ROL_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
              </select></div>
            <div id="afCentroWrap"><label class="block text-[11px] text-slate-400 mb-1">Centro de costo${hint('A qué etapa de producción pertenece esta área. Varias áreas pueden apuntar al mismo centro (ej. Lotificación y Acondicionamiento → ENV).')}</label>
              <select id="afCentro" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <option value="">— (elige) —</option>
                ${estado.centros.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('')}
              </select></div>
          </div>
          <div class="grid grid-cols-3 gap-2">
            <div><label class="block text-[10px] text-slate-400 mb-1">m²${hint('Superficie que ocupa el área, medida del plano. Base para renta, predial, vigilancia, limpieza.')}</label>
              <input type="number" min="0" step="0.01" id="afM2" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
            <div><label class="block text-[10px] text-slate-400 mb-1">kWh/mes medido${hint('Solo si el área tiene submedidor. Si lo pones, se usa este dato para la base kW en vez del kW instalado calculado de las cargas. Déjalo vacío si no lo mides.')}</label>
              <input type="number" min="0" step="0.01" id="afKwh" placeholder="—" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
            <div><label class="block text-[10px] text-slate-400 mb-1">Personas${hint('Cuánta gente trabaja habitualmente en el área. Base para internet, teléfono, papelería.')}</label>
              <input type="number" min="0" step="1" id="afPersonas" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
          </div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Notas</label>
            <input type="text" id="afNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <label class="flex items-center gap-2 text-[11px] text-slate-300">
            <input type="checkbox" id="afActivo" checked class="accent-emerald-500 w-3.5 h-3.5"> Activo
          </label>
          <button type="submit" id="afGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm cursor-pointer">Guardar área</button>
          <p id="afMsg" class="text-xs min-h-[1rem]"></p>
        </form>
      </div>

      <div class="xl:col-span-2 space-y-6">
        <div id="afTablero" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando...</div>
        <div id="afLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500"></div>
        <div id="afCargas" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500"></div>
      </div>
    </div>`;

    afCablear();
    await recargar();
    montarGuia(cont, 'areas-prorrateo');
}

function afCablear() {
    const $ = (id) => document.getElementById(id);
    $('afRol').addEventListener('change', () => {
        $('afCentroWrap').classList.toggle('hidden', $('afRol').value !== 'produccion');
    });
    $('afForm').addEventListener('submit', afGuardar);
    $('afNuevo').addEventListener('click', afResetForm);
}

async function recargar() {
    const [areas, cargas, kw, bases] = await Promise.all([
        supabaseClient.from('areas_fisicas').select('*').order('codigo'),
        supabaseClient.from('areas_fisicas_cargas').select('*').order('id'),
        supabaseClient.from('v_areas_carga').select('*'),
        supabaseClient.from('v_bases_prorrateo').select('*'),
    ]);
    const err = areas.error || cargas.error || kw.error || bases.error;
    if (err) {
        const m = err.message || String(err);
        document.getElementById('afTablero').innerHTML = TABLA_FALTA.test(m)
            ? `<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-17_areas_bases_prorrateo.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-xs">${esc(m)}</p>`;
        document.getElementById('afLista').innerHTML = '';
        document.getElementById('afCargas').innerHTML = '';
        return;
    }
    estado.areas = areas.data || [];
    estado.cargas = cargas.data || [];
    estado.kw = {};
    (kw.data || []).forEach(r => { estado.kw[r.area_id] = Number(r.kw_efectivo || 0); });
    estado.bases = bases.data || [];
    if (cargaAreaSel == null && estado.areas.length) cargaAreaSel = estado.areas[0].id;

    pintarTablero();
    pintarLista();
    pintarCargas();
}

function pintarTablero() {
    const cont = document.getElementById('afTablero');
    const porBase = (b) => estado.bases.filter(r => r.base === b);
    const filaResumen = (b) => {
        const rows = porBase(b);
        const prod = rows.filter(r => r.rol === 'produccion').reduce((s, r) => s + Number(r.fraccion || 0), 0);
        return { prod, noProd: 1 - prod || 0, hay: rows.some(r => Number(r.valor || 0) > 0) };
    };
    const areasOrden = [...estado.areas].sort((a, b) => a.codigo.localeCompare(b.codigo));
    const frac = (b, areaId) => {
        const r = estado.bases.find(x => x.base === b && x.area_id === areaId);
        return r ? Number(r.fraccion || 0) : 0;
    };
    const rM2 = filaResumen('m2'), rKw = filaResumen('kw'), rPer = filaResumen('personas');

    cont.innerHTML = `
      <h3 class="text-md font-semibold text-sky-400 mb-1">Bases de prorrateo</h3>
      <p class="text-[10px] text-slate-500 mb-3">Cada columna de % es cómo se repartiría un gasto que use esa base. La fila final es el Nivel 1: producción vs no producción.</p>
      <div class="overflow-x-auto">
      <table class="w-full text-xs whitespace-nowrap">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800">
          <th class="p-2">Área</th><th class="p-2">Rol</th>
          <th class="p-2 text-right">m²</th><th class="p-2 text-right">% m²</th>
          <th class="p-2 text-right">kW efect.</th><th class="p-2 text-right">% kW</th>
          <th class="p-2 text-right">Personas</th><th class="p-2 text-right">% pers.</th>
        </tr></thead>
        <tbody>
          ${areasOrden.filter(a => a.activo).map(a => `
            <tr class="border-b border-slate-900">
              <td class="p-2 font-mono text-slate-200">${esc(a.codigo)}</td>
              <td class="p-2 ${a.rol === 'produccion' ? 'text-emerald-400' : 'text-amber-400'}">${ROL_LABEL[a.rol]}</td>
              <td class="p-2 text-right font-mono text-slate-300">${fnum(a.m2)}</td>
              <td class="p-2 text-right font-mono text-slate-400">${fpct(frac('m2', a.id))}</td>
              <td class="p-2 text-right font-mono text-slate-300">${a.kwh_mensual != null ? fnum(a.kwh_mensual) + ' *' : fnum(estado.kw[a.id] || 0, 3)}</td>
              <td class="p-2 text-right font-mono text-slate-400">${fpct(frac('kw', a.id))}</td>
              <td class="p-2 text-right font-mono text-slate-300">${a.personas}</td>
              <td class="p-2 text-right font-mono text-slate-400">${fpct(frac('personas', a.id))}</td>
            </tr>`).join('')}
        </tbody>
        <tfoot>
          <tr class="border-t-2 border-slate-700 text-slate-300">
            <td class="p-2 font-semibold" colspan="2">Nivel 1 — Producción</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono text-emerald-400">${rM2.hay ? fpct(rM2.prod) : '—'}</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono text-emerald-400">${rKw.hay ? fpct(rKw.prod) : '—'}</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono text-emerald-400">${rPer.hay ? fpct(rPer.prod) : '—'}</td>
          </tr>
          <tr class="text-slate-400">
            <td class="p-2" colspan="2">Nivel 1 — No producción</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono">${rM2.hay ? fpct(rM2.noProd) : '—'}</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono">${rKw.hay ? fpct(rKw.noProd) : '—'}</td>
            <td class="p-2"></td><td class="p-2 text-right font-mono">${rPer.hay ? fpct(rPer.noProd) : '—'}</td>
          </tr>
        </tfoot>
      </table>
      </div>
      <p class="text-[10px] text-slate-500 mt-2">* kWh medido por submedidor (se usa en vez del kW instalado). Sin asterisco = kW instalado calculado de las cargas.</p>`;
}

function pintarLista() {
    const cont = document.getElementById('afLista');
    if (!estado.areas.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin áreas. Crea la primera.</p>`; return; }
    const centroCod = (id) => { const c = estado.centros.find(x => x.id === id); return c ? c.codigo : '—'; };

    aplicarOrden(afOrden, estado.areas, (a, campo) => {
        switch (campo) {
            case 'codigo': return (a.codigo || '').toLowerCase();
            case 'nombre': return (a.nombre || '').toLowerCase();
            case 'rol': return a.rol || '';
            case 'centro': return centroCod(a.centro_costo_id).toLowerCase();
            case 'm2': return Number(a.m2 || 0);
            case 'kw': return a.kwh_mensual != null ? Number(a.kwh_mensual) : Number(estado.kw[a.id] || 0);
            case 'personas': return Number(a.personas || 0);
            case 'estado': return a.activo ? 1 : 0;
            default: return a.id;
        }
    });

    cont.innerHTML = `
      <h3 class="text-md font-semibold text-sky-400 mb-3">Áreas</h3>
      <div class="overflow-x-auto">
      <table class="w-full text-xs whitespace-nowrap">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800">
          ${thOrden(afOrden, 'codigo', 'Código')}${thOrden(afOrden, 'nombre', 'Nombre')}${thOrden(afOrden, 'rol', 'Rol')}${thOrden(afOrden, 'centro', 'Centro')}
          ${thOrden(afOrden, 'm2', 'm²', 'text-right justify-end')}${thOrden(afOrden, 'kw', 'kW', 'text-right justify-end')}${thOrden(afOrden, 'personas', 'Pers.', 'text-right justify-end')}
          ${thOrden(afOrden, 'estado', 'Estado')}<th class="p-2"></th>
        </tr></thead>
        <tbody>
          ${estado.areas.map(a => `
            <tr class="border-b border-slate-900">
              <td class="p-2 font-mono text-slate-200">${esc(a.codigo)}</td>
              <td class="p-2 text-slate-300">${esc(a.nombre)}</td>
              <td class="p-2 ${a.rol === 'produccion' ? 'text-emerald-400' : 'text-amber-400'}">${ROL_LABEL[a.rol]}</td>
              <td class="p-2 font-mono text-slate-400">${a.rol === 'produccion' ? esc(centroCod(a.centro_costo_id)) : '—'}</td>
              <td class="p-2 text-right font-mono ${a.m2 > 0 ? 'text-slate-300' : 'text-amber-400'}">${fnum(a.m2)}${a.m2 > 0 ? '' : ' ⚠'}</td>
              <td class="p-2 text-right font-mono text-slate-300">${a.kwh_mensual != null ? fnum(a.kwh_mensual) + '*' : fnum(estado.kw[a.id] || 0, 2)}</td>
              <td class="p-2 text-right font-mono text-slate-300">${a.personas}</td>
              <td class="p-2">${a.activo ? '<span class="text-emerald-400">activo</span>' : '<span class="text-slate-500">inactivo</span>'}</td>
              <td class="p-2 text-right"><button type="button" class="af-edit text-sky-400 hover:underline" data-id="${a.id}">Editar</button></td>
            </tr>`).join('')}
        </tbody>
      </table>
      </div>
      <p class="text-[10px] text-slate-500 mt-2">⚠ m² en 0 = esa área no pesa en el reparto por superficie. Captura al menos m² y personas de cada área.</p>`;
    cont.querySelectorAll('.af-edit').forEach(b => b.addEventListener('click', () => afCargarEnForm(estado.areas.find(a => a.id === Number(b.dataset.id)))));
    wireOrdenTabla(cont, afOrden, pintarLista);
}

function pintarCargas() {
    const cont = document.getElementById('afCargas');
    if (!estado.areas.length) { cont.innerHTML = ''; return; }
    if (!estado.areas.some(a => a.id === cargaAreaSel)) cargaAreaSel = estado.areas[0].id;
    const area = estado.areas.find(a => a.id === cargaAreaSel);
    const cargas = estado.cargas.filter(c => c.area_id === cargaAreaSel);
    const totalKw = cargas.reduce((s, c) => s + c.kw_unitario * c.cantidad * c.factor_uso, 0);

    aplicarOrden(afcOrden, cargas, (c, campo) => {
        switch (campo) {
            case 'descripcion': return (c.descripcion || '').toLowerCase();
            case 'tipo': return (TIPO_CARGA[c.tipo] || c.tipo || '').toLowerCase();
            case 'kw_unit': return Number(c.kw_unitario || 0);
            case 'cantidad': return Number(c.cantidad || 0);
            case 'f_uso': return Number(c.factor_uso || 0);
            case 'kw_efect': return c.kw_unitario * c.cantidad * c.factor_uso;
            default: return c.id;
        }
    });

    cont.innerHTML = `
      <div class="flex flex-wrap items-center justify-between gap-2 mb-3">
        <h3 class="text-md font-semibold text-sky-400">Cargas eléctricas${hint('Los equipos, luminarias y clima de cada área. kW efectivo = kW unitario × cantidad × factor de uso. La suma es el kW instalado del área para la base de energía.')}</h3>
        <select id="afCargaArea" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
          ${estado.areas.map(a => `<option value="${a.id}"${a.id === cargaAreaSel ? ' selected' : ''}>${esc(a.codigo)} · ${esc(a.nombre)}</option>`).join('')}
        </select>
      </div>
      ${area && area.kwh_mensual != null ? `<p class="text-[11px] text-amber-400 mb-2">Esta área tiene kWh medido (${fnum(area.kwh_mensual)} kWh/mes); las cargas de abajo son informativas, la base kW usa el medido.</p>` : ''}
      <div class="overflow-x-auto">
      <table class="w-full text-xs whitespace-nowrap">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800">
          ${thOrden(afcOrden, 'descripcion', 'Descripción')}${thOrden(afcOrden, 'tipo', 'Tipo')}
          ${thOrden(afcOrden, 'kw_unit', 'kW unit.', 'text-right justify-end')}${thOrden(afcOrden, 'cantidad', 'Cant.', 'text-right justify-end')}${thOrden(afcOrden, 'f_uso', 'F. uso', 'text-right justify-end')}
          ${thOrden(afcOrden, 'kw_efect', 'kW efect.', 'text-right justify-end')}<th class="p-2"></th>
        </tr></thead>
        <tbody>
          ${cargas.length ? cargas.map(c => `
            <tr class="border-b border-slate-900">
              <td class="p-2 text-slate-300">${esc(c.descripcion)}</td>
              <td class="p-2 text-slate-400">${TIPO_CARGA[c.tipo] || c.tipo}</td>
              <td class="p-2 text-right font-mono text-slate-300">${fnum(c.kw_unitario, 3)}</td>
              <td class="p-2 text-right font-mono text-slate-300">${c.cantidad}</td>
              <td class="p-2 text-right font-mono text-slate-400">${fnum(c.factor_uso, 2)}</td>
              <td class="p-2 text-right font-mono text-emerald-400">${fnum(c.kw_unitario * c.cantidad * c.factor_uso, 3)}</td>
              <td class="p-2 text-right whitespace-nowrap">
                <button type="button" class="afc-edit text-sky-400 hover:underline" data-id="${c.id}">Editar</button>
                <button type="button" class="afc-del text-rose-400 hover:underline ml-2" data-id="${c.id}">Borrar</button>
              </td>
            </tr>`).join('') : `<tr><td colspan="7" class="p-2 text-slate-500 italic">Sin cargas en esta área.</td></tr>`}
        </tbody>
        <tfoot><tr class="border-t-2 border-slate-700 text-slate-200">
          <td class="p-2 font-semibold" colspan="5">kW instalado del área</td>
          <td class="p-2 text-right font-mono text-emerald-400">${fnum(totalKw, 3)}</td><td></td>
        </tr></tfoot>
      </table>
      </div>

      <form id="afCargaForm" class="grid grid-cols-2 sm:grid-cols-6 gap-2 mt-4 items-end">
        <div class="col-span-2"><label class="block text-[10px] text-slate-400 mb-1">Descripción <span class="text-rose-400">*</span></label>
          <input type="text" id="afcDesc" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100" required></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">Tipo</label>
          <select id="afcTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
            ${Object.entries(TIPO_CARGA).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
          </select></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">kW unit.${hint('Potencia de placa del equipo, en kW. Si viene en HP: 1 HP ≈ 0.746 kW. Si viene en W: divídelo entre 1000.')}</label>
          <input type="number" min="0" step="0.001" id="afcKw" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono" required></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">Cantidad</label>
          <input type="number" min="1" step="1" id="afcCant" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">F. uso${hint('Fracción del tiempo/carga que el equipo demanda de verdad. 1 = siempre a plena carga. Un túnel de vapor que enciende 3 h de un turno de 10: ~0.30.')}</label>
          <input type="number" min="0.01" max="1" step="0.01" id="afcFu" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
        <div class="col-span-2 sm:col-span-6 flex gap-2">
          <button type="submit" id="afcGuardar" class="bg-sky-600 hover:bg-sky-500 text-white font-medium py-2 px-4 rounded-lg text-xs cursor-pointer">Agregar carga</button>
          <button type="button" id="afcCancelar" class="hidden text-xs text-slate-400 hover:text-slate-200 px-2">Cancelar edición</button>
          <span id="afcMsg" class="text-xs self-center"></span>
        </div>
      </form>`;

    document.getElementById('afCargaArea').addEventListener('change', (e) => {
        cargaAreaSel = Number(e.target.value); cargaEditId = null; pintarCargas();
    });
    document.getElementById('afCargaForm').addEventListener('submit', afGuardarCarga);
    document.getElementById('afcCancelar').addEventListener('click', () => { cargaEditId = null; pintarCargas(); });
    wireOrdenTabla(cont, afcOrden, pintarCargas);
    cont.querySelectorAll('.afc-del').forEach(b => b.addEventListener('click', () => afBorrarCarga(Number(b.dataset.id))));
    cont.querySelectorAll('.afc-edit').forEach(b => b.addEventListener('click', () => {
        const c = estado.cargas.find(x => x.id === Number(b.dataset.id));
        if (!c) return;
        cargaEditId = c.id;
        document.getElementById('afcDesc').value = c.descripcion;
        document.getElementById('afcTipo').value = c.tipo;
        document.getElementById('afcKw').value = c.kw_unitario;
        document.getElementById('afcCant').value = c.cantidad;
        document.getElementById('afcFu').value = c.factor_uso;
        document.getElementById('afcGuardar').textContent = 'Guardar cambios';
        document.getElementById('afcCancelar').classList.remove('hidden');
    }));
}

function afResetForm() {
    areaEditId = null;
    const f = document.getElementById('afForm');
    if (f) f.reset();
    document.getElementById('afM2').value = 0;
    document.getElementById('afPersonas').value = 0;
    document.getElementById('afKwh').value = '';
    document.getElementById('afActivo').checked = true;
    document.getElementById('afCentroWrap').classList.remove('hidden');
    document.getElementById('afFormTitulo').textContent = 'Nueva área';
    document.getElementById('afNuevo').classList.add('hidden');
    document.getElementById('afMsg').textContent = '';
}

async function afGuardar(e) {
    e.preventDefault();
    const $ = (id) => document.getElementById(id);
    const msg = $('afMsg');
    msg.className = 'text-xs min-h-[1rem]'; msg.textContent = '';
    const rol = $('afRol').value;
    const row = {
        codigo: $('afCodigo').value.trim().toUpperCase(),
        nombre: $('afNombre').value.trim(),
        rol,
        centro_costo_id: rol === 'produccion' && $('afCentro').value ? Number($('afCentro').value) : null,
        m2: num($('afM2').value),
        kwh_mensual: $('afKwh').value !== '' ? num($('afKwh').value) : null,
        personas: Math.round(num($('afPersonas').value)),
        activo: $('afActivo').checked,
        notas: $('afNotas').value.trim() || null,
    };
    if (!row.codigo || !row.nombre) { msg.textContent = 'Faltan código o nombre.'; msg.className = 'text-xs text-rose-400'; return; }
    if (row.rol === 'produccion' && !row.centro_costo_id) { msg.textContent = 'Un área de producción necesita su centro de costo.'; msg.className = 'text-xs text-rose-400'; return; }

    try {
        $('afGuardar').disabled = true;
        let error;
        if (areaEditId) ({ error } = await supabaseClient.from('areas_fisicas').update(row).eq('id', areaEditId));
        else ({ error } = await supabaseClient.from('areas_fisicas').insert([row]));
        if (error) throw error;
        msg.textContent = areaEditId ? 'Área actualizada.' : 'Área creada.';
        msg.className = 'text-xs text-emerald-400';
        afResetForm();
        await recargar();
    } catch (err) {
        msg.textContent = /duplicate key|unique/i.test(err.message || '') ? 'Ya existe un área con ese código.' : (err.message || String(err));
        msg.className = 'text-xs text-rose-400';
    } finally {
        $('afGuardar').disabled = false;
    }
}

function afCargarEnForm(a) {
    if (!a) return;
    areaEditId = a.id;
    const set = (id, v) => { document.getElementById(id).value = v ?? ''; };
    set('afCodigo', a.codigo); set('afNombre', a.nombre); set('afRol', a.rol);
    set('afCentro', a.centro_costo_id || '');
    set('afM2', a.m2 ?? 0); set('afKwh', a.kwh_mensual ?? ''); set('afPersonas', a.personas ?? 0);
    set('afNotas', a.notas || '');
    document.getElementById('afActivo').checked = !!a.activo;
    document.getElementById('afCentroWrap').classList.toggle('hidden', a.rol !== 'produccion');
    document.getElementById('afFormTitulo').textContent = `Editar ${a.codigo}`;
    document.getElementById('afNuevo').classList.remove('hidden');
    document.getElementById('afMsg').textContent = '';
    document.getElementById('afForm').scrollIntoView({ block: 'nearest' });
}

async function afGuardarCarga(e) {
    e.preventDefault();
    const $ = (id) => document.getElementById(id);
    const msg = $('afcMsg');
    msg.className = 'text-xs self-center'; msg.textContent = '';
    const row = {
        area_id: cargaAreaSel,
        tipo: $('afcTipo').value,
        descripcion: $('afcDesc').value.trim(),
        kw_unitario: num($('afcKw').value),
        cantidad: Math.max(1, Math.round(num($('afcCant').value, 1))),
        factor_uso: Math.min(1, Math.max(0.01, num($('afcFu').value, 1))),
    };
    if (!row.descripcion) { msg.textContent = 'Falta la descripción.'; msg.className = 'text-xs text-rose-400 self-center'; return; }
    try {
        $('afcGuardar').disabled = true;
        let error;
        if (cargaEditId) ({ error } = await supabaseClient.from('areas_fisicas_cargas').update(row).eq('id', cargaEditId));
        else ({ error } = await supabaseClient.from('areas_fisicas_cargas').insert([row]));
        if (error) throw error;
        cargaEditId = null;
        await recargar();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs text-rose-400 self-center';
    } finally {
        const b = document.getElementById('afcGuardar');
        if (b) b.disabled = false;
    }
}

async function afBorrarCarga(id) {
    if (!confirm('¿Borrar esta carga eléctrica?')) return;
    const { error } = await supabaseClient.from('areas_fisicas_cargas').delete().eq('id', id);
    if (error) { alert(error.message || String(error)); return; }
    if (cargaEditId === id) cargaEditId = null;
    await recargar();
}
