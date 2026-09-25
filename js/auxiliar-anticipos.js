// =====================================================================
//  Auxiliar de Anticipos a proveedores — pestaña de Reportes contables.
//
//  Trazabilidad completa de cada anticipo pagado a una orden de compra
//  ANTES de recibir la mercancía (js/ordenes-compra.js, botón "💰
//  Anticipo"; RPC pagar_anticipo_oc()): a qué proveedor y OC se pagó, su
//  póliza, cuánto se ha aplicado ya contra recepciones (y contra cuál
//  documento) y cuánto sigue disponible.
//
//  "Cuadre contra la balanza": la cuenta 109.01 Anticipos a proveedores
//  solo la mueven pagar_anticipo_oc() (cargo) y contabilizar_compra()
//  (abono al aplicarse) — ambas dejan su rastro en
//  pagos_proveedor_aplicaciones, así que la suma de "disponible" de todos
//  los anticipos vigentes DEBE ser igual al saldo de 109.01 en la
//  balanza a la fecha "Hasta". Si no cuadra, algo tocó esa cuenta por
//  fuera de este flujo (póliza manual, ajuste). Misma regla de saldos que
//  el resto de Reportes contables (js/polizas-saldo.js): una póliza
//  cancelada CON su reverso sigue contando (se neutralizan).
//
//  Requiere sql/2026-10-27_anticipo_proveedores.sql. Sin ella, la
//  pestaña avisa y no revienta el resto de Reportes contables.
//
//  Todo va en una sola tabla dentro de #rcTabla para que "Imprimir" y
//  "Exportar CSV" de Reportes contables funcionen sin cambios.
// =====================================================================
import { supabaseClient } from './supabase.js';
import { convertirEnBuscador } from './buscador-select.js';
import { ESTATUS_CONSULTA, traerReversos, enSaldo } from './polizas-saldo.js';

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fmt = (n) => {
    const v = Math.round((Number(n) || 0) * 100) / 100;
    const s = Math.abs(v).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return v < 0 ? `(${s})` : s;
};

// Mismo patrón de enlaces que el resto de los Auxiliares (regla de CLAUDE.md).
const linkDoc = (id, texto) => id
    ? `<button type="button" onclick="window.abrirDetalleDocumentoGlobal(${Number(id)})" class="text-sky-300 hover:text-sky-200 hover:underline cursor-pointer font-mono" title="Abrir el documento">${esc(texto)}</button>`
    : esc(texto);
const linkPoliza = (id) => id
    ? `<button type="button" onclick="window.rcVerPoliza(${Number(id)}); const m=document.getElementById('rcModalPoliza'); if(m) m.style.zIndex=70;" data-pol-id="${Number(id)}" class="text-sky-300 hover:text-sky-200 hover:underline cursor-pointer font-mono" title="Abrir la póliza">póliza…</button>`
    : '—';
const linkOc = (id, texto) => id
    ? `<button type="button" onclick="window.verDetalleOC && window.verDetalleOC(${Number(id)})" class="text-emerald-300 hover:text-emerald-200 hover:underline cursor-pointer font-mono" title="Abrir la orden de compra">${esc(texto)}</button>`
    : esc(texto);

let proveedoresCache = null;

async function cargarProveedores() {
    if (proveedoresCache) return proveedoresCache;
    const { data, error } = await supabaseClient.from('proveedores').select('id, nombre').order('nombre');
    if (error) throw error;
    proveedoresCache = data || [];
    return proveedoresCache;
}

/** Arma (una vez) los filtros propios de la pestaña dentro de `caja`. */
export async function prepararFiltrosAuxAnt(caja, alCambiar) {
    if (!caja || caja.dataset.listo === '1') return;
    caja.dataset.listo = '1';
    let proveedores = [];
    try { proveedores = await cargarProveedores(); } catch (_) { /* se avisa al generar */ }
    caja.innerHTML = `
        <div><label class="block text-[11px] text-slate-400 mb-1">Proveedor</label>
            <select id="aaProveedor" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 max-w-[16rem]">
                <option value="">Todos</option>
                ${proveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('')}
            </select></div>
        <label class="flex items-center gap-1.5 text-[11px] text-slate-300 pb-2 cursor-pointer">
            <input type="checkbox" id="aaSoloDisp" class="accent-sky-500"> Solo con saldo disponible</label>`;
    convertirEnBuscador(document.getElementById('aaProveedor'));
    caja.querySelectorAll('select, input').forEach((el) => el.addEventListener('change', alCambiar));
}

/** Genera el reporte y lo pinta en `res` (el contenedor #rcResultado). */
export async function generarAuxAnticipos(res, hasta) {
    if (!hasta) { alert('Indica la fecha "Hasta".'); return; }
    res.innerHTML = '<p class="text-slate-500">Consultando anticipos y pólizas...</p>';
    try {
        const proveedorSel = document.getElementById('aaProveedor')?.value || '';
        const soloDisp = document.getElementById('aaSoloDisp')?.checked ?? false;

        const { data: anticipos, error: eAnt } = await supabaseClient
            .from('pagos_proveedor_aplicaciones')
            .select(`id, monto, pago_id, orden_compra_id,
                      pagos_proveedor ( id, fecha, poliza_id, estatus, referencia, proveedor_id, proveedores ( nombre ) ),
                      ordenes_compra ( id, folio )`)
            .eq('tipo', 'anticipo_oc')
            .lte('pagos_proveedor.fecha', hasta)
            .order('id', { ascending: true });
        if (eAnt) throw eAnt;
        const filas = (anticipos || []).filter((a) => a.pagos_proveedor); // el filtro por fecha en el join puede dejar null

        if (!filas.length) {
            res.innerHTML = '<p class="text-slate-400">Sin anticipos pagados hasta esa fecha. (Si esperabas ver alguno, revisa que <span class="font-mono">sql/2026-10-27_anticipo_proveedores.sql</span> ya esté corrida.)</p>';
            return;
        }

        // Cuánto se ha aplicado de cada anticipo, y contra qué documento(s).
        const idsAnt = filas.map((a) => a.id);
        const { data: apls } = await supabaseClient.from('pagos_proveedor_aplicaciones')
            .select('aplicacion_origen_id, monto, documento_id, documentos ( folio )')
            .eq('tipo', 'anticipo_aplicado').in('aplicacion_origen_id', idsAnt);
        const aplicadoPor = new Map();     // anticipo id -> { total, detalle: [{folio, monto}] }
        (apls || []).forEach((a) => {
            if (!aplicadoPor.has(a.aplicacion_origen_id)) aplicadoPor.set(a.aplicacion_origen_id, { total: 0, detalle: [] });
            const g = aplicadoPor.get(a.aplicacion_origen_id);
            g.total += Number(a.monto || 0);
            g.detalle.push({ folio: a.documentos?.folio || ('#' + a.documento_id), monto: Number(a.monto || 0), docId: a.documento_id });
        });

        let filasVista = filas.map((a) => {
            const pago = a.pagos_proveedor;
            const monto = Number(a.monto || 0);
            const ap = aplicadoPor.get(a.id) || { total: 0, detalle: [] };
            const disponible = Math.round((monto - ap.total) * 100) / 100;
            return {
                proveedorId: pago.proveedor_id, proveedor: pago.proveedores?.nombre || '(sin proveedor)',
                ocId: a.orden_compra_id, ocFolio: a.ordenes_compra?.folio || ('#' + a.orden_compra_id),
                fecha: pago.fecha, polizaId: pago.poliza_id, referencia: pago.referencia,
                estatus: pago.estatus, monto, aplicado: ap.total, detalleAplicado: ap.detalle,
                disponible: pago.estatus === 'cancelado' ? 0 : disponible,
            };
        });
        if (proveedorSel) filasVista = filasVista.filter((f) => String(f.proveedorId) === proveedorSel);
        if (soloDisp) filasVista = filasVista.filter((f) => f.disponible > 0.005);
        if (!filasVista.length) { res.innerHTML = '<p class="text-slate-400">Sin anticipos con esos filtros.</p>'; return; }

        filasVista.sort((a, b) => (a.proveedor.localeCompare(b.proveedor, 'es') || (a.fecha < b.fecha ? -1 : 1)));

        // Cuadre: suma de lo disponible (vigente) vs. saldo real de 109.01 en la balanza a "Hasta".
        let cuadre = null;
        try {
            const { data: ctas, error: eCta } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre, naturaleza').eq('codigo', '109.01').limit(1);
            if (eCta) throw eCta;
            const cta109 = ctas?.[0];
            if (cta109) {
                const reversos = await traerReversos();
                const { data: movs109, error: eMov } = await supabaseClient.from('poliza_movimientos')
                    .select('cargo, abono, polizas!inner(id, fecha, estatus)')
                    .eq('cuenta_id', cta109.id).in('polizas.estatus', ESTATUS_CONSULTA).lte('polizas.fecha', hasta);
                if (eMov) throw eMov;
                const signo = cta109.naturaleza === 'A' ? -1 : 1;
                const saldoBalanza = (movs109 || []).filter((m) => enSaldo(m.polizas, reversos))
                    .reduce((s, m) => s + signo * ((Number(m.cargo) || 0) - (Number(m.abono) || 0)), 0);
                // Todos los anticipos vigentes (no cancelados), sin filtro de proveedor: el cuadre es contra TODA la cuenta.
                const disponibleTotal = filas.reduce((s, a) => {
                    if (a.pagos_proveedor.estatus === 'cancelado') return s;
                    const ap = aplicadoPor.get(a.id) || { total: 0 };
                    return s + (Number(a.monto || 0) - ap.total);
                }, 0);
                cuadre = { cta: cta109, saldoBalanza, disponibleTotal: Math.round(disponibleTotal * 100) / 100, dif: Math.round((saldoBalanza - disponibleTotal) * 100) / 100 };
            }
        } catch (_) { /* si no existe la cuenta o falta la migración, se omite el cuadre sin romper la lista */ }

        pintar(res, { hasta, filasVista, cuadre });
    } catch (err) {
        res.innerHTML = `<p class="text-rose-400 text-xs">No se pudo generar. ¿Corriste <span class="font-mono">sql/2026-10-27_anticipo_proveedores.sql</span>?<br>${esc(err.message || err)}</p>`;
    }
}

function pintar(res, { hasta, filasVista, cuadre }) {
    const td = 'p-1.5';
    const tdR = 'p-1.5 text-right font-mono';
    let tMonto = 0, tAplicado = 0, tDisp = 0;
    let proveedorActual = null;
    let cuerpo = '';
    for (const f of filasVista) {
        if (f.proveedor !== proveedorActual) {
            proveedorActual = f.proveedor;
            cuerpo += `<tr class="bg-slate-800/60"><td class="p-2 font-bold text-sky-400" colspan="8">${esc(proveedorActual)}</td></tr>`;
        }
        tMonto += f.monto; tAplicado += f.aplicado; tDisp += f.disponible;
        const estatusBadge = f.estatus === 'cancelado'
            ? '<span class="text-[10px] text-rose-400 font-semibold">CANCELADO</span>'
            : f.disponible > 0.005 ? '<span class="text-[10px] text-amber-300 font-semibold">DISPONIBLE</span>' : '<span class="text-[10px] text-emerald-400 font-semibold">APLICADO</span>';
        cuerpo += `
        <tr class="border-b border-slate-900/60 text-slate-300 ${f.estatus === 'cancelado' ? 'opacity-60' : ''}">
            <td class="${td} font-mono text-[11px]">${f.fecha || ''}</td>
            <td class="${td}">${linkOc(f.ocId, f.ocFolio)}</td>
            <td class="${td} font-mono text-[11px]">${linkPoliza(f.polizaId)}</td>
            <td class="${td} text-[11px] text-slate-400">${esc(f.referencia || '')}</td>
            <td class="${tdR}">${fmt(f.monto)}</td>
            <td class="${tdR}">${f.aplicado > 0.005 ? fmt(f.aplicado) : ''}${f.detalleAplicado.length ? `<div class="text-[10px] text-slate-500 font-sans">${f.detalleAplicado.map((d) => `${linkDoc(d.docId, d.folio)} ${fmt(d.monto)}`).join(' · ')}</div>` : ''}</td>
            <td class="${tdR} ${f.disponible > 0.005 ? 'text-amber-300' : ''}">${f.disponible > 0.005 ? fmt(f.disponible) : (f.estatus === 'cancelado' ? '—' : '0.00')}</td>
            <td class="p-1.5">${estatusBadge}</td>
        </tr>`;
    }

    let cuadreHtml = '';
    if (cuadre) {
        const ok = Math.abs(cuadre.dif) < 0.5;
        cuadreHtml = `
        <tr><td colspan="8" class="pt-4"></td></tr>
        <tr class="bg-slate-800/60"><td class="p-2 font-bold ${ok ? 'text-emerald-400' : 'text-amber-400'}" colspan="8">${ok ? '✅' : '⚠️'} Cuadre ${esc(cuadre.cta.codigo)} · ${esc(cuadre.cta.nombre)} al ${esc(hasta)}</td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="7">Suma de anticipos vigentes (disponible, todos los proveedores)</td><td class="${tdR}">${fmt(cuadre.disponibleTotal)}</td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="7">Saldo de la cuenta en la balanza (contabilizadas + canceladas con su reverso)</td><td class="${tdR}">${fmt(cuadre.saldoBalanza)}</td></tr>
        <tr class="font-semibold ${ok ? 'text-emerald-300' : 'text-amber-300'}"><td class="${td}" colspan="7">Diferencia (balanza − anticipos vigentes)</td><td class="${tdR}">${fmt(cuadre.dif)}</td></tr>
        ${!ok ? `<tr><td class="${td} text-[11px] text-slate-500 italic" colspan="8">Si no cuadra, revisa pólizas manuales que hayan tocado 109.01 fuera de "💰 Anticipo" (Órdenes de compra) o la recepción que lo aplica.</td></tr>` : ''}`;
    }

    res.innerHTML = `
        <div class="flex flex-wrap gap-4 text-xs text-slate-400 mb-3">
            <span>Al: <b class="text-slate-200">${esc(hasta)}</b></span>
            <span>Anticipos: <b class="text-slate-200">${filasVista.length}</b></span>
            <span>Pagado: <b class="text-slate-200">$${fmt(tMonto)}</b></span>
            <span>Aplicado: <b class="text-emerald-300">$${fmt(tAplicado)}</b></span>
            <span>Disponible: <b class="text-amber-300">$${fmt(tDisp)}</b></span>
        </div>
        <div id="rcTabla" class="overflow-x-auto">
        <table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
                <th class="p-1.5">Fecha pago</th><th class="p-1.5">Orden de compra</th><th class="p-1.5">Póliza</th><th class="p-1.5">Referencia</th>
                <th class="p-1.5 text-right">Pagado</th><th class="p-1.5 text-right">Aplicado (a documento)</th><th class="p-1.5 text-right">Disponible</th><th class="p-1.5">Estatus</th>
            </tr></thead>
            <tbody>${cuerpo}${cuadreHtml}</tbody>
        </table>
        <p class="text-[10px] text-slate-500 mt-2">"Disponible" es lo que aún puede aplicarse a una recepción futura de esa misma orden de compra (o cancelarse, si no se ha aplicado nada). El cuadre suma TODOS los proveedores aunque el filtro muestre solo uno.</p>
        </div>`;
}
