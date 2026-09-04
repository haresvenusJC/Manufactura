import { supabaseClient } from './supabase.js';
import { siguientePeriodoSugerido, nomAutorizar, nomCancelar, actualizarBannerNominaPendiente } from './nomina.js';

// =====================================================================
// Contabilidad · Tareas — bandeja de pendientes que requieren revisión
// humana. Dos orígenes:
//   1. Tareas persistentes de la tabla public.tareas (las genera el
//      sistema solo: hoy 'inventario_bajo_minimo'). Se pueden marcar
//      Atendida / No aceptada (posponer) / No aplica (archivar).
//   2. Señales calculadas al vuelo (nóminas en borrador, recordatorio
//      del viernes) que no viven en una tabla.
// Agregar un tipo nuevo = sumar un fetcher, no rediseñar la pantalla.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;

export async function cargarModuloTareas() {
    const cont = document.getElementById('contenedorTareas');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Cargando tareas...</p>`;

    try {
        const [sistema, borradores, recordatorio] = await Promise.all([
            fetchTareasSistema(),
            fetchNominasBorrador(),
            fetchRecordatorioViernes(),
        ]);

        if (sistema.length === 0 && borradores.length === 0 && !recordatorio) {
            cont.innerHTML = `<p class="text-emerald-400 text-sm">✔ No hay tareas pendientes.</p>`;
            return;
        }

        cont.innerHTML = `
            <div class="space-y-3">
                ${recordatorio ? renderRecordatorio(recordatorio) : ''}
                ${sistema.map(renderTareaSistema).join('')}
                ${borradores.map(renderNominaBorrador).join('')}
            </div>`;

        cont.querySelectorAll('.tarea-atender').forEach((b) => b.addEventListener('click', () => resolverTarea(b, 'atender', null, 'Marcada como atendida')));
        cont.querySelectorAll('.tarea-descartar').forEach((b) => b.addEventListener('click', () => {
            const d = prompt('¿En cuántos días quieres que vuelva a aparecer si sigue bajo el mínimo?', '7');
            if (d === null) return;
            resolverTarea(b, 'posponer', Math.max(1, parseInt(d, 10) || 7), 'No aceptada por el usuario');
        }));
        cont.querySelectorAll('.tarea-ir-oc').forEach((b) => b.addEventListener('click', () => {
            window.__ocPreProducto = {
                id: Number(b.dataset.prod),
                cantidad: b.dataset.sug ? parseFloat(b.dataset.sug) : null,
            };
            window.loadView('ordenes-compra');
        }));

        cont.querySelectorAll('.tarea-autorizar').forEach((b) => b.addEventListener('click', async () => {
            await nomAutorizar(Number(b.dataset.id), b);
            await cargarModuloTareas();
        }));
        cont.querySelectorAll('.tarea-cancelar').forEach((b) => b.addEventListener('click', async () => {
            await nomCancelar(Number(b.dataset.id));
            await cargarModuloTareas();
        }));
        cont.querySelectorAll('.tarea-ir-nomina').forEach((b) => b.addEventListener('click', () => window.loadView('nomina')));
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar tareas: ${err.message || err}</p>`;
    }
}

// --- Tareas persistentes (tabla public.tareas) --------------------------

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

async function resolverTarea(btn, accion, dias, nota) {
    btn.disabled = true;
    const { error } = await supabaseClient.rpc('tarea_resolver', {
        p_id: Number(btn.dataset.tarea),
        p_accion: accion,
        p_nota: nota || null,
        p_dias: dias ?? null,
    });
    if (error) {
        alert('No se pudo actualizar la tarea: ' + (error.message || error));
        btn.disabled = false;
        return;
    }
    await cargarModuloTareas();
}

function renderTareaSistema(t) {
    const chip = t.prioridad === 1
        ? '<span class="text-[10px] bg-rose-900/60 text-rose-300 border border-rose-700 rounded px-1.5 py-0.5">Alta</span>'
        : t.prioridad === 3
            ? '<span class="text-[10px] bg-slate-800 text-slate-400 border border-slate-700 rounded px-1.5 py-0.5">Baja</span>'
            : '<span class="text-[10px] bg-amber-900/50 text-amber-300 border border-amber-700 rounded px-1.5 py-0.5">Normal</span>';
    const sug = t.datos && t.datos.sugerido_pedir != null ? t.datos.sugerido_pedir : '';
    const botonOc = t.accion_sugerida === 'crear_orden_compra' && t.entidad_id
        ? `<button type="button" data-prod="${t.entidad_id}" data-sug="${sug}" class="tarea-ir-oc text-xs bg-emerald-700 hover:bg-emerald-600 text-emerald-100 px-3 py-1.5 rounded-lg border border-emerald-600 cursor-pointer">🛒 Crear orden de compra</button>`
        : '';
    const revivida = t.estatus === 'pospuesta'
        ? `<p class="text-[11px] text-sky-400/80">Reapareció: venció el aplazamiento y sigue bajo el mínimo.</p>` : '';
    return `
        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 space-y-2">
            <div class="flex items-start justify-between flex-wrap gap-2">
                <div class="min-w-0">
                    <p class="text-sm text-slate-200 font-semibold flex items-center gap-2">${chip} ${esc(t.titulo)}</p>
                    ${t.detalle ? `<p class="text-[11px] text-slate-500 mt-0.5">${esc(t.detalle)}</p>` : ''}
                    ${revivida}
                </div>
                <div class="flex gap-2 flex-wrap justify-end shrink-0">
                    ${botonOc}
                    <button type="button" data-tarea="${t.id}" class="tarea-atender text-xs bg-amber-800 hover:bg-amber-700 text-amber-100 px-3 py-1.5 rounded-lg border border-amber-600 cursor-pointer">✔ Atendida</button>
                    <button type="button" data-tarea="${t.id}" class="tarea-descartar text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">✕ No aceptada</button>
                </div>
            </div>
        </div>`;
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

function renderRecordatorio(sugerido) {
    return `
        <div class="bg-amber-950/40 border border-amber-700 rounded-lg p-3 flex items-center justify-between gap-3">
            <div>
                <p class="text-sm text-amber-200 font-semibold">📋 Semana del ${sugerido.inicio} al ${sugerido.fin} lista para pre-ejecutar</p>
                <p class="text-[11px] text-amber-300/80">Ya es viernes de esa semana y todavía no se ha pre-ejecutado (a mano ni por la tarea automática de Supabase).</p>
            </div>
            <button type="button" class="tarea-ir-nomina shrink-0 text-xs bg-amber-800 hover:bg-amber-700 text-amber-100 px-3 py-1.5 rounded-lg border border-amber-600 cursor-pointer">Ir a Nómina</button>
        </div>`;
}

function renderNominaBorrador(n) {
    return `
        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 space-y-2">
            <div class="flex items-center justify-between flex-wrap gap-2">
                <div>
                    <p class="text-sm text-slate-200 font-semibold">⏳ Nómina #${n.id} — semana del ${n.periodo_inicio} al ${n.periodo_fin}</p>
                    <p class="text-[11px] text-slate-500">Fecha de pago ${n.fecha_pago} · Condición: ${n.condicion === 'contado' ? 'Contado' : 'Crédito (por pagar)'}</p>
                </div>
                <div class="flex gap-2">
                    <button type="button" data-id="${n.id}" class="tarea-autorizar text-xs bg-amber-800 hover:bg-amber-700 text-amber-100 px-3 py-1.5 rounded-lg border border-amber-600 cursor-pointer">✔ Autorizar</button>
                    <button type="button" data-id="${n.id}" class="tarea-cancelar text-xs bg-slate-800 hover:bg-slate-700 text-rose-300 px-3 py-1.5 rounded-lg border border-slate-700 cursor-pointer">Cancelar</button>
                </div>
            </div>
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 text-[11px]">
                <div class="bg-slate-900 rounded p-2"><span class="text-slate-500 block">Subtotal</span><span class="font-mono text-slate-200">${money(n.subtotal)}</span></div>
                <div class="bg-slate-900 rounded p-2"><span class="text-slate-500 block">ISR retenido</span><span class="font-mono text-slate-200">${money(n.isr_retenido)}</span></div>
                <div class="bg-slate-900 rounded p-2"><span class="text-slate-500 block">Cuotas IMSS/INFONAVIT</span><span class="font-mono text-slate-200">${money(n.cuotas_imss)}</span></div>
                <div class="bg-slate-900 rounded p-2"><span class="text-slate-500 block">Total</span><span class="font-mono text-emerald-400 font-semibold">${money(n.total)}</span></div>
            </div>
        </div>`;
}
