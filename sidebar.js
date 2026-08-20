export const renderSidebar = () => {
    const tabs = [
        { name: "Dashboard", id: "dashboard" },
        { name: "Catálogo", id: "catalogo" },
        { name: "Inventario", id: "inventario" },
        { name: "Producción", id: "produccion" },
        { name: "Auditoría", id: "auditoria" },
        { name: "Configuración", id: "configuracion" }
    ];

    let html = '<div class="text-lg font-bold text-sky-400 mb-4 px-2">Hares de México</div>';
    html += '<ul class="space-y-1" style="list-style: none; padding: 0;">';
    tabs.forEach(tab => {
        html += `<li>
            <button onclick="window.loadView('${tab.id}')" class="w-full text-left px-3 py-2 rounded-lg hover:bg-slate-800 text-slate-300 transition text-sm font-medium" style="cursor: pointer;">
                ${tab.name}
            </button>
        </li>`;
    });
    html += '</ul>';
    
    return html;
};