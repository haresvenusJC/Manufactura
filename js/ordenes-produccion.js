// =====================================================================
//  Consulta de órdenes de producción: lista TODAS las órdenes (pendiente
//  por insumos / en proceso / cerrada / cancelada), no solo las abiertas
//  o cerradas que ya muestra la pantalla de Producción.
//
//  Su razón de ser es dar seguimiento a las que quedaron en 'borrador'
//  (pendientes por insumos, ver js/produccion.js -> generarOrdenDeProduccion):
//  cuando el BOM no alcanza al generarlas, se guardan igual -con procesos y
//  equipo ya capturados- en vez de perderse, y desde aquí se revisan y se
//  continúan (o se cancelan) en cuanto haya existencias.
// =====================================================================
import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { calcularRequerimientosProduccion, formatoCantidad, fmtFaltante, generarRequisicionFaltantes, requisicionesDeOrden } from './produccion.js';
import { imprimirConPlantilla } from './impresion.js';

const ordenTabla = crearOrdenTabla('created_at', 'desc');
let ordenesCache = [];
let filtros = { estado: '', texto: '' };

const ESTADOS = {
    borrador: { label: '📋 Pendiente por insumos', clase: 'bg-amber-950/40 text-amber-300 border-amber-800/60' },
    en_proceso: { label: '⏱️ En proceso', clase: 'bg-sky-950/40 text-sky-300 border-sky-800/60' },
    cerrada: { label: '✅ Cerrada', clase: 'bg-emerald-950/40 text-emerald-300 border-emerald-800/60' },
    cancelada: { label: '🗑 Cancelada', clase: 'bg-slate-800 text-slate-400 border-slate-700' },
};

function badgeEstado(estado) {
    const e = ESTADOS[estado] || { label: estado || '—', clase: 'bg-slate-800 text-slate-400 border-slate-700' };
    return `<span class="text-[11px] px-2 py-0.5 rounded-lg border ${e.clase}">${e.label}</span>`;
}

export async function cargarModuloOrdenesProduccion() {
    const cont = document.getElementById('contenedorOrdenesProduccionConsulta');
    if (!cont || !supabaseClient) return;

    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl space-y-4">
            <div class="flex flex-wrap gap-3 items-end">
                <div>
                    <label class="block text-xs font-medium text-slate-400 mb-1">ESTADO</label>
                    <select id="opFiltroEstado" class="bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        <option value="">Todas</option>
                        <option value="borrador">📋 Pendiente por insumos</option>
                        <option value="en_proceso">⏱️ En proceso</option>
                        <option value="cerrada">✅ Cerrada</option>
                        <option value="cancelada">🗑 Cancelada</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[180px]">
                    <label class="block text-xs font-medium text-slate-400 mb-1">BUSCAR (folio, producto o lote)</label>
                    <input type="text" id="opFiltroTexto" placeholder="Escribe para filtrar…" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                </div>
                <button type="button" id="opRefrescar" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-2 rounded-lg border border-slate-700" title="Refrescar">↻ Refrescar</button>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-sm text-left">
                    <thead class="text-slate-400 border-b border-slate-800">
                        <tr id="opTheadRow"></tr>
                    </thead>
                    <tbody id="opTbody"></tbody>
                </table>
            </div>
            <p id="opVacio" class="hidden text-slate-500 text-xs italic text-center py-4">No hay órdenes de producción que coincidan con el filtro.</p>
        </div>
        <div id="opModalDetalle"></div>
    `;

    document.getElementById('opFiltroEstado').addEventListener('change', (e) => { filtros.estado = e.target.value; pintarTabla(); });
    document.getElementById('opFiltroTexto').addEventListener('input', (e) => { filtros.texto = e.target.value.trim().toLowerCase(); pintarTabla(); });
    document.getElementById('opRefrescar').addEventListener('click', cargarOrdenes);

    await cargarOrdenes();
}

async function cargarOrdenes() {
    const tbody = document.getElementById('opTbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="7" class="p-3 text-slate-500 text-xs italic">Cargando...</td></tr>';

    const columnas = `
        id, folio, numero_lote, cantidad_producida, estado, abierta_at, created_at, faltantes_insumos,
        producto_id, productos ( nombre, sku ),
        orden_produccion_procesos (
            id, proceso_nombre,
            orden_produccion_proceso_empleados ( empleado_id, empleados ( nombre ) )
        )`;
    let { data, error } = await supabaseClient.from('ordenes_produccion').select(columnas)
        .order('created_at', { ascending: false }).limit(500);
    if (error) {   // aún sin la migración 2026-09-22 (columna faltantes_insumos)
        ({ data, error } = await supabaseClient.from('ordenes_produccion').select(columnas.replace(', faltantes_insumos', ''))
            .order('created_at', { ascending: false }).limit(500));
    }
    if (error) {
        if (tbody) tbody.innerHTML = `<tr><td colspan="7" class="p-3 text-rose-400 text-xs">Error: ${error.message}</td></tr>`;
        return;
    }
    ordenesCache = data || [];
    pintarTabla();
}

function pintarTabla() {
    const theadRow = document.getElementById('opTheadRow');
    const tbody = document.getElementById('opTbody');
    const vacio = document.getElementById('opVacio');
    if (!theadRow || !tbody) return;

    theadRow.innerHTML = [
        thOrden(ordenTabla, 'folio', 'Folio'),
        thOrden(ordenTabla, 'producto', 'Producto'),
        thOrden(ordenTabla, 'cantidad_producida', 'Cantidad', 'text-right justify-end'),
        thOrden(ordenTabla, 'numero_lote', 'Lote'),
        thOrden(ordenTabla, 'estado', 'Estado'),
        thOrden(ordenTabla, 'created_at', 'Creada'),
        `<th class="p-3">Acciones</th>`,
    ].join('');
    wireOrdenTabla(theadRow, ordenTabla, pintarTabla);

    let filas = ordenesCache.filter((o) => {
        if (filtros.estado && o.estado !== filtros.estado) return false;
        if (filtros.texto) {
            const hay = `${o.folio || ''} ${o.productos?.nombre || ''} ${o.numero_lote || ''}`.toLowerCase();
            if (!hay.includes(filtros.texto)) return false;
        }
        return true;
    });

    aplicarOrden(ordenTabla, filas, (o, campo) => {
        if (campo === 'producto') return (o.productos?.nombre || '').toLowerCase();
        if (campo === 'created_at') return o.created_at || '';
        return o[campo] ?? '';
    });

    vacio.classList.toggle('hidden', filas.length > 0);

    tbody.innerHTML = filas.map((o) => {
        const folio = o.folio || ('#' + o.id);
        const creada = o.created_at ? new Date(o.created_at).toLocaleString() : '';
        const acciones = [`<button type="button" class="btn-op-detalle text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700" data-id="${o.id}">👁 Detalle</button>`];
        if (o.estado === 'borrador') {
            acciones.push(`<button type="button" class="btn-op-continuar text-xs bg-amber-700 hover:bg-amber-600 text-white px-2 py-1 rounded-lg" data-id="${o.id}">🔄 Revisar y continuar</button>`);
            acciones.push(`<button type="button" class="btn-op-cancelar text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded-lg" data-id="${o.id}">🗑 Cancelar</button>`);
        }
        return `
            <tr class="border-b border-slate-900 align-top">
                <td class="p-3 font-mono text-amber-400">${folio}</td>
                <td class="p-3 text-slate-200">${o.productos?.nombre || 'Producto'}</td>
                <td class="p-3 text-right font-mono text-slate-300">${formatoCantidad(o.cantidad_producida)}</td>
                <td class="p-3 text-slate-400">${o.numero_lote || 'S/L'}</td>
                <td class="p-3">${badgeEstado(o.estado)}</td>
                <td class="p-3 text-slate-500 text-xs">${creada}</td>
                <td class="p-3"><div class="flex flex-wrap gap-1.5">${acciones.join('')}</div></td>
            </tr>`;
    }).join('');

    tbody.querySelectorAll('.btn-op-detalle').forEach((btn) => {
        btn.addEventListener('click', () => abrirDetalle(Number(btn.dataset.id)));
    });
    tbody.querySelectorAll('.btn-op-continuar').forEach((btn) => {
        btn.addEventListener('click', () => continuarOrdenPendiente(Number(btn.dataset.id), btn));
    });
    tbody.querySelectorAll('.btn-op-cancelar').forEach((btn) => {
        btn.addEventListener('click', () => cancelarOrdenPendiente(Number(btn.dataset.id)));
    });
}

// Exportada: también la usa la tarjeta "📋 Órdenes pendientes por insumos" de Producción
// (js/produccion.js), que pasa `alTerminar` para refrescarse en vez de esta tabla.
export async function continuarOrdenPendiente(ordenId, btn, alTerminar = null) {
    let orden = ordenesCache.find((o) => o.id === ordenId);
    if (!orden) {
        const { data } = await supabaseClient.from('ordenes_produccion')
            .select('id, folio, producto_id, cantidad_producida, estado, productos ( nombre )').eq('id', ordenId).single();
        orden = data;
    }
    if (!orden) return;
    btn.disabled = true;
    btn.textContent = 'Revisando...';

    const { error, filas } = await calcularRequerimientosProduccion(orden.producto_id, orden.cantidad_producida);
    if (error) {
        alert('No se pudo revisar existencias: ' + error);
        btn.disabled = false;
        btn.textContent = '🔄 Revisar y continuar';
        return;
    }
    const faltan = filas.filter((f) => !f.suficiente);

    if (faltan.length) {
        const snapshot = faltan.map((f) => ({ id: f.componenteId, nombre: f.nombre, unidad: f.unidad, requerido: f.requerido, disponible: f.disponible }));
        await supabaseClient.from('ordenes_produccion').update({ faltantes_insumos: snapshot }).eq('id', ordenId).select('id');
        alert(`⛔ Todavía faltan insumos para "${orden.productos?.nombre || 'este producto'}":\n${faltan.map(fmtFaltante).join('\n')}\n\nTe llevamos a generar la compra u orden de producción de lo que falta.`);
        // Mismo flujo que el botón "📝 Generar requisición de lo faltante" del formulario: para lo
        // que se fabrica en casa (semiterminados como el Granel) navega directo a Producción con el
        // producto y la cantidad ya precargados.
        await generarRequisicionFaltantes(faltan, orden.productos?.nombre || 'este producto', orden.cantidad_producida, { id: orden.id, folio: orden.folio });
        // Si no se navegó a otra pantalla, el botón vuelve a quedar usable y la lista refleja la nueva revisión.
        if (document.body.contains(btn)) {
            btn.disabled = false;
            btn.textContent = '🔄 Revisar y continuar';
            if (alTerminar) await alTerminar(); else await cargarOrdenes();
        }
        return;
    }

    if (!confirm(`Ya hay existencias suficientes. ¿Pasar la orden ${orden.folio || '#' + orden.id} a "en proceso"?`)) {
        btn.disabled = false;
        btn.textContent = '🔄 Revisar y continuar';
        return;
    }
    const { error: errUpd } = await supabaseClient.from('ordenes_produccion')
        .update({ estado: 'en_proceso', abierta_at: new Date().toISOString(), faltantes_insumos: null })
        .eq('id', ordenId);
    if (errUpd) { alert('No se pudo continuar la orden: ' + errUpd.message); btn.disabled = false; btn.textContent = '🔄 Revisar y continuar'; return; }
    alert(`✅ Orden ${orden.folio || '#' + orden.id} pasó a "en proceso". Ya aparece en Producción → Órdenes en Proceso.`);
    if (alTerminar) await alTerminar(); else await cargarOrdenes();
}

async function cancelarOrdenPendiente(ordenId) {
    const orden = ordenesCache.find((o) => o.id === ordenId);
    if (!orden) return;
    if (!confirm(`¿Cancelar la orden pendiente ${orden.folio || '#' + orden.id}? No se podrá reabrir.`)) return;
    const { error } = await supabaseClient.from('ordenes_produccion').update({ estado: 'cancelada' }).eq('id', ordenId);
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await cargarOrdenes();
}

// ---------------------------------------------------------------------
//  "👁 Detalle" = documento imprimible "Estado de la orden de producción":
//  todo lo de la orden calculado en vivo (insumos que hay / faltan, lotes a
//  surtir, procesos y tiempos, requisiciones ligadas, costos si ya cerró).
//  Va con estilos en línea (hoja blanca) para que se vea igual en pantalla
//  y al imprimir con la plantilla (imprimirConPlantilla).
// ---------------------------------------------------------------------
const escD = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fechaHora = (iso) => iso ? new Date(iso).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' }) : '—';
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
function duracion(seg) {
    const s = Math.max(0, Math.round(seg || 0));
    const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
    return h ? `${h} h ${m} min` : `${m} min`;
}
const ESTADO_TXT = { borrador: 'Pendiente por insumos', en_proceso: 'En proceso', cerrada: 'Cerrada', cancelada: 'Cancelada' };

const ST = {
    hoja: 'background:#fff;color:#111;border-radius:12px;padding:18px;font-size:12px;line-height:1.4;',
    h: 'font-size:12px;font-weight:700;margin:16px 0 6px;padding-bottom:3px;border-bottom:1px solid #ccc;text-transform:uppercase;letter-spacing:.03em;',
    tabla: 'width:100%;border-collapse:collapse;font-size:11px;',
    th: 'text-align:left;padding:4px 6px;border-bottom:1px solid #999;background:#f3f3f3;',
    thR: 'text-align:right;padding:4px 6px;border-bottom:1px solid #999;background:#f3f3f3;',
    td: 'padding:4px 6px;border-bottom:1px solid #e3e3e3;vertical-align:top;',
    tdR: 'padding:4px 6px;border-bottom:1px solid #e3e3e3;text-align:right;white-space:nowrap;vertical-align:top;',
    nota: 'font-size:10px;color:#666;',
};

// Exportada: también la usa Producción ("👁 Ver estado" en órdenes pendientes por insumos).
export async function abrirDetalle(ordenId) {
    let host = document.getElementById('opModalDetalle');
    if (!host) {   // desde otra pantalla: contenedor propio pegado a <body>
        host = document.createElement('div');
        host.id = 'opModalDetalle';
        document.body.appendChild(host);
    }
    host.innerHTML = `
        <div id="opModalOverlay" class="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/40 p-4">
            <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto p-4 space-y-3">
                <div class="flex justify-between items-center gap-3">
                    <p class="text-sm font-semibold text-amber-400">📄 Estado de la orden de producción</p>
                    <div class="flex items-center gap-2">
                        <button type="button" id="opDocImprimir" disabled class="text-xs bg-amber-600 hover:bg-amber-500 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">🖨️ Imprimir</button>
                        <button type="button" id="opModalCerrar" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer">&times;</button>
                    </div>
                </div>
                <div id="opDocEstado"><p class="text-slate-400 text-xs italic">Armando el documento...</p></div>
            </div>
        </div>`;
    const overlay = host.querySelector('#opModalOverlay');
    const cerrar = () => { host.innerHTML = ''; };
    overlay.addEventListener('click', (e) => { if (e.target === overlay) cerrar(); });
    host.querySelector('#opModalCerrar').addEventListener('click', cerrar);

    const doc = host.querySelector('#opDocEstado');
    try {
        const html = await armarDocumentoEstado(ordenId);
        if (!document.body.contains(doc)) return;   // se cerró mientras cargaba
        doc.innerHTML = html.cuerpo;
        const btn = host.querySelector('#opDocImprimir');
        btn.disabled = false;
        btn.addEventListener('click', () => imprimirConPlantilla('orden_produccion', `Estado de la orden de producción ${html.folio}`, 'opDocEstado'));
    } catch (e) {
        doc.innerHTML = `<p class="text-rose-400 text-xs">No se pudo armar el documento: ${escD(e.message || e)}</p>`;
    }
}

async function armarDocumentoEstado(ordenId) {
    const { data: o, error } = await supabaseClient.from('ordenes_produccion')
        .select(`*, productos ( nombre, sku, unidades_medida ( nombre ) ),
            orden_produccion_procesos ( id, proceso_nombre, segundos_transcurridos, costo_calculado,
                orden_produccion_proceso_empleados ( empleado_id, finalizado_at, empleados ( nombre ) ) )`)
        .eq('id', ordenId).single();
    if (error) throw error;

    const folio = o.folio || ('#' + o.id);
    const unidadProd = o.productos?.unidades_medida?.nombre || 'u';
    const cerrada = o.estado === 'cerrada';

    // Insumos: requerimiento y existencias de hoy (misma función que Producción).
    const req = await calcularRequerimientosProduccion(o.producto_id, o.cantidad_producida);
    const filas = req.filas || [];
    let tipoPorId = new Map();
    if (filas.length) {
        const { data: infos } = await supabaseClient.from('productos').select('id, tipo, abastecimiento').in('id', filas.map((f) => f.componenteId));
        tipoPorId = new Map((infos || []).map((p) => [p.id, p]));
    }
    const seFabrica = (id) => { const p = tipoPorId.get(id); return p && p.tipo === 'producto' && p.abastecimiento !== 'comprado'; };

    // Lotes a surtir (FIFO/FEFO): la vista solo trae órdenes en proceso.
    let lotes = [];
    if (o.estado === 'en_proceso') {
        const { data: lv } = await supabaseClient.from('v_ot_orden_componentes')
            .select('producto_id, producto_nombre, unidad, numero_lote, lote_proveedor, fecha_caducidad, tomar_de_lote, criterio')
            .eq('orden_id', o.id);
        lotes = (lv || []).filter((l) => l.tomar_de_lote > 0);
    }

    // Tiempos registrados por proceso y empleado.
    const procesos = o.orden_produccion_procesos || [];
    const procIds = procesos.map((p) => p.id);
    const segPor = new Map();   // `${proc}|${emp}` -> segundos
    const activos = new Set();
    if (procIds.length) {
        const { data: regs } = await supabaseClient.from('registros_tiempo')
            .select('orden_produccion_proceso_id, empleado_id, inicio, fin').in('orden_produccion_proceso_id', procIds);
        (regs || []).forEach((r) => {
            const k = `${r.orden_produccion_proceso_id}|${r.empleado_id}`;
            const fin = r.fin ? new Date(r.fin).getTime() : Date.now();
            segPor.set(k, (segPor.get(k) || 0) + Math.max(0, (fin - new Date(r.inicio).getTime()) / 1000));
            if (!r.fin) activos.add(k);
        });
    }

    const reqs = await requisicionesDeOrden(o.id);   // null = aún sin la migración de la liga

    // ---- Encabezado
    const nFalta = filas.filter((f) => !f.suficiente).length;
    const loteTxt = req.loteInfo
        ? `<p style="${ST.nota}">Receta pensada para un lote de ${formatoCantidad(req.loteInfo.rendimientoLote)} ${escD(req.loteInfo.unidad)} → esta orden equivale a ${formatoCantidad(req.loteInfo.factorLote)} lote(s).</p>` : '';
    const encabezado = `
        <table style="${ST.tabla}">
            <tr><td style="${ST.td}width:22%;"><b>Folio</b></td><td style="${ST.td}">${escD(folio)}</td>
                <td style="${ST.td}width:18%;"><b>Estado</b></td><td style="${ST.td}"><b>${escD(ESTADO_TXT[o.estado] || o.estado)}</b></td></tr>
            <tr><td style="${ST.td}"><b>Producto</b></td><td style="${ST.td}" colspan="3">${escD(o.productos?.nombre || '')}${o.productos?.sku ? ` (${escD(o.productos.sku)})` : ''}</td></tr>
            <tr><td style="${ST.td}"><b>Cantidad</b></td><td style="${ST.td}">${formatoCantidad(o.cantidad_producida)} ${escD(unidadProd)}</td>
                <td style="${ST.td}"><b>Lote</b></td><td style="${ST.td}">${escD(o.numero_lote || 'S/L')}</td></tr>
            <tr><td style="${ST.td}"><b>Creada</b></td><td style="${ST.td}">${fechaHora(o.created_at)}</td>
                <td style="${ST.td}"><b>Abierta / Cerrada</b></td><td style="${ST.td}">${fechaHora(o.abierta_at)} / ${fechaHora(o.cerrada_at)}</td></tr>
        </table>
        ${loteTxt}
        <p style="margin-top:8px;font-weight:700;">${cerrada ? '✔ Orden cerrada: los insumos ya se descontaron del inventario.'
            : (o.estado === 'cancelada' ? 'Orden cancelada.'
            : (nFalta ? `⛔ Faltan ${nFalta} de ${filas.length} insumos (existencias al ${fechaHora(new Date().toISOString())}).`
                      : `✅ Hay existencias de los ${filas.length} insumos (al ${fechaHora(new Date().toISOString())}).`))}</p>`;

    // ---- Insumos
    const mostrarExist = !cerrada && o.estado !== 'cancelada';
    const filasHtml = filas.map((f) => {
        const receta = f.recetaUnidad && f.recetaUnidadConsistente ? `${formatoCantidad(f.recetaCantidad)} ${escD(f.recetaUnidad)}` : `${formatoCantidad(f.requerido)} ${escD(f.unidad)}`;
        const falta = Math.max(0, f.requerido - f.disponible);
        const estado = f.suficiente ? '✅ Hay' : (seFabrica(f.componenteId) ? '🏭 Falta — se fabrica' : '⛔ Falta — comprar');
        return `<tr>
            <td style="${ST.td}">${escD(f.nombre)}${f.nota && f.notaTipo === 'aviso' ? `<div style="${ST.nota}">⚠ ${escD(f.nota)}</div>` : ''}</td>
            <td style="${ST.tdR}">${receta}</td>
            <td style="${ST.tdR}">${formatoCantidad(f.requerido)} ${escD(f.unidad)}</td>
            ${mostrarExist ? `<td style="${ST.tdR}">${formatoCantidad(f.disponible)} ${escD(f.unidad)}</td>
            <td style="${ST.tdR}${falta > 0 ? 'color:#b91c1c;font-weight:700;' : ''}">${falta > 0 ? formatoCantidad(falta) + ' ' + escD(f.unidad) : '—'}</td>
            <td style="${ST.td}white-space:nowrap;">${estado}</td>` : ''}
        </tr>`;
    }).join('');
    const insumos = req.error
        ? `<p style="${ST.nota}">${escD(req.error)}</p>`
        : `<table style="${ST.tabla}"><thead><tr>
                <th style="${ST.th}">Insumo</th><th style="${ST.thR}">Receta</th><th style="${ST.thR}">Requerido</th>
                ${mostrarExist ? `<th style="${ST.thR}">Disponible</th><th style="${ST.thR}">Faltante</th><th style="${ST.th}">Estado</th>` : ''}
           </tr></thead><tbody>${filasHtml}</tbody></table>`;

    // ---- Lotes a surtir
    const lotesHtml = o.estado !== 'en_proceso' ? '' : `
        <p style="${ST.h}">Lotes a surtir (FIFO / FEFO)</p>
        ${lotes.length ? `<table style="${ST.tabla}"><thead><tr><th style="${ST.th}">Insumo</th><th style="${ST.th}">Lote</th><th style="${ST.th}">Caducidad</th><th style="${ST.thR}">Tomar</th><th style="${ST.th}">Criterio</th></tr></thead><tbody>
            ${lotes.map((l) => `<tr><td style="${ST.td}">${escD(l.producto_nombre)}</td><td style="${ST.td}" class="campo-lote">${escD(l.numero_lote || l.lote_proveedor || 'S/L')}</td>
                <td style="${ST.td}">${escD(l.fecha_caducidad || '—')}</td><td style="${ST.tdR}">${formatoCantidad(l.tomar_de_lote)} ${escD(l.unidad || '')}</td><td style="${ST.td}">${escD(l.criterio || '')}</td></tr>`).join('')}
            </tbody></table>` : `<p style="${ST.nota}">Sin lotes con existencia para surtir.</p>`}`;

    // ---- Procesos y equipo
    const procesosHtml = procesos.length ? `<table style="${ST.tabla}"><thead><tr><th style="${ST.th}">Proceso</th><th style="${ST.th}">Empleado</th><th style="${ST.thR}">Tiempo registrado</th><th style="${ST.th}">Situación</th></tr></thead><tbody>
        ${procesos.map((p) => {
            const emps = p.orden_produccion_proceso_empleados || [];
            if (!emps.length) return `<tr><td style="${ST.td}"><b>${escD(p.proceso_nombre)}</b></td><td style="${ST.td}" colspan="3">Sin equipo asignado</td></tr>`;
            return emps.map((e, idx) => {
                const k = `${p.id}|${e.empleado_id}`;
                const seg = segPor.get(k) || 0;
                const sit = e.finalizado_at ? `Terminó ${fechaHora(e.finalizado_at)}` : (activos.has(k) ? 'Trabajando ahora' : (seg > 0 ? 'En pausa' : 'Sin iniciar'));
                return `<tr><td style="${ST.td}">${idx === 0 ? `<b>${escD(p.proceso_nombre)}</b>` : ''}</td><td style="${ST.td}">${escD(e.empleados?.nombre || 'Empleado')}</td>
                    <td style="${ST.tdR}">${seg > 0 ? duracion(seg) : '—'}</td><td style="${ST.td}">${sit}</td></tr>`;
            }).join('');
        }).join('')}</tbody></table>` : `<p style="${ST.nota}">Sin procesos capturados.</p>`;

    // ---- Requisiciones ligadas
    const reqsHtml = reqs === null
        ? `<p style="${ST.nota}">Falta correr sql/2026-09-22_requisicion_orden_produccion.sql para ligar requisiciones a la orden.</p>`
        : (reqs.length ? `<table style="${ST.tabla}"><thead><tr><th style="${ST.th}">Folio</th><th style="${ST.th}">Fecha</th><th style="${ST.th}">Estado</th><th style="${ST.th}">Partidas</th></tr></thead><tbody>
            ${reqs.map((r) => `<tr><td style="${ST.td}">${escD(r.folio)}</td><td style="${ST.td}">${escD(r.fecha || '')}</td><td style="${ST.td}">${escD(r.estadoTexto)}</td>
                <td style="${ST.td}">${escD(r.detalle.map((d) => `${d.nombre}: ${formatoCantidad(d.cantidad)}${d.unidad ? ' ' + d.unidad : ''}`).join(', '))}</td></tr>`).join('')}
            </tbody></table>` : `<p style="${ST.nota}">No hay requisiciones de compra ligadas a esta orden.</p>`);

    // ---- Costos (solo cerrada)
    const costosHtml = !cerrada ? '' : `
        <div class="campo-costo"><p style="${ST.h}">Costos</p>
        <table style="${ST.tabla}">
            <tr><td style="${ST.td}">Materiales</td><td style="${ST.tdR}">${money(o.costo_total_materiales)}</td></tr>
            <tr><td style="${ST.td}">Mano de obra</td><td style="${ST.tdR}">${money(o.costo_total_mano_obra)}</td></tr>
            <tr><td style="${ST.td}"><b>Costo unitario final</b></td><td style="${ST.tdR}"><b>${money(o.costo_unitario_final)}</b> / ${escD(unidadProd)}</td></tr>
        </table></div>`;

    const firma = (t) => `<td style="width:33%;padding:28px 10px 0;text-align:center;"><div style="border-top:1px solid #333;padding-top:4px;font-size:11px;">${t}</div></td>`;

    return {
        folio,
        cuerpo: `<div style="${ST.hoja}">
            ${encabezado}
            <p style="${ST.h}">Insumos${cerrada ? ' (receta de la orden)' : ' — existencias de hoy'}</p>
            ${insumos}
            ${lotesHtml}
            <p style="${ST.h}">Procesos y equipo</p>
            ${procesosHtml}
            <p style="${ST.h}">Requisiciones de compra ligadas</p>
            ${reqsHtml}
            ${costosHtml}
            <table style="width:100%;margin-top:18px;"><tr>${firma('Elaboró')}${firma('Revisó')}${firma('Autorizó')}</tr></table>
        </div>`,
    };
}
