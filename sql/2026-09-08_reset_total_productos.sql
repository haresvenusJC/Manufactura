-- =====================================================================
--  RESET TOTAL DE CATÁLOGO — borra productos y TODAS sus dependencias
--  Fecha: 2026-09-08  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  ⚠️  ESTO ES LO CONTRARIO del reset de sql/2026-09-05_reset_paso_a_paso.sql.
--      Aquel preservaba productos ("sin borrar los artículos"). Este SÍ
--      los borra, junto con BOM, claves de proveedor, precios especiales
--      y las tareas de inventario que ya no aplicarían. Es un catálogo
--      en cero, no solo transacciones en cero.
--
--  BORRA:
--    productos, bom, producto_claves_proveedor, lista_precio_items,
--    tareas (solo las de entidad_tipo = 'producto'),
--    + red de seguridad (por si el reset del 09-05 no se corrió antes):
--    movimientos_inventario, documento_detalles, lotes_inventario,
--    ordenes_compra_detalle, orden_produccion_proceso_empleados,
--    orden_produccion_procesos, ordenes_produccion.
--
--  NO TOCA (siguen intactos): proveedores, clientes, empleados,
--    cuentas_contables, tipos_movimiento, unidades_medida, monedas,
--    procesos_produccion, c_uso_cfdi/c_forma_pago/c_metodo_pago,
--    plantillas_*, listas_precio (el encabezado de la lista, solo se
--    vacían sus renglones), documentos/polizas/gastos/pagos/ordenes_compra
--    (ya deberían estar en 0 por el reset anterior; no se tocan aquí),
--    contadores_documentos, nómina, auth.*.
--
--  ANTES DE CORRER: el PASO 0 hace un snapshot de lo que se va a borrar
--  a tablas espejo _bkp2_*. Si además quieres un respaldo completo de
--  Supabase, hazlo desde Database -> Backups.
--
--  Idempotente (TRUNCATE/DELETE guardados con to_regclass; ninguna
--  columna, función, trigger ni policy se toca).
-- =====================================================================


-- =====================================================================
--  PASO 0  ·  Snapshot de lo que se va a borrar (respaldo local)
-- =====================================================================
do $$
declare
    t      text;
    n      bigint;
    tablas text[] := array['productos', 'bom', 'producto_claves_proveedor', 'lista_precio_items'];
begin
    foreach t in array tablas loop
        if to_regclass('public.' || t) is null then continue; end if;
        execute format('drop table if exists public.%I', '_bkp2_' || t);
        execute format('create table public.%I as table public.%I', '_bkp2_' || t, t);
        execute format('select count(*) from public.%I', '_bkp2_' || t) into n;
        raise notice 'snapshot: _bkp2_%  (% filas)', rpad(t, 28), n;
    end loop;
    raise notice 'Snapshot listo en _bkp2_*. No se ve afectado por los pasos siguientes.';
end $$;


-- =====================================================================
--  PASO 1  ·  DRY RUN — solo cuenta, no borra nada.
-- =====================================================================
do $$
declare
    t   text;
    n   bigint;
    tot bigint := 0;
    tablas text[] := array[
        'movimientos_inventario', 'documento_detalles', 'lotes_inventario',
        'ordenes_compra_detalle', 'registros_tiempo', 'solicitudes_reasignacion',
        'orden_produccion_proceso_empleados',
        'orden_produccion_procesos', 'ordenes_produccion',
        'bom', 'producto_claves_proveedor', 'lista_precio_items',
        'productos'
    ];
begin
    raise notice '--- filas actuales ---';
    foreach t in array tablas loop
        if to_regclass('public.' || t) is null then
            raise notice '  %  (no existe, se omite)', rpad(t, 38);
            continue;
        end if;
        execute format('select count(*) from public.%I', t) into n;
        raise notice '  %  %', rpad(t, 38), n;
        tot := tot + n;
    end loop;
    raise notice '--- TOTAL: % filas ---', tot;
    raise notice 'tareas de producto que se borrarán: %',
        (select count(*) from public.tareas where entidad_tipo = 'producto');
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 2 · Red de seguridad — por si sql/2026-09-05 no se corrió antes
--    Guarda   : kardex, partidas, lotes, recepciones/entregas de OC,
--               equipo/procesos/órdenes de producción, cronómetros y
--               solicitudes de reasignación — TODO cuelga de un producto
--               (directo o vía orden_produccion_procesos), así que debe
--               quedar en 0 antes de borrar productos. Van todas en el
--               mismo TRUNCATE porque registros_tiempo y
--               solicitudes_reasignacion tienen FK hacia
--               orden_produccion_procesos: Postgres exige truncarlas
--               juntas aunque ya estén vacías.
--    Al vaciar : si ya estaban en 0 (por el reset del 09-05), este paso
--               no hace nada.
-- ─────────────────────────────────────────────────────────────────────
do $$
declare
    t          text;
    existentes text[] := array[]::text[];
    candidatos text[] := array[
        'movimientos_inventario', 'documento_detalles', 'lotes_inventario',
        'ordenes_compra_detalle', 'registros_tiempo', 'solicitudes_reasignacion',
        'orden_produccion_proceso_empleados',
        'orden_produccion_procesos', 'ordenes_produccion'
    ];
begin
    foreach t in array candidatos loop
        if to_regclass('public.' || t) is not null then
            existentes := array_append(existentes, format('public.%I', t));
        end if;
    end loop;

    if array_length(existentes, 1) is null then
        raise notice 'PASO 2  ninguna tabla de la lista existe, omitido';
    else
        execute 'truncate table ' || array_to_string(existentes, ', ') || ' restart identity';
        raise notice 'PASO 2  red de seguridad truncada: %', array_to_string(existentes, ', ');
    end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 3 · bom
--    Guarda   : qué componentes/insumos lleva cada producto terminado
--               (producto_id = el fabricado, componente_id = el insumo;
--               ambos apuntan a productos)
--    La llena  : Catálogo -> ficha de producto, sección BOM
--    Al vaciar : las recetas desaparecen junto con los productos
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.bom') is null then
    raise notice 'PASO 3  bom: no existe, omitido';
  else
    raise notice 'PASO 3  bom: % filas -> 0', (select count(*) from public.bom);
    truncate table public.bom restart identity;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 4 · producto_claves_proveedor
--    Guarda   : claves del proveedor por producto (para conciliar XML)
--    La llena  : Catálogo -> "Claves de proveedor"
--    Al vaciar : se van junto con los productos; proveedores NO se toca
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.producto_claves_proveedor') is null then
    raise notice 'PASO 4  producto_claves_proveedor: no existe, omitido';
  else
    raise notice 'PASO 4  producto_claves_proveedor: % filas -> 0',
      (select count(*) from public.producto_claves_proveedor);
    truncate table public.producto_claves_proveedor restart identity;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 5 · lista_precio_items
--    Guarda   : precio especial de un producto dentro de una lista de precios
--    La llena  : Clientes -> Listas de precio
--    Al vaciar : se van los renglones; el ENCABEZADO de cada lista
--               (listas_precio: nombre, cliente, vigencia) NO se toca
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.lista_precio_items') is null then
    raise notice 'PASO 5  lista_precio_items: no existe, omitido';
  else
    raise notice 'PASO 5  lista_precio_items: % filas -> 0',
      (select count(*) from public.lista_precio_items);
    truncate table public.lista_precio_items restart identity;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 6 · tareas de producto (no tienen FK; quedarían huérfanas)
--    Guarda   : las tareas "inventario_bajo_minimo" generadas por producto
--    Al vaciar : desaparecen (ya no hay producto al que referirse); las
--               tareas de OTRO tipo (a futuro) no se tocan
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.tareas') is null then
    raise notice 'PASO 6  tareas: no existe, omitido';
  else
    raise notice 'PASO 6  tareas de producto: % filas -> 0',
      (select count(*) from public.tareas where entidad_tipo = 'producto');
    delete from public.tareas where entidad_tipo = 'producto';
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 7 · productos   (EL BORRADO FINAL — irreversible sin el PASO 0)
--    Van en el MISMO truncate todas las tablas que tienen una FK hacia
--    productos (bom, producto_claves_proveedor, lista_precio_items,
--    ordenes_compra_detalle, ordenes_produccion, documento_detalles,
--    movimientos_inventario, lotes_inventario) más las que a su vez
--    cuelgan de ordenes_produccion (orden_produccion_procesos,
--    registros_tiempo, solicitudes_reasignacion,
--    orden_produccion_proceso_empleados). Postgres exige truncar todo
--    ese grupo junto aunque ya esté vacío por los PASOS 2-6 — es la
--    sola EXISTENCIA de la constraint la que lo exige, no los datos.
--    Al vaciar : el catálogo queda en cero. Los ids vuelven a arrancar
--               en 1 (restart identity). unidades_medida, monedas,
--               proveedores, cuentas_contables, etc. NO se tocan.
-- ─────────────────────────────────────────────────────────────────────
do $$
declare
    t          text;
    n          bigint;
    existentes text[] := array[]::text[];
    candidatos text[] := array[
        'movimientos_inventario', 'documento_detalles', 'lotes_inventario',
        'ordenes_compra_detalle', 'registros_tiempo', 'solicitudes_reasignacion',
        'orden_produccion_proceso_empleados', 'orden_produccion_procesos',
        'ordenes_produccion', 'bom', 'producto_claves_proveedor',
        'lista_precio_items', 'productos'
    ];
begin
    execute 'select count(*) from public.productos' into n;
    raise notice 'PASO 7  productos: % filas -> 0', n;

    foreach t in array candidatos loop
        if to_regclass('public.' || t) is not null then
            existentes := array_append(existentes, format('public.%I', t));
        end if;
    end loop;

    execute 'truncate table ' || array_to_string(existentes, ', ') || ' restart identity';
    raise notice 'PASO 7  truncado junto (por dependencia de FK): %', array_to_string(existentes, ', ');
end $$;


-- =====================================================================
--  VERIFICACIÓN (opcional)
-- =====================================================================
-- select 'productos' t, count(*) n from public.productos
-- union all select 'bom', count(*) from public.bom
-- union all select 'producto_claves_proveedor', count(*) from public.producto_claves_proveedor
-- union all select 'lista_precio_items', count(*) from public.lista_precio_items
-- union all select 'tareas de producto', count(*) from public.tareas where entidad_tipo = 'producto'
-- union all select '--- deben seguir intactos ---', null
-- union all select 'proveedores', count(*) from public.proveedores
-- union all select 'clientes', count(*) from public.clientes
-- union all select 'listas_precio (encabezados)', count(*) from public.listas_precio
-- union all select 'cuentas_contables', count(*) from public.cuentas_contables;


-- =====================================================================
--  RESTAURAR desde el snapshot _bkp2_* (si te arrepientes)
-- =====================================================================
-- begin;
--   truncate table public.productos restart identity cascade;
--   insert into public.productos overriding system value select * from public._bkp2_productos;
--   select setval(pg_get_serial_sequence('public.productos','id'), (select coalesce(max(id),1) from public.productos));
--
--   truncate table public.bom restart identity;
--   insert into public.bom overriding system value select * from public._bkp2_bom;
--
--   truncate table public.producto_claves_proveedor restart identity;
--   insert into public.producto_claves_proveedor overriding system value select * from public._bkp2_producto_claves_proveedor;
--
--   truncate table public.lista_precio_items restart identity;
--   insert into public.lista_precio_items overriding system value select * from public._bkp2_lista_precio_items;
-- commit;


-- =====================================================================
--  Limpieza de los espejos _bkp2_* (corre cuando ya no los necesites)
-- =====================================================================
-- do $$
-- declare r record;
-- begin
--     for r in select tablename from pg_tables where schemaname = 'public' and tablename like '\_bkp2\_%'
--     loop
--         execute format('drop table if exists public.%I', r.tablename);
--         raise notice 'drop %', r.tablename;
--     end loop;
-- end $$;
