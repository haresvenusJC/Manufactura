// =====================================================================
//  Estado vacío estándar: cuando una lista no tiene registros ("Sin pedidos…",
//  "No hay pagos con esos filtros.", "Sin devoluciones de cliente registradas.")
//  se muestra la ilustración de documentos arriba y el MISMO mensaje debajo.
//  Un solo lugar, sin tocar cada módulo: un MutationObserver detecta esos
//  avisos cuando aparecen en pantalla (también dentro de subventanas) y les
//  antepone la ilustración (hoja trasera con el color de acento del tema).
//
//  Qué cuenta como "aviso de lista vacía": un elemento sin hijos (p / td / div)
//  con texto que empieza por "Sin ", "No hay " o "No se encontr…", en gris
//  (text-slate-500), que NO sea una pista chica (text-xs / text-[11px]) ni
//  cursiva, ni de partidas de un formulario. Para excluir uno puntual:
//  data-sin-ilustracion.
// =====================================================================
const SVG_VACIO = `
<svg viewBox="0 0 120 130" width="92" height="100" aria-hidden="true" focusable="false" style="display:block;margin:0 auto;filter:drop-shadow(0 6px 8px rgba(0,0,0,.28))">
  <path d="M42 22H90L114 46V114a8 8 0 0 1-8 8H42a8 8 0 0 1-8-8V30a8 8 0 0 1 8-8Z" style="fill:var(--acc,#38bdf8)"/>
  <path d="M90 22V38a8 8 0 0 0 8 8H114Z" style="fill:color-mix(in srgb, var(--acc,#38bdf8) 55%, #000)"/>
  <path d="M26 10H70L94 34V102a8 8 0 0 1-8 8H26a8 8 0 0 1-8-8V18a8 8 0 0 1 8-8Z" fill="#fbfbfb"/>
  <path d="M70 10V26a8 8 0 0 0 8 8H94Z" fill="#dfe3ea"/>
  <rect x="30" y="52" width="46" height="5" rx="2.5" fill="#e3e7ee"/>
  <rect x="30" y="64" width="38" height="5" rx="2.5" fill="#e3e7ee"/>
  <rect x="30" y="76" width="42" height="5" rx="2.5" fill="#e3e7ee"/>
</svg>`;

const ES_AVISO = /^(Sin |No hay |No se encontr)/i;
const NO_APLICA_TEXTO = /partidas|^Sin resultados|^Sin cargar|^Sin avisos|^Sin datos para previsualizar/i;
const NO_APLICA_CLASE = /(?:^|\s)(italic|text-xs|text-\[1[01]px\]|text-rose-\d+|text-emerald-\d+|text-amber-\d+)(?:\s|$)/;

function esAvisoDeListaVacia(el) {
    if (!el || el.nodeType !== 1 || el.dataset.ev || 'sinIlustracion' in el.dataset) return false;
    if (!['P', 'TD', 'DIV'].includes(el.tagName) || el.children.length) return false;
    const texto = (el.textContent || '').trim();
    if (!texto || texto.length > 150 || !ES_AVISO.test(texto) || NO_APLICA_TEXTO.test(texto)) return false;
    const clase = el.className && el.className.baseVal === undefined ? String(el.className) : '';
    if (!/text-slate-[56]00/.test(clase) || NO_APLICA_CLASE.test(clase)) return false;
    // Listas desplegables de sugerencias y menús: no son "listas vacías".
    if (el.closest('.absolute, [class*="max-h-"], [role="listbox"]')) return false;
    return true;
}

function ilustrar(el) {
    const texto = el.textContent.trim();
    el.dataset.ev = '1';
    el.classList.remove('text-left');
    el.classList.add('text-center');
    if (el.tagName === 'TD') { el.style.paddingTop = '2.5rem'; el.style.paddingBottom = '2.5rem'; }
    el.innerHTML = `${SVG_VACIO}<span style="display:block;margin-top:.75rem">${texto.replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]))}</span>`;
}

function recorrer(nodo) {
    if (!(nodo instanceof Element)) return;
    if (esAvisoDeListaVacia(nodo)) ilustrar(nodo);
    nodo.querySelectorAll?.('p, td, div').forEach((el) => { if (esAvisoDeListaVacia(el)) ilustrar(el); });
}

if (typeof document !== 'undefined' && !window.__estadoVacio) {
    window.__estadoVacio = true;
    new MutationObserver((muts) => { for (const m of muts) m.addedNodes.forEach(recorrer); })
        .observe(document.body, { childList: true, subtree: true });
    recorrer(document.body);
}
