-- =====================================================================
--  Requisición de compra: cancelar una pendiente
--  Fecha: 2026-10-11  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-29_requisiciones_compra.sql
--
--  La tabla ya admitía el estatus 'cancelada' desde que se creó, pero
--  nunca se implementó la función ni el botón — solo existían Autorizar
--  y Rechazar. "Cancelar" es para cuando la requisición ya no aplica por
--  algo ajeno al contenido (se generó por error, se duplicó, ya no se
--  necesita) — a diferencia de "Rechazar", que es un rechazo de fondo
--  (el admin no aprueba comprar eso). Solo aplica a una pendiente.
--
--  Idempotente.
-- =====================================================================

begin;

create or replace function public.requisicion_cancelar(
    p_requisicion_id bigint,
    p_motivo         text default null
)
returns void
language plpgsql
volatile
set search_path = public
as $$
declare
    v_estatus text;
begin
    select estatus into v_estatus
      from public.requisiciones_compra
     where id = p_requisicion_id
       for update;

    if v_estatus is null then
        raise exception 'La requisición % no existe.', p_requisicion_id;
    end if;
    if v_estatus <> 'pendiente' then
        raise exception 'La requisición ya está en estatus "%": no se puede cancelar.', v_estatus;
    end if;

    update public.requisiciones_compra
       set estatus = 'cancelada',
           motivo_rechazo = nullif(trim(p_motivo), ''),
           revisada_en = now()
     where id = p_requisicion_id;
end;
$$;

grant execute on function public.requisicion_cancelar(bigint, text) to authenticated;

commit;
