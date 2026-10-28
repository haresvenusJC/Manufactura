import { supabaseClient } from './supabase.js';
import { avatarHtml, urlsFotos } from './fotos-personal.js';

// =====================================================================
//  Catálogos · Departamentos
//   Cada departamento tiene un tipo (el mismo criterio de los centros de
//   costo), su centro de costo y un responsable (un empleado). El equipo
//   NO se captura aquí: son los empleados que tienen ese departamento.
//   Requiere sql/2026-10-28_departamentos_gerente_foto.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;
const TIPO_LABEL = { produccion: 'Producción', servicio: 'Servicio', administracion: 'Administración', ventas: 'Ventas' };

export async function cargarModuloDepartamentos() {
    const cont = document.getElementById('view-departamentos');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    // Todo en paralelo: lo que la pantalla muestra y los selectores del formulario
    const [resDeps, resEmps, resCentros] = await Promise.all([
        supabaseClient.from('departamentos').select('*').order('nombre'),
        supabaseClient.from('empleados').select('id, nombre, puesto, activo, departamento_id, foto_path').order('nombre'),
        supabaseClient.from('centros_costo').select('id, codigo, nombre').order('codigo'),
    ]);

    if (resDeps.error) {
        cont.innerHTML = TABLA_FALTA.test(resDeps.error.message || '')
            ? `<p class="text-amber-400 text-sm">Falta correr <span class="font-mono">sql/2026-10-28_departamentos_gerente_foto.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-sm">${esc(resDeps.error.message)}</p>`;
        return;
    }
    const deps = resDeps.data || [];
    const emps = resEmps.data || [];
    const centros = resCentros.data || [];
    const urls = await urlsFotos(emps.map((e) => e.foto_path));
    const empDe = (id) => emps.find((e) => e.id === id);

    const opcionesEmp = emps.filter((e) => e.activo).map((e) => `<option value="${e.id}">${esc(e.nombre)}${e.puesto ? ' — ' + esc(e.puesto) : ''}</option>`).join('');
    const opcionesCentro = centros.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
      <div class="space-y-6 max-w-3xl mx-auto">
        <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
          <h2 class="text-xl font-bold text-slate-100 mb-1">🏢 Departamentos</h2>
          <p class="text-xs text-slate-400 mb-4">Define cada departamento y quién lo dirige. Su equipo son los empleados que lo tienen asignado en el Catálogo de Empleados; el Gerente de cada persona se captura allá.</p>
          <form id="depForm" class="space-y-4">
            <input type="hidden" id="depId" value="">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE</label>
                <input type="text" id="depNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
              </div>
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">TIPO (opcional)</label>
                <select id="depTipo" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin definir)</option>
                  ${Object.entries(TIPO_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
                </select>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">RESPONSABLE (opcional)</label>
                <select id="depResp" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin asignar)</option>${opcionesEmp}
                </select>
              </div>
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">CENTRO DE COSTO (opcional)</label>
                <select id="depCentro" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin asignar)</option>${opcionesCentro}
                </select>
              </div>
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">NOTAS (opcional)</label>
              <input type="text" id="depNotas" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            </div>
            <label class="flex items-center gap-2 text-xs text-slate-300"><input type="checkbox" id="depActivo" checked class="accent-emerald-500"> Activo</label>
            <p id="depMsg" class="text-xs min-h-[1rem]"></p>
            <div class="flex items-center gap-3">
              <button type="submit" id="depGuardar" class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2 px-4 rounded-lg text-sm shadow-lg">💾 Guardar departamento</button>
              <button type="button" id="depCancelar" class="hidden bg-slate-800 hover:bg-slate-700 text-slate-200 py-2 px-4 rounded-lg text-sm border border-slate-700">Cancelar edición</button>
            </div>
          </form>
        </div>

        <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
          <h3 class="text-sm font-bold text-slate-200 mb-3">Departamentos registrados</h3>
          <div id="depLista" class="space-y-3"></div>
        </div>
      </div>`;

    const $ = (id) => document.getElementById(id);

    function pintarLista() {
        const lista = $('depLista');
        if (!deps.length) { lista.innerHTML = `<p class="text-slate-500 text-xs italic">Todavía no hay departamentos.</p>`; return; }
        lista.innerHTML = deps.map((d) => {
            const equipo = emps.filter((e) => e.departamento_id === d.id && e.activo);
            const resp = d.responsable_id ? empDe(d.responsable_id) : null;
            const centro = centros.find((c) => c.id === d.centro_costo_id);
            return `
            <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 ${d.activo ? '' : 'opacity-50'}">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <p class="text-sm font-semibold text-slate-100">${esc(d.nombre)} ${d.activo ? '' : '<span class="text-[10px] text-rose-400">(inactivo)</span>'}</p>
                  <p class="text-[11px] text-slate-500">${d.tipo ? esc(TIPO_LABEL[d.tipo]) : 'Sin tipo'} · ${centro ? 'Centro de costo ' + esc(centro.codigo) : 'Sin centro de costo'} · Responsable: ${resp ? esc(resp.nombre) : 'sin asignar'}</p>
                  ${d.notas ? `<p class="text-[11px] text-slate-500 italic">${esc(d.notas)}</p>` : ''}
                </div>
                <div class="flex items-center gap-3 shrink-0">
                  <button type="button" class="dep-editar text-slate-400 hover:text-sky-400 text-xs" data-id="${d.id}">✏️</button>
                  <button type="button" class="dep-toggle text-slate-400 hover:text-amber-400 text-xs" data-id="${d.id}">${d.activo ? '🚫' : '✅'}</button>
                </div>
              </div>
              <div class="mt-2 flex flex-wrap gap-2">
                ${equipo.length ? equipo.map((e) => `<span class="flex items-center gap-1.5 bg-slate-900 border border-slate-800 rounded-full pl-1 pr-2.5 py-0.5 text-[11px] text-slate-300">${avatarHtml(e.nombre, urls.get(e.foto_path), 20)}${esc(e.nombre)}</span>`).join('')
                  : '<span class="text-[11px] text-slate-600 italic">Sin empleados asignados</span>'}
              </div>
            </div>`;
        }).join('');

        lista.querySelectorAll('.dep-editar').forEach((b) => {
            b.onclick = () => {
                const d = deps.find((x) => x.id === Number(b.dataset.id));
                if (!d) return;
                $('depId').value = d.id; $('depNombre').value = d.nombre; $('depTipo').value = d.tipo || '';
                $('depResp').value = d.responsable_id ? String(d.responsable_id) : '';
                $('depCentro').value = d.centro_costo_id ? String(d.centro_costo_id) : '';
                $('depNotas').value = d.notas || ''; $('depActivo').checked = d.activo;
                $('depCancelar').classList.remove('hidden'); $('depGuardar').textContent = '💾 Actualizar departamento';
                window.scrollTo({ top: 0, behavior: 'smooth' });
            };
        });
        lista.querySelectorAll('.dep-toggle').forEach((b) => {
            b.onclick = async () => {
                const d = deps.find((x) => x.id === Number(b.dataset.id));
                if (!d) return;
                const equipo = emps.filter((e) => e.departamento_id === d.id && e.activo).length;
                if (d.activo && equipo && !confirm(`"${d.nombre}" tiene ${equipo} empleado(s) activo(s). Al desactivarlo ya no aparecerá para asignar a nadie más. ¿Continuar?`)) return;
                const { error } = await supabaseClient.from('departamentos').update({ activo: !d.activo }).eq('id', d.id);
                if (error) { alert('❌ ' + error.message); return; }
                cargarModuloDepartamentos();
            };
        });
    }

    function limpiar() {
        $('depForm').reset(); $('depId').value = ''; $('depMsg').textContent = '';
        $('depCancelar').classList.add('hidden'); $('depGuardar').textContent = '💾 Guardar departamento';
    }
    $('depCancelar').onclick = limpiar;

    $('depForm').onsubmit = async (e) => {
        e.preventDefault();
        const msg = $('depMsg'); msg.className = 'text-xs min-h-[1rem]'; msg.textContent = '';
        const fila = {
            nombre: $('depNombre').value.trim(),
            tipo: $('depTipo').value || null,
            responsable_id: Number($('depResp').value) || null,
            centro_costo_id: Number($('depCentro').value) || null,
            notas: $('depNotas').value.trim() || null,
            activo: $('depActivo').checked,
        };
        if (!fila.nombre) { msg.textContent = 'Falta el nombre.'; msg.className = 'text-xs text-rose-400'; return; }
        const id = Number($('depId').value) || null;
        const { error } = id
            ? await supabaseClient.from('departamentos').update(fila).eq('id', id)
            : await supabaseClient.from('departamentos').insert([fila]);
        if (error) {
            const igual = deps.find((d) => d.id !== id && String(d.nombre).trim().toLowerCase() === fila.nombre.toLowerCase());
            msg.textContent = /departamentos_nombre_uq|duplicate/i.test(error.message || '')
                ? (igual && !igual.activo
                    ? `"${igual.nombre}" ya existe pero está inactivo. Reactívalo con el botón ✅ de su tarjeta (abajo) en vez de crear otro.`
                    : 'Ya existe un departamento con ese nombre.')
                : 'No se pudo guardar: ' + error.message;
            msg.className = 'text-xs text-rose-400';
            return;
        }
        // Si cambió el nombre, los empleados conservan el texto viejo en empleados.departamento: se sincroniza.
        if (id) await supabaseClient.from('empleados').update({ departamento: fila.nombre }).eq('departamento_id', id);
        cargarModuloDepartamentos();
    };

    pintarLista();
}
