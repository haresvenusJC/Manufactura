import { supabaseClient } from './supabase.js';
import { abrirTablaUnidades } from './catalogo.js';

// =====================================================================
// Configuración · Tablas
//   Visor de solo lectura de las tablas de apoyo del sistema, para ver los datos que contienen.
//   Columnas dinámicas (lo que traiga la tabla en la base), con buscador.
//   Unidades de medida además ofrece abrir su editor (el mismo de Catálogo y Kardex → "📏 Unidades").
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const TABLAS = {
    unidades_medida: { titulo: '📏 Unidades de medida', desc: 'Piezas, Kilogramos, Litros... "Fraccionable" indica si se puede pedir/producir en decimales.', orden: 'nombre' },
    monedas: { titulo: '💱 Monedas', desc: 'Monedas disponibles en Órdenes de compra y Compra directa (MXN, USD...).', orden: 'id' },
};

const fmt = (v) => {
    if (v === null || v === undefined || v === '') return '<span class="text-slate-600">—</span>';
    if (typeof v === 'boolean') return v ? '✔ Sí' : '✕ No';
    if (typeof v === 'object') return esc(JSON.stringify(v));
    return esc(v);
};

export async function cargarModuloTablas(tabla = 'unidades_medida') {
    const cont = document.getElementById('contenedorTablas');
    if (!cont) return;
    const cfg = TABLAS[tabla] || TABLAS.unidades_medida;
    const nombre = TABLAS[tabla] ? tabla : 'unidades_medida';

    const titulo = document.getElementById('tituloTablas');
    if (titulo) titulo.textContent = cfg.titulo;
    cont.innerHTML = '<p class="text-sm text-slate-400">Cargando…</p>';

    const { data, error } = await supabaseClient.from(nombre).select('*').order(cfg.orden, { ascending: true });
    if (error) {
        cont.innerHTML = `<p class="text-sm text-rose-400">No se pudo leer la tabla <code>${esc(nombre)}</code>: ${esc(error.message)}</p>`;
        return;
    }
    const filas = data || [];
    const cols = filas.length ? Object.keys(filas[0]) : [];

    cont.innerHTML = `
        <p class="text-xs text-slate-400 mb-3">${esc(cfg.desc)}</p>
        <div class="flex flex-wrap gap-2 items-center mb-3">
            <input type="text" id="tablasBuscar" placeholder="🔍 Buscar…" class="flex-1 min-w-[12rem] bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            ${nombre === 'unidades_medida' ? '<button type="button" id="tablasEditarUnid" class="text-xs bg-slate-800 hover:bg-slate-700 text-indigo-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">✏️ Editar / agregar unidades</button>' : ''}
            <span id="tablasConteo" class="text-[11px] text-slate-500"></span>
        </div>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
            <table class="w-full text-sm text-left">
                <thead class="bg-slate-950 text-[11px] uppercase text-slate-400"><tr>${cols.map((c) => `<th class="px-3 py-2 whitespace-nowrap">${esc(c)}</th>`).join('')}</tr></thead>
                <tbody id="tablasCuerpo" class="divide-y divide-slate-800 text-slate-200"></tbody>
            </table>
        </div>`;

    const cuerpo = cont.querySelector('#tablasCuerpo');
    const conteo = cont.querySelector('#tablasConteo');
    const pintar = () => {
        const q = (cont.querySelector('#tablasBuscar').value || '').trim().toLowerCase();
        const vis = q ? filas.filter((f) => cols.some((c) => String(f[c] ?? '').toLowerCase().includes(q))) : filas;
        cuerpo.innerHTML = vis.length
            ? vis.map((f) => `<tr class="hover:bg-slate-800/40">${cols.map((c) => `<td class="px-3 py-1.5">${fmt(f[c])}</td>`).join('')}</tr>`).join('')
            : `<tr><td colspan="${Math.max(cols.length, 1)}" class="px-3 py-4 text-center text-slate-500">Sin registros.</td></tr>`;
        conteo.textContent = `${vis.length} de ${filas.length}`;
    };
    cont.querySelector('#tablasBuscar').addEventListener('input', pintar);
    cont.querySelector('#tablasEditarUnid')?.addEventListener('click', abrirTablaUnidades);
    pintar();
}
