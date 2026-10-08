import { supabaseClient } from './supabase.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { linkDoc, linkPoliza, etiquetaPoliza } from './enlaces-reporte.js';
import { imprimirHtml, marcaDeEstatus } from './impresion.js';

// =====================================================================
//  Cuentas por pagar / Pagos a proveedores
//  Lista compras y gastos a crédito con saldo pendiente y registra el
//  pago (Cargo 201.01 Proveedores / Abono banco) vía registrar_pago_proveedor.
//  Requiere: sql/2026-09-02_pagos_proveedor.sql
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Estado del filtro de visibilidad (Pendientes / Pagadas / Canceladas / Todas)
// y el último dataset traído, para poder refiltrar sin volver a consultar.
let cxpCache = [];
let cxpCuentasPago = []; // cuentas de banco/caja, para el modal de Anticipo (reusa lo ya cargado por el módulo)
let cxpEmpleados = []; // para "Visto bueno" (ligado a un empleado real, no texto libre)
let cxpAnticiposDisp = 0; // suma de v_anticipos_oc.disponible, para la tarjeta KPI
let cxpPreOcCache = null;
let cxpFiltro = 'pendiente';
let cxpDesde = primerDiaMesISO();
let cxpHasta = hoyISO();
let cxpProveedorId = '';
let cxpDocQ = '';
// Estatus como menú desplegable en el encabezado de la columna (no pestañas), igual que la
// maqueta https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi: "Pendiente" es la unión de
// vencida + parcial + sin ningún pago (vencida/parcial se calculan aquí, el backend solo
// conoce pendiente/pagado/cancelado — v_cuentas_por_pagar.estatus_cxp).
const CXP_ESTATUS_MENU = [
    ['pendiente', 'Pendiente'], ['vencida', 'Vencida'], ['parcial', 'Parcial'], '-',
    ['pagado', 'Pagada'], ['cancelado', 'Cancelada'], '-',
    ['todas', 'Todas'],
];
const CXP_ABIERTOS = ['pendiente', 'vencida', 'parcial'];
const cxpEstLabel = (v) => CXP_ESTATUS_MENU.find((m) => Array.isArray(m) && m[0] === v)?.[1] || v;
const cxpOrden = crearOrdenTabla();
const cxpHistOrden = crearOrdenTabla('id', 'desc');

export async function cargarModuloPagosProveedor() {
    const cont = document.getElementById('contenedorPagosProveedor');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';

    let ctasPago = [];
    try {
        const { data, error } = await supabaseClient.from('cuentas_contables')
            .select('id, codigo, nombre').eq('afectable', true).eq('activa', true).order('codigo');
        if (error) throw error;
        // 102.02 (Bancos extranjeros USD) se excluye a propósito: la empresa no tiene cuenta en
        // USD, siempre paga en MXN aunque la OC esté en USD. Se deja en el catálogo para cuando
        // haya expansión a compras/ventas en el extranjero — solo se oculta de este selector.
        ctasPago = (data || []).filter(c => /^(101|102)/.test(c.codigo) && c.codigo !== '102.02');
        cxpCuentasPago = ctasPago;
    } catch (_) {
        cont.innerHTML = '<p class="text-amber-400 text-xs">El módulo de contabilidad no está instalado (faltan las cuentas contables).</p>';
        return;
    }

    try {
        const { data } = await supabaseClient.from('empleados').select('id, nombre').eq('activo', true).order('nombre');
        cxpEmpleados = data || [];
    } catch (_) { cxpEmpleados = []; }
    try {
        const { data } = await supabaseClient.from('v_anticipos_oc').select('disponible');
        cxpAnticiposDisp = (data || []).reduce((a, r) => a + Number(r.disponible || 0), 0);
    } catch (_) { cxpAnticiposDisp = 0; }

    let cxp = [];
    try {
        const { data, error } = await supabaseClient.from('v_cuentas_por_pagar').select('*').order('fecha', { ascending: true });
        if (error) throw error;
        cxp = data || [];
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-02_pagos_proveedor.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
        return;
    }

    cxpCache = cxp;
    cxpPreOcCache = window.__cxpOcPreseleccion || null;
    window.__cxpOcPreseleccion = null;
    cxpFiltro = 'pendiente';
    cxpDesde = primerDiaMesISO(); cxpHasta = hoyISO(); cxpProveedorId = '';

    cont.innerHTML = `
    <div class="space-y-4">
      <div id="cxpPanelDocumentos" class="bg-slate-950 border border-slate-800 rounded-xl p-4"></div>

      <p class="text-xs text-slate-500">
        ¿Vas a pagar antes de recibir la mercancía? Eso no es una deuda todavía, por eso no aparece en la lista de arriba:
        <button type="button" id="cxpBtnAnticipo" class="text-sky-400 hover:text-sky-300 underline">💰 pagar anticipo a una OC sin recibir</button>.
      </p>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Pagos registrados</h3>
        <div id="cxpHist" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    document.getElementById('cxpBtnAnticipo').onclick = cxpAbrirAnticipo;

    cxpPintarDocumentos();
    await cxpHistorial();
    montarGuia(cont, 'pagos-proveedor');
}

// Repinta solo el panel "Documentos por pagar" según cxpFiltro, sin
// volver a consultar Supabase (cxpCache ya trae todos los estatus).
function cxpPintarDocumentos() {
    const panel = document.getElementById('cxpPanelDocumentos');
    if (!panel) return;

    // "Pendientes de pago" nunca se oculta por fecha (es lo que debes, no
    // caduca por ser de un mes anterior) — a petición del usuario, antes
    // se escondía fuera del rango "inicio de mes a hoy" y avisaba con un
    // banner aparte; ahora simplemente siempre se ve todo. "Pagadas" /
    // "Canceladas" / "Todas" sí respetan el rango elegido (ahí sí es un
    // historial, tiene sentido acotarlo).
    const porProveedor = (x) => !cxpProveedorId || String(x.proveedor_id || '') === cxpProveedorId;
    const porDoc = (x) => !cxpDocQ || (x.folio || '').toLowerCase().includes(cxpDocQ.toLowerCase());
    const porFecha = (x) => (!cxpDesde || (x.fecha || '') >= cxpDesde) && (!cxpHasta || (x.fecha || '') <= cxpHasta);
    const esVencida = (x) => x.estatus_cxp === 'pendiente' && !!x.vence && x.vence < hoyISO();
    const esParcial = (x) => x.estatus_cxp === 'pendiente' && Number(x.pagado || 0) > 0;

    const pendientesTodas = cxpCache.filter((x) => x.estatus_cxp === 'pendiente' && porProveedor(x) && porDoc(x));
    const noPendientesConFecha = cxpCache.filter((x) => x.estatus_cxp !== 'pendiente' && porProveedor(x) && porDoc(x) && porFecha(x));
    const todasVista = [...pendientesTodas, ...noPendientesConFecha];

    const conteos = {
        pendiente: pendientesTodas.length,
        vencida: pendientesTodas.filter(esVencida).length,
        parcial: pendientesTodas.filter(esParcial).length,
        pagado: noPendientesConFecha.filter((x) => x.estatus_cxp === 'pagado').length,
        cancelado: noPendientesConFecha.filter((x) => x.estatus_cxp === 'cancelado').length,
    };

    const esAbierto = CXP_ABIERTOS.includes(cxpFiltro);
    const filtrados = cxpFiltro === 'pendiente' ? pendientesTodas
        : cxpFiltro === 'vencida' ? pendientesTodas.filter(esVencida)
        : cxpFiltro === 'parcial' ? pendientesTodas.filter(esParcial)
        : cxpFiltro === 'todas' ? todasVista
        : noPendientesConFecha.filter((x) => x.estatus_cxp === cxpFiltro);
    const totalGeneral = filtrados.reduce((a, x) => a + Number(x.saldo || 0), 0);

    aplicarOrden(cxpOrden, filtrados, (x, campo) => {
        switch (campo) {
            case 'folio': return (x.folio || String(x.id)).toLowerCase();
            case 'proveedor': return (x.proveedor_nombre || '').toLowerCase();
            case 'fecha': return x.fecha || '';
            case 'total': return Number(x.total || 0);
            case 'vence': return x.vence || '';
            case 'saldo': return Number(x.saldo || 0);
            default: return x.id;
        }
    });

    const proveedoresUnicos = new Map();
    cxpCache.forEach((x) => { if (x.proveedor_id && !proveedoresUnicos.has(x.proveedor_id)) proveedoresUnicos.set(x.proveedor_id, x.proveedor_nombre || `#${x.proveedor_id}`); });
    const listaProveedores = [...proveedoresUnicos.entries()].sort((a, b) => a[1].localeCompare(b[1], 'es'));

    // Chip de estatus por fila (Pendiente/Vencida/Parcial/Pagada/Cancelada) — igual que la maqueta.
    const chipEstatus = (x) => {
        if (x.estatus_cxp === 'cancelado') return '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-rose-950 text-rose-300">Cancelada</span>';
        if (x.estatus_cxp === 'pagado') return '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-950 text-emerald-300">Pagada</span>';
        if (esVencida(x)) return '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-rose-950 text-rose-300">Vencida</span>';
        if (esParcial(x)) return '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-sky-950 text-sky-300">Parcial</span>';
        return '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-amber-950 text-amber-300">Pendiente</span>';
    };

    // Encabezado de columna como menú desplegable (triángulo grande + valor elegido DEBAJO del
    // botón, en letra chica, para que elegir un filtro nunca ensanche la columna): mismo patrón
    // en los 3 — Documento (busca folio de OC), Proveedor (lista), Estatus (lista con conteo).
    const thFiltro = (id, titulo, etiqueta, menuHtml) => `
      <th class="p-2 relative align-top">
        <div class="inline-flex flex-col items-start gap-0.5">
          <button type="button" id="cxpTh${id}" class="inline-flex items-center gap-1 text-sky-400 hover:text-sky-300 font-semibold text-[11px] normal-case tracking-normal">${titulo}<span class="text-sm leading-none">▼</span></button>
          <span class="text-[10px] font-semibold text-sky-400 normal-case">${etiqueta}</span>
        </div>
        <div id="cxp${id}Menu" class="hidden absolute top-full left-0 mt-1 z-30 bg-slate-800 border border-slate-600 rounded-lg p-2 shadow-2xl normal-case font-normal">${menuHtml}</div>
      </th>`;

    const thDoc = thFiltro('Doc', 'Documento', cxpDocQ ? `· ${esc(cxpDocQ)}` : '', `
      <div class="w-52">
        <input type="search" id="cxpDocQInput" value="${esc(cxpDocQ)}" placeholder="Buscar folio de OC" autocomplete="off" class="w-full bg-slate-900 border border-slate-700 rounded-lg p-1.5 text-xs text-slate-100 mb-1.5">
        <button type="button" id="cxpDocClear" class="text-[11px] text-slate-400 hover:text-slate-200">Quitar búsqueda</button>
      </div>`);

    const thProv = thFiltro('Prov', 'Proveedor', cxpProveedorId ? `· ${esc(proveedoresUnicos.get(Number(cxpProveedorId)) || '')}` : '', `
      <div class="w-56">
        <input type="search" id="cxpProvQInput" placeholder="Buscar proveedor" autocomplete="off" class="w-full bg-slate-900 border border-slate-700 rounded-lg p-1.5 text-xs text-slate-100 mb-1.5">
        <div id="cxpProvLista" class="max-h-56 overflow-y-auto">
          <button type="button" data-prov="" class="cxp-prov-opt block w-full text-left text-xs px-2 py-1.5 rounded ${!cxpProveedorId ? 'text-sky-400 font-semibold' : 'text-slate-200 hover:bg-slate-700'}">Todos los proveedores</button>
          ${listaProveedores.map(([id, nombre]) => `<button type="button" data-prov="${id}" data-nombre="${esc(nombre.toLowerCase())}" class="cxp-prov-opt block w-full text-left text-xs px-2 py-1.5 rounded ${cxpProveedorId === String(id) ? 'text-sky-400 font-semibold' : 'text-slate-200 hover:bg-slate-700'}">${esc(nombre)}</button>`).join('')}
        </div>
      </div>`);

    const thEst = thFiltro('Est', 'Estatus', cxpFiltro === 'pendiente' ? '' : `· ${cxpEstLabel(cxpFiltro)}`, `
      <div class="w-48">
        ${CXP_ESTATUS_MENU.map((m) => m === '-' ? '<hr class="border-slate-700 my-1">' :
            `<button type="button" data-est="${m[0]}" class="cxp-est-opt flex items-center justify-between gap-3 w-full text-left text-xs px-2 py-1.5 rounded ${cxpFiltro === m[0] ? 'text-sky-400 font-semibold' : 'text-slate-200 hover:bg-slate-700'}"><span>${m[1]}</span><span class="text-slate-500">${m[0] === 'todas' ? todasVista.length : (conteos[m[0]] || 0)}</span></button>`
        ).join('')}
      </div>`);

    const hoy7 = new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10);
    const sumSi = (f) => pendientesTodas.filter(f).reduce((a, x) => a + Number(x.saldo || 0), 0);
    const kpis = `
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[10px] uppercase text-slate-500">Saldo total pendiente</p>
          <p class="font-mono text-lg text-slate-100">${money(sumSi(() => true))}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[10px] uppercase text-slate-500">Vencido</p>
          <p class="font-mono text-lg text-rose-400">${money(sumSi((x) => x.vence && x.vence < hoyISO()))}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[10px] uppercase text-slate-500">Vence en 7 días</p>
          <p class="font-mono text-lg text-amber-300">${money(sumSi((x) => x.vence && x.vence >= hoyISO() && x.vence <= hoy7))}</p>
        </div>
        <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
          <p class="text-[10px] uppercase text-slate-500">Anticipos disponibles</p>
          <p class="font-mono text-lg text-sky-300">${money(cxpAnticiposDisp)}</p>
          <p class="text-[10px] text-slate-500 mt-0.5">Se usan solos al pagar una OC sin recibir — sin botón aparte</p>
        </div>
      </div>`;

    panel.innerHTML = `
      ${kpis}
      <div class="flex items-center justify-between mb-2 flex-wrap gap-2">
        <h3 class="text-md font-semibold text-slate-300">Documentos por pagar</h3>
        ${esAbierto ? '' : `<span class="text-xs text-slate-400">Suma: <span class="font-mono text-amber-300">${money(totalGeneral)}</span></span>`}
      </div>
      <div class="flex flex-wrap items-end gap-2 mb-3">
        <div><label class="block text-[10px] text-slate-400 mb-1">Desde</label>
          <input type="date" id="cxpDesde" value="${cxpDesde}" ${esAbierto ? 'disabled' : ''} class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 disabled:opacity-40"></div>
        <div><label class="block text-[10px] text-slate-400 mb-1">Hasta</label>
          <input type="date" id="cxpHasta" value="${cxpHasta}" ${esAbierto ? 'disabled' : ''} class="bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100 disabled:opacity-40"></div>
        <button type="button" id="cxpLimpiarFiltros" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg">Limpiar</button>
      </div>
      ${esAbierto ? '<p class="text-[10px] text-slate-500 mb-3">"Desde/Hasta" no aplica aquí — pendientes de pago siempre se ven todos, sin importar la fecha.</p>' : ''}
      <div class="overflow-x-auto border border-slate-800 rounded-lg" style="overflow-y:visible">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            <th class="p-2">${esAbierto ? '<input type="checkbox" id="cxpAll" class="accent-emerald-500">' : ''}</th>
            ${thDoc}
            ${thProv}
            ${thOrden(cxpOrden, 'fecha', 'Fecha')}
            ${thOrden(cxpOrden, 'vence', 'Vence')}${thOrden(cxpOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpOrden, 'saldo', 'Saldo', 'text-right justify-end')}
            ${thEst}
            <th class="p-2">Póliza</th>
            <th class="p-2"></th>
          </tr></thead>
          <tbody id="cxpBody">
            ${filtrados.length ? filtrados.map((x) => {
                const pre = esAbierto && cxpPreOcCache && x.tipo === 'compra' && Number(x.orden_compra_id) === Number(cxpPreOcCache);
                const vencida = esVencida(x);
                return `
                <tr class="border-b border-slate-900 ${x.estatus_cxp === 'cancelado' ? 'opacity-60' : ''}" data-tipo="${x.tipo}" data-id="${x.id}" data-saldo="${x.saldo}" data-total="${x.total || 0}" data-oc-id="${x.orden_compra_id || ''}" data-prov="${x.proveedor_id || ''}" data-prov-nombre="${esc(x.proveedor_nombre || '—')}" data-folio="${esc(x.folio || '#' + x.id)}">
                  <td class="p-2 text-center">${esAbierto ? `<input type="checkbox" class="cxp-chk accent-emerald-500 w-4 h-4" ${pre ? 'checked' : ''}>` : ''}</td>
                  <td class="p-2">${x.tipo === 'compra' ? linkDoc(x.id, x.folio || '#' + x.id, 'text-xs font-mono text-slate-200') : `<span class="text-xs font-mono text-slate-200">${esc(x.folio || '#' + x.id)}</span>`}</td>
                  <td class="p-2 text-xs">${esc(x.proveedor_nombre || '—')}</td>
                  <td class="p-2 text-xs whitespace-nowrap text-slate-400">${x.fecha || ''}</td>
                  <td class="p-2 text-xs whitespace-nowrap ${vencida ? 'text-rose-400 font-semibold' : 'text-slate-400'}">${x.vence || '—'}</td>
                  <td class="p-2 text-right text-xs font-mono">${money(x.total)}</td>
                  <td class="p-2 text-right text-xs font-mono text-amber-300">${money(x.saldo)}</td>
                  <td class="p-2">${chipEstatus(x)}</td>
                  <td class="p-2 text-xs">${linkPoliza(x.poliza_id, 'text-xs font-mono text-sky-400 hover:underline')}</td>
                  <td class="p-2 text-right">${esAbierto ? `<button type="button" class="cxp-pagar-fila text-xs bg-sky-600 hover:bg-sky-500 text-white font-medium px-3 py-1.5 rounded-lg">Pagar</button>` : ''}</td>
                </tr>`;
            }).join('') : `<tr><td colspan="10" class="p-4 text-center text-slate-500">No hay documentos en "${cxpEstLabel(cxpFiltro).toLowerCase()}" con los filtros elegidos.</td></tr>`}
          </tbody>
        </table>
      </div>
      ${esAbierto ? `
      <div id="cxpBarraSel" class="hidden items-center justify-between gap-3 flex-wrap mt-3 border border-emerald-700 rounded-lg p-3 bg-slate-900">
        <span class="text-sm text-slate-300"><span id="cxpSelTxt"></span></span>
        <div class="flex gap-2">
          <button type="button" id="cxpLimpiarSel" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-2 rounded-lg">Limpiar</button>
          <button type="button" id="cxpRegistrar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2 rounded-lg text-sm">Pagar selección</button>
        </div>
      </div>` : ''}
      <p id="cxpMsg" class="text-xs mt-2 min-h-[1rem]"></p>
    `;

    document.getElementById('cxpDesde').onchange = (e) => { cxpDesde = e.target.value; cxpPintarDocumentos(); };
    document.getElementById('cxpHasta').onchange = (e) => { cxpHasta = e.target.value; cxpPintarDocumentos(); };
    document.getElementById('cxpLimpiarFiltros').onclick = () => { cxpDesde = ''; cxpHasta = ''; cxpProveedorId = ''; cxpDocQ = ''; cxpPintarDocumentos(); };
    wireOrdenTabla(panel, cxpOrden, cxpPintarDocumentos);
    cxpWireFiltrosEncabezado(panel);

    if (!esAbierto) return;

    // Un pago = un proveedor: al marcar uno, los demás proveedores se deshabilitan.
    const seleccionadas = () => Array.from(document.querySelectorAll('#cxpBody tr')).filter((tr) => tr.querySelector('.cxp-chk')?.checked);
    const actualizarSeleccion = () => {
        const marcadas = seleccionadas();
        const prov = marcadas[0]?.dataset.prov || '';
        document.querySelectorAll('#cxpBody tr').forEach((tr) => {
            const chk = tr.querySelector('.cxp-chk');
            if (!chk) return;
            chk.disabled = !!prov && !chk.checked && tr.dataset.prov !== prov;
            tr.classList.toggle('opacity-40', chk.disabled);
        });
        const barra = document.getElementById('cxpBarraSel');
        barra.classList.toggle('hidden', !marcadas.length);
        barra.classList.toggle('flex', marcadas.length > 0);
        const total = marcadas.reduce((a, tr) => a + (parseFloat(tr.dataset.saldo) || 0), 0);
        document.getElementById('cxpSelTxt').textContent = marcadas.length
            ? `${marcadas.length} documento(s) · ${marcadas[0].dataset.provNombre} · saldo ${money(total)}`
            : '';
    };
    document.getElementById('cxpAll').onchange = (e) => {
        document.querySelectorAll('#cxpBody .cxp-chk').forEach((c) => { c.checked = e.target.checked; });
        actualizarSeleccion();
    };
    document.querySelectorAll('#cxpBody .cxp-chk').forEach((el) => el.addEventListener('change', actualizarSeleccion));
    document.getElementById('cxpLimpiarSel').onclick = () => {
        document.querySelectorAll('#cxpBody .cxp-chk').forEach((c) => { c.checked = false; });
        document.getElementById('cxpAll').checked = false;
        actualizarSeleccion();
    };
    document.getElementById('cxpRegistrar').onclick = () => {
        const filas = seleccionadas();
        if (filas.length > 1) cxpAbrirAutorizacion(filas); else cxpAbrirPago(filas);
    };
    // "Pagar" por fila: paga solo ESE documento, sin tener que marcar su casilla primero.
    document.querySelectorAll('#cxpBody .cxp-pagar-fila').forEach((b) => {
        b.onclick = () => cxpAbrirPago([b.closest('tr')]);
    });
    actualizarSeleccion();
}

function cxpCerrarMenusFiltro() {
    ['cxpDocMenu', 'cxpProvMenu', 'cxpEstMenu'].forEach((id) => { document.getElementById(id)?.classList.add('hidden'); });
}
// Un solo listener global (como subventanas-movibles.js): cierra cualquier menú de encabezado
// abierto al tocar fuera, sin importar cuántas veces se repinte la tabla.
if (typeof document !== 'undefined' && !window.__cxpMenuListener) {
    window.__cxpMenuListener = true;
    document.addEventListener('click', (e) => {
        if (!e.target.closest('#cxpDocMenu, #cxpProvMenu, #cxpEstMenu, #cxpThDoc, #cxpThProv, #cxpThEst')) cxpCerrarMenusFiltro();
    });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') cxpCerrarMenusFiltro(); });
}

function cxpWireFiltrosEncabezado(panel) {
    const toggle = (btnId, menuId) => {
        const btn = document.getElementById(btnId);
        const menu = document.getElementById(menuId);
        if (!btn || !menu) return;
        btn.onclick = (e) => {
            e.stopPropagation();
            const abrir = menu.classList.contains('hidden');
            cxpCerrarMenusFiltro();
            if (abrir) { menu.classList.remove('hidden'); const i = menu.querySelector('input'); if (i) setTimeout(() => i.focus(), 0); }
        };
    };
    toggle('cxpThDoc', 'cxpDocMenu');
    toggle('cxpThProv', 'cxpProvMenu');
    toggle('cxpThEst', 'cxpEstMenu');

    // El buscador de Documento sí repinta todo el panel (necesita refiltrar la tabla), así que
    // sin esto perdería el foco y la posición del cursor en cada tecla.
    const docInput = document.getElementById('cxpDocQInput');
    if (docInput) docInput.oninput = (e) => {
        const pos = e.target.selectionStart;
        cxpDocQ = e.target.value;
        cxpPintarDocumentos();
        const nuevo = document.getElementById('cxpDocQInput');
        if (nuevo) { document.getElementById('cxpDocMenu')?.classList.remove('hidden'); nuevo.focus(); nuevo.setSelectionRange(pos, pos); }
    };
    document.getElementById('cxpDocClear')?.addEventListener('click', () => { cxpDocQ = ''; cxpPintarDocumentos(); });

    // El buscador de Proveedor solo filtra la lista ya pintada (no repinta nada), por eso no
    // necesita el mismo cuidado de foco.
    document.getElementById('cxpProvQInput')?.addEventListener('input', (e) => {
        const q = e.target.value.trim().toLowerCase();
        panel.querySelectorAll('.cxp-prov-opt[data-nombre]').forEach((b) => { b.classList.toggle('hidden', !!q && !b.dataset.nombre.includes(q)); });
    });
    panel.querySelectorAll('.cxp-prov-opt').forEach((b) => { b.onclick = () => { cxpProveedorId = b.dataset.prov || ''; cxpPintarDocumentos(); }; });
    panel.querySelectorAll('.cxp-est-opt').forEach((b) => { b.onclick = () => { cxpFiltro = b.dataset.est; cxpPintarDocumentos(); }; });
}

// Pagar varias OC del mismo proveedor en una sola transferencia sigue
// permitido, pero pide autorización del responsable de Finanzas antes de
// abrir el pago (por ahora un campo de texto — más adelante se ligaría al
// usuario que inició sesión con ese rol, sin tener que escribirlo).
function cxpAbrirAutorizacion(filas) {
    const total = filas.reduce((a, tr) => a + (parseFloat(tr.dataset.saldo) || 0), 0);
    cxpMostrarModal(`
      <div class="bg-slate-900 border border-slate-700 rounded-2xl p-4 max-w-md w-full">
        <div class="flex items-start justify-between gap-3 mb-2">
          <h3 class="text-base font-bold text-slate-100">Autorización requerida</h3>
          <button type="button" class="text-slate-400 hover:text-slate-100 text-xl leading-none" onclick="window.cxpAntCerrar()">&times;</button>
        </div>
        <p class="text-xs text-slate-400 mb-3">Vas a pagar ${filas.length} documentos de <b class="text-slate-200">${esc(filas[0].dataset.provNombre)}</b> en una sola transferencia (${money(total)}). Por política, esto necesita el visto bueno del responsable de Finanzas.</p>
        <div><label class="block text-[10px] text-slate-400 mb-1">Autoriza (nombre)</label>
          <input type="text" id="cxpAutNombre" placeholder="Nombre de quien autoriza" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
        <p class="text-[10px] text-sky-400 bg-sky-950/40 border border-sky-900 rounded-lg px-2.5 py-2 mt-2">Por ahora es un campo de texto libre — más adelante se ligaría al usuario que inició sesión con ese rol.</p>
        <p id="cxpAutErr" class="text-xs text-rose-400 min-h-[1rem] mt-1"></p>
        <div class="flex justify-end gap-2 mt-2">
          <button type="button" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-2 rounded-lg" onclick="window.cxpAntCerrar()">Cancelar</button>
          <button type="button" id="cxpAutOk" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Autorizar y continuar</button>
        </div>
      </div>`);
    document.getElementById('cxpAutOk').onclick = () => {
        const nombre = document.getElementById('cxpAutNombre').value.trim();
        if (!nombre) { document.getElementById('cxpAutErr').textContent = 'Escribe quién autoriza.'; return; }
        cxpAbrirPago(filas);
    };
}

// Ventana de pago: dos columnas, igual que la maqueta (https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi) —
// izquierda: proveedor/documento, qué ampara el pago (detalle real solo si es UN documento), aprobaciones;
// derecha: datos del pago, resumen y vista previa de la póliza. Pago total (saldo completo, no editable) o
// parcial (un solo documento, monto editable y acuerdo con el proveedor obligatorio).
async function cxpAbrirPago(filas) {
    if (!filas.length) return;
    const docs = filas.map((tr) => ({
        tipo: tr.dataset.tipo, id: Number(tr.dataset.id), saldo: parseFloat(tr.dataset.saldo) || 0,
        totalDoc: parseFloat(tr.dataset.total) || 0, ocId: tr.dataset.ocId ? Number(tr.dataset.ocId) : null,
        folio: tr.dataset.folio, prov: tr.dataset.provNombre,
    }));
    const provId = filas[0].dataset.prov ? Number(filas[0].dataset.prov) : null;

    cxpMostrarModal(`<div class="bg-slate-950 border border-slate-700 rounded-xl w-full max-w-sm p-5 text-sm text-slate-400 shadow-2xl">Cargando…</div>`);

    // El detalle "rico" (línea por línea, subtotal/IVA, datos de la OC, trazabilidad real: requisición
    // que autorizó la OC y nota de crédito/cargo si la hubo) solo aplica cuando se paga UN documento a
    // la vez — con varios documentos seleccionados se queda la tabla resumen folio+saldo.
    let detalle = null, proveedorInfo = null;
    if (docs.length === 1 && docs[0].tipo === 'compra') {
        try {
            const [{ data: doc }, { data: lineas }, { data: prov }, { data: oc }, { data: req }, { data: notas }] = await Promise.all([
                supabaseClient.from('documentos').select('subtotal, iva, total').eq('id', docs[0].id).maybeSingle(),
                supabaseClient.from('documento_detalles').select('cantidad, costo_unitario, subtotal, productos ( nombre, sku, cuentas_contables!cuenta_inventario_id ( codigo ) )').eq('documento_id', docs[0].id),
                provId ? supabaseClient.from('proveedores').select('nombre, rfc').eq('id', provId).maybeSingle() : Promise.resolve({ data: null }),
                docs[0].ocId ? supabaseClient.from('ordenes_compra').select('folio, fecha, dias_credito').eq('id', docs[0].ocId).maybeSingle() : Promise.resolve({ data: null }),
                docs[0].ocId ? supabaseClient.from('requisiciones_compra').select('folio, solicitada_por, revisada_por, revisada_en').eq('orden_compra_id', docs[0].ocId).maybeSingle() : Promise.resolve({ data: null }),
                supabaseClient.from('notas_compra').select('folio, tipo, monto, motivo, motivo_detalle, estatus').eq('documento_id', docs[0].id),
            ]);
            detalle = { doc: doc || {}, lineas: lineas || [], oc: oc || null, requisicion: req || null, notas: notas || [] };
            proveedorInfo = prov || null;
        } catch (_) { detalle = null; }
    }

    cxpPintarVentanaPago(docs, provId, detalle, proveedorInfo);
}

function cxpPintarVentanaPago(docs, provId, detalle, proveedorInfo) {
    const total = docs.reduce((a, d) => a + d.saldo, 0);
    const pagadoAntes = docs.reduce((a, d) => a + (d.totalDoc - d.saldo), 0);
    const provNombre = docs[0].prov;
    const opcionesCuenta = cxpCuentasPago.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const opcionesEmpleado = cxpEmpleados.map((e) => `<option value="${e.id}">${esc(e.nombre)}</option>`).join('');
    const unico = docs.length === 1;

    const bloqueProveedorDoc = `
      <div class="space-y-2">
        <div class="grid grid-cols-2 gap-x-3 gap-y-1.5 text-xs">
          <div><span class="text-slate-500 block">Proveedor</span><span class="text-slate-200">${esc(provNombre)}</span></div>
          <div><span class="text-slate-500 block">RFC</span><span class="text-slate-200 font-mono">${esc(proveedorInfo?.rfc || '—')}</span></div>
          ${unico ? `
          <div><span class="text-slate-500 block">Fecha de la ODC</span><span class="text-slate-200 font-mono">${esc(detalle?.oc?.fecha || '—')}</span></div>
          <div><span class="text-slate-500 block">Días de crédito</span><span class="text-slate-200">${detalle?.oc?.dias_credito != null ? detalle.oc.dias_credito + ' días' : '— (sin capturar)'}</span></div>
          <div class="col-span-2"><span class="text-slate-500 block">Documentos</span>
            ${docs[0].ocId ? `<button type="button" onclick="window.verDetalleOC(${docs[0].ocId})" class="text-sky-400 hover:underline">Ver ODC ${esc(detalle?.oc?.folio || '')}</button> · ` : ''}
            ${linkDoc(docs[0].id, 'Ver recepción', 'text-sky-400 hover:underline')}
            ${(detalle?.notas || []).filter((n) => n.estatus === 'activa').map((n) => ` · <span class="text-amber-300 font-mono">${esc(n.folio)}</span>`).join('')}
          </div>` : `<div class="col-span-2"><span class="text-slate-500 block">Documentos</span><span class="text-slate-200">${docs.length} seleccionados (ver tabla abajo)</span></div>`}
        </div>
      </div>`;

    const bloqueAmpara = `
      <div class="space-y-2">
        <h4 class="text-[11px] font-semibold text-slate-400 uppercase tracking-wide">Qué ampara este pago</h4>
        ${unico && detalle?.lineas?.length ? `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-[11px] text-slate-300">
            <thead class="bg-slate-900 text-slate-500 uppercase"><tr><th class="p-1.5">Código</th><th class="p-1.5">Descripción</th><th class="p-1.5">Cta.</th><th class="p-1.5 text-right">Cant.</th><th class="p-1.5 text-right">P. Unit.</th><th class="p-1.5 text-right">Importe</th></tr></thead>
            <tbody>${detalle.lineas.map((l) => `<tr class="border-t border-slate-900"><td class="p-1.5 font-mono">${esc(l.productos?.sku || '—')}</td><td class="p-1.5">${esc(l.productos?.nombre || '—')}</td><td class="p-1.5 font-mono">${esc(l.productos?.cuentas_contables?.codigo || '115.01')}</td><td class="p-1.5 text-right font-mono">${l.cantidad}</td><td class="p-1.5 text-right font-mono">${money(l.costo_unitario)}</td><td class="p-1.5 text-right font-mono">${money(l.subtotal)}</td></tr>`).join('')}</tbody>
          </table>
        </div>
        <div class="text-xs text-slate-400 space-y-0.5 text-right pr-1">
          <p>Subtotal <span class="font-mono text-slate-200">${money(detalle.doc.subtotal)}</span></p>
          <p>IVA <span class="font-mono text-slate-200">${money(detalle.doc.iva)}</span></p>
          <p class="font-semibold">Total <span class="font-mono text-amber-300">${money(detalle.doc.total)}</span></p>
        </div>` : `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-500 uppercase"><tr><th class="p-1.5">Documento</th><th class="p-1.5 text-right">Saldo</th></tr></thead>
            <tbody>${docs.map((d) => `<tr class="border-t border-slate-900"><td class="p-1.5 font-mono">${esc(d.folio)}</td><td class="p-1.5 text-right font-mono">${money(d.saldo)}</td></tr>`).join('')}</tbody>
          </table>
        </div>`}
      </div>`;

    const req = detalle?.requisicion;
    const notasActivas = (detalle?.notas || []).filter((n) => n.estatus === 'activa');
    const filaTraza = (txt) => `<p class="flex items-start gap-1.5 text-xs text-slate-300"><span class="text-emerald-400 shrink-0">✓</span><span>${txt}</span></p>`;
    const bloqueAprobaciones = `
      <div class="space-y-1.5">
        <h4 class="text-[11px] font-semibold text-slate-400 uppercase tracking-wide">Aprobaciones y trazabilidad</h4>
        ${unico && req ? filaTraza(`Requisición <b class="font-mono">${esc(req.folio)}</b> autorizada${req.revisada_por ? ' por ' + esc(req.revisada_por) : ''}${req.revisada_en ? ' · ' + esc(String(req.revisada_en).slice(0, 10)) : ''}`) : ''}
        ${unico && notasActivas.length ? notasActivas.map((n) => `<p class="flex items-start gap-1.5 text-xs text-amber-300 bg-amber-950/40 border border-amber-900 rounded-lg px-2.5 py-1.5"><span class="shrink-0">⚠</span><span>Nota ${n.tipo === 'credito' ? 'de crédito' : 'de cargo'} <b class="font-mono">${esc(n.folio)}</b> por ${money(n.monto)} — ${esc(n.motivo)}${n.motivo_detalle ? ': ' + esc(n.motivo_detalle) : ''}</span></p>`).join('') : ''}
        ${!unico ? `<p class="text-xs text-slate-500">Trazabilidad detallada solo cuando se paga un documento a la vez.</p>` : (!req && !notasActivas.length ? `<p class="text-xs text-slate-500">Sin requisición ligada ni notas de ajuste para este documento.</p>` : '')}
        <label class="block text-xs text-slate-400 mb-1 mt-1.5">Visto bueno de quien solicitó <span class="text-slate-500">· informativo, opcional</span></label>
        <select id="cxpVistoBueno" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">— sin confirmar —</option>${opcionesEmpleado}</select>
      </div>`;

    const bloqueDatosPago = `
      <div class="space-y-2">
        <h4 class="text-[11px] font-semibold text-slate-400 uppercase tracking-wide">Datos del pago</h4>
        <div class="flex gap-2">
          <button type="button" id="cxpTipoTotal" aria-pressed="true" class="text-xs px-3 py-1.5 rounded-lg border bg-sky-600 border-sky-500 text-white">Pago total</button>
          <button type="button" id="cxpTipoParcial" aria-pressed="false" class="text-xs px-3 py-1.5 rounded-lg border bg-slate-900 border-slate-800 text-slate-300">Pago parcial</button>
        </div>
        <div>
          <label class="block text-xs text-slate-400 mb-1">Monto a pagar <span id="cxpMontoHint" class="text-slate-500">· saldo de los documentos</span></label>
          <input type="number" id="cxpMonto" step="0.01" min="0" value="${total.toFixed(2)}" readonly class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm font-mono text-slate-100 opacity-80">
        </div>
        <div id="cxpAcuerdoBox" class="hidden space-y-1">
          <label class="block text-xs text-amber-300">Acuerdo con el proveedor (obligatorio en pago parcial)</label>
          <input type="text" id="cxpAcuerdo" placeholder="Ej. Anticipo 50%, saldo contra entrega, acordado con [contacto]" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
          <p class="text-[10px] text-slate-500">Idealmente esta condición se declara en la OC antes de autorizarla.</p>
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Fecha del pago</label>
            <input type="date" id="cxpFechaPago" value="${hoyISO()}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta (banco / caja)</label>
            <select id="cxpCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">— elige —</option>${opcionesCuenta}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Forma de pago</label>
            <select id="cxpFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="" selected>— elegir —</option><option value="transferencia">transferencia</option><option value="cheque">cheque</option><option value="tarjeta">tarjeta</option><option value="efectivo">efectivo</option></select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Referencia</label>
            <input type="text" id="cxpRefPago" placeholder="No. de transferencia / cheque" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <p id="cxpAlertaEfectivo" class="hidden text-xs text-amber-300 bg-amber-950/40 border border-amber-900 rounded-lg px-2.5 py-2">Pagos en efectivo mayores a $2,000 no son deducibles y su IVA no es acreditable. Confírmalo con tu contador.</p>
        <div><label class="block text-xs text-slate-400 mb-1">Notas internas</label>
          <input type="text" id="cxpNotasPago" placeholder="Opcional" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
      </div>`;

    const bloqueResumen = `
      <div class="space-y-1 text-xs border-t border-slate-800 pt-3">
        <h4 class="text-[11px] font-semibold text-slate-400 uppercase tracking-wide mb-1">Resumen</h4>
        <p class="flex justify-between"><span class="text-slate-500">Total</span><span class="font-mono text-slate-200">${money(total + pagadoAntes)}</span></p>
        <p class="flex justify-between"><span class="text-slate-500">Pagado anteriormente</span><span class="font-mono text-slate-200">${money(pagadoAntes)}</span></p>
        <p class="flex justify-between font-semibold"><span>Este pago</span><span id="cxpResumenEste" class="font-mono text-emerald-400">${money(total)}</span></p>
        <p class="flex justify-between"><span class="text-slate-500">Saldo restante</span><span id="cxpResumenSaldo" class="font-mono text-amber-300">$0.00</span></p>
      </div>
      <div id="cxpPolizaPreview" class="border border-dashed border-slate-700 rounded-lg p-3 text-xs text-slate-400">Elige la cuenta de pago para ver la póliza.</div>`;

    cxpMostrarModal(`
      <div class="bg-slate-950 border border-slate-700 rounded-xl w-full max-w-4xl max-h-[92vh] overflow-y-auto shadow-2xl">
        <div class="flex items-start justify-between gap-3 px-5 py-4 border-b border-slate-800">
          <div>
            <h3 class="text-md font-semibold text-slate-100">Registrar pago · <span class="font-mono text-emerald-400">${unico ? esc(docs[0].folio) : esc(provNombre)}</span></h3>
            <p class="text-xs text-slate-400">${docs.length} documento(s) · ${esc(provNombre)} · saldo ${money(total)}</p>
          </div>
          <button type="button" class="text-slate-400 hover:text-slate-100 text-xl leading-none" onclick="window.cxpAntCerrar()">&times;</button>
        </div>
        <div class="p-5 grid md:grid-cols-2 gap-5">
          <div class="space-y-4">${bloqueProveedorDoc}${bloqueAmpara}${bloqueAprobaciones}</div>
          <div class="space-y-4">
            ${bloqueDatosPago}
            ${bloqueResumen}
            <p id="cxpPagoErr" class="text-xs text-rose-400 min-h-[1rem]"></p>
            <div class="flex justify-end gap-2">
              <button type="button" class="text-sm bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-4 py-2 rounded-lg" onclick="window.cxpAntCerrar()">Cancelar</button>
              <button type="button" id="cxpConfirmarPago" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2 rounded-lg text-sm">Confirmar pago</button>
            </div>
          </div>
        </div>
      </div>`);

    let parcial = false;
    const monto = document.getElementById('cxpMonto');
    const err = document.getElementById('cxpPagoErr');
    const actualizarPolizaPreview = () => {
        const ctaId = document.getElementById('cxpCuentaPago').value;
        const cta = cxpCuentasPago.find((c) => String(c.id) === ctaId);
        const prev = document.getElementById('cxpPolizaPreview');
        if (!cta) { prev.textContent = 'Elige la cuenta de pago para ver la póliza.'; return; }
        const serie = cta.codigo.startsWith('101') ? 'VAE' : 'BAN';
        prev.innerHTML = `<p class="text-slate-300 font-semibold mb-1.5">Póliza ${serie}-… · Egreso (se genera al confirmar)</p>
          <div class="flex justify-between"><span>201.01 Proveedores</span><span class="font-mono">Cargo</span></div>
          <div class="flex justify-between"><span>${esc(cta.codigo)} ${esc(cta.nombre)}</span><span class="font-mono">Abono</span></div>`;
    };
    const validar = () => {
        const m = parseFloat(monto.value) || 0;
        let e = '';
        if (parcial) {
            if (docs.length !== 1) e = 'El pago parcial solo aplica a un documento a la vez.';
            else if (m <= 0) e = 'El monto debe ser mayor a cero.';
            else if (m >= total - 0.005) e = 'Si paga el saldo completo, usa «Pago total».';
            else if (!document.getElementById('cxpAcuerdo').value.trim()) e = 'Escribe el acuerdo con el proveedor.';
        }
        err.textContent = e;
        document.getElementById('cxpConfirmarPago').disabled = !!e;
        const forma = document.getElementById('cxpFormaPago').value;
        document.getElementById('cxpAlertaEfectivo').classList.toggle('hidden', !(forma === 'efectivo' && m > 2000));
        document.getElementById('cxpResumenEste').textContent = money(m);
        document.getElementById('cxpResumenSaldo').textContent = money(Math.max(0, total - m));
    };
    const fijarTipo = (esParcial) => {
        parcial = esParcial;
        document.getElementById('cxpTipoTotal').setAttribute('aria-pressed', String(!parcial));
        document.getElementById('cxpTipoParcial').setAttribute('aria-pressed', String(parcial));
        document.getElementById('cxpTipoTotal').className = `text-xs px-3 py-1.5 rounded-lg border ${!parcial ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300'}`;
        document.getElementById('cxpTipoParcial').className = `text-xs px-3 py-1.5 rounded-lg border ${parcial ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-900 border-slate-800 text-slate-300'}`;
        monto.readOnly = !parcial; monto.classList.toggle('opacity-80', !parcial);
        document.getElementById('cxpAcuerdoBox').classList.toggle('hidden', !parcial);
        document.getElementById('cxpMontoHint').textContent = parcial ? '· menor al saldo' : '· saldo de los documentos';
        monto.value = parcial ? '' : total.toFixed(2);
        validar();
    };
    document.getElementById('cxpTipoTotal').onclick = () => fijarTipo(false);
    document.getElementById('cxpTipoParcial').onclick = () => fijarTipo(true);
    monto.oninput = validar;
    document.getElementById('cxpAcuerdo').oninput = validar;
    document.getElementById('cxpFormaPago').onchange = validar;
    document.getElementById('cxpCuentaPago').onchange = actualizarPolizaPreview;
    document.getElementById('cxpConfirmarPago').onclick = () => registrarPago(docs, parcial);
    validar();
    actualizarPolizaPreview();
}

async function registrarPago(docs, parcial) {
    const err = document.getElementById('cxpPagoErr');
    const cuenta = document.getElementById('cxpCuentaPago').value;
    if (!cuenta) { err.textContent = 'Elige la cuenta de banco / caja.'; return; }
    const m = parseFloat(document.getElementById('cxpMonto').value) || 0;
    const acuerdo = document.getElementById('cxpAcuerdo').value.trim();
    const aplicaciones = parcial
        ? [{ tipo: docs[0].tipo, id: docs[0].id, monto: m }]
        : docs.map((d) => ({ tipo: d.tipo, id: d.id, monto: d.saldo }));
    const btn = document.getElementById('cxpConfirmarPago');
    btn.disabled = true;
    try {
        const { data, error } = await supabaseClient.rpc('registrar_pago_proveedor', {
            p_datos: {
                fecha: document.getElementById('cxpFechaPago').value || hoyISO(),
                cuenta_pago_id: Number(cuenta),
                forma_pago: document.getElementById('cxpFormaPago').value || null,
                referencia: document.getElementById('cxpRefPago').value.trim() || null,
                notas: document.getElementById('cxpNotasPago').value.trim() || null,
                visto_bueno_empleado_id: document.getElementById('cxpVistoBueno').value ? Number(document.getElementById('cxpVistoBueno').value) : null,
                aplicaciones,
            },
        });
        if (error) throw error;
        if (parcial) {
            const { error: eA } = await supabaseClient.rpc('pago_proveedor_set_acuerdo', { p_pago_id: data.pago_id, p_acuerdo: acuerdo });
            if (eA) alert('El pago se registró, pero no se pudo guardar el acuerdo: ' + eA.message);
        }
        alert(`✅ Pago registrado por ${money(data.total)} (${aplicaciones.length} documento(s)). Póliza de Egreso generada.`);
        window.cxpAntCerrar();
        await cargarModuloPagosProveedor();
    } catch (e) {
        err.textContent = 'No se pudo registrar el pago: ' + (e.message || e);
        btn.disabled = false;
    }
}

// Comprobante de pago a proveedor (mismo estilo de impresión que el resto de la app).
async function cxpImprimirComprobante(id) {
    try {
        const { data: p, error } = await supabaseClient.from('pagos_proveedor')
            .select('id, fecha, total, referencia, forma_pago, notas, estatus, poliza_id, proveedores ( nombre, rfc ), cuentas_contables!cuenta_pago_id ( codigo, nombre ), pagos_proveedor_aplicaciones ( tipo, monto, documentos ( folio ), gastos ( concepto, folio_factura ) )')
            .eq('id', id).single();
        if (error) throw error;
        const pol = p.poliza_id ? await etiquetaPoliza(p.poliza_id) : '—';
        const filas = (p.pagos_proveedor_aplicaciones || []).map((a) => `<tr>
            <td>${a.tipo === 'gasto' ? 'Gasto' : a.tipo === 'compra' ? 'Compra' : esc(a.tipo)}</td>
            <td>${esc(a.tipo === 'gasto' ? [a.gastos?.concepto, a.gastos?.folio_factura].filter(Boolean).join(' · ') : (a.documentos?.folio || '—'))}</td>
            <td style="text-align:right">${money(a.monto)}</td></tr>`).join('');
        await imprimirHtml('pago_proveedor', `Pago a proveedor #${p.id}`, `
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:3px 12px;margin-bottom:6px">
                <div><b>Proveedor:</b> ${esc(p.proveedores?.nombre || '(varios)')}</div>
                <div><b>RFC:</b> ${esc(p.proveedores?.rfc || '—')}</div>
                <div><b>Fecha:</b> ${esc(p.fecha || '')}</div>
                <div><b>Forma de pago:</b> ${esc(p.forma_pago || '—')}</div>
                <div><b>Referencia:</b> ${esc(p.referencia || '—')}</div>
                <div><b>Cuenta de salida:</b> ${p.cuentas_contables ? esc(p.cuentas_contables.codigo + ' · ' + p.cuentas_contables.nombre) : '—'}</div>
                <div><b>Póliza:</b> ${esc(pol)}</div>
                <div><b>Estatus:</b> ${esc(p.estatus)}</div>
            </div>
            <table><thead><tr><th>Tipo</th><th>Documento aplicado</th><th style="text-align:right">Monto</th></tr></thead>
            <tbody>${filas || '<tr><td colspan="3">Sin documentos aplicados.</td></tr>'}</tbody>
            <tfoot><tr><td colspan="2" style="text-align:right"><b>Total pagado</b></td><td style="text-align:right"><b>${money(p.total)}</b></td></tr></tfoot></table>
            ${p.notas ? `<p style="margin-top:6px"><b>Notas:</b> ${esc(p.notas)}</p>` : ''}
            <div style="display:flex;gap:40px;margin-top:28px"><div style="flex:1;border-top:1px solid #555;text-align:center;padding-top:2px">Elaboró</div><div style="flex:1;border-top:1px solid #555;text-align:center;padding-top:2px">Recibió proveedor</div></div>`, marcaDeEstatus(p.estatus));
    } catch (e) { alert('No se pudo armar el comprobante: ' + (e.message || e)); }
}

async function cxpHistorial() {
    const cont = document.getElementById('cxpHist');
    try {
        const selCompleto = 'id, fecha, total, referencia, forma_pago, estatus, poliza_id, visto_bueno_at, proveedores ( nombre ), empleados!visto_bueno_empleado_id ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto )';
        const selBase = 'id, fecha, total, referencia, forma_pago, estatus, poliza_id, proveedores ( nombre ), pagos_proveedor_aplicaciones ( tipo, monto )';
        let { data, error } = await supabaseClient.from('pagos_proveedor').select(selCompleto).order('id', { ascending: false }).limit(100);
        if (error && /does not exist|schema cache|could not find/i.test(error.message || '')) {
            ({ data, error } = await supabaseClient.from('pagos_proveedor').select(selBase).order('id', { ascending: false }).limit(100));
        }
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin pagos registrados.</p>'; return; }

        aplicarOrden(cxpHistOrden, data, (p, campo) => {
            switch (campo) {
                case 'fecha': return p.fecha || '';
                case 'proveedor': return (p.proveedores?.nombre || '').toLowerCase();
                case 'ref': return (p.referencia || '').toLowerCase();
                case 'total': return Number(p.total || 0);
                case 'docs': return (p.pagos_proveedor_aplicaciones || []).length;
                case 'estatus': return p.estatus || '';
                default: return p.id;
            }
        });

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2 text-left">Acción</th>${thOrden(cxpHistOrden, 'fecha', 'Fecha')}${thOrden(cxpHistOrden, 'proveedor', 'Proveedor')}${thOrden(cxpHistOrden, 'ref', 'Ref.')}
              ${thOrden(cxpHistOrden, 'total', 'Total', 'text-right justify-end')}${thOrden(cxpHistOrden, 'docs', '# Docs', 'text-center justify-center')}<th class="p-2">Póliza</th><th class="p-2">Visto bueno</th>${thOrden(cxpHistOrden, 'estatus', 'Estatus')}
            </tr></thead>
            <tbody>
              ${data.map(p => `
                <tr class="border-b border-slate-900 ${p.estatus === 'cancelado' ? 'opacity-50' : ''}">
                  <td class="p-2 whitespace-nowrap"><button type="button" class="cxp-print text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded mr-1" data-id="${p.id}" title="Imprimir comprobante de pago">🖨️</button>${p.estatus === 'registrado' ? `<button type="button" class="cxp-cancel text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded" data-id="${p.id}">Cancelar</button>` : ''}</td>
                  <td class="p-2 whitespace-nowrap">${p.fecha || ''}</td>
                  <td class="p-2">${esc(p.proveedores?.nombre || '(varios)')}</td>
                  <td class="p-2 text-slate-400">${esc(p.referencia || '')}</td>
                  <td class="p-2 text-right font-mono">${money(p.total)}</td>
                  <td class="p-2 text-center font-mono text-slate-400">${(p.pagos_proveedor_aplicaciones || []).length}</td>
                  <td class="p-2">${p.poliza_id ? `<button type="button" onclick="window.verPolizaDeDocumento(${p.poliza_id}, '${p.fecha || ''}')" class="text-[11px] bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-2 py-1 rounded cursor-pointer">🧾 Póliza #${p.poliza_id}</button>` : '<span class="text-slate-500">—</span>'}</td>
                  <td class="p-2 text-slate-400">${p.empleados?.nombre ? `✓ ${esc(p.empleados.nombre)}` : '<span class="text-slate-600">—</span>'}</td>
                  <td class="p-2 ${p.estatus === 'registrado' ? 'text-emerald-400' : 'text-rose-400'}">${esc(p.estatus)}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        cont.querySelectorAll('.cxp-print').forEach(b => { b.onclick = () => cxpImprimirComprobante(Number(b.dataset.id)); });
        cont.querySelectorAll('.cxp-cancel').forEach(b => {
            b.onclick = async () => {
                if (!confirm('¿Cancelar este pago? Se genera la póliza de reverso y los saldos vuelven a quedar pendientes.')) return;
                const { error } = await supabaseClient.rpc('cancelar_pago_proveedor', { p_pago_id: Number(b.dataset.id) });
                if (error) { alert('No se pudo cancelar: ' + error.message); return; }
                await cargarModuloPagosProveedor();
            };
        });
        wireOrdenTabla(cont, cxpHistOrden, cxpHistorial);
    } catch (err) {
        cont.innerHTML = `<p class="text-slate-500 text-xs">Historial no disponible: ${esc(err.message || err)}</p>`;
    }
}

// =====================================================================
//  Anticipo a proveedor (se paga ANTES de recibir la mercancía). Antes
//  vivía como botón por fila en Órdenes de compra; a petición del usuario
//  esa pantalla ya solo muestra estatus (Recibido/Pagado) + Cancelar, así
//  que este es ahora el único punto de entrada — se elige la OC aquí en
//  vez de llegar con ella preseleccionada. Misma función del lado de la
//  base (pagar_anticipo_oc, sql/2026-10-27_anticipo_proveedores.sql).
// =====================================================================
async function cxpAbrirAnticipo() {
    let ocs = [];
    try {
        const { data, error } = await supabaseClient.from('ordenes_compra')
            .select('id, folio, proveedores ( nombre )')
            .in('estatus', ['abierta', 'recibida_parcial'])
            .order('id', { ascending: false });
        if (error) throw error;
        ocs = data || [];
    } catch (e) {
        alert('No se pudieron cargar las órdenes de compra: ' + (e.message || e));
        return;
    }
    if (!ocs.length) { alert('No hay órdenes de compra abiertas o parcialmente recibidas para pagarles un anticipo.'); return; }

    const optOc = '<option value="">— elige una orden de compra —</option>' +
        ocs.map((o) => `<option value="${o.id}">${esc(o.folio || '#' + o.id)} · ${esc(o.proveedores?.nombre || '—')}</option>`).join('');
    const optCta = '<option value="">— caja / banco —</option>' +
        cxpCuentasPago.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cxpMostrarModal(`
      <div class="bg-slate-900 border border-slate-700 rounded-2xl p-4 max-w-md w-full">
        <h3 class="text-base font-bold text-slate-100 mb-1">💰 Pagar anticipo a proveedor</h3>
        <p class="text-xs text-slate-400 mb-3">Se paga ANTES de recibir la mercancía; al recibirla, el anticipo se aplica solo contra el pasivo que se reconozca.</p>
        <div class="space-y-2">
          <div><label class="block text-[10px] text-slate-400 mb-1">Orden de compra</label>
            <select id="cxpAntOc" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optOc}</select></div>
          <p id="cxpAntInfo" class="text-[11px] text-emerald-400 min-h-[1rem]"></p>
          <div><label class="block text-[10px] text-slate-400 mb-1">Fecha</label>
            <input type="date" id="cxpAntFecha" value="${hoyISO()}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Monto a pagar</label>
            <input type="number" step="0.01" min="0.01" id="cxpAntMonto" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono"></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Cuenta (banco / caja)</label>
            <select id="cxpAntCuenta" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">${optCta}</select></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Forma de pago</label>
            <select id="cxpAntForma" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
              <option value="">—</option><option>transferencia</option><option>efectivo</option><option>cheque</option><option>tarjeta</option></select></div>
          <div><label class="block text-[10px] text-slate-400 mb-1">Referencia</label>
            <input type="text" id="cxpAntRef" placeholder="No. de transferencia / cheque" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"></div>
        </div>
        <p id="cxpAntMsg" class="text-xs mt-2 min-h-[1rem] text-rose-400"></p>
        <div class="flex justify-end gap-2 mt-3">
          <button type="button" onclick="window.cxpAntCerrar()" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-2 rounded-lg">Cancelar</button>
          <button type="button" id="cxpAntGuardar" class="text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-4 py-2 rounded-lg">Registrar pago</button>
        </div>
      </div>`);

    document.getElementById('cxpAntOc').onchange = async (e) => {
        const id = e.target.value;
        const info = document.getElementById('cxpAntInfo');
        if (!id) { info.textContent = ''; return; }
        try {
            const { data } = await supabaseClient.from('v_anticipos_oc').select('disponible').eq('orden_compra_id', Number(id)).maybeSingle();
            info.textContent = data && Number(data.disponible) > 0 ? `Ya tiene ${money(data.disponible)} de anticipo disponible sin aplicar.` : '';
        } catch (_) { info.textContent = ''; }
    };

    document.getElementById('cxpAntGuardar').onclick = async () => {
        const msg = document.getElementById('cxpAntMsg');
        const ocId = document.getElementById('cxpAntOc').value;
        const monto = parseFloat(document.getElementById('cxpAntMonto').value);
        const cuenta = document.getElementById('cxpAntCuenta').value;
        if (!ocId) { msg.textContent = 'Elige la orden de compra.'; return; }
        if (!(monto > 0)) { msg.textContent = 'Captura un monto mayor a cero.'; return; }
        if (!cuenta) { msg.textContent = 'Elige la cuenta de banco / caja.'; return; }
        const btn = document.getElementById('cxpAntGuardar');
        btn.disabled = true;
        try {
            const { data, error } = await supabaseClient.rpc('pagar_anticipo_oc', {
                p_oc_id: Number(ocId),
                p_datos: {
                    fecha: document.getElementById('cxpAntFecha').value || hoyISO(),
                    monto,
                    cuenta_pago_id: Number(cuenta),
                    forma_pago: document.getElementById('cxpAntForma').value || null,
                    referencia: document.getElementById('cxpAntRef').value.trim() || null,
                },
            });
            if (error) throw error;
            alert(`✅ Anticipo pagado por ${money(data.total)}. Póliza de Egreso generada.`);
            window.cxpAntCerrar();
            await cargarModuloPagosProveedor();
        } catch (e) {
            msg.textContent = 'No se pudo registrar el anticipo: ' + (e.message || e);
            btn.disabled = false;
        }
    };
}

function cxpMostrarModal(html) {
    let wrap = document.getElementById('cxpModalWrap');
    if (!wrap) {
        wrap = document.createElement('div');
        wrap.id = 'cxpModalWrap';
        wrap.className = 'fixed inset-0 bg-slate-950/40 flex items-center justify-center z-50 p-4';
        document.body.appendChild(wrap);
    }
    wrap.innerHTML = html;
}
window.cxpAntCerrar = () => { document.getElementById('cxpModalWrap')?.remove(); };
