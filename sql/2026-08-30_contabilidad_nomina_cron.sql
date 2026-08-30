-- =====================================================================
--  Contabilidad - FASE 7b: pg_cron - pre-ejecuta la nomina pendiente sola
--  Fecha: 2026-08-30   Proyecto: Hares de Mexico (Supabase)
--
--  Este archivo NO lo ejecuta la aplicacion. Se pega y corre a mano en:
--    Supabase -> SQL Editor
--  Requiere haber corrido antes:
--    sql/2026-08-30_contabilidad_nomina.sql
--    sql/2026-08-30_contabilidad_isr.sql
--    sql/2026-08-30_contabilidad_nomina_borrador.sql
--
--  El aviso de "es viernes, pre-ejecuta y autoriza" (2026-08-30, mismo
--  dia) solo aparece si alguien inicia sesion - si nadie entra a la app
--  el viernes, nadie lo ve. Este archivo agrega una tarea programada
--  (pg_cron) que corre TODOS LOS DIAS y, quien nada mas se cumpla que
--  ya sea viernes de la semana pendiente (lunes a domingo, la que sigue
--  a la ultima nomina usada) Y todavia no exista ninguna nomina para
--  esa semana, la PRE-EJECUTA sola (mismo resultado que darle "Pre-
--  ejecutar nomina" a mano): calcula sueldos con el sueldo_semanal
--  vigente de cada empleado activo, IMSS patronal con las primas
--  minimas por default (16.29355%, el mismo total que trae la pantalla
--  sin tocar nada) e ISR con la tabla vigente - queda como 'borrador',
--  NO se contabiliza. Alguien sigue teniendo que entrar a Autorizarla
--  (el aviso global ya avisa que esta pendiente).
--
--  Por que corre TODOS los dias en vez de solo los viernes: si un dia
--  se cae el cron o el proyecto estuvo pausado, el siguiente dia se
--  pone al corriente solo (la funcion ya trae el filtro "solo si ya es
--  viernes o despues"), en vez de tener que esperar a la siguiente
--  semana. Es barato de correr (unas cuantas consultas chicas) y no
--  hace nada si ya existe la nomina de esa semana.
--
--  cuenta_pago_id / condicion: como no hay forma automatica de saber
--  desde que caja/banco se va a pagar, la nomina auto-generada siempre
--  queda en condicion 'credito' (sueldos netos por pagar) - si se
--  necesita pagar de contado desde una cuenta especifica, se cancela el
--  borrador y se vuelve a pre-ejecutar a mano con esa opcion antes de
--  autorizar.
--
--  Requiere la extension pg_cron. En Supabase normalmente ya esta
--  disponible para habilitarse por SQL; si el comando de abajo da un
--  error de permisos, se habilita desde el Dashboard -> Database ->
--  Extensions (buscar "pg_cron" -> Enable) y se vuelve a correr este
--  archivo completo.
--
--  Para revisar que esta corriendo:
--    select * from cron.job;
--    select * from cron.job_run_details order by start_time desc limit 20;
--  Para apagarlo sin borrar el archivo:
--    select cron.unschedule('nomina_autogenerar_pendiente_diario');
--
--  Idempotente.
-- =====================================================================

begin;

create extension if not exists pg_cron with schema extensions;

-- ---------------------------------------------------------------------
-- _nomina_autogenerar_pendiente(): logica del cron, tambien invocable a
-- mano para probarla: select public._nomina_autogenerar_pendiente();
-- ---------------------------------------------------------------------
create or replace function public._nomina_autogenerar_pendiente()
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_ultimo_fin  date;
    v_inicio      date;
    v_fin         date;
    v_viernes     date;
    v_hoy         date := current_date;
    v_ya_existe   boolean;
    v_empleados   jsonb;
    v_subtotal    numeric(14,2);
    v_cuotas_imss numeric(14,2);
begin
    select max(periodo_fin) into v_ultimo_fin from public.nominas;

    if v_ultimo_fin is not null then
        v_inicio := v_ultimo_fin + 1;
    else
        -- Sin historial: la semana lunes-domingo que contiene (o ya
        -- termino) hoy. extract(isodow) = 1 (lunes) .. 7 (domingo).
        v_inicio := v_hoy - (extract(isodow from v_hoy)::int - 1);
    end if;
    v_fin     := v_inicio + 6;
    v_viernes := v_inicio + 4;

    if v_hoy < v_viernes then
        return; -- todavia no es viernes de esa semana
    end if;

    select exists (
        select 1 from public.nominas
         where estatus <> 'cancelada'
           and periodo_inicio = v_inicio
           and periodo_fin = v_fin
    ) into v_ya_existe;
    if v_ya_existe then
        return; -- ya se pre-ejecuto (a mano o por una corrida previa del cron)
    end if;

    select coalesce(jsonb_agg(jsonb_build_object('empleado_id', id, 'sueldo', sueldo_semanal)), '[]'::jsonb),
           coalesce(sum(sueldo_semanal), 0)
      into v_empleados, v_subtotal
      from public.empleados
     where activo;

    if jsonb_array_length(v_empleados) = 0 or v_subtotal <= 0 then
        return; -- nada que pre-ejecutar
    end if;

    -- Mismo total por default que arma la pantalla sin tocar nada:
    -- 0.54355 (riesgo clase I) + 1.10 + 1.05 + 0.70 + 1.00 + 1.75 + 2.00
    -- + 3.150 + 5.00 = 16.29355% patronal.
    v_cuotas_imss := round(v_subtotal * 16.29355 / 100, 2);

    perform public.precalcular_nomina(jsonb_build_object(
        'periodo_inicio', v_inicio,
        'periodo_fin', v_fin,
        'fecha_pago', v_fin,
        'condicion', 'credito',
        'cuotas_imss', v_cuotas_imss,
        'empleados', v_empleados
    ));
exception when others then
    -- No se detiene el cron por un error puntual (ej. falta una cuenta
    -- en el plan de cuentas, o ya se agrego una nomina para esa semana
    -- justo entre el chequeo y el insert) - queda para revisar a mano
    -- via cron.job_run_details.
    raise warning 'nomina_autogenerar_pendiente: %', sqlerrm;
end;
$$;

revoke all on function public._nomina_autogenerar_pendiente() from public;

-- ---------------------------------------------------------------------
-- Programa la corrida diaria (13:00 UTC ~ 7-8 am hora de Mexico según
-- horario de verano). Se puede ajustar la hora desde el Dashboard ->
-- Database -> Cron, o corriendo de nuevo cron.schedule con otro valor.
-- ---------------------------------------------------------------------
do $$
begin
    if exists (select 1 from cron.job where jobname = 'nomina_autogenerar_pendiente_diario') then
        perform cron.unschedule('nomina_autogenerar_pendiente_diario');
    end if;
end;
$$;

select cron.schedule(
    'nomina_autogenerar_pendiente_diario',
    '0 13 * * *',
    $$ select public._nomina_autogenerar_pendiente(); $$
);

commit;
