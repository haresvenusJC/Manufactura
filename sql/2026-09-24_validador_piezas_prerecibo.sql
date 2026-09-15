-- =====================================================================
--  Pre-recibo del operador: validador de piezas por partida
--  Fecha: 2026-09-24  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere: sql/2026-09-11_prerecibo_operador.sql
--
--  Antes, el pre-recibo del operador solo tenía un checkbox "todo
--  correcto" + observaciones libres: no había ningún dato de cuántas
--  piezas realmente llegaron por partida, todo dependía de que el
--  operador escribiera bien la diferencia en texto (o de que el admin
--  releyera la foto).
--
--  Esto agrega:
--    · pre_recibos.lineas (jsonb) — lo que el operador capturó por
--      partida: { orden_compra_detalle_id, descripcion, unidad,
--      cantidad_pedida, cantidad_pendiente, cantidad_capturada }.
--    · prerecibo_crear gana el parámetro p_lineas (jsonb), lo valida
--      (array, cantidades numéricas >= 0, partidas que sí pertenecen a
--      la OC indicada) y lo guarda junto con el resto del pre-recibo.
--
--  Sigue siendo solo un dato de referencia para que el admin decida al
--  validar — el pre-recibo NUNCA mueve inventario ni contabilidad por sí
--  solo (eso lo sigue haciendo el admin en "Recibo de mercancía").
--
--  Idempotente.
-- =====================================================================

begin;

alter table public.pre_recibos
    add column if not exists lineas jsonb not null default '[]'::jsonb;

comment on column public.pre_recibos.lineas is
  'Conteo del operador por partida al capturar el pre-recibo: [{orden_compra_detalle_id, descripcion, unidad, cantidad_pedida, cantidad_pendiente, cantidad_capturada}]. Solo de referencia para el admin — no mueve inventario.';

-- La versión anterior (6 parámetros, sin p_lineas) queda reemplazada.
-- Si no se tira explícitamente, Postgres la deja viva como sobrecarga
-- distinta y un cliente que llame con 6 argumentos seguiría cayendo en
-- la versión vieja (sin validador de piezas).
drop function if exists public.prerecibo_crear(uuid, bigint, text, jsonb, text, boolean);

create or replace function public.prerecibo_crear(
    p_token           uuid,
    p_orden_compra_id bigint,
    p_referencia      text,
    p_fotos           jsonb,
    p_observaciones   text,
    p_todo_correcto   boolean,
    p_lineas          jsonb default '[]'::jsonb
)
returns bigint
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_emp_id     bigint;
    v_emp_nombre text;
    v_n          integer;
    v_i          integer;
    v_foto       text;
    v_id         bigint;
    v_lineas     jsonb := coalesce(p_lineas, '[]'::jsonb);
    r            jsonb;
    v_detalle_id bigint;
    v_cant       numeric;
begin
    -- sesión (misma tabla que la Orden de Trabajo)
    select s.empleado_id, e.nombre
      into v_emp_id, v_emp_nombre
      from public.sesiones_ot s
      join public.empleados e on e.id = s.empleado_id
     where s.token = p_token
       and s.expira_at > now();

    if v_emp_id is null then
        raise exception 'SESION_EXPIRADA';
    end if;

    -- fotos: array de 1..5 data-URI de imagen, cada una <= ~2.2 MB
    if p_fotos is null or jsonb_typeof(p_fotos) <> 'array' then
        raise exception 'Debes adjuntar al menos una foto del documento.';
    end if;
    v_n := jsonb_array_length(p_fotos);
    if v_n < 1 then
        raise exception 'Debes adjuntar al menos una foto del documento.';
    end if;
    if v_n > 5 then
        raise exception 'Máximo 5 fotos.';
    end if;
    for v_i in 0 .. v_n - 1 loop
        v_foto := p_fotos ->> v_i;
        if v_foto is null or left(v_foto, 11) <> 'data:image/' then
            raise exception 'Foto % con formato inválido.', v_i + 1;
        end if;
        if length(v_foto) > 3000000 then
            raise exception 'La foto % pesa demasiado; vuelve a tomarla con menos resolución.', v_i + 1;
        end if;
    end loop;

    if p_orden_compra_id is null and coalesce(trim(p_referencia), '') = '' then
        raise exception 'Elige una orden de compra o escribe una referencia del documento.';
    end if;

    if p_orden_compra_id is not null
       and not exists (select 1 from public.ordenes_compra oc where oc.id = p_orden_compra_id) then
        raise exception 'La orden de compra ya no existe.';
    end if;

    -- lineas: array opcional del conteo por partida. Si viene, cada
    -- elemento debe traer una cantidad_capturada numerica >= 0, y si
    -- trae orden_compra_detalle_id debe pertenecer a la OC indicada.
    if jsonb_typeof(v_lineas) <> 'array' then
        raise exception 'Formato de partidas capturadas invalido.';
    end if;
    if jsonb_array_length(v_lineas) > 200 then
        raise exception 'Demasiadas partidas capturadas.';
    end if;

    for r in select * from jsonb_array_elements(v_lineas)
    loop
        v_detalle_id := nullif(r->>'orden_compra_detalle_id', '')::bigint;
        v_cant := (r->>'cantidad_capturada')::numeric;
        if v_cant is null or v_cant < 0 then
            raise exception 'La cantidad capturada de una partida no puede ser negativa ni estar vacía.';
        end if;
        if v_detalle_id is not null then
            if p_orden_compra_id is null then
                raise exception 'Una partida capturada trae orden_compra_detalle_id pero no elegiste orden de compra.';
            end if;
            if not exists (
                select 1 from public.ordenes_compra_detalle d
                 where d.id = v_detalle_id and d.orden_compra_id = p_orden_compra_id
            ) then
                raise exception 'Una partida capturada no pertenece a la orden de compra elegida.';
            end if;
        end if;
    end loop;

    insert into public.pre_recibos
        (orden_compra_id, referencia, empleado_id, empleado_nombre,
         fotos, observaciones, todo_correcto, estatus, lineas)
    values
        (p_orden_compra_id, nullif(trim(p_referencia), ''), v_emp_id, v_emp_nombre,
         p_fotos, nullif(trim(p_observaciones), ''), coalesce(p_todo_correcto, false), 'pendiente', v_lineas)
    returning id into v_id;

    return v_id;
end $$;

revoke all     on function public.prerecibo_crear(uuid, bigint, text, jsonb, text, boolean, jsonb) from public;
grant  execute on function public.prerecibo_crear(uuid, bigint, text, jsonb, text, boolean, jsonb) to anon, authenticated;

commit;
