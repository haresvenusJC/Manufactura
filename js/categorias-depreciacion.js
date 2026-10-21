import { supabaseClient } from './supabase.js';

// =====================================================================
// Categorías de depreciación fiscal (LISR arts. 33-36) — tabla c_categoria_depreciacion.
// Las usan Alta de artículo (tipo Activo fijo), la alta rápida de la requisición y Activos fijos.
// Editable en Configuración → Tablas → "SAT · Depreciación fiscal"; requiere
// sql/2026-10-22_categorias_depreciacion_fiscal.sql (sin ella, las listas quedan vacías y todo sigue como antes).
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fmtPct = (n) => `${Number(n)}%`;
const fmtMoneda = (n) => Number(n).toLocaleString('es-MX', { style: 'currency', currency: 'MXN', maximumFractionDigits: 0 });

/** Todas las filas activas, ordenadas. Devuelve [] si la migración no está corrida. */
export async function cargarCategoriasDep() {
    try {
        const { data, error } = await supabaseClient.from('c_categoria_depreciacion')
            .select('id, grupo, articulo, categoria, pct_anual, tope_deducible, vigente_desde, vigente_hasta, notas')
            .eq('activo', true).order('orden').order('vigente_desde', { ascending: false });
        return error ? [] : (data || []);
    } catch (_) { return []; }
}

/**
 * De cada categoría deja solo la fila que rige en `anio` (la de mayor vigente_desde ≤ año y no vencida).
 * Si una categoría aún no empieza ese año, se queda con su fila más antigua (mejor ver algo que nada).
 */
export function vigentesEn(filas, anio) {
    const porClave = new Map();
    for (const f of filas) {
        const k = `${f.articulo}|${f.categoria}`;
        const rige = f.vigente_desde <= anio && (f.vigente_hasta == null || f.vigente_hasta >= anio);
        const actual = porClave.get(k);
        if (rige && (!actual || !actual.rige || f.vigente_desde > actual.fila.vigente_desde)) porClave.set(k, { fila: f, rige: true });
        else if (!actual) porClave.set(k, { fila: f, rige: false });
        else if (!actual.rige && !rige && f.vigente_desde < actual.fila.vigente_desde) porClave.set(k, { fila: f, rige: false });
    }
    return [...porClave.values()].map((v) => v.fila);
}

/** Meses de vida útil que corresponden a un % anual (10 % → 120, 25 % → 48, 30 % → 40). */
export const vidaMesesDePct = (pct) => (Number(pct) > 0 ? Math.round(1200 / Number(pct)) : 0);

/** <option> agrupadas (depreciación / amortización) con % y fundamento. `seleccionada` = id aunque ya no rija. */
export function opcionesCategoriaDep(filas, anio, seleccionada = null) {
    let lista = vigentesEn(filas, anio);
    if (seleccionada != null && !lista.some((f) => f.id === Number(seleccionada))) {
        const extra = filas.find((f) => f.id === Number(seleccionada));
        if (extra) lista = [...lista, extra];
    }
    const grupo = (g, titulo) => {
        const fs = lista.filter((f) => f.grupo === g);
        return fs.length ? `<optgroup label="${titulo}">${fs.map((f) => `<option value="${f.id}">${esc(f.categoria)} · ${fmtPct(f.pct_anual)} (${esc(f.articulo)})</option>`).join('')}</optgroup>` : '';
    };
    return '<option value="">Sin categoría fiscal</option>' + grupo('depreciacion', 'Depreciación (arts. 34-35)') + grupo('amortizacion', 'Amortización (art. 33)');
}

/** Texto de apoyo al elegir una categoría. */
export function textoCategoriaDep(fila) {
    if (!fila) return '';
    const vigencia = fila.vigente_hasta ? `${fila.vigente_desde}–${fila.vigente_hasta}` : `desde ${fila.vigente_desde}`;
    const meses = vidaMesesDePct(fila.pct_anual);
    return `${esc(fila.articulo)} · máximo ${fmtPct(fila.pct_anual)} anual (≈ ${meses} meses de vida útil) · vigente ${vigencia}`
        + (fila.tope_deducible ? ` · <b>tope deducible ${fmtMoneda(fila.tope_deducible)}</b>` : '')
        + (fila.notas ? ` · ${esc(fila.notas)}` : '');
}
