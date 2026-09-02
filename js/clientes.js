import { supabaseClient } from './supabase.js';

// =====================================================================
//  Clientes + Listas de precio
//  Requiere: sql/2026-09-01_clientes_listas_precio.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// Régimen fiscal (SAT c_RegimenFiscal) — los más comunes.
const REGIMENES = [
    ['', '(sin especificar)'],
    ['601', '601 General de Ley Personas Morales'],
    ['603', '603 Personas Morales con Fines no Lucrativos'],
    ['605', '605 Sueldos y Salarios e Ingresos Asimilados a Salarios'],
    ['606', '606 Arrendamiento'],
    ['612', '612 Personas Físicas con Actividades Empresariales y Profesionales'],
    ['616', '616 Sin obligaciones fiscales'],
    ['621', '621 Incorporación Fiscal'],
    ['626', '626 Régimen Simplificado de Confianza (RESICO)'],
];
const USOS_CFDI = [
    ['G01', 'G01 Adquisición de mercancías'],
    ['G03', 'G03 Gastos en general'],
    ['I01', 'I01 Construcciones'],
    ['P01', 'P01 Por definir'],
    ['S01', 'S01 Sin efectos fiscales'],
    ['CP01', 'CP01 Pagos'],
];

let cliTab = 'clientes';
let cuentasCobroCache = [];
let listasCache = [];
let clientesCache = [];
let cliEditId = null;

export async function cargarModuloClientes() {
    const cont = document.getElementById('contenedorClientes');
    if (!cont) return;
    cont.innerHTML = `
        <div class="space-y-4">
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-1 flex flex-wrap gap-1" id="cliTabs"></div>
            <div id="cliContenido"></div>
        </div>`;
    renderTabs();
    await cargarComunes();
    activarTab(cliTab);
}

function renderTabs() {
    const el = document.getElementById('cliTabs');
    const tabs = [{ id: 'clientes', t: 'Clientes' }, { id: 'listas', t: 'Listas de precio' }];
    el.innerHTML = tabs.map((x) => `
        <button data-tab="${x.id}" class="cli-tab text-xs font-semibold px-3 py-2 rounded-lg transition ${x.id === cliTab ? 'bg-sky-600 text-white' : 'text-slate-400 hover:bg-slate-800'}" style="cursor:pointer">${x.t}</button>`).join('');
    el.querySelectorAll('.cli-tab').forEach((b) => b.addEventListener('click', () => activarTab(b.dataset.tab)));
}

function activarTab(id) {
    cliTab = id;
    renderTabs();
    if (id === 'clientes') renderTabClientes();
    else renderTabListas();
}

async function cargarComunes() {
    try {
        const [ctas, listas] = await Promise.all([
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo'),
            supabaseClient.from('listas_precio').select('*').order('nombre'),
        ]);
        cuentasCobroCache = (ctas.data || []).filter((c) => /^(101|102|105)/.test(c.codigo));
        listasCache = listas.data || [];
    } catch (_) { /* SQL aun no corrido */ }
}

// --------------------------- Tab Clientes ---------------------------

async function renderTabClientes() {
    const cont = document.getElementById('cliContenido');
    const optCta = '<option value="">(sin cuenta)</option>' + cuentasCobroCache.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
    const optLista = '<option value="">(sin lista)</option>' + listasCache.map((l) => `<option value="${l.id}">${l.nombre}</option>`).join('');

    cont.innerHTML = `
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <div class="flex justify-between items-center">
                <h3 id="cliFormTitulo" class="text-md font-semibold text-sky-400">Nuevo cliente</h3>
                <button type="button" id="cliNuevo" class="hidden text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2.5 py-1 rounded-lg border border-slate-700 cursor-pointer">Nuevo</button>
            </div>
            <form id="cliForm" class="space-y-2">
                <input type="hidden" id="cliId">
                <div><label class="block text-[11px] text-slate-400 mb-1">Nombre / Razón social <span class="text-rose-400">*</span></label>
                    <input type="text" id="cliNombre" required class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">RFC</label>
                        <input type="text" id="cliRfc" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">CP</label>
                        <input type="text" id="cliCp" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Régimen fiscal</label>
                        <select id="cliRegimen" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${REGIMENES.map(([v, t]) => `<option value="${v}">${t}</option>`).join('')}</select></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Uso CFDI</label>
                        <select id="cliUso" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${USOS_CFDI.map(([v, t]) => `<option value="${v}" ${v === 'G03' ? 'selected' : ''}>${t}</option>`).join('')}</select></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Contacto</label>
                        <input type="text" id="cliContacto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Teléfono</label>
                        <input type="text" id="cliTelefono" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                </div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Email</label>
                    <input type="email" id="cliEmail" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Dirección</label>
                    <textarea id="cliDireccion" rows="2" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></textarea></div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Condición de pago</label>
                        <select id="cliCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="contado">Contado</option><option value="credito">Crédito</option></select></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Días de crédito</label>
                        <input type="number" min="0" step="1" id="cliDias" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                </div>
                <div class="grid grid-cols-2 gap-2">
                    <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de cobro</label>
                        <select id="cliCuentaCobro" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optCta}</select></div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Lista de precio</label>
                        <select id="cliLista" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optLista}</select></div>
                </div>
                <div><label class="block text-[11px] text-slate-400 mb-1">Notas</label>
                    <input type="text" id="cliNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                <label class="flex items-center gap-2 text-xs text-slate-300"><input type="checkbox" id="cliActivo" checked class="accent-sky-500"> Activo</label>
                <button type="submit" id="cliGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Guardar cliente</button>
                <p id="cliMsg" class="text-xs min-h-[1rem]"></p>
            </form>
        </div>
        <div class="lg:col-span-2 space-y-3">
            <div class="flex flex-wrap justify-between items-center gap-2">
                <h3 class="text-md font-semibold text-slate-200">Catálogo de clientes</h3>
                <input type="text" id="cliFiltro" placeholder="filtrar..." class="bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 w-56 focus:outline-none focus:border-sky-500">
            </div>
            <div id="cliTabla" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-center text-slate-500 text-sm">Cargando...</div>
        </div>
    </div>`;

    document.getElementById('cliForm').addEventListener('submit', guardarCliente);
    document.getElementById('cliNuevo').addEventListener('click', limpiarCliForm);
    document.getElementById('cliFiltro').addEventListener('input', renderTablaClientes);
    document.getElementById('cliCondicion').addEventListener('change', (e) => {
        if (e.target.value === 'contado') document.getElementById('cliDias').value = 0;
    });
    await recargarClientes();
}

async function recargarClientes() {
    try {
        const { data, error } = await supabaseClient
            .from('clientes')
            .select('*, listas_precio(nombre)')
            .order('nombre');
        if (error) throw error;
        clientesCache = data || [];
        renderTablaClientes();
    } catch (err) {
        document.getElementById('cliTabla').innerHTML =
            `<p class="text-rose-400 text-xs">No se pudo cargar. ¿Corriste <span class="font-mono">sql/2026-09-01_clientes_listas_precio.sql</span>?<br>${err.message || err}</p>`;
    }
}

function renderTablaClientes() {
    const cont = document.getElementById('cliTabla');
    const q = (document.getElementById('cliFiltro').value || '').trim().toLowerCase();
    let lista = clientesCache;
    if (q) lista = lista.filter((c) => `${c.nombre} ${c.rfc || ''} ${c.contacto || ''}`.toLowerCase().includes(q));
    if (!lista.length) { cont.innerHTML = `<p class="text-slate-400 text-sm">Sin clientes.</p>`; return; }

    cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                    <tr><th class="p-2 text-left">Acciones</th><th class="p-2">Nombre</th><th class="p-2">RFC</th><th class="p-2">Contacto</th>
                        <th class="p-2">Cond.</th><th class="p-2">Lista</th><th class="p-2">Estado</th></tr>
                </thead>
                <tbody>
                    ${lista.map((c) => `
                        <tr class="border-b border-slate-900 ${c.activo ? '' : 'opacity-50'}">
                            <td class="p-2"><button data-edit="${c.id}" class="cli-edit text-[10px] bg-slate-800 hover:bg-slate-700 text-sky-300 px-2 py-1 rounded border border-slate-700 cursor-pointer">Editar</button></td>
                            <td class="p-2 text-slate-100 font-medium">${c.nombre}</td>
                            <td class="p-2 font-mono text-slate-400">${c.rfc || '—'}</td>
                            <td class="p-2 text-slate-400">${c.contacto || '—'}</td>
                            <td class="p-2 text-slate-400">${c.condicion_pago}${c.condicion_pago === 'credito' ? ` (${c.dias_credito}d)` : ''}</td>
                            <td class="p-2 text-slate-400">${c.listas_precio?.nombre || '—'}</td>
                            <td class="p-2"><button data-toggle="${c.id}" class="cli-toggle text-[10px] px-2 py-0.5 rounded border cursor-pointer ${c.activo ? 'bg-emerald-950 text-emerald-400 border-emerald-800' : 'bg-slate-800 text-slate-400 border-slate-700'}">${c.activo ? 'Activo' : 'Inactivo'}</button></td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>`;
    cont.querySelectorAll('.cli-edit').forEach((b) => b.addEventListener('click', () => editarCliente(Number(b.dataset.edit))));
    cont.querySelectorAll('.cli-toggle').forEach((b) => b.addEventListener('click', async () => {
        const c = clientesCache.find((x) => x.id === Number(b.dataset.toggle));
        await supabaseClient.from('clientes').update({ activo: !c.activo }).eq('id', c.id);
        await recargarClientes();
    }));
}

function limpiarCliForm() {
    cliEditId = null;
    document.getElementById('cliForm').reset();
    document.getElementById('cliId').value = '';
    document.getElementById('cliActivo').checked = true;
    document.getElementById('cliUso').value = 'G03';
    document.getElementById('cliFormTitulo').textContent = 'Nuevo cliente';
    document.getElementById('cliGuardar').textContent = 'Guardar cliente';
    document.getElementById('cliNuevo').classList.add('hidden');
    document.getElementById('cliMsg').textContent = '';
}

function editarCliente(id) {
    const c = clientesCache.find((x) => x.id === id);
    if (!c) return;
    cliEditId = id;
    const set = (el, v) => { document.getElementById(el).value = v ?? ''; };
    document.getElementById('cliId').value = id;
    set('cliNombre', c.nombre); set('cliRfc', c.rfc); set('cliCp', c.cp);
    set('cliRegimen', c.regimen_fiscal); set('cliUso', c.uso_cfdi || 'G03');
    set('cliContacto', c.contacto); set('cliTelefono', c.telefono); set('cliEmail', c.email);
    set('cliDireccion', c.direccion); set('cliCondicion', c.condicion_pago || 'contado');
    set('cliDias', c.dias_credito ?? 0);
    set('cliCuentaCobro', c.cuenta_cobro_id || ''); set('cliLista', c.lista_precio_id || '');
    set('cliNotas', c.notas);
    document.getElementById('cliActivo').checked = c.activo !== false;
    document.getElementById('cliFormTitulo').textContent = `Editar ${c.nombre}`;
    document.getElementById('cliGuardar').textContent = 'Actualizar cliente';
    document.getElementById('cliNuevo').classList.remove('hidden');
    document.getElementById('contenedorClientes').scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function guardarCliente(e) {
    e.preventDefault();
    const msg = document.getElementById('cliMsg');
    const val = (id) => document.getElementById(id).value.trim();
    const payload = {
        nombre: val('cliNombre'),
        rfc: val('cliRfc') || null,
        cp: val('cliCp') || null,
        regimen_fiscal: val('cliRegimen') || null,
        uso_cfdi: val('cliUso') || null,
        contacto: val('cliContacto') || null,
        telefono: val('cliTelefono') || null,
        email: val('cliEmail') || null,
        direccion: val('cliDireccion') || null,
        condicion_pago: val('cliCondicion'),
        dias_credito: parseInt(document.getElementById('cliDias').value, 10) || 0,
        cuenta_cobro_id: val('cliCuentaCobro') ? parseInt(val('cliCuentaCobro'), 10) : null,
        lista_precio_id: val('cliLista') ? parseInt(val('cliLista'), 10) : null,
        notas: val('cliNotas') || null,
        activo: document.getElementById('cliActivo').checked,
    };
    if (!payload.nombre) { msg.textContent = 'El nombre es obligatorio.'; msg.className = 'text-xs text-rose-400'; return; }
    try {
        if (cliEditId) {
            const { error } = await supabaseClient.from('clientes').update(payload).eq('id', cliEditId);
            if (error) throw error;
        } else {
            const { error } = await supabaseClient.from('clientes').insert([payload]);
            if (error) throw error;
        }
        limpiarCliForm();
        await recargarClientes();
        msg.textContent = 'Guardado.'; msg.className = 'text-xs text-emerald-400';
    } catch (err) {
        msg.textContent = err.message || String(err); msg.className = 'text-xs text-rose-400';
    }
}

// --------------------------- Tab Listas de precio ---------------------------

let listaSelId = null;
let itemsLista = new Map();     // producto_id -> precio (en la lista seleccionada)
let productosLista = [];        // {id, sku, nombre, precio_venta}

async function renderTabListas() {
    const cont = document.getElementById('cliContenido');
    cont.innerHTML = `
    <div class="space-y-4">
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl flex flex-wrap items-end gap-3">
            <div>
                <label class="block text-[11px] text-slate-400 mb-1">Lista</label>
                <select id="lpSelect" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></select>
            </div>
            <button type="button" id="lpNueva" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer">+ Nueva lista</button>
            <input type="text" id="lpFiltro" placeholder="filtrar productos..." class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 w-56">
            <button type="button" id="lpGuardar" class="ml-auto text-xs bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg font-semibold cursor-pointer">Guardar precios</button>
        </div>
        <div id="lpTabla" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Elige o crea una lista.</div>
        <p id="lpMsg" class="text-xs min-h-[1rem]"></p>
    </div>`;

    await cargarComunes();
    const sel = document.getElementById('lpSelect');
    sel.innerHTML = listasCache.map((l) => `<option value="${l.id}">${l.nombre}${l.es_default ? ' (base)' : ''}</option>`).join('') || '<option value="">(sin listas)</option>';
    if (listasCache.length) { listaSelId = Number(sel.value); }

    sel.addEventListener('change', () => { listaSelId = Number(sel.value); cargarItemsLista(); });
    document.getElementById('lpFiltro').addEventListener('input', renderTablaLista);
    document.getElementById('lpNueva').addEventListener('click', nuevaLista);
    document.getElementById('lpGuardar').addEventListener('click', guardarPreciosLista);

    if (listaSelId) await cargarItemsLista();
}

async function nuevaLista() {
    const nombre = prompt('Nombre de la lista (ej. Mayoreo, Cadenas):', '');
    if (!nombre || !nombre.trim()) return;
    const { data, error } = await supabaseClient.from('listas_precio').insert([{ nombre: nombre.trim() }]).select('id').single();
    if (error) { alert('No se pudo crear: ' + error.message); return; }
    await cargarComunes();
    const sel = document.getElementById('lpSelect');
    sel.innerHTML = listasCache.map((l) => `<option value="${l.id}">${l.nombre}${l.es_default ? ' (base)' : ''}</option>`).join('');
    sel.value = data.id; listaSelId = data.id;
    await cargarItemsLista();
}

async function cargarItemsLista() {
    const cont = document.getElementById('lpTabla');
    cont.innerHTML = '<p class="text-slate-500">Cargando...</p>';
    try {
        const [prods, items] = await Promise.all([
            supabaseClient.from('productos').select('id, sku, nombre, precio_venta, activo').order('nombre'),
            supabaseClient.from('lista_precio_items').select('producto_id, precio').eq('lista_id', listaSelId),
        ]);
        if (prods.error) throw prods.error;
        if (items.error) throw items.error;
        productosLista = (prods.data || []).filter((p) => p.activo !== false);
        itemsLista = new Map((items.data || []).map((i) => [i.producto_id, Number(i.precio)]));
        renderTablaLista();
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">${err.message || err}</p>`;
    }
}

function renderTablaLista() {
    const cont = document.getElementById('lpTabla');
    if (!listaSelId) { cont.innerHTML = '<p class="text-slate-400">Elige o crea una lista.</p>'; return; }
    const q = (document.getElementById('lpFiltro')?.value || '').trim().toLowerCase();
    const lista = productosLista.filter((p) => !q || `${p.sku || ''} ${p.nombre}`.toLowerCase().includes(q));
    cont.innerHTML = `
        <div class="overflow-x-auto max-h-[28rem] overflow-y-auto border border-slate-800 rounded-lg">
            <table class="w-full text-left text-[11px] text-slate-300">
                <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800 sticky top-0">
                    <tr><th class="p-2">SKU</th><th class="p-2">Producto</th><th class="p-2 text-right">Precio base</th><th class="p-2 text-right">Precio en esta lista</th></tr>
                </thead>
                <tbody>
                    ${lista.map((p) => `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 font-mono text-slate-500">${p.sku || '—'}</td>
                            <td class="p-2 text-slate-200">${p.nombre}</td>
                            <td class="p-2 text-right font-mono text-slate-500">${p.precio_venta != null ? money(p.precio_venta) : '—'}</td>
                            <td class="p-2 text-right">
                                <input type="number" step="0.01" min="0" data-pid="${p.id}"
                                    value="${itemsLista.has(p.id) ? itemsLista.get(p.id) : ''}" placeholder="(usa base)"
                                    class="lp-precio w-28 bg-slate-900 border border-slate-800 rounded p-1 text-[11px] text-slate-100 text-right font-mono">
                            </td>
                        </tr>`).join('')}
                </tbody>
            </table>
        </div>
        <p class="text-[11px] text-slate-500 mt-2">Deja el campo vacío para que ese producto use su <b>precio de venta base</b>. "Guardar precios" aplica los cambios.</p>`;
}

async function guardarPreciosLista() {
    const msg = document.getElementById('lpMsg');
    msg.textContent = 'Guardando...'; msg.className = 'text-xs text-slate-400';
    const upserts = [];
    const borrar = [];
    document.querySelectorAll('.lp-precio').forEach((inp) => {
        const pid = Number(inp.dataset.pid);
        const raw = inp.value.trim();
        const yaHabia = itemsLista.has(pid);
        if (raw === '') { if (yaHabia) borrar.push(pid); return; }
        const val = Math.max(0, parseFloat(raw) || 0);
        if (!yaHabia || itemsLista.get(pid) !== val) upserts.push({ lista_id: listaSelId, producto_id: pid, precio: val });
    });
    try {
        if (upserts.length) {
            const { error } = await supabaseClient.from('lista_precio_items').upsert(upserts, { onConflict: 'lista_id,producto_id' });
            if (error) throw error;
        }
        if (borrar.length) {
            const { error } = await supabaseClient.from('lista_precio_items').delete().eq('lista_id', listaSelId).in('producto_id', borrar);
            if (error) throw error;
        }
        msg.textContent = `Listo: ${upserts.length} actualizado(s), ${borrar.length} quitado(s).`;
        msg.className = 'text-xs text-emerald-400';
        await cargarItemsLista();
    } catch (err) {
        msg.textContent = err.message || String(err); msg.className = 'text-xs text-rose-400';
    }
}
