-- =====================================================================
--  Orden de Trabajo: resumen de componentes + lotes a surtir (FIFO/FEFO)
--  Fecha: 2026-09-12  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: bom, ordenes_produccion (estado 'en_proceso'), lotes_inventario,
--  productos, unidades_medida — todo ya existente.
--
--  Problema: al GENERAR la orden de producción no se reserva ni se emite
--  nada; la materia prima se descuenta hasta que se CIERRA la orden. Los
--  operadores no saben qué lote agarrar.
--
--  Esta vista arma, por cada orden en proceso, la explosión del BOM
--  (cantidad_requerida = bom.cantidad_requerida * orden.cantidad_producida)
--  y le asigna los lotes con la política de EQUILIBRIO FIFO/FEFO:
--
--    orden de consumo = date_trunc('month', fecha_caducidad) asc nulls last,
--                       fecha_ingreso asc, created_at asc
--
--  -> Lotes que caducan el MISMO mes se consumen FIFO (por antigüedad),
--     sin fragmentar de más. Solo cuando un lote caduca un mes ANTES se
--     adelanta (FEFO). Los lotes sin caducidad quedan al final, FIFO.
--
--  Cada línea trae 'criterio' = 'FEFO' cuando ese lote se adelantó a otro
--  más antiguo por conveniencia de producción (evitar merma por
--  caducidad), o 'FIFO' cuando salió por antigüedad normal.
--
--  IMPORTANTE: la RPC que descuenta al cerrar (registrar_salida_fifo)
--  usa el MISMO orden — ver sql/2026-09-13_salidas_fefo.sql.
--
--  Idempotente (create or replace view). Para la pantalla móvil -> anon.
-- =====================================================================

begin;

create or replace view public.v_ot_orden_componentes as
with req as (
    select op.id                                   as orden_id,
           op.folio                                 as orden_folio,
           b.componente_id                          as producto_id,
           pc.nombre                                as producto_nombre,
           pc.sku,
           umc.nombre                               as unidad,
           coalesce(pc.requiere_caducidad, false)   as requiere_caducidad,
           round((b.cantidad_requerida * coalesce(op.cantidad_producida, 0))::numeric, 4)
                                                    as cantidad_requerida
      from public.ordenes_produccion op
      join public.bom b        on b.producto_id = op.producto_id
      join public.productos pc on pc.id = b.componente_id
      left join public.unidades_medida umc on umc.id = pc.unidad_medida_id
     where op.estado = 'en_proceso'
),
lotes as (
    select l.producto_id,
           l.id                                     as lote_id,
           l.numero_lote,
           l.lote_proveedor,
           l.fecha_ingreso,
           l.fecha_caducidad,
           coalesce(l.stock_actual, 0)              as stock_actual,
           -- acumulado de lo que se consume ANTES de este lote, en el orden de equilibrio
           coalesce(sum(coalesce(l.stock_actual, 0)) over (
               partition by l.producto_id
               order by date_trunc('month', l.fecha_caducidad) asc nulls last,
                        l.fecha_ingreso asc, l.created_at asc
               rows between unbounded preceding and 1 preceding), 0) as acum_prev
      from public.lotes_inventario l
     where coalesce(l.stock_actual, 0) > 0
),
disp as (
    select producto_id, sum(stock_actual) as total_disponible
      from lotes
     group by producto_id
)
select r.orden_id,
       r.orden_folio,
       r.producto_id,
       r.producto_nombre,
       r.sku,
       r.unidad,
       r.requiere_caducidad,
       r.cantidad_requerida,
       coalesce(d.total_disponible, 0)                                     as total_disponible,
       greatest(0, r.cantidad_requerida - coalesce(d.total_disponible, 0)) as faltante,
       lo.lote_id,
       lo.numero_lote,
       lo.lote_proveedor,
       lo.fecha_ingreso,
       lo.fecha_caducidad,
       lo.stock_actual                                                     as stock_en_lote,
       case when lo.lote_id is null then null
            else greatest(0, least(lo.stock_actual, r.cantidad_requerida - lo.acum_prev))
       end                                                                 as tomar_de_lote,
       -- 'FEFO' si este lote se adelantó a otro más antiguo (por ingreso)
       -- que caduca un mes después o no caduca; 'FIFO' si salió por antigüedad.
       case
         when lo.lote_id is null then null
         when exists (
              select 1 from lotes o
               where o.producto_id = lo.producto_id
                 and o.fecha_ingreso < lo.fecha_ingreso
                 and (o.fecha_caducidad is null
                      or date_trunc('month', o.fecha_caducidad) > date_trunc('month', lo.fecha_caducidad))
         ) then 'FEFO'
         else 'FIFO'
       end                                                                 as criterio
  from req r
  left join disp d  on d.producto_id = r.producto_id
  left join lotes lo
    on lo.producto_id = r.producto_id
   and lo.acum_prev < r.cantidad_requerida            -- solo los lotes que entran en el requerimiento
 order by r.orden_id, r.producto_nombre,
          date_trunc('month', lo.fecha_caducidad) asc nulls last,
          lo.fecha_ingreso, lo.lote_id;

grant select on public.v_ot_orden_componentes to anon, authenticated;

comment on view public.v_ot_orden_componentes is
  'Por orden en proceso: componentes del BOM con cantidad requerida, disponibilidad y lotes a surtir con política de equilibrio FIFO/FEFO (mismo mes de caducidad -> FIFO; mes anterior -> FEFO). Columna criterio indica cuál aplicó.';

commit;


-- =====================================================================
--  Prueba (opcional) — cambia :id por una orden en proceso
-- =====================================================================
-- select producto_nombre, unidad, cantidad_requerida, total_disponible, faltante,
--        numero_lote, tomar_de_lote, fecha_caducidad, criterio
-- from public.v_ot_orden_componentes
-- where orden_id = :id
-- order by producto_nombre, fecha_caducidad;
