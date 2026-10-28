-- =====================================================================
--  Requisiciones de compra: quién solicita y quién autoriza (responsables)
--  Fecha: 2026-10-28  ·  Proyecto: Hares de México (Supabase)
--
--  NO lo ejecuta la app. Pegar y correr A MANO en Supabase -> SQL Editor.
--  Requiere sql/2026-10-28_departamentos_gerente_foto.sql (departamentos y
--  gerente de cada empleado).
--
--  Mientras no haya claves de acceso por persona, el responsable se FIJA con
--  una lista desplegable de las personas del departamento (quien solicita) y de
--  la plantilla (quien autoriza; se sugiere el Gerente del solicitante). Estos
--  campos alimentan las firmas de la requisición y de la orden de compra.
--
--  Sigue existiendo solicitada_por (texto): se escribe con el nombre del
--  empleado para que lo que ya lo lee no cambie.
--
--  Idempotente. No cambia datos existentes ni ninguna función.
-- =====================================================================

begin;

alter table public.requisiciones_compra
    add column if not exists departamento_id            bigint references public.departamentos (id) on delete set null,
    add column if not exists solicitante_empleado_id    bigint references public.empleados (id) on delete set null,
    add column if not exists autorizada_por_empleado_id bigint references public.empleados (id) on delete set null;

comment on column public.requisiciones_compra.departamento_id is
  'Departamento que pide (de ahí salen las personas que pueden solicitar).';
comment on column public.requisiciones_compra.solicitante_empleado_id is
  'Empleado que solicita; aparece en la firma "Solicitó".';
comment on column public.requisiciones_compra.autorizada_por_empleado_id is
  'Empleado que revisa y autoriza; aparece en la firma "Revisó y autorizó". Si está vacío se muestra el Gerente del solicitante.';

create index if not exists requisiciones_compra_depto_idx on public.requisiciones_compra (departamento_id);

commit;

-- Verificación (opcional)
-- select folio, solicitada_por, departamento_id, solicitante_empleado_id, autorizada_por_empleado_id from public.requisiciones_compra order by id desc limit 10;
