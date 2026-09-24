// =====================================================================
//  Galería de íconos para los accesos rápidos de Inicio (js/bienvenida.js).
//  Íconos de línea 24x24, se pintan con stroke="currentColor" — mismo trazo
//  que los de las tarjetas originales. Agrupados por categoría para el selector.
// =====================================================================

export const ICONOS = {
    // Producción
    fabrica:  '<path d="M3 21h18"/><path d="M5 21V11l5 3v-3l5 3V5h3.5v16"/><path d="M8 18h.01M12 18h.01M15.5 18h.01"/>',
    matraz:   '<path d="M9 3h6"/><path d="M10 3v6.2L4.6 18.4A1.8 1.8 0 0 0 6.2 21h11.6a1.8 1.8 0 0 0 1.6-2.6L14 9.2V3"/><path d="M7.5 15h9"/>',
    probeta:  '<path d="M9 3h6"/><path d="M10 3v14a2 2 0 0 0 4 0V3"/><path d="M10 12h4"/>',
    gota:     '<path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z"/>',
    balanza:  '<path d="M12 4v16M7 20h10M4 8h16"/><path d="M4 8l-2.5 6h5zM20 8l-2.5 6h5z"/>',
    engrane:  '<circle cx="12" cy="12" r="4"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M19.1 4.9 17 7M7 17l-2.1 2.1"/>',
    reloj:    '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    ordenes:  '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4h6v3H9z"/><path d="M8.5 12h7M8.5 16h5"/>',
    rayo:     '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>',
    // Compras y abasto
    carrito:  '<path d="M3 4h2.2l2.1 10.2a1.6 1.6 0 0 0 1.6 1.3h7.6a1.6 1.6 0 0 0 1.55-1.2L19.5 8H6.1"/><circle cx="9.5" cy="19.5" r="1.3"/><circle cx="17" cy="19.5" r="1.3"/>',
    caja:     '<path d="M12 3 4 7v10l8 4 8-4V7z"/><path d="M4 7l8 4 8-4"/><path d="M12 11v10"/>',
    camion:   '<path d="M2 6h11v10H2z"/><path d="M13 9h4l3 3v4h-7z"/><circle cx="6.5" cy="18" r="1.8"/><circle cx="16.5" cy="18" r="1.8"/>',
    recibo:   '<path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
    etiqueta: '<path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="8.5" r="1.2"/>',
    bolsa:    '<path d="M5 8h14l-1 13H6z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/>',
    // Inventario y almacén
    capas:    '<path d="M12 3 3 8l9 5 9-5-9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/>',
    archivo:  '<rect x="3" y="4" width="18" height="4" rx="1"/><path d="M5 8v12h14V8"/><path d="M10 12h4"/>',
    codigo:   '<path d="M4 6v12M7 6v12M11 6v12M14 6v12M17 6v12M20 6v12"/>',
    lupa:     '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l5 5"/>',
    intercambio: '<path d="M4 8h14l-3-3M20 16H6l3 3"/>',
    descarga: '<path d="M12 3v12"/><path d="M7 11l5 5 5-5"/><path d="M4 20h16"/>',
    subir:    '<path d="M12 16V4"/><path d="M7 8l5-5 5 5"/><path d="M4 20h16"/>',
    // Contabilidad y finanzas
    libro:    '<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2z"/><path d="M4 19V5"/><path d="M9 8h6"/>',
    calculadora: '<rect x="5" y="3" width="14" height="18" rx="2"/><path d="M8 7h8"/><path d="M8.5 12h.01M12 12h.01M15.5 12h.01M8.5 16h.01M12 16h.01M15.5 16h.01"/>',
    moneda:   '<circle cx="12" cy="12" r="9"/><path d="M14.5 9.5c-.5-1-1.5-1.5-2.5-1.5-1.5 0-2.5.8-2.5 2s1 1.7 2.5 2 2.5.8 2.5 2-1 2-2.5 2c-1 0-2-.5-2.5-1.5M12 6.5V8M12 16v1.5"/>',
    billete:  '<rect x="2.5" y="6" width="19" height="12" rx="2"/><circle cx="12" cy="12" r="2.8"/>',
    banco:    '<path d="M3 9l9-5 9 5z"/><path d="M5 9v8M9.5 9v8M14.5 9v8M19 9v8M3 20h18"/>',
    edificio: '<path d="M4 21V5l8-2v18"/><path d="M12 9l8 2v10"/><path d="M8 8h.01M8 12h.01M8 16h.01M16 14h.01M16 18h.01"/>',
    // Reportes
    barras:   '<path d="M4 20h16"/><path d="M7 20v-7M12 20V6M17 20v-10"/>',
    linea:    '<path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/>',
    pastel:   '<path d="M12 3v9h9a9 9 0 1 1-9-9z"/><path d="M15 3.5A9 9 0 0 1 20.5 9H15z"/>',
    documento: '<path d="M6 3h8l4 4v14H6z"/><path d="M14 3v4h4"/><path d="M9 12h6M9 16h6"/>',
    lista:    '<path d="M9 6h11M9 12h11M9 18h11"/><path d="M4.5 6h.01M4.5 12h.01M4.5 18h.01"/>',
    impresora: '<path d="M7 9V3h10v6"/><rect x="4" y="9" width="16" height="8" rx="2"/><path d="M7 14h10v7H7z"/>',
    // Personas y ventas
    personas: '<circle cx="9" cy="8" r="3.2"/><path d="M3 20a6 6 0 0 1 12 0"/><circle cx="17" cy="9" r="2.4"/><path d="M16.5 14.2A5 5 0 0 1 21 19"/>',
    usuario:  '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
    sobre:    '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>',
    mapa:     '<path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.5"/>',
    // Herramientas y generales
    brujula:  '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>',
    casa:     '<path d="M3 11l9-8 9 8"/><path d="M5 10v11h14V10"/><path d="M10 21v-6h4v6"/>',
    estrella: '<path d="M12 3l2.8 5.7 6.2.9-4.5 4.4 1 6.2L12 17.2 6.5 20.2l1-6.2L3 9.6l6.2-.9z"/>',
    campana:  '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 21h4"/>',
    calendario: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
    ajustes:  '<path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2"/><circle cx="8" cy="17" r="2"/>',
    candado:  '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
    escudo:   '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/>',
    bandera:  '<path d="M5 21V4"/><path d="M5 4h11l-2 4 2 4H5"/>',
    tarea:    '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l3 3 5-6"/>',
    carpeta:  '<path d="M3 6a2 2 0 0 1 2-2h4l2 3h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    lapiz:    '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
    mas:      '<path d="M12 5v14M5 12h14"/>',
    cerrar:   '<path d="M6 6l12 12M18 6L6 18"/>',
    izquierda: '<path d="M15 5l-7 7 7 7"/>',
    derecha:  '<path d="M9 5l7 7-7 7"/>',
};

// Categorías de la galería (orden de aparición en el selector)
export const CATEGORIAS_ICONOS = [
    ['Producción',            ['fabrica', 'matraz', 'probeta', 'gota', 'balanza', 'engrane', 'reloj', 'ordenes', 'rayo']],
    ['Compras y abasto',      ['carrito', 'caja', 'camion', 'recibo', 'etiqueta', 'bolsa']],
    ['Inventario y almacén',  ['capas', 'archivo', 'codigo', 'lupa', 'intercambio', 'descarga', 'subir']],
    ['Contabilidad y finanzas', ['libro', 'calculadora', 'moneda', 'billete', 'banco', 'edificio']],
    ['Reportes',              ['barras', 'linea', 'pastel', 'documento', 'lista', 'impresora']],
    ['Personas y ventas',     ['personas', 'usuario', 'sobre', 'mapa']],
    ['Herramientas',          ['brujula', 'casa', 'estrella', 'campana', 'calendario', 'ajustes', 'candado', 'escudo', 'bandera', 'tarea', 'carpeta']],
];

export const svgIcono = (nombre) =>
    `<svg viewBox="0 0 24 24" aria-hidden="true">${ICONOS[nombre] || ICONOS.estrella}</svg>`;
