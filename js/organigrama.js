import { supabaseClient } from './supabase.js';
import { avatarHtml, urlsFotos } from './fotos-personal.js';

// =====================================================================
//  Catálogos · Organigrama
//   Se dibuja solo con el Gerente de cada empleado (empleados.gerente_id):
//   quien no tiene gerente es la cabeza de la organización. No se captura
//   nada aquí; para cambiar la estructura se edita el empleado.
//   Requiere sql/2026-10-28_departamentos_gerente_foto.sql.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|column .* does not exist/i;

export async function cargarModuloOrganigrama() {
    const cont = document.getElementById('view-organigrama');
    if (!cont) return;
    cont.innerHTML = `<p class="text-slate-500 text-sm">Cargando...</p>`;

    const [resEmps, resDeps] = await Promise.all([
        supabaseClient.from('empleados').select('id, nombre, puesto, activo, departamento_id, gerente_id, foto_path').eq('activo', true).order('nombre'),
        supabaseClient.from('departamentos').select('id, nombre').order('nombre'),
    ]);
    const err = resEmps.error || resDeps.error;
    if (err) {
        cont.innerHTML = TABLA_FALTA.test(err.message || '')
            ? `<p class="text-amber-400 text-sm">Falta correr <span class="font-mono">sql/2026-10-28_departamentos_gerente_foto.sql</span> en Supabase.</p>`
            : `<p class="text-rose-400 text-sm">${esc(err.message)}</p>`;
        return;
    }
    const emps = resEmps.data || [];
    const deps = resDeps.data || [];
    const urls = await urlsFotos(emps.map((e) => e.foto_path));
    const depNombre = (id) => deps.find((d) => d.id === id)?.nombre || null;

    const porId = new Map(emps.map((e) => [e.id, e]));
    const hijos = new Map();
    const raices = [];
    emps.forEach((e) => {
        if (e.gerente_id && porId.has(e.gerente_id)) {
            if (!hijos.has(e.gerente_id)) hijos.set(e.gerente_id, []);
            hijos.get(e.gerente_id).push(e);
        } else {
            raices.push(e);   // sin gerente, o su gerente está inactivo
        }
    });
    const huerfanos = raices.filter((e) => e.gerente_id && !porId.has(e.gerente_id));
    const aCargo = (id) => (hijos.get(id) || []).reduce((n, h) => n + 1 + aCargo(h.id), 0);

    function nodo(e, visitados) {
        if (visitados.has(e.id)) return '';   // por seguridad: la base ya impide los círculos
        visitados.add(e.id);
        const subs = (hijos.get(e.id) || []);
        const total = aCargo(e.id);
        const dep = depNombre(e.departamento_id);
        const tarjeta = `
            <div class="flex items-center gap-3 bg-slate-950 border border-slate-800 rounded-xl p-2.5 pr-4 min-w-0">
              ${avatarHtml(e.nombre, urls.get(e.foto_path), 44)}
              <div class="min-w-0">
                <p class="text-sm font-semibold text-slate-100 truncate">${esc(e.nombre)}</p>
                <p class="text-[11px] text-slate-400 truncate">${esc(e.puesto || 'Sin puesto')}</p>
                <p class="text-[10px] text-slate-500 truncate">${dep ? esc(dep) : 'Sin departamento'}${total ? ` · ${total} a su cargo` : ''}</p>
              </div>
            </div>`;
        if (!subs.length) return `<li>${tarjeta}</li>`;
        return `<li>
            <details open>
              <summary class="cursor-pointer list-none">${tarjeta}</summary>
              <ul class="ml-6 pl-4 border-l border-slate-700 mt-2 space-y-2">${subs.map((h) => nodo(h, visitados)).join('')}</ul>
            </details>
          </li>`;
    }

    const visitados = new Set();
    const arbol = raices.map((r) => nodo(r, visitados)).join('');

    cont.innerHTML = `
      <div class="space-y-4 max-w-3xl mx-auto">
        <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
          <div class="flex items-center justify-between gap-2 flex-wrap mb-1">
            <h2 class="text-xl font-bold text-slate-100">🧩 Organigrama</h2>
            <button type="button" onclick="window.loadView('empleados')" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2.5 py-1 rounded-lg whitespace-nowrap cursor-pointer">Editar en Empleados</button>
          </div>
          <p class="text-xs text-slate-400 mb-4">Sale solo del Gerente de cada empleado. Quien no tiene gerente es la cabeza de la organización. Toca una persona para plegar o desplegar su equipo.</p>
          ${raices.length > 1 ? `<p class="text-[11px] text-amber-300 bg-amber-950/40 border border-amber-900/60 rounded-lg px-3 py-2 mb-3">Hay ${raices.length} personas sin gerente${huerfanos.length ? ` (${huerfanos.length} porque su gerente está inactivo)` : ''}. Normalmente solo la cabeza de la organización queda sin gerente.</p>` : ''}
          ${emps.length ? `<ul class="space-y-3">${arbol}</ul>` : `<p class="text-slate-500 text-xs italic">Todavía no hay empleados activos.</p>`}
        </div>
      </div>`;
}
