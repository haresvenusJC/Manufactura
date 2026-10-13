// =====================================================================
//  Compras → Pagos a proveedores: CONSULTA de los pagos ya hechos (solo lectura).
//  Para que Compras sepa qué orden ya está pagada y pueda reclamar la mercancía
//  (columna "Mercancía"). Quien ejecuta, concilia y CANCELA los pagos es Finanzas
//  (Finanzas → Cuentas por pagar, botón "Ver"): aquí no hay botón Cancelar.
//  Mes actual por default, filtro por proveedor y paginado en el servidor
//  (regla de optimizar cargas: solo se trae lo que se muestra).
// =====================================================================
import { supabaseClient } from './supabase.js';
import { linkPoliza, linkDoc } from './enlaces-reporte.js';
import { cxpImprimirComprobante } from './pagos-proveedor.js';

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const hoyISO = () => new Date().toISOString().slice(0, 10);
const inicioMesISO = () => hoyISO().slice(0, 8) + '01';
const POR_PAGINA = 50;

let pcDesde = '';
let pcHasta = '';
let pcProveedor = '';
let pcPagina = 0;
let pcProveedores = [];

export async function cargarModuloPagosCompras() {
    const cont = document.getElementById('contenedorPagosCompras');
    if (!cont) return;
    pcDesde = inicioMesISO(); pcHasta = hoyISO(); pcProveedor = ''; pcPagina = 0;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const { data } = await supabaseClient.from('proveedores').select('id, nombre').order('nombre');
        pcProveedores = data || [];
    } catch (_) { pcProveedores = []; }
    pcPintarMarco(cont);
    await pcCargarTabla();
}

function pcPintarMarco(cont) {
    const optProv = '<option value="">Todos los proveedores</option>' + pcProveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
    const inp = 'bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100';
    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
        <p class="text-xs text-slate-400">Pagos que Finanzas ya hizo a proveedores. Úsalo para saber qué orden está pagada y cuándo reclamar la mercancía. Los pagos se registran y se cancelan en Finanzas → Cuentas por pagar.</p>
        <div class="flex flex-wrap items-end gap-3">
          <div><label class="block text-[10px] text-slate-400 mb-1">Desde</label><input type="date" id="pcDesde" value="${pcDesde}" class="${inp}"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Hasta</label><input type="date" id="pcHasta" value="${pcHasta}" class="${inp}"></div>
          <div class="w-64"><label class="block text-[10px] text-slate-400 mb-1">Proveedor</label><select id="pcProveedor" class="w-full ${inp}">${optProv}</select></div>
          <button type="button" id="pcAplicar" class="text-xs bg-sky-600 hover:bg-sky-500 text-white font-medium px-4 py-1.5 rounded-lg">Filtrar</button>
        </div>
        <div id="pcTabla">Cargando...</div>
      </div>`;
    const aplicar = () => {
        pcDesde = document.getElementById('pcDesde').value; pcHasta = document.getElementById('pcHasta').value;
        pcProveedor = document.getElementById('pcProveedor').value; pcPagina = 0;
        pcCargarTabla();
    };
    document.getElementById('pcAplicar').onclick = aplicar;
    document.getElementById('pcProveedor').onchange = aplicar;
}

// Mercancía: un pago a un documento ya recibido = "Recibida"; un anticipo depende del estatus de la ODC; un gasto no lleva mercancía.
function pcMercancia(p) {
    const ap = (p.pagos_proveedor_aplicaciones || [])[0];
    if (!ap) return '—';
    if (ap.tipo === 'gasto') return '—';
    if (ap.tipo === 'compra') return 'Recibida';
    const est = ap.ordenes_compra?.estatus;
    return est === 'recibida' ? 'Recibida' : est === 'recibida_parcial' ? 'Parcial' : est === 'cancelada' ? 'ODC cancelada' : 'Por recibir';
}
const pcClaseMercancia = (t) => t === 'Recibida' ? 'text-emerald-300' : t === 'Parcial' ? 'text-amber-300' : t === 'Por recibir' ? 'text-sky-300' : 'text-slate-500';

function pcAplicadoA(p) {
    const aps = p.pagos_proveedor_aplicaciones || [];
    if (!aps.length) return '—';
    return aps.map((a) => {
        if (a.tipo === 'gasto') return `<span class="text-slate-300">Gasto ${esc(a.gastos?.folio_factura || a.gastos?.concepto || '')}</span>`;
        if (a.tipo === 'compra') {
            const oc = a.documentos?.ordenes_compra?.folio;
            return `${linkDoc(a.documento_id, a.documentos?.folio || '#' + a.documento_id, 'text-xs font-mono text-slate-200')}${oc ? ` <span class="text-slate-500">· ${esc(oc)}</span>` : ''}`;
        }
        const oc = a.ordenes_compra;
        return oc ? `<button type="button" onclick="window.verDetalleOC(${a.orden_compra_id})" class="text-xs font-mono text-emerald-300 hover:underline">${esc(oc.folio || '#' + a.orden_compra_id)}</button> <span class="text-slate-500">anticipo</span>` : 'Anticipo';
    }).join('<br>');
}

async function pcCargarTabla() {
    const cont = document.getElementById('pcTabla');
    if (!cont) return;
    const selCompleto = 'id, fecha, total, referencia, forma_pago, estatus, poliza_id, proveedores ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto, documento_id, orden_compra_id, documentos ( folio, ordenes_compra ( folio ) ), ordenes_compra ( folio, estatus ), gastos ( concepto, folio_factura ) )';
    const selBase = 'id, fecha, total, referencia, forma_pago, estatus, poliza_id, proveedores ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto, documento_id, orden_compra_id )';
    const consulta = (sel) => {
        let q = supabaseClient.from('pagos_proveedor').select(sel, { count: 'exact' }).order('id', { ascending: false });
        if (pcDesde) q = q.gte('fecha', pcDesde);
        if (pcHasta) q = q.lte('fecha', pcHasta);
        if (pcProveedor) q = q.eq('proveedor_id', Number(pcProveedor));
        return q.range(pcPagina * POR_PAGINA, pcPagina * POR_PAGINA + POR_PAGINA - 1);
    };
    try {
        let { data, error, count } = await consulta(selCompleto);
        if (error) ({ data, error, count } = await consulta(selBase)); // sin los enlaces anidados: aun así se ven los pagos
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">No hay pagos con esos filtros.</p>'; return; }
        const total = count ?? data.length;
        const paginas = Math.max(1, Math.ceil(total / POR_PAGINA));
        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300 table-fixed">
            <colgroup><col style="width:10%"><col style="width:20%"><col style="width:22%"><col style="width:10%"><col style="width:13%"><col style="width:12%"><col style="width:7%"><col style="width:6%"></colgroup>
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Fecha</th><th class="p-2">Proveedor</th><th class="p-2">Aplicado a</th>
              <th class="p-2 text-right">Total</th><th class="p-2">Forma / ref.</th><th class="p-2">Póliza</th><th class="p-2">Mercancía</th><th class="p-2"></th>
            </tr></thead>
            <tbody>
              ${data.map((p) => { const m = pcMercancia(p); return `
                <tr class="border-b border-slate-900 ${p.estatus === 'cancelado' ? 'opacity-50' : ''}">
                  <td class="p-2 whitespace-nowrap">${esc(p.fecha || '')}</td>
                  <td class="p-2 truncate">${esc(p.proveedores?.nombre || '(varios)')}</td>
                  <td class="p-2">${pcAplicadoA(p)}</td>
                  <td class="p-2 text-right font-mono">${money(p.total)}</td>
                  <td class="p-2 text-slate-400 truncate">${esc([p.forma_pago, p.referencia].filter(Boolean).join(' · '))}</td>
                  <td class="p-2">${linkPoliza(p.poliza_id, 'text-xs font-mono text-emerald-400 hover:underline')}</td>
                  <td class="p-2 ${p.estatus === 'cancelado' ? 'text-rose-400' : pcClaseMercancia(m)}">${p.estatus === 'cancelado' ? 'Cancelado' : esc(m)}</td>
                  <td class="p-2 text-right"><button type="button" class="pc-print text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded" data-id="${p.id}" title="Imprimir comprobante de pago">🖨️</button></td>
                </tr>`; }).join('')}
            </tbody>
          </table>
        </div>
        <div class="flex items-center justify-between mt-2 text-xs text-slate-400">
          <span>${total} pago(s) · página ${pcPagina + 1} de ${paginas}</span>
          <div class="flex gap-2">
            <button type="button" id="pcPrev" class="bg-slate-800 hover:bg-slate-700 border border-slate-700 px-3 py-1 rounded-lg ${pcPagina === 0 ? 'opacity-40 pointer-events-none' : ''}">← Anterior</button>
            <button type="button" id="pcNext" class="bg-slate-800 hover:bg-slate-700 border border-slate-700 px-3 py-1 rounded-lg ${pcPagina + 1 >= paginas ? 'opacity-40 pointer-events-none' : ''}">Siguiente →</button>
          </div>
        </div>`;
        cont.querySelectorAll('.pc-print').forEach((b) => { b.onclick = () => cxpImprimirComprobante(Number(b.dataset.id)); });
        document.getElementById('pcPrev').onclick = () => { if (pcPagina > 0) { pcPagina--; pcCargarTabla(); } };
        document.getElementById('pcNext').onclick = () => { if (pcPagina + 1 < paginas) { pcPagina++; pcCargarTabla(); } };
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">No se pudieron cargar los pagos: ${esc(err.message || err)}</p>`;
    }
}
