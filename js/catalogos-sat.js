import { supabaseClient } from './supabase.js';

// =====================================================================
//  Catálogos SAT de unidades (c_ClaveUnidad) y de productos/servicios (c_ClaveProdServ).
//  Son grandes (2,418 y 52,513 renglones): NUNCA se bajan completos. Cada búsqueda llama a
//  sat_buscar_unidad() / sat_buscar_prod_serv() (sql/2026-10-23_catalogos_sat_estructura.sql),
//  que devuelven máximo 20 renglones con índice, sin acentos y con las palabras en cualquier orden.
//  Las claves que ya usas salen primero.
//
//  montarBuscadorClaveSat({ tipo, input, caja, alElegir, detalle })
//    tipo: 'prod_serv' | 'unidad'. `caja`: <div> (el padre del input debe ser position: relative).
//    `detalle` (opcional): <p> donde se muestra el nombre de la clave tecleada/elegida.
//  describirClaveSat(tipo, clave) → { clave, texto } o null si no está en el catálogo.
// =====================================================================

const esc = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const CFG = {
    prod_serv: { rpc: 'sat_buscar_prod_serv', tabla: 'c_clave_prod_serv', texto: 'descripcion' },
    unidad: { rpc: 'sat_buscar_unidad', tabla: 'c_clave_unidad', texto: 'nombre' },
};

const cacheDescripcion = new Map();

export async function buscarClaveSat(tipo, q, limite = 20) {
    const { data, error } = await supabaseClient.rpc(CFG[tipo].rpc, { p_q: q, p_limit: limite });
    if (error) throw error;
    return data || [];
}

export async function describirClaveSat(tipo, clave) {
    const k = String(clave || '').trim();
    if (!k) return null;
    const llave = `${tipo}:${k}`;
    if (cacheDescripcion.has(llave)) return cacheDescripcion.get(llave);
    const c = CFG[tipo];
    const { data, error } = await supabaseClient.from(c.tabla).select(`clave, ${c.texto}`).eq('clave', k).maybeSingle();
    if (error) return undefined;          // no se pudo consultar (¿falta correr el SQL?): no se afirma nada
    const r = data ? { clave: data.clave, texto: data[c.texto] } : null;
    cacheDescripcion.set(llave, r);
    return r;
}

export function montarBuscadorClaveSat({ tipo, input, caja, alElegir, detalle }) {
    if (!input || !caja || !CFG[tipo]) return;
    const cfg = CFG[tipo];
    const minimo = tipo === 'prod_serv' ? 2 : 1;
    let temporizador = null, secuencia = 0, items = [], activo = -1;

    const cerrar = () => { caja.classList.add('hidden'); caja.innerHTML = ''; items = []; activo = -1; };
    const marcar = () => caja.querySelectorAll('[data-i]').forEach((el) => el.classList.toggle('bg-slate-800', Number(el.dataset.i) === activo));
    const etiqueta = (r) => (tipo === 'prod_serv'
        ? `<span class="font-mono text-slate-300">${esc(r.clave)}</span> ${esc(r.descripcion)}`
        : `<span class="font-mono text-slate-300">${esc(r.clave)}</span> ${esc(r.nombre)}${r.simbolo ? ` <span class="text-slate-500">(${esc(r.simbolo)})</span>` : ''}`);
    const marca = (r) => [r.usada ? '★ en uso' : '', r.vigente === false ? 'fuera de vigencia' : ''].filter(Boolean).join(' · ');

    const elegir = (r) => {
        cerrar();
        input.value = r.clave;
        if (detalle) detalle.innerHTML = `<span class="text-emerald-400">✓ ${esc(r[cfg.texto])}</span>`;
        alElegir?.(r);
        input.dispatchEvent(new Event('change', { bubbles: true }));
    };
    const pintar = (lista, texto) => {
        items = lista; activo = -1;
        caja.innerHTML = lista.length
            ? lista.map((r, i) => `
                <button type="button" data-i="${i}" class="w-full text-left px-3 py-1.5 hover:bg-slate-800 border-b border-slate-800 last:border-0">
                    <span class="block text-xs text-slate-100">${etiqueta(r)}</span>
                    ${marca(r) ? `<span class="block text-[10px] text-amber-300/80">${marca(r)}</span>` : ''}
                </button>`).join('')
            : `<p class="px-3 py-2 text-xs text-slate-500">Sin coincidencias en el catálogo del SAT para "${esc(texto)}".</p>`;
        caja.classList.remove('hidden');
        caja.querySelectorAll('[data-i]').forEach((b) => b.addEventListener('mousedown', (e) => { e.preventDefault(); elegir(items[Number(b.dataset.i)]); }));
    };

    const consultar = async () => {
        const texto = input.value.trim();
        if (texto.replace(/\s+/g, '').length < minimo) { cerrar(); return; }
        const mia = ++secuencia;
        try {
            const lista = await buscarClaveSat(tipo, texto);
            if (mia !== secuencia) return;
            pintar(lista, texto);
        } catch (err) {
            if (mia !== secuencia) return;
            caja.innerHTML = `<p class="px-3 py-2 text-xs text-rose-400">No se pudo buscar: ${esc(err.message || err)}${/function|does not exist|schema cache/i.test(err.message || '') ? ' (¿falta correr sql/2026-10-23_catalogos_sat_estructura.sql?)' : ''}</p>`;
            caja.classList.remove('hidden');
        }
    };

    input.addEventListener('input', () => { clearTimeout(temporizador); temporizador = setTimeout(consultar, 200); });
    input.addEventListener('focus', () => { if (input.value.trim().length >= minimo && !items.length) consultar(); });
    input.addEventListener('keydown', (e) => {
        if (caja.classList.contains('hidden') || !items.length) return;
        if (e.key === 'ArrowDown') { e.preventDefault(); activo = Math.min(activo + 1, items.length - 1); marcar(); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); activo = Math.max(activo - 1, 0); marcar(); }
        else if (e.key === 'Enter') { e.preventDefault(); e.stopImmediatePropagation(); elegir(items[activo >= 0 ? activo : 0]); }
        else if (e.key === 'Escape') cerrar();
    }, true);
    input.addEventListener('blur', () => setTimeout(cerrar, 150));

    // Al terminar de teclear una clave completa, se muestra qué es (o se avisa que no está en el catálogo).
    if (detalle) {
        const completa = () => (tipo === 'prod_serv' ? /^\d{8}$/ : /^[A-Za-z0-9]{1,3}$/);
        const mostrar = async () => {
            const v = input.value.trim();
            if (!v) { detalle.textContent = ''; return; }
            if (!completa().test(v)) { detalle.textContent = ''; return; }
            const r = await describirClaveSat(tipo, tipo === 'unidad' ? v.toUpperCase() : v);
            if (r === undefined) { detalle.textContent = ''; return; }
            detalle.innerHTML = r
                ? `<span class="text-emerald-400">✓ ${esc(r.texto)}</span>`
                : '<span class="text-amber-300">⚠ Esta clave no está en el catálogo del SAT cargado. Revísala antes de usarla.</span>';
        };
        input.addEventListener('change', mostrar);
        input.addEventListener('blur', () => setTimeout(mostrar, 200));
        mostrar();
    }
}

// ---------------------------------------------------------------------
//  Configuración → Tablas → "SAT · Unidades" y "SAT · Productos y servicios":
//  visor con búsqueda en el servidor (no se baja el catálogo completo).
// ---------------------------------------------------------------------
export function cargarVisorSat(cont, titulo, tipo) {
    const esProd = tipo === 'prod_serv';
    if (titulo) titulo.textContent = esProd ? '🧾 SAT · Productos y servicios (ClaveProdServ)' : '🧾 SAT · Unidades (ClaveUnidad)';
    cont.innerHTML = `
        <p class="text-xs text-slate-400 mb-3">${esProd
            ? 'Catálogo c_ClaveProdServ del SAT (52,513 claves, versión 4.0). Busca por clave o por palabras en cualquier orden y sin acentos; muestra hasta 20 resultados. Las que ya usas en tus productos o en claves de proveedor salen primero (★).'
            : 'Catálogo c_ClaveUnidad del SAT (2,418 unidades, versión 2.0). Busca por clave (H87, KGM…), nombre o símbolo. Las habituales y las que ya ligaste a una unidad del ERP salen primero (★). Para ligar una unidad del ERP a su clave: Tablas → Unidades de medida → ✏️ Editar / agregar unidades.'}</p>
        <div class="flex flex-wrap gap-2 items-center mb-3">
            <input type="text" id="satBuscar" placeholder="${esProd ? '🔍 Clave o palabras (ej. envase plástico, 24121807)…' : '🔍 Clave o nombre (ej. KGM, litro, mil)…'}" class="flex-1 min-w-[12rem] bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            <span id="satConteo" class="text-[11px] text-slate-500"></span>
        </div>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
            <table class="w-full text-sm text-left">
                <thead class="bg-slate-950 text-[11px] text-slate-400"><tr>
                    <th class="px-3 py-2 whitespace-nowrap">Clave</th>
                    <th class="px-3 py-2">${esProd ? 'Descripción' : 'Nombre'}</th>
                    ${esProd ? '<th class="px-3 py-2">IVA</th><th class="px-3 py-2">IEPS</th><th class="px-3 py-2">Complemento</th>' : '<th class="px-3 py-2">Símbolo</th>'}
                    <th class="px-3 py-2">Uso</th>
                </tr></thead>
                <tbody id="satCuerpo" class="divide-y divide-slate-800 text-slate-200"></tbody>
            </table>
        </div>`;
    const cuerpo = cont.querySelector('#satCuerpo');
    const conteo = cont.querySelector('#satConteo');
    const cols = esProd ? 6 : 4;
    const vacio = (msg) => { cuerpo.innerHTML = `<tr><td colspan="${cols}" class="px-3 py-4 text-center text-slate-500">${msg}</td></tr>`; conteo.textContent = ''; };
    vacio('Escribe para buscar en el catálogo.');
    let t = null, seq = 0;
    cont.querySelector('#satBuscar').addEventListener('input', (e) => {
        clearTimeout(t);
        const q = e.target.value.trim();
        if (q.replace(/\s+/g, '').length < (esProd ? 2 : 1)) { vacio('Escribe para buscar en el catálogo.'); return; }
        t = setTimeout(async () => {
            const mia = ++seq;
            try {
                const lista = await buscarClaveSat(tipo, q, 20);
                if (mia !== seq) return;
                cuerpo.innerHTML = lista.length ? lista.map((r) => `
                    <tr class="hover:bg-slate-800/40">
                        <td class="px-3 py-1.5 font-mono whitespace-nowrap">${esc(r.clave)}</td>
                        <td class="px-3 py-1.5">${esc(esProd ? r.descripcion : r.nombre)}${r.vigente === false ? ' <span class="text-[10px] text-rose-400">fuera de vigencia</span>' : ''}</td>
                        ${esProd ? `<td class="px-3 py-1.5 text-xs text-slate-400">${esc(r.incluir_iva || '—')}</td><td class="px-3 py-1.5 text-xs text-slate-400">${esc(r.incluir_ieps || '—')}</td><td class="px-3 py-1.5 text-xs text-slate-400">${esc(r.complemento || '—')}</td>` : `<td class="px-3 py-1.5 text-xs text-slate-400">${esc(r.simbolo || '—')}</td>`}
                        <td class="px-3 py-1.5 text-xs text-amber-300">${r.usada ? '★ en uso' : (r.comun ? 'habitual' : '')}</td>
                    </tr>`).join('') : `<tr><td colspan="${cols}" class="px-3 py-4 text-center text-slate-500">Sin coincidencias.</td></tr>`;
                conteo.textContent = `${lista.length}${lista.length === 20 ? '+' : ''} resultado(s)`;
            } catch (err) {
                if (mia !== seq) return;
                vacio(`<span class="text-rose-400">No se pudo buscar: ${esc(err.message || err)}. ¿Ya corriste los SQL de sql/2026-10-23_catalogos_sat_*?</span>`);
            }
        }, 200);
    });
}
