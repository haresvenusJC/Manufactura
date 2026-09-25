import { supabaseClient } from './supabase.js';
import { siguienteFolio } from './folios.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { imprimirConPlantilla } from './impresion.js';
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
        .select('id, nombre, sku, costo_unitario, unidad_medida_id, proveedor_id').order('nombre');
    reqProductos = pr.data || [];
}

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
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Fecha</label>
            <input type="date" id="reqFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="reqNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>

        <div class="bg-slate-900/50 border border-slate-800 rounded-lg p-3 mb-3">
          <div class="grid grid-cols-2 md:grid-cols-5 gap-2">
            <div class="col-span-2 relative">
              <label class="block text-[11px] text-slate-400 mb-1">Producto</label>
              <input type="text" id="reqProdInput" autocomplete="off" placeholder="Buscar o escribir uno nuevo..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <div id="reqProdSug" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-xl z-40 max-h-44 overflow-y-auto"></div>
            </div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Cantidad</label>
              <input type="number" step="any" min="0" id="reqProdCant" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Unidad</label>
              <select id="reqProdUnidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optUni}</select></div>
            <div><label class="block text-[11px] text-slate-400 mb-1">Proveedor sugerido</label>
              <select id="reqProdProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optProv}</select></div>
          </div>
          <div id="reqInfoProveedor" class="hidden mt-2 text-[11px] text-slate-300 bg-slate-900 border border-slate-800 rounded-lg px-2.5 py-2"></div>
          <button type="button" id="reqAddPartida" class="mt-2 w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-1.5 rounded-lg text-xs">＋ Agregar partida</button>
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
        <button type="button" id="reqGuardar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar requisición</button>
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

    // Nota con la que llega la preselección (p. ej. desde Producción: "Faltantes para producir…").
    // Se conserva mientras queden grupos de otros proveedores por cargar.
    const notasPre = window.__reqPreNotas;
    if (!Array.isArray(window.__reqPreGruposRestantes) || !window.__reqPreGruposRestantes.length) window.__reqPreNotas = null;

    if (Array.isArray(preMulti) && preMulti.length) {
        for (const item of preMulti) {
            const p = reqProductos.find((x) => x.id === Number(item.id));
            if (!p || !(item.cantidad > 0)) continue;
            await reqAgregarPartida({ productoId: p.id, nombre: p.nombre, cantidad: item.cantidad, unidadId: p.unidad_medida_id || null, proveedorId: p.proveedor_id || null, tareaId: item.tareaId || null });
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
async function reqAgregarPartida({ productoId, nombre, cantidad, unidadId, proveedorId, tareaId = null }) {
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
        cantInp.addEventListener('change', () => { reqPartidasTemp[i].cantidad = parseFloat(cantInp.value) || 0; });
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
        let { data: req, error: e1 } = await supabaseClient.from('requisiciones_compra').insert([filaReq]).select('id, folio').single();
        if (e1 && reqOrdenProd && TABLA_FALTA.test(e1.message || '')) {
            // aún sin sql/2026-09-22_requisicion_orden_produccion.sql: se guarda sin la liga.
            delete filaReq.orden_produccion_id;
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
        modal.querySelector('#btnImprimirReq').onclick = () => imprimirConPlantilla('requisicion_compra', 'Requisición ' + (r.folio || '#' + r.id), idCuerpo);

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
            <button type="button" id="btnGuardarEditarReq" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar cambios</button>
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

window.reqAutorizar = async (id) => {
    const idModal = window.idSubventana('modalAutorizarReq');
    if (idModal === 'modalAutorizarReq') document.getElementById('modalAutorizarReq')?.remove();

    const { data: r, error } = await supabaseClient
        .from('requisiciones_compra')
        .select('id, folio, requisiciones_compra_detalle ( proveedor_sugerido_id )')
        .eq('id', id)
        .single();
    if (error) { alert('No se pudo cargar la requisición: ' + (error.message || error)); return; }

    const provSugerido = (r.requisiciones_compra_detalle || []).find(d => d.proveedor_sugerido_id)?.proveedor_sugerido_id || '';
    const optProv = '<option value="">Seleccione proveedor...</option>' + reqProveedores.map(p => `<option value="${p.id}" ${p.id === provSugerido ? 'selected' : ''}>${esc(p.nombre)}</option>`).join('');
    const optMon = reqMonedas.map(m => `<option value="${m.id}">${esc(m.codigo)}</option>`).join('');
    const mxn = reqMonedas.find(m => m.codigo === 'MXN');

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '10vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '28rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">Autorizar requisición <span class="text-emerald-300 font-mono">${esc(r.folio || '#' + r.id)}</span></h3>
            <button id="cerrarAutorizarReq" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div class="p-4 overflow-y-auto flex-1 space-y-3">
            <p class="text-xs text-slate-400">Se creará una Orden de compra con estos datos y las partidas de la requisición.</p>
            <div><label class="block text-xs text-slate-400 mb-1">Proveedor</label>
              <select id="autProveedor" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optProv}</select></div>
            <div><label class="block text-xs text-slate-400 mb-1">Fecha esperada</label>
              <input type="date" id="autFechaEsp" value="${fechaHabilesDesdeHoy(5)}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
            <div><label class="block text-xs text-slate-400 mb-1">Moneda</label>
              <select id="autMoneda" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optMon}</select></div>
            <button type="button" id="btnConfirmarAutorizar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Autorizar y crear Orden de compra</button>
            <p id="autMsg" class="text-xs min-h-[1rem]"></p>
        </div>`;
    document.body.appendChild(modal);
    if (mxn) modal.querySelector('#autMoneda').value = mxn.id;

    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('#cerrarAutorizarReq').onclick = cerrar;
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    modal.querySelector('#btnConfirmarAutorizar').onclick = async () => {
        const autMsg = modal.querySelector('#autMsg');
        const proveedorId = modal.querySelector('#autProveedor').value ? parseInt(modal.querySelector('#autProveedor').value) : null;
        if (!proveedorId) { autMsg.textContent = 'Elige el proveedor.'; autMsg.className = 'text-xs min-h-[1rem] text-rose-400'; return; }
        const btn = modal.querySelector('#btnConfirmarAutorizar');
        btn.disabled = true;
        const { data, error } = await supabaseClient.rpc('requisicion_autorizar', {
            p_requisicion_id: id,
            p_proveedor_id: proveedorId,
            p_fecha_esperada: modal.querySelector('#autFechaEsp').value || null,
            p_moneda_id: modal.querySelector('#autMoneda').value ? parseInt(modal.querySelector('#autMoneda').value) : null,
            p_revisada_por: null,
        });
        if (error) {
            autMsg.textContent = 'No se pudo autorizar: ' + (error.message || error);
            autMsg.className = 'text-xs min-h-[1rem] text-rose-400';
            btn.disabled = false;
            return;
        }
        const ocFolio = Array.isArray(data) ? data[0]?.oc_folio : data?.oc_folio;
        cerrar();
        alert(`Requisición autorizada. Se creó la Orden de compra ${ocFolio || ''}.`);
        await reqRenderLista();
    };
};
