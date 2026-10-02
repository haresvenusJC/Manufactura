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
let cuentasCache = null;
let ultimoRes = null;
let ultimoHasta = null;

async function cargarCuentas() {
    if (cuentasCache) return cuentasCache;
    const { data, error } = await supabaseClient.from('cuentas_contables')
        .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
    if (error) throw error;
    cuentasCache = data || [];
    return cuentasCache;
}

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
    ultimoRes = res; ultimoHasta = hasta;
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

        // Resoluciones (reasignado/reembolsado/baja de saldo que ya no se va a
        // aplicar a una recepción de ESA oc) — requiere sql/2026-10-29_
        // resolucion_anticipo_oc.sql; sin ella, no se muestra el ajuste ni la
        // sub-tabla, pero el resto del reporte sigue funcionando igual que antes.
        let resoluciones = [];
        try {
            const { data: res2, error: eRes } = await supabaseClient
                .from('anticipo_oc_resoluciones')
                .select(`id, tipo, monto, fecha, notas, poliza_id,
                          ordenes_compra!anticipo_oc_resoluciones_orden_compra_id_fkey ( id, folio, proveedor_id, proveedores ( nombre ) ),
                          destino:ordenes_compra!anticipo_oc_resoluciones_oc_destino_id_fkey ( id, folio )`)
                .lte('fecha', hasta)
                .order('id', { ascending: false });
            if (eRes) throw eRes;
            resoluciones = res2 || [];
        } catch (_) { /* migración no corrida: se omite */ }

        if (resoluciones.length) {
            // Neto por OC: positivo = hay que restarle a sus filas (salió de ahí),
            // negativo = hay que sumarle (le entró reasignado de otra OC). FIFO
            // por fila en el mismo orden ascendente de id que ya usa
            // contabilizar_compra al consumir anticipo_oc.
            const netoPorOc = new Map();
            resoluciones.forEach((r) => {
                const ocOrigenId = r.ordenes_compra?.id;
                if (ocOrigenId) netoPorOc.set(ocOrigenId, (netoPorOc.get(ocOrigenId) || 0) + Number(r.monto || 0));
                if (r.tipo === 'reasignado' && r.destino?.id) netoPorOc.set(r.destino.id, (netoPorOc.get(r.destino.id) || 0) - Number(r.monto || 0));
            });
            const pendienteResta = new Map([...netoPorOc].filter(([, v]) => v > 0));
            filasVista.forEach((f) => {
                const falta = pendienteResta.get(f.ocId) || 0;
                if (falta > 0 && f.disponible > 0) {
                    const take = Math.min(falta, f.disponible);
                    f.disponible = Math.round((f.disponible - take) * 100) / 100;
                    pendienteResta.set(f.ocId, Math.round((falta - take) * 100) / 100);
                }
            });
            const entrantePorOc = new Map([...netoPorOc].filter(([, v]) => v < 0).map(([k, v]) => [k, -v]));
            if (entrantePorOc.size) {
                const ultimaFilaPorOc = new Map();
                filasVista.forEach((f) => { if (entrantePorOc.has(f.ocId)) ultimaFilaPorOc.set(f.ocId, f); });
                ultimaFilaPorOc.forEach((f, ocId) => { f.disponible = Math.round((f.disponible + entrantePorOc.get(ocId)) * 100) / 100; });
            }
        }

        if (proveedorSel) filasVista = filasVista.filter((f) => String(f.proveedorId) === proveedorSel);
        if (soloDisp) filasVista = filasVista.filter((f) => f.disponible > 0.005);
        const resolucionesVista = resoluciones.filter((r) => !proveedorSel || String(r.ordenes_compra?.proveedor_id || '') === proveedorSel);
        if (!filasVista.length && !resolucionesVista.length) { res.innerHTML = '<p class="text-slate-400">Sin anticipos con esos filtros.</p>'; return; }

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
                let disponibleTotal = filas.reduce((s, a) => {
                    if (a.pagos_proveedor.estatus === 'cancelado') return s;
                    const ap = aplicadoPor.get(a.id) || { total: 0 };
                    return s + (Number(a.monto || 0) - ap.total);
                }, 0);
                // 'reasignado' no toca 109.01 (se neutraliza entre origen y destino); solo
                // 'reembolsado' y 'baja' de verdad abonan la cuenta — sí hay que restarlos.
                disponibleTotal -= resoluciones.filter((r) => r.tipo !== 'reasignado').reduce((s, r) => s + Number(r.monto || 0), 0);
                cuadre = { cta: cta109, saldoBalanza, disponibleTotal: Math.round(disponibleTotal * 100) / 100, dif: Math.round((saldoBalanza - disponibleTotal) * 100) / 100 };
            }
        } catch (_) { /* si no existe la cuenta o falta la migración, se omite el cuadre sin romper la lista */ }

        pintar(res, { hasta, filasVista, cuadre, resoluciones: resolucionesVista });
    } catch (err) {
        res.innerHTML = `<p class="text-rose-400 text-xs">No se pudo generar. ¿Corriste <span class="font-mono">sql/2026-10-27_anticipo_proveedores.sql</span>?<br>${esc(err.message || err)}</p>`;
    }
}

function pintar(res, { hasta, filasVista, cuadre, resoluciones = [] }) {
    const td = 'p-1.5';
    const tdR = 'p-1.5 text-right font-mono';
    let tMonto = 0, tAplicado = 0, tDisp = 0;
    let proveedorActual = null;
    let cuerpo = '';
    const ocConBotonResolver = new Set();
    for (const f of filasVista) {
        if (f.proveedor !== proveedorActual) {
            proveedorActual = f.proveedor;
            cuerpo += `<tr class="bg-slate-800/60"><td class="p-2 font-bold text-sky-400" colspan="9">${esc(proveedorActual)}</td></tr>`;
        }
        tMonto += f.monto; tAplicado += f.aplicado; tDisp += f.disponible;
        const estatusBadge = f.estatus === 'cancelado'
            ? '<span class="text-[10px] text-rose-400 font-semibold">CANCELADO</span>'
            : f.disponible > 0.005 ? '<span class="text-[10px] text-amber-300 font-semibold">DISPONIBLE</span>' : '<span class="text-[10px] text-emerald-400 font-semibold">APLICADO</span>';
        const puedeResolver = f.estatus !== 'cancelado' && f.disponible > 0.005 && !ocConBotonResolver.has(f.ocId);
        if (puedeResolver) ocConBotonResolver.add(f.ocId);
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
            <td class="p-1.5">${puedeResolver ? `<button type="button" onclick="window.aaResolverAnticipo(${f.ocId}, '${esc(f.ocFolio)}')" class="text-[10px] bg-amber-700 hover:bg-amber-600 text-white px-2 py-1 rounded whitespace-nowrap">Resolver saldo</button>` : ''}</td>
        </tr>`;
    }

    let cuadreHtml = '';
    if (cuadre) {
        const ok = Math.abs(cuadre.dif) < 0.5;
        cuadreHtml = `
        <tr><td colspan="9" class="pt-4"></td></tr>
        <tr class="bg-slate-800/60"><td class="p-2 font-bold ${ok ? 'text-emerald-400' : 'text-amber-400'}" colspan="9">${ok ? '✅' : '⚠️'} Cuadre ${esc(cuadre.cta.codigo)} · ${esc(cuadre.cta.nombre)} al ${esc(hasta)}</td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="8">Suma de anticipos vigentes (disponible, todos los proveedores)</td><td class="${tdR}">${fmt(cuadre.disponibleTotal)}</td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="8">Saldo de la cuenta en la balanza (contabilizadas + canceladas con su reverso)</td><td class="${tdR}">${fmt(cuadre.saldoBalanza)}</td></tr>
        <tr class="font-semibold ${ok ? 'text-emerald-300' : 'text-amber-300'}"><td class="${td}" colspan="8">Diferencia (balanza − anticipos vigentes)</td><td class="${tdR}">${fmt(cuadre.dif)}</td></tr>
        ${!ok ? `<tr><td class="${td} text-[11px] text-slate-500 italic" colspan="9">Si no cuadra, revisa pólizas manuales que hayan tocado 109.01 fuera de "💰 Anticipo" (Órdenes de compra), la recepción que lo aplica, o un "Resolver saldo" (reembolso/baja).</td></tr>` : ''}`;
    }

    const tipoLabel = { reasignado: 'Reasignado', reembolsado: 'Reembolsado', baja: 'Dado de baja' };
    const tipoColor = { reasignado: 'text-sky-300', reembolsado: 'text-emerald-300', baja: 'text-rose-300' };
    const resolucionesHtml = resoluciones.length ? `
        <h4 class="text-sm font-semibold text-slate-300 mt-5 mb-2">Resoluciones de saldo (anticipos que ya no se aplicaron a una recepción de esa OC)</h4>
        <div class="overflow-x-auto">
        <table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
                <th class="p-1.5">Fecha</th><th class="p-1.5">Tipo</th><th class="p-1.5">OC origen</th><th class="p-1.5">Destino</th>
                <th class="p-1.5 text-right">Monto</th><th class="p-1.5">Póliza</th><th class="p-1.5">Notas</th>
            </tr></thead>
            <tbody>${resoluciones.map((r) => `
                <tr class="border-b border-slate-900/60 text-slate-300">
                    <td class="${td} font-mono text-[11px]">${r.fecha || ''}</td>
                    <td class="${td} font-semibold ${tipoColor[r.tipo] || ''}">${esc(tipoLabel[r.tipo] || r.tipo)}</td>
                    <td class="${td}">${linkOc(r.ordenes_compra?.id, r.ordenes_compra?.folio || ('#' + r.ordenes_compra?.id))} <span class="text-[10px] text-slate-500">${esc(r.ordenes_compra?.proveedores?.nombre || '')}</span></td>
                    <td class="${td}">${r.tipo === 'reasignado' ? linkOc(r.destino?.id, r.destino?.folio || ('#' + r.destino?.id)) : '<span class="text-slate-500">—</span>'}</td>
                    <td class="${tdR}">${fmt(r.monto)}</td>
                    <td class="${td} font-mono text-[11px]">${linkPoliza(r.poliza_id)}</td>
                    <td class="${td} text-[11px] text-slate-400">${esc(r.notas || '')}</td>
                </tr>`).join('')}
            </tbody>
        </table>
        </div>` : '';

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
                <th class="p-1.5 text-right">Pagado</th><th class="p-1.5 text-right">Aplicado (a documento)</th><th class="p-1.5 text-right">Disponible</th><th class="p-1.5">Estatus</th><th class="p-1.5"></th>
            </tr></thead>
            <tbody>${cuerpo}${cuadreHtml}</tbody>
        </table>
        <p class="text-[10px] text-slate-500 mt-2">"Disponible" es lo que aún puede aplicarse a una recepción futura de esa misma orden de compra, reasignarse a otra, reembolsarse o darse de baja ("Resolver saldo"). El cuadre suma TODOS los proveedores aunque el filtro muestre solo uno.</p>
        ${resolucionesHtml}
        </div>`;
}

// =====================================================================
//  "Resolver saldo" — a petición del usuario: cuando una OC ya no se va
//  a completar y le queda anticipo disponible (dinero que Tesorería ya
//  pagó), 3 escenarios reales, cada uno con su propio tratamiento
//  contable (NIF: dinero recuperable sigue siendo activo, dinero perdido
//  es un gasto, no se puede dejar "disponible" para siempre sin más):
//   - reasignado  : el proveedor deja aplicarlo a OTRA compra suya — sin
//                   póliza, solo se reetiqueta a qué OC pertenece.
//   - reembolsado : el proveedor regresa el efectivo — póliza Ingreso.
//   - baja        : no hay nada que recuperar — póliza Diario a gasto.
//  RPC resolver_anticipo_oc() (sql/2026-10-29_resolucion_anticipo_oc.sql).
// =====================================================================
function aaMostrarModal(html) {
    let wrap = document.getElementById('aaModalWrap');
    if (!wrap) {
        wrap = document.createElement('div');
        wrap.id = 'aaModalWrap';
        wrap.className = 'fixed inset-0 bg-slate-950/40 flex items-center justify-center z-50 p-4';
        document.body.appendChild(wrap);
    }
    wrap.innerHTML = html;
}
window.aaCerrarModal = () => { document.getElementById('aaModalWrap')?.remove(); };

window.aaResolverAnticipo = async (ocId, ocFolio) => {
    ocId = Number(ocId);
    let oc, disponible = 0, otrasOcs = [], cuentas = [];
    try {
        const [{ data: o, error: eOc }, { data: ant }, ctas] = await Promise.all([
            supabaseClient.from('ordenes_compra').select('id, folio, proveedor_id, proveedores ( nombre )').eq('id', ocId).single(),
            supabaseClient.from('v_anticipos_oc').select('disponible').eq('orden_compra_id', ocId).maybeSingle(),
            cargarCuentas(),
        ]);
        if (eOc) throw eOc;
        oc = o;
        disponible = Number(ant?.disponible) || 0;
        cuentas = ctas;
        const { data: otras } = await supabaseClient.from('ordenes_compra')
            .select('id, folio').eq('proveedor_id', oc.proveedor_id).in('estatus', ['abierta', 'recibida_parcial']).neq('id', ocId).order('id', { ascending: false });
        otrasOcs = otras || [];
    } catch (e) {
        alert('No se pudo cargar la información de la orden de compra: ' + (e.message || e));
        return;
    }
    if (disponible <= 0.005) { alert('Esta orden de compra ya no tiene saldo de anticipo disponible.'); return; }

    const optOc = otrasOcs.length
        ? '<option value="">— elige la OC destino —</option>' + otrasOcs.map((o2) => `<option value="${o2.id}">${esc(o2.folio || '#' + o2.id)}</option>`).join('')
        : '<option value="">— este proveedor no tiene otra OC abierta —</option>';
    const optCta = '<option value="">— elige una cuenta —</option>' + cuentas.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    aaMostrarModal(`
      <div class="bg-slate-900 border border-slate-700 rounded-2xl p-4 max-w-md w-full">
        <h3 class="text-base font-bold text-slate-100 mb-1">Resolver saldo de anticipo — ${esc(ocFolio)}</h3>
        <p class="text-xs text-slate-400 mb-3">Proveedor: ${esc(oc.proveedores?.nombre || '—')}. Disponible: <b class="text-amber-300">${fmt(disponible)}</b>. Úsalo cuando esta orden ya no se va a completar y necesitas decidir qué pasa con lo que ya se pagó de anticipo.</p>
        <div class="space-y-2">
          <div><label class="block text-[10px] text-slate-400 mb-1">¿Qué pasó con este saldo?</label>
            <select id="aaResTipo" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <option value="">— elige —</option>
              <option value="reasignado">Se aplicará a otra compra de este proveedor (reasignar)</option>
              <option value="reembolsado">El proveedor va a devolver el efectivo (reembolso)</option>
              <option value="baja">No se va a recuperar — es una pérdida (dar de baja)</option>
            </select></div>
          <div id="aaResCampoOc" class="hidden"><label class="block text-[10px] text-slate-400 mb-1">Orden de compra destino</label>
            <select id="aaResOcDestino" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optOc}</select></div>
          <div id="aaResCampoBanco" class="hidden"><label class="block text-[10px] text-slate-400 mb-1">Cuenta de banco / caja (donde entra el reembolso)</label>
            <select id="aaResCtaBanco" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optCta}</select></div>
          <div id="aaResCampoGasto" class="hidden"><label class="block text-[10px] text-slate-400 mb-1">Cuenta de gasto / pérdida</label>
            <select id="aaResCtaGasto" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optCta}</select></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Monto a resolver</label>
            <input type="number" step="0.01" min="0.01" max="${disponible}" id="aaResMonto" value="${disponible}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Fecha</label>
            <input type="date" id="aaResFecha" value="${new Date().toISOString().slice(0, 10)}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Notas</label>
            <input type="text" id="aaResNotas" placeholder="Por qué no se completó esta OC" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
        </div>
        <p id="aaResMsg" class="text-xs mt-2 min-h-[1rem] text-rose-400"></p>
        <div class="flex justify-end gap-2 mt-3">
          <button type="button" onclick="window.aaCerrarModal()" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-2 rounded-lg">Cancelar</button>
          <button type="button" id="aaResGuardar" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Registrar</button>
        </div>
      </div>`);

    document.getElementById('aaResTipo').onchange = (e) => {
        const t = e.target.value;
        document.getElementById('aaResCampoOc').classList.toggle('hidden', t !== 'reasignado');
        document.getElementById('aaResCampoBanco').classList.toggle('hidden', t !== 'reembolsado');
        document.getElementById('aaResCampoGasto').classList.toggle('hidden', t !== 'baja');
    };

    document.getElementById('aaResGuardar').onclick = async () => {
        const msg = document.getElementById('aaResMsg');
        const tipo = document.getElementById('aaResTipo').value;
        const monto = parseFloat(document.getElementById('aaResMonto').value);
        if (!tipo) { msg.textContent = 'Elige qué pasó con el saldo.'; return; }
        if (!(monto > 0)) { msg.textContent = 'Captura un monto mayor a cero.'; return; }
        const datos = {
            tipo, monto,
            fecha: document.getElementById('aaResFecha').value || new Date().toISOString().slice(0, 10),
            notas: document.getElementById('aaResNotas').value.trim() || null,
        };
        if (tipo === 'reasignado') {
            const ocDestino = document.getElementById('aaResOcDestino').value;
            if (!ocDestino) { msg.textContent = 'Elige la orden de compra destino.'; return; }
            datos.oc_destino_id = Number(ocDestino);
        } else if (tipo === 'reembolsado') {
            const cta = document.getElementById('aaResCtaBanco').value;
            if (!cta) { msg.textContent = 'Elige la cuenta de banco / caja.'; return; }
            datos.cuenta_banco_id = Number(cta);
        } else {
            const cta = document.getElementById('aaResCtaGasto').value;
            if (!cta) { msg.textContent = 'Elige la cuenta de gasto / pérdida.'; return; }
            datos.cuenta_gasto_id = Number(cta);
        }

        const btn = document.getElementById('aaResGuardar');
        btn.disabled = true;
        try {
            const { data, error } = await supabaseClient.rpc('resolver_anticipo_oc', { p_oc_id: ocId, p_datos: datos });
            if (error) throw error;
            alert(`✅ Saldo resuelto (${tipo}) por $${fmt(data.monto)}.`);
            window.aaCerrarModal();
            if (ultimoRes && ultimoHasta) await generarAuxAnticipos(ultimoRes, ultimoHasta);
        } catch (e) {
            msg.textContent = 'No se pudo resolver el saldo: ' + (e.message || e);
            btn.disabled = false;
        }
    };
};
