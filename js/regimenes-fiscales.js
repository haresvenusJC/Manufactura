import { supabaseClient } from './supabase.js';

// =====================================================================
//  Regímenes fiscales (SAT c_RegimenFiscal) — fuente única para todos los formularios.
//  La verdad está en la tabla `c_regimen_fiscal` (sql/2026-10-30_c_regimen_fiscal.sql, editable en
//  Configuración → Tablas → "SAT · Regímenes fiscales"). La lista de abajo es SOLO el respaldo para
//  cuando esa migración aún no se ha corrido o no hay red: las mismas 19 claves que ya había.
//  `REGIMENES` es un arreglo vivo [clave, descripción] (solo activos): `cargarRegimenes()` lo
//  reemplaza en sitio, así que quien lo importó lo ve actualizado.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

export const REGIMENES = [
    ['601', 'General de Ley Personas Morales'],
    ['603', 'Personas Morales con Fines no Lucrativos'],
    ['605', 'Sueldos y Salarios e Ingresos Asimilados a Salarios'],
    ['606', 'Arrendamiento'],
    ['607', 'Régimen de Enajenación o Adquisición de Bienes'],
    ['608', 'Demás ingresos'],
    ['610', 'Residentes en el Extranjero sin Establecimiento Permanente en México'],
    ['611', 'Ingresos por Dividendos (socios y accionistas)'],
    ['612', 'Personas Físicas con Actividades Empresariales y Profesionales'],
    ['614', 'Ingresos por intereses'],
    ['615', 'Régimen de los ingresos por obtención de premios'],
    ['616', 'Sin obligaciones fiscales'],
    ['620', 'Sociedades Cooperativas de Producción'],
    ['621', 'Incorporación Fiscal'],
    ['622', 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras'],
    ['623', 'Opcional para Grupos de Sociedades'],
    ['624', 'Coordinados'],
    ['625', 'Régimen de las Actividades Empresariales con ingresos a través de Plataformas Tecnológicas'],
    ['626', 'Régimen Simplificado de Confianza (RESICO)'],
];

// Retirados (activo = false): no se ofrecen para elegir, pero se conservan para mostrar el de un registro viejo.
const INACTIVOS = [];

/** Lee la tabla y actualiza REGIMENES. Si la tabla no existe / está vacía / no hay red, deja el respaldo. */
export async function cargarRegimenes() {
    try {
        const { data, error } = await supabaseClient.from('c_regimen_fiscal').select('clave, descripcion, activo').order('clave');
        if (error || !data || !data.length) return false;
        REGIMENES.splice(0, REGIMENES.length, ...data.filter((r) => r.activo !== false).map((r) => [r.clave, r.descripcion]));
        INACTIVOS.splice(0, INACTIVOS.length, ...data.filter((r) => r.activo === false).map((r) => [r.clave, r.descripcion]));
        return true;
    } catch (_) {
        return false;
    }
}

/**
 * <option>s del select de régimen. `valor` = el que ya trae el registro (se deja seleccionado);
 * `predeterminado` = el que se marca si no hay valor. Los retirados van ocultos y deshabilitados:
 * no se pueden elegir de nuevo, pero un registro que ya los tenga los sigue mostrando al editarse.
 */
export function opcionesRegimen({ valor = '', predeterminado = '', vacio = '— régimen —' } = {}) {
    const elegido = valor || predeterminado;
    const vivo = REGIMENES.map(([k, v]) => `<option value="${esc(k)}"${k === elegido ? ' selected' : ''}>${esc(k)} · ${esc(v)}</option>`);
    const retirados = INACTIVOS.map(([k, v]) => `<option value="${esc(k)}" hidden disabled${k === elegido ? ' selected' : ''}>${esc(k)} · ${esc(v)} (retirado)</option>`);
    return `<option value="">${esc(vacio)}</option>` + vivo.join('') + retirados.join('');
}
