import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { abrirAsistenteProrrateo } from './asistente-prorrateo.js';

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
        <span class="flex flex-wrap gap-2 items-center">
          <button type="button" id="prAsistente" class="text-sm font-semibold bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg shadow cursor-pointer whitespace-nowrap">&#129517; Asistente de llenado</button>
          <a href="${GUIA_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">&#9654; Guia interactiva</a>
          <a href="${MANUAL_URL}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg whitespace-nowrap">Manual &#8599;</a>
        </span>
      </div>
      <div id="prCuerpo"><p class="text-slate-500 text-sm">Cargando...</p></div>`;

    document.getElementById('prMes').addEventListener('change', prCargar);
    document.getElementById('prAsistente').addEventListener('click', () => abrirAsistenteProrrateo('inicio', prCargar));
    await prCargar();
    montarGuia(cont, 'prorrateo');
}

async function prCargar() {
    const cuerpo = document.getElementById('prCuerpo');
    const mes = document.getElementById('prMes').value || mesActualISO();
    const periodo = `${mes}-01`;
    cuerpo.innerHTML = `<p class="text-slate-500 text-sm">Calculando ${mes}...</p>`;

    let pool, corrida, calc, centros, areas, err;
    try {
        [pool, corrida, calc, centros, areas] = await Promise.all([
            supabaseClient.from('gastos')
                .select('id, concepto, subtotal, cif_tipo, prorrateo_estatus, cuenta_gasto:cuentas_contables!cuenta_gasto_id(codigo, nombre, cif_tipo)')
                .eq('clasificacion', 'indirecto_produccion').eq('estatus', 'registrado')
                .gte('fecha', periodo).lt('fecha', prSiguienteMes(periodo)).order('fecha'),
            supabaseClient.from('prorrateo_corridas').select('*').eq('periodo', periodo).eq('estatus', 'aplicado').maybeSingle(),
            supabaseClient.rpc('prorrateo_calcular', { p_periodo: periodo }),
            supabaseClient.from('centros_costo').select('id, codigo, nombre, capacidad_normal_horas').eq('tipo', 'produccion').eq('activo', true),
            supabaseClient.from('areas_fisicas').select('id, codigo, rol, m2, activo, centro_costo_id'),
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
    const porCentro = new Map();
    let ociosa = 0, aplicado = 0;
    filas.forEach(f => {
        const kc = f.centro_costo_id;
        if (!porCentro.has(kc)) porCentro.set(kc, { horas: Number(f.horas_centro || 0), cap: Number(f.capacidad_normal || 0), util: f.utilizacion, aplicado: 0, ocioso: 0 });
        if (f.es_capacidad_ociosa) porCentro.get(kc).ocioso += Number(f.monto || 0);
        else porCentro.get(kc).aplicado += Number(f.monto || 0);
        if (f.es_capacidad_ociosa) { ociosa += Number(f.monto || 0); return; }
        aplicado += Number(f.monto || 0);
        const k = f.orden_produccion_id;
        if (!porOrden.has(k)) porOrden.set(k, { folio: f.orden_folio, horas: Number(f.horas_orden || 0), monto: 0 });
        porOrden.get(k).monto += Number(f.monto || 0);
    });
    const horasCentro = [...porCentro.values()].reduce((s, c) => s + c.horas, 0);
    const capNormal = [...porCentro.values()].reduce((s, c) => s + c.cap, 0);
    const util = capNormal > 0 ? horasCentro / capNormal : null;
    const ctrs = centros && centros.data ? centros.data : [];
    const arsData = areas && areas.data ? areas.data : [];
    const centroCod = (id) => ctrs.find(c => c.id === id)?.codigo || ('#' + id);

    // ¿Listo para prorratear? — avisos rápidos de lo que falta (con atajo al paso del asistente)
    const faltan = [];
    const sinCap = ctrs.filter(c => !(Number(c.capacidad_normal_horas) > 0));
    if (!ctrs.length || sinCap.length) faltan.push(['centros', ctrs.length ? `Sin capacidad normal: ${sinCap.map(c => esc(c.codigo)).join(', ')}` : 'No hay etapas (centros de costo) de producción']);
    const arAct = arsData.filter(a => a.activo);
    if (!arAct.length || arAct.some(a => !(Number(a.m2) > 0)) || !arAct.some(a => a.rol === 'no_produccion') || arAct.some(a => a.rol === 'produccion' && !a.centro_costo_id)) {
        faltan.push(['areas', 'Áreas incompletas (m², etapa u oficina)']);
    }
    const sinTipoPend = (cor ? prorrateados : pendientes).filter(g => !tipoDe(g));
    if (sinTipoPend.length) faltan.push(['revision', `${sinTipoPend.length} gasto(s) sin tipo fijo/variable (se tratan como variables)`]);
    let html = faltan.length
        ? `<div class="mb-4 border border-amber-800 bg-amber-950/20 rounded-xl p-3 text-xs text-amber-300 flex flex-wrap items-center justify-between gap-2">
            <div><b>Antes de aplicar, revisa:</b> ${faltan.map(([, t]) => `&#9888; ${t}`).join(' &middot; ')}</div>
            <button type="button" data-pr-paso="${faltan[0][0]}" class="text-xs bg-sky-600 hover:bg-sky-500 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer whitespace-nowrap">Resolver con el asistente</button>
          </div>`
        : '';

    if (cor) {
        html += `<div class="bg-emerald-950/30 border border-emerald-800 rounded-xl p-3 mb-4 flex flex-wrap items-center justify-between gap-2">
            <div class="text-sm">
              <span class="text-emerald-400 font-semibold">Prorrateo aplicado</span>
              <span class="text-slate-400"> &middot; ${cor.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${cor.poliza_id}, null)" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-0.5 rounded cursor-pointer"><span data-pol-id="${cor.poliza_id}">póliza…</span></button>` : 'poliza #-'} &middot; aplicado ${money(cor.total_aplicado)} &middot; ociosidad ${money(cor.total_ocioso)} &middot; ${cor.gastos_incluidos} gasto(s)</span>
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
          <p class="text-[11px] text-slate-400">Horas de mano de obra del mes (todas las etapas)</p>
          <p class="text-lg font-mono text-slate-100">${fnum(horasCentro, 1)} h</p>
          <p class="text-[11px] text-slate-500">capacidad normal ${fnum(capNormal, 0)} h &middot; utilizacion ${util != null ? fnum(util * 100, 0) + '%' : '-'}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[11px] text-slate-400">Distribucion</p>
          <p class="text-lg font-mono text-emerald-400">${money(aplicado)}</p>
          <p class="text-[11px] text-slate-500">a ordenes &middot; capacidad no utilizada <span class="text-amber-400">${money(ociosa)}</span></p>
        </div>
      </div>`;

    if (porCentro.size) {
        html += `<h3 class="text-sm font-semibold text-slate-300 mb-2">Por etapa (centro de costo)</h3>
          <div class="overflow-x-auto mb-4"><table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
              <th class="p-2">Etapa</th><th class="p-2 text-right">Horas reales</th><th class="p-2 text-right">Capacidad normal</th><th class="p-2 text-right">Utilización</th><th class="p-2 text-right">CIF a órdenes</th><th class="p-2 text-right">Capacidad no utilizada</th></tr></thead>
            <tbody>${[...porCentro.entries()].map(([id, c]) => `
              <tr class="border-b border-slate-900">
                <td class="p-2 font-mono text-slate-200">${esc(centroCod(id))}</td>
                <td class="p-2 text-right font-mono text-slate-300">${fnum(c.horas, 1)} h</td>
                <td class="p-2 text-right font-mono ${c.cap > 0 ? 'text-slate-400' : 'text-amber-400'}">${c.cap > 0 ? fnum(c.cap, 0) + ' h' : '0 &#9888;'}</td>
                <td class="p-2 text-right font-mono text-slate-400">${c.util != null ? fnum(c.util * 100, 0) + '%' : '-'}</td>
                <td class="p-2 text-right font-mono text-emerald-400">${money(c.aplicado)}</td>
                <td class="p-2 text-right font-mono text-amber-400">${money(c.ocioso)}</td>
              </tr>`).join('')}</tbody>
          </table></div>`;
    }

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

    cuerpo.querySelectorAll('[data-pr-paso]').forEach(b => b.addEventListener('click', () => abrirAsistenteProrrateo(b.dataset.prPaso, prCargar)));
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
