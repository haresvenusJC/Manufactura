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

## Notas técnicas

- Sin backend. Librerías por CDN: `@supabase/supabase-js` y `xlsx` (SheetJS,
  `cdn.sheetjs.com`).
- Requiere sesión de administrador (las políticas RLS de `productos` /
  `proveedores` permiten escribir al rol `authenticated`).
