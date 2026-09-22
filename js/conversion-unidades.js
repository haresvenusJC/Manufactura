// =====================================================================
//  Conversión de unidades entre lo que pide una receta (BOM) y la unidad en
//  que se lleva el inventario de ese insumo. Compartido por js/produccion.js
//  (para calcular cuánto descontar al producir) y js/catalogo.js (para
//  avisar, al capturar la receta, cuánto se va a descontar de verdad).
// =====================================================================

// Familias que se pueden convertir con exactitud: masa (mg, g, kg) y volumen (mL, L).
const FAMILIAS_UNIDAD = [
    [/^(miligramos?|mgs?)$/, 'masa', 0.001],
    [/^(kilogramos?|kilos?|kgs?)$/, 'masa', 1000],
    [/^(gramos?|grs?|g)$/, 'masa', 1],
    [/^(mililitros?|mls?|cc)$/, 'volumen', 1],
    [/^(litros?|lts?|l)$/, 'volumen', 1000],
];

export function familiaDeUnidad(nombre) {
    const n = String(nombre || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().trim();
    for (const [re, familia, aBase] of FAMILIAS_UNIDAD) if (re.test(n)) return { familia, aBase };
    return null;
}

/**
 * Cuántas unidades de destino (inventario) equivale 1 unidad de origen (BOM).
 *  - Misma unidad (mismo id): 1.
 *  - Mismo tipo de unidad, distinta escala (g ↔ kg, mL ↔ L): se convierte exacto.
 *  - Unidades de distinto tipo (p. ej. Litros ↔ Kilogramos) CON densidad
 *    (kg que pesa 1 litro) capturada: se convierte con ella.
 *  - Lo mismo pero SIN densidad: no se puede convertir, se toma 1 a 1 y se avisa.
 *  - Origen sin unidad (capturas viejas del BOM sin unidad_medida): regla histórica
 *    (mL/g → kg/L y cantidades > 10 se toman como mL/g), para no romper BOM ya cargados así.
 * Devuelve { factor, nota, tipo }: `tipo` es 'ok' (conversión resuelta, con o sin densidad)
 * o 'aviso' (se tomó 1 a 1 a ciegas, falta la densidad).
 */
export function factorConversion(unidadOrigenRaw, unidadDestinoId, nombreUnidadPorId, nombreUnidadDestino, cantidadOrigen, densidadKgL) {
    const raw = String(unidadOrigenRaw ?? '').trim();
    if (!raw) {
        const destino = String(nombreUnidadDestino || '').toLowerCase().trim();
        return { factor: (destino.includes('ml') || destino.includes('g') || cantidadOrigen > 10) ? 1 / 1000 : 1, nota: '', tipo: 'ok' };
    }
    if (String(unidadDestinoId ?? '') === raw) return { factor: 1, nota: '', tipo: 'ok' };

    const nombreOrigen = /^\d+$/.test(raw) ? (nombreUnidadPorId.get(raw) || '') : raw;
    const fo = familiaDeUnidad(nombreOrigen);
    const fd = familiaDeUnidad(nombreUnidadDestino);
    if (fo && fd && fo.familia === fd.familia) return { factor: fo.aBase / fd.aBase, nota: '', tipo: 'ok' };

    if (fo && fd && fo.familia !== fd.familia) {
        const densidad = Number(densidadKgL) || 0;
        if (densidad > 0 && ((fo.familia === 'volumen' && fd.familia === 'masa') || (fo.familia === 'masa' && fd.familia === 'volumen'))) {
            // kg/L y g/mL son el mismo número: se convierte a la unidad base de cada familia y se aplica la densidad.
            const factor = fo.familia === 'volumen'
                ? (fo.aBase * densidad) / fd.aBase        // origen en volumen, destino en masa
                : (fo.aBase / densidad) / fd.aBase;        // origen en masa, destino en volumen
            return { factor, nota: `Convertido con densidad ${densidad} kg/L.`, tipo: 'ok' };
        }
    }
    if (nombreOrigen && nombreUnidadDestino && nombreOrigen.toLowerCase() !== nombreUnidadDestino.toLowerCase()) {
        return { factor: 1, nota: `Está en ${nombreOrigen} y el inventario en ${nombreUnidadDestino}: falta la densidad del insumo, se toma 1 a 1.`, tipo: 'aviso' };
    }
    return { factor: 1, nota: '', tipo: 'ok' };
}
