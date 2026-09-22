import { supabaseClient } from './supabase.js';
import { siguienteFolio } from './folios.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { registrarSalidaMultiPartida } from './salidas.js';

// =====================================================================
//  Pedidos de venta — cliente pide, se surte después (total o en
//  partes). Al surtir, genera una salida real reusando
//  registrarSalidaMultiPartida (mismo motor de inventario/kardex que ya
//  usa Salidas / Ventas), enlazada de vuelta al pedido.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const hoyISO = () => new Date().toISOString().slice(0, 10);

let pvClientes = [];
let pvProductos = [];
let pvPartidasTemp = [];
let pvProdSel = null;
let pvFiltro = 'pendiente';
const pvListaOrden = crearOrdenTabla('id', 'desc');

const PV_FILTROS = [
    { v: 'pendiente', t: 'Pendientes' },
    { v: 'parcial', t: 'Parciales' },
    { v: 'surtido', t: 'Surtidos' },
    { v: 'cancelado', t: 'Cancelados' },
    { v: 'todas', t: 'Todas' },
];
const PV_ESTATUS = {
    pendiente: 'text-amber-300 bg-amber-950/40',
    parcial: 'text-sky-300 bg-sky-950/50',
    surtido: 'text-emerald-300 bg-emerald-950/40',
    cancelado: 'text-slate-400 bg-slate-800',
};

export async function cargarModuloPedidosVenta() {
    const cont = document.getElementById('contenedorPedidosVenta');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const [cl, pr] = await Promise.all([
            supabaseClient.from('clientes').select('id, nombre').order('nombre'),
            supabaseClient.from('productos').select('id, nombre, sku, precio_venta, unidad_medida_id').order('nombre'),
        ]);
        pvClientes = cl.data || [];
        pvProductos = pr.data || [];
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`;
        return;
    }
    pvPartidasTemp = [];

    const optCli = '<option value="">Seleccione cliente...</option>' + pvClientes.map((c) => `<option value="${c.id}">${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Nuevo pedido de venta</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Cliente</label>
            <select id="pvCliente" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCli}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="pvFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="pvNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
            <div class="col-span-2 relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="pvProdInput" autocomplete="off" placeholder="Buscar producto..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="pvProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="pvCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Precio unit.</label>
              <input type="number" step="any" min="0" id="pvPrecio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          </div>
          <button type="button" id="pvAddPartida" class="mt-2 w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
        </div>
        <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Producto</th><th class="p-2 text-right">Cantidad</th><th class="p-2 text-right">Precio</th>
              <th class="p-2 text-right">Importe</th><th class="p-2"></th>
            </tr></thead>
            <tbody id="pvPartidasBody"><tr><td colspan="5" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr></tbody>
          </table>
        </div>
        <button type="button" id="pvGuardar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar pedido</button>
        <p id="pvMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pedidos de venta</h3>
        <div id="pvFiltros" class="flex flex-wrap gap-2 mb-2"></div>
        <div id="pvLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('pvFecha').value = hoyISO();
    pvWireFormulario();
    pvPintarFiltros();
    await pvRenderLista();
    montarGuia(cont, 'pedidos-venta');
}

function pvWireFormulario() {
    const inp = document.getElementById('pvProdInput');
    const sug = document.getElementById('pvProdSug');
    inp.addEventListener('input', () => {
        pvProdSel = null;
        const t = inp.value.toLowerCase().trim();
        if (!t) { sug.classList.add('hidden'); return; }
        const hits = pvProductos.filter((p) => (p.nombre && p.nombre.toLowerCase().includes(t)) || (p.sku && p.sku.toLowerCase().includes(t))).slice(0, 12);
        if (!hits.length) { sug.classList.add('hidden'); return; }
        sug.innerHTML = hits.map((p) => `<div class="px-3 py-2 text-xs text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer border-b border-slate-800/50 last:border-0 pv-sug" data-id="${p.id}">${esc(p.nombre)} <span class="text-[10px] text-slate-400">${p.sku ? 'SKU ' + esc(p.sku) : ''}</span></div>`).join('');
        sug.classList.remove('hidden');
        sug.querySelectorAll('.pv-sug').forEach((el) => {
            el.onclick = () => {
                const p = pvProductos.find((x) => x.id === Number(el.dataset.id));
                pvProdSel = p || null;
                inp.value = p ? p.nombre : inp.value;
                if (p && p.precio_venta != null) document.getElementById('pvPrecio').value = p.precio_venta;
                sug.classList.add('hidden');
            };
        });
    });
    document.addEventListener('click', (e) => { if (!inp.contains(e.target) && !sug.contains(e.target)) sug.classList.add('hidden'); });

    document.getElementById('pvAddPartida').onclick = () => {
        const nombre = inp.value.trim();
        const cantidad = parseFloat(document.getElementById('pvCant').value) || 0;
        const precio = parseFloat(document.getElementById('pvPrecio').value) || 0;
        if (!pvProdSel || cantidad <= 0) { alert('Elige un producto del catálogo y una cantidad mayor a 0.'); return; }
        pvPartidasTemp.push({ productoId: pvProdSel.id, nombre, cantidad, precio, unidadMedidaId: pvProdSel.unidad_medida_id || null });
        pvRenderPartidas();
        inp.value = ''; document.getElementById('pvCant').value = ''; document.getElementById('pvPrecio').value = '';
        pvProdSel = null; inp.focus();
    };
    document.getElementById('pvGuardar').onclick = pvGuardarPedido;
}

function pvRenderPartidas() {
    const b = document.getElementById('pvPartidasBody');
    if (!pvPartidasTemp.length) { b.innerHTML = '<tr><td colspan="5" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr>'; return; }
    b.innerHTML = pvPartidasTemp.map((p, i) => `
        <tr class="border-b border-slate-900">
            <td class="p-2 text-slate-100">${esc(p.nombre)}</td>
            <td class="p-2 text-right font-mono">${p.cantidad}</td>
            <td class="p-2 text-right font-mono">${money(p.precio)}</td>
            <td class="p-2 text-right font-mono text-emerald-400">${money(p.cantidad * p.precio)}</td>
            <td class="p-2 text-right"><button type="button" onclick="window.pvQuitarPartida(${i})" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button></td>
        </tr>`).join('');
}
window.pvQuitarPartida = (i) => { pvPartidasTemp.splice(i, 1); pvRenderPartidas(); };

async function pvGuardarPedido() {
    const msg = document.getElementById('pvMsg');
    if (!pvPartidasTemp.length) { msg.textContent = 'Agrega al menos una partida.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    const clienteId = document.getElementById('pvCliente').value ? parseInt(document.getElementById('pvCliente').value) : null;
    if (!clienteId) { msg.textContent = 'Elige el cliente.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('pvGuardar');
    btn.disabled = true;
    try {
        const folio = await siguienteFolio('PED');   // consecutivo: PED-000001, PED-000002...
        const { data: pedido, error: e1 } = await supabaseClient.from('pedidos_venta').insert([{
            folio, fecha: document.getElementById('pvFecha').value || hoyISO(), cliente_id: clienteId,
            estatus: 'pendiente', notas: document.getElementById('pvNotas').value.trim() || null,
        }]).select('id, folio').single();
        if (e1) throw e1;

        const filas = pvPartidasTemp.map((p) => ({
            pedido_id: pedido.id, producto_id: p.productoId, descripcion: null, cantidad: p.cantidad,
            cantidad_surtida: 0, precio_unitario: p.precio, unidad_medida_id: p.unidadMedidaId,
        }));
        const { error: e2 } = await supabaseClient.from('pedidos_venta_detalle').insert(filas);
        if (e2) throw e2;

        msg.textContent = `Pedido ${pedido.folio} guardado.`;
        msg.className = 'text-xs mt-2 text-emerald-400';
        pvPartidasTemp = [];
        pvRenderPartidas();
        document.getElementById('pvNotas').value = '';
        pvFiltro = 'pendiente';
        pvPintarFiltros();
        await pvRenderLista();
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

function pvPintarFiltros() {
    const cont = document.getElementById('pvFiltros');
    if (!cont) return;
    cont.innerHTML = PV_FILTROS.map((f) => {
        const on = f.v === pvFiltro;
        return `<button type="button" class="pv-filtro-btn text-xs px-3 py-1.5 rounded-lg border transition ${on ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300 hover:bg-slate-800'}" data-filtro="${f.v}">${f.t}</button>`;
    }).join('');
    cont.querySelectorAll('.pv-filtro-btn').forEach((b) => { b.onclick = () => { pvFiltro = b.dataset.filtro; pvPintarFiltros(); pvRenderLista(); }; });
}

async function pvRenderLista() {
    const cont = document.getElementById('pvLista');
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        let q = supabaseClient
            .from('pedidos_venta')
            .select('id, folio, fecha, estatus, notas, clientes ( nombre ), pedidos_venta_detalle ( cantidad, cantidad_surtida, precio_unitario )')
            .order('id', { ascending: false }).limit(200);
        if (pvFiltro !== 'todas') q = q.eq('estatus', pvFiltro);
        const { data, error } = await q;
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin pedidos en "${PV_FILTROS.find((f) => f.v === pvFiltro)?.t.toLowerCase()}".</p>`; return; }

        data.forEach((p) => {
            const det = p.pedidos_venta_detalle || [];
            p._total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.precio_unitario || 0), 0);
            const ped = det.reduce((a, d) => a + Number(d.cantidad || 0), 0);
            const sur = det.reduce((a, d) => a + Number(d.cantidad_surtida || 0), 0);
            p._pct = ped > 0 ? Math.round((sur / ped) * 100) : 0;
        });
        aplicarOrden(pvListaOrden, data, (p, campo) => {
            switch (campo) {
                case 'folio': return (p.folio || String(p.id)).toLowerCase();
                case 'fecha': return p.fecha || '';
                case 'total': return p._total;
                case 'estatus': return p.estatus || '';
                default: return p.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              ${thOrden(pvListaOrden, 'folio', 'Folio')}<th class="p-2">Cliente</th>${thOrden(pvListaOrden, 'fecha', 'Fecha')}
              ${thOrden(pvListaOrden, 'total', 'Total', 'text-right justify-end')}<th class="p-2">Surtido</th>${thOrden(pvListaOrden, 'estatus', 'Estatus')}
            </tr></thead>
            <tbody>
              ${data.map((p) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2"><button type="button" onclick="window.pvAbrirDetalle(${p.id})" class="font-mono text-emerald-300 hover:underline text-left">${esc(p.folio || '#' + p.id)}</button></td>
                  <td class="p-2">${esc(p.clientes?.nombre || '—')}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${p.fecha || ''}</td>
                  <td class="p-2 text-right font-mono">${money(p._total)}</td>
                  <td class="p-2 font-mono text-slate-400">${p._pct}%</td>
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${PV_ESTATUS[p.estatus] || 'text-slate-400 bg-slate-800'}">${esc(p.estatus)}</span></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, pvListaOrden, pvRenderLista);
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-10-04_pedidos_venta.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
    }
}

// ---- Detalle / surtir un pedido ----
window.pvAbrirDetalle = async (id) => {
    document.getElementById('modalDetallePedido')?.remove();
    const modal = document.createElement('div');
    modal.id = 'modalDetallePedido';
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh'; modal.style.left = '50%'; modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)'; modal.style.maxWidth = '44rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Pedido <span id="pvTituloDetalle" class="text-emerald-300 font-mono"></span></h3>
            <button id="pvCerrarDetalle" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div id="pvCuerpoDetalle" class="p-4 overflow-y-auto flex-1"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>`;
    document.body.appendChild(modal);
    const cerrarFuera = (e) => { if (!modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() { modal.remove(); document.removeEventListener('click', cerrarFuera); document.removeEventListener('keydown', cerrarEsc); }
    document.getElementById('pvCerrarDetalle').onclick = cerrar;
    setTimeout(() => { document.addEventListener('click', cerrarFuera); document.addEventListener('keydown', cerrarEsc); }, 0);

    await pvPintarDetalle(id);
};

async function pvPintarDetalle(id) {
    const cuerpo = document.getElementById('pvCuerpoDetalle');
    try {
        const { data: p, error } = await supabaseClient
            .from('pedidos_venta')
            .select('id, folio, fecha, estatus, notas, clientes ( nombre ), pedidos_venta_detalle ( id, producto_id, descripcion, cantidad, cantidad_surtida, precio_unitario, unidad_medida_id, productos ( nombre, sku ) )')
            .eq('id', id).single();
        if (error) throw error;
        document.getElementById('pvTituloDetalle').textContent = p.folio || ('#' + p.id);

        const det = p.pedidos_venta_detalle || [];
        const total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.precio_unitario || 0), 0);

        cuerpo.innerHTML = `
            <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
                <div><span class="block text-[10px] text-slate-500">Cliente</span><span class="text-slate-100">${esc(p.clientes?.nombre || '—')}</span></div>
                <div><span class="block text-[10px] text-slate-500">Estatus</span><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${PV_ESTATUS[p.estatus] || 'text-slate-400 bg-slate-800'}">${esc(p.estatus)}</span></div>
                <div><span class="block text-[10px] text-slate-500">Fecha</span><span class="text-slate-300">${p.fecha || '—'}</span></div>
            </div>
            ${p.notas ? `<div class="mb-4"><span class="block text-[10px] text-slate-500 mb-1">Notas</span><p class="text-xs text-slate-300 bg-slate-800 border border-slate-700 rounded-lg px-2 py-1.5">${esc(p.notas)}</p></div>` : ''}
            <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
              <table class="w-full text-left text-xs text-slate-300">
                <thead class="bg-slate-950 text-slate-500 uppercase"><tr>
                  <th class="p-2">Producto</th><th class="p-2 text-right">Pedido</th><th class="p-2 text-right">Surtido</th>
                  <th class="p-2 text-right">Pendiente</th><th class="p-2 text-right">Precio</th>
                </tr></thead>
                <tbody>
                  ${det.map((d) => `
                    <tr class="border-b border-slate-900">
                      <td class="p-2">${esc(d.productos?.nombre || d.descripcion || '—')}${d.productos?.sku ? `<span class="block text-[10px] text-slate-500">SKU ${esc(d.productos.sku)}</span>` : ''}</td>
                      <td class="p-2 text-right font-mono">${d.cantidad}</td>
                      <td class="p-2 text-right font-mono text-slate-400">${d.cantidad_surtida}</td>
                      <td class="p-2 text-right font-mono ${Number(d.cantidad) - Number(d.cantidad_surtida) > 0 ? 'text-amber-400' : 'text-emerald-400'}">${Number(d.cantidad) - Number(d.cantidad_surtida)}</td>
                      <td class="p-2 text-right font-mono">${money(d.precio_unitario)}</td>
                    </tr>`).join('')}
                </tbody>
                <tfoot><tr><td colspan="4" class="p-2 text-right font-semibold text-slate-400">Total</td><td class="p-2 text-right font-mono font-semibold text-emerald-300">${money(total)}</td></tr></tfoot>
              </table>
            </div>
            ${p.estatus === 'pendiente' || p.estatus === 'parcial' ? `
              <div id="pvSurtirArea"></div>
              <button type="button" id="pvBtnSurtir" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm mb-2">📦 Surtir pendiente</button>
              ${p.estatus === 'pendiente' ? `<button type="button" id="pvBtnCancelar" class="w-full bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 font-medium py-2 rounded-lg text-sm">Cancelar pedido</button>` : ''}
            ` : ''}
            <p id="pvMsgDetalle" class="text-xs mt-2 min-h-[1rem]"></p>`;

        const btnSurtir = document.getElementById('pvBtnSurtir');
        if (btnSurtir) btnSurtir.onclick = () => pvAbrirSurtir(p, det.filter((d) => Number(d.cantidad) - Number(d.cantidad_surtida) > 0));
        const btnCancelar = document.getElementById('pvBtnCancelar');
        if (btnCancelar) btnCancelar.onclick = async () => {
            const motivo = prompt('¿Por qué se cancela este pedido?');
            if (motivo === null) return;
            const { error: eCan } = await supabaseClient.rpc('pedido_venta_cancelar', { p_pedido_id: p.id, p_motivo: motivo || null });
            if (eCan) { alert('No se pudo cancelar: ' + eCan.message); return; }
            document.getElementById('modalDetallePedido')?.remove();
            await pvRenderLista();
        };
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar el pedido: ${esc(err.message || err)}</p>`;
    }
}

// Surtido: por cada línea pendiente, elegir lote(s) y cantidad a surtir ahora.
async function pvAbrirSurtir(pedido, lineasPendientes) {
    const area = document.getElementById('pvSurtirArea');
    if (!area) return;
    area.innerHTML = '<p class="text-slate-500 text-xs mb-2">Cargando lotes disponibles...</p>';

    const lineasConLotes = await Promise.all(lineasPendientes.map(async (d) => {
        const { data: lotes } = await supabaseClient
            .from('lotes_inventario')
            .select('id, numero_lote, fecha_ingreso, stock_actual, costo_unitario_final')
            .eq('producto_id', d.producto_id).gt('stock_actual', 0).order('fecha_ingreso', { ascending: true });
        return { detalle: d, lotes: lotes || [] };
    }));

    area.innerHTML = `
      <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3 space-y-2">
        ${lineasConLotes.map((l, i) => {
            const pendiente = Number(l.detalle.cantidad) - Number(l.detalle.cantidad_surtida);
            const optsLote = l.lotes.length
                ? l.lotes.map((lo) => `<option value="${lo.id}" data-disp="${lo.stock_actual}" data-costo="${lo.costo_unitario_final}">${esc(lo.numero_lote || ('#' + lo.id))} · disp. ${lo.stock_actual}</option>`).join('')
                : '<option value="">Sin lotes con stock</option>';
            return `
            <div class="grid grid-cols-1 md:grid-cols-4 gap-2 items-end border-b border-slate-800 pb-2 last:border-0" data-linea="${i}">
                <div class="md:col-span-2"><label class="block text-[11px] text-slate-400 mb-0.5">${esc(l.detalle.productos?.nombre || l.detalle.descripcion)} — pendiente ${pendiente}</label>
                    <select class="pv-surtir-lote w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${optsLote}</select></div>
                <div><label class="block text-[11px] text-slate-400 mb-0.5">Cantidad a surtir</label>
                    <input type="number" step="any" min="0" max="${pendiente}" class="pv-surtir-cant w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100" value="0"></div>
                <div class="text-[11px] text-slate-500">Costo del lote se toma automático.</div>
            </div>`;
        }).join('')}
      </div>
      <button type="button" id="pvConfirmarSurtir" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm mb-2">Confirmar surtido</button>`;

    document.getElementById('pvConfirmarSurtir').onclick = async () => {
        const msg = document.getElementById('pvMsgDetalle');
        const filas = [...area.querySelectorAll('[data-linea]')];
        const partidas = [];
        const actualizaciones = [];
        for (const fila of filas) {
            const idx = Number(fila.dataset.linea);
            const linea = lineasConLotes[idx];
            const selLote = fila.querySelector('.pv-surtir-lote');
            const inpCant = fila.querySelector('.pv-surtir-cant');
            const cantidad = parseFloat(inpCant.value) || 0;
            if (cantidad <= 0) continue;
            const loteOpt = selLote.selectedOptions[0];
            if (!selLote.value) { alert('Elige un lote para "' + (linea.detalle.productos?.nombre || linea.detalle.descripcion) + '".'); return; }
            const disp = Number(loteOpt.dataset.disp || 0);
            if (cantidad > disp) { alert('Cantidad mayor al disponible en ese lote.'); return; }
            partidas.push({
                loteId: Number(selLote.value), productoId: linea.detalle.producto_id, cantidad,
                costoUnitario: Number(loteOpt.dataset.costo || 0), precioVenta: linea.detalle.precio_unitario,
                productoNombre: linea.detalle.productos?.nombre || linea.detalle.descripcion, numeroLote: loteOpt.textContent,
            });
            actualizaciones.push({ detalleId: linea.detalle.id, nuevaSurtida: Number(linea.detalle.cantidad_surtida) + cantidad });
        }
        if (!partidas.length) { msg.textContent = 'Captura al menos una cantidad a surtir.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

        const btn = document.getElementById('pvConfirmarSurtir');
        btn.disabled = true;
        try {
            // Surtidos del pedido en orden: PED-000012-S1, PED-000012-S2...
            const { count: surtidosPrevios } = await supabaseClient.from('documentos')
                .select('id', { count: 'exact', head: true }).eq('pedido_venta_id', pedido.id);
            const folio = `${pedido.folio}-S${(surtidosPrevios || 0) + 1}`;
            const res = await registrarSalidaMultiPartida({ tipoMovimiento: 'salida_venta', folio, descripcion: 'Surtido de pedido ' + pedido.folio, partidas, pedidoVentaId: pedido.id });
            if (!res.success) throw new Error(res.error || 'Error desconocido');

            for (const act of actualizaciones) {
                await supabaseClient.from('pedidos_venta_detalle').update({ cantidad_surtida: act.nuevaSurtida }).eq('id', act.detalleId);
            }
            const { data: detFresco } = await supabaseClient.from('pedidos_venta_detalle').select('cantidad, cantidad_surtida').eq('pedido_id', pedido.id);
            let nuevoEstatus = 'parcial';
            if (detFresco && detFresco.every((d) => Number(d.cantidad_surtida) >= Number(d.cantidad))) nuevoEstatus = 'surtido';
            else if (detFresco && detFresco.every((d) => Number(d.cantidad_surtida) === 0)) nuevoEstatus = 'pendiente';
            await supabaseClient.from('pedidos_venta').update({ estatus: nuevoEstatus }).eq('id', pedido.id);

            msg.textContent = `Surtido registrado (documento #${res.documentoId}). Pedido "${nuevoEstatus}".`;
            msg.className = 'text-xs mt-2 text-emerald-400';
            await pvPintarDetalle(pedido.id);
            await pvRenderLista();
        } catch (err) {
            msg.textContent = 'No se pudo surtir: ' + (err.message || err);
            msg.className = 'text-xs mt-2 text-rose-400';
            btn.disabled = false;
        }
    };
}
