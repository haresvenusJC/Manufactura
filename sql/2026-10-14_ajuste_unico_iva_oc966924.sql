-- =====================================================================
--  Ajuste ÚNICO: reclasificar el IVA del pago de OC-966924
--  Fecha: 2026-10-14  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr a mano en Supabase -> SQL Editor,
--  UNA SOLA VEZ.
--
--  Contexto: el pago de OC-966924 (póliza Egreso #11, $1,075.32) se
--  registró antes de sql/2026-10-13_pago_reclasifica_iva.sql, así que
--  solo movió Proveedores -> Bancos. Su IVA ($148.32) se quedó en
--  119.01 "IVA acreditable pendiente de pago" aunque la factura ya está
--  pagada. Este script genera la póliza de Diario que lo pasa a 118.01:
--
--      Cargo 118.01  IVA acreditable pagado
--      Abono 119.01  IVA acreditable pendiente de pago
--
--  · El monto se calcula del propio documento de la OC (documentos.iva
--    proporcional a lo ya pagado), no va hardcodeado.
--  · Se fecha en el día del pago (no hoy): ahí es cuando el IVA se vuelve
--    acreditable. Necesita que ese periodo siga abierto.
--  · Es seguro correrlo dos veces: si ya existe el ajuste, no hace nada.
-- =====================================================================

begin;

do $$
declare
    v_concepto  constant text := 'Ajuste único: reclasifica IVA pagado OC-966924';
    v_cta118    bigint := public._cuenta_id('118.01');
    v_cta119    bigint := public._cuenta_id('119.01');
    v_iva       numeric(14,2);
    v_fecha     date;
    v_docs      integer;
    v_poliza    jsonb;
begin
    if exists (select 1 from public.polizas
                where concepto = v_concepto and estatus = 'contabilizada') then
        raise notice 'El ajuste ya existe (póliza contabilizada): no se hace nada.';
        return;
    end if;

    if v_cta118 is null then raise exception 'Falta la cuenta 118.01 en el plan de cuentas.'; end if;
    if v_cta119 is null then raise exception 'Falta la cuenta 119.01 en el plan de cuentas.'; end if;

    -- IVA de la(s) recepción(es) de la OC, proporcional a lo ya pagado.
    select count(*),
           round(coalesce(sum(coalesce(d.iva, 0) * least(coalesce(d.total_pagado, 0), d.total) / nullif(d.total, 0)), 0), 2)
      into v_docs, v_iva
      from public.documentos d
      join public.ordenes_compra oc on oc.id = d.orden_compra_id
     where oc.folio = 'OC-966924'
       and d.tipo_movimiento = 'entrada_compra'
       and coalesce(d.estado, '') <> 'cancelado'
       and coalesce(d.condicion, '') = 'credito'
       and coalesce(d.total_pagado, 0) > 0;

    if v_docs = 0 or v_iva <= 0 then
        raise exception 'No se encontró recepción pagada a crédito con IVA para OC-966924 — revisa el folio.';
    end if;

    -- Fecha del pago (el más reciente no cancelado aplicado a esa recepción).
    select max(p.fecha)
      into v_fecha
      from public.pagos_proveedor p
      join public.pagos_proveedor_aplicaciones a on a.pago_id = p.id
      join public.documentos d on d.id = a.documento_id
      join public.ordenes_compra oc on oc.id = d.orden_compra_id
     where oc.folio = 'OC-966924'
       and p.estatus = 'registrado';

    if v_fecha is null then v_fecha := current_date; end if;

    v_poliza := public.registrar_poliza(jsonb_build_object(
        'fecha', v_fecha,
        'tipo', 'Diario',
        'concepto', v_concepto,
        'origen', 'ajuste',
        'movimientos', jsonb_build_array(
            jsonb_build_object('cuenta_id', v_cta118, 'cargo', v_iva,
                               'concepto', 'IVA pagado OC-966924 (reclasificación)'),
            jsonb_build_object('cuenta_id', v_cta119, 'abono', v_iva,
                               'concepto', 'Reclasifica IVA pendiente OC-966924')
        )
    ));

    raise notice 'Ajuste registrado: póliza % por $% con fecha %.', v_poliza->>'poliza_id', v_iva, v_fecha;
end $$;

commit;

-- Verificación (opcional): 118.01 debe subir y 119.01 debe bajar por el mismo monto.
-- select p.id, p.tipo, p.numero, p.fecha, p.concepto, p.estatus
--   from public.polizas p where p.concepto like 'Ajuste único: reclasifica IVA pagado OC-966924%';
