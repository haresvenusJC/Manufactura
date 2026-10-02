import { supabaseClient } from './supabase.js';
import { abrirTablaUnidades, abrirTablaDensidades } from './catalogo.js';
import { REGIMENES, cargarRegimenes } from './regimenes-fiscales.js';
import { familiaDeUnidad } from './conversion-unidades.js';

// =====================================================================
// Configuración · Tablas
//   Visor de solo lectura de las tablas de apoyo del sistema, para ver los datos que contienen.
//   Columnas dinámicas (lo que traiga la tabla en la base), con buscador.
//   Unidades de medida además ofrece abrir su editor (el mismo de Catálogo y Kardex → "📏 Unidades").
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const TABLAS = {
    unidades_medida: { titulo: '📏 Unidades de medida', desc: 'Piezas, Kilogramos, Litros... "Fraccionable" indica si se puede pedir/producir en decimales.', orden: 'nombre' },
    c_uso_cfdi: { titulo: '🧾 SAT · Uso del CFDI', desc: 'Catálogo c_UsoCFDI del SAT, con la cuenta contable sugerida para cada uso (la usan Recibo de mercancía y Gastos).', orden: 'clave' },
    c_forma_pago: { titulo: '🧾 SAT · Forma de pago', desc: 'Catálogo c_FormaPago del SAT (01 Efectivo, 03 Transferencia...).', orden: 'clave' },
    c_metodo_pago: { titulo: '🧾 SAT · Método de pago', desc: 'Catálogo c_MetodoPago del SAT (PUE / PPD).', orden: 'clave' },
    regimenes: { titulo: '🧾 SAT · Regímenes fiscales', desc: '', orden: 'clave' },
    monedas: { titulo: '💱 Monedas', desc: 'Monedas disponibles en Órdenes de compra y Compra directa (MXN, USD...).', orden: 'id' },
};

const fmt = (v) => {
    if (v === null || v === undefined || v === '') return '<span class="text-slate-600">—</span>';
    if (typeof v === 'boolean') return v ? '✔ Sí' : '✕ No';
    if (typeof v === 'object') return esc(JSON.stringify(v));
    return esc(v);
};

// Conversiones: no es una tabla de la base, es la regla de js/conversion-unidades.js (familias masa/volumen)
// aplicada a las unidades que SÍ existen en `unidades_medida`. Entre familias distintas interviene la densidad.
async function cargarConversiones(cont, titulo) {
    if (titulo) titulo.textContent = '🔄 Tabla de conversiones';
    const { data, error } = await supabaseClient.from('unidades_medida').select('nombre').order('nombre');
    if (error) { cont.innerHTML = `<p class="text-sm text-rose-400">No se pudo leer unidades_medida: ${esc(error.message)}</p>`; return; }
    const fam = {};
    const sin = [];
    (data || []).forEach((u) => {
        const f = familiaDeUnidad(u.nombre);
        if (f) (fam[f.familia] = fam[f.familia] || []).push({ nombre: u.nombre, aBase: f.aBase });
        else sin.push(u.nombre);
    });
    const num = (v) => v.toLocaleString('es-MX', { maximumFractionDigits: 6 });
    const base = { masa: 'gramo', volumen: 'mililitro' };
    // Una tarjeta por unidad ("1 Kilogramos = 1,000 Gramos · 1,000,000 Miligramos"): se lee bien en celular, sin tabla ancha.
    const bloque = (nombre, lista) => {
        lista.sort((a, b) => a.aBase - b.aBase);
        return `
        <h3 class="text-sm font-semibold text-slate-200 mt-4 mb-2">${nombre === 'masa' ? '⚖️ Masa' : '🧪 Volumen'} <span class="text-[11px] font-normal text-slate-500">(base: ${base[nombre]})</span></h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">${lista.map((r) => `
            <div class="bg-slate-950 border border-slate-800 rounded-lg p-3">
                <div class="text-sm font-semibold text-slate-100 mb-1">1 ${esc(r.nombre)}</div>
                <ul class="text-xs text-slate-300 space-y-0.5">${lista.filter((c) => c !== r).map((c) => `<li>= <span class="font-mono text-sky-300">${num(r.aBase / c.aBase)}</span> ${esc(c.nombre)}</li>`).join('')}</ul>
            </div>`).join('')}
        </div>`;
    };
    cont.innerHTML = `
        <p class="text-xs text-slate-400">Así convierte el sistema las fórmulas (BOM) a la unidad de inventario. Dentro de la misma familia es exacto; entre masa y volumen usa la <strong>densidad</strong> del artículo (kg/L). Solo ve la regla del sistema, no se edita aquí.</p>
        <div class="flex flex-wrap gap-2 mt-3"><button type="button" id="tablasDens" class="text-xs bg-slate-800 hover:bg-slate-700 text-indigo-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">⚖️ Ver / editar densidades</button></div>
        ${Object.keys(fam).map((k) => bloque(k, fam[k])).join('')}
        <h3 class="text-sm font-semibold text-slate-200 mt-4 mb-1">Sin conversión automática</h3>
        <p class="text-xs text-slate-400">${sin.length ? sin.map(esc).join(', ') : '—'} — se comparan 1 a 1 (solo con la misma unidad). Si compras en una y surtes en otra, captura el factor en la clave del proveedor.</p>`;
    cont.querySelector('#tablasDens')?.addEventListener('click', abrirTablaDensidades);
}

// Regímenes fiscales: único catálogo de esta pantalla que se EDITA aquí (c_regimen_fiscal).
// Descripción y "activo" se guardan al cambiar; la clave no se edita (es la llave). Retirar ≠ borrar.
async function cargarEditorRegimenes(cont, titulo) {
    if (titulo) titulo.textContent = TABLAS.regimenes.titulo;
    const { data, error } = await supabaseClient.from('c_regimen_fiscal').select('clave, descripcion, activo').order('clave');
    if (error) {
        cont.innerHTML = `<div class="text-xs text-amber-300 bg-amber-950/30 border border-amber-800 rounded-lg p-3 mb-3">Para ver y editar este catálogo corre primero <code>sql/2026-10-30_c_regimen_fiscal.sql</code> en Supabase (${esc(error.message)}). Mientras tanto los formularios usan esta lista de respaldo:</div>
            <ul class="text-sm text-slate-300 space-y-0.5">${REGIMENES.map(([k, v]) => `<li><span class="font-mono text-slate-400">${esc(k)}</span> · ${esc(v)}</li>`).join('')}</ul>`;
        return;
    }
    const filas = data || [];
    cont.innerHTML = `
        <p class="text-xs text-slate-400 mb-3">Catálogo c_RegimenFiscal del SAT que usan Proveedores, Clientes y las altas rápidas desde el XML. Los cambios se guardan solos. <strong>Retirar</strong> un régimen (desmarcar "Activo") deja de ofrecerlo en los formularios sin borrarlo ni afectar a quien ya lo tenga.</p>
        <div class="flex flex-wrap gap-2 items-end bg-slate-950/60 border border-slate-800 rounded-lg p-2 mb-3">
            <div><label class="block text-[10px] text-slate-400 mb-0.5">Clave (3 dígitos)</label><input id="regNuevaClave" maxlength="3" inputmode="numeric" placeholder="609" class="w-20 bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 font-mono"></div>
            <div class="flex-1 min-w-[12rem]"><label class="block text-[10px] text-slate-400 mb-0.5">Descripción</label><input id="regNuevaDesc" placeholder="Consolidación" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
            <button type="button" id="regAgregar" class="text-xs bg-sky-600 hover:bg-sky-500 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">＋ Agregar</button>
        </div>
        <p id="regMsg" class="text-[11px] min-h-[1rem] mb-2"></p>
        <div class="overflow-x-auto border border-slate-800 rounded-lg"><table class="w-full text-sm text-left">
            <thead class="bg-slate-950 text-[11px] uppercase text-slate-400"><tr><th class="px-3 py-2">Clave</th><th class="px-3 py-2">Descripción</th><th class="px-3 py-2">Activo</th></tr></thead>
            <tbody class="divide-y divide-slate-800 text-slate-200">${filas.map((r) => `
                <tr data-clave="${esc(r.clave)}"><td class="px-3 py-1.5 font-mono text-slate-400">${esc(r.clave)}</td>
                <td class="px-3 py-1.5"><input data-campo="descripcion" value="${esc(r.descripcion)}" class="w-full bg-slate-950 border border-slate-800 rounded p-1 text-xs text-slate-100"></td>
                <td class="px-3 py-1.5"><input data-campo="activo" type="checkbox" class="accent-sky-500" ${r.activo !== false ? 'checked' : ''}></td></tr>`).join('')}
            </tbody></table></div>`;

    const msg = cont.querySelector('#regMsg');
    const aviso = (t, ok) => { msg.textContent = t; msg.className = `text-[11px] min-h-[1rem] mb-2 ${ok ? 'text-emerald-400' : 'text-rose-400'}`; };
    cont.querySelectorAll('tbody tr').forEach((tr) => {
        tr.querySelectorAll('[data-campo]').forEach((el) => el.addEventListener('change', async () => {
            const clave = tr.dataset.clave;
            const descripcion = tr.querySelector('[data-campo="descripcion"]').value.trim();
            if (!descripcion) { aviso('La descripción no puede quedar vacía.', false); return; }
            const activo = tr.querySelector('[data-campo="activo"]').checked;
            const { error: e } = await supabaseClient.from('c_regimen_fiscal').update({ descripcion, activo }).eq('clave', clave);
            if (e) { aviso(`No se guardó ${clave}: ${e.message}`, false); return; }
            await cargarRegimenes();
            aviso(`✔ ${clave} guardado.`, true);
        }));
    });
    cont.querySelector('#regAgregar').addEventListener('click', async () => {
        const clave = cont.querySelector('#regNuevaClave').value.trim();
        const descripcion = cont.querySelector('#regNuevaDesc').value.trim();
        if (!/^\d{3}$/.test(clave)) { aviso('La clave del SAT son 3 dígitos (ej. 609).', false); return; }
        if (!descripcion) { aviso('Escribe la descripción.', false); return; }
        if (filas.some((r) => r.clave === clave)) { aviso(`La clave ${clave} ya existe.`, false); return; }
        const { error: e } = await supabaseClient.from('c_regimen_fiscal').insert({ clave, descripcion, activo: true });
        if (e) { aviso(`No se agregó: ${e.message}`, false); return; }
        await cargarRegimenes();
        await cargarEditorRegimenes(cont, titulo);
    });
}

export async function cargarModuloTablas(tabla = 'unidades_medida') {
    const cont = document.getElementById('contenedorTablas');
    if (!cont) return;
    if (tabla === 'densidades') {
        const t = document.getElementById('tituloTablas'); if (t) t.textContent = '⚖️ Densidades';
        cont.innerHTML = '<p class="text-xs text-slate-400 mb-3">Kilogramos que pesa 1 litro de cada insumo — para convertir fórmulas en volumen contra inventario en peso. Se ve y edita en la subventana.</p><button type="button" id="tablasDens2" class="text-xs bg-slate-800 hover:bg-slate-700 text-amber-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">⚖️ Abrir tabla de densidades</button>';
        cont.querySelector('#tablasDens2').addEventListener('click', abrirTablaDensidades);
        abrirTablaDensidades();
        return;
    }
    if (tabla === 'regimenes') return cargarEditorRegimenes(cont, document.getElementById('tituloTablas'));
    if (tabla === 'conversiones') {
        cont.innerHTML = '<p class="text-sm text-slate-400">Cargando…</p>';
        return cargarConversiones(cont, document.getElementById('tituloTablas'));
    }
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
