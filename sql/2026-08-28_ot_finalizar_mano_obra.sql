-- =====================================================================
--  Migración: función ot_finalizar (botón "🏁 Finalizar tarea" del móvil)
--  Fecha: 2026-08-28
--  Proyecto: Hares de México (Supabase)
--
--  Este archivo NO lo ejecuta la aplicación. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--
--  Motivo: js/orden-trabajo.js llama a supabaseClient.rpc('ot_finalizar', ...)
--  y lee la columna "finalizado_at" desde la vista v_ot_proceso_empleados,
--  pero ninguna de las dos cosas quedó registrada en el SQL versionado de
--  2026-08-27_flujo_ot.sql. Resultado: el cronómetro nunca se cierra al
--  finalizar la tarea, por lo que "Equipos de Trabajo por Proceso" muestra
--  00:00:00 y $0.00 aunque el empleado sí haya trabajado (el costo por hora
--  nunca se multiplica porque no hay segundos que multiplicar).
--
--  Esta migración es idempotente: se puede correr varias veces sin romper
--  nada, y "create or replace" sobrescribe cualquier versión rota que ya
--  exista en la base de datos.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. orden_produccion_proceso_empleados: marca de "tarea finalizada"
-- ---------------------------------------------------------------------
alter table public.orden_produccion_proceso_empleados
    add column if not exists finalizado_at timestamptz;

-- ---------------------------------------------------------------------
-- 2. Vista pública para 'anon': ahora expone finalizado_at
--    (agrega columna al final; compatible con create or replace view)
-- ---------------------------------------------------------------------
create or replace view public.v_ot_proceso_empleados as
    select ope.orden_produccion_proceso_id,
           ope.empleado_id,
           e.nombre as empleado_nombre,
           ope.finalizado_at
      from public.orden_produccion_proceso_empleados ope
      join public.empleados e on e.id = ope.empleado_id;

-- ---------------------------------------------------------------------
-- 3. ot_finalizar: finaliza (o reabre) la tarea de un empleado en un
--    proceso. Al finalizar, SIEMPRE cierra primero el cronómetro abierto
--    (si lo hay) para que el tiempo trabajado quede en registros_tiempo
--    y el costo (costo_hora_snapshot * horas) se calcule completo cuando
--    el admin cierre la orden.
-- ---------------------------------------------------------------------
-- Se elimina primero por si ya existe una versión con defaults en los
-- parámetros: "create or replace" no puede cambiar la firma de una función
-- existente si los defaults no coinciden.
drop function if exists public.ot_finalizar(uuid, bigint, boolean);

create or replace function public.ot_finalizar(p_token uuid, p_proceso_id bigint, p_finalizar boolean)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_empleado_id  bigint;
    v_estado_orden text;
    v_reg          record;
begin
    select s.empleado_id
      into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token
       and s.expira_at > now();

    if v_empleado_id is null then
        raise exception 'SESION_EXPIRADA';
    end if;

    select op.estado
      into v_estado_orden
      from public.orden_produccion_procesos opp
      join public.ordenes_produccion op on op.id = opp.orden_produccion_id
     where opp.id = p_proceso_id;

    if v_estado_orden is null then
        raise exception 'El proceso no existe.';
    end if;
    if v_estado_orden <> 'en_proceso' then
        raise exception 'La orden ya no está en proceso.';
    end if;

    if not exists (
        select 1 from public.orden_produccion_proceso_empleados ope
         where ope.orden_produccion_proceso_id = p_proceso_id
           and ope.empleado_id = v_empleado_id
    ) then
        raise exception 'No estás asignado a este proceso.';
    end if;

    if p_finalizar then
        -- Cierra el cronómetro abierto (si existe) ANTES de marcar finalizada
        -- la tarea, para no perder el tiempo trabajado.
        update public.registros_tiempo rt
           set fin = now()
         where rt.orden_produccion_proceso_id = p_proceso_id
           and rt.empleado_id = v_empleado_id
           and rt.fin is null
        returning * into v_reg;

        update public.orden_produccion_proceso_empleados
           set finalizado_at = now()
         where orden_produccion_proceso_id = p_proceso_id
           and empleado_id = v_empleado_id;

        return jsonb_build_object(
            'estado', 'finalizada',
            'cronometro_cerrado', (v_reg is not null),
            'fin', coalesce(v_reg.fin, now())
        );
    else
        update public.orden_produccion_proceso_empleados
           set finalizado_at = null
         where orden_produccion_proceso_id = p_proceso_id
           and empleado_id = v_empleado_id;

        return jsonb_build_object('estado', 'reabierta');
    end if;
end;
$$;

revoke all     on function public.ot_finalizar(uuid, bigint, boolean) from public;
grant  execute on function public.ot_finalizar(uuid, bigint, boolean) to anon, authenticated;

commit;
