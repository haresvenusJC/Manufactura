// =====================================================================
//  Fechas sin hora (columnas `date`: fecha_ingreso, fecha_emision…).
//  `new Date('2026-10-16')` las toma como medianoche UTC y en México (UTC−6)
//  se ven como el día ANTERIOR (15/10). Este helper las lee como fecha local.
//  Si el valor trae hora (timestamp), se comporta como siempre.
// =====================================================================
export function fechaLocalTxt(v, locale) {
    if (!v) return '';
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(v).trim());
    const d = m ? new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3])) : new Date(v);
    if (isNaN(d.getTime())) return '';
    return locale ? d.toLocaleDateString(locale) : d.toLocaleDateString();
}

// Fecha de HOY en hora local (no UTC): `new Date().toISOString().slice(0,10)` da el día siguiente después de las 18:00 en México.
const dosD = (n) => String(n).padStart(2, '0');
export function isoLocal(d) { return `${d.getFullYear()}-${dosD(d.getMonth() + 1)}-${dosD(d.getDate())}`; }
export function hoyISO() { return isoLocal(new Date()); }
export function diasDesdeHoyISO(n) { const d = new Date(); d.setDate(d.getDate() + n); return isoLocal(d); }
