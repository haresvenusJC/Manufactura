# Plantilla de importación — Materias primas / insumos

Archivos:

- **`plantilla_materias_primas.xlsx`** — hoja `PLANTILLA` con encabezados y filas de ejemplo.
- **`plantilla_materias_primas.csv`** — lo mismo en texto plano (se edita fácil, se abre en Excel).

El importador de la app (**Catálogos → ⬆️ Importar Excel/CSV**) lee cualquiera de los dos.

## Cómo armar tu archivo

1. Abre la plantilla. El `.csv` trae unas notas arriba (líneas que empiezan
   con `#`) explicando el archivo — bórralas junto con las **filas de
   ejemplo** antes de capturar las tuyas.
2. **No cambies ni muevas la fila de encabezados** (la que dice
   "Nombre, SKU, Tipo…"). El importador la detecta sola aunque tenga notas
   arriba — no importa en qué fila del archivo quede.
3. Guarda como `.xlsx` o `.csv` y súbelo en el módulo.

## Columnas

Ninguna columna tiene que llamarse exactamente así: el importador detecta el encabezado por aproximación y además puedes reasignar cada columna a mano en el mapeo.

### Básico

| Columna | ¿Obligatoria? | Qué poner |
|---|---|---|
| **Nombre** | **Sí** | Nombre del artículo. Clave para saber si ya existe (cuando no hay SKU). |
| **SKU** | No (recomendado) | Código interno único. Si lo pones, se empareja por SKU. Ej. `MP-CMC`. |
| **Tipo** | No | `materia prima` · `insumo` · `producto` (también `MP`, `componente`, `PT`…). Si lo pones, manda sobre el tipo por defecto — para crear **y** para actualizar. |
| **Proveedor** | No | Nombre del proveedor. Si no existe, se crea. |
| **Precio** | No | Costo unitario (de compra). Va a `costo_unitario`. Acepta `1234.56` o `$ 1,234.56`. |
| **Precio de venta** | No | Precio de lista de venta **sin IVA**. Va a `productos.precio_venta`. Se usa para calcular el ingreso al registrar una venta. |
| **Moneda** | No | `MXN` / `USD`. Vacío = la de por defecto. |
| **Unidad** | No | Litros, Kilogramos, Piezas… Si no coincide, se usa la de por defecto. |
| **Notas** | No | Texto libre (descripción). |

### Contable *(necesitas el módulo de contabilidad instalado)*

| Columna | Qué poner |
|---|---|
| **Tasa IVA** | `16%`, `16`, `0.16`, `0%` o `exento` (exento se guarda como vacío). |
| **Tasa IEPS** | Igual formato; normalmente `0`. |
| **Cuenta inventario** | Código (ej. `115-01`) o nombre de la cuenta contable donde se registra el inventario de ese artículo. Debe existir ya en el plan de cuentas — si no matchea nada, la fila se marca para revisión y no se incluye sola (no hay "cuenta por defecto" a la que caer). |
| **Cuenta costo** | Igual que la anterior, pero la cuenta de costo/gasto (ej. `509-01`). |

### Compras / abasto *(campos ERP)*

| Columna | Qué poner |
|---|---|
| **Stock minimo** | Nivel para avisar "hay que comprar" (número). |
| **Tiempo entrega dias** | Días que tarda el proveedor en surtir (entero). |
| **Cantidad minima compra** | MOQ: cantidad mínima que vende el proveedor (número). |
| **Activo** | `si` / `no` (también `1`/`0`, `vigente`, `baja`…). |

## Reglas de importación

- **Ya existe** (por SKU, o por Nombre si no hay SKU) → se **actualiza** con las columnas que hayas mapeado (precio, moneda, unidad, proveedor, notas, tasas, stock mínimo, MOQ, activo… y **tipo** si mapeaste esa columna).
- **No existe** → se **crea**. El tipo sale de la columna `Tipo` si la mapeaste; si no, del selector "Tipo para productos nuevos" (ajustable fila por fila en la vista previa).
- Valores que no se entienden (IVA no numérico, `activo` distinto de si/no, tipo desconocido) se marcan como aviso en la fila y ese campo no se toca; el resto de la fila sí entra.
- En la vista previa marcas qué filas entran. **Nada se guarda hasta pulsar "Importar".**

## Consejo para las materias primas de LOVLUB

Los archivos `COSTO PRODUCCION *.xlsx` traen la hoja `COSTOS COMPRA` con casi toda la lista.
Para pasarlos a esta plantilla:

- **Nombre** ← columna `NOMBRE`
- **Proveedor** ← columna `PROVEEDOR`
- **Precio** ← usa `COSTO GR/ML IVA INCLUIDO` × 1000 (queda en MXN por Kg/Lt) y pon **Moneda = MXN**;
  o usa `PRECIO USD` tal cual y pon **Moneda = USD**.
- **Unidad** ← Kilogramos o Litros según el material.
- Unifica proveedores repetidos (ej. `KC FRAGANCES` vs `KCFRAGANCES`) antes de importar.
