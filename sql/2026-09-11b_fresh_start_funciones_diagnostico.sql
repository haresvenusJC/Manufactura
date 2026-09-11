-- =====================================================================
--  Funciones de SOLO LECTURA para el módulo "Fresh start" de la app
--  (Configuración -> Fresh start / mantenimiento).
--  Fecha: 2026-09-11  ·  Proyecto: Hares de México (Supabase)
--
--  Corresponden a los PASO 1 y PASO 2 de
--  sql/2026-09-11_reset_fresh_start_completo.sql (conteos + previo de
--  datos). NO borran ni modifican nada — solo consultan pg_catalog y
--  hacen SELECT sobre las tablas candidatas a borrarse.
--
--  El PASO 3 (snapshot) y el PASO 4 (borrado real, con el flag
--  "confirmo") siguen siendo EXCLUSIVAMENTE manuales en Supabase ->
--  SQL Editor — la app solo le muestra ese SQL al usuario para copiar,
--  nunca lo ejecuta.
-- =====================================================================

begin;

create or replace function public.fresh_start_preview_conteos()
returns table(orden int, tabla text, filas bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
    preservar text[] := array[
        'cuentas_contables','centros_costo','areas_fisicas','areas_fisicas_cargas',
        'reparto_plantillas','reparto_plantilla_lineas','tipos_movimiento',
        'unidades_medida','monedas','c_uso_cfdi','c_forma_pago','c_metodo_pago',
        'plantillas_documentos','isr_tarifas','isr_tarifa_tramos','costos_config',
        'procesos_produccion',
        'clientes','empleados','listas_precio','nominas','nomina_detalles',
        'tareas','alertas_caducidad_umbrales'
    ];
    restante  text[];
    t         text;
    hoja      text;
    encontro  boolean;
    n         bigint;
    i         int := 0;
begin
    select array_agg(tablename) into restante
      from pg_tables
     where schemaname = 'public'
       and tablename <> all (preservar)
       and tablename not like '\_bkp%' escape '\';

    while restante is not null and array_length(restante,1) > 0 loop
        encontro := false;
        foreach t in array restante loop
            perform 1
              from pg_constraint con
              join pg_class cl    on cl.oid = con.conrelid
              join pg_class clref on clref.oid = con.confrelid
              join pg_namespace ns on ns.oid = cl.relnamespace and ns.nspname = 'public'
             where con.contype = 'f'
               and clref.relname = t
               and cl.relname <> t
               and cl.relname = any (restante);
            if not found then
                hoja := t;
                encontro := true;
                exit;
            end if;
        end loop;

        if not encontro then
            raise exception 'Ciclo de FKs detectado entre: %  (revisar a mano)', array_to_string(restante, ', ');
        end if;

        i := i + 1;
        execute format('select count(*) from public.%I', hoja) into n;
        orden := i;
        tabla := hoja;
        filas := n;
        return next;
        restante := array_remove(restante, hoja);
    end loop;
end;
$$;

revoke all on function public.fresh_start_preview_conteos() from public;
grant execute on function public.fresh_start_preview_conteos() to authenticated;


create or replace function public.fresh_start_preview_datos(p_tabla text default null)
returns table(tabla text, fila jsonb)
language plpgsql
security definer
set search_path = public
as $$
declare
    preservar text[] := array[
        'cuentas_contables','centros_costo','areas_fisicas','areas_fisicas_cargas',
        'reparto_plantillas','reparto_plantilla_lineas','tipos_movimiento',
        'unidades_medida','monedas','c_uso_cfdi','c_forma_pago','c_metodo_pago',
        'plantillas_documentos','isr_tarifas','isr_tarifa_tramos','costos_config',
        'procesos_produccion',
        'clientes','empleados','listas_precio','nominas','nomina_detalles',
        'tareas','alertas_caducidad_umbrales'
    ];
    restante text[];
    t        text;
begin
    select array_agg(tablename) into restante
      from pg_tables
     where schemaname = 'public'
       and tablename <> all (preservar)
       and tablename not like '\_bkp%' escape '\'
       and (p_tabla is null or tablename = p_tabla);

    if restante is null then
        return;
    end if;

    foreach t in array restante loop
        return query execute format(
            'select %L::text, to_jsonb(x.*) from public.%I x', t, t
        );
    end loop;
end;
$$;

revoke all on function public.fresh_start_preview_datos(text) from public;
grant execute on function public.fresh_start_preview_datos(text) to authenticated;

commit;
