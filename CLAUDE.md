# Hares de México — guía para trabajar en este repo

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

## Última sesión

- Archivos tocados (lo último): `js/tareas.js`, `version.json`. A petición del usuario ("falta un botón de
  cancelar tarea, porque a veces será necesario cancelar cualquier tarea si ya se atendió por otro medio"):
  nuevo botón "🚫 Cancelar" en CADA tarea de "Tareas de almacén" (inventario bajo mínimo y caducidad próxima
  por igual — antes las de "comprar" no tenían ninguna forma manual de cerrarse, y "✔ Atendida"/"✕ No
  aceptada" no encajaban con "ya se resolvió por otro medio"). No fue necesaria ninguna migración: el RPC
  `public.tarea_resolver` (`sql/2026-09-06_tareas_sistema.sql`) ya soportaba la acción `'archivar'` desde que
  se creó (comentario original: "Se marcan Atendida / No aceptada (posponer) / No aplica (archivar)"), solo
  nunca se conectó a un botón. Con confirmación + motivo opcional, llama `resolverTarea(btn, 'archivar', ...)`.
  Diferencia clave con "No aceptada" (posponer): "Cancelar" no programa un reaviso a N días — pero tampoco
  apaga la alerta para siempre, si la condición que la generó sigue viva el sincronizador
  (`tareas_sync_inventario` / el de caducidad) la vuelve a crear sola en el siguiente evento (movimiento de
  stock, o el job diario de pg_cron 07:15) — mismo comportamiento que ya tenían los productos que dejan de
  estar bajo mínimo. Las tareas archivadas ya aparecían correctamente en "Historial de tareas" (`ESTATUS_
  LABEL`/`ESTATUS_BADGE` ya traían 'archivada': 'Archivada'), no se tocó. Pendiente: probar en el navegador —
  cancelar una tarea de "Comprar: …" y una de caducidad, confirmar que aparecen en el Historial como
  "Archivada" y que si la condición sigue (stock sigue bajo mínimo) vuelve a aparecer como pendiente.
- Archivos tocados (lo último): `js/catalogo.js`, `js/documentos.js`, `js/ordenes-compra.js`,
  `js/pedidos-venta.js`, `js/trazabilidad.js`, `js/requisiciones-compra.js`, `js/ordenes-produccion.js`,
  `version.json`. Bug reportado con captura: al abrir "Editar artículo" con Ctrl+clic teniendo ya abierta
  "Ver artículo" del mismo producto, la nueva subventana se quedaba en "Cargando..." para siempre. Causa
  raíz: el contenedor exterior de cada subventana sí recibía un id único (`window.idSubventana`), pero los
  ids INTERNOS del `innerHTML` de la plantilla (botones, campos, el div de contenido) seguían siendo el
  mismo literal en las dos instancias, y el código que después los llenaba los buscaba con
  `document.getElementById('idInterno')` (global) en vez de escoparlos a SU modal — con dos instancias
  abiertas, esa búsqueda global siempre resuelve al primer elemento del DOM (la instancia vieja), dejando a
  la nueva con sus propios elementos nunca tocados. Se auditaron una por una TODAS las funciones que usan
  `window.idSubventana` (la lista completa de la convención de Subventanas) y se corrigió cada
  `document.getElementById('xxx')` que apuntara a un id definido dentro de esa misma plantilla, cambiándolo
  a `modal.querySelector('#xxx')` (o la variable de closure ya existente: `cuerpo`, `cont`, `host`, `area`).
  Alcance real, por archivo: `catalogo.js` (`abrirResumenCompletoProducto` — 7 sitios — y `abrirTablaDensidades`/
  `abrirTablaUnidades` — 6 sitios más; `abrirVentanaBom` ya estaba bien); `ordenes-compra.js`
  (`abrirDetalleOC`/`renderEdicionOC` — ~25 sitios, incluye el formulario completo de edición de la OC);
  `requisiciones-compra.js` (`abrirDetalleReq`, `reqEditar`, `reqAutorizar` — ~20 sitios entre los tres);
  `pedidos-venta.js` (`pvPintarDetalle`/`pvAbrirSurtir` — de paso corrigió un bug real independiente: el botón
  "Cancelar pedido" llamaba `modal.remove()` sin que `modal` existiera en ese scope, `ReferenceError` en cada
  clic); `trazabilidad.js` (`abrirAntecedentes` — 2 sitios); `ordenes-produccion.js` (`abrirDetalle`, el botón
  Imprimir pasaba un id fijo `'opDocEstado'` a `imprimirConPlantilla`, que busca por id global). Bug hermano
  encontrado de paso en `documentos.js`: `window.imprimirDocumentoActual` leía un solo `docActualParaImprimir`
  global (no por instancia) — con 2 documentos abiertos, imprimir el primero después de haber cargado el
  segundo imprimía el CONTENIDO correcto (ese sí ya iba por id único) pero con el TÍTULO/tipo de plantilla del
  segundo; ahora es un `Map` por `idModal`. Mismo patrón aplicado también donde `imprimirConPlantilla` recibía
  un id fijo (`ordenes-compra.js`/`requisiciones-compra.js`): se le da al div de contenido un id único por
  instancia (`xxx__<idModal>`) antes de imprimir. Confirmados SIN este bug (ya estaban bien escopados):
  `abrirVentanaBom` (catálogo), `rcVerPoliza` (contabilidad.js), `abrirManual` (asistente-contable.js),
  `abrirDetalleDocumentoGlobal`/`cerrarDetalleDocumento` (documentos.js), `abrirDetalleDocumento` (kardex.js),
  `modalFaltantesProd` (produccion.js). Pendiente: probar en el navegador con 2-3 subventanas Ctrl+clic
  abiertas a la vez del mismo registro — sobre todo Editar artículo/Ver artículo de catálogo (el caso
  reportado), Editar/Autorizar requisición, y el botón Imprimir de OC/Requisición/Orden de producción con dos
  documentos abiertos.
- Archivos tocados (lo último): `js/catalogo.js`, `js/subventanas-movibles.js` (nueva capacidad:
  `window.idSubventana`), `js/documentos.js`, `js/kardex.js`, `js/contabilidad.js`, `js/enlaces-reporte.js`,
  `js/ordenes-produccion.js`, `js/auxiliar-inventarios.js`, `js/auxiliar-anticipos.js`, `js/produccion.js`,
  `js/ordenes-compra.js`, `js/pedidos-venta.js`, `js/trazabilidad.js`, `js/requisiciones-compra.js`,
  `js/asistente-contable.js`, `CLAUDE.md`, `version.json`. Dos pedidos del usuario (con captura):
  (1) "Editar artículo" de una Materia prima mostraba "Rendimiento del lote" — no aplica (esa materia prima/
  insumo es COMPONENTE de la fórmula de un granel, no tiene su propia fórmula/BOM): ahora ese campo se oculta
  para todo lo que no sea `tipo = 'semiterminado'` (antes solo se ocultaba para "Producto terminado"), tanto en
  "Editar artículo" (`camposOcultosPorTipo`) como en el formulario de Alta (`bloqueProdRendimientoLote`);
  Densidad sigue igual (si aplica a materia prima/insumo). (2) "Que Ctrl+clic en cualquier enlace abra una
  subventana aparte, sin ocupar una ya desplegada" — ver la nueva convención en "Subventanas" arriba
  (`window.idSubventana`, un solo mecanismo compartido) y la lista de qué se tocó ahí. De paso, dos bugs reales
  encontrados al hacerlo: `js/asistente-contable.js` (`abrirManual`) y `js/contabilidad.js` (alta rápida de
  proveedor) buscaban su botón "×" con `document.getElementById` (global) en vez de `ov.querySelector` (scoped
  al modal) — con dos instancias abiertas, el "×" de la segunda no cerraba nada (buscaba en la primera); el de
  `asistente-contable.js` se corrigió de paso (aparece en cualquier pantalla vía "📖 Cómo llenar esta
  pantalla"); el de `contabilidad.js` (`gaApX`) se dejó igual a propósito (ese modal no se tocó, ver la
  convención). Pendiente: probar Ctrl+clic en varios de los enlaces tocados (Ver póliza, Abrir documento,
  Editar artículo, Editar o ver BOM, manual) — sobre todo abrir DOS documentos o DOS pólizas a la vez y
  confirmar que cada una imprime/cierra la suya, no la del otro. Probar también que Rendimiento del lote ya
  no aparece para Materia prima/Insumo, en Alta y en Editar artículo.
- Archivos tocados (lo último): `js/catalogo.js`, `CLAUDE.md`, `version.json`. Bug reportado con captura (dos
  subventanas abiertas a la vez para el mismo producto): al usar "Usar 10 Kilogramos como Rendimiento del lote"
  en "🧪 Editar o ver BOM" (`abrirVentanaBom`), la "Revisión del granel" de "✏️ Editar artículo"
  (`abrirResumenCompletoProducto`), ya abierta detrás, se quedaba con el dato viejo (4 de 5 ⚠) aunque BOM ya
  lo había guardado — cada subventana solo refrescaba el formulario de Alta (`window.refrescarFormularioSi
  EsProducto`, ya existía), nunca a las otras dos. Se agregaron `window.refrescarBomSiEsProducto` (dentro de
  `abrirVentanaBom`) y `window.refrescarResumenSiEsProducto` (dentro de `abrirResumenCompletoProducto`, se
  resuelve re-llamando a la función completa con los mismos parámetros — ya reconstruye todo el modal), mismo
  patrón `if (typeof window.X === 'function') await window.X(id)` que el existente. Los 3 puntos donde se
  guarda Densidad/Rendimiento del lote de un semiterminado (Alta al guardar, BOM "Guardar" y sus botones
  rápidos "Usar X", Editar artículo "Guardar cambios") ahora llaman a los OTROS dos refrescos — cada subventana
  sigue sin refrescarse a sí misma (ya está fresca). Nota: la tabla "⚖️ Densidades" (edición rápida por fila)
  no quedó conectada a esto — mismo tipo de hueco, pero el usuario no lo reportó; pendiente si hace falta.
  Pendiente: probar en el navegador con las 2-3 subventanas abiertas a la vez para el mismo producto.
- Archivos tocados (lo último): `js/produccion.js`, `js/tareas.js`, `CLAUDE.md`, `version.json`. Bug de
  duplicidad reportado por el usuario (con captura de "Tareas de almacén"): cuando una orden de producción
  dispara sola una requisición de lo faltante (`generarRequisicionFaltantes`, al guardarse como "pendiente por
  insumos"), no revisaba si ya había una Tarea de almacén pendiente ("Comprar: …") pidiendo ESE mismo insumo —
  se podía terminar pidiendo dos veces lo mismo (la tarea, sin resolver, y la requisición de la orden). Ahora
  `generarRequisicionFaltantes` busca en `tareas` (accion_sugerida='crear_orden_compra', estatus pendiente/
  pospuesta) por cada insumo faltante y liga su `tareaId` a la partida — mismo mecanismo que ya existía para
  "Generar requisición" desde Tareas (`js/requisiciones-compra.js` ya marca 'atendida' la tarea ligada al
  GUARDAR la requisición, sin tocar ese archivo). Esto también resolvió el pedido de "que se marque atendida
  si genero la requisición desde Tareas" — YA estaba implementado (por eso no se tocó `requisiciones-compra.js`).
  Además, a petición del usuario ("que no pueda marcar como atendida si no genero una requisición"): en
  "Tareas de almacén" las tareas de comprar (`crear_orden_compra`) ya NO tienen botón "✔ Atendida" — se
  reemplazó por texto fijo "No atendida" (se resuelve sola al guardar su requisición); las de caducidad
  (`revisar_lote`) conservan su botón, porque esas no se resuelven con una requisición. "✕ No aceptada"
  (posponer) se dejó igual para todas. Pendiente: probar en el navegador con un caso real (una orden de
  producción cuyo faltante ya tenga una Tarea de almacén pendiente) y confirmar que la tarea desaparece de
  la lista al guardar la requisición generada desde Producción.
- Archivos tocados (lo último): `js/subventanas-movibles.js`, `CLAUDE.md`, `version.json`. A petición del usuario
  ("las 3 opciones: estirar desde una esquina y maximizar y restaurar") se implementó lo que la sesión anterior
  había dejado solo anotado como pendiente: manija en la esquina inferior derecha (`data-subventana-resize`,
  arrastre libre con mínimo 260×160px) + botón "⤢"/"⤡" en la barra de título (`data-subventana-maximizar`, busca
  la fila `.flex.justify-between` en vez del "asa" de arrastrar, que a veces es solo el texto del título) que
  maximiza a casi pantalla completa y restaura. El tamaño/posición original de cada panel se captura una sola vez
  (la primera vez que se toca, con un `WeakMap`) y "Restaurar" siempre vuelve a ESE, sin importar cuántos estirones
  a mano haya habido de por medio. Al maximizar también se reubican `top`/`left`/`transform` (no solo
  ancho/alto/`translate`) porque las subventanas flotantes que se autoposicionan (ej. "Editar o ver BOM", `top:
  8vh; left: 50%; transform: translateX(-50%)`) se salían de la pantalla si solo se agrandaban sin reubicarlas;
  las que centra su overlay (`flex items-center justify-center`) no necesitan eso, se recentran solas. Mismo
  mecanismo automático que "movibles" (MutationObserver + `panelDe()`), sin tocar ningún módulo. Pendiente:
  probar en el navegador (mouse y dedo) en varias subventanas — sobre todo una flotante (BOM) y una con overlay
  (Editar artículo / Documento) — y confirmar que el botón "⤢" no quede visualmente raro si la fila de título
  tiene más de 2 elementos.
- Archivos tocados (lo último): `js/catalogo.js`, `CLAUDE.md`, `version.json`. En "✏️ Editar artículo" de un
  granel (semiterminado), la Unidad de Medida vive más abajo en el formulario (`ORDEN_CAMPOS_PRODUCTO`) que
  Densidad y Rendimiento del lote — el usuario reportó (con captura) que tenía que scrollear para saber en
  qué unidad estaba capturando esos dos campos. Nuevo banner `rcUnidadDeclarada`, justo antes del campo
  Densidad ("📏 Unidad de medida preseleccionada: **X**..."), que se actualiza solo (`pintarGranel`) si cambian
  Unidad de Medida, Tipo, Rendimiento o Cuenta — mismo patrón que la guía/análisis que ya estaban ahí. También
  se agregó a Convenciones (`CLAUDE.md`) la regla "subventanas siempre expandibles/contraíbles" (a petición del
  usuario) — **solo quedó documentada, no implementada todavía** (candidato: ampliar
  `js/subventanas-movibles.js`, mismo mecanismo automático que "movibles"). Pendiente: probar el banner nuevo
  en el navegador; programar expandir/contraer cuando el usuario lo pida (requiere su propio plan, toca todas
  las subventanas).
- Archivos tocados (lo último): `index.html`, `js/catalogo.js`, `js/kardex.js`, `js/app.js`, `js/indice.js`,
  `version.json`. A petición del usuario ("cuando estoy dando de alta un artículo, lo único que vea en la
  pantalla sea el menú de acciones para lograrlo" + fusionar Kardex con el Catálogo general "porque
  prácticamente se están haciendo lo mismo"): se separó "Alta de artículo" (`cargarModuloAltaArticulo`,
  vista nueva `alta-articulo`, solo el formulario — antes vivía junto al listado en la misma pantalla
  `catalogo`) de "Catálogo y Kardex" (`cargarModuloCatalogoKardex`, sigue en la vista `catalogo`): el
  listado general de artículos con el Kardex fusionado — ☰ "Kardex de este producto" ya no navega a otra
  pantalla, despliega los movimientos en un panel debajo de la tabla, en la misma pantalla
  (`mostrarKardexInlineProducto` → `kardex.js` `renderizarKardexProducto`, parametrizado por producto en
  vez de tener su propio buscador). Kardex se quitó del menú "Inventario y almacén" (a petición del
  usuario, "solo en catálogos por lo pronto") — vive solo dentro de "Catálogos" ahora. Se conservó tal
  cual la función de "Alta de artículo" de editar por nombre (autocompletado ya la traía) — no se tocó,
  solo se movió de pantalla. `window.abrirDetalleDocumento`/`cerrarDetalleDocumento` de `kardex.js` (modal
  de documento que usa esa tabla) se dejaron intactos. Pendiente: probar en el navegador — Alta de
  artículo (crear y editar por nombre), Catálogo y Kardex (buscar/exportar/☰ y el panel de Kardex
  inline con su filtro por lote), y que el menú/Índice apunten bien a las dos pantallas nuevas.
- Archivos tocados (lo último): `index.html` (cajón), `js/indice.js`, `js/app.js`, `js/tareas.js`, `version.json`.
  Reacomodo completo del menú (a petición del usuario, "no siento que esté bien acomodado ni intuitivo"): antes 5
  grupos colapsables + "Documentos" suelto, con "Operación" y "Finanzas" escondiendo 3-4 sub-bloques de texto no
  clicables cada uno (16 pantallas en un solo desplegable). Ahora 9 grupos parejos, sin sub-bloques ocultos:
  **Catálogos** (antes "Datos Maestros"), **Compras** (Requisiciones/OC/Recibo/**Compra directa** —antes "Compras /
  Proveedores", chocaba con el nombre de "Proveedores"—/Entradas directas), **Inventario y almacén** (Stock/Kardex/
  Auditoría/**Tareas de almacén**, nuevo), **Ventas** (Pedidos de venta/Salidas/Devoluciones — se separó de
  Inventario), **Producción** (subió a grupo propio), **Documentos** (solo), **Finanzas — operación diaria**
  (Gastos/CxP/CxC/Bancos/Nómina/Activos fijos/Prorrateo/**Tareas contables**, nuevo), **Contabilidad y control**
  (nuevo: junta Pólizas + lo que antes era "Fiscal" + "Configuración contable" — Pólizas ya no vive enterrado bajo
  "Nómina y cierre de mes"), **Reportes** (Reportes operativos —antes solo "Reportes", se distingue de "Reportes
  contables"— + Bitácora de cambios), **Configuración** (General/Plantillas/Fresh start). "Tareas" se dividió por
  origen real de los pendientes (`js/tareas.js` ya los separaba internamente: tabla `tareas` = almacén vs. nómina en
  borrador/recordatorio = contable): `cargarModuloTareas(departamento)` acepta `'almacen'`/`'contable'`/vacío
  (todas) y `window.loadView('tareas', {departamento:'...'})` desde cada menú; banner "Viendo solo tareas de
  X — Ver todas" cuando hay filtro. `js/indice.js` (SECCIONES) actualizado igual, mismo orden/nombres, con `extra`
  para pasar el departamento en las tarjetas de Tareas. Pendiente: probar el menú y ambos accesos de Tareas en el
  navegador. **Ojo, hallazgo aparte sin resolver**: el CSS de `index.html` trae el comentario "cajón lateral...
  sin riel de iconos", pero la convención de este archivo dice "Nav: riel de iconos + cajón — no revertir a
  sidebar plano" — el riel parece haberse perdido en algún punto; no se tocó esta sesión, solo se deja anotado.

- Archivos tocados (lo último): `sql/2026-10-27_anticipo_proveedores.sql` (nuevo), `js/ordenes-compra.js`, `version.json`.
  Bug reportado: "Recibir mercancía" siempre generaba póliza de Egreso, hasta en compras a crédito (nunca hay salida real
  de banco ahí — debería ser Diario). Causa: `contabilizar_compra()` traía `'tipo', 'Egreso'` fijo. Ampliado a un módulo
  completo de **Anticipo a proveedores** (el usuario paga la OC 7 días antes de recibir la factura — flujo real, sin
  soporte hasta ahora): cuenta nueva `109.01` Anticipos a proveedores; `pagos_proveedor_aplicaciones` gana tipos
  `anticipo_oc` (el pago, ligado a la OC) y `anticipo_aplicado` (su rastro al consumirse en una recepción, con candado
  de integridad); RPC `pagar_anticipo_oc()` (Cargo 109.01/Abono banco, Egreso); `contabilizar_compra()` reescrita para
  **siempre** reconocer el pasivo COMPLETO en 201.01 al recibir (nunca lo salta, así el proveedor no desaparece de su
  auxiliar aunque el neto sea $0) y cancelarlo por la vía que corresponda: anticipo disponible de esa OC, luego banco si
  se paga ahí mismo, resto a crédito si sobra. Tipo de póliza ya NO depende del combo Contado/Crédito: Egreso solo si
  ESA póliza abona banco por algo, si no Diario. `cancelar_pago_proveedor()` no deja cancelar un anticipo ya aplicado a
  una recepción; `cancelar_recibo_inventario()` libera el anticipo si se cancela esa recepción. Vista `v_anticipos_oc`
  (pagado/aplicado/disponible por OC) + botón "💰 Anticipo" en Órdenes de compra (visible en `abierta`/`recibida_parcial`,
  antes de recibir) con badge del saldo disponible. 3 escenarios (anticipo 100%, parcial+crédito, parcial+resto contado) simulados y probados en Postgres
  local con números reales — cuadran cargo=abono y el tipo de póliza sale correcto en los tres. Nueva regla en
  Convenciones: toda propuesta de contabilidad debe apegarse a NIF, no solo "que cuadre". Completado en la misma sesión
  (a petición del usuario, "no dejes nada pendiente"): `js/trazabilidad.js` — "🔗 Antecedentes de proceso" ahora inserta
  un paso "Anticipo(s) pagado(s) — antes de recibir" entre la Orden de compra y la Recepción (monto, fecha, póliza,
  disponible/aplicado), solo si la OC tiene alguno. `js/auxiliar-anticipos.js` (nuevo) — pestaña "Auxiliar de Anticipos
  a proveedores" en Reportes contables (`js/contabilidad.js`): lista cada anticipo por proveedor (OC, póliza, pagado,
  aplicado con el documento al que se aplicó, disponible, estatus) + "Cuadre" contra el saldo real de 109.01 en la
  balanza (mismo patrón que el Auxiliar de inventarios). También se agregó `sql/2026-10-28_diagnostico_migraciones_
  pendientes2.sql` (solo lectura, continúa a `…10-16_…`) para verificar qué migraciones de 2026-09-24c en adelante ya
  están corridas — corrido por el usuario: solo faltó `sql/2026-10-27_anticipo_proveedores.sql` (nueva, todavía sin correr) y
  ya se corrigió el nombre del archivo (nació como `2026-09-25_…`, mal ubicado en la cronología del repo; se renombró a
  `2026-10-27_…` y se actualizaron sus referencias). Corrección post-mortem: la migración fallaba en Supabase con
  "cannot drop columns from view" — la sección 9 reescribía `v_cuentas_por_pagar` copiando la versión vieja (10 columnas,
  `sql/2026-09-02_...`) en vez de la vigente (12 columnas: `poliza_id`/`estatus_cxp`, `sql/2026-09-10c_...`, que
  `js/pagos-proveedor.js` y `js/ordenes-compra.js` ya usan) — además esa "corrección" no hacía falta: la vista vigente
  ya resuelve los cancelados con `estatus_cxp='cancelado'` (filtrable, no oculto). Se quitó esa sección por completo;
  vuelto a probar en Postgres local, cuadra igual. **Migración corrida y confirmada** (diagnóstico "TODO AL DÍA").
  Pendiente: probar el botón "💰 Anticipo" + Recibir mercancía (tipo de póliza), "🔗 Antecedentes de proceso" y el
  Auxiliar de Anticipos a proveedores en el navegador, con un caso real.
- Archivos tocados (lo último): `js/catalogo.js`. En "Editar artículo" (editor genérico) y en el formulario de alta/edición,
  Densidad, Rendimiento del lote y Requiere caducidad se ocultan cuando el Tipo es Producto terminado (no aplican: el
  granel ya llega en la unidad que pide su BOM). Clave SAT de "Claves de proveedor": si se deja vacía, toma la del
  producto (arriba) en vez de volver a preguntarla; solo se escribe aparte si ese proveedor la reporta distinta.
  Pendiente: probar en el navegador, "comitea" cuando se apruebe subir.
- Archivos tocados (lo último): `js/catalogo.js`, `version.json`. Catálogo no abría ("Cannot access 'ultimoResForm' before
  initialization"): `sincronizarAbastecimiento()` corre al abrir y usaba la variable antes de su `let`; se subió la
  declaración junto a `productoSeleccionadoId`. Pendiente: que el usuario recargue (Ctrl+Shift+R si sigue).
- Archivos tocados (lo último): `js/bienvenida.js`, `js/iconos-accesos.js` (nuevo), `js/indice.js` (exporta `SECCIONES`),
  `css/bienvenida.css`, `sql/2026-09-24c_accesos_directos_usuario.sql` (nuevo). Inicio con accesos rápidos personalizables
  por usuario: "✎ Personalizar accesos" → agregar/editar (pantalla de la lista del Índice, título, subtítulo, ícono de una
  galería de ~50 íconos por categoría), quitar, reordenar con ◀ ▶ y "↺ Restablecer los de siempre". Se guardan en
  `accesos_directos_usuario` (una fila por usuario, jsonb, RLS por `auth.uid()`); sin la tabla o sin red quedan en
  `localStorage` (`hares_accesos_<uid>`) y se avisa. Máx. 12. Pendiente: correr la migración y probar en el navegador.
- Ajuste local (`js/produccion.js`): la etiqueta "CANTIDAD A PRODUCIR" del formulario de orden muestra la unidad del
  producto (Litros, Kilos, Piezas…) y la nota de abajo la repite en los graneles con tandas. Pendiente: subir con "comitea"
  (y correr `python3 actualizar-version.py`).
- Archivos tocados (lo último): `js/conversion-unidades.js`, `js/catalogo.js`. Densidad del granel automática: `tamanoTeoricoTanda`
  devuelve `densidadCalculada` (kg/L de la mezcla, 3 dec.; solo si ≥1 insumo trae densidad; los que no, como agua →
  `densidadFaltante`). `htmlDensidadMezcla` la muestra en el análisis 🧮 con botón "Usar X kg/L como Densidad". Alta/edición
  del Catálogo y "✏️ Editar artículo": el campo se llena solo si está vacío o conserva el último calculado (`dataset.auto`);
  escrito a mano se respeta. "Editar o ver BOM": al guardar, si el granel no tiene densidad se guarda sola. SOLO
  semiterminados (el terminado no la necesita: quien lo consume ya lo pide en su unidad). Cambiarla a mano (alta, Editar
  artículo, ⚖️ Densidades) pide `confirmarCambioDensidad`: cómo se calculó (insumo × densidad = kg, total ÷ L) y por qué no
  conviene; si no confirma, regresa a la calculada; si confirma, `dataset.manual` y ya no se llena sola. Pendiente: probar.
- Archivos tocados (lo último): `js/enlaces-reporte.js` (nuevo: `linkDoc`/`linkPoliza`), `js/documentos.js`, `js/contabilidad.js`,
  `activos-fijos`, `compras`, `entradas`, `salidas`, `cuentas-por-cobrar`, `pagos-proveedor`, `devoluciones`, `trazabilidad`,
  `pedidos-venta`, `tareas`, `ordenes-compra`. Auditoría "documentos y pólizas se abren desde el reporte": `verPolizaDeDocumento`
  (todos los botones "Ver póliza") ya NO navega a Pólizas, abre `rcVerPoliza` en subventana; "Abrir documento" dentro de la
  póliza tampoco navega; `window.zSubventanaSiguiente()` pone la nueva encima de las abiertas. Folios enlazados en historiales
  de Compras/Entradas/Salidas, CxC, CxP (compras), Devoluciones (+ póliza), Activos fijos (póliza), Trazabilidad (REQ/OC).
  Pedidos de venta: solo `tipo = 'producto'`. Desde = día 1 del mes / Hasta = hoy por default en CxC, CxP (con aviso de
  pendientes fuera del rango + "Ver todas las fechas"), historial de Recibo de mercancía (antes 7 días) e Historial de tareas.
  Sin enlazar a propósito: la tabla dinámica de `reportes.js` (el folio es agrupador). Pendiente: probar en el navegador.
- Archivos tocados (lo último): `sql/2026-09-24_tipo_semiterminado.sql` y `sql/2026-09-24b_quitar_es_semiterminado.sql`
  (nuevos), `sql/…23e`/`…23f` (usan tipo), `js/catalogo.js`, `produccion.js`, `ordenes-produccion.js`, `importador-bom.js`,
  `importador.js`, `inventario.js`, `auxiliar-inventarios.js`, `auditoria-inventario.js`, `reportes.js`, `salidas.js`, manual.
  Semiterminado ya es un TIPO: `productos.tipo = 'semiterminado'` (antes `producto` + `es_semiterminado`). Se elige con
  su botón en el alta y en "✏️ Editar artículo" → "Tipo"; lo que "se fabrica" = `producto` o `semiterminado`; un granel
  NO se vende (Salida por Venta solo `producto`); sin cuenta → 115.02. Migración 1 amplía la regla de `tipo`, convierte los
  fabricados marcados o con "granel" en el nombre (por nombre solo la 1.ª vez), 115.02 si no hay existencia, y un trigger
  puente mantiene `es_semiterminado` hasta el paso 2. Probado en Postgres local. Pendiente: correr la 1, publicar, correr la 2.
- Archivos tocados (lo último): `js/subventanas-movibles.js` (nuevo), `js/app.js` y los 3 módulos de operador (lo importan),
  fondos de subventanas en `asistente-contable`, `catalogo`, `contabilidad`, `documentos`, `kardex`, `ordenes-compra`,
  `recibo-operador`, `salidas`. Todas las subventanas se arrastran desde su barra de título (mouse y dedo) sin tocar cada
  módulo: un MutationObserver detecta `div.fixed.inset-0` (panel = primer hijo) y `div.fixed.rounded-2xl` flotantes; se
  mueven con CSS `translate`, quedan 60 px a la vista y el clic al soltar no las cierra. Fondos opacos (`/80` + blur,
  `bg-black/70`) → `bg-slate-950/40`. Excluir una: `data-no-movible`. Probado en Chromium. Pendiente: probar en el celular.
- Archivos tocados (lo último): `js/produccion.js`, `js/app.js`, y texto de `js/catalogo.js`, `js/ordenes-produccion.js`,
  `js/importador-bom.js`, `js/conversion-unidades.js`, `js/bienvenida.js`, `manual-costos-produccion.html`.
  Orden sugerida de granel sin tanda redonda: la pregunta ya no es subventana, va en "EXISTENCIAS PARA ESTA PRODUCCIÓN"
  (`#preguntaTandaBOM`, `mostrarPreguntaTanda`) con tanda completa marcada por defecto. F5 reabre la misma pantalla
  (`iniciarApp` lee `history.state.erpVista`; no recupera lo capturado). En la UI "receta" → "fórmula" (variables igual;
  el importador de BOM acepta encabezado "receta" o "fórmula"). Pendiente: probar en el celular.
- Archivos tocados (lo último): `sql/2026-09-23e_graneles_revision.sql` (solo lectura) y `sql/2026-09-23f_graneles_aplicar.sql`
  (nuevos). Aplica a todos los graneles con BOM (nombre "granel" o semiterminado, unidad de volumen/peso): semiterminado +
  fabricado, `rendimiento_lote_bom` = suma de la receta (misma cuenta que 🧮) y cuenta 115.02 solo si no tiene existencia.
  Probado en Postgres local. Pendiente: que el usuario corra primero la revisión y luego la aplicación; los que tengan
  existencia en otra cuenta necesitan póliza de reclasificación.
- Archivos tocados (lo último): `js/catalogo.js` — en "✏️ Editar artículo" la casilla "Es semiterminado (granel)" va
  justo después de "Tipo" (`ORDEN_CAMPOS_PRODUCTO`), antes quedaba al final.
- Archivos tocados (lo último): `js/catalogo.js`, `manual-costos-produccion.html` — explicación de por qué importa el
  "Rendimiento del lote" aunque la MP se descuente a costo real (la receta decide cuánto se gasta; el rendimiento, entre
  cuántos litros se reparte y cuántos hay): pista en el formulario y en "Editar artículo", enlace desde el análisis 🧮 y
  nueva sección del manual `#m-granel-rendimiento` (cómo se arma un granel + tabla 15 vs 14.64 L).
- Archivos tocados (lo último): `js/catalogo.js` — "🧪 Revisión del granel" (`htmlGuiaGranel`) arriba de "✏️ Editar
  artículo" (si es semiterminado o el nombre dice "granel") y de "🧪 Editar o ver BOM": ✅/⚠ por punto con qué hacer —
  semiterminado, unidad (L/kg), BOM, rendimiento vs. suma de la receta, densidades, piezas en la receta, cuenta 115.02
  (solo en Editar artículo; avisa reclasificación si ya hay existencia). Se recalcula al editar los campos.
- Archivos tocados (lo último): `js/catalogo.js`, `js/ordenes-compra.js`, `js/pedidos-venta.js`, `js/requisiciones-compra.js`,
  `js/trazabilidad.js`. "Usar X como Rendimiento del lote" cerraba "Editar artículo": el recuadro se re-dibuja, el botón
  tocado sale del DOM y `cerrarFuera` lo tomaba como clic fuera. Ahora `cerrarFuera` ignora nodos desconectados
  (`e.target.isConnected`) en todas las subventanas con ese patrón, y el botón hace `stopPropagation`.
  El análisis 🧮 en "Editar artículo" ahora va justo debajo del campo "Rendimiento del lote" (antes al final).
- Archivos tocados (lo último): `cargador.js`, `version.json`, `actualizar-version.py` (nuevos), `index.html` y las 3 apps de
  operador, `js/app.js`, `js/conteo-inventario.js`. El celular seguía con los .js viejos en caché tras publicar: las
  páginas ya no cargan su módulo directo, sino `cargador.js` → lee `version.json` sin caché → import map que pide cada
  `js/*.js?v=<versión>`. `app.js`/`conteo-inventario.js` arrancan aunque el DOM ya esté listo.
- Archivos tocados (lo último): `js/catalogo.js` — "✏️ Editar artículo" (menú ☰, el editor genérico por columnas) no
  tenía pistas: nombres legibles (`ETIQUETAS_CAMPO_PRODUCTO`), pista bajo cada campo clave (`PISTAS_CAMPO_PRODUCTO`:
  tipo, unidad, densidad, rendimiento, semiterminado…) y el análisis 🧮 del tamaño de la tanda con botón que llena
  "Rendimiento del lote" (se guarda con "Guardar cambios").
- Archivos tocados (lo último): `js/produccion.js`, `js/ordenes-produccion.js`, `sql/2026-09-23d_rendimiento_real_orden.sql`
  (nuevo). `cerrarOrdenDeProduccion(id, cantidadReal)` acepta lo realmente obtenido (insumos por lo planeado, al inventario
  lo real, costo = total ÷ real) — el usuario pidió NO preguntarlo al cerrar: el botón cierra con lo planeado. Al cerrar, `cantidad_producida` = REAL y
  `cantidad_planeada` = lo pedido (así `contabilizar_produccion` y el prorrateo de CIF, que dividen entre
  `cantidad_producida`, ya usan lo real sin reescribirlos). "Estado de la orden" muestra planeado/obtenido/% merma y la
  receta sobre lo planeado. Pendiente: correr `sql/2026-09-23d_rendimiento_real_orden.sql` (sin ella cierra con lo real
  pero no guarda lo planeado).
- Archivos tocados (lo último): `js/catalogo.js`, `js/produccion.js` — pistas explicativas para dar de alta un granel:
  "Unidad de Medida" (granel en Litros/Kilogramos, nunca Pieza), "Densidad (kg por litro)", "Rendimiento del lote (para el
  BOM)" (litros de UNA tanda; ej. Fresa Kiwi 15), aviso en "Editar o ver BOM" (receta por tanda / por 1 unidad / falta
  rendimiento) y en "CANTIDAD A PRODUCIR". Producción: si el producto tiene `rendimiento_lote_bom`, aparece "TANDAS A
  PREPARAR" (default 1) y "CANTIDAD A PRODUCIR" se llena sola = tandas × rendimiento (y al revés); la orden sigue guardando
  la cantidad en la unidad del producto. Pendiente: `rendimiento_lote_bom` vacío en Granel Aceite Sey Piña Colada (id 232)
  y revisar los demás graneles.
  Análisis "🧮 Tamaño real de la tanda" (`tamanoTeoricoTanda` en `js/conversion-unidades.js`): suma la receta de un
  semiterminado llevando cada insumo a la unidad del granel con su densidad (sin densidad = agua, se avisa; piezas se
  ignoran), compara contra "Rendimiento del lote" y ofrece "Usar X como Rendimiento del lote" — en el formulario del
  Catálogo (bajo la lista del BOM) y en "Editar o ver BOM" (ahí guarda directo). Fresa Kiwi da 14.64 L (capturado 15).
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

- `app.js` — router de vistas (`window.loadView`, con historial del navegador: ← / → entre pantallas; F5 se queda en la pantalla) + shell de
  navegación (riel de iconos + cajón) y exposición de funciones al `window` para los `onclick` del HTML.
- `areas-prorrateo.js` — declara m²/kW/personas por área para derivar los % de prorrateo de gastos compartidos.
- `asistente-contable.js` — panel de ayuda colapsable ("¿Cómo llenar esta pantalla?") reutilizado por
  varios módulos + el asistente de captura de Gastos.
- `activos-fijos.js` — activos fijos y depreciación (NIF C-6, línea recta): catálogo + corrida mensual con póliza.
- `auditoria-inventario.js` — auditorías de inventario (toma física) lado admin: crear, ver avance/resultado,
  cerrar/reabrir (la captura la hace el operador en `conteo-inventario.html`).
- `auxiliar-anticipos.js` — Reportes contables → "Auxiliar de Anticipos a proveedores": cada anticipo pagado a una
  OC antes de recibir (pagado/aplicado/disponible, con el documento al que se aplicó) + cuadre contra la cuenta 109.01.
- `auxiliar-inventarios.js` — Reportes contables → "Auxiliar de inventarios (valorizado)": kardex valorizado por
  artículo/clasificación/cuenta + cuadre contra la balanza de cada cuenta de inventario.
- `auth.js` — login del admin (los empleados no pasan por aquí) + bitácora de inicio/cierre de sesión.
- `bancos-tesoreria.js` — cuentas bancarias ligadas a cuenta contable, conciliación y flujo proyectado simple.
- `bienvenida.js` — pantalla de Inicio: saludo, nombre del usuario y accesos rápidos personalizables por usuario
  (tabla `accesos_directos_usuario`, respaldo en el navegador).
- `iconos-accesos.js` — galería de íconos de línea (por categoría) para los accesos rápidos de Inicio.
- `bitacora-cambios.js` — consulta de la bitácora de movimientos (quién/cuándo/qué cambió) de todo el negocio.
- `buscador-select.js` — convierte un `<select>` largo en un buscador con teclado, sin cambiar su comportamiento.
- `catalogo.js` — dos pantallas separadas: `cargarModuloAltaArticulo` ("Alta de artículo", solo el
  formulario: alta/edición por nombre, clasificación, BOM) y `cargarModuloCatalogoKardex` ("Catálogo y
  Kardex", el listado general con ☰ acciones, export Excel/CSV, tabla de Densidades y de Unidades de
  medida, y el panel de Kardex embebido al elegir un artículo).
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
- `enlaces-reporte.js` — `linkDoc`/`linkPoliza`: folio o póliza como enlace que abre su subventana (regla de reportes);
  todo `[data-pol-id]` se rotula solo como "Egreso #34" (tipo + número, consulta en lote), nunca el id interno.
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
- `kardex.js` — `renderizarKardexProducto`: movimientos de un producto, embebidos en el panel de
  "Catálogo y Kardex" (`js/catalogo.js`); ya no tiene vista ni buscador propios. También trae
  `window.abrirDetalleDocumento`/`cerrarDetalleDocumento` (modal de documento usado por esa tabla).
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
- `subventanas-movibles.js` — hace arrastrables TODAS las subventanas (detección automática, sin llamar nada desde
  cada módulo); se importa en `app.js` y en las 3 apps de operador.
- `supabase.js` — cliente y credenciales de Supabase.
- `tareas.js` — bandeja de pendientes (inventario bajo mínimo, caducidad próxima, nómina en borrador...) con historial.
- `trazabilidad.js` — antecedentes de proceso: Requisición → Orden de compra → Documento(s) de recepción.

## Convenciones

- **Selects** siempre desde la tabla real de Supabase, nunca hardcodeados.
- **Migraciones SQL**: idempotentes (`if not exists`, `create or replace`), envueltas en `begin;`/`commit;`.
  Nunca se edita una ya corrida — se agrega una nueva. Se pegan a mano en Supabase → SQL Editor.
- **Push a GitHub** solo cuando el usuario dice "comitea" (cualquier forma), y siempre directo a `main` (así lo pidió el usuario). El repo local NO está
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
- **Pólizas se muestran como tipo + número** ("Egreso #34", el consecutivo por tipo), NUNCA con el id interno global
  (`polizas.id`): en enlaces usar `linkPoliza` / `data-pol-id` y en mensajes `etiquetaPoliza()` (`js/enlaces-reporte.js`).
- **Contabilidad y NIF**: toda propuesta o cambio relacionado con contabilidad (pólizas, cuentas, tipo Ingreso/Egreso/Diario,
  cuándo se reconoce un pasivo vs. cuándo sale efectivo, anticipos, etc.) debe apegarse a los principios de contabilidad y
  las NIF — no solo "que cuadre" en pantalla. Si hay duda de criterio, decirlo explícito antes de proponer, no asumir.
- **Cancelar = contra-asiento**: una póliza cancelada sigue contando para saldos junto con su reverso (se neutralizan);
  nunca filtrar solo `estatus = 'contabilizada'` al sumar saldos — usar `enSaldo` (`js/polizas-saldo.js`) o
  `poliza_en_saldo()` en SQL.
- **Reglas de integridad en la base, no solo en pantalla**: lo que protege saldos/existencias (ej. no recibir más de lo
  pedido, `cantidad_recibida` derivada de documentos) va como trigger/constraint; la pantalla solo avisa antes.
- **Versión de los .js**: en cada commit que toque `js/` correr `python3 actualizar-version.py` (regenera `version.json`,
  que usa `cargador.js`); si no, los navegadores pueden seguir con los archivos viejos en caché. Un módulo nuevo en
  `js/` entra solo a la lista al regenerar.
- **Subventanas (modales)** — aplica a TODAS las que se generen en cualquier proceso (nuevas y existentes), para que
  el usuario pueda analizar la información de la pantalla que la originó:
  - **Nunca ocultar el contenido que originó la subventana**: la pantalla de atrás sigue visible detrás (overlay
    semitransparente, no un fondo opaco que la tape por completo). Abrir una subventana no cierra, re-dibuja ni
    navega fuera de la pantalla de origen.
  - **Siempre movibles**: se arrastran desde su barra de título (mouse y touch en el celular) a cualquier parte de la
    pantalla, sin salirse por completo del área visible, para destapar lo que haya detrás. Un solo mecanismo
    reutilizable para todas (`js/subventanas-movibles.js`, automático); si una subventana abre otra, cada una se
    mueve por su cuenta. Fondo: `bg-slate-950/40`, sin `backdrop-blur`.
  - **Siempre estirables (esquina) y maximizables/restaurables** (a petición del usuario 2026-09-25): manija en la
    esquina inferior derecha para estirar el panel a mano (ancho y alto libres, con mínimo), y botón "⤢" en la
    barra de título que maximiza (casi pantalla completa) y restaura el tamaño original con el mismo botón ("⤡").
    Mismo mecanismo automático que "movibles" (`js/subventanas-movibles.js`, sin tocar cada módulo): el tamaño
    original de cada panel se guarda la primera vez que se toca (estirón o maximizar) y "Restaurar" siempre
    regresa a ESE, aunque de por medio haya habido un estirón a mano. Las subventanas flotantes que se
    autoposicionan (`top`/`left`/`transform`, ej. "Editar o ver BOM") también se reubican al maximizar para no
    salirse de la pantalla; las que centra su overlay (`flex items-center justify-center`) se recentran solas al
    cambiar de tamaño.
  - **Ctrl/Cmd + clic en el enlace/botón que la abre = ábrela aparte** (a petición del usuario 2026-09-25): no
    reusa/reemplaza la que ya esté abierta — se abre una instancia independiente, con su propio id. Un solo
    mecanismo compartido: `window.idSubventana('idDeSiempre')` (`js/subventanas-movibles.js`) regresa el id de
    siempre en un clic normal, o uno nuevo único si hubo Ctrl/Cmd al hacer clic (un listener global en captura
    ya lo sabe para cuando el `onclick` corre). Cada función que abre una subventana lo usa para decidir el id
    de su contenedor (y de cualquier id interno que se busque por `document.getElementById` en vez de por
    referencia directa al elemento — ojo ahí, es la parte fácil de pasar por alto). Ya aplicado a las que abren
    algo por un enlace/botón "ver": `abrirDetalleDocumentoGlobal`/`cerrarDetalleDocumento` (`js/documentos.js`,
    ahora la única definición — la de `js/kardex.js` se quitó, quedaba pisada porque documentos.js carga
    después), `rcVerPoliza`/`rcCerrarModalPoliza` (`js/contabilidad.js`), `abrirManual` (`js/asistente-contable.js`),
    y los modales de `js/catalogo.js` (BOM/Editar artículo/Densidades/Unidades), `js/produccion.js`,
    `js/ordenes-compra.js`, `js/ordenes-produccion.js`, `js/pedidos-venta.js`, `js/trazabilidad.js` y
    `js/requisiciones-compra.js`. A propósito sin tocar: el modal genérico `rmModalWrap` de
    `js/ordenes-compra.js` (helper de bajo nivel con muchos llamadores, no una sola función "abrir X") y
    `gaAltaModal` de `js/contabilidad.js` (alta rápida, no es un enlace a algo existente) — y las 3 apps de
    operador (pantallas táctiles, Ctrl+clic no aplica ahí). Cualquier subventana nueva que abra un enlace/botón
    "ver algo" debe usar `window.idSubventana` igual que las de arriba.

## Estado del proyecto (módulos clave)

- Contabilidad de doble entrada + SAT + compras ligada; fases avanzadas ya corridas (prorrateo CIF, costeo
  PEPS/FEFO, landed cost). Reportes contables: Balanza, Estado de resultados, Balance general y **Auxiliar
  de cuentas contables** (saldo inicial + movimientos + saldo final; selector de UNA cuenta -padre trae
  sus hijos, de detalle solo ella- o "Todas las cuentas", sin desde/hasta).
- Clasificación de productos: `productos.tipo` (producto / semiterminado / materia_prima / insumo) + `abastecimiento`
  (fabricado/comprado; semiterminado siempre fabricado). `es_semiterminado` quedó obsoleta (se borra con
  `sql/2026-09-24b_…`). Vista `v_productos_bom`. En Catálogo: botones Producto terminado/Semiterminado/Materia
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

- Semiterminado como tipo: TERMINADO (verificado 2026-09-23): migración 1, código en `main`, `…24b` (columna `es_semiterminado`
  borrada) y `…23f` (graneles de aceite en 14.64 L, 115.02) corridos. Ids 232 y 254 (Aceite Sey Piña Colada/Chocolate)
  corregidos a semiterminado (verificado). Pendiente: Granel Love Oil Fresa Kiwi (id 227) quedó en 7.99 L: su fórmula tiene solo 3 componentes, completarla. Al crear graneles
  nuevos, volver a correr revisión `…23e` + aplicar `…23f` (o usar "🧪 Revisión del granel").
- Verificado 2026-09-23 en la base: corridas todas las migraciones de 2026-09-22 y 2026-09-23 (`…23d` no, es opcional).
  Documentos vacíos de los cierres fallidos (ids 22-25, PROD-000001/-MP y PROD-000002/-MP) marcados `cancelado` (no
  borrados, para dejar rastro y que no bloqueen el candado de cierre de septiembre).
- Graneles en Kilogramos: el usuario confirmó que sus terminados los consumen en GRAMOS → no hace falta la densidad del
  granel (solo la de los insumos que la receta pida en L/mL). Si algún terminado pidiera un granel en mL, capturar la
  densidad del granel (ya se calcula sola de la fórmula; botón "Usar X kg/L como Densidad").
- Los demás graneles de Gel/Miel/Lubricante (Anal Xtasi, Bubblegum, Cherry, Chocolate, Essence, Mango, Mint, Prolongel
  Retardador, Vcream, Watermelon, Miel Bee Power, Lubricante Silicón) no salieron en la revisión: o no tienen BOM o su
  nombre no dice "granel". Cuando tengan receta, se configuran con la revisión ✅/⚠ o con los SQL `…e`/`…f`.
- Evaluar si extender el buscador de selects a otras pantallas (Salidas, Órdenes de compra, alta de BOM).
- Subventanas: ya movibles y con fondo semitransparente todas las detectadas; una nueva queda cubierta sola si usa
  `fixed inset-0` (fondo + panel) o `fixed rounded-2xl` (flotante) y su barra de título es el primer hijo del panel.
