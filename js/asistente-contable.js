// =====================================================================
// Asistente de Contabilidad — panel colapsable de ayuda por pantalla.
//   · montarGuia(cont, clave)  -> guía "para qué sirve / pasos / cuándo /
//     errores comunes" (pantallas sin campos que clasificar).
//   · crearPanelAsistente(...) -> el chrome colapsable reutilizable
//     (lo usa también el asistente de captura de Gastos, en contabilidad.js).
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const LS = (k) => 'asist:' + k;

export function crearPanelAsistente({ clave, titulo, subtitulo = 'ayuda para esta pantalla', abiertoPorDefecto = false }) {
    let abierto = abiertoPorDefecto;
    try { const v = localStorage.getItem(LS(clave)); if (v === '1') abierto = true; if (v === '0') abierto = false; } catch (_) { /* */ }

    const wrap = document.createElement('div');
    wrap.className = 'asist-panel border border-slate-800 rounded-xl bg-slate-950 mb-4 overflow-hidden';
    wrap.innerHTML = `
      <button type="button" class="asist-tgl w-full flex items-center justify-between gap-3 px-4 py-2.5 text-left hover:bg-slate-900/60 transition">
        <span class="text-sm font-semibold text-sky-400"><span class="asist-arrow inline-block w-3">${abierto ? '▾' : '▸'}</span> Asistente — ${esc(titulo)}</span>
        <span class="text-[11px] text-slate-500 shrink-0 hidden sm:inline">${esc(subtitulo)}</span>
      </button>
      <div class="asist-body ${abierto ? '' : 'hidden'} px-4 pb-4 pt-1 text-xs text-slate-300 leading-relaxed space-y-3"></div>`;

    const body = wrap.querySelector('.asist-body');
    const arrow = wrap.querySelector('.asist-arrow');
    wrap.querySelector('.asist-tgl').addEventListener('click', () => {
        const ab = body.classList.toggle('hidden') === false;
        arrow.textContent = ab ? '▾' : '▸';
        try { localStorage.setItem(LS(clave), ab ? '1' : '0'); } catch (_) { /* */ }
    });
    return { wrap, body };
}

export const GUIAS = {
    'plan-cuentas': {
        titulo: 'Plan de cuentas',
        paraQue: 'El catálogo de todas las cuentas contables — los "cajones" donde se acumula cada tipo de movimiento. Ya viene cargado con el Código Agrupador del SAT.',
        pasos: [
            'Búscala por código o por nombre.',
            'En una cuenta de gasto indirecto (503.xx), revisa que el campo Tipo CIF diga "fijo" o "variable".',
            'Si te falta una cuenta, créala dentro de su grupo (ej. 503.10) con su naturaleza (D/A) y su tipo.',
        ],
        cuando: 'Una vez al inicio para revisar; después casi no se toca.',
        errores: [
            'Cambiar el código o borrar una cuenta que ya tiene movimientos.',
            'Capturar gastos en 503.98 (capacidad no utilizada): esa cuenta la mueve el sistema solo.',
        ],
    },
    'polizas': {
        titulo: 'Pólizas',
        paraQue: 'Ver los asientos contables (cargos y abonos) que el sistema generó por cada gasto, nómina, producción o prorrateo.',
        pasos: [
            'Filtra por fecha, tipo u origen.',
            'Abre una póliza para ver sus movimientos y su cuadre (Σ cargos = Σ abonos).',
            'Para corregir, cancela desde el origen (el gasto, la corrida de prorrateo), no aquí.',
        ],
        cuando: 'Cuando necesitas rastrear de dónde salió un movimiento o revisar que todo cuadre.',
        errores: [
            'Intentar "arreglar" una póliza a mano — siempre se corrige cancelando y rehaciendo la operación que la generó.',
        ],
    },
    'reportes-contables': {
        titulo: 'Reportes contables',
        paraQue: 'Balanza de comprobación, estado de resultados y saldos por cuenta a una fecha.',
        pasos: [
            'Elige el periodo.',
            'Revisa la cuenta 503.98 (capacidad no utilizada): si crece mes a mes, tienes planta que pagas y no usas.',
            'Revisa 115.03 (producción en proceso): debería quedar cerca de cero tras cerrar órdenes y correr el prorrateo.',
        ],
        cuando: 'Al cierre de cada mes, después del prorrateo.',
        errores: ['Leer los números antes de haber corrido el prorrateo del mes: faltaría todo el CIF.'],
    },
    'pagos-proveedor': {
        titulo: 'Cuentas por pagar',
        paraQue: 'Lo que le debes a cada proveedor por gastos y compras a crédito, y el registro de sus pagos.',
        pasos: [
            'Filtra por proveedor o por antigüedad del saldo.',
            'Registra un pago eligiendo la cuenta de banco / caja y el monto.',
            'El pago genera su póliza y baja el saldo del proveedor.',
        ],
        cuando: 'Cuando vas a pagar, o para saber cuánto debes.',
        errores: [
            'Registrar el mismo pago dos veces.',
            'Pagar desde una cuenta de banco distinta a la real: el saldo del banco queda mal.',
        ],
    },
    'nomina': {
        titulo: 'Nómina',
        paraQue: 'Calcular y contabilizar la nómina del periodo: sueldos, cuotas IMSS/INFONAVIT e ISR retenido.',
        pasos: [
            'Genera el borrador del periodo.',
            'Revisa percepciones, deducciones y días trabajados por empleado.',
            'Confírmala: se genera la póliza y la mano de obra de producción queda disponible para el costeo de las órdenes.',
        ],
        cuando: 'Cada periodo de pago.',
        errores: ['Confirmar sin revisar los días trabajados.', 'Correrla dos veces para el mismo periodo.'],
    },
    'isr': {
        titulo: 'Tabla ISR',
        paraQue: 'Las tarifas de ISR (LISR art. 96) y el subsidio al empleo que usa el cálculo de nómina.',
        pasos: [
            'Revisa que la periodicidad (mensual / quincenal / semanal) y el año sean los vigentes.',
            'Si el SAT publica tarifas nuevas, actualízalas aquí antes de correr la nómina.',
        ],
        cuando: 'Al inicio del año o cuando cambien las tarifas.',
        errores: ['Mezclar tarifas de distintas periodicidades.'],
    },
    'prorrateo': {
        titulo: 'Prorrateo de gastos',
        paraQue: 'Repartir, una vez al mes, los gastos indirectos de fabricación (CIF) entre las órdenes de producción y la capacidad no utilizada.',
        pasos: [
            'Elige el mes.',
            'Revisa las tarjetas: CIF pendiente (fijo/variable), horas de mano de obra vs capacidad, distribución.',
            'Revisa la tabla "Distribución propuesta" por centro y orden.',
            'Aplica. Si llega un gasto tarde: Cancelar el mes, capturarlo y volver a aplicar.',
        ],
        cuando: 'Fin de mes, después de capturar todos los gastos indirectos y cerrar la producción del mes.',
        errores: [
            'Aplicar antes de capturar todos los gastos indirectos.',
            'Dejar la capacidad normal de un centro en 0: el CIF fijo se repartiría entre pocas unidades e inflaría el costo.',
        ],
    },
    'centros-costo': {
        titulo: 'Centros de costo',
        paraQue: 'Las 3 etapas de fabricación (SURT, MEZ, ENV) donde se acumulan mano de obra y CIF. Cada una guarda su capacidad normal en horas de mano de obra al mes.',
        pasos: [
            'Edita cada centro y ajusta "Operadores" a tu plantilla real de esa etapa.',
            'Pulsa "Usar sugerido" para copiar el cálculo al campo que se usa.',
            'Deja el método en "Real (a fin de mes)".',
        ],
        cuando: 'Una vez al inicio; la capacidad se revisa 1–2 veces al año.',
        errores: ['Dejar la capacidad en 0 (aviso ⚠).', 'Borrar un centro que ya tiene órdenes o gastos.'],
    },
    'areas-prorrateo': {
        titulo: 'Áreas y bases de prorrateo',
        paraQue: 'Declarar los m², la carga eléctrica (kW) y las personas de cada área. De aquí salen los % con que se reparten renta, energía y servicios — no se teclean.',
        pasos: [
            'Da de alta cada área con su rol (producción → su centro / no producción → oficina).',
            'Captura m² y número de personas.',
            'En "Cargas eléctricas" agrega los equipos de cada área con su kW y su factor de uso.',
            'Revisa el tablero de bases: los % se calculan solos.',
        ],
        cuando: 'Una vez al inicio; se actualiza cuando cambia la planta.',
        errores: [
            'Olvidar el área de Oficina: sin ella el Nivel 1 sale 100% producción.',
            'Dejar m² en 0.',
        ],
    },
    'reparto-plantillas': {
        titulo: 'Reparto de gastos compartidos',
        paraQue: 'Definir, una vez por cuenta o por proveedor, cómo se parte un gasto compartido: qué base usar (m² / kW / personas) y a qué cuenta de oficina (601.xx) va la parte de no producción.',
        pasos: [
            'Elige la cuenta de gasto (o déjala genérica).',
            'Elige la base de reparto.',
            'Elige la cuenta de la parte de oficina.',
            'Mira la vista previa: cómo quedaría repartido un gasto de $10,000.',
        ],
        cuando: 'Una vez al configurar; se ajusta si cambian las áreas.',
        errores: [
            'Usar base m²/kW/personas sin haber capturado esos datos en Áreas.',
            'No asignar la cuenta de oficina cuando la base sí genera parte de no producción.',
        ],
    },
    'tareas': {
        titulo: 'Tareas',
        paraQue: 'Avisos y pendientes que el sistema genera solo: inventario bajo mínimo, lotes por caducar, nómina por generar.',
        pasos: [
            'Revisa las tarjetas.',
            'Marca cada una como atendida, o descártala si no aplica.',
            'En el historial ves quién resolvió cada tarea y cuándo.',
        ],
        cuando: 'A diario, o cada vez que entras al ERP.',
        errores: ['Descartar una tarea sin resolver el problema de fondo.'],
    },
};

export function montarGuia(cont, clave) {
    if (!cont) return;
    const cfg = GUIAS[clave];
    if (!cfg) return;
    if (cont.querySelector(':scope > .asist-panel')) return;

    const { wrap, body } = crearPanelAsistente({ clave, titulo: cfg.titulo, subtitulo: 'cómo usar esta pantalla' });
    body.innerHTML = `
      ${cfg.paraQue ? `<p><span class="text-slate-100 font-semibold">Para qué sirve. </span>${esc(cfg.paraQue)}</p>` : ''}
      ${cfg.pasos && cfg.pasos.length ? `<div><p class="text-slate-100 font-semibold mb-1">Pasos</p><ol class="list-decimal ml-4 space-y-1">${cfg.pasos.map((p) => `<li>${esc(p)}</li>`).join('')}</ol></div>` : ''}
      ${cfg.cuando ? `<p><span class="text-slate-100 font-semibold">Cuándo usarla. </span>${esc(cfg.cuando)}</p>` : ''}
      ${cfg.errores && cfg.errores.length ? `<div><p class="text-amber-400 font-semibold mb-1">Errores comunes</p><ul class="list-disc ml-4 space-y-1">${cfg.errores.map((p) => `<li>${esc(p)}</li>`).join('')}</ul></div>` : ''}`;
    cont.prepend(wrap);
}
