import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { traerReversos, enSaldo } from './polizas-saldo.js';

// =====================================================================
//  Bancos y Tesorería: catálogo de cuentas bancarias (banco, número,
//  CLABE) ligadas 1:1 a una cuenta contable ya existente, conciliación
//  de sus movimientos (poliza_movimientos, sin tabla aparte) y un
//  flujo proyectado simple: saldo bancos + por cobrar pendiente − por
//  pagar pendiente. No es un forecast con fechas de vencimiento — no
//  existen esas fechas en el modelo hoy; es una fotografía honesta de
//  lo que ya se sabe.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const btOrdenMov = crearOrdenTabla('fecha', 'desc');

let btCuentas = [];
let btCuentaActualId = null;
let btCtaEditId = null;

export async function cargarModuloBancosTesoreria() {
    const cont = document.getElementById('contenedorBancosTesoreria');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';

    let ctasContables = [];
    try {
        const { data } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        ctasContables = (data || []).filter((c) => /^(101|102)/.test(c.codigo));
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar cuentas contables: ${e.message || e}</p>`;
        return;
    }
    const optsCtas = ctasContables.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 id="btFormTitulo" class="text-md font-semibold text-emerald-400 mb-3">Nueva cuenta bancaria</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Banco</label>
            <input type="text" id="btBanco" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Alias</label>
            <input type="text" id="btAlias" placeholder="Ej. Cuenta operativa" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta contable ligada</label>
            <select id="btCtaContable" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsCtas}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Número de cuenta</label>
            <input type="text" id="btNumero" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">CLABE</label>
            <input type="text" id="btClabe" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
          <div class="md:col-span-3"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="btNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="flex gap-2">
          <button type="button" id="btGuardar" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar cuenta bancaria</button>
          <button type="button" id="btCancelarEdicion" class="hidden bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 px-4 rounded-lg text-sm">Cancelar</button>
        </div>
        <p id="btMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div id="btFlujoProyectado" class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <p class="text-slate-500 text-sm">Calculando flujo proyectado...</p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Cuentas bancarias</h3>
        <div id="btLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500 mb-4">Cargando...</div>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Movimientos y conciliación</h3>
        <div id="btMovimientos" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Elige una cuenta bancaria de la lista de arriba.</div>
      </div>
    </div>`;

    document.getElementById('btGuardar').onclick = btGuardarCuenta;
    document.getElementById('btCancelarEdicion').onclick = btResetForm;

    await btRenderLista(ctasContables);
    await btRenderFlujoProyectado();
    montarGuia(cont, 'bancos-tesoreria');
}

function btResetForm() {
    btCtaEditId = null;
    document.getElementById('btFormTitulo').textContent = 'Nueva cuenta bancaria';
    document.getElementById('btBanco').value = '';
    document.getElementById('btAlias').value = '';
    document.getElementById('btCtaContable').value = '';
    document.getElementById('btNumero').value = '';
    document.getElementById('btClabe').value = '';
    document.getElementById('btNotas').value = '';
    document.getElementById('btGuardar').textContent = 'Guardar cuenta bancaria';
    document.getElementById('btCancelarEdicion').classList.add('hidden');
}

async function btGuardarCuenta() {
    const msg = document.getElementById('btMsg');
    const banco = document.getElementById('btBanco').value.trim();
    const alias = document.getElementById('btAlias').value.trim();
    const ctaId = document.getElementById('btCtaContable').value ? parseInt(document.getElementById('btCtaContable').value) : null;
    if (!banco || !alias) { msg.textContent = 'Banco y alias son obligatorios.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    if (!ctaId) { msg.textContent = 'Elige la cuenta contable ligada.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const payload = {
        banco, alias, cuenta_contable_id: ctaId,
        numero_cuenta: document.getElementById('btNumero').value.trim() || null,
        clabe: document.getElementById('btClabe').value.trim() || null,
        notas: document.getElementById('btNotas').value.trim() || null,
    };
    try {
        let error;
        if (btCtaEditId) ({ error } = await supabaseClient.from('cuentas_bancarias').update(payload).eq('id', btCtaEditId));
        else ({ error } = await supabaseClient.from('cuentas_bancarias').insert([payload]));
        if (error) throw error;
        msg.textContent = btCtaEditId ? 'Cuenta actualizada.' : 'Cuenta guardada.';
        msg.className = 'text-xs mt-2 text-emerald-400';
        btResetForm();
        const { data } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        await btRenderLista((data || []).filter((c) => /^(101|102)/.test(c.codigo)));
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    }
}

async function btRenderLista(ctasContables) {
    btCuentas = [];
    const cont = document.getElementById('btLista');
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_bancarias')
            .select('id, banco, alias, numero_cuenta, clabe, activa, cuenta_contable_id, cuentas_contables ( codigo, nombre )')
            .order('id', { ascending: false });
        if (error) throw error;
        btCuentas = data || [];
        if (!btCuentas.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin cuentas bancarias registradas.</p>'; return; }

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2"></th><th class="p-2">Alias</th><th class="p-2">Banco</th><th class="p-2">Número</th>
              <th class="p-2">Cuenta contable</th><th class="p-2 text-right">Saldo</th>
            </tr></thead>
            <tbody id="btListaBody">${btCuentas.map((c) => `<tr class="border-b border-slate-900" data-id="${c.id}"><td colspan="6" class="p-2 text-slate-500">calculando...</td></tr>`).join('')}</tbody>
          </table>
        </div>`;

        for (const c of btCuentas) {
            const saldo = await btSaldoCuenta(c.cuenta_contable_id);
            const fila = cont.querySelector(`tr[data-id="${c.id}"]`);
            if (!fila) continue;
            fila.innerHTML = `
                <td class="p-2"><button type="button" onclick="window.btEditarCuenta(${c.id})" class="text-[11px] text-sky-400 hover:text-sky-300">Editar</button></td>
                <td class="p-2"><button type="button" onclick="window.btVerMovimientos(${c.id})" class="text-slate-100 hover:underline text-left">${esc(c.alias)}</button></td>
                <td class="p-2 text-slate-400">${esc(c.banco)}</td>
                <td class="p-2 font-mono text-slate-500">${esc(c.numero_cuenta || '—')}</td>
                <td class="p-2 text-slate-400">${esc(c.cuentas_contables?.codigo || '')} · ${esc(c.cuentas_contables?.nombre || '')}</td>
                <td class="p-2 text-right font-mono ${saldo < 0 ? 'text-rose-400' : 'text-emerald-400'}">${money(saldo)}</td>`;
        }
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

async function btSaldoCuenta(cuentaContableId) {
    const [{ data }, reversos] = await Promise.all([
        supabaseClient.from('poliza_movimientos').select('cargo, abono, polizas!inner ( id, estatus )').eq('cuenta_id', cuentaContableId),
        traerReversos(),
    ]);
    return (data || []).filter((m) => enSaldo(m.polizas, reversos))
        .reduce((a, m) => a + Number(m.cargo || 0) - Number(m.abono || 0), 0);
}

window.btEditarCuenta = (id) => {
    const c = btCuentas.find((x) => x.id === id);
    if (!c) return;
    btCtaEditId = id;
    document.getElementById('btFormTitulo').textContent = 'Editar cuenta bancaria';
    document.getElementById('btBanco').value = c.banco || '';
    document.getElementById('btAlias').value = c.alias || '';
    document.getElementById('btCtaContable').value = c.cuenta_contable_id || '';
    document.getElementById('btNumero').value = c.numero_cuenta || '';
    document.getElementById('btClabe').value = c.clabe || '';
    document.getElementById('btNotas').value = c.notas || '';
    document.getElementById('btGuardar').textContent = 'Actualizar cuenta bancaria';
    document.getElementById('btCancelarEdicion').classList.remove('hidden');
    document.getElementById('btBanco').scrollIntoView({ behavior: 'smooth', block: 'start' });
};

window.btVerMovimientos = async (id) => {
    btCuentaActualId = id;
    const c = btCuentas.find((x) => x.id === id);
    const cont = document.getElementById('btMovimientos');
    if (!c || !cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando movimientos...</p>';
    try {
        const [{ data, error }, reversos] = await Promise.all([supabaseClient
            .from('poliza_movimientos')
            .select('id, cargo, abono, concepto, conciliado, fecha_conciliacion, referencia_banco, polizas!inner ( id, estatus, fecha, numero, tipo, concepto )')
            .eq('cuenta_id', c.cuenta_contable_id)
            .order('id', { ascending: true }), traerReversos()]);
        if (error) throw error;
        // Misma regla que la balanza: borradores y canceladas sin reverso no cuentan.
        const movs = (data || []).filter((m) => enSaldo(m.polizas, reversos));
        let saldo = 0;
        movs.forEach((m) => { saldo += Number(m.cargo || 0) - Number(m.abono || 0); m._saldo = saldo; });
        movs.reverse();

        cont.innerHTML = `
        <p class="text-xs text-slate-400 mb-2"><strong class="text-slate-200">${esc(c.alias)}</strong> — ${esc(c.banco)} · saldo actual ${money(saldo)}</p>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Fecha</th><th class="p-2">Concepto</th><th class="p-2 text-right">Cargo</th><th class="p-2 text-right">Abono</th>
              <th class="p-2 text-right">Saldo</th><th class="p-2 text-center">Conciliado</th><th class="p-2">Referencia banco</th>
            </tr></thead>
            <tbody>
              ${movs.map((m) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 whitespace-nowrap text-slate-400">${m.polizas?.fecha || ''}</td>
                  <td class="p-2 text-slate-300">${esc(m.concepto || m.polizas?.concepto || '')}</td>
                  <td class="p-2 text-right font-mono">${Number(m.cargo) > 0 ? money(m.cargo) : ''}</td>
                  <td class="p-2 text-right font-mono">${Number(m.abono) > 0 ? money(m.abono) : ''}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${money(m._saldo)}</td>
                  <td class="p-2 text-center"><input type="checkbox" class="bt-conciliado accent-emerald-500" data-id="${m.id}" ${m.conciliado ? 'checked' : ''}></td>
                  <td class="p-2"><input type="text" class="bt-referencia w-28 bg-slate-900 border border-slate-800 rounded px-1.5 py-1 text-[11px] text-slate-100" data-id="${m.id}" value="${esc(m.referencia_banco || '')}" placeholder="ref."></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;

        cont.querySelectorAll('.bt-conciliado').forEach((chk) => {
            chk.onchange = async () => {
                await supabaseClient.from('poliza_movimientos').update({
                    conciliado: chk.checked, fecha_conciliacion: chk.checked ? new Date().toISOString().slice(0, 10) : null,
                }).eq('id', Number(chk.dataset.id));
            };
        });
        cont.querySelectorAll('.bt-referencia').forEach((inp) => {
            inp.onchange = async () => {
                await supabaseClient.from('poliza_movimientos').update({ referencia_banco: inp.value.trim() || null }).eq('id', Number(inp.dataset.id));
            };
        });
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
};

async function btRenderFlujoProyectado() {
    const cont = document.getElementById('btFlujoProyectado');
    try {
        const { data: cuentas } = await supabaseClient.from('cuentas_bancarias').select('cuenta_contable_id');
        let saldoBancos = 0;
        for (const c of cuentas || []) saldoBancos += await btSaldoCuenta(c.cuenta_contable_id);

        const { data: ventas } = await supabaseClient.from('documentos').select('total_cobrado, subtotal, iva').eq('tipo_movimiento', 'salida_venta').neq('estado', 'cancelado');
        const porCobrar = (ventas || []).reduce((a, d) => a + Math.max(0, (Number(d.subtotal || 0) + Number(d.iva || 0)) - Number(d.total_cobrado || 0)), 0);

        const { data: compras } = await supabaseClient.from('documentos').select('total_pagado, subtotal, iva').eq('tipo_movimiento', 'entrada_compra').neq('estado', 'cancelado');
        const { data: gastosCredito } = await supabaseClient.from('gastos').select('total_pagado, subtotal, iva, ieps, ret_iva, ret_isr').eq('condicion', 'credito').neq('estatus', 'cancelado');
        const porPagarCompras = (compras || []).reduce((a, d) => a + Math.max(0, (Number(d.subtotal || 0) + Number(d.iva || 0)) - Number(d.total_pagado || 0)), 0);
        const porPagarGastos = (gastosCredito || []).reduce((a, g) => a + Math.max(0, (Number(g.subtotal || 0) + Number(g.iva || 0) + Number(g.ieps || 0) - Number(g.ret_iva || 0) - Number(g.ret_isr || 0)) - Number(g.total_pagado || 0)), 0);
        const porPagar = porPagarCompras + porPagarGastos;

        const proyectado = saldoBancos + porCobrar - porPagar;

        cont.innerHTML = `
          <h3 class="text-md font-semibold text-emerald-400 mb-3">Flujo proyectado (simple)</h3>
          <p class="text-[11px] text-slate-500 mb-3">No es un pronóstico con fechas — es lo que ya se sabe hoy: saldo de tus cuentas + lo que te deben − lo que debes, sin vencimientos.</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3"><span class="block text-[10px] text-slate-500">Saldo en bancos</span><span class="font-mono ${saldoBancos < 0 ? 'text-rose-400' : 'text-slate-100'}">${money(saldoBancos)}</span></div>
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3"><span class="block text-[10px] text-slate-500">Por cobrar pendiente</span><span class="font-mono text-emerald-400">${money(porCobrar)}</span></div>
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3"><span class="block text-[10px] text-slate-500">Por pagar pendiente</span><span class="font-mono text-rose-400">${money(porPagar)}</span></div>
            <div class="bg-slate-900 border border-emerald-800 rounded-lg p-3"><span class="block text-[10px] text-slate-500">Saldo proyectado</span><span class="font-mono font-semibold ${proyectado < 0 ? 'text-rose-400' : 'text-emerald-300'}">${money(proyectado)}</span></div>
          </div>`;
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al calcular el flujo proyectado: ${esc(err.message || err)}</p>`;
    }
}
