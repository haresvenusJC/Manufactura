import { supabaseClient } from './supabase.js';

export async function cargarModuloEmpleados() {
    const contenedor = document.getElementById('view-empleados');
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div class="space-y-6 max-w-3xl mx-auto">
            <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <h2 class="text-xl font-bold text-slate-100 mb-1">👷 Catálogo de Empleados</h2>
                <p class="text-xs text-slate-400 mb-4">Captura el sueldo semanal y las horas semanales de cada empleado; el costo por hora se calcula automáticamente para usarse en los cronómetros de producción.</p>

                <form id="formEmpleado" class="space-y-4">
                    <input type="hidden" id="empIdEditando" value="">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE</label>
                        <input type="text" id="empNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PUESTO (opcional)</label>
                            <input type="text" id="empPuesto" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">PIN MÓVIL (4 dígitos)</label>
                            <input type="text" id="empPin" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" placeholder="Dejar vacío para no cambiar"
                                   class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono tracking-widest">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">FECHA DE INGRESO (opcional)</label>
                            <input type="date" id="empFechaIngreso" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">DEPARTAMENTO (opcional)</label>
                            <select id="empDepartamento" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                <option value="">(sin asignar)</option>
                                <option value="Producción">Producción</option>
                                <option value="Administración">Administración</option>
                                <option value="Ventas">Ventas</option>
                                <option value="Almacén">Almacén</option>
                            </select>
                        </div>
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
            cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar: ${error.message}</p>`;
            return;
        }
        if (!data || !data.length) {
            cont.innerHTML = `<p class="text-slate-500 text-xs italic">Todavía no hay empleados registrados.</p>`;
            return;
        }

        cont.innerHTML = data.map(emp => `
            <div class="flex items-center justify-between bg-slate-950 border border-slate-800 rounded-lg p-3 ${!emp.activo ? 'opacity-50' : ''}">
                <div>
                    <p class="text-sm font-semibold text-slate-200">${emp.nombre} ${!emp.activo ? '<span class="text-[10px] text-rose-400">(inactivo)</span>' : ''}</p>
                    <p class="text-[11px] text-slate-500">${emp.puesto || 'Sin puesto'}${emp.departamento ? ' · ' + emp.departamento : ''} · $${Number(emp.sueldo_semanal).toFixed(2)}/sem · ${Number(emp.horas_semanales)} hrs/sem</p>
                    <p class="text-[11px] mt-0.5 ${emp.pin_hash ? 'text-emerald-500' : 'text-amber-500'}">${emp.pin_hash ? 'PIN móvil ✓' : 'Sin PIN móvil'}</p>
                </div>
                <div class="flex items-center gap-3">
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
                document.getElementById('empDepartamento').value = emp.departamento || '';
                document.getElementById('empRfc').value = emp.rfc || '';
                document.getElementById('empCurp').value = emp.curp || '';
                document.getElementById('empNss').value = emp.nss || '';
                document.getElementById('empSueldo').value = emp.sueldo_semanal;
                document.getElementById('empHoras').value = emp.horas_semanales;
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
        actualizarPreviewCostoHora();
    }

    document.getElementById('btnCancelarEdicionEmp').onclick = resetFormulario;

    document.getElementById('formEmpleado').onsubmit = async (e) => {
        e.preventDefault();
        const idEditando = document.getElementById('empIdEditando').value;
        const registro = {
            nombre: document.getElementById('empNombre').value.trim(),
            puesto: document.getElementById('empPuesto').value.trim() || null,
            fecha_ingreso: document.getElementById('empFechaIngreso').value || null,
            departamento: document.getElementById('empDepartamento').value || null,
            rfc: document.getElementById('empRfc').value.trim().toUpperCase() || null,
            curp: document.getElementById('empCurp').value.trim().toUpperCase() || null,
            nss: document.getElementById('empNss').value.trim() || null,
            sueldo_semanal: parseFloat(document.getElementById('empSueldo').value) || 0,
            horas_semanales: parseFloat(document.getElementById('empHoras').value) || 1
        };

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
    await cargarLista();
}