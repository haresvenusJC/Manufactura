// =====================================================================
// Índice del ERP — mapa de todos los módulos con acceso directo.
//   Pensado para llegar rápido a las pantallas de configuración.
// =====================================================================

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

const SECCIONES = [
    {
        grupo: 'Catálogos', ancla: 'cat', items: [
            { v: 'catalogo', t: 'Productos', d: 'Alta y edición de productos, materias primas e insumos: SKU, unidad, costo, bandera de control de caducidad.', cfg: true },
            { v: 'proveedores', t: 'Proveedores', d: 'Datos fiscales: RFC, régimen, uso CFDI, forma y método de pago, cuenta de gasto por defecto.', cfg: true },
            { v: 'clientes', t: 'Clientes y listas de precio', d: 'Clientes y sus listas de precio.', cfg: true },
            { v: 'empleados', t: 'Empleados', d: 'Plantilla, costo por hora y PIN para la Orden de Trabajo en el celular.', cfg: true },
            { v: 'importador', t: 'Importar Excel/CSV', d: 'Carga masiva de productos desde una plantilla.' },
        ],
    },
    {
        grupo: 'Inventario', ancla: 'inv', items: [
            { v: 'inventario', t: 'Stock General', d: 'Existencias por producto y por lote, con mínimos.' },
            { v: 'kardex', t: 'Kardex', d: 'Movimientos de entrada y salida por producto, con el criterio FIFO/FEFO usado.' },
        ],
    },
    {
        grupo: 'Entradas', ancla: 'ent', items: [
            { v: 'ordenes-compra', t: 'Órdenes de compra', d: 'Emisión de órdenes de compra a proveedores.' },
            { v: 'recibo-mercancia', t: 'Recibo de mercancía', d: 'Recepción contra OC o desde el XML del CFDI; captura de lote y caducidad.' },
            { v: 'compras', t: 'Compras / Proveedores', d: 'Compras con afectación contable directa.' },
            { v: 'entradas-directas', t: 'Entradas directas', d: 'Altas de inventario sin orden de compra.' },
        ],
    },
    {
        grupo: 'Salidas', ancla: 'sal', items: [
            { v: 'salidas', t: 'Salidas / Ventas', d: 'Salidas de inventario y ventas.' },
        ],
    },
    {
        grupo: 'Producción', ancla: 'prod', items: [
            { v: 'produccion', t: 'Producción', d: 'Órdenes de producción: BOM, procesos con su centro de costo, cierre y costeo del lote.', cfg: true },
        ],
    },
    {
        grupo: 'Documentos y reportes', ancla: 'doc', items: [
            { v: 'documentos', t: 'Documentos', d: 'Consecutivos y consulta de documentos.' },
            { v: 'auditoria', t: 'Auditoría', d: 'Bitácora de cambios.' },
            { v: 'reportes', t: 'Reportes', d: 'Reportes operativos.' },
        ],
    },
    {
        grupo: 'Contabilidad — operación diaria', ancla: 'cta-op', items: [
            { v: 'gastos', t: 'Gastos', d: 'Captura de facturas de gasto. Trae lector de XML del CFDI y asistente de clasificación.' },
            { v: 'pagos-proveedor', t: 'Cuentas por pagar', d: 'Saldos por proveedor y registro de pagos.' },
            { v: 'tareas', t: 'Tareas', d: 'Pendientes automáticos: inventario bajo mínimo, lotes por caducar, nómina por generar.' },
        ],
    },
    {
        grupo: 'Contabilidad — nómina y cierre de mes', ancla: 'cta-mes', items: [
            { v: 'nomina', t: 'Nómina', d: 'Cálculo y contabilización de sueldos, IMSS/INFONAVIT e ISR.' },
            { v: 'prorrateo', t: 'Prorrateo de gastos', d: 'Reparto mensual del CIF a las órdenes y a la capacidad no utilizada.' },
            { v: 'polizas', t: 'Pólizas', d: 'Consulta de los asientos contables generados.' },
            { v: 'reportes-contables', t: 'Reportes contables', d: 'Balanza de comprobación, estado de resultados, saldos por cuenta.' },
        ],
    },
    {
        grupo: 'Configuración — contabilidad y costos', ancla: 'cfg-cta', config: true, items: [
            { v: 'plan-cuentas', t: 'Plan de cuentas', d: 'Catálogo de cuentas (Código Agrupador SAT). En las 503.xx se marca fijo o variable.', cfg: true },
            { v: 'centros-costo', t: 'Centros de costo', d: 'Las 3 etapas SURT / MEZ / ENV y su capacidad normal en horas de mano de obra al mes.', cfg: true },
            { v: 'areas-prorrateo', t: 'Áreas y bases de prorrateo', d: 'm², carga eléctrica (kW) y personas por área. De aquí salen los % con que se reparten renta, luz y servicios.', cfg: true },
            { v: 'reparto-plantillas', t: 'Reparto de gastos compartidos', d: 'Plantillas por cuenta o proveedor: qué base usar y a qué cuenta de oficina va la parte de no producción.', cfg: true },
            { v: 'isr', t: 'Tabla ISR', d: 'Tarifas de retención de ISR sobre sueldos (Art. 96 LISR) y subsidio.', cfg: true },
        ],
    },
    {
        grupo: 'Configuración — general', ancla: 'cfg-gral', config: true, items: [
            { v: 'configuracion', t: 'General', d: 'Datos de la empresa y parámetros globales.', cfg: true },
            { v: 'plantillas', t: 'Plantillas de impresión', d: 'Diseño de los documentos que se imprimen.', cfg: true },
        ],
    },
];

const DOCS = [
    { href: 'manual-costos-produccion.html', t: '📖 Manual de gastos y costos de producción' },
    { href: 'guia-costos-produccion.html', t: '▶ Guía interactiva del flujo de costos' },
];

export function cargarModuloIndice() {
    const cont = document.getElementById('contenedorIndice');
    if (!cont) return;

    const chip = (s) => `<a href="#idx-${s.ancla}" class="text-[11px] px-2.5 py-1 rounded-full border ${s.config ? 'border-amber-700 text-amber-300' : 'border-slate-700 text-slate-300'} hover:bg-slate-800 whitespace-nowrap">${esc(s.grupo)}</a>`;

    const card = (it) => `
      <button type="button" onclick="window.loadView('${it.v}')"
        class="text-left bg-slate-950 border ${it.cfg ? 'border-amber-800/50' : 'border-slate-800'} rounded-xl p-3 hover:border-sky-600 hover:bg-slate-900 transition group">
        <div class="flex items-center justify-between gap-2">
          <span class="text-sm font-semibold text-slate-100">${esc(it.t)}</span>
          <span class="text-xs text-sky-400 opacity-0 group-hover:opacity-100 transition">Abrir →</span>
        </div>
        <p class="text-[11px] text-slate-400 mt-1 leading-snug">${esc(it.d)}</p>
        ${it.cfg ? '<span class="inline-block mt-1.5 text-[9px] uppercase tracking-wider text-amber-500">configuración</span>' : ''}
      </button>`;

    const seccion = (s) => `
      <section id="idx-${s.ancla}" class="scroll-mt-4">
        <h3 class="text-sm font-semibold ${s.config ? 'text-amber-400' : 'text-sky-400'} mb-2 border-b border-slate-800 pb-1">${esc(s.grupo)}</h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2.5">
          ${s.items.map(card).join('')}
        </div>
      </section>`;

    cont.innerHTML = `
      <p class="text-xs text-slate-400 mb-3 max-w-2xl">Acceso directo a todas las pantallas. Las marcadas <span class="text-amber-400">en ámbar</span> son de configuración.</p>
      <div class="flex flex-wrap gap-1.5 mb-4">${SECCIONES.map(chip).join('')}</div>
      <div class="flex flex-wrap gap-2 mb-5">
        ${DOCS.map((d) => `<a href="${d.href}" target="_blank" rel="noopener" class="text-xs bg-slate-800 hover:bg-slate-700 text-sky-300 border border-slate-700 px-3 py-1.5 rounded-lg">${esc(d.t)}</a>`).join('')}
      </div>
      <div class="space-y-6">${SECCIONES.map(seccion).join('')}</div>`;
}
