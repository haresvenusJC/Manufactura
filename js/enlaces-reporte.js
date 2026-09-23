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
    ? `<button type="button" onclick="window.verPolizaDeDocumento(${Number(id)})" class="${clase} hover:underline cursor-pointer" title="Abrir la póliza">#${Number(id)}</button>`
    : '—';
