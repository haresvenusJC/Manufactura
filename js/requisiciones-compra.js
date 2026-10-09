import { supabaseClient } from './supabase.js';
import { siguienteFolio } from './folios.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { imprimirConPlantilla, marcaDeEstatus } from './impresion.js';
import { obtenerInfoProveedorProducto } from './info-proveedor-producto.js';
import './trazabilidad.js';

// =====================================================================
//  Requisiciones de compra — paso previo a la Orden de compra. Se capturan
//  a mano o llegan solas desde Tareas ("Inventario bajo mínimo"); el admin
//  las autoriza (se convierte en Orden de compra real vía la función
//  requisicion_autorizar) o las rechaza (requisicion_rechazar). No mueve
//  inventario ni contabilidad por sí misma — de eso se encarga la OC que
//  resulta de autorizarla.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
// Hoy + N días hábiles (lunes a viernes), en hora local — para "Fecha esperada" al autorizar.
function fechaHabilesDesdeHoy(n) {
    const d = new Date();
    let faltan = n;
    while (faltan > 0) {
        d.setDate(d.getDate() + 1);
        if (d.getDay() !== 0 && d.getDay() !== 6) faltan--;
    }
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

let reqProveedores = [];
let reqUnidades = [];
let reqMonedas = [];
let reqProductos = [];
let reqPartidasTemp = [];
let reqProdSel = null;
let reqFiltro = 'pendiente';
// Orden de producción de la que salió la requisición ({ id, folio }), vía window.__reqPreOrden
// ("Faltantes para producir"). Se guarda en requisiciones_compra.orden_produccion_id.
let reqOrdenProd = null;
// Pedido de venta cuyo faltante cubre la requisición ({ id, folio }), vía window.__reqPrePedido. Se guarda en requisiciones_compra.pedido_venta_id.
let reqPedido = null;
const reqListaOrden = crearOrdenTabla('id', 'desc');

const REQ_FILTROS = [
    { v: 'pendiente', t: 'Pendientes' },
    { v: 'autorizada', t: 'Autorizadas' },
    { v: 'rechazada', t: 'Rechazadas' },
    { v: 'cancelada', t: 'Canceladas' },
    { v: 'todas', t: 'Todas' },
];

const REQ_ESTATUS = {
    pendiente: 'text-amber-300 bg-amber-950/40',
    autorizada: 'text-emerald-300 bg-emerald-950/40',
    rechazada: 'text-rose-300 bg-rose-950/40',
    cancelada: 'text-slate-400 bg-slate-800',
};

async function reqCargarCatalogos() {
    const [pv, um, mo] = await Promise.all([
        supabaseClient.from('proveedores').select('id, nombre').order('nombre'),
        supabaseClient.from('unidades_medida').select('id, nombre').order('nombre'),
        supabaseClient.from('monedas').select('id, codigo').order('id'),
    ]);
    reqProveedores = pv.data || [];
    reqUnidades = um.data || [];
    reqMonedas = mo.data || [];

    const pr = await supabaseClient.from('productos')
        .select('id, nombre, sku, costo_unitario, unidad_medida_id, proveedor_id, cantidad_minima_compra').order('nombre');
    reqProductos = pr.data || [];
}

// MOQ (cantidad mínima de compra) vigente del producto, 0 si no está capturado.
function reqMoqDe(productoId) {
    const p = productoId ? reqProductos.find((x) => x.id === Number(productoId)) : null;
    const m = Number(p && p.cantidad_minima_compra);
    return m > 0 ? m : 0;
}

// Aviso de MOQ de una partida (se repinta solo en .req-moq, sin tocar los demás campos).
function reqHtmlMoq(p, i) {
    if (!p.productoId) return '';
    const moq = reqMoqDe(p.productoId);
    const u = esc(p.unidadNombre || '');
    const cant = Number(p.cantidad || 0);
    if (!moq) {
        return `<div class="mt-1 text-[10px] text-amber-300">⚠ Sin MOQ capturado — el proveedor tal vez no venda solo lo que pide la orden.
            <span class="block mt-1"><input type="number" step="any" min="0" placeholder="MOQ (${u})" class="req-part-moq w-24 bg-slate-900 border border-slate-700 rounded px-1 py-0.5 text-right font-mono text-slate-100">
            <button type="button" onclick="window.reqGuardarMoq(${i})" class="ml-1 bg-sky-800 hover:bg-sky-700 text-white rounded px-2 py-0.5 cursor-pointer">Guardar MOQ</button></span></div>`;
    }
    const necesita = p.necesario != null && p.necesario < moq ? ` La orden necesita ${formatoNum(p.necesario)} ${u}.` : '';
    if (cant < moq) {
        return `<div class="mt-1 text-[10px] text-amber-300">⚠ MOQ ${formatoNum(moq)} ${u}: pides ${formatoNum(cant)}.${necesita}
            <button type="button" onclick="window.reqPedirMoq(${i})" class="ml-1 bg-amber-800 hover:bg-amber-700 text-white rounded px-2 py-0.5 cursor-pointer">Pedir ${formatoNum(moq)}</button></div>`;
    }
    const sobra = Number((cant - (p.necesario != null ? p.necesario : cant)).toFixed(4));
    return `<div class="mt-1 text-[10px] text-emerald-400">✓ MOQ ${formatoNum(moq)} ${u}${necesita && sobra > 0 ? ` —${necesita} Sobran ${formatoNum(sobra)} ${u} (quedan en stock).` : ''}</div>`;
}
const formatoNum = (n) => Number(Number(n).toFixed(4)).toLocaleString('es-MX', { maximumFractionDigits: 4 });

window.reqPedirMoq = (i) => {
    const p = reqPartidasTemp[i];
    if (!p) return;
    if (p.necesario == null) p.necesario = p.cantidad;
    p.cantidad = reqMoqDe(p.productoId);
    reqRenderPartidas();
};

// Captura el MOQ ahí mismo (productos.cantidad_minima_compra) y sigue con la requisición.
window.reqGuardarMoq = async (i) => {
    const p = reqPartidasTemp[i];
    const tr = document.querySelector(`#reqPartidasBody tr[data-idx="${i}"]`);
    const inp = tr && tr.querySelector('.req-part-moq');
    const moq = inp ? parseFloat(inp.value) : NaN;
    if (!p || !p.productoId || !(moq > 0)) { alert('Escribe un MOQ mayor a 0.'); return; }
    const { error } = await supabaseClient.from('productos').update({ cantidad_minima_compra: moq }).eq('id', p.productoId);
    if (error) { alert('No se pudo guardar el MOQ: ' + error.message); return; }
    const prod = reqProductos.find((x) => x.id === Number(p.productoId));
    if (prod) prod.cantidad_minima_compra = moq;
    // Otras partidas del mismo producto quedan cubiertas por el mismo MOQ.
    reqPartidasTemp.forEach((q) => {
        if (q.productoId === p.productoId && Number(q.cantidad || 0) < moq) {
            if (q.necesario == null) q.necesario = q.cantidad;
            q.cantidad = moq;
        }
    });
    reqRenderPartidas();
};

export async function cargarModuloRequisicionesCompra() {
    const cont = document.getElementById('contenedorRequisicionesCompra');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try { await reqCargarCatalogos(); }
    catch (e) { cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`; return; }

    reqPartidasTemp = [];
    reqProdSel = null;

    const optProv = '<option value="">Proveedor sugerido...</option>' + reqProveedores.map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
    const optUni = '<option value="">Unidad...</option>' + reqUnidades.map(u => `<option value="${u.id}">${esc(u.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Nueva requisición de compra</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:flex lg:flex-wrap gap-3 mb-3">
          <div class="lg:w-52"><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="reqFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="lg:flex-1 lg:min-w-[240px]"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="reqNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>

        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-5 lg:flex lg:flex-wrap lg:items-end gap-2">
            <div class="col-span-2 lg:flex-1 lg:min-w-[260px] relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="reqProdInput" autocomplete="off" placeholder="Buscar o escribir uno nuevo..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="reqProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div class="lg:w-28"><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="reqProdCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div class="lg:w-44"><label class="block text-[11px] text-slate-400 mb-1">Unidad</label>
              <select id="reqProdUnidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optUni}</select></div>
            <div class="lg:w-56"><label class="block text-[11px] text-slate-400 mb-1">Proveedor sugerido</label>
              <select id="reqProdProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optProv}</select></div>
          </div>
          <div id="reqInfoProveedor" class="hidden mt-2 text-[11px] text-slate-300 bg-slate-900 border border-slate-800 rounded-lg px-2.5 py-2"></div>
          <button type="button" id="reqAddPartida" class="mt-2 w-full lg:w-auto lg:px-6 bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
        </div>

        <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Mi catálogo (interno)</th><th class="p-2 text-right">Cantidad</th>
              <th class="p-2">Datos del proveedor (para la OC)</th>
              <th class="p-2 text-right">Costo est.</th><th class="p-2 text-right">Importe</th><th class="p-2"></th>
            </tr></thead>
            <tbody id="reqPartidasBody"><tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr></tbody>
          </table>
        </div>
        <button type="button" id="reqGuardar" class="w-full lg:w-auto lg:px-10 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar requisición</button>
        <p id="reqMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Requisiciones de compra</h3>
        <div id="reqFiltros" class="flex flex-wrap gap-2 mb-2"></div>
        <div id="reqLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('reqFecha').value = hoyISO();

    reqWireFormulario();
    await reqAplicarPreseleccion();
    reqPintarFiltros();
    await reqRenderLista();
    montarGuia(cont, 'requisiciones-compra');
}

// Preselección al entrar desde Tareas ("📝 Generar requisición" en
// Contabilidad · Tareas):
//   · window.__reqPreProducto = { id, cantidad } — una sola partida (legado).
//   · window.__reqPreProductos = [{ id, cantidad }, ...] — varias tareas
//     seleccionadas del MISMO proveedor, agregadas de una vez como partidas.
//   · window.__reqPreGruposRestantes = [[{id,cantidad}, ...], ...] — cuando
//     las tareas seleccionadas eran de proveedores distintos, el resto de
//     los grupos quedan aquí; reqCargarSiguienteGrupoPendiente() los va
//     metiendo uno a uno después de guardar cada requisición (una
//     requisición es siempre de un solo proveedor).
async function reqAplicarPreseleccion() {
    const preMulti = window.__reqPreProductos;
    const pre = window.__reqPreProducto;
    window.__reqPreProductos = null;
    window.__reqPreProducto = null;
    // Se entró sin preselección (a mano, desde el menú): un "siguiente paso" viejo ya no aplica.
    const conPre = (Array.isArray(preMulti) && preMulti.length) || (pre && pre.id);
    if (!conPre) window.__faltantesSiguiente = null;
    // Liga a la orden de producción: se conserva mientras queden grupos de otros proveedores por cargar.
    reqOrdenProd = conPre && window.__reqPreOrden && window.__reqPreOrden.id ? window.__reqPreOrden : null;
    if (!conPre || !Array.isArray(window.__reqPreGruposRestantes) || !window.__reqPreGruposRestantes.length) window.__reqPreOrden = null;
    reqPedido = conPre && window.__reqPrePedido && window.__reqPrePedido.id ? window.__reqPrePedido : null;
    if (!conPre || !Array.isArray(window.__reqPreGruposRestantes) || !window.__reqPreGruposRestantes.length) window.__reqPrePedido = null;

    // Nota con la que llega la preselección (p. ej. desde Producción: "Faltantes para producir…").
    // Se conserva mientras queden grupos de otros proveedores por cargar.
    const notasPre = window.__reqPreNotas;
    if (!Array.isArray(window.__reqPreGruposRestantes) || !window.__reqPreGruposRestantes.length) window.__reqPreNotas = null;

    if (Array.isArray(preMulti) && preMulti.length) {
        for (const item of preMulti) {
            const p = reqProductos.find((x) => x.id === Number(item.id));
            if (!p || !(item.cantidad > 0)) continue;
            // Con MOQ capturado, lo que pide la orden se sube al MOQ (no se compra menos de lo que el proveedor vende);
            // `necesario` conserva lo que pidió la orden para el aviso y el sobrante.
            const moq = reqMoqDe(p.id);
            const sube = moq > 0 && item.cantidad < moq;
            await reqAgregarPartida({ productoId: p.id, nombre: p.nombre, cantidad: sube ? moq : item.cantidad, unidadId: p.unidad_medida_id || null, proveedorId: p.proveedor_id || null, tareaId: item.tareaId || null, necesario: item.cantidad });
        }
        reqRenderPartidas();
        document.getElementById('reqNotas').value = notasPre || 'Generada desde Tareas: inventario bajo mínimo (agrupada por proveedor).';
        reqAvisarGruposRestantes();
        return;
    }

    if (!pre || !pre.id) return;
    const p = reqProductos.find((x) => x.id === Number(pre.id));
    if (!p) return;
    await reqAgregarPartida({ productoId: p.id, nombre: p.nombre, cantidad: pre.cantidad > 0 ? pre.cantidad : 1, unidadId: p.unidad_medida_id || null, proveedorId: p.proveedor_id || null, tareaId: pre.tareaId || null });
    reqRenderPartidas();
    document.getElementById('reqNotas').value = 'Generada desde Tareas: inventario bajo mínimo.';
}

function reqAvisarGruposRestantes() {
    const restantes = window.__reqPreGruposRestantes;
    const msg = document.getElementById('reqMsg');
    if (!msg) return;
    const partes = [];
    if (reqOrdenProd) partes.push(`Ligada a la orden de producción ${reqOrdenProd.folio || '#' + reqOrdenProd.id}.`);
    if (reqPedido) partes.push(`Ligada al pedido de venta ${reqPedido.folio || '#' + reqPedido.id}.`);
    if (Array.isArray(restantes) && restantes.length) {
        partes.push(`Guarda esta requisición y se va a abrir la del siguiente proveedor automáticamente (quedan ${restantes.length}).`);
    }
    const sig = window.__faltantesSiguiente;
    if (sig && sig.prodPre) {
        partes.push(`Después de esta(s) requisición(es) sigue: órdenes de producción (${sig.prodPre.total}).`);
    }
    if (partes.length) {
        msg.textContent = partes.join(' ');
        msg.className = 'text-xs mt-2 text-sky-400';
    }
}

// Venía de "Faltantes para producir" (Producción) con cosas que también se fabrican en casa:
// al guardar la última requisición, ofrece seguir con esas órdenes de producción.
function reqOfrecerSiguientePaso(msg, textoGuardado) {
    const sig = window.__faltantesSiguiente;
    if (!sig || !sig.prodPre) return false;
    msg.innerHTML = `${esc(textoGuardado)}
        <button type="button" id="reqBtnContinuarProd" class="block mt-2 text-xs bg-amber-700 hover:bg-amber-600 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">🏭 Continuar con las órdenes de producción (${sig.prodPre.total})</button>`;
    msg.className = 'text-xs mt-2 text-emerald-400';
    document.getElementById('reqBtnContinuarProd').addEventListener('click', () => {
        window.__prodPre = sig.prodPre;
        window.__faltantesSiguiente = null;
        window.loadView('produccion');
    });
    msg.scrollIntoView({ behavior: 'smooth', block: 'center' });
    return true;
}

// Después de guardar una requisición, si venían más grupos de proveedor
// pendientes (tareas seleccionadas de distintos proveedores), carga el
// siguiente como una nueva requisición en el mismo formulario.
async function reqCargarSiguienteGrupoPendiente() {
    const restantes = window.__reqPreGruposRestantes;
    if (!Array.isArray(restantes) || !restantes.length) return false;
    window.__reqPreProductos = restantes.shift();
    window.__reqPreGruposRestantes = restantes;
    await reqAplicarPreseleccion();
    return true;
}

function reqWireFormulario() {
    const inp = document.getElementById('reqProdInput');
    const sug = document.getElementById('reqProdSug');

    inp.addEventListener('input', () => {
        reqProdSel = null;
        reqActualizarInfoProveedor();
        const t = inp.value.toLowerCase().trim();
        if (!t) { sug.classList.add('hidden'); return; }
        const hits = reqProductos.filter(p =>
            (p.nombre && p.nombre.toLowerCase().includes(t)) || (p.sku && p.sku.toLowerCase().includes(t))
        ).slice(0, 12);
        if (!hits.length) { sug.classList.add('hidden'); return; }
        sug.innerHTML = hits.map(p => `
            <div class="px-3 py-2 text-xs text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer border-b border-slate-800/50 last:border-0 req-sug" data-id="${p.id}">
                ${esc(p.nombre)} <span class="text-[10px] text-slate-400">${p.sku ? 'SKU ' + esc(p.sku) : ''}</span>
            </div>`).join('');
        sug.classList.remove('hidden');
        sug.querySelectorAll('.req-sug').forEach(el => {
            el.onclick = () => {
                const p = reqProductos.find(x => x.id === Number(el.dataset.id));
                reqProdSel = p || null;
                inp.value = p ? p.nombre : inp.value;
                if (p && p.unidad_medida_id) document.getElementById('reqProdUnidad').value = p.unidad_medida_id;
                if (p && p.proveedor_id) document.getElementById('reqProdProveedor').value = p.proveedor_id;
                sug.classList.add('hidden');
                reqActualizarInfoProveedor();
            };
        });
    });
    document.addEventListener('click', (e) => {
        if (!inp.contains(e.target) && !sug.contains(e.target)) sug.classList.add('hidden');
    });
    document.getElementById('reqProdProveedor').addEventListener('change', reqActualizarInfoProveedor);

    document.getElementById('reqAddPartida').onclick = async () => {
        const nombre = inp.value.trim();
        const cantidad = parseFloat(document.getElementById('reqProdCant').value) || 0;
        const unidadId = document.getElementById('reqProdUnidad').value ? parseInt(document.getElementById('reqProdUnidad').value) : null;
        const proveedorId = document.getElementById('reqProdProveedor').value ? parseInt(document.getElementById('reqProdProveedor').value) : null;
        if (!nombre || cantidad <= 0) { alert('Indica el producto y una cantidad mayor a 0.'); return; }

        await reqAgregarPartida({ productoId: reqProdSel ? reqProdSel.id : null, nombre, cantidad, unidadId, proveedorId });
        reqRenderPartidas();
        inp.value = ''; document.getElementById('reqProdCant').value = '';
        document.getElementById('reqProdUnidad').value = ''; document.getElementById('reqProdProveedor').value = '';
        reqProdSel = null; inp.focus();
        reqActualizarInfoProveedor();
    };

    document.getElementById('reqGuardar').onclick = reqGuardarRequisicion;
}

// Agrega una partida a reqPartidasTemp (no repinta ni limpia el formulario —
// eso lo hace quien la llama). Compartida entre el botón "Agregar partida" y
// la preselección masiva desde Tareas (reqAplicarPreseleccion).
async function reqAgregarPartida({ productoId, nombre, cantidad, unidadId, proveedorId, tareaId = null, necesario = null }) {
    const prod = productoId ? reqProductos.find((x) => x.id === Number(productoId)) : null;
    const uNom = reqUnidades.find((u) => u.id === unidadId)?.nombre || '';
    const provNom = reqProveedores.find((p) => p.id === proveedorId)?.nombre || '';

    // Congela el SKU/descripción/unidad del proveedor al momento de
    // capturar (igual que el costo estimado) — así, al analizar la
    // requisición o al pasarla a Orden de compra, quedan lado a lado
    // tu SKU interno y el dato del proveedor, que es el que él entiende.
    let datosProveedor = { skuProveedor: null, descripcionProveedor: null, unidadProveedor: null, factorConversion: null };
    if (prod && proveedorId) {
        try {
            const info = await obtenerInfoProveedorProducto(prod.id, proveedorId);
            if (info) {
                datosProveedor = {
                    skuProveedor: info.claveProveedor,
                    descripcionProveedor: info.descripcionProveedor,
                    unidadProveedor: info.unidadProveedor,
                    factorConversion: info.factorConversion,
                };
            }
        } catch (_) { /* sin datos del proveedor: la partida se agrega igual */ }
    }

    reqPartidasTemp.push({
        productoId: prod ? prod.id : null,
        skuInterno: prod ? (prod.sku || '') : '',
        nombre,
        cantidad,
        necesario,
        costo: prod ? Number(prod.costo_unitario || 0) : 0,
        unidadId,
        unidadNombre: uNom,
        proveedorId,
        proveedorNombre: provNom,
        tareaId,
        ...datosProveedor,
    });
}

// Refleja, para el producto y proveedor elegidos en la fila de captura, cómo
// ESE proveedor identifica y vende el producto (su SKU, su descripción, su
// unidad) y el precio unitario de la última compra que se le hizo — la
// referencia para hablar con él en sus propios términos.
async function reqActualizarInfoProveedor() {
    const cont = document.getElementById('reqInfoProveedor');
    if (!cont) return;
    const proveedorId = document.getElementById('reqProdProveedor').value ? parseInt(document.getElementById('reqProdProveedor').value) : null;
    if (!reqProdSel || !proveedorId) { cont.classList.add('hidden'); cont.innerHTML = ''; return; }

    cont.classList.remove('hidden');
    cont.innerHTML = 'Buscando datos del proveedor...';
    try {
        const info = await obtenerInfoProveedorProducto(reqProdSel.id, proveedorId);
        if (!info || (!info.claveProveedor && !info.descripcionProveedor && !info.unidadProveedor && info.ultimoPrecio == null)) {
            cont.innerHTML = '<span class="text-slate-500 italic">Sin datos registrados de este proveedor para este producto — captúralos en Productos → "Claves de proveedor".</span>';
            return;
        }
        const partes = [];
        if (info.claveProveedor) partes.push(`<strong class="text-slate-200">SKU proveedor:</strong> <span class="font-mono">${esc(info.claveProveedor)}</span>`);
        if (info.descripcionProveedor) partes.push(`<strong class="text-slate-200">Descripción proveedor:</strong> ${esc(info.descripcionProveedor)}`);
        if (info.unidadProveedor) partes.push(`<strong class="text-slate-200">Unidad proveedor:</strong> ${esc(info.unidadProveedor)}${info.factorConversion ? ` (factor ${info.factorConversion})` : ''}`);
        if (info.ultimoPrecio != null) partes.push(`<strong class="text-slate-200">Última compra:</strong> ${money(info.ultimoPrecio)}${info.ultimaFecha ? ' (' + esc(info.ultimaFecha) + ')' : ''}`);
        cont.innerHTML = partes.join(' &nbsp;·&nbsp; ');
    } catch (err) {
        cont.innerHTML = `<span class="text-rose-400">Error al consultar datos del proveedor: ${esc(err.message || err)}</span>`;
    }
}

function reqRenderPartidas() {
    const b = document.getElementById('reqPartidasBody');
    if (!reqPartidasTemp.length) {
        b.innerHTML = '<tr><td colspan="6" class="p-3 text-center text-slate-500 italic">Sin partidas.</td></tr>';
        return;
    }
    b.innerHTML = reqPartidasTemp.map((p, i) => {
        const tieneDatosProv = p.skuProveedor || p.descripcionProveedor || p.unidadProveedor;
        const importe = Number(p.cantidad || 0) * Number(p.costo || 0);
        return `
        <tr class="border-b border-slate-900 align-top" data-idx="${i}">
            <td class="p-2 text-slate-100">
                ${esc(p.nombre)}${p.productoId ? '' : ' <span class="text-[10px] text-amber-400">(nuevo)</span>'}
                ${p.skuInterno ? `<span class="block text-[10px] text-slate-500 font-mono">SKU ${esc(p.skuInterno)}</span>` : ''}
                <div class="req-moq">${reqHtmlMoq(p, i)}</div>
            </td>
            <td class="p-2 text-right">
                <input type="number" step="any" min="0" class="req-part-cant w-20 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-right font-mono text-slate-100" value="${p.cantidad}">
                <span class="block text-[10px] text-slate-500 font-normal">${esc(p.unidadNombre || '')}</span>
            </td>
            <td class="p-2 text-slate-400 text-[11px]">
                ${p.proveedorNombre ? `<span class="text-slate-300">${esc(p.proveedorNombre)}</span>` : '<span class="italic text-slate-600">sin proveedor sugerido</span>'}
                ${tieneDatosProv ? `<span class="block">${p.skuProveedor ? `SKU proveedor: <span class="font-mono">${esc(p.skuProveedor)}</span>` : ''}</span>
                    ${p.descripcionProveedor ? `<span class="block">"${esc(p.descripcionProveedor)}"</span>` : ''}
                    ${p.unidadProveedor ? `<span class="block">Unidad: ${esc(p.unidadProveedor)}${p.factorConversion ? ` (×${p.factorConversion})` : ''}</span>` : ''}`
                    : (p.proveedorNombre ? '<span class="block italic text-slate-600">sin claves capturadas para este proveedor</span>' : '')}
            </td>
            <td class="p-2 text-right"><input type="number" step="any" min="0" class="req-part-costo w-24 bg-slate-900 border border-slate-800 rounded px-2 py-1 text-right font-mono text-slate-100" value="${Number(p.costo || 0)}"></td>
            <td class="p-2 text-right font-mono req-part-importe">${money(importe)}</td>
            <td class="p-2 text-right"><button type="button" onclick="window.reqQuitarPartida(${i})" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button></td>
        </tr>`;
    }).join('');

    b.querySelectorAll('tr[data-idx]').forEach((tr) => {
        const i = Number(tr.dataset.idx);
        const cantInp = tr.querySelector('.req-part-cant');
        const costoInp = tr.querySelector('.req-part-costo');
        const importeCelda = tr.querySelector('.req-part-importe');
        const actualizarImporte = () => {
            const c = parseFloat(cantInp.value) || 0;
            const co = parseFloat(costoInp.value) || 0;
            importeCelda.textContent = money(c * co);
        };
        cantInp.addEventListener('input', actualizarImporte);
        costoInp.addEventListener('input', actualizarImporte);
        cantInp.addEventListener('change', () => {
            reqPartidasTemp[i].cantidad = parseFloat(cantInp.value) || 0;
            const caja = tr.querySelector('.req-moq');
            if (caja) caja.innerHTML = reqHtmlMoq(reqPartidasTemp[i], i);
        });
        costoInp.addEventListener('change', () => { reqPartidasTemp[i].costo = parseFloat(costoInp.value) || 0; });
    });
}
window.reqQuitarPartida = (i) => { reqPartidasTemp.splice(i, 1); reqRenderPartidas(); };

async function reqGuardarRequisicion() {
    const msg = document.getElementById('reqMsg');
    msg.textContent = ''; msg.className = 'text-xs mt-2 min-h-[1rem]';
    if (!reqPartidasTemp.length) { msg.textContent = 'Agrega al menos una partida.'; msg.className = 'text-xs mt-2 text-rose-400'; return; }

    const btn = document.getElementById('reqGuardar');
    btn.disabled = true;
    try {
        const notas = document.getElementById('reqNotas').value.trim();
        const folio = await siguienteFolio('REQ');   // consecutivo: REQ-000001, REQ-000002...
        const origen = notas.startsWith('Generada desde Tareas') ? 'stock_bajo_minimo' : 'manual';
        const filaReq = {
            folio,
            fecha: document.getElementById('reqFecha').value || hoyISO(),
            origen,
            estatus: 'pendiente',
            notas: notas || null,
        };
        if (reqOrdenProd) filaReq.orden_produccion_id = reqOrdenProd.id;
        if (reqPedido) filaReq.pedido_venta_id = reqPedido.id;
        let { data: req, error: e1 } = await supabaseClient.from('requisiciones_compra').insert([filaReq]).select('id, folio').single();
        if (e1 && reqOrdenProd && TABLA_FALTA.test(e1.message || '')) {
            // aún sin sql/2026-09-22_requisicion_orden_produccion.sql: se guarda sin la liga.
            delete filaReq.orden_produccion_id;
            ({ data: req, error: e1 } = await supabaseClient.from('requisiciones_compra').insert([filaReq]).select('id, folio').single());
        }
        if (e1 && reqPedido && /pedido_venta_id/i.test(e1.message || '')) {
            // aún sin sql/2026-11-04_pedido_venta_cobertura.sql: se guarda sin la liga al pedido.
            delete filaReq.pedido_venta_id;
            ({ data: req, error: e1 } = await supabaseClient.from('requisiciones_compra').insert([filaReq]).select('id, folio').single());
        }
        if (e1) throw e1;

        const filas = reqPartidasTemp.map(p => ({
            requisicion_id: req.id,
            producto_id: p.productoId,
            descripcion: p.productoId ? null : p.nombre,
            cantidad: p.cantidad,
            unidad_medida_id: p.unidadId,
            proveedor_sugerido_id: p.proveedorId,
            costo_estimado: p.costo,
            sku_proveedor: p.skuProveedor || null,
            descripcion_proveedor: p.descripcionProveedor || null,
            unidad_proveedor: p.unidadProveedor || null,
            factor_conversion_proveedor: p.factorConversion ?? null,
        }));
        let { error: e2 } = await supabaseClient.from('requisiciones_compra_detalle').insert(filas);
        if (e2 && /does not exist|schema cache|could not find/i.test(e2.message || '')) {
            // columnas de datos del proveedor aún no existen: reintenta sin ellas.
            const filasSinProveedor = filas.map(({ sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor, ...resto }) => resto);
            ({ error: e2 } = await supabaseClient.from('requisiciones_compra_detalle').insert(filasSinProveedor));
        }
        if (e2) throw e2;

        // Las tareas de "inventario bajo mínimo" que originaron estas
        // partidas (ver tareas.js) se marcan Atendidas solas — ya se generó
        // la requisición, no hace falta que el admin también le dé "✔
        // Atendida" a mano en Tareas. Mejor esfuerzo: si falla, la
        // requisición ya quedó guardada de todas formas.
        const tareaIds = [...new Set(reqPartidasTemp.map((p) => p.tareaId).filter(Boolean))];
        for (const tareaId of tareaIds) {
            try {
                await supabaseClient.rpc('tarea_resolver', { p_id: tareaId, p_accion: 'atender', p_nota: `Requisición ${req.folio} generada`, p_dias: null });
            } catch (_) { /* no bloquea el guardado de la requisición */ }
        }

        reqPartidasTemp = [];
        reqRenderPartidas();
        document.getElementById('reqNotas').value = '';
        reqFiltro = 'pendiente';
        reqPintarFiltros();
        await reqRenderLista();

        const siguiente = await reqCargarSiguienteGrupoPendiente();
        if (!siguiente) {
            reqOrdenProd = null;
            reqPedido = null;
            const texto = `Requisición ${req.folio} guardada, pendiente de autorización.`;
            if (!reqOfrecerSiguientePaso(msg, texto)) {
                msg.textContent = texto;
                msg.className = 'text-xs mt-2 text-emerald-400';
            }
        } else {
            msg.textContent = `Requisición ${req.folio} guardada. Cargué la del siguiente proveedor — revisa y guarda esta también.`;
            msg.className = 'text-xs mt-2 text-emerald-400';
            document.getElementById('reqPartidasBody')?.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    } catch (err) {
        const m = err?.message || String(err);
        msg.textContent = TABLA_FALTA.test(m)
            ? 'Falta correr sql/2026-09-29_requisiciones_compra.sql en Supabase.'
            : 'No se pudo guardar: ' + m;
        msg.className = 'text-xs mt-2 text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

function reqPintarFiltros() {
    const cont = document.getElementById('reqFiltros');
    if (!cont) return;
    cont.innerHTML = REQ_FILTROS.map(f => {
        const on = f.v === reqFiltro;
        return `<button type="button" class="req-filtro-btn text-xs px-3 py-1.5 rounded-lg border transition ${on ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300 hover:bg-slate-800'}" data-filtro="${f.v}">${f.t}</button>`;
    }).join('');
    cont.querySelectorAll('.req-filtro-btn').forEach(b => {
        b.onclick = () => { reqFiltro = b.dataset.filtro; reqPintarFiltros(); reqRenderLista(); };
    });
}

async function reqRenderLista() {
    const cont = document.getElementById('reqLista');
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        let q = supabaseClient
            .from('requisiciones_compra')
            .select('id, folio, fecha, estatus, origen, notas, revisada_por, revisada_en, motivo_rechazo, orden_compra_id, ordenes_compra ( folio, estatus ), requisiciones_compra_detalle ( cantidad, costo_estimado, productos ( nombre ) )')
            .order('id', { ascending: false })
            .limit(200);
        if (reqFiltro !== 'todas') q = q.eq('estatus', reqFiltro);
        const { data, error } = await q;
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">Sin requisiciones en "${REQ_FILTROS.find(f => f.v === reqFiltro)?.t.toLowerCase()}".</p>`; return; }

        data.forEach(r => {
            const det = r.requisiciones_compra_detalle || [];
            r._total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.costo_estimado || 0), 0);
            r._resumen = det.map(d => d.productos?.nombre || '(sin producto)').join(', ');
        });
        aplicarOrden(reqListaOrden, data, (r, campo) => {
            switch (campo) {
                case 'folio': return (r.folio || String(r.id)).toLowerCase();
                case 'fecha': return r.fecha || '';
                case 'total': return r._total;
                case 'estatus': return r.estatus || '';
                default: return r.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(reqListaOrden, 'folio', 'Folio')}<th class="p-2">Partidas</th>${thOrden(reqListaOrden, 'fecha', 'Fecha')}
              ${thOrden(reqListaOrden, 'total', 'Total est.', 'text-right justify-end')}${thOrden(reqListaOrden, 'estatus', 'Estatus')}<th class="p-2">Origen</th>
            </tr></thead>
            <tbody>
              ${data.map(r => `
                    <tr class="border-b border-slate-900">
                      <td class="p-2 whitespace-nowrap">
                        ${r.estatus === 'pendiente' ? `
                            <button type="button" onclick="window.reqAutorizar(${r.id})" class="text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded">Autorizar</button>
                            <button type="button" onclick="window.reqEditar(${r.id})" class="text-[11px] bg-sky-800 hover:bg-sky-700 text-sky-200 border border-sky-700 px-2 py-1 rounded ml-1">✏ Editar</button>
                            <button type="button" onclick="window.reqRechazar(${r.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded ml-1">Rechazar</button>
                            <button type="button" onclick="window.reqCancelar(${r.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-amber-300 border border-slate-700 px-2 py-1 rounded ml-1">Cancelar</button>
                        ` : (r.orden_compra_id ? `
                            <button type="button" onclick="window.verDetalleOC(${r.orden_compra_id})" class="text-[11px] font-mono text-emerald-300 hover:underline">OC ${esc(r.ordenes_compra?.folio || '#' + r.orden_compra_id)}</button>
                            <button type="button" onclick="window.abrirAntecedentesOC(${r.orden_compra_id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded ml-1">🔗 Antecedentes</button>
                            ${r.estatus === 'autorizada' && r.ordenes_compra?.estatus === 'cancelada' ? `<button type="button" onclick="window.reqSincronizarCancelacion(${r.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-amber-300 border border-slate-700 px-2 py-1 rounded ml-1" title="La orden de compra de esta requisición ya está cancelada">⚠ Marcar cancelada</button>` : ''}
                        ` : '')}
                      </td>
                      <td class="p-2"><button type="button" onclick="window.abrirDetalleReq(${r.id})" class="font-mono text-emerald-300 hover:underline hover:text-emerald-200 text-left">${esc(r.folio || '#' + r.id)}</button></td>
                      <td class="p-2 text-slate-300 max-w-xs truncate" title="${esc(r._resumen)}">${esc(r._resumen) || '—'}</td>
                      <td class="p-2 whitespace-nowrap text-slate-400">${r.fecha || ''}</td>
                      <td class="p-2 text-right font-mono">${money(r._total)}</td>
                      <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${REQ_ESTATUS[r.estatus] || 'text-slate-400 bg-slate-800'}">${esc(r.estatus)}</span></td>
                      <td class="p-2 text-slate-500 text-[11px]">${r.origen === 'stock_bajo_minimo' ? 'Stock bajo mínimo' : 'Manual'}</td>
                    </tr>
                    ${(r.estatus === 'rechazada' || r.estatus === 'cancelada') && r.motivo_rechazo ? `<tr class="border-b border-slate-900"><td></td><td colspan="6" class="p-2 pt-0 text-[11px] ${r.estatus === 'cancelada' ? 'text-amber-400/80' : 'text-rose-400/80'}">Motivo: ${esc(r.motivo_rechazo)}</td></tr>` : ''}
              `).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, reqListaOrden, reqRenderLista);
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = TABLA_FALTA.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-29_requisiciones_compra.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
    }
}

// ---- Detalle / versión imprimible de una requisición ----
async function abrirDetalleReq(id) {
    const idModal = window.idSubventana('modalDetalleReq');
    if (idModal === 'modalDetalleReq') document.getElementById('modalDetalleReq')?.remove();

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '42rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Requisición <span id="tituloDetalleReqSub" class="text-emerald-300 font-mono"></span></h3>
            <div class="flex items-center gap-2">
                <button id="btnImprimirReq" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 px-3 py-1.5 rounded-lg">🖨️ Imprimir</button>
                <button id="cerrarDetalleReq" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
            </div>
        </div>
        <div id="cuerpoDetalleReq" class="p-4 overflow-y-auto flex-1">
            <p class="text-slate-500 text-sm text-center">Cargando...</p>
        </div>`;
    document.body.appendChild(modal);
    // id único del cuerpo por instancia — imprimirConPlantilla busca por id global
    // (document.getElementById), no escopado a este modal.
    const idCuerpo = idModal === 'modalDetalleReq' ? 'cuerpoDetalleReq' : `cuerpoDetalleReq__${idModal}`;
    modal.querySelector('#cuerpoDetalleReq').id = idCuerpo;

    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('#cerrarDetalleReq').onclick = cerrar;
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    try {
        let { data: r, error } = await supabaseClient
            .from('requisiciones_compra')
            .select(`id, folio, fecha, estatus, origen, notas, revisada_por, revisada_en, motivo_rechazo, orden_compra_id,
                ordenes_compra ( folio ),
                requisiciones_compra_detalle ( id, producto_id, descripcion, cantidad, costo_estimado,
                    sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor,
                    productos ( nombre, sku ), unidades_medida ( nombre ), proveedores ( nombre ) )`)
            .eq('id', id).single();
        if (error && /does not exist|schema cache|could not find/i.test(error.message || '')) {
            // columnas de datos del proveedor aún no existen: cae al select sin ellas.
            ({ data: r, error } = await supabaseClient
                .from('requisiciones_compra')
                .select(`id, folio, fecha, estatus, origen, notas, revisada_por, revisada_en, motivo_rechazo, orden_compra_id,
                    ordenes_compra ( folio ),
                    requisiciones_compra_detalle ( id, producto_id, descripcion, cantidad, costo_estimado,
                        productos ( nombre, sku ), unidades_medida ( nombre ), proveedores ( nombre ) )`)
                .eq('id', id).single());
        }
        if (error) throw error;

        modal.querySelector('#tituloDetalleReqSub').textContent = r.folio || ('#' + r.id);
        modal.querySelector('#btnImprimirReq').onclick = () => imprimirConPlantilla('requisicion_compra', 'Requisición ' + (r.folio || '#' + r.id), idCuerpo, marcaDeEstatus(r.estatus));

        const cuerpo = modal.querySelector('#' + idCuerpo);
        const det = r.requisiciones_compra_detalle || [];
        const total = det.reduce((a, d) => a + Number(d.cantidad || 0) * Number(d.costo_estimado || 0), 0);
        const fmtFecha = (iso) => { try { return new Date(iso).toLocaleString('es-MX', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }); } catch (e) { return iso || '—'; } };

        const bloqueRevision = r.estatus === 'autorizada'
            ? `<div class="mb-4"><span class="block text-[10px] text-slate-500 mb-1">Autorizada</span>
                 <p class="text-xs text-slate-300">Se generó la <button type="button" onclick="window.verDetalleOC(${r.orden_compra_id})" class="text-emerald-300 hover:underline font-mono">Orden de compra ${esc(r.ordenes_compra?.folio || '#' + r.orden_compra_id)}</button>${r.revisada_por ? ' · autorizó ' + esc(r.revisada_por) : ''}${r.revisada_en ? ' · ' + fmtFecha(r.revisada_en) : ''}.</p></div>`
            : r.estatus === 'rechazada'
                ? `<div class="mb-4"><span class="block text-[10px] text-slate-500 mb-1">Rechazada</span>
                     <p class="text-xs text-rose-400">${esc(r.motivo_rechazo || 'Sin motivo registrado.')}${r.revisada_por ? ' · ' + esc(r.revisada_por) : ''}${r.revisada_en ? ' · ' + fmtFecha(r.revisada_en) : ''}</p></div>`
                : '';

        cuerpo.innerHTML = `
            <div class="grid grid-cols-2 gap-3 mb-4 text-sm">
                <div><span class="block text-[10px] text-slate-500">Fecha</span><span class="text-slate-300">${r.fecha || '—'}</span></div>
                <div><span class="block text-[10px] text-slate-500">Estatus</span><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${REQ_ESTATUS[r.estatus] || 'text-slate-400 bg-slate-800'}">${esc(r.estatus)}</span></div>
                <div><span class="block text-[10px] text-slate-500">Origen</span><span class="text-slate-300">${r.origen === 'stock_bajo_minimo' ? 'Stock bajo mínimo' : 'Manual'}</span></div>
            </div>
            ${r.notas ? `<div class="mb-4"><span class="block text-[10px] text-slate-500 mb-1">Notas</span><p class="text-xs text-slate-300 bg-slate-800 border border-slate-700 rounded-lg px-2 py-1.5">${esc(r.notas)}</p></div>` : ''}
            ${bloqueRevision}
            <div class="overflow-x-auto border border-slate-800 rounded-lg mb-4">
              <table class="w-full text-left text-xs text-slate-300">
                <thead class="bg-slate-950 text-slate-500 uppercase"><tr>
                  <th class="p-2">Mi catálogo (interno)</th><th class="p-2 text-right">Cantidad</th>
                  <th class="p-2">Datos del proveedor (para la OC)</th>
                  <th class="p-2 text-right">Costo est.</th><th class="p-2 text-right">Importe</th>
                </tr></thead>
                <tbody>
                  ${det.map(d => {
                      const tieneDatosProv = d.sku_proveedor || d.descripcion_proveedor || d.unidad_proveedor;
                      return `
                    <tr class="border-b border-slate-900 align-top">
                      <td class="p-2">${esc(d.productos?.nombre || d.descripcion || '—')}${d.productos?.sku ? `<span class="block text-[10px] text-slate-500">SKU ${esc(d.productos.sku)}</span>` : ''}</td>
                      <td class="p-2 text-right font-mono">${Number(d.cantidad || 0).toLocaleString('es-MX', { maximumFractionDigits: 4 })} ${esc(d.unidades_medida?.nombre || '')}</td>
                      <td class="p-2 text-slate-400 text-[11px]">
                        ${d.proveedores?.nombre ? `<span class="text-slate-300">${esc(d.proveedores.nombre)}</span>` : '<span class="italic text-slate-600">sin proveedor sugerido</span>'}
                        ${tieneDatosProv ? `${d.sku_proveedor ? `<span class="block">SKU proveedor: <span class="font-mono">${esc(d.sku_proveedor)}</span></span>` : ''}
                            ${d.descripcion_proveedor ? `<span class="block">"${esc(d.descripcion_proveedor)}"</span>` : ''}
                            ${d.unidad_proveedor ? `<span class="block">Unidad: ${esc(d.unidad_proveedor)}${d.factor_conversion_proveedor ? ` (×${d.factor_conversion_proveedor})` : ''}</span>` : ''}`
                            : (d.proveedores?.nombre ? '<span class="block italic text-slate-600">sin claves capturadas para este proveedor</span>' : '')}
                      </td>
                      <td class="p-2 text-right font-mono">${money(d.costo_estimado)}</td>
                      <td class="p-2 text-right font-mono">${money(Number(d.cantidad || 0) * Number(d.costo_estimado || 0))}</td>
                    </tr>`;
                  }).join('') || '<tr><td colspan="5" class="p-3 text-center text-slate-500">Sin partidas.</td></tr>'}
                </tbody>
                <tfoot>
                  <tr><td colspan="4" class="p-2 text-right font-semibold text-slate-400">Total estimado</td><td class="p-2 text-right font-mono font-semibold text-emerald-300">${money(total)}</td></tr>
                </tfoot>
              </table>
            </div>
            <div class="grid grid-cols-2 gap-6 mt-8 pt-4 border-t border-slate-800 text-xs text-slate-400">
                <div><p class="border-t border-slate-600 pt-1 mt-8">Solicitó</p></div>
                <div><p class="border-t border-slate-600 pt-1 mt-8">Revisó y autorizó</p></div>
            </div>`;
    } catch (err) {
        modal.querySelector('#' + idCuerpo).innerHTML = `<p class="text-rose-400 text-xs">Error al cargar la requisición: ${esc(err.message || err)}</p>`;
    }
}
window.abrirDetalleReq = (id) => abrirDetalleReq(Number(id));

window.reqRechazar = async (id) => {
    const motivo = prompt('¿Por qué se rechaza esta requisición?');
    if (motivo === null) return;
    if (!motivo.trim()) { alert('Escribe un motivo.'); return; }
    const { error } = await supabaseClient.rpc('requisicion_rechazar', {
        p_requisicion_id: id,
        p_motivo: motivo.trim(),
        p_revisada_por: null,
    });
    if (error) { alert('No se pudo rechazar: ' + (error.message || error)); return; }
    await reqRenderLista();
};

// Cancelar: la requisición ya no aplica por algo ajeno al contenido (se
// generó por error, se duplicó, ya no se necesita) — a diferencia de
// Rechazar, que es un rechazo de fondo. Requiere sql/2026-10-11_requisicion_cancelar.sql.
window.reqCancelar = async (id) => {
    if (!confirm('¿Cancelar esta requisición? Ya no se podrá autorizar ni rechazar.')) return;
    const motivo = prompt('Motivo de la cancelación (opcional):', '');
    if (motivo === null) return;
    const { error } = await supabaseClient.rpc('requisicion_cancelar', { p_requisicion_id: id, p_motivo: motivo || null });
    if (error) {
        alert(/does not exist|schema cache|could not find/i.test(error.message || '')
            ? 'Falta correr sql/2026-10-11_requisicion_cancelar.sql en Supabase.'
            : 'No se pudo cancelar: ' + (error.message || error));
        return;
    }
    await reqRenderLista();
};

// Requisiciones autorizadas antes de que ocCancelar() propagara la
// cancelación a su requisición (o si por lo que sea no se sincronizó):
// deja marcar la requisición como cancelada a mano cuando su OC ya está
// cancelada. No usa requisicion_cancelar (esa es solo para "pendiente").
window.reqSincronizarCancelacion = async (id) => {
    if (!confirm('La orden de compra de esta requisición ya está cancelada. ¿Marcar también la requisición como cancelada?')) return;
    const { error } = await supabaseClient.from('requisiciones_compra')
        .update({ estatus: 'cancelada', motivo_rechazo: 'Se canceló la orden de compra generada.' })
        .eq('id', id);
    if (error) { alert('No se pudo actualizar: ' + (error.message || error)); return; }
    await reqRenderLista();
};

// Editar (solo pendiente): fecha, notas, y cantidad/costo estimado de cada
// partida — quitar una partida también. Para agregar un producto nuevo,
// rechaza y vuelve a capturar (mantiene el flujo simple).
window.reqEditar = async (id) => {
    const idModal = window.idSubventana('modalEditarReq');
    if (idModal === 'modalEditarReq') document.getElementById('modalEditarReq')?.remove();

    const { data: r, error } = await supabaseClient
        .from('requisiciones_compra')
        .select('id, folio, fecha, notas, estatus, requisiciones_compra_detalle ( id, cantidad, costo_estimado, productos ( nombre ), descripcion )')
        .eq('id', id).single();
    if (error) { alert('No se pudo cargar la requisición: ' + (error.message || error)); return; }
    if (r.estatus !== 'pendiente') { alert('Solo se puede editar una requisición pendiente.'); return; }

    const det = r.requisiciones_compra_detalle || [];
    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh'; modal.style.left = '50%'; modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)'; modal.style.maxWidth = '36rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Editar requisición <span class="text-emerald-300 font-mono">${esc(r.folio || '#' + r.id)}</span></h3>
            <button id="cerrarEditarReq" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div class="p-4 overflow-y-auto flex-1 space-y-3">
            <div class="grid grid-cols-2 gap-3">
                <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
                    <input type="date" id="editReqFecha" value="${esc(r.fecha || '')}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                <div><label class="block text-xs text-slate-400 mb-1">Notas</label>
                    <input type="text" id="editReqNotas" value="${esc(r.notas || '')}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
            </div>
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-950 text-slate-500 uppercase"><tr>
                        <th class="p-2">Producto</th><th class="p-2 text-right">Cantidad</th><th class="p-2 text-right">Costo est.</th><th class="p-2"></th>
                    </tr></thead>
                    <tbody id="editReqPartidas">
                        ${det.map((d) => `
                            <tr class="border-b border-slate-900" data-id="${d.id}">
                                <td class="p-2">${esc(d.productos?.nombre || d.descripcion || '—')}</td>
                                <td class="p-2 text-right"><input type="number" step="any" min="0" class="edit-req-cant w-20 bg-slate-950 border border-slate-800 rounded px-2 py-1 text-right font-mono text-slate-100" value="${d.cantidad}"></td>
                                <td class="p-2 text-right"><input type="number" step="any" min="0" class="edit-req-costo w-24 bg-slate-950 border border-slate-800 rounded px-2 py-1 text-right font-mono text-slate-100" value="${Number(d.costo_estimado || 0)}"></td>
                                <td class="p-2 text-right"><button type="button" class="edit-req-quitar text-rose-400 hover:text-rose-300">✕</button></td>
                            </tr>`).join('') || '<tr><td colspan="4" class="p-3 text-center text-slate-500">Sin partidas.</td></tr>'}
                    </tbody>
                </table>
            </div>
            <p class="text-[10px] text-slate-500">Para agregar un producto nuevo, cancela esta requisición y captura una nueva — aquí solo se ajustan cantidades/costos o se quitan partidas.</p>
            <button type="button" id="btnGuardarEditarReq" class="w-full lg:w-auto lg:px-10 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar cambios</button>
            <p id="editReqMsg" class="text-xs min-h-[1rem]"></p>
        </div>`;
    document.body.appendChild(modal);

    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('#cerrarEditarReq').onclick = cerrar;
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    modal.querySelectorAll('.edit-req-quitar').forEach((b) => b.onclick = () => b.closest('tr').remove());

    modal.querySelector('#btnGuardarEditarReq').onclick = async () => {
        const msg = modal.querySelector('#editReqMsg');
        const filas = [...modal.querySelectorAll('#editReqPartidas tr[data-id]')];
        const idsRestantes = filas.map((tr) => Number(tr.dataset.id));
        const idsQuitados = det.map((d) => d.id).filter((dId) => !idsRestantes.includes(dId));
        if (!filas.length) { msg.textContent = 'La requisición debe tener al menos una partida.'; msg.className = 'text-xs min-h-[1rem] text-rose-400'; return; }

        try {
            const { error: eHead } = await supabaseClient.from('requisiciones_compra')
                .update({ fecha: modal.querySelector('#editReqFecha').value || r.fecha, notas: modal.querySelector('#editReqNotas').value.trim() || null })
                .eq('id', id);
            if (eHead) throw eHead;

            for (const tr of filas) {
                const cantidad = parseFloat(tr.querySelector('.edit-req-cant').value) || 0;
                const costo = parseFloat(tr.querySelector('.edit-req-costo').value) || 0;
                if (cantidad <= 0) throw new Error('Cada partida necesita una cantidad mayor a 0.');
                const { error: eDet } = await supabaseClient.from('requisiciones_compra_detalle')
                    .update({ cantidad, costo_estimado: costo }).eq('id', Number(tr.dataset.id));
                if (eDet) throw eDet;
            }
            if (idsQuitados.length) {
                const { error: eDel } = await supabaseClient.from('requisiciones_compra_detalle').delete().in('id', idsQuitados);
                if (eDel) throw eDel;
            }
            cerrar();
            await reqRenderLista();
        } catch (err) {
            msg.textContent = 'No se pudo guardar: ' + (err.message || err);
            msg.className = 'text-xs min-h-[1rem] text-rose-400';
        }
    };
};

// =====================================================================
//  Autorizar requisición = generar la Orden de compra FORMAL (cotización del
//  proveedor + condiciones de pago pactadas + partidas con precio real).
//  Compras PACTA contado/crédito, plazo y anticipo comprometido; el pago lo
//  ejecuta Finanzas (Cuentas por pagar). La ODC no genera póliza.
// =====================================================================
const IVA_ODC = 0.16;
const DIAS_CREDITO_ODC = [7, 15, 30, 60];

window.reqAutorizar = async (id) => {
    const idModal = window.idSubventana('modalAutorizarReq');
    if (idModal === 'modalAutorizarReq') document.getElementById('modalAutorizarReq')?.remove();

    // id == null → ODC "manual" (sin requisición): mismo documento formal, partidas capturadas aquí.
    const manual = (id == null);
    if (manual) await reqCargarCatalogos();
    const [rq, pv, fp, em] = await Promise.all([
        manual ? Promise.resolve({ data: { id: null, folio: null, fecha: hoyISO(), origen: 'captura directa', solicitada_por: null, requisiciones_compra_detalle: [] } })
            : supabaseClient.from('requisiciones_compra')
                .select(`id, folio, fecha, origen, solicitada_por, notas,
                    requisiciones_compra_detalle ( id, producto_id, descripcion, cantidad, costo_estimado, unidad_medida_id, notas, proveedor_sugerido_id,
                        sku_proveedor, productos ( nombre, sku ) )`)
                .eq('id', id).single(),
        supabaseClient.from('proveedores')
            .select('id, nombre, rfc, contacto, telefono, email, condicion_pago, dias_credito, forma_pago').order('nombre'),
        supabaseClient.from('c_forma_pago').select('clave, descripcion').order('clave'),
        manual ? supabaseClient.from('empleados').select('id, nombre').eq('activo', true).order('nombre') : Promise.resolve({ data: [] }),
    ]);
    if (rq.error) { alert('No se pudo cargar la requisición: ' + (rq.error.message || rq.error)); return; }
    const r = rq.data;
    const provs = pv.data || [];
    const formas = fp.data || [];
    const empleados = em.data || [];
    const nombreUnidad = (uid) => reqUnidades.find((u) => u.id === uid)?.nombre || '';
    const mxn = reqMonedas.find((m) => m.codigo === 'MXN');
    const optUni = '<option value="">Unidad...</option>' + reqUnidades.map((u) => `<option value="${u.id}">${esc(u.nombre)}</option>`).join('');
    const optEmp = '<option value="">— sin especificar —</option>' + empleados.map((e) => `<option value="${e.id}">${esc(e.nombre)}</option>`).join('');

    const lineas = (r.requisiciones_compra_detalle || []).slice().sort((a, b) => a.id - b.id).map((d) => ({
        reqDetId: d.id,
        productoId: d.producto_id,
        descripcion: d.descripcion,
        nombre: d.productos?.nombre || d.descripcion || '(sin nombre)',
        sku: d.productos?.sku || '',
        cantidad: Number(d.cantidad || 0),
        costo: Number(d.costo_estimado || 0),
        unidad: nombreUnidad(d.unidad_medida_id),
        skuProveedor: d.sku_proveedor || '',
    }));
    const provSugerido = (r.requisiciones_compra_detalle || []).find((d) => d.proveedor_sugerido_id)?.proveedor_sugerido_id || '';

    let condicion = 'contado';
    const hoy = hoyISO();
    const optProv = '<option value="">Seleccione proveedor...</option>' + provs.map((p) =>
        `<option value="${p.id}" ${p.id === provSugerido ? 'selected' : ''}>${esc(p.nombre)}${p.rfc ? ' — ' + esc(p.rfc) : ''}</option>`).join('');
    const optMon = reqMonedas.map((m) => `<option value="${m.id}">${esc(m.codigo)}</option>`).join('');
    const optForma = '<option value="">— sin definir —</option>' + formas.map((f) => `<option value="${esc(f.clave)}">${esc(f.clave)} · ${esc(f.descripcion)}</option>`).join('');
    const optDias = DIAS_CREDITO_ODC.map((d) => `<option value="${d}">${d} días</option>`).join('');
    const inp = 'w-full bg-slate-950 border border-slate-800 rounded-lg px-2.5 py-2 text-sm text-slate-100';
    const lbl = 'block text-[11px] text-slate-400 mb-1';
    const card = 'bg-slate-950/60 border border-slate-800 rounded-xl p-4';
    const h3 = 'text-xs font-bold uppercase tracking-wide text-slate-300 mb-1';

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed inset-0 bg-slate-950/40 z-50 flex justify-center items-start p-3 overflow-y-auto';
    modal.innerHTML = `
      <div class="bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl w-full max-w-3xl my-2">
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Generación de Orden de Compra ${manual ? '' : `<span class="text-emerald-300 font-mono">· ${esc(r.folio || '#' + r.id)}</span>`}</h3>
            <button type="button" data-x class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div class="p-4 space-y-4">

          <div class="${card}">
            ${manual ? `
            <h4 class="${h3}">📋 Origen: captura directa (sin requisición)</h4>
            <div class="mt-2 max-w-xs"><label class="${lbl}">Solicitado por · informativo</label><select data-f="solicitante" class="${inp}">${optEmp}</select></div>`
            : `
            <h4 class="${h3}">📋 Requisición de origen</h4>
            <div class="flex flex-wrap gap-x-8 gap-y-2 text-xs mt-2">
              <div><span class="block text-[10px] text-slate-500 uppercase">Folio</span><span class="font-mono text-slate-100">${esc(r.folio || '#' + r.id)}</span></div>
              <div><span class="block text-[10px] text-slate-500 uppercase">Solicitada por</span><span class="text-slate-100">${esc(r.solicitada_por || '—')}</span></div>
              <div><span class="block text-[10px] text-slate-500 uppercase">Fecha de solicitud</span><span class="text-slate-100">${esc(r.fecha || '—')}</span></div>
              <div><span class="block text-[10px] text-slate-500 uppercase">Origen</span><span class="text-slate-100">${esc(r.origen || 'manual')}</span></div>
            </div>`}
          </div>

          <div class="${card}">
            <h4 class="${h3}">🧾 Cotización del proveedor <span class="font-normal normal-case text-slate-500">— su COT / prefactura</span></h4>
            <p class="text-[11px] text-slate-500 mb-3">Lo que el proveedor mandó cuando Compras le pidió precio. Es el respaldo real de esta orden.</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
              <div><label class="${lbl}">Proveedor *</label><select data-f="proveedor" class="${inp}">${optProv}</select></div>
              <div><label class="${lbl}">N.º de cotización del proveedor *</label><input type="text" data-f="cotFolio" placeholder="Ej. COT-AZ-0417" class="${inp}"></div>
            </div>
            <p class="text-[11px] text-sky-300 bg-sky-950/40 border border-sky-900/60 rounded-lg px-2.5 py-1.5 mb-3">↳ Prellenado con los datos del proveedor (Catálogos → Proveedores) — ajústalo aquí solo si en ESTA cotización cambió.</p>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-3">
              <div><label class="${lbl}">Contacto que cotizó *</label><input type="text" data-f="contacto" class="${inp}"></div>
              <div><label class="${lbl}">Teléfono · opcional</label><input type="tel" data-f="telefono" class="${inp}"></div>
              <div><label class="${lbl}">Email · opcional</label><input type="email" data-f="email" class="${inp}"></div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div><label class="${lbl}">Fecha de la cotización *</label><input type="date" data-f="cotFecha" value="${hoy}" class="${inp}"></div>
              <div><label class="${lbl}">Vigente hasta *</label><input type="date" data-f="cotVigencia" class="${inp}"></div>
            </div>
            <p data-f="vigAviso" class="hidden text-[11px] text-amber-300 bg-amber-950/40 border border-amber-900/60 rounded-lg px-2.5 py-1.5 mt-2">⚠ La cotización vence pronto — confirma el precio con el proveedor antes de autorizar.</p>
          </div>

          <div class="${card}">
            <h4 class="${h3}">🤝 Condiciones negociadas</h4>
            <p class="text-[11px] text-slate-500 mb-3">Lo que Compras pactó con el proveedor. Compras NO ejecuta el pago: Finanzas lo hace (anticipo, pago total o parcialidades) desde Cuentas por pagar.</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
              <div><label class="${lbl}">Condición de pago *</label>
                <div class="flex bg-slate-950 border border-slate-800 rounded-lg p-0.5 gap-0.5">
                  <button type="button" data-cond="contado" class="flex-1 text-xs font-semibold py-2 rounded-md">Contado</button>
                  <button type="button" data-cond="credito" class="flex-1 text-xs font-semibold py-2 rounded-md">Crédito</button>
                </div></div>
              <div><label class="${lbl}">Plazo de crédito *</label>
                <select data-f="dias" class="${inp} disabled:opacity-40">${optDias}</select></div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-3">
              <div><label class="${lbl}">Forma de pago acordada · informativo</label><select data-f="forma" class="${inp}">${optForma}</select></div>
              <div><label class="${lbl}">Fecha esperada de entrega *</label><input type="date" data-f="fechaEsp" value="${fechaHabilesDesdeHoy(5)}" class="${inp}"></div>
              <div><label class="${lbl}">Moneda</label><select data-f="moneda" class="${inp}">${optMon}</select>
                <div data-f="tcBloque" class="hidden mt-2"><label class="${lbl}">Tipo de cambio</label>
                  <input type="number" step="0.0001" min="0" data-f="tc" class="${inp} font-mono">
                  <p data-f="tcFuente" class="text-[10px] text-slate-500 mt-0.5"></p></div></div>
            </div>
            <label class="flex items-center gap-2 text-xs text-slate-200 cursor-pointer select-none">
              <input type="checkbox" data-f="chkAnt" class="w-4 h-4 accent-emerald-500"> ¿Se paga anticipo antes de recibir la mercancía?
            </label>
            <div data-f="antBox" class="hidden mt-2 bg-emerald-950/40 border border-emerald-900/60 rounded-lg p-3">
              <div class="flex flex-wrap items-center gap-3 text-xs">
                <span class="text-emerald-300 uppercase text-[10px]">% anticipo</span>
                <input type="number" data-f="antPct" min="1" max="100" step="any" value="100" class="w-20 bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-right font-mono text-slate-100">
                <span class="text-emerald-300 uppercase text-[10px]">Equivale a</span>
                <span data-f="antMonto" class="font-mono font-bold text-slate-100">$0.00</span>
              </div>
              <p data-f="antTexto" class="text-[11px] text-slate-400 mt-2"></p>
            </div>
          </div>

          <div class="${card}">
            <h4 class="${h3}">📦 Partidas cotizadas</h4>
            <p class="text-[11px] text-slate-500 mb-3">${manual ? 'Captura cada producto con el precio real que cotizó el proveedor.' : 'Precio real del proveedor — puede diferir del costo estimado de la requisición.'}</p>
            ${manual ? `
            <div class="bg-slate-900/60 border border-slate-800 rounded-lg p-3 mb-3">
              <div class="grid grid-cols-2 sm:grid-cols-6 gap-2 items-end">
                <div class="col-span-2 sm:col-span-3 relative"><label class="${lbl}">Producto</label>
                  <input type="text" data-f="pInput" autocomplete="off" placeholder="Buscar o escribir uno nuevo..." class="${inp}">
                  <div data-f="pSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div></div>
                <div><label class="${lbl}">Cantidad</label><input type="number" step="any" min="0" data-f="pCant" class="${inp}"></div>
                <div><label class="${lbl}">Costo unit.</label><input type="number" step="any" min="0" data-f="pCosto" class="${inp}"></div>
                <div><label class="${lbl}">Unidad</label><select data-f="pUni" class="${inp}">${optUni}</select></div>
              </div>
              <button type="button" data-f="pAdd" class="mt-2 text-xs bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium px-4 py-1.5 rounded-lg">＋ Agregar partida</button>
            </div>` : ''}
            <div class="overflow-x-auto">
              <table class="w-full text-xs text-slate-300">
                <thead class="text-[10px] uppercase text-slate-500"><tr>
                  <th class="text-left p-2">Producto</th><th class="text-left p-2">SKU proveedor</th><th class="text-right p-2">Cant.</th>
                  <th class="text-right p-2">Costo unit.</th><th class="text-right p-2">Subtotal</th><th></th></tr></thead>
                <tbody data-f="partidas"></tbody>
              </table>
            </div>
            <div class="flex justify-end gap-6 mt-3 pt-2 border-t border-slate-800 text-xs">
              <div class="text-right"><span class="block text-[10px] uppercase text-slate-500">Subtotal</span><span data-f="tSub" class="font-mono text-slate-200">$0.00</span></div>
              <div class="text-right"><span class="block text-[10px] uppercase text-slate-500">IVA 16% (estimado)</span><span data-f="tIva" class="font-mono text-slate-200">$0.00</span></div>
              <div class="text-right"><span class="block text-[10px] uppercase text-slate-500">Total estimado</span><span data-f="tTot" class="font-mono text-base font-bold text-emerald-300">$0.00</span></div>
            </div>
          </div>

          <div class="${card}">
            <h4 class="${h3}">📝 Notas de la orden</h4>
            <textarea data-f="notas" rows="2" placeholder="Observaciones para el proveedor o para quien reciba..." class="${inp} mt-1"></textarea>
          </div>

          <p class="text-[11px] text-slate-500">🖨️ Al confirmar, la orden queda autorizada y se imprime con el formato estándar (encabezado ORDEN DE COMPRA + folio, cotización, condiciones, partidas, totales y firmas) desde el detalle de la orden.</p>
          <p data-f="msg" class="text-xs min-h-[1rem]"></p>
        </div>
        <div class="flex justify-between items-center gap-3 p-4 border-t border-slate-800">
          <span class="text-[11px] text-slate-500">Solicitada por: <b class="text-slate-300">${esc(r.solicitada_por || '—')}</b> · informativo</span>
          <div class="flex gap-2">
            <button type="button" data-x class="text-sm bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium px-4 py-2 rounded-lg">Cancelar</button>
            <button type="button" data-f="ok" class="text-sm bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Confirmar cotización y generar ODC</button>
          </div>
        </div>
      </div>`;
    document.body.appendChild(modal);

    const f = (n) => modal.querySelector(`[data-f="${n}"]`);
    if (mxn) f('moneda').value = mxn.id;

    const cerrar = () => { modal.remove(); document.removeEventListener('keydown', cerrarEsc); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    document.addEventListener('keydown', cerrarEsc);
    modal.querySelectorAll('[data-x]').forEach((b) => { b.onclick = cerrar; });

    // ---- Partidas ----
    const pintarPartidas = () => {
        f('partidas').innerHTML = lineas.map((l, i) => `
          <tr class="border-t border-slate-800 align-middle">
            <td class="p-2"><span class="text-slate-100 font-semibold">${esc(l.nombre)}</span><span class="block text-[10px] text-slate-500">${l.sku ? 'interno: ' + esc(l.sku) + ' · ' : ''}${esc(l.unidad)}</span></td>
            <td class="p-2"><input type="text" data-sku="${i}" value="${esc(l.skuProveedor)}" class="w-28 bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-xs text-slate-100"></td>
            <td class="p-2 text-right font-mono">${manual
                ? `<input type="number" data-cant="${i}" min="0" step="any" value="${l.cantidad}" class="w-20 bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-right font-mono text-xs text-slate-100">`
                : formatoNum(l.cantidad)}</td>
            <td class="p-2 text-right"><input type="number" data-costo="${i}" min="0" step="any" value="${l.costo}" class="w-24 bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-right font-mono text-xs text-slate-100"></td>
            <td class="p-2 text-right font-mono" data-sub="${i}">${money(l.cantidad * l.costo)}</td>
            <td class="p-2 text-right">${manual ? `<button type="button" data-quitar="${i}" class="text-rose-400 hover:text-rose-300 text-xs px-2 py-1 bg-rose-950/40 rounded border border-rose-900/50">✕</button>` : ''}</td>
          </tr>`).join('') || '<tr><td colspan="6" class="p-3 text-center text-slate-500">Sin partidas.</td></tr>';
        f('partidas').querySelectorAll('[data-cant]').forEach((el) => { el.oninput = () => { lineas[Number(el.dataset.cant)].cantidad = parseFloat(el.value) || 0; recalcular(); }; });
        f('partidas').querySelectorAll('[data-quitar]').forEach((el) => { el.onclick = () => { lineas.splice(Number(el.dataset.quitar), 1); pintarPartidas(); recalcular(); }; });
        f('partidas').querySelectorAll('[data-sku]').forEach((el) => { el.oninput = () => { lineas[Number(el.dataset.sku)].skuProveedor = el.value; }; });
        f('partidas').querySelectorAll('[data-costo]').forEach((el) => {
            el.oninput = () => { lineas[Number(el.dataset.costo)].costo = parseFloat(el.value) || 0; recalcular(); };
        });
    };
    const totales = () => {
        const sub = lineas.reduce((a, l) => a + l.cantidad * l.costo, 0);
        return { sub, iva: sub * IVA_ODC, tot: sub * (1 + IVA_ODC) };
    };
    function recalcular() {
        const t = totales();
        lineas.forEach((l, i) => { const c = modal.querySelector(`[data-sub="${i}"]`); if (c) c.textContent = money(l.cantidad * l.costo); });
        f('tSub').textContent = money(t.sub);
        f('tIva').textContent = money(t.iva);
        f('tTot').textContent = money(t.tot);
        const pct = parseFloat(f('antPct').value) || 0;
        f('antMonto').textContent = money(t.tot * pct / 100);
        pintarTextoAnticipo(pct);
    }
    function pintarTextoAnticipo(pct) {
        const resto = Math.max(0, 100 - pct);
        const dias = f('dias').value;
        f('antTexto').textContent = (resto <= 0.001
            ? 'Finanzas pagará el 100% antes de recibir (pago anticipado total). Al recibir, el anticipo cubre todo el pasivo.'
            : `Finanzas pagará ${pct}% antes de recibir; el ${resto}% restante ${condicion === 'credito' ? `a ${dias} días` : 'de contado al recibir'}.`)
            + ' Se paga desde Cuentas por pagar → anticipo a una OC.';
    }

    // ---- Condición contado / crédito ----
    const pintarCondicion = () => {
        modal.querySelectorAll('[data-cond]').forEach((b) => {
            const on = b.dataset.cond === condicion;
            b.className = 'flex-1 text-xs font-semibold py-2 rounded-md ' + (on ? 'bg-emerald-600 text-white' : 'text-slate-400 hover:text-slate-200');
        });
        f('dias').disabled = condicion !== 'credito';
        recalcular();
    };
    modal.querySelectorAll('[data-cond]').forEach((b) => { b.onclick = () => { condicion = b.dataset.cond; pintarCondicion(); }; });
    f('dias').onchange = recalcular;

    f('chkAnt').onchange = () => {
        f('antBox').classList.toggle('hidden', !f('chkAnt').checked);
        if (f('chkAnt').checked && condicion === 'credito' && f('antPct').value === '100') f('antPct').value = '50';
        recalcular();
    };
    f('antPct').oninput = recalcular;

    // ---- Vigencia ----
    const revisarVigencia = () => {
        const v = f('cotVigencia').value;
        let pronto = false;
        if (v) { const dias = Math.round((new Date(v + 'T00:00:00') - new Date(hoyISO() + 'T00:00:00')) / 86400000); pronto = dias <= 3; }
        f('vigAviso').classList.toggle('hidden', !pronto);
    };
    f('cotVigencia').onchange = revisarVigencia;

    // ---- Prellenado desde el catálogo de proveedores ----
    const prellenar = async () => {
        const p = provs.find((x) => x.id === Number(f('proveedor').value));
        if (!p) return;
        f('contacto').value = p.contacto || '';
        f('telefono').value = p.telefono || '';
        f('email').value = p.email || '';
        condicion = p.condicion_pago === 'credito' ? 'credito' : 'contado';
        const d = Number(p.dias_credito || 0);
        f('dias').value = String(DIAS_CREDITO_ODC.includes(d) ? d : 30);
        if (p.forma_pago && [...f('forma').options].some((o) => o.value === p.forma_pago)) f('forma').value = p.forma_pago;
        pintarCondicion();
        for (const l of lineas) {
            if (l.skuProveedor || !l.productoId) continue;
            try {
                const info = await obtenerInfoProveedorProducto(l.productoId, p.id);
                if (info?.claveProveedor) l.skuProveedor = info.claveProveedor;
            } catch (_) { /* sin datos del proveedor: se captura a mano */ }
        }
        pintarPartidas();
    };
    f('proveedor').onchange = prellenar;

    // ---- Tipo de cambio (DOF) al elegir una moneda distinta de MXN; queda editable ----
    const esExtranjera = () => { const s = f('moneda'); return !!s.value && (s.selectedOptions[0]?.textContent || '').trim().toUpperCase() !== 'MXN'; };
    f('moneda').onchange = async () => {
        const ext = esExtranjera();
        f('tcBloque').classList.toggle('hidden', !ext);
        if (!ext || f('tc').value) return;
        f('tcFuente').textContent = 'Consultando el DOF...';
        try {
            const { data, error } = await supabaseClient.functions.invoke('tipo-cambio-dof');
            if (error || !data?.valor) throw new Error('sin dato');
            f('tc').value = data.valor;
            f('tc').dataset.valorDof = String(data.valor);
            f('tc').dataset.fecha = data.fecha;
            f('tcFuente').textContent = `DOF · fecha ${data.fecha} · puedes cambiarlo`;
        } catch (_) { f('tcFuente').textContent = 'No se pudo traer del DOF. Captúralo a mano.'; }
    };

    // ---- Captura de partidas (solo ODC manual) ----
    let prodSel = null;
    if (manual) {
        const pInput = f('pInput'), pSug = f('pSug');
        pInput.addEventListener('input', () => {
            prodSel = null;
            const t = pInput.value.toLowerCase().trim();
            if (!t) { pSug.classList.add('hidden'); return; }
            const hits = reqProductos.filter((p) => (p.nombre && p.nombre.toLowerCase().includes(t)) || (p.sku && p.sku.toLowerCase().includes(t))).slice(0, 12);
            if (!hits.length) { pSug.classList.add('hidden'); return; }
            pSug.innerHTML = hits.map((p) => `<div class="px-3 py-2 text-xs text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer border-b border-slate-800/50 last:border-0" data-pid="${p.id}">${esc(p.nombre)} <span class="text-[10px] text-slate-400">${p.sku ? 'SKU ' + esc(p.sku) : ''}</span></div>`).join('');
            pSug.classList.remove('hidden');
            pSug.querySelectorAll('[data-pid]').forEach((el) => {
                el.onclick = () => {
                    const p = reqProductos.find((x) => x.id === Number(el.dataset.pid));
                    prodSel = p || null;
                    pInput.value = p ? p.nombre : pInput.value;
                    if (p && p.costo_unitario != null) f('pCosto').value = p.costo_unitario;
                    if (p && p.unidad_medida_id) f('pUni').value = p.unidad_medida_id;
                    pSug.classList.add('hidden');
                };
            });
        });
        f('pAdd').onclick = async () => {
            const nombre = pInput.value.trim();
            const cantidad = parseFloat(f('pCant').value) || 0;
            if (!nombre || cantidad <= 0) { alert('Indica el producto y una cantidad mayor a 0.'); return; }
            const uId = f('pUni').value ? Number(f('pUni').value) : null;
            const linea = {
                reqDetId: null, productoId: prodSel ? prodSel.id : null, descripcion: prodSel ? null : nombre, nombre,
                sku: prodSel ? (prodSel.sku || '') : '', cantidad, costo: parseFloat(f('pCosto').value) || 0,
                unidad: nombreUnidad(uId), unidadId: uId, skuProveedor: '', descripcionProveedor: null, unidadProveedor: null, factorConversion: null,
            };
            const provId = f('proveedor').value ? Number(f('proveedor').value) : null;
            if (prodSel && provId) {
                try {
                    const info = await obtenerInfoProveedorProducto(prodSel.id, provId);
                    if (info) {
                        linea.skuProveedor = info.claveProveedor || '';
                        linea.descripcionProveedor = info.descripcionProveedor || null;
                        linea.unidadProveedor = info.unidadProveedor || null;
                        linea.factorConversion = info.factorConversion ?? null;
                    }
                } catch (_) { /* sin datos del proveedor: la partida se agrega igual */ }
            }
            lineas.push(linea);
            pInput.value = ''; f('pCant').value = ''; f('pCosto').value = ''; f('pUni').value = ''; prodSel = null;
            pintarPartidas(); recalcular(); pInput.focus();
        };
    }

    pintarPartidas();
    pintarCondicion();
    if (f('proveedor').value) prellenar();

    // ---- Confirmar ----
    f('ok').onclick = async () => {
        const msg = f('msg');
        const err = (t) => { msg.textContent = t; msg.className = 'text-xs min-h-[1rem] text-rose-400'; };
        const proveedorId = f('proveedor').value ? Number(f('proveedor').value) : null;
        if (!proveedorId) return err('Elige el proveedor.');
        if (!f('cotFolio').value.trim()) return err('Captura el N.º de cotización del proveedor.');
        if (!f('contacto').value.trim()) return err('Captura el contacto que cotizó.');
        if (!f('cotFecha').value) return err('Captura la fecha de la cotización.');
        if (!f('cotVigencia').value) return err('Captura hasta cuándo es vigente la cotización.');
        if (f('cotVigencia').value < f('cotFecha').value) return err('La vigencia no puede ser anterior a la fecha de la cotización.');
        if (!f('fechaEsp').value) return err('Captura la fecha esperada de entrega.');
        if (!lineas.length) return err(manual ? 'Agrega al menos una partida.' : 'La requisición no tiene partidas.');
        if (lineas.some((l) => !(l.costo > 0))) return err('Captura el costo unitario cotizado de todas las partidas.');
        const conAnticipo = f('chkAnt').checked;
        const pct = conAnticipo ? (parseFloat(f('antPct').value) || 0) : 0;
        if (conAnticipo && (pct <= 0 || pct > 100)) return err('El % de anticipo debe estar entre 1 y 100.');

        const t = totales();
        const btn = f('ok');
        btn.disabled = true;
        msg.textContent = 'Generando la orden...'; msg.className = 'text-xs min-h-[1rem] text-slate-400';
        try {
            let ocId;
            let aviso = '';
            const notaUsuario = f('notas').value.trim();
            const camposTC = (esExtranjera() && f('tc').value) ? {
                tipo_cambio: Number(f('tc').value),
                tipo_cambio_fuente: f('tc').dataset.valorDof ? (f('tc').dataset.valorDof !== f('tc').value ? 'captura manual (DOF de referencia distinto)' : 'DOF') : 'captura manual',
                tipo_cambio_fecha: f('tc').dataset.fecha || hoyISO(),
            } : {};
            const camposFormales = {
                cotizacion_folio: f('cotFolio').value.trim(),
                cotizacion_contacto: f('contacto').value.trim(),
                cotizacion_telefono: f('telefono').value.trim() || null,
                cotizacion_email: f('email').value.trim() || null,
                cotizacion_fecha: f('cotFecha').value,
                cotizacion_vigencia: f('cotVigencia').value,
                condicion_pago: condicion,
                dias_credito: condicion === 'credito' ? Number(f('dias').value) : 0,
                forma_pago: f('forma').value || null,
                anticipo_pct: conAnticipo ? pct : null,
                anticipo_monto: conAnticipo ? Math.round(t.tot * pct) / 100 : null,
            };

            if (manual) {
                // ODC sin requisición: se inserta directo, con folio ODC consecutivo.
                const folio = await siguienteFolio('ODC');
                const { data: oc, error: eIns } = await supabaseClient.from('ordenes_compra').insert([{
                    folio,
                    proveedor_id: proveedorId,
                    fecha: hoyISO(),
                    fecha_esperada: f('fechaEsp').value || null,
                    moneda_id: f('moneda').value ? Number(f('moneda').value) : null,
                    solicitante_empleado_id: f('solicitante').value ? Number(f('solicitante').value) : null,
                    estatus: 'abierta',
                    notas: notaUsuario || null,
                    ...camposTC,
                    ...camposFormales,
                }]).select('id, folio').single();
                if (eIns) {
                    if (/does not exist|schema cache|could not find/i.test(eIns.message || '')) throw new Error('Falta correr sql/2026-10-09_odc_formal.sql en Supabase (' + eIns.message + ')');
                    throw eIns;
                }
                ocId = oc.id;
                const filas = lineas.map((l) => ({
                    orden_compra_id: ocId, producto_id: l.productoId, descripcion: l.productoId ? null : l.nombre,
                    cantidad: l.cantidad, cantidad_recibida: 0, costo_unitario_estimado: l.costo, unidad_medida_id: l.unidadId ?? null,
                    sku_proveedor: l.skuProveedor.trim() || null, descripcion_proveedor: l.descripcionProveedor || null,
                    unidad_proveedor: l.unidadProveedor || null, factor_conversion_proveedor: l.factorConversion ?? null,
                }));
                let { error: eDet } = await supabaseClient.from('ordenes_compra_detalle').insert(filas);
                if (eDet && /does not exist|schema cache|could not find/i.test(eDet.message || '')) {
                    ({ error: eDet } = await supabaseClient.from('ordenes_compra_detalle').insert(
                        filas.map(({ sku_proveedor, descripcion_proveedor, unidad_proveedor, factor_conversion_proveedor, ...resto }) => resto)));
                }
                if (eDet) throw eDet;
                cerrar();
                window.__ocAbrirTras = ocId;
                window.loadView('ordenes-compra');
                return;
            }

            const { data, error } = await supabaseClient.rpc('requisicion_autorizar', {
                p_requisicion_id: id,
                p_proveedor_id: proveedorId,
                p_fecha_esperada: f('fechaEsp').value || null,
                p_moneda_id: f('moneda').value ? Number(f('moneda').value) : null,
                p_revisada_por: null,
            });
            if (error) throw error;
            ocId = Array.isArray(data) ? data[0]?.oc_id : data?.oc_id;

            const { error: eOc } = await supabaseClient.from('ordenes_compra').update({
                ...camposTC,
                ...camposFormales,
                notas: `Generada desde requisición ${r.folio || '#' + r.id}` + (notaUsuario ? ' · ' + notaUsuario : ''),
            }).eq('id', ocId);
            if (eOc) aviso = 'La orden se creó, pero NO se guardaron cotización y condiciones (' + (eOc.message || eOc) + '). Falta correr sql/2026-10-09_odc_formal.sql.';

            // Precio real y SKU del proveedor en cada partida (el RPC copió el costo estimado de la requisición).
            const { data: det } = await supabaseClient.from('ordenes_compra_detalle')
                .select('id, producto_id, descripcion, cantidad').eq('orden_compra_id', ocId).order('id');
            const libres = lineas.slice();
            for (const d of (det || [])) {
                const k = libres.findIndex((l) => l.productoId === d.producto_id && (l.descripcion || null) === (d.descripcion || null) && Number(l.cantidad) === Number(d.cantidad));
                if (k < 0) continue;
                const l = libres.splice(k, 1)[0];
                const { error: eD } = await supabaseClient.from('ordenes_compra_detalle')
                    .update({ costo_unitario_estimado: l.costo, sku_proveedor: l.skuProveedor.trim() || null }).eq('id', d.id);
                if (eD && !aviso) aviso = 'La orden se creó, pero no se pudo guardar el precio cotizado de una partida: ' + (eD.message || eD);
            }

            cerrar();
            if (aviso) alert('⚠ ' + aviso);
            window.__ocAbrirTras = ocId;
            window.loadView('ordenes-compra');
        } catch (e) {
            err('No se pudo generar la orden: ' + (e.message || e));
            btn.disabled = false;
        }
    };
};
