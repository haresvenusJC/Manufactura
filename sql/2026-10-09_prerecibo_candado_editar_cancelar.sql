-- =====================================================================
--  Pre-recibo: candado obligatorio, cancelar, editar (solo admin)
--  Fecha: 2026-10-09  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-11_prerecibo_operador.sql,
--            sql/2026-09-24_validador_piezas_prerecibo.sql
--
--  Pedido explícito: ninguna orden de compra puede afectar inventario ni
--  contabilidad si no tiene un pre-recibo VALIDADO. Sin excepciones — si
--  no hay operador para hacer el conteo físico, el admin lo captura él
--  mismo desde su panel (ya tiene permiso de escritura directa sobre
--  pre_recibos por la política RLS admin_all).
--
--  Cambios:
--  1) pre_recibos.estatus admite 'cancelado' (además de pendiente /
--     validado / rechazado). Cancelar sirve para anular un pre-recibo
--     por completo (se equivocaron de OC, se duplicó, la compra ya no
--     aplica) y poder capturar uno nuevo para la misma orden — a
--     diferencia de "rechazar", que es para cuando el CONTEO está mal y
--     hay que recontar. Se puede cancelar en cualquier estatus (incluso
--     ya validado), por si el admin se da cuenta después del error.
--  2) prerecibo_validar gana la acción 'cancelar'.
--  3) prerecibo_editar (nueva): SOLO admin, corrige a mano las
--     cantidades capturadas por partida y las observaciones de un
--     pre-recibo pendiente o validado — para cuando el operador
--     capturó mal un número. Queda en la bitácora (trigger genérico).
--  4) Candado real: trigger en documentos que impide crear un recibo de
--     mercancía (tipo_movimiento = 'entrada_compra' con orden_compra_id)
--     si esa orden no tiene un pre-recibo con estatus 'validado'. Como
--     TODO el flujo de recepción (documento_detalles, movimiento FIFO,
--     lotes, contabilizar_compra) arranca insertando esa fila en
--     documentos, este único candado bloquea inventario Y contabilidad
--     a la vez — no hace falta tocarlos por separado.
--  5) Bitácora en pre_recibos (no estaba cubierta).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Nuevo estatus 'cancelado'
-- ---------------------------------------------------------------------
alter table public.pre_recibos drop constraint if exists pre_recibos_estatus_check;
alter table public.pre_recibos
    add constraint pre_recibos_estatus_check
    check (estatus in ('pendiente', 'validado', 'rechazado', 'cancelado'));

-- ---------------------------------------------------------------------
-- 2. prerecibo_validar: agrega la acción 'cancelar'
-- ---------------------------------------------------------------------
create or replace function public.prerecibo_validar(
    p_id     bigint,
    p_accion text,               -- 'validar' | 'rechazar' | 'cancelar'
    p_nota   text default null
)
returns public.pre_recibos
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_row public.pre_recibos;
    v_nuevo text;
begin
    if coalesce(auth.role(), '') <> 'authenticated' then
        raise exception 'No autorizado.';
    end if;
    if p_accion not in ('validar', 'rechazar', 'cancelar') then
        raise exception 'Acción inválida (usa validar | rechazar | cancelar).';
    end if;
    v_nuevo := case p_accion when 'validar' then 'validado' when 'rechazar' then 'rechazado' else 'cancelado' end;

    update public.pre_recibos
       set estatus         = v_nuevo,
           nota_validacion = nullif(trim(p_nota), ''),
           validado_por    = auth.uid(),
           validado_en     = now()
     where id = p_id
    returning * into v_row;

    if not found then
        raise exception 'El pre-recibo % no existe.', p_id;
    end if;
    return v_row;
end $$;

revoke all     on function public.prerecibo_validar(bigint, text, text) from public, anon;
grant  execute on function public.prerecibo_validar(bigint, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 3. prerecibo_editar: solo admin, corrige cantidades/observaciones
-- ---------------------------------------------------------------------
create or replace function public.prerecibo_editar(
    p_id             bigint,
    p_lineas         jsonb,
    p_observaciones  text default null
)
returns public.pre_recibos
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_actual     public.pre_recibos;
    v_lineas     jsonb := coalesce(p_lineas, '[]'::jsonb);
    r            jsonb;
    v_detalle_id bigint;
    v_cant       numeric;
    v_row        public.pre_recibos;
begin
    if coalesce(auth.role(), '') <> 'authenticated' then
        raise exception 'No autorizado.';
    end if;

    select * into v_actual from public.pre_recibos where id = p_id;
    if v_actual is null then raise exception 'El pre-recibo % no existe.', p_id; end if;
    if v_actual.estatus not in ('pendiente', 'validado') then
        raise exception 'Solo se puede editar un pre-recibo pendiente o validado (este está "%").', v_actual.estatus;
    end if;

    if jsonb_typeof(v_lineas) <> 'array' then raise exception 'Formato de partidas inválido.'; end if;
    if jsonb_array_length(v_lineas) > 200 then raise exception 'Demasiadas partidas.'; end if;
    for r in select * from jsonb_array_elements(v_lineas)
    loop
        v_detalle_id := nullif(r->>'orden_compra_detalle_id', '')::bigint;
        v_cant := (r->>'cantidad_capturada')::numeric;
        if v_cant is null or v_cant < 0 then
            raise exception 'La cantidad capturada de una partida no puede ser negativa ni estar vacía.';
        end if;
        if v_detalle_id is not null and v_actual.orden_compra_id is not null then
            if not exists (
                select 1 from public.ordenes_compra_detalle d
                 where d.id = v_detalle_id and d.orden_compra_id = v_actual.orden_compra_id
            ) then
                raise exception 'Una partida no pertenece a la orden de compra de este pre-recibo.';
            end if;
        end if;
    end loop;

    update public.pre_recibos
       set lineas        = v_lineas,
           observaciones = coalesce(nullif(trim(p_observaciones), ''), observaciones)
     where id = p_id
    returning * into v_row;

    return v_row;
end $$;

revoke all     on function public.prerecibo_editar(bigint, jsonb, text) from public, anon;
grant  execute on function public.prerecibo_editar(bigint, jsonb, text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Candado: sin pre-recibo validado, no se puede crear el documento
--    de recepción (y por lo tanto nada de lo que depende de él).
-- ---------------------------------------------------------------------
create or replace function public._candado_recibo_requiere_prerecibo()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if new.tipo_movimiento = 'entrada_compra' and new.orden_compra_id is not null then
        if not exists (
            select 1 from public.pre_recibos
             where orden_compra_id = new.orden_compra_id
               and estatus = 'validado'
        ) then
            raise exception
                'No puedes registrar un recibo de mercancía para esta orden de compra sin un pre-recibo validado. '
                'Si el operador ya lo capturó, valídalo primero en "Pre-recibos por validar". '
                'Si no hay operador, captúralo tú mismo desde el panel de administración y valídalo antes de continuar.';
        end if;
    end if;
    return new;
end $$;

drop trigger if exists trg_candado_recibo_prerecibo on public.documentos;
create trigger trg_candado_recibo_prerecibo
    before insert on public.documentos
    for each row execute function public._candado_recibo_requiere_prerecibo();

-- ---------------------------------------------------------------------
-- 5. Bitácora en pre_recibos
-- ---------------------------------------------------------------------
drop trigger if exists trg_bitacora_pre_recibos on public.pre_recibos;
create trigger trg_bitacora_pre_recibos
    after insert or update or delete on public.pre_recibos
    for each row execute function public.fn_bitacora_generica();

commit;
