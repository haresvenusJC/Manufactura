# Plantilla de importación — Estructura de Componentes (BOM)

Archivo: **`plantilla_bom.csv`** — una fila por cada componente de una receta.

El importador de la app (**Catálogos → Importar Excel/CSV → pestaña
"Estructura de Componentes (BOM)"**) lee este archivo (o un `.xlsx`/`.xls`
con las mismas columnas).

## Cómo armar tu archivo

1. **Primero** da de alta (o importa con la otra pestaña) los productos y
   materias primas/insumos que va a usar la receta — este importador **no
   crea productos nuevos**, solo relaciona los que ya existen.
2. Una fila por cada componente. Si un producto lleva 5 insumos, son 5 filas
   con el mismo "Producto padre" y distinto "Componente".
3. El archivo trae unas notas arriba (líneas que empiezan con `#`) — bórralas
   junto con las filas de ejemplo antes de capturar tus datos reales. **No
   cambies ni muevas la fila de encabezados** (la que dice "Producto padre
   (SKU o nombre), Componente (SKU o nombre), Cantidad, Unidad"); el
   importador la detecta sola aunque tenga notas arriba.
4. Guarda como `.xlsx` o `.csv` y súbelo en el módulo.

## Columnas

| Columna | ¿Obligatoria? | Qué poner |
|---|---|---|
| **Producto padre (SKU o nombre)** | **Sí** | SKU o nombre del producto terminado al que le vas a cargar la receta. Debe existir ya en el Catálogo y ser de tipo "Producto terminado". |
| **Componente (SKU o nombre)** | **Sí** | SKU o nombre del insumo, materia prima o subensamble que entra en la receta. Debe existir ya en el Catálogo (de cualquier tipo). |
| **Cantidad** | **Sí** | Cuánto se consume del componente por cada unidad del producto padre. Número mayor a 0. |
| **Unidad** | No | Unidad en la que viene esa cantidad (Piezas, Kilogramos, Litros…). Si no coincide con ninguna del catálogo de unidades, la fila se marca para revisión y **no se incluye sola**. |

## El ejemplo del archivo

Las 2 filas de datos de `plantilla_bom.csv` arman la receta del "Gel
lubricante 60 ml" (`PT-GEL-60`) usando el envase y la tapa de
`plantilla_materias_primas.csv` — súbelas en ese orden (productos primero,
BOM después) para ver el flujo completo de punta a punta antes de cargar tu
información real.

## Reglas de importación

- **Producto padre o componente no encontrados** (por SKU o nombre) → la fila
  queda en error y no se importa; este importador nunca crea productos.
- **Producto padre que ya tiene ese mismo componente en su receta** → se
  **actualiza** la cantidad/unidad de esa relación.
- **Producto padre + componente nuevos para esa receta** → se **crea** la
  relación en `bom`.
- Un producto no puede ser componente de sí mismo — esas filas quedan en
  error.
- Casilla **"Reemplazar la receta completa"**: si la marcas, antes de cargar
  se borran todos los componentes que ya tenía cada producto tocado por el
  archivo, y se deja solo lo que traiga el archivo. Si la dejas sin marcar
  (por defecto), solo se agregan o actualizan los componentes del archivo —
  el resto de la receta existente no se toca.
- En la vista previa marcas qué filas entran. **Nada se guarda hasta pulsar
  "Importar".**
