import { supabaseClient } from './supabase.js';
import { parsearCfdi } from './cfdi.js';
import { rmClasificarConceptos } from './ordenes-compra.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
//  Captura masiva de "Claves de proveedor" (SKU/UPC, descripción y unidad
//  con que cada proveedor vende un producto) leyendo sus facturas XML —
//  el mismo emparejamiento contra el catálogo interno que usa el
//  importador de XML de Recibo de mercancía (clave ya homologada → SAT →
//  SKU → nombre), pero sin tocar inventario, lotes ni contabilidad: solo
//  llena producto_claves_proveedor. Útil para cargar de golpe facturas
//  viejas sin tener que volver a "recibir" esa mercancía.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const normTxt = (s) => String(s || '').normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase().trim();

let iclProductos = [];
let iclProveedores = [];
let iclFilas = [];

export async function cargarModuloImportadorClavesProveedor() {
    const cont = document.getElementById('contenedorImportadorClavesProveedor');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        const [pr, pv] = await Promise.all([
            supabaseClient.from('productos').select('id, nombre, sku').order('nombre'),
            supabaseClient.from('proveedores').select('id, nombre, rfc').order('nombre'),
        ]);
        iclProductos = pr.data || [];
        iclProveedores = pv.data || [];
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`;
        return;
    }
    iclFilas = [];

    cont.innerHTML = `
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
        <h3 class="text-md font-semibold text-emerald-400">Importar facturas XML</h3>
        <p class="text-xs text-slate-400">Sube una o varias facturas (XML del CFDI) de tus proveedores. Se leen sus partidas y se intentan emparejar contra tu catálogo interno, para capturar de una vez el SKU, la descripción y la unidad con que cada proveedor vende cada producto. <strong>No mueve inventario ni contabilidad</strong> — solo llena "Claves de proveedor" en Productos.</p>
        <input type="file" id="iclArchivos" accept=".xml,text/xml" multiple class="w-full text-xs text-slate-300 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-slate-800 file:text-slate-200 hover:file:bg-slate-700">
        <button type="button" id="iclProcesar" class="w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-2 rounded-lg text-sm">Procesar archivos</button>
        <p id="iclMsg" class="text-xs min-h-[1rem]"></p>
      </div>
      <div id="iclTabla" class="mt-4"><p class="text-slate-500 text-sm">Sube archivos para empezar.</p></div>
    `;

    document.getElementById('iclProcesar').onclick = iclProcesarArchivos;
    montarGuia(cont, 'importador-claves-proveedor');
}

async function iclProcesarArchivos() {
    const input = document.getElementById('iclArchivos');
    const files = [...(input.files || [])];
    if (!files.length) { alert('Elige uno o más archivos XML.'); return; }

    const msg = document.getElementById('iclMsg');
    msg.textContent = 'Procesando...'; msg.className = 'text-xs min-h-[1rem] text-slate-400';

    let archivosOk = 0, conceptosNuevos = 0;
    const erroresArchivo = [];

    for (const file of files) {
        try {
            const text = await file.text();
            const r = parsearCfdi(text);
            if (r.error) { erroresArchivo.push(`${file.name}: ${r.error}`); continue; }

            const rfc = (r.rfcEmisor || '').trim();
            let proveedorId = null, proveedorNombre = r.nombreEmisor || rfc || 'Proveedor no identificado';
            if (rfc) {
                try {
                    const { data: pv } = await supabaseClient.from('proveedores').select('id, nombre').ilike('rfc', rfc).limit(1).maybeSingle();
                    if (pv) { proveedorId = pv.id; proveedorNombre = pv.nombre; }
                } catch (_) { /* proveedores sin columna rfc */ }
            }

            const clavesMap = new Map(), clavesSatMap = new Map();
            if (proveedorId) {
                try {
                    const { data } = await supabaseClient.from('producto_claves_proveedor')
                        .select('producto_id, clave, clave_sat').eq('proveedor_id', proveedorId);
                    (data || []).forEach((c) => {
                        if (c.clave) clavesMap.set(normTxt(c.clave), c.producto_id);
                        if (c.clave_sat) clavesSatMap.set(String(c.clave_sat).trim(), c.producto_id);
                    });
                } catch (_) { /* tabla de claves aún no existe */ }
            }

            const { productos: conceptosProducto } = rmClasificarConceptos(r.conceptos);
            conceptosProducto.forEach((cp) => {
                let prodId = null;
                if (cp.noId && clavesMap.has(normTxt(cp.noId))) prodId = clavesMap.get(normTxt(cp.noId));
                if (!prodId && cp.claveSat && clavesSatMap.has(cp.claveSat)) prodId = clavesSatMap.get(cp.claveSat);
                if (!prodId && cp.noId) {
                    const bySku = iclProductos.find((p) => p.sku && normTxt(p.sku) === normTxt(cp.noId));
                    if (bySku) prodId = bySku.id;
                }
                if (!prodId && cp.descripcion) {
                    const nd = normTxt(cp.descripcion);
                    const byName = iclProductos.find((p) => p.nombre && (nd.includes(normTxt(p.nombre)) || normTxt(p.nombre).includes(nd)));
                    if (byName) prodId = byName.id;
                }
                iclFilas.push({
                    archivo: file.name,
                    rfcEmisor: rfc,
                    proveedorId,
                    proveedorNombre,
                    claveSat: cp.claveSat || '',
                    noId: cp.noId || '',
                    descripcion: cp.descripcion || '',
                    unidad: cp.unidad || cp.claveUnidad || '',
                    productoId: prodId,
                    productoIdAuto: prodId,
                    incluir: true,
                });
                conceptosNuevos++;
            });
            archivosOk++;
        } catch (err) {
            erroresArchivo.push(`${file.name}: ${err.message || err}`);
        }
    }

    input.value = '';
    const partes = [`Procesados ${archivosOk} de ${files.length} archivo(s), ${conceptosNuevos} partida(s) agregada(s).`];
    if (erroresArchivo.length) partes.push(`${erroresArchivo.length} con error: ${erroresArchivo.join(' · ')}`);
    msg.textContent = partes.join(' ');
    msg.className = 'text-xs min-h-[1rem] ' + (erroresArchivo.length ? 'text-amber-400' : 'text-emerald-400');
    iclRenderTabla();
}

function iclRenderTabla() {
    const cont = document.getElementById('iclTabla');
    if (!cont) return;
    if (!iclFilas.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sube archivos para empezar.</p>'; return; }

    const optsProductos = '<option value="">— no importar esta línea —</option>' +
        iclProductos.map((p) => `<option value="${p.id}">${esc(p.sku || 's/SKU')} · ${esc(p.nombre)}</option>`).join('');
    const optsProveedores = '<option value="">Elige proveedor...</option>' +
        iclProveedores.map((p) => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');

    const coincidencias = iclFilas.filter((f) => f.productoId).length;

    cont.innerHTML = `
      <p class="text-xs text-slate-400 mb-2">Coincidieron ${coincidencias} de ${iclFilas.length} partida(s) con tu catálogo. Revisa las que no, elige el producto correcto (o desmárcalas), y confirma el proveedor en las que no se identificaron por RFC.</p>
      <div class="overflow-x-auto border border-slate-800 rounded-lg">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            <th class="p-2">Incluir</th><th class="p-2">Archivo / Proveedor</th><th class="p-2">Producto interno</th>
            <th class="p-2">SKU proveedor</th><th class="p-2">Descripción proveedor</th><th class="p-2">Unidad</th>
          </tr></thead>
          <tbody>
            ${iclFilas.map((f, i) => `
              <tr class="border-b border-slate-900 align-top" data-idx="${i}">
                <td class="p-2 text-center"><input type="checkbox" class="icl-chk accent-emerald-500 w-4 h-4" ${f.incluir ? 'checked' : ''}></td>
                <td class="p-2 text-slate-400 text-[11px]">
                  <span class="block text-slate-500">${esc(f.archivo)}</span>
                  ${f.proveedorId
                      ? `<span class="text-emerald-400">${esc(f.proveedorNombre)}</span>`
                      : `<select class="icl-proveedor-manual bg-slate-900 border border-amber-700 rounded px-1 py-0.5 text-[11px] text-slate-100 mt-0.5">${optsProveedores}</select>
                         <span class="block text-[10px] text-amber-400">RFC ${esc(f.rfcEmisor || '?')} no encontrado</span>`}
                </td>
                <td class="p-2">
                  <select class="icl-producto w-full bg-slate-900 border ${f.productoId ? 'border-slate-800' : 'border-amber-700'} rounded px-1.5 py-1 text-xs text-slate-100">${optsProductos}</select>
                  ${f.productoId && f.productoId !== f.productoIdAuto ? '<p class="text-[10px] text-emerald-400 mt-0.5">✓ homologado a mano</p>' : (f.productoId ? '<p class="text-[10px] text-emerald-400 mt-0.5">✓ coincide con el catálogo</p>' : '<p class="text-[10px] text-amber-400 mt-0.5">sin coincidencia</p>')}
                </td>
                <td class="p-2 font-mono text-slate-400">${esc(f.noId) || '—'}</td>
                <td class="p-2 text-slate-400">${esc(f.descripcion) || '—'}</td>
                <td class="p-2 text-slate-400">${esc(f.unidad) || '—'}</td>
              </tr>`).join('')}
          </tbody>
        </table>
      </div>
      <button type="button" id="iclGuardar" class="mt-3 w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">💾 Guardar claves de proveedor</button>
      <p id="iclMsgGuardar" class="text-xs mt-2 min-h-[1rem]"></p>
    `;

    cont.querySelectorAll('.icl-chk').forEach((chk) => {
        chk.onchange = () => { iclFilas[Number(chk.closest('tr').dataset.idx)].incluir = chk.checked; };
    });
    cont.querySelectorAll('.icl-producto').forEach((sel) => {
        const idx = Number(sel.closest('tr').dataset.idx);
        sel.value = iclFilas[idx].productoId || '';
        sel.onchange = () => {
            iclFilas[idx].productoId = sel.value ? Number(sel.value) : null;
            iclRenderTabla();
        };
    });
    cont.querySelectorAll('.icl-proveedor-manual').forEach((sel) => {
        const idx = Number(sel.closest('tr').dataset.idx);
        sel.onchange = () => {
            const pid = sel.value ? Number(sel.value) : null;
            iclFilas[idx].proveedorId = pid;
            iclFilas[idx].proveedorNombre = pid ? (iclProveedores.find((p) => p.id === pid)?.nombre || '') : '';
            iclRenderTabla();
        };
    });
    document.getElementById('iclGuardar').onclick = iclGuardarClaves;
}

async function iclGuardarClaves() {
    const msg = document.getElementById('iclMsgGuardar');
    const aGuardar = iclFilas.filter((f) => f.incluir && f.productoId && f.proveedorId);
    if (!aGuardar.length) {
        msg.textContent = 'No hay partidas listas para guardar — marca "Incluir" y asegúrate de que cada una tenga producto y proveedor.';
        msg.className = 'text-xs mt-2 text-rose-400';
        return;
    }

    const btn = document.getElementById('iclGuardar');
    btn.disabled = true;
    let ok = 0, fallos = 0;
    for (const f of aGuardar) {
        try {
            const { data: existente } = await supabaseClient.from('producto_claves_proveedor')
                .select('id').eq('producto_id', f.productoId).eq('proveedor_id', f.proveedorId).limit(1).maybeSingle();
            const payload = {
                clave: f.noId || null,
                clave_sat: f.claveSat || null,
                descripcion_factura: f.descripcion || null,
                unidad_factura: f.unidad || null,
            };
            if (existente) {
                const { error } = await supabaseClient.from('producto_claves_proveedor').update(payload).eq('id', existente.id);
                if (error) throw error;
            } else {
                const { error } = await supabaseClient.from('producto_claves_proveedor').insert([{ producto_id: f.productoId, proveedor_id: f.proveedorId, ...payload }]);
                if (error) throw error;
            }
            f._guardado = true;
            ok++;
        } catch (err) {
            f._guardado = false;
            fallos++;
        }
    }

    iclFilas = iclFilas.filter((f) => !f._guardado);
    iclRenderTabla();
    const msgFinal = document.getElementById('iclMsg');
    if (msgFinal) {
        msgFinal.textContent = `Guardadas ${ok} clave(s) de proveedor.` + (fallos ? ` ${fallos} con error — se quedan en la tabla para reintentar.` : '');
        msgFinal.className = 'text-xs min-h-[1rem] ' + (fallos ? 'text-amber-400' : 'text-emerald-400');
    }
}
