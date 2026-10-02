import { supabaseClient } from './supabase.js';
import { linkPoliza } from './enlaces-reporte.js';

// =====================================================================
//  Antecedentes de proceso: Requisición → Orden de compra → Documento(s)
//  de recepción. Ancla siempre en el id de la Orden de compra, porque es
//  el único punto de la cadena que se puede resolver hacia los dos lados
//  con una sola columna (requisiciones_compra.orden_compra_id hacia
//  arriba, documentos.orden_compra_id hacia abajo). Se llama desde
//  Requisiciones, Órdenes de compra y Documentos por igual.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const REQ_ESTATUS = {
    pendiente: 'text-amber-300 bg-amber-950/40',
    autorizada: 'text-emerald-300 bg-emerald-950/40',
    rechazada: 'text-rose-300 bg-rose-950/40',
    cancelada: 'text-slate-400 bg-slate-800',
};
const DOC_ESTATUS = {
    completado: 'text-emerald-400 bg-emerald-950/40 border-emerald-900/50',
    cancelado: 'text-rose-400 bg-rose-950/40 border-rose-900/50',
};

export async function abrirAntecedentes(ordenCompraId) {
    const idModal = window.idSubventana('modalAntecedentes');
    if (idModal === 'modalAntecedentes') document.getElementById('modalAntecedentes')?.remove();
    if (!ordenCompraId) { alert('Esta orden de compra no tiene antecedentes que mostrar.'); return; }

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-50 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '38rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">🔗 Antecedentes de proceso</h3>
            <button id="cerrarAntecedentes" class="text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div id="cuerpoAntecedentes" class="p-4 overflow-y-auto flex-1 space-y-4">
            <p class="text-slate-500 text-sm text-center">Consultando...</p>
        </div>`;
    document.body.appendChild(modal);

    // e.target.isConnected: un botón que se re-dibujó al hacer clic ya no está en la página y NO es "clic fuera".
    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('#cerrarAntecedentes').onclick = cerrar;
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    const cuerpo = modal.querySelector('#cuerpoAntecedentes');
    try {
        const [oc, req, docs, anticipos] = await Promise.all([
            supabaseClient.from('ordenes_compra')
                .select('id, folio, fecha, estatus, proveedores ( nombre )')
                .eq('id', ordenCompraId).single(),
            supabaseClient.from('requisiciones_compra')
                .select('id, folio, fecha, estatus, origen, notas')
                .eq('orden_compra_id', ordenCompraId).maybeSingle(),
            supabaseClient.from('documentos')
                .select('id, folio, fecha_emision, estado, poliza_id, tipo_movimiento')
                .eq('orden_compra_id', ordenCompraId)
                .order('id', { ascending: true }),
            // Anticipo(s) pagados a esta OC antes de recibir (2026-09-25) —
            // si la migración no ha corrido, la tabla igual existe (es de
            // pagos_proveedor_aplicaciones, 2026-09-02) solo faltan las
            // columnas nuevas; se degrada solo con el catch de abajo.
            supabaseClient.from('pagos_proveedor_aplicaciones')
                .select('id, monto, pago_id, pagos_proveedor ( id, fecha, poliza_id, estatus, referencia )')
                .eq('tipo', 'anticipo_oc').eq('orden_compra_id', ordenCompraId)
                .then((r) => r).catch(() => ({ data: [], error: null })),
        ]);
        if (oc.error) throw oc.error;

        // Cuánto de cada anticipo ya se aplicó (a esta u otra recepción de
        // la misma OC, si se recibió en partes).
        let aplicadoPorAnticipo = new Map();
        const idsAnticipos = (anticipos?.data || []).map((a) => a.id);
        if (idsAnticipos.length) {
            const { data: apls } = await supabaseClient.from('pagos_proveedor_aplicaciones')
                .select('aplicacion_origen_id, monto').eq('tipo', 'anticipo_aplicado').in('aplicacion_origen_id', idsAnticipos);
            (apls || []).forEach((a) => aplicadoPorAnticipo.set(a.aplicacion_origen_id, (aplicadoPorAnticipo.get(a.aplicacion_origen_id) || 0) + Number(a.monto || 0)));
        }

        const paso = (titulo, contenidoHtml) => `
            <div class="border border-slate-800 rounded-lg p-3">
                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1.5">${titulo}</p>
                ${contenidoHtml}
            </div>`;

        const htmlReq = req.data
            ? `<div class="flex items-center justify-between gap-2 flex-wrap">
                 <button type="button" onclick="window.abrirDetalleReq && window.abrirDetalleReq(${req.data.id})" class="font-mono text-sky-300 text-sm hover:underline" title="Abrir la requisición">${esc(req.data.folio || '#' + req.data.id)}</button>
                 <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${REQ_ESTATUS[req.data.estatus] || 'text-slate-400 bg-slate-800'}">${esc(req.data.estatus)}</span>
               </div>
               <p class="text-[11px] text-slate-500 mt-1">${req.data.fecha || ''} · ${req.data.origen === 'stock_bajo_minimo' ? 'Generada por stock bajo mínimo' : 'Capturada a mano'}</p>
               ${req.data.notas ? `<p class="text-[11px] text-slate-400 mt-1">${esc(req.data.notas)}</p>` : ''}`
            : `<p class="text-xs text-slate-500 italic">Esta orden de compra se creó directamente, sin pasar por una requisición.</p>`;

        const o = oc.data;
        const htmlOc = `<div class="flex items-center justify-between gap-2 flex-wrap">
                 <button type="button" onclick="window.verDetalleOC && window.verDetalleOC(${o.id})" class="font-mono text-emerald-300 text-sm hover:underline" title="Abrir la orden de compra">${esc(o.folio || '#' + o.id)}</button>
                 <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-sky-300 bg-sky-950/50">${esc(o.estatus)}</span>
               </div>
               <p class="text-[11px] text-slate-500 mt-1">${o.fecha || ''} · ${esc(o.proveedores?.nombre || 'sin proveedor')}</p>`;

        const htmlAnticipos = (anticipos?.data || []).map((a) => {
            const p = a.pagos_proveedor;
            const aplicado = aplicadoPorAnticipo.get(a.id) || 0;
            const disponible = Math.round((Number(a.monto || 0) - aplicado) * 100) / 100;
            return `
                <div class="flex items-center justify-between gap-2 flex-wrap py-1.5 border-b border-slate-800 last:border-0">
                    <div>
                        <span class="text-sm text-slate-200">${money(a.monto)}</span>
                        <span class="text-[11px] text-slate-500 ml-1">${p?.fecha || ''}${p?.referencia ? ' · ' + esc(p.referencia) : ''}</span>
                        ${p?.estatus === 'cancelado' ? '<span class="text-[10px] text-rose-400 font-semibold ml-1">CANCELADO</span>' : ''}
                    </div>
                    <div class="flex items-center gap-2">
                        ${disponible > 0 ? `<span class="text-[10px] text-amber-300">Disponible ${money(disponible)}</span>` : (p?.estatus !== 'cancelado' ? '<span class="text-[10px] text-emerald-400">Aplicado</span>' : '')}
                        ${p?.poliza_id ? linkPoliza(p.poliza_id, 'font-mono text-sky-300 text-[10px]') : ''}
                    </div>
                </div>`;
        }).join('');

        const htmlDocs = (docs.data && docs.data.length)
            ? docs.data.map(d => `
                <div class="flex items-center justify-between gap-2 flex-wrap py-1.5 border-b border-slate-800 last:border-0">
                    <div>
                        <button type="button" onclick="window.abrirDetalleDocumentoGlobal(${d.id})" class="font-mono text-indigo-300 hover:underline text-sm">${esc(d.folio || '#' + d.id)}</button>
                        <span class="text-[11px] text-slate-500 ml-1">${d.fecha_emision ? new Date(d.fecha_emision).toLocaleDateString('es-MX') : ''}</span>
                    </div>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold border ${DOC_ESTATUS[d.estado] || 'text-slate-400 bg-slate-800 border-slate-700'}">${esc(d.estado || 'N/D')}</span>
                </div>`).join('')
            : `<p class="text-xs text-slate-500 italic">Todavía no se ha recibido nada contra esta orden.</p>`;

        const flecha = '<div class="text-center text-slate-600 text-lg leading-none">↓</div>';
        cuerpo.innerHTML = `
            ${paso('1 · Requisición de compra', htmlReq)}
            ${flecha}
            ${paso('2 · Orden de compra', htmlOc)}
            ${htmlAnticipos ? flecha + paso('3 · Anticipo(s) pagado(s) — antes de recibir', htmlAnticipos) : ''}
            ${flecha}
            ${paso(`${htmlAnticipos ? '4' : '3'} · Recepción / entrada de mercancía`, htmlDocs)}
        `;
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar los antecedentes: ${esc(err.message || err)}</p>`;
    }
}

window.abrirAntecedentesOC = (ordenCompraId) => abrirAntecedentes(Number(ordenCompraId));

// =====================================================================
//  Seguimiento de un pedido de venta (reservas, entrega 4):
//  Pedido → Producción / Requisición → Orden de compra → Recepción → Surtido.
//  Ancla en pedidos_venta.id; las ligas salen de ordenes_produccion.pedido_venta_id,
//  requisiciones_compra.pedido_venta_id (sql/2026-11-04) y documentos.pedido_venta_id
//  (surtidos). Sin la migración 2026-11-04 muestra solo el pedido y sus surtidos.
// =====================================================================
const PV_ESTATUS_SEG = {
    pendiente: 'text-amber-300 bg-amber-950/40', parcial: 'text-sky-300 bg-sky-950/40',
    surtido: 'text-emerald-300 bg-emerald-950/40', cancelado: 'text-slate-400 bg-slate-800',
};
const OP_ESTADO_SEG = { borrador: 'pendiente por insumos', en_proceso: 'en proceso', cerrada: 'cerrada', cancelada: 'cancelada' };
const OC_ESTATUS_SEG = { borrador: 'en borrador', abierta: 'abierta, sin recibir', recibida_parcial: 'recibida parcial', recibida: 'recibida', cancelada: 'cancelada' };

export async function abrirSeguimientoPedido(pedidoId) {
    const idModal = window.idSubventana('modalSeguimientoPedido');
    if (idModal === 'modalSeguimientoPedido') document.getElementById('modalSeguimientoPedido')?.remove();
    if (!pedidoId) return;

    const modal = document.createElement('div');
    modal.id = idModal;
    modal.className = 'fixed z-[70] bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl flex flex-col max-h-[85vh]';
    modal.style.top = '6vh';
    modal.style.left = '50%';
    modal.style.transform = 'translateX(-50%)';
    modal.style.width = 'calc(100% - 2rem)';
    modal.style.maxWidth = '40rem';
    modal.innerHTML = `
        <div class="flex justify-between items-center p-4 border-b border-slate-800">
            <h3 class="text-base font-semibold text-slate-100">🔗 Seguimiento del pedido</h3>
            <button type="button" class="seg-cerrar text-slate-400 hover:text-slate-200 text-xl leading-none">&times;</button>
        </div>
        <div class="seg-cuerpo p-4 overflow-y-auto flex-1 space-y-3"><p class="text-slate-500 text-sm text-center">Consultando...</p></div>`;
    document.body.appendChild(modal);

    const cerrarFuera = (e) => { if (e.target.isConnected && !modal.contains(e.target)) cerrar(); };
    const cerrarEsc = (e) => { if (e.key === 'Escape') cerrar(); };
    function cerrar() {
        modal.remove();
        document.removeEventListener('click', cerrarFuera);
        document.removeEventListener('keydown', cerrarEsc);
    }
    modal.querySelector('.seg-cerrar').onclick = cerrar;
    setTimeout(() => { document.addEventListener('click', cerrarFuera); document.addEventListener('keydown', cerrarEsc); }, 0);

    const cuerpo = modal.querySelector('.seg-cuerpo');
    try {
        const consultaPedido = (conReserva) => supabaseClient.from('pedidos_venta')
            .select(`id, folio, fecha, estatus, clientes ( nombre ), pedidos_venta_detalle ( id, cantidad, cantidad_surtida${conReserva ? ', cantidad_reservada' : ''}, descripcion, productos ( nombre ) )`)
            .eq('id', pedidoId).single();
        let { data: ped, error: ePed } = await consultaPedido(true);
        if (ePed && /cantidad_reservada/i.test(ePed.message || '')) ({ data: ped, error: ePed } = await consultaPedido(false));
        if (ePed) throw ePed;

        // Producción y requisiciones ligadas (migración 2026-11-04; si falta, null → se avisa).
        const rOps = await supabaseClient.from('ordenes_produccion')
            .select('id, folio, estado, cantidad_producida, cerrada_at, productos ( nombre, unidades_medida ( nombre ) )')
            .eq('pedido_venta_id', pedidoId).order('id', { ascending: true });
        const rReq = await supabaseClient.from('requisiciones_compra')
            .select('id, folio, fecha, estatus, orden_compra_id, ordenes_compra ( id, folio, estatus, proveedores ( nombre ) ), requisiciones_compra_detalle ( cantidad, productos ( nombre ) )')
            .eq('pedido_venta_id', pedidoId).order('id', { ascending: true });
        const sinMigracion = !!(rOps.error || rReq.error);
        const ops = rOps.error ? [] : (rOps.data || []);
        const reqs = rReq.error ? [] : (rReq.data || []);

        const ocIds = [...new Set(reqs.map((r) => r.orden_compra_id).filter(Boolean))];
        const [rRec, rSur] = await Promise.all([
            ocIds.length
                ? supabaseClient.from('documentos').select('id, folio, fecha_emision, estado, orden_compra_id').in('orden_compra_id', ocIds).order('id', { ascending: true })
                : Promise.resolve({ data: [] }),
            supabaseClient.from('documentos').select('id, folio, fecha_emision, estado').eq('pedido_venta_id', pedidoId).order('id', { ascending: true }),
        ]);
        const recibosPorOc = new Map();
        (rRec.data || []).forEach((d) => { if (!recibosPorOc.has(d.orden_compra_id)) recibosPorOc.set(d.orden_compra_id, []); recibosPorOc.get(d.orden_compra_id).push(d); });
        const surtidos = rSur.error ? [] : (rSur.data || []);

        const fechaTxt = (f) => f ? new Date(f).toLocaleDateString('es-MX') : '';
        const num = (n) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 4 });
        const insignia = (txt, clase) => `<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${clase}">${esc(txt)}</span>`;
        const paso = (titulo, html) => `
            <div class="border border-slate-800 rounded-lg p-3">
                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1.5">${titulo}</p>${html}
            </div>`;
        const flecha = '<div class="text-center text-slate-600 text-lg leading-none">↓</div>';
        const docLinea = (d, etiqueta) => `
            <div class="flex items-center justify-between gap-2 flex-wrap py-1 border-b border-slate-800 last:border-0">
                <div><button type="button" onclick="window.abrirDetalleDocumentoGlobal(${d.id})" class="font-mono text-indigo-300 hover:underline text-sm">${esc(d.folio || '#' + d.id)}</button>
                <span class="text-[11px] text-slate-500 ml-1">${etiqueta}${fechaTxt(d.fecha_emision)}</span></div>
                ${insignia(d.estado || 'N/D', DOC_ESTATUS[d.estado] || 'text-slate-400 bg-slate-800')}
            </div>`;

        const det = ped.pedidos_venta_detalle || [];
        const htmlPedido = `
            <div class="flex items-center justify-between gap-2 flex-wrap">
                <button type="button" onclick="window.pvAbrirDetalle && window.pvAbrirDetalle(${ped.id})" class="font-mono text-emerald-300 text-sm hover:underline" title="Abrir el pedido">${esc(ped.folio || '#' + ped.id)}</button>
                ${insignia(ped.estatus, PV_ESTATUS_SEG[ped.estatus] || 'text-slate-400 bg-slate-800')}
            </div>
            <p class="text-[11px] text-slate-500 mt-1">${esc(ped.fecha || '')} · ${esc(ped.clientes?.nombre || 'sin cliente')}</p>
            <table class="w-full text-[11px] mt-2"><thead class="text-slate-500"><tr><th class="text-left font-normal">Producto</th><th class="text-right font-normal">Pedido</th><th class="text-right font-normal">Surtido</th>${det.some((d) => d.cantidad_reservada !== undefined) ? '<th class="text-right font-normal">Apartado</th>' : ''}</tr></thead><tbody>
            ${det.map((d) => `<tr class="border-t border-slate-800"><td class="py-0.5 text-slate-300">${esc(d.productos?.nombre || d.descripcion || '—')}</td><td class="text-right font-mono">${num(d.cantidad)}</td><td class="text-right font-mono text-slate-400">${num(d.cantidad_surtida)}</td>${d.cantidad_reservada !== undefined ? `<td class="text-right font-mono text-sky-300">${num(d.cantidad_reservada)}</td>` : ''}</tr>`).join('')}
            </tbody></table>`;

        const htmlOps = ops.map((o) => `
            <div class="flex items-center justify-between gap-2 flex-wrap py-1 border-b border-slate-800 last:border-0">
                <div><button type="button" onclick="window.abrirDetalleOrdenProduccion && window.abrirDetalleOrdenProduccion(${o.id})" class="font-mono text-amber-300 hover:underline text-sm">${esc(o.folio || 'OP-' + String(o.id).padStart(6, '0'))}</button>
                <span class="text-[11px] text-slate-500 ml-1">${esc(o.productos?.nombre || '')}: ${num(o.cantidad_producida)} ${esc(o.productos?.unidades_medida?.nombre || '')}${o.cerrada_at ? ' · cerrada ' + fechaTxt(o.cerrada_at) : ''}</span></div>
                ${insignia(OP_ESTADO_SEG[o.estado] || o.estado, o.estado === 'cerrada' ? 'text-emerald-300 bg-emerald-950/40' : (o.estado === 'cancelada' ? 'text-slate-400 bg-slate-800' : 'text-amber-300 bg-amber-950/40'))}
            </div>
            ${o.estado === 'cerrada' ? '<p class="text-[10px] text-emerald-400 pb-1">✔ Ya hay producto terminado: se aparta solo al pedido más antiguo que lo necesite.</p>' : ''}`).join('');

        const htmlReqs = reqs.map((r) => {
            const oc = r.ordenes_compra;
            const recs = oc ? (recibosPorOc.get(oc.id) || []) : [];
            return `
            <div class="py-1.5 border-b border-slate-800 last:border-0">
                <div class="flex items-center justify-between gap-2 flex-wrap">
                    <div><button type="button" onclick="window.abrirDetalleReq && window.abrirDetalleReq(${r.id})" class="font-mono text-sky-300 hover:underline text-sm">${esc(r.folio || '#' + r.id)}</button>
                    <span class="text-[11px] text-slate-500 ml-1">${esc((r.requisiciones_compra_detalle || []).map((x) => `${x.productos?.nombre || ''}: ${num(x.cantidad)}`).join(', '))}</span></div>
                    ${insignia(r.estatus, REQ_ESTATUS[r.estatus] || 'text-slate-400 bg-slate-800')}
                </div>
                ${oc ? `<div class="ml-4 mt-1 flex items-center justify-between gap-2 flex-wrap">
                    <div>↳ <button type="button" onclick="window.verDetalleOC && window.verDetalleOC(${oc.id})" class="font-mono text-emerald-300 hover:underline text-xs">${esc(oc.folio || '#' + oc.id)}</button>
                    <span class="text-[11px] text-slate-500 ml-1">${esc(oc.proveedores?.nombre || '')}</span></div>
                    ${insignia(OC_ESTATUS_SEG[oc.estatus] || oc.estatus, 'text-sky-300 bg-sky-950/50')}</div>
                  ${recs.length ? `<div class="ml-8 mt-1">${recs.map((d) => docLinea(d, 'recepción · ')).join('')}</div>` : '<p class="ml-8 mt-1 text-[10px] text-slate-500 italic">Aún sin recepción.</p>'}`
                  : `<p class="ml-4 mt-1 text-[10px] text-slate-500 italic">${r.estatus === 'pendiente' ? 'Pendiente de autorizar.' : 'Sin orden de compra todavía.'}</p>`}
            </div>`;
        }).join('');

        const hayCobertura = ops.length || reqs.length;
        cuerpo.innerHTML = `
            ${paso('1 · Pedido de venta', htmlPedido)}
            ${flecha}
            ${paso('2 · Lo que se fabrica (órdenes de producción)', htmlOps || '<p class="text-xs text-slate-500 italic">Ninguna orden de producción ligada.</p>')}
            ${paso('3 · Lo que se compra (requisición → orden de compra → recepción)', htmlReqs || '<p class="text-xs text-slate-500 italic">Ninguna requisición ligada.</p>')}
            ${sinMigracion ? '<p class="text-[11px] text-amber-300">⚠ Falta correr sql/2026-11-04_pedido_venta_cobertura.sql: sin él no hay liga entre el pedido y su producción / compra.</p>' : ''}
            ${!hayCobertura && !sinMigracion ? '<p class="text-[11px] text-slate-500">Este pedido no necesitó producción ni compra (o todavía no se genera).</p>' : ''}
            ${flecha}
            ${paso('4 · Surtidos (salidas contra el pedido)', surtidos.length ? surtidos.map((d) => docLinea(d, '')).join('') : '<p class="text-xs text-slate-500 italic">Todavía no se ha surtido nada.</p>')}`;
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar el seguimiento: ${esc(err.message || err)}</p>`;
    }
}

window.abrirSeguimientoPedido = (pedidoId) => abrirSeguimientoPedido(Number(pedidoId));
