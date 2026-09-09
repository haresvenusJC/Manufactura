import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
// Contabilidad · Reparto de gastos compartidos (plantillas)
//   Define, una vez por cuenta (o por proveedor), cómo se parte un gasto
//   compartido: qué base usar (m² / kW / personas) y a qué cuenta de
//   resultados va la parte de oficina. Los % se derivan de las áreas
//   declaradas en "Áreas y bases de prorrateo".
//   Requiere sql/2026-09-18_gastos_reparto_wizard.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const num = (v, d = 0) => { const n = parseFloat(v); return Number.isFinite(n) ? n : d; };
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const fpct = (f) => (Number(f || 0) * 100).toLocaleString('es-MX', { maximumFractionDigits: 1 }) + '%';
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

const BASE_LABEL = {
    m2: 'Superficie (m²)', kw: 'Carga eléctrica (kW)', personas: 'Número de personas',
    partes_iguales: 'Partes iguales entre centros', manual: 'Manual (% fijos)',
};
const hint = (t) => `<span class="hint" tabindex="0" role="note" aria-label="${esc(t)}" data-tip="${esc(t)}">?</span>`;
const MUESTRA = 10000;

const estado = { plantillas: [], cuentas: [], proveedores: [], centros: [], bases: [] };
let editId = null;
let lineasManual = [];

export async function cargarModuloRepartoPlantillas() {
    const cont = document.getElementById('contenedorRepartoPlantillas');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    try {
        const [pl, ctas, prov, centros, bases] = await Promise.all([
            supabaseClient.from('reparto_plantillas').select('*').order('id'),
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo, afectable, activa').eq('activa', true).order('codigo'),
            supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
            supabaseClient.from('centros_costo').select('id, codigo, nombre').eq('tipo', 'produccion').eq('activo', true).order('codigo'),
            supabaseClient.from('v_bases_prorrateo').select('*'),
        ]);
        const err = pl.error || ctas.error || prov.error || centros.error || bases.error;
        if (err) throw err;
        estado.plantillas = pl.data || [];
        estado.cuentas = ctas.data || [];
        estado.proveedores = prov.data || [];
        estado.centros = centros.data || [];
        estado.bases = bases.data || [];
    } catch (err) {
        const m = err.message || String(err);
        cont.innerHTML = TABLA_FALTA.test(m)
            ? `<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-18_gastos_reparto_wizard.sql</span> (y el 17) en Supabase.</p>`
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    const ctasGasto = estado.cuentas.filter((c) => (c.tipo === 'gasto' || c.tipo === 'costo') && c.afectable);
    cont.innerHTML = `
    <p class="text-xs text-slate-400 max-w-2xl mb-4">Cada plantilla dice <span class="text-slate-300">cómo repartir</span> un gasto compartido y <span class="text-slate-300">a qué cuenta de oficina</span> va su parte de no producción. Los % salen de las áreas — aquí no se teclean.</p>
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
      <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
        <div class="flex items-center justify-between">
          <h3 class="text-md font-semibold text-sky-400" id="rpFormTitulo">Nueva plantilla</h3>
          <button type="button" id="rpNuevo" class="hidden text-[11px] text-slate-400 hover:text-slate-200">+ Nueva</button>
        </div>
        <form id="rpForm" class="space-y-3">
          <div><label class="block text-[11px] text-slate-400 mb-1">Nombre <span class="text-rose-400">*</span></label>
            <input type="text" id="rpNombre" placeholder="Renta compartida (m²)" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
          <div class="grid grid-cols-1 gap-2">
            <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de gasto${hint('Cuando captures un gasto con esta cuenta, el asistente propondrá esta plantilla. Déjala vacía para una plantilla genérica (aplica a cualquier cuenta).')}</label>
              <select id="rpCuenta" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <option value="">— genérica (cualquier cuenta) —</option>
                ${ctasGasto.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('')}
              </select></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Proveedor${hint('Opcional. Una plantilla con proveedor gana sobre la de la cuenta cuando captures un gasto de ese proveedor.')}</label>
              <select id="rpProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <option value="">— cualquier proveedor —</option>
                ${estado.proveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('')}
              </select></div>
          </div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Base de reparto${hint('m² para renta, predial, vigilancia, limpieza. kW para energía. Personas para internet y teléfono. Partes iguales reparte solo entre los centros de producción. Manual = tú fijas los %.')}</label>
            <select id="rpBase" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              ${Object.entries(BASE_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
            </select></div>
          <div id="rpCtaNpWrap"><label class="block text-[11px] text-slate-400 mb-1">Cuenta de la parte de oficina${hint('A dónde va la parte de no producción (601.xx). Ej. renta → 601.24 Arrendamiento; energía → 601.17. Si la base no genera parte de oficina, no se usa.')}</label>
            <select id="rpCtaNp" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">— (ninguna) —</option>
              ${estado.cuentas.filter((c) => c.afectable && (c.tipo === 'gasto' || c.tipo === 'costo')).map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('')}
            </select></div>

          <div id="rpManualWrap" class="hidden border border-slate-800 rounded-lg p-3 bg-slate-900/40 space-y-2">
            <p class="text-[11px] font-semibold text-sky-400">Líneas manuales (deben sumar 100%)</p>
            <div id="rpLineas" class="space-y-2"></div>
            <button type="button" id="rpAddLinea" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">+ Línea</button>
            <p id="rpLineasSuma" class="text-[10px] text-slate-500"></p>
          </div>

          <div><label class="block text-[11px] text-slate-400 mb-1">Notas</label>
            <input type="text" id="rpNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <label class="flex items-center gap-2 text-[11px] text-slate-300">
            <input type="checkbox" id="rpActivo" checked class="accent-emerald-500 w-3.5 h-3.5"> Activo
          </label>
          <button type="submit" id="rpGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm cursor-pointer">Guardar plantilla</button>
          <p id="rpMsg" class="text-xs min-h-[1rem]"></p>
        </form>
      </div>

      <div class="xl:col-span-2 space-y-6">
        <div id="rpPreview" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-xs text-slate-500"></div>
        <div id="rpLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500"></div>
      </div>
    </div>`;

    rpCablear();
    rpAplicarBase();
    pintarLista();
    pintarPreview();
    montarGuia(cont, 'reparto-plantillas');
}

function rpCablear() {
    const $ = (id) => document.getElementById(id);
    $('rpBase').addEventListener('change', () => { rpAplicarBase(); pintarPreview(); });
    $('rpForm').addEventListener('submit', rpGuardar);
    $('rpNuevo').addEventListener('click', rpResetForm);
    $('rpAddLinea').addEventListener('click', () => { lineasManual.push({ destino: 'produccion', ref: '', porcentaje: 0 }); pintarLineas(); });
}

function rpAplicarBase() {
    const base = document.getElementById('rpBase').value;
    document.getElementById('rpManualWrap').classList.toggle('hidden', base !== 'manual');
    document.getElementById('rpCtaNpWrap').classList.toggle('hidden', base === 'partes_iguales' || base === 'manual');
    if (base === 'manual' && !lineasManual.length) {
        lineasManual = [{ destino: 'produccion', ref: '', porcentaje: 0 }];
    }
    pintarLineas();
}

function pintarLineas() {
    const cont = document.getElementById('rpLineas');
    if (!cont) return;
    const optCentros = estado.centros.map((c) => `<option value="c:${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const optCuentas = estado.cuentas.filter((c) => c.afectable && (c.tipo === 'gasto' || c.tipo === 'costo'))
        .map((c) => `<option value="a:${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    cont.innerHTML = lineasManual.map((l, i) => `
      <div class="flex gap-1.5 items-center" data-i="${i}">
        <select class="rpl-dest bg-slate-900 border border-slate-800 rounded p-1 text-[11px] text-slate-100">
          <option value="produccion"${l.destino === 'produccion' ? ' selected' : ''}>Producción</option>
          <option value="no_produccion"${l.destino === 'no_produccion' ? ' selected' : ''}>No producción</option>
        </select>
        <select class="rpl-ref bg-slate-900 border border-slate-800 rounded p-1 text-[11px] text-slate-100 flex-1">
          <option value="">— destino —</option>
          ${l.destino === 'produccion' ? optCentros : optCuentas}
        </select>
        <input type="number" min="0" max="100" step="0.01" class="rpl-pct w-16 bg-slate-900 border border-slate-800 rounded p-1 text-[11px] text-slate-100 text-right font-mono" value="${l.porcentaje || 0}">
        <button type="button" class="rpl-del text-rose-400 text-xs px-1">✕</button>
      </div>`).join('');

    cont.querySelectorAll('[data-i]').forEach((row) => {
        const i = Number(row.dataset.i);
        row.querySelector('.rpl-ref').value = lineasManual[i].ref || '';
        row.querySelector('.rpl-dest').addEventListener('change', (e) => { lineasManual[i].destino = e.target.value; lineasManual[i].ref = ''; pintarLineas(); });
        row.querySelector('.rpl-ref').addEventListener('change', (e) => { lineasManual[i].ref = e.target.value; });
        row.querySelector('.rpl-pct').addEventListener('input', (e) => { lineasManual[i].porcentaje = num(e.target.value); rpSumaLineas(); });
        row.querySelector('.rpl-del').addEventListener('click', () => { lineasManual.splice(i, 1); pintarLineas(); });
    });
    rpSumaLineas();
}

function rpSumaLineas() {
    const el = document.getElementById('rpLineasSuma');
    if (!el) return;
    const s = lineasManual.reduce((a, l) => a + num(l.porcentaje), 0);
    el.textContent = `Suma: ${s.toFixed(2)}%` + (Math.abs(s - 100) > 0.01 ? ' — debe ser 100%' : ' ✓');
    el.className = 'text-[10px] ' + (Math.abs(s - 100) > 0.01 ? 'text-amber-400' : 'text-emerald-400');
}

// --- Preview: cómo quedaría un gasto de $10,000 con la base elegida ---
function resolverClientBase(base) {
    const rows = estado.bases.filter((r) => r.base === base);
    const porCentro = {};
    let noProd = 0;
    rows.forEach((r) => {
        if (r.rol === 'produccion' && r.centro_costo_id) {
            porCentro[r.centro_costo_id] = (porCentro[r.centro_costo_id] || 0) + Number(r.fraccion || 0);
        } else if (r.rol === 'no_produccion') {
            noProd += Number(r.fraccion || 0);
        }
    });
    return { porCentro, noProd, hay: rows.some((r) => Number(r.valor || 0) > 0) };
}

function pintarPreview() {
    const cont = document.getElementById('rpPreview');
    const base = document.getElementById('rpBase').value;
    if (base === 'manual') { cont.innerHTML = `<p class="text-slate-500">Reparto manual: define las líneas a la izquierda.</p>`; return; }
    if (base === 'partes_iguales') {
        const n = estado.centros.length || 1;
        cont.innerHTML = `
          <h3 class="text-sm font-semibold text-sky-400 mb-2">Vista previa — gasto de ${money(MUESTRA)}</h3>
          <p class="text-slate-400">${money(MUESTRA)} ÷ ${n} centros = <span class="font-mono text-emerald-400">${money(MUESTRA / n)}</span> a cada uno de: ${estado.centros.map((c) => esc(c.codigo)).join(', ') || '—'}. Sin parte de oficina.</p>`;
        return;
    }
    const r = resolverClientBase(base);
    const centroCod = (id) => { const c = estado.centros.find((x) => x.id === Number(id)); return c ? `${c.codigo} · ${c.nombre}` : `#${id}`; };
    if (!r.hay) {
        cont.innerHTML = `<p class="text-amber-400">Aún no hay datos de <b>${esc(BASE_LABEL[base])}</b> en las áreas. Captúralos en "Áreas y bases de prorrateo".</p>`;
        return;
    }
    const filasProd = Object.entries(r.porCentro).map(([id, f]) => `
      <tr class="border-b border-slate-900"><td class="p-1.5 text-slate-300">${esc(centroCod(id))}</td>
        <td class="p-1.5 text-right font-mono text-slate-400">${fpct(f)}</td>
        <td class="p-1.5 text-right font-mono text-emerald-400">${money(MUESTRA * f)}</td></tr>`).join('');
    cont.innerHTML = `
      <h3 class="text-sm font-semibold text-sky-400 mb-2">Vista previa — gasto de ${money(MUESTRA)}</h3>
      <table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-1.5">Destino</th><th class="p-1.5 text-right">%</th><th class="p-1.5 text-right">Monto</th></tr></thead>
        <tbody>
          ${filasProd}
          ${r.noProd > 0 ? `<tr class="border-b border-slate-900"><td class="p-1.5 text-amber-400">No producción → cuenta de oficina</td><td class="p-1.5 text-right font-mono text-slate-400">${fpct(r.noProd)}</td><td class="p-1.5 text-right font-mono text-amber-400">${money(MUESTRA * r.noProd)}</td></tr>` : ''}
        </tbody>
      </table>
      <p class="text-[10px] text-slate-500 mt-2">Nivel 1 — Producción ${fpct(1 - r.noProd)} · No producción ${fpct(r.noProd)}. Los montos se congelan al capturar cada gasto.</p>`;
}

function pintarLista() {
    const cont = document.getElementById('rpLista');
    if (!estado.plantillas.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin plantillas. Crea la primera.</p>`; return; }
    const ctaCod = (id) => { const c = estado.cuentas.find((x) => x.id === id); return c ? `${c.codigo} · ${c.nombre}` : (id ? `#${id}` : '—'); };
    const provNom = (id) => { const p = estado.proveedores.find((x) => x.id === id); return p ? p.nombre : (id ? `#${id}` : '—'); };
    cont.innerHTML = `
      <h3 class="text-md font-semibold text-sky-400 mb-3">Plantillas</h3>
      <div class="overflow-x-auto">
      <table class="w-full text-xs whitespace-nowrap">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800">
          <th class="p-2">Nombre</th><th class="p-2">Ámbito</th><th class="p-2">Base</th><th class="p-2">Parte oficina →</th><th class="p-2">Estado</th><th class="p-2"></th>
        </tr></thead>
        <tbody>
          ${estado.plantillas.map((p) => `
            <tr class="border-b border-slate-900">
              <td class="p-2 text-slate-300">${esc(p.nombre)}</td>
              <td class="p-2 text-slate-400">${p.proveedor_id ? 'Prov: ' + esc(provNom(p.proveedor_id)) : (p.cuenta_id ? 'Cta: ' + esc(ctaCod(p.cuenta_id)) : 'Genérica')}</td>
              <td class="p-2 text-slate-400">${esc(BASE_LABEL[p.base] || p.base)}</td>
              <td class="p-2 font-mono text-slate-400">${esc(ctaCod(p.cuenta_no_produccion_id))}</td>
              <td class="p-2">${p.activo ? '<span class="text-emerald-400">activo</span>' : '<span class="text-slate-500">inactivo</span>'}</td>
              <td class="p-2 text-right whitespace-nowrap">
                <button type="button" class="rp-edit text-sky-400 hover:underline" data-id="${p.id}">Editar</button>
                <button type="button" class="rp-del text-rose-400 hover:underline ml-2" data-id="${p.id}">Borrar</button>
              </td>
            </tr>`).join('')}
        </tbody>
      </table>
      </div>`;
    cont.querySelectorAll('.rp-edit').forEach((b) => b.addEventListener('click', () => rpCargarEnForm(estado.plantillas.find((p) => p.id === Number(b.dataset.id)))));
    cont.querySelectorAll('.rp-del').forEach((b) => b.addEventListener('click', () => rpBorrar(Number(b.dataset.id))));
}

function rpResetForm() {
    editId = null; lineasManual = [];
    const f = document.getElementById('rpForm');
    if (f) f.reset();
    document.getElementById('rpActivo').checked = true;
    document.getElementById('rpFormTitulo').textContent = 'Nueva plantilla';
    document.getElementById('rpNuevo').classList.add('hidden');
    document.getElementById('rpMsg').textContent = '';
    rpAplicarBase();
    pintarPreview();
}

async function rpGuardar(e) {
    e.preventDefault();
    const $ = (id) => document.getElementById(id);
    const msg = $('rpMsg');
    msg.className = 'text-xs min-h-[1rem]'; msg.textContent = '';
    const base = $('rpBase').value;
    const row = {
        nombre: $('rpNombre').value.trim(),
        cuenta_id: $('rpCuenta').value ? Number($('rpCuenta').value) : null,
        proveedor_id: $('rpProveedor').value ? Number($('rpProveedor').value) : null,
        base,
        cuenta_no_produccion_id: (base !== 'partes_iguales' && base !== 'manual' && $('rpCtaNp').value) ? Number($('rpCtaNp').value) : null,
        activo: $('rpActivo').checked,
        notas: $('rpNotas').value.trim() || null,
    };
    if (!row.nombre) { msg.textContent = 'Falta el nombre.'; msg.className = 'text-xs text-rose-400'; return; }

    let lineas = [];
    if (base === 'manual') {
        const s = lineasManual.reduce((a, l) => a + num(l.porcentaje), 0);
        if (Math.abs(s - 100) > 0.01) { msg.textContent = 'Las líneas manuales deben sumar 100%.'; msg.className = 'text-xs text-rose-400'; return; }
        for (const l of lineasManual) {
            if (!l.ref || !l.porcentaje) { msg.textContent = 'Cada línea manual necesita destino y %.'; msg.className = 'text-xs text-rose-400'; return; }
            const [k, id] = l.ref.split(':');
            lineas.push({
                destino: l.destino,
                centro_costo_id: k === 'c' ? Number(id) : null,
                cuenta_resultados_id: k === 'a' ? Number(id) : null,
                porcentaje: num(l.porcentaje),
            });
        }
    }

    try {
        $('rpGuardar').disabled = true;
        let plId = editId;
        if (editId) {
            const { error } = await supabaseClient.from('reparto_plantillas').update(row).eq('id', editId);
            if (error) throw error;
            await supabaseClient.from('reparto_plantilla_lineas').delete().eq('plantilla_id', editId);
        } else {
            const { data, error } = await supabaseClient.from('reparto_plantillas').insert([row]).select('id').single();
            if (error) throw error;
            plId = data.id;
        }
        if (base === 'manual' && lineas.length) {
            const { error } = await supabaseClient.from('reparto_plantilla_lineas')
                .insert(lineas.map((l) => ({ ...l, plantilla_id: plId })));
            if (error) throw error;
        }
        msg.textContent = editId ? 'Plantilla actualizada.' : 'Plantilla creada.';
        msg.className = 'text-xs text-emerald-400';
        rpResetForm();
        await cargarModuloRepartoPlantillas();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs text-rose-400';
    } finally {
        const b = document.getElementById('rpGuardar');
        if (b) b.disabled = false;
    }
}

async function rpCargarEnForm(p) {
    if (!p) return;
    editId = p.id;
    const set = (id, v) => { document.getElementById(id).value = v ?? ''; };
    set('rpNombre', p.nombre); set('rpCuenta', p.cuenta_id || ''); set('rpProveedor', p.proveedor_id || '');
    set('rpBase', p.base); set('rpCtaNp', p.cuenta_no_produccion_id || ''); set('rpNotas', p.notas || '');
    document.getElementById('rpActivo').checked = !!p.activo;
    lineasManual = [];
    if (p.base === 'manual') {
        const { data } = await supabaseClient.from('reparto_plantilla_lineas').select('*').eq('plantilla_id', p.id);
        lineasManual = (data || []).map((l) => ({
            destino: l.destino,
            ref: l.centro_costo_id ? `c:${l.centro_costo_id}` : (l.cuenta_resultados_id ? `a:${l.cuenta_resultados_id}` : ''),
            porcentaje: l.porcentaje,
        }));
    }
    document.getElementById('rpFormTitulo').textContent = `Editar: ${p.nombre}`;
    document.getElementById('rpNuevo').classList.remove('hidden');
    document.getElementById('rpMsg').textContent = '';
    rpAplicarBase();
    pintarPreview();
    document.getElementById('rpForm').scrollIntoView({ block: 'nearest' });
}

async function rpBorrar(id) {
    if (!confirm('¿Borrar esta plantilla de reparto? Los gastos ya capturados con ella no se tocan.')) return;
    const { error } = await supabaseClient.from('reparto_plantillas').delete().eq('id', id);
    if (error) { alert(error.message || String(error)); return; }
    await cargarModuloRepartoPlantillas();
}
