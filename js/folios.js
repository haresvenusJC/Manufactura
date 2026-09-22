import { supabaseClient } from './supabase.js';

// =====================================================================
//  Folios consecutivos. Los asigna la base (contador por serie:
//  OC-000001, OC-000002...), así dos personas a la vez nunca reciben el
//  mismo. Requiere sql/2026-10-21_folios_consecutivos.sql; si aún no está
//  corrida, se usa el folio de respaldo de siempre (hora en milisegundos)
//  para que nada se detenga.
// =====================================================================

// Serie según el tipo de salida de inventario.
export const SERIE_SALIDA = { salida_venta: 'VTA', merma: 'MER', salida: 'SAL', ajuste: 'AJU' };

const respaldo = (serie) => `${serie}-${Date.now().toString().slice(-6)}`;

/** Asigna y AVANZA el contador: úsalo solo cuando el folio se va a guardar de verdad. */
export async function siguienteFolio(serie) {
    try {
        const { data, error } = await supabaseClient.rpc('siguiente_folio', { p_serie: serie });
        if (error || !data) throw error || new Error('sin folio');
        return data;
    } catch (_) {
        return respaldo(serie);
    }
}

/** Solo muestra cuál sería el siguiente (no avanza): para sugerirlo en un campo. null si aún no está la migración. */
export async function proximoFolio(serie) {
    try {
        const { data, error } = await supabaseClient.rpc('proximo_folio', { p_serie: serie });
        return error ? null : data;
    } catch (_) {
        return null;
    }
}
