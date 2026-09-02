-- =====================================================================
--  Catálogos SAT del CFDI + trazabilidad fiscal en pólizas
--  Fecha: 2026-09-03  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--  Requiere: contabilidad fases 1-4 (cuentas, polizas, gastos, compras).
--
--  - c_uso_cfdi     : catálogo c_UsoCFDI del SAT + cuenta contable por defecto
--  - c_forma_pago   : catálogo c_FormaPago del SAT
--  - c_metodo_pago  : PUE / PPD
--  - documentos.uso_cfdi / metodo_pago / moneda : datos fiscales de la entrada
--  - registrar_poliza  : ahora acepta p_datos.fiscal y lo estampa en CADA
--                        movimiento (uuid_cfdi, tercero_rfc, forma_pago, metodo_pago)
--  - contabilizar_compra : usa la cuenta del Uso CFDI como fallback y pasa
--                          la trazabilidad fiscal a la póliza.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Catálogos
-- ---------------------------------------------------------------------
create table if not exists public.c_uso_cfdi (
    clave       text primary key,
    descripcion text not null,
    cuenta_id   bigint references public.cuentas_contables (id) on delete set null,
    activo      boolean not null default true
);

insert into public.c_uso_cfdi (clave, descripcion, cuenta_id)
select v.clave, v.descripcion, public._cuenta_id(v.cta)
from (values
    ('G01', 'Adquisición de mercancías',                                   '115.01'),
    ('G02', 'Devoluciones, descuentos o bonificaciones',                   '115.01'),
    ('G03', 'Gastos en general',                                           null),
    ('I01', 'Construcciones',                                              null),
    ('I02', 'Mobiliario y equipo de oficina por inversiones',             null),
    ('I03', 'Equipo de transporte',                                        null),
    ('I04', 'Equipo de cómputo y accesorios',                             null),
    ('I05', 'Dados, troqueles, moldes, matrices y herramental',           null),
    ('I06', 'Comunicaciones telefónicas',                                  null),
    ('I07', 'Comunicaciones satelitales',                                  null),
    ('I08', 'Otra maquinaria y equipo',                                    null),
    ('D01', 'Honorarios médicos, dentales y gastos hospitalarios',         null),
    ('D02', 'Gastos médicos por incapacidad o discapacidad',              null),
    ('D03', 'Gastos funerales',                                            null),
    ('D04', 'Donativos',                                                   null),
    ('D05', 'Intereses reales pagados por créditos hipotecarios (casa habitación)', null),
    ('D06', 'Aportaciones voluntarias al SAR',                             null),
    ('D07', 'Primas por seguros de gastos médicos',                       null),
    ('D08', 'Gastos de transportación escolar obligatoria',               null),
    ('D09', 'Depósitos en cuentas de ahorro, primas de planes de pensiones', null),
    ('D10', 'Pagos por servicios educativos (colegiaturas)',              null),
    ('S01', 'Sin efectos fiscales',                                        null),
    ('CP01', 'Pagos',                                                      null),
    ('CN01', 'Nómina',                                                     null)
) as v(clave, descripcion, cta)
on conflict (clave) do update set descripcion = excluded.descripcion;

create table if not exists public.c_forma_pago (
    clave       text primary key,
    descripcion text not null
);
insert into public.c_forma_pago (clave, descripcion) values
    ('01', 'Efectivo'),
    ('02', 'Cheque nominativo'),
    ('03', 'Transferencia electrónica de fondos'),
    ('04', 'Tarjeta de crédito'),
    ('05', 'Monedero electrónico'),
    ('06', 'Dinero electrónico'),
    ('08', 'Vales de despensa'),
    ('12', 'Dación en pago'),
    ('13', 'Pago por subrogación'),
    ('14', 'Pago por consignación'),
    ('15', 'Condonación'),
    ('17', 'Compensación'),
    ('23', 'Novación'),
    ('24', 'Confusión'),
    ('25', 'Remisión de deuda'),
    ('26', 'Prescripción o caducidad'),
    ('27', 'A satisfacción del acreedor'),
    ('28', 'Tarjeta de débito'),
    ('29', 'Tarjeta de servicios'),
    ('30', 'Aplicación de anticipos'),
    ('31', 'Intención de pago'),
    ('99', 'Por definir')
on conflict (clave) do update set descripcion = excluded.descripcion;

create table if not exists public.c_metodo_pago (
    clave       text primary key,
    descripcion text not null
);
insert into public.c_metodo_pago (clave, descripcion) values
    ('PUE', 'Pago en una sola exhibición'),
    ('PPD', 'Pago en parcialidades o diferido')
on conflict (clave) do update set descripcion = excluded.descripcion;

alter table public.c_uso_cfdi    enable row level security;
alter table public.c_forma_pago  enable row level security;
alter table public.c_metodo_pago enable row level security;
drop policy if exists admin_all on public.c_uso_cfdi;
drop policy if exists admin_all on public.c_forma_pago;
drop policy if exists admin_all on public.c_metodo_pago;
create policy admin_all on public.c_uso_cfdi    for all to authenticated using (true) with check (true);
create policy admin_all on public.c_forma_pago  for all to authenticated using (true) with check (true);
create policy admin_all on public.c_metodo_pago for all to authenticated using (true) with check (true);
grant all    on public.c_uso_cfdi, public.c_forma_pago, public.c_metodo_pago to authenticated;
grant select on public.c_uso_cfdi, public.c_forma_pago, public.c_metodo_pago to anon;

-- ---------------------------------------------------------------------
-- 2. Datos fiscales del CFDI en el documento de entrada
-- ---------------------------------------------------------------------
alter table public.documentos
    add column if not exists uso_cfdi    text,
    add column if not exists metodo_pago text,
    add column if not exists moneda      text,
    add column if not exists tipo_cambio numeric(14,6) default 1;

-- ---------------------------------------------------------------------
-- 3. registrar_poliza: estampa p_datos.fiscal en cada movimiento
--    fiscal: { uuid_cfdi, tercero_rfc, tercero_nombre, forma_pago, metodo_pago }
--    (cada renglón puede traer su propio valor; si no, hereda del bloque fiscal)
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
    v_fiscal    jsonb := coalesce(p_datos->'fiscal', '{}'::jsonb);
    v_sum_cargo numeric(14,2) := 0;
    v_sum_abono numeric(14,2) := 0;
    v_numero    int;
    v_poliza_id bigint;
    v_cargo     numeric(14,2);
    v_abono     numeric(14,2);
    v_cuenta    public.cuentas_contables%rowtype;
    v_i         int := 0;
    r           jsonb;
begin
    if v_fecha is null then raise exception 'La fecha de la poliza es obligatoria.'; end if;
    if v_concepto is null then raise exception 'El concepto de la poliza es obligatorio.'; end if;
    if v_tipo not in ('Ingreso','Egreso','Diario') then raise exception 'Tipo de poliza invalido: %', v_tipo; end if;
    if jsonb_array_length(v_movs) < 2 then raise exception 'La poliza necesita al menos 2 movimientos.'; end if;

    for r in select * from jsonb_array_elements(v_movs)
    loop
        v_i := v_i + 1;
        v_cargo := round(coalesce((r->>'cargo')::numeric, 0), 2);
        v_abono := round(coalesce((r->>'abono')::numeric, 0), 2);
        if v_cargo < 0 or v_abono < 0 then
            raise exception 'Renglon %: cargo y abono no pueden ser negativos.', v_i;
        end if;
        if (v_cargo > 0 and v_abono > 0) or (v_cargo = 0 and v_abono = 0) then
            raise exception 'Renglon %: pon importe en cargo O en abono (no ambos, no ninguno).', v_i;
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
    if v_sum_cargo = 0 then raise exception 'La poliza no puede sumar cero.'; end if;

    select coalesce(max(numero), 0) + 1 into v_numero
    from public.polizas
    where tipo = v_tipo and extract(year from fecha) = extract(year from v_fecha);

    insert into public.polizas
        (fecha, tipo, numero, concepto, folio, origen, origen_tabla, origen_id, moneda_id, tipo_cambio)
    values (
        v_fecha, v_tipo, v_numero, v_concepto,
        nullif(trim(p_datos->>'folio'), ''),
        coalesce(nullif(trim(p_datos->>'origen'), ''), 'manual'),
        nullif(trim(p_datos->>'origen_tabla'), ''),
        (p_datos->>'origen_id')::bigint,
        (p_datos->>'moneda_id')::bigint,
        coalesce((p_datos->>'tipo_cambio')::numeric, 1)
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
            coalesce(nullif(trim(r->>'tercero_rfc'), ''),    nullif(trim(v_fiscal->>'tercero_rfc'), '')),
            coalesce(nullif(trim(r->>'tercero_nombre'), ''), nullif(trim(v_fiscal->>'tercero_nombre'), '')),
            coalesce(nullif(trim(r->>'uuid_cfdi'), ''),      nullif(trim(v_fiscal->>'uuid_cfdi'), '')),
            coalesce(nullif(trim(r->>'forma_pago'), ''),     nullif(trim(v_fiscal->>'forma_pago'), '')),
            coalesce(nullif(trim(r->>'metodo_pago'), ''),    nullif(trim(v_fiscal->>'metodo_pago'), ''))
        );
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'numero', v_numero);
end;
$$;
revoke all     on function public.registrar_poliza(jsonb) from public;
grant  execute on function public.registrar_poliza(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 4. contabilizar_compra: cuenta del Uso CFDI como fallback + traza fiscal
--    p_datos ahora acepta ademas: uso_cfdi, metodo_pago, moneda
-- ---------------------------------------------------------------------
create or replace function public.contabilizar_compra(p_documento_id bigint, p_datos jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_doc        public.documentos%rowtype;
    v_subtotal   numeric(14,2) := greatest(0, round(coalesce((p_datos->>'subtotal')::numeric, 0), 2));
    v_iva        numeric(14,2) := greatest(0, round(coalesce((p_datos->>'iva')::numeric, 0), 2));
    v_ieps       numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ieps')::numeric, 0), 2));
    v_ret_iva    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_iva')::numeric, 0), 2));
    v_ret_isr    numeric(14,2) := greatest(0, round(coalesce((p_datos->>'ret_isr')::numeric, 0), 2));
    v_condicion  text := coalesce(nullif(trim(p_datos->>'condicion'), ''), 'credito');
    v_cta_pago   bigint := (p_datos->>'cuenta_pago_id')::bigint;
    v_uso        text := nullif(trim(p_datos->>'uso_cfdi'), '');
    v_metodo     text := nullif(trim(p_datos->>'metodo_pago'), '');
    v_forma      text := nullif(trim(p_datos->>'forma_pago'), '');
    v_moneda     text := nullif(trim(p_datos->>'moneda'), '');
    v_tc         numeric(14,6) := coalesce(nullif(p_datos->>'tipo_cambio', '')::numeric, 1);
    v_moneda_id  bigint;
    v_uuid       text := nullif(trim(p_datos->>'uuid_cfdi'), '');
    v_rfc        text := nullif(trim(p_datos->>'rfc_emisor'), '');
    v_total      numeric(14,2);
    v_sum_det    numeric(14,2);
    v_movs       jsonb := '[]'::jsonb;
    v_id         bigint;
    v_cta_inv_def bigint;
    v_cuenta     public.cuentas_contables%rowtype;
    r            record;
    v_acum       numeric(14,2) := 0;
    v_reparto    numeric(14,2);
begin
    select * into v_doc from public.documentos where id = p_documento_id;
    if not found then raise exception 'El documento de compra no existe.'; end if;
    if v_doc.poliza_id is not null then raise exception 'Esta compra ya esta contabilizada (poliza %).', v_doc.poliza_id; end if;
    if v_condicion not in ('contado','credito') then raise exception 'Condicion invalida: %', v_condicion; end if;

    -- Cuenta de inventario por defecto: la del Uso CFDI si la tiene, si no 115.01
    v_cta_inv_def := coalesce(
        (select cuenta_id from public.c_uso_cfdi where clave = v_uso and cuenta_id is not null),
        public._cuenta_id('115.01'));

    -- Moneda de la póliza (los importes ya llegan en MXN; esto es para el registro)
    select id into v_moneda_id from public.monedas where codigo = coalesce(v_moneda, 'MXN') limit 1;

    select coalesce(sum(subtotal), 0) into v_sum_det from public.documento_detalles where documento_id = p_documento_id;
    if v_subtotal <= 0 then v_subtotal := round(v_sum_det, 2); end if;
    if v_subtotal <= 0 then raise exception 'La compra no tiene importe (subtotal 0).'; end if;

    v_total := round(v_subtotal + v_iva + v_ieps - v_ret_iva - v_ret_isr, 2);
    if v_total < 0 then raise exception 'Las retenciones no pueden superar subtotal + impuestos.'; end if;

    if v_condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_cta_pago;
        if not found then raise exception 'Selecciona la cuenta de caja / banco del pago.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    for r in
        select coalesce(pr.cuenta_inventario_id, v_cta_inv_def) as cta_id,
               sum(dd.subtotal) as monto_det
          from public.documento_detalles dd
          left join public.productos pr on pr.id = dd.producto_id
         where dd.documento_id = p_documento_id
         group by coalesce(pr.cuenta_inventario_id, v_cta_inv_def)
         order by 1
    loop
        if v_sum_det > 0 then
            v_reparto := round(v_subtotal * (r.monto_det / v_sum_det), 2);
        else
            v_reparto := v_subtotal;
        end if;
        v_acum := v_acum + v_reparto;
        v_movs := v_movs || jsonb_build_object('cuenta_id', r.cta_id, 'cargo', v_reparto, 'concepto', 'Inventario ' || coalesce(v_doc.folio, ''));
    end loop;
    if v_acum <> v_subtotal and jsonb_array_length(v_movs) > 0 then
        v_id := jsonb_array_length(v_movs) - 1;
        v_movs := jsonb_set(
            v_movs, array[v_id::text, 'cargo'],
            to_jsonb(round((v_movs -> (v_id::int) ->> 'cargo')::numeric + (v_subtotal - v_acum), 2))
        );
    end if;

    if v_iva > 0 then
        v_id := public._cuenta_id(case when v_condicion = 'contado' then '118.01' else '119.01' end);
        if v_id is null then raise exception 'Falta la cuenta % (IVA acreditable).',
            case when v_condicion = 'contado' then '118.01' else '119.01' end; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_iva, 'concepto', 'IVA acreditable');
    end if;
    if v_ieps > 0 then
        v_id := public._cuenta_id('118.03');
        if v_id is null then raise exception 'Falta la cuenta 118.03 (IEPS acreditable).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_ieps, 'concepto', 'IEPS acreditable');
    end if;
    if v_ret_iva > 0 then
        v_id := public._cuenta_id('216.05');
        if v_id is null then raise exception 'Falta la cuenta 216.05 (IVA retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_iva, 'concepto', 'IVA retenido');
    end if;
    if v_ret_isr > 0 then
        v_id := public._cuenta_id('216.10');
        if v_id is null then raise exception 'Falta la cuenta 216.10 (ISR retenido).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_ret_isr, 'concepto', 'ISR retenido');
    end if;

    if v_condicion = 'contado' then
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_cta_pago, 'abono', v_total, 'concepto', 'Pago compra ' || coalesce(v_doc.folio, ''));
    else
        v_id := public._cuenta_id('201.01');
        if v_id is null then raise exception 'Falta la cuenta 201.01 (Proveedores).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_total,
                    'concepto', 'Compra a credito ' || coalesce(v_doc.folio, ''), 'proveedor_id', v_doc.proveedor_id);
    end if;

    v_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_doc.fecha_emision,
        'tipo', 'Egreso',
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),
        'folio', v_doc.folio,
        'origen', 'compra',
        'origen_tabla', 'documentos',
        'origen_id', p_documento_id,
        'moneda_id', v_moneda_id,
        'tipo_cambio', v_tc,
        'movimientos', v_movs,
        'fiscal', jsonb_build_object(
            'uuid_cfdi', v_uuid,
            'tercero_rfc', v_rfc,
            'forma_pago', v_forma,
            'metodo_pago', v_metodo
        )
    ))->>'poliza_id')::bigint;

    update public.documentos
       set subtotal = v_subtotal, iva = v_iva, ieps = v_ieps, ret_iva = v_ret_iva, ret_isr = v_ret_isr,
           total = v_total, condicion = v_condicion,
           forma_pago = v_forma,
           metodo_pago = v_metodo,
           moneda = v_moneda,
           tipo_cambio = v_tc,
           uso_cfdi = v_uso,
           cuenta_pago_id = case when v_condicion = 'contado' then v_cta_pago else null end,
           uuid_cfdi = v_uuid,
           rfc_emisor = v_rfc,
           poliza_id = v_id
     where id = p_documento_id;

    return jsonb_build_object('poliza_id', v_id, 'total', v_total);
end;
$$;
revoke all     on function public.contabilizar_compra(bigint, jsonb) from public;
grant  execute on function public.contabilizar_compra(bigint, jsonb) to authenticated;

commit;
