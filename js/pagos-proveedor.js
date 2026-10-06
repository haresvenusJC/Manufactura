import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { linkDoc, linkPoliza, etiquetaPoliza } from './enlaces-reporte.js';
import { imprimirHtml, marcaDeEstatus } from './impresion.js';

// =====================================================================
//  Cuentas por pagar / Pagos a proveedores (v2, maqueta aprobada por el usuario)
//  - Una fila por DOCUMENTO = orden de compra (las recepciones de una misma OC se
//    suman en una fila). Las OC autorizadas que aún no se reciben salen como
//    "anticipo" (se pagan contra la cotización: Cargo 109.01 / Abono banco).
//    Los gastos a crédito y las compras directas sin OC salen con su propio folio.
//  - "Pagar" abre una SUBVENTANA: Pago total (monto = saldo, no editable) o Pago parcial
//    (editable, exige escribir el acuerdo con el proveedor). Un pago = un proveedor.
//  - La póliza lleva serie BAN (banco) o VAE (efectivo/caja) además de su tipo SAT.
//  Requiere: sql/2026-09-02_pagos_proveedor.sql y sql/2026-11-08_cxp_v2_series_poliza.sql
//  (sin esta última el pago se registra igual, sin serie ni validaciones de total/parcial).
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const sumaDias = (iso, dias) => { if (!iso) return ''; const d = new Date(iso + 'T12:00:00'); d.setDate(d.getDate() + (Number(dias) || 0)); return d.toISOString().slice(0, 10); };
const r2 = (n) => Math.round((Number(n) || 0) * 100) / 100;
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

let cxpFilas = [];          // una fila por OC / gasto / compra sin OC (ver cxpCargarFilas)
let cxpCuentasPago = [];    // cuentas de banco/caja
let cxpAnticiposDisp = 0;   // KPI: anticipos pagados y aún sin aplicar
let cxpEstatus = 'pendientes';
let cxpDocQ = '';
let cxpProvId = '';
let cxpDesde = primerDiaMesISO();
let cxpHasta = hoyISO();
const cxpSel = new Set();
const cxpOrden = crearOrdenTabla('fecha', 'asc');
const cxpHistOrden = crearOrdenTabla('id', 'desc');

const ESTATUS_MENU = [
    ['pendientes', 'Pendientes de pago'], ['pendiente', 'Pendiente'], ['vencida', 'Vencida'], ['parcial', 'Parcial'],
    ['pagada', 'Pagada'], ['cancelada', 'Cancelada'], ['todas', 'Todas'],
];
const ESTATUS_BADGE = {
    vencida:   ['Vencida',   'bg-rose-500/15 text-rose-300 border-rose-500/30'],
    pendiente: ['Pendiente', 'bg-amber-500/15 text-amber-300 border-amber-500/30'],
    parcial:   ['Parcial',   'bg-sky-500/15 text-sky-300 border-sky-500/30'],
    pagada:    ['Pagada',    'bg-emerald-500/15 text-emerald-300 border-emerald-500/30'],
    cancelada: ['Cancelada', 'bg-slate-500/15 text-slate-400 border-slate-500/30'],
};
const cxpAbierta = (r) => r.estatus !== 'cancelada' && r.saldo > 0.005;

export async function cargarModuloPagosProveedor() {
    const cont = document.getElementById('contenedorPagosProveedor');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    cxpCerrarMenu();

    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        cxpCuentasPago = (data || []).filter((c) => /^(101|102)/.test(c.codigo));
    } catch (_) {
        cont.innerHTML = '<p class="text-amber-400 text-xs">El módulo de contabilidad no está instalado (faltan las cuentas contables).</p>';
        return;
    }

    try {
        cxpFilas = await cxpCargarFilas();
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-02_pagos_proveedor.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    cxpEstatus = 'pendientes'; cxpDocQ = ''; cxpProvId = '';
    cxpDesde = primerDiaMesISO(); cxpHasta = hoyISO();
    cxpSel.clear();
    const pre = window.__cxpOcPreseleccion ? Number(window.__cxpOcPreseleccion) : null;
    window.__cxpOcPreseleccion = null;
    if (pre) cxpFilas.filter((r) => r.ocId === pre && cxpAbierta(r)).forEach((r) => cxpSel.add(r.key));

    cont.innerHTML = `
    <div class="space-y-4">
      <div id="cxpPanelDocumentos"></div>
      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pagos registrados</h3>
        <div id="cxpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;
    cxpPintar();
    await cxpHistorial();
    montarGuia(cont, 'pagos-proveedor');
}

// ---------------------------------------------------------------------
//  Datos: una fila por documento (OC)
// ---------------------------------------------------------------------
async function cxpCargarFilas() {
    const hoy = hoyISO();
    const { data: vista, error } = await supabaseClient.from('v_cuentas_por_pagar').select('*').order('fecha', { ascending: true });
    if (error) throw error;

    const ocIds = [...new Set((vista || []).filter((x) => x.orden_compra_id).map((x) => Number(x.orden_compra_id)))];
    const ocPorId = new Map();
    if (ocIds.length) {
        const { data } = await supabaseClient.from('ordenes_compra').select('id, folio, fecha').in('id', ocIds);
        (data || []).forEach((o) => ocPorId.set(Number(o.id), o));
    }

    // Días de crédito del proveedor (sin ellos, vence el mismo día de la OC).
    const diasProv = new Map();
    try {
        const { data } = await supabaseClient.from('proveedores').select('id, dias_credito');
        (data || []).forEach((p) => diasProv.set(Number(p.id), Number(p.dias_credito) || 0));
    } catch (_) { /* sin días de crédito */ }

    // Anticipos ya pagados por OC y KPI de anticipos disponibles.
    const antPorOc = new Map();
    cxpAnticiposDisp = 0;
    try {
        const { data } = await supabaseClient.from('v_anticipos_oc').select('orden_compra_id, pagado, aplicado, disponible');
        (data || []).forEach((a) => { antPorOc.set(Number(a.orden_compra_id), a); cxpAnticiposDisp += Math.max(Number(a.disponible) || 0, 0); });
    } catch (_) { /* sin módulo de anticipos */ }

    // Pólizas de los pagos ya hechos (no canceladas), por documento / gasto / OC.
    const polPorClave = new Map();
    try {
        const { data } = await supabaseClient.from('pagos_proveedor_aplicaciones')
            .select('tipo, documento_id, gasto_id, orden_compra_id, pagos_proveedor ( poliza_id, estatus )')
            .order('id', { ascending: false }).limit(2000);
        (data || []).forEach((a) => {
            const pp = a.pagos_proveedor;
            if (!pp || pp.estatus === 'cancelado' || !pp.poliza_id) return;
            const k = a.documento_id ? 'compra:' + a.documento_id : a.gasto_id ? 'gasto:' + a.gasto_id : a.orden_compra_id ? 'oc:' + a.orden_compra_id : null;
            if (!k) return;
            if (!polPorClave.has(k)) polPorClave.set(k, new Set());
            polPorClave.get(k).add(Number(pp.poliza_id));
        });
    } catch (_) { /* sin pólizas ligadas */ }

    // 1) Deuda: compras recibidas a crédito y gastos a crédito. Las recepciones de la misma OC se suman.
    const grupos = new Map();
    for (const x of vista || []) {
        const esOc = x.tipo === 'compra' && x.orden_compra_id;
        const key = esOc ? 'oc:' + x.orden_compra_id : x.tipo + ':' + x.id;
        let g = grupos.get(key);
        if (!g) {
            const oc = esOc ? ocPorId.get(Number(x.orden_compra_id)) : null;
            g = {
                key, kind: 'deuda', ocId: esOc ? Number(x.orden_compra_id) : null,
                documento: oc?.folio || x.folio || ('#' + x.id), proveedorId: x.proveedor_id ? Number(x.proveedor_id) : null,
                proveedor: x.proveedor_nombre || '—', fecha: oc?.fecha || x.fecha, total: 0, pagado: 0, saldo: 0,
                totalCancelado: 0, docs: [], polizas: new Set(), nCancelados: 0,
            };
            grupos.set(key, g);
        }
        const docKey = x.tipo + ':' + x.id;
        (polPorClave.get(docKey) || []).forEach((p) => g.polizas.add(p));
        if (x.estatus_cxp === 'cancelado') { g.nCancelados++; g.totalCancelado += Number(x.total) || 0; return; }
        g.total += Number(x.total) || 0;
        g.pagado += Number(x.pagado) || 0;
        g.saldo += Number(x.saldo) || 0;
        g.docs.push({ tipo: x.tipo, id: Number(x.id), folio: x.folio, total: Number(x.total) || 0, saldo: Number(x.saldo) || 0, fecha: x.fecha });
    }
    const filas = [];
    for (const g of grupos.values()) {
        const todoCancelado = !g.docs.length;
        const dias = diasProv.get(g.proveedorId) || 0;
        g.total = r2(todoCancelado ? g.totalCancelado : g.total); g.pagado = r2(g.pagado); g.saldo = r2(g.saldo);
        g.vence = sumaDias(g.fecha, dias);
        g.vencida = !todoCancelado && g.saldo > 0.005 && g.vence && g.vence < hoy;
        g.estatus = todoCancelado ? 'cancelada' : g.saldo <= 0.005 ? 'pagada' : g.pagado > 0.005 ? 'parcial' : g.vencida ? 'vencida' : 'pendiente';
        g.polizas = [...g.polizas];
        filas.push(g);
    }

    // 2) Anticipo: OC autorizada ('abierta') que aún no se recibe; se paga contra la cotización.
    try {
        const { data: abiertas } = await supabaseClient.from('ordenes_compra')
            .select('id, folio, fecha, proveedor_id, proveedores ( nombre ), ordenes_compra_detalle ( cantidad, costo_unitario_estimado )')
            .eq('estatus', 'abierta');
        for (const o of abiertas || []) {
            if (grupos.has('oc:' + o.id)) continue;
            const total = r2((o.ordenes_compra_detalle || []).reduce((a, d) => a + (Number(d.cantidad) || 0) * (Number(d.costo_unitario_estimado) || 0), 0));
            if (total <= 0) continue;
            const pagado = r2(Number(antPorOc.get(Number(o.id))?.pagado) || 0);
            const saldo = r2(Math.max(total - pagado, 0));
            // Un anticipo no "vence" por sí solo: solo si el proveedor tiene días de crédito capturados.
            const dias = diasProv.get(Number(o.proveedor_id)) || 0;
            const vence = dias > 0 ? sumaDias(o.fecha, dias) : '';
            const vencida = saldo > 0.005 && !!vence && vence < hoy;
            filas.push({
                key: 'anticipo:' + o.id, kind: 'anticipo', ocId: Number(o.id), documento: o.folio || '#' + o.id,
                proveedorId: o.proveedor_id ? Number(o.proveedor_id) : null, proveedor: o.proveedores?.nombre || '—',
                fecha: o.fecha, vence, total, pagado, saldo, vencida, docs: [],
                polizas: [...(polPorClave.get('oc:' + o.id) || [])],
                estatus: saldo <= 0.005 ? 'pagada' : pagado > 0.005 ? 'parcial' : vencida ? 'vencida' : 'pendiente',
            });
        }
    } catch (_) { /* sin OC abiertas */ }

    return filas;
}

function cxpFiltradas() {
    const q = cxpDocQ.trim().toLowerCase();
    return cxpFilas.filter((r) => {
        if (cxpProvId && String(r.proveedorId || '') !== cxpProvId) return false;
        if (q && !String(r.documento || '').toLowerCase().includes(q)) return false;
        // Lo que se debe nunca se esconde por fecha; pagadas y canceladas sí respetan "desde / hasta".
        if (!cxpAbierta(r)) {
            if (cxpDesde && (r.fecha || '') < cxpDesde) return false;
            if (cxpHasta && (r.fecha || '') > cxpHasta) return false;
        }
        if (cxpEstatus === 'pendientes') return cxpAbierta(r);
        if (cxpEstatus === 'todas') return true;
        return r.estatus === cxpEstatus;
    });
}

// ---------------------------------------------------------------------
//  Lista
// ---------------------------------------------------------------------
function cxpPintar() {
    const panel = document.getElementById('cxpPanelDocumentos');
    if (!panel) return;
    const hoy = hoyISO();
    const en7 = sumaDias(hoy, 7);
    const abiertas = cxpFilas.filter(cxpAbierta);
    const kSaldo = abiertas.reduce((a, r) => a + r.saldo, 0);
    const kVencido = abiertas.filter((r) => r.vencida).reduce((a, r) => a + r.saldo, 0);
    const kSemana = abiertas.filter((r) => !r.vencida && r.vence && r.vence >= hoy && r.vence <= en7).reduce((a, r) => a + r.saldo, 0);

    const filas = cxpFiltradas();
    aplicarOrden(cxpOrden, filas, (x, campo) => {
        switch (campo) {
            case 'fecha': return x.fecha || '';
            case 'vence': return x.vence || '';
            case 'total': return x.total;
            case 'saldo': return x.saldo;
            default: return x.fecha || '';
        }
    });

    const conteo = (v) => v === 'todas' ? cxpFilas.length : v === 'pendientes' ? abiertas.length : cxpFilas.filter((r) => r.estatus === v).length;
    const kpi = (t, v, c = 'text-slate-100') => `<div class="bg-slate-950 border border-slate-800 rounded-xl p-4"><p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">${t}</p><p class="text-xl font-mono mt-1 ${c}">${money(v)}</p></div>`;
    const nomProv = cxpProvId ? (cxpFilas.find((r) => String(r.proveedorId || '') === cxpProvId)?.proveedor || '') : '';
    const lblEst = cxpEstatus !== 'pendientes' ? ESTATUS_MENU.find((e) => e[0] === cxpEstatus)?.[1] : '';
    const thFiltro = (tipo, txt, activo) => `<th class="p-2"><button type="button" class="cxp-th-filtro inline-flex items-center gap-1 uppercase ${activo ? 'text-sky-300' : 'hover:text-sky-300'}" data-menu="${tipo}">${txt}${activo ? ` <span class="normal-case text-slate-400">· ${esc(activo)}</span>` : ''} ▾</button></th>`;

    const filaHtml = (r) => {
        const sel = cxpSel.has(r.key);
        const b = ESTATUS_BADGE[r.estatus] || ESTATUS_BADGE.pendiente;
        const docLink = r.ocId
            ? `<button type="button" onclick="window.verDetalleOC(${r.ocId})" class="font-mono font-semibold text-slate-100 hover:text-sky-300 hover:underline text-left">${esc(r.documento)}</button>`
            : r.docs[0]?.tipo === 'compra' ? linkDoc(r.docs[0].id, r.documento, 'font-mono font-semibold text-slate-100') : `<span class="font-mono font-semibold text-slate-100">${esc(r.documento)}</span>`;
        const nota = r.kind === 'anticipo' ? '<div class="text-[10px] text-slate-500">sin recibir · anticipo</div>' : (r.docs.length > 1 ? `<div class="text-[10px] text-slate-500">${r.docs.length} recepciones</div>` : '');
        const pol = r.polizas.length ? r.polizas.slice(0, 2).map((id) => linkPoliza(id, 'font-mono text-sky-300 text-[11px]')).join('<br>') + (r.polizas.length > 2 ? `<div class="text-[10px] text-slate-500">+${r.polizas.length - 2} más</div>` : '') : '<span class="text-slate-600">—</span>';
        return `<tr class="border-b border-slate-900 ${r.estatus === 'cancelada' ? 'opacity-50' : ''}" data-key="${esc(r.key)}">
          <td class="p-2 text-center"><input type="checkbox" class="cxp-chk accent-emerald-500 w-4 h-4" data-key="${esc(r.key)}" ${cxpAbierta(r) ? '' : 'disabled'} ${sel ? 'checked' : ''}></td>
          <td class="p-2">${docLink}${nota}</td>
          <td class="p-2">${esc(r.proveedor)}</td>
          <td class="p-2 whitespace-nowrap text-slate-400 font-mono">${esc(r.fecha || '')}</td>
          <td class="p-2 whitespace-nowrap font-mono ${r.vencida ? 'text-rose-400' : 'text-slate-400'}">${esc(r.vence || '')}</td>
          <td class="p-2 text-right font-mono">${money(r.total)}</td>
          <td class="p-2 text-right font-mono ${r.saldo > 0.005 ? 'text-amber-300' : 'text-slate-500'}">${money(r.saldo)}</td>
          <td class="p-2"><span class="text-[10px] font-semibold px-2 py-0.5 rounded-full border ${b[1]}">${b[0]}</span></td>
          <td class="p-2">${pol}</td>
          <td class="p-2 text-right">${cxpAbierta(r) ? `<button type="button" class="cxp-pagar text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-3 py-1 rounded-lg" data-key="${esc(r.key)}">Pagar</button>` : ''}</td>
        </tr>`;
    };

    const selRows = [...cxpSel].map((k) => cxpFilas.find((r) => r.key === k)).filter(Boolean);
    const selTotal = selRows.reduce((a, r) => a + r.saldo, 0);

    panel.innerHTML = `
      <div class="space-y-4">
        <div class="flex items-center justify-between flex-wrap gap-2">
          <h3 class="text-md font-semibold text-slate-300">Documentos por pagar</h3>
          <span class="text-[11px] text-slate-500">Documento = orden de compra. Las OC aún sin recibir se pagan como anticipo.</span>
        </div>
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
          ${kpi('Saldo total pendiente', kSaldo)}${kpi('Vencido', kVencido, 'text-rose-300')}${kpi('Vence en 7 días', kSemana, 'text-amber-300')}${kpi('Anticipos disponibles', cxpAnticiposDisp, 'text-emerald-300')}
        </div>
        <div class="flex flex-wrap items-end gap-3">
          <div><label class="block text-[10px] text-slate-400 mb-1">desde</label>
            <input type="date" id="cxpDesde" value="${cxpDesde}" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">hasta</label>
            <input type="date" id="cxpHasta" value="${cxpHasta}" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
          <p class="text-[10px] text-slate-500 pb-2">El rango aplica a pagadas y canceladas; lo que se debe siempre se ve completo.</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          ${filas.length ? `
          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs text-slate-300">
              <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
                <th class="p-2"><input type="checkbox" id="cxpAll" class="accent-emerald-500" aria-label="Marcar todos"></th>
                ${thFiltro('doc', 'Documento', cxpDocQ.trim())}${thFiltro('prov', 'Proveedor', nomProv)}
                ${thOrden(cxpOrden, 'fecha', 'Fecha')}${thOrden(cxpOrden, 'vence', 'Vence')}
                ${thOrden(cxpOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpOrden, 'saldo', 'Saldo', 'text-right justify-end')}
                ${thFiltro('est', 'Estatus', lblEst)}
                <th class="p-2">Póliza</th><th class="p-2"></th>
              </tr></thead>
              <tbody id="cxpBody">${filas.map(filaHtml).join('')}</tbody>
            </table>
          </div>` : `
          <table class="w-full text-left text-xs text-slate-300"><thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            ${thFiltro('doc', 'Documento', cxpDocQ.trim())}${thFiltro('prov', 'Proveedor', nomProv)}${thFiltro('est', 'Estatus', lblEst)}</tr></thead></table>
          <p class="text-slate-500 text-sm p-3">No hay documentos con los filtros elegidos.</p>`}
        </div>
        ${selRows.length ? `
        <div class="flex flex-wrap items-center justify-between gap-3 bg-slate-900 border border-emerald-700/50 rounded-xl p-3">
          <div class="text-sm text-slate-200"><b>${selRows.length}</b> documento(s) seleccionado(s)<span class="text-slate-400 text-xs"> · ${esc([...new Set(selRows.map((r) => r.proveedor))].join(', '))}</span></div>
          <div class="flex items-center gap-3"><span class="font-mono text-amber-300 text-lg">${money(selTotal)}</span>
            <button type="button" id="cxpSelLimpiar" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-2 rounded-lg">Limpiar</button>
            <button type="button" id="cxpSelPagar" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Pagar</button></div>
        </div>` : ''}
        <p id="cxpMsg" class="text-xs min-h-[1rem] text-rose-400"></p>
      </div>`;

    panel.querySelectorAll('.cxp-th-filtro').forEach((b) => { b.onclick = (e) => { e.stopPropagation(); cxpAbrirMenu(b, b.dataset.menu); }; });
    document.getElementById('cxpDesde').onchange = (e) => { cxpDesde = e.target.value; cxpPintar(); };
    document.getElementById('cxpHasta').onchange = (e) => { cxpHasta = e.target.value; cxpPintar(); };
    wireOrdenTabla(panel, cxpOrden, cxpPintar);
    panel.querySelectorAll('.cxp-chk').forEach((c) => { c.onchange = () => { if (c.checked) cxpSel.add(c.dataset.key); else cxpSel.delete(c.dataset.key); cxpPintar(); }; });
    const all = document.getElementById('cxpAll');
    if (all) all.onchange = () => { filas.filter(cxpAbierta).forEach((r) => { if (all.checked) cxpSel.add(r.key); else cxpSel.delete(r.key); }); cxpPintar(); };
    panel.querySelectorAll('.cxp-pagar').forEach((b) => { b.onclick = () => cxpIniciarPago([b.dataset.key]); });
    const sp = document.getElementById('cxpSelPagar'); if (sp) sp.onclick = () => cxpIniciarPago([...cxpSel]);
    const sl = document.getElementById('cxpSelLimpiar'); if (sl) sl.onclick = () => { cxpSel.clear(); cxpPintar(); };
}

// Menús de los encabezados (Documento / Proveedor / Estatus): flotan sobre la pantalla para no recortarse con el scroll de la tabla.
function cxpCerrarMenu() { document.getElementById('cxpMenuFlot')?.remove(); }
function cxpAbrirMenu(btn, tipo) {
    const previo = document.getElementById('cxpMenuFlot');
    if (previo && previo.dataset.tipo === tipo) { previo.remove(); return; }
    cxpCerrarMenu();
    const r = btn.getBoundingClientRect();
    const m = document.createElement('div');
    m.id = 'cxpMenuFlot'; m.dataset.tipo = tipo;
    m.className = 'fixed bg-slate-900 border border-slate-700 rounded-lg shadow-2xl p-2 text-xs text-slate-200 w-64 max-h-80 overflow-y-auto';
    m.style.top = (r.bottom + 4) + 'px';
    m.style.left = Math.max(8, Math.min(r.left, window.innerWidth - 272)) + 'px';
    m.style.zIndex = '70';
    const inp = 'w-full bg-slate-950 border border-slate-800 rounded-md p-1.5 text-xs text-slate-100 mb-2';
    const btnCls = 'block w-full text-left px-2 py-1.5 rounded-md hover:bg-slate-800';
    if (tipo === 'doc') {
        m.innerHTML = `<input type="search" class="${inp}" placeholder="Buscar folio de OC" value="${esc(cxpDocQ)}" autocomplete="off"><button type="button" class="${btnCls} text-slate-400" data-quitar="1">Quitar búsqueda</button>`;
        const i = m.querySelector('input');
        i.oninput = () => { cxpDocQ = i.value; cxpPintar(); };
        m.querySelector('[data-quitar]').onclick = () => { cxpDocQ = ''; cxpCerrarMenu(); cxpPintar(); };
        setTimeout(() => i.focus(), 0);
    } else if (tipo === 'prov') {
        const provs = new Map();
        cxpFilas.forEach((x) => { if (x.proveedorId && !provs.has(String(x.proveedorId))) provs.set(String(x.proveedorId), x.proveedor); });
        const lista = [...provs.entries()].sort((a, b) => a[1].localeCompare(b[1], 'es'));
        m.innerHTML = `<input type="search" class="${inp}" placeholder="Buscar proveedor" autocomplete="off"><div data-lista></div>`;
        const pintaLista = (q) => {
            const f = lista.filter(([, n]) => n.toLowerCase().includes(q.toLowerCase()));
            m.querySelector('[data-lista]').innerHTML = `<button type="button" class="${btnCls} ${cxpProvId ? '' : 'text-sky-300'}" data-id="">Todos los proveedores</button>` +
                f.map(([id, n]) => `<button type="button" class="${btnCls} ${cxpProvId === id ? 'text-sky-300' : ''}" data-id="${esc(id)}">${esc(n)}</button>`).join('');
            m.querySelectorAll('[data-id]').forEach((b) => { b.onclick = () => { cxpProvId = b.dataset.id; cxpCerrarMenu(); cxpPintar(); }; });
        };
        pintaLista('');
        const i = m.querySelector('input');
        i.oninput = () => pintaLista(i.value);
        setTimeout(() => i.focus(), 0);
    } else {
        m.setAttribute('role', 'menu');
        const conteo = (v) => v === 'todas' ? cxpFilas.length : v === 'pendientes' ? cxpFilas.filter(cxpAbierta).length : cxpFilas.filter((x) => x.estatus === v).length;
        m.innerHTML = ESTATUS_MENU.map(([v, t]) => `${v === 'pagada' || v === 'todas' ? '<div class="border-t border-slate-800 my-1"></div>' : ''}<button type="button" class="${btnCls} ${cxpEstatus === v ? 'text-sky-300' : ''}" data-v="${v}">${t} <span class="text-slate-500">(${conteo(v)})</span></button>`).join('');
        m.querySelectorAll('[data-v]').forEach((b) => { b.onclick = () => { cxpEstatus = b.dataset.v; cxpCerrarMenu(); cxpPintar(); }; });
    }
    document.body.appendChild(m);
}
if (!window.__cxpMenuListener) {
    window.__cxpMenuListener = true;
    document.addEventListener('mousedown', (e) => {
        const m = document.getElementById('cxpMenuFlot');
        if (m && !m.contains(e.target) && !e.target.closest('.cxp-th-filtro')) m.remove();
    });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') document.getElementById('cxpMenuFlot')?.remove(); });
}

// ---------------------------------------------------------------------
//  Pagar → subventana
// ---------------------------------------------------------------------
function cxpAviso(txt) {
    const el = document.getElementById('cxpMsg');
    if (el) el.textContent = txt; else alert(txt);
}

function cxpIniciarPago(keys) {
    const filas = keys.map((k) => cxpFilas.find((r) => r.key === k)).filter((r) => r && cxpAbierta(r));
    if (!filas.length) { cxpAviso('Marca al menos un documento a pagar.'); return; }
    if (new Set(filas.map((r) => String(r.proveedorId || ''))).size > 1) { cxpAviso('Un pago es de un solo proveedor: deja marcados solo los documentos del mismo proveedor.'); return; }
    if (new Set(filas.map((r) => r.kind)).size > 1) { cxpAviso('Paga por separado los anticipos (OC sin recibir) y las deudas (OC ya recibida).'); return; }
    if (filas[0].kind === 'anticipo' && filas.length > 1) { cxpAviso('Un anticipo se paga por orden de compra: marca una sola.'); return; }
    cxpAviso('');
    cxpAbrirPago(filas);
}

async function cxpSiguientesSeries() {
    const sig = { BAN: 1, VAE: 1 };
    try {
        const { data } = await supabaseClient.from('contadores_folios').select('serie, ultimo').in('serie', ['POLBAN', 'POLVAE']);
        (data || []).forEach((c) => { sig[c.serie.replace('POL', '')] = Number(c.ultimo) + 1; });
    } catch (_) { /* sin contador */ }
    return sig;
}

async function cxpAbrirPago(filas) {
    const kind = filas[0].kind;
    const prov = filas[0].proveedor;
    const idModal = window.idSubventana ? window.idSubventana('cxpPagoModal') : 'cxpPagoModal';
    document.getElementById(idModal)?.remove();
    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed inset-0 bg-slate-950/40 flex items-center justify-center p-4';
    modal.style.zIndex = String(window.zSubventanaSiguiente ? window.zSubventanaSiguiente() : 60);
    modal.innerHTML = `<div class="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-5xl max-h-[92vh] flex flex-col shadow-2xl overflow-hidden">
        <div class="flex justify-between items-center px-5 py-3 border-b border-slate-800 bg-slate-950">
          <h3 class="text-sm font-bold text-slate-100">Registrar pago · ${esc(filas.map((r) => r.documento).join(', '))}</h3>
          <button type="button" class="cxp-x text-slate-400 hover:text-slate-200 text-lg font-bold px-2" aria-label="Cerrar">&times;</button>
        </div>
        <div class="cxp-cuerpo p-5 overflow-y-auto text-sm text-slate-400">Cargando documento…</div>
      </div>`;
    document.body.appendChild(modal);
    modal.querySelector('.cxp-x').onclick = () => modal.remove();
    const cuerpo = modal.querySelector('.cxp-cuerpo');

    // Documentos a pagar (más antiguos primero) y renglones que ampara el pago.
    let docs = []; let lineas = []; let notaLineas = '';
    try {
        if (kind === 'anticipo') {
            const { data } = await supabaseClient.from('ordenes_compra_detalle')
                .select('cantidad, costo_unitario_estimado, descripcion, productos ( nombre, sku )').eq('orden_compra_id', filas[0].ocId);
            lineas = (data || []).map((d) => ({ cod: d.productos?.sku || 'sin código', desc: d.productos?.nombre || d.descripcion || '—', cant: Number(d.cantidad) || 0, pu: Number(d.costo_unitario_estimado) || 0, imp: (Number(d.cantidad) || 0) * (Number(d.costo_unitario_estimado) || 0) }));
            notaLineas = 'Importes estimados de la orden de compra (sin IVA); la factura real llega con la recepción.';
        } else {
            docs = filas.flatMap((r) => r.docs).filter((d) => d.saldo > 0.005).sort((a, b) => String(a.fecha || '').localeCompare(String(b.fecha || '')));
            const idsC = docs.filter((d) => d.tipo === 'compra').map((d) => d.id);
            const idsG = docs.filter((d) => d.tipo === 'gasto').map((d) => d.id);
            if (idsC.length) {
                const { data: dd } = await supabaseClient.from('documentos').select('id, total, iva').in('id', idsC);
                (dd || []).forEach((x) => { const d = docs.find((y) => y.tipo === 'compra' && y.id === Number(x.id)); if (d) d.iva = Number(x.iva) || 0; });
                const { data: det } = await supabaseClient.from('documento_detalles').select('documento_id, cantidad, costo_unitario, subtotal, productos ( nombre, sku )').in('documento_id', idsC);
                lineas = (det || []).map((d) => ({ cod: d.productos?.sku || 'sin código', desc: d.productos?.nombre || '—', cant: Number(d.cantidad) || 0, pu: Number(d.costo_unitario) || 0, imp: Number(d.subtotal) || (Number(d.cantidad) || 0) * (Number(d.costo_unitario) || 0) }));
            }
            if (idsG.length) {
                const { data: gg } = await supabaseClient.from('gastos').select('id, concepto, iva, total').in('id', idsG);
                (gg || []).forEach((x) => { const d = docs.find((y) => y.tipo === 'gasto' && y.id === Number(x.id)); if (d) d.iva = Number(x.iva) || 0; lineas.push({ cod: 'gasto', desc: x.concepto || '—', cant: 1, pu: Number(x.total) || 0, imp: Number(x.total) || 0 }); });
            }
            notaLineas = 'Solo se paga lo ya recibido.';
        }
    } catch (_) { /* sin renglones: el pago funciona igual */ }

    const saldoTotal = r2(filas.reduce((a, r) => a + r.saldo, 0));
    const totalDoc = r2(filas.reduce((a, r) => a + r.total, 0));
    const pagadoAnt = r2(filas.reduce((a, r) => a + r.pagado, 0));
    const series = await cxpSiguientesSeries();
    const optCta = cxpCuentasPago.map((c) => `<option value="${c.id}" data-cod="${esc(c.codigo)}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const ctaDef = cxpCuentasPago.find((c) => /^102/.test(c.codigo)) || cxpCuentasPago[0];
    const inp = 'w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100';
    const lbl = 'block text-[10px] text-slate-400 mb-1';
    const verOc = filas.filter((r) => r.ocId).map((r) => `<a href="#" onclick="window.verDetalleOC(${r.ocId});return false" class="text-sky-300 hover:underline">Ver OC ${esc(r.documento)}</a>`).join(' · ');
    const verRec = docs.filter((d) => d.tipo === 'compra').map((d) => linkDoc(d.id, 'Recepción ' + (d.folio || '#' + d.id), 'text-sky-300')).join(' · ');

    cuerpo.className = 'cxp-cuerpo p-5 overflow-y-auto grid md:grid-cols-2 gap-5 text-sm text-slate-300';
    cuerpo.innerHTML = `
      <div class="space-y-4">
        <section class="bg-slate-950 border border-slate-800 rounded-xl p-4">
          <h4 class="text-xs font-bold text-slate-200 uppercase mb-2">Proveedor y documento</h4>
          <div class="grid grid-cols-2 gap-2 text-xs">
            <div><span class="text-slate-500 block">Proveedor</span><b class="text-slate-100">${esc(prov)}</b></div>
            <div><span class="text-slate-500 block">Documento</span><b class="text-slate-100 font-mono">${esc(filas.map((r) => r.documento).join(', '))}</b></div>
            <div><span class="text-slate-500 block">Fecha · Vence</span><b class="font-mono">${esc(filas[0].fecha || '')} · ${esc(filas[0].vence || '')}</b></div>
            <div><span class="text-slate-500 block">Tipo de pago</span><b class="text-slate-100">${kind === 'anticipo' ? 'Anticipo (OC sin recibir)' : 'Pago de deuda (ya recibida)'}</b></div>
          </div>
          <p class="text-xs mt-2">${[verOc, verRec].filter(Boolean).join(' · ')}</p>
        </section>
        <section class="bg-slate-950 border border-slate-800 rounded-xl p-4">
          <h4 class="text-xs font-bold text-slate-200 uppercase mb-2">Qué ampara este pago</h4>
          ${lineas.length ? `<div class="overflow-x-auto"><table class="w-full text-[11px]"><thead class="text-slate-500 uppercase"><tr><th class="text-left p-1">Código</th><th class="text-left p-1">Descripción</th><th class="text-right p-1">Cant.</th><th class="text-right p-1">P. unit.</th><th class="text-right p-1">Importe</th></tr></thead>
            <tbody>${lineas.map((l) => `<tr class="border-t border-slate-900"><td class="p-1 font-mono">${esc(l.cod)}</td><td class="p-1">${esc(l.desc)}</td><td class="p-1 text-right font-mono">${l.cant}</td><td class="p-1 text-right font-mono">${money(l.pu)}</td><td class="p-1 text-right font-mono">${money(l.imp)}</td></tr>`).join('')}</tbody></table></div>`
            : '<p class="text-xs text-slate-500">Sin renglones para mostrar.</p>'}
          <p class="text-[11px] text-slate-500 mt-2">${esc(notaLineas)}</p>
        </section>
        <section class="bg-slate-950 border border-slate-800 rounded-xl p-4">
          <h4 class="text-xs font-bold text-slate-200 uppercase mb-2">Validación</h4>
          ${kind === 'anticipo'
              ? '<p class="text-xs text-amber-300">Aún no se recibe: se paga como anticipo (Cargo 109.01 Anticipos a proveedores). Al validar la recepción, el sistema lo cancela contra la deuda en la misma póliza.</p>'
              : '<p class="text-xs text-emerald-300">Recepción ya registrada: se paga la deuda reconocida en 201.01 Proveedores.</p>'}
        </section>
      </div>
      <div class="space-y-4">
        <section class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
          <h4 class="text-xs font-bold text-slate-200 uppercase">Datos del pago</h4>
          <div class="inline-flex rounded-lg border border-slate-700 overflow-hidden" role="group" aria-label="Tipo de pago">
            <button type="button" class="cxp-b-total px-3 py-1.5 text-xs font-semibold bg-sky-600 text-white">Pago total</button>
            <button type="button" class="cxp-b-parcial px-3 py-1.5 text-xs font-semibold bg-slate-900 text-slate-300">Pago parcial</button>
          </div>
          <div><label class="${lbl}">Monto a pagar <span class="cxp-monto-hint text-slate-500">· saldo del documento</span></label>
            <input type="number" step="0.01" min="0" class="cxp-monto ${inp} font-mono" value="${saldoTotal.toFixed(2)}" readonly></div>
          <div class="cxp-acuerdo-box hidden bg-slate-900 border border-slate-700 rounded-lg p-3 space-y-2">
            <label class="${lbl}">Acuerdo con el proveedor (obligatorio en pago parcial)</label>
            <input type="text" class="cxp-acuerdo ${inp}" placeholder="Ej. Anticipo 50%, saldo contra entrega, acordado con [contacto]">
            <p class="text-[10px] text-slate-500">Idealmente esta condición se declara en la OC antes de autorizarla. Mientras tanto queda registrada con el pago y en la bitácora.</p>
          </div>
          <div class="grid grid-cols-2 gap-2">
            <div><label class="${lbl}">Fecha del pago</label><input type="date" class="cxp-fecha ${inp}" value="${hoyISO()}"></div>
            <div><label class="${lbl}">Forma de pago</label>
              <select class="cxp-forma ${inp}"><option>transferencia</option><option>cheque</option><option>tarjeta</option><option>efectivo</option></select></div>
          </div>
          <div><label class="${lbl}">Cuenta de pago</label><select class="cxp-cuenta ${inp}">${optCta}</select></div>
          <div class="cxp-alerta-efectivo hidden text-[11px] bg-amber-500/10 border border-amber-500/30 text-amber-300 rounded-lg p-2">Los pagos en efectivo mayores a $2,000 no son deducibles y su IVA no es acreditable. Confírmalo con tu contador.</div>
          <div><label class="${lbl}">Referencia</label><input type="text" class="cxp-ref ${inp}" placeholder="No. de transferencia / cheque"></div>
          <div><label class="${lbl}">Notas internas</label><input type="text" class="cxp-notas ${inp}" placeholder="Opcional"></div>
        </section>
        <section class="bg-slate-950 border border-slate-800 rounded-xl p-4">
          <h4 class="text-xs font-bold text-slate-200 uppercase mb-2">Resumen</h4>
          <div class="text-xs space-y-1">
            <div class="flex justify-between"><span class="text-slate-500">${kind === 'anticipo' ? 'Total estimado de la OC' : 'Total del documento'}</span><span class="font-mono">${money(totalDoc)}</span></div>
            <div class="flex justify-between"><span class="text-slate-500">Pagado anteriormente</span><span class="font-mono">${money(pagadoAnt)}</span></div>
            <div class="flex justify-between text-sm"><b>Este pago</b><b class="cxp-s-este font-mono text-amber-300"></b></div>
            <div class="flex justify-between"><span class="text-slate-500">Saldo restante</span><span class="cxp-s-saldo font-mono"></span></div>
          </div>
          <div class="mt-3 border border-slate-800 rounded-lg p-3 bg-slate-900">
            <b class="cxp-pol-titulo text-xs text-slate-200"></b>
            <div class="cxp-pol-filas text-[11px] mt-2 space-y-1"></div>
          </div>
        </section>
        <p class="cxp-err text-xs text-rose-400 min-h-[1rem]"></p>
        <div class="flex justify-end gap-2">
          <button type="button" class="cxp-cancelar text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-4 py-2 rounded-lg">Cancelar</button>
          <button type="button" class="cxp-confirmar text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-5 py-2 rounded-lg">Confirmar pago</button>
        </div>
      </div>`;

    const q = (c) => cuerpo.querySelector(c);
    let modo = 'total';
    if (ctaDef) q('.cxp-cuenta').value = ctaDef.id;

    const codigoCuenta = () => q('.cxp-cuenta').selectedOptions[0]?.dataset.cod || '';
    const montoActual = () => modo === 'total' ? saldoTotal : r2(parseFloat(q('.cxp-monto').value) || 0);
    // Reparte lo que se paga entre los documentos, el más antiguo primero (en un anticipo no hay documentos).
    const repartir = (monto) => {
        let resto = monto; const apps = [];
        for (const d of docs) { if (resto <= 0.004) break; const m = r2(Math.min(resto, d.saldo)); apps.push({ tipo: d.tipo, id: d.id, monto: m, doc: d }); resto = r2(resto - m); }
        return apps;
    };
    const validar = () => {
        const m = montoActual();
        if (modo === 'parcial') {
            if (!(m > 0)) return 'Captura el monto del pago parcial.';
            if (m >= saldoTotal - 0.005) return 'Para pagar el saldo completo usa «Pago total».';
            if (!q('.cxp-acuerdo').value.trim()) return 'Escribe el acuerdo con el proveedor para registrar un pago parcial.';
        }
        if (!q('.cxp-cuenta').value) return 'Elige la cuenta de banco / caja.';
        return '';
    };
    const recalc = () => {
        const m = montoActual();
        const serie = /^101/.test(codigoCuenta()) ? 'VAE' : 'BAN';
        q('.cxp-s-este').textContent = money(m);
        q('.cxp-s-saldo').textContent = money(Math.max(saldoTotal - m, 0));
        q('.cxp-pol-titulo').textContent = `Póliza ${serie}-${String(series[serie]).padStart(5, '0')} · Egreso (se genera al confirmar)`;
        let filasPol = '';
        const fila = (c, cargo, abono) => `<div class="grid grid-cols-[1fr_auto_auto] gap-3"><span>${esc(c)}</span><span class="font-mono text-right w-24">${cargo != null ? money(cargo) : ''}</span><span class="font-mono text-right w-24">${abono != null ? money(abono) : ''}</span></div>`;
        const cta = cxpCuentasPago.find((c) => String(c.id) === q('.cxp-cuenta').value);
        const ctaTxt = cta ? `${cta.codigo} ${cta.nombre}` : 'Banco / caja';
        filasPol += '<div class="grid grid-cols-[1fr_auto_auto] gap-3 text-slate-500 text-[10px]"><span>Cuenta</span><span class="w-24 text-right">Cargo</span><span class="w-24 text-right">Abono</span></div>';
        if (kind === 'anticipo') {
            filasPol += fila('109.01 Anticipos a proveedores', m, null);
        } else {
            filasPol += fila('201.01 Proveedores', m, null);
            const iva = r2(repartir(m).reduce((a, x) => a + (x.doc.total > 0 && x.doc.iva ? x.doc.iva * x.monto / x.doc.total : 0), 0));
            if (iva > 0) { filasPol += fila('118.01 IVA acreditable pagado', iva, null); filasPol += fila('119.01 IVA acreditable pendiente', null, iva); }
        }
        filasPol += fila(ctaTxt, null, m);
        q('.cxp-pol-filas').innerHTML = filasPol;
        const efectivo = /^101/.test(codigoCuenta()) || q('.cxp-forma').value === 'efectivo';
        q('.cxp-alerta-efectivo').classList.toggle('hidden', !(efectivo && m > 2000));
        q('.cxp-err').textContent = modo === 'parcial' ? validar() : '';
    };
    const setModo = (m) => {
        modo = m;
        q('.cxp-b-total').className = 'cxp-b-total px-3 py-1.5 text-xs font-semibold ' + (m === 'total' ? 'bg-sky-600 text-white' : 'bg-slate-900 text-slate-300');
        q('.cxp-b-parcial').className = 'cxp-b-parcial px-3 py-1.5 text-xs font-semibold ' + (m === 'parcial' ? 'bg-sky-600 text-white' : 'bg-slate-900 text-slate-300');
        q('.cxp-acuerdo-box').classList.toggle('hidden', m !== 'parcial');
        const mo = q('.cxp-monto');
        mo.readOnly = m === 'total';
        q('.cxp-monto-hint').textContent = m === 'total' ? '· saldo del documento' : '· editable, menor al saldo';
        if (m === 'total') mo.value = saldoTotal.toFixed(2); else { mo.value = ''; mo.focus(); }
        recalc();
    };
    q('.cxp-b-total').onclick = () => setModo('total');
    q('.cxp-b-parcial').onclick = () => setModo('parcial');
    ['.cxp-monto', '.cxp-acuerdo'].forEach((s) => q(s).addEventListener('input', recalc));
    ['.cxp-cuenta', '.cxp-forma'].forEach((s) => q(s).addEventListener('change', recalc));
    q('.cxp-cancelar').onclick = () => modal.remove();
    recalc();

    q('.cxp-confirmar').onclick = async () => {
        const err = validar();
        const msg = q('.cxp-err');
        if (err) { msg.textContent = err; return; }
        const monto = montoActual();
        const acuerdo = modo === 'parcial' ? q('.cxp-acuerdo').value.trim() : null;
        const base = {
            fecha: q('.cxp-fecha').value || hoyISO(),
            cuenta_pago_id: Number(q('.cxp-cuenta').value),
            forma_pago: q('.cxp-forma').value || null,
            referencia: q('.cxp-ref').value.trim() || null,
            notas: q('.cxp-notas').value.trim() || null,
            tipo_pago: modo, acuerdo,
        };
        const btn = q('.cxp-confirmar');
        btn.disabled = true; msg.textContent = '';
        try {
            const llamar = async (v2, viejo, args, argsViejo) => {
                let r = await supabaseClient.rpc(v2, args);
                if (r.error && /could not find the function|schema cache/i.test(r.error.message || '')) {
                    // Sin la migración 2026-11-08: se registra igual por la función de siempre (sin serie), con el acuerdo en notas.
                    r = await supabaseClient.rpc(viejo, argsViejo);
                }
                if (r.error) throw r.error;
                return r.data;
            };
            const notasViejo = [base.notas, acuerdo ? `Pago parcial — acuerdo: ${acuerdo}` : ''].filter(Boolean).join(' | ') || null;
            let data;
            if (kind === 'anticipo') {
                data = await llamar('pagar_anticipo_oc_v2', 'pagar_anticipo_oc',
                    { p_oc_id: filas[0].ocId, p_datos: { ...base, monto } },
                    { p_oc_id: filas[0].ocId, p_datos: { fecha: base.fecha, monto, cuenta_pago_id: base.cuenta_pago_id, forma_pago: base.forma_pago, referencia: base.referencia, notas: notasViejo } });
            } else {
                const aplicaciones = repartir(monto).map((a) => ({ tipo: a.tipo, id: a.id, monto: a.monto }));
                data = await llamar('registrar_pago_proveedor_v2', 'registrar_pago_proveedor',
                    { p_datos: { ...base, aplicaciones } },
                    { p_datos: { fecha: base.fecha, cuenta_pago_id: base.cuenta_pago_id, forma_pago: base.forma_pago, referencia: base.referencia, notas: notasViejo, aplicaciones } });
            }
            const etiqueta = data?.serie_folio || (data?.poliza_id ? await etiquetaPoliza(data.poliza_id) : '');
            modal.remove();
            alert(`✅ ${kind === 'anticipo' ? 'Anticipo' : 'Pago'} registrado por ${money(data?.total ?? monto)}.${etiqueta ? ' Póliza ' + etiqueta + ' generada.' : ''}`);
            await cargarModuloPagosProveedor();
        } catch (e) {
            msg.textContent = 'No se pudo registrar el pago: ' + (e.message || e);
            btn.disabled = false;
        }
    };
}

// Comprobante de pago a proveedor (mismo estilo de impresión que el resto de la app).
async function cxpImprimirComprobante(id) {
    try {
        const { data: p, error } = await supabaseClient.from('pagos_proveedor')
            .select('id, fecha, total, referencia, forma_pago, notas, estatus, poliza_id, proveedores ( nombre, rfc ), cuentas_contables!cuenta_pago_id ( codigo, nombre ), pagos_proveedor_aplicaciones ( tipo, monto, documentos ( folio ), gastos ( concepto, folio_factura ) )')
            .eq('id', id).single();
        if (error) throw error;
        const pol = p.poliza_id ? await etiquetaPoliza(p.poliza_id) : '—';
        const filas = (p.pagos_proveedor_aplicaciones || []).map((a) => `<tr>
            <td>${a.tipo === 'gasto' ? 'Gasto' : a.tipo === 'compra' ? 'Compra' : esc(a.tipo)}</td>
            <td>${esc(a.tipo === 'gasto' ? [a.gastos?.concepto, a.gastos?.folio_factura].filter(Boolean).join(' · ') : (a.documentos?.folio || '—'))}</td>
            <td style="text-align:right">${money(a.monto)}</td></tr>`).join('');
        await imprimirHtml('pago_proveedor', `Pago a proveedor #${p.id}`, `
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:3px 12px;margin-bottom:6px">
                <div><b>Proveedor:</b> ${esc(p.proveedores?.nombre || '(varios)')}</div>
                <div><b>RFC:</b> ${esc(p.proveedores?.rfc || '—')}</div>
                <div><b>Fecha:</b> ${esc(p.fecha || '')}</div>
                <div><b>Forma de pago:</b> ${esc(p.forma_pago || '—')}</div>
                <div><b>Referencia:</b> ${esc(p.referencia || '—')}</div>
                <div><b>Cuenta de salida:</b> ${p.cuentas_contables ? esc(p.cuentas_contables.codigo + ' · ' + p.cuentas_contables.nombre) : '—'}</div>
                <div><b>Póliza:</b> ${esc(pol)}</div>
                <div><b>Estatus:</b> ${esc(p.estatus)}</div>
            </div>
            <table><thead><tr><th>Tipo</th><th>Documento aplicado</th><th style="text-align:right">Monto</th></tr></thead>
            <tbody>${filas || '<tr><td colspan="3">Sin documentos aplicados.</td></tr>'}</tbody>
            <tfoot><tr><td colspan="2" style="text-align:right"><b>Total pagado</b></td><td style="text-align:right"><b>${money(p.total)}</b></td></tr></tfoot></table>
            ${p.notas ? `<p style="margin-top:6px"><b>Notas:</b> ${esc(p.notas)}</p>` : ''}
            <div style="display:flex;gap:40px;margin-top:28px"><div style="flex:1;border-top:1px solid #555;text-align:center;padding-top:2px">Elaboró</div><div style="flex:1;border-top:1px solid #555;text-align:center;padding-top:2px">Recibió proveedor</div></div>`, marcaDeEstatus(p.estatus));
    } catch (e) { alert('No se pudo armar el comprobante: ' + (e.message || e)); }
}

async function cxpHistorial() {
    const cont = document.getElementById('cxpHist');
    try {
        const { data, error } = await supabaseClient.from('pagos_proveedor')
            .select('id, fecha, total, referencia, forma_pago, estatus, poliza_id, proveedores ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto )')
            .order('id', { ascending: false }).limit(100);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin pagos registrados.</p>'; return; }

        aplicarOrden(cxpHistOrden, data, (p, campo) => {
            switch (campo) {
                case 'fecha': return p.fecha || '';
                case 'proveedor': return (p.proveedores?.nombre || '').toLowerCase();
                case 'ref': return (p.referencia || '').toLowerCase();
                case 'total': return Number(p.total || 0);
                case 'docs': return (p.pagos_proveedor_aplicaciones || []).length;
                case 'estatus': return p.estatus || '';
                default: return p.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(cxpHistOrden, 'fecha', 'Fecha')}${thOrden(cxpHistOrden, 'proveedor', 'Proveedor')}${thOrden(cxpHistOrden, 'ref', 'Ref.')}
              ${thOrden(cxpHistOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpHistOrden, 'docs', '# Docs', 'text-center justify-center')}<th class="p-2">Póliza</th>${thOrden(cxpHistOrden, 'estatus', 'Estatus')}
            </tr></thead>
            <tbody>
              ${data.map(p => `
                <tr class="border-b border-slate-900 ${p.estatus === 'cancelado' ? 'opacity-50' : ''}">
                  <td class="p-2 whitespace-nowrap"><button type="button" class="cxp-print text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded mr-1" data-id="${p.id}" title="Imprimir comprobante de pago">🖨️</button>${p.estatus === 'registrado' ? `<button type="button" class="cxp-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded" data-id="${p.id}">Cancelar</button>` : ''}</td>
                  <td class="p-2 whitespace-nowrap">${p.fecha || ''}</td>
                  <td class="p-2">${esc(p.proveedores?.nombre || '(varios)')}</td>
                  <td class="p-2 text-slate-400">${esc(p.referencia || '')}</td>
                  <td class="p-2 text-right font-mono">${money(p.total)}</td>
                  <td class="p-2 text-center font-mono text-slate-400">${(p.pagos_proveedor_aplicaciones || []).length}</td>
                  <td class="p-2">${p.poliza_id ? linkPoliza(p.poliza_id, 'font-mono text-sky-300 text-[11px]') : '<span class="text-slate-500">—</span>'}</td>
                  <td class="p-2 ${p.estatus === 'registrado' ? 'text-emerald-400' : 'text-rose-400'}">${esc(p.estatus)}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        cont.querySelectorAll('.cxp-print').forEach(b => { b.onclick = () => cxpImprimirComprobante(Number(b.dataset.id)); });
        cont.querySelectorAll('.cxp-cancel').forEach(b => {
            b.onclick = async () => {
                if (!confirm('¿Cancelar este pago? Se genera la póliza de reverso y los saldos vuelven a quedar pendientes.')) return;
                const { error } = await supabaseClient.rpc('cancelar_pago_proveedor', { p_pago_id: Number(b.dataset.id) });
                if (error) { alert('No se pudo cancelar: ' + error.message); return; }
                await cargarModuloPagosProveedor();
            };
        });
        wireOrdenTabla(cont, cxpHistOrden, cxpHistorial);
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">Historial no disponible: ${esc(err.message || err)}</p>`;
    }
}
