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
    { v: 'pendiente', t: 'Pendiente' },
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
        // 102.02 (Bancos extranjeros USD) se excluye a propósito: la empresa no tiene cuenta en
        // USD, siempre paga en MXN aunque la OC esté en USD. Se deja en el catálogo para cuando
        // haya expansión a compras/ventas en el extranjero — solo se oculta de este selector.
        ctasPago = (data || []).filter(c => /^(101|102)/.test(c.codigo) && c.codigo !== '102.02');
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

    cont.innerHTML = `
    <div class="space-y-4">
      <div id="cxpPanelDocumentos" class="bg-slate-950 border border-slate-800 rounded-xl p-4"></div>

      <p class="text-xs text-slate-500">
        ¿Vas a pagar antes de recibir la mercancía? Eso no es una deuda todavía, por eso no aparece en la lista de arriba:
        <button type="button" id="cxpBtnAnticipo" class="text-sky-400 hover:text-sky-300 underline">💰 pagar anticipo a una OC sin recibir</button>.
      </p>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pagos registrados</h3>
        <div id="cxpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

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
            case 'vence': return x.vence || '';
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
            ${thOrden(cxpOrden, 'vence', 'Vence')}${thOrden(cxpOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpOrden, 'saldo', 'Saldo', 'text-right justify-end')}
            <th class="p-2">Póliza</th>
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
                const vencida = x.vence && x.estatus_cxp === 'pendiente' && x.vence < hoyISO();
                return `
                <tr class="border-b border-slate-900 ${x.estatus_cxp === 'cancelado' ? 'opacity-60' : ''}" data-tipo="${x.tipo}" data-id="${x.id}" data-saldo="${x.saldo}" data-prov="${x.proveedor_id || ''}" data-prov-nombre="${esc(x.proveedor_nombre || '—')}" data-folio="${esc(x.folio || '#' + x.id)}">
                  ${esPendiente
                      ? `<td class="p-2 text-center"><input type="checkbox" class="cxp-chk accent-emerald-500 w-4 h-4" ${pre ? 'checked' : ''}></td>`
                      : `<td class="p-2">${estatusBadge(x)}</td>`}
                  <td class="p-2">${x.tipo}</td>
                  <td class="p-2">${x.tipo === 'compra' ? linkDoc(x.id, x.folio || '#' + x.id, 'font-mono text-slate-200') : `<span class="font-mono text-slate-200">${esc(x.folio || '#' + x.id)}</span>`}</td>
                  <td class="p-2">${esc(x.proveedor_nombre || '—')}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${x.fecha || ''}</td>
                  <td class="p-2 whitespace-nowrap ${vencida ? 'text-rose-400 font-semibold' : 'text-slate-400'}">${x.vence || '—'}</td>
                  <td class="p-2 text-right font-mono">${money(x.total)}</td>
                  <td class="p-2 text-right font-mono text-amber-300">${money(x.saldo)}</td>
                  <td class="p-2"><div class="flex flex-col gap-1">${verPoliza}${verDoc}${!verPoliza && !verDoc ? '<span class="text-slate-500">—</span>' : ''}</div></td>
                </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>
      ${esPendiente ? `
      <div id="cxpBarraSel" class="hidden items-center justify-between gap-3 flex-wrap mt-3 border border-emerald-700 rounded-lg p-3 bg-slate-900">
        <span class="text-sm text-slate-300"><span id="cxpSelTxt"></span></span>
        <div class="flex gap-2">
          <button type="button" id="cxpLimpiarSel" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-2 rounded-lg">Limpiar</button>
          <button type="button" id="cxpRegistrar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2 rounded-lg text-sm">Pagar selección</button>
        </div>
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

    // Un pago = un proveedor: al marcar uno, los demás proveedores se deshabilitan.
    const seleccionadas = () => Array.from(document.querySelectorAll('#cxpBody tr')).filter((tr) => tr.querySelector('.cxp-chk')?.checked);
    const actualizarSeleccion = () => {
        const marcadas = seleccionadas();
        const prov = marcadas[0]?.dataset.prov || '';
        document.querySelectorAll('#cxpBody tr').forEach((tr) => {
            const chk = tr.querySelector('.cxp-chk');
            if (!chk) return;
            chk.disabled = !!prov && !chk.checked && tr.dataset.prov !== prov;
            tr.classList.toggle('opacity-40', chk.disabled);
        });
        const barra = document.getElementById('cxpBarraSel');
        barra.classList.toggle('hidden', !marcadas.length);
        barra.classList.toggle('flex', marcadas.length > 0);
        const total = marcadas.reduce((a, tr) => a + (parseFloat(tr.dataset.saldo) || 0), 0);
        document.getElementById('cxpSelTxt').textContent = marcadas.length
            ? `${marcadas.length} documento(s) · ${marcadas[0].dataset.provNombre} · saldo ${money(total)}`
            : '';
    };
    document.getElementById('cxpAll').onchange = (e) => {
        document.querySelectorAll('#cxpBody .cxp-chk').forEach((c) => { c.checked = e.target.checked; });
        actualizarSeleccion();
    };
    document.querySelectorAll('#cxpBody .cxp-chk').forEach((el) => el.addEventListener('change', actualizarSeleccion));
    document.getElementById('cxpLimpiarSel').onclick = () => {
        document.querySelectorAll('#cxpBody .cxp-chk').forEach((c) => { c.checked = false; });
        document.getElementById('cxpAll').checked = false;
        actualizarSeleccion();
    };
    document.getElementById('cxpRegistrar').onclick = () => {
        const filas = seleccionadas();
        if (filas.length > 1) cxpAbrirAutorizacion(filas); else cxpAbrirPago(filas);
    };
    actualizarSeleccion();
}

// Pagar varias OC del mismo proveedor en una sola transferencia sigue
// permitido, pero pide autorización del responsable de Finanzas antes de
// abrir el pago (por ahora un campo de texto — más adelante se ligaría al
// usuario que inició sesión con ese rol, sin tener que escribirlo).
function cxpAbrirAutorizacion(filas) {
    const total = filas.reduce((a, tr) => a + (parseFloat(tr.dataset.saldo) || 0), 0);
    cxpMostrarModal(`
      <div class="bg-slate-900 border border-slate-700 rounded-2xl p-4 max-w-md w-full">
        <div class="flex items-start justify-between gap-3 mb-2">
          <h3 class="text-base font-bold text-slate-100">Autorización requerida</h3>
          <button type="button" class="text-slate-400 hover:text-slate-100 text-xl leading-none" onclick="window.cxpAntCerrar()">&times;</button>
        </div>
        <p class="text-xs text-slate-400 mb-3">Vas a pagar ${filas.length} documentos de <b class="text-slate-200">${esc(filas[0].dataset.provNombre)}</b> en una sola transferencia (${money(total)}). Por política, esto necesita el visto bueno del responsable de Finanzas.</p>
        <div><label class="block text-[10px] text-slate-400 mb-1">Autoriza (nombre)</label>
          <input type="text" id="cxpAutNombre" placeholder="Nombre de quien autoriza" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
        <p class="text-[10px] text-sky-400 bg-sky-950/40 border border-sky-900 rounded-lg px-2.5 py-2 mt-2">Por ahora es un campo de texto libre — más adelante se ligaría al usuario que inició sesión con ese rol.</p>
        <p id="cxpAutErr" class="text-xs text-rose-400 min-h-[1rem] mt-1"></p>
        <div class="flex justify-end gap-2 mt-2">
          <button type="button" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-2 rounded-lg" onclick="window.cxpAntCerrar()">Cancelar</button>
          <button type="button" id="cxpAutOk" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Autorizar y continuar</button>
        </div>
      </div>`);
    document.getElementById('cxpAutOk').onclick = () => {
        const nombre = document.getElementById('cxpAutNombre').value.trim();
        if (!nombre) { document.getElementById('cxpAutErr').textContent = 'Escribe quién autoriza.'; return; }
        cxpAbrirPago(filas);
    };
}

// Ventana de pago: total (saldo completo, no editable) o parcial (un solo documento,
// monto editable y acuerdo con el proveedor obligatorio).
function cxpAbrirPago(filas) {
    if (!filas.length) return;
    const docs = filas.map((tr) => ({ tipo: tr.dataset.tipo, id: Number(tr.dataset.id), saldo: parseFloat(tr.dataset.saldo) || 0, folio: tr.dataset.folio, prov: tr.dataset.provNombre }));
    const total = docs.reduce((a, d) => a + d.saldo, 0);
    const provNombre = docs[0].prov;
    const filasHtml = docs.map((d) => `<tr><td class="p-2 font-mono">${esc(d.folio)}</td><td class="p-2 text-right font-mono">${money(d.saldo)}</td></tr>`).join('');
    const opcionesCuenta = cxpCuentasPago.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cxpMostrarModal(`
      <div class="bg-slate-950 border border-slate-700 rounded-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto p-5 space-y-4 shadow-2xl">
        <div class="flex items-start justify-between gap-3">
          <div>
            <h3 class="text-md font-semibold text-emerald-400">Registrar pago a ${esc(provNombre)}</h3>
            <p class="text-xs text-slate-400">${docs.length} documento(s) · saldo ${money(total)}</p>
          </div>
          <button type="button" class="text-slate-400 hover:text-slate-100 text-xl leading-none" onclick="window.cxpAntCerrar()">&times;</button>
        </div>
        <table class="w-full text-xs text-slate-300"><tbody>${filasHtml}</tbody></table>

        <div class="flex gap-2">
          <button type="button" id="cxpTipoTotal" aria-pressed="true" class="text-xs px-3 py-1.5 rounded-lg border bg-sky-600 border-sky-500 text-white">Pago total</button>
          <button type="button" id="cxpTipoParcial" aria-pressed="false" class="text-xs px-3 py-1.5 rounded-lg border bg-slate-900 border-slate-800 text-slate-300">Pago parcial</button>
        </div>
        <div>
          <label class="block text-xs text-slate-400 mb-1">Monto a pagar <span id="cxpMontoHint" class="text-slate-500">· saldo de los documentos</span></label>
          <input type="number" id="cxpMonto" step="0.01" min="0" value="${total.toFixed(2)}" readonly class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm font-mono text-slate-100 opacity-80">
        </div>
        <div id="cxpAcuerdoBox" class="hidden space-y-1">
          <label class="block text-xs text-amber-300">Acuerdo con el proveedor (obligatorio en pago parcial)</label>
          <input type="text" id="cxpAcuerdo" placeholder="Ej. Anticipo 50%, saldo contra entrega, acordado con [contacto]" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
          <p class="text-[10px] text-slate-500">Idealmente esta condición se declara en la OC antes de autorizarla.</p>
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Fecha del pago</label>
            <input type="date" id="cxpFechaPago" value="${hoyISO()}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta (banco / caja)</label>
            <select id="cxpCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">— elige —</option>${opcionesCuenta}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Forma de pago</label>
            <select id="cxpFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="" selected>— elegir —</option><option value="transferencia">transferencia</option><option value="cheque">cheque</option><option value="tarjeta">tarjeta</option><option value="efectivo">efectivo</option></select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Referencia</label>
            <input type="text" id="cxpRefPago" placeholder="No. de transferencia / cheque" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <p id="cxpAlertaEfectivo" class="hidden text-xs text-amber-300 bg-amber-950/40 border border-amber-900 rounded-lg px-2.5 py-2">Pagos en efectivo mayores a $2,000 no son deducibles y su IVA no es acreditable. Confírmalo con tu contador.</p>
        <p id="cxpPagoErr" class="text-xs text-rose-400 min-h-[1rem]"></p>
        <div class="flex justify-end gap-2">
          <button type="button" class="text-sm bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-4 py-2 rounded-lg" onclick="window.cxpAntCerrar()">Cancelar</button>
          <button type="button" id="cxpConfirmarPago" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2 rounded-lg text-sm">Confirmar pago</button>
        </div>
      </div>`);

    let parcial = false;
    const monto = document.getElementById('cxpMonto');
    const err = document.getElementById('cxpPagoErr');
    const validar = () => {
        const m = parseFloat(monto.value) || 0;
        let e = '';
        if (parcial) {
            if (docs.length !== 1) e = 'El pago parcial solo aplica a un documento a la vez.';
            else if (m <= 0) e = 'El monto debe ser mayor a cero.';
            else if (m >= total - 0.005) e = 'Si paga el saldo completo, usa «Pago total».';
            else if (!document.getElementById('cxpAcuerdo').value.trim()) e = 'Escribe el acuerdo con el proveedor.';
        }
        err.textContent = e;
        document.getElementById('cxpConfirmarPago').disabled = !!e;
        const forma = document.getElementById('cxpFormaPago').value;
        document.getElementById('cxpAlertaEfectivo').classList.toggle('hidden', !(forma === 'efectivo' && m > 2000));
    };
    const fijarTipo = (esParcial) => {
        parcial = esParcial;
        document.getElementById('cxpTipoTotal').setAttribute('aria-pressed', String(!parcial));
        document.getElementById('cxpTipoParcial').setAttribute('aria-pressed', String(parcial));
        document.getElementById('cxpTipoTotal').className = `text-xs px-3 py-1.5 rounded-lg border ${!parcial ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300'}`;
        document.getElementById('cxpTipoParcial').className = `text-xs px-3 py-1.5 rounded-lg border ${parcial ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300'}`;
        monto.readOnly = !parcial; monto.classList.toggle('opacity-80', !parcial);
        document.getElementById('cxpAcuerdoBox').classList.toggle('hidden', !parcial);
        document.getElementById('cxpMontoHint').textContent = parcial ? '· menor al saldo' : '· saldo de los documentos';
        monto.value = parcial ? '' : total.toFixed(2);
        validar();
    };
    document.getElementById('cxpTipoTotal').onclick = () => fijarTipo(false);
    document.getElementById('cxpTipoParcial').onclick = () => fijarTipo(true);
    monto.oninput = validar;
    document.getElementById('cxpAcuerdo').oninput = validar;
    document.getElementById('cxpFormaPago').onchange = validar;
    document.getElementById('cxpConfirmarPago').onclick = () => registrarPago(docs, parcial);
    validar();
}

async function registrarPago(docs, parcial) {
    const err = document.getElementById('cxpPagoErr');
    const cuenta = document.getElementById('cxpCuentaPago').value;
    if (!cuenta) { err.textContent = 'Elige la cuenta de banco / caja.'; return; }
    const m = parseFloat(document.getElementById('cxpMonto').value) || 0;
    const acuerdo = document.getElementById('cxpAcuerdo').value.trim();
    const aplicaciones = parcial
        ? [{ tipo: docs[0].tipo, id: docs[0].id, monto: m }]
        : docs.map((d) => ({ tipo: d.tipo, id: d.id, monto: d.saldo }));
    const btn = document.getElementById('cxpConfirmarPago');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_pago_proveedor', {
            p_datos: {
                fecha: document.getElementById('cxpFechaPago').value || hoyISO(),
                cuenta_pago_id: Number(cuenta),
                forma_pago: document.getElementById('cxpFormaPago').value || null,
                referencia: document.getElementById('cxpRefPago').value.trim() || null,
                aplicaciones,
            },
        });
        if (error) throw error;
        if (parcial) {
            const { error: eA } = await supabaseClient.rpc('pago_proveedor_set_acuerdo', { p_pago_id: data.pago_id, p_acuerdo: acuerdo });
            if (eA) alert('El pago se registró, pero no se pudo guardar el acuerdo: ' + eA.message);
        }
        alert(`✅ Pago registrado por ${money(data.total)} (${aplicaciones.length} documento(s)). Póliza de Egreso generada.`);
        window.cxpAntCerrar();
        await cargarModuloPagosProveedor();
    } catch (e) {
        err.textContent = 'No se pudo registrar el pago: ' + (e.message || e);
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
