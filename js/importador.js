import { supabaseClient } from './supabase.js';
// SheetJS (lectura de .xlsx/.xls/.csv). CDN oficial en formato ESM.
import * as XLSX from 'https://cdn.sheetjs.com/xlsx-0.20.3/package/xlsx.mjs';

// =====================================================================
//  Importador de datos (Excel / CSV)
//  - Subes un archivo .xlsx / .xls / .csv (por ejemplo la plantilla de
//    ejemplos/plantilla_materias_primas.xlsx).
//  - Detecta la fila de encabezados y sugiere el mapeo de columnas
//    (Nombre, SKU, Proveedor, Precio, Moneda, Unidad, Notas).
//  - Pre-resumen antes de validar; luego vista previa fila por fila con
//    casillas para elegir que se importa.
//  - Upsert: si el producto ya existe (por SKU, o por nombre si no hay
//    SKU) se ACTUALIZA; si no, se CREA. Los proveedores nuevos se crean.
//  - El precio va a productos.costo_unitario (+ moneda_id).
// =====================================================================

// Campos destino y las "pistas" para autodetectar la columna del archivo.
// grupo: 'basico' | 'contable' | 'compras'  (solo para agrupar en la UI)
const CAMPOS = [
    { key: 'proveedor',      label: 'Proveedor',            grupo: 'basico',   hints: ['proveedor', 'supplier', 'fabricante', 'marca', 'vendor'] },
    { key: 'nombre',         label: 'Nombre del producto',  grupo: 'basico',   hints: ['producto', 'nombre', 'articulo', 'item', 'material', 'insumo'] },
    { key: 'sku',            label: 'SKU / Codigo',         grupo: 'basico',   hints: ['sku', 'codigo', 'clave', 'code', 'parte', 'part', 'no. parte', 'referencia', 'no parte'] },
    { key: 'tipo',           label: 'Tipo (MP / insumo / producto)', grupo: 'basico', hints: ['tipo', 'categoria', 'category', 'clase', 'familia', 'segmento'] },
    { key: 'costo_unitario', label: 'Precio / Costo',       grupo: 'basico',   hints: ['precio', 'costo', 'price', 'cost', 'importe', 'unitario', 'unit price', 'pu', 'p.u'] },
    { key: 'moneda',         label: 'Moneda',               grupo: 'basico',   hints: ['moneda', 'currency', 'divisa'] },
    { key: 'unidad',         label: 'Unidad de medida',     grupo: 'basico',   hints: ['unidad', 'um', 'u/m', 'unit', 'medida', 'uom', 'u de m'] },
    { key: 'descripcion',    label: 'Descripcion / Notas',  grupo: 'basico',   hints: ['descripcion', 'nota', 'notas', 'detalle', 'observacion', 'especificacion', 'description'] },

    // --- Contable (requiere el modulo de contabilidad) ---
    { key: 'tasa_iva',       label: 'Tasa IVA',             grupo: 'contable', hints: ['iva', 'i.v.a', 'impuesto iva', 'vat', 'tasa iva'] },
    { key: 'tasa_ieps',      label: 'Tasa IEPS',            grupo: 'contable', hints: ['ieps', 'tasa ieps'] },

    // --- Compras / abasto (campos ERP agregados el 30/08) ---
    { key: 'stock_minimo',   label: 'Stock minimo / reorden', grupo: 'compras', hints: ['stock minimo', 'minimo', 'reorden', 'reorder', 'punto de pedido', 'punto de reorden', 'existencia minima', 'min stock', 'stock min', 'nivel minimo'] },
    { key: 'tiempo_entrega_dias', label: 'Tiempo de entrega (dias)', grupo: 'compras', hints: ['tiempo de entrega', 'lead time', 'leadtime', 'dias entrega', 'plazo de entrega', 'dias de surtido', 'entrega dias', 'lead', 'plazo'] },
    { key: 'cantidad_minima_compra', label: 'Cantidad minima de compra (MOQ)', grupo: 'compras', hints: ['moq', 'minima compra', 'minimo de compra', 'lote minimo', 'pedido minimo', 'compra minima', 'cantidad minima', 'multiplo de compra'] },
    { key: 'activo',         label: 'Activo / vigente',     grupo: 'compras',  hints: ['activo', 'vigente', 'habilitado', 'enabled', 'estatus', 'status', 'estado', 'alta'] },
];

// --------- parsers de los campos nuevos ---------

// '16%' / '16' / '0.16' / '' / 'exento' -> { val } o { err:true }; val=undefined = no tocar
function parseTasaImp(raw) {
    const s = String(raw ?? '').trim().toLowerCase();
    if (s === '') return { val: undefined };
    if (/exent|exon|n\/a|na/.test(s)) return { val: null };
    let n = parseNumero(s.replace('%', ''));
    if (n === null) return { err: true };
    if (n > 1) n = n / 100;                 // 16 -> 0.16
    return { val: Math.round(n * 10000) / 10000 };
}

function parseBooleano(raw) {
    const s = String(raw ?? '').trim().toLowerCase();
    if (s === '') return undefined;
    if (['si', 'sí', 's', 'yes', 'y', '1', 'true', 'x', 'activo', 'vigente', 'alta', 'verdadero'].includes(s)) return true;
    if (['no', 'n', '0', 'false', 'inactivo', 'baja', 'descontinuado', 'falso'].includes(s)) return false;
    return undefined; // no reconocido -> no tocar
}

function parseTipoProducto(raw) {
    const s = norm(raw);
    if (!s) return '';
    if (/materia|prima|\bmp\b/.test(s)) return 'materia_prima';
    if (/insumo|componente|auxiliar/.test(s)) return 'insumo';
    if (/producto|terminad|\bpt\b|articulo|final|venta/.test(s)) return 'producto';
    return '';
}

// Estado del modulo (se reinicia en cada carga de la vista).
const estado = {
    workbook: null,
    filename: '',
    hojaActual: '',
    filaEnc: 1,          // fila (1-based) con los encabezados
    filaDatos: 2,        // primera fila (1-based) con datos
    filaEncSugerida: 1,  // lo que detecto el heuristico
    headers: [],
    filas: [],
    mapeo: {},
    monedaDetectada: '', // codigo inferido del encabezado de precio (ej. "USD")
    plan: null,
    refs: { provPorNombre: new Map(), umPorNombre: new Map(), monPorCodigo: new Map(), prodPorSku: new Map(), prodPorNombre: new Map(), monedas: [], unidades: [] },
};

// --------------------------- helpers ---------------------------

// Normaliza para comparar: minusculas, sin acentos, espacios colapsados.
// (Asi "LIMON" empata con "limon" y "  Acido   Citrico " con "acido citrico".)
function norm(x) {
    return String(x ?? '')
        .normalize('NFD')
        .replace(/[̀-ͯ]/g, '') // quita marcas diacriticas combinantes
        .trim().toLowerCase()
        .replace(/\s+/g, ' ');
}

function parseNumero(v) {
    if (v === null || v === undefined || v === '') return null;
    if (typeof v === 'number') return isFinite(v) ? v : null;
    let s = String(v).trim().replace(/[^0-9.,\-]/g, '');
    if (!s) return null;
    if (s.includes(',') && s.includes('.')) s = s.replace(/,/g, '');      // 1,234.56 -> 1234.56
    else if (s.includes(',') && !s.includes('.')) s = s.replace(',', '.'); // 1234,56  -> 1234.56
    const n = parseFloat(s);
    return isFinite(n) ? n : null;
}

// --------------------------- vista ---------------------------

export async function cargarModuloImportador() {
    const cont = document.getElementById('contenedorImportador');
    if (!cont) return;

    // reinicio de estado
    estado.workbook = null; estado.headers = []; estado.filas = []; estado.mapeo = {}; estado.plan = null;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Columna izquierda: archivo -->
        <div class="space-y-4">
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-2">
                <h3 class="text-md font-semibold text-sky-400">1 · Archivo</h3>
                <p class="text-xs text-slate-400">Sube tu Excel o CSV con los productos / materias primas.</p>
                <input type="file" id="impArchivoLocal" accept=".xlsx,.xls,.csv"
                    class="w-full text-xs text-slate-300 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:bg-slate-800 file:text-slate-200 hover:file:bg-slate-700 cursor-pointer">
                <div class="text-[11px] text-slate-400 pt-2 border-t border-slate-800 mt-2">
                    Plantilla de ejemplo:
                    <a href="ejemplos/plantilla_materias_primas.xlsx" download class="text-sky-400 hover:underline">Excel</a> ·
                    <a href="ejemplos/plantilla_materias_primas.csv" download class="text-sky-400 hover:underline">CSV</a>
                    <span class="text-slate-600 block mt-1">Encabezados: Nombre · SKU · Tipo · Proveedor · Precio · Moneda · Unidad · Tasa IVA · Tasa IEPS · Stock minimo · Tiempo entrega dias · Cantidad minima compra · Activo · Notas</span>
                </div>
            </div>
        </div>

        <!-- Columna derecha: mapeo, validacion, importacion -->
        <div class="xl:col-span-2 space-y-4">
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-4">
                <div class="flex flex-wrap justify-between items-center gap-2">
                    <h3 class="text-md font-semibold text-sky-400">2 · Hoja y mapeo de columnas</h3>
                    <select id="impHoja" class="hidden bg-slate-900 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 focus:outline-none focus:border-sky-500"></select>
                </div>
                <p id="impArchivoInfo" class="text-xs text-slate-500">Sube un archivo para configurar el mapeo.</p>

                <div id="impFilasCtrl" class="hidden flex flex-wrap items-center gap-4 text-[11px] text-slate-400">
                    <label>Fila de encabezados
                        <input type="number" id="impFilaEnc" min="1" value="1" class="ml-1 w-16 bg-slate-900 border border-slate-800 rounded p-1 text-xs text-slate-100">
                    </label>
                    <label>Primera fila de datos
                        <input type="number" id="impFilaDatos" min="2" value="2" class="ml-1 w-16 bg-slate-900 border border-slate-800 rounded p-1 text-xs text-slate-100">
                    </label>
                    <button type="button" id="impFilaEncAuto" class="text-sky-400 hover:underline cursor-pointer">usar sugerida</button>
                    <span id="impFilaEncHint" class="text-sky-400"></span>
                </div>

                <div id="impMapeo" class="grid grid-cols-1 sm:grid-cols-2 gap-3"></div>

                <div id="impResumen" class="hidden rounded-lg border border-slate-800 bg-slate-900/40 p-3 text-[11px] text-slate-300"></div>

                <hr class="border-slate-800">

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Tipo para productos NUEVOS</label>
                        <select id="impTipo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                            <option value="materia_prima">Materia prima</option>
                            <option value="insumo">Insumo / componente</option>
                            <option value="producto">Producto terminado</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Moneda por defecto</label>
                        <select id="impMonedaDef" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                    </div>
                    <div>
                        <label class="block text-[11px] text-slate-400 mb-1">Unidad por defecto</label>
                        <select id="impUnidadDef" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                    </div>
                </div>
                <label class="flex items-center gap-2 text-xs text-slate-300">
                    <input type="checkbox" id="impCrearProv" checked class="accent-sky-500"> Crear proveedores que no existan
                </label>

                <div class="flex gap-2">
                    <button type="button" id="impValidar" class="flex-1 bg-slate-800 hover:bg-slate-700 text-sky-300 font-medium py-2 rounded-lg text-sm border border-slate-700 transition cursor-pointer">Validar</button>
                    <button type="button" id="impImportar" disabled class="flex-1 bg-sky-600 hover:bg-sky-500 disabled:opacity-40 disabled:cursor-not-allowed text-white font-medium py-2 rounded-lg text-sm transition cursor-pointer">Importar</button>
                </div>
            </div>

            <div id="impPreview" class="bg-slate-950 border border-slate-800 p-4 rounded-xl text-xs text-slate-500">Sin datos para previsualizar.</div>
            <div id="impResultado" class="hidden bg-slate-950 border border-slate-800 p-4 rounded-xl text-xs"></div>
        </div>
    </div>
    `;

    cablearEventos();
    await cargarReferencias();
}

function cablearEventos() {
    const $ = (id) => document.getElementById(id);

    $('impArchivoLocal').addEventListener('change', async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        try {
            const buf = await file.arrayBuffer();
            procesarWorkbook(buf, file.name);
        } catch (err) {
            alert('No se pudo leer el archivo: ' + (err.message || err));
        }
    });

    $('impHoja').addEventListener('change', (e) => cargarHoja(e.target.value)); // re-detecta encabezados

    const releerConFilas = () => {
        const fe = Math.max(1, parseInt($('impFilaEnc').value, 10) || 1);
        const fd = Math.max(fe + 1, parseInt($('impFilaDatos').value, 10) || fe + 1);
        cargarHoja(estado.hojaActual, fe, fd);
    };
    $('impFilaEnc').addEventListener('change', releerConFilas);
    $('impFilaDatos').addEventListener('change', releerConFilas);
    $('impFilaEncAuto').addEventListener('click', () => {
        cargarHoja(estado.hojaActual, estado.filaEncSugerida, estado.filaEncSugerida + 1);
    });

    ['impMonedaDef', 'impUnidadDef', 'impTipo', 'impCrearProv'].forEach((id) => {
        $(id).addEventListener('change', () => { if (estado.filas.length) renderPreResumen(); });
    });

    $('impValidar').addEventListener('click', validar);
    $('impImportar').addEventListener('click', importar);
}

// --------------------------- parseo del archivo ---------------------------

function procesarWorkbook(bufferOrBytes, filename) {
    const bytes = bufferOrBytes instanceof Uint8Array ? bufferOrBytes : new Uint8Array(bufferOrBytes);
    const wb = XLSX.read(bytes, { type: 'array' });
    estado.workbook = wb;
    estado.filename = filename;

    const sel = document.getElementById('impHoja');
    sel.innerHTML = wb.SheetNames.map((n) => `<option value="${n}">${n}</option>`).join('');
    sel.classList.toggle('hidden', wb.SheetNames.length <= 1);

    cargarHoja(wb.SheetNames[0]);
}

// Heuristica: de las primeras ~20 filas, elige la que MAS parece un encabezado
// (varias celdas de texto, pocos numeros, y coincidencias con los campos destino).
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
    return mejor; // indice 0-based
}

// Infiere el codigo de moneda a partir del texto del encabezado de precio.
function monedaDesdeHeader(h) {
    const n = norm(h);
    if (/\busd\b/.test(n) || n.includes('dolar') || n.includes('dls') || n.includes('dlls')) return 'USD';
    if (n.includes('mxn') || n.includes('m.n') || n.includes('peso')) return 'MXN';
    if (/\beur\b/.test(n) || n.includes('euro')) return 'EUR';
    return '';
}

function cargarHoja(nombreHoja, filaEnc, filaDatos) {
    const wb = estado.workbook;
    if (!wb) return;
    estado.hojaActual = nombreHoja;
    document.getElementById('impHoja').value = nombreHoja;

    const ws = wb.Sheets[nombreHoja];
    const aoa = XLSX.utils.sheet_to_json(ws, { header: 1, blankrows: false, defval: '' });

    // 1. Fila de encabezados: la que pasan por parametro, o la sugerida.
    estado.filaEncSugerida = detectarFilaEncabezados(aoa) + 1;
    const fe = Math.min(Math.max(1, filaEnc || estado.filaEncSugerida), Math.max(1, aoa.length));
    const fd = Math.max(fe + 1, filaDatos || fe + 1);
    estado.filaEnc = fe;
    estado.filaDatos = fd;

    // 2. Encabezados: placeholder si viene vacio, sufijo si se repiten.
    const vistos = {};
    const headers = (aoa[fe - 1] || []).map((h, i) => {
        let name = String(h).trim() || `Columna ${i + 1}`;
        if (vistos[name] != null) { vistos[name] += 1; name = `${name} (${vistos[name]})`; }
        else vistos[name] = 0;
        return name;
    });

    // 3. Filas de datos (desde fd), se descartan las totalmente vacias.
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

    // 4. Moneda inferida del encabezado de precio.
    estado.monedaDetectada = monedaDesdeHeader(estado.mapeo.costo_unitario);
    if (estado.monedaDetectada) {
        const selMon = document.getElementById('impMonedaDef');
        const opt = [...selMon.options].find((o) => norm(o.textContent) === norm(estado.monedaDetectada));
        if (opt) selMon.value = opt.value;
    }

    // 5. Sincroniza los controles de fila.
    document.getElementById('impFilasCtrl').classList.remove('hidden');
    document.getElementById('impFilaEnc').value = fe;
    document.getElementById('impFilaDatos').value = fd;
    document.getElementById('impFilaEncHint').textContent =
        fe === estado.filaEncSugerida ? '(coincide con la sugerida)' : `sugerida: fila ${estado.filaEncSugerida}`;

    document.getElementById('impArchivoInfo').innerHTML =
        `Archivo: <span class="text-slate-300 font-medium">${estado.filename}</span> — ` +
        `hoja "<span class="text-slate-300">${nombreHoja}</span>" — ` +
        `encabezados en fila <span class="text-slate-300">${fe}</span> — ` +
        `<span class="text-slate-300">${filas.length} fila(s)</span>, ${headers.length} columna(s)`;

    renderMapeo();
    renderPreResumen();
    document.getElementById('impImportar').disabled = true;
    document.getElementById('impPreview').innerHTML =
        `<p class="text-slate-500">Revisa el mapeo y pulsa <span class="text-sky-300">Validar</span> para el detalle fila por fila.</p>`;
    document.getElementById('impResultado').classList.add('hidden');
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

const GRUPOS = [
    { id: 'basico',   t: 'Básico' },
    { id: 'contable', t: 'Contable (requiere módulo de contabilidad)' },
    { id: 'compras',  t: 'Compras / abasto' },
];

function renderMapeo() {
    const cont = document.getElementById('impMapeo');
    const opts = (sel) => `<option value="">(ninguna)</option>` +
        estado.headers.map((h) => `<option value="${h}" ${h === sel ? 'selected' : ''}>${h}</option>`).join('');

    const campoHtml = (campo) => {
        const val = estado.mapeo[campo.key];
        const tag = val
            ? `<span class="text-emerald-500">detectada: ${val}</span>`
            : `<span class="text-slate-600">sin detectar</span>`;
        return `
        <div>
            <label class="block text-[11px] text-slate-400 mb-1">
                ${campo.label} ${campo.key === 'nombre' ? '<span class="text-rose-400">*</span>' : ''}
                <span class="ml-1 text-[10px]">${tag}</span>
            </label>
            <select data-campo="${campo.key}" class="imp-map w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 focus:outline-none focus:border-sky-500">
                ${opts(val)}
            </select>
        </div>`;
    };

    cont.innerHTML = GRUPOS.map((g) => {
        const campos = CAMPOS.filter((c) => (c.grupo || 'basico') === g.id);
        if (!campos.length) return '';
        return `
            <div class="sm:col-span-2 text-[10px] uppercase tracking-wider text-sky-400/80 mt-1">${g.t}</div>
            ${campos.map(campoHtml).join('')}`;
    }).join('');

    cont.querySelectorAll('.imp-map').forEach((sel) => {
        sel.addEventListener('change', (e) => {
            estado.mapeo[e.target.dataset.campo] = e.target.value;
            estado.plan = null;
            document.getElementById('impImportar').disabled = true;
            if (e.target.dataset.campo === 'costo_unitario') {
                estado.monedaDetectada = monedaDesdeHeader(e.target.value);
            }
            renderMapeo();       // refresca las etiquetas "detectada"
            renderPreResumen();  // y el pre-resumen
        });
    });
}

// --------------------------- pre-resumen ---------------------------

// Pasada ligera (sin construir el plan completo) para adelantar que va a pasar:
// cuantas filas se crearian / actualizarian, proveedores nuevos, filas sin
// precio, posibles duplicados de productos ya existentes, y avisos de mapeo.
function preEstadisticas() {
    const R = estado.refs;
    const m = estado.mapeo;
    const val = (fila, key) => (m[key] ? String(fila[m[key]] ?? '').trim() : '');

    const provNuevos = new Set();
    const dups = [];
    let crear = 0, actualizar = 0, sinNombre = 0, sinPrecio = 0, precioMal = 0;

    for (const fila of estado.filas) {
        const nombre = val(fila, 'nombre');
        if (!nombre) { sinNombre++; continue; }
        const sku = val(fila, 'sku');
        const existe = (sku && R.prodPorSku.has(norm(sku))) || (!sku && R.prodPorNombre.has(norm(nombre)));
        if (existe) {
            actualizar++;
        } else {
            crear++;
            const d = posibleDuplicado(nombre);
            if (d) dups.push([nombre, d]);
        }
        if (m.costo_unitario) {
            const raw = val(fila, 'costo_unitario');
            if (raw === '') sinPrecio++;
            else if (parseNumero(raw) === null) precioMal++;
        }
        const pv = val(fila, 'proveedor');
        if (pv && !R.provPorNombre.has(norm(pv))) provNuevos.add(pv.trim());
    }
    return { total: estado.filas.length, crear, actualizar, sinNombre, sinPrecio, precioMal, provNuevos: [...provNuevos], dups };
}

function renderPreResumen() {
    const cont = document.getElementById('impResumen');
    if (!cont || !estado.filas.length) { if (cont) cont.classList.add('hidden'); return; }
    cont.classList.remove('hidden');

    const m = estado.mapeo;
    const s = preEstadisticas();
    const monSel = document.getElementById('impMonedaDef');
    const monTxt = monSel?.options[monSel.selectedIndex]?.textContent || '(ninguna)';

    const avisos = [];
    if (!m.nombre) avisos.push('No se detecto la columna <b>Nombre</b>: mapeala a mano o el importador no podra continuar.');
    if (!m.costo_unitario) avisos.push('Sin columna de <b>precio</b>: los productos entrarian sin costo_unitario.');
    if (m.costo_unitario && !m.moneda) {
        avisos.push(estado.monedaDetectada && norm(estado.monedaDetectada) !== norm(monTxt)
            ? `El encabezado de precio sugiere <b>${estado.monedaDetectada}</b>, pero la moneda por defecto es <b>${monTxt}</b>. Ajusta "Moneda por defecto" o mapea una columna de moneda.`
            : `No hay columna de <b>moneda</b>: se usara <b>${monTxt}</b> para todas las filas.`);
    }
    if (s.sinNombre) avisos.push(`<b>${s.sinNombre}</b> fila(s) sin nombre (se marcaran como error).`);
    if (s.sinPrecio) avisos.push(`<b>${s.sinPrecio}</b> fila(s) sin precio: entrarian sin costo.`);
    if (s.precioMal) avisos.push(`<b>${s.precioMal}</b> fila(s) con precio no numerico.`);
    if (s.provNuevos.length) avisos.push(`Se crearian <b>${s.provNuevos.length}</b> proveedor(es) nuevo(s).`);
    if (s.dups.length) avisos.push(`<b>${s.dups.length}</b> posible(s) duplicado(s) de productos que ya existen.`);

    const mapPairs = CAMPOS.map((c) => `${c.label}: <span class="${m[c.key] ? 'text-emerald-400' : 'text-slate-600'}">${m[c.key] || '—'}</span>`).join(' &nbsp;·&nbsp; ');

    cont.innerHTML = `
        <div class="font-semibold text-sky-400 mb-1">Pre-resumen</div>
        <div class="mb-2">${mapPairs}</div>
        <div class="flex flex-wrap gap-3 mb-2">
            <span class="px-2 py-0.5 rounded bg-slate-800 border border-slate-700">${s.total} filas</span>
            <span class="px-2 py-0.5 rounded bg-emerald-950 border border-emerald-800 text-emerald-400">${s.crear} a crear</span>
            <span class="px-2 py-0.5 rounded bg-sky-950 border border-sky-800 text-sky-400">${s.actualizar} a actualizar</span>
            <span class="px-2 py-0.5 rounded bg-slate-800 border border-slate-700">moneda: ${monTxt}</span>
        </div>
        ${avisos.length ? `<ul class="list-disc pl-4 space-y-0.5 text-amber-300/90">${avisos.map((a) => `<li>${a}</li>`).join('')}</ul>` : `<div class="text-emerald-400">Sin avisos: el mapeo se ve completo.</div>`}
        ${s.provNuevos.length ? `<div class="mt-2 text-slate-400"><b>Proveedores nuevos:</b> ${s.provNuevos.slice(0, 20).join(' · ')}${s.provNuevos.length > 20 ? ' …' : ''}</div>` : ''}
        ${s.dups.length ? `<div class="mt-1 text-slate-400"><b>Posibles duplicados:</b> ${s.dups.slice(0, 8).map(([a, b]) => `"${a}" ≈ "${b}"`).join(' · ')}${s.dups.length > 8 ? ' …' : ''}</div>` : ''}
        <div class="mt-2 text-slate-500">Pulsa <span class="text-sky-300">Validar</span> para el detalle fila por fila y elegir cuales importar.</div>
    `;
}

// --------------------------- referencias de la BD ---------------------------

async function cargarReferencias() {
    try {
        const [prov, um, mon, prod] = await Promise.all([
            supabaseClient.from('proveedores').select('id, nombre'),
            supabaseClient.from('unidades_medida').select('id, nombre'),
            supabaseClient.from('monedas').select('id, codigo'),
            supabaseClient.from('productos').select('id, nombre, sku'),
        ]);
        for (const r of [prov, um, mon, prod]) if (r.error) throw r.error;

        const R = estado.refs;
        R.provPorNombre = new Map((prov.data || []).map((p) => [norm(p.nombre), p.id]));
        R.umPorNombre = new Map((um.data || []).map((u) => [norm(u.nombre), u.id]));
        R.monPorCodigo = new Map((mon.data || []).map((m) => [norm(m.codigo), m.id]));
        R.monedas = mon.data || [];
        R.unidades = um.data || [];
        R.prodPorSku = new Map();
        R.prodPorNombre = new Map();
        for (const p of prod.data || []) {
            if (p.sku) R.prodPorSku.set(norm(p.sku), p);
            R.prodPorNombre.set(norm(p.nombre), p);
        }

        const selMon = document.getElementById('impMonedaDef');
        selMon.innerHTML = R.monedas.map((m) => `<option value="${m.id}">${m.codigo}</option>`).join('');
        const mxn = R.monedas.find((m) => norm(m.codigo) === 'mxn');
        if (mxn) selMon.value = mxn.id;

        const selUm = document.getElementById('impUnidadDef');
        selUm.innerHTML = `<option value="">(ninguna)</option>` +
            R.unidades.map((u) => `<option value="${u.id}">${u.nombre}</option>`).join('');

        // si ya habia una hoja cargada, recalcula el pre-resumen con los catalogos frescos
        if (estado.filas.length) renderPreResumen();
    } catch (err) {
        console.error('Error al cargar referencias del importador:', err);
        const info = document.getElementById('impArchivoInfo');
        if (info) info.innerHTML = `<span class="text-rose-400">No se pudieron cargar catalogos (proveedores/monedas/unidades): ${err.message || err}</span>`;
    }
}

// --------------------------- validacion ---------------------------

function celda(fila, campoKey) {
    const col = estado.mapeo[campoKey];
    if (!col) return '';
    return fila[col] ?? '';
}

// Devuelve el nombre de un producto existente que se PARECE a `nombre`
// (uno contiene al otro), o '' si no hay.
function posibleDuplicado(nombre) {
    const nn = norm(nombre);
    if (nn.length < 4) return '';
    for (const [k, p] of estado.refs.prodPorNombre) {
        if (k === nn) return ''; // coincidencia exacta -> es "actualizar", no duplicado
        if (k.length >= 4 && (k.includes(nn) || nn.includes(k))) return p.nombre;
    }
    return '';
}

function validar() {
    if (!estado.filas.length) { alert('Primero carga un archivo con datos.'); return; }
    if (!estado.mapeo.nombre) { alert('Debes mapear la columna "Nombre del producto".'); return; }

    const R = estado.refs;
    const monedaDef = document.getElementById('impMonedaDef').value ? Number(document.getElementById('impMonedaDef').value) : null;
    const unidadDef = document.getElementById('impUnidadDef').value ? Number(document.getElementById('impUnidadDef').value) : null;
    const crearProv = document.getElementById('impCrearProv').checked;

    const plan = estado.filas.map((fila, idx) => {
        const problemas = [];
        const nombre = String(celda(fila, 'nombre')).trim();
        const sku = String(celda(fila, 'sku')).trim();
        const descripcion = String(celda(fila, 'descripcion')).trim();
        const provNombre = String(celda(fila, 'proveedor')).trim();

        // precio
        let precio = null;
        const precioRaw = celda(fila, 'costo_unitario');
        if (estado.mapeo.costo_unitario && String(precioRaw).trim() !== '') {
            precio = parseNumero(precioRaw);
            if (precio === null) problemas.push('precio no numerico ("' + precioRaw + '")');
        }

        // moneda
        let monedaId = monedaDef, monedaTxt = '';
        const monRaw = String(celda(fila, 'moneda')).trim();
        if (monRaw) {
            const hit = R.monPorCodigo.get(norm(monRaw));
            if (hit) { monedaId = hit; monedaTxt = monRaw.toUpperCase(); }
            else { monedaTxt = monRaw.toUpperCase() + ' → def'; problemas.push('moneda "' + monRaw + '" desconocida, se usa la de por defecto'); }
        }

        // unidad
        let unidadId = unidadDef, unidadTxt = '';
        const uniRaw = String(celda(fila, 'unidad')).trim();
        if (uniRaw) {
            const hit = R.umPorNombre.get(norm(uniRaw));
            if (hit) { unidadId = hit; unidadTxt = uniRaw; }
            else { unidadTxt = uniRaw + ' → def'; problemas.push('unidad "' + uniRaw + '" no existe, se usa la de por defecto'); }
        }

        // proveedor
        let provId = null, provNuevo = false;
        if (provNombre) {
            const hit = R.provPorNombre.get(norm(provNombre));
            if (hit) provId = hit;
            else { provNuevo = true; if (!crearProv) problemas.push('proveedor "' + provNombre + '" no existe (no se creara)'); }
        }

        // match de producto
        let accion = 'crear', prodId = null, via = '';
        if (sku && R.prodPorSku.has(norm(sku))) { accion = 'actualizar'; prodId = R.prodPorSku.get(norm(sku)).id; via = 'SKU'; }
        else if (!sku && R.prodPorNombre.has(norm(nombre))) { accion = 'actualizar'; prodId = R.prodPorNombre.get(norm(nombre)).id; via = 'nombre'; }

        // posible duplicado (solo tiene sentido avisar si se va a crear)
        let dupDe = '';
        if (accion === 'crear') {
            dupDe = posibleDuplicado(nombre);
            if (dupDe) problemas.push('posible duplicado de "' + dupDe + '"');
        }

        // ---- campos nuevos (tipo, tasas, stock minimo, entrega, MOQ, activo) ----
        const extras = {};
        let tipoCol = '';
        if (estado.mapeo.tipo) {
            tipoCol = parseTipoProducto(celda(fila, 'tipo'));
            const rawT = String(celda(fila, 'tipo')).trim();
            if (rawT && !tipoCol) problemas.push('tipo "' + rawT + '" no reconocido');
        }
        if (estado.mapeo.tasa_iva) {
            const r = parseTasaImp(celda(fila, 'tasa_iva'));
            if (r.err) problemas.push('IVA no numerico');
            else if (r.val !== undefined) extras.tasa_iva = r.val;   // null = exento
        }
        if (estado.mapeo.tasa_ieps) {
            const r = parseTasaImp(celda(fila, 'tasa_ieps'));
            if (r.err) problemas.push('IEPS no numerico');
            else if (r.val !== undefined) extras.tasa_ieps = r.val ?? 0;
        }
        for (const [k, lbl] of [
            ['stock_minimo', 'stock minimo'],
            ['tiempo_entrega_dias', 'tiempo de entrega'],
            ['cantidad_minima_compra', 'cantidad minima de compra'],
        ]) {
            if (!estado.mapeo[k]) continue;
            const raw = String(celda(fila, k)).trim();
            if (raw === '') continue;
            const n = parseNumero(raw);
            if (n === null) { problemas.push(lbl + ' no numerico ("' + raw + '")'); continue; }
            extras[k] = k === 'tiempo_entrega_dias' ? Math.round(Math.abs(n)) : Math.abs(n);
        }
        if (estado.mapeo.activo) {
            const b = parseBooleano(celda(fila, 'activo'));
            if (b === undefined) {
                const rawA = String(celda(fila, 'activo')).trim();
                if (rawA) problemas.push('activo "' + rawA + '" no reconocido (usa si/no)');
            } else {
                extras.activo = b;
            }
        }

        if (!nombre) { accion = 'error'; problemas.push('sin nombre'); }

        return {
            fila: estado.filaDatos + idx, nombre, sku, descripcion, provNombre, provId, provNuevo,
            precio, monedaId, monedaTxt, unidadId, unidadTxt, accion, prodId, via, dupDe, problemas,
            extras, tipoCol,
            // control del usuario:
            incluir: accion !== 'error',   // se puede desmarcar fila por fila
            tipoOverride: '',              // tipo elegido para ESTA fila (solo aplica al crear)
        };
    });

    estado.plan = plan;
    renderPreview(plan);
    actualizarBotonImportar();
}

function actualizarBotonImportar() {
    const btn = document.getElementById('impImportar');
    const n = (estado.plan || []).filter((p) => p.incluir && p.accion !== 'error').length;
    btn.textContent = n ? `Importar (${n})` : 'Importar';
    btn.disabled = n === 0;
}

const TIPOS = [
    { v: 'materia_prima', t: 'Materia prima' },
    { v: 'insumo', t: 'Insumo' },
    { v: 'producto', t: 'Producto' },
];

function renderPreview(plan) {
    const cont = document.getElementById('impPreview');
    const crear = plan.filter((p) => p.accion === 'crear').length;
    const actualizar = plan.filter((p) => p.accion === 'actualizar').length;
    const errores = plan.filter((p) => p.accion === 'error').length;
    const provNuevos = new Set(plan.filter((p) => p.provNuevo).map((p) => norm(p.provNombre))).size;
    const tipoDef = document.getElementById('impTipo').value;

    const badge = (a) => a === 'crear'
        ? `<span class="text-emerald-400">crear</span>`
        : a === 'actualizar'
            ? `<span class="text-sky-400">actualizar</span>`
            : `<span class="text-rose-400">error</span>`;

    const selTipo = (p, i) => {
        if (p.accion !== 'crear') return '<span class="text-slate-600">—</span>';
        if (p.tipoCol) {
            const lbl = (TIPOS.find((x) => x.v === p.tipoCol) || {}).t || p.tipoCol;
            return `<span class="text-slate-300" title="tomado del archivo">${lbl} <span class="text-slate-600">(archivo)</span></span>`;
        }
        const val = p.tipoOverride || tipoDef;
        return `<select data-i="${i}" class="imp-row-tipo bg-slate-900 border border-slate-800 rounded p-1 text-[11px] text-slate-100">
            ${TIPOS.map((x) => `<option value="${x.v}" ${x.v === val ? 'selected' : ''}>${x.t}</option>`).join('')}
        </select>`;
    };

    cont.innerHTML = `
        <div class="flex flex-wrap gap-3 mb-3 text-xs">
            <span class="px-2 py-1 rounded bg-emerald-950 border border-emerald-800 text-emerald-400">${crear} a crear</span>
            <span class="px-2 py-1 rounded bg-sky-950 border border-sky-800 text-sky-400">${actualizar} a actualizar</span>
            <span class="px-2 py-1 rounded bg-rose-950 border border-rose-800 text-rose-400">${errores} con error</span>
            <span class="px-2 py-1 rounded bg-slate-900 border border-slate-700 text-slate-300">${provNuevos} proveedor(es) nuevo(s)</span>
        </div>

        <div class="flex flex-wrap items-center gap-2 mb-2">
            <input type="text" id="impFiltro" placeholder="filtrar por nombre o SKU..."
                class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-[11px] text-slate-100 w-52 focus:outline-none focus:border-sky-500">
            <span class="text-[11px] text-slate-500">Marcar:</span>
            <button type="button" data-sel="todos"      class="imp-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Todos</button>
            <button type="button" data-sel="ninguno"    class="imp-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Ninguno</button>
            <button type="button" data-sel="nuevos"     class="imp-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-emerald-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Solo nuevos</button>
            <button type="button" data-sel="actualizar" class="imp-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Solo a actualizar</button>
            <button type="button" data-sel="filtrados"  class="imp-sel text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-200 px-2 py-1 rounded border border-slate-700 cursor-pointer">Marcar filtrados</button>
        </div>

        <div class="overflow-x-auto max-h-80 overflow-y-auto border border-slate-800 rounded-lg">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-sky-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr>
                        <th class="p-2"><input type="checkbox" id="impChkTodos" class="accent-sky-500"></th>
                        <th class="p-2">#</th><th class="p-2">Accion</th><th class="p-2">Tipo (nuevos)</th><th class="p-2">Nombre</th><th class="p-2">SKU</th>
                        <th class="p-2">Precio</th><th class="p-2">Mon.</th><th class="p-2">Unid.</th><th class="p-2">Proveedor</th><th class="p-2">Notas</th>
                    </tr>
                </thead>
                <tbody>
                    ${plan.map((p, i) => `
                        <tr class="imp-row border-b border-slate-900 ${p.incluir ? '' : 'opacity-40'}" data-i="${i}"
                            data-buscar="${norm(p.nombre + ' ' + p.sku)}">
                            <td class="p-2">
                                <input type="checkbox" data-i="${i}" class="imp-row-chk accent-sky-500"
                                    ${p.incluir ? 'checked' : ''} ${p.accion === 'error' ? 'disabled' : ''}>
                            </td>
                            <td class="p-2 text-slate-500">${p.fila}</td>
                            <td class="p-2">${badge(p.accion)}${p.via ? ` <span class="text-slate-600">(${p.via})</span>` : ''}</td>
                            <td class="p-2">${selTipo(p, i)}</td>
                            <td class="p-2 text-slate-100">${p.nombre || '<span class="text-rose-400">—</span>'}</td>
                            <td class="p-2 font-mono text-slate-400">${p.sku || ''}</td>
                            <td class="p-2 font-mono">${p.precio ?? ''}</td>
                            <td class="p-2 text-slate-400">${p.monedaTxt || ''}</td>
                            <td class="p-2 text-slate-400">${p.unidadTxt || ''}</td>
                            <td class="p-2 text-slate-400">${p.provNombre || ''}${p.provNuevo ? ' <span class="text-emerald-500">+nuevo</span>' : ''}</td>
                            <td class="p-2 text-amber-400/80">${p.problemas.join('; ')}</td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>`;

    cablearPreview();
}

function cablearPreview() {
    const plan = estado.plan || [];

    document.querySelectorAll('.imp-row-chk').forEach((chk) => {
        chk.addEventListener('change', (e) => {
            const i = Number(e.target.dataset.i);
            plan[i].incluir = e.target.checked;
            e.target.closest('tr').classList.toggle('opacity-40', !e.target.checked);
            actualizarBotonImportar();
        });
    });

    document.querySelectorAll('.imp-row-tipo').forEach((sel) => {
        sel.addEventListener('change', (e) => {
            plan[Number(e.target.dataset.i)].tipoOverride = e.target.value;
        });
    });

    const chkTodos = document.getElementById('impChkTodos');
    if (chkTodos) chkTodos.addEventListener('change', (e) => aplicarSeleccion(e.target.checked ? 'todos' : 'ninguno'));

    document.querySelectorAll('.imp-sel').forEach((b) => {
        b.addEventListener('click', () => aplicarSeleccion(b.dataset.sel));
    });

    const filtro = document.getElementById('impFiltro');
    if (filtro) filtro.addEventListener('input', () => {
        const q = norm(filtro.value);
        document.querySelectorAll('.imp-row').forEach((tr) => {
            tr.classList.toggle('hidden', q !== '' && !tr.dataset.buscar.includes(q));
        });
    });
}

// Aplica una seleccion masiva y vuelve a pintar la vista previa.
function aplicarSeleccion(modo) {
    const plan = estado.plan || [];
    const raw = document.getElementById('impFiltro')?.value || '';
    const q = norm(raw);
    const visible = (p) => q === '' || norm(p.nombre + ' ' + p.sku).includes(q);

    plan.forEach((p) => {
        if (p.accion === 'error') { p.incluir = false; return; }
        if (modo === 'todos') p.incluir = true;
        else if (modo === 'ninguno') p.incluir = false;
        else if (modo === 'nuevos') p.incluir = p.accion === 'crear';
        else if (modo === 'actualizar') p.incluir = p.accion === 'actualizar';
        else if (modo === 'filtrados') { if (visible(p)) p.incluir = true; }
    });

    renderPreview(plan);
    const f = document.getElementById('impFiltro');
    if (f && raw) { f.value = raw; f.dispatchEvent(new Event('input')); }
    actualizarBotonImportar();
}

// --------------------------- importacion ---------------------------

async function importar() {
    if (!estado.plan) { alert('Primero pulsa Validar.'); return; }
    const btn = document.getElementById('impImportar');
    btn.disabled = true;
    btn.textContent = 'Importando...';

    const R = estado.refs;
    const tipoDef = document.getElementById('impTipo').value;
    const crearProv = document.getElementById('impCrearProv').checked;
    const resultados = [];
    let creados = 0, actualizados = 0, fallidos = 0, omitidos = 0;

    for (const p of estado.plan) {
        if (p.accion === 'error') { resultados.push({ ...p, estado: 'omitido', detalle: p.problemas.join('; ') }); omitidos++; continue; }
        if (!p.incluir) { resultados.push({ ...p, estado: 'omitido', detalle: 'desmarcada' }); omitidos++; continue; }
        try {
            // proveedor (crear si hace falta y esta permitido)
            let provId = p.provId;
            if (!provId && p.provNombre && crearProv) {
                const clave = norm(p.provNombre);
                if (R.provPorNombre.has(clave)) {
                    provId = R.provPorNombre.get(clave);
                } else {
                    const { data, error } = await supabaseClient.from('proveedores').insert([{ nombre: p.provNombre }]).select('id').single();
                    if (error) throw new Error('proveedor: ' + error.message);
                    provId = data.id;
                    R.provPorNombre.set(clave, provId);
                }
            }

            const campos = {};
            if (estado.mapeo.sku && p.sku) campos.sku = p.sku;
            if (p.unidadId) campos.unidad_medida_id = p.unidadId;
            if (p.precio !== null && p.precio !== undefined) campos.costo_unitario = p.precio;
            if (p.monedaId) campos.moneda_id = p.monedaId;
            if (provId) campos.proveedor_id = provId;
            if (estado.mapeo.descripcion && p.descripcion) campos.descripcion = p.descripcion;
            // campos nuevos mapeados (tasas, stock minimo, entrega, MOQ, activo)
            Object.assign(campos, p.extras || {});
            // el tipo tomado de una columna manda sobre el default / override
            if (p.tipoCol) campos.tipo = p.tipoCol;

            if (p.accion === 'actualizar') {
                const { error } = await supabaseClient.from('productos').update(campos).eq('id', p.prodId);
                if (error) throw new Error(error.message);
                resultados.push({ ...p, estado: 'actualizado', detalle: '' });
                actualizados++;
            } else {
                const payload = { tipo: p.tipoCol || p.tipoOverride || tipoDef, nombre: p.nombre, ...campos };
                const { data, error } = await supabaseClient.from('productos').insert([payload]).select('id').single();
                if (error) throw new Error(error.code === '23505' ? 'SKU duplicado' : error.message);
                if (p.sku) R.prodPorSku.set(norm(p.sku), { id: data.id });
                R.prodPorNombre.set(norm(p.nombre), { id: data.id });
                resultados.push({ ...p, estado: 'creado', detalle: '' });
                creados++;
            }
        } catch (err) {
            resultados.push({ ...p, estado: 'fallo', detalle: err.message || String(err) });
            fallidos++;
        }
    }

    renderResultado(resultados, { creados, actualizados, fallidos, omitidos });

    // Se invalida el plan para no reimportar por accidente: hay que volver a
    // pulsar "Validar" (que ademas reflejara los productos recien creados).
    estado.plan = null;
    btn.textContent = 'Importar';
    btn.disabled = true;
    await cargarReferencias();
}

function renderResultado(resultados, tot) {
    const cont = document.getElementById('impResultado');
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
                <thead class="bg-slate-900 text-sky-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr><th class="p-2">#</th><th class="p-2">Producto</th><th class="p-2">Resultado</th><th class="p-2">Detalle</th></tr>
                </thead>
                <tbody>
                    ${resultados.map((r) => `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 text-slate-500">${r.fila}</td>
                            <td class="p-2 text-slate-100">${r.nombre || ''} ${r.sku ? `<span class="text-slate-600 font-mono">${r.sku}</span>` : ''}</td>
                            <td class="p-2 ${color(r.estado)}">${r.estado}</td>
                            <td class="p-2 text-amber-400/80">${r.detalle || ''}</td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>
        <p class="text-slate-500 mt-3">Listo. Abre <span class="text-sky-300">Catalogos → Productos</span> para ver los cambios.</p>`;
}
