import { supabaseClient } from './supabase.js';
import { urlsFotos, avatarHtml } from './fotos-personal.js';

// =====================================================================
//  Firmas de los documentos: quién solicita y quién autoriza.
//   Los nombres salen de la plantilla de Empleados (puesto, departamento y
//   Gerente), no de texto libre. Mientras no haya claves de acceso por
//   persona, el responsable se fija con una lista desplegable.
//   Requiere sql/2026-10-28_departamentos_gerente_foto.sql; sin ella
//   devuelve la lista simple de empleados y las firmas salen sin departamento.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Empleados activos y departamentos, en paralelo.
export async function cargarPersonal() {
    const [e, d] = await Promise.all([
        supabaseClient.from('empleados').select('id, nombre, puesto, departamento_id, departamento, gerente_id, foto_path').eq('activo', true).order('nombre'),
        supabaseClient.from('departamentos').select('id, nombre, responsable_id').eq('activo', true).order('nombre'),
    ]);
    if (e.error || d.error) {
        const simple = await supabaseClient.from('empleados').select('id, nombre, puesto').eq('activo', true).order('nombre');
        return { disponible: false, empleados: simple.data || [], departamentos: [] };
    }
    return { disponible: true, empleados: e.data || [], departamentos: d.data || [] };
}

export const empleadoDe = (personal, id) => (id ? personal.empleados.find((x) => x.id === Number(id)) || null : null);
export const gerenteDe = (personal, id) => {
    const emp = empleadoDe(personal, id);
    return emp && emp.gerente_id ? empleadoDe(personal, emp.gerente_id) : null;
};

// { nombre, puesto, departamento } de un empleado (o null).
export function datosFirma(personal, id) {
    const emp = empleadoDe(personal, id);
    if (!emp) return null;
    const dep = personal.departamentos.find((d) => d.id === emp.departamento_id);
    return { nombre: emp.nombre, foto_path: emp.foto_path || null, puesto: emp.puesto || '', departamento: dep ? dep.nombre : (emp.departamento || '') };
}

// Quién autoriza: el elegido; si no hay, el Gerente del solicitante.
export function autorizaEsperado(personal, autorizaId, solicitanteId) {
    return datosFirma(personal, autorizaId) || datosFirma(personal, gerenteDe(personal, solicitanteId)?.id);
}

// Agrega `url` (foto firmada) a cada firma que tenga foto; solo para pantalla, nunca se imprime.
export async function conFotos(...firmas) {
    const lista = firmas.filter(Boolean);
    const mapa = await urlsFotos(lista.map((f) => f.foto_path));
    lista.forEach((f) => { f.url = mapa.get(f.foto_path) || null; });
    return firmas;
}

// Icono pequeño (foto o iniciales) para pantallas digitales; oculto al imprimir.
export function htmlIconoPersona(firma, tam = 28) {
    return firma ? `<span class="print:hidden inline-flex align-middle mr-1.5">${avatarHtml(firma.nombre, firma.url, tam)}</span>` : '';
}

// Un renglón de firma: el nombre sobre la línea; debajo, el rol y el puesto.
export function htmlFirma(rol, firma) {
    const detalle = firma ? [firma.puesto, firma.departamento].filter(Boolean).join(' · ') : '';
    return `<div>
        <p class="mt-8 min-h-[1.25rem] text-sm font-medium text-slate-100 flex items-center gap-1.5">${htmlIconoPersona(firma, 24)}${firma ? esc(firma.nombre) : ''}</p>
        <p class="border-t border-slate-600 pt-1">${esc(rol)}${detalle ? ` <span class="text-slate-500">· ${esc(detalle)}</span>` : ''}</p>
    </div>`;
}

export function htmlBloqueFirmas(solicito, autorizo, rolAutoriza = 'Revisó y autorizó') {
    return `<div class="grid grid-cols-2 gap-6 mt-6 pt-4 border-t border-slate-800 text-xs text-slate-400">
        ${htmlFirma('Solicitó', solicito)}${htmlFirma(rolAutoriza, autorizo)}
    </div>`;
}

// Para documentos que ya traen sus ids (ej. la orden de compra): arma las dos firmas.
export async function resolverFirmas({ solicitanteId, autorizaId }) {
    const personal = await cargarPersonal();
    const solicito = datosFirma(personal, solicitanteId);
    const autorizo = autorizaEsperado(personal, autorizaId, solicitanteId);
    await conFotos(solicito, autorizo);
    return { solicito, autorizo };
}
