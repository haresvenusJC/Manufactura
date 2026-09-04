# Importador Excel / CSV

Módulo: **Catálogos → ⬆️ Importar Excel/CSV** (`js/importador.js`).

Sube un archivo `.xlsx` / `.xls` / `.csv` con productos o materias primas y los
carga a `productos` (creando `proveedores` que no existan). El precio va a
`productos.costo_unitario` (+ `moneda_id`).

## Plantilla

En `ejemplos/`:

- `plantilla_materias_primas.xlsx` / `.csv` — plantilla vacía con encabezados y
  filas de ejemplo. También se descarga desde la propia pantalla (paso 1).
- `materias_primas_LOVLUB.csv` — las materias primas de la hoja `COSTOS COMPRA`
  ya volcadas (precio en MXN por Kg/Lt, proveedores unificados). **Revisar
  columna `Unidad` y las filas con `Precio` vacío antes de importar.**
- `LEEME_plantilla.md` — qué va en cada columna.

Encabezados (fila 1): `Nombre` (obligatorio) · `SKU` · `Proveedor` · `Precio` ·
`Moneda` · `Unidad` · `Notas`. Con esos nombres el importador mapea todo solo.

## Flujo

1. **Archivo** — sube el Excel/CSV.
2. **Hoja y mapeo** — detecta la fila de encabezados (ajustable) y sugiere qué
   columna es cada campo. Aparece un **pre-resumen**: nº de filas, cuántas se
   crearían / actualizarían, proveedores nuevos, filas sin precio, posibles
   duplicados y avisos de mapeo.
3. Elige tipo / moneda / unidad por defecto y pulsa **Validar**.
4. **Vista previa fila por fila** — casilla por renglón (los que tienen error
   quedan bloqueados), botones *Todos / Ninguno / Solo nuevos / Solo a
   actualizar / Marcar filtrados*, filtro por nombre/SKU, y columna **Tipo**
   por fila para los que se van a crear. El botón dice **Importar (N)**.
5. **Importar**. Al terminar, el plan se limpia: para otra pasada hay que volver
   a **Validar** (así se ven ya los productos recién creados).

## Reglas

- **Ya existe** (por SKU, o por Nombre si no hay SKU) → se **actualiza** precio,
  moneda, unidad, proveedor y notas. No se cambia su `tipo`.
- **No existe** → se **crea** con el tipo elegido (ajustable fila por fila).
- **Proveedor** no existente → se crea en `proveedores` (casilla marcable).
- **Moneda / Unidad** se resuelven contra `monedas` / `unidades_medida`; si no
  hay match se usa el valor por defecto del formulario.
- **Precio** acepta `$1,234.56`, `1234,56`, etc. Si no es numérico, la fila
  entra sin precio y se avisa.

## Filas que "requieren revisión"

Cuando el archivo trae **Moneda**, **Unidad** o **Tipo** y el texto no
matchea ningún catálogo, la fila ya **no** se cae en automático a un valor
por defecto: se marca con ⚠ y arranca **desmarcada** en la vista previa
(contador "requiere revisión"). Así un dato de catálogo mal escrito no se
cuela con el valor equivocado — el usuario decide fila por fila si corrige
el archivo o acepta el valor por defecto marcando la casilla a mano.

## Notas técnicas

- Sin backend. Librerías por CDN: `@supabase/supabase-js` y `xlsx` (SheetJS,
  `cdn.sheetjs.com`).
- Requiere sesión de administrador (las políticas RLS de `productos` /
  `proveedores` permiten escribir al rol `authenticated`).

---

# Importador de BOM (Estructura de Componentes)

Módulo: **Catálogos → Importar Excel/CSV → pestaña "Estructura de
Componentes (BOM)"** (`js/importador-bom.js`).

Sube un archivo `.xlsx` / `.xls` / `.csv` con una fila por cada componente
de una receta y las relaciona en la tabla `bom`. **No crea productos
nuevos** — el producto padre y cada componente deben existir ya en
`productos` (se buscan por SKU o por nombre).

## Plantilla

En `ejemplos/`:

- `plantilla_bom.csv` — 2 filas de ejemplo que arman la receta del producto
  `PT-GEL-60` de `plantilla_materias_primas.csv` (útil para ver el flujo
  completo: importar productos primero, BOM después).
- `LEEME_plantilla_bom.md` — qué va en cada columna.

Encabezados: `Producto padre (SKU o nombre)` · `Componente (SKU o nombre)` ·
`Cantidad` (las tres obligatorias) · `Unidad` (opcional). El archivo trae
notas explicativas arriba (líneas `#`); el importador detecta la fila de
encabezados sola sin importar cuántas notas haya encima.

## Flujo

Igual que el importador de Productos: **Archivo → Hoja y mapeo → Validar
(pre-resumen) → vista previa fila por fila → Importar**.

## Reglas

- **Producto padre**: debe existir y ser de tipo "Producto terminado"; si no
  existe o es de otro tipo, la fila queda en error.
- **Componente**: debe existir (materia prima, insumo u otro producto como
  subensamble); si no existe, la fila queda en error.
- Un producto no puede ser componente de sí mismo.
- Si el par (producto, componente) **ya existe** en `bom` → se
  **actualiza** cantidad/unidad. Si no existe → se **crea**.
- **Unidad** sin match en `unidades_medida` → la fila requiere revisión
  (ver sección de arriba) y no se incluye sola.
- Casilla **"Reemplazar la receta completa"**: borra de una vez todos los
  componentes que ya tenía cada producto tocado por el archivo antes de
  insertar los del archivo. Sin marcar (por defecto), solo agrega/actualiza
  los componentes del archivo sin tocar el resto de la receta existente.
