// =====================================================================
//  Filtro por columna (menú ▼ en el encabezado) + orden ⇅, reutilizable.
//  Mismo patrón visual de Requisición de Compra / Cuentas por pagar: el valor
//  elegido se ve en letra chica junto al título, el menú se abre con posición
//  fija (no lo recorta el contenedor con scroll) y se cierra al tocar fuera o con Esc.
//
//  Uso:
//    thColumna({ orden: estadoOrden, campo: 'unidad', titulo: 'Unidad', clase: 'text-right',
//                filtro: { id: 'unidad', valor: 'Litros', opciones: [{ v: '', t: 'Todas' }, { v: 'Litros', t: 'Litros', n: 12 }] } })
//    wireFiltrosColumna(contenedor, (id, valor) => { ...guardar y repintar... });
//  El orden usa la misma clase `th-orden` que orden-tabla.js (wireOrdenTabla lo conecta).
// =====================================================================
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

export function thColumna({ orden, campo, titulo, clase = '', filtro = null, pad = 'p-3' }) {
    const activo = orden && orden.campo === campo;
    const flecha = activo
        ? `<span class="text-sm text-sky-300">${orden.dir === 'asc' ? '▲' : '▼'}</span>`
        : '<span class="text-sm text-slate-500">⇅</span>';
    const sel = filtro ? filtro.opciones.find((o) => String(o.v) === String(filtro.valor ?? '')) : null;
    const filtrado = filtro && String(filtro.valor ?? '') !== '';
    // Sin leyenda bajo el título (descuadraba los encabezados): el filtro activo se ve en el color del ▼ y en su tooltip.
    const menu = filtro ? `
        <div data-fc-menu="${filtro.id}" class="hidden z-40 bg-slate-800 border border-slate-600 rounded-lg p-1.5 shadow-2xl normal-case font-normal text-left min-w-[11rem] max-h-72 overflow-y-auto">
          ${filtro.opciones.map((o) => `
            <button type="button" data-fc-opt="${filtro.id}" data-v="${esc(o.v)}" class="flex w-full items-center justify-between gap-3 text-xs px-2 py-1.5 rounded text-left ${String(o.v) === String(filtro.valor ?? '') ? 'text-sky-400 font-semibold' : 'text-slate-200 hover:bg-slate-700'}">
              <span class="truncate">${esc(o.t)}</span>${o.n != null ? `<span class="text-[10px] text-slate-500 font-mono">${o.n}</span>` : ''}
            </button>`).join('')}
        </div>` : '';
    return `<th class="${pad} ${clase} align-top">
        <div class="inline-flex items-center gap-1.5 ${clase.includes('text-right') ? 'justify-end' : clase.includes('text-center') ? 'justify-center' : ''}">
          <button type="button" class="th-orden inline-flex items-center gap-1.5 hover:text-sky-300 cursor-pointer" data-campo-orden="${campo}"><span>${esc(titulo)}</span>${flecha}</button>
          ${filtro ? `<button type="button" data-fc-btn="${filtro.id}" title="Filtrar ${esc(titulo)}${filtrado && sel ? ': ' + esc(sel.t) : ''}" class="text-base leading-none ${filtrado ? 'text-amber-300' : 'text-sky-500'} hover:text-sky-300 cursor-pointer">▼</button>` : ''}
        </div>
        ${menu}
      </th>`;
}

function cerrarMenus() {
    document.querySelectorAll('[data-fc-menu]').forEach((m) => m.classList.add('hidden'));
}
if (typeof document !== 'undefined' && !window.__fcListener) {
    window.__fcListener = true;
    document.addEventListener('click', (e) => { if (!e.target.closest('[data-fc-menu], [data-fc-btn]')) cerrarMenus(); });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') cerrarMenus(); });
    window.addEventListener('scroll', (e) => { if (!(e.target.closest && e.target.closest('[data-fc-menu]'))) cerrarMenus(); }, true);
}

export function wireFiltrosColumna(contenedor, onSeleccion) {
    contenedor.querySelectorAll('[data-fc-btn]').forEach((btn) => {
        btn.onclick = (e) => {
            e.stopPropagation();
            const menu = contenedor.querySelector(`[data-fc-menu="${btn.dataset.fcBtn}"]`);
            if (!menu) return;
            const abrir = menu.classList.contains('hidden');
            cerrarMenus();
            if (!abrir) return;
            menu.classList.remove('hidden');
            // body tiene `zoom` (Configuración → Tamaño del texto): las coordenadas de pantalla se dividen entre el zoom para que
            // el menú quede pegado a su botón (sin esto aparecía desplazado a la derecha/abajo con texto "Grande" o "Muy grande").
            const z = Number(getComputedStyle(document.body).zoom) || 1;
            const r = btn.getBoundingClientRect();
            menu.style.position = 'fixed';
            // `position:fixed` se mide contra el ancestro con `transform` (la animación de entrada de .vista-seccion deja uno): se mide
            // dónde cae el origen (0,0) y se resta, para que el menú quede pegado a su botón con o sin ese ancestro.
            menu.style.top = '0px'; menu.style.left = '0px';
            const o = menu.getBoundingClientRect();
            const ancho = o.width || 200;
            menu.style.top = ((r.bottom + 4 - o.top) / z) + 'px';
            menu.style.left = ((Math.max(8, Math.min(r.left, window.innerWidth - ancho - 8)) - o.left) / z) + 'px';
        };
    });
    contenedor.querySelectorAll('[data-fc-opt]').forEach((op) => {
        op.onclick = () => { cerrarMenus(); onSeleccion(op.dataset.fcOpt, op.dataset.v); };
    });
}
