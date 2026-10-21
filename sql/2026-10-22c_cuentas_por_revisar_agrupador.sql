-- =====================================================================
--  SOLO LECTURA. Cuentas contables que la migración 2026-10-22b NO conoce
--  (creadas a mano en Plan de cuentas o por otras pantallas) y que por eso
--  conservan su codigo_agrupador actual. Pega el resultado al asistente para
--  asignarles el código correcto del Anexo 24 RMF 2026.
-- =====================================================================
select c.codigo, c.nombre, c.tipo, c.naturaleza, c.nivel, c.afectable,
       c.codigo_agrupador as agrupador_actual,
       case when c.codigo_agrupador is null then 'SIN agrupador'
            when c.codigo_agrupador = c.codigo then 'copia del número interno (probable error)'
            else 'revisar' end as senal
  from public.cuentas_contables c
 where c.codigo not in (
    '101.01','102.01','102.02','105.01','108.01','109.01','115.01','115.02','115.03','115.04','118.01','118.03','119.01',
    '152.01','154.01','153.01','153.02','201.01','205.01','209','209.01','209.02','210.01','213.01','213.03','216.01','216.05','216.10','219.01',
    '301.01','304.01','305.01','401.01','401.03','401.04','402.01','403.01','501.01','502.01',
    '503.01','503.02','503.03','503.04','503.05','503.06','503.07','503.08','503.09','503.10','503.11','503.12','503.13','503.14','503.15','503.16','503.98','503.99',
    '601.01','601.06','601.11','601.14','601.17','601.18','601.19','601.24','601.50','601.52','601.59','601.61','601.62','601.63','601.83','601.84','601.99',
    '701.01','701.04','702.01','702.02')
 order by c.codigo;
