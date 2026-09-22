# Hares de México — guía para trabajar en este repo

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

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
- Producción: botón "Generar requisición de lo faltante" — abre requisición de compra (agrupada por
  proveedor) y/o órdenes de producción para lo que se fabrica en casa (semiterminados como el granel).
- Buscador reutilizable para `<select>` largos: `js/buscador-select.js` (en uso en Producción).
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
  `sql/2026-10-26_prerecibo_documento_id.sql`.

## Pendiente

- Correr `sql/2026-10-23_densidad_conversion_bom.sql`, `sql/2026-10-25_unidades_medida_editable.sql` y
  `sql/2026-10-26_prerecibo_documento_id.sql`.
- En Catálogo → "⚖️ Densidades", capturar la de los saborizantes y cualquier otro insumo que la necesite
  (se ve fácil ahí: unidad en peso pero sin densidad).
- Evaluar si extender el buscador de selects a otras pantallas (Salidas, Órdenes de compra, alta de BOM).
- Pendiente de responder: ¿aplicar también el default Desde=inicio de mes/Hasta=hoy a Cuentas por
  cobrar/pagar, historial de Recibo de mercancía e Historial de tareas? (se dejaron igual, ver arriba).
