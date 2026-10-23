-- =====================================================================
--  Catálogos SAT de productos y servicios (c_ClaveProdServ) y de unidades (c_ClaveUnidad) como TABLAS
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  Sirve para que, al capturar la Clave SAT de un producto (Alta de
--  artículo), el sistema busque por clave o por palabras y muestre su
--  descripción. La tabla nace VACÍA: se llena desde Utilerías →
--  "Importar catálogo SAT (productos y servicios)" con el archivo
--  catCFDI.xls (hoja c_ClaveProdServ) que publica el SAT (Anexo 20).
--  También crea c_clave_unidad y la columna unidades_medida.clave_sat.
--  No toca productos ni claves ya capturadas. Idempotente.
--  Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

create table if not exists public.c_clave_prod_serv (
    clave               text primary key,
    descripcion         text not null,
    incluir_iva         text,
    incluir_ieps        text,
    palabras_similares  text,
    fecha_inicio        text,
    fecha_fin           text      -- vacío = vigente
);

comment on table public.c_clave_prod_serv is
  'Catálogo c_ClaveProdServ del SAT (CFDI 4.0). Se carga desde Utilerías con catCFDI.xls.';

-- Catálogo c_ClaveUnidad del SAT (unidades de medida del CFDI: KGM, LTR, H87...).
create table if not exists public.c_clave_unidad (
    clave        text primary key,
    nombre       text not null,
    descripcion  text,
    simbolo      text,
    fecha_inicio text,
    fecha_fin    text      -- vacío = vigente
);
comment on table public.c_clave_unidad is
  'Catálogo c_ClaveUnidad del SAT (CFDI 4.0). Se carga desde Utilerías con el mismo archivo del catálogo de productos y servicios.';

alter table public.c_clave_unidad enable row level security;
drop policy if exists admin_all on public.c_clave_unidad;
create policy admin_all on public.c_clave_unidad for all to authenticated using (true) with check (true);
grant all on public.c_clave_unidad to authenticated;

-- Cada unidad de medida del ERP puede llevar su clave SAT (se edita en Configuración → Tablas → Unidades de medida).
alter table public.unidades_medida add column if not exists clave_sat text;

alter table public.c_clave_prod_serv enable row level security;
drop policy if exists admin_all on public.c_clave_prod_serv;
create policy admin_all on public.c_clave_prod_serv for all to authenticated using (true) with check (true);
grant all on public.c_clave_prod_serv to authenticated;

commit;

-- Revisión después de importar:
--   select count(*) from public.c_clave_prod_serv;
--   select count(*) from public.c_clave_unidad;
--   select * from public.c_clave_prod_serv where clave like '5110%' limit 10;
