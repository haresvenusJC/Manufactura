-- =====================================================================
--  Claves de proveedor: unidad SAT con que vende el proveedor + factor obligatorio
--  Fecha: 2026-10-23  ·  Proyecto: Hares de México (Supabase)
--
--  ENTREGA 2 de 5 de "cotización del proveedor con su unidad y su factor".
--  Correr DESPUÉS de los 4 pasos de sql/2026-10-23_catalogos_sat_* (necesita c_clave_unidad
--  cargada) y de sql/2026-09-30_factor_conversion_proveedor.sql (columna factor_conversion).
--
--  producto_claves_proveedor ya guardaba, por producto y proveedor: su clave, su ClaveProdServ,
--  su descripción, su unidad (texto) y un factor. Se agrega:
--   · clave_unidad_sat → la ClaveUnidad del SAT con que ese proveedor vende (MIL, H87, KGM...).
--   · Regla de integridad: si hay unidad SAT, el factor es OBLIGATORIO y mayor a cero (cuántas
--     unidades de TU inventario trae 1 unidad del proveedor). Nunca se asume 1 a 1 en silencio.
--  El mismo producto puede tener una fila por proveedor: el proveedor A en MIL ×1,000 y el B en H87 ×1.
--  No toca stock, BOM ni documentos. Idempotente.
-- =====================================================================
begin;

do $$
declare v_n bigint := 0;
begin
    if to_regclass('public.c_clave_unidad') is not null then
        execute 'select count(*) from public.c_clave_unidad' into v_n;
    end if;
    if v_n = 0 then
        raise exception 'Primero carga los catálogos SAT (sql/2026-10-23_catalogos_sat_estructura.sql y …_datos_unidad.sql).';
    end if;
end $$;

alter table public.producto_claves_proveedor
    add column if not exists clave_unidad_sat text;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'producto_claves_proveedor_unidad_sat_fk') then
        alter table public.producto_claves_proveedor
            add constraint producto_claves_proveedor_unidad_sat_fk
            foreign key (clave_unidad_sat) references public.c_clave_unidad (clave);
    end if;
    if not exists (select 1 from pg_constraint where conname = 'producto_claves_proveedor_unidad_factor_chk') then
        alter table public.producto_claves_proveedor
            add constraint producto_claves_proveedor_unidad_factor_chk
            check (clave_unidad_sat is null or coalesce(factor_conversion, 0) > 0);
    end if;
end $$;

comment on column public.producto_claves_proveedor.clave_unidad_sat is
  'ClaveUnidad del SAT (c_ClaveUnidad) con que este proveedor vende este producto. Con ella, factor_conversion es obligatorio.';
comment on column public.producto_claves_proveedor.factor_conversion is
  'Unidades de INVENTARIO que trae 1 unidad del proveedor (1 MIL = 1000 piezas -> 1000). Obligatorio si hay clave_unidad_sat.';

commit;
