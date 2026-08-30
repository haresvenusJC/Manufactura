import { supabaseClient } from './supabase.js';

// =====================================================================
// Contabilidad · Tabla ISR — catálogo versionado de tarifas de retención
// de ISR sobre sueldos (Art. 96 LISR). Cada versión queda guardada con
// su fecha de vigencia y fuente; nunca se sobreescribe, así que una
// nómina vieja siempre queda ligada a la tabla que estaba vigente
// cuando se calculó. El cálculo en sí lo hace el RPC calcular_isr_nomina
// (ver sql/2026-08-30_contabilidad_isr.sql) — este módulo solo captura
// y muestra las tarifas.
// =====================================================================

const hoyISO = () => new Date().toISOString().slice(0, 10);

let isrTramos = []; // [{ limite_inferior, limite_superior, cuota_fija, porcentaje }]

const TRAMO_VACIO = () => ({ limite_inferior: '', limite_superior: '', cuota_fija: '', porcentaje: '' });

export async function cargarModuloIsr() {
    const cont = document.getElementById('contenedorIsr');
    if (!cont) return;

    cont.innerHTML = `
    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Formulario -->
        <div class="bg-slate-950 border border-slate-800 p-4 rounded-xl space-y-3">
            <h3 class="text-md font-semibold text-sky-400">Nueva tabla ISR</h3>
            <p class="text-[11px] text-slate-500">Súbela cada vez que el SAT publique una nueva (normalmente a fines de diciembre, en el Anexo 8 de la Resolución Miscelánea Fiscal). No se sobreescribe la anterior — cada nómina queda ligada a la que estaba vigente cuando se calculó.</p>
            <form id="isrForm" class="space-y-3">
                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Vigente desde</label>
                    <input type="date" id="isrVigenteDesde" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                </div>
                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Fuente</label>
                    <input type="text" id="isrFuente" placeholder="Ej. Anexo 8 RMF 2026, DOF 28/12/2025" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                </div>

                <div class="flex items-center justify-between">
                    <label class="text-[11px] text-slate-400">Tramos (tarifa mensual)</label>
                    <div class="flex gap-2">
                        <button type="button" id="isrDuplicar" class="text-[10px] text-sky-400 hover:underline">Duplicar última versión</button>
                        <button type="button" id="isrAgregarTramo" class="text-[10px] text-emerald-400 hover:underline">+ Renglón</button>
                    </div>
                </div>
                <div class="border border-slate-800 rounded-lg overflow-hidden overflow-x-auto">
                    <table class="w-full text-[11px]">
                        <thead class="bg-slate-900 text-slate-400 uppercase">
                            <tr>
                                <th class="p-1.5 text-right">Límite inf.</th>
                                <th class="p-1.5 text-right">Límite sup.</th>
                                <th class="p-1.5 text-right">Cuota fija</th>
                                <th class="p-1.5 text-right">%</th>
                                <th class="p-1.5 w-6"></th>
                            </tr>
                        </thead>
                        <tbody id="isrTramosBody"></tbody>
                    </table>
                </div>
                <p class="text-[10px] text-slate-500">Deja "Límite sup." vacío en el último renglón (sin tope).</p>

                <button type="submit" id="isrGuardar" class="w-full bg-sky-600 hover:bg-sky-500 text-white font-medium py-2.5 rounded-lg text-sm transition cursor-pointer">Guardar tabla</button>
                <p id="isrMsg" class="text-xs min-h-[1rem]"></p>
            </form>
        </div>

        <!-- Historial -->
        <div class="xl:col-span-2 space-y-3">
            <h3 class="text-md font-semibold text-sky-400">Versiones cargadas</h3>
            <div id="isrLista" class="bg-slate-950 border border-slate-800 rounded-xl p-4 text-sm text-slate-500">Cargando...</div>
        </div>
    </div>`;

    document.getElementById('isrVigenteDesde').value = hoyISO();
    isrTramos = Array.from({ length: 11 }, TRAMO_VACIO);
    renderTramos();

    document.getElementById('isrAgregarTramo').addEventListener('click', () => {
        isrTramos.push(TRAMO_VACIO());
        renderTramos();
    });
    document.getElementById('isrDuplicar').addEventListener('click', duplicarUltimaVersion);
    document.getElementById('isrForm').addEventListener('submit', isrGuardar);

    await isrBuscar();
}

function renderTramos() {
    const body = document.getElementById('isrTramosBody');
    if (!body) return;

    body.innerHTML = isrTramos.map((t, i) => `
        <tr class="border-t border-slate-800">
            <td class="p-1"><input type="number" step="0.01" min="0" class="isr-t w-full bg-slate-900 border border-slate-800 rounded p-1 text-right font-mono text-slate-100" data-i="${i}" data-f="limite_inferior" value="${t.limite_inferior}"></td>
            <td class="p-1"><input type="number" step="0.01" min="0" class="isr-t w-full bg-slate-900 border border-slate-800 rounded p-1 text-right font-mono text-slate-100" data-i="${i}" data-f="limite_superior" value="${t.limite_superior}" placeholder="sin tope"></td>
            <td class="p-1"><input type="number" step="0.01" min="0" class="isr-t w-full bg-slate-900 border border-slate-800 rounded p-1 text-right font-mono text-slate-100" data-i="${i}" data-f="cuota_fija" value="${t.cuota_fija}"></td>
            <td class="p-1"><input type="number" step="0.001" min="0" class="isr-t w-full bg-slate-900 border border-slate-800 rounded p-1 text-right font-mono text-slate-100" data-i="${i}" data-f="porcentaje" value="${t.porcentaje}"></td>
            <td class="p-1 text-center">
                <button type="button" class="isr-del text-rose-400 hover:text-rose-300" data-i="${i}" title="Quitar renglón">✕</button>
            </td>
        </tr>
    `).join('');

    body.querySelectorAll('.isr-t').forEach((el) => {
        el.addEventListener('input', (e) => {
            const i = Number(e.target.dataset.i);
            const f = e.target.dataset.f;
            if (isrTramos[i]) isrTramos[i][f] = e.target.value;
        });
    });
    body.querySelectorAll('.isr-del').forEach((btn) => {
        btn.addEventListener('click', () => {
            isrTramos.splice(Number(btn.dataset.i), 1);
            renderTramos();
        });
    });
}

async function duplicarUltimaVersion() {
    const msg = document.getElementById('isrMsg');
    try {
        const { data: ultima, error: errUltima } = await supabaseClient
            .from('isr_tarifas')
            .select('id, fuente')
            .order('vigente_desde', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (errUltima) throw errUltima;
        if (!ultima) { msg.textContent = 'No hay ninguna versión previa que duplicar.'; msg.className = 'text-xs text-amber-400'; return; }

        const { data: tramos, error: errTramos } = await supabaseClient
            .from('isr_tarifa_tramos')
            .select('limite_inferior, limite_superior, cuota_fija, porcentaje')
            .eq('tarifa_id', ultima.id)
            .order('orden');
        if (errTramos) throw errTramos;

        document.getElementById('isrFuente').value = ultima.fuente || '';
        isrTramos = (tramos && tramos.length ? tramos : Array.from({ length: 11 }, TRAMO_VACIO))
            .map((t) => ({
                limite_inferior: t.limite_inferior ?? '',
                limite_superior: t.limite_superior ?? '',
                cuota_fija: t.cuota_fija ?? '',
                porcentaje: t.porcentaje ?? '',
            }));
        renderTramos();
        msg.textContent = 'Se copiaron los tramos de la última versión — ajusta los montos y guarda.';
        msg.className = 'text-xs text-emerald-400';
    } catch (err) {
        msg.textContent = 'No se pudo duplicar: ' + (err.message || err);
        msg.className = 'text-xs text-rose-400';
    }
}

async function isrGuardar(e) {
    e.preventDefault();
    const msg = document.getElementById('isrMsg');
    msg.textContent = ''; msg.className = 'text-xs min-h-[1rem]';

    const vigenteDesde = document.getElementById('isrVigenteDesde').value;
    const fuente = document.getElementById('isrFuente').value.trim() || null;

    const tramosValidos = isrTramos
        .filter((t) => t.limite_inferior !== '' && t.porcentaje !== '')
        .map((t, i) => ({
            orden: i + 1,
            limite_inferior: parseFloat(t.limite_inferior) || 0,
            limite_superior: t.limite_superior === '' ? null : parseFloat(t.limite_superior),
            cuota_fija: parseFloat(t.cuota_fija) || 0,
            porcentaje: parseFloat(t.porcentaje) || 0,
        }));

    if (!vigenteDesde) {
        msg.textContent = 'La fecha de vigencia es obligatoria.'; msg.className = 'text-xs text-rose-400'; return;
    }
    if (tramosValidos.length === 0) {
        msg.textContent = 'Captura al menos un tramo (límite inferior y %).'; msg.className = 'text-xs text-rose-400'; return;
    }

    try {
        document.getElementById('isrGuardar').disabled = true;

        const { data: tarifa, error: errTarifa } = await supabaseClient
            .from('isr_tarifas')
            .insert([{ vigente_desde: vigenteDesde, fuente }])
            .select('id')
            .single();
        if (errTarifa) throw errTarifa;

        const { error: errTramos } = await supabaseClient
            .from('isr_tarifa_tramos')
            .insert(tramosValidos.map((t) => ({ ...t, tarifa_id: tarifa.id })));
        if (errTramos) throw errTramos;

        msg.textContent = `Tabla ISR guardada (vigente desde ${vigenteDesde}, ${tramosValidos.length} tramo(s)).`;
        msg.className = 'text-xs text-emerald-400';
        await isrBuscar();
    } catch (err) {
        msg.textContent = err.message || String(err);
        msg.className = 'text-xs text-rose-400';
    } finally {
        document.getElementById('isrGuardar').disabled = false;
    }
}

async function isrBuscar() {
    const cont = document.getElementById('isrLista');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500">Cargando...</p>`;
    try {
        const { data, error } = await supabaseClient
            .from('isr_tarifas')
            .select('id, vigente_desde, fuente, created_at, isr_tarifa_tramos(id)')
            .order('vigente_desde', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(100);
        if (error) throw error;

        if (!data || data.length === 0) {
            cont.innerHTML = `<p class="text-slate-400 text-sm">Todavía no hay ninguna tabla ISR cargada — mientras tanto, la Nómina calcula el ISR en $0.00.</p>`;
            return;
        }

        const hoy = hoyISO();
        const vigenteId = data.find((t) => t.vigente_desde <= hoy)?.id;

        cont.innerHTML = `
            <div class="overflow-x-auto border border-slate-800 rounded-lg">
                <table class="w-full text-left text-xs text-slate-300">
                    <thead class="bg-slate-900 text-slate-400 uppercase border-b border-slate-800">
                        <tr><th class="p-2">Vigente desde</th><th class="p-2">Fuente</th><th class="p-2 text-right">Tramos</th><th class="p-2">Estatus</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((t) => `
                            <tr class="border-b border-slate-900">
                                <td class="p-2 whitespace-nowrap">${t.vigente_desde}</td>
                                <td class="p-2 text-slate-400">${t.fuente || '—'}</td>
                                <td class="p-2 text-right">${t.isr_tarifa_tramos?.length || 0}</td>
                                <td class="p-2">${t.id === vigenteId ? '<span class="text-emerald-400 font-semibold">Vigente hoy</span>' : '<span class="text-slate-500">Histórica</span>'}</td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>`;
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar la tabla ISR. ¿Corriste <span class="font-mono">sql/2026-08-30_contabilidad_isr.sql</span>?<br>${err.message || err}</p>`;
    }
}
