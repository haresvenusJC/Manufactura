-- =====================================================================
--  RESET PASO A PASO de datos transaccionales — deja el sistema "virgen"
--  Fecha: 2026-09-05  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Se pega y se corre A MANO en Supabase -> SQL Editor.
--
--  Sustituye al TRUNCATE global de sql/2026-09-04_reset_datos_transaccionales.sql.
--  Aquí cada tabla se vacía en SU PROPIO PASO, en orden hijo -> padre (para no
--  chocar con llaves foráneas), y cada paso primero DICE cuántas filas tiene y
--  luego las borra. Corre un PASO, revisa el NOTICE, y pasa al siguiente.
--
--  CÓMO PROBAR UN PASO SIN CONFIRMARLO:
--      begin;
--        <pega aquí el bloque del PASO>
--      rollback;         -- <- no se guarda nada; solo ves el conteo
--
--  QUÉ NO SE TOCA (ni filas ni estructura):
--      productos (solo stock_actual -> 0; costo_unitario se conserva),
--      bom, producto_claves_proveedor, proveedores, clientes, empleados,
--      cuentas_contables, tipos_movimiento, unidades_medida, monedas,
--      procesos_produccion, c_uso_cfdi / c_forma_pago / c_metodo_pago,
--      plantillas_*, listas_precio, lista_precio_items, tabla ISR,
--      y todo auth.*  ·  Ninguna función, trigger, policy ni migración.
--
--  No hay DROP ni ALTER de columnas. Solo DELETE + un UPDATE (stock -> 0)
--  + (opcional, PASO 23) ALTER SEQUENCE para que los id arranquen en 1.
--
--  ANTES DE EMPEZAR: respaldo. Elige uno —
--    · Supabase -> Database -> Backups -> "Restore to new project", ó
--    · pg_dump "...connection string..." -Fc -f respaldo_pre_reset.dump, ó
--    · la PARTE 0 de sql/2026-09-04_reset_datos_transaccionales.sql
--      (copia a espejos _bkp_* las tablas que se conservan).
-- =====================================================================


-- =====================================================================
--  PASO 0  ·  DRY RUN — solo cuenta, NO borra nada. Córrelo primero.
-- =====================================================================
do $$
declare
    t   text;
    n   bigint;
    tot bigint := 0;
    tablas text[] := array[
        'registros_tiempo',
        'solicitudes_reasignacion',
        'orden_produccion_proceso_empleados',
        'orden_produccion_procesos',
        'ordenes_produccion',
        'sesiones_ot',
        'movimientos_inventario',
        'pagos_proveedor_aplicaciones',
        'pagos_proveedor',
        'documento_detalles',
        'lotes_inventario',
        'gastos',
        'documentos',
        'poliza_movimientos',
        'polizas',
        'ordenes_compra_detalle',
        'ordenes_compra',
        'contadores_documentos',
        'auditoria',
        'tareas'
    ];
begin
    raise notice '--- filas actuales (lo que borrarían los PASOS 1..19 + opcionales) ---';
    foreach t in array tablas loop
        if to_regclass('public.' || t) is null then
            raise notice '  %  (no existe, se omite)', rpad(t, 38);
            continue;
        end if;
        execute format('select count(*) from public.%I', t) into n;
        raise notice '  %  %', rpad(t, 38), n;
        tot := tot + n;
    end loop;

    raise notice '--- nómina (PASO 7, se vacía como bloque) ---';
    for t in
        select tablename from pg_tables
        where schemaname = 'public' and tablename like 'nomina%'
        order by tablename
    loop
        execute format('select count(*) from public.%I', t) into n;
        raise notice '  %  %', rpad(t, 38), n;
        tot := tot + n;
    end loop;

    raise notice '--- TOTAL a borrar: % filas ---', tot;
    raise notice 'productos que se conservan (stock -> 0, costo_unitario intacto): %',
        (select count(*) from public.productos);
end $$;


-- =====================================================================
--  A partir de aquí cada PASO BORRA. Corre uno, lee el NOTICE, sigue.
--  Orden = hijo -> padre. Si un PASO falla nombrando otra tabla, esa
--  tabla tiene una FK hacia lo que borras: pásame el nombre del error.
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
--  PASO 1 · registros_tiempo
--    Guarda   : marcas de inicio/paro de cronómetro por empleado y proceso
--    La llena  : Orden de Trabajo (pantalla móvil)
--    Depende de: orden_produccion_procesos (PASO 4), empleados (se conserva)
--    Al vaciar : se pierden los tiempos capturados; nada más
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.registros_tiempo') is null then
    raise notice 'PASO 1  registros_tiempo: no existe, omitido';
  else
    raise notice 'PASO 1  registros_tiempo: % filas -> 0',
      (select count(*) from public.registros_tiempo);
    delete from public.registros_tiempo;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 2 · solicitudes_reasignacion
--    Guarda   : peticiones de operarios para entrar a un proceso ajeno
--    La llena  : Orden de Trabajo (rpc ot_solicitar_reasignacion)
--    Depende de: orden_produccion_procesos (PASO 4), empleados (se conserva)
--    Al vaciar : cero solicitudes pendientes; el flujo sigue funcionando
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.solicitudes_reasignacion') is null then
    raise notice 'PASO 2  solicitudes_reasignacion: no existe, omitido';
  else
    raise notice 'PASO 2  solicitudes_reasignacion: % filas -> 0',
      (select count(*) from public.solicitudes_reasignacion);
    delete from public.solicitudes_reasignacion;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 3 · orden_produccion_proceso_empleados
--    Guarda   : el equipo (checkboxes) asignado a cada proceso de una orden
--    La llena  : Producción, al generar la orden
--    Depende de: orden_produccion_procesos (PASO 4), empleados (se conserva)
--    Al vaciar : se va junto con las órdenes de producción
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.orden_produccion_proceso_empleados') is null then
    raise notice 'PASO 3  orden_produccion_proceso_empleados: no existe, omitido';
  else
    raise notice 'PASO 3  orden_produccion_proceso_empleados: % filas -> 0',
      (select count(*) from public.orden_produccion_proceso_empleados);
    delete from public.orden_produccion_proceso_empleados;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 4 · orden_produccion_procesos
--    Guarda   : los procesos (Pesaje, Envasado, ...) de cada orden
--    La llena  : Producción
--    Depende de: ordenes_produccion (PASO 5)
--    Al vaciar : se va junto con las órdenes; procesos_produccion (catálogo) NO se toca
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.orden_produccion_procesos') is null then
    raise notice 'PASO 4  orden_produccion_procesos: no existe, omitido';
  else
    raise notice 'PASO 4  orden_produccion_procesos: % filas -> 0',
      (select count(*) from public.orden_produccion_procesos);
    delete from public.orden_produccion_procesos;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 5 · ordenes_produccion
--    Guarda   : las órdenes de producción (abiertas y cerradas)
--    La llena  : Producción
--    Depende de: productos (se conserva)
--    Al vaciar : historial de producción en 0; el BOM y los procesos NO se tocan
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.ordenes_produccion') is null then
    raise notice 'PASO 5  ordenes_produccion: no existe, omitido';
  else
    raise notice 'PASO 5  ordenes_produccion: % filas -> 0',
      (select count(*) from public.ordenes_produccion);
    delete from public.ordenes_produccion;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 6 · sesiones_ot
--    Guarda   : la sesión activa del móvil (token + expiración)
--    La llena  : rpc ot_login
--    Depende de: empleados (se conserva)
--    Al vaciar : los operarios vuelven a ingresar su PIN. Nada más.
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.sesiones_ot') is null then
    raise notice 'PASO 6  sesiones_ot: no existe, omitido';
  else
    raise notice 'PASO 6  sesiones_ot: % filas -> 0',
      (select count(*) from public.sesiones_ot);
    delete from public.sesiones_ot;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 7 · Nómina  (se vacía como bloque: todas las tablas nomina*)
--    Guarda   : periodos de nómina, renglones por empleado y su desglose
--               de percepciones/deducciones
--    La llena  : módulo Nómina
--    Depende de: empleados (se conserva) y, si aplica, polizas -> por eso
--               este PASO va ANTES del PASO 16 (polizas)
--    Al vaciar : historial de nómina en 0; catálogos de conceptos, tabla
--               ISR y empleados NO se tocan
--    Nota      : es un TRUNCATE del subconjunto nomina* (resuelve las FKs
--               entre esas tablas). Si falla nombrando una tabla que NO
--               empieza con "nomina", pásame ese nombre.
-- ─────────────────────────────────────────────────────────────────────
do $$
declare
    t     text;
    n     bigint;
    lista text := '';
begin
    for t in
        select tablename from pg_tables
        where schemaname = 'public' and tablename like 'nomina%'
        order by tablename
    loop
        execute format('select count(*) from public.%I', t) into n;
        raise notice 'PASO 7  %  -> 0  (% filas)', rpad(t, 34), n;
        lista := lista || case when lista = '' then '' else ', ' end
                 || format('public.%I', t);
    end loop;

    if lista = '' then
        raise notice 'PASO 7  no hay tablas de nómina, omitido';
    else
        execute 'truncate table ' || lista || ' restart identity';
        raise notice 'PASO 7  nómina truncada: %', lista;
    end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 8 · movimientos_inventario  (KARDEX)
--    Guarda   : cada entrada/salida con costo, lote y documento origen
--    La llena  : rpc FIFO (compras, salidas, producción, recibo de mercancía)
--    Depende de: documentos (PASO 14), lotes_inventario (PASO 12), productos (se conserva)
--    Al vaciar : kardex vacío; sin historial de costos por movimiento
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.movimientos_inventario') is null then
    raise notice 'PASO 8  movimientos_inventario: no existe, omitido';
  else
    raise notice 'PASO 8  movimientos_inventario: % filas -> 0',
      (select count(*) from public.movimientos_inventario);
    delete from public.movimientos_inventario;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 9 · pagos_proveedor_aplicaciones
--    Guarda   : qué documento de compra o gasto pagó cada pago, y con cuánto
--    La llena  : Contabilidad -> Cuentas por pagar
--    Depende de: pagos_proveedor (PASO 10), documentos (PASO 14), gastos (PASO 13)
--    Al vaciar : se va junto con los pagos
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.pagos_proveedor_aplicaciones') is null then
    raise notice 'PASO 9  pagos_proveedor_aplicaciones: no existe, omitido';
  else
    raise notice 'PASO 9  pagos_proveedor_aplicaciones: % filas -> 0',
      (select count(*) from public.pagos_proveedor_aplicaciones);
    delete from public.pagos_proveedor_aplicaciones;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 10 · pagos_proveedor
--    Guarda   : los pagos registrados a proveedores (egresos)
--    La llena  : Contabilidad -> Cuentas por pagar (rpc registrar_pago_proveedor)
--    Depende de: polizas (PASO 16), proveedores / cuentas_contables (se conservan)
--    Al vaciar : historial de pagos en 0; los saldos por pagar se recalculan solos
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.pagos_proveedor') is null then
    raise notice 'PASO 10  pagos_proveedor: no existe, omitido';
  else
    raise notice 'PASO 10  pagos_proveedor: % filas -> 0',
      (select count(*) from public.pagos_proveedor);
    delete from public.pagos_proveedor;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 11 · documento_detalles
--    Guarda   : los renglones (partidas) de cada documento
--    La llena  : Compras, Salidas, Producción, Recibo de mercancía
--    Depende de: documentos (PASO 14), productos (se conserva)
--    Al vaciar : se va junto con los documentos
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.documento_detalles') is null then
    raise notice 'PASO 11  documento_detalles: no existe, omitido';
  else
    raise notice 'PASO 11  documento_detalles: % filas -> 0',
      (select count(*) from public.documento_detalles);
    delete from public.documento_detalles;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 12 · lotes_inventario
--    Guarda   : los lotes con su stock, costo, caducidad y lote del proveedor
--    La llena  : rpc FIFO
--    Depende de: documentos (PASO 14), productos (se conserva)
--    Al vaciar : sin lotes -> el stock real queda en 0 (se refuerza en el PASO 20)
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.lotes_inventario') is null then
    raise notice 'PASO 12  lotes_inventario: no existe, omitido';
  else
    raise notice 'PASO 12  lotes_inventario: % filas -> 0',
      (select count(*) from public.lotes_inventario);
    delete from public.lotes_inventario;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 13 · gastos
--    Guarda   : las facturas de gasto capturadas
--    La llena  : Contabilidad -> Gastos
--    Depende de: polizas (PASO 16), documentos (PASO 14), proveedores (se conserva)
--    Al vaciar : historial de gastos en 0
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.gastos') is null then
    raise notice 'PASO 13  gastos: no existe, omitido';
  else
    raise notice 'PASO 13  gastos: % filas -> 0',
      (select count(*) from public.gastos);
    delete from public.gastos;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 14 · documentos
--    Guarda   : la cabecera de TODO documento (entradas, salidas, producción,
--               entrada_compra, recibos) + sus datos fiscales
--    La llena  : todos los módulos de movimiento
--    Depende de: polizas (PASO 16), ordenes_compra (PASO 18), proveedores (se conserva)
--    Al vaciar : documentos en 0; el consecutivo por tipo reinicia al vaciar el PASO 19
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.documentos') is null then
    raise notice 'PASO 14  documentos: no existe, omitido';
  else
    raise notice 'PASO 14  documentos: % filas -> 0',
      (select count(*) from public.documentos);
    delete from public.documentos;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 15 · poliza_movimientos
--    Guarda   : los renglones de cargo/abono de cada póliza
--    La llena  : rpc registrar_poliza
--    Depende de: polizas (PASO 16), cuentas_contables / proveedores (se conservan)
--    Al vaciar : se va junto con las pólizas
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.poliza_movimientos') is null then
    raise notice 'PASO 15  poliza_movimientos: no existe, omitido';
  else
    raise notice 'PASO 15  poliza_movimientos: % filas -> 0',
      (select count(*) from public.poliza_movimientos);
    delete from public.poliza_movimientos;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 16 · polizas
--    Guarda   : los asientos contables (Ingreso / Egreso / Diario)
--    La llena  : contabilizar_compra / contabilizar_* / pólizas manuales
--    Depende de: monedas (se conserva) y sí mismas (poliza_reversa_id)
--    Al vaciar : Balanza y Estado de resultados en 0; el PLAN DE CUENTAS NO se toca
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.polizas') is null then
    raise notice 'PASO 16  polizas: no existe, omitido';
  else
    raise notice 'PASO 16  polizas: % filas -> 0',
      (select count(*) from public.polizas);
    delete from public.polizas;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 17 · ordenes_compra_detalle
--    Guarda   : las partidas de cada orden de compra (pedido vs recibido)
--    La llena  : Entradas -> Órdenes de compra
--    Depende de: ordenes_compra (PASO 18), productos / unidades_medida (se conservan)
--    Al vaciar : se va junto con las OC
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.ordenes_compra_detalle') is null then
    raise notice 'PASO 17  ordenes_compra_detalle: no existe, omitido';
  else
    raise notice 'PASO 17  ordenes_compra_detalle: % filas -> 0',
      (select count(*) from public.ordenes_compra_detalle);
    delete from public.ordenes_compra_detalle;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 18 · ordenes_compra
--    Guarda   : las órdenes de compra (borrador, abierta, recibida, ...)
--    La llena  : Entradas -> Órdenes de compra
--    Depende de: proveedores / monedas (se conservan)
--    Al vaciar : sin OC pendientes; el módulo arranca limpio
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.ordenes_compra') is null then
    raise notice 'PASO 18  ordenes_compra: no existe, omitido';
  else
    raise notice 'PASO 18  ordenes_compra: % filas -> 0',
      (select count(*) from public.ordenes_compra);
    delete from public.ordenes_compra;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 19 · contadores_documentos
--    Guarda   : el consecutivo vivo por tipo_movimiento (entrada_compra #N, ...)
--    La llena  : el trigger fn_documentos_asignar_consecutivo al insertar
--    Depende de: nada
--    Al vaciar : el próximo documento de cada tipo vuelve a numerarse desde 1
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  if to_regclass('public.contadores_documentos') is null then
    raise notice 'PASO 19  contadores_documentos: no existe, omitido';
  else
    raise notice 'PASO 19  contadores_documentos: % filas -> 0',
      (select count(*) from public.contadores_documentos);
    delete from public.contadores_documentos;
  end if;
end $$;


-- ─────────────────────────────────────────────────────────────────────
--  PASO 20 · productos.stock_actual -> 0   (NO borra productos)
--    Por qué  : el stock real ya está en 0 al vaciar lotes_inventario (PASO 12);
--               esto sincroniza el saldo cacheado en el catálogo.
--    costo_unitario  : SE CONSERVA (último costo de compra). No se toca.
-- ─────────────────────────────────────────────────────────────────────
do $$
begin
  raise notice 'PASO 20  productos.stock_actual -> 0  (% filas; costo_unitario intacto)',
    (select count(*) from public.productos);
  update public.productos set stock_actual = 0;
end $$;


-- =====================================================================
--  PASOS OPCIONALES — no confirmados. Revísalos y corre solo si aplican.
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
--  PASO 21 (OPCIONAL) · auditoria
--    Guarda   : bitácora de cambios del sistema (si existe la tabla)
--    Al vaciar : se pierde el rastro histórico de auditoría. Nada funcional se rompe.
-- ─────────────────────────────────────────────────────────────────────
-- do $$
-- begin
--   if to_regclass('public.auditoria') is null then
--     raise notice 'PASO 21  auditoria: no existe, omitido';
--   else
--     raise notice 'PASO 21  auditoria: % filas -> 0',
--       (select count(*) from public.auditoria);
--     delete from public.auditoria;
--   end if;
-- end $$;

-- ─────────────────────────────────────────────────────────────────────
--  PASO 22 (OPCIONAL) · tareas
--    OJO: revisa si "tareas" son pendientes generados por movimientos
--    (entonces sí bórralas) o si son tareas de configuración/plantilla
--    (entonces NO). Ante la duda, déjala.
-- ─────────────────────────────────────────────────────────────────────
-- do $$
-- begin
--   if to_regclass('public.tareas') is null then
--     raise notice 'PASO 22  tareas: no existe, omitido';
--   else
--     raise notice 'PASO 22  tareas: % filas -> 0',
--       (select count(*) from public.tareas);
--     delete from public.tareas;
--   end if;
-- end $$;

-- ─────────────────────────────────────────────────────────────────────
--  PASO 23 (OPCIONAL) · reiniciar las secuencias id -> arrancan en 1
--    DELETE no reinicia el autoincremental (el de nómina sí, por el
--    TRUNCATE del PASO 7). Esto es solo estético: que el primer registro
--    nuevo de cada tabla vuelva a ser id = 1. Seguro porque ya no queda
--    nada que referencie los id viejos.
-- ─────────────────────────────────────────────────────────────────────
-- do $$
-- declare
--     t   text;
--     seq text;
--     tablas text[] := array[
--         'registros_tiempo','solicitudes_reasignacion',
--         'orden_produccion_proceso_empleados','orden_produccion_procesos',
--         'ordenes_produccion','sesiones_ot','movimientos_inventario',
--         'pagos_proveedor_aplicaciones','pagos_proveedor','documento_detalles',
--         'lotes_inventario','gastos','documentos','poliza_movimientos',
--         'polizas','ordenes_compra_detalle','ordenes_compra'
--     ];
-- begin
--     foreach t in array tablas loop
--         if to_regclass('public.' || t) is null then continue; end if;
--         seq := pg_get_serial_sequence('public.' || t, 'id');
--         if seq is not null then
--             execute format('alter sequence %s restart with 1', seq);
--             raise notice 'secuencia reiniciada: %  (%.id)', seq, t;
--         end if;
--     end loop;
-- end $$;


-- =====================================================================
--  VERIFICACIÓN FINAL (opcional) — todo lo transaccional en 0,
--  todo lo maestro intacto.
-- =====================================================================
-- select 'productos'          t, count(*) n from public.productos
-- union all select 'proveedores',        count(*) from public.proveedores
-- union all select 'clientes',           count(*) from public.clientes
-- union all select 'empleados',          count(*) from public.empleados
-- union all select 'cuentas_contables',  count(*) from public.cuentas_contables
-- union all select 'procesos_produccion',count(*) from public.procesos_produccion
-- union all select '--- deben quedar en 0 ---', null
-- union all select 'documentos',         count(*) from public.documentos
-- union all select 'documento_detalles', count(*) from public.documento_detalles
-- union all select 'lotes_inventario',   count(*) from public.lotes_inventario
-- union all select 'movimientos_inventario', count(*) from public.movimientos_inventario
-- union all select 'polizas',            count(*) from public.polizas
-- union all select 'poliza_movimientos', count(*) from public.poliza_movimientos
-- union all select 'gastos',             count(*) from public.gastos
-- union all select 'pagos_proveedor',    count(*) from public.pagos_proveedor
-- union all select 'ordenes_compra',     count(*) from public.ordenes_compra
-- union all select 'ordenes_produccion', count(*) from public.ordenes_produccion
-- union all select 'contadores_documentos', count(*) from public.contadores_documentos
-- union all select 'stock <> 0 (debe ser 0)', count(*) from public.productos where coalesce(stock_actual,0) <> 0;


-- =====================================================================
--  TODO DE UNA VEZ (después de revisar los PASOS 1..20 uno por uno).
--  Descomenta el bloque completo y córrelo: hace lo mismo, atómico.
-- =====================================================================
/*
begin;

  delete from public.registros_tiempo;
  delete from public.solicitudes_reasignacion;
  delete from public.orden_produccion_proceso_empleados;
  delete from public.orden_produccion_procesos;
  delete from public.ordenes_produccion;
  delete from public.sesiones_ot;

  do $$
  declare t text; lista text := '';
  begin
    for t in select tablename from pg_tables
             where schemaname = 'public' and tablename like 'nomina%'
    loop
      lista := lista || case when lista = '' then '' else ', ' end || format('public.%I', t);
    end loop;
    if lista <> '' then execute 'truncate table ' || lista || ' restart identity'; end if;
  end $$;

  delete from public.movimientos_inventario;
  delete from public.pagos_proveedor_aplicaciones;
  delete from public.pagos_proveedor;
  delete from public.documento_detalles;
  delete from public.lotes_inventario;
  delete from public.gastos;
  delete from public.documentos;
  delete from public.poliza_movimientos;
  delete from public.polizas;
  delete from public.ordenes_compra_detalle;
  delete from public.ordenes_compra;
  delete from public.contadores_documentos;

  update public.productos set stock_actual = 0;   -- costo_unitario se conserva

commit;
*/
