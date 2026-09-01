import { verificarConexionReal, cargarCatalogoInicial } from './catalogo.js';
import { cargarInventarioCompleto } from './inventario.js';
import { configurarFormularioCompras, toggleTipoCambio } from './compras.js';
import { configurarFormularioEntradasDirectas } from './entradas.js';
import { cargarModuloProduccion } from './produccion.js';
import { cargarModuloProveedores } from './proveedores.js';
import { cargarModuloSalidas } from './salidas.js';
import { cargarVistaKardex } from './kardex.js'; 
import { cargarVistaDocumentos } from './documentos.js'; 
import { cargarModuloPlantillas } from './plantillas.js';
import { cargarModuloEmpleados } from './empleados.js';
import { cargarModuloImportador } from './importador.js';
import { cargarModuloClientes } from './clientes.js';
import { cargarModuloContabilidad, cargarModuloPolizas, cargarModuloGastos, cargarModuloReportesContables } from './contabilidad.js';
import { cargarModuloNomina, actualizarBannerNominaPendiente } from './nomina.js';
import { cargarModuloTareas } from './tareas.js';
import { cargarModuloIsr } from './isr.js';
import { cargarModuloReportes } from './reportes.js';
import { montarLogin, cerrarSesion } from './auth.js';

// 1. Exposición de funciones al scope global para eventos HTML (onclick)
window.toggleSubmenu = function(submenuId) {
    const submenu = document.getElementById(submenuId);
    if (!submenu) return;
    
    const flechaId = submenuId.replace('submenu-', 'flecha-');
    const flecha = document.getElementById(flechaId);

    submenu.classList.toggle('hidden');
    
    if (flecha) {
        flecha.style.transform = submenu.classList.contains('hidden') ? 'rotate(0deg)' : 'rotate(180deg)';
    }
};

window.toggleTipoCambio = toggleTipoCambio;

// ===== Navegación: riel de iconos + cajón lateral (Opción 6) =====
// - Escritorio: el riel de 56 px está siempre; el cajón con rótulos flota
//   junto al riel y se abre con ☰. El botón 📌 lo fija como columna.
// - Móvil / tableta: no hay riel; ☰ (barra superior) abre el cajón sobre
//   el contenido, igual que antes.
const NAV_KEY = 'hares_nav_fijado';
const esEscritorio = () => window.matchMedia('(min-width: 1024px)').matches;
const navFijado = () => document.documentElement.getAttribute('data-nav') === 'fijado';

window.abrirCajon = function() {
    const sb = document.getElementById('sidebar');
    const bd = document.getElementById('sidebarBackdrop');
    if (!sb) return;
    if (esEscritorio()) {
        if (navFijado()) return;
        sb.classList.add('nav-abierto');
    } else {
        sb.classList.remove('-translate-x-full');
    }
    if (bd) bd.classList.remove('hidden');
};

window.cerrarSidebar = function() {
    const sb = document.getElementById('sidebar');
    const bd = document.getElementById('sidebarBackdrop');
    if (!sb) return;
    if (esEscritorio()) {
        if (navFijado()) return;          // fijado: no se cierra al navegar
        sb.classList.remove('nav-abierto');
    } else {
        sb.classList.add('-translate-x-full');
    }
    if (bd) bd.classList.add('hidden');
};

window.toggleSidebar = function() {
    const sb = document.getElementById('sidebar');
    if (!sb) return;
    if (esEscritorio() && navFijado()) { window.fijarSidebar(false); return; }
    const abierto = esEscritorio()
        ? sb.classList.contains('nav-abierto')
        : !sb.classList.contains('-translate-x-full');
    if (abierto) window.cerrarSidebar(); else window.abrirCajon();
};

window.fijarSidebar = function(valor) {
    const quiere = (typeof valor === 'boolean') ? valor : !navFijado();
    document.documentElement.setAttribute('data-nav', quiere ? 'fijado' : 'colapsado');
    try { localStorage.setItem(NAV_KEY, quiere ? '1' : '0'); } catch (e) {}
    const sb = document.getElementById('sidebar');
    const bd = document.getElementById('sidebarBackdrop');
    if (sb) sb.classList.remove('nav-abierto');
    if (bd) bd.classList.add('hidden');
    const b = document.getElementById('btnFijarNav');
    if (b) {
        b.classList.toggle('text-sky-400', quiere);
        b.classList.toggle('text-slate-500', !quiere);
        b.title = quiere ? 'Soltar menú' : 'Fijar menú abierto';
    }
};

// Iconos del riel: abren el cajón y despliegan esa sección (o navegan directo).
window.railNav = function(clave) {
    const submenus = {
        catalogos: 'submenu-catalogos', inventario: 'submenu-inventario',
        entradas: 'submenu-entradas', salidas: 'submenu-salidas',
        contabilidad: 'submenu-contabilidad', configuracion: 'submenu-configuracion'
    };
    const vistas = { documentos: 'documentos', produccion: 'produccion', auditoria: 'auditoria', reportes: 'reportes' };

    document.querySelectorAll('#iconRail [data-rail]').forEach(el =>
        el.classList.toggle('rail-activo', el.getAttribute('data-rail') === clave));

    if (vistas[clave]) { window.loadView(vistas[clave]); return; }

    const smId = submenus[clave];
    if (!smId) return;
    window.abrirCajon();
    const sm = document.getElementById(smId);
    if (!sm) return;
    document.querySelectorAll('#sidebar ul[id^="submenu-"]').forEach(u => {
        const flecha = document.getElementById(u.id.replace('submenu-', 'flecha-'));
        if (u === sm) {
            u.classList.remove('hidden');
            if (flecha) flecha.style.transform = 'rotate(180deg)';
        } else {
            u.classList.add('hidden');
            if (flecha) flecha.style.transform = 'rotate(0deg)';
        }
    });
    sm.scrollIntoView({ block: 'nearest' });
};

// Al CRUZAR el punto de quiebre móvil/escritorio, deja el estado limpio
// (no en cada resize, para no molestar al scroll en celulares).
let _navEscritorio = esEscritorio();
window.addEventListener('resize', () => {
    const ahora = esEscritorio();
    if (ahora === _navEscritorio) return;
    _navEscritorio = ahora;
    const sb = document.getElementById('sidebar');
    const bd = document.getElementById('sidebarBackdrop');
    if (!sb) return;
    if (!navFijado()) sb.classList.remove('nav-abierto');
    sb.classList.add('-translate-x-full');
    if (bd) bd.classList.add('hidden');
});

// 2. Enrutador global para la navegación de vistas
window.loadView = function(viewName) {
    document.querySelectorAll('.vista-seccion').forEach(section => {
        section.classList.add('hidden');
    });

    const targetSection = document.getElementById(`view-${viewName}`);
    if (targetSection) {
        targetSection.classList.remove('hidden');
    }

    window.cerrarSidebar();

    switch (viewName) {
        case 'compras': // <-- Conectado correctamente al menú "Compras / Proveedores"
            configurarFormularioCompras();
            break;
        case 'entradas-directas':
            configurarFormularioEntradasDirectas();
            break;
        case 'salidas':
            cargarModuloSalidas();
            break;
        case 'produccion':
            cargarModuloProduccion();
            break;
        case 'proveedores':
            cargarModuloProveedores();
            break;
        case 'inventario':
            cargarInventarioCompleto();
            break;
        case 'kardex':
            cargarVistaKardex();
            break;
        case 'documentos':
            cargarVistaDocumentos();
            break;
        case 'plantillas':
            cargarModuloPlantillas();
            break;
        case 'empleados':
            cargarModuloEmpleados();
            break;
        case 'importador':
            cargarModuloImportador();
            break;
        case 'clientes':
            cargarModuloClientes();
            break;
        case 'plan-cuentas':
            cargarModuloContabilidad();
            break;
        case 'polizas':
            cargarModuloPolizas();
            break;
        case 'gastos':
            cargarModuloGastos();
            break;
        case 'reportes-contables':
            cargarModuloReportesContables();
            break;
        case 'nomina':
            cargarModuloNomina();
            break;
        case 'tareas':
            cargarModuloTareas();
            break;
        case 'isr':
            cargarModuloIsr();
            break;
        case 'reportes':
            cargarModuloReportes();
            break;
        default:
            break;
    }
};

// 3. Inicialización controlada de la aplicación (solo tras iniciar sesión)
let appIniciada = false;

async function iniciarApp() {
    if (appIniciada) return;
    appIniciada = true;
    console.log("Iniciando Hares de México (Sistema Modular)...");

    try {
        await verificarConexionReal();
        await cargarCatalogoInicial();

        // Cargas simultáneas y tolerantes a fallos
        await Promise.allSettled([
            cargarInventarioCompleto(),
            cargarModuloProduccion(),
            cargarModuloProveedores(),
            cargarModuloSalidas(),
            configurarFormularioCompras(),
            configurarFormularioEntradasDirectas(),
            // Aviso global de nóminas en borrador pendientes de autorizar —
            // se ofrece a quien inicie sesión, sin importar en qué pantalla esté.
            actualizarBannerNominaPendiente()
        ]);

        console.log("Módulos inicializados correctamente.");
    } catch (error) {
        console.error("Error al inicializar la base de la aplicación:", error);
    }
}

window.cerrarSesionAdmin = async () => { await cerrarSesion(); };

document.addEventListener('DOMContentLoaded', () => {
    // Sincroniza el botón "fijar menú" con el estado guardado.
    window.fijarSidebar(document.documentElement.getAttribute('data-nav') === 'fijado');
    montarLogin(iniciarApp);
});