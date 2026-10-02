import { supabaseClient } from './supabase.js';
import { siguienteFolio } from './folios.js';
import { imprimirConPlantilla, marcaDeEstatus } from './impresion.js';
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
// Renglón con mercancía por cubrir: pedido − surtido − reservado (solo si la migración de reservas ya corrió).
const pvFalta = (d) => (d.cantidad_reservada === undefined || d.cantidad_reservada === null || d.apartar === false)
    ? 0 : Math.max(Number(d.cantidad || 0) - Number(d.cantidad_surtida || 0) - Number(d.cantidad_reservada || 0), 0);
const pvNum = (n) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 4 });

// Aviso de lo que falta al guardar un pedido (resultado de pedido_venta_reservar).
function pvHtmlFaltantes(filas) {
    const faltan = (filas || []).filter((f) => Number(f.faltante) > 1e-9);
    if (!faltan.length) return ' <span class="text-emerald-400">Toda la mercancía quedó apartada.</span>';
    return `<span class="block mt-2 text-amber-300 font-semibold">⚠ Falta mercancía para surtir completo:</span>`
        + faltan.map((f) => `<span class="block text-amber-200/90">• ${esc(f.producto || 'Producto')}: faltan <b>${pvNum(f.faltante)}</b> de ${pvNum(f.pendiente)}`
            + ` (apartadas ${pvNum(f.reservado)}; en almacén ${pvNum(f.stock)}${Number(f.apartado_otros) > 0 ? `, ${pvNum(f.apartado_otros)} ya apartadas por otros pedidos` : ''})</span>`).join('');
}

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
            // Solo producto terminado: materia prima, insumos y semiterminados (graneles) no se venden.
            supabaseClient.from('productos').select('id, nombre, sku, precio_venta, unidad_medida_id').eq('tipo', 'producto').order('nombre'),
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
        <div class="grid grid-cols-1 md:grid-cols-3 lg:flex lg:flex-wrap lg:items-end gap-3 mb-3">
          <div class="lg:flex-1 lg:min-w-[220px]"><label class="block text-xs text-slate-400 mb-1">Cliente</label>
            <select id="pvCliente" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCli}</select></div>
          <div class="lg:w-40"><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="pvFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="lg:flex-1 lg:min-w-[220px]"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="pvNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-4 lg:flex lg:flex-wrap lg:items-end gap-2">
            <div class="col-span-2 lg:flex-1 lg:min-w-[260px] relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="pvProdInput" autocomplete="off" placeholder="Buscar producto terminado..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="pvProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div class="lg:w-28"><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="pvCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div class="lg:w-32"><label class="block text-[11px] text-slate-400 mb-1">Precio unit.</label>
              <input type="number" step="any" min="0" id="pvPrecio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          </div>
          <button type="button" id="pvAddPartida" class="mt-2 w-full lg:w-auto lg:px-6 bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
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
        <button type="button" id="pvGuardar" class="w-full lg:w-auto lg:px-10 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar pedido</button>
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

        // Reservas (sql/2026-11-03_reservas_pedidos.sql): el pedido aparta lo que hay y avisa lo que falta.
        // Sin la migración esta llamada falla y simplemente se omite.
        let avisoReservas = '', hayFalta = false;
        try {
            const { data: rsv, error: eRsv } = await supabaseClient.rpc('pedido_venta_reservar', { p_pedido_id: pedido.id });
            if (!eRsv && Array.isArray(rsv)) { avisoReservas = pvHtmlFaltantes(rsv); hayFalta = rsv.some((f) => Number(f.faltante) > 1e-9); }
        } catch (_) { /* sin reservas */ }
        msg.innerHTML = `Pedido ${esc(pedido.folio)} guardado.${avisoReservas}`;
        msg.className = `text-xs mt-2 ${hayFalta ? 'text-slate-200' : 'text-emerald-400'}`;
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
        // nivel 2 = reservas + liberar (…03b), 1 = solo reservas (…03), 0 = sin migraciones
        const consultaLista = (nivel) => {
            let q = supabaseClient
                .from('pedidos_venta')
                .select(`id, folio, fecha, estatus, notas, clientes ( nombre ), pedidos_venta_detalle ( cantidad, cantidad_surtida${nivel >= 1 ? ', cantidad_reservada' : ''}${nivel >= 2 ? ', apartar' : ''}, precio_unitario )`)
                .order('id', { ascending: false }).limit(200);
            if (pvFiltro !== 'todas') q = q.eq('estatus', pvFiltro);
            return q;
        };
        let { data, error } = await consultaLista(2);
        if (error && /apartar/i.test(error.message || '')) ({ data, error } = await consultaLista(1));
        if (error && /cantidad_reservada/i.test(error.message || '')) ({ data, error } = await consultaLista(0));
        if (error) throw error;
        const puedeRecalcular = !!(data && data.some((p) => (p.pedidos_venta_detalle || []).some((d) => d.apartar !== undefined)));
        if (!data || !data.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin pedidos en "${PV_FILTROS.find((f) => f.v === pvFiltro)?.t.toLowerCase()}".</p>`; return; }

        data.forEach((p) => {
            const det = p.pedidos_venta_detalle || [];
            p._total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.precio_unitario || 0), 0);
            const ped = det.reduce((a, d) => a + Number(d.cantidad || 0), 0);
            const sur = det.reduce((a, d) => a + Number(d.cantidad_surtida || 0), 0);
            p._pct = ped > 0 ? Math.round((sur / ped) * 100) : 0;
            p._falta = (p.estatus === 'pendiente' || p.estatus === 'parcial') && det.some((d) => pvFalta(d) > 1e-9);
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
        ${puedeRecalcular ? '<div class="flex justify-end mb-2"><button type="button" id="pvRecalcularTodo" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg" title="Vuelve a calcular las reservas de todos los productos (úsalo si algo no cuadra)">↻ Recalcular reservas</button></div>' : ''}
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
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${PV_ESTATUS[p.estatus] || 'text-slate-400 bg-slate-800'}">${esc(p.estatus)}</span>${p._falta ? ' <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-amber-300 bg-amber-950/50 border border-amber-800" title="Hay renglones sin mercancía suficiente apartada">⚠ Falta stock</span>' : ''}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, pvListaOrden, pvRenderLista);
        const btnRecalc = cont.querySelector('#pvRecalcularTodo');
        if (btnRecalc) btnRecalc.onclick = async () => {
            btnRecalc.disabled = true;
            const { data: n, error: eR } = await supabaseClient.rpc('reservas_recalcular_todo');
            if (eR) { alert('No se pudo recalcular: ' + eR.message); btnRecalc.disabled = false; return; }
            alert(`Reservas recalculadas (${n} producto${n === 1 ? '' : 's'}).`);
            await pvRenderLista();
        };
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-10-04_pedidos_venta.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
    }
}

// ---- Detalle / surtir un pedido ----
window.pvAbrirDetalle = async (id) => {
    const idModal = window.idSubventana('modalDetallePedido');
    if (idModal === 'modalDetallePedido') document.getElementById('modalDetallePedido')?.remove();
    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh'; modal.style.left = '50%'; modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)'; modal.style.maxWidth = '44rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Pedido <span id="pvTituloDetalle" class="text-emerald-300 font-mono"></span></h3>
            <div class="flex items-center gap-3">
                <button id="pvImprimirDetalle" type="button" disabled class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1 rounded-lg disabled:opacity-40">🖨️ Imprimir</button>
                <button id="pvCerrarDetalle" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
            </div>
        </div>
        <div id="pvCuerpoDetalle" class="p-4 overflow-y-auto flex-1"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>`;
    document.body.appendChild(modal);
    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() { modal.remove(); document.removeEventListener('click', cerrarFuera); document.removeEventListener('keydown', cerrarEsc); }
    modal.querySelector('#pvCerrarDetalle').onclick = cerrar;
    setTimeout(() => { document.addEventListener('click', cerrarFuera); document.addEventListener('keydown', cerrarEsc); }, 0);

    await pvPintarDetalle(id, modal);
};

// modal: la instancia de esta subventana (window.idSubventana) — TODOS los ids
// internos del template se buscan escopados a ella, nunca por document.getElementById,
// para que con 2+ instancias abiertas (Ctrl+clic) cada una pinte/opere lo suyo.
async function pvPintarDetalle(id, modal) {
    const cuerpo = modal.querySelector('#pvCuerpoDetalle');
    try {
        const consultaDetalle = (nivel) => supabaseClient
            .from('pedidos_venta')
            .select(`id, folio, fecha, estatus, notas, clientes ( nombre ), pedidos_venta_detalle ( id, producto_id, descripcion, cantidad, cantidad_surtida${nivel >= 1 ? ', cantidad_reservada' : ''}${nivel >= 2 ? ', apartar, motivo_liberacion' : ''}, precio_unitario, unidad_medida_id, productos ( nombre, sku ) )`)
            .eq('id', id).single();
        let { data: p, error } = await consultaDetalle(2);
        if (error && /apartar|motivo_liberacion/i.test(error.message || '')) ({ data: p, error } = await consultaDetalle(1));   // falta …03b
        if (error && /cantidad_reservada/i.test(error.message || '')) ({ data: p, error } = await consultaDetalle(0));         // falta …03
        if (error) throw error;
        modal.querySelector('#pvTituloDetalle').textContent = p.folio || ('#' + p.id);

        const det = p.pedidos_venta_detalle || [];
        const total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.precio_unitario || 0), 0);
        const conReservas = (p.estatus === 'pendiente' || p.estatus === 'parcial') && det.some((d) => d.cantidad_reservada !== undefined && d.cantidad_reservada !== null);
        const hayFalta = conReservas && det.some((d) => pvFalta(d) > 1e-9);
        const puedeLiberar = conReservas && det.some((d) => d.apartar !== undefined);   // migración …03b corrida
        const hayLiberadas = puedeLiberar && det.some((d) => d.apartar === false);
        const hayApartadas = puedeLiberar && det.some((d) => d.apartar !== false);

        cuerpo.innerHTML = `
            <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
                <div><span class="block text-[10px] text-slate-500">Cliente</span><span class="text-slate-100">${esc(p.clientes?.nombre || '—')}</span></div>
                <div><span class="block text-[10px] text-slate-500">Estatus</span><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${PV_ESTATUS[p.estatus] || 'text-slate-400 bg-slate-800'}">${esc(p.estatus)}</span></div>
                <div><span class="block text-[10px] text-slate-500">Fecha</span><span class="text-slate-300">${p.fecha || '—'}</span></div>
            </div>
            ${p.notas ? `<div class="mb-4"><span class="block text-[10px] text-slate-500 mb-1">Notas</span><p class="text-xs text-slate-300 bg-slate-800 border border-slate-700 rounded-lg px-2 py-1.5">${esc(p.notas)}</p></div>` : ''}
            ${puedeLiberar ? `<div class="flex flex-wrap justify-end gap-2 mb-2">
                ${hayApartadas ? '<button type="button" id="pvLiberarTodo" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-amber-300 border border-slate-700 px-3 py-1.5 rounded-lg" title="Deja libre toda la mercancía apartada de este pedido">Liberar reservas del pedido</button>' : ''}
                ${hayLiberadas ? '<button type="button" id="pvReactivarTodo" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg">Volver a apartar todo</button>' : ''}
                <button type="button" id="pvRecalcularPedido" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg" title="Vuelve a calcular las reservas de los productos de este pedido">↻ Recalcular</button>
              </div>` : ''}
            ${hayFalta ? '<p class="text-xs text-amber-300 bg-amber-950/30 border border-amber-800 rounded-lg px-3 py-2 mb-3">⚠ Hay renglones sin mercancía suficiente apartada. Lo que falta se cubre con producción o compra; cuando llegue, se aparta solo (el pedido más antiguo primero).</p>' : ''}
            <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
              <table class="w-full text-left text-xs text-slate-300">
                <thead class="bg-slate-950 text-slate-500 uppercase"><tr>
                  <th class="p-2">Producto</th><th class="p-2 text-right">Pedido</th><th class="p-2 text-right">Surtido</th>
                  <th class="p-2 text-right">Pendiente</th>${conReservas ? '<th class="p-2 text-right">Reservado</th><th class="p-2 text-right">Falta</th>' : ''}${puedeLiberar ? '<th class="p-2 text-center">Reserva</th>' : ''}<th class="p-2 text-right">Precio</th>
                </tr></thead>
                <tbody>
                  ${det.map((d) => `
                    <tr class="border-b border-slate-900">
                      <td class="p-2">${esc(d.productos?.nombre || d.descripcion || '—')}${d.productos?.sku ? `<span class="block text-[10px] text-slate-500">SKU ${esc(d.productos.sku)}</span>` : ''}</td>
                      <td class="p-2 text-right font-mono">${d.cantidad}</td>
                      <td class="p-2 text-right font-mono text-slate-400">${d.cantidad_surtida}</td>
                      <td class="p-2 text-right font-mono ${Number(d.cantidad) - Number(d.cantidad_surtida) > 0 ? 'text-amber-400' : 'text-emerald-400'}">${Number(d.cantidad) - Number(d.cantidad_surtida)}</td>
                      ${conReservas ? `<td class="p-2 text-right font-mono text-sky-300">${pvNum(d.cantidad_reservada)}</td>
                      <td class="p-2 text-right font-mono ${pvFalta(d) > 1e-9 ? 'text-rose-400 font-semibold' : 'text-slate-500'}">${pvFalta(d) > 1e-9 ? pvNum(pvFalta(d)) : '—'}</td>` : ''}
                      ${puedeLiberar ? `<td class="p-2 text-center whitespace-nowrap">${d.apartar === false
                          ? `<span class="text-[10px] text-slate-400" title="${esc(d.motivo_liberacion || '')}">Liberada</span> <button type="button" class="pv-reactivar text-[10px] text-sky-300 hover:underline" data-det="${d.id}">Volver a apartar</button>`
                          : `<button type="button" class="pv-liberar text-[10px] text-amber-300 hover:underline" data-det="${d.id}">Liberar</button>`}</td>` : ''}
                      <td class="p-2 text-right font-mono">${money(d.precio_unitario)}</td>
                    </tr>`).join('')}
                </tbody>
                <tfoot><tr><td colspan="${(conReservas ? 6 : 4) + (puedeLiberar ? 1 : 0)}" class="p-2 text-right font-semibold text-slate-400">Total</td><td class="p-2 text-right font-mono font-semibold text-emerald-300">${money(total)}</td></tr></tfoot>
              </table>
            </div>
            ${p.estatus === 'pendiente' || p.estatus === 'parcial' ? `
              <div id="pvSurtirArea"></div>
              <button type="button" id="pvBtnSurtir" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm mb-2">📦 Surtir pendiente</button>
              ${p.estatus === 'pendiente' ? `<button type="button" id="pvBtnCancelar" class="w-full bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 font-medium py-2 rounded-lg text-sm">Cancelar pedido</button>` : ''}
            ` : ''}
            <p id="pvMsgDetalle" class="text-xs mt-2 min-h-[1rem]"></p>`;

        // Liberar / volver a apartar / recalcular (migración …03b). Libera con motivo obligatorio y queda anotado en el pedido.
        if (puedeLiberar) {
            const refrescar = async () => { await pvPintarDetalle(p.id, modal); await pvRenderLista(); };
            const llamar = async (nombre, args) => {
                const { error: eRpc } = await supabaseClient.rpc(nombre, args);
                if (eRpc) { alert('No se pudo: ' + eRpc.message); return false; }
                return true;
            };
            const pedirMotivo = (que) => { const m = prompt(`${que}\n\nMotivo (obligatorio):`, ''); return m === null ? null : m.trim(); };
            modal.querySelectorAll('.pv-liberar').forEach((b) => b.onclick = async () => {
                const m = pedirMotivo('Liberar la mercancía apartada de este renglón. Quedará disponible para otros pedidos.');
                if (m === null) return; if (!m) { alert('Escribe el motivo.'); return; }
                if (await llamar('pedido_venta_liberar_reserva', { p_pedido_id: p.id, p_detalle_id: Number(b.dataset.det), p_motivo: m })) await refrescar();
            });
            modal.querySelectorAll('.pv-reactivar').forEach((b) => b.onclick = async () => {
                if (await llamar('pedido_venta_reactivar_reserva', { p_pedido_id: p.id, p_detalle_id: Number(b.dataset.det) })) await refrescar();
            });
            const btnLibTodo = modal.querySelector('#pvLiberarTodo');
            if (btnLibTodo) btnLibTodo.onclick = async () => {
                const m = pedirMotivo('Liberar TODA la mercancía apartada de este pedido (no se cancela el pedido).');
                if (m === null) return; if (!m) { alert('Escribe el motivo.'); return; }
                if (await llamar('pedido_venta_liberar_reserva', { p_pedido_id: p.id, p_detalle_id: null, p_motivo: m })) await refrescar();
            };
            const btnReacTodo = modal.querySelector('#pvReactivarTodo');
            if (btnReacTodo) btnReacTodo.onclick = async () => { if (await llamar('pedido_venta_reactivar_reserva', { p_pedido_id: p.id, p_detalle_id: null })) await refrescar(); };
            const btnRecPed = modal.querySelector('#pvRecalcularPedido');
            if (btnRecPed) btnRecPed.onclick = async () => { if (await llamar('pedido_venta_reservar', { p_pedido_id: p.id })) await refrescar(); };
        }

        const btnImp = modal.querySelector('#pvImprimirDetalle');
        if (btnImp) { btnImp.disabled = false; btnImp.onclick = () => imprimirConPlantilla('pedido_venta', 'Pedido de venta ' + (p.folio || '#' + p.id), cuerpo, marcaDeEstatus(p.estatus)); }

        const btnSurtir = modal.querySelector('#pvBtnSurtir');
        if (btnSurtir) btnSurtir.onclick = () => pvAbrirSurtir(p, det.filter((d) => Number(d.cantidad) - Number(d.cantidad_surtida) > 0), modal);
        const btnCancelar = modal.querySelector('#pvBtnCancelar');
        if (btnCancelar) btnCancelar.onclick = async () => {
            const motivo = prompt('¿Por qué se cancela este pedido?');
            if (motivo === null) return;
            const { error: eCan } = await supabaseClient.rpc('pedido_venta_cancelar', { p_pedido_id: p.id, p_motivo: motivo || null });
            if (eCan) { alert('No se pudo cancelar: ' + eCan.message); return; }
            modal.remove();
            await pvRenderLista();
        };
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar el pedido: ${esc(err.message || err)}</p>`;
    }
}

// Surtido: por cada línea pendiente, elegir lote(s) y cantidad a surtir ahora.
async function pvAbrirSurtir(pedido, lineasPendientes, modal) {
    const area = modal.querySelector('#pvSurtirArea');
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
            // Con reservas, solo se puede surtir lo apartado para este renglón (lo demás está apartado por otros pedidos o no existe aún).
            const maximo = (l.detalle.cantidad_reservada === undefined || l.detalle.cantidad_reservada === null) ? pendiente : Math.min(pendiente, Number(l.detalle.cantidad_reservada));
            l.maximo = maximo;
            const optsLote = l.lotes.length
                ? l.lotes.map((lo) => `<option value="${lo.id}" data-disp="${lo.stock_actual}" data-costo="${lo.costo_unitario_final}">${esc(lo.numero_lote || ('#' + lo.id))} · disp. ${lo.stock_actual}</option>`).join('')
                : '<option value="">Sin lotes con stock</option>';
            return `
            <div class="grid grid-cols-1 md:grid-cols-4 gap-2 items-end border-b border-slate-800 pb-2 last:border-0" data-linea="${i}">
                <div class="md:col-span-2"><label class="block text-[11px] text-slate-400 mb-0.5">${esc(l.detalle.productos?.nombre || l.detalle.descripcion)} — pendiente ${pendiente}${l.detalle.apartar === false ? ' · <span class="text-amber-300">reserva liberada (vuelve a apartarla para surtir)</span>' : (maximo < pendiente ? ` · <span class="text-amber-300">apartado ${pvNum(maximo)}</span>` : '')}</label>
                    <select class="pv-surtir-lote w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${optsLote}</select></div>
                <div><label class="block text-[11px] text-slate-400 mb-0.5">Cantidad a surtir</label>
                    <input type="number" step="any" min="0" max="${maximo}" class="pv-surtir-cant w-full bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100" value="0"></div>
                <div class="text-[11px] text-slate-500">Costo del lote se toma automático.</div>
            </div>`;
        }).join('')}
      </div>
      <button type="button" id="pvConfirmarSurtir" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm mb-2">Confirmar surtido</button>`;

    modal.querySelector('#pvConfirmarSurtir').onclick = async () => {
        const msg = modal.querySelector('#pvMsgDetalle');
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
            if (cantidad > linea.maximo + 1e-9) { alert(`Solo hay ${pvNum(linea.maximo)} apartadas para "${linea.detalle.productos?.nombre || linea.detalle.descripcion}". Lo demás todavía no tiene mercancía.`); return; }
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

        const btn = modal.querySelector('#pvConfirmarSurtir');
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
            await pvPintarDetalle(pedido.id, modal);
            await pvRenderLista();
        } catch (err) {
            msg.textContent = 'No se pudo surtir: ' + (err.message || err);
            msg.className = 'text-xs mt-2 text-rose-400';
            btn.disabled = false;
        }
    };
}
