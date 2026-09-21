import { supabaseClient } from './supabase.js';

// ---------------------------------------------------------------------------
//  Pantalla de bienvenida (Inicio): logo, saludo según la hora, el nombre de
//  quien entró y accesos rápidos. El nombre sale, en este orden, de: el que el
//  usuario eligió con ✎ (se guarda en este navegador), el nombre del perfil de
//  Supabase (user_metadata) o, si no hay, el inicio de su correo.
// ---------------------------------------------------------------------------

const LS_NOMBRE = 'hares_nombre_saludo';
let reloj = null;

// Íconos de línea (24x24, trazo con el color del tema). Se pintan con stroke="currentColor".
const ICONO = {
    fabrica:  '<path d="M3 21h18"/><path d="M5 21V11l5 3v-3l5 3V5h3.5v16"/><path d="M8 18h.01M12 18h.01M15.5 18h.01"/>',
    caja:     '<path d="M12 3 4 7v10l8 4 8-4V7z"/><path d="M4 7l8 4 8-4"/><path d="M12 11v10"/>',
    capas:    '<path d="M12 3 3 8l9 5 9-5-9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/>',
    matraz:   '<path d="M9 3h6"/><path d="M10 3v6.2L4.6 18.4A1.8 1.8 0 0 0 6.2 21h11.6a1.8 1.8 0 0 0 1.6-2.6L14 9.2V3"/><path d="M7.5 15h9"/>',
    carrito:  '<path d="M3 4h2.2l2.1 10.2a1.6 1.6 0 0 0 1.6 1.3h7.6a1.6 1.6 0 0 0 1.55-1.2L19.5 8H6.1"/><circle cx="9.5" cy="19.5" r="1.3"/><circle cx="17" cy="19.5" r="1.3"/>',
    brujula:  '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>',
    lapiz:    '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
};
const svg = (nombre) => `<svg viewBox="0 0 24 24" aria-hidden="true">${ICONO[nombre]}</svg>`;

// Accesos rápidos: [vista, ícono, título, subtítulo]
const ACCESOS = [
    ['produccion',       'fabrica', 'Producción',           'Órdenes y costos'],
    ['recibo-mercancia', 'caja',    'Recibo de mercancía',  'Entradas de compra'],
    ['inventario',       'capas',   'Inventario',           'Existencias y lotes'],
    ['catalogo',         'matraz',  'Productos y BOM',      'Catálogo y recetas'],
    ['ordenes-compra',   'carrito', 'Órdenes de compra',    'Abasto'],
    ['indice',           'brujula', 'Índice del ERP',       'Todos los módulos'],
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
                <a class="bv-editar" id="bvEditar" href="#" title="Cambiar cómo te saludo">${svg('lapiz')}</a>
            </h1>
            <p class="bv-sub">Qué bueno verte de nuevo. Aquí tienes lo de todos los días a un clic.</p>

            <div class="bv-tiles">
                ${ACCESOS.map(([vista, ico, titulo, sub]) => `
                <a class="bv-tile" href="#" data-vista="${vista}">
                    <span class="ico">${svg(ico)}</span>
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
