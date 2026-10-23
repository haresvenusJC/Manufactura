-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 7 de 10 (5113 claves; total 52513)
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
50351611|Albaricoque derby royal congelada orgánica|O|O||D||1|Chabacano derby royal congelado orgánico
50351612|Albaricoque dina congelada orgánica|O|O||D||1|Chabacano dina congelado orgánico
50351613|Albaricoque earlicot congelada orgánica|O|O||D||1|Chabacano earlicot congelado orgánico
50351614|Albaricoque earliman congelada orgánica|O|O||D||1|Chabacano earliman congelado orgánico
50351615|Albaricoque early bright congelada orgánica|O|O||D||1|Chabacano early bright congelado orgánico
50351616|Albaricoque  dorado en llamas congelada orgánica|O|O||D||1|Chabacano dorado en llamas congelado orgánico
50351617|Albaricoque frenso congelada orgánica|O|O||D||1|Chabacano frenso congelado orgánico
50351618|Albaricoque dorado claro congelada orgánica|O|O||D||1|Chabacano dorado claro congelado orgánico
50351619|Albaricoque barra dorado congelada orgánica|O|O||D||1|Chabacano barra dorado congelado orgánico
50351620|Albaricoque dorado dulce congelada orgánica|O|O||D||1|Chabacano dorado dulce congelado orgánico
50351621|Albaricoque dorado rico congelada orgánica|O|O||D||1|Chabacano dorado rico congelado orgánico
50351622|Albaricoque helena congelada orgánica|O|O||D||1|Chabacano helena congelado orgánico
50351623|Albaricoque honeycot congelada orgánica|O|O||D||1|Chabacano  congelado orgánico
50351624|Albaricoque imperial congelada orgánica|O|O||D||1|Chabacano imperial congelado orgánico
50351625|Albaricoque jordanne congelada orgánica|O|O||D||1|Chabacano jordanne congelado orgánico
50351626|Albaricoque jumbo cot congelada orgánica|O|O||D||1|Chabacano jumbo cot congelado orgánico
50351627|Albaricoque kandy kot congelada orgánica|O|O||D||1|Chabacano kandy kot congelado orgánico
50351628|Albaricoque katy congelada orgánica|O|O||D||1|Chabacano katy congelado orgánico
50351629|Albaricoque rey congelada orgánica|O|O||D||1|Chabacano rey congelado orgánico
50351630|Albaricoque lambertin congelada orgánica|O|O||D||1|Chabacano lambertin congelado orgánico
50351631|Albaricoque loma congelada orgánica|O|O||D||1|Chabacano loma congelado orgánico
50351632|Albaricoque lulu belle congelada orgánica|O|O||D||1|Chabacano lulu belle congelado orgánico
50351633|Albaricoque modesto congelada orgánica|O|O||D||1|Chabacano modesto congelado orgánico
50351634|Albaricoque moorpark congelada orgánica|O|O||D||1|Chabacano moorpark congelado orgánico
50351635|Albaricoque orangered congelada orgánica|O|O||D||1|Chabacano orange red congelado orgánico
50351636|Albaricoque palstein congelada orgánica|O|O||D||1|Chabacano palstein congelado orgánico
50351637|Albaricoque perfeccion congelada orgánica|O|O||D||1|Chabacano perfección congelado orgánico
50351638|Albaricoque perfection congelada orgánica|O|O||D||1|Chabacano perfection congelado orgánico
50351639|Albaricoque poppy congelada orgánica|O|O||D||1|Chabacano poppy congelado orgánico
50351640|Albaricoque poppycot congelada orgánica|O|O||D||1|Chabacano poppy cot congelado orgánico
50351641|Albaricoque reina congelada orgánica|O|O||D||1|Chabacano reina congelado orgánico
50351642|Albaricoque riland congelada orgánica|O|O||D||1|Chabacano riland congelado orgánico
50351643|Albaricoque rival congelada orgánica|O|O||D||1|Chabacano rival congelado orgánico
50351644|Albaricoque robada congelada orgánica|O|O||D||1|Chabacano robada congelado orgánico
50351645|Albaricoque royal congelada orgánica|O|O||D||1|Chabacano royal congelado orgánico
50351646|Albaricoque  royal blenheim congelada orgánica|O|O||D||1|Chabacano royal blenheim congelado orgánico
50351647|Albaricoque  royal orange congelada orgánica|O|O||D||1|Chabacano royal orange congelado orgánico
50351648|Albaricoque gota de sol congelada orgánica|O|O||D||1|Chabacano gota de sol congelado orgánico
50351649|Albaricoque tilton congelada orgánica|O|O||D||1|Chabacano tilton congelado orgánico
50351650|Albaricoque tomcot congelada orgánica|O|O||D||1|Chabacano tomcot congelado orgánico
50351651|Albaricoque tracy congelada orgánica|O|O||D||1|Chabacano tracy congelado orgánico
50351652|Albaricoque tri gem congelada orgánica|O|O||D||1|Chabacano tri gem congelado orgánico
50351653|Albaricoque valle dorado congelada orgánica|O|O||D||1|Chabacano valle dorado congelado orgánico
50351654|Albaricoque westley congelada orgánica|O|O||D||1|Chabacano westley congelado orgánico
50351655|Albaricoque  york congelada orgánica|O|O||D||1|Chabacano york congelado orgánico
50351700|Bananos orgánicos congelados|O|O||D||1|Plátanos orgánicos congelados
50351701|Bananas manzana congelada orgánica|O|O||D||1|Plátano apple congelado orgánico
50351702|Bananas bebe congelada orgánica|O|O||D||1|Plátano bebe congelado orgánico
50351703|Bananas burro congelada orgánica|O|O||D||1|Plátano burro congelado orgánico
50351704|Bananas cavendish congelada orgánica|O|O||D||1|Plátano cavendish congelado orgánico
50351705|Bananas dominico congelada orgánica|O|O||D||1|Plátano dominico congelado orgánico
50351706|Bananas verde congelada orgánica|O|O||D||1|Plátano verde congelado orgánico
50351707|Bananas gros michel congelada orgánica|O|O||D||1|Plátano gros michel congelado orgánico
50351708|Bananas lacatan congelada orgánica|O|O||D||1|Plátano lacatan congelado orgánico
50351709|Bananas dedo de dama congelada orgánica|O|O||D||1|Plátano dedo de dama congelado orgánico
50351710|Bananas manzano congelada orgánica|O|O||D||1|Plátano manzano congelado orgánico
50351711|Bananas mysore congelada orgánica|O|O||D||1|Plátano mysore congelado orgánico
50351712|Bananas pisang mas congelada orgánica|O|O||D||1|Plátano pisang mas congelado orgánico
50351713|Bananas roja congelada orgánica|O|O||D||1|Plátano roja congelado orgánico
50351714|Bananas saba congelada orgánica|O|O||D||1|Plátano saba congelado orgánico
50351715|Bananas sucrier congelada orgánica|O|O||D||1|Plátano sucrier congelado orgánico
50351800|Barberries orgánicos congelados|O|O||D||1|Berberís orgánicos congelados
50351801|Berberís paleleaf congelada orgánica|O|O||D||1|Berberí paleleaf congelado orgánico
50351802|Barberís chenault congelada orgánica|O|O||D||1|Berberí chenault congelado orgánico
50351803|Barberís roja congelada orgánica|O|O||D||1|Berberí roja congelado orgánico
50351804|Barberís invierno verde congelada orgánica|O|O||D||1|Berberí invierno verde congelado orgánico
50351805|Barberís korean congelada orgánica|O|O||D||1|Berberí korean congelado orgánico
50351806|Barberís mentor congelada orgánica|O|O||D||1|Berberí mentor congelado orgánico
50351807|Barberís japones congelada orgánica|O|O||D||1|Berberí japonés congelado orgánico
50351808|Barberís atropurpurea congelada orgánica|O|O||D||1|Berberí atropurpurea congelado orgánico
50351809|Barberís aurea congelada orgánica|O|O||D||1|Berberí aurea congelado orgánico
50351810|Barberís bagatelle congelada orgánica|O|O||D||1|Berberí bagatelle congelado orgánico
50351811|Barberís crimsom pygmy congelada orgánica|O|O||D||1|Berberí crimsom pygmy congelado orgánico
50351812|Barberís kobold congelada orgánica|O|O||D||1|Berberí kobold congelado orgánico
50351813|Barberís warty congelada orgánica|O|O||D||1|Berberí warty congelado orgánico
50351814|Barberís europea congelada orgánica|O|O||D||1|Berberí europea congelado orgánico
50351900|Gayubas orgánicas congeladas|O|O||D||1|Rastreras orgánicas congeladas
50351901|Gayuba alpine congelada orgánica|O|O||D||1|Rastrera alpine congelada orgánica
50351902|Gayuba roja congelada orgánica|O|O||D||1|Rastrera roja congelada orgánica
50351903|Gayuba común congelada orgánica|O|O||D||1|Rastrera común congelada orgánica
50352000|Moras orgánicas congeladas|O|O||D||1|Zarzamoras orgánicas congeladas
50352001|Mora apache congelada orgánica|O|O||D||1|Zarzamora apache congelada orgánica
50352002|Mora satin negro congelada orgánica|O|O||D||1|Zarzamora satín negro congelada orgánica
50352003|Mora congelada orgánica|O|O||D||1|Zarzamora congelada orgánica
50352004|Mora cherokee congelada orgánica|O|O||D||1|Zarzamora cherokee congelada orgánica
50352005|Mora chester congelada orgánica|O|O||D||1|Zarzamora chéster congelada orgánica
50352006|Mora dirksen congelada orgánica|O|O||D||1|Zarzamora dirksen congelada orgánica
50352007|Bayasjosta congelada orgánica|O|O||D||1|Zarzamora josta congelada orgánica
50352008|Bayaslogan congelada orgánica|O|O||D||1|Zarzamora logan congelada orgánica
50352009|Bayasmarion congelada orgánica|O|O||D||1|Zarzamora marion congelada orgánica
50352010|Mora navaho congelada orgánica|O|O||D||1|Zarzamora navaho congelada orgánica
50352011|Bayanectar congelada orgánica|O|O||D||1|Zarzamora néctar congelada orgánica
50352012|Mora olallie congelada orgánica|O|O||D||1|Zarzamora olallie congelada orgánica
50352013|Bayatay congelada orgánica|O|O||D||1|Zarzamora tay congelada orgánica
50352014|Mora thomless hull congelada orgánica|O|O||D||1|Zarzamora thomless hull congelada orgánica
50352015|Bayayoung congelada orgánica|O|O||D||1|Zarzamora young congelada orgánica
50352100|Arándanos de mirto orgánicos congelados|O|O||D||1|Mirtillos orgánicos congelados
50352101|Arandanos bog congelada orgánica|O|O||D||1|Mirtillo bog congelado orgánico
50352102|Arandanos enano congelada orgánica|O|O||D||1|Mirtillo enano congelado orgánico
50352103|Arandanos montaña congelada orgánica|O|O||D||1|Mirtillo de montaña congelado orgánico
50352104|Arandanos oval-leaved congelada orgánica|O|O||D||1|Mirtillo oval-leaved congelado orgánico
50352200|Agrás orgánicas congeladas|O|O||D||1|Frutos azules del bosque orgánicos congelados
50352201|Agras bluecrop congelada orgánica|O|O||D||1|Fruto azul del bosque bluecrop congelado orgánico
50352202|Agras bluetta congelada orgánica|O|O||D||1|Fruto azul del bosque bluetta congelado orgánico
50352203|Agras brigitta congelada orgánica|O|O||D||1|Fruto azul del bosque brigitta congelado orgánico
50352204|Agras chandler congelada orgánica|O|O||D||1|Fruto azul del bosque chandler congelado orgánico
50352205|Agras duque congelada orgánica|O|O||D||1|Fruto azul del bosque duque congelado orgánico
50352206|Agras hrdyblue congelada orgánica|O|O||D||1|Fruto azul del bosque hrdyblue congelado orgánico
50352207|Agras legacy congelada orgánica|O|O||D||1|Fruto azul del bosque legacy congelado orgánico
50352208|Agras misty congelada orgánica|O|O||D||1|Fruto azul del bosque misty congelado orgánico
50352209|Agras nelson congelada orgánica|O|O||D||1|Fruto azul del bosque nelson congelado orgánico
50352210|Agras northblue congelada orgánica|O|O||D||1|Fruto azul del bosque northblue congelado orgánico
50352211|Agras northcountry congelada orgánica|O|O||D||1|Fruto azul del bosque northcountry congelado orgánico
50352212|Agras northsky congelada orgánica|O|O||D||1|Fruto azul del bosque northsky congelado orgánico
50352213|Agras patriota congelada orgánica|O|O||D||1|Fruto azul del bosque patriota congelado orgánico
50352214|Agras spartan congelada orgánica|O|O||D||1|Fruto azul del bosque spartan congelado orgánico
50352215|Agras toro congelada orgánica|O|O||D||1|Fruto azul del bosque toro congelado orgánico
50352300|Frutas del pan orgánicas congeladas|O|O||D||1
50352301|Fruta de pan chataigne congelada orgánica|O|O||D||1|Fruta del pan chataigne congelada orgánica
50352302|Fruta de pan sin pepa congelada orgánica|O|O||D||1|Fruta del pan sin semilla congelada orgánica
50352303|Fruta de pan corazón blanco congelada orgánica|O|O||D||1|Fruta del pan corazón blanco congelada orgánica
50352304|Fruta de pan corazón amarillo congelada orgánica|O|O||D||1|Fruta del pan corazón amarillo congelada orgánica
50352400|Chirimoyas orgánicas congeladas|O|O||D||1|Annonas orgánicas congeladas
50352401|Chirimoya chays congelada orgánica|O|O||D||1|Annona chays congelada orgánica
50352402|Chirimoya bronceada congelada orgánica|O|O||D||1|Annona bronceada congelada orgánica
50352403|Chirimoya burtons congelada orgánica|O|O||D||1|Annona burtons congelada orgánica
50352404|Chirimoya burton favorite congelada orgánica|O|O||D||1|Annona burton favorite congelada orgánica
50352405|Chirimoya jete congelada orgánica|O|O||D||1|Annona jete congelada orgánica
50352406|Chirimoya reretai congelada orgánica|O|O||D||1|Annona reretai congelada orgánica
50352407|Chirimoya smoothey congelada orgánica|O|O||D||1|Annona smoothey congelada orgánica
50352408|Chirimoya española congelada orgánica|O|O||D||1|Annona española congelada orgánica
50352409|Chirimoya blanca congelada orgánica|O|O||D||1|Annona blanca congelada orgánica
50352500|Cerezas orgánicas congeladas|O|O||D||1
50352501|Cereza amarelle  congelada orgánica|O|O||D||1
50352502|Cereza brooks congelada orgánica|O|O||D||1
50352503|Cereza bigarreu congelada orgánica|O|O||D||1
50352504|Cereza bing congelada orgánica|O|O||D||1
50352505|Cereza negra republic congelada orgánica|O|O||D||1
50352506|Cereza negra schmidt congelada orgánica|O|O||D||1
50352507|Cereza negra tartarian congelada orgánica|O|O||D||1
50352508|Cereza fiesta bing congelada orgánica|O|O||D||1
50352509|Cereza garnet congelada orgánica|O|O||D||1
50352510|Cereza rey congelada orgánica|O|O||D||1
50352511|Cereza champan congelada orgánica|O|O||D||1
50352512|Cereza lapin congelada orgánica|O|O||D||1
50352513|Cereza larian congelada orgánica|O|O||D||1
50352514|Cereza dark guines congelada orgánica|O|O||D||1
50352515|Cereza montmorency congelada orgánica|O|O||D||1
50352516|Cereza duque congelada orgánica|O|O||D||1
50352517|Cereza early rivers congelada orgánica|O|O||D||1
50352518|Cereza ruby bing congelada orgánica|O|O||D||1
50352519|Cereza santine congelada orgánica|O|O||D||1
50352520|Cereza geans/guines congelada orgánica|O|O||D||1
50352521|Cereza sonata congelada orgánica|O|O||D||1
50352522|Cereza lambert congelada orgánica|O|O||D||1
50352523|Cereza stella congelada orgánica|O|O||D||1
50352524|Cereza sweethart congelada orgánica|O|O||D||1
50352525|Cereza tartarian congelada orgánica|O|O||D||1
50352527|Cereza maraschino congelada orgánica|O|O||D||1
50352528|Cereza van congelada orgánica|O|O||D||1
50352529|Cereza morello congelada orgánica|O|O||D||1
50352530|Cereza royal ann congelada orgánica|O|O||D||1
50352531|Cereza ranier congelada orgánica|O|O||D||1
50352532|Cereza royal congelada orgánica|O|O||D||1
50352600|Citrones orgánicos congelados|O|O||D||1|Cidras orgánicas congeladas
50352601|Citrones buddha´s hand congelada orgánica|O|O||D||1|Cidra mano de Buda congelada orgánica
50352602|Citrones fingered congelada orgánica|O|O||D||1|Cidra finger red congelada orgánica
50352603|Citrones fo shoukan congelada orgánica|O|O||D||1|Cidra fo shoukan congelada orgánica
50352604|Cotrones bushakan congelada orgánica|O|O||D||1|Cidra bushakan congelada orgánica
50352605|Citones diamante congelada orgánica|O|O||D||1|Cidra diamante congelada orgánica
50352606|Citrones etrog congelada orgánica|O|O||D||1|Cidra etrog congelada orgánica
50352607|Citrones ponderosa congelada orgánica|O|O||D||1|Cidra ponderosa congelada orgánica
50352700|Arándanos orgánicos congelados|O|O||D||1|Arándanos rojos orgánicos congelados
50352701|Arandano ben lear congelada orgánica|O|O||D||1|Arándano rojo ben lear congelado orgánico
50352702|Arandano temprana negra congelada orgánica|O|O||D||1|Arándano rojo temprana negra congelado orgánico
50352703|Arandano gryclesik congelada orgánica|O|O||D||1|Arándano rojo gryclesik congelado orgánico
50352704|Arandano  howe congelada orgánica|O|O||D||1|Arándano rojo howe congelado orgánico
50352705|Bayas lingon congelada orgánica|O|O||D||1|Arándano rojo lingon congelado orgánico
50352706|Arandano mcfarling congelada orgánica|O|O||D||1|Arándano rojo mcfarling congelado orgánico
50352707|Arandano mauntain congelada orgánica|O|O||D||1|Arándano rojo mauntain congelado orgánico
50352708|Arandano pilgrim congelada orgánica|O|O||D||1|Arándano rojo pilgrim congelado orgánico
50352709|Arandano searless congelada orgánica|O|O||D||1|Arándano rojo searless congelado orgánico
50352710|Arandano stevens congelada orgánica|O|O||D||1|Arándano rojo stevens congelado orgánico
50352800|pasas de Corinto orgánicas congeladas|O|O||D||1
50352801|Pasa hudson bay congelada orgánica|O|O||D||1|Pasa de Corinto hudson bay congelada orgánica
50352802|Pasa waxy congelada orgánica|O|O||D||1|Pasa de Corinto waxy congelada orgánica
50352803|Pasa desierto congelada orgánica|O|O||D||1|Pasa de Corinto desierto congelada orgánica
50352804|Pasa negra congelada orgánica|O|O||D||1|Pasa de Corinto negra congelada orgánica
50352805|Pasa roja congelada orgánica|O|O||D||1|Pasa de Corinto roja congelada orgánica
50352806|Pasa blanca congelada orgánica|O|O||D||1|Pasa de Corinto blanca congelada orgánica
50352900|Dátiles orgánicos congelados|O|O||D||1
50352901|Dátiles asharasi  congelada orgánica|O|O||D||1
50352902|Dátiles barhi o barhee congelada orgánica|O|O||D||1
50352903|Dátiles deglet noor congelada orgánica|O|O||D||1
50352904|Dátiles fardh congelada orgánica|O|O||D||1
50352905|Dátiles gundila congelada orgánica|O|O||D||1
50352906|Dátiles halawi/halawy congelada orgánica|O|O||D||1
50352907|Dátiles hilali congelada orgánica|O|O||D||1
50352908|Dátiles khadrawi/khadrawy congelada orgánica|O|O||D||1
50352909|Dátiles khalas congelada orgánica|O|O||D||1
50352910|Dátiles khustawi congelada orgánica|O|O||D||1
50352911|Dátiles khidri congelada orgánica|O|O||D||1
50352912|Dátiles medjool/ medjol congelada orgánica|O|O||D||1
50352913|Dátiles mactoum congelada orgánica|O|O||D||1
50352914|Dátiles neghal congelada orgánica|O|O||D||1
50352915|Dátiles yatimeh congelada orgánica|O|O||D||1
50352916|Dátiles zahidi congelada orgánica|O|O||D||1
50353000|Pitahayas orgánicas congeladas|O|O||D||1
50353001|Pitahaya roja, rosada congelada orgánica|O|O||D||1
50353002|Pitahaya roja, amarillo congelada orgánica|O|O||D||1
50353100|Brevas orgánicas congeladas|O|O||D||1|Higos orgánicos congelados
50353101|Breva bardajic congelada orgánica|O|O||D||1|Higo bardajic congelado orgánico
50353102|Breva pavo carmelito congelada orgánica|O|O||D||1|Higo pavo carmelito congelado orgánico
50353103|Breva calimyma  congelada orgánica|O|O||D||1|Higo calimyma congelado orgánico
50353104|Breva conadria congelada orgánica|O|O||D||1|Higo conadria congelado orgánico
50353105|Breva dotado congelada orgánica|O|O||D||1|Higo dotado congelado orgánico
50353106|Breva kadota congelada orgánica|O|O||D||1|Higo kadota congelado orgánico
50353107|Breva mediterránea congelada orgánica|O|O||D||1|Higo mediterránea congelado orgánico
50353108|Breva misión congelada orgánica|O|O||D||1|Higo misión congelado orgánico
50353109|Breva amyma congelada orgánica|O|O||D||1|Higo amyma congelado orgánico
50353110|Breva verdona congelada orgánica|O|O||D||1|Higo verdona congelado orgánico
50353111|Breva rey blanco congelada orgánica|O|O||D||1|Higo rey blanco congelado orgánico
50353200|Grosellas orgánicas congeladas|O|O||D||1
50353201|Grosella early sulphur congelada orgánica|O|O||D||1
50353202|Grosella gota dorada congelada orgánica|O|O||D||1
50353203|Grosella langley grace congelada orgánica|O|O||D||1
50353204|Grocella leveller congelada orgánica|O|O||D||1
50353205|Grosella london congelada orgánica|O|O||D||1
50353206|Grosella worcestershire congelada orgánica|O|O||D||1
50353207|Grosella americana  worcesterberry congelada orgánica|O|O||D||1
50353300|Toronjas orgánicas congeladas|O|O||D||1
50353301|Toronja burgundi congelada orgánica|O|O||D||1
50353302|Toronja duncan congelada orgánica|O|O||D||1
50353303|Toronja foster congelada orgánica|O|O||D||1
50353304|Toronja marsh congelada orgánica|O|O||D||1
50353305|Toronja nueva zelandia congelada orgánica|O|O||D||1
50353306|Toronja rio rojo congelada orgánica|O|O||D||1
50353307|Toronja ruby rojo congelada orgánica|O|O||D||1
50353308|Toronja star ruby congelada orgánica|O|O||D||1
50353309|Toronja triumph congelada orgánica|O|O||D||1
50353400|Uvas de mesa orgánicas congeladas|O|O||D||1
50353401|Uva alicante congelada orgánica|O|O||D||1
50353402|Uva almeira congelada orgánica|O|O||D||1
50353403|Uva alphonse lavalle congelada orgánica|O|O||D||1
50353404|Uva otoño rey grapes congelada orgánica|O|O||D||1
50353405|Uva otoño royal congelada orgánica|O|O||D||1
50353406|Uva otoño sin semilla congelada orgánica|O|O||D||1
50353407|Uva baresana congelada orgánica|O|O||D||1
50353408|Uva barlinka congelada orgánica|O|O||D||1
50353409|Uva bellisima seedless congelada orgánica|O|O||D||1
50353410|Uva bellesa negra sin pepa congelada orgánica|O|O||D||1
50353411|Uva esmeralda negra congelada orgánica|O|O||D||1
50353412|Uva negra gigante congelada orgánica|O|O||D||1
50353413|Uva globo negro congelada orgánica|O|O||D||1
50353414|Uva negra monnukka congelada orgánica|O|O||D||1
50353415|Uva perla negra congelada orgánica|O|O||D||1
50353416|Uva negra sin semilla congelada orgánica|O|O||D||1
50353417|Uva bonheur congelada orgánica|O|O||D||1
50353418|Uva calmeria congelada orgánica|O|O||D||1
50353419|Uva cardinal congelada orgánica|O|O||D||1
50353420|Uva catawba congelada orgánica|O|O||D||1
50353421|Uva chasselas/golden chasselas congelada orgánica|O|O||D||1
50353422|Uva rosa navidad congelada orgánica|O|O||D||1
50353423|Uva concord congelada orgánica|O|O||D||1
50353424|Uva concord sin pepa congelada orgánica|O|O||D||1
50353425|Uva crimson sin pepa congelada orgánica|O|O||D||1
50353426|Uva dauphine  congelada orgánica|O|O||D||1
50353427|Uva daleware congelada orgánica|O|O||D||1
50353428|Uva early muscat congelada orgánica|O|O||D||1
50353429|Uva early sweet congelada orgánica|O|O||D||1
50353430|Uva esmerald sin pepa congelada orgánica|O|O||D||1
50353431|Uva emperatriz congelada orgánica|O|O||D||1
50353432|Uva emperor congelada orgánica|O|O||D||1
50353433|Uva empress congelada orgánica|O|O||D||1
50353434|Uva exótica congelada orgánica|O|O||D||1
50353435|Uva fantasia congelada orgánica|O|O||D||1
50353436|Uva fantasy sin pepa congelada orgánica|O|O||D||1
50353437|Uva llama congelada orgánica|O|O||D||1
50353438|Uva llama sin semilla congelada orgánica|O|O||D||1
50353439|Uva llama tokay congelada orgánica|O|O||D||1
50353440|Uva rojo ardiente congelada orgánica|O|O||D||1
50353441|Uva galaxy sin pepa congelada orgánica|O|O||D||1
50353442|Uva gamay congelada orgánica|O|O||D||1
50353443|Uva dorada congelada orgánica|O|O||D||1
50353444|Uva hanepot o honeypot congelada orgánica|O|O||D||1
50353445|Uva italia congelada orgánica|O|O||D||1
50353446|Uva jade sin pepa congelada orgánica|O|O||D||1
50353447|Uva jubileo congelada orgánica|O|O||D||1
50353448|Uva rey ruby congelada orgánica|O|O||D||1
50353449|Uva kyoho congelada orgánica|O|O||D||1
50353450|Uva la rochelle congelada orgánica|O|O||D||1
50353451|Uva dedo de dama congelada orgánica|O|O||D||1
50353452|Uva late sin semilla congelada orgánica|O|O||D||1
50353453|Uva majestic sin semilla congelada orgánica|O|O||D||1
50353454|Uva malaga congelada orgánica|O|O||D||1
50353455|Uva marro sin pepa congelada orgánica|O|O||D||1
50353456|Uva muscadine congelada orgánica|O|O||D||1
50353457|Uva muscat flame congelada orgánica|O|O||D||1
50353458|Uva muscat congelada orgánica|O|O||D||1
50353459|Uva muscat sin semilla congelada orgánica|O|O||D||1
50353460|Uva napoleon congelada orgánica|O|O||D||1
50353461|Uva nigeria congelada orgánica|O|O||D||1
50353462|Uva new cross congelada orgánica|O|O||D||1
50353463|Uva nibella congelada orgánica|O|O||D||1
50353464|Uva niagara congelada orgánica|O|O||D||1
50353465|Uva olivette congelada orgánica|O|O||D||1
50353466|Uva perlette congelada orgánica|O|O||D||1
50353467|Uva perlon congelada orgánica|O|O||D||1
50353468|Uva prima negra sin pepa congelada orgánica|O|O||D||1
50353469|Uva princesa congelada orgánica|O|O||D||1
50353470|Uva reina congelada orgánica|O|O||D||1
50353471|Uva roja blush congelada orgánica|O|O||D||1
50353472|Uva roja globe congelada orgánica|O|O||D||1
50353473|Uva roja malaga congelada orgánica|O|O||D||1
50353474|Uva roja sin pepa congelada orgánica|O|O||D||1
50353475|Uva regina congelada orgánica|O|O||D||1
50353476|Uva ribier congelada orgánica|O|O||D||1
50353477|Uva rosita congelada orgánica|O|O||D||1
50353478|Uva rouge congelada orgánica|O|O||D||1
50353479|Uva royal negra sin pepa congelada orgánica|O|O||D||1
50353480|Uva ruby roja sin pepa congelada orgánica|O|O||D||1
50353481|Uva ryby sin pepa congelada orgánica|O|O||D||1
50353482|Uva scarlet royal congelada orgánica|O|O||D||1
50353483|Uva scuppemong congelada orgánica|O|O||D||1
50353484|Uva sugarose congelada orgánica|O|O||D||1
50353485|Uva sugartirteen congelada orgánica|O|O||D||1
50353486|Uva sugraone congelada orgánica|O|O||D||1
50353487|Uva sugrasixteen congelada orgánica|O|O||D||1
50353488|Uva sultana sun roja congelada orgánica|O|O||D||1
50353489|Uva verano royal congelada orgánica|O|O||D||1
50353490|Uva atardecer congelada orgánica|O|O||D||1
50353491|Uva superior sin pepa congelada orgánica|O|O||D||1
50353492|Uva thompson sin pepa congelada orgánica|O|O||D||1
50353493|Uva tokaylpinot gris congelada orgánica|O|O||D||1
50353494|Uva waltman cross congelada orgánica|O|O||D||1
50353495|Uva blanca sin pepa congelada orgánica|O|O||D||1
50353496|Uva zante current congelada orgánica|O|O||D||1
50353500|Uvas pasas orgánicas congeladas|O|O||D||1
50353501|Uva corinth negra congelada orgánica|O|O||D||1
50353502|Uva canner congelada orgánica|O|O||D||1
50353503|Uva dovine congelada orgánica|O|O||D||1
50353504|Uva fiesta congelada orgánica|O|O||D||1
50353505|Uva selme pete congelada orgánica|O|O||D||1
50353506|Uva sultana congelada orgánica|O|O||D||1
50353600|Uvas para vino orgánicas congeladas|O|O||D||1
50353601|Uva uva alicante bouschet congelada orgánica|O|O||D||1
50353602|Uva barbera congelada orgánica|O|O||D||1
50353603|Uva burger congelada orgánica|O|O||D||1
50353604|Uva cabemet franc congelada orgánica|O|O||D||1
50353605|Uva cabenet sauvignon congelada orgánica|O|O||D||1
50353606|Uva carignane congelada orgánica|O|O||D||1
50353607|Uva camelian congelada orgánica|O|O||D||1
50353608|Uva cattarrato congelada orgánica|O|O||D||1
50353609|Uva centurian congelada orgánica|O|O||D||1
50353610|Uva charbono congelada orgánica|O|O||D||1
50353611|Uva chardonnay congelada orgánica|O|O||D||1
50353612|Uva chenin blanco congelada orgánica|O|O||D||1
50353613|Uva cinsaut congelada orgánica|O|O||D||1
50353614|Uva dolcetto congelada orgánica|O|O||D||1
50353615|Uva emerald riesling congelada orgánica|O|O||D||1
50353616|Uva francesa colombard congelada orgánica|O|O||D||1
50353617|Uva granny nap congelada orgánica|O|O||D||1
50353618|Uva gamay beaujolais congelada orgánica|O|O||D||1
50353619|Uva gewurztraminer congelada orgánica|O|O||D||1
50353620|Uva grnache congelada orgánica|O|O||D||1
50353621|Uva grinache blanc congelada orgánica|O|O||D||1
50353622|Uva lagrein congelada orgánica|O|O||D||1
50353623|Uva lambruso congelada orgánica|O|O||D||1
50353624|Uva malbec congelada orgánica|O|O||D||1
50353625|Uva malvasía bianca congelada orgánica|O|O||D||1
50353626|Uva marsanne congelada orgánica|O|O||D||1
50353627|Uva matano congelada orgánica|O|O||D||1
50353628|Uva merlot congelada orgánica|O|O||D||1
50353629|Uva meunier congelada orgánica|O|O||D||1
50353630|Uva missiom congelada orgánica|O|O||D||1
50353631|Uva montepulceano congelada orgánica|O|O||D||1
50353632|Uva muscat blanc congelada orgánica|O|O||D||1
50353633|Uva muscat hamburg congelada orgánica|O|O||D||1
50353634|Uva muscat alexandria congelada orgánica|O|O||D||1
50353635|Uva muscat naranja congelada orgánica|O|O||D||1
50353636|Uva nebbiolo congelada orgánica|O|O||D||1
50353637|Uva palomino congelada orgánica|O|O||D||1
50353638|Uva petit verdor congelada orgánica|O|O||D||1
50353639|Uva petit sirah congelada orgánica|O|O||D||1
50353640|Uva pinot blanc congelada orgánica|O|O||D||1
50353641|Uva pinot gris congelada orgánica|O|O||D||1
50353642|Uva pinot noir congelada orgánica|O|O||D||1
50353643|Uva primitivo congelada orgánica|O|O||D||1
50353644|Uva roussane congelada orgánica|O|O||D||1
50353645|Uva real congelada orgánica|O|O||D||1
50353646|Uva rubired congelada orgánica|O|O||D||1
50353647|Uva ruby cabenet congelada orgánica|O|O||D||1
50353648|Uva salvador congelada orgánica|O|O||D||1
50353649|Uva sangiovese congelada orgánica|O|O||D||1
50353650|Uva sauvignon blanc congelada orgánica|O|O||D||1
50353651|Uva sauvignon musque congelada orgánica|O|O||D||1
50353652|Uva semillon congelada orgánica|O|O||D||1
50353653|Uva souzao congelada orgánica|O|O||D||1
50353654|Uva st emilion congelada orgánica|O|O||D||1
50353655|Uva symohony congelada orgánica|O|O||D||1
50353656|Uva syrah  congelada orgánica|O|O||D||1
50353657|Uva tannat congelada orgánica|O|O||D||1
50353658|Uva tempranillo congelada orgánica|O|O||D||1
50353659|Uvas teroldego congelada orgánica|O|O||D||1
50353660|Uvas tocai friulano congelada orgánica|O|O||D||1
50353661|Uvas touriga nacional congelada orgánica|O|O||D||1
50353662|Uvas triplett blanc congelada orgánica|O|O||D||1
50353663|Uvas viogner congelada orgánica|O|O||D||1
50353664|Uvas blanca riesling congelada orgánica|O|O||D||1
50353665|Uvas zinfandel congelada orgánica|O|O||D||1
50353700|Guayabas orgánicas congeladas|O|O||D||1
50353701|Guayabas beaumont congelada orgánica|O|O||D||1
50353702|Guayabas carrley congelada orgánica|O|O||D||1
50353703|Guayabas lucida congelada orgánica|O|O||D||1
50353704|Guayaba piña congelada orgánica|O|O||D||1
50353800|Arándanos Huckleberry orgánicos congelados|O|O||D||1|Arándanos azules orgánicos congelados
50353801|Arándano invierno negro congelado orgánico|O|O||D||1|Arándano azul invierno negro congelado orgánico
50353802|Arándano cascada congelado orgánico|O|O||D||1|Arándano azul cascada congelado orgánico
50353803|Arándano enano congelado orgánico|O|O||D||1|Arándano azul enano congelado orgánico
50353804|Arándano montaña congelado orgánico|O|O||D||1|Arándano azul montaña congelado orgánico
50353805|Arándano rojo congelado orgánico|O|O||D||1|Arándano azul red congelado orgánico
50353900|Kiwis orgánicos congelados|O|O||D||1
50353901|Fruta de kiwi ananasnaja congelada orgánica|O|O||D||1|Kiwi ananasnaja congelado orgánico
50353902|Fruta de kiwi belleza del ártico congelada orgánica|O|O||D||1|Kiwi belleza del ártico congelado orgánico
50353903|Fruta de kiwi blake congelada orgánica|O|O||D||1|Kiwi blake congelado orgánico
50353904|Fruta de kiwi hayward congelada orgánica|O|O||D||1|Kiwi hayward congelado orgánico
50353905|Fruta de kiwi issai congelada orgánica|O|O||D||1|Kiwi issai congelado orgánico
50353906|Fruta de kiwi siberiana congelada orgánica|O|O||D||1|Kiwi siberiano congelado orgánico
50354000|Naranjos Chinos (kumquats) orgánicos congelados|O|O||D||1
50354001|Naranjo chino hong kong congelado orgánico|O|O||D||1
50354002|Naranjo chino limequat congelado orgánico|O|O||D||1
50354003|Naranjo fruta larga congelado orgánico|O|O||D||1|Naranjo chino long fruit congelado orgánico
50354004|Naranjo chino malayan congelado orgánico|O|O||D||1
50354005|Naranjo meiwa congelado orgánico|O|O||D||1|Naranjo chino meiwa congelado orgánico
50354006|Naranja chino nagami congelado orgánico|O|O||D||1|Naranjo chino nagami congelado orgánico
50354100|Limones orgánicos congelados|O|O||D||1
50354101|Limón baboon congelado orgánico|O|O||D||1
50354102|Limón bearss sicilian congelado orgánico|O|O||D||1
50354103|Limón cameron highland congelado orgánico|O|O||D||1
50354104|Limón escondido congelado orgánico|O|O||D||1
50354105|Limón eureka congelado orgánico|O|O||D||1
50354106|Limón lisbon congelado orgánico|O|O||D||1
50354107|Limón meyer congelado orgánico|O|O||D||1
50354108|Limón volkaner congelado orgánico|O|O||D||1
50354200|Limas orgánicas congeladas|O|O||D||1
50354201|Lima limón indian sweet congelado orgánico|O|O||D||1
50354202|Lima limón congelado orgánico|O|O||D||1
50354203|Lima limón mandarin congelado orgánico|O|O||D||1
50354204|Lima limón philippine congelado orgánico|O|O||D||1
50354205|Lima limón tahitian congelado orgánico|O|O||D||1
50354206|Lima limón bearss congelado orgánico|O|O||D||1
50354207|Lima limón persa congelado orgánico|O|O||D||1
50354208|Lima limón sin pepas congelado orgánico|O|O||D||1|Lima limón sin semillas congelado orgánico
50354300|Nísperos orgánicos congelados|O|O||D||1
50354301|Níspero advance congelado orgánico|O|O||D||1
50354302|Níspero benlehr congelado orgánico|O|O||D||1
50354303|Níspero big jim congelado orgánico|O|O||D||1
50354304|Níspero champagne congelado orgánico|O|O||D||1
50354305|Níspero early rojo congelado orgánico|O|O||D||1
50354306|Níspero nuget dorado congelado orgánico|O|O||D||1
50354307|Níspero herd´s mammoth congelado orgánico|O|O||D||1
50354308|Níspero mogi congelado orgánico|O|O||D||1
50354309|Níspero mrs cooksey congelado orgánico|O|O||D||1
50354310|Níspero fresa congelado orgánico|O|O||D||1
50354311|Níspero tanaka congelado orgánico|O|O||D||1
50354312|Níspero victoria vista blanco congelado orgánico|O|O||D||1
50354313|Níspero wolfe congelado orgánico|O|O||D||1
50354400|Mandarinas orgánicas congeladas|O|O||D||1
50354401|Naranjas clauselinas congelada orgánica|O|O||D||1
50354402|Mandarinas clementinas congelada orgánica|O|O||D||1
50354403|Naranja mandarina cleopatra congelada orgánica|O|O||D||1
50354404|Mandarina dancy congelada orgánica|O|O||D||1
50354405|Naranja ellensday congelada orgánica|O|O||D||1
50354406|Naranja fairchild congelada orgánica|O|O||D||1
50354407|Naranja fallglo congelada orgánica|O|O||D||1
50354408|Naranja fortuna congelada orgánica|O|O||D||1
50354409|Mandarina naranja fremont congelada orgánica|O|O||D||1
50354410|Naranja fremont congelada orgánica|O|O||D||1
50354411|Naranja nuget dorada congelada orgánica|O|O||D||1
50354412|Mandarina naranja miel congelada orgánica|O|O||D||1
50354413|Naranja miel congelada orgánica|O|O||D||1
50354414|Mandarina miel congelada orgánica|O|O||D||1
50354415|Natanja tanjelo honebelle congelada orgánica|O|O||D||1|Naranja tangelo honebelle congelada orgánica
50354416|Naranja mandarina rey congelada orgánica|O|O||D||1
50354417|Naranja kinnow congelada orgánica|O|O||D||1
50354418|Naranja andarinalee congelada orgánica|O|O||D||1
50354419|Naranja makokkee congelada orgánica|O|O||D||1
50354420|Naranja malvasion congelada orgánica|O|O||D||1
50354421|Naranja mandarina mediterránea congelada orgánica|O|O||D||1
50354422|Naranja tangelo minneola congelada orgánica|O|O||D||1
50354423|Naranja monica congelada orgánica|O|O||D||1
50354424|Naranja murcott miel congelada orgánica|O|O||D||1
50354425|Naranja murcott tangors congelada orgánica|O|O||D||1
50354426|Naranja mandarina natsudaidai  congelada orgánica|O|O||D||1
50354427|Naranja mandarina natsumikan congelada orgánica|O|O||D||1
50354428|Naranja tanjelo nocatee congelada orgánica|O|O||D||1
50354429|Naranja tanjelo orlando congelada orgánica|O|O||D||1
50354430|Mandarina ortanique congelada orgánica|O|O||D||1
50354431|Naranja mandarina pagina congelada orgánica|O|O||D||1
50354432|Naranja pixie congelada orgánica|O|O||D||1
50354433|Naranja mandarina ponkan bantangas congelada orgánica|O|O||D||1
50354434|Naranja reina congelada orgánica|O|O||D||1
50354435|Naranja robinson congelada orgánica|O|O||D||1
50354436|Naranja saltenitas congelada orgánica|O|O||D||1
50354437|Naranja tangelo sampson congelada orgánica|O|O||D||1
50354438|Naranja mandarina satsuma congelada orgánica|O|O||D||1
50354439|Naranja mandarina sunburst congelada orgánica|O|O||D||1
50354440|Tangelo congelado orgánico|O|O||D||1
50354441|Naranja mandarina congelada orgánica|O|O||D||1
50354442|Naranja templo congelada orgánica|O|O||D||1
50354443|Naranja thornton congelada orgánica|O|O||D||1
50354444|Mandarina wekiwa congelada orgánica|O|O||D||1
50354445|Mandarina wilkins congelada orgánica|O|O||D||1
50354446|Mandarina willowleaf mediterránea congelada orgánica|O|O||D||1
50354500|Mangos orgánicos congelados|O|O||D||1
50354501|Mango alphonso congelado orgánico|O|O||D||1
50354502|Mango ataulfo congelado orgánico|O|O||D||1
50354503|Mango criollo congelado orgánico|O|O||D||1
50354504|Mango edwards congelado orgánico|O|O||D||1
50354505|Mango francine congelado orgánico|O|O||D||1
50354506|Mango francis congelado orgánico|O|O||D||1
50354507|Mango gandaria congelado orgánico|O|O||D||1
50354508|Mango haden congelado orgánico|O|O||D||1
50354509|Mangos irwin congelado orgánico|O|O||D||1
50354510|Mangos keitt congelado orgánico|O|O||D||1
50354511|Mangos kent congelado orgánico|O|O||D||1
50354512|Mangos kesar congelado orgánico|O|O||D||1
50354513|Mangos kuini congelado orgánico|O|O||D||1
50354514|Mangos manila super congelado orgánico|O|O||D||1
50354515|Mangos manila congelado orgánico|O|O||D||1
50354516|Mangos mayaguez congelado orgánico|O|O||D||1
50354517|Mangos mulgoba congelado orgánico|O|O||D||1
50354518|Mangos oro congelado orgánico|O|O||D||1
50354519|Mangos palmer congelado orgánico|O|O||D||1
50354520|Mango parvin congelado orgánico|O|O||D||1
50354521|Mango sandersha congelado orgánico|O|O||D||1
50354522|Mangos sensation congelado orgánico|O|O||D||1
50354523|Mango smith congelado orgánico|O|O||D||1
50354524|Mango tomy atkin congelado orgánico|O|O||D||1
50354525|Mango van dyke congelado orgánico|O|O||D||1
50354600|Melones orgánicos congelados|O|O||D||1
50354601|Melon allsweet congelado orgánico|O|O||D||1
50354602|Melón athens congelado orgánico|O|O||D||1
50354603|Melón diamante negro congelado orgánico|O|O||D||1
50354604|Melón cal dulce congelado orgánico|O|O||D||1
50354605|Melons cantaloupe congelado orgánico|O|O||D||1
50354606|Melón carnical congelado orgánico|O|O||D||1
50354607|Melón casaba congelado orgánico|O|O||D||1
50354608|Melón cavaillon congelado orgánico|O|O||D||1
50354609|Melón charentais congelado orgánico|O|O||D||1
50354610|Sandia charleston gray congelado orgánico|O|O||D||1
50354611|Melón crenshaw congelado orgánico|O|O||D||1
50354612|Melón crimson sweet congelado orgánico|O|O||D||1
50354613|Melón dixie lee congelado orgánico|O|O||D||1
50354614|Melón eclipse congelado orgánico|O|O||D||1
50354615|Melón ein dór  congelado orgánico|O|O||D||1
50354616|Melón fiesta congelado orgánico|O|O||D||1
50354617|Melón galia congelado orgánico|O|O||D||1
50354618|Melón gaya congelado orgánico|O|O||D||1
50354619|Melón hami congelado orgánico|O|O||D||1
50354620|Melón miel dew congelado orgánico|O|O||D||1
50354621|Melón hielo congelado orgánico|O|O||D||1
50354622|Melón ida orgullo congelado orgánico|O|O||D||1
50354623|Melón juan canary congelado orgánico|O|O||D||1
50354624|Melón jubileo congelado orgánico|O|O||D||1
50354625|Melón jubilación congelado orgánico|O|O||D||1
50354626|Melón kaki / kakri congelado orgánico|O|O||D||1
50354627|Melón kiwano congelado orgánico|O|O||D||1
50354628|Melon koreano congelado orgánico|O|O||D||1|Melón coreano congelado orgánico
50354629|Melón long grey congelado orgánico|O|O||D||1|Melón largo gris congelado orgánico
50354630|Melón mayan congelado orgánico|O|O||D||1
50354631|Melón micky lee congelado orgánico|O|O||D||1
50354632|Melón mirage congelado orgánico|O|O||D||1
50354633|Sandia luna y estrellas congelado orgánico|O|O||D||1
50354634|Melón ogen congelado orgánico|O|O||D||1
50354635|Melón patriota congelado orgánico|O|O||D||1
50354636|Melón pavo real congelado orgánico|O|O||D||1
50354637|Melón pepino congelado orgánico|O|O||D||1
50354638|Melón persian congelado orgánico|O|O||D||1
50354639|Melón picnic congelado orgánico|O|O||D||1
50354640|Melón piel de sapo congelado orgánico|O|O||D||1
50354641|Melón piña congelado orgánico|O|O||D||1
50354642|Melón quetzali congelado orgánico|O|O||D||1
50354643|Melón goblin rojo congelado orgánico|O|O||D||1
50354644|Melón regency congelado orgánico|O|O||D||1
50354645|Melón royal mejestic congelado orgánico|O|O||D||1
50354646|Melón royal star congelado orgánico|O|O||D||1
50354647|Melón dulce royal congelado orgánico|O|O||D||1
50354648|Malon santa claus congelado orgánico|O|O||D||1|Melón piel de sapo congelado orgánico, Melón santa claus congelado orgánico
50354649|Melón sharlyn congelado orgánico|O|O||D||1
50354650|Melón español congelado orgánico|O|O||D||1
50354651|Melón sprite congelado orgánico|O|O||D||1
50354652|Melón starbright congelado orgánico|O|O||D||1
50354653|Melón stars and stripes congelado orgánico|O|O||D||1
50354654|Melón bebe de azúcar congelado orgánico|O|O||D||1
50354655|Sandia bebe de azúcar congelada orgánica|O|O||D||1
50354656|Melón dulce sol congelado orgánico|O|O||D||1
50354657|Sandia corazón dulce sin pepa congelada orgánica|O|O||D||1
50354658|Melón tentación congelado orgánico|O|O||D||1
50354659|Melón tigre bebe congelado orgánico|O|O||D||1
50354660|Melón tuscan tipo congelado orgánico|O|O||D||1
50354661|Sandia bebe amarillo congelada orgánica|O|O||D||1
50354700|Moras mulberry orgánicas congeladas|O|O||D||1|Zarzamoras mulberry orgánicas congeladas
50354701|Mora negra congelada orgánica|O|O||D||1|Zarzamora negra congelada orgánica
50354702|Mora blanca congelada orgánica|O|O||D||1|Zarzamora blanca congelada orgánica
50354800|Mirtos orgánicos congelados|O|O||D||1|Arrayanes congelados orgánicos
50354801|Mirto bog congelado orgánico|O|O||D||1|Arrayán bog congelado orgánico
50354900|Nectarinas orgánicos congelados|O|O||D||1
50354901|Durazno april glo congelado orgánico|O|O||D||1
50354902|Durazno arctic mist congelado orgánico|O|O||D||1
50354903|Durazno artic snow congelado orgánico|O|O||D||1
50354904|Durazno artic star congelado orgánico|O|O||D||1
50354905|Durazno artic dulce congelado orgánico|O|O||D||1
50354906|Durazno artic glo congelado orgánico|O|O||D||1
50354907|Durazno august fire congelado orgánico|O|O||D||1
50354908|Durazno  perla de agosto congelado orgánico|O|O||D||1
50354909|Durazno agosto rojo congelado orgánico|O|O||D||1
50354910|Durazno estrella de agosto congelado orgánico|O|O||D||1
50354911|Durazno big john congelado orgánico|O|O||D||1
50354912|Durazno perla brillante congelado orgánico|O|O||D||1
50354913|Durazno diamante brillante congelado orgánico|O|O||D||1
50354914|Durazno diamante ray congelado orgánico|O|O||D||1
50354915|Durazno earligo congelado orgánico|O|O||D||1
50354916|Durazno diamante temprano congelado orgánico|O|O||D||1
50354917|Durazno fairlane congelado orgánico|O|O||D||1
50354918|Durazno fantasia congelado orgánico|O|O||D||1
50354919|Durazno perla fuego congelado orgánico|O|O||D||1
50354920|Durazno fuego dulce congelado orgánico|O|O||D||1
50354921|Durazno flamekist congelado orgánico|O|O||D||1
50354922|Durazno tipo plano congelado orgánico|O|O||D||1
50354923|Durazno delicia de jardín congelado orgánico|O|O||D||1
50354924|Durazno mina de oro congelado orgánico|O|O||D||1
50354925|Durazno perla grande congelado orgánico|O|O||D||1
50354926|Durazno hardired congelado orgánico|O|O||D||1
50354927|Durazno miel de fuego congelado orgánico|O|O||D||1
50354928|Durazno julio rojo congelado orgánico|O|O||D||1
50354929|Durazno kay perla congelado orgánico|O|O||D||1
50354930|Durazno key dulce congelado orgánico|O|O||D||1
50354931|Durazno diamante mayo congelado orgánico|O|O||D||1
50354932|Durazno mayfire congelado orgánico|O|O||D||1
50354933|Durazno mayglo congelado orgánico|O|O||D||1
50354934|Durazno mericrest congelado orgánico|O|O||D||1
50354935|Durazno diamante rojo congelado orgánico|O|O||D||1
50354936|Durazno oro rojo congelado orgánico|O|O||D||1
50354937|Durazno jim rojo congelado orgánico|O|O||D||1
50354938|Durazno roy rojo congelado orgánico|O|O||D||1
50354939|Durazno rio rojo congelado orgánico|O|O||D||1
50354940|Durazno diamante de rosa congelado orgánico|O|O||D||1
50354941|Durazno rotal glo congelado orgánico|O|O||D||1
50354942|Durazno diamante ryby congelado orgánico|O|O||D||1
50354943|Durazno ruby dulce congelado orgánico|O|O||D||1
50354944|Durazno joya ruddy congelado orgánico|O|O||D||1
50354945|Durazno septiembre rojo congelado orgánico|O|O||D||1
50354946|Durazno reina de nieve congelado orgánico|O|O||D||1
50354947|Durazno primavera clara congelado orgánico|O|O||D||1
50354948|Durazno primavera roja congelado orgánico|O|O||D||1
50354949|Durazno verano rojiso congelado orgánico|O|O||D||1
50354950|Durazno verano claro congelado orgánico|O|O||D||1
50354951|Durazno verano diamante congelado orgánico|O|O||D||1
50354952|Durazno verano fuego congelado orgánico|O|O||D||1
50354953|Durazno verano grande congelado orgánico|O|O||D||1
50354954|Durazno sunglo congelado orgánico|O|O||D||1
50354955|Durazno fuego zee congelado orgánico|O|O||D||1
50354956|Durazno zee glo congelado orgánico|O|O||D||1
50354957|Durazno zeegrand congelado orgánico|O|O||D||1
50355000|Naranjas orgánicas congeladas|O|O||D||1
50355001|Naranja áfrica agria congelada orgánica|O|O||D||1
50355002|Naranja dulce amber congelada orgánica|O|O||D||1
50355003|Naranja argentina agria congelada orgánica|O|O||D||1
50355004|Naranja bahianinha congelado orgánico|O|O||D||1
50355005|Naranja bergamot congelada orgánica|O|O||D||1
50355006|Naranja berna congelada orgánica|O|O||D||1
50355007|Naranja bigaradier apepu congelada orgánica|O|O||D||1
50355008|Naranja agria dulce daidai congelada orgánica|O|O||D||1
50355009|Naranja mono congelada orgánica|O|O||D||1
50355010|Naranja sangre congelada orgánica|O|O||D||1
50355011|Naranja california navel congelada orgánica|O|O||D||1
50355012|Naranja cara cara congelada orgánica|O|O||D||1
50355013|Naranja chinotto congelada orgánica|O|O||D||1
50355014|Naranja sueño nevel congelada orgánica|O|O||D||1
50355015|Naranja gou tou congelada orgánica|O|O||D||1
50355016|Naranja hamlin congelada orgánica|O|O||D||1
50355017|Naranja jaffa congelada orgánica|O|O||D||1
50355018|Naranja jincheng congelada orgánica|O|O||D||1
50355019|Naranja k-temprano congelada orgánica|O|O||D||1
50355020|Naranja kona congelada orgánica|O|O||D||1
50355021|Naranja navel tarde congelada orgánica congelada orgánica|O|O||D||1
50355022|Naranja valencia tarde congelada orgánica|O|O||D||1
50355023|Naranja limequat congelada orgánica|O|O||D||1
50355024|Naranja mar congelada orgánica|O|O||D||1
50355025|Naranja malegold congelada orgánica|O|O||D||1
50355026|Naranja moro congelada orgánica|O|O||D||1
50355027|Naranja moro tabaco congelada orgánica|O|O||D||1
50355028|Naranja navel congelada orgánica|O|O||D||1
50355029|Naranja navelina congelada orgánica|O|O||D||1
50355030|Naranja oro blanco congelada orgánica|O|O||D||1
50355031|Naranja osceola congelada orgánica|O|O||D||1
50355032|Naranja parson carmelito congelada orgánica|O|O||D||1
50355033|Naranja pera congelada orgánica|O|O||D||1
50355034|Naranjo pummulo congelada orgánica|O|O||D||1|Naranja pummulo congelada orgánica
50355035|Naranja rhode rojo congelada orgánica|O|O||D||1
50355036|Naranja roble congelada orgánica|O|O||D||1
50355037|Naranja salustianas congelada orgánica|O|O||D||1
50355038|Naranja sanguine congelada orgánica|O|O||D||1
50355039|Naranja sanguinelli congelada orgánica|O|O||D||1
50355040|Naranja cevilla congelada orgánica|O|O||D||1
50355041|Naranja shamouti jaffa congelada orgánica|O|O||D||1
50355042|Naranja tunis congelada orgánica|O|O||D||1
50355043|Naranja valencia congelada orgánica|O|O||D||1
50355044|Naranja washington navel congelada orgánica|O|O||D||1
50355100|Papayas orgánicas congeladas|O|O||D||1
50355101|Papaya verde cocinar congelada orgánica|O|O||D||1
50355102|Papaya maradol congelada orgánica|O|O||D||1
50355103|Papaya amarillo mexicano congelada orgánica|O|O||D||1
50355104|Papaya montaña congelada orgánica|O|O||D||1
50355105|Papaya solo congelada orgánica|O|O||D||1
50355106|Papaya tainung congelada orgánica|O|O||D||1
50355200|Maracuyás orgánicas congeladas|O|O||D||1
50355201|Fruta maracuyá banana congelada orgánica|O|O||D||1|Curuba congelada orgánica
50355202|Maracuyá flor azul congelada orgánica|O|O||D||1|Maracuyá pasionaria azul congelada orgánica
50355203|Maracuyá crackerjack congelada orgánica|O|O||D||1
50355204|Maracuyá granadilla gigante congelada orgánica|O|O||D||1
50355205|Maracuyá granadilla dorada congelada orgánica|O|O||D||1
50355206|Maracuyá maypops congelada orgánica|O|O||D||1
50355207|Maracuyá roja congelada orgánica|O|O||D||1
50355208|Maracuyá granadilla dulce congelada orgánica|O|O||D||1
50355209|Maracuyá sandia congelada orgánica|O|O||D||1
50355210|Maracuyá  wing- steam congelada orgánica|O|O||D||1
50355300|Duraznos orgánicos congelados|O|O||D||1
50355301|Durazno escudo amber congelado orgánico|O|O||D||1
50355302|Durazno nieve de abril congelado orgánico|O|O||D||1
50355303|Durazno dama de agosto congelado orgánico|O|O||D||1
50355304|Durazno llama de otoño congelado orgánico|O|O||D||1
50355305|Durazno dama de otoño congelado orgánico|O|O||D||1
50355306|Durazno babcock congelado orgánico|O|O||D||1
50355307|Durazno brittany lane congelado orgánico|O|O||D||1
50355308|Durazno cary mac congelado orgánico|O|O||D||1
50355309|Durazno clásica congelado orgánico|O|O||D||1
50355310|Durazno dulce del campo congelado orgánico|O|O||D||1
50355311|Durazno escudo de cielo congelado orgánico|O|O||D||1
50355312|Durazno dama crimson congelado orgánico|O|O||D||1
50355313|Durazno príncipe corona congelado orgánico|O|O||D||1
50355314|Durazno sol david congelado orgánico|O|O||D||1
50355315|Durazno  princesa diamante congelado orgánico|O|O||D||1
50355316|Durazno earlrich congelado orgánico|O|O||D||1
50355317|Durazno majestuosa temprana congelado orgánico|O|O||D||1
50355318|Durazno early treat congelado orgánico|O|O||D||1
50355319|Durazno dama elegante congelado orgánico|O|O||D||1
50355320|Durazno emperatriz congelado orgánico|O|O||D||1
50355321|Durazno encoré congelado orgánico|O|O||D||1
50355322|Durazno dama elegante congelado orgánico|O|O||D||1
50355323|Durazno príncipe de fuego congelado orgánico|O|O||D||1
50355324|Durazno escudo de llama congelado orgánico|O|O||D||1
50355325|Durazno tipo plano congelado orgánico|O|O||D||1
50355326|Durazno escudo de sabor congelado orgánico|O|O||D||1
50355327|Durazno príncipe florida congelado orgánico|O|O||D||1
50355328|Durazno luna llena congelado orgánico|O|O||D||1
50355329|Durazno harvester congelado orgánico|O|O||D||1
50355330|Durazno princesa de hielo congelado orgánico|O|O||D||1
50355331|Durazno princesa de marfil congelado orgánico|O|O||D||1
50355332|Durazno princesa reina jersey congelado orgánico|O|O||D||1
50355333|Durazno john henry congelado orgánico|O|O||D||1
50355334|Durazno príncipe de junio congelado orgánico|O|O||D||1
50355335|Durazno kaweah congelado orgánico|O|O||D||1
50355336|Durazno klondike congelado orgánico|O|O||D||1
50355337|Durazno lindo congelado orgánico|O|O||D||1
50355338|Durazno loring congelado orgánico|O|O||D||1
50355339|Durazno majestuoso congelado orgánico|O|O||D||1
50355340|Durazno o’henry congelado orgánico|O|O||D||1
50355341|Durazno escudo de reina congelado orgánico|O|O||D||1
50355342|Durazno dama roja congelado orgánico|O|O||D||1
50355343|Durazno globo rojo congelado orgánico|O|O||D||1
50355344|Durazno cielo rojo congelado orgánico|O|O||D||1
50355345|Durazno redtop congelado orgánico|O|O||D||1
50355346|Durazno regina congelado orgánico|O|O||D||1
50355347|Durazno dama rica congelado orgánico|O|O||D||1
50355348|Durazno mayo rico congelado orgánico|O|O||D||1
50355349|Durazno gloria royal congelado orgánico|O|O||D||1
50355350|Durazno dama royal congelado orgánico|O|O||D||1
50355351|Durazno nieve de septiembre congelado orgánico|O|O||D||1
50355352|Durazno sol de septiembre congelado orgánico|O|O||D||1
50355353|Durazno gema sierra congelado orgánico|O|O||D||1
50355354|Durazno angel de nieve congelado orgánico|O|O||D||1
50355355|Durazno gema de nieve congelado orgánico|O|O||D||1
50355356|Durazno rey de nieve congelado orgánico|O|O||D||1
50355357|Durazno dama de primavera congelado orgánico|O|O||D||1
50355358|Durazno nieve de primavera congelado orgánico|O|O||D||1
50355359|Durazno escudo de primavera congelado orgánico|O|O||D||1
50355360|Durazno dulce gigante congelado orgánico|O|O||D||1
50355361|Durazno dama de azúcar congelado orgánico|O|O||D||1
50355362|Durazno brillo de sol congelado orgánico|O|O||D||1
50355363|Durazno sunhigh congelado orgánico|O|O||D||1
50355364|Durazno dama super congelado orgánico|O|O||D||1
50355365|Durazno super rico congelado orgánico|O|O||D||1
50355366|Durazno surecrop congelado orgánico|O|O||D||1
50355367|Durazno sueño dulce congelado orgánico|O|O||D||1
50355368|Durazno septiembre dulce congelado orgánico|O|O||D||1
50355369|Durazno vista congelado orgánico|O|O||D||1
50355370|Durazno dama blanca congelado orgánico|O|O||D||1
50355371|Durazno dama zee congelado orgánico|O|O||D||1
50355400|Peras orgánicas congeladas|O|O||D||1
50355401|Peras abate fetel congelada orgánica|O|O||D||1
50355402|Peras anjou congelada orgánica|O|O||D||1
50355403|Pera asiática congelada orgánica|O|O||D||1
50355404|Pera bartlett congelada orgánica|O|O||D||1
50355405|Pera best ever congelada orgánica|O|O||D||1
50355406|Pera beth congelada orgánica|O|O||D||1
50355407|Pera beurre congelada orgánica|O|O||D||1
50355408|Pera bosc congelada orgánica|O|O||D||1
50355409|Pera clapp favorita congelada orgánica|O|O||D||1
50355410|Pera comice congelada orgánica|O|O||D||1
50355411|Pera concorde congelada orgánica|O|O||D||1
50355412|Pera conference congelada orgánica|O|O||D||1
50355413|Pera crimson rojo congelada orgánica|O|O||D||1
50355414|Peras d’ anjou congelada orgánica|O|O||D||1
50355415|Pera dr jules guyot congelada orgánica|O|O||D||1
50355416|Peras early congelada orgánica|O|O||D||1
50355417|Peras emperador carmelito congelada orgánica|O|O||D||1
50355418|Peras forelle congelada orgánica|O|O||D||1
50355419|Pera mantequilla francesa congelada orgánica|O|O||D||1
50355420|Pera glou morceau congelada orgánica|O|O||D||1
50355421|Pera hosui congelada orgánica|O|O||D||1
50355422|Pera mantequilla italiana congelada orgánica|O|O||D||1
50355423|Pera jargonelle congelada orgánica|O|O||D||1
50355424|Pera juno congelada orgánica|O|O||D||1
50355425|Para kaiserlouise bonne de jersey congelada orgánica|O|O||D||1
50355426|Pera keiffer congelada orgánica|O|O||D||1
50355427|Pera rey royal congelada orgánica|O|O||D||1
50355428|Pera limonera congelada orgánica|O|O||D||1
50355429|Pera merton pride congelada orgánica|O|O||D||1
50355430|Pera mauntain bartlette congelada orgánica|O|O||D||1
50355431|Pera oliver de serrers congelada orgánica|O|O||D||1
50355432|Pera onward congelada orgánica|O|O||D||1
50355433|Pera packham´s triumph congelada orgánica|O|O||D||1
50355434|Pera paraíso congelada orgánica|O|O||D||1
50355435|Pera passe crassane congelada orgánica|O|O||D||1
50355436|Pera perry congelada orgánica|O|O||D||1
50355437|Pera bartlette rojo congelada orgánica|O|O||D||1
50355438|Pera dánjou  rojo congelada orgánica|O|O||D||1
50355439|Pera rocha congelada orgánica|O|O||D||1
50355440|Pera rosey rojo congelada orgánica|O|O||D||1
50355441|Pera rosy roja congelada orgánica|O|O||D||1
50355442|Pera majestuosa royal congelada orgánica|O|O||D||1
50355443|Pera ruby rojo congelada orgánica|O|O||D||1
50355444|Pera santa maria congelada orgánica|O|O||D||1
50355445|Pera seckel congelada orgánica|O|O||D||1
50355446|Pera sensación congelada orgánica|O|O||D||1
50355447|Pera crimson estrella congelada orgánica|O|O||D||1
50355448|Pera crimson stark congelada orgánica|O|O||D||1
50355449|Pera bartlette de verano congelada orgánica|O|O||D||1
50355450|Pera verano dorado congelada orgánica|O|O||D||1
50355451|Pera sol dorado congelada orgánica|O|O||D||1
50355452|Pera sunprite congelada orgánica|O|O||D||1
50355453|Pera taylors dorado congelada orgánica|O|O||D||1
50355454|Pera taylors rojo congelada orgánica|O|O||D||1
50355455|Pera tientsin congelada orgánica|O|O||D||1
50355456|Pera tosca congelada orgánica|O|O||D||1
50355457|Pera warden  congelada orgánica|O|O||D||1
50355458|Pera williams bon chretien congelada orgánica|O|O||D||1
50355459|Pera williams congelada orgánica|O|O||D||1
50355460|Pera nelis de invierno congelada orgánica|O|O||D||1
50355500|Caquis orgánicos congelados|O|O||D||1
50355501|Caqui americano congelada orgánica|O|O||D||1
50355502|Caqui sapote negro congelada orgánica|O|O||D||1|Caqui zapote negro congelado orgánico
50355503|Caqui chapote / negro congelada orgánica|O|O||D||1
50355504|Caqui dátale ciruela congelada orgánica|O|O||D||1
50355505|Caqui fuyu congelada orgánica|O|O||D||1
50355506|Caqui gigante fuyu congelada orgánica|O|O||D||1
50355507|Caqui hachiya congelada orgánica|O|O||D||1
50355508|Caqui mantequilla / mabolo congelada orgánica|O|O||D||1
50355509|Caqui príncipe ito congelada orgánica|O|O||D||1
50355510|Caqui brillante royal congelada orgánica|O|O||D||1
50355511|Caqui sharon congelada orgánica|O|O||D||1
50355512|Caqui triumph congelada orgánica|O|O||D||1
50355600|Piñas orgánicas congeladas|O|O||D||1
50355601|Piña chirimoya congelada orgánica|O|O||D||1|Atemoya congelada orgánica
50355602|Piña dorada congelada orgánica|O|O||D||1
50355603|Piña hilo congelada orgánica|O|O||D||1
50355604|Piña kona sugarloaf congelada orgánica|O|O||D||1
50355605|Piña reina natal congelada orgánica|O|O||D||1
50355606|Piña pernabuco congelada orgánica|O|O||D||1
50355607|Piña español rojo congelada orgánica|O|O||D||1
50355608|Piña cayen suave congelada orgánica|O|O||D||1
50355609|Piña sugarloaf congelada orgánica|O|O||D||1
50355610|Piña variegated congelada orgánica|O|O||D||1
50355700|Ciruelos Damascos orgánicos congelados|O|O||D||1
50355701|Ciruelo / damasco negro kat congelado orgánico|O|O||D||1
50355702|Ciruelo / damasco gusto azul congelado orgánico|O|O||D||1
50355703|Ciruelo / damasco corazón de crimson congelado orgánico|O|O||D||1
50355704|Ciruelo / damasco dapply dandy congelado orgánico|O|O||D||1
50355705|Ciruelo / damasco dapple fuego congelado orgánico|O|O||D||1
50355706|Ciruelo / damasco  dapple temprano congelado orgánico|O|O||D||1
50355707|Ciruelo / damasco  caída de sabor congelado orgánico|O|O||D||1
50355708|Ciruelo / damasco sabor de oro congelado orgánico|O|O||D||1
50355709|Ciruelo / damasco sabor granada congelado orgánico|O|O||D||1
50355710|Ciruelo / damasco sabor de corazón congelado orgánico|O|O||D||1
50355711|Ciruelo / damasco joya de sabor congelado orgánico|O|O||D||1
50355712|Ciruelo / damasco sabor de rey congelado orgánico|O|O||D||1
50355713|Ciruelo / damasco sabor de reina congelado orgánico|O|O||D||1
50355714|Ciruelo / damasco sabor supremo congelado orgánico|O|O||D||1
50355715|Ciruelo / damasco sabor premio congelado orgánico|O|O||D||1
50355716|Ciruelo / damasco saborella congelado orgánico|O|O||D||1
50355717|Ciruelo / damasco saborrico congelado orgánico|O|O||D||1
50355718|Ciruelo / damasco  sabor rosa congelado orgánico|O|O||D||1
50355719|Ciruelo / damasco orgullo geo congelado orgánico|O|O||D||1
50355720|Ciruelo / damasco kat rojo congelado orgánico|O|O||D||1
50355721|Ciruelo / damasco premio royal congelado orgánico|O|O||D||1
50355722|Ciruelo / damasco rosa sierra congelado orgánico|O|O||D||1
50355723|Ciruelo / damasco geisha dulce congelado orgánico|O|O||D||1
50355800|Ciruelas orgánicas congeladas|O|O||D||1
50355801|Ciruela joya amber congelada orgánica|O|O||D||1
50355802|Ciruela angeleno congelada orgánica|O|O||D||1
50355803|Ciruela aurora congelada orgánica|O|O||D||1
50355804|Ciruela otoño bonito congelada orgánica|O|O||D||1
50355805|Ciruela gigante de otoño congelada orgánica|O|O||D||1
50355806|Ciruela orgullo de otoño congelada orgánica|O|O||D||1
50355807|Ciruela rosa de otoño congelada orgánica|O|O||D||1
50355808|Ciruela playero congelada orgánica|O|O||D||1
50355809|Ciruela betty anne congelada orgánica|O|O||D||1
50355810|Ciruela belleza negra congelada orgánica|O|O||D||1
50355811|Ciruela bullase negra congelada orgánica|O|O||D||1
50355812|Ciruela diamante negro congelada orgánica|O|O||D||1
50355813|Ciruela gigante negro congelada orgánica|O|O||D||1
50355814|Ciruela hielo negro congelada orgánica|O|O||D||1
50355815|Ciruela esplendor negro congelada orgánica|O|O||D||1
50355816|Ciruela ámbar negro congelada orgánica|O|O||D||1
50355817|Ciruela purpura congelada orgánica|O|O||D||1
50355818|Ciruela  carsbad congelada orgánica|O|O||D||1
50355819|Ciruela casselman congelada orgánica|O|O||D||1
50355820|Ciruela catalina congelada orgánica|O|O||D||1
50355821|Ciruela damson congelada orgánica|O|O||D||1
50355822|Ciruela dolly congelada orgánica|O|O||D||1
50355823|Ciruela earliqueen congelada orgánica|O|O||D||1
50355824|Ciruela rosa early congelada orgánica|O|O||D||1
50355825|Ciruela ébano mayo congelada orgánica|O|O||D||1
50355826|Ciruela ébano congelada orgánica|O|O||D||1
50355827|Ciruela corazón de elefante congelada orgánica|O|O||D||1
50355828|Ciruela belleza de esmeralda congelada orgánica|O|O||D||1
50355829|Ciruela emperatriz congelada orgánica|O|O||D||1
50355830|Ciruela libertad congelada orgánica|O|O||D||1
50355831|Ciruela friar congelada orgánica|O|O||D||1
50355832|Ciruela rojo gar congelada orgánica|O|O||D||1
50355833|Ciruela gobernador congelada orgánica|O|O||D||1
50355834|Ciruela rosa grande congelada orgánica|O|O||D||1
50355835|Ciruela green gage congelada orgánica|O|O||D||1|Ciruela calibre verde congelada orgánica
50355836|Ciruela greengage congelada orgánica|O|O||D||1
50355837|Ciruela hiromi congelada orgánica|O|O||D||1
50355838|Ciruela hiromi rojo congelada orgánica|O|O||D||1
50355839|Ciruela vacacion congelada orgánica|O|O||D||1
50355840|Ciruela howard sol congelada orgánica|O|O||D||1
50355841|Ciruela tipo interspecific congelada orgánica|O|O||D||1
50355842|Ciruela jamaico congelada orgánica|O|O||D||1
50355843|Ciruela joanna rojo congelada orgánica|O|O||D||1
50355844|Ciruela kelsey congelada orgánica|O|O||D||1
50355845|Ciruela jaime rey congelada orgánica|O|O||D||1
50355846|Ciruela laroda congelada orgánica|O|O||D||1
50355847|Ciruela rosa tarde congelada orgánica|O|O||D||1
50355848|Ciruela rosa linda congelada orgánica|O|O||D||1
50355849|Ciruela estrella solitaria congelada orgánica|O|O||D||1
50355850|Ciruela mariposa congelada orgánica|O|O||D||1
50355851|Ciruela mercado negro congelada orgánica|O|O||D||1
50355852|Ciruela mercado rojo congelada orgánica|O|O||D||1
50355853|Ciruela maribel congelada orgánica|O|O||D||1
50355854|Ciruelas sol de octubre congelada orgánica|O|O||D||1
50355855|Ciruela owen t congelada orgánica|O|O||D||1
50355856|Ciruela perdrigon congelada orgánica|O|O||D||1
50355857|Ciruela placer rosado congelada orgánica|O|O||D||1
50355858|Ciruela  presidente congelada orgánica|O|O||D||1
50355859|Ciruela hora prima congelada orgánica|O|O||D||1|Ciruela prime time congelada orgánica
50355860|Ciruela majestad purpura congelada orgánica|O|O||D||1
50355861|Ciruela reina rosa congelada orgánica|O|O||D||1
50355862|Ciruela quetsch congelada orgánica|O|O||D||1
50355863|Ciruela belleza roja congelada orgánica|O|O||D||1
50355864|Ciruela camino rojo congelada orgánica|O|O||D||1
50355865|Ciruela ram rojo congelada orgánica|O|O||D||1
50355866|Ciruela rosa roja congelada orgánica|O|O||D||1
50355867|Ciruela rojo rico congelada orgánica|O|O||D||1
50355868|Ciruela romero congelada orgánica|O|O||D||1
50355869|Ciruela diamante rojo congelada orgánica|O|O||D||1
50355870|Ciruela rojo royal congelada orgánica|O|O||D||1
50355871|Ciruela royal zee congelada orgánica|O|O||D||1
50355872|Ciruela roysum congelada orgánica|O|O||D||1
50355873|Ciruela santa rosa congelada orgánica|O|O||D||1
50355874|Ciruela zafiro congelada orgánica|O|O||D||1
50355875|Ciruela sloe congelada orgánica|O|O||D||1
50355876|Ciruela sta catherine congelada orgánica|O|O||D||1
50355877|Ciruela bullase blanco congelada orgánica|O|O||D||1
50355900|Granadas orgánicas congeladas|O|O||D||1
50355901|Granada foothhill congelada orgánica|O|O||D||1
50355902|Granada, granada congelada orgánica|O|O||D||1|Granada congelada orgánica
50355903|Granada rojo feliz congelada orgánica|O|O||D||1
50355904|Granada nana congelada orgánica|O|O||D||1
50355905|Granada rojo de pat congelada orgánica|O|O||D||1
50355906|Granada pinkhan congelado orgánico|O|O||D||1
50355907|Granada terciopelo morado congelada orgánica|O|O||D||1
50355908|Granada grandioso congelada orgánica|O|O||D||1
50356000|Pomelos orgánicos congelados|O|O||D||1
50356001|Pomelo chandler congelado orgánico|O|O||D||1
50356002|Pomelo hirado butan congelado orgánico|O|O||D||1
50356003|Pomelo liang ping yau congelado orgánico|O|O||D||1
50356004|Pomelo panda wangi congelado orgánico|O|O||D||1
50356005|Pomelo rosado congelado orgánico|O|O||D||1
50356006|Pomelo shaddock rojo congelado orgánico|O|O||D||1
50356007|Pomelo siamese dulce congelado orgánico|O|O||D||1
50356008|Pomelo waingwright congelado orgánico|O|O||D||1
50356100|Membrillos orgánicos congelados|O|O||D||1
50356101|Membrillo campeón congelado orgánico|O|O||D||1
50356102|Membrillo piña congelado orgánico|O|O||D||1
50356103|Membrillo smyma congelado orgánico|O|O||D||1
50356200|Frambuesas orgánicas congeladas|O|O||D||1
50356201|Frambuesa americana roja congelada orgánica|O|O||D||1
50356202|Frambuesa bailey queensland congelada orgánica|O|O||D||1
50356203|Frambuesa negra congelada orgánica|O|O||D||1
50356204|Frambuesa oscura congelada orgánica|O|O||D||1
50356205|Frambuesa deliciosa congelada orgánica|O|O||D||1
50356206|Frambuesa enano focke congelada orgánica|O|O||D||1
50356207|Frambuesa focke hojagris congelada orgánica|O|O||D||1
50356208|Frambuesa focke fresa congelada orgánica|O|O||D||1
50356209|Frambuesa  focke amarillo himalaya congelada orgánica|O|O||D||1
50356210|Frambuesa dorado congelado orgánico|O|O||D||1
50356211|Frambuesa gris nuevo mexico congelada orgánica|O|O||D||1
50356212|Frambuesa jepson whitebark congelada orgánica|O|O||D||1
50356213|Frambuesa kellogs san diego congelada orgánica|O|O||D||1
50356214|Frambuesa leucodemis whitebark congelada orgánica|O|O||D||1
50356215|Frambuesa munz cuyamaca congelada orgánica|O|O||D||1
50356216|Frambuesa peck bartons congelada orgánica|O|O||D||1
50356217|Frambuesa flor morada congelada orgánica|O|O||D||1
50356218|Frambuesa roadside congelada orgánica|O|O||D||1
50356219|Frambuesa san diego congelada orgánica|O|O||D||1
50356220|Frambuesa nieve congelada orgánica|O|O||D||1
50356221|Frambuesa pico de nieve congelada orgánica|O|O||D||1
50356222|Frambuesa hoja de fresa congelada orgánica|O|O||D||1
50356223|Frambuesa cultivo dulce congelada orgánica|O|O||D||1
50356224|Frambuesa tor y gris whitebark congelada orgánica|O|O||D||1
50356225|Frambuesa caribe congelada orgánica|O|O||D||1
50356226|Frambuesa whitebark congelada orgánica|O|O||D||1
50356227|Frambuesa vino congelada orgánica|O|O||D||1
50356228|Frambuesa himalaya amarillo congelada orgánica|O|O||D||1
50356229|Frambuesa yu-shan congelada orgánica|O|O||D||1
50356300|Ruibarbos orgánicos congelados|O|O||D||1|Acelgas rojas orgánicas congeladas
50356301|Ruibarbo crimson rojo congelado orgánico|O|O||D||1|Acelga roja crimson congelada orgánica
50356302|Ruibarbo champagne temprana congelado orgánico|O|O||D||1|Acelga roja champagne temprana congelada orgánica
50356303|Ruibarbo glasking perpetual  congelado orgánico|O|O||D||1|Acelga roja glasking perpetual congelada orgánica
50356304|Ruibarbo sutton congelado orgánico|O|O||D||1|Acelga roja sutton congelada orgánica
50356305|Ruibarbo timperley temprano congelado orgánico|O|O||D||1|Acelga roja temprana de Timperley congelada orgánica
50356306|Ruibarbo valentina congelado orgánico|O|O||D||1|Acelga roja valentina congelada orgánica
50356307|Ruibarbo victoria congelado orgánico|O|O||D||1|Acelga roja victoria congelada orgánica
50356308|Ruibarbo zwolle de cemilla congelado orgánico|O|O||D||1|Acelga roja zwolle de semilla congelada orgánica
50356309|Ruibarbo macdonald congelado orgánico|O|O||D||1|Acelga roja macdonald congelada orgánica
50356310|Ruibarbo tilden congelado orgánico|O|O||D||1|Acelga roja tilden congelada orgánica
50356400|Escaramujos orgánicos congelados|O|O||D||1|Rosa mosqueta orgánicas congeladas
50356401|Escaramujo rosa brier congelado orgánico|O|O||D||1|Rosa mosqueta brier congelada orgánica
50356402|Escaramujo rosa elegante congelado orgánico|O|O||D||1|Rosa mosqueta elegante congelada orgánica
50356403|Escaramujo rosa rugosa congelado orgánico|O|O||D||1|Rosa mosqueta rugosa congelada orgánica
50356404|Escaramujo rosa burnet o scotch congelado orgánico|O|O||D||1|Rosa mosqueta burnet o scotch congelada orgánica
50356500|Sapotes orgánicos congelados|O|O||D||1|Zapotes orgánicos congelados
50356501|Sapote blanco congelado orgánico|O|O||D||1|Zapote blanco congelado orgánico
50356502|Sapote negro congelado orgánico|O|O||D||1|Zapote negro congelado orgánico
50356600|Bayas saskatoon orgánicas congeladas|O|O||D||1|Fresas de junio orgánicas congeladas
50356601|Baya mielmadera saskatoon congelada orgánica|O|O||D||1|Fresa de junio mielmadera congelada orgánica
50356602|Baya northline saskatoon congelada orgánica|O|O||D||1|Fresa de junio northline congelada orgánica
50356603|Baya saskatoon ahumado congelada orgánica|O|O||D||1|Fresa de junio smoky congelada orgánica
50356604|Baya saskatoon thiessen congelada orgánica|O|O||D||1|Fresa de junio thiessen congelada orgánica
50356700|Fresas orgánicas congeladas|O|O||D||1
50356701|Fresa chandler congelada orgánica|O|O||D||1
50356702|Fresa rumbo junio congelada orgánica|O|O||D||1|Fresa temporada de junio congelada orgánica
50356703|Fresa rumbo siempre congelada orgánica|O|O||D||1|Fresa de todo el año congelada orgánica
50356800|Manzanas dulces orgánicas congeladas|O|O||D||1|Saramuyos orgánicos congelados
50356801|Manzana kampong malve dulce congelada orgánica|O|O||D||1|Saramuyo kampong mauve orgánico congelado
50356802|Manzana dulce sin pepa congelada orgánica|O|O||D||1|Saramuyo sin semilla orgánico congelado
50356803|Manzana dulce thai lessand congelada orgánica|O|O||D||1|Saramuyo thai lessand orgánico congelado
50356900|Tamarillos orgánicos congelados|O|O||D||1|Tomates de árbol orgánicos congelados
50356901|Tamarindo amberlea dorado congelado orgánico|O|O||D||1|Tomate de árbol amberlea dorado congelado orgánico
50356902|Tamarindo calvo dorado congelado orgánico|O|O||D||1|Tomate de árbol calvo dorado congelado orgánico
50356903|Tamarindo mina de oro congelado orgánico|O|O||D||1|Tomate de árbol mina de oro congelado orgánico
50356904|Tamarindo oratia rojo congelado orgánico|O|O||D||1|Tomate de árbol oratia rojo congelado orgánico
50356905|Tamarindo beau rojo congelado orgánico|O|O||D||1|Tomate de árbol beau rojo congelado orgánico
50356906|Tamarindo delicia roja congelado orgánico|O|O||D||1|Tomate de árbol delicia roja congelado orgánico
50357000|Frutas Nominant orgánicas congeladas|O|O||D||1|Frutas predominantes orgánicas congeladas
50357001|Cupania congelada orgánica|O|O||D||1|Ackee congelada orgánica
50357002|Babaco congelado orgánico|O|O||D||1|Carica pentágona congelada orgánica
50357003|Banana flor congelada orgánica|O|O||D||1|Flor de plátano congelada orgánica
50357004|Baobab congelada orgánica|O|O||D||1
50357005|Naranja agria congelada orgánica|O|O||D||1
50357006|Canistel congelada orgánica|O|O||D||1|Zapote amarillo congelado orgánico
50357007|Coco congelado orgánico|O|O||D||1
50357008|Baya nublosa congelada orgánica|O|O||D||1|Mora de los pantanos congelada orgánica
50357009|Baya drew congelada orgánica|O|O||D||1|Baya de gota congelada orgánica
50357010|Durian congelada orgánica|O|O||D||1|Durio congelado orgánico
50357011|Baya elder congelada orgánica|O|O||D||1|Baya de sauco congelada orgánica
50357012|Feijoa congelada orgánica|O|O||D||1|Guayabo del Brasil congelado orgánico
50357013|Mora congelada orgánica|O|O||D||1|Mora congelada orgánica
50357014|Cretaegus congelada orgánica|O|O||D||1|Majuelo congelado orgánico
50357015|Baya miel congelada orgánica|O|O||D||1|Madreselva azul congelada orgánica
50357016|Jackfruit congelada orgánica|O|O||D||1|Yaca congelada orgánica
50357017|Jambolan congelada orgánica|O|O||D||1
50357018|Jujube congelada orgánica|O|O||D||1|Azufaifa congelada orgánica
50357019|Liches congelado orgánicos orgánicos|O|O||D||1|Lichi congelado orgánico
50357020|Mangostinos congelado orgánicos orgánicos|O|O||D||1|Mangostán congelado orgánico
50357021|Medlar congelada orgánica|O|O||D||1
50357022|Mombines congelada orgánica|O|O||D||1|Hobo congelado orgánico
50357023|Monstera congelada orgánica|O|O||D||1|Cerimán congelado orgánico
50357024|Pepinos congelado orgánico|O|O||D||1|Pepino dulce congelado orgánico
50357025|Platono congelado orgánico|O|O||D||1|Plátano macho congelado orgánico
50357026|Peras en escabeche congelada orgánica|O|O||D||1|Tuna congelada orgánica
50357027|Mamonsillo congelado orgánico|O|O||D||1|Guaya congelada orgánica
50357028|Rambután congelado orgánico|O|O||D||1|Achotillo congelado orgánico
50357029|Manzana rosa congelada orgánica|O|O||D||1|Pero de agua congelado orgánico
50357030|Rosele congelada orgánica|O|O||D||1|Flor de jamaica congelada orgánica
50357031|Baya rowan congelada orgánica|O|O||D||1|Serba congelada orgánica
50357032|Baya buckhom de mar congelada orgánica|O|O||D||1|Espino amarillo congelado orgánico
50357033|Baya plata congelada orgánica|O|O||D||1|Olivo de otoño congelado orgánico
50357034|Baya sorbete congelado orgánico|O|O||D||1|Serba congelada orgánica
50357035|Guanabana congelada orgánica|O|O||D||1|Guanábana congelada orgánica
50357036|Manzana estrella congelada orgánica|O|O||D||1|Cainito congelado orgánico
50357037|Tamarindo congelado orgánico|O|O||D||1
50357100|Aronias orgánicas congeladas|O|O||D||1
50357101|Aronia magia de otoño congelada orgánica|O|O||D||1
50357102|Aronia brillantísima congelada orgánica|O|O||D||1
50357103|Aronia nero congelada orgánica|O|O||D||1
50357104|Aronia viquingo congelada orgánica|O|O||D||1
50357200|Aceitunas orgánicas congeladas|O|O||D||1
50357201|Aceitunas agrinion congelada orgánica|O|O||D||1|Aceituna agrinion congelada orgánica
50357202|Aceitunas aleppo congelada orgánica|O|O||D||1|Aceituna aleppo congelada orgánica
50357203|Aceitunas  alfonso congelada orgánica|O|O||D||1|Aceituna alfonso congelada orgánica
50357204|Aceitunas  amfisa congelada orgánica|O|O||D||1|Aceituna amfisa congelada orgánica
50357205|Aceitunas  arauco congelada orgánica|O|O||D||1|Aceituna arauco congelada orgánica
50357206|Aceitunas  arbequina congelada orgánica|O|O||D||1|Aceituna arbequina congelada orgánica
50357207|Aceitunas  atlanta congelada orgánica|O|O||D||1|Aceituna atlanta congelada orgánica
50357208|Aceitunas  cerignola congelada orgánica|O|O||D||1|Aceituna cerignola congelada orgánica
50357209|Aceitunas  cracked provencal congelada orgánica|O|O||D||1|Aceituna cracked provencal congelada orgánica
50357210|Aceitunas  empeltre congelada orgánica|O|O||D||1|Aceituna empeltre congelada orgánica
50357211|Aceitunas gaeta  congelada orgánica|O|O||D||1|Aceituna gaeta congelada orgánica
50357212|Aceitunas hondoelia congelada orgánica|O|O||D||1|Aceituna hondoelia congelada orgánica
50357213|Aceitunas kalamata congelada orgánica|O|O||D||1|Aceituna kalamata congelada orgánica
50357214|Aceitunas kura congelada orgánica|O|O||D||1|Aceituna kura congelada orgánica
50357215|Aceitunas ligurian congelada orgánica|O|O||D||1|Aceituna ligurian congelada orgánica
50357216|Aceitunas lucque congelada orgánica|O|O||D||1|Aceituna lucque congelada orgánica
50357217|Aceitunas lugano congelada orgánica|O|O||D||1|Aceituna lugano congelada orgánica
50357218|Aceitunas manzanilla congelada orgánica|O|O||D||1|Aceituna manzanilla congelada orgánica
50357219|Aceitunas marche congelada orgánica|O|O||D||1|Aceituna marche congelada orgánica
50357220|Aceitunas misión congelada orgánica|O|O||D||1|Aceituna misión congelada orgánica
50357221|Aceitunas nafplion verde congelada orgánica|O|O||D||1|Aceituna nafplion verde congelada orgánica
50357222|Aceitunas nicoise congelada orgánica|O|O||D||1|Aceituna nicoise congelada orgánica
50357223|Aceitunas nyons congelada orgánica|O|O||D||1|Aceituna nyons congelada orgánica
50357224|Aceitunas picholine congelada orgánica|O|O||D||1|Aceituna picholine congelada orgánica
50357225|Aceitunas ponentine congelada orgánica|O|O||D||1|Aceituna ponentine congelada orgánica
50357226|Aceitunas royal congelada orgánica|O|O||D||1|Aceituna royal congelada orgánica
50357227|Aceitunas seracena congelada orgánica|O|O||D||1|Aceituna seracena congelada orgánica
50357228|Aceitunas sevillano congelada orgánica|O|O||D||1|Aceituna sevillano congelada orgánica
50357229|Aceitunas sicilian congelada orgánica|O|O||D||1|Aceituna sicilian congelada orgánica
50357230|Aceitunas toscanella congelada orgánica|O|O||D||1|Aceituna toscanella congelada orgánica
50361500|Manzanas en lata o en frasco|O|O||D||1
50361501|Manzanas akane en lata o en frasco|O|O||D||1|Manzana akane en lata o en frasco
50361502|Manzana ambrosia en lata o en frasco|O|O||D||1
50361503|Manzanas api en lata o en frasco|O|O||D||1|Manzana api en lata o en frasco
50361504|Manzanas baldwin en lata o en frasco|O|O||D||1|Manzana baldwin en lata o en frasco
50361505|Manzanas brabum en lata o en frasco|O|O||D||1|Manzana brabum en lata o en frasco
50361506|Manzanas bramley en lata o en frasco|O|O||D||1|Manzana bramley en lata o en frasco
50361507|Manzana joven bramley en lata o en frasco|O|O||D||1
50361508|Manzana calville blanche d’hiver en lata o en frasco|O|O||D||1
50361509|Manzana cameo en lata o en frasco|O|O||D||1
50361510|Manzana charles ross en lata o en frasco|O|O||D||1
50361511|Manzana codlin en lata o en frasco|O|O||D||1
50361512|Manzana cortland en lata o en frasco|O|O||D||1
50361513|Manzana costard en lata o en frasco|O|O||D||1
50361514|Manzana court pendu plat en lata o en frasco|O|O||D||1
50361515|Manzana  cox´s orange pippin en lata o en frasco|O|O||D||1
50361516|Manzana crab en lata o en frasco|O|O||D||1
50361517|Manzana crispin en lata o en frasco|O|O||D||1
50361518|Manzana delicious en lata o en frasco|O|O||D||1
50361519|Manzana duquesa en lata o en frasco|O|O||D||1
50361520|Manzana earligold en lata o en frasco|O|O||D||1
50361521|Manzana early mcintosh en lata o en frasco|O|O||D||1
50361522|Manzana elstar en lata o en frasco|O|O||D||1
50361523|Manzana imperio en lata o en frasco|O|O||D||1
50361524|Manzana flower of kent en lata o en frasco|O|O||D||1
50361525|Manzana fiji en lata o en frasco|O|O||D||1
50361526|Manzana gala en lata o en frasco|O|O||D||1
50361527|Manzana gascoyne´s scarlet en lata o en frasco|O|O||D||1
50361528|Manzana gillyflower en lata o en frasco|O|O||D||1
50361529|Manzana ginger gold en lata o en frasco|O|O||D||1
50361530|Manzana gladstone en lata o en frasco|O|O||D||1
50361531|Manzana gloster en lata o en frasco|O|O||D||1
50361532|Manzana dorado supremo en lata o en frasco|O|O||D||1
50361533|Manzana dorado delicioso en lata o en frasco|O|O||D||1
50361534|Manzana dorado noble nobel en lata o en frasco|O|O||D||1
50361535|Manzana granny smith en lata o en frasco|O|O||D||1
50361536|Manzana gravenstain en lata o en frasco|O|O||D||1
50361537|Manzana greening en lata o en frasco|O|O||D||1
50361538|Manzana greensleeves en lata o en frasco|O|O||D||1
50361539|Manzana honeycrisp en lata o en frasco|O|O||D||1
50361540|Manzana howgate wonder en lata o en frasco|O|O||D||1
50361541|Manzana red ida en lata o en frasco|O|O||D||1
50361542|Manzana james grives en lata o en frasco|O|O||D||1
50361543|Manzana jersey mac en lata o en frasco|O|O||D||1
50361544|Manzana jaster en lata o en frasco|O|O||D||1
50361545|Manzana jonagold en lata o en frasco|O|O||D||1
50361546|Manzana jonamac en lata o en frasco|O|O||D||1
50361547|Manzana  jonathan  en lata o en frasco|O|O||D||1
50361548|Manzana katy en lata o en frasco|O|O||D||1
50361549|Manzana kidd´s orange red en lata o en frasco|O|O||D||1
50361550|Manzana lady en lata o en frasco|O|O||D||1
50361551|Manzana law rome en lata o en frasco|O|O||D||1
50361552|Manzana laxton en lata o en frasco|O|O||D||1
50361553|Manzana lord derby en lata o en frasco|O|O||D||1
50361554|Manzana macoun  en lata o en frasco|O|O||D||1
50361555|Manzana mcintosh en lata o en frasco|O|O||D||1
50361556|Manzana mutsu en lata o en frasco|O|O||D||1
50361557|Manzana newtown pippin en lata o en frasco|O|O||D||1
50361558|Manzana northen spy en lata o en frasco en lata o en frasco|O|O||D||1
50361559|Manzana orleans reinette en lata o en frasco|O|O||D||1
50361560|Manzana ozark gold en lata o en frasco|O|O||D||1
50361561|Manzana pacific rose en lata o en frasco|O|O||D||1
50361562|Manzana paula red en lata o en frasco|O|O||D||1
50361563|Manzana peamain en lata o en frasco|O|O||D||1
50361564|Manzana pink lady en lata o en frasco|O|O||D||1
50361565|Manzana pippin en lata o en frasco|O|O||D||1
50361566|Manzana pitmaston pineapple en lata o en frasco|O|O||D||1
50361567|Manzana pomme dápi en lata o en frasco|O|O||D||1
50361568|Manzana prime gold en lata o en frasco|O|O||D||1
50361569|Manzana roja astrakhan en lata o en frasco|O|O||D||1
50361570|Manzana roja boscoop en lata o en frasco|O|O||D||1
50361571|Manzana  roja chief en lata o en frasco|O|O||D||1
50361572|Manzana roja delicious en lata o en frasco|O|O||D||1
50361573|Manzana roja grvenstain en lata o en frasco|O|O||D||1
50361574|Manzana  roma en lata o en frasco|O|O||D||1
50361575|Manzanared stayman en lata o en frasco|O|O||D||1
50361576|Manzana roja york en lata o en frasco|O|O||D||1
50361577|Manzana reinette en lata o en frasco|O|O||D||1
50361578|Manzana rome beuty en lata o en frasco|O|O||D||1
50361579|Manzana russet en lata o en frasco|O|O||D||1
50361580|Manzana sierra belleza en lata o en frasco|O|O||D||1
50361581|Manzana spartan en lata o en frasco|O|O||D||1
50361582|Manzana stark crimson en lata o en frasco|O|O||D||1
50361583|Manzana starking en lata o en frasco|O|O||D||1
50361584|Manzana stayman en lata o en frasco|O|O||D||1
50361585|Manzana stayman winesap en lata o en frasco|O|O||D||1
50361586|Manzana verano rambo en lata o en frasco|O|O||D||1
50361587|Manzana tsugaru en lata o en frasco|O|O||D||1
50361588|Manzana veinte onzas en lata o en frasco|O|O||D||1
50361589|Manzana tydeman red en lata o en frasco|O|O||D||1
50361590|Manzana vistabella en lata o en frasco|O|O||D||1
50361591|Manzana weatley en lata o en frasco|O|O||D||1
50361592|Manzana blanca joanetine en lata o en frasco|O|O||D||1
50361593|Manzana blanca transparente en lata o en frasco|O|O||D||1
50361594|Manzana winesap en lata o en frasco|O|O||D||1
50361595|Manzana worcester en lata o en frasco|O|O||D||1
50361596|Manzana york imperial en lata o en frasco|O|O||D||1
50361600|Albaricoques en lata o en frasco|O|O||D||1|Chabacanos en lata o en frasco
50361601|Abaricoques ambercot en lata o en frasco|O|O||D||1|Chabacano ambercot en lata o en frasco
50361602|Albaricoques apache en lata o en frasco|O|O||D||1|Chabacano apache en lata o en frasco
50361603|Albaricoques brittany dorado en lata o en frasco|O|O||D||1|Chabacano brittany dorado en lata o en frasco
50361604|Albaricoque black en lata o en frasco|O|O||D||1|Chabacano black en lata o en frasco
50361605|Albaricoque blenheim en lata o en frasco|O|O||D||1|Chabacano blenheim en lata o en frasco
50361606|Albaricoque bonny en lata o en frasco|O|O||D||1|Chabacano bonny en lata o en frasco
50361607|Albaricoque biluda en lata o en frasco|O|O||D||1|Chabacano biluda en lata o en frasco
50361608|Albaricoque castlebrite en lata o en frasco|O|O||D||1|Chabacano castlebrite en lata o en frasco
50361609|Albaricoque  clutha gold en lata o en frasco|O|O||D||1|Chabacano clutha gold en lata o en frasco
50361610|Albaricoque clutha sun en lata o en frasco|O|O||D||1|Chabacano clutha sun en lata o en frasco
50361611|Albaricoque derby royal en lata o en frasco|O|O||D||1|Chabacano derby royal en lata o en frasco
50361612|Albaricoque dina en lata o en frasco|O|O||D||1|Chabacano dina en lata o en frasco
50361613|Albaricoque earlicot en lata o en frasco|O|O||D||1|Chabacano earlicot en lata o en frasco
50361614|Albaricoque earliman en lata o en frasco|O|O||D||1|Chabacano earliman en lata o en frasco
50361615|Albaricoque early bright en lata o en frasco|O|O||D||1|Chabacano early bright en lata o en frasco
50361616|Albaricoque  dorado en llamas en lata o en frasco|O|O||D||1|Chabacano dorado en llamas en lata o en frasco
50361617|Albaricoque frenso en lata o en frasco|O|O||D||1|Chabacano frenso en lata o en frasco
50361618|Albaricoque dorado claro en lata o en frasco|O|O||D||1|Chabacano dorado claro en lata o en frasco
50361619|Albaricoque barra dorada en lata o en frasco|O|O||D||1|Chabacano barra dorada en lata o en frasco
50361620|Albaricoque dorada dulce en lata o en frasco|O|O||D||1|Chabacano dorada dulce en lata o en frasco
50361621|Albaricoque dorada rica en lata o en frasco|O|O||D||1|Chabacano dorada rica en lata o en frasco
50361622|Albaricoque helena en lata o en frasco|O|O||D||1|Chabacano helena en lata o en frasco
50361623|Albaricoque honeycot en lata o en frasco|O|O||D||1|Chabacano  en lata o en frasco
50361624|Albaricoque imperial en lata o en frasco|O|O||D||1|Chabacano imperial en lata o en frasco
50361625|Albaricoque jordanne en lata o en frasco|O|O||D||1|Chabacano jordanne en lata o en frasco
50361626|Albaricoque jumbo cot en lata o en frasco|O|O||D||1|Chabacano jumbo cot en lata o en frasco
50361627|Albaricoque kandy kot en lata o en frasco|O|O||D||1|Chabacano kandy kot en lata o en frasco
50361628|Albaricoque katy en lata o en frasco|O|O||D||1|Chabacano katy en lata o en frasco
50361629|Albaricoque rey en lata o en frasco|O|O||D||1|Chabacano rey en lata o en frasco
50361630|Albaricoque lambertin en lata o en frasco|O|O||D||1|Chabacano lambertin en lata o en frasco
50361631|Albaricoque loma en lata o en frasco|O|O||D||1|Chabacano loma en lata o en frasco
50361632|Albaricoque lulu belle en lata o en frasco|O|O||D||1|Chabacano lulu belle en lata o en frasco
50361633|Albaricoque modesto en lata o en frasco|O|O||D||1|Chabacano modesto en lata o en frasco
50361634|Albaricoque moorpark en lata o en frasco|O|O||D||1|Chabacano moorpark en lata o en frasco
50361635|Albaricoque orangered en lata o en frasco|O|O||D||1|Chabacano orange red en lata o en frasco
50361636|Albaricoque palstein en lata o en frasco|O|O||D||1|Chabacano palstein en lata o en frasco
50361637|Albaricoque patterson en lata o en frasco|O|O||D||1|Chabacano patterson en lata o en frasco
50361638|Albaricoque perfection en lata o en frasco|O|O||D||1|Chabacano perfection en lata o en frasco
50361639|Albaricoque poppy en lata o en frasco|O|O||D||1|Chabacano poppy en lata o en frasco
50361640|Albaricoque poppycot en lata o en frasco|O|O||D||1|Chabacano poppy cot en lata o en frasco
50361641|Albaricoque reina en lata o en frasco|O|O||D||1|Chabacano reina en lata o en frasco
50361642|Albaricoque riland en lata o en frasco|O|O||D||1|Chabacano riland en lata o en frasco
50361643|Albaricoque rival en lata o en frasco|O|O||D||1|Chabacano rival en lata o en frasco
50361644|Albaricoque robada en lata o en frasco|O|O||D||1|Chabacano robada en lata o en frasco
50361645|Albaricoque royal en lata o en frasco|O|O||D||1|Chabacano royal en lata o en frasco
50361646|Albaricoque  royal blenheim en lata o en frasco|O|O||D||1|Chabacano royal blenheim en lata o en frasco
50361647|Albaricoque  royal orange en lata o en frasco|O|O||D||1|Chabacano royal orange en lata o en frasco
50361648|Albaricoque gota de sol en lata o en frasco|O|O||D||1|Chabacano gota de sol en lata o en frasco
50361649|Albaricoque tilton en lata o en frasco|O|O||D||1|Chabacano tilton en lata o en frasco
50361650|Albaricoque tomcot en lata o en frasco|O|O||D||1|Chabacano tomcot en lata o en frasco
50361651|Albaricoque tracy en lata o en frasco|O|O||D||1|Chabacano tracy en lata o en frasco
50361652|Albaricoque tri gem en lata o en frasco|O|O||D||1|Chabacano tri gem en lata o en frasco
50361653|Albaricoque valle dorado en lata o en frasco|O|O||D||1|Chabacano valle dorado en lata o en frasco
50361654|Albaricoque westley en lata o en frasco|O|O||D||1|Chabacano westley en lata o en frasco
50361655|Albaricoque  york en lata o en frasco|O|O||D||1|Chabacano york en lata o en frasco
50361700|Bananos en lata o en frasco|O|O||D||1|Plátanos en lata o en frasco
50361701|Banana manzana en lata o en frasco|O|O||D||1|Plátano apple en lata o en frasco
50361702|Banana bebe en lata o en frasco|O|O||D||1|Plátano bebe en lata o en frasco
50361703|Banana burro en lata o en frasco|O|O||D||1|Plátano burro en lata o en frasco
50361704|Bananas cavendish en lata o en frasco|O|O||D||1|Plátano cavendish en lata o en frasco
50361705|Bananas dominico en lata o en frasco|O|O||D||1|Plátano dominico en lata o en frasco
50361706|Bananas verde en lata o en frasco|O|O||D||1|Plátano verde en lata o en frasco
50361707|Bananas gros michel en lata o en frasco|O|O||D||1|Plátano gros michel en lata o en frasco
50361708|Bananas lacatan en lata o en frasco|O|O||D||1|Plátano lacatan en lata o en frasco
50361709|Bananas lady finger en lata o en frasco|O|O||D||1|Plátano lady finger en lata o en frasco
50361710|Bananas manzano en lata o en frasco|O|O||D||1|Plátano manzano en lata o en frasco
50361711|Banana mysore en lata o en frasco|O|O||D||1|Plátano mysore en lata o en frasco
50361712|Banana pisang mas en lata o en frasco|O|O||D||1|Plátano pisang mas en lata o en frasco
50361713|Bananas red en lata o en frasco|O|O||D||1|Plátano red en lata o en frasco
50361714|Bananas saba en lata o en frasco|O|O||D||1|Plátano saba en lata o en frasco
50361715|Bananas sucrier en lata o en frasco|O|O||D||1|Plátano sucrier en lata o en frasco
50361800|Barberries en lata o en frasco|O|O||D||1|Berberís en lata o en frasco
50361801|Berberís paleleaf en lata o en frasco|O|O||D||1|Berberí paleleaf en lata o en frasco
50361802|Barberís chenault en lata o en frasco|O|O||D||1|Berberí chenault en lata o en frasco
50361803|Barberries red en lata o en frasco|O|O||D||1|Berberí  red en lata o en frasco
50361804|Barberís wintergreen en lata o en frasco|O|O||D||1|Berberí wintergreen en lata o en frasco
50361805|Barberís korean en lata o en frasco|O|O||D||1|Berberí korean en lata o en frasco
50361806|Barberís mentor en lata o en frasco|O|O||D||1|Berberí mentor en lata o en frasco
50361807|Barberís japanese en lata o en frasco|O|O||D||1|Berberí japanese en lata o en frasco
50361808|Barberís atropurpurea en lata o en frasco|O|O||D||1|Berberí atropurpurea en lata o en frasco
50361809|Barberís aurea en lata o en frasco|O|O||D||1|Berberí aurea en lata o en frasco
50361810|Barberís bagatelle en lata o en frasco|O|O||D||1|Berberí bagatelle en lata o en frasco
50361811|Barberís crimsom pygmy en lata o en frasco|O|O||D||1|Berberí crimsom pygmy en lata o en frasco
50361812|Barberís kobold en lata o en frasco|O|O||D||1|Berberí kobold en lata o en frasco
50361813|Barberís warty en lata o en frasco|O|O||D||1|Berberí warty en lata o en frasco
50361814|Barberís european en lata o en frasco|O|O||D||1|Berberí european en lata o en frasco
50361900|Gayubas en lata o en frasco|O|O||D||1|Rastreras en lata o en frasco
50361901|Gayuba alpine en lata o en frasco|O|O||D||1|Rastrera alpine en lata o en frasco
50361902|Gayuba roja en lata o en frasco|O|O||D||1|Rastrera roja en lata o en frasco
50361903|Gayuba común en lata o en frasco|O|O||D||1|Rastrera común en lata o en frasco
50362000|Moras en lata o en frasco|O|O||D||1|Zarzamoras en lata o en frasco
50362001|Mora apache en lata o en frasco|O|O||D||1|Zarzamora apache en lata o en frasco
50362002|Mora satín negro en lata o en frasco|O|O||D||1|Zarzamora satín negro en lata o en frasco
50362003|Mora boysen en lata o en frasco|O|O||D||1|Zarzamora boysen en lata o en frasco
50362004|Mora cherokee en lata o en frasco|O|O||D||1|Zarzamora cherokee en lata o en frasco
50362005|Mora chester en lata o en frasco|O|O||D||1|Zarzamora chéster en lata o en frasco
50362006|Mora dirksen en lata o en frasco|O|O||D||1|Zarzamora dirksen en lata o en frasco
50362007|Bayasjosta en lata o en frasco|O|O||D||1|Zarzamora josta en lata o en frasco
50362008|Bayaslogan en lata o en frasco|O|O||D||1|Zarzamora logan en lata o en frasco
50362009|Bayasmarion en lata o en frasco|O|O||D||1|Zarzamora marion en lata o en frasco
50362010|Mora navaho en lata o en frasco|O|O||D||1|Zarzamora navaho en lata o en frasco
50362011|Bayanectar en lata o en frasco|O|O||D||1|Zarzamora néctar en lata o en frasco
50362012|Mora olallie en lata o en frasco|O|O||D||1|Zarzamora olallie en lata o en frasco
50362013|Baya tay en lata o en frasco|O|O||D||1|Zarzamora tay en lata o en frasco
50362014|Mora thomless hull en lata o en frasco|O|O||D||1|Zarzamora thomless hull en lata o en frasco
50362015|Baya joven en lata o en frasco|O|O||D||1|Zarzamora joven en lata o en frasco
50362100|Arándanos de mirto en lata o en frasco|O|O||D||1|Mirtillos en lata o en frasco
50362101|Arandanos bog en lata o en frasco|O|O||D||1|Mirtillo bog en lata o en frasco
50362102|Arandanos dwarf en lata o en frasco|O|O||D||1|Mirtillo enano en lata o en frasco
50362103|Arandanos mountain en lata o en frasco|O|O||D||1|Mirtillo de montaña en lata o en frasco
50362104|Arandanos oval-leaved en lata o en frasco|O|O||D||1|Mirtillo oval-leaved en lata o en frasco
50362200|Agrás en lata o en frasco|O|O||D||1|Frutos azules del bosque en lata o en frasco
50362201|Agras bluecrop en lata o en frasco|O|O||D||1|Fruto azul del bosque bluecrop en lata o en frasco
50362202|Agras bluetta en lata o en frasco|O|O||D||1|Fruto azul del bosque bluetta en lata o en frasco
50362203|Agras brigitta en lata o en frasco|O|O||D||1|Fruto azul del bosque brigitta en lata o en frasco
50362204|Agras chandler en lata o en frasco|O|O||D||1|Fruto azul del bosque chandler en lata o en frasco
50362205|Agras duke en lata o en frasco|O|O||D||1|Fruto azul del bosque duke en lata o en frasco
50362206|Agras hardyblue en lata o en frasco|O|O||D||1|Fruto azul del bosque hardyblue en lata o en frasco
50362207|Agras legacy en lata o en frasco|O|O||D||1|Fruto azul del bosque legacy en lata o en frasco
50362208|Agras misty en lata o en frasco|O|O||D||1|Fruto azul del bosque misty en lata o en frasco
50362209|Agras nelson en lata o en frasco|O|O||D||1|Fruto azul del bosque nelson en lata o en frasco
50362210|Agras northblue en lata o en frasco|O|O||D||1|Fruto azul del bosque northblue en lata o en frasco
50362211|Agras northcountry en lata o en frasco|O|O||D||1|Fruto azul del bosque northcountry en lata o en frasco
50362212|Agras northsky en lata o en frasco|O|O||D||1|Fruto azul del bosque northsky en lata o en frasco
50362213|Agras patriot en lata o en frasco|O|O||D||1|Fruto azul del bosque patriot en lata o en frasco
50362214|Agras spartan en lata o en frasco|O|O||D||1|Fruto azul del bosque spartan en lata o en frasco
50362215|Agras toro en lata o en frasco|O|O||D||1|Fruto azul del bosque toro en lata o en frasco
50362300|Frutas del pan en lata o en frasco|O|O||D||1
50362301|Fruta de pan chataigne en lata o en frasco|O|O||D||1|Fruta del pan chataigne en lata o en frasco
50362302|Fruta de pan sin semilla en lata o en frasco|O|O||D||1|Fruta del pan sin semilla en lata o en frasco
50362303|Fruta de pan corazón blanco en lata o en frasco|O|O||D||1|Fruta del pan corazón blanco en lata o en frasco
50362304|Fruta de pan corazón amarillo en lata o en frasco|O|O||D||1|Fruta del pan corazón amarillo en lata o en frasco
50362400|Chirimoyas en lata o en frasco|O|O||D||1|Annonas en lata o en frasco
50362401|Chirimoya chays en lata o en frasco|O|O||D||1|Annona chays en lata o en frasco
50362402|Chirimoya bronceada en lata o en frasco|O|O||D||1|Annona bronceada en lata o en frasco
50362403|Chirimoya burtons en lata o en frasco|O|O||D||1|Annona burtons en lata o en frasco
50362404|Chirimoya burton favorite en lata o en frasco|O|O||D||1|Annona burton favorite en lata o en frasco
50362405|Chirimoya jete en lata o en frasco|O|O||D||1|Annona jete en lata o en frasco
50362406|Chirimoya reretai en lata o en frasco|O|O||D||1|Annona reretai en lata o en frasco
50362407|Chirimoya suave en lata o en frasco|O|O||D||1|Annona suave en lata o en frasco
50362408|Chirimoya española en lata o en frasco|O|O||D||1|Annona española en lata o en frasco
50362409|Chirimoya white en lata o en frasco|O|O||D||1|Annona white en lata o en frasco
50362500|Cerezas en lata o en frasco|O|O||D||1
50362501|Cereza amarelle  en lata o en frasco|O|O||D||1
50362502|Cereza brooks en lata o en frasco|O|O||D||1
50362503|Cereza bigarreu en lata o en frasco|O|O||D||1
50362504|Cereza bing en lata o en frasco|O|O||D||1
50362505|Cereza blach republic en lata o en frasco|O|O||D||1
50362506|Cereza negra schmidt en lata o en frasco|O|O||D||1
50362507|Cereza blacktartarian en lata o en frasco|O|O||D||1
50362508|Cereza fiesta bing en lata o en frasco|O|O||D||1
50362509|Cereza garnet en lata o en frasco|O|O||D||1
50362510|Cereza king en lata o en frasco|O|O||D||1
50362511|Cereza champagne en lata o en frasco|O|O||D||1
50362512|Cereza lapin en lata o en frasco|O|O||D||1
50362513|Cereza larian en lata o en frasco|O|O||D||1
50362514|Cereza dark guines en lata o en frasco|O|O||D||1
50362515|Cereza montmorency en lata o en frasco|O|O||D||1
50362516|Cereza duque en lata o en frasco|O|O||D||1
50362517|Cereza early rivers en lata o en frasco|O|O||D||1
50362518|Cereza ruby bing en lata o en frasco|O|O||D||1
50362519|Cereza santine en lata o en frasco|O|O||D||1
50362520|Cereza geans/guines en lata o en frasco|O|O||D||1
50362521|Cereza sonata en lata o en frasco|O|O||D||1
50362522|Cereza lambert en lata o en frasco|O|O||D||1
50362523|Cereza stella en lata o en frasco|O|O||D||1
50362524|Cereza sweethart en lata o en frasco|O|O||D||1
50362525|Cereza tartarian en lata o en frasco|O|O||D||1
50362527|Cereza maraschino en lata o en frasco|O|O||D||1
50362528|Cereza van en lata o en frasco|O|O||D||1
50362529|Cereza morello en lata o en frasco|O|O||D||1
50362530|Cereza royal ann en lata o en frasco|O|O||D||1
50362531|Cereza ranier en lata o en frasco|O|O||D||1
50362532|Cereza royal en lata o en frasco|O|O||D||1
50362600|Citrones en lata o en frasco|O|O||D||1|Cidras en lata o en frasco
50362601|Citrones buddha´s hand en lata o en frasco|O|O||D||1|Cidra mano de Buda en lata o en frasco
50362602|Citrones fingered en lata o en frasco|O|O||D||1|Cidra finger red en lata o en frasco
50362603|Citrones fo shoukan en lata o en frasco|O|O||D||1|Cidra fo shoukan en lata o en frasco
50362604|Cotrones bushakan en lata o en frasco|O|O||D||1|Cidra bushakan en lata o en frasco
50362605|Citones diamante en lata o en frasco|O|O||D||1|Cidra diamante en lata o en frasco
50362606|Citrones etrog en lata o en frasco|O|O||D||1|Cidra etrog en lata o en frasco
50362607|Citrones ponderosa en lata o en frasco|O|O||D||1|Cidra ponderosa en lata o en frasco
50362700|Arándanos en lata o en frasco|O|O||D||1|Arándanos rojos en lata o en frasco
50362701|Arandano ben lear en lata o en frasco|O|O||D||1|Arándano rojo ben lear en lata o en frasco
50362702|Arandano early black en lata o en frasco|O|O||D||1|Arándano rojo early black en lata o en frasco
50362703|Arandano gryclesik en lata o en frasco|O|O||D||1|Arándano rojo gryclesik en lata o en frasco
50362704|Arandano  howe en lata o en frasco|O|O||D||1|Arándano rojo howe en lata o en frasco
50362705|Bayas lingon en lata o en frasco|O|O||D||1|Arándano rojo lingon en lata o en frasco
50362706|Arandano mcfarling en lata o en frasco|O|O||D||1|Arándano rojo mcfarling en lata o en frasco
50362707|Arandano mauntain en lata o en frasco|O|O||D||1|Arándano rojo mauntain en lata o en frasco
50362708|Arandano pilgrim en lata o en frasco|O|O||D||1|Arándano rojo pilgrim en lata o en frasco
50362709|Arandano searless en lata o en frasco|O|O||D||1|Arándano rojo searless en lata o en frasco
50362710|Arandano stevens en lata o en frasco|O|O||D||1|Arándano rojo stevens en lata o en frasco
50362800|pasas de Corinto en lata o en frasco|O|O||D||1
50362801|Pasa hudson bay en lata o en frasco|O|O||D||1|Pasa de Corinto hudson bay en lata o en frasco
50362802|Pasa cera en lata o en frasco|O|O||D||1|Pasa de Corinto cera en lata o en frasco
50362803|Pasa postre en lata o en frasco|O|O||D||1|Pasa de Corinto postre en lata o en frasco
50362804|Pasa negra en lata o en frasco|O|O||D||1|Pasa de Corinto negra en lata o en frasco
50362805|Pasa roja en lata o en frasco|O|O||D||1|Pasa de Corinto roja en lata o en frasco
50362806|Pasa blanca en lata o en frasco|O|O||D||1|Pasa de Corinto blanca en lata o en frasco
50362900|Dátiles en lata o en frasco|O|O||D||1
50362901|Dátiles asharasi  en lata o en frasco|O|O||D||1
50362902|Dátiles barhi o barhee en lata o en frasco|O|O||D||1
50362903|Dátiles deglet noor en lata o en frasco|O|O||D||1
50362904|Dátiles fardh en lata o en frasco|O|O||D||1
50362905|Dátiles gundila en lata o en frasco|O|O||D||1
50362906|Dátiles halawi/halawy en lata o en frasco|O|O||D||1
50362907|Dátiles hilali en lata o en frasco|O|O||D||1
50362908|Dátiles khadrawi/khadrawy en lata o en frasco|O|O||D||1
50362909|Dátiles khalas en lata o en frasco|O|O||D||1
50362910|Dátiles khustawi en lata o en frasco|O|O||D||1
50362911|Dátiles khidri en lata o en frasco|O|O||D||1
50362912|Dátiles medjool/ medjol en lata o en frasco|O|O||D||1
50362913|Dátiles mactoum en lata o en frasco|O|O||D||1
50362914|Dátiles neghal en lata o en frasco|O|O||D||1
50362915|Dátiles yatimeh en lata o en frasco|O|O||D||1
50362916|Dátiles zahidi en lata o en frasco|O|O||D||1
50363000|Pitahayas en lata o en frasco|O|O||D||1
50363001|Pitahaya roja, rosada en lata o en frasco|O|O||D||1
50363002|Pitahaya roja, amarillo en lata o en frasco|O|O||D||1
50363100|Brevas en lata o en frasco|O|O||D||1|Higos en lata o en frasco
50363101|Breva bardajic en lata o en frasco|O|O||D||1|Higo bardajic en lata o en frasco
50363102|Breva brown turkey en lata o en frasco|O|O||D||1|Higo brown turkey en lata o en frasco
50363103|Breva calimyma  en lata o en frasco|O|O||D||1|Higo calimyma en lata o en frasco
50363104|Breva conadria en lata o en frasco|O|O||D||1|Higo conadria en lata o en frasco
50363105|Breva dotado en lata o en frasco|O|O||D||1|Higo dotado en lata o en frasco
50363106|Breva kadota en lata o en frasco|O|O||D||1|Higo kadota en lata o en frasco
50363107|Breva mediterránea en lata o en frasco|O|O||D||1|Higo mediterránea en lata o en frasco
50363108|Breva misión en lata o en frasco|O|O||D||1|Higo misión en lata o en frasco
50363109|Breva amyma en lata o en frasco|O|O||D||1|Higo amyma en lata o en frasco
50363110|Breva verdona en lata o en frasco|O|O||D||1|Higo verdona en lata o en frasco
50363111|Breva rey blanco en lata o en frasco|O|O||D||1|Higo rey blanco en lata o en frasco
50363200|Grosellas en lata o en frasco|O|O||D||1
50363201|Grosella early sulphur en lata o en frasco|O|O||D||1
50363202|Grosella gota dorada en lata o en frasco|O|O||D||1
50363203|Grosella langley grace en lata o en frasco|O|O||D||1
50363204|Grocella leveller en lata o en frasco|O|O||D||1
50363205|Grosella london en lata o en frasco|O|O||D||1
50363206|Grosella worcestershire en lata o en frasco|O|O||D||1
50363207|Grosella americana worcesterberry en lata o en frasco|O|O||D||1
50363300|Toronjas en lata o en frasco|O|O||D||1
50363301|Toronja burgundi en lata o en frasco|O|O||D||1
50363302|Toronja duncan en lata o en frasco|O|O||D||1
50363303|Toronja foster enlatada o enfrascada|O|O||D||1
50363304|Toronja marsh en lata o en frasco|O|O||D||1
50363305|Toronja nueva zelandia en lata o en frasco|O|O||D||1
50363306|Toronja rio rojo en lata o en frasco|O|O||D||1
50363307|Toronja ruby rojo en lata o en frasco|O|O||D||1
50363308|Toronja star ruby en lata o en frasco|O|O||D||1
50363309|Toronja triumph en lata o en frasco|O|O||D||1
50363400|Uvas de mesa en lata o en frasco|O|O||D||1
50363401|Uva alicante en lata o en frasco|O|O||D||1
50363402|Uva almeira en lata o en frasco|O|O||D||1
50363403|Uva alphonse lavalle en lata o en frasco|O|O||D||1
50363404|Uva otoño rey grapes en lata o en frasco|O|O||D||1
50363405|Uva otoño real en lata o en frasco|O|O||D||1
50363406|Uva otoño sin pepa en lata o en frasco|O|O||D||1
50363407|Uva baresana en lata o en frasco|O|O||D||1
50363408|Uva barlinka en lata o en frasco|O|O||D||1
50363409|Uva belleza seedless en lata o en frasco|O|O||D||1
50363410|Uva black beauty sin pepa en lata o en frasco|O|O||D||1
50363411|Uva esmeralda negra en lata o en frasco|O|O||D||1
50363412|Uva gigante negra en lata o en frasco|O|O||D||1
50363413|Uva globo negro en lata o en frasco|O|O||D||1
50363414|Uva negra monnukka en lata o en frasco|O|O||D||1
50363415|Uva perla negra en lata o en frasco|O|O||D||1
50363416|Uva negra sin pepa en lata o en frasco|O|O||D||1
50363417|Uva bonheur en lata o en frasco|O|O||D||1
50363418|Uva calmeria en lata o en frasco|O|O||D||1
50363419|Uva cardinal en lata o en frasco|O|O||D||1
50363420|Uva catawba en lata o en frasco|O|O||D||1
50363421|Uva chasselas/golden chasselas en lata o en frasco|O|O||D||1
50363422|Uva christmas rose en lata o en frasco|O|O||D||1
50363423|Uva concord en lata o en frasco|O|O||D||1
50363424|Uva concord sin pepa en lata o en frasco|O|O||D||1
50363425|Uva crimson sin pepa en lata o en frasco|O|O||D||1
50363426|Uva dauphine  en lata o en frasco|O|O||D||1
50363427|Uva daleware en lata o en frasco|O|O||D||1
50363428|Uva early muscat en lata o en frasco|O|O||D||1
50363429|Uva early sweet en lata o en frasco|O|O||D||1
50363430|Uva esmeralda sin pepa en lata o en frasco|O|O||D||1
50363431|Uva emperatriz en lata o en frasco|O|O||D||1
50363432|Uva emperador en lata o en frasco|O|O||D||1
50363433|Uva empress en lata o en frasco|O|O||D||1
50363434|Uva exótica en lata o en frasco|O|O||D||1
50363435|Uva fantasía en lata o en frasco|O|O||D||1
50363436|Uva fantasía sin pepa en lata o en frasco|O|O||D||1
50363437|Uva llama en lata o en frasco|O|O||D||1
50363438|Uva llama sin pepa en lata o en frasco|O|O||D||1
50363439|Uva llama tokay en lata o en frasco|O|O||D||1
50363440|Uva llama red en lata o en frasco|O|O||D||1
50363441|Uva galaxy sin pepa en lata o en frasco|O|O||D||1
50363442|Uva gamay en lata o en frasco|O|O||D||1
50363443|Uva dorada en lata o en frasco|O|O||D||1
50363444|Uva haneypot o honeypot en lata o en frasco|O|O||D||1
50363445|Uva italia en lata o en frasco|O|O||D||1
50363446|Uva jade sin pepa en lata o en frasco|O|O||D||1
50363447|Uva jubilee en lata o en frasco|O|O||D||1
50363448|Uva king ruby en lata o en frasco|O|O||D||1
50363449|Uva kyoho en lata o en frasco|O|O||D||1
50363450|Uva la rochelle en lata o en frasco|O|O||D||1
50363451|Uva dedo de dama en lata o en frasco|O|O||D||1
50363452|Uva late sin pepa en lata o en frasco|O|O||D||1
50363453|Uva majestuoso sin pepa en lata o en frasco|O|O||D||1
50363454|Uva malaga en lata o en frasco|O|O||D||1
50363455|Uva marro sin pepa en lata o en frasco|O|O||D||1
50363456|Uva muscadine en lata o en frasco|O|O||D||1
50363457|Uva muscat llama en lata o en frasco|O|O||D||1
50363458|Uva muscat en lata o en frasco|O|O||D||1
50363459|Uva muscat sin papa en lata o en frasco|O|O||D||1
50363460|Uva napoleon en lata o en frasco|O|O||D||1
50363461|Uva nigeria en lata o en frasco|O|O||D||1
50363462|Uva new cross en lata o en frasco|O|O||D||1
50363463|Uva nibella en lata o en frasco|O|O||D||1
50363464|Uva niagara en lata o en frasco|O|O||D||1
50363465|Uva olivette en lata o en frasco|O|O||D||1
50363466|Uva perlette en lata o en frasco|O|O||D||1
50363467|Uva perlon en lata o en frasco|O|O||D||1
50363468|Uva prima negra sin pepa en lata o en frasco|O|O||D||1
50363469|Uva princesa en lata o en frasco|O|O||D||1
50363470|Uva reina en lata o en frasco|O|O||D||1
50363471|Uva roja blush en lata o en frasco|O|O||D||1
50363472|Uva roja globo en lata o en frasco|O|O||D||1
50363473|Uva roja malaga en lata o en frasco|O|O||D||1
50363474|Uva roja sin pepa en lata o en frasco|O|O||D||1
50363475|Uva regina en lata o en frasco|O|O||D||1
50363476|Uva ribier en lata o en frasco|O|O||D||1
50363477|Uva rosita en lata o en frasco|O|O||D||1
50363478|Uva rouge en lata o en frasco|O|O||D||1
50363479|Uva royal negra sin pepa en lata o en frasco|O|O||D||1
50363480|Uva ruby roja sin pepa en lata o en frasco|O|O||D||1
50363481|Uva ruby sin pepa en lata o en frasco|O|O||D||1
50363482|Uva scarlet royal en lata o en frasco|O|O||D||1
50363483|Uva scuppemong en lata o en frasco|O|O||D||1
50363484|Uva sugarose en lata o en frasco|O|O||D||1
50363485|Uva sugartirteen en lata o en frasco|O|O||D||1
50363486|Uva sugraone en lata o en frasco|O|O||D||1
50363487|Uva sugrasixteen en lata o en frasco|O|O||D||1
50363488|Uva sultana sun roja en lata o en frasco|O|O||D||1
50363489|Uva verano royal en lata o en frasco|O|O||D||1
50363490|Uva atardecer en lata o en frasco|O|O||D||1
50363491|Uva superior sin pepa en lata o en frasco|O|O||D||1
50363492|Uva thompson sin pepa en lata o en frasco|O|O||D||1
50363493|Uva tokaylpinot gris en lata o en frasco|O|O||D||1
50363494|Uva waltman cross en lata o en frasco|O|O||D||1
50363495|Uva blanca sin pepa en lata o en frasco|O|O||D||1
50363496|Uva zante current en lata o en frasco|O|O||D||1
50363500|Uvas pasas en lata o en frasco|O|O||D||1
50363501|Uva corinth negra en lata o en frasco|O|O||D||1
50363502|Uva canner en lata o en frasco|O|O||D||1
50363503|Uva dovine en lata o en frasco|O|O||D||1
50363504|Uva fiesta en lata o en frasco|O|O||D||1
50363505|Uva selme pete en lata o en frasco|O|O||D||1
50363506|Uva sultana en lata o en frasco|O|O||D||1
50363600|Uvas para vino en lata o en frasco|O|O||D||1
50363601|Uva alicante bouschet en lata o en frasco|O|O||D||1
50363602|Uva barbera en lata o en frasco|O|O||D||1
50363603|Uva burger en lata o en frasco|O|O||D||1
50363604|Uva cabemet franc en lata o en frasco|O|O||D||1
50363605|Uva cabenet sauvignon en lata o en frasco|O|O||D||1
50363606|Uva carignane en lata o en frasco|O|O||D||1
50363607|Uva camelian en lata o en frasco|O|O||D||1
50363608|Uva cattarrato en lata o en frasco|O|O||D||1
50363609|Uva centurian en lata o en frasco|O|O||D||1
50363610|Uva charbono en lata o en frasco|O|O||D||1
50363611|Uva chardonnay en lata o en frasco|O|O||D||1
50363612|Uva chenin blanco en lata o en frasco|O|O||D||1
50363613|Uva cinsaut en lata o en frasco|O|O||D||1
50363614|Uva dolcetto en lata o en frasco|O|O||D||1
50363615|Uva emerald riesling en lata o en frasco|O|O||D||1
50363616|Uva frances colombard en lata o en frasco|O|O||D||1
50363617|Uva granny nap en lata o en frasco|O|O||D||1
50363618|Uva gamay beaujolais en lata o en frasco|O|O||D||1
50363619|Uva gewurztraminer en lata o en frasco|O|O||D||1
50363620|Uva grnache en lata o en frasco|O|O||D||1
50363621|Uva grinache blanc en lata o en frasco|O|O||D||1
50363622|Uva lagrein en lata o en frasco|O|O||D||1
50363623|Uva lambruso en lata o en frasco|O|O||D||1
50363624|Uva malbec en lata o en frasco|O|O||D||1
50363625|Uva malvasía bianca en lata o en frasco|O|O||D||1
50363626|Uva marsanne en lata o en frasco|O|O||D||1
50363627|Uva matano en lata o en frasco|O|O||D||1
50363628|Uva merlot en lata o en frasco|O|O||D||1
50363629|Uva meunier en lata o en frasco|O|O||D||1
50363630|Uva missiom en lata o en frasco|O|O||D||1
50363631|Uva montepulceano en lata o en frasco|O|O||D||1
50363632|Uva muscat blanc en lata o en frasco|O|O||D||1
50363633|Uva muscat hamburg en lata o en frasco|O|O||D||1
50363634|Uva muscat alexandria en lata o en frasco|O|O||D||1
50363635|Uva muscat naranja en lata o en frasco|O|O||D||1
50363636|Uva nebbiolo en lata o en frasco|O|O||D||1
50363637|Uva palomino en lata o en frasco|O|O||D||1
50363638|Uva petit verdor en lata o en frasco|O|O||D||1
50363639|Uva petit sirah en lata o en frasco|O|O||D||1
50363640|Uva pinot blanc en lata o en frasco|O|O||D||1
50363641|Uva pinot gris en lata o en frasco|O|O||D||1
50363642|Uva pinot noir en lata o en frasco|O|O||D||1
50363643|Uva primitivo en lata o en frasco|O|O||D||1
50363644|Uva roussane en lata o en frasco|O|O||D||1
50363645|Uva real  en lata o en frasco|O|O||D||1
50363646|Uva rubired en lata o en frasco|O|O||D||1
50363647|Uva ruby cabenet en lata o en frasco|O|O||D||1
50363648|Uva salvador en lata o en frasco|O|O||D||1
50363649|Uva sangiovese en lata o en frasco|O|O||D||1
50363650|Uva sauvignon blanc en lata o en frasco|O|O||D||1
50363651|Uva sauvignon musque en lata o en frasco|O|O||D||1
50363652|Uva semillon en lata o en frasco|O|O||D||1
50363653|Uva souzao en lata o en frasco|O|O||D||1
50363654|Uva st emilion en lata o en frasco|O|O||D||1
50363655|Uva symohony en lata o en frasco|O|O||D||1
50363656|Uva syrah  en lata o en frasco|O|O||D||1
50363657|Uva tannat en lata o en frasco|O|O||D||1
50363658|Uva tempranillo en lata o en frasco|O|O||D||1
50363659|Uvas teroldego en lata o en frasco|O|O||D||1
50363660|Uvas tocai friulano en lata o en frasco|O|O||D||1
50363661|Uvas touriga nacional en lata o en frasco|O|O||D||1
50363662|Uvas triplett blanc en lata o en frasco|O|O||D||1
50363663|Uvas viogner en lata o en frasco|O|O||D||1
50363664|Uvas white riesling en lata o en frasco|O|O||D||1
50363665|Uvas zinfandel en lata o en frasco|O|O||D||1
50363700|Guayabas en lata o en frasco|O|O||D||1
50363701|Guayabas beaumont en lata o en frasco|O|O||D||1
50363702|Guayabas carrley en lata o en frasco|O|O||D||1
50363703|Guayabas lucida en lata o en frasco|O|O||D||1
50363704|Guayaba piña en lata o en frasco|O|O||D||1
50363800|Arándanos Huckleberry en lata o en frasco|O|O||D||1|Arándanos azules en lata o en frasco
50363801|Arándano invierno negro en lata o en frasco|O|O||D||1|Arándano azul invierno negro en lata o en frasco
50363802|Arándano cascada en lata o en frasco|O|O||D||1|Arándano azul cascada en lata o en frasco
50363803|Arándano enano en lata o en frasco|O|O||D||1|Arándano azul enano en lata o en frasco
50363804|Arándano montaña en lata o en frasco|O|O||D||1|Arándano azul montaña en lata o en frasco
50363805|Arándano rojo en lata o en frasco|O|O||D||1|Arándano azul red en lata o en frasco
50363900|Kiwis en lata o en frasco|O|O||D||1
50363901|Fruta de kiwi ananasnaja en lata o en frasco|O|O||D||1|Kiwi ananasnaja en lata o en frasco
50363902|Fruta de kiwi belleza del ártico en lata o en frasco|O|O||D||1|Kiwi belleza del ártico en lata o en frasco
50363903|Fruta de kiwi blake en lata o en frasco|O|O||D||1|Kiwi blake en lata o en frasco
50363904|Fruta de kiwi hayward en lata o en frasco|O|O||D||1|Kiwi hayward en lata o en frasco
50363905|Fruta de kiwi issai en lata o en frasco|O|O||D||1|Kiwi issai en lata o en frasco
50363906|Fruta de kiwi siberiana en lata o en frasco|O|O||D||1|Kiwi siberiano en lata o en frasco
50364000|Naranjos Chinos (kumquats) en lata o en frasco|O|O||D||1
50364001|Naranjo chino hong kong en lata o en frasco|O|O||D||1
50364002|Naranjo chino limequat en lata o en frasco|O|O||D||1
50364003|Naranjo long fruit en lata o en frasco|O|O||D||1|Naranjo chino long fruit en lata o en frasco
50364004|Naranjo chino malayan en lata o en frasco|O|O||D||1
50364005|Naranjo meiwa en lata o en frasco|O|O||D||1|Naranjo chino meiwa en lata o en frasco
50364006|Naranja chino nagami en lata o en frasco|O|O||D||1|Naranjo chino nagami en lata o en frasco
50364100|Limones en lata o en frasco|O|O||D||1
50364101|Limón baboon en lata o en frasco|O|O||D||1
50364102|Limón bearss sicilian en lata o en frasco|O|O||D||1
50364103|Limón cameron highland en lata o en frasco|O|O||D||1
50364104|Limón escondido en lata o en frasco|O|O||D||1
50364105|Limón eureka en lata o en frasco|O|O||D||1
50364106|Limón lisbon en lata o en frasco|O|O||D||1
50364107|Limón meyer en lata o en frasco|O|O||D||1
50364108|Limón volkaner en lata o en frasco|O|O||D||1
50364200|Limas en lata o en frasco|O|O||D||1
50364201|Lima limón indian sweet en lata o en frasco|O|O||D||1
50364202|Lima limón en lata o en frasco|O|O||D||1
50364203|Lima limón mandarin en lata o en frasco|O|O||D||1
50364204|Lima limón philippine en lata o en frasco|O|O||D||1
50364205|Lima limón tahitian en lata o en frasco|O|O||D||1
50364206|Lima limón bearss en lata o en frasco|O|O||D||1
50364207|Lima limón persa en lata o en frasco|O|O||D||1
50364208|Lima limón sin pepas en lata o en frasco|O|O||D||1|Lima limón sin semillas en lata o en frasco
50364300|Nísperos en lata o en frasco|O|O||D||1
50364301|Níspero advance en lata o en frasco|O|O||D||1
50364302|Níspero benlehr en lata o en frasco|O|O||D||1
50364303|Níspero big jim en lata o en frasco|O|O||D||1
50364304|Níspero champagne en lata o en frasco|O|O||D||1
50364305|Níspero early rojo en lata o en frasco|O|O||D||1
50364306|Níspero nuget dorado en lata o en frasco|O|O||D||1
50364307|Níspero herd´s mammoth en lata o en frasco|O|O||D||1
50364308|Níspero mogi en lata o en frasco|O|O||D||1
50364309|Níspero mrs cooksey en lata o en frasco|O|O||D||1
50364310|Níspero fresa en lata o en frasco|O|O||D||1
50364311|Níspero tanaka en lata o en frasco|O|O||D||1
50364312|Níspero victoria vista blanco en lata o en frasco|O|O||D||1
50364313|Níspero wolfe en lata o en frasco|O|O||D||1
50364400|Mandarinas en lata o en frasco|O|O||D||1
50364401|Naranjas clauselinas en lata o en frasco|O|O||D||1
50364402|Mandarinas clementinas en lata o en frasco|O|O||D||1
50364403|Naranja mandarina cleopatra|O|O||D||1
50364404|Mandarina dancy en lata o en frasco|O|O||D||1
50364405|Naranja ellensday en lata o en frasco|O|O||D||1
50364406|Naranja fairchild en lata o en frasco|O|O||D||1
50364407|Naranja fallglo en lata o en frasco|O|O||D||1
50364408|Naranja fortuna en lata o en frasco|O|O||D||1
50364409|Mandarina naranja fremont en lata o en frasco|O|O||D||1
50364410|Naranja fremont en lata o en frasco|O|O||D||1
50364411|Naranja nuget dorada en lata o en frasco|O|O||D||1
50364412|Mandarina naranja miel en lata o en frasco|O|O||D||1
50364413|Naranja miel en lata o en frasco|O|O||D||1
50364414|Mandarina miel en lata o en frasco|O|O||D||1
50364415|Natanja tanjelo honebelle en lata o en frasco|O|O||D||1|Naranja tangelo honebelle en lata o en frasco
50364416|Naranja mandarina rey en lata o en frasco|O|O||D||1
50364417|Naranja kinnow en lata o en frasco|O|O||D||1
50364418|Naranja andarinalee en lata o en frasco|O|O||D||1
50364419|Naranja makokkee en lata o en frasco|O|O||D||1
50364420|Naranja malvasion en lata o en frasco|O|O||D||1
50364421|Naranja mandarina mediterránea en lata o en frasco|O|O||D||1
50364422|Naranja tangelo minneola en lata o en frasco|O|O||D||1
50364423|Naranja monica en lata o en frasco|O|O||D||1
50364424|Naranja murcott miel en lata o en frasco|O|O||D||1
50364425|Naranja murcott tangors en lata o en frasco|O|O||D||1
50364426|Naranja mandarina natsudaidai  en lata o en frasco|O|O||D||1
50364427|Naranja mandarina natsumikan en lata o en frasco|O|O||D||1
50364428|Naranja tanjelo nocatee en lata o en frasco|O|O||D||1
50364429|Naranja tanjelo orlando en lata o en frasco|O|O||D||1
50364430|Mandarina ortanique en lata o en frasco|O|O||D||1
50364431|Naranja mandarina pagina en lata o en frasco|O|O||D||1
50364432|Naranja pixie en lata o en frasco|O|O||D||1
50364433|Naranja mandarina ponkan bantangas en lata o en frasco|O|O||D||1
50364434|Naranja reina en lata o en frasco|O|O||D||1
50364435|Naranja robinson en lata o en frasco|O|O||D||1
50364436|Naranja saltenitas en lata o en frasco|O|O||D||1
50364437|Naranja tangelo sampson en lata o en frasco|O|O||D||1
50364438|Naranja mandarina satsuma en lata o en frasco|O|O||D||1
50364439|Naranja mandarina sunburst en lata o en frasco|O|O||D||1
50364440|Tangelo en lata o en frasco|O|O||D||1
50364441|Naranja mandarina en lata o en frasco|O|O||D||1
50364442|Naranja templo en lata o en frasco|O|O||D||1
50364443|Naranja thornton en lata o en frasco|O|O||D||1
50364444|Mandarina wekiwa en lata o en frasco|O|O||D||1
50364445|Mandarina wilkins en lata o en frasco|O|O||D||1
50364446|Mandarina willowleaf mediterránea en lata o en frasco|O|O||D||1
50364500|Mangos en lata o en frasco|O|O||D||1
50364501|Mango alphonso en lata o en frasco|O|O||D||1
50364502|Mango ataulfo en lata o en frasco|O|O||D||1
50364503|Mango criollo en lata o en frasco|O|O||D||1
50364504|Mango edwards en lata o en frasco|O|O||D||1
50364505|Mango francine en lata o en frasco|O|O||D||1
50364506|Mango francis en lata o en frasco|O|O||D||1
50364507|Mango gandaria en lata o en frasco|O|O||D||1
50364508|Mango haden en lata o en frasco|O|O||D||1
50364509|Mangos irwin en lata o en frasco|O|O||D||1
50364510|Mangos keitt en lata o en frasco|O|O||D||1
50364511|Mangos kent en lata o en frasco|O|O||D||1
50364512|Mangos kesar en lata o en frasco|O|O||D||1
50364513|Mangos kuini en lata o en frasco|O|O||D||1
50364514|Mangos manila super en lata o en frasco|O|O||D||1
50364515|Mangos manila en lata o en frasco|O|O||D||1
50364516|Mangos mayaguez en lata o en frasco|O|O||D||1
50364517|Mangos mulgoba en lata o en frasco|O|O||D||1
50364518|Mangos oro en lata o en frasco|O|O||D||1
50364519|Mangos palmer en lata o en frasco|O|O||D||1
50364520|Mango parvin en lata o en frasco|O|O||D||1
50364521|Mango sandersha en lata o en frasco|O|O||D||1
50364522|Mangos sensation en lata o en frasco|O|O||D||1
50364523|Mango smith en lata o en frasco|O|O||D||1
50364524|Mango tomy atkin en lata o en frasco|O|O||D||1
50364525|Mango van dyke en lata o en frasco|O|O||D||1
50364600|Melones en lata o en frasco|O|O||D||1
50364601|Melon  todo dulce en lata o en frasco|O|O||D||1
50364602|Melón athens en lata o en frasco|O|O||D||1
50364603|Melón diamante negro en lata o en frasco|O|O||D||1
50364604|Melón cal dulce en lata o en frasco|O|O||D||1
50364605|Melons cantaloupe en lata o en frasco|O|O||D||1
50364606|Melón carnical en lata o en frasco|O|O||D||1
50364607|Melón casaba en lata o en frasco|O|O||D||1
50364608|Melón cavaillon en lata o en frasco|O|O||D||1
50364609|Melón charentais en lata o en frasco|O|O||D||1
50364610|Sandia charleston gray en lata o en frasco|O|O||D||1
50364611|Melón crenshaw en lata o en frasco|O|O||D||1
50364612|Melón crimson sweet en lata o en frasco|O|O||D||1
50364613|Melón dixie lee en lata o en frasco|O|O||D||1
50364614|Melón eclipse en lata o en frasco|O|O||D||1
50364615|Melón ein dór  en lata o en frasco|O|O||D||1
50364616|Melón fiesta en lata o en frasco|O|O||D||1
50364617|Melón galia en lata o en frasco|O|O||D||1
50364618|Melón gaya en lata o en frasco|O|O||D||1
50364619|Melón hami en lata o en frasco|O|O||D||1
50364620|Melón miel dew en lata o en frasco|O|O||D||1
50364621|Melón hielo en lata o en frasco|O|O||D||1
50364622|Melón ida orgullo en lata o en frasco|O|O||D||1
50364623|Melón juan canary en lata o en frasco|O|O||D||1
50364624|Melón jubileo en lata o en frasco|O|O||D||1
50364625|Melón jubilación en lata o en frasco|O|O||D||1
50364626|Melón kaki / kakri en lata o en frasco|O|O||D||1
50364627|Melón kiwano en lata o en frasco|O|O||D||1
50364628|Melon koreano en lata o en frasco|O|O||D||1|Melón coreano en lata o en frasco
50364629|Melóngris largo grey en lata o en frasco|O|O||D||1|Melón largo gris en lata o en frasco
50364630|Melón mayan en lata o en frasco|O|O||D||1
50364631|Melón micky lee en lata o en frasco|O|O||D||1
50364632|Melón mirage en lata o en frasco|O|O||D||1
50364633|Sandia luna y estrellas en lata o en frasco|O|O||D||1
50364634|Melón ogen en lata o en frasco|O|O||D||1
50364635|Melón patriota en lata o en frasco|O|O||D||1
50364636|Melón pavo real en lata o en frasco|O|O||D||1
50364637|Melón pepino en lata o en frasco|O|O||D||1
50364638|Melón persa en lata o en frasco|O|O||D||1
50364639|Melón picnic en lata o en frasco|O|O||D||1
50364640|Melón piel de sapo en lata o en frasco|O|O||D||1
50364641|Melón piña en lata o en frasco|O|O||D||1
50364642|Melón quetzali en lata o en frasco|O|O||D||1
50364643|Melón goblin rojo en lata o en frasco|O|O||D||1
50364644|Melón regency en lata o en frasco|O|O||D||1
50364645|Melón royal mejestic en lata o en frasco|O|O||D||1
50364646|Melón royal star en lata o en frasco|O|O||D||1
50364647|Melón dulce royal en lata o en frasco|O|O||D||1
50364648|Malon santa claus en lata o en frasco|O|O||D||1|Melón piel de sapo en lata o en frasco, Melón santa claus en lata o en frasco
50364649|Melón sharlyn en lata o en frasco|O|O||D||1
50364650|Melón español en lata o en frasco|O|O||D||1
50364651|Melón sprite en lata o en frasco|O|O||D||1
50364652|Melón starbright en lata o en frasco|O|O||D||1
50364653|Melón stars and stripes en lata o en frasco|O|O||D||1
50364654|Melón bebe de azúcar en lata o en frasco|O|O||D||1
50364655|Sandia bebe de azúcar en lata o en frasco|O|O||D||1
50364656|Melón dulce sol en lata o en frasco|O|O||D||1
50364657|Sandia corazón dulce sin pepa en lata o en frasco|O|O||D||1
50364658|Melón tentación en lata o en frasco|O|O||D||1
50364659|Melón tigre bebe en lata o en frasco|O|O||D||1
50364660|Melón tuscan tipo en lata o en frasco|O|O||D||1
50364661|Sandia bebe amarillo en lata o en frasco|O|O||D||1
50364700|Moras mulberry en lata o en frasco|O|O||D||1|Zarzamoras mulberry en lata o en frasco
50364701|Mora negra en lata o en frasco|O|O||D||1|Zarzamora negra en lata o en frasco
50364702|Mora blanca en lata o en frasco|O|O||D||1|Zarzamora blanca en lata o en frasco
50364800|Mirtos en lata o en frasco|O|O||D||1|Arrayanes en lata o en frasco
50364801|Mirto bog en lata o en frasco|O|O||D||1|Arrayán bog en lata o en frasco
50364900|Nectarinas en lata o en frasco|O|O||D||1
50364901|Durazno abril glo en lata o en frasco|O|O||D||1
50364902|Durazno arctic mist en lata o en frasco|O|O||D||1
50364903|Durazno artic snow en lata o en frasco|O|O||D||1
50364904|Durazno artic star en lata o en frasco|O|O||D||1
50364905|Durazno artic dulce en lata o en frasco|O|O||D||1
50364906|Durazno artic glo en lata o en frasco|O|O||D||1
50364907|Durazno fuego de agosto en lata o en frasco|O|O||D||1
50364908|Durazno  perla de agosto en lata o en frasco|O|O||D||1
50364909|Durazno agosto rojo en lata o en frasco|O|O||D||1
50364910|Durazno estrella de agosto en lata o en frasco|O|O||D||1
50364911|Durazno grande john en lata o en frasco|O|O||D||1
50364912|Durazno perla brillante en lata o en frasco|O|O||D||1
50364913|Durazno diamante brillante en lata o en frasco|O|O||D||1
50364914|Durazno diamante rayo en lata o en frasco|O|O||D||1
50364915|Durazno earligo en lata o en frasco|O|O||D||1
50364916|Durazno diamante temprano en lata o en frasco|O|O||D||1
50364917|Durazno fairlane en lata o en frasco|O|O||D||1
50364918|Durazno fantasia en lata o en frasco|O|O||D||1
50364919|Durazno perla fuego en lata o en frasco|O|O||D||1
50364920|Durazno fuego dulce en lata o en frasco|O|O||D||1
50364921|Durazno flamekist en lata o en frasco|O|O||D||1
50364922|Durazno tipo plano en lata o en frasco|O|O||D||1
50364923|Durazno delicia de jardín en lata o en frasco|O|O||D||1
50364924|Durazno mina de oro en lata o en frasco|O|O||D||1
50364925|Durazno perla grande en lata o en frasco|O|O||D||1
50364926|Durazno hardired en lata o en frasco|O|O||D||1
50364927|Durazno miel de fuego en lata o en frasco|O|O||D||1
50364928|Durazno julio rojo en lata o en frasco|O|O||D||1
50364929|Durazno kay perla en lata o en frasco|O|O||D||1
50364930|Durazno key dulce en lata o en frasco|O|O||D||1
50364931|Durazno diamante mayo en lata o en frasco|O|O||D||1
50364932|Durazno mayfire en lata o en frasco|O|O||D||1
50364933|Durazno mayglo en lata o en frasco|O|O||D||1
50364934|Durazno mericrest en lata o en frasco|O|O||D||1
50364935|Durazno diamante rojo en lata o en frasco|O|O||D||1
50364936|Durazno oro rojo en lata o en frasco|O|O||D||1
50364937|Durazno jim rojo en lata o en frasco|O|O||D||1
50364938|Durazno roy rojo en lata o en frasco|O|O||D||1
50364939|Durazno rio rojo en lata o en frasco|O|O||D||1
50364940|Durazno diamante de rosa en lata o en frasco|O|O||D||1
50364941|Durazno rotal glo en lata o en frasco|O|O||D||1
50364942|Durazno diamante ryby en lata o en frasco|O|O||D||1
50364943|Durazno ruby dulce en lata o en frasco|O|O||D||1
50364944|Durazno joya ruddy en lata o en frasco|O|O||D||1
50364945|Durazno septiembre rojo en lata o en frasco|O|O||D||1
50364946|Durazno reina de nieve en lata o en frasco|O|O||D||1
50364947|Durazno primavera clara en lata o en frasco|O|O||D||1
50364948|Durazno primavera roja en lata o en frasco|O|O||D||1
50364949|Durazno verano rojiso en lata o en frasco|O|O||D||1
50364950|Durazno verano claro en lata o en frasco|O|O||D||1
50364951|Durazno verano diamante en lata o en frasco|O|O||D||1
50364952|Durazno verano fuego en lata o en frasco|O|O||D||1
50364953|Durazno verano grande en lata o en frasco|O|O||D||1
50364954|Durazno sunglo en lata o en frasco|O|O||D||1
50364955|Durazno fuego zee en lata o en frasco|O|O||D||1
50364956|Durazno zee glo en lata o en frasco|O|O||D||1
50364957|Durazno zeegrand en lata o en frasco|O|O||D||1
50365000|Naranjas en lata o en frasco|O|O||D||1
50365001|Naranja áfrica agria en lata o en frasco|O|O||D||1
50365002|Naranja dulce amber en lata o en frasco|O|O||D||1
50365003|Naranja argentina agria en lata o en frasco|O|O||D||1
50365004|Naranja bahianinha en lata o en frasco|O|O||D||1
50365005|Naranja bergamot en lata o en frasco|O|O||D||1
50365006|Naranja berna en lata o en frasco|O|O||D||1
50365007|Naranja bigaradier apepu en lata o en frasco|O|O||D||1
50365008|Naranja agria dulce daidai en lata o en frasco|O|O||D||1
50365009|Naranja mono en lata o en frasco|O|O||D||1
50365010|Naranja sangre en lata o en frasco|O|O||D||1
50365011|Naranja california navel en lata o en frasco|O|O||D||1
50365012|Naranja cara cara en lata o en frasco|O|O||D||1
50365013|Naranja chinotto en lata o en frasco|O|O||D||1
50365014|Naranja sueño nevel en lata o en frasco|O|O||D||1
50365015|Naranja gou tou en lata o en frasco|O|O||D||1
50365016|Naranja hamlin en lata o en frasco|O|O||D||1
50365017|Naranja jaffa en lata o en frasco|O|O||D||1
50365018|Naranja jincheng en lata o en frasco|O|O||D||1
50365019|Naranja k-temprano en lata o en frasco|O|O||D||1
50365020|Naranja kona en lata o en frasco|O|O||D||1
50365021|Naranja navel tarde en lata o en frasco en lata o en frasco|O|O||D||1
50365022|Naranja valencia tarde en lata o en frasco|O|O||D||1
50365023|Naranja limequat en lata o en frasco|O|O||D||1
50365024|Naranja mar en lata o en frasco|O|O||D||1
50365025|Naranja malegold en lata o en frasco|O|O||D||1
50365026|Naranja moro en lata o en frasco|O|O||D||1
50365027|Naranja moro tabaco en lata o en frasco|O|O||D||1
50365028|Naranja navel en lata o en frasco|O|O||D||1
50365029|Naranja navelina en lata o en frasco|O|O||D||1
50365030|Naranja oro blanco en lata o en frasco|O|O||D||1
50365031|Naranja osceola en lata o en frasco|O|O||D||1
50365032|Naranja parson carmelito en lata o en frasco|O|O||D||1
50365033|Naranja pera en lata o en frasco|O|O||D||1
50365034|Naranjo pummulo en lata o en frasco|O|O||D||1|Naranja pummulo en lata o en frasco
50365035|Naranja rhode rojo en lata o en frasco|O|O||D||1
50365036|Naranja roble en lata o en frasco|O|O||D||1
50365037|Naranja salustianas en lata o en frasco|O|O||D||1
50365038|Naranja sanguine en lata o en frasco|O|O||D||1
50365039|Naranja sanguinelli en lata o en frasco|O|O||D||1
50365040|Naranja cevilla en lata o en frasco|O|O||D||1
50365041|Naranja shamouti jaffa en lata o en frasco|O|O||D||1
50365042|Naranja tunis en lata o en frasco|O|O||D||1
50365043|Naranja valencia en lata o en frasco|O|O||D||1
50365044|Naranja washington navel en lata o en frasco|O|O||D||1
50365100|Papayas en lata o en frasco|O|O||D||1
50365101|Papaya verde cocinar en lata o en frasco|O|O||D||1
50365102|Papaya maradol en lata o en frasco|O|O||D||1
50365103|Papaya amarillo mexicano en lata o en frasco|O|O||D||1
50365104|Papaya montaña en lata o en frasco|O|O||D||1
50365105|Papaya solo en lata o en frasco|O|O||D||1
50365106|Papaya tainung en lata o en frasco|O|O||D||1
50365200|Maracuyás en lata o en frasco|O|O||D||1
50365201|Maracuyá banana en lata o en frasco|O|O||D||1|Curuba en lata o en frasco
50365202|Maracuyá flor azul en lata o en frasco|O|O||D||1|Maracuyá pasionaria azul en lata o en frasco
50365203|Maracuyá crackerjack en lata o en frasco|O|O||D||1
50365204|Maracuyá granadilla gigante en lata o en frasco|O|O||D||1
50365205|Maracuyá granadilla dorada en lata o en frasco|O|O||D||1
50365206|Maracuyá maypops en lata o en frasco|O|O||D||1
50365207|Maracuyá roja en lata o en frasco|O|O||D||1
50365208|Maracuyá granadilla dulce en lata o en frasco|O|O||D||1
50365209|Maracuyá sandia en lata o en frasco|O|O||D||1
50365210|Maracuyá  wing- steam en lata o en frasco|O|O||D||1
50365300|Duraznos en lata o en frasco|O|O||D||1
50365301|Durazno escudo amber en lata o en frasco|O|O||D||1
50365302|Durazno nieve de abril en lata o en frasco|O|O||D||1
50365303|Durazno dama de agosto en lata o en frasco|O|O||D||1
50365304|Durazno llama de otoño en lata o en frasco|O|O||D||1
50365305|Durazno dama de otoño en lata o en frasco|O|O||D||1
50365306|Durazno babcock en lata o en frasco|O|O||D||1
50365307|Durazno brittany lane en lata o en frasco|O|O||D||1
50365308|Durazno cary mac en lata o en frasco|O|O||D||1
50365309|Durazno clásica en lata o en frasco|O|O||D||1
50365310|Durazno dulce del campo en lata o en frasco|O|O||D||1
50365311|Durazno escudo de cielo en lata o en frasco|O|O||D||1
50365312|Durazno dama crimson en lata o en frasco|O|O||D||1
50365313|Durazno príncipe corona en lata o en frasco|O|O||D||1
50365314|Durazno sol david en lata o en frasco|O|O||D||1
50365315|Durazno  princesa diamante en lata o en frasco|O|O||D||1
50365316|Durazno earlrich en lata o en frasco|O|O||D||1
50365317|Durazno majestuosa temprana en lata o en frasco|O|O||D||1
50365318|Durazno early treat en lata o en frasco|O|O||D||1
50365319|Durazno dama elegante en lata o en frasco|O|O||D||1
50365320|Durazno emperatriz en lata o en frasco|O|O||D||1
50365321|Durazno encoré en lata o en frasco|O|O||D||1
50365322|Durazno dama elegante en lata o en frasco|O|O||D||1
50365323|Durazno príncipe de fuego en lata o en frasco|O|O||D||1
50365324|Durazno escudo de llama en lata o en frasco|O|O||D||1
50365325|Durazno tipo plano en lata o en frasco|O|O||D||1
50365326|Durazno escudo de sabor en lata o en frasco|O|O||D||1
50365327|Durazno príncipe florida en lata o en frasco|O|O||D||1
50365328|Durazno luna llena en lata o en frasco|O|O||D||1
50365329|Durazno harvester en lata o en frasco|O|O||D||1
50365330|Durazno princesa de hielo en lata o en frasco|O|O||D||1
50365331|Durazno princesa de marfil en lata o en frasco|O|O||D||1
50365332|Durazno princesa reina jersey en lata o en frasco|O|O||D||1
50365333|Durazno john henry en lata o en frasco|O|O||D||1
50365334|Durazno príncipe de junio en lata o en frasco|O|O||D||1
50365335|Durazno kaweah en lata o en frasco|O|O||D||1
50365336|Durazno klondike en lata o en frasco|O|O||D||1
50365337|Durazno lindo en lata o en frasco|O|O||D||1
50365338|Durazno loring en lata o en frasco|O|O||D||1
50365339|Durazno majestuoso en lata o en frasco|O|O||D||1
50365340|Durazno o’henry en lata o en frasco|O|O||D||1
50365341|Durazno escudo de reina en lata o en frasco|O|O||D||1
50365342|Durazno dama roja en lata o en frasco|O|O||D||1
50365343|Durazno globo rojo en lata o en frasco|O|O||D||1
50365344|Durazno cielo rojo en lata o en frasco|O|O||D||1
50365345|Durazno redtop en lata o en frasco|O|O||D||1
50365346|Durazno regina en lata o en frasco|O|O||D||1
50365347|Durazno dama rica en lata o en frasco|O|O||D||1
50365348|Durazno mayo rico en lata o en frasco|O|O||D||1
50365349|Durazno gloria royal en lata o en frasco|O|O||D||1
50365350|Durazno dama royal en lata o en frasco|O|O||D||1
50365351|Durazno nieve de septiembre en lata o en frasco|O|O||D||1
50365352|Durazno sol de septiembre en lata o en frasco|O|O||D||1
50365353|Durazno gema sierra en lata o en frasco|O|O||D||1
50365354|Durazno angel de nieve en lata o en frasco|O|O||D||1
50365355|Durazno gema de nieve en lata o en frasco|O|O||D||1
50365356|Durazno rey de nieve en lata o en frasco|O|O||D||1
50365357|Durazno dama de primavera en lata o en frasco|O|O||D||1
50365358|Durazno nieve de primavera en lata o en frasco|O|O||D||1
50365359|Durazno escudo de primavera en lata o en frasco|O|O||D||1
50365360|Durazno dulce gigante en lata o en frasco|O|O||D||1
50365361|Durazno dama de azúcar en lata o en frasco|O|O||D||1
50365362|Durazno brillo de sol en lata o en frasco|O|O||D||1
50365363|Durazno sunhigh en lata o en frasco|O|O||D||1
50365364|Durazno dama super en lata o en frasco|O|O||D||1
50365365|Durazno super rico en lata o en frasco|O|O||D||1
50365366|Durazno surecrop en lata o en frasco|O|O||D||1
50365367|Durazno sueño dulce en lata o en frasco|O|O||D||1
50365368|Durazno septiembre dulce en lata o en frasco|O|O||D||1
50365369|Durazno vista en lata o en frasco|O|O||D||1
50365370|Durazno dama blanca en lata o en frasco|O|O||D||1
50365371|Durazno dama zee en lata o en frasco|O|O||D||1
50365400|Peras en lata o en frasco|O|O||D||1
50365401|Peras abate fetel en lata o en frasco|O|O||D||1
50365402|Peras anjou en lata o en frasco|O|O||D||1
50365403|Pera asiática en lata o en frasco|O|O||D||1
50365404|Pera bartlett en lata o en frasco|O|O||D||1
50365405|Pera best ever en lata o en frasco|O|O||D||1
50365406|Pera beth en lata o en frasco|O|O||D||1
50365407|Pera beurre en lata o en frasco|O|O||D||1
50365408|Pera bosc en lata o en frasco|O|O||D||1
50365409|Pera clapp favorita en lata o en frasco|O|O||D||1
50365410|Pera comice en lata o en frasco|O|O||D||1
50365411|Pera concorde en lata o en frasco|O|O||D||1
50365412|Pera conference en lata o en frasco|O|O||D||1
50365413|Pera crimson rojo en lata o en frasco|O|O||D||1
50365414|Peras d’ anjou en lata o en frasco|O|O||D||1
50365415|Pera dr jules guyot en lata o en frasco|O|O||D||1
50365416|Peras early en lata o en frasco|O|O||D||1
50365417|Peras emperador carmelito en lata o en frasco|O|O||D||1
50365418|Peras forelle en lata o en frasco|O|O||D||1
50365419|Pera mantequilla francesa en lata o en frasco|O|O||D||1
50365420|Pera glou morceau en lata o en frasco|O|O||D||1
50365421|Pera hosui en lata o en frasco|O|O||D||1
50365422|Pera mantequilla italiana en lata o en frasco|O|O||D||1
50365423|Pera jargonelle en lata o en frasco|O|O||D||1
50365424|Pera juno en lata o en frasco|O|O||D||1
50365425|Para kaiserlouise bonne de jersey en lata o en frasco|O|O||D||1
50365426|Pera keiffer en lata o en frasco|O|O||D||1
50365427|Pera rey royal en lata o en frasco|O|O||D||1
50365428|Pera limonera en lata o en frasco|O|O||D||1
50365429|Pera merton pride en lata o en frasco|O|O||D||1
50365430|Pera mauntain bartlette en lata o en frasco|O|O||D||1
50365431|Pera oliver de serrers en lata o en frasco|O|O||D||1
50365432|Pera onward en lata o en frasco|O|O||D||1
50365433|Pera packham´s triumph en lata o en frasco|O|O||D||1
50365434|Pera paraíso en lata o en frasco|O|O||D||1
50365435|Pera passe crassane en lata o en frasco|O|O||D||1
50365436|Pera perry en lata o en frasco|O|O||D||1
50365437|Pera bartlette rojo en lata o en frasco|O|O||D||1
50365438|Pera dánjou  rojo en lata o en frasco|O|O||D||1
50365439|Pera rocha en lata o en frasco|O|O||D||1
50365440|Pera rosey rojo en lata o en frasco|O|O||D||1
50365441|Pera rosy roja en lata o en frasco|O|O||D||1
50365442|Pera majestuosa royal en lata o en frasco|O|O||D||1
50365443|Pera ruby rojo en lata o en frasco|O|O||D||1
50365444|Pera santa maria en lata o en frasco|O|O||D||1
50365445|Pera seckel en lata o en frasco|O|O||D||1
50365446|Pera sensación en lata o en frasco|O|O||D||1
50365447|Pera crimson estrella en lata o en frasco|O|O||D||1
50365448|Pera crimson stark en lata o en frasco|O|O||D||1
50365449|Pera bartlette de verano en lata o en frasco|O|O||D||1
50365450|Pera verano dorado en lata o en frasco|O|O||D||1
50365451|Pera sol dorado en lata o en frasco|O|O||D||1
50365452|Pera sunprite en lata o en frasco|O|O||D||1
50365453|Pera taylors dorado en lata o en frasco|O|O||D||1
50365454|Pera taylors rojo en lata o en frasco|O|O||D||1
50365455|Pera tientsin en lata o en frasco|O|O||D||1
50365456|Pera tosca en lata o en frasco|O|O||D||1
50365457|Pera warden  en lata o en frasco|O|O||D||1
50365458|Pera williams bon chretien en lata o en frasco|O|O||D||1
50365459|Pera williams en lata o en frasco|O|O||D||1
50365460|Pera nelis de invierno en lata o en frasco|O|O||D||1
50365500|Caquis en lata o en frasco|O|O||D||1
50365501|Caqui americano en lata o en frasco|O|O||D||1
50365502|Caqui sapote negro en lata o en frasco|O|O||D||1|Caqui zapote negro en lata o en frasco
50365503|Caqui chapote / negro en lata o en frasco|O|O||D||1
50365504|Caqui dátale ciruela en lata o en frasco|O|O||D||1
50365505|Caqui fuyu en lata o en frasco|O|O||D||1
50365506|Caqui gigante fuyu en lata o en frasco|O|O||D||1
50365507|Caqui hachiya en lata o en frasco|O|O||D||1
50365508|Caqui mantequilla / mabolo en lata o en frasco|O|O||D||1
50365509|Caqui príncipe ito en lata o en frasco|O|O||D||1
50365510|Caqui brillante royal en lata o en frasco|O|O||D||1
50365511|Caqui sharon en lata o en frasco|O|O||D||1
50365512|Caqui triumph en lata o en frasco|O|O||D||1
50365600|Piñas en lata o en frasco|O|O||D||1
50365601|Piña chirimoya en lata o en frasco|O|O||D||1|Atemoya en lata o en frasco
50365602|Piña dorada en lata o en frasco|O|O||D||1
50365603|Piña hilo en lata o en frasco|O|O||D||1
50365604|Piña kona sugarloaf en lata o en frasco|O|O||D||1
50365605|Piña reina natal en lata o en frasco|O|O||D||1
50365606|Piña pernabuco en lata o en frasco|O|O||D||1
50365607|Piña español rojo en lata o en frasco|O|O||D||1
50365608|Piña cayen suave en lata o en frasco|O|O||D||1
50365609|Piña sugarloaf en lata o en frasco|O|O||D||1
50365610|Piña variegated en lata o en frasco|O|O||D||1
50365700|Ciruelos Damascos en lata o en frasco|O|O||D||1
50365701|Ciruelo / damasco negro kat en lata o en frasco|O|O||D||1
50365702|Ciruelo / damasco gusto azul en lata o en frasco|O|O||D||1
50365703|Ciruelo / damasco corazón de crimson en lata o en frasco|O|O||D||1
50365704|Ciruelo / damasco dapply dandy en lata o en frasco|O|O||D||1
50365705|Ciruelo / damasco dapple fuego en lata o en frasco|O|O||D||1
50365706|Ciruelo / damasco  dapple temprano en lata o en frasco|O|O||D||1
50365707|Ciruelo / damasco  caída de sabor en lata o en frasco|O|O||D||1
50365708|Ciruelo / damasco sabor de oro en lata o en frasco|O|O||D||1
50365709|Ciruelo / damasco sabor granada en lata o en frasco|O|O||D||1
50365710|Ciruelo / damasco sabor de corazón en lata o en frasco|O|O||D||1
50365711|Ciruelo / damasco joya de sabor en lata o en frasco|O|O||D||1
50365712|Ciruelo / damasco sabor de rey en lata o en frasco|O|O||D||1
50365713|Ciruelo / damasco sabor de reina en lata o en frasco|O|O||D||1
50365714|Ciruelo / damasco sabor supremo en lata o en frasco|O|O||D||1
50365715|Ciruelo / damasco sabor premio en lata o en frasco|O|O||D||1
50365716|Ciruelo / damasco saborella en lata o en frasco|O|O||D||1
50365717|Ciruelo / damasco saborrico en lata o en frasco|O|O||D||1
50365718|Ciruelo / damasco  sabor rosa en lata o en frasco|O|O||D||1
50365719|Ciruelo / damasco orgullo geo en lata o en frasco|O|O||D||1
50365720|Ciruelo / damasco kat rojo en lata o en frasco|O|O||D||1
50365721|Ciruelo / damasco premio royal en lata o en frasco|O|O||D||1
50365722|Ciruelo / damasco rosa sierra en lata o en frasco|O|O||D||1
50365723|Ciruelo / damasco geisha dulce en lata o en frasco|O|O||D||1
50365800|Ciruelas en lata o en frasco|O|O||D||1
50365801|Ciruela joya amber en lata o en frasco|O|O||D||1
50365802|Ciruela angeleno en lata o en frasco|O|O||D||1
50365803|Ciruela aurora en lata o en frasco|O|O||D||1
50365804|Ciruela otoño bonito en lata o en frasco|O|O||D||1
50365805|Ciruela gigante de otoño en lata o en frasco|O|O||D||1
50365806|Ciruela orgullo de otoño en lata o en frasco|O|O||D||1
50365807|Ciruela rosa de otoño en lata o en frasco|O|O||D||1
50365808|Ciruela playero en lata o en frasco|O|O||D||1
50365809|Ciruela betty anne en lata o en frasco|O|O||D||1
50365810|Ciruela belleza negra en lata o en frasco|O|O||D||1
50365811|Ciruela bullase negra en lata o en frasco|O|O||D||1
50365812|Ciruela diamante negro en lata o en frasco|O|O||D||1
50365813|Ciruela gigante negro en lata o en frasco|O|O||D||1
50365814|Ciruela hielo negro en lata o en frasco|O|O||D||1
50365815|Ciruela esplendor negro en lata o en frasco|O|O||D||1
50365816|Ciruela ámbar negro en lata o en frasco|O|O||D||1
50365817|Ciruela purpura en lata o en frasco|O|O||D||1
50365818|Ciruela  carsbad en lata o en frasco|O|O||D||1
50365819|Ciruela casselman en lata o en frasco|O|O||D||1
50365820|Ciruela catalina en lata o en frasco|O|O||D||1
50365821|Ciruela damson en lata o en frasco|O|O||D||1
50365822|Ciruela dolly en lata o en frasco|O|O||D||1
50365823|Ciruela earliqueen en lata o en frasco|O|O||D||1
50365824|Ciruela rosa early en lata o en frasco|O|O||D||1
50365825|Ciruela ébano mayo en lata o en frasco|O|O||D||1
50365826|Ciruela ébano en lata o en frasco|O|O||D||1
50365827|Ciruela corazón de elefante en lata o en frasco|O|O||D||1
50365828|Ciruela belleza de esmeralda en lata o en frasco|O|O||D||1
50365829|Ciruela emperatriz en lata o en frasco|O|O||D||1
50365830|Ciruela libertad en lata o en frasco|O|O||D||1
50365831|Ciruela friar en lata o en frasco|O|O||D||1
50365832|Ciruela rojo gar en lata o en frasco|O|O||D||1
50365833|Ciruela gobernador en lata o en frasco|O|O||D||1
50365834|Ciruela rosa grande en lata o en frasco|O|O||D||1
50365835|Ciruela calibre verde en lata o en frasco|O|O||D||1
50365836|Ciruela calibre verde en lata o en frasco|O|O||D||1|Ciruela greengage en lata o en frasco
50365837|Ciruela hiromi en lata o en frasco|O|O||D||1
50365838|Ciruela hiromi rojo en lata o en frasco|O|O||D||1
50365839|Ciruela vacacion en lata o en frasco|O|O||D||1
50365840|Ciruela howard sol en lata o en frasco|O|O||D||1
50365841|Ciruela tipo interspecific en lata o en frasco|O|O||D||1
50365842|Ciruela jamaico en lata o en frasco|O|O||D||1
50365843|Ciruela joanna rojo en lata o en frasco|O|O||D||1
50365844|Ciruela kelsey en lata o en frasco|O|O||D||1
50365845|Ciruela jaime rey en lata o en frasco|O|O||D||1
50365846|Ciruela laroda en lata o en frasco|O|O||D||1
50365847|Ciruela rosa tarde en lata o en frasco|O|O||D||1
50365848|Ciruela rosa linda en lata o en frasco|O|O||D||1
50365849|Ciruela estrella solitaria en lata o en frasco|O|O||D||1
50365850|Ciruela mariposa en lata o en frasco|O|O||D||1
50365851|Ciruela mercado negro en lata o en frasco|O|O||D||1
50365852|Ciruela mercado rojo en lata o en frasco|O|O||D||1
50365853|Ciruela maribel en lata o en frasco|O|O||D||1
50365854|Ciruelas sol de octubre en lata o en frasco|O|O||D||1
50365855|Ciruela owen t en lata o en frasco|O|O||D||1
50365856|Ciruela perdrigon en lata o en frasco|O|O||D||1
50365857|Ciruela placer rosado en lata o en frasco|O|O||D||1
50365858|Ciruela  presidente en lata o en frasco|O|O||D||1
50365859|Ciruela primetime en lata o en frasco|O|O||D||1
50365860|Ciruela majestad purpura en lata o en frasco|O|O||D||1
50365861|Ciruela reina rosa en lata o en frasco|O|O||D||1
50365862|Ciruela quetsch en lata o en frasco|O|O||D||1
50365863|Ciruela belleza roja en lata o en frasco|O|O||D||1
50365864|Ciruela camino rojo en lata o en frasco|O|O||D||1
50365865|Ciruela ram rojo en lata o en frasco|O|O||D||1
50365866|Ciruela rosa roja en lata o en frasco|O|O||D||1
50365867|Ciruela rojo rico en lata o en frasco|O|O||D||1
50365868|Ciruela romero en lata o en frasco|O|O||D||1
50365869|Ciruela diamante rojo en lata o en frasco|O|O||D||1
50365870|Ciruela rojo royal en lata o en frasco|O|O||D||1
50365871|Ciruela royal zee en lata o en frasco|O|O||D||1
50365872|Ciruela roysum en lata o en frasco|O|O||D||1
50365873|Ciruela santa rosa en lata o en frasco|O|O||D||1
50365874|Ciruela zafiro en lata o en frasco|O|O||D||1
50365875|Ciruela sloe en lata o en frasco|O|O||D||1
50365876|Ciruela sta catherine en lata o en frasco|O|O||D||1
50365877|Ciruela bullase blanco en lata o en frasco|O|O||D||1
50365900|Granadas en lata o en frasco|O|O||D||1
50365901|Granada foothhill en lata o en frasco|O|O||D||1
50365902|Granada, granada en lata o en frasco|O|O||D||1|Granada en lata o en frasco
50365903|Granada rojo feliz en lata o en frasco|O|O||D||1
50365904|Granada nana en lata o en frasco|O|O||D||1
50365905|Granada rojo de pat en lata o en frasco|O|O||D||1
50365906|Granada pinkhan en lata o en frasco|O|O||D||1
50365907|Granada terciopelo morado en lata o en frasco|O|O||D||1
50365908|Granada grandioso en lata o en frasco|O|O||D||1
50366000|Pomelos en lata o en frasco|O|O||D||1
50366001|Pomelo chandler en lata o en frasco|O|O||D||1
50366002|Pomelo hirado butan en lata o en frasco|O|O||D||1
50366003|Pomelo liang ping yau en lata o en frasco|O|O||D||1
50366004|Pomelo panda wangi en lata o en frasco|O|O||D||1
50366005|Pomelo rosado en lata o en frasco|O|O||D||1
50366006|Pomelo shaddock rojo en lata o en frasco|O|O||D||1
50366007|Pomelo siamese dulce en lata o en frasco|O|O||D||1
50366008|Pomelo waingwright en lata o en frasco|O|O||D||1
50366100|Membrillos en lata o en frasco|O|O||D||1
50366101|Membrillo campeón en lata o en frasco|O|O||D||1
50366102|Membrillo piña en lata o en frasco|O|O||D||1
50366103|Membrillo smyma en lata o en frasco|O|O||D||1
50366200|Frambuesas en lata o en frasco|O|O||D||1
50366201|Frambuesa americana roja en lata o en frasco|O|O||D||1
50366202|Frambuesa bailey queensland en lata o en frasco|O|O||D||1
50366203|Frambuesa negra en lata o en frasco|O|O||D||1
50366204|Frambuesa oscura en lata o en frasco|O|O||D||1
50366205|Frambuesa deliciosa en lata o en frasco|O|O||D||1
50366206|Frambuesa enano focke en lata o en frasco|O|O||D||1
50366207|Frambuesa focke hojagris en lata o en frasco|O|O||D||1
50366208|Frambuesa focke fresa en lata o en frasco|O|O||D||1
50366209|Frambuesa  focke amarillo himalaya en lata o en frasco|O|O||D||1
50366210|Frambuesa dorado en lata o en frasco|O|O||D||1
50366211|Frambuesa gris nuevo mexico en lata o en frasco|O|O||D||1
50366212|Frambuesa jepson whitebark en lata o en frasco|O|O||D||1
50366213|Frambuesa kellogs san diego en lata o en frasco|O|O||D||1
50366214|Frambuesa leucodemis whitebark en lata o en frasco|O|O||D||1
50366215|Frambuesa munz cuyamaca en lata o en frasco|O|O||D||1
50366216|Frambuesa peck bartons en lata o en frasco|O|O||D||1
50366217|Frambuesa flor morada en lata o en frasco|O|O||D||1
50366218|Frambuesa roadside en lata o en frasco|O|O||D||1
50366219|Frambuesa san diego en lata o en frasco|O|O||D||1
50366220|Frambuesa nieve en lata o en frasco|O|O||D||1
50366221|Frambuesa pico de nieve en lata o en frasco|O|O||D||1
50366222|Frambuesa hoja de fresa en lata o en frasco|O|O||D||1
50366223|Frambuesa cultivo dulce en lata o en frasco|O|O||D||1
50366224|Frambuesa tor y gris whitebark en lata o en frasco|O|O||D||1
50366225|Frambuesa caribe en lata o en frasco|O|O||D||1
50366226|Frambuesa whitebark en lata o en frasco|O|O||D||1
50366227|Frambuesa vino en lata o en frasco|O|O||D||1
50366228|Frambuesa himalaya amarillo en lata o en frasco|O|O||D||1
50366229|Frambuesa yu-shan en lata o en frasco|O|O||D||1
50366300|Ruibarbos en lata o en frasco|O|O||D||1|Acelgas rojas en lata o en frasco
50366301|Ruibarbo crimson rojo en lata o en frasco|O|O||D||1|Acelga roja crimson en lata o en frasco
50366302|Ruibarbo champagne temprana en lata o en frasco|O|O||D||1|Acelga roja champagne temprana en lata o en frasco
50366303|Ruibarbo glasking perpetual  en lata o en frasco|O|O||D||1|Acelga roja glasking perpetual en lata o en frasco
50366304|Ruibarbo sutton en lata o en frasco|O|O||D||1|Acelga roja sutton en lata o en frasco
50366305|Ruibarbo timperley temprano en lata o en frasco|O|O||D||1|Acelga roja temprana de Timperley en lata o en frasco
50366306|Ruibarbo valentina en lata o en frasco|O|O||D||1|Acelga roja valentina en lata o en frasco
50366307|Ruibarbo victoria en lata o en frasco|O|O||D||1|Acelga roja victoria en lata o en frasco
50366308|Ruibarbo zwolle de cemilla en lata o en frasco|O|O||D||1|Acelga roja zwolle de semilla en lata o en frasco
50366309|Ruibarbo macdonald en lata o en frasco|O|O||D||1|Acelga roja macdonald en lata o en frasco
50366310|Ruibarbo tilden en lata o en frasco|O|O||D||1|Acelga roja tilden en lata o en frasco
50366400|Escaramujos en lata o en frasco|O|O||D||1|Rosa mosqueta en lata o en frasco
50366401|Escaramujo rosa brier en lata o en frasco|O|O||D||1|Rosa mosqueta brier en lata o en frasco
50366402|Escaramujo rosa elegante en lata o en frasco|O|O||D||1|Rosa mosqueta elegante en lata o en frasco
50366403|Escaramujo rosa rugosa en lata o en frasco|O|O||D||1|Rosa mosqueta rugosa en lata o en frasco
50366404|Escaramujo rosa burnet o scotch en lata o en frasco|O|O||D||1|Rosa mosqueta burnet o scotch en lata o en frasco
50366500|Sapotes en lata o en frasco|O|O||D||1|Zapotes en lata o en frasco
50366501|Sapote blanco en lata o en frasco|O|O||D||1|Zapote blanco en lata o en frasco
50366502|Sapote negro en lata o en frasco|O|O||D||1|Zapote negro en lata o en frasco
50366600|Bayas saskatoon en lata o en frasco|O|O||D||1|Fresas de junio en lata o en frasco
50366601|Baya mielmadera saskatoon en lata o en frasco|O|O||D||1|Fresa de junio mielmadera en lata o en frasco
50366602|Baya northline saskatoon en lata o en frasco|O|O||D||1|Fresa de junio northline en lata o en frasco
50366603|Baya saskatoon ahumado en lata o en frasco|O|O||D||1|Fresa de junio smoky en lata o en frasco
50366604|Baya saskatoon thiessen en lata o en frasco|O|O||D||1|Fresa de junio thiessen en lata o en frasco
50366700|Fresas en lata o en frasco|O|O||D||1
50366701|Fresa chandler en lata o en frasco|O|O||D||1
50366702|Fresa rumbo junio en lata o en frasco|O|O||D||1|Fresa temporada de junio en lata o en frasco
50366703|Fresa rumbo siempre en lata o en frasco|O|O||D||1|Fresa de todo el año en lata o en frasco
50366800|Manzanas dulces en lata o en frasco|O|O||D||1|Saramuyos en lata o en frasco
50366801|Manzana kampong malve dulce en lata o en frasco|O|O||D||1|Saramuyo kampong mauve en lata o en frasco
50366802|Manzana dulce sin pepa en lata o en frasco|O|O||D||1|Saramuyo sin semilla en lata o en frasco
50366803|Manzana dulce thai lessand en lata o en frasco|O|O||D||1|Saramuyo thai lessand en lata o en frasco
50366900|Tamarillos en lata o en frasco|O|O||D||1|Tomate de árbol en lata o en frasco
50366901|Tamarindo amberlea dorado en lata o en frasco|O|O||D||1|Tomate de árbol amberlea dorado en lata o en frasco
50366902|Tamarindo calvo dorado en lata o en frasco|O|O||D||1|Tomate de árbol calvo dorado en lata o en frasco
50366903|Tamarindo mina de oro en lata o en frasco|O|O||D||1|Tomate de árbol mina de oro en lata o en frasco
50366904|Tamarindo oratia rojo en lata o en frasco|O|O||D||1|Tomate de árbol oratia rojo en lata o en frasco
50366905|Tamarindo beau rojo en lata o en frasco|O|O||D||1|Tomate de árbol beau rojo en lata o en frasco
50366906|Tamarindo delicia roja en lata o en frasco|O|O||D||1|Tomate de árbol delicia roja en lata o en frasco
50367000|Frutas Nominant en lata o en frasco|O|O||D||1|Frutas predominantes en lata o en frasco
50367001|Cupania en lata o en frasco|O|O||D||1|Ackee en lata o en frasco
50367002|Babaco en lata o en frasco|O|O||D||1|Carica pentágona en lata o en frasco
50367003|Banana flor en lata o en frasco|O|O||D||1|Flor de plátano en lata o en frasco
50367004|Baobab en lata o en frasco|O|O||D||1
50367005|Naranja agria en lata o en frasco|O|O||D||1
50367006|Canistel en lata o en frasco|O|O||D||1|Zapote amarillo en lata o en frasco
50367007|Baya nublosa en lata o en frasco|O|O||D||1|Mora de los pantanos en lata o en frasco
50367008|Coco en lata o en frasco|O|O||D||1
50367009|Baya drew en lata o en frasco|O|O||D||1|Baya de gota en lata o en frasco
50367010|Durian en lata o en frasco|O|O||D||1|Durio en lata o en frasco
50367011|Baya elder en lata o en frasco|O|O||D||1|Baya de sauco en lata o en frasco
50367012|Feijoa en lata o en frasco|O|O||D||1|Guayabo del Brasil en lata o en frasco
50367013|Mora en lata o en frasco|O|O||D||1
50367014|Cretaegus en lata o en frasco|O|O||D||1|Majuelo en lata o en frasco
50367015|Baya miel en lata o en frasco|O|O||D||1|Madreselva azul en lata o en frasco
50367016|Jaca en lata o en frasco|O|O||D||1|Yaca en lata o en frasco
50367017|Jambolan en lata o en frasco|O|O||D||1
50367018|Jujube en lata o en frasco|O|O||D||1|Azufaifa en lata o en frasco
50367019|Liches en lata o en frascos orgánicos|O|O||D||1|Lichi en lata o en frascos orgánicos
50367020|Mangostinos en lata o en frascos orgánicos|O|O||D||1|Mangostán en lata o en frascos orgánicos
50367021|Medlar en lata o en frasco|O|O||D||1
50367022|Mombines en lata o en frasco|O|O||D||1|Hobo en lata o en frasco
50367023|Monstera en lata o en frasco|O|O||D||1|Cerimán en lata o en frasco
50367024|Pepinos en lata o en frasco|O|O||D||1|Pepino dulce en lata o en frasco
50367025|Platono en lata o en frasco|O|O||D||1|Plátano macho en lata o en frasco
50367026|Peras en escabeche en lata o en frasco|O|O||D||1|Tuna en lata o en frasco
50367027|Mamonsillo en lata o en frasco|O|O||D||1|Guaya en lata o en frasco
50367028|Rambután en lata o en frasco|O|O||D||1|Achotillo en lata o en frasco
50367029|Manzana rosa en lata o en frasco|O|O||D||1|Pero de agua en lata o en frasco
50367030|Rosele en lata o en frasco|O|O||D||1|Flor de jamaica en lata o en frasco
50367031|Baya rowan en lata o en frasco|O|O||D||1|Serba en lata o en frasco
50367032|Baya buckhom de mar en lata o en frasco|O|O||D||1|Espino amarillo en lata o en frasco
50367033|Baya plata en lata o en frasco|O|O||D||1|Olivo de otoño en lata o en frasco
50367034|Baya sorbete en lata o en frasco|O|O||D||1|Serba en lata o en frasco
50367035|Guanábana en lata o en frasco|O|O||D||1
50367036|Manzana estrella en lata o en frasco|O|O||D||1|Cainito en lata o en frasco
50367037|Tamarindo en lata o en frasco|O|O||D||1
50367100|Aronias en lata o en frasco|O|O||D||1
50367101|Aronia magia de otoño en lata o en frasco|O|O||D||1
50367102|Aronia brillantísima en lata o en frasco|O|O||D||1
50367103|Aronia nero en lata o en frasco|O|O||D||1
50367104|Aronia viquingo en lata o en frasco|O|O||D||1
50367200|Aceitunas en lata o en frasco|O|O||D||1
50367201|Aceitunas agrinion en lata o en frasco|O|O||D||1|Aceituna agrinion en lata o en frasco
50367202|Aceitunas aleppo en lata o en frasco|O|O||D||1|Aceituna aleppo en lata o en frasco
50367203|Aceitunas  alfonso en lata o en frasco|O|O||D||1|Aceituna alfonso en lata o en frasco
50367204|Aceitunas  amfisa en lata o en frasco|O|O||D||1|Aceituna amfisa en lata o en frasco
50367205|Aceitunas  arauco en lata o en frasco|O|O||D||1|Aceituna arauco en lata o en frasco
50367206|Aceitunas  arbequina en lata o en frasco|O|O||D||1|Aceituna arbequina en lata o en frasco
50367207|Aceitunas  atlanta en lata o en frasco|O|O||D||1|Aceituna atlanta en lata o en frasco
50367208|Aceitunas  cerignola en lata o en frasco|O|O||D||1|Aceituna cerignola en lata o en frasco
50367209|Aceitunas  cracked provencal en lata o en frasco|O|O||D||1|Aceituna cracked provencal en lata o en frasco
50367210|Aceitunas  empeltre en lata o en frasco|O|O||D||1|Aceituna empeltre en lata o en frasco
50367211|Aceitunas gaeta  en lata o en frasco|O|O||D||1|Aceituna gaeta en lata o en frasco
50367212|Aceitunas hondoelia en lata o en frasco|O|O||D||1|Aceituna hondoelia en lata o en frasco
50367213|Aceitunas kalamata en lata o en frasco|O|O||D||1|Aceituna kalamata en lata o en frasco
50367214|Aceitunas kura en lata o en frasco|O|O||D||1|Aceituna kura en lata o en frasco
50367215|Aceitunas ligurian en lata o en frasco|O|O||D||1|Aceituna ligurian en lata o en frasco
50367216|Aceitunas lucque en lata o en frasco|O|O||D||1|Aceituna lucque en lata o en frasco
50367217|Aceitunas lugano en lata o en frasco|O|O||D||1|Aceituna lugano en lata o en frasco
50367218|Aceitunas manzanilla en lata o en frasco|O|O||D||1|Aceituna manzanilla en lata o en frasco
50367219|Aceitunas marche en lata o en frasco|O|O||D||1|Aceituna marche en lata o en frasco
50367220|Aceitunas misión en lata o en frasco|O|O||D||1|Aceituna misión en lata o en frasco
50367221|Aceitunas nafplion verde en lata o en frasco|O|O||D||1|Aceituna nafplion verde en lata o en frasco
50367222|Aceitunas nicoise en lata o en frasco|O|O||D||1|Aceituna nicoise en lata o en frasco
50367223|Aceitunas nyons en lata o en frasco|O|O||D||1|Aceituna nyons en lata o en frasco
50367224|Aceitunas picholine en lata o en frasco|O|O||D||1|Aceituna picholine en lata o en frasco
50367225|Aceitunas ponentine en lata o en frasco|O|O||D||1|Aceituna ponentine en lata o en frasco
50367226|Aceitunas royal en lata o en frasco|O|O||D||1|Aceituna royal en lata o en frasco
50367227|Aceitunas seracena en lata o en frasco|O|O||D||1|Aceituna seracena en lata o en frasco
50367228|Aceitunas sevillano en lata o en frasco|O|O||D||1|Aceituna sevillano en lata o en frasco
50367229|Aceitunas sicilian en lata o en frasco|O|O||D||1|Aceituna sicilian en lata o en frasco
50367230|Aceitunas toscanella en lata o en frasco|O|O||D||1|Aceituna toscanella en lata o en frasco
50371500|Manzanas orgánicas en lata o en frasco|O|O||D||1
50371501|Manzanas akane orgánica en lata o en frascos|O|O||D||1|Manzana akane orgánica en lata o en frascos
50371502|Manzana ambrosia orgánica en lata o en frasco|O|O||D||1
50371503|Manzanas api orgánica en lata o en frascos|O|O||D||1|Manzana api orgánica en lata o en frascos
50371504|Manzanas baldwin orgánica en lata o en  frasco|O|O||D||1|Manzana baldwin orgánica en lata o en frasco
50371505|Manzanas brabum orgánica en lata o en frasco|O|O||D||1|Manzana brabum orgánica en lata o en frasco
50371506|Manzanas bramley orgánica en lata o en frasco|O|O||D||1|Manzana bramley orgánica en lata o en frasco
50371507|Manzana joven bramley orgánica  en lata o en frasco|O|O||D||1
50371508|Manzana calville blanche d’hiver orgánica en lata o en frasco|O|O||D||1
50371509|Manzana cameo orgánica en lata o en frasco|O|O||D||1
50371510|Manzana charles ross orgánica en lata o en frasco|O|O||D||1
50371511|Manzana codlin orgánica en lata o en frasco|O|O||D||1
50371512|Manzana cortland orgánica en lata o en frasco|O|O||D||1
50371513|Manzana costard orgánica en lata o en frasco|O|O||D||1
50371514|Manzana court pendu plat orgánica en lata o en frasco|O|O||D||1
50371515|Manzana  cox´s orange pippin orgánica en lata o en frasco|O|O||D||1
50371516|Manzana crab orgánica en lata o en frasco|O|O||D||1
50371517|Manzana crispin orgánica en lata o en frasco|O|O||D||1
50371518|Manzana delicious orgánica en lata o en frasco|O|O||D||1
50371519|Manzana duquesa orgánica en lata o en frasco|O|O||D||1
50371520|Manzana earligold orgánica en lata o en frasco|O|O||D||1
50371521|Manzana early mcintosh orgánica en lata o en frasco|O|O||D||1
50371522|Manzana elstar orgánica en lata o en frasco|O|O||D||1
50371523|Manzana empire orgánica en lata o en frasco|O|O||D||1
50371524|Manzana flor de kent orgánica en lata o en frasco|O|O||D||1
50371525|Manzana fiji orgánica en lata o en frasco|O|O||D||1
50371526|Manzana gala orgánica en lata o en frasco|O|O||D||1
50371527|Manzana gascoyne´s scarlet orgánica en lata o en frasco|O|O||D||1
50371528|Manzana gillyflower orgánica en lata o en frasco|O|O||D||1
50371529|Manzana ginger gold orgánica en lata o en frasco|O|O||D||1
50371530|Manzana gladstone orgánica en lata o en frasco|O|O||D||1
50371531|Manzana gloster orgánica en lata o en frasco|O|O||D||1
50371532|Manzana gold supreme orgánica en lata o en frasco|O|O||D||1
50371533|Manzana golden delicious orgánica en lata o en frasco|O|O||D||1
50371534|Manzana golden nobel orgánica en lata o en frasco|O|O||D||1
50371535|Manzana granny smith orgánica en lata o en frasco|O|O||D||1
50371536|Manzana gravenstain orgánica en lata o en frasco|O|O||D||1
50371537|Manzana greening orgánica en lata o en frasco|O|O||D||1
50371538|Manzana greensleeves orgánica en lata o en frasco|O|O||D||1
50371539|Manzana honeycrisp orgánica en lata o en frasco|O|O||D||1
50371540|Manzana howgate wonder orgánica en lata o en frasco|O|O||D||1
50371541|Manzana red ida orgánica en lata o en frasco|O|O||D||1
50371542|Manzana james grives orgánica en lata o en frasco|O|O||D||1
50371543|Manzana jersey mac orgánica en lata o en frasco|O|O||D||1
50371544|Manzana jaster orgánica en lata o en frasco|O|O||D||1
50371545|Manzana jonagold orgánica en lata o en frasco|O|O||D||1
50371546|Manzana jonamac orgánica en lata o en frasco|O|O||D||1
50371547|Manzana  jonathan  orgánica en lata o en frasco|O|O||D||1
50371548|Manzana katy orgánica en lata o en frasco|O|O||D||1
50371549|Manzana kidd´s orange red orgánica en lata o en frasco|O|O||D||1
50371550|Manzana lady orgánica en lata o en frasco|O|O||D||1
50371551|Manzana law rome orgánica en lata o en frasco|O|O||D||1
50371552|Manzana laxton orgánica en lata o en frasco|O|O||D||1
50371553|Manzana lord derby orgánica en lata o en frasco|O|O||D||1
50371554|Manzana macoun  orgánica en lata o en frasco|O|O||D||1
50371555|Manzana mcintosh orgánica en lata o en frasco|O|O||D||1
50371556|Manzana mutsu orgánica en lata o en frasco|O|O||D||1
50371557|Manzana newtown pippin orgánica en lata o en frasco|O|O||D||1
50371558|Manzana northen spy orgánica en lata o en frasco|O|O||D||1
50371559|Manzana orleans reinette orgánica en lata o en frasco|O|O||D||1
50371560|Manzana ozark gold orgánica en lata o en frasco|O|O||D||1
50371561|Manzana rosa pacifica orgánica en lata o en frasco|O|O||D||1
50371562|Manzana paula roja orgánica en lata o en frasco|O|O||D||1
50371563|Manzana peamain orgánica en lata o en frasco|O|O||D||1
50371564|Manzana dama rosada orgánica en lata o en frasco|O|O||D||1
50371565|Manzana pippin orgánica en lata o en frasco|O|O||D||1
50371566|Manzana pitmaston pineapple orgánica en lata o en frasco|O|O||D||1
50371567|Manzana pomme dápi orgánica en lata o en frasco|O|O||D||1
50371568|Manzana prime gold orgánica en lata o en frasco|O|O||D||1
50371569|Manzana rojo astrakhan orgánica en lata o en frasco|O|O||D||1
50371570|Manzana rojo boscoop orgánica en lata o en frasco|O|O||D||1
50371571|Manzana rojo jefe orgánica en lata o en frasco|O|O||D||1
50371572|Manzana delicia rojo orgánica en lata o en frasco|O|O||D||1
50371573|Manzana rojo grvenstain orgánica en lata o en frasco|O|O||D||1
50371574|Manzana  roma orgánica en lata o en frasco|O|O||D||1
50371575|Manzana rojo stayman orgánica en lata o en frasco|O|O||D||1
50371576|Manzana rojo york orgánica en lata o en frasco|O|O||D||1
50371577|Manzana reinette orgánica en lata o en frasco|O|O||D||1
50371578|Manzana belleza romana orgánica en lata o en frasco|O|O||D||1
50371579|Manzana russet orgánica en lata o en frasco|O|O||D||1
50371580|Manzana sierra belleza orgánica en lata o en frasco|O|O||D||1
50371581|Manzana spartan orgánica en lata o en frasco|O|O||D||1
50371582|Manzana stark crimson orgánica en lata o en frasco|O|O||D||1
50371583|Manzana starking orgánica en lata o en frasco|O|O||D||1
50371584|Manzana stayman orgánica en lata o en frasco|O|O||D||1
50371585|Manzana stayman winesap orgánica en lata o en frasco|O|O||D||1
50371586|Manzana summer rambo orgánica en lata o en frasco|O|O||D||1
50371587|Manzana tsugaru orgánica en lata o en frasco|O|O||D||1
50371588|Manzana twenty ounce orgánica en lata o en frasco|O|O||D||1
50371589|Manzana tydeman red orgánica en lata o en frasco|O|O||D||1
50371590|Manzana vistabella orgánica en lata o en frasco|O|O||D||1
50371591|Manzana weatley orgánica en lata o en frasco|O|O||D||1
50371592|Manzana blanca joanetine orgánica en lata o en frasco|O|O||D||1
50371593|Manzana blanca transparent orgánica en lata o en frasco|O|O||D||1
50371594|Manzana winesap orgánica en lata o en frasco|O|O||D||1
50371595|Manzana worcester orgánica en lata o en frasco|O|O||D||1
50371596|Manzana york imperial orgánica en lata o en frasco|O|O||D||1
50371600|Albaricoques orgánicos en lata o en frasco|O|O||D||1|Chabacanos orgánicos en lata o en frasco
50371601|Abaricoques ambercot orgánica en lata o en frasco|O|O||D||1|Chabacano ambercot orgánico en lata o en frasco
50371602|Albaricoques apache orgánica en lata o en frasco|O|O||D||1|Chabacano apache orgánico en lata o en frasco
50371603|Albaricoques brittany gold orgánica en lata o en frasco|O|O||D||1|Chabacano brittany gold orgánico en lata o en frasco
50371604|Albaricoque black orgánica en lata o en frasco|O|O||D||1|Chabacano black orgánico en lata o en frasco
50371605|Albaricoque blenheim orgánica en lata o en frasco|O|O||D||1|Chabacano blenheim orgánico en lata o en frasco
50371606|Albaricoque bonny orgánica en lata o en frasco|O|O||D||1|Chabacano bonny orgánico en lata o en frasco
50371607|Albaricoque biluda orgánica en lata o en frasco|O|O||D||1|Chabacano biluda orgánico en lata o en frasco
50371608|Albaricoque castlebrite orgánica en lata o en frasco|O|O||D||1|Chabacano castlebrite orgánico en lata o en frasco
50371609|Albaricoque  clutha gold orgánica en lata o en frasco|O|O||D||1|Chabacano clutha gold orgánico en lata o en frasco
50371610|Albaricoque clutha sun orgánica en lata o en frasco|O|O||D||1|Chabacano clutha sun orgánico en lata o en frasco
50371611|Albaricoque derby royal orgánica en lata o en frasco|O|O||D||1|Chabacano derby royal orgánico en lata o en frasco
50371612|Albaricoque dina orgánica en lata o en frasco|O|O||D||1|Chabacano dina orgánico en lata o en frasco
50371613|Albaricoque earlicot orgánica en lata o en frasco|O|O||D||1|Chabacano earlicot orgánico en lata o en frasco
50371614|Albaricoque earliman orgánica en lata o en frasco|O|O||D||1|Chabacano earliman orgánico en lata o en frasco
50371615|Albaricoque early bright orgánica en lata o en frasco|O|O||D||1|Chabacano early bright orgánico en lata o en frasco
50371616|Albaricoque dorado en llamas orgánica en lata o en frasco|O|O||D||1|Chabacano dorado en llamas orgánico en lata o en frasco
50371617|Albaricoque frenso orgánica en lata o en frasco|O|O||D||1|Chabacano frenso orgánico en lata o en frasco
50371618|Albaricoque gold bright orgánica en lata o en frasco|O|O||D||1|Chabacano gold bright orgánico en lata o en frasco
50371619|Albaricoque goldbar orgánica en lata o en frasco|O|O||D||1|Chabacano goldbar orgánico en lata o en frasco
50371620|Albaricoque dulce dorado orgánica en lata o en frasco|O|O||D||1|Chabacano dulce dorado orgánico en lata o en frasco
50371621|Albaricoque rico dorado orgánica en lata o en frasco|O|O||D||1|Chabacano rico dorado orgánico en lata o en frasco
50371622|Albaricoque helena orgánica en lata o en frasco|O|O||D||1|Chabacano helena orgánico en lata o en frasco
50371623|Albaricoque honeycot orgánica en lata o en frasco|O|O||D||1|Chabacano  orgánico en lata o en frasco
50371624|Albaricoque imperial orgánica en lata o en frasco|O|O||D||1|Chabacano imperial orgánico en lata o en frasco
50371625|Albaricoque jordanne orgánica en lata o en frasco|O|O||D||1|Chabacano jordanne orgánico en lata o en frasco
50371626|Albaricoque jumbo cot orgánica en lata o en frasco|O|O||D||1|Chabacano jumbo cot orgánico en lata o en frasco
50371627|Albaricoque kandy kot orgánica en lata o en frasco|O|O||D||1|Chabacano kandy kot orgánico en lata o en frasco
50371628|Albaricoque katy orgánica en lata o en frasco|O|O||D||1|Chabacano katy orgánico en lata o en frasco
50371629|Albaricoque rey orgánica en lata o en frasco|O|O||D||1|Chabacano rey orgánico en lata o en frasco
50371630|Albaricoque lambertin orgánica en lata o en frasco|O|O||D||1|Chabacano lambertin orgánico en lata o en frasco
50371631|Albaricoque loma orgánica en lata o en frasco|O|O||D||1|Chabacano loma orgánico en lata o en frasco
50371632|Albaricoque lulu belle orgánica en lata o en frasco|O|O||D||1|Chabacano lulu belle orgánico en lata o en frasco
50371633|Albaricoque modesto orgánica en lata o en frasco|O|O||D||1|Chabacano modesto orgánico en lata o en frasco
50371634|Albaricoque moorpark orgánica en lata o en frasco|O|O||D||1|Chabacano moorpark orgánico en lata o en frasco
50371635|Albaricoque orangered orgánica en lata o en frasco|O|O||D||1|Chabacano orange red orgánico en lata o en frasco
50371636|Albaricoque palstein orgánica en lata o en frasco|O|O||D||1|Chabacano palstein orgánico en lata o en frasco
50371637|Albaricoque patterson orgánica en lata o en frasco|O|O||D||1|Chabacano patterson orgánico en lata o en frasco
50371638|Albaricoque perfection orgánica en lata o en frasco|O|O||D||1|Chabacano perfection orgánico en lata o en frasco
50371639|Albaricoque poppy orgánica en lata o en frasco|O|O||D||1|Chabacano poppy orgánico en lata o en frasco
50371640|Albaricoque poppycot orgánica en lata o en frasco|O|O||D||1|Chabacano poppy cot orgánico en lata o en frasco
50371641|Albaricoque reina orgánica en lata o en frasco|O|O||D||1|Chabacano reina orgánico en lata o en frasco
50371642|Albaricoque riland orgánica en lata o en frasco|O|O||D||1|Chabacano riland orgánico en lata o en frasco
50371643|Albaricoque rival orgánica en lata o en frasco|O|O||D||1|Chabacano rival orgánico en lata o en frasco
50371644|Albaricoque robada orgánica en lata o en frasco|O|O||D||1|Chabacano robada orgánico en lata o en frasco
50371645|Albaricoque royal orgánica en lata o en frasco|O|O||D||1|Chabacano royal orgánico en lata o en frasco
50371646|Albaricoque  royal blenheim orgánica en lata o en frasco|O|O||D||1|Chabacano royal blenheim orgánico en lata o en frasco
50371647|Albaricoque  royal orange orgánica en lata o en frasco|O|O||D||1|Chabacano royal orange orgánico en lata o en frasco
50371648|Albaricoque sundrop orgánica en lata o en frasco|O|O||D||1|Chabacano sundrop orgánico en lata o en frasco
50371649|Albaricoque tilton orgánica en lata o en frasco|O|O||D||1|Chabacano tilton orgánico en lata o en frasco
50371650|Albaricoque tomcot orgánica en lata o en frasco|O|O||D||1|Chabacano tomcot orgánico en lata o en frasco
50371651|Albaricoque tracy orgánica en lata o en frasco|O|O||D||1|Chabacano tracy orgánico en lata o en frasco
50371652|Albaricoque tri gem orgánica en lata o en frasco|O|O||D||1|Chabacano tri gem orgánico en lata o en frasco
50371653|Albaricoque valley gold orgánica en lata o en frasco|O|O||D||1|Chabacano valley gold orgánico en lata o en frasco
50371654|Albaricoque westley orgánica en lata o en frasco|O|O||D||1|Chabacano westley orgánico en lata o en frasco
50371655|Albaricoque  york orgánica en lata o en frasco|O|O||D||1|Chabacano york orgánico en lata o en frasco
50371700|Bananos orgánicos en lata o en frasco|O|O||D||1|Plátanos orgánicos en lata o en frasco
50371701|Banana manzana orgánica en lata o en frasco|O|O||D||1|Plátano apple orgánico en lata o en frasco
50371702|Banana baby orgánica en lata o en frasco|O|O||D||1|Plátano baby orgánico en lata o en frasco
50371703|Banana burro orgánica en lata o en frasco|O|O||D||1|Plátano burro orgánico en lata o en frasco
50371704|Bananas cavendish orgánica en lata o en frasco|O|O||D||1|Plátano cavendish orgánico en lata o en frasco
50371705|Bananas dominico orgánica en lata o en frasco|O|O||D||1|Plátano dominico orgánico en lata o en frasco
50371706|Bananas verde orgánica en lata o en frasco|O|O||D||1|Plátano verde orgánico en lata o en frasco
50371707|Bananas gros michel orgánica en lata o en frasco|O|O||D||1|Plátano gros michel orgánico en lata o en frasco
50371708|Bananas lacatan orgánica en lata o en frasco|O|O||D||1|Plátano lacatan orgánico en lata o en frasco
50371709|Bananas dedos de dama orgánica en lata o en frasco|O|O||D||1|Plátano dedos de dama orgánico en lata o en frasco
50371710|Bananas manzano orgánica en lata o en frasco|O|O||D||1|Plátano manzano orgánico en lata o en frasco
50371711|Banana mysore orgánica en lata o en frasco|O|O||D||1|Plátano mysore orgánico en lata o en frasco
50371712|Banana pisang mas orgánica en lata o en frasco|O|O||D||1|Plátano pisang mas orgánico en lata o en frasco
50371713|Bananas red orgánica en lata o en frasco|O|O||D||1|Plátano red orgánico en lata o en frasco
50371714|Bananas saba orgánica en lata o en frasco|O|O||D||1|Plátano saba orgánico en lata o en frasco
50371715|Bananas sucrier orgánica en lata o en frasco|O|O||D||1|Plátano sucrier orgánico en lata o en frasco
50371800|Barberries orgánicos en lata o en frasco|O|O||D||1|Berberís orgánicos en lata o en frasco
50371801|Berberís paleleaf orgánica en lata o en frasco|O|O||D||1|Berberí paleleaf orgánico en lata o en frasco
50371802|Barberís chenault orgánica en lata o en frasco|O|O||D||1|Berberí chenault orgánico en lata o en frasco
50371803|Barberries red orgánica en lata o en frasco|O|O||D||1|Berberí  red orgánico en lata o en frasco
50371804|Barberís wintergreen orgánica en lata o en frasco|O|O||D||1|Berberí wintergreen orgánico en lata o en frasco
50371805|Barberís korean orgánica en lata o en frasco|O|O||D||1|Berberí korean orgánico en lata o en frasco
50371806|Barberís mentor orgánica en lata o en frasco|O|O||D||1|Berberí mentor orgánico en lata o en frasco
50371807|Barberís japonesa orgánica en lata o en frasco|O|O||D||1|Berberí japonesa orgánico en lata o en frasco
50371808|Barberís atropurpurea orgánica en lata o en frasco|O|O||D||1|Berberí atropurpurea orgánico en lata o en frasco
50371809|Barberís aurea orgánica en lata o en frasco|O|O||D||1|Berberí aurea orgánico en lata o en frasco
50371810|Barberís bagatelle orgánica en lata o en frasco|O|O||D||1|Berberí bagatelle orgánico en lata o en frasco
50371811|Barberís crimsom pygmy orgánica en lata o en frasco|O|O||D||1|Berberí crimsom pygmy orgánico en lata o en frasco
50371812|Barberís kobold orgánica en lata o en frasco|O|O||D||1|Berberí kobold orgánico en lata o en frasco
50371813|Barberís warty orgánica en lata o en frasco|O|O||D||1|Berberí warty orgánico en lata o en frasco
50371814|Barberís europa orgánica en lata o en frasco|O|O||D||1|Berberí europa orgánico en lata o en frasco
50371900|Gayubas orgánicas en lata o en frasco|O|O||D||1|Rastreras orgánicas en lata o en frasco
50371901|Gayuba alpine orgánica en lata o en frasco|O|O||D||1|Rastrera alpine orgánica en lata o en frasco
50371902|Gayuba roja orgánica en lata o en frasco|O|O||D||1|Rastrera roja orgánica en lata o en frasco
50371903|Gayuba común orgánica en lata o en frasco|O|O||D||1|Rastrera común orgánica en lata o en frasco
50372000|Moras orgánicas en lata o en frasco|O|O||D||1|Zarzamoras orgánicas en lata o en frasco
50372001|Mora apache orgánica en lata o en frasco|O|O||D||1|Zarzamora apache orgánica en lata o en frasco
50372002|Mora satín negro orgánica en lata o en frasco|O|O||D||1|Zarzamora satín negro orgánica en lata o en frasco
50372003|Mora orgánica en lata o en frasco|O|O||D||1|Zarzamora orgánica en lata o en frasco
50372004|Mora cherokee orgánica en lata o en frasco|O|O||D||1|Zarzamora cherokee orgánica en lata o en frasco
50372005|Mora chester orgánica en lata o en frasco|O|O||D||1|Zarzamora chéster orgánica en lata o en frasco
50372006|Mora dirksen orgánica en lata o en frasco|O|O||D||1|Zarzamora dirksen orgánica en lata o en frasco
50372007|Bayas josta orgánica en lata o en frasco|O|O||D||1|Zarzamora josta orgánica en lata o en frasco
50372008|Bayas logan orgánica en lata o en frasco|O|O||D||1|Zarzamora logan orgánica en lata o en frasco
50372009|Bayas marión orgánica en lata o en frasco|O|O||D||1|Zarzamora marión orgánica en lata o en frasco
50372010|Mora navaho orgánica en lata o en frasco|O|O||D||1|Zarzamora navaho orgánica en lata o en frasco
50372011|Baya nectar orgánica en lata o en frasco|O|O||D||1|Zarzamora néctar orgánica en lata o en frasco
50372012|Mora olallie orgánica en lata o en frasco|O|O||D||1|Zarzamora olallie orgánica en lata o en frasco
50372013|Bayatay orgánica en lata o en frasco|O|O||D||1|Zarzamora tay orgánica en lata o en frasco
50372014|Mora thomless hull orgánica en lata o en frasco|O|O||D||1|Zarzamora thomless hull orgánica en lata o en frasco
50372015|Bayayoung orgánica en lata o en frasco|O|O||D||1|Zarzamora young orgánica en lata o en frasco
50372100|Arándanos de mirto orgánicos en lata o en frasco|O|O||D||1|Mirtillos orgánicos en lata o en frasco
50372101|Arandanos bog orgánica en lata o en frasco|O|O||D||1|Mirtillo bog orgánico en lata o en frasco
50372102|Arandanos enano orgánica en lata o en frasco|O|O||D||1|Mirtillo enano orgánico en lata o en frasco
50372103|Arandanos montaña orgánica en lata o en frasco|O|O||D||1|Mirtillo de montaña orgánico en lata o en frasco
50372104|Arandanos oval-leaved orgánica en lata o en frasco|O|O||D||1|Mirtillo oval-leaved orgánico en lata o en frasco
50372200|Agrás orgánicas en lata o en frasco|O|O||D||1|Frutos azules del bosque orgánicos en lata o en frasco
50372201|Agras bluecrop orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque bluecrop orgánico en lata o en frasco
50372202|Agras bluetta orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque bluetta orgánico en lata o en frasco
50372203|Agras brigitta orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque brigitta orgánico en lata o en frasco
50372204|Agras chandler orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque chandler orgánico en lata o en frasco
50372205|Agras duke orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque duke orgánico en lata o en frasco
50372206|Agras hrdyblue orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque hrdyblue orgánico en lata o en frasco
50372207|Agras legacy orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque legacy orgánico en lata o en frasco
50372208|Agras misty orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque misty orgánico en lata o en frasco
50372209|Agras nelson orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque nelson orgánico en lata o en frasco
50372210|Agras northblue orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque northblue orgánico en lata o en frasco
50372211|Agras northcountry orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque northcountry orgánico en lata o en frasco
50372212|Agras northsky orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque northsky orgánico en lata o en frasco
50372213|Agras patriot orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque patriot orgánico en lata o en frasco
50372214|Agras spartan orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque spartan orgánico en lata o en frasco
50372215|Agras toro orgánica en lata o en frasco|O|O||D||1|Fruto azul del bosque toro orgánico en lata o en frasco
50372300|Frutas del pan orgánicas en lata o en frasco|O|O||D||1
50372301|Fruta de pan chataigne orgánica en lata o en frasco|O|O||D||1|Fruta del pan chataigne orgánica en lata o en frasco
50372302|Fruta de pan sin pepa orgánica en lata o en frasco|O|O||D||1|Fruta del pan sin semilla orgánica en lata o en frasco
50372303|Fruta de pan corazón blanco orgánica en lata o en frasco|O|O||D||1|Fruta del pan corazón blanco orgánica en lata o en frasco
50372304|Fruta de pan corazón amarillo orgánica en lata o en frasco|O|O||D||1|Fruta del pan corazón amarillo orgánica en lata o en frasco
50372400|Chirimoyas orgánicas en lata o en frasco|O|O||D||1|Annonas orgánicas en lata o en frasco
50372401|Chirimoya chays orgánica en lata o en frasco|O|O||D||1|Annona chays orgánica en lata o en frasco
50372402|Chirimoya bronceada orgánica en lata o en frasco|O|O||D||1|Annona bronceada orgánica en lata o en frasco
50372403|Chirimoya burtons orgánica en lata o en frasco|O|O||D||1|Annona burtons orgánica en lata o en frasco
50372404|Chirimoya burton favorite orgánica en lata o en frasco|O|O||D||1|Annona burton favorite orgánica en lata o en frasco
50372405|Chirimoya jete orgánica en lata o en frasco|O|O||D||1|Annona jete orgánica en lata o en frasco
50372406|Chirimoya reretai orgánica en lata o en frasco|O|O||D||1|Annona reretai orgánica en lata o en frasco
50372407|Chirimoya smoothey orgánica en lata o en frasco|O|O||D||1|Annona smoothey orgánica en lata o en frasco
50372408|Chirimoya españa orgánica en lata o en frasco|O|O||D||1|Annona españa orgánica en lata o en frasco
50372409|Chirimoya white orgánica en lata o en frasco|O|O||D||1|Annona white orgánica en lata o en frasco
50372500|Cerezas orgánicas en lata o en frasco|O|O||D||1
50372501|Cereza amarelle  orgánica en lata o en frasco|O|O||D||1
50372502|Cereza brooks orgánica en lata o en frasco|O|O||D||1
50372503|Cereza bigarreu orgánica en lata o en frasco|O|O||D||1
50372504|Cereza bing orgánica en lata o en frasco|O|O||D||1
50372505|Cereza blach republica orgánica en lata o en frasco|O|O||D||1
50372506|Cereza negra schmidt orgánica en lata o en frasco|O|O||D||1
50372507|Cereza blacktartarian orgánica en lata o en frasco|O|O||D||1
50372508|Cereza fiesta bing orgánica en lata o en frasco|O|O||D||1
50372509|Cereza garnet orgánica en lata o en frasco|O|O||D||1
50372510|Cereza king orgánica en lata o en frasco|O|O||D||1
50372511|Cereza chapman orgánica en lata o en frasco|O|O||D||1
50372512|Cereza lapin orgánica en lata o en frasco|O|O||D||1
50372513|Cereza larian orgánica en lata o en frasco|O|O||D||1
50372514|Cereza oscuro guines orgánica en lata o en frasco|O|O||D||1
50372515|Cereza montmorency orgánica en lata o en frasco|O|O||D||1
50372516|Cereza duque orgánica en lata o en frasco|O|O||D||1
50372517|Cereza early rivers orgánica en lata o en frasco|O|O||D||1
50372518|Cereza ruby bing orgánica en lata o en frasco|O|O||D||1
50372519|Cereza santin orgánica en lata o en frasco|O|O||D||1
50372520|Cereza geans/guines orgánica en lata o en frasco|O|O||D||1
50372521|Cereza sonata orgánica en lata o en frasco|O|O||D||1
50372522|Cereza lambert orgánica en lata o en frasco|O|O||D||1
50372523|Cereza stella orgánica en lata o en frasco|O|O||D||1
50372524|Cereza sweethart orgánica en lata o en frasco|O|O||D||1
50372525|Cereza tartarian orgánica en lata o en frasco|O|O||D||1
50372527|Cereza maraschino orgánica en lata o en frasco|O|O||D||1
50372528|Cereza van orgánica en lata o en frasco|O|O||D||1
50372529|Cereza morello orgánica en lata o en frasco|O|O||D||1
50372530|Cereza royal ann orgánica en lata o en frasco|O|O||D||1
50372531|Cereza ranier orgánica en lata o en frasco|O|O||D||1
50372532|Cereza royal orgánica en lata o en frasco|O|O||D||1
50372600|Citrones orgánicos en lata o en frasco|O|O||D||1|Cidras orgánicas en lata o en frasco
50372601|Citrones buddha´s mano orgánica en lata o en frasco|O|O||D||1|Cidra mano de Buda orgánica en lata o en frasco
50372602|Citrones fingered orgánica en lata o en frasco|O|O||D||1|Cidra finger red orgánica en lata o en frasco
50372603|Citrones fo shoukan orgánica en lata o en frasco|O|O||D||1|Cidra fo shoukan orgánica en lata o en frasco
50372604|Citrones bushakan orgánica en lata o en frasco|O|O||D||1|Cidra bushakan orgánica en lata o en frasco
50372605|Citones diamante orgánica en lata o en frasco|O|O||D||1|Cidra diamante orgánica en lata o en frasco
50372606|Citrones etrog orgánica en lata o en frasco|O|O||D||1|Cidra etrog orgánica en lata o en frasco
50372607|Citrones ponderosa orgánica en lata o en frasco|O|O||D||1|Cidra ponderosa orgánica en lata o en frasco
50372700|Arándanos orgánicos en lata o en frasco|O|O||D||1|Arándanos rojos orgánicos en lata o en frasco
50372701|Arandano ben lear orgánica en lata o en frasco|O|O||D||1|Arándano rojo ben lear orgánico en lata o en frasco
50372702|Arandano early negro orgánica en lata o en frasco|O|O||D||1|Arándano rojo early negro orgánico en lata o en frasco
50372703|Arandano grayclesik orgánica en lata o en frasco|O|O||D||1|Arándano rojo grayclesik orgánico en lata o en frasco
50372704|Arandano  howe orgánica en lata o en frasco|O|O||D||1|Arándano rojo howe orgánico en lata o en frasco
50372705|Bayas lingon orgánica en lata o en frasco|O|O||D||1|Arándano rojo lingon orgánico en lata o en frasco
50372706|Arandano mcfarling orgánica en lata o en frasco|O|O||D||1|Arándano rojo mcfarling orgánico en lata o en frasco
50372707|Arandano montaña orgánica en lata o en frasco|O|O||D||1|Arándano rojo montaña orgánico en lata o en frasco
50372708|Arandano pilgrim orgánica en lata o en frasco|O|O||D||1|Arándano rojo pilgrim orgánico en lata o en frasco
50372709|Arandano searless orgánica en lata o en frasco|O|O||D||1|Arándano rojo searless orgánico en lata o en frasco
50372710|Arandano stevens orgánica en lata o en frasco|O|O||D||1|Arándano rojo stevens orgánico en lata o en frasco
50372800|pasas de Corinto orgánicas en lata o en frasco|O|O||D||1
50372801|Pasa hudson bay orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto hudson bay orgánica en lata o en frasco
50372802|Pasa waxy orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto waxy orgánica en lata o en frasco
50372803|Pasa desierto orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto desierto orgánica en lata o en frasco
50372804|Pasa negra orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto negra orgánica en lata o en frasco
50372805|Pasa roja orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto roja orgánica en lata o en frasco
50372806|Pasa blanca orgánica en lata o en frasco|O|O||D||1|Pasa de Corinto blanca orgánica en lata o en frasco
50372900|Dátiles orgánicos en lata o en frasco|O|O||D||1
50372901|Dátiles asharasi  orgánica en lata o en frasco|O|O||D||1
50372902|Dátiles barhi o barhee orgánica en lata o en frasco|O|O||D||1
50372903|Dátiles deglet noor orgánica en lata o en frasco|O|O||D||1
50372904|Dátiles fardh orgánica en lata o en frasco|O|O||D||1
50372905|Dátiles gundila orgánica en lata o en frasco|O|O||D||1
50372906|Dátiles halawi/halawy orgánica en lata o en frasco|O|O||D||1
50372907|Dátiles hilali orgánica en lata o en frasco|O|O||D||1
50372908|Dátiles khadrawi/khadrawy orgánica en lata o en frasco|O|O||D||1
50372909|Dátiles khalas orgánica en lata o en frasco|O|O||D||1
50372910|Dátiles khustawi orgánica en lata o en frasco|O|O||D||1
50372911|Dátiles khidri orgánica en lata o en frasco|O|O||D||1
50372912|Dátiles medjool/ medjol orgánica en lata o en frasco|O|O||D||1
50372913|Dátiles mactoum orgánica en lata o en frasco|O|O||D||1
50372914|Dátiles neghal orgánica en lata o en frasco|O|O||D||1
50372915|Dátiles yatimeh orgánica en lata o en frasco|O|O||D||1
50372916|Dátiles zahidi orgánica en lata o en frasco|O|O||D||1
50373000|Pitahayas orgánicas en lata o en frasco|O|O||D||1
50373001|Pitahaya roja, rosada orgánica en lata o en frasco|O|O||D||1
50373002|Pitahaya roja, amarillo orgánica en lata o en frasco|O|O||D||1
50373100|Brevas orgánicas en lata o en frasco|O|O||D||1|Higos orgánicos en lata o en frasco
50373101|Breva bardajic orgánica en lata o en frasco|O|O||D||1|Higo bardajic orgánico en lata o en frasco
50373102|Breva brown turkey orgánica en lata o en frasco|O|O||D||1|Higo brown turkey orgánico en lata o en frasco
50373103|Breva calimyma  orgánica en lata o en frasco|O|O||D||1|Higo calimyma orgánico en lata o en frasco
50373104|Breva conadria orgánica en lata o en frasco|O|O||D||1|Higo conadria orgánico en lata o en frasco
50373105|Breva dotado orgánica en lata o en frasco|O|O||D||1|Higo dotado orgánico en lata o en frasco
50373106|Breva kadota orgánica en lata o en frasco|O|O||D||1|Higo kadota orgánico en lata o en frasco
50373107|Breva mediterránea orgánica en lata o en frasco|O|O||D||1|Higo mediterránea orgánico en lata o en frasco
50373108|Breva misión orgánica en lata o en frasco|O|O||D||1|Higo misión orgánico en lata o en frasco
50373109|Breva amyma orgánica en lata o en frasco|O|O||D||1|Higo amyma orgánico en lata o en frasco
50373110|Breva verdona orgánica en lata o en frasco|O|O||D||1|Higo verdona orgánico en lata o en frasco
50373111|Breva rey blanco orgánica en lata o en frasco|O|O||D||1|Higo rey blanco orgánico en lata o en frasco
50373200|Grosellas orgánicas en lata o en frasco|O|O||D||1
50373201|Grosella early sulphur orgánica en lata o en frasco|O|O||D||1
50373202|Grosella goldendrop orgánica en lata o en frasco|O|O||D||1
50373203|Grosella langley grace orgánica en lata o en frasco|O|O||D||1
50373204|Grocella leveller orgánica en lata o en frasco|O|O||D||1
50373205|Grosella london orgánica en lata o en frasco|O|O||D||1
50373206|Grosella worcestershire orgánica en lata o en frasco|O|O||D||1
50373207|Grosella americana worcesterberry orgánic|O|O||D||1
50373300|Toronjas orgánicas en lata o en frasco|O|O||D||1
50373301|Toronja burgundi orgánica en lata o en frasco|O|O||D||1
50373302|Toronja duncan orgánica en lata o en frasco|O|O||D||1
50373303|Toronja foster orgánica en lata o en frasco|O|O||D||1
50373304|Toronja marsh orgánica en lata o en frasco|O|O||D||1
50373305|Toronja nueva zelandia orgánica en lata o en frasco|O|O||D||1
50373306|Toronja rio rojo orgánica en lata o en frasco|O|O||D||1
50373307|Toronja ruby rojo orgánica en lata o en frasco|O|O||D||1
50373308|Toronja star ruby orgánica en lata o en frasco|O|O||D||1
50373309|Toronja triunfo orgánica en lata o en frasco|O|O||D||1
50373400|Uvas de mesa orgánicas en lata o en frasco|O|O||D||1
50373401|Uva alicante orgánica en lata o en frasco|O|O||D||1
50373402|Uva almeira orgánica en lata o en frasco|O|O||D||1
50373403|Uva alphonse lavalle orgánica en lata o en frasco|O|O||D||1
50373404|Uva otoñoking grapes orgánica en lata o en frasco|O|O||D||1
50373405|Uva autum royal orgánica en lata o en frasco|O|O||D||1
50373406|Uva autum sin pepa orgánica en lata o en frasco|O|O||D||1
50373407|Uva baresana orgánica en lata o en frasco|O|O||D||1
50373408|Uva barlinka orgánica en lata o en frasco|O|O||D||1
50373409|Uva belleza sin pepa orgánica en lata o en frasco|O|O||D||1
50373410|Uva black beauty sin pepa orgánica en lata o en frasco|O|O||D||1
50373411|Uva black esmeralda orgánica en lata o en frasco|O|O||D||1
50373412|Uva gigante negra orgánica en lata o en frasco|O|O||D||1
50373413|Uva globo negro orgánica en lata o en frasco|O|O||D||1
50373414|Uva negra monnukka orgánica en lata o en frasco|O|O||D||1
50373415|Uva black pearl orgánica en lata o en frasco|O|O||D||1
50373416|Uva black sin pepa orgánica en lata o en frasco|O|O||D||1
50373417|Uva bonheur orgánica en lata o en frasco|O|O||D||1
50373418|Uva calmeria orgánica en lata o en frasco|O|O||D||1
50373419|Uva cardinal orgánica en lata o en frasco|O|O||D||1
50373420|Uva catawba orgánica en lata o en frasco|O|O||D||1
50373421|Uva chasselas/dorado chasselas orgánica en lata o en frasco|O|O||D||1
50373422|Uva christmas rose orgánica en lata o en frasco|O|O||D||1
50373423|Uva concord orgánica en lata o en frasco|O|O||D||1
50373424|Uva concord sin pepa orgánica en lata o en frasco|O|O||D||1
50373425|Uva crimson sin pepa orgánica en lata o en frasco|O|O||D||1
50373426|Uva dauphine  orgánica en lata o en frasco|O|O||D||1
50373427|Uva daleware orgánica en lata o en frasco|O|O||D||1
50373428|Uva early muscat orgánica en lata o en frasco|O|O||D||1
50373429|Uva early sweet orgánica en lata o en frasco|O|O||D||1
50373430|Uva esmeralda sin pepa orgánica en lata o en frasco|O|O||D||1
50373431|Uva emperatriz orgánica en lata o en frasco|O|O||D||1
50373432|Uva emperador orgánica en lata o en frasco|O|O||D||1
50373433|Uva empres orgánica en lata o en frasco|O|O||D||1
50373434|Uva exótica orgánica en lata o en frasco|O|O||D||1
50373435|Uva fantasía orgánica en lata o en frasco|O|O||D||1
50373436|Uva fantasia sin pepa orgánica en lata o en frasco|O|O||D||1
50373437|Uva llama orgánica en lata o en frasco|O|O||D||1
50373438|Uva llama sin pepa orgánica en lata o en frasco|O|O||D||1
50373439|Uva llama tokay orgánica en lata o en frasco|O|O||D||1
50373440|Uva flaming red orgánica en lata o en frasco|O|O||D||1
50373441|Uva galaxia sin pepa orgánica en lata o en frasco|O|O||D||1
50373442|Uva gamay orgánica en lata o en frasco|O|O||D||1
50373443|Uva dorada orgánica en lata o en frasco|O|O||D||1
50373444|Uva miel o honeypot orgánica en lata o en frasco|O|O||D||1
50373445|Uva italia orgánica en lata o en frasco|O|O||D||1
50373446|Uva jade sin pepa orgánica en lata o en frasco|O|O||D||1
50373447|Uva jubilee orgánica en lata o en frasco|O|O||D||1
50373448|Uva king ruby orgánica en lata o en frasco|O|O||D||1
50373449|Uva kyoho orgánica en lata o en frasco|O|O||D||1
50373450|Uva la rochelle orgánica en lata o en frasco|O|O||D||1
50373451|Uva dedo de dama orgánica en lata o en frasco|O|O||D||1
50373452|Uva late sin pepa orgánica en lata o en frasco|O|O||D||1
50373453|Uva majestic sin pepa orgánica en lata o en frasco|O|O||D||1
50373454|Uva malaga orgánica en lata o en frasco|O|O||D||1
50373455|Uva marro sin pepa orgánica en lata o en frasco|O|O||D||1
50373456|Uva muscadine orgánica en lata o en frasco|O|O||D||1
50373457|Uva muscat llama orgánica en lata o en frasco|O|O||D||1
50373458|Uva muscat orgánica en lata o en frasco|O|O||D||1
50373459|Uva muscat sin papa orgánica en lata o en frasco|O|O||D||1
50373460|Uva napoleon orgánica en lata o en frasco|O|O||D||1
50373461|Uva nigeria orgánica en lata o en frasco|O|O||D||1
50373462|Uva new cross orgánica en lata o en frasco|O|O||D||1
50373463|Uva nibella orgánica en lata o en frasco|O|O||D||1
50373464|Uva niagara orgánica en lata o en frasco|O|O||D||1
50373465|Uva olivette orgánica en lata o en frasco|O|O||D||1
50373466|Uva perlette orgánica en lata o en frasco|O|O||D||1
50373467|Uva perlon orgánica en lata o en frasco|O|O||D||1
50373468|Uva prima black sin pepa orgánica en lata o en frasco|O|O||D||1
50373469|Uva principe orgánica en lata o en frasco|O|O||D||1
50373470|Uva reina orgánica en lata o en frasco|O|O||D||1
50373471|Uva roja blush orgánica en lata o en frasco|O|O||D||1
50373472|Uva roja globo orgánica en lata o en frasco|O|O||D||1
50373473|Uva roja malaga orgánica en lata o en frasco|O|O||D||1
50373474|Uva roja sin pepa orgánica en lata o en frasco|O|O||D||1
50373475|Uva regina orgánica en lata o en frasco|O|O||D||1
50373476|Uva ribier orgánica en lata o en frasco|O|O||D||1
50373477|Uva rosita orgánica en lata o en frasco|O|O||D||1
50373478|Uva rouge orgánica en lata o en frasco|O|O||D||1
50373479|Uva royal negra sin pepa orgánica en lata o en frasco|O|O||D||1
50373480|Uva ruby roja sin pepa orgánica en lata o en frasco|O|O||D||1
50373481|Uva ryby sin pepa orgánica en lata o en frasco|O|O||D||1
50373482|Uva scarlet royal orgánica en lata o en frasco|O|O||D||1
50373483|Uva scuppemong orgánica en lata o en frasco|O|O||D||1
50373484|Uva sugarose orgánica en lata o en frasco|O|O||D||1
50373485|Uva sugartirteen orgánica en lata o en frasco|O|O||D||1
50373486|Uva sugraone orgánica en lata o en frasco|O|O||D||1
50373487|Uva sugrasixteen orgánica en lata o en frasco|O|O||D||1
50373488|Uva sultana sun roja orgánica en lata o en frasco|O|O||D||1
50373489|Uva verano royal orgánica en lata o en frasco|O|O||D||1
50373490|Uva atardecer orgánica en lata o en frasco|O|O||D||1
50373491|Uva superior sin pepa orgánica en lata o en frasco|O|O||D||1
50373492|Uva thompson sin pepa orgánica en lata o en frasco|O|O||D||1
50373493|Uva tokaylpinot gris orgánica en lata o en frasco|O|O||D||1
50373494|Uva waltman cross orgánica en lata o en frasco|O|O||D||1
50373495|Uva blanca sin pepa orgánica en lata o en frasco|O|O||D||1
50373496|Uva zante current orgánica en lata o en frasco|O|O||D||1
50373500|Uvas pasas orgánicas en lata o en frasco|O|O||D||1
50373501|Uva corinth negra orgánica en lata o en frasco|O|O||D||1
50373502|Uva canner orgánica en lata o en frasco|O|O||D||1
50373503|Uva dovine orgánica en lata o en frasco|O|O||D||1
50373504|Uva fiesta orgánica en lata o en frasco|O|O||D||1
50373505|Uva selme pete orgánica en lata o en frasco|O|O||D||1
50373506|Uva sultana orgánica en lata o en frasco|O|O||D||1
50373600|Uvas para vino orgánicas en lata o en frasco|O|O||D||1
50373601|Uva licante bouschet orgánica en lata o en frasco|O|O||D||1
50373602|Uva barbera orgánica en lata o en frasco|O|O||D||1
50373603|Uva burger orgánica en lata o en frasco|O|O||D||1
50373604|Uva cabemet franc orgánica en lata o en frasco|O|O||D||1
50373605|Uva cabenet sauvignon orgánica en lata o en frasco|O|O||D||1
50373606|Uva carignane orgánica en lata o en frasco|O|O||D||1
50373607|Uva camelian orgánica en lata o en frasco|O|O||D||1
50373608|Uva cattarrato orgánica en lata o en frasco|O|O||D||1
50373609|Uva centurian orgánica en lata o en frasco|O|O||D||1
50373610|Uva charbono orgánica en lata o en frasco|O|O||D||1
50373611|Uva chardonnay orgánica en lata o en frasco|O|O||D||1
50373612|Uva chenin blanco orgánica en lata o en frasco|O|O||D||1
50373613|Uva cinsaut orgánica en lata o en frasco|O|O||D||1
50373614|Uva dolcetto orgánica en lata o en frasco|O|O||D||1
50373615|Uva emerald riesling orgánica en lata o en frasco|O|O||D||1
50373616|Uva frances colombard orgánica en lata o en frasco|O|O||D||1
50373617|Uva granny nap orgánica en lata o en frasco|O|O||D||1
50373618|Uva gamay beaujolais orgánica en lata o en frasco|O|O||D||1
50373619|Uva gewurztraminer orgánica en lata o en frasco|O|O||D||1
50373620|Uva grnache orgánica en lata o en frasco|O|O||D||1
50373621|Uva grinache blanc orgánica en lata o en frasco|O|O||D||1
50373622|Uva lagrein orgánica en lata o en frasco|O|O||D||1
50373623|Uva lambruso orgánica en lata o en frasco|O|O||D||1
50373624|Uva malbec orgánica en lata o en frasco|O|O||D||1
50373625|Uva malvasía bianca orgánica en lata o en frasco|O|O||D||1
50373626|Uva marsanne orgánica en lata o en frasco|O|O||D||1
50373627|Uva matano orgánica en lata o en frasco|O|O||D||1
50373628|Uva merlot orgánica en lata o en frasco|O|O||D||1
50373629|Uva meunier orgánica en lata o en frasco|O|O||D||1
50373630|Uva missiom orgánica en lata o en frasco|O|O||D||1
50373631|Uva montepulceano orgánica en lata o en frasco|O|O||D||1
50373632|Uva muscat blanc orgánica en lata o en frasco|O|O||D||1
50373633|Uva muscat hamburg orgánica en lata o en frasco|O|O||D||1
50373634|Uva muscat alexandria orgánica en lata o en frasco|O|O||D||1
50373635|Uva muscat naranja orgánica en lata o en frasco|O|O||D||1
50373636|Uva nebbiolo orgánica en lata o en frasco|O|O||D||1
50373637|Uva palomino orgánica en lata o en frasco|O|O||D||1
50373638|Uva petit verdor orgánica en lata o en frasco|O|O||D||1
50373639|Uva petit sirah orgánica en lata o en frasco|O|O||D||1
50373640|Uva pinot blanc orgánica en lata o en frasco|O|O||D||1
50373641|Uva pinot gris orgánica en lata o en frasco|O|O||D||1
50373642|Uva pinot noir orgánica en lata o en frasco|O|O||D||1
50373643|Uva primitivo orgánica en lata o en frasco|O|O||D||1
50373644|Uva roussane orgánica en lata o en frasco|O|O||D||1
50373645|Uva real  orgánica en lata o en frasco|O|O||D||1
50373646|Uva rubired orgánica en lata o en frasco|O|O||D||1
50373647|Uva ruby cabenet orgánica en lata o en frasco|O|O||D||1
50373648|Uva salvador orgánica en lata o en frasco|O|O||D||1
50373649|Uva sangiovese orgánica en lata o en frasco|O|O||D||1
50373650|Uva sauvignon blanc orgánica en lata o en frasco|O|O||D||1
50373651|Uva sauvignon musque orgánica en lata o en frasco|O|O||D||1
50373652|Uva semillon orgánica en lata o en frasco|O|O||D||1
50373653|Uva souzao orgánica en lata o en frasco|O|O||D||1
50373654|Uva st emilion orgánica en lata o en frasco|O|O||D||1
50373655|Uva symohony orgánica en lata o en frasco|O|O||D||1
50373656|Uva syrah  orgánica en lata o en frasco|O|O||D||1
50373657|Uva tannat orgánica en lata o en frasco|O|O||D||1
50373658|Uva temoranillo orgánica en lata o en frasco|O|O||D||1
50373659|Uvas teroldego orgánica en lata o en frasco|O|O||D||1
50373660|Uvas tocai friulano orgánica en lata o en frasco|O|O||D||1
50373661|Uvas touriga nacional orgánica en lata o en frasco|O|O||D||1
50373662|Uvas triplett blanc orgánica en lata o en frasco|O|O||D||1
50373663|Uvas viogner orgánica en lata o en frasco|O|O||D||1
50373664|Uvas white riesling orgánica en lata o en frasco|O|O||D||1
50373665|Uvas zinfandel orgánica en lata o en frasco|O|O||D||1
50373700|Guayabas orgánicas en lata o en frasco|O|O||D||1
50373701|Guayabas beaumont orgánica en lata o en frasco|O|O||D||1
50373702|Guayabas carrley orgánica en lata o en frasco|O|O||D||1
50373703|Guayabas lucida orgánica en lata o en frasco|O|O||D||1
50373704|Guayaba piña orgánica en lata o en frasco|O|O||D||1
50373800|Arándanos Huckleberry orgánicos en lata o en frasco|O|O||D||1|Arándanos azules orgánicos en lata o en frasco
50373801|Arándano invierno negro orgánico en lata o en frasco|O|O||D||1|Arándano azul invierno negro orgánico en lata o en frasco
50373802|Arándano cascada orgánico en lata o en frasco|O|O||D||1|Arándano azul cascada orgánico en lata o en frasco
50373803|Arándano enano orgánico en lata o en frasco|O|O||D||1|Arándano azul enano orgánico en lata o en frasco
50373804|Arándano montaña orgánico en lata o en frasco|O|O||D||1|Arándano azul montaña orgánico en lata o en frasco
50373805|Arándano rojo orgánico en lata o en frasco|O|O||D||1|Arándano azul red orgánico en lata o en frasco
50373900|Kiwis orgánicos en lata o en frasco|O|O||D||1
50373901|Fruta de kiwi ananasnaja orgánica en lata o en frasco|O|O||D||1|Kiwi ananasnaja orgánico en lata o en frasco
50373902|Fruta de kiwi belleza del ártico orgánica en lata o en frasco|O|O||D||1|Kiwi belleza del ártico orgánico en lata o en frasco
50373903|Fruta de kiwi blake orgánica en lata o en frasco|O|O||D||1|Kiwi blake orgánico en lata o en frasco
50373904|Fruta de kiwi hayward orgánica en lata o en frasco|O|O||D||1|Kiwi hayward orgánico en lata o en frasco
50373905|Fruta de kiwi issai orgánica en lata o en frasco|O|O||D||1|Kiwi issai orgánico en lata o en frasco
50373906|Fruta de kiwi siberiana orgánica en lata o en frasco|O|O||D||1|Kiwi siberiano orgánico en lata o en frasco
50374000|Naranjos Chinos (kumquats) orgánicos en lata o en frasco|O|O||D||1
50374001|Naranjo chino hong kong orgánico en lata o en frasco|O|O||D||1
50374002|Naranjo chino limequat orgánico en lata o en frasco|O|O||D||1
50374003|Naranjo long fruit orgánico en lata o en frasco|O|O||D||1|Naranjo chino long fruit orgánico en lata o en frasco
50374004|Naranjo chino malayan orgánico en lata o en frasco|O|O||D||1
50374005|Naranjo meiwa orgánico en lata o en frasco|O|O||D||1|Naranjo chino meiwa orgánico en lata o en frasco
50374006|Naranja chino nagami orgánico en lata o en frasco|O|O||D||1|Naranjo chino nagami orgánico en lata o en frasco
50374100|Limones orgánicos en lata o en frasco|O|O||D||1
50374101|Limón baboon orgánico en lata o en frasco|O|O||D||1
50374102|Limón bearss sicilian orgánico en lata o en frasco|O|O||D||1
50374103|Limón cameron highland orgánico en lata o en frasco|O|O||D||1
50374104|Limón escondido orgánico en lata o en frasco|O|O||D||1
50374105|Limón eureka orgánico en lata o en frasco|O|O||D||1
50374106|Limón lisbon orgánico en lata o en frasco|O|O||D||1
50374107|Limón meyer orgánico en lata o en frasco|O|O||D||1
50374108|Limón volkaner orgánico en lata o en frasco|O|O||D||1
50374200|Limas orgánicas en lata o en frasco|O|O||D||1
50374201|Lima limón indian sweet orgánico en lata o en frasco|O|O||D||1
50374202|Lima limón orgánico en lata o en frasco|O|O||D||1
50374203|Lima limón mandarin orgánico en lata o en frasco|O|O||D||1
50374204|Lima limón philippine orgánico en lata o en frasco|O|O||D||1
50374205|Lima limón tahitian orgánico en lata o en frasco|O|O||D||1
50374206|Lima limón bearss orgánico en lata o en frasco|O|O||D||1
50374207|Lima limón persa orgánico en lata o en frasco|O|O||D||1
50374208|Lima limón sin pepas orgánico en lata o en frasco|O|O||D||1|Lima limón sin semillas orgánico en lata o en frasco
50374300|Nísperos orgánicos en lata o en frasco|O|O||D||1
50374301|Níspero advance orgánico en lata o en frasco|O|O||D||1
50374302|Níspero benlehr orgánico en lata o en frasco|O|O||D||1
50374303|Níspero big jim orgánico en lata o en frasco|O|O||D||1
50374304|Níspero champagne orgánico en lata o en frasco|O|O||D||1
50374305|Níspero early rojo orgánico en lata o en frasco|O|O||D||1
50374306|Níspero nuget dorado orgánico en lata o en frasco|O|O||D||1
50374307|Níspero herd´s mammoth orgánico en lata o en frasco|O|O||D||1
50374308|Níspero mogi orgánico en lata o en frasco|O|O||D||1
50374309|Níspero mrs cooksey orgánico en lata o en frasco|O|O||D||1
50374310|Níspero fresa orgánico en lata o en frasco|O|O||D||1
50374311|Níspero tanaka orgánico en lata o en frasco|O|O||D||1
50374312|Níspero victoria vista blanco orgánico en lata o en frasco|O|O||D||1
50374313|Níspero wolfe orgánico en lata o en frasco|O|O||D||1
50374400|Mandarinas orgánicas en lata o en frasco|O|O||D||1
50374401|Naranjas clauselinas orgánica en lata o en frascos en lata o en frasco|O|O||D||1
50374402|Mandarinas clementinas orgánica en lata o en frascos en lata o en frasco|O|O||D||1
50374403|Naranja mandarina cleopatra|O|O||D||1
50374404|Mandarina dancy orgánica en lata o en frasco|O|O||D||1
50374405|Naranja ellensday orgánica en lata o en frasco|O|O||D||1
50374406|Naranja fairchild orgánica en lata o en frasco|O|O||D||1
50374407|Naranja fallglo orgánica en lata o en frasco|O|O||D||1
50374408|Naranja fortuna orgánica en lata o en frasco|O|O||D||1
50374409|Mandarina naranja fremont orgánica en lata o en frasco|O|O||D||1
50374410|Naranja fremont orgánica en lata o en frasco|O|O||D||1
50374411|Naranja nuget dorada orgánica en lata o en frasco|O|O||D||1
50374412|Mandarina naranja miel orgánica en lata o en frasco|O|O||D||1
50374413|Naranja miel orgánica en lata o en frasco|O|O||D||1
50374414|Mandarina miel orgánica en lata o en frasco|O|O||D||1
50374415|Natanja tanjelo honebelle orgánica en lata o en frasco|O|O||D||1|Naranja tangelo honebelle orgánica en lata o en frasco
50374416|Naranja mandarina rey orgánica en lata o en frasco|O|O||D||1
50374417|Naranja kinnow orgánica en lata o en frasco|O|O||D||1
50374418|Naranja andarinalee orgánica en lata o en frasco|O|O||D||1
50374419|Naranja makokkee orgánica en lata o en frasco|O|O||D||1
50374420|Naranja malvasion orgánica en lata o en frasco|O|O||D||1
50374421|Naranja mandarina mediterránea orgánica en lata o en frasco|O|O||D||1
50374422|Naranja tangelo minneola orgánica en lata o en frasco|O|O||D||1
50374423|Naranja monica orgánica en lata o en frasco|O|O||D||1
50374424|Naranja murcott miel orgánica en lata o en frasco|O|O||D||1
50374425|Naranja murcott tangors orgánica en lata o en frasco|O|O||D||1
50374426|Naranja mandarina natsudaidai  orgánica en lata o en frasco|O|O||D||1
50374427|Naranja mandarina natsumikan orgánica en lata o en frasco|O|O||D||1
50374428|Naranja tanjelo nocatee orgánica en lata o en frasco|O|O||D||1
50374429|Naranja tanjelo orlando orgánica en lata o en frasco|O|O||D||1
50374430|Mandarina ortanique orgánica en lata o en frasco|O|O||D||1
50374431|Naranja mandarina pagina orgánica en lata o en frasco|O|O||D||1
50374432|Naranja pixie orgánica en lata o en frasco|O|O||D||1
50374433|Naranja mandarina ponkan bantangas orgánica en lata o en frasco|O|O||D||1
50374434|Naranja reina orgánica en lata o en frasco|O|O||D||1
50374435|Naranja robinson orgánica en lata o en frasco|O|O||D||1
50374436|Naranja saltenitas orgánica en lata o en frasco|O|O||D||1
50374437|Naranja tangelo sampson orgánica en lata o en frasco|O|O||D||1
50374438|Naranja mandarina satsuma orgánica en lata o en frasco|O|O||D||1
50374439|Naranja mandarina sunburst orgánica en lata o en frasco|O|O||D||1
50374440|Tangelo orgánico en lata o en frasco|O|O||D||1
50374441|Naranja mandarina orgánica en lata o en frasco|O|O||D||1
50374442|Naranja templo orgánica en lata o en frasco|O|O||D||1
50374443|Naranja thornton orgánica en lata o en frasco|O|O||D||1
50374444|Mandarina wekiwa orgánica en lata o en frasco|O|O||D||1
50374445|Mandarina wilkins orgánica en lata o en frasco|O|O||D||1
50374446|Mandarina willowleaf mediterránea orgánica en lata o en frasco|O|O||D||1
50374500|Mangos orgánicos en lata o en frasco|O|O||D||1
50374501|Mango alphonso orgánico en lata o en frasco|O|O||D||1
50374502|Mango ataulfo orgánico en lata o en frasco|O|O||D||1
50374503|Mango criollo orgánico en lata o en frasco|O|O||D||1
50374504|Mango edwards orgánico en lata o en frasco|O|O||D||1
50374505|Mango francine orgánico en lata o en frasco|O|O||D||1
50374506|Mango francis orgánico en lata o en frasco|O|O||D||1
50374507|Mango gandaria orgánico en lata o en frasco|O|O||D||1
50374508|Mango haden orgánico en lata o en frasco|O|O||D||1
50374509|Mangos irwin orgánico en lata o en frasco|O|O||D||1
50374510|Mangos keitt orgánico en lata o en frasco|O|O||D||1
50374511|Mangos kent orgánico en lata o en frasco|O|O||D||1
50374512|Mangos kesar orgánico en lata o en frasco|O|O||D||1
50374513|Mangos kuini orgánico en lata o en frasco|O|O||D||1
50374514|Mangos manila super orgánico en lata o en frasco|O|O||D||1
50374515|Mangos manila orgánico en lata o en frasco|O|O||D||1
50374516|Mangos mayaguez orgánico en lata o en frasco|O|O||D||1
50374517|Mangos mulgoba orgánico en lata o en frasco|O|O||D||1
50374518|Mangos oro orgánico en lata o en frasco|O|O||D||1
50374519|Mangos palmer orgánico en lata o en frasco|O|O||D||1
50374520|Mango parvin orgánico en lata o en frasco|O|O||D||1
50374521|Mango sandersha orgánico en lata o en frasco|O|O||D||1
50374522|Mangos sensation orgánico en lata o en frasco|O|O||D||1
50374523|Mango smith orgánico en lata o en frasco|O|O||D||1
50374524|Mango tomy atkin orgánico en lata o en frasco|O|O||D||1
50374525|Mango van dyke orgánico en lata o en frasco|O|O||D||1
50374600|Melones orgánicos en lata o en frasco|O|O||D||1
50374601|Melon allsweet orgánico en lata o en frasco|O|O||D||1
50374602|Melón athens orgánico en lata o en frasco|O|O||D||1
50374603|Melón diamante negro orgánico en lata o en frasco|O|O||D||1
50374604|Melón cal sweet orgánico en lata o en frasco|O|O||D||1
50374605|Melons cantaloupe orgánico en lata o en frasco|O|O||D||1
50374606|Melón carnical orgánico en lata o en frasco|O|O||D||1
50374607|Melón casaba orgánico en lata o en frasco|O|O||D||1
50374608|Melón cavaillon orgánico en lata o en frasco|O|O||D||1
50374609|Melón charentais orgánico en lata o en frasco|O|O||D||1
50374610|Sandia charleston gray orgánico en lata o en frasco|O|O||D||1
50374611|Melón crenshaw orgánico en lata o en frasco|O|O||D||1
50374612|Melón crimson sweet orgánico en lata o en frasco|O|O||D||1
50374613|Melón dixie lee orgánico en lata o en frasco|O|O||D||1
50374614|Melón eclipse orgánico en lata o en frasco|O|O||D||1
50374615|Melón ein dór  orgánico en lata o en frasco|O|O||D||1
50374616|Melón fiesta orgánico en lata o en frasco|O|O||D||1
50374617|Melón galia orgánico en lata o en frasco|O|O||D||1
50374618|Melón gaya orgánico en lata o en frasco|O|O||D||1
50374619|Melón hami orgánico en lata o en frasco|O|O||D||1
50374620|Melón miel dew orgánico en lata o en frasco|O|O||D||1
50374621|Melón hielo orgánico en lata o en frasco|O|O||D||1
50374622|Melón ida orgullo orgánico en lata o en frasco|O|O||D||1
50374623|Melón juan canary orgánico en lata o en frasco|O|O||D||1
50374624|Melón jubileo orgánico en lata o en frasco|O|O||D||1
50374625|Melón jubilación orgánico en lata o en frasco|O|O||D||1
50374626|Melón kaki / kakri orgánico en lata o en frasco|O|O||D||1
50374627|Melón kiwano orgánico en lata o en frasco|O|O||D||1
50374628|Melon koreano orgánico en lata o en frasco|O|O||D||1|Melón coreano orgánico en lata o en frasco
50374629|Melón long grey orgánico en lata o en frasco|O|O||D||1|Melón largo gris orgánico en lata o en frasco
50374630|Melón mayan orgánico en lata o en frasco|O|O||D||1
50374631|Melón micky lee orgánico en lata o en frasco|O|O||D||1
50374632|Melón mirage orgánico en lata o en frasco|O|O||D||1
50374633|Sandia luna y estrellas orgánico en lata o en frasco|O|O||D||1
50374634|Melón ogen orgánico en lata o en frasco|O|O||D||1
50374635|Melón patriot orgánico en lata o en frasco|O|O||D||1
50374636|Melón peacook orgánico en lata o en frasco|O|O||D||1
50374637|Melón pepino orgánico en lata o en frasco|O|O||D||1
50374638|Melón persian orgánico en lata o en frasco|O|O||D||1
50374639|Melón picnic orgánico en lata o en frasco|O|O||D||1
50374640|Melón piel de sapo orgánico en lata o en frasco|O|O||D||1
50374641|Melón piña orgánico en lata o en frasco|O|O||D||1
50374642|Melón quetzali orgánico en lata o en frasco|O|O||D||1
50374643|Melón goblin rojo orgánico en lata o en frasco|O|O||D||1
50374644|Melón regency orgánico en lata o en frasco|O|O||D||1
50374645|Melón royal mejestic orgánico en lata o en frasco|O|O||D||1
50374646|Melón royal star orgánico en lata o en frasco|O|O||D||1
50374647|Melón dulce royal orgánico en lata o en frasco|O|O||D||1
50374648|Malon santa claus orgánico en lata o en frasco|O|O||D||1|Melón piel de sapo orgánico en lata o en frasco, Melón santa claus orgánico en lata o en frasco
50374649|Melón sharlyn orgánico en lata o en frasco|O|O||D||1
50374650|Melón español orgánico en lata o en frasco|O|O||D||1
50374651|Melón sprite orgánic orgánico en lata o en frasco|O|O||D||1
50374652|Melón starbright orgánico en lata o en frasco|O|O||D||1
50374653|Melón stars and stripes orgánico en lata o en frasco|O|O||D||1
50374654|Melón bebe de azúcar orgánico en lata o en frasco|O|O||D||1
50374655|Sandia bebe de azúcar orgánica en lata o en frasco|O|O||D||1
50374656|Melón dulce sol orgánico en lata o en frasco|O|O||D||1
50374657|Sandia corazón dulce sin pepa orgánica en lata o en frasco|O|O||D||1
50374658|Melón tentación orgánico en lata o en frasco|O|O||D||1
50374659|Melón tigre bebe orgánico en lata o en frasco|O|O||D||1
50374660|Melón tuscan tipo orgánico en lata o en frasco|O|O||D||1
50374661|Sandia baby amarillo orgánica en lata o en frasco|O|O||D||1
50374700|Moras mulberry orgánicas en lata o en frasco|O|O||D||1|Zarzamoras mulberry orgánicas en lata o en frasco
50374701|Mora negra orgánica en lata o en frasco|O|O||D||1|Zarzamora negra orgánica en lata o en frasco
50374702|Mora blanca orgánica en lata o en frasco|O|O||D||1|Zarzamora blanca orgánica en lata o en frasco
50374800|Mirtos orgánicos en lata o en frasco|O|O||D||1|Arrayanes orgánicos en lata o en frasco
50374801|Mirto bog orgánico en lata o en frasco|O|O||D||1|Arrayán bog orgánico en lata o en frasco
50374900|Nectarinas orgánicos en lata o en frasco|O|O||D||1
50374901|Durazno april glo orgánico en lata o en frasco|O|O||D||1
50374902|Durazno arctic mist orgánico en lata o en frasco|O|O||D||1
50374903|Durazno artic snow orgánico en lata o en frasco|O|O||D||1
50374904|Durazno artic star orgánico en lata o en frasco|O|O||D||1
50374905|Durazno artic dulce orgánico en lata o en frasco|O|O||D||1
50374906|Durazno artic glo orgánico en lata o en frasco|O|O||D||1
50374907|Durazno agosto llama orgánico en lata o en frasco|O|O||D||1
50374908|Durazno  perla de agosto orgánico en lata o en frasco|O|O||D||1
50374909|Durazno agosto rojo orgánico en lata o en frasco|O|O||D||1
50374910|Durazno estrella de agosto orgánico en lata o en frasco|O|O||D||1
50374911|Durazno big john orgánico en lata o en frasco|O|O||D||1
50374912|Durazno perla brillante orgánico en lata o en frasco|O|O||D||1
50374913|Durazno diamante brillante orgánico en lata o en frasco|O|O||D||1
50374914|Durazno diamante rayo orgánico en lata o en frasco|O|O||D||1
50374915|Durazno earligo orgánico en lata o en frasco|O|O||D||1
50374916|Durazno diamante temprano orgánico en lata o en frasco|O|O||D||1
50374917|Durazno fairlane orgánico en lata o en frasco|O|O||D||1
50374918|Durazno fantasía orgánico en lata o en frasco|O|O||D||1
50374919|Durazno perla fuego orgánico en lata o en frasco|O|O||D||1
50374920|Durazno fuego dulce orgánico en lata o en frasco|O|O||D||1
50374921|Durazno flamekist orgánico en lata o en frasco|O|O||D||1
50374922|Durazno tipo plano orgánico en lata o en frasco|O|O||D||1
50374923|Durazno delicia de jardín orgánico en lata o en frasco|O|O||D||1
50374924|Durazno mina de oro orgánico en lata o en frasco|O|O||D||1
50374925|Durazno perla grande orgánico en lata o en frasco|O|O||D||1
50374926|Durazno hardired orgánico en lata o en frasco|O|O||D||1
50374927|Durazno miel de fuego orgánico en lata o en frasco|O|O||D||1
50374928|Durazno julio rojo orgánico en lata o en frasco|O|O||D||1
50374929|Durazno kay perla orgánico en lata o en frasco|O|O||D||1
50374930|Durazno key dulce orgánico en lata o en frasco|O|O||D||1
50374931|Durazno diamante mayo orgánico en lata o en frasco|O|O||D||1
50374932|Durazno mayfire orgánico en lata o en frasco|O|O||D||1
50374933|Durazno mayglo orgánico en lata o en frasco|O|O||D||1
50374934|Durazno mericrest orgánico en lata o en frasco|O|O||D||1
50374935|Durazno diamante rojo orgánico en lata o en frasco|O|O||D||1
50374936|Durazno oro rojo orgánico en lata o en frasco|O|O||D||1
50374937|Durazno jim rojo orgánico en lata o en frasco|O|O||D||1
50374938|Durazno roy rojo orgánico en lata o en frasco|O|O||D||1
50374939|Durazno rio rojo orgánico en lata o en frasco|O|O||D||1
50374940|Durazno diamante de rosa orgánico en lata o en frasco|O|O||D||1
50374941|Durazno rotal glo orgánico en lata o en frasco|O|O||D||1
50374942|Durazno diamante ryby orgánico en lata o en frasco|O|O||D||1
50374943|Durazno ruby dulce orgánico en lata o en frasco|O|O||D||1
50374944|Durazno joya ruddy orgánico en lata o en frasco|O|O||D||1
50374945|Durazno septiembre rojo orgánico en lata o en frasco|O|O||D||1
50374946|Durazno reina de nieve orgánico en lata o en frasco|O|O||D||1
50374947|Durazno primavera clara orgánico en lata o en frasco|O|O||D||1
50374948|Durazno primavera roja orgánico en lata o en frasco|O|O||D||1
50374949|Durazno verano rojiso orgánico en lata o en frasco|O|O||D||1
50374950|Durazno verano claro orgánico en lata o en frasco|O|O||D||1
50374951|Durazno verano diamante orgánico en lata o en frasco|O|O||D||1
50374952|Durazno verano fuego orgánico en lata o en frasco|O|O||D||1
50374953|Durazno verano grande orgánico en lata o en frasco|O|O||D||1
50374954|Durazno sunglo orgánico en lata o en frasco|O|O||D||1
50374955|Durazno fuego zee orgánico en lata o en frasco|O|O||D||1
50374956|Durazno zee glo orgánico en lata o en frasco|O|O||D||1
50374957|Durazno zeegrand orgánico en lata o en frasco|O|O||D||1
50375000|Naranjas orgánicas en lata o en frasco|O|O||D||1
50375001|Naranja áfrica agria orgánica en lata o en frasco|O|O||D||1
50375002|Naranja dulce amber orgánica en lata o en frasco|O|O||D||1
50375003|Naranja argentina agria orgánica en lata o en frasco|O|O||D||1
50375004|Naranja bahianinha orgánico en lata o en frasco|O|O||D||1
50375005|Naranja bergamot orgánica en lata o en frasco|O|O||D||1
50375006|Naranja berna orgánica en lata o en frasco|O|O||D||1
50375007|Naranja bigaradier apepu orgánica en lata o en frasco|O|O||D||1
50375008|Naranja agria dulce daidai orgánica en lata o en frasco|O|O||D||1
50375009|Naranja mono orgánica en lata o en frasco|O|O||D||1
50375010|Naranja sangre orgánica en lata o en frasco|O|O||D||1
50375011|Naranja california navel orgánica en lata o en frasco|O|O||D||1
50375012|Naranja cara cara orgánica en lata o en frasco|O|O||D||1
50375013|Naranja chinotto orgánica en lata o en frasco|O|O||D||1
50375014|Naranja sueño nevel orgánica en lata o en frasco|O|O||D||1
50375015|Naranja gou tou orgánica en lata o en frasco|O|O||D||1
50375016|Naranja hamlin orgánica en lata o en frasco|O|O||D||1
50375017|Naranja jaffa orgánica en lata o en frasco|O|O||D||1
50375018|Naranja jincheng orgánica en lata o en frasco|O|O||D||1
50375019|Naranja k-temprano orgánica en lata o en frasco|O|O||D||1
50375020|Naranja kona orgánica en lata o en frasco|O|O||D||1
50375021|Naranja navel tarde orgánica en lata o en frasco|O|O||D||1
50375022|Naranja valencia tarde orgánica en lata o en frasco|O|O||D||1
50375023|Naranja limequat orgánica en lata o en frasco|O|O||D||1
50375024|Naranja mar orgánica en lata o en frasco|O|O||D||1
50375025|Naranja malegold orgánica en lata o en frasco|O|O||D||1
50375026|Naranja moro orgánica en lata o en frasco|O|O||D||1
50375027|Naranja moro tabaco orgánica en lata o en frasco|O|O||D||1
50375028|Naranja navel orgánica en lata o en frasco|O|O||D||1
50375029|Naranja navelina orgánica en lata o en frasco|O|O||D||1
50375030|Naranja oro blanco orgánica en lata o en frasco|O|O||D||1
50375031|Naranja osceola orgánica en lata o en frasco|O|O||D||1
50375032|Naranja parson carmelito orgánica en lata o en frasco|O|O||D||1
50375033|Naranja pera orgánica en lata o en frasco|O|O||D||1
50375034|Naranjo pummulo orgánica en lata o en frasco|O|O||D||1|Naranja pummulo orgánica en lata o en frasco
50375035|Naranja rhode rojo orgánica en lata o en frasco|O|O||D||1
50375036|Naranja roble orgánica en lata o en frasco|O|O||D||1
50375037|Naranja salustianas orgánica en lata o en frasco|O|O||D||1
50375038|Naranja sanguine orgánica en lata o en frasco|O|O||D||1
50375039|Naranja sanguinelli orgánica en lata o en frasco|O|O||D||1
50375040|Naranja cevilla orgánica en lata o en frasco|O|O||D||1
50375041|Naranja shamouti jaffa orgánica en lata o en frasco|O|O||D||1
50375042|Naranja tunis orgánica en lata o en frasco|O|O||D||1
50375043|Naranja valencia orgánica en lata o en frasco|O|O||D||1
50375044|Naranja washington navel orgánica en lata o en frasco|O|O||D||1
50375100|Papayas orgánicas en lata o en frasco|O|O||D||1
50375101|Papaya verde cocinar orgánica en lata o en frasco|O|O||D||1
50375102|Papaya maradol orgánica en lata o en frasco|O|O||D||1
50375103|Papaya amarillo mexicano orgánica en lata o en frasco|O|O||D||1
50375104|Papaya montaña orgánica en lata o en frasco|O|O||D||1
50375105|Papaya solo orgánica en lata o en frasco|O|O||D||1
50375106|Papaya tainung orgánica en lata o en frasco|O|O||D||1
50375200|Maracuyás orgánicas en lata o en frasco|O|O||D||1
50375201|Fruta maracuyá banana orgánica en lata o en frasco|O|O||D||1|Curuba orgánica en lata o en frasco
50375202|Maracuyá flor azul orgánica en lata o en frasco|O|O||D||1|Maracuyá pasionaria azul orgánica en lata o en frasco
50375203|Maracuyá crackerjack orgánica en lata o en frasco|O|O||D||1
50375204|Maracuyá granadilla gigante orgánica en lata o en frasco|O|O||D||1
50375205|Maracuyá granadilla dorada orgánica en lata o en frasco|O|O||D||1
50375206|Maracuyá maypops orgánica en lata o en frasco|O|O||D||1
50375207|Maracuyá roja orgánica en lata o en frasco|O|O||D||1
50375208|Maracuyá granadilla dulce orgánica en lata o en frasco|O|O||D||1
50375209|Maracuyá sandia orgánica en lata o en frasco|O|O||D||1
50375210|Maracuyá  wing- steam orgánica en lata o en frasco|O|O||D||1
50375300|Duraznos orgánicos en lata o en frasco|O|O||D||1
50375301|Durazno escudo amber orgánico en lata o en frasco|O|O||D||1
50375302|Durazno nieve de abril orgánico en lata o en frasco|O|O||D||1
50375303|Durazno dama de agosto orgánico en lata o en frasco|O|O||D||1
50375304|Durazno llama de otoño orgánico en lata o en frasco|O|O||D||1
50375305|Durazno dama de otoño orgánico en lata o en frasco|O|O||D||1
50375306|Durazno babcock orgánico en lata o en frasco|O|O||D||1
50375307|Durazno brittany lane orgánico en lata o en frasco|O|O||D||1
50375308|Durazno cary mac orgánico en lata o en frasco|O|O||D||1
50375309|Durazno clásica orgánico en lata o en frasco|O|O||D||1
50375310|Durazno dulce del campo orgánico en lata o en frasco|O|O||D||1
50375311|Durazno escudo de cielo orgánico en lata o en frasco|O|O||D||1
50375312|Durazno dama crimson orgánico en lata o en frasco|O|O||D||1
50375313|Durazno príncipe corona orgánico en lata o en frasco|O|O||D||1
50375314|Durazno sol david orgánico en lata o en frasco|O|O||D||1
50375315|Durazno  princesa diamante orgánico en lata o en frasco|O|O||D||1
50375316|Durazno earlrich orgánico en lata o en frasco|O|O||D||1
50375317|Durazno majestuosa temprana orgánico en lata o en frasco|O|O||D||1
50375318|Durazno early treat orgánico en lata o en frasco|O|O||D||1
50375319|Durazno dama elegante orgánico en lata o en frasco|O|O||D||1
50375320|Durazno emperatriz orgánico en lata o en frasco|O|O||D||1
50375321|Durazno encoré orgánico en lata o en frasco|O|O||D||1
50375322|Durazno dama elegante orgánico en lata o en frasco|O|O||D||1
50375323|Durazno príncipe de fuego orgánico en lata o en frasco|O|O||D||1
50375324|Durazno escudo de llama orgánico en lata o en frasco|O|O||D||1
50375325|Durazno tipo plano orgánico en lata o en frasco|O|O||D||1
50375326|Durazno escudo de sabor orgánico en lata o en frasco|O|O||D||1
50375327|Durazno príncipe florida orgánico en lata o en frasco|O|O||D||1
50375328|Durazno luna llena orgánico en lata o en frasco|O|O||D||1
50375329|Durazno harvester orgánico en lata o en frasco|O|O||D||1
50375330|Durazno princesa de hielo orgánico en lata o en frasco|O|O||D||1
50375331|Durazno princesa de marfil orgánico en lata o en frasco|O|O||D||1
50375332|Durazno princesa reina jersey orgánico en lata o en frasco|O|O||D||1
50375333|Durazno john henry orgánico en lata o en frasco|O|O||D||1
50375334|Durazno príncipe de junio orgánico en lata o en frasco|O|O||D||1
50375335|Durazno kaweah orgánico en lata o en frasco|O|O||D||1
50375336|Durazno klondike orgánico en lata o en frasco|O|O||D||1
50375337|Durazno lindo orgánico en lata o en frasco|O|O||D||1
50375338|Durazno loring orgánico en lata o en frasco|O|O||D||1
50375339|Durazno majestuoso orgánico en lata o en frasco|O|O||D||1
50375340|Durazno o’henry orgánico en lata o en frasco|O|O||D||1
50375341|Durazno escudo de reina orgánico en lata o en frasco|O|O||D||1
50375342|Durazno dama roja orgánico en lata o en frasco|O|O||D||1
50375343|Durazno globo rojo orgánico en lata o en frasco|O|O||D||1
50375344|Durazno cielo rojo orgánico en lata o en frasco|O|O||D||1
50375345|Durazno redtop orgánico en lata o en frasco|O|O||D||1
50375346|Durazno regina orgánico en lata o en frasco|O|O||D||1
50375347|Durazno dama rica orgánico en lata o en frasco|O|O||D||1
50375348|Durazno mayo rico orgánico en lata o en frasco|O|O||D||1
50375349|Durazno gloria royal orgánico en lata o en frasco|O|O||D||1
50375350|Durazno dama royal orgánico en lata o en frasco|O|O||D||1
50375351|Durazno nieve de septiembre orgánico en lata o en frasco|O|O||D||1
50375352|Durazno sol de septiembre orgánico en lata o en frasco|O|O||D||1
50375353|Durazno gema sierra orgánico en lata o en frasco|O|O||D||1
50375354|Durazno angel de nieve orgánico en lata o en frasco|O|O||D||1
50375355|Durazno gema de nieve orgánico en lata o en frasco|O|O||D||1
50375356|Durazno rey de nieve orgánico en lata o en frasco|O|O||D||1
50375357|Durazno dama de primavera orgánico en lata o en frasco|O|O||D||1
50375358|Durazno nieve de primavera orgánico en lata o en frasco|O|O||D||1
50375359|Durazno escudo de primavera orgánico en lata o en frasco|O|O||D||1
50375360|Durazno dulce gigante orgánico en lata o en frasco|O|O||D||1
50375361|Durazno dama de azúcar orgánico en lata o en frasco|O|O||D||1
50375362|Durazno brillo de sol orgánico en lata o en frasco|O|O||D||1
50375363|Durazno sunhigh orgánico en lata o en frasco|O|O||D||1
50375364|Durazno dama super orgánico en lata o en frasco|O|O||D||1
50375365|Durazno super rico orgánico en lata o en frasco|O|O||D||1
50375366|Durazno surecrop orgánico en lata o en frasco|O|O||D||1
50375367|Durazno sueño dulce orgánico en lata o en frasco|O|O||D||1
50375368|Durazno septiembre dulce orgánico en lata o en frasco|O|O||D||1
50375369|Durazno vista orgánico en lata o en frasco|O|O||D||1
50375370|Durazno dama blanca orgánico en lata o en frasco|O|O||D||1
50375371|Durazno dama zee orgánico en lata o en frasco|O|O||D||1
50375400|Peras orgánicas en lata o en frasco|O|O||D||1
50375401|Peras abate fetel orgánica en lata o en frasco|O|O||D||1
50375402|Peras anjou orgánica en lata o en frasco|O|O||D||1
50375403|Pera asiática orgánica en lata o en frasco|O|O||D||1
50375404|Pera bartlett orgánica en lata o en frasco|O|O||D||1
50375405|Pera best ever orgánica en lata o en frasco|O|O||D||1
50375406|Pera beth orgánica en lata o en frasco|O|O||D||1
50375407|Pera beurre orgánica en lata o en frasco|O|O||D||1
50375408|Pera bosc orgánica en lata o en frasco|O|O||D||1
50375409|Pera clapp favorita orgánica en lata o en frasco|O|O||D||1
50375410|Pera comice orgánica en lata o en frasco|O|O||D||1
50375411|Pera concorde orgánica en lata o en frasco|O|O||D||1
50375412|Pera conference orgánica en lata o en frasco|O|O||D||1
50375413|Pera crimson rojo orgánica en lata o en frasco|O|O||D||1
50375414|Peras d’ anjou orgánica en lata o en frasco|O|O||D||1
50375415|Pera dr jules guyot orgánica en lata o en frasco|O|O||D||1
50375416|Peras early orgánica en lata o en frasco|O|O||D||1
50375417|Peras emperador carmelito orgánica en lata o en frasco|O|O||D||1
50375418|Peras forelle orgánica en lata o en frasco|O|O||D||1
50375419|Pera mantequilla francesa orgánica en lata o en frasco|O|O||D||1
50375420|Pera glou morceau orgánica en lata o en frasco|O|O||D||1
50375421|Pera hosui orgánica en lata o en frasco|O|O||D||1
50375422|Pera mantequilla italiana orgánica en lata o en frasco|O|O||D||1
50375423|Pera jargonelle orgánica en lata o en frasco|O|O||D||1
50375424|Pera juno orgánica en lata o en frasco|O|O||D||1
50375425|Para kaiserlouise bonne de jersey orgánica en lata o en frasco|O|O||D||1
50375426|Pera keiffer orgánica en lata o en frasco|O|O||D||1
50375427|Pera rey royal orgánica en lata o en frasco|O|O||D||1
50375428|Pera limonera orgánica en lata o en frasco|O|O||D||1
50375429|Pera merton pride orgánica en lata o en frasco|O|O||D||1
50375430|Pera mauntain bartlette orgánica en lata o en frasco|O|O||D||1
50375431|Pera oliver de serrers orgánica en lata o en frasco|O|O||D||1
50375432|Pera onward orgánica en lata o en frasco|O|O||D||1
50375433|Pera packham´s triumph orgánica en lata o en frasco|O|O||D||1
50375434|Pera paraíso orgánica en lata o en frasco|O|O||D||1
50375435|Pera passe crassane orgánica en lata o en frasco|O|O||D||1
50375436|Pera perry orgánica en lata o en frasco|O|O||D||1
50375437|Pera bartlette rojo orgánica en lata o en frasco|O|O||D||1
50375438|Pera dánjou  rojo orgánica en lata o en frasco|O|O||D||1
50375439|Pera rocha orgánica en lata o en frasco|O|O||D||1
50375440|Pera rosey rojo orgánica en lata o en frasco|O|O||D||1
50375441|Pera rosy roja orgánica en lata o en frasco|O|O||D||1
50375442|Pera majestuosa royal orgánica en lata o en frasco|O|O||D||1
50375443|Pera ruby rojo orgánica en lata o en frasco|O|O||D||1
50375444|Pera santa maria orgánica en lata o en frasco|O|O||D||1
50375445|Pera seckel orgánica en lata o en frasco|O|O||D||1
50375446|Pera sensación orgánica en lata o en frasco|O|O||D||1
50375447|Pera crimson estrella orgánica en lata o en frasco|O|O||D||1
50375448|Pera crimson stark orgánica en lata o en frasco|O|O||D||1
50375449|Pera bartlette de verano orgánica en lata o en frasco|O|O||D||1
50375450|Pera verano dorado orgánica en lata o en frasco|O|O||D||1
50375451|Pera sol dorado orgánica en lata o en frasco|O|O||D||1
50375452|Pera sunprite orgánica en lata o en frasco|O|O||D||1
50375453|Pera taylors dorado orgánica en lata o en frasco|O|O||D||1
50375454|Pera taylors rojo orgánica en lata o en frasco|O|O||D||1
50375455|Pera tientsin orgánica en lata o en frasco|O|O||D||1
50375456|Pera tosca orgánica en lata o en frasco|O|O||D||1
50375457|Pera warden  orgánica en lata o en frasco|O|O||D||1
50375458|Pera williams bon chretien orgánica en lata o en frasco|O|O||D||1
50375459|Pera williams orgánica en lata o en frasco|O|O||D||1
50375460|Pera nelis de invierno orgánica en lata o en frasco|O|O||D||1
50375500|Caquis orgánicos en lata o en frasco|O|O||D||1
50375501|Caqui americano orgánica en lata o en frasco|O|O||D||1
50375502|Caqui sapote negro orgánica en lata o en frasco|O|O||D||1|Caqui zapote negro orgánica en lata o en frasco
50375503|Caqui chapote / negro orgánica en lata o en frasco|O|O||D||1
50375504|Caqui dátale ciruela orgánica en lata o en frasco|O|O||D||1
50375505|Caqui fuyu orgánica en lata o en frasco|O|O||D||1
50375506|Caqui gigante fuyu orgánica en lata o en frasco|O|O||D||1
50375507|Caqui hachiya orgánica en lata o en frasco|O|O||D||1
50375508|Caqui mantequilla / mabolo orgánica en lata o en frasco|O|O||D||1
50375509|Caqui príncipe ito orgánica en lata o en frasco|O|O||D||1
50375510|Caqui brillante royal orgánica en lata o en frasco|O|O||D||1
50375511|Caqui sharon orgánica en lata o en frasco|O|O||D||1
50375512|Caqui triumph orgánica en lata o en frasco|O|O||D||1
50375600|Piñas orgánicas en lata o en frasco|O|O||D||1
50375601|Piña chirimoya orgánica en lata o en frasco|O|O||D||1|Atemoya orgánica en lata o en frasco
50375602|Piña dorada orgánica en lata o en frasco|O|O||D||1
50375603|Piña hilo orgánica en lata o en frasco|O|O||D||1
50375604|Piña kona sugarloaf orgánica en lata o en frasco|O|O||D||1
50375605|Piña reina natal orgánica en lata o en frasco|O|O||D||1
50375606|Piña pernabuco orgánica en lata o en frasco|O|O||D||1
50375607|Piña español rojo orgánica en lata o en frasco|O|O||D||1
50375608|Piña cayen suave orgánica en lata o en frasco|O|O||D||1
50375609|Piña sugarloaf orgánica en lata o en frasco|O|O||D||1
50375610|Piña variegated orgánica en lata o en frasco|O|O||D||1
50375700|Ciruelos Damascos orgánicos en lata o en frasco|O|O||D||1
50375701|Ciruelo / damasco negro kat orgánico en lata o en frasco|O|O||D||1
50375702|Ciruelo / damasco gusto azul orgánico en lata o en frasco|O|O||D||1
50375703|Ciruelo / damasco corazón de crimson orgánico en lata o en frasco|O|O||D||1
50375704|Ciruelo / damasco dapply dandy orgánico en lata o en frasco|O|O||D||1
50375705|Ciruelo / damasco dapple fuego orgánico en lata o en frasco|O|O||D||1
50375706|Ciruelo / damasco  dapple temprano orgánico en lata o en frasco|O|O||D||1
50375707|Ciruelo / damasco  caída de sabor orgánico en lata o en frasco|O|O||D||1
50375708|Ciruelo / damasco sabor de oro orgánico en lata o en frasco|O|O||D||1
50375709|Ciruelo / damasco sabor granada orgánico en lata o en frasco|O|O||D||1
50375710|Ciruelo / damasco sabor de corazón orgánico en lata o en frasco|O|O||D||1
50375711|Ciruelo / damasco joya de sabor orgánico en lata o en frasco|O|O||D||1
50375712|Ciruelo / damasco sabor de rey orgánico en lata o en frasco|O|O||D||1
50375713|Ciruelo / damasco sabor de reina orgánico en lata o en frasco|O|O||D||1
50375714|Ciruelo / damasco sabor supremo orgánico en lata o en frasco|O|O||D||1
50375715|Ciruelo / damasco sabor premio orgánico en lata o en frasco|O|O||D||1
50375716|Ciruelo / damasco saborella orgánico en lata o en frasco|O|O||D||1
50375717|Ciruelo / damasco saborrico orgánico en lata o en frasco|O|O||D||1
50375718|Ciruelo / damasco  sabor rosa orgánico en lata o en frasco|O|O||D||1
50375719|Ciruelo / damasco orgullo geo orgánico en lata o en frasco|O|O||D||1
50375720|Ciruelo / damasco kat rojo orgánico en lata o en frasco|O|O||D||1
50375721|Ciruelo / damasco premio royal orgánico en lata o en frasco|O|O||D||1
50375722|Ciruelo / damasco rosa sierra orgánico en lata o en frasco|O|O||D||1
50375723|Ciruelo / damasco geisha dulce orgánico en lata o en frasco|O|O||D||1
50375800|Ciruelas orgánicas en lata o en frasco|O|O||D||1
50375801|Ciruela joya amber orgánica en lata o en frasco|O|O||D||1
50375802|Ciruela angeleno orgánica en lata o en frasco|O|O||D||1
50375803|Ciruela aurora orgánica en lata o en frasco|O|O||D||1
50375804|Ciruela otoño bonito orgánica en lata o en frasco|O|O||D||1
50375805|Ciruela gigante de otoño orgánica en lata o en frasco|O|O||D||1
50375806|Ciruela orgullo de otoño orgánica en lata o en frasco|O|O||D||1
50375807|Ciruela rosa de otoño orgánica en lata o en frasco|O|O||D||1
50375808|Ciruela playero orgánica en lata o en frasco|O|O||D||1
50375809|Ciruela betty anne orgánica en lata o en frasco|O|O||D||1
50375810|Ciruela belleza negra orgánica en lata o en frasco|O|O||D||1
50375811|Ciruela bullase negra orgánica en lata o en frasco|O|O||D||1
50375812|Ciruela diamante negro orgánica en lata o en frasco|O|O||D||1
50375813|Ciruela gigante negro orgánica en lata o en frasco|O|O||D||1
50375814|Ciruela hielo negro orgánica en lata o en frasco|O|O||D||1
50375815|Ciruela esplendor negro orgánica en lata o en frasco|O|O||D||1
50375816|Ciruela ámbar negro orgánica en lata o en frasco|O|O||D||1
50375817|Ciruela purpura orgánica en lata o en frasco|O|O||D||1
50375818|Ciruela  carsbad orgánica en lata o en frasco|O|O||D||1
50375819|Ciruela casselman orgánica en lata o en frasco|O|O||D||1
50375820|Ciruela catalina orgánica en lata o en frasco|O|O||D||1
50375821|Ciruela damson orgánica en lata o en frasco|O|O||D||1
50375822|Ciruela dolly orgánica en lata o en frasco|O|O||D||1
50375823|Ciruela earliqueen orgánica en lata o en frasco|O|O||D||1
50375824|Ciruela rosa early orgánica en lata o en frasco|O|O||D||1
50375825|Ciruela ébano mayo orgánica en lata o en frasco|O|O||D||1
50375826|Ciruela ébano orgánica en lata o en frasco|O|O||D||1
50375827|Ciruela corazón de elefante orgánica en lata o en frasco|O|O||D||1
50375828|Ciruela belleza de esmeralda orgánica en lata o en frasco|O|O||D||1
50375829|Ciruela emperatriz orgánica en lata o en frasco|O|O||D||1
50375830|Ciruela libertad orgánica en lata o en frasco|O|O||D||1
50375831|Ciruela friar orgánica en lata o en frasco|O|O||D||1
50375832|Ciruela rojo gar orgánica en lata o en frasco|O|O||D||1
50375833|Ciruela gobernador orgánica en lata o en frasco|O|O||D||1
50375834|Ciruela rosa grande orgánica en lata o en frasco|O|O||D||1
50375835|Ciruela green gage orgánica en lata o en frasco|O|O||D||1|Ciruela calibre verde orgánica en lata o en frasco
50375836|Ciruela greengage orgánica en lata o en frasco|O|O||D||1
50375837|Ciruela hiromi orgánica en lata o en frasco|O|O||D||1
50375838|Ciruela hiromi rojo orgánica en lata o en frasco|O|O||D||1
50375839|Ciruela vacacion orgánica en lata o en frasco|O|O||D||1
50375840|Ciruela howard sol orgánica en lata o en frasco|O|O||D||1
50375841|Ciruela tipo interspecific orgánica en lata o en frasco|O|O||D||1
50375842|Ciruela jamaico orgánica en lata o en frasco|O|O||D||1
50375843|Ciruela joanna rojo orgánica en lata o en frasco|O|O||D||1
50375844|Ciruela kelsey orgánica en lata o en frasco|O|O||D||1
50375845|Ciruela jaime rey orgánica en lata o en frasco|O|O||D||1
50375846|Ciruela laroda orgánica en lata o en frasco|O|O||D||1
50375847|Ciruela rosa tarde orgánica en lata o en frasco|O|O||D||1
50375848|Ciruela rosa linda orgánica en lata o en frasco|O|O||D||1
50375849|Ciruela estrella solitaria orgánica en lata o en frasco|O|O||D||1
50375850|Ciruela mariposa orgánica en lata o en frasco|O|O||D||1
50375851|Ciruela mercado negro orgánica en lata o en frasco|O|O||D||1
50375852|Ciruela mercado rojo orgánica en lata o en frasco|O|O||D||1
50375853|Ciruela maribel orgánica en lata o en frasco|O|O||D||1
50375854|Ciruelas sol de octubre orgánica en lata o en frasco|O|O||D||1
50375855|Ciruela owen t orgánica en lata o en frasco|O|O||D||1
50375856|Ciruela perdrigon orgánica en lata o en frasco|O|O||D||1
50375857|Ciruela placer rosado orgánica en lata o en frasco|O|O||D||1
50375858|Ciruela  presidente orgánica en lata o en frasco|O|O||D||1
50375859|Ciruela hora prima orgánica en lata o en frasco|O|O||D||1|Ciruela prime time orgánica en lata o en frasco
50375860|Ciruela majestad purpura orgánica en lata o en frasco|O|O||D||1
50375861|Ciruela reina rosa orgánica en lata o en frasco|O|O||D||1
50375862|Ciruela quetsch orgánica en lata o en frasco|O|O||D||1
50375863|Ciruela belleza roja orgánica en lata o en frasco|O|O||D||1
50375864|Ciruela camino rojo orgánica en lata o en frasco|O|O||D||1
50375865|Ciruela ram rojo orgánica en lata o en frasco|O|O||D||1
50375866|Ciruela rosa roja orgánica en lata o en frasco|O|O||D||1
50375867|Ciruela rojo rico orgánica en lata o en frasco|O|O||D||1
50375868|Ciruela romero orgánica en lata o en frasco|O|O||D||1
50375869|Ciruela diamante rojo orgánica en lata o en frasco|O|O||D||1
50375870|Ciruela rojo royal orgánica en lata o en frasco|O|O||D||1
50375871|Ciruela royal zee orgánica en lata o en frasco|O|O||D||1
50375872|Ciruela roysum orgánica en lata o en frasco|O|O||D||1
50375873|Ciruela santa rosa orgánica en lata o en frasco|O|O||D||1
50375874|Ciruela zafiro orgánica en lata o en frasco|O|O||D||1
50375875|Ciruela sloe orgánica en lata o en frasco|O|O||D||1
50375876|Ciruela sta catherine orgánica en lata o en frasco|O|O||D||1
50375877|Ciruela bullase blanco orgánica en lata o en frasco|O|O||D||1
50375900|Granadas orgánicas en lata o en frasco|O|O||D||1
50375901|Granada foothhill orgánica en lata o en frasco|O|O||D||1
50375902|Granada, granada orgánica en lata o en frasco|O|O||D||1|Granada orgánica en lata o en frasco
50375903|Granada rojo feliz orgánica en lata o en frasco|O|O||D||1
50375904|Granada nana orgánica en lata o en frasco|O|O||D||1
50375905|Granada rojo de pat orgánica en lata o en frasco|O|O||D||1
50375906|Granada pinkhan orgánic|O|O||D||1
50375907|Granada terciopelo morado orgánica en lata o en frasco|O|O||D||1
50375908|Granada grandioso orgánica en lata o en frasco|O|O||D||1
50376000|Pomelos orgánicos en lata o en frasco|O|O||D||1
50376001|Pomelo chandler orgánico en lata o en frasco|O|O||D||1
50376002|Pomelo hirado butan orgánico en lata o en frasco|O|O||D||1
50376003|Pomelo liang ping yau orgánico en lata o en frasco|O|O||D||1
50376004|Pomelo panda wangi orgánico en lata o en frasco|O|O||D||1
50376005|Pomelo rosado orgánico en lata o en frasco|O|O||D||1
50376006|Pomelo shaddock rojo orgánico en lata o en frasco|O|O||D||1
50376007|Pomelo siamese dulce orgánico en lata o en frasco|O|O||D||1
50376008|Pomelo waingwright orgánico en lata o en frasco|O|O||D||1
50376100|Membrillos orgánicos en lata o en frasco|O|O||D||1
50376101|Membrillo campeón orgánico en lata o en frasco|O|O||D||1
50376102|Membrillo piña orgánico en lata o en frasco|O|O||D||1
50376103|Membrillo smyma orgánico en lata o en frasco|O|O||D||1
50376200|Frambuesas orgánicas en lata o en frasco|O|O||D||1
50376201|Frambuesa americana roja orgánica en lata o en frasco|O|O||D||1
50376202|Frambuesa bailey queensland orgánica en lata o en frasco|O|O||D||1
50376203|Frambuesa negra orgánica en lata o en frasco|O|O||D||1
50376204|Frambuesa oscura orgánica en lata o en frasco|O|O||D||1
50376205|Frambuesa deliciosa orgánica en lata o en frasco|O|O||D||1
50376206|Frambuesa enano focke orgánica en lata o en frasco|O|O||D||1
50376207|Frambuesa focke hojagris orgánica en lata o en frasco|O|O||D||1
50376208|Frambuesa focke fresa orgánica en lata o en frasco|O|O||D||1
50376209|Frambuesa  focke amarillo himalaya orgánica en lata o en frasco|O|O||D||1
50376210|Frambuesa dorado orgánica en lata o en frasco|O|O||D||1
50376211|Frambuesa gris nuevo mexico orgánica en lata o en frasco|O|O||D||1
50376212|Frambuesa jepson whitebark orgánica en lata o en frasco|O|O||D||1
50376213|Frambuesa kellogs san diego orgánica en lata o en frasco|O|O||D||1
50376214|Frambuesa leucodemis whitebark orgánica en lata o en frasco|O|O||D||1
50376215|Frambuesa munz cuyamaca orgánica en lata o en frasco|O|O||D||1
50376216|Frambuesa peck bartons orgánica en lata o en frasco|O|O||D||1
50376217|Frambuesa flor morada orgánica en lata o en frasco|O|O||D||1
50376218|Frambuesa roadside orgánica en lata o en frasco|O|O||D||1
50376219|Frambuesa san diego orgánica en lata o en frasco|O|O||D||1
50376220|Frambuesa nieve orgánica en lata o en frasco|O|O||D||1
50376221|Frambuesa pico de nieve orgánica en lata o en frasco|O|O||D||1
50376222|Frambuesa hoja de fresa orgánica en lata o en frasco|O|O||D||1
50376223|Frambuesa cultivo dulce orgánica en lata o en frasco|O|O||D||1
50376224|Frambuesa tor y gris whitebark orgánica en lata o en frasco|O|O||D||1
50376225|Frambuesa caribe orgánica en lata o en frasco|O|O||D||1
50376226|Frambuesa whitebark orgánica en lata o en frasco|O|O||D||1
50376227|Frambuesa vino orgánica en lata o en frasco|O|O||D||1
50376228|Frambuesa himalaya amarillo orgánica en lata o en frasco|O|O||D||1
50376229|Frambuesa yu-shan orgánica en lata o en frasco|O|O||D||1
50376300|Ruibarbos orgánicos en lata o en frasco|O|O||D||1|Acelgas rojas orgánicas en lata o en frasco
50376301|Ruibarbo crimson rojo orgánico en lata o en frasco|O|O||D||1|Acelga roja crimson orgánica en lata o en frasco
50376302|Ruibarbo champagne temprana orgánico en lata o en frasco|O|O||D||1|Acelga roja champagne temprana orgánica en lata o en frasco
50376303|Ruibarbo glasking perpetual  orgánico en lata o en frasco|O|O||D||1|Acelga roja glasking perpetual orgánica en lata o en frasco
50376304|Ruibarbo sutton orgánico en lata o en frasco|O|O||D||1|Acelga roja sutton orgánica en lata o en frasco
50376305|Ruibarbo timperley temprano orgánico en lata o en frasco|O|O||D||1|Acelga roja temprana de Timperley orgánica en lata o en frasco
50376306|Ruibarbo valentina orgánico en lata o en frasco|O|O||D||1|Acelga roja valentina orgánica en lata o en frasco
50376307|Ruibarbo victoria orgánico en lata o en frasco|O|O||D||1|Acelga roja victoria orgánica en lata o en frasco
50376308|Ruibarbo zwolle de cemilla orgánico en lata o en frasco|O|O||D||1|Acelga roja zwolle de semilla orgánica en lata o en frasco
50376309|Ruibarbo macdonald orgánico en lata o en frasco|O|O||D||1|Acelga roja macdonald orgánica en lata o en frasco
50376310|Ruibarbo tilden orgánico en lata o en frasco|O|O||D||1|Acelga roja tilden orgánica en lata o en frasco
50376400|Escaramujos orgánicos en lata o en frasco|O|O||D||1|Rosa mosqueta orgánicas en lata o en frasco
50376401|Escaramujo rosa brier orgánico en lata o en frasco|O|O||D||1|Rosa mosqueta brier orgánica en lata o en frasco
50376402|Escaramujo rosa elegante orgánico en lata o en frasco|O|O||D||1|Rosa mosqueta elegante orgánica en lata o en frasco
50376403|Escaramujo rosa rugosa orgánico en lata o en frasco|O|O||D||1|Rosa mosqueta rugosa orgánica en lata o en frasco
50376404|Escaramujo rosa burnet o scotch orgánico en lata o en frasco|O|O||D||1|Rosa mosqueta burnet o scotch orgánica en lata o en frasco
50376500|Sapotes orgánicos en lata o en frasco|O|O||D||1|Zapotes orgánicos en lata o en frasco
50376501|Zapote blanco orgánico en lata o en frasco|O|O||D||1|Zapote blanco orgánico en lata o en frasco
50376502|Zapote negro orgánico en lata o en frasco|O|O||D||1|Zapote negro orgánico en lata o en frasco
50376600|Bayas saskatoon orgánicas en lata o en frasco|O|O||D||1|Fresas de junio orgánicas en lata o en frasco
50376601|Baya mielmadera saskatoon orgánica en lata o en frasco|O|O||D||1|Fresa de junio mielmadera orgánica en lata o en frasco
50376602|Baya northline saskatoon orgánica en lata o en frasco|O|O||D||1|Fresa de junio northline orgánica en lata o en frasco
50376603|Baya saskatoon ahumado orgánica en lata o en frasco|O|O||D||1|Fresa de junio smoky orgánica en lata o en frasco
50376604|Baya saskatoon thiessen orgánica en lata o en frasco|O|O||D||1|Fresa de junio thiessen orgánica en lata o en frasco
50376700|Fresas orgánicas en lata o en frasco|O|O||D||1
50376701|Fresa chandler orgánica en lata o en frasco|O|O||D||1
50376702|Fresa rumbo junio orgánica en lata o en frasco|O|O||D||1|Fresa temporada de junio orgánica en lata o en frasco
50376703|Fresa rumbo siempre orgánica en lata o en frasco|O|O||D||1|Fresa de todo el año orgánica en lata o en frasco
50376800|Manzanas dulces orgánicas en lata o en frasco|O|O||D||1|Saramuyos orgánicos en lata o en frasco
50376801|Manzana kampong malve dulce orgánica en lata o en frasco|O|O||D||1|Saramuyo kampong mauve orgánico en lata o en frasco
50376802|Manzana dulce sin pepa orgánica en lata o en frasco|O|O||D||1|Saramuyo sin semilla orgánico en lata o en frasco
50376803|Manzana dulce thai lessand orgánica en lata o en frasco|O|O||D||1|Saramuyo thai lessand orgánico en lata o en frasco
50376900|Tamarillos orgánicos en lata o en frasco|O|O||D||1|Tomate de árbol orgánicos en lata o en frasco
50376901|Tamarindo amberlea dorado orgánico en lata o en frasco|O|O||D||1|Tomate de árbol amberlea dorado orgánico en lata o en frasco
50376902|Tamarindo calvo dorado orgánico en lata o en frasco|O|O||D||1|Tomate de árbol calvo dorado orgánico en lata o en frasco
50376903|Tamarindo mina de oro orgánico en lata o en frasco|O|O||D||1|Tomate de árbol mina de oro orgánico en lata o en frasco
50376904|Tamarindo oratia rojo orgánico en lata o en frasco|O|O||D||1|Tomate de árbol oratia rojo orgánico en lata o en frasco
50376905|Tamarindo beau rojo orgánico en lata o en frasco|O|O||D||1|Tomate de árbol beau rojo orgánico en lata o en frasco
50376906|Tamarindo delicia roja orgánico en lata o en frasco|O|O||D||1|Tomate de árbol delicia roja orgánico en lata o en frasco
50377000|Frutas Nominant orgánicas en lata o en frasco|O|O||D||1|Frutas predominantes orgánicas en lata o en frasco
50377001|Cupania orgánica en lata o en frasco|O|O||D||1|Ackee orgánica en lata o en frasco
50377002|Babaco orgánico en lata o en frasco|O|O||D||1|Carica pentágona orgánica en lata o en frasco
50377003|Banana flor orgánica en lata o en frasco|O|O||D||1|Flor de plátano orgánica en lata o en frasco
50377004|Baobab orgánica en lata o en frasco|O|O||D||1
50377005|Naranja agria orgánica en lata o en frasco|O|O||D||1
50377006|Canistel orgánica en lata o en frasco|O|O||D||1|Zapote amarillo orgánico en lata o en frasco
50377007|Baya nublosa orgánica en lata o en frasco|O|O||D||1|Mora de los pantanos orgánica en lata o en frasco
50377008|Coco orgánico en lata o en frasco|O|O||D||1
50377009|Baya drew orgánica en lata o en frasco|O|O||D||1|Baya de gota orgánica en lata o en frasco
50377010|Durian orgánica en lata o en frasco|O|O||D||1|Durio orgánico en lata o en frasco
50377011|Baya elder orgánica en lata o en frasco|O|O||D||1|Baya de sauco orgánica en lata o en frasco
50377012|Feijoa orgánica en lata o en frasco|O|O||D||1|Guayabo del Brasil orgánico en lata o en frasco
50377013|Mora orgánica en lata o en frasco|O|O||D||1
50377014|Cretaegus orgánica en lata o en frasco|O|O||D||1|Majuelo orgánico en lata o en frasco
50377015|Baya miel orgánica en lata o en frasco|O|O||D||1|Madreselva azul orgánica en lata o en frasco
50377016|Jaca orgánica en lata o en frasco|O|O||D||1|Yaca orgánica en lata o en frasco
50377017|Jambolan orgánica en lata o en frasco|O|O||D||1
50377018|Jujube orgánica en lata o en frasco|O|O||D||1|Azufaifa orgánica en lata o en frasco
50377019|Liches orgánico en lata o en frascos en lata o en frasco|O|O||D||1|Lichi orgánico en lata o en frascos en lata o en frasco
50377020|Mangostinos orgánico en lata o en frascos en lata o en frasco|O|O||D||1|Mangostán orgánico en lata o en frascos en lata o en frasco
50377021|Medlar orgánica en lata o en frasco|O|O||D||1
50377022|Mombines orgánica en lata o en frasco|O|O||D||1|Hobo orgánico en lata o en frasco
50377023|Monstera orgánica en lata o en frasco|O|O||D||1|Cerimán orgánico en lata o en frasco
50377024|Pepinos orgánico en lata o en frasco|O|O||D||1|Pepino dulce orgánico en lata o en frasco
50377025|Platono orgánico en lata o en frasco|O|O||D||1|Plátano macho orgánico en lata o en frasco
50377026|Peras en escabeche orgánica en lata o en frasco|O|O||D||1|Tuna orgánica en lata o en frasco
50377027|Mamonsillo orgánico en lata o en frasco|O|O||D||1|Guaya orgánico en lata o en frasco
50377028|Rambután orgánico en lata o en frasco|O|O||D||1|Achotillo orgánico en lata o en frasco
50377029|Manzana rosa orgánica en lata o en frasco|O|O||D||1|Pero de agua orgánica en lata o en frasco
50377030|Rosele orgánica en lata o en frasco|O|O||D||1|Flor de jamaica orgánica en lata o en frasco
50377031|Baya rowan orgánica en lata o en frasco|O|O||D||1|Serba orgánica en lata o en frasco
50377032|Baya buckhom de mar orgánica en lata o en frasco|O|O||D||1|Espino amarillo orgánica en lata o en frasco
50377033|Baya plata orgánica en lata o en frasco|O|O||D||1|Olivo de otoño orgánica en lata o en frasco
50377034|Baya sorbete orgánico en lata o en frasco|O|O||D||1|Serba orgánico en lata o en frasco
50377035|Wanabana orgánica en lata o en frasco|O|O||D||1|Guanábana orgánica en lata o en frasco
50377036|Manzana estrella orgánica en lata o en frasco|O|O||D||1|Cainito orgánica en lata o en frasco
50377037|Tamarindo orgánico en lata o en frasco|O|O||D||1
50377100|Aronias orgánicas en lata o en frasco|O|O||D||1
50377101|Aronia magia de otoño orgánica en lata o en frasco|O|O||D||1
50377102|Aronia brillantísima orgánica en lata o en frasco|O|O||D||1
50377103|Aronia nero orgánica en lata o en frasco|O|O||D||1
50377104|Aronia viquingo orgánica en lata o en frasco|O|O||D||1
50377200|Aceitunas orgánicas en lata o en frasco|O|O||D||1
50377201|Aceitunas agrinion orgánica en lata o en frasco|O|O||D||1|Aceituna agrinion orgánica en lata o en frasco
50377202|Aceitunas aleppo orgánica en lata o en frasco|O|O||D||1|Aceituna aleppo orgánica en lata o en frasco
50377203|Aceitunas  alfonso orgánica en lata o en frasco|O|O||D||1|Aceituna alfonso orgánica en lata o en frasco
50377204|Aceitunas  amfisa orgánica en lata o en frasco|O|O||D||1|Aceituna amfisa orgánica en lata o en frasco
50377205|Aceitunas  arauco orgánica en lata o en frasco|O|O||D||1|Aceituna arauco orgánica en lata o en frasco
50377206|Aceitunas  arbequina orgánica en lata o en frasco|O|O||D||1|Aceituna arbequina orgánica en lata o en frasco
50377207|Aceitunas  atlanta orgánica en lata o en frasco|O|O||D||1|Aceituna atlanta orgánica en lata o en frasco
50377208|Aceitunas  cerignola orgánica en lata o en frasco|O|O||D||1|Aceituna cerignola orgánica en lata o en frasco
50377209|Aceitunas  cracked provencal orgánica en lata o en frasco|O|O||D||1|Aceituna cracked provencal orgánica en lata o en frasco
50377210|Aceitunas  empeltre orgánica en lata o en frasco|O|O||D||1|Aceituna empeltre orgánica en lata o en frasco
50377211|Aceitunas gaeta  orgánica en lata o en frasco|O|O||D||1|Aceituna gaeta orgánica en lata o en frasco
50377212|Aceitunas hondoelia orgánica en lata o en frasco|O|O||D||1|Aceituna hondoelia orgánica en lata o en frasco
50377213|Aceitunas kalamata orgánica en lata o en frasco|O|O||D||1|Aceituna kalamata orgánica en lata o en frasco
50377214|Aceitunas kura orgánica en lata o en frasco|O|O||D||1|Aceituna kura orgánica en lata o en frasco
50377215|Aceitunas ligurian orgánica en lata o en frasco|O|O||D||1|Aceituna ligurian orgánica en lata o en frasco
50377216|Aceitunas lucque orgánica en lata o en frasco|O|O||D||1|Aceituna lucque orgánica en lata o en frasco
50377217|Aceitunas lugano orgánica en lata o en frasco|O|O||D||1|Aceituna lugano orgánica en lata o en frasco
50377218|Aceitunas manzanilla orgánica en lata o en frasco|O|O||D||1|Aceituna manzanilla orgánica en lata o en frasco
50377219|Aceitunas marche orgánica en lata o en frasco|O|O||D||1|Aceituna marche orgánica en lata o en frasco
50377220|Aceitunas misión orgánica en lata o en frasco|O|O||D||1|Aceituna misión orgánica en lata o en frasco
50377221|Aceitunas nafplion verde orgánica en lata o en frasco|O|O||D||1|Aceituna nafplion verde orgánica en lata o en frasco
50377222|Aceitunas nicoise orgánica en lata o en frasco|O|O||D||1|Aceituna nicoise orgánica en lata o en frasco
50377223|Aceitunas nyons orgánica en lata o en frasco|O|O||D||1|Aceituna nyons orgánica en lata o en frasco
50377224|Aceitunas picholine orgánica en lata o en frasco|O|O||D||1|Aceituna picholine orgánica en lata o en frasco
50377225|Aceitunas ponentine orgánica en lata o en frasco|O|O||D||1|Aceituna ponentine orgánica en lata o en frasco
50377226|Aceitunas royal orgánica en lata o en frasco|O|O||D||1|Aceituna royal orgánica en lata o en frasco
50377227|Aceitunas seracena orgánica en lata o en frasco|O|O||D||1|Aceituna seracena orgánica en lata o en frasco
50377228|Aceitunas sevillano orgánica en lata o en frasco|O|O||D||1|Aceituna sevillano orgánica en lata o en frasco
50377229|Aceitunas sicilian orgánica en lata o en frasco|O|O||D||1|Aceituna sicilian orgánica en lata o en frasco
50377230|Aceitunas toscanella orgánica en lata o en frasco|O|O||D||1|Aceituna toscanella orgánica en lata o en frasco
50381500|Purés de cítricos|O|O||D||1
50381501|Puré de naranja|O|O||D||1
50381502|Puré de lima|O|O||D||1
50381503|Puré de limón|O|O||D||1
50381600|Purés de bayas|O|O||D||1
50381601|Puré de fresa|O|O||D||1
50381602|Puré de mora|O|O||D||1
50381700|Purés de frutas tropicales|O|O||D||1
50381701|Puré de mango|O|O||D||1
50381702|Puré de kiwi|O|O||D||1
50381800|Purés de melón|O|O||D||1
50381801|Puré de melón|O|O||D||1
50381802|Puré de sandía|O|O||D||1
50401500|Alcachofas|O|O||D||1
50401501|Alcachofa brittany|O|O||D||1
50401502|Alcachofa cantonesa|O|O||D||1
50401503|Alcachofa francesa|O|O||D||1
50401504|Alcachofa globo verde|O|O||D||1
50401505|Alcachofa gros camus de bretaña|O|O||D||1
50401506|Alcachofa midi|O|O||D||1
50401507|Alcachofa globo morado|O|O||D||1
50401508|Alcachofa morado cecilia|O|O||D||1
50401509|Alcachofa romanesco|O|O||D||1
50401510|Alcachofa espinoso sardo|O|O||D||1
50401511|Alcachofa vert de laon|O|O||D||1
50401512|Alcachofa violeta de chiggiia|O|O||D||1
50401513|Alcachofa violeta de toscana|O|O||D||1
50401600|Espárragos|O|O||D||1
50401601|Espárragos connovers colossal|O|O||D||1
50401602|Espárragos franklin|O|O||D||1
50401603|Espárragos mamut gigante|O|O||D||1
50401604|Espárragos lucullus|O|O||D||1
50401605|Espárragos martha washington|O|O||D||1
50401700|Aguacates|O|O||D||1
50401701|Aguacate ajax b – 7|O|O||D||1
50401702|Aguacate arue|O|O||D||1
50401703|Aguacate bacon|O|O||D||1
50401704|Aguacate benik|O|O||D||1
50401705|Aguacate bernecker|O|O||D||1
50401706|Aguacate beta|O|O||D||1
50401707|Aguacate biondo|O|O||D||1
50401708|Aguacate príncipe negro|O|O||D||1
50401709|Aguacate blair|O|O||D||1
50401710|Aguacate blair cabina|O|O||D||1
50401711|Aguacate cabina 1|O|O||D||1
50401712|Aguacate cabina 3|O|O||D||1
50401713|Aguacate cabina 5|O|O||D||1
50401714|Aguacate cabina 7|O|O||D||1
50401715|Aguacate cabina 8|O|O||D||1
50401716|Aguacate brooks 1978|O|O||D||1
50401717|Aguacate brookslate|O|O||D||1
50401718|Aguacate california haas|O|O||D||1
50401719|Aguacate catalina|O|O||D||1
50401720|Aguacate chica|O|O||D||1
50401721|Aguacate choquette|O|O||D||1
50401722|Aguacate cristina|O|O||D||1
50401723|Aguacate collison|O|O||D||1
50401724|Aguacate donnie|O|O||D||1
50401725|Aguacate dr dupis numero 2|O|O||D||1
50401726|Aguacate dr. dupie|O|O||D||1
50401727|Aguacate ettinger|O|O||D||1
50401728|Aguacate fuch|O|O||D||1
50401729|Aguacate fuch gwen|O|O||D||1
50401730|Aguacate fuerte|O|O||D||1
50401731|Aguacate gotham|O|O||D||1
50401732|Aguacate gossman|O|O||D||1
50401733|Aguacate guatemala sin pepa|O|O||D||1
50401734|Aguacate hall|O|O||D||1
50401735|Aguacate hardee|O|O||D||1
50401736|Aguacate haas|O|O||D||1
50401737|Aguacate herman|O|O||D||1
50401738|Aguacate hickson|O|O||D||1
50401739|Aguacate k-5|O|O||D||1
50401740|Aguacate k- 9|O|O||D||1
50401741|Aguacate cordero haas|O|O||D||1
50401742|Aguacate leona|O|O||D||1
50401743|Aguacate leona linda|O|O||D||1
50401744|Aguacate lisa p|O|O||D||1
50401745|Aguacate lisa loretta|O|O||D||1
50401746|Aguacate loretta|O|O||D||1
50401747|Aguacate lula|O|O||D||1
50401748|Aguacate lula mascarthur|O|O||D||1
50401749|Aguacate marcus|O|O||D||1
50401750|Aguacate melendez|O|O||D||1
50401751|Aguacate meya|O|O||D||1
50401752|Aguacate miguel p|O|O||D||1
50401753|Aguacate monroe|O|O||D||1
50401754|Aguacate murrieta verde|O|O||D||1
50401755|Aguacate nabal|O|O||D||1
50401756|Aguacate nadir|O|O||D||1
50401757|Aguacate nesbitt|O|O||D||1
50401758|Aguacate peterson|O|O||D||1
50401759|Aguacate pinelli|O|O||D||1
50401760|Aguacate pinkerton|O|O||D||1
50401761|Aguacate pollock|O|O||D||1
50401762|Aguacate puebla|O|O||D||1
50401763|Aguacate reed|O|O||D||1
50401764|Aguacaterue|O|O||D||1
50401765|Aguacateruehle|O|O||D||1
50401766|Aguacate ryan|O|O||D||1
50401767|Aguacate semil|O|O||D||1
50401768|Aguacate semil 43|O|O||D||1
50401769|Aguacate simonds|O|O||D||1
50401770|Aguacate simpson|O|O||D||1
50401771|Aguacate taylor|O|O||D||1
50401772|Aguacate tonelada|O|O||D||1
50401773|Aguacate torre|O|O||D||1
50401774|Aguacate torre li|O|O||D||1
50401775|Aguacate trapp|O|O||D||1
50401776|Aguacate semilla de caribe|O|O||D||1
50401777|Aguacate wagner|O|O||D||1
50401778|Aguacate waldin|O|O||D||1
50401779|Aguacate wurtz|O|O||D||1
50401780|Aguacate zio p|O|O||D||1
50401781|Aguacate ziu|O|O||D||1
50401782|Aguacate zultano|O|O||D||1
50401800|Fríjoles|O|O||D||1
50401801|Frijoles anasazi ®|O|O||D||1
50401802|Frijoles appaloosa|O|O||D||1
50401803|Frijoles azuki|O|O||D||1
50401804|Frijoles barlotti|O|O||D||1
50401805|Frijoles appaloosa negra|O|O||D||1
50401806|Frijoles negros|O|O||D||1
50401807|Frijoles gran negros|O|O||D||1
50401808|Frijoles shackamaxon negro|O|O||D||1
50401809|Frijoles ojo negro|O|O||D||1
50401810|Frijoles bobby|O|O||D||1
50401811|Frijoles bolita|O|O||D||1
50401812|Frijoles esposa perezosa carmelita|O|O||D||1
50401813|Frijoles calipso|O|O||D||1
50401814|Frijoles canelini|O|O||D||1
50401815|Frijoles castor|O|O||D||1
50401816|Frijoles amarillo chino|O|O||D||1
50401817|Frijoles lengua de dragón|O|O||D||1
50401818|Frijoles soldado europeo|O|O||D||1
50401819|Frijoles fava|O|O||D||1
50401820|Frijoles flageolet|O|O||D||1
50401821|Frijoles  horticultura francesa|O|O||D||1
50401822|Frijoles marina francesa|O|O||D||1
50401823|Frijoles coco gigante blanco|O|O||D||1
50401824|Frijoles verdes|O|O||D||1
50401825|Frijoles romano verde|O|O||D||1
50401826|Frijoles guar gum|O|O||D||1
50401827|Frijoles haricot|O|O||D||1
50401828|Frijoles hyacinth|O|O||D||1
50401829|Frijoles tipo italiano|O|O||D||1
50401830|Frijoles asombro jackson|O|O||D||1
50401831|Frijoles ganado jacobs|O|O||D||1
50401832|Frijoles asombro kentucky|O|O||D||1
50401833|Frijoles riñón|O|O||D||1
50401834|Frijoles lima|O|O||D||1
50401835|Frijoles madera|O|O||D||1
50401836|Frijoles medula|O|O||D||1
50401837|Frijoles mat|O|O||D||1
50401838|Frijoles monstoler ganzo salvaje|O|O||D||1
50401839|Frijoles  mortgage lifter|O|O||D||1
50401840|Frijoles polilla|O|O||D||1
50401841|Frijoles mung|O|O||D||1
50401842|Frijoles munsi wolf|O|O||D||1
50401843|Frijoles nuna|O|O||D||1
50401844|Frijoles pinto|O|O||D||1
50401845|Frijoles runner|O|O||D||1
50401846|String beans|O|O||D||1|Ayecote, Fríjol gordo
50401847|Frijoles habichuelas|O|O||D||1|Ejote, Fríjol tierno
50401848|Frijoles tamarind|O|O||D||1
50401849|Frijoles tonka|O|O||D||1
50401850|Frijoles cera|O|O||D||1
50401851|Frijoles winged|O|O||D||1
50401852|Frijoles largos|O|O||D||1
50401853|Frijoles peruanos canario|O|O||D||1
50401900|Remolachas|O|O||D||1|Betabeles
50401901|Remolacha accion|O|O||D||1|Betabel acción
50401902|Remolacha albina vereduna|O|O||D||1|Betabel albina vereduna
50401903|Remolacha barababiotela de chiggia|O|O||D||1|Betabel barababiotela de chiggia
50401904|Remolacha boltardy|O|O||D||1|Betabel boltardy
50401905|Remolacha bonel|O|O||D||1|Betabel bonel
50401906|Remolacha burpees dorado|O|O||D||1|Betabel burpees dorado
50401907|Remolacha cheltenham tapa verde|O|O||D||1|Betabel cheltenham tapa verde
50401908|Remolacha cheltenham mono|O|O||D||1|Betabel cheltenham mono
50401909|Remolacha chioggia|O|O||D||1|Betabel chioggia
50401910|Remolacha cilindra|O|O||D||1|Betabel cilindra
50401911|Remolacha dégypte|O|O||D||1|Betabel dégypte
50401912|Remolacha detroit 2 rojo oscuro|O|O||D||1|Betabel detroit 2 rojo oscuro
50401913|Remolacha detroit 2 bala chiquita|O|O||D||1|Betabel detroit 2 bala chiquita
50401914|Remolacha egipcia plana|O|O||D||1|Betabel egipcia plana
50401915|Remolacha  raíz de nabo egipcio|O|O||D||1|Betabel raíz de nabo egipcio
50401916|Remolacha fomanova|O|O||D||1|Betabel fomanova
50401917|Remolacha forono|O|O||D||1|Betabel forono
50401918|Remolacha monaco|O|O||D||1|Betabel mónaco
50401919|Remolacha monograma|O|O||D||1|Betabel monograma
50401920|Remolacha pronto|O|O||D||1|Betabel pronto
50401921|Remolacha regalía|O|O||D||1|Betabel regalía
50401922|Remolacha dulce|O|O||D||1|Betabel dulce
50402000|Brócolis|O|O||D||1
50402001|Brócolini|O|O||D||1
50402002|Brócoli romanesco|O|O||D||1
50402003|Brócoli raab|O|O||D||1
50402004|Brócoli chino|O|O||D||1
50402100|Repollitos de Bruselas|O|O||D||1|Coles de Bruselas
50402101|Repollitas de bruselas citade|O|O||D||1|Coles de Bruselas citade
50402102|Repollitas de bruselas falstaff|O|O||D||1|Coles de Bruselas falstaff
50402103|Repollitas de bruselas oliver|O|O||D||1|Coles de Bruselas oliver
50402104|Repollitas de bruselas peer gynt|O|O||D||1|Coles de Bruselas peer gynt
50402105|Repollitas de bruselas rampart|O|O||D||1|Coles de Bruselas rampart
50402106|Repollitas de bruselas rubine|O|O||D||1|Coles de Bruselas rubine
50402107|Repollitas de bruselas  widgeon|O|O||D||1|Coles de Bruselas widgeon
50402200|Cebollas de ensalada|O|O||D||1|Cebollas de cambray
50402201|Cebolla belstville ensalada|O|O||D||1|Cebolla de cambray belstville
50402202|Cebolla feast ensalada|O|O||D||1|Cebolla de cambray feast
50402203|Cebolla ishikura ensalada|O|O||D||1|Cebolla de cambray ishikura
50402204|Cebolla mercado kyoto|O|O||D||1|Cebolla de cambray mercado kyoto
50402205|Cebolla barba roja ensalada|O|O||D||1|Cebolla de cambray barba roja
50402206|Cebolla amigo rojo ensalada|O|O||D||1|Cebolla de cambray amigo rojo
50402207|Cebolla santa claus|O|O||D||1|Cebolla de cambray santa claus
50402208|Cebolla tokyo ensalada|O|O||D||1|Cebolla de cambray tokyo
50402209|Cebolla lisbon blanca ensalada|O|O||D||1|Cebolla de cambray lisbon blanca
50402210|Cebolla invierno blanca ensalada|O|O||D||1|Cebolla de cambray invierno blanca
50402211|Cebolla final de invierno ensalada|O|O||D||1|Cebolla de cambray final de invierno
50402300|Repollos|O|O||D||1|Coles
50402301|Repollo negro|O|O||D||1|Col negro
50402302|Repollo savoy|O|O||D||1|Col savoy
50402303|Repollo zorrillo|O|O||D||1|Col zorrillo
50402304|Repollo blanco|O|O||D||1|Col blanco
50402305|Repollo morado|O|O||D||1|Col morado
50402400|Cardos|O|O||D||1|Cardos comestibles
50402401|Cardos lunghi|O|O||D||1|Cardo comestible lunghi
50402402|Cardos gobbi|O|O||D||1|Cardo comestible gobbi
50402500|Zanahorias|O|O||D||1
50402501|Zanahoria amsterdam|O|O||D||1
50402502|Zanahoria rey de otoño|O|O||D||1
50402503|Zanahoria berlicum|O|O||D||1
50402504|Zanahoria chantenay|O|O||D||1
50402505|Zanahoria nantes|O|O||D||1
50402506|Zanahoria mercado de parís|O|O||D||1
50402507|Zanahoria bebé|O|O||D||1
50402600|Coliflores|O|O||D||1
50402601|Coliflor todo el año|O|O||D||1
50402602|Coliflor alverda|O|O||D||1
50402603|Otoño gigante 3|O|O||D||1
50402604|Coliflordok elgon|O|O||D||1
50402605|Coliflor bola de nieve temprana|O|O||D||1
50402606|Coliflor luz de lima|O|O||D||1
50402607|Coliflor minaret|O|O||D||1
50402608|Coliflor buque de naranja|O|O||D||1
50402609|Coliflor capa morada|O|O||D||1
50402610|Coliflor bola de nieve|O|O||D||1
50402611|Coliflor invierno walcheren 3|O|O||D||1
50402612|Coliflor piedra blanca|O|O||D||1
50402700|Apios|O|O||D||1
50402701|Apio celebridad|O|O||D||1
50402702|Apio|O|O||D||1
50402703|Apio chino|O|O||D||1
50402704|Apio dinant francés|O|O||D||1
50402705|Apio gigante rosado|O|O||D||1
50402706|Apio gigante rojo|O|O||D||1
50402707|Apio gigante blanco|O|O||D||1
50402708|Apio dorado auto escalado|O|O||D||1
50402709|Apio "greensleeves"|O|O||D||1
50402710|Apio hopkins fenlander|O|O||D||1
50402711|Apio torre marfil|O|O||D||1
50402712|Apio lathom blanqueado|O|O||D||1
50402713|Apio sopa de amsterdam|O|O||D||1
50402714|Apio estándar cargado|O|O||D||1
50402715|Apio triunfo alto utah|O|O||D||1
50402800|Acelgas|O|O||D||1
50402801|Acelga luz brillante|O|O||D||1
50402802|Acelga gigante fordhook|O|O||D||1
50402803|Acelga luculus|O|O||D||1
50402804|Acelga espinaca perpetua|O|O||D||1
50402805|Acelga ruibarbo|O|O||D||1
50402806|Acelga suizo|O|O||D||1
50402807|Acelga volcán|O|O||D||1
50402808|Acelga rey blanco|O|O||D||1
50402900|Achicorias|O|O||D||1|Escarolas
50402901|Achicoria batavian hoja ancha|O|O||D||1|Escarola batavian hoja ancha
50402902|Achicoria en cornet de bordeaux|O|O||D||1|Escarola en cornet de bordeaux
50402903|Achicoria rollo verde ruffee|O|O||D||1|Escarola rollo verde ruffee
50402904|Achicoria roll verde|O|O||D||1|Escarola roll verde
50402905|Achicoria limnoe lone|O|O||D||1|Escarola limnoe lone
50402906|Achicoria pancalieri riccia|O|O||D||1|Escarola pancalieri riccia
50402907|Achicoria ensalada rey|O|O||D||1|Escarola ensalada rey
50402908|Achicoria sanda|O|O||D||1|Escarola sanda
50402909|Achicoria scarola verde|O|O||D||1|Escarola scarola verde
50402910|Achicoria tres fine maraichere|O|O||D||1|Escarola tres fine maraichere
50402911|Achicoria wallone freisee wescelkkopf|O|O||D||1|Escarola wallone freisee wescelkkopf
50403000|Repollos chinos|O|O||D||1|Col china
50403001|Bok choy|O|O||D||1
50403002|Bok choy enano|O|O||D||1
50403003|Flor de repollo chino|O|O||D||1|Flor de col china
50403004|Choy sum|O|O||D||1
50403005|Col (bok choy) enano|O|O||D||1
50403006|Col (bok choy) fengshan|O|O||D||1
50403007|Col (bok choy) jade pagoda|O|O||D||1
50403008|Col (bok choy) kasumi|O|O||D||1
50403009|Col (bok choy)  nerva|O|O||D||1
50403010|Col (bok choy) rosette|O|O||D||1
50403011|Col (bok choy) ruffles|O|O||D||1
50403012|Col (bok choy) hoja  santo serrated|O|O||D||1
50403013|Col (bok choy) shangahai|O|O||D||1
50403014|Shantung|O|O||D||1
50403015|Repollo tip top|O|O||D||1|Col china tip top
50403016|Yau choy sum|O|O||D||1
50403100|Cebollines|O|O||D||1
50403101|Cebollín chino|O|O||D||1
50403200|Maíces|O|O||D||1
50403201|Maíz aloha|O|O||D||1
50403202|Maíz alpine|O|O||D||1
50403203|Maíz ambrosia|O|O||D||1
50403204|Maíz argent|O|O||D||1
50403205|Maíz aspen|O|O||D||1
50403206|Maíz avalancha|O|O||D||1
50403207|Maíz biqueen|O|O||D||1
50403208|Maíz  bodacious|O|O||D||1
50403209|Maíz  mantequilla y azúcar|O|O||D||1
50403210|Maíz  calico belle|O|O||D||1
50403211|Maíz  camelot|O|O||D||1
50403212|Maíz  challengercrisp ‘n dulce|O|O||D||1
50403213|Maíz  campeón|O|O||D||1
50403214|Maíz  algodón de azúcar|O|O||D||1
50403215|Maíz  dártagnan|O|O||D||1
50403216|Maíz  dazzle|O|O||D||1
50403217|Maíz  diamante y oro|O|O||D||1
50403218|Maíz  divinidad|O|O||D||1
50403219|Maíz  delicia doble|O|O||D||1
50403220|Maíz  gema doble|O|O||D||1
50403221|Maíz  earlivee|O|O||D||1
50403222|Maíz  temprano extra dulce|O|O||D||1
50403223|Maíz excel|O|O||D||1
50403224|Maíz  cruz dorada bantam|O|O||D||1
50403225|Maíz  miel y crema|O|O||D||1
50403226|Maíz  miel y perla|O|O||D||1
50403227|Maíz  miel dulce|O|O||D||1
50403228|Maíz  hudson|O|O||D||1
50403229|Maíz  dorado illini|O|O||D||1
50403230|Maíz  illini extra dulce|O|O||D||1
50403231|Maíz  increíble|O|O||D||1
50403232|Maíz  lochief|O|O||D||1
50403233|Maíz jubileo|O|O||D||1
50403234|Maíz jupbileo super dulce|O|O||D||1
50403235|Maíz  confite korn|O|O||D||1
50403236|Maíz  beso y acuso|O|O||D||1
50403237|Maíz  lancelot|O|O||D||1
50403238|Maíz dulce maple|O|O||D||1
50403239|Maíz  medley|O|O||D||1
50403240|Maíz merlin|O|O||D||1
50403241|Maíz milagro|O|O||D||1
50403242|Maíz nk – 199|O|O||D||1
50403243|Maíz durazno y crema|O|O||D||1
50403244|Maíz blanco perla|O|O||D||1
50403245|Maíz  pegasus|O|O||D||1
50403246|Maíz  fenomenal|O|O||D||1
50403247|Maíz  dama de platino|O|O||D||1
50403248|Maíz  precioso|O|O||D||1
50403249|Maíz   pristine|O|O||D||1
50403250|Maíz  rápido|O|O||D||1
50403251|Maíz  radiante|O|O||D||1
50403252|Maíz  seneca brave|O|O||D||1
50403253|Maíz  amanecer seneca|O|O||D||1
50403254|Maíz  horizonte seneca|O|O||D||1
50403255|Maíz  brillo de estrella seneca|O|O||D||1
50403256|Maíz  noche blanca seneca|O|O||D||1
50403257|Maíz  showcase|O|O||D||1
50403258|Maíz  reina plateada|O|O||D||1
50403259|Maíz  bella nieve|O|O||D||1
50403260|Maíz nieve de primavera|O|O||D||1
50403261|Maíz  premio de primavera|O|O||D||1
50403262|Maíz  azúcar y oro|O|O||D||1
50403263|Maíz rollo de azúcar|O|O||D||1
50403264|Maíz nieve de azúcar|O|O||D||1
50403265|Maíz baile de sol|O|O||D||1
50403266|Maíz estrella tell|O|O||D||1
50403267|Maíz terminador|O|O||D||1
50403268|Maíz tesoro|O|O||D||1
50403269|Maíz tuxedo|O|O||D||1
50403300|Berros|O|O||D||1
50403301|Berros de tierra|O|O||D||1
50403302|Nasturtium|O|O||D||1
50403303|Berros de agua|O|O||D||1
50403304|Berros de invierno|O|O||D||1
50403400|Cocombros|O|O||D||1|Pepinos cohombro
50403401|Cocombro arena|O|O||D||1|Pepino cohombro arena
50403402|Cocombro americano|O|O||D||1|Pepino cohombro americano
50403403|Cocombro atena|O|O||D||1|Pepino cohombro atena
50403404|Cocombro blanco lungo de parigi|O|O||D||1|Pepino cohombro blanco lungo de parigi
50403405|Cocombro verde burpless buen sabor|O|O||D||1|Pepino cohombro verde burpless buen sabor
50403406|Cocombro chicago pickling|O|O||D||1|Pepino cohombro chicago pickling
50403407|Cocombro manzana cristal|O|O||D||1|Pepino cohombro manzana cristal
50403408|Cocombro limón cristal|O|O||D||1|Pepino cohombro limón cristal
50403409|Cocombro danimas|O|O||D||1|Pepino cohombro danimas
50403410|Cocombro gherkin|O|O||D||1|Pepino cohombro gherkin
50403411|Cocombro hokus|O|O||D||1|Pepino cohombro hokus
50403412|Cocombro japonés|O|O||D||1|Pepino cohombro japonés
50403413|Cocombro karela|O|O||D||1|Pepino cohombro karela
50403414|Cocombro korila|O|O||D||1|Pepino cohombro korila
50403415|Cocombro verde largo mejorado|O|O||D||1|Pepino cohombro verde largo mejorado
50403416|Cocombro mas mercado|O|O||D||1|Pepino cohombro mas mercado
50403417|Cocombro enano|O|O||D||1|Pepino cohombro enano
50403418|Cocombro pickling nacional|O|O||D||1|Pepino cohombro pickling nacional
50403419|Cocombro persa|O|O||D||1|Pepino cohombro persa
50403420|Cocombro telégrafo|O|O||D||1|Pepino cohombro telégrafo
50403421|Cocombro telégrafo mejorado|O|O||D||1|Pepino cohombro telégrafo mejorado
50403422|Cocombro vert de massy cornichon|O|O||D||1|Pepino cohombro vert de massy cornichon
50403423|Cocombro yamato|O|O||D||1|Pepino cohombro yamato
50403500|Berenjenas|O|O||D||1
50403501|Berenjena bambino|O|O||D||1
50403502|Berenjena  belleza negra|O|O||D||1
50403503|Berenjena  negra enorme|O|O||D||1
50403504|Berenjena  chino|O|O||D||1
50403505|Berenjena  huevo de pascua|O|O||D||1
50403506|Berenjena  filipino|O|O||D||1
50403507|Berenjena   mercado de florida|O|O||D||1
50403508|Berenjena  india|O|O||D||1
50403509|Berenjena  italiano|O|O||D||1
50403510|Berenjena  japonés|O|O||D||1
50403511|Berenjena  morado largo|O|O||D||1
50403512|Berenjena   rayas larga|O|O||D||1
50403513|Berenjena  mercado de dinero|O|O||D||1
50403514|Berenjena  ova|O|O||D||1
50403515|Berenjena   arveja|O|O||D||1
50403516|Berenjena  tom bajito|O|O||D||1
50403517|Berenjena  siciliano|O|O||D||1
50403518|Berenjena  tailandés|O|O||D||1
50403519|Berenjena  violeta de florencia|O|O||D||1
50403520|Berenjena  blanco|O|O||D||1
50403600|Endivias|O|O||D||1
50403601|Endivias witloof de brucelas|O|O||D||1
50403602|Endivias francocastel|O|O||D||1
50403603|Endivias catalogna de galantina|O|O||D||1
50403604|Endivias chioggia|O|O||D||1
50403605|Endivias grumolo verde|O|O||D||1
50403606|Endivias raíz larga magdeburg|O|O||D||1
50403607|Endivias palla rosa zorzi precoce|O|O||D||1
50403608|Endivias radice amare|O|O||D||1
50403609|Endivias rosa de traviso|O|O||D||1
50403610|Endivias  rosa de verona|O|O||D||1
50403611|Endivias soncino|O|O||D||1
50403612|Endivias sugarthi|O|O||D||1
50403613|Endivias verona|O|O||D||1
50403614|Endivias witloof zoom|O|O||D||1
50403700|Hinojos|O|O||D||1
50403701|Hinojo cantino|O|O||D||1
50403702|Hinojo fino|O|O||D||1
50403703|Hinojoherald|O|O||D||1
50403704|Hinojo perfección|O|O||D||1
50403705|Hinojo sirio|O|O||D||1
50403706|Hinojo florencia dulce|O|O||D||1
50403707|Hinojo tardo|O|O||D||1
50403800|Ajos|O|O||D||1
50403801|Ajo tarde california|O|O||D||1
50403802|Ajo tallos chinos|O|O||D||1
50403803|Ajo cebollin|O|O||D||1
50403804|Ajo germidor|O|O||D||1
50403805|Ajo guardado largo|O|O||D||1
50403806|Ajo ramson|O|O||D||1
50403807|Ajo rocambola|O|O||D||1
50403808|Ajo rosa de lautrec|O|O||D||1
50403809|Ajo solent blanco|O|O||D||1
50403810|Ajo morado español|O|O||D||1
50403811|Ajo valentina italiana|O|O||D||1
50403900|Calabazas|O|O||D||1
50403901|Petula|O|O||D||1|Luffa
50403902|Melon amargo|O|O||D||1
50403903|Botella calabaza|O|O||D||1|Mate
50403904|Calabash gounds|O|O||D||1|Calabaza de peregrino
50403905|Melón peludo|O|O||D||1
50403906|Calabaza amarga|O|O||D||1
50403907|Loofah suave|O|O||D||1|Zapatillo suave
50403908|Serpiente de calabaza|O|O||D||1|Chichinda
50403909|Calabaza larga amarga|O|O||D||1
50403910|Calabaza tinda|O|O||D||1
50403911|Calabaza tindoori|O|O||D||1
50404000|Guisantes|O|O||D||1|Chícharos
50404001|Guisante chino|O|O||D||1|Chícharo chino
50404002|Guisante inglés|O|O||D||1|Chícharo inglés
50404003|Guisante de jardín|O|O||D||1|Chícharo de jardín
50404004|Guisante nieve|O|O||D||1|Chícharo nieve
50404006|Guisante snap dulce|O|O||D||1|Chícharo snap dulce
50404100|Hierbas|O|O||D||1|Perejil, Yerbabuena o hierbabuena
50404101|Albahaca|O|O||D||1
50404102|Laurel|O|O||D||1
50404103|Borraja|O|O||D||1
50404104|Alcaravea|O|O||D||1
50404105|Perifollo|O|O||D||1
50404106|Cilantro|O|O||D||1
50404107|Chipolinos|O|O||D||1
50404108|Hoja de curry|O|O||D||1
50404109|Eneldo|O|O||D||1
50404110|Epazote|O|O||D||1
50404111|Fenogreco|O|O||D||1
50404112|Limonaria|O|O||D||1|Té de limón
50404113|Mejorana|O|O||D||1
50404114|Menta|O|O||D||1
50404115|Orégano|O|O||D||1
50404116|Pápalo|O|O||D||1
50404117|Pápalo delgado|O|O||D||1
50404118|Perilla|O|O||D||1|Albahaca japonesa
50404119|Recao|O|O||D||1
50404120|Romero|O|O||D||1
50404121|Salvia|O|O||D||1
50404122|Salsifí|O|O||D||1|Barba cabruna
50404123|Satureja|O|O||D||1|Ajedreas
50404124|Estragón|O|O||D||1|Tarragón
50404125|Tomillo|O|O||D||1
50404126|Tumeric|O|O||D||1|Cúrcuma
50404127|Verdolaga|O|O||D||1
50404200|Coles|O|O||D||1
50404201|Col rizada|O|O||D||1
50404202|Repollo verde|O|O||D||1
50404300|Colinabos|O|O||D||1|Colirrábanos
50404301|Colinabo estrella azur|O|O||D||1|Colirrábano estrella azur
50404302|Colinabo verde viena|O|O||D||1|Colirrábano verde viena
50404303|Colinabo lanro|O|O||D||1|Colirrábano lanro
50404304|Colinabo viena morada|O|O||D||1|Colirrábano viena morada
50404305|Colinabo trero rowel|O|O||D||1|Colirrábano trero rowel
50404306|Colinabo viena blanca|O|O||D||1|Colirrábano viena blanca
50404400|Puerros|O|O||D||1|Poros
50404401|Puerro cobra gigante otoño|O|O||D||1|Poro cobra gigante otoño
50404402|Puerro otoño mamut 2|O|O||D||1|Poro otoño mamut 2
50404403|Puerro blue de solaise|O|O||D||1|Poro blue de solaise
50404404|Puerro cortina|O|O||D||1|Poro cortina
50404405|Puerro prelina|O|O||D||1|Poro prelina
50404406|Puerro salvaje|O|O||D||1|Poro salvaje
50404500|Lentejas|O|O||D||1
50404501|Lenteja beluga|O|O||D||1
50404502|Lenteja  verde francesa|O|O||D||1
50404503|Lenteja verde|O|O||D||1
50404504|Lenteja crimson pequeña|O|O||D||1
50404505|Lenteja pardina española|O|O||D||1
50404506|Lenteja roja separada|O|O||D||1
50404507|Lenteja amarilla separad|O|O||D||1
50404508|Lenteja tarahumara rosada|O|O||D||1
50404600|Lechugas|O|O||D||1
50404601|Lechuga  bibb|O|O||D||1
50404602|Lechuga  boston|O|O||D||1
50404603|Lechuga frisee|O|O||D||1
50404604|Lechuga rosa lola|O|O||D||1
50404605|Lechuga  mixta masculina|O|O||D||1
50404606|Lechuga mizuna|O|O||D||1
50404607|Lechuga hoja roja|O|O||D||1
50404608|Lechuga oja roja roble|O|O||D||1
50404609|Lechuga romana ruby|O|O||D||1
50404610|Lechuga romana bebé roja|O|O||D||1
50404611|Lechuga cabeza de mantequilla|O|O||D||1
50404612|Lechuga china|O|O||D||1|Lechuga orejona
50404613|Lechuga cabeza tostada|O|O||D||1
50404614|Lechuga hoja verde|O|O||D||1
50404615|Lechuga iceberg|O|O||D||1
50404616|Lechuga cordero|O|O||D||1
50404617|Lechuga hoja suelta|O|O||D||1
50404618|Lechuga mache|O|O||D||1
50404619|Lechuga boston roja|O|O||D||1
50404620|Lechuga cabeza roja|O|O||D||1
50404621|Lechuga romana|O|O||D||1
50404622|Lechuga mostza roja rusa|O|O||D||1
50404623|Lechuga tatsoi|O|O||D||1
50404700|Ñames|O|O||D||1
50404701|Ñame amarilla|O|O||D||1
50404702|Ñame blanca|O|O||D||1
50404703|Ñame coco|O|O||D||1
50404704|Ñame eddoes|O|O||D||1
50404705|Ñame isleña|O|O||D||1
50404706|Ñame lila|O|O||D||1
50404800|Hongos o champiñones|O|O||D||1
50404801|Champiñón trompeta negra|O|O||D||1
50404802|Champiñón carmelito|O|O||D||1
50404803|Champiñón|O|O||D||1
50404804|Champiñón chanterelle|O|O||D||1
50404805|Champiñón cremini|O|O||D||1
50404806|Champiñón enoki|O|O||D||1
50404807|Champiñón puercoespín|O|O||D||1
50404808|Champiñón gallina del bosque|O|O||D||1
50404809|Champiñón langosta|O|O||D||1
50404810|Champiñón morels|O|O||D||1
50404811|Champiñón ostra|O|O||D||1
50404812|Champiñón pleurotus|O|O||D||1
50404813|Champiñón pompom|O|O||D||1
50404814|Champiñón porcieni|O|O||D||1
50404815|Champiñón portobello|O|O||D||1
50404816|Champiñón shitake|O|O||D||1
50404817|Champiñón shimeji|O|O||D||1
50404818|Champiñón san jorge|O|O||D||1
50404819|Champiñón blanco|O|O||D||1
50404820|Champiñón tompeta blanca|O|O||D||1
50404821|Champiñón woodear|O|O||D||1
50404822|Champiñón seta|O|O||D||1
50404823|Champión tonku|O|O||D||1
50404900|Mostazas|O|O||D||1
50404901|Mostaza bambú|O|O||D||1
50404902|Mostaza ajo|O|O||D||1
50404903|Mostaza hoja gigante|O|O||D||1
50404904|Mostaza rojo en nieve|O|O||D||1
50404905|Mostaza sureño|O|O||D||1
50404906|Mostaza corazón envuelto|O|O||D||1
50405100|Solanáceas (nightshades)|O|O||D||1
50405101|Lámpara china|O|O||D||1
50405102|Mora de jardin|O|O||D||1
50405103|Naranjilla|O|O||D||1
50405104|Tomatillo|O|O||D||1
50405200|Okras|O|O||D||1
50405201|Okra artista|O|O||D||1
50405202|Okra vinotinto|O|O||D||1
50405203|Okra sin columna clemson|O|O||D||1
50405204|Okra verde enano vaina larga|O|O||D||1
50405205|Okra  mamut sin columna|O|O||D||1
50405206|Okra terciopelo rojo|O|O||D||1
50405207|Okra estrella de david reliquia|O|O||D||1
50405300|Cebollas|O|O||D||1
50405301|Cebolla albion|O|O||D||1
50405302|Cebolla alisia craig|O|O||D||1
50405303|Cebolla hirviendo|O|O||D||1
50405304|Cebolla bufalo|O|O||D||1
50405305|Cebolla bulbo|O|O||D||1
50405306|Cebolla cremosa|O|O||D||1
50405307|Cebolla amarillo expreso o – x|O|O||D||1
50405308|Cebolla kelsae|O|O||D||1
50405309|Cebolla gigante marshal globo fen|O|O||D||1
50405310|Cebolla perla|O|O||D||1
50405311|Cebolla baron rojo|O|O||D||1
50405312|Cebolla roja|O|O||D||1|Cebolla morada
50405313|Cebolla rijnsberger|O|O||D||1
50405314|Cebolla senshyu semi – globo amarillo|O|O||D||1
50405315|Cebolla sturon|O|O||D||1
50405316|Cebolla sturgatter|O|O||D||1
50405317|Cebolla dulce|O|O||D||1
50405318|Cebolla torpedo o rojo italiana|O|O||D||1
50405319|Cebolla roja guardada|O|O||D||1
50405320|Cebollablanca guardada|O|O||D||1
50405321|Cebollaamarilla guardada|O|O||D||1
50405322|Cebollarosada|O|O||D||1
50405323|Cebolla verde|O|O||D||1
50405400|Alverjas|O|O||D||1|Alberjones
50405401|Alverja casco morado|O|O||D||1|Alberjón casco morado
50405402|Alverja pinkeye|O|O||D||1|Alberjón pinkeye
50405403|Alverja crowder|O|O||D||1|Alberjón crowder
50405404|Alverja acre blanco|O|O||D||1|Alberjón acre blanco
50405405|Alverja ojo negro|O|O||D||1|Alberjón ojo negro
50405406|Alverja crema zipper|O|O||D||1|Alberjón crema zipper
50405500|Maníes|O|O||D||1|Cacahuates
50405501|Maní bambara|O|O||D||1|Cacahuate bambara
50405502|Maní florunner|O|O||D||1|Cacahuate florunner
50405503|Maní husa / kerstings|O|O||D||1|Cacahuate husa / kerstings
50405504|Maní español|O|O||D||1|Cacahuate español
50405505|Maní valencia|O|O||D||1|Cacahuate valencia
50405506|Maní virginia|O|O||D||1|Cacahuate virginia
50405600|Pimientos|O|O||D||1|Chiles
50405601|Pimentón ají|O|O||D||1|Ají
50405602|Pimentón  árbol|O|O||D||1|Chile de árbol
50405603|Pimentón queso|O|O||D||1
50405604|Pimentón chilaca|O|O||D||1|Chilaca
50405605|Pimentón cubanelles|O|O||D||1|Chile cubanelle o pimienta italiana
50405606|Pimentón fresno|O|O||D||1|Chile fresno
50405607|Pimentón kapia|O|O||D||1|Chile kapia
50405608|Pimentón coreano|O|O||D||1|Chile cheongyang
50405609|Pimentón manzano|O|O||D||1|Chile manzano o de cera
50405610|Pimentón melrose|O|O||D||1
50405611|Pimentón chile amarillo|O|O||D||1|Chile peruano amarillo
50405612|Pimentón aji dulce|O|O||D||1|Ají dulce
50405613|Pimentón anaheim|O|O||D||1
50405614|Pimentón ancho|O|O||D||1|Chile ancho o mulato
50405615|Pimentón campana|O|O||D||1|Chile campana
50405616|Pimentón cascabel|O|O||D||1|Chile cascabel
50405617|Pimentón cayenne|O|O||D||1|Pimienta de Cayena o roja
50405618|Pimentón anfitrión cereza|O|O||D||1
50405619|Pimentón chitespin|O|O||D||1|Chile chiltepín
50405620|Pimentón dedo picante|O|O||D||1|Chile Jwala
50405621|Pimentón guajillo|O|O||D||1|Chile guajillo
50405622|Pimentón guerro|O|O||D||1|Chile güero
50405623|Pimentón habanero|O|O||D||1|Chile habanero
50405624|Pimentón cera de hungria|O|O||D||1|Pimentón húngaro
50405625|Pimentón jalapeño|O|O||D||1|Chile cuaresmeño, Chile jalapeño
50405626|Pimentón picante largo|O|O||D||1|Chile cola de rata
50405627|Pimentón marasol|O|O||D||1|Chile mirasol
50405628|Pimentón pasilla|O|O||D||1|Chile pasilla
50405629|Pimentón peperoncini|O|O||D||1
50405630|Pimentón pequin|O|O||D||1|Chile piquín
50405631|Pimentón pimiento|O|O||D||1|Pimiento morrón
50405632|Pimentón poblano|O|O||D||1|Chile poblano
50405633|Pimentón scotch bonnet|O|O||D||1|Pimientos Bonney o rojos Caribe
50405634|Pimentón serrano|O|O||D||1|Chile serrano, Chile verde
50405635|Pimentón tabasco|O|O||D||1|Chile tabasco
50405636|Pimentón tai|O|O||D||1|Chile ojo de pájaro
50405637|Pimentón tepin|O|O||D||1|Chile mosquito o catarina
50405638|Pimentón chili amaucho|O|O||D||1|Chile arnaucho
50405639|Pimentón chili mochero|O|O||D||1|Chile mochero
50405640|Pimentón chili limo|O|O||D||1|Chile limo
50405700|Papas|O|O||D||1
50405701|Papa blanca larga|O|O||D||1
50405702|Papa redonda blanca|O|O||D||1
50405703|Papa redonda roja|O|O||D||1|Papa de cambray
50405704|Papa  russet|O|O||D||1
50405705|Papa morada|O|O||D||1
50405706|Papa amarilla|O|O||D||1
50405707|Papa nueva|O|O||D||1
50405708|Papa especial|O|O||D||1
50405709|Papa huayro|O|O||D||1
50405710|Papa peruanita|O|O||D||1
50405711|Papa yunggay|O|O||D||1
50405800|Nabos suecos|O|O||D||1
50405801|Nabo sueco acme|O|O||D||1
50405802|Nabo sueco angela|O|O||D||1
50405803|Nabo sueco el mejor|O|O||D||1
50405804|Nabo sueco marian|O|O||D||1
50405900|Vegetales marinos|O|O||D||1
50405901|Agar-agar|O|O||D||1
50405902|Arame|O|O||D||1
50405903|Alga dulse|O|O||D||1
50405904|Habichuelas vert de mer|O|O||D||1
50405905|Hijiki|O|O||D||1
50405906|Musgo irlandes|O|O||D||1
50405907|Quelpo|O|O||D||1
50405908|Laver|O|O||D||1
50405909|Nori|O|O||D||1
50405910|Alga roja|O|O||D||1
50405911|Kale de mar|O|O||D||1
50405912|Lechuga de mar|O|O||D||1
50405913|Algas de mar|O|O||D||1
50405914|Spirulina|O|O||D||1
50405915|Susabi nuri|O|O||D||1
50405916|Wakame|O|O||D||1
50406000|Chalotes|O|O||D||1
50406001|Chalote atlántica|O|O||D||1
50406002|Chalote creación|O|O||D||1
50406003|Chalote drittler nido blanco|O|O||D||1
50406004|Chalote gigante mejorado amarillo|O|O||D||1
50406005|Chalote gourmet dorado|O|O||D||1
50406006|Chalote grise de bagnolet|O|O||D||1
50406007|Chalote hative de nort|O|O||D||1
50406008|Chalote pikant|O|O||D||1
50406009|Chalote papa roja|O|O||D||1
50406010|Chalote sante|O|O||D||1
50406011|Chalote topper|O|O||D||1
50406100|Alazanes|O|O||D||1|Acederas
50406101|Alazán dock|O|O||D||1|Acedera dock
50406102|Alazán jardín|O|O||D||1|Acedera jardín
50406103|Alazán oveja|O|O||D||1|Acedera oveja
50406104|Alazán madera|O|O||D||1|Acedera madera
50406200|Espinacas|O|O||D||1
50406201|Espinaca americana|O|O||D||1
50406202|Espinaca bloomsdale|O|O||D||1
50406203|Espinaca invierno gigante|O|O||D||1
50406204|Espinaca horenso|O|O||D||1
50406205|Espinaca cuarto de cordero|O|O||D||1
50406206|Espinaca malabar|O|O||D||1
50406207|Espinaca medania|O|O||D||1
50406208|Espinaca orach|O|O||D||1
50406209|Espinaca savoy|O|O||D||1
50406210|Espinaca hoja de sigma|O|O||D||1
50406211|Espinaca espacio|O|O||D||1
50406212|Espinaca trinidad|O|O||D||1
50406213|Espinaca salvaje|O|O||D||1
50406224|Espinaca nueva zelandia|O|O||D||1
50406225|Espinaca iceplant|O|O||D||1
50406300|Calabazas|O|O||D||1
50406301|Calabaza boston|O|O||D||1
50406302|Calabaza buttemut|O|O||D||1
50406303|Calabaza costata romanesca|O|O||D||1
50406304|Calabaza crookneck|O|O||D||1
50406305|Calabaza  cucuzza|O|O||D||1
50406306|Calabaza  delicata|O|O||D||1
50406307|Calabaza  delicioso|O|O||D||1
50406308|Calabaza verano dorado cuello torsido|O|O||D||1
50406309|Calabaza prolífico temprano cuello recto|O|O||D||1
50406310|Calabaza  oro|O|O||D||1
50406311|Calabaza  jack pequeño|O|O||D||1
50406312|Calabaza  campo de kentucky|O|O||D||1
50406313|Calabaza marrow|O|O||D||1
50406314|Calabaza  medio oriente|O|O||D||1
50406315|Calabaza  miniatura|O|O||D||1
50406316|Calabaza  orangetti|O|O||D||1
50406317|Calabaza pattypan|O|O||D||1
50406318|Calabaza  rondini|O|O||D||1
50406319|Calabaza  redonda|O|O||D||1
50406320|Calabaza  espagueti|O|O||D||1
50406321|Calabaza  estripeti|O|O||D||1
50406322|Calabaza  molde dulce|O|O||D||1
50406323|Calabaza  empanada dulce|O|O||D||1
50406324|Calabaza  premio triple|O|O||D||1
50406325|Calabaza waltham butternut|O|O||D||1
50406326|Calabaza  arbusto scallop amarillo|O|O||D||1
50406327|Calabaza cuello recto amarillo|O|O||D||1
50406328|Calabaza zafiro|O|O||D||1
50406329|Calabaza zucchini|O|O||D||1
50406400|Batatas|O|O||D||1|Camotes
50406401|Batata beauregard|O|O||D||1|Camote beauregard
50406402|Batata centennial|O|O||D||1|Camote centennial
50406403|Batata diane|O|O||D||1|Camote diane
50406404|Batata dulce garnet|O|O||D||1|Camote dulce garnet
50406405|Batata georgia dulce rojo|O|O||D||1|Camote georgia dulce rojo
50406406|Batata  dorado|O|O||D||1|Camote dorado
50406407|Batata hanna|O|O||D||1|Camote hanna
50406408|Batata japonés|O|O||D||1|Camote japonés
50406409|Batata jersey|O|O||D||1|Camote jersey
50406410|Batata joya|O|O||D||1|Camote joya
50406411|Batata meryland roja|O|O||D||1|Camote meryland roja
50406412|Batata nema dorado|O|O||D||1|Camote nema dorado
50406413|Batata o´henry|O|O||D||1|Camote o´henry
50406414|Batata okinawan|O|O||D||1|Camote okinawan
50406415|Batata naranja|O|O||D||1|Camote naranja
50406416|Batata oriental|O|O||D||1|Camote oriental
50406417|Batata jersey rojo|O|O||D||1|Camote jersey rojo
50406418|Batata mar rojo|O|O||D||1|Camote mar rojo
50406419|Batata brillo rojo|O|O||D||1|Camote brillo rojo
50406420|Batata jersey amarillo|O|O||D||1|Camote jersey amarillo
50406421|Batata morado|O|O||D||1|Camote morado
50406500|Tomates|O|O||D||1|Jitomates
50406501|Tomates ailsa craig|O|O||D||1|Jitomate ailsa craig
50406502|Tomates alicante|O|O||D||1|Jitomate alicante
50406503|Tomates ciruela negra|O|O||D||1|Jitomate ciruela negra
50406504|Tomates vino de brandy|O|O||D||1|Jitomate brandy
50406505|Tomates bella cereza|O|O||D||1|Jitomate cherry belle
50406506|Tomates cereza|O|O||D||1|Jitomate cherry
50406507|Tomates delicioso|O|O||D||1|Jitomate delicioso
50406508|Tomates dombito|O|O||D||1|Jitomate dombito
50406509|Tomates delicia del jardín|O|O||D||1|Jitomate delicia del jardín
50406510|Tomates uva|O|O||D||1|Jitomate uva
50406511|Tomates verde|O|O||D||1|Tomate verde
50406512|Tomates super marmande|O|O||D||1|Jitomate super marmande
50406513|Tomates rayas naturales marvel|O|O||D||1|Jitomate rayas naturales marvel
50406514|Tomates minibel|O|O||D||1|Jitomate minibel
50406515|Tomates oaxacan|O|O||D||1|Jitomate oaxaca
50406516|Tomates alerta roja|O|O||D||1|Jitomate alerta roja
50406517|Tomates roma vf|O|O||D||1|Jitomate roma vf
50406518|Tomates marzano zan|O|O||D||1|Jitomate san marzano
50406519|Tomates shirley|O|O||D||1|Jitomate shirley
50406520|Tomates siberia|O|O||D||1|Jitomate siberia
50406521|Tomates super beefsteak|O|O||D||1|Jitomate super beefsteak
50406522|Tomates tigerella|O|O||D||1|Jitomate tigerella
50406523|Tomates tiny tim|O|O||D||1|Jitomate tiny tim
50406524|Tomates tumbler|O|O||D||1|Jitomate tumbler
50406525|Tomates cocktail amarillo|O|O||D||1
50406526|Tomates forma de pera amarillo|O|O||D||1
50406527|Tomates perfección amarilla|O|O||D||1
50406600|Nabos|O|O||D||1
50406601|Nabo globo verde|O|O||D||1
50406602|Nabo bola dorada|O|O||D||1
50406603|Nabo mercado de manchester|O|O||D||1
50406604|Nabo top morado milan|O|O||D||1
50406605|Nabo top morado blanco|O|O||D||1
50406606|Nabo bola de nieve|O|O||D||1
50406607|Nabo tokio|O|O||D||1
50406608|Nabo cruz de tokio|O|O||D||1
50406700|Auyamas|O|O||D||1|Calabazas gigantes
50406701|Calabaza acorn|O|O||D||1|Calabaza gigante acorn
50406702|Calabaza gigante atlántico|O|O||D||1|Calabaza gigante atlántico
50406703|Calabaza banana rosado|O|O||D||1|Calabaza gigante banana rosado
50406704|Calabaza max grande|O|O||D||1|Calabaza gigante max
50406705|Calabaza|O|O||D||1|Calabaza de castilla
50406706|Calabaza carnaval|O|O||D||1|Calabaza gigante carnaval
50406707|Auyama queso|O|O||D||1|Calabaza gigante queso
50406708|Calabaza príncipe coronado|O|O||D||1|Calabaza gigante príncipe coronado
50406709|Calabaza  curcibita|O|O||D||1|Calabaza gigante curcibita
50406710|Calabaza cushaw|O|O||D||1|Calabaza gigante cushaw
50406711|Calabaza  gigante auyama|O|O||D||1
50406712|Calabaza  hubbard|O|O||D||1|Calabaza gigante hubbard
50406713|Calabaza  jerrahdale|O|O||D||1|Calabaza gigante jerrahdale
50406714|Calabaza  kabocha|O|O||D||1|Calabaza gigante kabocha
50406715|Calabaza queensland azul|O|O||D||1|Calabaza gigante queensland azul
50406716|Calabaza rouge vif détampes|O|O||D||1|Calabaza gigante rouge vif détampes
50406717|Calabaza  turban turco|O|O||D||1|Calabaza gigante turban turco
50406718|Calabaza  valenciano|O|O||D||1|Calabaza gigante valenciano
50406719|Calabaza  warted hubbard|O|O||D||1|Calabaza gigante warted hubbard
50406720|Auyama whangaparoa|O|O||D||1|Calabaza gigante whangaparoa
50406721|Auyama china|O|O||D||1|Calabaza gigante china
50406722|Auyama  loche|O|O||D||1|Calabaza gigante loche
50406723|Auyama  macre|O|O||D||1|Calabaza gigante macre
50406800|Ñames|O|O||D||1
50406801|Ñame agria africana|O|O||D||1
50406802|Ñame agria asiática|O|O||D||1
50406803|Ñame china|O|O||D||1
50406804|Ñame globo|O|O||D||1
50406805|Ñame grater|O|O||D||1
50406806|Ñame japonesa|O|O||D||1
50406807|Ñame lesser|O|O||D||1
50406808|Ñame papa|O|O||D||1
50406809|Ñame guinea blanca|O|O||D||1
50406810|Ñame guinea amarillo|O|O||D||1
50407000|Vegetales Nominant|O|O||D||1|Vegetales predominantes, Nopal
50407001|Alfalfa|O|O||D||1
50407002|Hojas de aloe|O|O||D||1|Hoja de sábila, Penca de sábila
50407003|Apio|O|O||D||1
50407004|Arrurruz|O|O||D||1
50407005|Punta de flecha|O|O||D||1|Sagittaria
50407006|Rúcula|O|O||D||1
50407007|Arum|O|O||D||1|Taro
50407008|Raíz de bambú|O|O||D||1
50407009|Hojas de platano|O|O||D||1
50407010|Batatas|O|O||D||1
50407011|Brotes de frijol|O|O||D||1
50407012|Top de remolacha|O|O||D||1|Betabel
50407013|Melón agrio|O|O||D||1|Balsamina
50407014|Bayas de alcaparra|O|O||D||1
50407015|Carob|O|O||D||1|Algarrobo
50407016|Cha-om|O|O||D||1
50407017|Chayote o guatila|O|O||D||1
50407018|Garbanzo|O|O||D||1
50407019|Verde de crisantemos|O|O||D||1
50407020|Verde de diente de león|O|O||D||1
50407021|Diente de león|O|O||D||1
50407022|Dasheen|O|O||D||1
50407023|Puntas de alverja|O|O||D||1
50407024|Diakon|O|O||D||1|Rábano
50407025|Donqua|O|O||D||1|Ginseng hembra
50407026|Helecho|O|O||D||1|Brotes de helecho
50407027|Gai choi|O|O||D||1|Mostaza castaña
50407028|Gailon|O|O||D||1|Brécol chino
50407029|Galanga|O|O||D||1|Jengibre azul
50407030|Raíz de jengibre|O|O||D||1
50407031|Gobo|O|O||D||1|Garduña
50407032|Brote de lúpulo|O|O||D||1
50407033|Rabano blanco|O|O||D||1|Rábano de caballo
50407034|Jicama|O|O||D||1
50407035|Kuduz|O|O||D||1|Kudzu
50407036|Bulbo de margarita|O|O||D||1|Bulbo de lili chino
50407037|Linkok|O|O||D||1
50407038|Lo bok|O|O||D||1
50407039|Frijol largo|O|O||D||1|Fríjol serpiente
50407040|Raíz de lotus|O|O||D||1|Rosa del Nilo
50407041|Hojas de maguey|O|O||D||1|Hoja de agave, Penca de maguey
50407042|Mallows|O|O||D||1|Malva
50407043|Sapote mamey|O|O||D||1|Mamey
50407044|Moap|O|O||D||1
50407045|Moo|O|O||D||1
50407046|Moqua|O|O||D||1
50407047|Opos|O|O||D||1
50407048|Corazon de palma|O|O||D||1|Palmito
50407049|Paprika|O|O||D||1
50407050|Purslane|O|O||D||1|Verdolaga
50407051|Raddichios|O|O||D||1|Achicoria morada
50407052|Sinquas|O|O||D||1|Zapallo
50407053|Frijol de soya|O|O||D||1
50407054|Spoonwart|O|O||D||1|Hierba del escorbuto
50407055|Uva tassele hyacinth|O|O||D||1
50407056|Taro|O|O||D||1|Tales
50407057|Hoja de taro|O|O||D||1
50407058|Tallo de taro|O|O||D||1
50407059|Tapeguaje|O|O||D||1
50407060|Verde tierno|O|O||D||1
50407061|Tindora|O|O||D||1
50407062|Árbol de cebolla|O|O||D||1|Cebollas egipcias
50407063|Udo|O|O||D||1
50407064|Agua castaño|O|O||D||1|Castaña de agua china
50407065|Agua espinaca|O|O||D||1|Akankong
50407066|Yumpi|O|O||D||1|Mapuey
50407067|Yautia|O|O||D||1
50407068|Yu choy|O|O||D||1
50407070|Yuca|O|O||D||1
50407071|Caigua|O|O||D||1|Achocha
50407100|Alverjas dulces|O|O||D||1|Chícharos
50407101|Alverja biquini|O|O||D||1|Chícharo biquini
50407102|Alverja cavalier|O|O||D||1|Chícharo cavalier
50407103|Alverja margarita|O|O||D||1|Chícharo margarita
50407104|Alverja darfon|O|O||D||1|Chícharo darfon
50407105|Alverja "early onward"|O|O||D||1|Chícharo "early onward"
50407106|Alverja primer feltham|O|O||D||1|Chícharo primer feltham
50407107|Alverja verde hurst shaft|O|O||D||1|Chícharo verde hurst shaft
50407108|Guisante oregón sugar pod|O|O||D||1|Chícharo oregón sugar pod
50407109|Alverja príncipe alberto|O|O||D||1|Chícharo príncipe alberto
50407110|Alverja reuzensuiker|O|O||D||1|Chícharo reuzensuiker
50407200|Tubérculos|O|O||D||1
50407201|Arracacha|O|O||D||1
50407202|Maca|O|O||D||1
50407203|Oca|O|O||D||1
50407204|Olluco|O|O||D||1
50407205|Mashua|O|O||D||1
50411500|Alcachofas orgánicas|O|O||D||1
50411501|Alcachofa britany orgánica|O|O||D||1
50411502|Alcachofa cantonesa orgánica|O|O||D||1
50411503|Alcachofa francesa orgánica|O|O||D||1
50411504|Alcachofa globo verde orgánico|O|O||D||1
50411505|Alcachofa gros cumus de bretaña orgánico|O|O||D||1
50411506|Alcachofa midi orgánico|O|O||D||1
50411507|Alcachofa globo morado orgánico|O|O||D||1
50411508|Alcachofa siciliano morado orgánico|O|O||D||1
50411509|Alcachofa romanesco orgánico|O|O||D||1
50411510|Alcachofa espinoso sardo orgánico|O|O||D||1
50411511|Alcachofa vert de loan  orgánico|O|O||D||1
50411512|Alcachofa violeta di chioggia orgánica|O|O||D||1
50411513|Alcachofa violeta de toscana orgánica|O|O||D||1
50411600|Espárragos orgánicos|O|O||D||1
50411601|Espárragos convers colosal organico|O|O||D||1
50411602|Espárragos franklin orgánico|O|O||D||1
50411603|Espárragos mamut gigante orgánico|O|O||D||1
50411604|Espárragos lucullus orgánico|O|O||D||1
50411605|Espárragos martha washington orgánico|O|O||D||1
50411700|Aguacates orgánicos|O|O||D||1
50411701|Aguacate ajax b-7 orgánico|O|O||D||1
50411702|Aguacate arue orgánico|O|O||D||1
50411703|Aguacate bacon orgánico|O|O||D||1
50411704|Aguacate benik orgánico|O|O||D||1
50411705|Aguacate bemecker orgánico|O|O||D||1
50411706|Aguacate beta orgánico|O|O||D||1
50411707|Aguacate biondo orgánico|O|O||D||1
50411708|Aguacate príncipe negro orgánico|O|O||D||1
50411709|Aguacate blair orgánico|O|O||D||1
50411710|Aguacate blair booth orgánico|O|O||D||1
50411711|Aguacate booth 1 orgánico|O|O||D||1
50411712|Aguacate booth 3 orgánico|O|O||D||1
50411713|Aguacate  booth 5 orgánico|O|O||D||1
50411714|Aguacate booth 7 orgánico|O|O||D||1
50411715|Aguacate booth 8 orgánico|O|O||D||1
50411716|Aguacate brooks 1978 orgánico|O|O||D||1
50411717|Aguacate brookslate orgánico|O|O||D||1
50411718|Aguacate california haas orgánico|O|O||D||1
50411719|Aguacate catalina orgánico|O|O||D||1
50411720|Aguacate chica orgánic|O|O||D||1
50411721|Aguacate choquette orgánico|O|O||D||1
50411722|Aguacate cristina orgánico|O|O||D||1
50411723|Aguacate colison orgánico|O|O||D||1
50411724|Aguacate donie orgánico|O|O||D||1
50411725|Aguacate dr. depuis numero 2 orgánico|O|O||D||1
50411726|Aguacate de. depus orgánico|O|O||D||1
50411727|Aguacate etinger orgánico|O|O||D||1
50411728|Aguacate fuchs orgánico|O|O||D||1
50411729|Aguacate fuchs gwen orgánico|O|O||D||1
50411730|Aguacate fuerte orgánico|O|O||D||1
50411731|Aguacate gorham orgánico|O|O||D||1
50411732|Aguacate gossam orgánico|O|O||D||1
50411733|Aguacate gutemala sin pepe orgánico|O|O||D||1
50411734|Aguacate hall orgánico|O|O||D||1
50411735|Aguacate hardee orgánico|O|O||D||1
50411736|Aguacate haas orgánico|O|O||D||1
50411737|Aguacate herman orgánico|O|O||D||1
50411738|Aguacate hickson orgánico|O|O||D||1
50411739|Aguacate k- 5 orgánico|O|O||D||1
50411740|Aguacate k – 9 orgánico|O|O||D||1
50411741|Aguacate oveja haas orgánico|O|O||D||1
50411742|Aguacate leona orgánico|O|O||D||1
50411743|Aguacate linda leona orgánico|O|O||D||1
50411744|Aguacate lisa p orgánico|O|O||D||1
50411745|Aguacate lisa loretta orgánico|O|O||D||1
50411746|Aguacate loretta organico|O|O||D||1
50411747|Aguacate lula orgánico|O|O||D||1
50411748|Aguacate lula macarthur orgánico|O|O||D||1
50411749|Aguacate marcus orgánico|O|O||D||1
50411750|Aguacate melendez orgánico|O|O||D||1
50411751|Aguacate meya p orgánico|O|O||D||1
50411752|Aguacate miguel p orgánico|O|O||D||1
50411753|Aguacate monroe orgánico|O|O||D||1
50411754|Aguacate murrieta verde orgánico|O|O||D||1
50411755|Aguacate nabal orgánico|O|O||D||1
50411756|Aguacate nadir orgánico|O|O||D||1
50411757|Aguacate nesbitt orgánico|O|O||D||1
50411758|Aguacate peterson orgánico|O|O||D||1
50411759|Aguacate pinelli orgánico|O|O||D||1
50411760|Aguacate pinkerton orgánico|O|O||D||1
50411761|Aguacate pollock orgánico|O|O||D||1
50411762|Aguacate puebla orgánico|O|O||D||1
50411763|Aguacate reed orgánico|O|O||D||1
50411764|Aguacate rue orgánico|O|O||D||1
50411765|Aguacate ruehle orgánico|O|O||D||1
50411766|Aguacate ryan orgánico|O|O||D||1
50411767|Aguacate semil orgánico|O|O||D||1
50411768|Aguacate semil 43 orgánico|O|O||D||1
50411769|Aguacate simmond orgánico|O|O||D||1
50411770|Aguacate  simpson orgánico|O|O||D||1
50411771|Aguacate taylor orgánico|O|O||D||1
50411772|Aguacate tonelada orgánico|O|O||D||1
50411773|Aguacate torre orgánico|O|O||D||1
50411774|Aguacate torre li orgánico|O|O||D||1
50411775|Aguacate trapp orgánico|O|O||D||1
50411776|Aguacate caribe orgánico|O|O||D||1
50411777|Aguacate wagner orgánico|O|O||D||1
50411778|Aguacate waldin orgánico|O|O||D||1
50411779|Aguacate wurtz orgánico|O|O||D||1
50411780|Aguacate zio p orgánico|O|O||D||1
50411781|Aguacate ziu orgánico|O|O||D||1
50411782|Aguacate appaloosa orgánico|O|O||D||1
50411800|Fríjoles orgánicos|O|O||D||1
50411801|Frijoles anasazi™|O|O||D||1
50411802|Frijoles appaloosa orgánicos|O|O||D||1
50411803|Frijoles azuki orgánicos|O|O||D||1
50411804|Frijoles barlotti orgánicos|O|O||D||1
50411805|Frijoles appaloosa negra orgánicos|O|O||D||1
50411806|Frijoles negros orgánicos|O|O||D||1
50411807|Frijoles gran negros orgánicos|O|O||D||1
50411808|Frijoles shackamaxon negro orgánicos|O|O||D||1
50411809|Frijoles ojo negro orgánicos|O|O||D||1
50411810|Frijoles bobby orgánicos|O|O||D||1
50411811|Frijoles bolita orgánicos|O|O||D||1
50411812|Frijoles esposa perezosa carmelita orgánicos|O|O||D||1
50411813|Frijoles calipso orgánicos|O|O||D||1
50411814|Frijoles canelini orgánicos|O|O||D||1
50411815|Frijoles castor orgánicos|O|O||D||1
50411816|Frijoles amarillo chino orgánicos|O|O||D||1
50411817|Frijoles lengua de dragón orgánicos|O|O||D||1
50411818|Frijoles soldado europeo orgánicos|O|O||D||1
50411819|Frijoles fava orgánicos|O|O||D||1
50411820|Frijoles flageolet orgánicos|O|O||D||1
50411821|Frijoles  horticultura francesa orgánicos|O|O||D||1
50411822|Frijoles marina francesa orgánicos|O|O||D||1
50411823|Frijoles coco gigante blanco orgánicos|O|O||D||1
50411824|Frijoles verdes orgánicos|O|O||D||1
50411825|Frijoles romano verde orgánicos|O|O||D||1
50411826|Frijoles guar gum orgánicos|O|O||D||1
50411827|Frijoles haricot orgánicos|O|O||D||1
50411828|Frijoles hyacinth orgánicos|O|O||D||1
50411829|Frijoles tipo italiano orgánicos|O|O||D||1
50411830|Frijoles asombro jackson orgánicos|O|O||D||1
50411831|Frijoles ganado jacobs  orgánicos|O|O||D||1
50411832|Frijoles asombro kentucky orgánicos|O|O||D||1
50411833|Frijoles riñón orgánicos|O|O||D||1
50411834|Frijoles lima orgánicos|O|O||D||1
50411835|Frijoles madera orgánicos|O|O||D||1
50411836|Frijoles medula orgánicos|O|O||D||1
50411837|Frijoles mat orgánicos|O|O||D||1
50411838|Frijoles monstoler ganzo salvaje orgánicos|O|O||D||1
50411839|Frijoles  mortgage lifter orgánicos|O|O||D||1
50411840|Frijoles polilla orgánicos|O|O||D||1
50411841|Frijoles mung orgánicos|O|O||D||1
50411842|Frijoles munsi wolf orgánicos|O|O||D||1
50411843|Frijoles nuna orgánicos|O|O||D||1
50411844|Frijoles pinto orgánicos|O|O||D||1
50411845|Frijoles runner orgánicos|O|O||D||1
50411846|Frijoles string orgánicos|O|O||D||1|Ayecote orgánico, Fríjol gordo orgánico
50411847|Frijoles habichuelas orgánicos|O|O||D||1|Ejote orgánico, Fríjol tierno orgánico
50411848|Frijoles tamarind orgánicos|O|O||D||1
50411849|Frijoles tonka orgánicos|O|O||D||1
50411850|Frijoles cera orgánicos|O|O||D||1
50411851|Frijoles winged orgánicos|O|O||D||1
50411852|Frijoles largos orgánicos|O|O||D||1
50411900|Remolachas orgánicas|O|O||D||1|Betabeles orgánicos
50411901|Remolacha acción orgánicos|O|O||D||1|Betabel acción orgánicos
50411902|Remolacha albina vereduna orgánica|O|O||D||1|Betabel albina vereduna orgánico
50411903|Remolacha barababiotela de chiggia orgánica|O|O||D||1|Betabel barababiotela de chiggia orgánico
50411904|Remolacha boltardy orgánica|O|O||D||1|Betabel boltardy orgánico
50411905|Remolacha bonel orgánica|O|O||D||1|Betabel bonel orgánico
50411906|Remolacha burpees dorado orgánica|O|O||D||1|Betabel burpees dorado orgánico
50411907|Remolacha cheltenham tapa verde orgánica|O|O||D||1|Betabel cheltenham tapa verde orgánico
50411908|Remolacha cheltenham mono orgánica|O|O||D||1|Betabel cheltenham mono orgánico
50411909|Remolacha chioggia orgánica|O|O||D||1|Betabel chioggia orgánico
50411910|Remolacha cilindra orgánica|O|O||D||1|Betabel cilindra orgánico
50411911|Remolacha dégypte orgánica|O|O||D||1|Betabel dégypte orgánico
50411912|Remolacha detroit 2 rojo oscuro orgánica|O|O||D||1|Betabel detroit 2 rojo oscuro orgánico
50411913|Remolacha detroit 2 bala chiquita orgánica|O|O||D||1|Betabel detroit 2 bala chiquita orgánico
50411914|Remolacha egipcia plana  orgánica|O|O||D||1|Betabel egipcia plana orgánico
50411915|Remolacha  raíz de nabo egipcio orgánica|O|O||D||1|Betabel raíz de nabo egipcio orgánico
50411916|Remolacha fomanova orgánica|O|O||D||1|Betabel fomanova orgánico
50411917|Remolacha forono orgánica|O|O||D||1|Betabel forono orgánico
50411918|Remolacha monaco orgánica|O|O||D||1|Betabel mónaco orgánico
50411919|Remolacha monograma orgánica|O|O||D||1|Betabel monograma orgánico
50411920|Remolacha pronto orgánica|O|O||D||1|Betabel pronto orgánico
50411921|Remolacha regalía orgánica|O|O||D||1|Betabel regalía orgánico
50411922|Remolacha dulce orgánica|O|O||D||1|Betabel dulce orgánico
50412000|Brócolis orgánicas|O|O||D||1
50412001|Brócoli orgánico|O|O||D||1
50412002|Brócoli romanesco orgánico|O|O||D||1
50412003|Brócoli raab orgánico|O|O||D||1
50412004|Brócoli chino orgánico|O|O||D||1
50412100|Repollitos de Bruselas orgánicas|O|O||D||1|Coles de Bruselas orgánicas
50412101|Repollitas de bruselas citade orgánicas|O|O||D||1|Coles de Bruselas citade orgánicas
50412102|Repollitas de bruselas falstaff orgánicas|O|O||D||1|Coles de Bruselas falstaff orgánicas
50412103|Repollitas de bruselas oliver orgánicas|O|O||D||1|Coles de Bruselas oliver orgánicas
50412104|Repollitas de bruselas peer gynt orgánicas|O|O||D||1|Coles de Bruselas peer gynt orgánicas
50412105|Repollitas de bruselas rampart orgánicas|O|O||D||1|Coles de Bruselas rampart orgánicas
50412106|Repollitas de bruselas rubine orgánicas|O|O||D||1|Coles de Bruselas rubine orgánicas
50412107|Repollitas de bruselas  widgeon orgánicas|O|O||D||1|Coles de Bruselas widgeon orgánicas
50412200|Cebollas de ensalada orgánicas|O|O||D||1|Cebollas de cambray orgánicas
50412201|Cebolla belstville ensalada orgánica|O|O||D||1|Cebolla de cambray belstville orgánica
50412202|Cebolla feast ensalada orgánica|O|O||D||1|Cebolla de cambray feast orgánica
50412203|Cebolla ishikura ensalada orgánica|O|O||D||1|Cebolla de cambray ishikura orgánica
50412204|Cebolla mercado kyoto orgánica|O|O||D||1|Cebolla de cambray mercado kyoto orgánica
50412205|Cebolla barba roja ensalada orgánica|O|O||D||1|Cebolla de cambray barba roja orgánica
50412206|Cebolla amigo rojo ensalada orgánica|O|O||D||1|Cebolla de cambray amigo rojo orgánica
50412207|Cebolla santa claus orgánica|O|O||D||1|Cebolla de cambray santa claus orgánica
50412208|Cebolla tokyo ensalada orgánica|O|O||D||1|Cebolla de cambray tokyo orgánica
50412209|Cebolla lisbon blanca ensalada orgánica|O|O||D||1|Cebolla de cambray lisbon blanca orgánica
50412210|Cebolla invierno blanca ensalada orgánica|O|O||D||1|Cebolla de cambray invierno blanca orgánica
50412211|Cebolla final de invierno ensalada orgánica|O|O||D||1|Cebolla de cambray final de invierno orgánica
50412300|Repollos orgánicos|O|O||D||1|Coles orgánicas
50412301|Repollo negro orgánico|O|O||D||1|Col negro orgánica
50412302|Repollo savoy orgánico|O|O||D||1|Col savoy orgánica
50412303|Repollo zorrillo orgánico|O|O||D||1|Col zorrillo orgánica
50412304|Repollo blanco orgánico|O|O||D||1|Col blanco orgánica
50412400|Cardos orgánicos|O|O||D||1|Cardos comestibles orgánicos
50412401|Cardos lunghi orgánico|O|O||D||1|Cardo comestible lunghi orgánicos
50412402|Cardos gobbi orgánico|O|O||D||1|Cardo comestible gobbi orgánicos
50412500|Zanahorias orgánicas|O|O||D||1
50412501|Zanahoria amsterdam orgánica|O|O||D||1
50412502|Zanahoria rey de otoño orgánica|O|O||D||1
50412503|Zanahoria berlicum orgánica|O|O||D||1
50412504|Zanahoria chantenay orgánica|O|O||D||1
50412505|Zanahoria nantes orgánica|O|O||D||1
50412506|Zanahoria mercado de parís orgánica|O|O||D||1
50412600|Coliflores orgánicas|O|O||D||1
50412601|Coliflor todo el año orgánica|O|O||D||1
50412602|Coliflor alverda orgánica|O|O||D||1
50412603|Coliflor otoño gigante 3 orgánica|O|O||D||1
50412604|Coliflor dok elgon orgánica|O|O||D||1
50412605|Coliflor bola de nieve temprana orgánica|O|O||D||1
50412606|Coliflor luz de lima orgánica|O|O||D||1
50412607|Coliflor minaret orgánica|O|O||D||1
50412608|Coliflor buque de naranja orgánica|O|O||D||1
50412609|Coliflor capa morada orgánica|O|O||D||1
50412610|Coliflor bola de nieve orgánica|O|O||D||1
50412611|Coliflor invierno walcheren 3 orgánica|O|O||D||1
50412612|Coliflor piedra blanca orgánica|O|O||D||1
50412700|Apios orgánicos|O|O||D||1
50412701|Apio celebridad orgánico|O|O||D||1
50412702|Apio  orgánico|O|O||D||1
50412703|Apio chino orgánico|O|O||D||1
50412704|Apio dinant francés orgánico|O|O||D||1
50412705|Apio gigante rosado orgánico|O|O||D||1
50412706|Apio gigante rojo orgánico|O|O||D||1
50412707|Apio gigante blanco orgánico|O|O||D||1
50412708|Apio dorado auto escalado orgánico|O|O||D||1
50412709|Apio "greensleeves" orgánico|O|O||D||1
50412710|Apio hopkins fenlander orgánico|O|O||D||1
50412711|Apio torre marfil orgánico|O|O||D||1
50412712|Apio lathom blanqueado orgánico|O|O||D||1
50412713|Apio sopa de amsterdam orgánico|O|O||D||1
50412714|Apio estándar cargado orgánico|O|O||D||1
50412715|Apio triunfo alto utah orgánico|O|O||D||1
50412800|Acelgas orgánicas|O|O||D||1
50412801|Acelga  fordhook gigante orgánica|O|O||D||1
50412802|Acelga gigantelucullus orgánica|O|O||D||1
50412803|Acelga espinaca perpetua orgánica|O|O||D||1
50412804|Acelga ruibarbo perpetua orgánica|O|O||D||1
50412805|Acelga suizo orgánica|O|O||D||1
50412806|Acelga volcan orgánica|O|O||D||1
50412807|Acelga rey blanco orgánica|O|O||D||1
50412900|Achicorias  orgánicas|O|O||D||1|Escarolas  orgánicas
50412901|Achicoria batavian hoja ancha orgánica|O|O||D||1|Escarola batavian hoja ancha orgánica
50412902|Achicoria en cornet de bordeaux orgánica|O|O||D||1|Escarola en cornet de bordeaux orgánica
50412903|Achicoria rollo verde ruffee orgánica|O|O||D||1|Escarola rollo verde ruffee orgánica
50412904|Achicoria roll verde orgánica|O|O||D||1|Escarola roll verde orgánica
50412905|Achicoria limnoe lone orgánica|O|O||D||1|Escarola limnoe lone orgánica
50412906|Achicoria pancalieri riccia orgánica|O|O||D||1|Escarola pancalieri riccia orgánica
50412907|Achicoria ensalada rey orgánica|O|O||D||1|Escarola ensalada rey orgánica
50412908|Achicoria sanda orgánica|O|O||D||1|Escarola sanda orgánica
50412909|Achicoria scarola verde orgánica|O|O||D||1|Escarola scarola verde orgánica
50412910|Achicoria tres fine maraichere orgánica|O|O||D||1|Escarola tres fine maraichere orgánica
50412911|Achicoria wallone freisee wescelkkopf orgánica|O|O||D||1|Escarola wallone freisee wescelkkopf orgánica
50413000|Repollos chinos orgánicos|O|O||D||1|Coles chinas orgánicas
50413001|Bok choy orgánico|O|O||D||1
50413002|Bok choy enano orgánico|O|O||D||1
50413003|Flor de repollo chino orgánico|O|O||D||1|Flor de col china orgánico
50413004|Choy sum orgánico|O|O||D||1
50413005|Col (bok choy) enano orgánico|O|O||D||1
50413006|Col (bok choy) fengshan orgánico|O|O||D||1
50413007|Col (bok choy) jade pagoda orgánico|O|O||D||1
50413008|Col (bok choy) kasumi orgánico|O|O||D||1
50413009|Col (bok choy)  nerva orgánico|O|O||D||1
50413010|Col (bok choy) rosette orgánico|O|O||D||1
50413011|Col (bok choy) ruffles orgánico|O|O||D||1
50413012|Col (bok choy) hoja  santo serrated orgánico|O|O||D||1
50413013|Col (bok choy) shangahai orgánico|O|O||D||1
50413014|Shantung orgánico|O|O||D||1
50413015|Repollo tip top orgánico|O|O||D||1|Col china tip top orgánico
50413016|Yau choy sum orgánico|O|O||D||1
50413100|Cebollines orgánicos|O|O||D||1
50413101|Cebollín chino orgánico|O|O||D||1
50413200|Berros  orgánicos|O|O||D||1
50413201|Berros de tierra orgánico|O|O||D||1
50413202|Nasturtium orgánico|O|O||D||1
50413203|Berros de agua orgánico|O|O||D||1
50413204|Berros de invierno orgánico|O|O||D||1
50413300|Cocombros  orgánicos|O|O||D||1|Pepinos cohombro orgánicos
50413301|Cocombro arena orgánico|O|O||D||1|Pepino cohombro arena orgánico
50413302|Cocombro americano orgánico|O|O||D||1|Pepino cohombro americano orgánico
50413303|Cocombro atena orgánico|O|O||D||1|Pepino cohombro atena orgánico
50413304|Cocombro blanco lungo de parigi orgánico|O|O||D||1|Pepino cohombro blanco lungo de parigi orgánico
50413305|Cocombro verde burpless buen sabor orgánico|O|O||D||1|Pepino cohombro verde burpless buen sabor orgánico
50413306|Cocombro chicago pickling orgánico|O|O||D||1|Pepino cohombro chicago pickling orgánico
50413307|Cocombro manzana cristal orgánico|O|O||D||1|Pepino cohombro manzana cristal orgánico
50413308|Cocombro limón cristal orgánico|O|O||D||1|Pepino cohombro limón cristal orgánico
50413309|Cocombro danimas orgánico|O|O||D||1|Pepino cohombro danimas orgánico
50413310|Cocombro gherkin orgánico|O|O||D||1|Pepino cohombro gherkin orgánico
50413311|Cocombro hokus orgánico|O|O||D||1|Pepino cohombro hokus orgánico
50413312|Cocombro japonés orgánico|O|O||D||1|Pepino cohombro japonés orgánico
50413313|Cocombro karela orgánico|O|O||D||1|Pepino cohombro karela orgánico
50413314|Cocombro korila orgánico|O|O||D||1|Pepino cohombro korila orgánico
50413315|Cocombro verde largo mejorado orgánico|O|O||D||1|Pepino cohombro verde largo mejorado orgánico
50413316|Cocombro mas mercado orgánico|O|O||D||1|Pepino cohombro mas mercado orgánico
50413317|Cocombro enano orgánico|O|O||D||1|Pepino cohombro enano orgánico
50413318|Cocombro pickling nacional orgánico|O|O||D||1|Pepino cohombro pickling nacional orgánico
50413319|Cocombro persa orgánico|O|O||D||1|Pepino cohombro persa orgánico
50413320|Cocombro telégrafo orgánico|O|O||D||1|Pepino cohombro telégrafo orgánico
50413321|Cocombro telégrafo mejorado orgánico|O|O||D||1|Pepino cohombro telégrafo mejorado orgánico
50413322|Cocombro vert de massy cornichon orgánico|O|O||D||1|Pepino cohombro vert de massy cornichon orgánico
50413323|Cocombro yamato orgánico|O|O||D||1|Pepino cohombro yamato orgánico
50413400|Berenjenas  orgánicas|O|O||D||1
50413401|Berenjena bambino orgánica|O|O||D||1
50413402|Berenjena  belleza negra orgánica|O|O||D||1
50413403|Berenjena  negra enorme orgánica|O|O||D||1
50413404|Berenjena  chino orgánica|O|O||D||1
50413405|Berenjena  huevo de pascua orgánica|O|O||D||1
50413406|Berenjena  filipino orgánica|O|O||D||1
50413407|Berenjena   mercado de florida orgánica|O|O||D||1
50413408|Berenjena  india orgánica|O|O||D||1
50413409|Berenjena  italiano orgánica|O|O||D||1
50413410|Berenjena  japonés orgánica|O|O||D||1
50413411|Berenjena  morado largo orgánica|O|O||D||1
50413412|Berenjena   rayas larga orgánica|O|O||D||1
50413413|Berenjena  mercado de dinero orgánica|O|O||D||1
50413414|Berenjena  ova orgánica|O|O||D||1
50413415|Berenjena   arveja orgánica|O|O||D||1
50413416|Berenjena  tom bajito orgánica|O|O||D||1
50413417|Berenjena  siciliano orgánica|O|O||D||1
50413418|Berenjena  tailandés orgánica|O|O||D||1
50413419|Berenjena  violeta de florencia orgánica|O|O||D||1
50413420|Berenjena  blanco orgánica|O|O||D||1
50413500|Endivias  orgánicas|O|O||D||1
50413501|Endivias witloof de brucelas orgánicas|O|O||D||1
50413502|Endivias francocastel orgánicas|O|O||D||1
50413503|Endivias catalogna de galantina orgánicas|O|O||D||1
50413504|Endivias chioggia orgánicas|O|O||D||1
50413505|Endivias grumolo verde orgánicas|O|O||D||1
50413506|Endivias raíz larga magdeburg orgánicas|O|O||D||1
50413507|Endivias palla rosa zorzi precoce orgánicas|O|O||D||1
50413508|Endivias radice amare orgánicas|O|O||D||1
50413509|Endivias rosa de traviso orgánicas|O|O||D||1
50413510|Endivias  rosa de verona orgánicas|O|O||D||1
50413511|Endivias soncino orgánicas|O|O||D||1
50413512|Endivias sugarthi orgánicas|O|O||D||1
50413513|Endivias verona orgánicas|O|O||D||1
50413514|Endivias witloof zoom orgánicas|O|O||D||1
50413600|Hinojos  orgánicos|O|O||D||1
50413601|Hinojo cantino orgánico|O|O||D||1
50413602|Hinojo fino orgánico|O|O||D||1
50413603|Hinojoherald orgánico|O|O||D||1
50413604|Hinojo perfección orgánico|O|O||D||1
50413605|Hinojo sirio orgánico|O|O||D||1
50413606|Hinojo florencia dulce orgánico|O|O||D||1
50413607|Hinojo tardo orgánico|O|O||D||1
50413700|Ajos  orgánicos|O|O||D||1
50413701|Ajo tarde california orgánico|O|O||D||1
50413702|Ajo tallos chinos orgánico|O|O||D||1
50413703|Ajo cebollin orgánico|O|O||D||1
50413704|Ajo germidor orgánico|O|O||D||1
50413705|Ajo guardado largo orgánico|O|O||D||1
50413706|Ajo ramson orgánico|O|O||D||1
50413707|Ajo rocambola orgánico|O|O||D||1
50413708|Ajo rosa de lautrec orgánico|O|O||D||1
50413709|Ajo solent blanco orgánico|O|O||D||1
50413710|Ajo morado español orgánico|O|O||D||1
50413711|Ajo valentina italiana orgánico|O|O||D||1
50413800|Calabazas orgánicas|O|O||D||1
50413801|Petula orgánica|O|O||D||1|Luffa orgánica
50413802|Melon amargo orgánico|O|O||D||1
50413803|Botella calabaza orgánica|O|O||D||1|Mate orgánico
50413804|Calabash gounds orgánico|O|O||D||1|Calabaza de peregrino orgánica
50413805|Melón peludo orgánico|O|O||D||1
50413806|Calabaza amarga orgánica|O|O||D||1
50413807|Loofah suave orgánico|O|O||D||1|Zapatillo suave orgánico
50413808|Serpiente de calabaza orgánica|O|O||D||1|Chichinda orgánica
50413809|Calabaza larga amarga orgánica|O|O||D||1
50413810|Calabaza tinda orgánica|O|O||D||1
50413811|Calabaza tindoori orgánica|O|O||D||1
50413900|Guisantes orgánicos|O|O||D||1|Chícharos orgánicos
50413901|Guisante chino orgánica|O|O||D||1|Chícharo chino orgánico
50413902|Guisante inglés orgánica|O|O||D||1|Chícharo inglés orgánico
50413903|Guisante de jardín orgánica|O|O||D||1|Chícharo de jardín orgánico
50413904|Guisante nieve orgánica|O|O||D||1|Chícharo nieve orgánico
50413906|Guisante snap dulce orgánica|O|O||D||1|Chícharo snap dulce orgánico
50414000|Hierbas orgánicas|O|O||D||1|Perejil orgánico, Yerbabuena o hierbabuena orgánica
50414001|Albahaca orgánica|O|O||D||1
50414002|Laurel orgánico|O|O||D||1
50414003|Borraja orgánica|O|O||D||1
50414004|Alcaravea orgánica|O|O||D||1
50414005|Perifollo orgánico|O|O||D||1
50414006|Cilantro orgánico|O|O||D||1
50414007|Chipolinos orgánicos|O|O||D||1
50414008|Hoja de curry orgánica|O|O||D||1
50414009|Eneldo orgánico|O|O||D||1
50414010|Epazote orgánico|O|O||D||1
50414011|Fenogreco orgánico|O|O||D||1
50414012|Limonaria orgánica|O|O||D||1|Té de limón orgánico
50414013|Mejorana orgánica|O|O||D||1
50414014|Menta orgánica|O|O||D||1
50414015|Orégano orgánico|O|O||D||1
50414016|Pápalo orgánico|O|O||D||1
50414017|Pápalo delgado orgánico|O|O||D||1
50414018|Perilla orgánica|O|O||D||1|Albahaca japonesa orgánica
50414019|Recao orgánico|O|O||D||1
50414020|Romero orgánico|O|O||D||1
50414021|Salvia orgánica|O|O||D||1
50414022|Salsifí orgánica|O|O||D||1|Barba cabruna orgánica
50414023|Satureja orgánica|O|O||D||1|Ajedreas  orgánica
50414024|Estragón orgánico|O|O||D||1|Tarragón  orgánico
50414025|Tomillo orgánico|O|O||D||1
50414026|Tumeric orgánico|O|O||D||1|Cúrcuma orgánica
50414027|Verdolaga orgánica|O|O||D||1
50414100|Coles  orgánicos|O|O||D||1
50414101|Col rizada orgánica|O|O||D||1
50414102|Repollo verde orgánico|O|O||D||1
50414200|Colinabos orgánicos|O|O||D||1|Colirrábanos orgánicos
50414201|Colinabo estrella azur orgánico|O|O||D||1|Colirrábano estrella azur orgánico
50414202|Colinabo verde viena orgánico|O|O||D||1|Colirrábano verde viena orgánico
50414203|Colinabo lanro orgánico|O|O||D||1|Colirrábano lanro orgánico
50414204|Colinabo viena morada orgánico|O|O||D||1|Colirrábano viena morada orgánico
50414205|Colinabo trero rowel orgánico|O|O||D||1|Colirrábano trero rowel orgánico
50414206|Colinabo viena blanca orgánico|O|O||D||1|Colirrábano viena blanca orgánico
50414300|Puerros orgánicos|O|O||D||1|Poros orgánicos
50414301|Puerro cobra gigante otoño orgánico|O|O||D||1|Poro cobra gigante otoño orgánico
50414302|Puerro otoño mamut 2 orgánico|O|O||D||1|Poro otoño mamut 2 orgánico
50414303|Puerro blue de solaise orgánico|O|O||D||1|Poro blue de solaise orgánico
50414304|Puerro cortina orgánico|O|O||D||1|Poro cortina orgánico
50414305|Puerro prelina orgánico|O|O||D||1|Poro prelina orgánico
50414306|Puerro salvaje orgánico|O|O||D||1|Poro salvaje orgánico
50414400|Lentejas  orgánicas|O|O||D||1
50414401|Lenteja beluga orgánica|O|O||D||1
50414402|Lenteja  verde francesa orgánica|O|O||D||1
50414403|Lenteja verde orgánica|O|O||D||1
50414404|Lenteja crimson pequeña orgánica|O|O||D||1
50414405|Lenteja pardina española orgánica|O|O||D||1
50414406|Lenteja roja separada orgánica|O|O||D||1
50414407|Lenteja amarilla separad orgánica|O|O||D||1
50414408|Lenteja tarahumara rosada orgánica|O|O||D||1
50414500|Lechugas  orgánicas|O|O||D||1
50414501|Lechuga  bibb orgánica|O|O||D||1
50414502|Lechuga  boston orgánica|O|O||D||1
50414503|Lechuga frisee orgánica|O|O||D||1
50414504|Lechuga rosa lola orgánica|O|O||D||1
50414505|Lechuga  mixta masculina orgánica|O|O||D||1
50414506|Lechuga mizuna orgánica|O|O||D||1
50414507|Lechuga hoja roja orgánica|O|O||D||1
50414508|Lechuga oja roja roble orgánica|O|O||D||1
50414509|Lechuga romana ruby orgánica|O|O||D||1
50414510|Lechuga romana bebé roja orgánica|O|O||D||1
50414511|Lechuga cabeza de mantequilla orgánica|O|O||D||1
50414512|Lechuga china orgánica|O|O||D||1|Lechuga orejona orgánica
50414513|Lechuga cabeza tostada orgánica|O|O||D||1
50414514|Lechuga hoja verde orgánica|O|O||D||1
50414515|Lechuga iceberg orgánica|O|O||D||1
50414516|Lechuga cordero orgánica|O|O||D||1
50414517|Lechuga hoja suelta orgánica|O|O||D||1
50414518|Lechuga mache orgánica|O|O||D||1
50414519|Lechuga boston roja orgánica|O|O||D||1
50414520|Lechuga cabeza roja orgánica|O|O||D||1
50414521|Lechuga romana orgánica|O|O||D||1
50414522|Lechuga mostza roja rusa orgánica|O|O||D||1
50414523|Lechuga tatsoi orgánica|O|O||D||1
50414600|Ñames orgánicos|O|O||D||1
50414601|Ñame amarilla orgánica|O|O||D||1
50414602|Ñame blanca orgánica|O|O||D||1
50414603|Ñame coco orgánica|O|O||D||1
50414604|Ñame eddoes orgánica|O|O||D||1
50414605|Ñame isleña orgánica|O|O||D||1
50414606|Ñame lila orgánica|O|O||D||1
50414700|Hongos o champiñones  orgánicos|O|O||D||1
50414701|Champiñón trompeta negra orgánico|O|O||D||1
$sat$, E'\n') as l
 where l <> ''
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
