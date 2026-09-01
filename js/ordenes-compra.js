import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

// =====================================================================
//  Órdenes de compra + Recibo de mercancía  (Fase 1: captura y recepción
//  manual). El recibo reutiliza el flujo de Compras: crea un documento
//  'entrada_compra', mueve inventario FIFO por lote y, si el módulo
//  contable está instalado, contabiliza con contabilizar_compra.
//  Fase 2: importar XML del CFDI.  Fase 3: leer el QR del CFDI.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

let ocProveedores = [];
let ocUnidades = [];
let ocProductos = [];
let ocMonedas = [];
let ocPartidasTemp = [];
let ocProdSel = null;          // producto elegido en el autocompletar de la OC
let ocRecibirId = null;        // OC preseleccionada al entrar a "Recibo de mercancía"

async function ocCargarCatalogos() {
    const [pv, um, mo] = await Promise.all([
        supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
        supabaseClient.from('unidades_medida').select('id, nombre').order('nombre'),
        supabaseClient.from('monedas').select('id, codigo').order('id'),
    ]);
    ocProveedores = pv.data || [];
    ocUnidades = um.data || [];
    ocMonedas = mo.data || [];

    // requiere_caducidad puede no existir aún: cae al select básico
    let pr = await supabaseClient.from('productos')
        .select('id, nombre, sku, costo_unitario, unidad_medida_id, proveedor_id, requiere_caducidad').order('nombre');
    if (pr.error) {
        pr = await supabaseClient.from('productos')
            .select('id, nombre, sku, costo_unitario, unidad_medida_id, proveedor_id').order('nombre');
    }
    ocProductos = pr.data || [];
}

// =====================================================================
//  MÓDULO: Órdenes de compra
// =====================================================================
export async function cargarModuloOrdenesCompra() {
    const cont = document.getElementById('contenedorOrdenesCompra');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try { await ocCargarCatalogos(); }
    catch (e) { cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`; return; }

    ocPartidasTemp = [];
    ocProdSel = null;

    const optProv = '<option value="">Seleccione proveedor...</option>' + ocProveedores.map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
    const optUni = '<option value="">Unidad...</option>' + ocUnidades.map(u => `<option value="${u.id}">${esc(u.nombre)}</option>`).join('');
    const optMon = ocMonedas.map(m => `<option value="${m.id}">${esc(m.codigo)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Nueva orden de compra</h3>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Proveedor</label>
            <select id="ocProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optProv}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="ocFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha esperada</label>
            <input type="date" id="ocFechaEsp" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Moneda</label>
            <select id="ocMoneda" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optMon}</select></div>
          <div class="md:col-span-4"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="ocNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>

        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-5 gap-2">
            <div class="col-span-2 relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="ocProdInput" autocomplete="off" placeholder="Buscar o escribir uno nuevo..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="ocProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="ocProdCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Costo estimado</label>
              <input type="number" step="any" min="0" id="ocProdCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Unidad</label>
              <select id="ocProdUnidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optUni}</select></div>
          </div>
          <button type="button" id="ocAddPartida" class="mt-2 w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
        </div>

        <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Producto</th><th class="p-2 text-right">Cantidad</th><th class="p-2">Unidad</th>
              <th class="p-2 text-right">Costo est.</th><th class="p-2 text-right">Importe</th><th class="p-2"></th>
            </tr></thead>
            <tbody id="ocPartidasBody"><tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr></tbody>
          </table>
        </div>
        <button type="button" id="ocGuardar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar orden de compra</button>
        <p id="ocMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Órdenes de compra</h3>
        <div id="ocLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('ocFecha').value = hoyISO();
    const mxn = ocMonedas.find(m => m.codigo === 'MXN');
    if (mxn) document.getElementById('ocMoneda').value = mxn.id;

    ocWireFormulario();
    await ocRenderLista();
}

function ocWireFormulario() {
    const inp = document.getElementById('ocProdInput');
    const sug = document.getElementById('ocProdSug');

    inp.addEventListener('input', () => {
        ocProdSel = null;
        const t = inp.value.toLowerCase().trim();
        if (!t) { sug.classList.add('hidden'); return; }
        const hits = ocProductos.filter(p =>
            (p.nombre && p.nombre.toLowerCase().includes(t)) || (p.sku && p.sku.toLowerCase().includes(t))
        ).slice(0, 12);
        if (!hits.length) { sug.classList.add('hidden'); return; }
        sug.innerHTML = hits.map(p => `
            <div class="px-3 py-2 text-xs text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer border-b border-slate-800/50 last:border-0 oc-sug" data-id="${p.id}">
                ${esc(p.nombre)} <span class="text-[10px] text-slate-400">${p.sku ? 'SKU ' + esc(p.sku) : ''}</span>
            </div>`).join('');
        sug.classList.remove('hidden');
        sug.querySelectorAll('.oc-sug').forEach(el => {
            el.onclick = () => {
                const p = ocProductos.find(x => x.id === Number(el.dataset.id));
                ocProdSel = p || null;
                inp.value = p ? p.nombre : inp.value;
                if (p && p.costo_unitario != null) document.getElementById('ocProdCosto').value = p.costo_unitario;
                if (p && p.unidad_medida_id) document.getElementById('ocProdUnidad').value = p.unidad_medida_id;
                sug.classList.add('hidden');
            };
        });
    });
    document.addEventListener('click', (e) => {
        if (!inp.contains(e.target) && !sug.contains(e.target)) sug.classList.add('hidden');
    });

    document.getElementById('ocAddPartida').onclick = () => {
        const nombre = inp.value.trim();
        const cantidad = parseFloat(document.getElementById('ocProdCant').value) || 0;
        const costo = parseFloat(document.getElementById('ocProdCosto').value) || 0;
        const unidadId = document.getElementById('ocProdUnidad').value ? parseInt(document.getElementById('ocProdUnidad').value) : null;
        if (!nombre || cantidad <= 0) { alert('Indica el producto y una cantidad mayor a 0.'); return; }
        const uNom = ocUnidades.find(u => u.id === unidadId)?.nombre || '';
        ocPartidasTemp.push({
            productoId: ocProdSel ? ocProdSel.id : null,
            nombre,
            cantidad,
            costo,
            unidadId,
            unidadNombre: uNom,
        });
        ocRenderPartidas();
        inp.value = ''; document.getElementById('ocProdCant').value = ''; document.getElementById('ocProdCosto').value = '';
        document.getElementById('ocProdUnidad').value = ''; ocProdSel = null; inp.focus();
    };

    document.getElementById('ocGuardar').onclick = ocGuardarOrden;
}

function ocRenderPartidas() {
    const b = document.getElementById('ocPartidasBody');
    if (!ocPartidasTemp.length) {
        b.innerHTML = '<tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr>';
        return;
    }
    b.innerHTML = ocPartidasTemp.map((p, i) => `
        <tr class="border-b border-slate-900">
            <td class="p-2 text-slate-100">${esc(p.nombre)}${p.productoId ? '' : ' <span class="text-[10px] text-amber-400">(nuevo)</span>'}</td>
            <td class="p-2 text-right font-mono">${p.cantidad}</td>
            <td class="p-2 text-slate-400">${esc(p.unidadNombre)}</td>
            <td class="p-2 text-right font-mono">${money(p.costo)}</td>
            <td class="p-2 text-right font-mono text-emerald-400">${money(p.cantidad * p.costo)}</td>
            <td class="p-2 text-right"><button type="button" onclick="window.ocQuitarPartida(${i})" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button></td>
        </tr>`).join('');
}
window.ocQuitarPartida = (i) => { ocPartidasTemp.splice(i, 1); ocRenderPartidas(); };

async function ocGuardarOrden() {
    const msg = document.getElementById('ocMsg');
    msg.textContent = ''; msg.className = 'text-xs mt-2 min-h-[1rem]';
    if (!ocPartidasTemp.length) { msg.textContent = 'Agrega al menos una partida.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('ocGuardar');
    btn.disabled = true;
    try {
        const folio = 'OC-' + Date.now().toString().slice(-6);
        const { data: oc, error: e1 } = await supabaseClient.from('ordenes_compra').insert([{
            folio,
            proveedor_id: document.getElementById('ocProveedor').value ? parseInt(document.getElementById('ocProveedor').value) : null,
            fecha: document.getElementById('ocFecha').value || hoyISO(),
            fecha_esperada: document.getElementById('ocFechaEsp').value || null,
            moneda_id: document.getElementById('ocMoneda').value ? parseInt(document.getElementById('ocMoneda').value) : null,
            estatus: 'abierta',
            notas: document.getElementById('ocNotas').value.trim() || null,
        }]).select('id, folio').single();
        if (e1) throw e1;

        const filas = ocPartidasTemp.map(p => ({
            orden_compra_id: oc.id,
            producto_id: p.productoId,
            descripcion: p.productoId ? null : p.nombre,
            cantidad: p.cantidad,
            cantidad_recibida: 0,
            costo_unitario_estimado: p.costo,
            unidad_medida_id: p.unidadId,
        }));
        const { error: e2 } = await supabaseClient.from('ordenes_compra_detalle').insert(filas);
        if (e2) throw e2;

        msg.textContent = `Orden ${oc.folio} guardada.`;
        msg.className = 'text-xs mt-2 text-emerald-400';
        ocPartidasTemp = [];
        ocRenderPartidas();
        document.getElementById('ocNotas').value = '';
        await ocRenderLista();
    } catch (err) {
        const m = err?.message || String(err);
        if (/does not exist|schema cache|could not find/i.test(m)) {
            msg.textContent = 'Falta correr sql/2026-09-02_ordenes_compra.sql en Supabase.';
        } else {
            msg.textContent = 'No se pudo guardar: ' + m;
        }
        msg.className = 'text-xs mt-2 text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

const OC_ESTATUS = {
    borrador: 'text-slate-400 bg-slate-800',
    abierta: 'text-sky-300 bg-sky-950/50',
    recibida_parcial: 'text-amber-300 bg-amber-950/40',
    recibida: 'text-emerald-300 bg-emerald-950/40',
    cancelada: 'text-rose-300 bg-rose-950/40',
};

async function ocRenderLista() {
    const cont = document.getElementById('ocLista');
    try {
        const { data, error } = await supabaseClient
            .from('ordenes_compra')
            .select('id, folio, fecha, fecha_esperada, estatus, notas, proveedores ( nombre ), ordenes_compra_detalle ( cantidad, cantidad_recibida, costo_unitario_estimado )')
            .order('id', { ascending: false })
            .limit(200);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin órdenes de compra.</p>'; return; }

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Folio</th><th class="p-2">Proveedor</th><th class="p-2">Fecha</th>
              <th class="p-2 text-right">Total est.</th><th class="p-2">Recibido</th><th class="p-2">Estatus</th><th class="p-2 text-right">Acción</th>
            </tr></thead>
            <tbody>
              ${data.map(o => {
                  const det = o.ordenes_compra_detalle || [];
                  const total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.costo_unitario_estimado || 0), 0);
                  const ped = det.reduce((a, d) => a + Number(d.cantidad || 0), 0);
                  const rec = det.reduce((a, d) => a + Number(d.cantidad_recibida || 0), 0);
                  const pct = ped > 0 ? Math.round((rec / ped) * 100) : 0;
                  const puedeRecibir = o.estatus === 'abierta' || o.estatus === 'recibida_parcial';
                  return `
                    <tr class="border-b border-slate-900">
                      <td class="p-2 font-mono text-emerald-300">${esc(o.folio || '#' + o.id)}</td>
                      <td class="p-2">${esc(o.proveedores?.nombre || '—')}</td>
                      <td class="p-2 whitespace-nowrap text-slate-400">${o.fecha || ''}</td>
                      <td class="p-2 text-right font-mono">${money(total)}</td>
                      <td class="p-2 font-mono text-slate-400">${pct}%</td>
                      <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${OC_ESTATUS[o.estatus] || 'text-slate-400 bg-slate-800'}">${esc(o.estatus)}</span></td>
                      <td class="p-2 text-right whitespace-nowrap">
                        ${puedeRecibir ? `<button type="button" onclick="window.irARecibirOC(${o.id})" class="text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded">Recibir</button>` : ''}
                        ${(o.estatus === 'recibida' || o.estatus === 'recibida_parcial') ? `<button type="button" onclick="window.ocPagar(${o.id})" class="text-[11px] bg-sky-700 hover:bg-sky-600 text-white px-2 py-1 rounded ml-1">Pagar</button>` : ''}
                        ${o.estatus === 'abierta' ? `<button type="button" onclick="window.ocCancelar(${o.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded ml-1">Cancelar</button>` : ''}
                      </td>
                    </tr>`;
              }).join('')}
            </tbody>
          </table>
        </div>`;
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-02_ordenes_compra.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
    }
}

window.ocCancelar = async (id) => {
    if (!confirm('¿Cancelar esta orden de compra?')) return;
    const { error } = await supabaseClient.from('ordenes_compra').update({ estatus: 'cancelada' }).eq('id', id);
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await ocRenderLista();
};

window.irARecibirOC = (id) => {
    ocRecibirId = Number(id);
    window.loadView('recibo-mercancia');
};

// Ir a Cuentas por pagar con las compras de esta OC preseleccionadas.
window.ocPagar = (id) => {
    window.__cxpOcPreseleccion = Number(id);
    window.loadView('pagos-proveedor');
};

// =====================================================================
//  MÓDULO: Recibo de mercancía
// =====================================================================
let rmSinContab = false;
let rmCuentasPago = [];

export async function cargarModuloReciboMercancia() {
    const cont = document.getElementById('contenedorReciboMercancia');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try { await ocCargarCatalogos(); }
    catch (e) { cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${e.message || e}</p>`; return; }

    // Cuentas de pago (si hay módulo contable)
    rmSinContab = false;
    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        rmCuentasPago = (data || []).filter(c => /^(101|102)/.test(c.codigo));
    } catch (_) { rmSinContab = true; rmCuentasPago = []; }

    let ocs = [];
    try {
        const { data, error } = await supabaseClient
            .from('ordenes_compra')
            .select('id, folio, fecha, estatus, notas, proveedor_id, proveedores ( nombre ), ordenes_compra_detalle ( id, producto_id, descripcion, cantidad, cantidad_recibida, costo_unitario_estimado, unidad_medida_id )')
            .in('estatus', ['abierta', 'recibida_parcial'])
            .order('id', { ascending: false });
        if (error) throw error;
        ocs = data || [];
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-02_ordenes_compra.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    const optOc = '<option value="">Elige una orden...</option>' +
        ocs.map(o => `<option value="${o.id}">${esc(o.folio || '#' + o.id)} · ${esc(o.proveedores?.nombre || 's/proveedor')} · ${esc(o.estatus)}</option>`).join('');

    const fiscalHtml = rmSinContab ? '' : `
      <div id="rmBloqueFiscal" class="bg-slate-950 border border-slate-800 rounded-xl p-4 mt-4">
        <label class="flex items-center gap-2 text-sm font-semibold text-slate-200 mb-3">
          <input type="checkbox" id="rmContabilizar" checked class="accent-emerald-500"> Generar póliza contable
        </label>
        <div id="rmCamposFiscales" class="grid grid-cols-2 md:grid-cols-4 gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Subtotal</label>
            <input type="number" step="0.01" min="0" id="rmSubtotal" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">IVA <button type="button" id="rmIva16" class="text-[10px] text-emerald-400 hover:underline">16%</button></label>
            <input type="number" step="0.01" min="0" id="rmIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">IEPS</label>
            <input type="number" step="0.01" min="0" id="rmIeps" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Total</label>
            <input type="text" id="rmTotal" readonly value="$0.00" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-emerald-400 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Ret. IVA</label>
            <input type="number" step="0.01" min="0" id="rmRetIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Ret. ISR</label>
            <input type="number" step="0.01" min="0" id="rmRetIsr" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Condición</label>
            <select id="rmCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="credito">Crédito (por pagar)</option><option value="contado">Contado</option></select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Forma de pago</label>
            <select id="rmFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">—</option><option>efectivo</option><option>transferencia</option><option>tarjeta</option><option>cheque</option></select></div>
          <div id="rmPagoWrap" class="hidden md:col-span-2"><label class="block text-xs text-slate-400 mb-1">Pagado desde (caja / banco)</label>
            <select id="rmCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <option value="">— caja / banco —</option>${rmCuentasPago.map(c => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('')}</select></div>
          <div class="md:col-span-2"><label class="block text-xs text-slate-400 mb-1">UUID CFDI</label>
            <input type="text" id="rmUuid" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
          <div class="md:col-span-2"><label class="block text-xs text-slate-400 mb-1">RFC emisor</label>
            <input type="text" id="rmRfc" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
        </div>
      </div>`;

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="flex flex-wrap items-end justify-between gap-3">
          <div class="flex-1 min-w-[240px]">
            <label class="block text-xs text-slate-400 mb-1">Orden de compra</label>
            <select id="rmOC" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optOc}</select>
          </div>
          <div class="flex gap-2">
            <button type="button" disabled title="Disponible en la Fase 2" class="text-xs bg-slate-800 text-slate-500 border border-slate-700 px-3 py-2 rounded-lg cursor-not-allowed">📄 Importar XML</button>
            <button type="button" disabled title="Disponible en la Fase 3" class="text-xs bg-slate-800 text-slate-500 border border-slate-700 px-3 py-2 rounded-lg cursor-not-allowed">🔳 Leer QR</button>
          </div>
        </div>
      </div>
      <div id="rmDetalle"></div>
      ${fiscalHtml}
      <button type="button" id="rmConfirmar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-3 rounded-lg text-sm hidden">✅ Confirmar recepción</button>
      <p id="rmMsg" class="text-xs min-h-[1rem]"></p>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Órdenes con recepción pendiente</h3>
        <div id="rmLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500"></div>
      </div>
    </div>`;

    const selOc = document.getElementById('rmOC');
    selOc.onchange = () => rmRenderDetalle(ocs.find(o => o.id === Number(selOc.value)));

    if (!rmSinContab) {
        const rc = () => {
            const n = (id) => parseFloat(document.getElementById(id)?.value) || 0;
            const t = n('rmSubtotal') + n('rmIva') + n('rmIeps') - n('rmRetIva') - n('rmRetIsr');
            document.getElementById('rmTotal').value = money(t);
        };
        ['rmSubtotal', 'rmIva', 'rmIeps', 'rmRetIva', 'rmRetIsr'].forEach(id => document.getElementById(id).addEventListener('input', rc));
        document.getElementById('rmIva16').onclick = () => {
            document.getElementById('rmIva').value = (Math.round((parseFloat(document.getElementById('rmSubtotal').value) || 0) * 16) / 100).toFixed(2);
            rc();
        };
        document.getElementById('rmContabilizar').onchange = (e) => {
            document.getElementById('rmCamposFiscales').style.display = e.target.checked ? '' : 'none';
        };
        document.getElementById('rmCondicion').onchange = (e) => {
            document.getElementById('rmPagoWrap').classList.toggle('hidden', e.target.value !== 'contado');
        };
    }

    document.getElementById('rmConfirmar').onclick = () => rmConfirmar(ocs);

    rmLista(ocs);

    if (ocRecibirId) {
        selOc.value = String(ocRecibirId);
        selOc.dispatchEvent(new Event('change'));
        ocRecibirId = null;
    }
}

function rmLista(ocs) {
    const cont = document.getElementById('rmLista');
    if (!ocs.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">No hay órdenes por recibir.</p>'; return; }
    cont.innerHTML = ocs.map(o => {
        const det = o.ordenes_compra_detalle || [];
        const ped = det.reduce((a, d) => a + Number(d.cantidad || 0), 0);
        const rec = det.reduce((a, d) => a + Number(d.cantidad_recibida || 0), 0);
        return `<div class="flex justify-between items-center py-1.5 border-b border-slate-900 last:border-0 text-xs">
            <span><span class="font-mono text-emerald-300">${esc(o.folio || '#' + o.id)}</span> · ${esc(o.proveedores?.nombre || '—')}</span>
            <span class="text-slate-400 font-mono">${rec}/${ped}</span>
        </div>`;
    }).join('');
}

function rmRenderDetalle(oc) {
    const cont = document.getElementById('rmDetalle');
    const btn = document.getElementById('rmConfirmar');
    if (!oc) { cont.innerHTML = ''; btn.classList.add('hidden'); return; }

    const nombreProd = (d) => {
        if (d.producto_id) return ocProductos.find(p => p.id === d.producto_id)?.nombre || `Producto #${d.producto_id}`;
        return d.descripcion || 'Sin nombre';
    };

    const filas = (oc.ordenes_compra_detalle || []).map((d) => {
        const pend = Math.max(0, Number(d.cantidad || 0) - Number(d.cantidad_recibida || 0));
        const prod = d.producto_id ? ocProductos.find(p => p.id === d.producto_id) : null;
        const reqCad = !!(prod && prod.requiere_caducidad);
        return `
        <tr class="border-b border-slate-900" data-detid="${d.id}" data-reqcad="${reqCad ? 1 : 0}">
          <td class="p-2 text-center"><input type="checkbox" class="rm-chk accent-emerald-500 w-4 h-4" ${pend > 0 ? 'checked' : ''}></td>
          <td class="p-2 text-slate-100">${esc(nombreProd(d))}${d.producto_id ? '' : ' <span class="text-[10px] text-amber-400">(nuevo)</span>'}${reqCad ? ' <span class="text-[10px] text-amber-400">· caducidad requerida</span>' : ''}</td>
          <td class="p-2 text-right font-mono text-slate-400">${d.cantidad}</td>
          <td class="p-2 text-right font-mono text-slate-400">${d.cantidad_recibida}</td>
          <td class="p-2 text-right font-mono">${pend}</td>
          <td class="p-2"><input type="number" step="any" min="0" class="rm-cant w-20 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 text-right font-mono" value="${pend}"></td>
          <td class="p-2"><input type="number" step="any" min="0" class="rm-costo w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 text-right font-mono" value="${Number(d.costo_unitario_estimado || 0)}"></td>
          <td class="p-2"><input type="text" class="rm-lote w-28 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono" placeholder="lote del proveedor"></td>
          <td class="p-2"><input type="date" class="rm-cad w-32 bg-slate-900 border ${reqCad ? 'border-amber-600' : 'border-slate-800'} rounded px-2 py-1 text-xs text-slate-100 font-mono"></td>
        </tr>`;
    }).join('');

    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <p class="text-xs text-slate-400 mb-2">Ajusta cantidades y costos a lo realmente recibido. Desmarca lo que no llegó. Captura el <b>lote del proveedor</b> (y su caducidad donde aplique).</p>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Recibir</th><th class="p-2">Producto</th><th class="p-2 text-right">Pedido</th>
              <th class="p-2 text-right">Ya recib.</th><th class="p-2 text-right">Pend.</th>
              <th class="p-2">Cant. a recibir</th><th class="p-2">Costo real</th><th class="p-2">Lote del proveedor</th><th class="p-2">Caducidad</th>
            </tr></thead>
            <tbody id="rmDetBody">${filas}</tbody>
          </table>
        </div>
      </div>`;

    btn.classList.remove('hidden');

    const recalc = () => {
        let st = 0;
        cont.querySelectorAll('#rmDetBody tr').forEach(tr => {
            if (!tr.querySelector('.rm-chk').checked) return;
            st += (parseFloat(tr.querySelector('.rm-cant').value) || 0) * (parseFloat(tr.querySelector('.rm-costo').value) || 0);
        });
        const elSt = document.getElementById('rmSubtotal');
        if (elSt) {
            elSt.value = st.toFixed(2);
            const elIva = document.getElementById('rmIva');
            if (elIva) elIva.value = (Math.round(st * 16) / 100).toFixed(2);
            const elTot = document.getElementById('rmTotal');
            const n = (id) => parseFloat(document.getElementById(id)?.value) || 0;
            if (elTot) elTot.value = money(n('rmSubtotal') + n('rmIva') + n('rmIeps') - n('rmRetIva') - n('rmRetIsr'));
        }
    };
    cont.querySelectorAll('.rm-chk, .rm-cant, .rm-costo').forEach(el => el.addEventListener('input', recalc));
    recalc();
}

async function rmConfirmar(ocs) {
    const msg = document.getElementById('rmMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';
    const ocId = Number(document.getElementById('rmOC').value);
    const oc = ocs.find(o => o.id === ocId);
    if (!oc) { msg.textContent = 'Elige una orden de compra.'; msg.className = 'text-xs text-rose-400'; return; }

    const lineas = [];
    const errores = [];
    document.querySelectorAll('#rmDetBody tr').forEach(tr => {
        if (!tr.querySelector('.rm-chk').checked) return;
        const cant = parseFloat(tr.querySelector('.rm-cant').value) || 0;
        if (cant <= 0) return;
        const det = (oc.ordenes_compra_detalle || []).find(d => d.id === Number(tr.dataset.detid));
        const nom = det?.producto_id
            ? (ocProductos.find(p => p.id === det.producto_id)?.nombre || `#${det.producto_id}`)
            : (det?.descripcion || 'partida');
        const lote = tr.querySelector('.rm-lote').value.trim();
        const caducidad = tr.querySelector('.rm-cad').value || null;
        if (!lote) errores.push(`Falta el lote del proveedor de "${nom}".`);
        if (tr.dataset.reqcad === '1' && !caducidad) errores.push(`Falta la caducidad de "${nom}".`);
        lineas.push({ det, cantidad: cant, costo: parseFloat(tr.querySelector('.rm-costo').value) || 0, lote, caducidad });
    });
    if (!lineas.length) { msg.textContent = 'Marca al menos una partida con cantidad mayor a 0.'; msg.className = 'text-xs text-rose-400'; return; }
    if (errores.length) { alert('⚠ Revisa:\n' + errores.join('\n')); return; }
    if (!confirm(`¿Confirmar recepción de ${lineas.length} partida(s) de la orden ${oc.folio}?`)) return;

    const btn = document.getElementById('rmConfirmar');
    btn.disabled = true;
    try {
        const { data: doc, error: eDoc } = await supabaseClient.from('documentos').insert([{
            tipo_movimiento: 'entrada_compra',
            folio: oc.folio,
            proveedor_id: oc.proveedor_id,
            fecha_emision: hoyISO(),
            notas: `Recibo de mercancía — orden ${oc.folio}`,
            estado: 'completado',
            orden_compra_id: oc.id,
        }]).select('id').single();
        if (eDoc) throw eDoc;
        const documentoId = doc.id;

        for (const l of lineas) {
            let productoId = l.det.producto_id;
            if (!productoId) {
                const { data: np, error: eNp } = await supabaseClient.from('productos').insert([{
                    nombre: l.det.descripcion || 'Producto de compra',
                    costo_unitario: l.costo,
                    proveedor_id: oc.proveedor_id,
                    unidad_medida_id: l.det.unidad_medida_id,
                    tipo: 'materia_prima',
                    stock_actual: 0,
                }]).select('id').single();
                if (eNp) throw eNp;
                productoId = np.id;
                await supabaseClient.from('ordenes_compra_detalle').update({ producto_id: productoId }).eq('id', l.det.id);
            }

            const { error: eDet } = await supabaseClient.from('documento_detalles').insert([{
                documento_id: documentoId,
                producto_id: productoId,
                cantidad: l.cantidad,
                costo_unitario: l.costo,
                subtotal: l.cantidad * l.costo,
            }]);
            if (eDet) throw eDet;

            const { error: eFifo } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
                p_producto_id: productoId,
                p_cantidad: l.cantidad,
                p_tipo_movimiento: 'entrada',
                p_documento_id: documentoId,
                p_costo_unitario: l.costo,
                p_numero_lote: l.lote,
            });
            if (eFifo) throw eFifo;

            // Guarda el lote del proveedor y la caducidad en el lote recién creado
            // (best-effort: si aún no corres sql/2026-09-02_caducidad_lotes.sql se ignora)
            try {
                let { data: loteRow } = await supabaseClient.from('lotes_inventario')
                    .select('id').eq('producto_id', productoId).eq('numero_lote', l.lote)
                    .eq('documento_id', documentoId).order('created_at', { ascending: false }).limit(1).maybeSingle();
                if (!loteRow) {
                    ({ data: loteRow } = await supabaseClient.from('lotes_inventario')
                        .select('id').eq('producto_id', productoId).eq('numero_lote', l.lote)
                        .order('created_at', { ascending: false }).limit(1).maybeSingle());
                }
                if (loteRow) {
                    await supabaseClient.from('lotes_inventario')
                        .update({ lote_proveedor: l.lote, fecha_caducidad: l.caducidad })
                        .eq('id', loteRow.id);
                }
            } catch (_) { /* columnas de caducidad aún no existen */ }

            await supabaseClient.from('ordenes_compra_detalle')
                .update({ cantidad_recibida: Number(l.det.cantidad_recibida || 0) + l.cantidad })
                .eq('id', l.det.id);
        }

        // Contabilizar (reutiliza contabilizar_compra)
        let msgContab = '';
        const chk = document.getElementById('rmContabilizar');
        if (!rmSinContab && chk && chk.checked) {
            const nf = (id) => Math.max(0, parseFloat(document.getElementById(id)?.value) || 0);
            let subtotal = nf('rmSubtotal');
            if (subtotal <= 0) subtotal = lineas.reduce((a, l) => a + l.cantidad * l.costo, 0);
            const condicion = document.getElementById('rmCondicion').value;
            try {
                const { data: cc, error: eCc } = await supabaseClient.rpc('contabilizar_compra', {
                    p_documento_id: documentoId,
                    p_datos: {
                        subtotal,
                        iva: nf('rmIva'), ieps: nf('rmIeps'), ret_iva: nf('rmRetIva'), ret_isr: nf('rmRetIsr'),
                        condicion,
                        forma_pago: document.getElementById('rmFormaPago').value || null,
                        cuenta_pago_id: condicion === 'contado' && document.getElementById('rmCuentaPago')?.value
                            ? parseInt(document.getElementById('rmCuentaPago').value) : null,
                        uuid_cfdi: document.getElementById('rmUuid').value.trim() || null,
                        rfc_emisor: document.getElementById('rmRfc').value.trim() || null,
                    },
                });
                if (eCc) throw eCc;
                msgContab = cc && cc.total != null
                    ? ` Póliza de Egreso generada (total ${money(cc.total)}).`
                    : ' Póliza de Egreso generada.';
            } catch (e) {
                msgContab = ` (Entrada OK, pero no se contabilizó: ${e.message || e})`;
            }
        }

        // Recalcular estatus de la OC
        const { data: detFresco } = await supabaseClient.from('ordenes_compra_detalle')
            .select('cantidad, cantidad_recibida').eq('orden_compra_id', oc.id);
        let nuevo = 'recibida_parcial';
        if (detFresco && detFresco.every(d => Number(d.cantidad_recibida || 0) >= Number(d.cantidad || 0))) nuevo = 'recibida';
        else if (detFresco && detFresco.every(d => Number(d.cantidad_recibida || 0) === 0)) nuevo = 'abierta';
        await supabaseClient.from('ordenes_compra').update({ estatus: nuevo }).eq('id', oc.id);

        alert(`✅ Recepción registrada (documento #${documentoId}).${msgContab}\nLa orden ${oc.folio} quedó "${nuevo}".`);

        if (typeof cargarInventarioCompleto === 'function') await cargarInventarioCompleto();
        await cargarModuloReciboMercancia();
    } catch (err) {
        msg.textContent = 'No se pudo registrar la recepción: ' + (err.message || err);
        msg.className = 'text-xs text-rose-400';
        btn.disabled = false;
    }
}
