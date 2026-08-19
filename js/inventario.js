import { supabaseClient } from './supabase.js';

export async function cargarInventarioCompleto() {
    const contenedorInv = document.getElementById('contenedorInventario');
    const contenedorLotes = document.getElementById('contenedorExistenciasLote');
    
    try {
        if (!supabaseClient) return;
        
        if (contenedorInv) {
            const { data: materias, error: errMat } = await supabaseClient
                .from('materias_primas')
                .select('nombre, unidad_medida, stock_actual, costo_unitario, proveedor');
            
            if (errMat) throw errMat;

            if (!materias || materias.length === 0) {
                contenedorInv.innerHTML = `<p class="text-slate-400 text-sm">No hay materias primas registradas.</p>`;
            } else {
                let html = `
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm text-slate-300">
                            <thead>
                                <tr class="border-b border-slate-800 text-sky-400">
                                    <th class="p-2">Insumo</th>
                                    <th class="p-2">Stock Actual</th>
                                    <th class="p-2">Unidad</th>
                                    <th class="p-2">Costo Unitario</th>
                                    <th class="p-2">Proveedor</th>
                                </tr>
                            </thead>
                            <tbody>
                `;
                materias.forEach(m => {
                    html += `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 font-medium text-slate-100">${m.nombre}</td>
                            <td class="p-2 font-mono text-sky-300">${m.stock_actual ?? 0}</td>
                            <td class="p-2 text-slate-400">${m.unidad_medida || ''}</td>
                            <td class="p-2 font-mono">$${Number(m.costo_unitario || 0).toFixed(2)}</td>
                            <td class="p-2 text-slate-400">${m.proveedor || 'N/D'}</td>
                        </tr>
                    `;
                });
                html += `</tbody></table></div>`;
                contenedorInv.innerHTML = html;
            }
        }

        if (contenedorLotes) {
            const { data: lotes, error: errLotes } = await supabaseClient
                .from('lotes_materias_primas')
                .select(`
                    id,
                    numero_lote,
                    stock_actual,
                    costo_unitario,
                    moneda,
                    fecha_ingreso,
                    materias_primas ( nombre )
                `);
            
            if (errLotes) throw errLotes;

            if (!lotes || lotes.length === 0) {
                contenedorLotes.innerHTML = `<p class="text-slate-400 text-sm">No hay lotes registrados.</p>`;
            } else {
                let htmlLotes = `
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm text-slate-300">
                            <thead>
                                <tr class="border-b border-slate-800 text-sky-400">
                                    <th class="p-2">Lote / Factura</th>
                                    <th class="p-2">Insumo</th>
                                    <th class="p-2">Stock Lote</th>
                                    <th class="p-2">Costo</th>
                                    <th class="p-2">Moneda</th>
                                    <th class="p-2">Ingreso</th>
                                </tr>
                            </thead>
                            <tbody>
                `;
                lotes.forEach(l => {
                    htmlLotes += `
                        <tr class="border-b border-slate-900">
                            <td class="p-2 font-mono text-xs text-sky-300">${l.numero_lote}</td>
                            <td class="p-2 font-medium">${l.materias_primas?.nombre || 'Desconocido'}</td>
                            <td class="p-2 font-mono">${l.stock_actual}</td>
                            <td class="p-2 font-mono">$${Number(l.costo_unitario || 0).toFixed(2)}</td>
                            <td class="p-2 text-xs">${l.moneda || 'MXN'}</td>
                            <td class="p-2 text-xs text-slate-400">${l.fecha_ingreso ? new Date(l.fecha_ingreso).toLocaleDateString() : 'N/D'}</td>
                        </tr>
                    `;
                });
                htmlLotes += `</tbody></table></div>`;
                contenedorLotes.innerHTML = htmlLotes;
            }
        }
    } catch (err) {
        console.error("Error al cargar inventario o lotes:", err);
    }
}