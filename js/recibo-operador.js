import { supabaseClient } from './supabase.js';
import { accesoOperador } from './patron-login.js';

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
    ocultarModal();
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

// ---------- Pantalla: PIN / patrón (módulo compartido) ----------
function pantallaPin(emp) {
    accesoOperador(app(), emp, {
        volver: pantallaLogin,
        alEntrar: (fila) => {
            guardarSesion({ token: fila.token, empleadoId: fila.empleado_id, nombre: fila.empleado_nombre });
            pantallaFormulario();
        }
    });
}

// ---------- Pantalla: formulario de pre-recibo ----------
async function pantallaFormulario() {
    fotos = [];
    ocultarModal();
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

    document.getElementById('prEnviar').onclick = () => {
        if (validarAntesDeEnviar()) mostrarConfirmacion1();
    };
}

// ---------- validación previa (no envía nada todavía) ----------
function validarAntesDeEnviar() {
    const msg = document.getElementById('prMsg');
    const selOc = document.getElementById('prOc');
    const sinOc = selOc.value === '__sinoc__';
    const ocId = (!sinOc && selOc.value) ? Number(selOc.value) : null;
    const ref = document.getElementById('prRef')?.value || '';

    if (!ocId && !sinOc) { msg.textContent = 'Elige una orden de compra.'; return false; }
    if (sinOc && !ref.trim()) { msg.textContent = 'Escribe la referencia del documento.'; return false; }
    if (fotos.length === 0) { msg.textContent = 'Toma al menos una foto del documento.'; return false; }
    if (!document.getElementById('prOk').checked && !document.getElementById('prObs').value.trim()) {
        msg.textContent = 'Marca "todo correcto" o escribe qué no cuadra en observaciones.'; return false;
    }
    msg.textContent = '';
    return true;
}

// ---------- modal genérico (overlay sobre el formulario, que sigue montado) ----------
function mostrarModal(html) {
    let wrap = document.getElementById('prModalWrap');
    if (!wrap) {
        wrap = document.createElement('div');
        wrap.id = 'prModalWrap';
        wrap.className = 'fixed inset-0 bg-black/70 flex items-end sm:items-center justify-center z-50 p-4';
        document.body.appendChild(wrap);
    }
    wrap.innerHTML = html;
}
function ocultarModal() {
    const wrap = document.getElementById('prModalWrap');
    if (wrap) wrap.remove();
}

// ---------- 1ra confirmación: pre-resumen de lo capturado ----------
function mostrarConfirmacion1() {
    const lineas = leerLineasCapturadas();
    const obs = document.getElementById('prObs').value.trim();
    const discrepancias = lineas.filter((l) => l.cantidad_capturada !== l.cantidad_pendiente);
    const resumenLineas = !lineas.length
        ? '<p class="text-xs text-slate-500">Sin partidas (pre-recibo sin orden de compra).</p>'
        : `<div class="space-y-1 max-h-56 overflow-y-auto pr-1">` + lineas.map((l) => {
            const dif = l.cantidad_capturada - l.cantidad_pendiente;
            if (dif === 0) {
                return `<div class="flex justify-between items-baseline gap-2 text-xs border-b border-slate-800/60 py-1">
                    <span class="text-slate-300">${esc(l.descripcion)}</span>
                    <span class="font-mono text-emerald-400 shrink-0">${l.cantidad_capturada} ${esc(l.unidad)} ✓</span>
                </div>`;
            }
            return `<div class="flex justify-between items-baseline gap-2 text-xs bg-rose-950/60 border border-rose-700 rounded px-2 py-1">
                <span class="text-rose-200 font-semibold">⚠ ${esc(l.descripcion)}</span>
                <span class="font-mono text-rose-200 font-bold shrink-0">${l.cantidad_capturada} ${esc(l.unidad)} (esperabas ${l.cantidad_pendiente})</span>
            </div>`;
        }).join('') + `</div>`;

    mostrarModal(`
      <div class="bg-slate-900 border ${discrepancias.length ? 'border-rose-600' : 'border-slate-700'} rounded-2xl p-4 max-w-md w-full max-h-[85vh] overflow-y-auto">
        <h3 class="text-base font-bold text-slate-100 mb-1">Revisa tu conteo</h3>
        ${discrepancias.length
            ? `<p class="text-xs font-bold text-white bg-rose-700 border border-rose-500 rounded-lg px-2 py-1.5 mb-3">🚨 El conteo NO coincide con lo pedido en ${discrepancias.length} partida${discrepancias.length > 1 ? 's' : ''}. Revisa que esté bien antes de continuar.</p>`
            : `<p class="text-xs text-slate-400 mb-3">Esto es lo que se va a enviar. Si algo está mal, regresa y corrígelo antes de cerrar el recibo.</p>`}
        ${resumenLineas}
        ${obs ? `<p class="text-xs text-amber-300 mt-3"><b>Observaciones:</b> ${esc(obs)}</p>` : ''}
        <div class="flex gap-2 mt-4">
          <button type="button" id="prCancelar1" class="flex-1 bg-slate-800 border border-slate-700 text-slate-300 py-3 rounded-xl text-sm">‹ Regresar y corregir</button>
          <button type="button" id="prContinuar1" class="flex-1 bg-sky-600 active:bg-sky-700 text-white font-semibold py-3 rounded-xl text-sm">Continuar</button>
        </div>
      </div>`);
    document.getElementById('prCancelar1').onclick = ocultarModal;
    document.getElementById('prContinuar1').onclick = mostrarConfirmacion2;
}

// ---------- 2da confirmación: pregunta directa antes de cerrar ----------
function mostrarConfirmacion2() {
    mostrarModal(`
      <div class="bg-slate-900 border border-rose-700 rounded-2xl p-4 max-w-sm w-full">
        <h3 class="text-base font-bold text-rose-400 mb-2">¿Seguro que quieres cerrar este recibo?</h3>
        <p class="text-xs text-slate-400 mb-4">Una vez enviado ya no vas a poder editar el conteo. El administrador lo revisará contra las fotos.</p>
        <div class="flex gap-2">
          <button type="button" id="prCancelar2" class="flex-1 bg-slate-800 border border-slate-700 text-slate-300 py-3 rounded-xl text-sm">Cancelar</button>
          <button type="button" id="prConfirmar2" class="flex-1 bg-emerald-600 active:bg-emerald-700 text-white font-semibold py-3 rounded-xl text-sm">Sí, cerrar recibo</button>
        </div>
      </div>`);
    document.getElementById('prCancelar2').onclick = ocultarModal;
    document.getElementById('prConfirmar2').onclick = () => { ocultarModal(); enviarReal(); };
}

async function pintarLineas(ocId) {
    const cont = document.getElementById('prLineas');
    if (!cont) return;
    if (!ocId) { cont.innerHTML = ''; return; }
    cont.innerHTML = 'Cargando partidas...';
    const { data, error } = await supabaseClient
        .from('v_recibo_oc_lineas')
        .select('id, descripcion, cantidad, cantidad_recibida, unidad')
        .eq('orden_compra_id', ocId);
    if (error) { cont.innerHTML = ''; return; }
    if (!data || !data.length) { cont.innerHTML = '<span class="text-slate-500">Sin partidas.</span>'; return; }
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-2 mt-1">
            <p class="text-[11px] text-slate-500 mb-2">Cuenta las piezas que <b>de verdad</b> llegaron de cada partida:</p>
            ${data.map(l => {
                const pendiente = Math.max(0, Number(l.cantidad) - Number(l.cantidad_recibida || 0));
                return `
                <div class="py-1.5 border-b border-slate-800/60 last:border-0">
                    <div class="flex justify-between items-baseline mb-1 gap-2">
                        <span class="text-slate-300">${esc(l.descripcion)}</span>
                        <span class="text-slate-500 text-[11px] font-mono shrink-0">pedido ${l.cantidad}${l.cantidad_recibida > 0 ? ` (${l.cantidad_recibida} ya recib.)` : ''} ${esc(l.unidad || '')}</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="text-[11px] text-slate-500 shrink-0">Llegaron:</span>
                        <input type="number" inputmode="decimal" min="0" step="any"
                               class="pr-linea-input w-24 bg-slate-950 border border-slate-700 rounded-lg p-2 text-sm text-slate-100 text-right font-mono"
                               value="${pendiente}"
                               data-detalle-id="${l.id}"
                               data-descripcion="${esc(l.descripcion)}"
                               data-unidad="${esc(l.unidad || '')}"
                               data-pedida="${l.cantidad}"
                               data-pendiente="${pendiente}">
                        <span class="text-[11px] text-slate-500">${esc(l.unidad || '')}</span>
                    </div>
                </div>`;
            }).join('')}
        </div>`;
    cont.querySelectorAll('.pr-linea-input').forEach((inp) => {
        inp.addEventListener('input', () => { if (parseFloat(inp.value) < 0) inp.value = 0; });
    });
}

// Lee lo que el operador capturó por partida directamente del DOM
// (no hace falta estado aparte: mientras el modal de confirmación está
// abierto, el formulario sigue montado detrás).
function leerLineasCapturadas() {
    return Array.from(document.querySelectorAll('.pr-linea-input')).map((inp) => ({
        orden_compra_detalle_id: inp.dataset.detalleId ? Number(inp.dataset.detalleId) : null,
        descripcion: inp.dataset.descripcion || '',
        unidad: inp.dataset.unidad || '',
        cantidad_pedida: Number(inp.dataset.pedida) || 0,
        cantidad_pendiente: Number(inp.dataset.pendiente) || 0,
        cantidad_capturada: Math.max(0, parseFloat(inp.value) || 0),
    }));
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

async function enviarReal() {
    const msg = document.getElementById('prMsg');
    const btn = document.getElementById('prEnviar');
    const selOc = document.getElementById('prOc');
    const sinOc = selOc.value === '__sinoc__';
    const ocId = (!sinOc && selOc.value) ? Number(selOc.value) : null;
    const ref = document.getElementById('prRef')?.value || '';

    btn.disabled = true; msg.classList.remove('text-rose-400'); msg.classList.add('text-slate-400');
    msg.textContent = 'Enviando...';

    const { data, error } = await supabaseClient.rpc('prerecibo_crear', {
        p_token: sesion.token,
        p_orden_compra_id: ocId,
        p_referencia: sinOc ? ref.trim() : null,
        p_fotos: fotos,
        p_observaciones: document.getElementById('prObs').value || null,
        p_todo_correcto: document.getElementById('prOk').checked,
        p_lineas: leerLineasCapturadas(),
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
