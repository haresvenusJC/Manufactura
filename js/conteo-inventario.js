import { supabaseClient } from './supabase.js';
import { accesoOperador } from './patron-login.js';

// ---------------------------------------------------------------------------
//  Conteo de Inventario (móvil, para operadores externos).
//  Se usa de forma anónima: el operador se identifica con nombre + PIN de 4
//  dígitos (el mismo PIN de Orden de Trabajo — sesiones_ot / ot_login) y
//  captura conteos físicos por auditoría abierta.
//  Conteo A CIEGAS: nunca se muestra el stock del sistema, solo lo que el
//  propio operador ha ido acumulando. Cada captura se SUMA (nunca reemplaza)
//  y queda con su hora exacta.
// ---------------------------------------------------------------------------

const KEY = 'auditoria_sesion';
let sesion = null;

const app = () => document.getElementById('app');

function guardarSesion(s) {
    sesion = s;
    try { sessionStorage.setItem(KEY, JSON.stringify(s)); } catch (e) { /* modo privado */ }
}
function salir() {
    sesion = null;
    try { sessionStorage.removeItem(KEY); } catch (e) { /* noop */ }
    pantallaLogin();
}
function esErrorSesion(err) {
    const m = ((err && err.message) || '').toUpperCase();
    return m.includes('SESION_EXPIRADA') || m.includes('JWT') || m.includes('EXPIR');
}
function fmtHora(iso) {
    try { return new Date(iso).toLocaleString('es-MX', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }); }
    catch (e) { return iso || ''; }
}
const escAttr = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// ---------- Cabecera común ----------
function cabecera(titulo) {
    return `
        <div class="flex justify-between items-center mb-3">
            <div>
                <span class="text-sm font-bold text-sky-400 block">${sesion?.nombre || ''}</span>
                ${titulo ? `<span class="text-[11px] text-slate-500">${titulo}</span>` : ''}
            </div>
            <button id="btnSalir" class="text-xs text-slate-400">Salir</button>
        </div>`;
}
function engancharCabecera() {
    const b = document.getElementById('btnSalir');
    if (b) b.onclick = salir;
}

// ---------- Pantalla: identificación ----------
async function pantallaLogin() {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            <h1 class="text-lg font-bold text-sky-400 text-center mb-1">Conteo de Inventario</h1>
            <p class="text-xs text-slate-400 text-center mb-4">Toca tu nombre para empezar a contar.</p>
            <div id="listaEmp" class="grid grid-cols-1 gap-2"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
        </div>`;

    const { data, error } = await supabaseClient
        .from('v_ot_empleados')
        .select('id, nombre')
        .order('nombre', { ascending: true });

    const cont = document.getElementById('listaEmp');
    if (error) { cont.innerHTML = `<p class="text-rose-400 text-sm">${error.message}</p>`; return; }
    if (!data || !data.length) {
        cont.innerHTML = `<p class="text-slate-500 text-sm text-center">No hay empleados con PIN configurado. Pide a administración que te asigne uno.</p>`;
        return;
    }
    cont.innerHTML = data.map(e => `
        <button class="emp-btn bg-slate-900 border border-slate-800 rounded-xl py-4 text-base font-semibold text-slate-100 active:bg-slate-800"
                data-id="${e.id}" data-nombre="${(e.nombre || '').replace(/"/g, '&quot;')}">${e.nombre}</button>
    `).join('');
    cont.querySelectorAll('.emp-btn').forEach(b => {
        b.onclick = () => pantallaPin({ id: Number(b.dataset.id), nombre: b.dataset.nombre });
    });
}

// ---------- Pantalla: PIN / patrón (módulo compartido) ----------
function pantallaPin(emp) {
    accesoOperador(app(), emp, {
        volver: pantallaLogin,
        alEntrar: (fila) => {
            guardarSesion({ token: fila.token, empleadoId: fila.empleado_id, nombre: fila.empleado_nombre });
            pantallaAuditorias();
        }
    });
}

// ---------- Pantalla: auditorías abiertas ----------
async function pantallaAuditorias() {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera('Elige la auditoría')}
            <div id="listaAud" class="grid grid-cols-1 gap-2"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
        </div>`;
    engancharCabecera();

    const { data, error } = await supabaseClient
        .from('v_auditorias_abiertas')
        .select('*');

    const cont = document.getElementById('listaAud');
    if (error) { cont.innerHTML = `<p class="text-rose-400 text-sm">${error.message}</p>`; return; }
    if (!data || !data.length) {
        cont.innerHTML = `<p class="text-slate-500 text-sm text-center">No hay auditorías abiertas en este momento.</p>`;
        return;
    }
    cont.innerHTML = data.map(a => `
        <button class="aud-btn bg-slate-900 border border-slate-800 rounded-xl p-4 text-left active:bg-slate-800" data-id="${a.id}" data-nombre="${(a.nombre || '').replace(/"/g, '&quot;')}">
            <span class="block text-base font-semibold text-slate-100">${a.nombre}</span>
            <span class="block text-xs text-slate-500 mt-1">${a.fecha} · ${a.items_con_conteo}/${a.total_items} contados</span>
        </button>
    `).join('');
    cont.querySelectorAll('.aud-btn').forEach(b => {
        b.onclick = () => pantallaItems({ id: Number(b.dataset.id), nombre: b.dataset.nombre });
    });
}

// ---------- Pantalla: items de la auditoría ----------
async function pantallaItems(aud) {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera(aud.nombre)}
            <div class="flex justify-between items-center mb-2">
                <button id="volverAud" class="text-xs text-slate-400">‹ Otra auditoría</button>
                <button id="verResumenMio" class="text-xs text-sky-400 font-semibold">📋 Ver mi resumen</button>
            </div>
            <div id="listaItems" class="grid grid-cols-1 gap-2"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
        </div>`;
    engancharCabecera();
    document.getElementById('volverAud').onclick = pantallaAuditorias;
    document.getElementById('verResumenMio').onclick = () => pantallaResumen(aud);

    const { data, error } = await supabaseClient
        .from('v_auditoria_items_operador')
        .select('*')
        .eq('auditoria_id', aud.id)
        .order('descripcion', { ascending: true });

    const cont = document.getElementById('listaItems');
    if (error) {
        if (esErrorSesion(error)) { salir(); return; }
        cont.innerHTML = `<p class="text-rose-400 text-sm">${error.message}</p>`;
        return;
    }
    if (!data || !data.length) {
        cont.innerHTML = `<p class="text-slate-500 text-sm text-center">Esta auditoría no tiene renglones que contar.</p>`;
        return;
    }
    cont.innerHTML = data.map(it => `
        <button class="item-btn bg-slate-900 border border-slate-800 rounded-xl p-4 text-left active:bg-slate-800" data-id="${it.item_id}">
            <span class="block text-base font-semibold text-slate-100">${it.descripcion}</span>
            <span class="block text-xs text-slate-500 mt-1">${it.sku ? 'SKU ' + it.sku + ' · ' : ''}${it.unidad_nombre || ''}</span>
            <span class="block text-xs text-emerald-400 mt-1">Llevas capturado: ${Number(it.acumulado).toLocaleString('es-MX', { maximumFractionDigits: 4 })}</span>
        </button>
    `).join('');
    cont.querySelectorAll('.item-btn').forEach(b => {
        const it = data.find(x => x.item_id === Number(b.dataset.id));
        b.onclick = () => pantallaCapturar(aud, it);
    });
}

// ---------- Pantalla: resumen de mis capturas (ver, editar, borrar) ----------
async function pantallaResumen(aud) {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera(aud.nombre)}
            <button id="volverItemsDesdeResumen" class="text-xs text-slate-400 mb-2">‹ Volver a los renglones</button>
            <h2 class="text-base font-bold text-slate-100 mb-1">Resumen de mis capturas</h2>
            <p class="text-xs text-slate-500 mb-3">Revisa y corrige tus cantidades, notas y caducidades antes de enviar tu conteo.</p>
            <div id="bannerConfirmado"></div>
            <div id="listaResumen"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
            <div id="wrapConfirmarEnvio"></div>
        </div>`;
    engancharCabecera();
    document.getElementById('volverItemsDesdeResumen').onclick = () => pantallaItems(aud);

    const [rConf, rCap] = await Promise.all([
        supabaseClient.rpc('mi_confirmacion_auditoria', { p_token: sesion.token, p_auditoria_id: aud.id }),
        supabaseClient.rpc('mis_capturas_auditoria', { p_token: sesion.token, p_auditoria_id: aud.id }),
    ]);
    const cont = document.getElementById('listaResumen');
    const errAlgo = rConf.error || rCap.error;
    if (errAlgo) {
        if (esErrorSesion(errAlgo)) { salir(); return; }
        cont.innerHTML = `<p class="text-rose-400 text-sm">${errAlgo.message}</p>`;
        return;
    }

    const confirmadoEn = rConf.data;
    if (confirmadoEn) {
        document.getElementById('bannerConfirmado').innerHTML = `
            <div class="bg-emerald-950/40 border border-emerald-800 rounded-lg px-3 py-2 mb-3 text-xs text-emerald-300">
                ✔ Ya enviaste y confirmaste tu conteo de esta auditoría el ${fmtHora(confirmadoEn)}.
            </div>`;
    }

    pintarResumen(aud, rCap.data || [], !confirmadoEn);
}

function pintarResumen(aud, capturas, editable) {
    const cont = document.getElementById('listaResumen');
    const wrapBtn = document.getElementById('wrapConfirmarEnvio');
    if (!capturas.length) {
        cont.innerHTML = '<p class="text-slate-500 text-sm text-center">Todavía no has capturado ningún conteo en esta auditoría.</p>';
        if (wrapBtn) wrapBtn.innerHTML = '';
        return;
    }

    const porItem = new Map();
    capturas.forEach((c) => {
        if (!porItem.has(c.item_id)) porItem.set(c.item_id, { descripcion: c.descripcion, sku: c.sku, unidad_nombre: c.unidad_nombre, capturas: [] });
        porItem.get(c.item_id).capturas.push(c);
    });

    cont.innerHTML = Array.from(porItem.values()).map((it) => {
        const total = it.capturas.reduce((a, c) => a + Number(c.cantidad_equivalente || 0), 0);
        const unidad = it.unidad_nombre || 'pieza';
        return `
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-3 mb-2.5">
            <div class="flex justify-between items-start">
                <span class="text-sm font-semibold text-slate-100">${it.descripcion}</span>
                <span class="text-sm text-emerald-400 font-semibold whitespace-nowrap ml-2">${total.toLocaleString('es-MX', { maximumFractionDigits: 4 })} ${unidad}</span>
            </div>
            <span class="block text-[11px] text-slate-500 mb-2">${it.sku ? 'SKU ' + it.sku : ''}</span>
            <div class="space-y-2">
                ${it.capturas.map((c) => editable ? filaEditableCaptura(c, unidad) : filaSoloLecturaCaptura(c, unidad)).join('')}
            </div>
        </div>`;
    }).join('');

    if (editable) {
        cont.querySelectorAll('.res-tipo').forEach((sel) => {
            sel.onchange = () => {
                const wrap = sel.closest('.res-fila').querySelector('.res-wrap-ppc');
                if (wrap) wrap.classList.toggle('hidden', sel.value !== 'caja');
            };
        });
        cont.querySelectorAll('.res-guardar').forEach((btn) => { btn.onclick = () => guardarEdicionCaptura(aud, btn); });
        cont.querySelectorAll('.res-eliminar').forEach((btn) => { btn.onclick = () => eliminarCaptura(aud, btn); });
    }

    if (wrapBtn) {
        wrapBtn.innerHTML = editable
            ? `<button id="btnConfirmarEnvio" class="w-full mt-1 bg-emerald-600 active:bg-emerald-700 text-white font-semibold rounded-xl py-3 text-sm">✅ Confirmar y enviar mi conteo</button>`
            : '';
        const b = document.getElementById('btnConfirmarEnvio');
        if (b) b.onclick = () => pantallaConfirmarEnvio(aud);
    }
}

function filaSoloLecturaCaptura(c, unidad) {
    return `
        <div class="bg-slate-950/60 border border-slate-800 rounded-lg px-2.5 py-1.5 text-[11px]">
            <div class="flex justify-between items-center">
                <span class="text-slate-300">${c.cantidad} ${c.tipo_captura === 'caja' ? `caja(s) × ${c.piezas_por_caja}` : `${unidad}(s)`} = <b class="text-slate-100">${c.cantidad_equivalente}</b></span>
                <span class="text-slate-500">${fmtHora(c.capturado_en)}</span>
            </div>
            ${c.nota ? `<div class="text-slate-400 mt-0.5">📝 ${c.nota}</div>` : ''}
            ${c.fecha_caducidad ? `<div class="text-amber-400 mt-0.5">Caduca: ${c.fecha_caducidad}</div>` : ''}
        </div>`;
}

function filaEditableCaptura(c, unidad) {
    return `
        <div class="res-fila bg-slate-950/60 border border-slate-800 rounded-lg px-2.5 py-2 text-[11px]" data-conteo-id="${c.conteo_id}">
            <div class="flex justify-between items-center mb-1.5">
                <span class="text-slate-500">${fmtHora(c.capturado_en)}</span>
                <button type="button" class="res-eliminar text-rose-400 hover:text-rose-300 text-[10px] px-2 py-0.5 bg-rose-950/40 rounded border border-rose-900/50">🗑️ Borrar</button>
            </div>
            <div class="grid grid-cols-2 gap-1.5 mb-1.5">
                <input type="number" step="0.0001" min="0" value="${c.cantidad}" class="res-cantidad bg-slate-900 border border-slate-800 rounded p-1.5 text-center text-slate-100">
                <select class="res-tipo bg-slate-900 border border-slate-800 rounded p-1.5 text-slate-100">
                    <option value="pieza" ${c.tipo_captura !== 'caja' ? 'selected' : ''}>Sueltos / ${escAttr(unidad)}</option>
                    <option value="caja" ${c.tipo_captura === 'caja' ? 'selected' : ''}>Por caja</option>
                </select>
            </div>
            <div class="res-wrap-ppc mb-1.5 ${c.tipo_captura === 'caja' ? '' : 'hidden'}">
                <input type="number" step="0.0001" min="0.0001" value="${c.piezas_por_caja}" placeholder="¿Cuántos ${escAttr(unidad)} trae cada caja?" class="res-ppc w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-center text-slate-100">
            </div>
            <input type="text" value="${escAttr(c.nota || '')}" placeholder="Nota (opcional)" class="res-nota w-full bg-slate-900 border border-slate-800 rounded p-1.5 mb-1.5 text-slate-100">
            <input type="date" value="${c.fecha_caducidad || ''}" class="res-caducidad w-full bg-slate-900 border border-slate-800 rounded p-1.5 mb-1.5 text-slate-100">
            <p class="res-msg text-[10px] h-3 text-rose-400"></p>
            <button type="button" class="res-guardar w-full bg-sky-700 hover:bg-sky-600 text-white font-medium rounded py-1.5 text-[11px]">💾 Guardar cambios</button>
        </div>`;
}

async function guardarEdicionCaptura(aud, btn) {
    const fila = btn.closest('.res-fila');
    const conteoId = Number(fila.dataset.conteoId);
    const cantidad = parseFloat(fila.querySelector('.res-cantidad').value);
    const tipo = fila.querySelector('.res-tipo').value;
    const ppc = tipo === 'caja' ? parseFloat(fila.querySelector('.res-ppc').value) : 1;
    const nota = fila.querySelector('.res-nota').value.trim();
    const fechaCaducidad = fila.querySelector('.res-caducidad').value;
    const msg = fila.querySelector('.res-msg');
    msg.textContent = '';
    if (!Number.isFinite(cantidad) || cantidad <= 0) { msg.textContent = 'Cantidad inválida.'; return; }
    if (tipo === 'caja' && (!Number.isFinite(ppc) || ppc <= 0)) { msg.textContent = 'Indica cuántos trae cada caja.'; return; }

    btn.disabled = true; btn.textContent = 'Guardando...';
    const { error } = await supabaseClient.rpc('editar_conteo_auditoria', {
        p_token: sesion.token, p_conteo_id: conteoId, p_cantidad: cantidad,
        p_tipo_captura: tipo, p_piezas_por_caja: ppc, p_nota: nota || null,
        p_fecha_caducidad: fechaCaducidad || null,
    });
    if (error) {
        if (esErrorSesion(error)) { salir(); return; }
        msg.textContent = error.message;
        btn.disabled = false; btn.textContent = '💾 Guardar cambios';
        return;
    }
    await pantallaResumen(aud);
}

async function eliminarCaptura(aud, btn) {
    if (!confirm('¿Borrar esta captura? No se puede deshacer.')) return;
    const fila = btn.closest('.res-fila');
    const conteoId = Number(fila.dataset.conteoId);
    btn.disabled = true;
    const { error } = await supabaseClient.rpc('eliminar_conteo_auditoria', {
        p_token: sesion.token, p_conteo_id: conteoId,
    });
    if (error) {
        if (esErrorSesion(error)) { salir(); return; }
        alert(error.message);
        btn.disabled = false;
        return;
    }
    await pantallaResumen(aud);
}

// ---------- Pantalla: pre-resumen final + confirmación antes de enviar ----------
async function pantallaConfirmarEnvio(aud) {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera(aud.nombre)}
            <h2 class="text-base font-bold text-slate-100 mb-1">Confirmar envío de tu conteo</h2>
            <p class="text-xs text-slate-500 mb-3">Este es tu resumen final. Revísalo con cuidado antes de confirmar.</p>
            <div id="preResumenFinal"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
            <p class="text-sm text-amber-300 font-semibold text-center my-3">¿Estás seguro de que estos datos son correctos?</p>
            <div class="flex gap-2">
                <button id="btnVolverAEditar" class="flex-1 bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 rounded-lg text-sm">‹ Revisar de nuevo</button>
                <button id="btnEnviarDefinitivo" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2.5 rounded-lg text-sm">Sí, enviar</button>
            </div>
            <p id="envioMsg" class="text-xs text-center mt-2 min-h-[1rem]"></p>
        </div>`;
    engancharCabecera();
    document.getElementById('btnVolverAEditar').onclick = () => pantallaResumen(aud);

    const cont = document.getElementById('preResumenFinal');
    const { data, error } = await supabaseClient.rpc('mis_capturas_auditoria', {
        p_token: sesion.token, p_auditoria_id: aud.id,
    });
    if (error) {
        if (esErrorSesion(error)) { salir(); return; }
        cont.innerHTML = `<p class="text-rose-400 text-sm">${error.message}</p>`;
        return;
    }

    const porItem = new Map();
    (data || []).forEach((c) => {
        if (!porItem.has(c.item_id)) porItem.set(c.item_id, { descripcion: c.descripcion, sku: c.sku, unidad_nombre: c.unidad_nombre, total: 0, n: 0 });
        const it = porItem.get(c.item_id);
        it.total += Number(c.cantidad_equivalente || 0);
        it.n += 1;
    });
    cont.innerHTML = Array.from(porItem.values()).map((it) => `
        <div class="bg-slate-900 border border-slate-800 rounded-lg px-3 py-2 mb-1.5 flex justify-between items-center text-xs">
            <div>
                <span class="block text-slate-100 font-medium">${it.descripcion}</span>
                <span class="block text-[10px] text-slate-500">${it.sku ? 'SKU ' + it.sku + ' · ' : ''}${it.n} captura(s)</span>
            </div>
            <span class="text-emerald-400 font-semibold whitespace-nowrap ml-2">${it.total.toLocaleString('es-MX', { maximumFractionDigits: 4 })} ${it.unidad_nombre || 'pieza'}</span>
        </div>`).join('') || '<p class="text-slate-500 text-sm text-center">Sin capturas.</p>';

    document.getElementById('btnEnviarDefinitivo').onclick = async () => {
        const btn = document.getElementById('btnEnviarDefinitivo');
        const msg = document.getElementById('envioMsg');
        btn.disabled = true; btn.textContent = 'Enviando...';
        const { error: eConf } = await supabaseClient.rpc('confirmar_mi_conteo', {
            p_token: sesion.token, p_auditoria_id: aud.id,
        });
        if (eConf) {
            if (esErrorSesion(eConf)) { salir(); return; }
            msg.textContent = eConf.message;
            msg.className = 'text-xs text-center mt-2 text-rose-400';
            btn.disabled = false; btn.textContent = 'Sí, enviar';
            return;
        }
        app().innerHTML = `
            <div class="p-4 max-w-md mx-auto text-center">
                ${cabecera(aud.nombre)}
                <div class="bg-emerald-950/40 border border-emerald-800 rounded-xl p-6 mt-6">
                    <p class="text-3xl mb-2">✔</p>
                    <p class="text-base font-semibold text-emerald-300">¡Conteo enviado!</p>
                    <p class="text-xs text-slate-400 mt-1">Gracias, tu conteo de esta auditoría ya quedó confirmado.</p>
                </div>
                <button id="btnAOtraAuditoria" class="w-full mt-4 bg-slate-800 hover:bg-slate-700 text-slate-200 font-medium py-2.5 rounded-lg text-sm">Ir a otra auditoría</button>
            </div>`;
        engancharCabecera();
        document.getElementById('btnAOtraAuditoria').onclick = pantallaAuditorias;
    };
}

// ---------- Pantalla: capturar conteo de un item ----------
async function pantallaCapturar(aud, item) {
    let tipo = 'pieza';
    let capturas = [];

    async function cargarCapturas() {
        const { data, error } = await supabaseClient.rpc('capturas_item_auditoria', {
            p_token: sesion.token, p_item_id: item.item_id,
        });
        if (!error) capturas = data || [];
    }

    function totalAcumulado() {
        return capturas.reduce((a, c) => a + Number(c.cantidad_equivalente || 0), 0);
    }

    function render(msg = '', msgOk = false) {
        const unidad = item.unidad_nombre || 'pieza';
        app().innerHTML = `
            <div class="p-4 max-w-md mx-auto">
                ${cabecera(aud.nombre)}
                <div class="flex justify-between items-center mb-2">
                    <button id="volverItems" class="text-xs text-slate-400">‹ Otro renglón</button>
                    <button id="verResumenMio" class="text-xs text-sky-400 font-semibold">📋 Ver mi resumen</button>
                </div>
                <div class="bg-slate-900 border border-slate-800 rounded-xl p-4 mb-3">
                    <span class="block text-base font-semibold text-slate-100">${item.descripcion}</span>
                    <span class="block text-xs text-slate-500 mt-1">${item.sku ? 'SKU ' + item.sku + ' · ' : ''}${unidad}</span>
                    <span class="block text-sm text-emerald-400 mt-2 font-semibold">Acumulado hasta ahora: ${totalAcumulado().toLocaleString('es-MX', { maximumFractionDigits: 4 })} ${unidad}</span>
                </div>

                <div class="bg-slate-900 border border-slate-800 rounded-xl p-4 mb-3 space-y-3">
                    <div>
                        <label class="block text-xs text-slate-400 mb-1">Cantidad (en ${unidad})</label>
                        <input id="capCantidad" type="number" step="0.0001" min="0" inputmode="decimal"
                               class="w-full bg-slate-950 border border-slate-800 rounded-lg p-3 text-lg text-slate-100 text-center" placeholder="0">
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <button id="tipoPieza" class="tipo-btn rounded-lg py-2.5 text-sm font-semibold border ${tipo === 'pieza' ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-950 border-slate-800 text-slate-300'}">Sueltos / ${unidad}</button>
                        <button id="tipoCaja" class="tipo-btn rounded-lg py-2.5 text-sm font-semibold border ${tipo === 'caja' ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-950 border-slate-800 text-slate-300'}">Por caja</button>
                    </div>
                    <div id="wrapPpc" class="${tipo === 'caja' ? '' : 'hidden'}">
                        <label class="block text-xs text-slate-400 mb-1">¿Cuántos ${unidad} trae cada caja?</label>
                        <input id="capPpc" type="number" step="0.0001" min="0.0001" inputmode="decimal"
                               class="w-full bg-slate-950 border border-slate-800 rounded-lg p-3 text-lg text-slate-100 text-center" placeholder="Ej. 24" value="1">
                    </div>
                    <div>
                        <label class="block text-xs text-slate-400 mb-1">Fecha de caducidad de este lote (opcional)</label>
                        <input id="capCaducidad" type="date" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2.5 text-sm text-slate-100">
                    </div>
                    <div>
                        <label class="block text-xs text-slate-400 mb-1">Nota (opcional)</label>
                        <input id="capNota" type="text" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2.5 text-sm text-slate-100" placeholder="Ej. tarima 2, anaquel B">
                    </div>
                    <p class="text-xs h-4 text-center ${msgOk ? 'text-emerald-400' : 'text-rose-400'}">${msg}</p>
                    <button id="btnRegistrar" class="w-full bg-emerald-600 active:bg-emerald-700 text-white font-semibold rounded-xl py-3 text-base">Registrar conteo</button>
                </div>

                <div>
                    <p class="text-xs text-slate-400 mb-2">Tus capturas de este renglón</p>
                    <div class="space-y-1.5">
                        ${capturas.length ? capturas.map(c => `
                            <div class="bg-slate-900/60 border border-slate-800 rounded-lg px-3 py-2 text-xs">
                                <div class="flex justify-between items-center">
                                    <span class="text-slate-300">${c.cantidad} ${c.tipo_captura === 'caja' ? `caja(s) × ${c.piezas_por_caja}` : `${unidad}(s)`} = <b class="text-slate-100">${c.cantidad_equivalente}</b></span>
                                    <span class="text-slate-500">${fmtHora(c.capturado_en)}</span>
                                </div>
                                ${c.fecha_caducidad ? `<div class="text-amber-400 mt-1">Caduca: ${c.fecha_caducidad}</div>` : ''}
                            </div>`).join('') : '<p class="text-slate-600 text-xs text-center">Sin capturas todavía.</p>'}
                    </div>
                </div>
            </div>`;

        engancharCabecera();
        document.getElementById('volverItems').onclick = () => pantallaItems(aud);
        document.getElementById('verResumenMio').onclick = () => pantallaResumen(aud);
        document.getElementById('tipoPieza').onclick = () => { tipo = 'pieza'; render(); };
        document.getElementById('tipoCaja').onclick = () => { tipo = 'caja'; render(); };

        document.getElementById('btnRegistrar').onclick = async () => {
            const cantidad = parseFloat(document.getElementById('capCantidad').value);
            const ppc = tipo === 'caja' ? parseFloat(document.getElementById('capPpc').value) : 1;
            const nota = document.getElementById('capNota').value.trim();
            const fechaCaducidad = document.getElementById('capCaducidad').value;
            if (!Number.isFinite(cantidad) || cantidad <= 0) { render('Captura una cantidad mayor a cero.'); return; }
            if (tipo === 'caja' && (!Number.isFinite(ppc) || ppc <= 0)) { render('Captura cuántas piezas trae cada caja.'); return; }

            const btn = document.getElementById('btnRegistrar');
            btn.disabled = true; btn.textContent = 'Guardando...';

            const { error } = await supabaseClient.rpc('registrar_conteo_auditoria', {
                p_token: sesion.token, p_item_id: item.item_id, p_cantidad: cantidad,
                p_tipo_captura: tipo, p_piezas_por_caja: ppc, p_nota: nota || null,
                p_fecha_caducidad: fechaCaducidad || null,
            });
            if (error) {
                if (esErrorSesion(error)) { salir(); return; }
                render(error.message, false);
                return;
            }
            await cargarCapturas();
            render('✔ Conteo registrado.', true);
        };
    }

    await cargarCapturas();
    render();
}

document.addEventListener('DOMContentLoaded', () => {
    try { sesion = JSON.parse(sessionStorage.getItem(KEY) || 'null'); } catch (e) { sesion = null; }
    if (sesion && sesion.token) pantallaAuditorias();
    else pantallaLogin();
});
