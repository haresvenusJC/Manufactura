-- =====================================================================
--  Acuerdo con el proveedor para pagos parciales (Cuentas por pagar v2)
--  Proyecto: Hares de México (Supabase)
--
--  Un pago parcial necesita escribir el acuerdo con el proveedor
--  (p. ej. "anticipo 50%, saldo contra entrega"). Se guarda en el pago
--  mismo, no en la póliza. El pago total no lleva acuerdo.
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

alter table public.pagos_proveedor add column if not exists acuerdo_proveedor text;

create or replace function public.pago_proveedor_set_acuerdo(p_pago_id bigint, p_acuerdo text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_texto text := trim(coalesce(p_acuerdo, ''));
begin
    if v_texto = '' then
        raise exception 'Escribe el acuerdo con el proveedor.';
    end if;
    update public.pagos_proveedor
       set acuerdo_proveedor = v_texto
     where id = p_pago_id;
    if not found then
        raise exception 'Pago % no existe.', p_pago_id;
    end if;
    return jsonb_build_object('pago_id', p_pago_id, 'acuerdo', v_texto);
end;
$$;

revoke all     on function public.pago_proveedor_set_acuerdo(bigint, text) from public, anon;
grant  execute on function public.pago_proveedor_set_acuerdo(bigint, text) to authenticated;

commit;
