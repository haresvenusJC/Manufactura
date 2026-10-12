// =====================================================================
//  Buscador automático en los <select> de listas largas (proveedor, cliente,
//  cuenta contable, producto, orden...). Un solo lugar decide cuáles: cada
//  vez que aparece en pantalla un select de la lista de abajo (también dentro
//  de subventanas, que se crean al abrirse) se convierte con
//  `convertirEnBuscador` (js/buscador-select.js) — escribes parte del nombre
//  y eliges con clic o ↑ ↓ Enter. El <select> sigue siendo la fuente de verdad,
//  así que ningún módulo cambia.
//
//  Para sumar otro select: agregar su selector CSS a BUSCABLES (solo listas
//  largas o que crecen; no hace falta en listas fijas de 3-5 opciones).
//  Para excluir uno puntual: data-sin-buscador en el <select>.
// =====================================================================
import { convertirEnBuscador } from './buscador-select.js';

const POR_ID = {
    // Proveedores
    compraProveedorId: 'Escribe para buscar proveedor…', gaProveedor: 'Escribe para buscar proveedor…',
    prodProveedorId: 'Escribe para buscar proveedor…', cpProveedor: 'Escribe para buscar proveedor…',
    devpProveedor: 'Escribe para buscar proveedor…', rmRecProveedor: 'Escribe para buscar proveedor…',
    reqProdProveedor: 'Escribe para buscar proveedor…', rpProveedor: 'Escribe para buscar proveedor…',
    selectFiltroProveedor: 'Escribe para buscar proveedor…', aaProveedor: 'Escribe para buscar proveedor…',
    // Clientes
    devcCliente: 'Escribe para buscar cliente…', pvCliente: 'Escribe para buscar cliente…',
    salClienteSelect: 'Escribe para buscar cliente…', cxcFiltroCliente: 'Escribe para buscar cliente…',
    // Cuentas contables (el plan de cuentas es largo: se busca por código o nombre)
    gaCuentaGasto: 'Código o nombre de la cuenta…', gaCuentaPago: 'Código o nombre de la cuenta…',
    rcAuxCuenta: 'Código o nombre de la cuenta…', ctaPadre: 'Código o nombre de la cuenta…',
    afCtaActivo: 'Código o nombre de la cuenta…', afCtaGasto: 'Código o nombre de la cuenta…',
    afCtaAcumulada: 'Código o nombre de la cuenta…', btCtaContable: 'Código o nombre de la cuenta…',
    ccCuenta: 'Código o nombre de la cuenta…', prodCtaInventario: 'Código o nombre de la cuenta…',
    prodCtaCosto: 'Código o nombre de la cuenta…', salCuentaCargo: 'Código o nombre de la cuenta…',
    edCuentaAbono: 'Código o nombre de la cuenta…', provCuentaGasto: 'Código o nombre de la cuenta…',
    rpCuenta: 'Código o nombre de la cuenta…', rpCtaNp: 'Código o nombre de la cuenta…',
    aiCuenta: 'Código o nombre de la cuenta…', aaResCtaGasto: 'Código o nombre de la cuenta…',
    // Productos / insumos
    bomInsumo: 'Escribe para buscar por nombre o SKU…', bomAgregar: 'Escribe para buscar por nombre o SKU…',
    // Órdenes (compra / producción)
    rmOC: 'Escribe folio o proveedor…', preAdmOc: 'Escribe folio o proveedor…',
    cxpAntOc: 'Escribe folio o proveedor…', aaResOcDestino: 'Escribe folio o proveedor…',
    selectOrdenId: 'Escribe folio o producto…', gaOrden: 'Escribe folio o producto…',
};
// Selects sin id estable (los de la ODC formal llevan data-f).
const POR_SELECTOR = {
    'select[data-f="proveedor"]': 'Escribe para buscar proveedor…',
};

function intentar(select) {
    if (!(select instanceof HTMLSelectElement) || select.multiple || select.dataset.buscador === '1' || 'sinBuscador' in select.dataset) return;
    let placeholder = POR_ID[select.id];
    if (!placeholder) {
        for (const [sel, ph] of Object.entries(POR_SELECTOR)) { if (select.matches(sel)) { placeholder = ph; break; } }
    }
    if (!placeholder) return;
    try { convertirEnBuscador(select, { placeholder }); } catch (e) { console.warn('buscador-auto:', select.id, e); }
}

function recorrer(nodo) {
    if (!(nodo instanceof Element)) return;
    if (nodo.tagName === 'SELECT') intentar(nodo);
    nodo.querySelectorAll?.('select').forEach(intentar);
}

new MutationObserver((muts) => { for (const m of muts) m.addedNodes.forEach(recorrer); })
    .observe(document.body, { childList: true, subtree: true });
recorrer(document.body);
