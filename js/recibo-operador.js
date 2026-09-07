import { supabaseClient } from './supabase.js';

// ---------------------------------------------------------------------------
//  Pre-recibo de mercancía (móvil, para operadores de almacén).
//  Anónimo: el operador se identifica con nombre + PIN de 4 dígitos (mismo
//  ot_login que la Orden de Trabajo). Elige la orden de compra que recibe,
//  toma foto(s) del documento, confirma que todo cuadra y lo envía. El
//  admin lo valida desde "Recibo de mercancía".
//  Lecturas por vistas públicas (v_recibo_*), escritura por RPC
//  prerecibo_crear. NO se muestran costos.
//  Requiere sql/2026-09-11_prerecibo_operador.sql.
// ---------------------------------------------------------------------------

const KEY = 'prerecibo_sesion';
let sesion = null;
let fotos = [];   // data-URI base64 comprimidas

const app = () => document.getElementById('app');
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function guardarSesion(s) {
    sesion = s;
    try { sessionStorage.setItem(KEY, JSON.stringify(s)); } catch (e) { /* modo privado */ }
}
function cargarSesion() {
    try { sesion = JSON.parse(sessionStorage.getItem(KEY) || 'null'); } catch (e) { sesion = null; }
    return sesion;
}
function salir() {
    sesion = null; fotos = [];
    try { sessionStorage.removeItem(KEY); } catch (e) { /* noop */ }
    pantallaLogin();
}

function cabecera() {
    return `
        <div class="flex justify-between items-center mb-3">
            <span class="text-sm font-bold text-sky-400">${esc(sesion?.nombre || '')}</span>
            <button id="btnSalir" class="text-xs text-slate-400">Salir</button>
        </div>`;
}
function engancharCabecera() {
    const b = document.getElementById('btnSalir');
    if (b) b.onclick = salir;
}

// ---------- comprimir foto antes de mandarla ----------
// Documento (remito/factura): se reescala a 1100 px de lado mayor y se
// codifica en WebP con calidad baja — es el formato más pequeño para
// este tipo de imagen (~30% menos que JPEG a calidad equivalente). Si el
// navegador no sabe codificar WebP (iOS viejo), cae a JPEG.
function comprimirImagen(file, maxLado = 1100, calidad = 0.5) {
    return new Promise((resolve, reject) => {
        const rd = new FileReader();
        rd.onerror = () => reject(new Error('No se pudo leer la imagen.'));
        rd.onload = () => {
            const img = new Image();
            img.onerror = () => reject(new Error('Imagen no válida.'));
            img.onload = () => {
                let w = img.width, h = img.height;
                if (w > maxLado || h > maxLado) {
                    const r = Math.min(maxLado / w, maxLado / h);
                    w = Math.round(w * r); h = Math.round(h * r);
                }
                const c = document.createElement('canvas');
                c.width = w; c.height = h;
                const ctx = c.getContext('2d');
                ctx.fillStyle = '#ffffff';           // fondo blanco si el origen tiene transparencia
                ctx.fillRect(0, 0, w, h);
                ctx.drawImage(img, 0, 0, w, h);

                let durl = c.toDataURL('image/webp', calidad);
                if (durl.indexOf('data:image/webp') !== 0) {          // navegador sin WebP -> JPEG
                    durl = c.toDataURL('image/jpeg', Math.min(calidad + 0.1, 0.7));
                }
                resolve(durl);
            };
            img.src = rd.result;
        };
        rd.readAsDataURL(file);
    });
}

// ---------- Pantalla: identificación ----------
async function pantallaLogin() {
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            <h1 class="text-lg font-bold text-sky-400 text-center mb-1">Pre-recibo de mercancía</h1>
            <p class="text-xs text-slate-400 text-center mb-4">Toca tu nombre para empezar.</p>
            <div id="listaEmp" class="grid grid-cols-1 gap-2"><p class="text-slate-500 text-sm text-center">Cargando...</p></div>
        </div>`;

    const { data, error } = await supabaseClient
        .from('v_ot_empleados').select('id, nombre').order('nombre', { ascending: true });

    const cont = document.getElementById('listaEmp');
    if (error) { cont.innerHTML = `<p class="text-rose-400 text-sm">${esc(error.message)}</p>`; return; }
    if (!data || !data.length) {
        cont.innerHTML = `<p class="text-slate-500 text-sm text-center">No hay empleados con PIN configurado. Pide a administración que te asigne uno.</p>`;
        return;
    }
    cont.innerHTML = data.map(e => `
        <button class="emp-btn bg-slate-900 border border-slate-800 rounded-xl py-4 text-base font-semibold text-slate-100 active:bg-slate-800"
                data-id="${e.id}" data-nombre="${esc(e.nombre)}">${esc(e.nombre)}</button>`).join('');
    cont.querySelectorAll('.emp-btn').forEach(b => {
        b.onclick = () => pantallaPin({ id: Number(b.dataset.id), nombre: b.dataset.nombre });
    });
}

// ---------- Pantalla: PIN ----------
function pantallaPin(emp) {
    let pin = '';
    const render = (msg = '') => {
        app().innerHTML = `
            <div class="p-4 max-w-xs mx-auto">
                <button id="volver" class="text-xs text-slate-400 mb-2">‹ Volver</button>
                <h2 class="text-base font-bold text-slate-100 text-center mb-1">${esc(emp.nombre)}</h2>
                <p class="text-xs text-slate-400 text-center mb-3">Ingresa tu PIN de 4 dígitos</p>
                <div class="flex justify-center gap-3 mb-4">
                    ${[0, 1, 2, 3].map(i => `<span class="w-4 h-4 rounded-full ${i < pin.length ? 'bg-sky-400' : 'bg-slate-700'}"></span>`).join('')}
                </div>
                <p class="text-rose-400 text-xs text-center h-4 mb-2">${esc(msg)}</p>
                <div class="grid grid-cols-3 gap-2">
                    ${[1, 2, 3, 4, 5, 6, 7, 8, 9].map(n => `<button class="tecla bg-slate-900 border border-slate-800 rounded-xl py-4 text-xl text-slate-100 active:bg-slate-800" data-n="${n}">${n}</button>`).join('')}
                    <button class="bg-transparent" disabled></button>
                    <button class="tecla bg-slate-900 border border-slate-800 rounded-xl py-4 text-xl text-slate-100 active:bg-slate-800" data-n="0">0</button>
                    <button id="borrar" class="bg-slate-900 border border-slate-800 rounded-xl py-4 text-xl text-slate-300 active:bg-slate-800">⌫</button>
                </div>
            </div>`;
        document.getElementById('volver').onclick = pantallaLogin;
        document.getElementById('borrar').onclick = () => { pin = pin.slice(0, -1); render(); };
        document.querySelectorAll('.tecla').forEach(t => {
            t.onclick = async () => {
                if (pin.length >= 4) return;
                pin += t.dataset.n;
                if (pin.length < 4) { render(); return; }
                render('Verificando...');
                const { data, error } = await supabaseClient.rpc('ot_login', { p_empleado_id: emp.id, p_pin: pin });
                const fila = Array.isArray(data) ? data[0] : data;
                if (error || !fila) { pin = ''; render(error ? error.message : 'PIN incorrecto'); return; }
                guardarSesion({ token: fila.token, empleadoId: fila.empleado_id, nombre: fila.empleado_nombre });
                pantallaFormulario();
            };
        });
    };
    render();
}

// ---------- Pantalla: formulario de pre-recibo ----------
async function pantallaFormulario() {
    fotos = [];
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera()}
            <h2 class="text-sm font-bold text-slate-200 mb-2">Nuevo pre-recibo</h2>

            <label class="block text-xs text-slate-400 mb-1">Orden de compra</label>
            <select id="prOc" class="w-full bg-slate-900 border border-slate-800 rounded-xl p-3 text-sm text-slate-100 mb-2">
                <option value="">Cargando órdenes...</option>
            </select>

            <div id="prSinOc" class="hidden mb-2">
                <label class="block text-xs text-slate-400 mb-1">Referencia del documento (remisión / factura)</label>
                <input type="text" id="prRef" placeholder="Ej. REM-4821" class="w-full bg-slate-900 border border-slate-800 rounded-xl p-3 text-sm text-slate-100">
            </div>

            <div id="prLineas" class="text-xs text-slate-400 mb-3"></div>

            <label class="block text-xs text-slate-400 mb-1">Foto(s) del documento</label>
            <input type="file" id="prFoto" accept="image/*" capture="environment" class="hidden">
            <button type="button" id="prTomarFoto" class="w-full bg-slate-800 border border-slate-700 rounded-xl py-3 text-sm text-sky-300 active:bg-slate-700 mb-2">📷 Tomar / elegir foto</button>
            <div id="prFotos" class="grid grid-cols-3 gap-2 mb-3"></div>

            <label class="flex items-start gap-2 text-sm text-slate-200 bg-slate-900 border border-slate-800 rounded-xl p-3 mb-2">
                <input type="checkbox" id="prOk" class="accent-emerald-500 w-5 h-5 mt-0.5 shrink-0">
                <span>Confirmo que revisé la mercancía física contra el documento y <strong>todo está correcto</strong>.</span>
            </label>

            <label class="block text-xs text-slate-400 mb-1">Observaciones (si algo no cuadra)</label>
            <textarea id="prObs" rows="3" placeholder="Ej. faltaron 2 cajas de la partida 3" class="w-full bg-slate-900 border border-slate-800 rounded-xl p-3 text-sm text-slate-100 mb-3"></textarea>

            <p id="prMsg" class="text-xs text-rose-400 text-center min-h-[1rem] mb-2"></p>
            <button type="button" id="prEnviar" class="w-full bg-emerald-600 active:bg-emerald-700 text-white font-semibold py-3 rounded-xl text-sm">Enviar pre-recibo</button>
        </div>`;
    engancharCabecera();

    // cargar OCs
    const selOc = document.getElementById('prOc');
    const { data: ocs, error } = await supabaseClient
        .from('v_recibo_ocs')
        .select('id, folio, proveedor_nombre, fecha_esperada, estatus, partidas')
        .order('fecha_esperada', { ascending: true });
    if (error) {
        selOc.innerHTML = `<option value="">— (error al cargar) —</option>`;
        document.getElementById('prMsg').textContent = /does not exist|schema cache|could not find/i.test(error.message || '')
            ? 'Falta correr sql/2026-09-11_prerecibo_operador.sql en Supabase.'
            : error.message;
    } else {
        selOc.innerHTML = `<option value="">— elige una orden —</option>`
            + (ocs || []).map(o => `<option value="${o.id}">${esc(o.folio || '#' + o.id)} · ${esc(o.proveedor_nombre || 's/proveedor')} · ${o.partidas} part.</option>`).join('')
            + `<option value="__sinoc__">Sin orden de compra (referencia libre)</option>`;
    }

    selOc.onchange = () => {
        const v = selOc.value;
        document.getElementById('prSinOc').classList.toggle('hidden', v !== '__sinoc__');
        pintarLineas(v && v !== '__sinoc__' ? Number(v) : null);
    };

    // foto
    const inputFoto = document.getElementById('prFoto');
    document.getElementById('prTomarFoto').onclick = () => inputFoto.click();
    inputFoto.onchange = async () => {
        const file = inputFoto.files && inputFoto.files[0];
        inputFoto.value = '';
        if (!file) return;
        if (fotos.length >= 5) { document.getElementById('prMsg').textContent = 'Máximo 5 fotos.'; return; }
        document.getElementById('prMsg').textContent = 'Procesando foto...';
        try {
            const durl = await comprimirImagen(file);
            fotos.push(durl);
            document.getElementById('prMsg').textContent = '';
            pintarFotos();
        } catch (e) {
            document.getElementById('prMsg').textContent = e.message || 'No se pudo procesar la foto.';
        }
    };

    document.getElementById('prEnviar').onclick = enviar;
}

async function pintarLineas(ocId) {
    const cont = document.getElementById('prLineas');
    if (!cont) return;
    if (!ocId) { cont.innerHTML = ''; return; }
    cont.innerHTML = 'Cargando partidas...';
    const { data, error } = await supabaseClient
        .from('v_recibo_oc_lineas')
        .select('descripcion, cantidad, cantidad_recibida, unidad')
        .eq('orden_compra_id', ocId);
    if (error) { cont.innerHTML = ''; return; }
    if (!data || !data.length) { cont.innerHTML = '<span class="text-slate-500">Sin partidas.</span>'; return; }
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-2 mt-1">
            <p class="text-[11px] text-slate-500 mb-1">Lo que dice la orden:</p>
            ${data.map(l => `<div class="flex justify-between py-0.5 border-b border-slate-800/60 last:border-0">
                <span class="text-slate-300">${esc(l.descripcion)}</span>
                <span class="text-slate-400 font-mono">${l.cantidad}${l.cantidad_recibida > 0 ? ` (${l.cantidad_recibida} ya recib.)` : ''} ${esc(l.unidad || '')}</span>
            </div>`).join('')}
        </div>`;
}

function pintarFotos() {
    const cont = document.getElementById('prFotos');
    if (!cont) return;
    cont.innerHTML = fotos.map((f, i) => `
        <div class="relative">
            <img src="${f}" class="w-full h-20 object-cover rounded-lg border border-slate-700">
            <button type="button" data-i="${i}" class="pr-quita absolute -top-2 -right-2 bg-rose-600 text-white w-6 h-6 rounded-full text-xs leading-none">✕</button>
        </div>`).join('');
    cont.querySelectorAll('.pr-quita').forEach(b => b.onclick = () => {
        fotos.splice(Number(b.dataset.i), 1); pintarFotos();
    });
}

async function enviar() {
    const msg = document.getElementById('prMsg');
    const btn = document.getElementById('prEnviar');
    const selOc = document.getElementById('prOc');
    const sinOc = selOc.value === '__sinoc__';
    const ocId = (!sinOc && selOc.value) ? Number(selOc.value) : null;
    const ref = document.getElementById('prRef')?.value || '';

    if (!ocId && !sinOc) { msg.textContent = 'Elige una orden de compra.'; return; }
    if (sinOc && !ref.trim()) { msg.textContent = 'Escribe la referencia del documento.'; return; }
    if (fotos.length === 0) { msg.textContent = 'Toma al menos una foto del documento.'; return; }
    if (!document.getElementById('prOk').checked && !document.getElementById('prObs').value.trim()) {
        msg.textContent = 'Marca "todo correcto" o escribe qué no cuadra en observaciones.'; return;
    }

    btn.disabled = true; msg.classList.remove('text-rose-400'); msg.classList.add('text-slate-400');
    msg.textContent = 'Enviando...';

    const { data, error } = await supabaseClient.rpc('prerecibo_crear', {
        p_token: sesion.token,
        p_orden_compra_id: ocId,
        p_referencia: sinOc ? ref.trim() : null,
        p_fotos: fotos,
        p_observaciones: document.getElementById('prObs').value || null,
        p_todo_correcto: document.getElementById('prOk').checked,
    });

    btn.disabled = false; msg.classList.remove('text-slate-400'); msg.classList.add('text-rose-400');
    if (error) {
        msg.textContent = /SESION_EXPIRADA/i.test(error.message || '')
            ? 'Tu sesión expiró, vuelve a identificarte.' : (error.message || 'No se pudo enviar.');
        if (/SESION_EXPIRADA/i.test(error.message || '')) setTimeout(salir, 1500);
        return;
    }
    pantallaOk(data);
}

function pantallaOk(id) {
    app().innerHTML = `
        <div class="p-6 max-w-md mx-auto text-center">
            <div class="text-5xl mb-3">✅</div>
            <h2 class="text-lg font-bold text-emerald-400 mb-1">Pre-recibo enviado</h2>
            <p class="text-sm text-slate-400 mb-6">Folio interno #${id}. El administrador lo revisará y validará la recepción.</p>
            <button type="button" id="prOtro" class="w-full bg-sky-600 active:bg-sky-700 text-white font-semibold py-3 rounded-xl text-sm mb-2">Capturar otro</button>
            <button type="button" id="prSalir" class="w-full bg-slate-800 border border-slate-700 text-slate-300 py-3 rounded-xl text-sm">Salir</button>
        </div>`;
    document.getElementById('prOtro').onclick = pantallaFormulario;
    document.getElementById('prSalir').onclick = salir;
}

// ---------- arranque ----------
if (cargarSesion() && sesion.token) {
    pantallaFormulario();
} else {
    pantallaLogin();
}
