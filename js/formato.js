// =====================================================================
//  Formato de dinero (regla acordada con el usuario 2026-10-22):
//  · Costos y PRECIOS UNITARIOS: siempre 4 decimales (diezmilésimas), sin quitar ceros → money4(0.0525) = "$0.0525", money4(12.5) = "$12.5000".
//  · Importes, subtotales, IVA y totales: 2 decimales, redondeo COMERCIAL (el 3.er decimal ≥ 5 sube, ≤ 4 baja; nunca truncar).
//    El importe de cada partida = redondear2(cantidad × costo exacto); el subtotal suma esos importes ya redondeados,
//    el IVA se calcula sobre el subtotal y se redondea; total = subtotal + IVA (así lo impreso cuadra con calculadora).
// =====================================================================

// Redondeo comercial a `dec` decimales sin los fallos binarios de Math.round (1.005 → 1.01, 65.625 → 65.63).
export function redondear(n, dec = 2) {
    const x = Number(n) || 0;
    const signo = x < 0 ? -1 : 1;
    const r = Math.round(Number(`${Math.abs(x)}e${dec}`)) ;
    return signo * Number(`${r}e-${dec}`);
}
export const redondear2 = (n) => redondear(n, 2);

const fmt = (n, dec) => redondear(n, dec).toLocaleString('es-MX', { minimumFractionDigits: dec, maximumFractionDigits: dec });
export const money = (n) => '$' + fmt(n, 2);
export const money4 = (n) => '$' + fmt(n, 4);
export const num4 = (n) => fmt(n, 4);   // sin signo $ (celdas con "$" aparte)
// Importe de una partida: cantidad × costo exacto, redondeado a 2 decimales.
export const importe = (cantidad, costo) => redondear2(Number(cantidad || 0) * Number(costo || 0));

// Importe OFICIAL de una partida de ODC: el del proveedor (cantidad × precio en SU unidad, sql/2026-10-23c) si lo trae; si no, cantidad × costo.
// Nunca cantidad interna × costo interno: ese costo es derivado y puede diferir unos centavos.
export const importePartidaOdc = (d) => (d && d.importe_proveedor != null ? Number(d.importe_proveedor) : importe(d?.cantidad, d?.costo_unitario_estimado));
