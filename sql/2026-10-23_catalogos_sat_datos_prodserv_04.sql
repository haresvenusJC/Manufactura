-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 4 de 10 (5343 claves; total 52513)
--  Fecha: 2026-10-23  ·  Fuente: ...SAT26.xlsx (versión 4.0, publicada 2020-12-29)
--  Correr DESPUÉS de sql/2026-10-23_catalogos_sat_estructura.sql; las partes en cualquier orden.
--  Idempotente (upsert). Pegar COMPLETO en Supabase -> SQL Editor (≈322 KB).
--  Formato compacto por renglón: clave|descripción|IVA|IEPS|complemento|desde|hasta|franja|similares
--  (O = Opcional, D = 2019-01-07, vacío = sin dato).
-- =====================================================================
begin;
insert into public.c_clave_prod_serv (clave, descripcion, incluir_iva, incluir_ieps, complemento, vigente_desde, vigente_hasta, franja_fronteriza, palabras_similares)
select split_part(l, '|', 1),
       split_part(l, '|', 2),
       nullif(case split_part(l, '|', 3) when 'O' then 'Opcional' else split_part(l, '|', 3) end, ''),
       nullif(case split_part(l, '|', 4) when 'O' then 'Opcional' else split_part(l, '|', 4) end, ''),
       nullif(split_part(l, '|', 5), ''),
       case split_part(l, '|', 6) when '' then null when 'D' then date '2019-01-07' else split_part(l, '|', 6)::date end,
       case split_part(l, '|', 7) when '' then null when 'D' then date '2019-01-07' else split_part(l, '|', 7)::date end,
       split_part(l, '|', 8) = '1',
       nullif(split_part(l, '|', 9), '')
  from regexp_split_to_table($sat$
31321209|Ensambles de barras soldadas con solvente de acero inoxidable|O|O||D||1
31321210|Ensambles de barras soldadas con solvente de titanio|O|O||D||1
31321211|Ensambles de barras soldadas con solvente de aleación wasp|O|O||D||1
31321212|Ensambles de barras soldadas con solvente de cobre|O|O||D||1
31321213|Ensambles de barras soldadas con solvente de latón|O|O||D||1
31321300|Conjuntos remachados de material en barras|O|O||D||1
31321301|Ensambles de barras remachadas de aluminio|O|O||D||1
31321302|Ensambles de barras remachadas de acero al carbono|O|O||D||1
31321303|Ensambles de barras remachadas de aleación hast x|O|O||D||1|Ensambles de barras remachadas de aleación hastelloy x
31321304|Ensambles de barras remachadas de inconel|O|O||D||1
31321305|Ensambles de barras remachadas de acero de aleación baja|O|O||D||1
31321306|Ensambles de barras remachadas no metálica|O|O||D||1|Ensambles de barras remachadas plásticas
31321309|Ensambles de barras remachadas de acero inoxidable|O|O||D||1
31321310|Ensambles de barras remachadas de titanio|O|O||D||1
31321311|Ensambles de barras remachadas de aleación wasp|O|O||D||1
31321312|Ensambles de barras remachadas de cobre|O|O||D||1
31321313|Ensambles de barras remachadas de latón|O|O||D||1
31321400|Conjuntos soldados o soldados en fuerte de material en barras|O|O||D||1
31321401|Ensambles de barras soldadas con soldadura fuerte o débil de aluminio|O|O||D||1
31321402|Ensambles de barras soldadas con soldadura fuerte o débil de acero al carbono|O|O||D||1
31321403|Ensambles de barras soldadas con soldadura fuerte o débil de aleación hast x|O|O||D||1|Ensambles de barras soldadas con soldadura fuerte o débil de aleación hastelloy x
31321404|Ensambles de barras soldadas con soldadura fuerte o débil de inconel|O|O||D||1
31321405|Ensambles de barras soldadas con soldadura fuerte o débil de acero de aleación baja|O|O||D||1
31321406|Ensambles de barras soldadas con soldadura fuerte o débil no metálica|O|O||D||1|Ensambles de barras soldadas con soldadura fuerte o débil plástica
31321409|Ensambles de barras soldadas con soldadura fuerte o débil de acero inoxidable|O|O||D||1
31321410|Ensambles de barras soldadas con soldadura fuerte o débil de titanio|O|O||D||1
31321411|Ensambles de barras soldadas con soldadura fuerte o débil de aleación wasp|O|O||D||1
31321412|Ensambles de barras soldadas con soldadura fuerte o débil de cobre|O|O||D||1
31321413|Ensambles de barras soldadas con soldadura fuerte o débil de latón|O|O||D||1
31321500|Conjuntos de barras soldadas con ultra violeta UV|O|O||D||1
31321501|Ensambles de barras soldadas con soldadura ultra violeta de aluminio|O|O||D||1
31321502|Ensambles de barras soldadas con soldadura ultra violeta de acero al carbono|O|O||D||1
31321503|Ensambles de barras soldadas con soldadura ultra violeta de aleación hast x|O|O||D||1|Ensambles de barras soldadas con soldadura ultra violeta de aleación hastelloy x
31321504|Ensambles de barras soldadas con soldadura ultra violeta de inconel|O|O||D||1
31321505|Ensambles de barras soldadas con soldadura ultra violeta de acero de aleación baja|O|O||D||1
31321506|Ensambles de barras soldadas con soldadura ultra violeta no metálica|O|O||D||1|Ensambles de barras soldadas con soldadura ultra violeta de plástico
31321509|Ensambles de barras soldadas con soldadura ultra violeta de acero inoxidable|O|O||D||1
31321510|Ensambles de barras soldadas con soldadura ultra violeta de titanio|O|O||D||1
31321511|Ensambles de barras soldadas con soldadura ultra violeta de aleación wasp|O|O||D||1
31321512|Ensambles de barras soldadas con soldadura ultra violeta de cobre|O|O||D||1
31321513|Ensambles de barras soldadas con soldadura ultra violeta de latón|O|O||D||1
31321600|Conjuntos sónicos soldados de material en barras|O|O||D||1
31321601|Ensambles de barras soldadas con soldadura sónica de aluminio|O|O||D||1
31321602|Ensambles de barras soldadas con soldadura sónica de acero al carbono|O|O||D||1
31321603|Ensambles de barras soldadas con soldadura sónica de aleación hast x|O|O||D||1|Ensambles de barras soldadas con soldadura sónica de aleación hastelloy x
31321604|Ensambles de barras soldadas con soldadura sónica de inconel|O|O||D||1
31321605|Ensambles de barras soldadas con soldadura sónica de acero de aleación baja|O|O||D||1
31321606|Ensambles de barras soldadas con soldadura sónica no metálica|O|O||D||1|Ensambles de barras soldadas con soldadura sónica plástica
31321609|Ensambles de barras soldadas con soldadura sónica de acero inoxidable|O|O||D||1
31321610|Ensambles de barras soldadas con soldadura sónica de titanio|O|O||D||1
31321611|Ensambles de barras soldadas con soldadura sónica de aleación wasp|O|O||D||1
31321612|Ensambles de barras soldadas con soldadura sónica de cobre|O|O||D||1
31321613|Ensambles de barras soldadas con soldadura sónica de latón|O|O||D||1
31321700|Conjuntos empernados de material en barras|O|O||D||1
31321701|Ensambles de barras atornilladas de aluminio|O|O||D||1
31321702|Ensambles de barras atornilladas de acero al carbono|O|O||D||1
31321703|Ensambles de barras atornilladas de aleación hast x|O|O||D||1|Ensamble de barras atornilladas de aleación hastelloy x
31321704|Ensambles de barras atornilladas de inconel|O|O||D||1
31321705|Ensambles de barras atornilladas de acero de aleación baja|O|O||D||1
31321706|Ensambles de barras atornilladas no metálica|O|O||D||1|Ensambles de barras atornilladas de plástico
31321709|Ensambles de barras atornilladas de acero inoxidable|O|O||D||1
31321710|Ensambles de barras atornilladas de titanio|O|O||D||1
31321711|Ensambles de barras atornilladas de aleación wasp|O|O||D||1
31321712|Ensambles de barras atornilladas de cobre|O|O||D||1
31321713|Ensambles de barras atornilladas de latón|O|O||D||1
31331100|Conjuntos estructurales con acabado ligado|O|O||D||1
31331101|Ensambles estructurales pegados de aluminio|O|O||D||1
31331102|Ensambles estructurales pegados de acero al carbono|O|O||D||1
31331103|Ensambles estructurales pegados de aleación hast x|O|O||D||1|Ensambles estructurales pegados de aleación hastelloy x
31331104|Ensambles estructurales pegados de inconel|O|O||D||1
31331105|Ensambles estructurales pegados de acero de aleación baja|O|O||D||1
31331106|Ensambles estructurales pegados no metálica|O|O||D||1|Ensambles estructurales pegados de plástico
31331109|Ensambles estructurales pegados de acero inoxidable|O|O||D||1
31331110|Ensambles estructurales pegados de titanio|O|O||D||1
31331111|Ensambles estructurales pegados de aleación wasp|O|O||D||1
31331112|Ensambles estructurales pegados de cobre|O|O||D||1
31331113|Ensambles estructurales pegados de latón|O|O||D||1
31331200|Conjuntos estructurales empernados|O|O||D||1
31331201|Ensambles estructurales atornillados de aluminio|O|O||D||1
31331202|Ensambles estructurales atornillados de acero al carbono|O|O||D||1
31331203|Ensambles estructurales atornillados de aleación hast x|O|O||D||1|Ensambles estructurales atornillados de aleación hastelloy x
31331204|Ensambles estructurales atornillados de inconel|O|O||D||1
31331205|Ensambles estructurales atornillados de acero de aleación baja|O|O||D||1
31331206|Ensambles estructurales atornillados no metálica|O|O||D||1|Ensambles estructurales atornillados de plástico
31331209|Ensambles estructurales atornillados de acero inoxidable|O|O||D||1
31331210|Ensambles estructurales atornillados de titanio|O|O||D||1
31331211|Ensambles estructurales atornillados de aleación wasp|O|O||D||1
31331212|Ensambles estructurales atornillados de cobre|O|O||D||1
31331213|Ensambles estructurales atornillados de latón|O|O||D||1
31331300|Conjuntos estructurales soldado sónico|O|O||D||1
31331301|Ensambles estructurales con soldadura sónica de aluminio|O|O||D||1
31331302|Ensambles estructurales con soldadura sónica de acero al carbono|O|O||D||1
31331303|Ensambles estructurales con soldadura sónica de aleación hast x|O|O||D||1|Ensambles estructurales con soldadura sónica de aleación hastelloy x
31331304|Ensambles estructurales con soldadura sónica de inconel|O|O||D||1
31331305|Ensambles estructurales con soldadura sónica de acero de aleación baja|O|O||D||1
31331306|Ensambles estructurales con soldadura sónica no metálica|O|O||D||1|Ensambles estructurales con soldadura sónica plástica
31331309|Ensambles estructurales con soldadura sónica de acero inoxidable|O|O||D||1
31331310|Ensambles estructurales con soldadura sónica de titanio|O|O||D||1
31331311|Ensambles estructurales con soldadura sónica de aleación wasp|O|O||D||1
31331312|Ensambles estructurales con soldadura sónica de cobre|O|O||D||1
31331313|Ensambles estructurales con soldadura sónica de latón|O|O||D||1
31331400|Conjuntos estructurales soldados con ultra violeta UV|O|O||D||1
31331401|Ensambles estructurales con soldadura ultra violeta de aluminio|O|O||D||1
31331402|Ensambles estructurales con soldadura ultra violeta de acero al carbono|O|O||D||1
31331403|Ensambles estructurales con soldadura ultra violeta de aleación hast x|O|O||D||1|Ensambles estructurales con soldadura ultra violeta de aleación hastelloy x
31331404|Ensambles estructurales con soldadura ultra violeta de inconel|O|O||D||1
31331405|Ensambles estructurales con soldadura ultra violeta de acero de aleación baja|O|O||D||1
31331406|Ensambles estructurales con soldadura ultra violeta no metálica|O|O||D||1|Ensambles estructurales con soldadura ultra violeta plástica
31331409|Ensambles estructurales con soldadura ultra violeta de acero inoxidable|O|O||D||1
31331410|Ensambles estructurales con soldadura ultra violeta de titanio|O|O||D||1
31331411|Ensambles estructurales con soldadura ultra violeta de aleación wasp|O|O||D||1
31331412|Ensambles estructurales con soldadura ultra violeta de cobre|O|O||D||1
31331413|Ensambles estructurales con soldadura ultra violeta de latón|O|O||D||1
31331500|Conjuntos estructurales soldado de solvente|O|O||D||1
31331501|Ensambles estructurales con soldadura de solvente de aluminio|O|O||D||1
31331502|Ensambles estructurales con soldadura de solvente de acero al carbono|O|O||D||1
31331503|Ensambles estructurales con soldadura de solvente de aleación hast x|O|O||D||1|Ensambles estructurales con soldadura de solvente de aleación hestalloy x
31331504|Ensambles estructurales con soldadura de solvente de inconel|O|O||D||1
31331505|Ensambles estructurales con soldadura de solvente de acero de aleación baja|O|O||D||1
31331506|Ensambles estructurales con soldadura de solvente no metálica|O|O||D||1
31331509|Ensambles estructurales con soldadura de solvente de acero inoxidable|O|O||D||1
31331510|Ensambles estructurales con soldadura de solvente de titanio|O|O||D||1
31331511|Ensambles estructurales con soldadura de solvente de aleación wasp|O|O||D||1
31331512|Ensambles estructurales con soldadura de solvente de cobre|O|O||D||1
31331513|Ensambles estructurales con soldadura de solvente de latón|O|O||D||1
31331600|Conjuntos estructurales soldado o soldado con latón|O|O||D||1
31331601|Ensambles estructurales con soldadura de fuerte o débil de aluminio|O|O||D||1
31331602|Ensambles estructurales con soldadura de fuerte o débil de acero al carbono|O|O||D||1
31331603|Ensambles estructurales con soldadura de fuerte o débil de aleación hast x|O|O||D||1|Ensambles estructurales con soldadura de fuerte o débil de aleación hastelloy x
31331604|Ensambles estructurales con soldadura de fuerte o débil de inconel|O|O||D||1
31331605|Ensambles estructurales con soldadura de fuerte o débil de acero de aleación baja|O|O||D||1
31331606|Ensambles estructurales con soldadura de fuerte o débil no metálica|O|O||D||1|Ensambles estructurales con soldadura de fuerte o débil plástica
31331609|Ensambles estructurales con soldadura de fuerte o débil de acero inoxidable|O|O||D||1
31331610|Ensambles estructurales con soldadura de fuerte o débil de titanio|O|O||D||1
31331611|Ensambles estructurales con soldadura de fuerte o débil de aleación wasp|O|O||D||1
31331612|Ensambles estructurales con soldadura de fuerte o débil de cobre|O|O||D||1
31331613|Ensambles estructurales con soldadura de fuerte o débil de latón|O|O||D||1
31331700|Conjuntos estructurales remachados|O|O||D||1
31331701|Ensambles estructurales remachados de aluminio|O|O||D||1
31331702|Ensambles estructurales remachados de acero al carbono|O|O||D||1
31331703|Ensambles estructurales remachados de aleación hast x|O|O||D||1|Ensambles estructurales remachados de aleación hastelloy x
31331704|Ensambles estructurales remachados de inconel|O|O||D||1
31331705|Ensambles estructurales remachados de acero de aleación baja|O|O||D||1
31331706|Ensambles estructurales remachados no metálica|O|O||D||1|Ensambles estructurales remachados de plástico
31331709|Ensambles estructurales remachados de acero inoxidable|O|O||D||1
31331710|Ensambles estructurales remachados de titanio|O|O||D||1
31331711|Ensambles estructurales remachados de aleación wasp|O|O||D||1
31331712|Ensambles estructurales remachados de cobre|O|O||D||1
31331713|Ensambles estructurales remachados de latón|O|O||D||1
31341100|Conjuntos de placa soldado o soldado con latón|O|O||D||1
31341101|Ensambles de láminas soldadas con soldadura fuerte o débil de aluminio|O|O||D||1
31341102|Ensambles de láminas soldadas con soldadura fuerte o débil de acero al carbono|O|O||D||1
31341103|Ensambles de láminas soldadas con soldadura fuerte o débil de aleación hast x|O|O||D||1|Ensambles de láminas soldadas con soldadura fuerte o débil de aleación hastelloy x
31341104|Ensambles de láminas soldadas con soldadura fuerte o débil de inconel|O|O||D||1
31341105|Ensambles de láminas soldadas con soldadura fuerte o débil de acero de aleación baja|O|O||D||1
31341106|Ensambles de láminas soldadas con soldadura fuerte o débil no metálica|O|O||D||1|Ensambles de láminas soldadas con soldadura fuerte o débil plástica
31341109|Ensambles de láminas soldadas con soldadura fuerte o débil de acero inoxidable|O|O||D||1
31341110|Ensambles de láminas soldadas con soldadura fuerte o débil de titanio|O|O||D||1
31341111|Ensambles de láminas soldadas con soldadura fuerte o débil de aleación wasp|O|O||D||1
31341112|Ensambles de láminas soldadas con soldadura fuerte o débil de cobre|O|O||D||1
31341113|Ensambles de láminas soldadas con soldadura fuerte o débil de latón|O|O||D||1
31341200|Conjuntos remachados de placa|O|O||D||1
31341201|Ensambles de láminas remachadas de aluminio|O|O||D||1
31341202|Ensambles de láminas remachadas de acero al carbono|O|O||D||1
31341203|Ensambles de láminas remachadas de aleación hast x|O|O||D||1|Ensambles de láminas remachadas de aleación hastelloy x
31341204|Ensambles de láminas remachadas de inconel|O|O||D||1
31341205|Ensambles de láminas remachadas de acero de aleación baja|O|O||D||1
31341206|Ensambles de láminas remachadas no metálica|O|O||D||1|Ensambles de láminas remachadas de plástico
31341209|Ensambles de láminas remachadas de acero inoxidable|O|O||D||1
31341210|Ensambles de láminas remachadas de titanio|O|O||D||1
31341211|Ensambles de láminas remachadas de aleación wasp|O|O||D||1
31341212|Ensambles de láminas remachadas de cobre|O|O||D||1
31341213|Ensambles de láminas remachadas de latón|O|O||D||1
31341300|Conjuntos de láminas soldadas con ultra violeta UV|O|O||D||1
31341301|Ensambles de láminas soldadas con soldadura ultra violeta de aluminio|O|O||D||1
31341302|Ensambles de láminas soldadas con soldadura ultra violeta de acero al carbono|O|O||D||1
31341303|Ensambles de láminas soldadas con soldadura ultra violeta de aleación hast x|O|O||D||1|Ensamble de láminas soldadas con soldadura ultra violeta de aleación hastelloy x
31341304|Ensambles de láminas soldadas con soldadura ultra violeta de inconel|O|O||D||1
31341305|Ensambles de láminas soldadas con soldadura ultra violeta de acero de aleación baja|O|O||D||1
31341306|Ensambles de láminas soldadas con soldadura ultra violeta no metálica|O|O||D||1|Ensambles de láminas soldadas con soldadura ultra violeta plástica
31341309|Ensambles de láminas soldadas con soldadura ultra violeta de acero inoxidable|O|O||D||1
31341310|Ensambles de láminas soldadas con soldadura ultra violeta de titanio|O|O||D||1
31341311|Ensambles de láminas soldadas con soldadura ultra violeta de aleación wasp|O|O||D||1
31341312|Ensambles de láminas soldadas con soldadura ultra violeta de cobre|O|O||D||1
31341313|Ensambles de láminas soldadas con soldadura ultra violeta de latón|O|O||D||1
31341400|Conjuntos de lámina soldada sónica|O|O||D||1
31341401|Ensambles de láminas soldadas con soldadura sónica de aluminio|O|O||D||1
31341402|Ensambles de láminas soldadas con soldadura sónica de acero al carbono|O|O||D||1
31341403|Ensambles de láminas soldadas con soldadura sónica de aleación hast x|O|O||D||1|Ensambles de láminas soldadas con soldadura sónica de aleación hastelloy x
31341404|Ensambles de láminas soldadas con soldadura sónica de inconel|O|O||D||1
31341405|Ensambles de láminas soldadas con soldadura sónica de acero de aleación baja|O|O||D||1
31341406|Ensambles de láminas soldadas con soldadura sónica no metálica|O|O||D||1|Ensamble de láminas soldadas con soldadura plástica
31341409|Ensambles de láminas soldadas con soldadura sónica de acero inoxidable|O|O||D||1
31341410|Ensambles de láminas soldadas con soldadura sónica de titanio|O|O||D||1
31341411|Ensambles de láminas soldadas con soldadura sónica de aleación wasp|O|O||D||1
31341412|Ensambles de láminas soldadas con soldadura sónica de cobre|O|O||D||1
31341413|Ensambles de láminas soldadas con soldadura sónica de latón|O|O||D||1
31341500|Conjuntos de lámina soldada de solvente|O|O||D||1
31341501|Ensambles de láminas soldadas con soldadura solvente de aluminio|O|O||D||1
31341502|Ensambles de láminas soldadas con soldadura solvente de acero al carbono|O|O||D||1
31341503|Ensambles de láminas soldadas con soldadura solvente de aleación hast x|O|O||D||1|Ensambles de láminas soldadas con soldadura solvente de aleación hastelloy x
31341504|Ensambles de láminas soldadas con soldadura solvente de inconel|O|O||D||1
31341505|Ensambles de láminas soldadas con soldadura solvente de acero de aleación baja|O|O||D||1
31341506|Ensambles de láminas soldadas con soldadura solvente no metálica|O|O||D||1
31341509|Ensambles de láminas soldadas con soldadura solvente de acero inoxidable|O|O||D||1
31341510|Ensambles de láminas soldadas con soldadura solvente de titanio|O|O||D||1
31341511|Ensambles de láminas soldadas con soldadura solvente de aleación wasp|O|O||D||1
31341512|Ensambles de láminas soldadas con soldadura solvente de cobre|O|O||D||1
31341513|Ensambles de láminas soldadas con soldadura solvente de latón|O|O||D||1
31341600|Conjuntos de lámina con acabado ligado|O|O||D||1
31341601|Ensambles de láminas pegadas de aluminio|O|O||D||1
31341602|Ensambles de láminas pegadas de acero al carbono|O|O||D||1
31341603|Ensambles de láminas pegadas de aleación hast x|O|O||D||1|Ensamble de láminas pegadas de aleación hastelloy x
31341604|Ensambles de láminas pegadas de inconel|O|O||D||1
31341605|Ensambles de láminas pegadas de acero de aleación baja|O|O||D||1
31341606|Ensambles de láminas pegadas no metálica|O|O||D||1
31341609|Ensambles de láminas pegadas de acero inoxidable|O|O||D||1
31341610|Ensambles de láminas pegadas de titanio|O|O||D||1
31341611|Ensambles de láminas pegadas de aleación wasp|O|O||D||1
31341612|Ensambles de láminas pegadas de cobre|O|O||D||1
31341613|Ensambles de láminas pegadas de latón|O|O||D||1
31341700|Conjuntos de lámina empernada|O|O||D||1
31341701|Ensambles de láminas atornilladas de aluminio|O|O||D||1
31341702|Ensambles de láminas atornilladas de acero al carbono|O|O||D||1
31341703|Ensambles de láminas atornilladas de aleación hast x|O|O||D||1|Ensambles de láminas atornilladas de aleación hastelloy x
31341704|Ensambles de láminas atornilladas de inconel|O|O||D||1
31341705|Ensambles de láminas atornilladas de acero de aleación baja|O|O||D||1
31341706|Ensambles de láminas atornilladas no metálica|O|O||D||1|Ensambles de láminas atornilladas de plástico
31341709|Ensambles de láminas atornilladas de acero inoxidable|O|O||D||1
31341710|Ensambles de láminas atornilladas de titanio|O|O||D||1
31341711|Ensambles de láminas atornilladas de aleación wasp|O|O||D||1
31341712|Ensambles de láminas atornilladas de cobre|O|O||D||1
31341713|Ensambles de láminas atornilladas de latón|O|O||D||1
31351100|Conjuntos de tubos soldados con ultra violeta UV|O|O||D||1
31351101|Ensambles de tubos soldados con soldadura ultra violeta de aluminio|O|O||D||1
31351102|Ensambles de tubos soldados con soldadura ultra violeta de acero al carbono|O|O||D||1
31351103|Ensambles de tubos soldados con soldadura ultra violeta de aleación hast x|O|O||D||1|Ensambles de tubos soldados con soldadura ultra violeta de aleación hastelloy x
31351104|Ensambles de tubos soldados con soldadura ultra violeta de inconel|O|O||D||1
31351105|Ensambles de tubos soldados con soldadura ultra violeta de acero de aleación baja|O|O||D||1
31351106|Ensambles de tubos soldados con soldadura ultra violeta no metálica|O|O||D||1|Ensambles de tubos soldados con soldadura ultra violeta plástica
31351109|Ensambles de tubos soldados con soldadura ultra violeta de acero inoxidable|O|O||D||1
31351110|Ensambles de tubos soldados con soldadura ultra violeta de titanio|O|O||D||1
31351111|Ensambles de tubos soldados con soldadura ultra violeta de aleación wasp|O|O||D||1
31351112|Ensambles de tubos soldados con soldadura ultra violeta de cobre|O|O||D||1
31351113|Ensambles de tubos soldados con soldadura ultra violeta de latón|O|O||D||1
31351200|Conjuntos de tubería soldada o soldada con latón|O|O||D||1
31351201|Ensambles de tubos soldados con soldadura fuerte o débil de aluminio|O|O||D||1
31351202|Ensambles de tubos soldados con soldadura fuerte o débil de acero al carbono|O|O||D||1
31351203|Ensambles de tubos soldados con soldadura fuerte o débil de aleación hast x|O|O||D||1|Ensambles de tubos soldados con soldadura fuerte o débil de aleación hastelloy x
31351204|Ensambles de tubos soldados con soldadura fuerte o débil de inconel|O|O||D||1
31351205|Ensambles de tubos soldados con soldadura fuerte o débil de acero de aleación baja|O|O||D||1
31351206|Ensambles de tubos soldados con soldadura fuerte o débil no metálica|O|O||D||1|Ensambles de tubos soldados con soldadura fuerte o débil plástica
31351209|Ensambles de tubos soldados con soldadura fuerte o débil de acero inoxidable|O|O||D||1
31351210|Ensambles de tubos soldados con soldadura fuerte o débil de titanio|O|O||D||1
31351211|Ensambles de tubos soldados con soldadura fuerte o débil de aleación wasp|O|O||D||1
31351212|Ensambles de tubos soldados con soldadura fuerte o débil de cobre|O|O||D||1
31351213|Ensambles de tubos soldados con soldadura fuerte o débil de latón|O|O||D||1
31351300|Conjuntos de tubería remachada|O|O||D||1
31351301|Ensambles de tubos remachados de aluminio|O|O||D||1
31351302|Ensambles de tubos remachados de acero al carbono|O|O||D||1
31351303|Ensambles de tubos remachados de aleación hast x|O|O||D||1|Ensambles de tubos remachados de aleación hastelloy x
31351304|Ensambles de tubos remachados de inconel|O|O||D||1
31351305|Ensambles de tubos remachados de acero de aleación baja|O|O||D||1
31351306|Ensambles de tubos remachados no metálica|O|O||D||1|Ensambles de tubos remangados de plástico
31351309|Ensambles de tubos remachados de acero inoxidable|O|O||D||1
31351310|Ensambles de tubos remachados de titanio|O|O||D||1
31351311|Ensambles de tubos remachados de aleación wasp|O|O||D||1
31351312|Ensambles de tubos remachados de cobre|O|O||D||1
31351313|Ensambles de tubos remachados de latón|O|O||D||1
31351400|Conjuntos de tubería ligada|O|O||D||1
31351401|Ensambles de tubos pegados de aluminio|O|O||D||1
31351402|Ensambles de tubos pegados de acero al carbono|O|O||D||1
31351403|Ensambles de tubos pegados de aleación hast x|O|O||D||1|Ensambles de tubos pegados de aleación hastelloy x
31351404|Ensambles de tubos pegados de inconel|O|O||D||1
31351405|Ensambles de tubos pegados de acero de aleación baja|O|O||D||1
31351406|Ensambles de tubos pegados no metálica|O|O||D||1|ensambles de tubos pegados de plástico
31351409|Ensambles de tubos pegados de acero inoxidable|O|O||D||1
31351410|Ensambles de tubos pegados de titanio|O|O||D||1
31351411|Ensambles de tubos pegados de aleación wasp|O|O||D||1
31351412|Ensambles de tubos pegados de cobre|O|O||D||1
31351413|Ensambles de tubos pegados de latón|O|O||D||1
31351500|Conjuntos de tubería empernados|O|O||D||1
31351501|Ensambles de tubos atornillados de aluminio|O|O||D||1
31351502|Ensambles de tubos atornillados de acero al carbono|O|O||D||1
31351503|Ensambles de tubos atornillados de aleación hast x|O|O||D||1|Ensambles de tubos atornillados de aleación hastelloy x
31351504|Ensambles de tubos atornillados de inconel|O|O||D||1
31351505|Ensambles de tubos atornillados de acero de aleación baja|O|O||D||1
31351506|Ensambles de tubos atornillados no metálica|O|O||D||1|Ensambles de tubos atornillados de plástico
31351509|Ensambles de tubos atornillados de acero inoxidable|O|O||D||1
31351510|Ensambles de tubos atornillados de titanio|O|O||D||1
31351511|Ensambles de tubos atornillados de aleación wasp|O|O||D||1
31351512|Ensambles de tubos atornillados de cobre|O|O||D||1
31351513|Ensambles de tubos atornillados de latón|O|O||D||1
31351600|Conjuntos de tubería soldada de solvente|O|O||D||1
31351601|Ensambles de tubos soldados con disolvente de aluminio|O|O||D||1
31351602|Ensambles de tubos soldados con disolvente de acero al carbono|O|O||D||1
31351603|Ensambles de tubos soldados con disolvente de aleación hast x|O|O||D||1|Ensambles de tubos soldados con disolvente de aleación hastelloy x
31351604|Ensambles de tubos soldados con disolvente de inconel|O|O||D||1
31351605|Ensambles de tubos soldados con disolvente de acero de aleación baja|O|O||D||1
31351606|Ensambles de tubos soldados con disolvente no metálica|O|O||D||1
31351609|Ensambles de tubos soldados con disolvente de acero inoxidable|O|O||D||1
31351610|Ensambles de tubos soldados con disolvente de titanio|O|O||D||1
31351611|Ensambles de tubos soldados con disolvente de aleación wasp|O|O||D||1
31351612|Ensambles de tubos soldados con disolvente de cobre|O|O||D||1
31351613|Ensambles de tubos soldados con disolvente de latón|O|O||D||1
31351700|Conjuntos de tubería soldada sónica|O|O||D||1
31351701|Ensambles de tubos soldados con soldadura sónica de aluminio|O|O||D||1
31351702|Ensambles de tubos soldados con soldadura sónica de acero al carbono|O|O||D||1
31351703|Ensambles de tubos soldados con soldadura sónica de aleación hast x|O|O||D||1|Ensambles de tubos soldados con soldadura sónica de aleación hastelloy x
31351704|Ensambles de tubos soldados con soldadura sónica de inconel|O|O||D||1
31351705|Ensambles de tubos soldados con soldadura sónica de acero de aleación baja|O|O||D||1
31351706|Ensambles de tubos soldados con soldadura sónica no metálica|O|O||D||1|Ensambles de tubos soldados con soldadura sónica plástica
31351709|Ensambles de tubos soldados con soldadura sónica de acero inoxidable|O|O||D||1
31351710|Ensambles de tubos soldados con soldadura sónica de titanio|O|O||D||1
31351711|Ensambles de tubos soldados con soldadura sónica de aleación wasp|O|O||D||1
31351712|Ensambles de tubos soldados con soldadura sónica de cobre|O|O||D||1
31351713|Ensambles de tubos soldados con soldadura sónica de latón|O|O||D||1
31361100|Conjuntos de placa ligados|O|O||D||1
31361101|Ensambles de placas soldadas de aluminio|O|O||D||1
31361102|Ensambles de placas soldadas de acero al carbono|O|O||D||1
31361103|Ensambles de placas soldadas de aleación hast x|O|O||D||1|Ensambles de placas soldadas de aleación hastelloy x
31361104|Ensambles de placas soldadas de inconel|O|O||D||1
31361105|Ensambles de placas soldadas de acero de aleación baja|O|O||D||1
31361106|Ensambles de placas soldadas no metálica|O|O||D||1|Ensambles de placas soldadas de plástico
31361109|Ensambles de placas soldadas de acero inoxidable|O|O||D||1
31361110|Ensambles de placas soldadas de titanio|O|O||D||1
31361111|Ensambles de placas soldadas de aleación wasp|O|O||D||1
31361112|Ensambles de placas soldadas de cobre|O|O||D||1
31361113|Ensambles de placas soldadas de latón|O|O||D||1
31361200|Conjuntos de placa empernados|O|O||D||1
31361201|Ensambles de placas atornilladas de aluminio|O|O||D||1
31361202|Ensambles de placas atornilladas de acero al carbono|O|O||D||1
31361203|Ensambles de placas atornilladas de aleación hast x|O|O||D||1|Ensambles de placas atornilladas de aleación hastelloy x
31361204|Ensambles de placas atornilladas de inconel|O|O||D||1
31361205|Ensambles de placas atornilladas de acero de aleación baja|O|O||D||1
31361206|Ensambles de placas atornilladas no metálica|O|O||D||1|Ensambles de placas atornilladas de plástico
31361209|Ensambles de placas atornilladas de acero inoxidable|O|O||D||1
31361210|Ensambles de placas atornilladas de titanio|O|O||D||1
31361211|Ensambles de placas atornilladas de aleación wasp|O|O||D||1
31361212|Ensambles de placas atornilladas de cobre|O|O||D||1
31361213|Ensambles de placas atornilladas de latón|O|O||D||1
31361300|Conjuntos de placa soldados de solvente|O|O||D||1
31361301|Ensambles de placas soldadas con solvente de aluminio|O|O||D||1
31361302|Ensambles de placas soldadas con solvente de acero al carbono|O|O||D||1
31361303|Ensambles de placas soldadas con solvente de aleación hast x|O|O||D||1|Ensambles de placas soldadas con solvente de aleación hastelloy x
31361304|Ensambles de placas soldadas con solvente de inconel|O|O||D||1
31361305|Ensambles de placas soldadas con solvente de acero de aleación baja|O|O||D||1
31361306|Ensambles de placas soldadas con solvente no metálica|O|O||D||1
31361309|Ensambles de placas soldadas con solvente de acero inoxidable|O|O||D||1
31361310|Ensambles de placas soldadas con solvente de titanio|O|O||D||1
31361311|Ensambles de placas soldadas con solvente de aleación wasp|O|O||D||1
31361312|Ensambles de placas soldadas con solvente de cobre|O|O||D||1
31361313|Ensambles de placas soldadas con solvente de latón|O|O||D||1
31361400|Conjuntos de placas soldadas o soldadas con latón|O|O||D||1
31361401|Ensambles de placas soldadas con soldadura fuerte o débil de aluminio|O|O||D||1
31361402|Ensambles de placas soldadas con soldadura fuerte o débil de acero al carbono|O|O||D||1
31361403|Ensambles de placas soldadas con soldadura fuerte o débil de aleación hast x|O|O||D||1|Ensambles de placas soldadas con soldadura fuerte o débil de aleación hastelloy x
31361404|Ensambles de placas soldadas con soldadura fuerte o débil de inconel|O|O||D||1
31361405|Ensambles de placas soldadas con soldadura fuerte o débil de acero de aleación baja|O|O||D||1
31361406|Ensambles de placas soldadas con soldadura fuerte o débil no metálica|O|O||D||1
31361409|Ensambles de placas soldadas con soldadura fuerte o débil de acero inoxidable|O|O||D||1
31361410|Ensambles de placas soldadas con soldadura fuerte o débil de titanio|O|O||D||1
31361411|Ensambles de placas soldadas con soldadura fuerte o débil de aleación wasp|O|O||D||1|Ensambles de placas soldadas con soldadura fuerte o débil de aleación waspaloy
31361412|Ensambles de placas soldadas con soldadura fuerte o débil de cobre|O|O||D||1
31361413|Ensambles de placas soldadas con soldadura fuerte o débil de latón|O|O||D||1
31361500|Conjuntos de placas soldadas con ultra violeta UV|O|O||D||1
31361501|Ensambles de placas soldadas con soldadura ultra violeta de aluminio|O|O||D||1
31361502|Ensambles de placas soldadas con soldadura ultra violeta de acero al carbono|O|O||D||1
31361503|Ensambles de placas soldadas con soldadura ultra violeta de aleación hast x|O|O||D||1|Ensambles de placas soldadas con soldadura ultra violeta de aleación hastelloy x
31361504|Ensambles de placas soldadas con soldadura ultra violeta de inconel|O|O||D||1
31361505|Ensambles de placas soldadas con soldadura ultra violeta de acero de aleación baja|O|O||D||1
31361506|Ensambles de placas soldadas con soldadura ultra violeta no metálica|O|O||D||1
31361509|Ensambles de placas soldadas con soldadura ultra violeta de acero inoxidable|O|O||D||1
31361510|Ensambles de placas soldadas con soldadura ultra violeta de titanio|O|O||D||1
31361511|Ensambles de placas soldadas con soldadura ultra violeta de aleación wasp|O|O||D||1|Ensambles de placas soldadas con soldadura ultra violeta de aleación waspaloy
31361512|Ensambles de placas soldadas con soldadura ultra violeta de cobre|O|O||D||1
31361513|Ensambles de placas soldadas con soldadura ultra violeta de latón|O|O||D||1
31361600|Conjuntos de placas soldadas con sónico|O|O||D||1
31361601|Ensambles de placas soldadas con soldadura sónica de aluminio|O|O||D||1
31361602|Ensambles de placas soldadas con soldadura sónica de acero al carbono|O|O||D||1
31361603|Ensambles de placas soldadas con soldadura sónica de aleación hast x|O|O||D||1|Ensambles de placas soldadas con soldadura sónica de aleación hastelloy x
31361604|Ensambles de placas soldadas con soldadura sónica de inconel|O|O||D||1
31361605|Ensambles de placas soldadas con soldadura sónica de acero de aleación baja|O|O||D||1
31361606|Ensambles de placas soldadas con soldadura sónica no metálica|O|O||D||1
31361609|Ensambles de placas soldadas con soldadura sónica de acero inoxidable|O|O||D||1
31361610|Ensambles de placas soldadas con soldadura sónica de titanio|O|O||D||1
31361611|Ensambles de placas soldadas con soldadura sónica de aleación wasp|O|O||D||1|Ensambles de placas soldadas con soldadura sónica de aleación waspaloy
31361612|Ensambles de placas soldadas con soldadura sónica de cobre|O|O||D||1
31361613|Ensambles de placas soldadas con soldadura sónica de latón|O|O||D||1
31361700|Conjuntos de placas remachadas|O|O||D||1
31361701|Ensambles de placas remachadas de aluminio|O|O||D||1
31361702|Ensambles de placas remachadas de acero al carbono|O|O||D||1
31361703|Ensambles de placas remachadas de aleación hast x|O|O||D||1|Ensambles de placas remachadas de aleación hastelloy x
31361704|Ensambles de placas remachadas de inconel|O|O||D||1
31361705|Ensambles de placas remachadas de acero de aleación baja|O|O||D||1
31361706|Ensambles de placas remachadas no metálica|O|O||D||1
31361709|Ensambles de placas remachadas de acero inoxidable|O|O||D||1
31361710|Ensambles de placas remachadas de titanio|O|O||D||1
31361711|Ensambles de placas remachadas de aleación wasp|O|O||D||1|Ensambles de placas remachadas de aleación waspaloy
31361712|Ensambles de placas remachadas de cobre|O|O||D||1
31361713|Ensambles de placas remachadas de latón|O|O||D||1
31371000|Productos de fibra de cerámica|O|O||D||1
31371001|Paneles aislantes|O|O||D||1
31371002|Lana aislante|O|O||D||1
31371003|Sábanas refractarias|O|O||D||1
31371100|Ladrillos refractarios|O|O||D||1
31371101|Ladrillo de mulita|O|O||D||1
31371102|Ladrillos de silimanita|O|O||D||1
31371103|Ladrillos resistentes al ácido|O|O||D||1
31371104|Ladrillos de sílice|O|O||D||1
31371105|Ladrillos de alta alúmina|O|O||D||1
31371106|Ladrillos de silicato de calcio|O|O||D||1
31371107|Ladrillos con formas|O|O||D||1
31371108|Ladrillos de arcilla de fuego|O|O||D||1
31371200|Compuestos para moldear|O|O||D||1
31371201|Moldeables densos|O|O||D||1
31371202|Moldeables de aislación|O|O||D||1
31371203|Moldeables bajos en cemento|O|O||D||1
31371204|Moldeables resistentes a ácidos o a álcalis|O|O||D||1
31371205|Moldeables resistentes a abrasión|O|O||D||1
31371206|Moldeables sic|O|O||D||1
31371207|Moldeables de auto flujo|O|O||D||1
31371208|Moldeable tabular alúmina|O|O||D||1
31371209|Moldeable resistente a la erosión|O|O||D||1
31371210|Moldeable de alta alúmina|O|O||D||1
31371211|Moldeable de arcilla de fuego|O|O||D||1
31371212|Moldeable de servicio especial|O|O||D||1
31371300|Refractarios formados|O|O||D||1
31371301|Bloques porosos|O|O||D||1
31371302|Boquillas de zircón|O|O||D||1
31371400|Losetas refractarias|O|O||D||1
31371401|Tejas de sílice|O|O||D||1
31381100|Imanes fundidos y ensambles magnéticos|O|O||D||1
31381101|Imán isotrópico fundido maquinado de ferrita|O|O||D||1
31381102|Imán isotrópico fundido maquinado de bario ferrita|O|O||D||1
31381103|Imán isotrópico fundido maquinado de estroncio ferrita|O|O||D||1
31381104|Imán isotrópico fundido maquinado de neodimio|O|O||D||1
31381105|Imán isotrópico fundido maquinado de samario cobalto|O|O||D||1
31381106|Imán isotrópico fundido maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381107|Imán anisotrópico fundido maquinado de ferrita|O|O||D||1
31381108|Imán anisotrópico fundido maquinado de bario ferrita|O|O||D||1
31381109|Imán anisotrópico fundido maquinado de estroncio ferrita|O|O||D||1
31381110|Imán anisotrópico fundido maquinado de samario cobalto|O|O||D||1
31381111|Imán anisotrópico fundido maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381112|Imán isotrópico fundido, maquinado y recubierto de ferrita|O|O||D||1
31381113|Imán isotrópico fundido, maquinado y recubierto de bario ferrita|O|O||D||1
31381114|Imán isotrópico fundido, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381115|Imán isotrópico fundido, maquinado y recubierto de neodimio|O|O||D||1
31381116|Imán isotrópico fundido, maquinado y recubierto de samario cobalto|O|O||D||1
31381117|Imán isotrópico fundido, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381118|Imán anisotrópico fundido, maquinado y recubierto  de ferrita|O|O||D||1
31381119|Imán anisotrópico fundido, maquinado y recubierto  de bario ferrita|O|O||D||1
31381120|Imán anisotrópico fundido, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381121|Imán anisotrópico fundido, maquinado y recubierto de samario cobalto|O|O||D||1
31381122|Imán anisotrópico fundido, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381123|Imán isotrópico fundido recubierto de ferrita|O|O||D||1
31381124|Imán isotrópico fundido recubierto de bario ferrita|O|O||D||1
31381125|Imán isotrópico fundido recubierto de estroncio ferrita|O|O||D||1
31381126|Imán isotrópico fundido recubierto de neodimio|O|O||D||1
31381127|Imán isotrópico fundido recubierto de samario cobalto|O|O||D||1
31381128|Imán isotrópico fundido recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381129|Imán anisotrópico fundido recubierto de ferrita|O|O||D||1
31381130|Imán anisotrópico fundido recubierto de bario ferrita|O|O||D||1
31381131|Imán anisotrópico fundido recubierto de estroncio ferrita|O|O||D||1
31381132|Imán anisotrópico fundido recubierto de samario cobalto|O|O||D||1
31381133|Imán anisotrópico fundido recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381134|Herramienta isotrópica fundida maquinada de ferrita|O|O||D||1
31381135|Herramienta isotrópica fundida maquinada de bario ferrita|O|O||D||1
31381136|Herramienta isotrópica fundida maquinada de estroncio ferrita|O|O||D||1
31381137|Herramienta isotrópica fundida maquinada de neodimio|O|O||D||1
31381138|Herramienta isotrópica fundida maquinada de samario cobalto|O|O||D||1
31381139|Herramienta isotrópica fundida maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381140|Herramienta anisotrópica fundida maquinada de ferrita|O|O||D||1
31381141|Herramienta anisotrópica fundida maquinada de bario ferrita|O|O||D||1
31381142|Herramienta anisotrópica fundida maquinada de estroncio ferrita|O|O||D||1
31381143|Herramienta anisotrópica fundida maquinada de samario cobalto|O|O||D||1
31381144|Herramienta anisotrópica fundida maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381145|Ensamble de imán isotrópico fundido de ferrita|O|O||D||1
31381146|Ensamble de imán isotrópico fundido de bario ferrita|O|O||D||1
31381147|Ensamble de imán isotrópico fundido de estroncio ferrita|O|O||D||1
31381148|Ensamble de imán isotrópico fundido de neodimio|O|O||D||1
31381149|Ensamble de imán isotrópico fundido de samario cobalto|O|O||D||1
31381150|Ensamble de imán isotrópico fundido de aluminio níquel cobalto ferroso|O|O||D||1
31381151|Ensamble de imán anisotrópico fundido de ferrita|O|O||D||1
31381152|Ensamble de imán anisotrópico fundido de bario ferrita|O|O||D||1
31381153|Ensamble de imán anisotrópico fundido de estroncio ferrita|O|O||D||1
31381154|Ensamble de imán anisotrópico fundido de samario cobalto|O|O||D||1
31381155|Ensamble de imán anisotrópico fundido de aluminio níquel cobalto ferroso|O|O||D||1
31381200|Imanes sinterizados y ensambles magnéticos|O|O||D||1
31381201|Imán isotrópico sinterizado maquinado de ferrita|O|O||D||1
31381202|Imán isotrópico sinterizado maquinado de bario ferrita|O|O||D||1
31381203|Imán isotrópico sinterizado maquinado de estroncio ferrita|O|O||D||1
31381204|Imán isotrópico sinterizado maquinado de neodimio|O|O||D||1
31381205|Imán isotrópico sinterizado maquinado de samario cobalto|O|O||D||1
31381206|Imán isotrópico sinterizado maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381207|Imán anisotrópico sinterizado maquinado de ferrita|O|O||D||1
31381208|Imán anisotrópico sinterizado maquinado de bario ferrita|O|O||D||1
31381209|Imán anisotrópico sinterizado maquinado de estroncio ferrita|O|O||D||1
31381210|Imán anisotrópico sinterizado maquinado de samario cobalto|O|O||D||1
31381211|Imán anisotrópico sinterizado maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381212|Imán isotrópico sinterizado, maquinado y recubierto de ferrita|O|O||D||1
31381213|Imán isotrópico sinterizado, maquinado y recubierto de bario ferrita|O|O||D||1
31381214|Imán isotrópico sinterizado, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381215|Imán isotrópico sinterizado, maquinado y recubierto de neodimio|O|O||D||1
31381216|Imán isotrópico sinterizado, maquinado y recubierto de samario cobalto|O|O||D||1
31381217|Imán isotrópico sinterizado, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381218|Imán anisotrópico sinterizado, maquinado y recubierto  de ferrita|O|O||D||1
31381219|Imán anisotrópico sinterizado, maquinado y recubierto  de bario ferrita|O|O||D||1
31381220|Imán anisotrópico sinterizado, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381221|Imán anisotrópico sinterizado, maquinado y recubierto de samario cobalto|O|O||D||1
31381222|Imán anisotrópico sinterizado, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381223|Imán isotrópico sinterizado recubierto de ferrita|O|O||D||1
31381224|Imán isotrópico sinterizado recubierto de bario ferrita|O|O||D||1
31381225|Imán isotrópico sinterizado recubierto de estroncio ferrita|O|O||D||1
31381226|Imán isotrópico sinterizado recubierto de neodimio|O|O||D||1
31381227|Imán isotrópico sinterizado recubierto de samario cobalto|O|O||D||1
31381228|Imán isotrópico sinterizado recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381229|Imán anisotrópico sinterizado recubierto de ferrita|O|O||D||1
31381230|Imán anisotrópico sinterizado recubierto de bario ferrita|O|O||D||1
31381231|Imán anisotrópico sinterizado recubierto de estroncio ferrita|O|O||D||1
31381232|Imán anisotrópico sinterizado recubierto de samario cobalto|O|O||D||1
31381233|Imán anisotrópico sinterizado recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381234|Herramienta isotrópica sinterizada maquinada de ferrita|O|O||D||1
31381235|Herramienta isotrópica sinterizada maquinada de bario ferrita|O|O||D||1
31381236|Herramienta isotrópica sinterizada maquinada de estroncio ferrita|O|O||D||1
31381237|Herramienta isotrópica sinterizada maquinada de neodimio|O|O||D||1
31381238|Herramienta isotrópica sinterizada maquinada de samario cobalto|O|O||D||1
31381239|Herramienta isotrópica sinterizada maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381240|Herramienta anisotrópica sinterizada maquinada de ferrita|O|O||D||1
31381241|Herramienta anisotrópica sinterizada maquinada de bario ferrita|O|O||D||1
31381242|Herramienta anisotrópica sinterizada maquinada de estroncio ferrita|O|O||D||1
31381243|Herramienta anisotrópica sinterizada maquinada de samario cobalto|O|O||D||1
31381244|Herramienta anisotrópica sinterizada maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381245|Ensamble de imán isotrópico sinterizado de ferrita|O|O||D||1
31381246|Ensamble de imán isotrópico sinterizado de bario ferrita|O|O||D||1
31381247|Ensamble de imán isotrópico sinterizado de estroncio ferrita|O|O||D||1
31381248|Ensamble de imán isotrópico sinterizado de neodimio|O|O||D||1
31381249|Ensamble de imán isotrópico sinterizado de samario cobalto|O|O||D||1
31381250|Ensamble de imán isotrópico sinterizado de aluminio níquel cobalto ferroso|O|O||D||1
31381251|Ensamble de imán anisotrópico sinterizado de ferrita|O|O||D||1
31381252|Ensamble de imán anisotrópico sinterizado de bario ferrita|O|O||D||1
31381253|Ensamble de imán anisotrópico sinterizado de estroncio ferrita|O|O||D||1
31381254|Ensamble de imán anisotrópico sinterizado de samario cobalto|O|O||D||1
31381255|Ensamble de imán anisotrópico sinterizado de aluminio níquel cobalto ferroso|O|O||D||1
31381300|Imanes prensados y ensambles magnéticos|O|O||D||1
31381301|Imán isotrópico prensado y sinterizado maquinado de ferrita|O|O||D||1
31381302|Imán isotrópico prensado y sinterizado maquinado de bario ferrita|O|O||D||1
31381303|Imán isotrópico prensado y sinterizado maquinado de estroncio ferrita|O|O||D||1
31381304|Imán isotrópico prensado y sinterizado maquinado de neodimio|O|O||D||1
31381305|Imán isotrópico prensado y sinterizado maquinado de samario cobalto|O|O||D||1
31381306|Imán isotrópico prensado y sinterizado maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381307|Imán anisotrópico prensado y sinterizado maquinado de ferrita|O|O||D||1
31381308|Imán anisotrópico prensado y sinterizado maquinado de bario ferrita|O|O||D||1
31381309|Imán anisotrópico prensado y sinterizado maquinado de estroncio ferrita|O|O||D||1
31381310|Imán anisotrópico prensado y sinterizado maquinado de samario cobalto|O|O||D||1
31381311|Imán anisotrópico prensado y sinterizado maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381312|Imán isotrópico prensado y sinterizado, maquinado y recubierto de ferrita|O|O||D||1
31381313|Imán isotrópico prensado y sinterizado, maquinado y recubierto de bario ferrita|O|O||D||1
31381314|Imán isotrópico prensado y sinterizado, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381315|Imán isotrópico prensado y sinterizado, maquinado y recubierto de neodimio|O|O||D||1
31381316|Imán isotrópico prensado y sinterizado, maquinado y recubierto de samario cobalto|O|O||D||1
31381317|Imán isotrópico prensado y sinterizado, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381318|Imán anisotrópico prensado y sinterizado, maquinado y recubierto  de ferrita|O|O||D||1
31381319|Imán anisotrópico prensado y sinterizado, maquinado y recubierto  de bario ferrita|O|O||D||1
31381320|Imán anisotrópico prensado y sinterizado, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381321|Imán anisotrópico prensado y sinterizado, maquinado y recubierto de samario cobalto|O|O||D||1
31381322|Imán anisotrópico prensado y sinterizado, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381323|Imán isotrópico prensado y sinterizado recubierto de ferrita|O|O||D||1
31381324|Imán isotrópico prensado y sinterizado recubierto de bario ferrita|O|O||D||1
31381325|Imán isotrópico prensado y sinterizado recubierto de estroncio ferrita|O|O||D||1
31381326|Imán isotrópico prensado y sinterizado recubierto de neodimio|O|O||D||1
31381327|Imán isotrópico prensado y sinterizado recubierto de samario cobalto|O|O||D||1
31381328|Imán isotrópico prensado y sinterizado recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381329|Imán anisotrópico prensado y sinterizado recubierto de ferrita|O|O||D||1
31381330|Imán anisotrópico prensado y sinterizado recubierto de bario ferrita|O|O||D||1
31381331|Imán anisotrópico prensado y sinterizado recubierto de estroncio ferrita|O|O||D||1
31381332|Imán anisotrópico prensado y sinterizado recubierto de samario cobalto|O|O||D||1
31381333|Imán anisotrópico prensado y sinterizado recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381334|Herramienta isotrópica prensada y sinterizada maquinada de ferrita|O|O||D||1
31381335|Herramienta isotrópica prensada y sinterizada maquinada de bario ferrita|O|O||D||1
31381336|Herramienta isotrópica prensada y sinterizada maquinada de estroncio ferrita|O|O||D||1
31381337|Herramienta isotrópica prensada y sinterizada maquinada de neodimio|O|O||D||1
31381338|Herramienta isotrópica prensada y sinterizada maquinada de samario cobalto|O|O||D||1
31381339|Herramienta isotrópica prensada y sinterizada maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381340|Herramienta anisotrópica prensada y sinterizada maquinada de ferrita|O|O||D||1
31381341|Herramienta anisotrópica prensada y sinterizada maquinada de bario ferrita|O|O||D||1
31381342|Herramienta anisotrópica prensada y sinterizada maquinada de estroncio ferrita|O|O||D||1
31381343|Herramienta anisotrópica prensada y sinterizada maquinada de samario cobalto|O|O||D||1
31381344|Herramienta anisotrópica prensada y sinterizada maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381345|Ensamble de imán isotrópico prensado y sinterizado de ferrita|O|O||D||1
31381346|Ensamble de imán isotrópico prensado y sinterizado de bario ferrita|O|O||D||1
31381347|Ensamble de imán isotrópico prensado y sinterizado de estroncio ferrita|O|O||D||1
31381348|Ensamble de imán isotrópico prensado y sinterizado de neodimio|O|O||D||1
31381349|Ensamble de imán isotrópico prensado y sinterizado de samario cobalto|O|O||D||1
31381350|Ensamble de imán isotrópico prensado y sinterizado de aluminio níquel cobalto ferroso|O|O||D||1
31381351|Ensamble de imán anisotrópico prensado y sinterizado de ferrita|O|O||D||1
31381352|Ensamble de imán anisotrópico prensado y sinterizado de bario ferrita|O|O||D||1
31381353|Ensamble de imán anisotrópico prensado y sinterizado de estroncio ferrita|O|O||D||1
31381354|Ensamble de imán anisotrópico prensado y sinterizado de samario cobalto|O|O||D||1
31381355|Ensamble de imán anisotrópico prensado y sinterizado de aluminio níquel cobalto ferroso|O|O||D||1
31381400|Imanes pegados con plástico y ensambles magnéticos|O|O||D||1
31381401|Imán isotrópico pegado con plástico maquinado de ferrita|O|O||D||1
31381402|Imán isotrópico pegado con plástico maquinado de bario ferrita|O|O||D||1
31381403|Imán isotrópico pegado con plástico maquinado de estroncio ferrita|O|O||D||1
31381404|Imán isotrópico pegado con plástico maquinado de neodimio|O|O||D||1
31381405|Imán isotrópico pegado con plástico maquinado de samario cobalto|O|O||D||1
31381406|Imán isotrópico pegado con plástico maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381407|Imán anisotrópico pegado con plástico maquinado de ferrita|O|O||D||1
31381408|Imán anisotrópico pegado con plástico maquinado de bario ferrita|O|O||D||1
31381409|Imán anisotrópico pegado con plástico maquinado de estroncio ferrita|O|O||D||1
31381410|Imán anisotrópico pegado con plástico maquinado de samario cobalto|O|O||D||1
31381411|Imán anisotrópico pegado con plástico maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381412|Imán isotrópico pegado con plástico, maquinado y recubierto de ferrita|O|O||D||1
31381413|Imán isotrópico pegado con plástico, maquinado y recubierto de bario ferrita|O|O||D||1
31381414|Imán isotrópico pegado con plástico, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381415|Imán isotrópico pegado con plástico, maquinado y recubierto de neodimio|O|O||D||1
31381416|Imán isotrópico pegado con plástico, maquinado y recubierto de samario cobalto|O|O||D||1
31381417|Imán isotrópico pegado con plástico, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381418|Imán anisotrópico pegado con plástico, maquinado y recubierto  de ferrita|O|O||D||1
31381419|Imán anisotrópico pegado con plástico, maquinado y recubierto  de bario ferrita|O|O||D||1
31381420|Imán anisotrópico pegado con plástico, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381421|Imán anisotrópico pegado con plástico, maquinado y recubierto de samario cobalto|O|O||D||1
31381422|Imán anisotrópico pegado con plástico, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381423|Imán isotrópico pegado con plástico recubierto de ferrita|O|O||D||1
31381424|Imán isotrópico pegado con plástico recubierto de bario ferrita|O|O||D||1
31381425|Imán isotrópico pegado con plástico recubierto de estroncio ferrita|O|O||D||1
31381426|Imán isotrópico pegado con plástico recubierto de neodimio|O|O||D||1
31381427|Imán isotrópico pegado con plástico recubierto de samario cobalto|O|O||D||1
31381428|Imán isotrópico pegado con plástico recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381429|Imán anisotrópico pegado con plástico recubierto de ferrita|O|O||D||1
31381430|Imán anisotrópico pegado con plástico recubierto de bario ferrita|O|O||D||1
31381431|Imán anisotrópico pegado con plástico recubierto de estroncio ferrita|O|O||D||1
31381432|Imán anisotrópico pegado con plástico recubierto de samario cobalto|O|O||D||1
31381433|Imán anisotrópico pegado con plástico recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381434|Herramienta isotrópica pegada con plástico maquinada de ferrita|O|O||D||1
31381435|Herramienta isotrópica pegada con plástico maquinada de bario ferrita|O|O||D||1
31381436|Herramienta isotrópica pegada con plástico maquinada de estroncio ferrita|O|O||D||1
31381437|Herramienta isotrópica pegada con plástico maquinada de neodimio|O|O||D||1
31381438|Herramienta isotrópica pegada con plástico maquinada de samario cobalto|O|O||D||1
31381439|Herramienta isotrópica pegada con plástico maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381440|Herramienta anisotrópica pegada con plástico maquinada de ferrita|O|O||D||1
31381441|Herramienta anisotrópica pegada con plástico maquinada de bario ferrita|O|O||D||1
31381442|Herramienta anisotrópica pegada con plástico maquinada de estroncio ferrita|O|O||D||1
31381443|Herramienta anisotrópica pegada con plástico maquinada de samario cobalto|O|O||D||1
31381444|Herramienta anisotrópica pegada con plástico maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381445|Ensamble de imán isotrópico pegado con plástico de ferrita|O|O||D||1
31381446|Ensamble de imán isotrópico pegado con plástico de bario ferrita|O|O||D||1
31381447|Ensamble de imán isotrópico pegado con plástico de estroncio ferrita|O|O||D||1
31381448|Ensamble de imán isotrópico pegado con plástico de neodimio|O|O||D||1
31381449|Ensamble de imán isotrópico pegado con plástico de samario cobalto|O|O||D||1
31381450|Ensamble de imán isotrópico pegado con plástico de aluminio níquel cobalto ferroso|O|O||D||1
31381451|Ensamble de imán anisotrópico pegado con plástico de ferrita|O|O||D||1
31381452|Ensamble de imán anisotrópico pegado con plástico de bario ferrita|O|O||D||1
31381453|Ensamble de imán anisotrópico pegado con plástico de estroncio ferrita|O|O||D||1
31381454|Ensamble de imán anisotrópico pegado con plástico de samario cobalto|O|O||D||1
31381455|Ensamble de imán anisotrópico pegado con plástico de aluminio níquel cobalto ferroso|O|O||D||1
31381500|Imanes moldeados por inyección y ensambles magnéticos|O|O||D||1
31381501|Imán isotrópico pegado con plástico moldeado por inyección maquinado de ferrita|O|O||D||1
31381502|Imán isotrópico pegado con plástico moldeado por inyección maquinado de bario ferrita|O|O||D||1
31381503|Imán isotrópico pegado con plástico moldeado por inyección maquinado de estroncio ferrita|O|O||D||1
31381504|Imán isotrópico pegado con plástico moldeado por inyección maquinado de neodimio|O|O||D||1
31381505|Imán isotrópico pegado con plástico moldeado por inyección maquinado de samario cobalto|O|O||D||1
31381506|Imán isotrópico pegado con plástico moldeado por inyección maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381507|Imán anisotrópico pegado con plástico moldeado por inyección maquinado de ferrita|O|O||D||1
31381508|Imán anisotrópico pegado con plástico moldeado por inyección maquinado de bario ferrita|O|O||D||1
31381509|Imán anisotrópico pegado con plástico moldeado por inyección maquinado de estroncio ferrita|O|O||D||1
31381510|Imán anisotrópico pegado con plástico moldeado por inyección maquinado de samario cobalto|O|O||D||1
31381511|Imán anisotrópico pegado con plástico moldeado por inyección maquinado de aluminio níquel cobalto ferroso|O|O||D||1
31381512|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de ferrita|O|O||D||1
31381513|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de bario ferrita|O|O||D||1
31381514|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381515|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de neodimio|O|O||D||1
31381516|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de samario cobalto|O|O||D||1
31381517|Imán isotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381518|Imán anisotrópico pegado con plástico moldeado por inyección, maquinado y recubierto  de ferrita|O|O||D||1
31381519|Imán anisotrópico pegado con plástico moldeado por inyección, maquinado y recubierto  de bario ferrita|O|O||D||1
31381520|Imán anisotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de estroncio ferrita|O|O||D||1
31381521|Imán anisotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de samario cobalto|O|O||D||1
31381522|Imán anisotrópico pegado con plástico moldeado por inyección, maquinado y recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381523|Imán isotrópico pegado con plástico moldeado por inyección recubierto de ferrita|O|O||D||1
31381524|Imán isotrópico pegado con plástico moldeado por inyección recubierto de bario ferrita|O|O||D||1
31381525|Imán isotrópico pegado con plástico moldeado por inyección recubierto de estroncio ferrita|O|O||D||1
31381526|Imán isotrópico pegado con plástico moldeado por inyección recubierto de neodimio|O|O||D||1
31381527|Imán isotrópico pegado con plástico moldeado por inyección recubierto de samario cobalto|O|O||D||1
31381528|Imán isotrópico pegado con plástico moldeado por inyección recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381529|Imán anisotrópico pegado con plástico moldeado por inyección recubierto de ferrita|O|O||D||1
31381530|Imán anisotrópico pegado con plástico moldeado por inyección recubierto de bario ferrita|O|O||D||1
31381531|Imán anisotrópico pegado con plástico moldeado por inyección recubierto de estroncio ferrita|O|O||D||1
31381532|Imán anisotrópico pegado con plástico moldeado por inyección recubierto de samario cobalto|O|O||D||1
31381533|Imán anisotrópico pegado con plástico moldeado por inyección recubierto de aluminio níquel cobalto ferroso|O|O||D||1
31381534|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de ferrita|O|O||D||1
31381535|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de bario ferrita|O|O||D||1
31381536|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de estroncio ferrita|O|O||D||1
31381537|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de neodimio|O|O||D||1
31381538|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de samario cobalto|O|O||D||1
31381539|Herramienta isotrópica pegada con plástico moldeada por inyección maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381540|Herramienta anisotrópica pegada con plástico moldeada por inyección maquinada de ferrita|O|O||D||1
31381541|Herramienta anisotrópica pegada con plástico moldeada por inyección maquinada de bario ferrita|O|O||D||1
31381542|Herramienta anisotrópica pegada con plástico moldeada por inyección maquinada de estroncio ferrita|O|O||D||1
31381543|Herramienta anisotrópica pegada con plástico moldeada por inyección maquinada de samario cobalto|O|O||D||1
31381544|Herramienta anisotrópica pegada con plástico moldeada por inyección maquinada de aluminio níquel cobalto ferroso|O|O||D||1
31381545|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de ferrita|O|O||D||1
31381546|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de bario ferrita|O|O||D||1
31381547|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de estroncio ferrita|O|O||D||1
31381548|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de neodimio|O|O||D||1
31381549|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de samario cobalto|O|O||D||1
31381550|Ensamble de imán isotrópico pegado con plástico moldeado por inyección de aluminio níquel cobalto ferroso|O|O||D||1
31381551|Ensamble de imán anisotrópico pegado con plástico moldeado por inyección de ferrita|O|O||D||1
31381552|Ensamble de imán anisotrópico pegado con plástico moldeado por inyección de bario ferrita|O|O||D||1
31381553|Ensamble de imán anisotrópico pegado con plástico moldeado por inyección de estroncio ferrita|O|O||D||1
31381554|Ensamble de imán anisotrópico pegado con plástico moldeado por inyección de samario cobalto|O|O||D||1
31381555|Ensamble de imán anisotrópico pegado con plástico moldeado por inyección de aluminio níquel cobalto ferroso|O|O||D||1
31391500|Maquinados de precisión estándar|O|O||D||1
31391501|Maquinado de precisión estándar de plástico|O|O||D||1
31391502|Maquinado de precisión estándar de cerámica|O|O||D||1
31391503|Maquinado de precisión estándar de acero|O|O||D||1
31391504|Maquinado de precisión estándar de acero inoxidable|O|O||D||1
31391505|Maquinado de precisión estándar de aluminio|O|O||D||1
31391506|Maquinado de precisión estándar de latón|O|O||D||1
31391600|Maquinados de precisión media|O|O||D||1
31391601|Maquinado de precisión media de plástico|O|O||D||1
31391602|Maquinado de precisión media de cerámica|O|O||D||1
31391603|Maquinado de precisión media de acero|O|O||D||1
31391604|Maquinado de precisión media de acero inoxidable|O|O||D||1
31391605|Maquinado de precisión media de aluminio|O|O||D||1
31391606|Maquinado de precisión media de latón|O|O||D||1
31391700|Maquinados de precisión alta|O|O||D||1
31391701|Maquinado de alta precisión de plástico|O|O||D||1
31391702|Maquinado de alta precisión de cerámica|O|O||D||1
31391703|Maquinado de alta precisión de acero|O|O||D||1
31391704|Maquinado de alta precisión de acero inoxidable|O|O||D||1
31391705|Maquinado de alta precisión de aluminio|O|O||D||1
31391706|Maquinado de alta precisión de latón|O|O||D||1
31401500|Empaques Moldeados|O|O||D||1
31401501|Empaque moldeado de caucho|O|O||D||1
31401502|Empaque moldeado de plástico|O|O||D||1
31401503|Empaque moldeado o – ring|O|O||D||1|Juntas moldeadas con anillo tórico
31401504|Empaque moldeado de interferencia electromagnética|O|O||D||1
31401505|Empaque moldeado de silicona|O|O||D||1
31401506|Empaque moldeado inflable|O|O||D||1
31401507|Kit de empaque moldeado|O|O||D||1
31401600|Empaques troquelados|O|O||D||1
31401601|Empaque troquelado de caucho|O|O||D||1
31401602|Empaque troquelado de plástico|O|O||D||1
31401603|Empaque troquelado de textil|O|O||D||1
31401604|Empaque troquelado de corcho|O|O||D||1
31401605|Empaque troquelado de interferencia electromagnética o emi|O|O||D||1
31401606|Empaque troquelado de silicona|O|O||D||1
31401607|Empaque troquelado de fibra comprimida|O|O||D||1
31401608|Empaque troquelado de bi – material|O|O||D||1
31401609|Empaque troquelado de polietifluroetileno|O|O||D||1
31401610|Kit de empaque troquelado|O|O||D||1
31401700|Empaques estampados|O|O||D||1
31401701|Empaque de caucho estampado recubierto de acero|O|O||D||1
31401702|Empaque estampado de plástico|O|O||D||1
31401703|Empaque estampado de caucho|O|O||D||1
31401704|Empaque estampado de metal|O|O||D||1
31401705|Empaque estampado de textil|O|O||D||1
31401706|Empaque estampado de corcho|O|O||D||1
31401707|Empaque estampado atornillado|O|O||D||1
31401708|Kit de empaque estampado|O|O||D||1|Juego de juntas estampadas
31401800|Empaques cortados con chorro de agua|O|O||D||1
31401801|Empaque de interferencia electromagnética cortado con chorro de agua|O|O||D||1
31401802|Empaque  de caucho cortado con chorro de agua|O|O||D||1
31401803|Empaque  de plástico cortado con chorro de agua|O|O||D||1
31401804|Empaque de textil cortado con chorro de agua|O|O||D||1
31401805|Empaque de corcho cortado con chorro de agua|O|O||D||1
31401806|Empaque de silicona cortado con chorro de agua|O|O||D||1
31401807|Kit de empaque cortado con chorro de agua|O|O||D||1|Juego de juntas de corte por chorro de agua
31401900|Empaques líquidos|O|O||D||1
31401901|Empaque líquido de poli acrilato|O|O||D||1
31401902|Empaque líquido de silicona|O|O||D||1
31401903|Empaque líquido de solvente|O|O||D||1
31401904|Empaque líquido anaeróbico|O|O||D||1
31411500|Sellos torneados|O|O||D||1
31411501|Sello torneado de caucho|O|O||D||1
31411502|Sello torneado de politetrafluroetileno|O|O||D||1
31411503|Sello torneado de neopreno|O|O||D||1
31411504|Sello torneado de poliacrilato|O|O||D||1
31411505|Sello torneado metálico|O|O||D||1
31411506|Kit de sello torneado|O|O||D||1|Juego de sellos de corte de torno
31411600|Sellos troquelados|O|O||D||1
31411601|Sello troquelado de caucho|O|O||D||1
31411602|Sello troquelado de espuma|O|O||D||1
31411603|Sello troquelado de plástico|O|O||D||1
31411604|Kit de sello troquelado|O|O||D||1|Juego de sellos troquelados
31411605|Sello troquelado de silicona|O|O||D||1
31411700|Sellos mecánicos|O|O||D||1
31411701|Sello mecánico de empuje|O|O||D||1
31411702|Sello mecánico de fuelle|O|O||D||1
31411703|Kit de sello mecánico|O|O||D||1|Juego de sellos mecánicos
31411704|Sello  v – ring|O|O||D||1
31411705|Sello de labio|O|O||D||1
31411800|Sellos de diafragma|O|O||D||1
31411801|Sello de diafragma soldado|O|O||D||1
31411802|Sello de diafragma de abrazadera|O|O||D||1
31411803|Sello de diafragma de cápsula|O|O||D||1
31411804|Sello de diafragma de caucho|O|O||D||1
31411805|Sello de diafragma de fibra reforzada|O|O||D||1
31411900|Sellos moldeados|O|O||D||1
31411901|Sello moldeado de caucho|O|O||D||1
31411902|Sello moldeado de plástico|O|O||D||1
31411903|Sello moldeado de precisión|O|O||D||1
31411904|Sello moldeado de caucho sobre metal o plástico|O|O||D||1
31411905|Sello moldeado de silicona|O|O||D||1
31421500|Sellos sinterizados|O|O||D||1
31421501|Filtro sinterizado estándar de hierro cobre|O|O||D||1
31421502|Filtro sinterizado estándar compuesto de hierro magnético suave|O|O||D||1
31421503|Filtro sinterizado de alta temperatura compuesto de hierro magnético suave|O|O||D||1
31421504|Filtro sinterizado estándar de acero inoxidable|O|O||D||1
31421505|Filtro sinterizado de alta temperatura de acero inoxidable|O|O||D||1
31421506|Filtro sinterizado compacto estándar de acero inoxidable|O|O||D||1
31421507|Filtro sinterizado estándar de níquel cobalto|O|O||D||1
31421508|Filtro sinterizado de alta temperatura de níquel cobalto|O|O||D||1
31421509|Filtro sinterizado compacto estándar de níquel cobalto|O|O||D||1
31421510|Filtro sinterizado estándar de aluminio|O|O||D||1
31421511|Filtro sinterizado alta temperatura de níquel cobalto|O|O||D||1
31421512|Filtro sinterizado estándar de base de cobre|O|O||D||1
31421513|Filtro sinterizado estándar de aleación de titanio|O|O||D||1
31421514|Filtro sinterizado de alta temperatura de aleación de titanio|O|O||D||1
31421515|Filtro sinterizado estándar de berilio|O|O||D||1
31421516|Filtro sinterizado de alta temperatura de berilio|O|O||D||1
31421517|Filtro sinterizado estándar de metal refractario|O|O||D||1
31421518|Filtro sinterizado de alta temperatura de metal refractario|O|O||D||1
31421519|Filtro sinterizado estándar de cerámica|O|O||D||1
31421520|Filtro sinterizado de alta temperatura de cerámica|O|O||D||1
31421521|Filtro sinterizado estándar de polvo de hierro puro|O|O||D||1
31421522|Filtro sinterizado de alta temperatura de polvo de hierro puro|O|O||D||1
32101500|Conjuntos de circuitos y componentes de radiofrecuencia (RF)|O|O||D||1
32101502|Montajes de circuitos impresos (pca)|O|O||D||1|Montajes de circuitos impresos en placa
32101503|Conjuntos de circuitos mixtos|O|O||D||1
32101504|Ensamblajes de circuitos montados en superficie|O|O||D||1
32101505|Ensamblajes de circuitos electro plateados|O|O||D||1
32101506|Tarjetas de circuito de doble cara|O|O||D||1
32101507|Tarjetas de tablero de conectores de circuitos|O|O||D||1
32101508|Tarjetas de circuito multi capa|O|O||D||1
32101509|Tarjetas de circuito de una cara|O|O||D||1
32101510|Tablero de cables impreso|O|O||D||1
32101512|Demoduladores|O|O||D||1
32101513|Conjuntos de circuitos de aplicaciones específicas|O|O||D||1
32101514|Amplificadores|O|O||D||1
32101515|Atenuadores|O|O||D||1
32101516|Circuladores|O|O||D||1
32101517|Acopladores|O|O||D||1
32101518|Líneas de retardo|O|O||D||1
32101519|Detectores|O|O||D||1
32101520|Cargas simuladas|O|O||D||1
32101521|Filtros de radiofrecuencia (rf)|O|O||D||1
32101522|Aisladores|O|O||D||1
32101523|Mezcladores|O|O||D||1
32101524|Variadores de fase|O|O||D||1
32101525|Multiplexores|O|O||D||1
32101526|Amplificadores de tubos de onda|O|O||D||1
32101527|Terminaciones|O|O||D||1
32101528|Moduladores|O|O||D||1
32101529|Divisores o splitters|O|O||D||1
32101530|Combinado de radio frecuencia rf|O|O||D||1|Combinado de radiofrecuencia (RF)
32101531|Pad atenuador de red|O|O||D||1
32101532|Sustrato cerámico|O|O||D||1
32101533|Transformador de salid|O|O||D||1
32101534|Trampa de ondas|O|O||D||1
32101535|Circuito de fase modulada|O|O||D||1
32101536|Compensador de desbalance de fase y factor de potencia|O|O||D||1
32101537|Repetidor de sincro|O|O||D||1
32101538|Estabilizador de impedancia|O|O||D||1
32101539|Selector de frecuencia|O|O||D||1
32101540|Resolvedor|O|O||D||1
32101541|Transmisor de sincro|O|O||D||1
32101542|Receptor de sincro|O|O||D||1
32101543|Controlador e indicador de calibre|O|O||D||1
32101544|Oscilador de frecuencia|O|O||D||1
32101545|Bobina de antena|O|O||D||1
32101546|Multiplicador de frecuencia|O|O||D||1
32101547|Limitador|O|O||D||1
32101548|Discriminador|O|O||D||1
32101600|Circuitos integrados|O|O||D||1
32101601|Memoria de acceso aleatorio (ram)|O|O||D||1
32101602|Memoria ram dinámica (dram)|O|O||D||1|Memoria dinámica de acceso aleatorio (DRAM)
32101603|Memoria ram estática (sram)|O|O||D||1|Memoria estática de acceso aleatorio (SRAM)
32101604|Memoria rom programable (prom)|O|O||D||1|Memoria de lectura programable (PROM)
32101605|Memoria rom programable borrable (eprom)|O|O||D||1|Memoria de sólo lectura programable borrable (EPROM)
32101606|Memoria rom programable borrable eléctricamente (eeprom)|O|O||D||1|Memoria de sólo lectura programable borrable electrónicamente (EEPROM)
32101607|Circuitos integrados monolíticos de memoria (mmic)|O|O||D||1|Circuitos integrados de memoria monolítica (MMIC)
32101608|Memoria de sólo lectura (rom)|O|O||D||1|Memoria sólo de lectura (ROM)
32101609|Circuitos integrados de aplicaciones específicas (asic)|O|O||D||1|Circuitos integrados específicos de la aplicación (ASIC)
32101611|Lógica de matriz programable (pal)|O|O||D||1
32101612|Lógica de matriz de puertas (gal)|O|O||D||1
32101613|Lógica transistor-transistor (ttl)|O|O||D||1
32101614|Lógica de emisor acoplado (ecl)|O|O||D||1
32101615|Tecnología mos bipolar (bimos)|O|O||D||1|Tecnología de semiconductores de óxido metálico o bipolar (BIMOS)
32101616|Tecnología cmos bipolar (bicmos)|O|O||D||1|Tecnología de semiconductores de óxido metálico complementario bipolar (BICMOS)
32101617|Tarjetas inteligentes|O|O||D||1
32101618|Circuitos integrados ordenados hacia arriba|O|O||D||1
32101619|Circuitos integrados lineales|O|O||D||1
32101620|Circuitos integrados digitales|O|O||D||1
32101621|Memoria dram síncrona (sdram)|O|O||D||1|Memoria síncrona dinámica de acceso aleatorio (SDRAM)
32101622|Memoria flash|O|O||D||1|Tarjeta de memoria para celular
32101623|Memoria rdram (rambus)|O|O||D||1|Memoria de acceso aleatorio dinámica rambus (RDRAM)
32101624|Memoria sgram|O|O||D||1
32101625|Circuitos integrados de accionamiento o control por motor|O|O||D||1
32101626|Microprocesadores|O|O||D||1
32101627|Osciladores de reloj|O|O||D||1
32101628|Microcontroladores|O|O||D||1
32101629|Amplificadores operacionales|O|O||D||1
32101630|Circuitos integrados de regulador de tensión|O|O||D||1
32101631|Circuitos integrados de comparador de tensión|O|O||D||1
32101632|Circuitos integrados de temporizador|O|O||D||1
32101633|Puertas lógicas|O|O||D||1
32101634|Circuitos basculantes|O|O||D||1
32101635|Registros de desplazamiento|O|O||D||1
32101636|Procesador de señal digital (dsp)|O|O||D||1
32101637|Procesadores de red|O|O||D||1
32101638|Circuito integrado de aplicación específica|O|O||D||1
32101639|Microcontrolador de 8 bits|O|O||D||1
32101640|Microcontrolador de 16 bits|O|O||D||1
32101641|Procesador de señal digital de extremo bajo dsp|O|O||D||1
32101642|Microcontrolador de rango medio de 32 bits|O|O||D||1
32101643|Circuito integrado lógico programable|O|O||D||1
32101644|Procesador de señal digital de extremo alto dsp|O|O||D||1
32101645|Microcontrolador de rango alto de 32 bits|O|O||D||1
32101646|Memoria flash paralelo (nor)|O|O||D||1|Memoria flash paralela (NOR)
32101647|Memoria flash serial (nor)|O|O||D||1
32101648|Memoria flash (nand)|O|O||D||1
32101649|Circuito integrado estándar análogo o lineal|O|O||D||1
32101650|Circuito integrado de amplificador de audio análogo|O|O||D||1
32101651|Circuito integrado de amplificador de audio digital|O|O||D||1
32101652|Circuito integrado lógico estándar|O|O||D||1
32101653|Circuito integrado microondas|O|O||D||1
32101654|Circuito integrado bus transceptor|O|O||D||1
32101655|Circuito integrado de servicio de radio audio digital satelital|O|O||D||1
32101656|Circuito integrado de sistema de posicionamiento geográfico gps|O|O||D||1
32101657|Circuito integrado de sintonizador|O|O||D||1
32101658|Circuito integrado de acelerador de gráficos|O|O||D||1
32101659|Circuito integrado de exhibición de drivers|O|O||D||1
32101660|Circuito integrado de sensor de tasa angular|O|O||D||1
32101661|Circuito integrado acelerómetro|O|O||D||1
32101662|Circuito integrado efecto hall|O|O||D||1
32101663|Circuito integrado sensor temperatura infrarroja ir|O|O||D||1|Circuito integrado del sensor infrarrojo de la temperatura del IR
32101664|Circuito integrado ultrasónico|O|O||D||1
32101665|Circuito integrado de sensor de imagen|O|O||D||1
32101666|Circuito integrado de procesador de videos o media|O|O||D||1
32101667|Circuito integrado de procesador de visión|O|O||D||1
32101668|Circuito integrado condecs|O|O||D||1|Circuito integrado de códec
32101669|Circuito integrado de protocolo de comunicación|O|O||D||1
32101670|Circuito integrado de transponedor|O|O||D||1
32101671|Circuito integrado de sensor de presión|O|O||D||1
32101672|Bastidor de conductores|O|O||D||1
32111500|Diodos|O|O||D||1
32111501|Diodos de microondas|O|O||D||1
32111502|Diodos zener|O|O||D||1
32111503|Diodos emisores de luz (led)|O|O||D||1
32111504|Diodos schottky|O|O||D||1
32111505|Diodos con efecto túnel|O|O||D||1
32111506|Diodos fotosensibles|O|O||D||1
32111507|Diodos de capacitancia variable|O|O||D||1
32111508|Diodos solares|O|O||D||1
32111509|Diodos de energía|O|O||D||1
32111510|Diodos de radiofrecuencia (rf)|O|O||D||1
32111511|Diodos de señal pequeña|O|O||D||1
32111512|Diodo láser|O|O||D||1
32111513|Diodo varactor|O|O||D||1
32111514|Diodo pin|O|O||D||1
32111515|Diodo óptico|O|O||D||1
32111600|Transistores|O|O||D||1
32111601|Transistores fotosensibles|O|O||D||1
32111602|Transistor de efecto de campo (fet)|O|O||D||1
32111603|Transistores mos de efecto de campo (mosfet)|O|O||D||1|Transistores de efecto de campo de silicona de óxido metálico (MOSFET)
32111604|Chips de transistor|O|O||D||1
32111607|Transistores bipolares de radiofrecuencia (rf) o darlington|O|O||D||1
32111608|Transistores uniempalme|O|O||D||1
32111609|Transistores bipolares de puerta aislada (igbt)|O|O||D||1
32111610|Transistores de efecto de campo de unión (jfet)|O|O||D||1
32111611|Transistores bipolares de unión (bjt)|O|O||D||1
32111612|Transistor de efecto de campo de potencia|O|O||D||1
32111613|Transistor bipolar o de radio frecuencia bipolar|O|O||D||1
32111614|Transistor de efecto de campo inteligente|O|O||D||1
32111615|Transistor de efecto de campo de señal pequeña|O|O||D||1
32111616|Transistor de efecto de campo de radio frecuencia|O|O||D||1
32111700|Aparatos semiconductores|O|O||D||1
32111701|Células fotovoltaicas|O|O||D||1
32111702|Tiristores|O|O||D||1
32111703|Diacs|O|O||D||1|Diodo para corriente alterna
32111704|Triacs|O|O||D||1|Tríodo para corriente alterna
32111705|Aisladores acoplados ópticos|O|O||D||1
32111706|Osciladores a cristal|O|O||D||1
32111707|Suspector de semiconductor|O|O||D||1
32111708|Red de adaptación de impedancia|O|O||D||1
32111709|Red de compensación de temperatura|O|O||D||1
32121500|Capacitores|O|O||D||1
32121501|Capacitores fijos|O|O||D||1
32121502|Capacitores o varactores variables|O|O||D||1
32121503|Capacitores ajustables pre - ajustados|O|O||D||1
32121504|Redes de capacitores|O|O||D||1
32121505|Capacitor fijo de aluminio electrolítico|O|O||D||1
32121506|Capacitor cerámico fijo|O|O||D||1
32121507|Capacitor de película fijo|O|O||D||1
32121508|Capacitor fijo de tántalo|O|O||D||1
32121509|Capacitor de aire|O|O||D||1
32121510|Capacitor de gas|O|O||D||1
32121511|Capacitor de aceite|O|O||D||1
32121512|Capacitor de mica|O|O||D||1
32121513|Capacitor de vacío|O|O||D||1
32121514|Capacitor de papel|O|O||D||1
32121515|Capacitor de papel metalizado|O|O||D||1
32121600|Resistores|O|O||D||1
32121602|Resistores fusibles|O|O||D||1
32121603|Resistores o varistores variables|O|O||D||1
32121607|Redes de resistores|O|O||D||1
32121609|Resistores fijos|O|O||D||1
32121610|Termistor|O|O||D||1
32121611|Placa restrictora o restrictor de aire|O|O||D||1
32121612|Resistor montado en superficie|O|O||D||1
32121613|Resistor embobinado|O|O||D||1|Resistencia bobinada
32121614|Resistor de óxido de película de metal|O|O||D||1
32121615|Resistor de película de carbono|O|O||D||1
32121616|Resistor recortador|O|O||D||1
32121617|Resistor de potencia|O|O||D||1
32121618|Resistor de película de metal|O|O||D||1
32121700|Componentes discretos|O|O||D||1
32121701|Rectificadores|O|O||D||1
32121702|Inductores|O|O||D||1
32121703|Ferritas|O|O||D||1
32121704|Convertidores estáticos|O|O||D||1
32121705|Inversores|O|O||D||1
32121706|Redes r/c de resistores o capacitores|O|O||D||1
32121707|Rectificador controlado de silicona|O|O||D||1
32121708|Rectificador de puente|O|O||D||1
32121709|Inductor de embobinado|O|O||D||1
32121710|Inductor multi capa|O|O||D||1
32121711|Inductor de estrangulador|O|O||D||1
32121712|Bobina de alta frecuencia|O|O||D||1
32121800|Filtros de señales|O|O||D||1
32121801|Filtro de onda acústica de superficie saw|O|O||D||1
32121802|Filtro cerámico|O|O||D||1
32121803|Filtro de microondas|O|O||D||1
32121804|Filtro de cristal|O|O||D||1
32121900|Resonadores|O|O||D||1
32121901|Resonador de  onda acústica de superficie saw|O|O||D||1
32121902|Resonador cerámico|O|O||D||1
32131000|Accesorios, materias primas y piezas de componentes electrónicos|O|O||D||1
32131001|Piletas térmicas|O|O||D||1
32131002|Matrices de semiconductor|O|O||D||1
32131003|Pastillas de semiconductor|O|O||D||1
32131005|Paquetes de circuitos integrados|O|O||D||1
32131006|Soportes o zócalos de circuito integrado|O|O||D||1
32131007|Soportes de componentes discretos|O|O||D||1
32131008|Compuestos disipadores de calor|O|O||D||1
32131009|Aisladores para disipadores de calor|O|O||D||1
32131010|Tarjetas sencillas de circuitos impresos|O|O||D||1
32131011|Cubiertas de circuitos integrados|O|O||D||1
32131012|Objetivos de erosión superficial|O|O||D||1
32131013|Máscara de foto|O|O||D||1
32131014|Tablero de circuito impreso flexible, desnudo|O|O||D||1
32131015|Tablero de circuito impreso por un solo lado, desnudo|O|O||D||1
32131016|Tablero de circuito impreso por un ambos lados, desnudo|O|O||D||1
32131017|Tablero de circuito impreso multicapa, desnudo|O|O||D||1
32131018|Tablero de circuito impreso con capa pesada de bronce, desnudo|O|O||D||1
32131019|Tablero de circuito impreso electroplateado con oro, desnudo|O|O||D||1
32131020|Tablero de circuito impreso ensamblado flexible|O|O||D||1
32131021|Sustrato cerámico combustión combinada a baja temperatura|O|O||D||1
32131022|Cerámica para sustratos de tableros de circuitos impresos pcb|O|O||D||1|Cerámica para placas de circuitos impresos (PCB)
32131023|Soporte de dispositivos eléctricos o electrónicos|O|O||D||1
32141000|Tubos electrónicos|O|O||D||1
32141001|Tubos de rayos catódicos|O|O||D||1
32141002|Klistrones|O|O||D||1|Válvula de vacío
32141003|Magnetrones|O|O||D||1
32141004|Tubos de ondas progresivas|O|O||D||1
32141005|Tubos de disco sellado|O|O||D||1
32141006|Resnatrones|O|O||D||1|Resnatron
32141007|Tiratrones|O|O||D||1
32141008|Ignitrones|O|O||D||1
32141009|Tubos fotoeléctricos|O|O||D||1
32141010|Tubos fotomultiplicadores|O|O||D||1
32141011|Tubos receptores de televisión o cámara|O|O||D||1
32141012|Tubo de diodo|O|O||D||1
32141013|Tubo de tríodo|O|O||D||1
32141014|Tubos de tetrodo|O|O||D||1
32141015|Tubos de pentodo|O|O||D||1
32141016|Tubos múltiples|O|O||D||1
32141017|Tubo contador|O|O||D||1
32141018|Tubo de rayo de salida|O|O||D||1
32141019|Tubo electrón de microondas|O|O||D||1
32141020|Tubo convertidor de frecuencia|O|O||D||1
32141021|Tubo rectificador|O|O||D||1
32141022|Tubo regulador electrónico de voltaje|O|O||D||1
32141100|Piezas y accesorios de tubos electrónicos|O|O||D||1
32141101|Cátodos o emisores|O|O||D||1
32141102|Elementos de ánodo|O|O||D||1
32141103|Elementos de rejilla|O|O||D||1
32141104|Elementos deflectores|O|O||D||1
32141105|Obturadores o fundas de tubo|O|O||D||1
32141106|Bases de tubo|O|O||D||1
32141107|Zócalos de tubo|O|O||D||1
32141108|Clavijas de electrodo|O|O||D||1
32141109|Portaelectrodos|O|O||D||1
32141110|Pieza de polo magnético|O|O||D||1
32151500|Dispositivos de control de indicación y de señalización|O|O||D||1
32151501|Módulo de sonido de control|O|O||D||1
32151502|Módulo de luz|O|O||D||1
32151503|Apilamiento de luz|O|O||D||1
32151504|Ecualizador de circuito electrónico|O|O||D||1
32151600|Subsistemas programables de controlador lógico|O|O||D||1
32151601|Subsistema i/o chasis controlador lógico programable|O|O||D||1
32151602|Subsistema i/o chasis controlador lógico programable distribuido en gabinete|O|O||D||1
32151603|Subsistema i/o chasis controlador lógico programable distribuido en la máquina|O|O||D||1
32151700|Controladores lógicos programables|O|O||D||1
32151701|Dispositivo de unión control de red|O|O||D||1
32151702|Interfaz pc red control|O|O||D||1
32151703|Accesorios de controlador lógico programable|O|O||D||1
32151704|Chasis de controlador lógico programable|O|O||D||1
32151705|Módulo de controlador lógico programable|O|O||D||1
32151706|Suministro de energía de controlador lógico programable|O|O||D||1
32151707|Dispositivo de programación del controlador lógico programable|O|O||D||1
32151800|Dispositivos de control de seguridad|O|O||D||1
32151801|Interruptor de carga iec|O|O||D||1
32151802|Módulo de control de seguridad|O|O||D||1
32151803|Sistema de aislación de seguridad|O|O||D||1
32151804|Cortina y scanner de luz de seguridad|O|O||D||1|Escáner y barrera de seguridad
32151805|Estera (mat) y borde de seguridad|O|O||D||1
32151900|Dispositivos de automatización de control de la conectividad|O|O||D||1
32151901|Conector de paso de mamparo|O|O||D||1
32151902|Conjunto de cables del sistema de control|O|O||D||1
32151903|Caja de distribución del sistema de control|O|O||D||1
32151904|Cable de conexión del sistema de control|O|O||D||1
32151905|Receptáculo del sistema de control|O|O||D||1
32151906|Splitter del sistema de control|O|O||D||1
32151907|Cable en y del sistema de control|O|O||D||1
32151908|Cableado del sistema de control|O|O||D||1
32151909|Conector desmontable de campo|O|O||D||1
32151910|Sistema de control del panel de paso|O|O||D||1|Sistema de conexión de control de panel
32152000|Control de procesos o sistemas empaquetados de automatización|O|O||D||1
32152001|Sistema empaquetado de control distribuido dcs|O|O||D||1
32152002|Sistema empaquetado de control de supervisión y adquisición de datos scada|O|O||D||1
32152003|Sistema empaquetado de seguridad instrumentada sis|O|O||D||1|Sistema de embalaje instrumentado de seguridad (SIS)
39101600|Lámparas y bombillas|O|O||D||1|Lámparas y focos
39101601|Lámparas halógenas|O|O||D||1|Focos halógenos
39101602|Lámparas médicas|O|O||D||1
39101603|Lámparas solares|O|O||D||1
39101605|Lámparas fluorescentes|O|O||D||1|Focos fluorescentes
39101608|Luz asómbrica o scialytica de operación|O|O||D||1|Lámpara de operación asómbrica o cialítica
39101609|Lámparas de escenario o estudio|O|O||D||1
39101612|Lámparas incandescentes|O|O||D||1|Focos incandescentes
39101613|Lámparas infrarrojas|O|O||D||1
39101614|Lámparas de haluro- metálico|O|O||D||1
39101615|Lámparas de vapor de mercurio|O|O||D||1
39101616|Lámparas de rayos ultravioleta (uv)|O|O||D||1
39101617|Lámparas de sodio de alta presión hid|O|O||D||1
39101618|Lámparas de neón|O|O||D||1|Focos de neón
39101619|Lámparas compactas fluorescentes cfl|O|O||D||1
39101620|Lámparas de inducción|O|O||D||1
39101621|Lámparas de sodio de baja presión hid|O|O||D||1
39101622|Lámparas en miniatura|O|O||D||1
39101623|Lámparas de rayo sellado|O|O||D||1
39101624|Luz negra|O|O||D||1
39101625|Lámparas de xenón|O|O||D||1
39101626|Lámparas de criptón|O|O||D||1
39101627|Lámparas de arco|O|O||D||1
39101800|Componentes y accesorios de Lámpara|O|O||D||1
39101801|Filamento de lámpara|O|O||D||1
39101802|Vidrio de lámpara|O|O||D||1
39101803|Base de lámpara|O|O||D||1|Socket para foco
39101804|Ignitor de lámpara de sodio de alta presión|O|O||D||1
39101805|Capacitor seco de haluro de metal|O|O||D||1
39101806|Capacitor seco de lámpara de sodio de alta presión|O|O||D||1
39101900|Balastos de lámparas y transformadores de lámparas|O|O||D||1
39101901|Balasto fluorescente|O|O||D||1
39101902|Balasto de alta intensidad de descarga hid|O|O||D||1
39101903|Sistema de inducción de iluminación|O|O||D||1
39101904|Transformador de iluminación de bajo voltaje|O|O||D||1
39101905|Balasto de neón|O|O||D||1|Balastro de neón
39101906|Transformador de lámpara reductora|O|O||D||1
39101907|Balasto de alta intensidad de descarga  electrónica ehid|O|O||D||1|Balastro de electrónico de alta intensidad descarga EHID
39111500|Iluminación de interiores y artefactos|O|O||D||1
39111501|Artefactos fluorescentes|O|O||D||1
39111503|Dispositivos de pared|O|O||D||1
39111504|Sistemas de iluminación de escenario o estudio|O|O||D||1
39111505|Iluminación empotrada|O|O||D||1
39111506|Arañas de luces|O|O||D||1|Candelabros
39111507|Artefactos de escritorio|O|O||D||1
39111508|Alumbrado de pista|O|O||D||1
39111509|Lámparas de pie|O|O||D||1
39111510|Lámparas de mesa|O|O||D||1
39111512|Luces de banco de laboratorio|O|O||D||1
39111515|Artefactos para lámpara proyectada hacia abajo|O|O||D||1
39111520|Artefactos de alumbrado halógeno|O|O||D||1
39111521|Plafones|O|O||D||1
39111522|Iluminación colgante|O|O||D||1
39111524|Accesorio de alta intensidad de descarga hid|O|O||D||1
39111525|Accesorio incandescente|O|O||D||1
39111527|Accesorio de iluminación solar|O|O||D||1
39111528|Accesorio para debajo de gabinete|O|O||D||1
39111529|Gobo de iluminación|O|O||D||1
39111530|Accesorio para lámpara proyectada hacia abajo|O|O||D||1
39111531|Orientación para iluminación comercial|O|O||D||1
39111532|Accesorio fluorescente para grandes áreas|O|O||D||1
39111533|Banda de iluminación|O|O||D||1|Tira fluorescente
39111534|Luminaria fluorescente con lente|O|O||D||1
39111535|Accesorio parabólico|O|O||D||1
39111536|Iluminador de tocador|O|O||D||1|Iluminación de vanidad
39111537|Dispositivo para iluminaciones deportivas|O|O||D||1
39111538|Dispositivo para iluminaciones de garaje o marquesina|O|O||D||1
39111539|Caja de iluminación|O|O||D||1
39111540|Sistema de iluminación de auto – elevación|O|O||D||1
39111541|Accesorio de dispositivo de iluminación interior|O|O||D||1
39111600|Iluminación exterior y artefactos|O|O||D||1
39111603|Alumbrado de la vía pública|O|O||D||1
39111605|Iluminación paisajística|O|O||D||1
39111606|Alumbrado submarino|O|O||D||1
39111608|Alumbrado de zonas residenciales|O|O||D||1
39111609|Linternas de queroseno, propano o butano|O|O||D||1|Lámpara de queroseno, propano o butano
39111610|Linternas|O|O||D||1
39111611|Reflectores|O|O||D||1
39111612|Iluminación de áreas|O|O||D||1
39111613|Iluminación de seguridad|O|O||D||1
39111614|Dispositivo de iluminación de buzones|O|O||D||1
39111615|Luces exteriores para iluminación puntual instaladas en el suelo|O|O||D||1
39111616|Accesorios de iluminación exterior|O|O||D||1
39111700|Alumbrado de emergencia|O|O||D||1
39111703|Luces de tormenta|O|O||D||1
39111705|Barras fluorescentes o de iluminación|O|O||D||1
39111706|Luces de emergencia o estroboscópicas (licuadoras)|O|O||D||1
39111707|Unidad de salida de combo de luz|O|O||D||1
39111708|Señal iluminada de salida de emergencia|O|O||D||1|Señal luminosa de salida de emergencia
39111709|Unidad de luz de emergencia|O|O||D||1
39111710|Accesorios de iluminación de emergencia|O|O||D||1
39111711|Kit de conversión de salida de luz|O|O||D||1
39111712|Galería de montaje de luz de salida|O|O||D||1
39111713|Dispositivo de iluminación remota|O|O||D||1
39111714|Bengala de señalización|O|O||D||1
39111800|Accesorios de iluminación|O|O||D||1
39111801|Balastos de lámparas|O|O||D||1
39111802|Cubiertas de lámpara|O|O||D||1
39111803|Enchufes de lámparas|O|O||D||1
39111806|Cajas de iluminación|O|O||D||1
39111808|Parrillas|O|O||D||1
39111809|Filtros acondicionadores de luz|O|O||D||1
39111810|Interruptor de lámpara|O|O||D||1
39111811|Líneas férreas electrificadas|O|O||D||1
39111812|Pantallas de lámparas|O|O||D||1
39111813|Brazos de lámparas|O|O||D||1
39111814|Kit de brida de iluminación de marco de cielorraso|O|O||D||1|Juego de tapa de luz de marco de techo
39111815|Protector de lámpara y de dispositivo de lámpara|O|O||D||1
39111816|Lente de lámpara|O|O||D||1
39111817|Accesorio para montaje de lámpara|O|O||D||1
39111818|Reflector de lámpara|O|O||D||1
39111819|Accesorio de seguridad de lámpara|O|O||D||1
39111820|Kit de ensamble de cableado de lámpara|O|O||D||1
39111821|Kit de retro – adaptación de iluminación|O|O||D||1
39111822|Soporte de pared para iluminación|O|O||D||1
39111823|Tapa para poste de luz|O|O||D||1
39111824|Lente difusor de iluminación|O|O||D||1
39111825|Lámpara con bisagras|O|O||D||1
39111826|Juego de cables de iluminación|O|O||D||1
39111827|Reflector o redireccionador de iluminación|O|O||D||1
39111828|Dispositivo de puerta de iluminación|O|O||D||1
39111829|Cubierta del canal de iluminación|O|O||D||1
39111830|Brazo de soporte de iluminación|O|O||D||1
39111900|Señalización e iluminación de emplazamientos peligrosos|O|O||D||1
39111903|Iluminación de minería subterránea|O|O||D||1
39111904|Dispositivo de ubicación marina|O|O||D||1|Dispositivo de localización marina
39111905|Dispositivo de iluminación de sala blanca|O|O||D||1
39111906|Dispositivo de luz de servicio en condiciones difíciles|O|O||D||1
39111907|Dispositivo de luz hermética de vapor|O|O||D||1
39111908|Dispositivo de iluminación protector contra vandalismo|O|O||D||1
39111909|Accesorio de dispositivo de iluminación de ambiente especial|O|O||D||1
39112000|Proyectores móviles|O|O||D||1
39112001|Torre de luz|O|O||D||1
39112002|Carro de iluminación|O|O||D||1
39112003|Stand de iluminación|O|O||D||1
39112004|Luz para puertos de cargue|O|O||D||1
39112005|Luz fluorescente portátil|O|O||D||1
39112006|Lámpara de mano portátil|O|O||D||1
39112007|Lámpara de mano portátil de descarga de alta intensidad hid|O|O||D||1
39112008|Luz incandescente portátil|O|O||D||1
39112009|Luz de mecánicos|O|O||D||1
39112010|Luz de cuerda|O|O||D||1
39112011|Árbol o hilo de luz|O|O||D||1
39112012|Luz manual o extensión|O|O||D||1
39112013|Accesorio de iluminación portátil y temporal|O|O||D||1
39112100|Iluminación óptica|O|O||D||1
39112101|Iluminación de fibra óptica|O|O||D||1
39112102|Iluminación óptica de diodo emisor de luz led|O|O||D||1
39112200|Dispositivos de efectos especiales|O|O||D||1
39112201|Aparato de efecto atmosférico|O|O||D||1
39112202|Máquina de burbujas|O|O||D||1
39112300|Iluminación y accesorios de escenarios y estudios|O|O||D||1
39112301|Cambiador de color|O|O||D||1
39112302|Filtros de color|O|O||D||1
39112303|Soportes y marcos de filtros|O|O||D||1
39112304|Soportes gobo|O|O||D||1
39112305|Accesorios de rotadores gobo y efecto de movimiento de luz|O|O||D||1
39112306|Diafragma iris|O|O||D||1
39112307|Barras de iluminación|O|O||D||1
39112308|Sillas iluminadas|O|O||D||1
39112309|Bola de disco o bola de espejos|O|O||D||1
39112400|Dispositivos para manejo de luces y control de escenarios y estudios|O|O||D||1
39112401|Dimers y accesorios|O|O||D||1
39112402|Consolas y accesorios para el control de iluminación|O|O||D||1
39112403|Suministro de energía y unidades de control de iluminación|O|O||D||1
39112500|Luminarias de escenarios y estudios|O|O||D||1
39112501|Luz de foco|O|O||D||1
39112502|Luz de seguir|O|O||D||1
39112503|Luces móviles|O|O||D||1
39112504|Spots de latas par y pasadores|O|O||D||1|Lámparas parcan y pinspot
39112505|Luminarias tipo perfil|O|O||D||1
39112506|Bancos spot|O|O||D||1
39112507|Luces de franjas|O|O||D||1
39112508|Luminarias ultravioleta y de luz negra|O|O||D||1|Lámparas ultravioleta y de luz negra
39112600|Dispositivos de iluminación no - eléctrica|O|O||D||1
39112601|Lámpara de alcohol|O|O||D||1
39112602|Candelero|O|O||D||1
39112603|Lámpara de kerosene o de propano o de gas natural o de butano|O|O||D||1
39112604|Velas de cera|O|O||D||1
39121000|Equipamiento para distribución y conversión de alimentación|O|O||D||1
39121001|Transformadores de distribución de potencia|O|O||D||1
39121002|Transformadores de suministro de potencia|O|O||D||1
39121003|Transformadores de instrumentos|O|O||D||1
39121004|Unidades de suministro de energía|O|O||D||1|Fuente de poder
39121006|Adaptadores o inversores de potencia|O|O||D||1
39121007|Conversores de frecuencia|O|O||D||1
39121008|Conversores de señales|O|O||D||1
39121009|Reguladores eléctricos o de potencia|O|O||D||1
39121010|Bobinas magnéticas|O|O||D||1
39121011|Fuentes ininterrumpibles de potencia|O|O||D||1
39121012|Estrangulador|O|O||D||1
39121013|Convertidores rotativos eléctricos|O|O||D||1
39121014|Bancos de capacitores|O|O||D||1
39121015|Reactores|O|O||D||1
39121016|Anillos colectores|O|O||D||1
39121017|Unidades de distribución de alimentación (pdus)|O|O||D||1|Unidades de distribución de energía (PDU)
39121018|Barreras de seguridad intrínseca|O|O||D||1
39121019|Dispositivos de acoplamiento por inducción|O|O||D||1
39121020|Acondicionadores de señal|O|O||D||1
39121021|Unidades servo|O|O||D||1
39121022|Transformadores electrónicos|O|O||D||1
39121023|Compensadores var estática|O|O||D||1
39121024|Condensadores síncronos|O|O||D||1
39121025|Transformadores buck – boost|O|O||D||1
39121026|Transformadores de control de potencia|O|O||D||1
39121027|Transformador encapsulado|O|O||D||1
39121028|Transformador de mitigación armónica|O|O||D||1
39121029|Transformador de aislación|O|O||D||1
39121030|Transformador montado en pad|O|O||D||1
39121031|Strip de salida del suministro eléctrico|O|O||D||1
39121032|Transformador de corriente|O|O||D||1
39121033|Transformador potencial|O|O||D||1
39121034|Transformador de corriente de fase cero|O|O||D||1
39121035|Compensador de arranque de motor|O|O||D||1
39121036|Transformador de radio frecuencia rf|O|O||D||1
39121037|Transformador de limite|O|O||D||1
39121038|Yugo deflector|O|O||D||1|Yugo de desviación
39121039|Suministro de potencia de celda de combustible|O|O||D||1
39121040|Ahorrador de energía eléctrica|O|O||D||1
39121041|Transformador de voltaje constante|O|O||D||1
39121042|Transformador de filamento|O|O||D||1
39121043|Transformador rotativo|O|O||D||1
39121044|Transformador de audio frecuencia|O|O||D||1
39121045|Transformador de modulación|O|O||D||1
39121046|Transformador para igualar impedancia|O|O||D||1
39121047|Transformador de frecuencia intermedia|O|O||D||1
39121100|Centros de control y distribución y accesorios|O|O||D||1
39121101|Centros de carga|O|O||D||1
39121102|Tomas o centros de medidores|O|O||D||1
39121103|Paneles|O|O||D||1
39121104|Centros de control de motor|O|O||D||1
39121105|Sistemas de conmutadores|O|O||D||1
39121106|Sistemas de control o vigilancia de potencia|O|O||D||1
39121107|Sistemas de control de iluminación|O|O||D||1
39121108|Accesorios del panel de control o distribución|O|O||D||1
39121109|Transformadores de transmisión|O|O||D||1
39121110|Tablero de interruptor de circuito|O|O||D||1
39121111|Tablero de fusibles|O|O||D||1
39121112|Tablero de bajo voltaje de corriente alterna y directa ac dc|O|O||D||1
39121113|Centro de control de motor de bajo voltaje|O|O||D||1
39121114|Centro de control de motor de medio voltaje|O|O||D||1
39121115|Tablero de controles de medio voltaje|O|O||D||1
39121116|Tablero de bajo voltaje|O|O||D||1
39121117|Bus bar|O|O||D||1|Barra colectora
39121300|Cuadros, registros y menaje para electricidad|O|O||D||1
39121301|Cerramientos del panel de control o distribución|O|O||D||1
39121302|Placas o cubiertas de cerramiento|O|O||D||1
39121303|Cajas eléctricas|O|O||D||1
39121304|Cubiertas de cajas eléctricas|O|O||D||1
39121305|Cajas a prueba de intemperie|O|O||D||1
39121306|Cajas de conmutadores|O|O||D||1
39121307|Cajas de suelo|O|O||D||1
39121308|Cajas de toma de corriente|O|O||D||1
39121309|Cajas eléctricas especiales|O|O||D||1
39121310|Cajas de uso general|O|O||D||1
39121311|Accesorios eléctricos|O|O||D||1
39121312|Bujes eléctricos|O|O||D||1
39121313|Bridas de techo|O|O||D||1
39121314|Cerramiento a prueba de explosión|O|O||D||1
39121315|Caja de dispositivos|O|O||D||1
39121316|Caja de cielorraso|O|O||D||1
39121317|Platillo de cielorraso|O|O||D||1
39121318|Cerramiento del interruptor de circuito|O|O||D||1
39121319|Cerramiento de transformador de corriente|O|O||D||1
39121320|Extensión de caja eléctrica|O|O||D||1
39121321|Ferretería y accesorios de caja eléctrica|O|O||D||1
39121322|Partición de caja eléctrica|O|O||D||1
39121323|Cerramiento de consola eléctrica|O|O||D||1
39121324|Cerramiento eléctrico de propósito general|O|O||D||1
39121325|Cerramiento de unidad de interfaz de operador eléctrico|O|O||D||1
39121326|Cerramiento de botón eléctrico|O|O||D||1
39121327|Cerramiento de terminal eléctrico|O|O||D||1
39121328|Caja de perforación calificada de fuego|O|O||D||1
39121329|Gabinete de fusibles|O|O||D||1
39121330|Caja de distribución eléctrica|O|O||D||1
39121331|Caja de ubicación peligrosa|O|O||D||1
39121332|Caja de unión eléctrica|O|O||D||1
39121333|Caja de mampostería|O|O||D||1
39121334|Cerramiento eléctrico modular|O|O||D||1
39121335|Gabinete de terminaciones telefónicas|O|O||D||1
39121336|Cerramiento eléctrico subterráneo|O|O||D||1|Recinto eléctrico subterráneo
39121337|Compuesto de sellamiento eléctrico|O|O||D||1
39121400|Lengüetas de conexión, conectadores y terminales|O|O||D||1
39121402|Enchufes eléctricos|O|O||D||1
39121403|Enchufe de bloqueo|O|O||D||1|Bloqueo para enchufes
39121404|Manguitos eléctricos|O|O||D||1|Manguito de empalme
39121405|Terminales de cable o alambre|O|O||D||1|Terminal conector de empalme
39121406|Receptáculos eléctricos|O|O||D||1
39121407|Strips de conexiones|O|O||D||1
39121408|Conexiones mecánicas|O|O||D||1
39121409|Conectores de cables eléctricos|O|O||D||1
39121410|Bloques de terminales|O|O||D||1
39121412|Conectores de soporte posterior|O|O||D||1
39121413|Conectores circulares|O|O||D||1
39121414|Conectores coaxiales|O|O||D||1
39121415|Conectores planos|O|O||D||1
39121416|Tapas de conectores eléctricos|O|O||D||1
39121419|Conexiones flexibles|O|O||D||1
39121420|Conectores herméticos|O|O||D||1
39121421|Ensambles de conectores|O|O||D||1
39121423|Conectores de resorte|O|O||D||1
39121424|Tapas del bloque de terminales|O|O||D||1
39121425|Separador de tablero de terminales|O|O||D||1|PCB terminal
39121426|Puente de conexión|O|O||D||1
39121427|Bobinadoras de cable|O|O||D||1
39121428|Bobinadoras eléctricas|O|O||D||1
39121431|Conectores estancos de cables|O|O||D||1
39121432|Terminales eléctricos|O|O||D||1
39121433|Conectores de radiofrecuencia (rf)|O|O||D||1
39121434|Conectores de tubos metálicos eléctricos (emt)|O|O||D||1
39121435|Hilos o cables de conexión|O|O||D||1
39121436|Electrodos|O|O||D||1
39121437|Patines de toma de corriente|O|O||D||1
39121438|Conector automático de hilos o cables|O|O||D||1
39121440|Cable de extensión eléctrica|O|O||D||1|Extensión eléctrica
39121441|Cable de puente eléctrico|O|O||D||1|Cable pasa corriente
39121442|Ensamble de puerto eléctrico|O|O||D||1
39121443|Conector de bus subterráneo eléctrico|O|O||D||1|Conector de bus
39121444|Enchufe y módulo rj|O|O||D||1
39121445|Torsión en conector de cable|O|O||D||1
39121446|Equipo conector de terminal de cable|O|O||D||1|Conector para cable
39121447|Desconexión de terminal de cable|O|O||D||1|Terminal hembra de desconexión
39121448|Conector de cable o alambre de compresión|O|O||D||1|Conector de compresión de cable
39121449|Empalme de cable o alambre de compresión|O|O||D||1|Empalme de compresión de cables
39121450|Cabeza de martillo|O|O||D||1|Perno de cabeza de martillo
39121451|Conectores tap off|O|O||D||1|Acoplador direccional
39121452|Unión de cable|O|O||D||1|Articulación para cable
39121453|Unión de cangrejo|O|O||D||1|Conector de cangrejo
39121454|Terminal de batería|O|O||D||1
39121455|Conector de molde de inserción eléctrica|O|O||D||1
39121456|Conector de subestación|O|O||D||1
39121457|Conector exotérmico|O|O||D||1|Soldadura exotérmica
39121458|Reductor de compresión de cable o alambre|O|O||D||1|Terminal compresión para cable
39121459|Placa de circuito impreso pcb con prensa conector de cabecera|O|O||D||1
39121460|Conector con filtro de cabecera|O|O||D||1
39121461|Sello de conector y cable|O|O||D||1|Conector de la glándula
39121462|Conector de telecomunicaciones|O|O||D||1
39121463|Conector para enchufe|O|O||D||1
39121464|Codo de tubo metálico eléctrico emt|O|O||D||1
39121465|Trenza flexible|O|O||D||1
39121466|Terminal y tapa de conexión mecánica|O|O||D||1
39121467|Enchufe y tapa de conexión mecánica|O|O||D||1
39121500|Conmutadores, controles y relés y accesorios|O|O||D||1
39121521|Controles de motor de arranque|O|O||D||1
39121522|Contactos eléctricos|O|O||D||1
39121523|Temporizadores|O|O||D||1
39121524|Fotocontroles|O|O||D||1
39121527|Codificadores|O|O||D||1
39121528|Sensores fotoeléctricos|O|O||D||1
39121529|Contactores|O|O||D||1|Contactores electromagnéticos
39121534|Luces indicadoras o indicadores luminosos|O|O||D||1
39121544|Piezas de luces indicadoras o accesorios|O|O||D||1
39121545|Paradas de emergencia|O|O||D||1|Botón paro de emergencia
39121551|Piezas de reflector|O|O||D||1
39121552|Módulos de control eléctrico|O|O||D||1
39121555|Control de contador|O|O||D||1
39121561|Estación colgante de control|O|O||D||1
39121565|Estación de control de montaje de superficie|O|O||D||1
39121568|Reactor de derivación|O|O||D||1
39121569|Reacción en serie|O|O||D||1|Reactores en serie
39121570|Re - cerrador|O|O||D||1|Interruptor, Reconectador
39121600|Dispositivos y accesorios para la protección de circuitos|O|O||D||1
39121601|Breakers de circuito|O|O||D||1
39121602|Breakers de circuito magnético|O|O||D||1
39121603|Micro disyuntores|O|O||D||1
39121604|Fusibles de retardo|O|O||D||1
39121605|Fusibles de tapón|O|O||D||1
39121606|Fusibles de cartucho|O|O||D||1
39121607|Fusibles de cuerpo de vidrio|O|O||D||1
39121609|Microfusibles|O|O||D||1
39121610|Supresor de ondas|O|O||D||1
39121611|Fusibles de cerámicas|O|O||D||1
39121612|Fusibles de cuchilla|O|O||D||1
39121613|Conjuntos o dispositivos de polo a tierra|O|O||D||1
39121614|Disyuntores de pérdida a tierra|O|O||D||1
39121615|Breakers de circuito de aire|O|O||D||1
39121616|Breakers de circuito de caja moldeada|O|O||D||1
39121617|Piezas de fusible o accesorios|O|O||D||1
39121618|Alambre para fusible|O|O||D||1
39121619|Fusibles tipo botella|O|O||D||1
39121620|Materiales transientes de protección|O|O||D||1
39121621|Accesorios y aparatos de protección contra rayos|O|O||D||1
39121622|Fusible automotriz|O|O||D||1
39121623|Fusible electrónico|O|O||D||1
39121624|Soporte de fusible|O|O||D||1
39121625|Fusible de alta velocidad|O|O||D||1
39121626|Fusible de medio voltaje|O|O||D||1
39121627|Fusible de potencia|O|O||D||1
39121628|Fusible semiconductor|O|O||D||1
39121629|Bloque de fusibles|O|O||D||1
39121630|Clip de fusible|O|O||D||1
39121631|Interruptor de circuito de alto voltaje lleno de aceite|O|O||D||1
39121632|Protector de redes|O|O||D||1
39121633|Interruptor de circuito|O|O||D||1
39121634|Protector de sobretensiones|O|O||D||1
39121635|Regulador de voltaje|O|O||D||1
39121636|Limitador de corriente|O|O||D||1
39121637|Supresor de arco|O|O||D||1
39121638|Corte de fusible|O|O||D||1
39121639|Interruptor de vacío|O|O||D||1
39121640|Breaker de circuito eléctrico|O|O||D||1
39121641|Fusible de gancho|O|O||D||1
39121642|Fusible de tornillo|O|O||D||1
39121643|Panel protector de sobrecorriente|O|O||D||1
39121644|Breaker de circuito de alta velocidad|O|O||D||1
39121645|Breaker de circuito de aceite|O|O||D||1
39121646|Breaker de circuito de gas|O|O||D||1
39121647|Descargador electrostático|O|O||D||1
39121648|Aditivo de tierra|O|O||D||1
39121700|Ferretería eléctrica y suministros|O|O||D||1
39121701|Soportes eléctricos|O|O||D||1
39121702|Clips para cables|O|O||D||1
39121703|Enlaces de cables|O|O||D||1
39121704|Placas de pared|O|O||D||1
39121705|Grapas para cables|O|O||D||1
39121706|Bujes de transformadores|O|O||D||1
39121707|Clavos de tabla de arneses|O|O||D||1
39121708|Riel din|O|O||D||1
39121709|Atadura de mango|O|O||D||1
39121710|Receptáculo multiplicador eléctrico|O|O||D||1
39121717|Montaje de fijador de cable|O|O||D||1
39121718|Kits de empalme de cables|O|O||D||1
39121719|Protectores|O|O||D||1
39121720|Asas de transformadores|O|O||D||1
39121721|Aislantes eléctricos|O|O||D||1
39121722|Dispositivo para sacar alambres y cables|O|O||D||1
39121723|Tubo encogible al calor|O|O||D||1
39121724|Artículos para montaje de conector|O|O||D||1
39121725|Mango de cable eléctrico|O|O||D||1
39121726|Atador de cables eléctricos|O|O||D||1
39121727|Varilla aislante eléctrica|O|O||D||1
39121728|Tubo de aislamiento|O|O||D||1
39121729|Juego de cables eléctricos|O|O||D||1
39121730|Roseta eléctrica|O|O||D||1
39121731|Equipo para atar cables|O|O||D||1
39121800|Instalaciones de Edificios Inteligentes - IBI|O|O||D||1
39121801|Unidades o dispositivos de control|O|O||D||1
39121802|Unidades o dispositivos inactivos|O|O||D||1
39121803|Sistema de control de construcción ambiental|O|O||D||1
39121900|Dispositivos y accesorios de seguridad eléctrica|O|O||D||1
39121901|Bloqueo de breaker de circuito|O|O||D||1
39121902|Cerramiento de bloqueo|O|O||D||1
39121903|Bloqueo de pasador y candado|O|O||D||1
39121904|Kit y estación de bloqueo|O|O||D||1
39121905|Dispositivo de bloqueo múltiple|O|O||D||1
39121906|Bloqueo de enchufe y cable|O|O||D||1
39121907|Bloqueo de receptáculo|O|O||D||1
39121908|Bloqueo de interruptor|O|O||D||1
39121909|Bloqueo de válvula|O|O||D||1
39121910|Marcador de voltaje|O|O||D||1
39122000|Unidades eléctricas de velocidades variables|O|O||D||1
39122001|Unidad ac invertida|O|O||D||1|Inversor accionamiento AC
39122002|Unidad dc de control de motor|O|O||D||1
39122003|Unidad de servo control|O|O||D||1
39122100|Equipo de transmisión y distribución eléctrica|O|O||D||1
39122101|Potheads de cable para subestaciones|O|O||D||1
39122102|Cambiador de tomas|O|O||D||1
39122103|Poste de utilidad|O|O||D||1
39122104|Cable galvanizado de refuerzo|O|O||D||1
39122105|Espaciador eléctrico|O|O||D||1
39122106|Abrazadera para cruceta|O|O||D||1
39122107|Bloque de madera de cableado|O|O||D||1
39122108|Varilla de anclaje para cable galvanizado de refuerzo|O|O||D||1
39122109|Cruceta de acero tipo cuadrado|O|O||D||1
39122110|Arandela de conexión para línea eléctrica aérea|O|O||D||1
39122111|Dispositivo para dividir la línea eléctrica del carro|O|O||D||1
39122112|Ojo del juego de aislamiento|O|O||D||1
39122113|Cruceta del poste de utilidad|O|O||D||1
39122114|Toma de vía de bus eléctrico o toma de bus|O|O||D||1
39122115|Varilla de armadura eléctrica|O|O||D||1
39122116|Ajuste de vínculo de línea aérea|O|O||D||1
39122117|Tensión yugo de polo de suspensión|O|O||D||1
39122118|Conector de bloque de cable eléctrico|O|O||D||1
39122119|Torre de acero de transmisión eléctrica|O|O||D||1
39122120|Banda de polo de utilidad|O|O||D||1
39122200|Interruptores eléctricos y accesorios|O|O||D||1
39122201|Interruptor de código|O|O||D||1
39122202|Interruptor de cuchilla|O|O||D||1|Switch de cuchillas
39122203|Interruptor sensible|O|O||D||1
39122204|Interruptor de vueltas|O|O||D||1
39122205|Interruptores de seguridad|O|O||D||1|Switch de seguridad
39122206|Reductores o dimers|O|O||D||1
39122207|Interruptores de tambor|O|O||D||1
39122208|Interruptores de tiempos|O|O||D||1
39122209|Interruptores de resorte|O|O||D||1
39122210|Interruptores automáticos por caída de presión|O|O||D||1
39122211|Interruptores de volquete|O|O||D||1
39122212|Conmutadores de botón deslizante|O|O||D||1
39122213|Interruptores de límite|O|O||D||1
39122214|Interruptores de controlador|O|O||D||1
39122215|Interruptores variables|O|O||D||1
39122216|Interruptores de botón|O|O||D||1
39122217|Interruptores giratorios|O|O||D||1
39122218|Interruptor no fusible|O|O||D||1|Switch no fusible
39122219|Interruptor nivel o flotador|O|O||D||1
39122220|Interruptor de radio frecuencia rf|O|O||D||1
39122221|Parte o accesorio de interruptor|O|O||D||1|Partes y accesorios de switch
39122222|Interruptor de pie|O|O||D||1
39122223|Interruptor de flujo|O|O||D||1
39122224|Interruptor de cerradura|O|O||D||1
39122225|Interruptor de mercurio|O|O||D||1
39122226|Interruptor rocker|O|O||D||1
39122227|Interruptor o control joystick|O|O||D||1
39122228|Interruptor de vacío|O|O||D||1
39122229|Interruptor de temperatura|O|O||D||1
39122230|Interruptor de proximidad|O|O||D||1
39122231|Interruptor dispositivo de combinación|O|O||D||1
39122232|Interruptor de combinación|O|O||D||1
39122233|Interruptor de desconexión|O|O||D||1
39122234|Interruptor de bloqueo|O|O||D||1
39122235|Interruptor de sistema de cableado modular|O|O||D||1
39122236|Interruptor de sensor de ocupación o movimiento|O|O||D||1
39122237|Interruptor de montura de panel|O|O||D||1
39122238|Interruptor de fotocelda|O|O||D||1
39122239|Interruptor de halar|O|O||D||1
39122240|Interruptor de velocidad|O|O||D||1
39122241|Interruptor de lengüeta|O|O||D||1
39122242|Interruptor de suelo|O|O||D||1
39122243|Micro – interruptor|O|O||D||1
39122244|Interruptor de corte|O|O||D||1
39122245|Interruptor magnético|O|O||D||1
39122246|Interruptor de potenciómetro eléctrico|O|O||D||1
39122247|Interruptor de potenciómetro automotriz hvac|O|O||D||1
39122248|Interruptor de distribuidor de señal de potencia|O|O||D||1
39122249|Interruptor de control de timón|O|O||D||1
39122250|Interruptor selector de cambio de transmisión automática|O|O||D||1
39122251|Interruptor detent|O|O||D||1
39122300|Relés eléctricos y accesorios|O|O||D||1|Relevadores eléctricos y accesorios
39122301|Relé buchholtz|O|O||D||1|Relevador buchholz
39122302|Relé de distancia|O|O||D||1|Relevador de distancia
39122303|Relé multicontacto|O|O||D||1|Relevador multicontacto
39122304|Relé de lengüeta|O|O||D||1|Relevador de lengüeta
39122305|Relé de medidor|O|O||D||1|Relevador de medidor
39122306|Relé de tierra direccional|O|O||D||1|Relevador de tierra direccional
39122307|Relé auxiliar|O|O||D||1|Relevador auxiliar
39122308|Relé de índice diferencial|O|O||D||1|Relevador de índice diferencial
39122309|Relé subterráneo|O|O||D||1|Relevador subterráneo
39122310|Relé selector de tierra|O|O||D||1|Relevador selector de tierra
39122311|Relé de presión|O|O||D||1|Relevador de presión
39122312|Relé de polaridad|O|O||D||1|Relevador de polaridad
39122313|Relé trip free|O|O||D||1|Relevador sin disparo
39122314|Relé de bloqueo|O|O||D||1|Relevador de bloqueo
39122315|Relé electromagnético|O|O||D||1|Relevador electromagnético
39122316|Relé de re – cerrado|O|O||D||1|Relevador de reconexión
39122317|Relé de aseguramiento|O|O||D||1|Relevador de aseguramiento
39122318|Relé de frecuencia|O|O||D||1|Relevador de frecuencia
39122319|Relé de corriente directa|O|O||D||1|Relevador de corriente directa
39122320|Relé horizontal|O|O||D||1|Relevador horizontal
39122321|Relé no polarizado|O|O||D||1|Relevador no polarizado
39122322|Relé de voltaje de corriente directa|O|O||D||1|Relevador de voltaje de corriente directa
39122323|Relé digital multi – función|O|O||D||1|Relevador digital multifunción
39122324|Relés de potencia|O|O||D||1|Relevadores de potencia
39122325|Relés universales|O|O||D||1|Relevadores universales
39122326|Relés de clavija bipolar|O|O||D||1|Relevadores de clavija bipolar
39122327|Relés de voltaje alterno|O|O||D||1|Relevadores de voltaje alterno
39122328|Relés de mercurio|O|O||D||1|Relevadores de mercurio
39122329|Relés de acción diferida|O|O||D||1|Relevadores de acción diferida
39122330|Relés de sobrecarga|O|O||D||1|Relevadores de sobrecarga
39122331|Relés de control|O|O||D||1|Relevadores de control
39122332|Relés de interrupción de fase|O|O||D||1|Relevadores de interrupción de fase
39122333|Relés de estado sólido|O|O||D||1|Relevadores de estado sólido
39122334|Módulo de relés múltiples o de placa de relés|O|O||D||1
39122335|Base o toma de relé|O|O||D||1
39122336|Relé intermitente de luz direccional|O|O||D||1
39122337|Relé de tablero de circuito impreso|O|O||D||1
39131500|Marcadores de alambre y dispositivos para marcar alambre|O|O||D||1
39131501|Marcador de cable de pinza|O|O||D||1
39131502|Marcador de cable de encogimiento por calor|O|O||D||1
39131503|Marcador de cable de deslizar|O|O||D||1
39131504|Marcador de cable de identificación|O|O||D||1
39131505|Herramienta e impresora para rotular cable|O|O||D||1
39131506|Libro de marcador de cable|O|O||D||1
39131507|Tarjeta de arcador de cable|O|O||D||1|Marcador para cable y alambre
39131508|Rollo y dispensador de arcador de cable|O|O||D||1|Rollo y dispensador de marcador de cable
39131509|Marcador de cable de escribir|O|O||D||1
39131600|Dispositivos de protección de alambre|O|O||D||1
39131601|Tubo corrugado para cableado interno|O|O||D||1
39131602|Manga trenzada expandible|O|O||D||1
39131603|Perfil pasacable|O|O||D||1|Borde del ojal de caucho
39131604|Empaque de espiral|O|O||D||1
39131605|Piso de cables track or guard|O|O||D||1
39131606|Placa de clavos para protección de cable|O|O||D||1
39131607|Cordón para amarrar cables|O|O||D||1
39131608|Sistema de sellamiento de ductos|O|O||D||1
39131700|Conductos eléctricos, electroductos y cables aéreos|O|O||D||1
39131701|Electroducto|O|O||D||1
39131702|Dispositivos y accesorios de electroducto|O|O||D||1
39131703|Escalerilla de cables|O|O||D||1
39131704|Bandeja de cables|O|O||D||1
39131705|Dispositivos y accesorios de bandeja de cable|O|O||D||1
39131706|Conducto eléctrico|O|O||D||1
39131707|Acoples de conducto eléctrico|O|O||D||1
39131708|Cuerpo de ajuste de conducto eléctrico|O|O||D||1
39131709|Cableado eléctrico o conductos de cables|O|O||D||1
39131710|Cables aéreos|O|O||D||1
39131711|Dispositivos y accesorios de cableado eléctrico|O|O||D||1
39131712|Ducto de cableado|O|O||D||1
39131713|Dispositivos y accesorios de ducto de cableado|O|O||D||1
39131714|Canaletas para cables|O|O||D||1
39131715|Conducto subterráneo de manguera|O|O||D||1
39131716|Manipulador de cable|O|O||D||1
39131717|Codo de conducto eléctrico|O|O||D||1
39131718|Boquilla de conducto eléctrico|O|O||D||1
39131719|Tubería metálica eléctrica emt|O|O||D||1
39131720|Tubería metálica eléctrica emt roscada|O|O||D||1
40101500|Ventilación|O|O||D||1
40101501|Colectores de aire|O|O||D||1
40101502|Extractores de aire|O|O||D||1
40101503|Rejilla de ventilación|O|O||D||1
40101504|Compuertas de ventilación|O|O||D||1
40101505|Difusores de aire|O|O||D||1
40101506|Tubos de ventilación|O|O||D||1
40101507|Tubería de ventilación en espiral|O|O||D||1
40101508|Cortina de ventilación|O|O||D||1
40101509|Clavos para sistemas de ventilación|O|O||D||1
40101510|Tubería de ventilación|O|O||D||1
40101511|Colgador para tubos de ventilación|O|O||D||1
40101512|Dispositivos para tubos de ventilación|O|O||D||1
40101600|Circulación del aire y piezas y accesorios|O|O||D||1
40101601|Secadores|O|O||D||1
40101602|Circuladores de aire|O|O||D||1
40101603|Impulsores|O|O||D||1
40101604|Ventiladores|O|O||D||1
40101605|Protectores o sus accesorios para ventiladores|O|O||D||1
40101606|Dispositivos de seguridad para ventiladores|O|O||D||1
40101607|Válvula de control de volumen de aire|O|O||D||1
40101608|Unidad de filtrado para ventiladores|O|O||D||1
40101609|Ventiladores de techo|O|O||D||1
40101610|Kit de ventiladores de techo|O|O||D||1
40101700|Enfriamiento|O|O||D||1
40101701|Aires acondicionados|O|O||D||1|Aire acondicionado
40101702|Intercambiadores de enfriado|O|O||D||1
40101703|Enfriadores de evaporación|O|O||D||1
40101704|Unidades de condensación|O|O||D||1
40101705|Ensamblajes de tubos capilares|O|O||D||1
40101706|Obturadores de aire acondicionado|O|O||D||1
40101707|Accesorios para torres de enfriamiento|O|O||D||1
40101708|Unidad de ventilador de bobina|O|O||D||1
40101709|Unidad de manejo de aire|O|O||D||1
40101710|Enfriador de reciprocidad|O|O||D||1
40101711|Enfriador de líquido centrífugo|O|O||D||1
40101712|Enfriador de tornillo|O|O||D||1
40101713|Enfriador de absorción|O|O||D||1
40101714|Enfriador calentador de absorción|O|O||D||1
40101715|Cámara de temperatura y humedad constantes|O|O||D||1
40101716|Torre enfriadora|O|O||D||1
40101717|Ahorrador de energía para aire acondicionado|O|O||D||1
40101718|Bobina enfriadora|O|O||D||1
40101719|Receptor de líquido refrigerante|O|O||D||1
40101720|Unidad de enfriamiento|O|O||D||1
40101721|Condensador de agua enfriada|O|O||D||1
40101722|Condensador de vapor|O|O||D||1
40101800|Equipo de calefacción y piezas y accesorios|O|O||D||1
40101801|Radiadores|O|O||D||1
40101802|Intercambiadores de calor|O|O||D||1
40101805|Calefacción|O|O||D||1
40101806|Bombas de calor|O|O||D||1
40101807|Unidades de calefacción solar|O|O||D||1
40101808|Estufas de calefacción|O|O||D||1
40101809|Calentadores de circulación|O|O||D||1
40101810|Calentadores de conductos de bobina|O|O||D||1
40101811|Calentadores de convección|O|O||D||1
40101812|Intercambiadores divididos|O|O||D||1
40101813|Intercambiadores de doble división|O|O||D||1
40101814|Calentadores de aletas tubulares|O|O||D||1
40101815|Calentadores de inmersión|O|O||D||1
40101816|Intercambiadores de teteras|O|O||D||1
40101817|Intercambiadores de una vía|O|O||D||1
40101818|Calentadores de procesamiento de aire|O|O||D||1
40101819|Calentadores de espacio|O|O||D||1
40101820|Intercambiadores divididos|O|O||D||1
40101821|Calentadores de banda|O|O||D||1
40101822|Calentadores tubulares|O|O||D||1
40101823|Intercambiadores de dos vías|O|O||D||1
40101824|Calentador de cuarzo|O|O||D||1
40101825|Calentadores de agua para uso doméstico|O|O||D||1
40101826|Calentadores de agua comerciales|O|O||D||1
40101827|Calentadores de fibra cerámica|O|O||D||1
40101828|Calentadores de cartucho|O|O||D||1
40101829|Calentadores de tiro|O|O||D||1
40101830|Elementos de calefacción|O|O||D||1
40101831|Calentadores de inducción|O|O||D||1
40101832|Puertas para equipos de calefacción|O|O||D||1
40101833|Encendedor para calderas o calentadores|O|O||D||1
40101834|Quemadores (fogones)|O|O||D||1
40101835|Plato intercambiador de calor|O|O||D||1
40101836|Intercambiador de calor de concha y de tubo|O|O||D||1
40101837|Chimenea|O|O||D||1
40101838|Economizador|O|O||D||1
40101839|Placas difusoras|O|O||D||1
40101840|Calentador de película|O|O||D||1
40101841|Pre calentador de aire|O|O||D||1
40101842|Dispositivo para derretir hielo|O|O||D||1
40101843|Horno eléctrico|O|O||D||1
40101844|Horno de alta frecuencia de inducción al vacío|O|O||D||1
40101845|Horno de reverberación|O|O||D||1
40101846|Horno de baño de sal|O|O||D||1|Horno de tratamiento térmico
40101847|Horno eléctrico de carbonización y nitrificación|O|O||D||1
40101848|Sistema de calefacción de aire forzado|O|O||D||1
40101849|Cabezal de distribución de agua caliente|O|O||D||1
40101850|Horno crematorio|O|O||D||1
40101900|Control de humedad|O|O||D||1
40101901|Vaporizadores|O|O||D||1
40101902|Deshumidificadores|O|O||D||1
40101903|Humidificadores|O|O||D||1
40102000|Calderas|O|O||D||1
40102001|Quemadores de tubo radiante|O|O||D||1
40102002|Quemadores de tubo de agua|O|O||D||1
40102003|Quemadores eléctricos|O|O||D||1
40102004|Quemadores operados con gas natural|O|O||D||1
40102005|Quemadores operados con gas propano|O|O||D||1
40102006|Quemadores operados con calor sobrante|O|O||D||1
40102007|Mini quemadores de aceite|O|O||D||1
40102100|Chimeneas y accesorios|O|O||D||1
40102101|Chimeneas operadas con leña|O|O||D||1
40102102|Chimenea a gas de ventilador b|O|O||D||1
40102103|Chimenea a gas de ventilador directo|O|O||D||1
40102104|Chimenea a gas de ventilador libre|O|O||D||1
40102105|Chimenea eléctrica|O|O||D||1
40102106|Fachadas de chimeneas|O|O||D||1
40102107|Repisas para chimeneas|O|O||D||1
40141600|Válvulas|O|O||D||1
40141602|Válvulas de aguja|O|O||D||1
40141603|Válvulas neumáticas|O|O||D||1
40141604|Válvulas de seguridad|O|O||D||1
40141605|Válvulas solenoides|O|O||D||1
40141606|Válvulas de relevo|O|O||D||1
40141607|Válvulas de bola|O|O||D||1
40141608|Válvulas hidráulicas|O|O||D||1
40141609|Válvulas de control|O|O||D||1
40141610|Válvulas de flotación|O|O||D||1
40141611|Válvulas de globo|O|O||D||1
40141612|Válvulas de expansión|O|O||D||1
40141613|Válvulas de compuerta|O|O||D||1
40141615|Válvulas de lengüeta|O|O||D||1
40141616|Partes o accesorios para válvulas|O|O||D||1
40141617|Válvulas esféricas de ángulo|O|O||D||1
40141618|Válvulas de seguridad de bola|O|O||D||1
40141619|Válvulas de mariposa con diseño de casquillo|O|O||D||1
40141620|Válvulas de mariposa con diseño de disco|O|O||D||1
40141621|Válvulas de diafragma|O|O||D||1
40141622|Válvulas de seguridad en línea|O|O||D||1
40141623|Válvulas tipo compuerta|O|O||D||1
40141624|Válvulas con pistones lubricados|O|O||D||1
40141625|Válvulas purgadoras de sedimentos (barro o lodo)|O|O||D||1
40141626|Válvulas con pistón no lubricado|O|O||D||1
40141627|Válvulas de orificio|O|O||D||1
40141628|Válvulas piloto|O|O||D||1
40141629|Válvulas de pinzamiento|O|O||D||1
40141630|Válvulas de seguridad de pistón|O|O||D||1
40141631|Válvulas de bombeo|O|O||D||1
40141632|Válvulas de monitoreo|O|O||D||1
40141633|Válvulas deslizantes|O|O||D||1
40141634|Válvulas de control de rotación|O|O||D||1
40141635|Válvulas de turbina|O|O||D||1
40141636|Kits de válvulas|O|O||D||1
40141637|Válvulas de control de disco|O|O||D||1
40141638|Válvulas alternadoras|O|O||D||1
40141639|Válvulas de llenado del inodoro|O|O||D||1
40141640|Válvulas de inodoro|O|O||D||1
40141641|Válvulas solenoides|O|O||D||1
40141642|Válvulas de asiento (o auxiliares)|O|O||D||1
40141643|Válvulas de contención|O|O||D||1
40141644|Válvulas de esclusa rotativas|O|O||D||1
40141645|Vástagos de válvulas|O|O||D||1
40141646|Soportes (asientos) de válvulas|O|O||D||1
40141647|Válvulas de segmento|O|O||D||1
40141648|Válvulas magnéticas|O|O||D||1
40141649|Ensamblaje de bobina de válvula de control direccional|O|O||D||1
40141650|Válvula de gas comprimido|O|O||D||1
40141651|Válvula de aire|O|O||D||1
40141652|Válvula reductora de presión|O|O||D||1
40141653|Válvula de compuerta|O|O||D||1
40141654|Válvula de regulación|O|O||D||1
40141655|Válvula de vacío|O|O||D||1
40141656|Válvula de brida tipo mariposa|O|O||D||1
40141657|Válvula de control de rociadores|O|O||D||1
40141658|Válvula de bloqueo y sangrado|O|O||D||1
40141659|Válvula horizontal de elevación|O|O||D||1
40141700|Material de ferretería y accesorios|O|O||D||1
40141719|Adaptadores para plomería|O|O||D||1
40141720|Conectores para plomería|O|O||D||1
40141725|Ganchos (soportes) para plomería|O|O||D||1
40141726|Hidrantes|O|O||D||1
40141727|Plomería de ventilación|O|O||D||1
40141731|Boquillas|O|O||D||1
40141732|Centradores (arañas) para plomería|O|O||D||1
40141734|Conectores para mangueras|O|O||D||1|Adaptadores de manguera
40141735|Embudos|O|O||D||1
40141736|Graseras (de lubricación)|O|O||D||1
40141737|Diafragmas|O|O||D||1
40141738|Tapones de drenaje (de aceite)|O|O||D||1
40141739|Tapas de desagüe|O|O||D||1
40141740|Llave de la gasolina|O|O||D||1
40141741|Orificios de ajuste|O|O||D||1
40141742|Atomizadores|O|O||D||1
40141743|Puntas o capas de boquillas|O|O||D||1
40141744|Cuencos de drenaje|O|O||D||1
40141745|Fusibles de alta temperatura|O|O||D||1
40141746|Mirillas (indicadores de nivel)|O|O||D||1
40141747|Trampa de grasas|O|O||D||1
40141749|Interruptor de vacío|O|O||D||1
40141750|Brazo (de tubería)|O|O||D||1
40141751|Codos (de tubería)|O|O||D||1
40141755|Resorte para evitar movimiento de tubería|O|O||D||1
40141756|Caja de accesorios para conectar tubos|O|O||D||1
40141757|Escudetes|O|O||D||1|Ojo de cerradura
40141758|Canal de drenaje|O|O||D||1
40141759|Desagües de piso|O|O||D||1|Drenaje de piso
40141760|Hidrante anti congelamiento|O|O||D||1
40141761|Múltiple (colector) de tubería|O|O||D||1
40141762|Dispositivo protector del medidor de agua|O|O||D||1
40141763|Supresor de golpes de ariete|O|O||D||1
40141764|Ensamblaje de mangueras|O|O||D||1
40141765|Separador de drenaje|O|O||D||1
40141766|Regulador de cierre con asiento para trabajos de agua|O|O||D||1
40141767|Zapatas para tubería|O|O||D||1
40141768|Adaptador desmontable|O|O||D||1
40141769|Caja o cámara de válvulas|O|O||D||1
40141770|Máquina de fusión de tubos|O|O||D||1
40141900|Conductos|O|O||D||1
40141901|Conductos flexibles|O|O||D||1
40141902|Conductos rígidos|O|O||D||1
40141903|Conductos o red de conductos de manganeso|O|O||D||1
40141904|Conductos o red de conductos de aleación ferrosa|O|O||D||1
40141905|Conductos o red de conductos de titanio|O|O||D||1
40141906|Conductos o red de conductos de latón|O|O||D||1
40141907|Conductos o red de conductos de latón|O|O||D||1
40141908|Conductos o red de conductos de plomo|O|O||D||1
40141909|Conductos o red de conductos de bronce|O|O||D||1
40141910|Conductos o red de conductos de zinc|O|O||D||1
40141911|Conductos o red de conductos de acero|O|O||D||1
40141912|Conductos o red de conductos de hierro|O|O||D||1
40141913|Conductos o red de conductos de cemento|O|O||D||1
40141914|Conductos o red de conductos de plástico|O|O||D||1
40141915|Conductos o red de conductos de caucho|O|O||D||1
40141916|Conductos o red de conductos de vidrio|O|O||D||1
40141917|Conductos o red de conductos de piedra|O|O||D||1
40141918|Conductos o red de conductos de aleación no ferrosa|O|O||D||1
40141919|Conductos o red de conductos de aluminio|O|O||D||1
40141920|Conductos o red de conductos de acero inoxidable|O|O||D||1
40141921|Conductos o red de conductos de metales preciosos|O|O||D||1
40141922|Conductos o red de conductos de cobre|O|O||D||1
40141923|Conductos o red de conductos de látex|O|O||D||1
40141924|Conductos o red de conductos de nylon|O|O||D||1
40142000|Mangueras|O|O||D||1
40142001|Mangueras de ácido|O|O||D||1
40142002|Mangueras de aire|O|O||D||1
40142003|Mangueras de perforación|O|O||D||1
40142004|Mangueras marítimas|O|O||D||1
40142005|Mangueras para manipular material|O|O||D||1
40142006|Mangueras de aceite|O|O||D||1
40142007|Mangueras especiales|O|O||D||1
40142008|Mangueras de agua|O|O||D||1
40142009|Mangueras multipropósito de aire, agua y gas|O|O||D||1
40142010|Mangueras recubiertas de fluoropolímero|O|O||D||1
40142011|Manguera química|O|O||D||1
40142012|Manguera para alimentos y bebidas|O|O||D||1
40142013|Mangueras para minería|O|O||D||1
40142014|Mangueras de petróleo|O|O||D||1
40142015|Mangueras para limpieza al vapor|O|O||D||1
40142016|Mangueras al vacío|O|O||D||1
40142017|Mangueras de soldadura|O|O||D||1
40142018|Mangueras para rociar|O|O||D||1
40142019|Mangueras de conductos|O|O||D||1
40142020|Mangueras hidráulicas|O|O||D||1
40142021|Mangueras de polvo de piedra|O|O||D||1
40142022|Rollos de mangueras|O|O||D||1
40142200|Reguladores de gas y fluido|O|O||D||1
40142201|Reguladores de gas|O|O||D||1
40142202|Reguladores de fluido|O|O||D||1
40142203|Kits de reparación de reguladores de fluido|O|O||D||1
40142204|Regulador de oxígeno para soldadura|O|O||D||1
40142205|Regulador de acetileno para soldadura|O|O||D||1
40142206|Compuerta de regulación de flujo|O|O||D||1
40142207|Regulador del nivel del agua|O|O||D||1
40142208|Mezclador de gas|O|O||D||1
40142500|Interceptores y coladores|O|O||D||1
40142501|Filtros (coladores) de líquido|O|O||D||1
40142502|Trampas de líquido|O|O||D||1
40142503|Trampas de vapor|O|O||D||1
40142504|Filtros (coladores) de vapor|O|O||D||1
40142505|Filtros (coladores) en y|O|O||D||1
40142506|Filtros (coladores) en t|O|O||D||1
40142507|Filtros (coladores) cónicos|O|O||D||1
40142508|Filtros (coladores) de canasta|O|O||D||1
40142509|Trampa de aceite|O|O||D||1
40142510|Trampa de vapor termostática|O|O||D||1
40142511|Trampa de vapor termodinámica|O|O||D||1
40142512|Respiradero|O|O||D||1
40142513|Trampa p|O|O||D||1
40142514|Trampa j|O|O||D||1
40142515|Trampa s|O|O||D||1
40151500|Bombas|O|O||D||1
40151501|Bombas de aire|O|O||D||1
40151502|Bombas de vacío|O|O||D||1
40151503|Bombas centrífugas|O|O||D||1
40151504|Bombas de circulación|O|O||D||1
40151505|Bombas dosificadoras|O|O||D||1
40151506|Bombas de mano|O|O||D||1
40151507|Bombas de irrigación|O|O||D||1
40151508|Bombas de barro|O|O||D||1
40151509|Bombas recíprocas|O|O||D||1
40151510|Bombas de agua|O|O||D||1
40151511|Bombas para pozos|O|O||D||1
40151512|Bombas para sumideros|O|O||D||1
40151513|Bombas sumergibles|O|O||D||1
40151514|Bombas de vapor|O|O||D||1
40151515|Bombas solenoides|O|O||D||1
40151516|Bombas de corte|O|O||D||1
40151517|Bombas de alcantarillado|O|O||D||1
40151518|Bombas no selladas|O|O||D||1
40151519|Bombas sanitarias|O|O||D||1
40151520|Bombas de muestreo|O|O||D||1
40151521|Bombas giratorias|O|O||D||1
40151522|Bombas de osmosis inversa|O|O||D||1
40151523|Bombas de desplazamiento positivo|O|O||D||1
40151524|Bombas de aceite|O|O||D||1
40151525|Bombas de lodo|O|O||D||1
40151526|Bombas de turbina|O|O||D||1
40151527|Bombas de émbolo|O|O||D||1
40151528|Bombas oscilantes|O|O||D||1
40151529|Bombas de tambor|O|O||D||1
40151530|Bombas de dragado|O|O||D||1
40151531|Bombas para remover agua|O|O||D||1
40151532|Bombas de combustible|O|O||D||1
40151533|Bombas hidráulicas|O|O||D||1
40151534|Bombas criogénicas|O|O||D||1
40151546|Bombas de partición axial|O|O||D||1
40151547|Bombas de pozo profundo|O|O||D||1
40151548|Bombas de diafragma|O|O||D||1
40151549|Bombas de doble diafragma|O|O||D||1
40151550|Bombas dúplex|O|O||D||1
40151551|Bombas de engranaje|O|O||D||1
40151552|Bombas de metraje o inyección o proporcionales|O|O||D||1
40151553|Bombas de cavidad progresiva|O|O||D||1
40151554|Bombas de pistón|O|O||D||1
40151555|Bombas de resalte rotatorias|O|O||D||1
40151556|Bombas de leva rotatorias|O|O||D||1
40151557|Bombas de pistón rotatorias|O|O||D||1
40151558|Bombas de tuerca|O|O||D||1
40151559|Bombas simplex|O|O||D||1
40151560|Bombas de paleta deslizante|O|O||D||1
40151561|Bombas triplex|O|O||D||1
40151562|Bombas de tornillo|O|O||D||1
40151563|Sets de bombas contra incendio|O|O||D||1
40151564|Bombas químicas|O|O||D||1
40151565|Bombas de macerar|O|O||D||1
40151566|Bomba elevadora de presión|O|O||D||1
40151567|Bomba de alta temperatura|O|O||D||1
40151568|Bomba de pulpa|O|O||D||1
40151569|Bomba monoflex|O|O||D||1
40151570|Bomba de flujo mixto|O|O||D||1
40151571|Bomba longitudinal|O|O||D||1
40151572|Bomba de elevación de aire|O|O||D||1
40151573|Bomba de magneto|O|O||D||1
40151574|Bomba eyectora|O|O||D||1
40151575|Bomba enfriadora sin cepillo|O|O||D||1
40151576|Bomba eléctrica|O|O||D||1
40151577|Bomba de lechada|O|O||D||1
40151578|Bomba de aire para buceo|O|O||D||1
40151579|Bomba de gravedad|O|O||D||1
40151580|Bomba lubricante|O|O||D||1
40151600|Compresores|O|O||D||1
40151601|Compresores de aire|O|O||D||1
40151602|Compresores de flujo axiales|O|O||D||1
40151603|Compresores de diafragma|O|O||D||1
40151604|Compresores de gas|O|O||D||1
40151605|Compresores de motor|O|O||D||1
40151606|Compresores recíprocos|O|O||D||1
40151607|Compresores refrigerantes|O|O||D||1
40151608|Compresores rotativos|O|O||D||1
40151609|Compresores de tuerca|O|O||D||1
40151611|Compresores de barril|O|O||D||1
40151612|Compresores centrífugos|O|O||D||1
40151613|Compresores de combinación|O|O||D||1
40151614|Compresores semi radiales|O|O||D||1
40151615|Turbo compresores|O|O||D||1
40151616|Kits de compresores|O|O||D||1
40151700|Piezas y accesorios de bomba|O|O||D||1
40151701|Carcasas para bombas|O|O||D||1
40151712|Empaques para bombas|O|O||D||1
40151713|Revestimientos para bombas|O|O||D||1
40151714|Barriles para bombas|O|O||D||1
40151715|Poleas para bombas|O|O||D||1
40151716|Cabezas para bombas|O|O||D||1
40151717|Discos para bombas|O|O||D||1
40151718|Partes de repuesto para bombas de lodo|O|O||D||1
40151719|Partes de repuesto para bombas de alcantarillado|O|O||D||1
40151720|Partes de repuesto para bombas sumergibles|O|O||D||1
40151721|Partes de repuesto para bombas de agua|O|O||D||1
40151722|Partes de repuesto para bombas de pozo|O|O||D||1
40151723|Partes de repuesto para bombas de sumidero|O|O||D||1
40151724|Partes de repuesto para bombas dosificadoras|O|O||D||1
40151725|Partes de repuesto para bombas centrífugas|O|O||D||1
40151726|Partes de repuesto para bombas de circulación|O|O||D||1
40151727|Partes de repuesto para bombas rotatorias|O|O||D||1
40151728|Kits de reparación de bombas|O|O||D||1
40151729|Estator de bombas|O|O||D||1
40151730|Impulsores de bombas|O|O||D||1
40151731|Rotores de bombas|O|O||D||1
40151732|Ejes de bombas|O|O||D||1
40151733|Placas de asiento de bombas|O|O||D||1
40151734|Placas de base de bombas|O|O||D||1
40151735|Ensamblaje de columnas de bombas|O|O||D||1
40151736|Tubos de columna de bombas|O|O||D||1
40151737|Ensamblaje de caja de bombas|O|O||D||1
40151738|Campana de succión de bombas|O|O||D||1
40151739|Partes para bombas recíprocas|O|O||D||1
40151800|Partes o accesorios de compresores|O|O||D||1
40151801|Partes para compresores rotatorios|O|O||D||1
40151802|Partes para compresores de aire|O|O||D||1
40151803|Partes para compresores recíprocos|O|O||D||1
40151804|Partes para compresores centrífugos|O|O||D||1
40161500|Filtros|O|O||D||1
40161501|Filtros al vacío|O|O||D||1
40161502|Filtros de agua|O|O||D||1
40161503|Recolectores de polvo|O|O||D||1
40161504|Filtros de aceite|O|O||D||1
40161505|Filtros de aire|O|O||D||1
40161506|Maquinaria de filtrado|O|O||D||1
40161507|Membranas de filtrado|O|O||D||1
40161508|Filtros de bolsa|O|O||D||1
40161509|Filtros de absorción|O|O||D||1
40161511|Filtros coalescentes|O|O||D||1
40161512|Filtros electrónicos|O|O||D||1
40161513|Filtros de combustible|O|O||D||1
40161514|Filtros para tuberías de gas|O|O||D||1
40161515|Filtros hidráulicos|O|O||D||1
40161516|Filtros en línea|O|O||D||1
40161517|Filtros de luz|O|O||D||1
40161518|Filtros de microfibra|O|O||D||1
40161519|Filtros de panel|O|O||D||1
40161520|Filtros de aletas radiales|O|O||D||1
40161521|Bases para filtros|O|O||D||1
40161522|Aletas para filtros|O|O||D||1
40161524|Filtros de pintura|O|O||D||1
40161525|Contenedores para filtros|O|O||D||1
40161526|Retenedores o accesorios para filtros|O|O||D||1
40161527|Kits de reparación de filtros|O|O||D||1
40161528|Filtros de arena|O|O||D||1
40161529|Filtros de tubo|O|O||D||1
40161530|Filtros de cabina de aire|O|O||D||1
40161531|Ensamblaje de filtros|O|O||D||1
40161532|Malla para filtros|O|O||D||1
40161533|Filtros para desechos sólidos|O|O||D||1
40161600|Purificación|O|O||D||1
40161601|Neutralizador (depurador) de aire|O|O||D||1
40161602|Limpiadores de aire|O|O||D||1
40161603|Máquinas limpiadoras de tubos y tuberías|O|O||D||1
40161604|Regenerador de aceite|O|O||D||1
40161605|Torre desodorizante|O|O||D||1
40161606|Generador de ozono para limpiar el aire|O|O||D||1
40161607|Sistema para desulfurar el gas de combustión|O|O||D||1
40161608|Esterilizador de aire|O|O||D||1
40161700|Separadores|O|O||D||1
40161701|Centrífugas|O|O||D||1
40161702|Lavador húmedo|O|O||D||1
40161703|Eliminadores de niebla|O|O||D||1
40161704|Hidrociclones|O|O||D||1
40161705|Tamiz separador de partículas líquidas|O|O||D||1
40161800|Medios de filtrado|O|O||D||1
40161801|Medios de textiles metálicos|O|O||D||1
40161802|Fieltros prensados|O|O||D||1
40161803|Papeles filtrantes|O|O||D||1
40161804|Ayudas filtrantes|O|O||D||1|Ayudas de filtro
40161805|Paño filtrante|O|O||D||1
40161806|Malla filtrante|O|O||D||1
40161807|Elemento (dispositivo poroso) filtrante|O|O||D||1
40161808|Medio biológico filtrante|O|O||D||1
40161809|Cartucho filtrante|O|O||D||1
40171500|Tubos y tuberías comerciales|O|O||D||1
40171501|Tubo de acero al carbono soldado para uso comercial|O|O||D||1
40171502|Tubo de acero al carbono sin uniones para uso comercial|O|O||D||1
40171503|Tubo de hierro dúctil para uso comercial|O|O||D||1
40171504|Tubo de aleación de alto níquel para uso comercial|O|O||D||1
40171505|Tubo de acero de alto rendimiento para uso comercial|O|O||D||1
40171506|Tubo de aleación ferrosa para uso comercial|O|O||D||1
40171507|Tubo de aluminio para uso comercial|O|O||D||1
40171508|Tubo de latón para uso comercial|O|O||D||1
40171509|Tubo de bronce para uso comercial|O|O||D||1
40171510|Tubo de concreto para uso comercial|O|O||D||1
40171511|Tubo de cobre para uso comercial|O|O||D||1
40171512|Tubo de hierro forjado para uso comercial|O|O||D||1
40171513|Concentrador de tubo de hierro forjado ensamblado para uso comercial|O|O||D||1
40171514|Tubo de plomo para uso comercial|O|O||D||1
40171515|Tubo de magnesio para uso comercial|O|O||D||1
40171516|Tubo no ferroso para uso comercial|O|O||D||1
40171517|Tubo pvc para uso comercial|O|O||D||1
40171518|Tubo cpvc para uso comercial|O|O||D||1
40171519|Tubo abs para uso comercial|O|O||D||1
40171520|Tubo hdpe para uso comercial|O|O||D||1
40171521|Tubo de acero inoxidable soldado para uso comercial|O|O||D||1
40171522|Tubo de acero inoxidable sin uniones para uso comercial|O|O||D||1
40171523|Tubo de latón para uso comercial|O|O||D||1
40171524|Tubo de titanio para uso comercial|O|O||D||1
40171525|Tubo de zinc para uso comercial|O|O||D||1
40171526|Tubo de vidrio para uso comercial|O|O||D||1
40171527|Tubo galvanizado corrugado soldado para uso comercial|O|O||D||1
40171600|Tubos y tuberías industriales|O|O||D||1
40171601|Tubo de acero al carbono soldado para uso industrial|O|O||D||1
40171602|Tubo de acero al carbono sin uniones para uso industrial|O|O||D||1
40171603|Tubo de hierro dúctil para uso industrial|O|O||D||1
40171604|Tubo de aleación de alto níquel para uso industrial|O|O||D||1
40171605|Tubo de acero de alto rendimiento para uso industrial|O|O||D||1
40171606|Tubo de aleación ferrosa para uso industrial|O|O||D||1
40171607|Tubo de aluminio para uso industrial|O|O||D||1
40171608|Tubo de latón para uso industrial|O|O||D||1
40171609|Tubo de bronce para uso industrial|O|O||D||1
40171610|Tubo de concreto para uso industrial|O|O||D||1
40171611|Tubo de cobre para uso industrial|O|O||D||1
40171612|Tubo de hierro forjado para uso industrial|O|O||D||1
40171613|Concentrador de tubo de hierro forjado ensamblado para uso industrial|O|O||D||1
40171614|Tubo de plomo para uso industrial|O|O||D||1
40171615|Tubo de magnesio para uso industrial|O|O||D||1
40171616|Tubo no ferroso para uso industrial|O|O||D||1
40171617|Tubo pvc para uso industrial|O|O||D||1
40171618|Tubo cpvc para uso industrial|O|O||D||1
40171619|Tubo abs para uso industrial|O|O||D||1
40171620|Tubo hdpe para uso industrial|O|O||D||1
40171621|Tubo de acero inoxidable soldado para uso industrial|O|O||D||1
40171622|Tubo de acero inoxidable sin uniones para uso industrial|O|O||D||1
40171623|Tubo de latón para uso industrial|O|O||D||1
40171624|Tubo de titanio para uso industrial|O|O||D||1
40171625|Tubo de zinc para uso industrial|O|O||D||1
40171626|Tubo de vidrio para uso industrial|O|O||D||1
40171700|Adaptadores de tubos|O|O||D||1
40171701|Adaptador de tubo de latón|O|O||D||1
40171702|Adaptador de tubo de acero al carbono|O|O||D||1
40171703|Adaptador de tubo de hierro forjado|O|O||D||1
40171704|Adaptador de tubo de hierro dúctil|O|O||D||1
40171705|Adaptador de tubo de acero forjado|O|O||D||1
40171706|Adaptador de tubo de hierro maleable|O|O||D||1
40171707|Adaptador de tubo de acero inoxidable|O|O||D||1
40171708|Adaptador de tubo plástico pvc|O|O||D||1
40171709|Adaptador de tubo plástico cpvc|O|O||D||1
40171710|Adaptador de tubo plástico abs|O|O||D||1
40171711|Adaptador de tubo plástico hdpe|O|O||D||1
40171800|Anillos frontales de ángulos de tubos|O|O||D||1
40171801|Anillo frontal de ángulo de tubo de acero al carbono|O|O||D||1
40171802|Anillo frontal de ángulo de tubo de acero forjado|O|O||D||1
40171803|Anillo frontal de ángulo de tubo de acero inoxidable|O|O||D||1
40171900|Bridas de respaldo para tubos|O|O||D||1
40171901|Brida de respaldo para tubos de acero al carbono|O|O||D||1
40171902|Brida de respaldo para tubos de acero forjado|O|O||D||1
40171903|Brida de respaldo para tubos de acero inoxidable|O|O||D||1
40171904|Brida de respaldo para tubos de hierro dúctil|O|O||D||1
40171905|Brida de respaldo para tubos de cobre|O|O||D||1
40172000|Deflectores para tubos|O|O||D||1
40172001|Deflectores para tubos de latón|O|O||D||1|Coples para tubos de latón
40172002|Deflectores para tubos de hierro dúctil|O|O||D||1|Coples para tubos de hierro dúctil
40172003|Deflectores para tubos de acero forjado|O|O||D||1|Coples para tubos de acero forjado
40172004|Deflectores para tubos de acero inoxidable|O|O||D||1|Coples para tubos de acero inoxidable
40172005|Deflectores para tubos de plástico pvc|O|O||D||1|Coples para tubos de plástico PVC
40172006|Deflectores para tubos de plástico cpvc|O|O||D||1|Coples para tubos de plástico cpvc
40172007|Deflectores para tubos de plástico abs|O|O||D||1|Coples para tubos de plástico ABS
40172008|Deflectores para tubos de plástico hdpe|O|O||D||1|Coples para tubos de plástico hdpe
40172100|Codos para tubos|O|O||D||1
40172101|Codos para tubos de hierro forjado|O|O||D||1
40172102|Codos para tubos de hierro maleable|O|O||D||1
40172103|Codos para tubos de cobre|O|O||D||1
40172200|Bridas ciegas para tubos|O|O||D||1
40172201|Bridas ciegas para tubos de acero al carbono|O|O||D||1
40172202|Bridas ciegas para tubos de hierro forjado|O|O||D||1
40172203|Bridas ciegas para tubos de hierro dúctil|O|O||D||1
40172204|Bridas ciegas para tubos de acero forjado|O|O||D||1
40172205|Bridas ciegas para tubos de acero inoxidable|O|O||D||1
40172206|Bridas ciegas para tubos de cobre|O|O||D||1
40172300|Casquillos para tubos|O|O||D||1
40172301|Casquillos para tubos de latón|O|O||D||1
40172302|Casquillos para tubos de acero al carbono|O|O||D||1
40172303|Casquillos para tubos de hierro forjado|O|O||D||1
40172304|Casquillos para tubos de hierro dúctil|O|O||D||1
40172305|Casquillos para tubos de acero forjado|O|O||D||1
40172306|Casquillos para tubos de hierro maleable|O|O||D||1
40172307|Casquillos para tubos de acero inoxidable|O|O||D||1
40172308|Casquillos para tubos de plástico pvc|O|O||D||1
40172309|Casquillos para tubos de plástico cpvc|O|O||D||1
40172310|Casquillos para tubos de plástico abs|O|O||D||1
40172311|Casquillos para tubos de plástico hdpe|O|O||D||1
40172312|Casquillos para tubos de cobre|O|O||D||1
40172313|Casquillos para tubos de caucho|O|O||D||1
40172400|Tapas para tubos|O|O||D||1
40172401|Tapa de tubo de latón|O|O||D||1
40172402|Tapa de tubo de acero al carbono|O|O||D||1
40172403|Tapa de tubo de hierro forjado|O|O||D||1
40172404|Tapa de tubo de hierro dúctil|O|O||D||1
40172405|Tapa de tubo de acero forjado|O|O||D||1
40172406|Tapa de tubo de hierro maleable|O|O||D||1
40172407|Tapa de tubo de acero inoxidable|O|O||D||1
40172408|Tapa de tubo de plástico pvc|O|O||D||1
40172409|Tapa de tubo de plástico cpvc|O|O||D||1
40172410|Tapa de tubo de plástico abs|O|O||D||1
40172411|Tapa de tubo de plástico hdpe|O|O||D||1
40172412|Tapa de tubo de cobre|O|O||D||1
40172413|Tapa de tubo de caucho|O|O||D||1
40172500|Conectores de tubos|O|O||D||1
40172501|Conector de tubo de latón|O|O||D||1
40172502|Conector de tubo de acero al carbono|O|O||D||1
40172503|Conector de tubo de hierro forjado|O|O||D||1
40172504|Conector de tubo de hierro dúctil|O|O||D||1
40172505|Conector de tubo de acero forjado|O|O||D||1
40172506|Conector de tubo de hierro maleable|O|O||D||1
40172507|Conector de tubo de acero inoxidable|O|O||D||1
40172508|Conector de tubo de plástico pvc|O|O||D||1
40172509|Conector de tubo de plástico cpvc|O|O||D||1
40172510|Conector de tubo de plástico abs|O|O||D||1
40172511|Conector de tubo de plástico hdpe|O|O||D||1
40172512|Conector de tubo de plástico vidrio reforzado termoestable|O|O||D||1
40172513|Conector de tubo flexible|O|O||D||1
40172514|Conector de tubo pre aislado|O|O||D||1
40172515|Conector de tubo de poli butileno|O|O||D||1
40172516|Conector de tubo de polietileno|O|O||D||1
40172517|Conector de tubo de polipropileno|O|O||D||1
40172518|Conector de tubo de acero revestido|O|O||D||1
40172519|Conector de tubo de aleación de aluminio y de aluminio|O|O||D||1
40172520|Conector de tubo de clorhidrato de polivinilo rígido|O|O||D||1
40172521|Conector de tubo de cobre y de aleación de cobre|O|O||D||1
40172522|Uniones de tubo flexible|O|O||D||1
40172600|Acoples de tubos|O|O||D||1
40172601|Acoples de tubos de latón|O|O||D||1
40172602|Acoples de tubos de acero al carbono|O|O||D||1
40172603|Acoples de tubos de hierro forjado|O|O||D||1
40172604|Acoples de tubos de hierro dúctil|O|O||D||1
40172605|Acoples de tubos de acero forjado|O|O||D||1
40172606|Acoples de tubos de hierro maleable|O|O||D||1
40172607|Acoples de tubos de acero inoxidable|O|O||D||1
40172608|Acoples de tubos de plástico pvc|O|O||D||1
40172609|Acoples de tubos de plástico cpvc|O|O||D||1
40172610|Acoples de tubos abs|O|O||D||1
40172611|Acoples de tubos de plástico hdpe|O|O||D||1
40172612|Acoples de tubos de cobre|O|O||D||1
40172700|Cruces de tubos|O|O||D||1
40172701|Cruces de tubos de latón|O|O||D||1
40172702|Cruces de tubos de acero al carbono|O|O||D||1
40172703|Cruces de tubos de hierro forjado|O|O||D||1
40172704|Cruces de tubos de hierro dúctil|O|O||D||1
40172705|Cruces de tubos de acero forjado|O|O||D||1
40172706|Cruces de tubos de hierro maleable|O|O||D||1
40172707|Cruces de tubos de acero inoxidable|O|O||D||1
40172708|Cruces de tubos de plástico pvc|O|O||D||1
40172709|Cruces de tubos de plástico cpvc|O|O||D||1
40172710|Cruces de tubos de plástico abs|O|O||D||1
40172711|Cruces de tubos de plástico hdpe|O|O||D||1
40172712|Cruces de tubos de cobre|O|O||D||1
40172800|Codos de tubos|O|O||D||1
40172801|Codos para tubos de latón|O|O||D||1
40172802|Codos para tubos de acero al carbono|O|O||D||1
40172803|Codos para tubos de hierro forjado|O|O||D||1
40172804|Codos para tubos de hierro dúctil|O|O||D||1
40172805|Codos para tubos de acero forjado|O|O||D||1
40172806|Codos para tubos de hierro maleable|O|O||D||1
40172807|Codos para tubos de acero inoxidable|O|O||D||1
40172808|Codos para tubos de plástico pvc|O|O||D||1
40172809|Codos para tubos de plástico cpvc|O|O||D||1
40172810|Codos para tubos de plástico abs|O|O||D||1
40172811|Codos para tubos de plástico hdpe|O|O||D||1
40172812|Codos para tubos de cobre|O|O||D||1
40172900|Uniones de extensión de tubos|O|O||D||1|Uniones o niples de extensión de tubos
40172901|Uniones de extensión para tubos de acero al carbono|O|O||D||1|Uniones o niples de extensión para tubos de acero al carbono
40172902|Uniones de extensión para tubos de hierro forjado|O|O||D||1|Uniones o niples de extensión para tubos de hierro forjado
40172903|Uniones de extensión para tubos de hierro dúctil|O|O||D||1|Uniones o niples de extensión para tubos de hierro dúctil
40172904|Uniones de extensión para tubos de acero forjado|O|O||D||1|Uniones o niples de extensión para tubos de acero forjado
40172905|Uniones de extensión para tubos de acero inoxidable|O|O||D||1|Uniones o niples de extensión para tubos de acero inoxidable
40172906|Uniones de extensión para tubos de plástico pvc|O|O||D||1|Uniones o niples de extensión para tubos de plástico PVC
40172907|Uniones de extensión para tubos de plástico cpvc|O|O||D||1|Uniones o niples de extensión para tubos de plástico cpvc
40172908|Uniones de extensión para tubos de plástico abs|O|O||D||1|Uniones o niples de extensión para tubos de plástico ABS
40172909|Uniones de extensión para tubos de plástico hdpe|O|O||D||1|Uniones o niples de extensión para tubos de plástico hdpe
40172910|Uniones de extensión para tubos de caucho|O|O||D||1|Uniones o niples de extensión para tubos de caucho
40172911|Uniones de extensión para tubos de cobre|O|O||D||1|Uniones o niples de extensión para tubos de cobre
40173000|Semiacoplamientos de tubería|O|O||D||1|Reducciones para tubos
40173001|Semiacoplamientos para tubos de latón|O|O||D||1|Reducciones de latón
40173002|Semiacoplamientos para tubos de acero al carbono|O|O||D||1|Reducciones de acero al carbono
40173003|Semiacoplamientos para tubos de acero forjado|O|O||D||1|Reducciones de acero forjado
40173004|Semiacoplamientos para tubos de hierro maleable|O|O||D||1|Reducciones de hierro maleable
40173005|Semiacoplamientos para tubos de acero inoxidable|O|O||D||1|Reducciones de acero inoxidable
40173006|Semiacoplamientos para tubos de plástico pvc|O|O||D||1|Reducciones de plástico PVC
40173007|Semiacoplamientos para tubos de plástico cpvc|O|O||D||1|Reducciones de plástico cpvc
40173008|Semiacoplamientos para tubos de plástico abs|O|O||D||1|Reducciones de plástico ABS
40173009|Semiacoplamientos para tubos de plástico hdpe|O|O||D||1|Reducciones de plástico hdpe
40173100|Brida de junta de empalme para tubos|O|O||D||1|Juntas de unión para tubos
40173101|Brida de junta de empalme para tubos de acero al carbono|O|O||D||1|Junta de unión para tubos de acero al carbono
40173102|Brida de junta de empalme para tubos de acero forjado|O|O||D||1|Junta de unión para tubos de acero forjado
40173103|Brida de junta de empalme para tubos de acero inoxidable|O|O||D||1|Junta de unión para tubos de acero inoxidable
40173104|Brida de junta de empalme para tubos de cobre|O|O||D||1|Junta de unión para tubos de cobre
40173200|Bridas cuello largas para soldar|O|O||D||1|Juntas de cuello largo para soldar
40173201|Bridas cuello largas para soldar para tubos de acero al carbono|O|O||D||1|Junta de cuello largo para soldar para tubos de acero al carbono
40173202|Bridas cuello largas para soldar para tubos de acero forjado|O|O||D||1|Junta de cuello largo para soldar para tubos de acero forjado
40173203|Bridas cuello largas para soldar para tubos de acero inoxidable|O|O||D||1|Junta de cuello largo para soldar para tubos de acero inoxidable
40173300|Boquillas de tubos|O|O||D||1
40173301|Boquillas para tubos de latón|O|O||D||1
40173302|Boquillas para tubos de acero al carbono|O|O||D||1
40173303|Boquillas para tubos de acero inoxidable|O|O||D||1
40173304|Boquillas para tubos de plástico pvc|O|O||D||1
40173305|Boquillas para tubos de plástico cpvc|O|O||D||1
40173306|Boquillas para tubos de plástico abs|O|O||D||1
40173307|Boquillas para tubos de plástico hdpe|O|O||D||1
40173400|Bridas de plato|O|O||D||1
40173401|Bridas de plato para tubos de latón|O|O||D||1
40173402|Bridas de plato para tubos de acero al carbono|O|O||D||1
40173403|Bridas de plato para tubos de hierro forjado|O|O||D||1
40173404|Bridas de plato para tubos de hierro dúctil|O|O||D||1
40173405|Bridas de plato para tubos de hierro maleable|O|O||D||1
40173406|Bridas de plato para tubos de acero inoxidable|O|O||D||1
40173407|Bridas de plato para tubos de plástico abs|O|O||D||1
40173408|Bridas de plato para tubos de plástico pvc|O|O||D||1
40173409|Bridas de plato para tubos de cobre|O|O||D||1
40173500|Tapones para tubos|O|O||D||1
40173501|Tapones para tubos de latón|O|O||D||1
40173502|Tapones para tubos de acero al carbono|O|O||D||1
40173503|Tapones para tubos de hierro forjado|O|O||D||1
40173504|Tapones para tubos de hierro dúctil|O|O||D||1
40173505|Tapones para tubos de acero forjado|O|O||D||1
40173506|Tapones para tubos de hierro maleable|O|O||D||1
40173507|Tapones para tubos de acero inoxidable|O|O||D||1
40173508|Tapones para tubos de plástico pvc|O|O||D||1
40173509|Tapones para tubos de plástico cpvc|O|O||D||1
40173510|Tapones para tubos de plástico abs|O|O||D||1
40173511|Tapones para tubos de plástico hdpe|O|O||D||1
40173512|Tapones para tubos de cobre|O|O||D||1
40173513|Tapones para tubos de caucho|O|O||D||1
40173600|Acoplamientos reductores para tubos|O|O||D||1|Coples reductores
40173601|Acoplamiento reductor para tubos de latón|O|O||D||1|Cople reductor para tubos de latón
40173602|Acoplamiento reductor para tubos de acero al carbono|O|O||D||1|Cople reductor para tubos de acero al carbono
40173603|Acoplamiento reductor para tubos de hierro forjado|O|O||D||1|Cople reductor para tubos de hierro forjado
40173604|Acoplamiento reductor para tubos de hierro dúctil|O|O||D||1|Cople reductor para tubos de hierro dúctil
40173605|Acoplamiento reductor para tubos de acero forjado|O|O||D||1|Cople reductor para tubos de acero forjado
40173606|Acoplamiento reductor para tubos de hierro maleable|O|O||D||1|Cople reductor para tubos de hierro maleable
40173607|Acoplamiento reductor para tubos de acero inoxidable|O|O||D||1|Cople reductor para tubos de acero inoxidable
40173608|Acoplamiento reductor para tubos de plástico pvc|O|O||D||1|Cople reductor para tubos de plástico PVC
40173609|Acoplamiento reductor para tubos de plástico cpvc|O|O||D||1|Cople reductor para tubos de plástico cpvc
40173610|Acoplamiento reductor para tubos de plástico abs|O|O||D||1
40173611|Acoplamiento reductor para tubos de plástico hdpe|O|O||D||1
40173612|Acoplamiento reductor para tubos de caucho|O|O||D||1|Cople reductor para tubos de caucho
40173613|Acoplamiento reductor para tubos de cobre|O|O||D||1|Cople reductor para tubos de cobre
40173700|Bridas reductoras para tubos|O|O||D||1
40173701|Brida reductora para tubos de latón|O|O||D||1
40173702|Brida reductora para tubos de hierro forjado|O|O||D||1
40173703|Brida reductora para tubos de hierro dúctil|O|O||D||1
40173704|Brida reductora para tubos de acero forjado|O|O||D||1
40173705|Brida reductora para tubos de hierro maleable|O|O||D||1
40173706|Brida reductora para tubos de acero inoxidable|O|O||D||1
40173707|Brida reductora para tubos de plástico pvc|O|O||D||1
40173708|Brida reductora para tubos de plástico cpvc|O|O||D||1
40173709|Brida reductora para tubos de plástico abs|O|O||D||1
40173710|Brida reductora para tubos de plástico hdpe|O|O||D||1
40173711|Brida reductora para tubos de cobre|O|O||D||1
40173800|Abrazaderas de reparación para tubos|O|O||D||1
40173801|Abrazadera de reparación para tubos de hierro forjado|O|O||D||1
40173802|Abrazadera de reparación para tubos de hierro dúctil|O|O||D||1
40173803|Abrazadera de reparación para tubos de acero forjado|O|O||D||1
40173804|Abrazadera de reparación para tubos de acero inoxidable|O|O||D||1
40173805|Abrazadera de reparación para tubos de plástico pvc|O|O||D||1
40173806|Abrazadera de reparación para tubos de plástico cpvc|O|O||D||1
40173807|Abrazadera de reparación para tubos de plástico abs|O|O||D||1
40173808|Abrazadera de reparación para tubos de plástico hdpe|O|O||D||1
40173900|Disco de ruptura para tubos|O|O||D||1
40173901|Disco de ruptura para tubos de acero al carbono|O|O||D||1
40173902|Disco de ruptura para tubos de hierro forjado|O|O||D||1
40173903|Disco de ruptura para tubos de hierro dúctil|O|O||D||1
40173904|Disco de ruptura para tubos de acero forjado|O|O||D||1
40173905|Disco de ruptura para tubos de hierro maleable|O|O||D||1
40173906|Disco de ruptura para tubos de acero inoxidable|O|O||D||1
40173907|Disco de ruptura para tubos de plástico pvc|O|O||D||1
40173908|Disco de ruptura para tubos de plástico cpvc|O|O||D||1
40173909|Disco de ruptura para tubos de plástico abs|O|O||D||1
40173910|Disco de ruptura para tubos de plástico hdpe|O|O||D||1
40174000|Brida deslizante para tubos|O|O||D||1
40174001|Brida deslizante para tubos de latón|O|O||D||1
40174002|Brida deslizante para tubos de acero al carbono|O|O||D||1
40174003|Brida deslizante para tubos de hierro forjado|O|O||D||1
40174004|Brida deslizante para tubos de hierro dúctil|O|O||D||1
40174005|Brida deslizante para tubos de acero forjado|O|O||D||1
40174006|Brida deslizante para tubos de acero inoxidable|O|O||D||1
40174007|Brida deslizante para tubos de cobre|O|O||D||1
40174100|Brida encajada por soldadura para tubos|O|O||D||1
40174101|Brida encajada por soldadura para tubos de acero al carbono|O|O||D||1
40174102|Brida encajada por soldadura para tubos de acero forjado|O|O||D||1
40174103|Brida encajada por soldadura para tubos de acero inoxidable|O|O||D||1
40174104|Brida encajada por soldadura para tubos de plástico pvc|O|O||D||1
40174105|Brida encajada por soldadura para tubos de plástico cpvc|O|O||D||1
40174106|Brida encajada por soldadura para tubos de plástico abs|O|O||D||1
40174107|Brida encajada por soldadura para tubos de plástico hdpe|O|O||D||1
40174108|Brida encajada por soldadura para tubos de cobre|O|O||D||1
40174200|Sockolets para tubos|O|O||D||1
40174201|Sockolet para tubos de acero al carbono|O|O||D||1
40174202|Sockolet para tubos de acero forjado|O|O||D||1
40174203|Sockolet para tubos de acero inoxidable|O|O||D||1
40174300|Espaciadores para tubos|O|O||D||1|Separadores para tubos
40174301|Espaciador para tubos de latón|O|O||D||1|Separador para tubos de latón
40174302|Espaciador para tubos de acero al carbono|O|O||D||1|Separador para tubos de acero al carbono
40174303|Espaciador para tubos de hierro forjado|O|O||D||1|Separador para tubos de hierro forjado
40174304|Espaciador para tubos de hierro dúctil|O|O||D||1|Separador para tubos de hierro dúctil
40174305|Espaciador para tubos de acero forjado|O|O||D||1|Separador para tubos de acero forjado
40174306|Espaciador para tubos de acero inoxidable|O|O||D||1|Separador para tubos de acero inoxidable
40174307|Espaciador para tubos de plástico pvc|O|O||D||1|Separador para tubos de plástico PVC
40174308|Espaciador para tubos de plástico cpvc|O|O||D||1|Separador para tubos de plástico cpvc
40174309|Espaciador para tubos de plástico abs|O|O||D||1|Separador para tubos de plástico ABS
40174310|Espaciador para tubos de plástico hdpe|O|O||D||1|Separador para tubos de plástico hdpe
40174400|Bridas ciegas para tubos|O|O||D||1
40174401|Bridas ciegas para tubos de acero al carbono|O|O||D||1
40174402|Bridas ciegas para tubos de acero forjado|O|O||D||1
40174403|Bridas ciegas para tubos de acero forjado|O|O||D||1
40174500|Pivotes o uniones rotativas para tubos|O|O||D||1
40174501|Pivotes o uniones rotativas para tubos de latón|O|O||D||1
40174502|Pivotes o uniones rotativas para tubos de plástico pvc|O|O||D||1
40174503|Pivotes o uniones rotativas para tubos de plástico cpvc|O|O||D||1
40174504|Pivotes o uniones rotativas para tubos de plástico abs|O|O||D||1
40174505|Pivotes o uniones rotativas para tubos de plástico hdpe|O|O||D||1
40174506|Pivotes o uniones rotativas para tubos de cobre|O|O||D||1
40174600|T para tubos|O|O||D||1|Conexiones en T para tubos
40174601|T para tubos de latón|O|O||D||1|Conexión en T para tubos de latón
40174602|T para tubos de acero al carbono|O|O||D||1|Conexión en T para tubos de acero al carbono
40174603|T para tubos de hierro forjado|O|O||D||1|Conexión en T para tubos de hierro forjado
40174604|T para tubos de hierro dúctil|O|O||D||1|Conexión en T para tubos de hierro dúctil
40174605|T para tubos de acero forjado|O|O||D||1|Conexión en T para tubos de acero forjado
40174606|T para tubos de hierro maleable|O|O||D||1|Conexión en T para tubos de hierro maleable
40174607|T para tubos de acero inoxidable|O|O||D||1|Conexión en T para tubos de acero inoxidable
40174608|T para tubos de plástico pvc|O|O||D||1|Conexión en T para tubos de plástico PVC
40174609|T para tubos de plástico cpvc|O|O||D||1|Conexión en T para tubos de plástico cpvc
40174610|T para tubos de plástico abs|O|O||D||1|Conexión en T para tubos de plástico ABS
40174611|T para tubos de plástico hdpe|O|O||D||1|Conexión en T para tubos de plástico hdpe
40174612|T para tubos de cobre|O|O||D||1|Conexión en T para tubos de cobre
40174700|Brida roscada para tubos|O|O||D||1
40174701|Brida roscada para tubos de latón|O|O||D||1
40174702|Brida roscada para tubos de acero al carbono|O|O||D||1
40174703|Brida roscada para tubos de hierro forjado|O|O||D||1
40174704|Brida roscada para tubos de hierro dúctil|O|O||D||1
40174705|Brida roscada para tubos de acero forjado|O|O||D||1
40174706|Brida roscada para tubos de hierro maleable|O|O||D||1
40174707|Brida roscada para tubos de acero inoxidable|O|O||D||1
40174708|Brida roscada para tubos de plástico pvc|O|O||D||1
40174709|Brida roscada para tubos de plástico cpvc|O|O||D||1
40174710|Brida roscada para tubos de plástico abs|O|O||D||1
40174711|Brida roscada para tubos de plástico hdpe|O|O||D||1
40174800|Bridas de inodoro para tubos|O|O||D||1
40174801|Bridas de inodoro para tubos de acero al carbono|O|O||D||1
40174802|Bridas de inodoro para tubos de hierro forjado|O|O||D||1
40174803|Bridas de inodoro para tubos de plástico pvc|O|O||D||1
40174804|Bridas de inodoro para tubos de plástico cpvc|O|O||D||1
40174805|Bridas de inodoro para tubos de plástico abs|O|O||D||1
40174806|Bridas de inodoro para tubos de plástico hdpe|O|O||D||1
40174807|Bridas de inodoro para tubos de latón|O|O||D||1
40174808|Bridas de inodoro para tubos de cobre|O|O||D||1
40174900|Uniones para tubos|O|O||D||1
40174901|Uniones para tubos de latón|O|O||D||1
40174902|Uniones para tubos de acero al carbono|O|O||D||1
40174903|Uniones para tubos de hierro forjado|O|O||D||1
40174904|Uniones para tubos de hierro dúctil|O|O||D||1
40174905|Uniones para tubos de acero forjado|O|O||D||1
40174906|Uniones para tubos de hierro maleable|O|O||D||1
40174907|Uniones para tubos de acero inoxidable|O|O||D||1
40174908|Uniones para tubos de plástico pvc|O|O||D||1
40174909|Uniones para tubos de plástico cpvc|O|O||D||1
40174910|Uniones para tubos de plástico abs|O|O||D||1
40174911|Uniones para tubos de plástico hdpe|O|O||D||1
40174912|Uniones para tubos de cobre|O|O||D||1
40175000|Bridas cuello para tubos|O|O||D||1
40175001|Bridas cuello para tubos de acero al carbono|O|O||D||1
40175002|Bridas cuello para tubos de acero forjado|O|O||D||1
40175003|Bridas cuello para tubos de acero inoxidable|O|O||D||1
40175100|Brida encajada por soldadura|O|O||D||1
40175101|Brida encajada por soldadura para tubos de acero al carbono|O|O||D||1
40175102|Brida encajada por soldadura para tubos de acero forjado|O|O||D||1
40175103|Brida encajada por soldadura para tubos de acero inoxidable|O|O||D||1
40175200|Y de conexión para tubos|O|O||D||1|Conexiones en Y para tubos
40175201|Y de conexión para tubos de latón|O|O||D||1|Conexión en Y para tubos de latón
40175202|Y de conexión para tubos de acero al carbono|O|O||D||1|Conexión en Y para tubos de acero al carbono
40175203|Y de conexión para tubos de hierro forjado|O|O||D||1|Conexión en Y para tubos de hierro forjado
40175204|Y de conexión para tubos de hierro dúctil|O|O||D||1|Conexión en Y para tubos de hierro dúctil
40175205|Y de conexión para tubos de acero forjado|O|O||D||1|Conexión en Y para tubos de acero forjado
40175206|Y de conexión para tubos de hierro maleable|O|O||D||1|Conexión en Y para tubos de hierro maleable
40175207|Y de conexión para tubos de acero inoxidable|O|O||D||1|Conexión en Y para tubos de acero inoxidable
40175208|Y de conexión para tubos de plástico pvc|O|O||D||1|Conexión en Y para tubos de plástico PVC
40175209|Y de conexión para tubos de plástico cpvc|O|O||D||1|Conexión en Y para tubos de plástico cpvc
40175210|Y de conexión para tubos de plástico abs|O|O||D||1|Conexión en Y para tubos de plástico ABS
40175211|Y de conexión para tubos de plástico hdpe|O|O||D||1|Conexión en Y para tubos de plástico hdpe
40175212|Y de conexión para tubos de cobre|O|O||D||1|Conexión en Y para tubos de cobre
40175300|Accesorios y bridas especializados para tubos|O|O||D||1
40175301|Bridas de amoniaco|O|O||D||1|Bridas para amoniaco
40175302|Bridas de orificio|O|O||D||1
40175303|Salidas para ramas de tubería|O|O||D||1
40175304|Cajas de conexión de tubos|O|O||D||1
40175305|Insertos de tubos|O|O||D||1|Tapones de tubos
40175306|Laterales de tubos|O|O||D||1
40175307|Sillas de tubos|O|O||D||1|Monturas y soportes para tubos
40175308|Remates de secciones de tuberías|O|O||D||1|Remates para secciones de tuberías
40175309|Bridas de paleta para tubos|O|O||D||1
40181500|Tubos de cobre soldados|O|O||D||1
40181501|Tubo doblado de cobre soldado|O|O||D||1|Tubo curvado de cobre soldado
40181502|Tubo perforado de cobre soldado|O|O||D||1|Tubo agujerado de cobre soldado
40181503|Tubo de remate final de cobre soldado|O|O||D||1
40181504|Tubo multipuerto de cobre soldado|O|O||D||1
40181505|Tubo biselado de cobre soldado|O|O||D||1
40181506|Ensamblaje de tubos de cobre soldado|O|O||D||1
40181600|Tubos de latón soldados|O|O||D||1
40181601|Tubo doblado de latón soldada|O|O||D||1|Tubo curvado de latón soldada
40181602|Tubo perforado de latón soldada|O|O||D||1|Tubo agujerado de latón soldada
40181603|Tubo de remate final de latón soldada|O|O||D||1
40181604|Tubo multipuerto de latón soldada|O|O||D||1
40181605|Tubo biselado de latón soldada|O|O||D||1
40181606|Ensamblaje de tubos de latón soldada|O|O||D||1
40181700|Tubos de aluminio soldados|O|O||D||1
40181701|Tubo doblado de aluminio soldado|O|O||D||1|Tubo curvado de aluminio soldado
40181702|Tubo perforado de aluminio soldado|O|O||D||1|Tubo agujereado de aluminio soldado
40181703|Tubo de remate final de aluminio soldado|O|O||D||1
40181704|Tubo multipuerto de aluminio soldado|O|O||D||1
40181705|Tubo biselado de aluminio soldado|O|O||D||1
40181706|Ensamblaje de tubos de aluminio soldado|O|O||D||1
40181800|Tubos de acero soldados|O|O||D||1
40181801|Tubo doblado de acero soldado|O|O||D||1|Tubo curvado  de acero soldado
40181802|Tubo perforado de acero soldado|O|O||D||1|Tubo agujerado de acero soldado
40181803|Tubo de remate final de acero soldado|O|O||D||1
40181804|Tubo multipuerto de acero soldado|O|O||D||1
40181805|Tubo biselado de acero soldado|O|O||D||1
40181806|Ensamblaje de tubos de acero soldado|O|O||D||1
40181900|Tubos de acero inoxidable soldados|O|O||D||1
40181901|Tubo doblado de acero inoxidable soldado|O|O||D||1|Tubo curvado de acero inoxidable soldado
40181902|Tubo perforado de acero inoxidable soldado|O|O||D||1|Tubo agujereado de acero inoxidable soldado
40181903|Tubo de remate final de acero inoxidable soldado|O|O||D||1
40181904|Tubo multipuerto de acero inoxidable soldado|O|O||D||1
40181905|Tubo biselado de acero inoxidable soldado|O|O||D||1
40181906|Ensamblaje de tubos de acero inoxidable soldado|O|O||D||1
40182000|Tubos de cobre sin uniones|O|O||D||1
40182001|Tubo doblado de cobre sin uniones|O|O||D||1|Tubo curvado de cobre sin uniones
40182002|Tubo perforado de cobre sin uniones|O|O||D||1|Tubo agujerado de cobre sin uniones
40182003|Tubo de remate final de cobre sin uniones|O|O||D||1
40182004|Tubo multipuerto de cobre sin uniones|O|O||D||1
40182005|Tubo biselado de cobre sin uniones|O|O||D||1
40182006|Ensamblaje de tubos de cobre sin uniones|O|O||D||1
40182100|Tubos de latón sin uniones|O|O||D||1
40182101|Tubo doblado de latón sin uniones|O|O||D||1|Tubo curvado de latón sin uniones
40182102|Tubo perforado de latón sin uniones|O|O||D||1|Tubo agujerado de latón sin uniones
40182103|Tubo de remate final de latón sin uniones|O|O||D||1
40182104|Tubo multipuerto de latón sin uniones|O|O||D||1
40182105|Tubo biselado de latón sin uniones|O|O||D||1
40182106|Ensamblaje de tubos de latón sin uniones|O|O||D||1
40182200|Tubos de aluminio sin uniones|O|O||D||1
40182201|Tubo doblado de aluminio sin uniones|O|O||D||1|Tubo curvado de aluminio sin uniones
40182202|Tubo perforado de aluminio sin uniones|O|O||D||1|Tubo agujerado de aluminio sin uniones
40182203|Tubo de remate final de aluminio sin uniones|O|O||D||1
40182204|Tubo multipuerto de aluminio sin uniones|O|O||D||1
40182205|Tubo biselado de aluminio sin uniones|O|O||D||1
40182206|Ensamblaje de tubos de aluminio sin uniones|O|O||D||1
40182300|Tubos de acero sin uniones|O|O||D||1
40182301|Tubo doblado de acero sin uniones|O|O||D||1|Tubo curvado de acero sin uniones
40182302|Tubo perforado de acero sin uniones|O|O||D||1|Tubo agujerado de acero sin uniones
40182303|Tubo de remate final de acero sin uniones|O|O||D||1
40182304|Tubo multipuerto de acero sin uniones|O|O||D||1
40182305|Tubo biselado de acero sin uniones|O|O||D||1
40182306|Ensamblaje de tubos de acero sin uniones|O|O||D||1
40182400|Tubos de acero inoxidable sin uniones|O|O||D||1
40182401|Tubo doblado de acero inoxidable sin uniones|O|O||D||1|Tubo curvado de acero inoxidable sin uniones
40182402|Tubo perforado de acero inoxidable sin uniones|O|O||D||1|Tubo agujerado de acero inoxidable sin uniones
40182403|Tubo de remate final de acero inoxidable sin uniones|O|O||D||1
40182404|Tubo multipuerto de acero inoxidable sin uniones|O|O||D||1
40182405|Tubo biselado de acero inoxidable sin uniones|O|O||D||1
40182406|Ensamblaje de tubos de acero inoxidable sin uniones|O|O||D||1
40182500|Tubos de cobre extruidos|O|O||D||1
40182501|Tubo doblado de cobre extruido|O|O||D||1|Tubo curvado de cobre extruido
40182502|Tubo perforado de cobre extruido|O|O||D||1|Tubo agujerado de cobre extruido
40182503|Tubo de remate final de cobre extruido|O|O||D||1
40182504|Tubo multipuerto de cobre extruido|O|O||D||1
40182505|Tubo biselado de cobre extruido|O|O||D||1
40182506|Ensamblaje de tubos de cobre extruido|O|O||D||1
40182600|Tubos de latón extruidos|O|O||D||1
40182601|Tubo doblado de latón extruida|O|O||D||1|Tubo curvado de latón extruida
40182602|Tubo perforado de latón extruida|O|O||D||1|Tubo agujerado de latón extruida
40182603|Tubo de remate final de latón extruida|O|O||D||1
40182604|Tubo multipuerto de latón extruida|O|O||D||1
40182605|Tubo biselado de latón extruida|O|O||D||1
40182606|Ensamblaje de tubos de latón extruida|O|O||D||1
40182700|Tubos de aluminio extruidos|O|O||D||1
40182701|Tubo doblado de aluminio extruido|O|O||D||1|Tubo curvado de aluminio extruido
40182702|Tubo perforado de aluminio extruido|O|O||D||1|Tubo agujerado de aluminio extruido
40182703|Tubo de remate final de aluminio extruido|O|O||D||1
40182704|Tubo multipuerto de aluminio extruido|O|O||D||1
40182705|Tubo biselado de aluminio extruido|O|O||D||1
40182706|Ensamblaje de tubos de aluminio extruido|O|O||D||1
40182707|Tubería cubierta de aluminio extruido|O|O||D||1
40182800|Tubos de acero extruidos|O|O||D||1
40182801|Tubo doblado de acero extruido|O|O||D||1|Tubo curvado de acero extruido
40182802|Tubo perforado de acero extruido|O|O||D||1|Tubo agujerado de acero extruido
40182803|Tubo de remate final de acero extruido|O|O||D||1
40182804|Tubo multipuerto de acero extruido|O|O||D||1
40182805|Tubo biselado de acero extruido|O|O||D||1
40182806|Ensamblaje de tubos de acero extruido|O|O||D||1
40182900|Tubos de acero inoxidable extruidos|O|O||D||1
40182901|Tubo doblado de acero inoxidable extruido|O|O||D||1|Tubo curvado de acero inoxidable extruido
40182902|Tubo perforado de acero inoxidable extruido|O|O||D||1|Tubo agujerado de acero inoxidable extruido
40182903|Tubo de remate final de acero inoxidable extruido|O|O||D||1
40182904|Tubo multipuerto de acero inoxidable extruido|O|O||D||1
40182905|Tubo biselado de acero inoxidable extruido|O|O||D||1
40182906|Ensamblaje de tubos de acero inoxidable extruido|O|O||D||1
40183000|Tuberías de caucho y plástico|O|O||D||1
40183001|Tubería de caucho|O|O||D||1
40183002|Tubería de plástico pvc|O|O||D||1
40183003|Tubería de plástico cpvc|O|O||D||1
40183004|Tubería de plástico hdpe|O|O||D||1
40183005|Tubería de caucho de baja presión|O|O||D||1
40183006|Tubería termo contraíble|O|O||D||1
40183007|Tubería de espuma de caucho|O|O||D||1
40183008|Tubería de poliuretano pur|O|O||D||1
40183009|Tubería de manga trenzada|O|O||D||1
40183010|Tubería de alta presión con ensamblaje|O|O||D||1
40183100|Accesorios de tubos|O|O||D||1
40183101|Codo de tubo|O|O||D||1
40183102|“t” de tubo|O|O||D||1|Tubo en T
40183103|Unión de tubo|O|O||D||1
40183104|Tapón de tubo|O|O||D||1
40183105|Boquilla de tubo|O|O||D||1
40183106|Pistón de tubo|O|O||D||1
40183107|Acople de tubo|O|O||D||1
40183108|Casquillo de tubo|O|O||D||1
40183109|Adaptador de tubo|O|O||D||1
40183110|Conector de tubo|O|O||D||1
40183111|Cruz de tubo|O|O||D||1|Tubo en cruz
40183112|Reductor de tubo|O|O||D||1
41101500|Equipo y suministros para la mezcla, la dispersión y la homogeneización en laboratorio|O|O||D||1
41101502|Bolsas “stomachers”|O|O||D||1|Homogeneizador con palas o bolsas para laboratorio
41101503|Rociadores de laboratorio|O|O||D||1|Pulverizadores de laboratorio
41101504|Homogeneizadores|O|O||D||1
41101505|Celdas de presión francesas|O|O||D||1|Homogeneizador celular por presión (prensa francesa)
41101515|Latas medidoras de líquido|O|O||D||1|Bidones
41101516|Homogeneizadores dobles|O|O||D||1|Homogeneizador de tejidos
41101518|Mezcladores o emulsificadores de laboratorio|O|O||D||1
41101700|Equipo de perforación, amoladura, corte, trituración y prensado para laboratorio|O|O||D||1
41101701|Molinos de laboratorio|O|O||D||1|Molinos para laboratorio
41101702|Pilones y morteros|O|O||D||1
41101703|Moledoras de tejidos|O|O||D||1|Homogeneizador para muestras pequeñas
41101705|Trituradoras o pulverizadoras de laboratorio|O|O||D||1
41101706|Desintegradores de laboratorio|O|O||D||1
41101707|Prensas de laboratorio|O|O||D||1
41101708|Esmeriladora o pulidora de laboratorio|O|O||D||1
41101709|Mezcladora de asfalto y concreto de laboratorio|O|O||D||1|Mezclador de laboratorio para asfalto y concreto (hormigón)
41101800|Equipo de física de electrones y de estado sólido para laboratorio|O|O||D||1
41101801|Pistolas de electrones|O|O||D||1
41101802|Generadores de rayos x|O|O||D||1
41101803|Coulómetros|O|O||D||1
41101804|Electroscopios|O|O||D||1
41101805|Flujómetros|O|O||D||1
41101806|Magnetómetros|O|O||D||1
41101807|Aparatos de difracción de electrones|O|O||D||1
41101808|Aparatos de difracción de neutrones|O|O||D||1
41101809|Aparatos de difracción óptica|O|O||D||1
41101810|Difractómetros|O|O||D||1
41101811|Micro analizador de sondeo de electrones por rayos x|O|O||D||1
41101812|Acelerador de partículas|O|O||D||1
41101813|Controlador de equipos de rayos x de laboratorio|O|O||D||1
41101900|Equipo iónico de laboratorio|O|O||D||1
41101901|Fuentes de iones|O|O||D||1
41101902|Aparatos de intercambio de iones|O|O||D||1
41101903|Equipos de implantación de iones|O|O||D||1
41102400|Equipo de calefacción y secadores para laboratorio|O|O||D||1
41102401|Quemadores de gas|O|O||D||1|Mecheros de gas
41102402|Quemadores de alcohol|O|O||D||1|Mecheros de alcohol
41102403|Incineradores de laboratorio|O|O||D||1
41102404|Calentadores de laboratorio|O|O||D||1
41102405|Revestimientos o cintas calentadoras|O|O||D||1
41102406|Hornillas eléctricas de laboratorio|O|O||D||1
41102407|Gabinetes calentadores|O|O||D||1
41102410|Secadoras infrarrojas|O|O||D||1
41102412|Secadores de aire caliente|O|O||D||1
41102421|Cámaras de reciclaje de temperatura o recicladores térmicos|O|O||D||1|Cámara de ciclos de temperatura, Termocicladores
41102422|Baños secos o bloques calentadores|O|O||D||1
41102423|Hornillas eléctricas agitadoras|O|O||D||1
41102424|Calentadores de deslizamiento|O|O||D||1|Calentadores de muestras
41102425|Secadores de deslizamiento|O|O||D||1|Secador de muestras
41102426|Equipos o accesorios para calentar o secar|O|O||D||1
41102427|Torre secadora|O|O||D||1
41102428|Papel altamente absorbente|O|O||D||1
41102429|Sellador por calor de unidades de tubos de muestras de sangre|O|O||D||1
41102500|Equipo entomológico para laboratorio y accesorios|O|O||D||1
41102501|Contenedores de insectos para laboratorio|O|O||D||1
41102502|Instalaciones de crianza para entomología|O|O||D||1
41102503|Textiles o redes para entomología|O|O||D||1
41102504|Equipo de entomología para clavar especímenes|O|O||D||1
41102505|Materiales de ensamblaje para entomología|O|O||D||1
41102506|Bandejas de entomología|O|O||D||1
41102507|Equipo para recolectar especímenes de entomología|O|O||D||1
41102508|Aspiradoras para entomología|O|O||D||1
41102509|Cucharones para entomología|O|O||D||1
41102510|Mono copas para entomología|O|O||D||1
41102511|Trampas pegajosas para entomología|O|O||D||1
41102512|Kits de pruebas para insectos|O|O||D||1
41102513|Unidades de despliegue para entomología|O|O||D||1
41102600|Equipo y accesorios para laboratorio animal|O|O||D||1
41102601|Jaulas para animales pequeños para laboratorio|O|O||D||1
41102602|Equipo de acuarios|O|O||D||1
41102603|Suministros para identificación de animales|O|O||D||1
41102604|Dispositivos para atrapar animales|O|O||D||1
41102605|Sistemas de aireación de peces|O|O||D||1
41102606|Restricciones o arneses para animales para laboratorio|O|O||D||1
41102607|Agujas para alimentar animales|O|O||D||1
41102608|Equipos para pruebas de animales|O|O||D||1
41102609|Pistola anestésica|O|O||D||1
41102700|Equipo de cristalografía|O|O||D||1
41102701|Modelos de enrejados de cristal|O|O||D||1
41102702|Ensamblajes de cristales centellantes|O|O||D||1
41102703|Equipo de dispersión de luz|O|O||D||1
41102704|Equipo de difracción de rayos x|O|O||D||1
41102705|Cristalizadores|O|O||D||1
41102706|Equipo de crecimiento de cristal|O|O||D||1
41102900|Equipo de histología|O|O||D||1
41102901|Estaciones de incrustación de tejidos|O|O||D||1
41102902|Moldes de incrustación|O|O||D||1
41102903|Cápsulas de incrustación|O|O||D||1
41102904|Compuestos de incrustación|O|O||D||1
41102905|Aparatos de teñido histológico|O|O||D||1
41102909|Procesadores de tejidos|O|O||D||1
41102910|Aparatos de cultivo de tejidos|O|O||D||1
41102911|Cuchillos o sujeta cuchillos o cuchillas histológicos|O|O||D||1
41102912|Cuchillos marcadores de vidrio histológicos|O|O||D||1
41102913|Afiladores o correas o compuestos histológicos|O|O||D||1
41102914|Desintegradores ultrasónicos|O|O||D||1
41102915|Estaciones de muestreo y disección histológica|O|O||D||1
41102916|Micrótomos|O|O||D||1
41102917|Cuchillas para micrótomos|O|O||D||1
41102918|Forros deslizantes para laboratorio|O|O||D||1
41102919|Recicladores de solventes|O|O||D||1
41102920|Casetes para tejidos para histología|O|O||D||1
41102921|Parafina para histología|O|O||D||1
41102922|Equipo de forros deslizantes automatizado|O|O||D||1
41102923|Contador de celdas somático|O|O||D||1
41102924|Etiquetador de casetes de tejidos automatizado|O|O||D||1
41102925|Arcador permanente resistente a la formalina y al solvente para histología|O|O||D||1|Fijadores histológicos
41102926|Tolva de casetes de tejidos para histología|O|O||D||1
41102927|Implemento para procesar tejidos para histología|O|O||D||1
41103000|Equipo de enfriamiento para laboratorio|O|O||D||1
41103001|Sondas planas enfriadoras refrigeradas|O|O||D||1
41103003|Criostatos|O|O||D||1
41103004|Hornos de circulación por ventilador|O|O||D||1
41103005|Gabinetes o congeladores ultra fríos o ultra bajos independientes|O|O||D||1
41103006|Congeladores criogénicos o de nitrógeno líquido|O|O||D||1
41103007|Unidades de enfriamiento o circuladores de agua fría|O|O||D||1
41103008|Módulos enfriadores refrigerados|O|O||D||1
41103010|Refrigeradores para bancos de sangre|O|O||D||1
41103011|Refrigeradores para propósitos generales o neveras congeladores|O|O||D||1
41103012|Refrigeradores o neveras congeladores para almacenar material inflamable|O|O||D||1
41103013|Refrigeradores o neveras congeladores a prueba de explosiones|O|O||D||1
41103014|Refrigeradores de cromatografía|O|O||D||1
41103015|Congeladores para bancos de sangre|O|O||D||1
41103017|Congeladores para almacenar material inflamable|O|O||D||1
41103019|Congeladores para almacenar plasma|O|O||D||1
41103020|Congeladores de cofre ultra fríos o ultra bajos|O|O||D||1
41103021|Congeladores planos para laboratorio|O|O||D||1
41103022|Transporte o almacenamiento frío|O|O||D||1
41103023|Enfriadores para laboratorio|O|O||D||1
41103024|Trampas frías|O|O||D||1
41103025|Accesorios para equipos enfriadores de laboratorio|O|O||D||1
41103026|Cubeta de hielo o contenedor enfriador para mesa de trabajo|O|O||D||1
41103027|Cabina de almacenamiento de unidades de sangre|O|O||D||1
41103200|Equipo de lavado de laboratorio|O|O||D||1
41103201|Lavadoras de ingeniería química|O|O||D||1
41103202|Máquinas lavadoras para laboratorio|O|O||D||1
41103203|Lavadoras de pipetas|O|O||D||1
41103205|Estantes o accesorios para máquinas lavadoras|O|O||D||1
41103206|Detergentes de lavado para laboratorios|O|O||D||1
41103207|Lavadoras de micro placas|O|O||D||1
41103208|Lavadoras de celdas de bancos de sangre|O|O||D||1
41103209|Botellas de lavado de laboratorios|O|O||D||1
41103210|Esterilizadores uv ultravioleta para laboratorios|O|O||D||1|Sistema esterilizador con filtro UV
41103211|Equipos para el tratamiento de aguas residuales de laboratorio|O|O||D||1
41103212|Cepillo limpiador de cristalería de laboratorio|O|O||D||1
41103300|Equipo de mecánica de fluidos|O|O||D||1
41103301|Contadores centellantes líquidos|O|O||D||1
41103302|Hidrómetros ácidos de batería|O|O||D||1
41103303|Densitómetros|O|O||D||1
41103305|Equipos de alto vacío|O|O||D||1
41103306|Equipos de vacío neumático|O|O||D||1
41103307|Equipos de vacío o vapor de mercurio|O|O||D||1
41103308|Aparatos de combustión de alto vacío|O|O||D||1
41103309|Equipos de análisis de inyección de flujo|O|O||D||1
41103310|Instrumentos para medir la concentración de gas o vapor|O|O||D||1
41103311|Manómetros|O|O||D||1
41103312|Viscosímetros|O|O||D||1
41103313|Indicadores de profundidad|O|O||D||1
41103314|Aparatos de estimación de estructura microscópica|O|O||D||1
41103315|Aparatos de estimación de fuerza de una solución|O|O||D||1
41103316|Picnómetros|O|O||D||1
41103317|Instrumentos para medir la tensión de la superficie|O|O||D||1
41103318|Densitómetro nuclear|O|O||D||1
41103319|Instrumento para medir la concentración|O|O||D||1
41103320|Instrumento para medir la densidad|O|O||D||1
41103321|Aparatos para medir la estabilidad de cuerpos flotantes|O|O||D||1
41103322|Evaluador de corriente de aire|O|O||D||1|Anemómetro
41103323|Flujómetro acústico de canal abierto|O|O||D||1
41103324|Generador de ondas para laboratorio|O|O||D||1
41103325|Aparato de visualización de flujo de fluido|O|O||D||1
41103326|Túnel de viento|O|O||D||1
41103327|Medidor de corriente|O|O||D||1
41103400|Equipo de acondicionamiento ambiental para laboratorio|O|O||D||1
41103401|Pantallas de control de contaminación|O|O||D||1
41103403|Equipos de control de aire microbiológico|O|O||D||1
41103406|Cajas de guantes de aislamiento|O|O||D||1
41103407|Cámara anaeróbica|O|O||D||1
41103408|Alcance refrigerado para cámaras ambientales o de cultivo|O|O||D||1
41103409|Alcance caliente para cámaras ambientales o de cultivo|O|O||D||1
41103410|Alcance refrigerado y caliente para cámaras ambientales y de cultivo|O|O||D||1
41103411|Camino refrigerado para cámaras ambientales o de cultivo|O|O||D||1
41103412|Camino caliente para cámaras ambientales o de cultivo|O|O||D||1
41103413|Camino refrigerado y caliente para cámaras ambientales o de cultivo|O|O||D||1
41103414|Accesorios para equipos acondicionadores de ambiente para laboratorios|O|O||D||1
41103415|Bancos limpios|O|O||D||1
41103416|Cámara de ciclos de temperatura|O|O||D||1
41103417|Monitor de calidad del aire interior|O|O||D||1
41103418|Cámara ambiental de temperatura y humedad a la que se puede entrar|O|O||D||1|Cámara climática
41103419|Cámara de polución ambiental|O|O||D||1|Cámara de contaminación ambiental
41103420|Cámara de ozono ambiental|O|O||D||1
41103421|Cámara de explosión ambiental|O|O||D||1
41103500|Recintos cerrados de laboratorio y accesorios|O|O||D||1
41103501|Ebullómetro|O|O||D||1
41103502|Caperuzas o cajones para gases|O|O||D||1
41103504|Gabinetes o estaciones para flujo laminar|O|O||D||1
41103506|Cerramientos pcr|O|O||D||1
41103507|Cerramientos hepa filtrados|O|O||D||1
41103508|Cerramientos carbono filtrados|O|O||D||1
41103509|Estropajos para laboratorio|O|O||D||1
41103510|Secadores para laboratorio|O|O||D||1
41103511|Accesorios de cerramiento para laboratorio|O|O||D||1
41103512|Eliminadores de estática|O|O||D||1
41103513|Cerramientos para cultivo de tejidos|O|O||D||1
41103514|Generador de vapor para laboratorio|O|O||D||1
41103515|Generador de gas para laboratorio|O|O||D||1
41103516|Capucha de ventilación|O|O||D||1
41103700|Cubetas de laboratorio|O|O||D||1
41103701|Baños de circulación|O|O||D||1
41103702|Baños termostáticos|O|O||D||1
41103703|Baños múltiples|O|O||D||1
41103704|Baños biológicos|O|O||D||1
41103705|Baños para órganos|O|O||D||1
41103706|Baños de agua|O|O||D||1
41103707|Baños de aceite|O|O||D||1
41103708|Baños de arena|O|O||D||1
41103709|Baños refrigerados|O|O||D||1
41103710|Baños de agua de agitación orbital|O|O||D||1
41103711|Baños de agua de agitación recíproca|O|O||D||1
41103712|Circuladores de inmersión|O|O||D||1
41103713|Baños de viscosidad|O|O||D||1
41103714|Baños de flotación de tejidos|O|O||D||1
41103715|Accesorios o suministros para baños de laboratorio|O|O||D||1
41103716|Baños para descongelar plasma de bancos de sangre|O|O||D||1
41103717|Baños para cultivos de tejidos|O|O||D||1
41103800|Equipo y suministros para la mezcla y la agitación por sacudida o varillas en laboratorio|O|O||D||1
41103801|Mezcladores de laboratorio|O|O||D||1
41103802|Mezcladores de rodillo|O|O||D||1
41103803|Mesas para revolver|O|O||D||1
41103804|Equipo multi banco o de floculación|O|O||D||1
41103805|Vibradores para laboratorio|O|O||D||1
41103806|Agitador magnético|O|O||D||1
41103807|Mezcladores de toque para laboratorio|O|O||D||1
41103808|Mezcladores de plaqueta|O|O||D||1
41103809|Mezcladores químicos o de hematología|O|O||D||1
41103810|Agitadores de techo|O|O||D||1
41103811|Sacudidores orbitales|O|O||D||1
41103812|Sacudidores recíprocos|O|O||D||1
41103813|Sacudidores de rotación|O|O||D||1
41103814|Mezcladores de vértice|O|O||D||1
41103815|Rotadores de tubos|O|O||D||1
41103816|Accesorios o aditamentos para mezcladores o sacudidores|O|O||D||1
41103817|Reactor de laboratorio|O|O||D||1
41103900|Centrifugadoras de laboratorio y accesorios|O|O||D||1
41103901|Micro centrífugas|O|O||D||1
41103902|Micro centrífugas refrigeradas|O|O||D||1
41103903|Centrífugas de mesa|O|O||D||1
41103904|Centrífugas de mesa refrigeradas|O|O||D||1
41103905|Centrífugas de piso|O|O||D||1
41103906|Centrífugas de piso refrigeradas|O|O||D||1
41103907|Ultra centrífugas|O|O||D||1
41103908|Centrífugas de vacío|O|O||D||1
41103909|Rotores de centrífugas|O|O||D||1
41103910|Baldes centrífugos|O|O||D||1
41103911|Adaptadores para centrífugas|O|O||D||1
41103912|Cepillos para centrífugas|O|O||D||1
41103913|Accesorios para centrífugas de laboratorio|O|O||D||1
41103914|Citocentrífuga|O|O||D||1
41104000|Equipo de toma de muestras|O|O||D||1
41104001|Cambiadores de muestras|O|O||D||1
41104002|Oxidante de muestras|O|O||D||1
41104003|Línea de preparación de muestras|O|O||D||1
41104004|Bombas de preparación de muestras|O|O||D||1
41104005|Achicadores para laboratorio|O|O||D||1
41104006|Coliwasas (muestreadores de desechos líquidos de compostaje)|O|O||D||1
41104007|Muestreadores de agua|O|O||D||1
41104008|Muestreadores o colectores de aire|O|O||D||1
41104009|Bombas muestreadoras de aire|O|O||D||1
41104010|Kits de reactivos para usar con muestreadores de aire|O|O||D||1
41104011|Filtros u otras partes de repuesto para muestreadores|O|O||D||1
41104012|Recogedores o frascos para polvo|O|O||D||1
41104013|Muestreadores de dióxido de sulfuro o de humo|O|O||D||1
41104014|Aplicadores de muestras|O|O||D||1
41104015|Equipo de análisis de muestras de plantas|O|O||D||1
41104016|Muestreadores de polución de aire|O|O||D||1
41104017|Contenedores para muestras|O|O||D||1
41104018|Preparaciones para extracción de fase sólida|O|O||D||1
41104019|Colectores de muestras|O|O||D||1
41104020|Bandeja de flujo de elemento calcino|O|O||D||1
41104021|Colector de fracciones|O|O||D||1
41104022|Formador de muestras|O|O||D||1
41104100|Contenedores de recogida y transporte de especímenes, y suministros|O|O||D||1
41104101|Sobres o empaques para especímenes o láminas de muestras|O|O||D||1
41104102|Lancetas|O|O||D||1
41104103|Calentadores de pivote|O|O||D||1
41104104|Torniquetes|O|O||D||1
41104105|Bolsas para recolectar o transportar especímenes|O|O||D||1
41104106|Bandejas o accesorios de flebotomía|O|O||D||1
41104107|Tubos de recolección o contenedores de sangre al vacío|O|O||D||1
41104108|Tubos de recolección o contenedores de sangre no al vacío|O|O||D||1
41104109|Bolsas de recolección de unidades de sangre|O|O||D||1
41104110|Botellas de cultivo de sangre|O|O||D||1
41104111|Kits o contenedores de recolección de citologías|O|O||D||1
41104112|Contenedores de recolección de orina|O|O||D||1
41104114|Contenedores de recolección frepp sepp|O|O||D||1
41104115|Contenedores de recolección de filtro de suero|O|O||D||1
41104116|Contenedores de recolección o transporte de frotis|O|O||D||1
41104117|Porta especímenes|O|O||D||1
41104118|Contenedor de recolección de especímenes|O|O||D||1
41104119|Contenedores de recolección de tejido óseo|O|O||D||1
41104120|Tubos de tasa de sedimentación|O|O||D||1
41104121|Contenedores con medio químico para recolección de heces|O|O||D||1
41104122|Contenedores sin medio químico para recolección de heces|O|O||D||1
41104123|Aparatos o contenedores para recolección de esputos|O|O||D||1
41104124|Bandejas de biopsia de médula de hueso para laboratorio|O|O||D||1
41104125|Contenedor de preservación de especímenes para histología o patología|O|O||D||1
41104126|Contenedor de especímenes de histología o patología|O|O||D||1
41104127|Alimentador para laboratorio|O|O||D||1
41104128|Recolector de especímenes de cultivo sin frotis|O|O||D||1
41104129|Tarjeta de recolección de monitoreo de desórdenes metabólicos neonatales|O|O||D||1
41104200|Equipo y suministros de purificación de agua para laboratorio|O|O||D||1
41104201|Reactivos de purificación del agua|O|O||D||1
41104202|Equipos de deionización o desmineralización|O|O||D||1
41104203|Equipos de intercambio de base|O|O||D||1
41104204|Equipos de ósmosis inversa|O|O||D||1
41104205|Unidades ultra violeta de purificación de agua|O|O||D||1
41104206|Sistemas de agua ultra pura|O|O||D||1
41104207|Sistemas de análisis de agua|O|O||D||1
41104208|Deshidratadores|O|O||D||1
41104209|Desoxidantes|O|O||D||1
41104210|Disolventes|O|O||D||1
41104211|Suavizantes|O|O||D||1
41104212|Cartuchos de filtración de agua|O|O||D||1
41104213|Agua destilada o deionizada|O|O||D||1
41104300|Equipo de fermentación|O|O||D||1
41104301|Unidades de fermentación estándar|O|O||D||1
41104302|Aparatos de cultivo continuo|O|O||D||1
41104303|Jarros o accesorios anaeróbicos|O|O||D||1
41104304|Sistemas digestivos|O|O||D||1
41104305|Condensadores (espesantes)|O|O||D||1
41104306|Equipos para cultivos in vitro|O|O||D||1
41104307|Equipos para fermentación microbiológica|O|O||D||1
41104308|Sistemas o suministros para cultivos ambientales anaeróbicos|O|O||D||1
41104400|Equipo de incubación de laboratorio|O|O||D||1
41104401|Incubadoras para uso general de convección de gravedad|O|O||D||1
41104402|Incubadoras de uso general de aire forzado o convección mecánica|O|O||D||1
41104403|Incubadoras para cultivo de tejidos|O|O||D||1
41104404|Incubadoras de demanda de oxígeno biológico bod enfriadas|O|O||D||1
41104405|Incubadoras de agitación|O|O||D||1
41104406|Incubadoras planas|O|O||D||1
41104407|Incubadoras de cámara única de dióxido de carbono recubierta de agua|O|O||D||1
41104408|Incubadoras de cámara dual de dióxido de carbono recubierta de agua|O|O||D||1
41104409|Incubadoras de cámara única de dióxido de carbono recubierta de agua con control de humedad|O|O||D||1
41104410|Incubadoras de cámara dual de dióxido de carbono recubierta de agua con control de humedad|O|O||D||1
41104411|Incubadoras de cámara única de dióxido de carbono de pared seca|O|O||D||1
41104412|Incubadoras de cámara dual de dióxido de carbono de pared seca|O|O||D||1
41104413|Incubadoras de cámara única de dióxido de carbono de pared seca con control de humedad|O|O||D||1
41104414|Incubadoras de cámara dual de dióxido de carbono de pared seca con control de humedad|O|O||D||1
41104415|Incubadoras de cámara única de tres gases recubierta de agua|O|O||D||1
41104416|Incubadoras de cámara dual de tres gases recubierta de agua|O|O||D||1
41104417|Incubadoras de cámara única de tres gases recubierta de agua con control de humedad|O|O||D||1
41104418|Incubadoras de cámara dual de tres gases recubierta de agua con control de humedad|O|O||D||1
41104419|Incubadoras de cámara única de tres gases de pared seca|O|O||D||1
41104420|Incubadoras de cámara dual de tres gases de pared seca|O|O||D||1
41104421|Incubadoras de cámara única de tres gases de pared seca con control de humedad|O|O||D||1
41104422|Incubadoras de cámara dual de tres gases de pared seca con control de humedad|O|O||D||1
41104423|Incubadoras refrigeradas|O|O||D||1
41104424|Accesorios para incubadoras|O|O||D||1
41104425|Incubadora de dióxido de carbono|O|O||D||1
41104426|Aparatos para preparación de medios|O|O||D||1
41104427|Incubadora de plaqueta|O|O||D||1
41104500|Estufas de laboratorio y accesorios|O|O||D||1
41104501|Hornos de convección mecánica para laboratorio|O|O||D||1
41104502|Hornos de convección de gravedad|O|O||D||1
41104503|Hornos de envejecimiento|O|O||D||1
41104504|Hornos de limpieza de espacio|O|O||D||1|Horno de laboratorio
41104505|Recipientes de cuarzo para horno para laboratorio|O|O||D||1
41104506|Hornos de seguridad para laboratorios|O|O||D||1
41104507|Hornos microondas para laboratorio|O|O||D||1
41104508|Secadoras de inducción|O|O||D||1
41104509|Hornos al vacío|O|O||D||1
41104510|Hornos o gabinetes secadores|O|O||D||1
41104511|Hornos o incubadoras de hibridación|O|O||D||1
41104512|Accesorios para hornos de laboratorio|O|O||D||1
41104513|Horno para derretir magnesio|O|O||D||1
41104600|Hornos de laboratorio y accesorios|O|O||D||1
41104601|Hornos de caja para laboratorio|O|O||D||1
41104602|Hornos de caja programables|O|O||D||1
41104603|Hornos de tubo|O|O||D||1
41104604|Hornos de tubo programables|O|O||D||1
41104605|Hornos de crisol|O|O||D||1
41104606|Hornos de crisol programables|O|O||D||1
41104607|Consola de control de calderas|O|O||D||1
41104608|Consola de control de calderas programables|O|O||D||1
41104609|Hornos de seguridad para laboratorio|O|O||D||1
41104610|Crisoles para hornos de laboratorio|O|O||D||1
41104611|Aislamiento de repuesto para calderas de laboratorio|O|O||D||1
41104612|Accesorios para calderas de laboratorio|O|O||D||1
41104613|Prensa caliente para laboratorio|O|O||D||1
41104700|Secadoras por congelación y liofilizadores de laboratorio, y accesorios|O|O||D||1
41104701|Secadores de congelación o liofolizantes|O|O||D||1
41104702|Cristalería para secadores de congelación|O|O||D||1
41104703|Secadores de bandeja|O|O||D||1
41104704|Accesorios para secadores de congelación o liofolizantes|O|O||D||1
41104800|Equipo y suministros de laboratorio para el vertido, la destilación, la evaporación y la extracción|O|O||D||1
41104801|Unidades de redomas o retortas|O|O||D||1
41104802|Unidades de bi destilación|O|O||D||1|Unidades de destilación Bi
41104803|Evaporadores para laboratorio|O|O||D||1|Evaporador para laboratorio
41104804|Evaporadores de vacío o rotatorios|O|O||D||1|Evaporador de vacío o rotatorios
41104805|Evaporadores de purga de nitrógeno|O|O||D||1|Evaporador de purga de nitrógeno
41104806|Equipo de extracción para laboratorios|O|O||D||1
41104807|Extractores de grasa|O|O||D||1
41104808|Extractores de fibra cruda|O|O||D||1
41104809|Unidad de análisis de sedimentación|O|O||D||1
41104810|Aparatos de fraccionamiento|O|O||D||1
41104811|Fraccionadores de densidad gradiente|O|O||D||1
41104812|Pipetas o columnas o accesorios de destilación|O|O||D||1
41104813|Componentes de reflujo|O|O||D||1
41104814|Condensadores intercambiadores de calor para laboratorio|O|O||D||1
41104815|Aparatos “kjeldahl” para la determinación de nitrógeno|O|O||D||1
41104816|Concentradores centrífugos o de vacío|O|O||D||1
41104817|Casquillos de extracción|O|O||D||1
41104818|Empaques estructurados (para uso en columnas de destilación y reactivos químicos)|O|O||D||1
41104819|Cosechadora de células|O|O||D||1|Cultivo celular
41104820|Aparatos de destilación fraccional para laboratorios|O|O||D||1
41104821|Concentrador de muestras estáticas|O|O||D||1
41104900|Equipo y suministros de filtrado para laboratorio|O|O||D||1
41104901|Filtros de línea para laboratorio|O|O||D||1
41104902|Equipos de filtración de gel|O|O||D||1
41104903|Equipos de ultra filtración|O|O||D||1
41104904|Filtros de células aglomeradas|O|O||D||1
41104905|Equipos de filtración de canal angosto|O|O||D||1
41104906|Equipos de filtración de ósmosis inversa|O|O||D||1
41104907|Equipos de filtración molecular|O|O||D||1
41104908|Elementos de filtración de cartucho para laboratorios|O|O||D||1
41104909|Sujeta filtros o ciclones para laboratorios|O|O||D||1
41104910|Filtros multi hoja o de prensa para laboratorios|O|O||D||1
41104911|Sistemas de filtración de aire para laboratorios|O|O||D||1
41104912|Filtro de prensas de fluido|O|O||D||1
41104913|Filtros de bio separación|O|O||D||1
41104914|Tazas o botellas de filtración|O|O||D||1
41104915|Filtros de cápsulas|O|O||D||1
41104916|Filtros centrífugos|O|O||D||1
41104917|Filtros ambientales para laboratorio|O|O||D||1
41104918|Filtros de vidrio para laboratorio|O|O||D||1
41104919|Filtros hepa para laboratorio|O|O||D||1
41104920|Filtros de hibridación|O|O||D||1
41104921|Filtros de membrana para laboratorio|O|O||D||1
41104922|Filtros de jeringa|O|O||D||1
41104923|Filtros de plato multipocillo|O|O||D||1
41104924|Filtros de microbiología|O|O||D||1
41104925|Hardware de filtración o accesorios para laboratorio|O|O||D||1
41104926|Filtro de cama de sílice|O|O||D||1
41104927|Pantallas de soporte para filtros|O|O||D||1
41104928|Receptor de botellas para laboratorio|O|O||D||1
41104929|Papeles filtrantes para laboratorio|O|O||D||1
41104930|Cernidor molecular|O|O||D||1|Tamiz Moleculares
41105000|Equipo y suministros de tamizado y cribado para laboratorio|O|O||D||1
41105001|Separadores para laboratorio|O|O||D||1
41105002|Equipo de tamizaje para laboratorio|O|O||D||1
41105003|Cernidores de prueba|O|O||D||1
41105100|Bombas y conductos de laboratorio|O|O||D||1
41105101|Bombas de vacío para laboratorio|O|O||D||1|Bomba de vacío para laboratorio
41105102|Bombas peristálticas|O|O||D||1|Bomba peristálticas
41105103|Bombas centrífugas para laboratorio|O|O||D||1|Bomba centrífugas para laboratorio
41105104|Bombas de jeringa|O|O||D||1|Bomba de jeringa
41105105|Bombas de medición|O|O||D||1|Bomba de medición
41105106|Bombas de cromatografía|O|O||D||1|Bomba de cromatografía
41105107|Bombas de tambor para laboratorio|O|O||D||1|Bomba de tambor para laboratorio
41105108|Tubos de uso general para laboratorio|O|O||D||1|Tubo de uso general para laboratorio
41105109|Bombas de aleta rotativa|O|O||D||1|Bomba de aleta rotativa
41105200|Equipo de teñido de portaobjetos de laboratorio y accesorios|O|O||D||1
41105201|Equipo para teñir muestras de histología o citología|O|O||D||1
41105202|Equipo para teñir muestras de hematología|O|O||D||1
41105203|Equipo para teñir muestras de microbiología|O|O||D||1
41105204|Accesorios para equipos para teñir muestras de laboratorio|O|O||D||1
41105205|Equipo para preparar micro muestras|O|O||D||1
41105206|Equipo inmuno-histo-químico automático para teñir|O|O||D||1
41105207|Accesorios para equipo inmuno-histo-químico automático para teñir|O|O||D||1
41105208|Estante y bandeja para teñir muestras para laboratorio|O|O||D||1
41105209|Set para teñir muestras manualmente multi departamental|O|O||D||1
41105300|Sistemas de electroforesis y transferencia para laboratorio y suministros|O|O||D||1
41105301|Cajas de gel|O|O||D||1
41105302|Secadores de gel|O|O||D||1
41105303|Suministros para el sistema de energía de electroforesis|O|O||D||1
41105304|Transiluminadores|O|O||D||1
41105305|Accesorios para el sistema de electroforesis|O|O||D||1
41105307|Instrumental para electroforesis capilar|O|O||D||1
41105308|Capilares o cartuchos|O|O||D||1
41105309|Kits o reactivos para electroforesis capilar|O|O||D||1
41105310|Accesorios para bloquear o transferir|O|O||D||1
41105311|Aparatos para bloquear o transferir|O|O||D||1
41105312|Peinillas o platos o espaciadores o bandejas|O|O||D||1
41105313|Casetes de detección o accesorios relacionados|O|O||D||1
41105314|Sistemas de documentación de gel|O|O||D||1
41105315|Accesorios de documentación de gel|O|O||D||1
41105316|Entrecruzadores ultravioleta|O|O||D||1
41105317|Reactivos para preparar geles de agarosa|O|O||D||1
41105318|Geles de agarosa prefabricados|O|O||D||1
41105319|Reactivos para preparar gel poliacrilamida|O|O||D||1
41105320|Geles de poliacrilamida pre fabricados|O|O||D||1
41105321|Tintura para geles ácido nucleicos|O|O||D||1
41105322|Tintura para geles poliacrilamidas|O|O||D||1
41105323|Zonas o soluciones prefabricadas para electroforesis|O|O||D||1
41105324|Sondas para ácido desoxirribonucleico dna o ácido ribonucleico rna|O|O||D||1
41105325|Placas micropocillo para hibridación de ácido desoxirribonucleico dna o ácido ribonucleico rna|O|O||D||1
41105326|Agentes reactivos o zonas para hibridación|O|O||D||1
41105327|Nucleótidos u oligómeros conjugados|O|O||D||1
41105328|Northern blot o southern blot o western blot prefabricadas|O|O||D||1
41105329|Agentes bloqueadores|O|O||D||1
41105330|Proteínas de control o lisados celulares o lisados de tejidos|O|O||D||1
41105331|Reactivos o kits o sustratos de detección quimio fluorescente de proteínas|O|O||D||1
41105332|Reactivos o kits o sustratos de detección quimio luminiscente de proteínas|O|O||D||1
41105333|Reactivos o kits o sustratos de detección cromogénica de proteínas|O|O||D||1
41105334|Marcadores de cuantificación de ácido desoxirribonucleico dna|O|O||D||1
41105335|Marcadores de tamaño o estándares de ácido desoxirribonucleico dna|O|O||D||1
41105336|Marcadores de foco isoeléctrico ief|O|O||D||1
41105337|Marcadores de electroforesis de proteína|O|O||D||1
41105338|Marcadores o estándares de ácido ribonucleico rna|O|O||D||1
41105339|Membranas de transferencia por adsorción|O|O||D||1
41105340|Sistema de electroforesis|O|O||D||1
41105341|Película de auto radiografía|O|O||D||1
41105500|Kits y componentes de extracción, purificación y cuantificación de ácidos nucleicos|O|O||D||1
41105501|Kits de extracción de gel o limpiadores de ácido desoxirribonucleico dna|O|O||D||1
41105502|Kits para extrae ácido desoxirribonucleico dna de alimentos|O|O||D||1
41105503|Sistemas de electro elución|O|O||D||1
41105504|Kits de purificación de ácido desoxirribonucleico dna genómico|O|O||D||1
41105505|Sistemas de selección de alto rendimiento hts en purificación de ácido nucleico|O|O||D||1
41105506|Kits para purificación de ácido ribonucleico mensajero mrna|O|O||D||1
41105507|Glóbulos magnéticos para aislar ácido nucleico|O|O||D||1
41105508|Co-precipitantes de ácidos nucleicos|O|O||D||1
41105509|Kits de cuantificación de ácidos nucleicos|O|O||D||1
41105510|Kits de purificación de fagos de ácido desoxirribonucleico dna|O|O||D||1
41105511|Kits para extracción de plásmidos de ácido desoxirribonucleico dna de la levadura|O|O||D||1
41105512|Kit de purificación de plásmidos o cósmidos o cromosomas bacterianos artificiales bac|O|O||D||1
41105513|Kits de purificación de ácido nucleico etiquetado|O|O||D||1
41105514|Reactivos para extracción o precipitación o re suspensión de ácido nucleico|O|O||D||1
41105515|Materiales de estabilización o limpieza de ácido ribonucleico|O|O||D||1
41105516|Kits de extracción de gel de ácido ribonucleico rna|O|O||D||1
41105517|Kits para extracción de ácido nucleico de células o tejidos de plantas|O|O||D||1
41105518|Kits de purificación de ácido ribonucleico rna total|O|O||D||1
41105519|Kits de purificación de ácido desoxirribonucleico dna viral|O|O||D||1
41105520|Kits de purificación de ácido ribonucleico viral|O|O||D||1
41105521|Sistema de detección de ácido desoxirribonucleico dna|O|O||D||1
41105600|Productos secuenciadores de ácido desoxirribonucleico (ADN)|O|O||D||1
41105601|Kits o enzimas para secuenciación|O|O||D||1
41105700|Matrices génicas|O|O||D||1
41105701|Acido nucleico inmovilizado en membranas de vidrio o nylon|O|O||D||1
41105800|Productos de transcripción y traducción in vitro|O|O||D||1
41105801|Conjugados o derivados oligoméricos|O|O||D||1
41105802|Ribonucleotidos|O|O||D||1
41105803|Sistemas o kits de transcripción o traducción|O|O||D||1
41105804|Accesorios de etiquetado de traducción|O|O||D||1
41105900|Bibliotecas y material relacionado|O|O||D||1
41105901|Tejidos animales o fluidos corporales|O|O||D||1
41105902|Muestrarios de ácido desoxirribonucleico dna complementario|O|O||D||1
41105903|Kits de síntesis de ácido desoxirribonucleico dna complementario|O|O||D||1
41105904|Muestrarios genómicos|O|O||D||1
41105905|Kits de construcción de muestrarios|O|O||D||1
41105906|Muestrarios de despliegue de proteínas o péptidos|O|O||D||1
41105907|Dos muestrarios o sistemas de dos híbridos|O|O||D||1
41105908|Kits de empaques virales|O|O||D||1
41105909|Sintetizador de péptidos|O|O||D||1
41106000|Sistemas de etiquetado y detección de ácidos nucleicos|O|O||D||1
41106001|Materiales de detección de ácido nucleico quimio fluorescente|O|O||D||1
41106002|Materiales de detección de ácido nucleico quimio luminiscente|O|O||D||1
41106003|Materiales de detección nucleicos y cromogénicos|O|O||D||1
41106004|Kits de etiquetado no radiactivos de ácido nucleico|O|O||D||1
41106005|Kits de etiquetado radiactivos de ácido nucleico|O|O||D||1
41106006|Radio nucleótidos o nucleosidos|O|O||D||1|Kits de etiquetado reactivos de ácido nucleico
41106100|Kits de análisis de ácido desoxirribonucleico (ADN)|O|O||D||1
41106101|Kits citogenéticos|O|O||D||1
41106102|Kits de kits de exhibición o sustracción diferenciales|O|O||D||1
41106103|Kits de tipificación de ácido desoxirribonucleico dna|O|O||D||1
41106104|Pruebas de protección nucleasa|O|O||D||1
41106200|Medios, kits y equipo de propagación y transformación de microorganismos|O|O||D||1
41106201|Antimicóticos|O|O||D||1
41106202|Celdas competentes de bacterias|O|O||D||1
41106203|Kits de transformación de bacterias|O|O||D||1
41106204|Medio agar embotellado o en bandas para bacterias|O|O||D||1
41106205|Mezclas de suplemento brent para levadura|O|O||D||1
41106206|Mezclas de suplemento completo para levadura|O|O||D||1
41106207|Medio discoide dictiostelium|O|O||D||1|Medio discoide dictyostelium
41106208|Cubetas de electroporación|O|O||D||1
41106209|Mezclas de suplemento hollenberg para levaduras|O|O||D||1
41106210|Medios o suplementos para schizosaccharomyces pombe (levadura de fisión)|O|O||D||1
41106211|Ingredientes o aditivos de medio para schizosaccharomyces pombe|O|O||D||1|Ingredientes o aditivos de medio para levadura de fisión
41106212|Ingredientes o aditivos de medio para bacterias|O|O||D||1
41106213|Medio seco premezclado|O|O||D||1
41106214|Reactivos para preparar bacterias competentes|O|O||D||1
41106215|Reactivos para preparar levadura competente|O|O||D||1
41106216|Medios ricos para levadura|O|O||D||1
41106217|Platos especiales para bacterias|O|O||D||1
41106218|Medio seco premezclado especializado|O|O||D||1
41106219|Mezclas suplementarias completas sintéticas para levadura|O|O||D||1
41106220|Medio sintético para levadura|O|O||D||1
41106221|Células competentes para levadura|O|O||D||1
41106222|Kits de transformación de levadura|O|O||D||1
41106223|Bases de nitrógeno para levadura ynb o variantes de bases de nitrógeno para levaduras ynb|O|O||D||1
41106300|Productos de reacción en cadena de la polimerasa (PCR) y reacción en cadena de transcriptasa inversa de la polimerasa (RT PCR)|O|O||D||1
41106301|Trifosfatos deoxinucleotidos dntps|O|O||D||1
41106302|Kits de reacción en cadena polimerasa específica para genes|O|O||D||1
41106303|Kits de purificación de reacción en cadena de polimerasa|O|O||D||1
41106304|Kits para cuantificación de ácido ribonucleico mensajero mrna mediante reacción en cadena de polimerasa pcr|O|O||D||1
41106305|Nucleótidos|O|O||D||1
41106306|Tapones para reacción en cadena de polimerasa pcr|O|O||D||1
41106307|Productos para optimizar la reacción en cadena de polimerasa pcr|O|O||D||1
41106308|Base para reacción en cadena de polimerasa pcr o reacción en cadena de polimerasa transcripta inversa rt pcr|O|O||D||1
41106309|Ácido desoxirribonucleico complementario cdna pre-preparado|O|O||D||1
41106310|Ácido desoxirribonucleico adn genómico purificado|O|O||D||1
41106311|Ácidos ribonucleicos rna purificados|O|O||D||1
41106312|Productos de tecnología de rápida amplificación o terminaciones de ácido desoxirribonucleico complementario race|O|O||D||1
41106313|Kits de reacción en cadena de polimerasa transcriptasa inversa rt pcr|O|O||D||1
41106314|Kits o polimerasas de ácido desoxirribonucleico dna termoestable|O|O||D||1
41106400|Iniciadores, enlaces y adaptadores|O|O||D||1
41106401|Adaptadores o enlazadores|O|O||D||1
41106402|Bases misceláneas|O|O||D||1
41106403|Bases de secuenciación|O|O||D||1
41106500|Productos de expresión proteínica|O|O||D||1
41106501|Kits de expresión bacteriana|O|O||D||1
41106502|Reactivos de transfección eucariótica|O|O||D||1
41106503|Inductores o reguladores|O|O||D||1
41106504|Células de insectos|O|O||D||1
41106505|Kits de expresión de insectos|O|O||D||1
41106506|Medio para insectos|O|O||D||1
41106507|Reactivos o suplementos para medio para insectos|O|O||D||1
41106508|Kits de expresión celular mamífera|O|O||D||1
41106509|Células mamíferas|O|O||D||1
41106510|Kits para extracción de proteína de células o tejidos de mamíferos|O|O||D||1
41106511|Kits para extracción de proteína de bacterias|O|O||D||1
41106512|Kits para extracción de proteína de levadura|O|O||D||1
41106513|Reportero de ensayo genético|O|O||D||1
41106514|Líneas celulares mamíferas estables|O|O||D||1
41106515|Kits de expresión de levadura|O|O||D||1
41106516|Consumibles de expresión de enzimas|O|O||D||1
41106600|Vectores|O|O||D||1
41106601|Vectores enfocados a cromosomas|O|O||D||1
41106602|Vectores enfocados a expresión bacteriana|O|O||D||1
41106603|Vectores de casete|O|O||D||1
41106604|Despliegue de mapas o secuencias vectoriales|O|O||D||1
41106605|Mapas o secuencias de reportero de vector enzimático|O|O||D||1
41106606|Vectores de expresión de ácido desoxirribonucleico complementario cdna|O|O||D||1
41106607|Mapas o secuencias de vectores proteínicos fluorescentes|O|O||D||1
41106608|Vectores de fusión|O|O||D||1
41106609|Vectores enfocados a genes|O|O||D||1
41106610|Vectores de clonación general|O|O||D||1
41106611|Vectores o kits de sistemas hídricos|O|O||D||1
41106612|Vectores de expresión de insectos|O|O||D||1
41106613|Vectores de construcción de muestrarios|O|O||D||1
41106614|Vectores de expresión celular de mamíferos|O|O||D||1
41106615|Kits o vectores de clonación de reacción en cadena de polimerasa pcr|O|O||D||1
41106616|Ácido desoxirribonucleico dna fágico o viral|O|O||D||1
41106617|Kits o vectores de muta génesis plásmida|O|O||D||1
41106618|Productos de expresión o clonación de recombinación mediada|O|O||D||1
41106619|Vectores de secuenciación|O|O||D||1
41106620|Mapas o secuencias de reporteros de vectores por señal de transducción|O|O||D||1
41106621|Kits o vectores de expresión de virus mediado|O|O||D||1
41106622|Vectores de expresión de levadura|O|O||D||1
41106700|Equipos y accesorios de laboratorio botánico|O|O||D||1
41106701|Medidor de área de hojas|O|O||D||1
41106702|Aparato de medición de fotosíntesis|O|O||D||1
41106703|Instrumento de medición de crecimiento de las plantas o auxanómetro|O|O||D||1
41106704|Instrumento de medición de la clorofila|O|O||D||1
41106705|Fitotrón|O|O||D||1
41106706|Minirizotrón|O|O||D||1
41106707|Dispositivo de inspección de la nutrición de la vegetación|O|O||D||1
41106708|Set de dispositivos para recolección de plantas|O|O||D||1
41111500|Instrumentos de medición del peso|O|O||D||1
41111501|Balanzas de carga superior electrónicos|O|O||D||1
41111502|Balanzas de laboratorio|O|O||D||1
41111503|Balanzas mecánicas|O|O||D||1
41111504|Balanzas de resorte tensor|O|O||D||1
41111505|Pesas de calibración o sets de pesas|O|O||D||1
41111506|Básculas para pesar animales|O|O||D||1
41111507|Básculas de mesa|O|O||D||1
41111508|Básculas para medir el peso corporal|O|O||D||1
41111509|Básculas de piso o de plataforma|O|O||D||1
41111510|Básculas postales|O|O||D||1
41111511|Básculas de camión o riel|O|O||D||1
41111512|Balanzas de triple haz|O|O||D||1
41111513|Balanzas de humedad|O|O||D||1
41111515|Contenedores o tazones o barcos o papeles para pesar|O|O||D||1
41111516|Accesorios para instrumentos de medición de peso|O|O||D||1
41111517|Balanzas analíticas|O|O||D||1
41111518|Básculas de carga axial|O|O||D||1
41111519|Básculas de grúa|O|O||D||1
41111520|Báscula de peso de correa transportadora|O|O||D||1
41111521|Termogravímeto|O|O||D||1
41111522|Básculas de tolva|O|O||D||1
41111523|Prototipo de peso|O|O||D||1
41111524|Báscula indicadora de precio|O|O||D||1
41111525|Báscula empacadora automática|O|O||D||1
41111526|Báscula de selección automática|O|O||D||1
41111600|Instrumentos de medida de longitud, espesor o distancia|O|O||D||1
41111601|Micrómetros|O|O||D||1
41111602|Podómetros|O|O||D||1
41111603|Telémetros o buscadores de rango|O|O||D||1
41111604|Reglas|O|O||D||1
41111605|Medidoras de tensión|O|O||D||1
41111606|Telurómetros|O|O||D||1
41111607|Medidores o contadores de roscas|O|O||D||1
41111613|Metros de distancia|O|O||D||1
41111614|Medidores de altura|O|O||D||1
41111615|Sistemas láser de medición|O|O||D||1
41111616|Ruedas medidoras para distancias|O|O||D||1
41111617|Medidor de espesores|O|O||D||1
41111618|Set de bloques de patrón longitudinal|O|O||D||1
41111619|Calibrador go nogo|O|O||D||1
41111620|Cuña de etalón|O|O||D||1
41111621|Calibradores|O|O||D||1
41111622|Calibradores micrómetros|O|O||D||1
41111623|Dispositivos de medición de grosor|O|O||D||1
41111624|Medidor de orificios o alexómetro|O|O||D||1
41111625|Curvímetro|O|O||D||1
41111626|Bloque de medición|O|O||D||1
41111627|Bloque en v|O|O||D||1
41111628|Medidor de alambre|O|O||D||1
41111629|Sensor de posición de cable o alambre de extensión linear|O|O||D||1
41111630|Indicador de dial o medidor de dial|O|O||D||1
41111631|Medidor de radio|O|O||D||1
41111632|Medidor de cilindros|O|O||D||1
41111633|Micrómetro de aire|O|O||D||1
41111634|Micrómetro eléctrico|O|O||D||1
41111635|Comparador de bloques de patrón longitudinal|O|O||D||1
41111636|Equipo de medición de diámetro de cilindro|O|O||D||1
41111637|Taza probadora cónica|O|O||D||1
41111638|Probador de circunferencias de cigarrillos|O|O||D||1
41111639|Medidor de formas y profundidad de la cabeza de los tornillos|O|O||D||1
41111640|Medidor de soldadura|O|O||D||1
41111641|Medidor de paso de rosca|O|O||D||1
41111642|Medidor de espacio entre uniones de rieles|O|O||D||1
41111643|Calibrador de alambre|O|O||D||1
41111644|Medidor de pernos|O|O||D||1
41111645|Barra sinusoidal|O|O||D||1
41111646|Medidor telescópico|O|O||D||1
41111647|Medidor de orificios|O|O||D||1
41111648|Medidor cónico|O|O||D||1
41111649|Medidor de profundidad de llantas|O|O||D||1
41111650|Medidor de perforación|O|O||D||1
41111651|Catetómetro|O|O||D||1
41111700|Instrumentos y accesorios de visión y observación|O|O||D||1
41111701|Microscopios iónicos|O|O||D||1
41111702|Microscopios monoculares|O|O||D||1
41111703|Microscopios de disección de luz o de estéreo|O|O||D||1
41111704|Iluminadores para microscopios|O|O||D||1
41111705|Objetivos para microscopios|O|O||D||1|Lentes objetivos para microscopios
41111706|Elementos de sujeción de fotos para microscopios|O|O||D||1
41111707|Proyectores de perfil|O|O||D||1
41111708|Elementos de sujeción de video para microscopios|O|O||D||1
41111709|Microscopios compuestos de luz binocular|O|O||D||1
41111710|Combinación de microscopios de luz y electrones|O|O||D||1
41111711|Microscopios de electrones|O|O||D||1
41111712|Microscopios invertidos|O|O||D||1
41111713|Magnificadores|O|O||D||1
41111714|Lupas|O|O||D||1
41111715|Telescopios|O|O||D||1
41111716|Equipos de inspección boroscópica|O|O||D||1
41111717|Binoculares|O|O||D||1
41111718|Microscopios metalúrgicos|O|O||D||1
41111719|Microscopios de campo oscuro|O|O||D||1
41111720|Microscopios de escáner de electrones|O|O||D||1
41111721|Microscopios de transmisión de electrones|O|O||D||1
41111722|Microscopios fluorescentes|O|O||D||1
41111723|Microscopios de escáner de luz, disco giratorio o escáner de láser|O|O||D||1
41111724|Microscopios de escáner de sonda|O|O||D||1
41111725|Microscopios de polarización|O|O||D||1
41111726|Microscopios acústicos|O|O||D||1
41111727|Microscopios de proyección|O|O||D||1
41111728|Microscopios de campo ancho|O|O||D||1
41111729|Microscopios oculares|O|O||D||1
41111730|Condensadores de microscopios|O|O||D||1
41111731|Colectores de microscopios|O|O||D||1
41111733|Tubos de microscopios|O|O||D||1
41111734|Microscopios de fases|O|O||D||1
41111735|Microscopios de fases automáticos|O|O||D||1
41111736|Cubiertas para microscopios|O|O||D||1
41111737|Videoscopios|O|O||D||1
41111738|Fibroscopios|O|O||D||1
41111739|Bombillos de repuesto para microscopios de laboratorio|O|O||D||1
41111740|Sistema de inspección óptica automática|O|O||D||1
41111741|Equipo de microscopio de contraste de interferencia diferencial|O|O||D||1
41111742|Periscopio|O|O||D||1
41111743|Autocolimador|O|O||D||1
41111744|Micrómetro microscópico|O|O||D||1
41111745|Micromanipulador|O|O||D||1
41111746|Palanca óptica|O|O||D||1
41111747|Fibroscopio industrial|O|O||D||1
41111748|Microscopio de imagen multimedia|O|O||D||1
41111749|Microscopio de contraste de fase|O|O||D||1
41111800|Equipo de examen no destructivo|O|O||D||1
41111801|Equipo de examen de corriente parásita|O|O||D||1
41111802|Equipo de examen de penetración líquida|O|O||D||1
41111803|Equipo de examen de partículas magnéticas|O|O||D||1
41111804|Equipo de examen ultrasónico|O|O||D||1
41111805|Equipo de examen de radiografía co 60|O|O||D||1
41111806|Equipo de examen de radiografía cs 137|O|O||D||1
41111807|Equipo de examen de radiografía ir 192|O|O||D||1
41111808|Equipo de examen de radiografía de rayos x|O|O||D||1
41111809|Equipo de prueba de goteo|O|O||D||1
41111810|Estación de equipos de pruebas de calor|O|O||D||1
41111811|Estación de equipos de pruebas de frío|O|O||D||1
41111812|Equipo de examen de radiografía de rayos gamma|O|O||D||1
41111813|Iluminador para ver radiografías para uso industrial|O|O||D||1
41111814|Equipo de examen de radiografía de neutrones|O|O||D||1
41111815|Detector de metales de refuerzo|O|O||D||1
41111816|Instrumento de medición de desplazamiento|O|O||D||1
41111817|Sistema de medición del sabor del arroz|O|O||D||1
41111818|Reactivo de examen no destructivo|O|O||D||1
41111819|Probador de cable de acero|O|O||D||1
41111820|Detector de fluorescencia|O|O||D||1
41111900|Instrumentos indicadores y de registro|O|O||D||1
41111901|Contadores|O|O||D||1|Contadores mecánicos
41111902|Contadores electrónicos|O|O||D||1|Contadores electrónicos
41111903|Detectores de metales|O|O||D||1|Detectores de metales
41111904|Columnas electrónicas|O|O||D||1|Columnas electrónicas de medición
41111905|Sondas de medición electrónicas|O|O||D||1|Sondas o puntas de prueba electrónicas
41111906|Grabadoras de tablas|O|O||D||1|Registrador de gráficos
41111907|Grabadoras de lectura digital|O|O||D||1
41111908|Grabadoras gráficas|O|O||D||1
41111909|Grabadoras de cintas magnéticas|O|O||D||1
41111910|Grabadoras multifunción|O|O||D||1
41111911|Grabadoras oscilo gráficas|O|O||D||1
41111912|Grabadoras sicológicas|O|O||D||1
41111913|Grabadoras de punta de trazado|O|O||D||1
41111914|Servo grabadoras|O|O||D||1
41111915|Sensores bi metálicos|O|O||D||1|Sensores bimetálicos
41111916|Sensores de no contacto|O|O||D||1|Sensores sin contacto
41111917|Probadores digitales|O|O||D||1
41111918|Instruments giroscópicos|O|O||D||1
41111919|Aparatos de detección para objetos no metálicos|O|O||D||1
41111920|Máquinas de medición de coordenadas cmm|O|O||D||1|Máquina de medición de coordenadas (CMM)
41111921|Sensores de velocidad|O|O||D||1
41111922|Sensores de fallas de lámparas|O|O||D||1
41111923|Sensor de pistones pre-arranque|O|O||D||1
41111924|Sensores de oxígeno|O|O||D||1
41111926|Sensores de proximidad|O|O||D||1
41111927|Sensores de presión|O|O||D||1
41111928|Sensores de corriente|O|O||D||1
41111929|Detectores de radiación|O|O||D||1
41111930|Sensores de corriente eléctrica|O|O||D||1
41111931|Sensores de flujo|O|O||D||1
41111932|Detectores de escape de líquidos|O|O||D||1
41111933|Sensores de carga eléctrica|O|O||D||1
41111934|Sensores de fuerza o de torsión|O|O||D||1
41111935|Sensores de inclinación|O|O||D||1
41111936|Sensores de imagen de semiconductor de óxido de metal complementario cmos|O|O||D||1|Sensor de imagen CMOS
41111937|Sensores giratorios de posición|O|O||D||1
41111938|Sensores o transmisores de nivel|O|O||D||1
41111939|Sensores acústicos|O|O||D||1
41111940|Sensores de color|O|O||D||1
41111941|Sensores olfativos|O|O||D||1
41111942|Sensores de opacidad o polvo o visibilidad|O|O||D||1
41111943|Sensores de resistencia o conductividad eléctrica|O|O||D||1
41111944|Sensores de admisión eléctricos|O|O||D||1
41111945|Sensores de posición linear|O|O||D||1
41111946|Sensores de inductancia eléctrica|O|O||D||1
41111947|Esferos de registro de tablas|O|O||D||1|Plumas grabadoras de gráficos
41111948|Contadores de células diferenciales hematológicas manuales o electrónicos|O|O||D||1|Contadores diferenciales de células sanguíneas (manuales o electrónicos)
41111949|Cronómetro|O|O||D||1
41111950|Indicador de nivel|O|O||D||1
41111951|Indicador de humedad|O|O||D||1
41111952|Sensor de sulfuro de hidrógeno|O|O||D||1
41111953|Sensor de armado de inflador de restricción (bolsa de aire) suplementario|O|O||D||1|Sensor del sistema suplementario de restricción inflable (SIR)
41111954|Sensor líquido|O|O||D||1|Sensor de líquidos
41111955|Sensor solar|O|O||D||1
41111956|Sensor de temperatura infrarrojo|O|O||D||1
41111957|Sensor de presión de aceite|O|O||D||1
41111958|Sensor de presión ambiental múltiple|O|O||D||1
41111959|Sensor de presión de combustible|O|O||D||1
41111960|Sensor ultrasónico|O|O||D||1
41111961|Sensor de ocupación|O|O||D||1|Sensores de movimiento
41111962|Sensor de desgaste de frenos|O|O||D||1
41111963|Sensor de nivel de combustible|O|O||D||1
41111964|Sensor de tensión del cinturón de seguridad|O|O||D||1
41111965|Sensor de agua|O|O||D||1
41111966|Sensor de humedad|O|O||D||1
41111967|Sensor de cabeceo largo lateral|O|O||D||1
41111968|Sensor de tasa angular|O|O||D||1
41111969|Sensor de control de voltaje|O|O||D||1
41111970|Sensor de temperatura|O|O||D||1
41111971|Contador binario|O|O||D||1
41111972|Sensor de inflador de restricción (bolsa de aire) suplementario sir o de ensamblaje de bobina de la bolsa de aire|O|O||D||1
41111973|Contador de partículas|O|O||D||1
41111974|Probador sensor de calor|O|O||D||1|Sensor probador de calor
41111975|Monitor de campo magnético|O|O||D||1
41111976|Sistema de chequeo métrico de agua|O|O||D||1
41111977|Contador de iones|O|O||D||1
41111978|Lector de tubo microhematocrito manual|O|O||D||1
41112100|Transductores|O|O||D||1
41112101|Cristales piezoeléctricos|O|O||D||1
41112103|Sensores de fibra|O|O||D||1
41112104|Transductores de audio|O|O||D||1|Transductor electroacústico
41112105|Transmisores de temperatura|O|O||D||1
41112106|Transmisores de humedad|O|O||D||1
41112107|Transductores electro neumáticos|O|O||D||1
41112108|Celdas de carga|O|O||D||1
41112109|Transductor de corriente|O|O||D||1
41112110|Transductor de presión|O|O||D||1
41112111|Transductor de desplazamiento|O|O||D||1
41112112|Transductor de energía eléctrica|O|O||D||1
41112113|Transductor de energía mecánica|O|O||D||1
41112114|Transmisor termohigrómetro|O|O||D||1
41112200|Instrumentos de medida de temperatura y calor|O|O||D||1
41112201|Calorímetros|O|O||D||1
41112202|Equipos de rastreo de calor|O|O||D||1
41112203|Grabadoras de punto de fusión|O|O||D||1
41112204|Pirómetros|O|O||D||1
41112205|Reguladores de temperatura|O|O||D||1
41112206|Termo cúpulas|O|O||D||1|Sensor para medir la temperatura
41112207|Termógrafos|O|O||D||1
41112209|Termostatos|O|O||D||1
41112210|Termómetros de lectura remota|O|O||D||1
41112211|Termómetros de resistencia|O|O||D||1
41112212|Termómetros de superficie|O|O||D||1
41112213|Termómetros de mano|O|O||D||1
41112214|Controles de temperatura criogénicos|O|O||D||1
41112215|Controladores de temperatura humidificadores|O|O||D||1|Humidificadores para el control de temperatura
41112216|Termopozos|O|O||D||1
41112217|Termo cabezas|O|O||D||1|Sensor de temperatura en cabeza de cilindro (Thermoheads)
41112219|Sondas termopares|O|O||D||1
41112220|Termómetros de refrigerador o congelador de laboratorio|O|O||D||1
41112221|Termómetros de incubadora de laboratorio|O|O||D||1
41112222|Indicador de temperatura|O|O||D||1
41112223|Indicador compuesto|O|O||D||1
41112224|Termómetro infrarrojo|O|O||D||1
41112225|Detector de temperatura de resistencia|O|O||D||1
41112226|Sensor termopar de baja temperatura|O|O||D||1
41112227|Sensor termopar de alta temperatura|O|O||D||1
41112228|Analizador de eficiencia de combustión|O|O||D||1
41112229|Medidor de calor|O|O||D||1
41112230|Calibrador pirómetro|O|O||D||1|Calibrador de pirómetro
41112231|Probador de nube de aceite y de punto de vertido|O|O||D||1
41112232|Instrumento medidor de punto de congelación|O|O||D||1
41112233|Instrumento medidor de punto de derretimiento|O|O||D||1
41112234|Flujómetro de calor|O|O||D||1
41112235|Instrumento para medir calor específico|O|O||D||1
41112236|Probador de punto de ablandamiento del asfalto|O|O||D||1
41112237|Termómetro de punto de rocío|O|O||D||1
41112238|Probador de punto de caída de temperatura|O|O||D||1
41112239|Termómetro de vidrio|O|O||D||1
41112240|Banda de verificación de temperatura de la unidad de sangre|O|O||D||1
41112300|Instrumentos de medición de la humedad|O|O||D||1
41112301|Higrómetros|O|O||D||1
41112302|Sicrómetros|O|O||D||1|Psicrómetro
41112303|Probadores de humedad de temperatura|O|O||D||1|Instrumento para medir humedad y temperatura
41112304|Medidores de rocío|O|O||D||1
41112305|Controlador de humedad|O|O||D||1
41112306|Calibrador de humedad|O|O||D||1
41112307|Probador de retención de agua por el cemento|O|O||D||1
41112400|Instrumentos de medida y control de la presión|O|O||D||1
41112401|Indicadores de profundidad|O|O||D||1
41112402|Manostatos|O|O||D||1
41112403|Indicadores de presión|O|O||D||1
41112404|Reguladores de presión|O|O||D||1
41112405|Grabadoras de presión o de vacío|O|O||D||1
41112406|Indicadores de vacío|O|O||D||1
41112407|Instrumentos o controles de nivel de líquido|O|O||D||1
41112408|Intensificadores de presión|O|O||D||1
41112409|Escáneres de presión|O|O||D||1
41112410|Transmisores de presión|O|O||D||1
41112411|Controladores de presión|O|O||D||1
41112412|Indicador de presión|O|O||D||1
41112413|Indicador de presión diferencial|O|O||D||1
41112414|Calibrador de presión|O|O||D||1
41112415|Aparato de warburg|O|O||D||1|Manómetro de Warburg
41112416|Probador de presión de destrucción o rompimiento|O|O||D||1
41112417|Instrumento medidor de la presión de vapor|O|O||D||1|Isoteniscopio
41112418|Probador de presión capilar|O|O||D||1
41112419|Medidor de resistencia de inhalación de los filtros de cigarrillos|O|O||D||1
41112420|Indicador de caída de presión|O|O||D||1
41112421|Probador de dureza de las frutas|O|O||D||1
41112422|Probador de presión hidráulica|O|O||D||1
41112423|Altímetro de presión|O|O||D||1
41112500|Instrumentos de medición y observación del caudal de fluidos|O|O||D||1
41112501|Flujómetros|O|O||D||1
41112502|Reómetros|O|O||D||1
41112503|Rotámetros|O|O||D||1|Rotámetros o flujometros
41112504|Medidores de agua|O|O||D||1|Medidor de agua (Hidrómetro)
41112505|Repuestos para medidores de agua|O|O||D||1
41112506|Venturis|O|O||D||1|Medidor de Flujo Venturi
41112508|Indicadores de gas|O|O||D||1
41112509|Monitores de temperatura y velocidad del aire|O|O||D||1
41112510|Indicadores visuales de flujo|O|O||D||1
41112511|Ventanas para visualizar el flujo|O|O||D||1
41112512|Computadores o totalizadores de flujo|O|O||D||1|Computadoras o totalizadores de flujo
41112513|Plato de orificio|O|O||D||1|Plato o placa de orificio
41112514|Indicadores de aceite|O|O||D||1
41112516|Transmisores de flujo|O|O||D||1
41112517|Flujómetros ópticos y accesorios|O|O||D||1
41112518|Equipo para probar la eficiencia de las bombas|O|O||D||1
41112519|Indicador de piloto|O|O||D||1|Manómetros de tubo de Pitot
41112520|Medidor de flujo de bombas contra incendios|O|O||D||1
41112521|Columna de calibración|O|O||D||1
41112600|Equipo de monitorización y comprobación higiénica|O|O||D||1
41112601|Kits de prueba de frotis manual|O|O||D||1
41112602|Kits de prueba de frotis automático|O|O||D||1|Equipo para prueba manual con hisopos
41112700|Equipo para semillas y piensos|O|O||D||1
41112701|Analizadores de grano|O|O||D||1
41112702|Contadores de semillas|O|O||D||1
41112704|Analizadores de alimentación|O|O||D||1
41112800|Equipo e instrumentos relacionados con el transporte|O|O||D||1
41112801|Velocímetros|O|O||D||1
41112802|Tacómetros|O|O||D||1
41112803|Discos para tacómetros|O|O||D||1
41112804|Equipo de medición de la abrasión de los rieles|O|O||D||1
41112805|Instrumento de medición del hundimiento de los rieles|O|O||D||1
41112806|Instrumento de medición de la separación entre las uniones de los rieles|O|O||D||1
41112807|Instrumento de medición de la fuerza de unión de los travesaños de los rieles|O|O||D||1
41112808|Probador de los vagones eléctricos|O|O||D||1
41112809|Probador de taxímetros|O|O||D||1
41112900|Equipo e instrumentos de navegación|O|O||D||1
41112901|Compases para encontrar la dirección|O|O||D||1|Brújulas
41112902|Instrumentos de navegación por radio|O|O||D||1
41112903|Sextantes|O|O||D||1|Sextante astronómico
41112904|Dispositivos de control complejo|O|O||D||1
41112905|Faro infrarrojo|O|O||D||1
41112906|Faro de radio|O|O||D||1
41112907|Boya de radio|O|O||D||1
41113000|Instrumentos de suministros evaluación química|O|O||D||1
41113001|Controladores de analizador digital|O|O||D||1
41113002|Analizadores de bioluminiscencia o quimioluminiscencia|O|O||D||1
41113003|Analizadores de electro gravimetría|O|O||D||1
41113004|Analizadores de ionización de la llama|O|O||D||1
41113005|Analizadores de iones|O|O||D||1
41113006|Analizadores de radiometría|O|O||D||1
41113007|Analizadores de acceso aleatorio|O|O||D||1
41113008|Analizadores de cintigrafía|O|O||D||1
41113009|Analizadores térmicos diferenciales|O|O||D||1
41113010|Analizadores térmicos de gravimetría|O|O||D||1
41113023|Equipo de partición de geles|O|O||D||1
41113024|Hidrómetros|O|O||D||1
41113025|Monocromadores|O|O||D||1
41113026|Nefelómetros|O|O||D||1
41113027|Osmómetros|O|O||D||1
41113029|Polarógrafos|O|O||D||1
41113030|Escáner radiocromatográfico|O|O||D||1
41113031|Sacarímetros|O|O||D||1
41113033|Volúmetros|O|O||D||1
41113034|Tiras o papeles para prueba de ph|O|O||D||1
41113035|Tiras o papeles para pruebas químicas|O|O||D||1
41113036|Micro placas|O|O||D||1
41113037|Lectores de micro placas|O|O||D||1
41113038|Alcoholímetro|O|O||D||1
41113039|Accesorios para osmómetros|O|O||D||1
41113040|Contador de colonias (de microorganismos)|O|O||D||1
41113041|Analizador elemental|O|O||D||1
41113042|Analizador de leche|O|O||D||1
41113043|Sistema de determinación de la fibra de la dieta|O|O||D||1
41113044|Hidrómetro de alcohol|O|O||D||1
41113045|Probador de película de aceite|O|O||D||1
41113046|Probador de adhesión|O|O||D||1
41113047|Probador de características de la espuma del aceite|O|O||D||1
41113048|Probador de resistencia del color|O|O||D||1
41113049|Analizador de combustión|O|O||D||1
41113050|Detector de arsénico|O|O||D||1
41113051|Probador de reducción de oxidación|O|O||D||1
41113052|Probador de tiza o pigmento que suelta la pintura seca|O|O||D||1
41113053|Probador de prevención de óxido|O|O||D||1
41113054|Probador de demulsibilidad|O|O||D||1|Probador de separabilidad del agua
41113055|Probador de goma en el combustible|O|O||D||1
41113056|Cable de experimentación de llama|O|O||D||1
41113057|Densitómetro de lodo|O|O||D||1
41113100|Analizadores y monitores de gas|O|O||D||1
41113101|Analizadores de emisión exhaustiva de automóviles|O|O||D||1|Analizadores de emisiones de escape para automóviles
41113102|Analizadores de combustión catalítica|O|O||D||1
41113103|Analizadores de absorción de gas químico|O|O||D||1
41113104|Explosímetros|O|O||D||1
41113105|Analizadores o detectores de hidrocarburos|O|O||D||1
41113106|Analizadores de absorción de infrarrojos o ultravioleta|O|O||D||1
41113107|Analizadores de gas nitrógeno|O|O||D||1
41113108|Analizadores de óxido de nitrógeno|O|O||D||1
41113109|Equipo orsat|O|O||D||1|Aparato de Orsat
41113110|Analizadores de gas de oxígeno|O|O||D||1
41113111|Analizadores de ozono|O|O||D||1
41113112|Analizadores de susceptibilidad paramagnética|O|O||D||1
41113113|Detectores o analizadores de dióxido de sulfuro|O|O||D||1
41113114|Analizadores de conductividad térmica|O|O||D||1
41113115|Detectores de radón|O|O||D||1
41113116|Tubos detectores de gas|O|O||D||1
41113117|Monitores simples de gas|O|O||D||1
41113118|Monitores múltiples de gas|O|O||D||1
41113119|Analizadores de dióxido de carbono disuelto|O|O||D||1
41113120|Analizador de monóxido de carbono|O|O||D||1
41113121|Sistema analizador de vapor de gas de vehículos|O|O||D||1
41113122|Olfatómetro|O|O||D||1
41113123|Probador de humo|O|O||D||1
41113124|Respirómetro|O|O||D||1
41113300|Analizadores de líquidos, sólidos y elementos|O|O||D||1
41113301|Analizadores ácidos o de base|O|O||D||1
41113302|Albuminómetros|O|O||D||1
41113304|Analizadores de bauxita|O|O||D||1
41113305|Analizadores de calcio|O|O||D||1
41113306|Analizadores de cloruro|O|O||D||1
41113308|Analizadores de electrolitos|O|O||D||1
41113309|Analizadores de enzimas|O|O||D||1
41113310|Analizadores de ácidos grasos|O|O||D||1
41113311|Lámpara detectora de haluro|O|O||D||1
41113312|Analizadores de lactato|O|O||D||1
41113313|Instrumentos de prueba de aceite mineral|O|O||D||1
41113314|Analizadores monitores de contenido de aceite|O|O||D||1
41113315|Analizadores de carbono orgánico|O|O||D||1
41113316|Equipo de prueba de petróleo|O|O||D||1
41113318|Analizadores de uranio|O|O||D||1
41113319|Analizadores de agua|O|O||D||1
41113320|Kit de prueba de aceite lubricante|O|O||D||1
41113321|Probador de pintura|O|O||D||1
41113322|Analizador de nitrógeno o nitrato o nitrito|O|O||D||1
41113323|Analizadores de azúcar|O|O||D||1
41113324|Probador de fuerza de ocultamiento de la pintura|O|O||D||1
41113325|Probador de posibilidad de lavar la pintura|O|O||D||1
41113326|Instrumento medidor del grano de la pintura|O|O||D||1
41113327|Aplicador de película de pintura|O|O||D||1
41113328|Analizador de mercurio|O|O||D||1
41113329|Probador de sólidos suspendidos ss|O|O||D||1
41113330|Instrumento para medir el espesor del lodo|O|O||D||1
41113331|Probador de congelación y descongelación|O|O||D||1
41113332|Analizador de raciones líquidas|O|O||D||1|Analizador de relación de líquidos
41113333|Analizador de potencial zeta|O|O||D||1
41113334|Equipo de prueba de pintura de revestimiento|O|O||D||1
41113335|Analizador de componentes múltiples de compuestos disueltos|O|O||D||1
41113336|Probador de número de emulsiones de vapor|O|O||D||1
41113337|Probador de tamaño del grano o de dispersión|O|O||D||1
41113338|Medidor de demanda de oxígeno bioquímico bod|O|O||D||1
41113339|Medidor de demanda de oxígeno químico cod|O|O||D||1
41113400|Instrumentos de evaluación nuclear|O|O||D||1
41113401|Contadores alfa|O|O||D||1
41113402|Contadores alfa beta|O|O||D||1
41113403|Contadores beta|O|O||D||1
41113404|Contadores beta gamma|O|O||D||1
41113405|Contadores gama|O|O||D||1
41113406|Medidores kvp|O|O||D||1|Medidores de kilo voltaje
41113407|Micro analizadores de rayos x|O|O||D||1
41113600|Equipo de medición y comprobación eléctrica|O|O||D||1
41113601|Amperímetros|O|O||D||1
41113602|Medidores  de fase|O|O||D||1
41113603|Puentes de laboratorio|O|O||D||1
41113604|Medidores de capacitancia|O|O||D||1
41113605|Derivatógrafos de análisis térmico|O|O||D||1
41113606|Indicadores de monitoreo de congelamiento|O|O||D||1
41113607|Monitores de estrés de calor|O|O||D||1
41113608|Contadores de coincidencia o no coincidencia|O|O||D||1
41113611|Medidores de diafonía|O|O||D||1
41113612|Probadores de resistencia de la tierra|O|O||D||1
41113613|Grabadoras de valor eléctrico|O|O||D||1
41113614|Medidores de campo electromagnético|O|O||D||1
41113615|Electrómetros|O|O||D||1
41113616|Cargas electrónicas|O|O||D||1
41113617|Equipos de medición de la fuerza del campo|O|O||D||1
41113618|Instrumentos de medición de ganancia|O|O||D||1
41113619|Galvanómetros|O|O||D||1
41113620|Cable de detección de alto voltaje|O|O||D||1
41113621|Medidores de impedancia|O|O||D||1
41113622|Bobinas o cajas de inductancias calibradas|O|O||D||1
41113623|Medidores de resistencia al aislamiento|O|O||D||1
41113624|Medidores de aislamiento|O|O||D||1
41113625|Cámaras de ionización|O|O||D||1
41113626|Ionómetros|O|O||D||1
41113627|Medidores de circuito de línea a tierra|O|O||D||1|Probadores de lazo de tierra de línea
41113628|Megohmetros|O|O||D||1
41113629|Medidores de filtración de microondas|O|O||D||1
41113630|Multímetros|O|O||D||1
41113631|Ohmetros|O|O||D||1
41113632|Oscilógrafos|O|O||D||1
41113633|Potenciómetros|O|O||D||1
41113634|Medidores q|O|O||D||1|Medidores Q
41113635|Equipo de medición de resistencia calibrada|O|O||D||1
41113636|Generadores de nivel|O|O||D||1
41113637|Medidores de voltaje o de corriente|O|O||D||1
41113638|Osciloscopios|O|O||D||1
41113639|Acelerómetros|O|O||D||1
41113640|Medidores de vatios|O|O||D||1
41113641|Probadores de circuitos gfi|O|O||D||1|Probadores de circuitos GFI
41113642|Probador de circuitos|O|O||D||1
41113643|Medidores o registros de demanda|O|O||D||1
41113644|Trazador de circuitos|O|O||D||1
41113645|Dispositivos de filtración de tierra|O|O||D||1
41113646|Calibrador o simulador de temperatura|O|O||D||1
41113647|Calibrador o simulador de frecuencia|O|O||D||1
41113649|Sofómetro|O|O||D||1
41113650|Probador funcional|O|O||D||1
41113651|Tablero de medición de resistencia|O|O||D||1
41113652|Tablero de ensamblaje de cables|O|O||D||1
41113653|Probador de circuito en serie|O|O||D||1
41113654|Medidor de circuito de corriente|O|O||D||1
41113655|Set de prueba de generador|O|O||D||1|Kit de prueba de generador
41113656|Probador de servo sistema|O|O||D||1
41113657|Probador de disyuntor (interruptor)|O|O||D||1
41113658|Probador de durabilidad del interruptor|O|O||D||1
41113659|Medidor de energía reactiva (var)|O|O||D||1
41113660|Probador de oscilador|O|O||D||1
41113661|Probador de regulador de voltaje|O|O||D||1
41113662|Resonador de cavidades|O|O||D||1
41113663|Probador transformador|O|O||D||1
41113664|Indicador de secuencia de fase|O|O||D||1
41113665|Probador de resistencia de contacto|O|O||D||1
41113666|Probador de pararrayos|O|O||D||1
41113667|Equipo de prueba del medidor de vatios hora|O|O||D||1
41113668|Probador de capacidad|O|O||D||1
41113669|Detector de línea de voltaje|O|O||D||1
41113670|Equipo de prueba de resistencia|O|O||D||1
41113671|Divisor de corriente|O|O||D||1
41113672|Probador de relé|O|O||D||1|Probador de relevadores
41113673|Medidor de panel y tablero de control|O|O||D||1
41113674|Probador de máquina pulidora|O|O||D||1
41113675|Equipo de prueba de control de frecuencia|O|O||D||1
41113676|Probador de bajo voltaje|O|O||D||1
41113677|Probador de resistencia de voltaje|O|O||D||1
41113678|Probador de abrazadera|O|O||D||1
41113679|Equipo de prueba de transformador de corriente y transformador potencial|O|O||D||1
41113680|Medidor de factor de energía|O|O||D||1
41113681|Probador combi (voltaje, corriente, frecuencia y otras)|O|O||D||1
41113682|Probador de corriente eléctrica|O|O||D||1
41113683|Probador de lámparas|O|O||D||1
41113684|Calibrador medidor de voltaje y corriente|O|O||D||1
41113685|Equipo para medir electricidad estática|O|O||D||1
41113686|Medidor de pulso|O|O||D||1|Oxímetro de pulso
41113687|Máquina para probar freno|O|O||D||1
41113688|Equipo para probar convertidores|O|O||D||1
41113689|Equipo para probar controladores|O|O||D||1
41113700|Instrumentos de medición y comprobación de comunicación electrónica|O|O||D||1
41113701|Probador de tubos de rayos catódicos|O|O||D||1
41113702|Comparadores|O|O||D||1|Comparadores analógicos o digitales
41113703|Acoplamiento direccional|O|O||D||1
41113704|Probadores de circuitos integrados|O|O||D||1
41113705|Probadores de estado lógico|O|O||D||1
41113706|Probadores de semiconductores|O|O||D||1
41113707|Probadores de circuitos de transistores|O|O||D||1
41113708|Medidores de energía|O|O||D||1
41113709|Medidores de modulación|O|O||D||1
41113710|Medidor de nivel|O|O||D||1
41113711|Analizadores de red|O|O||D||1
41113712|Probadores de cintas|O|O||D||1
41113713|Probadores de velocidad de la cinta|O|O||D||1
41113714|Diferenciador|O|O||D||1
41113715|Probadores de redes digitales de servicios integrados isdn|O|O||D||1
41113716|Localizadores de fallas de fibra óptica|O|O||D||1
41113717|Fuentes de prueba de fibra óptica|O|O||D||1
41113718|Analizadores de protocolo|O|O||D||1
41113719|Probador de pérdida óptica|O|O||D||1
41113720|Equipo de prueba de intensidad del tráfico|O|O||D||1
41113721|Instrumento de medición de señal de video|O|O||D||1
41113722|Probador de interferencia electromagnética (emi)|O|O||D||1|Probador de interferencia electromagnética (EMI)
41113723|Probador de equipo de radio|O|O||D||1
41113724|Set de prueba de teléfonos|O|O||D||1|Equipo de prueba de teléfonos
41113725|Medidor de energía óptica|O|O||D||1
41113726|Probador de resistencia al calor|O|O||D||1
41113727|Medidor de distorsión|O|O||D||1
41113728|Cámara ambiental de escudo electromagnético|O|O||D||1
41113729|Medidor de salida del amplificador|O|O||D||1
41113730|Probador de televisiones|O|O||D||1
41113731|Probador de cristales|O|O||D||1
41113732|Probador de amplificadores|O|O||D||1
41113733|Probador de antenas|O|O||D||1
41113734|Medidor de desviación de frecuencia|O|O||D||1
41113735|Probador de equipo de microondas|O|O||D||1
41113736|Refractómetro electrónico y de comunicación|O|O||D||1
41113737|Medidor de ruido|O|O||D||1
41113738|Probador de sobrecarga de la línea de comunicación|O|O||D||1
41113739|Probador de susceptibilidad electromagnética|O|O||D||1
41113740|Probador de cable de video, voz y datos|O|O||D||1
41113800|Instrumentos geofísicos, geotécnicos e hidrológicos|O|O||D||1
41113801|Compases geológicos|O|O||D||1|Brújula Brunton, Brújula de geólogo
41113802|Aparatos de prospección geológica|O|O||D||1
41113803|Instrumentos geofísicos electromagnéticos|O|O||D||1
41113804|Instrumentos geofísicos de gravedad|O|O||D||1
41113805|Instrumentos geofísicos de polarización inducida ip|O|O||D||1
41113806|Instrumentos geofísicos magnetómetros|O|O||D||1
41113807|Instrumentos geofísicos de resistividad|O|O||D||1
41113808|Gravímetros|O|O||D||1|Gravitómetro
41113809|Radar de penetración del suelo|O|O||D||1
41113810|Equipo de prueba hidrotérmica|O|O||D||1
41113811|Probador de resistencia sólida|O|O||D||1
41113812|Probador de fricción del suelo|O|O||D||1
41113813|Agregado estándar|O|O||D||1
41113814|Probador de límite plástico del suelo|O|O||D||1
41113815|Probador del límite de encogimiento del suelo|O|O||D||1
41113816|Probador de consolidación|O|O||D||1
41113817|Probador del límite líquido del suelo|O|O||D||1
41113818|Probador de resistencia de la placa|O|O||D||1|Probador de rodamientos de placas
41113819|Analizador de suelos|O|O||D||1
41113820|Probador de gravedad específica agregada|O|O||D||1|Probador agregado de gravedad específica
41113821|Probador de penetración del suelo|O|O||D||1
41113822|Probador de tasa de resistencia california|O|O||D||1
41113823|Probador de expansión de espécimen|O|O||D||1|Probador de expansión de muestras
41113824|Probador de permeabilidad de cabeza de suelo|O|O||D||1
41113825|Analizador de agregado del suelo|O|O||D||1
41113826|Analizador de textura del suelo|O|O||D||1
41113827|Aparato de compresión no confinada del suelo|O|O||D||1
41113828|Aparato de cono de densidad de la arena|O|O||D||1
41113829|Equipo de recolección de suelo bajo el agua|O|O||D||1
41113830|Instrumento para medir el peso de la unidad de agregado|O|O||D||1
41113831|Instrumento para medir el agua superficial en la superficie del agregado|O|O||D||1
41113900|Equipo para medición de suelos|O|O||D||1
41113901|Instrumentos de medición de perforación|O|O||D||1
41113902|Probadores de disolución o desintegración|O|O||D||1
41113903|Aparatos medidores del tamaño de partículas|O|O||D||1
41113904|Penetrómetros|O|O||D||1
41113905|Aparatos para probar permeabilidad|O|O||D||1
41113906|Aparatos para estimar permeabilidad o porosidad|O|O||D||1
41113907|Porosímetros|O|O||D||1
41113908|Aparatos para probar arena|O|O||D||1|Aparatos de prueba de arena
41113909|Aparatos muestreadores del núcleo del suelo|O|O||D||1
41113910|Kits de probadores del suelo|O|O||D||1
41114000|Equipo de medida de rocas y estratos|O|O||D||1
41114001|Clinómetros|O|O||D||1
41114100|Instrumentos sismológicos|O|O||D||1
41114102|Simuladores de terremotos|O|O||D||1
41114103|Módulos de alarma sísmica|O|O||D||1
41114104|Amplificadores sísmicos|O|O||D||1
41114105|Aparatos sísmicos portátiles|O|O||D||1
41114106|Sismógrafos o grabadoras sísmicas|O|O||D||1
41114107|Sismómetros|O|O||D||1
41114108|Vibrómetros|O|O||D||1
41114200|Instrumentos de agrimensión|O|O||D||1
41114201|Cintas medidoras|O|O||D||1|Cintas métricas
41114202|Varillas medidoras|O|O||D||1
41114203|Tablas medidoras|O|O||D||1
41114204|Teodolitos|O|O||D||1
41114205|Estacas de localización|O|O||D||1
41114206|Centro de localización|O|O||D||1
41114207|Estación total|O|O||D||1
41114208|Instrumento de longimetría|O|O||D||1
41114209|Taquímetro o taqueómetro|O|O||D||1
41114210|Nivel óptico|O|O||D||1|Nivel topográfico
41114211|Altímetro|O|O||D||1
41114212|Estereoscopio de espejo|O|O||D||1
41114213|Comparador de coordinadas|O|O||D||1|Comparador de coordenadas
41114214|Plantilla de encuestas|O|O||D||1
41114215|Dendrómetro|O|O||D||1
41114216|Alidada|O|O||D||1
41114217|Línea de plomo|O|O||D||1
41114218|Planímetros|O|O||D||1
41114219|Brazo de la plomada|O|O||D||1
41114220|Tránsito|O|O||D||1|Niveles de tránsito
41114221|Escuadra óptica|O|O||D||1
41114300|Instrumentos hidrológicos|O|O||D||1
41114301|Medidores de corriente para corriente abierta|O|O||D||1
41114302|Instrumentos de acceso a pozos de agua|O|O||D||1|Instrumentos de registro para pozos de agua
41114303|Grabadoras de nivel del agua en corrientes abiertas|O|O||D||1|Registradores de nivel de agua de corriente abierta
41114400|Instrumentos meteorológicos|O|O||D||1
41114401|Anemómetros|O|O||D||1
41114402|Barómetros|O|O||D||1
41114403|Grabadoras de precipitación o evaporación|O|O||D||1|Registradores de precipitación o evaporación
41114404|Aparatos de radiosonda|O|O||D||1
41114405|Grabadoras de lluvia|O|O||D||1
41114406|Aparatos para observar la precipitación o evaporación en la superficie|O|O||D||1
41114407|Aparatos para observar la radiación solar en la superficie|O|O||D||1|Aparatos para observar la radiación solar superficial
41114408|Aparatos para observar la temperatura o humedad en la superficie|O|O||D||1
41114409|Aparatos para observar el viento en la superficie|O|O||D||1
41114410|Estaciones meteorológicas|O|O||D||1
41114411|Accesorios para instrumentos de meteorología|O|O||D||1
41114412|Sistemas sonoros de radio acústica|O|O||D||1
41114413|Ceilómetro|O|O||D||1
41114414|Equipo receptor de satélite meteorológico|O|O||D||1
41114415|Sistema de análisis de rayos|O|O||D||1
41114416|Grabadora o escáner de tabla meteorológica|O|O||D||1
41114417|Robot boya meteorológica|O|O||D||1
41114418|Sistema para recibir y analizar información del satélite meteorológico|O|O||D||1
41114419|Sistema de alerta del nivel bajo del corte de viento|O|O||D||1|Sistema de alerta de corte de viento de bajo nivel
41114420|Calibrador de barómetros|O|O||D||1
41114421|Calibrador de higrómetros|O|O||D||1
41114422|Calibrador de medidor de lluvia|O|O||D||1
41114423|Calibrador de sistema automático de clima|O|O||D||1
41114424|Calibrador de anemómetros|O|O||D||1
41114425|Calibrador de actinómetros|O|O||D||1
41114426|Interruptor barométrico|O|O||D||1
41114427|Veletas|O|O||D||1
41114500|Instrumentos mecánicos|O|O||D||1
41114501|Dinamómetros|O|O||D||1
41114502|Elastómetros|O|O||D||1
41114503|Extensómetros|O|O||D||1
41114504|Instrumentos de medición de densidad|O|O||D||1
41114505|Instrumentos de prueba de redondez|O|O||D||1
41114506|Esferómetros|O|O||D||1
41114507|Maquinas de prueba de resortes|O|O||D||1
41114508|Probadores de superficie|O|O||D||1
41114509|Tensiómetros|O|O||D||1|Baumanómetro, Esfigmomanómetro, Esfingomanómetron, Manómetro ,
41114510|Limitador de torsión|O|O||D||1
41114511|Probador de suavidad|O|O||D||1
41114512|Probador de balance rotatorio de alta velocidad|O|O||D||1
41114513|Instrumento de medición de excentricidad|O|O||D||1
41114514|Instrumento de medición de vibración de torsión|O|O||D||1
41114515|Probador de fuerza centrífuga|O|O||D||1
41114516|Instrumento de medición de fuerza de corte|O|O||D||1
41114517|Probador de hinchazón hidráulica|O|O||D||1
41114518|Probador de soporte de cremallera|O|O||D||1
41114519|Sistema de remolque y carrito|O|O||D||1
41114520|Probador de caída|O|O||D||1
41114521|Probador de compresor de aire|O|O||D||1
41114522|Probador de engranajes|O|O||D||1
41114523|Barra de prueba|O|O||D||1
41114524|Probador hidráulico|O|O||D||1
41114525|Probador de filtros de aceite|O|O||D||1
41114526|Probador de limpiador de aire|O|O||D||1
41114527|Probador de correa|O|O||D||1
41114528|Instrumento de medición del mecanismo del movimiento de planeación|O|O||D||1
41114529|Probador de llantas en movimiento|O|O||D||1
41114530|Probador del estrés del pegante|O|O||D||1
41114600|Instrumentos de verificación de metales, metalurgia y materiales estructurales|O|O||D||1
41114601|Probadores de abrasión|O|O||D||1
41114602|Probadores de compresión|O|O||D||1
41114603|Instrumentos para probar concreto o cemento|O|O||D||1
41114604|Probadores de corrosión|O|O||D||1
41114605|Detectores de grietas o corrosión|O|O||D||1
41114606|Probadores de fuga|O|O||D||1
41114607|Máquinas para probar ductilidad|O|O||D||1
41114608|Probadores de fatiga|O|O||D||1
41114609|Aparatos probadores de forja|O|O||D||1
41114610|Aparatos probadores de fundición|O|O||D||1
41114611|Probadores de dureza|O|O||D||1
41114612|Probadores de impacto|O|O||D||1
41114613|Marco de carga|O|O||D||1
41114614|Instrumentos para probar metales|O|O||D||1
41114615|Instrumentos probadores foto elásticos|O|O||D||1
41114616|Indicadores de resistencia al estrés|O|O||D||1
41114617|Probadores de relajación|O|O||D||1
41114618|Instrumentos de medición de rugosidad|O|O||D||1
41114619|Probadores de fuerza de corte|O|O||D||1
41114620|Aparatos para probar choque|O|O||D||1
41114621|Probadores de tensión|O|O||D||1
41114622|Probadores de torsión|O|O||D||1
41114623|Máquinas para pruebas de flexión o transversales|O|O||D||1
41114624|Probadores de vibración|O|O||D||1
41114625|Probadores de desgaste|O|O||D||1
41114626|Aparatos para probar soldaduras|O|O||D||1|Aparatos para pruebas de soldadura
41114627|Aro de calibración|O|O||D||1
41114628|Probador de plasticidad|O|O||D||1
41114629|Probador de distorsión por calor|O|O||D||1
41114630|Probador de choque térmico|O|O||D||1
41114631|Probador de estrés|O|O||D||1
41114632|Probador de fuerza tensora|O|O||D||1
41114633|Probador de expansión térmica|O|O||D||1
41114634|Probador erichsen|O|O||D||1
41114635|Probador avalador de joyas|O|O||D||1|Probador de evaluación de joyas
41114636|Instrumento de medición de condición moldeadora de polímeros|O|O||D||1|Instrumento de medición de condiciones de moldeo de polímero
41114637|Aparatos de prueba de haces de luz|O|O||D||1|Aparatos de prueba de haz de luz
41114638|Probador de carga|O|O||D||1
41114639|Probador de flujo de cemento|O|O||D||1
41114640|Equipo de medición de plano de carretera|O|O||D||1
41114641|Equipo de curar cemento para laboratorio|O|O||D||1
41114642|Detector de perforación|O|O||D||1
41114643|Probador de estabilidad del cemento|O|O||D||1
41114644|Instrumento para medir aire en el concreto|O|O||D||1
41114645|Probador de longitud de mortero|O|O||D||1
41114646|Probador de aguja vicat|O|O||D||1
41114647|Probador de asentamiento|O|O||D||1
41114648|Probador de vibración del cemento o concreto|O|O||D||1
41114649|Probador de permeabilidad del mortero|O|O||D||1
41114650|Molde cilíndrico de concreto|O|O||D||1
41114700|Instrumentos para comprobación de papel, madera y tejidos|O|O||D||1
41114701|Instrumentos de prueba de cartón|O|O||D||1
41114702|Probadores de resistencia de textiles|O|O||D||1
41114703|Instrumentos para probar cuero|O|O||D||1|Instrumentos de prueba de cuero
41114704|Instrumentos para probar papel|O|O||D||1
41114705|Instrumentos para probar textiles|O|O||D||1
41114706|Instrumentos para probar madera|O|O||D||1
41114707|Probador de fuerza de textiles o papel|O|O||D||1
41114708|Probador de permeabilidad de vapor de agua|O|O||D||1
41114709|Instrumento para probar yam (textil sintético)|O|O||D||1
41114710|Probador de transmisión térmica|O|O||D||1
41114711|Probador de caída de textiles|O|O||D||1
41114712|Probador de repelencia de agua para textiles|O|O||D||1
41114713|Probador de recuperación de arrugas para textiles|O|O||D||1
41114714|Probador de maduración de textiles|O|O||D||1|Probador de madurez textil
41114715|Probador de permeabilidad al aire, papel o textiles|O|O||D||1
41114716|Probador de encogimiento de textiles|O|O||D||1
41114717|Probador de cocción de textiles|O|O||D||1|Probador para hornear textiles
41114718|Probador de grado de formación de motas para textiles|O|O||D||1|Probador de grado pilling textil
41114719|Máquina probadora de hojas de papel|O|O||D||1|Máquina de prueba de hojas de papel
41114720|Probador de absorción de agua de papel y paño|O|O||D||1
41114721|Probador de longitud de fibra|O|O||D||1
41114722|Probador de resistencia al rompimiento|O|O||D||1|Probador de fuerza de desgarro
41114723|Probador de fuerza de estallido|O|O||D||1
41114800|Instrumentos para comprobación de cerámica y vidrio|O|O||D||1
41114801|Instrumentos para probar cerámicas|O|O||D||1|Instrumentos de ensayo de cerámica
41114802|Instrumentos para probar vidrio|O|O||D||1|Instrumentos de prueba de vidrio
41114803|Instrumentos para probar alfarería|O|O||D||1|Instrumentos de prueba de cerámica
41115100|Instrumentos para comprobación de carbón y mineral|O|O||D||1
41115101|Instrumentos para probar carbón|O|O||D||1|Instrumentos de prueba de carbón
41115102|Goniómetro|O|O||D||1|Transportador
41115200|Sistemas y componentes de radar y sonar|O|O||D||1
41115201|Sistemas de vigilancia basados en radar|O|O||D||1
41115202|Polarrotores (elementos centrales de la antena)|O|O||D||1
41115203|Radar meteorológico|O|O||D||1
41115300|Equipo de generación y medición de luz y ondas|O|O||D||1
41115301|Medidores de absorción de luz|O|O||D||1
41115302|Cámaras anecóicas|O|O||D||1
41115303|Analizadores de frecuencia|O|O||D||1
41115304|Contadores o temporizadores o divisores de frecuencia|O|O||D||1
41115305|Medidores de frecuencia eléctrica|O|O||D||1
41115306|Interferómetros|O|O||D||1
41115307|Láseres|O|O||D||1
41115308|Medidores de luz|O|O||D||1
41115309|Luxómetros|O|O||D||1
41115310|Set de calibración óptica|O|O||D||1
41115311|Fotómetros|O|O||D||1
41115312|Polarímetros o refractómetros de mesa|O|O||D||1
41115313|Polarímetros o refractómetros manuales|O|O||D||1
41115314|Polarímetros|O|O||D||1
41115315|Polariscopios|O|O||D||1
41115316|Reflectómetros|O|O||D||1
41115317|Estroboscopios|O|O||D||1
41115318|Colorímetros|O|O||D||1
41115319|Lectores de tubo o disco|O|O||D||1
41115320|Generadores de señales|O|O||D||1
41115321|Imágenes infrarrojas|O|O||D||1|Cámaras infrarrojas
41115322|Analizadores de rayos láser|O|O||D||1
41115323|Generador de funciones|O|O||D||1
41115324|Sensor ultravioleta|O|O||D||1
41115325|Generador de imágenes térmico|O|O||D||1
41115326|Colimador óptico|O|O||D||1|Mira telescópica
41115327|Equipo de medición foto eléctrica|O|O||D||1|Equipo de medición fotoeléctrico
41115328|Sintetizador de forma de onda|O|O||D||1
41115329|Equipo de medición de propagación de radioonda|O|O||D||1|Equipo de medición de la propagación de ondas radioeléctricas
41115330|Medidor de opacidad|O|O||D||1
41115331|Instrumento medidor de brillo|O|O||D||1
41115332|Medidor de largo de onda óptica|O|O||D||1
41115333|Instrumento medidor de fotones|O|O||D||1
41115334|Probador de blancura|O|O||D||1
41115335|Vectorscopio|O|O||D||1
41115336|Lámpara de rayos ultravioleta para laboratorio|O|O||D||1
41115337|Instrumento de medición de ondas|O|O||D||1
41115338|Medidor de iluminancia|O|O||D||1
41115339|Elipsómetro|O|O||D||1
41115400|Equipo espectroscópico|O|O||D||1
41115401|Espectrofluorímetros o fluorímetros|O|O||D||1
41115402|Espectrógrafos|O|O||D||1
41115403|Espectrómetros|O|O||D||1
41115404|Espectrómetros de masa|O|O||D||1
41115405|Espectrómetros de protón|O|O||D||1
41115406|Espectrofotómetros|O|O||D||1
41115407|Espectrómetros de absorción atómica aa|O|O||D||1
41115408|Espectrómetros infrarrojos|O|O||D||1
41115409|Espectrómetros de resonancia magnética nuclear nmr|O|O||D||1
41115411|Espectrómetros de plasma acoplado inductivamente icp|O|O||D||1
41115412|Espectro bolómetro|O|O||D||1
41115413|Citómetro de flujo|O|O||D||1
41115414|Sistema de espectroscopia de rayo radio|O|O||D||1
41115415|Sistema de espectroscopio de electrones para análisis químico|O|O||D||1
41115416|Espectrómetro de resonancia de giro de electrones|O|O||D||1
41115500|Equipo de generación y medición de sonido|O|O||D||1
41115501|Sonares|O|O||D||1
41115502|Sonómetros|O|O||D||1
41115503|Aparatos para medir el sonido o medidores de decibeles|O|O||D||1|Instrumento para medir el sonido o medidores de decibeles
41115504|Analizadores de velocidad del sonido|O|O||D||1
41115505|Cuartos para pruebas acústicas|O|O||D||1
41115506|Generador de ruidos|O|O||D||1
41115507|Analizador de voz|O|O||D||1
41115508|Detector de sonido|O|O||D||1
41115509|Detector de cables y tubos subterráneos|O|O||D||1
41115510|Detector de fuga de tubos de agua|O|O||D||1
41115511|Probador de audífonos|O|O||D||1
41115512|Emisor de onda acústica|O|O||D||1
41115513|Generador acústico|O|O||D||1
41115514|Sonoboya|O|O||D||1
41115515|Hidrófono|O|O||D||1
41115600|Instrumentos y accesorios de medición electroquímica|O|O||D||1
41115601|Equipo de análisis volumétrico karl fischer|O|O||D||1|Valorador volumétrico Karl Fischer
41115602|Equipo de análisis volumétrico|O|O||D||1
41115603|Medidores de ph|O|O||D||1|Medidores de pH
41115604|Electrodos de ph|O|O||D||1|Electrodos de pH
41115606|Medidores de electrodos selectivos de iones ise|O|O||D||1
41115607|Tiras de prueba de iones selectivos|O|O||D||1
41115608|Electrodos selectivos de iones|O|O||D||1
41115609|Medidores de conductividad|O|O||D||1
41115610|Celdas de conductividad|O|O||D||1
41115611|Medidores de oxígeno disuelto|O|O||D||1
41115612|Sondas de oxigeno disuelto|O|O||D||1
41115613|Medidor de salinidad|O|O||D||1
41115614|Transmisores de ph|O|O||D||1
41115615|Controlador de ph|O|O||D||1
41115700|Instrumentos y accesorios de medición cromatográfica|O|O||D||1
41115701|Detectores cromatográficos|O|O||D||1
41115702|Escáneres cromatográficos|O|O||D||1
41115703|Gases cromatográficos|O|O||D||1|Cromatógrafos de gas
41115704|Iones cromatográficos|O|O||D||1|Cromatógrafo de iones
41115705|Cromatógrafos líquidos|O|O||D||1
41115706|Cromatógrafos de capa delgada|O|O||D||1
41115707|Cromatógrafos para cromatografía de líquido de alta presión|O|O||D||1
41115708|Cromatógrafos de capa delgada de alta presión tlc|O|O||D||1
41115709|Columnas para cromatografía líquida de alta presión hplc|O|O||D||1
41115710|Columnas para cromatografía de gas|O|O||D||1|Columnas GC para cromatografía de gas
41115711|Columnas para cromatografía líquida lc|O|O||D||1|Columnas LC para cromatografía líquida
41115712|Columnas para extracción de fase sólida spe|O|O||D||1|Columnas SPE de extracción en fase sólida
41115713|Tanques para cromatografía de capa delgada|O|O||D||1
41115714|Auto muestreadores|O|O||D||1
41115715|Inyectores|O|O||D||1
41115716|Accesorios para cromatografía líquida|O|O||D||1
41115717|Accesorios para cromatografía de gas|O|O||D||1
41115718|Inyector de paredes de membrana|O|O||D||1
41115719|Revestimientos para cromatografía de gas|O|O||D||1
41115720|Tubos para cromatografía|O|O||D||1
41115721|Sistema de cromatografía líquida de proteínas rápidas fplc|O|O||D||1
41115722|Columna para cromatografía líquida de proteínas rápidas fplc|O|O||D||1
41115723|Cromatógrafo de fluido súper crítico|O|O||D||1
41115800|Analizadores, accesorios y suministros clínicos y diagnósticos|O|O||D||1
41115801|Analizadores de amino ácidos|O|O||D||1
41115802|Accesorios o suministros para analizadores de amino ácidos|O|O||D||1
41115803|Analizadores de bancos de sangre|O|O||D||1
41115804|Accesorios o suministros para analizadores de bancos de sangre|O|O||D||1
41115805|Analizadores de gas en la sangre|O|O||D||1
41115806|Accesorios o suministros para analizadores de gas en la sangre|O|O||D||1
41115807|Analizadores químicos|O|O||D||1
41115808|Accesorios o suministros para analizadores químico|O|O||D||1
41115809|Analizadores de coagulación|O|O||D||1
41115810|Accesorios o suministros para analizadores de coagulación|O|O||D||1
41115811|Analizadores de secuencia desoxirribonucleica|O|O||D||1
41115812|Accesorios o suministros para analizadores de secuencia desoxirribonucleica|O|O||D||1
41115813|Analizadores de toxicología|O|O||D||1
41115814|Accesorios o suministros para analizadores de toxicología|O|O||D||1
41115815|Analizadores de hematología|O|O||D||1
41115816|Accesorios o suministros para analizadores de hematología|O|O||D||1
41115817|Analizadores de histología|O|O||D||1
41115818|Accesorios o suministros para analizadores de histología|O|O||D||1
41115819|Analizadores de inmunología|O|O||D||1
41115820|Accesorios o suministros para analizadores de inmunología|O|O||D||1
41115821|Analizadores de microbiología|O|O||D||1
41115822|Accesorios o suministros para analizadores de microbiología|O|O||D||1
41115823|Analizadores de proteína|O|O||D||1
41115824|Accesorios o suministros para analizadores de proteína|O|O||D||1
41115825|Analizadores radio isotópicos|O|O||D||1
41115826|Accesorios o suministros para analizadores radio isotópicos|O|O||D||1
41115827|Analizadores de orina|O|O||D||1
41115828|Accesorios o suministros para analizadores de orina|O|O||D||1
41115829|Analizadores de productos cárnicos o lácteos|O|O||D||1
41115830|Analizadores de glucosa|O|O||D||1
41115831|Estante o revistero para la manipulación de micro placas|O|O||D||1
41115832|Equipo para detección de antibióticos|O|O||D||1
41115833|Analizador de piel|O|O||D||1
41115834|Accesorios o suministros para citómetro de flujo|O|O||D||1
41115835|Contador automático de androginia y fertilidad|O|O||D||1
41115836|Accesorios o suministros para contador automático de androginia y fertilidad|O|O||D||1
41115837|Contador y medidor de tamaño de partículas|O|O||D||1
41115838|Accesorios o suministros para contador y medidor de tamaño de partículas|O|O||D||1
41115839|Analizador de unidad procesadora de aféresis de banco de sangre y donantes|O|O||D||1
41115840|Accesorios o suministros para analizador de unidad procesadora de aféresis de banco de sangre y donantes|O|O||D||1
41116000|Reactivos de analizadores clínicos y diagnósticos|O|O||D||1
41116001|Reactivos analizadores de amino ácidos|O|O||D||1
41116002|Reactivos analizadores de bancos de sangre|O|O||D||1
41116003|Reactivos analizadores de gas en la sangre|O|O||D||1
41116004|Reactivos analizadores de química|O|O||D||1
41116005|Reactivos analizadores de coagulación|O|O||D||1
41116006|Reactivos analizadores de secuencia de ácido desoxirribonucleico dna|O|O||D||1
41116007|Reactivos analizadores de toxicología|O|O||D||1
41116008|Reactivos analizadores de hematología|O|O||D||1
41116009|Reactivos analizadores de histología|O|O||D||1
41116010|Reactivos analizadores de inmunología|O|O||D||1
41116011|Reactivos analizadores de microbiología|O|O||D||1
41116012|Reactivos analizadores de proteínas|O|O||D||1
41116013|Reactivos analizadores radio isotópicos|O|O||D||1
41116014|Reactivos analizadores de análisis de orina|O|O||D||1
41116015|Reactivos o anticuerpos analizadores de citometría de flujo|O|O||D||1
41116016|Reactivo analizador de electrolitos|O|O||D||1
41116017|Reactivo contador automático de androginia y fertilidad|O|O||D||1
41116018|Reactivo analizador contador y medidor de tamaño de partículas|O|O||D||1
41116100|Kits de ensayos manuales, controles de calidad, calibradores y normativas|O|O||D||1
41116101|Kits o suministros de prueba de bancos de sangre|O|O||D||1
41116102|Reactivos o soluciones de bancos de sangre|O|O||D||1
41116103|Controles de calidad o calibradores o estándares de bancos de sangre|O|O||D||1
41116104|Kits o suministros para pruebas químicas|O|O||D||1
41116105|Reactivos o soluciones químicas|O|O||D||1
41116106|Tiras de prueba o papel de prueba químico|O|O||D||1
41116107|Controles de calidad o calibradores o estándares químicos|O|O||D||1
41116108|Kits o suministros para pruebas de coagulación|O|O||D||1
41116109|Reactivos o soluciones de coagulación|O|O||D||1
41116110|Controles de calidad o calibradores o estándares de coagulación|O|O||D||1
41116111|Kits o suministros para pruebas de citología|O|O||D||1
41116112|Controles de calidad o calibradores o estándares de citología|O|O||D||1
41116113|Reactivos o soluciones o tinturas para citología|O|O||D||1
41116116|Kits o suministros para pruebas ambientales|O|O||D||1
41116117|Reactivos o soluciones o tinturas ambientales|O|O||D||1
41116118|Kits o suministros para pruebas de alimentos|O|O||D||1
41116119|Reactivos o soluciones o tinturas para kits de pruebas de alimentos|O|O||D||1
41116120|Kits o suministros para pruebas de hematología|O|O||D||1
41116121|Reactivos o soluciones o tinturas para hematología|O|O||D||1
41116122|Controles de calidad o calibradores o estándares para hematología|O|O||D||1
41116123|Kits o suministros para pruebas de histología|O|O||D||1
41116124|Reactivos o soluciones o tinturas para histología|O|O||D||1
41116125|Controles de calidad o calibradores o estándares para histología|O|O||D||1
41116126|Kits o suministros para pruebas de inmunología o serología|O|O||D||1
41116127|Reactivos o soluciones o tinturas para inmunología o serología|O|O||D||1
41116128|Controles de calidad o calibradores o estándares para inmunología o serología|O|O||D||1
41116129|Kits o suministros para pruebas de microbiología o bacteriología|O|O||D||1
41116130|Reactivos o soluciones o tinturas para microbiología o bacteriología|O|O||D||1
41116131|Discos o paneles de identificación o sensibilidad para microbiología o bacteriología|O|O||D||1
41116132|Controles de calidad o calibradores o estándares para microbiología o bacteriología|O|O||D||1
41116133|Kits o suministros para pruebas de biología molecular|O|O||D||1
41116134|Reactivos o soluciones o tinturas para biología molecular|O|O||D||1
41116135|Controles de calidad o calibradores o estándares para biología molecular|O|O||D||1
41116136|Kits o suministros para análisis de orina|O|O||D||1
41116137|Reactivos o soluciones o tinturas para análisis de orina|O|O||D||1
41116138|Tiras para análisis de orina|O|O||D||1
41116139|Controles de calidad o calibradores o estándares de análisis de orina|O|O||D||1
41116140|Kits o suministros para parasitología o micología|O|O||D||1
41116141|Reactivos o soluciones o tinturas para parasitología o micología|O|O||D||1
41116142|Medio para parasitología o micología|O|O||D||1|Instrumentos para parasitología o micología
41116143|Controles de calidad o calibradores o estándares de parasitología o micología|O|O||D||1
41116144|Kits o suministros para pruebas de virología|O|O||D||1
41116145|Controles de calidad o calibradores o estándares para virología|O|O||D||1
41116146|Kits o suministros para pruebas de toxicología|O|O||D||1|Kits de prueba de toxicología o suministros
41116147|Controles de calidad o calibradores o estándares para toxicología|O|O||D||1
41116148|Kits o suministros para pruebas de citometría de flujo|O|O||D||1
41116149|Probador de lisado de limulus amebocita|O|O||D||1
41116150|Kits o suministros para pruebas de androgénesis y fertilidad|O|O||D||1
41116151|Controles de calidad o calibradores o estándares para androgénesis y fertilidad|O|O||D||1
41116152|Controles de calidad o calibradores o estándares para citometría de flujo|O|O||D||1
41116153|Controles de calidad o calibradores o estándares para inmunohistoquímica|O|O||D||1
41116154|Controles de calidad o calibradores o estándares para contar y determinar el tamaño de las partículas|O|O||D||1
41116155|Medio de crecimiento de cultura de células y biología molecular|O|O||D||1|Materiales de crecimiento de cultivo de células y biología molecular
41116156|Reactivos o soluciones o tinturas de virología|O|O||D||1
41116157|Medio de cultura de tejidos y células de virología|O|O||D||1|Materiales de cultivo de tejidos y células de virología
41116200|Suministros y equipo para lugares de tratamiento de pacientes|O|O||D||1
41116201|Monitores o medidores de glucosa|O|O||D||1
41116202|Monitores o medidores de colesterol|O|O||D||1
41116203|Accesorios para monitores o medidores|O|O||D||1
41116205|Kits de pruebas rápidas|O|O||D||1
41116206|Bebidas de diagnóstico para pruebas de laboratorio|O|O||D||1
41116207|Monitores o medidores de hemoglobina o hematocritos|O|O||D||1
41116208|Monitores o medidores de parámetros múltiples de química sanguínea|O|O||D||1
41116209|Monitores o medidores de múltiples parámetros de coagulación de la sangre|O|O||D||1
41116210|Monitores o medidores analizadores de aliento de desorden metabólico|O|O||D||1
41116211|Analizador de aliento de etanol|O|O||D||1
41116212|Controles de calidad o calibradores o estándares para monitores o medidores|O|O||D||1
41116300|Comprobadores de punto de inflamación para laboratorio|O|O||D||1
41116301|Probadores de punto de inflamación|O|O||D||1
41116302|Probador de incombustibilidad|O|O||D||1
41116303|Probador de inflamabilidad|O|O||D||1
41116304|Probador de punto de ignición|O|O||D||1
41116400|Instrumentos de medición de la aceleración y la vibración|O|O||D||1
41116401|Martillos de impacto|O|O||D||1
41116500|Piezas y accesorios de instrumentos|O|O||D||1
41116501|Diales o kits de diales de medición|O|O||D||1
41116502|Clip eléctrico|O|O||D||1
41121500|Equipo y suministros de pipetas y manipulación de líquidos|O|O||D||1
41121501|Sistemas de manipulación líquida automática o robótica|O|O||D||1
41121502|Diluidores de laboratorio|O|O||D||1
41121503|Pipeta de desplazamiento de aire multicanal manuales|O|O||D||1
41121504|Pipeta de desplazamiento de aire de un solo canal manuales|O|O||D||1
41121505|Pipeta de desplazamiento positivo de un solo canal manuales|O|O||D||1
41121506|Pipeta repetidoras de un solo canal manuales|O|O||D||1
41121507|Pipeta de un solo canal electrónicas|O|O||D||1
41121508|Pipeta multicanales electrónicas|O|O||D||1
41121509|Pipetas pasteur o de transferencia|O|O||D||1
41121510|Pipetas volumétricas|O|O||D||1
41121511|Pipetas serológicas|O|O||D||1
41121513|Pipetas de caída|O|O||D||1
41121514|Bombas de pipetas|O|O||D||1
41121515|Bombillos de pipetas|O|O||D||1|Bombillas de pipetas
41121516|Dispensadores de tapas de botella|O|O||D||1
41121517|Insertos o accesorios para pipeteras|O|O||D||1
41121600|Puntas de pipeta|O|O||D||1
41121601|Filtro de boquilla de pipeta|O|O||D||1
41121602|Puntas de pipeta de barrera de aerosol|O|O||D||1
41121603|Puntas de pipeta de baja retención|O|O||D||1
41121604|Puntas de pipeta de referencia|O|O||D||1
41121605|Puntas de pipeta ultra micro|O|O||D||1
41121606|Puntas de pipeta de carga de gel|O|O||D||1
41121607|Puntas de pipeta universales|O|O||D||1
41121608|Puntas de pipeta robóticas|O|O||D||1
41121609|Puntas de pipeta de volumen variable|O|O||D||1
41121700|Tubos de ensayo|O|O||D||1
41121701|Tubos de ensayo general o multipropósito|O|O||D||1
41121702|Tubos micro centrífugos|O|O||D||1
41121703|Tubos centrífugos|O|O||D||1
41121704|Tubos criogénicos|O|O||D||1
41121705|Tubos de resonancia magnética nuclear nmr|O|O||D||1
41121706|Tubos de cultivo|O|O||D||1
41121707|Tubos de pruebas de separador|O|O||D||1
41121708|Tubos de pruebas de anti coagulación|O|O||D||1
41121709|Tubos capilares o hematocritos|O|O||D||1
41121710|Cierres o tapas para tubos de ensayo|O|O||D||1
41121711|Tubos o accesorios para pruebas de análisis de orina|O|O||D||1
41121712|Tubos viscosímetros|O|O||D||1
41121713|Analizador de tamaño de arena|O|O||D||1
41121800|Artículos de vidrio o plástico y suministros generales de laboratorio|O|O||D||1
41121801|Vasos de observación para laboratorio|O|O||D||1
41121802|Varillas para revolver para laboratorio|O|O||D||1
41121803|Vasos de precipitados para laboratorio|O|O||D||1
41121804|Redomas para laboratorio|O|O||D||1
41121805|Cilindros graduados para laboratorio|O|O||D||1
41121806|Frascos para laboratorio|O|O||D||1
41121807|Ampollas para laboratorio|O|O||D||1
41121808|Buretas para laboratorio|O|O||D||1
41121809|Embudos para laboratorio|O|O||D||1
41121810|Platos o frascos para tintura para laboratorio|O|O||D||1
41121811|Kits de micro química para laboratorio|O|O||D||1
41121812|Platos para laboratorio|O|O||D||1
41121813|Cubetas|O|O||D||1
41121814|Tapas o forros o forros deslizantes para laboratorio|O|O||D||1
41121815|Adaptadores o conectores o instalaciones para laboratorio|O|O||D||1
41121816|Tubo de vidrio para laboratorio|O|O||D||1
41121817|Vidrio curvado para laboratorio|O|O||D||1|Vidrio curvo para laboratorio
41121818|Botella de almacenamiento para laboratorio|O|O||D||1
41121819|Botella de gotero y tapa de gotero|O|O||D||1
41122000|Jeringuillas de laboratorio o de muestreo|O|O||D||1
41122001|Jeringas de cromatografía|O|O||D||1
41122002|Agujas para jeringas de cromatografía|O|O||D||1
41122003|Adaptadores o accesorios para jeringa|O|O||D||1
41122004|Jeringas para muestras|O|O||D||1
41122100|Suministros de cultivo de tejido y cribado de alta definición|O|O||D||1
41122101|Platos o placas petri|O|O||D||1
41122102|Platos multi pocillo|O|O||D||1|Placas multipocillo
41122103|Espátulas de células|O|O||D||1
41122104|Frascos de cultivo de tejidos|O|O||D||1
41122105|Botellas de cultivo rotatorias|O|O||D||1
41122106|Dispositivos de inoculación|O|O||D||1
41122107|Platos o placas o insertos recubiertos para cultivo de tejidos|O|O||D||1
41122108|Presillos o agujas para inoculación microbiológica|O|O||D||1
41122109|Almohadilla de petri|O|O||D||1
41122110|Dispensador de almohadillas de petri|O|O||D||1
41122200|Crisoles|O|O||D||1
41122201|Crisoles de vidrio|O|O||D||1
41122202|Crisoles cerámicos|O|O||D||1
41122203|Crisoles de metal|O|O||D||1
41122300|Protectores y revestimientos de banco de laboratorio|O|O||D||1
41122301|Protectores o revestimientos de mesa de trabajo|O|O||D||1
41122400|Instrumentos de laboratorio|O|O||D||1
41122401|Barras giratorias, barras para revolver o gotas para revolver magnéticas|O|O||D||1
41122402|Recuperadores magnéticos de barras giratorias o recuperadores de barras giratorias|O|O||D||1
41122403|Espátulas para laboratorio|O|O||D||1
41122404|Tenazas para laboratorio|O|O||D||1
41122405|Fórceps para laboratorio|O|O||D||1
41122406|Cuchillos para laboratorio|O|O||D||1
41122407|Escalpelos para laboratorio|O|O||D||1
41122408|Tijeras para laboratorio|O|O||D||1
41122409|Herramientas para laboratorio|O|O||D||1
41122410|Película sellante para laboratorio|O|O||D||1
41122411|Cronómetros o relojes para laboratorio|O|O||D||1
41122412|Sellantes de tubos para laboratorio|O|O||D||1
41122413|Pinzas para laboratorio|O|O||D||1
41122414|Cuchara para laboratorio|O|O||D||1
41122415|Cristales de bioseparación centrífuga|O|O||D||1
41122500|Corchos, tapones y accesorios de laboratorio|O|O||D||1
41122501|Corchos para laboratorio|O|O||D||1
41122502|Tapones para laboratorio|O|O||D||1
41122503|Porta corchos para laboratorio|O|O||D||1
41122600|Portaobjetos de laboratorio y suministros|O|O||D||1
41122601|Portaobjetos para microscopios|O|O||D||1
41122602|Portaobjetos de microscopio|O|O||D||1
41122603|Papel de lentes para microscopio|O|O||D||1
41122604|Hemocitómetros|O|O||D||1
41122605|Aceite de inmersión para microscopios|O|O||D||1
41122606|Dispensadores de portaobjetos para microscopio|O|O||D||1
41122607|Solución limpiadora de lentes para microscopio|O|O||D||1
41122700|Cintas y etiquetas de laboratorio|O|O||D||1
41122701|Etiquetas para portaobjetos o especímenes|O|O||D||1
41122702|Cintas etiquetadoras|O|O||D||1
41122703|Cintas de seguridad|O|O||D||1
41122704|Cintas contra alteración|O|O||D||1|Cintas de seguridad contra alteración
41122800|Estantes, soportes y bandejas de laboratorio|O|O||D||1
41122801|Estantes o soportes para pipetas|O|O||D||1
41122802|Estantes para portaobjetos de microscopios|O|O||D||1
41122803|Estantes o soportes para tubos para sedimentación|O|O||D||1
41122804|Estantes para tubos de ensayo|O|O||D||1
41122805|Estantes para secado|O|O||D||1
41122806|Estantes para unidades de criopreservación|O|O||D||1
41122807|Bandejas para disección|O|O||D||1
41122808|Bandejas para propósitos generales|O|O||D||1|Bandejas de uso general de laboratorio
41122809|Estantes para placas petri|O|O||D||1
41122810|Estantes de almacenamiento de reactivos para la mesa de trabajo|O|O||D||1
41122811|Dispensador de tubos de cultivo y prueba|O|O||D||1
41123000|Desecadores y desecantes de laboratorio|O|O||D||1
41123001|Deshidratadores de frasco|O|O||D||1
41123002|Deshidratadores de gabinete|O|O||D||1
41123003|Desecantes|O|O||D||1
41123004|Deshidratadores de vacío|O|O||D||1
41123005|Contenedor de almacenamiento de disco desecante microbiológicamente susceptible|O|O||D||1
41123100|Suministros de diálisis para laboratorio|O|O||D||1
41123101|Tubos de diálisis|O|O||D||1
41123102|Pinzas de diálisis|O|O||D||1
41123103|Casete de diálisis|O|O||D||1
41123104|Membrana de diálisis|O|O||D||1
41123105|Porta casete de diálisis|O|O||D||1|Porta casete de diálisis
41123200|Especímenes preservados y suministros|O|O||D||1
41123201|Portaobjetos preparados preservados|O|O||D||1
41123202|Animales y organismos preservados|O|O||D||1
41123300|Contenedores y armarios de almacenamiento general para laboratorio|O|O||D||1
41123302|Cajas o folders para portaobjetos para microscopios|O|O||D||1
41123303|Gabinetes para portaobjetos para microscopios|O|O||D||1|Caja para portar objetos para microscopios
41123304|Cajas de almacenamiento criogénicas|O|O||D||1|Cajas para almacenamiento de viales criogénicos
41123305|Gabinetes para casetes de tejidos o histología|O|O||D||1|Gabinetes para casete de tejidos o histología
41123306|Accesorios para casetes de tejidos o histología|O|O||D||1|Accesorios para casete de tejido o histología
41123400|Dispositivos de dosificación|O|O||D||1
41123401|Tazas dosificadoras|O|O||D||1
41123402|Cucharas dosificadoras|O|O||D||1
41123403|Goteros dosificadores|O|O||D||1
42121500|Equipo veterinario|O|O||D||1
42121501|Probadores de presión sanguínea para uso veterinario|O|O||D||1
42121502|Probador quimiógrafo para uso veterinario|O|O||D||1|Probador quimógrafo para uso veterinario
42121503|Probador pirogénico para uso veterinario|O|O||D||1
42121504|Equipo estereotóxico para uso veterinario|O|O||D||1|Equipo esterotáctico para uso veterinario
42121505|Electrocardiógrafo ecg para uso veterinario|O|O||D||1|Electrocardiógrafo para veterinaria
42121506|Sets de instrumentos quirúrgicos para uso veterinario|O|O||D||1|Conjuntos de instrumentos quirúrgicos veterinarios
42121507|Unidades o accesorios de inyección o succión para uso veterinario|O|O||D||1
42121508|Sets de botellas para uso veterinario|O|O||D||1|Conjuntos de botellas veterinarias
42121509|Termómetros clínicos para uso veterinario|O|O||D||1
42121510|Cajas de instrumentos o accesorios para uso veterinario|O|O||D||1
42121511|Estuches enrollables para instrumentos o accesorios de uso veterinario|O|O||D||1
42121512|Espéculos para uso veterinario|O|O||D||1
42121513|Instrumentos de castración para uso veterinario|O|O||D||1
42121514|Kits de fijación externa para uso veterinario|O|O||D||1|Juegos veterinarios de fijación externa
42121515|Limas o cortaúñas para uso veterinario|O|O||D||1
42121600|Productos veterinarios|O|O||D||1
42121601|Productos gastrointestinales para uso veterinario|O|O||D||1|Medicamentos contra problemas gastrointestinales de uso veterinario
42121602|Productos para sangre o formación de sangre para uso veterinario|O|O||D||1|Medicamentos para sangre o formación de sangre para uso veterinario
42121603|Productos para el sistema respiratorio para uso veterinario|O|O||D||1|Medicamentos para el sistema respiratorio para uso veterinario
42121604|Productos para el sistema musculo esquelético o nervioso para uso veterinario|O|O||D||1|Medicamentos para el sistema musculo esquelético o nervioso para uso veterinario
42121605|Productos para el sistema cardiovascular para uso veterinario|O|O||D||1|Medicamentos para el sistema cardiovascular para uso veterinario
42121606|Productos dermatológicos o anti protozoarios para uso veterinario|O|O||D||1|Medicamentos dermatológicos o anti protozoarios para uso veterinario
42121607|Productos para el sistema sexual genital urinario u hormonales para uso veterinario|O|O||D||1|Medicamentos para el sistema sexual genital urinario u hormonales para uso veterinario
42121608|Productos dentales para uso veterinario|O|O||D||1|Medicamentos dentales para uso veterinario
42121700|Mobiliario clínico veterinario|O|O||D||1
42121701|Tablas quirúrgicas para uso veterinario|O|O||D||1|Mesas quirúrgicas para uso veterinario
42121702|Armarios de almacenamiento para uso veterinario|O|O||D||1
42121800|Equipo y suministros para inseminación artificial veterinaria|O|O||D||1
42121801|Máquina para inseminación artificial|O|O||D||1
42121802|Instrumento para recolección de semen|O|O||D||1
42121803|Estimulador de eyaculación eléctrico|O|O||D||1
42121804|Instrumento para empaquetar semen|O|O||D||1
42131500|Vestuario para pacientes|O|O||D||1|Ropa para pacientes
42131501|Petos para pacientes|O|O||D||1|Babero para pacientes
42131502|Gorras para pacientes|O|O||D||1
42131503|Capas de examen para pacientes|O|O||D||1
42131504|Batas para pacientes|O|O||D||1
42131505|Camisas o chalecos para pacientes bebés|O|O||D||1
42131506|Chaquetas para pacientes|O|O||D||1|Chaqueta de fuerza para pacientes
42131507|Pantuflas para pacientes|O|O||D||1
42131508|Pijamas para pacientes|O|O||D||1
42131509|Batas de hospital|O|O||D||1
42131510|Pantalones para pacientes|O|O||D||1
42131511|Prenda para hidroterapia|O|O||D||1
42131512|Gorra o sombrero o material para gorra para paciente bebé|O|O||D||1
42131600|Vestuario para el personal sanitario y artículos relacionados|O|O||D||1|Ropa de personal médico y artículos relacionados
42131601|Delantales o petos para personal médico|O|O||D||1|Delantales o baberos para personal médico
42131602|Cobertores de barba para personal médico|O|O||D||1|Cubierta de barba para personal médico
42131603|Blusas o blusones para personal médico|O|O||D||1|Bata o blusa para personal médico
42131604|Gorro de quirófano para personal médico|O|O||D||1
42131605|Overoles para personal médico|O|O||D||1
42131606|Máscaras quirúrgicas o de aislamiento para personal médico|O|O||D||1|Cubrebocas
42131607|Chaquetas o batas para personal médico|O|O||D||1
42131608|Vestidos para cirugía para personal médico|O|O||D||1|Ropa de cirugía para personal médico
42131609|Cubiertas para zapatos para personal médico|O|O||D||1
42131610|Protección de mangas para personal médico|O|O||D||1
42131611|Gorros o capuchas para cirujano|O|O||D||1
42131612|Batas de aislamiento para personal médico|O|O||D||1
42131613|Protectores de ojos o visores para personal médico|O|O||D||1
42131700|Prendas textiles quirúrgicas|O|O||D||1
42131701|Cortinas de cirugía|O|O||D||1|Cortinas quirúrgicas
42131702|Batas de cirugía|O|O||D||1|Batas quirúrgicas
42131704|Toallas de cirugía|O|O||D||1|Toallas quirúrgicas
42131705|Pantalones (“leggings”) de cirugía|O|O||D||1|Polainas quirúrgicas
42131706|Vestidos enteros de cirugía|O|O||D||1|Ropa quirúrgica desechable
42131707|Vestidos o cascos o máscaras faciales o accesorios de aislamiento de cirugía|O|O||D||1|Trajes de aislamiento quirúrgico o cascos o mascarillas o accesorios
42131708|Paquete o kit para limpieza quirúrgica o rotación de salas quirúrgicas|O|O||D||1
42132100|Ropa blanca del hospital|O|O||D||1
42132101|Protectores de colchón o silla para hospital|O|O||D||1
42132102|Sábanas elásticas médicas|O|O||D||1
42132103|Cortinas de barrera para pacientes|O|O||D||1
42132104|Almohadas antimicrobianas para hospital|O|O||D||1
42132105|Sábanas para hospital|O|O||D||1
42132106|Colchas o cubrecamas para hospital|O|O||D||1
42132107|Cobijas para hospital|O|O||D||1
42132108|Fundas protectoras de almohada para hospital|O|O||D||1
42132200|Guantes y accesorios médicos|O|O||D||1
42132201|Cajas o dispensadores de guantes médicos|O|O||D||1
42132202|Protector de caucho para dedos.|O|O||D||1|Protectores de látex para dedos
42132203|Guantes de examen o para procedimientos no quirúrgicos|O|O||D||1
42132204|Recubrimientos interiores para guantes médicos|O|O||D||1|Guantes quirúrgicos interiores
42132205|Guantes de cirugía|O|O||D||1|Guantes quirúrgicos
42141500|Bolas de algodón y copitos aplicadores|O|O||D||1
42141501|Bolas o fibra de algodón|O|O||D||1
42141502|Palitos (copitos) con punta de fibra|O|O||D||1|Cotonete, Hisopo
42141503|Toallitas de preparación de la piel|O|O||D||1
42141504|Aplicadores o absorbentes medicados|O|O||D||1
42141600|Palanganas y Bacinillas de cama y orinales y equipos de ingreso|O|O||D||1
42141601|Kits de admisión para el cuidado del paciente|O|O||D||1
42141602|Patos (bacinillas) para uso general|O|O||D||1
42141603|Recipientes para emesis (vómito)|O|O||D||1
42141605|Recipientes o cuencos para soluciones o mezclas médicas|O|O||D||1
42141606|Recipientes multipropósito para usos médicos|O|O||D||1|Recipientes multifuncionales para uso médico
42141607|Orinales de uso general para pacientes|O|O||D||1
42141608|Bolsas o recubrimientos para patos (bacinillas)|O|O||D||1
42141700|Productos para la prevención de decúbito|O|O||D||1
42141701|Sistemas de presión alterna|O|O||D||1|Colchón de presión alterna
42141702|Marcos o elevadores de cobijas|O|O||D||1
42141703|Cunas para extremidades|O|O||D||1
42141704|Recubrimientos para colchones|O|O||D||1
42141705|Almohadones o almohadillas o almohadas para la posición del paciente|O|O||D||1
42141800|Equipo de electroterapia|O|O||D||1
42141801|Unidades de combinación de electroterapia|O|O||D||1
42141802|Electrodos o accesorios para electroterapia|O|O||D||1
42141803|Cables o alambres de plomo para electroterapia|O|O||D||1
42141804|Simuladores galvánicos o farádicos|O|O||D||1
42141805|Estimuladores o kits neuromusculares|O|O||D||1
42141806|Unidades de diatermia de onda corta|O|O||D||1
42141807|Unidades de estimulación nerviosa eléctrica transcutánea|O|O||D||1
42141808|Electrodos de diatermia|O|O||D||1
42141809|Sets de estimulador muscular|O|O||D||1
42141810|Electrodo de iontoforesis|O|O||D||1
42141811|Sistema de terapia de ondas de choque extracorpóreas|O|O||D||1
42141812|Generador de electricidad estática para estimulación eléctrica|O|O||D||1
42141813|Dispositivo electro convulsivo|O|O||D||1
42141814|Estimulador de electricidad estática|O|O||D||1
42141815|Estimulador de ondas electromagnéticas de alta frecuencia|O|O||D||1
42141816|Estimulador de terapia electromagnética|O|O||D||1
42141817|Estimulador de pulso magnético|O|O||D||1
42141900|Suministros para la administración de enema|O|O||D||1
42141901|Baldes para enema|O|O||D||1
42141902|Bolsas para enema|O|O||D||1
42141903|Kits o accesorios para enema|O|O||D||1
42141904|Tubos o tapas o pinzas para enema|O|O||D||1
42141905|Jabones para enema|O|O||D||1
42142000|Instrumentos de grado bajo "floor grade"|O|O||D||1
42142001|Fórceps o homeostatos de bajo grado|O|O||D||1|Pinzas homeostáticas
42142002|Cuchillo de bajo grado|O|O||D||1
42142003|Manijas para cuchillo de bajo grado|O|O||D||1
42142004|Corta uñas de bajo grado|O|O||D||1|Pinza tipo alicata
42142005|Sujeta agujas de bajo grado|O|O||D||1|Porta agujas
42142006|Retractores de bajo grado|O|O||D||1
42142007|Tijeras de bajo grado|O|O||D||1
42142100|Productos de terapia de frío y de calor|O|O||D||1
42142101|Cubiertas para productos para terapia de calor o frío|O|O||D||1
42142102|Unidades o accesorios de enfriamiento para almacenamiento frío para uso médico|O|O||D||1|Unidades frigoríficas o accesorios de refrigeración médica
42142103|Lámparas de calor o sus accesorios para uso médico|O|O||D||1
42142104|Hidro coladores o sus accesorios para uso médico|O|O||D||1
42142105|Unidades o sistemas de calentamiento o enfriamiento terapéutico|O|O||D||1|Unidades o sistemas de calefacción o refrigeración terapéutica
42142106|Cobijas o cortinas de calentamiento o enfriamiento terapéutico|O|O||D||1|Mantas o cortinas para calefacción o refrigeración terapéutica
42142107|Sistema y accesorios de terapia de compresión crio terapéutica|O|O||D||1
42142108|Almohadillas o compresas o bolsas de calentamiento o enfriamiento terapéutico|O|O||D||1|Almohadillas o compresas o bolsas de calefacción o refrigeración terapéutica
42142109|Guantes de terapia para terapia de calor o frío|O|O||D||1|Guantes para tratamiento terapéutico con frío o calor
42142110|Botellas para terapia de calor o frío|O|O||D||1|Bolsa terapéuticas de agua caliente o fría
42142111|Bolsas o almohadas de hielo terapéuticas|O|O||D||1
42142112|Baños de parafina terapéuticos o sus accesorios|O|O||D||1
42142113|Máscaras para senos nasales terapéuticas|O|O||D||1|Antifaz terapéutico para senos nasales
42142114|Pantalones terapéuticos para terapia fría o caliente|O|O||D||1
42142119|Aparatos de hipotermia|O|O||D||1
42142120|Manga terapéutica para terapia de crio compresión|O|O||D||1
42142121|Gabinete de vapor húmedo|O|O||D||1
42142200|Productos de hidroterapia|O|O||D||1
42142201|Baños o tanques de hidroterapia para las extremidades|O|O||D||1
42142202|Baños o tanques de hidroterapia para inmersión total del cuerpo|O|O||D||1
42142203|Accesorios para baños o tanques de hidroterapia|O|O||D||1
42142204|Asientos para baños de hidroterapia|O|O||D||1
42142300|Productos de documentación médica|O|O||D||1
42142301|Etiquetas médicas para uso general|O|O||D||1|Etiquetas para uso médico
42142302|Componentes o accesorios para sistemas de planillas médicas|O|O||D||1
42142303|Productos de identificación de pacientes|O|O||D||1
42142400|Productos médicos de vacío o de succión|O|O||D||1
42142401|Solidificadores de fluidos para uso médico|O|O||D||1
42142402|Cánulas o tubos o accesorios de succión para uso médico|O|O||D||1
42142403|Contenedores de succión para uso médico|O|O||D||1
42142404|Aplicaciones al vacío o de succión para uso médico|O|O||D||1|Aparatos médicos de succión o de vacío
42142406|Sets o kits de succión para uso médico|O|O||D||1
42142407|Estuches para cánulas de succión para uso médico|O|O||D||1
42142500|Agujas de inyección y aspiración y accesorios|O|O||D||1
42142501|Agujas para amniocentesis|O|O||D||1
42142502|Agujas para anestesia|O|O||D||1
42142503|Agujas arteriales|O|O||D||1|Catéteres arteriales
42142504|Agujas para biopsia|O|O||D||1
42142505|Soportes para agujas de recolección de sangre|O|O||D||1|Porta aguja de extracción de sangre
42142506|Agujas romas|O|O||D||1|Agujas punta roma
42142507|Agujas mariposa|O|O||D||1
42142509|Bandejas o accesorios epidurales|O|O||D||1
42142510|Agujas de filtro|O|O||D||1
42142511|Tapas o dispositivos protectores o accesorios para agujas|O|O||D||1
42142512|Agujas de fístula|O|O||D||1|Agujas para fístula
42142513|Agujas para procedimientos de radiología|O|O||D||1
42142514|Bandejas o agujas espinales|O|O||D||1
42142515|Agujas de tubo al vacío|O|O||D||1|Agujas de tuvo de vacío
42142516|Agujas de transferencia|O|O||D||1
42142517|Tubos de extensión|O|O||D||1
42142518|Productos o accesorios aspiradores para biopsia|O|O||D||1
42142519|Guías para agujas|O|O||D||1
42142520|Alfileres dispensadores|O|O||D||1
42142521|Agujas para recolección de sangre|O|O||D||1
42142522|Agujas quirúrgicas para oídos o narices o gargantas|O|O||D||1
42142523|Agujas hipodérmicas|O|O||D||1
42142524|Agujas o sets para grabar|O|O||D||1
42142525|Agujas de irrigación|O|O||D||1
42142526|Protectores de agujas|O|O||D||1
42142527|Alambres para limpiar agujas|O|O||D||1
42142528|Agujas o sets para punción del esternón|O|O||D||1
42142529|Bandejas para agujas o porta agujas|O|O||D||1
42142530|Agujas para procedimientos diagnósticos|O|O||D||1
42142531|Contenedores o carritos o accesorios para desecho de agujas o cuchillas u otros objetos afilados|O|O||D||1
42142532|Agujas o kits o accesorios para pericardiocentesis|O|O||D||1
42142533|Agujas para administración de puertos intravenosos o arteriales|O|O||D||1
42142534|Aguja interósea|O|O||D||1
42142535|Aguja o bandeja para bloqueo nervioso anestésico|O|O||D||1
42142536|Aguja y catéter para toracentesis o paracentesis|O|O||D||1
42142537|Set o bandeja para toracentesis|O|O||D||1
42142538|Set o bandeja para paracentesis|O|O||D||1
42142600|Jeringas y accesorios|O|O||D||1
42142601|Jeringas para aspiración o irrigación médica|O|O||D||1
42142602|Peras de caucho para usos médicos|O|O||D||1
42142603|Jeringas de cartucho para uso médico|O|O||D||1
42142604|Jeringas de punta de catéter para uso médico|O|O||D||1
42142605|Jeringas para oídos para uso médico|O|O||D||1
42142606|Jeringas de entrega medida para uso médico|O|O||D||1
42142607|Micro jeringas para uso médico|O|O||D||1
42142608|Jeringas sin agujas para uso médico|O|O||D||1
42142609|Jeringas con agujas para uso médico|O|O||D||1
42142610|Jeringas de medicación líquida oral|O|O||D||1
42142611|Jeringas de tuberculina|O|O||D||1
42142612|Sets de jeringas de irrigación|O|O||D||1
42142613|Pistolas de inyección|O|O||D||1
42142614|Aparatos o accesorios para inyección hipodérmica|O|O||D||1
42142615|Accesorios para jeringas|O|O||D||1
42142616|Jeringas de recolección de sangre|O|O||D||1
42142617|Jeringas de fuente|O|O||D||1
42142618|Kits de jeringas de análisis de gas en la sangre|O|O||D||1
42142619|Jeringa de lavado pre llenada|O|O||D||1
42142620|Controlador o pistola de inyección de aguja interósea|O|O||D||1
42142700|Suministros urológicos|O|O||D||1
42142701|Catéteres urinarios supra púbicos|O|O||D||1
42142702|Catéteres urinarios uretrales|O|O||D||1
42142703|Tapones o pinzas para catéteres urinarios|O|O||D||1
42142704|Bolsas o medidores para drenaje urinario|O|O||D||1
42142705|Tiras o sujetadores para bolsas de drenaje urinario|O|O||D||1
42142706|Bandejas o paquetes o kits para procedimientos urológicos|O|O||D||1
42142707|Tubos de irrigación urinaria|O|O||D||1
42142708|Adaptadores para instrumentos de urología|O|O||D||1
42142709|Accesorios o sets para nefrostomía|O|O||D||1
42142710|Tubos o accesorios para drenaje urinario|O|O||D||1
42142711|Sets de auscultación uretral|O|O||D||1
42142712|Sets o accesorios de remoción de cálculos|O|O||D||1
42142713|Cubiertas o sets urológicos|O|O||D||1
42142714|Percoladores urológicos|O|O||D||1
42142715|Kits o accesorios de cateterización urológica|O|O||D||1
42142716|Dispositivo pesario|O|O||D||1
42142717|Catéter o drenaje para nefrostomía|O|O||D||1
42142718|Dispositivo de soporte y alargamiento del pene|O|O||D||1
42142719|Uretrotomo|O|O||D||1
42142720|Catéter urinario externo masculino|O|O||D||1
42142721|Alambre guía o alambre de deslizamiento urológico|O|O||D||1
42142800|Suministros y equipos para terapia vascular y de compresión|O|O||D||1
42142801|Dispositivos o tubos para compresión secuencial vascular|O|O||D||1
42142802|Prendas o soporte para compresión o vasculares|O|O||D||1
42142900|Corrección de la visión o gafas cosméticas y productos relacionados|O|O||D||1
42142901|Anteojos|O|O||D||1
42142902|Lentes para anteojos|O|O||D||1
42142903|Monturas para anteojos|O|O||D||1
42142904|Hardware para anteojos|O|O||D||1
42142905|Anteojos de sol|O|O||D||1
42142906|Estuches para anteojos|O|O||D||1
42142907|Pañitos para limpiar anteojos|O|O||D||1
42142908|Kits para limpiar anteojos|O|O||D||1
42142909|Retenedores de anteojos|O|O||D||1
42142910|Estuches para lentes de contacto|O|O||D||1
42142911|Insertores o removedores de lentes de contacto|O|O||D||1
42142912|Medidores de radio de lentes de contacto|O|O||D||1
42142913|Lentes de contacto|O|O||D||1
42142914|Solución limpiadora o humidificadora de lentes de contacto|O|O||D||1
42143100|Equipo y suministros de obstetricia y ginecología|O|O||D||1
42143101|Catéteres o kits de cateterización intrauterina|O|O||D||1
42143102|Dispositivos o accesorios uterinos|O|O||D||1
42143103|Dispositivos o accesorios contraceptivos intrauterinos|O|O||D||1
42143104|Kits o accesorios para amniocentesis|O|O||D||1
42143105|Unidades o accesorios de extracción obstétrica|O|O||D||1
42143106|Kits o accesorios de drenaje ginecológico|O|O||D||1
42143107|Perinómetro|O|O||D||1
42143108|Cámara de descompresión abdominal|O|O||D||1
42143200|Equipo y suministros de tratamiento de la fertilidad y la esterilidad|O|O||D||1
42143201|Kits o accesorios de preparación de semen|O|O||D||1
42143202|Productos o kits o accesorios para el tratamiento de la impotencia|O|O||D||1
42143203|Catéter de inseminación artificial|O|O||D||1
42143204|Catéter de transferencia de embriones|O|O||D||1
42143300|Equipo y suministros de quimioterapia|O|O||D||1
42143301|Sets o kits de administración de quimioterapia|O|O||D||1
42143302|Almohadilla de preparación para quimioterapia|O|O||D||1
42143303|Bolsa para transportar quimioterapia|O|O||D||1
42143400|Equipo y suministros de control de hiperhidrosis|O|O||D||1
42143401|Equipos o accesorios para el control del sudor|O|O||D||1
42143500|Productos y accesorios de otorrinolaringología|O|O||D||1
42143501|Ayudas para la limpieza de moldes auditivos|O|O||D||1
42143502|Dispositivos o accesorios para irrigación nasal|O|O||D||1
42143503|Dispositivos o bombas para el control de la hemorragia nasal|O|O||D||1
42143504|Moldes auditivos o sus accesorios|O|O||D||1
42143505|Kits de reparación de moldes auditivos|O|O||D||1
42143506|Sets filiformes para la trompa de eustaquio|O|O||D||1
42143507|Paquetes de medicación de oídos|O|O||D||1
42143508|Capuchas de viento para oídos|O|O||D||1
42143509|Pegantes o cementos para moldes auditivos|O|O||D||1
42143510|Pantallas protectoras de viento para oídos|O|O||D||1
42143511|Ganchos de cera de oídos|O|O||D||1
42143512|Mechas para oídos|O|O||D||1
42143513|Instrumentos o accesorios otológicos|O|O||D||1
42143514|Sistema para lavado de oídos|O|O||D||1
42143600|Sujeciones y accesorios|O|O||D||1
42143601|Chalecos y chaquetas de fuerza (de restricción)|O|O||D||1
42143602|Elementos de restricción de cintura y torso|O|O||D||1
42143603|Elementos de restricción de extremidades|O|O||D||1
42143604|Elementos de restricción de cabeza no para ems|O|O||D||1
42143605|Correas o hebillas o accesorios o suministros de restricción|O|O||D||1
42143606|Elementos de restricción para todo el cuerpo|O|O||D||1
42143607|Sensores o alarmas o accesorios de movimiento de pacientes|O|O||D||1
42143608|Dispositivos o accesorios para estabilización o prevención de caídas de pacientes|O|O||D||1
42143609|Tablas o accesorios para restricción de pacientes|O|O||D||1
42143700|Sistemas y accesorios de fototerapia|O|O||D||1
42143701|Circuladores de aire o accesorios para fototerapia|O|O||D||1
42143702|Cobijas para fototerapia|O|O||D||1
42143703|Bombillos para fototerapia|O|O||D||1
42143704|Esteras de luz para fototerapia|O|O||D||1
42143705|Dispositivos de protección de pacientes para fototerapia|O|O||D||1
42143706|Unidades eléctricas para fototerapia|O|O||D||1
42143707|Calentadores de camas o accesorios para fototerapia|O|O||D||1
42143708|Chaleco para fototerapia|O|O||D||1
42143709|Radiador de luz visible|O|O||D||1
42143800|Instrumentos y suministros y equipos para la medición de presión urológica|O|O||D||1
42143801|Sistemas o accesorios para cistometría|O|O||D||1
42143802|Transductores para cistometría|O|O||D||1
42143803|Catéteres uro dinámicos|O|O||D||1
42143900|Productos para la incontinencia fecal|O|O||D||1
42143901|Bolsa o accesorios de recolección de incontinencia fecal|O|O||D||1
42143902|Sistema o kit de manejo fecal|O|O||D||1
42143903|Catéter de colon o tubo rectal|O|O||D||1
42144000|Partes y accesorios para dispositivos auditivos externos|O|O||D||1
42144001|Procesador de sonido externo para dispositivos auditivos implantados|O|O||D||1
42144002|Cable externo para dispositivos auditivos implantados|O|O||D||1
42144003|Audífonos procesadores de sonido externos para dispositivos auditivos implantados|O|O||D||1
42144004|Magneto externo para dispositivos auditivos implantados|O|O||D||1
42144005|Micrófono externo para dispositivos auditivos implantados|O|O||D||1
42144100|Productos para drenaje de la cavidad pleural|O|O||D||1
42144101|Unidad o contenedor o accesorios para drenaje de la cavidad pléurica|O|O||D||1
42144102|Tubo de pecho|O|O||D||1
42144103|Kit de tubos de pecho|O|O||D||1
42144200|Equipo de acupuntura|O|O||D||1
42144201|Aguja de acupuntura|O|O||D||1
42144202|Bolita o semilla magnética para acupuntura|O|O||D||1
42144203|Brazalete para acu presión|O|O||D||1
42144300|Productos de contra pulsación externa|O|O||D||1
42144301|Sistema de contra pulsación externa ecp|O|O||D||1
42144302|Mangas o pantalones para contra pulsación externa ecp|O|O||D||1
42151500|Suministros y equipos de odontología cosmética|O|O||D||1
42151501|Luces de curación o accesorios para odontología estética|O|O||D||1
42151502|Pozos mezcladores para odontología estética|O|O||D||1
42151503|Coronas o formas de coronas|O|O||D||1
42151504|Laca dental|O|O||D||1
42151505|Suministros de grabado de dientes|O|O||D||1
42151506|Suministros blanqueadores o decolorantes de dientes|O|O||D||1
42151507|Sombras dentales|O|O||D||1
42151600|Instrumentos y dispositivos dentales y de subespecialidad|O|O||D||1
42151601|Accesorios o partes de repuesto para instrumentos dentales|O|O||D||1
42151602|Bandas para matriz dental|O|O||D||1
42151603|Herramientas de colocación de hidróxido de calcio|O|O||D||1
42151604|Herramientas de colocación de compuestos|O|O||D||1
42151605|Removedores de coronas o puentes|O|O||D||1
42151606|Talladores de amalgamas dentales|O|O||D||1
42151607|Casetes para instrumentos dentales|O|O||D||1
42151608|Bandejas o cubetas para instrumentos dentales|O|O||D||1
42151609|Esterillas para instrumentos dentales|O|O||D||1
42151610|Alicates dentales|O|O||D||1
42151611|Cepillos operativos dentales|O|O||D||1
42151612|Retractores dentales|O|O||D||1
42151613|Pulidores dentales|O|O||D||1
42151614|Fresas dentales|O|O||D||1
42151615|Unidades crio quirúrgicas dentales|O|O||D||1
42151616|Medidores de profundidad dentales|O|O||D||1
42151617|Taladros o brocas dentales|O|O||D||1
42151618|Elevadores dentales|O|O||D||1
42151619|Excavadoras dentales|O|O||D||1
42151620|Limas o curetas dentales|O|O||D||1
42151621|Instrumentos para contorno de calzas dentales|O|O||D||1
42151622|Protectores de dedos para uso odontológico|O|O||D||1
42151623|Fórceps dentales|O|O||D||1
42151624|Piezas manuales o accesorios para uso odontológico|O|O||D||1
42151625|Instrumentos de higiene dental|O|O||D||1
42151626|Accesorios para afilar instrumentos dentales|O|O||D||1
42151627|Espejos o mangos de espejo para uso odontológico|O|O||D||1
42151628|Lozas mezcladoras para uso odontológico|O|O||D||1
42151629|Organizadores dentales|O|O||D||1
42151630|Instrumentos de colocación para uso odontológico|O|O||D||1
42151631|Sondas dentales|O|O||D||1
42151632|Escariadores dentales|O|O||D||1
42151633|Instrumentos de empaque de cordones de retracción para uso odontológico|O|O||D||1
42151634|Picos de punta de raíz para uso dental|O|O||D||1
42151635|Eyectores de saliva o dispositivos de succión oral o suministros dentales|O|O||D||1
42151636|Raspadores dentales o accesorios|O|O||D||1
42151637|Escalas dentales|O|O||D||1
42151638|Tijeras dentales|O|O||D||1
42151639|Espátulas dentales|O|O||D||1
42151640|Pinzas dentales|O|O||D||1
42151641|Grabadores de cera para uso odontológico|O|O||D||1
42151642|Cuchillos de gingivectomía|O|O||D||1
42151643|Cortadoras de margen dental|O|O||D||1
42151644|Soportes para la boca para uso odontológico|O|O||D||1
42151645|Kits o bandejas operativas reusables pre ensambladas para uso odontológico|O|O||D||1
42151646|Dispositivos protectores para dientes|O|O||D||1
42151647|Sujetadores absorbentes para uso odontológico|O|O||D||1
42151648|Calibradores para uso odontológico|O|O||D||1
42151650|Herramientas de detección de fracturas para uso odontológico|O|O||D||1
42151651|Separadores de dientes para uso odontológico|O|O||D||1
42151652|Introductor de espigas para uso odontológico|O|O||D||1
42151653|Doblador de espigas para uso odontológico|O|O||D||1
42151654|Guías para uso odontológico|O|O||D||1
42151655|Probadores de nervio o de vitalidad para uso odontológico|O|O||D||1
42151656|Esparcidores para uso odontológico|O|O||D||1
42151657|Tubos o accesorios para uso odontológico|O|O||D||1
42151658|Enhebradores de seda dental|O|O||D||1
42151659|Kit de extracción de partes de dientes|O|O||D||1
42151660|Aplicadores o absorbentes para uso odontológico|O|O||D||1
42151661|Estuches o bolsas para instrumentos dentales|O|O||D||1
42151662|Electrodos de anestesia o repuestos para uso odontológico|O|O||D||1
42151663|Cuñas o sets para uso odontológico|O|O||D||1
42151664|Discos cortadores o separadores para uso odontológico|O|O||D||1
42151665|Calibradores o accesorios para uso odontológico|O|O||D||1
42151666|Sujetadores bucales para uso odontológico|O|O||D||1
42151667|Matrices o sets para uso odontológico|O|O||D||1
42151668|Enrolladores de instrumentos para instrumentos o accesorios dentales|O|O||D||1
42151669|Deshidratadores para uso odontológico|O|O||D||1
42151670|Portadores de calor para uso odontológico|O|O||D||1
42151671|Calzas o kits de calzas para sistemas post dentales|O|O||D||1
42151672|Expansores para uso odontológico|O|O||D||1
42151673|Martillos para uso odontológico|O|O||D||1
42151674|Sujetadores de fresas para uso odontológico|O|O||D||1
42151675|Kits de restauración para uso odontológico|O|O||D||1
42151676|Cuchillos para uso odontológico|O|O||D||1
42151677|Kits indicadores de presión para uso odontológico|O|O||D||1
42151678|Sujetadores para almohadillas o láminas mezcladoras|O|O||D||1
42151679|Bolsas mezcladoras para uso odontológico|O|O||D||1
42151680|Topes o accesorios endodónticos|O|O||D||1
42151681|Sets o accesorios de anestesia para uso odontológico|O|O||D||1
42151682|Broca endodóntica|O|O||D||1
42151683|Arco facial|O|O||D||1
42151700|Muebles para la clínica dental|O|O||D||1
42151701|Sillas para examen dental o partes relacionadas o accesorios|O|O||D||1
42151702|Taburetes para uso odontológico|O|O||D||1
42151703|Gabinetes para uso odontológico|O|O||D||1
42151704|Mesas o accesorios para uso odontológico|O|O||D||1
42151705|Sets de mobiliarios combinados para procedimientos dentales|O|O||D||1|Gabinetes combinados para consultorio dental
42151800|Rellenos y acabados dentales y suministros para pulir|O|O||D||1
42151801|Portadores de amalgamas|O|O||D||1
42151802|Obturadores o puntas o accesorios para uso odontológico|O|O||D||1
42151803|Cápsulas de amalgama para uso odontológico|O|O||D||1
42151804|Empaquetadores de cable para uso odontológico|O|O||D||1
42151805|Discos pulidores o de terminado para uso odontológico|O|O||D||1
42151806|Tiras pulidoras o de terminado para uso odontológico|O|O||D||1
42151807|Puntas pulidoras o de terminado para uso odontológico|O|O||D||1
42151808|Compuestos brilladores para uso odontológico|O|O||D||1
42151809|Paños comprimibles para uso odontológico|O|O||D||1|Paños comprimidos para uso odontológico
42151810|Kits pulidores o de terminado para uso odontológico|O|O||D||1
42151811|Copas o sets pulidores para uso odontológico|O|O||D||1
42151812|Resortes para abrasión o máquinas pulidoras para uso odontológico|O|O||D||1
42151813|Tubos de calzas para uso odontológico|O|O||D||1
42151814|Adaptadores de placas de sujeción para tallado o máquinas pulidoras para uso odontológico|O|O||D||1
42151815|Conos para tallado o máquinas pulidoras para uso odontológico|O|O||D||1
42151816|Portadores de lámina de oro|O|O||D||1
42151900|Equipo y suministros para higiene dental y cuidado preventivo|O|O||D||1
42151901|Cepillos para paladares o prótesis dentales|O|O||D||1
42151902|Kits de profilaxis para uso odontológico|O|O||D||1
42151903|Copas o contenedores para prótesis dentales|O|O||D||1
42151904|Soluciones o tabletas reveladoras|O|O||D||1
42151905|Geles o enjuagues de fluoruro|O|O||D||1|Fluoruro de sodio o enjuagues bucales
42151906|Tabletas o gotas de fluoruro|O|O||D||1
42151907|Tanques de profilaxis para uso odontológico|O|O||D||1
42151908|Frascos o sets para prótesis dentales|O|O||D||1
42151909|Pastas o kits de prevención dental|O|O||D||1
42151910|Dispositivos o accesorios para limpiar dientes|O|O||D||1
42151911|Sets acondicionadores de tejido dental|O|O||D||1
42151912|Aerosoles endodónticos|O|O||D||1|Aerosoles dentales
42152000|Equipo y suministros para hacer imágenes dentales|O|O||D||1
42152001|Sujetadores de aleta de mordida|O|O||D||1
42152002|Bloques o aletas o tabletas de mordida para uso odontológico|O|O||D||1
42152003|Procesadores de película para uso odontológico|O|O||D||1
42152004|Colgadores de película radiológica para uso odontológico|O|O||D||1|Colgadores para película de rayos x para uso odontológico
42152005|Sujetadores de película radiológica para uso odontológico|O|O||D||1|Soporte de película radiológica para uso odontológico
42152006|Monturas de película radiológica para uso odontológico|O|O||D||1
42152007|Duplicadores de rayos x para uso odontológico|O|O||D||1
42152008|Unidades de rayos x para uso odontológico|O|O||D||1
42152009|Visores o accesorios de rayos x para uso odontológico|O|O||D||1
42152010|Película radiológica para uso odontológico|O|O||D||1
42152011|Adaptadores de película de rayos x para uso odontológico|O|O||D||1
42152012|Partes o kits o accesorios para aparatos de rayos x para uso odontológico|O|O||D||1|Partes o accesorios para aparatos de rayos x para uso odontológico
42152013|Analizadores de película radiográfica para uso odontológico|O|O||D||1
42152014|Trazador radioactivo para uso odontológico|O|O||D||1
42152100|Equipo y suministros dentales para impresión y formar|O|O||D||1
42152101|Anillos de molde o suministros relacionados para uso odontológico|O|O||D||1
42152102|Formadores para uso odontológico|O|O||D||1
42152103|Adhesivos para bandejas de impresión para uso odontológico|O|O||D||1
42152104|Limpiadores de bandejas de impresión para uso odontológico|O|O||D||1
42152105|Bandejas de impresión para uso odontológico|O|O||D||1
42152106|Cuchillos para yeso para uso odontológico|O|O||D||1
42152107|Instrumentos de encerado para uso odontológico|O|O||D||1
42152108|Jeringas de material de impresión o accesorios para uso odontológico|O|O||D||1
42152109|Baños de agua para material de impresión o accesorios para uso odontológico|O|O||D||1
42152110|Dispositivos para marcar dientes|O|O||D||1
42152111|Endurecedores de material de impresión para uso odontológico|O|O||D||1
42152112|Instrumentos de secado o accesorios para uso odontológico|O|O||D||1
42152113|Kits de formación de base para prótesis dentales|O|O||D||1
42152114|Kits de entrega de materiales de impresión para uso odontológico|O|O||D||1
42152115|Canastas de impresión para uso odontológico|O|O||D||1
42152200|Equipo y suministros dentales de laboratorio y de esterilización|O|O||D||1
42152201|Láminas dentales|O|O||D||1
42152202|Unidades de abrasión por aire de laboratorio dental|O|O||D||1
42152203|Quemadores o antorchas de laboratorio dental|O|O||D||1
42152204|Máquinas para enyesar, sus partes o accesorios de laboratorio dental|O|O||D||1
42152205|Unidades de curado de laboratorio dental|O|O||D||1
42152206|Tintes de laboratorio dental|O|O||D||1
42152207|Recolectores de polvo de laboratorio dental|O|O||D||1
42152208|Máquinas o accesorios de laboratorio dental|O|O||D||1
42152209|Hornos de uso odontológico para laboratorios|O|O||D||1
42152210|Chapas de oro de laboratorio dental|O|O||D||1|Piezas o suministros de oro para laboratorio dental
42152211|Tornos o accesorios de laboratorio dental|O|O||D||1
42152212|Bordeadoras de modelos de laboratorio dental|O|O||D||1
42152213|Modelos de laboratorio dentales|O|O||D||1
42152214|Trampas de yeso de laboratorio dental|O|O||D||1
42152215|Lijadoras de chorro de arena o suministros de laboratorio dental|O|O||D||1|Arenadora dental o sus suministros para laboratorio
42152216|Máquinas soldadoras o suministros de laboratorio dental|O|O||D||1
42152217|Unidades de vacío o suministros de laboratorio dental|O|O||D||1
42152218|Vibradores de uso odontológico para laboratorios|O|O||D||1
42152219|Unidades de encerado de laboratorio dental|O|O||D||1
42152220|Piedras dentales para laboratorios|O|O||D||1
42152221|Protectores de moldes o estuches de laboratorio dental|O|O||D||1
42152222|Crisoles para máquinas de fundición de uso odontológico|O|O||D||1
42152223|Unidades o accesorios de procesamiento de resinas de laboratorio dental|O|O||D||1
42152224|Cantimploras de laboratorio dental|O|O||D||1
42152300|Láseres y equipo de iluminación y fibra óptica para odontología, y suministros|O|O||D||1
42152301|Láseres de uso odontológico|O|O||D||1|Láseres dentales
42152302|Dentoscopios|O|O||D||1
42152303|Luces para uso odontológico general o sus accesorios|O|O||D||1|Lámparas dentales generales o sus accesorios
42152304|Luces intraorales|O|O||D||1|Lámparas intraorales
42152305|Trípodes de luces de operación para uso odontológico|O|O||D||1|Tripié para lámparas de operación para uso odontológico
42152306|Luces o accesorios de fibra óptica para uso odontológico|O|O||D||1|Lámparas o accesorios de fibra óptica para uso odontológico
42152307|Sets de iluminación de operación para uso odontológico|O|O||D||1|Conjunto de iluminación de operación para uso odontológico
42152400|Materiales dentales|O|O||D||1
42152401|Aleaciones para amalgamas de uso odontológico|O|O||D||1
42152402|Materiales protectores de la boca para atletas|O|O||D||1
42152403|Aleaciones de molibdeno cromo cobalto fundido para implantes dentales|O|O||D||1
42152404|Materiales de impresión hidrocoloides irreversibles reversibles combinados|O|O||D||1
42152405|Plásticos para coronas o puentes|O|O||D||1
42152406|Pastas abrasivas de uso odontológico|O|O||D||1
42152407|Polvos abrasivos de uso odontológico|O|O||D||1
42152408|Puntos absorbentes de uso odontológico|O|O||D||1
42152409|Materiales de impresión agar de uso odontológico|O|O||D||1
42152410|Materiales de impresión alginadas de uso odontológico|O|O||D||1|Alginatos de uso odontológico
42152411|Aleaciones de fundición de metal de base de uso odontológico|O|O||D||1
42152412|Ceras de placa de base de uso odontológico|O|O||D||1
42152413|Aleaciones de soldadura fuerte de uso odontológico|O|O||D||1
42152414|Aleaciones de fundición de uso odontológico|O|O||D||1
42152415|Cerámicas de uso odontológico|O|O||D||1
42152416|Materiales de duplicación de uso odontológico|O|O||D||1
42152417|Inversiones de sílice etilo de uso odontológico|O|O||D||1
42152418|Productos de yeso de uso odontológico|O|O||D||1
42152419|Materiales de impresión de pasta de óxido de zinc eugenol de uso odontológico|O|O||D||1
42152420|Ceras de fundición para incrustaciones de uso odontológico|O|O||D||1
42152421|Mercurio de uso odontológico|O|O||D||1
42152422|Puntos obturadores de uso odontológico|O|O||D||1
42152423|Sellantes de huecos o fisuras de uso odontológico|O|O||D||1|Selladores de huecos o fisuras de uso odontológico
42152424|Cementos de base de agua de uso odontológico|O|O||D||1|Cementos dentales a base de agua
42152425|Resinas de base para prótesis dentales|O|O||D||1
42152426|Resinas de forrado temporales de base para prótesis dentales|O|O||D||1
42152427|Resinas de reparación de cura fría para prótesis dentales|O|O||D||1
42152428|Resinas de relleno directo|O|O||D||1
42152429|Materiales elastoméricos para impresiones dentales|O|O||D||1
42152430|Materiales de relleno endodóntico|O|O||D||1
42152431|Elastómeros de prótesis maxilofacial extra oral|O|O||D||1
42152432|Inversiones de fundición de yeso unido para aleaciones de oro|O|O||D||1
42152433|Película radiográfica dental intraoral|O|O||D||1
42152434|Amalgamantes para uso odontológico|O|O||D||1
42152435|Materiales elastómeros para ortodoncia|O|O||D||1
42152436|Inversiones unidas de fosfato|O|O||D||1
42152437|Dientes de porcelana|O|O||D||1
42152438|Materiales refractarios de tinte|O|O||D||1
42152439|Materiales resistentes de recubrimiento para prótesis dentales removibles|O|O||D||1
42152440|Inversiones de soldadura|O|O||D||1
42152441|Dientes de polímeros sintéticos|O|O||D||1
42152442|Titanio sin aleación para implantes dentales|O|O||D||1
42152443|Cementos de óxido de zinc eugenol y de no eugenol|O|O||D||1
42152444|Líquido de retracción gingival|O|O||D||1
42152445|Sets de partes anteriores o posteriores de dientes|O|O||D||1|Juego de carillas dentales
42152446|Recubrimientos o materiales adelgazantes o sets para caries dentales|O|O||D||1|Revestimientos para cavidad dental y diluyentes
42152447|Tintes o suministros de uso odontológico|O|O||D||1
42152449|Catalizadores de material de impresión de uso odontológico|O|O||D||1
42152450|Compuestos limpiadores de instrumentos de uso odontológico|O|O||D||1
42152451|Compuestos indicadores de presión de uso odontológico|O|O||D||1
42152452|Kits o accesorios de aislamiento de pastas de uso odontológico|O|O||D||1
42152453|Compuestos restauradores de uso odontológico|O|O||D||1
42152454|Protectores de nervios dentales|O|O||D||1
42152455|Estantes o soportes para productos abrasivos de uso odontológico|O|O||D||1
42152456|Agentes enmascaradores de uso odontológico|O|O||D||1
42152457|Kits de cementación de uso odontológico|O|O||D||1
42152458|Espaciadores de tintes de uso odontológico|O|O||D||1
42152459|Kits post endodoncia|O|O||D||1
42152460|Compuestos de recubrimiento para prótesis dentales|O|O||D||1
42152461|Compuestos de recubrimiento para modelos dentales|O|O||D||1
42152462|Kits de revestimiento de prótesis dentales|O|O||D||1
42152463|Solventes de cera de uso odontológico|O|O||D||1
42152464|Kits para implantes dentales|O|O||D||1
42152465|Lubricantes dentales|O|O||D||1
42152466|Probador de ajuste de material|O|O||D||1
42152468|Mezclador de material de impresión dental de alginato operado eléctricamente|O|O||D||1
42152469|Mezclador de material de impresión dental basado en caucho operado eléctricamente|O|O||D||1
42152470|Resina para aplicación de ortodoncia|O|O||D||1
42152500|Suministros dentales generales|O|O||D||1
42152501|Kits o bandejas desechables pre ensambladas de uso odontológico|O|O||D||1
42152502|Baberos de uso odontológico|O|O||D||1
42152503|Suministros hembra de uso odontológico|O|O||D||1|Presas de goma de uso odontológico
42152504|Recubrimientos de uso odontológico|O|O||D||1
42152505|Forros para el apoyacabezas de la silla de examen de uso odontológico|O|O||D||1
42152506|Bolitas absorbentes de uso odontológico|O|O||D||1
42152507|Rollos de uso odontológico|O|O||D||1
42152508|Jeringas o agujas o jeringas con agujas de uso odontológico|O|O||D||1
42152509|Cubiertas desechables para bandejas de uso odontológico|O|O||D||1
42152510|Estuches o cubiertas para instrumentos o sets de uso odontológico|O|O||D||1
42152511|Platos de uso odontológico|O|O||D||1
42152512|Pinzas de uso odontológico|O|O||D||1
42152513|Tazas medidoras de uso odontológico|O|O||D||1
42152514|Contenedores o accesorios de materiales de desecho de uso odontológico|O|O||D||1
42152516|Tazones mezcladores de uso odontológico|O|O||D||1
42152517|Sujetadores o dispensadores de servilletas de uso odontológico|O|O||D||1
42152518|Dispensadores de materiales de uso odontológico|O|O||D||1
42152519|Kits de accesorios para jeringas de uso odontológico|O|O||D||1
42152520|Escupideras de uso odontológico|O|O||D||1
42152521|Pantógrafo|O|O||D||1
42152600|Suministros específicos a la operación dental|O|O||D||1
42152601|Papeles articulados para operación o productos relacionados de uso odontológico|O|O||D||1
42152602|Barreras de control de infección para operaciones de uso odontológico|O|O||D||1
42152603|Tornillos de retención o productos relacionados para operaciones de uso odontológico|O|O||D||1
42152604|Cordones de retracción para operaciones de uso odontológico|O|O||D||1
42152605|Sets de sialografía de uso odontológico|O|O||D||1
42152606|Tablillas o sets de uso odontológico|O|O||D||1
42152607|Anillos para instrumentos de uso odontológico|O|O||D||1
42152608|Cartuchos de ligadura para ortodoncia|O|O||D||1
42152700|Equipo y suministros ortodoncia y prostodónticos|O|O||D||1
42152701|Articuladores o accesorios de uso odontológico|O|O||D||1
42152702|Soluciones hemostáticas de uso odontológico|O|O||D||1
42152703|Tornillos o fijadores o suministros relacionados de uso odontológico|O|O||D||1
42152704|Retenedores de uso odontológico|O|O||D||1
42152705|Pinzas de aplicación para ortodoncia|O|O||D||1
42152706|Frenillos "brackets" para ortodoncia|O|O||D||1
42152707|Tubos bucales para ortodoncia|O|O||D||1
42152708|Bobinas de resorte para ortodoncia|O|O||D||1
42152709|Elásticos para ortodoncia|O|O||D||1
42152710|Elastómeros para ortodoncia|O|O||D||1
42152711|Tornillos de expansión para ortodoncia|O|O||D||1
42152712|Bandas molares para ortodoncia|O|O||D||1
42152713|Alicates para ortodoncia|O|O||D||1
42152714|Estuches retenedores para ortodoncia|O|O||D||1
42152715|Bandas de colocación para ortodoncia|O|O||D||1
42152716|Topes o bloqueos para ortodoncia|O|O||D||1
42152717|Alambre para ortodoncia|O|O||D||1
42152718|Arco de alambre para ortodoncia|O|O||D||1
42152800|Equipo y suministro periodontal|O|O||D||1
42152801|Cinceles para periodoncia|O|O||D||1
42152802|Limas para periodoncia|O|O||D||1
42152803|Separadores para periodoncia|O|O||D||1
42152804|Instrumentos de prueba de implante periodontal a interface de hueso|O|O||D||1
42152805|Instrumentos de control para periodoncia|O|O||D||1
42152806|Disectores de tejido para periodoncia|O|O||D||1
42152807|Pastas protectoras para periodoncia|O|O||D||1
42152808|Curetas para periodoncia|O|O||D||1
42152809|Cuchillos para periodoncia|O|O||D||1
42152810|Membranas para periodoncia|O|O||D||1
42161500|Equipo de diálisis peritoneal y de equilibrio y suministros|O|O||D||1
42161501|Sets de transferencia de diálisis peritoneal ambulatoria continua capd|O|O||D||1
42161502|Calentadores de dialisato peritoneal|O|O||D||1
42161503|Sets de administración o cateterización de diálisis peritoneal|O|O||D||1
42161504|Adaptadores o pinzas o conectores de catéter para diálisis peritoneal|O|O||D||1
42161505|Bolsas o contenedores de drenaje de diálisis peritoneal|O|O||D||1
42161506|Derivaciones o catéteres o dispositivos de acceso permanente para diálisis peritoneal|O|O||D||1
42161507|Soluciones para diálisis peritoneal|O|O||D||1
42161508|Correas o arneses para unidades de diálisis peritoneal|O|O||D||1
42161509|Unidades de diálisis peritoneal|O|O||D||1
42161510|Kits de lavado para diálisis peritoneal|O|O||D||1
42161600|Equipo de hemodiálisis extracorpórea y suministros|O|O||D||1
42161601|Kits o sets o accesorios de administración de hemodiálisis|O|O||D||1
42161602|Muestreadores de bolsas de sangre para hemodiálisis|O|O||D||1
42161603|Aparato de demanda de oxígeno en la sangre para hemodiálisis|O|O||D||1
42161604|Sillas para hemodiálisis|O|O||D||1
42161605|Medidores de conductividad de dialisato para hemodiálisis|O|O||D||1
42161606|Detectores de nivel de dialisato para hemodiálisis|O|O||D||1
42161607|Bombas de presión de dialisato para hemodiálisis|O|O||D||1
42161608|Soluciones de dialisato para hemodiálisis|O|O||D||1
42161609|Tanques de dialisato para hemodiálisis|O|O||D||1
42161610|Tubos de dialisato para hemodiálisis|O|O||D||1
42161611|Baños calentadores de dialisato para hemodiálisis|O|O||D||1
42161612|Filtros de celuloide de dializador para hemodiálisis|O|O||D||1
42161613|Filtros de colodión de dializador para hemodiálisis|O|O||D||1
42161614|Filtros de filamento hueco de dializador para hemodiálisis|O|O||D||1
42161615|Sistemas de reprocesamiento de dializador para hemodiálisis|O|O||D||1
42161616|Detectores de burbujas de aire o espuma o coágulos, o trampas o alarmas para unidades de hemodiálisis|O|O||D||1
42161617|Monitores de presión arterial para unidades de hemodiálisis|O|O||D||1
42161618|Pinzas de línea de sangre para unidades de hemodiálisis|O|O||D||1
42161619|Tapas para válvulas de sangre para unidades de hemodiálisis|O|O||D||1
42161620|Bombas de sangre para unidades de hemodiálisis|O|O||D||1
42161621|Tapas para válvulas de dialisato unidades de hemodiálisis|O|O||D||1
42161622|Desinfectantes o limpiadores para unidades de hemodiálisis|O|O||D||1
42161623|Bombas de infusión de heparina unidades de hemodiálisis|O|O||D||1
42161624|Controladores de agujas únicas para unidades de hemodiálisis|O|O||D||1
42161625|Convertidores de un solo paso para unidades de hemodiálisis|O|O||D||1
42161626|Estantes o soportes o carritos para unidades de hemodiálisis|O|O||D||1
42161627|Monitores de temperatura para unidades de hemodiálisis|O|O||D||1
42161628|Equipos de prueba para unidades de hemodiálisis|O|O||D||1
42161629|Filtros transductores para unidades de hemodiálisis|O|O||D||1
42161630|Protectores transductores para unidades de hemodiálisis|O|O||D||1
42161631|Sistemas de purificación del agua para unidades de hemodiálisis|O|O||D||1
42161632|Unidades de hemodiálisis|O|O||D||1
42161633|Membranas dializadoras para aparatos de hemodiálisis|O|O||D||1
42161634|Bandejas de procedimiento o accesorios para hemodiálisis|O|O||D||1
42161635|Cartuchos para aparatos de hemodiálisis|O|O||D||1
42161700|Equipo de hemofiltración y suministros|O|O||D||1
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
