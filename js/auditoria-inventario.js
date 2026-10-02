import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';

// =====================================================================
//  Auditoría de inventarios (toma física) — lado ADMIN.
//  Crea auditorías, revisa el avance y el resultado (contado vs.
//  sistema, con la diferencia), y cierra/reabre la captura.
//  La captura en sí la hace el operador desde conteo-inventario.html
//  (PIN de 4 dígitos, conteo a ciegas — nunca ve el stock del sistema).
//  Requiere: sql/2026-09-14f_auditoria_inventarios.sql
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const num = (n, d = 4) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: d });
const TABLA_FALTA = /does not exist|schema cache|could not find/i;
const TIPO_LABEL = { producto: 'Producto terminado', semiterminado: 'Semiterminado', materia_prima: 'Materia prima', insumo: 'Insumo' };

let auditActual = null;      // { id, nombre } de la que se está revisando
let resultadoCache = [];
const resOrden = crearOrdenTabla('diferencia');
let audSeleccionMap = new Map();   // producto_id -> { nombre, sku } — elegidos a mano por SKU/nombre

export async function cargarModuloAuditoriaInventario() {
    const cont = document.getElementById('contenedorAuditoria');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';

    cont.innerHTML = `
      <div class="space-y-4">
        <div class="bg-amber-950/30 border border-amber-800 rounded-xl p-3 text-xs text-amber-200">
          Los operadores capturan el conteo desde <a href="conteo-inventario.html" target="_blank" class="underline font-semibold">conteo-inventario.html</a> — se identifican con nombre + PIN de 4 dígitos (el mismo de Orden de Trabajo) y nunca ven el stock del sistema (conteo a ciegas).
        </div>

        <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-md font-semibold text-slate-300">Nueva auditoría</h3>
            <button type="button" id="audToggleForm" class="text-xs text-sky-400">+ Nueva</button>
          </div>
          <form id="audForm" class="hidden space-y-3">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div><label class="block text-xs text-slate-400 mb-1">Nombre <span class="text-rose-400">*</span></label>
                <input type="text" id="audNombre" placeholder="Ej. Inventario general septiembre 2026" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required></div>
              <div><label class="block text-xs text-slate-400 mb-1">Notas</label>
                <input type="text" id="audNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
            </div>
            <div>
              <label class="block text-xs text-slate-400 mb-1">Incluir productos del catálogo por tipo</label>
              <div class="flex flex-wrap gap-3 bg-slate-900 border border-slate-800 rounded-lg p-3">
                <label class="flex items-center gap-1.5 text-xs text-slate-300"><input type="checkbox" id="audTipoProducto" class="accent-sky-500"> Producto terminado</label>
                <label class="flex items-center gap-1.5 text-xs text-slate-300"><input type="checkbox" id="audTipoSemi" class="accent-sky-500"> Semiterminado</label>
                <label class="flex items-center gap-1.5 text-xs text-slate-300"><input type="checkbox" id="audTipoMateria" class="accent-sky-500"> Materia prima</label>
                <label class="flex items-center gap-1.5 text-xs text-slate-300"><input type="checkbox" id="audTipoInsumo" class="accent-sky-500"> Insumo</label>
                <label class="flex items-center gap-1.5 text-xs text-slate-300 ml-auto"><input type="checkbox" id="audSoloActivos" class="accent-sky-500" checked> Solo activos</label>
              </div>
            </div>
            <div class="relative">
              <label class="block text-xs text-slate-400 mb-1">Elegir productos puntuales por SKU o nombre</label>
              <input type="text" id="audBuscarSku" autocomplete="off" placeholder="Escribe un SKU o nombre..." class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <div id="audSugerencias" class="hidden absolute left-0 right-0 top-full mt-1 bg-slate-900 border border-slate-800 rounded-lg shadow-2xl max-h-48 overflow-y-auto z-20"></div>
              <div id="audSeleccionados" class="flex flex-wrap gap-1.5 mt-2"></div>
            </div>
            <div>
              <label class="block text-xs text-slate-400 mb-1">Renglones libres (sin catálogo — equipo, mobiliario, etc.), uno por línea</label>
              <textarea id="audLibres" rows="3" placeholder="Ej. Báscula de piso&#10;Montacargas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></textarea>
            </div>
            <p id="audMsg" class="text-xs min-h-[1rem]"></p>
            <button type="submit" id="audCrear" class="bg-sky-600 hover:bg-sky-500 text-white font-medium px-5 py-2.5 rounded-lg text-sm">Crear auditoría</button>
          </form>
        </div>

        <div>
          <h3 class="text-md font-semibold text-slate-300 mb-2">Auditorías</h3>
          <div id="audLista" class="space-y-2"><p class="text-slate-500 text-sm">Cargando...</p></div>
        </div>

        <div id="audResultadoWrap" class="hidden">
          <h3 class="text-md font-semibold text-slate-300 mb-2">Resultado — <span id="audResultadoNombre"></span></h3>
          <div id="audResultado" class="bg-slate-950 border border-slate-800 rounded-xl p-3"></div>
        </div>
      </div>`;

    document.getElementById('audToggleForm').addEventListener('click', () => {
        document.getElementById('audForm').classList.toggle('hidden');
    });
    document.getElementById('audForm').addEventListener('submit', crearAuditoria);
    audSeleccionMap = new Map();
    wireBuscadorSku();
    pintarSeleccionados();

    await pintarListaAuditorias();
}

// ---- Buscador de SKU/nombre para elegir productos puntuales ----
function wireBuscadorSku() {
    const input = document.getElementById('audBuscarSku');
    const sug = document.getElementById('audSugerencias');
    if (!input || !sug) return;

    let timer = null;
    input.addEventListener('input', () => {
        clearTimeout(timer);
        const q = input.value.trim();
        if (q.length < 2) { sug.classList.add('hidden'); sug.innerHTML = ''; return; }
        timer = setTimeout(async () => {
            const { data, error } = await supabaseClient
                .from('productos')
                .select('id, nombre, sku, tipo')
                .or(`nombre.ilike.%${q}%,sku.ilike.%${q}%`)
                .limit(8);
            if (error || !data || !data.length) {
                sug.innerHTML = '<div class="p-2.5 text-xs text-slate-500">Sin coincidencias.</div>';
                sug.classList.remove('hidden');
                return;
            }
            sug.innerHTML = data.map((p) => `
                <div class="aud-sug p-2.5 hover:bg-slate-800 border-b border-slate-800 last:border-0 cursor-pointer" data-id="${p.id}" data-nombre="${esc(p.nombre)}" data-sku="${esc(p.sku || '')}">
                    <div class="text-xs font-semibold text-slate-100">${esc(p.nombre)}</div>
                    <div class="text-[11px] text-slate-500 font-mono">${esc(p.sku || 's/SKU')} · ${TIPO_LABEL[p.tipo] || p.tipo || ''}</div>
                </div>`).join('');
            sug.classList.remove('hidden');
            sug.querySelectorAll('.aud-sug').forEach((el) => {
                el.addEventListener('click', () => {
                    audSeleccionMap.set(Number(el.dataset.id), { nombre: el.dataset.nombre, sku: el.dataset.sku });
                    pintarSeleccionados();
                    input.value = '';
                    sug.classList.add('hidden');
                    sug.innerHTML = '';
                });
            });
        }, 250);
    });
    document.addEventListener('click', (e) => {
        if (!input.contains(e.target) && !sug.contains(e.target)) sug.classList.add('hidden');
    });
}

function pintarSeleccionados() {
    const cont = document.getElementById('audSeleccionados');
    if (!cont) return;
    if (!audSeleccionMap.size) { cont.innerHTML = ''; return; }
    cont.innerHTML = [...audSeleccionMap.entries()].map(([id, p]) => `
        <span class="inline-flex items-center gap-1.5 bg-sky-950/50 border border-sky-800 text-sky-300 text-[11px] px-2 py-1 rounded-full">
            ${esc(p.nombre)}${p.sku ? ` <span class="text-sky-500 font-mono">(${esc(p.sku)})</span>` : ''}
            <button type="button" class="aud-quitar-sel text-sky-400 hover:text-white" data-id="${id}">✕</button>
        </span>`).join('');
    cont.querySelectorAll('.aud-quitar-sel').forEach((b) => {
        b.addEventListener('click', () => { audSeleccionMap.delete(Number(b.dataset.id)); pintarSeleccionados(); });
    });
}

async function pintarListaAuditorias() {
    const cont = document.getElementById('audLista');
    try {
        const { data, error } = await supabaseClient
            .from('auditorias_inventario')
            .select('*')
            .order('created_at', { ascending: false });
        if (error) throw error;

        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Todavía no hay ninguna auditoría.</p>'; return; }

        // avance por auditoría (items totales / con al menos un conteo)
        const { data: items } = await supabaseClient.from('auditoria_items').select('id, auditoria_id');
        const { data: conteos } = await supabaseClient.from('auditoria_conteos').select('item_id');
        const itemsPorAud = new Map();
        (items || []).forEach((it) => {
            if (!itemsPorAud.has(it.auditoria_id)) itemsPorAud.set(it.auditoria_id, new Set());
            itemsPorAud.get(it.auditoria_id).add(it.id);
        });
        const itemsConConteo = new Set((conteos || []).map((c) => c.item_id));

        const ESTATUS_BADGE = {
            abierta: 'text-emerald-400 bg-emerald-950/40 border-emerald-800',
            cerrada: 'text-slate-400 bg-slate-800 border-slate-700',
            cancelada: 'text-rose-400 bg-rose-950/40 border-rose-800',
        };

        cont.innerHTML = data.map((a) => {
            const idsItems = itemsPorAud.get(a.id) || new Set();
            const totalItems = idsItems.size;
            const contados = [...idsItems].filter((id) => itemsConConteo.has(id)).length;
            return `
            <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 flex flex-wrap items-center justify-between gap-3">
              <div>
                <div class="flex items-center gap-2">
                  <span class="font-semibold text-slate-100">${esc(a.nombre)}</span>
                  <span class="text-[10px] px-2 py-0.5 rounded-full border ${ESTATUS_BADGE[a.estatus] || ''}">${a.estatus}</span>
                </div>
                <div class="text-xs text-slate-500 mt-1">${a.fecha} · ${contados}/${totalItems} renglones con captura${a.notas ? ' · ' + esc(a.notas) : ''}</div>
              </div>
              <div class="flex gap-2">
                <button type="button" class="aud-ver text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg" data-id="${a.id}" data-nombre="${esc(a.nombre)}">Ver resultado</button>
                ${a.estatus === 'abierta' ? `<button type="button" class="aud-cerrar text-xs bg-amber-800 hover:bg-amber-700 text-amber-100 border border-amber-600 px-3 py-1.5 rounded-lg" data-id="${a.id}">Cerrar captura</button>` : ''}
                ${a.estatus === 'cerrada' ? `<button type="button" class="aud-reabrir text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 px-3 py-1.5 rounded-lg" data-id="${a.id}">Reabrir</button>` : ''}
              </div>
            </div>`;
        }).join('');

        cont.querySelectorAll('.aud-ver').forEach((b) => b.addEventListener('click', () => verResultado(Number(b.dataset.id), b.dataset.nombre)));
        cont.querySelectorAll('.aud-cerrar').forEach((b) => b.addEventListener('click', async () => {
            if (!confirm('¿Cerrar la captura de esta auditoría? Los operadores ya no podrán agregar más conteos (se puede reabrir después).')) return;
            const { error } = await supabaseClient.rpc('cerrar_auditoria_inventario', { p_auditoria_id: Number(b.dataset.id) });
            if (error) { alert('No se pudo cerrar: ' + error.message); return; }
            await pintarListaAuditorias();
        }));
        cont.querySelectorAll('.aud-reabrir').forEach((b) => b.addEventListener('click', async () => {
            const { error } = await supabaseClient.rpc('reabrir_auditoria_inventario', { p_auditoria_id: Number(b.dataset.id) });
            if (error) { alert('No se pudo reabrir: ' + error.message); return; }
            await pintarListaAuditorias();
        }));
    } catch (err) {
        const m = err?.message || String(err);
        cont.innerHTML = TABLA_FALTA.test(m)
            ? '<p class="text-amber-400 text-xs">Falta correr <span class="font-mono">sql/2026-09-14f_auditoria_inventarios.sql</span> en Supabase.</p>'
            : `<p class="text-rose-400 text-xs">Error: ${esc(m)}</p>`;
    }
}

async function crearAuditoria(e) {
    e.preventDefault();
    const msg = document.getElementById('audMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';

    const nombre = document.getElementById('audNombre').value.trim();
    if (!nombre) { msg.textContent = 'El nombre es obligatorio.'; msg.className = 'text-xs text-rose-400'; return; }

    const tipos = [];
    if (document.getElementById('audTipoProducto').checked) tipos.push('producto');
    if (document.getElementById('audTipoSemi').checked) tipos.push('semiterminado');
    if (document.getElementById('audTipoMateria').checked) tipos.push('materia_prima');
    if (document.getElementById('audTipoInsumo').checked) tipos.push('insumo');
    const libres = document.getElementById('audLibres').value.split('\n').map((s) => s.trim()).filter(Boolean);
    const idsPuntuales = [...audSeleccionMap.keys()];

    if (!tipos.length && !libres.length && !idsPuntuales.length) {
        msg.textContent = 'Marca al menos un tipo de producto, elige productos puntuales, o agrega un renglón libre.';
        msg.className = 'text-xs text-rose-400';
        return;
    }

    const btn = document.getElementById('audCrear');
    btn.disabled = true;
    try {
        const idsSet = new Set(idsPuntuales);
        if (tipos.length) {
            let q = supabaseClient.from('productos').select('id').in('tipo', tipos);
            if (document.getElementById('audSoloActivos').checked) q = q.eq('activo', true);
            const { data, error } = await q;
            if (error) throw error;
            (data || []).forEach((p) => idsSet.add(p.id));
        }

        const { data, error } = await supabaseClient.rpc('crear_auditoria_inventario', {
            p_datos: { nombre, notas: document.getElementById('audNotas').value.trim() || null, producto_ids: [...idsSet], libres },
        });
        if (error) throw error;

        alert(`Auditoría creada con ${data.items} renglón(es) a contar.`);
        document.getElementById('audForm').reset();
        document.getElementById('audForm').classList.add('hidden');
        document.getElementById('audSoloActivos').checked = true;
        audSeleccionMap = new Map();
        pintarSeleccionados();
        await pintarListaAuditorias();
    } catch (err) {
        msg.textContent = 'No se pudo crear: ' + (err.message || err);
        msg.className = 'text-xs text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

async function verResultado(auditoriaId, nombre) {
    auditActual = { id: auditoriaId, nombre };
    const wrap = document.getElementById('audResultadoWrap');
    const cont = document.getElementById('audResultado');
    wrap.classList.remove('hidden');
    document.getElementById('audResultadoNombre').textContent = nombre;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    wrap.scrollIntoView({ behavior: 'smooth', block: 'start' });

    try {
        const { data, error } = await supabaseClient
            .from('v_auditoria_resultado')
            .select('*')
            .eq('auditoria_id', auditoriaId);
        if (error) throw error;
        resultadoCache = data || [];
        pintarResultado();
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

function pintarResultado() {
    const cont = document.getElementById('audResultado');
    if (!resultadoCache.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Esta auditoría no tiene renglones.</p>'; return; }

    aplicarOrden(resOrden, resultadoCache, (r, campo) => {
        switch (campo) {
            case 'descripcion': return (r.descripcion || '').toLowerCase();
            case 'sistema': return Number(r.stock_sistema || 0);
            case 'contado': return Number(r.contado || 0);
            case 'diferencia': return Math.abs(Number(r.diferencia || 0));
            case 'capturas': return Number(r.num_capturas || 0);
            default: return r.item_id;
        }
    });

    const totalDif = resultadoCache.reduce((a, r) => a + Math.abs(Number(r.diferencia || 0)), 0);

    cont.innerHTML = `
      <p class="text-[11px] text-slate-500 mb-2">${resultadoCache.length} renglón(es) · suma de diferencias absolutas: <span class="font-mono text-amber-300">${num(totalDif, 2)}</span></p>
      <div class="overflow-x-auto border border-slate-800 rounded-lg">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
            ${thOrden(resOrden, 'descripcion', 'Descripción')}
            ${thOrden(resOrden, 'sistema', 'Sistema', 'text-right justify-end')}
            ${thOrden(resOrden, 'contado', 'Contado', 'text-right justify-end')}
            ${thOrden(resOrden, 'diferencia', 'Diferencia', 'text-right justify-end')}
            ${thOrden(resOrden, 'capturas', '# Capturas', 'text-center justify-center')}
            <th class="p-2"></th>
          </tr></thead>
          <tbody>
            ${resultadoCache.map((r) => {
                const dif = Number(r.diferencia || 0);
                const claseDif = dif === 0 ? 'text-slate-400' : dif > 0 ? 'text-emerald-400' : 'text-rose-400';
                return `
                <tr class="border-b border-slate-900">
                  <td class="p-2 text-slate-100">${esc(r.descripcion)}${r.sku ? ` <span class="text-slate-500 font-mono">(${esc(r.sku)})</span>` : ''}</td>
                  <td class="p-2 text-right font-mono">${num(r.stock_sistema)}</td>
                  <td class="p-2 text-right font-mono">${num(r.contado)}</td>
                  <td class="p-2 text-right font-mono ${claseDif}">${dif > 0 ? '+' : ''}${num(dif)}</td>
                  <td class="p-2 text-center font-mono text-slate-400">${r.num_capturas}</td>
                  <td class="p-2 text-right"><button type="button" class="ver-capturas text-[11px] text-sky-400 hover:underline" data-id="${r.item_id}">Ver capturas</button></td>
                </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>
      <div id="audCapturasDetalle" class="mt-3"></div>`;

    wireOrdenTabla(cont, resOrden, pintarResultado);
    cont.querySelectorAll('.ver-capturas').forEach((b) => b.addEventListener('click', () => verCapturasItem(Number(b.dataset.id))));
}

async function verCapturasItem(itemId) {
    const det = document.getElementById('audCapturasDetalle');
    if (!det) return;
    det.innerHTML = '<p class="text-slate-500 text-xs">Cargando capturas...</p>';
    try {
        const { data, error } = await supabaseClient
            .from('auditoria_conteos')
            .select('id, cantidad, tipo_captura, piezas_por_caja, cantidad_equivalente, nota, fecha_caducidad, capturado_en, empleados ( nombre )')
            .eq('item_id', itemId)
            .order('capturado_en', { ascending: false });
        if (error) throw error;
        if (!data || !data.length) { det.innerHTML = '<p class="text-slate-500 text-xs">Sin capturas.</p>'; return; }

        det.innerHTML = `
          <div class="border border-slate-800 rounded-lg overflow-hidden">
            <table class="w-full text-left text-[11px] text-slate-300">
              <thead class="bg-slate-900 text-slate-500 uppercase"><tr>
                <th class="p-1.5">Hora</th><th class="p-1.5">Operador</th><th class="p-1.5">Captura</th>
                <th class="p-1.5 text-right">Equivalente</th><th class="p-1.5">Caducidad</th><th class="p-1.5">Nota</th>
              </tr></thead>
              <tbody>
                ${data.map((c) => `
                  <tr class="border-b border-slate-900">
                    <td class="p-1.5 whitespace-nowrap">${new Date(c.capturado_en).toLocaleString('es-MX')}</td>
                    <td class="p-1.5">${esc(c.empleados?.nombre || '—')}</td>
                    <td class="p-1.5">${c.cantidad} ${c.tipo_captura === 'caja' ? `caja(s) × ${c.piezas_por_caja}` : 'pieza(s)'}</td>
                    <td class="p-1.5 text-right font-mono">${num(c.cantidad_equivalente)}</td>
                    <td class="p-1.5 ${c.fecha_caducidad ? 'text-amber-400' : 'text-slate-600'}">${esc(c.fecha_caducidad || '—')}</td>
                    <td class="p-1.5 text-slate-400">${esc(c.nota || '')}</td>
                  </tr>`).join('')}
              </tbody>
            </table>
          </div>`;
    } catch (err) {
        det.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}
