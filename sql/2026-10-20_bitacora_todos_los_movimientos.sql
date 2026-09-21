-- =====================================================================
--  Bitácora de TODOS los movimientos de un usuario
--  Fecha: 2026-10-20  ·  Proyecto: Hares de México (Supabase)
--
--  Requiere sql/2026-09-22_fix_hallazgos_seguridad_contabilidad.sql
--  (ahí nace public.bitacora_cambios y fn_bitacora_generica).
--
--  Qué agrega:
--   1. usuario_email en bitacora_cambios: se guarda el correo de quien
--      hizo el movimiento (no solo su id). Las filas viejas se rellenan
--      desde auth.users.
--   2. fn_bitacora_generica mejorada:
--        - no registra un UPDATE que no cambió nada,
--        - recorta datos enormes (fotos, archivos en base64) para no
--          inflar la bitácora,
--        - tolera tablas con id uuid (registro_id queda vacío).
--   3. Triggers en las tablas de catálogos, compras, ventas, inventario,
--      producción y finanzas (solo en las que existan).
--   4. Eventos de sesión: bitacora_evento('LOGIN' | 'LOGOUT'), que llama
--      la app al entrar y al cerrar sesión.
--
--  La bitácora sigue siendo de solo lectura para la app: solo escriben
--  los triggers y bitacora_evento (security definer).
--
--  No se registran (a propósito) las tablas que genera el propio sistema
--  a partir de otras y crecen mucho: movimientos_inventario,
--  lotes_inventario, poliza_movimientos, gasto_aplicaciones, contadores,
--  sesiones de operador. Lo que las originó (documentos, pólizas, órdenes)
--  sí queda registrado.
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- 1. Correo del usuario + acciones de sesión
-- ---------------------------------------------------------------------
alter table public.bitacora_cambios
    add column if not exists usuario_email text default (auth.jwt() ->> 'email');

alter table public.bitacora_cambios drop constraint if exists bitacora_cambios_accion_check;
alter table public.bitacora_cambios
    add constraint bitacora_cambios_accion_check
    check (accion in ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT'));

create index if not exists idx_bitacora_usuario on public.bitacora_cambios (usuario_email, creado_at);

-- Filas anteriores: el correo sale de auth.users (solo llena la columna nueva).
update public.bitacora_cambios b
   set usuario_email = u.email
  from auth.users u
 where b.usuario_id = u.id
   and b.usuario_email is null;


-- ---------------------------------------------------------------------
-- 2. Función del trigger, más útil y más segura
-- ---------------------------------------------------------------------
-- Quita de un jsonb los valores muy grandes (fotos, PDF/imagen en base64...).
create or replace function public._bitacora_recortar(p jsonb)
returns jsonb
language sql
immutable
as $$
    select case when p is null then null else
        (select coalesce(jsonb_object_agg(
                    k,
                    case when length(v::text) > 3000 then to_jsonb('(dato grande omitido)'::text) else v end
                ), '{}'::jsonb)
           from jsonb_each(p) as t(k, v))
    end;
$$;

create or replace function public.fn_bitacora_generica()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_antes   jsonb;
    v_despues jsonb;
    v_id_txt  text;
begin
    if tg_op = 'INSERT' then
        v_despues := to_jsonb(new);
        v_id_txt  := v_despues ->> 'id';
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_despues)
        values (tg_table_name, case when v_id_txt ~ '^[0-9]+$' then v_id_txt::bigint end,
                'INSERT', public._bitacora_recortar(v_despues));
        return new;

    elsif tg_op = 'UPDATE' then
        v_antes   := to_jsonb(old);
        v_despues := to_jsonb(new);
        if v_antes = v_despues then return new; end if;      -- no cambió nada
        v_id_txt := v_despues ->> 'id';
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_antes, datos_despues)
        values (tg_table_name, case when v_id_txt ~ '^[0-9]+$' then v_id_txt::bigint end,
                'UPDATE', public._bitacora_recortar(v_antes), public._bitacora_recortar(v_despues));
        return new;

    elsif tg_op = 'DELETE' then
        v_antes  := to_jsonb(old);
        v_id_txt := v_antes ->> 'id';
        insert into public.bitacora_cambios (tabla, registro_id, accion, datos_antes)
        values (tg_table_name, case when v_id_txt ~ '^[0-9]+$' then v_id_txt::bigint end,
                'DELETE', public._bitacora_recortar(v_antes));
        return old;
    end if;
    return null;
end;
$$;

revoke all on function public.fn_bitacora_generica() from public, anon, authenticated;
revoke all on function public._bitacora_recortar(jsonb) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 3. Triggers en las tablas de negocio (solo en las que existan)
-- ---------------------------------------------------------------------
do $$
declare
    v_tabla text;
    v_tablas text[] := array[
        -- catálogos y datos maestros
        'productos', 'bom', 'producto_claves_proveedor', 'proveedores', 'clientes',
        'listas_precio', 'lista_precio_items', 'empleados', 'unidades_medida', 'monedas',
        'centros_costo', 'areas_fisicas', 'areas_fisicas_cargas',
        'reparto_plantillas', 'reparto_plantilla_lineas', 'costos_config', 'alertas_caducidad_umbrales',
        -- compras / abasto
        'requisiciones_compra', 'requisiciones_compra_detalle',
        'ordenes_compra', 'ordenes_compra_detalle', 'pre_recibos', 'recibo_costos_adicionales',
        -- ventas, inventario y producción
        'documentos', 'pedidos_venta', 'pedidos_venta_detalle',
        'auditorias_inventario', 'auditoria_items', 'inventario_deterioros',
        'ordenes_produccion',
        -- finanzas
        'gastos', 'polizas', 'pagos_proveedor', 'cobros_cliente',
        'nominas', 'nomina_detalles', 'prorrateo_corridas',
        -- ya tenían bitácora: se recrean con la función mejorada
        'cuentas_contables', 'isr_tarifas', 'isr_tarifa_tramos', 'periodos_contables',
        'activos_fijos', 'devoluciones_cliente', 'devoluciones_proveedor', 'cuentas_bancarias'
    ];
begin
    foreach v_tabla in array v_tablas loop
        if to_regclass('public.' || v_tabla) is not null then
            execute format('drop trigger if exists trg_bitacora_%1$s on public.%1$I', v_tabla);
            execute format(
                'create trigger trg_bitacora_%1$s after insert or update or delete on public.%1$I '
                'for each row execute function public.fn_bitacora_generica()', v_tabla);
        end if;
    end loop;
end $$;


-- ---------------------------------------------------------------------
-- 4. Eventos de sesión (los llama la app al entrar y al salir)
-- ---------------------------------------------------------------------
create or replace function public.bitacora_evento(p_accion text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
    if auth.uid() is null then
        raise exception 'Se necesita una sesión iniciada.';
    end if;
    if upper(coalesce(p_accion, '')) not in ('LOGIN', 'LOGOUT') then
        raise exception 'Evento no permitido: %', p_accion;
    end if;
    insert into public.bitacora_cambios (tabla, accion)
    values ('sesion', upper(p_accion));
end;
$$;

revoke all     on function public.bitacora_evento(text) from public, anon;
grant  execute on function public.bitacora_evento(text) to authenticated;

commit;

-- Para revisar después de correrla:
--   select tabla, count(*) from public.bitacora_cambios group by 1 order by 2 desc;
--   select usuario_email, accion, tabla, creado_at from public.bitacora_cambios order by id desc limit 20;
