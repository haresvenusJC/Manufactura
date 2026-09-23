-- =====================================================================
--  Candados para que contabilidad e inventario no se vuelvan a descuadrar
--  Fecha: 2026-09-23  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-22_fix_hallazgos_seguridad_contabilidad.sql (cancelar_poliza)
--            sql/2026-09-23_precierre_periodo_contable.sql / 2026-10-03_devoluciones.sql
--            (_candados_cierre_periodo, precierre/cerrar_periodo_contable)
--
--  Qué pasó (ver CLAUDE.md, "Cancelar = contra-asiento"):
--   1) cancelar_poliza hace contra-asiento (póliza de reverso) Y marca la
--      original 'cancelada'. Los reportes solo sumaban 'contabilizada':
--      la original salía y el reverso restaba => se restaba DOS veces
--      (OC-787934 y OC-185388: -3,435.21 en 115.01).
--      Regla nueva: una póliza cancelada CON reverso sigue contando; el
--      reverso la neutraliza. poliza_en_saldo() es la regla única.
--   2) Recibo de mercancía dejaba recibir más de lo pedido y sumaba
--      cantidad_recibida sobre un dato viejo de pantalla, así que la OC
--      no reflejaba el duplicado (OC-000017 y OC-000020 entraron 2 veces).
--      Ahora: la base rechaza recibir más de lo pedido, y cantidad_recibida
--      se DERIVA de los documentos de recepción vivos (no se confía en
--      lo que mande la pantalla).
--   3) Candado de cierre de periodo: el kardex valorizado de cada cuenta
--      de inventario debe cuadrar con su saldo en la balanza.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Regla única: ¿esta póliza cuenta para saldos?
--    contabilizada -> sí.  cancelada con reverso contabilizado -> sí (el
--    reverso la neutraliza).  cancelada sin reverso / borrador -> no.
-- ---------------------------------------------------------------------
create or replace function public.poliza_en_saldo(p_poliza_id bigint)
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
    select coalesce((
        select p.estatus = 'contabilizada'
            or (p.estatus = 'cancelada' and exists (
                    select 1 from public.polizas r
                     where r.origen_tabla = 'polizas' and r.origen_id = p.id
                       and r.estatus = 'contabilizada'))
          from public.polizas p where p.id = p_poliza_id), false);
$$;
revoke all     on function public.poliza_en_saldo(bigint) from public;
grant  execute on function public.poliza_en_saldo(bigint) to authenticated;


-- ---------------------------------------------------------------------
-- 2a. cantidad_recibida derivada de los documentos de recepción vivos.
--     Si una OC tiene varias partidas del mismo producto, se llenan en
--     orden y la última se queda con el excedente (para que se vea).
-- ---------------------------------------------------------------------
create or replace function public._recalcular_recibido_oc(p_oc bigint)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    r        record;
    l        record;
    v_rest   numeric;
    v_asig   numeric;
    v_estatus text;
begin
    if p_oc is null then return; end if;

    for r in
        select ocd.producto_id,
               coalesce((select sum(dd.cantidad)
                           from public.documento_detalles dd
                           join public.documentos d on d.id = dd.documento_id
                          where d.orden_compra_id = p_oc
                            and d.tipo_movimiento in ('entrada_compra', 'entrada')
                            and coalesce(d.estado, '') <> 'cancelado'
                            and dd.producto_id = ocd.producto_id), 0) as recibido
          from public.ordenes_compra_detalle ocd
         where ocd.orden_compra_id = p_oc and ocd.producto_id is not null
         group by ocd.producto_id
    loop
        v_rest := r.recibido;
        for l in
            select id, coalesce(cantidad, 0) as cantidad,
                   row_number() over (order by id) as n, count(*) over () as total
              from public.ordenes_compra_detalle
             where orden_compra_id = p_oc and producto_id = r.producto_id
             order by id
        loop
            v_asig := case when l.n = l.total then v_rest else least(v_rest, l.cantidad) end;
            update public.ordenes_compra_detalle
               set cantidad_recibida = greatest(v_asig, 0)
             where id = l.id and coalesce(cantidad_recibida, -1) is distinct from greatest(v_asig, 0);
            v_rest := v_rest - v_asig;
        end loop;
    end loop;

    select case
             when bool_and(coalesce(cantidad_recibida, 0) >= coalesce(cantidad, 0)) then 'recibida'
             when bool_and(coalesce(cantidad_recibida, 0) = 0) then 'abierta'
             else 'recibida_parcial'
           end
      into v_estatus
      from public.ordenes_compra_detalle where orden_compra_id = p_oc;

    update public.ordenes_compra
       set estatus = v_estatus
     where id = p_oc
       and v_estatus is not null
       and estatus in ('abierta', 'recibida_parcial', 'recibida')
       and estatus <> v_estatus;
end;
$$;
revoke all on function public._recalcular_recibido_oc(bigint) from public;


-- ---------------------------------------------------------------------
-- 2b. Candado: no recibir más de lo pedido en la OC (por producto).
-- ---------------------------------------------------------------------
create or replace function public._candado_recibo_no_excede_oc()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc      public.documentos%rowtype;
    v_pedido   numeric;
    v_recibido numeric;
    v_prod     text;
    v_folio    text;
begin
    if NEW.producto_id is null then return NEW; end if;
    if TG_OP = 'UPDATE' and coalesce(NEW.cantidad, 0) <= coalesce(OLD.cantidad, 0) then return NEW; end if;

    select * into v_doc from public.documentos where id = NEW.documento_id;
    if not found or v_doc.orden_compra_id is null
       or coalesce(v_doc.tipo_movimiento, '') not in ('entrada_compra', 'entrada')
       or coalesce(v_doc.estado, '') = 'cancelado' then
        return NEW;
    end if;

    select sum(coalesce(cantidad, 0)) into v_pedido
      from public.ordenes_compra_detalle
     where orden_compra_id = v_doc.orden_compra_id and producto_id = NEW.producto_id;
    if v_pedido is null then return NEW; end if;   -- producto fuera de la OC: no aplica

    select coalesce(sum(dd.cantidad), 0) into v_recibido
      from public.documento_detalles dd
      join public.documentos d on d.id = dd.documento_id
     where d.orden_compra_id = v_doc.orden_compra_id
       and d.tipo_movimiento in ('entrada_compra', 'entrada')
       and coalesce(d.estado, '') <> 'cancelado'
       and dd.producto_id = NEW.producto_id
       and dd.id is distinct from NEW.id;

    if v_recibido + coalesce(NEW.cantidad, 0) > v_pedido + 0.0005 then
        select nombre into v_prod from public.productos where id = NEW.producto_id;
        select folio into v_folio from public.ordenes_compra where id = v_doc.orden_compra_id;
        raise exception E'No se puede recibir % de "%": la orden % pidió % y ya se recibieron %.\nSi de verdad llegó de más, primero ajusta la cantidad de la orden de compra; si es una recepción repetida, no la vuelvas a capturar.',
            NEW.cantidad, coalesce(v_prod, NEW.producto_id::text), coalesce(v_folio, v_doc.orden_compra_id::text),
            v_pedido, v_recibido;
    end if;
    return NEW;
end;
$$;

drop trigger if exists trg_candado_recibo_no_excede_oc on public.documento_detalles;
create trigger trg_candado_recibo_no_excede_oc
    before insert or update of cantidad, producto_id on public.documento_detalles
    for each row execute function public._candado_recibo_no_excede_oc();


-- ---------------------------------------------------------------------
-- 2c. Recalcular cantidad_recibida cuando cambia una recepción.
-- ---------------------------------------------------------------------
create or replace function public._sync_recibido_oc_detalle()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_oc bigint;
begin
    select orden_compra_id into v_oc
      from public.documentos where id = coalesce(NEW.documento_id, OLD.documento_id);
    perform public._recalcular_recibido_oc(v_oc);
    return null;
end;
$$;

drop trigger if exists trg_sync_recibido_oc_detalle on public.documento_detalles;
create trigger trg_sync_recibido_oc_detalle
    after insert or update of cantidad, producto_id or delete on public.documento_detalles
    for each row execute function public._sync_recibido_oc_detalle();

create or replace function public._sync_recibido_oc_documento()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if NEW.orden_compra_id is not null then
        perform public._recalcular_recibido_oc(NEW.orden_compra_id);
    end if;
    return null;
end;
$$;

drop trigger if exists trg_sync_recibido_oc_documento on public.documentos;
create trigger trg_sync_recibido_oc_documento
    after update of estado on public.documentos
    for each row when (OLD.estado is distinct from NEW.estado)
    execute function public._sync_recibido_oc_documento();


-- ---------------------------------------------------------------------
-- 3. Cuadre kardex vs. balanza por cuenta de inventario a una fecha.
--    Misma regla que Reportes contables -> "Auxiliar de inventarios":
--    cuenta = productos.cuenta_inventario_id, si no 115.04 (producto) /
--    115.01 (lo demás); valor del kardex = cantidad × costo_unitario.
-- ---------------------------------------------------------------------
create or replace function public.cuadre_inventario_contable(p_hasta date)
returns table (cuenta_id bigint, codigo text, nombre text, kardex numeric, balanza numeric, diferencia numeric)
language sql
stable
security definer
set search_path = public, extensions
as $$
    with c as (
        select (select id from public.cuentas_contables where codigo = '115.01') as c01,
               (select id from public.cuentas_contables where codigo = '115.04') as c04
    ),
    prod as (
        select p.id, coalesce(p.cuenta_inventario_id, case when p.tipo = 'producto' then c.c04 else c.c01 end) as cta
          from public.productos p cross join c
    ),
    kx as (
        select pr.cta, sum(coalesce(mi.cantidad, 0) * coalesce(mi.costo_unitario, 0)) as valor
          from public.movimientos_inventario mi
          join prod pr on pr.id = mi.producto_id
         where mi.created_at < ((p_hasta + 1)::timestamp at time zone 'America/Mexico_City')
         group by pr.cta
    ),
    bz as (
        select pm.cuenta_id as cta, sum(coalesce(pm.cargo, 0) - coalesce(pm.abono, 0)) as neto
          from public.poliza_movimientos pm
          join public.polizas p on p.id = pm.poliza_id
         where p.fecha <= p_hasta
           and pm.cuenta_id in (select distinct cta from prod where cta is not null)
           and public.poliza_en_saldo(p.id)
         group by pm.cuenta_id
    )
    select cc.id, cc.codigo::text, cc.nombre::text,
           round(coalesce(kx.valor, 0), 2),
           round(coalesce(bz.neto, 0) * case when cc.naturaleza = 'A' then -1 else 1 end, 2),
           round(coalesce(bz.neto, 0) * case when cc.naturaleza = 'A' then -1 else 1 end - coalesce(kx.valor, 0), 2)
      from public.cuentas_contables cc
      left join kx on kx.cta = cc.id
      left join bz on bz.cta = cc.id
     where cc.id in (select distinct cta from prod where cta is not null);
$$;
revoke all     on function public.cuadre_inventario_contable(date) from public;
grant  execute on function public.cuadre_inventario_contable(date) to authenticated;


-- ---------------------------------------------------------------------
-- 4. Candado de cierre: inventario descuadrado contra la balanza.
--    Se agrega en precierre y cerrar_periodo_contable sin tocar
--    _candados_cierre_periodo (sigue siendo el de 2026-10-03).
-- ---------------------------------------------------------------------
create or replace function public._candado_cuadre_inventario(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_hasta   date := (make_date(p_anio, p_mes, 1) + interval '1 month' - interval '1 day')::date;
    v_cant    integer;
    v_detalle jsonb;
begin
    select count(*), coalesce(jsonb_agg(jsonb_build_object(
                'cuenta', q.codigo || ' ' || q.nombre, 'kardex', q.kardex,
                'balanza', q.balanza, 'diferencia', q.diferencia) order by q.codigo), '[]'::jsonb)
      into v_cant, v_detalle
      from public.cuadre_inventario_contable(v_hasta) q
     where abs(q.diferencia) >= 0.5;
    if v_cant > 0 then
        return jsonb_build_array(jsonb_build_object(
            'motivo', 'inventario_descuadrado',
            'descripcion', v_cant || ' cuenta(s) de inventario no cuadran contra el kardex valorizado al ' || v_hasta
                || '. Revisa Reportes contables -> "Auxiliar de inventarios (valorizado)".',
            'cantidad', v_cant, 'detalle', v_detalle));
    end if;
    return '[]'::jsonb;
end;
$$;
revoke all     on function public._candado_cuadre_inventario(integer, integer) from public;
grant  execute on function public._candado_cuadre_inventario(integer, integer) to authenticated;

create or replace function public.precierre_periodo_contable(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_candados jsonb;
begin
    if p_mes not between 1 and 12 then raise exception 'Mes inválido: %.', p_mes; end if;

    v_candados := public._candados_cierre_periodo(p_anio, p_mes)
               || public._candado_cuadre_inventario(p_anio, p_mes);

    return jsonb_build_object(
        'anio', p_anio, 'mes', p_mes,
        'listo_para_cerrar', (jsonb_array_length(v_candados) = 0),
        'candados', v_candados
    );
end;
$$;
revoke all     on function public.precierre_periodo_contable(integer, integer) from public;
grant  execute on function public.precierre_periodo_contable(integer, integer) to authenticated;

create or replace function public.cerrar_periodo_contable(p_anio integer, p_mes integer, p_forzar boolean default false)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_id       bigint;
    v_candados jsonb;
    v_detalle_txt text;
begin
    if p_mes not between 1 and 12 then raise exception 'Mes inválido: %.', p_mes; end if;
    if p_anio < 2000 then raise exception 'Año inválido: %.', p_anio; end if;

    v_candados := public._candados_cierre_periodo(p_anio, p_mes)
               || public._candado_cuadre_inventario(p_anio, p_mes);

    if jsonb_array_length(v_candados) > 0 and not p_forzar then
        select string_agg('· ' || (c->>'descripcion'), E'\n')
          into v_detalle_txt
          from jsonb_array_elements(v_candados) c;

        raise exception E'No se puede cerrar el periodo %-%: hay % pendiente(s) contable(s).\n%\n\nSi de verdad necesitas cerrarlo así, llama cerrar_periodo_contable(%, %, true) — los pendientes ignorados quedan guardados y en la bitácora.',
            p_anio, lpad(p_mes::text, 2, '0'), jsonb_array_length(v_candados), v_detalle_txt, p_anio, p_mes;
    end if;

    insert into public.periodos_contables (anio, mes, cerrado, cerrado_por, cerrado_at, advertencias_forzadas)
    values (p_anio, p_mes, true, auth.uid(), now(), case when p_forzar then v_candados else null end)
    on conflict (anio, mes) do update
        set cerrado = true, cerrado_por = auth.uid(), cerrado_at = now(),
            advertencias_forzadas = case when p_forzar then v_candados else null end
    returning id into v_id;

    return jsonb_build_object(
        'periodo_id', v_id, 'anio', p_anio, 'mes', p_mes, 'cerrado', true,
        'forzado', p_forzar,
        'candados_ignorados', case when p_forzar then v_candados else '[]'::jsonb end
    );
end;
$$;
revoke all     on function public.cerrar_periodo_contable(integer, integer, boolean) from public;
grant  execute on function public.cerrar_periodo_contable(integer, integer, boolean) to authenticated;

commit;
