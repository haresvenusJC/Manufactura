# Hares de México — guía para trabajar en este repo

Vanilla JS (ES modules, sin build) + Supabase (Postgres/PostgREST/Auth) + Tailwind CDN.

## Reglas del proyecto

- **Todo menú desplegable (`<select>`) se llena desde su tabla real en Supabase**, nunca con opciones
  inventadas o hardcodeadas a mano. Si el dato ya tiene catálogo (cuentas contables, `c_uso_cfdi`,
  `c_forma_pago`, `c_metodo_pago`, `unidades_medida`, `monedas`, régimen fiscal, etc.), el select se
  construye consultando esa tabla/columna. Si dos formularios necesitan el mismo catálogo, se exporta
  desde donde ya vive (ver `REGIMENES` en `js/proveedores.js`) en vez de duplicarlo.
- Migraciones SQL van en `sql/` con fecha en el nombre, envueltas en `begin;`/`commit;`, siempre
  idempotentes (`create table if not exists`, `add column if not exists`, `create or replace function`).
  Nunca se edita un archivo de migración ya corrido — se agrega uno nuevo.
- No las corre la app: se pegan a mano en Supabase → SQL Editor.
