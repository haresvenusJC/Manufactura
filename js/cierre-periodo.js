import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
// Contabilidad · Cierre de periodo
//   Revisa los 8 candados de sql/2026-09-23_precierre_periodo_contable.sql
//   (documentos/gastos/nóminas/cobros/pagos sin póliza, auditorías
//   abiertas, pólizas descuadradas) antes de cerrar un mes, y permite
//   reabrirlo si hace falta corregir algo después.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

const mesActualISO = () => new Date().toISOString().slice(0, 7);
const nombreMes = (anio, mes) =>
    new Date(anio, mes - 1, 1).toLocaleDateString('es-MX', { month: 'long', year: 'numeric' });

let cpUltimoResultado = null; // { anio, mes, listo_para_cerrar, candados }

export async function cargarModuloCierrePeriodo() {
    const cont = document.getElementById('contenedorCierrePeriodo');
    if (!cont) return;
    cont.innerHTML = `
      <div class="flex flex-wrap items-end justify-between gap-3 mb-4">
        <div>
          <label class="block text-[11px] text-slate-400 mb-1">Periodo a revisar</label>
          <input type="month" id="cpMes" value="${mesActualISO()}" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
        </div>
        <button type="button" id="cpBtnRevisar" class="text-xs bg-sky-700 hover:bg-sky-600 text-white px-4 py-2 rounded-lg font-semibold cursor-pointer">🔍 Revisar candados</button>
      </div>
      <div id="cpResultado" class="mb-6"></div>
      <div>
        <h3 class="text-sm font-semibold text-slate-300 mb-2">Historial de periodos</h3>
        <div id="cpHistorial" class="text-slate-500 text-sm">Cargando...</div>
      </div>`;

    document.getElementById('cpMes').addEventListener('change', cpRevisar);
    document.getElementById('cpBtnRevisar').addEventListener('click', cpRevisar);
    await cpRevisar();
    await cpCargarHistorial();
    montarGuia(cont, 'cierre-periodo');
}

function cpAnioMes() {
    const v = document.getElementById('cpMes').value || mesActualISO();
    const [anio, mes] = v.split('-').map(Number);
    return { anio, mes };
}

async function cpRevisar() {
    const { anio, mes } = cpAnioMes();
    const resultado = document.getElementById('cpResultado');
    resultado.innerHTML = `<p class="text-slate-500 text-sm">Revisando ${mes}/${anio}...</p>`;
    cpUltimoResultado = null;

    const { data, error } = await supabaseClient.rpc('precierre_periodo_contable', { p_anio: anio, p_mes: mes });
    if (error) {
        resultado.innerHTML = TABLA_FALTA.test(error.message || '')
            ? `<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-23_precierre_periodo_contable.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-xs">${esc(error.message)}</p>`;
        return;
    }
    cpUltimoResultado = data;
    cpPintarResultado();
}

function cpPintarResultado() {
    const resultado = document.getElementById('cpResultado');
    const d = cpUltimoResultado;
    if (!d) return;
    const titulo = nombreMes(d.anio, d.mes);

    if (d.listo_para_cerrar) {
        resultado.innerHTML = `
          <div class="bg-emerald-950/40 border border-emerald-800 rounded-xl p-4">
            <p class="text-emerald-300 font-semibold text-sm capitalize">✅ ${esc(titulo)} está limpio — no hay pendientes contables.</p>
            <button type="button" id="cpBtnCerrar" class="mt-3 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold px-4 py-2 rounded-lg cursor-pointer">🔒 Cerrar periodo</button>
          </div>`;
        document.getElementById('cpBtnCerrar').addEventListener('click', () => cpCerrar(false));
        return;
    }

    resultado.innerHTML = `
      <div class="bg-amber-950/30 border border-amber-800 rounded-xl p-4">
        <p class="text-amber-300 font-semibold text-sm mb-3 capitalize">⚠ ${esc(titulo)} tiene ${d.candados.length} pendiente(s) contable(s):</p>
        <div class="space-y-2 mb-4">
          ${d.candados.map((c) => `
            <details class="bg-slate-950/60 border border-slate-800 rounded-lg">
              <summary class="px-3 py-2 text-xs text-slate-200 cursor-pointer flex justify-between items-center gap-3">
                <span>${esc(c.descripcion)}</span>
                <span class="text-slate-500 shrink-0">${esc(c.cantidad)}</span>
              </summary>
              <div class="px-3 pb-2 text-[11px] text-slate-400 overflow-x-auto">
                ${Array.isArray(c.detalle) && c.detalle.length
                    ? `<table class="w-full mt-1"><tbody>${c.detalle.map((fila) => `
                        <tr class="border-t border-slate-800">${Object.entries(fila).map(([k, v]) => `<td class="py-1 pr-4 whitespace-nowrap">${esc(k)}: <span class="text-slate-300">${esc(v ?? '—')}</span></td>`).join('')}</tr>`).join('')}</tbody></table>`
                    : '<p class="italic text-slate-500">Sin detalle.</p>'}
              </div>
            </details>`).join('')}
        </div>
        <p class="text-xs text-slate-400 mb-2">Resuelve estos pendientes en su propio módulo y vuelve a revisar. Si de verdad necesitas cerrar con ellos así (decisión de negocio), puedes forzar el cierre — queda guardado qué se ignoró, en este historial y en la bitácora.</p>
        <button type="button" id="cpBtnForzar" class="bg-rose-700 hover:bg-rose-600 text-white text-xs font-semibold px-4 py-2 rounded-lg cursor-pointer">🔓 Cerrar de todos modos (forzar)</button>
      </div>`;
    document.getElementById('cpBtnForzar').addEventListener('click', () => cpCerrar(true));
}

async function cpCerrar(forzar) {
    const { anio, mes } = cpAnioMes();
    const titulo = nombreMes(anio, mes);
    const confirmMsg = forzar
        ? `¿Seguro que quieres cerrar ${titulo} con pendientes? Esto queda registrado en la bitácora y no se puede deshacer sin reabrir el periodo.`
        : `¿Cerrar el periodo ${titulo}? Después de cerrarlo no se podrán registrar ni cancelar pólizas con fecha dentro de ese mes hasta reabrirlo.`;
    if (!confirm(confirmMsg)) return;

    const { error } = await supabaseClient.rpc('cerrar_periodo_contable', { p_anio: anio, p_mes: mes, p_forzar: forzar });
    if (error) { alert('No se pudo cerrar: ' + error.message); return; }
    alert(`${titulo} quedó cerrado${forzar ? ' (forzado, con advertencias registradas)' : ''}.`);
    await cpRevisar();
    await cpCargarHistorial();
}

async function cpCargarHistorial() {
    const cont = document.getElementById('cpHistorial');
    const { data, error } = await supabaseClient
        .from('periodos_contables')
        .select('*')
        .order('anio', { ascending: false })
        .order('mes', { ascending: false })
        .limit(24);
    if (error) {
        cont.innerHTML = TABLA_FALTA.test(error.message || '') ? '' : `<p class="text-rose-400 text-xs">${esc(error.message)}</p>`;
        return;
    }
    if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Todavía no se ha cerrado ningún periodo.</p>'; return; }

    cont.innerHTML = `
      <div class="overflow-x-auto border border-slate-800 rounded-lg">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            <th class="p-2">Periodo</th><th class="p-2">Estatus</th><th class="p-2">Cerrado</th><th class="p-2"></th>
          </tr></thead>
          <tbody>
            ${data.map((p) => {
                const forzado = Array.isArray(p.advertencias_forzadas) && p.advertencias_forzadas.length > 0;
                return `
                <tr class="border-b border-slate-900">
                  <td class="p-2 capitalize">${esc(nombreMes(p.anio, p.mes))}</td>
                  <td class="p-2">
                    ${p.cerrado
                        ? `<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-950/40 text-emerald-300">Cerrado</span>${forzado ? ' <span class="text-amber-400" title="Se cerró con pendientes forzados">⚠</span>' : ''}`
                        : '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-800 text-slate-400">Reabierto</span>'}
                  </td>
                  <td class="p-2 text-slate-500 whitespace-nowrap">${p.cerrado_at ? new Date(p.cerrado_at).toLocaleString('es-MX') : '—'}</td>
                  <td class="p-2 text-right">
                    ${p.cerrado ? `<button type="button" class="cp-reabrir text-[11px] bg-slate-800 hover:bg-slate-700 text-amber-300 border border-slate-700 px-2 py-1 rounded cursor-pointer" data-anio="${p.anio}" data-mes="${p.mes}">Reabrir</button>` : ''}
                  </td>
                </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>`;

    cont.querySelectorAll('.cp-reabrir').forEach((btn) => {
        btn.addEventListener('click', () => cpReabrir(Number(btn.dataset.anio), Number(btn.dataset.mes)));
    });
}

async function cpReabrir(anio, mes) {
    const titulo = nombreMes(anio, mes);
    const motivo = prompt(`¿Por qué necesitas reabrir ${titulo}? (queda en la bitácora)`);
    if (!motivo || !motivo.trim()) return;
    const { error } = await supabaseClient.rpc('reabrir_periodo_contable', { p_anio: anio, p_mes: mes, p_motivo: motivo.trim() });
    if (error) { alert('No se pudo reabrir: ' + error.message); return; }
    alert(`${titulo} quedó reabierto.`);
    await cpCargarHistorial();
    await cpRevisar();
}
