// Enlaces reutilizables para la regla de CLAUDE.md "documentos y pólizas citados en un reporte
// SIEMPRE se pueden abrir desde ahí": abren su detalle en subventana sin salir de la pantalla.
// documento -> window.abrirDetalleDocumentoGlobal (js/documentos.js)
// póliza    -> window.rcVerPoliza (js/contabilidad.js), vía window.verPolizaDeDocumento
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// Folio de documento como enlace. `clase` = clases de color/tipografía del texto original.
export const linkDoc = (id, texto, clase = 'font-mono text-sky-300') => id
    ? `<button type="button" onclick="const z=window.zSubventanaSiguiente(); window.abrirDetalleDocumentoGlobal(${Number(id)}); const m=document.getElementById('modalDetalleDocKardex'); if(m){m.style.zIndex=z;m.classList.remove('hidden');}" class="${clase} hover:underline cursor-pointer text-left" title="Abrir el documento">${esc(texto)}</button>`
    : esc(texto);

// Número de póliza como enlace (#123).
export const linkPoliza = (id, clase = 'font-mono text-sky-300') => id
    ? `<button type="button" onclick="window.verPolizaDeDocumento(${Number(id)})" data-pol-id="${Number(id)}" class="${clase} hover:underline cursor-pointer" title="Abrir la póliza">póliza…</button>`
    : '—';

// Etiqueta "Egreso #34" en vez del id interno: todo elemento con data-pol-id="<id>" se rotula solo
// (tipo + número de la póliza), sin que cada pantalla tenga que consultarlo. Se consultan en lote y se
// guardan en caché; mientras llega la respuesta se ve "póliza…" (si no se encuentra, "ver póliza").
const cachePol = new Map();
let pendiente = null;
function rotular(el) {
    const p = cachePol.get(Number(el.dataset.polId));
    el.textContent = p ? `${p.tipo} #${p.numero}` : 'ver póliza';
    el.dataset.polLbl = '1';
}
async function rotularPolizas() {
    pendiente = null;
    const els = [...document.querySelectorAll('[data-pol-id]:not([data-pol-lbl])')];
    if (!els.length) return;
    const faltan = [...new Set(els.map((e) => Number(e.dataset.polId)).filter((id) => id && !cachePol.has(id)))];
    if (faltan.length) {
        try {
            const { supabaseClient } = await import('./supabase.js');
            const { data } = await supabaseClient.from('polizas').select('id, tipo, numero').in('id', faltan);
            (data || []).forEach((p) => cachePol.set(p.id, p));
        } catch (_) { /* si falla se queda el #id */ }
    }
    els.forEach(rotular);
}
if (typeof document !== 'undefined' && !window.__rotuladorPolizas) {
    window.__rotuladorPolizas = true;
    new MutationObserver(() => { if (!pendiente) pendiente = setTimeout(rotularPolizas, 50); })
        .observe(document.documentElement, { childList: true, subtree: true });
}
