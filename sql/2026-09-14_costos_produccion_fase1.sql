-- =====================================================================
--  Costos de producción — FASE 1: centros de costo, clasificación de
--  gastos (directo / indirecto / no producción), CIF fijo vs variable
--  Fecha: 2026-09-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-08-28_contabilidad_cuentas.sql,
--            sql/2026-08-28_contabilidad_gastos.sql
--
--  Contexto: hoy el costo de producción es materiales (FIFO) + mano de
--  obra (horas x sueldo). Falta la 3a pata: los GASTOS INDIRECTOS DE
--  FABRICACIÓN (CIF) — renta de planta, energía, mantenimiento,
--  depreciación de equipo, supervisión, insumos indirectos — y su
--  prorrateo a las órdenes.
--
--  Esta fase NO prorratea todavía (eso es la Fase 2). Solo deja:
--    1. public.centros_costo  — catálogo con la CAPACIDAD NORMAL en
--       horas de mano de obra al mes (con las variables del cálculo
--       sugerido) y el método de CIF (real | predeterminado).
--    2. cuentas_contables.cif_tipo  = 'fijo' | 'variable' | null
--       (solo relevante en las cuentas 503.xx de CIF).
--    3. Bloque de cuentas 503.xx (Gastos indirectos de fabricación) +
--       503.98 (Costo de capacidad no utilizada) si no existen.
--       115.03 (Producción en proceso) ya existe.
--    4. gastos + centro_costo_id, clasificacion, cif_tipo (override),
--       orden_produccion_id, prorrateo_estatus.
--    5. registrar_gasto ampliado para capturar y guardar esos campos.
--
--  Método de capacidad NORMAL (sin histórico): se estima "de la nómina
--  hacia abajo" —  operadores x horas de jornada x días hábiles del mes,
--  menos ausentismo (~10%), tiempo no productivo (~20%) y paros
--  planeados (~4%). La vista v_centros_costo devuelve ese cálculo como
--  'capacidad_sugerida_horas' al lado de la que se usa realmente
--  (capacidad_normal_horas, editable por el usuario).
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. cuentas_contables.cif_tipo
-- ---------------------------------------------------------------------
alter table public.cuentas_contables
    add column if not exists cif_tipo text
        check (cif_tipo is null or cif_tipo in ('fijo', 'variable'));

comment on column public.cuentas_contables.cif_tipo is
  'Solo en cuentas de gasto indirecto de fabricación (503.xx): fijo = no varía con el volumen (renta, depreciación, supervisión), variable = varía (energía, insumos indirectos, mantenimiento por uso).';


-- ---------------------------------------------------------------------
-- 2. Bloque de cuentas CIF (solo las que falten)
--    tipo 'costo', naturaleza 'D'. El mayor 503 y el detalle 503.xx.
-- ---------------------------------------------------------------------
insert into public.cuentas_contables (codigo, nombre, codigo_agrupador, naturaleza, tipo, nivel, afectable)
select v.codigo, v.nombre, v.codigo, v.naturaleza, v.tipo, v.nivel, v.afectable
from (values
    ('503',    'Gastos indirectos de fabricación',        'D', 'costo', 1, false),
    ('503.01', 'Energía eléctrica de planta',             'D', 'costo', 2, true),
    ('503.02', 'Mano de obra indirecta y supervisión',    'D', 'costo', 2, true),
    ('503.03', 'Mantenimiento de planta y equipo',        'D', 'costo', 2, true),
    ('503.04', 'Depreciación de maquinaria y equipo',     'D', 'costo', 2, true),
    ('503.05', 'Renta de nave industrial',                'D', 'costo', 2, true),
    ('503.06', 'Materiales e insumos indirectos',         'D', 'costo', 2, true),
    ('503.07', 'Servicios de planta (agua, gas)',         'D', 'costo', 2, true),
    ('503.08', 'Seguros y vigilancia de planta',          'D', 'costo', 2, true),
    ('503.98', 'Costo de capacidad no utilizada',         'D', 'costo', 2, true),
    ('503.99', 'Otros gastos indirectos de fabricación',  'D', 'costo', 2, true)
) as v(codigo, nombre, naturaleza, tipo, nivel, afectable)
where not exists (select 1 from public.cuentas_contables c where c.codigo = v.codigo);

-- enlazar el detalle 503.xx a su mayor 503
update public.cuentas_contables c
set cuenta_padre_id = p.id
from public.cuentas_contables p
where c.nivel = 2 and c.cuenta_padre_id is null
  and p.nivel = 1 and p.codigo = split_part(c.codigo, '.', 1)
  and c.codigo like '503.%';

-- marcar fijo / variable (503.98 se deja en null: es el sumidero a resultados,
-- no una fuente de CIF)
update public.cuentas_contables set cif_tipo = 'variable'
 where codigo in ('503.01','503.03','503.06','503.07','503.99') and cif_tipo is null;
update public.cuentas_contables set cif_tipo = 'fijo'
 where codigo in ('503.02','503.04','503.05','503.08') and cif_tipo is null;

comment on table public.cuentas_contables is
  'Plan de cuentas (Código Agrupador SAT). 503.xx = gastos indirectos de fabricación (ver cif_tipo). 503.98 = costo de capacidad no utilizada, va a resultados del periodo, NO a inventario.';


-- ---------------------------------------------------------------------
-- 3. centros_costo
-- ---------------------------------------------------------------------
create table if not exists public.centros_costo (
    id                        bigint generated always as identity primary key,
    codigo                    text    not null unique,
    nombre                    text    not null,
    tipo                      text    not null default 'produccion'
                              check (tipo in ('produccion','servicio','administracion','ventas')),
    cuenta_cif_default_id     bigint  references public.cuentas_contables(id) on delete set null,

    -- capacidad NORMAL en horas de mano de obra al mes (la que se usa)
    capacidad_normal_horas    numeric(12,2) not null default 0 check (capacidad_normal_horas >= 0),

    -- variables del cálculo SUGERIDO (de la nómina hacia abajo)
    cap_operadores            smallint       default 0  check (cap_operadores is null or cap_operadores >= 0),
    cap_horas_jornada         numeric(4,1)   default 8  check (cap_horas_jornada is null or cap_horas_jornada > 0),
    cap_dias_habiles_mes      smallint       default 24 check (cap_dias_habiles_mes is null or cap_dias_habiles_mes between 1 and 31),
    cap_factor_ausentismo     numeric(4,3)   default 0.90 check (cap_factor_ausentismo between 0 and 1),
    cap_factor_no_productivo  numeric(4,3)   default 0.80 check (cap_factor_no_productivo between 0 and 1),
    cap_factor_paros_planeados numeric(4,3)  default 0.96 check (cap_factor_paros_planeados between 0 and 1),

    -- método de aplicación del CIF
    metodo_cif                text    not null default 'real' check (metodo_cif in ('real','predeterminado')),
    tasa_cif_hora             numeric(14,4),           -- solo si metodo_cif = 'predeterminado'

    activo                    boolean not null default true,
    notas                     text,
    created_at                timestamptz not null default now()
);

alter table public.centros_costo enable row level security;
drop policy if exists admin_all on public.centros_costo;
create policy admin_all on public.centros_costo for all to authenticated using (true) with check (true);
grant all on public.centros_costo to authenticated;

comment on table public.centros_costo is
  'Áreas para acumular y prorratear gastos. capacidad_normal_horas = horas de mano de obra que la planta produce en un mes normal (no la máxima, no la de un mes malo). metodo_cif real = se prorratea el CIF real a fin de mes; predeterminado = se aplica tasa_cif_hora al cerrar cada orden y se concilia después.';

-- vista con el cálculo sugerido de capacidad
create or replace view public.v_centros_costo as
select cc.*,
       round(
           coalesce(cc.cap_operadores, 0)::numeric
         * coalesce(cc.cap_horas_jornada, 8)
         * coalesce(cc.cap_dias_habiles_mes, 24)
         * coalesce(cc.cap_factor_ausentismo, 0.90)
         * coalesce(cc.cap_factor_no_productivo, 0.80)
         * coalesce(cc.cap_factor_paros_planeados, 0.96)
       , 2) as capacidad_sugerida_horas
from public.centros_costo cc;

grant select on public.v_centros_costo to authenticated;

-- semilla: un centro de costo de Producción (capacidad en 0 -> el usuario
-- la captura o usa el sugerido cuando llene las variables)
insert into public.centros_costo (codigo, nombre, tipo, cuenta_cif_default_id, metodo_cif)
select 'PROD', 'Producción', 'produccion',
       (select id from public.cuentas_contables where codigo = '503.99'),
       'real'
where not exists (select 1 from public.centros_costo);


-- ---------------------------------------------------------------------
-- 4. gastos + columnas de costeo
-- ---------------------------------------------------------------------
alter table public.gastos
    add column if not exists centro_costo_id     bigint references public.centros_costo(id) on delete set null,
    add column if not exists clasificacion       text not null default 'no_produccion'
        check (clasificacion in ('directo_produccion','indirecto_produccion','no_produccion')),
    add column if not exists cif_tipo            text
        check (cif_tipo is null or cif_tipo in ('fijo','variable')),
    add column if not exists orden_produccion_id bigint references public.ordenes_produccion(id) on delete set null,
    add column if not exists prorrateo_estatus   text not null default 'no_aplica'
        check (prorrateo_estatus in ('no_aplica','pendiente','prorrateado'));

create index if not exists idx_gastos_clasificacion on public.gastos(clasificacion);
create index if not exists idx_gastos_prorrateo     on public.gastos(prorrateo_estatus) where prorrateo_estatus = 'pendiente';

comment on column public.gastos.clasificacion is
  'directo_produccion = se carga completo a una orden (orden_produccion_id). indirecto_produccion = CIF, se prorratea (Fase 2). no_produccion = admin/venta/financiero, sin efecto en costo de producción.';


-- ---------------------------------------------------------------------
-- 5. registrar_gasto — captura y guarda los campos de costeo
--    (misma póliza de Egreso que antes; el ruteo contable del directo /
--    indirecto se afina en la Fase 3)
-- ---------------------------------------------------------------------
create or replace function public.registrar_gasto(p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_fecha     date          := (p_datos->>'fecha')::date;
    v_concepto  text          := nullif(trim(p_datos->>'concepto'), '');
    v_prov      bigint        := (p_datos->>'proveedor_id')::bigint;
    v_cta_gasto bigint        := (p_datos->>'cuenta_gasto_id')::bigint;
    v_subtotal  numeric(14,2) := round(coalesce((p_datos->>'subtotal')::numeric, 0), 2);
    v_iva       numeric(14,2) := round(coalesce((p_datos->>'iva')::numeric, 0), 2);
    v_ieps      numeric(14,2) := round(coalesce((p_datos->>'ieps')::numeric, 0), 2);
    v_ret_iva   numeric(14,2) := round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2);
    v_ret_isr   numeric(14,2) := round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2);
    v_condicion text          := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'contado');
    v_cta_pago  bigint        := (p_datos->>'cuenta_pago_id')::bigint;

    v_centro    bigint        := (p_datos->>'centro_costo_id')::bigint;
    v_clasif    text          := coalesce(nullif(trim(p_datos->>'clasificacion'), ''), 'no_produccion');
    v_cif_tipo  text          := nullif(trim(p_datos->>'cif_tipo'), '');
    v_orden     bigint        := (p_datos->>'orden_produccion_id')::bigint;
    v_prorr     text;

    v_total     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_movs      jsonb;
    v_gasto_id  bigint;
    v_poliza_id bigint;
    v_id        bigint;
begin
    if v_fecha is null then raise exception 'La fecha del gasto es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto del gasto es obligatorio.'; end if;
    if v_subtotal <= 0 then raise exception 'El subtotal debe ser mayor a cero.'; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;
    if v_clasif not in ('directo_produccion','indirecto_produccion','no_produccion') then
        raise exception 'Clasificación inválida: %', v_clasif;
    end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_gasto;
    if not found then raise exception 'La cuenta de gasto no existe.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de gasto % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;
    if v_cuenta.tipo not in ('gasto','costo') then
        raise exception 'La cuenta % no es de gasto ni de costo.', v_cuenta.codigo;
    end if;

    -- reglas de costeo de producción
    if v_clasif = 'directo_produccion' then
        if v_orden is null then
            raise exception 'Un gasto directo de producción necesita la orden a la que se carga.';
        end if;
        if not exists (select 1 from public.ordenes_produccion o where o.id = v_orden) then
            raise exception 'La orden de producción % no existe.', v_orden;
        end if;
        v_prorr := 'no_aplica';
    elsif v_clasif = 'indirecto_produccion' then
        if v_centro is null then
            raise exception 'Un gasto indirecto de fabricación necesita un centro de costo.';
        end if;
        -- si no viene el fijo/variable, se toma de la cuenta contable
        if v_cif_tipo is null then
            v_cif_tipo := v_cuenta.cif_tipo;
        end if;
        v_prorr := 'pendiente';
        v_orden := null;   -- el indirecto no se ata a una sola orden
    else
        v_prorr := 'no_aplica';
        v_orden := null;
    end if;
    if v_cif_tipo is not null and v_cif_tipo not in ('fijo','variable') then
        raise exception 'cif_tipo inválido: %', v_cif_tipo;
    end if;

    v_total := round(v_subtotal + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden ser mayores que subtotal + impuestos.'; end if;

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco de la que sale el pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    -- ---- armar movimientos de la poliza (Egreso) ----
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_cta_gasto, 'cargo', v_subtotal, 'concepto', v_concepto)
    );

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta % (IVA acreditable).',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva, 'concepto', 'IVA acreditable');
    end if;

    if v_ieps > 0 then
        v_id := public._cuenta_id('118.03');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 118.03 (IEPS acreditable).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_ieps, 'concepto', 'IEPS acreditable');
    end if;

    if v_ret_iva > 0 then
        v_id := public._cuenta_id('216.05');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.05 (IVA retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_iva, 'concepto', 'IVA retenido');
    end if;

    if v_ret_isr > 0 then
        v_id := public._cuenta_id('216.10');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.10 (ISR retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_isr, 'concepto', 'ISR retenido');
    end if;

    if v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total, 'concepto', 'Pago ' || v_concepto);
    else
        v_id := public._cuenta_id('201.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 201.01 (Proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_total, 'concepto', 'Por pagar ' || v_concepto, 'proveedor_id', v_prov);
    end if;

    -- ---- insertar el gasto ----
    insert into public.gastos
        (fecha, concepto, proveedor_id, cuenta_gasto_id, subtotal, iva, ieps, ret_iva, ret_isr, total,
         condicion, forma_pago, cuenta_pago_id, folio_factura, uuid_cfdi, rfc_emisor, documento_id, notas,
         centro_costo_id, clasificacion, cif_tipo, orden_produccion_id, prorrateo_estatus)
    values (
        v_fecha, v_concepto, v_prov, v_cta_gasto, v_subtotal, v_iva, v_ieps, v_ret_iva, v_ret_isr, v_total,
        v_condicion,
        nullif(trim(p_datos->>'forma_pago'), ''),
        case when v_condicion = 'contado' then v_cta_pago else null end,
        nullif(trim(p_datos->>'folio_factura'), ''),
        nullif(trim(p_datos->>'uuid_cfdi'), ''),
        nullif(trim(p_datos->>'rfc_emisor'), ''),
        (p_datos->>'documento_id')::bigint,
        nullif(trim(p_datos->>'notas'), ''),
        v_centro, v_clasif, v_cif_tipo, v_orden, v_prorr
    )
    returning id into v_gasto_id;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha,
        'tipo', 'Egreso',
        'concepto', v_concepto,
        'origen', 'gasto',
        'origen_tabla', 'gastos',
        'origen_id', v_gasto_id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.gastos set poliza_id = v_poliza_id where id = v_gasto_id;

    return jsonb_build_object('gasto_id', v_gasto_id, 'poliza_id', v_poliza_id, 'total', v_total,
                              'clasificacion', v_clasif, 'prorrateo_estatus', v_prorr);
end;
$$;

revoke all     on function public.registrar_gasto(jsonb) from public;
grant  execute on function public.registrar_gasto(jsonb) to authenticated;

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select codigo, nombre, cif_tipo from public.cuentas_contables where codigo like '503%' order by codigo;
-- select * from public.v_centros_costo;
