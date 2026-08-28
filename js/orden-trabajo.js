import { supabaseClient } from './supabase.js';

// ---------------------------------------------------------------------------
//  Orden de Trabajo (móvil, para operarios).
//  Se usa de forma anónima: el empleado se identifica con nombre + PIN de 4
//  dígitos y registra sus tiempos de inicio/paro por proceso.
//  NO muestra costos por hora ni totales de dinero: toda la información de
//  costos se sirve solo a través de la app de administración (rol authenticated).
//  Toda la lectura pasa por vistas públicas (v_ot_*) y las escrituras por
//  las RPC ot_login / ot_marcar.
// ---------------------------------------------------------------------------

const KEY = 'ot_sesion';
let sesion = null;
let ticker = null;
let poll = null;
let ordenActualId = null;

const app = () => document.getElementById('app');

function guardarSesion(s) {
    sesion = s;
    try { sessionStorage.setItem(KEY, JSON.stringify(s)); } catch (e) { /* modo privado */ }
}
function cargarSesion() {
    try { sesion = JSON.parse(sessionStorage.getItem(KEY) || 'null'); } catch (e) { sesion = null; }
    return sesion;
}
function salir() {
    sesion = null;
    try { sessionStorage.removeItem(KEY); } catch (e) { /* noop */ }
    detenerTimers();
    pantallaLogin();
}
function detenerTimers() {
    clearInterval(ticker); ticker = null;
    clearInterval(poll); poll = null;
}
function esErrorSesion(err) {
    const m = ((err && err.message) || '').toUpperCase();
    return m.includes('SESION_EXPIRADA') || m.includes('JWT') || m.includes('EXPIR');
}
function fmt(seg) {
    const s = Math.max(0, Math.floor(seg));
    return [Math.floor(s / 3600), Math.floor((s % 3600) / 60), s % 60]
        .map(n => String(n).padStart(2, '0')).join(':');
}
function segIntervalo(inicio, fin) {
    return Math.max(0, ((fin ? new Date(fin) : new Date()) - new Date(inicio)) / 1000);
}

// ---------- Cabecera común ----------
function cabecera() {
    return `
        <div class="flex justify-between items-center">
            <span class="text-sm font-bold text-sky-400">${sesion?.nombre || ''}</span>
            <button id="btnSalir" class="text-xs text-slate-400">Salir</button>
        </div>`;
}
function engancharCabecera() {
    const b = document.getElementById('btnSalir');
    if (b) b.onclick = salir;
}

// ---------- Pantalla: identificación ----------
async function pantallaLogin() {
    detenerTimers();
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            <h1 class="text-lg font-bold text-sky-400 text-center mb-1">Orden de Trabajo</h1>
            <p class="text-xs text-slate-400 text-center mb-4">Toca tu nombre para registrar tus tiempos.</p>
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

// ---------- Pantalla: PIN ----------
function pantallaPin(emp) {
    let pin = '';

    const render = (msg = '') => {
        app().innerHTML = `
            <div class="p-4 max-w-xs mx-auto">
                <button id="volver" class="text-xs text-slate-400 mb-2">‹ Volver</button>
                <h2 class="text-base font-bold text-slate-100 text-center mb-1">${emp.nombre}</h2>
                <p class="text-xs text-slate-400 text-center mb-3">Ingresa tu PIN de 4 dígitos</p>
                <div class="flex justify-center gap-3 mb-4">
                    ${[0, 1, 2, 3].map(i => `<span class="w-4 h-4 rounded-full ${i < pin.length ? 'bg-sky-400' : 'bg-slate-700'}"></span>`).join('')}
                </div>
                <p class="text-rose-400 text-xs text-center h-4 mb-2">${msg}</p>
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

                const { data, error } = await supabaseClient.rpc('ot_login', {
                    p_empleado_id: emp.id,
                    p_pin: pin
                });
                const fila = Array.isArray(data) ? data[0] : data;
                if (error || !fila) {
                    pin = '';
                    render(error ? error.message : 'PIN incorrecto');
                    return;
                }
                guardarSesion({ token: fila.token, empleadoId: fila.empleado_id, nombre: fila.empleado_nombre });
                pantallaOrdenes();
            };
        });
    };

    render();
}

// ---------- Pantalla: lista de órdenes abiertas ----------
async function pantallaOrdenes() {
    detenerTimers();
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera()}
            <h2 class="text-sm font-bold text-slate-200 mt-3 mb-2">Órdenes abiertas</h2>
            <div id="listaOrd"><p class="text-slate-500 text-sm">Cargando...</p></div>
        </div>`;
    engancharCabecera();
    await pintarOrdenes();
    poll = setInterval(pintarOrdenes, 15000);
}

async function pintarOrdenes() {
    const cont = document.getElementById('listaOrd');
    if (!cont) return;

    const { data, error } = await supabaseClient
        .from('v_ot_ordenes')
        .select('id, folio, producto_nombre, cantidad_producida, numero_lote')
        .order('abierta_at', { ascending: true });

    if (error) { cont.innerHTML = `<p class="text-rose-400 text-sm">${error.message}</p>`; return; }
    if (!data || !data.length) { cont.innerHTML = `<p class="text-slate-500 text-sm">No hay órdenes abiertas.</p>`; return; }

    cont.innerHTML = data.map(o => `
        <button class="ord-btn w-full text-left bg-slate-900 border border-slate-800 rounded-xl p-3 mb-2 active:bg-slate-800" data-id="${o.id}">
            <p class="font-mono font-bold text-amber-400 text-sm">${o.folio || ('#' + o.id)}</p>
            <p class="text-sm text-slate-200">${o.producto_nombre || 'Producto'}</p>
            <p class="text-xs text-slate-500">${o.cantidad_producida} u · Lote ${o.numero_lote || 'S/L'}</p>
        </button>
    `).join('');
    cont.querySelectorAll('.ord-btn').forEach(b => {
        b.onclick = () => pantallaOrden(Number(b.dataset.id));
    });
}

// ---------- Pantalla: orden de trabajo ----------
async function pantallaOrden(ordenId) {
    detenerTimers();
    ordenActualId = ordenId;
    app().innerHTML = `
        <div class="p-4 max-w-md mx-auto">
            ${cabecera()}
            <button id="volverOrd" class="text-xs text-slate-400 mt-2 mb-1">‹ Órdenes</button>
            <div id="ordCont"><p class="text-slate-500 text-sm">Cargando...</p></div>
        </div>`;
    engancharCabecera();
    document.getElementById('volverOrd').onclick = pantallaOrdenes;
    await pintarOrden();
    ticker = setInterval(tick, 1000);
    poll = setInterval(pintarOrden, 15000);
}

async function pintarOrden() {
    const cont = document.getElementById('ordCont');
    if (!cont) return;

    const { data: ordenes } = await supabaseClient
        .from('v_ot_ordenes')
        .select('id, folio, producto_nombre, cantidad_producida, numero_lote')
        .eq('id', ordenActualId);
    const orden = (ordenes || [])[0];
    if (!orden) {
        detenerTimers();
        cont.innerHTML = `<p class="text-slate-500 text-sm">Esta orden ya no está abierta.</p>`;
        return;
    }

    const { data: procesos } = await supabaseClient
        .from('v_ot_procesos')
        .select('id, proceso_nombre')
        .eq('orden_produccion_id', ordenActualId);
    const procIds = (procesos || []).map(p => p.id);

    let equipos = [];
    let registros = [];
    if (procIds.length) {
        const [{ data: eq }, { data: rg }] = await Promise.all([
            supabaseClient.from('v_ot_proceso_empleados')
                .select('orden_produccion_proceso_id, empleado_id, empleado_nombre, finalizado_at')
                .in('orden_produccion_proceso_id', procIds),
            supabaseClient.from('v_ot_registros')
                .select('orden_produccion_proceso_id, empleado_id, inicio, fin')
                .in('orden_produccion_proceso_id', procIds)
        ]);
        equipos = eq || [];
        registros = rg || [];
    }

    const miId = Number(sesion.empleadoId);

    const procesosHtml = (procesos || []).map(p => {
        const team = equipos.filter(e => e.orden_produccion_proceso_id === p.id);
        const miAsign = team.find(e => Number(e.empleado_id) === miId);
        const asignado = !!miAsign;
        const finalizada = !!(miAsign && miAsign.finalizado_at);
        const mis = registros.filter(r => r.orden_produccion_proceso_id === p.id && Number(r.empleado_id) === miId);

        let acum = 0;
        let abierto = '';
        mis.forEach(r => { if (r.fin) acum += segIntervalo(r.inicio, r.fin); else abierto = r.inicio; });

        const nombres = team.map(e => e.empleado_nombre).filter(Boolean).join(', ') || 'Sin equipo asignado';

        let bloqueOperario = `<p class="text-[11px] text-slate-600 italic">No estás asignado a este proceso.</p>`;
        if (asignado && finalizada) {
            bloqueOperario = `
                <div class="flex items-center justify-between">
                    <span class="ot-timer font-mono text-lg text-slate-400" data-acum="${acum}" data-inicio="">${fmt(acum)}</span>
                    <span class="text-emerald-400 text-xs font-semibold">✅ Tarea finalizada</span>
                </div>
                <button class="btn-reabrir mt-2 text-xs text-slate-400 underline" data-proceso="${p.id}">Reabrir tarea</button>`;
        } else if (asignado) {
            bloqueOperario = `
                <div class="flex items-center justify-between">
                    <span class="ot-timer font-mono text-lg text-amber-300" data-acum="${acum}" data-inicio="${abierto}">${fmt(acum)}</span>
                    <button class="btn-marcar ${abierto ? 'bg-rose-600' : 'bg-emerald-600'} text-white font-semibold rounded-xl px-5 py-3 text-sm active:opacity-80"
                            data-proceso="${p.id}" data-accion="${abierto ? 'parar' : 'iniciar'}">
                        ${abierto ? '⏹ Parar' : '▶ Iniciar'}
                    </button>
                </div>
                <button class="btn-finalizar mt-2 w-full bg-slate-800 border border-slate-700 text-slate-200 font-semibold rounded-xl py-2.5 text-sm active:opacity-80"
                        data-proceso="${p.id}">🏁 Finalizar tarea</button>`;
        }

        return `
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-3 mb-2">
                <p class="text-sm font-semibold text-slate-100">${p.proceso_nombre}</p>
                <p class="text-[11px] text-slate-500 mb-2">${nombres}</p>
                ${bloqueOperario}
            </div>`;
    }).join('');

    cont.innerHTML = `
        <p class="font-mono font-bold text-amber-400 text-sm">${orden.folio || ('#' + orden.id)}</p>
        <p class="text-sm text-slate-200 mb-3">${orden.producto_nombre || ''} · ${orden.cantidad_producida} u · Lote ${orden.numero_lote || 'S/L'}</p>
        ${procesosHtml || '<p class="text-slate-500 text-sm">Esta orden no tiene procesos.</p>'}
    `;

    const manejarRpc = async (btn, rpc, params, confirmar) => {
        if (confirmar && !confirm(confirmar)) return;
        btn.disabled = true;
        const { error } = await supabaseClient.rpc(rpc, params);
        if (error) {
            if (esErrorSesion(error)) { alert('Tu sesión expiró. Vuelve a identificarte.'); salir(); return; }
            alert(error.message);
            btn.disabled = false;
            return;
        }
        await pintarOrden();
    };

    cont.querySelectorAll('.btn-marcar').forEach(b => {
        b.onclick = () => manejarRpc(b, 'ot_marcar', {
            p_token: sesion.token,
            p_proceso_id: Number(b.dataset.proceso),
            p_accion: b.dataset.accion
        });
    });

    cont.querySelectorAll('.btn-finalizar').forEach(b => {
        b.onclick = () => manejarRpc(b, 'ot_finalizar', {
            p_token: sesion.token,
            p_proceso_id: Number(b.dataset.proceso),
            p_finalizar: true
        }, '¿Finalizar tu tarea en este proceso? Se detendrá el cronómetro y tu tiempo quedará registrado.');
    });

    cont.querySelectorAll('.btn-reabrir').forEach(b => {
        b.onclick = () => manejarRpc(b, 'ot_finalizar', {
            p_token: sesion.token,
            p_proceso_id: Number(b.dataset.proceso),
            p_finalizar: false
        });
    });
}

function tick() {
    document.querySelectorAll('.ot-timer').forEach(el => {
        const acum = Number(el.dataset.acum || 0);
        const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
        el.textContent = fmt(acum + (ini ? (Date.now() - ini) / 1000 : 0));
    });
}

// ---------- Arranque ----------
cargarSesion();
if (sesion && sesion.token) pantallaOrdenes();
else pantallaLogin();
