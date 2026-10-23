import * as XLSX from 'https://cdn.sheetjs.com/xlsx-0.20.3/package/xlsx.mjs';
import { supabaseClient } from './supabase.js';

// =====================================================================
//  Utilerías → "Importar catálogo SAT (productos y servicios)".
//  Lee catCFDI.xls (hoja c_ClaveProdServ; Anexo 20 del SAT) y llena la
//  tabla c_clave_prod_serv (sql/2026-10-23_c_clave_prod_serv.sql) por
//  lotes de 1,000, con upsert por clave: se puede volver a cargar una
//  versión más nueva del catálogo sin duplicar ni borrar nada.
// =====================================================================

const norm = (s) => String(s ?? '').normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase().replace(/\s+/g, ' ').trim();
const txt = (v) => (v === undefined || v === null ? '' : String(v).trim());
const LOTE = 1000;

let filas = [];

// Busca la hoja y la fila de encabezados; devuelve las filas del catálogo.
function extraerCatalogo(wb) {
    const nombres = wb.SheetNames;
    const ordenadas = [...nombres.filter((n) => norm(n) === 'c_claveprodserv'), ...nombres.filter((n) => norm(n) !== 'c_claveprodserv')];
    for (const n of ordenadas) {
        const aoa = XLSX.utils.sheet_to_json(wb.Sheets[n], { header: 1, raw: false, defval: '' });
        const h = aoa.findIndex((r) => r.some((c) => norm(c) === 'c_claveprodserv'));
        if (h < 0) continue;
        const enc = aoa[h].map(norm);
        const col = (...opc) => enc.findIndex((c) => opc.some((o) => c.startsWith(o)));
        const iClave = col('c_claveprodserv'), iDesc = col('descripcion'), iIva = col('incluir iva'), iIeps = col('incluir ieps');
        const iSim = col('palabras similares'), iIni = col('fechainiciovigencia', 'fecha inicio'), iFin = col('fechafinvigencia', 'fecha fin');
        if (iClave < 0 || iDesc < 0) continue;
        const out = [];
        for (const r of aoa.slice(h + 1)) {
            const clave = txt(r[iClave]).replace(/\.0+$/, '');
            if (!/^\d{8}$/.test(clave)) continue;
            out.push({
                clave, descripcion: txt(r[iDesc]),
                incluir_iva: iIva >= 0 ? txt(r[iIva]) || null : null,
                incluir_ieps: iIeps >= 0 ? txt(r[iIeps]) || null : null,
                palabras_similares: iSim >= 0 ? txt(r[iSim]) || null : null,
                fecha_inicio: iIni >= 0 ? txt(r[iIni]) || null : null,
                fecha_fin: iFin >= 0 ? txt(r[iFin]) || null : null,
            });
        }
        if (out.length) return { hoja: n, filas: out };
    }
    return null;
}

export async function cargarModuloImportadorClaveSat() {
    const cont = document.getElementById('contenedorImportadorClaveSat');
    if (!cont) return;
    filas = [];
    cont.innerHTML = `
        <div class="bg-slate-900 border border-slate-800 p-4 rounded-xl space-y-3 max-w-3xl">
            <p class="text-xs text-slate-300">Carga el catálogo <span class="font-mono">c_ClaveProdServ</span> del SAT para que, al capturar la Clave SAT de un producto, el sistema busque por palabras y muestre su descripción.</p>
            <ol class="text-[11px] text-slate-400 list-decimal pl-5 space-y-0.5">
                <li>Baja <span class="font-mono">catCFDI.xls</span> del SAT (Anexo 20 · catálogos del CFDI 4.0) y usa la versión más reciente.</li>
                <li>Elígelo aquí: se lee la hoja <span class="font-mono">c_ClaveProdServ</span> (también acepta .xlsx o un .csv con las mismas columnas).</li>
                <li>Revisa el resumen y pulsa «Cargar». Puedes volver a cargar una versión nueva: actualiza por clave, no duplica.</li>
            </ol>
            <input type="file" id="icsArchivo" accept=".xls,.xlsx,.csv" class="block text-xs text-slate-300">
            <div id="icsResumen" class="text-xs text-slate-400"></div>
            <button id="icsCargar" class="hidden bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold px-4 py-2 rounded-lg">Cargar catálogo</button>
            <div id="icsEstado" class="text-xs"></div>
        </div>`;
    const resumen = cont.querySelector('#icsResumen'), btn = cont.querySelector('#icsCargar'), estado = cont.querySelector('#icsEstado');

    // Cuántas claves hay ya cargadas.
    supabaseClient.from('c_clave_prod_serv').select('clave', { count: 'exact', head: true }).then(({ count, error }) => {
        if (error) { estado.innerHTML = '<span class="text-amber-400">⚠ Falta crear la tabla: corre sql/2026-10-23_c_clave_prod_serv.sql en Supabase → SQL Editor.</span>'; return; }
        resumen.textContent = `Claves ya cargadas: ${(count || 0).toLocaleString('es-MX')}.`;
    });

    cont.querySelector('#icsArchivo').addEventListener('change', async (e) => {
        const f = e.target.files[0];
        btn.classList.add('hidden'); filas = [];
        if (!f) return;
        resumen.textContent = 'Leyendo archivo…';
        try {
            const wb = XLSX.read(await f.arrayBuffer(), { type: 'array' });
            const r = extraerCatalogo(wb);
            if (!r) { resumen.innerHTML = '<span class="text-rose-400">No encontré la hoja c_ClaveProdServ con sus columnas (clave de 8 dígitos y Descripción). ¿Es el archivo catCFDI.xls del SAT?</span>'; return; }
            filas = r.filas;
            resumen.innerHTML = `Hoja <span class="font-mono">${r.hoja}</span>: <b class="text-slate-100">${filas.length.toLocaleString('es-MX')}</b> claves listas. Ejemplo: <span class="font-mono">${filas[0].clave}</span> · ${filas[0].descripcion}`;
            btn.classList.remove('hidden');
        } catch (err) {
            resumen.innerHTML = `<span class="text-rose-400">No pude leer el archivo: ${err.message || err}</span>`;
        }
    });

    btn.addEventListener('click', async () => {
        if (!filas.length) return;
        btn.disabled = true;
        for (let i = 0; i < filas.length; i += LOTE) {
            estado.textContent = `Cargando… ${Math.min(i + LOTE, filas.length).toLocaleString('es-MX')} de ${filas.length.toLocaleString('es-MX')}`;
            const { error } = await supabaseClient.from('c_clave_prod_serv').upsert(filas.slice(i, i + LOTE), { onConflict: 'clave' });
            if (error) {
                estado.innerHTML = `<span class="text-rose-400">Error en el lote desde la fila ${i + 1}: ${error.message}. Lo ya cargado se conserva; puedes volver a intentarlo.</span>`;
                btn.disabled = false;
                return;
            }
        }
        estado.innerHTML = `<span class="text-emerald-400">✅ Catálogo cargado: ${filas.length.toLocaleString('es-MX')} claves.</span>`;
        btn.disabled = false;
    });
}
