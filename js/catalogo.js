import { supabaseClient } from './supabase.js';

export async function verificarConexionReal() {
    const statusEl = document.getElementById('statusConexion');
    try {
        if (!supabaseClient) throw new Error("Cliente Supabase no inicializado");
        
        const { error } = await supabaseClient.from('productos').select('id', { count: 'exact', head: true });
        if (error) throw error;

        if (statusEl) {
            statusEl.textContent = "Estado: Conectado";
            statusEl.className = "text-xs bg-emerald-950 px-3 py-1.5 rounded-lg text-emerald-400 border border-emerald-800 text-center font-mono";
        }
    } catch (error) {
        console.error("Error de conexión:", error);
        if (statusEl) {
            statusEl.textContent = "Estado: Error de Conexión";
            statusEl.className = "text-xs bg-red-950 px-3 py-1.5 rounded-lg text-red-400 border border-red-800 text-center font-mono";
        }
    }
}

export async function cargarCatalogoInicial() {
    const contenedor = document.getElementById('contenedorCatalogo');
    try {
        if (!supabaseClient || !contenedor) return;
        
        const { data, error } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku, descripcion');
        
        if (error) throw error;

        if (!data || data.length === 0) {
            contenedor.innerHTML = `<p class="text-slate-400 text-sm">No hay productos registrados en el catálogo.</p>`;
            return;
        }
        
        let html = `
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead>
                        <tr class="border-b border-slate-800 text-sky-400">
                            <th class="p-3">SKU</th>
                            <th class="p-3">Nombre del Producto</th>
                            <th class="p-3">Descripción</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        data.forEach(item => {
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-800/50 transition">
                    <td class="p-3 font-mono text-xs text-sky-300">${item.sku || 'N/D'}</td>
                    <td class="p-3 font-medium text-slate-100">${item.nombre || 'Sin nombre'}</td>
                    <td class="p-3 text-slate-400">${item.descripcion || 'Sin descripción'}</td>
                </tr>
            `;
        });
        
        html += `</tbody></table></div>`;
        contenedor.innerHTML = html;
    } catch (err) {
        console.error("Error al cargar catálogo:", err);
        if (contenedor) contenedor.innerHTML = `<p class="text-red-400 text-sm">Error al cargar la tabla 'productos'.</p>`;
    }
}