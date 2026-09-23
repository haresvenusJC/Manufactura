import { supabaseClient } from './supabase.js';
import { siguienteFolio } from './folios.js';
import { cargarInventarioCompleto } from './inventario.js';
import { imprimirConPlantilla } from './impresion.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { convertirEnBuscador } from './buscador-select.js';
import { factorConversion } from './conversion-unidades.js';

const histProdOrden = crearOrdenTabla('fecha', 'desc');

// Formatea cantidades evitando colas de decimales largas (10.0000001 -> "10").
export function formatoCantidad(n) {
    return Number(Number(n || 0).toFixed(3)).toString();
}

/**
 * Lote sugerido para una nueva producción: LotDDD + CadMMAA.
 *  - DDD: día juliano de hoy (1-366, con ceros a la izquierda) — Date.UTC en ambos
 *    extremos para que no falle por el cambio de horario de verano.
 *  - CadMMAA: mes y año (2+2 dígitos) de la caducidad, calculada a 2 años de hoy.
 * Ej. hoy 21-sep-2026 (día juliano 264) -> "Lot264Cad0928" (caduca 09/2028).
 */
function generarLoteSugerido(fecha = new Date()) {
    const inicioAnio = Date.UTC(fecha.getFullYear(), 0, 1);
    const hoyUTC = Date.UTC(fecha.getFullYear(), fecha.getMonth(), fecha.getDate());
    const diaJuliano = Math.round((hoyUTC - inicioAnio) / 86400000) + 1;
    const caducidad = new Date(fecha.getFullYear() + 2, fecha.getMonth(), fecha.getDate());
    const mm = String(caducidad.getMonth() + 1).padStart(2, '0');
    const aa = String(caducidad.getFullYear()).slice(-2);
    return `Lot${String(diaJuliano).padStart(3, '0')}Cad${mm}${aa}`;
}

/**
 * Para un producto y una cantidad a producir, calcula cuánto se requiere de
 * cada insumo del BOM (con conversión ml/g -> unidad base) y cuánto hay
 * disponible realmente (suma de stock por lote, que es lo que evalúa el RPC FIFO).
 * Lo usan tanto el panel de existencias del formulario como la validación final.
 *
 * @returns {Promise<{ error: string|null, filas: Array<{
 *   componenteId:number, nombre:string, unidad:string,
 *   costoUnitarioCatalogo:number, requerido:number, disponible:number, suficiente:boolean
 * }>, loteInfo: {rendimientoLote:number, unidad:string, factorLote:number}|null }>}
 */
export async function calcularRequerimientosProduccion(productoId, cantidadProducida) {
    const pid = Number(productoId);
    const cantidad = Number(cantidadProducida) || 0;

    if (!pid || cantidad <= 0) {
        return { error: 'Selecciona un producto y una cantidad válida.', filas: [] };
    }

    const { data: componentes, error: errComp } = await supabaseClient
        .from('bom')
        .select('componente_id, cantidad_requerida, unidad_medida')
        .eq('producto_id', pid);

    if (errComp) return { error: errComp.message, filas: [] };
    if (!componentes || componentes.length === 0) {
        return { error: 'El producto seleccionado no tiene una fórmula o BOM registrada.', filas: [] };
    }

    // Algunos semiterminados (los "Granel ... 15 Litros") tienen el BOM escrito para un LOTE
    // completo, no para 1 unidad — sql/2026-09-22_rendimiento_lote_bom.sql. Si el producto tiene
    // rendimiento_lote_bom > 0, la cantidad pedida se traduce a "cuántos lotes de la fórmula"
    // representa antes de escalar cada insumo; si no lo tiene, se comporta igual que siempre
    // (1 unidad producida = 1 vez la fórmula).
    let rendimientoLote = null;
    let unidadLoteNombre = '';
    {
        let { data: prodRaiz, error: errRaiz } = await supabaseClient
            .from('productos')
            .select('rendimiento_lote_bom, unidades_medida ( nombre )')
            .eq('id', pid)
            .single();
        if (errRaiz) {
            ({ data: prodRaiz, error: errRaiz } = await supabaseClient
                .from('productos')
                .select('unidades_medida ( nombre )')
                .eq('id', pid)
                .single());
        }
        if (!errRaiz && prodRaiz) {
            rendimientoLote = Number(prodRaiz.rendimiento_lote_bom) > 0 ? Number(prodRaiz.rendimiento_lote_bom) : null;
            unidadLoteNombre = prodRaiz.unidades_medida?.nombre || '';
        }
    }
    const factorLote = rendimientoLote ? (cantidad / rendimientoLote) : cantidad;

    const idsComponentes = componentes.map(c => c.componente_id);

    // Con densidad_kg_l (migración 2026-10-23); si aún no está, sin ella (sin densidad, la
    // conversión entre volumen y masa se toma como agua, 1 kg/L).
    let { data: infoInsumos, error: errInsumos } = await supabaseClient
        .from('productos')
        .select('id, nombre, costo_unitario, unidad_medida_id, densidad_kg_l, unidades_medida ( nombre )')
        .in('id', idsComponentes);
    if (errInsumos) {
        ({ data: infoInsumos, error: errInsumos } = await supabaseClient
            .from('productos')
            .select('id, nombre, costo_unitario, unidad_medida_id, unidades_medida ( nombre )')
            .in('id', idsComponentes));
    }
    if (errInsumos) return { error: errInsumos.message, filas: [] };
    const mapaInsumos = new Map((infoInsumos || []).map(i => [i.id, i]));

    // Nombres de las unidades: en `bom.unidad_medida` se guarda el id de la unidad como texto.
    const { data: unidadesCat } = await supabaseClient.from('unidades_medida').select('id, nombre');
    const nombreUnidadPorId = new Map((unidadesCat || []).map(u => [String(u.id), u.nombre]));

    const { data: lotes, error: errLotes } = await supabaseClient
        .from('lotes_inventario')
        .select('producto_id, stock_actual')
        .in('producto_id', idsComponentes);

    if (errLotes) return { error: errLotes.message, filas: [] };

    const stockPorComponente = new Map();
    (lotes || []).forEach(l => {
        const k = Number(l.producto_id);
        stockPorComponente.set(k, (stockPorComponente.get(k) || 0) + Number(l.stock_actual || 0));
    });

    // Se agregan los requerimientos por componente (un insumo puede repetirse en el BOM).
    const acumulado = new Map();
    componentes.forEach(comp => {
        const componenteId = Number(comp.componente_id);
        const datosIns = mapaInsumos.get(componenteId) || {};

        const cantidadReqUnit = Number(comp.cantidad_requerida || 0);
        const cantidadRecetaBase = cantidadReqUnit * factorLote;    // en la unidad del renglón del BOM, antes de convertir
        let requerido = cantidadRecetaBase;

        const unidadStockNombre = datosIns.unidades_medida?.nombre || '';
        const raw = String(comp.unidad_medida ?? '').trim();
        const conv = factorConversion(comp.unidad_medida, datosIns.unidad_medida_id, nombreUnidadPorId, unidadStockNombre, cantidadReqUnit, datosIns.densidad_kg_l);
        requerido *= conv.factor;

        // ¿La fórmula pide este insumo en OTRA unidad que la del inventario? Para avisar "Fórmula: X → se descuentan Y".
        const distinta = raw && String(datosIns.unidad_medida_id ?? '') !== raw;
        const nombreUnidadReceta = distinta ? (/^\d+$/.test(raw) ? (nombreUnidadPorId.get(raw) || '') : raw) : '';

        const prev = acumulado.get(componenteId);
        if (prev) {
            prev.requerido += requerido;
            if (!prev.nota && conv.nota) { prev.nota = conv.nota; prev.notaTipo = conv.tipo; }
            if (distinta && prev.recetaUnidadConsistente) {
                if (!prev.recetaUnidad) prev.recetaUnidad = nombreUnidadReceta;
                if (prev.recetaUnidad === nombreUnidadReceta) prev.recetaCantidad = (prev.recetaCantidad || 0) + cantidadRecetaBase;
                else prev.recetaUnidadConsistente = false;   // dos renglones del mismo insumo en unidades distintas: no se puede sumar limpio
            }
        } else {
            acumulado.set(componenteId, {
                componenteId,
                nombre: datosIns.nombre || `Insumo ID ${componenteId}`,
                unidad: unidadStockNombre,
                costoUnitarioCatalogo: Number(datosIns.costo_unitario || 0),
                requerido,
                nota: conv.nota || '',
                notaTipo: conv.tipo || 'ok',
                recetaCantidad: distinta ? cantidadRecetaBase : undefined,
                recetaUnidad: distinta ? nombreUnidadReceta : undefined,
                recetaUnidadConsistente: true,
            });
        }
    });

    const filas = Array.from(acumulado.values()).map(f => {
        const disponible = stockPorComponente.get(f.componenteId) || 0;
        return { ...f, disponible, suficiente: disponible + 1e-6 >= f.requerido };
    });

    const loteInfo = rendimientoLote ? { rendimientoLote, unidad: unidadLoteNombre, factorLote } : null;
    return { error: null, filas, loteInfo };
}

/**
 * Abre "Requisiciones de compra" con lo que falta para producir, ya cargado como partidas.
 *  - Una requisición es de UN proveedor: si lo faltante es de varios, se abre una por proveedor
 *    (la primera de una vez; las demás se cargan solas al guardar cada una).
 *  - Lo que se fabrica en casa (semiterminados como el granel) NO se compra: se deja fuera y se
 *    avisa, porque lo que hay que hacer es producirlo primero.
 * Reusa la preselección que ya usa Tareas (window.__reqPre*).
 *  - Con `orden` ({ id, folio }): la requisición queda ligada a esa orden de producción
 *    (requisiciones_compra.orden_produccion_id) y lo que YA está pedido para ella y aún no llega
 *    se descuenta, para no pedirlo dos veces (ver requisicionesDeOrden).
 */
export async function generarRequisicionFaltantes(faltan, nombreProducto, cantidadProducir, orden = null) {
    if (!faltan || !faltan.length) return;

    const ids = faltan.map((f) => f.componenteId);
    let { data: info, error } = await supabaseClient.from('productos')
        .select('id, nombre, tipo, proveedor_id, abastecimiento').in('id', ids);
    if (error) {   // aún sin la migración 2026-10-18
        ({ data: info, error } = await supabaseClient.from('productos').select('id, nombre, tipo, proveedor_id').in('id', ids));
    }
    if (error) { alert('No se pudo consultar los insumos: ' + error.message); return; }
    const porId = new Map((info || []).map((p) => [p.id, p]));

    const seFabrican = [];
    const comprables = [];
    for (const f of faltan) {
        const p = porId.get(f.componenteId) || {};
        const cantidad = Number((f.requerido - f.disponible).toFixed(3));
        if (!(cantidad > 0)) continue;
        const item = { id: f.componenteId, nombre: f.nombre, unidad: f.unidad, cantidad, proveedorId: p.proveedor_id || null };
        // un producto fabricado en casa (granel, terminado) se produce, no se compra
        if ((p.tipo === 'producto' || p.tipo === 'semiterminado') && p.abastecimiento !== 'comprado') seFabrican.push(item); else comprables.push(item);
    }

    // Lo ya pedido para esta orden (requisiciones pendientes/autorizadas que aún no llegan) se descuenta.
    const reqsLigadas = orden && orden.id ? ((await requisicionesDeOrden(orden.id)) || []) : [];
    const reqsEnCamino = reqsLigadas.filter((r) => r.enCamino);
    if (reqsEnCamino.length) {
        const pedido = new Map();
        reqsEnCamino.forEach((r) => r.detalle.forEach((d) => pedido.set(d.productoId, (pedido.get(d.productoId) || 0) + d.cantidad)));
        for (let k = comprables.length - 1; k >= 0; k--) {
            const ya = pedido.get(comprables[k].id) || 0;
            const resta = Number((comprables[k].cantidad - ya).toFixed(3));
            if (resta > 0) comprables[k].cantidad = resta; else comprables.splice(k, 1);
        }
    }

    const linea = (i) => `${i.nombre}: ${formatoCantidad(i.cantidad)}${i.unidad ? ' ' + i.unidad : ''}`;

    const grupos = new Map();
    for (const i of comprables) {
        const clave = i.proveedorId ? String(i.proveedorId) : 'sin';
        if (!grupos.has(clave)) grupos.set(clave, []);
        grupos.get(clave).push(i);
    }

    // Destinos: la requisición de compra (una por proveedor) y la orden de producción de cada semiterminado.
    // Si hay de los dos, el que no se eligió primero queda como "siguiente paso" (no se pierde):
    //  · requisición primero → window.__faltantesSiguiente lo ofrece al guardar la última requisición;
    //  · producción primero  → __prodPre.despues lo ofrece al generar la última orden sugerida.
    const listaGrupos = [...grupos.values()].map((items) => items.map((i) => ({ id: i.id, cantidad: i.cantidad })));
    const folioOrden = orden && orden.id ? (orden.folio || '#' + orden.id) : '';
    const notasReq = `Faltantes para producir ${formatoCantidad(cantidadProducir)} × ${nombreProducto}${folioOrden ? ` (orden ${folioOrden})` : ''}.`;
    const prodPre = () => ({
        lista: seFabrican.map((i) => ({ id: i.id, cantidad: i.cantidad, nombre: i.nombre, unidad: i.unidad })),
        total: seFabrican.length,
        origen: `Para producir ${formatoCantidad(cantidadProducir)} × ${nombreProducto}`,
        aplicada: false,
    });
    const abrirRequisicion = () => {
        window.__reqPreProductos = listaGrupos[0];
        window.__reqPreGruposRestantes = listaGrupos.slice(1);
        window.__reqPreNotas = notasReq;
        window.__reqPreOrden = orden && orden.id ? { id: orden.id, folio: orden.folio || null } : null;
        window.__faltantesSiguiente = seFabrican.length ? { prodPre: prodPre() } : null;
        window.loadView('requisiciones-compra');
    };
    const abrirOrdenesProduccion = () => {
        window.__prodPre = prodPre();
        if (comprables.length) window.__prodPre.despues = { grupos: listaGrupos, notas: notasReq };
        window.loadView('produccion');
    };

    // Un solo destino y un solo proveedor (y nada ya pedido que avisar): se va directo, sin preguntar.
    if (!comprables.length && !seFabrican.length && !reqsLigadas.length) return;
    if (!reqsLigadas.length && !seFabrican.length && grupos.size === 1) { abrirRequisicion(); return; }
    if (!reqsLigadas.length && !comprables.length && seFabrican.length) { abrirOrdenesProduccion(); return; }

    // Hay de las dos cosas (o varios proveedores): se muestra qué pasa con cada una y se elige por dónde empezar.
    const idsProv = [...grupos.keys()].filter((k) => k !== 'sin').map(Number);
    const { data: provs } = idsProv.length
        ? await supabaseClient.from('proveedores').select('id, nombre').in('id', idsProv)
        : { data: [] };
    const nombreProv = new Map((provs || []).map((p) => [p.id, p.nombre]));
    const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

    document.getElementById('modalFaltantesProd')?.remove();
    const modal = document.createElement('div');
    modal.id = 'modalFaltantesProd';
    // Fondo semitransparente sin difuminar: la pantalla que abrió la subventana sigue visible detrás.
    modal.className = 'fixed inset-0 z-[60] flex items-center justify-center bg-slate-950/40 p-4';
    modal.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-xl max-h-[85vh] overflow-y-auto p-5 text-sm text-slate-300 space-y-4">
            <div class="flex justify-between items-start gap-3">
                <div>
                    <h3 class="text-base font-bold text-slate-100">Faltantes para producir</h3>
                    <p class="text-xs text-slate-500 mt-0.5">${esc(formatoCantidad(cantidadProducir))} × ${esc(nombreProducto)}</p>
                </div>
                <button type="button" id="fpCerrar" class="text-slate-400 hover:text-slate-200 text-lg font-bold px-2 cursor-pointer">&times;</button>
            </div>
            ${reqsLigadas.length ? `
            <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
                <p class="text-xs font-semibold text-sky-400 mb-1.5">📦 Ya solicitado para la orden ${esc(folioOrden)}</p>
                <ul class="text-xs space-y-1">
                    ${reqsLigadas.map((r) => `<li><span class="text-slate-100 font-mono">${esc(r.folio)}</span>
                        <span class="text-slate-400">· ${esc(r.estadoTexto)}</span>
                        <span class="text-slate-500">— ${esc(r.detalle.map((d) => `${d.nombre}: ${formatoCantidad(d.cantidad)}${d.unidad ? ' ' + d.unidad : ''}`).join(', '))}</span></li>`).join('')}
                </ul>
                ${reqsEnCamino.length ? '<p class="text-[11px] text-slate-500 mt-1.5">Lo que ya está pedido y no ha llegado se descontó de lo que falta comprar.</p>' : ''}
                ${!comprables.length && !seFabrican.length ? '<p class="text-[11px] text-emerald-400 mt-1.5">✔ Todo lo que falta ya está solicitado: no hace falta otra requisición.</p>' : ''}
            </div>` : ''}
            ${comprables.length ? `
            <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
                <p class="text-xs font-semibold text-emerald-400 mb-1.5">🛒 Se compran${grupos.size > 1 ? ` — una requisición por proveedor (${grupos.size})` : ''}</p>
                <ul class="text-xs space-y-1 mb-3">
                    ${[...grupos.entries()].map(([clave, items]) => `
                    <li><span class="text-slate-100">${esc(clave === 'sin' ? 'Sin proveedor asignado' : (nombreProv.get(Number(clave)) || 'Proveedor #' + clave))}</span>
                        <span class="text-slate-500">— ${esc(items.map(linea).join(', '))}</span></li>`).join('')}
                </ul>
                <button type="button" id="fpReq" class="w-full bg-emerald-700 hover:bg-emerald-600 text-white text-xs font-medium py-2 rounded-lg cursor-pointer">📝 Generar requisición de compra</button>
            </div>` : ''}
            ${seFabrican.length ? `
            <div class="bg-slate-950 border border-slate-800 rounded-xl p-3">
                <p class="text-xs font-semibold text-amber-400 mb-1.5">🏭 Se fabrican en la planta — una orden de producción por producto (${seFabrican.length})</p>
                <ul class="text-xs space-y-1 mb-3">
                    ${seFabrican.map((i) => `<li class="text-slate-100">${esc(linea(i))}</li>`).join('')}
                </ul>
                <button type="button" id="fpProd" class="w-full bg-amber-700 hover:bg-amber-600 text-white text-xs font-medium py-2 rounded-lg cursor-pointer">🏭 Generar órdenes de producción</button>
            </div>` : ''}
            <p class="text-[11px] text-slate-500">${comprables.length && seFabrican.length ? 'Empieza por la que quieras: al terminarla te ofrezco continuar con la otra. ' : ''}Al abrir una orden de producción, el producto y la cantidad ya vienen cargados; solo completas el lote y los procesos.</p>
        </div>`;
    document.body.appendChild(modal);

    const cerrar = () => modal.remove();
    modal.addEventListener('click', (e) => { if (e.target === modal) cerrar(); });
    modal.querySelector('#fpCerrar').addEventListener('click', cerrar);
    modal.querySelector('#fpReq')?.addEventListener('click', () => { cerrar(); abrirRequisicion(); });
    modal.querySelector('#fpProd')?.addEventListener('click', () => { cerrar(); abrirOrdenesProduccion(); });
}

/**
 * Requisiciones de compra ligadas a una orden de producción (requisiciones_compra.orden_produccion_id,
 * sql/2026-09-22_requisicion_orden_produccion.sql). Devuelve null si la migración aún no está.
 * `enCamino`: pendiente de autorizar, o autorizada cuya orden de compra no ha recibido nada
 * (borrador/abierta) — eso es lo que se descuenta para no volver a pedirlo.
 */
export async function requisicionesDeOrden(ordenId) {
    const { data, error } = await supabaseClient.from('requisiciones_compra')
        .select('id, folio, fecha, estatus, ordenes_compra ( folio, estatus ), requisiciones_compra_detalle ( producto_id, cantidad, productos ( nombre, unidades_medida ( nombre ) ) )')
        .eq('orden_produccion_id', ordenId)
        .order('id', { ascending: true });
    if (error) return null;
    const TXT_OC = { borrador: 'OC en borrador', abierta: 'OC abierta, sin recibir', recibida_parcial: 'recibida parcial', recibida: 'recibida', cancelada: 'OC cancelada' };
    return (data || []).map((r) => {
        const oc = r.ordenes_compra;
        const enCamino = r.estatus === 'pendiente'
            || (r.estatus === 'autorizada' && (!oc || oc.estatus === 'borrador' || oc.estatus === 'abierta'));
        const estadoTexto = r.estatus === 'autorizada'
            ? `autorizada${oc ? ` → ${oc.folio || 'OC'} (${TXT_OC[oc.estatus] || oc.estatus})` : ''}`
            : (r.estatus === 'pendiente' ? 'pendiente de autorizar' : r.estatus);
        return {
            id: r.id, folio: r.folio, fecha: r.fecha, estatus: r.estatus, enCamino, estadoTexto,
            detalle: (r.requisiciones_compra_detalle || []).map((d) => ({
                productoId: Number(d.producto_id), cantidad: Number(d.cantidad || 0),
                nombre: d.productos?.nombre || 'Producto', unidad: d.productos?.unidades_medida?.nombre || '',
            })),
        };
    });
}

/**
 * Documentos de una orden CERRADA: el de ENTRADA (producto terminado, folio PROD-…, con la póliza) y el
 * de SALIDA (materia prima consumida, folio PROD-…-MP, donde quedan los movimientos del kardex). La orden
 * no guarda el id del documento: se llega por el lote que creó el cierre (producto + número de lote); como
 * un mismo número de lote se puede repetir entre órdenes, se toma el lote creado más cerca de cerrada_at.
 * Órdenes cerradas antes de separar los dos documentos traen todo en el de entrada (salida = null).
 */
export async function documentosDeOrden(orden) {
    const { data: lotes } = await supabaseClient.from('lotes_inventario')
        .select('documento_id, created_at')
        .eq('producto_id', orden.producto_id).eq('numero_lote', orden.numero_lote)
        .not('documento_id', 'is', null);
    if (!lotes || !lotes.length) return { entrada: null, salida: null };
    const ref = orden.cerrada_at ? new Date(orden.cerrada_at).getTime() : Date.now();
    const lote = lotes.slice().sort((a, b) =>
        Math.abs(new Date(a.created_at).getTime() - ref) - Math.abs(new Date(b.created_at).getTime() - ref))[0];
    const { data: entrada } = await supabaseClient.from('documentos')
        .select('id, folio, poliza_id, fecha_emision').eq('id', lote.documento_id).maybeSingle();
    let salida = null;
    if (entrada?.folio) {
        const { data: sal } = await supabaseClient.from('documentos')
            .select('id, folio').eq('folio', `${entrada.folio}-MP`).limit(1).maybeSingle();
        salida = sal || null;
    }
    return { entrada: entrada || null, salida };
}

/** Consumos reales (kardex) de una orden cerrada: un renglón por lote descontado, con el costo PEPS aplicado. */
export async function consumosDeOrden(docs) {
    const ids = [docs.entrada?.id, docs.salida?.id].filter(Boolean);
    if (!ids.length) return [];
    const { data } = await supabaseClient.from('movimientos_inventario')
        .select('cantidad, costo_unitario, lote_id, lotes_inventario ( numero_lote ), productos ( id, nombre, unidades_medida ( nombre ) )')
        .in('documento_id', ids)
        .eq('tipo_movimiento', 'salida_produccion');
    return data || [];
}

// Cronómetros del panel "Órdenes en Proceso" (viven mientras la vista está montada).
let tickerEnProceso = null;
let refetchEnProceso = null;

function formatoHHMMSS(totalSegundos) {
    const s = Math.max(0, Math.floor(totalSegundos));
    const hh = String(Math.floor(s / 3600)).padStart(2, '0');
    const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
    const ss = String(s % 60).padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
}

// Línea de detalle para un insumo que no alcanza (reusada al generar y al cerrar).
export function fmtFaltante(f) {
    const u = f.unidad ? ` ${f.unidad}` : '';
    return `• ${f.nombre}: requerido ${formatoCantidad(f.requerido)}${u}, disponible ${formatoCantidad(f.disponible)}${u} (faltan ${formatoCantidad(f.requerido - f.disponible)}${u})`;
}

function segundosDeIntervalo(inicioISO, finISO) {
    const ini = new Date(inicioISO).getTime();
    const fin = finISO ? new Date(finISO).getTime() : Date.now();
    return Math.max(0, (fin - ini) / 1000);
}

export async function cargarModuloProduccion() {
    const contenedorProd = document.getElementById('contenedorProduccion');

    // Órdenes sugeridas que ya se cargaron en una visita anterior y quedaron sin terminar: se descartan.
    if (window.__prodPre && window.__prodPre.aplicada) window.__prodPre = null;

    // Al re-montar la vista, cortar los timers anteriores.
    clearInterval(tickerEnProceso); tickerEnProceso = null;
    clearInterval(refetchEnProceso); refetchEnProceso = null;

    try {
        if (!supabaseClient || !contenedorProd) return;

        contenedorProd.innerHTML = `
            <div class="space-y-6 max-w-4xl mx-auto">
                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <h3 class="text-lg font-semibold mb-1 text-amber-400 flex items-center gap-2">🧾 Generar Orden de Producción</h3>
                    <p class="text-xs text-slate-400 mb-4">Valida existencias y abre la orden en estado <b>"en proceso"</b>. Los tiempos de trabajo se registran desde la <b>Orden de Trabajo</b> en el celular; el inventario se descuenta (FIFO) al <b>cerrar</b> la orden.</p>
                    <div id="avisoPreseleccionProd" class="hidden mb-4 text-xs text-amber-200 bg-amber-950/30 border border-amber-800/60 rounded-lg px-3 py-2"></div>
                    <form id="formOrdenProduccion" class="space-y-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PRODUCTO A PRODUCIR</label>
                            <select id="productoProducirId" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                <option value="">Seleccione un producto...</option>
                            </select>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <!-- Solo para productos con "Rendimiento del lote" (graneles): se pide en tandas y
                                     CANTIDAD A PRODUCIR se llena sola (tandas × rendimiento), y al revés. -->
                                <div id="bloqueTandas" class="hidden mb-3">
                                    <label class="block text-xs font-medium text-amber-400 mb-1" title="Cuántas veces vas a preparar la fórmula del BOM. Una tanda rinde lo capturado en Catálogo → Más detalles → Rendimiento del lote.">TANDAS A PREPARAR <span class="text-slate-500 cursor-help">ⓘ</span></label>
                                    <input type="number" id="tandasProducir" min="0" step="any" class="w-full bg-slate-950 border border-amber-800/60 rounded-lg p-2 text-sm text-slate-100">
                                    <p id="notaTandas" class="text-[10px] text-slate-500 mt-0.5"></p>
                                </div>
                                <label class="block text-xs font-medium text-slate-400 mb-1" title="En la Unidad de Medida del producto (Catálogo). En un granel con Rendimiento del lote se llena sola al escribir las tandas.">CANTIDAD A PRODUCIR <span class="text-slate-500 cursor-help">ⓘ</span></label>
                                <input type="number" id="cantidadProducida" min="0.0001" step="any" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                                <p id="notaCantidadProd" class="text-[10px] text-slate-500 mt-0.5">En la unidad del producto (pieza, litro, kilo…).</p>
                            </div>
                            <div>
                                <div class="flex justify-between items-center mb-1">
                                    <label class="block text-xs font-medium text-slate-400">NÚMERO DE LOTE RESULTANTE</label>
                                    <button type="button" id="btnSugerirLote" title="Generar de nuevo a partir de hoy: LotDDD (día juliano) + CadMMAA (caducidad a 2 años)" class="text-[10px] text-amber-400 hover:text-amber-300 cursor-pointer">🎲 Sugerir</button>
                                </div>
                                <input type="text" id="numeroLoteResultante" placeholder="Ej: Lot264Cad0928" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                        </div>
                        <div id="panelExistenciasBOM" class="hidden bg-slate-950 border border-slate-800 rounded-lg p-3">
                            <div class="flex justify-between items-center mb-2">
                                <span class="text-xs font-medium text-slate-400">EXISTENCIAS PARA ESTA PRODUCCIÓN (según fórmula / BOM)</span>
                                <span id="resumenExistenciasBOM" class="text-[11px] font-mono"></span>
                            </div>
                            <!-- Orden sugerida de un granel cuya necesidad no es tanda redonda: se elige aquí mismo
                                 tanda completa (por defecto) o solo lo necesario. Ver aplicarPreseleccionProduccion. -->
                            <div id="preguntaTandaBOM" class="hidden mb-2 text-[11px] text-amber-200 bg-amber-950/30 border border-amber-800/60 rounded-lg px-2.5 py-2"></div>
                            <p id="notaLoteBOM" class="hidden text-[11px] text-sky-300/90 bg-sky-950/20 border border-sky-800/40 rounded-lg px-2.5 py-1.5 mb-2"></p>
                            <div id="tablaExistenciasBOM" class="space-y-1"></div>
                            <div id="accionesExistenciasBOM" class="hidden mt-3 pt-3 border-t border-slate-800 flex flex-wrap items-center justify-between gap-2">
                                <span class="text-[11px] text-slate-500">Abre una requisición de compra con lo que falta, agrupada por proveedor.</span>
                                <button type="button" id="btnReqFaltantes" class="text-xs bg-emerald-700 hover:bg-emerald-600 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">📝 Generar requisición de lo faltante</button>
                            </div>
                        </div>
                        <div>
                            <div class="flex justify-between items-center mb-2">
                                <label class="block text-xs font-medium text-slate-400">PROCESOS Y EQUIPO DE TRABAJO ASIGNADO</label>
                                <button type="button" id="btnAgregarProceso" class="text-xs bg-slate-800 hover:bg-slate-700 text-amber-400 px-2 py-1 rounded-lg border border-slate-700">+ Agregar Proceso</button>
                            </div>
                            <div id="listaProcesosOrden" class="space-y-3"></div>
                            <p id="avisoSinProcesos" class="text-slate-500 text-xs italic mt-1">Agrega al menos un proceso (ej. Pesaje, Mezclado, Envasado) y asígnale su equipo. Solo el equipo asignado podrá registrar tiempo en el celular.</p>
                        </div>
                        <button type="submit" class="w-full bg-amber-600 hover:bg-amber-500 text-white font-semibold py-2 px-4 rounded-lg transition-all text-sm shadow-lg">
                            ✅ Generar Orden (en proceso)
                        </button>
                    </form>
                </div>

                <div id="tarjetaPendientesInsumos" class="hidden bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex justify-between items-center mb-1">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">📋 Órdenes pendientes por insumos <span id="numPendientesInsumos" class="text-sm text-slate-400"></span></h3>
                        <button type="button" id="btnRefrescarPendientes" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700" title="Refrescar">↻</button>
                    </div>
                    <p class="text-[11px] text-slate-500 mb-3">Lo que faltaba es de la última revisión; "🔄 Revisar y continuar" vuelve a revisar existencias.</p>
                    <div id="contenedorPendientesInsumos" class="space-y-2"></div>
                </div>

                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">⏱️ Órdenes en Proceso</h3>
                        <button type="button" id="btnRefrescarEnProceso" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700" title="Refrescar">↻</button>
                    </div>
                    <div id="contenedorOrdenesEnProceso"><p class="text-slate-500 text-xs italic">Cargando...</p></div>
                </div>

                <div class="bg-slate-900 border border-slate-800 p-6 rounded-xl shadow-xl">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-4">
                        <h3 class="text-lg font-semibold text-amber-400 flex items-center gap-2">📊 Historial de Órdenes Cerradas</h3>
                        <div class="flex items-center gap-2 w-full md:w-auto">
                            <select id="selectOrdenId" class="w-full md:w-72 bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-amber-300 font-mono">
                                <option value="">Seleccione orden por ID...</option>
                            </select>
                            <button id="btnImprimirOrden" class="bg-slate-800 hover:bg-slate-700 text-amber-400 p-2 rounded-lg border border-slate-700 transition-all text-sm flex items-center gap-1" title="Ventana Imprimible" disabled>🖨️</button>
                            <button id="btnReporteCompletoOrden" class="bg-amber-700 hover:bg-amber-600 text-white px-2.5 py-2 rounded-lg transition-all text-xs whitespace-nowrap" title="Costeo completo: por materia prima, por persona y por proceso (imprimible)">📄 Reporte completo</button>
                        </div>
                    </div>
                    <div id="detalleResumenOrden" class="bg-slate-950 border border-slate-800/60 p-4 rounded-lg text-sm text-slate-300 mb-6">
                        <p class="text-slate-500 italic text-center">Seleccione una orden cerrada para ver su desglose ejecutivo.</p>
                    </div>
                    <div id="contenedorHistorialProduccion"></div>
                </div>
            </div>
        `;

        // Solo lo que se fabrica: un producto "comprado para reventa" (migración
        // 2026-10-18) no se produce. Si la columna aún no existe, va sin ese filtro.
        let { data: productos, error: errProd } = await supabaseClient
            .from('productos')
            .select('id, nombre, sku, tipo')
            .in('tipo', ['producto', 'semiterminado'])
            .or('abastecimiento.is.null,abastecimiento.eq.fabricado');
        if (errProd) {
            ({ data: productos, error: errProd } = await supabaseClient
                .from('productos')
                .select('id, nombre, sku, tipo')
                .in('tipo', ['producto', 'semiterminado']));
        }

        const selectProd = document.getElementById('productoProducirId');
        if (!errProd && productos) {
            selectProd.innerHTML = '<option value="">Seleccione un producto...</option>';
            // Alfabético (en español: acentos y ñ en su lugar), no en el orden en que vengan de la base.
            productos.slice()
                .sort((a, b) => String(a.nombre || '').localeCompare(String(b.nombre || ''), 'es', { numeric: true, sensitivity: 'base' }))
                .forEach(p => {
                    selectProd.innerHTML += `<option value="${p.id}">${p.nombre} (${p.sku || 'Sin SKU'})</option>`;
                });
        }
        // Buscador: escribes parte del nombre o del SKU y eliges (el select sigue siendo la fuente del valor).
        convertirEnBuscador(selectProd, { placeholder: 'Escribe para buscar por nombre o SKU…' });

        // --- Panel de existencias según BOM: se recalcula al cambiar producto o cantidad ---
        const inputCantidadProd = document.getElementById('cantidadProducida');
        const panelExistencias = document.getElementById('panelExistenciasBOM');
        const tablaExistencias = document.getElementById('tablaExistenciasBOM');
        const resumenExistencias = document.getElementById('resumenExistenciasBOM');
        const notaLoteBOM = document.getElementById('notaLoteBOM');
        let tokenPanelExistencias = 0;
        const contAccionesReq = document.getElementById('accionesExistenciasBOM');
        const btnReqFaltantes = document.getElementById('btnReqFaltantes');
        let faltantesActuales = [];      // insumos que no alcanzan para lo que está capturado

        btnReqFaltantes.addEventListener('click', () => {
            const etiqueta = selectProd.options[selectProd.selectedIndex]?.textContent.trim() || '';
            generarRequisicionFaltantes(faltantesActuales, etiqueta, parseFloat(inputCantidadProd.value));
        });

        async function actualizarPanelExistencias() {
            const idProd = selectProd.value;
            const cant = parseFloat(inputCantidadProd.value);
            const miToken = ++tokenPanelExistencias;
            faltantesActuales = [];
            contAccionesReq.classList.add('hidden');

            if (!idProd || !cant || cant <= 0) {
                panelExistencias.classList.add('hidden');
                return;
            }

            panelExistencias.classList.remove('hidden');
            tablaExistencias.innerHTML = '<p class="text-slate-500 text-xs italic">Calculando requerimientos...</p>';
            resumenExistencias.textContent = '';

            const { error, filas, loteInfo } = await calcularRequerimientosProduccion(idProd, cant);
            if (miToken !== tokenPanelExistencias) return; // llegó una respuesta obsoleta

            if (error) {
                tablaExistencias.innerHTML = `<p class="text-amber-400 text-xs">${error}</p>`;
                resumenExistencias.textContent = '';
                notaLoteBOM.classList.add('hidden');
                return;
            }

            if (loteInfo) {
                const u = loteInfo.unidad ? ` ${loteInfo.unidad}` : '';
                notaLoteBOM.textContent = `📐 Fórmula pensada para un lote de ${formatoCantidad(loteInfo.rendimientoLote)}${u} → esta orden equivale a ${formatoCantidad(loteInfo.factorLote)} lote(s).`;
                notaLoteBOM.classList.remove('hidden');
            } else {
                notaLoteBOM.classList.add('hidden');
            }

            const faltan = filas.filter(f => !f.suficiente);
            faltantesActuales = faltan;
            contAccionesReq.classList.toggle('hidden', !faltan.length);
            resumenExistencias.textContent = faltan.length ? `⛔ Faltan ${faltan.length} insumo(s)` : '✅ Existencias suficientes';
            resumenExistencias.className = `text-[11px] font-mono ${faltan.length ? 'text-rose-400' : 'text-emerald-400'}`;

            tablaExistencias.innerHTML = filas.map(f => {
                const u = f.unidad ? ` ${f.unidad}` : '';
                const color = f.suficiente ? 'text-emerald-400' : 'text-rose-400';
                const icono = f.suficiente ? '✅' : '⛔';
                const falta = f.suficiente ? '' : ` · faltan ${formatoCantidad(f.requerido - f.disponible)}${u}`;
                // "Fórmula: 13.7 Litros → se descuentan 17.262 Kilogramos" — solo cuando la fórmula pide
                // este insumo en una unidad distinta a la del inventario (conversión real, no solo redondeo).
                let notaHtml = '';
                if (f.recetaUnidadConsistente && f.recetaCantidad != null && f.recetaUnidad) {
                    const detalle = f.notaTipo === 'aviso'
                        ? 'sin densidad capturada — se toma como agua (1 kg/L), agrégala en ⚖️ Densidades'
                        : (f.nota ? f.nota.replace(/^Convertido con /, '').replace(/\.$/, '') : 'conversión exacta de unidad');
                    const clase = f.notaTipo === 'aviso' ? 'text-amber-400/80' : 'text-emerald-400/70';
                    notaHtml = `<span class="block text-[10px] ${clase} font-normal">Fórmula: ${formatoCantidad(f.recetaCantidad)} ${f.recetaUnidad} → se descuentan ${formatoCantidad(f.requerido)}${u} (${detalle})</span>`;
                }
                return `
                    <div class="flex justify-between items-center gap-2 text-xs border-b border-slate-900 last:border-0 py-1">
                        <span class="text-slate-200">${icono} ${f.nombre}${notaHtml}</span>
                        <span class="font-mono ${color}">req ${formatoCantidad(f.requerido)}${u} · disp ${formatoCantidad(f.disponible)}${u}${falta}</span>
                    </div>`;
            }).join('');
        }

        // --- Tandas: productos con "Rendimiento del lote" (graneles) se piden en tandas ---
        // CANTIDAD A PRODUCIR (lo que se guarda en la orden y entra al inventario) = tandas × rendimiento.
        const bloqueTandas = document.getElementById('bloqueTandas');
        const inputTandas = document.getElementById('tandasProducir');
        const notaTandas = document.getElementById('notaTandas');
        const notaCantidadProd = document.getElementById('notaCantidadProd');
        const NOTA_CANTIDAD_BASE = notaCantidadProd.textContent;
        const rendimientoPorProducto = new Map();   // id -> { rend, unidad }
        {
            const r = await supabaseClient.from('productos')
                .select('id, rendimiento_lote_bom, unidades_medida ( nombre )')
                .gt('rendimiento_lote_bom', 0);
            if (!r.error) (r.data || []).forEach((p) => rendimientoPorProducto.set(String(p.id), {
                rend: Number(p.rendimiento_lote_bom), unidad: p.unidades_medida?.nombre || '',
            }));
        }
        const redondear = (n) => Math.round(n * 10000) / 10000;
        function aplicarModoTandas() {
            const info = rendimientoPorProducto.get(String(selectProd.value));
            bloqueTandas.classList.toggle('hidden', !info);
            if (!info) { inputTandas.value = ''; notaCantidadProd.textContent = NOTA_CANTIDAD_BASE; return; }
            const u = info.unidad ? ` ${info.unidad}` : '';
            notaTandas.textContent = `1 tanda = ${formatoCantidad(info.rend)}${u} (Rendimiento del lote). Puedes poner 0.5 para media tanda.`;
            notaCantidadProd.textContent = `Se llena sola: tandas × ${formatoCantidad(info.rend)}${u}. Es lo que entra al inventario al cerrar.`;
            inputTandas.value = '1';
            inputCantidadProd.value = String(info.rend);
        }
        inputTandas.addEventListener('input', () => {
            const info = rendimientoPorProducto.get(String(selectProd.value));
            const t = parseFloat(inputTandas.value);
            if (!info || !(t > 0)) return;
            inputCantidadProd.value = String(redondear(t * info.rend));
            actualizarPanelExistencias();
        });
        inputCantidadProd.addEventListener('input', () => {
            const info = rendimientoPorProducto.get(String(selectProd.value));
            const c = parseFloat(inputCantidadProd.value);
            if (info && c > 0) inputTandas.value = String(redondear(c / info.rend));
        });
        document.getElementById('formOrdenProduccion').addEventListener('reset', () => {
            bloqueTandas.classList.add('hidden');
            notaCantidadProd.textContent = NOTA_CANTIDAD_BASE;
        });

        selectProd.addEventListener('change', aplicarModoTandas);   // antes del panel: deja la cantidad lista
        selectProd.addEventListener('change', actualizarPanelExistencias);
        inputCantidadProd.addEventListener('input', actualizarPanelExistencias);

        // --- Catálogos para las tarjetas de proceso ---
        const { data: empleadosCatalogo } = await supabaseClient
            .from('empleados')
            .select('id, nombre, costo_hora')
            .eq('activo', true)
            .order('nombre', { ascending: true });

        let procesosCatalogo = null;
        {
            const r = await supabaseClient
                .from('procesos_produccion')
                .select('nombre, centro_costo_id')
                .order('nombre', { ascending: true });
            if (r.error) {
                const r2 = await supabaseClient
                    .from('procesos_produccion')
                    .select('nombre')
                    .order('nombre', { ascending: true });
                procesosCatalogo = r2.data;
            } else {
                procesosCatalogo = r.data;
            }
        }

        // Centros de costo de producción (para asignar cada proceso al suyo).
        let centrosCosto = [];
        {
            const r = await supabaseClient
                .from('v_centros_costo')
                .select('id, codigo, nombre, tipo, activo')
                .eq('tipo', 'produccion')
                .eq('activo', true)
                .order('codigo', { ascending: true });
            if (!r.error) centrosCosto = r.data || [];
        }

        const listaEmpleados = empleadosCatalogo || [];
        const listaProcesos = procesosCatalogo || [];
        const centroPorProceso = new Map(
            listaProcesos
                .filter(p => p.centro_costo_id != null)
                .map(p => [p.nombre, Number(p.centro_costo_id)])
        );
        let procesoContador = 0;

        function crearTarjetaProceso() {
            if (!listaEmpleados.length) {
                alert('⚠️ No hay empleados activos en el catálogo. Ve a "Empleados" y registra al menos uno antes de agregar un proceso.');
                return;
            }
            procesoContador++;
            const uid = `proc-${procesoContador}`;

            const opcionesProcesos = listaProcesos.map(p => `<option value="${p.nombre}">${p.nombre}</option>`).join('');
            const opcionesCentros = centrosCosto.map(c => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');
            const casillasEmpleados = listaEmpleados.map(e => `
                <label class="flex items-center gap-2 text-xs text-slate-200 px-1.5 py-1 rounded hover:bg-slate-800 cursor-pointer">
                    <input type="checkbox" class="chkEmpleado accent-amber-500 w-3.5 h-3.5" value="${e.id}" data-costo-hora="${e.costo_hora}" data-nombre="${(e.nombre || '').replace(/"/g, '&quot;')}">
                    <span>${e.nombre} <span class="text-slate-500">($${Number(e.costo_hora).toFixed(2)}/hr)</span></span>
                </label>`).join('');

            const div = document.createElement('div');
            div.className = 'proceso-item bg-slate-950 border border-slate-800 rounded-lg p-3 space-y-2';
            div.dataset.uid = uid;
            div.innerHTML = `
                <div class="flex gap-2 items-center">
                    <select class="selectProcesoNombre flex-1 bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
                        ${opcionesProcesos}
                        <option value="__otro__">+ Otro proceso...</option>
                    </select>
                    <input type="text" class="inputProcesoNuevoNombre hidden flex-1 bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100" placeholder="Nombre del proceso nuevo">
                    <button type="button" class="btnQuitarProceso text-rose-400 hover:text-rose-300 text-xs px-1" title="Quitar proceso">✕</button>
                </div>
                <div class="${opcionesCentros ? '' : 'hidden'}">
                    <label class="text-[10px] text-slate-500 block mb-1">CENTRO DE COSTO (dónde se acumula la mano de obra y el CIF de este proceso)</label>
                    <select class="selectProcesoCentro w-full bg-slate-900 border border-slate-800 rounded-lg p-1.5 text-xs text-slate-100">
                        <option value="">— sin asignar (usa el de producción por defecto) —</option>
                        ${opcionesCentros}
                    </select>
                </div>
                <div>
                    <label class="text-[10px] text-slate-500 block mb-1">EQUIPO DE TRABAJO (marca a quienes participan)</label>
                    <div class="equipoEmpleados max-h-28 overflow-y-auto bg-slate-900 border border-slate-800 rounded-lg p-1 space-y-0.5">
                        ${casillasEmpleados}
                    </div>
                    <p class="text-[10px] text-slate-500 mt-1"><span class="equipoCount text-amber-400 font-semibold">0</span> empleado(s) asignado(s)</p>
                </div>
            `;

            const selectProcesoNombre = div.querySelector('.selectProcesoNombre');
            const inputNuevoNombre = div.querySelector('.inputProcesoNuevoNombre');
            const selectProcesoCentro = div.querySelector('.selectProcesoCentro');
            selectProcesoNombre.onchange = () => {
                inputNuevoNombre.classList.toggle('hidden', selectProcesoNombre.value !== '__otro__');
                if (selectProcesoCentro && selectProcesoNombre.value !== '__otro__' && centroPorProceso.has(selectProcesoNombre.value)) {
                    selectProcesoCentro.value = String(centroPorProceso.get(selectProcesoNombre.value));
                }
            };
            selectProcesoNombre.onchange();

            const contadorEquipo = div.querySelector('.equipoCount');
            div.querySelectorAll('.chkEmpleado').forEach(chk => {
                chk.addEventListener('change', () => {
                    contadorEquipo.textContent = div.querySelectorAll('.chkEmpleado:checked').length;
                });
            });

            div.querySelector('.btnQuitarProceso').onclick = () => {
                div.remove();
                if (!document.querySelectorAll('.proceso-item').length) {
                    document.getElementById('avisoSinProcesos').classList.remove('hidden');
                }
            };

            document.getElementById('listaProcesosOrden').appendChild(div);
            document.getElementById('avisoSinProcesos').classList.add('hidden');
        }

        document.getElementById('btnAgregarProceso').onclick = crearTarjetaProceso;

        function recolectarProcesosDefinidos() {
            const procesos = [];
            document.querySelectorAll('#listaProcesosOrden .proceso-item').forEach(div => {
                let nombre = div.querySelector('.selectProcesoNombre').value;
                if (nombre === '__otro__') {
                    nombre = div.querySelector('.inputProcesoNuevoNombre').value.trim() || 'Proceso sin nombre';
                }
                const empleados = Array.from(div.querySelectorAll('.chkEmpleado:checked')).map(chk => ({
                    id: Number(chk.value),
                    costoHora: Number(chk.dataset.costoHora || 0)
                }));
                const centroSel = div.querySelector('.selectProcesoCentro');
                const centroCostoId = centroSel && centroSel.value ? Number(centroSel.value) : null;
                procesos.push({ nombre, empleados, centroCostoId });
            });
            return procesos;
        }

        const formOrden = document.getElementById('formOrdenProduccion');
        if (formOrden) {
            formOrden.onsubmit = async (e) => {
                e.preventDefault();
                const datos = {
                    productoId: document.getElementById('productoProducirId').value,
                    cantidadProducida: parseFloat(document.getElementById('cantidadProducida').value),
                    numeroLote: document.getElementById('numeroLoteResultante').value.trim(),
                    procesos: recolectarProcesosDefinidos()
                };

                const btnSubmit = formOrden.querySelector('button[type="submit"]');
                btnSubmit.disabled = true;
                btnSubmit.textContent = "Generando...";

                try {
                    const resultado = await generarOrdenDeProduccion(datos);
                    if (resultado.success && resultado.pendiente) {
                        const etiqueta = selectProd.options[selectProd.selectedIndex]?.textContent.trim() || '';
                        alert(`📋 Orden ${resultado.folio} guardada como PENDIENTE por insumos (procesos y equipo ya quedaron capturados):\n${resultado.faltantes.map(fmtFaltante).join('\n')}\n\nPodrás continuarla desde "Consulta de órdenes de producción" en cuanto haya existencias.`);
                        formOrden.reset();
                        document.getElementById('numeroLoteResultante').value = generarLoteSugerido();
                        document.getElementById('listaProcesosOrden').innerHTML = '';
                        document.getElementById('avisoSinProcesos').classList.remove('hidden');
                        panelExistencias.classList.add('hidden');
                        cargarOrdenesPendientesInsumos();
                        generarRequisicionFaltantes(faltantesActuales, etiqueta, datos.cantidadProducida, { id: resultado.ordenId, folio: resultado.folio });
                    } else if (resultado.success) {
                        alert(`✅ Orden ${resultado.folio} generada y en proceso.\nLos operarios ya pueden registrar tiempos desde la Orden de Trabajo en el celular.`);
                        formOrden.reset();
                        document.getElementById('numeroLoteResultante').value = generarLoteSugerido();
                        document.getElementById('listaProcesosOrden').innerHTML = '';
                        document.getElementById('avisoSinProcesos').classList.remove('hidden');
                        panelExistencias.classList.add('hidden');
                        await cargarOrdenesEnProceso();
                        // Si venían más órdenes sugeridas (semiterminados faltantes), carga la siguiente.
                        if (window.__prodPre && window.__prodPre.lista && window.__prodPre.lista.length) {
                            window.__prodPre.lista.shift();
                            aplicarPreseleccionProduccion();
                        }
                    } else {
                        alert("❌ Error: " + resultado.error);
                    }
                } catch (ex) {
                    alert("❌ Error crítico: " + ex.message);
                } finally {
                    btnSubmit.disabled = false;
                    btnSubmit.textContent = "✅ Generar Orden (en proceso)";
                }
            };
        }

        // Órdenes sugeridas desde "Generar requisición de lo faltante": para cada semiterminado que
        // falta y se fabrica en casa, carga el producto y la cantidad (solo falta el lote y los procesos).
        function aplicarPreseleccionProduccion() {
            const aviso = document.getElementById('avisoPreseleccionProd');
            const pre = window.__prodPre;
            if (!pre || !pre.lista || !pre.lista.length) {
                window.__prodPre = null;
                if (!aviso) return;
                // Se eligió primero producción y también faltaban cosas por comprar: ofrecer la requisición.
                if (pre && pre.despues && pre.despues.grupos.length) {
                    const { grupos, notas } = pre.despues;
                    aviso.innerHTML = `✅ Órdenes sugeridas generadas. Falta la requisición de compra de lo que no se fabrica.
                        <button type="button" id="btnContinuarReqFaltantes" class="block mt-2 text-xs bg-emerald-700 hover:bg-emerald-600 text-white font-medium px-3 py-1.5 rounded-lg cursor-pointer">📝 Continuar con la requisición de compra (${grupos.length} proveedor${grupos.length > 1 ? 'es' : ''})</button>`;
                    aviso.classList.remove('hidden');
                    document.getElementById('btnContinuarReqFaltantes').addEventListener('click', () => {
                        window.__reqPreProductos = grupos[0];
                        window.__reqPreGruposRestantes = grupos.slice(1);
                        window.__reqPreNotas = notas;
                        window.__faltantesSiguiente = null;
                        window.loadView('requisiciones-compra');
                    });
                    aviso.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    return;
                }
                aviso.classList.add('hidden');
                return;
            }
            const item = pre.lista[0];
            pre.aplicada = true;
            if (![...selectProd.options].some((o) => o.value === String(item.id))) {
                alert(`"${item.nombre}" no aparece entre los productos a producir (¿tiene fórmula / BOM?). Se omite.`);
                pre.lista.shift();
                aplicarPreseleccionProduccion();
                return;
            }
            selectProd.value = String(item.id);
            selectProd.dispatchEvent(new Event('change', { bubbles: true }));
            const n = pre.total - pre.lista.length + 1;
            const u = item.unidad ? ' ' + item.unidad : '';
            const cargar = (cantidad, nota) => {
                inputCantidadProd.value = String(cantidad);
                inputCantidadProd.dispatchEvent(new Event('input', { bubbles: true }));
                aviso.textContent = `🏭 Orden sugerida ${n} de ${pre.total}: ${item.nombre} × ${formatoCantidad(cantidad)}${u}${nota ? ` (${nota})` : ''}. ${pre.origen}. Ajusta la cantidad si conviene, captura el lote, agrega los procesos y genera la orden.`;
                aviso.classList.remove('hidden');
            };
            // Granel con "Rendimiento del lote": si lo que falta no es una tanda redonda, se pregunta en el
            // recuadro de existencias si se fabrica la tanda completa (menos de 1 → 1; más → siguiente media
            // tanda: 1.5, 2, 2.5…; es lo que queda marcado) o solo lo necesario.
            const info = rendimientoPorProducto.get(String(item.id));
            const tandasExactas = info ? redondear(item.cantidad / info.rend) : 0;
            const tandasSugeridas = tandasExactas < 1 ? 1 : Math.ceil(tandasExactas * 2) / 2;
            if (!info || !(tandasExactas > 0) || tandasSugeridas <= tandasExactas) {
                cargar(item.cantidad, '');
            } else {
                mostrarPreguntaTanda(item, info, tandasExactas, tandasSugeridas, cargar);
            }
            document.getElementById('numeroLoteResultante')?.focus();
        }

        // Pregunta "tanda completa / solo lo necesario" dentro de EXISTENCIAS PARA ESTA PRODUCCIÓN (sin subventana).
        const preguntaTanda = document.getElementById('preguntaTandaBOM');
        const ocultarPreguntaTanda = () => { preguntaTanda.classList.add('hidden'); preguntaTanda.innerHTML = ''; delete preguntaTanda.dataset.producto; };
        selectProd.addEventListener('change', () => { if (preguntaTanda.dataset.producto !== String(selectProd.value)) ocultarPreguntaTanda(); });
        document.getElementById('formOrdenProduccion').addEventListener('reset', ocultarPreguntaTanda);
        function mostrarPreguntaTanda(item, info, tandasExactas, tandasSugeridas, cargar) {
            const u = info.unidad ? ' ' + info.unidad : (item.unidad ? ' ' + item.unidad : '');
            const cantSugerida = redondear(tandasSugeridas * info.rend);
            const sobra = redondear(cantSugerida - item.cantidad);
            const txtTandas = (t) => `${formatoCantidad(t)} tanda${t === 1 ? '' : 's'}`;
            const etiqueta = tandasExactas < 1 ? 'Lote mínimo' : 'Tanda completa';
            const pintar = (completa) => {
                const clase = (activo) => activo
                    ? 'bg-amber-700 border-amber-500 text-white'
                    : 'bg-slate-900 border-slate-700 text-slate-300 hover:bg-slate-800';
                preguntaTanda.innerHTML = `
                    <p class="mb-1.5">Se necesitan <b class="text-slate-100">${formatoCantidad(item.cantidad)}${u}</b> (${formatoCantidad(tandasExactas)} de tanda) · 1 tanda rinde <b class="text-slate-100">${formatoCantidad(info.rend)}${u}</b>. ¿Cuánto fabricas?</p>
                    <div class="flex flex-wrap gap-2">
                        <button type="button" data-tanda="completa" class="border rounded-lg px-2.5 py-1.5 text-left cursor-pointer ${clase(completa)}">
                            ${completa ? '● ' : '○ '}🧪 ${etiqueta}: ${txtTandas(tandasSugeridas)} = ${formatoCantidad(cantSugerida)}${u}
                            <span class="block text-[10px] opacity-80">Sobran ${formatoCantidad(sobra)}${u} que quedan en inventario.</span>
                        </button>
                        <button type="button" data-tanda="necesario" class="border rounded-lg px-2.5 py-1.5 text-left cursor-pointer ${clase(!completa)}">
                            ${completa ? '○ ' : '● '}🎯 Solo lo necesario: ${formatoCantidad(item.cantidad)}${u}
                            <span class="block text-[10px] opacity-80">La fórmula se escala a ${formatoCantidad(tandasExactas)} de tanda; no sobra nada.</span>
                        </button>
                    </div>`;
                preguntaTanda.querySelectorAll('[data-tanda]').forEach((b) => b.addEventListener('click', () => elegir(b.dataset.tanda === 'completa')));
            };
            const elegir = (completa) => {
                pintar(completa);
                if (completa) cargar(cantSugerida, `${txtTandas(tandasSugeridas)}; se necesitaban ${formatoCantidad(item.cantidad)}${u}`);
                else cargar(item.cantidad, `solo lo necesario, ${formatoCantidad(tandasExactas)} de tanda`);
            };
            preguntaTanda.dataset.producto = String(item.id);
            preguntaTanda.classList.remove('hidden');
            elegir(true);   // por defecto: tanda completa
        }
        // Lote sugerido al abrir el formulario ("🎲 Sugerir" lo vuelve a calcular a partir de hoy).
        document.getElementById('numeroLoteResultante').value = generarLoteSugerido();
        document.getElementById('btnSugerirLote').addEventListener('click', () => {
            document.getElementById('numeroLoteResultante').value = generarLoteSugerido();
        });
        aplicarPreseleccionProduccion();

        document.getElementById('btnRefrescarEnProceso').onclick = cargarOrdenesEnProceso;
        document.getElementById('btnRefrescarPendientes').onclick = cargarOrdenesPendientesInsumos;

        await cargarOrdenesPendientesInsumos();
        await cargarOrdenesEnProceso();
        await cargarHistorialProduccion();

        tickerEnProceso = setInterval(tickEnProceso, 1000);
        refetchEnProceso = setInterval(cargarOrdenesEnProceso, 20000);
    } catch (err) {
        console.error("Error al inicializar el módulo de producción:", err);
    }
}

/**
 * Etapa 1: crea la orden en estado 'en_proceso' con sus procesos y equipos
 * asignados. NO mueve inventario ni calcula costos: eso ocurre al cerrarla.
 */
export async function generarOrdenDeProduccion(datos) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");

        const productoId = Number(datos.productoId);
        const cantidadProducida = Number(datos.cantidadProducida) || 0;
        const numeroLote = String(datos.numeroLote || '').trim();
        const procesos = Array.isArray(datos.procesos) ? datos.procesos : [];

        if (!productoId || cantidadProducida <= 0 || !numeroLote) {
            throw new Error("Faltan datos obligatorios o la cantidad a producir es inválida.");
        }
        if (!procesos.length) {
            throw new Error("Agrega al menos un proceso con su equipo de trabajo.");
        }
        if (procesos.some(p => !p.empleados || !p.empleados.length)) {
            throw new Error("Cada proceso debe tener al menos un empleado asignado (si no, nadie podrá registrar tiempo en el celular).");
        }

        // Validación de existencias (mismo cálculo que el panel del formulario). Si falta algo, la
        // orden no se pierde: se guarda como 'borrador' (pendiente por insumos) con sus procesos y
        // equipo ya capturados, para poder continuarla después desde "Consulta de órdenes de
        // producción" sin volver a llenar el formulario.
        const { error: errReq, filas } = await calcularRequerimientosProduccion(productoId, cantidadProducida);
        if (errReq) throw new Error(errReq);
        const faltantes = filas.filter(f => !f.suficiente);
        const pendienteInsumos = faltantes.length > 0;
        const faltantesSnapshot = pendienteInsumos
            ? faltantes.map(f => ({ id: f.componenteId, nombre: f.nombre, unidad: f.unidad, requerido: f.requerido, disponible: f.disponible }))
            : null;

        const filaOrden = {
            producto_id: productoId,
            cantidad_producida: cantidadProducida,
            numero_lote: numeroLote,
            estado: pendienteInsumos ? 'borrador' : 'en_proceso',
            abierta_at: pendienteInsumos ? null : new Date().toISOString(),
            faltantes_insumos: faltantesSnapshot
        };
        let { data: ordenNueva, error: errOrden } = await supabaseClient
            .from('ordenes_produccion').insert([filaOrden]).select('id').single();
        if (errOrden && /faltantes_insumos|column .* does not exist/i.test(errOrden.message || '')) {
            // Aún sin la migración 2026-09-22: se guarda igual como borrador, solo sin el detalle de lo que faltó.
            const { faltantes_insumos, ...filaSinSnapshot } = filaOrden;
            ({ data: ordenNueva, error: errOrden } = await supabaseClient
                .from('ordenes_produccion').insert([filaSinSnapshot]).select('id').single());
        }
        if (errOrden) throw errOrden;
        const ordenId = ordenNueva.id;
        const folio = 'OP-' + String(ordenId).padStart(6, '0');
        await supabaseClient.from('ordenes_produccion').update({ folio }).eq('id', ordenId);

        for (const proc of procesos) {
            const centroCostoId = proc.centroCostoId ? Number(proc.centroCostoId) : null;
            const filaProceso = { orden_produccion_id: ordenId, proceso_nombre: proc.nombre };
            if (centroCostoId) filaProceso.centro_costo_id = centroCostoId;

            let procIns, errProc;
            ({ data: procIns, error: errProc } = await supabaseClient
                .from('orden_produccion_procesos')
                .insert([filaProceso])
                .select('id')
                .single());

            if (errProc && /centro_costo_id|column .* does not exist/i.test(errProc.message || '')) {
                ({ data: procIns, error: errProc } = await supabaseClient
                    .from('orden_produccion_procesos')
                    .insert([{ orden_produccion_id: ordenId, proceso_nombre: proc.nombre }])
                    .select('id')
                    .single());
            }

            if (errProc) throw new Error(`No se pudo crear el proceso "${proc.nombre}": ${errProc.message}`);

            const filasEmp = proc.empleados.map(emp => ({
                orden_produccion_proceso_id: procIns.id,
                empleado_id: emp.id,
                costo_hora_snapshot: emp.costoHora
            }));
            const { error: errEmp } = await supabaseClient.from('orden_produccion_proceso_empleados').insert(filasEmp);
            if (errEmp) throw new Error(`No se pudo asignar el equipo del proceso "${proc.nombre}": ${errEmp.message}`);

            await supabaseClient.from('procesos_produccion').upsert([{ nombre: proc.nombre }], { onConflict: 'nombre', ignoreDuplicates: true });

            // El catálogo "aprende" el centro elegido para este proceso.
            if (centroCostoId) {
                try {
                    await supabaseClient.from('procesos_produccion')
                        .update({ centro_costo_id: centroCostoId })
                        .eq('nombre', proc.nombre);
                } catch (_) { /* la columna aún no existe: se ignora */ }
            }
        }

        return { success: true, ordenId, folio, pendiente: pendienteInsumos, faltantes: pendienteInsumos ? faltantes : null };
    } catch (error) {
        console.error("Error al generar la orden:", error.message);
        return { success: false, error: error.message };
    }
}

/**
 * Etapa 3: cierra una orden 'en_proceso'. Cierra cronómetros abiertos, calcula
 * la mano de obra a partir de registros_tiempo, re-valida existencias, descuenta
 * insumos (FIFO), da entrada al producto terminado y marca la orden como cerrada.
 */
// cantidadReal: lo que salió de verdad (ej. 14.6 L de una tanda planeada de 15). Los insumos se
// descuentan por lo planeado; al inventario entra lo real y el costo unitario = costo total ÷ real.
// Sin cantidadReal (o inválida) se cierra con lo planeado, como antes.
export async function cerrarOrdenDeProduccion(ordenId, cantidadReal = null) {
    try {
        if (!supabaseClient) throw new Error("Cliente de Supabase no inicializado.");
        ordenId = Number(ordenId);

        const { data: orden, error: errO } = await supabaseClient
            .from('ordenes_produccion')
            .select('id, producto_id, cantidad_producida, numero_lote, estado')
            .eq('id', ordenId)
            .single();

        if (errO) throw errO;
        if (!orden) throw new Error("Orden no encontrada.");
        if (orden.estado !== 'en_proceso') throw new Error(`La orden ya está "${orden.estado}".`);

        const productoId = Number(orden.producto_id);
        const cantidadProducida = Number(orden.cantidad_producida) || 0;   // planeada: con ella se descuentan los insumos
        const numeroLote = String(orden.numero_lote || '').trim();
        if (cantidadProducida <= 0 || !numeroLote) throw new Error("La orden no tiene cantidad o lote válidos.");
        const cantidadObtenida = Number(cantidadReal) > 0 ? Number(cantidadReal) : cantidadProducida;   // entra al inventario

        const { data: procesos, error: errP } = await supabaseClient
            .from('orden_produccion_procesos')
            .select('id, proceso_nombre, orden_produccion_proceso_empleados ( empleado_id, costo_hora_snapshot )')
            .eq('orden_produccion_id', ordenId);

        if (errP) throw errP;
        const procIds = (procesos || []).map(p => p.id);

        // Cierra cualquier cronómetro que quedó abierto.
        if (procIds.length) {
            const { error: errCierre } = await supabaseClient.from('registros_tiempo')
                .update({ fin: new Date().toISOString() })
                .is('fin', null)
                .in('orden_produccion_proceso_id', procIds);
            if (errCierre) throw new Error(`No se pudieron cerrar los cronómetros abiertos: ${errCierre.message}`);
        }

        let registros = [];
        if (procIds.length) {
            const { data: regs, error: errR } = await supabaseClient.from('registros_tiempo')
                .select('orden_produccion_proceso_id, empleado_id, inicio, fin')
                .in('orden_produccion_proceso_id', procIds);
            if (errR) throw errR;
            registros = regs || [];
        }

        // Mano de obra por proceso = suma de (segundos del empleado / 3600) * costo_hora_snapshot.
        let costoTotalManoObra = 0;
        const empleadosSet = new Set();
        const actualizacionesProceso = [];
        for (const p of procesos) {
            const snap = new Map((p.orden_produccion_proceso_empleados || []).map(e => [Number(e.empleado_id), Number(e.costo_hora_snapshot || 0)]));
            let segProc = 0;
            let costoProc = 0;
            registros.filter(r => r.orden_produccion_proceso_id === p.id).forEach(r => {
                const seg = segundosDeIntervalo(r.inicio, r.fin);
                segProc += seg;
                empleadosSet.add(Number(r.empleado_id));
                costoProc += (seg / 3600) * (snap.get(Number(r.empleado_id)) || 0);
            });
            costoTotalManoObra += costoProc;
            actualizacionesProceso.push({ id: p.id, segundos: Math.round(segProc), costo: costoProc });
        }

        // Re-validación de existencias: si falta algo, no se escribe nada más.
        const { error: errReq, filas } = await calcularRequerimientosProduccion(productoId, cantidadProducida);
        if (errReq) throw new Error(errReq);
        const faltantes = filas.filter(f => !f.suficiente);
        if (faltantes.length > 0) {
            throw new Error(`Existencias insuficientes. La orden sigue en proceso:\n${faltantes.map(fmtFaltante).join('\n')}`);
        }

        // Dos documentos para que el movimiento se lea claro en Documentos/Kardex:
        // uno de SALIDA (la materia prima que se consume) y uno de ENTRADA (el
        // producto terminado que resulta). Contablemente siguen siendo una sola
        // transformación de inventario -una sola póliza-, así que al póliza que
        // genera contabilizar_produccion() se le liga también el documento de
        // salida (ver más abajo) en vez de duplicar el asiento.
        const folioBase = await siguienteFolio('PROD');   // consecutivo: PROD-000001, PROD-000002...
        const { data: docSalida, error: errDocSalida } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: 'salida_produccion',
                folio: `${folioBase}-MP`,
                fecha_emision: new Date().toISOString(),
                descripcion: `Consumo de materia prima — orden de producción, lote ${numeroLote}`,
                estado: 'completado'
            }])
            .select('id')
            .single();
        if (errDocSalida) throw errDocSalida;
        const documentoSalidaId = docSalida.id;

        const { data: docInsertado, error: errDoc } = await supabaseClient
            .from('documentos')
            .insert([{
                tipo_movimiento: 'entrada_produccion',
                folio: folioBase,
                fecha_emision: new Date().toISOString(),
                descripcion: `Cierre de orden de producción — lote ${numeroLote} (consumo de materia prima: documento ${folioBase}-MP)`,
                estado: 'completado'
            }])
            .select('id')
            .single();

        if (errDoc) throw errDoc;
        const documentoId = docInsertado.id;

        let costoTotalMateriales = 0;
        for (const f of filas) {
            const { data: lotesConsumidos, error: errFifo } = await supabaseClient.rpc('registrar_salida_fifo', {
                p_producto_id: f.componenteId,
                p_cantidad_salida: Number(f.requerido),
                p_tipo_movimiento: 'salida_produccion',
                p_documento_id: documentoSalidaId,
                p_costo_unitario_fijo: null
            });

            if (errFifo) throw new Error(`Error al descontar ${f.nombre} (FIFO): ${errFifo.message}`);

            if (Array.isArray(lotesConsumidos) && lotesConsumidos.length > 0) {
                lotesConsumidos.forEach(l => {
                    costoTotalMateriales += Number(l.cantidad || 0) * Number(l.costo_unitario ?? f.costoUnitarioCatalogo);
                });
            } else {
                costoTotalMateriales += (f.requerido * f.costoUnitarioCatalogo);
            }
        }

        const costoUnitarioFinal = cantidadObtenida > 0 ? (costoTotalMateriales + costoTotalManoObra) / cantidadObtenida : 0;

        const { error: errEnt } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
            p_producto_id: productoId,
            p_cantidad: cantidadObtenida,
            p_tipo_movimiento: 'entrada_produccion',
            p_documento_id: documentoId,
            p_costo_unitario: costoUnitarioFinal,
            p_numero_lote: numeroLote
        });

        if (errEnt) throw new Error(`Error al registrar entrada de producto terminado: ${errEnt.message}`);

        const { data: loteCreado } = await supabaseClient
            .from('lotes_inventario')
            .select('id')
            .eq('producto_id', productoId)
            .eq('numero_lote', numeroLote)
            .eq('documento_id', documentoId)
            .maybeSingle();

        await supabaseClient.from('documento_detalles').insert([{
            documento_id: documentoId,
            producto_id: productoId,
            lote_id: loteCreado?.id || null,
            cantidad: cantidadObtenida,
            costo_unitario: costoUnitarioFinal,
            subtotal: costoUnitarioFinal * cantidadObtenida
        }]);

        await supabaseClient.from('productos').update({ costo_unitario: costoUnitarioFinal }).eq('id', productoId);

        for (const a of actualizacionesProceso) {
            await supabaseClient.from('orden_produccion_procesos')
                .update({ segundos_transcurridos: a.segundos, costo_calculado: a.costo })
                .eq('id', a.id);
        }

        // cantidad_producida pasa a ser lo REAL (contabilizar_produccion y el prorrateo de CIF dividen el
        // costo entre ella) y lo planeado se guarda en cantidad_planeada
        // (sql/2026-09-23d_rendimiento_real_orden.sql; sin la migración se cierra igual, sin guardar lo planeado).
        const datosCierre = {
            estado: 'cerrada',
            cerrada_at: new Date().toISOString(),
            costo_unitario_final: costoUnitarioFinal,
            costo_total_materiales: costoTotalMateriales,
            costo_total_mano_obra: costoTotalManoObra,
            empleados_involucrados: empleadosSet.size,
            cantidad_producida: cantidadObtenida,
        };
        let { error: errUpd } = await supabaseClient.from('ordenes_produccion')
            .update({ ...datosCierre, cantidad_planeada: cantidadProducida }).eq('id', ordenId);
        if (errUpd && /cantidad_planeada/.test(errUpd.message || '')) {
            ({ error: errUpd } = await supabaseClient.from('ordenes_produccion').update(datosCierre).eq('id', ordenId));
        }

        if (errUpd) throw errUpd;

        // Contabilizar el cierre (Cargo 115.04 PT / Abono 115.01 MP + 601.01 mano de obra).
        // No bloquea el cierre si el modulo contable no esta instalado o falla.
        let msgContab = '';
        try {
            const { data: cc, error: errCC } = await supabaseClient.rpc('contabilizar_produccion', {
                p_documento_id: documentoId,
                p_datos: {
                    costo_materiales: costoTotalMateriales,
                    costo_mano_obra: costoTotalManoObra,
                    orden_produccion_id: ordenId,
                    documento_salida_id: documentoSalidaId
                }
            });
            if (errCC) throw errCC;
            msgContab = ` Póliza de producción #${cc.poliza_id} generada.`;
            // La póliza queda ligada al documento de entrada (como ya hacía
            // contabilizar_produccion); se replica el mismo poliza_id en el
            // documento de salida para que ambos lados del movimiento se vean
            // contabilizados en Documentos, sin generar un segundo asiento.
            if (cc?.poliza_id) {
                await supabaseClient.from('documentos').update({ poliza_id: cc.poliza_id }).eq('id', documentoSalidaId);
            }
        } catch (e) {
            const m = e?.message || String(e);
            if (!/does not exist|could not find|schema cache/i.test(m)) {
                msgContab = ` (Cierre OK, pero no se contabilizó: ${m})`;
            }
        }

        const msgRend = Math.abs(cantidadObtenida - cantidadProducida) > 1e-9
            ? ` Planeado ${formatoCantidad(cantidadProducida)}, obtenido ${formatoCantidad(cantidadObtenida)} (${cantidadObtenida < cantidadProducida ? 'merma' : 'excedente'} ${formatoCantidad(Math.abs(cantidadProducida - cantidadObtenida) / cantidadProducida * 100)}%).`
            : '';
        return { success: true, mensaje: `Orden cerrada. Costo unitario: $${costoUnitarioFinal.toFixed(2)}.${msgRend}${msgContab}` };
    } catch (error) {
        console.error("Error al cerrar la orden:", error.message);
        return { success: false, error: error.message };
    }
}

// --- Panel "Órdenes en Proceso" (admin: sí muestra costos) -------------------

// Resumen de las órdenes 'borrador' (pendientes por insumos, ver generarOrdenDeProduccion). Usa la foto
// de la última revisión (faltantes_insumos) para no recalcular existencias de cada una al abrir la
// pantalla; "👁 Ver estado" y "🔄 Revisar y continuar" (de js/ordenes-produccion.js) calculan en vivo.
async function cargarOrdenesPendientesInsumos() {
    const tarjeta = document.getElementById('tarjetaPendientesInsumos');
    const cont = document.getElementById('contenedorPendientesInsumos');
    if (!tarjeta || !cont) return;

    let { data: ordenes, error } = await supabaseClient.from('ordenes_produccion')
        .select('id, folio, numero_lote, cantidad_producida, created_at, faltantes_insumos, productos ( nombre, unidades_medida ( nombre ) )')
        .eq('estado', 'borrador').order('created_at', { ascending: true });
    if (error) {   // aún sin sql/2026-09-22_orden_produccion_pendiente_insumos.sql
        tarjeta.classList.add('hidden');
        return;
    }
    ordenes = ordenes || [];
    document.getElementById('numPendientesInsumos').textContent = ordenes.length ? `(${ordenes.length})` : '';
    if (!ordenes.length) { tarjeta.classList.add('hidden'); cont.innerHTML = ''; return; }
    tarjeta.classList.remove('hidden');

    const reqsPorOrden = await Promise.all(ordenes.map((o) => requisicionesDeOrden(o.id)));
    const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

    cont.innerHTML = ordenes.map((o, i) => {
        const falt = Array.isArray(o.faltantes_insumos) ? o.faltantes_insumos : [];
        const reqs = reqsPorOrden[i] || [];
        const reqsTxt = reqs.length
            ? reqs.map((r) => `📦 ${esc(r.folio)} ${esc(r.estadoTexto)}`).join(' · ')
            : (reqsPorOrden[i] === null ? '' : 'Sin requisición');
        return `
        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 flex flex-wrap justify-between gap-3">
            <div class="min-w-0 flex-1">
                <p class="text-sm text-slate-100"><span class="font-mono font-bold text-amber-400">${esc(o.folio || '#' + o.id)}</span> · ${esc(o.productos?.nombre || 'Producto')}</p>
                <p class="text-[11px] text-slate-400">${formatoCantidad(o.cantidad_producida)} ${esc(o.productos?.unidades_medida?.nombre || 'u')} · Lote ${esc(o.numero_lote || 'S/L')} · ${new Date(o.created_at).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' })}</p>
                <p class="text-[11px] mt-1 ${falt.length ? 'text-rose-400' : 'text-slate-500'}" title="${esc(falt.map((f) => f.nombre).join(', '))}">${falt.length ? `⛔ Faltan ${falt.length} insumo(s): ${esc(falt.map((f) => f.nombre).join(', '))}` : 'Sin detalle de faltantes guardado'}</p>
                ${reqsTxt ? `<p class="text-[11px] mt-0.5 text-sky-300/90">${reqsTxt}</p>` : ''}
            </div>
            <div class="flex flex-col gap-1.5 shrink-0">
                <button type="button" class="btn-pend-ver text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-1 rounded-lg border border-slate-700" data-id="${o.id}">👁 Ver estado</button>
                <button type="button" class="btn-pend-continuar text-xs bg-amber-700 hover:bg-amber-600 text-white px-2 py-1 rounded-lg" data-id="${o.id}">🔄 Revisar y continuar</button>
            </div>
        </div>`;
    }).join('');

    // Import dinámico: ordenes-produccion.js ya importa de este archivo (evita el ciclo al cargar).
    cont.querySelectorAll('.btn-pend-ver').forEach((b) => b.addEventListener('click', async () => {
        const m = await import('./ordenes-produccion.js');
        m.abrirDetalle(Number(b.dataset.id));
    }));
    cont.querySelectorAll('.btn-pend-continuar').forEach((b) => b.addEventListener('click', async () => {
        const m = await import('./ordenes-produccion.js');
        await m.continuarOrdenPendiente(Number(b.dataset.id), b, async () => {
            await cargarOrdenesPendientesInsumos();
            await cargarOrdenesEnProceso();
        });
    }));
}

async function cargarOrdenesEnProceso() {
    const cont = document.getElementById('contenedorOrdenesEnProceso');
    if (!cont) return;

    const { data: ordenes, error } = await supabaseClient
        .from('ordenes_produccion')
        .select(`
            id, folio, numero_lote, cantidad_producida, abierta_at,
            productos ( nombre, unidades_medida ( nombre ) ),
            orden_produccion_procesos (
                id, proceso_nombre,
                orden_produccion_proceso_empleados ( empleado_id, costo_hora_snapshot, finalizado_at, empleados ( nombre ) )
            )
        `)
        .eq('estado', 'en_proceso')
        .order('abierta_at', { ascending: true });

    if (error) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${error.message}</p>`;
        return;
    }
    if (!ordenes || !ordenes.length) {
        cont.innerHTML = `<p class="text-slate-500 text-xs italic">No hay órdenes en proceso.</p>`;
        return;
    }

    const procIds = ordenes.flatMap(o => (o.orden_produccion_procesos || []).map(p => p.id));
    let registros = [];
    let solicitudes = [];
    if (procIds.length) {
        const { data: regs } = await supabaseClient.from('registros_tiempo')
            .select('orden_produccion_proceso_id, empleado_id, inicio, fin')
            .in('orden_produccion_proceso_id', procIds);
        registros = regs || [];
        // Solicitudes de reasignación pendientes (degrada si el SQL no está)
        try {
            const { data: sols, error: errSol } = await supabaseClient.from('solicitudes_reasignacion')
                .select('id, proceso_id, empleado_id, motivo, creada_at, empleados ( nombre )')
                .eq('estatus', 'pendiente')
                .in('proceso_id', procIds);
            if (!errSol) solicitudes = sols || [];
        } catch (_) { solicitudes = []; }
    }

    cont.innerHTML = ordenes.map(o => renderTarjetaOrdenEnProceso(o, registros, solicitudes)).join('');

    cont.querySelectorAll('.btn-resolver-sol').forEach(btn => {
        btn.onclick = async () => {
            const aprobar = btn.dataset.accion === 'aprobar';
            if (!confirm(aprobar
                ? `¿Asignar a ${btn.dataset.nombre} al proceso "${btn.dataset.proc}"?`
                : `¿Rechazar la solicitud de ${btn.dataset.nombre}?`)) return;
            btn.disabled = true;
            const { error } = await supabaseClient.rpc('resolver_reasignacion', {
                p_solicitud_id: Number(btn.dataset.id),
                p_aprobar: aprobar
            });
            if (error) { alert('No se pudo resolver: ' + error.message); btn.disabled = false; return; }
            await cargarOrdenesEnProceso();
        };
    });

    cont.querySelectorAll('.btn-ajuste-tiempo').forEach(btn => {
        btn.onclick = async () => {
            const resp = prompt(`Minutos trabajados a AGREGAR para "${btn.dataset.nombre}" en "${btn.dataset.procNombre}":`);
            if (resp === null) return;
            const min = parseFloat(resp);
            if (!min || Number.isNaN(min) || min <= 0) { alert('Ingresa un número de minutos mayor que 0.'); return; }

            const fin = new Date();
            const inicio = new Date(fin.getTime() - min * 60000);

            const { error: errIns } = await supabaseClient.from('registros_tiempo').insert([{
                orden_produccion_proceso_id: Number(btn.dataset.proceso),
                empleado_id: Number(btn.dataset.empleado),
                inicio: inicio.toISOString(),
                fin: fin.toISOString(),
                fuente: 'admin'
            }]);
            if (errIns) { alert('No se pudo registrar el ajuste: ' + errIns.message); return; }
            await cargarOrdenesEnProceso();
        };
    });

    cont.querySelectorAll('.btn-cerrar-orden').forEach(btn => {
        btn.onclick = async () => {
            if (!confirm(`¿Cerrar la orden ${btn.dataset.folio}? Se descontará el inventario (FIFO) y se calcularán los costos. Esto no se puede deshacer.`)) return;
            btn.disabled = true;
            btn.textContent = 'Cerrando...';
            // Se cierra con lo planeado. cerrarOrdenDeProduccion acepta una cantidad real como 2º
            // parámetro (merma medida), pero por ahora no se pregunta.
            const res = await cerrarOrdenDeProduccion(Number(btn.dataset.id));
            if (res.success) {
                alert('✅ ' + res.mensaje);
                await cargarOrdenesEnProceso();
                await cargarHistorialProduccion();
                if (typeof cargarInventarioCompleto === 'function') await cargarInventarioCompleto();
            } else {
                alert('❌ ' + res.error);
                btn.disabled = false;
                btn.textContent = '🔒 Cerrar orden';
            }
        };
    });
}

function renderTarjetaOrdenEnProceso(o, registros, solicitudes = []) {
    const abierta = o.abierta_at ? new Date(o.abierta_at).toLocaleString() : '';
    const folio = o.folio || ('#' + o.id);

    const procesosHtml = (o.orden_produccion_procesos || []).map(p => {
        const regsP = registros.filter(r => r.orden_produccion_proceso_id === p.id);
        const equipo = p.orden_produccion_proceso_empleados || [];

        const filasEmp = equipo.map(e => {
            const empId = Number(e.empleado_id);
            const snap = Number(e.costo_hora_snapshot || 0);
            const nombreEmp = e.empleados?.nombre || 'Empleado';
            let acumCerrado = 0;
            let inicioAbierto = '';
            regsP.filter(r => Number(r.empleado_id) === empId).forEach(r => {
                if (r.fin) acumCerrado += segundosDeIntervalo(r.inicio, r.fin);
                else inicioAbierto = r.inicio;
            });
            const activo = inicioAbierto ? '<span class="text-emerald-400">●</span> ' : '';
            const marca = e.finalizado_at ? ' <span class="text-emerald-400">✓ finalizada</span>' : '';
            return `
                <div class="flex justify-between items-center text-xs py-1">
                    <span class="text-slate-300">${activo}${nombreEmp}${marca}</span>
                    <span class="font-mono text-slate-400 flex items-center gap-1">
                        <span class="ot-timer" data-acum="${acumCerrado}" data-inicio="${inicioAbierto}">00:00:00</span>
                        · <span class="ot-costo text-emerald-400" data-card="${o.id}" data-acum="${acumCerrado}" data-inicio="${inicioAbierto}" data-costohora="${snap}">$0.00</span>
                        <button type="button" class="btn-ajuste-tiempo text-slate-500 hover:text-amber-400 ml-1" title="Ajustar tiempo manualmente"
                                data-proceso="${p.id}" data-empleado="${empId}" data-nombre="${nombreEmp.replace(/"/g, '&quot;')}" data-proc-nombre="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">✎</button>
                    </span>
                </div>`;
        }).join('');

        const solsP = solicitudes.filter(s => Number(s.proceso_id) === p.id);
        const solsHtml = solsP.map(s => `
            <div class="flex flex-wrap items-center justify-between gap-2 bg-amber-950/30 border border-amber-800/50 rounded-lg px-2.5 py-1.5 mt-1.5">
                <span class="text-[11px] text-amber-200">🙋 <b>${s.empleados?.nombre || 'Empleado'}</b> pide entrar a este proceso${s.motivo ? ` — <span class="text-amber-300/80">"${String(s.motivo).replace(/</g, '&lt;')}"</span>` : ''}</span>
                <span class="flex gap-1">
                    <button class="btn-resolver-sol text-[11px] bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded"
                            data-id="${s.id}" data-accion="aprobar" data-nombre="${(s.empleados?.nombre || '').replace(/"/g, '&quot;')}" data-proc="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">Aprobar</button>
                    <button class="btn-resolver-sol text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded"
                            data-id="${s.id}" data-accion="rechazar" data-nombre="${(s.empleados?.nombre || '').replace(/"/g, '&quot;')}" data-proc="${(p.proceso_nombre || '').replace(/"/g, '&quot;')}">Rechazar</button>
                </span>
            </div>`).join('');

        return `
            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3">
                <p class="text-sm font-semibold text-slate-200 mb-1">${p.proceso_nombre}</p>
                ${filasEmp || '<p class="text-[11px] text-slate-500 italic">Sin equipo asignado.</p>'}
                ${solsHtml}
            </div>`;
    }).join('');

    return `
        <div class="border border-slate-800 rounded-xl p-4 mb-3">
            <div class="flex flex-wrap justify-between items-start gap-2 mb-3">
                <div>
                    <p class="font-mono font-bold text-amber-400 text-sm">${folio}</p>
                    <p class="text-xs text-slate-300">${o.productos?.nombre || 'Producto'} · ${o.cantidad_producida} u · Lote ${o.numero_lote || 'S/L'}</p>
                    <p class="text-[11px] text-slate-500">Abierta: ${abierta}</p>
                </div>
                <button type="button" class="btn-cerrar-orden bg-rose-700 hover:bg-rose-600 text-white text-xs px-3 py-1.5 rounded-lg" data-id="${o.id}" data-folio="${folio}" data-cant="${Number(o.cantidad_producida) || 0}" data-unidad="${String(o.productos?.unidades_medida?.nombre || '').replace(/"/g, '&quot;')}">🔒 Cerrar orden</button>
            </div>
            <div class="space-y-2">${procesosHtml}</div>
            <div class="flex justify-between items-center text-xs mt-3 pt-2 border-t border-slate-800">
                <span class="text-slate-400">Mano de obra registrada (parcial)</span>
                <span class="ot-costo-total font-mono font-bold text-emerald-400" data-card="${o.id}">$0.00</span>
            </div>
        </div>`;
}

// Ticker de 1s: recalcula los cronómetros abiertos sin volver a consultar la BD.
function tickEnProceso() {
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-timer').forEach(el => {
        const acum = Number(el.dataset.acum || 0);
        const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
        el.textContent = formatoHHMMSS(acum + (ini ? (Date.now() - ini) / 1000 : 0));
    });
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-costo').forEach(el => {
        const acum = Number(el.dataset.acum || 0);
        const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
        const ch = Number(el.dataset.costohora || 0);
        const seg = acum + (ini ? (Date.now() - ini) / 1000 : 0);
        el.textContent = '$' + ((seg / 3600) * ch).toFixed(2);
    });
    // Subtotal de mano de obra por orden = suma de los costos de sus operarios.
    document.querySelectorAll('#contenedorOrdenesEnProceso .ot-costo-total').forEach(tot => {
        const card = tot.dataset.card;
        let sum = 0;
        document.querySelectorAll(`#contenedorOrdenesEnProceso .ot-costo[data-card="${card}"]`).forEach(el => {
            const acum = Number(el.dataset.acum || 0);
            const ini = el.dataset.inicio ? new Date(el.dataset.inicio).getTime() : 0;
            const ch = Number(el.dataset.costohora || 0);
            sum += ((acum + (ini ? (Date.now() - ini) / 1000 : 0)) / 3600) * ch;
        });
        tot.textContent = '$' + sum.toFixed(2);
    });
}

async function cargarHistorialProduccion(idSeleccionarReciente = null) {
    const contenedorHistorial = document.getElementById('contenedorHistorialProduccion');
    const selectOrdenId = document.getElementById('selectOrdenId');
    const detalleResumenOrden = document.getElementById('detalleResumenOrden');
    const btnImprimirOrden = document.getElementById('btnImprimirOrden');

    try {
        if (!contenedorHistorial) return;
        contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">Cargando historial...</p>`;

        const { data: ordenes, error } = await supabaseClient
            .from('ordenes_produccion')
            .select(`id, folio, producto_id, numero_lote, cantidad_producida, empleados_involucrados, costo_unitario_final, costo_total_materiales, costo_total_mano_obra, created_at, cerrada_at, productos ( id, nombre, sku, descripcion, unidades_medida ( nombre ) )`)
            .eq('estado', 'cerrada')
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!ordenes || ordenes.length === 0) {
            contenedorHistorial.innerHTML = `<p class="text-slate-400 text-sm">Todavía no hay órdenes cerradas.</p>`;
            if (selectOrdenId) selectOrdenId.innerHTML = '<option value="">No hay órdenes disponibles</option>';
            if (btnImprimirOrden) btnImprimirOrden.disabled = true;
            return;
        }

        if (selectOrdenId) {
            selectOrdenId.innerHTML = '<option value="">Seleccione orden por ID...</option>';
            ordenes.forEach(o => {
                selectOrdenId.innerHTML += `<option value="${o.id}">${o.folio || ('ID #' + o.id)} - ${o.numero_lote || 'Sin Lote'} (${o.productos?.nombre || 'Producto'})</option>`;
            });

            selectOrdenId.onchange = async (e) => {
                const val = Number(e.target.value);
                if (btnImprimirOrden) btnImprimirOrden.disabled = !val;
                await renderizarDetalleOrden(val, ordenes, detalleResumenOrden);
            };
        }

        const btnReporteCompleto = document.getElementById('btnReporteCompletoOrden');
        if (btnReporteCompleto) {
            btnReporteCompleto.onclick = async () => {
                const idActual = Number(selectOrdenId?.value);
                if (!idActual) return;
                // Import dinámico: ordenes-produccion.js ya importa de este archivo (evita el ciclo al cargar).
                const m = await import('./ordenes-produccion.js');
                m.abrirDetalle(idActual);
            };
        }

        if (btnImprimirOrden) {
            btnImprimirOrden.onclick = () => {
                const idActual = Number(selectOrdenId?.value);
                const ordenActual = ordenes.find(o => o.id === idActual);
                if (!ordenActual) return;
                const titulo = `Orden de Producción #${ordenActual.id} — Lote ${ordenActual.numero_lote || 'S/L'}`;
                imprimirConPlantilla('entrada_produccion', titulo, 'detalleResumenOrden');
            };
        }

        aplicarOrden(histProdOrden, ordenes, (o, campo) => {
            switch (campo) {
                case 'folio': return (o.folio || String(o.id)).toLowerCase();
                case 'fecha': return o.created_at || '';
                case 'lote': return (o.numero_lote || '').toLowerCase();
                case 'producto': return (o.productos?.nombre || '').toLowerCase();
                case 'cantidad': return Number(o.cantidad_producida || 0);
                case 'costo': return Number(o.costo_unitario_final || 0);
                default: return o.id;
            }
        });

        let html = `
            <h4 class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3 mt-6">Historial General de Órdenes</h4>
            <div class="overflow-x-auto"><table class="w-full text-left text-sm text-slate-300">
                <thead><tr class="border-b border-slate-800 text-amber-400">
                    ${thOrden(histProdOrden, 'folio', 'Folio')}${thOrden(histProdOrden, 'fecha', 'Fecha')}${thOrden(histProdOrden, 'lote', 'Lote PT')}${thOrden(histProdOrden, 'producto', 'Producto')}${thOrden(histProdOrden, 'cantidad', 'Cantidad')}${thOrden(histProdOrden, 'costo', 'Costo Unit. Final')}
                </tr></thead><tbody>
        `;

        ordenes.forEach(o => {
            html += `
                <tr class="border-b border-slate-900 hover:bg-slate-900/40 transition-colors cursor-pointer" onclick="document.getElementById('selectOrdenId').value='${o.id}'; document.getElementById('selectOrdenId').dispatchEvent(new Event('change'));">
                    <td class="p-2 font-mono text-xs text-amber-300">${o.folio || ('#' + o.id)}</td>
                    <td class="p-2 text-xs text-slate-400">${new Date(o.created_at).toLocaleDateString()}</td>
                    <td class="p-2 font-mono text-xs text-slate-200">${o.numero_lote || 'N/D'}</td>
                    <td class="p-2 font-medium text-slate-100">${o.productos?.nombre || 'Desconocido'}</td>
                    <td class="p-2 font-mono">${o.cantidad_producida}</td>
                    <td class="p-2 font-mono text-emerald-400 font-semibold">$${Number(o.costo_unitario_final || 0).toFixed(2)}</td>
                </tr>
            `;
        });

        html += `</tbody></table></div>`;
        contenedorHistorial.innerHTML = html;
        wireOrdenTabla(contenedorHistorial, histProdOrden, () => cargarHistorialProduccion(Number(selectOrdenId?.value) || null));

        const targetId = idSeleccionarReciente || ordenes[0].id;
        if (selectOrdenId) {
            selectOrdenId.value = targetId;
            if (btnImprimirOrden) btnImprimirOrden.disabled = false;
            await renderizarDetalleOrden(targetId, ordenes, detalleResumenOrden);
        }
    } catch (err) {
        console.error("Error al cargar historial:", err);
    }
}

async function renderizarDetalleOrden(idSeleccionado, ordenes, contenedorDetalle) {
    if (!idSeleccionado || !contenedorDetalle) return;
    const orden = ordenes.find(item => item.id === idSeleccionado);
    if (!orden) return;
    
    contenedorDetalle.innerHTML = `<p class="text-slate-400 text-sm text-center py-2">Cargando desglose de componentes por lote...</p>`;
    
    try {
        // Los consumos de materia prima quedan en el documento de SALIDA (PROD-…-MP), no en el de entrada
        // del producto terminado (que es el que trae la póliza): ver documentosDeOrden.
        const docs = await documentosDeOrden(orden);
        const docPolizaId = docs.entrada?.poliza_id || null;
        const docPolizaFecha = docs.entrada?.fecha_emision || null;
        const movimientosSalida = await consumosDeOrden(docs);

        const cantidadProducidaLote = Number(orden.cantidad_producida || 1);
        let htmlComponentes = '';
        let importeTotalFormula = 0;

        if (movimientosSalida && movimientosSalida.length > 0) {
            movimientosSalida.forEach(mov => {
                const nombreInsumo = mov.productos?.nombre || 'Insumo desconocido';
                const loteOrigen = mov.lotes_inventario?.numero_lote ? ` (Lote: ${mov.lotes_inventario.numero_lote})` : '';
                
                const cantidadDescontada = Math.abs(Number(mov.cantidad || 0));
                const costoUnitario = Number(mov.costo_unitario || 0);
                const subtotal = cantidadDescontada * costoUnitario;
                importeTotalFormula += subtotal;

                const unidadMedidaTexto = mov.productos?.unidades_medida?.nombre || 'Unid';

                htmlComponentes += `
                    <tr class="border-b border-slate-900/60 text-xs">
                        <td class="py-2.5 px-3 font-medium text-slate-200">
                            ${nombreInsumo} <span class="text-amber-400 font-mono text-[11px] campo-lote">${loteOrigen}</span>
                        </td>
                        <td class="py-2.5 px-3 font-mono text-amber-300">${cantidadDescontada.toFixed(4)}</td>
                        <td class="py-2.5 px-3 text-slate-400">${unidadMedidaTexto}</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300 campo-costo">$${costoUnitario.toFixed(2)}</td>
                        <td class="py-2.5 px-3 font-mono text-emerald-400 text-right font-semibold campo-costo">$${subtotal.toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            htmlComponentes = `
                <tr>
                    <td colspan="5" class="py-3 px-3 text-center text-slate-400 italic">
                        No se encontraron movimientos de lotes registrados para esta orden.
                    </td>
                </tr>
            `;
        }

        const { data: procesosOrden } = await supabaseClient
            .from('orden_produccion_procesos')
            .select(`
                id, proceso_nombre, segundos_transcurridos, costo_calculado,
                orden_produccion_proceso_empleados ( costo_hora_snapshot, empleados ( nombre ) )
            `)
            .eq('orden_produccion_id', orden.id)
            .order('created_at', { ascending: true });

        const formatoHHMMSS = (totalSegundos) => {
            const s = Math.max(0, Math.floor(totalSegundos));
            const hh = String(Math.floor(s / 3600)).padStart(2, '0');
            const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
            const ss = String(s % 60).padStart(2, '0');
            return `${hh}:${mm}:${ss}`;
        };

        let htmlProcesos = '';
        if (procesosOrden && procesosOrden.length > 0) {
            htmlProcesos = `
                <div class="mb-4 campo-costo">
                    <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">⏱️ Equipos de Trabajo por Proceso</h4>
                    <div class="space-y-2">
                        ${procesosOrden.map(p => {
                            const equipo = (p.orden_produccion_proceso_empleados || []).map(e => e.empleados?.nombre).filter(Boolean).join(', ') || 'Sin equipo asignado';
                            return `
                            <div class="bg-slate-900 border border-slate-800 rounded-lg p-3 flex flex-wrap justify-between items-center gap-2">
                                <div>
                                    <span class="text-sm font-semibold text-slate-200">${p.proceso_nombre}</span>
                                    <span class="text-[11px] text-slate-500 block">${equipo}</span>
                                </div>
                                <div class="text-right">
                                    <span class="font-mono text-amber-300 text-sm block">${formatoHHMMSS(p.segundos_transcurridos)}</span>
                                    <span class="font-mono text-emerald-400 text-xs">$${Number(p.costo_calculado).toFixed(2)}</span>
                                </div>
                            </div>`;
                        }).join('')}
                    </div>
                </div>
            `;
        }

        const mobTotal = Number(orden.costo_total_mano_obra || 0);
        const unitFinal = Number(orden.costo_unitario_final || 0);
        const materialTotalFinal = orden.costo_total_materiales ? Number(orden.costo_total_materiales) : importeTotalFormula;

        const unidadProducto = orden.productos?.unidades_medida?.nombre || '';
        const empleados = orden.empleados_involucrados != null ? orden.empleados_involucrados : 'N/D';

        contenedorDetalle.innerHTML = `
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4 pb-4 border-b border-slate-800">
                <div class="campo-lote"><span class="text-xs text-slate-400 block">ORDEN / LOTE</span><span class="font-mono font-bold text-amber-400">ID #${orden.id} | ${orden.numero_lote}</span></div>
                <div><span class="text-xs text-slate-400 block">PRODUCTO</span><span class="font-medium text-slate-100">${orden.productos?.nombre}</span>${orden.productos?.sku ? `<span class="text-[10px] text-slate-500 block font-mono">SKU: ${orden.productos.sku}</span>` : ''}</div>
                <div><span class="text-xs text-slate-400 block">CANTIDAD</span><span class="font-mono text-slate-200">${cantidadProducidaLote} ${unidadProducto}</span></div>
                <div><span class="text-xs text-slate-400 block">EMPLEADOS</span><span class="font-mono text-slate-200">${empleados}</span></div>
                <div><span class="text-xs text-slate-400 block">FECHA</span><span class="text-slate-300">${new Date(orden.created_at).toLocaleString()}</span></div>
                <div class="md:col-span-5">
                    <span class="text-xs text-slate-400 block">PÓLIZA CONTABLE</span>
                    ${docPolizaId
                        ? `<button type="button" onclick="window.verPolizaDeDocumento(${docPolizaId}, '${docPolizaFecha || ''}')" class="mt-1 text-xs bg-emerald-600 hover:bg-emerald-500 text-white font-semibold border border-emerald-700 px-3 py-1.5 rounded-lg inline-flex items-center gap-1.5 cursor-pointer">🧾 Ver póliza #${docPolizaId}</button>`
                        : `<span class="text-xs text-amber-400">Sin póliza — esta orden no se ha contabilizado.</span>`}
                </div>
            </div>
            ${orden.productos?.descripcion ? `<p class="text-xs text-slate-400 mb-4 -mt-2">${orden.productos.descripcion}</p>` : ''}
            ${htmlProcesos}
            <table class="w-full text-left text-sm text-slate-300 bg-slate-900 rounded-lg overflow-hidden mb-4">
                <thead>
                    <tr class="border-b border-slate-800 text-xs text-slate-400 bg-slate-950">
                        <th class="py-2.5 px-3">Materia Prima / Componente</th>
                        <th class="py-2.5 px-3">Cantidad</th>
                        <th class="py-2.5 px-3">Unidad</th>
                        <th class="py-2.5 px-3 campo-costo">Costo</th>
                        <th class="py-2.5 px-3 text-right campo-costo">Subtotal</th>
                    </tr>
                </thead>
                <tbody>${htmlComponentes}</tbody>
            </table>

            <div class="bg-slate-950 border border-slate-800 p-4 rounded-lg mb-4 flex justify-between items-center campo-costo">
                <span class="text-sm font-semibold text-amber-400">📊 Importe Total de todos los Componentes de la Fórmula:</span>
                <span class="text-lg font-mono font-bold text-emerald-400">$${importeTotalFormula.toFixed(2)}</span>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-4 gap-3 campo-costo">
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Materiales</span><span class="font-mono text-base text-slate-200 font-bold">$${materialTotalFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Mano de Obra</span><span class="font-mono text-base text-slate-200 font-bold">$${mobTotal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Costo Unitario</span><span class="font-mono text-base text-emerald-400 font-bold">$${unitFinal.toFixed(2)}</span></div>
                <div class="bg-slate-900 p-3 rounded-lg border border-slate-800"><span class="text-xs text-slate-400 block">Total Lote</span><span class="font-mono text-base text-amber-300 font-bold">$${(cantidadProducidaLote * unitFinal).toFixed(2)}</span></div>
            </div>`;
    } catch (err) { 
        console.error("Error al renderizar el detalle de la orden:", err); 
    }
}