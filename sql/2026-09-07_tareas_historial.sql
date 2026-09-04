-- =====================================================================
--  Historial de tareas del sistema — consulta filtrable + quién la resolvió
--  Fecha: 2026-09-07  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Complementa sql/2026-09-06_tareas_sistema.sql (no lo reemplaza; esa
--  tabla y sus triggers/funciones/job no se tocan aquí).
--
--  public.tareas ya guarda TODO el historial (nunca se borra una fila:
--  pendiente -> atendida / pospuesta -> archivada quedan todas ahí). Lo
--  que faltaba era:
--    a) una forma de consultarlo filtrando por estatus/tipo/fecha, y
--    b) saber QUIÉN la resolvió — resuelta_por es un uuid de auth.users,
--       y el rol authenticated no tiene permiso para leer esa tabla
--       directamente. tareas_historial() es security definer: hace ese
--       join una sola vez, en el servidor, y solo expone id + email.
--
--  Idempotente.
-- =====================================================================

begin;

create or replace function public.tareas_historial(
    p_estatus text        default null,   -- 'pendiente' | 'atendida' | 'pospuesta' | 'archivada' | null = todas
    p_tipo    text        default null,   -- 'inventario_bajo_minimo' | null = todos
    p_desde   timestamptz default null,   -- filtra por creada_en >=
    p_hasta   timestamptz default null,   -- filtra por creada_en <=
    p_limit   integer     default 300
)
returns table (
    id               bigint,
    tipo             text,
    estatus          text,
    prioridad        smallint,
    titulo           text,
    detalle          text,
    entidad_tipo     text,
    entidad_id       bigint,
    origen           text,
    accion_sugerida  text,
    creada_en        timestamptz,
    actualizada_en   timestamptz,
    posponer_hasta   timestamptz,
    resuelta_en      timestamptz,
    resuelta_por     uuid,
    resuelta_por_email text,
    nota_resolucion  text
)
language sql
stable
security definer
set search_path = public, extensions
as $$
    select t.id, t.tipo, t.estatus, t.prioridad, t.titulo, t.detalle,
           t.entidad_tipo, t.entidad_id, t.origen, t.accion_sugerida,
           t.creada_en, t.actualizada_en, t.posponer_hasta, t.resuelta_en,
           t.resuelta_por, u.email, t.nota_resolucion
    from public.tareas t
    left join auth.users u on u.id = t.resuelta_por
    where (p_estatus is null or t.estatus = p_estatus)
      and (p_tipo    is null or t.tipo    = p_tipo)
      and (p_desde   is null or t.creada_en >= p_desde)
      and (p_hasta   is null or t.creada_en <= p_hasta)
    order by t.creada_en desc
    limit greatest(coalesce(p_limit, 300), 1);
$$;

grant execute on function
    public.tareas_historial(text, text, timestamptz, timestamptz, integer)
    to authenticated;

comment on function public.tareas_historial is
  'Historial filtrable de public.tareas con el email de quien la resolvió (join a auth.users vía security definer).';

commit;


-- =====================================================================
--  Prueba rápida (opcional)
-- =====================================================================
-- select * from public.tareas_historial(null, null, null, null, 50);
-- select estatus, count(*) from public.tareas group by estatus order by 1;
