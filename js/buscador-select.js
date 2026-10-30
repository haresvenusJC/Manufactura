// =====================================================================
//  Buscador para un <select> con muchas opciones.
//  Escribes parte del nombre o del SKU, la lista se filtra (sin importar
//  mayúsculas ni acentos, y con varias palabras en cualquier orden) y eliges
//  con clic o con ↑ ↓ Enter. El <select> original sigue ahí (oculto) como
//  fuente de verdad: su valor, su evento "change", su validación `required`
//  y `form.reset()` funcionan igual que antes, así que el código que ya lo
//  usa no cambia.
//
//    import { convertirEnBuscador } from './buscador-select.js';
//    convertirEnBuscador(document.getElementById('miSelect'), { placeholder: '...' });
//
//  Si las opciones del select cambian después, llama select.buscadorRefrescar().
// =====================================================================

const normalizar = (s) => String(s ?? '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const MAX_VISIBLES = 80;

export function convertirEnBuscador(select, { placeholder = 'Escribe para buscar…', crear = null, crearVacio = false } = {}) {
    // crearVacio: muestra «Crear y editar…» aunque aún no se haya escrito nada (útil cuando la lista puede estar vacía).
    // crear: (texto, select) => void — si viene, al final de la lista aparece «Crear y editar…» (estilo Odoo).
    if (!select || select.dataset.buscador === '1') return null;
    select.dataset.buscador = '1';

    // Envoltorio: el input y la lista van sobre el select, que queda oculto pero presente.
    const cont = document.createElement('div');
    // El envoltorio pasa a ser el elemento del grid/flex: hereda las clases de diseño del select
    // (col-span, flex-1, basis, order…, con o sin prefijo responsivo) para no romper el renglón.
    const clasesDiseno = [...select.classList].filter((c) => /^(?:[a-z]+:)?(?:col-span|col-start|row-span|flex-1|flex-auto|grow|basis|self|order|justify-self)/.test(c));
    cont.className = ['relative', ...clasesDiseno].join(' ');
    select.parentNode.insertBefore(cont, select);
    cont.appendChild(select);
    Object.assign(select.style, { position: 'absolute', left: '0', bottom: '0', width: '100%', height: '1px', opacity: '0', pointerEvents: 'none' });
    select.tabIndex = -1;

    const input = document.createElement('input');
    input.type = 'text';
    input.autocomplete = 'off';
    input.placeholder = placeholder;
    input.className = `${select.className} pr-8`;
    input.setAttribute('role', 'combobox');
    input.setAttribute('aria-expanded', 'false');
    cont.insertBefore(input, select);

    const limpiar = document.createElement('button');
    limpiar.type = 'button';
    limpiar.textContent = '✕';
    limpiar.title = 'Quitar la selección';
    limpiar.className = 'hidden absolute right-2 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-200 text-xs cursor-pointer';
    cont.appendChild(limpiar);

    const lista = document.createElement('div');
    lista.className = 'hidden absolute z-40 left-0 right-0 mt-1 max-h-64 overflow-y-auto bg-slate-900 border border-slate-700 rounded-lg shadow-2xl text-sm';
    lista.style.top = '100%';
    cont.appendChild(lista);

    let activo = -1;           // renglón resaltado con el teclado
    let visibles = [];         // opciones que se muestran ahora

    const opciones = () => [...select.options]
        .filter((o) => o.value !== '')
        .map((o) => ({ value: o.value, texto: o.textContent.trim(), norm: normalizar(o.textContent) }));

    const etiquetaElegida = () => {
        const o = select.options[select.selectedIndex];
        return o && o.value !== '' ? o.textContent.trim() : '';
    };

    const sincronizar = () => {
        input.value = etiquetaElegida();
        limpiar.classList.toggle('hidden', !select.value);
    };

    const abrir = () => { lista.classList.remove('hidden'); input.setAttribute('aria-expanded', 'true'); };
    const cerrar = () => { lista.classList.add('hidden'); input.setAttribute('aria-expanded', 'false'); activo = -1; };

    const pintar = (texto) => {
        const palabras = normalizar(texto).split(/\s+/).filter(Boolean);
        const todas = opciones().filter((o) => palabras.every((p) => o.norm.includes(p)));
        visibles = todas.slice(0, MAX_VISIBLES);
        const textoCrear = String(texto ?? '').trim();
        if (crear && (textoCrear.length >= 2 || (crearVacio && !textoCrear))) visibles.push({ crear: true, texto: textoCrear });
        activo = visibles.length ? 0 : -1;
        if (!visibles.length) {
            lista.innerHTML = '<div class="px-3 py-2 text-slate-500 text-xs italic">Sin resultados.</div>';
            return;
        }
        lista.innerHTML = visibles.map((o, i) => o.crear
            ? `<div role="option" data-i="${i}" class="bs-op px-3 py-2 cursor-pointer text-sky-300 border-t border-slate-700 ${i === activo ? 'bg-slate-800' : ''}">➕ Crear y editar${o.texto ? ` «${esc(o.texto)}»` : ''}…</div>`
            : `<div role="option" data-i="${i}" class="bs-op px-3 py-2 cursor-pointer text-slate-100 ${i === activo ? 'bg-slate-800' : ''}">${esc(o.texto)}</div>`).join('')
            + (todas.length > MAX_VISIBLES ? `<div class="px-3 py-1.5 text-[11px] text-slate-500 border-t border-slate-800">Mostrando ${MAX_VISIBLES} de ${todas.length}: sigue escribiendo para acotar.</div>` : '');
    };

    const resaltar = () => {
        lista.querySelectorAll('.bs-op').forEach((el, i) => {
            el.classList.toggle('bg-slate-800', i === activo);
            if (i === activo) el.scrollIntoView({ block: 'nearest' });
        });
    };

    const elegir = (opcion) => {
        if (opcion && opcion.crear) { cerrar(); sincronizar(); crear(opcion.texto, select); return; }
        select.value = opcion ? opcion.value : '';
        select.dispatchEvent(new Event('change', { bubbles: true }));
        sincronizar();
        cerrar();
    };

    input.addEventListener('focus', () => { input.select(); pintar(''); abrir(); });
    input.addEventListener('input', () => { pintar(input.value); abrir(); });
    input.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
            e.preventDefault();
            if (lista.classList.contains('hidden')) { pintar(input.value); abrir(); return; }
            if (!visibles.length) return;
            activo = (activo + (e.key === 'ArrowDown' ? 1 : -1) + visibles.length) % visibles.length;
            resaltar();
        } else if (e.key === 'Enter') {
            if (!lista.classList.contains('hidden')) {
                e.preventDefault();                     // no enviar el formulario al elegir
                if (activo >= 0 && visibles[activo]) elegir(visibles[activo]);
            }
        } else if (e.key === 'Escape') {
            sincronizar();
            cerrar();
        }
    });

    // mousedown (no click): se elige antes de que el input pierda el foco
    lista.addEventListener('mousedown', (e) => {
        const el = e.target.closest('.bs-op');
        if (!el) return;
        e.preventDefault();
        elegir(visibles[Number(el.dataset.i)]);
    });
    limpiar.addEventListener('click', () => { elegir(null); input.focus(); });

    // Al salir sin elegir, el texto vuelve a lo que estaba seleccionado.
    input.addEventListener('blur', () => setTimeout(() => { sincronizar(); cerrar(); }, 120));
    if (select.form) select.form.addEventListener('reset', () => setTimeout(sincronizar, 0));
    select.addEventListener('change', sincronizar);

    select.buscadorRefrescar = sincronizar;

    // El código de cada pantalla llena el select o le asigna .value "por detrás" (sin evento
    // change): se refresca solo, así no hay que llamar a buscadorRefrescar() en cada módulo.
    const proto = Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value');
    if (proto && proto.get && proto.set) {
        Object.defineProperty(select, 'value', {
            configurable: true,
            get() { return proto.get.call(select); },
            set(v) { proto.set.call(select, v); sincronizar(); },
        });
    }
    new MutationObserver(sincronizar).observe(select, { childList: true, subtree: true });
    const sincronizarDeshabilitado = () => { input.disabled = select.disabled; limpiar.classList.toggle('hidden', select.disabled || !select.value); };
    new MutationObserver(sincronizarDeshabilitado).observe(select, { attributes: true, attributeFilter: ['disabled'] });
    sincronizar();
    sincronizarDeshabilitado();
    return { refrescar: sincronizar };
}
