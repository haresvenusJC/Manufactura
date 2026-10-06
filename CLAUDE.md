# Hares de México — guía para trabajar en este repo

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

## Última sesión

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`. **MOQ en la requisición** (a petición del usuario: no pedir solo lo
  que necesita la orden). Aplica a toda requisición precargada (desde orden de producción, pedido o Tareas): `reqCargarCatalogos` trae
  `productos.cantidad_minima_compra`; si el faltante es menor al MOQ, la partida se precarga con el MOQ y guarda `necesario` (lo que pidió la orden).
  Cada partida con producto muestra su aviso (`reqHtmlMoq`): sin MOQ → "⚠ Sin MOQ capturado" + campo y "Guardar MOQ" (escribe en `productos`, sube las
  partidas del mismo producto al MOQ y sigue en la misma requisición, `window.reqGuardarMoq`); cantidad < MOQ → botón "Pedir X" (`reqPedirMoq`);
  ≥ MOQ → "✓ MOQ" con el sobrante. Solo MOQ (sin múltiplos), editable. La cantidad se sigue pudiendo bajar a mano. Sin migración SQL. El MOQ está en la
  unidad de inventario del producto (misma que la partida). Pendiente: probar en el navegador con una orden cuyo faltante sea menor al MOQ y con un
  insumo sin MOQ (capturarlo ahí mismo).
- Archivos tocados (lo último): `js/ordenes-compra.js`, `supabase/functions/tipo-cambio-dof/index.ts` (nuevo),
  `sql/2026-10-06_oc_tipo_cambio.sql` (nuevo), `version.json`. **Tipo de cambio en la OC**: al elegir una moneda
  distinta de MXN, `tipo-cambio-dof` (Edge Function) lee la caja de Indicadores de https://www.dof.gob.mx y llena
  `ocTipoCambio`, que es editable; se guarda en `ordenes_compra.tipo_cambio` con `tipo_cambio_fuente` ("DOF" o
  "captura manual") y `tipo_cambio_fecha`. Si el DOF no responde, el campo queda para captura manual. Pendiente:
  correr `sql/2026-10-06_oc_tipo_cambio.sql`, desplegar la función (`supabase functions deploy tipo-cambio-dof`) y
  probar una OC en USD. Regla de fecha (FIX del día anterior vs del día) pendiente de confirmar con contador.

- Archivos tocados (lo último): `js/pagos-proveedor.js`, `js/ordenes-compra.js`, `js/produccion.js`, `version.json`,
  `sql/2026-10-05_series_3_letras.sql` (nuevo), `sql/2026-10-05_acuerdo_pago_parcial.sql` (nuevo). **Fecha de corte
  2026-10-05.** Series de documentos nuevas: OC→**ODC**, PROD→**ODP** (cierre de producción), DEVCLI→**DCL**,
  DEVPROV→**DPV** (contadores nuevos desde 000001; los folios anteriores no se renombran). Las órdenes de
  producción siguen en OP y las demás series ya eran de 3 letras. **Pagos a proveedores (maqueta v2):** un pago =
  un proveedor (la selección bloquea a los demás); "Pagar selección" abre una ventana con Pago total (saldo, no
  editable) o Pago parcial (un solo documento, monto editable, acuerdo obligatorio); el acuerdo se guarda en
  `pagos_proveedor.acuerdo_proveedor` vía `pago_proveedor_set_acuerdo`. Quitada la columna de monto por fila y el
  bloque superior de cuenta/forma/referencia (ahora están en la ventana). **Pendiente de decisión:** el caso
  anticipo (OC sin recibir) sigue por el botón "💰 Pagar anticipo a una OC" y NO se detecta solo; la "deuda por
  recepción" sigue por revisar. Pendiente: correr ambos SQL en Supabase (en este orden: series, luego acuerdo);
  probar la ventana de pago total y parcial; confirmar que `ODC-000001` sale como primer folio nuevo.

- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario: el formulario "Generar
  Orden de Producción" se compactó — producto, cantidad, tandas y lote con `px-2 py-1 text-xs` (antes `p-2 text-sm`),
  espacios verticales y de tarjeta reducidos. El buscador de producto hereda la clase del select (`buscador-select.js`).
  Sin migración SQL. Pendiente: revisar en el navegador.
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario: se quitó la tabla
  "Historial General de Órdenes" de Producción → Historial (`contenedorHistorialProduccion`, `histProdOrden` y sus
  imports de `orden-tabla.js`). Se conservan el selector por folio, el detalle, 🖨️ Imprimir y "📄 Reporte completo"
  para abrir una orden cerrada. La lista de órdenes sigue en Órdenes de producción. Sin migración SQL.
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario: **cada cambio de centro
  dentro de un proceso cierra una partida** — el centro y sus personas se guardan en `bloques` (estado del proceso),
  y el centro nuevo arranca SIN personas (el usuario pidió no arrastrar la selección anterior). Volver a un centro
  ya guardado lo reabre con sus personas.
  Cada partida es una mini-tarjeta en el RESUMEN DE PROCESOS y se envía como un proceso separado con su
  `centroCostoId` (`recolectarProcesosDefinidos` lee `div.resumenData`). Personas sin centro quedan como
  "Proceso sin centro". Antes, el bloque de resumen: el resumen de PROCESOS (arriba de Generar Orden) ya no es texto sino **mini-tarjetas** por proceso — ícono y color del centro,
  código · nombre y avatares con iniciales de las personas — que se llenan al elegir centro/personas (la data
  viaja en `div.resumenData`, `construirMiniTarjeta()` las arma con DOM, sin HTML de datos del usuario). Antes:
  el resumen de cada proceso ya NO va arriba de la tarjeta — ahora hay un bloque **"RESUMEN DE PROCESOS"** justo arriba de "Generar
  Orden", con una línea por proceso (`ENV · Envasado — Jose, Juan +2`). Cada tarjeta guarda su línea en
  `dataset.resumen` y `actualizarResumenGlobal()` reconstruye el bloque (se llama al pintar, al quitar un
  proceso, al agregar y al limpiar tras guardar). Cada tarjeta conserva solo "✏️ Editar / ▴ Listo" y "✕ Quitar".
  Sin migración SQL. Pendiente: probar en el navegador.
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario (captura: al cambiar
  de centro se perdían las personas marcadas, y el resumen ocupaba mucho espacio): cada proceso ahora guarda su
  selección en un **estado explícito** (`seleccion = {centro, empleados:Set}`) y se pinta desde ahí
  (`pintarProceso`), así cambiar de centro nunca toca a las personas. Los avatares se marcan con un handler
  propio (`preventDefault` sobre el `<label class="avatarEmpleado">`), y los checkboxes ocultos se sincronizan
  desde el estado (siguen siendo lo que lee `recolectarProcesosDefinidos`). Resumen de UNA línea siempre visible
  arriba de cada proceso ("ENV · Envasado — Jose, Juan +2"), con "✏️ Editar" / "▴ Listo" para mostrar u ocultar
  el selector y "✕" para quitar el proceso. Sin migración SQL. Pendiente: probar en el navegador (marcar personas,
  cambiar de centro varias veces, confirmar que las personas se conservan y que la orden guarda bien).
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario (con captura: el
  desplegable de proceso + el ✕ junto a él, más las tarjetas de centro, eran redundantes): **las 4 tarjetas de
  centro son ahora el ÚNICO selector** de cada proceso. Se quitó el `<select>` de proceso del catálogo, su
  "+ Otro proceso" y su ✕ de la fila. Al tocar una tarjeta el nombre del proceso se toma del catálogo
  `procesos_produccion` ligado a ese centro (`centro_costo_id`), o del nombre del centro si ninguno está
  ligado (p. ej. Acondicionamiento). "✕ Quitar proceso" pasó al pie del bloque, junto a "▾ minimizar". Si no
  se elige centro, el proceso se guarda como "Proceso sin centro". Sin migración SQL. Pendiente: probar en el
  navegador que la orden guarda el nombre correcto (Surtido de MP / Mezclado / Envasado) y el centro.
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. Bug/queja reportada con captura (dos
  procesos "Envasado" en la misma orden, cada uno mostrando el grid completo de 4 tarjetas de centro + los
  avatares de equipo): se hacía repetitivo y ocupaba mucho espacio verticalmente con varios procesos. Nuevo
  botón **"▾ Ya elegí — minimizar"** al final del bloque Centro de costo + Equipo de trabajo de cada proceso:
  lo colapsa a una sola línea de resumen ("ENV · Envasado — Jose, Juan, Michelle +2 más") con botón
  "✏️ Editar" para volver a abrirlo. Es manual, no automático (elegido a propósito — auto-colapsar al marcar
  el primer empleado habría estorbado para seguir marcando a los demás). Los checkboxes de empleados y el
  input oculto del centro siguen existiendo tal cual mientras está colapsado (solo `display:none` vía
  `hidden`), así que `recolectarProcesosDefinidos()` no se tocó — sigue leyendo lo mismo sin importar si el
  bloque está minimizado o no. Sin migración SQL. Pendiente: probar en el navegador — minimizar/editar un
  proceso, confirmar que el resumen muestra bien el centro y los nombres, y que "Generar Orden" sigue
  guardando igual con un proceso minimizado.
- Archivos tocados (lo último): `js/ordenes-produccion.js`, `js/produccion.js`, `version.json`. **Cierre automático de órdenes de producción, ENTREGA 1 de 3** (reportado: OP-000011 seguía "en_proceso" aunque los 3
  operadores ya habían pulsado "🏁 Finalizar tarea"; verificado con SQL: los 6 renglones con `finalizado_at` y 0 cronómetros abiertos — por diseño `ot_finalizar` solo cierra el cronómetro y marca la tarea del operador; la orden se cierra
  aparte con `cerrarOrdenDeProduccion`, que descuenta MP PEPS, costea, da entrada al terminado y genera póliza). El botón "🔒 Cerrar orden" SOLO existía en Producción → "⏱️ Órdenes en Proceso". Ahora también: en Órdenes de producción
  (lista, columna Acciones, y 👁 Detalle) para órdenes `en_proceso`, mismo cierre y misma confirmación (`cerrarOrdenDesdeAqui`); y aviso verde "✅ Todas las tareas finalizadas, falta cerrar la orden" cuando cada proceso tiene equipo y TODOS
  tienen `finalizado_at` (`todasLasTareasFinalizadas`, en lista, detalle y tarjeta de Producción). La consulta de la lista ahora trae `finalizado_at`. Probado en Chromium con Supabase simulado (aviso solo en la orden terminada, botón en las 2
  en proceso). **Plan aprobado por el usuario para las entregas 2 y 3 (pendientes):** (2) función SQL atómica `cerrar_orden_produccion(orden_id)` que reproduce el cierre actual (probar en Postgres local con existencias suficientes e
  insuficientes) y `cerrarOrdenDeProduccion` pasa a llamarla (una sola versión del cálculo); (3) cierre AUTOMÁTICO con pg_cron cada 5 min: cierra las órdenes con todas las tareas finalizadas y la última finalización de hace ≥10 min (ventana para que
  un operador reabra su tarea); si algo falta (alguien asignado sin finalizar) NO se cierra sola; si faltan existencias se queda abierta con nota "no pudo cerrarse: faltan X" + Tarea; el trabajo programado no afecta nunca a `ot_finalizar` ni al
  operador. Cierra con lo planeado (como el botón). Pendiente: que el usuario pruebe la entrega 1 (cerrar OP-000011 desde Órdenes de producción) antes de seguir con la 2.
- **EN DISCUSIÓN (solo propuestas, sin código):** dos temas abiertos para retomar. Maquetas privadas (no son pantallas reales): lista y pago de Cuentas por pagar v2 https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi (la v1 y su revisión contable: https://claude.ai/artifact/Y76kgS8aiL775ifwQPmT1c).
  **A) Cuentas por pagar (Finanzas) — ya acordado en la maqueta:** documento = OC autorizada (sin folio de recepción en la lista); columnas Total y Saldo (sin "pagado"); botón siempre "Pagar"; filtros en los encabezados
  (Documento ▾ busca folio de OC, Proveedor ▾, Estatus ▾ con Pendientes/Pendiente/Vencida/Parcial/Pagada/Cancelada/Todas) + solo "desde"/"hasta" arriba; sin columna de alertas; columna "Póliza"; sin enlace de anticipo en la tarjeta de anticipos;
  un pago = un proveedor = un evento; Pago total NO editable (refleja el saldo de la OC), Pago parcial editable y EXIGE escribir el acuerdo con el proveedor (+ evidencia opcional; idealmente la condición se declara en la OC, queda en el tintero);
  visto bueno de quien solicitó solo informativo (después obligatorio, como interruptor en Configuración). Subventana movible vs pantalla completa: la maqueta muestra ambas, falta que el usuario elija. Contabilidad (ya existe, verificado en
  `pagar_anticipo_oc` y `contabilizar_compra`): prepago 100% contra la cotización anexa a la OC = anticipo (Cargo 109.01 / Abono banco, Egreso); al validar el pre-recibo, UNA póliza Diario reconoce Inventario + IVA 118.01 contra 201.01 y cancela
  201.01 contra 109.01 (queda inventario, IVA y banco; Proveedores en cero). La deuda por recepción solo vive en compras a crédito y gastos. La pantalla de pago debe decidir sola entre anticipo (OC sin recibir) y pago de deuda (OC recibida).
  **Nomenclatura de pólizas (propuesta):** serie por origen con 3 letras, además del tipo SAT (Ingreso/Egreso/Diario, que se sigue reportando): BAN = pago por banco (antes "póliza de cheque"), VAE = pago en efectivo a una persona (el usuario renombró VAL→VAE),
  ING = ingresos por depósitos, DIA = cancelaciones/diario, y una serie para consumos de producción (el usuario dijo ODP). La serie saldría de la cuenta de pago (banco→BAN, caja→VAE). Hoy: "Tipo #número" con consecutivo por (tipo, año) y la cancelación
  crea contra-asiento del MISMO tipo (`cancelar_poliza`); no renumerar pólizas viejas. Estandarizar series de documentos a 3 letras (OC→ODC, PROD→ODP, DEVCLI/DEVPROV→3 letras) es solo propuesta. PREGUNTAS ABIERTAS: contado + transferencia como valores por defecto;
  varias OC del mismo proveedor en una sola transferencia; consecutivo de series de póliza por año o continuo; choque de nombre ODP (orden de producción vs póliza de consumos); serie OC vs ODC; "Vence/Vencida" se dejó como en su imagen (sin días de crédito = fecha de la OC).
  Datos que faltarían en la base (propuesta): fecha de vencimiento / días de crédito del proveedor, banco/CLABE/beneficiario del proveedor (con bitácora), UUID del complemento de pago (REP) en compras PPD, estado "observado", visto bueno. Alerta propuesta: pago en
  efectivo > $2,000 no deducible ni IVA acreditable (LISR 27 fr. III / LIVA 5 fr. III; confirmar con contador). DIOT sigue vigente (formato nuevo 2025), se basa en lo pagado por proveedor.
  **B) Producción por pedido (reservas):** analizar un plan de necesidades en cascada en vez de pasos sueltos: Pedido → ODP del terminado (redondeo al lote mínimo, ya hecho) → ODP del granel en tandas ENTERAS → requisiciones de MP/insumos con MOQ y múltiplos,
  agrupadas por proveedor, todo con vista previa que el usuario aprueba. Hallazgos: el MOQ (`productos.cantidad_minima_compra`) solo se usa en Tareas de almacén (`max(MOQ, faltante)`), NO en requisiciones que salen de un pedido o de una orden; hoy "Pregunta de tanda"
  permite medias tandas y "solo lo necesario" (el usuario quiere granel NO fraccionado); el pedido no tiene fecha prometida ni la orden fecha programada; no hay tiempo de fabricación por producto; el disparo por pedido y el disparo por stock mínimo son independientes
  (riesgo de duplicar: pendiente verificar si el mínimo descuenta lo "en camino"). Ejemplo del usuario (AX, mínimo 200, rendimiento 200/lote): 280 − 380 (Mario) → faltan 100 + mínimo 200 = 300 → 2 lotes (400); luego JAvier 150 → quedan 150 < mínimo → nuevo disparo.
  Propuestas: tarjeta por producto terminado (stock, reservado por cliente, en camino, proyectado vs mínimo), estados de orden Solicitada → Lista → En proceso → Terminada/Cancelada con fechas, fecha prometida calculada por la ruta más larga, semáforo de retrasos, prioridad
  por fecha prometida. DECISIONES PENDIENTES: tanda nunca fraccionable o casilla por producto; MOQ solo si el faltante es menor o siempre múltiplos; prioridad de apartado (pedido más antiguo vs fecha prometida). Folios: criterio propuesto = serie por tipo, consecutivo continuo
  asignado por la base, nunca se reutiliza, cancelado conserva folio, hijos heredan el del padre; series sin folio propio: pagos, cobros, nómina, auditoría, recepción/pre-recibo.
- Archivos tocados (lo último): `js/produccion.js`, `version.json`. A petición del usuario ("alguna idea para
  hacer esta selección más ágil e interactiva"), se exploraron 3 variantes en un Artifact de diseño (canvas
  interactivo, no comiteado — solo vive en claude.ai) y el usuario eligió la **Opción B**: en "Procesos y
  equipo de trabajo asignado" (formulario de nueva orden), el `<select>` de **Centro de costo** se reemplazó
  por una cuadrícula de 4 tarjetas con ícono y color propio por código (SURT teal, MEZ violeta, ENV cian/sky,
  ACOND ámbar — cualquier otro código usa un ícono/color genérico, no se oculta) — tocar una la selecciona,
  tocarla de nuevo la quita (vuelve a "sin asignar"); y la lista de checkboxes de **Equipo de trabajo** se
  reemplazó por avatares circulares con iniciales (color cíclico por posición), que se iluminan y marcan con
  un check al tocarlos. Implementado SIN tocar la lógica de guardado: los checkboxes de empleados siguen
  siendo `<input type="checkbox" class="chkEmpleado">` reales (solo ocultos, con `peer-checked:` para el
  estilo), y el centro de costo sigue siendo un `<input type="hidden" class="selectProcesoCentro">` — ambos
  con el mismo `.value`/`:checked` que ya leía `recolectarProcesosDefinidos()`, así que esa función y el envío
  del formulario no se tocaron. Nuevas constantes de módulo en `produccion.js`: `ICONO_CENTRO`/`COLOR_CENTRO`
  (con su versión `_DEFAULT` genérica) y `COLOR_AVATAR`/`inicialesDe()`. Sin migración SQL. Pendiente: probar
  en el navegador — elegir un centro, quitarlo tocándolo de nuevo, marcar/desmarcar empleados y confirmar que
  "Generar Orden" guarda igual que antes.
- Archivos tocados (lo último): `js/centros-costo.js`, `js/produccion.js`, `js/contabilidad.js`,
  `js/reparto-plantillas.js`, `version.json`. Bug reportado con captura: el selector "Equipo de trabajo" de
  Producción (centro de costo por proceso) salía ordenado alfabéticamente por código (`ENV, MEZ, SURT`) en
  vez del orden real del flujo de planta. Nuevo `ordenarCentrosProduccion()` (exportado de
  `js/centros-costo.js`, mapa fijo `{SURT:0, MEZ:1, ENV:2, ACOND:3}` — a petición del usuario se agregó
  Acondicionamiento al final de la secuencia fija, no como comodín alfabético — cualquier otro código fuera
  de estos 4 —como `PROD`— sí queda al final por código) aplicado en los 3 lugares que arman un desplegable
  de centros de costo:
  `js/produccion.js` (Equipo de trabajo, el reportado), `js/contabilidad.js` (Gastos → clasificación
  Indirecto/CIF) y `js/reparto-plantillas.js` (plantilla de reparto). La tabla de administración propia de
  Centros de costo (`js/centros-costo.js`, `cargarModuloCentrosCosto`) NO se tocó a propósito — ya tiene su
  propio ordenamiento por columna (clic en encabezado), no es un selector de opción única. Sin migración SQL.
  Pendiente: probar en el navegador los 3 selectores — confirmar que siempre salen SURT, MEZ, ENV.
- Archivos tocados (lo último): `manual-costos-produccion.html`. A petición del usuario ("revisa que falta de
  actualizar en todos los manuales"): auditoría completa de `manual-costos-produccion.html` contra el menú
  VIGENTE (`index.html`/`js/indice.js`) — venía con la estructura de hace varias reorganizaciones de menú
  atrás. Corregido: 11 referencias literales "Menú → Finanzas → X" que en realidad viven en **Contabilidad**
  (Plan de cuentas, Centros de costo, Áreas y bases de prorrateo, Reparto de gastos compartidos, Pólizas,
  Reportes contables — "Finanzas → Gastos/Prorrateo de gastos" sí seguían correctas, no se tocaron);
  "Compras / Proveedores" → **Catálogos → Proveedores** (Proveedores se movió de grupo hace tiempo); el botón
  "Ver póliza" decía que navegaba a Pólizas — ya no navega, abre una subventana (regla de este CLAUDE.md,
  corregida de paso). Los encabezados de la Parte 8 (guía rápida por módulo) traían nombres de ANTES del
  reacomodo de 9 grupos ("Datos Maestros", "Operación — Compras/Abastecimiento", etc.) — renombrados a los
  grupos vigentes (Catálogos, Compras, Inventario y Ventas, Producción, Documentos, Reportes, Finanzas,
  Nómina y cierre de mes, Configuración); donde un mismo bloque mezcla dos grupos (Inventario+Ventas,
  Finanzas+Contabilidad) se dejó una nota aclaratoria en vez de reordenar el contenido (reordenar bloques
  grandes de HTML a mano es más riesgo del que vale). Se encontraron y documentaron DOS huecos reales nunca
  escritos en el manual: nuevo `<h3>Utilerías</h3>` (los dos importadores vivían bajo "Catálogos" en el texto,
  pero el menú real los movió a Utilerías hace sesiones) y nueva sección **"Accesos para operadores"** (la
  pantalla existe desde hace tiempo — enlaces/QR de las 3 apps móviles — pero nunca tuvo su entrada en el
  manual, porque nació después de escribir esta Parte 8). También se renombró el h4 "General" → **"Temas de
  usuario"** (la sesión de hoy) y se le quitó la mención de los enlaces de operador (ya no viven ahí).
  `guia-costos-produccion.html` se revisó y no tenía ninguna de estas referencias — no necesitó cambios.
  Sin migración SQL. Pendiente: ninguno de código; si el usuario vuelve a reacomodar el menú, repetir esta
  auditoría contra `manual-costos-produccion.html` (Parte 8 especialmente).
- Archivos tocados (lo último): `index.html`, `js/indice.js`. El renombre de "Tema de colores" a "Temas de
  usuario" (sesión anterior) había cambiado el encabezado de la pantalla pero no el ítem **"General"** del
  menú lateral (Configuración) ni el título de su tarjeta en el Índice — a petición del usuario, ambos ya
  dicen **"Temas de usuario"**. Pendiente: ninguno.
- Archivos tocados (lo último): `js/bienvenida.js`, `css/bienvenida.css`. A petición del usuario ("un efecto en
  el casco y en los ojos del casco, algo que se vea muy de película"), en el logo de Inicio (`.bv-disco`,
  `img/HARES_icono_tinta.svg`): **brillo de poder** que respira sobre todo el casco (`filter: drop-shadow`
  pulsando en el acento del tema), **dos "ojos" que encienden** con parpadeo tipo arranque de máscara de
  película (`bv-ojo-i`/`bv-ojo-d`, `mix-blend-mode: screen`, con bloom) y un **barrido de luz diagonal**
  tipo escaneo/holograma sobre el disco (`bv-escaneo`). El SVG no tiene una forma de "ojo" propia (es un
  trazo abstracto sin hueco dedicado) — la posición de los dos brillos (`left: 40%`/`54%`, `top: 51%` sobre
  `.bv-disco`) es una ESTIMACIÓN visual sobre dónde cae la ranura del visor, no viene de coordenadas reales
  del SVG; si no caen justo sobre los ojos del casco, ajustar esos `left`/`top` en `css/bienvenida.css`.
  Respeta `prefers-reduced-motion` (apaga las 3 animaciones nuevas, deja los ojos fijos a media opacidad).
  Sin migración SQL. Pendiente: que el usuario revise en el navegador si los dos brillos caen sobre los ojos
  del casco o hace falta correr el `left`/`top`.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `js/indice.js`, `orden-trabajo.html`,
  `recibo-operador.html`, `conteo-inventario.html`, `css/doc-tema.css`. A petición del usuario: nuevo tema
  **Mac (oscuro)** (`data-theme="macos-dark"`, tarjeta en Configuración, junto a "Mac (claro y sencillo)") —
  misma estética plana y sobria (sin degradados, sin botones 3D, esquinas de 9 px, menú lateral translúcido),
  en la paleta oscura de sistema de macOS: fondo gris carbón `#1c1c1e`, tarjetas `#2c2c2e`, acento azul de modo
  oscuro `#0a84ff`, verde/rojo/naranja de sistema en su variante oscura. Mismo mecanismo que los demás temas
  (`data-tema` del botón → `data-theme` global, genérico, sin lista fija en JS). También a petición del
  usuario, la sección/tarjeta se renombró de **"Tema de colores" a "Temas de usuario"** (encabezado en
  Configuración, subtítulo de la tarjeta del Índice, y los comentarios de referencia en las 3 apps de
  operador y en `css/doc-tema.css`). Sin migración SQL. Pendiente: probar el tema nuevo en el navegador
  (sobre todo contraste de texto y la transparencia del menú lateral sobre fondo oscuro).
- Sesión de sincronización (sin archivos de producto; vía API de GitHub desde Claude Code, carpeta local sin
  git). El usuario pidió sincronizar GitHub con los últimos cambios locales ("sincroniza con github, todos
  los últimos cambios que hice desde Claude Code"). Al comparar el árbol local contra `main` se detectó que
  GitHub ya tenía 9 commits del día con trabajo real hecho por **otra sesión de Claude Code en la nube,
  trabajando directo contra GitHub** (nunca pasó por esta carpeta local): tema **Mac (claro y sencillo)**,
  **Lote mínimo de fabricación**, **Reservas de inventario para pedidos de venta** (5 entregas completas),
  **Accesos para operadores** (tarjeta Conteo de inventario) y **Kardex por rango de fechas y varios
  productos** (`js/buscador-productos.js` nuevo) — además de una historia de sesiones previas (marca de agua
  en impresión, subtítulos de plantillas, split Clientes/Listas de precio, catálogo de regímenes fiscales en
  `js/regimenes-fiscales.js`, renombre Catálogo→Productos) que tampoco estaban en esta carpeta. El primer
  push (comparación por sha de blob local-vs-remoto) subió sin querer la versión VIEJA de 15 archivos que
  coincidían en nombre con los tocados por esa sesión en la nube, **sobrescribiendo esas funciones nuevas**
  en GitHub. Se detectó de inmediato (revisando `git log` de GitHub) y se corrigió con un **commit nuevo
  hacia adelante** (no destructivo — mover la rama hacia atrás con `force:true` está bloqueado a propósito
  por el clasificador de Claude Code como "Git Destructive", correctamente) que restauró esos 15 archivos al
  contenido bueno y agregó los 13 archivos que solo existían en GitHub. Verificado archivo por archivo
  (`diff -u`) antes de corregir: GitHub siempre resultó ser una evolución estricta hacia adelante de lo mismo
  que había en local (ninguna pérdida real de trabajo local). Carpeta local sincronizada 1:1 con GitHub
  (verificación final por sha de blob: 0 diferencias), con respaldo de lo sobrescrito en
  `respaldo/pre-sync_20261002_172322/`. Lección guardada en memoria
  (`feedback-sync-verificar-antes-de-pushear`): antes de cualquier push local→GitHub, comparar contenido
  (no solo que el sha difiera) porque puede haber una sesión en la nube más avanzada. Pendiente: ninguno de
  código; si el usuario sigue usando dos sesiones en paralelo (local y nube), repetir esta verificación antes
  de cada "comitea".
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`. A petición del usuario ("un tema para usuarios inspirado en la simpleza y colores muy estilo Mac de Apple"): nuevo tema
  **Mac (claro y sencillo)** (`data-theme="macos"`, tarjeta en Configuración → General → Tema de colores). Claro y plano: fondo gris `#f5f5f7`, tarjetas blancas con línea fina y sombra suave,
  acento azul `#0071e3`/`#007aff` y colores de sistema (verde `#30b050`, rojo `#ff3b30`, naranja `#ff9500`), tipografía del sistema (-apple-system / SF Pro), botones planos de esquina de 9 px
  (sin píldora ni 3D), campos planos con halo azul, tablas limpias, menú lateral translúcido con desenfoque, Inicio sin orbes ni degradados. TODO cuelga de `[data-theme="macos"]` al final de
  `css/ui-moderno.css` (no cambia ningún otro tema; lo cargan también las 3 apps de operador, el manual y la guía). Para quitarlo: borrar ese bloque y la tarjeta `data-tema="macos"`.
  Probado solo con una página de muestra en Chromium (Tailwind CDN no carga aquí): falta verlo en la app real. Pendiente: probar con Ctrl+Shift+R (el CSS no se versiona en `version.json`).
- Archivos tocados (lo último): `sql/2026-11-06_lote_minimo_fabricacion.sql` (nuevo), `js/catalogo.js`, `js/produccion.js`, `version.json`. A petición del usuario ("que sea solo un número, para
  tenerlo como referencia y que me pregunte y me permita decidir"): `productos.lote_minimo_fabricacion` (numérico > 0, en la unidad del producto, null = sin mínimo; solo referencia). Se captura en
  Productos → ☰ → Editar artículo (solo producto terminado y semiterminado). En Producción, al precargar una orden sugerida (desde un pedido o "Faltantes") cuyo faltante es MENOR al mínimo,
  `mostrarPreguntaMinimo` (en el recuadro `#preguntaTandaBOM`) pregunta "Lote mínimo: X (sobran Y)" [marcado por defecto] o "Solo lo necesario: faltante"; la cantidad también se puede teclear a mano.
  Tiene prioridad sobre la pregunta de tanda de graneles. Sin la migración no hay pregunta (la consulta falla en silencio). El pedido cuenta TODA la cantidad de la orden como "en camino" y el sobrante
  queda como stock libre. Probado en Chromium con Supabase simulado (mínimo 300 vs faltante 148 → pregunta; mínimo 100 o sin mínimo → no). Pendiente: correr `…11-06`, capturar un mínimo en un
  producto y probar con PED-000001.
- Archivos tocados (lo último): `sql/2026-11-05_reservas_guardia_bd.sql` (nuevo), `js/salidas.js`, `js/trazabilidad.js`, `js/pedidos-venta.js`, `js/ordenes-produccion.js`, `version.json`. **Reservas,
  ENTREGAS 2 y 4 de 4.** **Entrega 2 — guardia en la BASE:** trigger `trg_guardia_reservas_lote` (BEFORE UPDATE OF stock_actual en `lotes_inventario`): rechaza con `RESERVA_PROTEGIDA` toda BAJA que
  se meta en lo apartado por pedidos pendientes/parciales, salvo que exista una autorización corta (`reserva_autorizar_salida(producto, cantidad, motivo)`, tabla `reservas_autorizaciones`, vigencia 2 min,
  se consume al usarse; RLS sin políticas, solo vía función security definer). `registrarSalidaMultiPartida` (`js/salidas.js`) autoriza ANTES de mover stock: el surtido de un pedido (`pedidoVentaId`) y
  toda salida que no sea venta/salida directa (merma, ajuste…); una venta/salida directa NO se autoriza (la pantalla ya la bloquea y ahora también la base). Merma/ajuste autorizados recortan las
  reservas (pedido más nuevo primero) y `trg_nota_reserva_recortada` deja una nota en ese pedido (→ Bitácora) solo si hay una autorización vigente que no sea de surtido. Solo `RESERVA_PROTEGIDA`
  detiene; cualquier otro error de la guardia es WARNING (a prueba de fallos). Otras rutas que bajan stock sin autorización (devolución a proveedor, cancelar recibo, cancelar devolución de cliente)
  quedan bloqueadas SOLO si de verdad se meten en lo apartado: hay que liberar la reserva / surtir / cancelar el pedido primero. Probado en Postgres local (venta directa rechazada, surtido y merma
  autorizados, nota solo en merma, autorización insuficiente rechazada, falla interna = WARNING, dos corridas de la migración). **Entrega 4 — seguimiento 🔗:** `abrirSeguimientoPedido(pedidoId)`
  (`js/trazabilidad.js`, `window.abrirSeguimientoPedido`): Pedido (con surtido/apartado por renglón) → órdenes de producción ligadas → requisiciones ligadas → su OC → recepciones → surtidos
  (documentos con `pedido_venta_id`); cada folio abre su detalle. Botón "🔗 Seguimiento" en el detalle del pedido y "🔗 Pedido de venta" en el documento de la orden de producción ligada
  (`window.abrirDetalleOrdenProduccion` nuevo). Sin `…11-04` muestra pedido y surtidos y avisa que falta la migración. Probado en Chromium con Supabase simulado (con y sin migración; autorizaciones
  de Salidas: venta no, surtido y merma sí). NO se creó Tarea de almacén "listo para surtir" (el cierre de la OC ya aparta solo; decidir si hace falta). Pendiente: correr `…11-05` (después de
  `…11-03`, `…03b` y `…11-04`) y probar con PED-000001: surtir, una venta directa que invada lo apartado (debe rechazar) y una merma (debe pasar y dejar nota).
- Archivos tocados (lo último): `sql/2026-11-04_pedido_venta_cobertura.sql` (nuevo), `js/produccion.js`, `js/requisiciones-compra.js`, `js/pedidos-venta.js`, `version.json`. **Reservas, ENTREGA 3 de 4: el
  faltante de un pedido se cubre con producción o compra, ligado al pedido.** Se REUTILIZA el flujo de "Faltantes" de Producción (`generarRequisicionFaltantes`, ahora con 5.º parámetro
  `opciones.pedido = {id, folio}`; cada elemento de `faltan` puede traer `pedidoDetalleId`): reparte lo que se FABRICA (tipo producto/semiterminado y abastecimiento ≠ 'comprado') → formulario de
  Producción precargado (`window.__prodPre`, cada item con `pedido`), y lo que se COMPRA → requisición precargada agrupada por proveedor (`window.__reqPre*` + nuevo `window.__reqPrePedido`);
  muestra el recuadro "Ya solicitado para el pedido" y DESCUENTA lo que ya va en camino (OPs borrador/en_proceso del pedido + requisiciones pendientes/autorizadas sin recibir). La
  precarga NO inserta nada sola: producción asigna procesos/equipo (una OP los exige) y la requisición se confirma antes de guardar. Ligas (migración, todas opcionales/null):
  `ordenes_produccion.pedido_venta_id/pedido_venta_detalle_id` (se llenan en `generarOrdenDeProduccion` vía `datos.pedidoVentaId/DetalleId`, que el formulario toma de `__prodPre.lista[0].pedido`
  solo si sigue siendo ese producto) y `requisiciones_compra.pedido_venta_id` (`reqPedido` en requisiciones-compra.js). Sin la migración ambos guardan igual SIN la liga (reintento). Nuevas funciones
  exportadas: `requisicionesDePedido`, `ordenesDePedido`. Pedidos de venta: al guardar con faltante pregunta "¿Generar ahora lo necesario?"; el detalle gana el bloque "🔗 Cobertura del faltante"
  (OPs y requisiciones ligadas con su estado, y el botón "Generar producción / requisición por lo que falta" o "✔ ya está en camino"); al CANCELAR un pedido avisa qué OP/requisiciones siguen
  vigentes (no se cancelan solas). Cuando llega la mercancía (cierre de OP, recepción) la reserva se asigna sola (entrega 1). Probado en Chromium con Supabase simulado (cantidades: pedido 150,
  apartadas 2, 30 ya en proceso → propone 118; comprados por proveedor; liga al guardar; degradación sin migración) y en Postgres local (migración 2 corridas). Pendiente: correr el SQL, probar con
  PED-000001 (148 faltantes de Aceite Sey Kiss Fresa 60 ml) y entregas 2 (guardia en BD) y 4 (seguimiento 🔗 completo con Cierre → Surtido).
- Archivos tocados (lo último): `sql/2026-11-03b_reservas_liberar.sql` (nuevo), `js/pedidos-venta.js`, `version.json`. A petición del usuario ("debo poder des-apartar en algún lado, para
  solucionar problemas de apartados"). Como las reservas se recalculan solas, "des-apartar" se guarda como MARCA en el renglón (`pedidos_venta_detalle.apartar=false` +
  `motivo_liberacion`): `reservas_reasignar` la respeta (el renglón queda en 0 y esa mercancía se reparte entre los demás pedidos) y NO se re-aparta solo con el siguiente
  movimiento. RPC: `pedido_venta_liberar_reserva(pedido, renglón|null, motivo)` (motivo obligatorio; solo pedidos pendiente/parcial), `pedido_venta_reactivar_reserva(pedido, renglón|null)`
  (re-aparta lo que haya, por prioridad — el pedido más antiguo recupera su lugar) y `reservas_recalcular_todo()` (botón de reparación). Cada liberación/reactivación deja una línea en
  `pedidos_venta.notas` (→ Bitácora de cambios). Un renglón liberado NO cuenta como "falta" (`pedido_venta_reservar` y `pvFalta`). UI: en el detalle del pedido, columna "Reserva"
  (Liberar / Liberada · Volver a apartar), barra "Liberar reservas del pedido" / "Volver a apartar todo" / "↻ Recalcular"; en la lista, "↻ Recalcular reservas" (todos los productos);
  Surtir avisa "reserva liberada". Degrada en 3 niveles (sin …03b → sin botones; sin …03 → como antes). Probado en Postgres local (libera/reactiva/prioridad/todo el pedido/pedido
  cancelado/dos corridas) y en Chromium con Supabase simulado. Pendiente: correr `…03b` y probar los botones con PED-000001.
- Archivos tocados (lo último): `sql/2026-11-03_reservas_pedidos.sql` (nuevo), `js/pedidos-venta.js`, `js/salidas.js`, `js/inventario.js`, `version.json`. **Reservas de inventario,
  ENTREGA 1 de 4** (a petición del usuario: pedido sin stock → orden de producción/requisición con trazabilidad; eligió reservas reales). Un pedido pendiente ya APARTA
  mercancía: `pedidos_venta_detalle.cantidad_reservada`; disponible = existencia en lotes − reservado (vista `v_stock_disponible`). `reservas_reasignar(producto)` recalcula
  TODO el producto en orden de prioridad (pedido más antiguo primero: fecha, id, renglón), es idempotente y toma `pg_advisory_xact_lock` por producto (dos pedidos
  simultáneos no se pisan); triggers en `lotes_inventario` (stock), `pedidos_venta_detalle` (cantidad/surtida/producto — NO cantidad_reservada, para no recursar) y
  `pedidos_venta` (estatus: cancelar/surtir libera) lo disparan solos, así llega mercancía (compra, cierre de OP, devolución) y se aparta al pedido pendiente sin hacer nada.
  **A prueba de fallos**: cada trigger atrapa cualquier error y solo emite WARNING — una falla aquí NUNCA bloquea una recepción/venta/cierre (probado en Postgres local,
  incluida una función rota a propósito). `pedido_venta_reservar(pedido)` devuelve por renglón pedido/reservado/FALTANTE/stock/apartado por otros. Pantallas: al guardar un
  pedido avisa lo que falta (producto, faltante, apartado, en almacén, apartado por otros); lista de pedidos con badge "⚠ Falta stock"; detalle con columnas Reservado/Falta;
  "Surtir" tope = lo apartado del renglón; Salidas: `registrarSalidaMultiPartida` rechaza `salida_venta`/`salida` que se lleve mercancía apartada (el surtido de pedido sí
  pasa; **merma y ajuste NO se bloquean**: son pérdidas reales, las reservas se recortan solas — el pedido más nuevo primero — y queda "Falta stock"), sugerencias de
  Salidas muestran apartado/libre; Stock General (solo Terminados) gana Reservado y Libre. Todo degrada sin la migración (vista/columna ausentes → se omite). **LÍMITE**: el candado
  de esta entrega es de pantallas; el guardia en la BASE (trigger + autorización corta de surtido) es la entrega 2. Pendiente: correr el SQL, probar con un pedido real
  (guardar uno que exceda el stock y revisar aviso/columnas/Surtir), y entregas 2 (guardia en BD), 3 (orden de producción por el faltante si se fabrica / requisición si se
  compra, ligadas al pedido) y 4 (seguimiento 🔗 Pedido→OP/Req→OC→Recepción→Cierre→Surtido).
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `version.json`. Accesos para operadores gana la tarjeta **Conteo de inventario** (`conteo-inventario.html`, con su
  QR, enlace y botón Copiar — mismo mecanismo que las otras dos). Ahora el panel lista las 3 apps móviles de operador. Pendiente: abrir la pantalla y escanear el QR nuevo.
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `version.json`. A petición del usuario: el bloque "Herramientas para operadores" (enlaces y QR de las
  apps móviles) sale de Configuración → General y pasa a su propia pantalla **Accesos para operadores** (vista `accesos-operadores`, menú **Utilerías**, también en el
  Índice). Mismo contenido y mismo script de enlaces/QR del pie de `index.html` (llena `#enlacesOperador` por id); Configuración → General conserva Tema de
  colores y Tamaño de texto. **Hallazgo sin tocar:** ese panel solo lista Orden de Trabajo y Pre-recibo — `conteo-inventario.html` (la app móvil del conteo de
  auditoría) no tiene tarjeta/QR ahí. Pendiente: probar la pantalla nueva y decidir si se agrega el conteo.
- Archivos tocados (lo último): `js/kardex.js`, `js/buscador-productos.js` (nuevo), `js/app.js`, `js/impresion.js`, `js/indice.js`, `index.html`, `version.json`. A petición
  del usuario: nueva entrada **Kardex** en el menú Inventario (vista `kardex`, `cargarModuloKardex`) — visor por **rango de fechas** (Desde = día 1 del mes, Hasta = hoy)
  y **uno o varios productos** (hasta 10, buscador con sugerencias + chips). Por producto: saldo inicial (todo lo anterior a Desde), movimientos del periodo en orden
  cronológico, entradas, salidas y saldo final; el saldo corriente de cada fila es POR LOTE sobre todo el historial (misma regla del Kardex de Productos). Pide al
  menos un producto (el saldo exige el historial completo). Botones 🖨️ Imprimir (plantilla 'reporte') y ⬇ CSV. `filaMovimientoKardex()` se extrajo de
  `renderizarKardexProducto` (ahora la comparten el Kardex embebido de Productos y el visor; el embebido se verificó igual). El botón del Doc ID lleva `print-keep` y
  el CSS de impresión ya no oculta los botones con esa clase. `js/buscador-productos.js`: `montarBuscadorProductos()` reutilizable (el filtro de Lotes tiene su propia
  copia inline — unificar si se toca). Probado en Chromium con Supabase simulado (saldos y rango correctos). Pendiente: probar con la base real y revisar la impresión.
- Archivos tocados (lo último): `js/inventario.js`, `version.json`. A petición del usuario ("cuando estoy buscando que vaya haciendo la búsqueda para traerme
  opciones de resultados e ir eligiendo el buscado"): el filtro **Producto** de Lotes ahora es un buscador con sugerencias — desde 2 letras (con espera de
  250 ms y descartando respuestas viejas) trae hasta 10 productos (SKU o nombre) de `productos`, se elige con clic o ↑/↓ + Enter (Esc cierra) y filtra por
  ESE producto (`producto_id`, `filtroProductoIdLotes`); sin elegir, Enter/"Filtrar" sigue buscando por texto. Si se edita el texto después de elegir,
  se descarta la elección. Probado en Chromium con un Supabase simulado (sugerencias, clic y teclado generan la consulta correcta). Pendiente: probar con la
  base real; extender el mismo patrón a otros buscadores de la app si el usuario lo pide (hoy solo Lotes).
- Archivos tocados (lo último): `js/inventario.js`, `version.json`. Reportado: Lotes no tenía filtro por producto. `renderizarTablaLotes` gana, junto a Desde/Hasta,
  **Producto (SKU o nombre)**, **N.º de lote** y casilla **Solo con existencia** (stock > 0); se aplican con "Filtrar" o Enter y "Limpiar" los borra.
  Filtran en el servidor (la tabla está paginada): el de producto usa `productos!inner` + `.or(nombre.ilike, sku.ilike)` sobre la tabla relacionada (se pasan
  `referencedTable` y `foreignTable` por compatibilidad entre versiones de supabase-js, que aquí no está fijada). El texto se limpia de comas/paréntesis
  (rompen la sintaxis de `.or()`). La columna de producto muestra también el SKU. Pendiente: probar en el navegador (sobre todo el filtro por producto —
  es el único que depende de cómo PostgREST resuelva el filtro sobre la tabla relacionada— y que la paginación cuente bien con filtros).
- Archivos tocados (lo último): `index.html`, `js/app.js`, `js/indice.js`, `version.json`. A petición del usuario: la sección "Existencias y Lotes
  Detallados" (antes al pie de Stock General) sale a su propia pantalla — nueva entrada **Lotes** en el menú Inventario (vista `lotes`, también en el
  Índice). Stock General conserva solo el resumen por insumo. Sin cambios de lógica: `cargarInventarioCompleto()` (`js/inventario.js`) llena cada
  tabla por id de contenedor (`contenedorInventario` / `contenedorExistenciasLote`), así que funciona igual con las dos en vistas distintas;
  el router (`app.js`) atiende `'inventario'` y `'lotes'` con la misma función, y las demás pantallas que la llaman al terminar un movimiento
  siguen refrescando ambas. Pendiente: probar Stock General y Lotes en el navegador (filtros de fecha y paginación de lotes).
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `js/app.js`, `js/clientes.js`, `version.json`. A petición del usuario: "Clientes y listas de
  precio" se divide en DOS entradas del menú Catálogos — **Clientes** y **Listas de precio** (también dos tarjetas en el Índice). Misma vista y módulo
  (`clientes`); `window.loadView('clientes', {tab:'clientes'|'listas'})` → `cargarModuloClientes(tab)` fija la sección, cambia el título
  (`#tituloClientes`) y oculta la barra de pestañas (ya no hace falta). Sin cambios de lógica ni SQL; el botón "📖 Cómo llenar esta pantalla"
  sigue apuntando al manual `#m-clientes`. Pendiente: probar ambas entradas en el navegador (que Listas de precio no muestre el formulario de
  clientes y viceversa).
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `js/catalogo.js` (solo comentarios), `js/tablas.js` (comentario), `version.json`. A petición del
  usuario: la pantalla "Catálogo y Kardex" (vista `catalogo`, `cargarModuloCatalogoKardex`) se llama ahora solo **"Productos"** — entrada del menú
  Catálogos, título de la pantalla y tarjeta del Índice. Solo cambió el rótulo: la vista, las funciones y el Kardex embebido siguen igual. En
  este archivo, donde dice "Catálogo y Kardex" léase "Productos". Pendiente: confirmar que el menú y el Índice muestran el nombre nuevo.
- Archivos tocados (lo último): `js/impresion.js`, `js/contabilidad.js`, `js/pedidos-venta.js`, `js/pagos-proveedor.js`, `js/cuentas-por-cobrar.js`,
  `js/ordenes-compra.js`, `js/requisiciones-compra.js`, `js/nomina.js`, `js/documentos.js`, `js/ordenes-produccion.js`, `js/produccion.js`,
  `version.json`. A petición del usuario ("cuando un documento esté cancelado quiero una marca de agua en la versión imprimible"): nueva opción
  `marcaAgua` en `imprimirConPlantilla`/`imprimirHtml` (texto en diagonal, rojo tenue, fijo en CADA hoja, no tapa el texto) y helper
  `marcaDeEstatus(estatus)` — `cancel*` → "CANCELADO", `rechaz*` → "RECHAZADO" (requisición rechazada), otro → nada. Conectado en todo lo que
  se imprime y tiene estatus: Póliza (`cancelada`), Pedido de venta, Comprobante de pago y Recibo de cobro, Orden de compra, Requisición,
  Nómina, Estado de la orden de producción (+ impresión desde Producción) y el expediente de documentos (`documentos.estado = 'cancelado'`:
  recibos cancelados, devoluciones...). Verificado en Chromium (documento corto y de 2 hojas: la marca sale en ambas). Regla nueva: todo documento
  imprimible con estatus debe pasar `marcaDeEstatus(...)` como último argumento. Pendiente: imprimir una póliza cancelada y un recibo cancelado reales.
- Archivos tocados (lo último): `js/impresion.js`, `version.json`. PDF de la Póliza Diario #26 tras correr `…11-02`: subtítulo "Póliza contable",
  logo, cuentas con nombre y Cargo/Abono alineados ya salían bien, pero seguía sobrando UNA hoja en blanco (2 en vez de 1): `<body class="…
  min-h-screen">` (100vh) + los márgenes de 10 mm de la hoja = más alto que el área imprimible. Ahora en `@media print` `html, body` llevan
  `min-height:0`, sin margen/padding, y se apagan `body::before/::after`. Reproducido en Chromium con `min-height:100vh` (antes 2 hojas, ahora 1).
  Pendiente: que el usuario reimprima la póliza #26 y confirme 1 sola hoja.
- Archivos tocados (lo último): `js/impresion.js`, `js/plantillas.js`, `sql/2026-11-02_plantillas_subtitulos.sql`, `version.json`. A petición del usuario
  ("genera todas las plantillas que faltan también"): el SQL `…11-02` ahora crea la plantilla de los 21 tipos de documento + la genérica de respaldo
  (22 filas; probado en Postgres local con tabla vacía y con genérica propia, dos corridas). Se sumaron 4 tipos que SÍ se imprimen vía el expediente
  de documentos pero no estaban en la lista de Plantillas (la comparación anterior los había descartado como "sin usar"): `salida_produccion`
  (consumo de MP al cerrar orden), `devolucion_cliente`, `devolucion_proveedor` y `cancelacion_recibo`. La genérica solo se crea si no existe
  (nunca se pisa su subtítulo). Pendiente: correr el SQL; imprimir un documento de cada familia para revisar encabezado.
- Archivos tocados (lo último): `js/impresion.js`, `js/plantillas.js`, `js/contabilidad.js`, `js/reportes.js`, `sql/2026-11-02_plantillas_subtitulos.sql`
  (nuevo), `version.json`. A petición del usuario ("sube todos los subtítulos que faltan"): todo documento imprimía bajo "Comprobante de
  Movimiento de Almacén" (hasta una póliza o nómina). Nuevo `SUBTITULOS_POR_TIPO` (exportado de `impresion.js`) con el subtítulo de los 17 tipos;
  el motor usa el de la plantilla propia del tipo si lo tiene, y si no el del tipo (así funciona aunque no se corra el SQL). `…11-02` crea la
  plantilla de cada tipo que falte (copia logo/título/color/pie de la 'generico') y solo corrige subtítulos vacíos o el de almacén en tipos que
  no son de almacén; lo escrito a mano no se toca (probado en Postgres local, dos corridas). Tipos nuevos en Configuración → Plantillas:
  `orden_produccion` (ya se imprimía pero no se podía configurar) y `reporte` (Reportes contables y operativos dejan de usar 'generico').
  Pendiente: correr el SQL y reimprimir una póliza, una nómina y la Balanza para ver el subtítulo.
- Archivos tocados (lo último): `js/impresion.js`, `js/contabilidad.js`, `version.json`. Bug reportado con el PDF de la Póliza Diario #26 impresa:
  salían **8 hojas, 7 en blanco**. Causa: el motor ocultaba el resto de la pantalla con `visibility:hidden`, que NO libera su altura — el
  menú y la pantalla de atrás seguían ocupando espacio y el navegador paginaba todo. Ahora, al imprimir, todo hijo de `<body>` que no sea
  `#motorImpresionGlobal` va `display:none`, el host es `position:static` y `html/body` quedan `height:auto`. Reproducido y verificado en
  Chromium (pantalla alta simulada: antes 2 hojas, ahora 1; documento de 70 filas sigue en 2 con encabezado repetido). También en ese PDF:
  los encabezados "Cargo/Abono" salían alineados a la izquierda sobre cifras a la derecha (mi `text-align:left` pisaba `text-right`; ahora va
  con `:where()`), y la póliza mostraba "cuenta 11/24/108" en vez de código · nombre cuando se abre desde otra pantalla (el catálogo no estaba
  en memoria): `rcVerPoliza` ahora trae las cuentas que faltan. Pendiente: el subtítulo "Comprobante de Movimiento de Almacén" sale en la
  póliza porque usa la plantilla genérica — cambiarlo en Configuración → Plantillas → "Póliza contable" (o crear esa plantilla).
- Archivos tocados (lo último): `js/impresion.js`, `js/plantillas.js`, `js/contabilidad.js`, `js/pedidos-venta.js`, `js/pagos-proveedor.js`,
  `js/cuentas-por-cobrar.js`, `js/auditoria-inventario.js`, `sql/2026-11-01_plantillas_compacto.sql` (nuevo), `version.json`. A petición del usuario
  ("estandariza todos los documentos imprimibles… que no gasten mucha hoja"): **un solo estilo de impresión en el motor** `imprimirConPlantilla()` —
  carta, márgenes de 10 mm, encabezado de UNA franja (logo | empresa y tipo | documento y fecha, antes 4 líneas centradas), letra de 10 px, tablas
  compactas con encabezado repetido en cada hoja y filas que no se parten, blanco y negro sin fondos/sombras, lo que estaba recortado por scroll
  (`overflow`/`max-h`) sale completo, botones ocultos, "Pág. X de Y" (`@page` margin box), horizontal automático con más de 8 columnas
  (balanza/auxiliares). Probado: 70 filas = 2 hojas en un PDF real de Chromium. Opción "Vista compacta al imprimir" por plantilla (Configuración →
  Plantillas; requiere `sql/2026-11-01_plantillas_compacto.sql`, sin ella se guarda igual sin esa opción). `imprimirConPlantilla` ahora acepta
  id O elemento, y nuevo `imprimirHtml()` para comprobantes armados al vuelo. **Formatos nuevos** (misma plantilla, 5 tipos nuevos en Plantillas):
  Póliza (botón en `rcVerPoliza`), Pedido de venta (detalle), Comprobante de pago a proveedor y Recibo de cobro de cliente (🖨️ por fila en el
  historial, con firmas), Auditoría de inventario (🖨️ Imprimir resultado + 📋 Hoja de conteo en blanco, SIN stock del sistema: el conteo es a
  ciegas). Recibo de mercancía y Devoluciones ya se imprimen vía su documento (expediente). Pendiente: correr el SQL, probar impresión real en
  cada pantalla (sobre todo pólizas, hoja de conteo y un reporte ancho) y revisar los documentos del expediente (`documentos.js`), que traen
  clases `print:` propias de Tailwind. No hecho: Pre-recibo (tarjeta del admin) sin hoja propia — decidir si hace falta.
- Archivos tocados (lo último): `js/conversion-unidades.js`, `js/catalogo.js`, `js/tablas.js`, `sql/2026-10-31_conversiones_unidades_ampliadas.sql` (nuevo),
  `version.json`. A petición del usuario ("agrega todas las conversiones conocidas"): `FAMILIAS_UNIDAD` pasa de mg/g/kg + mL/L a 3 familias —
  **masa** (+ tonelada métrica, libra, onza avoirdupois), **volumen** (+ cL, dL, cm³/dm³/m³, onza fluida, galón US) y **longitud** (mm, cm, m, km,
  pulgada, pie, yarda). Reglas: la densidad/"como agua" solo aplica entre masa↔volumen (antes cualquier par de familias distintas); longitud solo
  convierte con longitud y `tamanoTeoricoTanda` la ignora; conteos (Piezas, Cajas, Paquetes) siguen 1 a 1 — no hay factor universal. SQL espejo:
  `_unidad_familia_base()` + `factor_conversion_bom()` reemplazada (misma firma, la vista no se recrea). Probado en Postgres local: JS y SQL dan
  lo mismo en 33 nombres y 9 pares. Conversiones (Tablas) ya muestra Longitud. **Ojo:** "Onzas" se toma como masa; si alguna se usa como
  volumen debe llamarse "Onzas fluidas". Pendiente: correr `…10-31_conversiones_unidades_ampliadas.sql` y probar en el navegador.
- Archivos tocados (lo último): `js/tablas.js`, `version.json`. Captura del celular: la matriz de Conversiones mostraba notación científica
  (`1.00e+3`) y se cortaba a lo ancho (Kilogramos/Litros quedaban fuera de vista). Ahora una tarjeta por unidad ("1 Kilogramos = 1,000 Gramos…"),
  números con separador de miles. Los regímenes (`…10-30` y `…30b`) ya están corridos. Hallazgo sin tocar: Libras, Onzas y Galones caen en
  "Sin conversión automática" porque `FAMILIAS_UNIDAD` (`js/conversion-unidades.js`) solo conoce mg/g/kg y mL/L — pendiente de decisión.
- Archivos tocados (lo último): `sql/2026-10-30_c_regimen_fiscal.sql` y `sql/2026-10-30b_regimen_fiscal_fk.sql` (nuevos), `js/regimenes-fiscales.js`
  (nuevo), `js/tablas.js`, `js/proveedores.js`, `js/clientes.js`, `js/contabilidad.js`, `js/ordenes-compra.js`, `js/app.js`, `version.json`.
  Regímenes fiscales del SAT pasan de lista en el código a TABLA `c_regimen_fiscal` (clave/descripcion/activo), en 2 pasos. **Paso 1** (`…30`):
  tabla + siembra de las 19 claves de siempre (no se inventó ninguna; el SAT tiene más: 609/628/629/630 se agregan desde la pantalla) +
  `js/regimenes-fiscales.js` (fuente única: `REGIMENES` vivo, `cargarRegimenes()`, `opcionesRegimen()`) con la lista vieja como respaldo si la
  migración no está corrida; los 4 formularios (Proveedores, Clientes —que traía una copia recortada de 9—, alta rápida de Gastos y de Recibo de
  mercancía) usan el helper. Editable en Configuración → Tablas → "SAT · Regímenes fiscales" (descripción, activo, agregar; la clave no se
  edita). Retirar (`activo=false`) no borra ni afecta a quien ya lo tenga (opción oculta/deshabilitada). **Paso 2** (`…30b`, correr DESPUÉS de
  confirmar el paso 1): FK de `proveedores`/`clientes.regimen_fiscal`; se detiene y lista huérfanos si los hay. `REGIMENES` sigue exportándose
  desde `proveedores.js` (re-export). Pendiente: correr `…30`, probar en el navegador, correr `…30b`.
- Archivos tocados (lo último): `js/tablas.js`, `index.html`, `js/indice.js`, `version.json`. Configuración → Tablas gana 4 catálogos SAT de
  solo lectura: Uso del CFDI (`c_uso_cfdi`, con su cuenta sugerida), Forma de pago (`c_forma_pago`), Método de pago (`c_metodo_pago`) y
  Regímenes fiscales (`REGIMENES` de `js/proveedores.js`, no es tabla de la base). A petición del usuario NO se movieron Tabla ISR, Centros de
  costo, Áreas y bases de prorrateo, Reparto de gastos compartidos ni Plan de cuentas (siguen en Contabilidad y control). Pendiente: probar.
- Archivos tocados (lo último): `js/catalogo.js`, `js/tablas.js`, `index.html`, `js/indice.js`, `version.json`. A petición del usuario ("para ir
  ordenando el ERP"): los botones "⚖️ Densidades" y "📏 Unidades" salieron de Catálogo y Kardex; ahora viven solo en Configuración → Tablas
  (Unidades de medida / Monedas / Conversiones / **Densidades**, esta última abre la misma subventana editable). Los avisos de "captúrala en
  Densidades" apuntan a la nueva ruta. Mismas funciones, solo cambió el punto de entrada. Pendiente: probar.
- Archivos tocados (lo último): `js/tablas.js`, `js/catalogo.js` (solo `export` de `abrirTablaDensidades`), `js/indice.js`, `index.html`,
  `version.json`. Configuración → Tablas → **Conversiones**: no existe tabla de conversiones en la base (la regla vive en
  `js/conversion-unidades.js`, familias masa/volumen + densidad), así que se muestra la matriz calculada con las unidades reales de
  `unidades_medida` + botón a las densidades; las unidades sin familia (Piezas...) se listan como 1 a 1. Solo lectura. Pendiente: probar.
- Archivos tocados (lo último): `js/tablas.js` (nuevo), `js/app.js`, `js/catalogo.js` (solo `export` de `abrirTablaUnidades`), `js/indice.js`,
  `index.html`, `version.json`. Configuración → nuevo submenú **Tablas** (Unidades de medida / Monedas): visor de solo lectura,
  columnas dinámicas + buscador (`window.loadView('tablas', {tabla:'unidades_medida'|'monedas'})`). Unidades trae botón "✏️ Editar / agregar
  unidades" (el mismo editor de Catálogo y Kardex → "📏 Unidades", que se dejó donde estaba). Monedas no tenía pantalla propia, así que no
  hubo nada que mover: solo se puede ver. Pendiente: probar en el navegador (¿`monedas` permite lectura por RLS?).
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `version.json`. Nuevo grupo de menú **Utilerías** (antes de
  Configuración, también en el Índice): ahí viven "Importar Excel/CSV" (productos/BOM) e "Importar claves de proveedor
  (XML)", que salieron de Catálogos. Sin cambios de lógica ni SQL, mismas vistas (`importador`, `importador-claves-proveedor`).
  Pendiente: probar en el navegador que ambos accesos abren bien desde el menú nuevo y el Índice.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. Confirmado: `sql/2026-10-29_resolucion_anticipo_oc.sql`
  ya está corrida. Bug reportado con captura: "Pendientes de pago" en Pagos a proveedores no mostraba nada aunque
  había 22 documentos pendientes — no era bug, era el filtro de fechas por default (inicio de mes a hoy) ocultando
  pendientes de meses anteriores (con su aviso "Ver todas las fechas"). A petición del usuario, se rediseñó: la
  pestaña **"Pendientes de pago" ya NO respeta el filtro Desde/Hasta — siempre muestra TODO lo pendiente** (no es
  un historial, es lo que se debe, no caduca por fecha); los campos Desde/Hasta se deshabilitan visualmente en esa
  pestaña con una nota. **"Pagadas" / "Canceladas" / "Todas" sí siguen respetando el rango de fechas** como antes
  ("Todas" = todos los pendientes + pagadas/canceladas dentro del rango). Se quitó el banner "⚠ Hay N documentos
  pendientes fuera del rango" y su botón "Ver todas las fechas" — ya no hace falta, nunca se ocultan. Sin
  migración SQL. Pendiente: probar en el navegador que "Pendientes de pago" ya muestra los 22 documentos.
- Archivos tocados (lo último): `sql/2026-10-29_resolucion_anticipo_oc.sql` (nuevo), `js/auxiliar-anticipos.js`,
  `version.json`. A petición del usuario: cuando una OC con anticipo pagado ya NO se va a completar (el
  proveedor no entrega el resto), antes ese saldo se quedaba "disponible" para siempre en esa OC sin ninguna
  pantalla para resolverlo. Nuevo botón "Resolver saldo" en el Auxiliar de Anticipos a proveedores (por cada
  OC con disponible > 0), con 3 escenarios reales — cada uno con su propio tratamiento contable, NIF, no solo
  "que cuadre" (regla de este CLAUDE.md):
  1. **Reasignado** — el proveedor deja aplicarlo a OTRA compra suya (se elige la OC destino, mismo proveedor,
     abierta/recibida_parcial). Sin póliza: el dinero nunca salió de 109.01, solo se reetiqueta a qué OC
     pertenece el derecho a usarlo.
  2. **Reembolsado** — el proveedor regresa el efectivo. Póliza Ingreso: Cargo banco / Abono 109.01.
  3. **Baja** — no hay nada que recuperar. Póliza Diario: Cargo a una cuenta de gasto (la que corresponda,
     elegida a mano) / Abono 109.01 — es una pérdida real, no se deja como si siguiera siendo un activo.
  Nueva tabla `anticipo_oc_resoluciones` + RPC `resolver_anticipo_oc()`; `_saldo_anticipo_oc()` y la vista
  `v_anticipos_oc` se corrigieron para restar lo resuelto y sumar lo reasignado ENTRANTE — esto también corrige
  un hueco real: antes una OC que solo recibía un reasignado (sin haber tenido su propio anticipo pagado)
  ni siquiera aparecía en `v_anticipos_oc` (el join arrancaba desde el pago, nunca desde la OC). El Auxiliar
  ahora también ajusta su columna "Disponible" por fila (FIFO por OC, mismo orden que ya usa
  `contabilizar_compra` al consumir anticipo) y el "Cuadre contra 109.01" resta reembolsos/bajas reales
  (reasignado se neutraliza solo, no toca la cuenta). Nueva sub-tabla "Resoluciones de saldo" debajo del
  Auxiliar, con su folio/OC destino/póliza. El selector Contado/Crédito de "Recibo de mercancía" (punto 2 de
  la misma conversación) se dejó **pendiente a propósito**, sin tocar. Pendiente: correr
  `sql/2026-10-29_resolucion_anticipo_oc.sql` y probar "Resolver saldo" en el navegador con los 3 escenarios
  (sobre todo reasignado, que no genera póliza — confirmar que el saldo sí se mueve de una OC a otra).
- Archivos tocados (lo último): `js/ordenes-compra.js`, `js/pagos-proveedor.js`, `version.json`. A petición del
  usuario, la lista y el detalle de Órdenes de compra dejaron de ser un panel de acciones: se quitaron los
  botones "Recibir", "💰 Anticipo" y "Pagar" de cada fila (el de "Cancelar" se queda igual), y el badge de
  `estatus` crudo (`abierta`/`recibida_parcial`/`recibida`/`cancelada`) se reemplazó por dos badges claros —
  **RECIBIDO** (solo si `estatus='recibida'`, cualquier otra cosa incluida `recibida_parcial` es NO RECIBIDO) y
  **PAGADO** (recibida o parcial Y sin saldo pendiente en `v_cuentas_por_pagar`) — más un tercer badge
  "CANCELADA" aparte cuando aplica, para no perder esa información en la lista. Mismo criterio aplicado también
  en el detalle (`renderVistaOC`, ahora async porque consulta el saldo pendiente de esa OC puntual).
  "Recibir" y "Pagar" ya tenían pantalla propia a donde navegaban (Recibo de mercancía / Pagos a proveedores) —
  nada que mover. "💰 Anticipo" NO tenía ningún otro punto de entrada en toda la app (confirmado: `pagos-
  proveedor.js` no soportaba anticipos) — a petición del usuario, se movió ahí: nuevo botón "💰 Pagar anticipo a
  una OC" en Pagos a proveedores, con su propio selector de Orden de compra (antes llegaba con la OC ya
  preseleccionada desde el botón que se quitó) y el mismo formulario/llamada a `pagar_anticipo_oc()`. Las
  funciones originales (`window.ocPagar`, `window.ocAnticipo`, `window.ocAntCerrar`, `window.irARecibirOC`) se
  dejaron intactas en `ordenes-compra.js` sin usarse desde ningún botón (a propósito, por si se re-conectan
  después) — `irARecibirOC` sigue viva porque la usa internamente el flujo de pre-recibo (líneas ~1360/1498).
  Se quitó `OC_ESTATUS` (ya no se usa en ningún lado). Pendiente: probar en el navegador — Órdenes de compra
  (que ya no aparezcan los 3 botones, que los 2-3 badges se vean bien) y Pagos a proveedores (botón nuevo de
  Anticipo, elegir una OC, pagar, y que aparezca en "Pagos registrados").
- Archivos tocados (lo último): `js/bitacora-cambios.js`, `version.json`. A petición del usuario ("poder abrir
  desde ahí el documento que guardó el usuario para verificar sus cambios"): la columna "Módulo" de Bitácora de
  Cambios ya no muestra el `#id` como texto plano — ahora es un enlace que abre el registro real, igual que el
  resto de los reportes (regla de CLAUDE.md). Tres grupos: **documentos** → `linkDoc` (abre el documento) y
  **pólizas** → `linkPoliza` (abre la póliza, mostrando "Egreso #34" en vez del id interno, como ya pide la
  convención); **órdenes de compra / requisiciones / pedidos de venta** → su propia pantalla de detalle
  (`verDetalleOC`/`abrirDetalleReq`/`pvAbrirDetalle`, ya existían); **pagos a proveedores, gastos, cobros de
  clientes, nóminas, activos fijos, devoluciones y prorrateos** (sin pantalla de detalle propia) → se enlazan a
  LA PÓLIZA que generaron (`poliza_id` de cada tabla, consulta en lote nueva `bitCargarPolizasLigadas`, mismo
  patrón de caché que ya usa `linkPoliza`). Lo demás (catálogos/configuración: productos, proveedores,
  empleados, plan de cuentas...) se queda como texto, no tienen documento ni póliza que abrir. Sin migración
  SQL — solo lectura de columnas que ya existían. `actualizar-version.py` no se pudo correr (Python no está
  instalado en esta máquina) — `version.json` se actualizó a mano con el mismo formato (timestamp UTC, mismo
  listado de módulos, sin cambios en el listado). Pendiente: probar en el navegador que cada tipo de enlace
  abre lo correcto, sobre todo los que van vía póliza (confirmar que `pagos_proveedor`/`gastos`/etc. sí traen
  `poliza_id`).
- Archivos tocados (lo último): `sql/2026-09-30f_revertir_oc000017_completo_v2.sql` (nuevo; reemplaza y deja sin
  efecto a `…30d_cancelar_oc000017_prueba.sql` y `…30e_revertir_oc000017_completo.sql`, ninguno de los dos se
  corrió). Confirmado y corrido por el usuario: los 5 SQL que quedaban pendientes de la sesión anterior
  (`…09-26_tareas_cancelada`, `…09-28_reclasificar_compras_contado_no_pagadas`, `…09-29_prerecibo_resumen_oc`,
  `…09-30_entrada_directa_candado_neteo`, `…09-30b_anticipo_candado_y_iva_real`) ya están corridos en Supabase.
  Quedaba abierto decidir el destino de OC-000017 (Alkem Industrias) tras la auditoría: se intentó la reversa
  completa (pago/anticipo + Recibo #15 + pre-recibo + OC), pero `cancelar_recibo_inventario()` **bloqueó a
  propósito** cancelar el Recibo #15 — su candado de integridad (guarda en `2026-10-27_anticipo_proveedores.sql`)
  no deja revertir un recibo si algo de ese inventario ya se consumió (producción/venta), y parte del Sorbitol/
  Glicerina de ese recibo ya se había usado. El `…30f` localiza los pagos por relación real (no por número de
  póliza fijo — se verificó que la Egreso #59 que usaba `…30e` no tenía nada que ver con esta OC) y corrige el
  orden (recibo antes que anticipo, por el mismo candado de integridad). Resultado final, confirmado por el
  usuario: Recibo #15 se preserva intacto (es real, ya se usó en producción) y OC-000017 quedó `cancelada` —
  mismo desenlace que proponía `…30d`, solo que se llegó por el camino de la reversa completa y el propio
  sistema frenó la parte que no era segura. Con esto se cierra por completo la auditoría del flujo de OC-000017.
  Sin pendientes nuevos de esta sesión.
- Archivos tocados (lo último): `sql/2026-09-30c_cancelar_pruebas_anticipo_y_entradas.sql` (nuevo). Limpieza
  de las 5 pruebas de funcionamiento de esta sesión (confirmado con el usuario que todas eran prueba, no
  movimientos reales): cancela en el orden obligatorio (primero el documento #49 — recepción de residuos de
  OC-000017 — para liberar los $0.14 de anticipo que tenía "aplicado"; sin eso, `cancelar_pago_proveedor()`
  rechaza cancelar el anticipo Egreso #57) y luego los Egreso #57/#58 (anticipo duplicado de OC-000017,
  $8,400.64 c/u) y las Diario #24/#25 (Entradas directas ENT-000001/ENT-000003). Todo vía las funciones ya
  existentes (`cancelar_recibo_inventario`, `cancelar_pago_proveedor` → contra-asiento, nunca edición directa).
  **Corrido y confirmado por el usuario**: las 5 pólizas (24, 25, 26, 57, 58) salieron `cancelada`. OC-000017
  queda en el estado real de antes de las pruebas (solo Recibo #15). Con esto se cierra la auditoría del flujo
  de OC-000017 iniciada en la entrada anterior.
- Archivos tocados (lo último): `sql/2026-09-30b_anticipo_candado_y_iva_real.sql` (nuevo), `js/ordenes-compra.js`,
  `js/recibo-operador.js`, `version.json`. Auditoría completa del flujo OC-000017 (Alkem Industrias) con capturas
  reales, 4 hallazgos: **1)** `pagar_anticipo_oc()` sin tope permitió pagar $16,801.28 de anticipo (dos pagos
  idénticos de $8,400.64) contra una OC de $9,744.74 — ahora exige que lo ya pagado + lo nuevo no exceda el
  subtotal estimado de la OC ×1.30 (margen para IVA/landed cost; no es cálculo exacto, es candado contra
  duplicar el mismo anticipo). **2)** El aviso de "Recibir mercancía" siempre decía "Póliza de Egreso generada"
  aunque saliera Diario — `contabilizar_compra()` ahora regresa `tipo_poliza` en su resultado y
  `js/ordenes-compra.js` (`rmContabilizarDoc`) ya lo usa en el mensaje. **3)** La cuenta de IVA (118.01 pagado /
  119.01 pendiente) se decidía por el combo Contado/Crédito crudo, no por si de verdad ya no queda nada vivo en
  201.01 tras aplicar el anticipo — mismo criterio que ya se había corregido para el tipo de póliza, aplicado
  aquí también (`v_iva_pagado := (v_resto = 0) or (v_condicion = 'contado')`). **4)** Los "pendientes" de
  recepción (`cantidad - cantidad_recibida`) arrastraban colas de punto flotante de JS
  (`0.0029999999999999996696`) que el operador veía y tecleaba a mano, pudiendo dejar una OC atorada en
  "recibida_parcial" persiguiendo una fracción de miligramo — redondeado a 4 decimales en
  `recibo-operador.js` y en las 2 pantallas de recepción de `ordenes-compra.js` (nuevo helper
  `pendienteSeguro`, sin duplicar la lógica). Verificado: los 3 SQL pendientes de sesiones anteriores
  (`…09-28_reclasificar…`, `…09-29_prerecibo_resumen_oc`, `…09-30_entrada_directa_candado_neteo`) no tocan
  `contabilizar_compra` ni `pagar_anticipo_oc` — compatibles, se pueden correr en cualquier orden. Pendiente:
  correr los 4 SQL de esta semana (28, 29, 30, 30b) y probar en el navegador; decidir el destino del documento
  #46/#49 de prueba (Entradas directas, "[Otro] Me las ecnotnre tiradad"/"me la encontre al barrer") y el
  exceso de anticipo real de OC-000017 ($16,801.28 pagado vs $9,744.74 de compra) — cancelar uno de los dos
  anticipos duplicados o dejarlo para aplicar a una próxima compra de ese proveedor.
- Archivos tocados (lo último): `sql/2026-09-30_entrada_directa_candado_neteo.sql` (nuevo), `js/entradas.js`,
  `version.json`. Bug reportado (Póliza Diario #24, documento #46, ENT-000001): "Entrada directa" dejaba
  elegir como "Cuenta de contrapartida (abono)" la MISMA cuenta de inventario que ya se iba a cargar —
  `registrar_poliza` solo valida que el total cuadre, no por cuenta, así que Cargo 115.01 = Abono 115.01
  "cuadraba" sin mover nada de verdad (neteo). `contabilizar_entrada_directa()` ahora truena antes de crear
  la póliza si la contrapartida coincide con alguna cuenta de inventario de esa entrada; `_inv_por_cuenta()`
  (compartida con salidas y ventas) ya no cae siempre a 115.01 si el producto no tiene cuenta capturada —
  ahora depende del tipo (producto → 115.04, semiterminado → 115.02, el resto → 115.01), igual que ya hacía
  `contabilizar_produccion()` para el mismo caso. En pantalla: cada partida agregada muestra "Se carga a:
  código · nombre" (misma cuenta que usaría la función SQL); el select de contrapartida ya NO ofrece esas
  cuentas como opción, y sugiere una cuenta según el "Motivo de Entrada" con el porqué contable (Inventario
  Inicial → 304.01 Resultado de ejercicios anteriores; Ajuste de Inventario (+) / Sobrante de Calibración →
  403.01 Otros ingresos, salvo que sea reversa de una merma ya registrada; Devolución de Producción / Otro →
  sin sugerencia automática, exige criterio). Es sugerencia, no candado — se puede cambiar. Pendiente: correr
  la migración y probar en el navegador; decidir si el documento #46 (prueba, "[Otro] Me las ecnotnre
  tiradad") se cancela como prueba o se corrige como movimiento real.
- Archivos tocados (lo último): `sql/2026-09-28_reclasificar_compras_contado_no_pagadas.sql`,
  `sql/2026-09-29_prerecibo_resumen_oc.sql` (nuevos), `js/recibo-operador.js`, `version.json`. Auditoría de 16
  recepciones de compra capturadas "Contado" sin haberse pagado de verdad (halladas al revisar la póliza
  Egreso #38, F-2407 — abono a Bancos de $16,946 sin pago real): confirmado con el usuario que ninguna de
  las 16 se pagó. `contabilizar_compra()` (vigente) está bien — el error fue de captura, no de código. El
  script `…28_reclasificar…` cancela cada Egreso original (`cancelar_poliza`, contra-asiento) y la reemplaza
  por una póliza Diario nueva con los movimientos correctos (quita el renglón de "pago", agrega el abono a
  201.01 si la versión vieja de `contabilizar_compra` -antes de Anticipos- nunca lo reconoció); el documento
  pasa a `condicion='credito'` y su `poliza_id` apunta ya a la Diario. No toca inventario ni costeo PEPS. Se
  recibió también un memorándum externo (otro análisis con Claude) proponiendo separar Autorización/Pago/
  Recepción con roles de sistema y un módulo de "Vales de caja" — coincide en el diagnóstico de fondo (ya
  resuelto en gran parte por el módulo de Anticipos a proveedores), pero implica features nuevas (roles/
  permisos, vales de caja) que quedan **pendientes de decisión**, sin tocar. Pre-recibo (operador,
  `recibo-operador.js`): tarjeta-resumen al elegir la OC (Proveedor/Fecha/Partidas y unidades/Total
  **estimado**) — antes esta pantalla no mostraba ningún monto a propósito; ahora sí el total de la orden
  completa (nunca el costo unitario por partida), con `…29_prerecibo_resumen_oc.sql` agregando
  `unidades_totales`/`total_estimado` a la vista `v_recibo_ocs` (calculado al vuelo, sin columnas nuevas de
  tabla). Folio de confirmación con formato "PRE-000038" (solo texto, mismo id de `pre_recibos`). Pendiente:
  correr ambos SQL nuevos y probar en el celular; decidir el alcance del memorándum (roles, vales de caja)
  cuando el usuario retome el tema.
- Archivos tocados (lo último): `js/catalogo.js`, `version.json`. Reportado con captura (dos subventanas del
  mismo producto #258, Granel Miel Bee Power): "Editar artículo" mostraba "🧪 Revisión del granel — 6 de 6
  listos" con Rendimiento del lote en 10 Kilogramos ✅, mientras "🧪 Editar o ver BOM" (abierta al mismo
  tiempo) seguía en "4 de 5 listos" con "Sin Rendimiento del lote" ⚠️ — parecía el mismo bug de
  desincronización entre subventanas de sesiones pasadas, pero NO lo era: investigado a fondo, la "Revisión
  del granel" de "Editar artículo" (`pintarGranel` → `val('rendimiento_lote_bom', art.rendimiento_lote_bom)`)
  siempre lee el VALOR VIVO del campo del formulario (aunque no se haya guardado — se recalcula en cada
  tecleo o al usar el botón 🧮 "Usar X..." de ahí mismo, que solo llena el campo y avisa "Luego da 'Guardar
  cambios'."), a propósito, como vista previa. El usuario había escrito/usado el 10 Kilogramos en "Editar
  artículo" pero SIN darle "Guardar cambios" todavía — por eso BOM (que sí lee el dato ya guardado en la
  base) seguía mostrando el estado real. No era una falla del refresco entre ventanas, sino que no había
  ninguna pista de que esos ✅/⚠️ eran una vista previa sin guardar. Se agregó `sinGuardar` a `htmlGuiaGranel`
  (calculado en `pintarGranel` comparando cada campo vivo contra `art.*`, el valor con el que se cargó el
  modal) — cuando difiere de lo guardado, aparece un aviso "✏️ Esto es una vista previa... todavía sin
  guardar — otras subventanas... van a seguir mostrando el dato guardado hasta que des 'Guardar cambios'."
  arriba de la lista ✅/⚠️. Solo aplica a "Editar artículo" — el llamado de "Editar o ver BOM" a la misma
  función (`htmlGuiaGranel`) ya usa el dato guardado (`producto.rendimiento_lote_bom`, refrescado por
  `refrescarBomSiEsProducto`), nunca un valor de formulario sin guardar, así que no necesita el aviso.
  Pendiente: probar en el navegador — escribir/usar "Usar X" en Editar artículo sin guardar y confirmar que
  aparece el aviso; darle "Guardar cambios" y confirmar que BOM se actualiza solo (ya funcionaba) y el aviso
  desaparece.
- Archivos tocados (lo último): `sql/2026-09-26_tareas_cancelada.sql` (nuevo), `js/tareas.js`, `version.json`.
  Bug reportado con captura del Historial de tareas: "Comprar: Miel de Abeja", cancelada a mano con el botón
  nuevo "🚫 Cancelar" (sesión anterior), se guardaba con estatus `'archivada'` — el mismo que usa el sistema
  para "la condición ya no aplica" (stock recuperado, fecha de caducidad capturada...), quedando indistinguible
  en el Historial de un cierre automático. El usuario pidió que quede su propio estatus. Se agregó
  `'cancelada'` como estatus real (antes solo se reusaba `'archivar'`): constraint de `tareas.estatus` ampliado,
  nueva acción `'cancelar'` en `tarea_resolver()`, y el índice único parcial `tareas_entidad_viva_uq` +
  `tareas_sync_inventario()` + `tareas_sync_caducidad()` (las versiones VIGENTES: `…10-12_sugerido_pedir_entero.sql`
  y `…09-10_caducidad_solo_obligatorios.sql`, no las originales de `…09-06`/`…09-09`) tratan `'cancelada'`
  igual que `'archivada'` — no cuenta como tarea "viva", así que si la condición que la generó sigue vigente
  el sincronizador crea una tarea nueva sola (mismo comportamiento ya documentado la sesión pasada, ahora con
  el estatus correcto); y si la condición deja de aplicar, el auto-archivado NO le pisa el estatus a una que
  ya se canceló a mano. 3 escenarios simulados y probados en Postgres local (crear stub de `productos`/
  `unidades_medida`/`lotes_inventario`, correr las 5 migraciones en orden): cancelar y confirmar estatus
  `cancelada`; con la condición aún vigente, el sync crea una tarea nueva pendiente sin tocar la cancelada;
  con la condición resuelta, el sync archiva solo la pendiente nueva, la cancelada se queda igual. `js/tareas.js`:
  el botón ahora llama `resolverTarea(b, 'cancelar', ...)` (antes `'archivar'`); `ESTATUS_LABEL`/`ESTATUS_BADGE`
  ganan `cancelada: 'Cancelada'` (badge rosa, distinto del gris de "Archivada") — el filtro del Historial ya
  arma sus opciones desde ese objeto, no necesitó tocarse aparte. Pendiente: correr
  `sql/2026-09-26_tareas_cancelada.sql` en Supabase y probar el botón "🚫 Cancelar" en el navegador — confirmar
  que el Historial ya distingue "Cancelada" de "Archivada".
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
- `buscador-productos.js` — `montarBuscadorProductos()`: input con sugerencias de productos (SKU o nombre) mientras se escribe.
- `buscador-select.js` — convierte un `<select>` largo en un buscador con teclado, sin cambiar su comportamiento.
- `catalogo.js` — dos pantallas separadas: `cargarModuloAltaArticulo` ("Alta de artículo", solo el
  formulario: alta/edición por nombre, clasificación, BOM) y `cargarModuloCatalogoKardex` ("Catálogo y
  Kardex", el listado general con ☰ acciones, export Excel/CSV, y el panel de Kardex embebido al elegir un artículo).
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
- `impresion.js` — motor ÚNICO de impresión (`imprimirConPlantilla`, `imprimirHtml`): estilo compacto estándar + plantillas (encabezado/logo/pie). Todo documento imprimible nuevo pasa por aquí, no por `window.print()` directo.
- `indice.js` — índice/mapa de todos los módulos del ERP con acceso directo.
- `info-proveedor-producto.js` — cómo identifica y vende un proveedor específico un producto (SKU/descr./unidad
  + última compra real).
- `inventario.js` — stock general por producto y lote, con mínimos y deterioro de inventario (NIF C-4).
- `isr.js` — tabla ISR versionada (tarifas de retención sobre sueldos) + extracción desde PDF/OCR.
- `kardex.js` — `renderizarKardexProducto` (movimientos de UN producto, embebidos en Productos) + `cargarModuloKardex` (Inventario → Kardex: visor por fechas y varios productos). También trae
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
- `proveedores.js` — catálogo de proveedores + re-exporta `REGIMENES` (vive en `regimenes-fiscales.js`).
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
- `tablas.js` — Configuración → Tablas: visor de solo lectura de `unidades_medida` y `monedas` (columnas dinámicas, buscador).
- `regimenes-fiscales.js` — catálogo SAT de regímenes (tabla `c_regimen_fiscal`, respaldo en código): `cargarRegimenes()` y `opcionesRegimen()` para todos los selects.
- `tareas.js` — bandeja de pendientes (inventario bajo mínimo, caducidad próxima, nómina en borrador...) con historial.
- `trazabilidad.js` — antecedentes de proceso: Requisición → Orden de compra → Documento(s) de recepción.
  También `abrirSeguimientoPedido`: seguimiento 🔗 de un pedido de venta (producción/requisición → OC → recepción → surtidos).

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
