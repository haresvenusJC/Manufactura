import { supabaseClient } from './supabase.js';

// =====================================================================
//  Clave SAT de productos y servicios (c_ClaveProdServ): buscador con
//  sugerencias y descripción de la clave, sobre la tabla c_clave_prod_serv
//  (sql/2026-10-23_c_clave_prod_serv.sql, cargada desde Utilerías).
//  Uso: montarBuscadorClaveSat({ input, caja, nota })
//   - `input`: donde se escribe (clave de 8 dígitos o palabras); `caja`: <div> para la lista
//     (su padre con position: relative); `nota`: <p> donde se muestra la descripción de la clave.
//   - Desde 2 letras (o 3 dígitos) trae hasta 15 coincidencias; ↑/↓ + Enter o clic eligen; Esc cierra.
//   - Al elegir, el input queda con la clave y la nota con su descripción.
//   - Devuelve { mostrarNota() } para refrescar la nota cuando el código cambia el valor.
//   - Sin la tabla o sin catálogo cargado no estorba: el campo sigue siendo texto libre de 8 dígitos.
// =====================================================================

const esc = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
// Las comas y paréntesis rompen la sintaxis de .or() de PostgREST.
const limpiar = (t) => String(t || '').replace(/[,()%*\\]/g, ' ').trim();

const cacheClave = new Map();   // clave -> { descripcion } | null (no está) | undefined (no se pudo consultar)

export async function descripcionClaveSat(clave) {
    const k = String(clave || '').trim();
    if (!/^\d{8}$/.test(k)) return undefined;
    if (cacheClave.has(k)) return cacheClave.get(k);
    const { data, error } = await supabaseClient.from('c_clave_prod_serv').select('clave, descripcion, fecha_fin').eq('clave', k).maybeSingle();
    const r = error ? undefined : (data || null);
    if (!error) cacheClave.set(k, r);
    return r;
}

export function montarBuscadorClaveSat({ input, caja, nota }) {
    if (!input || !caja) return null;
    let temporizador = null, secuencia = 0, items = [], activo = -1;

    const cerrar = () => { caja.classList.add('hidden'); caja.innerHTML = ''; items = []; activo = -1; };
    const marcar = () => caja.querySelectorAll('[data-i]').forEach((el) => el.classList.toggle('bg-slate-800', Number(el.dataset.i) === activo));

    const mostrarNota = async () => {
        if (!nota) return;
        const v = input.value.trim();
        if (!v) { nota.textContent = ''; return; }
        if (!/^\d{8}$/.test(v)) { nota.className = 'text-[10px] text-slate-500 mt-0.5'; nota.textContent = 'Escribe palabras para buscar, o los 8 dígitos de la clave.'; return; }
        const r = await descripcionClaveSat(v);
        if (input.value.trim() !== v) return;   // cambió mientras consultaba
        if (r === undefined) { nota.textContent = ''; return; }
        if (r === null) { nota.className = 'text-[10px] text-amber-400 mt-0.5'; nota.textContent = '⚠ Esa clave no está en el catálogo del SAT cargado. Revísala o busca por palabras.'; return; }
        nota.className = 'text-[10px] text-emerald-400 mt-0.5';
        nota.textContent = `✔ ${r.descripcion}${r.fecha_fin ? ' (vigencia terminada)' : ''}`;
    };

    const elegir = (c) => { cerrar(); input.value = c.clave; cacheClave.set(c.clave, c); input.dispatchEvent(new Event('input', { bubbles: true })); mostrarNota(); };

    const pintar = (lista, texto) => {
        items = lista; activo = -1;
        caja.innerHTML = lista.length
            ? lista.map((c, i) => `
                <button type="button" data-i="${i}" class="w-full text-left px-3 py-2 hover:bg-slate-800 border-b border-slate-800 last:border-0">
                    <span class="block text-xs text-slate-100">${esc(c.descripcion)}</span>
                    <span class="block text-[10px] font-mono text-slate-500">${esc(c.clave)}</span>
                </button>`).join('')
            : `<p class="px-3 py-2 text-xs text-slate-500">Sin claves que coincidan con "${esc(texto)}".</p>`;
        caja.classList.remove('hidden');
    };

    const buscar = async (texto) => {
        const mia = ++secuencia;
        const t = limpiar(texto);
        // Varias palabras en cualquier orden: cada una debe aparecer en la descripción o en las palabras similares.
        let q = supabaseClient.from('c_clave_prod_serv').select('clave, descripcion, fecha_fin').order('clave').limit(15);
        if (/^\d+$/.test(t)) {
            q = q.like('clave', `${t}%`);
        } else {
            for (const p of t.split(/\s+/).filter(Boolean)) q = q.or(`descripcion.ilike.%${p}%,palabras_similares.ilike.%${p}%`);
        }
        const { data, error } = await q;
        if (mia !== secuencia) return;
        if (error) { cerrar(); return; }   // sin tabla: el campo sigue como texto libre
        pintar(data || [], texto);
    };

    input.addEventListener('input', () => {
        clearTimeout(temporizador);
        const v = input.value.trim();
        mostrarNota();
        if (/^\d{8}$/.test(v) || (/^\d+$/.test(v) ? v.length < 3 : v.length < 2)) { secuencia++; cerrar(); return; }
        temporizador = setTimeout(() => buscar(v), 250);
    });
    input.addEventListener('keydown', (e) => {
        if (caja.classList.contains('hidden')) return;
        if (e.key === 'ArrowDown') { e.preventDefault(); activo = Math.min(items.length - 1, activo + 1); marcar(); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); activo = Math.max(0, activo - 1); marcar(); }
        else if (e.key === 'Enter' && items.length) { e.preventDefault(); elegir(items[activo >= 0 ? activo : 0]); }
        else if (e.key === 'Escape') cerrar();
    });
    caja.addEventListener('mousedown', (e) => {
        const b = e.target.closest('[data-i]');
        if (b) { e.preventDefault(); elegir(items[Number(b.dataset.i)]); }
    });
    input.addEventListener('blur', () => setTimeout(cerrar, 150));

    return { mostrarNota };
}
