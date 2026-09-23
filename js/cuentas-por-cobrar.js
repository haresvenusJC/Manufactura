import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { linkDoc, linkPoliza } from './enlaces-reporte.js';

// =====================================================================
//  Cuentas por Cobrar / Cobros a clientes
//  Espejo de pagos-proveedor.js: lista ventas a crédito con saldo
//  pendiente y registra el cobro (Cargo banco / Abono 105.01 Clientes)
//  vía registrar_cobro_cliente.
//  Requiere: sql/2026-09-14e_cuentas_por_cobrar.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Estado del filtro de visibilidad (Pendientes / Pagadas / Canceladas / Todas)
// y el último dataset traído, para poder refiltrar sin volver a consultar.
let cxcCache = [];
let cxcFiltro = 'pendiente';
let cxcDesde = primerDiaMesISO();
let cxcHasta = hoyISO();
let cxcClienteId = '';
const CXC_FILTROS = [
    { v: 'pendiente', t: 'Pendientes de cobro' },
    { v: 'pagado', t: 'Cobradas' },
    { v: 'cancelado', t: 'Canceladas' },
    { v: 'todas', t: 'Todas' },
];
const cxcOrden = crearOrdenTabla();
const cxcHistOrden = crearOrdenTabla('id', 'desc');

export async function cargarModuloCuentasPorCobrar() {
    const cont = document.getElementById('contenedorCuentasPorCobrar');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';

    let ctasCobro = [];
    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        ctasCobro = (data || []).filter(c => /^(101|102)/.test(c.codigo));
    } catch (_) {
        cont.innerHTML = '<p class="text-amber-400 text-xs">El módulo de contabilidad no está instalado (faltan las cuentas contables).</p>';
        return;
    }

    let cxc = [];
    try {
        const { data, error } = await supabaseClient.from('v_cuentas_por_cobrar').select('*').order('fecha', { ascending: true });
        if (error) throw error;
        cxc = data || [];
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-14e_cuentas_por_cobrar.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    cxcCache = cxc;
    cxcFiltro = 'pendiente';
    cxcDesde = primerDiaMesISO(); cxcHasta = hoyISO(); cxcClienteId = '';

    const optCta = '<option value="">— caja / banco —</option>' +
        ctasCobro.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="flex flex-wrap items-end gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Fecha del cobro</label>
            <input type="date" id="cxcFecha" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta (banco / caja)</label>
            <select id="cxcCuenta" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCta}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Forma de cobro</label>
            <select id="cxcForma" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">—</option><option>transferencia</option><option>efectivo</option><option>cheque</option><option>tarjeta</option></select></div>
          <div class="flex-1 min-w-[160px]"><label class="block text-xs text-slate-400 mb-1">Referencia</label>
            <input type="text" id="cxcRef" placeholder="No. de transferencia / recibo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
      </div>

      <div id="cxcPanelDocumentos" class="bg-slate-950 border border-slate-800 rounded-xl p-4"></div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Cobros registrados</h3>
        <div id="cxcHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('cxcFecha').value = hoyISO();
    if (ctasCobro.length === 1) document.getElementById('cxcCuenta').value = ctasCobro[0].id;

    cxcPintarDocumentos();
    await cxcHistorial();
    montarGuia(cont, 'cuentas-por-cobrar');
}

// Repinta solo el panel "Ventas por cobrar" según cxcFiltro, sin volver a
// consultar Supabase (cxcCache ya trae todos los estatus).
function cxcPintarDocumentos() {
    const panel = document.getElementById('cxcPanelDocumentos');
    if (!panel) return;

    const porFechaCli = cxcCache.filter((x) =>
        (!cxcDesde || (x.fecha || '') >= cxcDesde) &&
        (!cxcHasta || (x.fecha || '') <= cxcHasta) &&
        (!cxcClienteId || String(x.cliente_id || '') === cxcClienteId)
    );

    const conteos = { pendiente: 0, pagado: 0, cancelado: 0 };
    porFechaCli.forEach((x) => { if (conteos[x.estatus_cxc] != null) conteos[x.estatus_cxc]++; });

    const filtrados = cxcFiltro === 'todas' ? porFechaCli : porFechaCli.filter((x) => x.estatus_cxc === cxcFiltro);
    const esPendiente = cxcFiltro === 'pendiente';
    // Aviso: pendientes de fechas fuera del rango (el default es el mes actual) para no perder saldos viejos.
    const fueraRango = cxcCache.filter((x) => x.estatus_cxc === 'pendiente'
        && (!cxcClienteId || String(x.cliente_id || '') === cxcClienteId)
        && (((cxcDesde && (x.fecha || '') < cxcDesde)) || (cxcHasta && (x.fecha || '') > cxcHasta)));
    const totalGeneral = filtrados.reduce((a, x) => a + Number(x.saldo || 0), 0);

    aplicarOrden(cxcOrden, filtrados, (x, campo) => {
        switch (campo) {
            case 'folio': return (x.folio || String(x.id)).toLowerCase();
            case 'cliente': return (x.cliente_nombre || '').toLowerCase();
            case 'fecha': return x.fecha || '';
            case 'total': return Number(x.total || 0);
            case 'cobrado': return Number(x.cobrado || 0);
            case 'saldo': return Number(x.saldo || 0);
            default: return x.id;
        }
    });

    const pills = CXC_FILTROS.map((f) => {
        const n = f.v === 'todas' ? porFechaCli.length : (conteos[f.v] || 0);
        const on = f.v === cxcFiltro;
        return `<button type="button" class="cxc-filtro-btn text-xs px-3 py-1.5 rounded-lg border transition ${on ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300 hover:bg-slate-800'}" data-filtro="${f.v}">${f.t} <span class="opacity-70">(${n})</span></button>`;
    }).join('');

    const clientesUnicos = new Map();
    cxcCache.forEach((x) => { if (x.cliente_id && !clientesUnicos.has(x.cliente_id)) clientesUnicos.set(x.cliente_id, x.cliente_nombre || `#${x.cliente_id}`); });
    const optCliente = '<option value="">— todos los clientes —</option>' +
        [...clientesUnicos.entries()]
            .sort((a, b) => a[1].localeCompare(b[1], 'es'))
            .map(([id, nombre]) => `<option value="${id}" ${cxcClienteId === String(id) ? 'selected' : ''}>${esc(nombre)}</option>`).join('');

    const estatusBadge = (x) => x.estatus_cxc === 'cancelado'
        ? '<span class="text-[10px] text-rose-400 font-semibold">CANCELADO</span>'
        : x.estatus_cxc === 'pagado'
            ? '<span class="text-[10px] text-emerald-400 font-semibold">COBRADO</span>'
            : '';

    panel.innerHTML = `
      <div class="flex items-center justify-between mb-2 flex-wrap gap-2">
        <h3 class="text-md font-semibold text-slate-300">Ventas por cobrar</h3>
        <span class="text-xs text-slate-400">${esPendiente ? 'Saldo total' : 'Suma'}: <span class="font-mono text-amber-300">${money(totalGeneral)}</span></span>
      </div>
      <div class="flex flex-wrap items-end gap-2 mb-3">
        <div><label class="block text-[10px] text-slate-400 mb-1">Desde</label>
          <input type="date" id="cxcDesde" value="${cxcDesde}" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">Hasta</label>
          <input type="date" id="cxcHasta" value="${cxcHasta}" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
        <div class="min-w-[200px]"><label class="block text-[10px] text-slate-400 mb-1">Cliente</label>
          <select id="cxcFiltroCliente" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">${optCliente}</select></div>
        <button type="button" id="cxcLimpiarFiltros" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg">Limpiar</button>
      </div>
      <div class="flex flex-wrap gap-2 mb-3">${pills}</div>
      ${fueraRango.length ? `<div class="mb-3 text-xs text-amber-300 bg-amber-950/30 border border-amber-800 rounded-lg px-3 py-2">⚠ Hay ${fueraRango.length} ventas pendientes fuera del rango de fechas (saldo ${money(fueraRango.reduce((a, x) => a + Number(x.saldo || 0), 0))}). <button type="button" id="cxcVerFueraRango" class="underline hover:text-amber-200">Ver todas las fechas</button></div>` : ''}
      ${filtrados.length ? `
      <div class="overflow-x-auto border border-slate-800 rounded-lg">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            ${esPendiente ? '<th class="p-2"><input type="checkbox" id="cxcAll" class="accent-emerald-500"></th>' : '<th class="p-2">Estatus</th>'}
            ${thOrden(cxcOrden, 'folio', 'Folio')}${thOrden(cxcOrden, 'cliente', 'Cliente')}${thOrden(cxcOrden, 'fecha', 'Fecha')}
            ${thOrden(cxcOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxcOrden, 'cobrado', 'Cobrado', 'text-right justify-end')}${thOrden(cxcOrden, 'saldo', 'Saldo', 'text-right justify-end')}
            <th class="p-2">Póliza / Recibo</th>
            ${esPendiente ? '<th class="p-2">Monto a cobrar</th>' : ''}
          </tr></thead>
          <tbody id="cxcBody">
            ${filtrados.map((x) => {
                const verPoliza = x.poliza_id
                    ? `<button type="button" onclick="window.verPolizaDeDocumento(${x.poliza_id}, '${x.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${x.poliza_id}</button>`
                    : '';
                const verDoc = `<button type="button" onclick="window.abrirDetalleDocumentoGlobal(${x.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded cursor-pointer">Ver venta</button>`;
                return `
                <tr class="border-b border-slate-900 ${x.estatus_cxc === 'cancelado' ? 'opacity-60' : ''}" data-id="${x.id}" data-saldo="${x.saldo}">
                  ${esPendiente
                      ? `<td class="p-2 text-center"><input type="checkbox" class="cxc-chk accent-emerald-500 w-4 h-4"></td>`
                      : `<td class="p-2">${estatusBadge(x)}</td>`}
                  <td class="p-2">${linkDoc(x.id, x.folio || '#' + x.id, 'font-mono text-slate-200')}</td>
                  <td class="p-2">${esc(x.cliente_nombre || '—')}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${x.fecha || ''}</td>
                  <td class="p-2 text-right font-mono">${money(x.total)}</td>
                  <td class="p-2 text-right font-mono text-slate-500">${money(x.cobrado)}</td>
                  <td class="p-2 text-right font-mono text-amber-300">${money(x.saldo)}</td>
                  <td class="p-2"><div class="flex flex-col gap-1">${verPoliza}${verDoc}</div></td>
                  ${esPendiente ? `<td class="p-2"><input type="number" step="0.01" min="0" class="cxc-monto w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-right font-mono text-slate-100" value="${Number(x.saldo).toFixed(2)}"></td>` : ''}
                </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>
      ${esPendiente ? `
      <div class="flex items-center justify-between mt-3">
        <span class="text-sm text-slate-300">Total a cobrar: <span id="cxcTotalCobrar" class="font-mono text-emerald-400 font-semibold">$0.00</span></span>
        <button type="button" id="cxcRegistrar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2.5 rounded-lg text-sm">Registrar cobro</button>
      </div>` : ''}
      ` : `<p class="text-slate-500 text-sm">No hay ventas en "${CXC_FILTROS.find((f) => f.v === cxcFiltro)?.t.toLowerCase()}" con los filtros de fecha/cliente elegidos.</p>`}
      <p id="cxcMsg" class="text-xs mt-2 min-h-[1rem]"></p>
    `;

    panel.querySelectorAll('.cxc-filtro-btn').forEach((b) => {
        b.onclick = () => { cxcFiltro = b.dataset.filtro; cxcPintarDocumentos(); };
    });
    document.getElementById('cxcDesde').onchange = (e) => { cxcDesde = e.target.value; cxcPintarDocumentos(); };
    document.getElementById('cxcHasta').onchange = (e) => { cxcHasta = e.target.value; cxcPintarDocumentos(); };
    document.getElementById('cxcFiltroCliente').onchange = (e) => { cxcClienteId = e.target.value; cxcPintarDocumentos(); };
    document.getElementById('cxcVerFueraRango')?.addEventListener('click', () => { cxcDesde = ''; cxcHasta = ''; cxcPintarDocumentos(); });
    document.getElementById('cxcLimpiarFiltros').onclick = () => { cxcDesde = ''; cxcHasta = ''; cxcClienteId = ''; cxcPintarDocumentos(); };
    wireOrdenTabla(panel, cxcOrden, cxcPintarDocumentos);

    if (!esPendiente || !filtrados.length) return;

    const recalcTot = () => {
        let t = 0;
        document.querySelectorAll('#cxcBody tr').forEach((tr) => {
            if (!tr.querySelector('.cxc-chk').checked) return;
            t += parseFloat(tr.querySelector('.cxc-monto').value) || 0;
        });
        const el = document.getElementById('cxcTotalCobrar');
        if (el) el.textContent = money(t);
    };
    document.getElementById('cxcAll').onchange = (e) => {
        document.querySelectorAll('#cxcBody .cxc-chk').forEach((c) => { c.checked = e.target.checked; });
        recalcTot();
    };
    document.querySelectorAll('#cxcBody .cxc-chk, #cxcBody .cxc-monto').forEach((el) => el.addEventListener('input', recalcTot));
    document.getElementById('cxcRegistrar').onclick = registrarCobro;
    recalcTot();
}

async function registrarCobro() {
    const msg = document.getElementById('cxcMsg');
    msg.textContent = ''; msg.className = 'text-xs mt-2 min-h-[1rem]';
    const cuenta = document.getElementById('cxcCuenta').value;
    if (!cuenta) { msg.textContent = 'Elige la cuenta de banco / caja.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const aplicaciones = [];
    let err = '';
    document.querySelectorAll('#cxcBody tr').forEach(tr => {
        if (!tr.querySelector('.cxc-chk').checked) return;
        const monto = parseFloat(tr.querySelector('.cxc-monto').value) || 0;
        const saldo = parseFloat(tr.dataset.saldo) || 0;
        if (monto <= 0) { err = err || 'Hay un monto en cero en una fila marcada.'; return; }
        if (monto > saldo + 0.01) { err = err || 'Un monto supera el saldo pendiente.'; return; }
        aplicaciones.push({ id: Number(tr.dataset.id), monto });
    });
    if (!aplicaciones.length) { msg.textContent = 'Marca al menos una venta a cobrar.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    if (err) { msg.textContent = err; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('cxcRegistrar');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_cobro_cliente', {
            p_datos: {
                fecha: document.getElementById('cxcFecha').value || hoyISO(),
                cuenta_cobro_id: Number(cuenta),
                forma_pago: document.getElementById('cxcForma').value || null,
                referencia: document.getElementById('cxcRef').value.trim() || null,
                aplicaciones,
            },
        });
        if (error) throw error;
        alert(`✅ Cobro registrado por ${money(data.total)} (${aplicaciones.length} venta(s)). Póliza de Ingreso generada.`);
        await cargarModuloCuentasPorCobrar();
    } catch (e) {
        msg.textContent = 'No se pudo registrar el cobro: ' + (e.message || e);
        msg.className = 'text-xs mt-2 text-rose-400';
        btn.disabled = false;
    }
}

async function cxcHistorial() {
    const cont = document.getElementById('cxcHist');
    try {
        const { data, error } = await supabaseClient.from('cobros_cliente')
            .select('id, fecha, total, referencia, forma_pago, estatus, poliza_id, clientes ( nombre ), cobros_cliente_aplicaciones ( monto )')
            .order('id', { ascending: false }).limit(100);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin cobros registrados.</p>'; return; }

        aplicarOrden(cxcHistOrden, data, (p, campo) => {
            switch (campo) {
                case 'fecha': return p.fecha || '';
                case 'cliente': return (p.clientes?.nombre || '').toLowerCase();
                case 'ref': return (p.referencia || '').toLowerCase();
                case 'total': return Number(p.total || 0);
                case 'docs': return (p.cobros_cliente_aplicaciones || []).length;
                case 'estatus': return p.estatus || '';
                default: return p.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(cxcHistOrden, 'fecha', 'Fecha')}${thOrden(cxcHistOrden, 'cliente', 'Cliente')}${thOrden(cxcHistOrden, 'ref', 'Ref.')}
              ${thOrden(cxcHistOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxcHistOrden, 'docs', '# Ventas', 'text-center justify-center')}<th class="p-2">Póliza</th>${thOrden(cxcHistOrden, 'estatus', 'Estatus')}
            </tr></thead>
            <tbody>
              ${data.map(p => `
                <tr class="border-b border-slate-900 ${p.estatus === 'cancelado' ? 'opacity-50' : ''}">
                  <td class="p-2">${p.estatus === 'registrado' ? `<button type="button" class="cxc-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded" data-id="${p.id}">Cancelar</button>` : ''}</td>
                  <td class="p-2 whitespace-nowrap">${p.fecha || ''}</td>
                  <td class="p-2">${esc(p.clientes?.nombre || '(varios)')}</td>
                  <td class="p-2 text-slate-400">${esc(p.referencia || '')}</td>
                  <td class="p-2 text-right font-mono">${money(p.total)}</td>
                  <td class="p-2 text-center font-mono text-slate-400">${(p.cobros_cliente_aplicaciones || []).length}</td>
                  <td class="p-2">${p.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${p.poliza_id}, '${p.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${p.poliza_id}</button>` : '<span class="text-slate-500">—</span>'}</td>
                  <td class="p-2 ${p.estatus === 'registrado' ? 'text-emerald-400' : 'text-rose-400'}">${esc(p.estatus)}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        cont.querySelectorAll('.cxc-cancel').forEach(b => {
            b.onclick = async () => {
                if (!confirm('¿Cancelar este cobro? Se genera la póliza de reverso y los saldos vuelven a quedar pendientes.')) return;
                const { error } = await supabaseClient.rpc('cancelar_cobro_cliente', { p_cobro_id: Number(b.dataset.id) });
                if (error) { alert('No se pudo cancelar: ' + error.message); return; }
                await cargarModuloCuentasPorCobrar();
            };
        });
        wireOrdenTabla(cont, cxcHistOrden, cxcHistorial);
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">Historial no disponible: ${esc(err.message || err)}</p>`;
    }
}
