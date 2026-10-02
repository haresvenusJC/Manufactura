-- =====================================================================
--  Catálogo de regímenes fiscales del SAT (c_RegimenFiscal) como TABLA
--  Fecha: 2026-10-30  ·  Proyecto: Hares de México (Supabase)
--
--  PASO 1 de 2. Hasta hoy el catálogo vivía en el código (REGIMENES de
--  js/proveedores.js, y una copia recortada en js/clientes.js): agregar o
--  retirar un régimen exigía editar y publicar código. Ahora vive aquí,
--  igual que c_uso_cfdi / c_forma_pago / c_metodo_pago, y se edita desde
--  Configuración → Tablas → "SAT · Regímenes fiscales".
--
--  - Siembra las MISMAS 19 claves que tenía el código (nada inventado).
--    El SAT tiene más (609, 628, 629, 630...): se agregan desde la pantalla.
--  - "activo" permite retirar un régimen sin borrarlo: deja de ofrecerse
--    en los formularios, pero proveedores/clientes que ya lo traen lo
--    conservan.
--  - No toca proveedores ni clientes. La llave foránea va en el PASO 2
--    (sql/2026-10-30b_regimen_fiscal_fk.sql), después de revisar que no
--    haya claves huérfanas.
--  Idempotente. Pégalo completo en Supabase -> SQL Editor.
-- =====================================================================
begin;

create table if not exists public.c_regimen_fiscal (
    clave       text primary key,
    descripcion text not null,
    activo      boolean not null default true
);

insert into public.c_regimen_fiscal (clave, descripcion) values
    ('601', 'General de Ley Personas Morales'),
    ('603', 'Personas Morales con Fines no Lucrativos'),
    ('605', 'Sueldos y Salarios e Ingresos Asimilados a Salarios'),
    ('606', 'Arrendamiento'),
    ('607', 'Régimen de Enajenación o Adquisición de Bienes'),
    ('608', 'Demás ingresos'),
    ('610', 'Residentes en el Extranjero sin Establecimiento Permanente en México'),
    ('611', 'Ingresos por Dividendos (socios y accionistas)'),
    ('612', 'Personas Físicas con Actividades Empresariales y Profesionales'),
    ('614', 'Ingresos por intereses'),
    ('615', 'Régimen de los ingresos por obtención de premios'),
    ('616', 'Sin obligaciones fiscales'),
    ('620', 'Sociedades Cooperativas de Producción'),
    ('621', 'Incorporación Fiscal'),
    ('622', 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras'),
    ('623', 'Opcional para Grupos de Sociedades'),
    ('624', 'Coordinados'),
    ('625', 'Régimen de las Actividades Empresariales con ingresos a través de Plataformas Tecnológicas'),
    ('626', 'Régimen Simplificado de Confianza (RESICO)')
on conflict (clave) do nothing;   -- no pisa descripciones que ya hayas corregido a mano

alter table public.c_regimen_fiscal enable row level security;
drop policy if exists admin_all on public.c_regimen_fiscal;
create policy admin_all on public.c_regimen_fiscal for all to authenticated using (true) with check (true);
grant all    on public.c_regimen_fiscal to authenticated;
grant select on public.c_regimen_fiscal to anon;

commit;

-- Revisión:
--   select * from public.c_regimen_fiscal order by clave;
--   -- Claves en uso que NO están en el catálogo (deben salir vacías antes del PASO 2):
--   select 'proveedores' as tabla, id, nombre, regimen_fiscal from public.proveedores
--    where regimen_fiscal is not null and regimen_fiscal not in (select clave from public.c_regimen_fiscal)
--   union all
--   select 'clientes', id, nombre, regimen_fiscal from public.clientes
--    where regimen_fiscal is not null and regimen_fiscal not in (select clave from public.c_regimen_fiscal);
