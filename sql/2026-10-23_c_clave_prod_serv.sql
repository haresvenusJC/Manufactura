-- =====================================================================
--  Catálogo SAT de productos y servicios (c_ClaveProdServ) como TABLA
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  Sirve para que, al capturar la Clave SAT de un producto (Alta de
--  artículo), el sistema busque por clave o por palabras y muestre su
--  descripción. La tabla nace VACÍA: se llena desde Utilerías →
--  "Importar catálogo SAT (productos y servicios)" con el archivo
--  catCFDI.xls (hoja c_ClaveProdServ) que publica el SAT (Anexo 20).
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

alter table public.c_clave_prod_serv enable row level security;
drop policy if exists admin_all on public.c_clave_prod_serv;
create policy admin_all on public.c_clave_prod_serv for all to authenticated using (true) with check (true);
grant all on public.c_clave_prod_serv to authenticated;

commit;

-- Revisión después de importar:
--   select count(*) from public.c_clave_prod_serv;
--   select * from public.c_clave_prod_serv where clave like '5110%' limit 10;
