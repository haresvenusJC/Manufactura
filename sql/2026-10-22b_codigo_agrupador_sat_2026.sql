-- =====================================================================
--  Código agrupador SAT correcto en el plan de cuentas
--  Fecha: 2026-10-22  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Fuente: Anexo 24 de la RMF 2026 (DOF 13-ene-2026), apartado A) a),
--  "Código agrupador de cuentas del SAT".
--
--  Problema: la siembra del plan de cuentas (2026-08-28 y siguientes) copió el
--  código interno en la columna codigo_agrupador (152.01 -> '152.01'), y solo
--  coincide con el SAT por casualidad: 152.01 es "Edificios" en el SAT (la
--  maquinaria es 153.01), 154.01 es "Automóviles" (el equipo de cómputo es
--  156.01), 503.xx es "Devoluciones sobre compras" (el CIF es 504.xx), etc.
--  Con eso la contabilidad electrónica (catálogo y balanza) saldría mal clasificada.
--
--  Qué hace: SOLO corrige codigo_agrupador de las cuentas que existan (por su
--  número interno); NO cambia números, nombres, saldos ni pólizas. Las cuentas
--  mayores (padre) toman el código de nivel 1 de SAT (3 dígitos) de sus hijas
--  cuando todas coinciden. Muestra cada cambio en un NOTICE (antes -> después).
--  Idempotente: una segunda corrida no cambia nada.
--
--  Revísalo con tu contador. Criterios que son JUICIO (marcados abajo con ¿?):
--  no hay una equivalencia única en el SAT.
-- =====================================================================

begin;

create temp table _agrup_sat (codigo text primary key, agrupador text not null, nota text) on commit drop;

insert into _agrup_sat (codigo, agrupador, nota) values
    -- Activo circulante
    ('101.01', '101.01', 'Caja y efectivo'),
    ('102.01', '102.01', 'Bancos nacionales'),
    ('102.02', '102.02', 'Bancos extranjeros'),
    ('105.01', '105.01', 'Clientes nacionales'),
    ('108.01', '107.01', '¿? Deudores diversos (SAT: 107 Deudores diversos; 107.01 Funcionarios y empleados)'),
    ('109.01', '120.01', 'Anticipos a proveedores -> SAT 120.01 Anticipo a proveedores nacional (109 del SAT es Pagos anticipados: seguros/rentas)'),
    ('115.01', '115.02', 'Inventario de materia prima -> SAT 115.02 Materia prima y materiales'),
    ('115.02', '115.03', '¿? Semiterminados/granel -> SAT 115.03 Producción en proceso'),
    ('115.03', '115.03', 'Producción en proceso'),
    ('115.04', '115.04', 'Productos terminados'),
    ('118.01', '118.01', 'IVA acreditable pagado'),
    ('118.03', '118.03', 'IEPS acreditable pagado'),
    ('119.01', '119.01', 'IVA pendiente de pago'),
    -- Activo fijo y su depreciación
    ('152.01', '153.01', 'Maquinaria y equipo -> SAT 153.01 (152 del SAT es Edificios)'),
    ('154.01', '156.01', 'Equipo de cómputo -> SAT 156.01 (154 del SAT es Automóviles)'),
    ('153.01', '171.02', 'Dep. acumulada de maquinaria y equipo -> SAT 171.02'),
    ('153.02', '171.05', 'Dep. acumulada de equipo de cómputo -> SAT 171.05'),
    -- Pasivo
    ('201.01', '201.01', 'Proveedores nacionales'),
    ('205.01', '205.02', 'Acreedores diversos a corto plazo nacional'),
    ('209.01', '208.01', 'IVA trasladado cobrado'),
    ('209.02', '209.01', 'IVA trasladado no cobrado'),
    ('210.01', '207.02', '¿? IEPS trasladado'),
    ('213.01', '213.03', 'ISR por pagar'),
    ('213.03', '213.01', 'IVA por pagar'),
    ('216.01', '216.01', 'ISR retenido por sueldos'),
    ('216.05', '216.10', 'IVA retenido -> SAT 216.10 Impuestos retenidos de IVA'),
    ('216.10', '216.04', '¿? ISR retenido por honorarios/fletes -> SAT 216.04 ISR por servicios profesionales'),
    ('219.01', '211.01', '¿? IMSS/INFONAVIT y nómina por pagar -> SAT 211.01 Provisión de IMSS patronal por pagar'),
    -- Capital
    ('301.01', '301.01', 'Capital fijo'),
    ('304.01', '304.01', 'Utilidad de ejercicios anteriores'),
    ('305.01', '305.01', 'Utilidad del ejercicio'),
    -- Ingresos
    ('401.01', '401.01', 'Ventas a la tasa general'),
    ('401.03', '401.04', 'Ventas al 0%'),
    ('401.04', '401.07', 'Ventas exentas'),
    ('402.01', '402.01', 'Devoluciones sobre ventas (tasa general)'),
    ('403.01', '403.01', 'Otros ingresos'),
    -- Costos
    ('501.01', '501.01', 'Costo de venta'),
    ('502.01', '502.01', 'Compras nacionales'),
    ('503.01', '504.01', 'Gastos indirectos de fabricación'),
    ('503.02', '504.01', 'Gastos indirectos de fabricación'),
    ('503.03', '504.01', 'Gastos indirectos de fabricación'),
    ('503.04', '504.08', '¿? Depreciación de maquinaria y equipo (si fuera de otro bien: 504.11 cómputo, 504.10 mobiliario...)'),
    ('503.05', '504.01', 'Gastos indirectos de fabricación'),
    ('503.06', '504.01', 'Gastos indirectos de fabricación'),
    ('503.07', '504.01', 'Gastos indirectos de fabricación'),
    ('503.08', '504.01', 'Gastos indirectos de fabricación'),
    ('503.09', '504.01', 'Gastos indirectos de fabricación'),
    ('503.10', '504.01', 'Gastos indirectos de fabricación'),
    ('503.11', '504.01', 'Gastos indirectos de fabricación'),
    ('503.12', '504.01', 'Gastos indirectos de fabricación'),
    ('503.13', '504.01', 'Gastos indirectos de fabricación'),
    ('503.14', '504.01', 'Gastos indirectos de fabricación'),
    ('503.15', '504.01', 'Gastos indirectos de fabricación'),
    ('503.16', '504.01', 'Gastos indirectos de fabricación'),
    ('503.98', '504.04', '¿? Costo de capacidad no utilizada -> SAT 504.04 Otras cuentas de costos incurridos'),
    ('503.99', '504.04', 'Otros gastos indirectos -> SAT 504.04'),
    -- Gastos generales
    ('601.01', '601.01', 'Sueldos y salarios'),
    ('601.06', '601.34', '¿? Honorarios -> SAT 601.34 personas físicas (601.38 si son personas morales)'),
    ('601.11', '601.48', 'Combustibles y lubricantes'),
    ('601.14', '601.72', 'Fletes y acarreos'),
    ('601.17', '601.52', 'Energía eléctrica'),
    ('601.18', '601.50', 'Teléfono, internet'),
    ('601.19', '601.51', 'Agua'),
    ('601.24', '601.46', '¿? Arrendamiento -> SAT 601.46 personas morales (601.45 si es persona física)'),
    ('601.50', '601.55', 'Papelería y artículos de oficina'),
    ('601.52', '601.56', 'Mantenimiento y conservación'),
    ('601.59', '601.26', 'Cuotas IMSS (601.27 es INFONAVIT)'),
    ('601.61', '601.57', 'Seguros y fianzas (mercancía en tránsito)'),
    ('601.62', '601.72', '¿? Maniobras y almacenaje -> SAT 601.72 Fletes y acarreos'),
    ('601.63', '601.73', 'Gastos aduanales -> SAT 601.73 Gastos de importación'),
    ('601.83', '601.61', 'Propaganda y publicidad'),
    ('601.84', '601.83', 'Gastos no deducibles (sin requisitos fiscales)'),
    ('601.99', '601.84', 'Otros gastos generales'),
    -- Resultado integral de financiamiento
    ('701.01', '701.10', 'Comisiones bancarias'),
    ('701.04', '701.01', 'Pérdida cambiaria'),
    ('702.01', '702.04', '¿? Intereses a favor -> SAT 702.04 bancarios nacional'),
    ('702.02', '702.01', 'Utilidad cambiaria');

-- 1) Cuentas de detalle (y cualquiera que coincida por número)
do $$
declare
    r record; n integer := 0;
begin
    for r in
        select c.id, c.codigo, c.nombre, c.codigo_agrupador as antes, m.agrupador as despues
          from public.cuentas_contables c
          join _agrup_sat m on m.codigo = c.codigo
         where c.codigo_agrupador is distinct from m.agrupador
         order by c.codigo
    loop
        update public.cuentas_contables set codigo_agrupador = r.despues where id = r.id;
        n := n + 1;
        raise notice '% · %: % -> %', r.codigo, r.nombre, coalesce(r.antes, '(vacío)'), r.despues;
    end loop;
    raise notice 'Cuentas corregidas: %', n;
end $$;

-- 2) Cuentas mayores (con hijas): código de nivel 1 del SAT (3 dígitos) si todas sus hijas coinciden
do $$
declare
    r record; n integer := 0;
begin
    for r in
        select p.id, p.codigo, p.nombre, p.codigo_agrupador as antes,
               min(left(h.codigo_agrupador, 3)) as pref, max(left(h.codigo_agrupador, 3)) as pref2
          from public.cuentas_contables p
          join public.cuentas_contables h on h.cuenta_padre_id = p.id
         where h.codigo_agrupador is not null
         group by p.id, p.codigo, p.nombre, p.codigo_agrupador
         order by p.codigo
    loop
        if r.pref is distinct from r.pref2 then
            raise notice 'MAYOR % · %: sus hijas caen en distintos rubros del SAT (% y %); revísala a mano.', r.codigo, r.nombre, r.pref, r.pref2;
        elsif r.antes is distinct from r.pref then
            update public.cuentas_contables set codigo_agrupador = r.pref where id = r.id;
            n := n + 1;
            raise notice 'MAYOR % · %: % -> %', r.codigo, r.nombre, coalesce(r.antes, '(vacío)'), r.pref;
        end if;
    end loop;
    raise notice 'Cuentas mayores corregidas: %', n;
end $$;

commit;


-- =====================================================================
--  Verificación (opcional): lo que quede con el mismo valor que su número interno
--  (señal de que no se corrigió) y las cuentas SIN agrupador.
-- =====================================================================
-- select codigo, nombre, codigo_agrupador from public.cuentas_contables
--  where codigo_agrupador is null or codigo_agrupador = codigo order by codigo;
