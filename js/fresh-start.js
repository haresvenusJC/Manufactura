import { supabaseClient } from './supabase.js';

// =====================================================================
// Configuración · Fresh start (mantenimiento)
//   Vista de diagnóstico para sql/2026-09-11_reset_fresh_start_completo.sql
//   PASO 1 (conteos) y PASO 2 (contenido detallado) se corren AQUÍ, en
//   vivo, vía las funciones de solo lectura de
//   sql/2026-09-11b_fresh_start_funciones_diagnostico.sql — no borran
//   ni modifican nada.
//   PASO 3 (snapshot) y PASO 4 (borrado real) NUNCA los corre la app:
//   esta pantalla solo muestra ese SQL para copiarlo y pegarlo a mano
//   en Supabase -> SQL Editor, tal como marca la regla del proyecto.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const TABLA_FALTA = /does not exist|schema cache|could not find|function .* does not exist/i;

let fsConteos = [];
let fsDatosTabla = '';

const PASO_3_SQL = `-- =====================================================================
--  PASO 3 · SNAPSHOT — respaldo de cada tabla que se va a borrar, en
--  tablas espejo "_bkp_fresh_<tabla>". No borra nada, es seguro correrlo
--  aunque luego decidas no seguir con el PASO 4.
-- =====================================================================
do $$
declare
    preservar text[] := array[
        'cuentas_contables','centros_costo','areas_fisicas','areas_fisicas_cargas',
        'reparto_plantillas','reparto_plantilla_lineas','tipos_movimiento',
        'unidades_medida','monedas','c_uso_cfdi','c_forma_pago','c_metodo_pago',
        'plantillas_documentos','isr_tarifas','isr_tarifa_tramos','costos_config',
        'procesos_produccion',
        'clientes','empleados','listas_precio','nominas','nomina_detalles',
        'tareas','alertas_caducidad_umbrales'
    ];
    restante text[];
    t        text;
begin
    select array_agg(tablename) into restante
      from pg_tables
     where schemaname = 'public'
       and tablename <> all (preservar)
       and tablename not like '\\_bkp%' escape '\\'
       and tablename <> '_fresh_orden';

    if restante is null then
        raise notice 'PASO 3  nada que respaldar (lista vacía)';
        return;
    end if;

    foreach t in array restante loop
        execute format('drop table if exists public.%I', '_bkp_fresh_' || t);
        execute format('create table public.%I as table public.%I', '_bkp_fresh_' || t, t);
        raise notice 'PASO 3  snapshot listo: _bkp_fresh_%', t;
    end loop;
end $$;`;

const PASO_4_SQL = `-- =====================================================================
--  PASO 4 · BORRADO REAL — requiere autorización explícita.
--
--  Antes de correr esto: cambia la línea "confirmo boolean := false"
--  de abajo a "true". Mientras diga false, el script se detiene sin
--  borrar nada.
-- =====================================================================
do $$
declare
    confirmo boolean := false;   -- <<< cambia a true para autorizar el borrado
    preservar text[] := array[
        'cuentas_contables','centros_costo','areas_fisicas','areas_fisicas_cargas',
        'reparto_plantillas','reparto_plantilla_lineas','tipos_movimiento',
        'unidades_medida','monedas','c_uso_cfdi','c_forma_pago','c_metodo_pago',
        'plantillas_documentos','isr_tarifas','isr_tarifa_tramos','costos_config',
        'procesos_produccion',
        'clientes','empleados','listas_precio','nominas','nomina_detalles',
        'tareas','alertas_caducidad_umbrales'
    ];
    restante text[];
    t        text;
    hoja     text;
    encontro boolean;
    v_seq    text;
begin
    if not confirmo then
        raise exception 'PASO 4 detenido: cambia "confirmo" a true en este script para autorizar el borrado total.';
    end if;

    select array_agg(tablename) into restante
      from pg_tables
     where schemaname = 'public'
       and tablename <> all (preservar)
       and tablename not like '\\_bkp%' escape '\\'
       and tablename <> '_fresh_orden';

    if restante is null then
        raise notice 'PASO 4  nada que borrar (lista vacía)';
        return;
    end if;

    while array_length(restante,1) > 0 loop
        encontro := false;
        foreach t in array restante loop
            perform 1
              from pg_constraint con
              join pg_class cl    on cl.oid = con.conrelid
              join pg_class clref on clref.oid = con.confrelid
              join pg_namespace ns on ns.oid = cl.relnamespace and ns.nspname = 'public'
             where con.contype = 'f'
               and clref.relname = t
               and cl.relname <> t
               and cl.relname = any (restante);
            if not found then
                hoja := t;
                encontro := true;
                exit;
            end if;
        end loop;

        if not encontro then
            raise exception 'PASO 4  ciclo de FKs detectado entre: %  (revisar a mano, no se borró nada más)', array_to_string(restante, ', ');
        end if;

        execute format('delete from public.%I', hoja);

        v_seq := pg_get_serial_sequence(format('public.%I', hoja), 'id');
        if v_seq is not null then
            execute 'alter sequence ' || v_seq || ' restart with 1';
        end if;

        raise notice 'PASO 4  borrado: %  (secuencia id reiniciada: %)', hoja, coalesce(v_seq, 'n/a');
        restante := array_remove(restante, hoja);
    end loop;

    raise notice 'PASO 4  listo — fresh start completo.';
end $$;`;

export async function cargarModuloFreshStart() {
    const cont = document.getElementById('contenedorFreshStart');
    if (!cont) return;

    cont.innerHTML = `
    <div class="space-y-5">
      <div class="bg-rose-950/40 border border-rose-800 rounded-xl p-3 text-xs text-rose-200">
        ⚠ Esta pantalla es para cuando decidas terminar las pruebas y arrancar operación real. El <b>PASO 1</b> y <b>PASO 2</b> solo consultan (no borran nada) y corren aquí mismo. El <b>PASO 3</b> (respaldo) y el <b>PASO 4</b> (borrado real) nunca los corre la app — aquí solo te doy el SQL para copiar y pegarlo a mano en Supabase → SQL Editor.
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
        <div class="flex items-center justify-between gap-2">
          <h3 class="text-sm font-semibold text-slate-200">Paso 1 · ¿Qué se borraría? (conteos)</h3>
          <button type="button" id="fsBtnConteos" class="text-xs bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded-lg" style="cursor:pointer">Actualizar diagnóstico</button>
        </div>
        <div id="fsConteosBox" class="text-xs text-slate-500">Sin cargar todavía.</div>
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
        <h3 class="text-sm font-semibold text-slate-200">Paso 2 · Previo de decisión (contenido detallado)</h3>
        <div class="flex flex-wrap items-center gap-2">
          <select id="fsSelectTabla" class="bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100">
            <option value="">— Todas las tablas —</option>
          </select>
          <button type="button" id="fsBtnDatos" class="text-xs bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded-lg" style="cursor:pointer">Ver contenido</button>
          <span class="text-[11px] text-slate-500">Corre primero el Paso 1 para llenar la lista de tablas.</span>
        </div>
        <div id="fsDatosBox" class="text-xs text-slate-500">Sin cargar todavía.</div>
      </div>

      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-2">
        <div class="flex items-center justify-between gap-2">
          <h3 class="text-sm font-semibold text-slate-200">Paso 3 · Snapshot (correr en Supabase)</h3>
          <button type="button" class="fsBtnCopiar text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg" data-sql="paso3" style="cursor:pointer">📋 Copiar SQL</button>
        </div>
        <p class="text-[11px] text-slate-500">No borra nada — crea las tablas espejo <span class="font-mono">_bkp_fresh_*</span> por si te arrepientes.</p>
        <pre class="bg-black/40 border border-slate-800 rounded-lg p-3 text-[11px] text-slate-300 overflow-x-auto max-h-56">${esc(PASO_3_SQL)}</pre>
      </div>

      <div class="bg-slate-950 border border-rose-900 rounded-xl p-4 space-y-2">
        <div class="flex items-center justify-between gap-2">
          <h3 class="text-sm font-semibold text-rose-300">Paso 4 · Borrado real (correr en Supabase)</h3>
          <button type="button" class="fsBtnCopiar text-xs bg-rose-800 hover:bg-rose-700 text-white px-3 py-1.5 rounded-lg" data-sql="paso4" style="cursor:pointer">📋 Copiar SQL</button>
        </div>
        <p class="text-[11px] text-rose-300/80">Antes de correrlo en Supabase, cambia a mano <span class="font-mono">confirmo boolean := false</span> por <span class="font-mono">true</span>. Mientras diga <span class="font-mono">false</span>, se detiene sin borrar nada.</p>
        <pre class="bg-black/40 border border-rose-900 rounded-lg p-3 text-[11px] text-rose-100 overflow-x-auto max-h-56">${esc(PASO_4_SQL)}</pre>
      </div>
    </div>`;

    document.getElementById('fsBtnConteos').addEventListener('click', fsCargarConteos);
    document.getElementById('fsBtnDatos').addEventListener('click', fsCargarDatos);
    cont.querySelectorAll('.fsBtnCopiar').forEach(btn => {
        btn.addEventListener('click', () => fsCopiar(btn.dataset.sql, btn));
    });
}

async function fsCopiar(cual, btn) {
    const texto = cual === 'paso3' ? PASO_3_SQL : PASO_4_SQL;
    try {
        await navigator.clipboard.writeText(texto);
        const original = btn.textContent;
        btn.textContent = '✔ Copiado';
        setTimeout(() => { btn.textContent = original; }, 1500);
    } catch (err) {
        alert('No se pudo copiar automáticamente. Selecciona el texto del cuadro y cópialo a mano.');
    }
}

async function fsCargarConteos() {
    const box = document.getElementById('fsConteosBox');
    box.innerHTML = `<p class="text-slate-500">Consultando...</p>`;
    try {
        const { data, error } = await supabaseClient.rpc('fresh_start_preview_conteos');
        if (error) throw error;
        fsConteos = data || [];

        if (!fsConteos.length) {
            box.innerHTML = `<p class="text-slate-500">No hay tablas con datos de prueba por borrar.</p>`;
        } else {
            box.innerHTML = `
            <div class="overflow-x-auto">
              <table class="w-full text-xs">
                <thead><tr class="text-slate-500 text-left"><th class="py-1 pr-3">Orden</th><th class="py-1 pr-3">Tabla</th><th class="py-1 pr-3 text-right">Filas actuales</th></tr></thead>
                <tbody>
                  ${fsConteos.map(r => `<tr class="border-t border-slate-800">
                    <td class="py-1 pr-3 text-slate-500">${r.orden}</td>
                    <td class="py-1 pr-3 font-mono text-slate-200">${esc(r.tabla)}</td>
                    <td class="py-1 pr-3 text-right ${r.filas > 0 ? 'text-amber-300' : 'text-slate-600'}">${r.filas}</td>
                  </tr>`).join('')}
                </tbody>
              </table>
            </div>`;
        }

        const sel = document.getElementById('fsSelectTabla');
        const actual = sel.value;
        sel.innerHTML = `<option value="">— Todas las tablas —</option>` +
            fsConteos.map(r => `<option value="${esc(r.tabla)}">${esc(r.tabla)} (${r.filas})</option>`).join('');
        sel.value = actual;
    } catch (err) {
        if (TABLA_FALTA.test(err.message || '')) {
            box.innerHTML = `<p class="text-amber-400">Falta correr <span class="font-mono">sql/2026-09-11b_fresh_start_funciones_diagnostico.sql</span> en Supabase.</p>`;
            return;
        }
        box.innerHTML = `<p class="text-rose-400">Error: ${esc(err.message || String(err))}</p>`;
    }
}

// Valor de una celda tipo "hoja de cálculo": vacío/booleano legible,
// objetos/arrays anidados en una línea (con el valor completo en el title
// por si se truncan visualmente).
function fsCelda(v) {
    if (v === null || v === undefined) return `<span class="text-slate-600">—</span>`;
    if (typeof v === 'boolean') return v ? 'sí' : 'no';
    if (typeof v === 'object') {
        const txt = JSON.stringify(v);
        return `<span title="${esc(txt)}">${esc(txt)}</span>`;
    }
    return esc(String(v));
}

function fsTablaHtml(tabla, filas) {
    const columnas = [];
    filas.forEach(f => Object.keys(f || {}).forEach(k => { if (!columnas.includes(k)) columnas.push(k); }));

    return `
    <div class="mb-4">
      <div class="text-xs font-mono text-sky-400 mb-1">${esc(tabla)} <span class="text-slate-500">(${filas.length} fila${filas.length === 1 ? '' : 's'})</span></div>
      <div class="overflow-x-auto border border-slate-800 rounded-lg max-h-96">
        <table class="w-full text-[11px] border-collapse">
          <thead class="sticky top-0">
            <tr class="bg-slate-900 text-slate-400">
              <th class="px-2 py-1 text-left border-b border-slate-800">#</th>
              ${columnas.map(c => `<th class="px-2 py-1 text-left border-b border-slate-800 whitespace-nowrap">${esc(c)}</th>`).join('')}
            </tr>
          </thead>
          <tbody>
            ${filas.map((f, i) => `
              <tr class="odd:bg-black/20">
                <td class="px-2 py-1 text-slate-600">${i + 1}</td>
                ${columnas.map(c => `<td class="px-2 py-1 text-slate-300 whitespace-nowrap">${fsCelda(f[c])}</td>`).join('')}
              </tr>`).join('')}
          </tbody>
        </table>
      </div>
    </div>`;
}

async function fsCargarDatos() {
    const box = document.getElementById('fsDatosBox');
    fsDatosTabla = document.getElementById('fsSelectTabla').value;
    box.innerHTML = `<p class="text-slate-500">Consultando...</p>`;
    try {
        const { data, error } = await supabaseClient.rpc('fresh_start_preview_datos', { p_tabla: fsDatosTabla || null });
        if (error) throw error;
        const filas = data || [];

        if (!filas.length) {
            box.innerHTML = `<p class="text-slate-500">Sin filas${fsDatosTabla ? ` en "${esc(fsDatosTabla)}"` : ''}.</p>`;
            return;
        }

        const porTabla = new Map();
        filas.forEach(r => {
            if (!porTabla.has(r.tabla)) porTabla.set(r.tabla, []);
            porTabla.get(r.tabla).push(r.fila || {});
        });

        box.innerHTML = `
        <p class="text-[11px] text-slate-500 mb-2">${filas.length} fila(s)${fsDatosTabla ? ` en "${esc(fsDatosTabla)}"` : ` en ${porTabla.size} tabla(s)`}.</p>
        ${Array.from(porTabla.entries()).map(([tabla, rows]) => fsTablaHtml(tabla, rows)).join('')}`;
    } catch (err) {
        if (TABLA_FALTA.test(err.message || '')) {
            box.innerHTML = `<p class="text-amber-400">Falta correr <span class="font-mono">sql/2026-09-11b_fresh_start_funciones_diagnostico.sql</span> en Supabase.</p>`;
            return;
        }
        box.innerHTML = `<p class="text-rose-400">Error: ${esc(err.message || String(err))}</p>`;
    }
}
