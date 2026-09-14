-- =====================================================================
--  Correcciones a hallazgos de seguridad / control interno (F3, F4, F5, F8
--  de la auditoría de contabilidad)
--  Fecha: 2026-09-22  ·  Proyecto: Hares de México (Supabase)
--
--  Este archivo NO lo ejecuta la app. Pegar y correr A MANO en:
--    Supabase -> SQL Editor
--
--  Requiere: sql/2026-08-27_flujo_ot.sql
--            sql/2026-08-28_contabilidad_cuentas.sql
--            sql/2026-08-28_contabilidad_polizas.sql
--            sql/2026-08-30_contabilidad_isr.sql
--            sql/2026-09-14_fix_hallazgos_contabilidad.sql
--
--  Corrige:
--
--  F3. ot_login (PIN de 4 dígitos, llamable por 'anon') no tenía límite
--      de intentos: 10,000 combinaciones eran fuerza-bruteables sin
--      fricción, permitiendo suplantar empleados y falsear los tiempos
--      que alimentan el costeo de mano de obra. Ahora bloquea al
--      empleado 15 minutos tras 5 intentos fallidos consecutivos.
--
--  F4. No existía cierre de periodo contable: cualquier usuario
--      autenticado podía registrar o cancelar pólizas en cualquier
--      fecha pasada, incluso ya declarada al SAT. Se agrega
--      periodos_contables + RPCs cerrar_periodo_contable /
--      reabrir_periodo_contable, y registrar_poliza / cancelar_poliza
--      ahora rechazan tocar un periodo cerrado.
--
--  F5. registrar_poliza / cancelar_poliza calculaban el consecutivo con
--      "select coalesce(max(numero),0)+1", sin bloqueo: dos inserciones
--      concurrentes podían generar el mismo folio (el mismo patrón de
--      bug ya visto en la cadena Egreso #2->#3->#4 mencionada en
--      2026-09-14_fix_hallazgos_contabilidad.sql). Se reemplaza por un
--      contador atómico (contadores_polizas, upsert con ON CONFLICT),
--      igual al patrón ya usado en contadores_documentos.
--
--  F8. cuentas_contables, isr_tarifas e isr_tarifa_tramos no tenían
--      bitácora: un cambio a una tasa de ISR o a una cuenta contable no
--      dejaba rastro de quién/cuándo/qué valor tenía antes. Se agrega
--      bitacora_cambios (solo insertable por el trigger, nunca por
--      'authenticated' vía API — así ni el propio admin puede borrar su
--      rastro) y triggers en esas 3 tablas + en periodos_contables
--      (para que abrir/cerrar/reabrir un periodo también quede
--      registrado).
--
--  Idempotente.
-- =====================================================================

begin;

-- =====================================================================
-- F8.0  Bitácora de cambios (genérica, de solo-inserción por trigger)
-- =====================================================================
create table if not exists public.bitacora_cambios (
    id            bigint generated always as identity primary key,
    tabla         text not null,
    registro_id   bigint,
    accion        text not null check (accion in ('INSERT','UPDATE','DELETE')),
    datos_antes   jsonb,
    datos_despues jsonb,
    usuario_id    uuid default auth.uid(),
    creado_at     timestamptz not null default now()
);
create index if not exists idx_bitacora_tabla_registro on public.bitacora_cambios(tabla, registro_id);
create index if not exists idx_bitacora_creado_at      on public.bitacora_cambios(creado_at);

alter table public.bitacora_cambios enable row level security;

-- Solo lectura para 'authenticated'. A propósito NO hay política de
-- insert/update/delete para 'authenticated' (ni siquiera con el rol
-- admin_all de las demás tablas): la única forma de escribir aquí es el
-- trigger de abajo, que corre como dueño de la función (SECURITY
-- DEFINER, dueño = quien corrió esta migración) y por eso no necesita
-- política propia. Así el log queda de solo-anexado incluso para quien
-- tiene acceso total en todo lo demás — sin FORCE ROW LEVEL SECURITY,
-- para no bloquear al propio dueño/trigger.
drop policy if exists solo_lectura on public.bitacora_cambios;
create policy solo_lectura on public.bitacora_cambios for select to authenticated using (true);

revoke all on public.bitacora_cambios from anon, authenticated;
grant select on public.bitacora_cambios to authenticated;

create or replace function public.fn_bitacora_generica()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if tg_op = 'INSERT' then
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_despues)
        values (tg_table_name, (to_jsonb(new)->>'id')::bigint, 'INSERT', to_jsonb(new));
        return new;
    elsif tg_op = 'UPDATE' then
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_antes, datos_despues)
        values (tg_table_name, (to_jsonb(new)->>'id')::bigint, 'UPDATE', to_jsonb(old), to_jsonb(new));
        return new;
    elsif tg_op = 'DELETE' then
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_antes)
        values (tg_table_name, (to_jsonb(old)->>'id')::bigint, 'DELETE', to_jsonb(old));
        return old;
    end if;
    return null;
end;
$$;

revoke all on function public.fn_bitacora_generica() from public, anon, authenticated;

-- Se enganchan a cuentas_contables / isr_tarifas / isr_tarifa_tramos más
-- abajo, y a periodos_contables en cuanto se crea (F4).


-- =====================================================================
-- F8.1  Triggers de bitácora en las 3 tablas señaladas por el hallazgo
-- =====================================================================
drop trigger if exists trg_bitacora_cuentas_contables on public.cuentas_contables;
create trigger trg_bitacora_cuentas_contables
    after insert or update or delete on public.cuentas_contables
    for each row execute function public.fn_bitacora_generica();

drop trigger if exists trg_bitacora_isr_tarifas on public.isr_tarifas;
create trigger trg_bitacora_isr_tarifas
    after insert or update or delete on public.isr_tarifas
    for each row execute function public.fn_bitacora_generica();

drop trigger if exists trg_bitacora_isr_tarifa_tramos on public.isr_tarifa_tramos;
create trigger trg_bitacora_isr_tarifa_tramos
    after insert or update or delete on public.isr_tarifa_tramos
    for each row execute function public.fn_bitacora_generica();


-- =====================================================================
-- F4  Cierre de periodo contable
-- =====================================================================
create table if not exists public.periodos_contables (
    id                bigint generated always as identity primary key,
    anio              integer not null,
    mes               integer not null check (mes between 1 and 12),
    cerrado           boolean not null default false,
    cerrado_por       uuid,
    cerrado_at        timestamptz,
    reabierto_por     uuid,
    reabierto_at      timestamptz,
    motivo_reapertura text,
    unique (anio, mes)
);

alter table public.periodos_contables enable row level security;
drop policy if exists admin_all on public.periodos_contables;
create policy admin_all on public.periodos_contables for all to authenticated using (true) with check (true);

drop trigger if exists trg_bitacora_periodos_contables on public.periodos_contables;
create trigger trg_bitacora_periodos_contables
    after insert or update or delete on public.periodos_contables
    for each row execute function public.fn_bitacora_generica();

-- Helper interno: lanza excepción si la fecha cae en un periodo cerrado.
create or replace function public._verificar_periodo_abierto(p_fecha date)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if p_fecha is null then
        return;
    end if;
    if exists (
        select 1 from public.periodos_contables
         where anio = extract(year from p_fecha)::int
           and mes  = extract(month from p_fecha)::int
           and cerrado
    ) then
        raise exception 'El periodo %-% ya está cerrado para contabilidad. Si de verdad necesitas modificarlo, reábrelo primero con reabrir_periodo_contable (queda registrado en la bitácora).',
            extract(year from p_fecha)::int, extract(month from p_fecha)::int;
    end if;
end;
$$;
revoke all     on function public._verificar_periodo_abierto(date) from public;
grant  execute on function public._verificar_periodo_abierto(date) to authenticated;

create or replace function public.cerrar_periodo_contable(p_anio integer, p_mes integer)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_id bigint;
begin
    if p_mes not between 1 and 12 then raise exception 'Mes inválido: %.', p_mes; end if;
    if p_anio < 2000 then raise exception 'Año inválido: %.', p_anio; end if;

    insert into public.periodos_contables (anio, mes, cerrado, cerrado_por, cerrado_at)
    values (p_anio, p_mes, true, auth.uid(), now())
    on conflict (anio, mes) do update
        set cerrado = true, cerrado_por = auth.uid(), cerrado_at = now()
    returning id into v_id;

    return jsonb_build_object('periodo_id', v_id, 'anio', p_anio, 'mes', p_mes, 'cerrado', true);
end;
$$;
revoke all     on function public.cerrar_periodo_contable(integer, integer) from public;
grant  execute on function public.cerrar_periodo_contable(integer, integer) to authenticated;

create or replace function public.reabrir_periodo_contable(p_anio integer, p_mes integer, p_motivo text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_id     bigint;
    v_motivo text := nullif(trim(p_motivo), '');
begin
    if v_motivo is null then
        raise exception 'Debes indicar el motivo para reabrir un periodo ya cerrado (queda en la bitácora).';
    end if;

    update public.periodos_contables
       set cerrado = false, reabierto_por = auth.uid(), reabierto_at = now(),
           motivo_reapertura = v_motivo
     where anio = p_anio and mes = p_mes and cerrado = true
    returning id into v_id;

    if not found then
        raise exception 'El periodo %-% no existe o no estaba cerrado.', p_anio, p_mes;
    end if;

    return jsonb_build_object('periodo_id', v_id, 'anio', p_anio, 'mes', p_mes, 'cerrado', false);
end;
$$;
revoke all     on function public.reabrir_periodo_contable(integer, integer, text) from public;
grant  execute on function public.reabrir_periodo_contable(integer, integer, text) to authenticated;


-- =====================================================================
-- F5  Consecutivo atómico de pólizas (reemplaza max(numero)+1)
-- =====================================================================
create table if not exists public.contadores_polizas (
    tipo   text    not null,
    anio   integer not null,
    ultimo integer not null default 0,
    primary key (tipo, anio)
);

alter table public.contadores_polizas enable row level security;
drop policy if exists admin_all on public.contadores_polizas;
create policy admin_all on public.contadores_polizas for all to authenticated using (true) with check (true);
grant select on public.contadores_polizas to authenticated;

-- Siembra el contador con lo que ya exista en polizas, para no repetir
-- ni brincar folios ya usados.
insert into public.contadores_polizas (tipo, anio, ultimo)
select tipo, extract(year from fecha)::integer, max(numero)
from public.polizas
group by tipo, extract(year from fecha)::integer
on conflict (tipo, anio) do update
    set ultimo = greatest(contadores_polizas.ultimo, excluded.ultimo);

-- Upsert atómico: sin lectura-luego-escritura, no hay ventana para que
-- dos transacciones concurrentes obtengan el mismo número.
create or replace function public._siguiente_numero_poliza(p_tipo text, p_fecha date)
returns integer
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_anio   integer := extract(year from p_fecha)::integer;
    v_numero integer;
begin
    insert into public.contadores_polizas (tipo, anio, ultimo)
    values (p_tipo, v_anio, 1)
    on conflict (tipo, anio) do update set ultimo = contadores_polizas.ultimo + 1
    returning ultimo into v_numero;
    return v_numero;
end;
$$;
revoke all     on function public._siguiente_numero_poliza(text, date) from public;
grant  execute on function public._siguiente_numero_poliza(text, date) to authenticated;


-- ---------------------------------------------------------------------
-- registrar_poliza — usa el contador atómico + valida periodo abierto
-- (idéntica al resto de la lógica de sql/2026-08-28_contabilidad_polizas.sql)
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
            nullif(trim(r->>'tercero_rfc'), ''),
            nullif(trim(r->>'tercero_nombre'), ''),
            nullif(trim(r->>'uuid_cfdi'), ''),
            nullif(trim(r->>'forma_pago'), ''),
            nullif(trim(r->>'metodo_pago'), '')
        );
    end loop;

    return jsonb_build_object('poliza_id', v_poliza_id, 'numero', v_numero);
end;
$$;

revoke all     on function public.registrar_poliza(jsonb) from public;
grant  execute on function public.registrar_poliza(jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- cancelar_poliza — usa el contador atómico + valida periodo abierto
-- tanto de la póliza original (lo que se está anulando) como del día de
-- hoy (donde se inserta el reverso). Conserva la validación de
-- 2026-09-14_fix_hallazgos_contabilidad.sql (no cancelar un reverso).
-- ---------------------------------------------------------------------
create or replace function public.cancelar_poliza(p_poliza_id bigint, p_motivo text default null)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_orig   public.polizas%rowtype;
    v_numero int;
    v_rev_id bigint;
    v_i      int := 0;
    m        public.poliza_movimientos%rowtype;
begin
    select * into v_orig from public.polizas where id = p_poliza_id;
    if not found then raise exception 'La poliza no existe.'; end if;
    if v_orig.estatus <> 'contabilizada' then
        raise exception 'Solo se puede cancelar una poliza contabilizada (estatus actual: %).', v_orig.estatus;
    end if;
    if v_orig.origen = 'ajuste' and v_orig.origen_tabla = 'polizas' then
        raise exception 'La poliza #% ya es un reverso (generado al cancelar la poliza #%). No se puede cancelar un reverso — revisa directamente la poliza original #% si necesitas deshacer esa cancelación.',
            v_orig.numero, v_orig.origen_id, v_orig.origen_id;
    end if;

    -- No se cancela (ni se "reabre" de facto) algo que cae en un periodo
    -- ya cerrado, y tampoco se inserta el reverso si hoy cae en uno.
    perform public._verificar_periodo_abierto(v_orig.fecha);
    perform public._verificar_periodo_abierto(current_date);

    v_numero := public._siguiente_numero_poliza(v_orig.tipo, current_date);

    insert into public.polizas
        (fecha, tipo, numero, concepto, origen, origen_tabla, origen_id, poliza_reversa_id, moneda_id, tipo_cambio)
    values (
        current_date, v_orig.tipo, v_numero,
        'Cancelacion de poliza ' || v_orig.tipo || ' #' || v_orig.numero || coalesce(' - ' || p_motivo, ''),
        'ajuste', 'polizas', v_orig.id, v_orig.id, v_orig.moneda_id, v_orig.tipo_cambio
    )
    returning id into v_rev_id;

    for m in select * from public.poliza_movimientos where poliza_id = v_orig.id order by orden
    loop
        v_i := v_i + 1;
        insert into public.poliza_movimientos (poliza_id, orden, cuenta_id, cargo, abono, concepto, proveedor_id, cliente_id)
        values (v_rev_id, v_i, m.cuenta_id, m.abono, m.cargo,           -- invertido
                'Reverso: ' || coalesce(m.concepto, ''), m.proveedor_id, m.cliente_id);
    end loop;

    update public.polizas set estatus = 'cancelada' where id = v_orig.id;

    return jsonb_build_object('poliza_reversa_id', v_rev_id);
end;
$$;

revoke all     on function public.cancelar_poliza(bigint, text) from public;
grant  execute on function public.cancelar_poliza(bigint, text) to authenticated;


-- =====================================================================
-- F3  ot_login con límite de intentos (bloqueo temporal por PIN)
-- =====================================================================
alter table public.empleados
    add column if not exists intentos_fallidos integer not null default 0,
    add column if not exists bloqueado_hasta   timestamptz;

create or replace function public.ot_login(p_empleado_id bigint, p_pin text)
returns table (token uuid, empleado_id bigint, empleado_nombre text)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_emp          public.empleados%rowtype;
    v_max_intentos constant integer  := 5;
    v_bloqueo      constant interval := interval '15 minutes';
begin
    delete from public.sesiones_ot where expira_at < now();   -- limpieza oportunista

    select e.* into v_emp
      from public.empleados e
     where e.id = p_empleado_id
       and e.activo is true
       and e.pin_hash is not null;

    if not found then
        raise exception 'Nombre o PIN incorrecto.';
    end if;

    if v_emp.bloqueado_hasta is not null and v_emp.bloqueado_hasta > now() then
        raise exception 'Demasiados intentos fallidos. Vuelve a intentar después de las %.',
            to_char(v_emp.bloqueado_hasta, 'HH24:MI');
    end if;

    if v_emp.pin_hash <> crypt(p_pin, v_emp.pin_hash) then
        update public.empleados
           set intentos_fallidos = coalesce(intentos_fallidos, 0) + 1,
               bloqueado_hasta   = case when coalesce(intentos_fallidos, 0) + 1 >= v_max_intentos
                                         then now() + v_bloqueo
                                         else bloqueado_hasta
                                    end
         where id = p_empleado_id;
        raise exception 'Nombre o PIN incorrecto.';
    end if;

    update public.empleados
       set intentos_fallidos = 0, bloqueado_hasta = null
     where id = p_empleado_id;

    return query
    insert into public.sesiones_ot (empleado_id)
    values (p_empleado_id)
    returning sesiones_ot.token, p_empleado_id, v_emp.nombre;
end;
$$;

revoke all     on function public.ot_login(bigint, text) from public;
grant  execute on function public.ot_login(bigint, text) to anon, authenticated;

commit;
