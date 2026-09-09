-- =====================================================================
--  Costos de producción — Reparto de gastos en 2 niveles + plantillas
--  Fecha: 2026-09-18  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere: sql/2026-09-14_costos_produccion_fase1.sql
--            sql/2026-09-15_costos_produccion_fase2y3.sql
--            sql/2026-09-16_costos_centros_por_proceso.sql
--            sql/2026-09-17_areas_bases_prorrateo.sql
--
--  Modelo de 2 niveles para un gasto indirecto compartido:
--    Nivel 1  ¿cuánto es de fábrica y cuánto de oficina?  -> la parte de
--             oficina se contabiliza en su cuenta de resultados (601.xx)
--             y NO entra al prorrateo.
--    Nivel 2  la parte de fábrica, ¿cómo se divide entre SURT/MEZ/ENV?
--
--  Los % NO se teclean: se derivan de v_bases_prorrateo (m² / kW /
--  personas) declaradas en "Áreas y bases de prorrateo". Una PLANTILLA
--  dice qué base usar y a qué cuenta de resultados va la parte de
--  oficina; se fija una vez por cuenta (o por proveedor).
--
--  Al capturar el gasto, registrar_gasto resuelve la plantilla contra
--  las áreas, CONGELA los % en gasto_prorrateo_reglas (parte fábrica) y
--  en gasto_reparto_no_produccion (parte oficina), y arma UNA póliza que
--  carga la cuenta 503.xx por la parte fábrica y la 601.xx por la de
--  oficina. El motor de prorrateo (Fase 2) no cambia.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. costos_config — parámetros del módulo (umbral de materialidad, ...)
-- ---------------------------------------------------------------------
create table if not exists public.costos_config (
    clave        text primary key,
    valor        text not null,
    descripcion  text
);

insert into public.costos_config (clave, valor, descripcion) values
    ('umbral_materialidad_mxn', '2000',
     'Gastos compartidos por debajo de este monto: el asistente sugiere asignarlos completos a un rubro sin repartir. Solo es un aviso, no bloquea.')
on conflict (clave) do nothing;

alter table public.costos_config enable row level security;
drop policy if exists admin_all on public.costos_config;
create policy admin_all on public.costos_config for all to authenticated using (true) with check (true);
grant all on public.costos_config to authenticated;


-- ---------------------------------------------------------------------
-- 2. reparto_plantillas + líneas (para base 'manual')
-- ---------------------------------------------------------------------
create table if not exists public.reparto_plantillas (
    id                       bigint generated always as identity primary key,
    nombre                   text not null,
    cuenta_id                bigint references public.cuentas_contables(id) on delete cascade,
    proveedor_id             bigint references public.proveedores(id) on delete cascade,
    base                     text not null default 'm2'
                             check (base in ('m2', 'kw', 'personas', 'partes_iguales', 'manual')),
    cuenta_no_produccion_id  bigint references public.cuentas_contables(id) on delete set null,
    activo                   boolean not null default true,
    notas                    text,
    created_at               timestamptz not null default now()
);

comment on table public.reparto_plantillas is
  'Cómo se reparte un gasto compartido. base = m²/kW/personas usa v_bases_prorrateo; manual usa reparto_plantilla_lineas. cuenta_no_produccion_id: a dónde va la parte de oficina (601.xx). Resolución por especificidad: plantilla del proveedor > plantilla de la cuenta > genérica.';

create index if not exists idx_rp_cuenta on public.reparto_plantillas(cuenta_id) where cuenta_id is not null;
create index if not exists idx_rp_prov   on public.reparto_plantillas(proveedor_id) where proveedor_id is not null;

alter table public.reparto_plantillas enable row level security;
drop policy if exists admin_all on public.reparto_plantillas;
create policy admin_all on public.reparto_plantillas for all to authenticated using (true) with check (true);
grant all on public.reparto_plantillas to authenticated;

create table if not exists public.reparto_plantilla_lineas (
    id                    bigint generated always as identity primary key,
    plantilla_id          bigint not null references public.reparto_plantillas(id) on delete cascade,
    destino               text not null check (destino in ('produccion', 'no_produccion')),
    centro_costo_id       bigint references public.centros_costo(id) on delete cascade,
    cuenta_resultados_id  bigint references public.cuentas_contables(id) on delete set null,
    porcentaje            numeric(7,4) not null check (porcentaje > 0 and porcentaje <= 100)
);

alter table public.reparto_plantilla_lineas enable row level security;
drop policy if exists admin_all on public.reparto_plantilla_lineas;
create policy admin_all on public.reparto_plantilla_lineas for all to authenticated using (true) with check (true);
grant all on public.reparto_plantilla_lineas to authenticated;


-- ---------------------------------------------------------------------
-- 3. gastos — columnas de trazabilidad del reparto
-- ---------------------------------------------------------------------
alter table public.gastos
    add column if not exists monto_prorrateable    numeric(14,2),
    add column if not exists reparto_base          text,
    add column if not exists reparto_plantilla_id  bigint references public.reparto_plantillas(id) on delete set null;

comment on column public.gastos.monto_prorrateable is
  'Parte del subtotal que entró al prorrateo (subtotal - parte de no producción). NULL si el gasto no es indirecto.';


-- ---------------------------------------------------------------------
-- 4. gasto_reparto_no_produccion — desglose de la parte de oficina
-- ---------------------------------------------------------------------
create table if not exists public.gasto_reparto_no_produccion (
    id         bigint generated always as identity primary key,
    gasto_id   bigint not null references public.gastos(id) on delete cascade,
    cuenta_id  bigint not null references public.cuentas_contables(id) on delete restrict,
    area_id    bigint references public.areas_fisicas(id) on delete set null,
    monto      numeric(14,2) not null
);
create index if not exists idx_grnp_gasto on public.gasto_reparto_no_produccion(gasto_id);

alter table public.gasto_reparto_no_produccion enable row level security;
drop policy if exists admin_all on public.gasto_reparto_no_produccion;
create policy admin_all on public.gasto_reparto_no_produccion for all to authenticated using (true) with check (true);
grant all on public.gasto_reparto_no_produccion to authenticated;


-- ---------------------------------------------------------------------
-- 5. _reparto_resolver — resuelve una plantilla contra las áreas
--    Devuelve filas: parte producción (una por centro) + parte no
--    producción (una por cuenta). monto = round(subtotal * fracción, 2).
-- ---------------------------------------------------------------------
create or replace function public._reparto_resolver(p_plantilla_id bigint, p_subtotal numeric)
returns table (destino text, centro_costo_id bigint, cuenta_id bigint, porcentaje numeric, monto numeric)
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
    v_pl public.reparto_plantillas%rowtype;
begin
    select * into v_pl from public.reparto_plantillas where id = p_plantilla_id and activo;
    if not found then
        raise exception 'La plantilla de reparto % no existe o está inactiva.', p_plantilla_id;
    end if;

    if v_pl.base = 'manual' then
        return query
        select l.destino,
               l.centro_costo_id,
               coalesce(l.cuenta_resultados_id, v_pl.cuenta_no_produccion_id),
               l.porcentaje::numeric,
               round(p_subtotal * l.porcentaje / 100.0, 2)
        from public.reparto_plantilla_lineas l
        where l.plantilla_id = p_plantilla_id;
        return;
    end if;

    if v_pl.base = 'partes_iguales' then
        return query
        with cc as (select c.id from public.centros_costo c where c.tipo = 'produccion' and c.activo)
        select 'produccion'::text, cc.id, null::bigint,
               round(100.0 / count(*) over (), 4),
               round(p_subtotal / count(*) over (), 2)
        from cc;
        return;
    end if;

    -- base m2 / kw / personas -> v_bases_prorrateo
    return query
    with b as (
        select v.rol, v.centro_costo_id, sum(v.fraccion) as f
        from public.v_bases_prorrateo v
        where v.base = v_pl.base
        group by v.rol, v.centro_costo_id
    )
    select 'produccion'::text, b.centro_costo_id, null::bigint,
           round(b.f * 100, 4), round(p_subtotal * b.f, 2)
    from b
    where b.rol = 'produccion' and b.centro_costo_id is not null and b.f > 0
    union all
    select 'no_produccion'::text, null::bigint, v_pl.cuenta_no_produccion_id,
           round(sum(b.f) * 100, 4), round(p_subtotal * sum(b.f), 2)
    from b
    where b.rol = 'no_produccion'
    having sum(b.f) > 0;
end $$;

grant execute on function public._reparto_resolver(bigint, numeric) to authenticated;


-- ---------------------------------------------------------------------
-- 6. registrar_gasto — ahora entiende p_datos->'reparto'
--    modo: 'directo' | 'centro_unico' | 'plantilla' | 'ninguno'
--    (si no viene 'reparto', se deduce de clasificacion — compatible
--     con el front actual).
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

    v_reparto   jsonb         := p_datos->'reparto';
    v_centro    bigint        := coalesce((v_reparto->>'centro_costo_id')::bigint, (p_datos->>'centro_costo_id')::bigint);
    v_clasif    text          := coalesce(nullif(trim(p_datos->>'clasificacion'), ''), 'no_produccion');
    v_cif_tipo  text          := nullif(trim(coalesce(v_reparto->>'cif_tipo', p_datos->>'cif_tipo')), '');
    v_orden     bigint        := coalesce((v_reparto->>'orden_produccion_id')::bigint, (p_datos->>'orden_produccion_id')::bigint);
    v_plantilla bigint        := nullif(v_reparto->>'plantilla_id', '')::bigint;
    v_modo      text;
    v_prorr     text;

    v_noprod_total  numeric(14,2) := 0;
    v_prod_total    numeric(14,2);
    v_rep_base      text;

    v_total     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_movs      jsonb;
    v_gasto_id  bigint;
    v_poliza_id bigint;
    v_id        bigint;
    r           record;
begin
    if v_fecha is null then raise exception 'La fecha del gasto es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto del gasto es obligatorio.'; end if;
    if v_subtotal <= 0 then raise exception 'El subtotal debe ser mayor a cero.'; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    select * into v_cuenta from public.cuentas_contables where id = v_cta_gasto;
    if not found then raise exception 'La cuenta de gasto no existe.'; end if;
    if not v_cuenta.afectable or not v_cuenta.activa then
        raise exception 'La cuenta de gasto % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
    end if;
    if v_cuenta.tipo not in ('gasto','costo') then
        raise exception 'La cuenta % no es de gasto ni de costo.', v_cuenta.codigo;
    end if;

    -- ---- modo de reparto ----
    v_modo := coalesce(nullif(trim(v_reparto->>'modo'), ''),
                       case v_clasif
                         when 'directo_produccion'   then 'directo'
                         when 'indirecto_produccion' then 'centro_unico'
                         else 'ninguno' end);

    if v_modo = 'directo' then
        v_clasif := 'directo_produccion';
        if v_orden is null then raise exception 'Un gasto directo de producción necesita la orden a la que se carga.'; end if;
        if not exists (select 1 from public.ordenes_produccion o where o.id = v_orden) then
            raise exception 'La orden de producción % no existe.', v_orden;
        end if;
        v_prorr := 'no_aplica'; v_centro := null;

    elsif v_modo = 'centro_unico' then
        v_clasif := 'indirecto_produccion';
        if v_centro is null then raise exception 'Un gasto indirecto de fabricación necesita un centro de costo.'; end if;
        if v_cif_tipo is null then v_cif_tipo := v_cuenta.cif_tipo; end if;
        v_prorr := 'pendiente'; v_orden := null;

    elsif v_modo = 'plantilla' then
        if v_plantilla is null then raise exception 'Falta la plantilla de reparto.'; end if;
        v_clasif := 'indirecto_produccion';
        v_centro := null; v_orden := null;
        if v_cif_tipo is null then v_cif_tipo := v_cuenta.cif_tipo; end if;

        if not exists (select 1 from public._reparto_resolver(v_plantilla, v_subtotal)) then
            raise exception 'La plantilla de reparto no produjo ninguna línea. Revisa las áreas y sus bases.';
        end if;
        if exists (select 1 from public._reparto_resolver(v_plantilla, v_subtotal) where destino = 'no_produccion' and cuenta_id is null) then
            raise exception 'La plantilla tiene parte de no producción pero no tiene cuenta de resultados asignada.';
        end if;
        select coalesce(sum(monto), 0) into v_noprod_total
          from public._reparto_resolver(v_plantilla, v_subtotal) where destino = 'no_produccion';
        v_prod_total := round(v_subtotal - v_noprod_total, 2);
        if v_prod_total < 0 then raise exception 'El reparto de no producción (%) supera el subtotal.', v_noprod_total; end if;
        select base into v_rep_base from public.reparto_plantillas where id = v_plantilla;
        if v_prod_total > 0 then
            v_prorr := 'pendiente';
        else
            v_prorr := 'no_aplica'; v_clasif := 'no_produccion';
        end if;

    else
        v_clasif := 'no_produccion';
        v_prorr := 'no_aplica'; v_orden := null; v_centro := null;
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
        jsonb_build_object('cuenta_id', v_cta_gasto,
            'cargo', case when v_modo = 'plantilla' then v_prod_total else v_subtotal end,
            'concepto', v_concepto)
    );

    if v_modo = 'plantilla' and v_noprod_total > 0 then
        for r in
            select cuenta_id, sum(monto) as monto
            from public._reparto_resolver(v_plantilla, v_subtotal)
            where destino = 'no_produccion' group by cuenta_id
        loop
            v_movs := v_movs || jsonb_build_object('cuenta_id', r.cuenta_id, 'cargo', r.monto,
                        'concepto', v_concepto || ' (no producción)');
        end loop;
    end if;

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
         centro_costo_id, clasificacion, cif_tipo, orden_produccion_id, prorrateo_estatus,
         monto_prorrateable, reparto_base, reparto_plantilla_id)
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
        v_centro, v_clasif, v_cif_tipo, v_orden, v_prorr,
        case when v_modo = 'plantilla' then v_prod_total
             when v_clasif = 'indirecto_produccion' then v_subtotal
             else null end,
        v_rep_base,
        case when v_modo = 'plantilla' then v_plantilla else null end
    )
    returning id into v_gasto_id;

    -- ---- plantilla: congelar el reparto ----
    if v_modo = 'plantilla' then
        if v_prod_total > 0 then
            update public.gastos set base_prorrateo = 'porcentaje_centros' where id = v_gasto_id;
            insert into public.gasto_prorrateo_reglas (gasto_id, centro_costo_id, porcentaje)
            select v_gasto_id, rr.centro_costo_id, round(rr.monto * 100.0 / nullif(v_subtotal, 0), 4)
            from public._reparto_resolver(v_plantilla, v_subtotal) rr
            where rr.destino = 'produccion' and rr.centro_costo_id is not null and rr.monto > 0;
        end if;
        insert into public.gasto_reparto_no_produccion (gasto_id, cuenta_id, monto)
        select v_gasto_id, rr.cuenta_id, sum(rr.monto)
        from public._reparto_resolver(v_plantilla, v_subtotal) rr
        where rr.destino = 'no_produccion' and rr.cuenta_id is not null
        group by rr.cuenta_id;
    end if;

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
                              'clasificacion', v_clasif, 'prorrateo_estatus', v_prorr,
                              'monto_prorrateable', case when v_modo = 'plantilla' then v_prod_total else null end,
                              'no_produccion', v_noprod_total);
end;
$$;

revoke all     on function public.registrar_gasto(jsonb) from public;
grant  execute on function public.registrar_gasto(jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- 7. Semilla de plantillas para los servicios compartidos típicos
--    (solo si existen las cuentas; % se derivan de las áreas)
-- ---------------------------------------------------------------------
insert into public.reparto_plantillas (nombre, cuenta_id, base, cuenta_no_produccion_id, notas)
select v.nombre,
       (select id from public.cuentas_contables where codigo = v.cta_prod),
       v.base,
       (select id from public.cuentas_contables where codigo = v.cta_noprod),
       v.notas
from (values
    ('Renta compartida (m²)',        '503.05', 'm2',       '601.24', 'Renta del predio: fábrica por m² ocupados, la parte de oficina a arrendamiento.'),
    ('Energía compartida (kW)',      '503.01', 'kw',       '601.17', 'Recibo CFE único: reparto por carga eléctrica instalada; la parte de oficina a energía eléctrica.'),
    ('Agua compartida (m²)',         '503.07', 'm2',       '601.19', 'Recibo de agua: reparto por superficie.'),
    ('Vigilancia compartida (m²)',   '503.08', 'm2',       '601.99', 'Vigilancia del predio: reparto por superficie.'),
    ('Internet y teléfono (personas)', null,   'personas', '601.18', 'Genérica: se propone en cualquier cuenta. Reparto por número de personas.')
) as v(nombre, cta_prod, base, cta_noprod, notas)
where (v.cta_prod is null or exists (select 1 from public.cuentas_contables where codigo = v.cta_prod))
  and exists (select 1 from public.cuentas_contables where codigo = v.cta_noprod)
  and not exists (select 1 from public.reparto_plantillas p where p.nombre = v.nombre);

commit;


-- =====================================================================
--  Verificación (opcional)
-- =====================================================================
-- select id, nombre, base, cuenta_id, cuenta_no_produccion_id from public.reparto_plantillas order by id;
-- select * from public._reparto_resolver( (select id from public.reparto_plantillas where nombre='Renta compartida (m²)'), 40000 );
-- select clave, valor from public.costos_config;
