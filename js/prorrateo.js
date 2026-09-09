import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
// Contabilidad · Prorrateo de gastos indirectos de fabricación (CIF)
//   Fase 2/3 de costos de producción. Elige un mes: junta el CIF
//   pendiente, calcula la distribución a las órdenes por horas de mano
//   de obra (fijo contra capacidad normal, variable contra horas reales)
//   y, al aplicar, genera la póliza de traspaso y ajusta el costo de las
//   órdenes cerradas del periodo.
//   Requiere sql/2026-09-15_costos_produccion_fase2y3.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const fnum = (n, d = 2) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: d });
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;
const MANUAL_URL = 'manual-costos-produccion.html';
const GUIA_URL = 'guia-costos-produccion.html';

const mesActualISO = () => new Date().toISOString().slice(0, 7);

export async function cargarModuloProrrateo() {
    const cont = document.getElementById('contenedorProrrateo');
    if (!cont) return;
    cont.innerHTML = `
      <div class="flex flex-wrap items-end justify-between gap-3 mb-4">
        <div>
          <label class="block text-[11px] text-slate-400 mb-1">Mes a prorratear</label>
          <input type="month" id="prMes" value="${mesActualISO()}" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
        </div>
        <span class="flex gap-2">
          <a href="${GUIA_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">&#9654; Guia interactiva</a>
          <a href="${MANUAL_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">Manual &#8599;</a>
        </span>
      </div>
      <div id="prCuerpo"><p class="text-slate-500 text-sm">Cargando...</p></div>`;

    document.getElementById('prMes').addEventListener('change', prCargar);
    await prCargar();
    montarGuia(cont, 'prorrateo');
}

async function prCargar() {
    const cuerpo = document.getElementById('prCuerpo');
    const mes = document.getElementById('prMes').value || mesActualISO();
    const periodo = `${mes}-01`;
    cuerpo.innerHTML = `<p class="text-slate-500 text-sm">Calculando ${mes}...</p>`;

    let pool, corrida, calc, err;
    try {
        [pool, corrida, calc] = await Promise.all([
            supabaseClient.from('gastos')
                .select('id, concepto, subtotal, cif_tipo, prorrateo_estatus, cuenta_gasto:cuentas_contables!cuenta_gasto_id(codigo, nombre, cif_tipo)')
                .eq('clasificacion', 'indirecto_produccion').eq('estatus', 'registrado')
                .gte('fecha', periodo).lt('fecha', prSiguienteMes(periodo)).order('fecha'),
            supabaseClient.from('prorrateo_corridas').select('*').eq('periodo', periodo).eq('estatus', 'aplicado').maybeSingle(),
            supabaseClient.rpc('prorrateo_calcular', { p_periodo: periodo }),
        ]);
        err = pool.error || calc.error;
    } catch (e) { err = e; }

    if (err) {
        cuerpo.innerHTML = TABLA_FALTA.test(err.message || '')
            ? `<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-15_costos_produccion_fase2y3.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-xs">${esc(err.message || String(err))}</p>`;
        return;
    }

    const gastos = pool.data || [];
    const cor = corrida && corrida.data ? corrida.data : null;
    const filas = calc.data || [];
    const pendientes = gastos.filter(g => g.prorrateo_estatus === 'pendiente');
    const prorrateados = gastos.filter(g => g.prorrateo_estatus === 'prorrateado');
    const tipoDe = (g) => g.cif_tipo || g.cuenta_gasto?.cif_tipo || null;

    const tot = (arr) => arr.reduce((s, g) => s + Number(g.subtotal || 0), 0);
    const baseLista = cor ? prorrateados : pendientes;
    const totFijo = tot(baseLista.filter(g => tipoDe(g) === 'fijo'));
    const totVar = tot(baseLista.filter(g => tipoDe(g) === 'variable'));
    const totOtro = tot(baseLista) - totFijo - totVar;

    // agrupar el cálculo (preview)
    const porOrden = new Map();
    let ociosa = 0, aplicado = 0;
    filas.forEach(f => {
        if (f.es_capacidad_ociosa) { ociosa += Number(f.monto || 0); return; }
        aplicado += Number(f.monto || 0);
        const k = f.orden_produccion_id;
        if (!porOrden.has(k)) porOrden.set(k, { folio: f.orden_folio, horas: Number(f.horas_orden || 0), monto: 0 });
        porOrden.get(k).monto += Number(f.monto || 0);
    });
    const horasCentro = filas.length ? Number(filas[0].horas_centro || 0) : 0;
    const capNormal = filas.length ? Number(filas[0].capacidad_normal || 0) : 0;
    const util = filas.length ? filas[0].utilizacion : null;

    let html = '';

    if (cor) {
        html += `<div class="bg-emerald-950/30 border border-emerald-800 rounded-xl p-3 mb-4 flex flex-wrap items-center justify-between gap-2">
            <div class="text-sm">
              <span class="text-emerald-400 font-semibold">Prorrateo aplicado</span>
              <span class="text-slate-400"> &middot; poliza #${cor.poliza_id ?? '-'} &middot; aplicado ${money(cor.total_aplicado)} &middot; ociosidad ${money(cor.total_ocioso)} &middot; ${cor.gastos_incluidos} gasto(s)</span>
            </div>
            <button type="button" id="prCancelar" class="text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-3 py-1.5 rounded-lg">Cancelar prorrateo del mes</button>
          </div>`;
    }

    html += `
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-4">
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[11px] text-slate-400">CIF ${cor ? 'del mes' : 'pendiente'}</p>
          <p class="text-lg font-mono text-slate-100">${money(totFijo + totVar + totOtro)}</p>
          <p class="text-[11px] text-slate-500">fijo ${money(totFijo)} &middot; variable ${money(totVar)}${baseLista.length ? '' : ' &middot; sin gastos'}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[11px] text-slate-400">Horas de mano de obra del mes</p>
          <p class="text-lg font-mono text-slate-100">${fnum(horasCentro, 1)} h</p>
          <p class="text-[11px] text-slate-500">capacidad normal ${fnum(capNormal, 0)} h &middot; utilizacion ${util != null ? fnum(util * 100, 0) + '%' : '-'}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[11px] text-slate-400">Distribucion</p>
          <p class="text-lg font-mono text-emerald-400">${money(aplicado)}</p>
          <p class="text-[11px] text-slate-500">a ordenes &middot; capacidad no utilizada <span class="text-amber-400">${money(ociosa)}</span></p>
        </div>
      </div>`;

    if (baseLista.length) {
        html += `<h3 class="text-sm font-semibold text-slate-300 mb-2">Gastos indirectos ${cor ? 'incluidos' : 'pendientes'} &mdash; ${mes}</h3>
          <div class="overflow-x-auto mb-4"><table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
              <th class="p-2">Cuenta</th><th class="p-2">Concepto</th><th class="p-2">Tipo</th><th class="p-2 text-right">Monto</th></tr></thead>
            <tbody>${baseLista.map(g => `
              <tr class="border-b border-slate-900">
                <td class="p-2 font-mono text-slate-400">${esc(g.cuenta_gasto?.codigo || '')}</td>
                <td class="p-2 text-slate-300">${esc(g.concepto)}</td>
                <td class="p-2 ${tipoDe(g) === 'fijo' ? 'text-amber-400' : 'text-slate-400'}">${tipoDe(g) || '-'}</td>
                <td class="p-2 text-right font-mono text-slate-200">${money(g.subtotal)}</td>
              </tr>`).join('')}</tbody>
          </table></div>`;
    } else {
        html += `<p class="text-slate-500 text-sm mb-4">No hay gastos indirectos ${cor ? 'en' : 'pendientes de'} ${mes}. Clasifica un gasto como <span class="text-slate-300">Indirecto de fabricacion</span> en Contabilidad &rarr; Gastos.</p>`;
    }

    if (porOrden.size || ociosa) {
        html += `<h3 class="text-sm font-semibold text-slate-300 mb-2">Distribucion propuesta</h3>
          <div class="overflow-x-auto mb-4"><table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
              <th class="p-2">Destino</th><th class="p-2 text-right">Horas MO</th><th class="p-2 text-right">Factor</th><th class="p-2 text-right">CIF asignado</th></tr></thead>
            <tbody>
              ${[...porOrden.entries()].map(([id, o]) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 text-slate-200">Orden ${esc(o.folio || ('#' + id))}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${fnum(o.horas, 1)}</td>
                  <td class="p-2 text-right font-mono text-slate-500">${horasCentro ? fnum(o.horas / horasCentro * 100, 1) + '%' : '-'}</td>
                  <td class="p-2 text-right font-mono text-emerald-400">${money(o.monto)}</td>
                </tr>`).join('')}
              ${ociosa ? `<tr class="border-b border-slate-900">
                  <td class="p-2 text-amber-400">Capacidad no utilizada &rarr; 503.98 (resultados)</td>
                  <td class="p-2"></td><td class="p-2"></td>
                  <td class="p-2 text-right font-mono text-amber-400">${money(ociosa)}</td>
                </tr>` : ''}
            </tbody>
          </table></div>`;
    }

    if (!cor && pendientes.length) {
        html += `<button type="button" id="prAplicar" class="w-full sm:w-auto bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 px-5 rounded-lg text-sm">Aplicar prorrateo de ${mes}</button>
          <p id="prMsg" class="text-xs min-h-[1rem] mt-2"></p>`;
    }

    document.getElementById('prCuerpo').innerHTML = html;

    const bA = document.getElementById('prAplicar');
    if (bA) bA.addEventListener('click', () => prEjecutar('prorrateo_aplicar', periodo, `Aplicar el prorrateo de ${mes}? Genera la poliza de traspaso y ajusta el costo de las ordenes cerradas del mes.`));
    const bC = document.getElementById('prCancelar');
    if (bC) bC.addEventListener('click', () => prEjecutar('prorrateo_cancelar', periodo, `Cancelar el prorrateo de ${mes}? Se revierte la poliza y los gastos vuelven a quedar pendientes.`));
}

async function prEjecutar(rpc, periodo, confirmar) {
    if (!confirm(confirmar)) return;
    const msg = document.getElementById('prMsg');
    if (msg) { msg.textContent = 'Procesando...'; msg.className = 'text-xs text-slate-400 mt-2'; }
    const { error } = await supabaseClient.rpc(rpc, { p_periodo: periodo });
    if (error) {
        if (msg) { msg.textContent = error.message || String(error); msg.className = 'text-xs text-rose-400 mt-2'; }
        else alert(error.message || String(error));
        return;
    }
    await prCargar();
}

function prSiguienteMes(periodoISO) {
    const d = new Date(periodoISO + 'T00:00:00');
    d.setMonth(d.getMonth() + 1);
    return d.toISOString().slice(0, 10);
}
