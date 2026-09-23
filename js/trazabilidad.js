import { supabaseClient } from './supabase.js';

// =====================================================================
//  Antecedentes de proceso: Requisición → Orden de compra → Documento(s)
//  de recepción. Ancla siempre en el id de la Orden de compra, porque es
//  el único punto de la cadena que se puede resolver hacia los dos lados
//  con una sola columna (requisiciones_compra.orden_compra_id hacia
//  arriba, documentos.orden_compra_id hacia abajo). Se llama desde
//  Requisiciones, Órdenes de compra y Documentos por igual.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

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
    document.getElementById('modalAntecedentes')?.remove();
    if (!ordenCompraId) { alert('Esta orden de compra no tiene antecedentes que mostrar.'); return; }

    const modal = document.createElement('div');
    modal.id = 'modalAntecedentes';
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
    document.getElementById('cerrarAntecedentes').onclick = cerrar;
    setTimeout(() => {
        document.addEventListener('click', cerrarFuera);
        document.addEventListener('keydown', cerrarEsc);
    }, 0);

    const cuerpo = document.getElementById('cuerpoAntecedentes');
    try {
        const [oc, req, docs] = await Promise.all([
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
        ]);
        if (oc.error) throw oc.error;

        const paso = (titulo, contenidoHtml) => `
            <div class="border border-slate-800 rounded-lg p-3">
                <p class="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1.5">${titulo}</p>
                ${contenidoHtml}
            </div>`;

        const htmlReq = req.data
            ? `<div class="flex items-center justify-between gap-2 flex-wrap">
                 <span class="font-mono text-sky-300 text-sm">${esc(req.data.folio || '#' + req.data.id)}</span>
                 <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${REQ_ESTATUS[req.data.estatus] || 'text-slate-400 bg-slate-800'}">${esc(req.data.estatus)}</span>
               </div>
               <p class="text-[11px] text-slate-500 mt-1">${req.data.fecha || ''} · ${req.data.origen === 'stock_bajo_minimo' ? 'Generada por stock bajo mínimo' : 'Capturada a mano'}</p>
               ${req.data.notas ? `<p class="text-[11px] text-slate-400 mt-1">${esc(req.data.notas)}</p>` : ''}`
            : `<p class="text-xs text-slate-500 italic">Esta orden de compra se creó directamente, sin pasar por una requisición.</p>`;

        const o = oc.data;
        const htmlOc = `<div class="flex items-center justify-between gap-2 flex-wrap">
                 <span class="font-mono text-emerald-300 text-sm">${esc(o.folio || '#' + o.id)}</span>
                 <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-sky-300 bg-sky-950/50">${esc(o.estatus)}</span>
               </div>
               <p class="text-[11px] text-slate-500 mt-1">${o.fecha || ''} · ${esc(o.proveedores?.nombre || 'sin proveedor')}</p>`;

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

        cuerpo.innerHTML = `
            ${paso('1 · Requisición de compra', htmlReq)}
            <div class="text-center text-slate-600 text-lg leading-none">↓</div>
            ${paso('2 · Orden de compra', htmlOc)}
            <div class="text-center text-slate-600 text-lg leading-none">↓</div>
            ${paso('3 · Recepción / entrada de mercancía', htmlDocs)}
        `;
    } catch (err) {
        cuerpo.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar los antecedentes: ${esc(err.message || err)}</p>`;
    }
}

window.abrirAntecedentesOC = (ordenCompraId) => abrirAntecedentes(Number(ordenCompraId));
