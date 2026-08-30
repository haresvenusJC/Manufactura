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
                    <input type="text" id="isrFuente" placeholder="Ej. Anexo 8 RMF 2026, DOF 28/12/2025" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                    <p class="text-[10px] text-slate-500 mt-1">Obligatoria — así siempre queda claro de dónde salió cada tabla al verla en "Versiones cargadas".</p>
                </div>
                <div>
                    <label class="block text-[11px] text-slate-400 mb-1">Periodicidad de esta tabla</label>
                    <select id="isrDiasPeriodo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        <option value="7">Periodo de 7 días (semanal)</option>
                        <option value="10">Periodo de 10 días</option>
                        <option value="15">Periodo de 15 días</option>
                        <option value="30.42">Mensual</option>
                    </select>
                    <p class="text-[10px] text-slate-500 mt-1">El SAT publica una tarifa distinta por periodicidad — usa la que corresponda a como pagas la nómina (semanal por default, ya que así está configurada esta app).</p>
                </div>

                <div class="bg-slate-900 border border-slate-800 rounded-lg p-3 space-y-2">
                    <label class="block text-[11px] text-slate-400 font-semibold">Extraer de un archivo (opcional)</label>
                    <p class="text-[10px] text-slate-500">Sube el PDF oficial (Anexo 8) o una foto/captura de la tabla — se intenta leer y llenar los renglones de abajo, pero SIEMPRE revísalos contra el documento antes de guardar; la lectura automática puede equivocarse.</p>
                    <input type="file" id="isrArchivo" accept=".pdf,image/*" class="w-full text-[11px] text-slate-300 file:mr-2 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:bg-slate-800 file:text-sky-300 file:text-[11px] file:cursor-pointer">
                    <button type="button" id="isrExtraer" class="w-full text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 px-3 py-2 rounded-lg border border-slate-700 cursor-pointer" disabled>Extraer de archivo</button>
                    <p id="isrExtraerMsg" class="text-[10px] min-h-[1rem] text-slate-500"></p>
                </div>

                <div class="flex items-center justify-between">
                    <label class="text-[11px] text-slate-400">Tramos</label>
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

    document.getElementById('isrArchivo').addEventListener('change', (e) => {
        document.getElementById('isrExtraer').disabled = !e.target.files?.length;
    });
    document.getElementById('isrExtraer').addEventListener('click', isrExtraerDeArchivo);

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

// ---------------------------------------------------------------------
// Extraer tramos de un archivo (PDF con texto seleccionable, o foto/
// captura vía OCR). Nunca guarda solo: solo llena la tabla editable de
// arriba para que el usuario la revise contra el documento antes de
// darle "Guardar tabla".
// ---------------------------------------------------------------------

async function isrExtraerDeArchivo() {
    const input = document.getElementById('isrArchivo');
    const btn = document.getElementById('isrExtraer');
    const msg = document.getElementById('isrExtraerMsg');
    const archivo = input.files?.[0];
    if (!archivo) return;

    btn.disabled = true;
    msg.className = 'text-[10px] min-h-[1rem] text-slate-400';

    try {
        let texto;
        if (archivo.type === 'application/pdf' || /\.pdf$/i.test(archivo.name)) {
            msg.textContent = 'Leyendo el PDF…';
            texto = await extraerTextoPdf(archivo);
        } else {
            msg.textContent = 'Reconociendo texto de la imagen (puede tardar unos segundos)…';
            texto = await extraerTextoImagen(archivo, (m) => {
                if (m.status === 'recognizing text') {
                    msg.textContent = `Reconociendo texto de la imagen… ${Math.round((m.progress || 0) * 100)}%`;
                }
            });
        }

        const encontrados = parsearTextoATramos(texto);
        if (encontrados.length < 2) {
            msg.textContent = 'No se reconocieron suficientes renglones — captúralos a mano abajo, o intenta con otro archivo/foto más clara.';
            msg.className = 'text-[10px] min-h-[1rem] text-amber-400';
            return;
        }

        isrTramos = encontrados;
        renderTramos();

        const fuenteInput = document.getElementById('isrFuente');
        if (fuenteInput && !fuenteInput.value.trim()) {
            fuenteInput.value = archivo.name;
        }

        msg.textContent = `Se llenaron ${encontrados.length} renglón(es) a partir de "${archivo.name}" — revísalos contra el documento oficial antes de guardar.`;
        msg.className = 'text-[10px] min-h-[1rem] text-emerald-400';
    } catch (err) {
        msg.textContent = 'No se pudo leer el archivo: ' + (err.message || err);
        msg.className = 'text-[10px] min-h-[1rem] text-rose-400';
    } finally {
        btn.disabled = false;
    }
}

async function extraerTextoPdf(archivo) {
    if (!window.pdfjsLib) throw new Error('No se pudo cargar la librería de lectura de PDF (revisa tu conexión y recarga la página).');

    const buffer = await archivo.arrayBuffer();
    const pdf = await pdfjsLib.getDocument({ data: buffer }).promise;
    let textoCompleto = '';

    for (let n = 1; n <= pdf.numPages; n++) {
        const page = await pdf.getPage(n);
        const contenido = await page.getTextContent();
        // Agrupa por renglón (misma coordenada Y) para no perder la
        // estructura de columnas al concatenar el texto.
        const porY = new Map();
        contenido.items.forEach((item) => {
            const y = Math.round(item.transform[5]);
            if (!porY.has(y)) porY.set(y, []);
            porY.get(y).push(item.str);
        });
        [...porY.keys()].sort((a, b) => b - a).forEach((y) => {
            textoCompleto += porY.get(y).join(' ') + '\n';
        });
    }
    return textoCompleto;
}

async function extraerTextoImagen(archivo, onProgreso) {
    if (!window.Tesseract) throw new Error('No se pudo cargar la librería de OCR (revisa tu conexión y recarga la página).');

    const { data } = await Tesseract.recognize(archivo, 'spa', {
        logger: onProgreso,
    });
    return data.text;
}

// Busca renglones con exactamente 4 valores numéricos (límite inferior,
// límite superior o "en adelante", cuota fija, %) — el patrón de un
// tramo de tarifa ISR. Un PDF del Anexo 8 trae VARIAS tablas (una por
// periodicidad: diaria, 7/10/15 días, mensual...), así que no basta con
// tomar los primeros 11 renglones de 4 números que aparezcan: podrían
// ser de la tabla equivocada. Se valida con dos invariantes que SÍ
// cumple cualquier tarifa progresiva real:
//   1. Es contigua: el límite inferior de un tramo es el límite
//      superior del tramo anterior + 0.01.
//   2. El % es estrictamente creciente entre tramos.
// Se busca entre todos los renglones candidatos la cadena contigua más
// larga que cumpla ambas cosas, y esa es la que se usa — así una tabla
// distinta mezclada en el mismo texto no puede colarse a la mitad.
function parsearTextoATramos(texto) {
    const reToken = /en\s*adelante|\d[\d,]*\.\d{1,3}|\d[\d,]*/gi;
    const candidatos = [];

    for (const linea of texto.split(/\r?\n/)) {
        const tokens = linea.match(reToken);
        if (!tokens || tokens.length !== 4) continue;

        const limInf = parseFloat(tokens[0].replace(/,/g, ''));
        const abierto = /en\s*adelante/i.test(tokens[1]);
        const limSup = abierto ? null : parseFloat(tokens[1].replace(/,/g, ''));
        const cuota = parseFloat(tokens[2].replace(/,/g, ''));
        const pct = parseFloat(tokens[3].replace(/,/g, ''));

        if (Number.isNaN(limInf) || Number.isNaN(cuota) || Number.isNaN(pct)) continue;
        if (pct <= 0 || pct > 60) continue;
        if (!abierto && (Number.isNaN(limSup) || limSup <= limInf)) continue;

        candidatos.push({ limInf, limSup, cuota, pct, abierto });
    }

    // Cadena contigua más larga: cada renglón debe amarrar con el
    // anterior (limite_inferior == limite_superior_previo + 0.01, con
    // tolerancia de centavos) y traer un % mayor al del tramo previo.
    let mejorCadena = [];
    let cadenaActual = [];
    for (const c of candidatos) {
        const previo = cadenaActual[cadenaActual.length - 1];
        const amarra = previo && previo.limSup != null && Math.abs(c.limInf - (previo.limSup + 0.01)) <= 0.05 && c.pct > previo.pct;

        if (cadenaActual.length === 0 || amarra) {
            cadenaActual.push(c);
        } else {
            if (cadenaActual.length > mejorCadena.length) mejorCadena = cadenaActual;
            cadenaActual = [c];
        }
        if (cadenaActual.length >= 11) break;
    }
    if (cadenaActual.length > mejorCadena.length) mejorCadena = cadenaActual;

    return mejorCadena.slice(0, 11).map((c) => ({
        limite_inferior: c.limInf.toFixed(2),
        limite_superior: c.abierto ? '' : c.limSup.toFixed(2),
        cuota_fija: c.cuota.toFixed(2),
        porcentaje: c.pct.toFixed(3),
    }));
}

async function duplicarUltimaVersion() {
    const msg = document.getElementById('isrMsg');
    try {
        const { data: ultima, error: errUltima } = await supabaseClient
            .from('isr_tarifas')
            .select('id, fuente, dias_periodo')
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
        if (ultima.dias_periodo) document.getElementById('isrDiasPeriodo').value = ultima.dias_periodo;
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
    const diasPeriodo = parseFloat(document.getElementById('isrDiasPeriodo').value) || 7;

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
            .insert([{ vigente_desde: vigenteDesde, fuente, dias_periodo: diasPeriodo }])
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
            .select('id, vigente_desde, fuente, dias_periodo, created_at, isr_tarifa_tramos(id)')
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
                        <tr><th class="p-2">Vigente desde</th><th class="p-2">Fuente</th><th class="p-2">Periodo</th><th class="p-2 text-right">Tramos</th><th class="p-2">Estatus</th></tr>
                    </thead>
                    <tbody>
                        ${data.map((t) => `
                            <tr class="isr-fila-tarifa border-b border-slate-900 cursor-pointer hover:bg-slate-900/60" data-id="${t.id}" title="Clic para ver los tramos guardados">
                                <td class="p-2 whitespace-nowrap">${t.vigente_desde}</td>
                                <td class="p-2 text-slate-400">${t.fuente || '—'}</td>
                                <td class="p-2 text-slate-400">${t.dias_periodo ? t.dias_periodo + ' días' : '—'}</td>
                                <td class="p-2 text-right">${t.isr_tarifa_tramos?.length || 0}</td>
                                <td class="p-2">${t.id === vigenteId ? '<span class="text-emerald-400 font-semibold">Vigente hoy</span>' : '<span class="text-slate-500">Histórica</span>'}</td>
                            </tr>
                            <tr class="isr-fila-detalle hidden" data-detalle-de="${t.id}">
                                <td colspan="5" class="p-0"></td>
                            </tr>`).join('')}
                    </tbody>
                </table>
            </div>
            <p class="text-[10px] text-slate-500 mt-1">Clic en una fila para ver sus tramos guardados y confirmar que se llenaron bien.</p>`;

        cont.querySelectorAll('.isr-fila-tarifa').forEach((tr) => {
            tr.addEventListener('click', () => isrToggleDetalleTarifa(Number(tr.dataset.id)));
        });
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al consultar la tabla ISR. ¿Corriste <span class="font-mono">sql/2026-08-30_contabilidad_isr.sql</span>?<br>${err.message || err}</p>`;
    }
}

const isrTramosCache = new Map(); // tarifa_id -> tramos ya consultados, para no repetir la consulta al reabrir

async function isrToggleDetalleTarifa(tarifaId) {
    const fila = document.querySelector(`.isr-fila-detalle[data-detalle-de="${tarifaId}"]`);
    if (!fila) return;
    const celda = fila.querySelector('td');

    if (!fila.classList.contains('hidden')) {
        fila.classList.add('hidden');
        return;
    }

    // Colapsa cualquier otra fila abierta, para no amontonar tablas.
    document.querySelectorAll('.isr-fila-detalle').forEach((f) => { if (f !== fila) f.classList.add('hidden'); });

    fila.classList.remove('hidden');
    if (isrTramosCache.has(tarifaId)) {
        celda.innerHTML = renderTablaTramosSoloLectura(isrTramosCache.get(tarifaId));
        return;
    }

    celda.innerHTML = `<p class="text-slate-500 text-[11px] p-2">Cargando tramos…</p>`;
    try {
        const { data, error } = await supabaseClient
            .from('isr_tarifa_tramos')
            .select('orden, limite_inferior, limite_superior, cuota_fija, porcentaje')
            .eq('tarifa_id', tarifaId)
            .order('orden');
        if (error) throw error;
        isrTramosCache.set(tarifaId, data || []);
        celda.innerHTML = renderTablaTramosSoloLectura(data || []);
    } catch (err) {
        celda.innerHTML = `<p class="text-rose-400 text-[11px] p-2">No se pudieron cargar los tramos: ${err.message || err}</p>`;
    }
}

function renderTablaTramosSoloLectura(tramos) {
    if (!tramos.length) return `<p class="text-slate-500 text-[11px] p-2">Esta versión no tiene tramos guardados.</p>`;
    return `
        <table class="w-full text-[11px] bg-slate-900/60">
            <thead class="text-slate-500 uppercase">
                <tr><th class="p-1.5 text-right">Límite inf.</th><th class="p-1.5 text-right">Límite sup.</th><th class="p-1.5 text-right">Cuota fija</th><th class="p-1.5 text-right">%</th></tr>
            </thead>
            <tbody>
                ${tramos.map((t) => `
                    <tr class="border-t border-slate-800 font-mono text-slate-300">
                        <td class="p-1.5 text-right">${Number(t.limite_inferior).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                        <td class="p-1.5 text-right">${t.limite_superior == null ? 'en adelante' : Number(t.limite_superior).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                        <td class="p-1.5 text-right">${Number(t.cuota_fija).toLocaleString('es-MX', { minimumFractionDigits: 2 })}</td>
                        <td class="p-1.5 text-right">${Number(t.porcentaje).toLocaleString('es-MX', { minimumFractionDigits: 3 })}</td>
                    </tr>`).join('')}
            </tbody>
        </table>`;
}
