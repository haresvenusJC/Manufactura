// =====================================================================
//  Auxiliar de inventarios (valorizado) — pestaña de Reportes contables.
//
//  Como el "Auxiliar de cuentas contables", pero por artículo: saldo
//  inicial (cantidad y valor), cada movimiento del kardex del periodo
//  (entradas/salidas en cantidad y valor, con su documento y póliza), saldo
//  corriente y saldo final. El valor es |cantidad| × costo_unitario del
//  movimiento (ya trae el landed cost del lote y, en salidas, el costo PEPS
//  con el que salió), igual que el Kardex.
//
//  Al final, "Cuadre contra la balanza": por cada cuenta de inventario
//  (productos.cuenta_inventario_id; sin cuenta -> 115.04 si es producto,
//  115.02 si es semiterminado, 115.01 si no, igual que contabilizar_produccion / compras) compara la
//  suma del kardex de TODOS sus artículos contra el saldo de la cuenta en
//  la balanza a la fecha "Hasta", y lista las pólizas que movieron la
//  cuenta sin un movimiento de inventario detrás (ajustes manuales,
//  deterioro, prorrateo de CIF…), que es donde suele estar la diferencia.
//  La balanza usa la misma regla que Reportes contables (js/polizas-saldo.js):
//  una póliza cancelada CON reverso sigue contando, y el reverso de un recibo
//  cancelado queda ligado a su movimiento 'cancelacion_recibo' del kardex.
//
//  Todo va en una sola tabla dentro de #rcTabla para que "Imprimir" y
//  "Exportar CSV" de Reportes contables funcionen sin cambios.
// =====================================================================
import { supabaseClient } from './supabase.js';
import { convertirEnBuscador } from './buscador-select.js';
import { ESTATUS_CONSULTA, traerReversos, enSaldo } from './polizas-saldo.js';

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fmt = (n) => {
    const v = Math.round((Number(n) || 0) * 100) / 100;
    const s = Math.abs(v).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return v < 0 ? `(${s})` : s;
};
const fmtCant = (n) => Number(Number(n || 0).toFixed(4)).toLocaleString('es-MX', { maximumFractionDigits: 4 });
const fechaLocal = (iso) => { const d = new Date(iso); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`; };

// Todo documento o póliza que aparece en un reporte se puede abrir desde ahí (regla de CLAUDE.md):
// documento -> window.abrirDetalleDocumentoGlobal (js/documentos.js), póliza -> window.rcVerPoliza
// (js/contabilidad.js). Ambos abren una subventana sin salir del reporte.
const linkDoc = (id, texto) => id
    ? `<button type="button" onclick="window.abrirDetalleDocumentoGlobal(${Number(id)}); const m=document.getElementById('modalDetalleDocKardex'); if(m){m.style.zIndex=70;m.classList.remove('hidden');}" class="text-sky-300 hover:text-sky-200 hover:underline cursor-pointer font-mono" title="Abrir el documento">${esc(texto)}</button>`
    : esc(texto);
const linkPoliza = (id) => id
    ? `<button type="button" onclick="window.rcVerPoliza(${Number(id)}); const m=document.getElementById('rcModalPoliza'); if(m) m.style.zIndex=70;" data-pol-id="${Number(id)}" class="text-sky-300 hover:text-sky-200 hover:underline cursor-pointer font-mono" title="Abrir la póliza">póliza…</button>`
    : '—';

const CLASIF = {
    materia_prima: 'Materia prima',
    insumo: 'Insumo',
    semiterminado: 'Semiterminado (granel)',
    producto: 'Producto terminado',
};
const TIPO_MOV = {
    entrada_compra: 'Compra', entrada: 'Entrada', entrada_produccion: 'Entrada de producción',
    salida_produccion: 'Salida a producción', salida_venta: 'Venta', salida: 'Salida', merma: 'Merma',
    cancelacion_recibo: 'Cancelación de recibo', ajuste_recepcion: 'Ajuste de recepción',
};

let productosCache = null;   // [{ id, nombre, sku, tipo, cuenta_inventario_id, unidad }]
let cuentasCache = null;     // [{ id, codigo, nombre, naturaleza }]

function clasificacion(p) {
    return p.tipo || 'producto';   // producto / semiterminado / materia_prima / insumo
}

async function cargarCatalogos() {
    if (!cuentasCache) {
        const { data, error } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre, naturaleza').order('codigo');
        if (error) throw error;
        cuentasCache = data || [];
    }
    if (!productosCache) {
        const cols = 'id, nombre, sku, tipo, cuenta_inventario_id, unidades_medida ( nombre )';
        const { data, error } = await supabaseClient.from('productos').select(cols).order('nombre');
        if (error) throw error;
        const c = (cod) => cuentasCache.find((x) => x.codigo === cod)?.id || null;
        const c01 = c('115.01'), c02 = c('115.02'), c04 = c('115.04');
        productosCache = (data || []).map((p) => ({
            id: p.id, nombre: p.nombre, sku: p.sku, tipo: p.tipo,
            unidad: p.unidades_medida?.nombre || '',
            cuentaAsignada: !!p.cuenta_inventario_id,
            // Misma regla que cuadre_inventario_contable() en la base.
            cuentaId: p.cuenta_inventario_id || (p.tipo === 'producto' ? c04 : p.tipo === 'semiterminado' ? (c02 || c04) : c01),
        }));
    }
}

/** Arma (una vez) los filtros propios de la pestaña dentro de `caja`. */
export async function prepararFiltrosAuxInv(caja, alCambiar) {
    if (!caja || caja.dataset.listo === '1') return;
    caja.dataset.listo = '1';
    caja.innerHTML = `
        <div><label class="block text-[11px] text-slate-400 mb-1">Clasificación</label>
            <select id="aiClasif" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
                <option value="">Todas</option>
                ${Object.entries(CLASIF).map(([k, t]) => `<option value="${k}">${t}</option>`).join('')}
            </select></div>
        <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de inventario</label>
            <select id="aiCuenta" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 max-w-[16rem]"><option value="">Todas</option></select></div>
        <div class="min-w-[16rem]"><label class="block text-[11px] text-slate-400 mb-1">Artículo</label>
            <select id="aiArticulo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100"><option value="">Todos los de la selección</option></select></div>
        <label class="flex items-center gap-1.5 text-[11px] text-slate-300 pb-2 cursor-pointer"><input type="checkbox" id="aiSoloMov" checked class="accent-sky-500"> Solo artículos con movimientos o saldo</label>`;
    try {
        await cargarCatalogos();
    } catch (err) {
        caja.innerHTML = `<p class="text-rose-400 text-xs">No se pudieron cargar productos/cuentas: ${esc(err.message || err)}</p>`;
        return;
    }
    const usadas = new Set(productosCache.map((p) => p.cuentaId).filter(Boolean));
    document.getElementById('aiCuenta').innerHTML = '<option value="">Todas</option>' + cuentasCache
        .filter((c) => usadas.has(c.id))
        .map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    const selArt = document.getElementById('aiArticulo');
    const llenarArticulos = () => {
        const actual = selArt.value;
        const lista = filtrarProductos(document.getElementById('aiClasif').value, document.getElementById('aiCuenta').value, '');
        selArt.innerHTML = '<option value="">Todos los de la selección</option>' +
            lista.map((p) => `<option value="${p.id}">${esc(p.nombre)}${p.sku ? ` (${esc(p.sku)})` : ''}</option>`).join('');
        if (lista.some((p) => String(p.id) === actual)) selArt.value = actual;
        selArt.buscadorRefrescar?.();
    };
    llenarArticulos();
    convertirEnBuscador(selArt, { placeholder: 'Todos los de la selección (escribe para buscar)' });
    ['aiClasif', 'aiCuenta'].forEach((id) => document.getElementById(id).addEventListener('change', () => { llenarArticulos(); alCambiar?.(); }));
    selArt.addEventListener('change', () => alCambiar?.());
    document.getElementById('aiSoloMov').addEventListener('change', () => alCambiar?.());
}

function filtrarProductos(clasif, cuentaId, articuloId) {
    return (productosCache || []).filter((p) =>
        (!clasif || clasificacion(p) === clasif) &&
        (!cuentaId || String(p.cuentaId) === String(cuentaId)) &&
        (!articuloId || String(p.id) === String(articuloId)));
}

async function traerMovimientos(productoIds, hastaISO) {
    const out = [];
    for (let i = 0; i < productoIds.length; i += 100) {
        const grupo = productoIds.slice(i, i + 100);
        for (let desdeFila = 0; ; desdeFila += 1000) {
            const { data, error } = await supabaseClient.from('movimientos_inventario')
                .select('id, producto_id, tipo_movimiento, cantidad, costo_unitario, created_at, documento_id, lotes_inventario ( numero_lote )')
                .in('producto_id', grupo)
                .lte('created_at', hastaISO)
                .order('created_at', { ascending: true })
                .order('id', { ascending: true })
                .range(desdeFila, desdeFila + 999);
            if (error) throw error;
            out.push(...(data || []));
            if (!data || data.length < 1000) break;
        }
    }
    // Folio y póliza de cada documento (consulta aparte: no depende de que exista la relación en PostgREST).
    const docIds = [...new Set(out.map((m) => m.documento_id).filter(Boolean))];
    const docs = new Map();
    for (let i = 0; i < docIds.length; i += 200) {
        const { data } = await supabaseClient.from('documentos').select('id, folio, poliza_id').in('id', docIds.slice(i, i + 200));
        (data || []).forEach((d) => docs.set(d.id, d));
    }
    out.forEach((m) => { m.documentos = docs.get(m.documento_id) || null; });
    return out;
}

async function traerPolizasCuenta(cuentaIds, hasta, reversos) {
    const out = [];
    for (let desdeFila = 0; ; desdeFila += 1000) {
        const { data, error } = await supabaseClient.from('poliza_movimientos')
            .select('cuenta_id, cargo, abono, concepto, polizas!inner(id, fecha, estatus, tipo, numero, concepto, origen)')
            .in('cuenta_id', cuentaIds)
            .in('polizas.estatus', ESTATUS_CONSULTA)
            .lte('polizas.fecha', hasta)
            .order('id', { ascending: true })
            .range(desdeFila, desdeFila + 999);
        if (error) throw error;
        out.push(...(data || []).filter((x) => enSaldo(x.polizas, reversos)));
        if (!data || data.length < 1000) break;
    }
    return out;
}

/** Genera el reporte y lo pinta en `res` (el contenedor #rcResultado). */
export async function generarAuxInventarios(res, desde, hasta) {
    if (!desde || !hasta) { alert('Indica el periodo.'); return; }
    res.innerHTML = '<p class="text-slate-500">Consultando kardex y pólizas...</p>';
    try {
        await cargarCatalogos();
        const clasif = document.getElementById('aiClasif')?.value || '';
        const cuentaSel = document.getElementById('aiCuenta')?.value || '';
        const articulo = document.getElementById('aiArticulo')?.value || '';
        const soloMov = document.getElementById('aiSoloMov')?.checked ?? true;

        const visibles = filtrarProductos(clasif, cuentaSel, articulo);
        if (!visibles.length) { res.innerHTML = '<p class="text-slate-400">No hay artículos con esos filtros.</p>'; return; }

        // Para cuadrar hay que sumar TODOS los artículos de cada cuenta involucrada, no solo los filtrados.
        const cuentasInv = [...new Set(visibles.map((p) => p.cuentaId).filter(Boolean))];
        const todosDeCuentas = productosCache.filter((p) => cuentasInv.includes(p.cuentaId));
        const hastaISO = new Date(`${hasta}T23:59:59.999`).toISOString();
        const [movs, reversos] = await Promise.all([traerMovimientos(todosDeCuentas.map((p) => p.id), hastaISO), traerReversos()]);
        // La póliza de cada movimiento: la del documento, salvo la cancelación de un recibo,
        // que se contabiliza en el reverso (contra-asiento) de esa póliza.
        const polizaDeMov = (m) => {
            const pol = m.documentos?.poliza_id || null;
            return (m.tipo_movimiento === 'cancelacion_recibo' && pol && reversos.get(Number(pol))) || pol;
        };
        const porProd = new Map();
        movs.forEach((m) => { if (!porProd.has(m.producto_id)) porProd.set(m.producto_id, []); porProd.get(m.producto_id).push(m); });

        // Kardex valorizado por artículo
        const kardex = new Map();
        for (const p of todosDeCuentas) {
            let cant = 0, valor = 0;
            const filas = [];
            let eC = 0, eV = 0, sC = 0, sV = 0;
            let cantIni = 0, valIni = 0;
            for (const m of porProd.get(p.id) || []) {
                const f = fechaLocal(m.created_at);
                const q = Number(m.cantidad || 0);
                const v = Math.abs(q) * Number(m.costo_unitario || 0) * (q < 0 ? -1 : 1);
                cant += q; valor += v;
                if (f < desde) { cantIni = cant; valIni = valor; continue; }
                if (q >= 0) { eC += q; eV += v; } else { sC += -q; sV += -v; }
                filas.push({ fecha: f, tipo: TIPO_MOV[m.tipo_movimiento] || m.tipo_movimiento || '—', docId: m.documento_id || null, folio: m.documentos?.folio || (m.documento_id ? '#' + m.documento_id : '—'),
                    poliza: polizaDeMov(m), lote: m.lotes_inventario?.numero_lote || '', q, cu: Number(m.costo_unitario || 0), v, cant, valor });
            }
            kardex.set(p.id, { p, cantIni, valIni, filas, eC, eV, sC, sV, cantFin: cant, valFin: valor });
        }

        // Balanza de las cuentas de inventario a la fecha "Hasta" + pólizas sin movimiento de inventario detrás
        const pols = cuentasInv.length ? await traerPolizasCuenta(cuentasInv, hasta, reversos) : [];
        const polizasConInventario = new Set(movs.map(polizaDeMov).filter(Boolean));
        const cuadre = cuentasInv.map((cid) => {
            const cta = cuentasCache.find((c) => c.id === cid) || { codigo: '?', nombre: 'Cuenta', naturaleza: 'D' };
            const signo = cta.naturaleza === 'A' ? -1 : 1;
            let saldo = 0;
            const ajenas = new Map();   // pólizas del periodo que movieron la cuenta sin kardex detrás
            pols.filter((x) => x.cuenta_id === cid).forEach((x) => {
                const neto = (Number(x.cargo) || 0) - (Number(x.abono) || 0);
                saldo += signo * neto;
                if (!polizasConInventario.has(x.polizas.id)) {
                    const k = x.polizas.id;
                    if (!ajenas.has(k)) ajenas.set(k, { pol: x.polizas, concepto: x.concepto || x.polizas.concepto || '', neto: 0 });
                    ajenas.get(k).neto += neto;
                }
            });
            const deCuenta = todosDeCuentas.filter((p) => p.cuentaId === cid);
            const kardexTotal = deCuenta.reduce((a, p) => a + kardex.get(p.id).valFin, 0);
            return { cta, saldoBalanza: saldo, kardexTotal, dif: saldo - kardexTotal, ajenas: [...ajenas.values()].sort((a, b) => (a.pol.fecha < b.pol.fecha ? -1 : 1)),
                sinCuenta: deCuenta.filter((p) => !p.cuentaAsignada).length, nArticulos: deCuenta.length };
        });

        pintar(res, { desde, hasta, visibles, kardex, cuadre, soloMov });
    } catch (err) {
        res.innerHTML = `<p class="text-rose-400 text-xs">No se pudo generar el auxiliar de inventarios.<br>${esc(err.message || err)}</p>`;
    }
}

function pintar(res, { desde, hasta, visibles, kardex, cuadre, soloMov }) {
    const td = 'p-1.5';
    const tdR = 'p-1.5 text-right font-mono';
    let cuerpo = '';
    let tE = 0, tS = 0, tIni = 0, tFin = 0, n = 0;
    for (const p of visibles) {
        const k = kardex.get(p.id);
        if (!k) continue;
        if (soloMov && !k.filas.length && Math.abs(k.valIni) < 0.005 && Math.abs(k.cantIni) < 0.0005) continue;
        n++;
        tE += k.eV; tS += k.sV; tIni += k.valIni; tFin += k.valFin;
        const cta = cuentasCache.find((c) => c.id === p.cuentaId);
        cuerpo += `
        <tr class="bg-slate-800/60"><td class="p-2 font-bold text-sky-400" colspan="11">${esc(p.nombre)}${p.sku ? ` <span class="font-normal text-slate-400">(${esc(p.sku)})</span>` : ''}
            <span class="font-normal text-[10px] text-slate-500 ml-2">${esc(CLASIF[clasificacion(p)] || '')} · ${cta ? esc(cta.codigo) + ' ' + esc(cta.nombre) : 'sin cuenta'}${p.cuentaAsignada ? '' : ' (sin cuenta asignada: se asume)'} · ${esc(p.unidad)}</span></td></tr>
        <tr class="border-b border-slate-900 text-slate-400"><td class="${td}" colspan="7">Saldo inicial al ${esc(desde)}</td>
            <td class="${tdR}"></td><td class="${tdR}"></td><td class="${tdR}">${fmtCant(k.cantIni)}</td><td class="${tdR}">${fmt(k.valIni)}</td></tr>
        ${k.filas.map((f) => `<tr class="border-b border-slate-900/60 text-slate-300">
            <td class="${td} font-mono text-[11px]">${esc(f.fecha)}</td><td class="${td}">${esc(f.tipo)}</td>
            <td class="${td} font-mono text-[11px]">${linkDoc(f.docId, f.folio)}</td><td class="${td} font-mono text-[11px]">${linkPoliza(f.poliza)}</td>
            <td class="${td} font-mono text-[11px]">${esc(f.lote)}</td>
            <td class="${tdR} text-emerald-300">${f.q >= 0 ? fmtCant(f.q) : ''}</td><td class="${tdR} text-emerald-300">${f.q >= 0 ? fmt(f.v) : ''}</td>
            <td class="${tdR} text-rose-300">${f.q < 0 ? fmtCant(-f.q) : ''}</td><td class="${tdR} text-rose-300">${f.q < 0 ? fmt(-f.v) : ''}</td>
            <td class="${tdR}">${fmtCant(f.cant)}</td><td class="${tdR}">${fmt(f.valor)}</td></tr>`).join('')}
        <tr class="border-b-2 border-slate-700 text-slate-200 font-semibold"><td class="${td}" colspan="5">Total del periodo / saldo final al ${esc(hasta)}</td>
            <td class="${tdR}">${fmtCant(k.eC)}</td><td class="${tdR}">${fmt(k.eV)}</td><td class="${tdR}">${fmtCant(k.sC)}</td><td class="${tdR}">${fmt(k.sV)}</td>
            <td class="${tdR}">${fmtCant(k.cantFin)}</td><td class="${tdR} text-sky-300">${fmt(k.valFin)}</td></tr>`;
    }
    if (!n) { res.innerHTML = '<p class="text-slate-400">Sin movimientos ni saldo en ese periodo para los artículos elegidos.</p>'; return; }

    const cuadreHtml = cuadre.map((c) => {
        const ok = Math.abs(c.dif) < 0.5;
        return `
        <tr class="bg-slate-800/60"><td class="p-2 font-bold ${ok ? 'text-emerald-400' : 'text-amber-400'}" colspan="11">${ok ? '✅' : '⚠️'} Cuadre ${esc(c.cta.codigo)} · ${esc(c.cta.nombre)} al ${esc(hasta)}
            <span class="font-normal text-[10px] text-slate-500 ml-2">${c.nArticulos} artículo(s) en esta cuenta${c.sinCuenta ? `, ${c.sinCuenta} sin cuenta asignada (se asumió)` : ''}</span></td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="10">Suma del kardex valorizado de TODOS los artículos de la cuenta</td><td class="${tdR}">${fmt(c.kardexTotal)}</td></tr>
        <tr class="text-slate-300"><td class="${td}" colspan="10">Saldo de la cuenta en la balanza (contabilizadas + canceladas con su reverso)</td><td class="${tdR}">${fmt(c.saldoBalanza)}</td></tr>
        <tr class="font-semibold ${ok ? 'text-emerald-300' : 'text-amber-300'}"><td class="${td}" colspan="10">Diferencia (balanza − kardex)</td><td class="${tdR}">${fmt(c.dif)}</td></tr>
        ${c.ajenas.length ? `<tr class="text-slate-400"><td class="${td} text-[11px] italic" colspan="11">Pólizas que movieron esta cuenta sin un movimiento de inventario detrás (ahí suele estar la diferencia):</td></tr>
        ${c.ajenas.map((a) => `<tr class="text-slate-400 text-[11px]"><td class="${td} font-mono">${esc(a.pol.fecha)}</td><td class="${td}">Póliza ${linkPoliza(a.pol.id)}</td>
            <td class="${td}">${esc(a.pol.tipo || '')} ${esc(a.pol.numero || '')}</td><td class="${td}">${esc(a.pol.origen || 'manual')}</td>
            <td class="${td}" colspan="6">${esc(a.concepto)}</td><td class="${tdR}">${fmt(a.neto)}</td></tr>`).join('')}` : ''}`;
    }).join('');

    res.innerHTML = `
        <div class="flex flex-wrap gap-4 text-xs text-slate-400 mb-3">
            <span>Periodo: <b class="text-slate-200">${esc(desde)} a ${esc(hasta)}</b></span>
            <span>Artículos: <b class="text-slate-200">${n}</b></span>
            <span>Saldo inicial: <b class="text-slate-200">$${fmt(tIni)}</b></span>
            <span>Entradas: <b class="text-emerald-300">$${fmt(tE)}</b></span>
            <span>Salidas: <b class="text-rose-300">$${fmt(tS)}</b></span>
            <span>Saldo final: <b class="text-sky-300">$${fmt(tFin)}</b></span>
        </div>
        <div id="rcTabla" class="overflow-x-auto">
        <table class="w-full text-xs">
            <thead><tr class="text-left text-slate-500 border-b border-slate-800">
                <th class="p-1.5">Fecha</th><th class="p-1.5">Movimiento</th><th class="p-1.5">Documento</th><th class="p-1.5">Póliza</th><th class="p-1.5">Lote</th>
                <th class="p-1.5 text-right">Entrada cant.</th><th class="p-1.5 text-right">Entrada $</th>
                <th class="p-1.5 text-right">Salida cant.</th><th class="p-1.5 text-right">Salida $</th>
                <th class="p-1.5 text-right">Saldo cant.</th><th class="p-1.5 text-right">Saldo $</th>
            </tr></thead>
            <tbody>${cuerpo}
            <tr><td colspan="11" class="pt-4"></td></tr>
            ${cuadreHtml}
            </tbody>
        </table>
        <p class="text-[10px] text-slate-500 mt-2">Valor = cantidad × costo unitario del movimiento en el kardex (incluye landed cost; las salidas van al costo PEPS con que salieron). El cuadre suma todos los artículos de cada cuenta aunque el filtro muestre solo algunos.</p>
        </div>`;
}
