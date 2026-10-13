-- =====================================================================
--  Series para TODAS las pólizas (catálogo aprobado por el usuario 2026-10-13).
--  Fecha: 2026-10-13  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere (ya corrida): 2026-10-07d_polizas_series_y_visto_bueno.sql
--  (contadores_folios_poliza, _siguiente_folio_poliza, polizas.folio_poliza).
--
--  Qué hace:
--   1. Tabla polizas_series_origen: a cada "origen" de póliza (gasto, nómina,
--      venta, depreciación...) le asigna su serie de 3 letras. Editable desde
--      el SQL Editor sin tocar código.
--   2. Reescribe registrar_poliza() (cuerpo completo, copia de la versión de
--      2026-10-07d) con UN cambio: si quien la llama NO manda 'serie', la
--      toma de esa tabla según el 'origen'. Las 13 funciones que crean pólizas
--      NO se tocan; las que ya mandan su serie (BAN, VAE, ING, CMP, REC) siguen
--      igual, y cancelar_poliza() sigue poniendo DIA directo.
--
--  Efecto: SOLO las pólizas nuevas llevan serie (SERIE-AÑO-00001). Las viejas
--  se quedan como "Diario No. 28" (no se renumeran). No cambia ningún asiento,
--  saldo ni reporte: es solo la etiqueta.
--
--  Origen 'ajuste' (lo usa registrar_deterioro_inventario) queda SIN serie a
--  propósito: también lo usan reclasificaciones manuales; dar DET al deterioro
--  requiere una línea en esa función (pendiente).
--
--  Idempotente.
-- =====================================================================

begin;

create table if not exists public.polizas_series_origen (
    origen text primary key,
    serie  text not null check (serie ~ '^[A-Z]{2,8}$'),
    que_es text
);

alter table public.polizas_series_origen enable row level security;
drop policy if exists solo_lectura on public.polizas_series_origen;
create policy solo_lectura on public.polizas_series_origen for select to authenticated using (true);
revoke all    on public.polizas_series_origen from anon, authenticated;
grant  select on public.polizas_series_origen to authenticated;

insert into public.polizas_series_origen (origen, serie, que_es) values
    ('compra',               'REC', 'Recepción de mercancía (con o sin ODC)'),
    ('produccion',           'CMP', 'Consumo de materia prima al cerrar una orden de producción'),
    ('gasto',                'GAS', 'Gasto'),
    ('nomina',               'NOM', 'Nómina'),
    ('depreciacion',         'DEP', 'Depreciación mensual de activos fijos'),
    ('venta',                'VEN', 'Venta'),
    ('salida',               'SMA', 'Salida de inventario por merma o ajuste'),
    ('entrada',              'EDI', 'Entrada directa de inventario'),
    ('devolucion_cliente',   'DVC', 'Devolución de cliente'),
    ('devolucion_proveedor', 'DVP', 'Devolución a proveedor'),
    ('prorrateo',            'PRR', 'Prorrateo de costos indirectos a producción'),
    ('anticipo_reembolso',   'RAN', 'Resolución de anticipo: reembolso del proveedor'),
    ('anticipo_baja',        'RAN', 'Resolución de anticipo: baja (pérdida)'),
    ('cobro',                'ING', 'Cobro a cliente'),
    ('pago',                 'BAN', 'Pago a proveedor (BAN si es banco, VAE si es caja: lo manda la función de pago)'),
    ('manual',               'MAN', 'Póliza capturada a mano')
on conflict (origen) do update set serie = excluded.serie, que_es = excluded.que_es;


-- ---------------------------------------------------------------------
-- registrar_poliza(): cuerpo COMPLETO (versión de 2026-10-07d) + serie por
-- origen cuando la función que la llama no manda 'serie'.
-- ---------------------------------------------------------------------
create or replace function public.registrar_poliza(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_fecha     date := (p_datos->>'fecha')::date;
    v_tipo      text := coalesce(nullif(trim(p_datos->>'tipo'), ''), 'Diario');
    v_concepto  text := nullif(trim(p_datos->>'concepto'), '');
    v_movs      jsonb := coalesce(p_datos->'movimientos', '[]'::jsonb);
    v_sum_cargo numeric(14,2) := 0;
    v_sum_abono numeric(14,2) := 0;
    v_numero    int;
    v_poliza_id bigint;
    v_cargo     numeric(14,2);
    v_abono     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_i         int := 0;
    r           jsonb;
    v_origen    text := coalesce(nullif(trim(p_datos->>'origen'), ''), 'manual');
    -- 'serie' explícita manda; si no viene, se toma de polizas_series_origen según el origen.
    v_serie     text := coalesce(
                            nullif(upper(trim(coalesce(p_datos->>'serie', ''))), ''),
                            (select s.serie from public.polizas_series_origen s where s.origen = coalesce(nullif(trim(p_datos->>'origen'), ''), 'manual')));
    v_folio_pol text;
begin
    if v_fecha is null then raise exception 'La fecha de la poliza es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto de la poliza es obligatorio.'; end if;
    if v_tipo not in ('Ingreso','Egreso','Diario') then raise exception 'Tipo de poliza invalido: %', v_tipo; end if;
    if jsonb_array_length(v_movs) < 2 then raise exception 'La poliza necesita al menos 2 movimientos.'; end if;

    perform public._verificar_periodo_abierto(v_fecha);

    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        v_cargo := round(coalesce((r->>'cargo')::numeric, 0), 2);
        v_abono := round(coalesce((r->>'abono')::numeric, 0), 2);

        if v_cargo < 0 or v_abono < 0 then
            raise exception 'Renglon %: cargo y abono no pueden ser negativos. cargo=%, abono=%, movimiento=%', v_i, v_cargo, v_abono, r;
        end if;
        if (v_cargo > 0 and v_abono > 0) or (v_cargo = 0 and v_abono = 0) then
            raise exception 'Renglon %: pon importe en cargo O en abono (no ambos, no ninguno). cargo=%, abono=%, movimiento=%', v_i, v_cargo, v_abono, r;
        end if;

        select * into v_cuenta from public.cuentas_contables where id = (r->>'cuenta_id')::bigint;
        if not found then raise exception 'Renglon %: la cuenta indicada no existe.', v_i; end if;
        if not v_cuenta.afectable then
            raise exception 'Renglon %: la cuenta % (%) es de mayor y no acepta movimientos.', v_i, v_cuenta.codigo, v_cuenta.nombre;
        end if;
        if not v_cuenta.activa then
            raise exception 'Renglon %: la cuenta % esta inactiva.', v_i, v_cuenta.codigo;
        end if;

        v_sum_cargo := v_sum_cargo + v_cargo;
        v_sum_abono := v_sum_abono + v_abono;
    end loop;

    if v_sum_cargo <> v_sum_abono then
        raise exception 'La poliza no cuadra: cargos %  vs  abonos %.', v_sum_cargo, v_sum_abono;
    end if;
    if v_sum_cargo = 0 then
        raise exception 'La poliza no puede sumar cero.';
    end if;

    v_numero := public._siguiente_numero_poliza(v_tipo, v_fecha);
    if v_serie is not null then
        v_folio_pol := public._siguiente_folio_poliza(v_serie, v_fecha);
    end if;

    insert into public.polizas
        (fecha, tipo, numero, concepto, folio, origen, origen_tabla, origen_id, moneda_id, tipo_cambio, folio_poliza)
    values (
        v_fecha, v_tipo, v_numero, v_concepto,
        nullif(trim(p_datos->>'folio'), ''),
        v_origen,
        nullif(trim(p_datos->>'origen_tabla'), ''),
        (p_datos->>'origen_id')::bigint,
        (p_datos->>'moneda_id')::bigint,
        coalesce((p_datos->>'tipo_cambio')::numeric, 1),
        v_folio_pol
    )
    returning id into v_poliza_id;

    v_i := 0;
    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        insert into public.poliza_movimientos
            (poliza_id, orden, cuenta_id, cargo, abono, concepto, proveedor_id, cliente_id,
             tercero_rfc, tercero_nombre, uuid_cfdi, forma_pago, metodo_pago)
        values (
            v_poliza_id, v_i, (r->>'cuenta_id')::bigint,
            round(coalesce((r->>'cargo')::numeric, 0), 2),
            round(coalesce((r->>'abono')::numeric, 0), 2),
            nullif(trim(r->>'concepto'), ''),
            (r->>'proveedor_id')::bigint,
            (r->>'cliente_id')::bigint,
            nullif(trim(r->>'tercero_rfc'), ''),
            nullif(trim(r->>'tercero_nombre'), ''),
            nullif(trim(r->>'uuid_cfdi'), ''),
            nullif(trim(r->>'forma_pago'), ''),
            nullif(trim(r->>'metodo_pago'), '')
        );
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'numero', v_numero, 'folio_poliza', v_folio_pol);
end;
$$;

revoke all     on function public.registrar_poliza(jsonb) from public;
grant  execute on function public.registrar_poliza(jsonb) to authenticated;

commit;

-- Para revisar después de correrla:
--   select * from public.polizas_series_origen order by serie;
--   select folio_poliza, tipo, numero, origen from public.polizas order by id desc limit 15;
