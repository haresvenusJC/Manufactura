import { supabaseClient } from './supabase.js';

export const REGIMENES = [
    ['601', 'General de Ley Personas Morales'],
    ['603', 'Personas Morales con Fines no Lucrativos'],
    ['605', 'Sueldos y Salarios e Ingresos Asimilados a Salarios'],
    ['606', 'Arrendamiento'],
    ['607', 'Régimen de Enajenación o Adquisición de Bienes'],
    ['608', 'Demás ingresos'],
    ['610', 'Residentes en el Extranjero sin Establecimiento Permanente en México'],
    ['611', 'Ingresos por Dividendos (socios y accionistas)'],
    ['612', 'Personas Físicas con Actividades Empresariales y Profesionales'],
    ['614', 'Ingresos por intereses'],
    ['615', 'Régimen de los ingresos por obtención de premios'],
    ['616', 'Sin obligaciones fiscales'],
    ['620', 'Sociedades Cooperativas de Producción'],
    ['621', 'Incorporación Fiscal'],
    ['622', 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras'],
    ['623', 'Opcional para Grupos de Sociedades'],
    ['624', 'Coordinados'],
    ['625', 'Régimen de las Actividades Empresariales con ingresos a través de Plataformas Tecnológicas'],
    ['626', 'Régimen Simplificado de Confianza (RESICO)'],
];

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

let provCtas = [];
let provCatUso = [];
let provCatForma = [];
let provCatMetodo = [];

export async function cargarModuloProveedores() {
    const contenedor = document.getElementById('contenedorProveedores');
    if (!contenedor) return;

    // Catálogos (best-effort: si falta el SQL de contabilidad/CFDI se usan opciones básicas)
    provCtas = []; provCatUso = []; provCatForma = []; provCatMetodo = [];
    try {
        const [c, u, f, m] = await Promise.all([
            supabaseClient.from('cuentas_contables').select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo'),
            supabaseClient.from('c_uso_cfdi').select('clave, descripcion').order('clave'),
            supabaseClient.from('c_forma_pago').select('clave, descripcion').order('clave'),
            supabaseClient.from('c_metodo_pago').select('clave, descripcion').order('clave'),
        ]);
        provCtas = c.data || [];
        provCatUso = u.data || [];
        provCatForma = f.data || [];
        provCatMetodo = m.data || [];
    } catch (_) { /* catálogos no instalados */ }

    // Valores por defecto para agilizar el alta (el caso mas comun de esta
    // empresa): regimen general de ley, uso CFDI de adquisicion de
    // mercancias, forma de pago transferencia, metodo PUE, y la cuenta de
    // proveedores nacionales. Quedan como "selected" en el HTML para que
    // tambien apliquen despues de un form.reset() (boton "Nuevo").
    const sel = (cond) => (cond ? ' selected' : '');
    const optReg = '<option value="">— régimen —</option>' + REGIMENES.map(([k, v]) => `<option value="${k}"${sel(k === '601')}>${k} · ${esc(v)}</option>`).join('');
    const optUso = '<option value="">—</option>' + (provCatUso.length
        ? provCatUso.map(x => `<option value="${esc(x.clave)}"${sel(x.clave === 'G01')}>${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="G01" selected>G01 · Adquisición de mercancías</option><option value="G03">G03 · Gastos en general</option>`);
    const optForma = '<option value="">—</option>' + (provCatForma.length
        ? provCatForma.map(x => `<option value="${esc(x.clave)}"${sel(x.clave === '03')}>${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="01">01 · Efectivo</option><option value="03" selected>03 · Transferencia</option><option value="04">04 · Tarjeta de crédito</option><option value="99">99 · Por definir</option>`);
    const optMetodo = '<option value="">—</option>' + (provCatMetodo.length
        ? provCatMetodo.map(x => `<option value="${esc(x.clave)}"${sel(x.clave === 'PUE')}>${esc(x.clave)} · ${esc(x.descripcion)}</option>`).join('')
        : `<option value="PUE" selected>PUE · Pago en una sola exhibición</option><option value="PPD">PPD · Pago en parcialidades o diferido</option>`);
    const optCta = '<option value="">— sin cuenta —</option>' + provCtas.map(c => `<option value="${c.id}"${sel(c.codigo === '201.01')}>${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    contenedor.innerHTML = `
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3 shadow-xl">
                <div class="flex justify-between items-center">
                    <h3 id="tituloFormProveedor" class="text-md font-semibold text-sky-400">Nuevo proveedor</h3>
                    <button type="button" id="btnLimpiarProveedor" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2.5 py-1 rounded-lg border border-slate-700 hidden cursor-pointer">Nuevo</button>
                </div>
                <form id="formProveedor" class="space-y-2.5 relative">
                    <input type="hidden" id="proveedorIdEdit">
                    <div class="relative">
                        <label class="block text-[11px] text-slate-400 mb-1">Nombre / Razón social <span class="text-rose-400">*</span></label>
                        <input type="text" id="provNombre" autocomplete="off" placeholder="Ej. ALKEM Industrias" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-sky-500" required>
                        <div id="sugerenciasProveedores" class="absolute z-50 left-0 right-0 bg-slate-900 border border-slate-700 rounded-lg shadow-2xl mt-1 hidden max-h-52 overflow-y-auto text-sm"></div>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <div><label class="block text-[11px] text-slate-400 mb-1">RFC</label>
                            <input type="text" id="provRfc" placeholder="AIN880204464" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase"></div>
                        <div><label class="block text-[11px] text-slate-400 mb-1">C.P. (domicilio fiscal)</label>
                            <input type="text" id="provCp" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                    </div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Régimen fiscal</label>
                        <select id="provRegimen" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optReg}</select></div>
                    <div class="grid grid-cols-2 gap-2">
                        <div><label class="block text-[11px] text-slate-400 mb-1">Contacto</label>
                            <input type="text" id="provContacto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                        <div><label class="block text-[11px] text-slate-400 mb-1">Teléfono</label>
                            <input type="text" id="provTelefono" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono"></div>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <div><label class="block text-[11px] text-slate-400 mb-1">Email</label>
                            <input type="email" id="provEmail" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
                        <div><label class="block text-[11px] text-slate-400 mb-1">Moneda habitual</label>
                            <input type="text" id="provMoneda" value="MXN" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase"></div>
                    </div>
                    <div><label class="block text-[11px] text-slate-400 mb-1">Dirección</label>
                        <input type="text" id="provDireccion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>

                    <div class="border-t border-slate-800 pt-2.5">
                        <p class="text-[11px] font-semibold text-sky-400 mb-2">Valores por defecto para sus compras</p>
                        <div class="grid grid-cols-2 gap-2">
                            <div><label class="block text-[11px] text-slate-400 mb-1">Uso CFDI</label>
                                <select id="provUso" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optUso}</select></div>
                            <div><label class="block text-[11px] text-slate-400 mb-1">Condición</label>
                                <select id="provCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                    <option value="contado" selected>Contado</option><option value="credito">Crédito</option></select></div>
                            <div><label class="block text-[11px] text-slate-400 mb-1">Días de crédito</label>
                                <input type="number" step="1" min="0" id="provDias" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"></div>
                            <div><label class="block text-[11px] text-slate-400 mb-1">Forma de pago (SAT)</label>
                                <select id="provForma" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optForma}</select></div>
                            <div><label class="block text-[11px] text-slate-400 mb-1">Método de pago</label>
                                <select id="provMetodo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optMetodo}</select></div>
                            <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de gasto / inventario</label>
                                <select id="provCuentaGasto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optCta}</select></div>
                        </div>
                    </div>

                    <div><label class="block text-[11px] text-slate-400 mb-1">Notas</label>
                        <textarea id="provNotas" rows="2" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></textarea></div>
                    <label class="flex items-center gap-2 text-xs text-slate-300"><input type="checkbox" id="provActivo" checked class="accent-sky-500"> Activo</label>

                    <button type="submit" id="btnGuardarProveedor" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm shadow-md cursor-pointer">Guardar proveedor</button>
                    <p id="provMsg" class="text-xs min-h-[1rem]"></p>
                </form>
            </div>

            <div class="lg:col-span-2 space-y-4">
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
                    <h3 class="text-md font-semibold text-slate-200">Catálogo de proveedores</h3>
                    <select id="selectFiltroProveedor" class="bg-slate-950 border border-slate-800 text-slate-200 text-xs rounded-lg p-2 w-full sm:w-64 focus:outline-none focus:border-sky-500">
                        <option value="">Seleccione proveedor para ver compras...</option>
                    </select>
                </div>
                <div id="tablaProveedoresContainer" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-center text-slate-500 text-sm">Cargando proveedores...</div>
                <div class="mt-4 space-y-2 bg-slate-950 border border-slate-800 p-4 rounded-xl">
                    <h4 class="text-sm font-semibold text-sky-400 mb-2">Historial de compras del proveedor seleccionado</h4>
                    <div id="historialComprasProveedorContainer" class="min-h-[80px] text-xs text-slate-400 flex items-center justify-center">
                        Elige un proveedor arriba o en la tabla para ver su historial.
                    </div>
                </div>
            </div>
        </div>
    `;

    await renderizarTablaProveedores();
    configurarLogicaProveedores();
}

async function renderizarTablaProveedores() {
    const cont = document.getElementById('tablaProveedoresContainer');
    const sel = document.getElementById('selectFiltroProveedor');
    if (!cont || !sel) return;
    try {
        const { data, error } = await supabaseClient.from('proveedores').select('*').order('nombre', { ascending: true });
        if (error) throw error;

        sel.innerHTML = '<option value="">Seleccione proveedor para ver compras...</option>' +
            (data || []).map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');

        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-400 text-sm">No hay proveedores registrados.</p>'; return; }

        cont.innerHTML = `
            <div class="overflow-x-auto border border-slate-800 rounded-xl max-h-72 overflow-y-auto bg-slate-950">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900 text-sky-400 border-b border-slate-800 text-xs uppercase sticky top-0">
                        <tr><th class="p-3 text-left">Acciones</th><th class="p-3">Proveedor</th><th class="p-3">RFC</th><th class="p-3">Contacto</th><th class="p-3">Cond.</th><th class="p-3">Estado</th></tr>
                    </thead>
                    <tbody>
                        ${data.map(p => `
                            <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition ${p.activo === false ? 'opacity-50' : ''}">
                                <td class="p-3"><button type="button" onclick="window.editarProveedor(${p.id})" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-2.5 py-1 rounded-lg border border-slate-700 cursor-pointer">Editar</button>
                                    <button type="button" onclick="window.filtrarComprasProveedor(${p.id}, '${esc(p.nombre).replace(/'/g, "\\'")}')" class="text-xs bg-sky-950 hover:bg-sky-900 text-sky-400 px-2.5 py-1 rounded-lg border border-sky-800 ml-1 cursor-pointer">Compras</button></td>
                                <td class="p-3 font-medium text-slate-100">${esc(p.nombre)}</td>
                                <td class="p-3 font-mono text-xs text-sky-300">${esc(p.rfc || '—')}</td>
                                <td class="p-3 text-slate-400 text-xs">${esc(p.contacto || '—')}${p.telefono ? ` · ${esc(p.telefono)}` : ''}</td>
                                <td class="p-3 text-xs text-slate-400">${esc(p.condicion_pago || '—')}${p.dias_credito ? ` (${p.dias_credito}d)` : ''}</td>
                                <td class="p-3 text-xs ${p.activo === false ? 'text-rose-400' : 'text-emerald-400'}">${p.activo === false ? 'Inactivo' : 'Activo'}</td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>`;
    } catch (err) {
        console.error('Error al cargar proveedores:', err);
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar proveedores: ${esc(err.message || err)}</p>`;
    }
}

function configurarLogicaProveedores() {
    const $ = (id) => document.getElementById(id);
    const form = $('formProveedor');
    const btnLimpiar = $('btnLimpiarProveedor');
    const titulo = $('tituloFormProveedor');
    const btnGuardar = $('btnGuardarProveedor');
    const inputNombre = $('provNombre');
    const dropdown = $('sugerenciasProveedores');
    const msg = $('provMsg');

    const CAMPOS = {
        provNombre: 'nombre', provRfc: 'rfc', provCp: 'cp', provRegimen: 'regimen_fiscal',
        provContacto: 'contacto', provTelefono: 'telefono', provEmail: 'email', provDireccion: 'direccion',
        provMoneda: 'moneda', provUso: 'uso_cfdi', provCondicion: 'condicion_pago', provForma: 'forma_pago',
        provMetodo: 'metodo_pago', provNotas: 'notas',
    };

    function limpiar() {
        form.reset();
        $('proveedorIdEdit').value = '';
        $('provMoneda').value = 'MXN';
        $('provActivo').checked = true;
        titulo.textContent = 'Nuevo proveedor';
        btnGuardar.textContent = 'Guardar proveedor';
        btnLimpiar.classList.add('hidden');
        dropdown.classList.add('hidden');
        msg.textContent = '';
    }
    btnLimpiar.addEventListener('click', limpiar);

    inputNombre.addEventListener('input', async (e) => {
        const q = e.target.value.trim();
        if (q.length < 2) { dropdown.classList.add('hidden'); return; }
        try {
            const { data } = await supabaseClient.from('proveedores')
                .select('id, nombre, rfc, contacto, telefono')
                .or(`nombre.ilike.%${q}%,rfc.ilike.%${q}%`)
                .limit(6);
            if (data && data.length) {
                dropdown.innerHTML = data.map(p => `
                    <div class="p-2.5 hover:bg-slate-800 border-b border-slate-800 text-slate-200 cursor-pointer flex justify-between items-center prov-sug" data-id="${p.id}">
                        <div><div class="font-semibold text-sky-400">${esc(p.nombre)}</div>
                            <div class="text-xs text-slate-400 font-mono">${esc(p.rfc || 's/RFC')} · ${esc(p.contacto || '')}</div></div>
                        <span class="text-[11px] bg-sky-950 text-sky-300 px-2 py-1 rounded border border-sky-800 shrink-0">Editar</span>
                    </div>`).join('');
                dropdown.classList.remove('hidden');
                dropdown.querySelectorAll('.prov-sug').forEach(el => el.onclick = () => { window.editarProveedor(Number(el.dataset.id)); dropdown.classList.add('hidden'); });
            } else {
                dropdown.innerHTML = '<div class="p-2.5 text-xs text-slate-400">Sin coincidencias. Se registrará como nuevo.</div>';
                dropdown.classList.remove('hidden');
            }
        } catch (_) { /* noop */ }
    });
    document.addEventListener('click', (e) => {
        if (!inputNombre.contains(e.target) && !dropdown.contains(e.target)) dropdown.classList.add('hidden');
    });

    window.editarProveedor = async function (id) {
        try {
            const { data: p, error } = await supabaseClient.from('proveedores').select('*').eq('id', id).single();
            if (error) throw error;
            $('proveedorIdEdit').value = p.id;
            Object.entries(CAMPOS).forEach(([elId, col]) => { const el = $(elId); if (el) el.value = p[col] ?? (elId === 'provMoneda' ? 'MXN' : ''); });
            $('provDias').value = p.dias_credito ?? 0;
            $('provCuentaGasto').value = p.cuenta_gasto_id || '';
            $('provActivo').checked = p.activo !== false;
            titulo.textContent = 'Modificar proveedor';
            btnGuardar.textContent = 'Actualizar proveedor';
            btnLimpiar.classList.remove('hidden');
            dropdown.classList.add('hidden');
            document.getElementById('contenedorProveedores').scrollIntoView({ behavior: 'smooth', block: 'start' });
        } catch (err) {
            alert('No se pudo cargar el proveedor: ' + (err.message || err));
        }
    };

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';
        const idEdit = $('proveedorIdEdit').value;
        const nombre = inputNombre.value.trim();
        if (!nombre) { msg.textContent = 'El nombre es obligatorio.'; msg.className = 'text-xs text-rose-400'; return; }

        const core = {
            nombre,
            contacto: $('provContacto').value.trim() || null,
            telefono: $('provTelefono').value.trim() || null,
        };
        const fiscal = {
            rfc: $('provRfc').value.trim().toUpperCase() || null,
            razon_social: nombre,
            regimen_fiscal: $('provRegimen').value || null,
            cp: $('provCp').value.trim() || null,
            email: $('provEmail').value.trim() || null,
            direccion: $('provDireccion').value.trim() || null,
            moneda: $('provMoneda').value.trim().toUpperCase() || 'MXN',
            uso_cfdi: $('provUso').value || null,
            condicion_pago: $('provCondicion').value || 'credito',
            dias_credito: parseInt($('provDias').value) || 0,
            forma_pago: $('provForma').value || null,
            metodo_pago: $('provMetodo').value || null,
            cuenta_gasto_id: $('provCuentaGasto').value ? Number($('provCuentaGasto').value) : null,
            activo: $('provActivo').checked,
            notas: $('provNotas').value.trim() || null,
        };

        btnGuardar.disabled = true;
        try {
            let id = idEdit ? Number(idEdit) : null;
            if (id) {
                const { error } = await supabaseClient.from('proveedores').update(core).eq('id', id);
                if (error) throw error;
            } else {
                const { data, error } = await supabaseClient.from('proveedores').insert([core]).select('id').single();
                if (error) throw error;
                id = data.id;
            }
            // Datos fiscales: best-effort (se ignora si falta el SQL de proveedores)
            const { data: dF, error: eF } = await supabaseClient.from('proveedores').update(fiscal).eq('id', id).select('id');
            if (eF && !/does not exist|schema cache|could not find/i.test(eF.message || '')) throw eF;

            let msgTexto, msgClase;
            if (eF) {
                msgTexto = 'Guardado. Ojo: falta correr sql/2026-09-03_proveedores_fiscal.sql para los datos fiscales.';
                msgClase = 'text-xs text-amber-400';
            } else if (!dF || dF.length === 0) {
                // update() sin error pero 0 filas afectadas = normalmente RLS
                // bloqueando el UPDATE en silencio (Supabase no lo reporta como
                // error). Los datos fiscales NO se guardaron aunque parezca que sí.
                msgTexto = 'Se guardó el nombre/contacto, pero los datos fiscales (RFC, régimen, etc.) NO se guardaron — revisa los permisos (RLS) de la tabla proveedores.';
                msgClase = 'text-xs text-rose-400';
            } else {
                msgTexto = idEdit ? 'Proveedor actualizado.' : 'Proveedor registrado.';
                msgClase = 'text-xs text-emerald-400';
            }

            limpiar();
            await renderizarTablaProveedores();
            msg.textContent = msgTexto;
            msg.className = msgClase;
        } catch (err) {
            msg.textContent = 'No se pudo guardar: ' + (err.message || err);
            msg.className = 'text-xs text-rose-400';
        } finally {
            btnGuardar.disabled = false;
        }
    });

    $('selectFiltroProveedor').addEventListener('change', (e) => {
        const id = e.target.value;
        if (id) window.filtrarComprasProveedor(parseInt(id), e.target.options[e.target.selectedIndex].text);
        else document.getElementById('historialComprasProveedorContainer').innerHTML = 'Elige un proveedor arriba o en la tabla para ver su historial.';
    });

    window.filtrarComprasProveedor = async function (proveedorId, nombreProveedor) {
        const cont = document.getElementById('historialComprasProveedorContainer');
        if (!cont) return;
        cont.innerHTML = `<p class="text-slate-400 text-xs">Cargando compras de ${esc(nombreProveedor)}...</p>`;
        try {
            const { data, error } = await supabaseClient.from('productos')
                .select('nombre, unidades_medida ( nombre ), lotes_inventario ( numero_lote, stock_actual, costo_unitario, fecha_ingreso, monedas ( codigo ) )')
                .eq('proveedor_id', proveedorId);
            if (error) throw error;

            const filas = [];
            (data || []).forEach(prod => (prod.lotes_inventario || []).forEach(l => filas.push({ prod: prod.nombre, u: prod.unidades_medida?.nombre || '', ...l, moneda: l.monedas?.codigo })));
            if (!filas.length) { cont.innerHTML = '<p class="text-slate-400 text-xs">Sin lotes de inventario de este proveedor.</p>'; return; }

            cont.innerHTML = `
                <div class="overflow-x-auto max-h-48 overflow-y-auto border border-slate-800 rounded-xl bg-slate-950 w-full">
                    <table class="w-full text-left text-slate-300 text-xs">
                        <thead class="bg-slate-900 text-sky-400 text-[11px] uppercase border-b border-slate-800 sticky top-0">
                            <tr><th class="p-2.5">Producto</th><th class="p-2.5">Lote</th><th class="p-2.5">Stock</th><th class="p-2.5">Costo unit.</th><th class="p-2.5">Ingreso</th></tr>
                        </thead>
                        <tbody>
                            ${filas.map(f => `
                                <tr class="border-b border-slate-900 hover:bg-slate-900/40">
                                    <td class="p-2.5 font-medium text-slate-100">${esc(f.prod)}</td>
                                    <td class="p-2.5 font-mono text-sky-300">${esc(f.numero_lote || 'S/N')}</td>
                                    <td class="p-2.5 font-mono">${f.stock_actual} ${esc(f.u)}</td>
                                    <td class="p-2.5 font-mono text-slate-300">$${Number(f.costo_unitario || 0).toFixed(2)} <span class="text-[10px] text-slate-500">${esc(f.moneda || 'MXN')}</span></td>
                                    <td class="p-2.5 text-slate-400">${f.fecha_ingreso ? new Date(f.fecha_ingreso).toLocaleDateString() : 'N/D'}</td>
                                </tr>`).join('')}
                        </tbody>
                    </table>
                </div>`;
        } catch (err) {
            cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
        }
    };
}
