-- =====================================================================
--  SOLO LECTURA. Después de correr 2026-10-22d: ¿qué cuentas de esa migración
--  NO se pudieron crear porque el código YA existía con otro nombre?
--  (La migración no las toca: se quedan como estaban.)
--  Pega el resultado al asistente.
-- =====================================================================

-- 1) Código pedido por la migración vs. lo que hay hoy en tu plan
with pedido(codigo, nombre_esperado) as (values
    ('155', 'Mobiliario y equipo de oficina'),
    ('156', 'Equipo de transporte'),
    ('157', 'Equipo de comunicación'),
    ('158', 'Edificios y construcciones'),
    ('159', 'Adaptaciones y mejoras'),
    ('613', 'Depreciación contable (administración)'),
    ('155.01', 'Mobiliario y equipo de oficina'),
    ('156.01', 'Equipo de transporte (automóviles, camiones)'),
    ('157.01', 'Equipo de comunicación'),
    ('158.01', 'Edificios y construcciones'),
    ('159.01', 'Adaptaciones y mejoras'),
    ('153.03', 'Depreciación acumulada de mobiliario y equipo de oficina'),
    ('153.04', 'Depreciación acumulada de equipo de transporte'),
    ('153.05', 'Depreciación acumulada de equipo de comunicación'),
    ('153.06', 'Depreciación acumulada de edificios y construcciones'),
    ('153.07', 'Depreciación acumulada de adaptaciones y mejoras'),
    ('503.20', 'Depreciación de equipo de cómputo (planta)'),
    ('503.21', 'Depreciación de mobiliario y equipo (planta)'),
    ('503.22', 'Depreciación de equipo de transporte (planta)'),
    ('503.23', 'Depreciación de equipo de comunicación (planta)'),
    ('503.24', 'Depreciación de edificios y construcciones (planta)'),
    ('503.25', 'Depreciación de adaptaciones y mejoras (planta)'),
    ('613.01', 'Depreciación de edificios y construcciones'),
    ('613.02', 'Depreciación de maquinaria y equipo'),
    ('613.03', 'Depreciación de equipo de transporte'),
    ('613.04', 'Depreciación de mobiliario y equipo de oficina'),
    ('613.05', 'Depreciación de equipo de cómputo'),
    ('613.06', 'Depreciación de equipo de comunicación'),
    ('613.17', 'Depreciación de adaptaciones y mejoras')
)
select p.codigo,
       p.nombre_esperado,
       c.nombre as nombre_actual_en_tu_plan,
       case when c.id is null              then 'NO EXISTE (revisar: debió crearse)'
            when c.nombre = p.nombre_esperado then 'OK (la creó la migración)'
            else 'CONFLICTO: ya existía con otro nombre' end as estado
  from pedido p
  left join public.cuentas_contables c on c.codigo = p.codigo
 order by (case when c.id is null then 0 when c.nombre = p.nombre_esperado then 2 else 1 end), p.codigo;

-- 2) Categorías que quedaron SIN alguna cuenta (por conflicto o por ser categorías raras)
select c.categoria,
       case when c.cuenta_activo_id      is null then 'falta' else 'ok' end as activo,
       case when c.cuenta_dep_acum_id    is null then 'falta' else 'ok' end as dep_acumulada,
       case when c.cuenta_gasto_cif_id   is null then 'falta' else 'ok' end as gasto_produccion,
       case when c.cuenta_gasto_admin_id is null then 'falta' else 'ok' end as gasto_admin
  from public.c_categoria_depreciacion c
 where c.grupo = 'depreciacion'
   and (c.cuenta_activo_id is null or c.cuenta_dep_acum_id is null or c.cuenta_gasto_cif_id is null or c.cuenta_gasto_admin_id is null)
 order by c.orden;
