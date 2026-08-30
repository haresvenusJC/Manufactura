import { supabaseClient } from './supabase.js';
import { siguientePeriodoSugerido, nomAutorizar, nomCancelar, actualizarBannerNominaPendiente } from './nomina.js';

// =====================================================================
// Contabilidad · Tareas — bandeja de pendientes que requieren revisión
// humana antes de que algo se contabilice. Por ahora solo hay un tipo
// (nóminas en borrador esperando autorización), pero está pensada para
// crecer: cada tarea es un objeto { tipo, titulo, detalle, acciones },
// así que agregar un tipo nuevo a futuro es sumar un fetcher, no
// rediseñar la pantalla.
// =====================================================================

const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const hoyISO = () => new Date().toISOString().slice(0, 10);

export async function cargarModuloTareas() {
    const cont = document.getElementById('contenedorTareas');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Cargando tareas...</p>`;

    try {
        const [borradores, recordatorio] = await Promise.all([
            fetchNominasBorrador(),
            fetchRecordatorioViernes(),
        ]);

        if (borradores.length === 0 && !recordatorio) {
            cont.innerHTML = `<p class="text-emerald-400 text-sm">✔ No hay tareas pendientes. Todo lo que se ha pre-ejecutado ya está autorizado.</p>`;
            return;
        }

        cont.innerHTML = `
            <div class="space-y-3">
                ${recordatorio ? renderRecordatorio(recordatorio) : ''}
                ${borradores.map(renderNominaBorrador).join('')}
            </div>`;

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
