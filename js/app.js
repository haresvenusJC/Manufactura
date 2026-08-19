import { verificarConexionReal, cargarCatalogoInicial } from './catalogo.js';
import { cargarInventarioCompleto } from './inventario.js';
import { configurarFormularioCompras, toggleTipoCambio } from './compras.js';
import { cargarModuloProduccion } from './produccion.js';

// Exponer funciones globales requeridas por los eventos inline del HTML
window.loadView = function(viewName) {
    document.querySelectorAll('.vista-seccion').forEach(section => {
        section.classList.add('hidden');
    });
    
    const targetSection = document.getElementById(`view-${viewName}`);
    if (targetSection) {
        targetSection.classList.remove('hidden');
    }
};

window.toggleTipoCambio = toggleTipoCambio;

// Inicializador general del sistema
document.addEventListener('DOMContentLoaded', async () => {
    console.log("Iniciando Hares de México (Sistema Modular)...");
    await verificarConexionReal();
    await cargarCatalogoInicial();
    await cargarInventarioCompleto();
    await cargarModuloProduccion();
    configurarFormularioCompras();
});