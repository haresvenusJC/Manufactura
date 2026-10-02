import { supabaseClient } from './supabase.js';

// Cache en memoria de las plantillas para no consultar Supabase en cada impresión
let cachePlantillas = null;

const PLANTILLA_DEFAULT = {
    tipo_documento: 'generico',
    nombre_plantilla: 'Plantilla General',
    logo_url: '',
    titulo_encabezado: 'Hares de México',
    subtitulo_encabezado: 'Comprobante de Movimiento de Almacén',
    color_acento: '#4f46e5',
    mostrar_costos: true,
    mostrar_lote: true,
    notas_legales: '',
    texto_pie: '',
    compacto: true
};

export function invalidarCachePlantillas() {
    cachePlantillas = null;
}

async function cargarTodasLasPlantillas() {
    if (cachePlantillas) return cachePlantillas;

    const { data, error } = await supabaseClient
        .from('plantillas_documentos')
        .select('*');

    cachePlantillas = {};
    if (!error && data) {
        data.forEach(p => { cachePlantillas[p.tipo_documento] = p; });
    }
    return cachePlantillas;
}

// Devuelve la plantilla del tipo pedido, o la 'generico', o el default embebido
export async function obtenerPlantilla(tipoDocumento) {
    const todas = await cargarTodasLasPlantillas();
    return todas[tipoDocumento] || todas['generico'] || PLANTILLA_DEFAULT;
}

// Host de impresión: un único elemento pegado directo a <body>, fuera de
// cualquier ancestro con position:fixed (los modales lo son). Los navegadores
// repiten el contenido de los elementos "fixed" en cada página al imprimir;
// al vivir fuera de esa cadena evitamos que el documento salga duplicado.
function obtenerHostImpresion() {
    let host = document.getElementById('motorImpresionGlobal');
    if (!host) {
        host = document.createElement('div');
        host.id = 'motorImpresionGlobal';
        host.style.display = 'none';
        document.body.appendChild(host);
    }
    return host;
}

const escHtml = (x) => String(x ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

/**
 * Imprime el contenido de un contenedor existente en el DOM aplicando
 * la plantilla configurada para ese tipo de documento.
 *
 * Estilo único para TODOS los documentos de la app (carta, márgenes de 10 mm, encabezado de una sola
 * franja, tablas compactas con encabezado repetido, sin fondos ni sombras para ahorrar hojas y tinta).
 * La vista compacta se puede apagar por plantilla (Configuración → Plantillas, "Vista compacta").
 *
 * @param {string} tipoDocumento - código del tipo (debe existir en tipos_movimiento, o 'generico')
 * @param {string} tituloDocumento - texto identificador, ej. "Folio FAC000069" o "Orden de Producción #14"
 * @param {string|Element} idContenedor - id del elemento del DOM (o el elemento) cuyo contenido se imprimirá
 * @param {{orientacion?: 'vertical'|'horizontal'}} [opciones] - si no se indica, horizontal automático con más de 8 columnas
 */
export async function imprimirConPlantilla(tipoDocumento, tituloDocumento, idContenedor, opciones = {}) {
    // Acepta el id del contenedor o el elemento mismo (subventanas con varias instancias abiertas: sin ids repetidos).
    const original = typeof idContenedor === 'string' ? document.getElementById(idContenedor) : idContenedor;
    if (!original) {
        console.error(`No se encontró el contenedor #${idContenedor} para imprimir.`);
        return;
    }

    const p = await obtenerPlantilla(tipoDocumento);
    // Reportes anchos (más de 8 columnas: balanza, auxiliares, tabla dinámica) salen en horizontal para no partir columnas.
    const maxColumnas = Math.max(0, ...Array.from(original.querySelectorAll('tr')).map((r) => r.cells.length));
    const orientacion = opciones.orientacion || (maxColumnas > 8 ? 'horizontal' : 'vertical');
    const fecha = new Date().toLocaleDateString('es-MX', { day: '2-digit', month: '2-digit', year: 'numeric' });

    // Encabezado de UNA franja: logo | empresa y tipo | documento y fecha (antes eran 4 líneas centradas).
    const encabezadoHtml = `
        <div class="dpe">
            <div class="dpe-logo">${p.logo_url ? `<img src="${escHtml(p.logo_url)}" alt="">` : ''}</div>
            <div class="dpe-centro"><h1>${escHtml(p.titulo_encabezado)}</h1><p>${escHtml(p.subtitulo_encabezado)}</p></div>
            <div class="dpe-der"><strong>${escHtml(tituloDocumento)}</strong><span>${fecha}</span></div>
        </div>`;

    const textoPie = [p.notas_legales, p.texto_pie].filter(Boolean).join(' — ');
    const pieHtml = textoPie ? `<div class="dpe-pie">${escHtml(textoPie)}</div>` : '';

    // Se clona el contenido original (sin tocarlo) y se descarta cualquier
    // encabezado/pie que haya quedado de una versión anterior del motor.
    const clon = original.cloneNode(true);
    clon.querySelectorAll('.plantilla-encabezado-print, .plantilla-pie-print').forEach(el => el.remove());

    const host = obtenerHostImpresion();
    host.innerHTML = encabezadoHtml + clon.innerHTML + pieHtml;
    host.dataset.mostrarCostos = p.mostrar_costos ? '1' : '0';
    host.dataset.mostrarLote = p.mostrar_lote ? '1' : '0';
    host.style.setProperty('--acento-print', p.color_acento || '#4f46e5');
    host.classList.toggle('print-compacto', p.compacto !== false);

    document.querySelectorAll('.area-imprimible-activa').forEach(el => el.classList.remove('area-imprimible-activa'));
    host.classList.add('area-imprimible-activa');

    // Tamaño/orientación de la hoja: se inyecta solo mientras se imprime (carta; horizontal para reportes anchos).
    let estiloPagina = document.getElementById('print-page-style');
    if (!estiloPagina) { estiloPagina = document.createElement('style'); estiloPagina.id = 'print-page-style'; document.head.appendChild(estiloPagina); }
    estiloPagina.textContent = `@page { size: letter ${orientacion === 'horizontal' ? 'landscape' : 'portrait'}; margin: 10mm; }`;

    host.style.display = 'block';

    // En escritorio window.print() bloquea hasta que se cierra el diálogo,
    // asi que ocultar el host justo despues es seguro. En iOS/iPadOS NO
    // bloquea (el share sheet de impresion/PDF aparece de forma asincrona),
    // asi que ocultar el host de inmediato lo dejaba oculto antes de que el
    // sistema alcanzara a capturar el contenido, resultando en un PDF en
    // blanco. Se espera al evento 'afterprint' (dispara en ambos casos al
    // cerrar el dialogo) con un respaldo por tiempo por si el navegador no
    // lo dispara.
    let oculto = false;
    const ocultar = () => {
        if (oculto) return;
        oculto = true;
        host.style.display = 'none';
        estiloPagina.textContent = '';
        window.removeEventListener('afterprint', ocultar);
    };
    window.addEventListener('afterprint', ocultar);
    setTimeout(ocultar, 5000);

    window.print();
}

/**
 * Imprime un HTML armado al vuelo (comprobantes, hojas de captura) con el mismo estilo que todo lo demás:
 * se monta fuera de pantalla, se imprime y se quita. Úsalo cuando el documento no vive en ninguna pantalla.
 */
export async function imprimirHtml(tipoDocumento, tituloDocumento, html, opciones = {}) {
    const caja = document.createElement('div');
    caja.style.display = 'none';
    caja.innerHTML = html;
    document.body.appendChild(caja);
    try { await imprimirConPlantilla(tipoDocumento, tituloDocumento, caja, opciones); }
    finally { setTimeout(() => caja.remove(), 6000); }
}

// Estilos globales de impresión (una sola vez para toda la app)
if (!document.getElementById('print-styles-global')) {
    const styleSheet = document.createElement('style');
    styleSheet.id = 'print-styles-global';
    styleSheet.innerHTML = `
        @page { margin: 10mm; @bottom-right { content: "Pág. " counter(page) " de " counter(pages); font: 8px sans-serif; color: #666; } }
        @media print {
            body * { visibility: hidden; }
            .area-imprimible-activa, .area-imprimible-activa * { visibility: visible; }
            .area-imprimible-activa {
                position: absolute; left: 0; top: 0; width: 100%;
                background: white !important; color: #111 !important; padding: 0 !important;
                font-family: system-ui, -apple-system, 'Segoe UI', Arial, sans-serif;
            }
            .no-print, .area-imprimible-activa button { display: none !important; }
            .area-imprimible-activa[data-mostrar-costos="0"] .campo-costo { display: none !important; }
            .area-imprimible-activa[data-mostrar-lote="0"] .campo-lote { display: none !important; }

            /* Blanco y negro, sin fondos ni sombras (ahorra tinta); lo que estaba recortado por scroll se imprime completo. */
            .area-imprimible-activa * {
                background: transparent !important; box-shadow: none !important; text-shadow: none !important;
                color: #111 !important; border-color: #b5b5b5 !important; backdrop-filter: none !important;
            }
            .area-imprimible-activa [class*="overflow-"] { overflow: visible !important; }
            .area-imprimible-activa [class*="max-h-"] { max-height: none !important; }
            .area-imprimible-activa [class*="max-w-"] { max-width: none !important; }
            .area-imprimible-activa input, .area-imprimible-activa select, .area-imprimible-activa textarea { border: none !important; padding: 0 !important; appearance: none; }

            /* Encabezado de una franja */
            .area-imprimible-activa .dpe { display: flex; align-items: center; gap: 10px; border-bottom: 1.5px solid var(--acento-print, #4f46e5) !important; padding-bottom: 4px; margin-bottom: 6px; }
            .area-imprimible-activa .dpe-logo { flex: 0 0 auto; min-width: 0; }
            .area-imprimible-activa .dpe-logo img { max-height: 28px; display: block; }
            .area-imprimible-activa .dpe-centro { flex: 1 1 auto; }
            .area-imprimible-activa .dpe .dpe-centro h1 { margin: 0; font-size: 13px !important; font-weight: 700; color: var(--acento-print, #4f46e5) !important; }
            .area-imprimible-activa .dpe .dpe-centro p { margin: 0; font-size: 9px !important; color: #555 !important; }
            .area-imprimible-activa .dpe-der { flex: 0 0 auto; text-align: right; display: flex; flex-direction: column; }
            .area-imprimible-activa .dpe .dpe-der strong { font-size: 11px !important; }
            .area-imprimible-activa .dpe .dpe-der span { font-size: 9px !important; color: #555 !important; }
            .area-imprimible-activa .dpe-pie { margin-top: 8px; padding-top: 4px; border-top: 1px solid #b5b5b5 !important; font-size: 8px !important; color: #666 !important; text-align: center; }

            /* Tablas: encabezado repetido en cada hoja y filas que no se parten */
            .area-imprimible-activa table { width: 100%; border-collapse: collapse; }
            .area-imprimible-activa thead { display: table-header-group; }
            .area-imprimible-activa thead th { font-weight: 700; border-bottom: 1px solid #555 !important; text-align: left; }
            .area-imprimible-activa tr { break-inside: avoid; page-break-inside: avoid; }
            .area-imprimible-activa h1, .area-imprimible-activa h2, .area-imprimible-activa h3 { break-after: avoid; }

            /* Vista compacta (por defecto): letra chica, espacios mínimos → menos hojas */
            .area-imprimible-activa.print-compacto, .area-imprimible-activa.print-compacto * { font-size: 10px !important; line-height: 1.3 !important; }
            .area-imprimible-activa.print-compacto h2, .area-imprimible-activa.print-compacto h3 { font-size: 11px !important; font-weight: 700; margin: 4px 0 2px !important; }
            .area-imprimible-activa.print-compacto .dpe .dpe-centro h1 { font-size: 13px !important; }
            .area-imprimible-activa.print-compacto .dpe .dpe-centro p, .area-imprimible-activa.print-compacto .dpe .dpe-der span { font-size: 9px !important; }
            .area-imprimible-activa.print-compacto .dpe .dpe-der strong { font-size: 11px !important; }
            .area-imprimible-activa.print-compacto .dpe-pie { font-size: 8px !important; }
            .area-imprimible-activa.print-compacto th, .area-imprimible-activa.print-compacto td { padding: 2px 4px !important; border-bottom: 0.5px solid #cfcfcf !important; }
            .area-imprimible-activa.print-compacto [class*="rounded"] { border-radius: 0 !important; }
            .area-imprimible-activa.print-compacto [class*="border"]:not(table):not(tr):not(td):not(th):not(.dpe):not(.dpe-pie) { padding: 3px 5px !important; }
            .area-imprimible-activa.print-compacto [class*="mt-"] { margin-top: 3px !important; }
            .area-imprimible-activa.print-compacto [class*="mb-"] { margin-bottom: 3px !important; }
            .area-imprimible-activa.print-compacto [class*="space-y-"] > * + * { margin-top: 3px !important; }
            .area-imprimible-activa.print-compacto [class*="gap-"] { gap: 3px 8px !important; }
            .area-imprimible-activa.print-compacto hr { margin: 3px 0 !important; }
        }
    `;
    document.head.appendChild(styleSheet);
}
