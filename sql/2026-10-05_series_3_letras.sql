-- =====================================================================
--  Series de folio a 3 letras, desde la fecha de corte 2026-10-05
--  Proyecto: Hares de México (Supabase)
--
--  Desde hoy los documentos NUEVOS salen con:
--    OC       -> ODC   (orden de compra)          ODC-000001 ...
--    PROD     -> ODP   (cierre de producción)     ODP-000001 ...
--    DEVCLI   -> DCL   (devolución de cliente)    DCL-000001 ...
--    DEVPROV  -> DPV   (devolución a proveedor)   DPV-000001 ...
--  Los folios anteriores (OC-000001 ..., PROD-..., DEVCLI-...) NO se
--  renombran: están citados en pólizas, documentos y notas. Los contadores
--  viejos se quedan tal cual (ya no avanzan).
--
--  Pégalo completo en Supabase -> SQL Editor. Es idempotente.
-- =====================================================================
begin;

-- 1. Contadores nuevos, empiezan en 0 (el primer folio será -000001)
insert into public.contadores_folios (serie, ultimo) values
    ('ODC', 0), ('ODP', 0), ('DCL', 0), ('DPV', 0)
on conflict (serie) do nothing;

-- 2. Funciones que ya generan folio: cambian solo la serie
do $$
declare
    r       record;
    v_def   text;
    v_nuevo text;
    v_pares text[][] := array[
        -- [función, texto viejo, texto nuevo]
        ['requisicion_autorizar',          $a$public.siguiente_folio('OC')$a$,      $b$public.siguiente_folio('ODC')$b$],
        ['registrar_devolucion_cliente',   $a$public.siguiente_folio('DEVCLI')$a$,  $b$public.siguiente_folio('DCL')$b$],
        ['registrar_devolucion_proveedor', $a$public.siguiente_folio('DEVPROV')$a$, $b$public.siguiente_folio('DPV')$b$]
    ];
    i int;
begin
    for i in 1 .. array_length(v_pares, 1) loop
        for r in
            select p.oid
              from pg_proc p
              join pg_namespace n on n.oid = p.pronamespace
             where n.nspname = 'public' and p.proname = v_pares[i][1]
        loop
            v_def := pg_get_functiondef(r.oid);
            if position(v_pares[i][2] in v_def) = 0 then
                raise notice 'Función %: ya usa la serie nueva (o su texto es distinto); no se toca.', v_pares[i][1];
            else
                v_nuevo := replace(v_def, v_pares[i][2], v_pares[i][3]);
                execute v_nuevo;
                raise notice 'Función %: serie cambiada.', v_pares[i][1];
            end if;
        end loop;
    end loop;
end $$;

commit;

-- Para revisar después de correrla:
--   select * from public.contadores_folios order by serie;
--   select public.proximo_folio('ODC');   -- debe dar ODC-000001
