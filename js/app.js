import { verificarConexionReal, cargarCatalogoInicial } from './catalogo.js';
import { cargarInventarioCompleto } from './inventario.js';
import { configurarFormularioCompras, toggleTipoCambio } from './compras.js';
import { configurarFormularioEntradasDirectas } from './entradas.js';
import { cargarModuloProduccion } from './produccion.js';
import { cargarModuloProveedores } from './proveedores.js';
import { cargarModuloSalidas } from './salidas.js';
import { cargarVistaKardex } from './kardex.js'; 
import { cargarVistaDocumentos } from './documentos.js'; 

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

// 2. Enrutador global para la navegación de vistas
window.loadView = function(viewName) {
    document.querySelectorAll('.vista-seccion').forEach(section => {
        section.classList.add('hidden');
    });
    
    const targetSection = document.getElementById(`view-${viewName}`);
    if (targetSection) {
        targetSection.classList.remove('hidden');
    }

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
        default:
            break;
    }
};

// 3. Inicialización controlada de la aplicación
document.addEventListener('DOMContentLoaded', async () => {
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
            configurarFormularioEntradasDirectas()
        ]);

        console.log("Módulos inicializados correctamente.");
    } catch (error) {
        console.error("Error al inicializar la base de la aplicación:", error);
    }
});