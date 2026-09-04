import { supabaseClient } from './supabase.js';
import { norm, parseNumero } from './importador.js';
// SheetJS (lectura de .xlsx/.xls/.csv). Mismo CDN que usa el importador de productos.
import * as XLSX from 'https://cdn.sheetjs.com/xlsx-0.20.3/package/xlsx.mjs';

// =====================================================================
//  Importador de Estructura de Componentes (BOM)
//  - Sube un archivo .xlsx / .xls / .csv con una fila por cada componente
//    de una receta: Producto (padre), Componente, Cantidad y Unidad.
//  - El producto padre DEBE existir y ser de tipo "producto" (terminado);
//    el componente DEBE existir (materia prima, insumo u otro producto).
//    Este importador nunca crea productos nuevos — solo relaciona los que
//    ya están dados de alta en el Catálogo.
//  - Si el par (producto, componente) ya existe en `bom`, se ACTUALIZA la
//    cantidad/unidad; si no, se CREA la relación.
//  - Casilla opcional "Reemplazar receta completa": antes de cargar, borra
//    todos los componentes que ya tenía cada producto tocado por el
//    archivo (útil para resincronizar una receta completa de una vez).
// =====================================================================

const CAMPOS = [
    { key: 'producto_padre', label: 'Producto (padre) — SKU o nombre', hints: ['producto', 'sku producto', 'producto padre', 'padre', 'articulo', 'terminado', 'receta'] },
    { key: 'componente', label: 'Componente — SKU o nombre', hints: ['componente', 'insumo', 'material', 'sku componente', 'ingrediente', 'materia prima'] },
    { key: 'cantidad', label: 'Cantidad requerida', hints: ['cantidad', 'qty', 'consumo', 'cantidad requerida', 'cant'] },
    { key: 'unidad', label: 'Unidad de consumo', hints: ['unidad', 'um', 'u/m', 'unit', 'medida', 'uom', 'u de m'] },
];

// Estado del modulo (se reinicia en cada carga de la vista).
const estado = {
    workbook: null,
    filename: '',
    hojaActual: '',
    filaEnc: 1,
    filaDatos: 2,
    filaEncSugerida: 1,
    headers: [],
    filas: [],
    mapeo: {},
    plan: null,
    refs: { productos: [], prodPorSku: new Map(), prodPorNombre: new Map(), umPorNombre: new Map(), bomExistente: new Map() },
};

// --------------------------- vista ---------------------------

export async function cargarModuloImportadorBom() {
    const cont = document.getElementById('contenedorImportadorBom');
    if (!cont) return;

    estado.workbook = null; estado.headers = []; estado.filas = []; estado.mapeo = {}; estado.plan = null;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <div class="space-y-4">
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-2">
                <h3 class="text-md font-semibold text-amber-400">1 · Archivo</h3>
                <p class="text-xs text-slate-400">Una fila por cada componente de la receta. El mismo producto se repite tantas filas como componentes tenga.</p>
                <input type="file" id="bomiArchivoLocal" accept=".xlsx,.xls,.csv"
                    class="w-full text-xs text-slate-300 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:bg-slate-800 file:text-slate-200 hover:file:bg-slate-700 cursor-pointer">
                <div class="text-[11px] text-slate-400 pt-2 border-t border-slate-800 mt-2">
                    Plantilla de ejemplo:
                    <a href="ejemplos/plantilla_bom.csv" download class="text-amber-400 hover:underline">CSV</a>
                    <span class="text-slate-600 block mt-1">Encabezados: Producto (padre) · Componente · Cantidad · Unidad. El producto y el componente deben existir ya en el Catálogo (búscalos por SKU o nombre).</span>
                </div>
            </div>
        </div>

        <div class="xl:col-span-2 space-y-4">
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-4">
                <div class="flex flex-wrap justify-between items-center gap-2">
                    <h3 class="text-md font-semibold text-amber-400">2 · Hoja y mapeo de columnas</h3>
                    <select id="bomiHoja" class="hidden bg-slate-900 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 focus:outline-none focus:border-amber-500"></select>
                </div>
                <p id="bomiArchivoInfo" class="text-xs text-slate-500">Sube un archivo para configurar el mapeo.</p>

                <div id="bomiFilasCtrl" class="hidden flex flex-wrap items-center gap-4 text-[11px] text-slate-400">
                    <label>Fila de encabezados
                        <input type="number" id="bomiFilaEnc" min="1" value="1" class="ml-1 w-16 bg-slate-900 border border-slate-800 rounded p-1 text-xs text-slate-100">
                    </label>
                    <label>Primera fila de datos
                        <input type="number" id="bomiFilaDatos" min="2" value="2" class="ml-1 w-16 bg-slate-900 border border-slate-800 rounded p-1 text-xs text-slate-100">
                    </label>
                    <button type="button" id="bomiFilaEncAuto" class="text-amber-400 hover:underline cursor-pointer">usar sugerida</button>
                    <span id="bomiFilaEncHint" class="text-amber-400"></span>
                </div>

                <div id="bomiMapeo" class="grid grid-cols-1 sm:grid-cols-2 gap-3"></div>

                <div id="bomiResumen" class="hidden rounded-lg border border-slate-800 bg-slate-900/40 p-3 text-[11px] text-slate-300"></div>

                <hr class="border-slate-800">

                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Unidad por defecto (si una fila no trae unidad)</label>
                    <select id="bomiUnidadDef" class="w-full sm:w-64 bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                </div>
                <label class="flex items-start gap-2 text-xs text-slate-300">
                    <input type="checkbox" id="bomiReemplazar" class="accent-amber-500 mt-0.5">
                    <span>Reemplazar la receta completa de cada producto tocado por el archivo (borra los componentes que ya tenía y deja solo los del archivo). Si lo dejas sin marcar, solo se agregan o actualizan los componentes que vengan en el archivo.</span>
                </label>

                <div class="flex gap-2">
                    <button type="button" id="bomiValidar" class="flex-1 bg-slate-800 hover:bg-slate-700 text-amber-300 font-medium py-2 rounded-lg text-sm border border-slate-700 transition cursor-pointer">Validar</button>
                    <button type="button" id="bomiImportar" disabled class="flex-1 bg-amber-600 hover:bg-amber-500 disabled:opacity-40 disabled:cursor-not-allowed text-white font-medium py-2 rounded-lg text-sm transition cursor-pointer">Importar</button>
                </div>
            </div>

            <div id="bomiPreview" class="bg-slate-950 border border-slate-800 p-4 rounded-xl text-xs text-slate-500">Sin datos para previsualizar.</div>
            <div id="bomiResultado" class="hidden bg-slate-950 border border-slate-800 p-4 rounded-xl text-xs"></div>
        </div>
    </div>
    `;

    cablearEventos();
    await cargarReferencias();
}

function cablearEventos() {
    const $ = (id) => document.getElementById(id);

    $('bomiArchivoLocal').addEventListener('change', async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        try {
            const buf = await file.arrayBuffer();
            procesarWorkbook(buf, file.name);
        } catch (err) {
            alert('No se pudo leer el archivo: ' + (err.message || err));
        }
    });

    $('bomiHoja').addEventListener('change', (e) => cargarHoja(e.target.value));

    const releerConFilas = () => {
        const fe = Math.max(1, parseInt($('bomiFilaEnc').value, 10) || 1);
        const fd = Math.max(fe + 1, parseInt($('bomiFilaDatos').value, 10) || fe + 1);
        cargarHoja(estado.hojaActual, fe, fd);
    };
    $('bomiFilaEnc').addEventListener('change', releerConFilas);
    $('bomiFilaDatos').addEventListener('change', releerConFilas);
    $('bomiFilaEncAuto').addEventListener('click', () => {
        cargarHoja(estado.hojaActual, estado.filaEncSugerida, estado.filaEncSugerida + 1);
    });

    $('bomiUnidadDef').addEventListener('change', () => { if (estado.filas.length) renderPreResumen(); });

    $('bomiValidar').addEventListener('click', validar);
    $('bomiImportar').addEventListener('click', importar);
}

// --------------------------- parseo del archivo ---------------------------

function procesarWorkbook(bufferOrBytes, filename) {
    const bytes = bufferOrBytes instanceof Uint8Array ? bufferOrBytes : new Uint8Array(bufferOrBytes);
    const wb = XLSX.read(bytes, { type: 'array' });
    estado.workbook = wb;
    estado.filename = filename;

    const sel = document.getElementById('bomiHoja');
    sel.innerHTML = wb.SheetNames.map((n) => `<option value="${n}">${n}</option>`).join('');
    sel.classList.toggle('hidden', wb.SheetNames.length <= 1);

    cargarHoja(wb.SheetNames[0]);
}

// Misma heuristica que el importador de productos: de las primeras ~20
// filas, elige la que MAS parece un encabezado.
function detectarFilaEncabezados(aoa) {
    const HINTS = CAMPOS.flatMap((c) => c.hints);
    let mejor = 0, mejorScore = -Infinity;
    const lim = Math.min(aoa.length, 20);
    for (let i = 0; i < lim; i++) {
        const celdas = (aoa[i] || []).map((c) => String(c).trim()).filter(Boolean);
        if (celdas.length < 2) continue;
        const numericas = celdas.filter((c) => parseNumero(c) !== null).length;
        const hits = celdas.filter((c) => {
            const n = norm(c);
            return HINTS.some((h) => n === h || n.includes(h));
        }).length;
        const score = celdas.length - numericas * 2 + hits * 6;
        if (score > mejorScore) { mejorScore = score; mejor = i; }
    }
    return mejor;
}

function cargarHoja(nombreHoja, filaEnc, filaDatos) {
    const wb = estado.workbook;
    if (!wb) return;
    estado.hojaActual = nombreHoja;
    document.getElementById('bomiHoja').value = nombreHoja;

    const ws = wb.Sheets[nombreHoja];
    const aoa = XLSX.utils.sheet_to_json(ws, { header: 1, blankrows: false, defval: '' });

    estado.filaEncSugerida = detectarFilaEncabezados(aoa) + 1;
    const fe = Math.min(Math.max(1, filaEnc || estado.filaEncSugerida), Math.max(1, aoa.length));
    const fd = Math.max(fe + 1, filaDatos || fe + 1);
    estado.filaEnc = fe;
    estado.filaDatos = fd;

    const vistos = {};
    const headers = (aoa[fe - 1] || []).map((h, i) => {
        let name = String(h).trim() || `Columna ${i + 1}`;
        if (vistos[name] != null) { vistos[name] += 1; name = `${name} (${vistos[name]})`; }
        else vistos[name] = 0;
        return name;
    });

    const filas = aoa.slice(fd - 1)
        .filter((r) => r.some((c) => String(c).trim() !== ''))
        .map((r) => {
            const o = {};
            headers.forEach((h, i) => { o[h] = r[i] ?? ''; });
            return o;
        });

    estado.headers = headers;
    estado.filas = filas;
    estado.mapeo = autoMapear(headers);
    estado.plan = null;

    document.getElementById('bomiFilasCtrl').classList.remove('hidden');
    document.getElementById('bomiFilaEnc').value = fe;
    document.getElementById('bomiFilaDatos').value = fd;
    document.getElementById('bomiFilaEncHint').textContent =
        fe === estado.filaEncSugerida ? '(coincide con la sugerida)' : `sugerida: fila ${estado.filaEncSugerida}`;

    document.getElementById('bomiArchivoInfo').innerHTML =
        `Archivo: <span class="text-slate-300 font-medium">${estado.filename}</span> — ` +
        `hoja "<span class="text-slate-300">${nombreHoja}</span>" — ` +
        `encabezados en fila <span class="text-slate-300">${fe}</span> — ` +
        `<span class="text-slate-300">${filas.length} fila(s)</span>, ${headers.length} columna(s)`;

    renderMapeo();
    renderPreResumen();
    document.getElementById('bomiImportar').disabled = true;
    document.getElementById('bomiPreview').innerHTML =
        `<p class="text-slate-500">Revisa el mapeo y pulsa <span class="text-amber-300">Validar</span> para el detalle fila por fila.</p>`;
    document.getElementById('bomiResultado').classList.add('hidden');
}

function autoMapear(headers) {
    const m = {};
    const usados = new Set();
    for (const campo of CAMPOS) {
        let elegido = '';
        for (const h of headers) {
            if (usados.has(h)) continue;
            const hn = norm(h);
            if (campo.hints.some((hint) => hn === hint || hn.includes(hint))) { elegido = h; break; }
        }
        m[campo.key] = elegido;
        if (elegido) usados.add(elegido);
    }
    return m;
}

function renderMapeo() {
    const cont = document.getElementById('bomiMapeo');
    const opts = (sel) => `<option value="">(ninguna)</option>` +
        estado.headers.map((h) => `<option value="${h}" ${h === sel ? 'selected' : ''}>${h}</option>`).join('');

    cont.innerHTML = CAMPOS.map((campo) => {
        const val = estado.mapeo[campo.key];
        const tag = val
            ? `<span class="text-emerald-500">detectada: ${val}</span>`
            : `<span class="text-slate-600">sin detectar</span>`;
        const requerido = ['producto_padre', 'componente', 'cantidad'].includes(campo.key);
        return `
        <div>
            <label class="block text-[11px] text-slate-400 mb-1">
                ${campo.label} ${requerido ? '<span class="text-rose-400">*</span>' : ''}
                <span class="ml-1 text-[10px]">${tag}</span>
            </label>
            <select data-campo="${campo.key}" class="bomi-map w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 focus:outline-none focus:border-amber-500">
                ${opts(val)}
            </select>
        </div>`;
    }).join('');

    cont.querySelectorAll('.bomi-map').forEach((sel) => {
        sel.addEventListener('change', (e) => {
            estado.mapeo[e.target.dataset.campo] = e.target.value;
            estado.plan = null;
            document.getElementById('bomiImportar').disabled = true;
            renderMapeo();
            renderPreResumen();
        });
    });
}

// --------------------------- pre-resumen ---------------------------

function celda(fila, campoKey) {
    const col = estado.mapeo[campoKey];
    if (!col) return '';
    return fila[col] ?? '';
}

function buscarProducto(texto) {
    const R = estado.refs;
    const t = norm(String(texto || '').trim());
    if (!t) return null;
    return R.prodPorSku.get(t) || R.prodPorNombre.get(t) || null;
}

function preEstadisticas() {
    const m = estado.mapeo;
    let sinPadre = 0, sinComponente = 0, sinCantidad = 0, padreNoExiste = 0, componenteNoExiste = 0;
    const productosTocados = new Set();

    for (const fila of estado.filas) {
        const padreTxt = String(celda(fila, 'producto_padre')).trim();
        const compTxt = String(celda(fila, 'componente')).trim();
        const cantTxt = String(celda(fila, 'cantidad')).trim();

        if (!padreTxt) { sinPadre++; continue; }
        if (!compTxt) { sinComponente++; continue; }
        if (!cantTxt || parseNumero(cantTxt) === null || parseNumero(cantTxt) <= 0) { sinCantidad++; continue; }

        const padre = buscarProducto(padreTxt);
        if (!padre) { padreNoExiste++; continue; }
        if (!buscarProducto(compTxt)) { componenteNoExiste++; continue; }
        productosTocados.add(padre.id);
    }
    return { total: estado.filas.length, sinPadre, sinComponente, sinCantidad, padreNoExiste, componenteNoExiste, productosTocados: productosTocados.size };
}

function renderPreResumen() {
    const cont = document.getElementById('bomiResumen');
    if (!cont || !estado.filas.length) { if (cont) cont.classList.add('hidden'); return; }
    cont.classList.remove('hidden');

    const m = estado.mapeo;
    const s = preEstadisticas();

    const avisos = [];
    if (!m.producto_padre) avisos.push('No se detecto la columna <b>Producto (padre)</b>: mapeala a mano o el importador no podra continuar.');
    if (!m.componente) avisos.push('No se detecto la columna <b>Componente</b>: mapeala a mano o el importador no podra continuar.');
    if (!m.cantidad) avisos.push('No se detecto la columna <b>Cantidad</b>: mapeala a mano o el importador no podra continuar.');
    if (s.sinPadre) avisos.push(`<b>${s.sinPadre}</b> fila(s) sin producto padre.`);
    if (s.sinComponente) avisos.push(`<b>${s.sinComponente}</b> fila(s) sin componente.`);
    if (s.sinCantidad) avisos.push(`<b>${s.sinCantidad}</b> fila(s) sin cantidad valida (> 0).`);
    if (s.padreNoExiste) avisos.push(`<b>${s.padreNoExiste}</b> fila(s) cuyo producto padre no existe en el Catálogo (este importador no crea productos).`);
    if (s.componenteNoExiste) avisos.push(`<b>${s.componenteNoExiste}</b> fila(s) cuyo componente no existe en el Catálogo.`);

    const mapPairs = CAMPOS.map((c) => `${c.label}: <span class="${m[c.key] ? 'text-emerald-400' : 'text-slate-600'}">${m[c.key] || '—'}</span>`).join(' &nbsp;·&nbsp; ');

    cont.innerHTML = `
        <div class="font-semibold text-amber-400 mb-1">Pre-resumen</div>
        <div class="mb-2">${mapPairs}</div>
        <div class="flex flex-wrap gap-3 mb-2">
            <span class="px-2 py-0.5 rounded bg-slate-800 border border-slate-700">${s.total} filas</span>
            <span class="px-2 py-0.5 rounded bg-slate-800 border border-slate-700">${s.productosTocados} producto(s) con receta en el archivo</span>
        </div>
        ${avisos.length ? `<ul class="list-disc pl-4 space-y-0.5 text-amber-300/90">${avisos.map((a) => `<li>${a}</li>`).join('')}</ul>` : `<div class="text-emerald-400">Sin avisos: el mapeo se ve completo.</div>`}
        <div class="mt-2 text-slate-500">Pulsa <span class="text-amber-300">Validar</span> para el detalle fila por fila y elegir cuales importar.</div>
    `;
}

// --------------------------- referencias de la BD ---------------------------

async function cargarReferencias() {
    try {
        const [prod, um] = await Promise.all([
            supabaseClient.from('productos').select('id, nombre, sku, tipo'),
            supabaseClient.from('unidades_medida').select('id, nombre'),
        ]);
        for (const r of [prod, um]) if (r.error) throw r.error;

        const R = estado.refs;
        R.productos = prod.data || [];
        R.prodPorSku = new Map();
        R.prodPorNombre = new Map();
        for (const p of R.productos) {
            if (p.sku) R.prodPorSku.set(norm(p.sku), p);
            R.prodPorNombre.set(norm(p.nombre), p);
        }
        R.umPorNombre = new Map((um.data || []).map((u) => [norm(u.nombre), u]));

        // BOM existente: para saber por (producto, componente) si hay que
        // crear o actualizar, y para poder borrar por producto al "reemplazar".
        const { data: bomData, error: errBom } = await supabaseClient
            .from('bom')
            .select('id, producto_id, componente_id, cantidad_requerida, unidad_medida');
        if (errBom) throw errBom;
        R.bomExistente = new Map((bomData || []).map((b) => [`${b.producto_id}|${b.componente_id}`, b]));

        const selUm = document.getElementById('bomiUnidadDef');
        if (selUm) {
            selUm.innerHTML = `<option value="">(ninguna)</option>` +
                (um.data || []).map((u) => `<option value="${u.id}">${u.nombre}</option>`).join('');
        }

        if (estado.filas.length) renderPreResumen();
    } catch (err) {
        console.error('Error al cargar referencias del importador de BOM:', err);
        const info = document.getElementById('bomiArchivoInfo');
        if (info) info.innerHTML = `<span class="text-rose-400">No se pudieron cargar catalogos (productos/unidades/BOM): ${err.message || err}</span>`;
    }
}

// --------------------------- validacion ---------------------------

function validar() {
    if (!estado.filas.length) { alert('Primero carga un archivo con datos.'); return; }
    if (!estado.mapeo.producto_padre || !estado.mapeo.componente || !estado.mapeo.cantidad) {
        alert('Debes mapear "Producto (padre)", "Componente" y "Cantidad" — son obligatorias para relacionar el BOM.');
        return;
    }

    const R = estado.refs;
    const unidadDef = document.getElementById('bomiUnidadDef').value ? Number(document.getElementById('bomiUnidadDef').value) : null;

    // Para avisar de pares duplicados dentro del propio archivo.
    const vistosEnArchivo = new Map();

    const plan = estado.filas.map((fila, idx) => {
        const problemas = [];
        const padreTxt = String(celda(fila, 'producto_padre')).trim();
        const compTxt = String(celda(fila, 'componente')).trim();
        const cantTxt = String(celda(fila, 'cantidad')).trim();
        const uniTxt = String(celda(fila, 'unidad')).trim();

        let accion = 'crear';
        let padre = null, componente = null, cantidad = null, unidadId = unidadDef, unidadTxt = '';

        if (!padreTxt) problemas.push('sin producto padre');
        else {
            padre = buscarProducto(padreTxt);
            if (!padre) problemas.push(`producto "${padreTxt}" no existe en el Catálogo`);
            else if (padre.tipo !== 'producto') problemas.push(`"${padre.nombre}" no es un Producto terminado (tipo actual: ${padre.tipo || 'sin tipo'})`);
        }

        if (!compTxt) problemas.push('sin componente');
        else {
            componente = buscarProducto(compTxt);
            if (!componente) problemas.push(`componente "${compTxt}" no existe en el Catálogo`);
        }

        if (padre && componente && padre.id === componente.id) problemas.push('un producto no puede ser componente de sí mismo');

        if (!cantTxt) problemas.push('sin cantidad');
        else {
            cantidad = parseNumero(cantTxt);
            if (cantidad === null || cantidad <= 0) { problemas.push(`cantidad no válida ("${cantTxt}")`); cantidad = null; }
        }

        let requiereRevision = false;
        if (uniTxt) {
            const hit = R.umPorNombre.get(norm(uniTxt));
            if (hit) { unidadId = hit.id; unidadTxt = hit.nombre; }
            else { unidadTxt = uniTxt + ' → def'; problemas.push(`unidad "${uniTxt}" no existe, revisa antes de incluir esta fila`); requiereRevision = true; }
        }

        let bomId = null;
        if (padre && componente) {
            const clave = `${padre.id}|${componente.id}`;
            const existente = R.bomExistente.get(clave);
            if (existente) { accion = 'actualizar'; bomId = existente.id; }

            if (vistosEnArchivo.has(clave)) problemas.push(`duplicado en el archivo (misma fila que #${vistosEnArchivo.get(clave)})`);
            else vistosEnArchivo.set(clave, estado.filaDatos + idx);
        }

        const esError = !padre || !componente || cantidad === null || (padre && componente && padre.id === componente.id);
        if (esError) accion = 'error';

        return {
            fila: estado.filaDatos + idx,
            padreTxt, compTxt, padreId: padre?.id || null, padreNombre: padre?.nombre || '',
            componenteId: componente?.id || null, componenteNombre: componente?.nombre || '',
            cantidad, unidadId, unidadTxt, accion, bomId, problemas, requiereRevision,
            incluir: !esError && !requiereRevision,
        };
    });

    estado.plan = plan;
    renderPreview(plan);
    actualizarBotonImportar();
}

function actualizarBotonImportar() {
    const btn = document.getElementById('bomiImportar');
    const n = (estado.plan || []).filter((p) => p.incluir && p.accion !== 'error').length;
    btn.textContent = n ? `Importar (${n})` : 'Importar';
    btn.disabled = n === 0;
}

function renderPreview(plan) {
    const cont = document.getElementById('bomiPreview');
    const crear = plan.filter((p) => p.accion === 'crear').length;
    const actualizar = plan.filter((p) => p.accion === 'actualizar').length;
    const errores = plan.filter((p) => p.accion === 'error').length;
    const revision = plan.filter((p) => p.requiereRevision).length;

    const badge = (a) => a === 'crear'
        ? `<span class="text-emerald-400">crear</span>`
        : a === 'actualizar'
            ? `<span class="text-sky-400">actualizar</span>`
            : `<span class="text-rose-400">error</span>`;

    cont.innerHTML = `
        <div class="flex flex-wrap gap-3 mb-3 text-xs">
            <span class="px-2 py-1 rounded bg-emerald-950 border border-emerald-800 text-emerald-400">${crear} a crear</span>
            <span class="px-2 py-1 rounded bg-sky-950 border border-sky-800 text-sky-400">${actualizar} a actualizar</span>
            <span class="px-2 py-1 rounded bg-rose-950 border border-rose-800 text-rose-400">${errores} con error</span>
            <span class="px-2 py-1 rounded bg-amber-950 border border-amber-800 text-amber-400">${revision} requiere revisión (desmarcadas)</span>
        </div>

        <div class="flex flex-wrap items-center gap-2 mb-2">
            <input type="text" id="bomiFiltro" placeholder="filtrar por producto o componente..."
                class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-[11px] text-slate-100 w-56 focus:outline-none focus:border-amber-500">
            <span class="text-[11px] text-slate-500">Marcar:</span>
            <button type="button" data-sel="todos"      class="bomi-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Todos</button>
            <button type="button" data-sel="ninguno"    class="bomi-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Ninguno</button>
            <button type="button" data-sel="nuevos"     class="bomi-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-emerald-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Solo nuevos</button>
            <button type="button" data-sel="actualizar" class="bomi-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Solo a actualizar</button>
            <button type="button" data-sel="filtrados"  class="bomi-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Marcar filtrados</button>
        </div>

        <div class="overflow-x-auto max-h-80 overflow-y-auto border border-slate-800 rounded-lg">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-amber-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr>
                        <th class="p-2"><input type="checkbox" id="bomiChkTodos" class="accent-amber-500"></th>
                        <th class="p-2">#</th><th class="p-2">Accion</th><th class="p-2">Producto (padre)</th><th class="p-2">Componente</th>
                        <th class="p-2">Cantidad</th><th class="p-2">Unidad</th><th class="p-2">Notas</th>
                    </tr>
                </thead>
                <tbody>
                    ${plan.map((p, i) => `
                        <tr class="bomi-row border-b border-slate-900 ${p.incluir ? '' : 'opacity-40'}" data-i="${i}"
                            data-buscar="${norm(p.padreTxt + ' ' + p.compTxt)}">
                            <td class="p-2">
                                <input type="checkbox" data-i="${i}" class="bomi-row-chk accent-amber-500"
                                    ${p.incluir ? 'checked' : ''} ${p.accion === 'error' ? 'disabled' : ''}>
                            </td>
                            <td class="p-2 text-slate-500">${p.fila}</td>
                            <td class="p-2">${badge(p.accion)}${p.requiereRevision ? ' <span class="text-amber-400" title="Dato de catálogo sin match, revisa antes de incluir">⚠</span>' : ''}</td>
                            <td class="p-2 text-slate-100">${p.padreNombre || `<span class="text-rose-400">${p.padreTxt || '—'}</span>`}</td>
                            <td class="p-2 text-slate-100">${p.componenteNombre || `<span class="text-rose-400">${p.compTxt || '—'}</span>`}</td>
                            <td class="p-2 font-mono">${p.cantidad ?? ''}</td>
                            <td class="p-2 text-slate-400">${p.unidadTxt || ''}</td>
                            <td class="p-2 text-amber-400/80">${p.problemas.join('; ')}</td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>`;

    cablearPreview();
}

function cablearPreview() {
    const plan = estado.plan || [];

    document.querySelectorAll('.bomi-row-chk').forEach((chk) => {
        chk.addEventListener('change', (e) => {
            const i = Number(e.target.dataset.i);
            plan[i].incluir = e.target.checked;
            e.target.closest('tr').classList.toggle('opacity-40', !e.target.checked);
            actualizarBotonImportar();
        });
    });

    const chkTodos = document.getElementById('bomiChkTodos');
    if (chkTodos) chkTodos.addEventListener('change', (e) => aplicarSeleccion(e.target.checked ? 'todos' : 'ninguno'));

    document.querySelectorAll('.bomi-sel').forEach((b) => {
        b.addEventListener('click', () => aplicarSeleccion(b.dataset.sel));
    });

    const filtro = document.getElementById('bomiFiltro');
    if (filtro) filtro.addEventListener('input', () => {
        const q = norm(filtro.value);
        document.querySelectorAll('.bomi-row').forEach((tr) => {
            tr.classList.toggle('hidden', q !== '' && !tr.dataset.buscar.includes(q));
        });
    });
}

function aplicarSeleccion(modo) {
    const plan = estado.plan || [];
    const raw = document.getElementById('bomiFiltro')?.value || '';
    const q = norm(raw);
    const visible = (p) => q === '' || norm(p.padreTxt + ' ' + p.compTxt).includes(q);

    plan.forEach((p) => {
        if (p.accion === 'error') { p.incluir = false; return; }
        if (modo === 'todos') p.incluir = true;
        else if (modo === 'ninguno') p.incluir = false;
        else if (modo === 'nuevos') p.incluir = p.accion === 'crear';
        else if (modo === 'actualizar') p.incluir = p.accion === 'actualizar';
        else if (modo === 'filtrados') { if (visible(p)) p.incluir = true; }
    });

    renderPreview(plan);
    const f = document.getElementById('bomiFiltro');
    if (f && raw) { f.value = raw; f.dispatchEvent(new Event('input')); }
    actualizarBotonImportar();
}

// --------------------------- importacion ---------------------------

async function importar() {
    if (!estado.plan) { alert('Primero pulsa Validar.'); return; }
    const btn = document.getElementById('bomiImportar');
    btn.disabled = true;
    btn.textContent = 'Importando...';

    const reemplazar = document.getElementById('bomiReemplazar').checked;
    const incluidas = estado.plan.filter((p) => p.incluir && p.accion !== 'error');
    const resultados = [];
    let creados = 0, actualizados = 0, fallidos = 0, omitidos = 0;

    // "Reemplazar receta completa": borra de una vez todo lo que ya tenia
    // cada producto tocado por filas incluidas, y las que ya existian en
    // bom (accion 'actualizar') pasan a insertarse de nuevo como si fueran
    // nuevas (su fila vieja ya no existe tras el borrado).
    if (reemplazar) {
        const productosATocar = [...new Set(incluidas.map((p) => p.padreId))];
        for (const pid of productosATocar) {
            const { error } = await supabaseClient.from('bom').delete().eq('producto_id', pid);
            if (error) console.warn(`No se pudo limpiar la receta previa del producto ${pid}: ${error.message}`);
        }
    }

    for (const p of estado.plan) {
        if (p.accion === 'error') { resultados.push({ ...p, estado: 'omitido', detalle: p.problemas.join('; ') }); omitidos++; continue; }
        if (!p.incluir) { resultados.push({ ...p, estado: 'omitido', detalle: 'desmarcada' }); omitidos++; continue; }
        try {
            const payload = {
                producto_id: p.padreId,
                componente_id: p.componenteId,
                cantidad_requerida: p.cantidad,
                unidad_medida: p.unidadId ? String(p.unidadId) : null,
            };

            if (!reemplazar && p.accion === 'actualizar' && p.bomId) {
                const { error } = await supabaseClient.from('bom').update(payload).eq('id', p.bomId);
                if (error) throw new Error(error.message);
                resultados.push({ ...p, estado: 'actualizado', detalle: '' });
                actualizados++;
            } else {
                const { error } = await supabaseClient.from('bom').insert([payload]);
                if (error) throw new Error(error.message);
                resultados.push({ ...p, estado: 'creado', detalle: '' });
                creados++;
            }
        } catch (err) {
            resultados.push({ ...p, estado: 'fallo', detalle: err.message || String(err) });
            fallidos++;
        }
    }

    renderResultado(resultados, { creados, actualizados, fallidos, omitidos });

    estado.plan = null;
    btn.textContent = 'Importar';
    btn.disabled = true;
    await cargarReferencias();
}

function renderResultado(resultados, tot) {
    const cont = document.getElementById('bomiResultado');
    cont.classList.remove('hidden');
    const color = (e) => e === 'creado' ? 'text-emerald-400' : e === 'actualizado' ? 'text-sky-400' : e === 'omitido' ? 'text-slate-500' : 'text-rose-400';

    cont.innerHTML = `
        <div class="flex flex-wrap gap-3 mb-3">
            <span class="px-2 py-1 rounded bg-emerald-950 border border-emerald-800 text-emerald-400">${tot.creados} creados</span>
            <span class="px-2 py-1 rounded bg-sky-950 border border-sky-800 text-sky-400">${tot.actualizados} actualizados</span>
            <span class="px-2 py-1 rounded bg-rose-950 border border-rose-800 text-rose-400">${tot.fallidos} con problema</span>
            <span class="px-2 py-1 rounded bg-slate-900 border border-slate-700 text-slate-400">${tot.omitidos} omitidos</span>
        </div>
        <div class="overflow-x-auto max-h-80 overflow-y-auto border border-slate-800 rounded-lg">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-amber-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr><th class="p-2">#</th><th class="p-2">Producto</th><th class="p-2">Componente</th><th class="p-2">Resultado</th><th class="p-2">Detalle</th></tr>
                </thead>
                <tbody>
                    ${resultados.map((r) => `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 text-slate-500">${r.fila}</td>
                            <td class="p-2 text-slate-100">${r.padreNombre || r.padreTxt || ''}</td>
                            <td class="p-2 text-slate-100">${r.componenteNombre || r.compTxt || ''}</td>
                            <td class="p-2 ${color(r.estado)}">${r.estado}</td>
                            <td class="p-2 text-amber-400/80">${r.detalle || ''}</td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>
        <p class="text-slate-500 mt-3">Listo. Abre <span class="text-amber-300">Catálogos → Productos</span> y edita un producto para ver su BOM actualizado.</p>`;
}
