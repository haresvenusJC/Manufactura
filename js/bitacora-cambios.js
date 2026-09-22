import { supabaseClient } from './supabase.js';
import { crearOrdenTabla, thOrden, wireOrdenTabla, aplicarOrden } from './orden-tabla.js';
import { montarGuia } from './asistente-contable.js';

// =====================================================================
//  Bitácora de movimientos — consulta de public.bitacora_cambios, que se
//  llena sola vía triggers (fn_bitacora_generica) en las tablas de
//  catálogos, compras, ventas, inventario, producción y finanzas, y con
//  los eventos de inicio/cierre de sesión (bitacora_evento). Guarda quién
//  (correo), cuándo, qué tabla y el antes/después de cada cambio.
//  Solo lectura — nadie puede alterar ni borrar el rastro (ni el admin):
//  la tabla solo admite INSERT desde los triggers (security definer).
//  Requiere sql/2026-10-20_bitacora_todos_los_movimientos.sql para el
//  correo y las tablas nuevas; sin ella sigue mostrando lo anterior.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const hoyISO = () => new Date().toISOString().slice(0, 10);
const primerDiaMesISO = () => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0, 10); };
const bitOrden = crearOrdenTabla('creado_at', 'desc');
const LIMITE = 500;
let bitFiltros = { usuario: '', tabla: '', accion: '', desde: '', hasta: '' };
let bitFilas = [];

// Nombre entendible de cada tabla que se audita.
const ETIQUETA_TABLA = {
    sesion: 'Inicio / cierre de sesión',
    productos: 'Productos', bom: 'BOM (componentes)', producto_claves_proveedor: 'Claves de proveedor',
    proveedores: 'Proveedores', clientes: 'Clientes', listas_precio: 'Listas de precio', lista_precio_items: 'Partidas de lista de precio',
    empleados: 'Empleados', unidades_medida: 'Unidades de medida', monedas: 'Monedas',
    centros_costo: 'Centros de costo', areas_fisicas: 'Áreas físicas', areas_fisicas_cargas: 'Cargas de áreas',
    reparto_plantillas: 'Plantillas de reparto', reparto_plantilla_lineas: 'Líneas de plantilla de reparto',
    costos_config: 'Parámetros de costeo', alertas_caducidad_umbrales: 'Umbrales de caducidad',
    requisiciones_compra: 'Requisiciones de compra', requisiciones_compra_detalle: 'Partidas de requisición',
    ordenes_compra: 'Órdenes de compra', ordenes_compra_detalle: 'Partidas de orden de compra',
    pre_recibos: 'Pre-recibos', recibo_costos_adicionales: 'Costos adicionales de recibo',
    documentos: 'Documentos (compras, ventas, producción)', pedidos_venta: 'Pedidos de venta', pedidos_venta_detalle: 'Partidas de pedido',
    auditorias_inventario: 'Auditorías de inventario', auditoria_items: 'Partidas de auditoría', inventario_deterioros: 'Deterioros de inventario',
    ordenes_produccion: 'Órdenes de producción',
    gastos: 'Gastos', polizas: 'Pólizas', pagos_proveedor: 'Pagos a proveedores', cobros_cliente: 'Cobros de clientes',
    nominas: 'Nóminas', nomina_detalles: 'Detalle de nómina', prorrateo_corridas: 'Prorrateos',
    cuentas_contables: 'Plan de cuentas', isr_tarifas: 'Tarifas ISR', isr_tarifa_tramos: 'Tramos ISR', periodos_contables: 'Cierre de periodo',
    activos_fijos: 'Activos fijos', devoluciones_cliente: 'Devoluciones de cliente', devoluciones_proveedor: 'Devoluciones a proveedor',
    cuentas_bancarias: 'Cuentas bancarias',
};
const nombreTabla = (t) => ETIQUETA_TABLA[t] || t;

const ETIQUETA_ACCION = { INSERT: 'Alta', UPDATE: 'Modificación', DELETE: 'Baja', LOGIN: 'Inicio de sesión', LOGOUT: 'Cierre de sesión' };
const ACCION_ESTILO = {
    INSERT: 'text-emerald-300 bg-emerald-950/40',
    UPDATE: 'text-amber-300 bg-amber-950/40',
    DELETE: 'text-rose-300 bg-rose-950/40',
    LOGIN: 'text-sky-300 bg-sky-950/40',
    LOGOUT: 'text-slate-300 bg-slate-800',
};

// Campos que cambian solos y no dicen nada al leer la bitácora.
const CAMPOS_RUIDO = new Set(['updated_at', 'actualizado_at', 'modificado_at', 'created_at', 'creado_at']);

const usuarioTxt = (r) => r.usuario_email || (r.usuario_id ? String(r.usuario_id).slice(0, 8) : 'Operador / sistema');

// Un nombre corto para reconocer el registro (nombre, folio, SKU...).
function etiquetaRegistro(d) {
    if (!d) return '';
    return d.nombre || d.folio || d.sku || d.codigo || d.concepto || d.descripcion || d.numero_lote || '';
}

// [[campo, antes, después], ...] de lo que cambió en un UPDATE.
function cambiosDe(r) {
    const a = r.datos_antes || {};
    const b = r.datos_despues || {};
    const out = [];
    new Set([...Object.keys(a), ...Object.keys(b)]).forEach((k) => {
        if (CAMPOS_RUIDO.has(k)) return;
        if (JSON.stringify(a[k]) !== JSON.stringify(b[k])) out.push([k, a[k], b[k]]);
    });
    return out;
}

const corto = (v, max = 40) => {
    const s = v === null || v === undefined ? '—' : (typeof v === 'object' ? JSON.stringify(v) : String(v));
    return s.length > max ? s.slice(0, max) + '…' : s;
};
const campoLegible = (k) => k.replace(/_/g, ' ');

// Texto de una sola línea: qué pasó.
function resumenDe(r) {
    if (r.accion === 'LOGIN') return 'Inició sesión';
    if (r.accion === 'LOGOUT') return 'Cerró sesión';
    if (r.accion === 'INSERT') { const e = etiquetaRegistro(r.datos_despues); return 'Alta' + (e ? ': ' + e : ''); }
    if (r.accion === 'DELETE') { const e = etiquetaRegistro(r.datos_antes); return 'Baja' + (e ? ': ' + e : ''); }
    const cambios = cambiosDe(r);
    if (!cambios.length) return 'Sin cambios visibles';
    const partes = cambios.slice(0, 3).map(([k, a, b]) => `${campoLegible(k)}: ${corto(a, 24)} → ${corto(b, 24)}`);
    return partes.join(' · ') + (cambios.length > 3 ? ` · +${cambios.length - 3} más` : '');
}

export async function cargarModuloBitacora() {
    const cont = document.getElementById('contenedorBitacora');
    if (!cont) return;

    const optsTabla = `<option value="">Todo el sistema</option>` +
        Object.keys(ETIQUETA_TABLA).sort((a, b) => nombreTabla(a).localeCompare(nombreTabla(b), 'es'))
            .map((t) => `<option value="${t}">${esc(nombreTabla(t))}</option>`).join('');
    const optsAccion = `<option value="">Todas</option>` +
        Object.entries(ETIQUETA_ACCION).map(([v, t]) => `<option value="${v}">${t}</option>`).join('');

    cont.innerHTML = `
    <div class="space-y-4">
      <div class="bg-slate-950 border border-slate-800 rounded-xl p-4">
        <div class="grid grid-cols-1 md:grid-cols-3 xl:grid-cols-6 gap-3">
          <div><label class="block text-xs text-slate-400 mb-1">Usuario</label>
            <select id="bitUsuario" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"><option value="">Todos</option></select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Módulo / tabla</label>
            <select id="bitTabla" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optsTabla}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Acción</label>
            <select id="bitAccion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">${optsAccion}</select></div>
          <div><label class="block text-xs text-slate-400 mb-1">Desde</label>
            <input type="date" id="bitDesde" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div><label class="block text-xs text-slate-400 mb-1">Hasta</label>
            <input type="date" id="bitHasta" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></div>
          <div class="flex items-end gap-2">
            <button type="button" id="bitConsultar" class="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-medium py-2 rounded-lg text-sm">Consultar</button>
            <button type="button" id="bitCsv" title="Descargar lo que se ve como CSV" class="bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-2 rounded-lg text-sm">⬇ CSV</button>
          </div>
        </div>
      </div>
      <div id="bitLista" class="bg-slate-950 border border-slate-800 rounded-xl p-3 text-sm text-slate-500">Cargando...</div>
    </div>`;

    document.getElementById('bitConsultar').onclick = () => {
        bitFiltros = {
            usuario: document.getElementById('bitUsuario').value,
            tabla: document.getElementById('bitTabla').value,
            accion: document.getElementById('bitAccion').value,
            desde: document.getElementById('bitDesde').value,
            hasta: document.getElementById('bitHasta').value,
        };
        bitCargar();
    };
    document.getElementById('bitCsv').onclick = bitExportarCsv;

    // Igual que el resto de los reportes: arranca del inicio del mes a hoy.
    document.getElementById('bitDesde').value = primerDiaMesISO();
    document.getElementById('bitHasta').value = hoyISO();
    bitFiltros = { usuario: '', tabla: '', accion: '', desde: primerDiaMesISO(), hasta: hoyISO() };

    await bitLlenarUsuarios();
    await bitCargar();
    montarGuia(cont, 'bitacora-cambios');
}

// Los usuarios que aparecen en la bitácora (correos reales de las últimas filas).
async function bitLlenarUsuarios() {
    const sel = document.getElementById('bitUsuario');
    try {
        const { data, error } = await supabaseClient.from('bitacora_cambios')
            .select('usuario_email').order('creado_at', { ascending: false }).limit(3000);
        if (error) throw error;
        const correos = [...new Set((data || []).map((r) => r.usuario_email).filter(Boolean))].sort();
        sel.innerHTML = `<option value="">Todos</option>` +
            correos.map((c) => `<option value="${esc(c)}">${esc(c)}</option>`).join('') +
            `<option value="__sistema__">Operador / sistema (sin correo)</option>`;
    } catch (_) { /* sin la columna usuario_email (migración pendiente): queda "Todos" */ }
}

async function bitCargar() {
    const cont = document.getElementById('bitLista');
    cont.innerHTML = '<p class="text-slate-500 text-sm">Consultando...</p>';
    try {
        let q = supabaseClient.from('bitacora_cambios').select('*').order('creado_at', { ascending: false }).limit(LIMITE);
        const f = bitFiltros;
        if (f.tabla) q = q.eq('tabla', f.tabla);
        if (f.accion) q = q.eq('accion', f.accion);
        if (f.usuario === '__sistema__') q = q.is('usuario_email', null).is('usuario_id', null);
        else if (f.usuario) q = q.eq('usuario_email', f.usuario);
        if (f.desde) q = q.gte('creado_at', new Date(`${f.desde}T00:00:00`).toISOString());
        if (f.hasta) q = q.lte('creado_at', new Date(`${f.hasta}T23:59:59`).toISOString());
        const { data, error } = await q;
        if (error) throw error;
        bitFilas = data || [];
        if (!bitFilas.length) { cont.innerHTML = '<p class="text-slate-500 text-sm">Sin movimientos con estos filtros.</p>'; return; }

        aplicarOrden(bitOrden, bitFilas, (r, campo) => {
            switch (campo) {
                case 'usuario': return usuarioTxt(r).toLowerCase();
                case 'tabla': return nombreTabla(r.tabla).toLowerCase();
                case 'accion': return r.accion || '';
                case 'creado_at': return r.creado_at || '';
                default: return r.id;
            }
        });

        cont.innerHTML = `
        <p class="text-xs text-slate-500 mb-2">${bitFilas.length} movimiento(s)${bitFilas.length >= LIMITE ? ` — se muestran los ${LIMITE} más recientes; afina con usuario, módulo o fechas` : ''}.</p>
        <div class="overflow-x-auto max-h-[75vh] overflow-y-auto border border-slate-800 rounded-lg">
          <table class="w-full text-left text-xs text-slate-300">
            <thead class="bg-slate-900 text-slate-400 uppercase sticky top-0"><tr>
              <th class="p-2"></th>${thOrden(bitOrden, 'creado_at', 'Fecha')}${thOrden(bitOrden, 'usuario', 'Usuario')}${thOrden(bitOrden, 'tabla', 'Módulo')}
              ${thOrden(bitOrden, 'accion', 'Acción')}<th class="p-2">Qué cambió</th>
            </tr></thead>
            <tbody>
              ${bitFilas.map((r) => `
                <tr class="border-b border-slate-900">
                  <td class="p-2"><button type="button" onclick="window.bitVerDetalle(${r.id})" class="text-sky-400 hover:text-sky-300 text-[11px]">Ver</button></td>
                  <td class="p-2 whitespace-nowrap text-slate-400">${r.creado_at ? new Date(r.creado_at).toLocaleString('es-MX') : ''}</td>
                  <td class="p-2 text-slate-300">${esc(usuarioTxt(r))}</td>
                  <td class="p-2">${esc(nombreTabla(r.tabla))}${r.registro_id ? ` <span class="font-mono text-slate-500">#${r.registro_id}</span>` : ''}</td>
                  <td class="p-2"><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold ${ACCION_ESTILO[r.accion] || 'text-slate-400 bg-slate-800'}">${esc(ETIQUETA_ACCION[r.accion] || r.accion)}</span></td>
                  <td class="p-2 text-slate-400">${esc(resumenDe(r))}</td>
                </tr>
                <tr id="bitDetalle${r.id}" class="hidden border-b border-slate-900">
                  <td></td>
                  <td colspan="5" class="p-2">${detalleHtml(r)}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
        wireOrdenTabla(cont, bitOrden, bitCargar);
    } catch (err) {
        cont.innerHTML = `<p class="text-rose-400 text-xs">Error: ${esc(err.message || err)}</p>`;
    }
}

// Detalle desplegable: en una modificación, solo los campos que cambiaron; en alta/baja, el registro completo.
function detalleHtml(r) {
    if (r.accion === 'LOGIN' || r.accion === 'LOGOUT') return '<p class="text-[11px] text-slate-500">Evento de sesión.</p>';
    if (r.accion === 'UPDATE') {
        const cambios = cambiosDe(r);
        if (cambios.length) {
            return `
            <table class="w-full text-[11px] border border-slate-800 rounded">
              <thead class="text-slate-500"><tr><th class="p-1.5 text-left">Campo</th><th class="p-1.5 text-left">Antes</th><th class="p-1.5 text-left">Después</th></tr></thead>
              <tbody>
                ${cambios.map(([k, a, b]) => `
                <tr class="border-t border-slate-800">
                  <td class="p-1.5 text-slate-300">${esc(campoLegible(k))}</td>
                  <td class="p-1.5 font-mono text-rose-300/80 break-all">${esc(corto(a, 300))}</td>
                  <td class="p-1.5 font-mono text-emerald-300/80 break-all">${esc(corto(b, 300))}</td>
                </tr>`).join('')}
              </tbody>
            </table>`;
        }
    }
    const datos = r.accion === 'DELETE' ? r.datos_antes : r.datos_despues;
    return `<pre class="text-[10px] bg-slate-900 border border-slate-800 rounded p-2 overflow-x-auto">${esc(JSON.stringify(datos, null, 2) || 'null')}</pre>`;
}

// Baja a CSV lo que está en pantalla (con los filtros aplicados).
function bitExportarCsv() {
    if (!bitFilas.length) { alert('No hay movimientos en pantalla para exportar.'); return; }
    const celda = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const lineas = [['Fecha', 'Usuario', 'Módulo', 'Registro', 'Acción', 'Qué cambió'].map(celda).join(',')];
    bitFilas.forEach((r) => {
        lineas.push([
            r.creado_at ? new Date(r.creado_at).toLocaleString('es-MX') : '',
            usuarioTxt(r), nombreTabla(r.tabla), r.registro_id ?? '',
            ETIQUETA_ACCION[r.accion] || r.accion, resumenDe(r),
        ].map(celda).join(','));
    });
    const blob = new Blob(['﻿' + lineas.join('\r\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `bitacora_${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}

window.bitVerDetalle = (id) => {
    document.getElementById(`bitDetalle${id}`)?.classList.toggle('hidden');
};
