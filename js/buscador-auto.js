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
import { supabaseClient } from './supabase.js';
import { abrirAltaVinculada } from './vinculos.js';

const PH_PROV = 'Escribe para buscar proveedor…';
const PH_CLI = 'Escribe para buscar cliente…';
// «Crear y editar…» al final de la lista: abre la pantalla de alta real del catálogo encima y, al guardar,
// deja el registro nuevo seleccionado en el campo (js/vinculos.js). Solo en campos de CAPTURA, no en filtros/reportes.
const SIN_CREAR = new Set(['selectFiltroProveedor', 'cxcFiltroCliente', 'rpProveedor', 'aaProveedor', 'pcProveedor']);
const crearDe = (entidad, tabla) => (texto, select) => abrirAltaVinculada(entidad, {
    nombre: texto,
    onGuardado: async ({ id }) => {
        const { data } = await supabaseClient.from(tabla).select('id, nombre').eq('id', id).single();
        if (!data) return;
        if (![...select.options].some((o) => o.value === String(data.id))) select.add(new Option(data.nombre, data.id));
        select.value = String(data.id);
        select.dispatchEvent(new Event('change', { bubbles: true }));
    },
});
const CREAR_POR_PH = { [PH_PROV]: crearDe('proveedor', 'proveedores'), [PH_CLI]: crearDe('cliente', 'clientes') };
const MIN_OPCIONES_AUTO = 15;   // cualquier otro select con tantas opciones también se vuelve buscador (↑ ↓ Enter)

const POR_ID = {
    // Proveedores
    compraProveedorId: 'Escribe para buscar proveedor…', gaProveedor: 'Escribe para buscar proveedor…',
    prodProveedorId: 'Escribe para buscar proveedor…', cpProveedor: 'Escribe para buscar proveedor…',
    devpProveedor: 'Escribe para buscar proveedor…', rmRecProveedor: 'Escribe para buscar proveedor…',
    reqProdProveedor: 'Escribe para buscar proveedor…', rpProveedor: 'Escribe para buscar proveedor…',
    selectFiltroProveedor: 'Escribe para buscar proveedor…', aaProveedor: 'Escribe para buscar proveedor…', pcProveedor: 'Escribe para buscar proveedor…',
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

function intentar(select, forzar = false) {
    if (!(select instanceof HTMLSelectElement) || select.multiple || select.dataset.buscador === '1' || 'sinBuscador' in select.dataset) return;
    let placeholder = POR_ID[select.id];
    if (!placeholder) {
        for (const [sel, ph] of Object.entries(POR_SELECTOR)) { if (select.matches(sel)) { placeholder = ph; break; } }
    }
    if (!placeholder) {
        // Selects largos sin registro aquí: se revisan un momento después (sus opciones se llenan al abrir la pantalla).
        if (!select.dataset.revisado) {
            select.dataset.revisado = '1';
            setTimeout(() => {
                if (select.isConnected && [...select.options].filter((o) => o.value !== '').length >= MIN_OPCIONES_AUTO) intentar(select, true);
            }, 700);
        }
        if (!forzar) return;
        placeholder = 'Escribe para buscar…';
    }
    const crear = SIN_CREAR.has(select.id) ? null : (CREAR_POR_PH[placeholder] || null);
    try { convertirEnBuscador(select, { placeholder, crear }); } catch (e) { console.warn('buscador-auto:', select.id, e); }
}

function recorrer(nodo) {
    if (!(nodo instanceof Element)) return;
    if (nodo.tagName === 'SELECT') intentar(nodo);
    nodo.querySelectorAll?.('select').forEach((s) => intentar(s));
}

new MutationObserver((muts) => { for (const m of muts) m.addedNodes.forEach(recorrer); })
    .observe(document.body, { childList: true, subtree: true });
recorrer(document.body);
