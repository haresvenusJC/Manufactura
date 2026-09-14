-- =====================================================================
--  Auditoría de inventarios: resumen de TODAS las capturas que el
--  propio operador ha ido registrando en una auditoría (con su nota y
--  su caducidad), para que las revise antes de darla por terminada.
--  Fecha: 2026-09-16  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-14f_auditoria_inventarios.sql
--            sql/2026-09-15_auditoria_caducidad_y_unidad.sql
--
--  Idempotente.
-- =====================================================================

begin;

create or replace function public.mis_capturas_auditoria(p_token uuid, p_auditoria_id bigint)
returns table (
    item_id              bigint,
    descripcion          text,
    sku                  text,
    unidad_nombre        text,
    conteo_id            bigint,
    cantidad             numeric,
    tipo_captura         text,
    piezas_por_caja      numeric,
    cantidad_equivalente numeric,
    nota                 text,
    fecha_caducidad      date,
    capturado_en         timestamptz
)
language plpgsql security definer set search_path = public, extensions
as $$
declare
    v_empleado_id bigint;
begin
    select s.empleado_id into v_empleado_id
      from public.sesiones_ot s
     where s.token = p_token and s.expira_at > now();
    if v_empleado_id is null then raise exception 'SESION_EXPIRADA'; end if;

    return query
        select ai.id, coalesce(p.nombre, ai.descripcion_libre), p.sku,
               coalesce(ai.unidad_nombre, ''), ac.id, ac.cantidad, ac.tipo_captura,
               ac.piezas_por_caja, ac.cantidad_equivalente, ac.nota, ac.fecha_caducidad, ac.capturado_en
          from public.auditoria_conteos ac
          join public.auditoria_items ai on ai.id = ac.item_id
          left join public.productos p on p.id = ai.producto_id
         where ai.auditoria_id = p_auditoria_id
           and ac.empleado_id = v_empleado_id
         order by coalesce(p.nombre, ai.descripcion_libre), ac.capturado_en desc;
end $$;

revoke all     on function public.mis_capturas_auditoria(uuid, bigint) from public;
grant  execute on function public.mis_capturas_auditoria(uuid, bigint) to anon, authenticated;

commit;
