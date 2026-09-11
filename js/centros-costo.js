import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';

const ccOrden = crearOrdenTabla('codigo');

// =====================================================================
// Contabilidad · Centros de costo (Costos de producción — Fase 1)
//   Áreas para acumular y prorratear gastos. Cada centro guarda su
//   CAPACIDAD NORMAL en horas de mano de obra al mes: el número que se
//   usa (capacidad_normal_horas, editable) y las variables del cálculo
//   sugerido "de la nómina hacia abajo".
//   Requiere sql/2026-09-14_costos_produccion_fase1.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const num = (v, d = 0) => { const n = parseFloat(v); return Number.isFinite(n) ? n : d; };
const fnum = (n) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 2 });
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

const TIPO_LABEL = { produccion: 'Producción', servicio: 'Servicio', administracion: 'Administración', ventas: 'Ventas' };
const MANUAL_URL = 'manual-costos-produccion.html';
const GUIA_URL = 'guia-costos-produccion.html';

// globo de ayuda: <label>Campo ${hint('texto que aparece al pasar por encima')}</label>
const hint = (t) => `<span class="hint" tabindex="0" role="note" aria-label="${esc(t)}" data-tip="${esc(t)}">?</span>`;

let ccCuentasCif = [];
let ccEditId = null;

export async function cargarModuloCentrosCosto() {
    const cont = document.getElementById('contenedorCentrosCosto');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('id, codigo, nombre, cif_tipo')
            .like('codigo', '503%')
            .eq('afectable', true)
            .order('codigo');
        if (error) throw error;
        ccCuentasCif = data || [];
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
      <p class="text-xs text-slate-400 max-w-xl">Áreas para acumular y prorratear gastos. La <span class="text-slate-300">capacidad normal</span> (horas de mano de obra al mes) aísla la capacidad ociosa para que no ensucie el costo de los lotes.</p>
      <div class="shrink-0 flex gap-2">
        <a href="${GUIA_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">▶ Guía interactiva</a>
        <a href="${MANUAL_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">📖 Manual</a>
      </div>
    </div>
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
      <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
        <div class="flex items-center justify-between">
          <h3 class="text-md font-semibold text-sky-400" id="ccFormTitulo">Nuevo centro de costo</h3>
          <button type="button" id="ccNuevo" class="hidden text-[11px] text-slate-400 hover:text-slate-200">+ Nuevo</button>
        </div>
        <form id="ccForm" class="space-y-3">
          <div class="grid grid-cols-2 gap-2">
            <div><label class="block text-[11px] text-slate-400 mb-1">Código <span class="text-rose-400">*</span>${hint('Corto y en mayúsculas. Ej. PROD, ENV, ALM. Con este código se identifica el centro.')}</label>
              <input type="text" id="ccCodigo" placeholder="PROD" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase" required></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Tipo${hint('Solo el tipo Producción entra al costo de los lotes. Servicio, Administración y Ventas sirven para control de gasto por área.')}</label>
              <select id="ccTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                ${Object.entries(TIPO_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
              </select></div>
          </div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Nombre <span class="text-rose-400">*</span>${hint('Ej. Producción, Envasado, Almacén. Es el nombre que verás en los reportes.')}</label>
            <input type="text" id="ccNombre" placeholder="Producción" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta CIF por defecto${hint('La cuenta 503.xx que se propondrá al capturar un gasto indirecto de este centro. Puedes dejar 503.99 (Otros gastos indirectos).')}</label>
            <select id="ccCuenta" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">— (ninguna) —</option>
              ${ccCuentasCif.filter(c => !/^503$/.test(c.codigo)).map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}${c.cif_tipo ? ' · ' + c.cif_tipo : ''}</option>`).join('')}
            </select></div>

          <div class="border border-slate-800 rounded-lg p-3 bg-slate-900/40 space-y-2">
            <p class="text-[11px] font-semibold text-sky-400">Capacidad normal — horas de mano de obra al mes${hint('Cuántas horas de operarios produce la planta en un mes NORMAL — ni el récord, ni el peor. Es el número que decide cuánto CIF fijo se carga a los productos y cuánto es planta parada.')}</p>
            <p class="text-[10px] text-slate-500">Cálculo sugerido "de la nómina hacia abajo". Llena las variables y usa el sugerido, o captura el número directo abajo.</p>
            <div class="grid grid-cols-3 gap-2">
              <div><label class="block text-[10px] text-slate-400 mb-1">Operadores${hint('Cuántos operarios de producción tienes en total. Ej. 6.')}</label>
                <input type="number" min="0" step="1" id="ccOper" value="0" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
              <div><label class="block text-[10px] text-slate-400 mb-1">Horas jornada${hint('Horas que trabaja un turno. Normalmente 8.')}</label>
                <input type="number" min="1" step="0.5" id="ccJorn" value="8" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
              <div><label class="block text-[10px] text-slate-400 mb-1">Días hábiles/mes${hint('Días que se produce al mes. Normalmente 22–24.')}</label>
                <input type="number" min="1" max="31" step="1" id="ccDias" value="24" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
              <div><label class="block text-[10px] text-slate-400 mb-1">Factor ausentismo${hint('1 menos el % de faltas, vacaciones e incapacidades. 0.90 = 10% de ausentismo. Manufactura MX típico: 8–12%.')}</label>
                <input type="number" min="0" max="1" step="0.01" id="ccFAus" value="0.90" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
              <div><label class="block text-[10px] text-slate-400 mb-1">Factor no productivo${hint('1 menos el % de la jornada que no produce: limpieza, arranque/paro, juntas, esperas de material. 0.80 = 20%. Planta no lean: 15–25%.')}</label>
                <input type="number" min="0" max="1" step="0.01" id="ccFNP" value="0.80" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
              <div><label class="block text-[10px] text-slate-400 mb-1">Factor paros planeados${hint('1 menos el % por mantenimiento programado o días sin pedidos ya conocidos. 0.96 ≈ 1 día/mes.')}</label>
                <input type="number" min="0" max="1" step="0.01" id="ccFPP" value="0.96" class="cc-cap w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 text-right font-mono"></div>
            </div>
            <div class="flex items-center justify-between text-xs bg-slate-900 border border-slate-800 rounded-lg p-2">
              <span class="text-slate-400">Sugerido: <span id="ccSugerido" class="font-mono text-emerald-400">0</span> h/mes</span>
              <button type="button" id="ccUsarSugerido" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">Usar sugerido →</button>
            </div>
            <div><label class="block text-[10px] text-slate-400 mb-1">Capacidad normal que se usa (h/mes) <span class="text-rose-400">*</span>${hint('El número final que usa el prorrateo. Toma el sugerido, o ajústalo si conoces tu operación mejor que la fórmula. Alta gerencia lo revisa 1–2 veces al año.')}</label>
              <input type="number" min="0" step="0.01" id="ccCapNorm" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-emerald-300 text-right font-mono"></div>
          </div>

          <div class="grid grid-cols-2 gap-2">
            <div><label class="block text-[11px] text-slate-400 mb-1">Método CIF${hint('Deja "Real": el prorrateo corre a fin de mes con el gasto real. "Tasa predeterminada" es para una etapa futura y hoy no tiene efecto.')}</label>
              <select id="ccMetodo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <option value="real">Real (a fin de mes)</option>
                <option value="predeterminado">Tasa predeterminada por hora</option>
              </select></div>
            <div id="ccTasaWrap" class="hidden"><label class="block text-[11px] text-slate-400 mb-1">Tasa CIF por hora ($)${hint('Solo si el método es predeterminado. CIF estimado por hora de mano de obra. Aún sin efecto en esta versión.')}</label>
              <input type="number" min="0" step="0.0001" id="ccTasa" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          </div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Notas${hint('Texto libre. Ej. supuestos de la capacidad, quién la autorizó, fecha de última revisión.')}</label>
            <input type="text" id="ccNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <label class="flex items-center gap-2 text-[11px] text-slate-300">
            <input type="checkbox" id="ccActivo" checked class="accent-emerald-500 w-3.5 h-3.5"> Activo${hint('Desmárcalo para dejar de usar el centro sin borrarlo. No aparecerá al capturar gastos.')}
          </label>

          <button type="submit" id="ccGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm cursor-pointer">Guardar centro de costo</button>
          <p id="ccMsg" class="text-xs min-h-[1rem]"></p>
        </form>
      </div>

      <div class="xl:col-span-2">
        <div id="ccLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando centros de costo...</div>
      </div>
    </div>`;

    ccCablear();
    await ccListar();
    ccCalcSugerido();
    montarGuia(cont, 'centros-costo');
}

function ccCablear() {
    const $ = (id) => document.getElementById(id);
    document.querySelectorAll('.cc-cap').forEach(el => el.addEventListener('input', ccCalcSugerido));
    $('ccUsarSugerido').addEventListener('click', () => { $('ccCapNorm').value = ccCalcSugerido(); });
    $('ccMetodo').addEventListener('change', () => {
        $('ccTasaWrap').classList.toggle('hidden', $('ccMetodo').value !== 'predeterminado');
    });
    $('ccForm').addEventListener('submit', ccGuardar);
    $('ccNuevo').addEventListener('click', ccResetForm);
}

function ccCalcSugerido() {
    const g = (id) => num(document.getElementById(id).value);
    const s = g('ccOper') * g('ccJorn') * g('ccDias')
        * g('ccFAus') * g('ccFNP') * g('ccFPP');
    const r = Math.round(s * 100) / 100;
    document.getElementById('ccSugerido').textContent = fnum(r);
    return r;
}

function ccResetForm() {
    ccEditId = null;
    const f = document.getElementById('ccForm');
    if (f) f.reset();
    document.getElementById('ccFormTitulo').textContent = 'Nuevo centro de costo';
    document.getElementById('ccNuevo').classList.add('hidden');
    ['ccJorn', 'ccDias', 'ccFAus', 'ccFNP', 'ccFPP'].forEach((id, i) => {
        document.getElementById(id).value = [null, null, null, null, null][i] ?? document.getElementById(id).value;
    });
    document.getElementById('ccJorn').value = 8;
    document.getElementById('ccDias').value = 24;
    document.getElementById('ccFAus').value = 0.90;
    document.getElementById('ccFNP').value = 0.80;
    document.getElementById('ccFPP').value = 0.96;
    document.getElementById('ccOper').value = 0;
    document.getElementById('ccCapNorm').value = 0;
    document.getElementById('ccActivo').checked = true;
    document.getElementById('ccTasaWrap').classList.add('hidden');
    document.getElementById('ccMsg').textContent = '';
    ccCalcSugerido();
}

async function ccGuardar(e) {
    e.preventDefault();
    const $ = (id) => document.getElementById(id);
    const msg = $('ccMsg');
    msg.className = 'text-xs min-h-[1rem]'; msg.textContent = '';

    const row = {
        codigo: $('ccCodigo').value.trim().toUpperCase(),
        nombre: $('ccNombre').value.trim(),
        tipo: $('ccTipo').value,
        cuenta_cif_default_id: $('ccCuenta').value ? Number($('ccCuenta').value) : null,
        capacidad_normal_horas: num($('ccCapNorm').value),
        cap_operadores: Math.round(num($('ccOper').value)),
        cap_horas_jornada: num($('ccJorn').value, 8),
        cap_dias_habiles_mes: Math.round(num($('ccDias').value, 24)),
        cap_factor_ausentismo: num($('ccFAus').value, 0.90),
        cap_factor_no_productivo: num($('ccFNP').value, 0.80),
        cap_factor_paros_planeados: num($('ccFPP').value, 0.96),
        metodo_cif: $('ccMetodo').value,
        tasa_cif_hora: $('ccMetodo').value === 'predeterminado' && $('ccTasa').value ? num($('ccTasa').value) : null,
        activo: $('ccActivo').checked,
        notas: $('ccNotas').value.trim() || null,
    };
    if (!row.codigo || !row.nombre) { msg.textContent = 'Faltan código o nombre.'; msg.className = 'text-xs text-rose-400'; return; }
    if (row.metodo_cif === 'predeterminado' && !row.tasa_cif_hora) {
        msg.textContent = 'El método predeterminado necesita la tasa CIF por hora.'; msg.className = 'text-xs text-rose-400'; return;
    }

    try {
        $('ccGuardar').disabled = true;
        let error;
        if (ccEditId) {
            ({ error } = await supabaseClient.from('centros_costo').update(row).eq('id', ccEditId));
        } else {
            ({ error } = await supabaseClient.from('centros_costo').insert([row]));
        }
        if (error) throw error;
        msg.textContent = ccEditId ? 'Centro de costo actualizado.' : 'Centro de costo creado.';
        msg.className = 'text-xs text-emerald-400';
        ccResetForm();
        await ccListar();
    } catch (err) {
        msg.textContent = /duplicate key|unique/i.test(err.message || '') ? 'Ya existe un centro con ese código.' : (err.message || String(err));
        msg.className = 'text-xs text-rose-400';
    } finally {
        $('ccGuardar').disabled = false;
    }
}

async function ccListar() {
    const cont = document.getElementById('ccLista');
    if (!cont) return;
    const { data, error } = await supabaseClient
        .from('v_centros_costo')
        .select('*')
        .order('codigo');
    if (error) { cont.innerHTML = `<p class="text-rose-400 text-xs">${esc(error.message || String(error))}</p>`; return; }
    const rows = data || [];
    if (!rows.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin centros de costo. Crea el primero.</p>`; return; }

    aplicarOrden(ccOrden, rows, (c, campo) => {
        switch (campo) {
            case 'codigo': return (c.codigo || '').toLowerCase();
            case 'nombre': return (c.nombre || '').toLowerCase();
            case 'tipo': return (TIPO_LABEL[c.tipo] || c.tipo || '').toLowerCase();
            case 'cap_normal': return Number(c.capacidad_normal_horas || 0);
            case 'sugerido': return Number(c.capacidad_sugerida_horas || 0);
            case 'metodo': return c.metodo_cif || '';
            case 'estado': return c.activo ? 1 : 0;
            default: return c.id;
        }
    });

    cont.innerHTML = `
      <table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800">
          ${thOrden(ccOrden, 'codigo', 'Código')}${thOrden(ccOrden, 'nombre', 'Nombre')}${thOrden(ccOrden, 'tipo', 'Tipo')}
          ${thOrden(ccOrden, 'cap_normal', 'Cap. normal (h/mes)', 'text-right justify-end')}${thOrden(ccOrden, 'sugerido', 'Sugerido', 'text-right justify-end')}
          ${thOrden(ccOrden, 'metodo', 'Método CIF')}${thOrden(ccOrden, 'estado', 'Estado')}<th class="p-2"></th>
        </tr></thead>
        <tbody>
          ${rows.map(c => {
            const dif = c.capacidad_sugerida_horas > 0 && c.capacidad_normal_horas > 0
                ? Math.abs(c.capacidad_normal_horas - c.capacidad_sugerida_horas) / c.capacidad_sugerida_horas : 0;
            return `
            <tr class="border-b border-slate-900">
              <td class="p-2 font-mono text-slate-200">${esc(c.codigo)}</td>
              <td class="p-2 text-slate-300">${esc(c.nombre)}</td>
              <td class="p-2 text-slate-400">${TIPO_LABEL[c.tipo] || c.tipo}</td>
              <td class="p-2 text-right font-mono ${c.capacidad_normal_horas > 0 ? 'text-emerald-400' : 'text-amber-400'}">${fnum(c.capacidad_normal_horas)}${c.capacidad_normal_horas > 0 ? '' : ' ⚠'}</td>
              <td class="p-2 text-right font-mono text-slate-500">${fnum(c.capacidad_sugerida_horas)}${dif > 0.15 ? ' <span class="text-amber-400" title="Se aleja más de 15% de la que usas">≠</span>' : ''}</td>
              <td class="p-2 text-slate-400">${c.metodo_cif === 'predeterminado' ? `Predeterminado · $${fnum(c.tasa_cif_hora)}/h` : 'Real'}</td>
              <td class="p-2">${c.activo ? '<span class="text-emerald-400">activo</span>' : '<span class="text-slate-500">inactivo</span>'}</td>
              <td class="p-2 text-right"><button type="button" class="cc-edit text-sky-400 hover:underline" data-id="${c.id}">Editar</button></td>
            </tr>`;
          }).join('')}
        </tbody>
      </table>
      <p class="text-[10px] text-slate-500 mt-2">⚠ capacidad en 0 = el prorrateo de la Fase 2 no podrá aislar la capacidad ociosa. ≠ la sugerida difiere &gt;15% de la que usas — revísala.</p>`;

    cont.querySelectorAll('.cc-edit').forEach(b => b.addEventListener('click', () => ccCargarEnForm(rows.find(r => r.id === Number(b.dataset.id)))));
    wireOrdenTabla(cont, ccOrden, ccListar);
}

function ccCargarEnForm(c) {
    if (!c) return;
    ccEditId = c.id;
    const set = (id, v) => { document.getElementById(id).value = v ?? ''; };
    set('ccCodigo', c.codigo); set('ccNombre', c.nombre); set('ccTipo', c.tipo);
    set('ccCuenta', c.cuenta_cif_default_id || '');
    set('ccCapNorm', c.capacidad_normal_horas ?? 0);
    set('ccOper', c.cap_operadores ?? 0); set('ccJorn', c.cap_horas_jornada ?? 8);
    set('ccDias', c.cap_dias_habiles_mes ?? 24); set('ccFAus', c.cap_factor_ausentismo ?? 0.90);
    set('ccFNP', c.cap_factor_no_productivo ?? 0.80); set('ccFPP', c.cap_factor_paros_planeados ?? 0.96);
    set('ccMetodo', c.metodo_cif); set('ccTasa', c.tasa_cif_hora ?? '');
    set('ccNotas', c.notas || '');
    document.getElementById('ccActivo').checked = !!c.activo;
    document.getElementById('ccTasaWrap').classList.toggle('hidden', c.metodo_cif !== 'predeterminado');
    document.getElementById('ccFormTitulo').textContent = `Editar ${c.codigo}`;
    document.getElementById('ccNuevo').classList.remove('hidden');
    document.getElementById('ccMsg').textContent = '';
    ccCalcSugerido();
    document.getElementById('ccForm').scrollIntoView({ block: 'nearest' });
}
