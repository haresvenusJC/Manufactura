import { supabaseClient } from './supabase.js';
import { comprimirFoto, subirFotoEmpleado, borrarFoto, urlsFotos, avatarHtml } from './fotos-personal.js';

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const DEPARTAMENTOS_ANTERIORES = ['Producción', 'Administración', 'Ventas', 'Almacén'];

export async function cargarModuloEmpleados() {
    const contenedor = document.getElementById('view-empleados');
    if (!contenedor) return;

    // Departamentos desde su tabla. Si la migración no se ha corrido, la pantalla funciona como antes
    // (selector fijo, sin Gerente ni foto) y avisa qué falta.
    const resDeps = await supabaseClient.from('departamentos').select('*').eq('activo', true).order('nombre');
    const hayEstructura = !resDeps.error;
    // Rol en el departamento (Responsable / Colaborador): requiere sql/2026-10-30_departamento_superior_rol.sql.
    const hayRol = hayEstructura && !(await supabaseClient.from('empleados').select('rol_departamento').limit(1)).error;
    const ROL_LABEL = { responsable: 'Responsable de Departamento', colaborador: 'Colaborador de Departamento' };
    const departamentos = hayEstructura ? (resDeps.data || []) : [];
    let empleadosCache = [];

    const opcionesDepartamento = hayEstructura
        ? departamentos.map((d) => `<option value="${d.id}">${esc(d.nombre)}</option>`).join('')
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

                <form id="formEmpleado" class="space-y-4">
                    <input type="hidden" id="empIdEditando" value="">
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
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PUESTO DE TRABAJO (opcional)</label>
                            <input type="text" id="empPuesto" placeholder="p. ej. Jefe de contabilidad" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PIN MÓVIL (4 dígitos)</label>
                            <input type="text" id="empPin" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" placeholder="Dejar vacío para no cambiar"
                                   class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono tracking-widest">
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
                            <label class="block text-xs font-medium text-slate-400 mb-1">GERENTE (opcional)</label>
                            <select id="empGerente" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                            <p id="empGerenteHint" class="text-[11px] text-slate-500 mt-1">Su jefe directo. Vacío = cabeza de la organización.</p>
                        </div>` : `
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">FECHA DE INGRESO (opcional)</label>
                            <input type="date" id="empFechaIngreso" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        </div>`}
                    </div>
                    ${hayRol ? `
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">ROL EN EL DEPARTAMENTO</label>
                        <select id="empRol" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">(sin departamento)</option>
                            <option value="colaborador">${ROL_LABEL.colaborador}</option>
                            <option value="responsable">${ROL_LABEL.responsable}</option>
                        </select>
                        <p id="empRolHint" class="text-[11px] text-slate-500 mt-1">«Responsable» es quien dirige el departamento (solo uno). El puesto de arriba es texto libre y solo describe, p. ej. «Jefe de Contabilidad».</p>
                    </div>` : hayEstructura ? `<p class="text-[11px] text-amber-300">Falta correr <span class="font-mono">sql/2026-10-30_departamento_superior_rol.sql</span> para elegir si es Responsable o Colaborador del departamento.</p>` : ''}
                    ${hayEstructura ? `
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">FECHA DE INGRESO (opcional)</label>
                        <input type="date" id="empFechaIngreso" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 sm:w-1/2">
                    </div>` : ''}
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
                    <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 flex justify-between items-center">
                        <span class="text-xs text-slate-400">Costo por hora calculado</span>
                        <span id="empCostoHoraPreview" class="font-mono text-lg font-bold text-emerald-400">$0.00</span>
                    </div>
                    <div class="flex items-center gap-3 pt-2">
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
                        <p class="text-[11px] text-slate-500">${esc(emp.puesto || 'Sin puesto')}${emp.departamento ? ' · ' + esc(emp.departamento) : ''}${hayRol && emp.departamento_id && emp.rol_departamento ? ' · <span class="' + (emp.rol_departamento === 'responsable' ? 'text-emerald-400' : 'text-slate-400') + '">' + ROL_LABEL[emp.rol_departamento] + '</span>' : ''} · $${Number(emp.sueldo_semanal).toFixed(2)}/sem · ${Number(emp.horas_semanales)} hrs/sem</p>
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
        if (hayEstructura) {
            const dep = departamentos.find((d) => String(d.id) === selDep.value);
            registro.departamento_id = dep ? dep.id : null;
            registro.departamento = dep ? dep.nombre : null;   // el texto se conserva por compatibilidad
            registro.gerente_id = Number(document.getElementById('empGerente').value) || null;
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

        resetFormulario();
        cargarLista();
    };

    actualizarPreviewCostoHora();
    if (hayEstructura) pintarVistaFoto('');
    await cargarLista();
    actualizarRol();
}
