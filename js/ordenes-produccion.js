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
import { calcularRequerimientosProduccion, formatoCantidad, fmtFaltante } from './produccion.js';

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

async function continuarOrdenPendiente(ordenId, btn) {
    const orden = ordenesCache.find((o) => o.id === ordenId);
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
        alert(`⛔ Todavía faltan insumos para "${orden.productos?.nombre || 'este producto'}":\n${faltan.map(fmtFaltante).join('\n')}`);
        await cargarOrdenes();
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
    await cargarOrdenes();
}

async function cancelarOrdenPendiente(ordenId) {
    const orden = ordenesCache.find((o) => o.id === ordenId);
    if (!orden) return;
    if (!confirm(`¿Cancelar la orden pendiente ${orden.folio || '#' + orden.id}? No se podrá reabrir.`)) return;
    const { error } = await supabaseClient.from('ordenes_produccion').update({ estado: 'cancelada' }).eq('id', ordenId);
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await cargarOrdenes();
}

function abrirDetalle(ordenId) {
    const orden = ordenesCache.find((o) => o.id === ordenId);
    const host = document.getElementById('opModalDetalle');
    if (!orden || !host) return;

    const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
    const procesosHtml = (orden.orden_produccion_procesos || []).map((p) => {
        const equipo = (p.orden_produccion_proceso_empleados || []).map((e) => esc(e.empleados?.nombre || 'Empleado')).join(', ');
        return `<li class="text-slate-200"><b>${esc(p.proceso_nombre)}</b> — <span class="text-slate-400">${equipo || 'sin equipo asignado'}</span></li>`;
    }).join('') || '<li class="text-slate-500 italic">Sin procesos capturados.</li>';

    const faltantesHtml = (orden.faltantes_insumos || []).length
        ? `<div class="bg-rose-950/20 border border-rose-900/40 rounded-lg p-3 mt-3">
               <p class="text-xs font-semibold text-rose-300 mb-1.5">⛔ Faltaba (última revisión)</p>
               <ul class="text-xs space-y-0.5">${orden.faltantes_insumos.map((f) => `<li class="text-rose-200/90">${esc(f.nombre)}: requerido ${formatoCantidad(f.requerido)}${f.unidad ? ' ' + esc(f.unidad) : ''}, disponible ${formatoCantidad(f.disponible)}${f.unidad ? ' ' + esc(f.unidad) : ''}</li>`).join('')}</ul>
           </div>`
        : '';

    host.innerHTML = `
        <div id="opModalOverlay" class="fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/80 backdrop-blur-sm p-4">
            <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-lg max-h-[85vh] overflow-y-auto p-5 text-sm text-slate-300 space-y-3">
                <div class="flex justify-between items-start gap-3">
                    <div>
                        <p class="font-mono font-bold text-amber-400">${esc(orden.folio || ('#' + orden.id))}</p>
                        <p class="text-xs text-slate-300">${esc(orden.productos?.nombre || 'Producto')} · ${formatoCantidad(orden.cantidad_producida)} u · Lote ${esc(orden.numero_lote || 'S/L')}</p>
                    </div>
                    <button type="button" id="opModalCerrar" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer">&times;</button>
                </div>
                <div>${badgeEstado(orden.estado)}</div>
                <div>
                    <p class="text-xs font-semibold text-slate-400 mb-1">PROCESOS Y EQUIPO</p>
                    <ul class="text-xs space-y-1">${procesosHtml}</ul>
                </div>
                ${faltantesHtml}
            </div>
        </div>`;

    const overlay = host.querySelector('#opModalOverlay');
    const cerrar = () => { host.innerHTML = ''; };
    overlay.addEventListener('click', (e) => { if (e.target === overlay) cerrar(); });
    host.querySelector('#opModalCerrar').addEventListener('click', cerrar);
}
