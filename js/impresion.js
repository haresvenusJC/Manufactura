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
    texto_pie: ''
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

/**
 * Imprime el contenido de un contenedor existente en el DOM aplicando
 * la plantilla configurada para ese tipo de documento.
 *
 * @param {string} tipoDocumento - código del tipo (debe existir en tipos_movimiento, o 'generico')
 * @param {string} tituloDocumento - texto identificador, ej. "Folio FAC000069" o "Orden de Producción #14"
 * @param {string} idContenedor - id del elemento del DOM cuyo contenido se imprimirá
 */
export async function imprimirConPlantilla(tipoDocumento, tituloDocumento, idContenedor) {
    const original = document.getElementById(idContenedor);
    if (!original) {
        console.error(`No se encontró el contenedor #${idContenedor} para imprimir.`);
        return;
    }

    const p = await obtenerPlantilla(tipoDocumento);

    const encabezadoHtml = `
        <div style="text-align:center; border-bottom:2px solid ${p.color_acento}; padding-bottom:10px; margin-bottom:16px;">
            ${p.logo_url ? `<img src="${p.logo_url}" style="max-height:60px; margin-bottom:6px;">` : ''}
            <h1 style="margin:0; font-size:18px; color:${p.color_acento};">${p.titulo_encabezado}</h1>
            <p style="margin:2px 0; font-size:11px; color:#555;">${p.subtitulo_encabezado}</p>
            <p style="margin:4px 0 0; font-size:12px; font-weight:bold; color:#000;">${tituloDocumento}</p>
        </div>
    `;

    const textoPie = [p.notas_legales, p.texto_pie].filter(Boolean).join(' — ');
    const pieHtml = textoPie
        ? `<div style="margin-top:20px; padding-top:8px; border-top:1px solid #ccc; font-size:10px; color:#666; text-align:center;">${textoPie}</div>`
        : '';

    // Se clona el contenido original (sin tocarlo) y se descarta cualquier
    // encabezado/pie que haya quedado de una versión anterior del motor.
    const clon = original.cloneNode(true);
    clon.querySelectorAll('.plantilla-encabezado-print, .plantilla-pie-print').forEach(el => el.remove());

    const host = obtenerHostImpresion();
    host.innerHTML = encabezadoHtml + clon.innerHTML + pieHtml;
    host.dataset.mostrarCostos = p.mostrar_costos ? '1' : '0';
    host.dataset.mostrarLote = p.mostrar_lote ? '1' : '0';

    document.querySelectorAll('.area-imprimible-activa').forEach(el => el.classList.remove('area-imprimible-activa'));
    host.classList.add('area-imprimible-activa');

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
        window.removeEventListener('afterprint', ocultar);
    };
    window.addEventListener('afterprint', ocultar);
    setTimeout(ocultar, 5000);

    window.print();
}

// Estilos globales de impresión (una sola vez para toda la app)
if (!document.getElementById('print-styles-global')) {
    const styleSheet = document.createElement('style');
    styleSheet.id = 'print-styles-global';
    styleSheet.innerHTML = `
        @media print {
            body * { visibility: hidden; }
            .area-imprimible-activa, .area-imprimible-activa * { visibility: visible; }
            .area-imprimible-activa {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                background: white !important;
                color: #111 !important;
                padding: 20px;
            }
            .no-print { display: none !important; }
            .area-imprimible-activa[data-mostrar-costos="0"] .campo-costo { display: none !important; }
            .area-imprimible-activa[data-mostrar-lote="0"] .campo-lote { display: none !important; }
        }
    `;
    document.head.appendChild(styleSheet);
}
