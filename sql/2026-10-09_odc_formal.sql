-- =====================================================================
--  Orden de compra formal: cotización del proveedor + condiciones de pago
--  que Compras PACTA (Finanzas ejecuta el pago, Compras nunca lo ejecuta).
--  Fecha: 2026-10-09  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor.
--
--  Solo agrega columnas informativas/de compromiso a ordenes_compra. NO hay
--  póliza al crear la ODC (un compromiso de compra no es un hecho contable,
--  NIF A-2/A-5): la contabilidad sigue igual —
--    · anticipo pagado antes de recibir: Cargo 109.01 / Abono banco (Egreso),
--      lo ejecuta Finanzas con pagar_anticipo_oc();
--    · al recibir: contabilizar_compra() reconoce SIEMPRE el pasivo completo en
--      201.01 Proveedores (Inventario + IVA) y cancela 201.01 contra 109.01 por
--      el anticipo aplicado — así Proveedores queda tocada aunque la compra
--      haya sido 100% de contado y prepagada, y se conserva la trazabilidad;
--    · el resto (contado contra entrega, o crédito a N días) lo paga Finanzas
--      desde Cuentas por pagar (201.01 contra banco).
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.ordenes_compra
    add column if not exists cotizacion_folio     text,
    add column if not exists cotizacion_contacto  text,
    add column if not exists cotizacion_telefono  text,
    add column if not exists cotizacion_email     text,
    add column if not exists cotizacion_fecha     date,
    add column if not exists cotizacion_vigencia  date,
    add column if not exists condicion_pago       text,
    add column if not exists forma_pago           text,
    add column if not exists anticipo_pct         numeric(6,2),
    add column if not exists anticipo_monto       numeric(14,2);

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ordenes_compra_condicion_pago_chk') then
        alter table public.ordenes_compra
            add constraint ordenes_compra_condicion_pago_chk
            check (condicion_pago is null or condicion_pago in ('contado', 'credito'));
    end if;
    if not exists (select 1 from pg_constraint where conname = 'ordenes_compra_anticipo_pct_chk') then
        alter table public.ordenes_compra
            add constraint ordenes_compra_anticipo_pct_chk
            check (anticipo_pct is null or (anticipo_pct >= 0 and anticipo_pct <= 100));
    end if;
end $$;

comment on column public.ordenes_compra.condicion_pago  is 'Pactado por Compras: contado | credito. Null = ODC anterior al documento formal.';
comment on column public.ordenes_compra.anticipo_pct    is 'Porcentaje del total que Compras se comprometió a pagar ANTES de recibir (Finanzas lo ejecuta con pagar_anticipo_oc).';
comment on column public.ordenes_compra.anticipo_monto  is 'Importe comprometido de anticipo (total estimado con IVA × anticipo_pct). Informativo para Finanzas.';
comment on column public.ordenes_compra.forma_pago      is 'Forma de pago acordada (clave c_forma_pago). Informativa: el pago lo ejecuta Finanzas.';

commit;

-- select folio, condicion_pago, dias_credito, anticipo_pct, anticipo_monto, cotizacion_folio from public.ordenes_compra order by id desc limit 10;
