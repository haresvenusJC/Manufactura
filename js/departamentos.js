import { supabaseClient } from './supabase.js';
import { avatarHtml, urlsFotos } from './fotos-personal.js';
import { convertirEnBuscador } from './buscador-select.js';
import { abrirAltaVinculada } from './vinculos.js';
import { homologarGerentes } from './empleados.js';

// =====================================================================
//  Catálogos · Departamentos
//   Cada departamento tiene un tipo (el mismo criterio de los centros de
//   costo), su centro de costo y, opcionalmente, un departamento SUPERIOR
//   (Finanzas → Cuentas por pagar). El responsable NO se captura aquí: sale
//   del rol «Responsable de Departamento» que RH le da al empleado en el
//   Catálogo de Empleados. El equipo son los empleados con ese departamento.
//   Requiere sql/2026-10-28_departamentos_gerente_foto.sql y, para la
//   jerarquía y el rol, sql/2026-10-30_departamento_superior_rol.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|relation .* does not exist/i;
const TIPO_LABEL = { produccion: 'Producción', servicio: 'Servicio', administracion: 'Administración', ventas: 'Ventas' };

export async function cargarModuloDepartamentos() {
    const cont = document.getElementById('view-departamentos');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    // Todo en paralelo: lo que la pantalla muestra y los selectores del formulario
    const [resDeps, resEmpsRol, resCentros, resProbe] = await Promise.all([
        supabaseClient.from('departamentos').select('*').order('nombre'),
        supabaseClient.from('empleados').select('id, nombre, puesto, activo, departamento_id, foto_path, rol_departamento, gerente_id').order('nombre'),
        supabaseClient.from('centros_costo').select('id, codigo, nombre').order('codigo'),
        supabaseClient.from('departamentos').select('departamento_padre_id').limit(1),
    ]);

    if (resDeps.error) {
        cont.innerHTML = TABLA_FALTA.test(resDeps.error.message || '')
            ? `<p class="text-amber-400 text-sm">Falta correr <span class="font-mono">sql/2026-10-28_departamentos_gerente_foto.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-sm">${esc(resDeps.error.message)}</p>`;
        return;
    }
    // Sin la migración del 30-oct la pantalla funciona como antes (sin superior y con el selector de responsable).
    const hayJerarquia = !resProbe.error && !resEmpsRol.error;
    const resEmps = resEmpsRol.error
        ? await supabaseClient.from('empleados').select('id, nombre, puesto, activo, departamento_id, foto_path, gerente_id').order('nombre')
        : resEmpsRol;
    const deps = resDeps.data || [];
    const emps = resEmps.data || [];
    const centros = resCentros.data || [];
    const urls = await urlsFotos(emps.map((e) => e.foto_path));
    const empDe = (id) => emps.find((e) => e.id === id);
    const depDe = (id) => deps.find((d) => d.id === id);

    // Responsable de un departamento: el empleado activo con rol «responsable» (RH); sin migración, el campo viejo.
    const responsableDe = (d) => hayJerarquia
        ? emps.find((e) => e.activo && e.departamento_id === d.id && e.rol_departamento === 'responsable') || null
        : (d.responsable_id ? empDe(d.responsable_id) : null);

    // Con la jerarquía/rol, solo se ofrecen quienes en su plantilla de empleado están marcados como «Responsable de Departamento».
    const etiquetaResp = (e) => `${e.nombre}${e.puesto ? ' — ' + e.puesto : ''}${e.departamento_id && depDe(e.departamento_id) ? ' · ' + depDe(e.departamento_id).nombre : ''}`;
    const opcionesEmp = emps.filter((e) => e.activo && (!hayJerarquia || e.rol_departamento === 'responsable'))
        .map((e) => `<option value="${e.id}">${esc(etiquetaResp(e))}</option>`).join('');
    const opcionesCentro = centros.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const selectTipo = (id) => `<select id="${id}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin definir)</option>
                  ${Object.entries(TIPO_LABEL).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}
                </select>`;
    const selectCentro = (id) => `<select id="${id}" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin asignar)</option>${opcionesCentro}
                </select>`;

    cont.innerHTML = `
      <div class="space-y-6 max-w-3xl mx-auto">
        <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
          <h2 class="text-xl font-bold text-slate-100 mb-1">🏢 Departamentos</h2>
          <p class="text-xs text-slate-400 mb-4">Define cada departamento y, si cuelga de otro, su departamento superior (p. ej. Finanzas → Cuentas por pagar). El responsable sale de Recursos Humanos: en el Catálogo de Empleados se marca quién es «Responsable de Departamento». Su equipo son los empleados que lo tienen asignado.</p>
          ${hayJerarquia ? '' : `<p class="text-[11px] text-amber-300 bg-amber-950/40 border border-amber-900/60 rounded-lg px-3 py-2 mb-4">Falta correr <span class="font-mono">sql/2026-10-30_departamento_superior_rol.sql</span> en Supabase para usar Departamento superior y el responsable desde Empleados. Mientras tanto la pantalla funciona como antes.</p>`}
          <form id="depForm" class="space-y-4">
            <input type="hidden" id="depId" value="">
            ${hayJerarquia ? `
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">DEPARTAMENTO SUPERIOR (si cuelga de otro)</label>
              <select id="depPadre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
              <p id="depPadreHint" class="text-[11px] text-slate-500 mt-1">Vacío = departamento de primer nivel. Elegir un superior solo ubica a este departamento en el árbol; no le copia datos.</p>
            </div>` : ''}
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE DEL DEPARTAMENTO</label>
                <input type="text" id="depNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
              </div>
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">TIPO (opcional)</label>
                ${selectTipo('depTipo')}
              </div>
            </div>
            ${hayJerarquia ? `
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">SUBDEPARTAMENTO (si tiene: escribe su nombre)</label>
              <input type="text" id="depSub" placeholder="p. ej. Cuentas por pagar" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <p class="text-[11px] text-slate-500 mt-1">Al guardar se crea como hijo de este departamento y HEREDA su tipo y centro de costo. Para varios, guarda y repite.</p>
            </div>` : ''}
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">RESPONSABLE DEL DEPARTAMENTO</label>
                <select id="depResp" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                  <option value="">(sin asignar)</option>${opcionesEmp}
                </select>
                ${hayJerarquia ? `<p class="text-[11px] text-slate-500 mt-1">Solo aparecen quienes están marcados como «Responsable de Departamento» en su plantilla de empleado. ¿No está? Elige «Crear y editar…»: se abre la plantilla de Empleados (puedes crear uno nuevo o editar a alguien de su lista y marcarlo como Responsable).</p>` : ''}
              </div>
              <div>
                <label class="block text-xs font-medium text-slate-400 mb-1">CENTRO DE COSTO (opcional)</label>
                ${selectCentro('depCentro')}
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
          <div id="depHomologa"></div>
          <div id="depLista" class="space-y-3"></div>
        </div>
      </div>`;

    const $ = (id) => document.getElementById(id);

    // ---- Departamento superior: buscador «Elija uno» + «Crear y editar…» -------------------------
    // Excluye al propio departamento y a sus descendientes (la base también impide los círculos).
    function descendientesDe(id) {
        const fuera = new Set([id]);
        let cambio = true;
        while (cambio) {
            cambio = false;
            for (const d of deps) {
                if (!fuera.has(d.id) && d.departamento_padre_id && fuera.has(d.departamento_padre_id)) { fuera.add(d.id); cambio = true; }
            }
        }
        return fuera;
    }
    function pintarOpcionesPadre(excluirId, seleccionado) {
        const sel = $('depPadre');
        if (!sel) return;
        const fuera = excluirId ? descendientesDe(excluirId) : new Set();
        sel.innerHTML = `<option value="">(ninguno: primer nivel)</option>`
            + deps.filter((d) => d.activo && !fuera.has(d.id)).map((d) => `<option value="${d.id}">${esc(rutaDe(d))}</option>`).join('');
        sel.value = seleccionado ? String(seleccionado) : '';
        if (sel.buscadorRefrescar) sel.buscadorRefrescar();
    }
    function rutaDe(d) {   // «Finanzas › Cuentas por pagar»
        const partes = [d.nombre];
        let p = d.departamento_padre_id ? depDe(d.departamento_padre_id) : null;
        let n = 0;
        while (p && n++ < 20) { partes.unshift(p.nombre); p = p.departamento_padre_id ? depDe(p.departamento_padre_id) : null; }
        return partes.join(' › ');
    }

    // Subventana mínima para dar de alta un departamento sin salir de esta pantalla.
    function abrirCrearDepartamento(texto, select) {
        const id = window.idSubventana ? window.idSubventana('depCrearWrap') : 'depCrearWrap';
        const ov = document.createElement('div');
        ov.id = id;
        ov.className = 'fixed inset-0 bg-slate-950/40 z-[60] flex items-center justify-center p-3';
        ov.innerHTML = `
          <div class="w-full max-w-md bg-slate-900 border border-slate-700 rounded-xl p-4 shadow-2xl space-y-3">
            <div class="flex items-center justify-between"><h3 class="text-sm font-bold text-slate-100">➕ Nuevo departamento</h3>
              <button type="button" data-x class="text-slate-400 hover:text-slate-100">✕</button></div>
            <div><label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE</label>
              <input type="text" data-n class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" value="${esc(texto)}"></div>
            <div class="grid grid-cols-2 gap-3">
              <div><label class="block text-xs font-medium text-slate-400 mb-1">TIPO</label>${selectTipo('depCrTipo')}</div>
              <div><label class="block text-xs font-medium text-slate-400 mb-1">CENTRO DE COSTO</label>${selectCentro('depCrCentro')}</div>
            </div>
            <p data-m class="text-xs min-h-[1rem]"></p>
            <div class="flex gap-2 justify-end">
              <button type="button" data-x class="bg-slate-800 hover:bg-slate-700 text-slate-200 py-1.5 px-3 rounded-lg text-sm border border-slate-700">Cancelar</button>
              <button type="button" data-ok class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-1.5 px-3 rounded-lg text-sm">Crear</button>
            </div>
          </div>`;
        document.body.appendChild(ov);
        const q = (s) => ov.querySelector(s);
        const cerrar = () => ov.remove();
        ov.querySelectorAll('[data-x]').forEach((b) => { b.onclick = cerrar; });
        q('[data-n]').focus();
        q('[data-ok]').onclick = async () => {
            const nombre = q('[data-n]').value.trim();
            const m = q('[data-m]');
            if (!nombre) { m.textContent = 'Falta el nombre.'; m.className = 'text-xs text-rose-400'; return; }
            const fila = { nombre, tipo: q('#depCrTipo').value || null, centro_costo_id: Number(q('#depCrCentro').value) || null, activo: true };
            const { data, error } = await supabaseClient.from('departamentos').insert([fila]).select('*').single();
            if (error) {
                m.textContent = /departamentos_nombre_uq|duplicate/i.test(error.message || '') ? 'Ya existe un departamento con ese nombre.' : 'No se pudo crear: ' + error.message;
                m.className = 'text-xs text-rose-400';
                return;
            }
            deps.push(data);
            pintarOpcionesPadre(Number($('depId').value) || null, data.id);
            select.dispatchEvent(new Event('change', { bubbles: true }));
            pintarLista();
            cerrar();
        };
    }

    // Responsable: buscador de empleados; si no está, «Crear y editar…» abre la plantilla de Empleados y regresa con la persona elegida.
    const abrirCrearEmpleado = (texto, select) => abrirAltaVinculada('empleado', {
        nombre: texto,
        onGuardado: async ({ id }) => {
            const { data } = await supabaseClient.from('empleados')
                .select(hayJerarquia ? 'id, nombre, puesto, activo, departamento_id, foto_path, gerente_id, rol_departamento' : 'id, nombre, puesto, activo, departamento_id, foto_path')
                .eq('id', id).single();
            if (!data) return;
            const i = emps.findIndex((e) => e.id === data.id);
            if (i >= 0) emps[i] = data; else emps.push(data);
            if (hayJerarquia && (!data.activo || data.rol_departamento !== 'responsable')) {
                alert(`${data.nombre} no está marcado como «Responsable de Departamento» en su plantilla de empleado, por eso no se puede elegir aquí. Edítalo en Empleados (Rol en el departamento) y vuelve a intentar.`);
                return;
            }
            if (![...select.options].some((o) => o.value === String(data.id))) select.add(new Option(etiquetaResp(data), data.id));
            select.value = String(data.id);
            select.dispatchEvent(new Event('change', { bubbles: true }));
        },
    });
    convertirEnBuscador($('depResp'), { placeholder: 'Elegir Empleado', crear: abrirCrearEmpleado, crearVacio: true });

    if (hayJerarquia) {
        pintarOpcionesPadre(null, null);
        convertirEnBuscador($('depPadre'), { placeholder: 'Elija uno', crear: abrirCrearDepartamento });
    }

    // ---- Lista jerárquica ------------------------------------------------------------------------
    function enOrdenDeArbol() {
        const hijosDe = (id) => deps.filter((d) => (d.departamento_padre_id || null) === id);
        const salida = [];
        const visto = new Set();
        const recorrer = (id, nivel) => {
            for (const d of hijosDe(id)) {
                if (visto.has(d.id)) continue;
                visto.add(d.id); salida.push({ d, nivel }); recorrer(d.id, nivel + 1);
            }
        };
        // Los que apuntan a un superior que no existe cuentan como de primer nivel
        recorrer(null, 0);
        deps.filter((d) => !visto.has(d.id)).forEach((d) => { visto.add(d.id); salida.push({ d, nivel: 0 }); recorrer(d.id, 1); });
        return salida;
    }

    // Homologación con Empleados: el Gerente esperado de cada persona sale de la jerarquía de departamentos.
    //  · Colaborador de un departamento → el responsable de ese departamento.
    //  · Responsable de un departamento → el responsable del departamento superior más cercano que tenga uno.
    function gerenteEsperado(e) {
        if (!hayJerarquia || !e.departamento_id) return null;
        const respDe = (depId) => emps.find((x) => x.activo && x.id !== e.id && x.departamento_id === depId && x.rol_departamento === 'responsable') || null;
        const d = depDe(e.departamento_id);
        if (!d) return null;
        if (e.rol_departamento !== 'responsable') return respDe(d.id);
        let p = d.departamento_padre_id ? depDe(d.departamento_padre_id) : null;
        for (let n = 0; p && n < 20; n++) {
            const r = respDe(p.id);
            if (r) return r;
            p = p.departamento_padre_id ? depDe(p.departamento_padre_id) : null;
        }
        return null;
    }
    function pintarHomologacion() {
        const cont = $('depHomologa');
        if (!cont || !hayJerarquia) return;
        const difieren = emps.filter((e) => {
            if (!e.activo) return false;
            const g = gerenteEsperado(e);
            return g && e.gerente_id !== g.id;
        });
        if (!difieren.length) { cont.innerHTML = ''; return; }
        cont.innerHTML = `
          <div class="bg-amber-950/40 border border-amber-900/60 rounded-lg p-3 mb-3 text-[11px] text-amber-200">
            <p class="font-semibold mb-1">⚠ ${difieren.length} empleado(s) con Gerente distinto al que marca la jerarquía de departamentos</p>
            <ul class="mb-2 space-y-0.5">${difieren.map((e) => `<li>${esc(e.nombre)}: ${e.gerente_id && empDe(e.gerente_id) ? esc(empDe(e.gerente_id).nombre) : 'sin gerente'} → <b>${esc(gerenteEsperado(e).nombre)}</b></li>`).join('')}</ul>
            <button type="button" id="depHomologar" class="bg-amber-600 hover:bg-amber-500 text-white font-semibold py-1 px-3 rounded-lg text-xs">Homologar Gerentes</button>
          </div>`;
        $('depHomologar').onclick = async () => {
            const fallos = [];
            for (const e of difieren) {
                const { error } = await supabaseClient.from('empleados').update({ gerente_id: gerenteEsperado(e).id }).eq('id', e.id);
                if (error) fallos.push(`${e.nombre}: ${error.message}`);
            }
            if (fallos.length) alert('Algunos no se pudieron homologar:\n' + fallos.join('\n'));
            cargarModuloDepartamentos();
        };
    }

    function pintarLista() {
        pintarHomologacion();
        const lista = $('depLista');
        if (!deps.length) { lista.innerHTML = `<p class="text-slate-500 text-xs italic">Todavía no hay departamentos.</p>`; return; }
        lista.innerHTML = enOrdenDeArbol().map(({ d, nivel }) => {
            const equipo = emps.filter((e) => e.departamento_id === d.id && e.activo);
            const resp = responsableDe(d);
            const centro = centros.find((c) => c.id === d.centro_costo_id);
            const padre = d.departamento_padre_id ? depDe(d.departamento_padre_id) : null;
            return `
            <div class="bg-slate-950 border border-slate-800 rounded-lg p-3 ${d.activo ? '' : 'opacity-50'}" style="margin-left:${Math.min(nivel, 5) * 1.25}rem">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <p class="text-sm font-semibold text-slate-100">${nivel ? '<span class="text-slate-600">↳</span> ' : ''}${esc(d.nombre)} ${d.activo ? '' : '<span class="text-[10px] text-rose-400">(inactivo)</span>'}</p>
                  <p class="text-[11px] text-slate-500">${padre ? 'Superior: ' + esc(padre.nombre) + ' · ' : ''}${d.tipo ? esc(TIPO_LABEL[d.tipo]) : 'Sin tipo'} · ${centro ? 'Centro de costo ' + esc(centro.codigo) : 'Sin centro de costo'} · Responsable: ${resp ? esc(resp.nombre) + (resp.puesto ? ' (' + esc(resp.puesto) + ')' : '') : 'sin asignar'}</p>
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
                if (hayJerarquia) {
                    pintarOpcionesPadre(d.id, d.departamento_padre_id);
                    const r = responsableDe(d);
                    $('depResp').value = r ? String(r.id) : '';
                    $('depSub').value = '';
                } else {
                    $('depResp').value = d.responsable_id ? String(d.responsable_id) : '';
                }
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
        if (hayJerarquia) pintarOpcionesPadre(null, null);
        $('depCancelar').classList.add('hidden'); $('depGuardar').textContent = '💾 Guardar departamento';
    }
    $('depCancelar').onclick = limpiar;

    const mensajeDuplicado = (nombre, id) => {
        const igual = deps.find((d) => d.id !== id && String(d.nombre).trim().toLowerCase() === nombre.toLowerCase());
        return igual && !igual.activo
            ? `"${igual.nombre}" ya existe pero está inactivo. Reactívalo con el botón ✅ de su tarjeta (abajo) en vez de crear otro.`
            : 'Ya existe un departamento con ese nombre.';
    };

    $('depForm').onsubmit = async (e) => {
        e.preventDefault();
        const msg = $('depMsg'); msg.className = 'text-xs min-h-[1rem]'; msg.textContent = '';
        const fila = {
            nombre: $('depNombre').value.trim(),
            tipo: $('depTipo').value || null,
            centro_costo_id: Number($('depCentro').value) || null,
            notas: $('depNotas').value.trim() || null,
            activo: $('depActivo').checked,
        };
        if (hayJerarquia) fila.departamento_padre_id = Number($('depPadre').value) || null;
        else fila.responsable_id = Number($('depResp').value) || null;   // el responsable de verdad sale del rol en Empleados
        if (!fila.nombre) { msg.textContent = 'Falta el nombre.'; msg.className = 'text-xs text-rose-400'; return; }
        const nombreSub = hayJerarquia ? $('depSub').value.trim() : '';
        if (nombreSub && nombreSub.toLowerCase() === fila.nombre.toLowerCase()) {
            msg.textContent = 'El subdepartamento debe llamarse distinto que su departamento.'; msg.className = 'text-xs text-rose-400'; return;
        }
        const id = Number($('depId').value) || null;
        // Responsable elegido (solo con la jerarquía/rol): si la persona ya está en otro departamento, se confirma el cambio.
        const respId = hayJerarquia ? (Number($('depResp').value) || null) : null;
        const respNuevo = respId ? empDe(respId) : null;
        if (respNuevo && respNuevo.departamento_id && respNuevo.departamento_id !== id) {
            const otro = depDe(respNuevo.departamento_id);
            if (!confirm(`${respNuevo.nombre} hoy pertenece a ${otro ? '«' + otro.nombre + '»' : 'otro departamento'}. Al guardar pasará a «${fila.nombre}» como Responsable de Departamento. ¿Continuar?`)) return;
        }
        const res = id
            ? await supabaseClient.from('departamentos').update(fila).eq('id', id).select('id').single()
            : await supabaseClient.from('departamentos').insert([fila]).select('id').single();
        if (res.error) {
            msg.textContent = /departamentos_nombre_uq|duplicate/i.test(res.error.message || '')
                ? mensajeDuplicado(fila.nombre, id)
                : 'No se pudo guardar: ' + res.error.message;
            msg.className = 'text-xs text-rose-400';
            return;
        }
        const idGuardado = res.data?.id ?? id;
        // Si cambió el nombre, los empleados conservan el texto viejo en empleados.departamento: se sincroniza.
        if (id) await supabaseClient.from('empleados').update({ departamento: fila.nombre }).eq('departamento_id', id);

        // Responsable: se escribe en la plantilla del empleado (única fuente); el responsable anterior pasa a Colaborador.
        if (hayJerarquia && idGuardado) {
            const actual = emps.find((e) => e.activo && e.departamento_id === idGuardado && e.rol_departamento === 'responsable');
            if ((actual ? actual.id : null) !== respId) {
                if (actual) {
                    const { error: e1 } = await supabaseClient.from('empleados').update({ rol_departamento: 'colaborador' }).eq('id', actual.id);
                    if (e1) alert('No se pudo quitar al responsable anterior: ' + e1.message);
                }
                if (respId) {
                    const { error: e2 } = await supabaseClient.from('empleados')
                        .update({ departamento_id: idGuardado, departamento: fila.nombre, rol_departamento: 'responsable' }).eq('id', respId);
                    if (e2) alert('Departamento guardado, pero no se pudo asignar al responsable: ' + e2.message);
                }
            }
        }

        // Con el responsable o la jerarquía cambiados, el Gerente de cada persona se rehomologa solo.
        if (hayJerarquia) await homologarGerentes();

        // Subdepartamento: nace como hijo, con el tipo y el centro de costo de este departamento.
        if (nombreSub && idGuardado) {
            const { error: errSub } = await supabaseClient.from('departamentos').insert([{
                nombre: nombreSub, tipo: fila.tipo, centro_costo_id: fila.centro_costo_id,
                departamento_padre_id: idGuardado, activo: true,
            }]);
            if (errSub) {
                alert('Departamento guardado, pero el subdepartamento no se pudo crear: '
                    + (/departamentos_nombre_uq|duplicate/i.test(errSub.message || '') ? mensajeDuplicado(nombreSub, null) : errSub.message));
            }
        }
        cargarModuloDepartamentos();
    };

    pintarLista();
}
