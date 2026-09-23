// =====================================================================
//  Regla única: ¿una póliza cuenta para saldos? (Balanza, Estado de
//  resultados, Balance, Auxiliar de cuentas, Auxiliar de inventarios).
//
//  Cancelar = contra-asiento: cancelar_poliza crea una póliza de reverso
//  (origen_tabla = 'polizas', origen_id = la original) y marca la original
//  'cancelada'. Si los reportes quitan la original pero suman el reverso,
//  el importe se resta DOS veces (así se descuadró 115.01 con OC-787934 y
//  OC-185388). Por eso:
//    contabilizada                          -> cuenta
//    cancelada CON reverso contabilizado    -> cuenta (el reverso la neutraliza)
//    cancelada sin reverso / borrador       -> no cuenta
//  Misma regla que public.poliza_en_saldo() en
//  sql/2026-09-23_candados_cuadre_inventario.sql.
// =====================================================================
import { supabaseClient } from './supabase.js';

// Estatus a pedir en los queries; después se filtra con enSaldo().
export const ESTATUS_CONSULTA = ['contabilizada', 'cancelada'];

/** Map id de póliza original -> id de su póliza de reverso (solo reversos contabilizados). */
export async function traerReversos() {
    const mapa = new Map();
    for (let desdeFila = 0; ; desdeFila += 1000) {
        const { data, error } = await supabaseClient.from('polizas')
            .select('id, origen_id')
            .eq('origen_tabla', 'polizas')
            .eq('estatus', 'contabilizada')
            .not('origen_id', 'is', null)
            .order('id', { ascending: true })
            .range(desdeFila, desdeFila + 999);
        if (error) throw error;
        (data || []).forEach((r) => mapa.set(Number(r.origen_id), Number(r.id)));
        if (!data || data.length < 1000) break;
    }
    return mapa;
}

/** `pol` = { id, estatus }; `reversos` = resultado de traerReversos(). */
export function enSaldo(pol, reversos) {
    if (!pol) return false;
    if (pol.estatus === 'contabilizada') return true;
    return pol.estatus === 'cancelada' && reversos.has(Number(pol.id));
}
