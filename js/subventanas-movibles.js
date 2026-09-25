// =====================================================================
//  Subventanas movibles y redimensionables — un solo mecanismo para
//  TODAS las subventanas (convención de CLAUDE.md):
//   - se arrastran desde su barra de título, con mouse o con el dedo.
//   - se estiran desde una manija en la esquina inferior derecha.
//   - un botón ⤢ en la barra de título las maximiza (casi pantalla
//     completa) y las restaura a su tamaño original.
//   - Ctrl/Cmd + clic en el enlace/botón que la abre: abre una instancia
//     aparte en vez de reusar/reemplazar la que ya esté abierta
//     (window.idSubventana, ver abajo).
//
//  No hay que llamar nada desde cada módulo: un MutationObserver detecta
//  las subventanas en cuanto entran al DOM (o cambia su contenido):
//   - con fondo:   div.fixed.inset-0 → su primer hijo es el panel.
//   - flotantes:   div.fixed.rounded-2xl (sin fondo) → él mismo es el panel.
//  La barra de título (para arrastrar) = primer hijo del panel (saltando
//  envoltorios de un solo hijo). El botón de maximizar se busca aparte,
//  por ".flex.justify-between" (la fila de título en casi todas), porque
//  esa barra de título puede terminar siendo solo el texto del título.
//  Se mueve/estira con las propiedades CSS `translate` / `width` / `height`
//  (se suman al `transform` que algunas ya usan para centrarse) y nunca
//  se sale del todo de la pantalla. Para excluir una: data-no-movible.
// =====================================================================

const NO_MOVIBLES = new Set(['loginOverlay', 'sidebarBackdrop']);
const INTERACTIVOS = 'button, a, input, select, textarea, label, iframe, [contenteditable], [data-no-arrastre]';
const MARGEN = 60; // px del panel que siempre quedan a la vista al arrastrar
const MARGEN_MAX = 16; // px de aire alrededor al maximizar
const MIN_ANCHO = 260, MIN_ALTO = 160; // px mínimos al estirar desde la esquina

// ---- Ctrl/Cmd + clic = "ábrela aparte" (no reusar/reemplazar la ya abierta) ----
// Un solo listener global en captura: corre ANTES que el onclick del enlace/botón
// que de verdad abre la subventana, así el estado de Ctrl ya está listo cuando
// ese código llama a window.idSubventana().
let __ctrlAlClic = false;
document.addEventListener('click', (e) => { __ctrlAlClic = !!(e.ctrlKey || e.metaKey); }, true);

// idBase: el id "de siempre" de esa subventana (ej. 'modalResumenProducto').
// Sin Ctrl: regresa el mismo id de siempre (se reusa/reemplaza, como hasta ahora).
// Con Ctrl: regresa un id nuevo único, para que la ya abierta se quede intacta y
// esta se abra como una instancia independiente (nunca se sale con el resto).
window.idSubventana = function (idBase) {
    if (!__ctrlAlClic) return idBase;
    return `${idBase}__${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
};

function panelDe(el) {
    if (!(el instanceof HTMLElement) || !el.classList.contains('fixed')) return null;
    if (NO_MOVIBLES.has(el.id) || el.hasAttribute('data-no-movible')) return null;
    if (el.classList.contains('inset-0')) return el.firstElementChild;
    if (el.classList.contains('rounded-2xl')) return el;
    return null;
}

// ---- Tamaño: capturar el original (una sola vez) y aplicar uno nuevo ----
// panel -> { base: {width,maxWidth,height,maxHeight,translate,top,left,transform}, maximizada }
const estadoPanel = new WeakMap();
const PROPS_TAMANO = ['width', 'maxWidth', 'height', 'maxHeight', 'translate', 'top', 'left', 'transform'];

function baselineDe(panel) {
    let e = estadoPanel.get(panel);
    if (!e) {
        const s = panel.style;
        const base = {};
        PROPS_TAMANO.forEach((p) => { base[p] = s[p]; });
        e = { base, maximizada: false };
        estadoPanel.set(panel, e);
    }
    return e;
}

function aplicarTamano(panel, v) {
    PROPS_TAMANO.forEach((p) => { panel.style[p] = v[p] ?? ''; });
}

function alternarMaximizado(panel, boton) {
    const e = baselineDe(panel);
    if (e.maximizada) {
        aplicarTamano(panel, e.base);
        e.maximizada = false;
    } else {
        // top/left/transform en 0 también: algunas subventanas flotantes se
        // posicionan solas (ej. "top: 8vh; left: 50%; transform: translateX(-50%)")
        // y con eso más alto/ancho se saldrían de la pantalla si no se reubican.
        aplicarTamano(panel, {
            width: `${Math.max(MIN_ANCHO, window.innerWidth - MARGEN_MAX * 2)}px`, maxWidth: 'none',
            height: `${Math.max(MIN_ALTO, window.innerHeight - MARGEN_MAX * 2)}px`, maxHeight: 'none',
            translate: '0px 0px', top: `${MARGEN_MAX}px`, left: `${MARGEN_MAX}px`, transform: 'none',
        });
        e.maximizada = true;
    }
    boton.textContent = e.maximizada ? '⤡' : '⤢';
    boton.title = e.maximizada ? 'Restaurar tamaño' : 'Maximizar';
}

// Fila de título real (para el botón de maximizar): casi todas usan
// "flex justify-between" en su barra de título — más confiable que el
// "asa" de abajo, que a veces termina siendo solo el texto del título.
function filaTitulo(panel, asa) {
    return panel.querySelector(':scope > .flex.justify-between, :scope .flex.justify-between') || asa || panel;
}

function agregarBotonMaximizar(panel, asa) {
    if (panel.querySelector('[data-subventana-maximizar]')) return;
    const fila = filaTitulo(panel, asa);
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.setAttribute('data-subventana-maximizar', '');
    btn.setAttribute('data-no-arrastre', '');
    btn.title = 'Maximizar';
    btn.textContent = '⤢';
    btn.className = 'text-slate-400 hover:text-slate-200 text-sm font-bold px-1.5 shrink-0';
    btn.addEventListener('click', (e) => { e.stopPropagation(); alternarMaximizado(panel, btn); });
    if (fila.children.length) fila.insertBefore(btn, fila.lastElementChild);
    else fila.appendChild(btn);
}

// Manija en la esquina inferior derecha para estirar el panel a mano.
function agregarManijaResize(panel) {
    if (panel.querySelector(':scope > [data-subventana-resize]')) return;
    const asa = document.createElement('div');
    asa.setAttribute('data-subventana-resize', '');
    asa.title = 'Arrastra para cambiar el tamaño';
    asa.style.cssText = 'position:absolute;right:0;bottom:0;width:18px;height:18px;cursor:nwse-resize;'
        + 'background:linear-gradient(135deg,transparent 0 50%,currentColor 50% 62%,transparent 62% 74%,currentColor 74% 86%,transparent 86%);'
        + 'color:#64748b;opacity:.6;touch-action:none;';
    panel.appendChild(asa);
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
    agregarBotonMaximizar(panel, asa);
    agregarManijaResize(panel);
}

function revisar(nodo) {
    if (!(nodo instanceof HTMLElement)) return;
    prepararPanel(panelDe(nodo));
    // El contenedor ya existía y solo le cambiaron el contenido (innerHTML).
    const padre = nodo.parentElement;
    if (padre) prepararPanel(panelDe(padre));
    nodo.querySelectorAll('.fixed').forEach((el) => prepararPanel(panelDe(el)));
}

// ---- Arrastre para mover (delegado: un solo listener para todas) ----
let arrastre = null;
// ---- Arrastre para estirar desde la esquina ----
let redimension = null;

function alPresionar(e) {
    if (e.button !== undefined && e.button !== 0) return;

    const manija = e.target.closest?.('[data-subventana-resize]');
    if (manija) {
        const panel = manija.parentElement;
        if (!panel) return;
        baselineDe(panel); // asegura que el tamaño original quede guardado antes de tocarlo
        const est = estadoPanel.get(panel);
        if (est) est.maximizada = false; // un estirón a mano ya no es "maximizada"
        const r = panel.getBoundingClientRect();
        redimension = { panel, id: e.pointerId, x0: e.clientX, y0: e.clientY, w0: r.width, h0: r.height, left: r.left, top: r.top };
        try { manija.setPointerCapture(e.pointerId); } catch (_) { /* sin captura también funciona */ }
        e.preventDefault();
        return;
    }

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
    if (redimension && e.pointerId === redimension.id) {
        const { panel, x0, y0, w0, h0, left, top } = redimension;
        e.preventDefault();
        const anchoMax = Math.max(MIN_ANCHO, window.innerWidth - left - 8);
        const altoMax = Math.max(MIN_ALTO, window.innerHeight - top - 8);
        const w = Math.min(anchoMax, Math.max(MIN_ANCHO, w0 + (e.clientX - x0)));
        const h = Math.min(altoMax, Math.max(MIN_ALTO, h0 + (e.clientY - y0)));
        panel.style.width = `${w}px`;
        panel.style.maxWidth = 'none';
        panel.style.height = `${h}px`;
        panel.style.maxHeight = 'none';
        return;
    }

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

function tragarClicTrasArrastre() {
    // El "click" que sigue a un arrastre podría caer en el fondo y cerrar la subventana.
    const tragar = (ev) => { ev.stopPropagation(); ev.preventDefault(); };
    window.addEventListener('click', tragar, { capture: true, once: true });
    setTimeout(() => window.removeEventListener('click', tragar, { capture: true }), 0);
}

function alSoltar(e) {
    if (redimension && e.pointerId === redimension.id) {
        redimension = null;
        tragarClicTrasArrastre();
        return;
    }
    if (!arrastre || e.pointerId !== arrastre.id) return;
    const movido = arrastre.movido;
    arrastre = null;
    if (!movido) return;
    tragarClicTrasArrastre();
}

function iniciar() {
    if (window.__subventanasMovibles) return;
    window.__subventanasMovibles = true;
    const estilo = document.createElement('style');
    estilo.textContent = `
        [data-subventana-asa] { cursor: move; touch-action: none; user-select: none; -webkit-user-select: none; }
        [data-subventana-asa] :is(${INTERACTIVOS}) { cursor: auto; }
        [data-subventana-resize]:hover { opacity: .95 !important; }
        @media print { [data-subventana] { translate: none !important; } [data-subventana-resize] { display: none !important; } }`;
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
