import { supabaseClient } from './supabase.js';
import { ICONOS, CATEGORIAS_ICONOS, svgIcono as svg } from './iconos-accesos.js';
import { SECCIONES } from './indice.js';

// ---------------------------------------------------------------------------
//  Pantalla de bienvenida (Inicio): logo, saludo según la hora, el nombre de
//  quien entró y accesos rápidos. El nombre sale, en este orden, de: el que el
//  usuario eligió con ✎ (se guarda en este navegador), el nombre del perfil de
//  Supabase (user_metadata) o, si no hay, el inicio de su correo.
//
//  Los accesos rápidos son personalizables por usuario ("✎ Personalizar"):
//  agregar, quitar, reordenar y elegir ícono de la galería. Se guardan en
//  `accesos_directos_usuario` (sql/2026-09-24c_...); si esa tabla aún no existe
//  o no hay red, quedan en este navegador (localStorage) y nada se rompe.
// ---------------------------------------------------------------------------

const LS_NOMBRE = 'hares_nombre_saludo';
const LS_ACCESOS = (uid) => `hares_accesos_${uid || 'anon'}`;
const MAX_ACCESOS = 12;
let reloj = null;
let editando = false;
let sesion = { uid: null, accesos: [] };

// Accesos por defecto: { v: vista, t: título, s: subtítulo, i: ícono de la galería }
const ACCESOS_DEFECTO = [
    { v: 'produccion',       i: 'fabrica', t: 'Producción',           s: 'Órdenes y costos' },
    { v: 'recibo-mercancia', i: 'caja',    t: 'Recibo de mercancía',  s: 'Entradas de compra' },
    { v: 'inventario',       i: 'capas',   t: 'Inventario',           s: 'Existencias y lotes' },
    { v: 'catalogo',         i: 'matraz',  t: 'Productos y BOM',      s: 'Catálogo y fórmulas' },
    { v: 'ordenes-compra',   i: 'carrito', t: 'Órdenes de compra',    s: 'Abasto' },
    { v: 'indice',           i: 'brujula', t: 'Índice del ERP',       s: 'Todos los módulos' },
];

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function saludoDelDia(hora) {
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
}

function nombreDesdeCorreo(correo) {
    const base = String(correo || '').split('@')[0].split(/[._-]+/)[0];
    return base ? base.charAt(0).toUpperCase() + base.slice(1) : '';
}

async function usuarioActual() {
    try {
        const { data } = await supabaseClient.auth.getSession();
        return data?.session?.user || null;
    } catch (_) {
        return null;
    }
}

function nombreDe(user) {
    try {
        const guardado = localStorage.getItem(LS_NOMBRE);
        if (guardado) return guardado;
    } catch (_) { /* sin almacenamiento */ }
    const meta = user?.user_metadata || {};
    const n = meta.nombre || meta.name || meta.full_name;
    if (n) return String(n).trim().split(/\s+/)[0];
    return nombreDesdeCorreo(user?.email);
}

function fechaHora(ahora) {
    const fecha = ahora.toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' });
    const hora = ahora.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit', hour12: false });
    return `${fecha.charAt(0).toUpperCase()}${fecha.slice(1)} · ${hora}`;
}

// Actualiza fecha/hora y el saludo (si cambió de mañana a tarde, etc.). Se detiene
// solo cuando la pantalla ya no existe en la página.
function tick() {
    const elFecha = document.getElementById('bvFecha');
    if (!elFecha) { clearInterval(reloj); reloj = null; return; }
    const ahora = new Date();
    elFecha.textContent = fechaHora(ahora);
    const elSaludo = document.getElementById('bvSaludoTxt');
    if (elSaludo) elSaludo.textContent = saludoDelDia(ahora.getHours());
}

// ---------------------------------------------------------------------------
//  Accesos: carga y guardado (Supabase, con respaldo en el navegador)
// ---------------------------------------------------------------------------

function limpiarAccesos(lista) {
    return (Array.isArray(lista) ? lista : [])
        .filter((a) => a && typeof a.v === 'string' && a.v && typeof a.t === 'string' && a.t.trim())
        .map((a) => ({ v: a.v, t: a.t.trim().slice(0, 40), s: String(a.s || '').trim().slice(0, 40), i: ICONOS[a.i] ? a.i : 'estrella' }))
        .slice(0, MAX_ACCESOS);
}

function leerLocal(uid) {
    try {
        const raw = localStorage.getItem(LS_ACCESOS(uid));
        return raw ? limpiarAccesos(JSON.parse(raw)) : null;
    } catch (_) { return null; }
}

function escribirLocal(uid, accesos) {
    try {
        if (accesos) localStorage.setItem(LS_ACCESOS(uid), JSON.stringify(accesos));
        else localStorage.removeItem(LS_ACCESOS(uid));
    } catch (_) { /* sin almacenamiento */ }
}

async function cargarAccesos(uid) {
    if (uid) {
        try {
            const { data, error } = await supabaseClient.from('accesos_directos_usuario')
                .select('accesos').eq('user_id', uid).maybeSingle();
            if (!error) {
                if (data) { const l = limpiarAccesos(data.accesos); escribirLocal(uid, l); return l; }
                escribirLocal(uid, null);
                return ACCESOS_DEFECTO.map((a) => ({ ...a }));   // sin fila = los de siempre
            }
        } catch (_) { /* cae al respaldo */ }
    }
    return leerLocal(uid) || ACCESOS_DEFECTO.map((a) => ({ ...a }));
}

// Devuelve true si quedó guardado en la nube.
async function guardarAccesos(accesos) {
    sesion.accesos = accesos;
    escribirLocal(sesion.uid, accesos);
    if (!sesion.uid) return false;
    try {
        const { error } = await supabaseClient.from('accesos_directos_usuario')
            .upsert({ user_id: sesion.uid, accesos, updated_at: new Date().toISOString() }, { onConflict: 'user_id' });
        return !error;
    } catch (_) { return false; }
}

async function restablecerAccesos() {
    escribirLocal(sesion.uid, null);
    sesion.accesos = ACCESOS_DEFECTO.map((a) => ({ ...a }));
    if (!sesion.uid) return true;
    try {
        const { error } = await supabaseClient.from('accesos_directos_usuario').delete().eq('user_id', sesion.uid);
        return !error;
    } catch (_) { return false; }
}

function avisoNube(guardado) {
    const el = document.getElementById('bvAviso');
    if (!el) return;
    el.textContent = guardado ? '' : 'Quedó guardado en este navegador (aún no se pudo guardar en tu cuenta; falta correr sql/2026-09-24c_accesos_directos_usuario.sql).';
    el.classList.toggle('hidden', guardado);
}

// ---------------------------------------------------------------------------
//  Pintado de las tarjetas
// ---------------------------------------------------------------------------

function pintarTiles() {
    const cont = document.getElementById('bvTiles');
    if (!cont) return;
    const tiles = sesion.accesos.map((a, idx) => `
        <a class="bv-tile${editando ? ' bv-edit' : ''}" href="#" data-idx="${idx}" data-vista="${esc(a.v)}">
            ${editando ? `<span class="bv-tools">
                <button type="button" class="bv-tool" data-mov="-1" title="Mover a la izquierda" ${idx === 0 ? 'disabled' : ''}>${svg('izquierda')}</button>
                <button type="button" class="bv-tool" data-mov="1" title="Mover a la derecha" ${idx === sesion.accesos.length - 1 ? 'disabled' : ''}>${svg('derecha')}</button>
                <button type="button" class="bv-tool bv-quitar" data-quitar="1" title="Quitar este acceso">${svg('cerrar')}</button>
            </span>` : ''}
            <span class="ico">${svg(a.i)}</span>
            <span>${esc(a.t)}</span>
            ${a.s ? `<small>${esc(a.s)}</small>` : ''}
        </a>`).join('');
    const nuevo = editando && sesion.accesos.length < MAX_ACCESOS ? `
        <a class="bv-tile bv-nuevo" href="#" data-nuevo="1">
            <span class="ico">${svg('mas')}</span>
            <span>Agregar acceso</span>
            <small>${sesion.accesos.length} de ${MAX_ACCESOS}</small>
        </a>` : '';
    cont.innerHTML = tiles + nuevo;

    const acciones = document.getElementById('bvAcciones');
    if (acciones) {
        acciones.innerHTML = editando
            ? `<button type="button" class="bv-btn bv-btn-ok" id="bvListo">✔ Listo</button>
               <button type="button" class="bv-btn" id="bvRestablecer">↺ Restablecer los de siempre</button>`
            : `<button type="button" class="bv-btn" id="bvPersonalizar">✎ Personalizar accesos</button>`;
        document.getElementById('bvListo')?.addEventListener('click', () => { editando = false; pintarTiles(); });
        document.getElementById('bvPersonalizar')?.addEventListener('click', () => { editando = true; pintarTiles(); });
        document.getElementById('bvRestablecer')?.addEventListener('click', async () => {
            if (!confirm('¿Volver a los accesos rápidos de siempre? Se pierden tus accesos personalizados.')) return;
            const ok = await restablecerAccesos();
            avisoNube(ok);
            pintarTiles();
        });
    }
}

async function mover(idx, delta) {
    const lista = sesion.accesos.slice();
    const j = idx + delta;
    if (j < 0 || j >= lista.length) return;
    [lista[idx], lista[j]] = [lista[j], lista[idx]];
    sesion.accesos = lista;
    pintarTiles();
    avisoNube(await guardarAccesos(lista));
}

async function quitar(idx) {
    const a = sesion.accesos[idx];
    if (!a || !confirm(`¿Quitar "${a.t}" de tus accesos rápidos?`)) return;
    const lista = sesion.accesos.filter((_, k) => k !== idx);
    sesion.accesos = lista;
    pintarTiles();
    avisoNube(await guardarAccesos(lista));
}

// ---------------------------------------------------------------------------
//  Editor de un acceso (subventana; el fondo semitransparente deja ver Inicio)
// ---------------------------------------------------------------------------

// Pantallas disponibles: las mismas del Índice del ERP (no se duplica la lista).
function opcionesPantallas(actual) {
    const vistas = new Set();
    return SECCIONES.map((g) => {
        const items = g.items.filter((it) => !vistas.has(it.v) && vistas.add(it.v));
        if (!items.length) return '';
        return `<optgroup label="${esc(g.grupo)}">${items.map((it) =>
            `<option value="${esc(it.v)}" ${it.v === actual ? 'selected' : ''}>${esc(it.t)}</option>`).join('')}</optgroup>`;
    }).join('');
}

const datosPantalla = (v) => {
    for (const g of SECCIONES) {
        const it = g.items.find((x) => x.v === v);
        if (it) return { titulo: it.t, sub: g.grupo.replace(/^Operación — /, '') };
    }
    return { titulo: '', sub: '' };
};

function abrirEditor(idx) {
    const nuevo = idx === null;
    const base = nuevo ? { v: '', t: '', s: '', i: 'estrella' } : sesion.accesos[idx];
    let iconoSel = base.i;
    let autoTitulo = nuevo || (base.t === datosPantalla(base.v).titulo);
    let autoSub = nuevo || (base.s === datosPantalla(base.v).sub);

    const ov = document.createElement('div');
    ov.className = 'fixed inset-0 z-[80] flex items-center justify-center p-4 bg-slate-950/40';
    ov.innerHTML = `
        <div class="w-full max-w-lg max-h-[88vh] overflow-y-auto bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl">
            <div class="flex items-center justify-between px-5 py-3 border-b border-slate-800" style="cursor: grab;">
                <h3 class="text-base font-bold text-slate-100">${nuevo ? '＋ Nuevo acceso rápido' : '✎ Editar acceso rápido'}</h3>
                <button type="button" id="bvEdCerrar" class="text-slate-400 hover:text-slate-200 text-xl leading-none" title="Cerrar">✕</button>
            </div>
            <div class="p-5 space-y-4">
                <div>
                    <label class="block text-xs font-medium text-slate-400 mb-1">PANTALLA A LA QUE LLEVA</label>
                    <select id="bvEdVista" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        <option value="">Elige una pantalla…</option>${opcionesPantallas(base.v)}
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">TÍTULO</label>
                        <input id="bvEdTitulo" maxlength="40" value="${esc(base.t)}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">SUBTÍTULO (opcional)</label>
                        <input id="bvEdSub" maxlength="40" value="${esc(base.s)}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-medium text-slate-400 mb-2">ÍCONO</label>
                    <div class="space-y-3">
                        ${CATEGORIAS_ICONOS.map(([cat, nombres]) => `
                        <div>
                            <p class="text-[10px] uppercase tracking-wider text-slate-500 mb-1">${esc(cat)}</p>
                            <div class="bv-galeria">${nombres.map((n) => `
                                <button type="button" class="bv-gico${n === iconoSel ? ' sel' : ''}" data-ico="${n}" title="${n}">${svg(n)}</button>`).join('')}
                            </div>
                        </div>`).join('')}
                    </div>
                </div>
                <p id="bvEdError" class="text-xs text-rose-400 hidden"></p>
                <div class="flex justify-end gap-2 pt-1">
                    <button type="button" id="bvEdCancelar" class="px-4 py-2 rounded-lg text-sm text-slate-300 bg-slate-800 hover:bg-slate-700">Cancelar</button>
                    <button type="button" id="bvEdGuardar" class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-sky-600 hover:bg-sky-500">Guardar</button>
                </div>
            </div>
        </div>`;
    document.body.appendChild(ov);

    const cerrar = () => ov.remove();
    const q = (id) => ov.querySelector(`#${id}`);
    ov.addEventListener('mousedown', (e) => { if (e.target === ov) cerrar(); });
    q('bvEdCerrar').addEventListener('click', cerrar);
    q('bvEdCancelar').addEventListener('click', cerrar);

    q('bvEdVista').addEventListener('change', () => {
        const d = datosPantalla(q('bvEdVista').value);
        if (autoTitulo) q('bvEdTitulo').value = d.titulo;
        if (autoSub) q('bvEdSub').value = d.sub;
    });
    q('bvEdTitulo').addEventListener('input', () => { autoTitulo = false; });
    q('bvEdSub').addEventListener('input', () => { autoSub = false; });

    ov.querySelectorAll('.bv-gico').forEach((b) => b.addEventListener('click', () => {
        iconoSel = b.dataset.ico;
        ov.querySelectorAll('.bv-gico').forEach((x) => x.classList.toggle('sel', x === b));
    }));

    q('bvEdGuardar').addEventListener('click', async () => {
        const v = q('bvEdVista').value;
        const t = q('bvEdTitulo').value.trim();
        const err = q('bvEdError');
        if (!v || !t) {
            err.textContent = !v ? 'Elige a qué pantalla lleva el acceso.' : 'Ponle un título.';
            err.classList.remove('hidden');
            return;
        }
        const item = { v, t, s: q('bvEdSub').value.trim(), i: iconoSel };
        const lista = sesion.accesos.slice();
        if (nuevo) lista.push(item); else lista[idx] = item;
        sesion.accesos = limpiarAccesos(lista);
        cerrar();
        pintarTiles();
        avisoNube(await guardarAccesos(sesion.accesos));
    });
}

// ---------------------------------------------------------------------------
//  Pantalla
// ---------------------------------------------------------------------------

export async function montarBienvenida() {
    const cont = document.getElementById('contenedorBienvenida');
    if (!cont) return;

    const user = await usuarioActual();
    const nombre = nombreDe(user);
    const ahora = new Date();
    editando = false;
    sesion = { uid: user?.id || null, accesos: await cargarAccesos(user?.id) };

    cont.innerHTML = `
        <div class="bv">
            <div class="bv-orbes"><div class="bv-orbe o1"></div><div class="bv-orbe o2"></div><div class="bv-orbe o3"></div></div>

            <div class="bv-logo">
                <div class="bv-disco"><img src="img/HARES_icono_tinta.svg" alt="Hares de México"></div>
            </div>

            <div id="bvFecha" class="bv-fecha">${esc(fechaHora(ahora))}</div>
            <h1 class="bv-saludo">
                <span id="bvSaludoTxt">${saludoDelDia(ahora.getHours())}</span>${nombre ? `, <span class="bv-nombre" id="bvNombre">${esc(nombre)}</span>` : ''}
                <a class="bv-editar" id="bvEditar" href="#" title="Cambiar cómo te saludo">${svg('lapiz')}</a>
            </h1>
            <p class="bv-sub">Qué bueno verte de nuevo. Aquí tienes lo de todos los días a un clic.</p>

            <div class="bv-tiles" id="bvTiles"></div>
            <div class="bv-acciones" id="bvAcciones"></div>
            <p id="bvAviso" class="bv-aviso hidden"></p>
        </div>`;

    pintarTiles();

    // Un solo listener para las tarjetas (se vuelven a pintar al editar).
    document.getElementById('bvTiles').addEventListener('click', (e) => {
        const tile = e.target.closest('.bv-tile');
        if (!tile) return;
        e.preventDefault();
        if (tile.dataset.nuevo) { abrirEditor(null); return; }
        const idx = Number(tile.dataset.idx);
        const mov = e.target.closest('[data-mov]');
        if (mov) { mover(idx, Number(mov.dataset.mov)); return; }
        if (e.target.closest('[data-quitar]')) { quitar(idx); return; }
        if (editando) { abrirEditor(idx); return; }
        if (typeof window.loadView === 'function') window.loadView(tile.dataset.vista);
    });

    document.getElementById('bvEditar').addEventListener('click', (e) => {
        e.preventDefault();
        const actual = document.getElementById('bvNombre')?.textContent || '';
        const nuevo = prompt('¿Cómo quieres que te salude? (déjalo vacío para usar el de tu cuenta)', actual);
        if (nuevo === null) return;
        try {
            if (nuevo.trim()) localStorage.setItem(LS_NOMBRE, nuevo.trim());
            else localStorage.removeItem(LS_NOMBRE);
        } catch (_) { /* sin almacenamiento */ }
        montarBienvenida();
    });

    clearInterval(reloj);
    reloj = setInterval(tick, 30000);
}
