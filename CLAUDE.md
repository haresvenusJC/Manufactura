# Hares de México — guía para trabajar en este repo

> **Al iniciar sesión:** antes de cualquier otra cosa, muestra al usuario los pendientes de la sección Pendiente de este archivo (en viñetas cortas, sin detalle técnico) y pregunta por cuál quiere empezar. No ejecutes ninguno sin su confirmación.

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

## Última sesión

- Archivos tocados (lo último): `js/empleados.js`, `js/departamentos.js`, `version.json`, `CLAUDE.md`. **Empleados: «Rol en el departamento» → «CARGO QUE OCUPA EN EL DEPARTAMENTO» (pedido del usuario 2026-10-30) y el campo Gerente se quita de la pantalla.** El cargo va a la derecha del Departamento (Responsable de Departamento / Colaborador de Departamento). El Gerente ya NO se captura: `gerente_id` se calcula con la regla de homologación al guardar y `homologarGerentes()` (exportada de `empleados.js`) lo rehomologa para todos después de guardar un empleado o un departamento (colaborador → responsable de su departamento; responsable → responsable del departamento superior más cercano con uno); si no hay a quién asignar se conserva el actual. El `<select id="empGerente">` queda oculto (`data-sin-buscador`) solo para no romper la lógica. El Organigrama y las firmas siguen leyendo `gerente_id`. Solo sintaxis verificada.

- Archivos tocados (lo último): `js/departamentos.js`, `js/empleados.js`, `js/vinculos.js`, `version.json`, `CLAUDE.md`. **Departamentos: «Responsable» pasa a ser un buscador «Elegir Empleado» con «➕ Crear y editar…»** (pedido del usuario 2026-10-30). Lista los empleados activos; si no está, «Crear y editar…» abre la plantilla de Empleados en subventana (nueva entidad `empleado` en `vinculos.js`; `empleados.js` avisa al guardar con `avisarRegistroGuardado`) y regresa con la persona elegida. Al guardar el departamento se escribe en la plantilla del empleado (única fuente): `departamento_id`, `departamento` y `rol_departamento='responsable'`; el responsable anterior pasa a Colaborador y, si la persona estaba en otro departamento, se pide confirmar. Dejarlo vacío quita al responsable (queda Colaborador). Sin el SQL `…10-30_departamento_superior_rol.sql` el campo es el selector de antes. Solo sintaxis verificada. Pendiente: probar con la base real.

- Corrección del usuario (mismo día): la lista del Responsable muestra SOLO empleados activos con rol «Responsable de Departamento» en su plantilla (con su departamento actual al lado); «Crear y editar…» sale siempre (aun con la lista vacía: `crearVacio` en `buscador-select.js`) y abre Empleados (crear uno nuevo o editar a alguien de su lista); si el empleado guardado no quedó como Responsable, avisa y no lo elige. `js/departamentos.js`, `js/buscador-select.js`.

- Archivos tocados (lo último): `js/departamentos.js`, `js/empleados.js`, `version.json`, `CLAUDE.md`. **Correcciones del usuario 2026-10-30 a Departamentos/Empleados:** (1) la herencia de tipo y centro de costo es SOLO de un departamento a su SUBDEPARTAMENTO (el campo «Subdepartamento» al guardar); elegir «Departamento superior» ya NO prellena nada. (2) **Homologación** de las dos jerarquías (departamentos y personas): regla única — colaborador → su Gerente es el responsable de su departamento; responsable → su Gerente es el responsable del departamento superior más cercano que tenga uno. En Empleados el Gerente se sugiere solo al elegir departamento o rol (nunca pisa una elección manual); en Departamentos aparece un aviso con los empleados cuyo Gerente difiere del esperado y el botón «Homologar Gerentes». Sin SQL nuevo (usa `…10-30_departamento_superior_rol.sql`, NO corrido). No es «tiempo real» entre pantallas: cada una lee la base al abrirse. Solo sintaxis verificada.

- Archivos tocados (lo último): `sql/2026-10-30_departamento_superior_rol.sql` (nuevo, **NO corrido**), `js/departamentos.js`, `js/empleados.js`, `version.json`, `CLAUDE.md`. **Departamento superior + rol del empleado en su departamento** (pedido del usuario 2026-10-30). (1) `departamentos.departamento_padre_id` (jerarquía sin círculos, trigger): la pantalla Departamentos gana «Departamento superior» (buscador con placeholder «Elija uno» que se borra al escribir/elegir, y «➕ Crear y editar…» que abre una mini-subventana de alta), «Subdepartamento» (texto: al guardar se crea como HIJO con el tipo y centro de costo del padre; ej. Finanzas → Cuentas por pagar) y la lista sale en árbol con sangría. Al elegir superior en un departamento nuevo se prellenan tipo y centro de costo (editables). (2) `empleados.rol_departamento` ('responsable'/'colaborador', único responsable activo por departamento con índice parcial): en Empleados nuevo selector «Rol en el departamento» (Responsable de Departamento / Colaborador de Departamento); el puesto sigue siendo texto libre («Jefe de Contabilidad») y la etiqueta oficial la da el rol; si ya hay otro responsable pide confirmar y lo pasa a Colaborador; la lista muestra el rol. (3) El responsable YA NO se captura en Departamentos (caja de solo lectura «Llenar» + enlace a Empleados): un trigger recalcula `departamentos.responsable_id` desde el rol, así que `firmas.js`, Organigrama y la sugerencia de Gerente no cambian. El SQL rellena roles de lo existente (el responsable previo si pertenece a ese departamento; los demás, colaboradores). Sin el SQL ambas pantallas funcionan como antes y avisan. Solo sintaxis verificada; sin probar renderizado. **Pendiente:** correr `…10-28_departamentos_gerente_foto.sql` y `…10-28b_firmas_requisicion.sql` (si no) y luego este; probar crear Finanzas + subdepartamento, elegir superior con «Elija uno», marcar un Responsable y ver que Departamentos lo muestre; el Organigrama sigue saliendo del Gerente (no de la jerarquía de departamentos).

- Archivos tocados (lo último): `js/catalogo.js`, `version.json`, `CLAUDE.md`. **Alta de artículo: «Cuenta de costo» se oculta en Activo fijo** (pedido del usuario 2026-10-29/30). Sesión también de **análisis normativo sin código**: caso de gel (granel + envasado) costeado contra NIF C-4/C-6 y RCFF art. 33-35, con textos oficiales que el usuario pasó (extracto NIF C-4 y PDF NIF 2024 C-4 pp. 888-922, NIF 2024 C-6 pp. 941-992, RCFF 2026). El «Base bibliográfica de costos.docx» NO es confiable (párrafos y citas inventados). No se tiene CFF art. 28/29 ni LISR. **Pendiente para mañana: la TABLA DE CONTRASTE ERP vs CFF/RCFF/NIF** (ver sección Pendiente).

- Archivos tocados (lo último): `js/asistente-prorrateo.js`, `version.json`, `CLAUDE.md`. **Se quitó la lista sugerida de «Equipos típicos»** del paso 3 · Luz del Asistente de llenado (chips «＋ Llenadora…», ✅ si ya hay uno parecido; pedido del usuario 2026-10-28: él arma su propia lista de equipos desde Activos fijos). Queda solo «＋ Dar de alta un equipo» (renglón en blanco) y la lista de lo ya dado de alta; las sugerencias de ÁREAS del paso 2 se conservan. Sin SQL.
- Archivos tocados (lo último): `index.html`, `js/indice.js`, `manual-costos-produccion.html`, `js/asistente-prorrateo.js`, `version.json`, `CLAUDE.md`. **Menú reordenado hacia SAP (decidido 2026-10-28, tras revisar `MANUAL_INTEGRAL_DE_MÓDULOS_SAP`)**: (1) nuevo grupo **Capital Humano** (≈HCM): Empleados, Departamentos, Organigrama, Nómina (salió de Finanzas) y Tabla ISR (salió de Contabilidad); (2) **Catálogos se conserva** y SUS pantallas se repiten, misma vista, en su módulo: Proveedores en Compras, Alta de artículo y Productos en Inventario, Clientes y Listas de precio en Ventas (Empleados también sigue en Catálogos; **Departamentos y Organigrama se quitaron de Catálogos a petición del usuario 2026-10-28 y viven solo en Capital Humano**); (3) **Costos** (≈CO) es grupo propio, ya no submenú de Contabilidad (Asistente de llenado, Centros de costo, Áreas y bases de prorrateo, Reparto de gastos compartidos, Prorrateo de gastos); Finanzas (≈FI-AP/AR/BL/AA) y Contabilidad (≈FI-GL) quedan separadas; (4) Utilerías y Configuración NO se tocaron. Rutas del manual/asistente: "Menú → Costos → …". **Pendiente (dudas sin resolver, para más adelante):** Pagos a proveedores (¿solo en Finanzas?), dónde queda Recibo de mercancía vs. factura (MM-IV), partir Tareas por origen, mover Activos fijos, ligar departamentos a módulos con las funciones; calidad (QM) y mantenimiento (PM) sin pantallas. Sin SQL. Sin probar renderizado (solo estructura HTML/sintaxis).
- Archivos tocados (lo último): `js/firmas.js`, `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Decisiones del usuario 2026-10-28:** la foto NO sale en los documentos impresos, SÍ en pantalla como icono pequeño (Odoo): `conFotos`/`htmlIconoPersona` (`print:hidden`) junto a Solicita y en las firmas del detalle de la requisición y de la ODC. Almacén: sin tipo, "dame tiempo". Límite de monto de autorización: NO habrá; queda libre y responde el jefe que autoriza. Subido a `main` con "comitea".
- Archivos tocados (lo último): `sql/2026-10-28_departamentos_gerente_foto.sql` y `sql/2026-10-28b_firmas_requisicion.sql` (nuevos, **NO corridos**), `js/departamentos.js`, `js/organigrama.js`, `js/fotos-personal.js`, `js/firmas.js` (nuevos), `js/empleados.js`, `js/requisiciones-compra.js`, `js/ordenes-compra.js`, `js/app.js`, `js/indice.js`, `index.html`, `version.json`, `CLAUDE.md`. **Recursos humanos al estilo Odoo + responsables en los documentos** (pedido del usuario 2026-10-28). (1) Tabla `departamentos` (nombre único sin importar mayúsculas, tipo = mismo criterio de `centros_costo`, centro de costo, responsable, activo); el equipo NO se captura: son los empleados con ese departamento. (2) `empleados` gana `departamento_id`, **`gerente_id`** (UN gerente por empleado; vacío = cabeza de la organización; trigger que impide ser su propio gerente o círculos) y `foto_path` (bucket PRIVADO `fotos-personal`, URL firmada, foto comprimida a 480 px). `empleados.departamento` (texto) se conserva y la pantalla lo sigue escribiendo; los 4 valores viejos se volvieron filas de `departamentos` (Almacén queda sin tipo: decisión pendiente). (3) Pantallas: Empleados (selector de departamento desde la tabla, **Gerente**, **foto**; al elegir departamento sin gerente se sugiere el responsable), Catálogos → **Departamentos** y Catálogos → **Organigrama** (árbol plegable que sale solo del Gerente; avisa si hay varias cabezas). Sin la migración, Empleados funciona como antes y avisa. (4) **Firmas**: `js/firmas.js`; la requisición gana `departamento_id`, `solicitante_empleado_id` y `autorizada_por_empleado_id`: al CREARLA se elige Departamento y luego "Solicita" (solo gente de ese departamento; obligatorio, se valida antes de gastar el folio); en el detalle/impresión salen **Solicita/Departamento** y las firmas con el nombre sobre la línea y rol · puesto · departamento debajo; "Revisó y autorizó" = el fijado en el panel "Responsables del documento" (no se imprime) o, si no hay, el **Gerente del solicitante**; la ODC impresa usa lo mismo (solicitante de la ODC o de su requisición). Mientras no haya claves por persona esto es una lista desplegable (responsabilidad declarada, no autenticada). Probado en Postgres local (2 corridas de cada SQL; auto-gerente, círculos y nombres repetidos se rechazan; se corrigió un error real del backfill con "Producción"/"producción") y en Chromium con Supabase simulado (31 comprobaciones). **Pendiente:** correr en Supabase, EN ORDEN, `…10-28_departamentos_gerente_foto.sql` y luego `…10-28b_firmas_requisicion.sql`; capturar departamentos con su responsable y el Gerente de cada empleado; probar con foto real. **Regla pedida por el usuario (NO implementada):** la autorización NO debe subir toda la cadena: una caja de hojas o cinta por $3,000 pedida por Almacén no necesita a la directora; habrá que definir **límites de autorización por monto/nivel** (jefe inmediato hasta X, siguiente nivel arriba de Y; parámetros por definir con el usuario) antes de bloquear nada. No se tocó: Pedidos de venta, pagos, nómina, ni los demás documentos (solo requisición y ODC muestran responsables).
- Archivos tocados (lo último): `CLAUDE.md` (solo documentación; **sin subir**). Sesión 2026-10-20/28 de análisis, sin cambios de código: (1) diagramas ISO 5807 de Costos y prorrateo (5 hojas) y de seguimiento de la compra de una envasadora y su depreciación; (2) estrategia de departamentos y funciones; (3) referencia de reparto del menú tipo SAP (sección nueva arriba); (4) análisis del flujo Requisición → COT → ODC → recepción → factura y de las diferencias. **Hallazgos sin resolver:** el alta de Activos fijos no se liga a la ODC ni a la recepción, y el recibo carga a inventario toda partida; Cierre de periodo no revisa depreciación ni prorrateo; no hay autorizador ni aviso cuando una recepción difiere de la factura (NDC/NDP sin autorizado_por). Regla pedida por el usuario: **en los diagramas de flujo solo dibujar lo que el ERP hace de verdad; lo que falta se marca como "falta", y verificar cada caja contra el código.**
- Archivos tocados (lo último): `js/tablas.js`, `js/tareas.js`, `js/indice.js`, `index.html`, `version.json`, `CLAUDE.md`. **Umbrales de caducidad pasan a Configuración → Tablas → "Umbral caducidades"** (pedido del usuario 2026-10-16): el panel "Alertas de caducidad — umbrales" (tabla `alertas_caducidad_umbrales`: días, etiqueta, prioridad, activo; agregar/activar/quitar) ya NO está al pie de Tareas de almacén; vive como nueva tabla de apoyo (`cargarEditorUmbralesCaducidad` en `tablas.js`, `window.loadView('tablas', {tabla:'umbral_caducidad'})`, entrada en el submenú Tablas y tarjeta en el Índice). Misma lógica: al cambiar un umbral se corre `tareas_sync_caducidad` y se avisa que las Tareas de almacén ya lo reflejan (antes recargaba Tareas). Sin SQL. Pendiente: probar agregar/activar/quitar un umbral en la pantalla nueva y ver que Tareas ya no lo muestra.
- Archivos tocados (lo último): `js/kardex.js`, `js/filtro-columna.js`, `js/asistente-contable.js`, `index.html`, `version.json`, `CLAUDE.md`. **Kardex (menú Inventario) con todos los estándares del ERP** (pedido del usuario 2026-10-16): (1) clase `lista-completa` (marco hasta el borde inferior, encabezado fijo, solo las filas se desplazan); (2) píldora "Ayuda" (guía `kardex` + manual `#m-kardex`) y se quitó la tarjeta/subtítulo del HTML; (3) UNA sola tabla para todos los productos: fila de grupo por producto (nombre, SKU, unidad, stock actual y tarjetas Saldo inicial/Entradas/Salidas/Saldo final) y sus movimientos debajo (antes un bloque con su propia tabla por producto); (4) filtros ▼ en Operación, Lote y Cantidad (entradas/salidas) con conteos y orden ⇅ (Fecha, Operación, Lote, Costo, Cantidad) dentro de cada producto — los saldos/totales son del periodo completo, los filtros solo ocultan filas; "Quitar filtros" y contador de movimientos; (5) estado vacío centrado con la ilustración ("Sin consulta todavía…"), mensajes de consulta/error en la misma tabla; (6) optimización: los productos elegidos se consultan en PARALELO (antes uno tras otro); (7) `hoyISO` compartido (hora local); (11) **saldo corriente del PRODUCTO (todos los lotes juntos)**: Stock ant./Stock nuevo parten de la fila anterior en orden cronológico (antes era POR LOTE y cada lote arrancaba en 0; el Kardex embebido de Productos conserva el cálculo por lote porque ahí hay filtro de lote); (10) orden visual: PRIMERO el resumen del producto (nombre, SKU, saldo inicial/entradas/salidas/saldo final) y DEBAJO los encabezados de columna (con un producto ambos en el thead fijo; con varios, cada uno trae su resumen + encabezados en el cuerpo); (9) orden por default: LO MÁS ANTIGUO ARRIBA (cronológico; cada consulta nueva vuelve a él) y el menú ▼ de la columna Doc ID deja elegir "Más nuevo arriba"; (8) la columna Doc ID muestra el FOLIO del documento (OPC-…, ENT-…, ODC-…; `adjuntarFoliosDocumento`, una consulta por los ids distintos; vale también para el Kardex embebido de Productos y el CSV) en vez de "#id". Imprimir saca lo que se ve (con filtros); el CSV exporta el periodo completo sin filtros. Sin SQL. Sin probar renderizado: pendiente Ctrl+Shift+R con 2-3 productos (sobre todo menús ▼, desplazamiento, impresión).
- Archivos tocados (lo último): `js/filtro-columna.js` (nuevo), `js/inventario.js`, `index.html`, `version.json`, `CLAUDE.md`. **Stock General (menú Inventario) rediseñado con filtros por columna** (pedido del usuario 2026-10-16: "filtro de columna… todas las columnas que tengan filtros"): los 4 grupos plegables con paginación de 10 se reemplazaron por UNA tabla `lista-completa` (encabezado fijo, solo las filas se desplazan) con menú ▼ en el encabezado de **Clasificación, Unidad, Existencia/Stock, Reservado, Libre y Costo unitario** (cada opción con su conteo, que respeta los demás filtros; "Quitar filtros" y contador "N de M artículos") + orden ⇅ en todas + el buscador por SKU/nombre de siempre (filtro de la columna Elemento). Reservado/Libre solo si la migración de reservas está corrida (como antes) y solo tienen valor en terminados. `filtro-columna.js` es el componente reutilizable (`thColumna`, `wireFiltrosColumna`) para llevar el mismo patrón a otras pantallas (Cuentas por pagar y Requisiciones tienen su propia versión: unificar es opcional). No se tocó la tabla de Lotes ni ninguna consulta/SQL. Sin probar renderizado: pendiente Ctrl+Shift+R (revisar que los menús ▼ no se corten, anchos de columna y el desplazamiento con 262 filas).
- Archivos tocados (lo último): `js/fechas.js` (nuevo), 30 módulos de `js/` (los que usan `hoyISO`/fechas), `sql/2026-10-16_zona_horaria_mexico.sql` (nuevo, **falta correrlo**), `version.json`, `CLAUDE.md`. **Todo documento se guarda con la fecha real de ejecución** (pedido del usuario 2026-10-16; origen: lote #78 de OPR-000001 mostraba 15/10 siendo 16/10). Hallazgos: (1) **PANTALLA:** `new Date('2026-10-16').toLocaleDateString()` toma la fecha sin hora como UTC y en México muestra el día ANTERIOR (Lotes, deterioro, documentos, compras, entradas, salidas, proveedores, órdenes de compra, trazabilidad) → `fechaLocalTxt()` en `fechas.js`. (2) **CLIENTE:** 16 módulos definían `hoyISO = new Date().toISOString().slice(0,10)` (UTC: después de las 18:00 en México daba el día siguiente) y ~15 sitios más lo repetían inline → ahora un solo `hoyISO()` local en `fechas.js` (también `isoLocal`, `diasDesdeHoyISO`). (3) **BASE:** 57 usos de `current_date` en funciones SQL (Supabase corre en UTC) → un solo `alter database postgres set timezone to 'America/Mexico_City'` (sin reescribir funciones). Quedan fuera a propósito: nombres de archivo exportado y fechas calculadas desde otra fecha (`sigMes`, fin de nómina). No se re-fecha lo ya guardado. Pendiente: correr el SQL, verificar con `select current_setting('TimeZone'), current_date`, probar un documento después de las 18:00; los jobs de pg_cron corren en UTC (el de las 07:15 sería 01:15 en México) — revisar aparte.
- Archivos tocados (lo último): `sql/2026-10-24_requisicion_resurtir.sql` (nuevo, **NO corrido**), `js/requisiciones-compra.js`, `js/info-proveedor-producto.js`, `js/ordenes-compra.js`, `version.json`, `CLAUDE.md`. **Requisición con pestañas «Resurtir» / «Compra nueva» + detalle de la ODC en formato de renglón sombreado** (aprobado por el usuario 2026-10-24, con maqueta https://claude.ai/artifact/WiMiTomWGg5jhpQSdcmGhb). «Nueva requisición de compra» gana dos pestañas arriba del renglón de captura. **Resurtir** (default): el buscador lista TODO el catálogo; al «Solicitar», `obtenerUltimaCompraPagada` (`info-proveedor-producto.js`: última recepción de compra no cancelada con `total_pagado >= total`) trae proveedor, Clave UM, Clave SAT, número, descripción, factor y precio (de la ODC de esa recepción; si no, de «Claves de proveedor» y del costo × factor). La línea se pinta en el formato de la generación de la ODC (renglón editable Cant./Clave UM/Clave SAT/Número/Descripción/P. unitario/Importe + renglón sombreado con cantidad, unidad, SKU y producto; `reqRenderResurtir`; sin «× factor» ni etiqueta de factura). Si el producto nunca se ha comprado y pagado: pop-up «no se ha comprado anteriormente» → Cancelar / «Ir a Compra nueva». **Compra nueva**: formato de siempre; si el producto ya se compró: pop-up con destello «ya se ha comprado anteriormente» → «Continuar como compra nueva» / «Ir a Resurtir». Nunca bloquea: pueden mezclarse líneas completas e incompletas (dos tablas seguidas); el documento es siempre «Requisición de compra». El pop-up es `reqPregunta` (cuadro propio, `data-no-movible`, Enter = principal, Esc = secundario; respeta `prefers-reduced-motion`). Guardado: columnas nuevas en `requisiciones_compra_detalle` (`modo_captura`, `clave_unidad_sat`, `clave_prod_serv_sat`, `precio_proveedor`, `origen_factura`); sin el SQL guarda como antes. `reqAutorizar`: las líneas de Resurtir llegan precargadas con esos datos (editables; el catálogo de claves no las pisa; cantidad del proveedor = cantidad ÷ factor). Detalle/impresión de la REQUISICIÓN (`abrirDetalleReq`): ya NO consulta «Claves de proveedor»; la caja del proveedor solo aparece si hay líneas de Resurtir (datos guardados, «referencia»); Compra nueva = solo lo nuestro + proveedor sugerido + costo estimado (la caja «Nuestro inventario» lleva ahora el total estimado). **Detalle/impresión de la ODC** (`renderVistaOC`): una sola tabla de partidas — renglón del proveedor y, debajo, renglón sombreado con cantidad/unidad nuestras, «× factor», SKU, producto y costo c/u, más una línea con solicitado/recibido/notas (reemplaza las dos cajas). Probado en Chromium con base simulada (requisición: Resurtir con datos de factura, pop-ups en ambos sentidos, mezcla y payload del guardado; detalle de la ODC); sin probar contra la base real ni la impresión en papel. **Pendiente:** correr `sql/2026-10-24_requisicion_resurtir.sql`; los tags «con factura» en la lista de sugerencias no se hicieron (la búsqueda de compra previa se hace al «Solicitar», una sola consulta); las líneas de Resurtir no muestran MOQ. **Orden de SQL pendiente:** …23b → …23c → …24.

- Archivos tocados (lo último): `js/ordenes-compra.js`, `js/importador-claves-proveedor.js`, `version.json`, `CLAUDE.md`. **ENTREGA 5 de 5: recepción por XML contra la cotización.** (1) Recibo de mercancía con ODC: si la partida trae la cotización en unidad del proveedor (`clave_unidad_sat` + `factor_conversion_proveedor`, de `…23c`) y el XML viene en ESA unidad, se convierte con ese factor (cantidad × factor; costo ÷ factor a 4 dec.) en vez de los presets; si la unidad del XML es otra, no convierte solo y avisa. Bajo cada partida emparejada sale una franja «Contra la cotización» (`rmPintarCotizacion`, `rmCotizacionDeLinea`): ✓ si coincide o, en ámbar, las diferencias de cantidad, precio, importe (±$0.01), Clave UM, Clave SAT y número; solo informa, no bloquea (cantidad e importe solo se comparan si la partida no tiene recepciones previas). (2) Recepción directa por XML sin ODC: si el proveedor ya tiene unidad SAT + factor en «Claves de proveedor» para el producto emparejado y el XML viene en esa unidad, la partida entra ya en tu unidad (con aviso). (3) Homologación a mano (recepción por XML) e importador de claves: guardan `clave_unidad_sat` + `factor_conversion` SOLO si el factor se deduce con seguridad (`factorSugeridoSat`); si no, la clave se guarda sola y el importador avisa «captura el factor en Alta de artículo». Sin SQL nuevo; todo degrada si faltan `…23b`/`…23c`. Probado: sintaxis y la función de comparación en Node (21 MIL × $3,560.5689 → 21,000 × $3.5606; unidad/SAT/número distintos); SIN probar renderizado ni contra la base real. **Pendiente (aprobado en maqueta, sin código):** pestañas Resurtir / Compra nueva en «Nueva requisición de compra» (maqueta https://claude.ai/artifact/WiMiTomWGg5jhpQSdcmGhb; plan presentado, falta aprobar), y decidir si el detalle de la ODC pasa al formato de renglón sombreado.

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Pantalla «Generación de Orden de Compra» más limpia** (pedido del usuario con captura marcada): el segundo renglón de cada partida ya NO es texto («Nuestro: …», equivalencias, «Solicitado», chip «de Claves de proveedor» se quitaron): es un renglón SOMBREADO alineado bajo las columnas con lo que pidió la requisición — cantidad solicitada, unidad, SKU y producto — y SOLO el campo «× factor» (en la columna Clave SAT, solo si el proveedor vende en otra unidad; borde ámbar si falta). Sin proveedor en el renglón ni encabezado extra. En una ODC manual el renglón muestra la cantidad ya convertida a tu unidad. El aviso de escala (costo por unidad >5× distinto) ahora es borde ámbar en Cant. con tooltip. **Pendiente de confirmar con el usuario:** el detalle/impresión de la ODC (dos cajas) y el de la REQUISICIÓN (debe llevar SOLO lo nuestro + proveedor sugerido + costo estimado, sin claves ni unidad SAT del proveedor: datos sin confirmar) siguen como en la entrega 4.

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **ENTREGA 4 de 5: impresión de la REQUISICIÓN con ambos lados** (el detalle `abrirDetalleReq` es también su impresión, vía `imprimirConPlantilla`). Misma tabla que el detalle de la ODC (decisión del usuario: DOS CAJAS por documento, unidas por el número de partida «#»: arriba «Cotización del proveedor / Como lo vende el proveedor sugerido» con Cant., Clave UM, Clave SAT, Número, Descripción, P. unitario e Importe + totales; abajo «Nuestro inventario · notas y observaciones» con SKU, Producto, Cantidad, Unidad, Costo c/u, Equivalencia y Observaciones [solicitado/recibido/notas en la ODC; proveedor sugerido y «sin claves» en la requisición]): renglón del proveedor sugerido (Cant. en SU unidad = cantidad ÷ factor, Clave UM, Clave SAT, Número, Descripción, P. unitario = costo × factor a 4 dec., Importe) y debajo «Nuestro: nombre · SKU · cantidad × costo c/u · 1 MIL = 1,000 Piezas · Proveedor». Se lee de «Claves de proveedor» con UNA consulta `in(producto_id)` (cae al select viejo sin las columnas SAT); sin claves capturadas el renglón va en tu unidad y lo avisa. El precio es solo estimado (la cotización real se captura en la ODC). La impresión de la ODC ya salía de `renderVistaOC` (entrega 3) con el mismo formato, sin cambios. Probado en Chromium con base simulada (20 MIL × $3,000 = $60,000.00 vs 20,000 pzas × $3.0000; partida sin claves en su unidad); sin PDF real ni base real. **Falta:** entrega 5 (recepción por XML contra la cotización; importador de claves y homologación con unidad SAT).

- Archivos tocados (lo último): `sql/2026-10-23c_odc_cotizacion_proveedor.sql` (nuevo, **NO corrido**), `js/requisiciones-compra.js`, `js/ordenes-compra.js`, `js/pagos-proveedor.js`, `js/info-proveedor-producto.js`, `js/formato.js`, `version.json`, `CLAUDE.md`. **ENTREGA 3 de 5: ODC con la cotización del proveedor en SU unidad.** La ODC NO se edita una vez creada; el momento editable es la subventana «Generación de Orden de Compra» (`reqAutorizar`, ahora ancha). Cada partida tiene DOS lados: fila del proveedor (Cant., Clave UM con buscador, Clave SAT con buscador, Número, Descripción, P. unitario, Importe; encabezados cortos en formato título) y debajo «Nuestro: … = 21,782 Piezas × $3.0040 c/u · Solicitado: 20,000 × $3.0000» con el **factor** (unidades de tu inventario por 1 unidad del proveedor). **Escalas (cuidado del usuario):** cantidad nuestra = cant. proveedor × factor; costo nuestro = precio proveedor ÷ factor a 4 decimales (21 MIL × $3,560.5689 → 21,000 × $3.5606); **importe oficial = cant. proveedor × precio proveedor** (`importe_proveedor`, p. ej. 21.782 × 3,004 = $65,433.13) y de ahí salen subtotal, IVA y anticipo; el costo interno es derivado. Se precarga desde «Claves de proveedor» (número, descripción, clave SAT, unidad SAT y factor) y, mientras el comprador no capture cantidad ni precio, se reexpresa lo solicitado en la unidad del proveedor (20,000 pzas × $3 con MIL×1000 → 20 MIL × $3,000). Sin factor con unidad SAT no deja; aviso si el costo por unidad se aleja >5× de lo solicitado. **Pop-up de diferencias** (solo ODC desde requisición): cantidad/costo/importe cotizado vs solicitado en la unidad del inventario (ignora < $0.01 de importe y < media diezmilésima de costo), el comprador decide, nota opcional; se guarda en `ordenes_compra.diferencias_cotizacion/_nota/_por/_en`. SQL: columnas nuevas en `ordenes_compra_detalle` (`cantidad_solicitada`, `costo_solicitado`, `cantidad_proveedor`, `clave_unidad_sat` FK, `clave_prod_serv_sat`, `precio_proveedor`, `importe_proveedor`) y `odc_generar` reescrita COMPLETA (convierte y valida en la base; sin clave de unidad la partida va como siempre). Probado en Postgres local (21.782 MIL×$3,004 = 65,433.13; 21 MIL×$3,560.5689 → 21,000×$3.5606; sin factor rechaza; 2 corridas) y en Chromium con base simulada (formulario, reescalado, popup y payload; detalle de la ODC con las dos caras); sin probar contra la base real. El detalle de la ODC (`renderVistaOC`) ya muestra ambos lados (esto es también su impresión) y los totales de lista/CxP usan `importePartidaOdc`; degrada sin el SQL. **Falta:** entrega 4 (impresión de la REQUISICIÓN con ambos lados y revisar la de la ODC en papel), entrega 5 (recepción por XML contra la cotización; importador de claves y homologación con unidad SAT). La ODC manual relabelea Cantidad/Precio como cotizados; guardar el factor capturado de vuelta en «Claves de proveedor» no se hizo (se captura en Alta de artículo). **Orden de SQL pendiente:** los 4 de `catalogos_sat` → `2026-10-23b_…` → `2026-10-23c_…`.

- Archivos tocados (lo último): `sql/2026-10-23b_claves_proveedor_unidad_sat.sql` (nuevo, **NO corrido**), `js/factor-unidad-sat.js` (nuevo), `js/catalogo.js`, `version.json`, `CLAUDE.md`. **ENTREGA 2 de 5: unidad SAT y factor por proveedor y producto en «Claves de proveedor»** (Alta de artículo → «Claves de proveedor»). SQL: `producto_claves_proveedor.clave_unidad_sat` (FK a `c_clave_unidad`) + regla de integridad en la base: con unidad SAT el `factor_conversion` es OBLIGATORIO y > 0 (probado en Postgres local: sin factor, factor 0 y clave inexistente se rechazan; sin catálogo cargado avisa qué SQL correr; 2 corridas). Pantalla: se quitaron el preset «Unidad de venta del proveedor» (millar/gruesa/…) y su texto libre; ahora hay un buscador de **Unidad SAT con que vende ESE proveedor** (MIL, H87, KGM…) y el **Factor** (unidades de tu inventario por 1 unidad del proveedor). `factorSugeridoSat` precarga el factor: misma clave que la unidad del inventario → 1; peso/volumen/longitud → exacto con la tabla del BOM (KGM→kg 1, KGM→g 1000, GRM→kg 0.001, TNE→kg 1000); múltiplos de pieza (MIL 1000, DZN 12, GRO 144, H87/EA/XUN 1) solo si el inventario se cuenta en piezas; todo lo demás (caja, paquete, tambo, litro→kilo por densidad) queda VACÍO para capturarlo a mano — nunca se asume 1 a 1 en silencio. Al agregar la clave, si hay unidad SAT y no hay factor no deja. El mismo producto puede tener una fila por proveedor (A en MIL ×1000, B en H87 ×1). `unidad_factura` (texto) ahora se llena con el nombre SAT («Mil»), así que lo que ya leen Recepción/`info-proveedor-producto` sigue funcionando. Degrada sin el SQL (lee/guarda sin la columna). Alta de artículo también lee `unidades_medida.clave_sat` (de `…catalogos_sat_vinculo_unidades`). Probado: función de factor en Node (13 casos) y el formulario real de Alta de artículo en Chromium con Supabase simulado (buscador de unidad, factor MIL→Piezas 1000, Gramos+MIL queda vacío con aviso, alerta sin factor, la clave se agrega y se lista «Unidad proveedor: Mil [MIL] · 1 = 1,000 Piezas»); sin probar contra la base real. **NO tocado a propósito:** `js/importador-claves-proveedor.js` (guarda `unidad_factura` del XML sin unidad SAT ni factor: la regla de la base los exige juntos, así que no se llena `clave_unidad_sat` desde ahí) y la homologación de `ordenes-compra.js` (inserta clave sin unidad); ambas quedan para la entrega 5. Filas viejas (unidad en texto sin clave SAT) se muestran igual; para darles unidad SAT se eliminan y se vuelven a agregar. **Orden de SQL pendiente:** los 4 de `catalogos_sat` (10 partes de productos) → `2026-10-23b_claves_proveedor_unidad_sat.sql`.

- Archivos tocados (lo último): `sql/2026-10-23_catalogos_sat_estructura.sql`, `…_datos_unidad.sql`, `…_datos_prodserv_01..10.sql` (10 partes de ~320 KB, formato compacto: el SQL Editor cortaba el pegado de archivos de ~1.2 MB), `…_vinculo_unidades.sql` (todos nuevos, **NO corridos**), `js/catalogos-sat.js` (nuevo), `js/catalogo.js`, `js/tablas.js`, `js/indice.js`, `index.html`, `version.json`, `CLAUDE.md`. **Catálogos SAT de unidades y de productos/servicios — ENTREGA 1 de 5** de «cotización del proveedor con su unidad y su factor» (diseño aprobado por el usuario 2026-10-23). Fuente: `Unidad_de_medida_y_productos_y_servicios_SAT26.xlsx` (c_ClaveUnidad v2.0, 2,418 filas, TODAS incluso las poco usadas; c_ClaveProdServ v4.0, 52,513 claves de 8 dígitos como TEXTO). **Rapidez:** el catálogo NUNCA se baja al navegador; `sat_buscar_prod_serv(q, limite)` / `sat_buscar_unidad(q, limite)` (máx. 20, mín. 2 letras en producto; palabras en cualquier orden y sin acentos; solo dígitos = clave que empieza con; las claves en uso —`productos.clave_sat`, `producto_claves_proveedor.clave_sat`, `unidades_medida.clave_sat`— y las `comun` salen primero) con índice trigrama sobre `busqueda` (columna generada con `_sat_norm`). Medido en Postgres local: 1–25 ms. **Orden de corrida:** estructura → datos_unidad → datos_prodserv_01..10 (cualquier orden, ~320 KB cada una) → vinculo_unidades (agrega `unidades_medida.clave_sat` con FK y PROPONE clave por nombre solo donde está vacía: Piezas→H87, Kilogramos→KGM…; lista las que no reconoce en NOTICE). **Pantallas:** Configuración → Tablas → «SAT · Unidades (ClaveUnidad)» y «SAT · Productos y servicios» (visor con búsqueda en servidor, también en el Índice); Alta de artículo: «Clave SAT» y la del proveedor son buscadores (clic/↑↓/Enter, muestra qué es la clave o avisa si no está en el catálogo; el guardado sigue exigiendo 8 dígitos); editor «✏️ Editar / agregar unidades»: columna «Clave SAT» por unidad (valida contra el catálogo; sin el SQL `vinculo` se oculta y todo sigue como antes). Probado: SQL completo en Postgres local (2 corridas, mapeo, búsquedas) y el buscador en Chromium con base simulada (lista, teclado, clave inexistente, unidades); sin probar Alta de artículo ni el editor de unidades renderizados (solo sintaxis) ni nada contra la base real. NO se tocó el «Editar artículo» genérico (`clave_sat` sigue como texto libre ahí). **Siguientes entregas aprobadas:** (2) Claves de proveedor: clave UM SAT + factor a la unidad de inventario por proveedor y producto (MIL×1000, H87×1; peso/volumen automáticos con `conversion-unidades.js`; sin factor no se guarda); (3) ODC formal: captura de la cotización (cantidad, clave UM, clave SAT, número, descripción y precio del proveedor), conversión a la unidad interna y pop-up al generar si hay diferencia de cantidad, costo o importe contra la requisición (el comprador decide, nota opcional, queda quién/cuándo; sin tope que bloquee; ignora < $0.01) — reescribe `odc_generar` COMPLETA; (4) impresión de requisición y ODC con ambos lados (proveedor: Cantidad, Clave UM, Unidad, Clave SAT, Número, Descripción, P. unitario 4 dec., Importe; abajo «Nuestro: SKU · descripción · cantidad · costo por pieza»); (5) recepción por XML comparada contra la cotización. Regla de diseño: el stock y el BOM solo conocen UNA unidad por producto; la unidad del proveedor existe solo en la captura. El importe de la partida es el del proveedor (cantidad × precio), el costo interno se deriva y no se recalcula de él.

- Archivos tocados (lo último): `js/tareas.js`, `js/asistente-contable.js`, `js/app.js` (ya pasa `limpiarBusqueda`), `index.html`, `css/ui-moderno.css`, `version.json`, `CLAUDE.md`. **Tareas REDISEÑADA con filtros** (pedido del usuario 2026-10-23, propuesta aprobada completa): pantalla ahora titulada **"Tareas"** (antes "Contabilidad · Tareas", engañoso porque ahí viven también las de almacén), con pestañas **Pendientes | Historial** (el historial carga al abrir su pestaña) y clase `lista-completa`. Pendientes = (a) **contadores clicables** (Todas, Prioridad alta, Compras, Caducidad, Contables, Reaparecidas: un clic filtra, otro quita); (b) buscador (tarea, detalle o proveedor); (c) **UNA tabla** (reemplaza las tarjetas) con menú ▼ + orden ⇅ en Prioridad, Tipo, Área (Almacén/Contable), Proveedor y Estatus (Pendiente/Reapareció), conteos por opción, "Quitar filtros" y "N de M tareas"; orden por default = contables (nómina) primero, luego prioridad y antigüedad; (d) acción principal por renglón (Generar requisición / Ver en inventario / Autorizar / Ir a Nómina) + menú **⋯** (Atendida solo si no es de compra, No aceptada, Cancelar; nómina: Ir a Nómina, Cancelar nómina); (e) **acciones masivas**: casilla en el encabezado = todas las visibles; barra con Generar requisición (una por proveedor, solo las de compra), No aceptada y Cancelar a todas las marcadas (un solo plazo/motivo). Abrir la pantalla (`loadView`) limpia búsqueda y filtros; "Tareas de almacén/contables" del menú solo preseleccionan el filtro Área. Reglas que se conservan: las de compra siguen SIN "Atendida" manual. `css/ui-moderno.css`: `.lista-completa div.hidden{display:none!important}` (los paneles/pestañas ocultos ya no los pisa la regla flex); `?v=` CSS → `20261023150000`. Sin SQL. Probado en Edge headless con Supabase simulado (4 renglones: nómina → compras Alta → caducidad Normal; el contador Contables filtra a 1; seleccionar todas muestra la barra); sin probar en la app real.
- Archivos tocados (lo último): `js/tareas.js`, `js/app.js`, `sql/2026-10-23_diagnostico_migraciones_pendientes5.sql` (solo lectura; el usuario lo corrió: **TODO AL DÍA** — las 6 migraciones del 21-22 oct ya corridas), `version.json`, `CLAUDE.md`. **(1) Carpeta local homologada con GitHub** (2026-10-23, 55 archivos bajados de la sesión en la nube: `formato.js`, `vinculos.js`, `categorias-depreciacion.js` y 8 SQL del 21-22 oct; 0 diferencias por sha contra `4b6c962`). **(2) Tareas:** las contables (nómina pendiente/recordatorio del viernes) salen ARRIBA de las de almacén, y al ABRIR la pantalla (`loadView`) la búsqueda empieza vacía (`cargarModuloTareas(dep, {limpiarBusqueda:true})`); el reclamo "no veo la tarea de la nómina" era que la nómina #7 ya estaba `registrada` (autorizada), no un fallo. **(3) Zona horaria confirmada:** `nominas.created_at` ya sale con `-06`. **(4) Pendiente de contador:** `codigo-agrupador-SAT-plan-de-cuentas.html` (tabla de 137 cuentas, 17 por "Confirmar"; no está en el repo, se generó al vuelo). **Pendiente:** decisiones del usuario (liquidar resto de ODC contado antes de recibir; maqueta del historial de pagos), % de anticipo 0–100, cuadre 115.01, Pedidos de venta con el patrón Requisición.
- Archivos tocados (lo último): `js/formato.js` (nuevo), `sql/2026-10-22g_odc_importes_redondeo.sql` (nuevo, **NO corrido**), 20 módulos que definían `money` + `requisiciones-compra`, `ordenes-compra`, `pedidos-venta`, `devoluciones`, `compras`, `entradas`, `salidas`, `kardex`, `inventario`, `documentos`, `produccion`, `proveedores`, `ordenes-produccion`, `pagos-proveedor`, `clientes`, `catalogo`, `version.json`, `CLAUDE.md`. **Costos y precios unitarios a diezmilésimas + redondeo comercial** (regla acordada con el usuario 2026-10-22, con ejemplo numérico). **Regla:** (1) costo/precio UNITARIO siempre con 4 decimales y SIN quitar ceros (`money4`: $0.0525, $12.5000), en pantalla e impresión; (2) importe de cada partida = `importe(cantidad, costo)` = cantidad × costo exacto redondeado a 2 decimales, **redondeo comercial** (3.er decimal ≥5 sube, ≤4 baja; nunca truncar; `redondear` evita el fallo binario de `Math.round`, 1.005→1.01); (3) subtotal = suma de esos importes redondeados, IVA = `redondear2(subtotal × 0.16)`, total = subtotal + IVA (ej. 65.63 + 4,197.50 = 4,263.13; IVA 682.10; total 4,945.23). `js/formato.js` exporta `money`, `money4`, `num4`, `importe`, `redondear`, `redondear2`; el `money` local de 20 módulos ahora es el de `formato.js` (ya redondea comercial). **Aplicado a:** requisición (detalle/impresión, totales, ODC formal con IVA redondeado), ODC (detalle, partidas nuevas, totales), pedidos de venta (precio unitario y totales), devoluciones, compra directa, entradas, salidas, Kardex, Stock General/Lotes, documentos (recepción), Producción (costeo), Proveedores, Pagos a proveedor («P. Unit.»), Órdenes de producción (costo/pieza y por lote), clientes (listas de precio). **Conflicto de captura corregido:** `prodCosto` y `prodPrecioVenta` del Alta de artículo tenían `step=0.01` y el navegador rechazaba 4 decimales; ahora `step=0.0001`. **SQL pendiente de correr:** `…22g` reescribe `odc_generar` COMPLETA (única diferencia: `v_sub` suma `round(cantidad×costo,2)` por partida; antes acumulaba sin redondear partida a partida y la variable `numeric(14,2)` recortaba cada suma); sin correrlo, el total estimado que guarda la base puede diferir 1 centavo de lo que muestra la pantalla. NO se tocó: `recibo-operador.js` (pre-recibo del operador), importes contables dentro de funciones SQL ya corridas, costos por hora/proceso. Verificado: sintaxis de todos los módulos, carga de módulos en Chromium (sin errores nuevos; app.js/importador.js fallan solo por CDN bloqueado en el entorno) y la regla con el ejemplo numérico. Sin probar renderizado de cada pantalla.

- Archivos tocados (lo último): `js/vinculos.js`, `version.json`, `CLAUDE.md`. **Alta de artículo dentro de la subventana PROBADA renderizada** (Chromium + Tailwind local + Supabase simulado + CSS del tema Claro Ice, con el `catalogo.js` real): nombre precargado, la pantalla de origen sigue visible detrás, las 5 pestañas de tipo y el bloque «Lo voy a comprar / Ya lo tengo» se ven bien, al guardar (materia prima) hace el insert, devuelve `{id}` a quien la pidió, cierra la subventana y la sección vuelve a su lugar oculta. Ajuste: se oculta el título propio de la pantalla dentro de la subventana (salía duplicado). Sin probar contra la base real. Nota: Moneda es obligatoria en el alta (comportamiento de siempre).

- Archivos tocados (lo último): `js/compras.js`, `version.json`, `CLAUDE.md`. **Compra directa: «Crear y editar…» de producto** (igual que Entradas directas). El buscador del insumo ahora acepta palabras en cualquier orden y sin acentos, y al final de la lista muestra «➕ Crear y editar «texto»…» (desde 2 letras) → Alta de artículo vinculada → el producto queda elegido con su unidad, costo y proveedor. «Agregar Partida» y el guardado directo YA NO aceptan un nombre inexistente (avisan); el alta silenciosa como materia prima queda sin uso (código sin quitar). Un equipo se rechaza con aviso (requisición → ODC). Sin probar renderizado.

- Archivos tocados (lo último): `js/entradas.js`, `version.json`, `CLAUDE.md`. **Entradas directas: «Crear y editar…» de producto** (decisión del usuario 2026-10-22: un solo camino). Bajo el campo de nombre aparece «➕ Crear y editar «texto»…» cuando lo escrito no existe → Alta de artículo vinculada (`abrirAltaVinculada`) → al guardar queda el nombre, la unidad y el costo cargados. **Cambio de comportamiento:** «Agregar» ya NO acepta un nombre inexistente (avisa que use «Crear y editar»); el atajo de crear una materia prima por nombre al guardar queda sin uso (código sin quitar). Un equipo (activo fijo) se rechaza con aviso. Sin probar renderizado. Compra directa (`js/compras.js`): su captura de producto no se ha revisado.

- Archivos tocados (lo último): `js/pedidos-venta.js`, `version.json`, `CLAUDE.md`. **«Crear y editar…» de producto en Pedidos de venta** (fase 3): buscador con palabras en cualquier orden + «➕ Crear y editar «texto»…» → Alta de artículo vinculada → el producto queda elegido (si se guarda como otro tipo que no sea terminado, avisa y no lo agrega). **Decidido NO conectar (con razón):** Salidas (un producto nuevo no tiene stock que sacar), Producción (un producto nuevo no tiene fórmula/BOM para producirse), BOM e insumos dentro de Alta de artículo (abriría la misma pantalla dentro de sí misma; el BOM en subventana lee su lista en memoria) y Entradas directas (ya da de alta el producto por nombre; ofrecer pasar por Alta de artículo real queda por decidir). Pendiente: cuentas contables y empleados. Sin probar renderizado. Sin SQL.

- Archivos tocados (lo último): `js/buscador-select.js`, `js/buscador-auto.js`, `js/vinculos.js`, `js/clientes.js`, `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **«Crear y editar…» en proveedor y cliente + búsqueda por palabras + teclado en más selects** (pedido del usuario 2026-10-22, fase 2). (1) `convertirEnBuscador(select, {crear})`: al final de la lista «➕ Crear y editar «texto»…» (desde 2 letras; con ↑↓ Enter también); `buscador-auto.js` lo activa en los selects de CAPTURA de proveedor y cliente (no en filtros/reportes: `SIN_CREAR`) y al guardar deja el registro nuevo seleccionado (agrega la opción si falta). Cliente: `vinculos.js` ganó la entidad `cliente` (carga `cargarModuloClientes` si su pantalla aún no se armó) y `clientes.js` avisa al guardar. (2) La búsqueda ya aceptaba varias palabras en cualquier orden en los selects («sey envase» = «envase sey»); ahora también el buscador de producto de la requisición/ODC (`reqFiltrarProductos`). (3) Cualquier select con ≥15 opciones que no esté en la lista se vuelve buscador solo (`MIN_OPCIONES_AUTO`, revisado 0.7 s después de aparecer porque sus opciones se llenan tarde); excluir uno: `data-sin-buscador`. Probado en Chromium con página mínima (orden de palabras, «Crear» con y sin coincidencias, Enter); sin probar en las pantallas reales ni la mudanza de Clientes. **Falta:** producto en Pedidos/Entradas/Salidas/Producción/BOM (son buscadores de producto propios, no selects), cuentas contables y empleados. Sin SQL.

- Archivos tocados (lo último): `js/vinculos.js` (nuevo), `js/requisiciones-compra.js`, `js/catalogo.js`, `js/proveedores.js`, `version.json`, `CLAUDE.md`. **Alta vinculada estilo Odoo («Crear y editar…») — fase 1** (pedido del usuario 2026-10-22: que un dato inexistente en una pantalla abra la MISMA pantalla de alta del catálogo encima y, al guardar, regrese a lo que se estaba capturando; una sola plantilla y una sola base). `abrirAltaVinculada(entidad, {nombre, onGuardado})` MUDA la `<section>` real del catálogo (`#view-alta-articulo`, `#view-proveedores`) a una subventana y la regresa a su lugar al cerrar; el catálogo avisa al guardar con `avisarRegistroGuardado(entidad, id)` (catalogo.js tras guardar el artículo; proveedores.js tras guardar). Registro `ENTIDADES` en `vinculos.js`: sumar un catálogo = una línea + el aviso en su guardado. Requisición y ODC manual: buscador con coincidencias desde la 1.ª letra y, al final, «➕ Crear y editar «texto»…» (desde 2 letras) → Alta de artículo con el nombre precargado → el artículo creado queda seleccionado. Se QUITARON el selector «Tipo» y la subventana suelta `reqAbrirAltaActivoFijo` (el tipo se elige en Alta de artículo). Probado el mecanismo en Chromium con una página mínima (precarga, mudanza, retorno, sección restaurada); sin probar con la app real ni la pantalla de Alta de artículo dentro de la subventana. **Fase 2 pendiente:** proveedor (selects de requisición/ODC/Gastos/Compra directa; la entidad ya está registrada), cliente (Pedidos de venta), producto en Pedidos/Entradas/Salidas/Producción/BOM, cuentas, empleados. Sin SQL.

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Buscador de producto de la requisición (y de la ODC manual) por TIPO** (pedido del usuario 2026-10-22: seguir la lógica de las pestañas de Alta de artículo; con Materia prima no sugerir activo fijo). Nuevo selector «Tipo» (Todos · Materia prima · Insumo · Producto terminado · Activo fijo; sin Semiterminado porque se fabrica) que filtra las coincidencias; «➕ Crear como activo fijo» solo sale con el tipo Activo fijo y sin coincidencias; con otro tipo sin coincidencias solo se avisa «Dalo de alta en Catálogos → Alta de artículo» (no se crean materias primas/insumos desde la requisición: evita columnas obligatorias de `productos` que no se ven en el repo), y con «Todos» pide elegir tipo. Helpers `REQ_TIPOS_BUSQUEDA`, `reqFiltrarProductos`, `reqFilaNuevo`. Solo sintaxis verificada; sin probar renderizado. Sin SQL.
- Archivos tocados (lo último): `js/activos-fijos.js`, `js/catalogo.js`, `js/requisiciones-compra.js`, `manual-costos-produccion.html`, `js/asistente-contable.js`, `version.json`, `CLAUDE.md`. **Categoría fiscal OBLIGATORIA y equipo usado editable** (confirmado por el usuario 2026-10-22). (1) Todo equipo exige categoría fiscal: Alta de artículo tipo Activo fijo (`required` + validación), alta rápida de la requisición, Activos fijos (al guardar uno depreciable, incluye Completar) y carga inicial. (2) «Equipo usado» (`activos_fijos.usado`, de `…22f`) en Activos fijos y en la carga inicial: habilita vida útil RESTANTE, valor residual y % fiscal editable (`pct_fiscal`, precargado de la categoría) con el monto a depreciar (costo − residual) a la vista; el costo de una compra sigue siendo de solo lectura (cuadra con la póliza REC). (3) Alta de artículo, tipo Activo fijo: elegir «Lo voy a comprar» (como antes) o «Ya lo tengo» (abre la subventana de carga inicial APE con nombre/categoría/modelo precargados; `afAbrirAperturaDesde`, que carga los catálogos de Activos fijos si hace falta — nueva `afCargarCatalogos`). Decisión de alcance: la carga inicial NO es un formulario embebido en Alta de artículo (reusa la subventana de Activos fijos) y no se creó columna `usado` en `productos` (el usado se marca al Completar/cargar, no en la plantilla). Sin SQL nuevo; requiere `…22f` corrido para usado y carga inicial. Probado en Chromium con base simulada (categoría obligatoria, usado sin %, precarga, monto a depreciar, RPC de apertura); sin probar Alta de artículo renderizada (solo sintaxis) ni nada contra la base real. Pendiente: correr `…22f`; el usuario confirma con su contador el % fiscal de usados.
- Archivos tocados (lo último): `sql/2026-10-22f_activos_apertura_baja.sql` (nuevo, **NO corrido**), `js/activos-fijos.js`, `manual-costos-produccion.html`, `js/asistente-contable.js`, `version.json`, `CLAUDE.md`. **Etapa B1 de la unificación de equipos: carga de equipos existentes (póliza APE) y baja con póliza (BAJ)** (decisiones del usuario 2026-10-22: la carga inicial SÍ genera póliza —su contabilidad ya existe pero habrá carga inicial— apegada al código agrupador; casos 1–4 de APE: carga inicial, 100 % depreciado, parcial, omitido; contrapartida 304.01 editable). SQL: series `apertura_activo`=APE y `baja_activo`=BAJ en `polizas_series_origen`; `activos_fijos` gana `modelo`, `numero_serie`, `garantia_vence`, `usado`, `acum_inicial`, `meses_dep_inicial`, `fecha_corte_apertura`, `poliza_apertura_id`, `poliza_baja_id`; `depreciacion_calcular` reescrita COMPLETA (suma la acumulada y los meses iniciales, empieza el mes siguiente al corte, nunca pasa de costo−residual); RPC `activo_fijo_apertura(p_datos)` (alta del equipo + póliza APE: Cargo activo costo / Abono acumulada / Abono contrapartida por el valor en libros; 100 % depreciado = sin renglón de contrapartida; meses ya depreciados por default = del mes de adquisición INCLUSIVE al mes del corte, igual que la regla de `depreciacion_calcular`) y RPC `activo_fijo_baja(p_datos)` (póliza BAJ: Cargo acumulada + Cargo pérdida 601.99 por el valor en libros / Abono costo; SOLO baja sin venta). Pantalla Activos fijos: botón "Cargar equipo existente" (subventana con cálculo y póliza en vista previa, cuentas por categoría y área), "Dar de baja" con vista previa de la póliza BAJ, columnas Dep. acumulada y Valor en libros. Probado en Postgres local (carga parcial 78 meses/$29,250/VL $15,750, báscula 100 % depreciada sin 304.01, oct-2026 no deprecia y nov-2026 sí $375, baja con póliza, doble baja rechazada, 2 corridas) y en Chromium con base simulada. **Sin hacer (etapa B2):** ficha única con pestañas (General · Compra y proveedor con "Más detalles" y "Claves de proveedor" · Depreciación y contabilidad · Consumo eléctrico), estados Por comprar/Recibido/En servicio/Baja, ocultar el artículo "Activo fijo" en Productos y la casilla "Equipo usado". La baja con venta (IVA, cobro) queda fuera. Orden de SQL: …22 → …22b → …22d → …22f.
- Archivos tocados (lo último): `sql/2026-10-22d_cuentas_depreciacion_por_tipo.sql` (nuevo, **NO corrido**), `js/categorias-depreciacion.js`, `js/tablas.js`, `js/activos-fijos.js`, `js/catalogo.js`, `js/requisiciones-compra.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Cuentas contables por categoría de bien (vinculación automática compra → depreciación)** (pedido del usuario 2026-10-22: "no vi esa vinculación automatizada del bien comprado y su ligue con la depreciación acumulada"). `c_categoria_depreciacion` gana `cuenta_activo_id`, `cuenta_dep_acum_id`, `cuenta_gasto_cif_id` (área de PRODUCCIÓN → 503.xx, SAT 504.xx, se prorratea) y `cuenta_gasto_admin_id` (área `no_produccion` → 613.xx, SAT 613 "Depreciación contable"), editables en Configuración → Tablas. La migración crea (solo si no existen; si un código ya existe con otro nombre NO lo toca y avisa) activo 155.01–159.01, acumuladas 153.03–153.07, CIF 503.20–503.25 y gasto 613.xx, con su agrupador del Anexo 24 RMF 2026, y asigna las cuentas a las categorías de maquinaria, cómputo, mobiliario, transporte, comunicación, edificios y adaptaciones (las demás quedan sin cuentas, se eligen a mano). `_alta_activos_desde_recepcion` (reescrita COMPLETA) copia al equipo que nace de la compra su cuenta de activo y su depreciación acumulada. Pantallas: al elegir la categoría en Alta de artículo y en la alta rápida de la requisición se fija la cuenta de activo (la que carga la póliza REC); en Activos fijos al elegir categoría y área se llenan activo, acumulada y gasto (producción → 503.xx con etapas; no producción → 613.xx) y se muestra el asiento. La depreciación mensual ya usaba las cuentas de cada activo, no cambió. Probado: migración en Postgres local (2 corridas) y Chromium con base simulada. **Sin hacer todavía (etapa B de la unificación):** ficha única con pestañas estilo Odoo, ocultar el artículo "Activo fijo" de Productos, póliza de baja y póliza de apertura para equipos viejos. Orden de corrida de SQL: `…22_categorias_depreciacion_fiscal` → `…22b_codigo_agrupador_sat_2026` → `…22d_cuentas_depreciacion_por_tipo`.
- Archivos tocados (lo último): `sql/2026-10-22b_codigo_agrupador_sat_2026.sql` (nuevo, **NO corrido**), `js/asistente-prorrateo.js`, `CLAUDE.md`. **Código agrupador SAT corregido** (el usuario pasó el Anexo 24 RMF 2026 en PDF y el de 2016 en xlsx). Hallazgo: la siembra del plan de cuentas copió el código interno en `codigo_agrupador` (152.01 → '152.01'), que solo coincide con el SAT por casualidad (152 = Edificios; maquinaria = 153.01; 154 = Automóviles, cómputo = 156.01; 503 = Devoluciones sobre compras, CIF = 504.01; 109.01 = Seguros pagados por anticipado, anticipos a proveedores = 120.01; 601.xx también desfasado). La migración corrige SOLO `codigo_agrupador` por número interno (no toca números, nombres ni saldos), deja las mayores en el nivel 1 del SAT cuando todas sus hijas coinciden, imprime cada cambio en NOTICE y es idempotente (probada 2 corridas en Postgres local con cuentas de muestra). Criterios de JUICIO marcados con ¿? en el SQL (honorarios, arrendamiento, semiterminados 115.02, depreciación 503.04 → 504.08 maquinaria, etc.): validar con el contador. `asistente-prorrateo.js`: las cuentas 503.xx nuevas ya nacen con agrupador 504.01. **Ajustes tras revisión del usuario:** honorarios (601.34), arrendamiento (601.46) y semiterminados 115.02 → 115.03 aprobados; depreciación con guarda por NOMBRE (153.01, 153.02, 503.04: solo se corrigen si el nombre corresponde a maquinaria/cómputo, si no se omiten con aviso; el agrupador depende del tipo de bien: 171.01–171.18 acumulada y 504.07–504.24 gasto); mayor 209 → 207 con 209.01 → 208.01 y 209.02 → 209.01 (los números internos NO cambian porque las funciones de ventas/devoluciones usan `_cuenta_id('209.01'/'209.02')`); `sql/2026-10-22c_cuentas_por_revisar_agrupador.sql` (solo lectura) lista las cuentas fuera del mapa. **Pendiente:** el usuario corre el SQL (idealmente tras revisar con su contador) y revisa los NOTICE; cuentas creadas a mano que no estén en el mapa quedan como estaban (verificar con el SELECT del pie del archivo). Importante para Activos fijos: la cuenta de activo por categoría sale del plan REAL (152.01, 153.01/02), nunca de códigos del SAT; el agrupador solo se usa para la contabilidad electrónica.
- Archivos tocados (lo último): `sql/2026-10-22_categorias_depreciacion_fiscal.sql` (nuevo, **NO corrido**), `js/categorias-depreciacion.js` (nuevo), `js/tablas.js`, `js/activos-fijos.js`, `js/catalogo.js`, `js/requisiciones-compra.js`, `js/indice.js`, `index.html`, `js/asistente-contable.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Categorías de depreciación fiscal (LISR)** (pedido del usuario 2026-10-22, con la tabla de cpcongroup.mx "Tabla SAT Vigente 2026"; los dos enlaces no se pueden abrir desde este entorno, se cargó lo que el usuario pegó en capturas). Tabla `c_categoria_depreciacion` (grupo depreciación/amortización, fundamento, categoría, % anual, tope deducible, `vigente_desde`/`vigente_hasta` por ejercicio, activo, notas; 22 filas sembradas: art. 34, 35 y 33; automóviles con tope $175,000 del art. 36-II). **Editable** en Configuración → Tablas → "SAT · Depreciación fiscal" (también en el Índice): los cambios de ley año con año se hacen con "Nueva vigencia" (cierra la fila y crea otra desde el año indicado). **Se elige la categoría** en Alta de artículo tipo Activo fijo (`prodCategoriaDep`), en Editar artículo, en la alta rápida de la requisición y en Activos fijos (reemplaza el texto libre "Categoría"): trae % y vida útil sugerida (100÷%×12 meses, editable) y avisa la parte no deducible si hay tope. `activos_fijos` guarda COPIA del % y tope del ejercicio (`pct_fiscal`, `tope_fiscal`, `ejercicio_fiscal`) y `productos.categoria_depreciacion_id` es la plantilla; `_alta_activos_desde_recepcion` (reescrita COMPLETA) copia la categoría al activo que nace de una compra (sigue "pendiente de completar"). El % es TOPE fiscal: la depreciación contable (NIF C-6) sigue usando `vida_util_meses`. Probado: migración en Postgres local (2 corridas, activo desde recepción con categoría 10 %/2026) y Chromium con base simulada (selector, vida sugerida, tope, insert con copia, editor de la tabla). **Sin probar:** alta rápida de la requisición y Alta/Editar artículo renderizados (solo sintaxis); nada contra la base real. **Verificar contra la LISR** los fundamentos de la fuente (comunicación 34-III, imagen y sonido 34-VIII, vehículos 11 %/10 %) y que la maquinaria de cosméticos/farmacéutica sea la tasa general 10 %. Pendiente: correr el SQL y subir a `main` con "comitea". **Hecho después (2026-10-22, aprobado):** Alta de artículo tipo Activo fijo oculta Costo unitario, Precio de venta, Moneda (se quita su `required` mientras está oculta) y Stock mínimo; Activos fijos explica arriba que ahí se capturan los equipos que YA se tienen (los que se van a comprar se piden por requisición/Productos) y, al guardar un alta manual, avisa si ya existe un artículo Activo fijo con ese nombre. Sin SQL. Sin probar renderizado (solo sintaxis).
- Archivos tocados (lo último): `js/activos-fijos.js`, `js/asistente-contable.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Costo histórico para equipos viejos** (pedido del usuario 2026-10-22: "tengo equipos que ya son viejos y que ya no se depreciarán pero sí quiero tenerlos en mi listado"): en Activos fijos, al marcar "No depreciable" aparece el campo opcional "Costo histórico" (antes ese tipo descartaba el costo); se guarda en `costo_adquisicion` (null si se deja vacío), se precarga al editar y no aplica a los que vienen de una compra (esos conservan su costo real). Sin póliza ni SQL. Probado en Chromium con Supabase simulado (alta con y sin costo, edición, ocultar/mostrar). Decidido también: fecha de adquisición de compras = fecha de la recepción.
- Archivos tocados (lo último): `sql/2026-10-21_activo_fijo_en_compras.sql` (nuevo, **YA corrido por el usuario 2026-10-22**: "Success. No rows returned"), `js/requisiciones-compra.js`, `js/ordenes-compra.js`, `js/activos-fijos.js`, `js/catalogo.js`, `js/documentos.js`, `js/contabilidad.js`, `js/inventario.js`, `js/auditoria-inventario.js`, `js/auxiliar-inventarios.js`, `js/reportes.js`, `js/salidas.js`, `js/entradas.js`, `js/compras.js`, `js/asistente-contable.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Activo fijo en el proceso de compra** (pedido del usuario 2026-10-21: "no estás considerando un proceso de licitación o compra… impacto en las cuentas contables de la erogación y del ingreso del activo fijo"). Decisiones del usuario: nuevo TIPO de producto `activo_fijo` (no marca por partida), alta automática del activo al recibir en estado **pendiente de completar**, un equipo por partida, y si el equipo no existe la requisición abre una subventana para crearlo sin perder lo capturado. **Flujo:** requisición → ODC (sin cambios; el equipo se pide como cualquier producto) → recepción: el activo NO entra al inventario (sin lote/kardex/caducidad, cantidad 1; `rmAplicarEntradaActivo`), la póliza REC carga la cuenta de activo (`productos.cuenta_inventario_id`, por default 152.01) + IVA contra 201.01/109.01 y la misma `contabilizar_compra` llama a `_alta_activos_desde_recepcion` que da de alta el activo (`activos_fijos.pendiente=true`, con costo —incluye flete capitalizable—, fecha, proveedor, ODC, recepción y póliza) → Finanzas → Activos fijos: botón "Completar" (área, potencia, depreciable, vida útil, cuentas, etapas; costo y fecha de solo lectura) → depreciación y prorrateo de siempre. Mientras esté pendiente no se deprecia (`vida_util_meses` null y `activos_fijos_dep_chk/nodep_chk` ya lo toleran). **SQL (funciones reescritas COMPLETAS):** `contabilizar_compra` (= 2026-10-14b + cuenta 152.01 para activo fijo sin cuenta + alta del activo), `cancelar_recibo_inventario` (= 2026-10-27 + una recepción solo de equipos ya se puede cancelar y retira sus activos; si alguno ya se depreció, no deja), `_alta_activos_desde_recepcion` (nueva), regla CHECK de `productos.tipo` ampliada, columnas nuevas en `activos_fijos`. **Pantallas:** alta rápida `reqAbrirAltaActivoFijo` (fila "➕ Crear «…» como activo fijo" en el buscador de la requisición y de la ODC manual; nombre, SKU, unidad, cuenta 15x, proveedor; el equipo queda seleccionado con cantidad 1; MOQ no aplica); Productos gana el tipo "Activo fijo" (alta, editar, etiquetas; no sale como componente de BOM); Stock General, Auditoría, Auxiliar de inventarios, Reportes de inventario, Salidas, Entradas directas y Compra directa lo excluyen; cancelar recibo (Documentos y Pólizas) muestra los activos que se retirarán; editar líneas de una recepción con equipo se bloquea (cancelar y recapturar). **Probado:** migración en Postgres local (2 corridas; recepción solo-equipo y mixta con inventario cuadran, cantidad 2 rechazada y revierte todo, cancelar retira el activo, depreciado bloquea) y UI en Chromium con Supabase simulado (subventana, selección, conservación de lo capturado, tope de cantidad 1 en requisición y ODC manual). **Sin probar:** la pantalla de Recibo de mercancía y Activos fijos renderizadas (solo sintaxis) y todo contra la base real. Pendiente: correr el SQL, y una compra de prueba completa (requisición → ODC → recepción → pago → Completar → depreciar → prorratear).

- Archivos tocados (lo último): `js/tablas.js`, `js/tareas.js`, `js/indice.js`, `index.html`, `version.json`, `CLAUDE.md`. **Umbrales de caducidad pasan a Configuración → Tablas → "Umbral caducidades"** (pedido del usuario 2026-10-16): el panel "Alertas de caducidad — umbrales" (tabla `alertas_caducidad_umbrales`: días, etiqueta, prioridad, activo; agregar/activar/quitar) ya NO está al pie de Tareas de almacén; vive como nueva tabla de apoyo (`cargarEditorUmbralesCaducidad` en `tablas.js`, `window.loadView('tablas', {tabla:'umbral_caducidad'})`, entrada en el submenú Tablas y tarjeta en el Índice). Misma lógica: al cambiar un umbral se corre `tareas_sync_caducidad` y se avisa que las Tareas de almacén ya lo reflejan (antes recargaba Tareas). Sin SQL.- Archivos tocados (lo último): `js/kardex.js`, `js/filtro-columna.js`, `js/asistente-contable.js`, `index.html`, `version.json`, `CLAUDE.md`. **Kardex (menú Inventario) con todos los estándares del ERP** (pedido del usuario 2026-10-16): (1) clase `lista-completa` (marco hasta el borde inferior, encabezado fijo, solo las filas se desplazan); (2) píldora "Ayuda" (guía `kardex` + manual `#m-kardex`) y se quitó la tarjeta/subtítulo del HTML; (3) UNA sola tabla para todos los productos: fila de grupo por producto (nombre, SKU, unidad, stock actual y tarjetas Saldo inicial/Entradas/Salidas/Saldo final) y sus movimientos debajo (antes un bloque con su propia tabla por producto); (4) filtros ▼ en Operación, Lote y Cantidad (entradas/salidas) con conteos y orden ⇅ (Fecha, Operación, Lote, Costo, Cantidad) dentro de cada producto — los saldos/totales son del periodo completo, los filtros solo ocultan filas; "Quitar filtros" y contador de movimientos; (5) estado vacío centrado con la ilustración ("Sin consulta todavía…"), mensajes de consulta/error en la misma tabla; (6) optimización: los productos elegidos se consultan en PARALELO (antes uno tras otro); (7) `hoyISO` compartido (hora local); (11) **saldo corriente del PRODUCTO (todos los lotes juntos)**: Stock ant./Stock nuevo parten de la fila anterior en orden cronológico (antes era POR LOTE y cada lote arrancaba en 0; el Kardex embebido de Productos conserva el cálculo por lote porque ahí hay filtro de lote); (10) orden visual: PRIMERO el resumen del producto (nombre, SKU, saldo inicial/entradas/salidas/saldo final) y DEBAJO los encabezados de columna (con un producto ambos en el thead fijo; con varios, cada uno trae su resumen + encabezados en el cuerpo); (9) orden por default: LO MÁS ANTIGUO ARRIBA (cronológico; cada consulta nueva vuelve a él) y el menú ▼ de la columna Doc ID deja elegir "Más nuevo arriba"; (8) la columna Doc ID muestra el FOLIO del documento (OPC-…, ENT-…, ODC-…; `adjuntarFoliosDocumento`, una consulta por los ids distintos; vale también para el Kardex embebido de Productos y el CSV) en vez de "#id". Imprimir saca lo que se ve (con filtros); el CSV exporta el periodo completo sin filtros. Sin SQL.- Archivos tocados (lo último): `js/filtro-columna.js` (nuevo), `js/inventario.js`, `index.html`, `version.json`, `CLAUDE.md`. **Stock General (menú Inventario) rediseñado con filtros por columna** (pedido del usuario 2026-10-16: "filtro de columna… todas las columnas que tengan filtros"): los 4 grupos plegables con paginación de 10 se reemplazaron por UNA tabla `lista-completa` (encabezado fijo, solo las filas se desplazan) con menú ▼ en el encabezado de **Clasificación, Unidad, Existencia/Stock, Reservado, Libre y Costo unitario** (cada opción con su conteo, que respeta los demás filtros; "Quitar filtros" y contador "N de M artículos") + orden ⇅ en todas + el buscador por SKU/nombre de siempre (filtro de la columna Elemento). Reservado/Libre solo si la migración de reservas está corrida (como antes) y solo tienen valor en terminados. `filtro-columna.js` es el componente reutilizable (`thColumna`, `wireFiltrosColumna`) para llevar el mismo patrón a otras pantallas (Cuentas por pagar y Requisiciones tienen su propia versión: unificar es opcional). No se tocó la tabla de Lotes ni ninguna consulta/SQL.- Archivos tocados (lo último): `js/fechas.js` (nuevo), 30 módulos de `js/` (los que usan `hoyISO`/fechas), `sql/2026-10-16_zona_horaria_mexico.sql` (nuevo, **falta correrlo**), `version.json`, `CLAUDE.md`. **Todo documento se guarda con la fecha real de ejecución** (pedido del usuario 2026-10-16; origen: lote #78 de OPR-000001 mostraba 15/10 siendo 16/10). Hallazgos: (1) **PANTALLA:** `new Date('2026-10-16').toLocaleDateString()` toma la fecha sin hora como UTC y en México muestra el día ANTERIOR (Lotes, deterioro, documentos, compras, entradas, salidas, proveedores, órdenes de compra, trazabilidad) → `fechaLocalTxt()` en `fechas.js`. (2) **CLIENTE:** 16 módulos definían `hoyISO = new Date().toISOString().slice(0,10)` (UTC: después de las 18:00 en México daba el día siguiente) y ~15 sitios más lo repetían inline → ahora un solo `hoyISO()` local en `fechas.js` (también `isoLocal`, `diasDesdeHoyISO`). (3) **BASE:** 57 usos de `current_date` en funciones SQL (Supabase corre en UTC) → un solo `alter database postgres set timezone to 'America/Mexico_City'` (sin reescribir funciones). Quedan fuera a propósito: nombres de archivo exportado y fechas calculadas desde otra fecha (`sigMes`, fin de nómina). No se re-fecha lo ya guardado. El SQL de zona horaria queda para después (el usuario lo pospuso 2026-10-21; no ofrecerlo como pendiente). Los jobs de pg_cron usan `cron.timezone` (UTC), no la zona de la base, y no necesitan ajuste: 13:00/13:15/13:20 UTC = 07:00/07:15/07:20 en México (UTC−6 fijo, sin horario de verano desde 2022).
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `js/contabilidad.js`, `js/subventanas-movibles.js`, `sql/2026-10-16_diagnostico_migraciones_pendientes4.sql` (solo lectura; el usuario lo corrió: **todas las migraciones al día**), `version.json`, `CLAUDE.md`. (1) Requisición: anchos de la tabla reajustados (Acciones 5 → 9 %); "Costo unit." de la ODC formal, de la captura manual de partida y de la edición de requisición con `$` y 4 decimales. (2) "Ver póliza": Estatus y Origen con mayúscula inicial (`capPrimera`). (3) Subventanas: el botón "Cerrar" del pie se oculta cuando hay semáforo (un solo control; el punto rojo lo dispara si la ventana no trae su ×).
- Archivos tocados (lo último): `index.html`, `orden-trabajo.html`, `recibo-operador.html`, `conteo-inventario.html`, `CLAUDE.md`. **Solo 3 temas** (pedido del usuario 2026-10-16: "ya no los quiero tener en cuenta"): Configuración → Temas de usuario conserva **Claro Ice**, **Mac (oscuro)** y **Mac (claro y sencillo)**; se quitaron las tarjetas Oscuro, Medianoche, Bosque, Ciruela, Confort, Papel, Niebla, Aurora, Atardecer, Neón y Océano. El tema por defecto pasa de `aurora` a `claro-ice` y, si el navegador tiene guardado un tema ya retirado, se usa `claro-ice` (en `index.html` y en las 3 apps de operador). **CSS borrado (sin dependencias, verificado con grep en css/js/html):** bloques de midnight, forest, plum, confort, paper, mist (`tema-base.css`) y aurora, sunset, neon, ocean + acentos/sombras por tema (`ui-moderno.css`); `:root` (oscuro base) y `data-theme="light"` (lo usan el manual y la guía) se conservan. `?v=` CSS → `20261016040000`.- Archivos tocados (lo último): `js/dialogos.js` (nuevo), `js/app.js`, `js/orden-trabajo.js`, `js/recibo-operador.js`, `js/conteo-inventario.js`, `js/subventanas-movibles.js`, `js/pagos-proveedor.js`, `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`, `sql/2026-10-16_diagnostico_odc11_segundo_pago.sql` (solo lectura, ya innecesario). **(1) Avisos con el diseño del tema:** `dialogos.js` reemplaza `window.alert` (el "haresvenusjc.github.io says…") por un cuadro propio con la paleta del tema, tono por emoji (✅/❌/⚠), cola de avisos, Enter/Esc; NO bloquea el código y NO reemplaza `confirm()`/`prompt()` (siguen nativos; ~5 llamadas); `window.alertNativo` queda por si hace falta el original. **(2) Semáforo de subventanas** a la derecha del título (verde · amarillo · rojo); si la barra de título no es flex (ej. `<h3>` de un cuadro de confirmación) se vuelve flex; el cuadro "¿Seguro que quieres cerrar este recibo?" pasó a `max-w-md`. **(3) Cuentas por pagar:** se quitó el enlace "ver pagos" de las filas abiertas (el historial de pagos de un documento con pago parcial queda por rediseñar: propuesta de subventana con línea de tiempo total → anticipo → pagos → saldo, abierta desde el chip de estatus; **pendiente de aprobar maqueta**). ODC-000011 salía sin "Pagar" por lista con datos viejos (F5). **(4) Lista vacía en `lista-completa`:** aviso centrado en el marco y sin franja de color propia. **Pendiente de decisión:** ODC con anticipo parcial sin liquidar — que Finanzas las vea como pendientes de liquidación (propuesta: se quedan en Pendiente con saldo = total − anticipo, chip "Anticipo pagado · falta liquidar", sin sumar a las tarjetas de deuda; pagar el resto antes de recibir solo si es contado — falta que el usuario decida).
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `js/subventanas-movibles.js`, `version.json`, `CLAUDE.md`. **Ajustes 2026-10-15 (3 pedidos del usuario):** (1) buscador de producto de la requisición con teclado: ↓/↑ mueven, Enter elige y pasa a Cantidad, Esc cierra; (2) costo estimado se muestra con 4 decimales (`425.0000`) desde que se agrega la partida y al editarlo; (3) el semáforo de las subventanas pasó a la DERECHA de la barra de título en el orden verde · amarillo · rojo, 15 % más grande (15 px; 21 px táctil), centrado con el título. Confirmado por el usuario: la advertencia de MOQ es para cantidad MENOR al MOQ. Pendiente: probar en el navegador (Ctrl+Shift+R) en varias subventanas.
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Requisición: MOQ pasa a COLUMNA y se quita ✎** (pedido del usuario 2026-10-15). (1) Se quitó el botón ✎ de cada partida
  (y `reqEditarPartida`/`reqCostoRetorno`): para cambiar algo se quita la partida con ✕ y se vuelve a "Solicitar". (2) Nueva columna **MOQ** en la tabla de partidas (`reqHtmlMoq`): muestra el MOQ del producto con su unidad
  y lo analiza contra la cantidad solicitada — cantidad MENOR al MOQ → advertencia "puede ser más difícil o no ejecutable por las políticas de venta del proveedor" + botón "Pedir X"; cumple → "✓ Cumple" (y sobrante si
  la orden necesitaba menos); sin MOQ → campo "Guardar MOQ" como antes. Interpretación a confirmar con el usuario: pidió advertir "en caso de ser igual o superior al MOQ"; se implementó para cantidad INFERIOR al MOQ
  (lo que realmente complica la compra). Sin SQL. Pendiente: confirmar la interpretación y probar en el navegador.
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Formulario "Nueva requisición de compra" — anotaciones del usuario (captura 2026-10-15):** (1) el botón "＋ Agregar partida" (debajo) pasó
  al final de la fila de captura con el nombre **"Solicitar"** (mismo `#reqAddPartida`, misma lógica: agrega la partida); (2) la **cantidad ya no se edita en la tabla** (solo se muestra con su unidad): se captura/edita arriba;
  para cambiar una partida ya agregada hay un botón **✎** que la regresa a la fila de captura (producto, cantidad, unidad y proveedor) y conserva su costo estimado (`reqEditarPartida`, `reqCostoRetorno`); "Pedir MOQ"
  sigue ajustando la cantidad; (3) **costo estimado**: símbolo "$" dentro del campo, `step=0.0001` (hasta diezmilésimas, redondeado a 4 decimales al guardar), importe a 2 decimales. **Sin resolver:** el usuario encerró en rojo
  el bloque "producto · SKU · ✓ MOQ" de la tabla sin escribir qué quería (¿encabezado "Mi catálogo (interno)"? ¿SKU cortado? ¿aviso MOQ?) — preguntar. Pendiente: subir con "comitea".
- Archivos tocados (lo último): `js/subventanas-movibles.js`, `version.json`, `CLAUDE.md`. **Controles de ventana estilo macOS/iOS** (pedido del usuario 2026-10-15): el botón "⤢" y el "×" de las subventanas se reemplazan por un
  semáforo a la IZQUIERDA de la barra de título — rojo = cerrar (dispara el × que cada ventana ya trae, que queda oculto, para no saltarse su limpieza; si no tiene, usa su botón "Cerrar" o quita el overlay), amarillo = minimizar
  (deja solo la barra de título; otro clic restaura y regresa el alto) y verde = maximizar/restaurar (la lógica de siempre). Glifos ✕ − + al pasar el cursor, 13 px (18 px en táctil). Un solo lugar (`agregarSemaforo`), sin tocar
  módulos; se inyecta su propio `<style id="sv-semaforo-css">` con `!important` porque `ui-moderno.css` fuerza botones 3D/esquinas. Probado en Edge headless (3 puntos, × original oculto, minimizar/restaurar, rojo dispara el
  cierre original, maximizar 724 px / restaurar 600 px). Pendiente: subir con "comitea" y revisar en varias ventanas (documento, póliza, BOM, requisición) que el × original se encontró y que no quedó doble cierre.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`. **Corrección: la lista de Requisiciones no desplazaba** (captura del usuario): la regla de recorte de esquinas
  `.overflow-x-auto.border:not(.overflow-y-auto):not([class*="max-h-"]) { overflow-y: hidden }` (especificidad 0,4,0) ganaba a `.lista-completa div:has(> table)` y congelaba las filas; el overflow-y del contenedor de la
  tabla en `lista-completa` ahora lleva `!important`. Cuentas por pagar y Lotes no estaban afectados (su contenedor no trae `overflow-x-auto`). `?v=` CSS → `20261015220000`. Lección: al probar un cambio de diseño de lista, verificar
  que SÍ se desplaza con más filas que el alto visible.
- Archivos tocados (lo último): `js/estado-vacio.js` (nuevo), `js/app.js`, `version.json`, `CLAUDE.md`. **Estado vacío estándar** (pedido del usuario 2026-10-15, con su ilustración de documentos): en TODA lista sin registros se
  muestra la ilustración (dos hojas: la trasera con el color de acento del tema —antes dorada—, la frontal blanca con pliegue y renglones) y debajo el mismo mensaje que ya existía. Sin tocar cada módulo: `estado-vacio.js`
  (importado en `app.js`) detecta con un MutationObserver los avisos "Sin …" / "No hay …" / "No se encontr…" (elemento sin hijos p/td/div, en `text-slate-500`, que NO sea pista chica `text-xs`/`text-[11px]`, cursiva ni de
  partidas de formulario, ni dentro de listas desplegables) y les antepone el SVG. Excluir uno: `data-sin-ilustracion`. Probado en Edge headless (aviso p y td ilustrados; cursiva, text-xs, partidas y menús no).
  Pendiente: subir con "comitea" y revisar en pantallas reales qué avisos quedaron sin ilustración (los chicos/cursiva se dejaron fuera a propósito) y si el tamaño (92×100 px) es el deseado.
- Archivos tocados (lo último): `js/contabilidad.js`, `version.json`, `CLAUDE.md`. **Reportes contables → Auxiliar de cuentas contables: el título y el subtítulo (cuenta, periodo, N movimientos) ya NO se van al desplazar** (pedido del usuario 2026-10-15): estaban DENTRO del contenedor que se desplaza (`#rcTabla` con `overflow-x-auto`), así que subían con las filas y solo el `thead` quedaba fijo. Ahora el título queda fuera y solo la tabla va en su propio contenedor con scroll. Revisadas las demás pantallas con el mismo patrón (encabezado dentro del contenedor desplazable): ninguna otra lo tenía (las demás tablas de Reportes contables, Auxiliar de inventarios y de Anticipos empiezan con la tabla). **Regla para pantallas nuevas:** el título/subtítulo/filtros van FUERA del contenedor `overflow-*`; dentro solo la tabla. Pendiente: verlo en el navegador.

- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`. **Clase `lista-completa` (diseño estándar de listado reutilizable):** el esquema de "lista a pantalla completa" ya no depende de
  nombres de pantalla — se activa agregando `lista-completa` a la `<section class="vista-seccion …">` en `index.html` (hoy: Requisición de Compra, Cuentas por pagar, Lotes). **Contrato:** título (con Ayuda) → opcional
  filtros/tarjetas → UN solo contenedor con la tabla (table-fixed, sin barra horizontal). **Efecto:** marco hasta el borde inferior, encabezado fijo y solo las filas se desplazan, el marco no se encoge vacío. Se borraron las reglas
  por pantalla (`#view-pagos-proveedor`, `#view-lotes`, `#reqLista`, `#cxpPanelDocumentos`…); la regla genérica de tablas (`max-height: calc(100vh − 15rem)`) ya excluye `.lista-completa *`. Para rediseñar otra pantalla:
  mover sus formularios largos a una subventana con botón "Crear" (como Requisiciones), dejar una sola tabla y añadir la clase. Pendiente: subir con "comitea" y revisar las 3 pantallas (deben verse igual que antes).
- Archivos tocados (lo último): `js/contabilidad.js`, `version.json`, `CLAUDE.md`. **Reportes contables: las pestañas (Balanza, Estado de resultados, Balance general, Auxiliares…) van ARRIBA y los filtros (Desde/Hasta/Generar/Exportar) debajo** (pedido del usuario 2026-10-15, antes estaba al revés). Solo cambió el orden en `cargarModuloReportesContables`; ids intactos. Pendiente: verlo en el navegador.

- Archivos tocados (lo último): `css/ui-moderno.css`, `js/requisiciones-compra.js`, `index.html`, `version.json`, `CLAUDE.md`. **Listas a pantalla completa — diseño estándar** (pedido del usuario 2026-10-15, capturas de Requisiciones y
  Cuentas por pagar): (1) el marco de la lista llega hasta el borde inferior de la ventana (`<main>` baja su relleno inferior a .5rem con `:has()` y la sección mide `100vh − 1.125rem − .5rem`; antes quedaba un hueco de ~1.5rem y,
  por la regla genérica de tablas de la otra sesión, `max-height: calc(100vh − 15rem)` en las demás); (2) título/Ayuda/filtros/encabezado fijos y solo las filas se desplazan POR DEBAJO, sin barra horizontal (`overflow-x:hidden`,
  columnas `table-fixed`); (3) el marco NO se encoge con pocas filas o vacío (`flex:1`; el aviso "Sin requisiciones…" va dentro); (4) la subventana "Nueva requisición de compra" se monta en `<body>` (dentro del contenedor
  quedaba recortada). Aplica a **Requisiciones, Cuentas por pagar y Lotes** (selector común al final de `ui-moderno.css`). Las demás tablas siguen con la regla genérica (`max-height: calc(100vh − 15rem)`); extender el
  esquema a otras pantallas de listado queda por decidir con el usuario. `?v=` CSS → `20261015190000`. Pendiente: subir con "comitea" y revisar en el navegador (Ctrl+Shift+R): hueco inferior, lista vacía, ventana flotante.
- Archivos tocados (lo último): `index.html`, `version.json`, `CLAUDE.md`. El botón **🧭 Índice** del menú lateral pasó del principio al final, debajo de Configuración (pedido del usuario 2026-10-15). Pendiente: verlo en el navegador.

- Archivos tocados (lo último): `index.html`, `js/indice.js`, `version.json`, `CLAUDE.md`. Se quitó el emoji 🧭 de la entrada "Asistente de llenado" del submenú Costos y prorrateo y de su tarjeta del Índice (pedido del usuario 2026-10-15); el botón dentro de Prorrateo de gastos conserva el suyo. Pendiente: verlo en el navegador.

- Archivos tocados (lo último): `index.html`, `js/indice.js`, `version.json`, `CLAUDE.md`. **"🧭 Asistente de llenado" es ahora la PRIMERA entrada del submenú Contabilidad → Costos y prorrateo** (pedido del usuario 2026-10-15: como el asistente llena las tablas de Centros de costo, Áreas y Reparto, debe ir antes que ellas): abre la subventana (`window.abrirAsistenteProrrateo('inicio')`) desde cualquier pantalla; también primera tarjeta del Índice (las tarjetas aceptan `js:` en vez de `v:`). El botón dentro de Prorrateo de gastos se queda. Pendiente: verlo en el navegador (Ctrl+Shift+R).

- Archivos tocados (lo último): `index.html`, `js/indice.js`, `js/asistente-prorrateo.js`, `manual-costos-produccion.html`, `guia-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Menú: "Costos y prorrateo" ya no es grupo propio sino un SUBMENÚ dentro de Contabilidad** (pedido del usuario 2026-10-15): Contabilidad = Pólizas · Plan de cuentas · ▼ Costos y prorrateo (Centros de costo → Áreas y bases de prorrateo → Reparto de gastos compartidos → Prorrateo de gastos) · Reportes contables · Cierre de periodo · Tabla ISR (el menú vuelve a 9 grupos). El Índice lo muestra como grupo "Contabilidad › Costos y prorrateo". Títulos de pantalla siguen "Costos y prorrateo · …"; rutas de manual, guía y asistente: "Menú → Contabilidad → Costos y prorrateo → …". Sin SQL. Pendiente: verlo en el navegador (Ctrl+Shift+R).

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. Requisiciones: se quitó el subtítulo "Requisiciones de compra" sobre la tabla y el `space-y-5` del contenedor (el
  overlay fijo del formulario añadía un hueco extra) — el panel de la lista queda pegado al encabezado fijo, como el mockup del usuario. Pendiente: subir con "comitea".
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`. **Subventanas con más contraste** (captura del usuario: el borde de "Nueva requisición de compra" casi no se distinguía del fondo):
  regla global para `.fixed.inset-0 > .border` y `.fixed.rounded-2xl.border` — borde `var(--bd-2)`, aro de 1 px con el acento del tema (42 %), sombra `--sh-2` y un resplandor suave del acento. Aplica a todas las ventanas
  flotantes de todos los temas (los Mac/Claro Ice ya tienen sombra propia; el aro del acento se suma). `?v=` CSS → `20261015170000`. Pendiente: subir con "comitea" y revisar en 2-3 temas.
- Archivos tocados (lo último): `sql/2026-10-15_equipos_unificados.sql` (nuevo, **YA corrido por el usuario 2026-10-15**), `js/activos-fijos.js`, `js/asistente-prorrateo.js`, `js/areas-prorrateo.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Alta unificada de equipos** (decisión del usuario 2026-10-15: todo equipo se da de alta en Activos fijos; camino B = borrar las cargas viejas y darlas de alta a mano con la guía). Migración: `activos_fijos` gana `depreciable`, `area_id`, `tipo_carga`, `potencia_kw` (por unidad, en kW), `cantidad`, `factor_uso`; costo y vida útil solo obligatorios si es depreciable (check `activos_fijos_dep_chk`) y un NO depreciable exige área y potencia (`activos_fijos_nodep_chk`); `v_areas_carga` suma desde `activos_fijos` (vigentes; mismas columnas, `v_bases_prorrateo` no se toca); **borra TODAS las filas de `areas_fisicas_cargas`** (incluido el túnel de vapor; las lista en un NOTICE; la tabla queda sin uso); `depreciacion_calcular` reescrita completa para ignorar no depreciables (`depreciacion_aplicar` no cambió: lee de esa función). Probada en Postgres local (2 corridas; rechaza depreciable sin costo y no depreciable sin área/potencia). **Activos fijos (pantalla):** área, tipo de carga, potencia (kW/HP/W), piezas, factor de uso y radio obligatorio Depreciable/No depreciable; el bloque de costo/vida/cuentas/etapas solo sale si es depreciable (precarga 152.01 / 503.04 / 153.01); la lista gana Área, kW efect. y badge. **Asistente de prorrateo, paso 3 · Luz:** ahora es la guía de alta — por área sin submedidor, tarjetas "Dar de alta un equipo" (nombre, tipo, potencia, piezas, uso, fecha, ¿se deprecia? y, si sí, costo/vida/cuentas/etapas con la etapa del área precargada); chips de equipos típicos con ✅ si ya hay uno parecido; **no deja pasar a "Ver resumen" ni guardar** si un renglón está incompleto o si un área de producción sin submedidor no tiene ningún equipo dado de alta (una luminaria cuenta: tipo Iluminación); al confirmar inserta en `activos_fijos` (+ `activos_fijos_centros`). Sin la migración el paso avisa que falta correrla. **Áreas y bases de prorrateo:** el panel Cargas eléctricas pasó a solo consulta (lee de Activos fijos, botón para ir a darlos de alta). Probado en Chromium con Supabase simulado (bloqueos, precarga, inserts). Pendiente: abrir el asistente y dar de alta los equipos reales (la luz queda en 0 kW hasta entonces); oficina sin equipos solo avisa. No tocado a propósito: `js/fresh-start.js` y `js/bitacora-cambios.js` (la tabla vieja sigue existiendo).

- Archivos tocados (lo último): `js/requisiciones-compra.js`, `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`. **Requisiciones: columna "Orden de Compra" solo con folios + acciones en "⋯"** (pedido del usuario
  2026-10-15): se quitó la fila "Motivo: …" de rechazadas y canceladas (el motivo se conserva en el detalle); "Orden de Compra" (encabezado y celdas centrados) solo lleva el folio de la ODC; las acciones de una
  pendiente (Autorizar/Editar/Rechazar/Cancelar) y "Marcar cancelada" pasaron a una columna nueva "Acciones" con botón "⋯" que despliega un menú (`reqMostrarMenuAcciones`, `#reqAccMenu`). **Botones:** esquinas
  de 12 px en vez de píldora (`border-radius: var(--r-sm)` para todo `button` salvo `.text-left`/`.w-full`; los temas Mac y Claro Ice ya tenían las suyas) y bisel casi plano (brillo .04/.10, canto 1 px, sombra corta).
  `?v=` CSS → `20261015160000`. Pendiente: que el usuario revise cómo quedó la forma de los botones/chips en varias pantallas y decida si el menú "⋯" se queda o prefiere botones visibles.
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Requisiciones: encabezados.** Columna "Folio" → **"Requisición"**; columna "Acción" → **"Orden de Compra"** en dos líneas
  (muestra solo el folio de la ODC; anchos 11/9/14/12/22/10/11/11 %). **Pendiente de decisión del usuario ("al rato reviso"):** las requisiciones pendientes guardan en esa misma celda sus botones
  (Autorizar/Editar/Rechazar/Cancelar), que con la columna angosta se acomodan en dos renglones bajo un encabezado "Orden de Compra" — opciones: (1) columna aparte "Acciones" solo para pendientes,
  (2) un solo botón "⋯" que despliega las 4 acciones, (3) dejarlo así.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Botones menos biselados** (pedido del usuario 2026-10-15, capturas del "Crear"): botones de color
  (verde/azul/índigo/rojo/ámbar) con volumen discreto — canto de 1 px (antes 2 px), brillo del degradado .08 (antes .24), brillo superior .16 (antes .45), sombra proyectada más corta, sin `text-shadow`, y al pasar el
  cursor sube 1 px (antes 2 px) con menos brillo; botones neutros (`bg-slate-800/700`) igual de suaves. Aplica a todos los temas con botones 3D (los temas "Mac"/Claro Ice ya eran planos). `?v=` de los 3 CSS
  en `index.html` → `20261015143000`. Además: en Requisiciones, las canceladas ya no muestran la fila "Motivo: …" debajo (se conserva en el detalle; las rechazadas sí la muestran). Pendiente: subir con "comitea".
- Archivos tocados (lo último): `index.html`, `js/requisiciones-compra.js`, `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. **Requisiciones de compra: encabezado y tabla** (pedido del usuario 2026-10-15,
  con mockup): título en singular "Requisición de Compra" + botón verde **"Crear"** separado del título (mismo tamaño que el mockup, `px-6 py-2 -my-1` para no alterar la altura de la fila fija); el formulario "Nueva
  requisición de compra" ya no vive arriba de la lista: es una subventana (`#reqNuevaWrap`, ids intactos) que abre "Crear" (`window.reqAbrirNueva`), se abre sola si se llega con partidas precargadas (Tareas,
  Producción, Pedidos) y al guardar sin "siguiente paso" se cierra y avisa con un toast; la píldora "Guardar requisición" se llama ahora "Crear". Se quitó el botón "📖 Cómo llenar esta pantalla" del
  encabezado de esta pantalla: la píldora "Ayuda" (asistente `montarGuia`) YA trae el botón "📖 Manual" que abre el mismo `#m-requisiciones-compra` — era el mismo contenido en dos botones. Tabla de la lista:
  anchos fijos (`table-fixed` + `<colgroup>`) para que no se muevan al filtrar; encabezados en formato título (sin `uppercase`; también en Cuentas por pagar: "PÓLIZA" → "Póliza"); chips de estatus con una sola
  convención (`reqEstLabel`: Pendiente/Autorizada/Rechazada/Cancelada, antes salían en minúsculas); botones de la columna Acción se acomodan en renglones sin ensanchar la columna. **Pendiente (decisión del usuario,
  a propósito sin tocar):** si el filtro de Estatus (menú con plurales "Pendientes/Autorizadas…") y los chips llevan botones o no, y su texto singular/plural; y extender la regla "Ayuda en un solo lugar" (quitar
  "Cómo llenar esta pantalla" duplicado) a las demás pantallas. **Hecho 2026-10-15:** quitado de las 6 que SÍ tienen píldora "Ayuda" (Pedidos de venta, Devoluciones, Bitácora de cambios, Importar claves de proveedor, Activos fijos, Bancos y Tesorería); quedan 13 con solo "Cómo llenar esta pantalla" (Productos/Alta, Clientes, Stock/Lotes, Compra directa, Entradas directas, Órdenes de compra, Recibo de mercancía, Salidas, Producción, Importador, etc.): no se quitó porque ahí es la ÚNICA entrada a la ayuda — para unificar hay que crear su guía "Ayuda" en `asistente-contable.js` y montarla en cada módulo.
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Requisiciones de compra: se quitaron los botones de filtro** (Pendientes/Autorizadas/Rechazadas/Canceladas/Todas) y el filtro de estatus pasó al **encabezado de la columna Estatus** (menú ▼, mismo patrón que Cuentas por pagar, posición fija para que el scroll de la tabla no lo recorte; default 'Pendientes'; con filtro sin resultados la tabla conserva su encabezado). `reqPintarFiltros` quedó vacía (la llaman 2 sitios). Pendiente: probar con Ctrl+Shift+R; subir con "comitea".
- Archivos tocados (lo último): `js/requisiciones-compra.js`, `version.json`, `CLAUDE.md`. **Requisiciones de compra: nuevo orden de columnas** (pedido del usuario 2026-10-15): Folio · Fecha · Acción · Antecedentes (botón propio, antes dentro de Acción) · Partidas · Total est. · Estatus · Origen (Origen se conserva al final; el usuario no lo mencionó). Pendiente: confirmar con el usuario si Origen se queda; subir con "comitea".
- Archivos tocados (lo último): `css/ui-moderno.css` (regla genérica al final), `index.html` (`?v=` de los 3 CSS), `js/bitacora-cambios.js`, `js/centros-costo.js` (se envolvió su tabla en `overflow-x-auto`), `version.json`, `CLAUDE.md`. **Encabezados fijos en TODAS las tablas de datos** (pedido del usuario 2026-10-15, con captura de Cuentas por pagar): toda tabla dentro de un contenedor `overflow-x-auto`/`overflow-auto` de una pantalla (`main section.vista-seccion`) tiene `thead` fijo y solo las filas se desplazan (`max-height: calc(100vh - 15rem)`, solo ≥1024 px); cubre ~92 de las 129 tablas del código. Quedan fuera a propósito: Cuentas por pagar y Lotes (tienen su propio esquema a pantalla completa), subventanas, impresión y tablas pequeñas de documentos sin contenedor (órdenes de producción, nómina, etc.). Excluir una: clase `tabla-sin-fijar` en su contenedor. NO probado renderizado: pendiente Ctrl+Shift+R en varias pantallas (Pólizas, Pedidos de venta, Bitácora, Kardex, Gastos, Centros de costo) y vigilar cortes de menús o tablas muy cortas con barra de scroll innecesaria. Sin SQL.
- Archivos tocados (lo último): `js/ordenes-compra.js`, `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. **Correcciones tras 3 capturas del usuario:** (1) `rmOcultarModal` no estaba en `window` → "Cerrar"/"×" del Pre-recibo (y de Editar pre-recibo) no cerraban; ahora sí. (2) ODC con anticipo cubierto y sin recibir muestra "ANTICIPO PAGADO" en lista y detalle; "Pactado/pagado/diferencia" sale también si lo pactado era 0; la historia de pagos muestra "Pendiente". (3) Cuentas por pagar: se quitó la palabra "recibo" de la columna Póliza y una ODC pagada solo con anticipos muestra la póliza BAN. (4) Filtro/chip "Parcial" → **"Pago parcial"** (el otro se queda "Anticipo pagado", decisión del usuario). Casos contables explicados al usuario: pago parcial = deuda ya recibida con abono (Cargo 201.01 + reclasifica IVA 119.01→118.01 proporcional); anticipo pagado = ODC sin recibir (Cargo 109.01/Abono banco). `sql/2026-10-14b…` y `…14c…` YA corridos por el usuario (2026-10-14). Pendiente: probar con una ODC nueva (anticipo 30% → recibir → pagar saldo).
- Archivos tocados (lo último): `sql/2026-10-14b_iva_anticipo_recepcion.sql` (nuevo, **NO corrido**), `sql/2026-10-14c_cxp_vence.sql` (nuevo, **NO corrido**), `js/pagos-proveedor.js`, `js/ordenes-compra.js`, `js/requisiciones-compra.js`, `js/recibo-operador.js`, `version.json`, `CLAUDE.md`. **Correcciones de la secuencia ODC-000010 (anticipo → recepción → pago)** que el usuario detectó con 11 capturas; mismas en las 3 entradas (requisición manual, ODC directa, requisición automática) porque todas convergen en la ODC.
  (1) **IVA del anticipo:** `contabilizar_compra` (cuerpo COMPLETO = versión 2026-10-07 + serie REC + cambio) manda a 118.01 la parte del IVA cubierta por el anticipo (51.00 en el ejemplo) y a 119.01 el resto; antes todo iba a 119.01 y esos 51.00 quedaban para siempre pendientes (el pago final reclasifica solo en proporción a lo pagado). Solo recepciones nuevas.
  (2) **"Pagada" falso:** una ODC con el anticipo cubierto pero sin recibir ya NO es "Pagada" sino estatus `anticipado` (chip "Anticipo pagado", filtro nuevo en el menú de Estatus). La tabla conserva SOLO Total y Saldo (el usuario rechazó una columna "Anticipado").
  (3) **Historia de pagos por ODC:** `cxpHistorialOc()` — "Ver" (y "ver pagos" en filas abiertas con pagos) muestra Total/Pagado/Pendiente y todos los pagos de la ODC (anticipos + pagos de sus recepciones) con póliza, comprobante y cancelar; el detalle de la ODC (`renderVistaOC`) gana "Historia de pagos" y, si el anticipo pagado difiere del pactado, "pactado/pagado/diferencia".
  (4) **Vista previa de la póliza de pago** ahora calcula las 4 líneas (201.01, 118.01, 119.01, banco) con el mismo cálculo que `registrar_pago_proveedor`. (5) **Recepción:** forma y método de pago SAT se precargan de lo pactado en la ODC (03 → transferencia; contado = PUE, crédito = PPD). (6) **Solicitante:** la ODC desde requisición también pide "Solicitado por" (preselecciona al empleado si el nombre coincide) y el Visto bueno del pago viene precargado con el solicitante, no con el operador. (7) **Crédito/Vence:** Contado muestra "— (contado)" en el plazo (modal de generación y de pago); `v_cuentas_por_pagar.vence` = contado sin vencimiento, crédito = fecha de la recepción + días. (8) **Pre-recibo (celular):** el "20/10" era `new Date('2026-10-21')` en UTC (un día antes) → fecha sin pasar por Date, ahora muestra fecha de la orden y entrega esperada; el total se rotula "sin IVA". (9) % de anticipo se limita a 0–100 al teclear (la base ya lo validaba).
  **Pendiente:** correr en Supabase `sql/2026-10-14b_iva_anticipo_recepcion.sql` y `sql/2026-10-14c_cxp_vence.sql`; probar con una ODC nueva (requisición → ODC con anticipo 30% → pagar anticipo → recibir → pagar saldo): la póliza de recepción debe traer 118.01 con la parte del anticipo y el pago final debe dejar 119.01 en cero; subir con "comitea". Los 3 documentos ya emitidos (ODC-000010) quedan como están (fase de pruebas → Fresh start).
- Archivos tocados (lo último): `index.html` (menú + títulos), `js/indice.js`, `js/asistente-prorrateo.js`, `js/areas-prorrateo.js`, `js/centros-costo.js`, `js/prorrateo.js`, `js/reparto-plantillas.js`,
  `manual-costos-produccion.html`, `guia-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Menú: nuevo grupo "Costos y prorrateo"** (pedido del usuario con captura: las 4 pantallas estaban separadas, Prorrateo en Finanzas
  y las otras 3 en Contabilidad). Ahora juntas, entre Finanzas y Contabilidad, en el orden de llenado: **Centros de costo → Áreas y bases de prorrateo → Reparto de gastos compartidos → Prorrateo de gastos** (configurar una vez,
  y al final la corrida mensual). Mismo cambio en el Índice (`SECCIONES`, grupo `costos-prorrateo`), en los títulos de las pantallas ("Costos y prorrateo · …"), en los textos del asistente y en las rutas del manual y la guía
  ("Menú → Costos y prorrateo → …"). Finanzas quedó con 7 entradas y Contabilidad con 5 (Pólizas, Plan de cuentas, Reportes contables, Cierre de periodo, Tabla ISR). Activos fijos se quedó en Finanzas. Sin SQL ni cambios de lógica.
  Total de grupos del menú: 10. Pendiente: verlo en el navegador (Ctrl+Shift+R) y subir con "comitea".
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. **Pagar anticipo (Cuentas por pagar):** el modal no tenía scroll y en pantallas bajas el botón "Registrar pago" quedaba fuera de vista (usuario atorado con un anticipo menor a lo pactado). Ahora el panel hace scroll (`max-h-[92vh]`) y la barra Cancelar/Registrar pago es fija abajo. La lógica de diferencia ya funcionaba: pagar menos de lo pactado se permite con el motivo obligatorio (queda en notas del pago). Pendiente: probar con ODC-000009.
- Archivos tocados (lo último): `js/inventario.js`, `css/ui-moderno.css`, `index.html` (`?v=`), `version.json`. **Lotes compacto:** botón "Cómo llenar esta pantalla" al borde derecho; filtros en una línea más baja (etiquetas al lado, "Solo con existencia" en línea); filas más bajas; título, filtros y encabezados fijos y solo las filas se desplazan (≥1024 px, clase `.lotes-scroll`). Pendiente: Ctrl+Shift+R en Lotes; si gusta, mismo esquema en otras tablas largas.
- Archivos tocados (lo último): `js/auxiliar-inventarios.js`, `js/cierre-periodo.js`, `version.json`, `CLAUDE.md`. **Cuadre de inventario: ahora dice QUÉ documentos explican la diferencia** (pedido del usuario con captura de
  Cierre de periodo: 115.01 con kardex 40,486.04 vs balanza 36,048.10, dif −4,437.94). Antes el cuadre solo listaba las pólizas SIN movimiento de inventario; faltaba la otra mitad. Nuevo `conciliarDocumentos()`: agrupa los
  movimientos del kardex por póliza (o por documento si no tiene) y compara kardex vs. lo contabilizado EN ESA cuenta; lista los que no coinciden ("sin póliza" = entró al kardex y nunca a la balanza; póliza por otro monto;
  cancelaciones a medias) y la suma documentos + pólizas sin kardex = la diferencia total. Sale en la pestaña Auxiliar de inventarios (bloque "📄 Documentos cuyo valor en el kardex NO coincide…") y, desde Cierre de periodo,
  botón "🔎 Ver qué documentos explican la diferencia de 115.01" en el detalle del candado → subventana `window.abrirCuadreInventarioCuenta(codigo, hasta)`. Solo lectura. Probado en Chromium con datos simulados (cuadra
  exacto). NO se ha corrido contra la base real: **pendiente que el usuario lo abra y vea los documentos**; probable causa (sin confirmar): documentos de compra (ej. FAA-88296, docs 40/41) en el kardex sin póliza. Pendiente: "comitea".
- Archivos tocados (lo último): `css/ui-moderno.css`, `js/app.js` (listener de scroll → `body.pagina-desplazada`), `index.html` (`?v=`), `version.json`. **Encabezado, 3 puntos del usuario:** (1) título centrado con el ☰ (y≈32) y píldora "Ayuda" de 28 px de alto (se bajó el alto, no el largo); (2) al desplazar, el título fijo se tapa con fondo opaco (`pagina-desplazada` + `box-shadow` del color de fondo) para que no se vea contenido detrás; (3) **Cuentas por pagar** (pantallas ≥1024 px): título+Ayuda, tarjetas KPI, fila "Documentos por pagar"/Desde-Hasta y encabezados de tabla quedan fijos; solo las filas se desplazan (scroll vertical propio, `thead` sticky). Probado renderizado (Chromium local, Claro Ice y Mac oscuro). Pendiente: Ctrl+Shift+R en la app real; vigilar que los menús de filtro del encabezado no se corten (están dentro del contenedor con scroll) y decidir si otras pantallas con tabla largas usan el mismo esquema.
- Archivos tocados (lo último): `js/cierre-periodo.js`, `version.json`, `CLAUDE.md`. **Cierre de periodo — pendientes ilegibles** (captura del usuario en Claro Ice): las tarjetas de cada pendiente usaban
  `bg-slate-950/60`, variante que `tema-base.css` NO remapea (solo `/80` y `/50`), así que quedaban gris oscuro con texto oscuro. Ahora usan `bg-slate-950`/`border-slate-700` (remapeados en todos los temas),
  texto más grande, conteo como pastilla ámbar, "· ver detalle ▾" y el detalle en renglones con etiqueta y valor (sin guiones bajos); el título ya no usa `capitalize` ("Septiembre de 2026 tiene…").
  **Corrección general (a petición del usuario):** `css/tema-base.css` ahora también remapea `bg-slate-950/60`, `bg-slate-900/30`, `bg-slate-800/60`, `/30` y `bg-slate-700/60` (antes quedaban gris oscuro fijo en temas claros: catálogo, conteo, órdenes de compra, tablas, etc.). NO se toca `bg-slate-950/40`: es el overlay de las subventanas. `?v=` de los 3 CSS subido. Sin SQL. Pendiente: verlo en el navegador (Ctrl+Shift+R) y subir con "comitea".
- Archivos tocados (lo último): `sql/2026-10-14_depreciacion_al_prorrateo.sql` (nuevo, **YA corrido por el usuario 2026-10-14**), `js/activos-fijos.js`, `js/prorrateo.js`, `js/asistente-prorrateo.js`, `version.json`, `CLAUDE.md`.
  **La depreciación de la maquinaria productiva entra al prorrateo del CIF** (pedido del usuario 2026-10-14: "considera poner esa necesidad de compra de maquinaria para tenerlo resuelto"; hoy no tiene maquinaria por
  depreciar, es para cuando compre). Hallazgos: `depreciacion_aplicar` cargaba 503.04 con póliza propia sin crear un gasto, así que el prorrateo (solo lee `gastos`) no la repartía; y el selector "cuenta de gasto"
  de Activos fijos solo listaba tipo `gasto`, no 503.xx (`costo`). **Decisión del usuario:** una máquina se usa en varias etapas y el reparto es en **PARTES IGUALES entre las etapas que se marquen** (descartó por
  horas de uso). Migración (funciones reescritas COMPLETAS): tabla `activos_fijos_centros` (activo ↔ etapas), `activos_fijos_depreciaciones.prorrateo_estatus` (no_aplica/pendiente/prorrateado),
  `gasto_aplicaciones.depreciacion_id` (gasto_id ya no es obligatorio; exactamente uno de los dos), y `depreciacion_aplicar`, `depreciacion_cancelar` (no deja si ya se prorrateó), `prorrateo_calcular` (se recrea:
  agrega `depreciacion_id`; la depreciación es CIF fijo de cada etapa, partes iguales con el centavo a la primera etapa), `prorrateo_aplicar` y `prorrateo_cancelar`. Solo entran máquinas con cuenta 503.xx y etapas;
  equipo de oficina (601.xx) o sin etapas = 'no_aplica'. Contabilidad: Cargo 503.04/Abono 153.xx al depreciar; Cargo 115.03 (o 503.98 si no se utilizó)/Abono 503.04 al prorratear (NIF C-4/C-6). Probada en Postgres local
  (3 etapas: 333.34/333.33/333.33, póliza cuadra, cancelaciones, 2 corridas de la migración). Activos fijos: el selector ya incluye 503.xx, bloque "¿En qué etapas se usa?" (checkboxes), columna "Etapas (CIF)" con ⚠ si falta.
  Prorrateo de gastos: las depreciaciones del mes aparecen en la tabla de gastos indirectos como "Depreciación <máquina>" (fijo). El asistente: el caso Depreciación ya no es solo advertencia (explica los pasos y lista las máquinas con o sin etapas)
  y la Revisión avisa solo si hay maquinaria sin etapas o falta la migración. Sin la migración todo degrada (no hay selector de etapas, no hay filas de depreciación). Subido a `main` (2026-10-14, "comitea": solo lo de prorrateo; los demás pendientes del proyecto quedan como están). Pendiente: probar
  con una máquina de prueba (alta con 503.04 y 2 etapas → aplicar depreciación → prorrateo).
- Archivos tocados (lo último): `js/prorrateo.js`, `css/ui-moderno.css`, `index.html` (`?v=` de los 3 CSS), `version.json`, `CLAUDE.md`. **Asistente de prorrateo más llamativo (opción C elegida por el usuario):** banner grande
  con degradado del acento del tema ("¿No sabes por dónde empezar?", lista de lo que falta, botón blanco "▶ Empezar el asistente" con pulso) + botón del encabezado con degradado y pulso; cuando no falta nada
  el banner se reduce a una línea "todo completo ✅ · Abrir" y se apaga el pulso. Reemplaza el aviso ámbar anterior. Clases `.pr-asist-*`/`.pr-pulso` al final de `ui-moderno.css` (solo esta pantalla;
  respeta `prefers-reduced-motion`). Revisado en Chromium con una página de muestra (Tailwind no carga aquí). Pendiente: verlo en la app real y en los temas oscuros/Claro Ice con Ctrl+Shift+R.
- Archivos tocados (lo último): `js/asistente-prorrateo.js` (nuevo), `js/prorrateo.js`, `js/asistente-contable.js`, `manual-costos-produccion.html`, `version.json`, `CLAUDE.md`. **Asistente de llenado del prorrateo**
  (pedido del usuario 2026-10-13: "no sé qué va primero", quería una guía interactiva con casos prácticos): botón destacado "🧭 Asistente de llenado" en Prorrateo de gastos que abre una subventana con 5 pasos en el
  orden de dependencia — (1) Tu planta: capacidad normal por etapa (operadores × jornada × días × factores), (2) Áreas: m²/personas/rol/etapa con sugerencias típicas de planta de cosméticos y farmacéuticos,
  (3) Luz: submedidor o equipos (kW/HP/W), (4) Tus gastos: 16 casos con preguntas (renta, luz, agua, gas, internet, mantenimiento, piezas [mejora mayor → Activos fijos], fumigación, monitoreo ambiental,
  calibraciones, limpieza, vigilancia/seguros, supervisión, insumos, calidad [de un lote → gasto directo], residuos) + info de depreciación y de lo que NO se prorratea, (5) Revisión del mes y simulación con
  `_reparto_resolver`. **Cada paso muestra un resumen y solo guarda al confirmar.** Escribe solo en tablas existentes (`centros_costo`, `areas_fisicas`(+`_cargas`), `reparto_plantillas`(+`_lineas`),
  `cuentas_contables` → crea cuentas 503.09–503.16 si no existen y fija `cif_tipo`); sin SQL nuevo. Cuentas nuevas propuestas: 503.09 Fumigación, 503.10 Monitoreo ambiental, 503.11 Calibración/validación,
  503.12 Refacciones, 503.13 Limpieza y sanitización, 503.14 Control de calidad externo, 503.15 Residuos, 503.16 Telecomunicaciones. `prorrateo.js` gana: aviso "Antes de aplicar, revisa" con atajo al paso del
  asistente, y tabla "Por etapa" (horas reales, capacidad, utilización, CIF aplicado y no utilizado por centro) — **corrige** que las tarjetas leían solo la primera fila del cálculo (con SURT/MEZ/ENV mezclaba/mostraba un centro).
  Probado en Chromium con Supabase simulado (los 5 pasos, 6 casos, guardado y simulación); falta probarlo con la base real y con Tailwind/estilos (no cargan en este entorno).
  (El hallazgo de la depreciación quedó resuelto en la entrada siguiente.) Pendiente: probar con Ctrl+Shift+R, subir con "comitea".
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html` (`?v=`), `version.json`. **Encabezado unificado — CORRECCIÓN tras PROBARLO RENDERIZADO** (ahora sí se puede: Chromium + `@tailwindcss/browser` local en el scratchpad,
  ruteando `cdn.tailwindcss.com` y abortando el resto; ver "Cómo ver pantallas aquí" abajo). Hallazgos: (1) el margen negativo `-2.5rem` + `position:sticky` dejaba el título a 24/48/64 px según la pantalla;
  (2) el título fijo NO se quedaba fijo porque `<main>` (Tailwind `overflow-y-auto`) no es quien se desplaza —lo hace la ventana—. Fix: en vez del margen negativo, `#app > main:has(> section.vista-seccion:not(.hidden):not(#view-bienvenida)) { padding-top:1.5rem }`
  (index.html lo deja en 4rem por el ☰) → las 43 pantallas con título nacen a la MISMA altura (medido); `#app > main { overflow: visible }` para que el sticky use la ventana (`top:.4rem`). La píldora "Ayuda" no es fija (se va con el scroll).
  **Cómo ver pantallas aquí:** servidor `python3 -m http.server`, Playwright-core + `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`, `npm i @tailwindcss/browser` (v4, sirve para maquetar), responder `cdn.tailwindcss.com` con ese JS y abortar lo demás; la app pide login (Supabase) así que se oculta `#loginOverlay`, se muestra la `section.vista-seccion` deseada y se inyecta contenido/`.asist-panel` de prueba.
  Pendiente: ver en la app real con Ctrl+Shift+R.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html` (`?v=`), `version.json`. **Encabezado unificado, PASO 2** (el usuario pidió ir por pasos: paso 1 = altura + título fijo; paso 2 = píldora): el cuadro "Asistente — … / 📖 Manual"
  (`.asist-panel`) pasa a ser en TODAS las pantallas y temas la píldora "Ayuda" arriba a la derecha (popover al abrir), con las reglas de `main section.vista-seccion:not(#view-bienvenida) .asist-panel`
  (antes solo `#contenedorPagosProveedor`). Sin HTML/JS/SQL. Pendiente: probar con Ctrl+Shift+R en varias pantallas (Pedidos de venta, Gastos, Pólizas…); vigilar choques con el botón "📖 Cómo llenar esta pantalla" a la derecha del título.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html` (`?v=` del CSS), `version.json`. **Corrección del encabezado unificado** (el usuario aclaró con capturas que NO quería la píldora "Ayuda" en todas las pantallas): se conserva en TODAS las pantallas
  (menos Inicio) la altura de Cuentas por pagar (título + tarjetas suben, `margin-top:-2.5rem`) y el título fijo (sticky); la píldora "Ayuda" (asistente + manual) vuelve a ser SOLO de Cuentas por pagar
  (`#contenedorPagosProveedor > .asist-panel`); en las demás pantallas el cuadro "Asistente — … / 📖 Manual" queda como era. Sin HTML/JS/SQL. Pendiente: probar con Ctrl+Shift+R.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html` (solo el `?v=` del CSS), `version.json`. **Encabezado unificado de TODAS las pantallas** (pedido del usuario 2026-10-13; referencia = Cuentas por pagar):
  las reglas que solo valían para `#view-pagos-proveedor` pasaron a `main section.vista-seccion:not(#view-bienvenida)` — (1) el título sube al renglón del ☰ (`margin-top:-2.5rem`, el mismo de CxP);
  (2) el título (o la fila título+botón Manual de las pantallas que la traen) queda **fijo arriba** (`position:sticky`, fondo `--bg-0`); (3) el bloque "Asistente — … / 📖 Manual" (`.asist-panel`, de
  `montarGuia`/`crearPanelAsistente`, incluido el de captura de Gastos) es en todas partes la píldora **"Ayuda"** arriba a la derecha, popover al abrir. Sin cambios de HTML/JS ni SQL. NO se pudo ver renderizado
  (Tailwind CDN no carga en este entorno): pendiente probar con Ctrl+Shift+R en varias pantallas (Pedidos de venta, Proveedores, Gastos, Productos) — vigilar que el título no quede tapado por el ☰ ni
  recortado arriba, que la píldora no choque con botones a la derecha del título, y que el título fijo no se vea raro en los temas oscuros. Si algo falla, el bloque está junto a "ENCABEZADO UNIFICADO" en `ui-moderno.css`.
- Archivos tocados (lo último): `js/tablas.js`, `index.html`, `js/indice.js`, `version.json`. A petición del usuario: se QUITARON de Configuración → Tablas las pantallas **Series de pólizas** y
  **Series de documentos** (menú, tarjetas del Índice y entradas de `TABLAS`); el usuario las revisa aparte y las retomará con el "Catálogo de series" (serie · qué es · tipo) como referencia.
  Sin migración SQL (el `…13c_series_polizas_tipo.sql` que se había escrito se descartó, nunca se corrió).
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `js/pagos-compras.js` (nuevo), `js/app.js`, `js/indice.js`, `js/buscador-auto.js`, `index.html`, `version.json`, `CLAUDE.md`. **"Pagos registrados" sale de
  Cuentas por pagar y pasa a Compras → Pagos a proveedores** (pedido del usuario 2026-10-13): la lista histórica ya no está en Finanzas. En Finanzas, el botón **"Ver"** de una fila pagada (o de una ODC
  con anticipo cubierto, que ahora se queda como "Pagada") muestra sus pagos con 🖨️ Comprobante y **Cancelar pago** (`cancelar_pago_proveedor`, contra-asiento): ÚNICO lugar donde se cancelan pagos
  ("solo Finanzas cancela"; sin roles aún, así que se resuelve por pantalla, no por permiso — restringir por rol cuando haya accesos). Compras ve la consulta nueva (Fecha, Proveedor, Aplicado a, Total,
  Forma/ref., Póliza, Mercancía, 🖨️) sin Cancelar. `cxpPagosPorClave` ('compra:id'/'gasto:id'/'oc:id') reemplaza a `cxpPagoPolizaPorDoc`. Sin cambios de SQL. Pendiente: revisar practicidad y consumo de
  recursos de las dos pantallas (el usuario lo dijo), y que el botón Ver de ODC con anticipo parcial también permita cancelar (hoy solo las ODC con anticipo ya cubierto).
- Archivos tocados (lo último): `sql/2026-10-13b_autor_registros_preparacion.sql` (nuevo, NO corrido, sin prisa), `CLAUDE.md`. **Columna "Creó" preparada, no activada** (pedido del usuario 2026-10-13:
  "que quede preparada para cuando implementemos los accesos a los usuarios"): `empleados.usuario_id` (liga empleado ↔ usuario de acceso) + `autor_de(uuid)` (nombre del empleado, o correo si no
  está ligado). La pantalla aún no la usa; `polizas.creado_por` ya se guarda. Falta, cuando se active: correr el SQL, ligar empleados con sus usuarios y pintar la columna "Creó" en la lista de
  pólizas, "Ver póliza" y documentos. Confirmado: `sql/2026-10-13_series_polizas.sql` YA corrido por el usuario (2026-10-13).
- Archivos tocados (lo último): `sql/2026-10-13_series_polizas.sql` (nuevo), `js/produccion.js`, `version.json`, `CLAUDE.md`. **Catálogo de series aprobado** (ver sección "Catálogo de series"):
  series para TODAS las pólizas vía tabla `polizas_series_origen` + `registrar_poliza()` reescrita completa (única función tocada; las 13 que crean pólizas no se tocan) y
  **OP → OPR** (orden de producción) y **ODP → OPC** (cierre de producción) en `produccion.js` (`siguienteFolio('OPR')` / `siguienteFolio('OPC')`; `siguiente_folio` crea el contador
  solo). Pendiente: correr `sql/2026-10-13_series_polizas.sql`, subir con "comitea" y probar un gasto/venta/nómina nuevos (deben salir como GAS-/VEN-/NOM-2026-0000N) y una
  orden de producción nueva (OPR-000001). Sin responder: columna "Creó" (¿correo o nombre del empleado?). Sin hacer: serie DET para deterioro.
- Archivos tocados (lo último): `js/enlaces-reporte.js`, `js/contabilidad.js`, `js/nomina.js`, `js/compras.js`, `js/cuentas-por-cobrar.js`, `js/documentos.js`, `js/entradas.js`,
  `js/ordenes-compra.js`, `js/pagos-proveedor.js`, `js/prorrateo.js`, `js/salidas.js`, `version.json`, `CLAUDE.md`. **Pólizas: nomenclatura visible unificada.** (1) Etiqueta
  `etiquetaDe`: con serie → SOLO el folio (`BAN-2026-00001`), sin serie → `Egreso No. 34` ("#" cambia a "No."); igual en título/impresión de "Ver póliza", lista de
  Pólizas, Contabilidad y Nómina. (2) Los botones "🧾 Póliza #<id interno>" (Compras, Entradas, Salidas, Cuentas por cobrar, Documentos, Órdenes de compra, Pagos registrados,
  Prorrateo, Gastos, Nómina) ahora son `<span data-pol-id>` que `enlaces-reporte.js` rotula solo (serie o tipo+No.): nunca más el id interno. Pendiente DECIDIR con el usuario
  (propuesta hecha, sin código): series para TODAS las pólizas (hoy solo BAN/VAE/ING/DIA/CMP/REC; "Diario No. 28" no dice qué es) y mostrar quién creó cada registro
  (`polizas.creado_por` existe; falta resolverlo a nombre).
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. **Cuentas por pagar: tabla unificada** (a petición del usuario, con capturas;
  se descartó la propuesta de quitar Pagada/Cancelada de la lista: "¿para qué entonces tengo filtros?"). (1) Anchos fijos (`table-fixed` + `<colgroup>`):
  las columnas ya no se recorren al cambiar de filtro, ni con la tabla vacía. (2) Se quitó `overflow-x-auto` del contenedor: era el que recortaba los menús
  de filtro y dibujaba una barra de desplazamiento pequeña que estorbaba. (3) La etiqueta del filtro elegido ya no flota (`absolute`, se empalmaba con el
  chip de la primera fila): va dentro del botón del encabezado, con `truncate`. (4) Columna Póliza: documento PAGADO muestra SOLO la póliza del pago
  (BAN-/VAE-…, vía `linkPoliza`); abiertos/cancelados, la del recibo. (5) Botón de acción de ancho fijo (72px): "Pagar" en abiertos (también en la vista
  "Todas"), "Ver" en pagados/cancelados → `cxpAbrirVer()` abre un selector con la póliza del recibo, el documento y la OC. Pendiente: subir con "comitea" y revisar
  en el navegador (Ctrl+Shift+R) que no queden barras, que las columnas no se muevan y que el menú de Estatus no se corte. No tocado a propósito: "Pagos registrados"
  (columna "# Docs" poco útil; se ofreció "Aplicado a" con el folio, sin respuesta).
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`, `version.json`, `CLAUDE.md`. **Cuentas por pagar: presentación homologada en TODOS los temas**
  (pedido del usuario; antes los ajustes eran solo de Claro Ice): se quitó el prefijo `[data-theme="claro-ice"]` de las reglas de `#view-pagos-proveedor` /
  `#contenedorPagosProveedor` — píldora "Ayuda" arriba a la derecha (el Asistente pasa a popover), título subido (`margin-top:-2.5rem`) y encabezado de
  tabla compacto. Siguen EXCLUSIVOS de Claro Ice solo la paleta/tipografía IBM Plex y los chips de estatus con color pálido propio (son del tema, no de la
  presentación). Subido `?v=` de los 3 CSS en `index.html` a `20261013120000`. Pendiente: subir con "comitea", Ctrl+Shift+R y revisar Cuentas por pagar en
  cada tema (sobre todo los oscuros: contraste de la píldora y del popover; usan `--bg-1`/`--bd-1`/`--sh-2` del tema).
- Archivos tocados (lo último): `sql/2026-10-12_odc_generar.sql` (nuevo), `js/requisiciones-compra.js`, `js/ordenes-compra.js`, `version.json`, `CLAUDE.md`.
  **ODC en UNA sola operación en la base:** `odc_generar(p_datos)` crea la ODC completa (cotización, condiciones, anticipo, partidas con costo/SKU) y, si
  viene de una requisición, la marca autorizada, todo en la misma transacción (antes eran 3 llamadas: `requisicion_autorizar` + update de la OC +
  update de cada partida; un corte a la mitad dejaba una ODC sin cotización). Mismo camino para ODC manual (sin `requisicion_id`) y desde requisición
  (partidas de la requisición, solo costo y SKU de la pantalla). El anticipo y el total (IVA 16% estimado) los calcula la base. `requisicion_autorizar`
  queda sin uso (no se tocó). **Hallazgo grave corregido en la misma migración:** `pagar_anticipo_oc` de `…07d` (ya corrida) se copió de `…10-27` y
  PERDIÓ el candado de `…09-30b` (anticipo acumulado ≤ total estimado × 1.30); la migración nueva la reescribe completa con el candado + serie BAN/VAE.
  También: el concepto de la póliza de anticipo ya no dice "OC ODC-…" y se quitó el prefijo "OC " repetido antes del folio en Requisiciones y en el
  pre-recibo (`ordenes-compra.js`); los documentos viejos con folio `OC-…` se dejan como están. Pendiente: correr `sql/2026-10-12_odc_generar.sql` en
  Supabase y subir con "comitea" (sin la migración, "Generar ODC" avisa que falta correrla); probar una ODC manual y una desde requisición.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. **Cuentas por pagar: lista única + conciliación con lo pactado.**
  Pedido del usuario: un anticipo de una ODC es un compromiso de pago manifestado y va en "Documentos por pagar", no en un panel aparte.
  `cxpCargarOcPorPagar()` (nunca lanza; corre en paralelo con la vista de deuda) arma renglones `tipo:'oc'` (anticipo pactado, o total con IVA
  si es contado sin anticipo, menos lo pagado) que se mezclan en `cxpCache`; chip "Por anticipar", botón "Pagar" igual al de las demás filas,
  sin checkbox (se paga de a una, otro asiento 109.01); `cxpAbrirPago` delega a `cxpAbrirAnticipo` si la fila es 'oc'. Las tarjetas de deuda
  NO suman estos compromisos; nueva tarjeta "Por anticipar (ODC)". Botón "Anticipo a otra OC" para ODC anteriores a las condiciones.
  **Conciliación pactado vs. ejecutado (sin SQL):** al pagar un anticipo o un documento ligado a una ODC con condiciones, se muestra lo
  pactado y se precarga la forma de pago; si Finanzas paga distinto (forma de pago o monto) se avisa, se exige el motivo y queda en las
  notas del pago como "[Difiere de lo pactado: …]". `cxpFormaDeClave` mapea la clave SAT de la ODC (01/02/03/04/28) al selector.
  Pendiente: un reporte/columna de desviaciones en "Pagos registrados" (hoy solo viven en las notas); que el pago de deuda también compare
  monto y plazo (hoy solo forma de pago). Falta subir con "comitea" y probar con ODC-000007.
- Archivos tocados (lo último): `js/buscador-auto.js` (nuevo), `js/buscador-select.js`, `js/app.js`, `version.json`, `CLAUDE.md`. **Buscador en
  selects de listas largas, en toda la app, sin tocar cada módulo**: `buscador-auto.js` (importado en `app.js`) detecta con un
  MutationObserver los `<select>` de su lista (~45: proveedores, clientes, cuentas contables, insumos de BOM, OC/órdenes, y el
  proveedor de la ODC formal por `data-f="proveedor"`) y los convierte con `convertirEnBuscador`; también los que nacen dentro de
  subventanas. `buscador-select.js` ganó: se refresca solo si el código asigna `.value` o cambia las opciones (antes había que llamar
  `buscadorRefrescar()`), copia al envoltorio las clases de diseño del select (col-span, flex-1…) y respeta `disabled`. No aplica a
  listas fijas cortas (condición, forma de pago, estatus) ni a las 3 apps de operador. Excluir uno: `data-sin-buscador`. Probado el
  componente en Edge headless (asignar value, opciones nuevas, disabled, clases de diseño); falta probar en pantallas reales (Compras,
  Gastos, Pedidos de venta, Pólizas, ODC formal). Pendiente: subir con "comitea" y revisar que ningún select oculto por clase propia
  deje su campo de texto visible (los que se ocultan desde un contenedor padre sí quedan bien).
- Archivos tocados (lo último): `sql/2026-10-09_odc_formal.sql` (nuevo), `js/requisiciones-compra.js`, `js/ordenes-compra.js`,
  `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. **ODC formal** (maqueta https://claude.ai/artifact/UHUmppsCjW93kPZ87LwQ5d):
  `reqAutorizar` ya no es el mini-modal — ahora es la subventana "Generación de Orden de Compra" (requisición de origen, cotización
  del proveedor con N.º/contacto/vigencia, condiciones, partidas con costo real y SKU proveedor, IVA 16% estimado, notas); al confirmar
  llama al mismo RPC `requisicion_autorizar` y luego actualiza `ordenes_compra` (cotizacion_*, `condicion_pago` contado/crédito,
  `dias_credito`, `forma_pago`, `anticipo_pct/_monto`) y el costo/SKU de cada partida. **Regla:** Compras solo PACTA; Finanzas ejecuta
  (anticipo con `pagar_anticipo_oc`, pago total/parcial desde Cuentas por pagar). La ODC NO genera póliza. Contable (NIF): anticipo
  antes de recibir = Cargo 109.01/Abono banco; al recibir `contabilizar_compra` reconoce SIEMPRE el pasivo completo en 201.01 y lo
  cancela contra 109.01 (así Proveedores queda tocada aunque sea contado 100% prepagado). Detalle de la ODC muestra cotización,
  condiciones, IVA/total y firmas al imprimir; el modal de anticipo en Cuentas por pagar muestra lo pactado y precarga el monto.
  Sin migración corrida degrada (detalle sin bloques nuevos). Pendiente: correr `sql/2026-10-09_odc_formal.sql` y probar una
  requisición → Autorizar; los 3 botones del encabezado del detalle (Antecedentes/Imprimir/Editar) NO se quitaron todavía; Editar
  no edita cotización/condiciones; no se pudo validar sintaxis (sin node en esta máquina) — revisar en el navegador con Ctrl+Shift+R.
  **Actualización:** se quitaron Antecedentes/Editar del encabezado del detalle (Imprimir pasó al pie). El formulario manual "Nueva orden
  de compra" se reemplazó por el botón "＋ Nueva orden de compra" → `window.reqAutorizar(null)` (mismo documento formal, modo manual: captura
  de partidas, solicitante, tipo de cambio DOF; inserta directo con folio ODC). Toda ODC nueva ya lleva cotización/condiciones/anticipo.
- Archivos tocados (lo último): `sql/2026-10-09_recepcion_serie_rec.sql` (nuevo), `js/contabilidad.js`, `version.json`,
  `CLAUDE.md`. A petición del usuario (dos capturas: "Diario #36" sin ninguna serie en la lista, y el modal de "Póliza
  Egreso #71" sin la serie BAN que sí se veía en la lista de Cuentas por pagar). **Revisados los asientos de la captura
  contra lo acordado: cuadran** — recepción (Diario #36) carga Inventario + IVA 119.01 "pendiente" contra Proveedores
  (crédito sin anticipo); pago (Egreso #71) cancela Proveedores, reclasifica 119.01→118.01 "pagado" (correcto por LIVA,
  el IVA solo es acreditable hasta que se paga) y abona Bancos — nada pendiente ahí, ningún cambio de código por eso.
  **Dos correcciones reales:** 1) El modal "Ver póliza" (`rcVerPoliza`, `js/contabilidad.js`) ya traía `folio_poliza` de
  la base pero el título y el nombre al imprimir lo ignoraban (`Póliza ${pol.tipo} #${pol.numero}`, fijo) — ahora muestra
  `Póliza BAN-2026-00001 · Egreso #71 · fecha` cuando la póliza tiene serie, igual que ya se veía en los enlaces de
  reportes (`linkPoliza`/`etiquetaPoliza`); sin serie, sigue como siempre. 2) La póliza de `contabilizar_compra()`
  (recepción de mercancía) era la única de las 6 que sí llevan serie (BAN/VAE/ING/DIA/CMP) que se había quedado sin la
  suya — nueva serie **REC**, mismo patrón de parche de texto sobre `pg_get_functiondef` ya usado para CMP (producción):
  busca `'tipo', 'Diario'` dentro del llamado a `registrar_poliza` de `contabilizar_compra()` (la versión vigente es
  `sql/2026-10-07_compras_notas_ajuste.sql`, la recepción siempre es Diario desde esa reescritura) y agrega
  `'serie', 'REC'` ahí mismo. Requiere `sql/2026-10-07d_polizas_series_y_visto_bueno.sql` corrida antes (crea
  `contadores_folios_poliza`/`_siguiente_folio_poliza`/`polizas.folio_poliza`) — confirmado al usuario que esa migración
  parece no estar corrida todavía (por eso no se veía ninguna serie BAN/VAE/etc. en ningún lado, ni siquiera en los pagos).
  Pendiente: correr `sql/2026-10-07d_polizas_series_y_visto_bueno.sql` (si no se ha corrido) y luego
  `sql/2026-10-09_recepcion_serie_rec.sql`; probar en el navegador que una recepción nueva salga como
  "REC-2026-00001 · Diario #N" en la lista de pólizas y en el modal.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. Ajuste sobre la ronda anterior: el
  label "Desde"/"Hasta" iba arriba del campo (`block`, apilado) — el usuario lo quería al lado (en línea, como en su
  referencia). Ahora cada campo es `<div class="flex items-center gap-1.5">` con label + input en la misma línea.
  Pendiente: confirmar en el navegador.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`, `CLAUDE.md`. Bug de layout reportado con captura
  (mockup del usuario vs. estado real): el renglón "Documentos por pagar" + Desde/Hasta/Limpiar usaba `justify-between`
  (título a la izquierda, filtros pegados al extremo derecho) — al no caber los dos extremos en una sola línea, el grupo
  de filtros se brincaba a su propio renglón, empezando en el extremo IZQUIERDO del contenedor (lo que el usuario vio y
  reportó como "lo traes en el extremo izquierdo"). Se quitó `justify-between` (ahora `gap-4`, sin separar a los extremos)
  para que Desde/Hasta/Limpiar queden pegados al título, como en su mockup. Pendiente: confirmar en el navegador (con
  Ctrl+Shift+R) que ya quedan juntos en vez de brincar a su propio renglón.
- Archivos tocados (lo último): `index.html`, `CLAUDE.md`. **Hallazgo real, probable causa de varias rondas de "no vi el
  cambio":** el CSS (`tema-base.css`/`ui-moderno.css`/`bienvenida.css`) se cargaba SIN `?v=`, a diferencia de los `.js`
  (que sí tienen cache-busting vía `cargador.js`/`version.json`) — el navegador podía estar sirviendo una copia vieja del
  CSS aunque ya estuviera actualizado en GitHub, sin importar Ctrl+Shift+R. Se agregó `?v=20261008234500` a los 3 `<link>`
  de CSS en `index.html` (mismo valor que `version.json`) y se documentó la convención para actualizarlo a mano en cada
  commit que toque `css/`. Pendiente: que el usuario recargue y confirme si AHORA sí se ven los cambios de Claro Ice
  (título subido, tabla compacta, chips con color propio) que llevaban varias rondas sin aparecer.
- Archivos tocados (lo último): `css/ui-moderno.css`, `version.json`. Corrección sobre la ronda 6: el "título duplicado" NO
  era un artefacto — el usuario literalmente puso una copia del texto en la posición que quería como referencia visual
  (con flecha "muévelo aquí"), no eran dos títulos reales. `margin-top` de Claro Ice en Cuentas por pagar subió de
  `-1.5rem` a `-2.5rem` (más agresivo). Pendiente: confirmar si con esto ya queda donde lo pidió, o si hace falta más.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `css/ui-moderno.css`, `version.json`. Ronda 6: el título duplicado
  que el usuario vio en una captura parece un artefacto de scroll/captura (la segunda captura, limpia, ya sale una sola vez
  bien colocado) — se le explicó, sin cambio de código por eso. Sí se reforzó lo que pedía de verdad: **"Claro Ice"** sube
  más el título (`margin-top` de `-0.75rem` a `-1.5rem`) y el encabezado de la tabla de "Documentos por pagar" se hizo más
  compacto (`padding` vertical de los `<th>` a `.5rem`, con más especificidad que no toca `thOrden()` — eso es compartido
  por otras pantallas). De paso, para TODOS los temas (es simple espaciado, no color): el espacio entre las tarjetas KPI y
  "Documentos por pagar", y entre ese renglón y la tabla, bajó de `mb-3` a `mb-2`. Pendiente: probar en el navegador con
  Claro Ice activo y confirmar que ya no se ve el título duplicado (si persiste, no es CSS — sería otra cosa, avisar).
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `css/ui-moderno.css`, `version.json`. Ronda 5 (5 capturas).
  **1) Desde/Hasta/Limpiar** se movió a la MISMA línea que "Documentos por pagar" (antes su propio renglón). **2) Se quitó
  "Suma: $X"** por completo (antes solo se ocultaba en vistas abiertas). **3) Cambio de comportamiento real, a petición
  explícita** (revierte una decisión de sesiones anteriores): Desde/Hasta ya NO se deshabilita ni se ignora en
  Pendiente/Vencida/Parcial — ahora filtra por fecha SIN importar el estatus, en cualquier vista; empieza siempre VACÍO
  (nunca prellenado con "inicio de mes/hoy", así no hay fecha que confundir) — se quitó el aviso "Desde/Hasta no aplica
  aquí". Las tarjetas KPI seguen siendo el total real sin filtrar por fecha (se separó `pendientesKPI` de
  `pendientesTodas`, que ahora sí respeta el rango). **4) Encabezados de columna ya no se desalinean**: el valor elegido
  (ej. "· Alkem Industrias" bajo Proveedor) ahora es `position:absolute` en vez de empujar el renglón — todos los `<th>`
  quedan en la misma línea tengan o no un filtro activo; de paso se igualó el tamaño de letra y el padding (`p-3`) con
  `thOrden()` (antes `text-[11px]`/`p-2`, inconsistente). El triángulo ▾ se cambió a ▼ más grande. **5) "Claro Ice":** el
  `<h2>` del título y el botón "Ayuda" (ya viven en el mismo renglón, ronda anterior) suben un poco más
  (`#view-pagos-proveedor { margin-top: -0.75rem }`, solo este tema/pantalla) para ganar espacio vertical. **Aclaración al
  usuario** sobre "¿dónde quedó el BAN-0000X?" en una póliza de pago: no es un bug de código — falta correr
  `sql/2026-10-07d_polizas_series_y_visto_bueno.sql` en Supabase; sin esa migración, `registrar_pago_proveedor()` sigue sin
  asignar serie y la póliza se muestra como "Egreso #N" genérico (comportamiento de respaldo ya previsto). Pendiente:
  correr esa migración si no se ha corrido, y probar en el navegador — Desde/Hasta en la vista Pendiente, alineación de
  encabezados, y el título subido en Claro Ice.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. Ronda 4 (captura marcando las tarjetas KPI): se
  quitó el texto de ayuda bajo "Anticipos disponibles" ("Se usan solos al pagar una OC sin recibir — sin botón aparte") y
  se recortó el padding de las 4 tarjetas (`p-3`→`p-2`, el contenedor `mb-4`→`mb-3`) — la tarjeta "Saldo total pendiente"
  sobraba espacio en blanco abajo comparada con las demás.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. Ronda 3 (3 capturas marcadas por el usuario después de
  probar un pago real). **1) "Ver ODC ODC-000002" repetía la palabra ODC** — ahora solo "Ver ODC-000002" (el folio ya trae
  el prefijo, no hace falta repetirlo). **2) Subtítulo redundante** en el encabezado de "Registrar pago" ("1 documento(s) ·
  Proveedor · saldo $X") — se quita cuando es un solo documento (la misma info ya está en Proveedor/RFC y en Resumen); se
  queda solo cuando son varios documentos, ahí sí es información nueva. **3) Hallazgo real, no era bug:** tras pagar
  ODC-000002 (quedó "Pagada", saldo $0.00), la columna Póliza seguía mostrando "Diario #34" — el usuario preguntó "¿dónde
  está el documento BANK?" (el de pago). Confirmado: así es por diseño — `v_cuentas_por_pagar.poliza_id` siempre es la del
  RECIBO (`contabilizar_compra`), nunca se actualiza con la del pago, son dos eventos contables distintos a propósito.
  Mejora real agregada: nueva consulta a `pagos_proveedor_aplicaciones` (join a `pagos_proveedor`, solo pagos
  `estatus='registrado'`) arma un mapa documento→póliza(s) de pago; la columna Póliza ahora muestra AMBAS, etiquetadas
  "recibo" (azul) y "pago" (verde) — antes solo se veía en el historial "Pagos registrados" más abajo, ahora también en la
  fila misma. Pendiente: probar en el navegador — pagar un documento y confirmar que su fila muestra las dos pólizas.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. Ronda 2 del mismo PDF "Revisión de documentos"
  (el usuario marcó "del recuadro rojo hacia abajo" en la imagen APROBADO): puro texto, sin tocar columnas (esas ya
  quedaron en la ronda anterior) ni colores. Se quitó el encabezado **"Proveedor y documento"** (tachado en rojo en la
  imagen); **"Fecha de la OC" → "Fecha de la ODC"** y **"Ver OC" → "Ver ODC"** (consistente con el folio real, que ya es
  ODC-000002, no OC-000002); **"Ver recibo" → "Ver recepción"** (así lo pidió explícito: "en lugar de ver factura ver
  recepción" — nunca hubo "Ver factura" en el código real, ya se llamaba "Ver recibo", solo cambió la palabra). La duda
  del usuario sobre "la factura, es el folio del documento o el folio digital" queda resuelta sola: no hay un link de
  factura aparte — el UUID del CFDI ya vive dentro del detalle de "Ver recepción" (`documentos.uuid_cfdi`). Pendiente:
  probar en el navegador que el bloque de proveedor/documento se vea bien sin el encabezado y que los 3 renombres
  aparezcan.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. A petición del usuario (PDF "Revisión de documentos"):
  dos ajustes de texto a la ventana de pago, sin tocar colores. **1) Tabla "Qué ampara este pago"** gana las columnas que
  faltaban — **Cta.** (cuenta de inventario del producto, `productos.cuenta_inventario_id`, con el mismo fallback 115.01 que
  usa `contabilizar_compra()`) y **P. Unit.** (`documento_detalles.costo_unitario`, ya se traía de la base pero no se
  pintaba) — ahora son 6 columnas: Código/Descripción/Cta./Cant./P. Unit./Importe, igual que la maqueta. **2) "Documentos"**
  (dentro de Proveedor y documento) ahora también lista las notas de crédito/cargo activas de este recibo (`notas_compra`,
  folio NDC-/NDP-) junto a "Ver OC · Ver recibo" — antes esas notas solo se veían más abajo, en Aprobaciones y trazabilidad.
  **Aclaración al usuario sobre ODC-000002** (no era un bug): su póliza Diario es SOLO la del recibo de mercancía — reconoce
  115.01/119.01 contra 201.01 Proveedores, nunca toca banco — por eso el botón "Pagar" sigue activo con saldo real pendiente;
  es exactamente la regla "Compras ya no decide el pago" de la sesión del 2026-10-07, funcionando como se diseñó. Pendiente:
  probar en el navegador con un documento que tenga nota de ajuste activa, para ver las dos columnas nuevas y el folio NDC/NDP
  junto a Ver OC/Ver recibo.
- Archivos tocados (lo último): `js/pagos-proveedor.js`, `version.json`. A petición del usuario (comparativo PDF "ACTUAL vs
  FORMATO APROBADO" con capturas marcadas): tabla de Cuentas por pagar ajustada al formato acordado. Quitada la columna
  **Tipo** (siempre decía "compra", sin valor — el formato aprobado no la tiene). Columna **Póliza** simplificada a un solo
  link de texto (`linkPoliza()`, ya se auto-rotula "Egreso #N" o "BAN-2027-00001 · Egreso #N" si ya corrió `…07d`) — se quitó
  el botón grande "🧾 Póliza #N" y el botón "Ver recibo" (**era 100% redundante**: hacía el mismo `abrirDetalleDocumentoGlobal`
  que ya dispara el link de la columna Documento — verificado antes de quitarlo, no se perdió nada). Nuevo **botón "Pagar"
  individual por fila** (azul, solo visible en vistas "abiertas" — Pendiente/Vencida/Parcial, igual que el checkbox): paga
  ESE documento directo, sin marcar su casilla primero — antes solo existía "Pagar selección" con checkbox. Confirmado al
  usuario: el botón se deja de ver solo cuando el documento sale de esas vistas (saldo llega a 0 → pasa a "Pagada" → ya no
  tiene checkbox ni botón Pagar, por diseño de `esAbierto`). **Trazabilidad real agregada** a "Aprobaciones" en la ventana de
  pago (antes solo tenía el selector de Visto bueno): si la OC viene de una requisición, muestra folio + quién/cuándo la
  autorizó (`requisiciones_compra.revisada_por/revisada_en`); si el documento tiene una nota de crédito/cargo activa
  (`notas_compra`, del candado de diferencia física vs. factura), la muestra con monto y motivo. Ambas solo cuando se paga
  UN documento (con selección múltiple no hay detalle rico, igual que "Qué ampara este pago"). A propósito NO se agregó lo
  demás que trae la maqueta ahí ("Recepción validada en almacén", "1 concepto fuera de lo habitual") — no hay dato real
  detrás, se habría tenido que inventar. Pendiente: probar en el navegador — que el botón Pagar de fila abra la ventana
  correcta, que Póliza muestre el link bien, y revisar una OC con requisición ligada y otra con nota de ajuste para ver la
  trazabilidad nueva. **Corrección de la misma ronda:** se quitó el "Saldo total: $X" junto a "Documentos por pagar" en las
  vistas abiertas (Pendiente/Vencida/Parcial) — duplicaba exactamente la tarjeta KPI "Saldo total pendiente" de arriba
  (el usuario lo marcó con flecha). En Pagadas/Canceladas/Todas se queda "Suma: $X" (ahí sí es un dato distinto, la KPI no
  lo cubre).
- Archivos tocados (lo último): `css/ui-moderno.css`. A petición del usuario (con captura marcando dónde): en **Cuentas por
  pagar, SOLO con el tema Claro Ice activo**, el bloque "Asistente — Cuentas por pagar" (lo monta `montarGuia()`, compartido
  por ~19 pantallas — NO se tocó ese archivo) se compacta a una píldora "Ayuda" arriba a la derecha, junto al `<h2>` del
  título, en vez de ocupar su propio renglón completo abajo. Al abrirlo se vuelve un popover flotante (420px) con el
  contenido completo + el botón "📖 Manual" (ambos ocultos mientras está colapsado). Es 100% CSS, scoped a
  `#contenedorPagosProveedor > .asist-panel` bajo `[data-theme="claro-ice"]` — usa `position:absolute` relativo a
  `#view-pagos-proveedor` (padre común del `<h2>` y del contenedor) y `:has()` para cambiar de píldora a popover según si
  `.asist-body` está `.hidden` o no. Con cualquier otro tema, o en cualquier otra pantalla, no cambia nada. Pendiente:
  probar en el navegador — que la píldora quede alineada con el título, que abrir/cerrar funcione igual que siempre, y que
  no se monte encima de las tarjetas KPI de forma rara.
- Archivos tocados (lo último): `css/ui-moderno.css`, `index.html`. A petición del usuario: nuevo tema global **"Claro Ice"**
  (`data-theme="claro-ice"`, tarjeta en Configuración → Temas de usuario, junto a "Mac (oscuro)") con la paleta y tipografía de
  la maqueta de Cuentas por pagar v2 — **modo CLARO** de la maqueta (`:root[data-theme="light"]` de su HTML, no el oscuro que
  se probó primero y el usuario corrigió con captura): fondo azul-hielo muy pálido (`#f1f4fb`), tarjetas blancas (`#ffffff`),
  acento azul (`#1d5fd1`), tipografía **IBM Plex Sans/Mono** (Google Fonts agregado en `index.html`, solo para este tema — los
  demás se quedan con Inter). Mismo patrón que "Mac (claro)" (`[data-theme="macos"]`, usado como plantilla de forma): variables
  `--bg-0..3`/`--bd-0..2`/`--tx-0..5`/`--acc`/`--ok`/`--bad`/`--warn`/`--chip` propias (no toca `tema-base.css`) + reglas de
  forma (botones planos sin degradado, esquinas 9-12px, campos planos, menú lateral translúcido claro). Diferencia extra sobre
  la plantilla macos: los chips de estatus (Pendiente/Vencida/Pagada) llevan su PROPIO fondo pálido por color
  (`.bg-amber-950`→`#fdf0cf`, `.bg-rose-950`/`.bg-red-950`→`#fde0e6`, `.bg-emerald-950`→`#d9f3e8`, `.bg-sky-950`→`#e1eaff`,
  todo `!important` solo bajo `[data-theme="claro-ice"]`) — el remapeo genérico de `tema-base.css` solo da un `--chip` único
  para todas, y en la maqueta cada estatus trae su propio tono. Revisado funcionalmente: todo lo que la maqueta hace (filtros
  de encabezado, chips, KPIs, ventana de pago, pop-up de autorización) ya estaba portado al código real en sesiones
  anteriores — lo único que faltaba era la piel visual. Lo que la maqueta tiene de más NO se portó, a propósito (ya explicado
  antes): el interruptor Subventana/Pantalla completa (el usuario ya eligió solo subventana) y el interruptor de "Caso:
  anticipo/deuda" (no aplica, anticipo es un flujo aparte en el código real) — ni "Observar y devolver" / "Pedir confirmación"
  de la maqueta, que ahí tampoco hacen nada real (solo un mensaje de aviso), para no meter botones sin función real detrás.
  El CSS no se versiona en `version.json` (confirmado en sesiones previas) — no hace falta tocarlo aquí, pero el navegador
  puede necesitar Ctrl+Shift+R por caché de CSS. Pendiente: probar el tema nuevo en el navegador, sobre todo en Cuentas por
  pagar (las tarjetas KPI, los chips de estatus con su color propio, la ventana de pago) y el menú lateral translúcido.
- Archivos tocados (lo último): `sql/2026-10-08_fix_dias_credito_legacy.sql` (nuevo), `js/pagos-proveedor.js`, `version.json`.
  A petición del usuario, dos correcciones sobre lo de ayer, comparando contra la maqueta otra vez. **1) Bug real encontrado
  comparando contra la maqueta**: todas las OC existentes (de antes de "Días de crédito") salían "Vencida" — el backfill de
  ayer les puso `dias_credito = 0`, y como son de septiembre, Vence (fecha + 0) ya quedaba en el pasado; antes de ese campo
  no existía ningún concepto de "vencida" para ellas. `dias_credito` vuelve a ser NULLABLE (sin default); las que tenían 0 por
  el backfill regresan a NULL (Vence sale "—", nunca Vencida); las OC NUEVAS lo siguen exigiendo, pero eso es validación de
  pantalla (`ordenes-compra.js`), no columna NOT NULL. **Ojo**: ese SQL solo es seguro correrlo el mismo día — si ya se
  capturó una OC real con "Inmediato" (0) a propósito, también se le borraría; avisar antes de recorrerlo si pasó tiempo.
  **2) Ventana "Registrar pago" reconstruida en dos columnas, igual que la maqueta** (antes era una sola columna con los
  campos apilados, divergía bastante): izquierda = Proveedor y documento (RFC, fecha de la OC, días de crédito, enlaces Ver
  OC/Ver recibo), Qué ampara este pago (tabla de líneas con código/descripción/cantidad/importe + subtotal/IVA/total — SOLO
  cuando se paga UN documento, trae `documento_detalles` fresco al abrir; con varios documentos seleccionados se queda la
  tabla resumen folio+saldo de siempre) y Aprobaciones (el selector de Visto bueno, que antes vivía del lado derecho);
  derecha = Datos del pago (+ nuevo campo "Notas internas", el RPC ya lo soportaba y no se estaba usando), Resumen (Total/
  Pagado anteriormente/Este pago/Saldo restante, en vivo) y una vista previa de la póliza (cuenta cargo/abono, serie BAN o
  VAE según la cuenta elegida). La ventana YA era subventana movible/redimensionable/maximizable desde que se creó —
  `subventanas-movibles.js` la detecta sola por su estructura (`fixed inset-0`, panel = primer hijo) — lo que faltaba era
  el contenido, no el mecanismo. `cxpAbrirPago` pasó a `async` (trae el detalle antes de pintar, con un "Cargando…" breve).
  Pendiente: correr `sql/2026-10-08_fix_dias_credito_legacy.sql` y probar — que las OC viejas ya no salgan Vencida, y abrir
  "Pagar" en un documento único vs. varios para ver las dos variantes de "Qué ampara este pago".
- Archivos tocados (lo último): `sql/2026-10-07b_cxp_v2.sql`, `sql/2026-10-07c_diagnostico_migraciones_pendientes3.sql` (solo
  lectura), `sql/2026-10-07d_polizas_series_y_visto_bueno.sql` (nuevos), `js/pagos-proveedor.js`, `js/ordenes-compra.js`,
  `js/enlaces-reporte.js`, `version.json`. **Cuentas por pagar v2 implementada en código real** (hasta hoy solo vivía en la
  maqueta https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi) + **nomenclatura de pólizas por serie** + **visto bueno ligado a
  empleado real**. Pagos a proveedores: "Pendientes de pago" → "Pendiente"; Folio de cada fila = el de la OC, nunca el del recibo
  (`v_cuentas_por_pagar` ahora hace `coalesce(oc.folio, d.folio)`, vista recreada con `DROP VIEW` porque `CREATE OR REPLACE` no
  deja cambiar el tipo de una columna); columna "Pagado" quitada, columna "Vence" agregada (= fecha de la OC + `dias_credito`,
  en rojo si ya venció); columna "Póliza / Recibo" → "Póliza"; botón "💰 Pagar anticipo a una OC" bajó de botón prominente a link
  discreto aparte (a propósito: un anticipo sobre una OC sin recibir no es una deuda todavía, meterlo en la lista de saldo
  pendiente habría sido contablemente engañoso — es la ÚNICA diferencia a propósito contra lo acordado en la maqueta); pagar
  varias OC del mismo proveedor en un solo pago sigue permitido pero ahora pide autorización (pop-up con nombre de quien
  autoriza, texto libre por ahora); "Forma de pago" ya no viene preseleccionado; alerta visual de efectivo > $2,000 (el asiento
  contable de IVA no acreditable queda pendiente de validar con el contador, a propósito); 4 tarjetas KPI (Saldo total
  pendiente/Vencido/Vence en 7 días/Anticipos disponibles). Órdenes de compra: nuevo campo obligatorio **"Días de crédito"**
  (Inmediato/7/15/30/60, select con fallback si la migración no se ha corrido) y nuevo campo opcional **"Solicitado por"**
  (empleado real, no texto libre). **Nomenclatura de pólizas**: nueva tabla `contadores_folios_poliza` (consecutivo POR AÑO,
  ej. `BAN-2027-00001` — distinto a `contadores_folios`, que es continuo) + función `_siguiente_folio_poliza(serie, fecha)` +
  columna `polizas.folio_poliza`; `registrar_poliza()` gana `p_datos->>'serie'` opcional (si no viene, sigue igual que
  siempre); solo 5 flujos la usan: `pagar_anticipo_oc`/`registrar_pago_proveedor` (BAN si la cuenta es banco 102.x, VAE si es
  caja 101.x), `registrar_cobro_cliente` (siempre ING), `cancelar_poliza` (siempre DIA, en TODA cancelación sin importar la
  serie original), `contabilizar_produccion` (siempre CMP — parche de texto sobre `pg_get_functiondef`, mismo patrón ya usado en
  `2026-10-05_series_3_letras.sql`, se eligió CMP y no ODP para no chocar con el folio del documento de cierre). Compras,
  gastos, nómina, activos fijos, devoluciones y prorrateo NO llevan serie, se quedan como "Diario #N"/"Egreso #N". `etiquetaPoliza()`
  (`js/enlaces-reporte.js`) ya muestra `"BAN-2027-00001 · Egreso #34"` cuando hay serie, con fallback si la columna no existe
  aún. **Visto bueno**: `ordenes_compra.solicitante_empleado_id` + `pagos_proveedor.visto_bueno_empleado_id`/`_at` (FK a
  `empleados`, no texto libre) — sigue siendo informativo, no bloquea nada; se marca a mano desde un select en la ventana de
  pago (columna nueva "Visto bueno" en el historial). Pendiente a propósito, no es de hoy: que aparezca en el menú de Tareas del
  empleado en vez de marcarse a mano aquí. Probado visualmente en el navegador (capturas del usuario) tras cada push — faltan
  push de ESTA ronda (pólizas/visto bueno/KPIs) y correr `…07d` en Supabase. **Corrección a petición explícita del usuario:**
  el filtro de Estatus había quedado como pestañas (simplificación propia, no se lo mostré claro) — se deshizo: ahora Documento,
  Proveedor y Estatus son menú desplegable EN EL ENCABEZADO de columna (triángulo ▼, valor elegido debajo del botón en letra
  chica para no ensanchar la columna), igual que la maqueta. Nuevo: columna Estatus con chip por fila (Pendiente/Vencida/
  Parcial/Pagada/Cancelada — Vencida/Parcial se calculan en el cliente, `v_cuentas_por_pagar.estatus_cxp` solo conoce pendiente/
  pagado/cancelado); columna checkbox siempre presente (antes se sustituía por "Estatus" en las vistas no-pendientes). Corregido
  de paso: si un filtro no encontraba nada, la tabla entera desaparecía (con los 3 menús adentro) dejando al usuario sin forma
  de cambiar el filtro — ahora el `<thead>` siempre se queda, solo cambia la fila del `<tbody>`. Un solo listener global
  (`window.__cxpMenuListener`, mismo patrón que `subventanas-movibles.js`) cierra los menús al tocar fuera o con Escape.
  **Deploy**: esta sesión no tenía git local
  conectado — se subió con script temporal vía API de GitHub (token del usuario, nunca guardado, script borrado después,
  verificado antes de pushear que nadie más hubiera tocado los mismos archivos en GitHub — ver `feedback-sync-verificar-antes-de-pushear`).
- Archivos tocados (lo último): `sql/2026-10-07_compras_notas_ajuste.sql` (nuevo), `sql/2026-10-07_diagnostico_aju_egresos.sql`
  (nuevo, solo lectura), `js/ordenes-compra.js`, `js/pagos-proveedor.js`, `version.json`. **Compras ya no decide el pago + Notas
  de crédito/cargo (NDC/NDP).** Corrección sobre el plan de ayer: "Recibo de mercancía" y "Pre-recibos" ya eran la MISMA pantalla
  (el pre-recibo se valida ahí mismo, con el mismo botón que contabiliza) — no se quitó ningún menú, solo el bloque de pago de
  esa pantalla. `contabilizar_compra()` reescrita: ya no recibe Condición ni Cuenta de pago (se quitaron del formulario de
  recepción); la recepción SIEMPRE contabiliza a crédito, aplica el anticipo de la OC si lo hay (ya existía) y la póliza es
  SIEMPRE Diario — el banco solo se mueve en `pagar_anticipo_oc` (antes) o el pago desde Cuentas por pagar (después), que ya
  generaban Egreso bien. El IVA (118.01 pagado / 119.01 pendiente) ahora depende de si el anticipo cubrió TODO (resto = 0), no
  de un combo Contado/Crédito que ya no existe. **NDC/NDP:** cuando lo recibido no coincide en valor con la factura (el candado
  de 2026-10-07 que antes solo tronaba), ahora se puede resolver sin salir de la recepción — `contabilizar_compra` devuelve la
  diferencia con detalle estructurado, `js/ordenes-compra.js` (`rmPedirNotaAjuste`) pregunta tipo (NDC si llegó menos / NDP si
  llegó más, precargado), motivo (dañada en transporte / caducada / fuera de especificación / empaque roto / excedente /
  producto distinto / Otro, con detalle obligatorio) y monto, y reintenta. La nota vive en tabla nueva `notas_compra` (folio
  NDC-/NDP- vía `siguiente_folio`) SIN póliza propia — su efecto contable es un ajuste al 201.01 reconocido en la MISMA póliza
  de la recepción, así que cancelar la recepción (`cancelar_recibo_inventario`, que ahora también marca la nota 'cancelada')
  revierte todo junto. El inventario siempre entra a lo que de verdad llegó (nunca al valor de la factura). Rechazo por mercancía
  dañada/consumida: el usuario decidió NO usar una nota aparte sobre algo ya consumido — se resuelve aquí, en el momento de
  validar. **Pagos a proveedor:** se quitó 102.02 (Bancos extranjeros USD) del selector de cuenta de pago (`js/pagos-proveedor.js`,
  un solo punto: el fetch que alimenta todos los selectores de esa pantalla) — la empresa nunca paga en USD (no tiene cuenta),
  aunque la OC esté en USD; la cuenta se queda en el catálogo para cuando haya expansión real a compras/ventas en el extranjero.
  **Sin hacer a propósito, por tiempo/riesgo (pendiente, más chico):** motivo de rechazo por partida (por qué no se recibió
  completa una línea) — iba a tocar dos flujos de captura (OC normal y XML directo); se dejó fuera para no meterlo a medias.
  **Diagnóstico de los 3 documentos que no cuadran** (AJU-000001 $27,553.24, Egreso #67 $16,946 F-2407, Egreso #69 pago OC-000001
  en 102.02): NO se canceló/archivó nada todavía — no hay función para deshacer una salida de ajuste de inventario (solo
  recepciones, devoluciones y pólizas sueltas tienen "cancelar"), y antes de inventar una reversa a mano hace falta saber si ese
  inventario ya se consumió en producción (si sí, es más delicado). El SQL de diagnóstico (solo lectura) ya está listo — falta
  correrlo y revisar el resultado antes de decidir cómo cerrar cada uno. Pendiente: correr ambos SQL (el de compras/notas primero,
  es el que de verdad cambia comportamiento; el diagnóstico es independiente y no tiene prisa) y probar una recepción con
  diferencia real para ver aparecer el cuadro de NDC/NDP.
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
  **A) Cuentas por pagar (Finanzas) — ronda de feedback 2026-10-07 (sobre la pantalla real, incorporada a la maqueta v2):**
  documento de la fila = OC, nunca folio de recepción como subtítulo; Saldo ya neta el anticipo (sin "diste $2,000" aparte);
  sin botón "💰 Pagar anticipo a una OC" ni selector de proveedor repetido — un solo "Pagar" por fila decide sola si es
  anticipo o deuda; filtro de Estatus en el encabezado de columna, no en pestañas. Maqueta v2 actualizada con estos puntos.
  **A) Cuentas por pagar (Finanzas) — ya acordado en la maqueta:** documento = OC autorizada (sin folio de recepción en la lista); columnas Total y Saldo (sin "pagado"); botón siempre "Pagar"; filtros en los encabezados
  (Documento ▾ busca folio de OC, Proveedor ▾, Estatus ▾ con Pendientes/Pendiente/Vencida/Parcial/Pagada/Cancelada/Todas) + solo "desde"/"hasta" arriba; sin columna de alertas; columna "Póliza"; sin enlace de anticipo en la tarjeta de anticipos;
  un pago = un proveedor = un evento; Pago total NO editable (refleja el saldo de la OC), Pago parcial editable y EXIGE escribir el acuerdo con el proveedor (+ evidencia opcional; idealmente la condición se declara en la OC, queda en el tintero);
  visto bueno de quien solicitó solo informativo (después obligatorio, como interruptor en Configuración). Subventana movible vs pantalla completa: la maqueta muestra ambas, falta que el usuario elija. Contabilidad (ya existe, verificado en
  `pagar_anticipo_oc` y `contabilizar_compra`): prepago 100% contra la cotización anexa a la OC = anticipo (Cargo 109.01 / Abono banco, Egreso); al validar el pre-recibo, UNA póliza Diario reconoce Inventario + IVA 118.01 contra 201.01 y cancela
  201.01 contra 109.01 (queda inventario, IVA y banco; Proveedores en cero). La deuda por recepción solo vive en compras a crédito y gastos. La pantalla de pago debe decidir sola entre anticipo (OC sin recibir) y pago de deuda (OC recibida).
  **Nomenclatura de pólizas — DECIDIDO 2026-10-07 (sigue sin código, pero ya no son preguntas abiertas):** serie por origen con 3 letras,
  además del tipo SAT (Ingreso/Egreso/Diario, que se sigue reportando): BAN = pago por banco, VAE = pago en efectivo a una persona,
  ING = ingresos por depósitos, DIA = cancelaciones/diario, **CMP = la póliza Diario que genera `contabilizar_produccion()` al cerrar una
  orden de producción** (Consumo de Materia Prima — se eligió CMP y no ODP para no chocar: ODP es el folio del DOCUMENTO que nace al
  cerrar la orden — entrada ODP-000123 + salida ODP-000123-MP —, no el de la póliza; hoy esa póliza es un "Diario #N" genérico sin serie
  propia, y solo el documento de entrada carga con `poliza_id`, el de salida es puro Kardex). La serie de pago sale de la cuenta
  (banco→BAN, caja→VAE). **Consecutivo por año** (ej. `BAN-2027-00001`, se reinicia cada enero). Hoy sigue siendo "Tipo #número" con
  consecutivo por (tipo, año) y la cancelación crea contra-asiento del MISMO tipo (`cancelar_poliza`); no renumerar pólizas viejas.
  Confirmado: ninguna póliza/documento de este ERP espera a un evento posterior para volverse contable (ni pagos: el Egreso nace al dar
  "Confirmar pago", no al aparecer en el banco) — no hay equivalente a "cheque en tránsito" o "vale por comprobar".
  **Resueltas las demás preguntas abiertas:**
  - Varias OC del mismo proveedor en un solo pago/transferencia: **sí se permite**, pero pide un pop-up de autorización del responsable
    de finanzas (por ahora solo el pop-up/placeholder, sin ligar a roles reales todavía).
  - "Vence/Vencida": nuevo campo **obligatorio** en la OC, "Días de crédito" (desplegable: Inmediato/7/15/30/60 días) — Vence = fecha de
    la OC + esos días. No se puede dejar en blanco. (Reemplaza la idea de capturarlo en el catálogo de Proveedores.)
  - Visto bueno de quien solicitó: sigue **informativo** por ahora, pero la base debe quedar lista para ligarlo a un usuario real (no
    texto libre) y que después aparezca en el menú de Tareas de ese usuario (encaja con el sistema de `tareas.js` ya existente).
  - Alerta de pago en efectivo > $2,000: **confirmado implementar**, con el asiento reflejando no deducible / IVA no acreditable
    (LISR 27 fr. III / LIVA 5 fr. III) — la alerta en pantalla es sencilla; las cuentas exactas para el IVA no acreditable quedan
    pendientes de validar con el contador antes de tocar código contable.
  - Forma de pago: el campo empieza **vacío** (sin preseleccionar Transferencia ni nada).
  - Serie OC vs ODC: sin cambio, ODC ya es la serie vigente del documento de la orden de compra (no de una póliza).
  Pendiente (sin resolver aún, menor prioridad): datos que faltarían en la base — banco/CLABE/beneficiario del proveedor (con
  bitácora), UUID del complemento de pago (REP) en compras PPD, estado "observado". DIOT sigue vigente (formato nuevo 2025), se basa en
  lo pagado por proveedor. Maqueta v2 (https://claude.ai/artifact/PeKAi5Wsp4VdokSwZzMDoi) actualizada con filtros en encabezado,
  Documento=OC, Saldo neto, sin botón de anticipo aparte — **falta reflejar ahí** CMP, días de crédito, pop-up de varias OC y forma de
  pago vacía. **Nada de esto tiene código real todavía** — falta el plan de implementación (SQL de series de póliza + campo
  `dias_credito` en OC + reescribir `js/pagos-proveedor.js` y partes de `js/ordenes-compra.js`) antes de tocar ninguna función.
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

## Referencia: distribución del menú tipo SAP (2026-10-28, solo referencia futura)

Reparto de las 56 pantallas actuales según los módulos de SAP. **No está implementado ni aprobado como rediseño del menú**; sirve para comparar y para decidir. Hoy el menú sigue agrupado por función y herramienta.
- **MM (18):** Requisiciones de compra, Órdenes de compra, Recibo de mercancía, Compra directa, Entradas directas, Stock General, Lotes, Kardex, Auditoría de inventarios, Tareas de almacén, Alta de artículo, Productos, Proveedores, Importar claves de proveedor (XML), Tablas · Unidades de medida / Conversiones / Densidades / Umbral caducidades.
- **SD (5):** Pedidos de venta, Salidas / Ventas, Devoluciones*, Clientes, Listas de precio.
- **PP (3):** Producción, Consulta de órdenes de producción, Importar Excel/CSV*.
- **FI (16):** Gastos, Cuentas por pagar, Pagos a proveedores*, Cuentas por cobrar, Bancos y Tesorería, Activos fijos, Tareas contables, Pólizas, Plan de cuentas, Reportes contables, Cierre de periodo, Tablas · Monedas y las 4 tablas SAT (Uso del CFDI, Forma de pago, Método de pago, Regímenes fiscales)*.
- **CO (5):** Asistente de llenado, Centros de costo, Áreas y bases de prorrateo, Reparto de gastos compartidos, Prorrateo de gastos.
- **HCM (3):** Empleados, Nómina, Tabla ISR*.
- **Administración (6, sin equivalente funcional):** Documentos, Reportes operativos, Bitácora de cambios, Accesos para operadores, Temas de usuario, Plantillas de impresión (más el Índice).
- **QM, PM, PS, CS:** sin pantallas (QM y PM son los huecos con más sentido para una planta de cosméticos/farmacéuticos).
- *Dudosos: Devoluciones (cliente → SD, proveedor → MM), Importar Excel/CSV (PP o MM), Pagos a proveedores (consulta de Compras, dato de FI), Tablas SAT (FI o SD), Tabla ISR (HCM, no contabilidad).
- Con este reparto desaparecen como grupos Catálogos, Utilerías, Configuración y Documentos. Relacionado: estrategia de departamentos/funciones (artifact "Departamentos y funciones del ERP").

## Catálogo de series (aprobado por el usuario 2026-10-13)

Todas de 3 letras. Documentos/órdenes: `SERIE-000001` (consecutivo continuo, `siguiente_folio`). Pólizas: `SERIE-AÑO-00001` (consecutivo por año,
`_siguiente_folio_poliza`). Lo ya emitido NO se renombra (ODC reemplazó OC; **OPR reemplaza OP y OPC reemplaza ODP desde 2026-10-13** — los `OP-…`/`ODP-…` viejos se quedan).

**Pólizas (serie · qué es · tipo SAT):** BAN pago por banco/anticipo · Egreso — VAE pago en efectivo/caja · Egreso — ING cobro a cliente · Ingreso — DIA cancelación
(reverso, mismo tipo que la original) — CMP consumo de MP al cerrar producción · Diario — REC recepción de mercancía (con o sin ODC) · Diario — GAS gasto · Egreso/Diario —
NOM nómina · Egreso — DEP depreciación · Diario — VEN venta · Ingreso/Diario — SMA salida por merma/ajuste · Diario — EDI entrada directa · Diario — DVC devolución de
cliente · Diario — DVP devolución a proveedor · Diario — PRR prorrateo de CIF · Diario — RAN resolución de anticipo (reembolso Ingreso / baja Diario) — MAN póliza manual · **APE apertura de activo fijo (carga inicial) · BAJ baja de activo fijo** (2026-10-22, `sql/2026-10-22f_activos_apertura_baja.sql`; ambas Diario) ·
el que se elija. (DET deterioro de inventario: reservada, pendiente — su origen es `ajuste`, compartido con reclasificaciones; requiere una línea en
`registrar_deterioro_inventario`.) La serie sale de `polizas_series_origen` (tabla editable en el SQL Editor) vía `registrar_poliza()` cuando la función que crea la póliza
no manda `serie`; BAN/VAE/ING/CMP/REC las mandan explícitas y DIA la pone `cancelar_poliza()`. Migración: `sql/2026-10-13_series_polizas.sql` (solo pólizas nuevas; no renumera).

**Documentos y órdenes (serie · qué es · tipo):** REQ requisición · Solicitud — ODC orden de compra · Orden — PRE pre-recibo · Documento de almacén — NDC/NDP nota de
crédito/cargo de compra · Documento — OPR orden de producción · Orden — OPC cierre de producción (entrada y consumo `-MP`) · Documento de almacén — PED pedido de venta · Orden —
VTA/MER/SAL/AJU salida por venta/merma/general/ajuste · Documento de almacén — ENT entrada directa · Documento de almacén — DCL/DPV devolución de cliente/a proveedor ·
Documento de almacén. Sin folio propio: pagos, cobros, nómina, auditoría.

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
- `asistente-prorrateo.js` — "🧭 Asistente de llenado" de Prorrateo de gastos: subventana de 5 pasos (planta → áreas → luz → casos de gasto → revisión) con resumen y confirmación antes de guardar; `abrirAsistenteProrrateo(paso, onCerrar)`.
- `areas-prorrateo.js` — declara m²/personas por área para derivar los % de prorrateo de gastos compartidos; la carga eléctrica (kW) sale de los equipos de Activos fijos (panel de solo consulta).
- `asistente-contable.js` — panel de ayuda colapsable ("¿Cómo llenar esta pantalla?") reutilizado por
  varios módulos + el asistente de captura de Gastos.
- `categorias-depreciacion.js` — categorías fiscales de depreciación (LISR): `cargarCategoriasDep`, `vigentesEn`, `opcionesCategoriaDep`, `vidaMesesDePct`; las usan Activos fijos, Alta de artículo y la requisición.
- `activos-fijos.js` — activos fijos y equipos: TODO equipo se da de alta aquí (área, potencia, Depreciable/No depreciable) + depreciación (NIF C-6, línea recta): catálogo + corrida mensual con póliza. Los equipos que llegan de una compra aparecen "⏳ pendiente de completar" (botón Completar; costo y fecha vienen de la compra).
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
- `vinculos.js` — alta vinculada («Crear y editar…»): abre la pantalla real de un catálogo como subventana y devuelve el registro creado (`abrirAltaVinculada`, `avisarRegistroGuardado`).
- `formato.js` — dinero: `money` (2 dec., redondeo comercial), `money4` (4 dec. para costos/precios unitarios), `importe(cant, costo)`, `redondear`/`redondear2`. Toda cifra monetaria nueva usa esto, no `toFixed`.
- `catalogos-sat.js` — catálogos SAT de unidades y productos/servicios: `montarBuscadorClaveSat` (buscador en servidor, nunca baja el catálogo), `describirClaveSat`, `cargarVisorSat` (Configuración → Tablas).
- `factor-unidad-sat.js` — `factorSugeridoSat`: factor sugerido entre la unidad SAT del proveedor y la unidad del inventario (función pura; vacío si no se puede deducir).
- `buscador-select.js` — convierte un `<select>` largo en un buscador con teclado, sin cambiar su comportamiento (se refresca solo si el código cambia su valor u opciones).
- `pagos-compras.js` — Compras → Pagos a proveedores: CONSULTA (solo lectura) de pagos ya hechos, mes actual por default, proveedor, paginado en servidor, columna "Mercancía" (por recibir/parcial/recibida) y 🖨️ comprobante; sin botón Cancelar (eso es de Finanzas).
- `dialogos.js` — reemplaza `alert()` por un cuadro con el diseño del tema (cola, Enter/Esc, tono por emoji); `confirm()`/`prompt()` no.
- `filtro-columna.js` — encabezado de tabla con orden ⇅ + menú de filtro ▼ por columna (`thColumna`/`wireFiltrosColumna`); lo usa Stock General.
- `estado-vacio.js` — ilustración (hojas con el acento del tema) + mensaje en toda lista vacía, detectado solo (avisos "Sin …"/"No hay …"); sin tocar módulos.
- `buscador-auto.js` — aplica ese buscador solo a los selects de listas largas (proveedor, cliente, cuenta contable, insumo, orden) detectándolos al aparecer en pantalla; la lista está en `POR_ID`/`POR_SELECTOR`. Para sumar uno, agregarlo ahí.
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
- `empleados.js` — catálogo de empleados con foto, departamento (de la tabla `departamentos`), **Gerente** (jefe directo, otro empleado) y PIN móvil; degrada al selector fijo si falta `sql/2026-10-28_departamentos_gerente_foto.sql`.
- `departamentos.js` — Catálogos → Departamentos: departamento superior (jerarquía) y subdepartamento, tipo, centro de costo, responsable (solo lectura: sale del rol del empleado) y el equipo.
- `organigrama.js` — Catálogos → Organigrama: árbol plegable dibujado con el Gerente de cada empleado (quien no tiene gerente es la cabeza).
- `fotos-personal.js` — foto del personal: compresión a 480 px, subida al bucket privado `fotos-personal`, URLs firmadas en lote y avatar con iniciales.
- `firmas.js` — quién solicita y quién autoriza en los documentos: `cargarPersonal`, `datosFirma`, `autorizaEsperado` (autorizador fijado o Gerente del solicitante), `htmlBloqueFirmas` (nombre sobre la línea; rol · puesto · departamento debajo) y `resolverFirmas`. Lo usan la requisición y la ODC; extenderlo a otros documentos es sumar su bloque.
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
  autorización → Orden de compra real. `reqAbrirAltaActivoFijo`: alta rápida de un equipo (tipo `activo_fijo`) desde el buscador de producto, en subventana, sin perder lo capturado.
- `salidas.js` — salidas de inventario (venta/merma/ajuste) con FEFO y póliza de ingreso si es venta.
- `state.js` — estado global simple compartido (insumos/productos/historial de producción cacheados).
- `subventanas-movibles.js` — hace arrastrables TODAS las subventanas (detección automática, sin llamar nada desde
  cada módulo); se importa en `app.js` y en las 3 apps de operador.
- `supabase.js` — cliente y credenciales de Supabase.
- `tablas.js` — Configuración → Tablas: visor de las tablas de apoyo (columnas dinámicas, buscador) + editores propios (regímenes, densidades, **umbrales de caducidad**).
- `regimenes-fiscales.js` — catálogo SAT de regímenes (tabla `c_regimen_fiscal`, respaldo en código): `cargarRegimenes()` y `opcionesRegimen()` para todos los selects.
- `tareas.js` — pantalla "Tareas": pestañas Pendientes (tabla única con contadores, filtros ▼ por columna, menú ⋯ y acciones masivas; inventario bajo mínimo, caducidad próxima, nómina en borrador) e Historial.
- `trazabilidad.js` — antecedentes de proceso: Requisición → Orden de compra → Documento(s) de recepción.
  También `abrirSeguimientoPedido`: seguimiento 🔗 de un pedido de venta (producción/requisición → OC → recepción → surtidos).

## Convenciones

- **Series de folios y pólizas**: toda función/módulo nuevo que emita un folio (`siguiente_folio`) o una póliza (`registrar_poliza`, serie en `polizas_series_origen`) debe agregar o actualizar su renglón en "Catálogo de series" de este archivo y, en el mismo cambio. (Ya no hay pantalla de series en Configuración → Tablas; la referencia es el "Catálogo de series".) Si cambia una serie, anotar el corte y que lo ya emitido no se renombra.

- **INSTRUCCIÓN PRIORITARIA — optimizar las cargas (pedido explícito del usuario 2026-10-12).** Toda pantalla o cambio nuevo debe
  cargar lo mínimo necesario y pintar rápido; y SIEMPRE que, al tocar o revisar código, Claude detecte cargas excesivas o innecesarias
  (catálogos completos que la pantalla ya no usa, consultas en serie que pueden ir en paralelo con `Promise.all`, `select('*')` o
  `.limit(...)` enormes, joins/embeds que no se muestran, recargar todo para cambiar una fila, N+1 consultas dentro de un ciclo), debe
  **avisar y sugerir la corrección** sin esperar a que el usuario note la lentitud — y corregirla si es seguro. Criterios: (1) pintar
  la pantalla de inmediato y cargar en segundo plano lo secundario; (2) consultas independientes en paralelo; (3) pedir solo las
  columnas y filas que se muestran (filtrar/paginar en el servidor); (4) catálogos grandes (productos, cuentas) solo donde se usen,
  y cacheados si se reutilizan; (5) no repetir una consulta que ya se hizo en la misma pantalla. Ejemplo ya corregido: Órdenes de
  compra tardaba en abrir por cargar todo el catálogo de productos y encadenar 5-6 consultas (2026-10-12).
- **Pantalla de listado = clase `lista-completa`** (2026-10-15): para que una pantalla tenga el diseño estándar (marco hasta el borde inferior, encabezado fijo, solo las filas se desplazan, no se encoge vacía) basta agregar la clase `lista-completa` a su `<section class="vista-seccion …">` en `index.html` y cumplir el contrato: título (con Ayuda) → opcional filtros/tarjetas → un solo contenedor con la tabla (`table-fixed`, sin barra horizontal). Los formularios largos de captura van en una subventana con botón "Crear" (ver Requisición de Compra). Reglas en `css/ui-moderno.css` (bloque "LISTAS A PANTALLA COMPLETA").
- **Fechas** (2026-10-16): "hoy" siempre con `hoyISO()` de `js/fechas.js` (hora local), nunca `new Date().toISOString().slice(0,10)` (UTC); fechas sin hora al pantalla con `fechaLocalTxt()`, nunca `new Date(fecha).toLocaleDateString()`. La base corre en `America/Mexico_City` (`sql/2026-10-16_zona_horaria_mexico.sql`).
- **Selects** siempre desde la tabla real de Supabase, nunca hardcodeados.
- **Migraciones SQL**: idempotentes (`if not exists`, `create or replace`), envueltas en `begin;`/`commit;`.
  Nunca se edita una ya corrida — se agrega una nueva. Se pegan a mano en Supabase → SQL Editor.
- **Funciones: siempre `create or replace function` con el cuerpo COMPLETO, nunca parche de texto** (a petición
  explícita del usuario 2026-10-09: "no quiero parches... cambios con trazabilidad más sólida, no adendums que con
  el tiempo pierden sentido o se hacen tan frágiles que les metes más parches"). El truco de `pg_get_functiondef(oid)`
  + `replace()` + `execute` (usado para la serie CMP de `contabilizar_produccion` y la serie REC de
  `contabilizar_compra`, ambos ya corridos — no se deshacen, pero no se repite el patrón) queda descartado para
  cualquier cambio nuevo: cada migración que toque una función debe poder leerse sola y mostrar qué hace la función
  HOY, sin que alguien tenga que reconstruir una cadena de parches anteriores para entenderla.
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
- **Pólizas se muestran como tipo + número** ("Egreso No. 34", el consecutivo por tipo; si tiene serie propia, SOLO el folio: "BAN-2026-00001" — cambio del usuario 2026-10-13), NUNCA con el id interno global
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
- **Versión del CSS (hallazgo 2026-10-08)**: `css/tema-base.css`, `css/ui-moderno.css` y `css/bienvenida.css` se cargan
  en `index.html` con `?v=<version>` igual que los `.js` — SIN esto, el navegador puede quedarse sirviendo el CSS viejo
  indefinidamente aunque el archivo ya esté actualizado en GitHub (causó varias rondas de "no vi el cambio" en la sesión
  del tema Claro Ice, donde el culpable real era caché, no el código). En cada commit que toque algo de `css/`, actualizar
  a mano el `?v=` de esos 3 `<link>` en `index.html` al mismo valor que `version.json`.
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
    barra de título que maximiza (casi pantalla completa) y restaura el tamaño original con el mismo botón ("⤡"). **Desde 2026-10-15 esos controles son un semáforo estilo macOS a la izquierda del título: rojo cierra, amarillo minimiza, verde maximiza/restaura (`agregarSemaforo`, `js/subventanas-movibles.js`).**
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

- **TABLA DE CONTRASTE: lo que hace el ERP vs lo que exigen CFF, RCFF y NIF (pedida por el usuario 2026-10-30 para el día siguiente).** Objetivo: fijar los criterios de las ventanas de usuario y decidir qué conexiones con otras bases de datos hacen falta. Formato acordado: una fila por requisito (norma + párrafo/artículo · qué exige · qué hace el ERP hoy ✅/⚠️/❌ · qué falta). **El deber ser manda, lo haga o no el sistema.** Fuentes ya leídas (citar solo estas con párrafo): NIF C-4 (44.1.1, 44.3.1–44.3.10, 44.7.2.1, 44.7.3.1, 44.7.6.1, 44.7.7.1, 44.8, 46.1, BC8: la norma NO exige centros de costo ni distribución primaria/secundaria; es metodología libre); NIF C-6 (44.2, 44.3, 44.6, 46.2 depreciación, 46.3 deterioro, 48 bajas); RCFF art. 33 (B.I asientos en 5 días, B.IV inversiones con % e importe de deducción anual y fecha de inicio, B.X, B.XII «centro de costos» = sucursal/establecimiento, B.XV inventarios con producto en proceso, existencias mensuales y método de valuación con fecha de inicio), 34 y 35. **Sin fuente todavía:** CFF art. 28/29, LISR (costo de ventas, deducción de inversiones), NIF B-3, C-9, C-15, D-3; no afirmar nada de ellos de memoria. Hallazgos ya identificados para la tabla: (1) producción en proceso no se valúa al corte (NIF C-4 44.7.2.1; RCFF 33-B.XV); (2) depreciación arranca en fecha de recepción, sin «fecha de puesta en servicio» (NIF C-6 46.2.3.1; etapa B2); (3) sin fecha ni importe de deducción FISCAL anual por inversión (RCFF 33-B.IV); (4) sin revisión anual de vida útil/valor residual (46.2.2.2); (5) sin componentes ni prueba de deterioro de activos (46.2.1.1, 46.3.1.1); (6) baja solo sin venta (48.1–48.2); (7) limpieza no se separa como mano de obra indirecta; mano de obra ociosa se queda en 601.01; (8) muestra de laboratorio/merma anormal vs normal; (9) laboratorio por lote cabe en NIF C-4 44.3.9 (confirmar con contador); (10) asientos mensuales (depreciación, prorrateo) frente a la regla de 5 días (RCFF 33-B.I); (11) donación/destrucción de inventario como salida propia; (12) distribución secundaria de centros de servicio: NO exigida por norma, solo si el usuario la quiere; (13) un área con dos centros de costo: no aplica a su caso (mezclado y envasado son áreas excluyentes). Pedir al usuario antes de seguir: texto de LISR/CFF si quiere la parte fiscal, y los datos que faltan del caso (EPP, prestaciones reales, tapado por pieza o por ciclo).

- **DECISIONES DEL USUARIO 2026-10-30 sobre diferencias en activos (sin código aún; falta plan y aprobación):** (1) una diferencia de PRECIO de la factura contra la ODC debe pedir **autorización de Compras** (hoy solo se informa en «Contra la cotización»); (2) un equipo **dañado** al llegar también requiere **autorización de Compras**; (3) un activo SÍ podrá recibirse con factura XML **sin ODC**, pero el sistema debe **hacer el esfuerzo de obligar a pedir ODC y cotización** (excepción documentada con motivo y autorización, marcada «sin ODC ni cotización» y con Tarea para regularizar). Hoy un equipo se rechaza por XML suelto (`js/ordenes-compra.js` ~L2974), Compra directa (`js/compras.js` L687) y Entrada directa (`js/entradas.js` L525/553). La autorización se ejecuta con listas filtradas por departamento/función (catálogo de funciones aún sin construir; sin límite de monto, responde quien autoriza).
- **COORDINACIÓN DEL CICLO DE UN ACTIVO FIJO Y DE SUS DIFERENCIAS (pedido del usuario 2026-10-30; solo análisis, sin código).** Requisición → ODC → anticipo/pago → pre-recibo → recepción (póliza REC + alta del activo «pendiente de completar») → Completar (puesta en servicio) → depreciación → prorrateo → baja/merma, con las diferencias ODC/requisición vs factura y cómo las registra la contabilidad (NIF C-6 44.2.1.1, 44.6.2, 44.6.7, 44.6.8, 46.2.3.1, 46.3.2, 48). **Bloqueos verificados en el código:** (a) un equipo se recibe de uno en uno por partida (`_alta_activos_desde_recepcion` rechaza cantidad ≠ 1; requisición y ODC manual topan en 1); (b) un equipo NO entra por XML/CFDI suelto ni por Compra/Entrada directa (solo requisición → ODC); (c) la recepción exige pre-recibo validado de esa ODC (`_candado_recibo_requiere_prerecibo`; NO verificado que `recibo-operador.js` maneje partidas de equipo); (d) una recepción con equipo no se edita: se cancela y se recaptura; (e) cancelarla se bloquea si ya hubo depreciación, y la depreciación no se cancela si ya se prorrateó, y un anticipo aplicado no se cancela hasta cancelar la recepción (cadena: prorrateo → depreciación → recepción → anticipo); (f) lo recibido vs el subtotal de la factura exige NDC/NDP; la diferencia de PRECIO contra ODC/requisición solo se informa («Contra la cotización») y no pide autorización ni queda registrada; (g) el anticipo acumulado no puede pasar de ×1.30 del total estimado de la ODC; (h) equipo sin Completar no se deprecia y Cierre de periodo no lo avisa ni existe Tarea «equipo por completar». **Huecos:** devolución/rechazo de un equipo al proveedor, equipo dañado al llegar, compensación de seguro (46.3.2.1), lote de equipos con precio global (44.6.7), baja con venta o por daño total, alta manual duplicada vs alta por compra. Propuesta a presentar: «expediente del activo» con estados y una Tarea por cada traspaso, y un panel único de «Diferencias» (tipo, monto, quién autoriza, resolución y asiento).
- **RR. HH. + responsables en documentos (2026-10-28): código hecho, falta correr los SQL y probar.** Ver "Última sesión". Orden: `sql/2026-10-28_departamentos_gerente_foto.sql` → `sql/2026-10-28b_firmas_requisicion.sql`. Después: dar de alta departamentos con responsable, asignar Gerente a cada empleado y revisar el Organigrama. Siguientes pasos acordados en la estrategia (sin código): límites de autorización por monto (el jefe inmediato no sube toda la cadena por compras chicas), aprobación del jefe de área ANTES de que Compras vea la requisición, extender las firmas a los demás documentos (pedidos de venta, pagos, nómina), decidir el tipo de Almacén (centro de servicio) y ligar `departamentos.centro_costo_id` al prorrateo (departamento → centro de costo → reparto). Fresh start: `departamentos` y el bucket `fotos-personal` deben preservarse (hoy `js/fresh-start.js` no los lista).
- **Alta vinculada («Crear y editar…») — pendiente (2026-10-22):** cuentas contables y empleados quedan para después (el usuario: «déjalos pendiente aún»; no tienen pantalla de alta que se pueda abrir así). Ya hecho en la rama `claude/vibrant-maxwell-atb5ib`, SIN subir a `main` y sin probar en la app real: producto (requisición, ODC manual, Pedidos de venta, Entradas directas, Compra directa), proveedor y cliente (selects). Para que el usuario lo vea: decir «comitea» → Ctrl+Shift+R y probar. Entradas/Compra directa ya no crean productos por nombre (aviso «Crear y editar»).
- **Decisiones del usuario 2026-10-22 (tarde):** `sql/2026-10-22f_activos_apertura_baja.sql` YA corrido. **CORRECCIÓN del usuario (mismo día): SÍ se pueden comprar EQUIPOS usados** (lo que no se compran son productos usados; había un malentendido). El flujo ya lo cubre sin cambios: el equipo usado entra por requisición → ODC → recepción a su costo de compra y se marca «Equipo usado» al Completarlo (vida restante, residual y % fiscal editables). Marcarlo desde la requisición/Productos (columna en `productos` + reescribir `_alta_activos_desde_recepcion`) queda como mejora opcional, sin pedir. **Quiere depreciación mensual AUTOMÁTICA** (pg_cron, sin botón; pendiente de plan y aprobación) y **la baja será por venta o por daño total** (hoy solo existe baja sin venta con póliza BAJ; falta baja con venta: IVA trasladado, cobro/CxC, utilidad o pérdida; y motivo «daño total»). Siguen pendientes: probar en la app real (Alta de artículo Activo fijo, Completar), compra de prueba completa de un equipo, desactivar las 5 categorías raras, validar % fiscal con el contador.
- **Decidido 2026-10-22 (ya no son pendientes):** (1) la fecha de adquisición de un activo que nace de una compra es la de la **recepción** (`documentos.fecha_emision`); no se agrega "Fecha de la factura". (2) Equipos viejos que ya no se deprecian pero se quieren en el listado: se dan de alta como "No depreciable" con su fecha original y un **costo histórico opcional** (solo informativo, sin póliza; el saldo en 152/153 debe estar ya en la contabilidad o en una póliza de apertura aparte). Hecho en `js/activos-fijos.js` (sin SQL).
- **PENDIENTE (2026-10-22):** el SQL `sql/2026-10-21_activo_fijo_en_compras.sql` YA se corrió en Supabase (2026-10-22); falta hacer la compra de prueba completa de un equipo (requisición → ODC → recepción → pago → Completar → depreciar → prorratear). Sin probar renderizado: Recibo de mercancía y Activos fijos (solo sintaxis + Chromium con base simulada) ni nada contra la base real. Pasar a `main` lo de la rama `claude/vibrant-maxwell-atb5ib` cuando el usuario lo pida. Confirmado: flete, maniobras, seguro de transporte y honorarios aduanales SÍ se capitalizan al costo del activo (NIF C-6, LISR art. 31); la casilla "capitaliza" de la recepción ya viene marcada.
- **ACTIVO FIJO EN COMPRAS — implementado 2026-10-21; SQL ya corrido (2026-10-22), falta probar con una compra real.** Ver "Última sesión". Pasos del usuario: Productos: verificar que aparece el tipo "Activo fijo" → compra de prueba de un equipo (Requisición: escribir un equipo nuevo → "➕ Crear como activo fijo" → ODC → Recibir mercancía → pagar → Finanzas → Activos fijos → "Completar" → Calcular depreciación → Prorrateo). Decidido: la fecha de adquisición del activo es la de la recepción (no la de la factura); un equipo no se puede recibir por XML/CFDI suelto ni por Compra/Entrada directa (solo requisición → ODC).
- **PEDIDOS DE VENTA — aplicar el "patrón Requisición de Compra" cuando el usuario lo pida (no antes; él dijo "espérame", 2026-10-15).** Receta (así se hizo en `js/requisiciones-compra.js` + `index.html`, commits 912c4d1…51368c4):
  (1) encabezado en `index.html`: `<h2>` en SINGULAR ("Pedido de Venta") + botón verde "Crear" separado (`bg-emerald-500 … px-6 py-2 -my-1 rounded-lg text-sm`, `onclick="window.pvAbrirNuevo && window.pvAbrirNuevo()"`), sin el botón "Cómo llenar esta pantalla"
  (la píldora "Ayuda" ya trae el Manual — Pedidos de venta ya lo tiene quitado); (2) el formulario "Nuevo pedido de venta" (hoy siempre visible arriba de la lista, `js/pedidos-venta.js` ~L91-126, con "Guardar pedido de venta" `#pvGuardar`) se envuelve en
  `#pvNuevoWrap` = `hidden fixed inset-0 bg-slate-950/40 z-50 justify-center items-start overflow-y-auto p-3` con panel `w-full max-w-5xl my-2 bg-slate-950 border … rounded-xl p-4 shadow-2xl`, barra de título con ✕, los IDs de los campos NO
  cambian (para no tocar la lógica de guardado/reservas); se MONTA en `document.body` al cargar el módulo (quitando antes el anterior) para que no lo recorte el contenedor; botón de guardar → "Crear"; abre (`classList.remove('hidden'); add('flex')`) con "Crear"
  y solo si llega con datos precargados; al guardar sin "siguiente paso" se cierra y muestra toast (`reqToast`); (3) quitar el subtítulo "Pedidos de venta" sobre la tabla y el `space-y-5` del contenedor; (4) tabla: `table-fixed` + `<colgroup>` con anchos que sumen 100 %,
  encabezados en formato título (sin `uppercase`, `th` con `p-3`), chips de estatus en singular con Mayúscula inicial (helper tipo `reqEstLabel`), acciones por fila en un menú "⋯" si ocupan mucho; (5) agregar la clase `lista-completa` a `<section id="view-pedidos-venta">`;
  (6) NO tocar validaciones de stock/reservas ni el detalle `pvAbrirDetalle`; (7) subir `?v=` del CSS solo si se toca CSS. Reglas generales en la convención "Pantalla de listado = clase `lista-completa`" (Convenciones).
- **Alta de equipos / Activos fijos — IMPLEMENTADA (2026-10-15), falta correr el SQL y dar de alta los equipos.** Ver "Última sesión". Pasos del usuario: respaldo → correr `sql/2026-10-15_equipos_unificados.sql` (borra las cargas viejas) → Prorrateo de gastos → "Asistente de llenado" → paso 3 · Luz y dar de alta los equipos reales de cada área (incluida la Oficina). Queda abierto: si iluminación/clima de oficina deben ser obligatorios (hoy solo avisa).
- **PARA MAÑANA (2026-10-15) — pendientes anotados el 2026-10-14 (el usuario los revisa al iniciar):**
  1. **REDISEÑAR Requisiciones de compra** (captura del usuario con anotaciones): (a) la captura de la requisición ("Nueva requisición de compra": fecha, notas, producto/cantidad/unidad/proveedor sugerido, partidas, "Guardar requisición") la hace un **solicitante distinto de Compras** — moverla fuera de la pantalla de Compras (¿pantalla/menú propio del solicitante, con su Tarea?); (b) Compras queda con la lista de requisiciones para revisar/autorizar y con **órdenes de compra directas** cuando ella misma necesite algo (la ODC formal manual `window.reqAutorizar(null)` ya existe); (c) revisar **botones de "nuevo", validaciones y cancelaciones** de ese flujo (qué puede cancelar quién, qué se valida al guardar). Sin código todavía: falta plan y aprobación.
  2. **Validación del % de anticipo en la ODC formal** (captura: el campo "% ANTICIPO" aceptó **600**): debe limitar a 0–100 (pantalla en `js/requisiciones-compra.js`/`reqAutorizar`; y en `odc_generar` en la base, que hoy calcula el monto con ese %). Revisar también que el monto de anticipo no exceda el total estimado.
  3. (Quitado a petición del usuario 2026-10-21: cuadre de inventario 115.01 — ya no le interesa; la herramienta "🔎 Ver qué documentos explican la diferencia" sigue disponible.)
  4. **Probar en la app real (Ctrl+Shift+R):** encabezado/título fijo/píldora "Ayuda" en varias pantallas; Cuentas por pagar con solo filas desplazables y menús de filtro sin cortarse; **Lotes** compacto; modal "Pagar anticipo" (scroll + botón visible) con ODC-000009; filtro Desde/Hasta con año tecleado.
  5. **Decisión abierta:** si el esquema "solo las filas se desplazan" (título/filtros/encabezados fijos) se extiende a otras tablas largas (hoy solo Cuentas por pagar y Lotes).
  6. Los demás pendientes de abajo siguen vigentes (probar prorrateo con una máquina de prueba, `sql/2026-10-12_odc_generar.sql` ya corrido o no según el usuario, Fresh start sin autorizar, etc.).
- **PARA MAÑANA (2026-10-13) — ODC en una sola operación: correr, subir y probar.** Código ya hecho en la carpeta local, NO subido a GitHub.
  (1) Correr `sql/2026-10-12_odc_generar.sql` en Supabase → SQL Editor (crea `odc_generar` y reescribe `pagar_anticipo_oc` restituyendo el candado
  ×1.30 que `…07d` había perdido). (2) Decir "comitea" para subir `js/requisiciones-compra.js`, `js/ordenes-compra.js`, el SQL, `version.json` y
  `CLAUDE.md`. (3) Probar: una ODC manual ("Crear") y una desde requisición (Autorizar) — deben quedar con cotización, condiciones y precios; y un
  anticipo desde Cuentas por pagar (ODC-000007) para confirmar el candado y que la póliza ya no diga "OC ODC-…". No subir antes de correr el SQL.
- **FRESH START (más adelante, el usuario aún NO lo autoriza — no ejecutar ni proponer fecha sin que él lo pida).** Decisión 2026-10-12:
  todo lo capturado hasta hoy es fase de pruebas del ERP, así que NO se parchan documentos sueltos (cada cancelación con contra-asiento
  deja otra póliza para siempre); se limpian todos juntos al hacer el Fresh start. Se resuelven ahí, sin trabajo previo, estos hallazgos
  del diagnóstico `sql/2026-10-12_diagnostico_unico.sql` (ya corrido, todas las pólizas cuadran aritméticamente; el "no cuadra" es contra
  la realidad, todo del 2026-10-06): **AJU-000001** (Diario #33, $27,553.24: ajuste de saldos que dejó en cero Miel de Abeja 103,
  Granel Miel Bee Power 10, Fructosa 7.1 y Damiana 0.9 contra 601.99 Otros gastos generales — gasto probablemente falso en octubre);
  **Egreso #67** ($16,946, pago de F-2407 desde Cuentas por pagar, referencia de relleno `X00000000X`; sin doble pago: #38 se canceló
  con #41 y se reclasificó en Diario #8); **Egreso #69** ($1,866.99, recepción de ODC-000001 capturada "Contado" contra 102.02 Bancos
  extranjeros USD, cuenta sin saldo real; su recepción no se puede cancelar porque lo recibido ya se consumió en producción).
  Al llegar el momento: (1) respaldo de Supabase (Database → Backups) justo antes; (2) revisar y actualizar el SQL de Configuración →
  Fresh start (`js/fresh-start.js`, solo muestra el SQL, nunca borra): faltan tablas de las últimas semanas — anticipos
  (`anticipo_oc_resoluciones`, aplicaciones tipo anticipo), `notas_compra`, `contadores_folios_poliza`, reservas de pedidos, columnas de
  la ODC formal, `pagos_proveedor.visto_bueno_*`; (3) conservar catálogos (productos, proveedores, clientes, empleados, plan de cuentas,
  BOM, regímenes, plantillas); (4) recargar inventario inicial real con Entrada directa "Inventario Inicial" contra 304.01. Esto reemplaza
  al pendiente anterior "Diagnóstico de 3 documentos que no cuadran" (ya diagnosticado; no hay que cerrarlos uno por uno).
- **[HECHO 2026-10-12 en código local, falta subir/probar: las ODC por pagar ya son renglones de "Documentos por pagar" (chip "Por anticipar", mismo botón "Pagar" azul; sin checkbox, un anticipo a la vez) y se quitó el panel aparte; la ventana de anticipo sigue siendo la compacta, unificar la ventana grande queda opcional.]** Unificar el criterio del botón "Pagar" en Finanzas → Cuentas por pagar (pedido del usuario 2026-10-09, para la próxima sesión). Hoy
  hay dos "Pagar" distintos: el azul de cada fila de "Documentos por pagar" (deuda ya recibida → `cxpAbrirPago`, pago a 201.01) y el verde
  de "Órdenes de compra por pagar" (ODC sin recibir → `cxpAbrirAnticipo`, anticipo a 109.01). Distinto color, distinta ventana y distinto
  texto de ayuda, sin criterio común para el usuario. Decidir con él: un solo estilo/botón y una sola ventana de pago que decida sola
  (anticipo vs. deuda, como ya se había acordado en la maqueta de Cuentas por pagar v2), o al menos mismo color/rótulo y una lista única.
  Nota: el panel "Órdenes de compra por pagar" se movió ARRIBA de "Documentos por pagar" en el código local (`js/pagos-proveedor.js`,
  `cxp-pagar-oc`) y NO está subido a GitHub todavía; la captura del usuario aún lo mostraba debajo.
- **[HECHO 2026-10-09: el texto/enlace se reemplazó por el panel "Órdenes de compra por pagar" — lista lo pactado por Compras en la ODC (anticipo pactado, o total si es contado sin anticipo, menos lo ya pagado) con botón Pagar → modal de anticipo precargado; `cxpAbrirAnticipo(ocPre, montoPre)`. Falta subir y probar.]** Quitar el texto de ayuda debajo de las tarjetas KPI en Finanzas → Cuentas por pagar (`js/pagos-proveedor.js`, ~línea 117),
  incluido el enlace azul "💰 pagar anticipo a una OC sin recibir" (`cxpBtnAnticipo` → `cxpAbrirAnticipo`). A petición del usuario
  (2026-10-09): el pago de anticipo se reubicará (probablemente con la ODC formal, ver maqueta "Orden de Compra formal") — NO borrar
  `cxpAbrirAnticipo` hasta decidir dónde vive. Pendiente de aprobación aparte: reemplazar la ODC actual (`js/ordenes-compra.js`
  `abrirDetalleOC`/`renderVistaOC`/`renderEdicionOC` + mini-modal `reqAutorizar`) por el documento formal de la maqueta
  https://claude.ai/artifact/UHUmppsCjW93kPZ87LwQ5d (sin los 3 botones Antecedentes/Imprimir/Editar del encabezado).
- **Cuentas por pagar v2 + series de pólizas + visto bueno — EJECUTADO 2026-10-07, falta correr el SQL y probar.** Pendiente:
  correr en orden `sql/2026-10-07b_cxp_v2.sql` (si no se corrió ya), `sql/2026-10-07d_polizas_series_y_visto_bueno.sql`; probar
  en el navegador — Pagos a proveedores (KPIs, Vence, pop-up de varias OC, selector de Visto bueno), Órdenes de compra (Días de
  crédito obligatorio, Solicitado por), y confirmar que una póliza de pago sale como "BAN-2027-00001 · Egreso #N" (o VAE si la
  cuenta es caja). Correr `sql/2026-10-07c_diagnostico_migraciones_pendientes3.sql` (solo lectura) para confirmar qué más falta
  de rondas anteriores (series ODC/DCL/DPV, acuerdo de pago parcial, tipo de cambio en la OC, reservas de pedidos...).
  Sin hacer a propósito: el tratamiento contable del IVA no acreditable en efectivo > $2,000 (solo queda el aviso visual,
  falta que el contador confirme la cuenta); que el Visto bueno aparezca en el menú de Tareas del empleado (hoy se marca a
  mano desde un select en Pagos a proveedores).
- Semiterminado como tipo: TERMINADO (verificado 2026-09-23): migración 1, código en `main`, `…24b` (columna `es_semiterminado`
  borrada) y `…23f` (graneles de aceite en 14.64 L, 115.02) corridos. Ids 232 y 254 (Aceite Sey Piña Colada/Chocolate)
  corregidos a semiterminado (verificado). **[DATO DEL USUARIO — no ofrecer; él lo sabe]** Pendiente: Granel Love Oil Fresa Kiwi (id 227) quedó en 7.99 L: su fórmula tiene solo 3 componentes, completarla. Al crear graneles
  nuevos, volver a correr revisión `…23e` + aplicar `…23f` (o usar "🧪 Revisión del granel").
- Verificado 2026-09-23 en la base: corridas todas las migraciones de 2026-09-22 y 2026-09-23 (`…23d` no, es opcional).
  Documentos vacíos de los cierres fallidos (ids 22-25, PROD-000001/-MP y PROD-000002/-MP) marcados `cancelado` (no
  borrados, para dejar rastro y que no bloqueen el candado de cierre de septiembre).
- Graneles en Kilogramos: el usuario confirmó que sus terminados los consumen en GRAMOS → no hace falta la densidad del
  granel (solo la de los insumos que la receta pida en L/mL). Si algún terminado pidiera un granel en mL, capturar la
  densidad del granel (ya se calcula sola de la fórmula; botón "Usar X kg/L como Densidad").
- **[DATO DEL USUARIO — no ofrecer ni listar como pendiente de Claude; él lo sabe y lo hará cuando quiera]** Los demás graneles de Gel/Miel/Lubricante (Anal Xtasi, Bubblegum, Cherry, Chocolate, Essence, Mango, Mint, Prolongel
  Retardador, Vcream, Watermelon, Miel Bee Power, Lubricante Silicón) no salieron en la revisión: o no tienen BOM o su
  nombre no dice "granel". Cuando tengan receta, se configuran con la revisión ✅/⚠ o con los SQL `…e`/`…f`.
- [HECHO 2026-10-12] Buscador de selects extendido a proveedores, clientes, cuentas contables, insumos de BOM y órdenes en toda la app (`js/buscador-auto.js`).
- Subventanas: ya movibles y con fondo semitransparente todas las detectadas; una nueva queda cubierta sola si usa
  `fixed inset-0` (fondo + panel) o `fixed rounded-2xl` (flotante) y su barra de título es el primer hijo del panel.
- **Compras y pagos — EJECUTADO 2026-10-07, falta correr el SQL:** puntos 1, 2 y 5 del plan quedaron en código (ver "Última
  sesión" arriba) — con una corrección: el punto 1 no quitó ningún menú (Recibo de mercancía y Pre-recibos ya eran la misma
  pantalla), solo el bloque de pago. El punto 3 (NDC/NDP) se implementó distinto a lo planeado: no son documentos aparte con su
  propia póliza — se capturan en el momento de validar la recepción y ajustan el 201.01 en la MISMA póliza (a petición del
  usuario, que aclaró que así es como se van a usar). El punto 4 (rechazo con merma dañada que se da de baja a gasto) NO se
  hizo — el usuario decidió que no hace falta: la diferencia se resuelve con NDC/NDP en la validación, no con una merma aparte.
  Queda pendiente, más chico: motivo de rechazo por partida (por qué no se recibió completa una línea) — informativo, no toca
  dinero. Correr `sql/2026-10-07_compras_notas_ajuste.sql` en Supabase antes de usar la recepción.
  Pendiente de decisión con el contador: si el IVA de la nota de ajuste debe prorratearse (hoy se ajusta solo el neto).
  Diagnóstico de los 3 documentos que no cuadran (AJU-000001 $27,553.24, Egreso #67 $16,946 F-2407, Egreso #69 pago OC-000001 en
  102.02 USD): SQL de solo lectura listo en `sql/2026-10-07_diagnostico_aju_egresos.sql` — correrlo y revisar antes de decidir
  cómo cerrar cada uno (no hay función para deshacer una salida de ajuste de inventario; hay que saber primero si ese inventario
  ya se consumió en producción).
