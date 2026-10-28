import { supabaseClient } from './supabase.js';
import { siguientePeriodoSugerido, nomAutorizar, nomCancelar } from './nomina.js';
import { montarGuia } from './asistente-contable.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { thColumna, wireFiltrosColumna } from './filtro-columna.js';

const histTareasOrden = crearOrdenTabla();

// =====================================================================
// Tareas — bandeja de pendientes que requieren revisión humana.
// Dos orígenes, mostrados en UNA sola tabla (mismo diseño que Stock General y Kardex):
//   1. Tareas persistentes de la tabla public.tareas (las genera el
//      sistema solo: 'inventario_bajo_minimo', 'caducidad_proxima').
//      Se marcan Atendida / No aceptada (posponer) / No aplica (archivar, automático) /
//      Cancelar (a mano, ya se atendió por otro medio — distinto de "archivar").
//   2. Señales calculadas al vuelo (nóminas en borrador, recordatorio
//      del viernes) que no viven en una tabla.
// Agregar un tipo nuevo = sumar un fetcher y su renglón en construirFilas(), no rediseñar la pantalla.
// Pestañas: "Pendientes" (esta tabla) e "Historial" (todas las tareas ya resueltas).
// =====================================================================

import { money, money4, importe, redondear2 } from './formato.js';
import { hoyISO } from './fechas.js';
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

// Cache de lo ya traído, para filtrar/ordenar en cliente sin volver a golpear Supabase.
let tareasCacheSistema = [];
let tareasCacheBorradores = [];
let tareasCacheRecordatorio = null;
let tareasFiltroTexto = '';
let tareasProductosMapa = new Map();   // producto_id -> { nombre, proveedorId, proveedorNombre }
let tareasSeleccionadas = new Set();   // ids de tareas persistentes marcadas (compra, caducidad…)

// Filtros por columna (menú ▼ del encabezado) y orden de la tabla de pendientes. '' = sin filtrar.
const pendFiltros = { prio: '', tipo: '', area: '', prov: '', est: '' };
const pendOrden = crearOrdenTabla('defecto', 'asc');   // defecto = contables primero, luego prioridad y antigüedad
let tareasPestana = 'pendientes';

const PRIO_LABEL = { 1: 'Alta', 2: 'Normal', 3: 'Baja' };
const PRIO_CHIP = {
    1: 'bg-rose-900/60 text-rose-300 border-rose-700',
    2: 'bg-amber-900/50 text-amber-300 border-amber-700',
    3: 'bg-slate-800 text-slate-400 border-slate-700',
};
const AREA_LABEL = { almacen: 'Almacén', contable: 'Contable' };
const EST_LABEL = { pendiente: 'Pendiente', reaparecio: 'Reapareció' };
const TIPO_FILA_LABEL = { nomina_borrador: 'Nómina por autorizar', nomina_recordatorio: 'Nómina del viernes' };
const tipoLabel = (t) => TIPO_FILA_LABEL[t] || TIPO_LABEL[t] || t;
const ANCHOS_TAREAS = [4, 8, 30, 11, 8, 13, 9, 8, 9];

// ---------------------------------------------------------------------
// Carga
// ---------------------------------------------------------------------
// `departamento` ('almacen' | 'contable' | null) llega desde el menú ("Tareas de almacén" / "Tareas contables")
// y solo preselecciona el filtro de Área. `limpiarBusqueda` = se está ABRIENDO la pantalla (no recargando tras una acción):
// búsqueda y filtros parten limpios, para que nada anterior esconda una tarea.
export async function cargarModuloTareas(departamento, { limpiarBusqueda = false } = {}) {
    if (limpiarBusqueda) {
        tareasFiltroTexto = '';
        Object.keys(pendFiltros).forEach((k) => { pendFiltros[k] = ''; });
        pendFiltros.area = departamento || '';
        tareasPestana = 'pendientes';
    }
    prepararPestanas();
    mostrarPestana(tareasPestana);

    const cont = document.getElementById('contenedorTareas');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Cargando tareas...</p>`;

    try {
        const [sistema, borradores, recordatorio] = await Promise.all([
            fetchTareasSistema(),
            fetchNominasBorrador(),
            fetchRecordatorioViernes(),
        ]);
        tareasCacheSistema = sistema;
        tareasCacheBorradores = borradores;
        tareasCacheRecordatorio = recordatorio;
        tareasSeleccionadas = new Set();
        await cargarProductosDeTareas(sistema);
        renderTareasActivas();
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar tareas: ${err.message || err}</p>`;
    } finally {
        montarGuia(cont, 'tareas');
    }
}

function prepararPestanas() {
    const bP = document.getElementById('tareasTabPend');
    const bH = document.getElementById('tareasTabHist');
    if (!bP || !bH || bP.dataset.listo) return;
    bP.dataset.listo = '1';
    bP.addEventListener('click', () => mostrarPestana('pendientes'));
    bH.addEventListener('click', () => mostrarPestana('historial'));
}

function mostrarPestana(cual) {
    tareasPestana = cual;
    const pP = document.getElementById('tareasPanelPend');
    const pH = document.getElementById('tareasPanelHist');
    const bP = document.getElementById('tareasTabPend');
    const bH = document.getElementById('tareasTabHist');
    if (!pP || !pH) return;
    pP.classList.toggle('hidden', cual !== 'pendientes');
    pH.classList.toggle('hidden', cual !== 'historial');
    const on = 'text-sky-300 border-sky-500';
    const off = 'text-slate-400 border-transparent hover:text-slate-200';
    if (bP) bP.className = `px-4 py-2 text-sm font-semibold border-b-2 cursor-pointer ${cual === 'pendientes' ? on : off}`;
    if (bH) bH.className = `px-4 py-2 text-sm font-semibold border-b-2 cursor-pointer ${cual === 'historial' ? on : off}`;
    if (cual === 'historial') cargarHistorialTareas();
}

// Para poder agrupar por proveedor en una sola requisición (ver
// tareasGenerarRequisicionConjunta), se necesita saber el proveedor de cada
// producto con alerta de "inventario bajo mínimo" — la tarea en sí no lo trae.
async function cargarProductosDeTareas(sistema) {
    tareasProductosMapa = new Map();
    const ids = [...new Set(sistema
        .filter((t) => t.accion_sugerida === 'crear_orden_compra' && t.entidad_id)
        .map((t) => Number(t.entidad_id)))];
    if (!ids.length) return;
    try {
        const { data, error } = await supabaseClient
            .from('productos')
            .select('id, nombre, proveedor_id, proveedores ( nombre )')
            .in('id', ids);
        if (error) throw error;
        (data || []).forEach((p) => tareasProductosMapa.set(p.id, {
            nombre: p.nombre, proveedorId: p.proveedor_id || null, proveedorNombre: p.proveedores?.nombre || null,
        }));
    } catch (_) { /* si falla, el selector conjunto simplemente no agrupará por proveedor */ }
}

// ---------------------------------------------------------------------
// Filas unificadas (una por tarea, venga de donde venga)
// ---------------------------------------------------------------------
function construirFilas() {
    const filas = [];
    tareasCacheSistema.forEach((t) => {
        const esCompra = t.accion_sugerida === 'crear_orden_compra';
        const info = esCompra ? tareasProductosMapa.get(Number(t.entidad_id)) : null;
        filas.push({
            clave: `t${t.id}`, kind: 'sistema', id: t.id, area: 'almacen', tipo: t.tipo, prio: t.prioridad || 2,
            titulo: t.titulo || '', detalle: t.detalle || '',
            prov: esCompra ? (info?.proveedorNombre || 'Sin proveedor') : '',
            creada: t.creada_en || '', est: t.estatus === 'pospuesta' ? 'reaparecio' : 'pendiente',
            esCompra, t,
        });
    });
    tareasCacheBorradores.forEach((n) => {
        filas.push({
            clave: `n${n.id}`, kind: 'nomina', id: n.id, area: 'contable', tipo: 'nomina_borrador', prio: 1,
            titulo: `Nómina #${n.id} — semana del ${n.periodo_inicio} al ${n.periodo_fin}`,
            detalle: `Fecha de pago ${n.fecha_pago} · ${n.condicion === 'contado' ? 'Contado' : 'Crédito (por pagar)'} · Total ${money(n.total)}`,
            prov: '', creada: `${n.periodo_fin}T00:00:00`, est: 'pendiente', n,
        });
    });
    if (tareasCacheRecordatorio) {
        const s = tareasCacheRecordatorio;
        filas.push({
            clave: 'r0', kind: 'recordatorio', id: 0, area: 'contable', tipo: 'nomina_recordatorio', prio: 1,
            titulo: `Semana del ${s.inicio} al ${s.fin} lista para pre-ejecutar`,
            detalle: 'Ya es viernes de esa semana y todavía no se ha pre-ejecutado (a mano ni por la tarea automática de Supabase).',
            prov: '', creada: `${s.fin}T00:00:00`, est: 'pendiente', s,
        });
    }
    return filas;
}

const edadTxt = (iso) => {
    if (!iso) return '';
    const d = Math.floor((Date.now() - new Date(iso).getTime()) / 86400000);
    return d <= 0 ? 'hoy' : `hace ${d} d`;
};

// ---------------------------------------------------------------------
// Pantalla: resumen clicable + buscador + tabla con filtros por columna
// ---------------------------------------------------------------------
function renderTareasActivas() {
    const cont = document.getElementById('contenedorTareas');
    if (!cont) return;

    const filas = construirFilas();
    const tabP = document.getElementById('tareasTabPend');
    if (tabP) tabP.innerHTML = `Pendientes <span class="ml-1 text-[11px] font-mono ${filas.length ? 'text-amber-300' : 'text-slate-500'}">${filas.length}</span>`;

    const texto = tareasFiltroTexto.trim().toLowerCase();
    const pasaTexto = (r) => !texto || tareasSeleccionadas.has(r.id) && r.kind === 'sistema'
        || `${r.titulo} ${r.detalle} ${r.prov}`.toLowerCase().includes(texto);
    const base = filas.filter(pasaTexto);

    const F = pendFiltros;
    const cumple = (r, excepto) => {
        if (excepto !== 'prio' && F.prio && String(r.prio) !== F.prio) return false;
        if (excepto !== 'tipo' && F.tipo && r.tipo !== F.tipo) return false;
        if (excepto !== 'area' && F.area && r.area !== F.area) return false;
        if (excepto !== 'prov' && F.prov && r.prov !== F.prov) return false;
        if (excepto !== 'est' && F.est && r.est !== F.est) return false;
        return true;
    };
    const lista = base.filter((r) => cumple(r, null));
    const cuenta = (excepto, fn) => base.filter((r) => cumple(r, excepto) && fn(r)).length;

    aplicarOrden(pendOrden, lista, (r, campo) => {
        switch (campo) {
            case 'prio': return r.prio;
            case 'titulo': return r.titulo.toLowerCase();
            case 'tipo': return tipoLabel(r.tipo).toLowerCase();
            case 'area': return r.area;
            case 'prov': return r.prov.toLowerCase();
            case 'creada': return r.creada;
            case 'est': return r.est;
            default: return `${r.area === 'contable' ? 0 : 1}|${r.prio}|${r.creada}`;   // contables primero, luego prioridad y antigüedad
        }
    });

    // ----- resumen clicable (cada chip enciende/apaga UN filtro) -----
    const chip = (etq, campo, valor, n, tono) => {
        const activo = F[campo] === valor && valor !== '';
        return `<button type="button" data-chip="${campo}" data-v="${valor}" class="tareas-chip px-3 py-1.5 rounded-lg border text-xs text-left cursor-pointer ${activo ? 'bg-sky-900/60 border-sky-500 text-sky-100' : 'bg-slate-900 border-slate-700 text-slate-300 hover:border-slate-500'}">
            <span class="block text-[10px] text-slate-400">${etq}</span><span class="font-mono text-sm font-semibold ${tono}">${n}</span></button>`;
    };
    const total = base.length;
    const chips = [
        chip('Todas', 'prio', '', total, 'text-slate-100'),
        chip('Prioridad alta', 'prio', '1', base.filter((r) => r.prio === 1).length, 'text-rose-300'),
        chip('Compras', 'tipo', 'inventario_bajo_minimo', base.filter((r) => r.tipo === 'inventario_bajo_minimo').length, 'text-amber-300'),
        chip('Caducidad', 'tipo', 'caducidad_proxima', base.filter((r) => r.tipo === 'caducidad_proxima').length, 'text-amber-300'),
        chip('Contables', 'area', 'contable', base.filter((r) => r.area === 'contable').length, 'text-sky-300'),
        chip('Reaparecidas', 'est', 'reaparecio', base.filter((r) => r.est === 'reaparecio').length, 'text-sky-300'),
    ].join('');

    // ----- encabezados con filtro ▼ y orden ⇅ -----
    const provs = [...new Set(base.map((r) => r.prov).filter(Boolean))].sort((a, b) => a.localeCompare(b, 'es'));
    const tipos = [...new Set(base.map((r) => r.tipo))];
    const todasVisiblesSel = lista.some((r) => r.kind === 'sistema') && lista.filter((r) => r.kind === 'sistema').every((r) => tareasSeleccionadas.has(r.id));
    const th = [
        `<th class="px-3 py-2"><input type="checkbox" id="tareasSelTodas" class="accent-sky-500 w-4 h-4" ${todasVisiblesSel ? 'checked' : ''} title="Seleccionar todas las tareas visibles"></th>`,
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'prio', titulo: 'Prioridad', filtro: { id: 'prio', valor: F.prio, opciones: [
            { v: '', t: 'Todas', n: cuenta('prio', () => true) },
            ...[1, 2, 3].map((p) => ({ v: String(p), t: PRIO_LABEL[p], n: cuenta('prio', (r) => r.prio === p) })),
        ] } }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'titulo', titulo: 'Tarea' }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'tipo', titulo: 'Tipo', filtro: { id: 'tipo', valor: F.tipo, opciones: [
            { v: '', t: 'Todos', n: cuenta('tipo', () => true) },
            ...tipos.map((t) => ({ v: t, t: tipoLabel(t), n: cuenta('tipo', (r) => r.tipo === t) })),
        ] } }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'area', titulo: 'Área', filtro: { id: 'area', valor: F.area, opciones: [
            { v: '', t: 'Todas', n: cuenta('area', () => true) },
            ...Object.entries(AREA_LABEL).map(([k, l]) => ({ v: k, t: l, n: cuenta('area', (r) => r.area === k) })),
        ] } }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'prov', titulo: 'Proveedor', filtro: { id: 'prov', valor: F.prov, opciones: [
            { v: '', t: 'Todos', n: cuenta('prov', () => true) },
            ...provs.map((p) => ({ v: p, t: p, n: cuenta('prov', (r) => r.prov === p) })),
        ] } }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'creada', titulo: 'Creada' }),
        thColumna({ orden: pendOrden, pad: 'px-3 py-2', campo: 'est', titulo: 'Estatus', filtro: { id: 'est', valor: F.est, opciones: [
            { v: '', t: 'Todos', n: cuenta('est', () => true) },
            ...Object.entries(EST_LABEL).map(([k, l]) => ({ v: k, t: l, n: cuenta('est', (r) => r.est === k) })),
        ] } }),
        '<th class="px-3 py-2 text-right">Acciones</th>',
    ].join('');

    const cuerpo = lista.length ? lista.map(filaTarea).join('')
        : `<tr><td colspan="${ANCHOS_TAREAS.length}" class="p-4 text-center text-slate-500 text-sm">${filas.length ? 'Sin tareas con esos filtros.' : 'Sin tareas pendientes.'}</td></tr>`;

    const hayFiltros = Object.values(F).some(Boolean) || texto;
    cont.innerHTML = `
        <div class="flex flex-wrap gap-2 mb-2">${chips}</div>
        <input type="text" id="tareasBuscador" value="${esc(tareasFiltroTexto)}" placeholder="🔍 Buscar por tarea, detalle o proveedor…" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 mb-2">
        ${renderBarraSeleccion()}
        <div class="flex items-center justify-between gap-3 text-[11px] text-slate-500 mb-1 min-h-[1rem]">
            <span>${lista.length} de ${filas.length} tareas</span>
            ${hayFiltros ? '<button type="button" id="tareasLimpiarFiltros" class="text-sky-300 hover:text-sky-200 underline shrink-0">Quitar filtros</button>' : ''}
        </div>
        <div class="border border-slate-800 rounded-xl bg-slate-950">
          <table class="w-full table-fixed text-left text-sm text-slate-300">
            <colgroup>${ANCHOS_TAREAS.map((a) => `<col style="width:${a}%">`).join('')}</colgroup>
            <thead class="bg-slate-900 text-slate-300 border-b border-slate-800 text-xs"><tr>${th}</tr></thead>
            <tbody>${cuerpo}</tbody>
          </table>
        </div>`;

    cablearTareas(cont);
}

function filaTarea(r) {
    const selec = r.kind === 'sistema';
    const check = selec
        ? `<input type="checkbox" class="tarea-check accent-sky-500 w-4 h-4" data-tarea="${r.id}" ${tareasSeleccionadas.has(r.id) ? 'checked' : ''} title="Seleccionar">`
        : '';
    const estChip = r.est === 'reaparecio'
        ? '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-sky-950 text-sky-300 whitespace-nowrap" title="Venció el aplazamiento y la condición sigue">Reapareció</span>'
        : '<span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-amber-950 text-amber-300">Pendiente</span>';
    const fecha = r.creada ? new Date(r.creada).toLocaleDateString('es-MX', { day: '2-digit', month: '2-digit', year: '2-digit' }) : '';
    return `
        <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition align-top">
            <td class="px-3 py-2">${check}</td>
            <td class="px-3 py-2"><span class="text-[10px] border rounded px-1.5 py-0.5 ${PRIO_CHIP[r.prio] || PRIO_CHIP[2]}">${PRIO_LABEL[r.prio] || 'Normal'}</span></td>
            <td class="px-3 py-2"><p class="text-slate-100 font-medium">${esc(r.titulo)}</p>${r.detalle ? `<p class="text-[11px] text-slate-500">${esc(r.detalle)}</p>` : ''}</td>
            <td class="px-3 py-2 text-xs text-slate-400">${esc(tipoLabel(r.tipo))}</td>
            <td class="px-3 py-2 text-xs ${r.area === 'contable' ? 'text-sky-300' : 'text-slate-400'}">${AREA_LABEL[r.area]}</td>
            <td class="px-3 py-2 text-xs text-slate-400 truncate" title="${esc(r.prov)}">${esc(r.prov) || '<span class="text-slate-600">—</span>'}</td>
            <td class="px-3 py-2 text-xs text-slate-500 whitespace-nowrap">${fecha}<span class="block text-[10px] text-slate-600">${edadTxt(r.creada)}</span></td>
            <td class="px-3 py-2">${estChip}</td>
            <td class="px-3 py-2 text-right whitespace-nowrap">${accionesDe(r)}</td>
        </tr>`;
}

// Acción principal visible + menú ⋯ con el resto (mismo patrón que Requisiciones).
function accionesDe(r) {
    const menu = `<button type="button" class="tarea-menu text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1.5 rounded-lg border border-slate-700 cursor-pointer" data-clave="${r.clave}" title="Más acciones">⋯</button>`;
    const prim = 'text-xs px-3 py-1.5 rounded-lg border cursor-pointer';
    if (r.kind === 'nomina') {
        return `<button type="button" data-id="${r.id}" class="tarea-autorizar ${prim} bg-amber-800 hover:bg-amber-700 text-amber-100 border-amber-600">✔ Autorizar</button> ${menu}`;
    }
    if (r.kind === 'recordatorio') {
        return `<button type="button" class="tarea-ir-nomina ${prim} bg-amber-800 hover:bg-amber-700 text-amber-100 border-amber-600">Ir a Nómina</button>`;
    }
    const t = r.t;
    if (r.esCompra && t.entidad_id) {
        const sug = t.datos && t.datos.sugerido_pedir != null ? t.datos.sugerido_pedir : '';
        return `<button type="button" data-prod="${t.entidad_id}" data-sug="${sug}" data-tarea="${t.id}" class="tarea-ir-oc ${prim} bg-emerald-700 hover:bg-emerald-600 text-emerald-100 border-emerald-600" title="Se marca atendida sola al guardar la requisición">📝 Generar requisición</button> ${menu}`;
    }
    if (t.accion_sugerida === 'revisar_lote') {
        return `<button type="button" class="tarea-ir-lote ${prim} bg-sky-800 hover:bg-sky-700 text-sky-100 border-sky-600">📦 Ver en inventario</button> ${menu}`;
    }
    return menu;
}

// ---------------------------------------------------------------------
// Eventos de la tabla
// ---------------------------------------------------------------------
function cablearTareas(cont) {
    cont.querySelectorAll('.tareas-chip').forEach((b) => b.addEventListener('click', () => {
        const campo = b.dataset.chip; const v = b.dataset.v;
        if (v === '') { Object.keys(pendFiltros).forEach((k) => { pendFiltros[k] = ''; }); }
        else pendFiltros[campo] = pendFiltros[campo] === v ? '' : v;
        renderTareasActivas();
    }));
    const buscador = cont.querySelector('#tareasBuscador');
    buscador?.addEventListener('input', () => {
        tareasFiltroTexto = buscador.value;
        const pos = buscador.selectionStart;
        renderTareasActivas();
        const nuevo = document.getElementById('tareasBuscador');
        if (nuevo) { nuevo.focus(); nuevo.setSelectionRange(pos, pos); }
    });
    wireOrdenTabla(cont, pendOrden, renderTareasActivas);
    wireFiltrosColumna(cont, (id, valor) => { pendFiltros[id] = valor; renderTareasActivas(); });
    cont.querySelector('#tareasLimpiarFiltros')?.addEventListener('click', () => {
        Object.keys(pendFiltros).forEach((k) => { pendFiltros[k] = ''; });
        tareasFiltroTexto = '';
        renderTareasActivas();
    });

    cont.querySelectorAll('.tarea-check').forEach((chk) => chk.addEventListener('change', () => {
        const id = Number(chk.dataset.tarea);
        if (chk.checked) tareasSeleccionadas.add(id); else tareasSeleccionadas.delete(id);
        renderTareasActivas();
    }));
    cont.querySelector('#tareasSelTodas')?.addEventListener('change', (e) => {
        const visibles = [...cont.querySelectorAll('.tarea-check')].map((c) => Number(c.dataset.tarea));
        visibles.forEach((id) => { if (e.target.checked) tareasSeleccionadas.add(id); else tareasSeleccionadas.delete(id); });
        renderTareasActivas();
    });
    cont.querySelector('#tareasGenerarConjunta')?.addEventListener('click', tareasGenerarRequisicionConjunta);
    cont.querySelector('#tareasLimpiarSeleccion')?.addEventListener('click', () => { tareasSeleccionadas.clear(); renderTareasActivas(); });
    cont.querySelector('#tareasMasNoAceptada')?.addEventListener('click', () => tareasMasivo('posponer'));
    cont.querySelector('#tareasMasCancelar')?.addEventListener('click', () => tareasMasivo('cancelar'));

    cont.querySelectorAll('.tarea-ir-oc').forEach((b) => b.addEventListener('click', () => {
        window.__reqPreProducto = {
            id: Number(b.dataset.prod),
            cantidad: b.dataset.sug ? parseFloat(b.dataset.sug) : null,
            tareaId: Number(b.dataset.tarea),
        };
        window.loadView('requisiciones-compra');
    }));
    cont.querySelectorAll('.tarea-ir-lote').forEach((b) => b.addEventListener('click', () => window.loadView('inventario')));
    cont.querySelectorAll('.tarea-ir-nomina').forEach((b) => b.addEventListener('click', () => window.loadView('nomina')));
    cont.querySelectorAll('.tarea-autorizar').forEach((b) => b.addEventListener('click', async () => {
        await nomAutorizar(Number(b.dataset.id), b);
        await cargarModuloTareas();
    }));
    cont.querySelectorAll('.tarea-menu').forEach((b) => b.addEventListener('click', (e) => { e.stopPropagation(); abrirMenuTarea(b); }));
}

// Menú ⋯ (un solo elemento flotante, posicionado junto al botón y corregido por el zoom de la app).
function cerrarMenuTarea() { document.getElementById('tareasMenuFlotante')?.remove(); }
if (typeof document !== 'undefined' && !window.__tareasMenuListener) {
    window.__tareasMenuListener = true;
    document.addEventListener('click', cerrarMenuTarea);
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') cerrarMenuTarea(); });
}
function abrirMenuTarea(btn) {
    cerrarMenuTarea();
    const fila = construirFilas().find((r) => r.clave === btn.dataset.clave);
    if (!fila) return;
    const op = [];
    if (fila.kind === 'nomina') {
        op.push(['Ir a Nómina', () => window.loadView('nomina')]);
        op.push(['Cancelar nómina', async () => { await nomCancelar(fila.id); await cargarModuloTareas(); }, true]);
    } else if (fila.kind === 'sistema') {
        if (!fila.esCompra) op.push(['✔ Atendida', () => resolverTareaId(fila.id, 'atender', null, 'Marcada como atendida')]);
        op.push(['✕ No aceptada', () => {
            const d = prompt('¿En cuántos días quieres que vuelva a aparecer si sigue aplicando?', '7');
            if (d === null) return;
            resolverTareaId(fila.id, 'posponer', Math.max(1, parseInt(d, 10) || 7), 'No aceptada por el usuario');
        }]);
        // Cancelar: ya se resolvió por otro medio y no aplica ni "Atendida" (exige el flujo real ligado) ni "No aceptada"
        // (esa vuelve a avisar en N días). Archiva la tarea; si la condición sigue viva el sincronizador la crea de nuevo.
        op.push(['🚫 Cancelar', () => {
            if (!confirm('¿Cancelar esta tarea porque ya se atendió por otro medio? Si la condición que la generó sigue aplicando, puede volver a aparecer.')) return;
            const motivo = prompt('Motivo (opcional):', '') || 'Cancelada: ya se atendió por otro medio.';
            resolverTareaId(fila.id, 'cancelar', null, motivo);
        }, true]);
    }
    const m = document.createElement('div');
    m.id = 'tareasMenuFlotante';
    m.className = 'bg-slate-800 border border-slate-600 rounded-lg p-1.5 shadow-2xl text-xs min-w-[10rem]';
    m.style.cssText = 'position:fixed;z-index:2147482000;';
    op.forEach(([txt, fn, peligro]) => {
        const b = document.createElement('button');
        b.type = 'button';
        b.className = `block w-full text-left px-3 py-1.5 rounded ${peligro ? 'text-rose-300' : 'text-slate-200'} hover:bg-slate-700`;
        b.textContent = txt;
        b.addEventListener('click', (e) => { e.stopPropagation(); cerrarMenuTarea(); fn(); });
        m.appendChild(b);
    });
    document.body.appendChild(m);
    const z = Number(getComputedStyle(document.body).zoom) || 1;
    const r = btn.getBoundingClientRect();
    m.style.top = ((r.bottom + 4) / z) + 'px';
    const ancho = m.getBoundingClientRect().width || 160;
    m.style.left = (Math.max(8, Math.min(r.right - ancho, window.innerWidth - ancho - 8)) / z) + 'px';
}

// ---------------------------------------------------------------------
// Resolver (una o varias)
// ---------------------------------------------------------------------
async function fetchTareasSistema() {
    const ahora = new Date().toISOString();
    const { data, error } = await supabaseClient
        .from('tareas')
        .select('*')
        .or(`estatus.eq.pendiente,and(estatus.eq.pospuesta,posponer_hasta.lte.${ahora})`)
        .order('prioridad', { ascending: true })
        .order('creada_en', { ascending: true });
    if (error) {
        if (TABLA_FALTA.test(error.message || '')) return [];   // aún no se corre el SQL
        throw error;
    }
    return data || [];
}

async function rpcResolver(id, accion, dias, nota) {
    const { error } = await supabaseClient.rpc('tarea_resolver', {
        p_id: Number(id), p_accion: accion, p_nota: nota || null, p_dias: dias ?? null,
    });
    return error;
}

async function resolverTareaId(id, accion, dias, nota) {
    const error = await rpcResolver(id, accion, dias, nota);
    if (error) { alert('No se pudo actualizar la tarea: ' + (error.message || error)); return; }
    await cargarModuloTareas();
}

// Acción masiva sobre las tareas persistentes marcadas: 'posponer' (No aceptada) o 'cancelar'. Un solo motivo/plazo para todas.
async function tareasMasivo(accion) {
    const ids = [...tareasSeleccionadas];
    if (!ids.length) return;
    let dias = null; let nota;
    if (accion === 'posponer') {
        const d = prompt(`¿En cuántos días quieres que vuelvan a aparecer las ${ids.length} tareas si siguen aplicando?`, '7');
        if (d === null) return;
        dias = Math.max(1, parseInt(d, 10) || 7);
        nota = 'No aceptada por el usuario';
    } else {
        if (!confirm(`¿Cancelar ${ids.length} tarea(s) porque ya se atendieron por otro medio? Si la condición sigue aplicando, pueden volver a aparecer.`)) return;
        nota = prompt('Motivo (opcional, se guarda en todas):', '') || 'Cancelada: ya se atendió por otro medio.';
    }
    const errores = (await Promise.all(ids.map((id) => rpcResolver(id, accion, dias, nota)))).filter(Boolean);
    if (errores.length) alert(`${errores.length} de ${ids.length} tarea(s) no se pudieron actualizar: ${errores[0].message || errores[0]}`);
    await cargarModuloTareas();
}

// Barra que aparece arriba de la tabla cuando hay 1+ tareas marcadas. Agrupa por proveedor del producto para
// ofrecer la requisición conjunta (una por proveedor) solo con las de "comprar"; Cancelar / No aceptada valen para todas.
function renderBarraSeleccion() {
    if (!tareasSeleccionadas.size) return '';
    const seleccion = tareasCacheSistema.filter((t) => tareasSeleccionadas.has(t.id));
    const compras = seleccion.filter((t) => t.accion_sugerida === 'crear_orden_compra' && t.entidad_id);
    const grupos = new Map();   // proveedorId (o 'sin') -> [tarea...]
    compras.forEach((t) => {
        const info = tareasProductosMapa.get(Number(t.entidad_id));
        const clave = info?.proveedorId ? String(info.proveedorId) : 'sin';
        if (!grupos.has(clave)) grupos.set(clave, []);
        grupos.get(clave).push(t);
    });
    const nombreDeGrupo = (clave, ts) => clave === 'sin' ? 'sin proveedor asignado' : (tareasProductosMapa.get(Number(ts[0].entidad_id))?.proveedorNombre || `proveedor #${clave}`);
    const resumenGrupos = [...grupos.entries()].map(([clave, ts]) => `${ts.length} de ${nombreDeGrupo(clave, ts)}`).join(' · ');
    const unSoloProveedor = grupos.size === 1 && ![...grupos.keys()].includes('sin');

    return `
      <div class="bg-sky-950/40 border border-sky-700 rounded-lg p-3 mb-2 flex items-center justify-between flex-wrap gap-2">
        <div class="text-xs text-sky-200">
          <b>${tareasSeleccionadas.size}</b> tarea(s) seleccionada(s)${compras.length ? ` — ${esc(resumenGrupos)}` : ''}
          ${compras.length && !unSoloProveedor ? '<p class="text-[11px] text-amber-300 mt-0.5">⚠ No todas comparten el mismo proveedor — al generar, se agrupan por su proveedor real y se abre una requisición por cada uno.</p>' : ''}
        </div>
        <div class="flex gap-2 shrink-0 flex-wrap">
          ${compras.length ? `<button type="button" id="tareasGenerarConjunta" class="text-xs bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded-lg">📝 Generar requisición${grupos.size > 1 ? ' por proveedor' : ''}</button>` : ''}
          <button type="button" id="tareasMasNoAceptada" class="text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-3 py-1.5 rounded-lg">✕ No aceptada</button>
          <button type="button" id="tareasMasCancelar" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 px-3 py-1.5 rounded-lg">🚫 Cancelar</button>
          <button type="button" id="tareasLimpiarSeleccion" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg">Quitar selección</button>
        </div>
      </div>`;
}

// Junta las tareas de compra seleccionadas por proveedor real del producto y manda a
// Requisiciones de compra una preselección por cada grupo (una requisición
// por proveedor, ya que una requisición es para un solo proveedor).
function tareasGenerarRequisicionConjunta() {
    const seleccion = tareasCacheSistema.filter((t) => tareasSeleccionadas.has(t.id) && t.entidad_id && t.accion_sugerida === 'crear_orden_compra');
    if (!seleccion.length) return;
    const grupos = new Map();
    seleccion.forEach((t) => {
        const info = tareasProductosMapa.get(Number(t.entidad_id));
        const clave = info?.proveedorId ? String(info.proveedorId) : 'sin';
        if (!grupos.has(clave)) grupos.set(clave, []);
        grupos.get(clave).push(t);
    });

    if (grupos.size > 1) {
        const detalle = [...grupos.entries()].map(([clave, ts]) => {
            const nombre = clave === 'sin' ? 'sin proveedor asignado' : (tareasProductosMapa.get(Number(ts[0].entidad_id))?.proveedorNombre || `proveedor #${clave}`);
            return `· ${nombre}: ${ts.map((t) => t.titulo.replace(/^Comprar:\s*/, '')).join(', ')}`;
        }).join('\n');
        if (!confirm(`Las tareas seleccionadas son de proveedores distintos — se va a abrir una requisición separada por cada grupo:\n\n${detalle}\n\n¿Continuar?`)) return;
    }

    // window.__reqPreGrupos: una requisición (una llamada a Requisiciones de
    // compra) por proveedor. Solo el primer grupo se abre de una vez; el
    // resto queda anotado para que el admin repita "Generar requisición" ya
    // dentro de esa pantalla (una requisición siempre es de un proveedor).
    const listaGrupos = [...grupos.values()].map((ts) => ts.map((t) => ({
        id: Number(t.entidad_id),
        cantidad: t.datos && t.datos.sugerido_pedir != null ? t.datos.sugerido_pedir : null,
        tareaId: t.id,
    })));
    window.__reqPreProductos = listaGrupos[0];
    window.__reqPreGruposRestantes = listaGrupos.slice(1);
    window.loadView('requisiciones-compra');
}

async function fetchNominasBorrador() {
    const { data, error } = await supabaseClient
        .from('nominas')
        .select('id, periodo_inicio, periodo_fin, fecha_pago, subtotal, cuotas_imss, isr_retenido, total, condicion')
        .eq('estatus', 'borrador')
        .order('periodo_fin', { ascending: true });
    if (error) throw error;
    return data || [];
}

// Si todavía no hay borrador pero ya es viernes de la semana pendiente,
// se ofrece como tarea también (mismo cálculo que el aviso global en
// js/nomina.js — se repite aquí porque es la señal que arma la tarea,
// no un dato que se pueda leer de la base).
async function fetchRecordatorioViernes() {
    const yaHayBorrador = (await fetchNominasBorrador()).length > 0;
    if (yaHayBorrador) return null;

    const sugerido = await siguientePeriodoSugerido();
    const viernes = new Date(sugerido.inicio + 'T00:00:00');
    viernes.setDate(viernes.getDate() + 4);
    const hoy = new Date(hoyISO() + 'T00:00:00');
    return hoy >= viernes ? sugerido : null;
}

// =====================================================================
// Historial — TODAS las tareas del sistema (no solo las pendientes),
// filtrable por estatus / tipo / rango de fechas / quién la resolvió.
// public.tareas nunca borra una fila: pendiente -> atendida / pospuesta
// -> archivada / cancelada quedan ahí; esto solo es la ventana para consultarlas.
// Requiere sql/2026-09-07_tareas_historial.sql (rpc tareas_historial).
// =====================================================================

const ESTATUS_LABEL = {
    pendiente: 'Pendiente', atendida: 'Atendida',
    pospuesta: 'Pospuesta', archivada: 'Archivada', cancelada: 'Cancelada',
};
const ESTATUS_BADGE = {
    pendiente: 'bg-amber-900/50 text-amber-300 border-amber-700',
    atendida: 'bg-emerald-900/50 text-emerald-300 border-emerald-700',
    pospuesta: 'bg-sky-900/50 text-sky-300 border-sky-700',
    archivada: 'bg-slate-800 text-slate-400 border-slate-700',
    cancelada: 'bg-rose-950/40 text-rose-300 border-rose-800',
};
const TIPO_LABEL = {
    inventario_bajo_minimo: 'Inventario bajo mínimo',
    caducidad_proxima: 'Caducidad próxima',
    caducidad_sin_fecha: 'Falta fecha de caducidad',
};

let histFilasCache = [];   // último resultado del servidor (ya filtrado por estatus/tipo/fechas)

function fmtFechaHora(iso) {
    if (!iso) return '—';
    return new Date(iso).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' });
}

async function cargarHistorialTareas() {
    const cont = document.getElementById('contenedorTareasHistorial');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Cargando historial...</p>`;

    try {
        histFilasCache = await fetchHistorialTareas({ desde: primerDiaMesISO(), hasta: hoyISO() });
    } catch (err) {
        if (TABLA_FALTA.test(err.message || '')) {
            cont.innerHTML = `<p class="text-slate-600 text-xs">El historial de tareas aún no está activado (falta correr sql/2026-09-07_tareas_historial.sql).</p>`;
            return;
        }
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar el historial: ${err.message || err}</p>`;
        return;
    }

    const tipos = [...new Set([...Object.keys(TIPO_LABEL), ...histFilasCache.map((r) => r.tipo)])];

    cont.innerHTML = `
        <h3 class="text-sm font-semibold text-slate-300 mb-3">Historial de tareas</h3>
        <input type="text" id="histBuscar" placeholder="🔍 Buscar por título..." class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 mb-2">
        <div class="flex flex-wrap items-end gap-2 mb-3 text-xs">
            <div>
                <label class="block text-slate-500 mb-1">Estatus</label>
                <select id="histEstatus" class="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-slate-200">
                    <option value="">Todas</option>
                    ${Object.entries(ESTATUS_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
                </select>
            </div>
            <div>
                <label class="block text-slate-500 mb-1">Tipo</label>
                <select id="histTipo" class="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-slate-200">
                    <option value="">Todos</option>
                    ${tipos.map((t) => `<option value="${esc(t)}">${esc(TIPO_LABEL[t] || t)}</option>`).join('')}
                </select>
            </div>
            <div>
                <label class="block text-slate-500 mb-1">Desde</label>
                <input type="date" id="histDesde" value="${primerDiaMesISO()}" class="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-slate-200">
            </div>
            <div>
                <label class="block text-slate-500 mb-1">Hasta</label>
                <input type="date" id="histHasta" value="${hoyISO()}" class="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-slate-200">
            </div>
            <div>
                <label class="block text-slate-500 mb-1">Procesada por</label>
                <select id="histQuien" class="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-slate-200"></select>
            </div>
            <button type="button" id="histFiltrar" class="bg-sky-800 hover:bg-sky-700 text-sky-100 px-3 py-1.5 rounded-lg border border-sky-600 cursor-pointer">Filtrar</button>
            <button type="button" id="histLimpiar" class="bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">Limpiar</button>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-xs">
                <thead>
                    <tr class="text-left text-slate-500 border-b border-slate-800" id="histCabecera">
                        ${thOrden(histTareasOrden, 'titulo', 'Título')}${thOrden(histTareasOrden, 'tipo', 'Tipo')}${thOrden(histTareasOrden, 'estatus', 'Estatus')}
                        ${thOrden(histTareasOrden, 'creada', 'Creada')}${thOrden(histTareasOrden, 'resuelta', 'Resuelta')}${thOrden(histTareasOrden, 'por', 'Por')}<th class="p-2">Nota</th>
                    </tr>
                </thead>
                <tbody id="histCuerpo"></tbody>
            </table>
        </div>`;

    renderTablaQuienYCuerpo();
    wireOrdenTabla(document.getElementById('histCabecera'), histTareasOrden, pintarCuerpoHistorial);
    document.getElementById('histBuscar').addEventListener('input', pintarCuerpoHistorial);

    document.getElementById('histFiltrar').addEventListener('click', async () => {
        const cuerpo = document.getElementById('histCuerpo');
        cuerpo.innerHTML = `<tr><td colspan="7" class="p-3 text-slate-500">Filtrando...</td></tr>`;
        try {
            histFilasCache = await fetchHistorialTareas({
                estatus: document.getElementById('histEstatus').value || null,
                tipo: document.getElementById('histTipo').value || null,
                desde: document.getElementById('histDesde').value || null,
                hasta: document.getElementById('histHasta').value || null,
            });
        } catch (err) {
            cuerpo.innerHTML = `<tr><td colspan="7" class="p-3 text-rose-400">${esc(err.message || String(err))}</td></tr>`;
            return;
        }
        renderTablaQuienYCuerpo();
    });

    document.getElementById('histLimpiar').addEventListener('click', () => cargarHistorialTareas());
}

function renderTablaQuienYCuerpo() {
    const selQuien = document.getElementById('histQuien');
    const previoQuien = selQuien.value;
    const quienes = [...new Set(histFilasCache.map((r) => r.resuelta_por_email || '__auto__'))];
    selQuien.innerHTML = `<option value="">Todos</option>` + quienes.map((q) =>
        q === '__auto__'
            ? `<option value="__auto__">— (sin resolver / automático)</option>`
            : `<option value="${esc(q)}">${esc(q)}</option>`
    ).join('');
    if (quienes.includes(previoQuien)) selQuien.value = previoQuien;
    selQuien.onchange = () => pintarCuerpoHistorial();

    pintarCuerpoHistorial();
}

function pintarCuerpoHistorial() {
    const quien = document.getElementById('histQuien').value;
    const texto = (document.getElementById('histBuscar')?.value || '').trim().toLowerCase();
    let filas = quien
        ? histFilasCache.filter((r) => (r.resuelta_por_email || '__auto__') === quien)
        : histFilasCache;
    if (texto) filas = filas.filter((r) => (r.titulo || '').toLowerCase().includes(texto));

    const cuerpo = document.getElementById('histCuerpo');
    if (filas.length === 0) {
        cuerpo.innerHTML = `<tr><td colspan="7" class="p-3 text-slate-500">Sin resultados.</td></tr>`;
        return;
    }

    aplicarOrden(histTareasOrden, filas, (t, campo) => {
        switch (campo) {
            case 'titulo': return (t.titulo || '').toLowerCase();
            case 'tipo': return (TIPO_LABEL[t.tipo] || t.tipo || '').toLowerCase();
            case 'estatus': return t.estatus || '';
            case 'creada': return t.creada_en || '';
            case 'resuelta': return t.resuelta_en || '';
            case 'por': return (t.resuelta_por_email || '').toLowerCase();
            default: return t.id;
        }
    });

    cuerpo.innerHTML = filas.map((t) => `
        <tr class="border-b border-slate-900">
            <td class="p-2 text-slate-200">${esc(t.titulo)}</td>
            <td class="p-2 text-slate-400">${esc(TIPO_LABEL[t.tipo] || t.tipo)}</td>
            <td class="p-2"><span class="text-[10px] border rounded px-1.5 py-0.5 ${ESTATUS_BADGE[t.estatus] || ''}">${ESTATUS_LABEL[t.estatus] || t.estatus}</span></td>
            <td class="p-2 text-slate-500 whitespace-nowrap">${fmtFechaHora(t.creada_en)}</td>
            <td class="p-2 text-slate-500 whitespace-nowrap">${fmtFechaHora(t.resuelta_en)}</td>
            <td class="p-2 text-slate-400">${esc(t.resuelta_por_email) || (t.estatus === 'archivada' ? 'Automático' : '—')}</td>
            <td class="p-2 text-slate-500">${esc(t.nota_resolucion || '')}</td>
        </tr>`).join('');
}

async function fetchHistorialTareas({ estatus, tipo, desde, hasta }) {
    const { data, error } = await supabaseClient.rpc('tareas_historial', {
        p_estatus: estatus || null,
        p_tipo: tipo || null,
        p_desde: desde ? `${desde}T00:00:00` : null,
        p_hasta: hasta ? `${hasta}T23:59:59` : null,
        p_limit: 300,
    });
    if (error) throw error;
    return data || [];
}
