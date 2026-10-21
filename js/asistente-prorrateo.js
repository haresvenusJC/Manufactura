import { supabaseClient } from './supabase.js';
import { ordenarCentrosProduccion } from './centros-costo.js';

// =====================================================================
// Contabilidad · Asistente de llenado del prorrateo (guía interactiva)
//   Subventana con 5 pasos en el orden en que dependen unos de otros:
//     1 Tu planta (centros de costo y capacidad normal)
//     2 Áreas físicas (m² y personas)
//     3 Luz (submedidor o equipos → kW; los equipos se dan de alta en Activos fijos)
//     4 Tus gastos (casos prácticos: renta, luz, agua, mantenimiento,
//       fumigación, calibraciones…) → crea la plantilla de reparto
//     5 Revisión del mes y simulación
//   Regla: cada paso pregunta, MUESTRA UN RESUMEN de lo que va a guardar y
//   solo escribe en la base cuando el usuario confirma.
//   Escribe en centros_costo, areas_fisicas, activos_fijos(+_centros) (equipos del
//   paso 3; requiere sql/2026-10-15_equipos_unificados.sql), reparto_plantillas(+_lineas)
//   y, si hace falta, cuentas_contables (cuentas 503.xx nuevas y su cif_tipo).
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const num = (v, d = 0) => { const n = parseFloat(v); return Number.isFinite(n) ? n : d; };
const money = (n) => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const fnum = (n, d = 2) => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: d });
const pct = (f) => (Number(f || 0) * 100).toLocaleString('es-MX', { maximumFractionDigits: 1 }) + '%';
const mesISO = () => hoyISO().slice(0, 7);
const sigMes = (iso) => { const d = new Date(iso + 'T00:00:00'); d.setMonth(d.getMonth() + 1); return d.toISOString().slice(0, 10); };

const ID_MODAL = 'asistenteProrrateoModal';
const INPUT = 'bg-slate-900 border border-slate-700 rounded-lg px-2 py-1.5 text-sm text-slate-100';
const BTN = 'text-sm font-medium px-4 py-2 rounded-lg cursor-pointer';
const BTN_OK = `${BTN} bg-emerald-600 hover:bg-emerald-500 text-white`;
const BTN_SEC = `${BTN} bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700`;
const BTN_AZ = `${BTN} bg-sky-600 hover:bg-sky-500 text-white`;

const PASOS = [
    { id: 'inicio', n: '🧭', t: 'Mapa' },
    { id: 'centros', n: '1', t: 'Tu planta' },
    { id: 'areas', n: '2', t: 'Áreas' },
    { id: 'luz', n: '3', t: 'Luz' },
    { id: 'casos', n: '4', t: 'Tus gastos' },
    { id: 'revision', n: '5', t: 'Revisión' },
];

const CTA_NOMBRES = {
    '503.01': 'Energía eléctrica de planta', '503.02': 'Mano de obra indirecta y supervisión',
    '503.03': 'Mantenimiento de planta y equipo', '503.04': 'Depreciación de maquinaria y equipo',
    '503.05': 'Renta de nave industrial', '503.06': 'Materiales e insumos indirectos',
    '503.07': 'Servicios de planta (agua, gas)', '503.08': 'Seguros y vigilancia de planta',
    '503.09': 'Fumigación y control de plagas', '503.10': 'Monitoreo ambiental y microbiológico',
    '503.11': 'Calibración, verificación y validación de equipos', '503.12': 'Refacciones y piezas de mantenimiento',
    '503.13': 'Limpieza y sanitización de planta', '503.14': 'Control de calidad y análisis de laboratorio externo',
    '503.15': 'Manejo de residuos', '503.16': 'Telecomunicaciones y sistemas de planta',
};

// ---------------------------------------------------------------------
// Casos prácticos (planta que maquila cosméticos y productos farmacéuticos)
//   alc = opciones de "¿a quién le toca?": [valor, texto, base, soloProduccion]
//   Valores especiales: una_etapa (pregunta cuál), manual (el usuario fija
//   los %), al_capturar (sin plantilla, se decide en cada factura).
// ---------------------------------------------------------------------
const ALC_MANUAL = ['manual', 'Prefiero definir yo los porcentajes'];
const ALC_CAPTURAR = ['al_capturar', 'Depende de cada factura (lo decido al capturar el gasto)'];
const Q_FREC = {
    id: 'frec', texto: '¿Cómo se paga?',
    opciones: [['contrato', 'Contrato o programa con costo parecido cada mes → gasto FIJO'], ['evento', 'Cuando hay servicio, falla o consumo → gasto VARIABLE']],
    cuando: (caso) => !caso.cif,
};

const CASOS = [
    {
        id: 'renta', i: '🏭', n: 'Renta o arrendamiento', d: 'Renta de la nave, bodega o predio.',
        cta: '503.05', of: '601.24', cif: 'fijo',
        qAlc: '¿Quién ocupa el inmueble que rentas?',
        alc: [['m2', 'Producción y oficinas comparten el inmueble → se reparte por m²', 'm2', false],
              ['planta_m2', 'Solo producción (las oficinas están en otro lado)', 'm2', true], ALC_MANUAL],
        porque: 'La renta se paga por el espacio, así que los m² que ocupa cada área son la base más justa. Es un gasto fijo: no cambia si produces más o menos.',
    },
    {
        id: 'luz', i: '💡', n: 'Luz (recibo de CFE)', d: 'Un solo recibo para toda la instalación.',
        cta: '503.01', of: '601.17', cif: 'variable',
        qAlc: '¿Cómo quieres repartir el recibo de luz?',
        alc: [['kw', 'Un recibo para planta y oficina → por carga eléctrica (kW) de cada área', 'kw', false],
              ['planta_kw', 'La oficina casi no consume: repartir solo entre producción por kW', 'kw', true],
              ['m2', 'No tengo datos de equipos → por m² (aproximado)', 'm2', false], ALC_MANUAL],
        porque: 'La luz la consumen los equipos, no el espacio: por eso la base es la carga eléctrica (kW) de cada área. Un área con muchos equipos o clima pesa más que una bodega del mismo tamaño.',
    },
    {
        id: 'agua', i: '💧', n: 'Agua', d: 'Recibo de agua o pipas.',
        cta: '503.07', of: '601.19', cif: 'variable',
        qAlc: '¿En qué se usa principalmente el agua?',
        alc: [['personas', 'Sanitarios, limpieza y uso del personal (planta y oficina) → por número de personas', 'personas', false],
              ['m2', 'Proceso y lavado en toda la planta, y también la oficina → por m²', 'm2', false],
              ['planta_m2', 'Casi todo es proceso en planta (la oficina casi no consume)', 'm2', true],
              ['una_etapa', 'El agua de proceso se usa en una sola etapa'], ALC_MANUAL],
        porque: 'El agua sigue a la gente (sanitarios) o al proceso (lavado de equipo y mezclas). Si la mayor parte es de proceso en una etapa, cárgala completa a esa etapa.',
    },
    {
        id: 'gas', i: '🔥', n: 'Gas, vapor y combustibles', d: 'Caldera, túnel de vapor, calefacción.',
        cta: '503.07', of: '601.99', cif: 'variable',
        qAlc: '¿Quién consume el gas?',
        alc: [['una_etapa', 'Una sola etapa (ej. túnel de vapor de acondicionamiento, caldera de mezclado)'],
              ['planta_m2', 'Servicios generales de la planta → por m²', 'm2', true],
              ['m2', 'Planta y oficina → por m²', 'm2', false], ALC_MANUAL],
        porque: 'El gas casi siempre lo consume un equipo concreto. Si es de una etapa, ahí va completo; así ese costo no se le carga a etapas que no lo usan.',
    },
    {
        id: 'internet', i: '🌐', n: 'Internet, teléfono y sistemas', d: 'Servicios de comunicación.',
        cta: '503.16', of: '601.18', cif: 'fijo',
        qAlc: '¿Quién usa estos servicios?',
        alc: [['personas', 'Producción y oficina → por número de personas', 'personas', false],
              ['planta_personas', 'Solo producción (líneas de planta, lectores, etiquetado)', 'personas', true], ALC_MANUAL],
        porque: 'Internet y teléfono se usan por persona. Es un gasto fijo: se paga igual aunque no produzcas.',
    },
    {
        id: 'mantenimiento', i: '🔧', n: 'Mantenimiento de equipos', d: 'Servicio técnico, preventivo o correctivo de maquinaria.',
        cta: '503.03', of: '601.52', cif: null,
        qAlc: '¿Qué equipos se atendieron?',
        alc: [['una_etapa', 'Equipos de una sola etapa (ej. llenadoras, mezcladores, selladoras)'],
              ['kw', 'Equipos de varias etapas → por carga eléctrica (kW): más equipo, más mantenimiento', 'kw', true],
              ['m2', 'Mantenimiento general del edificio e instalaciones (planta y oficina) → por m²', 'm2', false],
              ALC_MANUAL, ALC_CAPTURAR],
        porque: 'El mantenimiento sigue a las máquinas. Si sabes de qué etapa es, cárgalo completo a ella; si es de varias, la carga eléctrica es una buena medida de cuánto equipo tiene cada área.',
    },
    {
        id: 'piezas', i: '⚙️', n: 'Piezas y refacciones de mantenimiento', d: 'Sellos, bandas, boquillas, rodamientos, filtros, resistencias.',
        cta: '503.12', of: '601.52', cif: 'variable',
        pre: [{
            id: 'mejora', texto: '¿La pieza es de reposición normal o una mejora importante?',
            opciones: [['no', 'Reposición normal: reemplaza una parte gastada y el equipo queda igual'],
                       ['si', 'Mejora mayor: aumenta la vida útil, la capacidad o es un equipo nuevo y de costo importante']],
        }],
        esp: (r) => r.mejora === 'si'
            ? 'Esto no es un gasto: es una adición al activo fijo (NIF C-6). Regístralo en Contabilidad → Activos fijos; se depreciará en su vida útil. No lo prorrateo.'
            : null,
        qAlc: '¿Para qué equipos son las piezas?',
        alc: [['una_etapa', 'Equipos de una sola etapa'],
              ['kw', 'Equipos de varias etapas (almacén de refacciones general) → por kW', 'kw', true],
              ALC_MANUAL, ALC_CAPTURAR],
        porque: 'Las refacciones se consumen donde están las máquinas. Se llevan a gasto cuando se usan (reposición normal), no cuando se compran.',
    },
    {
        id: 'fumigacion', i: '🪲', n: 'Fumigación y control de plagas', d: 'Servicio de control de plagas (obligatorio en BPM).',
        cta: '503.09', of: '601.99', cif: null,
        qAlc: '¿Dónde se aplica el servicio?',
        alc: [['m2', 'En todo el inmueble (planta y oficina) → por m²', 'm2', false],
              ['planta_m2', 'Solo en producción y almacenes → por m²', 'm2', true], ALC_MANUAL],
        porque: 'El servicio cubre superficie, así que los m² son la base natural. Un contrato mensual es gasto fijo; un servicio extra por plaga es variable.',
    },
    {
        id: 'monitoreo', i: '🔬', n: 'Monitoreo ambiental y microbiológico', d: 'Conteo de partículas, ambiente, superficies, agua purificada.',
        cta: '503.10', of: '601.99', cif: null,
        qAlc: '¿Qué áreas se monitorean?',
        alc: [['una_etapa', 'Un área o etapa específica (ej. envasado de farmacéuticos, cuarto limpio)'],
              ['planta_m2', 'Todas las áreas de producción → por m²', 'm2', true], ALC_MANUAL, ALC_CAPTURAR],
        porque: 'El monitoreo se hace donde el producto está expuesto. Si el muestreo es de una sola área, cárgalo a su etapa; si es de toda la planta, por superficie.',
    },
    {
        id: 'calibraciones', i: '📏', n: 'Calibraciones y validaciones', d: 'Calibración de básculas e instrumentos, calificación de equipos, mapeos.',
        cta: '503.11', of: '601.99', cif: null,
        qAlc: '¿De qué instrumentos o equipos es?',
        alc: [['una_etapa', 'De una sola etapa (ej. básculas de surtido, termómetros de mezclado)'],
              ['partes_iguales', 'De varias etapas, sin distinguir → partes iguales entre etapas', 'partes_iguales', true],
              ['manual', 'De varias etapas: reparto por número de instrumentos que yo defino'], ALC_CAPTURAR],
        avisos: () => ['Si pagas la calibración de todo el año por adelantado, el gasto corresponde a los meses que cubre (devengación contable, NIF A-2): regístralo como pago anticipado y reconócelo mes a mes.'],
        porque: 'La calibración protege la exactitud de instrumentos concretos. Lo ideal es cargarla a la etapa que usa el instrumento; si son de varias etapas, lo más preciso es repartir según cuántos instrumentos tiene cada una.',
    },
    {
        id: 'limpieza', i: '🧽', n: 'Limpieza y sanitización', d: 'Servicio de limpieza, sanitizantes, desinfectantes.',
        cta: '503.13', of: '601.99', cif: null,
        qAlc: '¿Qué áreas se limpian?',
        alc: [['m2', 'Planta y oficina → por m²', 'm2', false],
              ['planta_m2', 'Solo las áreas de producción (sanitización de planta) → por m²', 'm2', true], ALC_MANUAL],
        porque: 'La limpieza depende de la superficie. Un contrato fijo de limpieza es gasto fijo; los sanitizantes que se consumen son variables.',
    },
    {
        id: 'seguridad', i: '🛡️', n: 'Vigilancia y seguros', d: 'Seguridad privada, seguro de la nave y de maquinaria.',
        cta: '503.08', of: '601.99', cif: 'fijo',
        qAlc: '¿Qué cubre?',
        alc: [['m2', 'Todo el inmueble (planta y oficina) → por m²', 'm2', false],
              ['planta_m2', 'Solo la planta → por m²', 'm2', true], ALC_MANUAL],
        porque: 'La vigilancia y el seguro protegen el inmueble y lo que hay en él; se pagan igual produzcas o no (gasto fijo).',
    },
    {
        id: 'supervision', i: '👷', n: 'Supervisión y mano de obra indirecta', d: 'Jefe de planta, almacenista, auxiliares que no están en una sola orden.',
        cta: '503.02', of: '601.01', cif: 'fijo',
        qAlc: '¿A quién atiende esta persona o equipo?',
        alc: [['personas', 'A toda la operación (jefe de planta, almacén) → por número de personas', 'personas', true],
              ['una_etapa', 'A una sola etapa'], ALC_MANUAL],
        avisos: () => ['Confirma con tu contador cómo se carga la nómina del personal indirecto; este asistente solo define cómo se reparte cuando se captura como gasto 503.02.'],
        porque: 'Quien supervisa varias etapas se reparte según la gente que cada una tiene. Es un costo fijo.',
    },
    {
        id: 'insumos', i: '🧤', n: 'Insumos y materiales indirectos', d: 'Uniformes, guantes, cubrebocas, EPP, solventes de línea, filtros.',
        cta: '503.06', of: '601.50', cif: 'variable',
        qAlc: '¿Qué tipo de insumo es?',
        alc: [['personas', 'Uniformes, EPP y consumibles del personal → por número de personas', 'personas', true],
              ['planta_m2', 'Limpieza y consumibles generales de planta → por m²', 'm2', true],
              ['una_etapa', 'Consumibles de una sola etapa'], ALC_MANUAL],
        porque: 'Los consumibles del personal siguen a la gente; los de limpieza, al espacio; los de una línea, a esa etapa.',
    },
    {
        id: 'calidad', i: '🧪', n: 'Control de calidad y análisis externos', d: 'Análisis de laboratorio, estabilidades, microbiología de producto.',
        cta: '503.14', of: '601.99', cif: 'variable',
        pre: [{
            id: 'directo', texto: '¿El análisis es de un lote u orden de producción en particular?',
            opciones: [['si', 'Sí (ej. estabilidad o microbiología de un lote) → es un gasto DIRECTO'],
                       ['no', 'No, es el programa general de control de calidad']],
        }],
        esp: (r) => r.directo === 'si'
            ? 'Entonces no se prorratea: al capturarlo en Gastos elige la clasificación "Directo de producción" y la orden. Se carga a ese lote y su costo unitario queda exacto.'
            : null,
        qAlc: '¿A qué etapas atiende el programa de calidad?',
        alc: [['partes_iguales', 'A todas las etapas por igual → partes iguales', 'partes_iguales', true],
              ['una_etapa', 'A una sola etapa'], ALC_MANUAL],
        porque: 'Lo que es de un lote específico va directo a ese lote; solo lo general se reparte.',
    },
    {
        id: 'residuos', i: '♻️', n: 'Manejo de residuos', d: 'Residuos peligrosos, RPBI, desecho de producto no conforme.',
        cta: '503.15', of: '601.99', cif: 'variable',
        qAlc: '¿De dónde vienen los residuos?',
        alc: [['una_etapa', 'De una sola etapa'],
              ['planta_m2', 'De toda la planta, sin medirlos por etapa → por m²', 'm2', true],
              ['manual', 'Tengo el dato de kg por etapa: defino yo los porcentajes']],
        porque: 'Lo más preciso es repartir según los kilos que genera cada etapa; si no lo mides, la superficie es una aproximación razonable.',
    },
    {
        id: 'depreciacion', i: '🏗️', n: 'Depreciación de maquinaria', d: 'Desgaste mensual de equipos productivos.',
        info: 'deprec',
    },
    {
        id: 'nopror', i: '🚫', n: 'Qué NO se prorratea', d: 'Gastos que no forman parte del costo de producción.',
        info: 'nopror',
    },
];

// ---------------------------------------------------------------------
// Estado del asistente
// ---------------------------------------------------------------------
let S = null;

const centroLbl = (id) => { const c = S.centros.find(x => x.id === Number(id)); return c ? c.codigo : '#' + id; };
const ctaPorCodigo = (cod) => S.cuentas.find(c => c.codigo === cod);
const ctaLbl = (id) => { const c = S.cuentas.find(x => x.id === Number(id)); return c ? `${c.codigo} · ${c.nombre}` : '—'; };
const q = (sel) => S.modal.querySelector(sel);
const qa = (sel) => [...S.modal.querySelectorAll(sel)];

async function cargarBase() {
    const [ce, ar, ca, kw, ct, pl, bs] = await Promise.all([
        supabaseClient.from('centros_costo').select('*').eq('tipo', 'produccion').eq('activo', true),
        supabaseClient.from('areas_fisicas').select('*').order('codigo'),
        supabaseClient.from('activos_fijos').select('id, nombre, area_id, tipo_carga, potencia_kw, cantidad, factor_uso, depreciable').eq('activo', true).not('area_id', 'is', null).order('id'),
        supabaseClient.from('v_areas_carga').select('*'),
        supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo, nivel, afectable, activa, cif_tipo').eq('activa', true).order('codigo'),
        supabaseClient.from('reparto_plantillas').select('*').order('id'),
        supabaseClient.from('v_bases_prorrateo').select('*'),
    ]);
    S.sinEquipos = !!ca.error;   // falta sql/2026-10-15_equipos_unificados.sql
    const err = ce.error || ar.error || kw.error || ct.error || pl.error || bs.error;
    if (err) throw err;
    S.centros = ordenarCentrosProduccion(ce.data || []);
    S.areas = ar.data || [];
    S.equipos = ca.data || [];
    S.kw = {};
    (kw.data || []).forEach(r => { S.kw[r.area_id] = Number(r.kw_efectivo || 0); });
    S.cuentas = ct.data || [];
    S.plantillas = pl.data || [];
    S.bases = bs.data || [];
}

export async function abrirAsistenteProrrateo(paso = 'inicio', onCerrar = null) {
    document.getElementById(ID_MODAL)?.remove();
    const z = typeof window.zSubventanaSiguiente === 'function' ? window.zSubventanaSiguiente() : 60;
    const modal = document.createElement('div');
    modal.id = ID_MODAL;
    modal.className = 'fixed inset-0 flex items-center justify-center bg-slate-950/40 p-3';
    modal.style.zIndex = z;
    modal.innerHTML = `
      <div class="bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl w-full max-w-4xl max-h-[92vh] flex flex-col">
        <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-slate-800">
          <div class="font-semibold text-sky-300">🧭 Asistente de llenado · Prorrateo de gastos</div>
          <button type="button" data-act="cerrar" class="text-slate-400 hover:text-white text-xl leading-none px-2" aria-label="Cerrar">×</button>
        </div>
        <div id="apNav" class="flex flex-wrap gap-1 px-3 py-2 border-b border-slate-800"></div>
        <div id="apCuerpo" class="p-4 overflow-y-auto flex-1 text-sm text-slate-300"><p class="text-slate-500">Cargando…</p></div>
      </div>`;
    document.body.appendChild(modal);

    S = {
        modal, paso: 'inicio', fase: {}, aviso: null, onCerrar,
        centros: [], areas: [], equipos: [], sinEquipos: false, kw: {}, cuentas: [], plantillas: [], bases: [], proveedores: null,
        borr: {}, filasAreas: null, luz: null, caso: null, resp: {}, R: null, sel: {}, rev: null,
    };
    modal.addEventListener('click', onClick);
    modal.addEventListener('change', onChange);
    modal.addEventListener('input', onInput);

    try {
        await cargarBase();
    } catch (err) {
        const m = err.message || String(err);
        q('#apCuerpo').innerHTML = /does not exist|schema cache|could not find/i.test(m)
            ? `<p class="text-amber-400">Faltan migraciones del módulo de costos (sql/2026-09-14 a 2026-09-18). Córrelas en Supabase y vuelve a abrir el asistente.</p>`
            : `<p class="text-rose-400">${esc(m)}</p>`;
        return;
    }
    S.paso = paso;
    pintar();
}
window.abrirAsistenteProrrateo = abrirAsistenteProrrateo;

function cerrar() {
    const cb = S?.onCerrar;
    S?.modal.remove();
    S = null;
    if (typeof cb === 'function') cb();
}

// ---------------------------------------------------------------------
// Estado de cada paso (✅ / ⚠) calculado de la base
// ---------------------------------------------------------------------
function estadoPasos() {
    const act = S.areas.filter(a => a.activo);
    const prodAreas = act.filter(a => a.rol === 'produccion');
    const centrosOk = S.centros.length > 0 && S.centros.every(c => Number(c.capacidad_normal_horas) > 0);
    const areasOk = act.length > 0 && act.every(a => Number(a.m2) > 0) && act.some(a => a.rol === 'no_produccion')
        && prodAreas.every(a => a.centro_costo_id);
    const kwBase = (a) => a.kwh_mensual != null ? Number(a.kwh_mensual) : (S.kw[a.id] || 0);
    const luzOk = prodAreas.length > 0 && prodAreas.every(a => kwBase(a) > 0);
    const casosOk = S.plantillas.some(p => p.activo);
    return { centros: centrosOk, areas: areasOk, luz: luzOk, casos: casosOk };
}

// ---------------------------------------------------------------------
// Pintado general
// ---------------------------------------------------------------------
function pintar(conservarScroll = false) {
    const est = estadoPasos();
    const scrollPrevio = conservarScroll ? q('#apCuerpo').scrollTop : 0;
    q('#apNav').innerHTML = PASOS.map(p => {
        const activo = p.id === S.paso;
        const ok = est[p.id];
        return `<button type="button" data-act="ir" data-paso="${p.id}" class="text-xs px-3 py-1.5 rounded-full border ${activo ? 'bg-sky-600 border-sky-500 text-white' : 'bg-slate-800 border-slate-700 text-slate-300 hover:bg-slate-700'}">${p.n} ${p.t}${ok === true ? ' ✅' : ok === false ? ' ⚠' : ''}</button>`;
    }).join('');
    const a = S.aviso; S.aviso = null;
    const aviso = a ? `<div class="mb-3 text-xs rounded-lg border p-2 ${a.t === 'ok' ? 'border-emerald-800 bg-emerald-950/30 text-emerald-300' : 'border-rose-800 bg-rose-950/30 text-rose-300'}">${esc(a.m)}</div>` : '';
    const vista = { inicio: vInicio, centros: vCentros, areas: vAreas, luz: vLuz, casos: vCasos, revision: vRevision }[S.paso]();
    const cuerpo = q('#apCuerpo');
    cuerpo.innerHTML = aviso + vista;
    cuerpo.scrollTop = scrollPrevio;
    if (S.paso === 'revision') cargarRevision();
    if (S.paso === 'casos' && S.caso === 'depreciacion') cargarDeprec();
}

const msgEl = () => q('#apMsg');
function msg(tipo, m) {
    const el = msgEl();
    if (!el) return;
    el.textContent = m;
    el.className = 'text-xs mt-2 ' + (tipo === 'ok' ? 'text-emerald-400' : tipo === 'err' ? 'text-rose-400' : 'text-slate-400');
}
const fase = () => S.fase[S.paso] || 'p';
const setFase = (f) => { S.fase[S.paso] = f; };
const barraBotones = (...btns) => `<div class="flex flex-wrap items-center gap-2 mt-4">${btns.join('')}</div><p id="apMsg" class="text-xs mt-2 min-h-[1rem]"></p>`;
const btn = (act, txt, cls, extra = '') => `<button type="button" data-act="${act}" ${extra} class="${cls}">${txt}</button>`;
const tip = (t) => `<div class="text-[11px] text-slate-500 mt-1">${t}</div>`;

// ---------------------------------------------------------------------
// MAPA
// ---------------------------------------------------------------------
function vInicio() {
    const est = estadoPasos();
    const filas = [
        ['centros', '1', 'Tu planta: etapas y capacidad', 'Cuántas personas trabajan en cada etapa (SURT, MEZ, ENV…) y cuántas horas al mes es lo normal.', 'Va primero: el prorrateo compara las horas realmente trabajadas contra esta capacidad para saber cuánto CIF fijo se aplica y cuánto es "capacidad no utilizada".'],
        ['areas', '2', 'Áreas físicas', 'Cada área con sus m², su gente y a qué etapa pertenece (o si es oficina).', 'Va segundo: de aquí salen los porcentajes de renta, agua, vigilancia, internet… y el reparto "planta vs oficina".'],
        ['luz', '3', 'Luz', 'Si cada área tiene submedidor, o qué equipos tiene: los das de alta aquí mismo en Activos fijos (potencia, área y si se deprecian).', 'Va tercero: la luz se reparte por carga eléctrica, no por espacio.'],
        ['casos', '4', 'Tus gastos', 'Casos prácticos: renta, luz, agua, mantenimiento, fumigación, calibraciones… Te hago preguntas y creo la regla de reparto de cada uno.', 'Va cuarto: usa todo lo anterior para calcular los porcentajes.'],
        ['revision', '5', 'Revisión y simulación', 'Qué falta antes de prorratear el mes, y una simulación con un monto de ejemplo.', 'Al final: confirma que todo quedó completo.'],
    ];
    const primero = filas.find(f => est[f[0]] === false);
    return `
      <p class="text-slate-200 mb-1">El prorrateo reparte los gastos indirectos de fabricación (CIF) entre las órdenes de producción. Para hacerlo bien hay que llenar 4 cosas <b>en este orden</b>, porque cada una usa la anterior:</p>
      <p class="text-xs text-slate-500 mb-3">En cada paso te pregunto, te muestro un resumen de lo que voy a guardar y solo guardo cuando tú confirmas.</p>
      <div class="space-y-2">
        ${filas.map(([id, n, t, d, porque]) => `
          <div class="border border-slate-800 rounded-xl p-3 bg-slate-950 flex flex-wrap items-start justify-between gap-3">
            <div class="flex-1 min-w-[220px]">
              <div class="font-semibold text-slate-100">${n}. ${t} ${est[id] === true ? '<span class="text-emerald-400 text-xs">✅ completo</span>' : est[id] === false ? '<span class="text-amber-400 text-xs">⚠ por completar</span>' : ''}</div>
              <div class="text-xs text-slate-400 mt-0.5">${d}</div>
              <div class="text-[11px] text-slate-500 mt-1">${porque}</div>
            </div>
            ${btn('ir', 'Ir al paso', BTN_SEC, `data-paso="${id}"`)}
          </div>`).join('')}
      </div>
      ${barraBotones(primero ? btn('ir', `Empezar por el paso ${primero[1]} →`, BTN_AZ, `data-paso="${primero[0]}"`) : btn('ir', 'Ir a la revisión →', BTN_AZ, 'data-paso="revision"'))}`;
}

// ---------------------------------------------------------------------
// PASO 1 · CENTROS Y CAPACIDAD
// ---------------------------------------------------------------------
function capCalc(v) { return Math.round(v.op * v.jor * v.dias * v.fa * v.fnp * v.fpp * 100) / 100; }
function valsCentro(c) {
    return {
        op: Number(c.cap_operadores) || 0, jor: Number(c.cap_horas_jornada) || 8, dias: Number(c.cap_dias_habiles_mes) || 24,
        fa: Number(c.cap_factor_ausentismo) || 0.90, fnp: Number(c.cap_factor_no_productivo) || 0.80, fpp: Number(c.cap_factor_paros_planeados) || 0.96,
    };
}
function vCentros() {
    if (fase() === 'r') return rCentros();
    if (!S.centros.length) return `<p class="text-amber-400">No hay centros de costo de producción activos. Créalos primero en Contabilidad → Costos y prorrateo → Centros de costo.</p>`;
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">1 · Tu planta</h3>
      <p class="text-xs text-slate-400 mb-3">La <b>capacidad normal</b> es cuántas horas de mano de obra produce una etapa en un mes normal. Con ella el sistema sabe si un mes fue flojo: lo que no se aprovechó no se le carga a los pocos lotes que sí saliste a producir. Responde por cada etapa:</p>
      <div class="space-y-3">
        ${S.centros.map(c => {
            const v = valsCentro(c);
            return `
            <div class="border border-slate-800 rounded-xl p-3 bg-slate-950" data-centro="${c.id}">
              <div class="font-semibold text-slate-100 mb-2">${esc(c.codigo)} · ${esc(c.nombre)} <span class="text-xs text-slate-500 font-normal">(capacidad guardada: ${fnum(c.capacidad_normal_horas)} h/mes)</span></div>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <label class="text-xs text-slate-400">¿Cuántas personas trabajan normalmente en esta etapa?
                  <input type="number" min="0" step="1" class="${INPUT} w-full mt-1 text-right font-mono" data-f="op" value="${v.op || ''}"></label>
                <label class="text-xs text-slate-400">¿Cuántas horas dura la jornada?
                  <input type="number" min="1" step="0.5" class="${INPUT} w-full mt-1 text-right font-mono" data-f="jor" value="${v.jor}"></label>
                <label class="text-xs text-slate-400">¿Cuántos días hábiles trabajan al mes?
                  <input type="number" min="1" step="1" class="${INPUT} w-full mt-1 text-right font-mono" data-f="dias" value="${v.dias}"></label>
              </div>
              <details class="mt-2"><summary class="text-[11px] text-slate-500 cursor-pointer">Ajustes finos (normalmente se dejan como están)</summary>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-2">
                  <label class="text-[11px] text-slate-400">Presencia (0.90 = 10% de faltas y permisos)
                    <input type="number" min="0.1" max="1" step="0.01" class="${INPUT} w-full mt-1 text-right font-mono" data-f="fa" value="${v.fa}"></label>
                  <label class="text-[11px] text-slate-400">Tiempo productivo (0.80 = 20% en limpieza, traslados, esperas)
                    <input type="number" min="0.1" max="1" step="0.01" class="${INPUT} w-full mt-1 text-right font-mono" data-f="fnp" value="${v.fnp}"></label>
                  <label class="text-[11px] text-slate-400">Sin paros planeados (0.96 = 4% de mantenimiento programado)
                    <input type="number" min="0.1" max="1" step="0.01" class="${INPUT} w-full mt-1 text-right font-mono" data-f="fpp" value="${v.fpp}"></label>
                </div>
              </details>
              <div class="mt-2 text-xs text-slate-400">Capacidad normal calculada: <b class="text-emerald-400 font-mono" data-cap>${fnum(capCalc(v))}</b> horas al mes</div>
            </div>`;
        }).join('')}
      </div>
      ${barraBotones(btn('centros-resumen', 'Ver resumen →', BTN_AZ))}`;
}
function leerCentrosDOM() {
    return qa('[data-centro]').map(el => {
        const g = (f) => num(el.querySelector(`[data-f="${f}"]`).value);
        const v = { op: g('op'), jor: g('jor'), dias: g('dias'), fa: g('fa'), fnp: g('fnp'), fpp: g('fpp') };
        return { id: Number(el.dataset.centro), ...v, cap: capCalc(v) };
    });
}
function rCentros() {
    const b = S.borr.centros;
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">1 · Resumen antes de guardar</h3>
      <p class="text-xs text-slate-400 mb-3">Esto es lo que voy a guardar en Centros de costo:</p>
      <div class="overflow-x-auto"><table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-2">Etapa</th><th class="p-2 text-right">Personas</th><th class="p-2">Cálculo</th><th class="p-2 text-right">Capacidad nueva</th><th class="p-2 text-right">Hoy</th></tr></thead>
        <tbody>${b.map(x => {
            const c = S.centros.find(k => k.id === x.id);
            return `<tr class="border-b border-slate-900">
              <td class="p-2 font-mono text-slate-200">${esc(c.codigo)}</td>
              <td class="p-2 text-right font-mono">${x.op}</td>
              <td class="p-2 text-slate-500">${x.op} × ${x.jor} h × ${x.dias} días × ${x.fa} × ${x.fnp} × ${x.fpp}</td>
              <td class="p-2 text-right font-mono text-emerald-400">${fnum(x.cap)} h</td>
              <td class="p-2 text-right font-mono text-slate-500">${fnum(c.capacidad_normal_horas)} h</td></tr>`;
        }).join('')}</tbody></table></div>
      ${tip('Los centros no se renombran ni se tocan sus demás datos; solo se actualiza la capacidad normal y sus variables.')}
      ${barraBotones(btn('volver', '← Corregir', BTN_SEC), btn('centros-guardar', '✅ Confirmar y guardar', BTN_OK))}`;
}
async function guardarCentros() {
    for (const x of S.borr.centros) {
        const { error } = await supabaseClient.from('centros_costo').update({
            cap_operadores: Math.round(x.op), cap_horas_jornada: x.jor, cap_dias_habiles_mes: Math.round(x.dias),
            cap_factor_ausentismo: x.fa, cap_factor_no_productivo: x.fnp, cap_factor_paros_planeados: x.fpp,
            capacidad_normal_horas: x.cap,
        }).eq('id', x.id);
        if (error) throw error;
    }
    await cargarBase();
}

// ---------------------------------------------------------------------
// PASO 2 · ÁREAS
// ---------------------------------------------------------------------
const AREAS_SUG = [
    { codigo: 'ALM-PT', nombre: 'Almacén de producto terminado', rol: 'no_produccion', nota: 'Almacenar producto ya terminado es gasto de venta/operación, no costo de producción (NIF C-4).' },
    { codigo: 'CC', nombre: 'Control de calidad / laboratorio', rol: 'produccion', nota: 'Elige la etapa que más atiende.' },
    { codigo: 'MANT', nombre: 'Mantenimiento / taller', rol: 'produccion', nota: 'Elige la etapa que más atiende.' },
    { codigo: 'CLIM', nombre: 'Cuarto limpio / área estéril', rol: 'produccion', nota: 'Para farmacéuticos; elige su etapa.' },
    { codigo: 'AGUA', nombre: 'Sistema de agua purificada', rol: 'produccion', nota: 'Elige la etapa que más la usa.' },
    { codigo: 'RESID', nombre: 'Cuarto de residuos', rol: 'produccion', nota: 'Elige la etapa que más genera.' },
    { codigo: 'COMED', nombre: 'Comedor y sanitarios', rol: 'no_produccion', nota: 'Servicios al personal.' },
];
function filaArea(a) {
    const k = a.id || a.key;
    const nueva = !a.id;
    return `
      <tr class="border-b border-slate-900" data-area="${k}" data-nueva="${nueva ? 1 : 0}">
        <td class="p-1"><input class="${INPUT} w-24 font-mono uppercase text-xs" data-f="codigo" value="${esc(a.codigo || '')}" ${nueva ? '' : 'readonly'}></td>
        <td class="p-1"><input class="${INPUT} w-44 text-xs" data-f="nombre" value="${esc(a.nombre || '')}"></td>
        <td class="p-1"><select class="${INPUT} text-xs" data-f="rol"><option value="produccion"${a.rol === 'produccion' ? ' selected' : ''}>Producción</option><option value="no_produccion"${a.rol === 'no_produccion' ? ' selected' : ''}>Oficina / no producción</option></select></td>
        <td class="p-1"><select class="${INPUT} text-xs" data-f="centro"><option value="">— etapa —</option>${S.centros.map(c => `<option value="${c.id}"${Number(a.centro_costo_id) === c.id ? ' selected' : ''}>${esc(c.codigo)}</option>`).join('')}</select></td>
        <td class="p-1"><input type="number" min="0" step="0.01" class="${INPUT} w-20 text-right font-mono text-xs" data-f="m2" value="${a.m2 ?? 0}"></td>
        <td class="p-1"><input type="number" min="0" step="1" class="${INPUT} w-16 text-right font-mono text-xs" data-f="personas" value="${a.personas ?? 0}"></td>
        <td class="p-1 text-center"><input type="checkbox" data-f="activo" ${a.activo !== false ? 'checked' : ''} class="accent-emerald-500"></td>
        <td class="p-1">${nueva ? `<button type="button" data-act="area-quitar" data-key="${k}" class="text-rose-400 text-xs hover:underline">Quitar</button>` : ''}</td>
      </tr>`;
}
function vAreas() {
    if (fase() === 'r') return rAreas();
    if (!S.filasAreas) S.filasAreas = S.areas.map(a => ({ ...a }));
    const usados = new Set(S.filasAreas.map(a => (a.codigo || '').toUpperCase()));
    const sug = AREAS_SUG.filter(s => !usados.has(s.codigo));
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">2 · Áreas físicas</h3>
      <p class="text-xs text-slate-400 mb-1">Para cada área de tu instalación dime: <b>¿cuántos m² mide</b> (del plano), <b>¿cuántas personas trabajan ahí</b> normalmente y <b>¿es de producción</b> (a qué etapa pertenece) <b>o es oficina</b>?</p>
      <p class="text-xs text-slate-500 mb-3">Todo lo administrativo es "Oficina / no producción": su parte de los servicios se va a resultados (601.xx), nunca al costo del producto. Debe existir al menos una, si no el reparto sale 100% producción.</p>
      <div class="overflow-x-auto"><table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-1">Código</th><th class="p-1">Nombre</th><th class="p-1">Rol</th><th class="p-1">Etapa</th><th class="p-1 text-right">m²</th><th class="p-1 text-right">Personas</th><th class="p-1">Activa</th><th></th></tr></thead>
        <tbody id="apFilasAreas">${S.filasAreas.map(filaArea).join('')}</tbody></table></div>
      <div class="mt-3 flex flex-wrap gap-2 items-center">
        ${btn('area-nueva', '＋ Agregar área', BTN_SEC)}
        ${sug.length ? `<span class="text-[11px] text-slate-500">Típicas en plantas de cosméticos y farmacéuticos:</span>${sug.map((s, i) => `<button type="button" data-act="area-sug" data-codigo="${s.codigo}" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded-full" title="${esc(s.nota)}">＋ ${esc(s.nombre)}</button>`).join('')}` : ''}
      </div>
      ${barraBotones(btn('areas-resumen', 'Ver resumen →', BTN_AZ))}`;
}
function leerAreasDOM() {
    return qa('[data-area]').map(el => {
        const g = (f) => el.querySelector(`[data-f="${f}"]`);
        const nueva = el.dataset.nueva === '1';
        const rol = g('rol').value;
        return {
            id: nueva ? null : Number(el.dataset.area), key: el.dataset.area,
            codigo: g('codigo').value.trim().toUpperCase(), nombre: g('nombre').value.trim(), rol,
            centro_costo_id: rol === 'produccion' && g('centro').value ? Number(g('centro').value) : null,
            m2: num(g('m2').value), personas: Math.round(num(g('personas').value)), activo: g('activo').checked,
        };
    });
}
function rAreas() {
    const b = S.borr.areas;
    const act = b.filter(a => a.activo);
    const totM2 = act.reduce((s, a) => s + a.m2, 0), totP = act.reduce((s, a) => s + a.personas, 0);
    const prodM2 = act.filter(a => a.rol === 'produccion').reduce((s, a) => s + a.m2, 0);
    const prodP = act.filter(a => a.rol === 'produccion').reduce((s, a) => s + a.personas, 0);
    const antes = (a) => S.areas.find(x => x.id === a.id);
    const cambio = (a) => {
        const o = antes(a);
        if (!o) return '<span class="text-emerald-400">NUEVA</span>';
        const c = [];
        if (o.nombre !== a.nombre) c.push('nombre');
        if (o.rol !== a.rol) c.push('rol');
        if ((o.centro_costo_id || null) !== a.centro_costo_id) c.push('etapa');
        if (Number(o.m2) !== a.m2) c.push(`m² ${fnum(o.m2)}→${fnum(a.m2)}`);
        if (Number(o.personas) !== a.personas) c.push(`personas ${o.personas}→${a.personas}`);
        if (!!o.activo !== a.activo) c.push(a.activo ? 'se activa' : 'se desactiva');
        return c.length ? `<span class="text-amber-400">${c.join(', ')}</span>` : '<span class="text-slate-600">sin cambio</span>';
    };
    const avisos = S.borr.areasAvisos;
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">2 · Resumen antes de guardar</h3>
      ${avisos.length ? `<div class="mb-3 space-y-1">${avisos.map(a => `<div class="text-xs text-amber-400">⚠ ${esc(a)}</div>`).join('')}</div>` : ''}
      <div class="overflow-x-auto"><table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-2">Área</th><th class="p-2">Rol</th><th class="p-2 text-right">m²</th><th class="p-2 text-right">% m²</th><th class="p-2 text-right">Personas</th><th class="p-2 text-right">% pers.</th><th class="p-2">Cambio</th></tr></thead>
        <tbody>${b.map(a => `<tr class="border-b border-slate-900 ${a.activo ? '' : 'opacity-50'}">
          <td class="p-2"><span class="font-mono text-slate-200">${esc(a.codigo)}</span> <span class="text-slate-500">${esc(a.nombre)}</span></td>
          <td class="p-2">${a.rol === 'produccion' ? `Producción · ${a.centro_costo_id ? esc(centroLbl(a.centro_costo_id)) : '?'}` : 'Oficina'}</td>
          <td class="p-2 text-right font-mono">${fnum(a.m2)}</td><td class="p-2 text-right font-mono text-slate-400">${a.activo && totM2 ? pct(a.m2 / totM2) : '—'}</td>
          <td class="p-2 text-right font-mono">${a.personas}</td><td class="p-2 text-right font-mono text-slate-400">${a.activo && totP ? pct(a.personas / totP) : '—'}</td>
          <td class="p-2">${cambio(a)}</td></tr>`).join('')}</tbody>
        <tfoot><tr class="border-t-2 border-slate-700 text-slate-300"><td class="p-2 font-semibold" colspan="3">Producción vs oficina</td>
          <td class="p-2 text-right font-mono text-emerald-400">${totM2 ? pct(prodM2 / totM2) : '—'}</td><td></td>
          <td class="p-2 text-right font-mono text-emerald-400">${totP ? pct(prodP / totP) : '—'}</td><td class="p-2 text-slate-500">producción</td></tr></tfoot></table></div>
      ${barraBotones(btn('volver', '← Corregir', BTN_SEC), btn('areas-guardar', '✅ Confirmar y guardar', BTN_OK))}`;
}
function validarAreas(b) {
    const err = [], avisos = [];
    const cods = new Set();
    for (const a of b) {
        if (!a.codigo || !a.nombre) err.push('Hay un área sin código o sin nombre.');
        if (cods.has(a.codigo)) err.push(`El código ${a.codigo} está repetido.`);
        cods.add(a.codigo);
        if (a.activo && a.rol === 'produccion' && !a.centro_costo_id) err.push(`El área ${a.codigo} es de producción: elige su etapa.`);
        if (a.activo && !(a.m2 > 0)) avisos.push(`${a.codigo} tiene 0 m²: no pesará en los repartos por superficie.`);
        if (a.activo && a.personas === 0) avisos.push(`${a.codigo} tiene 0 personas: no pesará en los repartos por personas.`);
    }
    if (!b.some(a => a.activo && a.rol === 'no_produccion')) avisos.push('No hay un área de Oficina: sin ella todo se reparte 100% a producción.');
    return { err, avisos };
}
async function guardarAreas() {
    for (const a of S.borr.areas) {
        const row = {
            nombre: a.nombre, rol: a.rol, centro_costo_id: a.centro_costo_id, m2: a.m2, personas: a.personas, activo: a.activo,
        };
        const { error } = a.id
            ? await supabaseClient.from('areas_fisicas').update(row).eq('id', a.id)
            : await supabaseClient.from('areas_fisicas').insert([{ ...row, codigo: a.codigo }]);
        if (error) throw error;
    }
    S.filasAreas = null;
    await cargarBase();
}

// ---------------------------------------------------------------------
// PASO 3 · LUZ
// ---------------------------------------------------------------------
const EQUIPOS_SUG = [
    ['Llenadora / dosificadora', 'equipo'], ['Mezclador u homogeneizador', 'equipo'], ['Marmita o reactor con chaqueta', 'equipo'],
    ['Compresor de aire', 'equipo'], ['Manejadora de aire / cuarto limpio (HVAC)', 'clima'], ['Aire acondicionado', 'clima'],
    ['Túnel de termoencogido / vapor', 'equipo'], ['Etiquetadora', 'equipo'], ['Banda transportadora', 'equipo'],
    ['Sistema de agua purificada (ósmosis)', 'equipo'], ['Refrigerador de materia prima', 'equipo'], ['Iluminación', 'iluminacion'],
];
const UNID_KW = { kW: 1, HP: 0.746, W: 0.001 };
const TIPOS_CARGA = [['equipo', 'Equipo'], ['clima', 'Clima / HVAC'], ['iluminacion', 'Iluminación'], ['otro', 'Otro']];
import { hoyISO } from './fechas.js';

function kwFila(f) { return num(f.v) * (UNID_KW[f.u] || 1) * Math.max(1, num(f.c, 1)) * Math.min(1, Math.max(0.01, num(f.f, 1))); }
const idCuenta = (cod) => ctaPorCodigo(cod)?.id || '';
// Equipos ya dados de alta en Activos fijos en un área (vigentes)
const equiposDe = (areaId) => S.equipos.filter(e => e.area_id === areaId);
const kwEquipo = (e) => Number(e.potencia_kw || 0) * Number(e.cantidad || 1) * Number(e.factor_uso || 1);
const primeraPalabra = (t) => (String(t).toLowerCase().match(/[a-záéíóúñü]{4,}/) || [''])[0];

function nuevoEquipo(areaId, d = '', t = 'equipo') {
    const a = S.areas.find(x => x.id === Number(areaId));
    return {
        d, t, v: '', u: 'kW', c: 1, f: 1, dep: '', fecha: hoyISO(),
        costo: '', res: 0, vida: '', ca: idCuenta('152.01'), cg: idCuenta('503.04'), cd: idCuenta('153.01'),
        et: a?.centro_costo_id ? [a.centro_costo_id] : [],
    };
}
function initLuz() {
    S.luz = {};
    S.areas.filter(a => a.activo).forEach(a => {
        S.luz[a.id] = { modo: a.kwh_mensual != null ? 'submedidor' : 'equipos', kwh: a.kwh_mensual ?? '', nuevas: [] };
    });
}
const optsCuenta = (tipo, sel) => {
    const lista = S.cuentas.filter(c => c.afectable && (tipo === 'gasto' ? (c.tipo === 'gasto' || c.codigo.startsWith('503.')) : c.tipo === 'activo'));
    return `<option value="">Selecciona…</option>` + lista.map(c => `<option value="${c.id}"${Number(sel) === c.id ? ' selected' : ''}>${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
};
// Una tarjeta de alta de equipo (borrador). Todo se guarda en Activos fijos al confirmar.
function htmlBorradorEquipo(a, f, i) {
    const k = `${a.id}_${i}`;
    return `
    <div class="border border-sky-900 bg-sky-950/10 rounded-xl p-3" data-luz-fila="${i}">
      <div class="flex flex-wrap items-end gap-2">
        <label class="text-[11px] text-slate-400">¿Qué equipo es?<input class="${INPUT} block w-56 text-xs lz-d" placeholder="Ej. Llenadora de pistón" value="${esc(f.d)}"></label>
        <label class="text-[11px] text-slate-400">Tipo<select class="${INPUT} block text-xs lz-t">${TIPOS_CARGA.map(([v, l]) => `<option value="${v}"${f.t === v ? ' selected' : ''}>${l}</option>`).join('')}</select></label>
        <label class="text-[11px] text-slate-400">Potencia de placa<span class="flex gap-1"><input type="number" min="0" step="0.001" class="${INPUT} w-24 text-right font-mono text-xs lz-v" placeholder="0 si no usa luz" value="${f.v}"><select class="${INPUT} text-xs lz-u">${['kW', 'HP', 'W'].map(u => `<option${f.u === u ? ' selected' : ''}>${u}</option>`).join('')}</select></span></label>
        <label class="text-[11px] text-slate-400">Piezas iguales<input type="number" min="1" step="1" class="${INPUT} block w-16 text-right font-mono text-xs lz-c" value="${f.c}"></label>
        <label class="text-[11px] text-slate-400" title="Fracción del tiempo que realmente demanda (1 = siempre a plena carga)">Uso (0.01–1)<input type="number" min="0.01" max="1" step="0.01" class="${INPUT} block w-16 text-right font-mono text-xs lz-f" value="${f.f}"></label>
        <label class="text-[11px] text-slate-400">Fecha de alta<input type="date" class="${INPUT} block text-xs lz-fecha" value="${f.fecha}"></label>
        <button type="button" data-act="luz-del" data-area="${a.id}" data-i="${i}" class="text-rose-400 text-xs hover:underline pb-2">Quitar</button>
      </div>
      <div class="mt-2 text-[11px] text-slate-300 font-medium">¿Este equipo se deprecia?</div>
      <div class="flex flex-wrap gap-4 mt-1 text-xs">
        <label class="flex items-start gap-1.5 max-w-xs"><input type="radio" class="mt-0.5 lz-dep" name="apEqDep_${k}" value="si" data-eqdep ${f.dep === 'si' ? 'checked' : ''}> <span><b>Depreciable</b> — lo compraste y se desgasta (maquinaria). Pide costo y vida útil.</span></label>
        <label class="flex items-start gap-1.5 max-w-xs"><input type="radio" class="mt-0.5 lz-dep" name="apEqDep_${k}" value="no" data-eqdep ${f.dep === 'no' ? 'checked' : ''}> <span><b>No depreciable</b> — solo lo controlas (dónde está y cuánta luz usa).</span></label>
      </div>
      ${f.dep === 'si' ? `
      <div class="mt-2 grid grid-cols-2 sm:grid-cols-4 gap-2 border-t border-slate-800 pt-2">
        <label class="text-[11px] text-slate-400">Costo de adquisición<input type="number" min="0" step="0.01" class="${INPUT} block w-full text-right font-mono text-xs lz-costo" value="${f.costo}"></label>
        <label class="text-[11px] text-slate-400">Valor residual<input type="number" min="0" step="0.01" class="${INPUT} block w-full text-right font-mono text-xs lz-res" value="${f.res}"></label>
        <label class="text-[11px] text-slate-400">Vida útil (meses)<input type="number" min="1" step="1" class="${INPUT} block w-full text-right font-mono text-xs lz-vida" placeholder="Ej. 120" value="${f.vida}"></label>
        <div></div>
        <label class="text-[11px] text-slate-400">Cuenta de activo<select class="${INPUT} block w-full text-xs lz-ca">${optsCuenta('activo', f.ca)}</select></label>
        <label class="text-[11px] text-slate-400">Cuenta de gasto de depreciación<select class="${INPUT} block w-full text-xs lz-cg">${optsCuenta('gasto', f.cg)}</select></label>
        <label class="text-[11px] text-slate-400">Depreciación acumulada<select class="${INPUT} block w-full text-xs lz-cd">${optsCuenta('activo', f.cd)}</select></label>
        <div class="text-[11px] text-slate-400">¿En qué etapas se usa?
          <div class="flex flex-wrap gap-x-3 gap-y-1 mt-1">${S.centros.map(c => `<label class="flex items-center gap-1 text-xs text-slate-200"><input type="checkbox" class="lz-et accent-emerald-500" value="${c.id}" ${f.et.includes(c.id) ? 'checked' : ''}> ${esc(c.codigo)}</label>`).join('')}</div></div>
      </div>
      <div class="text-[10px] text-slate-500 mt-1">Su depreciación mensual es CIF fijo: se reparte en partes iguales entre las etapas marcadas (se precargó la etapa de esta área).</div>` : ''}
      ${f.dep === '' ? '<div class="text-[10px] text-amber-400 mt-1">Elige si es Depreciable o No depreciable para poder guardarlo.</div>' : ''}
    </div>`;
}
function vLuz() {
    if (fase() === 'r') return rLuz();
    if (S.sinEquipos) return `<h3 class="text-base font-semibold text-sky-300 mb-1">3 · Luz</h3><div class="border border-amber-800 bg-amber-950/20 rounded-lg p-3 text-amber-300 text-xs">Falta correr <span class="font-mono">sql/2026-10-15_equipos_unificados.sql</span> en Supabase (los equipos ahora se dan de alta en Activos fijos). Córrelo y vuelve a abrir el asistente.</div>`;
    if (!S.luz) initLuz();
    const act = S.areas.filter(a => a.activo);
    if (!act.length) return `<p class="text-amber-400">Primero captura las áreas (paso 2).</p>`;
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">3 · Luz</h3>
      <p class="text-xs text-slate-400 mb-1">La luz se reparte según cuánta electricidad consume cada área. Para cada una dime: <b>¿tiene su propio medidor (submedidor)?</b> Si no, <b>da de alta aquí mismo sus equipos</b>: quedan registrados en <b>Activos fijos</b> (con su potencia, su área y si se deprecian) y de ahí sale la carga eléctrica.</p>
      <p class="text-xs text-slate-500 mb-3">No puedo guardar el paso si un área de producción sin submedidor no tiene al menos un equipo dado de alta (una luminaria también cuenta: usa el tipo Iluminación).</p>
      <div class="space-y-3">
        ${act.map(a => {
            const L = S.luz[a.id];
            const exist = equiposDe(a.id);
            const textos = [...exist.map(e => e.nombre), ...L.nuevas.map(f => f.d)].map(t => String(t).toLowerCase());
            return `
            <div class="border border-slate-800 rounded-xl p-3 bg-slate-950" data-luz-area="${a.id}">
              <div class="font-semibold text-slate-100">${esc(a.codigo)} · ${esc(a.nombre)} <span class="text-xs font-normal text-slate-500">${a.rol === 'produccion' ? 'producción' : 'oficina'}</span></div>
              <div class="flex flex-wrap gap-4 mt-2 text-xs">
                <label class="flex items-center gap-1"><input type="radio" name="apLuzModo_${a.id}" value="equipos" data-luzmodo ${L.modo === 'equipos' ? 'checked' : ''}> No tiene medidor propio → doy de alta sus equipos</label>
                <label class="flex items-center gap-1"><input type="radio" name="apLuzModo_${a.id}" value="submedidor" data-luzmodo ${L.modo === 'submedidor' ? 'checked' : ''}> Sí tiene submedidor</label>
              </div>
              ${L.modo === 'submedidor' ? `
                <label class="block text-xs text-slate-400 mt-2">¿Cuántos kWh consume al mes? (de los últimos recibos o lecturas)
                  <input type="number" min="0" step="0.01" class="${INPUT} w-40 mt-1 text-right font-mono" data-kwh value="${L.kwh}"></label>`
              : `
                ${exist.length ? `
                <div class="mt-2 text-[11px] text-slate-500">Ya dados de alta en Activos fijos (${exist.length}) → <b class="text-emerald-400">${fnum(S.kw[a.id] || 0, 3)} kW</b>:</div>
                <ul class="mt-1 text-xs text-slate-300 space-y-0.5">${exist.map(e => `<li>✅ ${esc(e.nombre)} <span class="text-slate-500">· ${e.potencia_kw == null ? 'sin potencia' : fnum(kwEquipo(e), 3) + ' kW'} · ${e.depreciable ? 'Depreciable' : 'No depreciable'}</span></li>`).join('')}</ul>
                <div class="text-[10px] text-slate-600 mt-1">Para corregir uno, edítalo en Activos fijos.</div>`
                : `<div class="mt-2 text-[11px] text-amber-400">❌ Esta área todavía no tiene equipos dados de alta.</div>`}
                ${L.nuevas.length ? `<div class="mt-2 space-y-2">${L.nuevas.map((f, i) => htmlBorradorEquipo(a, f, i)).join('')}
                  <div class="text-[11px] text-slate-500">Potencia: la de la placa del equipo (HP × 0.746 = kW). Uso: fracción del tiempo que realmente demanda (un túnel de vapor que enciende 3 h de un turno de 10 ≈ 0.30).</div></div>` : ''}
                <div class="mt-2 flex flex-wrap gap-1 items-center">
                  ${btn('luz-add', '＋ Dar de alta un equipo', BTN_SEC + ' !py-1 !px-3 text-xs', `data-area="${a.id}"`)}
                  <span class="text-[10px] text-slate-600">Equipos típicos (✅ = ya hay uno parecido):</span>
                  ${EQUIPOS_SUG.map(([d], i) => `<button type="button" data-act="luz-sug" data-area="${a.id}" data-i="${i}" class="text-[10px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-0.5 rounded-full">${textos.some(t => t.includes(primeraPalabra(d))) ? '✅ ' : ''}${esc(d)}</button>`).join('')}
                </div>`}
            </div>`;
        }).join('')}
      </div>
      ${barraBotones(btn('luz-resumen', 'Ver resumen →', BTN_AZ))}`;
}
function leerLuzDOM() {
    qa('[data-luz-area]').forEach(el => {
        const id = Number(el.dataset.luzArea);
        const L = S.luz[id];
        const modo = el.querySelector(`input[name="apLuzModo_${id}"]:checked`);
        if (modo) L.modo = modo.value;
        const kwh = el.querySelector('[data-kwh]');
        if (kwh) L.kwh = kwh.value;
        const previos = L.nuevas;
        L.nuevas = [...el.querySelectorAll('[data-luz-fila]')].map((r, i) => {
            const g = (c) => r.querySelector(c);
            const prev = previos[i] || {};
            // el bloque de depreciación solo existe en pantalla si eligió "Depreciable": si no está, conserva lo precargado
            const val = (c, campo, def = '') => (g(c) ? g(c).value : (prev[campo] ?? def));
            const tieneDep = !!g('.lz-ca');
            return {
                d: val('.lz-d', 'd').trim(), t: val('.lz-t', 't', 'equipo'), v: val('.lz-v', 'v'), u: val('.lz-u', 'u', 'kW'), c: val('.lz-c', 'c', 1), f: val('.lz-f', 'f', 1),
                dep: r.querySelector('.lz-dep:checked')?.value || '', fecha: val('.lz-fecha', 'fecha') || hoyISO(),
                costo: val('.lz-costo', 'costo'), res: val('.lz-res', 'res', 0), vida: val('.lz-vida', 'vida'),
                ca: val('.lz-ca', 'ca'), cg: val('.lz-cg', 'cg'), cd: val('.lz-cd', 'cd'),
                et: tieneDep ? [...r.querySelectorAll('.lz-et:checked')].map(c => Number(c.value)) : (prev.et || []),
            };
        });
    });
}
// null si el borrador está completo; si no, qué le falta
function errorEquipo(f) {
    if (!f.d) return 'falta el nombre del equipo';
    if (f.v === '' || !(num(f.v, -1) >= 0)) return 'falta la potencia de placa (pon 0 si no usa electricidad)';
    if (!(num(f.c) >= 1)) return 'las piezas iguales deben ser al menos 1';
    if (!(num(f.f) > 0 && num(f.f) <= 1)) return 'el uso debe estar entre 0.01 y 1';
    if (!f.dep) return 'indica si es Depreciable o No depreciable';
    if (f.dep === 'si') {
        if (!(num(f.costo) > 0)) return 'como es depreciable falta el costo de adquisición';
        if (!(num(f.vida) > 0)) return 'como es depreciable falta la vida útil en meses';
        if (!f.ca || !f.cg || !f.cd) return 'como es depreciable faltan sus tres cuentas (activo, gasto y depreciación acumulada)';
        if (String(ctaLbl(f.cg)).startsWith('503.') && !f.et.length) return 'marca en qué etapas se usa (si no, su depreciación no se prorratea)';
    }
    return null;
}
// Un renglón del borrador cuenta si el usuario empezó a llenarlo
const tocado = (f) => !!(f.d || f.v !== '' || f.dep);
// Errores que impiden guardar el paso
function erroresLuz() {
    const err = [];
    for (const a of S.areas.filter(x => x.activo)) {
        const L = S.luz[a.id];
        if (L.modo === 'submedidor') { if (!(num(L.kwh) > 0)) err.push(`${a.codigo}: captura los kWh del submedidor.`); continue; }
        for (const f of L.nuevas.filter(tocado)) {
            const e = errorEquipo(f);
            if (e) err.push(`${a.codigo} · ${f.d || 'equipo sin nombre'}: ${e}.`);
        }
        const enCurso = L.nuevas.filter(tocado);
        if (a.rol === 'produccion' && !enCurso.length && equiposDe(a.id).length === 0) err.push(`${a.codigo}: da de alta al menos un equipo en Activos fijos (o marca que tiene submedidor). Si solo hay luminarias, usa el tipo Iluminación.`);
    }
    return err;
}
function luzCalc() {
    const act = S.areas.filter(a => a.activo);
    const filas = act.map(a => {
        const L = S.luz[a.id];
        const nuevasValidas = L.modo === 'equipos' ? L.nuevas.filter(f => tocado(f) && !errorEquipo(f)) : [];
        const kw = L.modo === 'submedidor' ? num(L.kwh) : (S.kw[a.id] || 0) + nuevasValidas.reduce((s, f) => s + kwFila(f), 0);
        return { a, L, kw, nuevasValidas };
    });
    const tot = filas.reduce((s, x) => s + x.kw, 0);
    const prod = filas.filter(x => x.a.rol === 'produccion').reduce((s, x) => s + x.kw, 0);
    return { filas, tot, prod };
}
function rLuz() {
    const { filas, tot, prod } = luzCalc();
    const mezcla = filas.some(x => x.L.modo === 'submedidor') && filas.some(x => x.L.modo === 'equipos');
    const avisos = [];
    if (mezcla) avisos.push('Mezclas áreas con submedidor (kWh) y áreas por equipos (kW): la comparación se distorsiona. Mide todas con el mismo método.');
    filas.filter(x => x.kw === 0).forEach(x => avisos.push(`${x.a.codigo} quedó en 0: no pesará en el reparto de luz.`));
    const nuevos = filas.reduce((s, x) => s + x.nuevasValidas.length, 0);
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">3 · Resumen antes de guardar</h3>
      ${avisos.length ? `<div class="mb-3 space-y-1">${avisos.map(a => `<div class="text-xs text-amber-400">⚠ ${esc(a)}</div>`).join('')}</div>` : ''}
      <div class="overflow-x-auto"><table class="w-full text-xs">
        <thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-2">Área</th><th class="p-2">Método</th><th class="p-2 text-right">Consumo base</th><th class="p-2 text-right">% de la luz</th><th class="p-2">Se da de alta en Activos fijos</th></tr></thead>
        <tbody>${filas.map(x => `<tr class="border-b border-slate-900">
          <td class="p-2 font-mono text-slate-200">${esc(x.a.codigo)}</td>
          <td class="p-2">${x.L.modo === 'submedidor' ? 'Submedidor' : 'Equipos'}</td>
          <td class="p-2 text-right font-mono">${fnum(x.kw, 3)} ${x.L.modo === 'submedidor' ? 'kWh' : 'kW'}</td>
          <td class="p-2 text-right font-mono text-slate-400">${tot ? pct(x.kw / tot) : '—'}</td>
          <td class="p-2 text-slate-400">${x.nuevasValidas.length ? x.nuevasValidas.map(f => `${esc(f.d)} <span class="text-slate-600">(${f.dep === 'si' ? 'depreciable · ' + money(num(f.costo)) : 'no depreciable'})</span>`).join('<br>') : '—'}</td></tr>`).join('')}</tbody>
        <tfoot><tr class="border-t-2 border-slate-700"><td class="p-2 font-semibold" colspan="3">Producción vs oficina</td><td class="p-2 text-right font-mono text-emerald-400">${tot ? pct(prod / tot) : '—'} producción</td><td></td></tr></tfoot></table></div>
      ${nuevos ? tip(`Se darán de alta ${nuevos} equipo(s) en Activos fijos. Los depreciables empezarán a depreciarse desde su fecha de alta (aplica la depreciación en Activos fijos → Depreciación del mes).`) : ''}
      ${barraBotones(btn('volver', '← Corregir', BTN_SEC), btn('luz-guardar', '✅ Confirmar y guardar', BTN_OK))}`;
}
async function guardarLuz() {
    const errores = erroresLuz();
    if (errores.length) throw new Error(errores[0]);
    const { filas } = luzCalc();
    for (const x of filas) {
        const nuevoKwh = x.L.modo === 'submedidor' ? num(x.L.kwh) : null;
        const actual = x.a.kwh_mensual != null ? Number(x.a.kwh_mensual) : null;
        if (nuevoKwh !== actual) {
            const { error } = await supabaseClient.from('areas_fisicas').update({ kwh_mensual: nuevoKwh }).eq('id', x.a.id);
            if (error) throw error;
        }
        for (const f of x.nuevasValidas) {
            const dep = f.dep === 'si';
            const row = {
                nombre: f.d, categoria: dep ? 'Maquinaria y equipo' : 'Equipo controlado', fecha_adquisicion: f.fecha || hoyISO(),
                depreciable: dep, area_id: x.a.id, tipo_carga: f.t,
                potencia_kw: Math.round(num(f.v) * (UNID_KW[f.u] || 1) * 1000) / 1000,
                cantidad: Math.max(1, Math.round(num(f.c, 1))), factor_uso: Math.min(1, Math.max(0.01, num(f.f, 1))),
                costo_adquisicion: dep ? num(f.costo) : null, valor_residual: dep ? num(f.res) : 0, vida_util_meses: dep ? Math.round(num(f.vida)) : null,
                cuenta_activo_id: dep ? Number(f.ca) : null, cuenta_depreciacion_gasto_id: dep ? Number(f.cg) : null,
                cuenta_depreciacion_acumulada_id: dep ? Number(f.cd) : null,
            };
            const ins = await supabaseClient.from('activos_fijos').insert([row]).select('id').single();
            if (ins.error) throw ins.error;
            if (dep && f.et.length) {
                const et = await supabaseClient.from('activos_fijos_centros').insert(f.et.map(c => ({ activo_id: ins.data.id, centro_costo_id: c })));
                if (et.error) {
                    await supabaseClient.from('activos_fijos').delete().eq('id', ins.data.id);
                    throw new Error('No se pudieron guardar las etapas de ' + f.d + ': ' + et.error.message + ' (¿falta sql/2026-10-14_depreciacion_al_prorrateo.sql?)');
                }
            }
        }
    }
    S.luz = null;
    await cargarBase();
}

// ---------------------------------------------------------------------
// PASO 4 · CASOS DE GASTO
// ---------------------------------------------------------------------
function casoConfigurado(c) {
    if (c.info) return null;
    const cta = ctaPorCodigo(c.cta);
    return !!(cta && S.plantillas.some(p => p.activo && p.cuenta_id === cta.id));
}
function vCasos() {
    if (!S.caso) {
        return `
          <h3 class="text-base font-semibold text-sky-300 mb-1">4 · Tus gastos</h3>
          <p class="text-xs text-slate-400 mb-3">Elige el gasto que quieres configurar. Te haré unas preguntas cortas y al final verás un resumen antes de guardar. Los ✔ ya tienen su regla de reparto.</p>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
            ${CASOS.map(c => {
                const ok = casoConfigurado(c);
                return `<button type="button" data-act="caso-abrir" data-id="${c.id}" class="text-left border border-slate-800 hover:border-sky-600 bg-slate-950 rounded-xl p-3">
                  <div class="font-semibold text-slate-100">${c.i} ${c.n} ${ok ? '<span class="text-emerald-400 text-xs">✔ configurado</span>' : ''}</div>
                  <div class="text-[11px] text-slate-500 mt-0.5">${c.d}</div></button>`;
            }).join('')}
          </div>
          ${tip('Cada regla queda como una plantilla en Contabilidad → Costos y prorrateo → Reparto de gastos compartidos; al capturar el gasto en Gastos con esa cuenta, el sistema propone la plantilla solo.')}`;
    }
    const c = CASOS.find(x => x.id === S.caso);
    if (c.info === 'deprec') return vDeprec(c);
    if (c.info === 'nopror') return vNoPror(c);
    return fase() === 'r' ? rCaso(c) : vPreguntas(c);
}
function vDeprec(c) {
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n}</h3>
      <p class="text-xs text-slate-400 mb-2">La depreciación se calcula en <b>Activos fijos</b> (línea recta, NIF C-6). La de la maquinaria productiva es costo indirecto de fabricación <b>fijo</b>: al hacer el prorrateo del mes se reparte <b>en partes iguales entre las etapas</b> donde marques que se usa la máquina, y de ahí a las órdenes por horas contra la capacidad normal.</p>
      <ol class="list-decimal pl-5 text-xs text-slate-300 space-y-1 mb-3">
        <li>Da de alta la máquina en el <b>paso 3 · Luz</b> de este asistente (o en Activos fijos): elígela <b>Depreciable</b> y pon su costo y vida útil; la cuenta de gasto es <b>503.04 Depreciación de maquinaria y equipo</b>.</li>
        <li>Marca las etapas donde se usa (ej. una llenadora: MEZ y ENV). Si es <b>No depreciable</b> solo cuenta para la luz y no genera depreciación.</li>
        <li>Cada mes, aplica la depreciación y luego el prorrateo: ya entra sola.</li>
      </ol>
      <div id="apDeprecCuerpo" class="text-xs text-slate-500">Revisando tus activos…</div>
      ${barraBotones(btn('caso-volver', '← Volver a los gastos', BTN_SEC))}`;
}
async function datosActivos() {
    const [ac, et] = await Promise.all([
        supabaseClient.from('activos_fijos').select('id, nombre, cuenta_depreciacion_gasto_id').eq('activo', true),
        supabaseClient.from('activos_fijos_centros').select('activo_id, centro_costo_id'),
    ]);
    if (ac.error) return { error: ac.error.message, activos: [] };
    const productivos = (ac.data || []).filter(a => ctaLbl(a.cuenta_depreciacion_gasto_id).startsWith('503.'));
    const otros = (ac.data || []).length - productivos.length;
    if (et.error) return { sinMigracion: true, activos: productivos, otros };
    const porActivo = new Map();
    (et.data || []).forEach(r => porActivo.set(r.activo_id, [...(porActivo.get(r.activo_id) || []), centroLbl(r.centro_costo_id)]));
    return { activos: productivos.map(a => ({ ...a, etapas: porActivo.get(a.id) || [] })), otros };
}
async function cargarDeprec() {
    const d = await datosActivos();
    const el = q('#apDeprecCuerpo');
    if (!el) return;
    if (d.error) { el.innerHTML = `<span class="text-rose-400">${esc(d.error)}</span>`; return; }
    if (d.sinMigracion) {
        el.innerHTML = '<div class="border border-amber-800 bg-amber-950/20 rounded-lg p-2 text-amber-300">Falta correr <span class="font-mono">sql/2026-10-14_depreciacion_al_prorrateo.sql</span> en Supabase para que la depreciación entre al prorrateo.</div>';
        return;
    }
    if (!d.activos.length) {
        el.innerHTML = '<div class="border border-slate-800 rounded-lg p-2 text-slate-400">Hoy no tienes maquinaria productiva depreciándose en Activos fijos con cuenta 503.xx, así que no hay nada que repartir por este concepto. Cuando compres maquinaria, sigue los pasos de arriba.</div>';
        return;
    }
    el.innerHTML = `<table class="w-full"><thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-1.5">Máquina</th><th class="p-1.5">Etapas donde se usa</th></tr></thead><tbody>${d.activos.map(a => `<tr class="border-b border-slate-900"><td class="p-1.5 text-slate-200">${esc(a.nombre)}</td><td class="p-1.5">${a.etapas.length ? `<span class="text-emerald-400">${esc(a.etapas.join(', '))}</span>` : '<span class="text-amber-400">⚠ sin etapas: no se prorratea</span>'}</td></tr>`).join('')}</tbody></table>`;
}

function vNoPror(c) {
    const l = ['Sueldos y comisiones de ventas y administración', 'Publicidad y propaganda', 'Honorarios y papelería de oficina', 'Fletes de venta (entrega al cliente)',
        'Almacenaje de producto terminado (NIF C-4: no es costo de producción)', 'Intereses, comisiones bancarias e impuestos', 'Gastos no deducibles'];
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n}</h3>
      <p class="text-xs text-slate-400 mb-2">El prorrateo es solo para los gastos de <b>fabricación</b> que no puedes asignar a una orden. Estos van directo a resultados (cuentas 601.xx) y se capturan en Gastos como "No producción":</p>
      <ul class="list-disc pl-5 text-xs text-slate-300 space-y-1">${l.map(x => `<li>${x}</li>`).join('')}</ul>
      <p class="text-[11px] text-slate-500 mt-2">Si dudas de un gasto (por ejemplo, permisos y licencias sanitarias), consúltalo con tu contador antes de clasificarlo.</p>
      ${barraBotones(btn('caso-volver', '← Volver a los gastos', BTN_SEC))}`;
}
function radios(name, opciones, valor) {
    return `<div class="space-y-1 mt-1">${opciones.map(([v, l]) => `
      <label class="flex items-start gap-2 text-xs text-slate-200 cursor-pointer"><input type="radio" class="mt-0.5" name="${name}" value="${v}" data-resp="${name}" ${valor === v ? 'checked' : ''}> <span>${l}</span></label>`).join('')}</div>`;
}
function vPreguntas(c) {
    const r = S.resp;
    const bloques = [];
    (c.pre || []).forEach(p => bloques.push(`<div class="mb-3"><div class="text-slate-100 font-medium">${p.texto}</div>${radios(p.id, p.opciones, r[p.id])}</div>`));
    const bloqueaPre = (c.pre || []).some(p => !r[p.id]);
    const stop = !bloqueaPre && c.esp ? c.esp(r) : null;
    if (stop) bloques.push(`<div class="mb-3 border border-sky-800 bg-sky-950/20 rounded-xl p-3 text-sm text-sky-200">${esc(stop)}</div>`);
    if (!bloqueaPre && !stop) {
        bloques.push(`<div class="mb-3"><div class="text-slate-100 font-medium">${c.qAlc}</div>${radios('alc', c.alc.map(o => [o[0], o[1]]), r.alc)}</div>`);
        if (r.alc === 'una_etapa') {
            bloques.push(`<div class="mb-3"><div class="text-slate-100 font-medium">¿De cuál etapa?</div>${radios('centro', S.centros.map(x => [String(x.id), `${esc(x.codigo)} · ${esc(x.nombre)}`]), r.centro)}</div>`);
        }
        if (r.alc === 'manual') bloques.push(editorManual());
        if (Q_FREC.cuando(c) && r.alc && r.alc !== 'al_capturar') {
            bloques.push(`<div class="mb-3"><div class="text-slate-100 font-medium">${Q_FREC.texto}</div>${radios('frec', Q_FREC.opciones, r.frec)}</div>`);
        }
    }
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n}</h3>
      <p class="text-xs text-slate-400 mb-3">${c.d}</p>
      ${bloques.join('')}
      ${barraBotones(btn('caso-volver', '← Otros gastos', BTN_SEC), btn('caso-resumen', 'Ver resumen →', BTN_AZ))}`;
}
function editorManual() {
    const r = S.resp;
    const sum = S.centros.reduce((s, c) => s + num(r['pct_' + c.id]), 0) + num(r.pct_of);
    return `
      <div class="mb-3 border border-slate-800 rounded-xl p-3 bg-slate-950">
        <div class="text-slate-100 font-medium">¿Qué porcentaje le toca a cada destino? <span class="text-xs text-slate-500 font-normal">(deben sumar 100%)</span></div>
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 mt-2">
          ${S.centros.map(c => `<label class="text-[11px] text-slate-400">${esc(c.codigo)} · ${esc(c.nombre)}<input type="number" min="0" max="100" step="0.01" class="${INPUT} w-full mt-1 text-right font-mono" data-resp-pct="pct_${c.id}" value="${r['pct_' + c.id] ?? ''}"></label>`).join('')}
          <label class="text-[11px] text-slate-400">Oficina (a resultados)<input type="number" min="0" max="100" step="0.01" class="${INPUT} w-full mt-1 text-right font-mono" data-resp-pct="pct_of" value="${r.pct_of ?? ''}"></label>
        </div>
        <div class="text-[11px] mt-2 ${Math.abs(sum - 100) < 0.01 ? 'text-emerald-400' : 'text-amber-400'}" id="apSumaPct">Suma: ${fnum(sum, 2)}%</div>
      </div>`;
}

// --- cálculo de la recomendación -------------------------------------
function fraccionesBase(base, solo) {
    // devuelve { prod: Map(centroId->fracción), of: fracción } normalizado
    const filas = S.bases.filter(b => b.base === base);
    const prod = new Map();
    let of = 0;
    filas.forEach(b => {
        const f = Number(b.fraccion || 0);
        if (b.rol === 'produccion' && b.centro_costo_id) prod.set(b.centro_costo_id, (prod.get(b.centro_costo_id) || 0) + f);
        else if (b.rol === 'no_produccion') of += f;
    });
    if (solo) {
        const t = [...prod.values()].reduce((s, x) => s + x, 0);
        if (t > 0) for (const [k, v] of prod) prod.set(k, v / t);
        of = 0;
    }
    return { prod, of };
}
function tieneDatos(base) {
    if (base === 'partes_iguales') return S.centros.length > 0;
    return S.bases.some(b => b.base === base && Number(b.valor) > 0);
}
function resolver(c, r) {
    if (c.esp) { const e = c.esp(r); if (e) return { stop: e }; }
    const opt = c.alc.find(o => o[0] === r.alc);
    const notas = (c.avisos ? c.avisos(r) : []).slice();
    const cif = c.cif || (r.frec === 'contrato' ? 'fijo' : 'variable');
    const R = { caso: c, cif, notas, opt };
    if (opt[0] === 'al_capturar') { R.modo = 'ninguno'; return R; }
    if (opt[0] === 'una_etapa') {
        R.modo = 'manual'; R.lineas = [{ centroId: Number(r.centro), pct: 100 }]; R.ofPct = 0;
        R.desc = `100% a la etapa ${centroLbl(r.centro)}`;
        return R;
    }
    if (opt[0] === 'manual') {
        R.modo = 'manual';
        R.lineas = S.centros.map(x => ({ centroId: x.id, pct: num(r['pct_' + x.id]) })).filter(l => l.pct > 0);
        R.ofPct = num(r.pct_of);
        const suma = R.lineas.reduce((s, l) => s + l.pct, 0) + R.ofPct;
        if (Math.abs(suma - 100) > 0.01) R.error = `Los porcentajes suman ${fnum(suma, 2)}%, deben sumar 100%.`;
        R.desc = 'Porcentajes definidos por ti';
        return R;
    }
    const base = opt[2], solo = !!opt[3];
    R.base = base; R.solo = solo;
    if (!tieneDatos(base)) {
        const donde = base === 'kw' ? 'el paso 3 (Luz)' : 'el paso 2 (Áreas)';
        R.error = `Todavía no hay datos de ${base === 'm2' ? 'm²' : base === 'kw' ? 'carga eléctrica' : 'personas'} para calcular este reparto. Complétalos en ${donde}.`;
        return R;
    }
    if (solo && base !== 'partes_iguales') {
        const f = fraccionesBase(base, true);
        R.modo = 'manual'; R.lineas = [...f.prod].map(([centroId, p]) => ({ centroId, pct: Math.round(p * 10000) / 100 })); R.ofPct = 0;
        const s = R.lineas.reduce((a, l) => a + l.pct, 0);
        if (R.lineas.length && s !== 100) R.lineas[R.lineas.length - 1].pct = Math.round((R.lineas[R.lineas.length - 1].pct + 100 - s) * 100) / 100;
        R.snapshot = true;
        R.desc = `Solo producción, repartido por ${base === 'm2' ? 'm²' : base === 'kw' ? 'kW' : 'personas'}`;
        notas.push('Los porcentajes quedan fijos con los datos de hoy (la oficina queda fuera). Si cambian tus áreas, vuelve a correr este caso para actualizarlos.');
    } else if (base === 'partes_iguales') {
        R.modo = 'plantilla'; R.desc = 'Partes iguales entre las etapas';
    } else {
        R.modo = 'plantilla'; R.desc = `Por ${base === 'm2' ? 'superficie (m²)' : base === 'kw' ? 'carga eléctrica (kW)' : 'número de personas'}: producción por etapa y la parte de oficina a resultados`;
    }
    return R;
}
function previa(R, monto) {
    if (R.modo === 'manual') {
        const filas = R.lineas.map(l => ({ lbl: `Etapa ${centroLbl(l.centroId)}`, pct: l.pct / 100, monto: monto * l.pct / 100 }));
        if (R.ofPct > 0) filas.push({ lbl: 'Oficina → resultados (601.xx)', pct: R.ofPct / 100, monto: monto * R.ofPct / 100, of: true });
        return filas;
    }
    if (R.modo === 'plantilla') {
        if (R.base === 'partes_iguales') return S.centros.map(c => ({ lbl: `Etapa ${c.codigo}`, pct: 1 / S.centros.length, monto: monto / S.centros.length }));
        const f = fraccionesBase(R.base, false);
        const filas = [...f.prod].filter(([, p]) => p > 0).map(([id, p]) => ({ lbl: `Etapa ${centroLbl(id)}`, pct: p, monto: monto * p }));
        if (f.of > 0) filas.push({ lbl: 'Oficina → resultados (601.xx)', pct: f.of, monto: monto * f.of, of: true });
        return filas;
    }
    return [];
}
const necesitaOficina = (R, prev) => prev.some(f => f.of);

function opcionesCuentas(filtro, valor, extra = '') {
    return `${extra}${S.cuentas.filter(filtro).map(c => `<option value="${c.id}"${String(valor) === String(c.id) ? ' selected' : ''}>${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('')}`;
}
function rCaso(c) {
    const R = S.R;
    if (R.stop) {
        return `<h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n}</h3>
          <div class="border border-sky-800 bg-sky-950/20 rounded-xl p-3 text-sm text-sky-200">${esc(R.stop)}</div>
          ${barraBotones(btn('caso-pregs', '← Cambiar respuestas', BTN_SEC), btn('caso-volver', 'Entendido, otro gasto', BTN_AZ))}`;
    }
    if (R.error) {
        return `<h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n}</h3>
          <div class="border border-amber-800 bg-amber-950/20 rounded-xl p-3 text-sm text-amber-300">${esc(R.error)}</div>
          ${barraBotones(btn('caso-pregs', '← Cambiar respuestas', BTN_SEC))}`;
    }
    const cta = ctaPorCodigo(c.cta);
    const prev = previa(R, 10000);
    const ctaOf = ctaPorCodigo(c.of);
    const ctaProdSel = cta ? cta.id : 'NUEVA';
    const tipoActual = cta?.cif_tipo || null;
    const prod503 = (x) => x.codigo.startsWith('503.') && x.afectable && x.codigo !== '503.98';
    const ctaNuevaTxt = `＋ Crear cuenta ${c.cta} · ${CTA_NOMBRES[c.cta] || c.n}`;
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">${c.i} ${c.n} · Resumen antes de guardar</h3>
      <div class="text-xs text-slate-400 mb-3">${esc(c.porque)}</div>
      ${R.notas.length ? `<div class="mb-3 space-y-1">${R.notas.map(n => `<div class="text-xs text-amber-400">⚠ ${esc(n)}</div>`).join('')}</div>` : ''}
      ${R.modo === 'ninguno' ? `
        <div class="border border-slate-800 rounded-xl p-3 bg-slate-950 text-xs text-slate-300">No creo una regla fija: cada factura se decide al capturarla. En <b>Gastos</b> elige la cuenta, clasifícalo como "Indirecto de fabricación" y usa <b>"Todo a un centro"</b> con la etapa que corresponda.</div>`
      : `
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-3">
          <div class="border border-slate-800 rounded-xl p-3 bg-slate-950 space-y-2">
            <div class="text-xs text-slate-500">Cómo se reparte</div>
            <div class="text-slate-100">${esc(R.desc)}</div>
            <label class="block text-[11px] text-slate-400">Cuenta del gasto de planta
              <select id="apSelCta" class="${INPUT} w-full mt-1 text-xs">${opcionesCuentas(prod503, ctaProdSel, cta ? '' : `<option value="NUEVA" selected>${esc(ctaNuevaTxt)}</option>`)}${cta ? `<option value="NUEVA">${esc(ctaNuevaTxt)}</option>` : ''}</select></label>
            ${necesitaOficina(R, prev) ? `<label class="block text-[11px] text-slate-400">Cuenta de la parte de oficina
              <select id="apSelOf" class="${INPUT} w-full mt-1 text-xs">${opcionesCuentas((x) => x.afectable && (x.tipo === 'gasto' || x.tipo === 'costo') && x.codigo.startsWith('601.'), ctaOf?.id, ctaOf ? '' : '<option value="">— elige —</option>')}</select></label>` : ''}
            <label class="block text-[11px] text-slate-400">Tipo de gasto de la cuenta
              <select id="apSelCif" class="${INPUT} w-full mt-1 text-xs"><option value="fijo"${R.cif === 'fijo' ? ' selected' : ''}>Fijo (no cambia con el volumen)</option><option value="variable"${R.cif === 'variable' ? ' selected' : ''}>Variable (cambia con el volumen)</option></select></label>
            ${tipoActual && tipoActual !== R.cif ? `<div class="text-[11px] text-amber-400">La cuenta hoy está como ${tipoActual}. Cambiarla afecta a todos los gastos nuevos de esa cuenta que no traigan su propio tipo.</div>` : ''}
            <label class="block text-[11px] text-slate-400">¿Siempre te lo factura el mismo proveedor? (opcional)
              <select id="apSelProv" class="${INPUT} w-full mt-1 text-xs"><option value="">— cualquier proveedor —</option></select></label>
            ${tip('Con proveedor, la regla solo se propone para ese proveedor; sirve cuando varios gastos comparten la misma cuenta.')}
            ${R.modo === 'manual' && R.lineas.length === 1 ? tip('Esta regla se propondrá cada vez que captures un gasto con esta cuenta. Si a veces es de otra etapa, usa la opción "Depende de cada factura" o liga la regla a un proveedor.') : ''}
          </div>
          <div class="border border-slate-800 rounded-xl p-3 bg-slate-950">
            <div class="text-xs text-slate-500 mb-1">Ejemplo con un gasto de ${money(10000)}</div>
            <table class="w-full text-xs"><tbody>${prev.map(f => `<tr class="border-b border-slate-900"><td class="p-1.5 ${f.of ? 'text-amber-400' : 'text-slate-200'}">${esc(f.lbl)}</td><td class="p-1.5 text-right font-mono text-slate-400">${pct(f.pct)}</td><td class="p-1.5 text-right font-mono ${f.of ? 'text-amber-400' : 'text-emerald-400'}">${money(f.monto)}</td></tr>`).join('')}</tbody></table>
            ${R.cif === 'fijo' ? tip('Por ser FIJO, al prorratear solo se aplica a las órdenes la parte que corresponde a las horas realmente trabajadas contra la capacidad normal; el resto es capacidad no utilizada.') : tip('Por ser VARIABLE, se aplica completo a las órdenes del mes (siempre que haya horas trabajadas).')}
          </div>
        </div>
        <div class="mt-3 text-[11px] text-slate-500">Voy a guardar: ${cta ? '' : `la cuenta nueva <b>${c.cta}</b>, `}la regla de reparto <b>"${esc(c.n)}"</b>${tipoActual !== R.cif ? ' y el tipo fijo/variable de la cuenta' : ''}.</div>`}
      ${barraBotones(btn('caso-pregs', '← Corregir', BTN_SEC), R.modo === 'ninguno' ? btn('caso-volver', 'Entendido, otro gasto', BTN_AZ) : btn('caso-guardar', '✅ Confirmar y guardar', BTN_OK))}`;
}
async function cargarProveedores() {
    const sel = q('#apSelProv');
    if (!sel) return;
    if (!S.proveedores) {
        const { data } = await supabaseClient.from('proveedores').select('id, nombre').order('nombre');
        S.proveedores = data || [];
    }
    if (!q('#apSelProv')) return;
    sel.innerHTML = `<option value="">— cualquier proveedor —</option>` + S.proveedores.map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('');
}
async function guardarCaso() {
    const c = CASOS.find(x => x.id === S.caso), R = S.R;
    const selCta = q('#apSelCta')?.value;
    const cif = q('#apSelCif')?.value || R.cif;
    const provId = q('#apSelProv')?.value ? Number(q('#apSelProv').value) : null;
    let ctaId;
    if (!selCta || selCta === 'NUEVA') {
        const padre = ctaPorCodigo('503');
        const ins = await supabaseClient.from('cuentas_contables').insert([{
            codigo: c.cta, codigo_agrupador: '504.01',   // SAT (Anexo 24): 504.01 Gastos indirectos de fabricación; 503 del SAT es otra cosa
             nombre: CTA_NOMBRES[c.cta] || c.n, tipo: 'costo', naturaleza: 'D',
            cuenta_padre_id: padre?.id || null, nivel: padre ? (padre.nivel || 1) + 1 : 2, afectable: true, activa: true, cif_tipo: cif,
        }]).select('id').single();
        if (ins.error) throw ins.error;
        ctaId = ins.data.id;
    } else {
        ctaId = Number(selCta);
        const cta = S.cuentas.find(x => x.id === ctaId);
        if (cta && cta.cif_tipo !== cif) {
            const { error } = await supabaseClient.from('cuentas_contables').update({ cif_tipo: cif }).eq('id', ctaId);
            if (error) throw error;
        }
    }
    if (R.modo !== 'ninguno') {
        const prev = previa(R, 10000);
        const ofSel = q('#apSelOf')?.value;
        const ofId = ofSel ? Number(ofSel) : null;
        if (necesitaOficina(R, prev) && !ofId) throw new Error('Elige la cuenta de la parte de oficina.');
        const prov = provId ? (S.proveedores || []).find(p => p.id === provId) : null;
        const fila = {
            nombre: prov ? `${c.n} · ${prov.nombre}` : c.n, cuenta_id: ctaId, proveedor_id: provId,
            base: R.modo === 'manual' ? 'manual' : R.base, cuenta_no_produccion_id: ofId, activo: true,
            notas: `${R.desc}. Creada con el asistente de prorrateo (${hoyISO()}).`,
        };
        const existente = S.plantillas.find(p => p.cuenta_id === ctaId && (p.proveedor_id || null) === provId);
        let plId;
        if (existente) {
            const { error } = await supabaseClient.from('reparto_plantillas').update(fila).eq('id', existente.id);
            if (error) throw error;
            plId = existente.id;
            const del = await supabaseClient.from('reparto_plantilla_lineas').delete().eq('plantilla_id', plId);
            if (del.error) throw del.error;
        } else {
            const ins = await supabaseClient.from('reparto_plantillas').insert([fila]).select('id').single();
            if (ins.error) throw ins.error;
            plId = ins.data.id;
        }
        if (R.modo === 'manual') {
            const lineas = R.lineas.map(l => ({ plantilla_id: plId, destino: 'produccion', centro_costo_id: l.centroId, porcentaje: l.pct }));
            if (R.ofPct > 0) lineas.push({ plantilla_id: plId, destino: 'no_produccion', cuenta_resultados_id: ofId, porcentaje: R.ofPct });
            if (lineas.some(l => l.destino === 'no_produccion' && !l.cuenta_resultados_id)) throw new Error('Elige la cuenta de la parte de oficina.');
            const { error } = await supabaseClient.from('reparto_plantilla_lineas').insert(lineas);
            if (error) throw error;
        }
    }
    await cargarBase();
}

// ---------------------------------------------------------------------
// PASO 5 · REVISIÓN Y SIMULACIÓN
// ---------------------------------------------------------------------
function vRevision() {
    return `
      <h3 class="text-base font-semibold text-sky-300 mb-1">5 · Revisión y simulación</h3>
      <div class="flex flex-wrap items-end gap-3 mb-3">
        <label class="text-xs text-slate-400">Mes a revisar<input type="month" id="apRevMes" value="${S.rev?.mes || mesISO()}" class="${INPUT} block mt-1"></label>
      </div>
      <div id="apRevCuerpo" class="space-y-3"><p class="text-slate-500 text-xs">Revisando…</p></div>`;
}
async function cargarRevision() {
    const mes = q('#apRevMes')?.value || mesISO();
    const ini = `${mes}-01`, fin = sigMes(ini);
    S.rev = { mes };
    const est = estadoPasos();
    const [g, rt, act] = await Promise.all([
        supabaseClient.from('gastos')
            .select('id, concepto, subtotal, clasificacion, cif_tipo, prorrateo_estatus, cuenta_gasto:cuentas_contables!cuenta_gasto_id(codigo, cif_tipo)')
            .eq('estatus', 'registrado').gte('fecha', ini).lt('fecha', fin).limit(500),
        supabaseClient.from('registros_tiempo').select('id', { count: 'exact', head: true }).not('fin', 'is', null).gte('inicio', ini).lt('inicio', fin),
        datosActivos(),
    ]);
    if (!q('#apRevCuerpo')) return;
    const gastos = g.data || [];
    const indirectos = gastos.filter(x => x.clasificacion === 'indirecto_produccion');
    const sinTipo = indirectos.filter(x => !x.cif_tipo && !x.cuenta_gasto?.cif_tipo);
    const mal = gastos.filter(x => x.cuenta_gasto?.codigo?.startsWith('503.') && x.cuenta_gasto.codigo !== '503.98' && x.clasificacion !== 'indirecto_produccion');
    const horas = rt.count || 0;
    const sinCap = S.centros.filter(c => !(Number(c.capacidad_normal_horas) > 0));
    const sinEtapas = (act.activos || []).filter(a => !a.etapas || !a.etapas.length);
    const depItem = act.sinMigracion && act.activos.length
        ? '<div class="border border-amber-900 bg-amber-950/10 rounded-lg px-3 py-2 text-xs text-amber-300">⚠ Tienes maquinaria con cuenta 503.xx, pero falta correr <span class="font-mono">sql/2026-10-14_depreciacion_al_prorrateo.sql</span> para que su depreciación entre al prorrateo.</div>'
        : (sinEtapas.length
            ? `<div class="border border-amber-900 bg-amber-950/10 rounded-lg px-3 py-2 text-xs text-amber-300">⚠ Maquinaria sin etapas (su depreciación no se prorratea): ${sinEtapas.map(a => esc(a.nombre)).join(', ')}. Márcalas en Activos fijos.</div>`
            : '');
    const item = (ok, t, paso) => `<div class="flex items-start justify-between gap-2 border border-slate-800 rounded-lg px-3 py-2 bg-slate-950"><div class="text-xs ${ok ? 'text-slate-300' : 'text-amber-400'}">${ok ? '✅' : '⚠'} ${t}</div>${!ok && paso ? btn('ir', 'Ir al paso', BTN_SEC + ' !py-1 !px-3 text-xs', `data-paso="${paso}"`) : ''}</div>`;
    const totInd = indirectos.reduce((s, x) => s + Number(x.subtotal || 0), 0);
    q('#apRevCuerpo').innerHTML = `
      ${item(est.centros, est.centros ? 'Todas las etapas tienen capacidad normal.' : `Faltan capacidades: ${sinCap.map(c => esc(c.codigo)).join(', ') || 'revisa los centros'}.`, 'centros')}
      ${item(est.areas, est.areas ? 'Las áreas tienen m², personas, etapa y hay oficina.' : 'Faltan datos en las áreas (m², personas, etapa u oficina).', 'areas')}
      ${item(est.luz, est.luz ? 'Todas las áreas de producción tienen carga eléctrica.' : 'Hay áreas de producción sin datos de luz.', 'luz')}
      ${item(est.casos, est.casos ? `Hay ${S.plantillas.filter(p => p.activo).length} regla(s) de reparto activa(s).` : 'No hay reglas de reparto: configura al menos tus gastos compartidos.', 'casos')}
      ${item(horas > 0, horas > 0 ? `Hay ${horas} registro(s) de tiempo de producción en ${mes} (de ahí salen las horas de mano de obra).` : `No hay registros de tiempo cerrados en ${mes}: sin horas trabajadas no hay a quién repartirle el CIF. Se capturan en la app Orden de trabajo.`)}
      ${item(sinTipo.length === 0, sinTipo.length ? `${sinTipo.length} gasto(s) indirecto(s) de ${mes} sin tipo fijo/variable (se tratarán como variables): ${sinTipo.slice(0, 5).map(x => esc(x.concepto)).join(', ')}.` : `Gastos indirectos de ${mes}: ${indirectos.length} por ${money(totInd)}, todos con tipo fijo/variable.`)}
      ${item(mal.length === 0, mal.length ? `${mal.length} gasto(s) están en cuentas 503.xx pero NO marcados como "Indirecto de fabricación", así que no entran al prorrateo: ${mal.slice(0, 5).map(x => esc(x.concepto)).join(', ')}.` : 'No hay gastos en cuentas 503.xx sin clasificar como indirectos.')}
      ${depItem}
      <div class="border border-slate-800 rounded-xl p-3 bg-slate-950">
        <div class="font-semibold text-slate-100 mb-2">Simulación de una regla de reparto</div>
        <div class="flex flex-wrap items-end gap-3">
          <label class="text-xs text-slate-400">Regla<select id="apSimPl" class="${INPUT} block mt-1 text-xs">${S.plantillas.filter(p => p.activo).map(p => `<option value="${p.id}">${esc(p.nombre)}</option>`).join('') || '<option value="">(sin reglas)</option>'}</select></label>
          <label class="text-xs text-slate-400">Monto del gasto<input type="number" id="apSimMonto" min="0" step="0.01" value="10000" class="${INPUT} block mt-1 w-32 text-right font-mono"></label>
          ${btn('rev-sim', 'Simular', BTN_AZ)}
        </div>
        <div id="apSimRes" class="mt-3 text-xs"></div>
      </div>
      ${barraBotones(btn('ir-prorrateo', 'Ir a Prorrateo de gastos →', BTN_OK))}`;
}
async function simular() {
    const id = Number(q('#apSimPl')?.value), monto = num(q('#apSimMonto')?.value);
    const out = q('#apSimRes');
    if (!id || !(monto > 0)) { out.innerHTML = '<span class="text-amber-400">Elige una regla y un monto.</span>'; return; }
    out.textContent = 'Calculando…';
    const { data, error } = await supabaseClient.rpc('_reparto_resolver', { p_plantilla_id: id, p_subtotal: monto });
    if (error) { out.innerHTML = `<span class="text-rose-400">${esc(error.message)}</span>`; return; }
    const filas = data || [];
    out.innerHTML = filas.length
        ? `<table class="w-full"><thead><tr class="text-left text-slate-500 border-b border-slate-800"><th class="p-1.5">Destino</th><th class="p-1.5 text-right">%</th><th class="p-1.5 text-right">Monto</th></tr></thead><tbody>${filas.map(f => `<tr class="border-b border-slate-900"><td class="p-1.5 ${f.destino === 'produccion' ? 'text-slate-200' : 'text-amber-400'}">${f.destino === 'produccion' ? 'Etapa ' + esc(centroLbl(f.centro_costo_id)) : 'Oficina → ' + esc(ctaLbl(f.cuenta_id))}</td><td class="p-1.5 text-right font-mono text-slate-400">${fnum(f.porcentaje, 2)}%</td><td class="p-1.5 text-right font-mono text-emerald-400">${money(f.monto)}</td></tr>`).join('')}</tbody></table>`
        : '<span class="text-amber-400">La regla no produjo reparto: revisa que existan áreas con datos de esa base.</span>';
}

// ---------------------------------------------------------------------
// Eventos
// ---------------------------------------------------------------------
async function conGuardado(fn, okMsg, siguiente) {
    msg('', 'Guardando…');
    try {
        await fn();
        S.aviso = { t: 'ok', m: okMsg };
        S.fase = {};
        siguiente();
    } catch (err) {
        msg('err', err.message || String(err));
    }
}

async function onClick(e) {
    const b = e.target.closest('[data-act]');
    if (!b || !S) return;
    const act = b.dataset.act;
    switch (act) {
        case 'cerrar': cerrar(); return;
        case 'ir': S.paso = b.dataset.paso; S.caso = null; S.fase = {}; pintar(); return;
        case 'ir-prorrateo': {
            const cb = S.onCerrar;
            S.modal.remove(); S = null;
            if (typeof cb === 'function') cb(); else if (window.loadView) window.loadView('prorrateo');
            return;
        }
        case 'volver': setFase('p'); pintar(); return;

        case 'centros-resumen': {
            const b2 = leerCentrosDOM();
            if (b2.some(x => !(x.op > 0))) { msg('err', 'Indica cuántas personas trabajan en cada etapa (más de 0).'); return; }
            S.borr.centros = b2; setFase('r'); pintar(); return;
        }
        case 'centros-guardar':
            await conGuardado(guardarCentros, '✅ Capacidad de las etapas guardada.', () => { S.paso = 'areas'; pintar(); });
            return;

        case 'area-nueva': S.filasAreas = leerAreasDOM(); S.filasAreas.push({ key: 'n' + Date.now(), codigo: '', nombre: '', rol: 'produccion', m2: 0, personas: 0, activo: true }); pintar(true); return;
        case 'area-sug': {
            const s = AREAS_SUG.find(x => x.codigo === b.dataset.codigo);
            S.filasAreas = leerAreasDOM(); S.filasAreas.push({ key: 'n' + Date.now(), codigo: s.codigo, nombre: s.nombre, rol: s.rol, m2: 0, personas: 0, activo: true }); pintar(true); return;
        }
        case 'area-quitar': S.filasAreas = leerAreasDOM().filter(a => a.key !== b.dataset.key); pintar(true); return;
        case 'areas-resumen': {
            const lista = leerAreasDOM();
            const v = validarAreas(lista);
            if (v.err.length) { S.filasAreas = lista; msg('err', v.err[0]); return; }
            S.filasAreas = lista; S.borr.areas = lista; S.borr.areasAvisos = v.avisos; setFase('r'); pintar(); return;
        }
        case 'areas-guardar':
            await conGuardado(guardarAreas, '✅ Áreas guardadas.', () => { S.paso = 'luz'; S.luz = null; pintar(); });
            return;

        case 'luz-add': leerLuzDOM(); S.luz[b.dataset.area].nuevas.push(nuevoEquipo(b.dataset.area)); pintar(true); return;
        case 'luz-sug': {
            leerLuzDOM();
            const [d, t] = EQUIPOS_SUG[Number(b.dataset.i)];
            S.luz[b.dataset.area].nuevas.push(nuevoEquipo(b.dataset.area, d, t)); pintar(true); return;
        }
        case 'luz-del': leerLuzDOM(); S.luz[b.dataset.area].nuevas.splice(Number(b.dataset.i), 1); pintar(true); return;
        case 'luz-resumen': {
            leerLuzDOM();
            const errores = erroresLuz();
            if (errores.length) { msg('err', errores.length > 1 ? `${errores[0]} (y ${errores.length - 1} más por completar)` : errores[0]); return; }
            setFase('r'); pintar(); return;
        }
        case 'luz-guardar':
            await conGuardado(guardarLuz, '✅ Datos de luz guardados.', () => { S.paso = 'casos'; S.caso = null; pintar(); });
            return;

        case 'caso-abrir': S.caso = b.dataset.id; S.resp = {}; S.R = null; setFase('p'); pintar(); return;
        case 'caso-volver': S.caso = null; setFase('p'); pintar(); return;
        case 'caso-pregs': setFase('p'); pintar(); return;
        case 'caso-resumen': {
            const c = CASOS.find(x => x.id === S.caso);
            if ((c.pre || []).some(p => !S.resp[p.id])) { msg('err', 'Contesta la pregunta para continuar.'); return; }
            if (c.esp && c.esp(S.resp)) { S.R = resolver(c, S.resp); setFase('r'); pintar(); return; }
            if (!S.resp.alc) { msg('err', 'Elige una opción.'); return; }
            if (S.resp.alc === 'una_etapa' && !S.resp.centro) { msg('err', 'Elige la etapa.'); return; }
            if (Q_FREC.cuando(c) && S.resp.alc !== 'al_capturar' && !S.resp.frec) { msg('err', 'Indica cómo se paga.'); return; }
            S.R = resolver(c, S.resp);
            setFase('r'); pintar();
            if (!S.R.stop && !S.R.error && S.R.modo !== 'ninguno') cargarProveedores();
            return;
        }
        case 'caso-guardar': {
            const c = CASOS.find(x => x.id === S.caso);
            await conGuardado(guardarCaso, `✅ ${c.n}: regla de reparto guardada.`, () => { S.caso = null; setFase('p'); pintar(); });
            return;
        }
        case 'rev-sim': simular(); return;
    }
}

function onChange(e) {
    if (!S) return;
    const t = e.target;
    if (t.matches('[data-resp]')) {
        S.resp[t.dataset.resp] = t.value;
        if (t.dataset.resp === 'alc') { delete S.resp.centro; }
        pintar(true);
        return;
    }
    if (t.matches('[data-luzmodo]') || t.matches('[data-eqdep]')) { leerLuzDOM(); pintar(true); return; }
    if (t.id === 'apRevMes') { cargarRevision(); return; }
}

function onInput(e) {
    if (!S) return;
    const t = e.target;
    const cen = t.closest('[data-centro]');
    if (cen && t.dataset.f) {
        const g = (f) => num(cen.querySelector(`[data-f="${f}"]`).value);
        cen.querySelector('[data-cap]').textContent = fnum(capCalc({ op: g('op'), jor: g('jor'), dias: g('dias'), fa: g('fa'), fnp: g('fnp'), fpp: g('fpp') }));
        return;
    }
    if (t.dataset.respPct) {
        S.resp[t.dataset.respPct] = t.value;
        const sum = S.centros.reduce((s, c) => s + num(S.resp['pct_' + c.id]), 0) + num(S.resp.pct_of);
        const el = q('#apSumaPct');
        if (el) { el.textContent = `Suma: ${fnum(sum, 2)}%`; el.className = 'text-[11px] mt-2 ' + (Math.abs(sum - 100) < 0.01 ? 'text-emerald-400' : 'text-amber-400'); }
    }
}
