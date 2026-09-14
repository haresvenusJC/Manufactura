-- =====================================================================
--  Deterioro de inventario (valor neto de realización) — NIF C-4
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  NIF C-4 exige valuar el inventario al MENOR entre su costo y su valor
--  neto de realización (VNR). Hasta ahora el sistema no tenía forma de
--  castigar/reservar inventario caduco, dañado u obsoleto por debajo de
--  su costo — un lote vencido se quedaba en libros a su costo original
--  indefinidamente. Esto agrega esa capacidad:
--
--    · registrar_deterioro_inventario(p_lote_id, p_costo_nuevo, p_motivo)
--        - Exige que p_costo_nuevo sea MENOR al costo_unitario actual del
--          lote (solo castiga hacia abajo, nunca revalúa hacia arriba).
--        - Monto del castigo = (costo_anterior - costo_nuevo) x stock del
--          lote al momento.
--        - Poliza:  Cargo 601.64 (Deterioro de inventarios)
--                   Abono 115.xx (la cuenta de inventario del producto)
--        - Actualiza lotes_inventario.costo_unitario al nuevo valor y
--          deja registro en inventario_deterioros para trazabilidad.
--    · cancelar_deterioro_inventario(p_deterioro_id) — revierte la
--      póliza (vía cancelar_poliza) y regresa el lote a su costo previo.
--
--  Requiere: sql/2026-08-28_contabilidad_polizas.sql
--            sql/2026-08-28_contabilidad_compras.sql   (por _cuenta_id)
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Cuenta de gasto por deterioro de inventarios (si falta)
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select '601.64', 'Deterioro de inventarios', '601.64', 'D', 'gasto', 2, true
where not exists (select 1 from public.cuentas_contables where codigo = '601.64');

update public.cuentas_contables c
set cuenta_padre_id = p.id
from public.cuentas_contables p
where c.codigo = '601.64' and c.cuenta_padre_id is null
  and p.nivel = 1 and p.codigo = '601';


-- ---------------------------------------------------------------------
-- 1. Trazabilidad
-- ---------------------------------------------------------------------
create table if not exists public.inventario_deterioros (
    id                bigint generated always as identity primary key,
    lote_id           bigint not null references public.lotes_inventario(id) on delete restrict,
    producto_id       bigint not null references public.productos(id) on delete restrict,
    fecha             date not null default current_date,
    motivo            text not null,
    cantidad_afectada numeric(14,4) not null check (cantidad_afectada > 0),
    costo_anterior    numeric(14,4) not null,
    costo_nuevo       numeric(14,4) not null,
    monto_castigo     numeric(14,2) not null check (monto_castigo >= 0),
    cuenta_gasto_id    bigint references public.cuentas_contables(id),
    estatus           text not null default 'aplicado' check (estatus in ('aplicado','cancelado')),
    poliza_id         bigint references public.polizas(id) on delete set null,
    creado_por        uuid default auth.uid(),
    created_at        timestamptz not null default now()
);
create index if not exists idx_invdet_lote on public.inventario_deterioros(lote_id);

alter table public.inventario_deterioros enable row level security;
drop policy if exists admin_all on public.inventario_deterioros;
create policy admin_all on public.inventario_deterioros for all to authenticated using (true) with check (true);
grant all on public.inventario_deterioros to authenticated;


-- ---------------------------------------------------------------------
-- 2. registrar_deterioro_inventario
-- ---------------------------------------------------------------------
create or replace function public.registrar_deterioro_inventario(
    p_lote_id bigint, p_costo_nuevo numeric, p_motivo text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_lote      public.lotes_inventario%rowtype;
    v_costo_nuevo numeric(14,4) := round(coalesce(p_costo_nuevo, -1), 4);
    v_motivo    text := nullif(trim(p_motivo), '');
    v_monto     numeric(14,2);
    v_cta_inv   bigint;
    v_cta_gasto bigint := public._cuenta_id('601.64');
    v_poliza_id bigint;
    v_det_id    bigint;
begin
    if v_motivo is null then raise exception 'El motivo del deterioro es obligatorio.'; end if;
    if v_cta_gasto is null then raise exception 'Falta la cuenta 601.64 (Deterioro de inventarios) en el plan de cuentas.'; end if;

    select * into v_lote from public.lotes_inventario where id = p_lote_id;
    if not found then raise exception 'El lote no existe.'; end if;
    if v_lote.stock_actual <= 0 then raise exception 'El lote % ya no tiene existencia (stock 0) — no hay nada que castigar.', v_lote.numero_lote; end if;
    if v_costo_nuevo < 0 then raise exception 'El nuevo costo unitario no puede ser negativo.'; end if;
    if v_costo_nuevo >= coalesce(v_lote.costo_unitario, 0) then
        raise exception 'El nuevo costo (%) debe ser MENOR al costo actual del lote (%). Este registro solo castiga hacia abajo (deterioro), nunca revalúa hacia arriba.',
            v_costo_nuevo, v_lote.costo_unitario;
    end if;

    v_monto := round((coalesce(v_lote.costo_unitario, 0) - v_costo_nuevo) * v_lote.stock_actual, 2);
    if v_monto <= 0 then raise exception 'El castigo calculado es cero; nada que registrar.'; end if;

    select coalesce(pr.cuenta_inventario_id, public._cuenta_id('115.01'))
      into v_cta_inv
      from public.productos pr where pr.id = v_lote.producto_id;
    if v_cta_inv is null then raise exception 'El producto del lote no tiene cuenta de inventario asignada.'; end if;

    -- se inserta primero (sin poliza_id) para tener el origen_id de la poliza
    insert into public.inventario_deterioros
        (lote_id, producto_id, motivo, cantidad_afectada, costo_anterior, costo_nuevo, monto_castigo, cuenta_gasto_id)
    values
        (p_lote_id, v_lote.producto_id, v_motivo, v_lote.stock_actual, v_lote.costo_unitario, v_costo_nuevo, v_monto, v_cta_gasto)
    returning id into v_det_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', current_date,
        'tipo', 'Diario',
        'concepto', 'Deterioro de inventario — lote ' || coalesce(v_lote.numero_lote, p_lote_id::text) || ' — ' || v_motivo,
        'origen', 'ajuste',
        'origen_tabla', 'inventario_deterioros',
        'origen_id', v_det_id,
        'movimientos', jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta_gasto, 'cargo', v_monto, 'concepto', 'Deterioro de inventario: ' || v_motivo),
            jsonb_build_object('cuenta_id', v_cta_inv, 'abono', v_monto, 'concepto', 'Castigo de costo por deterioro')
        )
    ))->>'poliza_id')::bigint;

    update public.inventario_deterioros set poliza_id = v_poliza_id where id = v_det_id;

    update public.lotes_inventario set costo_unitario = v_costo_nuevo where id = p_lote_id;
    update public.productos set costo_unitario = v_costo_nuevo where id = v_lote.producto_id;

    return jsonb_build_object('deterioro_id', v_det_id, 'poliza_id', v_poliza_id, 'monto_castigo', v_monto, 'costo_nuevo', v_costo_nuevo);
end;
$$;

revoke all     on function public.registrar_deterioro_inventario(bigint, numeric, text) from public;
grant  execute on function public.registrar_deterioro_inventario(bigint, numeric, text) to authenticated;


-- ---------------------------------------------------------------------
-- 3. cancelar_deterioro_inventario
-- ---------------------------------------------------------------------
create or replace function public.cancelar_deterioro_inventario(p_deterioro_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_det public.inventario_deterioros%rowtype;
    v_rev bigint;
begin
    select * into v_det from public.inventario_deterioros where id = p_deterioro_id;
    if not found then raise exception 'El deterioro no existe.'; end if;
    if v_det.estatus = 'cancelado' then raise exception 'Este deterioro ya está cancelado.'; end if;

    if v_det.poliza_id is not null then
        v_rev := (public.cancelar_poliza(v_det.poliza_id, 'Cancelación de deterioro de inventario')->>'poliza_reversa_id')::bigint;
    end if;

    update public.lotes_inventario set costo_unitario = v_det.costo_anterior where id = v_det.lote_id;
    update public.productos set costo_unitario = v_det.costo_anterior where id = v_det.producto_id;
    update public.inventario_deterioros set estatus = 'cancelado' where id = p_deterioro_id;

    return jsonb_build_object('poliza_reversa_id', v_rev, 'costo_restaurado', v_det.costo_anterior);
end;
$$;

revoke all     on function public.cancelar_deterioro_inventario(bigint) from public;
grant  execute on function public.cancelar_deterioro_inventario(bigint) to authenticated;

commit;


-- =====================================================================
-- select * from public.inventario_deterioros order by id desc limit 10;
-- =====================================================================
