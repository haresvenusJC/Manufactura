-- =====================================================================
--  FRESH START COMPLETO — borra TODOS los datos de prueba (incluidos
--  proveedores, clientes y empleados) y deja la base lista para
--  arrancar operación real, conservando SOLO configuración de sistema.
--  Fecha: 2026-09-11  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor,
--  en el orden PASO 1 -> PASO 2 -> PASO 3 -> PASO 4, cada uno como una
--  ejecución ("Run") separada.
--
--  SE CONSERVA (no se toca):
--    cuentas_contables, centros_costo, areas_fisicas, areas_fisicas_cargas,
--    reparto_plantillas, reparto_plantilla_lineas, tipos_movimiento,
--    unidades_medida, monedas, c_uso_cfdi, c_forma_pago, c_metodo_pago,
--    plantillas_documentos, isr_tarifas, isr_tarifa_tramos, costos_config,
--    procesos_produccion, clientes, empleados, listas_precio, nominas,
--    nomina_detalles, tareas, alertas_caducidad_umbrales, y todo auth.*
--    (no se toca ningún schema fuera de "public").
--
--  SE BORRA: todo lo demás en el schema public — incluye productos,
--  proveedores, documentos, polizas, movimientos de inventario, órdenes
--  de compra/producción, pagos, gastos, etc.
--
--  Cómo evita el "whack-a-mole" de FKs que ya pasó 3 veces en este
--  proyecto (gastos, gasto_aplicaciones, reparto_plantillas...): en vez
--  de listar a mano el orden de borrado, PASO 4 descubre el orden
--  correcto en tiempo de ejecución consultando pg_constraint — encuentra
--  qué tablas "hoja" (nada más las referencia) puede vaciar primero,
--  las quita de la lista, y repite hasta vaciar todo. Si el esquema
--  cambia más adelante (nuevas tablas/FKs), este script se sigue
--  adaptando solo.
-- =====================================================================


-- =====================================================================
--  PASO 1 · DRY RUN — solo MUESTRA qué se borraría y en qué orden.
--  No borra nada. Correr y revisar el resultado (aparece como tabla,
--  no como "Success. No rows returned").
-- =====================================================================
create temp table if not exists _fresh_orden (ord int, tabla text, filas bigint);
delete from _fresh_orden;

do $$
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
       and tablename not like '\_bkp%' escape '\'
       and tablename <> '_fresh_orden';

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
        insert into _fresh_orden values (i, hoja, n);
        restante := array_remove(restante, hoja);
    end loop;
end $$;

select ord as orden, tabla, filas as filas_actuales from _fresh_orden order by ord;


-- =====================================================================
--  PASO 2 · PREVIO DE DECISIÓN — muestra TODO el contenido (todas las
--  filas, todas las columnas) de las tablas que se borrarían. Solo
--  lectura, no borra ni modifica nada. Úsalo para revisar a detalle
--  antes de decidir si sigues con el PASO 3/4.
--
--  Cada renglón del resultado es una fila real de alguna de esas tablas,
--  con sus columnas empacadas en "fila" (jsonb) — así funciona aunque
--  cada tabla tenga columnas distintas.
--
--  Para ver solo una tabla, corre después:
--    select fila from _fresh_datos where tabla = 'proveedores';
--  Si el resultado es muy grande, agrega "limit 200" al final del
--  select principal, o filtra por tabla como arriba.
-- =====================================================================
create temp table if not exists _fresh_datos (tabla text, fila jsonb);
delete from _fresh_datos;

do $$
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
       and tablename not in ('_fresh_orden', '_fresh_datos');

    if restante is null then
        raise notice 'PASO 2  nada que mostrar (lista vacía)';
        return;
    end if;

    foreach t in array restante loop
        execute format(
            'insert into _fresh_datos select %L, to_jsonb(x.*) from public.%I x',
            t, t
        );
    end loop;
end $$;

select tabla, fila from _fresh_datos order by tabla;


-- =====================================================================
--  PASO 3 · SNAPSHOT — respaldo de cada tabla que se va a borrar, en
--  tablas espejo "_bkp_fresh_<tabla>". No borra nada, es seguro correrlo
--  aunque luego decidas no seguir con el PASO 4.
-- =====================================================================
do $$
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
       and tablename <> '_fresh_orden';

    if restante is null then
        raise notice 'PASO 3  nada que respaldar (lista vacía)';
        return;
    end if;

    foreach t in array restante loop
        execute format('drop table if exists public.%I', '_bkp_fresh_' || t);
        execute format('create table public.%I as table public.%I', '_bkp_fresh_' || t, t);
        raise notice 'PASO 3  snapshot listo: _bkp_fresh_%', t;
    end loop;
end $$;


-- =====================================================================
--  PASO 4 · BORRADO REAL — requiere autorización explícita.
--
--  Antes de correr esto: cambia la línea "confirmo boolean := false"
--  de abajo a "true". Mientras diga false, el script se detiene sin
--  borrar nada (es la forma de "preguntar antes de borrar" sin depender
--  de un cuadro de diálogo que el SQL Editor no tiene).
-- =====================================================================
do $$
declare
    confirmo boolean := false;   -- <<< cambia a true para autorizar el borrado
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
    hoja     text;
    encontro boolean;
    v_seq    text;
begin
    if not confirmo then
        raise exception 'PASO 4 detenido: cambia "confirmo" a true en este script para autorizar el borrado total.';
    end if;

    select array_agg(tablename) into restante
      from pg_tables
     where schemaname = 'public'
       and tablename <> all (preservar)
       and tablename not like '\_bkp%' escape '\'
       and tablename <> '_fresh_orden';

    if restante is null then
        raise notice 'PASO 4  nada que borrar (lista vacía)';
        return;
    end if;

    while array_length(restante,1) > 0 loop
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
            raise exception 'PASO 4  ciclo de FKs detectado entre: %  (revisar a mano, no se borró nada más)', array_to_string(restante, ', ');
        end if;

        execute format('delete from public.%I', hoja);

        v_seq := pg_get_serial_sequence(format('public.%I', hoja), 'id');
        if v_seq is not null then
            execute 'alter sequence ' || v_seq || ' restart with 1';
        end if;

        raise notice 'PASO 4  borrado: %  (secuencia id reiniciada: %)', hoja, coalesce(v_seq, 'n/a');
        restante := array_remove(restante, hoja);
    end loop;

    raise notice 'PASO 4  listo — fresh start completo.';
end $$;


-- =====================================================================
--  VERIFICACIÓN (opcional, correr después del PASO 4)
-- =====================================================================
-- select 'proveedores' t, count(*) n from public.proveedores
-- union all select 'clientes', count(*) from public.clientes
-- union all select 'empleados', count(*) from public.empleados
-- union all select 'documentos', count(*) from public.documentos
-- union all select '--- deben seguir intactas ---', null
-- union all select 'cuentas_contables', count(*) from public.cuentas_contables
-- union all select 'tipos_movimiento', count(*) from public.tipos_movimiento
-- union all select 'unidades_medida', count(*) from public.unidades_medida;


-- =====================================================================
--  LIMPIEZA de los snapshots _bkp_fresh_* (corre cuando ya no los
--  necesites — pueden pesar bastante si había muchos datos de prueba).
-- =====================================================================
-- do $$
-- declare t text;
-- begin
--     for t in select tablename from pg_tables
--               where schemaname='public' and tablename like '\_bkp\_fresh\_%' escape '\'
--     loop
--         execute format('drop table if exists public.%I', t);
--     end loop;
-- end $$;
