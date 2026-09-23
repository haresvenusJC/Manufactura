// =====================================================================
//  Subventanas movibles — un solo mecanismo para TODAS las subventanas
//  (convención de CLAUDE.md): se arrastran desde su barra de título, con
//  mouse o con el dedo, para destapar la pantalla que las originó.
//
//  No hay que llamar nada desde cada módulo: un MutationObserver detecta
//  las subventanas en cuanto entran al DOM (o cambia su contenido):
//   - con fondo:   div.fixed.inset-0 → su primer hijo es el panel.
//   - flotantes:   div.fixed.rounded-2xl (sin fondo) → él mismo es el panel.
//  La barra de título = primer hijo del panel (saltando envoltorios de un solo hijo).
//  Se mueve con la propiedad CSS `translate` (se suma al `transform` que
//  algunas ya usan para centrarse) y nunca se sale del todo de la pantalla.
//  Para excluir una: atributo data-no-movible en el contenedor.
// =====================================================================

const NO_MOVIBLES = new Set(['loginOverlay', 'sidebarBackdrop']);
const INTERACTIVOS = 'button, a, input, select, textarea, label, iframe, [contenteditable], [data-no-arrastre]';
const MARGEN = 60; // px del panel que siempre quedan a la vista

function panelDe(el) {
    if (!(el instanceof HTMLElement) || !el.classList.contains('fixed')) return null;
    if (NO_MOVIBLES.has(el.id) || el.hasAttribute('data-no-movible')) return null;
    if (el.classList.contains('inset-0')) return el.firstElementChild;
    if (el.classList.contains('rounded-2xl')) return el;
    return null;
}

function prepararPanel(panel) {
    if (!panel || panel.hasAttribute('data-subventana')) return;
    panel.setAttribute('data-subventana', '');
    // Baja por envoltorios de un solo hijo; nunca el panel entero como asa
    // (en el celular impediría desplazar su contenido con el dedo).
    let asa = panel;
    for (let i = 0; i < 3 && asa.children.length === 1; i++) asa = asa.firstElementChild;
    if (asa.children.length > 1) asa = asa.firstElementChild;
    asa.setAttribute('data-subventana-asa', '');
    asa.title = asa.title || 'Arrastra para mover la ventana';
}

function revisar(nodo) {
    if (!(nodo instanceof HTMLElement)) return;
    prepararPanel(panelDe(nodo));
    // El contenedor ya existía y solo le cambiaron el contenido (innerHTML).
    const padre = nodo.parentElement;
    if (padre) prepararPanel(panelDe(padre));
    nodo.querySelectorAll('.fixed').forEach((el) => prepararPanel(panelDe(el)));
}

// ---- Arrastre (delegado: un solo listener para todas) ----
let arrastre = null;

function alPresionar(e) {
    if (e.button !== undefined && e.button !== 0) return;
    const asa = e.target.closest?.('[data-subventana-asa]');
    if (!asa || e.target.closest(INTERACTIVOS)) return;
    const panel = asa.closest('[data-subventana]');
    if (!panel) return;
    const [tx, ty] = (panel.style.translate || '0px 0px').split(' ').map((v) => parseFloat(v) || 0);
    const r = panel.getBoundingClientRect();
    arrastre = { panel, id: e.pointerId, x0: e.clientX, y0: e.clientY, tx, ty, r, movido: false };
    try { asa.setPointerCapture(e.pointerId); } catch (_) { /* sin captura también funciona */ }
}

function alMover(e) {
    if (!arrastre || e.pointerId !== arrastre.id) return;
    const { panel, x0, y0, tx, ty, r } = arrastre;
    let dx = e.clientX - x0, dy = e.clientY - y0;
    if (!arrastre.movido && Math.abs(dx) + Math.abs(dy) < 4) return;
    arrastre.movido = true;
    e.preventDefault();
    const vw = window.innerWidth, vh = window.innerHeight;
    dx = Math.min(Math.max(dx, MARGEN - r.right), vw - MARGEN - r.left);
    dy = Math.min(Math.max(dy, -r.top), vh - MARGEN - r.top);
    panel.style.translate = `${tx + dx}px ${ty + dy}px`;
}

function alSoltar(e) {
    if (!arrastre || e.pointerId !== arrastre.id) return;
    const movido = arrastre.movido;
    arrastre = null;
    if (!movido) return;
    // El "click" que sigue a un arrastre podría caer en el fondo y cerrar la subventana.
    const tragar = (ev) => { ev.stopPropagation(); ev.preventDefault(); };
    window.addEventListener('click', tragar, { capture: true, once: true });
    setTimeout(() => window.removeEventListener('click', tragar, { capture: true }), 0);
}

function iniciar() {
    if (window.__subventanasMovibles) return;
    window.__subventanasMovibles = true;
    const estilo = document.createElement('style');
    estilo.textContent = `
        [data-subventana-asa] { cursor: move; touch-action: none; user-select: none; -webkit-user-select: none; }
        [data-subventana-asa] :is(${INTERACTIVOS}) { cursor: auto; }
        @media print { [data-subventana] { translate: none !important; } }`;
    document.head.appendChild(estilo);
    document.addEventListener('pointerdown', alPresionar, true);
    document.addEventListener('pointermove', alMover, { capture: true, passive: false });
    document.addEventListener('pointerup', alSoltar, true);
    document.addEventListener('pointercancel', alSoltar, true);
    new MutationObserver((cambios) => {
        cambios.forEach((c) => c.addedNodes.forEach(revisar));
    }).observe(document.body, { childList: true, subtree: true });
    revisar(document.body);
}

if (document.body) iniciar();
else document.addEventListener('DOMContentLoaded', iniciar);
