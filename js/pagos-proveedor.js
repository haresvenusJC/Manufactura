import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { linkDoc, linkPoliza, etiquetaPoliza } from './enlaces-reporte.js';
import { imprimirHtml, marcaDeEstatus } from './impresion.js';

// =====================================================================
//  Cuentas por pagar / Pagos a proveedores
//  Lista compras y gastos a crédito con saldo pendiente y registra el
//  pago (Cargo 201.01 Proveedores / Abono banco) vía registrar_pago_proveedor.
//  Requiere: sql/2026-09-02_pagos_proveedor.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Estado del filtro de visibilidad (Pendientes / Pagadas / Canceladas / Todas)
// y el último dataset traído, para poder refiltrar sin volver a consultar.
let cxpCache = [];
let cxpCuentasPago = []; // cuentas de banco/caja, para el modal de Anticipo (reusa lo ya cargado por el módulo)
let cxpPreOcCache = null;
let cxpFiltro = 'pendiente';
let cxpDesde = primerDiaMesISO();
let cxpHasta = hoyISO();
let cxpProveedorId = '';
const CXP_FILTROS = [
    { v: 'pendiente', t: 'Pendientes de pago' },
    { v: 'pagado', t: 'Pagadas' },
    { v: 'cancelado', t: 'Canceladas' },
    { v: 'todas', t: 'Todas' },
];
const cxpOrden = crearOrdenTabla();
const cxpHistOrden = crearOrdenTabla('id', 'desc');

export async function cargarModuloPagosProveedor() {
    const cont = document.getElementById('contenedorPagosProveedor');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';

    let ctasPago = [];
    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        ctasPago = (data || []).filter(c => /^(101|102)/.test(c.codigo));
        cxpCuentasPago = ctasPago;
    } catch (_) {
        cont.innerHTML = '<p class="text-amber-400 text-xs">El módulo de contabilidad no está instalado (faltan las cuentas contables).</p>';
        return;
    }

    let cxp = [];
    try {
        const { data, error } = await supabaseClient.from('v_cuentas_por_pagar').select('*').order('fecha', { ascending: true });
        if (error) throw error;
        cxp = data || [];
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-02_pagos_proveedor.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    cxpCache = cxp;
    cxpPreOcCache = window.__cxpOcPreseleccion || null;
    window.__cxpOcPreseleccion = null;
    cxpFiltro = 'pendiente';
    cxpDesde = primerDiaMesISO(); cxpHasta = hoyISO(); cxpProveedorId = '';

    const optCta = '<option value="">— caja / banco —</option>' +
        ctasPago.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="flex flex-wrap items-end justify-between gap-3">
          <div class="flex flex-wrap items-end gap-3">
            <div><label class="block text-xs text-slate-400 mb-1">Fecha del pago</label>
              <input type="date" id="cxpFecha" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
            <div><label class="block text-xs text-slate-400 mb-1">Cuenta (banco / caja)</label>
              <select id="cxpCuenta" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCta}</select></div>
            <div><label class="block text-xs text-slate-400 mb-1">Forma de pago</label>
              <select id="cxpForma" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                <option value="">—</option><option>transferencia</option><option>efectivo</option><option>cheque</option><option>tarjeta</option></select></div>
            <div class="flex-1 min-w-[160px]"><label class="block text-xs text-slate-400 mb-1">Referencia</label>
              <input type="text" id="cxpRef" placeholder="No. de transferencia / cheque" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          </div>
          <button type="button" id="cxpBtnAnticipo" class="text-xs bg-amber-700 hover:bg-amber-600 text-white px-3 py-2 rounded-lg whitespace-nowrap">💰 Pagar anticipo a una OC</button>
        </div>
      </div>

      <div id="cxpPanelDocumentos" class="bg-slate-950 border border-slate-800 rounded-xl p-4"></div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pagos registrados</h3>
        <div id="cxpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('cxpFecha').value = hoyISO();
    if (ctasPago.length === 1) document.getElementById('cxpCuenta').value = ctasPago[0].id;
    document.getElementById('cxpBtnAnticipo').onclick = cxpAbrirAnticipo;

    cxpPintarDocumentos();
    await cxpHistorial();
    montarGuia(cont, 'pagos-proveedor');
}

// Repinta solo el panel "Documentos por pagar" según cxpFiltro, sin
// volver a consultar Supabase (cxpCache ya trae todos los estatus).
function cxpPintarDocumentos() {
    const panel = document.getElementById('cxpPanelDocumentos');
    if (!panel) return;

    // "Pendientes de pago" nunca se oculta por fecha (es lo que debes, no
    // caduca por ser de un mes anterior) — a petición del usuario, antes
    // se escondía fuera del rango "inicio de mes a hoy" y avisaba con un
    // banner aparte; ahora simplemente siempre se ve todo. "Pagadas" /
    // "Canceladas" / "Todas" sí respetan el rango elegido (ahí sí es un
    // historial, tiene sentido acotarlo).
    const porProveedor = (x) => !cxpProveedorId || String(x.proveedor_id || '') === cxpProveedorId;
    const porFecha = (x) => (!cxpDesde || (x.fecha || '') >= cxpDesde) && (!cxpHasta || (x.fecha || '') <= cxpHasta);
    const pendientesTodas = cxpCache.filter((x) => x.estatus_cxp === 'pendiente' && porProveedor(x));
    const noPendientesConFecha = cxpCache.filter((x) => x.estatus_cxp !== 'pendiente' && porProveedor(x) && porFecha(x));
    const todasVista = [...pendientesTodas, ...noPendientesConFecha];

    const conteos = {
        pendiente: pendientesTodas.length,
        pagado: noPendientesConFecha.filter((x) => x.estatus_cxp === 'pagado').length,
        cancelado: noPendientesConFecha.filter((x) => x.estatus_cxp === 'cancelado').length,
    };

    const esPendiente = cxpFiltro === 'pendiente';
    const filtrados = esPendiente ? pendientesTodas
        : cxpFiltro === 'todas' ? todasVista
        : noPendientesConFecha.filter((x) => x.estatus_cxp === cxpFiltro);
    const totalGeneral = filtrados.reduce((a, x) => a + Number(x.saldo || 0), 0);

    aplicarOrden(cxpOrden, filtrados, (x, campo) => {
        switch (campo) {
            case 'tipo': return x.tipo || '';
            case 'folio': return (x.folio || String(x.id)).toLowerCase();
            case 'proveedor': return (x.proveedor_nombre || '').toLowerCase();
            case 'fecha': return x.fecha || '';
            case 'total': return Number(x.total || 0);
            case 'pagado': return Number(x.pagado || 0);
            case 'saldo': return Number(x.saldo || 0);
            default: return x.id;
        }
    });

    const pills = CXP_FILTROS.map((f) => {
        const n = f.v === 'todas' ? todasVista.length : (conteos[f.v] || 0);
        const on = f.v === cxpFiltro;
        return `<button type="button" class="cxp-filtro-btn text-xs px-3 py-1.5 rounded-lg border transition ${on ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300 hover:bg-slate-800'}" data-filtro="${f.v}">${f.t} <span class="opacity-70">(${n})</span></button>`;
    }).join('');

    const proveedoresUnicos = new Map();
    cxpCache.forEach((x) => { if (x.proveedor_id && !proveedoresUnicos.has(x.proveedor_id)) proveedoresUnicos.set(x.proveedor_id, x.proveedor_nombre || `#${x.proveedor_id}`); });
    const optProveedor = '<option value="">— todos los proveedores —</option>' +
        [...proveedoresUnicos.entries()]
            .sort((a, b) => a[1].localeCompare(b[1], 'es'))
            .map(([id, nombre]) => `<option value="${id}" ${cxpProveedorId === String(id) ? 'selected' : ''}>${esc(nombre)}</option>`).join('');

    const estatusBadge = (x) => x.estatus_cxp === 'cancelado'
        ? '<span class="text-[10px] text-rose-400 font-semibold">CANCELADO</span>'
        : x.estatus_cxp === 'pagado'
            ? '<span class="text-[10px] text-emerald-400 font-semibold">PAGADO</span>'
            : '';

    panel.innerHTML = `
      <div class="flex items-center justify-between mb-2 flex-wrap gap-2">
        <h3 class="text-md font-semibold text-slate-300">Documentos por pagar</h3>
        <span class="text-xs text-slate-400">${esPendiente ? 'Saldo total' : 'Suma'}: <span class="font-mono text-amber-300">${money(totalGeneral)}</span></span>
      </div>
      <div class="flex flex-wrap items-end gap-2 mb-3">
        <div><label class="block text-[10px] text-slate-400 mb-1">Desde</label>
          <input type="date" id="cxpDesde" value="${cxpDesde}" ${esPendiente ? 'disabled' : ''} class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 disabled:opacity-40"></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">Hasta</label>
          <input type="date" id="cxpHasta" value="${cxpHasta}" ${esPendiente ? 'disabled' : ''} class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 disabled:opacity-40"></div>
        <div class="min-w-[200px]"><label class="block text-[10px] text-slate-400 mb-1">Proveedor</label>
          <select id="cxpFiltroProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">${optProveedor}</select></div>
        <button type="button" id="cxpLimpiarFiltros" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg">Limpiar</button>
      </div>
      ${esPendiente ? '<p class="text-[10px] text-slate-500 mb-3">"Desde/Hasta" no aplica aquí — pendientes de pago siempre se ven todos, sin importar la fecha.</p>' : ''}
      <div class="flex flex-wrap gap-2 mb-3">${pills}</div>
      ${filtrados.length ? `
      <div class="overflow-x-auto border border-slate-800 rounded-lg">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            ${esPendiente ? '<th class="p-2"><input type="checkbox" id="cxpAll" class="accent-emerald-500"></th>' : '<th class="p-2">Estatus</th>'}
            ${thOrden(cxpOrden, 'tipo', 'Tipo')}${thOrden(cxpOrden, 'folio', 'Folio')}${thOrden(cxpOrden, 'proveedor', 'Proveedor')}${thOrden(cxpOrden, 'fecha', 'Fecha')}
            ${thOrden(cxpOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpOrden, 'pagado', 'Pagado', 'text-right justify-end')}${thOrden(cxpOrden, 'saldo', 'Saldo', 'text-right justify-end')}
            <th class="p-2">Póliza / Recibo</th>
            ${esPendiente ? '<th class="p-2">Monto a pagar</th>' : ''}
          </tr></thead>
          <tbody id="cxpBody">
            ${filtrados.map((x) => {
                const pre = esPendiente && cxpPreOcCache && x.tipo === 'compra' && Number(x.orden_compra_id) === Number(cxpPreOcCache);
                const verPoliza = x.poliza_id
                    ? `<button type="button" onclick="window.verPolizaDeDocumento(${x.poliza_id}, '${x.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${x.poliza_id}</button>`
                    : '';
                const verDoc = x.tipo === 'compra'
                    ? `<button type="button" onclick="window.abrirDetalleDocumentoGlobal(${x.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded cursor-pointer">Ver recibo</button>`
                    : '';
                return `
                <tr class="border-b border-slate-900 ${x.estatus_cxp === 'cancelado' ? 'opacity-60' : ''}" data-tipo="${x.tipo}" data-id="${x.id}" data-saldo="${x.saldo}">
                  ${esPendiente
                      ? `<td class="p-2 text-center"><input type="checkbox" class="cxp-chk accent-emerald-500 w-4 h-4" ${pre ? 'checked' : ''}></td>`
                      : `<td class="p-2">${estatusBadge(x)}</td>`}
                  <td class="p-2">${x.tipo}</td>
                  <td class="p-2">${x.tipo === 'compra' ? linkDoc(x.id, x.folio || '#' + x.id, 'font-mono text-slate-200') : `<span class="font-mono text-slate-200">${esc(x.folio || '#' + x.id)}</span>`}</td>
                  <td class="p-2">${esc(x.proveedor_nombre || '—')}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${x.fecha || ''}</td>
                  <td class="p-2 text-right font-mono">${money(x.total)}</td>
                  <td class="p-2 text-right font-mono text-slate-500">${money(x.pagado)}</td>
                  <td class="p-2 text-right font-mono text-amber-300">${money(x.saldo)}</td>
                  <td class="p-2"><div class="flex flex-col gap-1">${verPoliza}${verDoc}${!verPoliza && !verDoc ? '<span class="text-slate-500">—</span>' : ''}</div></td>
                  ${esPendiente ? `<td class="p-2"><input type="number" step="0.01" min="0" class="cxp-monto w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-right font-mono text-slate-100" value="${Number(x.saldo).toFixed(2)}"></td>` : ''}
                </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>
      ${esPendiente ? `
      <div class="flex items-center justify-between mt-3">
        <span class="text-sm text-slate-300">Total a pagar: <span id="cxpTotalPagar" class="font-mono text-emerald-400 font-semibold">$0.00</span></span>
        <button type="button" id="cxpRegistrar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2.5 rounded-lg text-sm">Registrar pago</button>
      </div>` : ''}
      ` : `<p class="text-slate-500 text-sm">No hay documentos en "${CXP_FILTROS.find((f) => f.v === cxpFiltro)?.t.toLowerCase()}" con los filtros de fecha/proveedor elegidos.</p>`}
      <p id="cxpMsg" class="text-xs mt-2 min-h-[1rem]"></p>
    `;

    panel.querySelectorAll('.cxp-filtro-btn').forEach((b) => {
        b.onclick = () => { cxpFiltro = b.dataset.filtro; cxpPintarDocumentos(); };
    });
    document.getElementById('cxpDesde').onchange = (e) => { cxpDesde = e.target.value; cxpPintarDocumentos(); };
    document.getElementById('cxpHasta').onchange = (e) => { cxpHasta = e.target.value; cxpPintarDocumentos(); };
    document.getElementById('cxpFiltroProveedor').onchange = (e) => { cxpProveedorId = e.target.value; cxpPintarDocumentos(); };
    document.getElementById('cxpLimpiarFiltros').onclick = () => { cxpDesde = ''; cxpHasta = ''; cxpProveedorId = ''; cxpPintarDocumentos(); };
    wireOrdenTabla(panel, cxpOrden, cxpPintarDocumentos);

    if (!esPendiente || !filtrados.length) return;

    const recalcTot = () => {
        let t = 0;
        document.querySelectorAll('#cxpBody tr').forEach((tr) => {
            if (!tr.querySelector('.cxp-chk').checked) return;
            t += parseFloat(tr.querySelector('.cxp-monto').value) || 0;
        });
        const el = document.getElementById('cxpTotalPagar');
        if (el) el.textContent = money(t);
    };
    document.getElementById('cxpAll').onchange = (e) => {
        document.querySelectorAll('#cxpBody .cxp-chk').forEach((c) => { c.checked = e.target.checked; });
        recalcTot();
    };
    document.querySelectorAll('#cxpBody .cxp-chk, #cxpBody .cxp-monto').forEach((el) => el.addEventListener('input', recalcTot));
    document.getElementById('cxpRegistrar').onclick = registrarPago;
    recalcTot();
}

async function registrarPago() {
    const msg = document.getElementById('cxpMsg');
    msg.textContent = ''; msg.className = 'text-xs mt-2 min-h-[1rem]';
    const cuenta = document.getElementById('cxpCuenta').value;
    if (!cuenta) { msg.textContent = 'Elige la cuenta de banco / caja.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const aplicaciones = [];
    let err = '';
    document.querySelectorAll('#cxpBody tr').forEach(tr => {
        if (!tr.querySelector('.cxp-chk').checked) return;
        const monto = parseFloat(tr.querySelector('.cxp-monto').value) || 0;
        const saldo = parseFloat(tr.dataset.saldo) || 0;
        if (monto <= 0) { err = err || 'Hay un monto en cero en una fila marcada.'; return; }
        if (monto > saldo + 0.01) { err = err || 'Un monto supera el saldo pendiente.'; return; }
        aplicaciones.push({ tipo: tr.dataset.tipo, id: Number(tr.dataset.id), monto });
    });
    if (!aplicaciones.length) { msg.textContent = 'Marca al menos un documento a pagar.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    if (err) { msg.textContent = err; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('cxpRegistrar');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_pago_proveedor', {
            p_datos: {
                fecha: document.getElementById('cxpFecha').value || hoyISO(),
                cuenta_pago_id: Number(cuenta),
                forma_pago: document.getElementById('cxpForma').value || null,
                referencia: document.getElementById('cxpRef').value.trim() || null,
                aplicaciones,
            },
        });
        if (error) throw error;
        alert(`✅ Pago registrado por ${money(data.total)} (${aplicaciones.length} documento(s)). Póliza de Egreso generada.`);
        await cargarModuloPagosProveedor();
    } catch (e) {
        msg.textContent = 'No se pudo registrar el pago: ' + (e.message || e);
        msg.className = 'text-xs mt-2 text-rose-400';
        btn.disabled = false;
    }
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
                  <td class="p-2">${p.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${p.poliza_id}, '${p.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${p.poliza_id}</button>` : '<span class="text-slate-500">—</span>'}</td>
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

// =====================================================================
//  Anticipo a proveedor (se paga ANTES de recibir la mercancía). Antes
//  vivía como botón por fila en Órdenes de compra; a petición del usuario
//  esa pantalla ya solo muestra estatus (Recibido/Pagado) + Cancelar, así
//  que este es ahora el único punto de entrada — se elige la OC aquí en
//  vez de llegar con ella preseleccionada. Misma función del lado de la
//  base (pagar_anticipo_oc, sql/2026-10-27_anticipo_proveedores.sql).
// =====================================================================
async function cxpAbrirAnticipo() {
    let ocs = [];
    try {
        const { data, error } = await supabaseClient.from('ordenes_compra')
            .select('id, folio, proveedores ( nombre )')
            .in('estatus', ['abierta', 'recibida_parcial'])
            .order('id', { ascending: false });
        if (error) throw error;
        ocs = data || [];
    } catch (e) {
        alert('No se pudieron cargar las órdenes de compra: ' + (e.message || e));
        return;
    }
    if (!ocs.length) { alert('No hay órdenes de compra abiertas o parcialmente recibidas para pagarles un anticipo.'); return; }

    const optOc = '<option value="">— elige una orden de compra —</option>' +
        ocs.map((o) => `<option value="${o.id}">${esc(o.folio || '#' + o.id)} · ${esc(o.proveedores?.nombre || '—')}</option>`).join('');
    const optCta = '<option value="">— caja / banco —</option>' +
        cxpCuentasPago.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cxpMostrarModal(`
      <div class="bg-slate-900 border border-slate-700 rounded-2xl p-4 max-w-md w-full">
        <h3 class="text-base font-bold text-slate-100 mb-1">💰 Pagar anticipo a proveedor</h3>
        <p class="text-xs text-slate-400 mb-3">Se paga ANTES de recibir la mercancía; al recibirla, el anticipo se aplica solo contra el pasivo que se reconozca.</p>
        <div class="space-y-2">
          <div><label class="block text-[10px] text-slate-400 mb-1">Orden de compra</label>
            <select id="cxpAntOc" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optOc}</select></div>
          <p id="cxpAntInfo" class="text-[11px] text-emerald-400 min-h-[1rem]"></p>
          <div><label class="block text-[10px] text-slate-400 mb-1">Fecha</label>
            <input type="date" id="cxpAntFecha" value="${hoyISO()}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Monto a pagar</label>
            <input type="number" step="0.01" min="0.01" id="cxpAntMonto" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Cuenta (banco / caja)</label>
            <select id="cxpAntCuenta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optCta}</select></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Forma de pago</label>
            <select id="cxpAntForma" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <option value="">—</option><option>transferencia</option><option>efectivo</option><option>cheque</option><option>tarjeta</option></select></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Referencia</label>
            <input type="text" id="cxpAntRef" placeholder="No. de transferencia / cheque" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
        </div>
        <p id="cxpAntMsg" class="text-xs mt-2 min-h-[1rem] text-rose-400"></p>
        <div class="flex justify-end gap-2 mt-3">
          <button type="button" onclick="window.cxpAntCerrar()" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-2 rounded-lg">Cancelar</button>
          <button type="button" id="cxpAntGuardar" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Registrar pago</button>
        </div>
      </div>`);

    document.getElementById('cxpAntOc').onchange = async (e) => {
        const id = e.target.value;
        const info = document.getElementById('cxpAntInfo');
        if (!id) { info.textContent = ''; return; }
        try {
            const { data } = await supabaseClient.from('v_anticipos_oc').select('disponible').eq('orden_compra_id', Number(id)).maybeSingle();
            info.textContent = data && Number(data.disponible) > 0 ? `Ya tiene ${money(data.disponible)} de anticipo disponible sin aplicar.` : '';
        } catch (_) { info.textContent = ''; }
    };

    document.getElementById('cxpAntGuardar').onclick = async () => {
        const msg = document.getElementById('cxpAntMsg');
        const ocId = document.getElementById('cxpAntOc').value;
        const monto = parseFloat(document.getElementById('cxpAntMonto').value);
        const cuenta = document.getElementById('cxpAntCuenta').value;
        if (!ocId) { msg.textContent = 'Elige la orden de compra.'; return; }
        if (!(monto > 0)) { msg.textContent = 'Captura un monto mayor a cero.'; return; }
        if (!cuenta) { msg.textContent = 'Elige la cuenta de banco / caja.'; return; }
        const btn = document.getElementById('cxpAntGuardar');
        btn.disabled = true;
        try {
            const { data, error } = await supabaseClient.rpc('pagar_anticipo_oc', {
                p_oc_id: Number(ocId),
                p_datos: {
                    fecha: document.getElementById('cxpAntFecha').value || hoyISO(),
                    monto,
                    cuenta_pago_id: Number(cuenta),
                    forma_pago: document.getElementById('cxpAntForma').value || null,
                    referencia: document.getElementById('cxpAntRef').value.trim() || null,
                },
            });
            if (error) throw error;
            alert(`✅ Anticipo pagado por ${money(data.total)}. Póliza de Egreso generada.`);
            window.cxpAntCerrar();
            await cargarModuloPagosProveedor();
        } catch (e) {
            msg.textContent = 'No se pudo registrar el anticipo: ' + (e.message || e);
            btn.disabled = false;
        }
    };
}

function cxpMostrarModal(html) {
    let wrap = document.getElementById('cxpModalWrap');
    if (!wrap) {
        wrap = document.createElement('div');
        wrap.id = 'cxpModalWrap';
        wrap.className = 'fixed inset-0 bg-slate-950/40 flex items-center justify-center z-50 p-4';
        document.body.appendChild(wrap);
    }
    wrap.innerHTML = html;
}
window.cxpAntCerrar = () => { document.getElementById('cxpModalWrap')?.remove(); };
