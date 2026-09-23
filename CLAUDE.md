# Hares de México — guía para trabajar en este repo

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

## Última sesión

- Archivos tocados (lo último): `js/polizas-saldo.js` (nuevo), `js/contabilidad.js`, `js/auxiliar-inventarios.js`,
  `js/bancos-tesoreria.js`, `js/ordenes-compra.js`, `sql/2026-09-23_candados_cuadre_inventario.sql` (nuevo),
  `sql/2026-09-23b_diagnostico_cuadre_recepciones.sql` (nuevo, solo lectura). Descuadre 115.01 de (3,435.22): cancelar
  una póliza hace contra-asiento Y marca la original 'cancelada'; los reportes solo sumaban 'contabilizada' → se restaba
  2 veces. Ahora la regla única (`enSaldo` / `poliza_en_saldo()`) cuenta la cancelada CON reverso; el Auxiliar de
  inventarios liga el reverso al movimiento `cancelacion_recibo`. Recibo de mercancía dejaba recibir 2 veces la misma OC
  (sumaba `cantidad_recibida` sobre el dato viejo de pantalla): candado en pantalla + trigger que rechaza exceder lo
  pedido y deriva `cantidad_recibida` de los documentos vivos. Candado nuevo de cierre: kardex vs. balanza por cuenta.
  Probado en Postgres local. Pendiente: correr ambos SQL; cancelar los recibos duplicados de OC-000017/OC-000020
  (Glicerina) que marque el diagnóstico (no el lote AL1541/220926, ya consumido).
- Antes: `js/auxiliar-inventarios.js`, `js/ordenes-produccion.js`, `js/contabilidad.js`,
  `CLAUDE.md` — nueva regla "documentos y pólizas citados en un reporte se pueden abrir desde ahí": en el Auxiliar
  de inventarios el documento y la póliza de cada movimiento (y las pólizas del cuadre) son enlaces; igual en el
  costeo de la orden cerrada (folios PROD-… y póliza). Pendiente: auditar los demás reportes contra la regla.
- Antes: `js/auxiliar-inventarios.js` (nuevo), `js/contabilidad.js` — Reportes contables →
  pestaña "Auxiliar de inventarios (valorizado)": filtros Clasificación / Cuenta de inventario / Artículo (buscador);
  por artículo saldo inicial, movimientos del kardex (documento, póliza, lote, entrada/salida en cantidad y $, saldo
  corriente) y saldo final; valor = |cantidad| × `costo_unitario` del movimiento (trae landed cost y costo PEPS).
  "Cuadre" por cuenta (`cuenta_inventario_id`, sin cuenta → 115.04 si producto / 115.01 si no): kardex de TODOS los
  artículos de la cuenta vs. saldo en balanza a "Hasta", + pólizas que movieron la cuenta sin kardex detrás.
- Antes: `js/app.js` — la flecha ← del navegador sacaba del ERP: `window.loadView(vista,
  { desdeHistorial })` ahora anota cada pantalla con `history.pushState({ erpVista })` y un `popstate` la reabre;
  `iniciarApp` pone un tope (`erpBase`) + Inicio, así ← en Inicio se queda en Inicio. No cierra subventanas
  abiertas ni restaura la pantalla al recargar (F5 → Inicio).
- Antes: `js/produccion.js`, `js/ordenes-produccion.js`. "Historial de Órdenes Cerradas"
  mostraba "No se encontraron movimientos…" porque buscaba los consumos en el documento de ENTRADA y quedan en el de
  SALIDA (`PROD-…-MP`): nuevas `documentosDeOrden` / `consumosDeOrden` (exportadas de `produccion.js`; la orden no
  guarda el documento, se llega por el lote producto+número más cercano a `cerrada_at`). Botón "📄 Reporte
  completo" → `abrirDetalle`; para órdenes cerradas el documento ahora es costeo completo: resumen (MP/MO/%/costo
  unitario vs. orden anterior), materia prima real por lote (costo PEPS, subtotal, receta, diferencia, % MP),
  mano de obra por persona y por proceso (tiempo × `costo_hora_snapshot`, igual que el cierre), documentos y póliza.
- Antes: `sql/2026-09-22_fix_salida_fifo_costo_ambiguo.sql` (nuevo), `CLAUDE.md`. Antes, misma sesión:
  buscadores SAT en Recibo de mercancía, "Fecha esperada" +5 hábiles, pre-recibo en proceso, documento "Estado de la
  orden", requisiciones ligadas a la orden, pendientes por insumos en Producción, conversión sin densidad.
- Qué cambió: "Cerrar orden" fallaba con `column reference "costo_unitario" is ambiguous`. La
  `registrar_salida_fifo` VIVA en la base (costeo PEPS con cursor de capas `stock_costeo`, cambiada fuera de este
  repo — distinta a `sql/2026-09-13_salidas_fefo.sql`) abría el cursor sin alias y chocaba con la columna de
  salida `costo_unitario` del RETURNS TABLE. La migración es copia exacta de la versión viva con solo ese SELECT
  calificado (`lc.`); reproducido y probado en Postgres local. OJO: la fuente de verdad de esa función es ahora
  esta migración, no la de 2026-09-13.
- Pendiente: correr `sql/2026-09-22_fix_salida_fifo_costo_ambiguo.sql`,
  `sql/2026-09-22_factor_conversion_sin_densidad.sql` y `sql/2026-09-22_requisicion_orden_produccion.sql`; cada
  intento fallido de cierre dejó 2 documentos vacíos (`PROD-…-MP` y `PROD-…`) sin movimientos.

## Estructura

- `js/` — un módulo por pantalla del menú (ver `index.html`); `js/app.js` es el router (`window.loadView`).
  Un catálogo que usan dos formularios se exporta desde donde ya vive (ej. `REGIMENES` en `js/proveedores.js`),
  no se duplica.
- `sql/` — migraciones fechadas (`AAAA-MM-DD_descripcion.sql`), idempotentes, no las corre la app.
- `css/` — `tema-base.css` (paleta de temas + remapeo slate/acento, compartida por `index.html` y las 3 apps
  de operador), `ui-moderno.css` (botones 3D, paneles, 10 temas: 6 originales + aurora/sunset/neon/ocean),
  `doc-tema.css` (el manual y la guía siguen el tema elegido), `bienvenida.css`.
- Páginas sueltas: `index.html` (app admin), `orden-trabajo.html` / `recibo-operador.html` /
  `conteo-inventario.html` (operador vía celular, PIN o patrón), `manual-costos-produccion.html` (manual
  completo — cada pantalla lo abre con "📖 Cómo llenar esta pantalla"), `guia-costos-produccion.html`.
- `ejemplos/` — plantillas de importación (Excel/CSV) + su LEEME.

## Mapa de módulos (`js/*.js`)

- `app.js` — router de vistas (`window.loadView`, con historial del navegador: ← / → entre pantallas) + shell de
  navegación (riel de iconos + cajón) y exposición de funciones al `window` para los `onclick` del HTML.
- `areas-prorrateo.js` — declara m²/kW/personas por área para derivar los % de prorrateo de gastos compartidos.
- `asistente-contable.js` — panel de ayuda colapsable ("¿Cómo llenar esta pantalla?") reutilizado por
  varios módulos + el asistente de captura de Gastos.
- `activos-fijos.js` — activos fijos y depreciación (NIF C-6, línea recta): catálogo + corrida mensual con póliza.
- `auditoria-inventario.js` — auditorías de inventario (toma física) lado admin: crear, ver avance/resultado,
  cerrar/reabrir (la captura la hace el operador en `conteo-inventario.html`).
- `auxiliar-inventarios.js` — Reportes contables → "Auxiliar de inventarios (valorizado)": kardex valorizado por
  artículo/clasificación/cuenta + cuadre contra la balanza de cada cuenta de inventario.
- `auth.js` — login del admin (los empleados no pasan por aquí) + bitácora de inicio/cierre de sesión.
- `bancos-tesoreria.js` — cuentas bancarias ligadas a cuenta contable, conciliación y flujo proyectado simple.
- `bienvenida.js` — pantalla de Inicio: saludo, nombre del usuario y accesos rápidos.
- `bitacora-cambios.js` — consulta de la bitácora de movimientos (quién/cuándo/qué cambió) de todo el negocio.
- `buscador-select.js` — convierte un `<select>` largo en un buscador con teclado, sin cambiar su comportamiento.
- `catalogo.js` — catálogo de productos: alta/edición, clasificación, BOM, tabla de Densidades y de
  Unidades de medida, export Excel/CSV.
- `centros-costo.js` — centros de costo para prorrateo de CIF: capacidad normal en horas y variables del cálculo.
- `cfdi.js` — lector de CFDI: XML (confiable) y PDF (mejor esfuerzo, sin namespaces).
- `cierre-periodo.js` — cierre de periodo contable: revisa los 8 candados antes de cerrar un mes, permite reabrir.
- `clientes.js` — clientes + listas de precio.
- `compras.js` — compra directa con póliza cuando no se pasa por Orden de compra → Recibo de mercancía.
- `conteo-inventario.js` — app móvil de operador: conteo físico a ciegas por auditoría abierta (PIN/patrón).
- `contabilidad.js` — plan de cuentas, pólizas, gastos y reportes (Balanza/Estado de resultados/Balance
  general/Auxiliar de cuentas contables); la pestaña "Auxiliar de inventarios (valorizado)" vive en
  `auxiliar-inventarios.js`.
- `conversion-unidades.js` — conversión BOM↔inventario compartida (familias de unidad + densidad) entre
  Producción y Catálogo.
- `cuentas-por-cobrar.js` — cobros a clientes: ventas a crédito con saldo pendiente y registro del cobro.
- `devoluciones.js` — devoluciones de cliente y a proveedor, con su efecto de inventario y póliza propia.
- `documentos.js` — expediente de todos los documentos del sistema, imprimible, cancelación de recibos.
- `empleados.js` — catálogo de empleados.
- `entradas.js` — entradas directas de inventario sin compra de por medio (ajuste, inventario inicial...).
- `folios.js` — folios consecutivos por serie asignados por la base.
- `fresh-start.js` — diagnóstico para el reset de datos de prueba; nunca borra, solo muestra el SQL a pegar a mano.
- `importador-bom.js` — importa/exporta la estructura del BOM (recetas) desde Excel/CSV.
- `importador-claves-proveedor.js` — carga masiva de "Claves de proveedor" leyendo facturas XML viejas.
- `importador.js` — importador de productos desde Excel/CSV (upsert por SKU).
- `impresion.js` — motor genérico de impresión con plantillas (encabezado/logo/pie).
- `indice.js` — índice/mapa de todos los módulos del ERP con acceso directo.
- `info-proveedor-producto.js` — cómo identifica y vende un proveedor específico un producto (SKU/descr./unidad
  + última compra real).
- `inventario.js` — stock general por producto y lote, con mínimos y deterioro de inventario (NIF C-4).
- `isr.js` — tabla ISR versionada (tarifas de retención sobre sueldos) + extracción desde PDF/OCR.
- `kardex.js` — navegación directa al Kardex de un producto específico.
- `nomina.js` — nómina: cálculo (IMSS/ISR real vía RPC), autorización, póliza y recibo imprimible.
- `orden-tabla.js` — ordenamiento client-side reutilizable para encabezados de tabla en toda la app.
- `polizas-saldo.js` — regla única de qué pólizas cuentan para saldos (contabilizadas + canceladas con su reverso);
  la usan Reportes contables, Auxiliar de inventarios y Bancos. Espejo SQL: `poliza_en_saldo()`.
- `orden-trabajo.js` — app móvil del operario: registro de tiempos por proceso de una orden de producción;
  componentes/lotes a surtir vienen de la vista `v_ot_orden_componentes` (misma conversión que Producción).
- `ordenes-compra.js` — Órdenes de compra + Recibo de mercancía (candado de pre-recibo, landed cost,
  XML/PDF/QR del CFDI, FIFO).
- `ordenes-produccion.js` — consulta de TODAS las órdenes de producción (pendiente por
  insumos/en proceso/cerrada/cancelada); las 'borrador' (pendientes por insumos, ver
  `generarOrdenDeProduccion` en `produccion.js`) se revisan y continúan (o cancelan) desde aquí.
  "👁 Detalle" = documento imprimible "Estado de la orden de producción" (insumos en vivo, lotes,
  tiempos, requisiciones ligadas); si está cerrada, costeo completo por materia prima, persona y proceso
  (también desde Producción → Historial → "📄 Reporte completo").
- `pagos-proveedor.js` — pagos a proveedores: compras/gastos a crédito con saldo pendiente y registro del pago.
- `patron-login.js` — login por patrón (además de PIN) compartido por las 3 apps de operador.
- `pedidos-venta.js` — pedidos de venta que se surten después (total o en partes), enlazados a la salida real.
- `plantillas.js` — configuración de plantillas de impresión (logo, colores, encabezado/pie) por tipo de documento.
- `presentaciones-proveedor.js` — presentaciones de compra del proveedor (millar/gruesa/tambo...) y su factor
  a la unidad interna.
- `produccion.js` — órdenes de producción: BOM, procesos, requerimientos con conversión por densidad,
  generador de lote sugerido, cierre y costo. Si al generar faltan insumos, la orden no se pierde: se
  guarda como `estado: 'borrador'` (pendiente por insumos) con procesos/equipo ya capturados y el
  detalle de lo que faltó en `faltantes_insumos` — se retoma desde `ordenes-produccion.js`.
  `calcularRequerimientosProduccion` también soporta BOM "por lote completo" (`productos.rendimiento_lote_bom`,
  ver Catálogo → Más detalles → "Rendimiento del lote"): si el producto lo tiene capturado, la cantidad
  pedida se traduce a "cuántos lotes de la receta" antes de escalar cada insumo, en vez de multiplicar la
  receta directo por la cantidad (que sobre-pedía ~15× en los "Granel ... 15 Litros", cuyo BOM está escrito
  para el lote de referencia y no para 1 unidad).
- `proveedores.js` — catálogo de proveedores + catálogo `REGIMENES` (SAT) reutilizado por otros módulos.
- `prorrateo.js` — prorrateo de CIF a las órdenes de producción por horas de mano de obra, con póliza de traspaso.
- `recibo-operador.js` — app móvil del operador: captura del pre-recibo (fotos, conteo) que el admin valida después.
- `reparto-plantillas.js` — plantillas de reparto de gastos compartidos (qué base usar y a qué cuenta va).
- `reportes.js` — 3 reportes canónicos (compras por proveedor, gastos por cuenta, inventario valorizado) +
  tabla dinámica genérica.
- `requisiciones-compra.js` — requisiciones de compra (a mano, desde Tareas o desde "Faltantes para producir"),
  autorización → Orden de compra real.
- `salidas.js` — salidas de inventario (venta/merma/ajuste) con FEFO y póliza de ingreso si es venta.
- `state.js` — estado global simple compartido (insumos/productos/historial de producción cacheados).
- `supabase.js` — cliente y credenciales de Supabase.
- `tareas.js` — bandeja de pendientes (inventario bajo mínimo, caducidad próxima, nómina en borrador...) con historial.
- `trazabilidad.js` — antecedentes de proceso: Requisición → Orden de compra → Documento(s) de recepción.

## Convenciones

- **Selects** siempre desde la tabla real de Supabase, nunca hardcodeados.
- **Migraciones SQL**: idempotentes (`if not exists`, `create or replace`), envueltas en `begin;`/`commit;`.
  Nunca se edita una ya corrida — se agrega una nueva. Se pegan a mano en Supabase → SQL Editor.
- **Push a GitHub** solo cuando el usuario dice "comitea" (cualquier forma). El repo local NO está
  conectado a git: se sube con un script temporal que usa la API de GitHub (blob→tree→commit→PATCH ref);
  el token nunca se guarda y el script se borra justo después de usarlo. GitHub Pages (URL principal) +
  Netlify (respaldo) despliegan solo desde `main`.
- Responder siempre en español.
- Optimizar tokens: mínima verificación rutinaria, mínimos subagentes salvo investigación amplia real.
- Nombres de UI en las respuestas = texto literal verificado en el código, sin parafrasear.
- Nav: riel de iconos + cajón (☰ abre, 📌 fija) — no revertir a sidebar plano.
- **Al cerrar una sesión de trabajo importante, actualizar este archivo** con un resumen breve (no un
  historial detallado) de módulos nuevos/cambiados y pendientes.
- **Antes de modificar cualquier función**: grep de dónde se usa, reportar qué archivos se ven afectados y
  mostrar el plan de cambios — no aplicar nada hasta que el usuario lo apruebe.
- **Al terminar cada tarea**: actualizar "Última sesión" (abajo) con 3 líneas — archivos tocados, qué
  cambió en cada uno, qué quedó pendiente — y mantener al día el "Mapa de módulos".
- **Unidades de compra vs. surtido**: por estandarización de procesos, el usuario compra en una unidad y
  surte/formula en otra (compra en kg y la receta en mL, o al revés). Toda cantidad de BOM se convierte a la
  unidad de inventario (`factorConversion` / `factor_conversion_bom`) — nunca comparar números crudos entre
  unidades distintas; la densidad (Catálogo → ⚖️ Densidades) es la que da precisión volumen↔masa.
- **Documentos y pólizas citados en un reporte SIEMPRE se pueden abrir desde ahí**: todo folio de documento
  (OC-…, PROD-…, REC-…) y todo número de póliza que muestre un reporte o documento va como enlace que abre su
  detalle en subventana sin salir del reporte — documento → `window.abrirDetalleDocumentoGlobal(id)`
  (`js/documentos.js`), póliza → `window.rcVerPoliza(id)` (`js/contabilidad.js`). Si el reporte ya vive en una
  subventana, subir el `z-index` de la nueva (ver `lnkDoc`/`lnkPol` en `ordenes-produccion.js`).
- **Cancelar = contra-asiento**: una póliza cancelada sigue contando para saldos junto con su reverso (se neutralizan);
  nunca filtrar solo `estatus = 'contabilizada'` al sumar saldos — usar `enSaldo` (`js/polizas-saldo.js`) o
  `poliza_en_saldo()` en SQL.
- **Reglas de integridad en la base, no solo en pantalla**: lo que protege saldos/existencias (ej. no recibir más de lo
  pedido, `cantidad_recibida` derivada de documentos) va como trigger/constraint; la pantalla solo avisa antes.
- **Subventanas (modales)**: nunca ocultar el contenido que originó la subventana — la pantalla de atrás
  debe seguir visible detrás (overlay semitransparente, no un fondo opaco que la tape por completo).

## Estado del proyecto (módulos clave)

- Contabilidad de doble entrada + SAT + compras ligada; fases avanzadas ya corridas (prorrateo CIF, costeo
  PEPS/FEFO, landed cost). Reportes contables: Balanza, Estado de resultados, Balance general y **Auxiliar
  de cuentas contables** (saldo inicial + movimientos + saldo final; selector de UNA cuenta -padre trae
  sus hijos, de detalle solo ella- o "Todas las cuentas", sin desde/hasta).
- Clasificación de productos: `productos.tipo` + `abastecimiento` (fabricado/comprado) + `es_semiterminado`
  (granel). Vista `v_productos_bom`. En Catálogo: botones Producto terminado/Semiterminado/Materia
  prima/Insumo; BOM editable en ventana propia (☰ → "Editar o ver BOM") y visible en "Ver artículo".
- Cálculo de necesidades de producción (`calcularRequerimientosProduccion`, `js/produccion.js`) convierte
  por la unidad de cada renglón del BOM vs. la unidad de inventario del insumo: misma familia (g/kg, mL/L)
  exacto; familias distintas (BOM en volumen, inventario en peso o al revés) usa `productos.densidad_kg_l`
  si está capturada (Catálogo → Más detalles → "Densidad"), si no, 1 a 1 con aviso. Las recetas se dejan en
  volumen a propósito (más práctico en planta) — no se reescriben en peso. Migración
  `sql/2026-10-23_densidad_conversion_bom.sql` agrega la columna y siembra ~15 densidades de referencia
  (agua, glicerina, propilenglicol, sorbitol, siliconas, fenoxietanol, alcohol, tensoactivos,
  trietanolamina, betaína, sorbato de potasio, lidocaína); saborizantes/colorantes/aromas se capturan a
  mano si aplica (varían demasiado entre marca y lote). `js/conversion-unidades.js` centraliza la lógica
  (`factorConversion`), usada por `produccion.js` (panel de existencias) y `catalogo.js` (aviso en vivo al
  capturar el BOM: "Receta: X → se descontarán Y"). Catálogo tiene un botón "⚖️ Densidades" (junto a
  Excel/CSV) con tabla buscable/editable de todas las densidades, y "📏 Unidades" con el catálogo de
  unidades de medida (ver/editar nombre y "fraccionable"/agregar nuevas) — requiere
  `sql/2026-10-25_unidades_medida_editable.sql` (RLS de escritura; la tabla ya existía, no la crea
  ningún archivo de este repo).
  (`sql/2026-10-22_bom_granel_kilogramos.sql` fue una alternativa —reescribir el BOM en kg— que no se usó.)
- Folios consecutivos por serie (OC/REQ/PED/DEVCLI/DEVPROV/PROD/VTA/MER/SAL/AJU/ENT) vía `siguiente_folio()`
  / `proximo_folio()` (`sql/2026-10-21...`, `js/folios.js`). Folios previos a esto no se renombran.
- Bitácora de movimientos (`bitacora_cambios`): todas las tablas de negocio + login/logout, con correo del
  usuario, filtros (usuario/módulo/acción/fechas) y export CSV (`sql/2026-10-20...`, `js/bitacora-cambios.js`).
- Login por patrón (además de PIN) en las 3 apps de operador (`sql/2026-10-17...`, `js/patron-login.js`).
- Pantalla de Inicio (`js/bienvenida.js`): logo animado, saludo y accesos rápidos; es la vista de arranque.
- Producción: tarjeta "📋 Órdenes pendientes por insumos" (resumen de las 'borrador').
- Producción: botón "Generar requisición de lo faltante" — abre requisición de compra (agrupada por
  proveedor) y/o órdenes de producción para lo que se fabrica en casa (semiterminados como el granel).
- Buscador reutilizable para `<select>` largos: `js/buscador-select.js` (en uso en Producción y en Recibo de
  mercancía: Uso CFDI / Forma de pago / Método de pago). Si el valor se cambia por código, llamar
  `select.buscadorRefrescar()`.
- Producción: número de lote sugerido automático al abrir el formulario (`generarLoteSugerido`,
  `js/produccion.js`) con patrón `LotDDDCadMMAA` — `DDD` = día juliano de hoy, `CadMMAA` = mes/año de
  caducidad a 2 años; botón "🎲 Sugerir" para recalcular; campo sigue siendo texto libre editable.
- Selectores de fecha de reportes: Desde = inicio de mes, Hasta = hoy, por default, en todos los módulos
  (auditoría hecha esta sesión; se corrigieron Reportes contables —usaba inicio de año— y Bitácora de
  cambios —no traía default—). Se dejaron sin tocar, a propósito, los filtros que son búsqueda pura sin
  reporte (Cuentas por cobrar/pagar, historial de Recibo de mercancía, Historial de tareas).
- Recibo de mercancía / pre-recibos: "✔ Validar y recibir" sigue marcando el pre-recibo como `validado` de
  inmediato (lo exige el candado del trigger `_candado_recibo_requiere_prerecibo`, no se puede posponer),
  pero la tarjeta ya NO desaparece de "Pre-recibos por validar" hasta que la recepción se complete de
  verdad (nace el documento de entrada) — mientras tanto muestra "📦 Ya validado — falta completar la
  recepción" y el botón "📦 Continuar recepción". Se implementa con `pre_recibos.documento_id` (nullable,
  se llena solo al confirmar la recepción en `rmConfirmar`, `js/ordenes-compra.js`), degrada con gracia si
  la migración no se ha corrido (vuelve al comportamiento anterior). Requiere
  `sql/2026-10-26_prerecibo_documento_id.sql`. Mientras se procesa uno, la lista muestra solo ese
  (`rmPrereciboEnProceso`, botón "↩ Mostrar todos").

## Pendiente

- Correr `sql/2026-09-23c_fix_candado_recibo_redondeo.sql` (`documento_detalles.cantidad` guarda 2 decimales: sin esto el
  candado rechaza recibir exacto 152.015). Ya corridos: `2026-09-23_candados_cuadre_inventario.sql` y el diagnóstico `…b`;
  cancelar en Documentos los recibos duplicados #17 (OC-000017) y #19 (OC-000020), confirmados con el usuario, y
  verificar que el cuadre de 115.01 dé 0.
- Correr `sql/2026-09-22_fix_salida_fifo_costo_ambiguo.sql`, `sql/2026-09-22_factor_conversion_sin_densidad.sql` y `sql/2026-09-22_requisicion_orden_produccion.sql` (las demás de `sql/` ya están corridas, verificado 2026-09-22).
- Capturar "Rendimiento del lote" (Catálogo → Más detalles) en cada producto "Granel ..." cuyo BOM se
  escribió para el lote completo y no por 1 unidad — si no, `calcularRequerimientosProduccion` sigue
  pidiendo insumos de más. El usuario confirmó que sus lotes son de 10-15 Litros según el producto; hay
  que preguntarle el rendimiento exacto de cada uno (no asumir 15 parejo).
- En Catálogo → "⚖️ Densidades", capturar densidad de los "Granel ..." (Gel/Miel/Lubricante, son mezclas
  propias — no hay ficha técnica externa que buscar): Anal Xtasi, Bubblegum, Cherry, Chocolate, Essence,
  Fresa Kiwi, Mango, Mint, Piña Colada, Prolongel Retardador, Vcream, Watermelon, Miel Bee Power,
  Lubricante Silicón. Sabores (Chocolate/Fresa Kiwi/Piña Colada) y Ácido Cítrico se dejaron sin sembrar
  a propósito (varían demasiado) — capturarlos a mano solo si su BOM los usa en volumen y de verdad
  importa la precisión.
- Evaluar si extender el buscador de selects a otras pantallas (Salidas, Órdenes de compra, alta de BOM).
- Pendiente de responder: ¿aplicar también el default Desde=inicio de mes/Hasta=hoy a Cuentas por
  cobrar/pagar, historial de Recibo de mercancía e Historial de tareas? (se dejaron igual, ver arriba).
- Auditar los reportes existentes contra la regla "documentos y pólizas citados se pueden abrir desde ahí"
  (hecho solo en Auxiliar de inventarios y costeo de la orden).
- Revisar las subventanas/modales que ya existen en la app contra la convención nueva ("nunca ocultar el
  contenido que las originó") — no se ha auditado el código todavía, solo se documentó la regla.
