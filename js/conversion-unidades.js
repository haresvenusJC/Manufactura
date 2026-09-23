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
 *  - Lo mismo pero SIN densidad: se asume 1 kg/L (agua) respetando la escala (mL→kg ×0.001) y se avisa.
 *  - Origen sin unidad (capturas viejas del BOM sin unidad_medida): regla histórica
 *    (mL/g → kg/L y cantidades > 10 se toman como mL/g), para no romper BOM ya cargados así.
 * Devuelve { factor, nota, tipo }: `tipo` es 'ok' (conversión resuelta, con o sin densidad)
 * o 'aviso' (falta la densidad: se asumió agua, o unidades no convertibles tomadas 1 a 1).
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
        // Sin densidad: se asume 1 kg/L (como agua) PERO respetando la escala de cada unidad
        // (41 mL -> 0.041 kg, no 41 kg). Se sigue avisando que falta la densidad.
        return { factor: fo.aBase / fd.aBase, nota: `Está en ${nombreOrigen} y el inventario en ${nombreUnidadDestino}: falta la densidad del insumo, se toma como agua (1 kg/L).`, tipo: 'aviso' };
    }
    if (nombreOrigen && nombreUnidadDestino && nombreOrigen.toLowerCase() !== nombreUnidadDestino.toLowerCase()) {
        return { factor: 1, nota: `Está en ${nombreOrigen} y el inventario en ${nombreUnidadDestino}: son unidades que no se pueden convertir entre sí, se toma 1 a 1.`, tipo: 'aviso' };
    }
    return { factor: 1, nota: '', tipo: 'ok' };
}

/**
 * Tamaño teórico de UNA tanda de una receta (BOM): suma lo que aporta cada renglón, llevado a la
 * unidad del producto (volumen o masa) con la densidad de cada insumo. Sirve para proponer el
 * "Rendimiento del lote" de un granel (ej. Granel Aceite Sey Fresa Kiwi: ≈ 14.64 L).
 *  - renglones: [{ nombre, cantidad, unidadNombre, densidad }] (densidad en kg/L del insumo).
 *  - Renglones en piezas u otras unidades sin masa/volumen se ignoran (frascos, etiquetas).
 *  - Sin densidad se toma como agua (1 kg/L); solo afecta el total si hay que cambiar de familia
 *    (insumo en kg en una receta que rinde litros, o al revés) — esos van en `sinDensidad`.
 * Es teórico: al mezclar líquidos el volumen real puede ser un poco menor que la suma.
 */
export function tamanoTeoricoTanda(renglones, unidadProductoNombre) {
    const fp = familiaDeUnidad(unidadProductoNombre);
    let mL = 0, g = 0;
    const sinDensidad = [], ignorados = [];
    for (const r of renglones || []) {
        const q = Number(r.cantidad) || 0;
        if (q <= 0) continue;
        const f = familiaDeUnidad(r.unidadNombre);
        if (!f) { ignorados.push(r.nombre); continue; }
        const d = Number(r.densidad) || 0;
        const dens = d > 0 ? d : 1;
        if (!(d > 0) && fp && f.familia !== fp.familia) sinDensidad.push(r.nombre);
        if (f.familia === 'volumen') { const v = q * f.aBase; mL += v; g += v * dens; }
        else { const m = q * f.aBase; g += m; mL += m / dens; }
    }
    const total = !fp ? null : (fp.familia === 'volumen' ? mL / fp.aBase : g / fp.aBase);
    return {
        total, familia: fp ? fp.familia : null,
        litros: mL / 1000, kilos: g / 1000,
        densidadMezcla: mL > 0 ? g / mL : null,
        sinDensidad, ignorados,
    };
}
