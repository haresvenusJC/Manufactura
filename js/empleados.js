import { supabaseClient } from './supabase.js';
import { avisarRegistroGuardado } from './vinculos.js';
import { comprimirFoto, subirFotoEmpleado, borrarFoto, urlsFotos, avatarHtml } from './fotos-personal.js';

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const DEPARTAMENTOS_ANTERIORES = ['Producción', 'Administración', 'Ventas', 'Almacén'];

// ---- Horario laboral (días de la semana, entrada, salida y receso; hora en formato 24 h) ----
const DIAS_SEMANA = [
    { n: 1, t: 'Lunes', a: 'Lun' }, { n: 2, t: 'Martes', a: 'Mar' }, { n: 3, t: 'Miércoles', a: 'Mié' },
    { n: 4, t: 'Jueves', a: 'Jue' }, { n: 5, t: 'Viernes', a: 'Vie' }, { n: 6, t: 'Sábado', a: 'Sáb' }, { n: 7, t: 'Domingo', a: 'Dom' },
];
const HORAS_24 = Array.from({ length: 96 }, (_, i) => `${String(Math.floor(i / 4)).padStart(2, '0')}:${String((i % 4) * 15).padStart(2, '0')}`);
const RECESOS_MIN = [0, 15, 30, 45, 60, 90, 120];
const aMin = (hhmm) => { const [h, m] = String(hhmm || '00:00').split(':').map(Number); return (h || 0) * 60 + (m || 0); };
// Minutos trabajados del turno; si la salida es menor que la entrada el turno cruza la medianoche.
const minutosTurno = (h) => {
    const e = aMin(h.entrada), s = aMin(h.salida);
    const dur = s > e ? s - e : s + 1440 - e;
    return Math.max(0, dur - (Number(h.receso_min) || 0));
};
const textoReceso = (m) => (m === 0 ? 'No aplica' : m < 60 ? `${m} min` : `${Math.floor(m / 60)} h${m % 60 ? ' ' + (m % 60) + ' min' : ''}`);
function resumenHorario(lista) {
    const h = [...(lista || [])].sort((a, b) => a.dia - b.dia);
    if (!h.length) return '';
    const dias = h.map((x) => DIAS_SEMANA.find((d) => d.n === x.dia)?.a || x.dia).join(' ');
    const igual = h.every((x) => x.entrada === h[0].entrada && x.salida === h[0].salida);
    return `${dias}${igual ? ' ' + h[0].entrada + '–' + h[0].salida : ' (horarios distintos)'}`;
}

// Homologa el Gerente de todos con la jerarquía de departamentos (colaborador → responsable de su departamento;
// responsable → responsable del departamento superior más cercano que tenga uno). Devuelve cuántos cambió.
export async function homologarGerentes() {
    const [rd, re] = await Promise.all([
        supabaseClient.from('departamentos').select('id, departamento_padre_id').eq('activo', true),
        supabaseClient.from('empleados').select('id, activo, departamento_id, rol_departamento, gerente_id'),
    ]);
    if (rd.error || re.error) return 0;
    const deps = rd.data || [];
    const emps = re.data || [];
    const respDe = (depId, excluirId) => emps.find((x) => x.activo && x.id !== excluirId && x.departamento_id === depId && x.rol_departamento === 'responsable') || null;
    let cambios = 0;
    for (const e of emps) {
        if (!e.activo || !e.departamento_id) continue;
        let g = null;
        if (e.rol_departamento === 'responsable') {
            let d = deps.find((x) => x.id === e.departamento_id);
            let p = d && d.departamento_padre_id ? deps.find((x) => x.id === d.departamento_padre_id) : null;
            for (let n = 0; p && !g && n < 20; n++) {
                g = respDe(p.id, e.id);
                p = p.departamento_padre_id ? deps.find((x) => x.id === p.departamento_padre_id) : null;
            }
        } else {
            g = respDe(e.departamento_id, e.id);
        }
        if (g && g.id !== e.gerente_id) {
            const { error } = await supabaseClient.from('empleados').update({ gerente_id: g.id }).eq('id', e.id);
            if (!error) cambios++;
        }
    }
    return cambios;
}

// «Dirección › Finanzas › Cuentas por pagar»: así el empleado elige su departamento sin confundir subdepartamentos.
function rutaDepartamentoDe(d, lista) {
    const partes = [d.nombre];
    let p = d.departamento_padre_id ? lista.find((x) => x.id === d.departamento_padre_id) : null;
    for (let n = 0; p && n < 20; n++) { partes.unshift(p.nombre); p = p.departamento_padre_id ? lista.find((x) => x.id === p.departamento_padre_id) : null; }
    return partes.join(' › ');
}

export async function cargarModuloEmpleados() {
    const contenedor = document.getElementById('view-empleados');
    if (!contenedor) return;

    // Departamentos desde su tabla. Si la migración no se ha corrido, la pantalla funciona como antes
    // (selector fijo, sin Gerente ni foto) y avisa qué falta.
    const resDeps = await supabaseClient.from('departamentos').select('*').eq('activo', true).order('nombre');
    const hayEstructura = !resDeps.error;
    // Rol en el departamento (Responsable / Colaborador): requiere sql/2026-10-30_departamento_superior_rol.sql.
    const [sondeoRol, sondeoHorario] = await Promise.all([
        hayEstructura ? supabaseClient.from('empleados').select('rol_departamento').limit(1) : Promise.resolve({ error: true }),
        supabaseClient.from('empleados').select('horario_laboral').limit(1),   // requiere sql/2026-10-30c_empleados_horario.sql
    ]);
    const hayRol = hayEstructura && !sondeoRol.error;
    const hayHorario = !sondeoHorario.error;
    const ROL_LABEL = { responsable: 'Responsable de Departamento', colaborador: 'Colaborador de Departamento' };
    const departamentos = hayEstructura ? (resDeps.data || []) : [];
    let empleadosCache = [];

    const opcionesDepartamento = hayEstructura
        ? departamentos.map((d) => `<option value="${d.id}">${esc(rutaDepartamentoDe(d, departamentos))}</option>`).join('')
        : DEPARTAMENTOS_ANTERIORES.map((n) => `<option value="${esc(n)}">${esc(n)}</option>`).join('');

    contenedor.innerHTML = `
        <div class="space-y-6 max-w-3xl mx-auto">
            <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <div class="flex items-center justify-between gap-2 flex-wrap mb-1">
                    <h2 class="text-xl font-bold text-slate-100">👷 Catálogo de Empleados</h2>
                    <button type="button" onclick="window.abrirManual('#m-empleados', 'Empleados')" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2.5 py-1 rounded-lg whitespace-nowrap cursor-pointer">📖 Cómo llenar esta pantalla</button>
                </div>
                <p class="text-xs text-slate-400 mb-4">Captura el sueldo semanal y las horas semanales de cada empleado; el costo por hora se calcula automáticamente para usarse en los cronómetros de producción.</p>
                ${hayEstructura ? '' : `<p class="text-[11px] text-amber-300 bg-amber-950/40 border border-amber-900/60 rounded-lg px-3 py-2 mb-4">Falta correr <span class="font-mono">sql/2026-10-28_departamentos_gerente_foto.sql</span> en Supabase para usar Departamentos, Gerente y foto. Mientras tanto la pantalla funciona como antes.</p>`}

                <form id="formEmpleado" class="space-y-5">
                    <input type="hidden" id="empIdEditando" value="">

                    <!-- ===== INFORMACIÓN PERSONAL: lo que individualiza a la persona ===== -->
                    <div class="bg-slate-950/60 border border-slate-800 rounded-xl p-4 space-y-4">
                        <h3 class="text-sm font-bold text-sky-300">👤 Información personal</h3>
                        ${hayEstructura ? `
                        <div class="flex items-center gap-4">
                            <div id="empFotoPreview" class="shrink-0"></div>
                            <div class="min-w-0">
                                <label class="block text-xs font-medium text-slate-400 mb-1">FOTO (opcional)</label>
                                <input type="file" id="empFoto" accept="image/*" class="text-xs text-slate-300 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border file:border-slate-700 file:bg-slate-800 file:text-slate-200">
                                <button type="button" id="empFotoQuitar" class="hidden text-[11px] text-rose-400 hover:text-rose-300 mt-1">Quitar foto</button>
                            </div>
                        </div>` : ''}
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE</label>
                            <input type="text" id="empNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                        </div>
                        <div class="grid grid-cols-3 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">RFC (opcional)</label>
                                <input type="text" id="empRfc" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase">
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">CURP (opcional)</label>
                                <input type="text" id="empCurp" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono uppercase">
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">NSS (opcional)</label>
                                <input type="text" id="empNss" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono">
                            </div>
                        </div>
                    </div>

                    <!-- ===== INFORMACIÓN LABORAL: lo que lo liga a la empresa ===== -->
                    <div class="bg-slate-950/60 border border-slate-800 rounded-xl p-4 space-y-4">
                        <h3 class="text-sm font-bold text-emerald-300">🏢 Información laboral</h3>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">PUESTO DE TRABAJO (opcional)</label>
                                <input type="text" id="empPuesto" placeholder="p. ej. Jefe de contabilidad" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">FECHA DE INGRESO (opcional)</label>
                                <input type="date" id="empFechaIngreso" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">DEPARTAMENTO (opcional)</label>
                                <select id="empDepartamento" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                    <option value="">(sin asignar)</option>
                                    ${opcionesDepartamento}
                                </select>
                                ${hayEstructura ? `<button type="button" onclick="window.loadView('departamentos')" class="text-[11px] text-sky-400 hover:text-sky-300 mt-1">Administrar departamentos</button>` : ''}
                            </div>
                            ${hayEstructura ? `
                            <div>
                                ${hayRol ? `
                                <label class="block text-xs font-medium text-slate-400 mb-1">CARGO QUE OCUPA EN EL DEPARTAMENTO</label>
                                <select id="empRol" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                    <option value="">(sin departamento)</option>
                                    <option value="colaborador">${ROL_LABEL.colaborador}</option>
                                    <option value="responsable">${ROL_LABEL.responsable}</option>
                                </select>` : `
                                <p class="text-[11px] text-amber-300">Falta correr <span class="font-mono">sql/2026-10-30_departamento_superior_rol.sql</span> para elegir el cargo en el departamento.</p>`}
                                <select id="empGerente" class="hidden" data-sin-buscador></select>
                                <p id="empGerenteHint" class="hidden"></p>
                            </div>` : '<div></div>'}
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">SUELDO SEMANAL ($)</label>
                                <input type="number" id="empSueldo" min="0" step="0.01" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                            <div>
                                <label class="block text-xs font-medium text-slate-400 mb-1">HORAS SEMANALES</label>
                                <input type="number" id="empHoras" min="0" step="0.01" value="48" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                            </div>
                        </div>
                        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3">
                            <div class="flex items-center justify-between gap-2 flex-wrap mb-2">
                                <span class="text-xs font-medium text-slate-400">HORARIO LABORAL (días que trabaja, horario en formato 24 h y receso)</span>
                                <button type="button" id="empHorarioPreset" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded-lg">Lun–Vie 08:00–17:00</button>
                            </div>
                            ${hayHorario ? '' : `<p class="text-[11px] text-amber-300 mb-2">Falta correr <span class="font-mono">sql/2026-10-30c_empleados_horario.sql</span> en Supabase para guardar el horario; mientras tanto solo calcula las horas semanales.</p>`}
                            <table class="w-full text-xs">
                                <thead>
                                    <tr class="text-slate-500 text-left">
                                        <th class="py-1 pr-2 font-medium">Día</th><th class="py-1 pr-2 font-medium">Jornada</th>
                                        <th class="py-1 pr-2 font-medium">Entrada</th><th class="py-1 pr-2 font-medium">Salida</th>
                                        <th class="py-1 pr-2 font-medium">Receso</th><th class="py-1 pr-2 font-medium text-right">Horas netas</th>
                                    </tr>
                                </thead>
                                <tbody id="empHorarioBody"></tbody>
                            </table>
                            <datalist id="empHoras24">${HORAS_24.map((h) => `<option value="${h}"></option>`).join('')}</datalist>
                            <p class="text-[11px] text-slate-500 mt-2">Los días en «Descanso» no cuentan. Si la salida es menor que la entrada, el turno cruza la medianoche. <span id="empHorarioTotal" class="text-slate-300 font-semibold"></span></p>
                        </div>
                        <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 flex justify-between items-center">
                            <span class="text-xs text-slate-400">Costo por hora calculado</span>
                            <span id="empCostoHoraPreview" class="font-mono text-lg font-bold text-emerald-400">$0.00</span>
                        </div>
                        <div class="sm:w-1/2">
                            <label class="block text-xs font-medium text-slate-400 mb-1">PIN MÓVIL (4 dígitos)</label>
                            <input type="text" id="empPin" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" placeholder="Dejar vacío para no cambiar"
                                   class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono tracking-widest">
                        </div>
                    </div>

                    <div class="flex items-center gap-3 pt-1">
                        <button type="submit" id="btnGuardarEmpleado" class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2 px-4 rounded-lg text-sm shadow-lg">
                            💾 Guardar Empleado
                        </button>
                        <button type="button" id="btnCancelarEdicionEmp" class="bg-slate-800 hover:bg-slate-700 text-slate-200 py-2 px-4 rounded-lg text-sm border border-slate-700 hidden">
                            Cancelar edición
                        </button>
                    </div>
                </form>
            </div>

            <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <h3 class="text-sm font-bold text-slate-200 mb-3">Empleados registrados</h3>
                <div id="listaEmpleados" class="space-y-2">
                    <p class="text-slate-500 text-xs italic">Cargando...</p>
                </div>
            </div>
        </div>
    `;

    // Estado de la foto del formulario
    let fotoNueva = null;       // Blob ya comprimido, pendiente de subir al guardar
    let fotoQuitar = false;     // el usuario pidió quitar la foto actual
    let fotoRutaActual = null;  // ruta guardada del empleado en edición
    let fotoUrlActual = null;   // URL firmada de esa ruta (solo para mostrar)

    function pintarVistaFoto(nombre) {
        const cont = document.getElementById('empFotoPreview');
        if (!cont) return;
        const url = fotoNueva ? URL.createObjectURL(fotoNueva) : (fotoQuitar ? null : fotoUrlActual);
        cont.innerHTML = avatarHtml(nombre || document.getElementById('empNombre').value, url, 72);
        const btnQuitar = document.getElementById('empFotoQuitar');
        if (btnQuitar) btnQuitar.classList.toggle('hidden', !(fotoNueva || (fotoRutaActual && !fotoQuitar)));
    }

    if (hayEstructura) {
        document.getElementById('empFoto').onchange = async (ev) => {
            const archivo = ev.target.files && ev.target.files[0];
            if (!archivo) return;
            try {
                fotoNueva = await comprimirFoto(archivo);
                fotoQuitar = false;
                pintarVistaFoto();
            } catch (e) {
                alert('❌ No se pudo leer la imagen: ' + (e.message || e));
                ev.target.value = '';
            }
        };
        document.getElementById('empFotoQuitar').onclick = () => {
            fotoNueva = null;
            fotoQuitar = !!fotoRutaActual;
            document.getElementById('empFoto').value = '';
            pintarVistaFoto();
        };
        document.getElementById('empNombre').addEventListener('input', () => { if (!fotoNueva && !fotoUrlActual) pintarVistaFoto(); });
    }

    // Gerente: cualquier empleado activo menos el que se está editando (la base también impide los círculos).
    function pintarOpcionesGerente(excluirId, seleccionado) {
        const sel = document.getElementById('empGerente');
        if (!sel) return;
        const opciones = empleadosCache
            .filter((e) => e.activo && e.id !== excluirId)
            .map((e) => `<option value="${e.id}">${esc(e.nombre)}${e.puesto ? ' — ' + esc(e.puesto) : ''}</option>`)
            .join('');
        sel.innerHTML = `<option value="">(ninguno: cabeza de la organización)</option>${opciones}`;
        sel.value = seleccionado ? String(seleccionado) : '';
        sel.dataset.auto = '';
    }

    // Homologación con Departamentos: el Gerente esperado sale de la jerarquía de departamentos.
    //  · Colaborador → el responsable de su departamento.
    //  · Responsable → el responsable del departamento superior más cercano que tenga uno.
    function gerenteEsperado(depId, rol, idEditando) {
        const dep = departamentos.find((d) => d.id === depId);
        if (!dep) return null;
        if (!hayRol) return dep.responsable_id && dep.responsable_id !== idEditando ? { id: dep.responsable_id, nombre: 'el responsable del departamento' } : null;
        const respDe = (id) => empleadosCache.find((e) => e.activo && e.id !== idEditando && e.departamento_id === id && e.rol_departamento === 'responsable') || null;
        if (rol !== 'responsable') return respDe(dep.id);
        let p = dep.departamento_padre_id ? departamentos.find((d) => d.id === dep.departamento_padre_id) : null;
        for (let n = 0; p && n < 20; n++) {
            const r = respDe(p.id);
            if (r) return r;
            p = p.departamento_padre_id ? departamentos.find((d) => d.id === p.departamento_padre_id) : null;
        }
        return null;
    }
    // Sugerencia automática: se rellena si el Gerente está vacío o si lo puso esta misma sugerencia (nunca pisa una elección manual).
    function sugerirGerenteDelDepartamento() {
        const selDep = document.getElementById('empDepartamento');
        const selGer = document.getElementById('empGerente');
        const hint = document.getElementById('empGerenteHint');
        if (!selGer || !hayEstructura) return;
        const idEditando = Number(document.getElementById('empIdEditando').value) || null;
        const rol = document.getElementById('empRol')?.value || 'colaborador';
        const esperado = selDep.value ? gerenteEsperado(Number(selDep.value) || selDep.value, rol, idEditando) : null;
        if (esperado && (!selGer.value || selGer.dataset.auto === '1')) {
            selGer.value = String(esperado.id);
            selGer.dataset.auto = '1';
            if (hint) hint.textContent = rol === 'responsable'
                ? 'Sugerido: el responsable del departamento superior. Puedes cambiarlo.'
                : 'Sugerido: el responsable de su departamento. Puedes cambiarlo.';
        } else if (!esperado && selGer.dataset.auto === '1') {
            selGer.value = ''; selGer.dataset.auto = '';
            if (hint) hint.textContent = 'Su jefe directo. Vacío = cabeza de la organización.';
        } else if (hint && !selGer.dataset.auto) {
            hint.textContent = 'Su jefe directo. Vacío = cabeza de la organización.';
        }
    }
    // Rol: al elegir departamento queda «Colaborador» si estaba vacío; sin departamento no hay rol.
    // Avisa quién es hoy el responsable del departamento elegido.
    function actualizarRol() {
        const selRol = document.getElementById('empRol');
        if (!selRol) return;
        const depId = Number(document.getElementById('empDepartamento').value) || null;
        const hint = document.getElementById('empRolHint');
        if (!depId) { selRol.value = ''; selRol.disabled = true; return; }
        selRol.disabled = false;
        if (!selRol.value) selRol.value = 'colaborador';
        const idEditando = Number(document.getElementById('empIdEditando').value) || null;
        const actual = empleadosCache.find((e) => e.activo && e.id !== idEditando && e.departamento_id === depId && e.rol_departamento === 'responsable');
        if (hint) hint.textContent = actual
            ? `Hoy el responsable de este departamento es ${actual.nombre}. Si marcas «Responsable» aquí, ${actual.nombre} pasará a Colaborador.`
            : 'Este departamento aún no tiene responsable. El puesto es texto libre y solo describe, p. ej. «Jefe de Contabilidad».';
    }
    if (hayEstructura) {
        document.getElementById('empDepartamento').onchange = () => { actualizarRol(); sugerirGerenteDelDepartamento(); };
        const selRolEl = document.getElementById('empRol');
        if (selRolEl) selRolEl.onchange = sugerirGerenteDelDepartamento;
        // Si la persona elige el Gerente a mano, la sugerencia automática ya no lo toca.
        document.getElementById('empGerente').addEventListener('change', (ev) => { if (ev.isTrusted) ev.target.dataset.auto = ''; });
    }

    function actualizarPreviewCostoHora() {
        const sueldo = parseFloat(document.getElementById('empSueldo').value) || 0;
        const horas = parseFloat(document.getElementById('empHoras').value) || 0;
        const costoHora = horas > 0 ? sueldo / horas : 0;
        document.getElementById('empCostoHoraPreview').textContent = `$${costoHora.toFixed(2)}`;
    }
    document.getElementById('empSueldo').oninput = actualizarPreviewCostoHora;
    document.getElementById('empHoras').oninput = actualizarPreviewCostoHora;

    // ---- Tabla de horario laboral: siempre los 7 días; cada uno «Labora» o «Descanso» ----
    // Las celdas se actualizan EN SITIO (nunca se reconstruye la tabla mientras se navega): reconstruirla al cambiar un
    // valor destruía el campo enfocado y el Tab volvía a la primera celda. Entrada/Salida son campos con sugerencias:
    // al teclear «9» o «930» ofrecen las horas cercanas y al salir se normalizan a HH:MM.
    let horario = [];   // solo los días que se laboran: [{ dia, entrada, salida, receso_min }]
    const CLS_CAMPO = 'w-full bg-slate-900 border border-slate-700 rounded-md px-1.5 py-1 text-xs text-slate-100 disabled:opacity-50';
    const horarioPorDefecto = () => {
        const ref = horario[horario.length - 1];
        return { entrada: ref ? ref.entrada : '08:00', salida: ref ? ref.salida : '17:00', receso_min: ref ? ref.receso_min : 60 };
    };
    // «9» → 09:00 · «930» → 09:30 · «9:5» no vale · «1730» → 17:30; null si no es una hora válida
    function normalizarHora(v) {
        const t = String(v || '').trim();
        let h, m;
        let r;
        if ((r = t.match(/^(\d{1,2}):(\d{2})$/))) { h = Number(r[1]); m = Number(r[2]); }
        else if ((r = t.match(/^(\d{1,2})$/))) { h = Number(r[1]); m = 0; }
        else if ((r = t.match(/^(\d{1,2})(\d{2})$/))) { h = Number(r[1]); m = Number(r[2]); }
        else return null;
        if (h > 23 || m > 59) return null;
        return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
    }
    function opcionesReceso(valor) {
        const lista = RECESOS_MIN.includes(valor) ? RECESOS_MIN : [...RECESOS_MIN, valor].sort((a, b) => a - b);
        return lista.map((m) => `<option value="${m}">${textoReceso(m)}</option>`).join('');
    }
    function pintarFila(tr) {
        const dia = Number(tr.dataset.dia);
        const h = horario.find((x) => x.dia === dia);
        const labora = !!h;
        const q = (c) => tr.querySelector(`[data-c="${c}"]`);
        q('estado').value = labora ? 'labora' : 'descanso';
        const ent = q('entrada'), sal = q('salida'), rec = q('receso_min');
        ent.disabled = sal.disabled = rec.disabled = !labora;
        if (document.activeElement !== ent) ent.value = labora ? h.entrada : '';
        if (document.activeElement !== sal) sal.value = labora ? h.salida : '';
        if (labora && ![...rec.options].some((o) => Number(o.value) === Number(h.receso_min))) rec.insertAdjacentHTML('beforeend', `<option value="${Number(h.receso_min)}">${textoReceso(Number(h.receso_min))}</option>`);
        rec.value = labora ? String(Number(h.receso_min)) : '0';
        tr.classList.toggle('text-slate-500', !labora);
        const net = tr.querySelector('[data-c="neto"]');
        net.textContent = labora ? (minutosTurno(h) / 60).toFixed(2) + ' h' : '—';
        net.classList.toggle('text-rose-400', labora && h.entrada === h.salida);
    }
    function actualizarTotalHorario() {
        const total = horario.reduce((a, h) => a + minutosTurno(h), 0) / 60;
        const totEl = document.getElementById('empHorarioTotal');
        if (totEl) totEl.textContent = horario.length ? `Total semanal: ${total.toFixed(2)} h en ${horario.length} día(s) — se usa como «Horas semanales».` : 'Sin días laborados capturados.';
        if (horario.length) { document.getElementById('empHoras').value = total.toFixed(2); actualizarPreviewCostoHora(); }
    }
    // Reconstrucción completa: SOLO al cargar, editar, limpiar o usar el atajo (nunca durante la captura).
    function renderHorario() {
        const body = document.getElementById('empHorarioBody');
        if (!body) return;
        body.innerHTML = DIAS_SEMANA.map((d) => `<tr data-dia="${d.n}" class="border-t border-slate-800">
            <td class="py-1 pr-2 font-medium text-slate-200">${d.t}</td>
            <td class="py-1 pr-2"><select data-c="estado" data-sin-buscador class="${CLS_CAMPO}"><option value="labora">Labora</option><option value="descanso">Descanso</option></select></td>
            <td class="py-1 pr-2"><input type="text" data-c="entrada" list="empHoras24" maxlength="5" autocomplete="off" placeholder="—" class="${CLS_CAMPO} font-mono"></td>
            <td class="py-1 pr-2"><input type="text" data-c="salida" list="empHoras24" maxlength="5" autocomplete="off" placeholder="—" class="${CLS_CAMPO} font-mono"></td>
            <td class="py-1 pr-2"><select data-c="receso_min" data-sin-buscador class="${CLS_CAMPO}">${opcionesReceso(0)}</select></td>
            <td data-c="neto" class="py-1 pr-2 text-right font-mono text-slate-300">—</td>
        </tr>`).join('');
        body.querySelectorAll('tr[data-dia]').forEach(pintarFila);
        actualizarTotalHorario();
    }
    document.getElementById('empHorarioBody').addEventListener('change', (ev) => {
        const tr = ev.target.closest('tr[data-dia]');
        const c = ev.target.dataset.c;
        if (!tr || !c) return;
        const dia = Number(tr.dataset.dia);
        if (c === 'estado') {
            if (ev.target.value === 'labora') { if (!horario.some((x) => x.dia === dia)) horario.push({ dia, ...horarioPorDefecto() }); }
            else horario = horario.filter((x) => x.dia !== dia);
            horario.sort((x, y) => x.dia - y.dia);
        } else {
            const h = horario.find((x) => x.dia === dia);
            if (!h) return;
            if (c === 'receso_min') h.receso_min = Number(ev.target.value);
            else {
                const hora = normalizarHora(ev.target.value);
                if (hora) h[c] = hora;           // si lo tecleado no es una hora válida se regresa a la anterior
                ev.target.value = h[c];
            }
        }
        pintarFila(tr);
        actualizarTotalHorario();
    });
    // Enter en una hora la confirma (sin enviar el formulario completo)
    document.getElementById('empHorarioBody').addEventListener('keydown', (ev) => {
        if (ev.key === 'Enter' && ev.target.matches('input[data-c]')) {
            ev.preventDefault();
            ev.target.dispatchEvent(new Event('change', { bubbles: true }));
        }
    });
    document.getElementById('empHorarioPreset').onclick = () => {
        horario = [1, 2, 3, 4, 5].map((n) => ({ dia: n, entrada: '08:00', salida: '17:00', receso_min: 60 }));
        renderHorario();
    };
    renderHorario();

    async function cargarLista() {
        const cont = document.getElementById('listaEmpleados');
        const { data, error } = await supabaseClient
            .from('empleados')
            .select('*')
            .order('nombre', { ascending: true });

        if (error) {
            cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar: ${esc(error.message)}</p>`;
            return;
        }
        if (!data || !data.length) {
            cont.innerHTML = `<p class="text-slate-500 text-xs italic">Todavía no hay empleados registrados.</p>`;
            return;
        }
        empleadosCache = data;
        pintarOpcionesGerente(Number(document.getElementById('empIdEditando').value) || null, document.getElementById('empGerente')?.value);
        const urls = hayEstructura ? await urlsFotos(data.map((e) => e.foto_path)) : new Map();
        const nombreDe = (id) => data.find((e) => e.id === id)?.nombre || null;

        cont.innerHTML = data.map(emp => `
            <div class="flex items-center justify-between gap-3 bg-slate-950 border border-slate-800 rounded-lg p-3 ${!emp.activo ? 'opacity-50' : ''}">
                <div class="flex items-center gap-3 min-w-0">
                    ${hayEstructura ? avatarHtml(emp.nombre, urls.get(emp.foto_path), 40) : ''}
                    <div class="min-w-0">
                        <p class="text-sm font-semibold text-slate-200">${esc(emp.nombre)} ${!emp.activo ? '<span class="text-[10px] text-rose-400">(inactivo)</span>' : ''}</p>
                        <p class="text-[11px] text-slate-500">${esc(emp.puesto || 'Sin puesto')}${emp.departamento ? ' · ' + esc(emp.departamento) : ''}${hayRol && emp.departamento_id && emp.rol_departamento ? ' · <span class="' + (emp.rol_departamento === 'responsable' ? 'text-emerald-400' : 'text-slate-400') + '">' + ROL_LABEL[emp.rol_departamento] + '</span>' : ''} · $${Number(emp.sueldo_semanal).toFixed(2)}/sem · ${Number(emp.horas_semanales)} hrs/sem${hayHorario && Array.isArray(emp.horario_laboral) && emp.horario_laboral.length ? ' · ' + esc(resumenHorario(emp.horario_laboral)) : ''}</p>
                        ${hayEstructura ? `<p class="text-[11px] text-slate-500">${emp.gerente_id && nombreDe(emp.gerente_id) ? 'Gerente: ' + esc(nombreDe(emp.gerente_id)) : 'Sin gerente (cabeza de la organización)'}</p>` : ''}
                        <p class="text-[11px] mt-0.5 ${emp.pin_hash ? 'text-emerald-500' : 'text-amber-500'}">${emp.pin_hash ? 'PIN móvil ✓' : 'Sin PIN móvil'}${emp.patron_hash ? ' · Patrón ✓' : ''}</p>
                    </div>
                </div>
                <div class="flex items-center gap-3 shrink-0">
                    <span class="font-mono text-emerald-400 font-bold text-sm">$${Number(emp.costo_hora).toFixed(2)}/hr</span>
                    <button type="button" class="btn-pin-emp text-slate-400 hover:text-emerald-400 text-xs" data-id="${emp.id}" title="Restablecer PIN móvil">🔑</button>
                    <button type="button" class="btn-editar-emp text-slate-400 hover:text-sky-400 text-xs" data-id="${emp.id}">✏️</button>
                    <button type="button" class="btn-toggle-emp text-slate-400 hover:text-amber-400 text-xs" data-id="${emp.id}" data-activo="${emp.activo}">${emp.activo ? '🚫' : '✅'}</button>
                </div>
            </div>
        `).join('');

        cont.querySelectorAll('.btn-pin-emp').forEach(btn => {
            btn.onclick = async () => {
                const nuevoPin = (prompt('Nuevo PIN de 4 dígitos para la Orden de Trabajo móvil:') || '').trim();
                if (!nuevoPin) return;
                if (!/^\d{4}$/.test(nuevoPin)) { alert('El PIN debe tener exactamente 4 dígitos.'); return; }
                const { error: errPin } = await supabaseClient.rpc('set_pin_empleado', {
                    p_empleado_id: Number(btn.dataset.id),
                    p_pin: nuevoPin
                });
                if (errPin) { alert('No se pudo guardar el PIN: ' + errPin.message); return; }
                cargarLista();
            };
        });

        cont.querySelectorAll('.btn-editar-emp').forEach(btn => {
            btn.onclick = () => {
                const emp = data.find(e => e.id === Number(btn.dataset.id));
                if (!emp) return;
                document.getElementById('empIdEditando').value = emp.id;
                document.getElementById('empNombre').value = emp.nombre;
                document.getElementById('empPuesto').value = emp.puesto || '';
                document.getElementById('empFechaIngreso').value = emp.fecha_ingreso || '';
                document.getElementById('empDepartamento').value = hayEstructura ? (emp.departamento_id ? String(emp.departamento_id) : '') : (emp.departamento || '');
                document.getElementById('empRfc').value = emp.rfc || '';
                document.getElementById('empCurp').value = emp.curp || '';
                document.getElementById('empNss').value = emp.nss || '';
                document.getElementById('empSueldo').value = emp.sueldo_semanal;
                document.getElementById('empHoras').value = emp.horas_semanales;
                {
                    horario = (Array.isArray(emp.horario_laboral) ? emp.horario_laboral : [])
                        .map((h) => ({ dia: Number(h.dia), entrada: h.entrada, salida: h.salida, receso_min: Number(h.receso_min) || 0 }));
                    renderHorario();
                }
                if (hayEstructura) {
                    pintarOpcionesGerente(emp.id, emp.gerente_id);
                    if (hayRol) { document.getElementById('empRol').value = emp.rol_departamento || ''; actualizarRol(); }
                    const hint = document.getElementById('empGerenteHint');
                    if (hint) hint.textContent = 'Su jefe directo. Vacío = cabeza de la organización.';
                    fotoNueva = null; fotoQuitar = false;
                    fotoRutaActual = emp.foto_path || null;
                    fotoUrlActual = urls.get(emp.foto_path) || null;
                    document.getElementById('empFoto').value = '';
                    pintarVistaFoto(emp.nombre);
                }
                actualizarPreviewCostoHora();
                document.getElementById('btnCancelarEdicionEmp').classList.remove('hidden');
                document.getElementById('btnGuardarEmpleado').textContent = '💾 Actualizar Empleado';
                window.scrollTo({ top: 0, behavior: 'smooth' });
            };
        });

        cont.querySelectorAll('.btn-toggle-emp').forEach(btn => {
            btn.onclick = async () => {
                const nuevoEstado = btn.dataset.activo !== 'true';
                await supabaseClient.from('empleados').update({ activo: nuevoEstado }).eq('id', Number(btn.dataset.id));
                cargarLista();
            };
        });
    }

    function resetFormulario() {
        document.getElementById('formEmpleado').reset();
        document.getElementById('empIdEditando').value = '';
        document.getElementById('empHoras').value = 48;
        horario = []; renderHorario();
        document.getElementById('btnCancelarEdicionEmp').classList.add('hidden');
        document.getElementById('btnGuardarEmpleado').textContent = '💾 Guardar Empleado';
        if (hayEstructura) {
            fotoNueva = null; fotoQuitar = false; fotoRutaActual = null; fotoUrlActual = null;
            pintarOpcionesGerente(null, null);
            pintarVistaFoto('');
            actualizarRol();
        }
        actualizarPreviewCostoHora();
    }

    document.getElementById('btnCancelarEdicionEmp').onclick = resetFormulario;

    document.getElementById('formEmpleado').onsubmit = async (e) => {
        e.preventDefault();
        const idEditando = document.getElementById('empIdEditando').value;
        const selDep = document.getElementById('empDepartamento');
        const registro = {
            nombre: document.getElementById('empNombre').value.trim(),
            puesto: document.getElementById('empPuesto').value.trim() || null,
            fecha_ingreso: document.getElementById('empFechaIngreso').value || null,
            rfc: document.getElementById('empRfc').value.trim().toUpperCase() || null,
            curp: document.getElementById('empCurp').value.trim().toUpperCase() || null,
            nss: document.getElementById('empNss').value.trim() || null,
            sueldo_semanal: parseFloat(document.getElementById('empSueldo').value) || 0,
            horas_semanales: parseFloat(document.getElementById('empHoras').value) || 1
        };
        if (hayHorario) {
            if (horario.some((h) => h.entrada === h.salida)) { alert('En el horario laboral, la entrada y la salida no pueden ser la misma hora.'); return; }
            registro.horario_laboral = horario.length
                ? [...horario].sort((a, b) => a.dia - b.dia).map((h) => ({ dia: h.dia, entrada: h.entrada, salida: h.salida, receso_min: Number(h.receso_min) || 0 }))
                : null;
        }
        if (hayEstructura) {
            const dep = departamentos.find((d) => String(d.id) === selDep.value);
            registro.departamento_id = dep ? dep.id : null;
            registro.departamento = dep ? dep.nombre : null;   // el texto se conserva por compatibilidad
            // El Gerente ya no se captura: sale de la jerarquía de departamentos (si no hay a quién asignar, se conserva el actual).
            const rolParaGerente = hayRol ? (document.getElementById('empRol').value || 'colaborador') : 'colaborador';
            const esperadoG = dep ? gerenteEsperado(dep.id, rolParaGerente, Number(idEditando || 0) || null) : null;
            registro.gerente_id = esperadoG ? esperadoG.id : (Number(document.getElementById('empGerente').value) || null);
            if (hayRol) {
                const rol = dep ? (document.getElementById('empRol').value || 'colaborador') : null;
                registro.rol_departamento = rol;
                // Solo un responsable por departamento: si ya hay otro, se confirma y pasa a Colaborador.
                if (rol === 'responsable') {
                    const otro = empleadosCache.find((x) => x.activo && x.id !== Number(idEditando || 0) && x.departamento_id === dep.id && x.rol_departamento === 'responsable');
                    if (otro) {
                        if (!confirm(`${otro.nombre} es hoy el Responsable de ${dep.nombre}. ¿Cambiarlo a Colaborador y dejar a este empleado como Responsable?`)) return;
                        const { error: errOtro } = await supabaseClient.from('empleados').update({ rol_departamento: 'colaborador' }).eq('id', otro.id);
                        if (errOtro) { alert('❌ No se pudo cambiar al responsable anterior: ' + errOtro.message); return; }
                    }
                }
            }
        } else {
            registro.departamento = selDep.value || null;
        }

        let empleadoId = idEditando ? Number(idEditando) : null;
        let error;
        if (idEditando) {
            ({ error } = await supabaseClient.from('empleados').update(registro).eq('id', empleadoId));
        } else {
            const res = await supabaseClient.from('empleados').insert([registro]).select('id').single();
            error = res.error;
            empleadoId = res.data?.id ?? null;
        }

        if (error) {
            alert('❌ Error al guardar: ' + error.message);
            return;
        }

        // Foto: se sube después de guardar (necesita el id del empleado)
        if (hayEstructura && empleadoId && (fotoNueva || fotoQuitar)) {
            try {
                let nuevaRuta = null;
                if (fotoNueva) nuevaRuta = await subirFotoEmpleado(empleadoId, fotoNueva, fotoRutaActual);
                else if (fotoRutaActual) await borrarFoto(fotoRutaActual);
                const { error: errFoto } = await supabaseClient.from('empleados').update({ foto_path: nuevaRuta }).eq('id', empleadoId);
                if (errFoto) throw errFoto;
            } catch (errFoto) {
                alert('Empleado guardado, pero la foto no se pudo subir: ' + (errFoto.message || errFoto));
            }
        }

        const pin = document.getElementById('empPin').value.trim();
        if (pin && empleadoId) {
            if (!/^\d{4}$/.test(pin)) {
                alert('Empleado guardado. El PIN se ignoró: debe tener exactamente 4 dígitos.');
            } else {
                const { error: errPin } = await supabaseClient.rpc('set_pin_empleado', {
                    p_empleado_id: empleadoId,
                    p_pin: pin
                });
                if (errPin) alert('Empleado guardado, pero el PIN no se pudo actualizar: ' + errPin.message);
            }
        }

        // Si se abrió desde otra pantalla («Crear y editar…» del Responsable de un departamento), se le devuelve este empleado.
        if (hayRol) await homologarGerentes();
        if (empleadoId) avisarRegistroGuardado('empleado', empleadoId);
        resetFormulario();
        cargarLista();
    };

    actualizarPreviewCostoHora();
    if (hayEstructura) pintarVistaFoto('');
    await cargarLista();
    actualizarRol();
}
