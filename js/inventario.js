import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { thColumna, wireFiltrosColumna } from './filtro-columna.js';
import { etiquetaPoliza } from './enlaces-reporte.js';
import { fechaLocalTxt } from './fechas.js';

const invResumenOrden = crearOrdenTabla('nombre', 'asc');
const invLotesOrden = crearOrdenTabla();
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/**
 * Función auxiliar centralizada para registrar movimientos de almacén mediante FIFO (RPC de Supabase).
 * Soporta de manera inteligente entradas y salidas (como producción o ventas).
 */
export async function registrarMovimientoAlmacen({ productoId, cantidad, tipoMovimiento, documentoId, costoUnitario, numeroLote }) {
    let rpcNombre = 'registrar_movimiento_inventario_fifo';
    let parametros = {};

    if (Number(cantidad) < 0 || (tipoMovimiento && tipoMovimiento.startsWith('salida'))) {
        rpcNombre = 'registrar_salida_fifo';
        parametros = {
            p_producto_id: Number(productoId),
            p_cantidad_salida: Math.abs(Number(cantidad)),
            p_tipo_movimiento: tipoMovimiento,
            p_documento_id: documentoId ? Number(documentoId) : null,
            p_costo_unitario_fijo: costoUnitario ? Number(costoUnitario) : null
        };
    } else {
        parametros = {
            p_producto_id: Number(productoId),
            p_cantidad: Number(cantidad),
            p_tipo_movimiento: tipoMovimiento,
            p_documento_id: documentoId ? Number(documentoId) : null,
            p_costo_unitario: costoUnitario ? Number(costoUnitario) : null,
            p_numero_lote: numeroLote || null
        };
    }

    const { error } = await supabaseClient.rpc(rpcNombre, parametros);

    if (error) {
        throw new Error(`Error en inventario [${tipoMovimiento}] (RPC: ${rpcNombre}): ` + error.message);
    }
}

// Variables de estado para la paginación y filtros de lotes
let paginaActualLotes = 1;
const porPaginaLotes = 50;
let fechaInicioFiltro = '';
let fechaFinFiltro = '';
let invReservas = {};   // producto_id -> { reservado, disponible } (pedidos de venta pendientes; vista de sql/2026-11-03)
let filtroProductoLotes = '';     // SKU o nombre del producto (texto)
let filtroProductoIdLotes = null;   // si se eligió un producto de las sugerencias: se filtra por ese producto exacto
let filtroNumeroLote = '';         // número de lote (texto)
let filtroSoloConExistencia = false; // oculta lotes agotados (stock 0)
// Texto seguro para meterlo en un filtro de PostgREST (las comas y paréntesis rompen la sintaxis de .or()).
const limpiarFiltroTexto = (t) => String(t || '').replace(/[,()%*\\]/g, ' ').trim();

// Cache del resumen (productos) para poder filtrar/paginar/colapsar en
// cliente sin volver a golpear Supabase en cada tecleo del buscador.
let invProductosCache = [];
let invFiltroTexto = '';

export async function cargarInventarioCompleto() {
    const contenedorInv = document.getElementById('contenedorInventario');
    const contenedorLotes = document.getElementById('contenedorExistenciasLote');

    try {
        if (!supabaseClient) return;

        if (contenedorInv) {
            const colsInv = `
                    id, nombre, sku, tipo, costo_unitario, stock_actual, unidad_medida_id, moneda_id,
                    unidades_medida ( nombre ),
                    monedas ( codigo )
                `;
            const { data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select(colsInv)
                .order('id', { ascending: true });

            if (errProd) throw errProd;

            invProductosCache = (productos || []).filter((p) => p.tipo !== 'activo_fijo');   // un equipo no es existencia

            // Reservado / disponible por producto (sin la migración de reservas queda vacío y no se muestran las columnas).
            invReservas = {};
            try {
                const { data: rsv, error: eRsv } = await supabaseClient.from('v_stock_disponible').select('producto_id, reservado, disponible');
                if (!eRsv && Array.isArray(rsv)) { invReservas = { _ok: true }; rsv.forEach((r) => { invReservas[r.producto_id] = { reservado: Number(r.reservado), disponible: Number(r.disponible) }; }); }
            } catch (_) { /* sin reservas */ }

            const inputBuscar = document.getElementById('invBuscador');
            if (inputBuscar) {
                inputBuscar.value = invFiltroTexto;
                inputBuscar.oninput = () => {
                    invFiltroTexto = inputBuscar.value;
                    renderInventarioResumen();
                };
            }

            renderInventarioResumen();
        }

        if (contenedorLotes) {
            await renderizarTablaLotes(contenedorLotes);
        }

    } catch (err) {
        console.error("Error al cargar inventario o lotes:", err);
    }
}

// Clasificación de cada artículo en el resumen (misma regla de siempre; otros tipos no se listan).
const INV_CLASES = {
    terminados:     { t: 'Productos terminados', ico: '📦', cls: 'text-amber-400' },
    semiterminados: { t: 'Semiterminados (granel)', ico: '🧴', cls: 'text-indigo-400' },
    materias:       { t: 'Materias primas', ico: '🧪', cls: 'text-sky-400' },
    componentes:    { t: 'Componentes y refacciones', ico: '⚙️', cls: 'text-emerald-400' },
};
const invClaseDe = (p) => {
    if (p.tipo === 'producto') return 'terminados';
    if (p.tipo === 'semiterminado') return 'semiterminados';
    if (p.tipo === 'materia_prima' || !p.tipo) return 'materias';
    if (p.tipo === 'componente' || p.tipo === 'refaccion' || p.tipo === 'insumo') return 'componentes';
    return null;
};
// Filtros por columna (menú ▼ en el encabezado). '' = sin filtrar.
const invFiltros = { clase: '', unidad: '', stock: '', reservado: '', libre: '', costo: '' };

function renderInventarioResumen() {
    const contenedorInv = document.getElementById('contenedorInventario');
    if (!contenedorInv) return;

    const conReservas = !!invReservas._ok;
    const texto = invFiltroTexto.trim().toLowerCase();
    const reservadoDe = (p) => Number(invReservas[p.id]?.reservado || 0);
    const libreDe = (p) => (invClaseDe(p) === 'terminados' && invReservas[p.id] ? Number(invReservas[p.id].disponible || 0) : Number(p.stock_actual || 0));
    const base = invProductosCache.filter((p) => invClaseDe(p) && (!texto
        || (p.nombre || '').toLowerCase().includes(texto) || (p.sku || '').toLowerCase().includes(texto)));

    // Cada filtro; `excepto` permite contar las opciones de una columna sin aplicarle su propio filtro.
    const cumple = (p, excepto) => {
        const f = invFiltros;
        if (excepto !== 'clase' && f.clase && invClaseDe(p) !== f.clase) return false;
        if (excepto !== 'unidad' && f.unidad && (p.unidades_medida?.nombre || 'N/D') !== f.unidad) return false;
        if (excepto !== 'stock' && f.stock && (Number(p.stock_actual || 0) > 0) !== (f.stock === 'con')) return false;
        if (conReservas && excepto !== 'reservado' && f.reservado && (reservadoDe(p) > 0) !== (f.reservado === 'con')) return false;
        if (conReservas && excepto !== 'libre' && f.libre && (libreDe(p) > 0) !== (f.libre === 'con')) return false;
        if (excepto !== 'costo' && f.costo && (Number(p.costo_unitario || 0) > 0) !== (f.costo === 'con')) return false;
        return true;
    };
    const lista = base.filter((p) => cumple(p, null));
    const cuenta = (excepto, fn) => base.filter((p) => cumple(p, excepto) && fn(p)).length;

    aplicarOrden(invResumenOrden, lista, (item, campo) => {
        switch (campo) {
            case 'nombre': return (item.nombre || '').toLowerCase();
            case 'clase': return Object.keys(INV_CLASES).indexOf(invClaseDe(item));
            case 'unidad': return (item.unidades_medida?.nombre || '').toLowerCase();
            case 'stock': return Number(item.stock_actual || 0);
            case 'reservado': return reservadoDe(item);
            case 'libre': return libreDe(item);
            case 'costo': return Number(item.costo_unitario || 0);
            default: return item.id;
        }
    });

    const unidades = [...new Set(base.map((p) => p.unidades_medida?.nombre || 'N/D'))].sort((a, b) => a.localeCompare(b, 'es'));
    const opcSiNo = (campo, si, no, fn) => [
        { v: '', t: 'Todos', n: cuenta(campo, () => true) },
        { v: 'con', t: si, n: cuenta(campo, (p) => fn(p) > 0) },
        { v: 'sin', t: no, n: cuenta(campo, (p) => !(fn(p) > 0)) },
    ];
    const th = [
        thColumna({ orden: invResumenOrden, campo: 'nombre', titulo: 'Elemento / SKU' }),
        thColumna({ orden: invResumenOrden, campo: 'clase', titulo: 'Clasificación', filtro: { id: 'clase', valor: invFiltros.clase, opciones: [
            { v: '', t: 'Todas', n: cuenta('clase', () => true) },
            ...Object.entries(INV_CLASES).map(([k, c]) => ({ v: k, t: c.t, n: cuenta('clase', (p) => invClaseDe(p) === k) })),
        ] } }),
        thColumna({ orden: invResumenOrden, campo: 'unidad', titulo: 'Unidad', filtro: { id: 'unidad', valor: invFiltros.unidad, opciones: [
            { v: '', t: 'Todas', n: cuenta('unidad', () => true) },
            ...unidades.map((u) => ({ v: u, t: u, n: cuenta('unidad', (p) => (p.unidades_medida?.nombre || 'N/D') === u) })),
        ] } }),
        thColumna({ orden: invResumenOrden, campo: 'stock', titulo: conReservas ? 'Existencia' : 'Stock', clase: 'text-right', filtro: { id: 'stock', valor: invFiltros.stock,
            opciones: opcSiNo('stock', 'Con existencia', 'Sin existencia', (p) => Number(p.stock_actual || 0)) } }),
        ...(conReservas ? [
            thColumna({ orden: invResumenOrden, campo: 'reservado', titulo: 'Reservado', clase: 'text-right', filtro: { id: 'reservado', valor: invFiltros.reservado,
                opciones: opcSiNo('reservado', 'Con reservado', 'Sin reservado', reservadoDe) } }),
            thColumna({ orden: invResumenOrden, campo: 'libre', titulo: 'Libre', clase: 'text-right', filtro: { id: 'libre', valor: invFiltros.libre,
                opciones: opcSiNo('libre', 'Con libre', 'Sin libre', libreDe) } }),
        ] : []),
        thColumna({ orden: invResumenOrden, campo: 'costo', titulo: 'Costo unitario', clase: 'text-right', filtro: { id: 'costo', valor: invFiltros.costo,
            opciones: opcSiNo('costo', 'Con costo', 'Sin costo ($0)', (p) => Number(p.costo_unitario || 0)) } }),
    ].join('');
    const anchos = conReservas ? [27, 17, 9, 10, 10, 10, 17] : [34, 20, 11, 15, 20];
    const filas = lista.map((item) => {
        const c = INV_CLASES[invClaseDe(item)];
        const esTerm = invClaseDe(item) === 'terminados';
        const res = reservadoDe(item);
        const codigoMoneda = item.monedas?.codigo || 'MXN';
        return `
            <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                <td class="p-3 font-medium text-slate-100 truncate" title="${escLote(item.nombre)}">${escLote(item.nombre)} <span class="text-xs text-slate-500 font-mono">(${escLote(item.sku || 'N/D')})</span></td>
                <td class="p-3 text-xs ${c.cls} truncate">${c.t}</td>
                <td class="p-3 text-slate-400 text-xs">${escLote(item.unidades_medida?.nombre || 'N/D')}</td>
                <td class="p-3 text-right font-mono font-semibold">${item.stock_actual || 0}</td>
                ${conReservas ? `
                <td class="p-3 text-right font-mono ${res > 0 ? 'text-sky-300' : 'text-slate-600'}">${esTerm ? res : '—'}</td>
                <td class="p-3 text-right font-mono ${esTerm && res > 0 ? 'text-amber-300 font-semibold' : 'text-slate-400'}">${esTerm ? libreDe(item) : '—'}</td>` : ''}
                <td class="p-3 text-right font-mono text-slate-300">$${Number(item.costo_unitario || 0).toFixed(2)} <span class="text-[10px] text-slate-500">${codigoMoneda}</span></td>
            </tr>`;
    }).join('');

    const hayFiltros = Object.values(invFiltros).some(Boolean);
    contenedorInv.innerHTML = `
        <div class="flex items-center justify-between gap-2 mb-2 text-[11px] text-slate-500">
            <span>${lista.length} de ${base.length} artículos</span>
            ${hayFiltros ? '<button type="button" id="invLimpiarFiltros" class="text-sky-300 hover:text-sky-200 underline">Quitar filtros</button>' : ''}
        </div>
        <div class="border border-slate-800 rounded-xl bg-slate-950">
          <table class="w-full table-fixed text-left text-sm text-slate-300">
            <colgroup>${anchos.map((a) => `<col style="width:${a}%">`).join('')}</colgroup>
            <thead class="bg-slate-900 text-slate-300 border-b border-slate-800 text-xs"><tr>${th}</tr></thead>
            <tbody>${filas || `<tr><td colspan="${anchos.length}" class="p-4 text-center text-slate-500">No se encontraron artículos con ese criterio.</td></tr>`}</tbody>
          </table>
        </div>`;

    wireOrdenTabla(contenedorInv, invResumenOrden, () => renderInventarioResumen());
    wireFiltrosColumna(contenedorInv, (id, valor) => { invFiltros[id] = valor; renderInventarioResumen(); });
    contenedorInv.querySelector('#invLimpiarFiltros')?.addEventListener('click', () => {
        Object.keys(invFiltros).forEach((k) => { invFiltros[k] = ''; });
        renderInventarioResumen();
    });
}

const escLote = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

async function renderizarTablaLotes(contenedorLotes) {
    const textoProd = filtroProductoIdLotes ? '' : limpiarFiltroTexto(filtroProductoLotes);
    const textoLote = limpiarFiltroTexto(filtroNumeroLote);
    // !inner solo cuando se filtra por producto: así el filtro del producto también descarta los lotes (no solo vacía el embebido).
    let query = supabaseClient
        .from('lotes_inventario')
        .select(`
            id, numero_lote, stock_actual, costo_unitario, fecha_ingreso,
            productos${textoProd ? '!inner' : ''} ( nombre, sku, tipo )
        `, { count: 'exact' })
        .order('fecha_ingreso', { ascending: false })
        .order('id', { ascending: false });

    if (fechaInicioFiltro) query = query.gte('fecha_ingreso', fechaInicioFiltro);
    if (fechaFinFiltro) query = query.lte('fecha_ingreso', fechaFinFiltro);
    if (textoProd) query = query.or(`nombre.ilike.%${textoProd}%,sku.ilike.%${textoProd}%`, { referencedTable: 'productos', foreignTable: 'productos' });
    if (textoLote) query = query.ilike('numero_lote', `%${textoLote}%`);
    if (filtroProductoIdLotes) query = query.eq('producto_id', filtroProductoIdLotes);
    if (filtroSoloConExistencia) query = query.gt('stock_actual', 0);

    const desde = (paginaActualLotes - 1) * porPaginaLotes;
    const hasta = desde + porPaginaLotes - 1;
    query = query.range(desde, hasta);

    const { data: lotes, count, error: errLotes } = await query;
    if (errLotes) throw errLotes;

    aplicarOrden(invLotesOrden, lotes || [], (l, campo) => {
        switch (campo) {
            case 'lote': return (l.numero_lote || '').toLowerCase();
            case 'producto': return (l.productos?.nombre || '').toLowerCase();
            case 'tipo': return (l.productos?.tipo || '').toLowerCase();
            case 'stock': return Number(l.stock_actual || 0);
            case 'costo': return Number(l.costo_unitario || 0);
            case 'ingreso': return l.fecha_ingreso ? new Date(l.fecha_ingreso).getTime() : 0;
            default: return l.id;
        }
    });

    const totalRegistros = count || 0;
    const totalPaginas = Math.ceil(totalRegistros / porPaginaLotes) || 1;

    let htmlLotes = `
        <div class="bg-slate-900 border border-slate-800 px-3 py-2 rounded-xl mb-2 flex flex-wrap gap-x-4 gap-y-1 items-center justify-between lotes-filtros">
            <div class="flex flex-wrap items-center gap-x-3 gap-y-1.5">
                <div class="flex items-center gap-1.5">
                    <label class="text-xs text-slate-400 whitespace-nowrap">Desde:</label>
                    <input type="date" id="filtroFechaInicio" value="${fechaInicioFiltro}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-2 py-1 focus:outline-none focus:border-indigo-500">
                </div>
                <div class="flex items-center gap-1.5">
                    <label class="text-xs text-slate-400 whitespace-nowrap">Hasta:</label>
                    <input type="date" id="filtroFechaFin" value="${fechaFinFiltro}" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-2 py-1 focus:outline-none focus:border-indigo-500">
                </div>
                <div class="relative flex items-center gap-1.5">
                    <label class="text-xs text-slate-400 whitespace-nowrap">Producto (SKU o nombre):</label>
                    <input type="text" id="filtroLoteProducto" value="${escLote(filtroProductoLotes)}" placeholder="🔍 Escribe para buscar…" autocomplete="off" onkeydown="if(event.key==='Enter') window.aplicarFiltroFechasLotes()" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-2 py-1 w-52 focus:outline-none focus:border-indigo-500">
                    <div id="sugLoteProducto" class="hidden absolute left-0 right-0 top-full mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-2xl max-h-60 overflow-y-auto z-30"></div>
                </div>
                <div class="flex items-center gap-1.5">
                    <label class="text-xs text-slate-400 whitespace-nowrap">N.º de lote:</label>
                    <input type="text" id="filtroLoteNumero" value="${escLote(filtroNumeroLote)}" placeholder="Ej. AL1541" onkeydown="if(event.key==='Enter') window.aplicarFiltroFechasLotes()" class="bg-slate-950 border border-slate-700 text-slate-200 text-xs rounded-lg px-2 py-1 w-36 focus:outline-none focus:border-indigo-500">
                </div>
                <label class="flex items-center gap-1.5 text-xs text-slate-300 cursor-pointer"><input type="checkbox" id="filtroLoteConExistencia" class="accent-indigo-500" ${filtroSoloConExistencia ? 'checked' : ''}> Solo con existencia</label>
                <div class="flex items-center">
                    <button type="button" onclick="window.aplicarFiltroFechasLotes()" class="bg-indigo-600 hover:bg-indigo-500 text-white text-xs px-3 py-1 rounded-lg transition font-medium shadow-sm">Filtrar</button>
                    <button type="button" onclick="window.limpiarFiltroFechasLotes()" class="ml-2 bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs px-3 py-1 rounded-lg transition border border-slate-700">Limpiar</button>
                </div>
            </div>
            <div class="text-xs text-slate-400 font-mono">Total partidas: <span class="text-indigo-400 font-bold">${totalRegistros}</span></div>
        </div>
    `;

    if (!lotes || lotes.length === 0) {
        htmlLotes += `<div class="bg-slate-950 border border-slate-800 p-6 rounded-xl text-center text-slate-500 text-sm">No se encontraron lotes con esos filtros.</div>`;
    } else {
        htmlLotes += `
            <div class="lotes-scroll overflow-x-auto border border-slate-800 rounded-xl bg-slate-950">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900 text-indigo-400 border-b border-slate-800 text-xs uppercase">
                        <tr>
                            <th class="px-3 py-2 text-left">Acción</th>
                            ${thOrden(invLotesOrden, 'lote', 'Lote / Ref')}
                            ${thOrden(invLotesOrden, 'producto', 'Insumo / Producto')}
                            ${thOrden(invLotesOrden, 'tipo', 'Tipo')}
                            ${thOrden(invLotesOrden, 'stock', 'Stock Lote')}
                            ${thOrden(invLotesOrden, 'costo', 'Costo U.')}
                            ${thOrden(invLotesOrden, 'ingreso', 'Ingreso')}
                        </tr>
                    </thead>
                    <tbody>
        `;
        lotes.forEach(l => {
            const nombreProd = l.productos?.nombre || 'Desconocido';
            const tipoProd = l.productos?.tipo || 'General';
            const fechaIng = l.fecha_ingreso ? fechaLocalTxt(l.fecha_ingreso) : 'N/D';

            htmlLotes += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition">
                    <td class="px-3 py-1 whitespace-nowrap">
                        <button type="button" onclick="window.verDetalleLoteMovimiento(${l.id})" class="bg-slate-800 hover:bg-slate-700 text-indigo-300 text-xs px-2 py-0.5 rounded-lg border border-slate-700 transition font-medium">🔍 Documento</button>
                        <button type="button" onclick="window.registrarDeterioroLote(${l.id}, '${String(l.numero_lote || 'S/N').replace(/'/g, "\\'")}', ${Number(l.costo_unitario || 0)})" title="Castigar el costo del lote por caducidad, daño u obsolescencia (NIF C-4: costo o valor neto de realización, el menor)" class="bg-slate-800 hover:bg-slate-700 text-amber-300 text-xs px-2 py-0.5 rounded-lg border border-slate-700 transition font-medium ml-1">📉 Deterioro</button>
                    </td>
                    <td class="px-3 py-1 font-mono text-xs text-indigo-300">#${l.id} - ${l.numero_lote || 'S/N'}</td>
                    <td class="px-3 py-1 font-medium text-slate-100">${nombreProd}${l.productos?.sku ? `<span class="block text-[10px] font-mono text-slate-500">${escLote(l.productos.sku)}</span>` : ''}</td>
                    <td class="px-3 py-1 text-xs uppercase text-slate-400">${tipoProd}</td>
                    <td class="px-3 py-1 font-mono text-amber-300 font-semibold">${l.stock_actual}</td>
                    <td class="px-3 py-1 font-mono text-slate-300">$${Number(l.costo_unitario || 0).toFixed(2)}</td>
                    <td class="px-3 py-1 text-xs text-slate-400">${fechaIng}</td>
                </tr>
            `;
        });
        htmlLotes += `</tbody></table></div>`;

        htmlLotes += `
            <div class="flex items-center justify-between mt-4 px-2">
                <span class="text-xs text-slate-400">Página <strong class="text-slate-200">${paginaActualLotes}</strong> de <strong class="text-slate-200">${totalPaginas}</strong></span>
                <div class="flex gap-2">
                    <button type="button" onclick="window.cambiarPaginaLotes(${paginaActualLotes - 1})" ${paginaActualLotes <= 1 ? 'disabled class="opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800 text-xs px-3 py-1.5 rounded-lg"' : 'class="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-xs px-3 py-1.5 rounded-lg transition"'}>← Anterior</button>
                    <button type="button" onclick="window.cambiarPaginaLotes(${paginaActualLotes + 1})" ${paginaActualLotes >= totalPaginas ? 'disabled class="opacity-50 cursor-not-allowed bg-slate-900 text-slate-600 border border-slate-800 text-xs px-3 py-1.5 rounded-lg"' : 'class="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-xs px-3 py-1.5 rounded-lg transition"'}>Siguiente →</button>
                </div>
            </div>
        `;
    }

    contenedorLotes.innerHTML = htmlLotes;
    wireOrdenTabla(contenedorLotes, invLotesOrden, () => renderizarTablaLotes(contenedorLotes));
    wireBuscadorProductoLotes(contenedorLotes);
}

// Buscador con sugerencias del filtro "Producto": mientras se escribe va trayendo coincidencias (SKU o nombre) para
// elegir una; al elegirla se filtra por ESE producto. Sin elegir, Enter / "Filtrar" busca por el texto como antes.
function wireBuscadorProductoLotes(contenedor) {
    const input = contenedor.querySelector('#filtroLoteProducto');
    const caja = contenedor.querySelector('#sugLoteProducto');
    if (!input || !caja) return;
    let temporizador = null, secuencia = 0, items = [], activo = -1;

    const cerrar = () => { caja.classList.add('hidden'); caja.innerHTML = ''; items = []; activo = -1; };
    const marcar = () => caja.querySelectorAll('[data-i]').forEach((el) => el.classList.toggle('bg-slate-800', Number(el.dataset.i) === activo));
    const elegir = (p) => {
        filtroProductoLotes = p.nombre || '';
        filtroProductoIdLotes = p.id;
        paginaActualLotes = 1;
        cerrar();
        renderizarTablaLotes(contenedor);
    };
    const pintar = (lista, texto) => {
        items = lista; activo = -1;
        caja.innerHTML = lista.length
            ? lista.map((p, i) => `
                <button type="button" data-i="${i}" class="w-full text-left px-3 py-2 hover:bg-slate-800 border-b border-slate-800 last:border-0">
                    <span class="block text-xs text-slate-100">${escLote(p.nombre)}</span>
                    <span class="block text-[10px] font-mono text-slate-500">${escLote(p.sku || 's/sku')} · ${escLote(p.tipo || '')}</span>
                </button>`).join('')
            : `<p class="px-3 py-2 text-xs text-slate-500">Sin productos que coincidan con "${escLote(texto)}".</p>`;
        caja.classList.remove('hidden');
        caja.querySelectorAll('[data-i]').forEach((b) => b.addEventListener('mousedown', (e) => { e.preventDefault(); elegir(items[Number(b.dataset.i)]); }));
    };

    input.addEventListener('input', () => {
        filtroProductoIdLotes = null;   // editó el texto: ya no es el producto elegido
        clearTimeout(temporizador);
        const texto = limpiarFiltroTexto(input.value);
        if (texto.length < 2) { cerrar(); return; }
        temporizador = setTimeout(async () => {
            const mia = ++secuencia;
            const { data } = await supabaseClient.from('productos').select('id, sku, nombre, tipo')
                .or(`nombre.ilike.%${texto}%,sku.ilike.%${texto}%`).order('nombre').limit(10);
            if (mia !== secuencia) return;   // llegó una búsqueda más nueva
            pintar(data || [], texto);
        }, 250);
    });
    input.addEventListener('keydown', (e) => {
        if (caja.classList.contains('hidden') || !items.length) return;
        if (e.key === 'ArrowDown') { e.preventDefault(); activo = Math.min(activo + 1, items.length - 1); marcar(); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); activo = Math.max(activo - 1, 0); marcar(); }
        else if (e.key === 'Enter' && activo >= 0) { e.preventDefault(); e.stopImmediatePropagation(); elegir(items[activo]); }
        else if (e.key === 'Escape') cerrar();
    }, true);
    input.addEventListener('blur', () => setTimeout(cerrar, 150));
}

window.aplicarFiltroFechasLotes = function() {
    fechaInicioFiltro = document.getElementById('filtroFechaInicio')?.value || '';
    fechaFinFiltro = document.getElementById('filtroFechaFin')?.value || '';
    const txtProd = document.getElementById('filtroLoteProducto')?.value || '';
    if (txtProd !== filtroProductoLotes) filtroProductoIdLotes = null;   // escribió algo distinto a lo elegido: vuelve a buscar por texto
    filtroProductoLotes = txtProd;
    filtroNumeroLote = document.getElementById('filtroLoteNumero')?.value || '';
    filtroSoloConExistencia = !!document.getElementById('filtroLoteConExistencia')?.checked;
    paginaActualLotes = 1;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

window.limpiarFiltroFechasLotes = function() {
    fechaInicioFiltro = '';
    fechaFinFiltro = '';
    filtroProductoLotes = '';
    filtroProductoIdLotes = null;
    filtroNumeroLote = '';
    filtroSoloConExistencia = false;
    paginaActualLotes = 1;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

window.cambiarPaginaLotes = function(nuevaPagina) {
    paginaActualLotes = nuevaPagina;
    renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
};

// Deterioro de inventario (NIF C-4: costo o valor neto de realización, el
// menor) — castiga el costo unitario de un lote específico por caducidad,
// daño u obsolescencia. Solo permite bajar el costo, nunca subirlo.
// Requiere sql/2026-09-14b_deterioro_inventario.sql.
window.registrarDeterioroLote = async function(loteId, numeroLote, costoActual) {
    const costoStr = prompt(
        `Lote ${numeroLote} — costo unitario actual: $${Number(costoActual).toFixed(4)}\n\n` +
        `¿Cuál es el nuevo costo unitario (valor neto de realización)? Debe ser MENOR al actual.`,
        ''
    );
    if (costoStr === null) return;
    const costoNuevo = parseFloat(costoStr);
    if (!Number.isFinite(costoNuevo) || costoNuevo < 0) { alert('Costo inválido.'); return; }
    if (costoNuevo >= Number(costoActual)) { alert('El nuevo costo debe ser menor al costo actual — esto solo registra deterioro (castigo hacia abajo), no una revaluación.'); return; }

    const motivo = prompt('Motivo del deterioro (caducidad, daño, obsolescencia, etc.):', '');
    if (motivo === null || !motivo.trim()) { alert('El motivo es obligatorio.'); return; }

    try {
        const { data, error } = await supabaseClient.rpc('registrar_deterioro_inventario', {
            p_lote_id: loteId, p_costo_nuevo: costoNuevo, p_motivo: motivo.trim(),
        });
        if (error) throw error;
        alert(`Deterioro registrado — castigo de ${money(data.monto_castigo)} (póliza ${await etiquetaPoliza(data.poliza_id)}). Nuevo costo del lote: $${Number(data.costo_nuevo).toFixed(4)}.`);
        await renderizarTablaLotes(document.getElementById('contenedorExistenciasLote'));
    } catch (err) {
        const m = err?.message || String(err);
        if (/does not exist|schema cache|could not find/i.test(m)) {
            alert('Falta correr sql/2026-09-14b_deterioro_inventario.sql en Supabase.');
        } else {
            alert('No se pudo registrar el deterioro: ' + m);
        }
    }
};

window.verDetalleLoteMovimiento = async function(loteId) {
    try {
        if (!supabaseClient) return;
        const { data: loteInfo, error: errLote } = await supabaseClient
            .from('lotes_inventario')
            .select(`id, numero_lote, stock_actual, costo_unitario, fecha_ingreso, productos ( id, nombre, tipo )`)
            .eq('id', loteId)
            .single();

        if (errLote || !loteInfo) { alert("No se encontró información para este lote."); return; }

        let documentoIdEncontrado = null;
        let infoDetalle = null;

        const { data: detData } = await supabaseClient
            .from('documento_detalles')
            .select('cantidad, costo_unitario, subtotal, documento_id')
            .eq('lote_id', loteId)
            .maybeSingle();

        if (detData && detData.documento_id) {
            documentoIdEncontrado = detData.documento_id;
            infoDetalle = detData;
        } else {
            const { data: movData } = await supabaseClient
                .from('movimientos_inventario')
                .select('cantidad, costo_unitario, documento_id')
                .eq('lote_id', loteId)
                .not('documento_id', 'is', null)
                .limit(1)
                .maybeSingle();

            if (movData && movData.documento_id) {
                documentoIdEncontrado = movData.documento_id;
                infoDetalle = {
                    cantidad: movData.cantidad,
                    costo_unitario: movData.costo_unitario,
                    subtotal: Number(movData.cantidad || 0) * Number(movData.costo_unitario || 0)
                };
            }
        }

        let doc = null;
        if (documentoIdEncontrado) {
            const { data: docData } = await supabaseClient
                .from('documentos')
                .select(`id, tipo_movimiento, folio, fecha_emision, descripcion, estado, proveedores ( nombre )`)
                .eq('id', documentoIdEncontrado)
                .maybeSingle();
            doc = docData;
        }

        const nombreProd = loteInfo.productos?.nombre || 'N/D';
        const numLoteStr = loteInfo.numero_lote || `Lote #${loteInfo.id}`;
        
        let info = `📋 INFORMACIÓN DEL LOTE / TRAZABILIDAD\n-----------------------------------\n` +
                   `• Producto: ${nombreProd}\n• Identificador de Lote: ${numLoteStr}\n` +
                   `• Stock Actual en Lote: ${loteInfo.stock_actual}\n` +
                   `• Costo Unitario: $${Number(loteInfo.costo_unitario || 0).toFixed(2)}\n` +
                   `• Fecha de Ingreso: ${loteInfo.fecha_ingreso ? fechaLocalTxt(loteInfo.fecha_ingreso) : 'N/D'}\n\n`;

        if (doc) {
            info += `📄 DOCUMENTO VINCULADO:\n• ID Documento: #${doc.id}\n• Tipo de Movimiento: ${doc.tipo_movimiento.toUpperCase()}\n` +
                    `• Folio: ${doc.folio || 'N/D'}\n• Proveedor: ${doc.proveedores?.nombre || 'N/D'}\n` +
                    `• Estado: ${doc.estado}\n• Descripción: ${doc.descripcion || 'Sin descripción'}`;
        } else {
            info += `⚠️ Nota: Este lote no cuenta con un documento de entrada/compra formal asociado.`;
        }

        alert(info);
    } catch (err) {
        console.error("Error al consultar detalle del lote:", err);
    }
};

document.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && (e.target.id === 'filtroFechaInicio' || e.target.id === 'filtroFechaFin')) {
        window.aplicarFiltroFechasLotes();
    }
});
