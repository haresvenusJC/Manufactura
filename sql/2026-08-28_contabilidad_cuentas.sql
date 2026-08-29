-- =====================================================================
--  Contabilidad - FASE 1: Plan de cuentas (catalogo)
--  Fecha: 2026-08-28   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--
--  Crea la tabla cuentas_contables + politica RLS + un catalogo base
--  (mayores y subcuentas) alineado al Codigo Agrupador del SAT (Anexo 24).
--
--  OJO: los codigos agrupador son una base tipica de PyME manufactura.
--  Verificalos / ajustalos con tu contador antes de usarlos para la
--  contabilidad electronica. Puedes editarlos desde la pantalla
--  "Contabilidad -> Plan de cuentas".
--
--  Idempotente: la tabla se crea solo si no existe y la semilla se
--  inserta solo si la tabla esta vacia.
-- =====================================================================

begin;

create table if not exists public.cuentas_contables (
    id                bigint generated always as identity primary key,
    codigo            text    not null unique,          -- numero de cuenta interno (NumCta)
    nombre            text    not null,
    codigo_agrupador  text,                             -- Codigo Agrupador SAT (CodAgrup)
    naturaleza        char(1) not null check (naturaleza in ('D','A')),  -- Deudora / Acreedora
    tipo              text    not null check (tipo in
                        ('activo','pasivo','capital','ingreso','costo','gasto')),
    nivel             smallint not null default 1,
    cuenta_padre_id   bigint  references public.cuentas_contables(id) on delete restrict,
    afectable         boolean not null default true,    -- true = acepta movimientos (cuenta de detalle)
    activa            boolean not null default true,
    created_at        timestamptz not null default now()
);

create index if not exists idx_cuentas_contables_padre on public.cuentas_contables(cuenta_padre_id);
create index if not exists idx_cuentas_contables_tipo  on public.cuentas_contables(tipo);

alter table public.cuentas_contables enable row level security;
drop policy if exists admin_all on public.cuentas_contables;
create policy admin_all on public.cuentas_contables
    for all
    to authenticated
    using (true)
    with check (true);

-- ---------------------------------------------------------------------
-- Semilla (solo si la tabla esta vacia)
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select v.codigo, v.nombre, v.codigo_agrupador, v.naturaleza, v.tipo, v.nivel, v.afectable
from (values
    -- ================= ACTIVO =================
    ('101',    'Caja',                                 '101',    'D', 'activo',  1, false),
    ('101.01', 'Caja y efectivo',                      '101.01', 'D', 'activo',  2, true),
    ('102',    'Bancos',                               '102',    'D', 'activo',  1, false),
    ('102.01', 'Bancos nacionales (MXN)',              '102.01', 'D', 'activo',  2, true),
    ('102.02', 'Bancos extranjeros (USD)',             '102.02', 'D', 'activo',  2, true),
    ('105',    'Clientes',                             '105',    'D', 'activo',  1, false),
    ('105.01', 'Clientes nacionales',                  '105.01', 'D', 'activo',  2, true),
    ('108',    'Deudores diversos',                    '108',    'D', 'activo',  1, false),
    ('108.01', 'Deudores diversos',                    '108.01', 'D', 'activo',  2, true),
    ('115',    'Inventario',                           '115',    'D', 'activo',  1, false),
    ('115.01', 'Inventario de materia prima',          '115.01', 'D', 'activo',  2, true),
    ('115.03', 'Produccion en proceso',               '115.03', 'D', 'activo',  2, true),
    ('115.04', 'Productos terminados',                 '115.04', 'D', 'activo',  2, true),
    ('118',    'IVA acreditable pagado',               '118',    'D', 'activo',  1, false),
    ('118.01', 'IVA acreditable pagado',               '118.01', 'D', 'activo',  2, true),
    ('118.03', 'IEPS acreditable pagado',              '118.03', 'D', 'activo',  2, true),
    ('119',    'IVA acreditable pendiente de pago',    '119',    'D', 'activo',  1, false),
    ('119.01', 'IVA acreditable pendiente de pago',    '119.01', 'D', 'activo',  2, true),
    ('152',    'Maquinaria y equipo',                  '152',    'D', 'activo',  1, false),
    ('152.01', 'Maquinaria y equipo',                  '152.01', 'D', 'activo',  2, true),
    ('154',    'Equipo de computo',                    '154',    'D', 'activo',  1, false),
    ('154.01', 'Equipo de computo',                    '154.01', 'D', 'activo',  2, true),
    -- ================= PASIVO =================
    ('201',    'Proveedores',                          '201',    'A', 'pasivo',  1, false),
    ('201.01', 'Proveedores nacionales',               '201.01', 'A', 'pasivo',  2, true),
    ('205',    'Acreedores diversos',                  '205',    'A', 'pasivo',  1, false),
    ('205.01', 'Acreedores diversos',                  '205.01', 'A', 'pasivo',  2, true),
    ('209',    'IVA trasladado',                       '209',    'A', 'pasivo',  1, false),
    ('209.01', 'IVA trasladado cobrado',               '209.01', 'A', 'pasivo',  2, true),
    ('209.02', 'IVA trasladado no cobrado',            '209.02', 'A', 'pasivo',  2, true),
    ('210',    'IEPS trasladado',                      '210',    'A', 'pasivo',  1, false),
    ('210.01', 'IEPS trasladado',                      '210.01', 'A', 'pasivo',  2, true),
    ('213',    'Impuestos por pagar',                  '213',    'A', 'pasivo',  1, false),
    ('213.01', 'ISR por pagar',                        '213.01', 'A', 'pasivo',  2, true),
    ('213.03', 'IVA por pagar',                        '213.03', 'A', 'pasivo',  2, true),
    ('216',    'Impuestos retenidos por pagar',        '216',    'A', 'pasivo',  1, false),
    ('216.01', 'ISR retenido por sueldos',             '216.01', 'A', 'pasivo',  2, true),
    ('216.05', 'IVA retenido',                         '216.05', 'A', 'pasivo',  2, true),
    ('216.10', 'ISR retenido por honorarios / fletes', '216.10', 'A', 'pasivo',  2, true),
    ('219',    'Provisiones IMSS / nomina',            '219',    'A', 'pasivo',  1, false),
    ('219.01', 'IMSS, INFONAVIT y nomina por pagar',   '219.01', 'A', 'pasivo',  2, true),
    -- ================= CAPITAL =================
    ('301',    'Capital social',                       '301',    'A', 'capital', 1, false),
    ('301.01', 'Capital social fijo',                  '301.01', 'A', 'capital', 2, true),
    ('304',    'Resultado de ejercicios anteriores',   '304',    'A', 'capital', 1, false),
    ('304.01', 'Resultado de ejercicios anteriores',   '304.01', 'A', 'capital', 2, true),
    ('305',    'Resultado del ejercicio',              '305',    'A', 'capital', 1, false),
    ('305.01', 'Resultado del ejercicio',              '305.01', 'A', 'capital', 2, true),
    -- ================= INGRESOS =================
    ('401',    'Ingresos',                             '401',    'A', 'ingreso', 1, false),
    ('401.01', 'Ventas gravadas tasa general (16%)',   '401.01', 'A', 'ingreso', 2, true),
    ('401.03', 'Ventas gravadas tasa 0%',              '401.03', 'A', 'ingreso', 2, true),
    ('401.04', 'Ventas exentas',                       '401.04', 'A', 'ingreso', 2, true),
    ('402',    'Devoluciones y descuentos s/ ventas',  '402',    'D', 'ingreso', 1, false),
    ('402.01', 'Devoluciones sobre ventas',            '402.01', 'D', 'ingreso', 2, true),
    ('403',    'Otros ingresos',                       '403',    'A', 'ingreso', 1, false),
    ('403.01', 'Otros ingresos',                       '403.01', 'A', 'ingreso', 2, true),
    -- ================= COSTOS =================
    ('501',    'Costo de venta',                       '501',    'D', 'costo',   1, false),
    ('501.01', 'Costo de venta',                       '501.01', 'D', 'costo',   2, true),
    ('502',    'Compras',                              '502',    'D', 'costo',   1, false),
    ('502.01', 'Compras nacionales de materia prima',  '502.01', 'D', 'costo',   2, true),
    -- ================= GASTOS =================
    ('601',    'Gastos generales',                     '601',    'D', 'gasto',   1, false),
    ('601.01', 'Sueldos y salarios',                   '601.01', 'D', 'gasto',   2, true),
    ('601.06', 'Honorarios',                           '601.06', 'D', 'gasto',   2, true),
    ('601.11', 'Combustibles y lubricantes',           '601.11', 'D', 'gasto',   2, true),
    ('601.14', 'Fletes y acarreos',                    '601.14', 'D', 'gasto',   2, true),
    ('601.17', 'Energia electrica',                    '601.17', 'D', 'gasto',   2, true),
    ('601.18', 'Telefono e internet',                  '601.18', 'D', 'gasto',   2, true),
    ('601.19', 'Agua',                                 '601.19', 'D', 'gasto',   2, true),
    ('601.24', 'Arrendamiento (renta)',                '601.24', 'D', 'gasto',   2, true),
    ('601.50', 'Papeleria y utiles de oficina',        '601.50', 'D', 'gasto',   2, true),
    ('601.52', 'Mantenimiento y conservacion',         '601.52', 'D', 'gasto',   2, true),
    ('601.59', 'Cuotas IMSS / INFONAVIT patronales',   '601.59', 'D', 'gasto',   2, true),
    ('601.83', 'Publicidad y propaganda',              '601.83', 'D', 'gasto',   2, true),
    ('601.84', 'Gastos no deducibles',                 '601.84', 'D', 'gasto',   2, true),
    ('601.99', 'Otros gastos generales',               '601.99', 'D', 'gasto',   2, true),
    ('701',    'Gastos financieros',                   '701',    'D', 'gasto',   1, false),
    ('701.01', 'Comisiones y gastos bancarios',        '701.01', 'D', 'gasto',   2, true),
    ('701.04', 'Perdida cambiaria',                    '701.04', 'D', 'gasto',   2, true),
    ('702',    'Productos financieros',                '702',    'A', 'ingreso', 1, false),
    ('702.01', 'Intereses a favor',                    '702.01', 'A', 'ingreso', 2, true),
    ('702.02', 'Utilidad cambiaria',                   '702.02', 'A', 'ingreso', 2, true)
) as v(codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
where not exists (select 1 from public.cuentas_contables);

-- Enlaza cada subcuenta (nivel 2) con su mayor (nivel 1) por prefijo de codigo.
update public.cuentas_contables c
set cuenta_padre_id = p.id
from public.cuentas_contables p
where c.nivel = 2
  and c.cuenta_padre_id is null
  and p.nivel = 1
  and p.codigo = split_part(c.codigo, '.', 1);

commit;
