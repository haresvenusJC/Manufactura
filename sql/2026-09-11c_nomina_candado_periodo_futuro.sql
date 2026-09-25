-- =====================================================================
--  Nómina — candado: no se puede AUTORIZAR (cerrar/contabilizar) una
--  nómina cuyo periodo todavía no arranca.
--  Fecha: 2026-09-11  ·  Proyecto: Hares de México (Supabase)
--
--  Motivo: se pre-ejecutaron y autorizaron 3 nóminas seguidas (semanas
--  del 07-13, 14-20 y 21-27 de septiembre) el mismo día 11 de septiembre
--  — dos de ellas de periodos que ni siquiera habían empezado. Contable
--  y operativamente no debería poder "cerrarse" una nómina futura, solo
--  periodos ya iniciados (la vigente) o ya terminados (anteriores).
--
--  "Vigente o anterior" = periodo_inicio <= hoy. Si periodo_inicio es
--  posterior a hoy, autorizar_nomina ahora truena ANTES de tocar nada
--  (no se genera póliza ni se cambia el estatus del borrador).
--
--  El borrador (precalcular_nomina) se deja intacto — sigue permitiendo
--  capturar/planear nóminas futuras con anticipación; el candado es
--  específicamente al momento de autorizar (contabilizar).
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Reemplaza por completo la función autorizar_nomina (create or replace,
--  idempotente).
-- =====================================================================

begin;

create or replace function public.autorizar_nomina(p_nomina_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_nomina    public.nominas%rowtype;
    v_cuenta    public.cuentas_contables%rowtype;
    v_movs      jsonb;
    v_id        bigint;
    v_neto      numeric(14,2);
    v_poliza_id bigint;
begin
    select * into v_nomina from public.nominas where id = p_nomina_id;
    if not found then raise exception 'La nomina no existe.'; end if;
    if v_nomina.estatus <> 'borrador' then
        raise exception 'La nomina ya esta %; solo se puede autorizar un borrador pendiente.', v_nomina.estatus;
    end if;

    if v_nomina.periodo_inicio > current_date then
        raise exception 'No se puede autorizar una nomina futura (periodo % a %, todavia no inicia). Solo se permite autorizar el periodo vigente o periodos anteriores.',
            v_nomina.periodo_inicio, v_nomina.periodo_fin;
    end if;

    if v_nomina.condicion = 'contado' then
        select * into v_cuenta from public.cuentas_contables where id = v_nomina.cuenta_pago_id;
        if not found then raise exception 'La cuenta de pago de esta nomina ya no existe.'; end if;
        if not v_cuenta.afectable or not v_cuenta.activa then
            raise exception 'La cuenta de pago % ya no acepta movimientos o esta inactiva.', v_cuenta.codigo;
        end if;
    end if;

    v_neto := round(v_nomina.subtotal - v_nomina.isr_retenido, 2);

    v_id := public._cuenta_id('601.01');
    if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.01 (Sueldos y salarios).'; end if;
    v_movs := jsonb_build_array(
        jsonb_build_object('cuenta_id', v_id, 'cargo', v_nomina.subtotal, 'concepto', 'Nomina ' || v_nomina.periodo_inicio || ' a ' || v_nomina.periodo_fin)
    );

    if v_nomina.cuotas_imss > 0 then
        v_id := public._cuenta_id('601.59');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 601.59 (Cuotas IMSS/INFONAVIT patronales).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'cargo', v_nomina.cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT patronales');
    end if;

    if v_nomina.isr_retenido > 0 then
        v_id := public._cuenta_id('216.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 216.01 (ISR retenido por sueldos).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_nomina.isr_retenido, 'concepto', 'ISR retenido por sueldos');
    end if;

    if v_nomina.cuotas_imss > 0 then
        v_id := public._cuenta_id('219.01');
        if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
        v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_nomina.cuotas_imss, 'concepto', 'Cuotas IMSS/INFONAVIT por pagar');
    end if;

    if v_neto > 0 then
        if v_nomina.condicion = 'contado' then
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_nomina.cuenta_pago_id, 'abono', v_neto, 'concepto', 'Pago de nomina neta');
        else
            v_id := public._cuenta_id('219.01');
            if v_id is null then raise exception 'Falta en el plan de cuentas la cuenta 219.01 (IMSS/INFONAVIT y nomina por pagar).'; end if;
            v_movs := v_movs || jsonb_build_object('cuenta_id', v_id, 'abono', v_neto, 'concepto', 'Sueldos netos por pagar');
        end if;
    end if;

    v_poliza_id := (public.registrar_poliza(jsonb_build_object(
        'fecha', v_nomina.fecha_pago,
        'tipo', 'Egreso',
        'concepto', 'Nomina ' || v_nomina.periodo_inicio || ' a ' || v_nomina.periodo_fin,
        'origen', 'nomina',
        'origen_tabla', 'nominas',
        'origen_id', v_nomina.id,
        'movimientos', v_movs
    ))->>'poliza_id')::bigint;

    update public.nominas set poliza_id = v_poliza_id, estatus = 'registrada' where id = v_nomina.id;

    return jsonb_build_object('nomina_id', v_nomina.id, 'poliza_id', v_poliza_id, 'total', v_nomina.total);
end;
$$;

revoke all     on function public.autorizar_nomina(bigint) from public;
grant  execute on function public.autorizar_nomina(bigint) to authenticated;

commit;
