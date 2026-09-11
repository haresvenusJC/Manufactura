// =====================================================================
// Ordenamiento en vivo (client-side) para tablas de listado en toda la
// app: encabezados clicleables con flecha — ▲/▼ en la columna activa,
// ⇅ tenue (siempre visible) en las demás — que alternan asc/desc al
// hacer clic. Un solo lugar para no repetir este patrón en cada módulo
// (ver js/catalogo.js, primer lugar donde se usó).
// =====================================================================

// Crea el estado de ordenamiento de una tabla. Guardar en una variable
// de módulo (fuera de la función de render) para que persista entre
// repintados.
export function crearOrdenTabla(campoInicial = null, dirInicial = 'asc') {
    return { campo: campoInicial, dir: dirInicial };
}

function flechaOrden(estado, campo) {
    if (estado.campo === campo) {
        return `<span class="text-sm text-sky-300">${estado.dir === 'asc' ? '▲' : '▼'}</span>`;
    }
    return `<span class="text-sm text-slate-500">⇅</span>`;
}

// HTML de un <th> ordenable. `clase` son clases extra de alineación
// (ej. "text-right justify-end" para columnas numéricas).
export function thOrden(estado, campo, label, clase = '') {
    return `<th class="p-3 ${clase}">
        <button type="button" class="th-orden inline-flex items-center gap-2 ${clase} hover:text-sky-300 cursor-pointer" data-campo-orden="${campo}">${label}${flechaOrden(estado, campo)}</button>
    </th>`;
}

// Conecta los botones ya pintados dentro de `contenedor`. onCambio() se
// llama después de alternar asc/desc o cambiar de columna — normalmente
// vuelve a pintar la tabla (que a su vez debe llamar aplicarOrden antes
// de generar las filas).
export function wireOrdenTabla(contenedor, estado, onCambio) {
    contenedor.querySelectorAll('.th-orden').forEach((btn) => {
        btn.addEventListener('click', () => {
            const campo = btn.dataset.campoOrden;
            estado.dir = (estado.campo === campo && estado.dir === 'asc') ? 'desc' : 'asc';
            estado.campo = campo;
            onCambio();
        });
    });
}

// Ordena `arr` in-place según estado.campo/estado.dir. `valores(item, campo)`
// debe regresar el valor comparable (string, number, boolean-as-0/1, etc.)
// para ese campo. Si no hay columna activa, no hace nada.
export function aplicarOrden(estado, arr, valores) {
    if (!estado.campo || !Array.isArray(arr)) return arr;
    const dir = estado.dir === 'desc' ? -1 : 1;
    arr.sort((a, b) => {
        const va = valores(a, estado.campo);
        const vb = valores(b, estado.campo);
        if (va < vb) return -1 * dir;
        if (va > vb) return 1 * dir;
        return 0;
    });
    return arr;
}
