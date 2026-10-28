import { familiaDeUnidad } from './conversion-unidades.js';

// =====================================================================
//  Factor sugerido entre la unidad SAT con que VENDE un proveedor (c_ClaveUnidad) y la unidad en
//  que se lleva el inventario del producto. Es solo una SUGERENCIA para precargar el campo
//  "Factor": el usuario siempre puede corregirlo, y si no se puede deducir se deja VACÍO (nunca
//  se asume 1 a 1 en silencio).
//
//  Regla de diseño: el stock y el BOM solo conocen UNA unidad por producto; la unidad del proveedor
//  existe solo al capturar compras. Factor = cuántas unidades de INVENTARIO trae 1 unidad del proveedor
//  (1 MIL = 1,000 Piezas → 1000; 1 KGM → 1 si el inventario es en kilos, 0.001 si es en gramos...).
// =====================================================================

// Claves SAT de peso, volumen y longitud → nombre que entiende `familiaDeUnidad` (misma tabla de factores
// que el BOM; no se duplican los números aquí).
const CLAVE_A_NOMBRE = {
    KGM: 'kilogramos', GRM: 'gramos', MGM: 'miligramos', TNE: 'toneladas', LBR: 'libras', ONZ: 'onzas',
    LTR: 'litros', MLT: 'mililitros', CLT: 'centilitros', DLT: 'decilitros', MTQ: 'metros cubicos', GLL: 'galones',
    MTR: 'metros', CMT: 'centimetros', MMT: 'milimetros', KMT: 'kilometros', INH: 'pulgadas', FOT: 'pies', YRD: 'yardas',
};

// Unidades de CONTEO con un múltiplo fijo y universal de la pieza.
const MULTIPLO_PIEZA = { H87: 1, EA: 1, XUN: 1, MIL: 1000, DZN: 12, GRO: 144 };

const redondear = (n) => Math.round(n * 1e6) / 1e6;

/**
 * @param {object} p
 *   claveProv     clave SAT de la unidad del proveedor (ej. 'MIL')
 *   nombreInv     nombre de la unidad de inventario del producto (ej. 'Piezas', 'Kilogramos')
 *   claveInv      clave SAT ligada a esa unidad del ERP (unidades_medida.clave_sat), si ya se ligó
 * @returns {{factor:number, nota:string}|null}  null = no se puede deducir: capturarlo a mano.
 */
export function factorSugeridoSat({ claveProv, nombreInv, claveInv }) {
    const prov = String(claveProv || '').trim().toUpperCase();
    if (!prov) return null;
    const inv = String(claveInv || '').trim().toUpperCase();

    // 1) Misma unidad SAT que la del inventario → 1 a 1 (ya liga el ERP, no hay nada que convertir).
    if (inv && inv === prov) return { factor: 1, nota: 'Es la misma unidad que la de tu inventario.' };

    // 2) Peso / volumen / longitud: se convierte exacto con la tabla del BOM.
    const nombreProv = CLAVE_A_NOMBRE[prov];
    if (nombreProv) {
        const fp = familiaDeUnidad(nombreProv);
        const fi = familiaDeUnidad(nombreInv);
        if (fp && fi && fp.familia === fi.familia) {
            return { factor: redondear(fp.aBase / fi.aBase), nota: 'Conversión exacta entre unidades de la misma familia.' };
        }
        return null; // p. ej. proveedor vende en litros y el inventario va en kilos: depende de la densidad → a mano
    }

    // 3) Conteo: múltiplos fijos de la pieza, solo si el inventario también se cuenta en piezas.
    if (prov in MULTIPLO_PIEZA) {
        const invEsPieza = inv === 'H87' || /^(pieza|piezas|pza|pzas|unidad|unidades)$/i.test(String(nombreInv || '').trim());
        if (invEsPieza) return { factor: MULTIPLO_PIEZA[prov], nota: 'Múltiplo estándar de la pieza.' };
        return null;
    }

    // 4) Caja, paquete, rollo, tambo...: el contenido lo define cada proveedor → a mano.
    return null;
}
