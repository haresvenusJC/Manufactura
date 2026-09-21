-- =====================================================================
--  Distinguir en la base: terminado fabricado / terminado comprado
--  (reventa) / semiterminado / materia prima e insumo — y ver cuáles
--  tienen BOM.
--  Fecha: 2026-10-18  ·  Proyecto: Hares de México (Supabase)
--
--  `productos.tipo` NO cambia (producto / materia_prima / insumo ...), así
--  los semiterminados siguen usando las mismas cuentas contables, la misma
--  producción y el mismo inventario que un producto. Se agregan dos datos:
--
--    abastecimiento    'fabricado' | 'comprado'   (cómo se obtiene)
--    es_semiterminado  boolean                    (se fabrica y se usa como
--                                                  componente de otros, p. ej. granel)
--
--  Reglas que aplica la base:
--    - Un semiterminado siempre es 'fabricado' y de tipo 'producto'.
--    - Un producto 'comprado' (reventa) no puede tener BOM.
--    - Un producto no puede ser componente de sí mismo, ni directa ni
--      indirectamente (granel -> terminado -> granel).
--
--  Vista de consulta: public.v_productos_bom  (clasificación + estado del BOM).
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- 1. Columnas
-- ---------------------------------------------------------------------
alter table public.productos
    add column if not exists abastecimiento   text,
    add column if not exists es_semiterminado boolean not null default false;

comment on column public.productos.abastecimiento is
    'fabricado = se transforma en planta (lleva BOM); comprado = se compra terminado o es materia prima/insumo (no lleva BOM).';
comment on column public.productos.es_semiterminado is
    'true = se fabrica y se usa como componente de otros productos (p. ej. granel). Solo para tipo producto.';

-- Todo lo que ya existe: los productos hoy se transforman; lo demás se compra.
update public.productos
   set abastecimiento = case when tipo = 'producto' then 'fabricado' else 'comprado' end
 where abastecimiento is null;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'productos_abastecimiento_check') then
        alter table public.productos
            add constraint productos_abastecimiento_check
            check (abastecimiento in ('fabricado', 'comprado'));
    end if;
    if not exists (select 1 from pg_constraint where conname = 'productos_semiterminado_check') then
        alter table public.productos
            add constraint productos_semiterminado_check
            check (not es_semiterminado or (tipo = 'producto' and abastecimiento = 'fabricado'));
    end if;
end $$;


-- ---------------------------------------------------------------------
-- 2. Altas nuevas sin abastecimiento (compras, importador, entradas...)
--    reciben el valor lógico según su tipo.
-- ---------------------------------------------------------------------
create or replace function public.trg_productos_abastecimiento_default()
returns trigger
language plpgsql
as $$
begin
    if new.abastecimiento is null then
        new.abastecimiento := case when new.tipo = 'producto' then 'fabricado' else 'comprado' end;
    end if;
    return new;
end;
$$;

drop trigger if exists trg_productos_abastecimiento_default on public.productos;
create trigger trg_productos_abastecimiento_default
    before insert on public.productos
    for each row execute function public.trg_productos_abastecimiento_default();


-- ---------------------------------------------------------------------
-- 3. Reglas del BOM: sin reventa con receta y sin ciclos
-- ---------------------------------------------------------------------
create or replace function public.trg_bom_valida()
returns trigger
language plpgsql
as $$
declare
    v_abast  text;
    v_nombre text;
begin
    select p.abastecimiento, p.nombre
      into v_abast, v_nombre
      from public.productos p
     where p.id = new.producto_id;

    if v_abast = 'comprado' then
        raise exception '"%" se marcó como comprado (reventa) y no lleva BOM. Cámbialo a Fabricado para armarle receta.', v_nombre;
    end if;

    if new.producto_id = new.componente_id then
        raise exception 'Un producto no puede ser componente de sí mismo.';
    end if;

    -- Ciclo: ¿el componente ya contiene, en algún nivel, al producto que estamos armando?
    if exists (
        with recursive bajada(id) as (
            select b.componente_id from public.bom b where b.producto_id = new.componente_id
            union
            select b.componente_id from public.bom b join bajada x on b.producto_id = x.id
        )
        select 1 from bajada where id = new.producto_id
    ) then
        raise exception 'Ese componente ya usa a este producto en su propio BOM (sería un ciclo).';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_bom_valida on public.bom;
create trigger trg_bom_valida
    before insert or update of producto_id, componente_id on public.bom
    for each row execute function public.trg_bom_valida();


-- ---------------------------------------------------------------------
-- 4. Vista: cómo se clasifica cada artículo y si su BOM está completo
-- ---------------------------------------------------------------------
create or replace view public.v_productos_bom
with (security_invoker = true) as
select p.id,
       p.sku,
       p.nombre,
       p.tipo,
       p.abastecimiento,
       p.es_semiterminado,
       case
           when coalesce(p.tipo, 'materia_prima') = 'materia_prima'          then 'Materia prima'
           when p.tipo <> 'producto'                                         then 'Insumo / componente'
           when p.es_semiterminado                                           then 'Semiterminado'
           when p.abastecimiento = 'comprado'                                then 'Terminado comprado (reventa)'
           else                                                                   'Terminado fabricado'
       end as clasificacion,
       coalesce(c.n, 0) as n_componentes,
       coalesce(u.n, 0) as usado_en_n_productos,
       case
           when coalesce(p.tipo, 'materia_prima') <> 'producto'              then 'no aplica'
           when p.abastecimiento = 'comprado' and coalesce(c.n, 0) > 0       then 'revisar: comprado con BOM'
           when p.abastecimiento = 'comprado'                                then 'no aplica'
           when coalesce(c.n, 0) > 0                                         then 'con BOM'
           else                                                                   'SIN BOM'
       end as estado_bom
  from public.productos p
  left join (select producto_id,   count(*) as n from public.bom group by producto_id)   c on c.producto_id   = p.id
  left join (select componente_id, count(*) as n from public.bom group by componente_id) u on u.componente_id = p.id;

revoke all    on public.v_productos_bom from anon;
grant  select on public.v_productos_bom to authenticated;

commit;

-- Para revisar después de correrla:
--   select clasificacion, estado_bom, count(*) from public.v_productos_bom group by 1, 2 order by 1, 2;
--   select * from public.v_productos_bom where estado_bom in ('SIN BOM', 'revisar: comprado con BOM');
