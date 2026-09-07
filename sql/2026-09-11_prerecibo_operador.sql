-- =====================================================================
--  Pre-recibo de mercancía por el operador (móvil) + validación admin
--  Fecha: 2026-09-11  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--
--  Requiere haber corrido antes:
--    · sql/2026-08-27_flujo_ot.sql   (empleados.pin_hash, sesiones_ot,
--      v_ot_empleados, ot_login — se REUSAN para identificar al operador)
--    · sql/2026-09-02_ordenes_compra.sql  (ordenes_compra / _detalle)
--
--  Flujo:
--    1. El operador abre recibo-operador.html, se identifica con su
--       nombre + PIN de 4 dígitos (mismo ot_login que la Orden de
--       Trabajo — devuelve un token de sesiones_ot).
--    2. Elige la orden de compra que está recibiendo (o escribe una
--       referencia libre / número de remito si no hay OC).
--    3. Toma una o varias fotos del documento (remisión / factura).
--    4. Marca "todo correcto" y agrega observaciones si algo no cuadra.
--    5. Envía -> se crea un public.pre_recibos con estatus 'pendiente'.
--    6. El Admin lo ve en "Recibo de mercancía -> Pre-recibos por
--       validar", revisa la(s) foto(s), y lo Valida (pasa a capturar la
--       recepción real de esa OC) o lo Rechaza con un motivo.
--
--  Fotos: se guardan como data-URI base64 dentro de pre_recibos.fotos
--  (jsonb array). El cliente las comprime antes de enviar. La RPC limita
--  cantidad y tamaño. 'anon' NUNCA lee/escribe la tabla directo: solo
--  vía las RPC security definer.
--
--  Idempotente.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Tabla
-- ---------------------------------------------------------------------
create table if not exists public.pre_recibos (
    id               bigint generated always as identity primary key,
    orden_compra_id  bigint      references public.ordenes_compra (id) on delete set null,
    referencia       text,                                   -- remito / nota, si no hay OC
    empleado_id      bigint      references public.empleados (id),
    empleado_nombre  text,
    fotos            jsonb       not null default '[]'::jsonb, -- ["data:image/jpeg;base64,...", ...]
    observaciones    text,
    todo_correcto    boolean     not null default false,
    estatus          text        not null default 'pendiente'
                     check (estatus in ('pendiente', 'validado', 'rechazado')),
    documento_id     bigint      references public.documentos (id) on delete set null,
    creado_en        timestamptz not null default now(),
    validado_en      timestamptz,
    validado_por     uuid,
    nota_validacion  text
);

create index if not exists pre_recibos_estatus_idx on public.pre_recibos (estatus);
create index if not exists pre_recibos_oc_idx      on public.pre_recibos (orden_compra_id);

alter table public.pre_recibos enable row level security;
drop policy if exists admin_all on public.pre_recibos;
create policy admin_all on public.pre_recibos for all to authenticated using (true) with check (true);
grant all on public.pre_recibos to authenticated;
revoke all on public.pre_recibos from anon;   -- anon solo por RPC

comment on table public.pre_recibos is
  'Pre-recibo capturado por el operador desde recibo-operador.html (foto del documento + confirmación). El admin lo valida y con eso hace la recepción real.';


-- ---------------------------------------------------------------------
-- 2. Vistas públicas para el móvil (sin costos)
-- ---------------------------------------------------------------------
create or replace view public.v_recibo_ocs as
    select oc.id,
           oc.folio,
           oc.fecha,
           oc.fecha_esperada,
           oc.estatus,
           pr.nombre as proveedor_nombre,
           (select count(*) from public.ordenes_compra_detalle d
             where d.orden_compra_id = oc.id) as partidas
      from public.ordenes_compra oc
      left join public.proveedores pr on pr.id = oc.proveedor_id
     where oc.estatus in ('abierta', 'recibida_parcial');

create or replace view public.v_recibo_oc_lineas as
    select d.orden_compra_id,
           d.id,
           coalesce(nullif(trim(d.descripcion), ''), p.nombre, 'Partida') as descripcion,
           d.cantidad,
           coalesce(d.cantidad_recibida, 0) as cantidad_recibida,
           um.nombre as unidad
      from public.ordenes_compra_detalle d
      left join public.productos p on p.id = d.producto_id
      left join public.unidades_medida um on um.id = d.unidad_medida_id;

grant select on public.v_recibo_ocs, public.v_recibo_oc_lineas to anon, authenticated;


-- ---------------------------------------------------------------------
-- 3. RPC: el operador crea el pre-recibo (identificado por token OT)
-- ---------------------------------------------------------------------
create or replace function public.prerecibo_crear(
    p_token           uuid,
    p_orden_compra_id bigint,
    p_referencia      text,
    p_fotos           jsonb,
    p_observaciones   text,
    p_todo_correcto   boolean
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

    insert into public.pre_recibos
        (orden_compra_id, referencia, empleado_id, empleado_nombre,
         fotos, observaciones, todo_correcto, estatus)
    values
        (p_orden_compra_id, nullif(trim(p_referencia), ''), v_emp_id, v_emp_nombre,
         p_fotos, nullif(trim(p_observaciones), ''), coalesce(p_todo_correcto, false), 'pendiente')
    returning id into v_id;

    return v_id;
end $$;

revoke all     on function public.prerecibo_crear(uuid, bigint, text, jsonb, text, boolean) from public;
grant  execute on function public.prerecibo_crear(uuid, bigint, text, jsonb, text, boolean) to anon, authenticated;


-- ---------------------------------------------------------------------
-- 4. RPC: el admin valida o rechaza un pre-recibo
-- ---------------------------------------------------------------------
create or replace function public.prerecibo_validar(
    p_id     bigint,
    p_accion text,               -- 'validar' | 'rechazar'
    p_nota   text default null
)
returns public.pre_recibos
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
    v_row public.pre_recibos;
begin
    if coalesce(auth.role(), '') <> 'authenticated' then
        raise exception 'No autorizado.';
    end if;
    if p_accion not in ('validar', 'rechazar') then
        raise exception 'Acción inválida (usa validar | rechazar).';
    end if;

    update public.pre_recibos
       set estatus         = case p_accion when 'validar' then 'validado' else 'rechazado' end,
           nota_validacion = nullif(trim(p_nota), ''),
           validado_por    = auth.uid(),
           validado_en     = now()
     where id = p_id
    returning * into v_row;

    if not found then
        raise exception 'El pre-recibo % no existe.', p_id;
    end if;
    return v_row;
end $$;

revoke all     on function public.prerecibo_validar(bigint, text, text) from public, anon;
grant  execute on function public.prerecibo_validar(bigint, text, text) to authenticated;

commit;


-- =====================================================================
--  Consultas útiles (opcionales)
-- =====================================================================
-- select id, empleado_nombre, orden_compra_id, referencia, todo_correcto,
--        jsonb_array_length(fotos) as fotos, estatus, creado_en
-- from public.pre_recibos order by creado_en desc;
