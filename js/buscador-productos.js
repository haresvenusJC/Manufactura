import { supabaseClient } from './supabase.js';

// =====================================================================
//  Buscador de productos con sugerencias mientras se escribe (SKU o nombre).
//  Uso: montarBuscadorProductos({ input, caja, alElegir: (producto) => {...} })
//   - `input`: el <input> donde se escribe; `caja`: un <div> (position: relative en su padre) para la lista.
//   - Desde 2 letras trae hasta 10 coincidencias de `productos` (espera 250 ms; descarta respuestas viejas).
//   - Clic o ↑/↓ + Enter eligen; Esc cierra. Al elegir se llama alElegir({ id, sku, nombre, tipo }).
// =====================================================================

const esc = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
// Las comas y paréntesis rompen la sintaxis de .or() de PostgREST.
const limpiar = (t) => String(t || '').replace(/[,()%*\\]/g, ' ').trim();

export function montarBuscadorProductos({ input, caja, alElegir, limpiarAlElegir = true }) {
    if (!input || !caja) return;
    let temporizador = null, secuencia = 0, items = [], activo = -1;

    const cerrar = () => { caja.classList.add('hidden'); caja.innerHTML = ''; items = []; activo = -1; };
    const marcar = () => caja.querySelectorAll('[data-i]').forEach((el) => el.classList.toggle('bg-slate-800', Number(el.dataset.i) === activo));
    const elegir = (p) => { cerrar(); if (limpiarAlElegir) input.value = ''; alElegir(p); };
    const pintar = (lista, texto) => {
        items = lista; activo = -1;
        caja.innerHTML = lista.length
            ? lista.map((p, i) => `
                <button type="button" data-i="${i}" class="w-full text-left px-3 py-2 hover:bg-slate-800 border-b border-slate-800 last:border-0">
                    <span class="block text-xs text-slate-100">${esc(p.nombre)}</span>
                    <span class="block text-[10px] font-mono text-slate-500">${esc(p.sku || 's/sku')} · ${esc(p.tipo || '')}</span>
                </button>`).join('')
            : `<p class="px-3 py-2 text-xs text-slate-500">Sin productos que coincidan con "${esc(texto)}".</p>`;
        caja.classList.remove('hidden');
        caja.querySelectorAll('[data-i]').forEach((b) => b.addEventListener('mousedown', (e) => { e.preventDefault(); elegir(items[Number(b.dataset.i)]); }));
    };

    input.addEventListener('input', () => {
        clearTimeout(temporizador);
        const texto = limpiar(input.value);
        if (texto.length < 2) { cerrar(); return; }
        temporizador = setTimeout(async () => {
            const mia = ++secuencia;
            const { data } = await supabaseClient.from('productos').select('id, sku, nombre, tipo')
                .or(`nombre.ilike.%${texto}%,sku.ilike.%${texto}%`).order('nombre').limit(10);
            if (mia !== secuencia) return;
            pintar(data || [], texto);
        }, 250);
    });
    input.addEventListener('keydown', (e) => {
        if (caja.classList.contains('hidden') || !items.length) return;
        if (e.key === 'ArrowDown') { e.preventDefault(); activo = Math.min(activo + 1, items.length - 1); marcar(); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); activo = Math.max(activo - 1, 0); marcar(); }
        else if (e.key === 'Enter') { e.preventDefault(); e.stopImmediatePropagation(); elegir(items[activo >= 0 ? activo : 0]); }
        else if (e.key === 'Escape') cerrar();
    }, true);
    input.addEventListener('blur', () => setTimeout(cerrar, 150));
}
