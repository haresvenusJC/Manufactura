import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
//  Devoluciones a proveedor y de cliente. No existía ningún módulo de
//  esto — las cuentas 402/402.01 estaban sembradas desde el plan de
//  cuentas inicial sin usarse. Simplificación consciente: no recalcula
//  IVA/IEPS ni emite CFDI de nota de crédito, solo el efecto de
//  inventario + el asiento base (ver comentario en el SQL).
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const hoyISO = () => new Date().toISOString().slice(0, 10);
const normTxt = (s) => String(s || '').normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase().trim();

let devTab = 'cliente';
let devProductos = [];
let devClientes = [];
let devProveedores = [];
let devUnidades = [];
let devPartidasCliente = [];
let devPartidasProveedor = [];
let devProdSelCliente = null;
let devProdSelProveedor = null;
let devLotesProdActual = [];
const devHistOrdenCliente = crearOrdenTabla('id', 'desc');
const devHistOrdenProveedor = crearOrdenTabla('id', 'desc');

export async function cargarModuloDevoluciones() {
    const cont = document.getElementById('contenedorDevoluciones');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const [pr, cl, pv, um] = await Promise.all([
            supabaseClient.from('productos').select('id, nombre, sku, unidad_medida_id').order('nombre'),
            supabaseClient.from('clientes').select('id, nombre').order('nombre'),
            supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
            supabaseClient.from('unidades_medida').select('id, nombre').order('nombre'),
        ]);
        devProductos = pr.data || [];
        devClientes = cl.data || [];
        devProveedores = pv.data || [];
        devUnidades = um.data || [];
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`;
        return;
    }

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="flex gap-2">
        <button type="button" id="devTabCliente" class="text-sm font-medium px-4 py-2 rounded-lg border transition">Devolución de cliente</button>
        <button type="button" id="devTabProveedor" class="text-sm font-medium px-4 py-2 rounded-lg border transition">Devolución a proveedor</button>
      </div>
      <div id="devPanelCliente"></div>
      <div id="devPanelProveedor"></div>
    </div>`;

    document.getElementById('devTabCliente').onclick = () => { devTab = 'cliente'; devPintarTabs(); };
    document.getElementById('devTabProveedor').onclick = () => { devTab = 'proveedor'; devPintarTabs(); };

    devRenderPanelCliente();
    devRenderPanelProveedor();
    devPintarTabs();
    await devRenderHistCliente();
    await devRenderHistProveedor();
    montarGuia(cont, 'devoluciones');
}

function devPintarTabs() {
    const btnC = document.getElementById('devTabCliente');
    const btnP = document.getElementById('devTabProveedor');
    const activo = 'bg-sky-600 border-sky-500 text-white';
    const inactivo = 'bg-slate-900 border-slate-800 text-slate-300 hover:bg-slate-800';
    btnC.className = 'text-sm font-medium px-4 py-2 rounded-lg border transition ' + (devTab === 'cliente' ? activo : inactivo);
    btnP.className = 'text-sm font-medium px-4 py-2 rounded-lg border transition ' + (devTab === 'proveedor' ? activo : inactivo);
    document.getElementById('devPanelCliente').classList.toggle('hidden', devTab !== 'cliente');
    document.getElementById('devPanelProveedor').classList.toggle('hidden', devTab !== 'proveedor');
}

// =====================================================================
//  Devolución de cliente
// =====================================================================
function devRenderPanelCliente() {
    const cont = document.getElementById('devPanelCliente');
    const optCli = '<option value="">Seleccione cliente...</option>' + devClientes.map((c) => `<option value="${c.id}">${esc(c.nombre)}</option>`).join('');
    const optUni = '<option value="">Unidad...</option>' + devUnidades.map((u) => `<option value="${u.id}">${esc(u.nombre)}</option>`).join('');

    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Nueva devolución de cliente</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Cliente</label>
            <select id="devcCliente" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCli}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="devcFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Motivo</label>
            <input type="text" id="devcMotivo" placeholder="Ej. producto dañado" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-5 gap-2">
            <div class="col-span-2 relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="devcProdInput" autocomplete="off" placeholder="Buscar producto..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="devcProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="devcCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Costo unit.</label>
              <input type="number" step="any" min="0" id="devcCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Precio unit.</label>
              <input type="number" step="any" min="0" id="devcPrecio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          </div>
          <button type="button" id="devcAddPartida" class="mt-2 w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
        </div>
        <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Producto</th><th class="p-2 text-right">Cantidad</th><th class="p-2 text-right">Costo</th>
              <th class="p-2 text-right">Precio</th><th class="p-2 text-right">Importe</th><th class="p-2"></th>
            </tr></thead>
            <tbody id="devcPartidasBody"><tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr></tbody>
          </table>
        </div>
        <button type="button" id="devcGuardar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Registrar devolución de cliente</button>
        <p id="devcMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>
      <div class="mt-4">
        <h3 class="text-md font-semibold text-slate-300 mb-2">Devoluciones de cliente registradas</h3>
        <div id="devcHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>`;

    document.getElementById('devcFecha').value = hoyISO();
    devWireProdInput('devcProdInput', 'devcProdSug', (p) => { devProdSelCliente = p; });

    document.getElementById('devcAddPartida').onclick = () => {
        const inp = document.getElementById('devcProdInput');
        const nombre = inp.value.trim();
        const cantidad = parseFloat(document.getElementById('devcCant').value) || 0;
        const costo = parseFloat(document.getElementById('devcCosto').value) || 0;
        const precio = parseFloat(document.getElementById('devcPrecio').value) || 0;
        if (!devProdSelCliente || cantidad <= 0) { alert('Elige un producto del catálogo y una cantidad mayor a 0.'); return; }
        if (precio <= 0) { alert('Captura el precio unitario (el importe que se le va a abonar al cliente).'); return; }
        devPartidasCliente.push({ productoId: devProdSelCliente.id, nombre, cantidad, costo, precio, unidadMedidaId: devProdSelCliente.unidad_medida_id || null });
        devRenderPartidasCliente();
        inp.value = ''; document.getElementById('devcCant').value = ''; document.getElementById('devcCosto').value = ''; document.getElementById('devcPrecio').value = '';
        devProdSelCliente = null; inp.focus();
    };
    document.getElementById('devcGuardar').onclick = devGuardarCliente;
}

function devWireProdInput(idInput, idSug, onSeleccion) {
    const inp = document.getElementById(idInput);
    const sug = document.getElementById(idSug);
    inp.addEventListener('input', () => {
        onSeleccion(null);
        const t = inp.value.toLowerCase().trim();
        if (!t) { sug.classList.add('hidden'); return; }
        const hits = devProductos.filter((p) => (p.nombre && p.nombre.toLowerCase().includes(t)) || (p.sku && p.sku.toLowerCase().includes(t))).slice(0, 12);
        if (!hits.length) { sug.classList.add('hidden'); return; }
        sug.innerHTML = hits.map((p) => `<div class="px-3 py-2 text-xs text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer border-b border-slate-800/50 last:border-0 dev-sug" data-id="${p.id}">${esc(p.nombre)} <span class="text-[10px] text-slate-400">${p.sku ? 'SKU ' + esc(p.sku) : ''}</span></div>`).join('');
        sug.classList.remove('hidden');
        sug.querySelectorAll('.dev-sug').forEach((el) => {
            el.onclick = () => {
                const p = devProductos.find((x) => x.id === Number(el.dataset.id));
                onSeleccion(p || null);
                inp.value = p ? p.nombre : inp.value;
                sug.classList.add('hidden');
            };
        });
    });
    document.addEventListener('click', (e) => { if (!inp.contains(e.target) && !sug.contains(e.target)) sug.classList.add('hidden'); });
}

function devRenderPartidasCliente() {
    const b = document.getElementById('devcPartidasBody');
    if (!devPartidasCliente.length) { b.innerHTML = '<tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr>'; return; }
    b.innerHTML = devPartidasCliente.map((p, i) => `
        <tr class="border-b border-slate-900">
            <td class="p-2 text-slate-100">${esc(p.nombre)}</td>
            <td class="p-2 text-right font-mono">${p.cantidad}</td>
            <td class="p-2 text-right font-mono text-slate-400">${money(p.costo)}</td>
            <td class="p-2 text-right font-mono">${money(p.precio)}</td>
            <td class="p-2 text-right font-mono text-emerald-400">${money(p.cantidad * p.precio)}</td>
            <td class="p-2 text-right"><button type="button" onclick="window.devQuitarCliente(${i})" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button></td>
        </tr>`).join('');
}
window.devQuitarCliente = (i) => { devPartidasCliente.splice(i, 1); devRenderPartidasCliente(); };

async function devGuardarCliente() {
    const msg = document.getElementById('devcMsg');
    if (!devPartidasCliente.length) { msg.textContent = 'Agrega al menos una partida.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    const clienteId = document.getElementById('devcCliente').value ? parseInt(document.getElementById('devcCliente').value) : null;
    if (!clienteId) { msg.textContent = 'Elige el cliente.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('devcGuardar');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_devolucion_cliente', {
            p_datos: {
                fecha: document.getElementById('devcFecha').value || hoyISO(),
                cliente_id: clienteId,
                motivo: document.getElementById('devcMotivo').value.trim() || null,
                partidas: devPartidasCliente.map((p) => ({
                    producto_id: p.productoId, cantidad: p.cantidad, costo_unitario: p.costo, precio_unitario: p.precio, unidad_medida_id: p.unidadMedidaId,
                })),
            },
        });
        if (error) throw error;
        msg.textContent = `Devolución registrada (póliza #${data.poliza_id}).`;
        msg.className = 'text-xs mt-2 text-emerald-400';
        devPartidasCliente = [];
        devRenderPartidasCliente();
        document.getElementById('devcMotivo').value = '';
        await devRenderHistCliente();
    } catch (err) {
        msg.textContent = 'No se pudo registrar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

async function devRenderHistCliente() {
    const cont = document.getElementById('devcHist');
    if (!cont) return;
    try {
        const { data, error } = await supabaseClient
            .from('devoluciones_cliente')
            .select('id, folio, fecha, motivo, estatus, poliza_id, clientes ( nombre ), devoluciones_cliente_detalle ( cantidad, precio_unitario )')
            .order('id', { ascending: false }).limit(200);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin devoluciones de cliente registradas.</p>'; return; }
        data.forEach((d) => { d._total = (d.devoluciones_cliente_detalle || []).reduce((a, l) => a + Number(l.cantidad || 0) * Number(l.precio_unitario || 0), 0); });
        aplicarOrden(devHistOrdenCliente, data, (d, campo) => (campo === 'fecha' ? d.fecha || '' : campo === 'total' ? d._total : d.id));

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Folio</th>${thOrden(devHistOrdenCliente, 'fecha', 'Fecha')}<th class="p-2">Cliente</th>
              ${thOrden(devHistOrdenCliente, 'total', 'Total', 'text-right justify-end')}<th class="p-2">Estatus</th><th class="p-2"></th>
            </tr></thead>
            <tbody>
              ${data.map((d) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 font-mono text-emerald-300">${esc(d.folio)}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${d.fecha || ''}</td>
                  <td class="p-2">${esc(d.clientes?.nombre || '—')}</td>
                  <td class="p-2 text-right font-mono">${money(d._total)}</td>
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${d.estatus === 'cancelada' ? 'text-rose-300 bg-rose-950/40' : 'text-emerald-300 bg-emerald-950/40'}">${esc(d.estatus)}</span></td>
                  <td class="p-2 text-right">${d.estatus === 'registrada' ? `<button type="button" onclick="window.devCancelarCliente(${d.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded">Cancelar</button>` : ''}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, devHistOrdenCliente, devRenderHistCliente);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.devCancelarCliente = async (id) => {
    const motivo = prompt('¿Por qué se cancela esta devolución de cliente?');
    if (motivo === null) return;
    const { error } = await supabaseClient.rpc('cancelar_devolucion_cliente', { p_devolucion_id: id, p_motivo: motivo || null });
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await devRenderHistCliente();
};

// =====================================================================
//  Devolución a proveedor
// =====================================================================
function devRenderPanelProveedor() {
    const cont = document.getElementById('devPanelProveedor');
    const optProv = '<option value="">Seleccione proveedor...</option>' + devProveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');

    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Nueva devolución a proveedor</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Proveedor</label>
            <select id="devpProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optProv}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="devpFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Motivo</label>
            <input type="text" id="devpMotivo" placeholder="Ej. mercancía en mal estado" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
            <div class="col-span-2 relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="devpProdInput" autocomplete="off" placeholder="Buscar producto..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="devpProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Lote</label>
              <select id="devpLote" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"><option value="">Elige producto primero...</option></select></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="devpCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          </div>
          <p id="devpLoteInfo" class="text-[10px] text-slate-500 mt-1"></p>
          <button type="button" id="devpAddPartida" class="mt-2 w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
        </div>
        <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Producto</th><th class="p-2">Lote</th><th class="p-2 text-right">Cantidad</th>
              <th class="p-2 text-right">Costo</th><th class="p-2 text-right">Importe</th><th class="p-2"></th>
            </tr></thead>
            <tbody id="devpPartidasBody"><tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr></tbody>
          </table>
        </div>
        <button type="button" id="devpGuardar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Registrar devolución a proveedor</button>
        <p id="devpMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>
      <div class="mt-4">
        <h3 class="text-md font-semibold text-slate-300 mb-2">Devoluciones a proveedor registradas</h3>
        <div id="devpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>`;

    document.getElementById('devpFecha').value = hoyISO();
    devWireProdInput('devpProdInput', 'devpProdSug', async (p) => {
        devProdSelProveedor = p;
        await devCargarLotesProducto(p);
    });

    document.getElementById('devpLote').onchange = () => {
        const lote = devLotesProdActual.find((l) => l.id === Number(document.getElementById('devpLote').value));
        const info = document.getElementById('devpLoteInfo');
        info.textContent = lote ? `Disponible: ${Math.min(lote.stock_actual, lote.stock_costeo)} · Costo: ${money(lote.costo_unitario_final)}` : '';
    };

    document.getElementById('devpAddPartida').onclick = () => {
        const inp = document.getElementById('devpProdInput');
        const cantidad = parseFloat(document.getElementById('devpCant').value) || 0;
        const loteId = document.getElementById('devpLote').value ? Number(document.getElementById('devpLote').value) : null;
        const lote = devLotesProdActual.find((l) => l.id === loteId);
        if (!devProdSelProveedor || !lote) { alert('Elige un producto del catálogo y su lote.'); return; }
        const disponible = Math.min(lote.stock_actual, lote.stock_costeo);
        if (cantidad <= 0 || cantidad > disponible) { alert(`Cantidad inválida — disponible en ese lote: ${disponible}.`); return; }
        devPartidasProveedor.push({
            productoId: devProdSelProveedor.id, nombre: devProdSelProveedor.nombre, loteId: lote.id, numeroLote: lote.numero_lote,
            cantidad, costo: Number(lote.costo_unitario_final || 0), unidadMedidaId: devProdSelProveedor.unidad_medida_id || null,
        });
        devRenderPartidasProveedor();
        inp.value = ''; document.getElementById('devpCant').value = ''; document.getElementById('devpLote').innerHTML = '<option value="">Elige producto primero...</option>';
        document.getElementById('devpLoteInfo').textContent = '';
        devProdSelProveedor = null; devLotesProdActual = []; inp.focus();
    };
    document.getElementById('devpGuardar').onclick = devGuardarProveedor;
}

async function devCargarLotesProducto(producto) {
    const sel = document.getElementById('devpLote');
    if (!producto) { sel.innerHTML = '<option value="">Elige producto primero...</option>'; devLotesProdActual = []; return; }
    sel.innerHTML = '<option value="">Cargando lotes...</option>';
    const { data, error } = await supabaseClient
        .from('lotes_inventario')
        .select('id, numero_lote, fecha_ingreso, stock_actual, stock_costeo, costo_unitario_final')
        .eq('producto_id', producto.id)
        .gt('stock_actual', 0)
        .order('fecha_ingreso', { ascending: true });
    if (error) { sel.innerHTML = '<option value="">Error al cargar lotes</option>'; return; }
    devLotesProdActual = (data || []).filter((l) => Number(l.stock_costeo || 0) > 0);
    if (!devLotesProdActual.length) { sel.innerHTML = '<option value="">Sin lotes con stock disponible</option>'; return; }
    sel.innerHTML = devLotesProdActual.map((l) => `<option value="${l.id}">${esc(l.numero_lote || ('#' + l.id))} · disp. ${Math.min(l.stock_actual, l.stock_costeo)} · ${money(l.costo_unitario_final)}</option>`).join('');
}

function devRenderPartidasProveedor() {
    const b = document.getElementById('devpPartidasBody');
    if (!devPartidasProveedor.length) { b.innerHTML = '<tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr>'; return; }
    b.innerHTML = devPartidasProveedor.map((p, i) => `
        <tr class="border-b border-slate-900">
            <td class="p-2 text-slate-100">${esc(p.nombre)}</td>
            <td class="p-2 font-mono text-slate-400">${esc(p.numeroLote)}</td>
            <td class="p-2 text-right font-mono">${p.cantidad}</td>
            <td class="p-2 text-right font-mono text-slate-400">${money(p.costo)}</td>
            <td class="p-2 text-right font-mono text-emerald-400">${money(p.cantidad * p.costo)}</td>
            <td class="p-2 text-right"><button type="button" onclick="window.devQuitarProveedor(${i})" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button></td>
        </tr>`).join('');
}
window.devQuitarProveedor = (i) => { devPartidasProveedor.splice(i, 1); devRenderPartidasProveedor(); };

async function devGuardarProveedor() {
    const msg = document.getElementById('devpMsg');
    if (!devPartidasProveedor.length) { msg.textContent = 'Agrega al menos una partida.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }
    const proveedorId = document.getElementById('devpProveedor').value ? parseInt(document.getElementById('devpProveedor').value) : null;
    if (!proveedorId) { msg.textContent = 'Elige el proveedor.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('devpGuardar');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_devolucion_proveedor', {
            p_datos: {
                fecha: document.getElementById('devpFecha').value || hoyISO(),
                proveedor_id: proveedorId,
                motivo: document.getElementById('devpMotivo').value.trim() || null,
                partidas: devPartidasProveedor.map((p) => ({
                    producto_id: p.productoId, lote_id: p.loteId, cantidad: p.cantidad, unidad_medida_id: p.unidadMedidaId,
                })),
            },
        });
        if (error) throw error;
        msg.textContent = `Devolución registrada (póliza #${data.poliza_id}).`;
        msg.className = 'text-xs mt-2 text-emerald-400';
        devPartidasProveedor = [];
        devRenderPartidasProveedor();
        document.getElementById('devpMotivo').value = '';
        await devRenderHistProveedor();
    } catch (err) {
        msg.textContent = 'No se pudo registrar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

async function devRenderHistProveedor() {
    const cont = document.getElementById('devpHist');
    if (!cont) return;
    try {
        const { data, error } = await supabaseClient
            .from('devoluciones_proveedor')
            .select('id, folio, fecha, motivo, estatus, poliza_id, proveedores ( nombre ), devoluciones_proveedor_detalle ( cantidad, costo_unitario )')
            .order('id', { ascending: false }).limit(200);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin devoluciones a proveedor registradas.</p>'; return; }
        data.forEach((d) => { d._total = (d.devoluciones_proveedor_detalle || []).reduce((a, l) => a + Number(l.cantidad || 0) * Number(l.costo_unitario || 0), 0); });
        aplicarOrden(devHistOrdenProveedor, data, (d, campo) => (campo === 'fecha' ? d.fecha || '' : campo === 'total' ? d._total : d.id));

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Folio</th>${thOrden(devHistOrdenProveedor, 'fecha', 'Fecha')}<th class="p-2">Proveedor</th>
              ${thOrden(devHistOrdenProveedor, 'total', 'Total', 'text-right justify-end')}<th class="p-2">Estatus</th><th class="p-2"></th>
            </tr></thead>
            <tbody>
              ${data.map((d) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 font-mono text-emerald-300">${esc(d.folio)}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${d.fecha || ''}</td>
                  <td class="p-2">${esc(d.proveedores?.nombre || '—')}</td>
                  <td class="p-2 text-right font-mono">${money(d._total)}</td>
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${d.estatus === 'cancelada' ? 'text-rose-300 bg-rose-950/40' : 'text-emerald-300 bg-emerald-950/40'}">${esc(d.estatus)}</span></td>
                  <td class="p-2 text-right">${d.estatus === 'registrada' ? `<button type="button" onclick="window.devCancelarProveedor(${d.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded">Cancelar</button>` : ''}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, devHistOrdenProveedor, devRenderHistProveedor);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.devCancelarProveedor = async (id) => {
    const motivo = prompt('¿Por qué se cancela esta devolución a proveedor?');
    if (motivo === null) return;
    const { error } = await supabaseClient.rpc('cancelar_devolucion_proveedor', { p_devolucion_id: id, p_motivo: motivo || null });
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await devRenderHistProveedor();
};
