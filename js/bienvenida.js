import { supabaseClient } from './supabase.js';

// ---------------------------------------------------------------------------
//  Pantalla de bienvenida (Inicio): logo, saludo según la hora, el nombre de
//  quien entró y accesos rápidos. El nombre sale, en este orden, de: el que el
//  usuario eligió con ✎ (se guarda en este navegador), el nombre del perfil de
//  Supabase (user_metadata) o, si no hay, el inicio de su correo.
// ---------------------------------------------------------------------------

const LS_NOMBRE = 'hares_nombre_saludo';
let reloj = null;

// Accesos rápidos: [vista, ícono, título, subtítulo]
const ACCESOS = [
    ['produccion',       '🏭', 'Producción',           'Órdenes y costos'],
    ['recibo-mercancia', '📦', 'Recibo de mercancía',  'Entradas de compra'],
    ['inventario',       '🧴', 'Inventario',           'Existencias y lotes'],
    ['catalogo',         '🧪', 'Productos y BOM',      'Catálogo y recetas'],
    ['ordenes-compra',   '🛒', 'Órdenes de compra',    'Abasto'],
    ['indice',           '🧭', 'Índice del ERP',       'Todos los módulos'],
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

async function nombreUsuario() {
    try {
        const guardado = localStorage.getItem(LS_NOMBRE);
        if (guardado) return guardado;
    } catch (_) { /* sin almacenamiento */ }
    try {
        const { data } = await supabaseClient.auth.getSession();
        const u = data?.session?.user;
        const meta = u?.user_metadata || {};
        const n = meta.nombre || meta.name || meta.full_name;
        if (n) return String(n).trim().split(/\s+/)[0];
        return nombreDesdeCorreo(u?.email);
    } catch (_) {
        return '';
    }
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

export async function montarBienvenida() {
    const cont = document.getElementById('contenedorBienvenida');
    if (!cont) return;

    const nombre = await nombreUsuario();
    const ahora = new Date();

    cont.innerHTML = `
        <div class="bv">
            <div class="bv-orbes"><div class="bv-orbe o1"></div><div class="bv-orbe o2"></div><div class="bv-orbe o3"></div></div>

            <div class="bv-logo">
                <div class="bv-disco"><img src="img/HARES_icono_tinta.svg" alt="Hares de México"></div>
            </div>

            <div id="bvFecha" class="bv-fecha">${esc(fechaHora(ahora))}</div>
            <h1 class="bv-saludo">
                <span id="bvSaludoTxt">${saludoDelDia(ahora.getHours())}</span>${nombre ? `, <span class="bv-nombre" id="bvNombre">${esc(nombre)}</span>` : ''}
                <a class="bv-editar" id="bvEditar" href="#" title="Cambiar cómo te saludo">✏️</a>
            </h1>
            <p class="bv-sub">Qué bueno verte de nuevo. Aquí tienes lo de todos los días a un clic.</p>

            <div class="bv-tiles">
                ${ACCESOS.map(([vista, ico, titulo, sub]) => `
                <a class="bv-tile" href="#" data-vista="${vista}">
                    <span class="ico">${ico}</span>
                    <span>${esc(titulo)}</span>
                    <small>${esc(sub)}</small>
                </a>`).join('')}
            </div>
        </div>`;

    cont.querySelectorAll('.bv-tile').forEach((a) => {
        a.addEventListener('click', (e) => {
            e.preventDefault();
            if (typeof window.loadView === 'function') window.loadView(a.dataset.vista);
        });
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
