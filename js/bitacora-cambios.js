import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
//  Bitácora de cambios — consulta de public.bitacora_cambios, que ya se
//  llena sola vía trigger (fn_bitacora_generica) en las tablas sensibles
//  a fraude/error: cuentas contables, tarifas ISR, cierre de periodo,
//  activos fijos, devoluciones, pedidos de venta y cuentas bancarias.
//  Solo lectura — nadie puede alterar ni borrar el rastro (ni el admin):
//  la tabla solo admite INSERT desde el trigger (security definer).
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const bitOrden = crearOrdenTabla('creado_at', 'desc');
let bitFiltroTabla = '';
let bitFiltroAccion = '';
let bitFilas = [];

const TABLAS_CON_BITACORA = [
    { v: '', t: 'Todas las tablas' },
    { v: 'cuentas_contables', t: 'Plan de cuentas' },
    { v: 'isr_tarifas', t: 'Tarifas ISR' },
    { v: 'isr_tarifa_tramos', t: 'Tramos ISR' },
    { v: 'periodos_contables', t: 'Cierre de periodo' },
    { v: 'activos_fijos', t: 'Activos fijos' },
    { v: 'devoluciones_cliente', t: 'Devoluciones de cliente' },
    { v: 'devoluciones_proveedor', t: 'Devoluciones a proveedor' },
    { v: 'pedidos_venta', t: 'Pedidos de venta' },
    { v: 'cuentas_bancarias', t: 'Cuentas bancarias' },
];

const ACCION_ESTILO = {
    INSERT: 'text-emerald-300 bg-emerald-950/40',
    UPDATE: 'text-amber-300 bg-amber-950/40',
    DELETE: 'text-rose-300 bg-rose-950/40',
};

export async function cargarModuloBitacora() {
    const cont = document.getElementById('contenedorBitacora');
    if (!cont) return;

    const optsTabla = TABLAS_CON_BITACORA.map((t) => `<option value="${t.v}">${esc(t.t)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Tabla</label>
            <select id="bitTabla" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optsTabla}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Acción</label>
            <select id="bitAccion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">Todas</option>
              <option value="INSERT">Alta</option>
              <option value="UPDATE">Modificación</option>
              <option value="DELETE">Baja</option>
            </select></div>
          <div class="flex items-end"><button type="button" id="bitConsultar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2 rounded-lg text-sm">Consultar</button></div>
        </div>
      </div>
      <div id="bitLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
    </div>`;

    document.getElementById('bitConsultar').onclick = () => {
        bitFiltroTabla = document.getElementById('bitTabla').value;
        bitFiltroAccion = document.getElementById('bitAccion').value;
        bitCargar();
    };

    await bitCargar();
    montarGuia(cont, 'bitacora-cambios');
}

async function bitCargar() {
    const cont = document.getElementById('bitLista');
    cont.innerHTML = '<p class="text-slate-500 text-sm">Consultando...</p>';
    try {
        let q = supabaseClient.from('bitacora_cambios').select('*').order('creado_at', { ascending: false }).limit(300);
        if (bitFiltroTabla) q = q.eq('tabla', bitFiltroTabla);
        if (bitFiltroAccion) q = q.eq('accion', bitFiltroAccion);
        const { data, error } = await q;
        if (error) throw error;
        bitFilas = data || [];
        if (!bitFilas.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin movimientos con estos filtros.</p>'; return; }

        aplicarOrden(bitOrden, bitFilas, (r, campo) => {
            switch (campo) {
                case 'tabla': return r.tabla || '';
                case 'accion': return r.accion || '';
                case 'creado_at': return r.creado_at || '';
                default: return r.id;
            }
        });

        cont.innerHTML = `
        <p class="text-xs text-slate-500 mb-2">${bitFilas.length} movimiento(s) — últimos 300 como máximo.</p>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2"></th>${thOrden(bitOrden, 'creado_at', 'Fecha')}${thOrden(bitOrden, 'tabla', 'Tabla')}
              <th class="p-2">Registro</th>${thOrden(bitOrden, 'accion', 'Acción')}<th class="p-2">Usuario</th>
            </tr></thead>
            <tbody>
              ${bitFilas.map((r) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2"><button type="button" onclick="window.bitVerDetalle(${r.id})" class="text-sky-400 hover:text-sky-300 text-[11px]">Ver</button></td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${r.creado_at ? new Date(r.creado_at).toLocaleString('es-MX') : ''}</td>
                  <td class="p-2">${esc(TABLAS_CON_BITACORA.find((t) => t.v === r.tabla)?.t || r.tabla)}</td>
                  <td class="p-2 font-mono text-slate-400">#${r.registro_id ?? '—'}</td>
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${ACCION_ESTILO[r.accion] || 'text-slate-400 bg-slate-800'}">${esc(r.accion)}</span></td>
                  <td class="p-2 font-mono text-[10px] text-slate-500">${r.usuario_id ? esc(String(r.usuario_id).slice(0, 8)) : '—'}</td>
                </tr>
                <tr id="bitDetalle${r.id}" class="hidden border-b border-slate-900">
                  <td></td>
                  <td colspan="5" class="p-2">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
                      <div><p class="text-[10px] text-slate-500 mb-1">Antes</p><pre class="text-[10px] bg-slate-900 border border-slate-800 rounded p-2 overflow-x-auto">${esc(JSON.stringify(r.datos_antes, null, 2) || 'null')}</pre></div>
                      <div><p class="text-[10px] text-slate-500 mb-1">Después</p><pre class="text-[10px] bg-slate-900 border border-slate-800 rounded p-2 overflow-x-auto">${esc(JSON.stringify(r.datos_despues, null, 2) || 'null')}</pre></div>
                    </div>
                  </td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, bitOrden, bitCargar);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.bitVerDetalle = (id) => {
    document.getElementById(`bitDetalle${id}`)?.classList.toggle('hidden');
};
