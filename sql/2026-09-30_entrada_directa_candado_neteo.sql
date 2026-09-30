-- =====================================================================
--  Entrada Directa: candado anti-neteo + default correcto de cuenta de
--  inventario por tipo de producto.
--  Fecha: 2026-09-30  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Bug reportado (Póliza Diario #24, documento #46, ENT-000001): la
--  pantalla de "Entrada directa" deja elegir como "Cuenta de contrapartida
--  (abono)" cualquier cuenta del catálogo, incluida la MISMA cuenta de
--  inventario que ya se va a cargar. `registrar_poliza` solo valida que
--  el TOTAL de cargos = TOTAL de abonos, no por cuenta — así que una
--  póliza con Cargo 115.01 / Abono 115.01 por el mismo importe "cuadra"
--  pero no mueve nada de verdad (efecto neto cero).
--
--  1. contabilizar_entrada_directa: ahora truena ANTES de crear la póliza
--     si la cuenta de contrapartida coincide con alguna de las cuentas de
--     inventario que esta misma entrada va a cargar.
--  2. _inv_por_cuenta (compartida por entrada directa, salidas y ventas):
--     si el producto no tiene cuenta_inventario_id capturada, el default
--     ya no es SIEMPRE 115.01 (Materia prima) — ahora depende del tipo:
--     'producto' -> 115.04 (Productos terminados), 'semiterminado' ->
--     115.02 (Productos en proceso), cualquier otro -> 115.01, igual que
--     ya hace contabilizar_produccion() para el mismo caso.
--
--  Idempotente (create or replace function).
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. _inv_por_cuenta — default de cuenta por tipo de producto
-- ---------------------------------------------------------------------
create or replace function public._inv_por_cuenta(p_documento_id bigint)
returns jsonb
language sql stable
set search_path = public
as $$
    select coalesce(jsonb_agg(jsonb_build_object('cuenta_id', cta_id, 'monto', monto)), '[]'::jsonb)
    from (
        select coalesce(
                   pr.cuenta_inventario_id,
                   case pr.tipo
                       when 'producto'      then public._cuenta_id('115.04')
                       when 'semiterminado' then public._cuenta_id('115.02')
                       else public._cuenta_id('115.01')
                   end
               ) as cta_id,
               round(sum(dd.subtotal), 2) as monto
        from public.documento_detalles dd
        left join public.productos pr on pr.id = dd.producto_id
        where dd.documento_id = p_documento_id
        group by 1
    ) t
$$;

-- ---------------------------------------------------------------------
-- 2. contabilizar_entrada_directa — candado anti-neteo
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_entrada_directa(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc     public.documentos%rowtype;
    v_abono   bigint := (p_datos->>'cuenta_abono_id')::bigint;
    v_inv     jsonb  := public._inv_por_cuenta(p_documento_id);
    v_total   numeric(14,2) := 0;
    v_movs    jsonb  := '[]'::jsonb;
    v_cuenta  public.cuentas_contables%rowtype;
    r         jsonb;
    v_pid     bigint;
    v_choca   text;
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Este documento ya esta contabilizado (poliza %).', v_doc.poliza_id; end if;
    if v_doc.tipo_movimiento <> 'entrada' then
        raise exception 'contabilizar_entrada_directa solo aplica a entradas directas (tipo actual: %).', v_doc.tipo_movimiento;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_abono;
    if not found then raise exception 'Selecciona la cuenta de contrapartida (abono).'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;

    -- Candado anti-neteo: la contrapartida no puede ser la misma cuenta de
    -- inventario que esta entrada va a cargar (cargo = abono en la misma
    -- cuenta = efecto neto cero, aunque la poliza "cuadre" en total).
    select cc.codigo || ' · ' || cc.nombre
      into v_choca
      from jsonb_array_elements(v_inv) x
      join public.cuentas_contables cc on cc.id = (x->>'cuenta_id')::bigint
     where (x->>'cuenta_id')::bigint = v_abono
     limit 1;
    if v_choca is not null then
        raise exception 'La cuenta de contrapartida no puede ser "%" — es la MISMA cuenta de inventario que esta entrada va a cargar; cargo y abono se neutralizarian entre si sin efecto contable real. Elige otra cuenta (capital, otros ingresos, proveedores, etc.).', v_choca;
    end if;

    for r in select * from jsonb_array_elements(v_inv)
    loop
        v_total := v_total + (r->>'monto')::numeric;
        v_movs  := v_movs || jsonb_build_object('cuenta_id', (r->>'cuenta_id')::bigint, 'cargo', (r->>'monto')::numeric, 'concepto', 'Entrada inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_total <= 0 then raise exception 'La entrada no tiene costo (revisa los costos de las partidas).'; end if;

    v_movs := v_movs || jsonb_build_object('cuenta_id', v_abono, 'abono', v_total, 'concepto',
        coalesce(v_doc.descripcion, 'Entrada directa') || ' ' || coalesce(v_doc.folio, ''));

    v_pid := (public.registrar_poliza(jsonb_build_object(
        'fecha', coalesce(v_doc.fecha_emision::date, current_date),
        'tipo', 'Diario',
        'concepto', 'Entrada directa ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.descripcion, ''),
        'folio', v_doc.folio,
        'origen', 'entrada', 'origen_tabla', 'documentos', 'origen_id', p_documento_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.documentos set poliza_id = v_pid, total = v_total where id = p_documento_id;
    return jsonb_build_object('poliza_id', v_pid, 'total', v_total);
end;
$$;

commit;
