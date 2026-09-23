import { verificarConexionReal, cargarCatalogoInicial } from './catalogo.js';
import { cargarInventarioCompleto } from './inventario.js';
import { configurarFormularioCompras, toggleTipoCambio } from './compras.js';
import { configurarFormularioEntradasDirectas } from './entradas.js';
import { cargarModuloOrdenesCompra, cargarModuloReciboMercancia } from './ordenes-compra.js';
import { cargarModuloRequisicionesCompra } from './requisiciones-compra.js';
import { cargarModuloPagosProveedor } from './pagos-proveedor.js';
import { cargarModuloCuentasPorCobrar } from './cuentas-por-cobrar.js';
import { cargarModuloAuditoriaInventario } from './auditoria-inventario.js';
import { cargarModuloProduccion } from './produccion.js';
import { cargarModuloOrdenesProduccion } from './ordenes-produccion.js';
import { cargarModuloProveedores } from './proveedores.js';
import { cargarModuloSalidas } from './salidas.js';
import { cargarModuloPedidosVenta } from './pedidos-venta.js';
import { cargarModuloDevoluciones } from './devoluciones.js';
import { cargarModuloActivosFijos } from './activos-fijos.js';
import { cargarModuloBancosTesoreria } from './bancos-tesoreria.js';
import { cargarModuloBitacora } from './bitacora-cambios.js';
import { cargarVistaKardex } from './kardex.js'; 
import { cargarVistaDocumentos } from './documentos.js'; 
import { cargarModuloPlantillas } from './plantillas.js';
import { cargarModuloEmpleados } from './empleados.js';
import { cargarModuloImportador } from './importador.js';
import { cargarModuloImportadorClavesProveedor } from './importador-claves-proveedor.js';
import { cargarModuloImportadorBom } from './importador-bom.js';
import { cargarModuloClientes } from './clientes.js';
import { cargarModuloContabilidad, cargarModuloPolizas, cargarModuloGastos, cargarModuloReportesContables } from './contabilidad.js';
import { cargarModuloNomina, actualizarBannerNominaPendiente } from './nomina.js';
import { cargarModuloTareas } from './tareas.js';
import { cargarModuloCentrosCosto } from './centros-costo.js';
import { cargarModuloProrrateo } from './prorrateo.js';
import { cargarModuloCierrePeriodo } from './cierre-periodo.js';
import { cargarModuloAreasProrrateo } from './areas-prorrateo.js';
import { cargarModuloRepartoPlantillas } from './reparto-plantillas.js';
import { cargarModuloIndice } from './indice.js';
import { montarBienvenida } from './bienvenida.js';
import { cargarModuloIsr } from './isr.js';
import { cargarModuloReportes } from './reportes.js';
import { cargarModuloFreshStart } from './fresh-start.js';
import { montarLogin, cerrarSesion } from './auth.js';
import { abrirManual } from './asistente-contable.js';

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

// Pestañas del módulo Importar (Productos vs. BOM) — solo alternan qué
// panel se ve, los datos de cada uno ya se cargaron al entrar a la vista.
window.mostrarTabImportador = function(tab) {
    const activo = 'bg-sky-600 border-sky-500 text-white';
    const inactivo = 'bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-800';
    const btnProd = document.getElementById('tabImportadorProductos');
    const btnBom = document.getElementById('tabImportadorBom');
    const panelProd = document.getElementById('panelImportadorProductos');
    const panelBom = document.getElementById('panelImportadorBom');
    if (!btnProd || !btnBom || !panelProd || !panelBom) return;

    const esBom = tab === 'bom';
    panelProd.classList.toggle('hidden', esBom);
    panelBom.classList.toggle('hidden', !esBom);
    btnProd.className = `text-xs font-medium px-3 py-1.5 rounded-lg border transition cursor-pointer ${esBom ? inactivo : activo}`;
    btnBom.className = `text-xs font-medium px-3 py-1.5 rounded-lg border transition cursor-pointer ${esBom ? activo : inactivo}`;
};

// Botón "📖 Cómo llenar esta pantalla" de cada módulo (subventana con el manual).
window.abrirManual = abrirManual;

// Historial del navegador: cada cambio de pantalla se anota (history.pushState) para que la flecha
// ← del navegador regrese a la pantalla anterior del ERP en vez de sacar del sitio. El primer registro
// (erpBase, puesto en iniciarApp) es un tope: si se llega a él con ←, se queda en Inicio.
function registrarVistaEnHistorial(viewName) {
    if (!history.state || !history.state.erpVista) return;       // la app aún no arranca (antes del login)
    if (history.state.erpVista === viewName && !history.state.erpBase) return;   // misma pantalla: no duplicar
    history.pushState({ erpVista: viewName }, '');
}
window.addEventListener('popstate', (e) => {
    const st = e.state;
    if (!st || !st.erpVista) return;
    if (st.erpBase) {   // ← desde la primera pantalla: no salir del ERP, quedarse en Inicio
        history.pushState({ erpVista: 'bienvenida' }, '');
        window.loadView('bienvenida', { desdeHistorial: true });
        return;
    }
    window.loadView(st.erpVista, { desdeHistorial: true });
});

// 2. Enrutador global para la navegación de vistas
window.loadView = function(viewName, opciones = {}) {
    if (!opciones.desdeHistorial) registrarVistaEnHistorial(viewName);
    document.querySelectorAll('.vista-seccion').forEach(section => {
        section.classList.add('hidden');
    });

    const targetSection = document.getElementById(`view-${viewName}`);
    if (targetSection) {
        targetSection.classList.remove('hidden');
    }

    window.cerrarSidebar();

    switch (viewName) {
        case 'bienvenida':
            montarBienvenida();
            break;
        case 'indice':
            cargarModuloIndice();
            break;
        case 'compras': // <-- Conectado correctamente al menú "Compras / Proveedores"
            configurarFormularioCompras();
            break;
        case 'entradas-directas':
            configurarFormularioEntradasDirectas();
            break;
        case 'requisiciones-compra':
            cargarModuloRequisicionesCompra();
            break;
        case 'ordenes-compra':
            cargarModuloOrdenesCompra();
            break;
        case 'recibo-mercancia':
            cargarModuloReciboMercancia();
            break;
        case 'salidas':
            cargarModuloSalidas();
            break;
        case 'pedidos-venta':
            cargarModuloPedidosVenta();
            break;
        case 'devoluciones':
            cargarModuloDevoluciones();
            break;
        case 'activos-fijos':
            cargarModuloActivosFijos();
            break;
        case 'bancos-tesoreria':
            cargarModuloBancosTesoreria();
            break;
        case 'bitacora-cambios':
            cargarModuloBitacora();
            break;
        case 'produccion':
            cargarModuloProduccion();
            break;
        case 'consulta-produccion':
            cargarModuloOrdenesProduccion();
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
            cargarModuloImportadorBom();
            break;
        case 'importador-claves-proveedor':
            cargarModuloImportadorClavesProveedor();
            break;
        case 'clientes':
            cargarModuloClientes();
            break;
        case 'plan-cuentas':
            cargarModuloContabilidad();
            break;
        case 'centros-costo':
            cargarModuloCentrosCosto();
            break;
        case 'areas-prorrateo':
            cargarModuloAreasProrrateo();
            break;
        case 'reparto-plantillas':
            cargarModuloRepartoPlantillas();
            break;
        case 'prorrateo':
            cargarModuloProrrateo();
            break;
        case 'polizas':
            cargarModuloPolizas();
            break;
        case 'gastos':
            cargarModuloGastos();
            break;
        case 'pagos-proveedor':
            cargarModuloPagosProveedor();
            break;
        case 'cuentas-por-cobrar':
            cargarModuloCuentasPorCobrar();
            break;
        case 'reportes-contables':
            cargarModuloReportesContables();
            break;
        case 'cierre-periodo':
            cargarModuloCierrePeriodo();
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
        case 'auditoria':
            cargarModuloAuditoriaInventario();
            break;
        case 'fresh-start':
            cargarModuloFreshStart();
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

    // F5: el navegador conserva history.state al recargar → se vuelve a abrir la misma pantalla (no Inicio)
    // y el historial ya armado se respeta. Solo en la primera carga se pone el tope (erpBase) + Inicio,
    // para que ← nunca saque del ERP (ver registrarVistaEnHistorial).
    const st = history.state;
    const vistaRecargada = st && st.erpVista && !st.erpBase && st.erpVista !== 'bienvenida' ? st.erpVista : null;
    if (!st || !st.erpVista) {
        history.replaceState({ erpVista: 'bienvenida', erpBase: true }, '');
        history.pushState({ erpVista: 'bienvenida' }, '');
    } else if (st.erpBase) {
        history.pushState({ erpVista: 'bienvenida' }, '');
    }
    if (vistaRecargada) {   // mientras cargan los módulos, se muestra ya la sección de esa pantalla
        document.querySelectorAll('.vista-seccion').forEach((s) => s.classList.add('hidden'));
        document.getElementById(`view-${vistaRecargada}`)?.classList.remove('hidden');
    }

    // Pantalla de Inicio: se pinta de inmediato, sin esperar a las cargas de abajo.
    montarBienvenida().catch((e) => console.warn('No se pudo armar la bienvenida:', e));

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
    if (vistaRecargada) window.loadView(vistaRecargada, { desdeHistorial: true });
}

window.cerrarSesionAdmin = async () => { await cerrarSesion(); };

// cargador.js inyecta este módulo después de cargar version.json: el DOM puede estar listo ya.
function arrancarPagina() {
    // Sincroniza el botón "fijar menú" con el estado guardado.
    window.fijarSidebar(document.documentElement.getAttribute('data-nav') === 'fijado');
    montarLogin(iniciarApp);
}
if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', arrancarPagina);
else arrancarPagina();