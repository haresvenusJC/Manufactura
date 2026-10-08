begin;

-- ---------------------------------------------------------------------
-- Serie REC para la póliza que genera "Recibir mercancía" (contabilizar_compra).
-- Pedido del usuario tras ver "Diario #36" sin ninguna serie en la lista de
-- pólizas, mientras los pagos ya mostraban "BAN-2026-00001 · Egreso #N"
-- (sql/2026-10-07d_polizas_series_y_visto_bueno.sql). Requiere esa migración
-- corrida antes (crea contadores_folios_poliza / _siguiente_folio_poliza /
-- polizas.folio_poliza).
--
-- Mismo patch de texto que ya se usó para CMP (producción): se busca el
-- 'tipo', 'Diario' dentro del llamado a registrar_poliza de
-- contabilizar_compra() y se agrega 'serie', 'REC' justo ahí, sin
-- reescribir toda la función (es larga y no cambia nada más).
-- ---------------------------------------------------------------------
do $$
declare
    r     record;
    v_def text;
    v_old constant text := $a$'tipo', 'Diario',
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),$a$;
    v_new constant text := $b$'tipo', 'Diario', 'serie', 'REC',
        'concepto', 'Compra ' || coalesce(v_doc.folio, '') || coalesce(' - ' || v_doc.notas, ''),$b$;
begin
    for r in
        select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname = 'contabilizar_compra'
    loop
        v_def := pg_get_functiondef(r.oid);
        if position(v_old in v_def) = 0 then
            raise notice 'contabilizar_compra: ya tiene serie REC (o el texto cambio) - no se toca.';
        else
            execute replace(v_def, v_old, v_new);
            raise notice 'contabilizar_compra: serie REC aplicada.';
        end if;
    end loop;
end $$;

commit;

-- Verificación rápida tras correrla:
--   select folio_poliza, tipo, numero from public.polizas where origen = 'compra' order by id desc limit 5;
-- Si "ya tiene serie REC (o el texto cambio)" sale por NOTICE, revisar a mano si
-- contabilizar_compra() se reescribió fuera de sql/2026-10-07_compras_notas_ajuste.sql
-- desde la última vez que se tocó este repo.
