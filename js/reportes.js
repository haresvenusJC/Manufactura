import { supabaseClient } from './supabase.js';
import { imprimirConPlantilla } from './impresion.js';

// =====================================================================
// Módulo de Reportes: 3 reportes canónicos + tabla dinámica genérica.
//
// La tabla dinámica está construida sobre un registro de "datasets"
// (PIVOT_DATASETS): agregar un reporte nuevo a futuro es, en general,
// registrar un fetcher que devuelva filas planas + declarar sus
// dimensiones/medidas, sin tocar el motor de agregación ni el render.
// =====================================================================

// ---------- Helpers compartidos (mismo patrón que contabilidad.js) ----------
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const numero = (n) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };

const ETIQUETAS_TIPO_PRODUCTO = {
    materia_prima: 'Materia prima',
    insumo: 'Insumo',
    producto: 'Producto terminado',
    sin_tipo: 'Sin tipo',
};

// ---------- Exportar CSV / Imprimir (reutilizable en cualquier reporte) ----------
function escaparCSV(texto) {
    const s = String(texto ?? '').trim();
    return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

function exportarCSV(tablaContenedorId, nombreArchivo) {
    const tabla = document.getElementById(tablaContenedorId)?.querySelector('table');
    if (!tabla) { alert('No hay datos para exportar.'); return; }

    const filas = [];
    tabla.querySelectorAll('tr').forEach((tr) => {
        const celdas = [...tr.children].map((td) => escaparCSV(td.textContent));
        filas.push(celdas.join(','));
    });

    const csv = '﻿' + filas.join('\r\n'); // BOM para que Excel respete acentos/ñ
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${nombreArchivo}_${hoyISO()}.csv`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
}

function barraAcciones(tablaContenedorId, nombreArchivo) {
    return `
        <div class="flex justify-end gap-2 mb-2 no-print">
            <button class="rep-btn-csv text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 px-3 py-2 rounded-lg border border-slate-700 transition" data-target="${tablaContenedorId}" data-archivo="${nombreArchivo}" style="cursor: pointer;">⬇️ Exportar CSV</button>
            <button class="rep-btn-print text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 transition" data-target="${tablaContenedorId}" data-titulo="${nombreArchivo}" style="cursor: pointer;">🖨️ Imprimir</button>
        </div>
    `;
}

function wireBarraAcciones(root) {
    root.querySelectorAll('.rep-btn-csv').forEach((btn) => {
        btn.addEventListener('click', () => exportarCSV(btn.dataset.target, btn.dataset.archivo));
    });
    root.querySelectorAll('.rep-btn-print').forEach((btn) => {
        btn.addEventListener('click', () => imprimirConPlantilla('generico', btn.dataset.titulo, btn.dataset.target));
    });
}

// ---------- Fetchers de datos (compartidos entre reporte canónico y pivot) ----------

async function fetchComprasDetalle(desde, hasta) {
    const { data, error } = await supabaseClient
        .from('documentos')
        .select(`
            id, folio, fecha_emision,
            proveedores ( nombre ),
            documento_detalles ( cantidad, costo_unitario, subtotal, productos ( nombre ) )
        `)
        .eq('tipo_movimiento', 'entrada_compra')
        .gte('fecha_emision', desde)
        .lte('fecha_emision', hasta)
        .order('fecha_emision', { ascending: false })
        .limit(500);
    if (error) throw error;

    const filas = [];
    (data || []).forEach((doc) => {
        (doc.documento_detalles || []).forEach((det) => {
            filas.push({
                proveedor: doc.proveedores?.nombre || 'Sin proveedor',
                producto: det.productos?.nombre || 'N/D',
                folio: doc.folio || '',
                fecha: doc.fecha_emision,
                cantidad: Number(det.cantidad) || 0,
                costo_unitario: Number(det.costo_unitario) || 0,
                subtotal: Number(det.subtotal) || 0,
            });
        });
    });
    return filas;
}

async function fetchGastosDetalle(desde, hasta) {
    const { data, error } = await supabaseClient
        .from('gastos')
        .select('id, fecha, concepto, subtotal, iva, ieps, total, estatus, cuenta_gasto_id, cuentas_contables!cuenta_gasto_id(codigo, nombre)')
        .gte('fecha', desde)
        .lte('fecha', hasta)
        .neq('estatus', 'cancelado')
        .order('fecha', { ascending: false })
        .limit(500);
    if (error) throw error;

    return (data || []).map((g) => ({
        cuenta: g.cuentas_contables ? `${g.cuentas_contables.codigo} · ${g.cuentas_contables.nombre}` : 'Sin cuenta',
        concepto: g.concepto || '',
        estatus: g.estatus || '',
        fecha: g.fecha,
        subtotal: Number(g.subtotal) || 0,
        iva: Number(g.iva) || 0,
        total: Number(g.total) || 0,
    }));
}

async function fetchInventarioValorizado() {
    const { data, error } = await supabaseClient
        .from('productos')
        .select('id, nombre, sku, tipo, stock_actual, costo_unitario')
        .order('tipo', { ascending: true })
        .order('nombre', { ascending: true })
        .limit(2000);
    if (error) throw error;

    return (data || []).map((p) => ({
        producto: p.nombre,
        sku: p.sku || '',
        tipo: p.tipo || 'sin_tipo',
        stock: Number(p.stock_actual) || 0,
        costo_unitario: Number(p.costo_unitario) || 0,
        valor: (Number(p.stock_actual) || 0) * (Number(p.costo_unitario) || 0),
    }));
}

async function fetchMovimientosInventario(desde, hasta) {
    const { data, error } = await supabaseClient
        .from('movimientos_inventario')
        .select(`
            id, tipo_movimiento, cantidad, costo_unitario, created_at,
            productos ( nombre, tipo )
        `)
        .gte('created_at', `${desde}T00:00:00`)
        .lte('created_at', `${hasta}T23:59:59`)
        .order('created_at', { ascending: false })
        .limit(2000);
    if (error) throw error;

    return (data || []).map((m) => ({
        producto: m.productos?.nombre || 'N/D',
        tipo_producto: m.productos?.tipo || 'sin_tipo',
        tipo_movimiento: m.tipo_movimiento || '',
        cantidad: Number(m.cantidad) || 0,
        importe: (Number(m.cantidad) || 0) * (Number(m.costo_unitario) || 0),
        fecha: (m.created_at || '').slice(0, 10),
    }));
}

// ---------- Reporte 1: Compras por proveedor ----------

async function renderComprasPorProveedor(cont) {
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl space-y-4">
            <div class="flex flex-wrap items-end gap-3 no-print">
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Desde</label>
                    <input type="date" id="repCompDesde" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Hasta</label>
                    <input type="date" id="repCompHasta" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <button id="repCompBuscar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 transition" style="cursor: pointer;">Buscar</button>
            </div>
            <div id="repCompResultado"><p class="text-slate-500 text-sm text-center py-8">Cargando...</p></div>
        </div>
    `;
    document.getElementById('repCompDesde').value = primerDiaMesISO();
    document.getElementById('repCompHasta').value = hoyISO();
    document.getElementById('repCompBuscar').addEventListener('click', buscarComprasPorProveedor);
    await buscarComprasPorProveedor();
}

async function buscarComprasPorProveedor() {
    const resultado = document.getElementById('repCompResultado');
    if (!resultado) return;
    const desde = document.getElementById('repCompDesde').value;
    const hasta = document.getElementById('repCompHasta').value;
    resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">Cargando...</p>';

    try {
        const filas = await fetchComprasDetalle(desde, hasta);
        if (filas.length === 0) {
            resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">No hay compras en ese periodo.</p>';
            return;
        }

        const grupos = new Map();
        filas.forEach((f) => {
            if (!grupos.has(f.proveedor)) grupos.set(f.proveedor, { subtotal: 0, partidas: 0 });
            const g = grupos.get(f.proveedor);
            g.subtotal += f.subtotal;
            g.partidas += 1;
        });
        const ordenados = [...grupos.entries()].sort((a, b) => b[1].subtotal - a[1].subtotal);
        const totalGeneral = ordenados.reduce((acc, [, g]) => acc + g.subtotal, 0);

        resultado.innerHTML = `
            ${barraAcciones('repCompTabla', 'compras_por_proveedor')}
            <div id="repCompTabla" class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-slate-950 text-xs uppercase text-sky-400 border-b border-slate-800">
                        <tr><th class="p-3 text-left">Proveedor</th><th class="p-3 text-right">Partidas</th><th class="p-3 text-right">Subtotal</th></tr>
                    </thead>
                    <tbody>
                        ${ordenados.map(([prov, g]) => `
                            <tr class="border-b border-slate-900">
                                <td class="p-3 text-slate-200">${prov}</td>
                                <td class="p-3 text-right text-slate-400">${g.partidas}</td>
                                <td class="p-3 text-right font-mono text-emerald-400">${money(g.subtotal)}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="bg-slate-950 font-semibold">
                            <td class="p-3 text-slate-200">Total general</td>
                            <td class="p-3 text-right text-slate-400">${filas.length}</td>
                            <td class="p-3 text-right font-mono text-emerald-300">${money(totalGeneral)}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
        wireBarraAcciones(resultado);
    } catch (e) {
        resultado.innerHTML = `<p class="text-rose-400 text-sm">Error al cargar el reporte: ${e.message || e}</p>`;
    }
}

// ---------- Reporte 2: Gastos por cuenta ----------

async function renderGastosPorCuenta(cont) {
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl space-y-4">
            <div class="flex flex-wrap items-end gap-3 no-print">
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Desde</label>
                    <input type="date" id="repGasDesde" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Hasta</label>
                    <input type="date" id="repGasHasta" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <button id="repGasBuscar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 transition" style="cursor: pointer;">Buscar</button>
            </div>
            <div id="repGasResultado"><p class="text-slate-500 text-sm text-center py-8">Cargando...</p></div>
        </div>
    `;
    document.getElementById('repGasDesde').value = primerDiaMesISO();
    document.getElementById('repGasHasta').value = hoyISO();
    document.getElementById('repGasBuscar').addEventListener('click', buscarGastosPorCuenta);
    await buscarGastosPorCuenta();
}

async function buscarGastosPorCuenta() {
    const resultado = document.getElementById('repGasResultado');
    if (!resultado) return;
    const desde = document.getElementById('repGasDesde').value;
    const hasta = document.getElementById('repGasHasta').value;
    resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">Cargando...</p>';

    try {
        const filas = await fetchGastosDetalle(desde, hasta);
        if (filas.length === 0) {
            resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">No hay gastos en ese periodo.</p>';
            return;
        }

        const grupos = new Map();
        filas.forEach((f) => {
            if (!grupos.has(f.cuenta)) grupos.set(f.cuenta, { subtotal: 0, iva: 0, total: 0, registros: 0 });
            const g = grupos.get(f.cuenta);
            g.subtotal += f.subtotal;
            g.iva += f.iva;
            g.total += f.total;
            g.registros += 1;
        });
        const ordenados = [...grupos.entries()].sort((a, b) => b[1].total - a[1].total);
        const totales = ordenados.reduce((acc, [, g]) => ({
            subtotal: acc.subtotal + g.subtotal, iva: acc.iva + g.iva, total: acc.total + g.total,
        }), { subtotal: 0, iva: 0, total: 0 });

        resultado.innerHTML = `
            ${barraAcciones('repGasTabla', 'gastos_por_cuenta')}
            <div id="repGasTabla" class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-slate-950 text-xs uppercase text-sky-400 border-b border-slate-800">
                        <tr>
                            <th class="p-3 text-left">Cuenta</th><th class="p-3 text-right">Registros</th>
                            <th class="p-3 text-right">Subtotal</th><th class="p-3 text-right">IVA</th><th class="p-3 text-right">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${ordenados.map(([cuenta, g]) => `
                            <tr class="border-b border-slate-900">
                                <td class="p-3 text-slate-200">${cuenta}</td>
                                <td class="p-3 text-right text-slate-400">${g.registros}</td>
                                <td class="p-3 text-right font-mono text-slate-300">${money(g.subtotal)}</td>
                                <td class="p-3 text-right font-mono text-slate-300">${money(g.iva)}</td>
                                <td class="p-3 text-right font-mono text-emerald-400">${money(g.total)}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="bg-slate-950 font-semibold">
                            <td class="p-3 text-slate-200">Total general</td>
                            <td class="p-3 text-right text-slate-400">${filas.length}</td>
                            <td class="p-3 text-right font-mono text-slate-300">${money(totales.subtotal)}</td>
                            <td class="p-3 text-right font-mono text-slate-300">${money(totales.iva)}</td>
                            <td class="p-3 text-right font-mono text-emerald-300">${money(totales.total)}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
        wireBarraAcciones(resultado);
    } catch (e) {
        resultado.innerHTML = `<p class="text-rose-400 text-sm">Error al cargar el reporte: ${e.message || e}</p>`;
    }
}

// ---------- Reporte 3: Inventario valorizado ----------

async function renderInventarioValorizado(cont) {
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl space-y-4">
            <div class="flex items-center justify-between no-print">
                <p class="text-xs text-slate-400">Valor actual de existencias (stock × costo unitario), agrupado por tipo de producto.</p>
                <button id="repInvActualizar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 transition shrink-0" style="cursor: pointer;">↻ Actualizar</button>
            </div>
            <div id="repInvResultado"><p class="text-slate-500 text-sm text-center py-8">Cargando...</p></div>
        </div>
    `;
    document.getElementById('repInvActualizar').addEventListener('click', buscarInventarioValorizado);
    await buscarInventarioValorizado();
}

async function buscarInventarioValorizado() {
    const resultado = document.getElementById('repInvResultado');
    if (!resultado) return;
    resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">Cargando...</p>';

    try {
        const filas = await fetchInventarioValorizado();
        if (filas.length === 0) {
            resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">No hay productos registrados.</p>';
            return;
        }

        const grupos = new Map();
        filas.forEach((f) => {
            if (!grupos.has(f.tipo)) grupos.set(f.tipo, { valor: 0, items: 0 });
            const g = grupos.get(f.tipo);
            g.valor += f.valor;
            g.items += 1;
        });
        const ordenados = [...grupos.entries()].sort((a, b) => b[1].valor - a[1].valor);
        const totalGeneral = ordenados.reduce((acc, [, g]) => acc + g.valor, 0);

        resultado.innerHTML = `
            ${barraAcciones('repInvTabla', 'inventario_valorizado')}
            <div id="repInvTabla" class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead class="bg-slate-950 text-xs uppercase text-sky-400 border-b border-slate-800">
                        <tr><th class="p-3 text-left">Tipo</th><th class="p-3 text-right">Productos</th><th class="p-3 text-right">Valor</th></tr>
                    </thead>
                    <tbody>
                        ${ordenados.map(([tipo, g]) => `
                            <tr class="border-b border-slate-900">
                                <td class="p-3 text-slate-200">${ETIQUETAS_TIPO_PRODUCTO[tipo] || tipo}</td>
                                <td class="p-3 text-right text-slate-400">${g.items}</td>
                                <td class="p-3 text-right font-mono text-emerald-400">${money(g.valor)}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="bg-slate-950 font-semibold">
                            <td class="p-3 text-slate-200">Total general</td>
                            <td class="p-3 text-right text-slate-400">${filas.length}</td>
                            <td class="p-3 text-right font-mono text-emerald-300">${money(totalGeneral)}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
        wireBarraAcciones(resultado);
    } catch (e) {
        resultado.innerHTML = `<p class="text-rose-400 text-sm">Error al cargar el reporte: ${e.message || e}</p>`;
    }
}

// ---------- Tabla dinámica: registro de datasets + motor de agregación ----------
//
// Para agregar un dataset nuevo a futuro: registrar aquí un fetcher que
// devuelva un array de objetos planos, y declarar sus dimensiones/medidas.
// El motor de pivot (construirPivot/renderTablaPivot) es genérico y no
// necesita cambios.

const PIVOT_DATASETS = [
    {
        id: 'compras_detalle',
        label: 'Compras (detalle)',
        fetch: fetchComprasDetalle,
        dimensions: [
            { key: 'proveedor', label: 'Proveedor' },
            { key: 'producto', label: 'Producto' },
            { key: 'folio', label: 'Folio' },
            { key: 'fecha', label: 'Fecha' },
        ],
        measures: [
            { key: 'cantidad', label: 'Cantidad', formato: 'numero' },
            { key: 'subtotal', label: 'Subtotal', formato: 'moneda' },
            { key: 'costo_unitario', label: 'Costo unitario', formato: 'moneda' },
        ],
    },
    {
        id: 'gastos',
        label: 'Gastos',
        fetch: fetchGastosDetalle,
        dimensions: [
            { key: 'cuenta', label: 'Cuenta' },
            { key: 'concepto', label: 'Concepto' },
            { key: 'estatus', label: 'Estatus' },
            { key: 'fecha', label: 'Fecha' },
        ],
        measures: [
            { key: 'subtotal', label: 'Subtotal', formato: 'moneda' },
            { key: 'iva', label: 'IVA', formato: 'moneda' },
            { key: 'total', label: 'Total', formato: 'moneda' },
        ],
    },
    {
        id: 'movimientos',
        label: 'Movimientos de inventario',
        fetch: fetchMovimientosInventario,
        dimensions: [
            { key: 'producto', label: 'Producto' },
            { key: 'tipo_producto', label: 'Tipo de producto' },
            { key: 'tipo_movimiento', label: 'Tipo de movimiento' },
            { key: 'fecha', label: 'Fecha' },
        ],
        measures: [
            { key: 'cantidad', label: 'Cantidad', formato: 'numero' },
            { key: 'importe', label: 'Importe', formato: 'moneda' },
        ],
    },
];

const AGREGACIONES = {
    suma: { label: 'Suma', fn: (vals) => vals.reduce((a, v) => a + v, 0) },
    conteo: { label: 'Conteo', fn: (vals) => vals.length },
    promedio: { label: 'Promedio', fn: (vals) => (vals.length ? vals.reduce((a, v) => a + v, 0) / vals.length : 0) },
    min: { label: 'Mínimo', fn: (vals) => (vals.length ? Math.min(...vals) : 0) },
    max: { label: 'Máximo', fn: (vals) => (vals.length ? Math.max(...vals) : 0) },
};

const SIN_VALOR = '(vacío)';
const SIN_COLUMNA = '__total__';

// Motor puro: agrupa `rows` por filaKey (y colKey si se da) y agrega
// `valorKey` con la función elegida. Los totales de fila/columna/gran
// total se recalculan sobre los valores CRUDOS (no sobre las celdas ya
// agregadas), para que "promedio"/"mínimo"/"máximo" den totales correctos.
function construirPivot(rows, { filaKey, colKey, valorKey, agregacion }) {
    const agg = AGREGACIONES[agregacion] || AGREGACIONES.suma;
    const buckets = new Map(); // fila -> columna -> number[]

    rows.forEach((r) => {
        const fila = String(r[filaKey] ?? SIN_VALOR) || SIN_VALOR;
        const col = colKey ? (String(r[colKey] ?? SIN_VALOR) || SIN_VALOR) : SIN_COLUMNA;
        const val = Number(r[valorKey]) || 0;
        if (!buckets.has(fila)) buckets.set(fila, new Map());
        const porColumna = buckets.get(fila);
        if (!porColumna.has(col)) porColumna.set(col, []);
        porColumna.get(col).push(val);
    });

    const filas = [...buckets.keys()].sort((a, b) => a.localeCompare(b, 'es'));
    const columnasSet = new Set();
    buckets.forEach((porColumna) => porColumna.forEach((_, col) => columnasSet.add(col)));
    const columnas = colKey ? [...columnasSet].sort((a, b) => a.localeCompare(b, 'es')) : [SIN_COLUMNA];

    const celdas = new Map();
    filas.forEach((fila) => {
        const porColumna = buckets.get(fila);
        const filaMap = new Map();
        columnas.forEach((col) => filaMap.set(col, agg.fn(porColumna.get(col) || [])));
        celdas.set(fila, filaMap);
    });

    const totalesFila = new Map();
    filas.forEach((fila) => {
        const todos = [...buckets.get(fila).values()].flat();
        totalesFila.set(fila, agg.fn(todos));
    });

    const totalesColumna = new Map();
    columnas.forEach((col) => {
        const todos = [];
        filas.forEach((fila) => {
            const porColumna = buckets.get(fila);
            if (porColumna.has(col)) todos.push(...porColumna.get(col));
        });
        totalesColumna.set(col, agg.fn(todos));
    });

    const granTotal = agg.fn(rows.map((r) => Number(r[valorKey]) || 0));

    return { filas, columnas, celdas, totalesFila, totalesColumna, granTotal };
}

function formatearValor(n, formato) {
    return formato === 'moneda' ? money(n) : numero(n);
}

function renderTablaPivot(el, pivot, { filaLabel, valorLabel, colKey, formato }) {
    const conColumnas = Boolean(colKey);
    const alinear = (i) => (i === 0 ? 'text-left' : 'text-right');
    const claseValor = (i) => (i === 0 ? 'text-slate-200' : 'font-mono text-slate-300');

    let theadCols, bodyRows, tfootCols;
    if (conColumnas) {
        theadCols = [filaLabel, ...pivot.columnas, 'Total'];
        bodyRows = pivot.filas.map((fila) => [
            fila,
            ...pivot.columnas.map((c) => formatearValor(pivot.celdas.get(fila).get(c) || 0, formato)),
            formatearValor(pivot.totalesFila.get(fila), formato),
        ]);
        tfootCols = ['Total', ...pivot.columnas.map((c) => formatearValor(pivot.totalesColumna.get(c), formato)), formatearValor(pivot.granTotal, formato)];
    } else {
        theadCols = [filaLabel, valorLabel];
        bodyRows = pivot.filas.map((fila) => [fila, formatearValor(pivot.totalesFila.get(fila), formato)]);
        tfootCols = ['Total', formatearValor(pivot.granTotal, formato)];
    }

    el.innerHTML = `
        ${barraAcciones('repPivotTabla', 'tabla_dinamica')}
        <div id="repPivotTabla" class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead class="bg-slate-950 text-xs uppercase text-sky-400 border-b border-slate-800">
                    <tr>${theadCols.map((h, i) => `<th class="p-3 ${alinear(i)}">${h}</th>`).join('')}</tr>
                </thead>
                <tbody>
                    ${bodyRows.map((fila) => `<tr class="border-b border-slate-900">${fila.map((v, i) => `<td class="p-3 ${alinear(i)} ${claseValor(i)}">${v}</td>`).join('')}</tr>`).join('')}
                </tbody>
                <tfoot>
                    <tr class="bg-slate-950 font-semibold">${tfootCols.map((v, i) => `<td class="p-3 ${alinear(i)} ${i === 0 ? 'text-slate-200' : 'font-mono text-emerald-300'}">${v}</td>`).join('')}</tr>
                </tfoot>
            </table>
        </div>
    `;
    wireBarraAcciones(el);
}

let pivotDatasetActual = null;
let pivotDatosActuales = [];

async function renderPivot(cont) {
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl space-y-4">
            <div class="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-7 gap-3 no-print items-end">
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Dataset</label>
                    <select id="pvDataset" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Desde</label>
                    <input type="date" id="pvDesde" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Hasta</label>
                    <input type="date" id="pvHasta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Filas</label>
                    <select id="pvFilas" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Columnas</label>
                    <select id="pvColumnas" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Valor</label>
                    <select id="pvValor" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
                </div>
                <div>
                    <label class="block text-xs text-slate-400 mb-1">Agregación</label>
                    <select id="pvAgregacion" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                        ${Object.entries(AGREGACIONES).map(([k, v]) => `<option value="${k}">${v.label}</option>`).join('')}
                    </select>
                </div>
            </div>
            <div class="no-print">
                <button id="pvGenerar" class="text-xs bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg font-semibold transition" style="cursor: pointer;">Generar</button>
            </div>
            <div id="pvResultado"><p class="text-slate-500 text-sm text-center py-8">Elige el dataset y las opciones, luego presiona Generar.</p></div>
        </div>
    `;

    const selDataset = document.getElementById('pvDataset');
    selDataset.innerHTML = PIVOT_DATASETS.map((d) => `<option value="${d.id}">${d.label}</option>`).join('');
    document.getElementById('pvDesde').value = primerDiaMesISO();
    document.getElementById('pvHasta').value = hoyISO();

    const poblarDimensionesYMedidas = () => {
        pivotDatasetActual = PIVOT_DATASETS.find((d) => d.id === selDataset.value) || null;
        const selFilas = document.getElementById('pvFilas');
        const selCols = document.getElementById('pvColumnas');
        const selValor = document.getElementById('pvValor');
        if (!pivotDatasetActual) return;
        selFilas.innerHTML = pivotDatasetActual.dimensions.map((d) => `<option value="${d.key}">${d.label}</option>`).join('');
        selCols.innerHTML = '<option value="">— ninguna —</option>' + pivotDatasetActual.dimensions.map((d) => `<option value="${d.key}">${d.label}</option>`).join('');
        selValor.innerHTML = pivotDatasetActual.measures.map((m) => `<option value="${m.key}">${m.label}</option>`).join('');
    };
    poblarDimensionesYMedidas();

    selDataset.addEventListener('change', () => {
        poblarDimensionesYMedidas();
        pivotDatosActuales = []; // fuerza a volver a consultar con el nuevo dataset
        document.getElementById('pvResultado').innerHTML = '<p class="text-slate-500 text-sm text-center py-8">Elige el dataset y las opciones, luego presiona Generar.</p>';
    });

    document.getElementById('pvGenerar').addEventListener('click', () => generarPivot(true));
    ['pvFilas', 'pvColumnas', 'pvValor', 'pvAgregacion'].forEach((id) => {
        document.getElementById(id).addEventListener('change', () => generarPivot(false));
    });
}

async function generarPivot(forzarRefetch) {
    const resultado = document.getElementById('pvResultado');
    const dataset = pivotDatasetActual;
    if (!dataset || !resultado) return;

    const desde = document.getElementById('pvDesde').value;
    const hasta = document.getElementById('pvHasta').value;
    const filaKey = document.getElementById('pvFilas').value;
    const colKey = document.getElementById('pvColumnas').value || null;
    const valorKey = document.getElementById('pvValor').value;
    const agregacion = document.getElementById('pvAgregacion').value;

    if (forzarRefetch || pivotDatosActuales.length === 0) {
        resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">Cargando...</p>';
        try {
            pivotDatosActuales = await dataset.fetch(desde, hasta);
        } catch (e) {
            resultado.innerHTML = `<p class="text-rose-400 text-sm">Error al cargar el dataset: ${e.message || e}</p>`;
            return;
        }
    }

    if (pivotDatosActuales.length === 0) {
        resultado.innerHTML = '<p class="text-slate-500 text-sm text-center py-8">No hay datos para ese periodo.</p>';
        return;
    }

    const filaDim = dataset.dimensions.find((d) => d.key === filaKey);
    const medida = dataset.measures.find((m) => m.key === valorKey);
    const pivot = construirPivot(pivotDatosActuales, { filaKey, colKey, valorKey, agregacion });
    renderTablaPivot(resultado, pivot, {
        filaLabel: filaDim?.label || filaKey,
        valorLabel: medida?.label || valorKey,
        colKey,
        formato: medida?.formato || 'numero',
    });
}

// ---------- Barra de pestañas + entrada del módulo ----------

const TABS = [
    { id: 'compras', label: 'Compras por proveedor' },
    { id: 'gastos', label: 'Gastos por cuenta' },
    { id: 'inventario', label: 'Inventario valorizado' },
    { id: 'pivot', label: 'Tabla dinámica' },
];

let tabActual = 'compras';

function renderTabs() {
    const el = document.getElementById('repTabs');
    if (!el) return;
    el.innerHTML = TABS.map((t) => `
        <button data-tab="${t.id}" class="rep-tab-btn text-xs font-semibold px-3 py-2 rounded-lg transition ${t.id === tabActual ? 'bg-sky-600 text-white' : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'}" style="cursor: pointer;">${t.label}</button>
    `).join('');
    el.querySelectorAll('.rep-tab-btn').forEach((btn) => {
        btn.addEventListener('click', () => activarTab(btn.dataset.tab));
    });
}

function activarTab(id) {
    tabActual = id;
    renderTabs();
    const cont = document.getElementById('repContenido');
    if (!cont) return;
    if (id === 'compras') renderComprasPorProveedor(cont);
    else if (id === 'gastos') renderGastosPorCuenta(cont);
    else if (id === 'inventario') renderInventarioValorizado(cont);
    else if (id === 'pivot') renderPivot(cont);
}

export async function cargarModuloReportes() {
    const contenedor = document.getElementById('view-reportes');
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div class="space-y-4">
            <div>
                <h2 class="text-xl font-bold text-sky-400">📊 Reportes</h2>
                <p class="text-xs text-slate-400 mt-1">Reportes consolidados y tabla dinámica sobre compras, gastos, inventario y movimientos.</p>
            </div>
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-1 flex flex-wrap gap-1" id="repTabs"></div>
            <div id="repContenido"></div>
        </div>
    `;

    activarTab(tabActual);
}
