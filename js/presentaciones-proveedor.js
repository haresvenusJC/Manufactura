// =====================================================================
//  Presentaciones típicas en que un proveedor vende (millar, gruesa,
//  tambo, saco...) con su factor de conversión a la unidad interna
//  (pieza, litro, kilo...). Un solo catálogo compartido — no se duplica
//  esta lista entre Recibo de mercancía (conversión de una recepción) y
//  Claves de proveedor en Productos (la presentación estándar de compra
//  de ese proveedor para ese producto).
// =====================================================================

export const GRUPOS_PRESENTACION = [
    {
        grupo: 'Piezas',
        opciones: [
            { factor: 1000, etiqueta: 'Millar (×1000 piezas)' },
            { factor: 144, etiqueta: 'Gruesa (×144 piezas)' },
            { factor: 12, etiqueta: 'Docena (×12 piezas)' },
        ],
    },
    {
        grupo: 'Volumen / peso a granel',
        opciones: [
            { factor: 200, etiqueta: 'Tambo 200 L (×200 L)' },
            { factor: 208, etiqueta: 'Tambo 208 L (×208 L)' },
            { factor: 1000, etiqueta: 'Kilo a gramos (×1000 g)' },
            { factor: 1000, etiqueta: 'Litro a mililitros (×1000 mL)' },
            { factor: 25, etiqueta: 'Saco 25 kg (×25 kg)' },
            { factor: 50, etiqueta: 'Saco 50 kg (×50 kg)' },
        ],
    },
];

// HTML de los <optgroup>/<option> del preset, listo para insertar dentro
// de un <select>. `factor` es el value de cada <option>.
export function opcionesPresentacionHtml() {
    return GRUPOS_PRESENTACION.map((g) => `<optgroup label="${g.grupo}">` +
        g.opciones.map((o) => `<option value="${o.factor}" data-etiqueta="${o.etiqueta}">${o.etiqueta}</option>`).join('') +
        `</optgroup>`).join('');
}

// Unidad de compra que trae el propio CFDI (claveUnidad SAT y/o el texto
// libre) -> preset de conteo. Solo para presentaciones "de conteo"
// (millar/gruesa/docena): si el CFDI ya trae la partida en kilogramo o
// litro, esa YA es la unidad base — no hay nada que convertir, y sugerir
// un factor ahí sería inventar una conversión que no aplica.
const MAPA_UNIDAD_CFDI = [
    // Mismo proveedor, misma factura: a veces pone "Millar" completo y a
    // veces la abrevia "MI" — ambas deben apuntar al mismo preset.
    { clave: /^mil$/i, texto: /^(millar|mi)$/i, factor: 1000, etiqueta: 'Millar (×1000 piezas)' },
    { clave: /^gro$/i, texto: /^gruesa$/i, factor: 144, etiqueta: 'Gruesa (×144 piezas)' },
    { clave: /^(dzn|dzp)$/i, texto: /^docena$/i, factor: 12, etiqueta: 'Docena (×12 piezas)' },
];

export function sugerirPresetPorUnidadCfdi(claveUnidad, unidadTexto) {
    const clave = (claveUnidad || '').trim();
    const texto = (unidadTexto || '').trim();
    for (const m of MAPA_UNIDAD_CFDI) {
        if ((clave && m.clave.test(clave)) || (texto && m.texto.test(texto))) {
            return { factor: m.factor, etiqueta: m.etiqueta };
        }
    }
    return null;
}
