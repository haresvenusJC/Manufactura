import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';
import { REGIMENES } from './proveedores.js';
import { parsearCfdi, extraerTextoPdf, parsearCfdiPdf } from './cfdi.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';

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
const normTxt = (s) => String(s || '').normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase().trim();

let ocProveedores = [];
let ocUnidades = [];
const ocListaOrden = crearOrdenTabla('id', 'desc');
const rmRecepOrden = crearOrdenTabla();
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
    ocAplicarPreseleccion();
    await ocRenderLista();
}

// Preselección al entrar desde una tarea/sugerencia ("Crear orden de compra"
// en Contabilidad · Tareas). window.__ocPreProducto = { id, cantidad }.
function ocAplicarPreseleccion() {
    const pre = window.__ocPreProducto;
    window.__ocPreProducto = null;
    if (!pre || !pre.id) return;
    const p = ocProductos.find((x) => x.id === Number(pre.id));
    if (!p) return;
    ocProdSel = p;
    const set = (id, v) => { const el = document.getElementById(id); if (el != null && v != null && v !== '') el.value = v; };
    set('ocProdInput', p.nombre);
    set('ocProdCosto', p.costo_unitario);
    set('ocProdUnidad', p.unidad_medida_id);
    set('ocProveedor', p.proveedor_id);
    if (pre.cantidad) set('ocProdCant', pre.cantidad);
    const cant = document.getElementById('ocProdCant');
    if (cant) cant.focus();
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

        data.forEach(o => {
            const det = o.ordenes_compra_detalle || [];
            o._total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.costo_unitario_estimado || 0), 0);
            const ped = det.reduce((a, d) => a + Number(d.cantidad || 0), 0);
            const rec = det.reduce((a, d) => a + Number(d.cantidad_recibida || 0), 0);
            o._pct = ped > 0 ? Math.round((rec / ped) * 100) : 0;
        });
        aplicarOrden(ocListaOrden, data, (o, campo) => {
            switch (campo) {
                case 'folio': return (o.folio || String(o.id)).toLowerCase();
                case 'proveedor': return (o.proveedores?.nombre || '').toLowerCase();
                case 'fecha': return o.fecha || '';
                case 'total': return o._total;
                case 'recibido': return o._pct;
                case 'estatus': return o.estatus || '';
                default: return o.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(ocListaOrden, 'folio', 'Folio')}${thOrden(ocListaOrden, 'proveedor', 'Proveedor')}${thOrden(ocListaOrden, 'fecha', 'Fecha')}
              ${thOrden(ocListaOrden, 'total', 'Total est.', 'text-right justify-end')}${thOrden(ocListaOrden, 'recibido', 'Recibido')}${thOrden(ocListaOrden, 'estatus', 'Estatus')}
            </tr></thead>
            <tbody>
              ${data.map(o => {
                  const total = o._total;
                  const pct = o._pct;
                  const puedeRecibir = o.estatus === 'abierta' || o.estatus === 'recibida_parcial';
                  return `
                    <tr class="border-b border-slate-900">
                      <td class="p-2 whitespace-nowrap">
                        ${puedeRecibir ? `<button type="button" onclick="window.irARecibirOC(${o.id})" class="text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded">Recibir</button>` : ''}
                        ${(o.estatus === 'recibida' || o.estatus === 'recibida_parcial') ? `<button type="button" onclick="window.ocPagar(${o.id})" class="text-[11px] bg-sky-700 hover:bg-sky-600 text-white px-2 py-1 rounded ml-1">Pagar</button>` : ''}
                        ${o.estatus === 'abierta' ? `<button type="button" onclick="window.ocCancelar(${o.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded ml-1">Cancelar</button>` : ''}
                      </td>
                      <td class="p-2 font-mono text-emerald-300">${esc(o.folio || '#' + o.id)}</td>
                      <td class="p-2">${esc(o.proveedores?.nombre || '—')}</td>
                      <td class="p-2 whitespace-nowrap text-slate-400">${o.fecha || ''}</td>
                      <td class="p-2 text-right font-mono">${money(total)}</td>
                      <td class="p-2 font-mono text-slate-400">${pct}%</td>
                      <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${OC_ESTATUS[o.estatus] || 'text-slate-400 bg-slate-800'}">${esc(o.estatus)}</span></td>
                    </tr>`;
              }).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, ocListaOrden, ocRenderLista);
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
let rmOcActual = null;   // OC seleccionada en Recibo (para conciliar el XML)
let rmModo = null;       // 'oc' | 'xml'
let rmXmlMeta = null;    // { proveedorId, rfc, uuid, folio } cuando el recibo viene de un XML sin OC
let rmCargosXml = [];    // [{concepto, monto}] flete/seguro/etc. detectados en el XML (no se reciben como producto)
let rmCatUso = [];       // c_uso_cfdi
let rmCatForma = [];     // c_forma_pago
let rmCatMetodo = [];    // c_metodo_pago
let rmCatCuentasGasto = []; // cuentas_contables afectables/activas, para el alta rápida de proveedor
let rmRecProveedores = [];      // catálogo para el filtro de "Recepciones registradas"
let rmRecPagina = 1;
const rmRecPorPagina = 20;
let rmRecFiltro = { desde: '', hasta: '', proveedorId: '' };

export async function cargarModuloReciboMercancia() {
    const cont = document.getElementById('contenedorReciboMercancia');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    rmModo = null; rmXmlMeta = null; rmOcActual = null; rmCargosXml = [];
    rmRecPagina = 1; rmRecFiltro = { desde: '', hasta: '', proveedorId: '' };
    try { await ocCargarCatalogos(); }
    catch (e) { cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${e.message || e}</p>`; return; }

    // Cuentas de pago (si hay módulo contable)
    rmSinContab = false;
    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        rmCatCuentasGasto = data || [];
        rmCuentasPago = (data || []).filter(c => /^(101|102)/.test(c.codigo));
    } catch (_) { rmSinContab = true; rmCuentasPago = []; rmCatCuentasGasto = []; }

    // Catálogos SAT del CFDI (best-effort: si falta el SQL se usan opciones básicas)
    rmCatUso = []; rmCatForma = []; rmCatMetodo = [];
    try {
        const [u, f, m] = await Promise.all([
            supabaseClient.from('c_uso_cfdi').select('clave, descripcion, activo').order('clave'),
            supabaseClient.from('c_forma_pago').select('clave, descripcion').order('clave'),
            supabaseClient.from('c_metodo_pago').select('clave, descripcion').order('clave'),
        ]);
        rmCatUso = (u.data || []).filter(x => x.activo !== false);
        rmCatForma = f.data || [];
        rmCatMetodo = m.data || [];
    } catch (_) { /* catálogos no instalados */ }

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

    const optForma = '<option value="">—</option>' + (rmCatForma.length
        ? rmCatForma.map(x => `<option value="${esc(x.clave)}">${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="01">01 · Efectivo</option><option value="03">03 · Transferencia</option><option value="04">04 · Tarjeta de crédito</option><option value="28">28 · Tarjeta de débito</option><option value="02">02 · Cheque</option><option value="99">99 · Por definir</option>`);
    const optMetodo = '<option value="">—</option>' + (rmCatMetodo.length
        ? rmCatMetodo.map(x => `<option value="${esc(x.clave)}">${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="PUE">PUE · Pago en una sola exhibición</option><option value="PPD">PPD · Pago en parcialidades o diferido</option>`);
    const optUso = '<option value="">—</option>' + (rmCatUso.length
        ? rmCatUso.map(x => `<option value="${esc(x.clave)}">${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="G01">G01 · Adquisición de mercancías</option><option value="G03">G03 · Gastos en general</option>`);

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
          <div><label class="block text-xs text-slate-400 mb-1">Forma de pago (SAT)</label>
            <select id="rmFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optForma}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Método de pago</label>
            <select id="rmMetodoPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optMetodo}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Moneda</label>
            <input type="text" id="rmMoneda" value="MXN" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Tipo de cambio</label>
            <input type="number" step="0.0001" min="0" id="rmTipoCambio" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
          <div class="md:col-span-2"><label class="block text-xs text-slate-400 mb-1">Uso CFDI</label>
            <select id="rmUsoCfdi" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optUso}</select></div>
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
      <div id="rmPreRecibos"></div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="flex flex-wrap items-end justify-between gap-3">
          <div class="flex-1 min-w-[240px]">
            <label class="block text-xs text-slate-400 mb-1">Orden de compra</label>
            <select id="rmOC" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optOc}</select>
          </div>
          <div class="flex gap-2">
            <input type="file" id="rmXmlFile" accept=".xml,text/xml,application/xml" class="hidden">
            <input type="file" id="rmPdfFile" accept=".pdf,application/pdf" class="hidden">
            <input type="file" id="rmQrFile" accept="image/*" class="hidden">
            <button type="button" id="rmBtnXml" title="Cargar el XML del CFDI para prellenar impuestos y conciliar partidas" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-2 rounded-lg">📄 Importar XML</button>
            <button type="button" id="rmBtnPdf" title="Cargar el PDF de la factura cuando no tengas el XML — mismos campos, mejor esfuerzo (revisa lo que se precargue)" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-2 rounded-lg">📕 Importar PDF</button>
            <button type="button" id="rmBtnQr" title="Leer una foto del QR del CFDI (UUID, RFC, total)" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-2 rounded-lg">🔳 Leer QR</button>
          </div>
        </div>
        <p class="text-[11px] text-amber-400 mt-2">⚠ Si importas el PDF: siempre revisa cantidades y costos antes de confirmar — igual de importante que con el XML, pero aquí es más probable que haga falta ajustar algo a mano.</p>
        <p id="rmImportInfo" class="text-[11px] text-slate-400 mt-2"></p>
      </div>
      <div id="rmDetalle"></div>
      ${fiscalHtml}

      <div id="rmExtrasWrap" class="bg-slate-950 border border-slate-800 rounded-xl p-4 hidden">
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-sm font-semibold text-sky-400">Costos adicionales (landed cost)</h3>
          <span class="text-[11px] text-slate-500">se reparten por valor y se suman al costo del lote</span>
        </div>
        <table class="w-full text-xs">
          <thead><tr class="text-left text-slate-500 border-b border-slate-800">
            <th class="p-1.5">Concepto</th><th class="p-1.5 text-right">Monto (s/ IVA)</th>
            <th class="p-1.5 text-center">Al inventario</th><th class="p-1.5"></th>
          </tr></thead>
          <tbody id="rmExtrasBody"></tbody>
          <tfoot><tr class="border-t border-slate-800 text-slate-300">
            <td class="p-1.5 font-semibold">Total capitalizable</td>
            <td class="p-1.5 text-right font-mono text-emerald-400" id="rmExtrasTotal">$0.00</td>
            <td colspan="2"></td>
          </tr></tfoot>
        </table>
        <button type="button" id="rmExtraAdd" class="mt-2 text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">+ Cargo</button>
        <p class="text-[10px] text-slate-500 mt-2">"Al inventario" marcado = se capitaliza al costo del producto (115.xx) — es lo que recomienda NIF C-4 para flete/seguro necesarios para poner la mercancía en su ubicación y condición de venta. Desmarcado = el cargo va a gasto (601.14 fletes), recomendable solo si el cargo no es atribuible a la mercancía recibida. El IVA de estos cargos va en el campo IVA de arriba.</p>
        <p id="rmExtrasAviso" class="text-[10px] text-amber-400 mt-1"></p>
      </div>

      <button type="button" id="rmConfirmar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-3 rounded-lg text-sm hidden">✅ Confirmar recepción</button>
      <p id="rmMsg" class="text-xs min-h-[1rem]"></p>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Órdenes con recepción pendiente</h3>
        <div id="rmLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500"></div>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Recepciones registradas</h3>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3 mb-2">
          <div class="flex flex-wrap items-end gap-2">
            <div><label class="block text-[10px] text-slate-400 mb-1">Desde</label>
              <input type="date" id="rmRecDesde" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
            <div><label class="block text-[10px] text-slate-400 mb-1">Hasta</label>
              <input type="date" id="rmRecHasta" class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"></div>
            <div class="flex-1 min-w-[160px]"><label class="block text-[10px] text-slate-400 mb-1">Proveedor</label>
              <select id="rmRecProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100"><option value="">Todos</option></select></div>
            <button type="button" id="rmRecBuscar" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg">Buscar</button>
            <button type="button" id="rmRecLimpiar" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg">Limpiar</button>
          </div>
        </div>
        <div id="rmRecepciones" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
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

    // Importar XML / PDF / Leer QR del CFDI
    const xmlFile = document.getElementById('rmXmlFile');
    const pdfFile = document.getElementById('rmPdfFile');
    const qrFile = document.getElementById('rmQrFile');
    document.getElementById('rmBtnXml').onclick = () => xmlFile.click();
    document.getElementById('rmBtnPdf').onclick = () => pdfFile.click();
    document.getElementById('rmBtnQr').onclick = () => qrFile.click();
    xmlFile.onchange = () => {
        const f = xmlFile.files && xmlFile.files[0];
        if (!f) return;
        const r = new FileReader();
        r.onload = () => { rmProcesarXml(String(r.result || '')); xmlFile.value = ''; };
        r.readAsText(f);
    };
    pdfFile.onchange = () => {
        const f = pdfFile.files && pdfFile.files[0];
        if (f) rmProcesarPdf(f);
        pdfFile.value = '';
    };
    qrFile.onchange = () => {
        const f = qrFile.files && qrFile.files[0];
        if (f) rmProcesarQr(f);
        qrFile.value = '';
    };

    rmLista(ocs);

    try {
        const { data: pv } = await supabaseClient.from('proveedores').select('id, nombre').order('nombre');
        rmRecProveedores = pv || [];
    } catch (_) { rmRecProveedores = []; }
    const selRecProv = document.getElementById('rmRecProveedor');
    if (selRecProv) {
        selRecProv.innerHTML = '<option value="">Todos</option>' + rmRecProveedores.map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
    }
    document.getElementById('rmRecBuscar').onclick = () => {
        rmRecFiltro = {
            desde: document.getElementById('rmRecDesde').value || '',
            hasta: document.getElementById('rmRecHasta').value || '',
            proveedorId: document.getElementById('rmRecProveedor').value || '',
        };
        rmRecPagina = 1;
        rmRecepciones();
    };
    document.getElementById('rmRecLimpiar').onclick = () => {
        document.getElementById('rmRecDesde').value = '';
        document.getElementById('rmRecHasta').value = '';
        document.getElementById('rmRecProveedor').value = '';
        rmRecFiltro = { desde: '', hasta: '', proveedorId: '' };
        rmRecPagina = 1;
        rmRecepciones();
    };

    await rmRecepciones();
    await rmPreRecibos();

    if (ocRecibirId) {
        selOc.value = String(ocRecibirId);
        selOc.dispatchEvent(new Event('change'));
        ocRecibirId = null;
    }
}

// ---- Pre-recibos capturados por operadores (recibo-operador.html) ----
async function rmPreRecibos() {
    const cont = document.getElementById('rmPreRecibos');
    if (!cont) return;

    let filas;
    try {
        const { data, error } = await supabaseClient
            .from('pre_recibos')
            .select('id, orden_compra_id, referencia, empleado_nombre, fotos, observaciones, todo_correcto, creado_en, ordenes_compra ( folio, proveedores ( nombre ) )')
            .eq('estatus', 'pendiente')
            .order('creado_en', { ascending: true });
        if (error) throw error;
        filas = data || [];
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? `<p class="text-[11px] text-slate-600">Pre-recibos de operadores: falta correr <span class="font-mono">sql/2026-09-11_prerecibo_operador.sql</span>.</p>`
            : `<p class="text-rose-400 text-xs">Error al leer pre-recibos: ${esc(m)}</p>`;
        return;
    }

    const linkOperador = `<a href="recibo-operador.html" target="_blank" class="text-[11px] text-sky-400 hover:underline">Abrir pantalla de operador ↗</a>`;

    if (filas.length === 0) {
        cont.innerHTML = `<div class="bg-slate-950 border border-slate-800 rounded-xl p-3 flex items-center justify-between">
            <span class="text-xs text-slate-500">No hay pre-recibos de operadores por validar.</span>${linkOperador}</div>`;
        return;
    }

    cont.innerHTML = `
      <div class="bg-amber-950/30 border border-amber-800/50 rounded-xl p-3">
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-sm font-semibold text-amber-300">Pre-recibos por validar (${filas.length})</h3>
          ${linkOperador}
        </div>
        <div class="space-y-2">
          ${filas.map(pr => {
            const fotos = Array.isArray(pr.fotos) ? pr.fotos : [];
            const oc = pr.orden_compra_id
                ? `OC ${esc(pr.ordenes_compra?.folio || '#' + pr.orden_compra_id)} · ${esc(pr.ordenes_compra?.proveedores?.nombre || 's/proveedor')}`
                : `Sin OC · ref. ${esc(pr.referencia || '—')}`;
            return `
              <div class="bg-slate-950 border border-slate-800 rounded-lg p-3">
                <div class="flex flex-wrap items-start justify-between gap-2">
                  <div class="min-w-0">
                    <p class="text-sm text-slate-200 font-semibold">${oc}</p>
                    <p class="text-[11px] text-slate-500">Operador: ${esc(pr.empleado_nombre || '?')} · ${new Date(pr.creado_en).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' })}</p>
                    <p class="text-[11px] mt-0.5 ${pr.todo_correcto ? 'text-emerald-400' : 'text-amber-400'}">${pr.todo_correcto ? '✔ El operador confirmó que todo cuadra' : '⚠ El operador NO marcó "todo correcto"'}</p>
                    ${pr.observaciones ? `<p class="text-[11px] text-slate-400 mt-0.5">“${esc(pr.observaciones)}”</p>` : ''}
                  </div>
                  <div class="flex gap-2 shrink-0">
                    <button type="button" onclick="window.prereciboValidar(${pr.id}, ${pr.orden_compra_id || 'null'}, 'validar')" class="text-xs bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded-lg">✔ Validar y recibir</button>
                    <button type="button" onclick="window.prereciboValidar(${pr.id}, ${pr.orden_compra_id || 'null'}, 'rechazar')" class="text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-3 py-1.5 rounded-lg">✕ Rechazar</button>
                  </div>
                </div>
                ${fotos.length ? `<div class="flex gap-2 mt-2 flex-wrap">${fotos.map(f => `<a href="${f}" target="_blank"><img src="${f}" class="w-20 h-20 object-cover rounded border border-slate-700"></a>`).join('')}</div>` : '<p class="text-[11px] text-rose-400 mt-2">Sin fotos.</p>'}
              </div>`;
          }).join('')}
        </div>
      </div>`;
}

window.prereciboValidar = async (id, ocId, accion) => {
    let nota = null;
    if (accion === 'rechazar') {
        nota = prompt('Motivo del rechazo (se lo verá el operador con administración):', '');
        if (nota === null) return;
    }
    const { error } = await supabaseClient.rpc('prerecibo_validar', { p_id: Number(id), p_accion: accion, p_nota: nota });
    if (error) { alert('No se pudo procesar: ' + (error.message || error)); return; }
    if (accion === 'validar' && ocId) {
        window.irARecibirOC(ocId);   // recarga el módulo y abre esa OC para capturar la recepción
    } else {
        await rmPreRecibos();
    }
};

async function rmRecepciones() {
    const cont = document.getElementById('rmRecepciones');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const desde = (rmRecPagina - 1) * rmRecPorPagina;
        const hasta = desde + rmRecPorPagina - 1;

        let query = supabaseClient
            .from('documentos')
            .select('id, folio, fecha_emision, total, poliza_id, orden_compra_id, proveedor_id, notas, estado, proveedores ( nombre ), ordenes_compra ( folio ), documento_detalles ( cantidad, subtotal )', { count: 'exact' })
            .eq('tipo_movimiento', 'entrada_compra');
        // Sin filtro por orden_compra_id: las recepciones directas desde XML
        // (sin OC) tambien cuentan como recepciones registradas.
        if (rmRecFiltro.desde) query = query.gte('fecha_emision', rmRecFiltro.desde);
        if (rmRecFiltro.hasta) query = query.lte('fecha_emision', rmRecFiltro.hasta);
        if (rmRecFiltro.proveedorId) query = query.eq('proveedor_id', Number(rmRecFiltro.proveedorId));
        query = query.order('id', { ascending: false }).range(desde, hasta);

        const { data, error, count } = await query;
        if (error) throw error;
        if (!data || !data.length) {
            cont.innerHTML = rmRecPagina > 1
                ? '<p class="text-slate-500 text-sm">No hay más recepciones en esta página.</p>'
                : '<p class="text-slate-500 text-sm">Aún no hay recepciones registradas.</p>';
            return;
        }

        const totalPaginas = Math.ceil((count || data.length) / rmRecPorPagina) || 1;

        data.forEach(d => {
            const dets = d.documento_detalles || [];
            d._total = d.total != null ? Number(d.total) : dets.reduce((a, x) => a + Number(x.subtotal || 0), 0);
            d._partidas = dets.length;
        });
        aplicarOrden(rmRecepOrden, data, (d, campo) => {
            switch (campo) {
                case 'fecha': return d.fecha_emision || '';
                case 'orden': return (d.ordenes_compra?.folio || d.folio || '').toLowerCase();
                case 'proveedor': return (d.proveedores?.nombre || '').toLowerCase();
                case 'partidas': return d._partidas;
                case 'total': return d._total;
                default: return d.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(rmRecepOrden, 'fecha', 'Fecha')}${thOrden(rmRecepOrden, 'orden', 'Orden')}${thOrden(rmRecepOrden, 'proveedor', 'Proveedor')}
              ${thOrden(rmRecepOrden, 'partidas', 'Partidas', 'text-right justify-end')}${thOrden(rmRecepOrden, 'total', 'Total', 'text-right justify-end')}<th class="p-2">Contab.</th>
            </tr></thead>
            <tbody>
              ${data.map(d => {
                  const dets = d.documento_detalles || [];
                  const total = d._total;
                  const fecha = d.fecha_emision ? String(d.fecha_emision).slice(0, 10) : '';
                  const cancelado = d.estado === 'cancelado';
                  return `
                    <tr class="border-b border-slate-900${cancelado ? ' opacity-60' : ''}">
                      <td class="p-2"><button type="button" onclick="window.abrirDetalleDocumentoGlobal(${d.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">Ver</button></td>
                      <td class="p-2 whitespace-nowrap text-slate-400">${fecha}</td>
                      <td class="p-2 font-mono text-emerald-300">${esc(d.ordenes_compra?.folio || d.folio || '#' + d.id)}${cancelado ? ' <span class="text-rose-500 font-sans font-semibold">· CANCELADO</span>' : ''}</td>
                      <td class="p-2">${esc(d.proveedores?.nombre || '—')}</td>
                      <td class="p-2 text-right font-mono">${dets.length}</td>
                      <td class="p-2 text-right font-mono">${money(total)}</td>
                      <td class="p-2">${d.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${d.poliza_id}, '${fecha}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${d.poliza_id}</button>` : '<span class="text-slate-500">—</span>'}</td>
                    </tr>`;
              }).join('')}
            </tbody>
          </table>
        </div>
        <div class="flex items-center justify-between mt-2 text-xs">
          <span class="text-slate-500">${count ?? data.length} recepción(es) · página ${rmRecPagina} de ${totalPaginas}</span>
          <div class="flex gap-2">
            <button type="button" id="rmRecAnterior" ${rmRecPagina <= 1 ? 'disabled' : ''} class="${rmRecPagina <= 1 ? 'opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800' : 'bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700'} px-3 py-1.5 rounded-lg">← Anterior</button>
            <button type="button" id="rmRecSiguiente" ${rmRecPagina >= totalPaginas ? 'disabled' : ''} class="${rmRecPagina >= totalPaginas ? 'opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800' : 'bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700'} px-3 py-1.5 rounded-lg">Siguiente →</button>
          </div>
        </div>`;

        document.getElementById('rmRecAnterior')?.addEventListener('click', () => { if (rmRecPagina > 1) { rmRecPagina--; rmRecepciones(); } });
        document.getElementById('rmRecSiguiente')?.addEventListener('click', () => { if (rmRecPagina < totalPaginas) { rmRecPagina++; rmRecepciones(); } });
        wireOrdenTabla(cont, rmRecepOrden, rmRecepciones);
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">No se pudo cargar el historial: ${esc(err.message || err)}</p>`;
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
    rmOcActual = oc || null;
    if (!oc) {
        if (rmModo === 'xml') return;   // hay un recibo por XML en curso: no lo borres
        cont.innerHTML = ''; btn.classList.add('hidden');
        return;
    }
    rmModo = 'oc';

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
          <td class="p-2">
            <div class="flex items-center gap-1">
              <input type="number" step="any" min="0" class="rm-costo w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 text-right font-mono" value="${Number(d.costo_unitario_estimado || 0)}">
              <button type="button" class="rm-conv-toggle text-[10px] text-sky-400 hover:text-sky-300 whitespace-nowrap" title="Convertir desde la presentación de la factura (millar, gruesa, docena...)">🔁 convertir</button>
            </div>
          </td>
          <td class="p-2"><input type="text" class="rm-lote w-28 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono" placeholder="lote del proveedor"></td>
          <td class="p-2"><input type="date" class="rm-cad w-32 bg-slate-900 border ${reqCad ? 'border-amber-600' : 'border-slate-800'} rounded px-2 py-1 text-xs text-slate-100 font-mono"></td>
        </tr>
        ${rmFilaConversion(pend, d.costo_unitario_estimado)}`;
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
    rmInitExtras();
    rmWireConversiones(cont);

    const recalc = () => {
        let st = 0;
        cont.querySelectorAll('#rmDetBody tr').forEach(tr => {
            const chk = tr.querySelector('.rm-chk');
            if (!chk || !chk.checked) return;
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

// Tipo de cambio a aplicar a los costos (1 si la moneda es MXN).
function rmTcActual() {
    const moneda = (document.getElementById('rmMoneda')?.value.trim().toUpperCase()) || 'MXN';
    return moneda !== 'MXN' ? (parseFloat(document.getElementById('rmTipoCambio')?.value) || 1) : 1;
}

// ---- Landed cost: flete / seguro / etc. de la factura ----
const RM_EXTRA_CONCEPTOS = ['Flete', 'Seguro', 'Maniobras', 'Aduana / pedimento', 'Otro'];

// Detecta, por la descripción del concepto del CFDI, si es un cargo de flete/seguro/etc.
// en vez de mercancía — para NO recibirlo como producto y mandarlo al panel de landed cost.
const RM_CARGO_PATTERNS = [
    [/env[ií]o|flete|fletes|transporte|paqueter[ií]a|mensajer[ií]a|acarreo/i, 'Flete'],
    [/seguro/i, 'Seguro'],
    [/maniobra/i, 'Maniobras'],
    [/aduana|pedimento|agente aduanal|arancel/i, 'Aduana / pedimento'],
];

function rmEsConceptoCargo(descripcion) {
    const txt = String(descripcion || '');
    for (const [re, label] of RM_CARGO_PATTERNS) { if (re.test(txt)) return label; }
    return null;
}

// Separa los conceptos del CFDI en {productos, cargos}. cargos: [{concepto, monto}]
// listos para precargar el panel de Costos adicionales, sin crear producto ni lote.
function rmClasificarConceptos(conceptos) {
    const productos = [], cargos = [];
    (conceptos || []).forEach((c) => {
        const label = rmEsConceptoCargo(c.descripcion);
        if (label) cargos.push({ concepto: label, monto: Number(c.importe || (c.cantidad * c.valorUnitario) || 0) });
        else productos.push(c);
    });
    return { productos, cargos };
}

// Explica el impacto contable de cada decisión y por qué NIF C-4 la respalda,
// para que quede claro renglón por renglón (no solo al momento del diálogo).
function rmxNotaTexto(cap) {
    return cap
        ? '✓ Se capitaliza a 115.xx (inventario) — es la opción que recomienda NIF C-4.'
        : '⚠ Va a gasto 601.14 — NIF C-4 solo lo recomienda si el cargo no es atribuible a la mercancía recibida.';
}

function rmExtraFila(concepto, monto, cap) {
    const opts = RM_EXTRA_CONCEPTOS.map(c => `<option${c === concepto ? ' selected' : ''}>${c}</option>`).join('');
    return `<tr>
      <td class="p-1.5"><select class="rmx-concepto bg-slate-900 border border-slate-800 rounded px-1.5 py-1 text-xs text-slate-100">${opts}</select></td>
      <td class="p-1.5 text-right"><input type="number" step="0.01" min="0" class="rmx-monto w-24 bg-slate-900 border border-slate-800 rounded px-1.5 py-1 text-xs text-slate-100 text-right font-mono" value="${monto ?? ''}"></td>
      <td class="p-1.5 text-center">
        <input type="checkbox" class="rmx-cap accent-emerald-500 w-4 h-4"${cap ? ' checked' : ''}>
        <div class="rmx-nota text-[9px] mt-0.5 leading-tight ${cap ? 'text-emerald-500' : 'text-amber-500'}" style="max-width:8.5rem">${rmxNotaTexto(cap)}</div>
      </td>
      <td class="p-1.5 text-right"><button type="button" class="rmx-del text-rose-400 hover:text-rose-300 text-xs px-1">✕</button></td>
    </tr>`;
}

function rmExtrasRecalc() {
    let cap = 0;
    document.querySelectorAll('#rmExtrasBody tr').forEach(tr => {
        const montoEl = tr.querySelector('.rmx-monto');
        const capEl = tr.querySelector('.rmx-cap');
        if (!montoEl || !capEl) return;
        const m = parseFloat(montoEl.value) || 0;
        if (m > 0 && capEl.checked) cap += m;
    });
    const el = document.getElementById('rmExtrasTotal');
    if (el) el.textContent = money(cap);
}

function rmExtrasWire() {
    const body = document.getElementById('rmExtrasBody');
    if (!body) return;
    body.querySelectorAll('.rmx-del').forEach(b => b.onclick = () => { b.closest('tr').remove(); rmExtrasRecalc(); });
    body.querySelectorAll('.rmx-monto').forEach(el => el.oninput = rmExtrasRecalc);
    body.querySelectorAll('.rmx-cap').forEach(el => el.onchange = () => {
        const nota = el.closest('td').querySelector('.rmx-nota');
        if (nota) {
            nota.textContent = rmxNotaTexto(el.checked);
            nota.className = `rmx-nota text-[9px] mt-0.5 leading-tight ${el.checked ? 'text-emerald-500' : 'text-amber-500'}`;
        }
        rmExtrasRecalc();
    });
    rmExtrasRecalc();
}

// seed: [{concepto, monto}] detectados del CFDI (ver rmClasificarConceptos). Si no
// hay, arranca con Flete/Seguro en blanco como antes.
function rmInitExtras(seed) {
    const wrap = document.getElementById('rmExtrasWrap');
    if (!wrap) return;
    wrap.classList.remove('hidden');
    const body = document.getElementById('rmExtrasBody');
    if (body && !body.children.length) {
        const filas = (seed && seed.length) ? seed : [{ concepto: 'Flete', monto: '' }, { concepto: 'Seguro', monto: '' }];
        body.innerHTML = filas.map((f) => rmExtraFila(f.concepto, f.monto || '', true)).join('');
    }
    const add = document.getElementById('rmExtraAdd');
    if (add) add.onclick = () => { body.insertAdjacentHTML('beforeend', rmExtraFila('Otro', '', true)); rmExtrasWire(); };
    rmExtrasWire();
    if (seed && seed.length) {
        const aviso = document.getElementById('rmExtrasAviso');
        if (aviso) aviso.textContent = `Detectados en el CFDI y precargados aquí (no se recibieron como producto): ${seed.map((s) => s.concepto).join(', ')}.`;
    }
}

// Cada vez que se detecten cargos tipo flete/seguro/maniobras/aduana en un
// CFDI, se PREGUNTA si se deben incluir en el landed cost — nunca se asume
// en automático. Devuelve {usar, declinado}: usar = los cargos a precargar
// en el panel (vacío si el usuario dice que no), declinado = true si había
// cargos y el usuario eligió no incluirlos (para poder avisarle igual).
function rmPreguntarLandedCost(cargos) {
    if (!cargos || !cargos.length) return Promise.resolve({ usar: [], declinado: false });
    return new Promise((resolve) => {
        const total = cargos.reduce((s, c) => s + (c.monto || 0), 0);
        const detalle = cargos.map((c) => `<div>· ${esc(c.concepto)}: <b class="font-mono">${money(c.monto)}</b></div>`).join('');
        const modal = document.createElement('div');
        modal.className = 'fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4';
        modal.innerHTML = `
          <div class="bg-slate-900 border border-slate-700 rounded-xl p-5 max-w-md w-full text-sm text-slate-200 shadow-2xl">
            <h3 class="text-sky-400 font-semibold mb-1">⚠ Detecté cargos de flete / seguro en la factura</h3>
            <div class="text-xs text-slate-400 mb-3">${detalle}<div class="mt-1 text-slate-300">Total: <b class="font-mono">${money(total)}</b></div></div>
            <p class="text-xs text-slate-400 mb-2">¿Cómo se contabilizan?</p>
            <div class="space-y-2 mb-4">
              <label class="flex items-start gap-2 bg-emerald-950/40 border border-emerald-700 rounded-lg p-2 cursor-pointer">
                <input type="radio" name="rmDecCargos" value="landed" checked class="mt-1 accent-emerald-500">
                <span><b class="text-emerald-400">Incluir en landed cost</b> <span class="text-emerald-500">(preset · recomendado)</span> — se prorratean por valor y se cargan al costo del lote / cuenta de inventario (115.xx), no a gasto. Es lo que pide NIF C-4 para flete/seguro necesarios para poner la mercancía en su ubicación y condición de venta.</span>
              </label>
              <label class="flex items-start gap-2 bg-slate-950 border border-slate-800 rounded-lg p-2 cursor-pointer">
                <input type="radio" name="rmDecCargos" value="gasto" class="mt-1 accent-amber-500">
                <span><b class="text-amber-400">No incluirlos aquí</b> — los registro luego como gasto aparte (601.14 Fletes y acarreos). NIF C-4 solo recomienda esto si el cargo no es atribuible a la mercancía recibida.</span>
              </label>
            </div>
            <div class="flex justify-end gap-2">
              <button type="button" id="rmDecOk" class="bg-emerald-600 hover:bg-emerald-500 text-white px-3 py-1.5 rounded text-xs font-medium">Continuar</button>
            </div>
          </div>`;
        document.body.appendChild(modal);
        const cerrar = (usar, declinado) => { modal.remove(); resolve({ usar, declinado }); };
        modal.querySelector('#rmDecOk').onclick = () => {
            const val = modal.querySelector('input[name="rmDecCargos"]:checked').value;
            cerrar(val === 'landed' ? cargos : [], val !== 'landed');
        };
    });
}

// Agrega los cargos ya confirmados al panel de Costos adicionales. Si el
// panel solo tiene los renglones default en blanco (Flete/Seguro sin monto),
// los reemplaza; si ya tiene datos capturados a mano, los conserva y agrega.
function rmSembrarExtras(cargos) {
    const body = document.getElementById('rmExtrasBody');
    if (!body || !cargos || !cargos.length) return;
    const filasActuales = [...body.querySelectorAll('tr')];
    const soloDefaultVacio = filasActuales.every(tr => !parseFloat(tr.querySelector('.rmx-monto')?.value));
    if (soloDefaultVacio) body.innerHTML = '';
    cargos.forEach((c) => body.insertAdjacentHTML('beforeend', rmExtraFila(c.concepto, c.monto, true)));
    rmExtrasWire();
    const aviso = document.getElementById('rmExtrasAviso');
    if (aviso) aviso.textContent = `Detectados en el CFDI y precargados aquí (no se recibieron como producto): ${cargos.map((s) => s.concepto).join(', ')}.`;
}

function rmLeerExtras() {
    return [...document.querySelectorAll('#rmExtrasBody tr')].map(tr => ({
        concepto: tr.querySelector('.rmx-concepto').value,
        monto: parseFloat(tr.querySelector('.rmx-monto').value) || 0,
        capitaliza: tr.querySelector('.rmx-cap').checked,
    })).filter(e => e.monto > 0);
}

// ---- Conversión de presentación por partida (millar, gruesa, docena...) ----
// Evita el error de teclear la cantidad ya convertida (ej. 40,000 piezas) pero
// dejar el costo tal cual venía en la factura (ej. $241.38 por MILLAR, no por pieza).
function rmFilaConversion(cantidadActual, precioActual) {
    const cantVal = Number(cantidadActual) > 0 ? Number(cantidadActual) : '';
    const precioVal = Number(precioActual) > 0 ? Number(precioActual) : '';
    return `<tr class="rm-conv-row hidden bg-slate-900/60">
      <td colspan="12" class="p-2">
        <div class="flex flex-wrap items-end gap-2 text-[11px]">
          <span class="text-slate-400">Convertir desde la presentación de la factura:</span>
          <div><label class="block text-slate-500 mb-0.5">Cant. en factura</label>
            <input type="number" step="any" min="0" class="rm-conv-cant w-20 bg-slate-950 border border-slate-800 rounded px-1.5 py-1 text-slate-100 text-right font-mono" value="${cantVal}"></div>
          <div><label class="block text-slate-500 mb-0.5">Presentación</label>
            <select class="rm-conv-preset bg-slate-950 border border-slate-800 rounded px-1.5 py-1 text-slate-100">
              <option value="">Preset…</option>
              <optgroup label="Piezas">
                <option value="1000">Millar (×1000 piezas)</option>
                <option value="144">Gruesa (×144 piezas)</option>
                <option value="12">Docena (×12 piezas)</option>
              </optgroup>
              <optgroup label="Volumen / peso a granel">
                <option value="200">Tambo 200 L (×200 L)</option>
                <option value="208">Tambo 208 L (×208 L)</option>
                <option value="1000">Kilo a gramos (×1000 g)</option>
                <option value="1000">Litro a mililitros (×1000 mL)</option>
                <option value="25">Saco 25 kg (×25 kg)</option>
                <option value="50">Saco 50 kg (×50 kg)</option>
              </optgroup>
            </select></div>
          <div><label class="block text-slate-500 mb-0.5">Factor</label>
            <input type="number" step="any" min="0.0001" value="1" class="rm-conv-factor w-16 bg-slate-950 border border-slate-800 rounded px-1.5 py-1 text-slate-100 text-right font-mono"></div>
          <div><label class="block text-slate-500 mb-0.5">Precio en factura (por esa presentación)</label>
            <input type="number" step="any" min="0" class="rm-conv-precio w-24 bg-slate-950 border border-slate-800 rounded px-1.5 py-1 text-slate-100 text-right font-mono" value="${precioVal}"></div>
          <button type="button" class="rm-conv-aplicar bg-sky-700 hover:bg-sky-600 text-white px-2.5 py-1.5 rounded">Aplicar →</button>
          <span class="rm-conv-resultado text-emerald-400 font-mono"></span>
        </div>
      </td>
    </tr>`;
}

function rmWireConversiones(root) {
    if (!root) return;
    root.querySelectorAll('.rm-conv-toggle').forEach((btn) => {
        btn.onclick = () => {
            const row = btn.closest('tr').nextElementSibling;
            if (row && row.classList.contains('rm-conv-row')) row.classList.toggle('hidden');
        };
    });
    root.querySelectorAll('.rm-conv-preset').forEach((sel) => {
        sel.onchange = () => {
            if (sel.value) sel.closest('tr').querySelector('.rm-conv-factor').value = sel.value;
        };
    });
    root.querySelectorAll('.rm-conv-aplicar').forEach((btn) => {
        btn.onclick = () => {
            const convRow = btn.closest('tr');
            const mainRow = convRow.previousElementSibling;
            const cantF = parseFloat(convRow.querySelector('.rm-conv-cant').value) || 0;
            const factor = parseFloat(convRow.querySelector('.rm-conv-factor').value) || 0;
            const precioF = parseFloat(convRow.querySelector('.rm-conv-precio').value) || 0;
            if (cantF <= 0 || factor <= 0) { alert('Captura la cantidad de la factura y un factor válido.'); return; }
            const cantFinal = cantF * factor;
            const costoFinal = Math.round((precioF / factor) * 1e6) / 1e6;
            const inpCant = mainRow.querySelector('.rm-cant');
            const inpCosto = mainRow.querySelector('.rm-costo');
            if (inpCant) { inpCant.value = cantFinal; inpCant.dispatchEvent(new Event('input', { bubbles: true })); }
            if (inpCosto) { inpCosto.value = costoFinal; inpCosto.dispatchEvent(new Event('input', { bubbles: true })); }
            mainRow.dataset.convertido = '1';   // para avisar si se reimporta el archivo y se perdería este ajuste
            const res = convRow.querySelector('.rm-conv-resultado');
            if (res) res.textContent = `= ${cantFinal.toLocaleString('es-MX')} × $${costoFinal} c/u`;
        };
    });
}

// Resumen "cantidad × costo real = subtotal" por partida, para que el
// último clic de confirmación muestre el costo unitario tal cual se va a
// guardar — así un error de conversión (ej. $241 en vez de $0.24) se ve
// clarísimo ANTES de guardar, sin importar en qué paso se haya originado.
function rmResumenLineas(lineas, etiquetaFn) {
    const fmt = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 4 });
    let total = 0;
    const filas = lineas.map((l) => {
        const sub = l.cantidad * l.costo;
        total += sub;
        return `· ${etiquetaFn(l)}: ${l.cantidad.toLocaleString('es-MX')} × ${fmt(l.costo)} c/u = ${fmt(sub)}`;
    });
    return filas.join('\n') + `\n\nTotal material: ${fmt(total)}`;
}

// Convierte los extras a MXN, reparte por valor y anota landedUnit / adicUnit en cada línea.
function rmAplicarLanded(lineas, tc) {
    const extras = rmLeerExtras().map(e => ({
        concepto: e.concepto, monto: e.monto * (tc || 1), capitaliza: e.capitaliza, cuenta_gasto_id: null,
    }));
    const capTotal = extras.filter(e => e.capitaliza).reduce((a, e) => a + e.monto, 0);
    const matSubtotal = lineas.reduce((a, l) => a + l.cantidad * l.costo, 0);
    lineas.forEach(l => {
        const lineSub = l.cantidad * l.costo;
        const extraLinea = (capTotal > 0 && matSubtotal > 0) ? capTotal * (lineSub / matSubtotal) : 0;
        l.adicUnit = l.cantidad > 0 ? extraLinea / l.cantidad : 0;
        l.landedUnit = l.costo + l.adicUnit;
    });
    return { extras, matSubtotal, capTotal };
}

// Inserta el detalle (costo MATERIAL) + mueve inventario FIFO (costo LANDED) +
// guarda lote del proveedor, caducidad y la parte adicional del costo.
async function rmAplicarEntradaLinea(documentoId, productoId, cantidad, costo, lote, caducidad, landedUnit, adicUnit) {
    const { error: eDet } = await supabaseClient.from('documento_detalles').insert([{
        documento_id: documentoId, producto_id: productoId, cantidad, costo_unitario: costo, subtotal: cantidad * costo,
    }]);
    if (eDet) throw eDet;

    const costoLote = (landedUnit != null && landedUnit > 0) ? landedUnit : costo;
    const { error: eFifo } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
        p_producto_id: productoId, p_cantidad: cantidad, p_tipo_movimiento: 'entrada',
        p_documento_id: documentoId, p_costo_unitario: costoLote, p_numero_lote: lote,
    });
    if (eFifo) throw eFifo;

    let loteRowId = null;
    try {
        let { data: loteRow } = await supabaseClient.from('lotes_inventario')
            .select('id').eq('producto_id', productoId).eq('numero_lote', lote)
            .eq('documento_id', documentoId).order('created_at', { ascending: false }).limit(1).maybeSingle();
        if (!loteRow) {
            ({ data: loteRow } = await supabaseClient.from('lotes_inventario')
                .select('id').eq('producto_id', productoId).eq('numero_lote', lote)
                .order('created_at', { ascending: false }).limit(1).maybeSingle());
        }
        if (loteRow) {
            loteRowId = loteRow.id;
            await supabaseClient.from('lotes_inventario')
                .update({ lote_proveedor: lote, fecha_caducidad: caducidad }).eq('id', loteRow.id);
        }
    } catch (_) { /* columnas de caducidad aún no existen */ }

    if (loteRowId && adicUnit != null && adicUnit > 0) {
        try {
            await supabaseClient.from('lotes_inventario')
                .update({ costo_adicional_unitario: adicUnit }).eq('id', loteRowId);
        } catch (_) { /* falta sql/2026-09-20_landed_cost.sql */ }
    }
}

// Contabiliza el documento con los importes del bloque fiscal. Devuelve un texto de estado.
// extras: cargos adicionales (flete/seguro) YA en MXN, de rmAplicarLanded().
async function rmContabilizarDoc(documentoId, subtotalFallback, extras) {
    const chk = document.getElementById('rmContabilizar');
    if (rmSinContab || !chk || !chk.checked) return '';
    const nf = (id) => Math.max(0, parseFloat(document.getElementById(id)?.value) || 0);
    // Los importes en pantalla están en la moneda de la factura; la contabilidad va en MXN.
    const moneda = (document.getElementById('rmMoneda')?.value.trim().toUpperCase()) || 'MXN';
    const tc = moneda !== 'MXN' ? (parseFloat(document.getElementById('rmTipoCambio')?.value) || 1) : 1;
    let subtotal = nf('rmSubtotal') * tc;
    if (subtotal <= 0) subtotal = subtotalFallback;   // el fallback ya viene en MXN
    // Con cargos adicionales: el subtotal enviado es SOLO material (los extras van aparte),
    // para no contarlos dos veces si el CFDI ya los traía como partida.
    if (Array.isArray(extras) && extras.length) subtotal = subtotalFallback;
    const condicion = document.getElementById('rmCondicion').value;
    try {
        const { data: cc, error: eCc } = await supabaseClient.rpc('contabilizar_compra', {
            p_documento_id: documentoId,
            p_datos: {
                subtotal,
                iva: nf('rmIva') * tc, ieps: nf('rmIeps') * tc, ret_iva: nf('rmRetIva') * tc, ret_isr: nf('rmRetIsr') * tc,
                condicion,
                costos_adicionales: (extras || []).map(e => ({
                    concepto: e.concepto, monto: e.monto, capitaliza: e.capitaliza, cuenta_gasto_id: e.cuenta_gasto_id || null,
                })),
                tipo_cambio: tc,
                forma_pago: document.getElementById('rmFormaPago')?.value || null,
                metodo_pago: document.getElementById('rmMetodoPago')?.value || null,
                uso_cfdi: document.getElementById('rmUsoCfdi')?.value || null,
                moneda,
                cuenta_pago_id: condicion === 'contado' && document.getElementById('rmCuentaPago')?.value
                    ? parseInt(document.getElementById('rmCuentaPago').value) : null,
                uuid_cfdi: document.getElementById('rmUuid').value.trim() || null,
                rfc_emisor: document.getElementById('rmRfc').value.trim() || null,
            },
        });
        if (eCc) throw eCc;
        return cc && cc.total != null
            ? ` Póliza de Egreso generada (total ${money(cc.total)}).`
            : ' Póliza de Egreso generada.';
    } catch (e) {
        return ` (Entrada OK, pero no se contabilizó: ${e.message || e})`;
    }
}

async function rmConfirmar(ocs) {
    if (rmModo === 'xml') return rmConfirmarXml();

    const msg = document.getElementById('rmMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';
    const ocId = Number(document.getElementById('rmOC').value);
    const oc = ocs.find(o => o.id === ocId);
    if (!oc) { msg.textContent = 'Elige una orden de compra o importa un XML.'; msg.className = 'text-xs text-rose-400'; return; }

    const lineas = [];
    const errores = [];
    document.querySelectorAll('#rmDetBody tr').forEach(tr => {
        const chk = tr.querySelector('.rm-chk');
        if (!chk || !chk.checked) return;
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
        lineas.push({ det, label: nom, cantidad: cant, costo: parseFloat(tr.querySelector('.rm-costo').value) || 0, lote, caducidad });
    });
    if (!lineas.length) { msg.textContent = 'Marca al menos una partida con cantidad mayor a 0.'; msg.className = 'text-xs text-rose-400'; return; }
    if (errores.length) { alert('⚠ Revisa:\n' + errores.join('\n')); return; }
    if (!confirm(`¿Confirmar recepción de ${lineas.length} partida(s) de la orden ${oc.folio}?\n\nRevisa el costo unitario de cada una — así se va a guardar:\n\n${rmResumenLineas(lineas, (l) => l.label)}`)) return;

    const tc = rmTcActual();
    if (tc !== 1) lineas.forEach(l => { l.costo = l.costo * tc; });   // a MXN
    const landed = rmAplicarLanded(lineas, tc);   // reparte flete/seguro -> l.landedUnit / l.adicUnit

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

            await rmAplicarEntradaLinea(documentoId, productoId, l.cantidad, l.costo, l.lote, l.caducidad, l.landedUnit, l.adicUnit);
            // Deja el costo del catálogo con el último costo de compra (landed, en MXN).
            await supabaseClient.from('productos').update({ costo_unitario: (l.landedUnit ?? l.costo) }).eq('id', productoId);

            await supabaseClient.from('ordenes_compra_detalle')
                .update({ cantidad_recibida: Number(l.det.cantidad_recibida || 0) + l.cantidad })
                .eq('id', l.det.id);
        }

        const msgContab = await rmContabilizarDoc(documentoId, landed.matSubtotal, landed.extras);

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

// Tabla de recepción armada desde los conceptos de un CFDI (sin orden de compra).
function rmRenderDetalleXml(conceptos, meta) {
    rmModo = 'xml';
    rmXmlMeta = meta;
    const cont = document.getElementById('rmDetalle');
    const btn = document.getElementById('rmConfirmar');
    const clavesMap = meta.claves || new Map();
    const claveSatMap = meta.clavesSat || new Map();

    // Un mismo insumo suele llegar de más de un proveedor, cada quien con su
    // propio código/nombre en la factura — por eso el match automático (por
    // clave ya homologada, SKU o nombre) puede fallar aunque el producto ya
    // exista en el catálogo. Este selector deja elegir el producto real del
    // catálogo (fuente: tabla productos, como pide CLAUDE.md) en vez de crear
    // un duplicado; si se homologa un renglón que venía sin coincidencia,
    // rmConfirmarXml() guarda la clave de este proveedor para ese producto en
    // producto_claves_proveedor, así la próxima factura del mismo proveedor
    // ya empareja sola.
    const optsProductos = ocProductos.map(p => `<option value="${p.id}">${esc(p.sku || 's/SKU')} · ${esc(p.nombre)}</option>`).join('');

    let hits = 0;
    const filas = conceptos.map((cp, i) => {
        let prodId = null;
        if (cp.noId && clavesMap.has(normTxt(cp.noId))) prodId = clavesMap.get(normTxt(cp.noId));
        if (!prodId && cp.claveSat && claveSatMap.has(cp.claveSat)) prodId = claveSatMap.get(cp.claveSat);
        if (!prodId && cp.noId) {
            const bySku = ocProductos.find(p => p.sku && normTxt(p.sku) === normTxt(cp.noId));
            if (bySku) prodId = bySku.id;
        }
        if (!prodId && cp.descripcion) {
            const nd = normTxt(cp.descripcion);
            const byName = ocProductos.find(p => p.nombre && (nd.includes(normTxt(p.nombre)) || normTxt(p.nombre).includes(nd)));
            if (byName) prodId = byName.id;
        }
        const prod = prodId ? ocProductos.find(p => p.id === prodId) : null;
        if (prod) hits++;
        const reqCad = !!(prod && prod.requiere_caducidad);
        return `
        <tr class="border-b border-slate-900" data-cpidx="${i}" data-prodid="${prodId || ''}" data-prodid-auto="${prodId || ''}" data-desc="${esc(cp.descripcion || 'Producto CFDI')}" data-unidadid="${prod ? (prod.unidad_medida_id || '') : ''}" data-reqcad="${reqCad ? 1 : 0}" data-nocfdi="${esc(cp.noId || '')}">
          <td class="p-2 text-center"><input type="checkbox" class="rm-chk accent-emerald-500 w-4 h-4" checked></td>
          <td class="p-2 text-slate-100">
            <div class="text-[11px] text-slate-500">${esc(cp.descripcion || cp.noId || 'sin descripción')}</div>
            <select class="rm-prod-select w-full mt-1 bg-slate-900 border ${prod ? 'border-slate-800' : 'border-amber-700'} rounded px-1.5 py-1 text-xs text-slate-100">
              <option value="">➕ Crear producto nuevo</option>
              ${optsProductos}
            </select>
            <p class="rm-prod-nota text-[10px] mt-0.5 ${prod ? 'text-emerald-400' : 'text-amber-400'}">${prod ? '✓ coincide con el catálogo' : 'sin coincidencia — elige el producto del catálogo o déjalo así para crearlo'}</p>
          </td>
          <td class="p-2 font-mono text-slate-500 text-[10px]">${esc(cp.claveSat || '')}${cp.noId ? `<br>${esc(cp.noId)}` : ''}</td>
          <td class="p-2"><input type="number" step="any" min="0" class="rm-cant w-20 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 text-right font-mono" value="${cp.cantidad || 0}"></td>
          <td class="p-2">
            <div class="flex items-center gap-1">
              <input type="number" step="any" min="0" class="rm-costo w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 text-right font-mono" value="${Number(cp.valorUnitario || 0).toFixed(4)}">
              <button type="button" class="rm-conv-toggle text-[10px] text-sky-400 hover:text-sky-300 whitespace-nowrap" title="Convertir desde la presentación de la factura (millar, gruesa, docena...)">🔁 convertir</button>
            </div>
          </td>
          <td class="p-2"><input type="text" class="rm-lote w-28 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono" placeholder="lote del proveedor"></td>
          <td class="p-2"><input type="date" class="rm-cad w-32 bg-slate-900 border ${reqCad ? 'border-amber-600' : 'border-slate-800'} rounded px-2 py-1 text-xs text-slate-100 font-mono"></td>
        </tr>
        ${rmFilaConversion(cp.cantidad, cp.valorUnitario)}`;
    }).join('');

    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <p class="text-xs text-slate-400 mb-2">Partidas del CFDI (sin orden de compra). Revisa cantidades y costos, elige a qué <b>producto del catálogo</b> corresponde cada partida (o déjala para crear uno nuevo), y captura el <b>lote del proveedor</b> y la caducidad. Coincidieron ${hits} de ${conceptos.length}; si eliges el producto correcto en las que no coincidieron, la próxima factura de este proveedor ya empareja sola.</p>
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Recibir</th><th class="p-2">Producto</th><th class="p-2">Clave SAT / prov.</th>
              <th class="p-2">Cantidad</th><th class="p-2">Costo</th><th class="p-2">Lote del proveedor</th><th class="p-2">Caducidad</th>
            </tr></thead>
            <tbody id="rmDetBody">${filas}</tbody>
          </table>
        </div>
      </div>`;
    btn.classList.remove('hidden');
    rmInitExtras(rmCargosXml);
    rmWireConversiones(cont);

    cont.querySelectorAll('.rm-prod-select').forEach(sel => {
        const tr = sel.closest('tr');
        sel.value = tr.dataset.prodid || '';
        sel.addEventListener('change', () => {
            const prodId = sel.value ? Number(sel.value) : null;
            const prod = prodId ? ocProductos.find(p => p.id === prodId) : null;
            tr.dataset.prodid = prodId || '';
            tr.dataset.unidadid = prod ? (prod.unidad_medida_id || '') : '';
            const reqCad = !!(prod && prod.requiere_caducidad);
            tr.dataset.reqcad = reqCad ? '1' : '0';
            sel.className = sel.className.replace(/border-(slate-800|amber-700)/, prod ? 'border-slate-800' : 'border-amber-700');
            const cadInput = tr.querySelector('.rm-cad');
            cadInput.className = cadInput.className.replace(/border-(slate-800|amber-600)/, reqCad ? 'border-amber-600' : 'border-slate-800');
            const nota = tr.querySelector('.rm-prod-nota');
            if (prodId) {
                const esHomologacion = prodId !== Number(tr.dataset.prodidAuto || 0);
                nota.className = 'rm-prod-nota text-[10px] mt-0.5 text-emerald-400';
                nota.textContent = esHomologacion ? '✓ producto elegido — se guardará esta clave del proveedor para la próxima vez' : '✓ coincide con el catálogo';
            } else {
                nota.className = 'rm-prod-nota text-[10px] mt-0.5 text-amber-400';
                nota.textContent = 'se creará como producto nuevo en el catálogo';
            }
        });
    });
}

// Recepción directa a partir de un XML (sin orden de compra).
async function rmConfirmarXml() {
    const msg = document.getElementById('rmMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';

    const lineas = [];
    const errores = [];
    document.querySelectorAll('#rmDetBody tr').forEach(tr => {
        const chk = tr.querySelector('.rm-chk');
        if (!chk || !chk.checked) return;
        const cant = parseFloat(tr.querySelector('.rm-cant').value) || 0;
        if (cant <= 0) return;
        const desc = tr.dataset.desc || 'Producto CFDI';
        const lote = tr.querySelector('.rm-lote').value.trim();
        const caducidad = tr.querySelector('.rm-cad').value || null;
        if (!lote) errores.push(`Falta el lote del proveedor de "${desc}".`);
        if (tr.dataset.reqcad === '1' && !caducidad) errores.push(`Falta la caducidad de "${desc}".`);
        const prodId = tr.dataset.prodid ? Number(tr.dataset.prodid) : null;
        const prodIdAuto = tr.dataset.prodidAuto ? Number(tr.dataset.prodidAuto) : null;
        lineas.push({
            prodId,
            desc,
            unidadId: tr.dataset.unidadid ? Number(tr.dataset.unidadid) : null,
            cantidad: cant,
            costo: parseFloat(tr.querySelector('.rm-costo').value) || 0,
            lote, caducidad,
            // Se homologó a mano si el producto elegido existe y no coincide
            // con el auto-match (o no hubo auto-match): guarda la clave de
            // este proveedor para ese producto y la próxima factura empareja sola.
            noIdCfdi: tr.dataset.nocfdi || '',
            homologar: !!prodId && prodId !== prodIdAuto,
        });
    });
    if (!lineas.length) { msg.textContent = 'Marca al menos una partida con cantidad mayor a 0.'; msg.className = 'text-xs text-rose-400'; return; }
    if (errores.length) { alert('⚠ Revisa:\n' + errores.join('\n')); return; }
    if (!confirm(`¿Registrar la recepción de ${lineas.length} partida(s) del CFDI (sin orden de compra)?\n\nRevisa el costo unitario de cada una — así se va a guardar:\n\n${rmResumenLineas(lineas, (l) => l.desc)}`)) return;

    const tc = rmTcActual();
    if (tc !== 1) lineas.forEach(l => { l.costo = l.costo * tc; });   // a MXN
    const landed = rmAplicarLanded(lineas, tc);

    const btn = document.getElementById('rmConfirmar');
    btn.disabled = true;
    try {
        const folio = (rmXmlMeta && rmXmlMeta.folio) || 'CFDI';
        const { data: doc, error: eDoc } = await supabaseClient.from('documentos').insert([{
            tipo_movimiento: 'entrada_compra',
            folio,
            proveedor_id: rmXmlMeta ? rmXmlMeta.proveedorId : null,
            fecha_emision: hoyISO(),
            notas: `Recibo desde CFDI ${rmXmlMeta && rmXmlMeta.uuid ? rmXmlMeta.uuid : ''}`.trim(),
            estado: 'completado',
        }]).select('id').single();
        if (eDoc) throw eDoc;
        const documentoId = doc.id;

        for (const l of lineas) {
            let productoId = l.prodId;
            if (!productoId) {
                const { data: np, error: eNp } = await supabaseClient.from('productos').insert([{
                    nombre: l.desc,
                    costo_unitario: l.costo,
                    proveedor_id: rmXmlMeta ? rmXmlMeta.proveedorId : null,
                    unidad_medida_id: l.unidadId,
                    tipo: 'materia_prima',
                    stock_actual: 0,
                }]).select('id').single();
                if (eNp) throw eNp;
                productoId = np.id;
            }
            await rmAplicarEntradaLinea(documentoId, productoId, l.cantidad, l.costo, l.lote, l.caducidad, l.landedUnit, l.adicUnit);
            await supabaseClient.from('productos').update({ costo_unitario: (l.landedUnit ?? l.costo) }).eq('id', productoId);

            // Homologación: si se eligió a mano un producto existente para una
            // partida que el CFDI trae con su propia clave, se guarda esa
            // clave de este proveedor -> producto, para que la próxima
            // factura del mismo proveedor empareje sola.
            if (l.homologar && l.noIdCfdi && rmXmlMeta?.proveedorId) {
                try {
                    await supabaseClient.from('producto_claves_proveedor').insert([{
                        producto_id: productoId,
                        proveedor_id: rmXmlMeta.proveedorId,
                        clave: l.noIdCfdi,
                        descripcion_factura: l.desc,
                    }]);
                } catch (_) { /* no bloquea la recepción si la tabla de claves no existe o ya había una */ }
            }
        }

        const msgContab = await rmContabilizarDoc(documentoId, landed.matSubtotal, landed.extras);
        alert(`✅ Recepción registrada (documento #${documentoId}).${msgContab}`);

        if (typeof cargarInventarioCompleto === 'function') await cargarInventarioCompleto();
        await cargarModuloReciboMercancia();
    } catch (err) {
        msg.textContent = 'No se pudo registrar la recepción: ' + (err.message || err);
        msg.className = 'text-xs text-rose-400';
        btn.disabled = false;
    }
}

// ---- Importar XML del CFDI: prellena impuestos y concilia partidas ----
async function rmProcesarXml(text) {
    const r = parsearCfdi(text);
    if (r.error) { alert('No se pudo leer el XML: ' + r.error); return; }
    await rmProcesarDatosFactura(r, { icono: '📄', fuente: 'XML' });
}

// ---- Importar PDF de la factura: mismos campos, mejor esfuerzo (sin XML) ----
async function rmProcesarPdf(file) {
    const info = document.getElementById('rmImportInfo');
    if (info) info.textContent = 'Leyendo el PDF…';
    try {
        const texto = await extraerTextoPdf(file);
        const r = parsearCfdiPdf(texto);
        await rmProcesarDatosFactura(r, { icono: '📕', fuente: 'PDF' });
    } catch (e) {
        alert('No se pudo leer el PDF: ' + (e.message || e));
    }
}

// ---- Aplica a la pantalla los datos ya interpretados (de XML o de PDF) ----
async function rmProcesarDatosFactura(datos, { icono = '📄', fuente = 'XML' } = {}) {
    const yaConvertidas = document.querySelectorAll('#rmDetBody tr[data-convertido="1"]').length;
    if (yaConvertidas) {
        const seguir = confirm(
            `Ya habías aplicado la conversión de presentación (🔁 convertir) a ${yaConvertidas} partida(s) en esta pantalla.\n\n` +
            `Si importas otro archivo ahora, esas partidas se vuelven a llenar con los valores tal cual vienen en el archivo — se PERDERÍA la conversión que ya hiciste.\n\n` +
            `¿Continuar de todas formas?`
        );
        if (!seguir) return;
    }
    const info = document.getElementById('rmImportInfo');
    const {
        subtotal, total: totalCfdi, folio, rfcEmisor, nombreEmisor, regimenEmisor,
        lugarExpedicion: cpEmisor, uuid, moneda, tipoCambio, formaPago, metodoPago,
        usoCfdi, iva, ieps, retIva, retIsr, conceptos, avisos,
    } = datos;

    const setV = (id, v) => { const el = document.getElementById(id); if (el) el.value = Number(v).toFixed(2); };
    if (!rmSinContab) {
        setV('rmSubtotal', subtotal);
        setV('rmIva', iva);
        setV('rmIeps', ieps);
        setV('rmRetIva', retIva);
        setV('rmRetIsr', retIsr);
        const rTot = document.getElementById('rmTotal');
        if (rTot) rTot.value = money(subtotal + iva + ieps - retIva - retIsr);
    }
    const elRfc = document.getElementById('rmRfc'); if (elRfc && rfcEmisor) elRfc.value = rfcEmisor;
    const elUuid = document.getElementById('rmUuid'); if (elUuid && uuid) elUuid.value = uuid;
    const elMon = document.getElementById('rmMoneda'); if (elMon && moneda) elMon.value = moneda;
    const elTc = document.getElementById('rmTipoCambio'); if (elTc) elTc.value = (moneda !== 'MXN' && tipoCambio > 0) ? tipoCambio : 1;
    const setSel = (id, v) => {
        const el = document.getElementById(id);
        if (!el || !v) return;
        el.value = v;
        if (el.value !== v) {   // el código no está en el catálogo cargado
            const o = document.createElement('option');
            o.value = v; o.textContent = v + ' · (no en catálogo)';
            el.appendChild(o);
            el.value = v;
        }
    };
    setSel('rmFormaPago', formaPago);
    setSel('rmMetodoPago', metodoPago);
    setSel('rmUsoCfdi', usoCfdi);

    let conc = 0;
    const sinMatch = [];
    const cargosOc = [];
    let cargosDecision = { usar: [], declinado: false };
    let cargosDetectados = [];
    if (rmOcActual) {
        let claves = [];
        try {
            const prodIds = (rmOcActual.ordenes_compra_detalle || []).map(d => d.producto_id).filter(Boolean);
            if (prodIds.length) {
                const { data } = await supabaseClient.from('producto_claves_proveedor')
                    .select('producto_id, clave, clave_sat')
                    .eq('proveedor_id', rmOcActual.proveedor_id).in('producto_id', prodIds);
                claves = data || [];
            }
        } catch (_) { claves = []; }
        const porClave = new Map(claves.filter(c => c.clave).map(c => [normTxt(c.clave), c.producto_id]));
        const porSat = new Map(claves.filter(c => c.clave_sat).map(c => [String(c.clave_sat).trim(), c.producto_id]));

        const filasTr = [...document.querySelectorAll('#rmDetBody tr')];
        const detById = new Map((rmOcActual.ordenes_compra_detalle || []).map(d => [d.id, d]));
        const nombreDet = (d) => normTxt(d.producto_id ? (ocProductos.find(p => p.id === d.producto_id)?.nombre || '') : (d.descripcion || ''));

        for (const cp of conceptos) {
            const cargoLabel = rmEsConceptoCargo(cp.descripcion);
            if (cargoLabel) {
                cargosOc.push({ concepto: cargoLabel, monto: cp.cantidad * cp.valorUnitario, texto: cp.descripcion });
                continue;   // flete/seguro/etc.: no se intenta emparejar contra partidas de la OC
            }
            let prodId = null;
            if (cp.noId && porClave.has(normTxt(cp.noId))) prodId = porClave.get(normTxt(cp.noId));
            if (!prodId && cp.claveSat && porSat.has(cp.claveSat)) prodId = porSat.get(cp.claveSat);

            let tr = prodId ? filasTr.find(t => { const d = detById.get(Number(t.dataset.detid)); return d && d.producto_id === prodId; }) : null;
            if (!tr && cp.descripcion) {
                const nd = normTxt(cp.descripcion);
                tr = filasTr.find(t => {
                    const d = detById.get(Number(t.dataset.detid)); if (!d) return false;
                    const nom = nombreDet(d);
                    return nom && (nd.includes(nom) || nom.includes(nd));
                });
            }
            if (tr) {
                tr.querySelector('.rm-chk').checked = true;
                if (tr.dataset.convertido !== '1') {
                    if (cp.cantidad > 0) tr.querySelector('.rm-cant').value = cp.cantidad;
                    if (cp.valorUnitario > 0) tr.querySelector('.rm-costo').value = cp.valorUnitario.toFixed(4);
                }
                conc++;
            } else {
                sinMatch.push(cp.descripcion || cp.noId || '(sin descripción)');
            }
        }
        document.querySelector('#rmDetBody .rm-cant')?.dispatchEvent(new Event('input', { bubbles: true }));
        cargosDetectados = cargosOc;
        cargosDecision = await rmPreguntarLandedCost(cargosOc);
        if (cargosDecision.usar.length) rmSembrarExtras(cargosDecision.usar);
    } else {
        // Sin orden de compra: arma la recepción directamente del CFDI.
        let provId = null;
        try {
            const rfcQ = (rfcEmisor || '').trim();
            if (rfcQ) {
                const { data: pv } = await supabaseClient.from('proveedores').select('id').ilike('rfc', rfcQ).limit(1).maybeSingle();
                if (pv) provId = pv.id;
            }
        } catch (_) { /* proveedores sin columna rfc */ }
        const clavesMap = new Map(), clavesSatMap = new Map();
        if (provId) {
            try {
                const { data } = await supabaseClient.from('producto_claves_proveedor')
                    .select('producto_id, clave, clave_sat').eq('proveedor_id', provId);
                (data || []).forEach(c => {
                    if (c.clave) clavesMap.set(normTxt(c.clave), c.producto_id);
                    if (c.clave_sat) clavesSatMap.set(String(c.clave_sat).trim(), c.producto_id);
                });
            } catch (_) { /* tabla de claves aún no existe */ }
        }
        // Flete / seguro / maniobras / aduana: NO se reciben como producto.
        // Se pregunta si se incluyen en el landed cost antes de precargarlos
        // en el panel de Costos adicionales.
        const { productos: conceptosProducto, cargos } = rmClasificarConceptos(conceptos);
        cargosDetectados = cargos;
        cargosDecision = await rmPreguntarLandedCost(cargos);
        rmCargosXml = cargosDecision.usar;
        rmRenderDetalleXml(conceptosProducto, {
            proveedorId: provId, rfc: rfcEmisor, nombreEmisor, uuid, folio, claves: clavesMap, clavesSat: clavesSatMap,
            regimenFiscal: regimenEmisor, usoCfdi, formaPago, metodoPago, moneda, cp: cpEmisor,
        });
    }

    // Los importes fiscales del CFDI son la verdad: se re-aplican por si la
    // conciliación de partidas recalculó el subtotal a partir de las líneas.
    if (!rmSinContab) {
        setV('rmSubtotal', subtotal);
        setV('rmIva', iva);
        setV('rmIeps', ieps);
        setV('rmRetIva', retIva);
        setV('rmRetIsr', retIsr);
        const rTot = document.getElementById('rmTotal');
        if (rTot) rTot.value = money(subtotal + iva + ieps - retIva - retIsr);
    }

    if (info) {
        const sinProveedor = !rmOcActual && rmXmlMeta && !rmXmlMeta.proveedorId;
        info.innerHTML = `${icono} <b>${esc(nombreEmisor || rfcEmisor || fuente)}</b> · Folio ${esc(folio || '—')} · Total ${money(totalCfdi)} · ${conceptos.length} concepto(s)`
            + (rmOcActual
                ? ` · <span class="text-emerald-400">${conc} conciliado(s)</span>${sinMatch.length ? ` · <span class="text-amber-400">${sinMatch.length} sin coincidencia</span>` : ''}`
                : ` · <span class="text-emerald-400">recepción directa (sin orden)</span>${sinProveedor ? ' · <span class="text-amber-400">proveedor no identificado por RFC</span>' : ''}`);
        if (sinMatch.length) {
            info.innerHTML += `<br><span class="text-[10px] text-amber-400">Sin coincidencia: ${sinMatch.slice(0, 8).map(esc).join(' · ')}${sinMatch.length > 8 ? '…' : ''}. Ajusta a mano o agrega la clave del proveedor en Catálogos → Productos.</span>`;
        }
        if (cargosDetectados.length) {
            const lista = cargosDetectados.map((c) => `${esc(c.concepto)} ${money(c.monto)}`).join(', ');
            info.innerHTML += cargosDecision.declinado
                ? `<br><span class="text-[10px] text-amber-400">⚠ Detecté ${lista} en el ${fuente} — NO se recibieron como producto y elegiste no incluirlos en el landed cost. Regístralos como gasto aparte si aplica.</span>`
                : `<br><span class="text-[10px] text-emerald-400">✓ ${lista} incluidos en "Costos adicionales (landed cost)" abajo — no se recibieron como producto.</span>`;
        }
        if (avisos && avisos.length) {
            info.innerHTML += `<br><span class="text-[10px] text-amber-400">⚠ Leído de PDF (menos confiable que el XML) — revisa con cuidado: ${avisos.map(esc).join(' · ')}</span>`;
        }
        if (sinProveedor && nombreEmisor) {
            info.innerHTML += `<br><button type="button" id="rmBtnAltaProveedor" class="mt-1 text-[11px] bg-amber-950 hover:bg-amber-900 text-amber-300 border border-amber-800 px-2.5 py-1 rounded">➕ Dar de alta a "${esc(nombreEmisor)}" y vincularlo</button><div id="rmAltaProvForm"></div>`;
            document.getElementById('rmBtnAltaProveedor').onclick = rmAbrirFormAltaProveedor;
        }
    }
}

// Arma <option>s con el valor leído del XML ya marcado como seleccionado
// (si no está en el catálogo, se agrega igual como opción suelta para no
// perder el dato real del CFDI).
function rmOpcionesConValor(lista, valorActual, etiquetaVacio) {
    const val = (valorActual || '').trim();
    let html = `<option value="">${etiquetaVacio}</option>`;
    let encontrado = false;
    lista.forEach((x) => {
        const sel = x.clave === val;
        if (sel) encontrado = true;
        html += `<option value="${esc(x.clave)}"${sel ? ' selected' : ''}>${esc(x.clave)} · ${esc(x.descripcion)}</option>`;
    });
    if (val && !encontrado) html += `<option value="${esc(val)}" selected>${esc(val)} · (no está en el catálogo, se usa igual)</option>`;
    return html;
}

// Abre el mini-formulario de alta de proveedor con los datos REALES leidos
// del XML (regimen/uso CFDI/forma/metodo/moneda del propio CFDI, no
// valores inventados) para revisarlos y ajustarlos antes de guardar - la
// condicion se sugiere por el MetodoPago del CFDI (PPD = credito, si no
// contado) pero tambien es editable. Los catalogos (regimen SAT, uso
// CFDI, forma y metodo de pago, cuenta contable) salen de las mismas
// tablas/listas que ya usa el resto de la app (REGIMENES de proveedores.js,
// y rmCatUso/rmCatForma/rmCatMetodo/rmCatCuentasGasto ya cargados para el
// formulario de arriba). El C.P. se lee de Comprobante/@LugarExpedicion.
function rmAbrirFormAltaProveedor() {
    if (!rmXmlMeta) return;
    const btn = document.getElementById('rmBtnAltaProveedor');
    const cont = document.getElementById('rmAltaProvForm');
    if (!cont) return;
    if (btn) btn.classList.add('hidden');

    const condicionSugerida = rmXmlMeta.metodoPago === 'PPD' ? 'credito' : 'contado';
    const optRegimen = '<option value="">— régimen —</option>' + REGIMENES.map(([k, v]) => `<option value="${k}"${k === (rmXmlMeta.regimenFiscal || '') ? ' selected' : ''}>${k} · ${esc(v)}</option>`).join('');
    const optCtaGasto = '<option value="">— sin cuenta —</option>' + rmCatCuentasGasto.map(c => `<option value="${c.id}"${c.codigo === '201.01' ? ' selected' : ''}>${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    cont.innerHTML = `
        <div class="mt-2 bg-slate-900/60 border border-amber-800/60 rounded-lg p-2.5 space-y-2 max-w-md">
            <p class="text-[11px] text-amber-300 font-semibold">Dar de alta proveedor — datos leídos del XML, revisa y ajusta si hace falta</p>
            <div class="grid grid-cols-2 gap-2">
                <div class="col-span-2"><label class="block text-[10px] text-slate-400">Nombre</label>
                    <input id="rmApNombre" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100" value="${esc(rmXmlMeta.nombreEmisor || '')}"></div>
                <div><label class="block text-[10px] text-slate-400">RFC</label>
                    <input id="rmApRfc" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono uppercase" value="${esc(rmXmlMeta.rfc || '')}"></div>
                <div><label class="block text-[10px] text-slate-400">Régimen fiscal (SAT)</label>
                    <select id="rmApRegimen" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${optRegimen}</select></div>
                <div><label class="block text-[10px] text-slate-400">Uso CFDI</label>
                    <select id="rmApUso" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${rmOpcionesConValor(rmCatUso, rmXmlMeta.usoCfdi, '—')}</select></div>
                <div><label class="block text-[10px] text-slate-400">Condición</label>
                    <select id="rmApCondicion" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">
                        <option value="contado" ${condicionSugerida === 'contado' ? 'selected' : ''}>Contado</option>
                        <option value="credito" ${condicionSugerida === 'credito' ? 'selected' : ''}>Crédito</option>
                    </select></div>
                <div><label class="block text-[10px] text-slate-400">Forma de pago (SAT)</label>
                    <select id="rmApForma" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${rmOpcionesConValor(rmCatForma, rmXmlMeta.formaPago, '—')}</select></div>
                <div><label class="block text-[10px] text-slate-400">Método de pago</label>
                    <select id="rmApMetodo" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${rmOpcionesConValor(rmCatMetodo, rmXmlMeta.metodoPago, '—')}</select></div>
                <div><label class="block text-[10px] text-slate-400">Moneda</label>
                    <input id="rmApMoneda" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono uppercase" value="${esc(rmXmlMeta.moneda || 'MXN')}"></div>
                <div><label class="block text-[10px] text-slate-400">C.P.</label>
                    <input id="rmApCp" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100 font-mono" value="${esc(rmXmlMeta.cp || '')}" maxlength="5"></div>
                <div class="col-span-2"><label class="block text-[10px] text-slate-400">Cuenta contable</label>
                    <select id="rmApCuenta" class="w-full bg-slate-950 border border-slate-800 rounded px-2 py-1 text-xs text-slate-100">${optCtaGasto}</select></div>
            </div>
            <div class="flex gap-2">
                <button type="button" id="rmApGuardar" class="text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded">Guardar proveedor</button>
                <button type="button" id="rmApCancelar" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded">Cancelar</button>
            </div>
            <p id="rmApMsg" class="text-[11px] min-h-[1rem]"></p>
        </div>`;

    document.getElementById('rmApCancelar').onclick = () => {
        cont.innerHTML = '';
        if (btn) btn.classList.remove('hidden');
    };
    document.getElementById('rmApGuardar').onclick = rmGuardarProveedorDesdeXml;
}

// Guarda el proveedor con los valores que quedaron en el mini-formulario
// (ya editados o no) y lo enlaza de inmediato a esta recepción.
async function rmGuardarProveedorDesdeXml() {
    if (!rmXmlMeta || rmXmlMeta.proveedorId) return;
    const $ = (id) => document.getElementById(id);
    const nombre = $('rmApNombre').value.trim();
    const msg = $('rmApMsg');
    if (!nombre) { msg.textContent = 'El nombre es obligatorio.'; msg.className = 'text-[11px] text-rose-400'; return; }

    const btnGuardar = $('rmApGuardar');
    btnGuardar.disabled = true;
    try {
        const payload = {
            nombre,
            rfc: $('rmApRfc').value.trim().toUpperCase() || null,
            razon_social: nombre,
            regimen_fiscal: $('rmApRegimen').value.trim() || null,
            uso_cfdi: $('rmApUso').value.trim() || null,
            condicion_pago: $('rmApCondicion').value || 'contado',
            dias_credito: 0,
            forma_pago: $('rmApForma').value.trim() || null,
            metodo_pago: $('rmApMetodo').value.trim() || null,
            moneda: $('rmApMoneda').value.trim().toUpperCase() || 'MXN',
            cp: $('rmApCp').value.trim() || null,
            cuenta_gasto_id: $('rmApCuenta').value ? Number($('rmApCuenta').value) : null,
            activo: true,
        };
        const { data, error } = await supabaseClient.from('proveedores').insert([payload]).select('id').single();
        if (error) throw error;

        rmXmlMeta.proveedorId = data.id;
        const elRfc = document.getElementById('rmRfc');
        if (elRfc && payload.rfc) elRfc.value = payload.rfc;

        // Refresca los catálogos de proveedores que ya están cargados en este módulo.
        try {
            const { data: pv } = await supabaseClient.from('proveedores').select('id, nombre').order('nombre');
            ocProveedores = pv || [];
            rmRecProveedores = pv || [];
            const selRecProv = document.getElementById('rmRecProveedor');
            if (selRecProv) selRecProv.innerHTML = '<option value="">Todos</option>' + rmRecProveedores.map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
        } catch (_) { /* no crítico */ }

        document.getElementById('rmAltaProvForm').innerHTML = `<p class="mt-1 text-[11px] text-emerald-400">✔ Proveedor "${esc(nombre)}" dado de alta y vinculado a esta recepción.</p>`;
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-[11px] text-rose-400';
        btnGuardar.disabled = false;
    }
}

// ---- Leer QR del CFDI (foto o captura de pantalla) ----
async function rmProcesarQr(file) {
    const info = document.getElementById('rmImportInfo');
    if (!('BarcodeDetector' in window)) {
        alert('Este navegador no puede leer códigos QR. Usa "Importar XML", o abre el sistema en Chrome / Edge.');
        return;
    }
    try {
        const bitmap = await createImageBitmap(file);
        const detector = new window.BarcodeDetector({ formats: ['qr_code'] });
        const codes = await detector.detect(bitmap);
        if (!codes || !codes.length) { alert('No se detectó ningún QR en la imagen.'); return; }
        const raw = codes[0].rawValue || '';

        let uuid = '', rfc = '', total = '';
        try {
            const u = new URL(raw);
            uuid = u.searchParams.get('id') || u.searchParams.get('Id') || '';
            rfc = u.searchParams.get('re') || '';
            total = u.searchParams.get('tt') || '';
        } catch (_) {
            const m = raw.match(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/);
            if (m) uuid = m[0];
        }
        if (!uuid && !rfc) { alert('El QR no parece de un CFDI (no trae UUID ni RFC).'); return; }

        const elUuid = document.getElementById('rmUuid'); if (elUuid && uuid) elUuid.value = uuid;
        const elRfc = document.getElementById('rmRfc'); if (elRfc && rfc) elRfc.value = rfc;
        if (info) {
            info.innerHTML = `🔳 QR leído · UUID ${esc(uuid || '—')} · RFC ${esc(rfc || '—')}${total ? ` · Total del CFDI $${esc(total)}` : ''}`
                + `<br><span class="text-[10px] text-slate-500">El QR no trae las partidas ni el desglose de impuestos: captura Subtotal / IVA a mano o usa el XML.</span>`;
        }
    } catch (e) {
        alert('No se pudo leer el QR: ' + (e.message || e));
    }
}
