import { supabaseClient } from './supabase.js';

// ---------------------------------------------------------------------------
//  Acceso de operador (PIN o patrón) — compartido por Orden de Trabajo,
//  Pre-recibo y Conteo de inventario.
//
//  El patrón se dibuja como en el desbloqueo del celular (cuadrícula 3x3) y
//  se verifica en el servidor, igual que el PIN (ot_login_patron). Se crea
//  después de entrar con el PIN (ot_set_patron). Si la migración
//  sql/2026-10-17_login_patron_operadores.sql no está corrida, todo sigue
//  funcionando solo con PIN.
// ---------------------------------------------------------------------------

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const MIN_PUNTOS = 4;
const RADIO_TOQUE = 40;                  // unidades del viewBox (300x300)
const NODOS = Array.from({ length: 9 }, (_, i) => ({ n: i + 1, x: 50 + 100 * (i % 3), y: 50 + 100 * Math.floor(i / 3) }));
const claveOmitido = (id) => `patron_omitido_${id}`;

function leerOmitido(id) { try { return localStorage.getItem(claveOmitido(id)) === '1'; } catch (e) { return false; } }
function guardarOmitido(id) { try { localStorage.setItem(claveOmitido(id), '1'); } catch (e) { /* noop */ } }

// Punto que queda en medio de dos nodos (1 -> 3 pasa por el 2), como en el celular.
function nodoIntermedio(a, b) {
    const ax = (a - 1) % 3, ay = Math.floor((a - 1) / 3);
    const bx = (b - 1) % 3, by = Math.floor((b - 1) / 3);
    if ((ax + bx) % 2 !== 0 || (ay + by) % 2 !== 0) return null;
    return ((ay + by) / 2) * 3 + (ax + bx) / 2 + 1;
}

// ---------- Cuadrícula de puntos ----------
// Devuelve { reiniciar(), error(), ok() }. alTerminar(secuencia) se llama al
// levantar el dedo; el tablero queda bloqueado hasta reiniciar().
function montarTablero(el, alTerminar) {
    el.style.touchAction = 'none';
    el.innerHTML = `
        <svg viewBox="0 0 300 300" class="w-full h-full select-none" style="touch-action:none">
            <polyline fill="none" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" style="stroke:var(--acc)" points=""></polyline>
            ${NODOS.map(n => `
                <circle class="halo" cx="${n.x}" cy="${n.y}" r="32" style="fill:var(--acc);opacity:0"></circle>
                <circle class="punto" cx="${n.x}" cy="${n.y}" r="12" style="fill:var(--tx-4)"></circle>`).join('')}
        </svg>`;

    const svg = el.querySelector('svg');
    const linea = svg.querySelector('polyline');
    const halos = [...svg.querySelectorAll('.halo')];
    const puntos = [...svg.querySelectorAll('.punto')];
    let sel = [], activo = false, cursor = null, bloqueado = false, color = 'var(--acc)';

    const pintar = () => {
        const pts = sel.map(n => `${NODOS[n - 1].x},${NODOS[n - 1].y}`);
        if (activo && cursor) pts.push(`${cursor.x},${cursor.y}`);
        linea.setAttribute('points', pts.join(' '));
        linea.style.stroke = color;
        NODOS.forEach((n, i) => {
            const on = sel.includes(n.n);
            halos[i].style.opacity = on ? '.25' : '0';
            halos[i].style.fill = color;
            puntos[i].style.fill = on ? color : 'var(--tx-4)';
        });
    };
    const posicion = (ev) => {
        const r = svg.getBoundingClientRect();
        return { x: (ev.clientX - r.left) / r.width * 300, y: (ev.clientY - r.top) / r.height * 300 };
    };
    const tocar = (p) => {
        for (const n of NODOS) {
            if (sel.includes(n.n) || Math.hypot(p.x - n.x, p.y - n.y) > RADIO_TOQUE) continue;
            if (sel.length) {
                const medio = nodoIntermedio(sel[sel.length - 1], n.n);
                if (medio && !sel.includes(medio)) sel.push(medio);
            }
            sel.push(n.n);
            if (navigator.vibrate) navigator.vibrate(8);
            break;
        }
    };
    const terminar = () => {
        if (!activo) return;
        activo = false; cursor = null; pintar();
        if (!sel.length) return;
        bloqueado = true;
        alTerminar(sel.slice());
    };

    svg.onpointerdown = (ev) => {
        if (bloqueado) return;
        ev.preventDefault();
        try { svg.setPointerCapture(ev.pointerId); } catch (e) { /* noop */ }
        sel = []; activo = true; color = 'var(--acc)';
        cursor = posicion(ev); tocar(cursor); pintar();
    };
    svg.onpointermove = (ev) => {
        if (!activo) return;
        cursor = posicion(ev); tocar(cursor); pintar();
    };
    svg.onpointerup = terminar;
    svg.onpointercancel = terminar;

    return {
        reiniciar() { sel = []; activo = false; bloqueado = false; color = 'var(--acc)'; pintar(); },
        error() { color = 'var(--bad)'; pintar(); },
        ok() { color = 'var(--ok)'; pintar(); }
    };
}

// ---------- Punto de entrada ----------
/**
 * Pantalla de acceso de un empleado ya elegido: patrón si lo tiene, PIN si no.
 * @param {HTMLElement} app  contenedor donde se pinta.
 * @param {{id:number, nombre:string}} emp
 * @param {{volver: () => void, alEntrar: (fila:{token:string, empleado_id:number, empleado_nombre:string}) => void}} cb
 */
export async function accesoOperador(app, emp, { volver, alEntrar }) {
    // ¿Existe la migración y el empleado ya tiene patrón? Si el RPC falla, solo PIN.
    let soportado = false, tiene = false;
    try {
        const { data, error } = await supabaseClient.rpc('ot_tiene_patron', { p_empleado_id: emp.id });
        if (!error) { soportado = true; tiene = data === true; }
    } catch (e) { /* solo PIN */ }

    const entrarConFila = (data) => (Array.isArray(data) ? data[0] : data);

    // ----- Crear / cambiar patrón (ya con sesión abierta por PIN) -----
    const pantallaCrear = (fila) => {
        let primero = null;
        app.innerHTML = `
            <div class="p-4 max-w-xs mx-auto">
                <h2 class="text-base font-bold text-slate-100 text-center mb-1">${esc(emp.nombre)}</h2>
                <p id="ptTitulo" class="text-xs text-slate-400 text-center mb-1"></p>
                <p id="ptMsg" class="text-rose-400 text-xs text-center h-4 mb-2"></p>
                <div id="ptTablero" class="mx-auto" style="width:min(80vw,300px);aspect-ratio:1"></div>
                <button id="ptOmitir" class="block mx-auto mt-4 text-xs text-slate-400">Ahora no</button>
            </div>`;
        const titulo = document.getElementById('ptTitulo');
        const msg = document.getElementById('ptMsg');
        const paso1 = () => { primero = null; titulo.textContent = `Dibuja tu patrón (une al menos ${MIN_PUNTOS} puntos)`; };
        paso1();
        document.getElementById('ptOmitir').onclick = () => alEntrar(fila);

        const tablero = montarTablero(document.getElementById('ptTablero'), async (sec) => {
            msg.className = 'text-rose-400 text-xs text-center h-4 mb-2';
            if (sec.length < MIN_PUNTOS) {
                msg.textContent = `Une al menos ${MIN_PUNTOS} puntos.`;
                tablero.error(); setTimeout(() => { msg.textContent = ''; tablero.reiniciar(); }, 800);
                return;
            }
            const clave = sec.join('-');
            if (!primero) {
                primero = clave;
                titulo.textContent = 'Dibújalo otra vez para confirmar';
                msg.textContent = '';
                setTimeout(() => tablero.reiniciar(), 350);
                return;
            }
            if (clave !== primero) {
                msg.textContent = 'No coincide. Empieza de nuevo.';
                tablero.error();
                setTimeout(() => { msg.textContent = ''; paso1(); tablero.reiniciar(); }, 900);
                return;
            }
            msg.textContent = 'Guardando...';
            const { error } = await supabaseClient.rpc('ot_set_patron', { p_token: fila.token, p_patron: clave });
            if (error) {
                msg.textContent = error.message || 'No se pudo guardar el patrón.';
                tablero.error();
                setTimeout(() => { msg.textContent = ''; paso1(); tablero.reiniciar(); }, 1200);
                return;
            }
            tablero.ok();
            msg.className = 'text-emerald-400 text-xs text-center h-4 mb-2';
            msg.textContent = 'Patrón guardado ✓';
            setTimeout(() => alEntrar(fila), 800);
        });
    };

    // ----- Ofrecer crear patrón la primera vez -----
    const pantallaOferta = (fila) => {
        app.innerHTML = `
            <div class="p-4 max-w-xs mx-auto text-center">
                <h2 class="text-base font-bold text-slate-100 mb-2">${esc(emp.nombre)}</h2>
                <p class="text-sm text-slate-300 mb-1">¿Quieres entrar con un patrón?</p>
                <p class="text-xs text-slate-400 mb-4">Como en el desbloqueo del celular: dibujas una figura uniendo puntos, sin escribir el PIN. El PIN sigue sirviendo siempre.</p>
                <button id="ptCrear" class="w-full bg-sky-600 text-white rounded-xl py-3 text-sm font-semibold mb-2">Crear mi patrón</button>
                <button id="ptNo" class="w-full bg-slate-900 border border-slate-800 text-slate-300 rounded-xl py-3 text-sm">Ahora no</button>
            </div>`;
        document.getElementById('ptCrear').onclick = () => pantallaCrear(fila);
        document.getElementById('ptNo').onclick = () => { guardarOmitido(emp.id); alEntrar(fila); };
    };

    // ----- Dibujar el patrón para entrar -----
    const pantallaPatron = () => {
        app.innerHTML = `
            <div class="p-4 max-w-xs mx-auto">
                <button id="volver" class="text-xs text-slate-400 mb-2">‹ Volver</button>
                <h2 class="text-base font-bold text-slate-100 text-center mb-1">${esc(emp.nombre)}</h2>
                <p class="text-xs text-slate-400 text-center mb-1">Dibuja tu patrón</p>
                <p id="ptMsg" class="text-rose-400 text-xs text-center h-4 mb-2"></p>
                <div id="ptTablero" class="mx-auto" style="width:min(80vw,300px);aspect-ratio:1"></div>
                <button id="usarPin" class="block mx-auto mt-4 text-xs text-slate-400">Usar mi PIN</button>
            </div>`;
        document.getElementById('volver').onclick = volver;
        document.getElementById('usarPin').onclick = () => pantallaPin('entrar');
        const msg = document.getElementById('ptMsg');

        const tablero = montarTablero(document.getElementById('ptTablero'), async (sec) => {
            if (sec.length < MIN_PUNTOS) {
                msg.textContent = `Une al menos ${MIN_PUNTOS} puntos.`;
                tablero.error(); setTimeout(() => { msg.textContent = ''; tablero.reiniciar(); }, 800);
                return;
            }
            msg.textContent = 'Verificando...';
            const { data, error } = await supabaseClient.rpc('ot_login_patron', { p_empleado_id: emp.id, p_patron: sec.join('-') });
            const fila = entrarConFila(data);
            if (error || !fila) {
                msg.textContent = error ? error.message : 'Patrón incorrecto';
                tablero.error();
                setTimeout(() => { tablero.reiniciar(); }, 900);
                return;
            }
            tablero.ok();
            alEntrar(fila);
        });
    };

    // ----- Teclado de PIN (modo 'entrar' o 'crear') -----
    const pantallaPin = (modo) => {
        let pin = '';
        const render = (msg = '') => {
            const subtitulo = modo === 'crear' ? 'Ingresa tu PIN para crear tu patrón' : 'Ingresa tu PIN de 4 dígitos';
            const enlaces = !soportado ? '' : (tiene
                ? `<button id="ptUsar" class="text-xs text-slate-400">Usar patrón</button>
                   <button id="ptCambiar" class="text-xs text-slate-400">${modo === 'crear' ? 'Solo entrar' : 'Cambiar mi patrón'}</button>`
                : `<button id="ptCambiar" class="text-xs text-slate-400">${modo === 'crear' ? 'Solo entrar' : 'Crear un patrón'}</button>`);
            app.innerHTML = `
                <div class="p-4 max-w-xs mx-auto">
                    <button id="volver" class="text-xs text-slate-400 mb-2">‹ Volver</button>
                    <h2 class="text-base font-bold text-slate-100 text-center mb-1">${esc(emp.nombre)}</h2>
                    <p class="text-xs text-slate-400 text-center mb-3">${subtitulo}</p>
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
                    <div class="flex justify-center gap-6 mt-4">${enlaces}</div>
                </div>`;

            document.getElementById('volver').onclick = volver;
            document.getElementById('borrar').onclick = () => { pin = pin.slice(0, -1); render(); };
            const usar = document.getElementById('ptUsar');
            if (usar) usar.onclick = pantallaPatron;
            const cambiar = document.getElementById('ptCambiar');
            if (cambiar) cambiar.onclick = () => pantallaPin(modo === 'crear' ? 'entrar' : 'crear');

            document.querySelectorAll('.tecla').forEach(t => {
                t.onclick = async () => {
                    if (pin.length >= 4) return;
                    pin += t.dataset.n;
                    if (pin.length < 4) { render(); return; }
                    render('Verificando...');

                    const { data, error } = await supabaseClient.rpc('ot_login', { p_empleado_id: emp.id, p_pin: pin });
                    const fila = entrarConFila(data);
                    if (error || !fila) { pin = ''; render(error ? error.message : 'PIN incorrecto'); return; }

                    if (modo === 'crear') pantallaCrear(fila);
                    else if (soportado && !tiene && !leerOmitido(emp.id)) pantallaOferta(fila);
                    else alEntrar(fila);
                };
            });
        };
        render();
    };

    if (soportado && tiene) pantallaPatron();
    else pantallaPin('entrar');
}
