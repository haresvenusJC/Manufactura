import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';
import { linkDoc, linkPoliza } from './enlaces-reporte.js';
import { ordenarCentrosProduccion } from './centros-costo.js';
import { cargarCategoriasDep, opcionesCategoriaDep, textoCategoriaDep, vidaMesesDePct } from './categorias-depreciacion.js';

// =====================================================================
//  Activos fijos y depreciación (NIF C-6, línea recta): catálogo de
//  activos (maquinaria, equipo, vehículos...) y la corrida mensual de
//  depreciación — una póliza por mes (cargo a gasto de depreciación,
//  abono a depreciación acumulada), con su historial y cancelación.
// =====================================================================

import { money, money4, importe, redondear2 } from './formato.js';
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
import { hoyISO } from './fechas.js';
const afOrden = crearOrdenTabla('id', 'desc');

let afCuentas = [];
let afCentros = [];          // etapas de producción (para repartir la depreciación al CIF)
let afTieneEtapas = false;   // false si falta correr sql/2026-10-14_depreciacion_al_prorrateo.sql
let afEtapasPorActivo = new Map();
let afActivoEditId = null;
let afAreas = [];            // áreas físicas (dónde está cada equipo)
let afNuevo = false;         // false si falta correr sql/2026-10-15_equipos_unificados.sql
let afPend = false;          // false si falta correr sql/2026-10-21_activo_fijo_en_compras.sql (activos que nacen de una compra)
let afSoloPend = false;      // la lista muestra solo los pendientes de completar
let afEditPendiente = false; // el activo que se edita nació de una compra y está pendiente de completar
let afApe = false;           // false si falta correr sql/2026-10-22f_activos_apertura_baja.sql (carga de equipos existentes y baja con póliza)
let afCatsDep = [];          // categorías fiscales (LISR); vacío si falta sql/2026-10-22_categorias_depreciacion_fiscal.sql
let afCatOrig = null;        // categoría/% que el activo ya traía al editarlo (se conserva su copia del año)
let afEditLigado = false;    // el activo que se edita viene de una compra: su costo y fecha no se editan aquí
const UNIDAD_KW = { kW: 1, HP: 0.746, W: 0.001 };
const TIPOS_CARGA = [['equipo', 'Equipo'], ['clima', 'Clima / HVAC'], ['iluminacion', 'Iluminación'], ['otro', 'Otro']];
const afIdCuenta = (cod) => afCuentas.find((c) => c.codigo === cod)?.id || '';
const esCuentaCif = (id) => String(afCuentas.find((c) => c.id === Number(id))?.codigo || '').startsWith('503.');

// Catálogos que usan el alta, la carga de equipos existentes y la lista (cuentas, etapas, áreas, categorías fiscales y qué migraciones están corridas).
async function afCargarCatalogos() {
    const { data } = await supabaseClient.from('cuentas_contables').select('id, codigo, nombre, tipo').eq('afectable', true).eq('activa', true).order('codigo');
    afCuentas = data || [];
    const [ce, et, nu, ar, pe, cd, ap] = await Promise.all([
        supabaseClient.from('centros_costo').select('id, codigo, nombre').eq('tipo', 'produccion').eq('activo', true),
        supabaseClient.from('activos_fijos_centros').select('id').limit(1),
        supabaseClient.from('activos_fijos').select('depreciable').limit(1),
        supabaseClient.from('areas_fisicas').select('id, codigo, nombre, rol').eq('activo', true).order('codigo'),
        supabaseClient.from('activos_fijos').select('pendiente').limit(1),
        cargarCategoriasDep(),
        supabaseClient.from('activos_fijos').select('acum_inicial').limit(1),
    ]);
    afApe = !ap.error;
    afCatsDep = cd || [];
    afCentros = ordenarCentrosProduccion(ce.data || []);
    afTieneEtapas = !et.error;
    afNuevo = !nu.error && !ar.error;
    afPend = !pe.error;
    afAreas = ar.data || [];
}

/** Abre la carga de un equipo existente (con nombre/categoría/modelo precargados) desde otra pantalla, p. ej. Alta de artículo. */
export const afAbrirAperturaDesde = (pre) => window.afAbrirApertura(pre);

export async function cargarModuloActivosFijos() {
    const cont = document.getElementById('contenedorActivosFijos');
    if (!cont) return;
    cont.innerHTML = '<p class="text-slate-500 text-sm">Cargando...</p>';
    try {
        await afCargarCatalogos();
    } catch (e) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error al cargar catálogos: ${e.message || e}</p>`;
        return;
    }

    const optsActivo = afCuentas.filter((c) => c.tipo === 'activo').map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const optsGasto = afCuentas.filter((c) => c.tipo === 'gasto' || (c.tipo === 'costo' && String(c.codigo).startsWith('503.'))).map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 id="afFormTitulo" class="text-md font-semibold text-emerald-400 mb-3">Nuevo activo fijo</h3>
        <p class="text-[11px] text-slate-500 mb-3">Aquí das de alta los equipos que <b>ya tienes</b>. Para uno que vas a <b>comprar</b>, créalo desde Requisición de compra (o en Productos como «Activo fijo»): al recibirlo, aparece aquí solo y lo completas.</p>
        <div id="afPendAviso" class="hidden mb-3 bg-amber-950/30 border border-amber-800/50 text-amber-200 rounded-lg p-2.5 text-xs"></div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div class="md:col-span-2"><label class="block text-xs text-slate-400 mb-1">Nombre</label>
            <input type="text" id="afNombre" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Categoría${afCatsDep.length ? ' fiscal <span class="text-slate-600">· LISR, define el % máximo</span>' : ''}</label>
            <input type="text" id="afCategoria" placeholder="Ej. Maquinaria" class="${afCatsDep.length ? 'hidden ' : ''}w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
            ${afCatsDep.length ? '<select id="afCatDep" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>' : ''}</div>
          <div><label class="block text-xs text-slate-400 mb-1">Fecha de alta / adquisición</label>
            <input type="date" id="afFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          ${afNuevo ? `
          <div><label class="block text-xs text-slate-400 mb-1">Área donde está <span class="text-rose-400">*</span></label>
            <select id="afArea" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${afAreas.map((a) => `<option value="${a.id}">${esc(a.codigo)} · ${esc(a.nombre)}</option>`).join('')}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Tipo de carga</label>
            <select id="afTipoCarga" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${TIPOS_CARGA.map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Potencia de placa (por unidad) <span class="text-rose-400">*</span> <span class="text-slate-600">· 0 si no usa electricidad</span></label>
            <div class="flex gap-1"><input type="number" step="any" min="0" id="afPot" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
              <select id="afPotU" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option>kW</option><option>HP</option><option>W</option></select></div></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cantidad de piezas iguales</label>
            <input type="number" step="1" min="1" id="afCant" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Factor de uso <span class="text-slate-600">· 1 = siempre a plena carga</span></label>
            <input type="number" step="0.01" min="0.01" max="1" id="afFu" value="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="md:col-span-3 border border-slate-800 rounded-lg p-3 bg-slate-900/40">
            <div class="text-xs text-slate-300 font-medium mb-1">¿Este equipo se deprecia? <span class="text-rose-400">*</span></div>
            <label class="flex items-start gap-2 text-xs text-slate-200 mb-1"><input type="radio" name="afDep" value="si" class="mt-0.5"> <span><b>Depreciable</b> — lo compraste y vale dinero que se va desgastando (maquinaria, equipo de cómputo). Pide costo y vida útil; cada mes genera su póliza de depreciación.</span></label>
            <label class="flex items-start gap-2 text-xs text-slate-200"><input type="radio" name="afDep" value="no" class="mt-0.5"> <span><b>No depreciable</b> — solo quieres controlarlo (dónde está y cuánta luz usa): equipo ya depreciado, de bajo valor o que no se activa. No genera depreciación.</span></label>
          </div>` : ''}
          ${afCatsDep.length ? '<div id="afCatDepInfo" class="md:col-span-3 hidden text-[11px] text-teal-200 bg-teal-950/30 border border-teal-900/60 rounded-lg px-3 py-2"></div>' : ''}
          <div id="afHistWrap" class="md:col-span-3 hidden">
            <label class="block text-xs text-slate-400 mb-1">Costo histórico <span class="text-slate-600">· opcional: lo que costó el equipo, solo para verlo en el listado (no genera póliza ni depreciación)</span></label>
            <input type="number" step="any" min="0" id="afCostoHist" class="w-full md:w-1/3 bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
          </div>
          <div id="afDepWrap" class="md:col-span-3 grid grid-cols-1 md:grid-cols-3 gap-3 ${afNuevo ? 'hidden' : ''}">
          <div><label class="block text-xs text-slate-400 mb-1">Costo de adquisición</label>
            <input type="number" step="any" min="0" id="afCosto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Valor residual</label>
            <input type="number" step="any" min="0" id="afResidual" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Vida útil (meses)</label>
            <input type="number" step="1" min="1" id="afVidaUtil" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de activo</label>
            <select id="afCtaActivo" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsActivo}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de gasto de depreciación</label>
            <select id="afCtaGasto" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsGasto}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Cuenta de depreciación acumulada</label>
            <select id="afCtaAcumulada" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Selecciona...</option>${optsActivo}</select></div>
          ${afApe ? `<div class="md:col-span-3 border border-slate-800 rounded-lg p-3 bg-slate-900/40">
            <label class="flex items-start gap-2 text-xs text-slate-200"><input type="checkbox" id="afUsado" class="mt-0.5 accent-emerald-500"> <span><b>Equipo usado</b> — se compró de segunda mano. Entra a su costo de compra (no hereda lo que depreció el vendedor) y se habilita capturar su <b>vida útil restante</b>, su <b>valor residual</b> y el <b>% fiscal</b> que le aplica tu contador.</span></label>
            <div id="afUsadoWrap" class="hidden grid grid-cols-1 md:grid-cols-3 gap-3 mt-3">
              <div><label class="block text-xs text-slate-400 mb-1">% fiscal anual aplicado <span class="text-slate-600">· editable</span></label>
                <input type="number" step="any" min="0" max="100" id="afPctFiscal" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
              <div class="md:col-span-2 text-[11px] text-slate-400 self-end pb-2" id="afMontoDep"></div>
            </div></div>` : ''}
          </div>
          <div id="afEtapasWrap" class="md:col-span-3 hidden border border-slate-800 rounded-lg p-3 bg-slate-900/40">
            <div class="text-xs text-slate-300 font-medium mb-1">¿En qué etapas se usa esta máquina?</div>
            <div class="text-[11px] text-slate-500 mb-2">Su depreciación mensual es costo indirecto de fabricación (CIF fijo): al hacer el prorrateo del mes se reparte en <b>partes iguales</b> entre las etapas que marques y de ahí a las órdenes de producción. Si no marcas ninguna, no se prorratea.</div>
            ${afTieneEtapas
                ? `<div class="flex flex-wrap gap-4">${afCentros.map((c) => `<label class="flex items-center gap-1.5 text-xs text-slate-200"><input type="checkbox" class="afEtapaChk accent-emerald-500" value="${c.id}"> ${esc(c.codigo)} · ${esc(c.nombre)}</label>`).join('') || '<span class="text-xs text-amber-400">No hay etapas de producción: créalas en Centros de costo.</span>'}</div>`
                : '<div class="text-xs text-amber-400">Falta correr <span class="font-mono">sql/2026-10-14_depreciacion_al_prorrateo.sql</span> en Supabase para poder asignar etapas.</div>'}
          </div>
          <div class="md:col-span-3"><label class="block text-xs text-slate-400 mb-1">Notas</label>
            <input type="text" id="afNotas" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="flex gap-2">
          <button type="button" id="afGuardar" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Guardar activo</button>
          <button type="button" id="afCancelarEdicion" class="hidden bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 px-4 rounded-lg text-sm">Cancelar</button>
        </div>
        <p id="afMsg" class="text-xs mt-2 min-h-[1rem]"></p>
      </div>

      <div>
        <div class="flex flex-wrap items-center gap-2 mb-2">
          <h3 class="text-md font-semibold text-slate-300">Catálogo de activos fijos</h3>
          <button type="button" onclick="window.afAbrirApertura()" class="ml-auto text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg" title="Para equipos que ya tenías antes de empezar en el ERP: registra su depreciación acumulada y genera la póliza de apertura">Cargar equipo existente</button>
        </div>
        <div id="afLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <h3 class="text-md font-semibold text-emerald-400 mb-3">Depreciación del mes</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div><label class="block text-xs text-slate-400 mb-1">Año</label>
            <input type="number" id="afAnio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Mes</label>
            <input type="number" min="1" max="12" id="afMes" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="flex items-end"><button type="button" id="afCalcular" class="w-full bg-slate-800 hover:bg-slate-700 text-emerald-300 font-medium py-2 rounded-lg text-sm">Calcular</button></div>
        </div>
        <div id="afPreview" class="text-sm text-slate-500">Elige año y mes, y pulsa "Calcular".</div>
      </div>

      <div>
        <h3 class="text-md font-semibold text-slate-300 mb-2">Historial de depreciación aplicada</h3>
        <div id="afHistorial" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
      </div>
    </div>`;

    const hoy = new Date();
    document.getElementById('afFecha').value = hoyISO();
    document.getElementById('afAnio').value = hoy.getFullYear();
    document.getElementById('afMes').value = hoy.getMonth() + 1;

    document.getElementById('afVidaUtil').addEventListener('input', (e) => { delete e.target.dataset.auto; });
    document.getElementById('afGuardar').onclick = afGuardarActivo;
    document.getElementById('afCancelarEdicion').onclick = afResetForm;
    document.getElementById('afCalcular').onclick = afCalcularDepreciacion;
    document.getElementById('afCtaGasto').addEventListener('change', afMostrarEtapas);
    if (afCatsDep.length) {
        afPintarCatDep(null);
        document.getElementById('afCatDep').addEventListener('change', () => afAlElegirCategoria(true));
        document.getElementById('afFecha').addEventListener('change', () => afPintarCatDep(document.getElementById('afCatDep').value || null));
        document.getElementById('afCosto').addEventListener('input', () => afAlElegirCategoria(false));
        // Cambiar el área (producción / no producción) cambia el gasto de depreciación de la categoría elegida
        document.getElementById('afArea')?.addEventListener('change', () => {
            const f = afCatsDep.find((c) => c.id === Number(document.getElementById('afCatDep').value));
            if (f) { afAplicarCuentasCategoria(f); afAlElegirCategoria(false); }
        });
    }
    document.querySelectorAll('input[name="afDep"]').forEach((r) => r.addEventListener('change', afMostrarDep));
    ['afUsado', 'afCosto', 'afResidual', 'afVidaUtil', 'afCatDep'].forEach((id) => {
        const el = document.getElementById(id);
        if (el) { el.addEventListener('input', afSincUsado); el.addEventListener('change', afSincUsado); }
    });

    await afRenderLista();
    await afRenderHistorial();
    montarGuia(cont, 'activos-fijos');
}

// Categorías que rigen en el ejercicio de la fecha de adquisición (conserva la elegida aunque ya no rija).
function afPintarCatDep(sel) {
    const el = document.getElementById('afCatDep');
    if (!el) return;
    const anio = Number(String(document.getElementById('afFecha').value || '').slice(0, 4)) || new Date().getFullYear();
    el.innerHTML = opcionesCategoriaDep(afCatsDep, anio, sel);
    el.value = sel ? String(sel) : '';
    afAlElegirCategoria(false);
}

// Muestra el fundamento, tope y parte no deducible; con `precargar` sugiere la vida útil (editable) y el nombre de la categoría.
function afAlElegirCategoria(precargar) {
    const el = document.getElementById('afCatDep');
    const info = document.getElementById('afCatDepInfo');
    if (!el || !info) return;
    const fila = afCatsDep.find((c) => c.id === Number(el.value));
    if (!fila) { info.classList.add('hidden'); if (precargar) document.getElementById('afCategoria').value = ''; return; }
    if (precargar) {
        document.getElementById('afCategoria').value = fila.categoria;
        const vida = document.getElementById('afVidaUtil');
        if (vida && (!vida.value || vida.dataset.auto === '1')) { vida.value = vidaMesesDePct(fila.pct_anual); vida.dataset.auto = '1'; }
    }
    const costo = parseFloat(document.getElementById('afCosto').value) || 0;
    const noDed = fila.tope_deducible && costo > fila.tope_deducible ? ` · <b class="text-amber-300">parte no deducible para ISR: ${money(costo - fila.tope_deducible)}</b>` : '';
    if (precargar) afAplicarCuentasCategoria(fila);
    const nom = (id) => afCuentas.find((c) => c.id === Number(id));
    const ctaTxt = (id) => { const c = nom(id); return c ? `${c.codigo}` : '—'; };
    const rolProd = afAreas.find((a) => a.id === Number(document.getElementById('afArea')?.value))?.rol !== 'no_produccion';
    const cuentasInfo = fila.cuenta_activo_id
        ? `<br>📒 <b>Contabilidad:</b> compra → Cargo ${ctaTxt(fila.cuenta_activo_id)} · cada mes → Cargo ${ctaTxt(rolProd ? fila.cuenta_gasto_cif_id : fila.cuenta_gasto_admin_id)} (${rolProd ? 'área de producción, se prorratea al costo' : 'área sin producción, gasto'}) / Abono ${ctaTxt(fila.cuenta_dep_acum_id)}`
        : '<br><span class="text-amber-300">Esta categoría aún no tiene cuentas asignadas: elígelas abajo o captúralas en Configuración → Tablas → SAT · Depreciación fiscal.</span>';
    info.innerHTML = `${textoCategoriaDep(fila)}${noDed}${cuentasInfo}<br><span class="text-slate-500">El % es un tope: la vida útil de abajo (sugerida de ese %) es la que usa la depreciación contable y puedes ajustarla.</span>`;
    info.classList.remove('hidden');
}

// Cuentas del equipo según su categoría: activo, depreciación acumulada y gasto (CIF si el área es de producción, si no administración).
function afAplicarCuentasCategoria(fila) {
    if (!fila) return;
    const pon = (id, val) => { const el = document.getElementById(id); if (el && val) el.value = String(val); };
    const area = afAreas.find((a) => a.id === Number(document.getElementById('afArea')?.value));
    const prod = !area || area.rol !== 'no_produccion';
    pon('afCtaActivo', fila.cuenta_activo_id);
    pon('afCtaAcumulada', fila.cuenta_dep_acum_id);
    pon('afCtaGasto', prod ? fila.cuenta_gasto_cif_id : fila.cuenta_gasto_admin_id);
    afMostrarEtapas();
}

// Equipo usado: se habilitan % fiscal editable y vida restante; muestra el monto a depreciar (costo − residual).
function afSincUsado() {
    const chk = document.getElementById('afUsado');
    if (!chk) return;
    document.getElementById('afUsadoWrap').classList.toggle('hidden', !chk.checked);
    const lbl = document.getElementById('afVidaUtil')?.previousElementSibling;
    if (lbl) lbl.textContent = chk.checked ? 'Vida útil restante estimada (meses)' : 'Vida útil (meses)';
    const pct = document.getElementById('afPctFiscal');
    if (chk.checked && pct && !pct.value) pct.value = afCatsDep.find((c) => c.id === Number(document.getElementById('afCatDep')?.value))?.pct_anual ?? '';
    const costo = parseFloat(document.getElementById('afCosto').value) || 0, res = parseFloat(document.getElementById('afResidual').value) || 0;
    const vida = parseInt(document.getElementById('afVidaUtil').value) || 0, base = Math.max(0, costo - res);
    document.getElementById('afMontoDep').innerHTML = chk.checked && costo
        ? `Monto a depreciar: <b class="text-slate-200">${money(base)}</b> (costo ${money(costo)} − residual ${money(res)})${vida ? ` · ${money(base / vida)} al mes` : ''}` : '';
}

const afEsDep = () => !afNuevo || document.querySelector('input[name="afDep"]:checked')?.value === 'si';

function afMostrarEtapas() {
    const wrap = document.getElementById('afEtapasWrap');
    if (wrap) wrap.classList.toggle('hidden', !afEsDep() || !esCuentaCif(document.getElementById('afCtaGasto').value));
}

// Muestra el bloque de costo/vida/cuentas solo si el equipo es depreciable y precarga las cuentas de siempre
function afMostrarDep() {
    if (!afNuevo) return;
    const dep = afEsDep();
    document.getElementById('afDepWrap').classList.toggle('hidden', !dep);
    // "Costo histórico" solo para el que se marca No depreciable (y no viene de una compra: ese ya trae su costo real).
    document.getElementById('afHistWrap')?.classList.toggle('hidden', dep || afEditLigado || document.querySelector('input[name="afDep"]:checked')?.value !== 'no');
    if (dep) {
        const pon = (id, cod) => { const el = document.getElementById(id); if (el && !el.value) el.value = afIdCuenta(cod); };
        pon('afCtaActivo', '152.01'); pon('afCtaGasto', '503.04'); pon('afCtaAcumulada', '153.01');
    }
    afMostrarEtapas();
}

function afResetForm() {
    afActivoEditId = null;
    afEditPendiente = false; afEditLigado = false;
    document.getElementById('afPendAviso')?.classList.add('hidden');
    ['afCosto', 'afFecha'].forEach((id) => { const el = document.getElementById(id); if (el) { el.readOnly = false; el.classList.remove('opacity-60'); } });
    document.getElementById('afFormTitulo').textContent = 'Nuevo activo fijo';
    document.getElementById('afNombre').value = '';
    document.getElementById('afCategoria').value = '';
    afCatOrig = null;
    document.getElementById('afFecha').value = hoyISO();
    document.getElementById('afCosto').value = '';
    const hist0 = document.getElementById('afCostoHist'); if (hist0) hist0.value = '';
    document.getElementById('afResidual').value = '0';
    document.getElementById('afVidaUtil').value = '';
    delete document.getElementById('afVidaUtil').dataset.auto;
    document.getElementById('afCtaActivo').value = '';
    document.getElementById('afCtaGasto').value = '';
    document.getElementById('afCtaAcumulada').value = '';
    document.getElementById('afNotas').value = '';
    const us0 = document.getElementById('afUsado'); if (us0) { us0.checked = false; document.getElementById('afPctFiscal').value = ''; afSincUsado(); }
    document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = false; });
    if (afNuevo) {
        document.getElementById('afArea').value = '';
        document.getElementById('afTipoCarga').value = 'equipo';
        document.getElementById('afPot').value = '';
        document.getElementById('afPotU').value = 'kW';
        document.getElementById('afCant').value = '1';
        document.getElementById('afFu').value = '1';
        document.querySelectorAll('input[name="afDep"]').forEach((r) => { r.checked = false; });
    }
    afMostrarDep();
    afMostrarEtapas();
    if (afCatsDep.length) afPintarCatDep(null);
    document.getElementById('afGuardar').textContent = 'Guardar activo';
    document.getElementById('afCancelarEdicion').classList.add('hidden');
}

async function afGuardarActivo() {
    const msg = document.getElementById('afMsg');
    const nombre = document.getElementById('afNombre').value.trim();
    const costo = parseFloat(document.getElementById('afCosto').value) || 0;
    const vidaUtil = parseInt(document.getElementById('afVidaUtil').value) || 0;
    const dep = afEsDep();
    const falla = (t) => { msg.textContent = t; msg.className = 'text-xs mt-2 text-rose-400'; };
    if (!nombre) return falla('El nombre es obligatorio.');
    if (afNuevo) {
        if (!document.getElementById('afArea').value) return falla('Elige el área donde está el equipo.');
        if (document.getElementById('afPot').value === '' || !(parseFloat(document.getElementById('afPot').value) >= 0)) return falla('Captura la potencia de placa (pon 0 si no usa electricidad).');
        if (!(parseInt(document.getElementById('afCant').value) >= 1)) return falla('La cantidad debe ser al menos 1.');
        const fu = parseFloat(document.getElementById('afFu').value);
        if (!(fu > 0 && fu <= 1)) return falla('El factor de uso debe estar entre 0.01 y 1.');
        if (!document.querySelector('input[name="afDep"]:checked')) return falla('Indica si el equipo es Depreciable o No depreciable.');
    }
    if (dep) {
        if (costo <= 0) return falla('El costo de adquisición debe ser mayor a 0.');
        if (vidaUtil <= 0) return falla('La vida útil debe ser mayor a 0 meses.');
        if (afCatsDep.length && !document.getElementById('afCatDep')?.value) return falla('Elige la categoría fiscal del equipo: de ella salen su % máximo y sus cuentas.');
        if (afApe && document.getElementById('afUsado')?.checked) {
            const pf = parseFloat(document.getElementById('afPctFiscal').value);
            if (!(pf > 0 && pf <= 100)) return falla('Equipo usado: captura el % fiscal anual que le aplica (entre 0 y 100).');
            if ((parseFloat(document.getElementById('afResidual').value) || 0) >= costo) return falla('El valor residual debe ser menor al costo: no habría monto a depreciar.');
        }
        if (afNuevo && !(document.getElementById('afCtaActivo').value && document.getElementById('afCtaGasto').value && document.getElementById('afCtaAcumulada').value)) {
            return falla('Un equipo depreciable necesita sus tres cuentas (activo, gasto de depreciación y depreciación acumulada).');
        }
    }

    const payload = {
        nombre,
        categoria: document.getElementById('afCategoria').value.trim() || null,
        fecha_adquisicion: document.getElementById('afFecha').value || hoyISO(),
        // Un activo que viene de una compra conserva su costo aunque no se deprecie (ya está en la cuenta de activo).
        // No depreciable sin compra: el costo histórico es opcional (solo para el listado).
        costo_adquisicion: (dep || afEditLigado) ? costo : (parseFloat(document.getElementById('afCostoHist')?.value) > 0 ? parseFloat(document.getElementById('afCostoHist').value) : null),
        valor_residual: dep ? (parseFloat(document.getElementById('afResidual').value) || 0) : 0,
        vida_util_meses: dep ? vidaUtil : null,
        cuenta_activo_id: dep && document.getElementById('afCtaActivo').value ? parseInt(document.getElementById('afCtaActivo').value) : null,
        cuenta_depreciacion_gasto_id: dep && document.getElementById('afCtaGasto').value ? parseInt(document.getElementById('afCtaGasto').value) : null,
        cuenta_depreciacion_acumulada_id: dep && document.getElementById('afCtaAcumulada').value ? parseInt(document.getElementById('afCtaAcumulada').value) : null,
        notas: document.getElementById('afNotas').value.trim() || null,
    };
    if (afCatsDep.length) {
        const catId = Number(document.getElementById('afCatDep')?.value) || null;
        if (catId && afCatOrig && afCatOrig.id === catId) {
            // misma categoría que ya traía: se conserva la copia del % y tope de su ejercicio
            Object.assign(payload, { categoria_depreciacion_id: catId, pct_fiscal: afCatOrig.pct, tope_fiscal: afCatOrig.tope, ejercicio_fiscal: afCatOrig.ej });
        } else if (catId) {
            const f = afCatsDep.find((c) => c.id === catId);
            Object.assign(payload, { categoria_depreciacion_id: catId, pct_fiscal: f.pct_anual, tope_fiscal: f.tope_deducible,
                ejercicio_fiscal: Number(String(payload.fecha_adquisicion).slice(0, 4)) || new Date().getFullYear() });
        } else {
            Object.assign(payload, { categoria_depreciacion_id: null, pct_fiscal: null, tope_fiscal: null, ejercicio_fiscal: null });
        }
    }
    if (afApe) {
        const usado = !!document.getElementById('afUsado')?.checked;
        payload.usado = dep && usado;
        if (payload.usado) payload.pct_fiscal = parseFloat(document.getElementById('afPctFiscal').value);   // editable en usados
    }
    if (afPend && afActivoEditId && afEditPendiente) payload.pendiente = false;   // ya se completó: entra a la depreciación
    if (afNuevo) {
        Object.assign(payload, {
            depreciable: dep,
            area_id: parseInt(document.getElementById('afArea').value),
            tipo_carga: document.getElementById('afTipoCarga').value,
            potencia_kw: Math.round(parseFloat(document.getElementById('afPot').value) * (UNIDAD_KW[document.getElementById('afPotU').value] || 1) * 1000) / 1000,
            cantidad: parseInt(document.getElementById('afCant').value),
            factor_uso: parseFloat(document.getElementById('afFu').value),
        });
    }

    // Alta manual: si ya hay un artículo «Activo fijo» con ese nombre, probablemente es el mismo equipo que se va a comprar.
    if (!afActivoEditId) {
        try {
            const { data: dup } = await supabaseClient.from('productos').select('nombre').eq('tipo', 'activo_fijo').ilike('nombre', nombre).limit(1);
            if (dup && dup.length && !confirm(`Ya existe el artículo «${dup[0].nombre}» (Activo fijo) en Productos.\n\nSi es un equipo que vas a comprar, no lo captures aquí: pídelo en una requisición y, al recibirlo, aparecerá en Activos fijos solo.\n\n¿Guardarlo de todos modos como activo que ya tienes?`)) return;
        } catch (_) { /* sin aviso si la consulta falla */ }
    }

    try {
        let error, activoId = afActivoEditId;
        if (afActivoEditId) {
            ({ error } = await supabaseClient.from('activos_fijos').update(payload).eq('id', afActivoEditId));
        } else {
            const ins = await supabaseClient.from('activos_fijos').insert([payload]).select('id').single();
            error = ins.error; activoId = ins.data?.id;
        }
        if (error) throw error;
        // etapas donde se usa (solo si la cuenta de gasto es 503.xx y la migración está corrida)
        let sinEtapas = false;
        if (afTieneEtapas && activoId) {
            const marcadas = dep && esCuentaCif(payload.cuenta_depreciacion_gasto_id)
                ? [...document.querySelectorAll('.afEtapaChk:checked')].map((c) => Number(c.value)) : [];
            const del = await supabaseClient.from('activos_fijos_centros').delete().eq('activo_id', activoId);
            if (del.error) throw del.error;
            if (marcadas.length) {
                const ins2 = await supabaseClient.from('activos_fijos_centros').insert(marcadas.map((c) => ({ activo_id: activoId, centro_costo_id: c })));
                if (ins2.error) throw ins2.error;
            }
            sinEtapas = dep && esCuentaCif(payload.cuenta_depreciacion_gasto_id) && !marcadas.length;
        }
        const completado = !!(afActivoEditId && afEditPendiente);
        msg.textContent = (completado ? 'Activo completado: ya entra a la depreciación del mes.' : (afActivoEditId ? 'Activo actualizado.' : 'Activo guardado.'))
            + (sinEtapas ? ' ⚠ Sin etapas: su depreciación NO se repartirá al prorrateo hasta que las marques.' : '');
        msg.className = 'text-xs mt-2 ' + (sinEtapas ? 'text-amber-400' : 'text-emerald-400');
        afResetForm();
        await afRenderLista();
    } catch (err) {
        msg.textContent = 'No se pudo guardar: ' + (err.message || err);
        msg.className = 'text-xs mt-2 text-rose-400';
    }
}

async function afRenderLista() {
    const cont = document.getElementById('afLista');
    try {
        const { data, error } = await supabaseClient
            .from('activos_fijos')
            .select('id, nombre, categoria, fecha_adquisicion, costo_adquisicion, valor_residual, vida_util_meses, activo, fecha_baja, cuenta_depreciacion_gasto_id' + (afNuevo ? ', depreciable, area_id, potencia_kw, cantidad, factor_uso' : '') + (afCatsDep.length ? ', pct_fiscal' : '') + (afApe ? ', acum_inicial, poliza_apertura_id, poliza_baja_id' : '') + (afPend ? ', pendiente, documento_id' : ''))
            .order('id', { ascending: false });
        if (error) throw error;
        afEtapasPorActivo = new Map();
        if (afTieneEtapas) {
            const { data: et } = await supabaseClient.from('activos_fijos_centros').select('activo_id, centro_costo_id');
            (et || []).forEach((r) => {
                const cod = afCentros.find((c) => c.id === r.centro_costo_id)?.codigo || ('#' + r.centro_costo_id);
                afEtapasPorActivo.set(r.activo_id, [...(afEtapasPorActivo.get(r.activo_id) || []), cod]);
            });
        }
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin activos fijos registrados.</p>'; return; }
        // Depreciación acumulada = la inicial de la carga + lo que el ERP ha depreciado
        const acumPorActivo = new Map();
        if (afApe) {
            const { data: dp } = await supabaseClient.from('activos_fijos_depreciaciones').select('activo_id, monto');
            (dp || []).forEach((r) => acumPorActivo.set(r.activo_id, (acumPorActivo.get(r.activo_id) || 0) + Number(r.monto || 0)));
        }
        const acumDe = (a) => Math.round((Number(a.acum_inicial || 0) + (acumPorActivo.get(a.id) || 0)) * 100) / 100;
        const nPend = data.filter((a) => a.pendiente).length;
        if (!nPend) afSoloPend = false;
        const avisoPend = nPend ? `
        <div class="mb-2 flex flex-wrap items-center gap-3 bg-amber-950/30 border border-amber-800/50 text-amber-200 rounded-lg p-2.5 text-xs">
          <span>⏳ <b>${nPend}</b> activo(s) fijo(s) llegaron de una compra y están <b>pendientes de completar</b> (área, si se deprecia, vida útil y etapas). Mientras tanto no se deprecian.</span>
          <button type="button" onclick="window.afFiltrarPend()" class="text-[11px] bg-amber-900/60 hover:bg-amber-800 text-amber-100 border border-amber-700 px-2 py-1 rounded">${afSoloPend ? 'Ver todos' : 'Ver solo pendientes'}</button>
        </div>` : '';
        const visibles = afSoloPend ? data.filter((a) => a.pendiente) : data;

        aplicarOrden(afOrden, data, (a, campo) => {
            switch (campo) {
                case 'nombre': return (a.nombre || '').toLowerCase();
                case 'fecha': return a.fecha_adquisicion || '';
                case 'costo': return Number(a.costo_adquisicion || 0);
                default: return a.id;
            }
        });

        cont.innerHTML = `${avisoPend}
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Acción</th>${thOrden(afOrden, 'nombre', 'Nombre')}<th class="p-2">Categoría</th>
              ${thOrden(afOrden, 'fecha', 'Adquisición')}${thOrden(afOrden, 'costo', 'Costo', 'text-right justify-end')}
              ${afNuevo ? '<th class="p-2">Área</th><th class="p-2 text-right">kW efect.</th><th class="p-2">Depreciación</th>' : ''}
              ${afApe ? '<th class="p-2 text-right">Dep. acumulada</th><th class="p-2 text-right">Valor en libros</th>' : ''}<th class="p-2 text-right">Vida útil</th><th class="p-2">Etapas (CIF)</th><th class="p-2">Estatus</th>
            </tr></thead>
            <tbody>
              ${visibles.map((a) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 whitespace-nowrap">
                    ${a.pendiente
                        ? `<button type="button" onclick="window.afEditar(${a.id})" class="text-[11px] bg-amber-700 hover:bg-amber-600 text-white border border-amber-600 px-2 py-1 rounded font-semibold">Completar</button>`
                        : `<button type="button" onclick="window.afEditar(${a.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-2 py-1 rounded">Editar</button>`}
                    ${a.activo ? `<button type="button" onclick="window.afDarBaja(${a.id})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded ml-1">Dar de baja</button>` : ''}
                  </td>
                  <td class="p-2 text-slate-100">${esc(a.nombre)}${a.documento_id ? `<span class="block text-[10px] text-slate-500">Compra · ${linkDoc(a.documento_id, 'recepción #' + a.documento_id, 'font-mono text-sky-300')}</span>` : ''}</td>
                  <td class="p-2 text-slate-400">${esc(a.categoria || '—')}${a.pct_fiscal != null ? `<span class="block text-[10px] text-slate-500">LISR máx. ${Number(a.pct_fiscal)}%</span>` : ''}</td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${a.fecha_adquisicion || ''}</td>
                  <td class="p-2 text-right font-mono">${a.costo_adquisicion == null ? '—' : money(a.costo_adquisicion)}</td>
                  ${afNuevo ? `
                  <td class="p-2 whitespace-nowrap">${a.area_id ? esc(afAreas.find((x) => x.id === a.area_id)?.codigo || '#' + a.area_id) : (a.pendiente ? '<span class="text-slate-600">—</span>' : '<span class="text-amber-400" title="Sin área no cuenta para la luz">⚠ sin área</span>')}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${a.potencia_kw == null ? (a.pendiente ? '<span class="text-slate-600">—</span>' : '<span class="text-amber-400" title="Sin potencia no cuenta para la luz">⚠</span>') : (Number(a.potencia_kw) * Number(a.cantidad || 1) * Number(a.factor_uso || 1)).toLocaleString('es-MX', { maximumFractionDigits: 3 })}</td>
                  <td class="p-2">${a.pendiente ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-amber-300 bg-amber-950/40">Por definir</span>' : a.depreciable ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-sky-300 bg-sky-950/40">Depreciable</span>' : '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-slate-300 bg-slate-800">No depreciable</span>'}</td>` : ''}
                  ${afApe ? `<td class="p-2 text-right font-mono text-slate-400">${a.costo_adquisicion == null || a.pendiente ? '—' : money(acumDe(a))}</td><td class="p-2 text-right font-mono ${a.costo_adquisicion != null && !a.pendiente && Number(a.costo_adquisicion) - acumDe(a) <= 0 ? 'text-emerald-400' : 'text-slate-300'}">${a.costo_adquisicion == null || a.pendiente ? '—' : money(Number(a.costo_adquisicion) - acumDe(a))}</td>` : ''}
                  <td class="p-2 text-right font-mono text-slate-400">${a.vida_util_meses ?? '—'}</td>
                  <td class="p-2 text-xs">${a.pendiente ? '<span class="text-slate-600">—</span>' : (afNuevo && !a.depreciable) ? '<span class="text-slate-600">no aplica</span>' : esCuentaCif(a.cuenta_depreciacion_gasto_id)
                      ? ((afEtapasPorActivo.get(a.id) || []).length ? `<span class="text-emerald-400">${esc(afEtapasPorActivo.get(a.id).join(', '))}</span>` : (afTieneEtapas ? '<span class="text-amber-400" title="Sin etapas no se prorratea">⚠ sin etapas</span>' : '<span class="text-slate-500">—</span>'))
                      : '<span class="text-slate-600">no aplica</span>'}</td>
                  <td class="p-2">${a.pendiente ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-amber-300 bg-amber-950/40">⏳ pendiente de completar</span>' : a.activo ? '<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-emerald-300 bg-emerald-950/40">activo</span>' : `<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold text-slate-400 bg-slate-800">de baja${a.fecha_baja ? ' ' + a.fecha_baja : ''}</span>`}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, afOrden, afRenderLista);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.afEditar = async (id) => {
    const { data: a, error } = await supabaseClient.from('activos_fijos').select('*').eq('id', id).single();
    if (error || !a) { alert('No se pudo cargar el activo: ' + (error?.message || 'no encontrado')); return; }
    afActivoEditId = id;
    afEditPendiente = !!a.pendiente;
    afEditLigado = !!a.documento_id;
    document.getElementById('afFormTitulo').textContent = a.pendiente ? 'Completar activo fijo (viene de una compra)' : 'Editar activo fijo';
    const avisoP = document.getElementById('afPendAviso');
    if (avisoP) {
        if (a.documento_id) {
            avisoP.innerHTML = `Este equipo llegó de la compra · recepción ${linkDoc(a.documento_id, '#' + a.documento_id, 'font-mono text-sky-300')}. Su <b>costo</b> y su <b>fecha</b> vienen de esa compra y no se editan aquí.`
                + (a.pendiente ? ' <b>Falta:</b> área donde está, potencia, si se deprecia y, si se deprecia, su vida útil, cuentas y etapas.' : '');
            avisoP.classList.remove('hidden');
        } else avisoP.classList.add('hidden');
    }
    ['afCosto', 'afFecha'].forEach((cid) => { const el = document.getElementById(cid); if (el) { el.readOnly = afEditLigado; el.classList.toggle('opacity-60', afEditLigado); } });
    document.getElementById('afNombre').value = a.nombre || '';
    document.getElementById('afCategoria').value = a.categoria || '';
    document.getElementById('afFecha').value = a.fecha_adquisicion || '';
    document.getElementById('afCosto').value = a.costo_adquisicion || '';
    document.getElementById('afResidual').value = a.valor_residual || 0;
    document.getElementById('afVidaUtil').value = a.vida_util_meses || '';
    document.getElementById('afCtaActivo').value = a.cuenta_activo_id || '';
    document.getElementById('afCtaGasto').value = a.cuenta_depreciacion_gasto_id || '';
    document.getElementById('afCtaAcumulada').value = a.cuenta_depreciacion_acumulada_id || '';
    document.getElementById('afNotas').value = a.notas || '';
    const us1 = document.getElementById('afUsado');
    if (us1) { us1.checked = !!a.usado; document.getElementById('afPctFiscal').value = a.usado && a.pct_fiscal != null ? a.pct_fiscal : ''; }
    afCatOrig = a.categoria_depreciacion_id ? { id: a.categoria_depreciacion_id, pct: a.pct_fiscal, tope: a.tope_fiscal, ej: a.ejercicio_fiscal } : null;
    if (afCatsDep.length) afPintarCatDep(a.categoria_depreciacion_id || null);
    if (afCatsDep.length && a.pendiente && afCatOrig && !a.vida_util_meses && a.pct_fiscal) {
        const vida = document.getElementById('afVidaUtil');
        vida.value = vidaMesesDePct(a.pct_fiscal); vida.dataset.auto = '1';   // sugerida de su categoría; editable
    }
    if (afNuevo) {
        document.getElementById('afArea').value = a.area_id || '';
        document.getElementById('afTipoCarga').value = a.tipo_carga || 'equipo';
        document.getElementById('afPot').value = a.potencia_kw ?? '';
        document.getElementById('afPotU').value = 'kW';
        document.getElementById('afCant').value = a.cantidad || 1;
        document.getElementById('afFu').value = a.factor_uso ?? 1;
        // Pendiente de completar: el usuario decide explícitamente si se deprecia (no se asume).
        document.querySelectorAll('input[name="afDep"]').forEach((r) => { r.checked = !a.pendiente && r.value === (a.depreciable ? 'si' : 'no'); });
        document.getElementById('afDepWrap').classList.toggle('hidden', !!a.pendiente || !a.depreciable);
        const hist = document.getElementById('afCostoHist');
        if (hist) hist.value = (!a.depreciable && !a.documento_id && a.costo_adquisicion != null) ? a.costo_adquisicion : '';
        afMostrarDep();
    }
    document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = false; });
    if (afTieneEtapas) {
        const { data: et } = await supabaseClient.from('activos_fijos_centros').select('centro_costo_id').eq('activo_id', id);
        const ids = new Set((et || []).map((r) => r.centro_costo_id));
        document.querySelectorAll('.afEtapaChk').forEach((c) => { c.checked = ids.has(Number(c.value)); });
    }
    afMostrarEtapas();
    afSincUsado();
    document.getElementById('afGuardar').textContent = a.pendiente ? 'Completar y guardar activo' : 'Actualizar activo';
    document.getElementById('afCancelarEdicion').classList.remove('hidden');
    document.getElementById('afNombre').scrollIntoView({ behavior: 'smooth', block: 'start' });
};

window.afFiltrarPend = async () => { afSoloPend = !afSoloPend; await afRenderLista(); };

window.afDarBaja = async (id) => {
    const { data: a, error } = await supabaseClient.from('activos_fijos').select('*').eq('id', id).single();
    if (error || !a) { alert('No se pudo cargar el activo: ' + (error?.message || 'no encontrado')); return; }
    const { data: deps } = await supabaseClient.from('activos_fijos_depreciaciones').select('monto').eq('activo_id', id);
    const acum = Math.round((Number(a.acum_inicial || 0) + (deps || []).reduce((t, d) => t + Number(d.monto || 0), 0)) * 100) / 100;
    const costo = Number(a.costo_adquisicion || 0);
    const vl = Math.round((costo - acum) * 100) / 100;
    const cta = (cid) => { const c = afCuentas.find((x) => x.id === Number(cid)); return c ? `${c.codigo} · ${c.nombre}` : '—'; };
    const perd = afCuentas.find((c) => c.codigo === '601.99');

    const idv = window.idSubventana('afBajaModal');
    const ov = document.createElement('div');
    ov.id = idv;
    ov.className = 'fixed inset-0 bg-slate-950/40 flex items-start justify-center p-3 overflow-y-auto';
    ov.style.zIndex = typeof window.zSubventanaSiguiente === 'function' ? window.zSubventanaSiguiente() : 80;
    const fila = (c, cargo, abono) => `<tr class="border-b border-slate-900"><td class="p-1.5 font-mono text-[11px]">${esc(c)}</td><td class="p-1.5 text-right font-mono">${cargo ? money(cargo) : ''}</td><td class="p-1.5 text-right font-mono">${abono ? money(abono) : ''}</td></tr>`;
    ov.innerHTML = `
      <div class="w-full max-w-2xl my-6 bg-slate-950 border border-slate-800 rounded-xl p-4 shadow-2xl">
        <div class="flex items-center justify-between gap-3 mb-2"><h3 class="text-base font-semibold text-rose-300">Dar de baja · ${esc(a.nombre)}</h3>
          <button type="button" data-x class="text-slate-400 hover:text-slate-100 text-xl leading-none">&times;</button></div>
        <div class="grid grid-cols-2 gap-3 mb-3">
          <div><label class="block text-[11px] text-slate-400 mb-1">Fecha de baja</label><input type="date" data-f="fecha" value="${hoyISO()}" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Motivo <span class="text-rose-400">*</span></label><input type="text" data-f="motivo" placeholder="Descompuesto sin reparación, obsolescencia, siniestro…" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
        </div>
        <div class="text-xs bg-slate-900/60 border border-slate-800 rounded-lg p-2.5 mb-3 grid grid-cols-3 gap-2">
          <div><div class="text-slate-500">Costo</div><b>${money(costo)}</b></div><div><div class="text-slate-500">Dep. acumulada</div><b>${money(acum)}</b></div><div><div class="text-slate-500">Valor en libros</div><b>${money(vl)}</b></div>
        </div>
        ${costo > 0 && a.cuenta_activo_id ? `
        <p class="text-[11px] font-semibold text-sky-300 mb-1">Póliza BAJ · Diario (vista previa)</p>
        <table class="w-full text-xs text-slate-300 mb-1"><thead class="text-slate-500"><tr><th class="p-1.5 text-left">Cuenta</th><th class="p-1.5 text-right">Cargo</th><th class="p-1.5 text-right">Abono</th></tr></thead><tbody>
          ${acum > 0 ? fila(cta(a.cuenta_depreciacion_acumulada_id), acum, 0) : ''}${vl > 0 ? fila(perd ? `${perd.codigo} · ${perd.nombre} (pérdida por baja)` : '601.99 (pérdida por baja)', vl, 0) : ''}${fila(cta(a.cuenta_activo_id), 0, costo)}
        </tbody></table>
        <p class="text-[10px] text-slate-500 mb-2">Baja sin venta. Si vas a vender el equipo, registra la venta con su IVA en Salidas/Ventas y consulta a tu contador cómo dar de baja el activo.</p>` : '<p class="text-[11px] text-slate-500 mb-2">Este equipo no tiene costo ni cuenta de activo: solo se marcará como dado de baja, sin póliza.</p>'}
        <p data-f="msg" class="text-xs min-h-[1rem] mb-2"></p>
        <div class="flex gap-2"><button type="button" data-x class="bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 px-4 rounded-lg text-sm">Cancelar</button>
          <button type="button" data-f="ok" class="flex-1 bg-rose-700 hover:bg-rose-600 text-white font-semibold py-2.5 rounded-lg text-sm">Dar de baja${costo > 0 ? ' y generar póliza' : ''}</button></div>
      </div>`;
    document.body.appendChild(ov);
    const f = (n) => ov.querySelector(`[data-f="${n}"]`);
    ov.querySelectorAll('[data-x]').forEach((b) => { b.onclick = () => ov.remove(); });
    f('ok').onclick = async () => {
        const msg = f('msg');
        const mal = (t) => { msg.textContent = t; msg.className = 'text-xs min-h-[1rem] mb-2 text-rose-400'; };
        if (!f('motivo').value.trim()) return mal('Escribe el motivo de la baja.');
        f('ok').disabled = true; msg.textContent = 'Generando…'; msg.className = 'text-xs min-h-[1rem] mb-2 text-slate-400';
        const { data, error: e } = await supabaseClient.rpc('activo_fijo_baja', { p_datos: { activo_id: id, fecha_baja: f('fecha').value || hoyISO(), motivo: f('motivo').value.trim() } });
        if (e) {
            f('ok').disabled = false;
            return mal(/activo_fijo_baja/i.test(e.message || '') && /(find|function|schema)/i.test(e.message || '') ? 'Falta correr sql/2026-10-22f_activos_apertura_baja.sql en Supabase.' : 'No se pudo dar de baja: ' + (e.message || e));
        }
        ov.remove();
        alert('✅ Equipo dado de baja.' + (data?.poliza_id ? ' Se generó la póliza BAJ.' : ''));
        await afRenderLista();
    };
};

async function afCalcularDepreciacion() {
    const cont = document.getElementById('afPreview');
    const anio = parseInt(document.getElementById('afAnio').value) || new Date().getFullYear();
    const mes = parseInt(document.getElementById('afMes').value) || (new Date().getMonth() + 1);
    cont.innerHTML = '<p class="text-slate-500 text-sm">Calculando...</p>';
    try {
        const { data, error } = await supabaseClient.rpc('depreciacion_calcular', { p_anio: anio, p_mes: mes });
        if (error) throw error;
        const filas = (data || []).filter((f) => Number(f.monto_mes) > 0);
        if (!filas.length) {
            cont.innerHTML = '<p class="text-slate-500 text-sm">No hay depreciación pendiente de aplicar para ese mes (o ya se aplicó).</p>';
            return;
        }
        const total = filas.reduce((a, f) => a + Number(f.monto_mes || 0), 0);
        cont.innerHTML = `
          <div class="overflow-x-auto border border-slate-800 rounded-lg mb-3">
            <table class="w-full text-left text-xs text-slate-300">
              <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
                <th class="p-2">Activo</th><th class="p-2 text-right">Valor en libros</th><th class="p-2 text-right">Depreciación del mes</th>
              </tr></thead>
              <tbody>
                ${filas.map((f) => `
                  <tr class="border-b border-slate-900">
                    <td class="p-2 text-slate-100">${esc(f.nombre)}</td>
                    <td class="p-2 text-right font-mono text-slate-400">${money(f.valor_en_libros)}</td>
                    <td class="p-2 text-right font-mono text-emerald-400">${money(f.monto_mes)}</td>
                  </tr>`).join('')}
              </tbody>
              <tfoot><tr><td class="p-2 text-right font-semibold text-slate-400" colspan="2">Total</td><td class="p-2 text-right font-mono font-semibold text-emerald-300">${money(total)}</td></tr></tfoot>
            </table>
          </div>
          <button type="button" id="afAplicar" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2.5 rounded-lg text-sm">Aplicar depreciación de ${mes}/${anio}</button>
          <p id="afMsgAplicar" class="text-xs mt-2 min-h-[1rem]"></p>`;
        document.getElementById('afAplicar').onclick = async () => {
            const msgA = document.getElementById('afMsgAplicar');
            if (!confirm(`¿Aplicar la depreciación de ${mes}/${anio} por un total de ${money(total)}? Se generará una póliza.`)) return;
            try {
                const { error: eAp } = await supabaseClient.rpc('depreciacion_aplicar', { p_anio: anio, p_mes: mes });
                if (eAp) throw eAp;
                msgA.textContent = 'Depreciación aplicada.';
                msgA.className = 'text-xs mt-2 text-emerald-400';
                await afCalcularDepreciacion();
                await afRenderHistorial();
            } catch (err) {
                msgA.textContent = 'No se pudo aplicar: ' + (err.message || err);
                msgA.className = 'text-xs mt-2 text-rose-400';
            }
        };
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

async function afRenderHistorial() {
    const cont = document.getElementById('afHistorial');
    try {
        const { data, error } = await supabaseClient
            .from('activos_fijos_depreciaciones')
            .select('anio, mes, monto, poliza_id, activos_fijos ( nombre )')
            .order('anio', { ascending: false })
            .order('mes', { ascending: false })
            .limit(300);
        if (error) throw error;
        if (!data || !data.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Todavía no se ha aplicado ninguna depreciación.</p>'; return; }

        const porMes = new Map();
        data.forEach((d) => {
            const key = `${d.anio}-${String(d.mes).padStart(2, '0')}`;
            if (!porMes.has(key)) porMes.set(key, { anio: d.anio, mes: d.mes, total: 0, polizaId: d.poliza_id, n: 0 });
            const g = porMes.get(key);
            g.total += Number(d.monto || 0);
            g.n += 1;
        });
        const meses = [...porMes.values()].sort((a, b) => (b.anio - a.anio) || (b.mes - a.mes));

        cont.innerHTML = `
        <div class="overflow-x-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase"><tr>
              <th class="p-2">Mes</th><th class="p-2 text-right">Activos</th><th class="p-2 text-right">Total</th><th class="p-2">Póliza</th><th class="p-2"></th>
            </tr></thead>
            <tbody>
              ${meses.map((m) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2 text-slate-100">${String(m.mes).padStart(2, '0')}/${m.anio}</td>
                  <td class="p-2 text-right font-mono text-slate-400">${m.n}</td>
                  <td class="p-2 text-right font-mono">${money(m.total)}</td>
                  <td class="p-2">${linkPoliza(m.polizaId)}</td>
                  <td class="p-2 text-right"><button type="button" onclick="window.afCancelarMes(${m.anio}, ${m.mes})" class="text-[11px] bg-slate-800 hover:bg-slate-700 text-rose-300 border border-slate-700 px-2 py-1 rounded">Cancelar</button></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

window.afCancelarMes = async (anio, mes) => {
    if (!confirm(`¿Cancelar la depreciación aplicada de ${mes}/${anio}? Se revertirá la póliza.`)) return;
    const { error } = await supabaseClient.rpc('depreciacion_cancelar', { p_anio: anio, p_mes: mes });
    if (error) { alert('No se pudo cancelar: ' + error.message); return; }
    await afRenderHistorial();
    await afCalcularDepreciacion();
};


// ---------------------------------------------------------------------
// Carga de un equipo EXISTENTE (carga inicial): depreciación acumulada al corte + póliza APE.
// Requiere sql/2026-10-22f_activos_apertura_baja.sql.
// ---------------------------------------------------------------------
window.afAbrirApertura = async (pre = {}) => {
    // Puede abrirse desde Alta de artículo sin haber visitado Activos fijos: se cargan los catálogos
    if (!afCuentas.length) {
        try { await afCargarCatalogos(); } catch (e) { alert('No se pudieron cargar los catálogos: ' + (e.message || e)); return; }
    }
    if (!afApe) { alert('Falta correr sql/2026-10-22f_activos_apertura_baja.sql en Supabase para cargar equipos existentes.'); return; }
    const idv = window.idSubventana('afAperturaModal');
    if (document.getElementById(idv)) return;
    const ov = document.createElement('div');
    ov.id = idv;
    ov.className = 'fixed inset-0 bg-slate-950/40 flex items-start justify-center p-3 overflow-y-auto';
    ov.style.zIndex = typeof window.zSubventanaSiguiente === 'function' ? window.zSubventanaSiguiente() : 80;
    const optsCta = '<option value="">Selecciona…</option>' + afCuentas.map((c) => `<option value="${c.id}">${esc(c.codigo)} · ${esc(c.nombre)}</option>`).join('');
    const anio = new Date().getFullYear();
    const inp = 'w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100';
    ov.innerHTML = `
      <div class="w-full max-w-4xl my-4 bg-slate-950 border border-slate-800 rounded-xl p-4 shadow-2xl">
        <div class="flex items-center justify-between gap-3 mb-1"><h3 class="text-base font-semibold text-emerald-300">Cargar equipo existente</h3>
          <button type="button" data-x class="text-slate-400 hover:text-slate-100 text-xl leading-none">&times;</button></div>
        <p class="text-[11px] text-slate-500 mb-3">Para equipos que ya tenías antes de empezar en el ERP. Registra su depreciación acumulada al corte y genera la póliza de apertura <b>APE</b> (una sola vez por equipo). La depreciación del ERP continúa desde el mes siguiente al corte.</p>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
          <div class="md:col-span-2"><label class="block text-[11px] text-slate-400 mb-1">Nombre del equipo <span class="text-rose-400">*</span></label><input data-f="nombre" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Categoría fiscal <span class="text-rose-400">*</span></label><select data-f="cat" class="${inp}"></select></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Fecha de adquisición original <span class="text-rose-400">*</span></label><input type="date" data-f="adq" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Costo histórico <span class="text-rose-400">*</span></label><input type="number" step="any" min="0" data-f="costo" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Vida útil original (meses) <span class="text-rose-400">*</span></label><input type="number" min="1" data-f="vida" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Valor residual</label><input type="number" step="any" min="0" value="0" data-f="res" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Fecha de corte (inicio del ERP) <span class="text-rose-400">*</span></label><input type="date" data-f="corte" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Meses ya depreciados <span class="text-slate-600">· se calcula, editable</span></label><input type="number" min="0" data-f="meses" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Área donde está <span class="text-rose-400">*</span></label><select data-f="area" class="${inp}"><option value="">Selecciona…</option>${afAreas.map((x) => `<option value="${x.id}">${esc(x.codigo)} · ${esc(x.nombre)}</option>`).join('')}</select></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Potencia de placa (kW, 0 si no usa luz)</label><input type="number" step="any" min="0" value="0" data-f="pot" class="${inp}"></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Modelo / serie</label><input data-f="modelo" class="${inp}" placeholder="opcional"></div>
          <div class="md:col-span-3 border border-slate-800 rounded-lg p-2.5 bg-slate-900/40">
            <label class="flex items-start gap-2 text-[11px] text-slate-200"><input type="checkbox" data-f="usado" class="mt-0.5 accent-emerald-500"> <span><b>Equipo usado</b> — se compró de segunda mano. El costo es lo que pagaste y la vida útil es la <b>restante</b> al comprarlo; se habilita el % fiscal editable.</span></label>
            <div data-f="usadoWrap" class="hidden mt-2 md:w-1/3"><label class="block text-[11px] text-slate-400 mb-1">% fiscal anual aplicado <span class="text-slate-600">· editable</span></label><input type="number" step="any" min="0" max="100" data-f="pct" class="${inp}"></div>
          </div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Cuenta de activo</label><select data-f="cta_act" class="${inp}">${optsCta}</select></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Depreciación acumulada</label><select data-f="cta_acum" class="${inp}">${optsCta}</select></div>
          <div><label class="block text-[11px] text-slate-400 mb-1">Gasto de depreciación</label><select data-f="cta_gas" class="${inp}">${optsCta}</select></div>
        </div>
        <div data-f="etapasWrap" class="hidden mb-3 border border-slate-800 rounded-lg p-2.5 bg-slate-900/40"><div class="text-[11px] text-slate-300 mb-1">Etapas donde se usa (la depreciación se reparte en partes iguales al prorrateo)</div>
          <div class="flex flex-wrap gap-4">${afCentros.map((c) => `<label class="flex items-center gap-1.5 text-xs text-slate-200"><input type="checkbox" data-etapa value="${c.id}" class="accent-emerald-500"> ${esc(c.codigo)} · ${esc(c.nombre)}</label>`).join('')}</div></div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div class="bg-slate-900/60 border border-slate-800 rounded-lg p-3"><p class="text-[11px] font-semibold text-sky-300 mb-1.5">Cálculo al corte</p><div data-f="calc" class="text-xs text-slate-300 space-y-0.5"></div></div>
          <div class="bg-slate-900/60 border border-slate-800 rounded-lg p-3"><p class="text-[11px] font-semibold text-sky-300 mb-1.5">Póliza APE · Diario (vista previa)</p><div data-f="pol" class="text-xs"></div>
            <div class="mt-2"><label class="block text-[11px] text-slate-400 mb-1">Contrapartida del valor en libros</label><select data-f="cta_cont" class="${inp}">${optsCta}</select></div>
            <label class="flex items-center gap-2 text-[11px] text-slate-300 mt-2"><input type="checkbox" data-f="genpol" checked class="accent-emerald-500"> Generar póliza de apertura <span class="text-slate-500">(quítala solo si esos saldos ya están en tu contabilidad)</span></label></div>
        </div>
        <p data-f="msg" class="text-xs min-h-[1rem] mt-3"></p>
        <div class="flex gap-2 mt-2"><button type="button" data-x class="bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium py-2.5 px-4 rounded-lg text-sm">Cancelar</button>
          <button type="button" data-f="ok" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2.5 rounded-lg text-sm">Guardar equipo y generar póliza</button></div>
      </div>`;
    document.body.appendChild(ov);
    const f = (n) => ov.querySelector(`[data-f="${n}"]`);
    ov.querySelectorAll('[data-x]').forEach((b) => { b.onclick = () => ov.remove(); });
    f('corte').value = hoyISO();
    f('cat').innerHTML = opcionesCategoriaDep(afCatsDep, anio);
    if (pre.nombre) f('nombre').value = pre.nombre;
    if (pre.modelo) f('modelo').value = pre.modelo;
    if (pre.cat) f('cat').value = String(pre.cat);
    f('usado').onchange = () => {
        f('usadoWrap').classList.toggle('hidden', !f('usado').checked);
        const lbl = f('vida').previousElementSibling; if (lbl) lbl.innerHTML = f('usado').checked ? 'Vida útil restante al comprarlo (meses) <span class="text-rose-400">*</span>' : 'Vida útil original (meses) <span class="text-rose-400">*</span>';
        if (f('usado').checked && !f('pct').value) f('pct').value = afCatsDep.find((c) => c.id === Number(f('cat').value))?.pct_anual ?? '';
    };
    const ctaCont = afCuentas.find((c) => c.codigo === '304.01'); if (ctaCont) f('cta_cont').value = String(ctaCont.id);
    const cod = (id) => { const c = afCuentas.find((x) => x.id === Number(id)); return c ? `${c.codigo} · ${c.nombre}` : '—'; };
    const r2 = (n) => Math.round(n * 100) / 100;

    const mesesDefault = () => {
        const a = f('adq').value, c = f('corte').value;
        if (!a || !c) return '';
        const [ya, ma] = a.split('-').map(Number), [yc, mc] = c.split('-').map(Number);
        return Math.max(0, (yc - ya) * 12 + (mc - ma) + 1);
    };
    const calc = () => {
        const costo = parseFloat(f('costo').value) || 0, res = parseFloat(f('res').value) || 0, vida = parseInt(f('vida').value) || 0;
        const meses = Math.max(0, Math.min(parseInt(f('meses').value) || 0, vida));
        const mensual = vida ? r2((costo - res) / vida) : 0;
        const acum = vida && meses >= vida ? r2(costo - res) : Math.min(r2(costo - res), r2(mensual * meses));
        const vl = r2(costo - acum);
        f('calc').innerHTML = costo && vida ? `
          <div class="flex justify-between"><span>Depreciación mensual</span><b class="font-mono">${money(mensual)}</b></div>
          <div class="flex justify-between"><span>Meses ya depreciados</span><b class="font-mono">${meses}</b></div>
          <div class="flex justify-between"><span>Depreciación acumulada</span><b class="font-mono">${money(acum)}</b></div>
          <div class="flex justify-between"><span>Valor en libros</span><b class="font-mono">${money(vl)}</b></div>
          <div class="flex justify-between"><span>Meses por depreciar</span><b class="font-mono">${Math.max(0, vida - meses)}</b></div>
          ${vl <= 0 ? '<div class="text-emerald-400 pt-1">100 % depreciado: no se depreciará más y no hay renglón contra la contrapartida.</div>' : ''}` : '<span class="text-slate-500">Captura costo, vida útil y fechas.</span>';
        const fila = (c, cg, ab) => `<tr class="border-b border-slate-900"><td class="p-1 font-mono text-[11px]">${esc(c)}</td><td class="p-1 text-right font-mono">${cg ? money(cg) : ''}</td><td class="p-1 text-right font-mono">${ab ? money(ab) : ''}</td></tr>`;
        f('pol').innerHTML = costo && vida ? `<table class="w-full text-slate-300"><tbody>
          ${fila(cod(f('cta_act').value), costo, 0)}${acum > 0 ? fila(cod(f('cta_acum').value), 0, acum) : ''}${vl > 0 ? fila(cod(f('cta_cont').value), 0, vl) : ''}</tbody></table>` : '';
        return { costo, res, vida, meses, acum, vl };
    };
    const pintarCuentas = () => {
        const fila = afCatsDep.find((c) => c.id === Number(f('cat').value));
        if (!fila) return;
        const area = afAreas.find((x) => x.id === Number(f('area').value));
        const prod = !area || area.rol !== 'no_produccion';
        if (fila.cuenta_activo_id) f('cta_act').value = String(fila.cuenta_activo_id);
        if (fila.cuenta_dep_acum_id) f('cta_acum').value = String(fila.cuenta_dep_acum_id);
        const g = prod ? fila.cuenta_gasto_cif_id : fila.cuenta_gasto_admin_id;
        if (g) f('cta_gas').value = String(g);
        if (!f('vida').value) f('vida').value = vidaMesesDePct(fila.pct_anual);
        f('etapasWrap').classList.toggle('hidden', !(prod && afTieneEtapas && esCuentaCif(f('cta_gas').value)));
    };
    f('cat').onchange = () => { pintarCuentas(); f('meses').value = mesesDefault(); calc(); };
    f('area').onchange = () => { pintarCuentas(); calc(); };
    ['adq', 'corte'].forEach((k) => { f(k).addEventListener('change', () => { f('meses').value = mesesDefault(); calc(); }); });
    ['costo', 'vida', 'res', 'meses', 'cta_act', 'cta_acum', 'cta_cont'].forEach((k) => { f(k).addEventListener('input', calc); f(k).addEventListener('change', calc); });
    f('cta_gas').addEventListener('change', () => { f('etapasWrap').classList.toggle('hidden', !(afTieneEtapas && esCuentaCif(f('cta_gas').value))); });
    calc();

    f('ok').onclick = async () => {
        const msg = f('msg');
        const mal = (t) => { msg.textContent = t; msg.className = 'text-xs min-h-[1rem] mt-3 text-rose-400'; };
        const c = calc();
        if (!f('nombre').value.trim()) return mal('Escribe el nombre del equipo.');
        if (afCatsDep.length && !f('cat').value) return mal('Elige la categoría fiscal del equipo: de ella salen su % máximo y sus cuentas.');
        if (f('usado').checked && !(parseFloat(f('pct').value) > 0 && parseFloat(f('pct').value) <= 100)) return mal('Equipo usado: captura el % fiscal anual que le aplica (entre 0 y 100).');
        if (!f('adq').value || !f('corte').value) return mal('Captura la fecha de adquisición y la fecha de corte.');
        if (c.costo <= 0 || c.vida <= 0) return mal('Captura el costo histórico y la vida útil original.');
        if (!f('area').value) return mal('Elige el área donde está el equipo.');
        if (!f('cta_act').value || !f('cta_acum').value || !f('cta_gas').value) return mal('Faltan las cuentas del equipo (activo, depreciación acumulada y gasto).');
        if (f('genpol').checked && c.vl > 0 && !f('cta_cont').value) return mal('Elige la contrapartida del valor en libros (304.01 por defecto).');
        const datos = {
            nombre: f('nombre').value.trim(), categoria_depreciacion_id: f('cat').value ? Number(f('cat').value) : null,
            fecha_adquisicion: f('adq').value, costo: c.costo, vida_util_meses: c.vida, valor_residual: c.res, fecha_corte: f('corte').value,
            meses_depreciados: c.meses, area_id: Number(f('area').value), potencia_kw: parseFloat(f('pot').value) || 0,
            modelo: f('modelo').value.trim() || null,
            cuenta_activo_id: Number(f('cta_act').value), cuenta_dep_acum_id: Number(f('cta_acum').value), cuenta_gasto_id: Number(f('cta_gas').value),
            cuenta_contrapartida_id: f('cta_cont').value ? Number(f('cta_cont').value) : null,
            generar_poliza: f('genpol').checked,
            etapas: [...ov.querySelectorAll('[data-etapa]:checked')].map((x) => Number(x.value)),
        };
        f('ok').disabled = true; msg.textContent = 'Guardando…'; msg.className = 'text-xs min-h-[1rem] mt-3 text-slate-400';
        const { data, error } = await supabaseClient.rpc('activo_fijo_apertura', { p_datos: datos });
        if (error) {
            f('ok').disabled = false;
            return mal(/activo_fijo_apertura/i.test(error.message || '') && /(find|function|schema)/i.test(error.message || '') ? 'Falta correr sql/2026-10-22f_activos_apertura_baja.sql en Supabase.' : 'No se pudo guardar: ' + (error.message || error));
        }
        if (f('usado').checked && data?.activo_id) {
            const up = await supabaseClient.from('activos_fijos').update({ usado: true, pct_fiscal: parseFloat(f('pct').value) }).eq('id', data.activo_id);
            if (up.error) alert('El equipo se cargó, pero no se pudo marcar como usado: ' + up.error.message);
        }
        ov.remove();
        alert(`✅ Equipo cargado: acumulada ${money(data.depreciacion_acumulada)}, valor en libros ${money(data.valor_en_libros)}.` + (data.poliza_id ? ' Se generó la póliza APE.' : ' Sin póliza de apertura.'));
        await afRenderLista();
    };
};
