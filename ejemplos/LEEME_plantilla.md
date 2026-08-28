# Plantilla de importación — Materias primas / insumos

Archivos:

- **`plantilla_materias_primas.xlsx`** — hoja `PLANTILLA` con encabezados y filas de ejemplo.
- **`plantilla_materias_primas.csv`** — lo mismo en texto plano (se edita fácil, se abre en Excel).

El importador de la app (**Catálogos → ⬆️ Importar Excel/CSV**) lee cualquiera de los dos.

## Cómo armar tu archivo

1. Abre la plantilla, **borra las filas de ejemplo** y captura las tuyas.
2. **No cambies ni muevas los encabezados de la fila 1.** El importador los detecta solos.
3. Guarda como `.xlsx` o `.csv` y súbelo en el módulo.

## Columnas

| Columna | ¿Obligatoria? | Qué poner |
|---|---|---|
| **Nombre** | **Sí** | Nombre de la materia prima / insumo. Es la clave para saber si ya existe (cuando no hay SKU). |
| **SKU** | No (recomendado) | Código interno único. Si lo pones, se empareja por SKU. Ej. `MP-CMC`, `INS-ENVASE-PET-60`. |
| **Proveedor** | No | Nombre del proveedor. Si no existe, se crea. |
| **Precio** | No | Costo unitario (número). Va a `productos.costo_unitario`. Acepta `1234.56` o `$ 1,234.56`. Vacío = sin costo. |
| **Moneda** | No | `MXN` o `USD`. Vacío = la moneda por defecto que elijas en el importador. |
| **Unidad** | No | Debe coincidir con el catálogo: Litros, Mililitros, Kilogramos, Gramos, Miligramos, Piezas… Si no coincide, se usa la de por defecto. |
| **Notas** | No | Texto libre (descripción). |

## Reglas de importación

- **Ya existe** (por SKU, o por Nombre si no hay SKU) → se **actualiza** precio, moneda, unidad, proveedor y notas. No se cambia su `tipo`.
- **No existe** → se **crea** con el tipo que elijas en el importador (Materia prima / Insumo / Producto), ajustable fila por fila en la vista previa.
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
