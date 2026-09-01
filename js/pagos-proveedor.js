import { supabaseClient } from './supabase.js';

// =====================================================================
//  Cuentas por pagar / Pagos a proveedores
//  Lista compras y gastos a crédito con saldo pendiente y registra el
//  pago (Cargo 201.01 Proveedores / Abono banco) vía registrar_pago_proveedor.
//  Requiere: sql/2026-09-02_pagos_proveedor.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

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

    const preOc = window.__cxpOcPreseleccion || null;
    window.__cxpOcPreseleccion = null;

    const totalGeneral = cxp.reduce((a, x) => a + Number(x.saldo || 0), 0);
    const optCta = '<option value="">— caja / banco —</option>' +
        ctasPago.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
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
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-md font-semibold text-slate-300">Documentos por pagar</h3>
          <span class="text-xs text-slate-400">Saldo total: <span class="font-mono text-amber-300">${money(totalGeneral)}</span></span>
        </div>
        ${cxp.length ? `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2"><input type="checkbox" id="cxpAll" class="accent-emerald-500"></th>
              <th class="p-2">Tipo</th><th class="p-2">Folio</th><th class="p-2">Proveedor</th><th class="p-2">Fecha</th>
              <th class="p-2 text-right">Total</th><th class="p-2 text-right">Pagado</th><th class="p-2 text-right">Saldo</th>
              <th class="p-2">Monto a pagar</th>
            </tr></thead>
            <tbody id="cxpBody">
              ${cxp.map(x => {
                  const pre = preOc && x.tipo === 'compra' && Number(x.orden_compra_id) === Number(preOc);
                  return `
                  <tr class="border-b border-slate-900" data-tipo="${x.tipo}" data-id="${x.id}" data-saldo="${x.saldo}">
                    <td class="p-2 text-center"><input type="checkbox" class="cxp-chk accent-emerald-500 w-4 h-4" ${pre ? 'checked' : ''}></td>
                    <td class="p-2">${x.tipo}</td>
                    <td class="p-2 font-mono text-slate-200">${esc(x.folio || '#' + x.id)}</td>
                    <td class="p-2">${esc(x.proveedor_nombre || '—')}</td>
                    <td class="p-2 whitespace-nowrap text-slate-400">${x.fecha || ''}</td>
                    <td class="p-2 text-right font-mono">${money(x.total)}</td>
                    <td class="p-2 text-right font-mono text-slate-500">${money(x.pagado)}</td>
                    <td class="p-2 text-right font-mono text-amber-300">${money(x.saldo)}</td>
                    <td class="p-2"><input type="number" step="0.01" min="0" class="cxp-monto w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-right font-mono text-slate-100" value="${Number(x.saldo).toFixed(2)}"></td>
                  </tr>`;
              }).join('')}
            </tbody>
          </table>
        </div>
        <div class="flex items-center justify-between mt-3">
          <span class="text-sm text-slate-300">Total a pagar: <span id="cxpTotalPagar" class="font-mono text-emerald-400 font-semibold">$0.00</span></span>
          <button type="button" id="cxpRegistrar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2.5 rounded-lg text-sm">Registrar pago</button>
        </div>
        ` : '<p class="text-slate-500 text-sm">No hay compras ni gastos a crédito pendientes de pago. 🎉</p>'}
        <p id="cxpMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pagos registrados</h3>
        <div id="cxpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('cxpFecha').value = hoyISO();
    if (ctasPago.length === 1) document.getElementById('cxpCuenta').value = ctasPago[0].id;

    const recalcTot = () => {
        let t = 0;
        document.querySelectorAll('#cxpBody tr').forEach(tr => {
            if (!tr.querySelector('.cxp-chk').checked) return;
            t += parseFloat(tr.querySelector('.cxp-monto').value) || 0;
        });
        const el = document.getElementById('cxpTotalPagar');
        if (el) el.textContent = money(t);
    };
    if (cxp.length) {
        document.getElementById('cxpAll').onchange = (e) => {
            document.querySelectorAll('#cxpBody .cxp-chk').forEach(c => { c.checked = e.target.checked; });
            recalcTot();
        };
        document.querySelectorAll('#cxpBody .cxp-chk, #cxpBody .cxp-monto').forEach(el => el.addEventListener('input', recalcTot));
        document.getElementById('cxpRegistrar').onclick = registrarPago;
        recalcTot();
    }

    await cxpHistorial();
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

async function cxpHistorial() {
    const cont = document.getElementById('cxpHist');
    try {
        const { data, error } = await supabaseClient.from('pagos_proveedor')
            .select('id, fecha, total, referencia, forma_pago, estatus, poliza_id, proveedores ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto )')
            .order('id', { ascending: false }).limit(100);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin pagos registrados.</p>'; return; }
        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Fecha</th><th class="p-2">Proveedor</th><th class="p-2">Ref.</th>
              <th class="p-2 text-right">Total</th><th class="p-2 text-center"># Docs</th><th class="p-2">Estatus</th><th class="p-2 text-right">Acción</th>
            </tr></thead>
            <tbody>
              ${data.map(p => `
                <tr class="border-b border-slate-900 ${p.estatus === 'cancelado' ? 'opacity-50' : ''}">
                  <td class="p-2 whitespace-nowrap">${p.fecha || ''}</td>
                  <td class="p-2">${esc(p.proveedores?.nombre || '(varios)')}</td>
                  <td class="p-2 text-slate-400">${esc(p.referencia || '')}</td>
                  <td class="p-2 text-right font-mono">${money(p.total)}</td>
                  <td class="p-2 text-center font-mono text-slate-400">${(p.pagos_proveedor_aplicaciones || []).length}</td>
                  <td class="p-2 ${p.estatus === 'registrado' ? 'text-emerald-400' : 'text-rose-400'}">${esc(p.estatus)}</td>
                  <td class="p-2 text-right">${p.estatus === 'registrado' ? `<button type="button" class="cxp-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded" data-id="${p.id}">Cancelar</button>` : ''}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        cont.querySelectorAll('.cxp-cancel').forEach(b => {
            b.onclick = async () => {
                if (!confirm('¿Cancelar este pago? Se genera la póliza de reverso y los saldos vuelven a quedar pendientes.')) return;
                const { error } = await supabaseClient.rpc('cancelar_pago_proveedor', { p_pago_id: Number(b.dataset.id) });
                if (error) { alert('No se pudo cancelar: ' + error.message); return; }
                await cargarModuloPagosProveedor();
            };
        });
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">Historial no disponible: ${esc(err.message || err)}</p>`;
    }
}
