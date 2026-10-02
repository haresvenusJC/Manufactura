// =====================================================================
//  Conversión de unidades entre lo que pide una fórmula (BOM) y la unidad en
//  que se lleva el inventario de ese insumo. Compartido por js/produccion.js
//  (para calcular cuánto descontar al producir) y js/catalogo.js (para
//  avisar, al capturar la fórmula, cuánto se va a descontar de verdad).
// =====================================================================

// Familias que se pueden convertir con exactitud. `aBase` = cuántas unidades base vale 1 de esa unidad:
//   masa → gramos · volumen → mililitros · longitud → milímetros.
// Estándar: onza = masa avoirdupois (28.349523125 g); galón = galón US (3,785.411784 mL); tonelada = métrica.
// ("Onzas fluidas" es aparte: volumen.) Lo que NO está aquí (Piezas, Cajas, Paquetes...) son conteos: no hay
// factor universal, solo se comparan 1 a 1 (o con el factor que capture el proveedor).
// OJO: SQL espejo en public._unidad_familia_base() (sql/2026-10-31_conversiones_unidades_ampliadas.sql) — si se cambia una, cambiar la otra.
const FAMILIAS_UNIDAD = [
    // masa
    [/^(miligramos?|mgs?)$/, 'masa', 0.001],
    [/^(gramos?|grs?|g)$/, 'masa', 1],
    [/^(kilogramos?|kilos?|kgs?)$/, 'masa', 1000],
    [/^(toneladas?|tons?)$/, 'masa', 1000000],
    [/^(libras?|lbs?)$/, 'masa', 453.59237],
    [/^(onzas?|oz)$/, 'masa', 28.349523125],
    // volumen
    [/^(mililitros?|mls?|cc|cm3|centimetros? cubicos?)$/, 'volumen', 1],
    [/^(centilitros?|cls?)$/, 'volumen', 10],
    [/^(decilitros?|dls?)$/, 'volumen', 100],
    [/^(litros?|lts?|l|dm3|decimetros? cubicos?)$/, 'volumen', 1000],
    [/^(metros? cubicos?|m3)$/, 'volumen', 1000000],
    [/^(onzas? fluidas?|fl ?oz)$/, 'volumen', 29.5735295625],
    [/^(galon|galones|gal|gals)$/, 'volumen', 3785.411784],
    // longitud
    [/^(milimetros?|mms?)$/, 'longitud', 1],
    [/^(centimetros?|cms?)$/, 'longitud', 10],
    [/^(metros?|mts?|mtrs?|m)$/, 'longitud', 1000],
    [/^(kilometros?|kms?)$/, 'longitud', 1000000],
    [/^(pulgadas?|pulg|in)$/, 'longitud', 25.4],
    [/^(pies?|ft)$/, 'longitud', 304.8],
    [/^(yardas?|yds?)$/, 'longitud', 914.4],
];

export const BASE_FAMILIA = { masa: 'gramo', volumen: 'mililitro', longitud: 'milímetro' };

export function familiaDeUnidad(nombre) {
    const n = String(nombre || '').normalize('NFKD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/\s+/g, ' ').trim();
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

    const masaVolumen = (a, b) => (a === 'masa' && b === 'volumen') || (a === 'volumen' && b === 'masa');
    if (fo && fd && fo.familia !== fd.familia && masaVolumen(fo.familia, fd.familia)) {
        const densidad = Number(densidadKgL) || 0;
        if (densidad > 0) {
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
 * Tamaño teórico de UNA tanda de una fórmula (BOM): suma lo que aporta cada renglón, llevado a la
 * unidad del producto (volumen o masa) con la densidad de cada insumo. Sirve para proponer el
 * "Rendimiento del lote" de un granel (ej. Granel Aceite Sey Fresa Kiwi: ≈ 14.64 L).
 *  - renglones: [{ nombre, cantidad, unidadNombre, densidad }] (densidad en kg/L del insumo).
 *  - Renglones en piezas u otras unidades sin masa/volumen se ignoran (frascos, etiquetas).
 *  - `densidadCalculada`: densidad de la mezcla (kg/L, 3 decimales) para la "Densidad" del granel.
 *  - Sin densidad se toma como agua (1 kg/L); solo afecta el total si hay que cambiar de familia
 *    (insumo en kg en una fórmula que rinde litros, o al revés) — esos van en `sinDensidad`.
 * Es teórico: al mezclar líquidos el volumen real puede ser un poco menor que la suma.
 */
export function tamanoTeoricoTanda(renglones, unidadProductoNombre) {
    const fp0 = familiaDeUnidad(unidadProductoNombre);
    const fp = fp0 && fp0.familia !== 'longitud' ? fp0 : null;   // la longitud no es masa ni volumen: no entra en la suma
    let mL = 0, g = 0;
    const sinDensidad = [], ignorados = [], densidadFaltante = [];
    let conDensidad = 0;
    const detalle = [];   // por insumo: { nombre, litros, kilos, densidad, supuesta } — para explicar la densidad
    for (const r of renglones || []) {
        const q = Number(r.cantidad) || 0;
        if (q <= 0) continue;
        const f = familiaDeUnidad(r.unidadNombre);
        if (!f || f.familia === 'longitud') { ignorados.push(r.nombre); continue; }
        const d = Number(r.densidad) || 0;
        const dens = d > 0 ? d : 1;
        if (!(d > 0) && fp && f.familia !== fp.familia) sinDensidad.push(r.nombre);
        if (d > 0) conDensidad++; else densidadFaltante.push(r.nombre);
        if (f.familia === 'volumen') { const v = q * f.aBase; mL += v; g += v * dens; detalle.push({ nombre: r.nombre, litros: v / 1000, kilos: v * dens / 1000, densidad: dens, supuesta: !(d > 0) }); }
        else { const m = q * f.aBase; g += m; mL += m / dens; detalle.push({ nombre: r.nombre, litros: m / dens / 1000, kilos: m / 1000, densidad: dens, supuesta: !(d > 0) }); }
    }
    const total = !fp ? null : (fp.familia === 'volumen' ? mL / fp.aBase : g / fp.aBase);
    return {
        total, familia: fp ? fp.familia : null,
        litros: mL / 1000, kilos: g / 1000,
        densidadMezcla: mL > 0 ? g / mL : null,
        sinDensidad, ignorados,
        // Densidad de la mezcla (kg/L) para llenar la del granel: solo si al menos un insumo trae la suya;
        // los que no la tienen (densidadFaltante) cuentan como agua.
        densidadCalculada: (mL > 0 && conDensidad > 0) ? Math.round((g / mL) * 1000) / 1000 : null,
        densidadFaltante, detalle,
    };
}
