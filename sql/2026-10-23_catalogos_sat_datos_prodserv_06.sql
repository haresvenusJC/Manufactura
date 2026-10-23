-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 6 de 10 (6283 claves; total 52513)
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
50301649|Albaricoque tilton|O|O||D||1|Chabacano tilton
50301650|Albaricoque tomcot|O|O||D||1|Chabacano tomcot
50301651|Albaricoque tracy|O|O||D||1|Chabacano tracy
50301652|Albaricoque tri gem|O|O||D||1|Chabacano tri gem
50301653|Albaricoque valley dorado|O|O||D||1|Chabacano valley dorado
50301654|Albaricoque westley|O|O||D||1|Chabacano westley
50301655|Albaricoque  york|O|O||D||1|Chabacano york
50301700|Bananos|O|O||D||1|Plátanos
50301701|Banana apple|O|O||D||1|Plátano apple
50301702|Banana bebe|O|O||D||1|Plátano bebe
50301703|Banana burro|O|O||D||1|Plátano burro
50301704|Bananas cavendish|O|O||D||1|Plátano cavendish
50301705|Bananas dominico|O|O||D||1|Plátano dominico
50301706|Bananas green|O|O||D||1|Plátano green
50301707|Bananas gros michel|O|O||D||1|Plátano gros michel
50301708|Bananas lacatan|O|O||D||1|Plátano lacatan
50301709|Bananas dedo de dama|O|O||D||1|Plátano dedo de dama
50301710|Bananas manzano|O|O||D||1|Plátano manzano
50301711|Banana mysore|O|O||D||1|Plátano mysore
50301712|Banana pisang mas|O|O||D||1|Plátano pisang mas
50301713|Bananas rojo|O|O||D||1|Plátano rojo
50301714|Bananas saba|O|O||D||1|Plátano saba
50301715|Bananas sucrier|O|O||D||1|Plátano sucrier
50301716|Bananas palillo|O|O||D||1|Plátano palillo
50301717|Bananas purple|O|O||D||1|Plátano purple
50301718|Bananas isla|O|O||D||1|Plátano isla
50301800|Barberries|O|O||D||1|Berberís
50301801|Berberís paleleaf|O|O||D||1|Berberí paleleaf
50301802|Barberís chenault|O|O||D||1|Berberí chenault
50301803|Barberries rojo|O|O||D||1|Berberí rojo
50301804|Barberís wintergreen|O|O||D||1|Berberí wintergreen
50301805|Barberís korean|O|O||D||1|Berberí korean
50301806|Barberís mentor|O|O||D||1|Berberí mentor
50301807|Barberís japanese|O|O||D||1|Berberí japanese
50301808|Barberís atropurpurea|O|O||D||1|Berberí atropurpurea
50301809|Barberís aurea|O|O||D||1|Berberí aurea
50301810|Barberís bagatelle|O|O||D||1|Berberí bagatelle
50301811|Barberís crimsom pygmy|O|O||D||1|Berberí crimsom pygmy
50301812|Barberís kobold|O|O||D||1|Berberí kobold
50301813|Barberís warty|O|O||D||1|Berberí warty
50301814|Barberís  europea|O|O||D||1|Berberí europea
50301900|Gayubas|O|O||D||1|Rastreras
50301901|Gayuba alpine|O|O||D||1|Rastrera alpine
50301902|Gayuba roja|O|O||D||1|Rastrera roja
50301903|Gayuba comun|O|O||D||1|Rastrera común
50302000|Moras|O|O||D||1|Zarzamoras
50302001|Mora apache|O|O||D||1|Zarzamora apache
50302002|Mora negro satin|O|O||D||1|Zarzamora negro satín
50302003|Mora|O|O||D||1|Zarzamora
50302004|Mora cherokee|O|O||D||1|Zarzamora cherokee
50302005|Mora chester|O|O||D||1|Zarzamora chéster
50302006|Mora dirksen|O|O||D||1|Zarzamora dirksen
50302007|Bayas josta|O|O||D||1|Zarzamora josta
50302008|Bayas logan|O|O||D||1|Zarzamora logan
50302009|Bayas marion|O|O||D||1|Zarzamora marion
50302010|Mora navaho|O|O||D||1|Zarzamora navaho
50302011|Baya nectar|O|O||D||1|Zarzamora néctar
50302012|Mora olallie|O|O||D||1|Zarzamora olallie
50302013|Baya tay|O|O||D||1|Zarzamora tay
50302014|Mora thomless hull|O|O||D||1|Zarzamora thomless hull
50302015|Baya young|O|O||D||1|Zarzamora young
50302100|Arándanos de mirto|O|O||D||1|Mirtillos
50302101|Arandanos bog|O|O||D||1|Mirtillo bog
50302102|Arandanos dwarf|O|O||D||1|Mirtillo enano
50302103|Arandanos mountain|O|O||D||1|Mirtillo de montaña
50302104|Arandanos oval-leaved|O|O||D||1|Mirtillo oval-leaved
50302200|Agrás|O|O||D||1|Frutos azules del bosque
50302201|Agras bluecrop|O|O||D||1|Fruto azul del bosque bluecrop
50302202|Agras bluetta|O|O||D||1|Fruto azul del bosque bluetta
50302203|Agras brigitta|O|O||D||1|Fruto azul del bosque brigitta
50302204|Agras chandler|O|O||D||1|Fruto azul del bosque chandler
50302205|Agras duque|O|O||D||1|Fruto azul del bosque duque
50302206|Agras hrdyblue|O|O||D||1|Fruto azul del bosque hrdyblue
50302207|Agras legacy|O|O||D||1|Fruto azul del bosque legacy
50302208|Agras misty|O|O||D||1|Fruto azul del bosque misty
50302209|Agras nelson|O|O||D||1|Fruto azul del bosque nelson
50302210|Agras northblue|O|O||D||1|Fruto azul del bosque northblue
50302211|Agras northcountry|O|O||D||1|Fruto azul del bosque northcountry
50302212|Agras northsky|O|O||D||1|Fruto azul del bosque northsky
50302213|Agras patriot|O|O||D||1|Fruto azul del bosque patriot
50302214|Agras spartan|O|O||D||1|Fruto azul del bosque spartan
50302215|Agras toro|O|O||D||1|Fruto azul del bosque toro
50302300|Fruta del pan|O|O||D||1
50302301|Fruta de pan chataigne|O|O||D||1|Fruta del pan chataigne
50302302|Fruta de pan sin pepa|O|O||D||1|Fruta del pan sin semilla
50302303|Fruta de pan corazón blanco|O|O||D||1|Fruta del pan corazón blanco
50302304|Fruta de pan corazón amarillo|O|O||D||1|Fruta del pan corazón amarillo
50302400|Chirimoyas|O|O||D||1|Annonas
50302401|Chirimoya chays|O|O||D||1|Annona chays
50302402|Chirimoya bronceada|O|O||D||1|Annona bronceada
50302403|Chirimoya burtons|O|O||D||1|Annona burtons
50302404|Chirimoya burton favorite|O|O||D||1|Annona burton favorite
50302405|Chirimoya jete|O|O||D||1|Annona jete
50302406|Chirimoya reretai|O|O||D||1|Annona reretai
50302407|Chirimoya smoothey|O|O||D||1|Annona smoothey
50302408|Chirimoya español|O|O||D||1|Annona española
50302409|Chirimoya blanco|O|O||D||1|Annona blanca
50302500|Cerezas|O|O||D||1
50302501|Cereza amarelle|O|O||D||1
50302502|Cereza brooks|O|O||D||1
50302503|Cereza bigarreu|O|O||D||1
50302504|Cereza bing|O|O||D||1
50302505|Cereza blach republic|O|O||D||1
50302506|Cereza negro schmidt|O|O||D||1
50302507|Cereza negrotartarian|O|O||D||1
50302508|Cereza fiesta bing|O|O||D||1
50302509|Cereza garnet|O|O||D||1
50302510|Cereza rey|O|O||D||1
50302511|Cereza chapman|O|O||D||1
50302512|Cereza lapin|O|O||D||1
50302513|Cereza larian|O|O||D||1
50302514|Cereza dark guines|O|O||D||1
50302515|Cereza montmorency|O|O||D||1
50302516|Cereza duque|O|O||D||1
50302517|Cereza early rivers|O|O||D||1
50302518|Cereza ruby bing|O|O||D||1
50302519|Cereza santine|O|O||D||1
50302520|Cereza geans/guines|O|O||D||1
50302521|Cereza sonata|O|O||D||1
50302522|Cereza lambert|O|O||D||1
50302523|Cereza stella|O|O||D||1
50302524|Cereza sweethart|O|O||D||1
50302525|Cereza tartarian|O|O||D||1
50302527|Cereza maraschino|O|O||D||1
50302528|Cereza van|O|O||D||1
50302529|Cereza morello|O|O||D||1
50302530|Cereza royal ann|O|O||D||1
50302531|Cereza ranier|O|O||D||1
50302532|Cereza royal|O|O||D||1
50302533|Cereza verde|O|O||D||1
50302600|Citrones|O|O||D||1|Cidras
50302601|Citrones buddha´s hand|O|O||D||1|Cidra mano de Buda
50302602|Citrones dedo rojo|O|O||D||1|Cidra finger red
50302603|Citrones fo shoukan|O|O||D||1|Cidra fo shoukan
50302604|Citrones bushakan|O|O||D||1|Cidra bushakan
50302605|Citones diamante|O|O||D||1|Cidra diamante
50302606|Citrones etrog|O|O||D||1|Cidra etrog
50302607|Citrones ponderosa|O|O||D||1|Cidra ponderosa
50302700|Arándanos|O|O||D||1|Arándanos rojos
50302701|Arandano ben lear|O|O||D||1|Arándano rojo ben lear
50302702|Arandano early negro|O|O||D||1|Arándano rojo early negro
50302703|Arandano gryclesik|O|O||D||1|Arándano rojo gryclesik
50302704|Arandano  howe|O|O||D||1|Arándano rojo howe
50302705|Bayas lingon|O|O||D||1|Arándano rojo lingon
50302706|Arandano mcfarling|O|O||D||1|Arándano rojo mcfarling
50302707|Arandano mauntain|O|O||D||1|Arándano rojo mauntain
50302708|Arandano pilgrim|O|O||D||1|Arándano rojo pilgrim
50302709|Arandano searless|O|O||D||1|Arándano rojo searless
50302710|Arandano stevens|O|O||D||1|Arándano rojo stevens
50302800|pasas de Corinto|O|O||D||1
50302801|Pasa hudson bay|O|O||D||1|Pasa de Corinto hudson bay
50302802|Pasa waxy|O|O||D||1|Pasa de Corinto waxy
50302803|Pasa desert|O|O||D||1|Pasa de Corinto desert
50302804|Pasa negra|O|O||D||1|Pasa de Corinto negra
50302805|Pasa roja|O|O||D||1|Pasa de Corinto roja
50302806|Pasa blanca|O|O||D||1|Pasa de Corinto blanca
50302900|Dátiles|O|O||D||1
50302901|Dátiles asharasi|O|O||D||1
50302902|Dátiles barhi o barhee|O|O||D||1
50302903|Dátiles deglet noor|O|O||D||1
50302904|Dátiles fardh|O|O||D||1
50302905|Dátiles gundila|O|O||D||1
50302906|Dátiles halawi/halawy|O|O||D||1
50302907|Dátiles hilali|O|O||D||1
50302908|Dátiles khadrawi/khadrawy|O|O||D||1
50302909|Dátiles khalas|O|O||D||1
50302910|Dátiles khustawi|O|O||D||1
50302911|Dátiles khidri|O|O||D||1
50302912|Dátiles medjool/ medjol|O|O||D||1
50302913|Dátiles mactoum|O|O||D||1
50302914|Dátiles neghal|O|O||D||1
50302915|Dátiles yatimeh|O|O||D||1
50302916|Dátiles zahidi|O|O||D||1
50303000|Pitahayas|O|O||D||1
50303001|Pitahaya roja, rosada|O|O||D||1
50303002|Pitahaya roja, amarillo|O|O||D||1
50303100|Brevas|O|O||D||1|Higos
50303101|Breva bardajic|O|O||D||1|Higo bardajic
50303102|Breva brown turkey|O|O||D||1|Higo brown turkey
50303103|Breva calimyma|O|O||D||1|Higo calimyma
50303104|Breva conadria|O|O||D||1|Higo conadria
50303105|Breva dottado|O|O||D||1|Higo dottado
50303106|Breva kadota|O|O||D||1|Higo kadota
50303107|Breva mediterránea|O|O||D||1|Higo mediterránea
50303108|Breva mision|O|O||D||1|Higo misión
50303109|Breva amyma|O|O||D||1|Higo amyma
50303110|Breva verdona|O|O||D||1|Higo verdona
50303111|Breva rey blanco|O|O||D||1|Higo rey blanco
50303200|Grosellas|O|O||D||1
50303201|Grosella early sulphur|O|O||D||1
50303202|Grosella doradoendrop|O|O||D||1
50303203|Grosella langley grace|O|O||D||1
50303204|Grocella leveller|O|O||D||1
50303205|Grosella london|O|O||D||1
50303206|Grosella worcestershire|O|O||D||1
50303207|Grosella american worcesterberry|O|O||D||1
50303300|Toronjas|O|O||D||1
50303301|Toronja burgundi|O|O||D||1
50303302|Toronja duncan|O|O||D||1
50303303|Toronja foster|O|O||D||1
50303304|Toronja marsh|O|O||D||1
50303305|Toronja nueva zelandia|O|O||D||1
50303306|Toronja rio rojo|O|O||D||1
50303307|Toronja ruby rojo|O|O||D||1
50303308|Toronja star ruby|O|O||D||1
50303309|Toronja triumph|O|O||D||1
50303400|Uvas de mesa|O|O||D||1
50303401|Uva alicante|O|O||D||1
50303402|Uva almeira|O|O||D||1
50303403|Uva alphonse lavalle|O|O||D||1
50303404|Uva otoño rey grapes|O|O||D||1
50303405|Uva otoño royal|O|O||D||1
50303406|Uva otoño sin pepa|O|O||D||1
50303407|Uva baresana|O|O||D||1
50303408|Uva barlinka|O|O||D||1
50303409|Uva beaty sin pepa|O|O||D||1
50303410|Uva negro beauty sin pepa|O|O||D||1
50303411|Uva negro emerald|O|O||D||1
50303412|Uva negro gigante|O|O||D||1
50303413|Uva negro globo|O|O||D||1
50303414|Uva negro monnukka|O|O||D||1
50303415|Uva negro perla|O|O||D||1
50303416|Uva negro sin semilla|O|O||D||1
50303417|Uva bonheur|O|O||D||1
50303418|Uva calmeria|O|O||D||1
50303419|Uva cardinal|O|O||D||1
50303420|Uva catawba|O|O||D||1
50303421|Uva chasselas/doradoen chasselas|O|O||D||1
50303422|Uva christmas rose|O|O||D||1
50303423|Uva concord|O|O||D||1
50303424|Uva concord sin pepa|O|O||D||1
50303425|Uva crimson sin pepa|O|O||D||1
50303426|Uva dauphine|O|O||D||1
50303427|Uva daleware|O|O||D||1
50303428|Uva early muscat|O|O||D||1
50303429|Uva early sweet|O|O||D||1
50303430|Uva esmerald sin pepa|O|O||D||1
50303431|Uva emperatriz|O|O||D||1
50303432|Uva emperor|O|O||D||1
50303433|Uva empress|O|O||D||1
50303434|Uva exotic|O|O||D||1
50303435|Uva fantasia|O|O||D||1
50303436|Uva fantasy sin pepa|O|O||D||1
50303437|Uva llama|O|O||D||1
50303438|Uva llama sin pepa|O|O||D||1
50303439|Uva llama tokay|O|O||D||1
50303440|Uva flaming rojo|O|O||D||1
50303441|Uva galaxy sin pepa|O|O||D||1
50303442|Uva gamay|O|O||D||1
50303443|Uva dorada|O|O||D||1
50303444|Uva hanepot o honeypot|O|O||D||1
50303445|Uva italia|O|O||D||1
50303446|Uva jade sin pepa|O|O||D||1
50303447|Uva jubilee|O|O||D||1
50303448|Uva rey ruby|O|O||D||1
50303449|Uva kyoho|O|O||D||1
50303450|Uva la rochelle|O|O||D||1
50303451|Uva dedo de dama|O|O||D||1
50303452|Uva late sin pepa|O|O||D||1
50303453|Uva majestic sin pepa|O|O||D||1
50303454|Uva malaga|O|O||D||1
50303455|Uva marro sin pepa|O|O||D||1
50303456|Uva muscadine|O|O||D||1
50303457|Uva muscat llama|O|O||D||1
50303458|Uva muscat|O|O||D||1
50303459|Uva muscat sin semilla|O|O||D||1
50303460|Uva napoleon|O|O||D||1
50303461|Uva nigeria|O|O||D||1
50303462|Uva new cross|O|O||D||1
50303463|Uva nibella|O|O||D||1
50303464|Uva niagara|O|O||D||1
50303465|Uva olivette|O|O||D||1
50303466|Uva perlette|O|O||D||1
50303467|Uva perlon|O|O||D||1
50303468|Uva prima negro sin pepa|O|O||D||1
50303469|Uva princess|O|O||D||1
50303470|Uva reina|O|O||D||1
50303471|Uva roja blush|O|O||D||1
50303472|Uva roja globe|O|O||D||1
50303473|Uva roja malaga|O|O||D||1
50303474|Uva roja sin pepa|O|O||D||1
50303475|Uva regina|O|O||D||1
50303476|Uva ribier|O|O||D||1
50303477|Uva rosita|O|O||D||1
50303478|Uva rouge|O|O||D||1
50303479|Uva royal negra sin pepa|O|O||D||1
50303480|Uva ruby roja sin pepa|O|O||D||1
50303481|Uva ryby sin pepa|O|O||D||1
50303482|Uva scarlet royal|O|O||D||1
50303483|Uva scuppemong|O|O||D||1
50303484|Uva sugarose|O|O||D||1
50303485|Uva sugartirteen|O|O||D||1
50303486|Uva sugraone|O|O||D||1
50303487|Uva sugrasixteen|O|O||D||1
50303488|Uva sultana sun roja|O|O||D||1
50303489|Uva verano royal|O|O||D||1
50303490|Uva sunset|O|O||D||1
50303491|Uva superior sin semilla|O|O||D||1
50303492|Uva thompson sin semilla|O|O||D||1
50303493|Uva tokaylpinot gris|O|O||D||1
50303494|Uva waltman cross|O|O||D||1
50303495|Uva blanca sin pepa|O|O||D||1
50303496|Uva zante current|O|O||D||1
50303497|Uva quebranta|O|O||D||1
50303498|Uva burgundi|O|O||D||1
50303499|Uva torontel|O|O||D||1
50303500|Uvas pasas|O|O||D||1
50303501|Uva corinth negra|O|O||D||1
50303502|Uva canner|O|O||D||1
50303503|Uva dovine|O|O||D||1
50303504|Uva fiesta|O|O||D||1
50303505|Uva selme pete|O|O||D||1
50303506|Uva sultana|O|O||D||1
50303600|Uvas para vino|O|O||D||1
50303601|Uva uva alicante bouschet|O|O||D||1
50303602|Uva barbera|O|O||D||1
50303603|Uva burger|O|O||D||1
50303604|Uva cabemet franc|O|O||D||1
50303605|Uva cabenet sauvignon|O|O||D||1
50303606|Uva carignane|O|O||D||1
50303607|Uva camelian|O|O||D||1
50303608|Uva cattarrato|O|O||D||1
50303609|Uva centurian|O|O||D||1
50303610|Uva charbono|O|O||D||1
50303611|Uva chardonnay|O|O||D||1
50303612|Uva chenin blanco|O|O||D||1
50303613|Uva cinsaut|O|O||D||1
50303614|Uva dolcetto|O|O||D||1
50303615|Uva emerald riesling|O|O||D||1
50303616|Uva french colombard|O|O||D||1
50303617|Uva granny nap|O|O||D||1
50303618|Uva gamay beaujolais|O|O||D||1
50303619|Uva gewurztraminer|O|O||D||1
50303620|Uva grenache|O|O||D||1
50303621|Uva grenache blanc|O|O||D||1
50303622|Uva lagrein|O|O||D||1
50303623|Uva lambruso|O|O||D||1
50303624|Uva malbec|O|O||D||1
50303625|Uva malvasía bianca|O|O||D||1
50303626|Uva marsanne|O|O||D||1
50303627|Uva matano|O|O||D||1
50303628|Uva merlot|O|O||D||1
50303629|Uva meunier|O|O||D||1
50303630|Uva missiom|O|O||D||1
50303631|Uva montepulceano|O|O||D||1
50303632|Uva muscat blanc|O|O||D||1
50303633|Uva muscat hamburg|O|O||D||1
50303634|Uva muscat alexandria|O|O||D||1
50303635|Uva muscat orange|O|O||D||1
50303636|Uva nebbiolo|O|O||D||1
50303637|Uva palomino|O|O||D||1
50303638|Uva petit verdor|O|O||D||1
50303639|Uva petit sirah|O|O||D||1
50303640|Uva pinot blanc|O|O||D||1
50303641|Uva pinot gris|O|O||D||1
50303642|Uva pinot noir|O|O||D||1
50303643|Uva primitivo|O|O||D||1
50303644|Uva roussane|O|O||D||1
50303645|Uva royalty|O|O||D||1
50303646|Uva rubirojo|O|O||D||1
50303647|Uva ruby cabenet|O|O||D||1
50303648|Uva salvador|O|O||D||1
50303649|Uva sangiovese|O|O||D||1
50303650|Uva sauvignon blanc|O|O||D||1
50303651|Uva sauvignon musque|O|O||D||1
50303652|Uva semillon|O|O||D||1
50303653|Uva souzao|O|O||D||1
50303654|Uva st emilion|O|O||D||1
50303655|Uva symphony|O|O||D||1
50303656|Uva syrah|O|O||D||1
50303657|Uva tannat|O|O||D||1
50303658|Uva tempranillo|O|O||D||1
50303659|Uvas teroldego|O|O||D||1
50303660|Uvas tocai friulano|O|O||D||1
50303661|Uvas touriga nacional|O|O||D||1
50303662|Uvas triplett blanc|O|O||D||1
50303663|Uvas viogner|O|O||D||1
50303664|Uvas blanco riesling|O|O||D||1
50303665|Uvas zinfandel|O|O||D||1
50303700|Guayabas|O|O||D||1
50303701|Guayaba beaumont|O|O||D||1
50303702|Guayaba carrley|O|O||D||1
50303703|Guayaba lucida|O|O||D||1
50303704|Guayaba piña|O|O||D||1
50303800|Arándanos Huckleberry|O|O||D||1|Arándanos azules
50303801|Arándano negro invierno|O|O||D||1|Arándano azul negro invierno
50303802|Arándano cascade|O|O||D||1|Arándano azul cascade
50303803|Arándano enano|O|O||D||1|Arándano azul enano
50303804|Arándano montaña|O|O||D||1|Arándano azul montaña
50303805|Arándano rojo|O|O||D||1|Arándano azul red
50303900|Kiwis|O|O||D||1
50303901|Fruta de kiwi ananasnaja|O|O||D||1|Kiwi ananasnaja
50303902|Fruta de kiwi belleza del ártico|O|O||D||1|Kiwi belleza del ártico
50303903|Fruta de kiwi blake|O|O||D||1|Kiwi blake
50303904|Fruta de kiwi hayward|O|O||D||1|Kiwi hayward
50303905|Fruta de kiwi issai|O|O||D||1|Kiwi issai
50303906|Fruta de kiwi siberiana|O|O||D||1|Kiwi siberiano
50304000|Naranjos Chinos (kumquats)|O|O||D||1
50304001|Naranjo chino hong kong|O|O||D||1
50304002|Naranjo chino limequat|O|O||D||1
50304003|Naranjo long fruit|O|O||D||1|Naranjo chino long fruit
50304004|Naranjo chino malayan|O|O||D||1
50304005|Naranjo meiwa|O|O||D||1|Naranjo chino meiwa
50304006|Naranjo chino nagami|O|O||D||1
50304100|Limones|O|O||D||1
50304101|Limón baboon|O|O||D||1
50304102|Limón bearss sicilian|O|O||D||1
50304103|Limón cameron highland|O|O||D||1
50304104|Limón escondido|O|O||D||1
50304105|Limón eureka|O|O||D||1
50304106|Limón lisbon|O|O||D||1
50304107|Limón meyer|O|O||D||1
50304108|Limón volkaner|O|O||D||1
50304200|Limas|O|O||D||1
50304201|Lima limón dulce indio|O|O||D||1
50304202|Lima limón|O|O||D||1
50304203|Lima limón mandarina|O|O||D||1
50304204|Lima limón filipino|O|O||D||1
50304205|Lima limón tahitian|O|O||D||1
50304206|Lima limón bearss|O|O||D||1
50304207|Lima limón persa|O|O||D||1
50304208|Lima limón sin pepas|O|O||D||1|Lima limón sin semillas
50304300|Nísperos|O|O||D||1
50304301|Níspero advance|O|O||D||1
50304302|Níspero benlehr|O|O||D||1
50304303|Níspero big jim|O|O||D||1
50304304|Níspero champagne|O|O||D||1
50304305|Níspero early rojo|O|O||D||1
50304306|Níspero dorado nugget|O|O||D||1
50304307|Níspero herd´s mammoth|O|O||D||1
50304308|Níspero mogi|O|O||D||1
50304309|Níspero mrs cooksey|O|O||D||1
50304310|Níspero fresa|O|O||D||1
50304311|Níspero tanaka|O|O||D||1
50304312|Níspero victoria vista blanco|O|O||D||1
50304313|Níspero wolfe|O|O||D||1
50304400|Mandarinas|O|O||D||1
50304401|Naranjas clauselinas|O|O||D||1
50304402|Mandarinas clementinas|O|O||D||1
50304403|Naranja mandarina cleopatra|O|O||D||1
50304404|Mandarina dancy|O|O||D||1
50304405|Naranja ellensday|O|O||D||1
50304406|Naranja fairchild|O|O||D||1
50304407|Naranja fallglo|O|O||D||1
50304408|Naranja fortune|O|O||D||1
50304409|Mandarina naranja fremont|O|O||D||1
50304410|Naranja fremont|O|O||D||1
50304411|Naranja doradoen nugget|O|O||D||1
50304412|Mandarina naranja miel|O|O||D||1
50304413|Naranja miel|O|O||D||1
50304414|Mandarina miel|O|O||D||1
50304415|Naranja tanjelo honeybelle|O|O||D||1
50304416|Naranja mandarina rey|O|O||D||1
50304417|Naranja kinnow|O|O||D||1
50304418|Naranja andarinalee|O|O||D||1
50304419|Naranja makokkee|O|O||D||1
50304420|Naranja malvasion|O|O||D||1
50304421|Naranja mandarina mediterráneo|O|O||D||1
50304422|Naranja tangelo minneola|O|O||D||1
50304423|Naranja monica|O|O||D||1
50304424|Naranja murcott honey|O|O||D||1
50304425|Naranja murcott tangors|O|O||D||1
50304426|Naranja mandarina natsudaidai|O|O||D||1
50304427|Naranja mandarina natsumikan|O|O||D||1
50304428|Naranja tanjelo nocatee|O|O||D||1
50304429|Naranja tanjelo orlando|O|O||D||1
50304430|Mandarina ortanique|O|O||D||1
50304431|Naranja mandarina page|O|O||D||1
50304432|Naranja pixie|O|O||D||1
50304433|Naranja mandarina ponkan bantangas|O|O||D||1
50304434|Naranja reyna|O|O||D||1
50304435|Naranja robinson|O|O||D||1
50304436|Naranja saltenitas|O|O||D||1
50304437|Naranja tangelo sampson|O|O||D||1
50304438|Naranja mandarina satsuma|O|O||D||1
50304439|Naranja mandarina sunburst|O|O||D||1
50304440|Tangelo|O|O||D||1
50304441|Naranja mandarina|O|O||D||1
50304442|Naranja templo|O|O||D||1
50304443|Naranja thornton|O|O||D||1
50304444|Mandarina wekiwa|O|O||D||1
50304445|Mandarina wilkins|O|O||D||1
50304446|Mandarina willowleaf mediterranea|O|O||D||1
50304500|Mangos|O|O||D||1
50304501|Mango alphonso|O|O||D||1
50304502|Mango ataulfo|O|O||D||1
50304503|Mango criollo|O|O||D||1
50304504|Mango edwards|O|O||D||1
50304505|Mango francine|O|O||D||1
50304506|Mango francis|O|O||D||1
50304507|Mango gandaria|O|O||D||1
50304508|Mango haden|O|O||D||1
50304509|Mangos irwin|O|O||D||1
50304510|Mangos keitt|O|O||D||1
50304511|Mangos kent|O|O||D||1
50304512|Mangos kesar|O|O||D||1
50304513|Mangos kuini|O|O||D||1
50304514|Mangos manila super|O|O||D||1
50304515|Mangos manila|O|O||D||1
50304516|Mangos mayaguez|O|O||D||1
50304517|Mangos mulgoba|O|O||D||1
50304518|Mangos oro|O|O||D||1
50304519|Mangos palmer|O|O||D||1
50304520|Mango parvin|O|O||D||1
50304521|Mango sandersha|O|O||D||1
50304522|Mangos sensation|O|O||D||1
50304523|Mango smith|O|O||D||1
50304524|Mango tomy atkin|O|O||D||1
50304525|Mango van dyke|O|O||D||1
50304600|Melones|O|O||D||1
50304601|Melon allsweet|O|O||D||1
50304602|Melón athens|O|O||D||1
50304603|Melón diamante negro|O|O||D||1
50304604|Melón cal dulce|O|O||D||1
50304605|Melons cantaloupe|O|O||D||1
50304606|Melón carnical|O|O||D||1
50304607|Melón casaba|O|O||D||1
50304608|Melón cavaillon|O|O||D||1
50304609|Melón charentais|O|O||D||1
50304610|Sandia charleston gray|O|O||D||1
50304611|Melón crenshaw|O|O||D||1
50304612|Melón crimson sweet|O|O||D||1
50304613|Melón dixie lee|O|O||D||1
50304614|Melón eclipse|O|O||D||1
50304615|Melón ein dór|O|O||D||1
50304616|Melón fiesta|O|O||D||1
50304617|Melón galia|O|O||D||1
50304618|Melón gaya|O|O||D||1
50304619|Melón hami|O|O||D||1
50304620|Melón honey dew|O|O||D||1
50304621|Melón icebox|O|O||D||1
50304622|Melón ida pride|O|O||D||1
50304623|Melón juan canary|O|O||D||1
50304624|Melón jubileo|O|O||D||1
50304625|Melón jubilation|O|O||D||1
50304626|Melón kaki / kakri|O|O||D||1
50304627|Melón kiwano|O|O||D||1
50304628|Melon koreano|O|O||D||1|Melón coreano
50304629|Melón long grey|O|O||D||1|Melón largo gris
50304630|Melón mayan|O|O||D||1
50304631|Melón micky lee|O|O||D||1
50304632|Melón mirage|O|O||D||1
50304633|Sandia luna y estrellas|O|O||D||1
50304634|Melón ogen|O|O||D||1
50304635|Melón patriot|O|O||D||1
50304636|Melón peacook|O|O||D||1
50304637|Melón pepino|O|O||D||1
50304638|Melón persa|O|O||D||1
50304639|Melón picnic|O|O||D||1
50304640|Melón piel de sapo|O|O||D||1
50304641|Melón piña|O|O||D||1
50304642|Melón quetzali|O|O||D||1
50304643|Melón goblin rojo|O|O||D||1
50304644|Melón regency|O|O||D||1
50304645|Melón royal mejestic|O|O||D||1
50304646|Melón estrella royal|O|O||D||1
50304647|Melón royal dulce|O|O||D||1
50304648|Malon santa claus|O|O||D||1|Melón piel de sapo, Melón santa claus
50304649|Melón sharlyn|O|O||D||1
50304650|Melón español|O|O||D||1
50304651|Melón sprite|O|O||D||1
50304652|Melón starbright|O|O||D||1
50304653|Melón stars and stripes|O|O||D||1
50304654|Melón sugar bebe|O|O||D||1
50304655|Sandia sugar bebe|O|O||D||1
50304656|Melón sunsweet|O|O||D||1
50304657|Sandia sweet heart sin semilla|O|O||D||1
50304658|Melón tentación|O|O||D||1
50304659|Melón tiger bebe|O|O||D||1
50304660|Melón tuscan type|O|O||D||1
50304661|Sandia bebe amarillo|O|O||D||1
50304700|Mora mulberry|O|O||D||1|Zarzamoras mulberry
50304701|Mora negra|O|O||D||1|Zarzamora negra
50304702|Mora blanca|O|O||D||1|Zarzamora blanca
50304800|Mirtos|O|O||D||1|Arrayanes
50304801|Mirto bog|O|O||D||1|Arrayán bog
50304900|Nectarinas|O|O||D||1
50304901|Durazno april glo|O|O||D||1
50304902|Durazno arctic mist|O|O||D||1
50304903|Durazno artic snow|O|O||D||1
50304904|Durazno artic star|O|O||D||1
50304905|Durazno artic sweet|O|O||D||1
50304906|Durazno artic glo|O|O||D||1
50304907|Durazno august fire|O|O||D||1
50304908|Durazno  august pearl|O|O||D||1
50304909|Durazno august rojo|O|O||D||1
50304910|Durazno august estrella|O|O||D||1
50304911|Durazno big john|O|O||D||1
50304912|Durazno bright pearl|O|O||D||1
50304913|Durazno diamante bright|O|O||D||1
50304914|Durazno diamante ray|O|O||D||1
50304915|Durazno earligo|O|O||D||1
50304916|Durazno diamante temprano|O|O||D||1
50304917|Durazno fairlane|O|O||D||1
50304918|Durazno fantasia|O|O||D||1
50304919|Durazno perla fuego|O|O||D||1
50304920|Durazno fuego dulce|O|O||D||1
50304921|Durazno llamakist|O|O||D||1
50304922|Durazno tipo plano|O|O||D||1
50304923|Durazno delicia de jardín|O|O||D||1
50304924|Durazno mina de oro|O|O||D||1
50304925|Durazno perla grande|O|O||D||1
50304926|Durazno hardirojo|O|O||D||1
50304927|Durazno miel de fuego|O|O||D||1
50304928|Durazno julio rojo|O|O||D||1
50304929|Durazno kay perla|O|O||D||1
50304930|Durazno key dulce|O|O||D||1
50304931|Durazno diamante mayo|O|O||D||1
50304932|Durazno mayfire|O|O||D||1
50304933|Durazno mayglo|O|O||D||1
50304934|Durazno mericrest|O|O||D||1
50304935|Durazno diamante rojo|O|O||D||1
50304936|Durazno oro rojo|O|O||D||1
50304937|Durazno jim rojo|O|O||D||1
50304938|Durazno roy rojo|O|O||D||1
50304939|Durazno rio rojo|O|O||D||1
50304940|Durazno diamante de rosa|O|O||D||1
50304941|Durazno royal glo|O|O||D||1
50304942|Durazno diamante ryby|O|O||D||1
50304943|Durazno ruby dulce|O|O||D||1
50304944|Durazno joya ruddy|O|O||D||1
50304945|Durazno septiembre rojo|O|O||D||1
50304946|Durazno reina de nieve|O|O||D||1
50304947|Durazno primavera clara|O|O||D||1
50304948|Durazno primavera roja|O|O||D||1
50304949|Durazno verano rojiso|O|O||D||1
50304950|Durazno verano claro|O|O||D||1
50304951|Durazno verano diamante|O|O||D||1
50304952|Durazno verano fuego|O|O||D||1
50304953|Durazno verano grande|O|O||D||1
50304954|Durazno sunglo|O|O||D||1
50304955|Durazno fuego zee|O|O||D||1
50304956|Durazno zee glo|O|O||D||1
50304957|Durazno zeegrand|O|O||D||1
50305000|Naranjas|O|O||D||1
50305001|Naranja áfrica agria|O|O||D||1
50305002|Naranja dulce amber|O|O||D||1
50305003|Naranja argentina agria|O|O||D||1
50305004|Naranja bahianinha|O|O||D||1
50305005|Naranja bergamot|O|O||D||1
50305006|Naranja berna|O|O||D||1
50305007|Naranja bigaradier apepu|O|O||D||1
50305008|Naranja agria dulce daidai|O|O||D||1
50305009|Naranja blonde|O|O||D||1
50305010|Naranja sangr|O|O||D||1
50305011|Naranja california navel|O|O||D||1
50305012|Naranja cara cara|O|O||D||1
50305013|Naranja chinotto|O|O||D||1
50305014|Naranja sueño nevel|O|O||D||1
50305015|Naranja gou tou|O|O||D||1
50305016|Naranja hamlin|O|O||D||1
50305017|Naranja jaffa|O|O||D||1
50305018|Naranja jincheng|O|O||D||1
50305019|Naranja k-temprano|O|O||D||1
50305020|Naranja kona|O|O||D||1
50305021|Naranja navel tarde|O|O||D||1
50305022|Naranja valencia tarde|O|O||D||1
50305023|Naranja limequat|O|O||D||1
50305024|Naranja mar|O|O||D||1
50305025|Naranja maledorado|O|O||D||1
50305026|Naranja moro|O|O||D||1
50305027|Naranja moro tabacco|O|O||D||1
50305028|Naranja navel|O|O||D||1
50305029|Naranja navelina|O|O||D||1
50305030|Naranja oro blanco|O|O||D||1
50305031|Naranja osceola|O|O||D||1
50305032|Naranja parson carmelito|O|O||D||1
50305033|Naranja pera|O|O||D||1
50305034|Naranja pummulo|O|O||D||1
50305035|Naranja rhode rojo|O|O||D||1
50305036|Naranja roble|O|O||D||1
50305037|Naranja salustianas|O|O||D||1
50305038|Naranja sanguine|O|O||D||1
50305039|Naranja sanguinelli|O|O||D||1
50305040|Naranja cevilla|O|O||D||1
50305041|Naranja shamouti jaffa|O|O||D||1
50305042|Naranja tunis|O|O||D||1
50305043|Naranja valencia|O|O||D||1
50305044|Naranja washington navel|O|O||D||1
50305100|Papayas|O|O||D||1
50305101|Papaya verde cocinar|O|O||D||1
50305102|Papaya maradol|O|O||D||1
50305103|Papaya amarillo mexicano|O|O||D||1
50305104|Papaya montaña|O|O||D||1
50305105|Papaya solo|O|O||D||1
50305106|Papaya tainung|O|O||D||1
50305200|Maracuyás|O|O||D||1
50305201|Fruta maracuyá banana|O|O||D||1|Curuba
50305202|Maracuyá flor azul|O|O||D||1|Maracuyá pasionaria azul
50305203|Maracuyá crackerjack|O|O||D||1
50305204|Maracuyá granadilla gigante|O|O||D||1
50305205|Maracuyá granadilla dorada|O|O||D||1
50305206|Maracuyá maypops|O|O||D||1
50305207|Maracuyá roja|O|O||D||1
50305208|Maracuyá granadilla dulce|O|O||D||1
50305209|Maracuyá sandia|O|O||D||1
50305210|Maracuyá  wing- steam|O|O||D||1
50305300|Duraznos|O|O||D||1
50305301|Durazno escudo amber|O|O||D||1
50305302|Durazno nieve de abril|O|O||D||1
50305303|Durazno dama de agosto|O|O||D||1
50305304|Durazno llama de otoño|O|O||D||1
50305305|Durazno dama de otoño|O|O||D||1
50305306|Durazno babcock|O|O||D||1
50305307|Durazno brittany lane|O|O||D||1
50305308|Durazno cary mac|O|O||D||1
50305309|Durazno clasic|O|O||D||1
50305310|Durazno dulce del campo|O|O||D||1
50305311|Durazno escudo de cielo|O|O||D||1
50305312|Durazno dama crimson|O|O||D||1
50305313|Durazno príncipe corona|O|O||D||1
50305314|Durazno sol david|O|O||D||1
50305315|Durazno  princesa diamante|O|O||D||1
50305316|Durazno earlrich|O|O||D||1
50305317|Durazno majestuosa temprana|O|O||D||1
50305318|Durazno early treat|O|O||D||1
50305319|Durazno dama elegante|O|O||D||1
50305320|Durazno emperatriz|O|O||D||1
50305321|Durazno encoré|O|O||D||1
50305322|Durazno dama fancy|O|O||D||1
50305323|Durazno príncipe de fuego|O|O||D||1
50305324|Durazno escudo de llama|O|O||D||1
50305325|Durazno tipo plano|O|O||D||1
50305326|Durazno escudo de sabor|O|O||D||1
50305327|Durazno príncipe florida|O|O||D||1
50305328|Durazno luna llena|O|O||D||1
50305329|Durazno harvester|O|O||D||1
50305330|Durazno princesa de hielo|O|O||D||1
50305331|Durazno princesa de marfil|O|O||D||1
50305332|Durazno princesa reina jersey|O|O||D||1
50305333|Durazno john henry|O|O||D||1
50305334|Durazno príncipe de junio|O|O||D||1
50305335|Durazno kaweah|O|O||D||1
50305336|Durazno klondike|O|O||D||1
50305337|Durazno lindo|O|O||D||1
50305338|Durazno loring|O|O||D||1
50305339|Durazno majestuoso|O|O||D||1
50305340|Durazno o’henry|O|O||D||1
50305341|Durazno escudo de reina|O|O||D||1
50305342|Durazno dama roja|O|O||D||1
50305343|Durazno globo rojo|O|O||D||1
50305344|Durazno cielo rojo|O|O||D||1
50305345|Durazno redtop|O|O||D||1
50305346|Durazno regina|O|O||D||1
50305347|Durazno dama rica|O|O||D||1
50305348|Durazno mayo rico|O|O||D||1
50305349|Durazno gloria real|O|O||D||1
50305350|Durazno dama real|O|O||D||1
50305351|Durazno nieve de septiembre|O|O||D||1
50305352|Durazno sol de septiembre|O|O||D||1
50305353|Durazno gema sierra|O|O||D||1
50305354|Durazno angel de nieve|O|O||D||1
50305355|Durazno gema de nieve|O|O||D||1
50305356|Durazno rey de nieve|O|O||D||1
50305357|Durazno dama de primavera|O|O||D||1
50305358|Durazno nieve de primavera|O|O||D||1
50305359|Durazno escudo de primavera|O|O||D||1
50305360|Durazno dulce gigante|O|O||D||1
50305361|Durazno dama de azúcar|O|O||D||1
50305362|Durazno brillo de sol|O|O||D||1
50305363|Durazno sunhigh|O|O||D||1
50305364|Durazno dama super|O|O||D||1
50305365|Durazno super rico|O|O||D||1
50305366|Durazno surecrop|O|O||D||1
50305367|Durazno sueño duñce|O|O||D||1
50305368|Durazno septiembre dulce|O|O||D||1
50305369|Durazno vista|O|O||D||1
50305370|Durazno dama blanca|O|O||D||1
50305371|Durazno dama zee|O|O||D||1
50305400|Peras|O|O||D||1
50305401|Peras abate fetel|O|O||D||1
50305402|Peras anjou|O|O||D||1
50305403|Pera asiatica|O|O||D||1
50305404|Pera bartlett|O|O||D||1
50305405|Pera best ever|O|O||D||1
50305406|Pera beth|O|O||D||1
50305407|Pera beurre|O|O||D||1
50305408|Pera bosc|O|O||D||1
50305409|Pera clapp favorita|O|O||D||1
50305410|Pera comice|O|O||D||1
50305411|Pera concorde|O|O||D||1
50305412|Pera conference|O|O||D||1
50305413|Pera crimson rojo|O|O||D||1
50305414|Peras d’ anjou|O|O||D||1
50305415|Pera dr jules guyot|O|O||D||1
50305416|Peras early|O|O||D||1
50305417|Peras emperador carmelito|O|O||D||1
50305418|Peras forelle|O|O||D||1
50305419|Pera mantequilla francesa|O|O||D||1
50305420|Pera glou morceau|O|O||D||1
50305421|Pera hosui|O|O||D||1
50305422|Pera mantequilla italiana|O|O||D||1
50305423|Pera jargonelle|O|O||D||1
50305424|Pera juno|O|O||D||1
50305425|Para kaiserlouise bonne de jersey|O|O||D||1
50305426|Pera keiffer|O|O||D||1
50305427|Pera rey royal|O|O||D||1
50305428|Pera limonera|O|O||D||1
50305429|Pera merton pride|O|O||D||1
50305430|Pera mauntain bartlette|O|O||D||1
50305431|Pera oliver de serrers|O|O||D||1
50305432|Pera onward|O|O||D||1
50305433|Pera packham´s triumph|O|O||D||1
50305434|Pera paraíso|O|O||D||1
50305435|Pera passe crassane|O|O||D||1
50305436|Pera perry|O|O||D||1
50305437|Pera bartlette rojo|O|O||D||1
50305438|Pera dánjou  rojo|O|O||D||1
50305439|Pera rocha|O|O||D||1
50305440|Pera rosey rojo|O|O||D||1
50305441|Pera rosy roja|O|O||D||1
50305442|Pera majestuosa royal|O|O||D||1
50305443|Pera ruby rojo|O|O||D||1
50305444|Pera santa maria|O|O||D||1
50305445|Pera seckel|O|O||D||1
50305446|Pera sensación|O|O||D||1
50305447|Pera crimson estrella|O|O||D||1
50305448|Pera crimson stark|O|O||D||1
50305449|Pera bartlette de verano|O|O||D||1
50305450|Pera verano dorado|O|O||D||1
50305451|Pera sol dorado|O|O||D||1
50305452|Pera sunprite|O|O||D||1
50305453|Pera taylors dorado|O|O||D||1
50305454|Pera taylors rojo|O|O||D||1
50305455|Pera tientsin|O|O||D||1
50305456|Pera tosca|O|O||D||1
50305457|Pera warden|O|O||D||1
50305458|Pera williams bon chretien|O|O||D||1
50305459|Pera williams|O|O||D||1
50305460|Pera nelis de invierno|O|O||D||1
50305500|Caquis|O|O||D||1
50305501|Caqui americano|O|O||D||1
50305502|Caqui sapote negro|O|O||D||1|Caqui zapote negro
50305503|Caqui chapote / negro|O|O||D||1
50305504|Caqui dátale ciruela|O|O||D||1
50305505|Caqui fuyu|O|O||D||1
50305506|Caqui gigante fuyu|O|O||D||1
50305507|Caqui hachiya|O|O||D||1
50305508|Caqui mantequilla / mabolo|O|O||D||1
50305509|Caqui príncipe ito|O|O||D||1
50305510|Caqui brillante royal|O|O||D||1
50305511|Caqui sharon|O|O||D||1
50305512|Caqui triumph|O|O||D||1
50305600|Piñas|O|O||D||1
50305601|Piña chirimoya|O|O||D||1|Atemoya
50305602|Piña dorada|O|O||D||1
50305603|Piña hilo|O|O||D||1
50305604|Piña kona sugarloaf|O|O||D||1
50305605|Piña reina natal|O|O||D||1
50305606|Piña pernabuco|O|O||D||1
50305607|Piña español rojo|O|O||D||1
50305608|Piña cayen suave|O|O||D||1
50305609|Piña sugarloaf|O|O||D||1
50305610|Piña variegated|O|O||D||1
50305700|Ciruelos Damascos|O|O||D||1
50305701|Ciruelo / damasco negro kat|O|O||D||1
50305702|Ciruelo / damasco gusto azul|O|O||D||1
50305703|Ciruelo / damasco corazón de crimson|O|O||D||1
50305704|Ciruelo / damasco dapply dandy|O|O||D||1
50305705|Ciruelo / damasco dapple fuego|O|O||D||1
50305706|Ciruelo / damasco  dapple temprano|O|O||D||1
50305707|Ciruelo / damasco  caída de sabor|O|O||D||1
50305708|Ciruelo / damasco sabor de oro|O|O||D||1
50305709|Ciruelo / damasco sabor granada|O|O||D||1
50305710|Ciruelo / damasco sabor de corazón|O|O||D||1
50305711|Ciruelo / damasco joya de sabor|O|O||D||1
50305712|Ciruelo / damasco sabor de rey|O|O||D||1
50305713|Ciruelo / damasco sabor de reina|O|O||D||1
50305714|Ciruelo / damasco sabor supremo|O|O||D||1
50305715|Ciruelo / damasco sabor premio|O|O||D||1
50305716|Ciruelo / damasco saborella|O|O||D||1
50305717|Ciruelo / damasco saborrico|O|O||D||1
50305718|Ciruelo / damasco  sabor rosa|O|O||D||1
50305719|Ciruelo / damasco orgullo geo|O|O||D||1
50305720|Ciruelo / damasco kat rojo|O|O||D||1
50305721|Ciruelo / damasco premio royal|O|O||D||1
50305722|Ciruelo / damasco rosa sierra|O|O||D||1
50305723|Ciruelo / damasco geisha dulce|O|O||D||1
50305800|Ciruelas|O|O||D||1
50305801|Ciruela joya amber|O|O||D||1
50305802|Ciruela angeleno|O|O||D||1
50305803|Ciruela aurora|O|O||D||1
50305804|Ciruela otoño bonito|O|O||D||1
50305805|Ciruela gigante de otoño|O|O||D||1
50305806|Ciruela orgullo de otoño|O|O||D||1
50305807|Ciruela rosa de otoño|O|O||D||1
50305808|Ciruela playero|O|O||D||1
50305809|Ciruela betty anne|O|O||D||1
50305810|Ciruela belleza negra|O|O||D||1
50305811|Ciruela bullase negra|O|O||D||1
50305812|Ciruela diamante negro|O|O||D||1
50305813|Ciruela gigante negro|O|O||D||1
50305814|Ciruela hielo negro|O|O||D||1
50305815|Ciruela esplendor negro|O|O||D||1
50305816|Ciruela ámbar negro|O|O||D||1
50305817|Ciruela vino tinto|O|O||D||1
50305818|Ciruela  carsbad|O|O||D||1
50305819|Ciruela casselman|O|O||D||1
50305820|Ciruela catalina|O|O||D||1
50305821|Ciruela damson|O|O||D||1
50305822|Ciruela dolly|O|O||D||1
50305823|Ciruela earliqueen|O|O||D||1
50305824|Ciruela rosa early|O|O||D||1
50305825|Ciruela ébano mayo|O|O||D||1
50305826|Ciruela ébano|O|O||D||1
50305827|Ciruela corazón de elefante|O|O||D||1
50305828|Ciruela belleza de esmeralda|O|O||D||1
50305829|Ciruela emperatriz|O|O||D||1
50305830|Ciruela libertad|O|O||D||1
50305831|Ciruela friar|O|O||D||1
50305832|Ciruela rojo gar|O|O||D||1
50305833|Ciruela gobernador|O|O||D||1
50305834|Ciruela rosa grande|O|O||D||1
50305835|Ciruela green gage|O|O||D||1|Ciruela calibre verde
50305836|Ciruela greengage|O|O||D||1
50305837|Ciruela hiromi|O|O||D||1
50305838|Ciruela hiromi rojo|O|O||D||1
50305839|Ciruela vacacion|O|O||D||1
50305840|Ciruela howard sol|O|O||D||1
50305841|Ciruela tipo interspecific|O|O||D||1
50305842|Ciruela jamaiquina|O|O||D||1
50305843|Ciruela joanna rojo|O|O||D||1
50305844|Ciruela kelsey|O|O||D||1
50305845|Ciruela jaime rey|O|O||D||1
50305846|Ciruela laroda|O|O||D||1
50305847|Ciruela rosa tarde|O|O||D||1
50305848|Ciruela rosa linda|O|O||D||1
50305849|Ciruela estrella solitaria|O|O||D||1
50305850|Ciruela mariposa|O|O||D||1
50305851|Ciruela mercado negro|O|O||D||1
50305852|Ciruela mercado rojo|O|O||D||1
50305853|Ciruela maribel|O|O||D||1
50305854|Ciruelas sol de octubre|O|O||D||1
50305855|Ciruela owen t|O|O||D||1
50305856|Ciruela perdrigon|O|O||D||1
50305857|Ciruela placer rosado|O|O||D||1
50305858|Ciruela  presidente|O|O||D||1
50305859|Ciruela hora prima|O|O||D||1|Ciruela prime time
50305860|Ciruela majestad purpura|O|O||D||1
50305861|Ciruela reina rosa|O|O||D||1
50305862|Ciruela quetsch|O|O||D||1
50305863|Ciruela belleza roja|O|O||D||1
50305864|Ciruela camino rojo|O|O||D||1
50305865|Ciruela ram rojo|O|O||D||1
50305866|Ciruela rosa roja|O|O||D||1
50305867|Ciruela rojo rico|O|O||D||1
50305868|Ciruela romero|O|O||D||1
50305869|Ciruela diamante rojo|O|O||D||1
50305870|Ciruela rojo real|O|O||D||1
50305871|Ciruela royal zee|O|O||D||1
50305872|Ciruela roysum|O|O||D||1
50305873|Ciruela santa rosa|O|O||D||1
50305874|Ciruela zafiro|O|O||D||1
50305875|Ciruela sloe|O|O||D||1
50305876|Ciruela sta catherine|O|O||D||1
50305877|Ciruela bullase blanco|O|O||D||1
50305878|Ciruela creole|O|O||D||1
50305900|Granadas|O|O||D||1
50305901|Granada foothhill|O|O||D||1
50305902|Granada, granada|O|O||D||1|Granada
50305903|Granada rojo feliz|O|O||D||1
50305904|Granada nana|O|O||D||1
50305905|Granada rojo de pat|O|O||D||1
50305906|Granada pinkhan|O|O||D||1
50305907|Granada terciopelo morado|O|O||D||1
50305908|Granada grandioso|O|O||D||1
50306000|Pomelos|O|O||D||1
50306001|Pomelo chandler|O|O||D||1
50306002|Pomelo hirado butan|O|O||D||1
50306003|Pomelo liang ping yau|O|O||D||1
50306004|Pomelo panda wangi|O|O||D||1
50306005|Pomelo rosado|O|O||D||1
50306006|Pomelo shaddock rojo|O|O||D||1
50306007|Pomelo siamese dulce|O|O||D||1
50306008|Pomelo waingwright|O|O||D||1
50306100|Membrillos|O|O||D||1
50306101|Membrillo campeón|O|O||D||1
50306102|Membrillo piña|O|O||D||1
50306103|Membrillo smyma|O|O||D||1
50306200|Frambuesas|O|O||D||1
50306201|Frambuesa americana roja|O|O||D||1
50306202|Frambuesa bailey queensland|O|O||D||1
50306203|Frambuesa negra|O|O||D||1
50306204|Frambuesa oscura|O|O||D||1
50306205|Frambuesa deliciosa|O|O||D||1
50306206|Frambuesa enano focke|O|O||D||1
50306207|Frambuesa focke hojagris|O|O||D||1
50306208|Frambuesa focke fresa|O|O||D||1
50306209|Frambuesa  focke amarillo himalaya|O|O||D||1
50306210|Frambuesa dorado|O|O||D||1
50306211|Frambuesa gris nuevo mexico|O|O||D||1
50306212|Frambuesa jepson blancobark|O|O||D||1
50306213|Frambuesa kellogs san diego|O|O||D||1
50306214|Frambuesa leucodemis blancobark|O|O||D||1
50306215|Frambuesa munz cuyamaca|O|O||D||1
50306216|Frambuesa peck bartons|O|O||D||1
50306217|Frambuesa flor morada|O|O||D||1
50306218|Frambuesa roadside|O|O||D||1
50306219|Frambuesa san diego|O|O||D||1
50306220|Frambuesa nieve|O|O||D||1
50306221|Frambuesa pico de nieve|O|O||D||1
50306222|Frambuesa hoja de fresa|O|O||D||1
50306223|Frambuesa cultivo dulce|O|O||D||1
50306224|Frambuesa tor y gris blancobark|O|O||D||1
50306225|Frambuesa caribe|O|O||D||1
50306226|Frambuesa blancobark|O|O||D||1
50306227|Frambuesa vino|O|O||D||1
50306228|Frambuesa himalaya amarillo|O|O||D||1
50306229|Frambuesa yu-shan|O|O||D||1
50306300|Ruibarbos|O|O||D||1|Acelgas rojas
50306301|Ruibarbo crimson rojo|O|O||D||1|Acelga roja crimson
50306302|Ruibarbo champagne temprana|O|O||D||1|Acelga roja champagne temprana
50306303|Ruibarbo glasrey perpetual|O|O||D||1|Acelga roja glasrey perpetual
50306304|Ruibarbo sutton|O|O||D||1|Acelga roja sutton
50306305|Ruibarbo timperley temprano|O|O||D||1|Acelga roja temprana de Timperley
50306306|Ruibarbo valentina|O|O||D||1|Acelga roja valentina
50306307|Ruibarbo victoria|O|O||D||1|Acelga roja victoria
50306308|Ruibarbo zwolle de cemilla|O|O||D||1|Acelga roja zwolle de semilla
50306309|Ruibarbo macdonald|O|O||D||1|Acelga roja macdonald
50306310|Ruibarbo tilden|O|O||D||1|Acelga roja tilden
50306400|Escaramujos|O|O||D||1|Rosa mosqueta
50306401|Escaramujo rosa brier|O|O||D||1|Rosa mosqueta brier
50306402|Escaramujo rosa elegante|O|O||D||1|Rosa mosqueta elegante
50306403|Escaramujo rosa rugosa|O|O||D||1|Rosa mosqueta rugosa
50306404|Escaramujo rosa burnet o scotch|O|O||D||1|Rosa mosqueta burnet o scotch
50306500|Sapotes|O|O||D||1|Zapotes
50306501|Sapote blanco|O|O||D||1|Zapote blanco
50306502|Sapote negro|O|O||D||1|Zapote negro
50306600|Bayas saskatoon|O|O||D||1|Fresas de junio
50306601|Baya mielmadera saskatoon|O|O||D||1|Fresa de junio mielmadera
50306602|Baya northline saskatoon|O|O||D||1|Fresa de junio northline
50306603|Baya saskatoon ahumado|O|O||D||1|Fresa de junio smoky
50306604|Baya saskatoon thiessen|O|O||D||1|Fresa de junio thiessen
50306700|Fresas|O|O||D||1
50306701|Fresa chandler|O|O||D||1
50306702|Fresa rumbo junio|O|O||D||1|Fresa temporada de junio
50306703|Fresa rumbo siempre|O|O||D||1|Fresa de todo el año
50306800|Manzanas dulces|O|O||D||1|Saramuyos
50306801|Manzana kampong malve dulce|O|O||D||1|Saramuyo kampong mauve
50306802|Manzana dulce sin pepa|O|O||D||1|Saramuyo sin semilla
50306803|Manzana dulce thai lessand|O|O||D||1|Saramuyo thai lessand
50306900|Tamarillos|O|O||D||1|Tomates de árbol
50306901|Tamarillo amberlea dorado|O|O||D||1|Tomate de árbol amberlea dorado
50306902|Tamarillo calvo dorado|O|O||D||1|Tomate de árbol calvo dorado
50306903|Tamarillo mina de oro|O|O||D||1|Tomate de árbol mina de oro
50306904|Tamarillo oratia rojo|O|O||D||1|Tomate de árbol oratia rojo
50306905|Tamarillo beau rojo|O|O||D||1|Tomate de árbol beau rojo
50306906|Tamarillo delicia roja|O|O||D||1|Tomate de árbol delicia roja
50307000|Frutas Nominant|O|O||D||1|Frutas predominantes, Caña de azúcar, Tejocote, Xoconostle ,
50307001|Cupania|O|O||D||1|Ackee
50307002|Babaco|O|O||D||1|Carica pentágona
50307003|Banana flor|O|O||D||1|Flor de plátano
50307004|Baobab|O|O||D||1
50307005|Naranja agria|O|O||D||1
50307006|Canistel|O|O||D||1|Zapote amarillo
50307007|Baya nublosa|O|O||D||1|Mora de los pantanos
50307008|Coco|O|O||D||1
50307009|Baya drew|O|O||D||1|Baya de gota
50307010|Durian|O|O||D||1|Durio
50307011|Baya elder|O|O||D||1|Baya de sauco
50307012|Feijoa|O|O||D||1|Guayabo del Brasil
50307013|Mora|O|O||D||1
50307014|Espino|O|O||D||1|Majuelo
50307015|Baya miel|O|O||D||1|Madreselva azul
50307016|Jaca|O|O||D||1|Yaca
50307017|Jambolan|O|O||D||1
50307018|Jujube|O|O||D||1|Azufaifa
50307019|Liches|O|O||D||1|Lichi
50307020|Mangostinos|O|O||D||1|Mangostán
50307021|Nísperos|O|O||D||1|Medlar
50307022|Mombines|O|O||D||1|Hobo
50307023|Monstera|O|O||D||1|Cerimán
50307024|Pepinos|O|O||D||1|Pepino dulce
50307025|Platano|O|O||D||1|Plátano macho
50307026|Peras en escabeche|O|O||D||1|Tuna
50307027|Mamonsillo|O|O||D||1|Guaya
50307028|Rambután|O|O||D||1|Achotillo
50307029|Manzana rosa|O|O||D||1|Pero de agua
50307030|Rosele|O|O||D||1|Flor de jamaica
50307031|Baya rowan|O|O||D||1|Serba
50307032|Baya buckhom de mar|O|O||D||1|Espino amarillo
50307033|Baya plata|O|O||D||1|Olivo de otoño
50307034|Baya sorbete|O|O||D||1|Serba
50307035|Guanabana|O|O||D||1
50307036|Manzana estrella|O|O||D||1|Cainito
50307037|Tamarindo|O|O||D||1
50307038|Camu camu|O|O||D||1
50307039|Lúcuma|O|O||D||1
50307040|Araza|O|O||D||1|Guayaba amazónica
50307041|Copoazu|O|O||D||1|Cacao blanco
50307042|Poma rosa|O|O||D||1|Pomarrosa
50307043|Aguaje|O|O||D||1|Moriche
50307044|Cocona|O|O||D||1|Túpiro
50307045|Guayaba|O|O||D||1|Jinicuil
50307046|Carambola|O|O||D||1|Fruta de estrella
50307100|Aronias|O|O||D||1
50307101|Aronia magia de otoño|O|O||D||1
50307102|Aronia brillantísima|O|O||D||1
50307103|Aronia nero|O|O||D||1
50307104|Aronia vikingo|O|O||D||1
50307200|Aceitunas|O|O||D||1
50307201|Aceitunas agrinion|O|O||D||1|Aceituna agrinion
50307202|Aceitunas aleppo|O|O||D||1|Aceituna aleppo
50307203|Aceitunas  alfonso|O|O||D||1|Aceituna alfonso
50307204|Aceitunas  amfisa|O|O||D||1|Aceituna amfisa
50307205|Aceitunas  arauco|O|O||D||1|Aceituna arauco
50307206|Aceitunas  arbequina|O|O||D||1|Aceituna arbequina
50307207|Aceitunas  atlanta|O|O||D||1|Aceituna atlanta
50307208|Aceitunas  cerignola|O|O||D||1|Aceituna cerignola
50307209|Aceitunas  cracked provencal|O|O||D||1|Aceituna cracked provencal
50307210|Aceitunas  empeltre|O|O||D||1|Aceituna empeltre
50307211|Aceitunas gaeta|O|O||D||1|Aceituna gaeta
50307212|Aceitunas hondoelia|O|O||D||1|Aceituna hondoelia
50307213|Aceitunas kalamata|O|O||D||1|Aceituna kalamata
50307214|Aceitunas kura|O|O||D||1|Aceituna kura
50307215|Aceitunas ligurian|O|O||D||1|Aceituna ligurian
50307216|Aceitunas lucque|O|O||D||1|Aceituna lucque
50307217|Aceitunas lugano|O|O||D||1|Aceituna lugano
50307218|Aceitunas masanilla|O|O||D||1|Aceituna manzanilla
50307219|Aceitunas marche|O|O||D||1|Aceituna marche
50307220|Aceitunas misión|O|O||D||1|Aceituna misión
50307221|Aceitunas nafplion verde|O|O||D||1|Aceituna nafplion verde
50307222|Aceitunas nicoise|O|O||D||1|Aceituna nicoise
50307223|Aceitunas nyons|O|O||D||1|Aceituna nyons
50307224|Aceitunas picholine|O|O||D||1|Aceituna picholine
50307225|Aceitunas ponentine|O|O||D||1|Aceituna ponentine
50307226|Aceitunas royal|O|O||D||1|Aceituna royal
50307227|Aceitunas seracena|O|O||D||1|Aceituna seracena
50307228|Aceitunas sevillano|O|O||D||1|Aceituna sevillano
50307229|Aceitunas sicilian|O|O||D||1|Aceituna sicilian
50307230|Aceitunas toscanella|O|O||D||1|Aceituna toscanella
50307500|Subproductos de frutas frescas|O|O||D||1
50307501|Cascara de frutas cítricas|O|O||D||1
50307502|Extracto de naranja para mezclar en agua|O|O||D||1
50307503|Pulpa|O|O||D||1
50311500|Manzanas orgánicas|O|O||D||1
50311501|Manzanas akane orgánicas|O|O||D||1|Manzana akane orgánicas
50311502|Manzana ambrosia orgánica|O|O||D||1
50311503|Manzanas api orgánicas|O|O||D||1|Manzana api orgánicas
50311504|Manzanas baldwin orgánicas|O|O||D||1|Manzana baldwin orgánicas
50311505|Manzanas brabum orgánicas|O|O||D||1|Manzana brabum orgánicas
50311506|Manzanas bramley orgánicas|O|O||D||1|Manzana bramley orgánicas
50311507|Manzana joven bramley orgánic|O|O||D||1
50311508|Manzana calville blanche d’hiver orgánic|O|O||D||1
50311509|Manzana cameo orgánica|O|O||D||1
50311510|Manzana charles ross orgánica|O|O||D||1
50311511|Manzana codlin orgánica|O|O||D||1
50311512|Manzana cortland orgánica|O|O||D||1
50311513|Manzana costard orgánica|O|O||D||1
50311514|Manzana court pendu plat orgánica|O|O||D||1
50311515|Manzana  cox´s orange pippin orgánica|O|O||D||1
50311516|Manzana crab orgánica|O|O||D||1
50311517|Manzana crispin orgánica|O|O||D||1
50311518|Manzana delicioso orgánica|O|O||D||1
50311519|Manzana duquesa orgánica|O|O||D||1
50311520|Manzana earli dorado orgánica|O|O||D||1
50311521|Manzana early mcintosh orgánica|O|O||D||1
50311522|Manzana elstar orgánica|O|O||D||1
50311523|Manzana empire orgánica|O|O||D||1
50311524|Manzana flor de kent orgánica|O|O||D||1
50311525|Manzana fiji orgánica|O|O||D||1
50311526|Manzana gala orgánica|O|O||D||1
50311527|Manzana gascoyne´s scarlet orgánica|O|O||D||1
50311528|Manzana gillyflower orgánica|O|O||D||1
50311529|Manzana ginger dorado orgánica|O|O||D||1
50311530|Manzana gladstone orgánica|O|O||D||1
50311531|Manzana gloster orgánica|O|O||D||1
50311532|Manzana dorado supreme orgánica|O|O||D||1
50311533|Manzana doradoen delicioso orgánica|O|O||D||1
50311534|Manzana doradoen nobel orgánica|O|O||D||1
50311535|Manzana granny smith orgánica|O|O||D||1
50311536|Manzana gravenstain orgánica|O|O||D||1
50311537|Manzana verdeing orgánica|O|O||D||1
50311538|Manzana verdesleeves orgánica|O|O||D||1
50311539|Manzana honeycrisp orgánica|O|O||D||1
50311540|Manzana howgate wonder orgánica|O|O||D||1
50311541|Manzana rojo ida orgánica|O|O||D||1
50311542|Manzana james grives orgánica|O|O||D||1
50311543|Manzana jersey mac orgánica|O|O||D||1
50311544|Manzana jaster orgánica|O|O||D||1
50311545|Manzana jonadorado orgánica|O|O||D||1
50311546|Manzana jonamac orgánica|O|O||D||1
50311547|Manzana  jonathan  orgánica|O|O||D||1
50311548|Manzana katy orgánica|O|O||D||1
50311549|Manzana kidd´s orange rojo orgánica|O|O||D||1
50311550|Manzana lady orgánica|O|O||D||1
50311551|Manzana law rome orgánica|O|O||D||1
50311552|Manzana laxton orgánica|O|O||D||1
50311553|Manzana lord derby orgánica|O|O||D||1
50311554|Manzana macoun  orgánica|O|O||D||1
50311555|Manzana mcintosh orgánica|O|O||D||1
50311556|Manzana mutsu orgánica|O|O||D||1
50311557|Manzana newtown pippin orgánica|O|O||D||1
50311558|Manzana northen spy orgánica orgánica|O|O||D||1
50311559|Manzana orleans reinette orgánica|O|O||D||1
50311560|Manzana ozark dorado orgánica|O|O||D||1
50311561|Manzana pacific rose orgánica|O|O||D||1
50311562|Manzana paula rojo orgánica|O|O||D||1
50311563|Manzana peamain orgánica|O|O||D||1
50311564|Manzana pink lady orgánica|O|O||D||1
50311565|Manzana pippin orgánica|O|O||D||1
50311566|Manzana pitmaston pineapple orgánica|O|O||D||1
50311567|Manzana pomme dápi orgánica|O|O||D||1
50311568|Manzana prime dorado orgánica|O|O||D||1
50311569|Manzana rojo astrakhan orgánica|O|O||D||1
50311570|Manzana rojo boscoop orgánica|O|O||D||1
50311571|Manzana  rojo chief orgánica|O|O||D||1
50311572|Manzana rojo delicioso orgánica|O|O||D||1
50311573|Manzana rojo grvenstain orgánica|O|O||D||1
50311574|Manzana re rome orgánica|O|O||D||1
50311575|Manzana rojo stayman orgánica|O|O||D||1
50311576|Manzana rojo york orgánica|O|O||D||1
50311577|Manzana reinette orgánica|O|O||D||1
50311578|Manzana rome beuty orgánica|O|O||D||1
50311579|Manzana russet orgánica|O|O||D||1
50311580|Manzana sierra beaty orgánica|O|O||D||1
50311581|Manzana spartan orgánica|O|O||D||1
50311582|Manzana stark crimson orgánica|O|O||D||1
50311583|Manzana starrey orgánica|O|O||D||1
50311584|Manzana stayman orgánica|O|O||D||1
50311585|Manzana stayman winesap orgánica|O|O||D||1
50311586|Manzana verano rambo orgánica|O|O||D||1
50311587|Manzana tsugaru orgánica|O|O||D||1
50311588|Manzana veinte onzas orgánica|O|O||D||1
50311589|Manzana tydeman rojo orgánica|O|O||D||1
50311590|Manzana vistabella orgánica|O|O||D||1
50311591|Manzana weatley orgánica|O|O||D||1
50311592|Manzana blanco joanetine orgánica|O|O||D||1
50311593|Manzana blanco transparent orgánica|O|O||D||1
50311594|Manzana winesap orgánica|O|O||D||1
50311595|Manzana worcester orgánica|O|O||D||1
50311596|Manzana york imperial orgánica|O|O||D||1
50311600|Albaricoques orgánicos|O|O||D||1|Chabacanos orgánicos
50311601|Abaricoques ambercot orgánica|O|O||D||1|Chabacano ambercot orgánico
50311602|Albaricoques apache orgánica|O|O||D||1|Chabacano apache orgánico
50311603|Albaricoques brittany dorado orgánica|O|O||D||1|Chabacano brittany dorado orgánico
50311604|Albaricoque negro orgánica|O|O||D||1|Chabacano negro orgánico
50311605|Albaricoque blenheim orgánica|O|O||D||1|Chabacano blenheim orgánico
50311606|Albaricoque bonny orgánica|O|O||D||1|Chabacano bonny orgánico
50311607|Albaricoque biluda orgánica|O|O||D||1|Chabacano biluda orgánico
50311608|Albaricoque castlebrite orgánica|O|O||D||1|Chabacano castlebrite orgánico
50311609|Albaricoque  clutha dorado orgánica|O|O||D||1|Chabacano clutha dorado orgánico
50311610|Albaricoque clutha sun orgánica|O|O||D||1|Chabacano clutha sun orgánico
50311611|Albaricoque derby royal orgánica|O|O||D||1|Chabacano derby royal orgánico
50311612|Albaricoque dina orgánica|O|O||D||1|Chabacano dina orgánico
50311613|Albaricoque earlicot orgánica|O|O||D||1|Chabacano earlicot orgánico
50311614|Albaricoque earliman orgánica|O|O||D||1|Chabacano earliman orgánico
50311615|Albaricoque early bright orgánica|O|O||D||1|Chabacano early bright orgánico
50311616|Albaricoque  flaming dorado orgánica|O|O||D||1|Chabacano flaming dorado orgánico
50311617|Albaricoque frenso orgánica|O|O||D||1|Chabacano frenso orgánico
50311618|Albaricoque dorado bright orgánica|O|O||D||1|Chabacano dorado bright orgánico
50311619|Albaricoque doradobar orgánica|O|O||D||1|Chabacano doradobar orgánico
50311620|Albaricoque doradoen sweet orgánica|O|O||D||1|Chabacano doradoen sweet orgánico
50311621|Albaricoque doradorich orgánica|O|O||D||1|Chabacano  orgánico
50311622|Albaricoque helena orgánica|O|O||D||1|Chabacano helena orgánico
50311623|Albaricoque honeycot orgánica|O|O||D||1|Chabacano  orgánico
50311624|Albaricoque imperial orgánica|O|O||D||1|Chabacano imperial orgánico
50311625|Albaricoque jordanne orgánica|O|O||D||1|Chabacano jordanne orgánico
50311626|Albaricoque jumbo cot orgánica|O|O||D||1|Chabacano jumbo cot orgánico
50311627|Albaricoque kandy kot orgánica|O|O||D||1|Chabacano kandy kot orgánico
50311628|Albaricoque katy orgánica|O|O||D||1|Chabacano katy orgánico
50311629|Albaricoque rey orgánica|O|O||D||1|Chabacano rey orgánico
50311630|Albaricoque lambertin orgánica|O|O||D||1|Chabacano lambertin orgánico
50311631|Albaricoque loma orgánica|O|O||D||1|Chabacano loma orgánico
50311632|Albaricoque lulu belle orgánica|O|O||D||1|Chabacano lulu belle orgánico
50311633|Albaricoque modesto orgánica|O|O||D||1|Chabacano modesto orgánico
50311634|Albaricoque moorpark orgánica|O|O||D||1|Chabacano moorpark orgánico
50311635|Albaricoque orangerojo orgánica|O|O||D||1|Chabacano orange rojo orgánico
50311636|Albaricoque palstein orgánica|O|O||D||1|Chabacano palstein orgánico
50311637|Albaricoque patterson orgánica|O|O||D||1|Chabacano patterson orgánico
50311638|Albaricoque perfection orgánica|O|O||D||1|Chabacano perfection orgánico
50311639|Albaricoque poppy orgánica|O|O||D||1|Chabacano poppy orgánico
50311640|Albaricoque poppycot orgánica|O|O||D||1|Chabacano poppy cot orgánico
50311641|Albaricoque reina orgánica|O|O||D||1|Chabacano reina orgánico
50311642|Albaricoque riland orgánica|O|O||D||1|Chabacano riland orgánico
50311643|Albaricoque rival orgánica|O|O||D||1|Chabacano rival orgánico
50311644|Albaricoque robada orgánica|O|O||D||1|Chabacano robada orgánico
50311645|Albaricoque royal orgánica|O|O||D||1|Chabacano royal orgánico
50311646|Albaricoque  royal blenheim orgánica|O|O||D||1|Chabacano royal blenheim orgánico
50311647|Albaricoque  royal orange orgánica|O|O||D||1|Chabacano royal orange orgánico
50311648|Albaricoque sundrop orgánica|O|O||D||1|Chabacano sundrop orgánico
50311649|Albaricoque tilton orgánica|O|O||D||1|Chabacano tilton orgánico
50311650|Albaricoque tomcot orgánica|O|O||D||1|Chabacano tomcot orgánico
50311651|Albaricoque tracy orgánica|O|O||D||1|Chabacano tracy orgánico
50311652|Albaricoque tri gem orgánica|O|O||D||1|Chabacano tri gem orgánico
50311653|Albaricoque valley dorado orgánica|O|O||D||1|Chabacano valley dorado orgánico
50311654|Albaricoque westley orgánica|O|O||D||1|Chabacano westley orgánico
50311655|Albaricoque  york orgánica|O|O||D||1|Chabacano york orgánico
50311700|Bananos orgánicos|O|O||D||1|Plátanos orgánicos
50311701|Banana apple orgánica|O|O||D||1|Plátano apple orgánico
50311702|Banana baby orgánica|O|O||D||1|Plátano baby orgánico
50311703|Banana burro orgánica|O|O||D||1|Plátano burro orgánico
50311704|Bananas cavendish orgánica|O|O||D||1|Plátano cavendish orgánico
50311705|Bananas dominico orgánica|O|O||D||1|Plátano dominico orgánico
50311706|Bananas verde orgánica|O|O||D||1|Plátano verde orgánico
50311707|Bananas gros michel orgánica|O|O||D||1|Plátano gros michel orgánico
50311708|Bananas lacatan orgánica|O|O||D||1|Plátano lacatan orgánico
50311709|Bananas lady finger orgánica|O|O||D||1|Plátano lady finger orgánico
50311710|Bananas manzano orgánica|O|O||D||1|Plátano manzano orgánico
50311711|Banana mysore orgánica|O|O||D||1|Plátano mysore orgánico
50311712|Banana pisang mas orgánica|O|O||D||1|Plátano pisang mas orgánico
50311713|Bananas rojo orgánica|O|O||D||1|Plátano rojo orgánico
50311714|Bananas saba orgánica|O|O||D||1|Plátano saba orgánico
50311715|Bananas sucrier orgánica|O|O||D||1|Plátano sucrier orgánico
50311800|Barberries orgánicos|O|O||D||1|Berberís orgánicos
50311801|Berberís paleleaf orgánica|O|O||D||1|Berberí paleleaf orgánico
50311802|Barberís chenault orgánica|O|O||D||1|Berberí chenault orgánico
50311803|Barberries rojo orgánica|O|O||D||1|Berberí rojo orgánico
50311804|Barberís winterverde orgánica|O|O||D||1|Berberí winterverde orgánico
50311805|Barberís korean orgánica|O|O||D||1|Berberí korean orgánico
50311806|Barberís mentor orgánica|O|O||D||1|Berberí mentor orgánico
50311807|Barberís japanese orgánica|O|O||D||1|Berberí japanese orgánico
50311808|Barberís atropurpurea orgánica|O|O||D||1|Berberí atropurpurea orgánico
50311809|Barberís aurea orgánica|O|O||D||1|Berberí aurea orgánico
50311810|Barberís bagatelle orgánica|O|O||D||1|Berberí bagatelle orgánico
50311811|Barberís crimsom pygmy orgánica|O|O||D||1|Berberí crimsom pygmy orgánico
50311812|Barberís kobold orgánica|O|O||D||1|Berberí kobold orgánico
50311813|Barberís warty orgánica|O|O||D||1|Berberí warty orgánico
50311814|Barberís european orgánica|O|O||D||1|Berberí european orgánico
50311900|Gayubas orgánicas|O|O||D||1|Rastreras orgánicas
50311901|Gayuba alpine orgánica|O|O||D||1|Rastrera alpine orgánica
50311902|Gayuba roja orgánica|O|O||D||1|Rastrera roja orgánica
50311903|Gayuba comun orgánica|O|O||D||1|Rastrera común orgánica
50312000|Moras orgánicas|O|O||D||1|Zarzamoras orgánicas
50312001|Mora apache orgánica|O|O||D||1|Zarzamora apache orgánica
50312002|Mora negro satin orgánica|O|O||D||1|Zarzamora negro satín orgánica
50312003|Mora orgánica|O|O||D||1|Zarzamora orgánica
50312004|Mora cherokee orgánica|O|O||D||1|Zarzamora cherokee orgánica
50312005|Mora chester orgánica|O|O||D||1|Zarzamora chéster orgánica
50312006|Mora dirksen orgánica|O|O||D||1|Zarzamora dirksen orgánica
50312007|Bayas josta orgánica|O|O||D||1|Zarzamora josta orgánica
50312008|Bayas logan orgánica|O|O||D||1|Zarzamora logan orgánica
50312009|Bayas marion orgánica|O|O||D||1|Zarzamora marion orgánica
50312010|Mora navaho orgánica|O|O||D||1|Zarzamora navaho orgánica
50312011|Baya nectar orgánica|O|O||D||1|Zarzamora néctar orgánica
50312012|Mora olallie orgánica|O|O||D||1|Zarzamora olallie orgánica
50312013|Baya tay orgánica|O|O||D||1|Zarzamora tay orgánica
50312014|Mora thomless hull orgánica|O|O||D||1|Zarzamora thomless hull orgánica
50312015|Baya young orgánicos|O|O||D||1|Zarzamora young orgánicos
50312100|Arándanos de mirto orgánicos|O|O||D||1|Mirtillos orgánicos
50312101|Arandanos bog orgánicos|O|O||D||1|Mirtillo bog orgánico
50312102|Arandanos dwarf orgánicos|O|O||D||1|Mirtillo enano orgánico
50312103|Arandanos mountain orgánicos|O|O||D||1|Mirtillo de montaña orgánico
50312104|Arandanos oval-leaved orgánicos|O|O||D||1|Mirtillo oval-leaved orgánico
50312200|Agrás orgánicas|O|O||D||1|Frutos azules del bosque orgánicos
50312201|Agras bluetta orgánica|O|O||D||1|Fruto azul del bosque bluetta orgánico
50312202|Agras duque orgánica|O|O||D||1|Fruto azul del bosque duque orgánico
50312203|Agras spartan orgánica|O|O||D||1|Fruto azul del bosque spartan orgánico
50312204|Agras patriot orgánica|O|O||D||1|Fruto azul del bosque patriot orgánico
50312205|Agras toro orgánica|O|O||D||1|Fruto azul del bosque toro orgánico
50312206|Agras hardyblue orgánica|O|O||D||1|Fruto azul del bosque hardyblue orgánico
50312207|Agras bluecrop orgánica|O|O||D||1|Fruto azul del bosque bluecrop orgánico
50312208|Agras legacy orgánica|O|O||D||1|Fruto azul del bosque legacy orgánico
50312209|Agras nelson orgánica|O|O||D||1|Fruto azul del bosque nelson orgánico
50312210|Agras chandler orgánica|O|O||D||1|Fruto azul del bosque chandler orgánico
50312211|Agras brigitta orgánica|O|O||D||1|Fruto azul del bosque brigitta orgánico
50312212|Agras northcountry orgánica|O|O||D||1|Fruto azul del bosque northcountry orgánico
50312213|Agras northsky orgánica|O|O||D||1|Fruto azul del bosque northsky orgánico
50312214|Agras northblue orgánica|O|O||D||1|Fruto azul del bosque northblue orgánico
50312215|Agras misty orgánica|O|O||D||1|Fruto azul del bosque misty orgánico
50312300|Frutas del pan orgánicas|O|O||D||1
50312301|Fruta de pan chataigne orgánica|O|O||D||1|Fruta del pan chataigne orgánica
50312302|Fruta de pan sin semilla orgánica|O|O||D||1|Fruta del pan sin semilla orgánica
50312303|Fruta de pan corazón blanco orgánica|O|O||D||1|Fruta del pan corazón blanco orgánica
50312304|Fruta de pan corazón amarillo orgánica|O|O||D||1|Fruta del pan corazón amarillo orgánica
50312400|Chirimoyas orgánicas|O|O||D||1|Annonas orgánicas
50312401|Chirimoya chays orgánica|O|O||D||1|Annona chays orgánica
50312402|Chirimoya bronceada orgánica|O|O||D||1|Annona bronceada orgánica
50312403|Chirimoya burtons orgánica|O|O||D||1|Annona burtons orgánica
50312404|Chirimoya burton favorite orgánica|O|O||D||1|Annona burton favorite orgánica
50312405|Chirimoya jete orgánica|O|O||D||1|Annona jete orgánica
50312406|Chirimoya reretai orgánica|O|O||D||1|Annona reretai orgánica
50312407|Chirimoya smoothey orgánica|O|O||D||1|Annona smoothey orgánica
50312408|Chirimoya español orgánica|O|O||D||1|Annona español orgánica
50312409|Chirimoya blanco orgánica|O|O||D||1|Annona blanco orgánica
50312500|Cerezas orgánicas|O|O||D||1
50312501|Cereza amarelle  orgánica|O|O||D||1
50312502|Cereza brooks orgánica|O|O||D||1
50312503|Cereza bigarreu orgánica|O|O||D||1
50312504|Cereza bing orgánica|O|O||D||1
50312505|Cereza blach republic orgánica|O|O||D||1
50312506|Cereza negro schmidt orgánica|O|O||D||1
50312507|Cereza negrotartarian orgánica|O|O||D||1
50312508|Cereza fiesta bing orgánica|O|O||D||1
50312509|Cereza garnet orgánica|O|O||D||1
50312510|Cereza rey orgánica|O|O||D||1
50312511|Cereza chapman orgánica|O|O||D||1
50312512|Cereza lapin orgánica|O|O||D||1
50312513|Cereza larian orgánica|O|O||D||1
50312514|Cereza dark guines orgánica|O|O||D||1
50312515|Cereza montmorency orgánica|O|O||D||1
50312516|Cereza duque orgánica|O|O||D||1
50312517|Cereza early rivers orgánica|O|O||D||1
50312518|Cereza ruby bing orgánica|O|O||D||1
50312519|Cereza santine orgánica|O|O||D||1
50312520|Cereza geans/guines orgánica|O|O||D||1
50312521|Cereza sonata orgánica|O|O||D||1
50312522|Cereza lambert orgánica|O|O||D||1
50312523|Cereza stella orgánica|O|O||D||1
50312524|Cereza sweethart orgánica|O|O||D||1
50312525|Cereza tartarian orgánica|O|O||D||1
50312527|Cereza maraschino orgánica|O|O||D||1
50312528|Cereza van orgánica|O|O||D||1
50312529|Cereza morello orgánica|O|O||D||1
50312530|Cereza royal ann orgánica|O|O||D||1
50312531|Cereza ranier orgánica|O|O||D||1
50312532|Cereza royal orgánica|O|O||D||1
50312600|Citrones orgánicos|O|O||D||1|Cidras orgánicas
50312601|Citrones buddha´s hand orgánica|O|O||D||1|Cidra mano de Buda orgánica
50312602|Citrones fingerojo orgánica|O|O||D||1|Cidra finger red orgánica
50312603|Citrones fo shoukan orgánica|O|O||D||1|Cidra fo shoukan orgánica
50312604|Cotrones bushakan orgánica|O|O||D||1|Cidra bushakan orgánica
50312605|Citones diamante orgánica|O|O||D||1|Cidra diamante orgánica
50312606|Citrones etrog orgánica|O|O||D||1|Cidra etrog orgánica
50312607|Citrones ponderosa orgánica|O|O||D||1|Cidra ponderosa orgánica
50312700|Arándanos orgánicos|O|O||D||1|Arándanos rojos orgánicos
50312701|Arandano ben lear orgánica|O|O||D||1|Arándano rojo ben lear orgánico
50312702|Arandano early negro orgánica|O|O||D||1|Arándano rojo early negro orgánico
50312703|Arandano grycleski orgánica|O|O||D||1|Arándano rojo grycleski orgánico
50312704|Arandano  howe orgánica|O|O||D||1|Arándano rojo howe orgánico
50312705|Bayas lingon orgánica|O|O||D||1|Arándano rojo lingon orgánico
50312706|Arandano mcfarling orgánica|O|O||D||1|Arándano rojo mcfarling orgánico
50312707|Arandano mauntain orgánica|O|O||D||1|Arándano rojo mauntain orgánico
50312708|Arandano pilgrim orgánica|O|O||D||1|Arándano rojo pilgrim orgánico
50312709|Arandano searless orgánica|O|O||D||1|Arándano rojo searless orgánico
50312710|Arandano stevens orgánica|O|O||D||1|Arándano rojo stevens orgánico
50312800|pasas de Corinto orgánicas|O|O||D||1
50312801|Pasa hudson bay orgánica|O|O||D||1|Pasa de Corinto hudson bay orgánica
50312802|Pasa waxy orgánica|O|O||D||1|Pasa de Corinto waxy orgánica
50312803|Pasa desert orgánica|O|O||D||1|Pasa de Corinto desert orgánica
50312804|Pasa negra orgánica|O|O||D||1|Pasa de Corinto negra orgánica
50312805|Pasa roja orgánica|O|O||D||1|Pasa de Corinto roja orgánica
50312806|Pasa blanca orgánica|O|O||D||1|Pasa de Corinto blanca orgánica
50312900|Dátiles orgánicos|O|O||D||1
50312901|Dátiles asharasi  orgánica|O|O||D||1
50312902|Dátiles barhi o barhee orgánica|O|O||D||1
50312903|Dátiles deglet noor orgánica|O|O||D||1
50312904|Dátiles fardh orgánica|O|O||D||1
50312905|Dátiles gundila orgánica|O|O||D||1
50312906|Dátiles halawi/halawy orgánica|O|O||D||1
50312907|Dátiles hilali orgánica|O|O||D||1
50312908|Dátiles khadrawi/khadrawy orgánica|O|O||D||1
50312909|Dátiles khalas orgánica|O|O||D||1
50312910|Dátiles khustawi orgánica|O|O||D||1
50312911|Dátiles khidri orgánica|O|O||D||1
50312912|Dátiles medjool/ medjol orgánica|O|O||D||1
50312913|Dátiles mactoum orgánica|O|O||D||1
50312914|Dátiles neghal orgánica|O|O||D||1
50312915|Dátiles yatimeh orgánica|O|O||D||1
50312916|Dátiles zahidi orgánica|O|O||D||1
50313000|Pitahayas orgánicas|O|O||D||1
50313001|Pitahaya roja, rosada orgánica|O|O||D||1
50313002|Pitahaya roja, amarillo orgánica|O|O||D||1
50313100|Brevas orgánicas|O|O||D||1|Higos orgánicos
50313101|Breva bardajic orgánica|O|O||D||1|Higo bardajic orgánico
50313102|Breva brown turkey orgánica|O|O||D||1|Higo brown turkey orgánico
50313103|Breva calimyma  orgánica|O|O||D||1|Higo calimyma orgánico
50313104|Breva conadria orgánica|O|O||D||1|Higo conadria orgánico
50313105|Breva dotado orgánica|O|O||D||1|Higo dotado orgánico
50313106|Breva kadota orgánica|O|O||D||1|Higo kadota orgánico
50313107|Breva mediterránea orgánica|O|O||D||1|Higo mediterránea orgánico
50313108|Breva misión orgánica|O|O||D||1|Higo misión orgánico
50313109|Breva amyma orgánica|O|O||D||1|Higo amyma orgánico
50313110|Breva verdona orgánica|O|O||D||1|Higo verdona orgánico
50313111|Breva rey blanco orgánica|O|O||D||1|Higo rey blanco orgánico
50313200|Grosellas orgánicas|O|O||D||1
50313201|Grosella early sulphur orgánica|O|O||D||1
50313202|Grosella doradoendrop orgánica|O|O||D||1
50313203|Grosella langley grace orgánica|O|O||D||1
50313204|Grocella leveller orgánica|O|O||D||1
50313205|Grosella london orgánica|O|O||D||1
50313206|Grosella worcestershire orgánica|O|O||D||1
50313207|Grosella american worcesterberry orgánic|O|O||D||1
50313300|Toronjas orgánicas|O|O||D||1
50313301|Toronja burgundi orgánica|O|O||D||1
50313302|Toronja duncan orgánica|O|O||D||1
50313303|Toronja foster orgánica|O|O||D||1
50313304|Toronja marsh orgánica|O|O||D||1
50313305|Toronja nueva zelandia orgánica|O|O||D||1
50313306|Toronja rio rojo orgánica|O|O||D||1
50313307|Toronja ruby rojo orgánica|O|O||D||1
50313308|Toronja star ruby orgánica|O|O||D||1
50313309|Toronja triumph orgánica|O|O||D||1
50313400|Uvas de mesa orgánicas|O|O||D||1
50313401|Uva alicante orgánica|O|O||D||1
50313402|Uva almeira orgánica|O|O||D||1
50313403|Uva alphonse lavalle orgánica|O|O||D||1
50313404|Uva otoño rey grapes orgánica|O|O||D||1
50313405|Uva otoño royal orgánica|O|O||D||1
50313406|Uva otoño sin pepa orgánica|O|O||D||1
50313407|Uva baresana orgánica|O|O||D||1
50313408|Uva barlinka orgánica|O|O||D||1
50313409|Uva beaty seedless orgánica|O|O||D||1
50313410|Uva negro beauty sin pepa orgánica|O|O||D||1
50313411|Uva negro emerald orgánica|O|O||D||1
50313412|Uva negro giant orgánica|O|O||D||1
50313413|Uva negro globo orgánica|O|O||D||1
50313414|Uva negro monnukka orgánica|O|O||D||1
50313415|Uva negro perla orgánica|O|O||D||1
50313416|Uva negro sin pepa orgánica|O|O||D||1
50313417|Uva bonheur orgánica|O|O||D||1
50313418|Uva calmeria orgánica|O|O||D||1
50313419|Uva cardinal orgánica|O|O||D||1
50313420|Uva catawba orgánica|O|O||D||1
50313421|Uva chasselas/doradoen chasselas orgánica|O|O||D||1
50313422|Uva christmas rose orgánica|O|O||D||1
50313423|Uva concord orgánica|O|O||D||1
50313424|Uva concord sin pepa orgánica|O|O||D||1
50313425|Uva crimson sin pepa orgánica|O|O||D||1
50313426|Uva dauphine  orgánica|O|O||D||1
50313427|Uva daleware orgánica|O|O||D||1
50313428|Uva early muscat orgánica|O|O||D||1
50313429|Uva early sweet orgánica|O|O||D||1
50313430|Uva esmeralda sin pepa orgánica|O|O||D||1
50313431|Uva emperatriz orgánica|O|O||D||1
50313432|Uva emperor orgánica|O|O||D||1
50313433|Uva empress orgánica|O|O||D||1
50313434|Uva exótica orgánica|O|O||D||1
50313435|Uva fantasia orgánica|O|O||D||1
50313436|Uva fantasy sin pepa orgánica|O|O||D||1
50313437|Uva llama orgánica|O|O||D||1
50313438|Uva llama sin pepa orgánica|O|O||D||1
50313439|Uva llama tokay orgánica|O|O||D||1
50313440|Uva flaming rojo orgánica|O|O||D||1
50313441|Uva galaxy sin pepa orgánica|O|O||D||1
50313442|Uva gamay orgánica|O|O||D||1
50313443|Uva dorada orgánica|O|O||D||1
50313444|Uva hanepot o honeypot orgánica|O|O||D||1
50313445|Uva italia orgánica|O|O||D||1
50313446|Uva jade sin pepa orgánica|O|O||D||1
50313447|Uva jubilee orgánica|O|O||D||1
50313448|Uva rey ruby orgánica|O|O||D||1
50313449|Uva kyoho orgánica|O|O||D||1
50313450|Uva la rochelle orgánica|O|O||D||1
50313451|Uva lady finger orgánica|O|O||D||1
50313452|Uva late sin pepa orgánica|O|O||D||1
50313453|Uva majestic sin pepa orgánica|O|O||D||1
50313454|Uva malaga orgánica|O|O||D||1
50313455|Uva marro sin pepa orgánica|O|O||D||1
50313456|Uva muscadine orgánica|O|O||D||1
50313457|Uva muscat llama orgánica|O|O||D||1
50313458|Uva muscat orgánica|O|O||D||1
50313459|Uva muscat sin papa orgánica|O|O||D||1
50313460|Uva napoleon orgánica|O|O||D||1
50313461|Uva nigeria orgánica|O|O||D||1
50313462|Uva new cross orgánica|O|O||D||1
50313463|Uva nibella orgánica|O|O||D||1
50313464|Uva niagara orgánica|O|O||D||1
50313465|Uva olivette orgánica|O|O||D||1
50313466|Uva perlette orgánica|O|O||D||1
50313467|Uva perlon orgánica|O|O||D||1
50313468|Uva prima negro sin pepa orgánica|O|O||D||1
50313469|Uva prncess orgánica|O|O||D||1
50313470|Uva reina orgánica|O|O||D||1
50313471|Uva roja blush orgánica|O|O||D||1
50313472|Uva roja globe orgánica|O|O||D||1
50313473|Uva roja malaga orgánica|O|O||D||1
50313474|Uva roja sin pepa orgánica|O|O||D||1
50313475|Uva regina orgánica|O|O||D||1
50313476|Uva ribier orgánica|O|O||D||1
50313477|Uva rosita orgánica|O|O||D||1
50313478|Uva rouge orgánica|O|O||D||1
50313479|Uva royal negra sin pepa orgánica|O|O||D||1
50313480|Uva ruby roja sin pepa orgánica|O|O||D||1
50313481|Uva ryby sin pepa orgánica|O|O||D||1
50313482|Uva scarlet royal orgánica|O|O||D||1
50313483|Uva scuppemong orgánica|O|O||D||1
50313484|Uva sugarose orgánica|O|O||D||1
50313485|Uva sugartirteen orgánica|O|O||D||1
50313486|Uva sugraone orgánica|O|O||D||1
50313487|Uva sugrasixteen orgánica|O|O||D||1
50313488|Uva sultana sun roja orgánica|O|O||D||1
50313489|Uva verano royal orgánica|O|O||D||1
50313490|Uva atardecer orgánica|O|O||D||1
50313491|Uva superior sin pepa orgánica|O|O||D||1
50313492|Uva thompson sin pepa orgánica|O|O||D||1
50313493|Uva tokaylpinot gris orgánica|O|O||D||1
50313494|Uva waltman cross orgánica|O|O||D||1
50313495|Uva blanca sin pepa orgánica|O|O||D||1
50313496|Uva zante current orgánica|O|O||D||1
50313500|Uvas pasas orgánicas|O|O||D||1
50313501|Uva corinth negra orgánica|O|O||D||1
50313502|Uva canner orgánica|O|O||D||1
50313503|Uva dovine orgánica|O|O||D||1
50313504|Uva fiesta orgánica|O|O||D||1
50313505|Uva selme pete orgánica|O|O||D||1
50313506|Uva sultana orgánica|O|O||D||1
50313600|Uvas para vino orgánicas|O|O||D||1
50313601|Uva uva alicante bouschet orgánica|O|O||D||1
50313602|Uva barbera orgánica|O|O||D||1
50313603|Uva burger orgánica|O|O||D||1
50313604|Uva cabemet franc orgánica|O|O||D||1
50313605|Uva cabenet sauvignon orgánica|O|O||D||1
50313606|Uva carignane orgánica|O|O||D||1
50313607|Uva carnelian orgánica|O|O||D||1
50313608|Uva catarratto orgánica|O|O||D||1
50313609|Uva centurian orgánica|O|O||D||1
50313610|Uva charbono orgánica|O|O||D||1
50313611|Uva chardonnay orgánica|O|O||D||1
50313612|Uva chenin blanco orgánica|O|O||D||1
50313613|Uva cinsaut orgánica|O|O||D||1
50313614|Uva dolcetto orgánica|O|O||D||1
50313615|Uva emerald riesling orgánica|O|O||D||1
50313616|Uva french colombard orgánica|O|O||D||1
50313617|Uva gamay o napa orgánica|O|O||D||1
50313618|Uva gamay beaujolais orgánica|O|O||D||1
50313619|Uva gewurztraminer orgánica|O|O||D||1
50313620|Uva grenache orgánica|O|O||D||1
50313621|Uva grenache blanc orgánica|O|O||D||1
50313622|Uva lagrein orgánica|O|O||D||1
50313623|Uva lambrusco orgánica|O|O||D||1
50313624|Uva malbec orgánica|O|O||D||1
50313625|Uva malvasía bianca orgánica|O|O||D||1
50313626|Uva marsanne orgánica|O|O||D||1
50313627|Uva mataro orgánica|O|O||D||1
50313628|Uva merlot orgánica|O|O||D||1
50313629|Uva meunier orgánica|O|O||D||1
50313630|Uva missiom orgánica|O|O||D||1
50313631|Uva montepulciano orgánica|O|O||D||1
50313632|Uva muscat blanc orgánica|O|O||D||1
50313633|Uva muscat hamburg orgánica|O|O||D||1
50313634|Uva muscat alexandria orgánica|O|O||D||1
50313635|Uva muscat naranja orgánica|O|O||D||1
50313636|Uva nebbiolo orgánica|O|O||D||1
50313637|Uva palomino orgánica|O|O||D||1
50313638|Uva petit verdot orgánica|O|O||D||1
50313639|Uva petite sirah orgánica|O|O||D||1
50313640|Uva pinot blanc orgánica|O|O||D||1
50313641|Uva pinot gris orgánica|O|O||D||1
50313642|Uva pinot noir orgánica|O|O||D||1
50313643|Uva primitivo orgánica|O|O||D||1
50313644|Uva roussane orgánica|O|O||D||1
50313645|Uva real  orgánica|O|O||D||1
50313646|Uva rubirojo orgánica|O|O||D||1
50313647|Uva ruby cabenet orgánica|O|O||D||1
50313648|Uva salvador orgánica|O|O||D||1
50313649|Uva sangiovese orgánica|O|O||D||1
50313650|Uva sauvignon blanc orgánica|O|O||D||1
50313651|Uva sauvignon musque orgánica|O|O||D||1
50313652|Uva semillon orgánica|O|O||D||1
50313653|Uva souzao orgánica|O|O||D||1
50313654|Uva st emilion orgánica|O|O||D||1
50313655|Uva symohony orgánica|O|O||D||1
50313656|Uva syrah  orgánica|O|O||D||1
50313657|Uva tannat orgánica|O|O||D||1
50313658|Uva temor anillo orgánica|O|O||D||1
50313659|Uvas teroldego orgánica|O|O||D||1
50313660|Uvas tocai friulano orgánica|O|O||D||1
50313661|Uvas touriga nacional orgánica|O|O||D||1
50313662|Uvas triplett blanc orgánica|O|O||D||1
50313663|Uvas viognier orgánica|O|O||D||1
50313664|Uvas blanco riesling orgánica|O|O||D||1
50313665|Uvas zinfandel orgánica|O|O||D||1
50313700|Guayabas orgánicas|O|O||D||1
50313701|Guayaba beaumont orgánica|O|O||D||1
50313702|Guayaba carrley orgánica|O|O||D||1
50313703|Guayaba lucida orgánica|O|O||D||1
50313704|Guayaba piña orgánica|O|O||D||1
50313800|Arándanos Huckleberry orgánicos|O|O||D||1|Arándanos azules orgánicos
50313801|Arándano invierno negro orgánico|O|O||D||1|Arándano azul invierno negro orgánico
50313802|Arándano cascada orgánico|O|O||D||1|Arándano azul cascada orgánico
50313803|Arándano enano orgánico|O|O||D||1|Arándano azul enano orgánico
50313804|Arándano montaña orgánico|O|O||D||1|Arándano azul montaña orgánico
50313805|Arándano rojo orgánico|O|O||D||1|Arándano azul red orgánico
50313900|Kiwis orgánicos|O|O||D||1
50313901|Fruta de kiwi ananasnaja orgánica|O|O||D||1|Kiwi ananasnaja orgánico
50313902|Fruta de kiwi belleza del ártico orgánica|O|O||D||1|Kiwi belleza del ártico orgánico
50313903|Fruta de kiwi blake orgánica|O|O||D||1|Kiwi blake orgánico
50313904|Fruta de kiwi hayward orgánica|O|O||D||1|Kiwi hayward orgánico
50313905|Fruta de kiwi issai orgánica|O|O||D||1|Kiwi issai orgánico
50313906|Fruta de kiwi siberiana orgánica|O|O||D||1|Kiwi siberiano orgánico
50314000|Naranjos Chinos (kumquats) orgánicos|O|O||D||1
50314001|Naranjo chino hong kong orgánico|O|O||D||1
50314002|Naranjo chino limequat orgánico|O|O||D||1
50314003|Naranjo long fruit orgánico|O|O||D||1|Naranjo chino long fruit orgánico
50314004|Naranjo chino malayan orgánico|O|O||D||1
50314005|Naranjo meiwa orgánico|O|O||D||1|Naranjo chino meiwa orgánico
50314006|Naranja chino nagami orgánico|O|O||D||1|Naranjo chino nagami orgánico
50314100|Limones orgánicos|O|O||D||1
50314101|Limón baboon orgánico|O|O||D||1
50314102|Limón bearss sicilian orgánico|O|O||D||1
50314103|Limón cameron highland orgánico|O|O||D||1
50314104|Limón escondido orgánico|O|O||D||1
50314105|Limón eureka orgánico|O|O||D||1
50314106|Limón lisbon orgánico|O|O||D||1
50314107|Limón meyer orgánico|O|O||D||1
50314108|Limón volkaner orgánico|O|O||D||1
50314200|Limas orgánicas|O|O||D||1
50314201|Lima limón indian sweet orgánico|O|O||D||1
50314202|Lima limón orgánico|O|O||D||1
50314203|Lima limón mandarin orgánico|O|O||D||1
50314204|Lima limón philippine orgánico|O|O||D||1
50314205|Lima limón tahitian orgánico|O|O||D||1
50314206|Lima limón bearss orgánico|O|O||D||1
50314207|Lima limón persa orgánico|O|O||D||1
50314208|Lima limón sin pepas orgánico|O|O||D||1|Lima limón sin semilla orgánico
50314300|Nísperos orgánicos|O|O||D||1
50314301|Níspero advance orgánico|O|O||D||1
50314302|Níspero benlehr orgánico|O|O||D||1
50314303|Níspero big jim orgánico|O|O||D||1
50314304|Níspero champagne orgánico|O|O||D||1
50314305|Níspero early rojo orgánico|O|O||D||1
50314306|Níspero nuget dorado orgánico|O|O||D||1
50314307|Níspero herd´s mammoth orgánico|O|O||D||1
50314308|Níspero mogi orgánico|O|O||D||1
50314309|Níspero mrs cooksey orgánico|O|O||D||1
50314310|Níspero fresa orgánico|O|O||D||1
50314311|Níspero tanaka orgánico|O|O||D||1
50314312|Níspero victoria vista blanco orgánico|O|O||D||1
50314313|Níspero wolfe orgánico|O|O||D||1
50314400|Mandarinas orgánicas|O|O||D||1
50314401|Naranjas clauselinas orgánicas|O|O||D||1
50314402|Mandarinas clementinas orgánicas|O|O||D||1
50314403|Naranja mandarina cleopatra|O|O||D||1
50314404|Mandarina dancy orgánica|O|O||D||1
50314405|Naranja ellensday orgánica|O|O||D||1
50314406|Naranja fairchild orgánica|O|O||D||1
50314407|Naranja fallglo orgánica|O|O||D||1
50314408|Naranja fortuna orgánica|O|O||D||1
50314409|Mandarina naranja fremont orgánica|O|O||D||1
50314410|Naranja fremont orgánica|O|O||D||1
50314411|Naranja nuget dorada orgánica|O|O||D||1
50314412|Mandarina naranja miel orgánica|O|O||D||1
50314413|Naranja miel orgánica|O|O||D||1
50314414|Mandarina miel orgánica|O|O||D||1
50314415|Natanja tanjelo honebelle orgánica|O|O||D||1|Naranja tangelo honebelle orgánica
50314416|Naranja mandarina rey orgánica|O|O||D||1
50314417|Naranja kinnow orgánica|O|O||D||1
50314418|Naranja andarinalee orgánica|O|O||D||1
50314419|Naranja makokkee orgánica|O|O||D||1
50314420|Naranja malvasion orgánica|O|O||D||1
50314421|Naranja mandarina mediterránea orgánica|O|O||D||1
50314422|Naranja tangelo minneola orgánica|O|O||D||1
50314423|Naranja monica orgánica|O|O||D||1
50314424|Naranja murcott miel orgánica|O|O||D||1
50314425|Naranja murcott tangors orgánica|O|O||D||1
50314426|Naranja mandarina natsudaidai  orgánica|O|O||D||1
50314427|Naranja mandarina natsumikan orgánica|O|O||D||1
50314428|Naranja tanjelo nocatee orgánica|O|O||D||1
50314429|Naranja tanjelo orlando orgánica|O|O||D||1
50314430|Mandarina ortanique orgánica|O|O||D||1
50314431|Naranja mandarina pagina orgánica|O|O||D||1
50314432|Naranja pixie orgánica|O|O||D||1
50314433|Naranja mandarina ponkan bantangas orgánica|O|O||D||1
50314434|Naranja reina orgánica|O|O||D||1
50314435|Naranja robinson orgánica|O|O||D||1
50314436|Naranja saltenitas orgánica|O|O||D||1
50314437|Naranja tangelo sampson orgánica|O|O||D||1
50314438|Naranja mandarina satsuma orgánica|O|O||D||1
50314439|Naranja mandarina sunburst orgánica|O|O||D||1
50314440|Tangelo orgánico|O|O||D||1
50314441|Naranja mandarina orgánica|O|O||D||1
50314442|Naranja templo orgánica|O|O||D||1
50314443|Naranja thornton orgánica|O|O||D||1
50314444|Mandarina wekiwa orgánica|O|O||D||1
50314445|Mandarina wilkins orgánica|O|O||D||1
50314446|Mandarina willowleaf mediterránea orgánica|O|O||D||1
50314500|Mangos orgánicos|O|O||D||1
50314501|Mango alphonso orgánico|O|O||D||1
50314502|Mango ataulfo orgánico|O|O||D||1
50314503|Mango criollo orgánico|O|O||D||1
50314504|Mango edwards orgánico|O|O||D||1
50314505|Mango francine orgánico|O|O||D||1
50314506|Mango francis orgánico|O|O||D||1
50314507|Mango gandaria orgánico|O|O||D||1
50314508|Mango haden orgánico|O|O||D||1
50314509|Mangos irwin orgánico|O|O||D||1
50314510|Mangos keitt orgánico|O|O||D||1
50314511|Mangos kent orgánico|O|O||D||1
50314512|Mangos kesar orgánico|O|O||D||1
50314513|Mangos kuini orgánico|O|O||D||1
50314514|Mangos manila super orgánico|O|O||D||1
50314515|Mangos manila orgánico|O|O||D||1
50314516|Mangos mayaguez orgánico|O|O||D||1
50314517|Mangos mulgoba orgánico|O|O||D||1
50314518|Mangos oro orgánico|O|O||D||1
50314519|Mangos palmer orgánico|O|O||D||1
50314520|Mango parvin orgánico|O|O||D||1
50314521|Mango sandersha orgánico|O|O||D||1
50314522|Mangos sensation orgánico|O|O||D||1
50314523|Mango smith orgánico|O|O||D||1
50314524|Mango tomy atkin orgánico|O|O||D||1
50314525|Mango van dyke orgánico|O|O||D||1
50314600|Melones orgánicos|O|O||D||1
50314601|Melon allsweet orgánico|O|O||D||1
50314602|Melón athens orgánico|O|O||D||1
50314603|Melón diamante negro orgánico|O|O||D||1
50314604|Melón cal dulce orgánico|O|O||D||1
50314605|Melons cantaloupe orgánico|O|O||D||1
50314606|Melón carnical orgánico|O|O||D||1
50314607|Melón casaba orgánico|O|O||D||1
50314608|Melón cavaillon orgánico|O|O||D||1
50314609|Melón charentais orgánico|O|O||D||1
50314610|Sandia charleston gray orgánico|O|O||D||1
50314611|Melón crenshaw orgánico|O|O||D||1
50314612|Melón crimson sweet orgánico|O|O||D||1
50314613|Melón dixie lee orgánico|O|O||D||1
50314614|Melón eclipse orgánico|O|O||D||1
50314615|Melón ein dór  orgánico|O|O||D||1
50314616|Melón fiesta orgánico|O|O||D||1
50314617|Melón galia orgánico|O|O||D||1
50314618|Melón gaya orgánico|O|O||D||1
50314619|Melón hami orgánico|O|O||D||1
50314620|Melón miel dew orgánico|O|O||D||1
50314621|Melón hielo orgánico|O|O||D||1
50314622|Melón ida orgullo orgánico|O|O||D||1
50314623|Melón juan canary orgánico|O|O||D||1
50314624|Melón jubileo orgánico|O|O||D||1
50314625|Melón jubilación orgánico|O|O||D||1
50314626|Melón kaki / kakri orgánico|O|O||D||1
50314627|Melón kiwano orgánico|O|O||D||1
50314628|Melon koreano orgánico|O|O||D||1|Melón coreano orgánico
50314629|Melón long grey orgánico|O|O||D||1|Melón largo gris orgánico
50314630|Melón mayan orgánico|O|O||D||1
50314631|Melón micky lee orgánico|O|O||D||1
50314632|Melón mirage orgánico|O|O||D||1
50314633|Sandia luna y estrellas orgánico|O|O||D||1
50314634|Melón ogen orgánico|O|O||D||1
50314635|Melón patriot orgánico|O|O||D||1
50314636|Melón peacook orgánico|O|O||D||1
50314637|Melón pepino orgánico|O|O||D||1
50314638|Melón persian orgánico|O|O||D||1
50314639|Melón picnic orgánico|O|O||D||1
50314640|Melón piel de sapo orgánico|O|O||D||1
50314641|Melón piña orgánico|O|O||D||1
50314642|Melón quetzali orgánico|O|O||D||1
50314643|Melón goblin rojo orgánico|O|O||D||1
50314644|Melón regency orgánico|O|O||D||1
50314645|Melón royal mejestic orgánico|O|O||D||1
50314646|Melón royal star orgánico|O|O||D||1
50314647|Melón dulce royal orgánico|O|O||D||1
50314648|Malon santa claus orgánico|O|O||D||1|Melón piel de sapo orgánico, Melón santa claus orgánico
50314649|Melón sharlyn orgánico|O|O||D||1
50314650|Melón español orgánico|O|O||D||1
50314651|Melón sprite orgánic orgánico|O|O||D||1
50314652|Melón starbright orgánico|O|O||D||1
50314653|Melón stars and stripes orgánico|O|O||D||1
50314654|Melón bebe de azúcar orgánico|O|O||D||1
50314655|Sandia bebe de azúcar orgánica|O|O||D||1
50314656|Melón dulce sol orgánico|O|O||D||1
50314657|Sandia corazón dulce sin semilla orgánica|O|O||D||1
50314658|Melón tentación orgánico|O|O||D||1
50314659|Melón bebé tigre orgánico|O|O||D||1
50314660|Melón tuscan tipo orgánico|O|O||D||1
50314661|Sandia baby amarillo orgánica|O|O||D||1
50314700|Moras mulberry orgánicas|O|O||D||1|Zarzamoras mulberry orgánicas
50314701|Mora negra orgánica|O|O||D||1|Zarzamora negra orgánica
50314702|Mora blanca orgánica|O|O||D||1|Zarzamora blanca orgánica
50314800|Mirtos orgánicos|O|O||D||1|Arrayanes orgánicos
50314801|Mirto bog orgánico|O|O||D||1|Arrayán bog orgánico
50314900|Nectarinas orgánicos|O|O||D||1
50314901|Durazno april glo orgánico|O|O||D||1
50314902|Durazno arctic mist orgánico|O|O||D||1
50314903|Durazno artic snow orgánico|O|O||D||1
50314904|Durazno artic star orgánico|O|O||D||1
50314905|Durazno artic dulce orgánico|O|O||D||1
50314906|Durazno artic glo orgánico|O|O||D||1
50314907|Durazno august fire orgánico|O|O||D||1
50314908|Durazno  perla de agosto orgánico|O|O||D||1
50314909|Durazno agosto rojo orgánico|O|O||D||1
50314910|Durazno estrella de agosto orgánico|O|O||D||1
50314911|Durazno big john orgánico|O|O||D||1
50314912|Durazno perla brillante orgánico|O|O||D||1
50314913|Durazno diamante brillante orgánico|O|O||D||1
50314914|Durazno diamante ray orgánico|O|O||D||1
50314915|Durazno earligo orgánico|O|O||D||1
50314916|Durazno diamante temprano orgánico|O|O||D||1
50314917|Durazno fairlane orgánico|O|O||D||1
50314918|Durazno fantasia orgánico|O|O||D||1
50314919|Durazno perla fuego orgánico|O|O||D||1
50314920|Durazno fuego dulce orgánico|O|O||D||1
50314921|Durazno llamakist orgánico|O|O||D||1
50314922|Durazno tipo plano orgánico|O|O||D||1
50314923|Durazno delicia de jardín orgánico|O|O||D||1
50314924|Durazno mina de oro orgánico|O|O||D||1
50314925|Durazno perla grande orgánico|O|O||D||1
50314926|Durazno hardirojo orgánico|O|O||D||1
50314927|Durazno miel de fuego orgánico|O|O||D||1
50314928|Durazno julio rojo orgánico|O|O||D||1
50314929|Durazno kay perla orgánico|O|O||D||1
50314930|Durazno key dulce orgánico|O|O||D||1
50314931|Durazno diamante mayo orgánico|O|O||D||1
50314932|Durazno mayfire orgánico|O|O||D||1
50314933|Durazno mayglo orgánico|O|O||D||1
50314934|Durazno mericrest orgánico|O|O||D||1
50314935|Durazno diamante rojo orgánico|O|O||D||1
50314936|Durazno oro rojo orgánico|O|O||D||1
50314937|Durazno jim rojo orgánico|O|O||D||1
50314938|Durazno roy rojo orgánico|O|O||D||1
50314939|Durazno rio rojo orgánico|O|O||D||1
50314940|Durazno diamante de rosa orgánico|O|O||D||1
50314941|Durazno rotal glo orgánico|O|O||D||1
50314942|Durazno diamante ryby orgánico|O|O||D||1
50314943|Durazno ruby dulce orgánico|O|O||D||1
50314944|Durazno joya ruddy orgánico|O|O||D||1
50314945|Durazno septiembre rojo orgánico|O|O||D||1
50314946|Durazno reina de nieve orgánico|O|O||D||1
50314947|Durazno primavera clara orgánico|O|O||D||1
50314948|Durazno primavera roja orgánico|O|O||D||1
50314949|Durazno verano rojiso orgánico|O|O||D||1
50314950|Durazno verano claro orgánico|O|O||D||1
50314951|Durazno verano diamante orgánico|O|O||D||1
50314952|Durazno verano fuego orgánico|O|O||D||1
50314953|Durazno verano grande orgánico|O|O||D||1
50314954|Durazno sunglo orgánico|O|O||D||1
50314955|Durazno fuego zee orgánico|O|O||D||1
50314956|Durazno zee glo orgánico|O|O||D||1
50314957|Durazno zeegrand orgánico|O|O||D||1
50315000|Naranjas orgánicas|O|O||D||1
50315001|Naranja áfrica agria orgánica|O|O||D||1
50315002|Naranja dulce amber orgánica|O|O||D||1
50315003|Naranja argentina agria orgánica|O|O||D||1
50315004|Naranja bahianinha orgánico|O|O||D||1
50315005|Naranja bergamot orgánica|O|O||D||1
50315006|Naranja berna orgánica|O|O||D||1
50315007|Naranja bigaradier apepu orgánica|O|O||D||1
50315008|Naranja agria dulce daidai orgánica|O|O||D||1
50315009|Naranja mono orgánica|O|O||D||1
50315010|Naranja sangre orgánica|O|O||D||1
50315011|Naranja california navel orgánica|O|O||D||1
50315012|Naranja cara cara orgánica|O|O||D||1
50315013|Naranja chinotto orgánica|O|O||D||1
50315014|Naranja sueño nevel orgánica|O|O||D||1
50315015|Naranja gou tou orgánica|O|O||D||1
50315016|Naranja hamlin orgánica|O|O||D||1
50315017|Naranja jaffa orgánica|O|O||D||1
50315018|Naranja jincheng orgánica|O|O||D||1
50315019|Naranja k-temprano orgánica|O|O||D||1
50315020|Naranja kona orgánica|O|O||D||1
50315021|Naranja navel tarde orgánica orgánica|O|O||D||1
50315022|Naranja valencia tarde orgánica|O|O||D||1
50315023|Naranja limequat orgánica|O|O||D||1
50315024|Naranja mar orgánica|O|O||D||1
50315025|Naranja maledorado orgánica|O|O||D||1
50315026|Naranja moro orgánica|O|O||D||1
50315027|Naranja moro tabaco orgánica|O|O||D||1
50315028|Naranja navel orgánica|O|O||D||1
50315029|Naranja navelina orgánica|O|O||D||1
50315030|Naranja oro blanco orgánica|O|O||D||1
50315031|Naranja osceola orgánica|O|O||D||1
50315032|Naranja parson carmelito orgánica|O|O||D||1
50315033|Naranja pera orgánica|O|O||D||1
50315034|Naranjo pummulo orgánica|O|O||D||1|Naranja pummulo orgánica
50315035|Naranja rhode rojo orgánica|O|O||D||1
50315036|Naranja roble orgánica|O|O||D||1
50315037|Naranja salustianas orgánica|O|O||D||1
50315038|Naranja sanguine orgánica|O|O||D||1
50315039|Naranja sanguinelli orgánica|O|O||D||1
50315040|Naranja cevilla orgánica|O|O||D||1
50315041|Naranja shamouti jaffa orgánica|O|O||D||1
50315042|Naranja tunis orgánica|O|O||D||1
50315043|Naranja valencia orgánica|O|O||D||1
50315044|Naranja washington navel orgánica|O|O||D||1
50315100|Papayas orgánicas|O|O||D||1
50315101|Papaya verde cocinar orgánica|O|O||D||1
50315102|Papaya maradol orgánica|O|O||D||1
50315103|Papaya amarillo mexicano orgánica|O|O||D||1
50315104|Papaya montaña orgánica|O|O||D||1
50315105|Papaya solo orgánica|O|O||D||1
50315106|Papaya tainung orgánica|O|O||D||1
50315200|Maracuyás orgánicas|O|O||D||1
50315201|Fruta maracuyá banana orgánica|O|O||D||1|Curuba orgánica
50315202|Maracuyá flor azul orgánica|O|O||D||1|Maracuyá pasionaria azul orgánica
50315203|Maracuyá crackerjack orgánica|O|O||D||1
50315204|Maracuyá granadilla gigante orgánica|O|O||D||1
50315205|Maracuyá granadilla dorada orgánica|O|O||D||1
50315206|Maracuyá maypops orgánica|O|O||D||1
50315207|Maracuyá roja orgánica|O|O||D||1
50315208|Maracuyá granadilla dulce orgánica|O|O||D||1
50315209|Maracuyá sandia orgánica|O|O||D||1
50315210|Maracuyá  wing- steam orgánica|O|O||D||1
50315300|Duraznos orgánicos|O|O||D||1
50315301|Durazno escudo amber orgánico|O|O||D||1
50315302|Durazno nieve de abril orgánico|O|O||D||1
50315303|Durazno dama de agosto orgánico|O|O||D||1
50315304|Durazno llama de otoño orgánico|O|O||D||1
50315305|Durazno dama de otoño orgánico|O|O||D||1
50315306|Durazno babcock orgánico|O|O||D||1
50315307|Durazno brittany lane orgánico|O|O||D||1
50315308|Durazno cary mac orgánico|O|O||D||1
50315309|Durazno clásica orgánico|O|O||D||1
50315310|Durazno dulce del campo orgánico|O|O||D||1
50315311|Durazno escudo de cielo orgánico|O|O||D||1
50315312|Durazno dama crimson orgánico|O|O||D||1
50315313|Durazno príncipe corona orgánico|O|O||D||1
50315314|Durazno sol david orgánico|O|O||D||1
50315315|Durazno  princesa diamante orgánico|O|O||D||1
50315316|Durazno earlrich orgánico|O|O||D||1
50315317|Durazno majestuosa temprana orgánico|O|O||D||1
50315318|Durazno early treat orgánico|O|O||D||1
50315319|Durazno dama elegante orgánico|O|O||D||1
50315320|Durazno emperatriz orgánico|O|O||D||1
50315321|Durazno encoré orgánico|O|O||D||1
50315322|Durazno dama elegante orgánico|O|O||D||1
50315323|Durazno príncipe de fuego orgánico|O|O||D||1
50315324|Durazno escudo de llama orgánico|O|O||D||1
50315325|Durazno tipo plano orgánico|O|O||D||1
50315326|Durazno escudo de sabor orgánico|O|O||D||1
50315327|Durazno príncipe florida orgánico|O|O||D||1
50315328|Durazno luna llena orgánico|O|O||D||1
50315329|Durazno harvester orgánico|O|O||D||1
50315330|Durazno princesa de hielo orgánico|O|O||D||1
50315331|Durazno princesa de marfil orgánico|O|O||D||1
50315332|Durazno princesa reina jersey orgánico|O|O||D||1
50315333|Durazno john henry orgánico|O|O||D||1
50315334|Durazno príncipe de junio orgánico|O|O||D||1
50315335|Durazno kaweah orgánico|O|O||D||1
50315336|Durazno klondike orgánico|O|O||D||1
50315337|Durazno lindo orgánico|O|O||D||1
50315338|Durazno loring orgánico|O|O||D||1
50315339|Durazno majestuoso orgánico|O|O||D||1
50315340|Durazno o’henry orgánico|O|O||D||1
50315341|Durazno escudo de reina orgánico|O|O||D||1
50315342|Durazno dama roja orgánico|O|O||D||1
50315343|Durazno globo rojo orgánico|O|O||D||1
50315344|Durazno cielo rojo orgánico|O|O||D||1
50315345|Durazno retop orgánico|O|O||D||1
50315346|Durazno regina orgánico|O|O||D||1
50315347|Durazno dama rica orgánico|O|O||D||1
50315348|Durazno mayo rico vo|O|O||D||1
50315349|Durazno gloria royal orgánico|O|O||D||1
50315350|Durazno dama royal orgánico|O|O||D||1
50315351|Durazno nieve de septiembre orgánico|O|O||D||1
50315352|Durazno sol de septiembre orgánico|O|O||D||1
50315353|Durazno gema sierra orgánico|O|O||D||1
50315354|Durazno angel de nieve orgánico|O|O||D||1
50315355|Durazno gema de nieve orgánico|O|O||D||1
50315356|Durazno rey de nieve orgánico|O|O||D||1
50315357|Durazno dama de primavera orgánico|O|O||D||1
50315358|Durazno nieve de primavera orgánico|O|O||D||1
50315359|Durazno escudo de primavera orgánico|O|O||D||1
50315360|Durazno dulce gigante orgánico|O|O||D||1
50315361|Durazno dama de azúcar orgánico|O|O||D||1
50315362|Durazno brillo de sol orgánico|O|O||D||1
50315363|Durazno sunhigh orgánico|O|O||D||1
50315364|Durazno dama super orgánico|O|O||D||1
50315365|Durazno super rico orgánico|O|O||D||1
50315366|Durazno surecrop orgánico|O|O||D||1
50315367|Durazno sueño dulce orgánico|O|O||D||1
50315368|Durazno septiembre dulce orgánico|O|O||D||1
50315369|Durazno vista orgánico|O|O||D||1
50315370|Durazno dama blanca orgánico|O|O||D||1
50315371|Durazno dama zee orgánico|O|O||D||1
50315400|Peras orgánicas|O|O||D||1
50315401|Peras abate fetel orgánica|O|O||D||1
50315402|Peras anjou orgánica|O|O||D||1
50315403|Pera asiática orgánica|O|O||D||1
50315404|Pera bartlett orgánica|O|O||D||1
50315405|Pera best ever orgánica|O|O||D||1
50315406|Pera beth orgánica|O|O||D||1
50315407|Pera beurre orgánica|O|O||D||1
50315408|Pera bosc orgánica|O|O||D||1
50315409|Pera clapp favorita orgánica|O|O||D||1
50315410|Pera comice orgánica|O|O||D||1
50315411|Pera concorde orgánica|O|O||D||1
50315412|Pera conference orgánica|O|O||D||1
50315413|Pera crimson rojo orgánica|O|O||D||1
50315414|Peras d’ anjou orgánica|O|O||D||1
50315415|Pera dr jules guyot orgánica|O|O||D||1
50315416|Peras early orgánica|O|O||D||1
50315417|Peras emperador carmelito orgánica|O|O||D||1
50315418|Peras forelle orgánica|O|O||D||1
50315419|Pera mantequilla francesa orgánica|O|O||D||1
50315420|Pera glou morceau orgánica|O|O||D||1
50315421|Pera hosui orgánica|O|O||D||1
50315422|Pera mantequilla italiana orgánica|O|O||D||1
50315423|Pera jargonelle orgánica|O|O||D||1
50315424|Pera juno orgánica|O|O||D||1
50315425|Para kaiserlouise bonne de jersey orgánica|O|O||D||1
50315426|Pera keiffer orgánica|O|O||D||1
50315427|Pera rey royal orgánica|O|O||D||1
50315428|Pera limonera orgánica|O|O||D||1
50315429|Pera merton pride orgánica|O|O||D||1
50315430|Pera mauntain bartlette orgánica|O|O||D||1
50315431|Pera oliver de serrers orgánica|O|O||D||1
50315432|Pera onward orgánica|O|O||D||1
50315433|Pera packham´s triumph orgánica|O|O||D||1
50315434|Pera paraíso orgánica|O|O||D||1
50315435|Pera passe crassane orgánica|O|O||D||1
50315436|Pera perry orgánica|O|O||D||1
50315437|Pera bartlette rojo orgánica|O|O||D||1
50315438|Pera dánjou  rojo orgánica|O|O||D||1
50315439|Pera rocha orgánica|O|O||D||1
50315440|Pera rosey rojo orgánica|O|O||D||1
50315441|Pera rosy roja orgánica|O|O||D||1
50315442|Pera majestuosa royal orgánica|O|O||D||1
50315443|Pera ruby rojo orgánica|O|O||D||1
50315444|Pera santa maria orgánica|O|O||D||1
50315445|Pera seckel orgánica|O|O||D||1
50315446|Pera sensación orgánica|O|O||D||1
50315447|Pera crimson estrella orgánica|O|O||D||1
50315448|Pera crimson stark orgánica|O|O||D||1
50315449|Pera bartlette de verano orgánica|O|O||D||1
50315450|Pera verano dorado orgánica|O|O||D||1
50315451|Pera sol dorado orgánica|O|O||D||1
50315452|Pera sunprite orgánica|O|O||D||1
50315453|Pera taylors dorado orgánica|O|O||D||1
50315454|Pera taylors rojo orgánica|O|O||D||1
50315455|Pera tientsin orgánica|O|O||D||1
50315456|Pera tosca orgánica|O|O||D||1
50315457|Pera warden  orgánica|O|O||D||1
50315458|Pera williams bon chretien orgánica|O|O||D||1
50315459|Pera williams orgánica|O|O||D||1
50315460|Pera nelis de invierno orgánica|O|O||D||1
50315500|Caquis orgánicos|O|O||D||1
50315501|Caqui americano orgánica|O|O||D||1
50315502|Caqui sapote negro orgánica|O|O||D||1|Caqui zapote negro orgánico
50315503|Caqui chapote / negro orgánica|O|O||D||1
50315504|Caqui dátale ciruela orgánica|O|O||D||1
50315505|Caqui fuyu orgánica|O|O||D||1
50315506|Caqui gigante fuyu orgánica|O|O||D||1
50315507|Caqui hachiya orgánica|O|O||D||1
50315508|Caqui mantequilla / mabolo orgánica|O|O||D||1
50315509|Caqui príncipe ito orgánica|O|O||D||1
50315510|Caqui brillante royal orgánica|O|O||D||1
50315511|Caqui sharon orgánica|O|O||D||1
50315512|Caqui triumph orgánica|O|O||D||1
50315600|Piñas orgánicas|O|O||D||1
50315601|Piña chirimoya orgánica|O|O||D||1|Atemoya orgánica
50315602|Piña dorada orgánica|O|O||D||1
50315603|Piña hilo orgánica|O|O||D||1
50315604|Piña kona sugarloaf orgánica|O|O||D||1
50315605|Piña reina natal orgánica|O|O||D||1
50315606|Piña pernambuco orgánica|O|O||D||1
50315607|Piña español rojo orgánica|O|O||D||1
50315608|Piña cayen suave orgánica|O|O||D||1
50315609|Piña sugarloaf orgánica|O|O||D||1
50315610|Piña variegated orgánica|O|O||D||1
50315700|Ciruelos Damascos orgánicos|O|O||D||1
50315701|Ciruelo / damasco negro kat orgánico|O|O||D||1
50315702|Ciruelo / damasco gusto azul orgánio|O|O||D||1
50315703|Ciruelo / damasco corazón de crimson orgánico|O|O||D||1
50315704|Ciruelo / damasco dapply dandy orgánico|O|O||D||1
50315705|Ciruelo / damasco dapple fuego orgánico|O|O||D||1
50315706|Ciruelo / damasco  dapple temprano orgánico|O|O||D||1
50315707|Ciruelo / damasco  caída de sabor orgánico|O|O||D||1
50315708|Ciruelo / damasco sabor de oro orgánico|O|O||D||1
50315709|Ciruelo / damasco sabor granada orgánico|O|O||D||1
50315710|Ciruelo / damasco sabor de corazón orgánico|O|O||D||1
50315711|Ciruelo / damasco joya de sabor orgánico|O|O||D||1
50315712|Ciruelo / damasco sabor de rey orgánico|O|O||D||1
50315713|Ciruelo / damasco sabor de reina orgánico|O|O||D||1
50315714|Ciruelo / damasco sabor supremo orgánico|O|O||D||1
50315715|Ciruelo / damasco sabor premio orgánico|O|O||D||1
50315716|Ciruelo / damasco saborella orgánico|O|O||D||1
50315717|Ciruelo / damasco saborrico orgánico|O|O||D||1
50315718|Ciruelo / damasco  sabor rosa orgánico|O|O||D||1
50315719|Ciruelo / damasco orgullo geo orgánico|O|O||D||1
50315720|Ciruelo / damasco kat rojo orgánico|O|O||D||1
50315721|Ciruelo / damasco premio royal orgánico|O|O||D||1
50315722|Ciruelo / damasco rosa sierra orgánico|O|O||D||1
50315723|Ciruelo / damasco geisha dulce orgánico|O|O||D||1
50315800|Ciruelas orgánicas|O|O||D||1
50315801|Ciruela joya amber orgánica|O|O||D||1
50315802|Ciruela angeleno orgánica|O|O||D||1
50315803|Ciruela aurora orgánica|O|O||D||1
50315804|Ciruela otoño bonito orgánica|O|O||D||1
50315805|Ciruela gigante de otoño orgánica|O|O||D||1
50315806|Ciruela orgullo de otoño orgánica|O|O||D||1
50315807|Ciruela rosa de otoño orgánica|O|O||D||1
50315808|Ciruela playero orgánica|O|O||D||1
50315809|Ciruela betty anne orgánica|O|O||D||1
50315810|Ciruela belleza negra orgánica|O|O||D||1
50315811|Ciruela bullase negra orgánica|O|O||D||1
50315812|Ciruela diamante negro orgánica|O|O||D||1
50315813|Ciruela gigante negro orgánica|O|O||D||1
50315814|Ciruela hielo negro orgánica|O|O||D||1
50315815|Ciruela esplendor negro orgánica|O|O||D||1
50315816|Ciruela ámbar negro orgánica|O|O||D||1
50315817|Ciruela purpura orgánica|O|O||D||1
50315818|Ciruela  carsbad orgánica|O|O||D||1
50315819|Ciruela casselman orgánica|O|O||D||1
50315820|Ciruela catalina orgánica|O|O||D||1
50315821|Ciruela damson orgánica|O|O||D||1
50315822|Ciruela dolly orgánica|O|O||D||1
50315823|Ciruela earliqueen orgánica|O|O||D||1
50315824|Ciruela rosa early orgánica|O|O||D||1
50315825|Ciruela ébano mayo orgánica|O|O||D||1
50315826|Ciruela ébano orgánica|O|O||D||1
50315827|Ciruela corazón de elefante orgánica|O|O||D||1
50315828|Ciruela belleza de esmeralda orgánica|O|O||D||1
50315829|Ciruela emperatriz orgánica|O|O||D||1
50315830|Ciruela libertad orgánica|O|O||D||1
50315831|Ciruela friar orgánica|O|O||D||1
50315832|Ciruela rojo gar orgánica|O|O||D||1
50315833|Ciruela gobernador orgánica|O|O||D||1
50315834|Ciruela rosa grande orgánica|O|O||D||1
50315835|Ciruela green gage orgánica|O|O||D||1|Ciruela calibre verde orgánica
50315836|Ciruela greengage orgánica|O|O||D||1
50315837|Ciruela hiromi orgánica|O|O||D||1
50315838|Ciruela hiromi rojo orgánica|O|O||D||1
50315839|Ciruela vacacion orgánica|O|O||D||1
50315840|Ciruela howard sol orgánica|O|O||D||1
50315841|Ciruela tipo interspecific orgánica|O|O||D||1
50315842|Ciruela jamaico orgánica|O|O||D||1
50315843|Ciruela joanna rojo orgánica|O|O||D||1
50315844|Ciruela kelsey orgánica|O|O||D||1
50315845|Ciruela jaime rey orgánica|O|O||D||1
50315846|Ciruela laroda orgánica|O|O||D||1
50315847|Ciruela rosa tarde orgánica|O|O||D||1
50315848|Ciruela rosa linda orgánica|O|O||D||1
50315849|Ciruela estrella solitaria orgánica|O|O||D||1
50315850|Ciruela mariposa orgánica|O|O||D||1
50315851|Ciruela mercado negro orgánica|O|O||D||1
50315852|Ciruela mercado rojo orgánica|O|O||D||1
50315853|Ciruela maribel orgánica|O|O||D||1
50315854|Ciruelas sol de octubre orgánica|O|O||D||1
50315855|Ciruela owen t orgánica|O|O||D||1
50315856|Ciruela perdrigon orgánica|O|O||D||1
50315857|Ciruela placer rosado orgánica|O|O||D||1
50315858|Ciruela  presidente orgánica|O|O||D||1
50315859|Ciruela hora prima orgánica|O|O||D||1|Ciruela prime time orgánica
50315860|Ciruela majestad purpura orgánica|O|O||D||1
50315861|Ciruela reina rosa orgánica|O|O||D||1
50315862|Ciruela quetsch orgánica|O|O||D||1
50315863|Ciruela belleza roja orgánica|O|O||D||1
50315864|Ciruela camino rojo orgánica|O|O||D||1
50315865|Ciruela ram rojo orgánica|O|O||D||1
50315866|Ciruela rosa roja orgánica|O|O||D||1
50315867|Ciruela rojo rico orgánica|O|O||D||1
50315868|Ciruela romero orgánica|O|O||D||1
50315869|Ciruela diamante rojo orgánica|O|O||D||1
50315870|Ciruela rojo royal orgánica|O|O||D||1
50315871|Ciruela royal zee orgánica|O|O||D||1
50315872|Ciruela roysum orgánica|O|O||D||1
50315873|Ciruela santa rosa orgánica|O|O||D||1
50315874|Ciruela zafiro orgánica|O|O||D||1
50315875|Ciruela sloe orgánica|O|O||D||1
50315876|Ciruela st catherine orgánica|O|O||D||1
50315877|Ciruela bullase blanca orgánica|O|O||D||1
50315900|Granadas orgánicas|O|O||D||1
50315901|Granada foothhill orgánica|O|O||D||1
50315902|Granada granada orgánica|O|O||D||1|Granada orgánica
50315903|Granada rojo feliz orgánica|O|O||D||1
50315904|Granada nana orgánica|O|O||D||1
50315905|Granada rojo de pat orgánica|O|O||D||1
50315906|Granada pinkhan orgánic|O|O||D||1
50315907|Granada terciopelo morado orgánica|O|O||D||1
50315908|Granada grandioso orgánica|O|O||D||1
50316000|Pomelos orgánicos|O|O||D||1
50316001|Pomelo chandler orgánico|O|O||D||1
50316002|Pomelo hirado butan orgánico|O|O||D||1
50316003|Pomelo liang ping yau orgánico|O|O||D||1
50316004|Pomelo panda wangi orgánico|O|O||D||1
50316005|Pomelo rosado orgánico|O|O||D||1
50316006|Pomelo shaddock rojo orgánico|O|O||D||1
50316007|Pomelo siamese dulce orgánico|O|O||D||1
50316008|Pomelo waingwright orgánico|O|O||D||1
50316100|Membrillos orgánicos|O|O||D||1
50316101|Membrillo campeón orgánico|O|O||D||1
50316102|Membrillo piña orgánico|O|O||D||1
50316103|Membrillo smyma orgánico|O|O||D||1
50316200|Frambuesas orgánicas|O|O||D||1
50316201|Frambuesa americana roja orgánica|O|O||D||1
50316202|Frambuesa bailey queensland orgánica|O|O||D||1
50316203|Frambuesa negra orgánica|O|O||D||1
50316204|Frambuesa oscura orgánica|O|O||D||1
50316205|Frambuesa deliciosa orgánica|O|O||D||1
50316206|Frambuesa enano focke orgánica|O|O||D||1
50316207|Frambuesa focke hojagris orgánica|O|O||D||1
50316208|Frambuesa focke fresa orgánica|O|O||D||1
50316209|Frambuesa  focke amarillo himalaya orgánica|O|O||D||1
50316210|Frambuesa dorado orgánic|O|O||D||1
50316211|Frambuesa gris nuevo mexico orgánica|O|O||D||1
50316212|Frambuesa jepson blancobark orgánica|O|O||D||1
50316213|Frambuesa kellogs san diego orgánica|O|O||D||1
50316214|Frambuesa leucodemis blancobark orgánica|O|O||D||1
50316215|Frambuesa munz cuyamaca orgánica|O|O||D||1
50316216|Frambuesa peck bartons orgánica|O|O||D||1
50316217|Frambuesa flor morada orgánica|O|O||D||1
50316218|Frambuesa roadside orgánica|O|O||D||1
50316219|Frambuesa san diego orgánica|O|O||D||1
50316220|Frambuesa nieve orgánica|O|O||D||1
50316221|Frambuesa pico de nieve orgánica|O|O||D||1
50316222|Frambuesa hoja de fresa orgánica|O|O||D||1
50316223|Frambuesa cultivo dulce orgánica|O|O||D||1
50316224|Frambuesa tor y gris blancobark orgánica|O|O||D||1
50316225|Frambuesa caribe orgánica|O|O||D||1
50316226|Frambuesa blancobark orgánica|O|O||D||1
50316227|Frambuesa vino orgánica|O|O||D||1
50316228|Frambuesa himalaya amarillo orgánica|O|O||D||1
50316229|Frambuesa yu-shan orgánica|O|O||D||1
50316300|Ruibarbos orgánicos|O|O||D||1|Acelgas rojas orgánicas
50316301|Ruibarbo crimson rojo orgánico|O|O||D||1|Acelga roja crimson orgánica
50316302|Ruibarbo champagne temprana orgánico|O|O||D||1|Acelga roja champagne temprana orgánica
50316303|Ruibarbo glasrey perpetual  orgánico|O|O||D||1|Acelga roja glasrey perpetual orgánica
50316304|Ruibarbo sutton orgánico|O|O||D||1|Acelga roja sutton orgánica
50316305|Ruibarbo timperley temprano orgánico|O|O||D||1|Acelga roja temprana de Timperley orgánica
50316306|Ruibarbo valentina orgánico|O|O||D||1|Acelga roja valentina orgánica
50316307|Ruibarbo victoria orgánico|O|O||D||1|Acelga roja victoria orgánica
50316308|Ruibarbo zwolle de cemilla orgánico|O|O||D||1|Acelga roja zwolle de semilla orgánica
50316309|Ruibarbo macdonald orgánico|O|O||D||1|Acelga roja macdonald orgánica
50316310|Ruibarbo tilden orgánico|O|O||D||1|Acelga roja tilden orgánica
50316400|Escaramujos orgánicos|O|O||D||1|Rosa mosqueta orgánicas
50316401|Escaramujo rosa brier orgánico|O|O||D||1|Rosa mosqueta brier orgánica
50316402|Escaramujo rosa elegante orgánico|O|O||D||1|Rosa mosqueta elegante orgánica
50316403|Escaramujo rosa rugosa orgánico|O|O||D||1|Rosa mosqueta rugosa orgánica
50316404|Escaramujo rosa burnet o scotch orgánico|O|O||D||1|Rosa mosqueta burnet o scotch orgánica
50316500|Sapotes orgánicos|O|O||D||1|Zapotes orgánicos
50316501|Zapote blanco orgánico|O|O||D||1|Zapote blanco orgánico
50316502|Zapote negro orgánico|O|O||D||1|Zapote negro orgánico
50316600|Bayas saskatoon orgánicas|O|O||D||1|Fresas de junio orgánicas
50316601|Baya mielmadera saskatoon orgánica|O|O||D||1|Fresa de junio mielmadera orgánica
50316602|Baya northline saskatoon orgánica|O|O||D||1|Fresa de junio northline orgánica
50316603|Baya saskatoon ahumado orgánica|O|O||D||1|Fresa de junio smoky orgánica
50316604|Baya saskatoon thiessen orgánica|O|O||D||1|Fresa de junio thiessen orgánica
50316700|Fresas orgánicas|O|O||D||1
50316701|Fresa chandler orgánica|O|O||D||1
50316702|Fresa rumbo junio orgánica|O|O||D||1|Fresa temporada de junio orgánica
50316703|Fresa rumbo siempre orgánica|O|O||D||1|Fresa de todo el año orgánica
50316800|Manzanas dulces orgánicas|O|O||D||1|Saramuyos orgánicos
50316801|Manzana kampong malve dulce orgánica|O|O||D||1|Saramuyo kampong mauve orgánico
50316802|Manzana dulce sin pepa orgánica|O|O||D||1|Saramuyo sin semilla orgánico
50316803|Manzana dulce thai lessand orgánica|O|O||D||1|Saramuyo thai lessand orgánico
50316900|Tamarillos orgánicos|O|O||D||1|Tomates de árbol orgánicos
50316901|Tamarindo amberlea dorado orgánico|O|O||D||1|Tomate de árbol amberlea dorado orgánico
50316902|Tamarindo calvo dorado orgánico|O|O||D||1|Tomate de árbol calvo dorado orgánico
50316903|Tamarindo mina de oro orgánico|O|O||D||1|Tomate de árbol mina de oro orgánico
50316904|Tamarindo oratia rojo orgánico|O|O||D||1|Tomate de árbol oratia rojo orgánico
50316905|Tamarindo beau rojo orgánico|O|O||D||1|Tomate de árbol beau rojo orgánico
50316906|Tamarindo delicia roja orgánico|O|O||D||1|Tomate de árbol delicia roja orgánico
50317000|Frutas Nominant orgánicas|O|O||D||1|Frutas predominantes orgánicas, Tejocote, Xoconostl
50317001|Cupania orgánica|O|O||D||1|Ackee orgánica
50317002|Babaco orgánico|O|O||D||1|Carica pentágona orgánica
50317003|Banana flor orgánica|O|O||D||1|Flor de plátano orgánica
50317004|Baobab orgánica|O|O||D||1
50317005|Naranja agria orgánica|O|O||D||1
50317006|Canistel orgánica|O|O||D||1|Zapote amarillo orgánico
50317007|Baya nublosa orgánica|O|O||D||1|Mora de los pantanos orgánica
50317008|Coco orgánico|O|O||D||1
50317009|Baya drew orgánica|O|O||D||1|Baya de gota orgánica
50317010|Durian orgánica|O|O||D||1|Durio orgánico
50317011|Baya elder orgánica|O|O||D||1|Baya de sauco orgánica
50317012|Feijoa orgánica|O|O||D||1|Guayabo del Brasil orgánico
50317013|Mora orgánica|O|O||D||1
50317014|Cretaegus orgánica|O|O||D||1|Majuelo orgánico
50317015|Baya miel orgánica|O|O||D||1|Madreselva azul orgánica
50317016|Jaca orgánica|O|O||D||1|Yaca orgánica
50317017|Jambolan orgánica|O|O||D||1
50317018|Jujube orgánica|O|O||D||1|Azufaifa orgánica
50317019|Liches orgánicos|O|O||D||1|Lichi orgánico
50317020|Mangostinos orgánicos|O|O||D||1|Mangostán orgánico
50317021|Nísperos orgánicos|O|O||D||1|Medlar orgánico
50317022|Mombines orgánica|O|O||D||1|Hobo orgánico
50317023|Monstera orgánica|O|O||D||1|Cerimán orgánico
50317024|Pepinos orgánico|O|O||D||1|Pepino dulce orgánico
50317025|Platono orgánico|O|O||D||1|Plátano macho orgánico
50317026|Peras en escabeche orgánica|O|O||D||1|Tuna orgánica
50317027|Mamonsillo orgánico|O|O||D||1|Guaya orgánica
50317028|Rambután orgánico|O|O||D||1|Achotillo orgánico
50317029|Manzana rosa orgánica|O|O||D||1|Pero de agua orgánico
50317030|Rosele orgánica|O|O||D||1|Flor de jamaica orgánica
50317031|Baya rowan orgánica|O|O||D||1|Serba orgánica
50317032|Baya buckhom de mar orgánica|O|O||D||1|Espino amarillo orgánico
50317033|Baya plata orgánica|O|O||D||1|Olivo de otoño orgánico
50317034|Baya sorbete orgánico|O|O||D||1|Serba orgánica
50317035|Guanabana orgánica|O|O||D||1
50317036|Manzana estrella orgánica|O|O||D||1|Cainito orgánico
50317037|Tamarindo orgánico|O|O||D||1
50317100|Aronias orgánicas|O|O||D||1
50317101|Aronia magia de otoño orgánica|O|O||D||1
50317102|Aronia brillantísima orgánica|O|O||D||1
50317103|Aronia nero orgánica|O|O||D||1
50317104|Aronia vikingo orgánica|O|O||D||1
50317200|Aceitunas orgánicas|O|O||D||1
50317201|Aceitunas agrinion orgánica|O|O||D||1|Aceituna agrinion orgánica
50317202|Aceitunas aleppo orgánica|O|O||D||1|Aceituna aleppo orgánica
50317203|Aceitunas  alfonso orgánica|O|O||D||1|Aceituna alfonso orgánica
50317204|Aceitunas  amfisa orgánica|O|O||D||1|Aceituna amfisa orgánica
50317205|Aceitunas  arauco orgánica|O|O||D||1|Aceituna arauco orgánica
50317206|Aceitunas  arbequina orgánica|O|O||D||1|Aceituna arbequina orgánica
50317207|Aceitunas  atlanta orgánica|O|O||D||1|Aceituna atlanta orgánica
50317208|Aceitunas  cerignola orgánica|O|O||D||1|Aceituna cerignola orgánica
50317209|Aceitunas  cracked provencal orgánica|O|O||D||1|Aceituna cracked provencal orgánica
50317210|Aceitunas  empeltre orgánica|O|O||D||1|Aceituna empeltre orgánica
50317211|Aceitunas gaeta  orgánica|O|O||D||1|Aceituna gaeta orgánica
50317212|Aceitunas hondoelia orgánica|O|O||D||1|Aceituna hondoelia orgánica
50317213|Aceitunas kalamata orgánica|O|O||D||1|Aceituna kalamata orgánica
50317214|Aceitunas kura orgánica|O|O||D||1|Aceituna kura orgánica
50317215|Aceitunas ligurian orgánica|O|O||D||1|Aceituna ligurian orgánica
50317216|Aceitunas lucque orgánica|O|O||D||1|Aceituna lucque orgánica
50317217|Aceitunas lugano orgánica|O|O||D||1|Aceituna lugano orgánica
50317218|Aceitunas manzanilla orgánica|O|O||D||1|Aceituna manzanilla orgánica
50317219|Aceitunas marche orgánica|O|O||D||1|Aceituna marche orgánica
50317220|Aceitunas misión orgánica|O|O||D||1|Aceituna misión orgánica
50317221|Aceitunas nafplion verde orgánica|O|O||D||1|Aceituna nafplion verde orgánica
50317222|Aceitunas nicoise orgánica|O|O||D||1|Aceituna nicoise orgánica
50317223|Aceitunas nyons orgánica|O|O||D||1|Aceituna nyons orgánica
50317224|Aceitunas picholine orgánica|O|O||D||1|Aceituna picholine orgánica
50317225|Aceitunas ponentine orgánica|O|O||D||1|Aceituna ponentine orgánica
50317226|Aceitunas real orgánica|O|O||D||1|Aceituna real orgánica
50317227|Aceitunas seracena orgánica|O|O||D||1|Aceituna seracena orgánica
50317228|Aceitunas sevillano orgánica|O|O||D||1|Aceituna sevillano orgánica
50317229|Aceitunas sicilian orgánica|O|O||D||1|Aceituna sicilian orgánica
50317230|Aceitunas toscanella orgánica|O|O||D||1|Aceituna toscanella orgánica
50321500|Manzanas secas|O|O||D||1
50321501|Manzanas akane secas|O|O||D||1|Manzana akane secas
50321502|Manzana ambrosia seca|O|O||D||1
50321503|Manzanas api secas|O|O||D||1|Manzana api secas
50321504|Manzanas baldwin secas|O|O||D||1|Manzana baldwin secas
50321505|Manzanas brabum secas|O|O||D||1|Manzana brabum secas
50321506|Manzanas bramley secas|O|O||D||1|Manzana bramley secas
50321507|Manzana joven bramley sec|O|O||D||1
50321508|Manzana calville blanche d’hiver sec|O|O||D||1
50321509|Manzana cameo seca|O|O||D||1
50321510|Manzana charles ross seca|O|O||D||1
50321511|Manzana codlin seca|O|O||D||1
50321512|Manzana cortland seca|O|O||D||1
50321513|Manzana costard seca|O|O||D||1
50321514|Manzana court pendu plat seca|O|O||D||1
50321515|Manzana  cox´s orange pippin seca|O|O||D||1
50321516|Manzana crab seca|O|O||D||1
50321517|Manzana crispin seca|O|O||D||1
50321518|Manzana delisioso seca|O|O||D||1
50321519|Manzana duchess seca|O|O||D||1
50321520|Manzana earlidorado seca|O|O||D||1
50321521|Manzana early mcintosh seca|O|O||D||1
50321522|Manzana elstar seca|O|O||D||1
50321523|Manzana empire seca|O|O||D||1
50321524|Manzana flor de seca|O|O||D||1
50321525|Manzana fiji seca|O|O||D||1
50321526|Manzana gala seca|O|O||D||1
50321527|Manzana gascoyne´s scarlet seca|O|O||D||1
50321528|Manzana gillyflower seca|O|O||D||1
50321529|Manzana ginger dorado seca|O|O||D||1
50321530|Manzana gladstone seca|O|O||D||1
50321531|Manzana gloster seca|O|O||D||1
50321532|Manzana dorado supreme seca|O|O||D||1
50321533|Manzana doradoen delisioso seca|O|O||D||1
50321534|Manzana doradoen nobel seca|O|O||D||1
50321535|Manzana granny smith seca|O|O||D||1
50321536|Manzana gravenstain seca|O|O||D||1
50321537|Manzana verdeing seca|O|O||D||1
50321538|Manzana verdesleeves seca|O|O||D||1
50321539|Manzana honeycrisp seca|O|O||D||1
50321540|Manzana howgate wonder seca|O|O||D||1
50321541|Manzana roja ida seca|O|O||D||1
50321542|Manzana james grives seca|O|O||D||1
50321543|Manzana jersey mac seca|O|O||D||1
50321544|Manzana jaster seca|O|O||D||1
50321545|Manzana jonadorado seca|O|O||D||1
50321546|Manzana jonamac seca|O|O||D||1
50321547|Manzana  jonathan  seca|O|O||D||1
50321548|Manzana katy seca|O|O||D||1
50321549|Manzana kidd´s orange roja seca|O|O||D||1
50321550|Manzana lady seca|O|O||D||1
50321551|Manzana law roma seca|O|O||D||1
50321552|Manzana laxton seca|O|O||D||1
50321553|Manzana lord derby seca|O|O||D||1
50321554|Manzana macoun  seca|O|O||D||1
50321555|Manzana mcintosh seca|O|O||D||1
50321556|Manzana mutsu seca|O|O||D||1
50321557|Manzana newtown pippin seca|O|O||D||1
50321558|Manzana northen spy seca seca|O|O||D||1
50321559|Manzana orleans reinette seca|O|O||D||1
50321560|Manzana ozark dorado seca|O|O||D||1
50321561|Manzana pacific rose seca|O|O||D||1
50321562|Manzana paula roja seca|O|O||D||1
50321563|Manzana peamain seca|O|O||D||1
50321564|Manzana pink lady seca|O|O||D||1
50321565|Manzana pippin seca|O|O||D||1
50321566|Manzana pitmaston pineapple seca|O|O||D||1
50321567|Manzana pomme d'api seca|O|O||D||1
50321568|Manzana prime dorado seca|O|O||D||1
50321569|Manzana roja astrakhan seca|O|O||D||1
50321570|Manzana roja boscoop seca|O|O||D||1
50321571|Manzana roja chief seca|O|O||D||1
50321572|Manzana roja delisioso seca|O|O||D||1
50321573|Manzana roja grvenstain seca|O|O||D||1
50321574|Manzana roja roma seca|O|O||D||1
50321575|Manzana roja stayman seca|O|O||D||1
50321576|Manzana roja york seca|O|O||D||1
50321577|Manzana reinette seca|O|O||D||1
50321578|Manzana roma beuty seca|O|O||D||1
50321579|Manzana russet seca|O|O||D||1
50321580|Manzana sierra beaty seca|O|O||D||1
50321581|Manzana spartan seca|O|O||D||1
50321582|Manzana stark crimson seca|O|O||D||1
50321583|Manzana starrey seca|O|O||D||1
50321584|Manzana stayman seca|O|O||D||1
50321585|Manzana stayman winesap seca|O|O||D||1
50321586|Manzana summer rambo seca|O|O||D||1
50321587|Manzana tsugaru seca|O|O||D||1
50321588|Manzana twenty ounce seca|O|O||D||1
50321589|Manzana tydeman roja seca|O|O||D||1
50321590|Manzana vistabella seca|O|O||D||1
50321591|Manzana weatley seca|O|O||D||1
50321592|Manzana blanco joanetine seca|O|O||D||1
50321593|Manzana blanco transparent seca|O|O||D||1
50321594|Manzana winesap seca|O|O||D||1
50321595|Manzana worcester seca|O|O||D||1
50321596|Manzana york imperial seca|O|O||D||1
50321600|Albaricoques secos|O|O||D||1|Chabacanos secos
50321601|Abaricoques ambercot seca|O|O||D||1|Chabacano ambercot seco
50321602|Albaricoques apache seca|O|O||D||1|Chabacano apache seco
50321603|Albaricoques brittany dorado seca|O|O||D||1|Chabacano brittany dorado seco
50321604|Albaricoque negro seca|O|O||D||1|Chabacano negro seco
50321605|Albaricoque blenheim seca|O|O||D||1|Chabacano blenheim seco
50321606|Albaricoque bonny seca|O|O||D||1|Chabacano bonny seco
50321607|Albaricoque biluda seca|O|O||D||1|Chabacano biluda seco
50321608|Albaricoque castlebrite seca|O|O||D||1|Chabacano castlebrite seco
50321609|Albaricoque  clutha dorado seca|O|O||D||1|Chabacano clutha dorado seco
50321610|Albaricoque clutha sun seca|O|O||D||1|Chabacano clutha sun seco
50321611|Albaricoque derby royal seca|O|O||D||1|Chabacano derby royal seco
50321612|Albaricoque dina seca|O|O||D||1|Chabacano dina seco
50321613|Albaricoque earlicot seca|O|O||D||1|Chabacano earlicot seco
50321614|Albaricoque earliman seca|O|O||D||1|Chabacano earliman seco
50321615|Albaricoque early bright seca|O|O||D||1|Chabacano early bright seco
50321616|Albaricoque  flaming dorado seca|O|O||D||1|Chabacano flaming dorado seco
50321617|Albaricoque frenso seca|O|O||D||1|Chabacano frenso seco
50321618|Albaricoque dorado bright seca|O|O||D||1|Chabacano dorado bright seco
50321619|Albaricoque dorado barra seca|O|O||D||1|Chabacano dorado barra seco
50321620|Albaricoque dorado en dulce seca|O|O||D||1|Chabacano dorado en dulce seco
50321621|Albaricoque dorado rico seca|O|O||D||1|Chabacano dorado rico seco
50321622|Albaricoque helena seca|O|O||D||1|Chabacano helena seco
50321623|Albaricoque honeycot seca|O|O||D||1|Chabacano  seco
50321624|Albaricoque imperial seca|O|O||D||1|Chabacano imperial seco
50321625|Albaricoque jordanne seca|O|O||D||1|Chabacano jordanne seco
50321626|Albaricoque jumbo cot seca|O|O||D||1|Chabacano jumbo cot seco
50321627|Albaricoque kandy kot seca|O|O||D||1|Chabacano kandy kot seco
50321628|Albaricoque katy seca|O|O||D||1|Chabacano katy seco
50321629|Albaricoque rey seca|O|O||D||1|Chabacano rey seco
50321630|Albaricoque lambertin seca|O|O||D||1|Chabacano lambertin seco
50321631|Albaricoque loma seca|O|O||D||1|Chabacano loma seco
50321632|Albaricoque lulu belle seca|O|O||D||1|Chabacano lulu belle seco
50321633|Albaricoque modesto seca|O|O||D||1|Chabacano modesto seco
50321634|Albaricoque moorpark seca|O|O||D||1|Chabacano moorpark seco
50321635|Albaricoque orangeroja seca|O|O||D||1|Chabacano orange red seco
50321636|Albaricoque palstein seca|O|O||D||1|Chabacano palstein seco
50321637|Albaricoque patterson seca|O|O||D||1|Chabacano patterson seco
50321638|Albaricoque perfection seca|O|O||D||1|Chabacano perfection seco
50321639|Albaricoque poppy seca|O|O||D||1|Chabacano poppy seco
50321640|Albaricoque poppycot seca|O|O||D||1|Chabacano poppy cot seco
50321641|Albaricoque reina seca|O|O||D||1|Chabacano reina seco
50321642|Albaricoque riland seca|O|O||D||1|Chabacano riland seco
50321643|Albaricoque rival seca|O|O||D||1|Chabacano rival seco
50321644|Albaricoque robada seca|O|O||D||1|Chabacano robada seco
50321645|Albaricoque royal seca|O|O||D||1|Chabacano royal seco
50321646|Albaricoque  royal blenheim seca|O|O||D||1|Chabacano royal blenheim seco
50321647|Albaricoque  royal orange seca|O|O||D||1|Chabacano royal orange seco
50321648|Albaricoque dota de sol seca|O|O||D||1|Chabacano dota de sol seco
50321649|Albaricoque tilton seca|O|O||D||1|Chabacano tilton seco
50321650|Albaricoque tomcot seca|O|O||D||1|Chabacano tomcot seco
50321651|Albaricoque tracy seca|O|O||D||1|Chabacano tracy seco
50321652|Albaricoque tri gem seca|O|O||D||1|Chabacano tri gem seco
50321653|Albaricoque valley dorado seca|O|O||D||1|Chabacano valley dorado seco
50321654|Albaricoque westley seca|O|O||D||1|Chabacano westley seco
50321655|Albaricoque  york seca|O|O||D||1|Chabacano york seco
50321700|Bananos secos|O|O||D||1|Plátanos secos
50321701|Banana manzana seca|O|O||D||1|Plátano apple seco
50321702|Banana bebe seca|O|O||D||1|Plátano bebe seco
50321703|Banana burro seca|O|O||D||1|Plátano burro seco
50321704|Bananas cavendish seca|O|O||D||1|Plátano cavendish seco
50321705|Bananas dominico seca|O|O||D||1|Plátano dominico seco
50321706|Bananas verde seca|O|O||D||1|Plátano verde seco
50321707|Bananas gros michel seca|O|O||D||1|Plátano gros michel seco
50321708|Bananas lacatan seca|O|O||D||1|Plátano lacatan seco
50321709|Bananas dedo de dama seca|O|O||D||1|Plátano dedo de dama seco
50321710|Bananas manzano seca|O|O||D||1|Plátano manzano seco
50321711|Banana mysore seca|O|O||D||1|Plátano mysore seco
50321712|Banana pisang mas seca|O|O||D||1|Plátano pisang mas seco
50321713|Bananas roja seca|O|O||D||1|Plátano roja seco
50321714|Bananas saba seca|O|O||D||1|Plátano saba seco
50321715|Bananas sucrier seca|O|O||D||1|Plátano sucrier seco
50321800|Barberries secos|O|O||D||1|Berberís secos
50321801|Berberís paleleaf seca|O|O||D||1|Berberí paleleaf seco
50321802|Barberís chenault seca|O|O||D||1|Berberí chenault seco
50321803|Barberries roja seca|O|O||D||1|Berberí  roja seco
50321804|Barberís winterverde seca|O|O||D||1|Berberí winterverde seco
50321805|Barberís korean seca|O|O||D||1|Berberí korean seco
50321806|Barberís mentor seca|O|O||D||1|Berberí mentor seco
50321807|Barberís japanese seca|O|O||D||1|Berberí japanese seco
50321808|Barberís atropurpurea seca|O|O||D||1|Berberí atropurpurea seco
50321809|Barberís aurea seca|O|O||D||1|Berberí aurea seco
50321810|Barberís bagatelle seca|O|O||D||1|Berberí bagatelle seco
50321811|Barberís crimsom pygmy seca|O|O||D||1|Berberí crimsom pygmy seco
50321812|Barberís kobold seca|O|O||D||1|Berberí kobold seco
50321813|Barberís warty seca|O|O||D||1|Berberí warty seco
50321814|Barberís european seca|O|O||D||1|Berberí european seco
50321900|Gayubas secas|O|O||D||1|Rastreras secas
50321901|Gayuba alpine seca|O|O||D||1|Rastrera alpine seca
50321902|Gayuba roja seca|O|O||D||1|Rastrera roja seca
50321903|Gayuba comun seca|O|O||D||1|Rastrera común seca
50322000|Moras secas|O|O||D||1|Zarzamoras secas
50322001|Mora apache seca|O|O||D||1|Zarzamora apache seca
50322002|Mora negro satin seca|O|O||D||1|Zarzamora negro satín seca
50322003|Mora seca|O|O||D||1|Zarzamora seca
50322004|Mora cherokee seca|O|O||D||1|Zarzamora cherokee seca
50322005|Mora chester seca|O|O||D||1|Zarzamora chéster seca
50322006|Mora dirksen seca|O|O||D||1|Zarzamora dirksen seca
50322007|Bayas josta seca|O|O||D||1|Zarzamora josta seca
50322008|Bayas logan seca|O|O||D||1|Zarzamora logan seca
50322009|Bayas marion seca|O|O||D||1|Zarzamora marion seca
50322010|Mora navaho seca|O|O||D||1|Zarzamora navaho seca
50322011|Baya nectar seca|O|O||D||1|Zarzamora néctar seca
50322012|Mora olallie seca|O|O||D||1|Zarzamora olallie seca
50322013|Baya tay seca|O|O||D||1|Zarzamora tay seca
50322014|Mora thomless hull seca|O|O||D||1|Zarzamora thomless hull seca
50322015|Baya joven seca|O|O||D||1|Zarzamora joven seca
50322100|Arándanos de mirto secos|O|O||D||1|Mirtillos secos
50322101|Arandanos bog seca|O|O||D||1|Mirtillo bog seco
50322102|Arandanos enana seca|O|O||D||1|Mirtillo enano seco
50322103|Arandanos montaña seca|O|O||D||1|Mirtillo de montaña seco
50322104|Arandanos oval-leaved seca|O|O||D||1|Mirtillo oval-leaved seco
50322200|Agrás secas|O|O||D||1|Frutos azules del bosque secos
50322201|Agras bluecrop seca|O|O||D||1|Fruto azul del bosque bluecrop seco
50322202|Agras bluetta seca|O|O||D||1|Fruto azul del bosque bluetta seco
50322203|Agras brigitta seca|O|O||D||1|Fruto azul del bosque brigitta seco
50322204|Agras chandler seca|O|O||D||1|Fruto azul del bosque chandler seco
50322205|Agras duque seca|O|O||D||1|Fruto azul del bosque duque seco
50322206|Agras hardyblue seca|O|O||D||1|Fruto azul del bosque hardyblue seco
50322207|Agras legacy seca|O|O||D||1|Fruto azul del bosque legacy seco
50322208|Agras misty seca|O|O||D||1|Fruto azul del bosque misty seco
50322209|Agras nelson seca|O|O||D||1|Fruto azul del bosque nelson seco
50322210|Agras northblue seca|O|O||D||1|Fruto azul del bosque northblue seco
50322211|Agras northcountry seca|O|O||D||1|Fruto azul del bosque northcountry seco
50322212|Agras northsky seca|O|O||D||1|Fruto azul del bosque northsky seco
50322213|Agras patriot seca|O|O||D||1|Fruto azul del bosque patriot seco
50322214|Agras spartan seca|O|O||D||1|Fruto azul del bosque spartan seco
50322215|Agras toro seca|O|O||D||1|Fruto azul del bosque toro seco
50322300|Frutas del pan secas|O|O||D||1
50322301|Fruta de pan chataigne seca|O|O||D||1|Fruta del pan chataigne seca
50322302|Fruta de pan sin pepa seca|O|O||D||1|Fruta del pan sin semilla seca
50322303|Fruta de pan corazón blanco seca|O|O||D||1|Fruta del pan corazón blanco seca
50322304|Fruta de pan corazón amarillo seca|O|O||D||1|Fruta del pan corazón amarillo seca
50322400|Chirimoyas secas|O|O||D||1|Annonas secas
50322401|Chirimoya chays seca|O|O||D||1|Annona chays seca
50322402|Chirimoya bronceada seca|O|O||D||1|Annona bronceada seca
50322403|Chirimoya burtons seca|O|O||D||1|Annona burtons seca
50322404|Chirimoya burton favorite seca|O|O||D||1|Annona burton favorite seca
50322405|Chirimoya jete seca|O|O||D||1|Annona jete seca
50322406|Chirimoya reretai seca|O|O||D||1|Annona reretai seca
50322407|Chirimoya smoothey seca|O|O||D||1|Annona smoothey seca
50322408|Chirimoya españa seca|O|O||D||1|Annona españa seca
50322409|Chirimoya blanco seca|O|O||D||1|Annona blanco seca
50322500|Cerezas secas|O|O||D||1
50322501|Cereza amarelle  seca|O|O||D||1
50322502|Cereza brooks seca|O|O||D||1
50322503|Cereza bigarreu seca|O|O||D||1
50322504|Cereza bing seca|O|O||D||1
50322505|Cereza blach republic seca|O|O||D||1
50322506|Cereza negro schmidt seca|O|O||D||1
50322507|Cereza negro tartarian seca|O|O||D||1
50322508|Cereza fiesta bing seca|O|O||D||1
50322509|Cereza garnet seca|O|O||D||1
50322510|Cereza rey seca|O|O||D||1
50322511|Cereza chapman seca|O|O||D||1
50322512|Cereza lapin seca|O|O||D||1
50322513|Cereza larian seca|O|O||D||1
50322514|Cereza dark guines seca|O|O||D||1
50322515|Cereza montmorency seca|O|O||D||1
50322516|Cereza duque seca|O|O||D||1
50322517|Cereza early rivers seca|O|O||D||1
50322518|Cereza ruby bing seca|O|O||D||1
50322519|Cereza santine seca|O|O||D||1
50322520|Cereza geans/guines seca|O|O||D||1
50322521|Cereza sonata seca|O|O||D||1
50322522|Cereza lambert seca|O|O||D||1
50322523|Cereza stella seca|O|O||D||1
50322524|Cereza sweethart seca|O|O||D||1
50322525|Cereza tartarian seca|O|O||D||1
50322527|Cereza maraschino seca|O|O||D||1
50322528|Cereza van seca|O|O||D||1
50322529|Cereza morello seca|O|O||D||1
50322530|Cereza ann real seca|O|O||D||1
50322531|Cereza ranier seca|O|O||D||1
50322532|Cereza real seca|O|O||D||1
50322600|Citrones secos|O|O||D||1|Cidras secas
50322601|Citrones buddha´s hand seca|O|O||D||1|Cidra mano de Buda seca
50322602|Citrones fingeroja seca|O|O||D||1|Cidra finger red seca
50322603|Citrones fo shoukan seca|O|O||D||1|Cidra fo shoukan seca
50322604|Cotrones bushakan seca|O|O||D||1|Cidra bushakan seca
50322605|Citones diamante seca|O|O||D||1|Cidra diamante seca
50322606|Citrones etrog seca|O|O||D||1|Cidra etrog seca
50322607|Citrones ponderosa seca|O|O||D||1|Cidra ponderosa seca
50322700|Arándanos secos|O|O||D||1|Arándanos rojos secos
50322701|Arandano ben lear seca|O|O||D||1|Arándano rojo ben lear seco
50322702|Arandano early negro seca|O|O||D||1|Arándano rojo early negro seco
50322703|Arandano gryclesik seca|O|O||D||1|Arándano rojo gryclesik seco
50322704|Arandano  howe seca|O|O||D||1|Arándano rojo howe seco
50322705|Bayas lingon seca|O|O||D||1|Arándano rojo lingon seco
50322706|Arandano mcfarling seca|O|O||D||1|Arándano rojo mcfarling seco
50322707|Arandano mauntain seca|O|O||D||1|Arándano rojo mauntain seco
50322708|Arandano pilgrim seca|O|O||D||1|Arándano rojo pilgrim seco
50322709|Arandano searless seca|O|O||D||1|Arándano rojo searless seco
50322710|Arandano stevens seca|O|O||D||1|Arándano rojo stevens seco
50322800|pasas de Corinto secas|O|O||D||1
50322801|Pasa hudson bay seca|O|O||D||1|Pasa de Corinto hudson bay seca
50322802|Pasa waxy seca|O|O||D||1|Pasa de Corinto waxy seca
50322803|Pasa desert seca|O|O||D||1|Pasa de Corinto desert seca
50322804|Pasa negra seca|O|O||D||1|Pasa de Corinto negra seca
50322805|Pasa roja seca|O|O||D||1|Pasa de Corinto roja seca
50322806|Pasa blanca seca|O|O||D||1|Pasa de Corinto blanca seca
50322900|Dátiles secos|O|O||D||1
50322901|Dátiles asharasi  seca|O|O||D||1
50322902|Dátiles barhi o barhee seca|O|O||D||1
50322903|Dátiles deglet noor seca|O|O||D||1
50322904|Dátiles fardh seca|O|O||D||1
50322905|Dátiles gundila seca|O|O||D||1
50322906|Dátiles halawi/halawy seca|O|O||D||1
50322907|Dátiles hilali seca|O|O||D||1
50322908|Dátiles khadrawi/khadrawy seca|O|O||D||1
50322909|Dátiles khalas seca|O|O||D||1
50322910|Dátiles khustawi seca|O|O||D||1
50322911|Dátiles khidri seca|O|O||D||1
50322912|Dátiles medjool/ medjol seca|O|O||D||1
50322913|Dátiles mactoum seca|O|O||D||1
50322914|Dátiles neghal seca|O|O||D||1
50322915|Dátiles yatimeh seca|O|O||D||1
50322916|Dátiles zahidi seca|O|O||D||1
50323000|Pitahayas secas|O|O||D||1
50323001|Pitahaya roja, rosada seca|O|O||D||1
50323002|Pitahaya roja, amarillo seca|O|O||D||1
50323100|Brevas secas|O|O||D||1|Higos secos
50323101|Breva bardajic seca|O|O||D||1|Higo bardajic seco
50323102|Breva brown turkey seca|O|O||D||1|Higo brown turkey seco
50323103|Breva calimyma  seca|O|O||D||1|Higo calimyma seco
50323104|Breva conadria seca|O|O||D||1|Higo conadria seco
50323105|Breva dotado seca|O|O||D||1|Higo dotado seco
50323106|Breva kadota seca|O|O||D||1|Higo kadota seco
50323107|Breva mediterránea seca|O|O||D||1|Higo mediterránea seco
50323108|Breva misión seca|O|O||D||1|Higo misión seco
50323109|Breva amyma seca|O|O||D||1|Higo amyma seco
50323110|Breva verdona seca|O|O||D||1|Higo verdona seco
50323111|Breva rey blanco seca|O|O||D||1|Higo rey blanco seco
50323200|Grosellas secas|O|O||D||1
50323201|Grosella early sulphur seca|O|O||D||1
50323202|Grosella dorado caida seca|O|O||D||1
50323203|Grosella langley grace seca|O|O||D||1
50323204|Grocella leveller seca|O|O||D||1
50323205|Grosella london seca|O|O||D||1
50323206|Grosella worcestershire seca|O|O||D||1
50323207|Grosella americana  worcesterberry sec|O|O||D||1
50323300|Toronjas secas|O|O||D||1
50323301|Toronja burgundi seca|O|O||D||1
50323302|Toronja duncan seca|O|O||D||1
50323303|Toronja foster seca|O|O||D||1
50323304|Toronja marsh seca|O|O||D||1
50323305|Toronja nueva zelandia seca|O|O||D||1
50323306|Toronja rio rojo seca|O|O||D||1
50323307|Toronja ruby rojo seca|O|O||D||1
50323308|Toronja star ruby seca|O|O||D||1
50323309|Toronja triumph seca|O|O||D||1
50323400|Uvas de mesa secas|O|O||D||1
50323401|Uva alicante seca|O|O||D||1
50323402|Uva almeira seca|O|O||D||1
50323403|Uva alphonse lavalle seca|O|O||D||1
50323404|Uva otoño rey grapes seca|O|O||D||1
50323405|Uva otoño royal seca|O|O||D||1
50323406|Uva otoño sin pepa seca|O|O||D||1
50323407|Uva baresana seca|O|O||D||1
50323408|Uva barlinka seca|O|O||D||1
50323409|Uva beaty seedless seca|O|O||D||1
50323410|Uva negro beauty sin pepa seca|O|O||D||1
50323411|Uva negro esmeralda seca|O|O||D||1
50323412|Uva negro gigante seca|O|O||D||1
50323413|Uva negro globo seca|O|O||D||1
50323414|Uva negro monnukka seca|O|O||D||1
50323415|Uva negro perla seca|O|O||D||1
50323416|Uva negro sin pepa seca|O|O||D||1
50323417|Uva bonheur seca|O|O||D||1
50323418|Uva calmeria seca|O|O||D||1
50323419|Uva cardinal seca|O|O||D||1
50323420|Uva catawba seca|O|O||D||1
50323421|Uva chasselas/doradoen chasselas seca|O|O||D||1
50323422|Uva christmas rose seca|O|O||D||1
50323423|Uva concord seca|O|O||D||1
50323424|Uva concord sin pepa seca|O|O||D||1
50323425|Uva crimson sin pepa seca|O|O||D||1
50323426|Uva dauphine  seca|O|O||D||1
50323427|Uva daleware seca|O|O||D||1
50323428|Uva early muscat seca|O|O||D||1
50323429|Uva early sweet seca|O|O||D||1
50323430|Uva esmeralda sin pepa seca|O|O||D||1
50323431|Uva emperatriz seca|O|O||D||1
50323432|Uva emperor seca|O|O||D||1
50323433|Uva empress seca|O|O||D||1
50323434|Uva exótica seca|O|O||D||1
50323435|Uva fantasia seca|O|O||D||1
50323436|Uva fantasy sin pepa seca|O|O||D||1
50323437|Uva llama seca|O|O||D||1
50323438|Uva llama sin pepa seca|O|O||D||1
50323439|Uva llama tokay seca|O|O||D||1
50323440|Uva ardiente roja seca|O|O||D||1
50323441|Uva galaxy sin pepa seca|O|O||D||1
50323442|Uva gamay seca|O|O||D||1
50323443|Uva dorada seca|O|O||D||1
50323444|Uva hanepot o honeypot seca|O|O||D||1
50323445|Uva italia seca|O|O||D||1
50323446|Uva jade sin pepa seca|O|O||D||1
50323447|Uva jubilee seca|O|O||D||1
50323448|Uva rey ruby seca|O|O||D||1
50323449|Uva kyoho seca|O|O||D||1
50323450|Uva la rochelle seca|O|O||D||1
50323451|Uva dedo de dama seca|O|O||D||1
50323452|Uva late sin pepa seca|O|O||D||1
50323453|Uva majestic sin pepa seca|O|O||D||1
50323454|Uva malaga seca|O|O||D||1
50323455|Uva marro sin pepa seca|O|O||D||1
50323456|Uva muscadine seca|O|O||D||1
50323457|Uva muscat llama seca|O|O||D||1
50323458|Uva muscat seca|O|O||D||1
50323459|Uva muscat sin papa seca|O|O||D||1
50323460|Uva napoleon seca|O|O||D||1
50323461|Uva nigeria seca|O|O||D||1
50323462|Uva new cross seca|O|O||D||1
50323463|Uva nibella seca|O|O||D||1
50323464|Uva niagara seca|O|O||D||1
50323465|Uva olivette seca|O|O||D||1
50323466|Uva perlette seca|O|O||D||1
50323467|Uva perlon seca|O|O||D||1
50323468|Uva prima negro sin pepa seca|O|O||D||1
50323469|Uva prncess seca|O|O||D||1
50323470|Uva reina seca|O|O||D||1
50323471|Uva roja blush seca|O|O||D||1
50323472|Uva roja globe seca|O|O||D||1
50323473|Uva roja malaga seca|O|O||D||1
50323474|Uva roja sin pepa seca|O|O||D||1
50323475|Uva regina seca|O|O||D||1
50323476|Uva ribier seca|O|O||D||1
50323477|Uva rosita seca|O|O||D||1
50323478|Uva rouge seca|O|O||D||1
50323479|Uva royal negra sin pepa seca|O|O||D||1
50323480|Uva ruby roja sin pepa seca|O|O||D||1
50323481|Uva ryby sin pepa seca|O|O||D||1
50323482|Uva scarlet royal seca|O|O||D||1
50323483|Uva scuppemong seca|O|O||D||1
50323484|Uva sugarose seca|O|O||D||1
50323485|Uva sugartirteen seca|O|O||D||1
50323486|Uva sugraone seca|O|O||D||1
50323487|Uva sugrasixteen seca|O|O||D||1
50323488|Uva sultana sun roja seca|O|O||D||1
50323489|Uva verano royal seca|O|O||D||1
50323490|Uva atardecer seca|O|O||D||1
50323491|Uva superior sin pepa seca|O|O||D||1
50323492|Uva thompson sin pepa seca|O|O||D||1
50323493|Uva tokaylpinot gris seca|O|O||D||1
50323494|Uva waltman cross seca|O|O||D||1
50323495|Uva blanca sin semilla seca|O|O||D||1
50323496|Uva zante current seca|O|O||D||1
50323500|Uvas pasas secas|O|O||D||1
50323501|Uva corinth negra seca|O|O||D||1
50323502|Uva canner seca|O|O||D||1
50323503|Uva dovine seca|O|O||D||1
50323504|Uva fiesta seca|O|O||D||1
50323505|Uva selme pete seca|O|O||D||1
50323506|Uva sultana seca|O|O||D||1
50323600|Uvas para vino secas|O|O||D||1
50323601|Uva alicante bouschet seca|O|O||D||1
50323602|Uva barbera seca|O|O||D||1
50323603|Uva burger seca|O|O||D||1
50323604|Uva cabemet franc seca|O|O||D||1
50323605|Uva cabenet sauvignon seca|O|O||D||1
50323606|Uva carignane seca|O|O||D||1
50323607|Uva carnelian seca|O|O||D||1
50323608|Uva catarratto seca|O|O||D||1
50323609|Uva centurian seca|O|O||D||1
50323610|Uva charbono seca|O|O||D||1
50323611|Uva chardonnay seca|O|O||D||1
50323612|Uva chenin blanco seca|O|O||D||1
50323613|Uva cinsaut seca|O|O||D||1
50323614|Uva dolcetto seca|O|O||D||1
50323615|Uva esmeralda  riesling seca|O|O||D||1
50323616|Uva french colombard seca|O|O||D||1
50323617|Uva granny nap seca|O|O||D||1
50323618|Uva gamay beaujolais seca|O|O||D||1
50323619|Uva gewurztraminer seca|O|O||D||1
50323620|Uva grnache seca|O|O||D||1
50323621|Uva grinache blanc seca|O|O||D||1
50323622|Uva lagrein seca|O|O||D||1
50323623|Uva lambruso seca|O|O||D||1
50323624|Uva malbec seca|O|O||D||1
50323625|Uva malvasía bianca seca|O|O||D||1
50323626|Uva marsanne seca|O|O||D||1
50323627|Uva matano seca|O|O||D||1
50323628|Uva merlot seca|O|O||D||1
50323629|Uva meunier seca|O|O||D||1
50323630|Uva missiom seca|O|O||D||1
50323631|Uva montepulceano seca|O|O||D||1
50323632|Uva muscat blanc seca|O|O||D||1
50323633|Uva muscat hamburg seca|O|O||D||1
50323634|Uva muscat alexandria seca|O|O||D||1
50323635|Uva muscat naranja seca|O|O||D||1
50323636|Uva nebbiolo seca|O|O||D||1
50323637|Uva palomino seca|O|O||D||1
50323638|Uva petit verdot seca|O|O||D||1
50323639|Uva petite sirah seca|O|O||D||1
50323640|Uva pinot blanc seca|O|O||D||1
50323641|Uva pinot gris seca|O|O||D||1
50323642|Uva pinot noir seca|O|O||D||1
50323643|Uva primitivo seca|O|O||D||1
50323644|Uva roussane seca|O|O||D||1
50323645|Uva realeza seca|O|O||D||1
50323646|Uva rubiroja seca|O|O||D||1
50323647|Uva ruby cabernet seca|O|O||D||1
50323648|Uva salvador seca|O|O||D||1
50323649|Uva sangiovese seca|O|O||D||1
50323650|Uva sauvignon blanc seca|O|O||D||1
50323651|Uva sauvignon musque seca|O|O||D||1
50323652|Uva semillon seca|O|O||D||1
50323653|Uva souzao seca|O|O||D||1
50323654|Uva st emilion seca|O|O||D||1
50323655|Uva symphony seca|O|O||D||1
50323656|Uva syrah  seca|O|O||D||1
50323657|Uva tannat seca|O|O||D||1
50323658|Uva tempranillo seca|O|O||D||1
50323659|Uvas teroldego seca|O|O||D||1
50323660|Uvas tocai friulano seca|O|O||D||1
50323661|Uvas touriga nacional seca|O|O||D||1
50323662|Uvas triplett blanc seca|O|O||D||1
50323663|Uvas viognier seca|O|O||D||1
50323664|Uvas blanco riesling seca|O|O||D||1
50323665|Uvas zinfandel seca|O|O||D||1
50323700|Guayabas secas|O|O||D||1
50323701|Guayaba beaumont seca|O|O||D||1
50323702|Guayaba carrley seca|O|O||D||1
50323703|Guayaba lucida seca|O|O||D||1
50323704|Guayaba piña seca|O|O||D||1
50323800|Arándanos Huckleberry secos|O|O||D||1|Arándanos azules secos
50323801|Arándano invierno negro seco|O|O||D||1|Arándano azul invierno negro seco
50323802|Arándano cascada seco|O|O||D||1|Arándano azul cascada seco
50323803|Arándano enano seco|O|O||D||1|Arándano azul enano seco
50323804|Arándano montaña seco|O|O||D||1|Arándano azul montaña seco
50323805|Arándano rojo seco|O|O||D||1|Arándano azul red seco
50323900|Kiwis secos|O|O||D||1
50323901|Fruta de kiwi ananasnaja seca|O|O||D||1|Kiwi ananasnaja seco
50323902|Fruta de kiwi belleza del ártico seca|O|O||D||1|Kiwi belleza del ártico seco
50323903|Fruta de kiwi blake seca|O|O||D||1|Kiwi blake seco
50323904|Fruta de kiwi hayward seca|O|O||D||1|Kiwi hayward seco
50323905|Fruta de kiwi issai seca|O|O||D||1|Kiwi issai seco
50323906|Fruta de kiwi siberiana seca|O|O||D||1|Kiwi siberiano seco
50324000|Naranjos Chinos (kumquats) secos|O|O||D||1
50324001|Naranjo hong kong seco|O|O||D||1|Naranjo chino hong kong seco
50324002|Naranjo limequat seco|O|O||D||1|Naranjo chino limequat seco
50324003|Naranjo long fruit seco|O|O||D||1|Naranjo chino long fruit seco
50324004|Naranjo malayo seco|O|O||D||1|Naranjo chino malayo seco
50324005|Naranjo meiwa seco|O|O||D||1|Naranjo chino meiwa seco
50324006|Naranja nagami seco|O|O||D||1|Naranjo chino nagami seco
50324100|Limones secos|O|O||D||1
50324101|Limón baboon seco|O|O||D||1
50324102|Limón bearss sicilian seco|O|O||D||1
50324103|Limón cameron highland seco|O|O||D||1
50324104|Limón escondido seco|O|O||D||1
50324105|Limón eureka seco|O|O||D||1
50324106|Limón lisbon seco|O|O||D||1
50324107|Limón meyer seco|O|O||D||1
50324108|Limón volkaner seco|O|O||D||1
50324200|Limas secas|O|O||D||1
50324201|Lima limón indian sweet seco|O|O||D||1
50324202|Lima limón seco|O|O||D||1
50324203|Lima limón mandarin seco|O|O||D||1
50324204|Lima limón philippine seco|O|O||D||1
50324205|Lima limón tahitian seco|O|O||D||1
50324206|Lima limón bearss seco|O|O||D||1
50324207|Lima limón persa seco|O|O||D||1
50324208|Lima limón sin pepas seco|O|O||D||1|Lima limón sin semilla seco
50324300|Nísperos secos|O|O||D||1
50324301|Níspero japonés advance seco|O|O||D||1
50324302|Níspero japonés benlehr seco|O|O||D||1
50324303|Níspero japonés big jim seco|O|O||D||1
50324304|Níspero japonés champagne seco|O|O||D||1
50324305|Níspero japonés early rojo seco|O|O||D||1
50324306|Níspero japonés nugget dorado seco|O|O||D||1
50324307|Níspero japonés herd´s mammoth seco|O|O||D||1
50324308|Níspero japonés mogi seco|O|O||D||1
50324309|Níspero japonés mrs cooksey seco|O|O||D||1
50324310|Níspero japonés fresa seco|O|O||D||1
50324311|Níspero japonés tanaka seco|O|O||D||1
50324312|Níspero japonés victoria vista blanco seco|O|O||D||1
50324313|Níspero japonés wolfe seco|O|O||D||1
50324400|Mandarinas secas|O|O||D||1
50324401|Naranjas clauselinas secas|O|O||D||1
50324402|Mandarinas clementinas secas|O|O||D||1
50324403|Naranja mandarina cleopatra|O|O||D||1
50324404|Mandarina dancy seca|O|O||D||1
50324405|Naranja ellensday seca|O|O||D||1
50324406|Naranja fairchild seca|O|O||D||1
50324407|Naranja fallglo seca|O|O||D||1
50324408|Naranja fortuna seca|O|O||D||1
50324409|Mandarina naranja fremont seca|O|O||D||1
50324410|Naranja fremont seca|O|O||D||1
50324411|Naranja nuget dorada seca|O|O||D||1
50324412|Mandarina naranja miel seca|O|O||D||1
50324413|Naranja miel seca|O|O||D||1
50324414|Mandarina miel seca|O|O||D||1
50324415|Natanja tanjelo honebelle seca|O|O||D||1|Naranja tangelo honebelle seca
50324416|Naranja mandarina rey seca|O|O||D||1
50324417|Naranja kinnow seca|O|O||D||1
50324418|Naranja andarinalee seca|O|O||D||1
50324419|Naranja makokkee seca|O|O||D||1
50324420|Naranja malvasion seca|O|O||D||1
50324421|Naranja mandarina mediterránea seca|O|O||D||1
50324422|Naranja tangelo minneola seca|O|O||D||1
50324423|Naranja monica seca|O|O||D||1
50324424|Naranja murcott miel seca|O|O||D||1
50324425|Naranja murcott tangors seca|O|O||D||1
50324426|Naranja mandarina natsudaidai  seca|O|O||D||1
50324427|Naranja mandarina natsumikan seca|O|O||D||1
50324428|Naranja tanjelo nocatee seca|O|O||D||1
50324429|Naranja tanjelo orlando seca|O|O||D||1
50324430|Mandarina ortanique seca|O|O||D||1
50324431|Naranja mandarina pagina seca|O|O||D||1
50324432|Naranja pixie seca|O|O||D||1
50324433|Naranja mandarina ponkan bantangas seca|O|O||D||1
50324434|Naranja reina seca|O|O||D||1
50324435|Naranja robinson seca|O|O||D||1
50324436|Naranja saltenitas seca|O|O||D||1
50324437|Naranja tangelo sampson seca|O|O||D||1
50324438|Naranja mandarina satsuma seca|O|O||D||1
50324439|Naranja mandarina sunburst seca|O|O||D||1
50324440|Tangelo seco|O|O||D||1
50324441|Naranja mandarina seca|O|O||D||1
50324442|Naranja templo seca|O|O||D||1
50324443|Naranja thornton seca|O|O||D||1
50324444|Mandarina wekiwa seca|O|O||D||1
50324445|Mandarina wilkins seca|O|O||D||1
50324446|Mandarina willowleaf mediterránea seca|O|O||D||1
50324500|Mangos secos|O|O||D||1
50324501|Mango alphonso seco|O|O||D||1
50324502|Mango ataulfo seco|O|O||D||1
50324503|Mango criollo seco|O|O||D||1
50324504|Mango edwards seco|O|O||D||1
50324505|Mango francine seco|O|O||D||1
50324506|Mango francis seco|O|O||D||1
50324507|Mango gandaria seco|O|O||D||1
50324508|Mango haden seco|O|O||D||1
50324509|Mangos irwin seco|O|O||D||1
50324510|Mangos keitt seco|O|O||D||1
50324511|Mangos kent seco|O|O||D||1
50324512|Mangos kesar seco|O|O||D||1
50324513|Mangos kuini seco|O|O||D||1
50324514|Mangos manila super seco|O|O||D||1
50324515|Mangos manila seco|O|O||D||1
50324516|Mangos mayaguez seco|O|O||D||1
50324517|Mangos mulgoba seco|O|O||D||1
50324518|Mangos oro seco|O|O||D||1
50324519|Mangos palmer seco|O|O||D||1
50324520|Mango parvin seco|O|O||D||1
50324521|Mango sandersha seco|O|O||D||1
50324522|Mangos sensation seco|O|O||D||1
50324523|Mango smith seco|O|O||D||1
50324524|Mango tomy atkin seco|O|O||D||1
50324525|Mango van dyke seco|O|O||D||1
50324600|Melones secos|O|O||D||1
50324601|Melon allsweet seco|O|O||D||1
50324602|Melón athens seco|O|O||D||1
50324603|Melón diamante negro seco|O|O||D||1
50324604|Melón cal sweet seco|O|O||D||1
50324605|Melons cantaloupe seco|O|O||D||1
50324606|Melón carnical seco|O|O||D||1
50324607|Melón casaba seco|O|O||D||1
50324608|Melón cavaillon seco|O|O||D||1
50324609|Melón charentais seco|O|O||D||1
50324610|Sandia charleston gray seco|O|O||D||1
50324611|Melón crenshaw seco|O|O||D||1
50324612|Melón crimson sweet seco|O|O||D||1
50324613|Melón dixie lee seco|O|O||D||1
50324614|Melón eclipse seco|O|O||D||1
50324615|Melón ein dór  seco|O|O||D||1
50324616|Melón fiesta seco|O|O||D||1
50324617|Melón galia seco|O|O||D||1
50324618|Melón gaya seco|O|O||D||1
50324619|Melón hami seco|O|O||D||1
50324620|Melón miel dew seco|O|O||D||1
50324621|Melón hielo seco|O|O||D||1
50324622|Melón ida orgullo seco|O|O||D||1
50324623|Melón juan canary seco|O|O||D||1
50324624|Melón jubileo seco|O|O||D||1
50324625|Melón jubilación seco|O|O||D||1
50324626|Melón kaki / kakri seco|O|O||D||1
50324627|Melón kiwano seco|O|O||D||1
50324628|Melon koreano seco|O|O||D||1|Melón coreano seco
50324629|Melón long grey seco|O|O||D||1|Melón largo gris seco
50324630|Melón mayan seco|O|O||D||1
50324631|Melón micky lee seco|O|O||D||1
50324632|Melón mirage seco|O|O||D||1
50324633|Sandia luna y estrellas seco|O|O||D||1
50324634|Melón ogen seco|O|O||D||1
50324635|Melón patriot seco|O|O||D||1
50324636|Melón pavo real seco|O|O||D||1
50324637|Melón pepino seco|O|O||D||1
50324638|Melón persian seco|O|O||D||1
50324639|Melón picnic seco|O|O||D||1
50324640|Melón piel de sapo seco|O|O||D||1
50324641|Melón piña seco|O|O||D||1
50324642|Melón quetzali seco|O|O||D||1
50324643|Melón goblin rojo seco|O|O||D||1
50324644|Melón regency seco|O|O||D||1
50324645|Melón royal mejestic seco|O|O||D||1
50324646|Melón royal star seco|O|O||D||1
50324647|Melón dulce royal seco|O|O||D||1
50324648|Malon santa claus seco|O|O||D||1|Melón piel de sapo seco, Melón santa claus seco
50324649|Melón sharlyn seco|O|O||D||1
50324650|Melón español seco|O|O||D||1
50324651|Melón sprite sec seco|O|O||D||1
50324652|Melón starbright seco|O|O||D||1
50324653|Melón stars and stripes seco|O|O||D||1
50324654|Melón bebe de azúcar seco|O|O||D||1
50324655|Sandia bebe de azúcar seca|O|O||D||1
50324656|Melón dulce sol seco|O|O||D||1
50324657|Sandia corazón dulce sin semilla seca|O|O||D||1
50324658|Melón tentación seco|O|O||D||1
50324659|Melón bebe tigre seco|O|O||D||1
50324660|Melón tuscan tipo seco|O|O||D||1
50324661|Sandia bebe amarillo seca|O|O||D||1
50324700|Moras mulberry secas|O|O||D||1|Zarzamoras mulberry secas
50324701|Mora negra seca|O|O||D||1|Zarzamora negra seca
50324702|Mora blanca seca|O|O||D||1|Zarzamora blanca seca
50324800|Mirtos secos|O|O||D||1|Arrayanes secos
50324801|Mirto bog seco|O|O||D||1|Arrayán bog seco
50324900|Nectarinas secos|O|O||D||1
50324901|Durazno april glo seco|O|O||D||1
50324902|Durazno arctic mist seco|O|O||D||1
50324903|Durazno artic snow seco|O|O||D||1
50324904|Durazno artic star seco|O|O||D||1
50324905|Durazno artic dulce seco|O|O||D||1
50324906|Durazno artic glo seco|O|O||D||1
50324907|Durazno august fire seco|O|O||D||1
50324908|Durazno  perla de agosto seco|O|O||D||1
50324909|Durazno agosto rojo seco|O|O||D||1
50324910|Durazno estrella de agosto seco|O|O||D||1
50324911|Durazno big john seco|O|O||D||1
50324912|Durazno perla brillante seco|O|O||D||1
50324913|Durazno diamante brillante seco|O|O||D||1
50324914|Durazno diamante ray seco|O|O||D||1
50324915|Durazno earligo seco|O|O||D||1
50324916|Durazno diamante temprano seco|O|O||D||1
50324917|Durazno fairlane seco|O|O||D||1
50324918|Durazno fantasia seco|O|O||D||1
50324919|Durazno perla fuego seco|O|O||D||1
50324920|Durazno fuego dulce seco|O|O||D||1
50324921|Durazno llamakist seco|O|O||D||1
50324922|Durazno tipo plano seco|O|O||D||1
50324923|Durazno delicia de jardín seco|O|O||D||1
50324924|Durazno mina de oro seco|O|O||D||1
50324925|Durazno perla grande seco|O|O||D||1
50324926|Durazno hardiroja seco|O|O||D||1
50324927|Durazno miel de fuego seco|O|O||D||1
50324928|Durazno julio rojo seco|O|O||D||1
50324929|Durazno kay perla seco|O|O||D||1
50324930|Durazno key dulce seco|O|O||D||1
50324931|Durazno diamante mayo seco|O|O||D||1
50324932|Durazno mayfire seco|O|O||D||1
50324933|Durazno mayglo seco|O|O||D||1
50324934|Durazno mericrest seco|O|O||D||1
50324935|Durazno diamante rojo seco|O|O||D||1
50324936|Durazno oro rojo seco|O|O||D||1
50324937|Durazno jim rojo seco|O|O||D||1
50324938|Durazno roy rojo seco|O|O||D||1
50324939|Durazno rio rojo seco|O|O||D||1
50324940|Durazno diamante de rosa seco|O|O||D||1
50324941|Durazno rotal glo seco|O|O||D||1
50324942|Durazno diamante ryby seco|O|O||D||1
50324943|Durazno ruby dulce seco|O|O||D||1
50324944|Durazno joya ruddy seco|O|O||D||1
50324945|Durazno septiembre rojo seco|O|O||D||1
50324946|Durazno reina de nieve seco|O|O||D||1
50324947|Durazno primavera clara seco|O|O||D||1
50324948|Durazno primavera roja seco|O|O||D||1
50324949|Durazno verano rojiso seco|O|O||D||1
50324950|Durazno verano claro seco|O|O||D||1
50324951|Durazno verano diamante seco|O|O||D||1
50324952|Durazno verano fuego seco|O|O||D||1
50324953|Durazno verano grande seco|O|O||D||1
50324954|Durazno sunglo seco|O|O||D||1
50324955|Durazno fuego zee seco|O|O||D||1
50324956|Durazno zee glo seco|O|O||D||1
50324957|Durazno zeegrand seco|O|O||D||1
50325000|Naranjas secas|O|O||D||1
50325001|Naranja áfrica agria seca|O|O||D||1
50325002|Naranja dulce amber seca|O|O||D||1
50325003|Naranja argentina agria seca|O|O||D||1
50325004|Naranja bahianinha seco|O|O||D||1
50325005|Naranja bergamot seca|O|O||D||1
50325006|Naranja berna seca|O|O||D||1
50325007|Naranja bigaradier apepu seca|O|O||D||1
50325008|Naranja agria dulce daidai seca|O|O||D||1
50325009|Naranja mono seca|O|O||D||1
50325010|Naranja sangre seca|O|O||D||1
50325011|Naranja california navel seca|O|O||D||1
50325012|Naranja cara cara seca|O|O||D||1
50325013|Naranja chinotto seca|O|O||D||1
50325014|Naranja sueño nevel seca|O|O||D||1
50325015|Naranja gou tou seca|O|O||D||1
50325016|Naranja hamlin seca|O|O||D||1
50325017|Naranja jaffa seca|O|O||D||1
50325018|Naranja jincheng seca|O|O||D||1
50325019|Naranja k-temprano seca|O|O||D||1
50325020|Naranja kona seca|O|O||D||1
50325021|Naranja navel tarde seca seca|O|O||D||1
50325022|Naranja valencia tarde seca|O|O||D||1
50325023|Naranja limequat seca|O|O||D||1
50325024|Naranja mar seca|O|O||D||1
50325025|Naranja maledorado seca|O|O||D||1
50325026|Naranja moro seca|O|O||D||1
50325027|Naranja moro tabaco seca|O|O||D||1
50325028|Naranja navel seca|O|O||D||1
50325029|Naranja navelina seca|O|O||D||1
50325030|Naranja oro blanco seca|O|O||D||1
50325031|Naranja osceola seca|O|O||D||1
50325032|Naranja parson carmelito seca|O|O||D||1
50325033|Naranja pera seca|O|O||D||1
50325034|Naranjo pummulo seca|O|O||D||1|Naranja pummulo seca
50325035|Naranja rhode rojo seca|O|O||D||1
50325036|Naranja roble seca|O|O||D||1
50325037|Naranja salustianas seca|O|O||D||1
50325038|Naranja sanguine seca|O|O||D||1
50325039|Naranja sanguinelli seca|O|O||D||1
50325040|Naranja cevilla seca|O|O||D||1
50325041|Naranja shamouti jaffa seca|O|O||D||1
50325042|Naranja tunis seca|O|O||D||1
50325043|Naranja valencia seca|O|O||D||1
50325044|Naranja washington navel seca|O|O||D||1
50325100|Papayas secas|O|O||D||1
50325101|Papaya verde cocinar seca|O|O||D||1
50325102|Papaya maradol seca|O|O||D||1
50325103|Papaya amarillo mexicano seca|O|O||D||1
50325104|Papaya montaña seca|O|O||D||1
50325105|Papaya solo seca|O|O||D||1
50325106|Papaya tainung seca|O|O||D||1
50325200|Maracuyás secas|O|O||D||1
50325201|Fruta maracuyá banana seca|O|O||D||1|Curuba seca
50325202|Maracuyá flor azul seca|O|O||D||1|Maracuyá pasionaria azul seca
50325203|Maracuyá crackerjack seca|O|O||D||1
50325204|Maracuyá granadilla gigante seca|O|O||D||1
50325205|Maracuyá granadilla dorada seca|O|O||D||1
50325206|Maracuyá maypops seca|O|O||D||1
50325207|Maracuyá roja seca|O|O||D||1
50325208|Maracuyá granadilla dulce seca|O|O||D||1
50325209|Maracuyá sandia seca|O|O||D||1
50325210|Maracuyá  wing- steam seca|O|O||D||1
50325300|Duraznos secos|O|O||D||1
50325301|Durazno escudo amber seco|O|O||D||1
50325302|Durazno nieve de abril seco|O|O||D||1
50325303|Durazno dama de agosto seco|O|O||D||1
50325304|Durazno llama de otoño seco|O|O||D||1
50325305|Durazno dama de otoño seco|O|O||D||1
50325306|Durazno babcock seco|O|O||D||1
50325307|Durazno brittany lane seco|O|O||D||1
50325308|Durazno cary mac seco|O|O||D||1
50325309|Durazno clásica seco|O|O||D||1
50325310|Durazno dulce del campo seco|O|O||D||1
50325311|Durazno escudo de cielo seco|O|O||D||1
50325312|Durazno dama crimson seco|O|O||D||1
50325313|Durazno príncipe corona seco|O|O||D||1
50325314|Durazno sol david seco|O|O||D||1
50325315|Durazno  princesa diamante seco|O|O||D||1
50325316|Durazno earlrich seco|O|O||D||1
50325317|Durazno majestuosa temprana seco|O|O||D||1
50325318|Durazno early treat seco|O|O||D||1
50325319|Durazno dama elegante seco|O|O||D||1
50325320|Durazno emperatriz seco|O|O||D||1
50325321|Durazno encoré seco|O|O||D||1
50325322|Durazno dama elegante seco|O|O||D||1
50325323|Durazno príncipe de fuego seco|O|O||D||1
50325324|Durazno escudo de llama seco|O|O||D||1
50325325|Durazno tipo plano seco|O|O||D||1
50325326|Durazno escudo de sabor seco|O|O||D||1
50325327|Durazno príncipe florida seco|O|O||D||1
50325328|Durazno luna llena seco|O|O||D||1
50325329|Durazno harvester seco|O|O||D||1
50325330|Durazno princesa de hielo seco|O|O||D||1
50325331|Durazno princesa de marfil seco|O|O||D||1
50325332|Durazno princesa reina jersey seco|O|O||D||1
50325333|Durazno john henry seco|O|O||D||1
50325334|Durazno príncipe de junio seco|O|O||D||1
50325335|Durazno kaweah seco|O|O||D||1
50325336|Durazno klondike seco|O|O||D||1
50325337|Durazno lindo seco|O|O||D||1
50325338|Durazno loring seco|O|O||D||1
50325339|Durazno majestuoso seco|O|O||D||1
50325340|Durazno o’henry seco|O|O||D||1
50325341|Durazno escudo de reina seco|O|O||D||1
50325342|Durazno dama roja seco|O|O||D||1
50325343|Durazno globo rojo seco|O|O||D||1
50325344|Durazno cielo rojo seco|O|O||D||1
50325345|Durazno redtop seco|O|O||D||1
50325346|Durazno regina seco|O|O||D||1
50325347|Durazno dama rica seco|O|O||D||1
50325348|Durazno mayo rico seco|O|O||D||1
50325349|Durazno gloria real seco|O|O||D||1
50325350|Durazno dama real seco|O|O||D||1
50325351|Durazno nieve de septiembre seco|O|O||D||1
50325352|Durazno sol de septiembre seco|O|O||D||1
50325353|Durazno gema sierra seco|O|O||D||1
50325354|Durazno angel de nieve seco|O|O||D||1
50325355|Durazno gema de nieve seco|O|O||D||1
50325356|Durazno rey de nieve seco|O|O||D||1
50325357|Durazno dama de primavera seco|O|O||D||1
50325358|Durazno nieve de primavera seco|O|O||D||1
50325359|Durazno escudo de primavera seco|O|O||D||1
50325360|Durazno dulce gigante seco|O|O||D||1
50325361|Durazno dama de azúcar seco|O|O||D||1
50325362|Durazno brillo de sol seco|O|O||D||1
50325363|Durazno sunhigh seco|O|O||D||1
50325364|Durazno dama super seco|O|O||D||1
50325365|Durazno super rico seco|O|O||D||1
50325366|Durazno surecrop seco|O|O||D||1
50325367|Durazno sueño dulce seco|O|O||D||1
50325368|Durazno septiembre dulce seco|O|O||D||1
50325369|Durazno vista seco|O|O||D||1
50325370|Durazno dama blanca seco|O|O||D||1
50325371|Durazno dama zee seco|O|O||D||1
50325400|Peras secas|O|O||D||1
50325401|Peras abate fetel seca|O|O||D||1
50325402|Peras anjou seca|O|O||D||1
50325403|Pera asiática seca|O|O||D||1
50325404|Pera bartlett seca|O|O||D||1
50325405|Pera best ever seca|O|O||D||1
50325406|Pera beth seca|O|O||D||1
50325407|Pera beurre seca|O|O||D||1
50325408|Pera bosc seca|O|O||D||1
50325409|Pera clapp favorita seca|O|O||D||1
50325410|Pera comice seca|O|O||D||1
50325411|Pera concorde seca|O|O||D||1
50325412|Pera conference seca|O|O||D||1
50325413|Pera crimson rojo seca|O|O||D||1
50325414|Peras d’ anjou seca|O|O||D||1
50325415|Pera dr jules guyot seca|O|O||D||1
50325416|Peras early seca|O|O||D||1
50325417|Peras emperador carmelito seca|O|O||D||1
50325418|Peras forelle seca|O|O||D||1
50325419|Pera mantequilla francesa seca|O|O||D||1
50325420|Pera glou morceau seca|O|O||D||1
50325421|Pera hosui seca|O|O||D||1
50325422|Pera mantequilla italiana seca|O|O||D||1
50325423|Pera jargonelle seca|O|O||D||1
50325424|Pera juno seca|O|O||D||1
50325425|Para kaiserlouise bonne de jersey seca|O|O||D||1
50325426|Pera keiffer seca|O|O||D||1
50325427|Pera rey royal seca|O|O||D||1
50325428|Pera limonera seca|O|O||D||1
50325429|Pera merton pride seca|O|O||D||1
50325430|Pera mauntain bartlette seca|O|O||D||1
50325431|Pera oliver de serrers seca|O|O||D||1
50325432|Pera onward seca|O|O||D||1
50325433|Pera packham´s triumph seca|O|O||D||1
50325434|Pera paraíso seca|O|O||D||1
50325435|Pera passe crassane seca|O|O||D||1
50325436|Pera perry seca|O|O||D||1
50325437|Pera bartlett rojo seca|O|O||D||1
50325438|Pera dánjou  rojo seca|O|O||D||1
50325439|Pera rocha seca|O|O||D||1
50325440|Pera rosey rojo seca|O|O||D||1
50325441|Pera rosy roja seca|O|O||D||1
50325442|Pera majestuosa royal seca|O|O||D||1
50325443|Pera ruby rojo seca|O|O||D||1
50325444|Pera santa maria seca|O|O||D||1
50325445|Pera seckel seca|O|O||D||1
50325446|Pera sensación seca|O|O||D||1
50325447|Pera crimson estrella seca|O|O||D||1
50325448|Pera crimson stark seca|O|O||D||1
50325449|Pera bartlette de verano seca|O|O||D||1
50325450|Pera verano dorado seca|O|O||D||1
50325451|Pera sol dorado seca|O|O||D||1
50325452|Pera sunprite seca|O|O||D||1
50325453|Pera taylors dorado seca|O|O||D||1
50325454|Pera taylors rojo seca|O|O||D||1
50325455|Pera tientsin seca|O|O||D||1
50325456|Pera tosca seca|O|O||D||1
50325457|Pera warden  seca|O|O||D||1
50325458|Pera williams bon chretien seca|O|O||D||1
50325459|Pera williams seca|O|O||D||1
50325460|Pera nelis de invierno seca|O|O||D||1
50325500|Caquis secos|O|O||D||1
50325501|Caqui americano seca|O|O||D||1
50325502|Caqui sapote negro seca|O|O||D||1|Caqui zapote negro seco
50325503|Caqui chapote / negro seca|O|O||D||1
50325504|Caqui dátale ciruela seca|O|O||D||1
50325505|Caqui fuyu seca|O|O||D||1
50325506|Caqui gigante fuyu seca|O|O||D||1
50325507|Caqui hachiya seca|O|O||D||1
50325508|Caqui mantequilla / mabolo seca|O|O||D||1
50325509|Caqui príncipe ito seca|O|O||D||1
50325510|Caqui brillante royal seca|O|O||D||1
50325511|Caqui sharon seca|O|O||D||1
50325512|Caqui triumph seca|O|O||D||1
50325600|Piñas secas|O|O||D||1
50325601|Piña chirimoya seca|O|O||D||1|Atemoya seca
50325602|Piña dorada seca|O|O||D||1
50325603|Piña hilo seca|O|O||D||1
50325604|Piña kona sugarloaf seca|O|O||D||1
50325605|Piña reina natal seca|O|O||D||1
50325606|Piña pernabuco seca|O|O||D||1
50325607|Piña español rojo seca|O|O||D||1
50325608|Piña cayen suave seca|O|O||D||1
50325609|Piña sugarloaf seca|O|O||D||1
50325610|Piña variegated seca|O|O||D||1
50325700|Ciruelos Damascos secos|O|O||D||1
50325701|Ciruelo / damasco negro kat seco|O|O||D||1
50325702|Ciruelo / damasco gusto azul seco|O|O||D||1
50325703|Ciruelo / damasco corazón de crimson seco|O|O||D||1
50325704|Ciruelo / damasco dapply dandy seco|O|O||D||1
50325705|Ciruelo / damasco dapple fuego seco|O|O||D||1
50325706|Ciruelo / damasco  dapple temprano seco|O|O||D||1
50325707|Ciruelo / damasco  caída de sabor seco|O|O||D||1
50325708|Ciruelo / damasco sabor de oro seco|O|O||D||1
50325709|Ciruelo / damasco sabor granada seco|O|O||D||1
50325710|Ciruelo / damasco sabor de corazón seco|O|O||D||1
50325711|Ciruelo / damasco joya de sabor seco|O|O||D||1
50325712|Ciruelo / damasco sabor de rey seco|O|O||D||1
50325713|Ciruelo / damasco sabor de reina seco|O|O||D||1
50325714|Ciruelo / damasco sabor supremo seco|O|O||D||1
50325715|Ciruelo / damasco sabor premio seco|O|O||D||1
50325716|Ciruelo / damasco saborella seco|O|O||D||1
50325717|Ciruelo / damasco saborrico seco|O|O||D||1
50325718|Ciruelo / damasco  sabor rosa seco|O|O||D||1
50325719|Ciruelo / damasco orgullo geo seco|O|O||D||1
50325720|Ciruelo / damasco kat rojo seco|O|O||D||1
50325721|Ciruelo / damasco premio royal seco|O|O||D||1
50325722|Ciruelo / damasco rosa sierra seco|O|O||D||1
50325723|Ciruelo / damasco geisha dulce seco|O|O||D||1
50325800|Ciruelas secas|O|O||D||1
50325801|Ciruela joya amber seca|O|O||D||1
50325802|Ciruela angeleno seca|O|O||D||1
50325803|Ciruela aurora seca|O|O||D||1
50325804|Ciruela otoño bonito seca|O|O||D||1
50325805|Ciruela gigante de otoño seca|O|O||D||1
50325806|Ciruela orgullo de otoño seca|O|O||D||1
50325807|Ciruela rosa de otoño seca|O|O||D||1
50325808|Ciruela playero seca|O|O||D||1
50325809|Ciruela betty anne seca|O|O||D||1
50325810|Ciruela belleza negra seca|O|O||D||1
50325811|Ciruela bullase negra seca|O|O||D||1
50325812|Ciruela diamante negro seca|O|O||D||1
50325813|Ciruela gigante negro seca|O|O||D||1
50325814|Ciruela hielo negro seca|O|O||D||1
50325815|Ciruela esplendor negro seca|O|O||D||1
50325816|Ciruela ámbar negro seca|O|O||D||1
50325817|Ciruela vino tinto seca|O|O||D||1
50325818|Ciruela  carlsbad seca|O|O||D||1
50325819|Ciruela casselman seca|O|O||D||1
50325820|Ciruela catalina seca|O|O||D||1
50325821|Ciruela damson seca|O|O||D||1
50325822|Ciruela dolly seca|O|O||D||1
50325823|Ciruela earlireina seca|O|O||D||1
50325824|Ciruela rosa early seca|O|O||D||1
50325825|Ciruela ébano mayo seca|O|O||D||1
50325826|Ciruela ébano seca|O|O||D||1
50325827|Ciruela corazón de elefante seca|O|O||D||1
50325828|Ciruela belleza de esmeralda seca|O|O||D||1
50325829|Ciruela emperatriz seca|O|O||D||1
50325830|Ciruela libertad seca|O|O||D||1
50325831|Ciruela friar seca|O|O||D||1
50325832|Ciruela rojo gar seca|O|O||D||1
50325833|Ciruela gobernador seca|O|O||D||1
50325834|Ciruela rosa grande seca|O|O||D||1
50325835|Ciruela green gage seca|O|O||D||1|Ciruela calibre verde seca
50325836|Ciruela greengage seca|O|O||D||1
50325837|Ciruela hiromi seca|O|O||D||1
50325838|Ciruela hiromi rojo seca|O|O||D||1
50325839|Ciruela vacacion seca|O|O||D||1
50325840|Ciruela howard sol seca|O|O||D||1
50325841|Ciruela tipo interspecific seca|O|O||D||1
50325842|Ciruela jamaico seca|O|O||D||1
50325843|Ciruela joanna rojo seca|O|O||D||1
50325844|Ciruela kelsey seca|O|O||D||1
50325845|Ciruela jaime rey seca|O|O||D||1
50325846|Ciruela laroda seca|O|O||D||1
50325847|Ciruela rosa tarde seca|O|O||D||1
50325848|Ciruela rosa linda seca|O|O||D||1
50325849|Ciruela estrella solitaria seca|O|O||D||1
50325850|Ciruela mariposa seca|O|O||D||1
50325851|Ciruela mercado negro seca|O|O||D||1
50325852|Ciruela mercado rojo seca|O|O||D||1
50325853|Ciruela maribel seca|O|O||D||1
50325854|Ciruelas sol de octubre seca|O|O||D||1
50325855|Ciruela owen t seca|O|O||D||1
50325856|Ciruela perdrigon seca|O|O||D||1
50325857|Ciruela placer rosado seca|O|O||D||1
50325858|Ciruela  presidente seca|O|O||D||1
50325859|Ciruela hora prima seca|O|O||D||1|Ciruela prime time seca
50325860|Ciruela majestad purpura seca|O|O||D||1
50325861|Ciruela reina rosa seca|O|O||D||1
50325862|Ciruela quetsch seca|O|O||D||1
50325863|Ciruela belleza roja seca|O|O||D||1
50325864|Ciruela camino rojo seca|O|O||D||1
50325865|Ciruela ram rojo seca|O|O||D||1
50325866|Ciruela rosa roja seca|O|O||D||1
50325867|Ciruela rojo rico seca|O|O||D||1
50325868|Ciruela romaro seca|O|O||D||1
50325869|Ciruela diamante rojo seca|O|O||D||1
50325870|Ciruela rojo royal seca|O|O||D||1
50325871|Ciruela royal zee seca|O|O||D||1
50325872|Ciruela roysum seca|O|O||D||1
50325873|Ciruela santa rosa seca|O|O||D||1
50325874|Ciruela zafiro seca|O|O||D||1
50325875|Ciruela sloe seca|O|O||D||1
50325876|Ciruela sta catherine seca|O|O||D||1
50325877|Ciruela bullase blanco seca|O|O||D||1
50325900|Granadas secas|O|O||D||1
50325901|Granada foothhill seca|O|O||D||1
50325902|Granada, granada seca|O|O||D||1|Granada seca
50325903|Granada rojo feliz seca|O|O||D||1
50325904|Granada nana seca|O|O||D||1
50325905|Granada rojo de pat seca|O|O||D||1
50325906|Granada pinkhan sec|O|O||D||1
50325907|Granada terciopelo morado seca|O|O||D||1
50325908|Granada grandioso seca|O|O||D||1
50326000|Pomelos secos|O|O||D||1
50326001|Pomelo chandler seco|O|O||D||1
50326002|Pomelo hirado butan seco|O|O||D||1
50326003|Pomelo liang ping yau seco|O|O||D||1
50326004|Pomelo panda wangi seco|O|O||D||1
50326005|Pomelo rosado seco|O|O||D||1
50326006|Pomelo shaddock rojo seco|O|O||D||1
50326007|Pomelo siamese dulce seco|O|O||D||1
50326008|Pomelo waingwright seco|O|O||D||1
50326100|Membrillos secos|O|O||D||1
50326101|Membrillo campeón seco|O|O||D||1
50326102|Membrillo piña seco|O|O||D||1
50326103|Membrillo smyma seco|O|O||D||1
50326200|Frambuesas secas|O|O||D||1
50326201|Frambuesa americana roja seca|O|O||D||1
50326202|Frambuesa bailey reinasland seca|O|O||D||1
50326203|Frambuesa negra seca|O|O||D||1
50326204|Frambuesa oscura seca|O|O||D||1
50326205|Frambuesa deliciosa seca|O|O||D||1
50326206|Frambuesa enano focke seca|O|O||D||1
50326207|Frambuesa focke hojagris seca|O|O||D||1
50326208|Frambuesa focke fresa seca|O|O||D||1
50326209|Frambuesa  focke amarillo himalaya seca|O|O||D||1
50326210|Frambuesa dorado sec|O|O||D||1
50326211|Frambuesa gris nuevo mexico seca|O|O||D||1
50326212|Frambuesa jepson blancobark seca|O|O||D||1
50326213|Frambuesa kellogs san diego seca|O|O||D||1
50326214|Frambuesa leucodemis blancobark seca|O|O||D||1
50326215|Frambuesa munz cuyamaca seca|O|O||D||1
50326216|Frambuesa peck bartons seca|O|O||D||1
50326217|Frambuesa flor morada seca|O|O||D||1
50326218|Frambuesa roadside seca|O|O||D||1
50326219|Frambuesa san diego seca|O|O||D||1
50326220|Frambuesa nieve seca|O|O||D||1
50326221|Frambuesa pico de nieve seca|O|O||D||1
50326222|Frambuesa hoja de fresa seca|O|O||D||1
50326223|Frambuesa cultivo dulce seca|O|O||D||1
50326224|Frambuesa tor y gris blancobark seca|O|O||D||1
50326225|Frambuesa caribe seca|O|O||D||1
50326226|Frambuesa blancobark seca|O|O||D||1
50326227|Frambuesa vino seca|O|O||D||1
50326228|Frambuesa himalaya amarillo seca|O|O||D||1
50326229|Frambuesa yu-shan seca|O|O||D||1
50326300|Ruibarbos secos|O|O||D||1|Acelgas rojas secas
50326301|Ruibarbo crimson rojo seco|O|O||D||1|Acelga roja crimson seca
50326302|Ruibarbo champagne temprana seco|O|O||D||1|Acelga roja champagne temprana seca
50326303|Ruibarbo glasrey perpetual  seco|O|O||D||1|Acelga roja glasrey perpetual seca
50326304|Ruibarbo sutton seco|O|O||D||1|Acelga roja sutton seca
50326305|Ruibarbo timperley temprano seco|O|O||D||1|Acelga roja temprana de Timperley seca
50326306|Ruibarbo valentina seco|O|O||D||1|Acelga roja valentina seca
50326307|Ruibarbo victoria seco|O|O||D||1|Acelga roja victoria seca
50326308|Ruibarbo zwolle de cemilla seco|O|O||D||1|Acelga roja zwolle de semilla seca
50326309|Ruibarbo macdonald seco|O|O||D||1|Acelga roja macdonald seca
50326310|Ruibarbo tilden seco|O|O||D||1|Acelga roja tilden seca
50326400|Escaramujos secos|O|O||D||1|Rosa mosqueta secas
50326401|Escaramujo rosa brier seco|O|O||D||1|Rosa mosqueta brier seca
50326402|Escaramujo rosa elegante seco|O|O||D||1|Rosa mosqueta elegante seca
50326403|Escaramujo rosa rugosa seco|O|O||D||1|Rosa mosqueta rugosa seca
50326404|Escaramujo rosa burnet o scotch seco|O|O||D||1|Rosa mosqueta burnet o scotch seca
50326500|Sapotes secos|O|O||D||1|Zapotes secos
50326501|Sapote blanco seco|O|O||D||1|Zapote blanco seco
50326502|Sapote negro seco|O|O||D||1|Zapote negro seco
50326600|Bayas saskatoon secas|O|O||D||1|Fresas de junio secas
50326601|Baya mielmadera saskatoon seca|O|O||D||1|Fresa de junio mielmadera seca
50326602|Baya northline saskatoon seca|O|O||D||1|Fresa de junio northline seca
50326603|Baya saskatoon ahumado seca|O|O||D||1|Fresa de junio smoky seca
50326604|Baya saskatoon thiessen seca|O|O||D||1|Fresa de junio thiessen seca
50326700|Fresas secas|O|O||D||1
50326701|Fresa chandler seca|O|O||D||1
50326702|Fresa rumbo junio seca|O|O||D||1|Fresa temporada de junio seca
50326703|Fresa rumbo siempre seca|O|O||D||1|Fresa de todo el año seca
50326800|Manzanas dulces secas|O|O||D||1|Saramuyos secos
50326801|Manzana kampong malve dulce seca|O|O||D||1|Saramuyo kampong mauve seco
50326802|Manzana dulce sin pepa seca|O|O||D||1|Saramuyo sin semilla seco
50326803|Manzana dulce thai lessand seca|O|O||D||1|Saramuyo thai lessand seco
50326900|Tamarillos secos|O|O||D||1|Tomates de árbol secos
50326901|Tamarindo amberlea dorado seco|O|O||D||1|Tomate de árbol amberlea dorado seco
50326902|Tamarindo calvo dorado seco|O|O||D||1|Tomate de árbol calvo dorado seco
50326903|Tamarindo mina de oro seco|O|O||D||1|Tomate de árbol mina de oro seco
50326904|Tamarindo oratia rojo seco|O|O||D||1|Tomate de árbol oratia rojo seco
50326905|Tamarindo beau rojo seco|O|O||D||1|Tomate de árbol beau rojo seco
50326906|Tamarindo delicia roja seco|O|O||D||1|Tomate de árbol delicia roja seco
50327000|Frutas Nominant secas|O|O||D||1|Frutas predominantes secas
50327001|Cupania seca|O|O||D||1|Ackee seca
50327002|Babaco seco|O|O||D||1|Carica pentágona seca
50327003|Banana flor seca|O|O||D||1|Flor de plátano seca
50327004|Baobab seca|O|O||D||1
50327005|Naranja agria seca|O|O||D||1
50327006|Canistel seca|O|O||D||1|Zapote amarillo seco
50327007|Baya nublosa seca|O|O||D||1|Mora de los pantanos seca
50327008|Coco seco|O|O||D||1
50327009|Baya drew seca|O|O||D||1|Baya de gota seca
50327010|Durian seca|O|O||D||1|Durio seco
50327011|Baya elder seca|O|O||D||1|Baya de sauco seca
50327012|Feijoa seca|O|O||D||1|Guayabo del Brasil seco
50327013|Mora seca|O|O||D||1
50327014|Cretaegus seca|O|O||D||1|Majuelo seco
50327015|Baya miel seca|O|O||D||1|Madreselva azul seca
50327016|Jaca seca|O|O||D||1|Yaca seca
50327017|Jambolan seca|O|O||D||1
50327018|Jujube seca|O|O||D||1|Azufaifa seca
50327019|Liches secos|O|O||D||1|Lichi seco
50327020|Mangostinos secos|O|O||D||1|Mangostán seco
50327021|Medlar seca|O|O||D||1
50327022|Mombines seca|O|O||D||1|Hobo seco
50327023|Monstera seca|O|O||D||1|Cerimán seco
50327024|Pepinos seco|O|O||D||1|Pepino dulce seco
50327025|Platono seco|O|O||D||1|Plátano macho seco
50327026|Peras en escabeche seca|O|O||D||1|Tuna seca
50327027|Mamonsillo seco|O|O||D||1|Guaya seca
50327028|Rambután seco|O|O||D||1|Achotillo seco
50327029|Manzana rosa seca|O|O||D||1|Pero de agua seco
50327030|Rosele seca|O|O||D||1|Flor de jamaica seca
50327031|Baya rowan seca|O|O||D||1|Serba seca
50327032|Baya buckhom de mar seca|O|O||D||1|Espino amarillo seco
50327033|Baya plata seca|O|O||D||1|Olivo de otoño seco
50327034|Baya sorbete seco|O|O||D||1|Serba seca
50327035|Guanabana seca|O|O||D||1
50327036|Manzana estrella seca|O|O||D||1|Cainito seco
50327037|Tamarindo seco|O|O||D||1
50327100|Aronias secas|O|O||D||1
50327101|Aronia magia de otoño seca|O|O||D||1
50327102|Aronia brillantísima seca|O|O||D||1
50327103|Aronia nero seca|O|O||D||1
50327104|Aronia viquingo seca|O|O||D||1
50327200|Aceitunas secas|O|O||D||1
50327201|Aceitunas agrinion seca|O|O||D||1|Aceituna agrinion seca
50327202|Aceitunas aleppo seca|O|O||D||1|Aceituna aleppo seca
50327203|Aceitunas  alfonso seca|O|O||D||1|Aceituna alfonso seca
50327204|Aceitunas  amfisa seca|O|O||D||1|Aceituna amfisa seca
50327205|Aceitunas  arauco seca|O|O||D||1|Aceituna arauco seca
50327206|Aceitunas  arbequina seca|O|O||D||1|Aceituna arbequina seca
50327207|Aceitunas  atlanta seca|O|O||D||1|Aceituna atlanta seca
50327208|Aceitunas  cerignola seca|O|O||D||1|Aceituna cerignola seca
50327209|Aceitunas  cracked provencal seca|O|O||D||1|Aceituna cracked provencal seca
50327210|Aceitunas  empeltre seca|O|O||D||1|Aceituna empeltre seca
50327211|Aceitunas gaeta  seca|O|O||D||1|Aceituna gaeta seca
50327212|Aceitunas hondoelia seca|O|O||D||1|Aceituna hondoelia seca
50327213|Aceitunas kalamata seca|O|O||D||1|Aceituna kalamata seca
50327214|Aceitunas kura seca|O|O||D||1|Aceituna kura seca
50327215|Aceitunas ligurian seca|O|O||D||1|Aceituna ligurian seca
50327216|Aceitunas lucque seca|O|O||D||1|Aceituna lucque seca
50327217|Aceitunas lugano seca|O|O||D||1|Aceituna lugano seca
50327218|Aceitunas manzanilla seca|O|O||D||1|Aceituna manzanilla seca
50327219|Aceitunas marche seca|O|O||D||1|Aceituna marche seca
50327220|Aceitunas misión seca|O|O||D||1|Aceituna misión seca
50327221|Aceitunas nafplion verde seca|O|O||D||1|Aceituna nafplion verde seca
50327222|Aceitunas nicoise seca|O|O||D||1|Aceituna nicoise seca
50327223|Aceitunas nyons seca|O|O||D||1|Aceituna nyons seca
50327224|Aceitunas picholine seca|O|O||D||1|Aceituna picholine seca
50327225|Aceitunas ponentine seca|O|O||D||1|Aceituna ponentine seca
50327226|Aceitunas royal seca|O|O||D||1|Aceituna royal seca
50327227|Aceitunas seracena seca|O|O||D||1|Aceituna seracena seca
50327228|Aceitunas sevillano seca|O|O||D||1|Aceituna sevillano seca
50327229|Aceitunas sicilian seca|O|O||D||1|Aceituna sicilian seca
50327230|Aceitunas toscanella seca|O|O||D||1|Aceituna toscanella seca
50331500|Manzanas orgánicas secas|O|O||D||1
50331501|Manzanas akane orgánicas secas|O|O||D||1|Manzana akane orgánicas secas
50331502|Manzana ambrosia orgánicas seca|O|O||D||1
50331503|Manzanas api orgánicas secas|O|O||D||1|Manzana api orgánicas secas
50331504|Manzanas baldwin orgánicas secas|O|O||D||1|Manzana baldwin orgánicas secas
50331505|Manzanas brabum orgánicas secas|O|O||D||1|Manzana brabum orgánicas secas
50331506|Manzanas bramley orgánicas secas|O|O||D||1|Manzana bramley orgánicas secas
50331507|Manzana joven bramley orgánic|O|O||D||1
50331508|Manzana calville blanche d’hiver orgánic|O|O||D||1
50331509|Manzana cameo orgánicas seca|O|O||D||1
50331510|Manzana charles ross orgánicas seca|O|O||D||1
50331511|Manzana codlin orgánicas seca|O|O||D||1
50331512|Manzana cortland orgánicas seca|O|O||D||1
50331513|Manzana costard orgánicas seca|O|O||D||1
50331514|Manzana court pendu plat orgánicas seca|O|O||D||1
50331515|Manzana  cox´s orange pippin orgánicas seca|O|O||D||1
50331516|Manzana crab orgánicas seca|O|O||D||1
50331517|Manzana crispin orgánicas seca|O|O||D||1
50331518|Manzana delicious orgánicas seca|O|O||D||1
50331519|Manzana duchess orgánicas seca|O|O||D||1
50331520|Manzana earligold orgánicas seca|O|O||D||1
50331521|Manzana early mcintosh orgánicas seca|O|O||D||1
50331522|Manzana elstar orgánicas seca|O|O||D||1
50331523|Manzana empire orgánicas seca|O|O||D||1
50331524|Manzana flower of kent orgánicas seca|O|O||D||1
50331525|Manzana fiji orgánicas seca|O|O||D||1
50331526|Manzana gala orgánicas seca|O|O||D||1
50331527|Manzana gascoyne´s scarlet orgánicas seca|O|O||D||1
50331528|Manzana gillyflower orgánicas seca|O|O||D||1
50331529|Manzana ginger gold orgánicas seca|O|O||D||1
50331530|Manzana gladstone orgánicas seca|O|O||D||1
50331531|Manzana gloster orgánicas seca|O|O||D||1
50331532|Manzana gold supreme orgánicas seca|O|O||D||1
50331533|Manzana dorado delicious orgánicas seca|O|O||D||1
50331534|Manzana dorado nobel orgánicas seca|O|O||D||1
50331535|Manzana granny smith orgánicas seca|O|O||D||1
50331536|Manzana gravenstain orgánicas seca|O|O||D||1
50331537|Manzana greening orgánicas seca|O|O||D||1
50331538|Manzana greensleeves orgánicas seca|O|O||D||1
50331539|Manzana honeycrisp orgánicas seca|O|O||D||1
50331540|Manzana howgate wonder orgánicas seca|O|O||D||1
50331541|Manzana roja ida orgánicas seca|O|O||D||1
50331542|Manzana james grives orgánicas seca|O|O||D||1
50331543|Manzana jersey mac orgánicas seca|O|O||D||1
50331544|Manzana jaster orgánicas seca|O|O||D||1
50331545|Manzana jonagold orgánicas seca|O|O||D||1
50331546|Manzana jonamac orgánicas seca|O|O||D||1
50331547|Manzana  jonathan  orgánicas seca|O|O||D||1
50331548|Manzana katy orgánicas seca|O|O||D||1
50331549|Manzana kidd´s orange roja orgánicas seca|O|O||D||1
50331550|Manzana lady orgánicas seca|O|O||D||1
50331551|Manzana law roma orgánicas seca|O|O||D||1
50331552|Manzana laxton orgánicas seca|O|O||D||1
50331553|Manzana lord derby orgánicas seca|O|O||D||1
50331554|Manzana macoun  orgánicas seca|O|O||D||1
50331555|Manzana mcintosh orgánicas seca|O|O||D||1
50331556|Manzana mutsu orgánicas seca|O|O||D||1
50331557|Manzana newtown pippin orgánicas seca|O|O||D||1
50331558|Manzana northen spy orgánicas seca orgánicas seca|O|O||D||1
50331559|Manzana orleans reinette orgánicas seca|O|O||D||1
50331560|Manzana ozark gold orgánicas seca|O|O||D||1
50331561|Manzana pacific rose orgánicas seca|O|O||D||1
50331562|Manzana paula roja orgánicas seca|O|O||D||1
50331563|Manzana peamain orgánicas seca|O|O||D||1
50331564|Manzana pink lady orgánicas seca|O|O||D||1
50331565|Manzana pippin orgánicas seca|O|O||D||1
50331566|Manzana pitmaston pineapple orgánicas seca|O|O||D||1
50331567|Manzana pomme dápi orgánicas seca|O|O||D||1
50331568|Manzana prime gold orgánicas seca|O|O||D||1
50331569|Manzana roja astrakhan orgánicas seca|O|O||D||1
50331570|Manzana roja boscoop orgánicas seca|O|O||D||1
50331571|Manzana  roja chief orgánicas seca|O|O||D||1
50331572|Manzana roja delicious orgánicas seca|O|O||D||1
50331573|Manzana roja grvenstain orgánicas seca|O|O||D||1
50331574|Manzana re roma orgánicas seca|O|O||D||1
50331575|Manzanaroja stayman orgánicas seca|O|O||D||1
50331576|Manzana roja york orgánicas seca|O|O||D||1
50331577|Manzana reinette orgánicas seca|O|O||D||1
50331578|Manzana roma beuty orgánicas seca|O|O||D||1
50331579|Manzana russet orgánicas seca|O|O||D||1
50331580|Manzana sierra beaty orgánicas seca|O|O||D||1
50331581|Manzana spartan orgánicas seca|O|O||D||1
50331582|Manzana stark crimson orgánicas seca|O|O||D||1
50331583|Manzana starrey orgánicas seca|O|O||D||1
50331584|Manzana stayman orgánicas seca|O|O||D||1
50331585|Manzana stayman winesap orgánicas seca|O|O||D||1
50331586|Manzana summer rambo orgánicas seca|O|O||D||1
50331587|Manzana tsugaru orgánicas seca|O|O||D||1
50331588|Manzana twenty ounce orgánicas seca|O|O||D||1
50331589|Manzana tydeman roja orgánicas seca|O|O||D||1
50331590|Manzana vistabella orgánicas seca|O|O||D||1
50331591|Manzana weatley orgánicas seca|O|O||D||1
50331592|Manzana blanco joanetine orgánicas seca|O|O||D||1
50331593|Manzana blanco transparent orgánicas seca|O|O||D||1
50331594|Manzana winesap orgánicas seca|O|O||D||1
50331595|Manzana worcester orgánicas seca|O|O||D||1
50331596|Manzana york imperial orgánicas seca|O|O||D||1
50331600|Albaricoques orgánicos secos|O|O||D||1|Chabacanos orgánicos secos
50331601|Abaricoques ambercot orgánicas seca|O|O||D||1|Chabacano ambercot orgánico seco
50331602|Albaricoques apache orgánicas seca|O|O||D||1|Chabacano apache orgánico seco
50331603|Albaricoques brittany gold orgánicas seca|O|O||D||1|Chabacano brittany gold orgánico seco
50331604|Albaricoque negro orgánicas seca|O|O||D||1|Chabacano negro orgánico seco
50331605|Albaricoque blenheim orgánicas seca|O|O||D||1|Chabacano blenheim orgánico seco
50331606|Albaricoque bonny orgánicas seca|O|O||D||1|Chabacano bonny orgánico seco
50331607|Albaricoque biluda orgánicas seca|O|O||D||1|Chabacano biluda orgánico seco
50331608|Albaricoque castlebrite orgánicas seca|O|O||D||1|Chabacano castlebrite orgánico seco
50331609|Albaricoque  clutha gold orgánicas seca|O|O||D||1|Chabacano clutha gold orgánico seco
50331610|Albaricoque clutha sun orgánicas seca|O|O||D||1|Chabacano clutha sun orgánico seco
50331611|Albaricoque derby royal orgánicas seca|O|O||D||1|Chabacano derby royal orgánico seco
50331612|Albaricoque dina orgánicas seca|O|O||D||1|Chabacano dina orgánico seco
50331613|Albaricoque earlicot orgánicas seca|O|O||D||1|Chabacano earlicot orgánico seco
50331614|Albaricoque earliman orgánicas seca|O|O||D||1|Chabacano earliman orgánico seco
50331615|Albaricoque early bright orgánicas seca|O|O||D||1|Chabacano early bright orgánico seco
50331616|Albaricoque  flaming gold orgánicas seca|O|O||D||1|Chabacano flaming gold orgánico seco
50331617|Albaricoque frenso orgánicas seca|O|O||D||1|Chabacano frenso orgánico seco
50331618|Albaricoque gold bright orgánicas seca|O|O||D||1|Chabacano gold bright orgánico seco
50331619|Albaricoque goldbar orgánicas seca|O|O||D||1|Chabacano goldbar orgánico seco
50331620|Albaricoque dorado sweet orgánicas seca|O|O||D||1|Chabacano dorado sweet orgánico seco
50331621|Albaricoque goldrich orgánicas seca|O|O||D||1|Chabacano goldrich orgánico seco
50331622|Albaricoque helena orgánicas seca|O|O||D||1|Chabacano helena orgánico seco
50331623|Albaricoque honeycot orgánicas seca|O|O||D||1|Chabacano  orgánico seco
50331624|Albaricoque imperial orgánicas seca|O|O||D||1|Chabacano imperial orgánico seco
50331625|Albaricoque jordanne orgánicas seca|O|O||D||1|Chabacano jordanne orgánico seco
50331626|Albaricoque jumbo cot orgánicas seca|O|O||D||1|Chabacano jumbo cot orgánico seco
50331627|Albaricoque kandy kot orgánicas seca|O|O||D||1|Chabacano kandy kot orgánico seco
50331628|Albaricoque katy orgánicas seca|O|O||D||1|Chabacano katy orgánico seco
50331629|Albaricoque rey orgánicas seca|O|O||D||1|Chabacano rey orgánico seco
50331630|Albaricoque lambertin orgánicas seca|O|O||D||1|Chabacano lambertin orgánico seco
50331631|Albaricoque loma orgánicas seca|O|O||D||1|Chabacano loma orgánico seco
50331632|Albaricoque lulu belle orgánicas seca|O|O||D||1|Chabacano lulu belle orgánico seco
50331633|Albaricoque modesto orgánicas seca|O|O||D||1|Chabacano modesto orgánico seco
50331634|Albaricoque moorpark orgánicas seca|O|O||D||1|Chabacano moorpark orgánico seco
50331635|Albaricoque orangeroja orgánicas seca|O|O||D||1|Chabacano orange red orgánico seco
50331636|Albaricoque palstein orgánicas seca|O|O||D||1|Chabacano palstein orgánico seco
50331637|Albaricoque patterson orgánicas seca|O|O||D||1|Chabacano patterson orgánico seco
50331638|Albaricoque perfection orgánicas seca|O|O||D||1|Chabacano perfection orgánico seco
50331639|Albaricoque poppy orgánicas seca|O|O||D||1|Chabacano poppy orgánico seco
50331640|Albaricoque poppycot orgánicas seca|O|O||D||1|Chabacano poppy cot orgánico seco
50331641|Albaricoque reina orgánicas seca|O|O||D||1|Chabacano reina orgánico seco
50331642|Albaricoque riland orgánicas seca|O|O||D||1|Chabacano riland orgánico seco
50331643|Albaricoque rival orgánicas seca|O|O||D||1|Chabacano rival orgánico seco
50331644|Albaricoque robada orgánicas seca|O|O||D||1|Chabacano robada orgánico seco
50331645|Albaricoque royal orgánicas seca|O|O||D||1|Chabacano royal orgánico seco
50331646|Albaricoque  royal blenheim orgánicas seca|O|O||D||1|Chabacano royal blenheim orgánico seco
50331647|Albaricoque  royal orange orgánicas seca|O|O||D||1|Chabacano royal orange orgánico seco
50331648|Albaricoque sundrop orgánicas seca|O|O||D||1|Chabacano sundrop orgánico seco
50331649|Albaricoque tilton orgánicas seca|O|O||D||1|Chabacano tilton orgánico seco
50331650|Albaricoque tomcot orgánicas seca|O|O||D||1|Chabacano tomcot orgánico seco
50331651|Albaricoque tracy orgánicas seca|O|O||D||1|Chabacano tracy orgánico seco
50331652|Albaricoque tri gem orgánicas seca|O|O||D||1|Chabacano tri gem orgánico seco
50331653|Albaricoque valley gold orgánicas seca|O|O||D||1|Chabacano valley gold orgánico seco
50331654|Albaricoque westley orgánicas seca|O|O||D||1|Chabacano westley orgánico seco
50331655|Albaricoque  york orgánicas seca|O|O||D||1|Chabacano york orgánico seco
50331700|Bananos orgánicos secos|O|O||D||1|Plátanos orgánicos secos
50331701|Banana manzana orgánicas seca|O|O||D||1|Plátano apple orgánico seco
50331702|Banana bebe orgánicas seca|O|O||D||1|Plátano bebe orgánico seco
50331703|Banana burro orgánicas seca|O|O||D||1|Plátano burro orgánico seco
50331704|Bananas cavendish orgánicas seca|O|O||D||1|Plátano cavendish orgánico seco
50331705|Bananas dominico orgánicas seca|O|O||D||1|Plátano dominico orgánico seco
50331706|Bananas green orgánicas seca|O|O||D||1|Plátano green orgánico seco
50331707|Bananas gros michel orgánicas seca|O|O||D||1|Plátano gros michel orgánico seco
50331708|Bananas lacatan orgánicas seca|O|O||D||1|Plátano lacatan orgánico seco
50331709|Bananas dedo de dama orgánicas seca|O|O||D||1|Plátano dedo de dama orgánico seco
50331710|Bananas manzano orgánicas seca|O|O||D||1|Plátano manzano orgánico seco
50331711|Banana mysore orgánicas seca|O|O||D||1|Plátano mysore orgánico seco
50331712|Banana pisang mas orgánicas seca|O|O||D||1|Plátano pisang mas orgánico seco
50331713|Bananas roja orgánicas seca|O|O||D||1|Plátano roja orgánico seco
50331714|Bananas saba orgánicas seca|O|O||D||1|Plátano saba orgánico seco
50331715|Bananas sucrier orgánicas seca|O|O||D||1|Plátano sucrier orgánico seco
50331800|Barberries orgánicos secos|O|O||D||1|Berberís orgánicos secos
50331801|Berberís paleleaf orgánicas seca|O|O||D||1|Berberí paleleaf orgánico seco
50331802|Barberís chenault orgánicas seca|O|O||D||1|Berberí chenault orgánico seco
50331803|Barberís roja orgánicas seca|O|O||D||1|Berberí roja orgánico seco
50331804|Barberís wintergreen orgánicas seca|O|O||D||1|Berberí wintergreen orgánico seco
50331805|Barberís korean orgánicas seca|O|O||D||1|Berberí korean orgánico seco
50331806|Barberís mentor orgánicas seca|O|O||D||1|Berberí mentor orgánico seco
50331807|Barberís japanese orgánicas seca|O|O||D||1|Berberí japanese orgánico seco
50331808|Barberís atropurpurea orgánicas secas|O|O||D||1|Berberí atropurpurea orgánico secos
50331809|Barberís aurea orgánicas secas|O|O||D||1|Berberí aurea orgánico secos
50331810|Barberís bagatelle orgánicas secas|O|O||D||1|Berberí bagatelle orgánico secos
50331811|Barberís crimsom pygmy orgánicas secas|O|O||D||1|Berberí crimsom pygmy orgánico secos
50331812|Barberís kobold orgánicas secas|O|O||D||1|Berberí kobold orgánico secos
50331813|Barberís warty orgánicas secas|O|O||D||1|Berberí warty orgánico secos
50331814|Barberís european orgánicas secas|O|O||D||1|Berberí european orgánico secos
50331900|Gayubas orgánicas secas|O|O||D||1|Rastreras orgánicas secas
50331901|Gayuba alpine orgánicas secas|O|O||D||1|Rastrera alpine orgánicas secas
50331902|Gayuba roja orgánicas secas|O|O||D||1|Rastrera roja orgánicas secas
50331903|Gayuba comun orgánicas secas|O|O||D||1|Rastrera común orgánicas secas
50332000|Moras orgánicas secas|O|O||D||1|Zarzamoras orgánicas secas
50332001|Mora apache orgánicas secas|O|O||D||1|Zarzamora apache orgánicas secas
50332002|Mora negro satin orgánicas secas|O|O||D||1|Zarzamora negro satín orgánicas secas
50332003|Mora orgánicas secas|O|O||D||1|Zarzamora orgánicas secas
50332004|Mora cherokee orgánicas secas|O|O||D||1|Zarzamora cherokee orgánicas secas
50332005|Mora chester orgánicas secas|O|O||D||1|Zarzamora chéster orgánicas secas
50332006|Mora dirksen orgánicas secas|O|O||D||1|Zarzamora dirksen orgánicas secas
50332007|Bayasjosta orgánicas secas|O|O||D||1|Zarzamora josta orgánicas secas
50332008|Bayaslogan orgánicas secas|O|O||D||1|Zarzamora logan orgánicas secas
50332009|Bayasmarion orgánicas secas|O|O||D||1|Zarzamora marion orgánicas secas
50332010|Mora navaho orgánicas secas|O|O||D||1|Zarzamora navaho orgánicas secas
50332011|Bayanectar orgánicas secas|O|O||D||1|Zarzamora néctar orgánicas secas
50332012|Mora olallie orgánicas secas|O|O||D||1|Zarzamora olallie orgánicas secas
50332013|Bayatay orgánicas secas|O|O||D||1|Zarzamora tay orgánicas secas
50332014|Mora thomless hull orgánicas secas|O|O||D||1|Zarzamora thomless hull orgánicas secas
50332015|Bayayoung orgánicas secas|O|O||D||1|Zarzamora young orgánicas secas
50332100|Arándanos de mirto orgánicos secos|O|O||D||1|Mirtillos orgánicos secos
50332101|Arandanos bog orgánicas secas|O|O||D||1|Mirtillo bog orgánico seco
50332102|Arandanos dwarf orgánicas secas|O|O||D||1|Mirtillo enano orgánico seco
50332103|Arandanos mountain orgánicas secas|O|O||D||1|Mirtillo de montaña orgánico seco
50332104|Arandanos oval-leaved orgánicas secas|O|O||D||1|Mirtillo oval-leaved orgánico seco
50332200|Agrás orgánicas secas|O|O||D||1|Frutos azules del bosque orgánicos secos
50332201|Agras bluecrop orgánicas secas|O|O||D||1|Fruto azul del bosque bluecrop orgánico seco
50332202|Agras bluetta orgánicas secas|O|O||D||1|Fruto azul del bosque bluetta orgánico seco
50332203|Agras brigitta orgánicas secas|O|O||D||1|Fruto azul del bosque brigitta orgánico seco
50332204|Agras chandler orgánicas secas|O|O||D||1|Fruto azul del bosque chandler orgánico seco
50332205|Agras duke orgánicas secas|O|O||D||1|Fruto azul del bosque duke orgánico seco
50332206|Agras hrdyblue orgánicas secas|O|O||D||1|Fruto azul del bosque hrdyblue orgánico seco
50332207|Agras legacy orgánicas secas|O|O||D||1|Fruto azul del bosque legacy orgánico seco
50332208|Agras misty orgánicas secas|O|O||D||1|Fruto azul del bosque misty orgánico seco
50332209|Agras nelson orgánicas secas|O|O||D||1|Fruto azul del bosque nelson orgánico seco
50332210|Agras northblue orgánicas secas|O|O||D||1|Fruto azul del bosque northblue orgánico seco
50332211|Agras northcountry orgánicas secas|O|O||D||1|Fruto azul del bosque northcountry orgánico seco
50332212|Agras northsky orgánicas secas|O|O||D||1|Fruto azul del bosque northsky orgánico seco
50332213|Agras patriot orgánicas secas|O|O||D||1|Fruto azul del bosque patriot orgánico seco
50332214|Agras spartan orgánicas secas|O|O||D||1|Fruto azul del bosque spartan orgánico seco
50332215|Agras toro orgánicas secas|O|O||D||1|Fruto azul del bosque toro orgánico seco
50332300|Frutas del pan orgánicas secas|O|O||D||1
50332301|Fruta de pan chataigne orgánicas secas|O|O||D||1|Fruta del pan chataigne orgánicas secas
50332302|Fruta de pan sin pepa orgánicas secas|O|O||D||1|Fruta del pan sin semilla orgánicas secas
50332303|Fruta de pan corazón blanco orgánicas secas|O|O||D||1|Fruta del pan corazón blanco orgánicas secas
50332304|Fruta de pan corazón amarillo orgánicas secas|O|O||D||1|Fruta del pan corazón amarillo orgánicas secas
50332400|Chirimoyas orgánicas secas|O|O||D||1|Annonas orgánicas secas
50332401|Chirimoya chays orgánicas secas|O|O||D||1|Annona chays orgánica seca
50332402|Chirimoya bronceada orgánicas secas|O|O||D||1|Annona bronceada orgánica seca
50332403|Chirimoya burtons orgánicas secas|O|O||D||1|Annona burtons orgánica seca
50332404|Chirimoya burton favorite orgánicas secas|O|O||D||1|Annona burton favorite orgánica seca
50332405|Chirimoya jete orgánicas secas|O|O||D||1|Annona jete orgánica seca
50332406|Chirimoya reretai orgánicas secas|O|O||D||1|Annona reretai orgánica seca
50332407|Chirimoya smoothey orgánicas secas|O|O||D||1|Annona smoothey orgánica seca
50332408|Chirimoya spain orgánicas secas|O|O||D||1|Annona españa orgánica seca
50332409|Chirimoya blanco orgánicas secas|O|O||D||1|Annona blanco orgánica seca
50332500|Cerezas orgánicas secas|O|O||D||1
50332501|Cereza amarelle  orgánicas secas|O|O||D||1
50332502|Cereza brooks orgánicas secas|O|O||D||1
50332503|Cereza bigarreu orgánicas secas|O|O||D||1
50332504|Cereza bing orgánicas secas|O|O||D||1
50332505|Cereza blach republic orgánicas secas|O|O||D||1
50332506|Cereza negro schmidt orgánicas secas|O|O||D||1
50332507|Cereza negrotartarian orgánicas secas|O|O||D||1
50332508|Cereza fiesta bing orgánicas secas|O|O||D||1
50332509|Cereza garnet orgánicas secas|O|O||D||1
50332510|Cereza rey orgánicas secas|O|O||D||1
50332511|Cereza chapman orgánicas secas|O|O||D||1
50332512|Cereza lapin orgánicas secas|O|O||D||1
50332513|Cereza larian orgánicas secas|O|O||D||1
50332514|Cereza dark guines orgánicas secas|O|O||D||1
50332515|Cereza montmorency orgánicas secas|O|O||D||1
50332516|Cereza duke orgánicas secas|O|O||D||1
50332517|Cereza early rivers orgánicas secas|O|O||D||1
50332518|Cereza ruby bing orgánicas secas|O|O||D||1
50332519|Cereza santine orgánicas secas|O|O||D||1
50332520|Cereza geans/guines orgánicas secas|O|O||D||1
50332521|Cereza sonata orgánicas secas|O|O||D||1
50332522|Cereza lambert orgánicas secas|O|O||D||1
50332523|Cereza stella orgánicas secas|O|O||D||1
50332524|Cereza sweethart orgánicas secas|O|O||D||1
50332525|Cereza tartarian orgánicas secas|O|O||D||1
50332527|Cereza maraschino orgánicas secas|O|O||D||1
50332528|Cereza van orgánicas secas|O|O||D||1
50332529|Cereza morello orgánicas secas|O|O||D||1
50332530|Cereza royal ann orgánicas secas|O|O||D||1
50332531|Cereza ranier orgánicas secas|O|O||D||1
50332532|Cereza royal orgánicas secas|O|O||D||1
50332600|Citrones orgánicos secos|O|O||D||1|Cidras orgánicas secas
50332601|Citrones buddha´s hand orgánicas secas|O|O||D||1|Cidra mano de Buda orgánica seca
50332602|Citrones fingeroja orgánicas secas|O|O||D||1|Cidra finger red orgánica seca
50332603|Citrones fo shoukan orgánicas secas|O|O||D||1|Cidra fo shoukan orgánica seca
50332604|Cotrones bushakan orgánicas secas|O|O||D||1|Cidra bushakan orgánica seca
50332605|Citones diamante orgánicas secas|O|O||D||1|Cidra diamante orgánica seca
50332606|Citrones etrog orgánicas secas|O|O||D||1|Cidra etrog orgánica seca
50332607|Citrones ponderosa orgánicas secas|O|O||D||1|Cidra ponderosa orgánica seca
50332700|Arándanos orgánicos secos|O|O||D||1|Arándanos rojos orgánicos secos
50332701|Arandano ben lear orgánicas secas|O|O||D||1|Arándano rojo ben lear orgánico seco
50332702|Arandano early negro orgánicas secas|O|O||D||1|Arándano rojo early negro orgánico seco
50332703|Arandano gryclesik orgánicas secas|O|O||D||1|Arándano rojo gryclesik orgánico seco
50332704|Arandano howe orgánicas secas|O|O||D||1|Arándano rojo howe orgánico seco
50332705|Bayas lingon orgánicas secas|O|O||D||1|Arándano rojo lingon orgánico seco
50332706|Arandano mcfarling orgánicas secas|O|O||D||1|Arándano rojo mcfarling orgánico seco
50332707|Arandano mountain orgánicas secas|O|O||D||1|Arándano rojo mountain orgánico seco
50332708|Arandano pilgrim orgánicas secas|O|O||D||1|Arándano rojo pilgrim orgánico seco
50332709|Arandano searless orgánicas secas|O|O||D||1|Arándano rojo searless orgánico seco
50332710|Arandano stevens orgánicas secas|O|O||D||1|Arándano rojo stevens orgánico seco
50332800|pasas de Corinto orgánicas secas|O|O||D||1
50332801|Pasa hudson bay orgánicas secas|O|O||D||1|Pasa de Corinto hudson bay orgánica seca
50332802|Pasa waxy orgánicas secas|O|O||D||1|Pasa de Corinto waxy orgánica seca
50332803|Pasa desert orgánicas secas|O|O||D||1|Pasa de Corinto desert orgánica seca
50332804|Pasa negra orgánicas secas|O|O||D||1|Pasa de Corinto negra orgánica seca
50332805|Pasa roja orgánicas secas|O|O||D||1|Pasa de Corinto roja orgánica seca
50332806|Pasa blanca orgánicas secas|O|O||D||1|Pasa de Corinto blanca orgánica seca
50332900|Dátiles orgánicos secos|O|O||D||1
50332901|Dátiles asharasi  orgánicas secas|O|O||D||1
50332902|Dátiles barhi o barhee orgánicas secas|O|O||D||1
50332903|Dátiles deglet noor orgánicas secas|O|O||D||1
50332904|Dátiles fardh orgánicas secas|O|O||D||1
50332905|Dátiles gundila orgánicas secas|O|O||D||1
50332906|Dátiles halawi/halawy orgánicas secas|O|O||D||1
50332907|Dátiles hilali orgánicas secas|O|O||D||1
50332908|Dátiles khadrawi/khadrawy orgánicas secas|O|O||D||1
50332909|Dátiles khalas orgánicas secas|O|O||D||1
50332910|Dátiles khustawi orgánicas secas|O|O||D||1
50332911|Dátiles khidri orgánicas secas|O|O||D||1
50332912|Dátiles medjool/ medjol orgánicas secas|O|O||D||1
50332913|Dátiles mactoum orgánicas secas|O|O||D||1
50332914|Dátiles neghal orgánicas secas|O|O||D||1
50332915|Dátiles yatimeh orgánicas secas|O|O||D||1
50332916|Dátiles zahidi orgánicas secas|O|O||D||1
50333000|Pitahayas orgánicas secas|O|O||D||1
50333001|Pitahaya roja, rosada orgánicas secas|O|O||D||1
50333002|Pitahaya roja, amarillo orgánicas secas|O|O||D||1
50333100|Brevas orgánicas secas|O|O||D||1|Higos orgánicos secos
50333101|Breva bardajic orgánicas secas|O|O||D||1|Higo bardajic orgánico seco
50333102|Breva brown turkey orgánicas secas|O|O||D||1|Higo brown turkey orgánico seco
50333103|Breva calimyma  orgánicas secas|O|O||D||1|Higo calimyma orgánico seco
50333104|Breva conadria orgánicas secas|O|O||D||1|Higo conadria orgánico seco
50333105|Breva dotado orgánicas secas|O|O||D||1|Higo dotado orgánico seco
50333106|Breva kadota orgánicas secas|O|O||D||1|Higo kadota orgánico seco
50333107|Breva mediterránea orgánicas secas|O|O||D||1|Higo mediterránea orgánico seco
50333108|Breva misión orgánicas secas|O|O||D||1|Higo misión orgánico seco
50333109|Breva amyma orgánicas secas|O|O||D||1|Higo amyma orgánico seco
50333110|Breva verdona orgánicas secas|O|O||D||1|Higo verdona orgánico seco
50333111|Breva rey blanco orgánicas secas|O|O||D||1|Higo rey blanco orgánico seco
50333200|Grosellas orgánicas secas|O|O||D||1
50333201|Grosella early sulphur orgánicas secas|O|O||D||1
50333202|Grosella doradodrop orgánicas secas|O|O||D||1
50333203|Grosella langley grace orgánicas secas|O|O||D||1
50333204|Grocella leveller orgánicas secas|O|O||D||1
50333205|Grosella london orgánicas secas|O|O||D||1
50333206|Grosella worcestershire orgánicas secas|O|O||D||1
50333207|Grosella american worcesterberry orgánic|O|O||D||1
50333300|Toronjas orgánicas secas|O|O||D||1
50333301|Toronja burgundi orgánicas secas|O|O||D||1
50333302|Toronja duncan orgánicas secas|O|O||D||1
50333303|Toronja foster orgánica seca|O|O||D||1
50333304|Toronja marsh orgánicas secas|O|O||D||1
50333305|Toronja nueva zelandia orgánicas secas|O|O||D||1
50333306|Toronja rio rojo orgánicas secas|O|O||D||1
50333307|Toronja ruby rojo orgánicas secas|O|O||D||1
50333308|Toronja star ruby orgánicas secas|O|O||D||1
50333309|Toronja triumph orgánicas secas|O|O||D||1
50333400|Uvas de mesa orgánicas secas|O|O||D||1
50333401|Uva alicante orgánicas secas|O|O||D||1
50333402|Uva almeira orgánicas secas|O|O||D||1
50333403|Uva alphonse lavalle orgánicas secas|O|O||D||1
50333404|Uva otoño rey grapes orgánicas secas|O|O||D||1
50333405|Uva otoño royal orgánicas secas|O|O||D||1
50333406|Uva otoño sin pepa orgánicas secas|O|O||D||1
50333407|Uva baresana orgánicas secas|O|O||D||1
50333408|Uva barlinka orgánicas secas|O|O||D||1
50333409|Uva beaty seedless orgánicas secas|O|O||D||1
50333410|Uva negra beauty sin semilla orgánicas secas|O|O||D||1
50333411|Uva negra emerald orgánicas secas|O|O||D||1
50333412|Uva negra gigante orgánicas secas|O|O||D||1
50333413|Uva negra globe orgánicas secas|O|O||D||1
50333414|Uva negra monnukka orgánicas secas|O|O||D||1
50333415|Uva negra pearl orgánicas secas|O|O||D||1
50333416|Uva negra sin semilla orgánicas secas|O|O||D||1
50333417|Uva bonheur orgánicas secas|O|O||D||1
50333418|Uva calmeria orgánicas secas|O|O||D||1
50333419|Uva cardinal orgánicas secas|O|O||D||1
50333420|Uva catawba orgánicas secas|O|O||D||1
50333421|Uva chasselas/dorado chasselas orgánicas secas|O|O||D||1
50333422|Uva christmas rose orgánicas secas|O|O||D||1
50333423|Uva concord orgánicas secas|O|O||D||1
50333424|Uva concord sin pepa orgánicas secas|O|O||D||1
50333425|Uva crimson sin pepa orgánicas secas|O|O||D||1
50333426|Uva dauphine  orgánicas secas|O|O||D||1
50333427|Uva daleware orgánicas secas|O|O||D||1
50333428|Uva early muscat orgánicas secas|O|O||D||1
50333429|Uva early sweet orgánicas secas|O|O||D||1
50333430|Uva esmerald sin pepa orgánicas secas|O|O||D||1
50333431|Uva emperatriz orgánicas secas|O|O||D||1
50333432|Uva emperor orgánicas secas|O|O||D||1
50333433|Uva empress orgánicas secas|O|O||D||1
50333434|Uva exótica orgánicas secas|O|O||D||1
50333435|Uva fantasia orgánicas secas|O|O||D||1
50333436|Uva fantasy sin pepa orgánicas secas|O|O||D||1
50333437|Uva llama orgánicas secas|O|O||D||1
50333438|Uva llama sin pepa orgánicas secas|O|O||D||1
50333439|Uva llama tokay orgánicas secas|O|O||D||1
50333440|Uva flaming roja orgánicas secas|O|O||D||1
50333441|Uva galaxy sin pepa orgánicas secas|O|O||D||1
50333442|Uva gamay orgánicas secas|O|O||D||1
50333443|Uva dorada orgánicas secas|O|O||D||1
50333444|Uva hanepot o honeypot orgánicas secas|O|O||D||1
50333445|Uva italia orgánicas secas|O|O||D||1
50333446|Uva jade sin pepa orgánicas secas|O|O||D||1
50333447|Uva jubileo orgánicas secas|O|O||D||1
50333448|Uva rey ruby orgánicas secas|O|O||D||1
50333449|Uva kyoho orgánicas secas|O|O||D||1
50333450|Uva la rochelle orgánicas secas|O|O||D||1
50333451|Uva dedo de dama orgánicas secas|O|O||D||1
50333452|Uva late sin pepa orgánicas secas|O|O||D||1
50333453|Uva majestic sin pepa orgánicas secas|O|O||D||1
50333454|Uva malaga orgánicas secas|O|O||D||1
50333455|Uva marro sin pepa orgánicas secas|O|O||D||1
50333456|Uva muscadine orgánicas secas|O|O||D||1
50333457|Uva muscat llama orgánicas secas|O|O||D||1
50333458|Uva muscat orgánicas secas|O|O||D||1
50333459|Uva muscat sin papa orgánicas secas|O|O||D||1
50333460|Uva napoleon orgánicas secas|O|O||D||1
50333461|Uva nigeria orgánicas secas|O|O||D||1
50333462|Uva new cross orgánicas secas|O|O||D||1
50333463|Uva nibella orgánicas secas|O|O||D||1
50333464|Uva niagara orgánicas secas|O|O||D||1
50333465|Uva olivette orgánicas secas|O|O||D||1
50333466|Uva perlette orgánicas secas|O|O||D||1
50333467|Uva perlon orgánicas secas|O|O||D||1
50333468|Uva prima negro sin pepa orgánicas secas|O|O||D||1
50333469|Uva prncess orgánicas secas|O|O||D||1
50333470|Uva reina orgánicas secas|O|O||D||1
50333471|Uva roja blush orgánicas secas|O|O||D||1
50333472|Uva roja globe orgánicas secas|O|O||D||1
50333473|Uva roja malaga orgánicas secas|O|O||D||1
50333474|Uva roja sin pepa orgánicas secas|O|O||D||1
50333475|Uva regina orgánicas secas|O|O||D||1
50333476|Uva ribier orgánicas secas|O|O||D||1
50333477|Uva rosita orgánicas secas|O|O||D||1
50333478|Uva rouge orgánicas secas|O|O||D||1
50333479|Uva royal negra sin pepa orgánicas secas|O|O||D||1
50333480|Uva ruby roja sin pepa orgánicas secas|O|O||D||1
50333481|Uva ryby sin pepa orgánicas secas|O|O||D||1
50333482|Uva scarlet royal orgánicas secas|O|O||D||1
50333483|Uva scuppemong orgánicas secas|O|O||D||1
50333484|Uva sugarose orgánicas secas|O|O||D||1
50333485|Uva sugartirteen orgánicas secas|O|O||D||1
50333486|Uva sugraone orgánicas secas|O|O||D||1
50333487|Uva sugrasixteen orgánicas secas|O|O||D||1
50333488|Uva sultana sun roja orgánicas secas|O|O||D||1
50333489|Uva verano royal orgánicas secas|O|O||D||1
50333490|Uva sunset orgánicas secas|O|O||D||1
50333491|Uva superior sin pepa orgánicas secas|O|O||D||1
50333492|Uva thompson sin pepa orgánicas secas|O|O||D||1
50333493|Uva tokaylpinot gris orgánicas secas|O|O||D||1
50333494|Uva waltman cross orgánicas secas|O|O||D||1
50333495|Uva blanca sin pepa orgánicas secas|O|O||D||1
50333496|Uva zante current orgánicas secas|O|O||D||1
50333500|Uvas pasas orgánicas secas|O|O||D||1
50333501|Uva corinth negra orgánicas secas|O|O||D||1
50333502|Uva canner orgánicas secas|O|O||D||1
50333503|Uva dovine orgánicas secas|O|O||D||1
50333504|Uva fiesta orgánicas secas|O|O||D||1
50333505|Uva selme pete orgánicas secas|O|O||D||1
50333506|Uva sultana orgánicas secas|O|O||D||1
50333600|Uvas para vino orgánicas secas|O|O||D||1
50333601|Uva uva alicante bouschet orgánicas secas|O|O||D||1
50333602|Uva barbera orgánicas secas|O|O||D||1
50333603|Uva burger orgánicas secas|O|O||D||1
50333604|Uva cabemet franc orgánicas secas|O|O||D||1
50333605|Uva cabenet sauvignon orgánicas secas|O|O||D||1
50333606|Uva carignane orgánicas secas|O|O||D||1
50333607|Uva camelian orgánicas secas|O|O||D||1
50333608|Uva cattarrato orgánicas secas|O|O||D||1
50333609|Uva centurian orgánicas secas|O|O||D||1
50333610|Uva charbono orgánicas secas|O|O||D||1
50333611|Uva chardonnay orgánicas secas|O|O||D||1
50333612|Uva chenin blanco orgánicas secas|O|O||D||1
50333613|Uva cinsaut orgánicas secas|O|O||D||1
50333614|Uva dolcetto orgánicas secas|O|O||D||1
50333615|Uva emerald riesling orgánicas secas|O|O||D||1
50333616|Uva frances colombard orgánicas secas|O|O||D||1
50333617|Uva granny nap orgánicas secas|O|O||D||1
50333618|Uva gamay beaujolais orgánicas secas|O|O||D||1
50333619|Uva gewurztraminer orgánicas secas|O|O||D||1
50333620|Uva grnache orgánicas secas|O|O||D||1
50333621|Uva grinache blanc orgánicas secas|O|O||D||1
50333622|Uva lagrein orgánicas secas|O|O||D||1
50333623|Uva lambruso orgánicas secas|O|O||D||1
50333624|Uva malbec orgánicas secas|O|O||D||1
50333625|Uva malvasía bianca orgánicas secas|O|O||D||1
50333626|Uva marsanne orgánicas secas|O|O||D||1
50333627|Uva matano orgánicas secas|O|O||D||1
50333628|Uva merlot orgánicas secas|O|O||D||1
50333629|Uva meunier orgánicas secas|O|O||D||1
50333630|Uva missiom orgánicas secas|O|O||D||1
50333631|Uva montepulceano orgánicas secas|O|O||D||1
50333632|Uva muscat blanc orgánicas secas|O|O||D||1
50333633|Uva muscat hamburg orgánicas secas|O|O||D||1
50333634|Uva muscat alexandria orgánicas secas|O|O||D||1
50333635|Uva muscat naranja orgánicas secas|O|O||D||1
50333636|Uva nebbiolo orgánicas secas|O|O||D||1
50333637|Uva palomino orgánicas secas|O|O||D||1
50333638|Uva petit verdor orgánicas secas|O|O||D||1
50333639|Uva petit sirah orgánicas secas|O|O||D||1
50333640|Uva pinot blanc orgánicas secas|O|O||D||1
50333641|Uva pinot gris orgánicas secas|O|O||D||1
50333642|Uva pinot noir orgánicas secas|O|O||D||1
50333643|Uva primitivo orgánicas secas|O|O||D||1
50333644|Uva roussane orgánicas secas|O|O||D||1
50333645|Uva real  orgánicas secas|O|O||D||1
50333646|Uva rubiroja orgánicas secas|O|O||D||1
50333647|Uva ruby cabenet orgánicas secas|O|O||D||1
50333648|Uva salvador orgánicas secas|O|O||D||1
50333649|Uva sangiovese orgánicas secas|O|O||D||1
50333650|Uva sauvignon blanc orgánicas secas|O|O||D||1
50333651|Uva sauvignon musque orgánicas secas|O|O||D||1
50333652|Uva semillon orgánicas secas|O|O||D||1
50333653|Uva souzao orgánicas secas|O|O||D||1
50333654|Uva st emilion orgánicas secas|O|O||D||1
50333655|Uva symohony orgánicas secas|O|O||D||1
50333656|Uva syrah  orgánicas secas|O|O||D||1
50333657|Uva tannat orgánicas secas|O|O||D||1
50333658|Uva tempranillo orgánicas secas|O|O||D||1
50333659|Uvas teroldego orgánicas secas|O|O||D||1
50333660|Uvas tocai friulano orgánicas secas|O|O||D||1
50333661|Uvas touriga nacional orgánicas secas|O|O||D||1
50333662|Uvas triplett blanc orgánicas secas|O|O||D||1
50333663|Uvas viognier orgánicas secas|O|O||D||1
50333664|Uvas blanco riesling orgánicas secas|O|O||D||1
50333665|Uvas zinfandel orgánicas secas|O|O||D||1
50333700|Guayabas orgánicas secas|O|O||D||1
50333701|Guayaba beaumont orgánicas secas|O|O||D||1
50333702|Guayaba carrley orgánicas secas|O|O||D||1
50333703|Guayaba lucida orgánicas secas|O|O||D||1
50333704|Guayaba piña orgánicas secas|O|O||D||1
50333800|Arándanos Huckleberry orgánicos secos|O|O||D||1|Arándanos azules orgánicos secos
50333801|Arándano invierno negro orgánico seco|O|O||D||1|Arándano azul invierno negro orgánico seco
50333802|Arándano cascada orgánico seco|O|O||D||1|Arándano azul cascada orgánico seco
50333803|Arándano enano orgánico seco|O|O||D||1|Arándano azul enano orgánico seco
50333804|Arándano montaña orgánico seco|O|O||D||1|Arándano azul montaña orgánico seco
50333805|Arándano rojo orgánico seco|O|O||D||1|Arándano azul red orgánico seco
50333900|Kiwis orgánicos secos|O|O||D||1
50333901|Fruta de kiwi ananasnaja orgánicas secas|O|O||D||1|Kiwi ananasnaja orgánico seco
50333902|Fruta de kiwi belleza del ártico orgánicas secas|O|O||D||1|Kiwi belleza del ártico orgánico seco
50333903|Fruta de kiwi blake orgánicas secas|O|O||D||1|Kiwi blake orgánico seco
50333904|Fruta de kiwi hayward orgánicas secas|O|O||D||1|Kiwi hayward orgánico seco
50333905|Fruta de kiwi issai orgánicas secas|O|O||D||1|Kiwi issai orgánico seco
50333906|Fruta de kiwi siberiana orgánicas secas|O|O||D||1|Kiwi siberiano orgánico seco
50334000|Naranjos Chinos (kumquats) orgánicos secos|O|O||D||1
50334001|Naranjo chino hong kong orgánico seco|O|O||D||1
50334002|Naranjo chino limequat orgánico seco|O|O||D||1
50334003|Naranjo long fruit orgánico seco|O|O||D||1|Naranjo chino long fruit orgánico seco
50334004|Naranjo chino malayan orgánico seco|O|O||D||1
50334005|Naranjo meiwa orgánico seco|O|O||D||1|Naranjo chino meiwa orgánico seco
50334006|Naranja chino nagami orgánico seco|O|O||D||1|Naranjo chino nagami orgánico seco
50334100|Limones orgánicos secos|O|O||D||1
50334101|Limón baboon orgánico seco|O|O||D||1
50334102|Limón bearss sicilian orgánico seco|O|O||D||1
50334103|Limón cameron highland orgánico seco|O|O||D||1
50334104|Limón escondido orgánico seco|O|O||D||1
50334105|Limón eureka orgánico seco|O|O||D||1
50334106|Limón lisbon orgánico seco|O|O||D||1
50334107|Limón meyer orgánico seco|O|O||D||1
50334108|Limón volkaner orgánico seco|O|O||D||1
50334200|Limas orgánicas secas|O|O||D||1
50334201|Lima limón indian sweet orgánico seco|O|O||D||1
50334202|Lima limón orgánico seco|O|O||D||1
50334203|Lima limón mandarin orgánico seco|O|O||D||1
50334204|Lima limón philippine orgánico seco|O|O||D||1
50334205|Lima limón tahitian orgánico seco|O|O||D||1
50334206|Lima limón bearss orgánico seco|O|O||D||1
50334207|Lima limón persa orgánico seco|O|O||D||1
50334208|Lima limón sin pepas orgánico seco|O|O||D||1|Lima limón sin semillas orgánico seco
50334300|Nísperos orgánicos secos|O|O||D||1
50334301|Níspero japonés advance orgánico seco|O|O||D||1
50334302|Níspero japonés benlehr orgánico seco|O|O||D||1
50334303|Níspero japonés big jim orgánico seco|O|O||D||1
50334304|Níspero japonés champagne orgánico seco|O|O||D||1
50334305|Níspero japonés early rojo orgánico seco|O|O||D||1
50334306|Níspero japonés nugget dorado orgánico seco|O|O||D||1
50334307|Níspero japonés herd´s mammoth orgánico seco|O|O||D||1
50334308|Níspero japonés mogi orgánico seco|O|O||D||1
50334309|Níspero japonés mrs cooksey orgánico seco|O|O||D||1
50334310|Níspero japonés fresa orgánico seco|O|O||D||1
50334311|Níspero japonés tanaka orgánico seco|O|O||D||1
50334312|Níspero japonés victoria vista blanco orgánico seco|O|O||D||1
50334313|Níspero japonés wolfe orgánico seco|O|O||D||1
50334400|Mandarinas orgánicas secas|O|O||D||1
50334401|Naranjas clauselinas orgánicas secas|O|O||D||1
50334402|Mandarinas clementinas orgánicas secas|O|O||D||1
50334403|Naranja mandarina cleopatra|O|O||D||1
50334404|Mandarina dancy orgánicas secas|O|O||D||1
50334405|Naranja ellensday orgánicas secas|O|O||D||1
50334406|Naranja fairchild orgánicas secas|O|O||D||1
50334407|Naranja fallglo orgánicas secas|O|O||D||1
50334408|Naranja fortuna orgánicas secas|O|O||D||1
50334409|Mandarina naranja fremont orgánicas secas|O|O||D||1
50334410|Naranja fremont orgánicas secas|O|O||D||1
50334411|Naranja nuget dorada orgánicas secas|O|O||D||1
50334412|Mandarina naranja miel orgánicas secas|O|O||D||1
50334413|Naranja miel orgánicas secas|O|O||D||1
50334414|Mandarina miel orgánicas secas|O|O||D||1
50334415|Natanja tanjelo honebelle orgánicas secas|O|O||D||1|Naranja tangelo honebelle orgánicas secas
50334416|Naranja mandarina rey orgánicas secas|O|O||D||1
50334417|Naranja kinnow orgánicas secas|O|O||D||1
50334418|Naranja mandarina lee orgánicas secas|O|O||D||1
50334419|Naranja makokkee orgánicas secas|O|O||D||1
50334420|Naranja malvasios orgánicas secas|O|O||D||1
50334421|Naranja mandarina mediterránea orgánicas secas|O|O||D||1
50334422|Naranja tangelo minneola orgánicas secas|O|O||D||1
50334423|Naranja monica orgánicas secas|O|O||D||1
50334424|Naranja murcott miel orgánicas secas|O|O||D||1
50334425|Naranja murcott tangors orgánicas secas|O|O||D||1
50334426|Naranja mandarina natsudaidai  orgánicas secas|O|O||D||1
50334427|Naranja mandarina natsumikan orgánicas secas|O|O||D||1
50334428|Naranja tanjelo nocatee orgánicas secas|O|O||D||1
50334429|Naranja tanjelo orlando orgánicas secas|O|O||D||1
50334430|Mandarina ortanique orgánicas secas|O|O||D||1
50334431|Naranja mandarina pagina orgánicas secas|O|O||D||1
50334432|Naranja pixie orgánicas secas|O|O||D||1
50334433|Naranja mandarina ponkan bantangas orgánicas secas|O|O||D||1
50334434|Naranja reina orgánicas secas|O|O||D||1
50334435|Naranja robinson orgánicas secas|O|O||D||1
50334436|Naranja saltenitas orgánicas secas|O|O||D||1
50334437|Naranja tangelo sampson orgánicas secas|O|O||D||1
50334438|Naranja mandarina satsuma orgánicas secas|O|O||D||1
50334439|Naranja mandarina sunburst orgánicas secas|O|O||D||1
50334440|Tangelo orgánico seco|O|O||D||1
50334441|Naranja mandarina orgánicas secas|O|O||D||1
50334442|Naranja templo orgánicas secas|O|O||D||1
50334443|Naranja thornton orgánicas secas|O|O||D||1
50334444|Mandarina wekiwa orgánicas secas|O|O||D||1
50334445|Mandarina wilkins orgánicas secas|O|O||D||1
50334446|Mandarina willowleaf mediterránea orgánicas secas|O|O||D||1
50334500|Mangos orgánicos secos|O|O||D||1
50334501|Mango alphonso orgánico seco|O|O||D||1
50334502|Mango ataulfo orgánico seco|O|O||D||1
50334503|Mango criollo orgánico seco|O|O||D||1
50334504|Mango edwards orgánico seco|O|O||D||1
50334505|Mango francine orgánico seco|O|O||D||1
50334506|Mango francis orgánico seco|O|O||D||1
50334507|Mango gandaria orgánico seco|O|O||D||1
50334508|Mango haden orgánico seco|O|O||D||1
50334509|Mangos irwin orgánico seco|O|O||D||1
50334510|Mangos keitt orgánico seco|O|O||D||1
50334511|Mangos kent orgánico seco|O|O||D||1
50334512|Mangos kesar orgánico seco|O|O||D||1
50334513|Mangos kuini orgánico seco|O|O||D||1
50334514|Mangos manila super orgánico seco|O|O||D||1
50334515|Mangos manila orgánico seco|O|O||D||1
50334516|Mangos mayaguez orgánico seco|O|O||D||1
50334517|Mangos mulgoba orgánico seco|O|O||D||1
50334518|Mangos oro orgánico seco|O|O||D||1
50334519|Mangos palmer orgánico seco|O|O||D||1
50334520|Mango parvin orgánico seco|O|O||D||1
50334521|Mango sandersha orgánico seco|O|O||D||1
50334522|Mangos sensation orgánico seco|O|O||D||1
50334523|Mango smith orgánico seco|O|O||D||1
50334524|Mango tomy atkin orgánico seco|O|O||D||1
50334525|Mango van dyke orgánico seco|O|O||D||1
50334600|Melones orgánicos secos|O|O||D||1
50334601|Melon allsweet orgánico seco|O|O||D||1
50334602|Melón athena orgánico seco|O|O||D||1
50334603|Melón diamante negro orgánico seco|O|O||D||1
50334604|Melón cal dulce orgánico seco|O|O||D||1
50334605|Melón carnical orgánico seco|O|O||D||1
50334606|Melón cantaloupe orgánico seco|O|O||D||1
50334607|Melón casaba orgánico seco|O|O||D||1
50334608|Melón cavaillon orgánico seco|O|O||D||1
50334609|Melón charentais orgánico seco|O|O||D||1
50334610|Sandia charleston gray orgánico seco|O|O||D||1
50334611|Melón crenshaw orgánico seco|O|O||D||1
50334612|Melón crimson sweet orgánico seco|O|O||D||1
50334613|Melón dixie lee orgánico seco|O|O||D||1
50334614|Melón eclipse orgánico seco|O|O||D||1
50334615|Melón ein dór  orgánico seco|O|O||D||1
50334616|Melón fiesta orgánico seco|O|O||D||1
50334617|Melón galia orgánico seco|O|O||D||1
50334618|Melón gaya orgánico seco|O|O||D||1
50334619|Melón hami orgánico seco|O|O||D||1
50334620|Melón miel dew orgánico seco|O|O||D||1
50334621|Melón hielo orgánico seco|O|O||D||1
50334622|Melón ida orgullo orgánico seco|O|O||D||1
50334623|Melón juan canary orgánico seco|O|O||D||1
50334624|Melón jubileo orgánico seco|O|O||D||1
50334625|Melón jubilación orgánico seco|O|O||D||1
50334626|Melón kaki / kakri orgánico seco|O|O||D||1
50334627|Melón kiwano orgánico seco|O|O||D||1
50334628|Melon koreano orgánico seco|O|O||D||1|Melón coreano orgánico seco
50334629|Melón long grey orgánico seco|O|O||D||1|Melón largo gris orgánico seco
50334630|Melón mayan orgánico seco|O|O||D||1
50334631|Melón micky lee orgánico seco|O|O||D||1
50334632|Melón mirage orgánico seco|O|O||D||1
50334633|Sandia luna y estrellas orgánico seco|O|O||D||1
50334634|Melón ogen orgánico seco|O|O||D||1
50334635|Melón patriot orgánico seco|O|O||D||1
50334636|Melón peacook orgánico seco|O|O||D||1
50334637|Melón pepino orgánico seco|O|O||D||1
50334638|Melón persian orgánico seco|O|O||D||1
50334639|Melón picnic orgánico seco|O|O||D||1
50334640|Melón piel de sapo orgánico seco|O|O||D||1
50334641|Melón piña orgánico seco|O|O||D||1
50334642|Melón quetzali orgánico seco|O|O||D||1
50334643|Melón goblin rojo orgánico seco|O|O||D||1
50334644|Melón regency orgánico seco|O|O||D||1
50334645|Melón royal mejestic orgánico seco|O|O||D||1
50334646|Melón royal star orgánico seco|O|O||D||1
50334647|Melón dulce royal orgánico seco|O|O||D||1
50334648|Malon santa claus orgánico seco|O|O||D||1|Melón piel de sapo orgánico seco, Melón santa claus orgánico seco
50334649|Melón sharlyn orgánico seco|O|O||D||1
50334650|Melón español orgánico seco|O|O||D||1
50334651|Melón sprite orgánic orgánico seco|O|O||D||1
50334652|Melón starbright orgánico seco|O|O||D||1
50334653|Melón stars and stripes orgánico seco|O|O||D||1
50334654|Melón bebe de azúcar orgánico seco|O|O||D||1
50334655|Sandia bebe de azúcar orgánicas secas|O|O||D||1
50334656|Melón dulce sol orgánico seco|O|O||D||1
50334657|Sandia corazón dulce sin semilla orgánicas secas|O|O||D||1
50334658|Melón tentación orgánico seco|O|O||D||1
50334659|Melón bebe tigre orgánico seco|O|O||D||1
50334660|Melón tuscan tipo orgánico seco|O|O||D||1
50334661|Sandia bebe amarillo orgánicas secas|O|O||D||1
50334700|Moras mulberry orgánicas secas|O|O||D||1|Zarzamoras mulberry orgánicas secas
50334701|Mora negra orgánicas secas|O|O||D||1|Zarzamora negra orgánicas secas
50334702|Mora blanca orgánicas secas|O|O||D||1|Zarzamora blanca orgánicas secas
50334800|Mirtos orgánicos secos|O|O||D||1|Arrayanes orgánicos secos
50334801|Mirto bog orgánico seco|O|O||D||1|Arrayán bog orgánico seco
50334900|Nectarinas orgánicos secos|O|O||D||1
50334901|Durazno april glo orgánico seco|O|O||D||1
50334902|Durazno arctic mist orgánico seco|O|O||D||1
50334903|Durazno artic snow orgánico seco|O|O||D||1
50334904|Durazno artic star orgánico seco|O|O||D||1
50334905|Durazno artic dulce orgánico seco|O|O||D||1
50334906|Durazno artic glo orgánico seco|O|O||D||1
50334907|Durazno august fire orgánico seco|O|O||D||1
50334908|Durazno  perla de agosto orgánico seco|O|O||D||1
50334909|Durazno agosto rojo orgánico seco|O|O||D||1
50334910|Durazno estrella de agosto orgánico seco|O|O||D||1
50334911|Durazno big john orgánico seco|O|O||D||1
50334912|Durazno perla brillante orgánico seco|O|O||D||1
50334913|Durazno diamante brillante orgánico seco|O|O||D||1
50334914|Durazno diamante ray orgánico seco|O|O||D||1
50334915|Durazno earligo orgánico seco|O|O||D||1
50334916|Durazno diamante temprano orgánico seco|O|O||D||1
50334917|Durazno fairlane orgánico seco|O|O||D||1
50334918|Durazno fantasia orgánico seco|O|O||D||1
50334919|Durazno perla fuego orgánico seco|O|O||D||1
50334920|Durazno fuego dulce orgánico seco|O|O||D||1
50334921|Durazno llamakist orgánico seco|O|O||D||1
50334922|Durazno tipo plano orgánico seco|O|O||D||1
50334923|Durazno delicia de jardín orgánico seco|O|O||D||1
50334924|Durazno mina de oro orgánico seco|O|O||D||1
50334925|Durazno perla grande orgánico seco|O|O||D||1
50334926|Durazno hardiroja orgánico seco|O|O||D||1
50334927|Durazno miel de fuego orgánico seco|O|O||D||1
50334928|Durazno julio rojo orgánico seco|O|O||D||1
50334929|Durazno kay perla orgánico seco|O|O||D||1
50334930|Durazno key dulce orgánico seco|O|O||D||1
50334931|Durazno diamante mayo orgánico seco|O|O||D||1
50334932|Durazno mayfire orgánico seco|O|O||D||1
50334933|Durazno mayglo orgánico seco|O|O||D||1
50334934|Durazno mericrest orgánico seco|O|O||D||1
50334935|Durazno diamante rojo orgánico seco|O|O||D||1
50334936|Durazno oro rojo orgánico seco|O|O||D||1
50334937|Durazno jim rojo orgánico seco|O|O||D||1
50334938|Durazno roy rojo orgánico seco|O|O||D||1
50334939|Durazno rio rojo orgánico seco|O|O||D||1
50334940|Durazno diamante de rosa orgánico seco|O|O||D||1
50334941|Durazno rotal glo orgánico seco|O|O||D||1
50334942|Durazno diamante ryby orgánico seco|O|O||D||1
50334943|Durazno ruby dulce orgánico seco|O|O||D||1
50334944|Durazno joya ruddy orgánico seco|O|O||D||1
50334945|Durazno septiembre rojo orgánico seco|O|O||D||1
50334946|Durazno reina de nieve orgánico seco|O|O||D||1
50334947|Durazno primavera clara orgánico seco|O|O||D||1
50334948|Durazno primavera roja orgánico seco|O|O||D||1
50334949|Durazno verano rojiso orgánico seco|O|O||D||1
50334950|Durazno verano claro orgánico seco|O|O||D||1
50334951|Durazno verano diamante orgánico seco|O|O||D||1
50334952|Durazno verano fuego orgánico seco|O|O||D||1
50334953|Durazno verano grande orgánico seco|O|O||D||1
50334954|Durazno sunglo orgánico seco|O|O||D||1
50334955|Durazno fuego zee orgánico seco|O|O||D||1
50334956|Durazno zee glo orgánico seco|O|O||D||1
50334957|Durazno zeegrand orgánico seco|O|O||D||1
50335000|Naranjas orgánicas secas|O|O||D||1
50335001|Naranja áfrica agria orgánicas secas|O|O||D||1
50335002|Naranja dulce amber orgánicas secas|O|O||D||1
50335003|Naranja argentina agria orgánicas secas|O|O||D||1
50335004|Naranja bahianinha orgánico seco|O|O||D||1
50335005|Naranja bergamot orgánicas secas|O|O||D||1
50335006|Naranja berna orgánicas secas|O|O||D||1
50335007|Naranja bigaradier apepu orgánicas secas|O|O||D||1
50335008|Naranja agria dulce daidai orgánicas secas|O|O||D||1
50335009|Naranja mono orgánicas secas|O|O||D||1
50335010|Naranja sangre orgánicas secas|O|O||D||1
50335011|Naranja california navel orgánicas secas|O|O||D||1
50335012|Naranja cara cara orgánicas secas|O|O||D||1
50335013|Naranja chinotto orgánicas secas|O|O||D||1
50335014|Naranja sueño nevel orgánicas secas|O|O||D||1
50335015|Naranja gou tou orgánicas secas|O|O||D||1
50335016|Naranja hamlin orgánicas secas|O|O||D||1
50335017|Naranja jaffa orgánicas secas|O|O||D||1
50335018|Naranja jincheng orgánicas secas|O|O||D||1
50335019|Naranja k-temprano orgánicas secas|O|O||D||1
50335020|Naranja kona orgánicas secas|O|O||D||1
50335021|Naranja navel tarde orgánicas secas orgánicas secas|O|O||D||1
50335022|Naranja valencia tarde orgánicas secas|O|O||D||1
50335023|Naranja limequat orgánicas secas|O|O||D||1
50335024|Naranja mar orgánicas secas|O|O||D||1
50335025|Naranja malegold orgánicas secas|O|O||D||1
50335026|Naranja moro orgánicas secas|O|O||D||1
50335027|Naranja moro tabaco orgánicas secas|O|O||D||1
50335028|Naranja navel orgánicas secas|O|O||D||1
50335029|Naranja navelina orgánicas secas|O|O||D||1
50335030|Naranja oro blanco orgánicas secas|O|O||D||1
50335031|Naranja osceola orgánicas secas|O|O||D||1
50335032|Naranja parson carmelito orgánicas secas|O|O||D||1
50335033|Naranja pera orgánicas secas|O|O||D||1
50335034|Naranjo pummulo orgánicas secas|O|O||D||1|Naranja pummulo orgánicas secas
50335035|Naranja rhode rojo orgánicas secas|O|O||D||1
50335036|Naranja roble orgánicas secas|O|O||D||1
50335037|Naranja salustianas orgánicas secas|O|O||D||1
50335038|Naranja sanguine orgánicas secas|O|O||D||1
50335039|Naranja sanguinelli orgánicas secas|O|O||D||1
50335040|Naranja cevilla orgánicas secas|O|O||D||1
50335041|Naranja shamouti jaffa orgánicas secas|O|O||D||1
50335042|Naranja tunis orgánicas secas|O|O||D||1
50335043|Naranja valencia orgánicas secas|O|O||D||1
50335044|Naranja washington navel orgánicas secas|O|O||D||1
50335100|Papayas orgánicas secas|O|O||D||1
50335101|Papaya verde cocinar orgánicas secas|O|O||D||1
50335102|Papaya maradol orgánicas secas|O|O||D||1
50335103|Papaya amarillo mexicano orgánicas secas|O|O||D||1
50335104|Papaya montaña orgánicas secas|O|O||D||1
50335105|Papaya solo orgánicas secas|O|O||D||1
50335106|Papaya tainung orgánicas secas|O|O||D||1
50335200|Maracuyás orgánicas secas|O|O||D||1
50335201|Maracuyá banana orgánicas secas|O|O||D||1|Curuba orgánica seca
50335202|Maracuyá azul orgánicas secas|O|O||D||1|Maracuyá pasionaria azul orgánica seca
50335203|Maracuyá crackerjack orgánicas secas|O|O||D||1
50335204|Maracuyá granadilla gigante orgánicas secas|O|O||D||1
50335205|Maracuyá granadilla dorada orgánicas secas|O|O||D||1
50335206|Maracuyá maypops orgánicas secas|O|O||D||1
50335207|Maracuyá roja orgánicas secas|O|O||D||1
50335208|Maracuyá granadilla dulce orgánicas secas|O|O||D||1
50335209|Maracuyá sandia orgánicas secas|O|O||D||1
50335210|Maracuyá  wing- stemmed orgánicas secas|O|O||D||1
50335300|Duraznos orgánicos secos|O|O||D||1
50335301|Durazno escudo amber orgánico seco|O|O||D||1
50335302|Durazno nieve de abril orgánico seco|O|O||D||1
50335303|Durazno dama de agosto orgánico seco|O|O||D||1
50335304|Durazno llama de otoño orgánico seco|O|O||D||1
50335305|Durazno dama de otoño orgánico seco|O|O||D||1
50335306|Durazno babcock orgánico seco|O|O||D||1
50335307|Durazno brittany lane orgánico seco|O|O||D||1
50335308|Durazno cary mac orgánico seco|O|O||D||1
50335309|Durazno clásica orgánico seco|O|O||D||1
50335310|Durazno dulce del campo orgánico seco|O|O||D||1
50335311|Durazno escudo de cielo orgánico seco|O|O||D||1
50335312|Durazno dama crimson orgánico seco|O|O||D||1
50335313|Durazno príncipe corona orgánico seco|O|O||D||1
50335314|Durazno sol david orgánico seco|O|O||D||1
50335315|Durazno  princesa diamante orgánico seco|O|O||D||1
50335316|Durazno earlrich orgánico seco|O|O||D||1
50335317|Durazno majestuosa temprana orgánico seco|O|O||D||1
50335318|Durazno early treat orgánico seco|O|O||D||1
50335319|Durazno dama elegante orgánico seco|O|O||D||1
50335320|Durazno emperatriz orgánico seco|O|O||D||1
50335321|Durazno encoré orgánico seco|O|O||D||1
50335322|Durazno dama elegante orgánico seco|O|O||D||1
50335323|Durazno príncipe de fuego orgánico seco|O|O||D||1
50335324|Durazno escudo de llama orgánico seco|O|O||D||1
50335325|Durazno tipo plano orgánico seco|O|O||D||1
50335326|Durazno escudo de sabor orgánico seco|O|O||D||1
50335327|Durazno príncipe florida orgánico seco|O|O||D||1
50335328|Durazno luna llena orgánico seco|O|O||D||1
50335329|Durazno harvester orgánico seco|O|O||D||1
50335330|Durazno princesa de hielo orgánico seco|O|O||D||1
50335331|Durazno princesa de marfil orgánico seco|O|O||D||1
50335332|Durazno princesa reina jersey orgánico seco|O|O||D||1
50335333|Durazno john henry orgánico seco|O|O||D||1
50335334|Durazno príncipe de junio orgánico seco|O|O||D||1
50335335|Durazno kaweah orgánico seco|O|O||D||1
50335336|Durazno klondike orgánico seco|O|O||D||1
50335337|Durazno lindo orgánico seco|O|O||D||1
50335338|Durazno loring orgánico seco|O|O||D||1
50335339|Durazno majestuoso orgánico seco|O|O||D||1
50335340|Durazno o’henry orgánico seco|O|O||D||1
50335341|Durazno escudo de reina orgánico seco|O|O||D||1
50335342|Durazno dama roja orgánico seco|O|O||D||1
50335343|Durazno globo rojo orgánico seco|O|O||D||1
50335344|Durazno cielo rojo orgánico seco|O|O||D||1
50335345|Durazno redtop orgánico seco|O|O||D||1
50335346|Durazno regina orgánico seco|O|O||D||1
50335347|Durazno dama rica orgánico seco|O|O||D||1
50335348|Durazno mayo rico orgánico seco|O|O||D||1
50335349|Durazno gloria royal orgánico seco|O|O||D||1
50335350|Durazno dama royal orgánico seco|O|O||D||1
50335351|Durazno nieve de septiembre orgánico seco|O|O||D||1
50335352|Durazno sol de septiembre orgánico seco|O|O||D||1
50335353|Durazno gema sierra orgánico seco|O|O||D||1
50335354|Durazno angel de nieve orgánico seco|O|O||D||1
50335355|Durazno gema de nieve orgánico seco|O|O||D||1
50335356|Durazno rey de nieve orgánico seco|O|O||D||1
50335357|Durazno dama de primavera orgánico seco|O|O||D||1
50335358|Durazno nieve de primavera orgánico seco|O|O||D||1
50335359|Durazno escudo de primavera orgánico seco|O|O||D||1
50335360|Durazno dulce gigante orgánico seco|O|O||D||1
50335361|Durazno dama de azúcar orgánico seco|O|O||D||1
50335362|Durazno brillo de sol orgánico seco|O|O||D||1
50335363|Durazno sunhigh orgánico seco|O|O||D||1
50335364|Durazno dama super orgánico seco|O|O||D||1
50335365|Durazno super rico orgánico seco|O|O||D||1
50335366|Durazno surecrop orgánico seco|O|O||D||1
50335367|Durazno sueño dulce orgánico seco|O|O||D||1
50335368|Durazno septiembre dulce orgánico seco|O|O||D||1
50335369|Durazno vista orgánico seco|O|O||D||1
50335370|Durazno dama blanca orgánico seco|O|O||D||1
50335371|Durazno dama zee orgánico seco|O|O||D||1
50335400|Peras orgánicas secas|O|O||D||1
50335401|Peras abate fetel orgánicas secas|O|O||D||1
50335402|Peras anjou orgánicas secas|O|O||D||1
50335403|Pera asiática orgánicas secas|O|O||D||1
50335404|Pera bartlett orgánicas secas|O|O||D||1
50335405|Pera best ever orgánicas secas|O|O||D||1
50335406|Pera beth orgánicas secas|O|O||D||1
50335407|Pera beurre orgánicas secas|O|O||D||1
50335408|Pera bosc orgánicas secas|O|O||D||1
50335409|Pera clapp favorita orgánicas secas|O|O||D||1
50335410|Pera comice orgánicas secas|O|O||D||1
50335411|Pera concorde orgánicas secas|O|O||D||1
50335412|Pera conference orgánicas secas|O|O||D||1
50335413|Pera crimson rojo orgánicas secas|O|O||D||1
50335414|Peras d’ anjou orgánicas secas|O|O||D||1
50335415|Pera dr jules guyot orgánicas secas|O|O||D||1
50335416|Peras early orgánicas secas|O|O||D||1
50335417|Peras emperador carmelito orgánicas secas|O|O||D||1
50335418|Peras forelle orgánicas secas|O|O||D||1
50335419|Pera mantequilla francesa orgánicas secas|O|O||D||1
50335420|Pera glou morceau orgánicas secas|O|O||D||1
50335421|Pera hosui orgánicas secas|O|O||D||1
50335422|Pera mantequilla italiana orgánicas secas|O|O||D||1
50335423|Pera jargonelle orgánicas secas|O|O||D||1
50335424|Pera juno orgánicas secas|O|O||D||1
50335425|Para kaiserlouise bonne de jersey orgánicas secas|O|O||D||1
50335426|Pera keiffer orgánicas secas|O|O||D||1
50335427|Pera rey royal orgánicas secas|O|O||D||1
50335428|Pera limonera orgánicas secas|O|O||D||1
50335429|Pera merton pride orgánicas secas|O|O||D||1
50335430|Pera mauntain bartlette orgánicas secas|O|O||D||1
50335431|Pera oliver de serrers orgánicas secas|O|O||D||1
50335432|Pera onward orgánicas secas|O|O||D||1
50335433|Pera packham´s triumph orgánicas secas|O|O||D||1
50335434|Pera paraíso orgánicas secas|O|O||D||1
50335435|Pera passe crassane orgánicas secas|O|O||D||1
50335436|Pera perry orgánicas secas|O|O||D||1
50335437|Pera bartlette rojo orgánicas secas|O|O||D||1
50335438|Pera dánjou  rojo orgánicas secas|O|O||D||1
50335439|Pera rocha orgánicas secas|O|O||D||1
50335440|Pera rosey rojo orgánicas secas|O|O||D||1
50335441|Pera rosy roja orgánicas secas|O|O||D||1
50335442|Pera majestuosa royal orgánicas secas|O|O||D||1
50335443|Pera ruby rojo orgánicas secas|O|O||D||1
50335444|Pera santa maria orgánicas secas|O|O||D||1
50335445|Pera seckel orgánicas secas|O|O||D||1
50335446|Pera sensación orgánicas secas|O|O||D||1
50335447|Pera crimson estrella orgánicas secas|O|O||D||1
50335448|Pera crimson stark orgánicas secas|O|O||D||1
50335449|Pera bartlette de verano orgánicas secas|O|O||D||1
50335450|Pera verano dorado orgánicas secas|O|O||D||1
50335451|Pera sol dorado orgánicas secas|O|O||D||1
50335452|Pera sunprite orgánicas secas|O|O||D||1
50335453|Pera taylors dorado orgánicas secas|O|O||D||1
50335454|Pera taylors rojo orgánicas secas|O|O||D||1
50335455|Pera tientsin orgánicas secas|O|O||D||1
50335456|Pera tosca orgánicas secas|O|O||D||1
50335457|Pera warden  orgánicas secas|O|O||D||1
50335458|Pera williams bon chretien orgánicas secas|O|O||D||1
50335459|Pera williams orgánicas secas|O|O||D||1
50335460|Pera nelis de invierno orgánicas secas|O|O||D||1
50335500|Caquis orgánicos secos|O|O||D||1
50335501|Caqui americano orgánicas secas|O|O||D||1
50335502|Caqui sapote negro orgánicas secas|O|O||D||1|Caqui zapote negro orgánico seco
50335503|Caqui chapote / negro orgánicas secas|O|O||D||1
50335504|Caqui dátale ciruela orgánicas secas|O|O||D||1
50335505|Caqui fuyu orgánicas secas|O|O||D||1
50335506|Caqui gigante fuyu orgánicas secas|O|O||D||1
50335507|Caqui hachiya orgánicas secas|O|O||D||1
50335508|Caqui mantequilla / mabolo orgánicas secas|O|O||D||1
50335509|Caqui príncipe ito orgánicas secas|O|O||D||1
50335510|Caqui brillante royal orgánicas secas|O|O||D||1
50335511|Caqui sharon orgánicas secas|O|O||D||1
50335512|Caqui triumph orgánicas secas|O|O||D||1
50335600|Piñas orgánicas secas|O|O||D||1
50335601|Piña chirimoya orgánicas secas|O|O||D||1|Atemoya orgánica seca
50335602|Piña dorada orgánicas secas|O|O||D||1
50335603|Piña hilo orgánicas secas|O|O||D||1
50335604|Piña kona sugarloaf orgánicas secas|O|O||D||1
50335605|Piña reina natal orgánicas secas|O|O||D||1
50335606|Piña pernabuco orgánicas secas|O|O||D||1
50335607|Piña español rojo orgánicas secas|O|O||D||1
50335608|Piña cayen suave orgánicas secas|O|O||D||1
50335609|Piña sugarloaf orgánicas secas|O|O||D||1
50335610|Piña variegated orgánicas secas|O|O||D||1
50335700|Ciruelos Damascos orgánicos secos|O|O||D||1
50335701|Ciruelo / damasco negro kat orgánico seco|O|O||D||1
50335702|Ciruelo / damasco gusto azul orgánico seco|O|O||D||1
50335703|Ciruelo / damasco corazón de crimson orgánico seco|O|O||D||1
50335704|Ciruelo / damasco dapply dandy orgánico seco|O|O||D||1
50335705|Ciruelo / damasco dapple fuego orgánico seco|O|O||D||1
50335706|Ciruelo / damasco  dapple temprano orgánico seco|O|O||D||1
50335707|Ciruelo / damasco  caída de sabor orgánico seco|O|O||D||1
50335708|Ciruelo / damasco sabor de oro orgánico seco|O|O||D||1
50335709|Ciruelo / damasco sabor granada orgánico seco|O|O||D||1
50335710|Ciruelo / damasco sabor de corazón orgánico seco|O|O||D||1
50335711|Ciruelo / damasco joya de sabor orgánico seco|O|O||D||1
50335712|Ciruelo / damasco sabor de rey orgánico seco|O|O||D||1
50335713|Ciruelo / damasco sabor de reina orgánico seco|O|O||D||1
50335714|Ciruelo / damasco sabor supremo orgánico seco|O|O||D||1
50335715|Ciruelo / damasco sabor premio orgánico seco|O|O||D||1
50335716|Ciruelo / damasco saborella orgánico seco|O|O||D||1
50335717|Ciruelo / damasco saborrico orgánico seco|O|O||D||1
50335718|Ciruelo / damasco  sabor rosa orgánico seco|O|O||D||1
50335719|Ciruelo / damasco orgullo geo orgánico seco|O|O||D||1
50335720|Ciruelo / damasco kat rojo orgánico seco|O|O||D||1
50335721|Ciruelo / damasco premio royal orgánico seco|O|O||D||1
50335722|Ciruelo / damasco rosa sierra orgánico seco|O|O||D||1
50335723|Ciruelo / damasco geisha dulce orgánico seco|O|O||D||1
50335800|Ciruelas orgánicas secas|O|O||D||1
50335801|Ciruela joya amber orgánicas secas|O|O||D||1
50335802|Ciruela angeleno orgánicas secas|O|O||D||1
50335803|Ciruela aurora orgánicas secas|O|O||D||1
50335804|Ciruela otoño bonito orgánicas secas|O|O||D||1
50335805|Ciruela gigante de otoño orgánicas secas|O|O||D||1
50335806|Ciruela orgullo de otoño orgánicas secas|O|O||D||1
50335807|Ciruela rosa de otoño orgánicas secas|O|O||D||1
50335808|Ciruela playero orgánicas secas|O|O||D||1
50335809|Ciruela betty anne orgánicas secas|O|O||D||1
50335810|Ciruela belleza negra orgánicas secas|O|O||D||1
50335811|Ciruela bullase negra orgánicas secas|O|O||D||1
50335812|Ciruela diamante negro orgánicas secas|O|O||D||1
50335813|Ciruela gigante negro orgánicas secas|O|O||D||1
50335814|Ciruela hielo negro orgánicas secas|O|O||D||1
50335815|Ciruela esplendor negro orgánicas secas|O|O||D||1
50335816|Ciruela ámbar negro orgánicas secas|O|O||D||1
50335817|Ciruela purpura orgánicas secas|O|O||D||1
50335818|Ciruela  carsbad orgánicas secas|O|O||D||1
50335819|Ciruela casselman orgánicas secas|O|O||D||1
50335820|Ciruela catalina orgánicas secas|O|O||D||1
50335821|Ciruela damson orgánicas secas|O|O||D||1
50335822|Ciruela dolly orgánicas secas|O|O||D||1
50335823|Ciruela earlireina orgánicas secas|O|O||D||1
50335824|Ciruela rosa early orgánicas secas|O|O||D||1
50335825|Ciruela ébano mayo orgánicas secas|O|O||D||1
50335826|Ciruela ébano orgánicas secas|O|O||D||1
50335827|Ciruela corazón de elefante orgánicas secas|O|O||D||1
50335828|Ciruela belleza de esmeralda orgánicas secas|O|O||D||1
50335829|Ciruela emperatriz orgánicas secas|O|O||D||1
50335830|Ciruela libertad orgánicas secas|O|O||D||1
50335831|Ciruela friar orgánicas secas|O|O||D||1
50335832|Ciruela rojo gar orgánicas secas|O|O||D||1
50335833|Ciruela gobernador orgánicas secas|O|O||D||1
50335834|Ciruela rosa grande orgánicas secas|O|O||D||1
50335835|Ciruela green gage orgánicas secas|O|O||D||1|Ciruela calibre verde orgánica seca
50335836|Ciruela greengage orgánicas secas|O|O||D||1
50335837|Ciruela hiromi orgánicas secas|O|O||D||1
50335838|Ciruela hiromi rojo orgánicas secas|O|O||D||1
50335839|Ciruela vacacion orgánicas secas|O|O||D||1
50335840|Ciruela howard sol orgánicas secas|O|O||D||1
50335841|Ciruela tipo interspecific orgánicas secas|O|O||D||1
50335842|Ciruela jamaico orgánicas secas|O|O||D||1
50335843|Ciruela joanna rojo orgánicas secas|O|O||D||1
50335844|Ciruela kelsey orgánicas secas|O|O||D||1
50335845|Ciruela jaime rey orgánicas secas|O|O||D||1
50335846|Ciruela laroda orgánicas secas|O|O||D||1
50335847|Ciruela rosa tarde orgánicas secas|O|O||D||1
50335848|Ciruela rosa linda orgánicas secas|O|O||D||1
50335849|Ciruela estrella solitaria orgánicas secas|O|O||D||1
50335850|Ciruela mariposa orgánicas secas|O|O||D||1
50335851|Ciruela mercado negro orgánicas secas|O|O||D||1
50335852|Ciruela mercado rojo orgánicas secas|O|O||D||1
50335853|Ciruela maribel orgánicas secas|O|O||D||1
50335854|Ciruelas sol de octubre orgánicas secas|O|O||D||1
50335855|Ciruela owen t orgánicas secas|O|O||D||1
50335856|Ciruela perdrigon orgánicas secas|O|O||D||1
50335857|Ciruela placer rosado orgánicas secas|O|O||D||1
50335858|Ciruela  presidente orgánicas secas|O|O||D||1
50335859|Ciruela hora prima orgánicas secas|O|O||D||1|Ciruela prime time orgánica seca
50335860|Ciruela majestad purpura orgánicas secas|O|O||D||1
50335861|Ciruela reina rosa orgánicas secas|O|O||D||1
50335862|Ciruela quetsch orgánicas secas|O|O||D||1
50335863|Ciruela belleza roja orgánicas secas|O|O||D||1
50335864|Ciruela camino rojo orgánicas secas|O|O||D||1
50335865|Ciruela ram rojo orgánicas secas|O|O||D||1
50335866|Ciruela rosa roja orgánicas secas|O|O||D||1
50335867|Ciruela rojo rico orgánicas secas|O|O||D||1
50335868|Ciruela romaro orgánicas secas|O|O||D||1
50335869|Ciruela diamante rojo orgánicas secas|O|O||D||1
50335870|Ciruela rojo royal orgánicas secas|O|O||D||1
50335871|Ciruela royal zee orgánicas secas|O|O||D||1
50335872|Ciruela roysum orgánicas secas|O|O||D||1
50335873|Ciruela santa rosa orgánicas secas|O|O||D||1
50335874|Ciruela zafiro orgánicas secas|O|O||D||1
50335875|Ciruela sloe orgánicas secas|O|O||D||1
50335876|Ciruela sta catherine orgánicas secas|O|O||D||1
50335877|Ciruela bullase blanco orgánicas secas|O|O||D||1
50335900|Granadas orgánicas secas|O|O||D||1
50335901|Granada foothhill orgánicas secas|O|O||D||1
50335902|Granada, granada orgánicas secas|O|O||D||1|Granada orgánica seca
50335903|Granada rojo feliz orgánicas secas|O|O||D||1
50335904|Granada nana orgánicas secas|O|O||D||1
50335905|Granada rojo de pat orgánicas secas|O|O||D||1
50335906|Granada pinkhan orgánic|O|O||D||1
50335907|Granada terciopelo morado orgánicas secas|O|O||D||1
50335908|Granada grandioso orgánicas secas|O|O||D||1
50336000|Pomelos orgánicos secos|O|O||D||1
50336001|Pomelo chandler orgánico seco|O|O||D||1
50336002|Pomelo hirado butan orgánico seco|O|O||D||1
50336003|Pomelo liang ping yau orgánico seco|O|O||D||1
50336004|Pomelo panda wangi orgánico seco|O|O||D||1
50336005|Pomelo rosado orgánico seco|O|O||D||1
50336006|Pomelo shaddock rojo orgánico seco|O|O||D||1
50336007|Pomelo siamese dulce orgánico seco|O|O||D||1
50336008|Pomelo waingwright orgánico seco|O|O||D||1
50336100|Membrillos orgánicos secos|O|O||D||1
50336101|Membrillo campeón orgánico seco|O|O||D||1
50336102|Membrillo piña orgánico seco|O|O||D||1
50336103|Membrillo smyma orgánico seco|O|O||D||1
50336200|Frambuesas orgánicas secas|O|O||D||1
50336201|Frambuesa americana roja orgánicas secas|O|O||D||1
50336202|Frambuesa bailey reinasland orgánicas secas|O|O||D||1
50336203|Frambuesa negra orgánicas secas|O|O||D||1
50336204|Frambuesa oscura orgánicas secas|O|O||D||1
50336205|Frambuesa deliciosa orgánicas secas|O|O||D||1
50336206|Frambuesa enano focke orgánicas secas|O|O||D||1
50336207|Frambuesa focke hojagris orgánicas secas|O|O||D||1
50336208|Frambuesa focke fresa orgánicas secas|O|O||D||1
50336209|Frambuesa  focke amarillo himalaya orgánicas secas|O|O||D||1
50336210|Frambuesa dorado orgánic|O|O||D||1
50336211|Frambuesa gris nuevo mexico orgánicas secas|O|O||D||1
50336212|Frambuesa jepson blancobark orgánicas secas|O|O||D||1
50336213|Frambuesa kellogs san diego orgánicas secas|O|O||D||1
50336214|Frambuesa leucodemis blancobark orgánicas secas|O|O||D||1
50336215|Frambuesa munz cuyamaca orgánicas secas|O|O||D||1
50336216|Frambuesa peck bartons orgánicas secas|O|O||D||1
50336217|Frambuesa flor morada orgánicas secas|O|O||D||1
50336218|Frambuesa roadside orgánicas secas|O|O||D||1
50336219|Frambuesa san diego orgánicas secas|O|O||D||1
50336220|Frambuesa nieve orgánicas secas|O|O||D||1
50336221|Frambuesa pico de nieve orgánicas secas|O|O||D||1
50336222|Frambuesa hoja de fresa orgánicas secas|O|O||D||1
50336223|Frambuesa cultivo dulce orgánicas secas|O|O||D||1
50336224|Frambuesa tor y gris blancobark orgánicas secas|O|O||D||1
50336225|Frambuesa caribe orgánicas secas|O|O||D||1
50336226|Frambuesa blancobark orgánicas secas|O|O||D||1
50336227|Frambuesa vino orgánicas secas|O|O||D||1
50336228|Frambuesa himalaya amarillo orgánicas secas|O|O||D||1
50336229|Frambuesa yu-shan orgánicas secas|O|O||D||1
50336300|Ruibarbos orgánicos secos|O|O||D||1|Acelgas rojas orgánicas secas
50336301|Ruibarbo crimson rojo orgánico seco|O|O||D||1|Acelga roja crimson orgánica seca
50336302|Ruibarbo champagne temprana orgánico seco|O|O||D||1|Acelga roja champagne temprana orgánica seca
50336303|Ruibarbo glasrey perpetual  orgánico seco|O|O||D||1|Acelga roja glasrey perpetual orgánica seca
50336304|Ruibarbo sutton orgánico seco|O|O||D||1|Acelga roja sutton orgánica seca
50336305|Ruibarbo timperley temprano orgánico seco|O|O||D||1|Acelga roja temprana de Timperley orgánica seca
50336306|Ruibarbo valentina orgánico seco|O|O||D||1|Acelga roja valentina orgánica seca
50336307|Ruibarbo victoria orgánico seco|O|O||D||1|Acelga roja victoria orgánica seca
50336308|Ruibarbo zwolle de cemilla orgánico seco|O|O||D||1|Acelga roja zwolle de semilla orgánica seca
50336309|Ruibarbo macdonald orgánico seco|O|O||D||1|Acelga roja macdonald orgánica seca
50336310|Ruibarbo tilden orgánico seco|O|O||D||1|Acelga roja tilden orgánica seca
50336400|Escaramujos orgánicos secos|O|O||D||1|Rosa mosqueta orgánicas secas
50336401|Escaramujo rosa brier orgánico seco|O|O||D||1|Rosa mosqueta brier orgánica seca
50336402|Escaramujo rosa elegante orgánico seco|O|O||D||1|Rosa mosqueta elegante orgánica seca
50336403|Escaramujo rosa rugosa orgánico seco|O|O||D||1|Rosa mosqueta rugosa orgánica seca
50336404|Escaramujo rosa burnet o scotch orgánico seco|O|O||D||1|Rosa mosqueta burnet o scotch orgánica seca
50336500|Sapotes orgánicos secos|O|O||D||1|Zapotes orgánicos secos
50336501|Sapote blanco orgánico seco|O|O||D||1|Zapote blanco orgánico seco
50336502|Sapote negro orgánico seco|O|O||D||1|Zapote negro orgánico seco
50336600|Bayas saskatoon orgánicas secas|O|O||D||1|Fresas de junio orgánicas secas
50336601|Baya mielmadera saskatoon orgánicas secas|O|O||D||1|Fresa de junio mielmadera orgánica seca
50336602|Baya northline saskatoon orgánicas secas|O|O||D||1|Fresa de junio northline orgánica seca
50336603|Baya saskatoon ahumado orgánicas secas|O|O||D||1|Fresa de junio smoky orgánica seca
50336604|Baya saskatoon thiessen orgánicas secas|O|O||D||1|Fresa de junio thiessen orgánica seca
50336700|Fresas orgánicas secas|O|O||D||1
50336701|Fresa chandler orgánicas secas|O|O||D||1
50336702|Fresa rumbo junio orgánicas secas|O|O||D||1|Fresa temporada de junio orgánica seca
50336703|Fresa rumbo siempre orgánicas secas|O|O||D||1|Fresa de todo el año orgánica seca
50336800|Manzanas dulces orgánicas seca|O|O||D||1|Saramuyos orgánicos secos
50336801|Manzana kampong malve dulce orgánicas secas|O|O||D||1|Saramuyo kampong mauve orgánico seco
50336802|Manzana dulce sin pepa orgánicas secas|O|O||D||1|Saramuyo sin semilla orgánico seco
50336803|Manzana dulce thai lessand orgánicas secas|O|O||D||1|Saramuyo thai lessand orgánico seco
50336900|Tamarillos orgánicos secos|O|O||D||1|Tomates de árbol orgánico seco
50336901|Tamarindo amberlea dorado orgánico seco|O|O||D||1|Tomate de árbol amberlea dorado orgánico seco
50336902|Tamarindo calvo dorado orgánico seco|O|O||D||1|Tomate de árbol calvo dorado orgánico seco
50336903|Tamarindo mina de oro orgánico seco|O|O||D||1|Tomate de árbol mina de oro orgánico seco
50336904|Tamarindo oratia rojo orgánico seco|O|O||D||1|Tomate de árbol oratia rojo orgánico seco
50336905|Tamarindo beau rojo orgánico seco|O|O||D||1|Tomate de árbol beau rojo orgánico seco
50336906|Tamarindo delicia roja orgánico seco|O|O||D||1|Tomate de árbol delicia roja orgánico seco
50337000|Frutas Nominant orgánicas secas|O|O||D||1|Frutas predominantes orgánicas secas
50337001|Cupania orgánicas secas|O|O||D||1|Ackee orgánicas secas
50337002|Babaco orgánico seco|O|O||D||1|Carica pentágona orgánica seca
50337003|Banana flor orgánicas secas|O|O||D||1|Flor de plátano orgánica seca
50337004|Baobab orgánicas secas|O|O||D||1
50337005|Naranja agria orgánicas secas|O|O||D||1
50337006|Canistel orgánicas secas|O|O||D||1|Zapote amarillo orgánico seco
50337007|Baya nublosa orgánicas secas|O|O||D||1|Mora de los pantanos orgánicas secas
50337008|Coco orgánico seco|O|O||D||1
50337009|Baya drew orgánicas secas|O|O||D||1|Baya de gota orgánicas secas
50337010|Durian orgánicas secas|O|O||D||1|Durio orgánico seco
50337011|Baya elder orgánicas secas|O|O||D||1|Baya de sauco orgánicas secas
50337012|Feijoa orgánicas secas|O|O||D||1|Guayabo del Brasil orgánico seco
50337013|Mora orgánicas secas|O|O||D||1
50337014|Cretaegus orgánicas secas|O|O||D||1|Majuelo orgánico seco
50337015|Baya miel orgánicas secas|O|O||D||1|Madreselva azul orgánica seca
50337016|Jaca orgánicas secas|O|O||D||1|Yaca orgánica seca
50337017|Jambolan orgánicas secas|O|O||D||1
50337018|Jujube orgánicas secas|O|O||D||1|Azufaifa orgánica seca
50337019|Liches orgánico secos secos|O|O||D||1|Lichi orgánico seco
50337020|Mangostinos orgánico secos secos|O|O||D||1|Mangostán orgánico seco
50337021|Medlar orgánicas secas|O|O||D||1
50337022|Mombines orgánicas secas|O|O||D||1|Hobo orgánico seco
50337023|Monstera orgánicas secas|O|O||D||1|Cerimán orgánico seco
50337024|Pepinos orgánico seco|O|O||D||1|Pepino dulce orgánico seco
50337025|Platono orgánico seco|O|O||D||1|Plátano macho orgánico seco
50337026|Peras en escabeche orgánicas secas|O|O||D||1|Tuna orgánica seca
50337027|Mamonsillo orgánico seco|O|O||D||1|Guaya orgánica seca
50337028|Rambután orgánico seco|O|O||D||1|Achotillo orgánico seco
50337029|Manzana rosa orgánicas secas|O|O||D||1|Pero de agua orgánico seco
50337030|Rosele orgánicas secas|O|O||D||1|Flor de jamaica orgánica seca
50337031|Baya rowan orgánicas secas|O|O||D||1|Serba orgánica seca
50337032|Baya buckhom de mar orgánicas secas|O|O||D||1|Espino amarillo orgánico seco
50337033|Baya plata orgánicas secas|O|O||D||1|Olivo de otoño orgánico seco
50337034|Baya sorbete orgánico seco|O|O||D||1|Serba orgánica seca
50337035|Wanabana orgánicas secas|O|O||D||1|Guanábana orgánica seca
50337036|Manzana estrella orgánicas secas|O|O||D||1|Cainito orgánico seco
50337037|Tamarindo orgánico seco|O|O||D||1
50337100|Aronias orgánicas secas|O|O||D||1
50337101|Aronia magia de otoño orgánicas secas|O|O||D||1
50337102|Aronia brillantísima orgánicas secas|O|O||D||1
50337103|Aronia nero orgánicas secas|O|O||D||1
50337104|Aronia viquingo orgánicas secas|O|O||D||1
50337200|Aceitunas orgánicas secas|O|O||D||1
50337201|Aceitunas agrinion orgánicas secas|O|O||D||1|Aceituna agrinion orgánica seca
50337202|Aceitunas aleppo orgánicas secas|O|O||D||1|Aceituna aleppo orgánica seca
50337203|Aceitunas  alfonso orgánicas secas|O|O||D||1|Aceituna alfonso orgánica seca
50337204|Aceitunas  amfisa orgánicas secas|O|O||D||1|Aceituna amfisa orgánica seca
50337205|Aceitunas  arauco orgánicas secas|O|O||D||1|Aceituna arauco orgánica seca
50337206|Aceitunas  arbequina orgánicas secas|O|O||D||1|Aceituna arbequina orgánica seca
50337207|Aceitunas  atlanta orgánicas secas|O|O||D||1|Aceituna atlanta orgánica seca
50337208|Aceitunas  cerignola orgánicas secas|O|O||D||1|Aceituna cerignola orgánica seca
50337209|Aceitunas  cracked provencal orgánicas secas|O|O||D||1|Aceituna cracked provencal orgánica seca
50337210|Aceitunas  empeltre orgánicas secas|O|O||D||1|Aceituna empeltre orgánica seca
50337211|Aceitunas gaeta  orgánicas secas|O|O||D||1|Aceituna gaeta orgánica seca
50337212|Aceitunas hondroelia orgánicas secas|O|O||D||1|Aceituna hondroelia orgánica seca
50337213|Aceitunas kalamata orgánicas secas|O|O||D||1|Aceituna kalamata orgánica seca
50337214|Aceitunas kura orgánicas secas|O|O||D||1|Aceituna kura orgánica seca
50337215|Aceitunas ligurian orgánicas secas|O|O||D||1|Aceituna ligurian orgánica seca
50337216|Aceitunas lucque orgánicas secas|O|O||D||1|Aceituna lucque orgánica seca
50337217|Aceitunas lugano orgánicas secas|O|O||D||1|Aceituna lugano orgánica seca
50337218|Aceitunas manzanilla orgánicas secas|O|O||D||1|Aceituna manzanilla orgánica seca
50337219|Aceitunas marche orgánicas secas|O|O||D||1|Aceituna marche orgánica seca
50337220|Aceitunas misión orgánicas secas|O|O||D||1|Aceituna misión orgánica seca
50337221|Aceitunas nafplion verde orgánicas secas|O|O||D||1|Aceituna nafplion verde orgánica seca
50337222|Aceitunas nicoise orgánicas secas|O|O||D||1|Aceituna nicoise orgánica seca
50337223|Aceitunas nyons orgánicas secas|O|O||D||1|Aceituna nyons orgánica seca
50337224|Aceitunas picholine orgánicas secas|O|O||D||1|Aceituna picholine orgánica seca
50337225|Aceitunas ponentine orgánicas secas|O|O||D||1|Aceituna ponentine orgánica seca
50337226|Aceitunas royal orgánicas secas|O|O||D||1|Aceituna royal orgánica seca
50337227|Aceitunas seracena orgánicas secas|O|O||D||1|Aceituna seracena orgánica seca
50337228|Aceitunas sevillano orgánicas secas|O|O||D||1|Aceituna sevillano orgánica seca
50337229|Aceitunas sicilian orgánicas secas|O|O||D||1|Aceituna sicilian orgánica seca
50337230|Aceitunas toscanelle orgánicas secas|O|O||D||1|Aceituna toscanelle orgánica seca
50341500|Manzanas congeladas|O|O||D||1
50341501|Manzanas akane congeladas|O|O||D||1|Manzana akane congeladas
50341502|Manzana ambrosia congelada|O|O||D||1
50341503|Manzanas api congeladas|O|O||D||1|Manzana api congeladas
50341504|Manzanas baldwin congeladas|O|O||D||1|Manzana baldwin congeladas
50341505|Manzanas braebum congeladas|O|O||D||1|Manzana braebum congeladas
50341506|Manzanas bramley congeladas|O|O||D||1|Manzana bramley congeladas
50341507|Manzana joven bramley congelado|O|O||D||1
50341508|Manzana calville blanche d’hiver congelado|O|O||D||1
50341509|Manzana cameo congeladas|O|O||D||1
50341510|Manzana charles ross congeladas|O|O||D||1
50341511|Manzana codlin congeladas|O|O||D||1
50341512|Manzana cortland congeladas|O|O||D||1
50341513|Manzana costard congeladas|O|O||D||1
50341514|Manzana court pendu plat congeladas|O|O||D||1
50341515|Manzana  cox´s orange pippin congeladas|O|O||D||1
50341516|Manzana crab congeladas|O|O||D||1
50341517|Manzana crispin congeladas|O|O||D||1
50341518|Manzana deliciosa congeladas|O|O||D||1
50341519|Manzana duquesa congeladas|O|O||D||1
50341520|Manzana earligold congeladas|O|O||D||1
50341521|Manzana early mcintosh congeladas|O|O||D||1
50341522|Manzana elstar congeladas|O|O||D||1
50341523|Manzana empire congeladas|O|O||D||1
50341524|Manzana flower of kent congeladas|O|O||D||1
50341525|Manzana fiji congeladas|O|O||D||1
50341526|Manzana gala congeladas|O|O||D||1
50341527|Manzana gascoyne´s scarlet congeladas|O|O||D||1
50341528|Manzana gillyflower congeladas|O|O||D||1
50341529|Manzana ginger gold congeladas|O|O||D||1
50341530|Manzana gladstone congeladas|O|O||D||1
50341531|Manzana gloster congeladas|O|O||D||1
50341532|Manzana gold supreme congeladas|O|O||D||1
50341533|Manzana dorado delicious congeladas|O|O||D||1
50341534|Manzana dorado nobel congeladas|O|O||D||1
50341535|Manzana granny smith congeladas|O|O||D||1
50341536|Manzana gravenstain congeladas|O|O||D||1
50341537|Manzana greening congeladas|O|O||D||1
50341538|Manzana greensleeves congeladas|O|O||D||1
50341539|Manzana honeycrisp congeladas|O|O||D||1
50341540|Manzana howgate wonder congeladas|O|O||D||1
50341541|Manzana roja ida congeladas|O|O||D||1
50341542|Manzana james grives congeladas|O|O||D||1
50341543|Manzana jersey mac congeladas|O|O||D||1
50341544|Manzana jaster congeladas|O|O||D||1
50341545|Manzana jonagold congeladas|O|O||D||1
50341546|Manzana jonamac congeladas|O|O||D||1
50341547|Manzana  jonathan  congeladas|O|O||D||1
50341548|Manzana katy congeladas|O|O||D||1
50341549|Manzana kidd´s orange rojo congeladas|O|O||D||1
50341550|Manzana dama congeladas|O|O||D||1
50341551|Manzana ley de roma congeladas|O|O||D||1
50341552|Manzana laxton congeladas|O|O||D||1
50341553|Manzana lord derby congeladas|O|O||D||1
50341554|Manzana macoun  congeladas|O|O||D||1
50341555|Manzana mcintosh congeladas|O|O||D||1
50341556|Manzana mutsu congeladas|O|O||D||1
50341557|Manzana newtown pippin congeladas|O|O||D||1
50341558|Manzana northen spy congeladas congeladas|O|O||D||1
50341559|Manzana orleans reinette congeladas|O|O||D||1
50341560|Manzana ozark gold congeladas|O|O||D||1
50341561|Manzana pacific rosa congeladas|O|O||D||1
50341562|Manzana paula roja congeladas|O|O||D||1
50341563|Manzana peamain congeladas|O|O||D||1
50341564|Manzana dama rosada congeladas|O|O||D||1
50341565|Manzana pippin congeladas|O|O||D||1
50341566|Manzana pitmaston pineapple congeladas|O|O||D||1
50341567|Manzana pomme dàpi congeladas|O|O||D||1
50341568|Manzana prime dorado congeladas|O|O||D||1
50341569|Manzana roja astrakhan congeladas|O|O||D||1
50341570|Manzana roja boscoop congeladas|O|O||D||1
50341571|Manzana  roja chief congeladas|O|O||D||1
50341572|Manzana roja delicious congeladas|O|O||D||1
50341573|Manzana roja gravenstain congeladas|O|O||D||1
50341574|Manzana roja roma congeladas|O|O||D||1
50341575|Manzanarojo stayman congeladas|O|O||D||1
50341576|Manzana roja york congeladas|O|O||D||1
50341577|Manzana reinette congeladas|O|O||D||1
50341578|Manzana belleza de roma congeladas|O|O||D||1
50341579|Manzana russet congeladas|O|O||D||1
50341580|Manzana sierra belleza congeladas|O|O||D||1
50341581|Manzana spartan congeladas|O|O||D||1
50341582|Manzana stark crimson congeladas|O|O||D||1
50341583|Manzana starking congeladas|O|O||D||1
50341584|Manzana stayman congeladas|O|O||D||1
50341585|Manzana stayman winesap congeladas|O|O||D||1
50341586|Manzana verano rambo congeladas|O|O||D||1
50341587|Manzana tsugaru congeladas|O|O||D||1
50341588|Manzana veinte onzas congeladas|O|O||D||1
50341589|Manzana tydeman rojo congeladas|O|O||D||1
50341590|Manzana vistabella congeladas|O|O||D||1
50341591|Manzana weatley congeladas|O|O||D||1
50341592|Manzana blanco joanetine congeladas|O|O||D||1
50341593|Manzana blanco transparent congeladas|O|O||D||1
50341594|Manzana winesap congeladas|O|O||D||1
50341595|Manzana worcester congeladas|O|O||D||1
50341596|Manzana york imperial congeladas|O|O||D||1
50341600|Albaricoques congelados|O|O||D||1|Chabacanos congelados
50341601|Abaricoques ambercot congeladas|O|O||D||1|Chabacano ambercot congelado
50341602|Albaricoques apache congeladas|O|O||D||1|Chabacano apache congelado
50341603|Albaricoques brittany dorado congeladas|O|O||D||1|Chabacano brittany dorado congelado
50341604|Albaricoque negro congeladas|O|O||D||1|Chabacano negro congelado
50341605|Albaricoque blenheim congeladas|O|O||D||1|Chabacano blenheim congelado
50341606|Albaricoque bonny congeladas|O|O||D||1|Chabacano bonny congelado
50341607|Albaricoque biluda congeladas|O|O||D||1|Chabacano biluda congelado
50341608|Albaricoque castlebrite congeladas|O|O||D||1|Chabacano castlebrite congelado
50341609|Albaricoque  clutha gold congeladas|O|O||D||1|Chabacano clutha gold congelado
50341610|Albaricoque clutha sun congeladas|O|O||D||1|Chabacano clutha sun congelado
50341611|Albaricoque derby royal congeladas|O|O||D||1|Chabacano derby royal congelado
50341612|Albaricoque dina congeladas|O|O||D||1|Chabacano dina congelado
50341613|Albaricoque earlicot congeladas|O|O||D||1|Chabacano earlicot congelado
50341614|Albaricoque earliman congeladas|O|O||D||1|Chabacano earliman congelado
50341615|Albaricoque early bright congeladas|O|O||D||1|Chabacano early bright congelado
50341616|Albaricoque  flaming gold congeladas|O|O||D||1|Chabacano flaming gold congelado
50341617|Albaricoque frenso congeladas|O|O||D||1|Chabacano frenso congelado
50341618|Albaricoque gold bright congeladas|O|O||D||1|Chabacano gold bright congelado
50341619|Albaricoque goldbar congeladas|O|O||D||1|Chabacano goldbar congelado
50341620|Albaricoque dorado sweet congeladas|O|O||D||1|Chabacano dorado sweet congelado
50341621|Albaricoque goldrich congeladas|O|O||D||1|Chabacano goldrich congelado
50341622|Albaricoque helena congeladas|O|O||D||1|Chabacano helena congelado
50341623|Albaricoque honeycot congeladas|O|O||D||1|Chabacano  congelado
50341624|Albaricoque imperial congeladas|O|O||D||1|Chabacano imperial congelado
50341625|Albaricoque jordanne congeladas|O|O||D||1|Chabacano jordanne congelado
50341626|Albaricoque jumbo cot congeladas|O|O||D||1|Chabacano jumbo cot congelado
50341627|Albaricoque kandy kot congeladas|O|O||D||1|Chabacano kandy kot congelado
50341628|Albaricoque katy congeladas|O|O||D||1|Chabacano katy congelado
50341629|Albaricoque rey congeladas|O|O||D||1|Chabacano rey congelado
50341630|Albaricoque lambertin congeladas|O|O||D||1|Chabacano lambertin congelado
50341631|Albaricoque loma congeladas|O|O||D||1|Chabacano loma congelado
50341632|Albaricoque lulu belle congeladas|O|O||D||1|Chabacano lulu belle congelado
50341633|Albaricoque modesto congeladas|O|O||D||1|Chabacano modesto congelado
50341634|Albaricoque moorpark congeladas|O|O||D||1|Chabacano moorpark congelado
50341635|Albaricoque naranja ojo congeladas|O|O||D||1|Chabacano naranja ojo congelado
50341636|Albaricoque palstein congeladas|O|O||D||1|Chabacano palstein congelado
50341637|Albaricoque patterson congeladas|O|O||D||1|Chabacano patterson congelado
50341638|Albaricoque perfection congeladas|O|O||D||1|Chabacano perfection congelado
50341639|Albaricoque poppy congeladas|O|O||D||1|Chabacano poppy congelado
50341640|Albaricoque poppycot congeladas|O|O||D||1|Chabacano poppy cot congelado
50341641|Albaricoque reina congeladas|O|O||D||1|Chabacano reina congelado
50341642|Albaricoque riland congeladas|O|O||D||1|Chabacano riland congelado
50341643|Albaricoque rival congeladas|O|O||D||1|Chabacano rival congelado
50341644|Albaricoque robada congeladas|O|O||D||1|Chabacano robada congelado
50341645|Albaricoque royal congeladas|O|O||D||1|Chabacano royal congelado
50341646|Albaricoque  royal blenheim congeladas|O|O||D||1|Chabacano royal blenheim congelado
50341647|Albaricoque  royal orange congeladas|O|O||D||1|Chabacano royal orange congelado
50341648|Albaricoque sundrop congeladas|O|O||D||1|Chabacano sundrop congelado
50341649|Albaricoque tilton congeladas|O|O||D||1|Chabacano tilton congelado
50341650|Albaricoque tomcot congeladas|O|O||D||1|Chabacano tomcot congelado
50341651|Albaricoque tracy congeladas|O|O||D||1|Chabacano tracy congelado
50341652|Albaricoque tri gem congeladas|O|O||D||1|Chabacano tri gem congelado
50341653|Albaricoque valley gold congeladas|O|O||D||1|Chabacano valley gold congelado
50341654|Albaricoque westley congeladas|O|O||D||1|Chabacano westley congelado
50341655|Albaricoque  york congeladas|O|O||D||1|Chabacano york congelado
50341700|Bananos congelados|O|O||D||1|Plátanos congelados
50341701|Bananas manzana congeladas|O|O||D||1|Plátano apple congelado
50341702|Bananas bebe congeladas|O|O||D||1|Plátano bebe congelado
50341703|Bananas burro congeladas|O|O||D||1|Plátano burro congelado
50341704|Bananas cavendish congeladas|O|O||D||1|Plátano cavendish congelado
50341705|Bananas dominico congeladas|O|O||D||1|Plátano dominico congelado
50341706|Bananas green congeladas|O|O||D||1|Plátano green congelado
50341707|Bananas gros michel congeladas|O|O||D||1|Plátano gros michel congelado
50341708|Bananas lacatan congeladas|O|O||D||1|Plátano lacatan congelado
50341709|Bananas dedo de dama congeladas|O|O||D||1|Plátano dedo de dama congelado
50341710|Bananas manzano congeladas|O|O||D||1|Plátano manzano congelado
50341711|Bananas mysore congeladas|O|O||D||1|Plátano mysore congelado
50341712|Bananas pisang mas congeladas|O|O||D||1|Plátano pisang mas congelado
50341713|Bananas rojo congeladas|O|O||D||1|Plátano rojo congelado
50341714|Bananas saba congeladas|O|O||D||1|Plátano saba congelado
50341715|Bananas sucrier congeladas|O|O||D||1|Plátano sucrier congelado
50341800|Barberries congelados|O|O||D||1|Berberís congelados
50341801|Berberís paleleaf congeladas|O|O||D||1|Berberí paleleaf congelado
50341802|Barberís chenault congeladas|O|O||D||1|Berberí chenault congelado
50341803|Barberís rojo congeladas|O|O||D||1|Berberí rojo congelado
50341804|Barberís wintergreen congeladas|O|O||D||1|Berberí wintergreen congelado
50341805|Barberís korean congeladas|O|O||D||1|Berberí korean congelado
50341806|Barberís mentor congeladas|O|O||D||1|Berberí mentor congelado
50341807|Barberís japanese congeladas|O|O||D||1|Berberí japanese congelado
50341808|Barberís atropurpurea congeladas|O|O||D||1|Berberí atropurpurea congelado
50341809|Barberís aurea congeladas|O|O||D||1|Berberí aurea congelado
50341810|Barberís bagatelle congeladas|O|O||D||1|Berberí bagatelle congelado
50341811|Barberís crimsom pygmy congeladas|O|O||D||1|Berberí crimsom pygmy congelado
50341812|Barberís kobold congeladas|O|O||D||1|Berberí kobold congelado
50341813|Barberís warty congeladas|O|O||D||1|Berberí warty congelado
50341814|Barberís europa congeladas|O|O||D||1|Berberí europa congelado
50341900|Gayubas congeladas|O|O||D||1|Rastreras congeladas
50341901|Gayuba alpine congeladas|O|O||D||1|Rastrera alpine congeladas
50341902|Gayuba roja congeladas|O|O||D||1|Rastrera roja congeladas
50341903|Gayuba común congeladas|O|O||D||1|Rastrera común congeladas
50342000|Moras congeladas|O|O||D||1|Zarzamoras congeladas
50342001|Mora apache congeladas|O|O||D||1|Zarzamora apache congeladas
50342002|Mora negro satín congeladas|O|O||D||1|Zarzamora negro satín congeladas
50342003|Mora congeladas|O|O||D||1|Zarzamora congeladas
50342004|Mora cherokee congeladas|O|O||D||1|Zarzamora cherokee congeladas
50342005|Mora chester congeladas|O|O||D||1|Zarzamora chéster congeladas
50342006|Mora dirksen congeladas|O|O||D||1|Zarzamora dirksen congeladas
50342007|Bayas josta congeladas|O|O||D||1|Zarzamora josta congeladas
50342008|Bayas logan congeladas|O|O||D||1|Zarzamora logan congeladas
50342009|Bayas marion congeladas|O|O||D||1|Zarzamora marion congeladas
50342010|Mora navaho congeladas|O|O||D||1|Zarzamora navaho congeladas
50342011|Bayanectar congeladas|O|O||D||1|Zarzamora néctar congeladas
50342012|Mora olallie congeladas|O|O||D||1|Zarzamora olallie congeladas
50342013|Bayatay congeladas|O|O||D||1|Zarzamora tay congeladas
50342014|Mora thomless hull congeladas|O|O||D||1|Zarzamora thomless hull congeladas
50342015|Bayayoung congeladas|O|O||D||1|Zarzamora young congeladas
50342100|Arándanos de mirto congelados|O|O||D||1|Mirtillos congelados
50342101|Arandanos bog congeladas|O|O||D||1|Mirtillo bog congelado
50342102|Arandanos enano congeladas|O|O||D||1|Mirtillo enano congelado
50342103|Arandanos montaña congeladas|O|O||D||1|Mirtillo de montaña congelado
50342104|Arandanos oval-leaved congeladas|O|O||D||1|Mirtillo oval-leaved congelado
50342200|Agrás congeladas|O|O||D||1|Frutos azules del bosque congelados
50342201|Agras bluecrop congeladas|O|O||D||1|Fruto azul del bosque bluecrop congelado
50342202|Agras bluetta congeladas|O|O||D||1|Fruto azul del bosque bluetta congelado
50342203|Agras brigitta congeladas|O|O||D||1|Fruto azul del bosque brigitta congelado
50342204|Agras chandler congeladas|O|O||D||1|Fruto azul del bosque chandler congelado
50342205|Agras duque congeladas|O|O||D||1|Fruto azul del bosque duque congelado
50342206|Agras hardyblue congeladas|O|O||D||1|Fruto azul del bosque hardyblue congelado
50342207|Agras legacy congeladas|O|O||D||1|Fruto azul del bosque legacy congelado
50342208|Agras misti congeladas|O|O||D||1|Fruto azul del bosque misti congelado
50342209|Agras nelson congeladas|O|O||D||1|Fruto azul del bosque nelson congelado
50342210|Agras northblue congeladas|O|O||D||1|Fruto azul del bosque northblue congelado
50342211|Agras northcountry congeladas|O|O||D||1|Fruto azul del bosque northcountry congelado
50342212|Agras northsky congeladas|O|O||D||1|Fruto azul del bosque northsky congelado
50342213|Agras patriot congeladas|O|O||D||1|Fruto azul del bosque patriot congelado
50342214|Agras spartan congeladas|O|O||D||1|Fruto azul del bosque spartan congelado
50342215|Agras toro congeladas|O|O||D||1|Fruto azul del bosque toro congelado
50342300|Frutas del pan congeladas|O|O||D||1
50342301|Fruta de pan chataigne congeladas|O|O||D||1|Fruta del pan chataigne congeladas
50342302|Fruta de pan sin pepa congeladas|O|O||D||1|Fruta del pan sin semilla congeladas
50342303|Fruta de pan corazón blanco congeladas|O|O||D||1|Fruta del pan corazón blanco congeladas
50342304|Fruta de pan corazón amarillo congeladas|O|O||D||1|Fruta del pan corazón amarillo congeladas
50342400|Chirimoyas congeladas|O|O||D||1|Annonas congeladas
50342401|Chirimoya bays congeladas|O|O||D||1|Annona bays congelada
50342402|Chirimoya bronceada congeladas|O|O||D||1|Annona bronceada congelada
50342403|Chirimoya burtons congeladas|O|O||D||1|Annona burtons congelada
50342404|Chirimoya burton favorite congeladas|O|O||D||1|Annona burton favorite congelada
50342405|Chirimoya jete congeladas|O|O||D||1|Annona jete congelada
50342406|Chirimoya reretai congeladas|O|O||D||1|Annona reretai congelada
50342407|Chirimoya smoothey congeladas|O|O||D||1|Annona smoothey congelada
50342408|Chirimoya españa congeladas|O|O||D||1|Annona españa congelada
50342409|Chirimoya blanco congeladas|O|O||D||1|Annona blanco congelada
50342500|Cerezas congeladas|O|O||D||1
50342501|Cereza amarelle congeladas|O|O||D||1
50342502|Cereza brooks congeladas|O|O||D||1
50342503|Cereza bigarreu congeladas|O|O||D||1
50342504|Cereza bing congeladas|O|O||D||1
50342505|Cereza republica negra congeladas|O|O||D||1
50342506|Cereza negro schmidt congeladas|O|O||D||1
50342507|Cereza negrotartarian congeladas|O|O||D||1
50342508|Cereza fiesta bing congeladas|O|O||D||1
50342509|Cereza garnet congeladas|O|O||D||1
50342510|Cereza rey congeladas|O|O||D||1
50342511|Cereza chapman congeladas|O|O||D||1
50342512|Cereza lapin congeladas|O|O||D||1
50342513|Cereza larian congeladas|O|O||D||1
50342514|Cereza dark guines congeladas|O|O||D||1
50342515|Cereza montmorency congeladas|O|O||D||1
50342516|Cereza duque congeladas|O|O||D||1
50342517|Cereza early rivers congeladas|O|O||D||1
50342518|Cereza ruby bing congeladas|O|O||D||1
50342519|Cereza santine congeladas|O|O||D||1
50342520|Cereza geans/guines congeladas|O|O||D||1
50342521|Cereza sonata congeladas|O|O||D||1
50342522|Cereza lambert congeladas|O|O||D||1
50342523|Cereza stella congeladas|O|O||D||1
50342524|Cereza sweethart congeladas|O|O||D||1
50342525|Cereza tartarian congeladas|O|O||D||1
50342527|Cereza maraschino congeladas|O|O||D||1
50342528|Cereza van congeladas|O|O||D||1
50342529|Cereza morello congeladas|O|O||D||1
50342530|Cereza royal ann congeladas|O|O||D||1
50342531|Cereza ranier congeladas|O|O||D||1
50342532|Cereza royal congeladas|O|O||D||1
50342600|Citrones congelados|O|O||D||1|Cidras congeladas
50342601|Citrones buddha´s hand congeladas|O|O||D||1|Cidra mano de Buda congelada
50342602|Citrones fingerojo congeladas|O|O||D||1|Cidra finger red congelada
50342603|Citrones fo shoukan congeladas|O|O||D||1|Cidra fo shoukan congelada
50342604|Cotrones bushakan congeladas|O|O||D||1|Cidra bushakan congelada
50342605|Citones diamante congeladas|O|O||D||1|Cidra diamante congelada
50342606|Citrones etrog congeladas|O|O||D||1|Cidra etrog congelada
50342607|Citrones ponderosa congeladas|O|O||D||1|Cidra ponderosa congelada
50342700|Arándanos congelados|O|O||D||1|Arándanos rojos congelados
50342701|Arandano ben lear congeladas|O|O||D||1|Arándano rojo ben lear congelado
50342702|Arandano early negro congeladas|O|O||D||1|Arándano rojo early negro congelado
50342703|Arandano gryclesik congeladas|O|O||D||1|Arándano rojo gryclesik congelado
50342704|Arandano  howe congeladas|O|O||D||1|Arándano rojo howe congelado
50342705|Bayas lingon congeladas|O|O||D||1|Arándano rojo lingon congelado
50342706|Arandano mcfarling congeladas|O|O||D||1|Arándano rojo mcfarling congelado
50342707|Arandano mountain congeladas|O|O||D||1|Arándano rojo mountain congelado
50342708|Arandano pilgrim congeladas|O|O||D||1|Arándano rojo pilgrim congelado
50342709|Arandano searless congeladas|O|O||D||1|Arándano rojo searless congelado
50342710|Arandano stevens congeladas|O|O||D||1|Arándano rojo stevens congelado
50342800|pasas de Corinto congeladas|O|O||D||1
50342801|Pasa hudson bay congeladas|O|O||D||1|Pasa de Corinto hudson bay congelada
50342802|Pasa waxy congeladas|O|O||D||1|Pasa de Corinto waxy congelada
50342803|Pasa desierta congeladas|O|O||D||1|Pasa de Corinto desierta congelada
50342804|Pasa negra congeladas|O|O||D||1|Pasa de Corinto negra congelada
50342805|Pasa roja congeladas|O|O||D||1|Pasa de Corinto roja congelada
50342806|Pasa blanca congeladas|O|O||D||1|Pasa de Corinto blanca congelada
50342900|Dátiles congelados|O|O||D||1
50342901|Dátiles asharasi  congeladas|O|O||D||1
50342902|Dátiles barhi o barhee congeladas|O|O||D||1
50342903|Dátiles deglet noor congeladas|O|O||D||1
50342904|Dátiles fardh congeladas|O|O||D||1
50342905|Dátiles gundila congeladas|O|O||D||1
50342906|Dátiles halawi/halawy congeladas|O|O||D||1
50342907|Dátiles hilali congeladas|O|O||D||1
50342908|Dátiles khadrawi/khadrawy congeladas|O|O||D||1
50342909|Dátiles khalas congeladas|O|O||D||1
50342910|Dátiles khustawi congeladas|O|O||D||1
50342911|Dátiles khidri congeladas|O|O||D||1
50342912|Dátiles medjool/ medjol congeladas|O|O||D||1
50342913|Dátiles mactoum congeladas|O|O||D||1
50342914|Dátiles neghal congeladas|O|O||D||1
50342915|Dátiles yatimeh congeladas|O|O||D||1
50342916|Dátiles zahidi congeladas|O|O||D||1
50343000|Pitahayas congeladas|O|O||D||1
50343001|Pitahaya roja, rosada congeladas|O|O||D||1
50343002|Pitahaya roja, amarillo congeladas|O|O||D||1
50343100|Brevas congeladas|O|O||D||1|Higos congelados
50343101|Breva bardajic congeladas|O|O||D||1|Higo bardajic congelado
50343102|Breva brown turkey congeladas|O|O||D||1|Higo brown turkey congelado
50343103|Breva calimyma  congeladas|O|O||D||1|Higo calimyma congelado
50343104|Breva conadria congeladas|O|O||D||1|Higo conadria congelado
50343105|Breva dotado congeladas|O|O||D||1|Higo dotado congelado
50343106|Breva kadota congeladas|O|O||D||1|Higo kadota congelado
50343107|Breva mediterránea congeladas|O|O||D||1|Higo mediterránea congelado
50343108|Breva misión congeladas|O|O||D||1|Higo misión congelado
50343109|Breva amyma congeladas|O|O||D||1|Higo amyma congelado
50343110|Breva verdona congeladas|O|O||D||1|Higo verdona congelado
50343111|Breva rey blanco congeladas|O|O||D||1|Higo rey blanco congelado
50343200|Grosellas congeladas|O|O||D||1
50343201|Grosella early sulphur congeladas|O|O||D||1
50343202|Grosella doradodrop congeladas|O|O||D||1
50343203|Grosella langley grace congeladas|O|O||D||1
50343204|Grocella leveller congeladas|O|O||D||1
50343205|Grosella london congeladas|O|O||D||1
50343206|Grosella worcestershire congeladas|O|O||D||1
50343207|Grosella americana worcesterberry congelada|O|O||D||1
50343300|Toronjas congeladas|O|O||D||1
50343301|Toronja burgundi congeladas|O|O||D||1
50343302|Toronja duncan congeladas|O|O||D||1
50343303|Toronja foster congelada|O|O||D||1
50343304|Toronja marsh congeladas|O|O||D||1
50343305|Toronja nueva zelandia congeladas|O|O||D||1
50343306|Toronja rio rojo congeladas|O|O||D||1
50343307|Toronja rojo rubí congeladas|O|O||D||1
50343308|Toronja estrella rubí congeladas|O|O||D||1
50343309|Toronja triumph congeladas|O|O||D||1
50343400|Uvas de mesa congeladas|O|O||D||1
50343401|Uva alicante congeladas|O|O||D||1
50343402|Uva almeira congeladas|O|O||D||1
50343403|Uva alphonse lavalle congeladas|O|O||D||1
50343404|Uva autumn rey grapes congeladas|O|O||D||1
50343405|Uva autumn royal congeladas|O|O||D||1
50343406|Uva autum sin semilla congeladas|O|O||D||1
50343407|Uva baresana congeladas|O|O||D||1
50343408|Uva barlinka congeladas|O|O||D||1
50343409|Uva beauty sin semilla congeladas|O|O||D||1
50343410|Uva negro beauty sin semilla congeladas|O|O||D||1
50343411|Uva negro emerald congeladas|O|O||D||1
50343412|Uva negro giant congeladas|O|O||D||1
50343413|Uva negro globe congeladas|O|O||D||1
50343414|Uva negro monnukka congeladas|O|O||D||1
50343415|Uva negro pearl congeladas|O|O||D||1
50343416|Uva negro sin pepa congeladas|O|O||D||1
50343417|Uva bonheur congeladas|O|O||D||1
50343418|Uva calmeria congeladas|O|O||D||1
50343419|Uva cardinal congeladas|O|O||D||1
50343420|Uva catawba congeladas|O|O||D||1
50343421|Uva chasselas/dorado chasselas congeladas|O|O||D||1
50343422|Uva christmas rose congeladas|O|O||D||1
50343423|Uva concord congeladas|O|O||D||1
50343424|Uva concord sin semilla congeladas|O|O||D||1
50343425|Uva crimson sin semilla congeladas|O|O||D||1
50343426|Uva dauphine  congeladas|O|O||D||1
50343427|Uva daleware congeladas|O|O||D||1
50343428|Uva early muscat congeladas|O|O||D||1
50343429|Uva early sweet congeladas|O|O||D||1
50343430|Uva esmerald sin semilla congeladas|O|O||D||1
50343431|Uva emperatriz congeladas|O|O||D||1
50343432|Uva emperor congeladas|O|O||D||1
50343433|Uva empress congeladas|O|O||D||1
50343434|Uva exótica congeladas|O|O||D||1
50343435|Uva fantasía congeladas|O|O||D||1
50343436|Uva fantasia sin semilla congeladas|O|O||D||1
50343437|Uva llama congeladas|O|O||D||1
50343438|Uva llama sin pepa congeladas|O|O||D||1
50343439|Uva llama tokay congeladas|O|O||D||1
50343440|Uva ardiente rojo congeladas|O|O||D||1
50343441|Uva galaxy sin semilla congeladas|O|O||D||1
50343442|Uva gamay congeladas|O|O||D||1
50343443|Uva dorada congeladas|O|O||D||1
50343444|Uva hanepot o honeypot congeladas|O|O||D||1
50343445|Uva italia congeladas|O|O||D||1
50343446|Uva jade sin semilla congeladas|O|O||D||1
50343447|Uva jubileo congeladas|O|O||D||1
50343448|Uva rey ruby congeladas|O|O||D||1
50343449|Uva kyoho congeladas|O|O||D||1
50343450|Uva la rochelle congeladas|O|O||D||1
50343451|Uva dedo de dama congeladas|O|O||D||1
50343452|Uva late sin semilla congeladas|O|O||D||1
50343453|Uva majestosa sin semilla congeladas|O|O||D||1
50343454|Uva malaga congeladas|O|O||D||1
50343455|Uva marro sin pepa congeladas|O|O||D||1
50343456|Uva muscadine congeladas|O|O||D||1
50343457|Uva muscat llama congeladas|O|O||D||1
50343458|Uva muscat congeladas|O|O||D||1
50343459|Uva muscat sin papa congeladas|O|O||D||1
50343460|Uva napoleon congeladas|O|O||D||1
50343461|Uva nigeria congeladas|O|O||D||1
50343462|Uva new cross congeladas|O|O||D||1
50343463|Uva nibella congeladas|O|O||D||1
50343464|Uva niagara congeladas|O|O||D||1
50343465|Uva olivette congeladas|O|O||D||1
50343466|Uva perlette congeladas|O|O||D||1
50343467|Uva perlon congeladas|O|O||D||1
50343468|Uva prima negro sin semilla congeladas|O|O||D||1
50343469|Uva prncess congeladas|O|O||D||1
50343470|Uva reina congeladas|O|O||D||1
50343471|Uva roja blush congeladas|O|O||D||1
50343472|Uva roja globe congeladas|O|O||D||1
50343473|Uva roja malaga congeladas|O|O||D||1
50343474|Uva roja sin pepa congeladas|O|O||D||1
50343475|Uva regina congeladas|O|O||D||1
50343476|Uva ribier congeladas|O|O||D||1
50343477|Uva rosita congeladas|O|O||D||1
50343478|Uva rouge congeladas|O|O||D||1
50343479|Uva royal negra sin pepa congeladas|O|O||D||1
50343480|Uva ruby roja sin pepa congeladas|O|O||D||1
50343481|Uva ryby sin pepa congeladas|O|O||D||1
50343482|Uva scarlet royal congeladas|O|O||D||1
50343483|Uva scuppemong congeladas|O|O||D||1
50343484|Uva sugarose congeladas|O|O||D||1
50343485|Uva sugartirteen congeladas|O|O||D||1
50343486|Uva sugraone congeladas|O|O||D||1
50343487|Uva sugrasixteen congeladas|O|O||D||1
50343488|Uva sultana sun roja congeladas|O|O||D||1
50343489|Uva verano royal congeladas|O|O||D||1
50343490|Uva atardecer congeladas|O|O||D||1
50343491|Uva superior sin pepa congeladas|O|O||D||1
50343492|Uva thompson sin pepa congeladas|O|O||D||1
50343493|Uva tokaylpinot gris congeladas|O|O||D||1
50343494|Uva waltman cross congeladas|O|O||D||1
50343495|Uva blanca sin semilla congeladas|O|O||D||1
50343496|Uva zante current congeladas|O|O||D||1
50343500|Uvas pasas congeladas|O|O||D||1
50343501|Uva corinth negra congeladas|O|O||D||1
50343502|Uva canner congeladas|O|O||D||1
50343503|Uva dovine congeladas|O|O||D||1
50343504|Uva fiesta congeladas|O|O||D||1
50343505|Uva selme pete congeladas|O|O||D||1
50343506|Uva sultana congeladas|O|O||D||1
50343600|Uvas para vino congeladas|O|O||D||1
50343601|Uva uva alicante bouschet congeladas|O|O||D||1
50343602|Uva barbera congeladas|O|O||D||1
50343603|Uva burger congeladas|O|O||D||1
50343604|Uva cabemet franc congeladas|O|O||D||1
50343605|Uva cabenet sauvignon congeladas|O|O||D||1
50343606|Uva carignane congeladas|O|O||D||1
50343607|Uva camelian congeladas|O|O||D||1
50343608|Uva cattarrato congeladas|O|O||D||1
50343609|Uva centurian congeladas|O|O||D||1
50343610|Uva charbono congeladas|O|O||D||1
50343611|Uva chardonnay congeladas|O|O||D||1
50343612|Uva chenin blanco congeladas|O|O||D||1
50343613|Uva cinsaut congeladas|O|O||D||1
50343614|Uva dolcetto congeladas|O|O||D||1
50343615|Uva emerald riesling congeladas|O|O||D||1
50343616|Uva french colombard congeladas|O|O||D||1
50343617|Uva granny nap congeladas|O|O||D||1
50343618|Uva gamay beaujolais congeladas|O|O||D||1
50343619|Uva gewurztraminer congeladas|O|O||D||1
50343620|Uva grnache congeladas|O|O||D||1
50343621|Uva grinache blanc congeladas|O|O||D||1
50343622|Uva lagrein congeladas|O|O||D||1
50343623|Uva lambruso congeladas|O|O||D||1
50343624|Uva malbec congeladas|O|O||D||1
50343625|Uva malvasía bianca congeladas|O|O||D||1
50343626|Uva marsanne congeladas|O|O||D||1
50343627|Uva matano congeladas|O|O||D||1
50343628|Uva merlot congeladas|O|O||D||1
50343629|Uva meunier congeladas|O|O||D||1
50343630|Uva missiom congeladas|O|O||D||1
50343631|Uva montepulceano congeladas|O|O||D||1
50343632|Uva muscat blanc congeladas|O|O||D||1
50343633|Uva muscat hamburg congeladas|O|O||D||1
50343634|Uva muscat alexandria congeladas|O|O||D||1
50343635|Uva muscat naranja congeladas|O|O||D||1
50343636|Uva nebbiolo congeladas|O|O||D||1
50343637|Uva palomino congeladas|O|O||D||1
50343638|Uva petit verdor congeladas|O|O||D||1
50343639|Uva petit sirah congeladas|O|O||D||1
50343640|Uva pinot blanc congeladas|O|O||D||1
50343641|Uva pinot gris congeladas|O|O||D||1
50343642|Uva pinot noir congeladas|O|O||D||1
50343643|Uva primitivo congeladas|O|O||D||1
50343644|Uva roussane congeladas|O|O||D||1
50343645|Uva real  congeladas|O|O||D||1
50343646|Uva rubirojo congeladas|O|O||D||1
50343647|Uva ruby cabenet congeladas|O|O||D||1
50343648|Uva salvador congeladas|O|O||D||1
50343649|Uva sangiovese congeladas|O|O||D||1
50343650|Uva sauvignon blanc congeladas|O|O||D||1
50343651|Uva sauvignon musque congeladas|O|O||D||1
50343652|Uva semillon congeladas|O|O||D||1
50343653|Uva souzao congeladas|O|O||D||1
50343654|Uva st emilion congeladas|O|O||D||1
50343655|Uva symohony congeladas|O|O||D||1
50343656|Uva syrah  congeladas|O|O||D||1
50343657|Uva tannat congeladas|O|O||D||1
50343658|Uva temoranillo congeladas|O|O||D||1
50343659|Uvas teroldego congeladas|O|O||D||1
50343660|Uvas tocai friulano congeladas|O|O||D||1
50343661|Uvas touriga nacional congeladas|O|O||D||1
50343662|Uvas triplett blanc congeladas|O|O||D||1
50343663|Uvas viogner congeladas|O|O||D||1
50343664|Uvas blanco riesling congeladas|O|O||D||1
50343665|Uvas zinfandel congeladas|O|O||D||1
50343700|Guayabas congeladas|O|O||D||1
50343701|Guayaba beaumont congeladas|O|O||D||1
50343702|Guayaba carrley congeladas|O|O||D||1
50343703|Guayaba lucida congeladas|O|O||D||1
50343704|Guayaba piña congeladas|O|O||D||1
50343800|Arándanos Huckleberry congelados|O|O||D||1|Arándanos azules congelados
50343801|Arándano invierno negro congelado|O|O||D||1|Arándano azul invierno negro congelado
50343802|Arándano cascada congelado|O|O||D||1|Arándano azul cascada congelado
50343803|Arándano enano congelado|O|O||D||1|Arándano azul enano congelado
50343804|Arándano montaña congelado|O|O||D||1|Arándano azul montaña congelado
50343805|Arándano rojo congelado|O|O||D||1|Arándano azul red congelado
50343900|Kiwis congelados|O|O||D||1
50343901|Fruta de kiwi ananasnaja congeladas|O|O||D||1|Kiwi ananasnaja congelado
50343902|Fruta de kiwi belleza del ártico congeladas|O|O||D||1|Kiwi belleza del ártico congelado
50343903|Fruta de kiwi blake congeladas|O|O||D||1|Kiwi blake congelado
50343904|Fruta de kiwi hayward congeladas|O|O||D||1|Kiwi hayward congelado
50343905|Fruta de kiwi issai congeladas|O|O||D||1|Kiwi issai congelado
50343906|Fruta de kiwi siberiana congeladas|O|O||D||1|Kiwi siberiano congelado
50344000|Naranjos Chinos (kumquats) congelados|O|O||D||1
50344001|Naranjo chino hong kong congelado|O|O||D||1
50344002|Naranjo chino limequat congelado|O|O||D||1
50344003|Naranjo long fruit congelado|O|O||D||1|Naranjo chino long fruit congelado
50344004|Naranjo chino malayan congelado|O|O||D||1
50344005|Naranjo meiwa congelado|O|O||D||1|Naranjo chino meiwa congelado
50344006|Naranja chino nagami congelado|O|O||D||1|Naranjo chino nagami congelado
50344100|Limones congelados|O|O||D||1
50344101|Limón baboon congelado|O|O||D||1
50344102|Limón bearss sicilian congelado|O|O||D||1
50344103|Limón cameron highland congelado|O|O||D||1
50344104|Limón escondido congelado|O|O||D||1
50344105|Limón eureka congelado|O|O||D||1
50344106|Limón lisbon congelado|O|O||D||1
50344107|Limón meyer congelado|O|O||D||1
50344108|Limón volkaner congelado|O|O||D||1
50344200|Limas congeladas|O|O||D||1
50344201|Lima limón indian sweet congelado|O|O||D||1
50344202|Lima limón congelado|O|O||D||1
50344203|Lima limón mandarin congelado|O|O||D||1
50344204|Lima limón philippine congelado|O|O||D||1
50344205|Lima limón tahitian congelado|O|O||D||1
50344206|Lima limón bearss congelado|O|O||D||1
50344207|Lima limón persa congelado|O|O||D||1
50344208|Lima limón sin pepas congelado|O|O||D||1|Lima limón sin semillas congelado
50344300|Nísperos congelados|O|O||D||1
50344301|Níspero advance congelado|O|O||D||1
50344302|Níspero benlehr congelado|O|O||D||1
50344303|Níspero big jim congelado|O|O||D||1
50344304|Níspero champagne congelado|O|O||D||1
50344305|Níspero early rojo congelado|O|O||D||1
50344306|Níspero nuget dorado congelado|O|O||D||1
50344307|Níspero herd´s mammoth congelado|O|O||D||1
50344308|Níspero mogi congelado|O|O||D||1
50344309|Níspero mrs cooksey congelado|O|O||D||1
50344310|Níspero fresa congelado|O|O||D||1
50344311|Níspero tanaka congelado|O|O||D||1
50344312|Níspero victoria vista blanco congelado|O|O||D||1
50344313|Níspero wolfe congelado|O|O||D||1
50344400|Mandarinas congeladas|O|O||D||1
50344401|Naranjas clauselinas congeladas|O|O||D||1
50344402|Mandarinas clementinas congeladas|O|O||D||1
50344403|Naranja mandarina cleopatra|O|O||D||1
50344404|Mandarina dancy congeladas|O|O||D||1
50344405|Naranja ellensday congeladas|O|O||D||1
50344406|Naranja fairchild congeladas|O|O||D||1
50344407|Naranja fallglo congeladas|O|O||D||1
50344408|Naranja fortuna congeladas|O|O||D||1
50344409|Mandarina naranja fremont congeladas|O|O||D||1
50344410|Naranja fremont congeladas|O|O||D||1
50344411|Naranja nuget dorada congeladas|O|O||D||1
50344412|Mandarina naranja miel congeladas|O|O||D||1
50344413|Naranja miel congeladas|O|O||D||1
50344414|Mandarina miel congeladas|O|O||D||1
50344415|Naranja tangelo honeybelle congeladas|O|O||D||1
50344416|Naranja mandarina rey congeladas|O|O||D||1
50344417|Naranja kinnow congeladas|O|O||D||1
50344418|Naranja andarinalee congeladas|O|O||D||1
50344419|Naranja makokkee congeladas|O|O||D||1
50344420|Naranja malvasion congeladas|O|O||D||1
50344421|Naranja mandarina mediterránea congeladas|O|O||D||1
50344422|Naranja tangelo minneola congeladas|O|O||D||1
50344423|Naranja monica congeladas|O|O||D||1
50344424|Naranja murcott miel congeladas|O|O||D||1
50344425|Naranja murcott tangors congeladas|O|O||D||1
50344426|Naranja mandarina natsudaidai  congeladas|O|O||D||1
50344427|Naranja mandarina natsumikan congeladas|O|O||D||1
50344428|Naranja tanjelo nocatee congeladas|O|O||D||1
50344429|Naranja tanjelo orlando congeladas|O|O||D||1
50344430|Mandarina ortanique congeladas|O|O||D||1
50344431|Naranja mandarina pagina congeladas|O|O||D||1
50344432|Naranja pixie congeladas|O|O||D||1
50344433|Naranja mandarina ponkan bantangas congeladas|O|O||D||1
50344434|Naranja reina congeladas|O|O||D||1
50344435|Naranja robinson congeladas|O|O||D||1
50344436|Naranja saltenitas congeladas|O|O||D||1
50344437|Naranja tangelo sampson congeladas|O|O||D||1
50344438|Naranja mandarina satsuma congeladas|O|O||D||1
50344439|Naranja mandarina sunburst congeladas|O|O||D||1
50344440|Tangelo congelado|O|O||D||1
50344441|Naranja mandarina congeladas|O|O||D||1
50344442|Naranja templo congeladas|O|O||D||1
50344443|Naranja thornton congeladas|O|O||D||1
50344444|Mandarina wekiwa congeladas|O|O||D||1
50344445|Mandarina wilkins congeladas|O|O||D||1
50344446|Mandarina willowleaf mediterránea congeladas|O|O||D||1
50344500|Mangos congelados|O|O||D||1
50344501|Mango alphonso congelado|O|O||D||1
50344502|Mango ataulfo congelado|O|O||D||1
50344503|Mango criollo congelado|O|O||D||1
50344504|Mango edwards congelado|O|O||D||1
50344505|Mango francine congelado|O|O||D||1
50344506|Mango francis congelado|O|O||D||1
50344507|Mango gandaria congelado|O|O||D||1
50344508|Mango haden congelado|O|O||D||1
50344509|Mangos irwin congelado|O|O||D||1
50344510|Mangos keitt congelado|O|O||D||1
50344511|Mangos kent congelado|O|O||D||1
50344512|Mangos kesar congelado|O|O||D||1
50344513|Mangos kuini congelado|O|O||D||1
50344514|Mangos manila super congelado|O|O||D||1
50344515|Mangos manila congelado|O|O||D||1
50344516|Mangos mayaguez congelado|O|O||D||1
50344517|Mangos mulgoba congelado|O|O||D||1
50344518|Mangos oro congelado|O|O||D||1
50344519|Mangos palmer congelado|O|O||D||1
50344520|Mango parvin congelado|O|O||D||1
50344521|Mango sandersha congelado|O|O||D||1
50344522|Mangos sensation congelado|O|O||D||1
50344523|Mango smith congelado|O|O||D||1
50344524|Mango tomy atkin congelado|O|O||D||1
50344525|Mango van dyke congelado|O|O||D||1
50344600|Melones congelados|O|O||D||1
50344601|Melon allsweet congelado|O|O||D||1
50344602|Melón athens congelado|O|O||D||1
50344603|Melón diamante negro congelado|O|O||D||1
50344604|Melón cal sweet congelado|O|O||D||1
50344605|Melons cantaloupe congelado|O|O||D||1
50344606|Melón carnical congelado|O|O||D||1
50344607|Melón casaba congelado|O|O||D||1
50344608|Melón cavaillon congelado|O|O||D||1
50344609|Melón charentais congelado|O|O||D||1
50344610|Sandia charleston gray congelado|O|O||D||1
50344611|Melón crenshaw congelado|O|O||D||1
50344612|Melón crimson sweet congelado|O|O||D||1
50344613|Melón dixie lee congelado|O|O||D||1
50344614|Melón eclipse congelado|O|O||D||1
50344615|Melón ein dór  congelado|O|O||D||1
50344616|Melón fiesta congelado|O|O||D||1
50344617|Melón galia congelado|O|O||D||1
50344618|Melón gaya congelado|O|O||D||1
50344619|Melón hami congelado|O|O||D||1
50344620|Melón miel dew congelado|O|O||D||1
50344621|Melón hielo congelado|O|O||D||1
50344622|Melón ida orgullo congelado|O|O||D||1
50344623|Melón juan canary congelado|O|O||D||1
50344624|Melón jubileo congelado|O|O||D||1
50344625|Melón jubilación congelado|O|O||D||1
50344626|Melón kaki / kakri congelado|O|O||D||1
50344627|Melón kiwano congelado|O|O||D||1
50344628|Melon koreano congelado|O|O||D||1|Melón coreano congelado
50344629|Melón long grey congelado|O|O||D||1|Melón largo gris congelado
50344630|Melón mayan congelado|O|O||D||1
50344631|Melón micky lee congelado|O|O||D||1
50344632|Melón mirage congelado|O|O||D||1
50344633|Sandia luna y estrellas congelado|O|O||D||1
50344634|Melón ogen congelado|O|O||D||1
50344635|Melón patriot congelado|O|O||D||1
50344636|Melón pavo real congelado|O|O||D||1
50344637|Melón pepino congelado|O|O||D||1
50344638|Melón persian congelado|O|O||D||1
50344639|Melón picnic congelado|O|O||D||1
50344640|Melón piel de sapo congelado|O|O||D||1
50344641|Melón piña congelado|O|O||D||1
50344642|Melón quetzali congelado|O|O||D||1
50344643|Melón goblin rojo congelado|O|O||D||1
50344644|Melón regency congelado|O|O||D||1
50344645|Melón royal mejestic congelado|O|O||D||1
50344646|Melón royal star congelado|O|O||D||1
50344647|Melón dulce royal congelado|O|O||D||1
50344648|Malon santa claus congelado|O|O||D||1|Melón piel de sapo congelado, Melón santa claus congelado
50344649|Melón sharlyn congelado|O|O||D||1
50344650|Melón español congelado|O|O||D||1
50344651|Melón sprite congelado|O|O||D||1
50344652|Melón starbright congelado|O|O||D||1
50344653|Melón stars and stripes congelado|O|O||D||1
50344654|Melón bebe de azúcar congelado|O|O||D||1
50344655|Sandia bebe de azúcar congeladas|O|O||D||1
50344656|Melón dulce sol congelado|O|O||D||1
50344657|Sandia corazón dulce sin semilla congeladas|O|O||D||1
50344658|Melón tentación congelado|O|O||D||1
50344659|Melón tigre bebe congelado|O|O||D||1
50344660|Melón tuscan tipo congelado|O|O||D||1
50344661|Sandia bebe amarillo congeladas|O|O||D||1
50344700|Moras mulberry congeladas|O|O||D||1|Zarzamoras mulberry congeladas
50344701|Mora negra congeladas|O|O||D||1|Zarzamora negra congeladas
50344702|Mora blanca congeladas|O|O||D||1|Zarzamora blanca congeladas
50344800|Mirtos congelados|O|O||D||1|Arrayanes congelados
50344801|Mirto bog congelado|O|O||D||1|Arrayán bog congelado
50344900|Nectarinas congelados|O|O||D||1
50344901|Durazno april glo congelado|O|O||D||1
50344902|Durazno arctic mist congelado|O|O||D||1
50344903|Durazno artic snow congelado|O|O||D||1
50344904|Durazno artic star congelado|O|O||D||1
50344905|Durazno artic dulce congelado|O|O||D||1
50344906|Durazno artic glo congelado|O|O||D||1
50344907|Durazno agosto fire congelado|O|O||D||1
50344908|Durazno  perla de agosto congelado|O|O||D||1
50344909|Durazno agosto rojo congelado|O|O||D||1
50344910|Durazno estrella de agosto congelado|O|O||D||1
50344911|Durazno big john congelado|O|O||D||1
50344912|Durazno perla brillante congelado|O|O||D||1
50344913|Durazno diamante brillante congelado|O|O||D||1
50344914|Durazno diamante ray congelado|O|O||D||1
50344915|Durazno earligo congelado|O|O||D||1
50344916|Durazno diamante temprano congelado|O|O||D||1
50344917|Durazno fairlane congelado|O|O||D||1
50344918|Durazno fantasia congelado|O|O||D||1
50344919|Durazno perla fuego congelado|O|O||D||1
50344920|Durazno fuego dulce congelado|O|O||D||1
50344921|Durazno llamakist congelado|O|O||D||1
50344922|Durazno tipo plano congelado|O|O||D||1
50344923|Durazno delicia de jardín congelado|O|O||D||1
50344924|Durazno mina de oro congelado|O|O||D||1
50344925|Durazno perla grande congelado|O|O||D||1
50344926|Durazno hardirojo congelado|O|O||D||1
50344927|Durazno miel de fuego congelado|O|O||D||1
50344928|Durazno julio rojo congelado|O|O||D||1
50344929|Durazno kay perla congelado|O|O||D||1
50344930|Durazno key dulce congelado|O|O||D||1
50344931|Durazno diamante mayo congelado|O|O||D||1
50344932|Durazno mayfire congelado|O|O||D||1
50344933|Durazno mayglo congelado|O|O||D||1
50344934|Durazno mericrest congelado|O|O||D||1
50344935|Durazno diamante rojo congelado|O|O||D||1
50344936|Durazno oro rojo congelado|O|O||D||1
50344937|Durazno jim rojo congelado|O|O||D||1
50344938|Durazno roy rojo congelado|O|O||D||1
50344939|Durazno rio rojo congelado|O|O||D||1
50344940|Durazno diamante de rosa congelado|O|O||D||1
50344941|Durazno rotal glo congelado|O|O||D||1
50344942|Durazno diamante ryby congelado|O|O||D||1
50344943|Durazno ruby dulce congelado|O|O||D||1
50344944|Durazno joya ruddy congelado|O|O||D||1
50344945|Durazno septiembre rojo congelado|O|O||D||1
50344946|Durazno reina de nieve congelado|O|O||D||1
50344947|Durazno primavera clara congelado|O|O||D||1
50344948|Durazno primavera roja congelado|O|O||D||1
50344949|Durazno verano rojiso congelado|O|O||D||1
50344950|Durazno verano claro congelado|O|O||D||1
50344951|Durazno verano diamante congelado|O|O||D||1
50344952|Durazno verano fuego congelado|O|O||D||1
50344953|Durazno verano grande congelado|O|O||D||1
50344954|Durazno sunglo congelado|O|O||D||1
50344955|Durazno fuego zee congelado|O|O||D||1
50344956|Durazno zee glo congelado|O|O||D||1
50344957|Durazno zeegrand congelado|O|O||D||1
50345000|Naranjas congeladas|O|O||D||1
50345001|Naranja áfrica agria congeladas|O|O||D||1
50345002|Naranja dulce amber congeladas|O|O||D||1
50345003|Naranja argentina agria congeladas|O|O||D||1
50345004|Naranja bahianinha congelado|O|O||D||1
50345005|Naranja bergamot congeladas|O|O||D||1
50345006|Naranja berna congeladas|O|O||D||1
50345007|Naranja bigaradier apepu congeladas|O|O||D||1
50345008|Naranja agria dulce daidai congeladas|O|O||D||1
50345009|Naranja mono congeladas|O|O||D||1
50345010|Naranja sangre congeladas|O|O||D||1
50345011|Naranja california navel congeladas|O|O||D||1
50345012|Naranja cara cara congeladas|O|O||D||1
50345013|Naranja chinotto congeladas|O|O||D||1
50345014|Naranja sueño nevel congeladas|O|O||D||1
50345015|Naranja gou tou congeladas|O|O||D||1
50345016|Naranja hamlin congeladas|O|O||D||1
50345017|Naranja jaffa congeladas|O|O||D||1
50345018|Naranja jincheng congeladas|O|O||D||1
50345019|Naranja k-temprano congeladas|O|O||D||1
50345020|Naranja kona congeladas|O|O||D||1
50345021|Naranja navel tarde congeladas congeladas|O|O||D||1
50345022|Naranja valencia tarde congeladas|O|O||D||1
50345023|Naranja limequat congeladas|O|O||D||1
50345024|Naranja mar congeladas|O|O||D||1
50345025|Naranja malegold congeladas|O|O||D||1
50345026|Naranja moro congeladas|O|O||D||1
50345027|Naranja moro tabaco congeladas|O|O||D||1
50345028|Naranja navel congeladas|O|O||D||1
50345029|Naranja navelina congeladas|O|O||D||1
50345030|Naranja oro blanco congeladas|O|O||D||1
50345031|Naranja osceola congeladas|O|O||D||1
50345032|Naranja parson carmelito congeladas|O|O||D||1
50345033|Naranja pera congeladas|O|O||D||1
50345034|Naranja pummulo congeladas|O|O||D||1
50345035|Naranja rhode rojo congeladas|O|O||D||1
50345036|Naranja roble congeladas|O|O||D||1
50345037|Naranja salustianas congeladas|O|O||D||1
50345038|Naranja sanguine congeladas|O|O||D||1
50345039|Naranja sanguinelli congeladas|O|O||D||1
50345040|Naranja sevilla congeladas|O|O||D||1
50345041|Naranja shamouti jaffa congeladas|O|O||D||1
50345042|Naranja tunis congeladas|O|O||D||1
50345043|Naranja valencia congeladas|O|O||D||1
50345044|Naranja washington navel congeladas|O|O||D||1
50345100|Papayas congeladas|O|O||D||1
50345101|Papaya verde cocinar congeladas|O|O||D||1
50345102|Papaya maradol congeladas|O|O||D||1
50345103|Papaya amarillo mexicano congeladas|O|O||D||1
50345104|Papaya montaña congeladas|O|O||D||1
50345105|Papaya solo congeladas|O|O||D||1
50345106|Papaya tainung congeladas|O|O||D||1
50345200|Maracuyás congeladas|O|O||D||1
50345201|Maracuyá banana congeladas|O|O||D||1|Curuba congelada
50345202|Maracuyá flor azul congeladas|O|O||D||1|Maracuyá pasionaria azul congelada
50345203|Maracuyá crackerjack congeladas|O|O||D||1
50345204|Maracuyá granadilla gigante congeladas|O|O||D||1
50345205|Maracuyá granadilla dorada congeladas|O|O||D||1
50345206|Maracuyá maypops congeladas|O|O||D||1
50345207|Maracuyá roja congeladas|O|O||D||1
50345208|Maracuyá granadilla dulce congeladas|O|O||D||1
50345209|Maracuyá sandia congeladas|O|O||D||1
50345210|Maracuyá  wing- steam congeladas|O|O||D||1
50345300|Duraznos congelados|O|O||D||1
50345301|Durazno escudo amber congelado|O|O||D||1
50345302|Durazno nieve de abril congelado|O|O||D||1
50345303|Durazno dama de agosto congelado|O|O||D||1
50345304|Durazno llama de otoño congelado|O|O||D||1
50345305|Durazno dama de otoño congelado|O|O||D||1
50345306|Durazno babcock congelado|O|O||D||1
50345307|Durazno brittany lane congelado|O|O||D||1
50345308|Durazno cary mac congelado|O|O||D||1
50345309|Durazno clásica congelado|O|O||D||1
50345310|Durazno dulce del campo congelado|O|O||D||1
50345311|Durazno escudo de cielo congelado|O|O||D||1
50345312|Durazno dama crimson congelado|O|O||D||1
50345313|Durazno príncipe corona congelado|O|O||D||1
50345314|Durazno sol david congelado|O|O||D||1
50345315|Durazno  princesa diamante congelado|O|O||D||1
50345316|Durazno earlrich congelado|O|O||D||1
50345317|Durazno majestuosa temprana congelado|O|O||D||1
50345318|Durazno early treat congelado|O|O||D||1
50345319|Durazno dama elegante congelado|O|O||D||1
50345320|Durazno emperatriz congelado|O|O||D||1
50345321|Durazno encoré congelado|O|O||D||1
50345322|Durazno dama elegante congelado|O|O||D||1
50345323|Durazno príncipe de fuego congelado|O|O||D||1
50345324|Durazno escudo de llama congelado|O|O||D||1
50345325|Durazno tipo plano congelado|O|O||D||1
50345326|Durazno escudo de sabor congelado|O|O||D||1
50345327|Durazno príncipe florida congelado|O|O||D||1
50345328|Durazno luna llena congelado|O|O||D||1
50345329|Durazno harvester congelado|O|O||D||1
50345330|Durazno princesa de hielo congelado|O|O||D||1
50345331|Durazno princesa de marfil congelado|O|O||D||1
50345332|Durazno princesa reina jersey congelado|O|O||D||1
50345333|Durazno john henry congelado|O|O||D||1
50345334|Durazno príncipe de junio congelado|O|O||D||1
50345335|Durazno kaweah congelado|O|O||D||1
50345336|Durazno klondike congelado|O|O||D||1
50345337|Durazno lindo congelado|O|O||D||1
50345338|Durazno loring congelado|O|O||D||1
50345339|Durazno majestuoso congelado|O|O||D||1
50345340|Durazno o’henry congelado|O|O||D||1
50345341|Durazno escudo de reina congelado|O|O||D||1
50345342|Durazno dama roja congelado|O|O||D||1
50345343|Durazno globo rojo congelado|O|O||D||1
50345344|Durazno cielo rojo congelado|O|O||D||1
50345345|Durazno redtop congelado|O|O||D||1
50345346|Durazno regina congelado|O|O||D||1
50345347|Durazno dama rica congelado|O|O||D||1
50345348|Durazno mayo rico vo|O|O||D||1
50345349|Durazno gloria royal congelado|O|O||D||1
50345350|Durazno dama royal congelado|O|O||D||1
50345351|Durazno nieve de septiembre congelado|O|O||D||1
50345352|Durazno sol de septiembre congelado|O|O||D||1
50345353|Durazno gema sierra congelado|O|O||D||1
50345354|Durazno angel de nieve congelado|O|O||D||1
50345355|Durazno gema de nieve congelado|O|O||D||1
50345356|Durazno rey de nieve congelado|O|O||D||1
50345357|Durazno dama de primavera congelado|O|O||D||1
50345358|Durazno nieve de primavera congelado|O|O||D||1
50345359|Durazno escudo de primavera congelado|O|O||D||1
50345360|Durazno dulce gigante congelado|O|O||D||1
50345361|Durazno dama de azúcar congelado|O|O||D||1
50345362|Durazno brillo de sol congelado|O|O||D||1
50345363|Durazno sunhigh congelado|O|O||D||1
50345364|Durazno dama super congelado|O|O||D||1
50345365|Durazno super rico congelado|O|O||D||1
50345366|Durazno surecrop congelado|O|O||D||1
50345367|Durazno sueño dulce congelado|O|O||D||1
50345368|Durazno septiembre dulce congelado|O|O||D||1
50345369|Durazno vista congelado|O|O||D||1
50345370|Durazno dama blanca congelado|O|O||D||1
50345371|Durazno dama zee congelado|O|O||D||1
50345400|Peras congeladas|O|O||D||1
50345401|Peras abate fetel congeladas|O|O||D||1
50345402|Peras anjou congeladas|O|O||D||1
50345403|Pera asiática congeladas|O|O||D||1
50345404|Pera bartlett congeladas|O|O||D||1
50345405|Pera best ever congeladas|O|O||D||1
50345406|Pera beth congeladas|O|O||D||1
50345407|Pera beurre congeladas|O|O||D||1
50345408|Pera bosc congeladas|O|O||D||1
50345409|Pera clapp favorita congeladas|O|O||D||1
50345410|Pera comice congeladas|O|O||D||1
50345411|Pera concorde congeladas|O|O||D||1
50345412|Pera conference congeladas|O|O||D||1
50345413|Pera crimson rojo congeladas|O|O||D||1
50345414|Peras d’ anjou congeladas|O|O||D||1
50345415|Pera dr jules guyot congeladas|O|O||D||1
50345416|Peras early congeladas|O|O||D||1
50345417|Peras emperador carmelito congeladas|O|O||D||1
50345418|Peras forelle congeladas|O|O||D||1
50345419|Pera mantequilla francesa congeladas|O|O||D||1
50345420|Pera glou morceau congeladas|O|O||D||1
50345421|Pera hosui congeladas|O|O||D||1
50345422|Pera mantequilla italiana congeladas|O|O||D||1
50345423|Pera jargonelle congeladas|O|O||D||1
50345424|Pera juno congeladas|O|O||D||1
50345425|Para kaiserlouise bonne de jersey congeladas|O|O||D||1
50345426|Pera keiffer congeladas|O|O||D||1
50345427|Pera rey royal congeladas|O|O||D||1
50345428|Pera limonera congeladas|O|O||D||1
50345429|Pera merton pride congeladas|O|O||D||1
50345430|Pera mountain bartlette congeladas|O|O||D||1
50345431|Pera oliver de serrers congeladas|O|O||D||1
50345432|Pera onward congeladas|O|O||D||1
50345433|Pera packham´s triumph congeladas|O|O||D||1
50345434|Pera paraíso congeladas|O|O||D||1
50345435|Pera passe crassane congeladas|O|O||D||1
50345436|Pera perry congeladas|O|O||D||1
50345437|Pera bartlette rojo congeladas|O|O||D||1
50345438|Pera dánjou  rojo congeladas|O|O||D||1
50345439|Pera rocha congeladas|O|O||D||1
50345440|Pera rosey rojo congeladas|O|O||D||1
50345441|Pera rosy roja congeladas|O|O||D||1
50345442|Pera majestuosa royal congeladas|O|O||D||1
50345443|Pera ruby rojo congeladas|O|O||D||1
50345444|Pera santa maria congeladas|O|O||D||1
50345445|Pera seckel congeladas|O|O||D||1
50345446|Pera sensación congeladas|O|O||D||1
50345447|Pera crimson estrella congeladas|O|O||D||1
50345448|Pera crimson stark congeladas|O|O||D||1
50345449|Pera bartlette de verano congeladas|O|O||D||1
50345450|Pera verano dorado congeladas|O|O||D||1
50345451|Pera sol dorado congeladas|O|O||D||1
50345452|Pera sunprite congeladas|O|O||D||1
50345453|Pera taylors dorado congeladas|O|O||D||1
50345454|Pera taylors rojo congeladas|O|O||D||1
50345455|Pera tientsin congeladas|O|O||D||1
50345456|Pera tosca congeladas|O|O||D||1
50345457|Pera warden  congeladas|O|O||D||1
50345458|Pera williams bon chretien congeladas|O|O||D||1
50345459|Pera williams congeladas|O|O||D||1
50345460|Pera nelis de invierno congeladas|O|O||D||1
50345500|Caquis congelados|O|O||D||1
50345501|Caqui americano congeladas|O|O||D||1
50345502|Caqui sapote negro congeladas|O|O||D||1|Caqui zapote negro congelado
50345503|Caqui chapote / negro congeladas|O|O||D||1
50345504|Caqui dátale ciruela congeladas|O|O||D||1
50345505|Caqui fuyu congeladas|O|O||D||1
50345506|Caqui gigante fuyu congeladas|O|O||D||1
50345507|Caqui hachiya congeladas|O|O||D||1
50345508|Caqui mantequilla / mabolo congeladas|O|O||D||1
50345509|Caqui príncipe ito congeladas|O|O||D||1
50345510|Caqui brillante royal congeladas|O|O||D||1
50345511|Caqui sharon congeladas|O|O||D||1
50345512|Caqui triumph congeladas|O|O||D||1
50345600|Piñas congeladas|O|O||D||1
50345601|Piña chirimoya congeladas|O|O||D||1|Atemoya congelada
50345602|Piña dorada congeladas|O|O||D||1
50345603|Piña hilo congeladas|O|O||D||1
50345604|Piña kona sugarloaf congeladas|O|O||D||1
50345605|Piña reina natal congeladas|O|O||D||1
50345606|Piña pernabuco congeladas|O|O||D||1
50345607|Piña español rojo congeladas|O|O||D||1
50345608|Piña cayen suave congeladas|O|O||D||1
50345609|Piña sugarloaf congeladas|O|O||D||1
50345610|Piña variegated congeladas|O|O||D||1
50345700|Ciruelos Damascos congelados|O|O||D||1
50345701|Ciruelo / damasco negro kat congelado|O|O||D||1
50345702|Ciruelo / damasco gusto azul congelado|O|O||D||1
50345703|Ciruelo / damasco corazón de crimson congelado|O|O||D||1
50345704|Ciruelo / damasco dapply dandy congelado|O|O||D||1
50345705|Ciruelo / damasco dapple fuego congelado|O|O||D||1
50345706|Ciruelo / damasco  dapple temprano congelado|O|O||D||1
50345707|Ciruelo / damasco  caída de sabor congelado|O|O||D||1
50345708|Ciruelo / damasco sabor de oro congelado|O|O||D||1
50345709|Ciruelo / damasco sabor granada congelado|O|O||D||1
50345710|Ciruelo / damasco sabor de corazón congelado|O|O||D||1
50345711|Ciruelo / damasco joya de sabor congelado|O|O||D||1
50345712|Ciruelo / damasco sabor de rey congelado|O|O||D||1
50345713|Ciruelo / damasco sabor de reina congelado|O|O||D||1
50345714|Ciruelo / damasco sabor supremo congelado|O|O||D||1
50345715|Ciruelo / damasco sabor premio congelado|O|O||D||1
50345716|Ciruelo / damasco saborella congelado|O|O||D||1
50345717|Ciruelo / damasco saborrico congelado|O|O||D||1
50345718|Ciruelo / damasco  sabor rosa congelado|O|O||D||1
50345719|Ciruelo / damasco orgullo geo congelado|O|O||D||1
50345720|Ciruelo / damasco kat rojo congelado|O|O||D||1
50345721|Ciruelo / damasco premio royal congelado|O|O||D||1
50345722|Ciruelo / damasco rosa sierra congelado|O|O||D||1
50345723|Ciruelo / damasco geisha dulce congelado|O|O||D||1
50345800|Ciruelas congeladas|O|O||D||1
50345801|Ciruela joya amber congeladas|O|O||D||1
50345802|Ciruela angeleno congeladas|O|O||D||1
50345803|Ciruela aurora congeladas|O|O||D||1
50345804|Ciruela otoño bonito congeladas|O|O||D||1
50345805|Ciruela otoño gigante congeladas|O|O||D||1
50345806|Ciruela orgullo de otoño congeladas|O|O||D||1
50345807|Ciruela rosa de otoño congeladas|O|O||D||1
50345808|Ciruela playero congeladas|O|O||D||1
50345809|Ciruela betty anne congeladas|O|O||D||1
50345810|Ciruela belleza negra congeladas|O|O||D||1
50345811|Ciruela bullase negra congeladas|O|O||D||1
50345812|Ciruela diamante negro congeladas|O|O||D||1
50345813|Ciruela gigante negro congeladas|O|O||D||1
50345814|Ciruela hielo negro congeladas|O|O||D||1
50345815|Ciruela esplendor negro congeladas|O|O||D||1
50345816|Ciruela ámbar negro congeladas|O|O||D||1
50345817|Ciruela purpura congeladas|O|O||D||1
50345818|Ciruela  carlsbad congeladas|O|O||D||1
50345819|Ciruela casselman congeladas|O|O||D||1
50345820|Ciruela catalina congeladas|O|O||D||1
50345821|Ciruela damson congeladas|O|O||D||1
50345822|Ciruela dolly congeladas|O|O||D||1
50345823|Ciruela earliqueen congeladas|O|O||D||1
50345824|Ciruela rosa early congeladas|O|O||D||1
50345825|Ciruela ébano mayo congeladas|O|O||D||1
50345826|Ciruela ébano congeladas|O|O||D||1
50345827|Ciruela corazón de elefante congeladas|O|O||D||1
50345828|Ciruela belleza de esmeralda congeladas|O|O||D||1
50345829|Ciruela emperatriz congeladas|O|O||D||1
50345830|Ciruela libertad congeladas|O|O||D||1
50345831|Ciruela friar congeladas|O|O||D||1
50345832|Ciruela rojo gar congeladas|O|O||D||1
50345833|Ciruela gobernador congeladas|O|O||D||1
50345834|Ciruela rosa grande congeladas|O|O||D||1
50345835|Ciruela green gage congeladas|O|O||D||1|Ciruela calibre verde congelada
50345836|Ciruela greengage congeladas|O|O||D||1
50345837|Ciruela hiromi congeladas|O|O||D||1
50345838|Ciruela hiromi rojo congeladas|O|O||D||1
50345839|Ciruela vacacion congeladas|O|O||D||1
50345840|Ciruela howard sol congeladas|O|O||D||1
50345841|Ciruela tipo interspecific congeladas|O|O||D||1
50345842|Ciruela jamaico congeladas|O|O||D||1
50345843|Ciruela joanna rojo congeladas|O|O||D||1
50345844|Ciruela kelsey congeladas|O|O||D||1
50345845|Ciruela jaime rey congeladas|O|O||D||1
50345846|Ciruela laroda congeladas|O|O||D||1
50345847|Ciruela rosa tarde congeladas|O|O||D||1
50345848|Ciruela rosa linda congeladas|O|O||D||1
50345849|Ciruela estrella solitaria congeladas|O|O||D||1
50345850|Ciruela mariposa congeladas|O|O||D||1
50345851|Ciruela mercado negro congeladas|O|O||D||1
50345852|Ciruela mercado rojo congeladas|O|O||D||1
50345853|Ciruela maribel congeladas|O|O||D||1
50345854|Ciruelas sol de octubre congeladas|O|O||D||1
50345855|Ciruela owen t congeladas|O|O||D||1
50345856|Ciruela perdrigon congeladas|O|O||D||1
50345857|Ciruela placer rosado congeladas|O|O||D||1
50345858|Ciruela  presidente congeladas|O|O||D||1
50345859|Ciruela hora prima congeladas|O|O||D||1|Ciruela prime time congelada
50345860|Ciruela majestad purpura congeladas|O|O||D||1
50345861|Ciruela reina rosa congeladas|O|O||D||1
50345862|Ciruela quetsch congeladas|O|O||D||1
50345863|Ciruela belleza roja congeladas|O|O||D||1
50345864|Ciruela camino rojo congeladas|O|O||D||1
50345865|Ciruela ram rojo congeladas|O|O||D||1
50345866|Ciruela rosa roja congeladas|O|O||D||1
50345867|Ciruela rojo rico congeladas|O|O||D||1
50345868|Ciruela romero congeladas|O|O||D||1
50345869|Ciruela diamante rojo congeladas|O|O||D||1
50345870|Ciruela rojo royal congeladas|O|O||D||1
50345871|Ciruela royal zee congeladas|O|O||D||1
50345872|Ciruela roysum congeladas|O|O||D||1
50345873|Ciruela santa rosa congeladas|O|O||D||1
50345874|Ciruela zafiro congeladas|O|O||D||1
50345875|Ciruela sloe congeladas|O|O||D||1
50345876|Ciruela sta catherine congeladas|O|O||D||1
50345877|Ciruela bullase blanco congeladas|O|O||D||1
50345900|Granadas congeladas|O|O||D||1
50345901|Granada foothhill congeladas|O|O||D||1
50345902|Granada, granada congeladas|O|O||D||1|Granada congelada
50345903|Granada rojo feliz congeladas|O|O||D||1
50345904|Granada nana congeladas|O|O||D||1
50345905|Granada rojo de pat congeladas|O|O||D||1
50345906|Granada pinkhan congelado|O|O||D||1
50345907|Granada terciopelo morado congeladas|O|O||D||1
50345908|Granada grandioso congeladas|O|O||D||1
50346000|Pomelos congelados|O|O||D||1
50346001|Pomelo chandler congelado|O|O||D||1
50346002|Pomelo hirado butan congelado|O|O||D||1
50346003|Pomelo liang ping yau congelado|O|O||D||1
50346004|Pomelo panda wangi congelado|O|O||D||1
50346005|Pomelo rosado congelado|O|O||D||1
50346006|Pomelo shaddock rojo congelado|O|O||D||1
50346007|Pomelo siamese dulce congelado|O|O||D||1
50346008|Pomelo waingwright congelado|O|O||D||1
50346100|Membrillos congelados|O|O||D||1
50346101|Membrillo campeón congelado|O|O||D||1
50346102|Membrillo piña congelado|O|O||D||1
50346103|Membrillo smyma congelado|O|O||D||1
50346200|Frambuesas congeladas|O|O||D||1
50346201|Frambuesa americana roja congeladas|O|O||D||1
50346202|Frambuesa bailey queensland congeladas|O|O||D||1
50346203|Frambuesa negra congeladas|O|O||D||1
50346204|Frambuesa oscura congeladas|O|O||D||1
50346205|Frambuesa deliciosa congeladas|O|O||D||1
50346206|Frambuesa enano focke congeladas|O|O||D||1
50346207|Frambuesa focke hojagris congeladas|O|O||D||1
50346208|Frambuesa focke fresa congeladas|O|O||D||1
50346209|Frambuesa  focke amarillo himalaya congeladas|O|O||D||1
50346210|Frambuesa dorado congelado|O|O||D||1
50346211|Frambuesa gris nuevo mexico congeladas|O|O||D||1
50346212|Frambuesa jepson blancobark congeladas|O|O||D||1
50346213|Frambuesa kellogs san diego congeladas|O|O||D||1
50346214|Frambuesa leucodemis blancobark congeladas|O|O||D||1
50346215|Frambuesa munz cuyamaca congeladas|O|O||D||1
50346216|Frambuesa peck bartons congeladas|O|O||D||1
50346217|Frambuesa flor morada congeladas|O|O||D||1
50346218|Frambuesa roadside congeladas|O|O||D||1
50346219|Frambuesa san diego congeladas|O|O||D||1
50346220|Frambuesa nieve congeladas|O|O||D||1
50346221|Frambuesa pico de nieve congeladas|O|O||D||1
50346222|Frambuesa hoja de fresa congeladas|O|O||D||1
50346223|Frambuesa cultivo dulce congeladas|O|O||D||1
50346224|Frambuesa tor y gris blancobark congeladas|O|O||D||1
50346225|Frambuesa caribe congeladas|O|O||D||1
50346226|Frambuesa blancobark congeladas|O|O||D||1
50346227|Frambuesa vino congeladas|O|O||D||1
50346228|Frambuesa himalaya amarillo congeladas|O|O||D||1
50346229|Frambuesa yu-shan congeladas|O|O||D||1
50346300|Ruibarbos congelados|O|O||D||1|Acelgas rojas congeladas
50346301|Ruibarbo crimson rojo congelado|O|O||D||1|Acelga roja crimson congelada
50346302|Ruibarbo champagne temprana congelado|O|O||D||1|Acelga roja champagne temprana congelada
50346303|Ruibarbo glasrey perpetual  congelado|O|O||D||1|Acelga roja glasrey perpetual congelada
50346304|Ruibarbo sutton congelado|O|O||D||1|Acelga roja sutton congelada
50346305|Ruibarbo timperley temprano congelado|O|O||D||1|Acelga roja temprana de Timperley congelada
50346306|Ruibarbo valentina congelado|O|O||D||1|Acelga roja valentina congelada
50346307|Ruibarbo victoria congelado|O|O||D||1|Acelga roja victoria congelada
50346308|Ruibarbo zwolle de cemilla congelado|O|O||D||1|Acelga roja zwolle de semilla congelada
50346309|Ruibarbo macdonald congelado|O|O||D||1|Acelga roja macdonald congelada
50346310|Ruibarbo tilden congelado|O|O||D||1|Acelga roja tilden congelada
50346400|Escaramujos congelados|O|O||D||1|Rosa mosqueta congeladas
50346401|Escaramujo rosa brier congelado|O|O||D||1|Rosa mosqueta brier congelada
50346402|Escaramujo rosa elegante congelado|O|O||D||1|Rosa mosqueta elegante congelada
50346403|Escaramujo rosa rugosa congelado|O|O||D||1|Rosa mosqueta rugosa congelada
50346404|Escaramujo rosa burnet o scotch congelado|O|O||D||1|Rosa mosqueta burnet o scotch congelada
50346500|Sapotes congelados|O|O||D||1|Zapotes congelados
50346501|Sapote blanco congelado|O|O||D||1|Zapote blanco congelado
50346502|Sapote negro congelado|O|O||D||1|Zapote negro congelado
50346600|Bayas saskatoon congeladas|O|O||D||1|Fresas de junio congeladas
50346601|Baya mielmadera saskatoon congeladas|O|O||D||1|Fresa de junio mielmadera congelada
50346602|Baya northline saskatoon congeladas|O|O||D||1|Fresa de junio northline congelada
50346603|Baya saskatoon ahumado congeladas|O|O||D||1|Fresa de junio smoky congelada
50346604|Baya saskatoon thiessen congeladas|O|O||D||1|Fresa de junio thiessen congelada
50346700|Fresas congeladas|O|O||D||1
50346701|Fresa chandler congeladas|O|O||D||1
50346702|Fresa rumbo junio congeladas|O|O||D||1|Fresa temporada de junio congelada
50346703|Fresa rumbo siempre congeladas|O|O||D||1|Fresa de todo el año congelada
50346800|Manzanas dulces congeladas|O|O||D||1|Saramuyos congelados
50346801|Manzana kampong malve dulce congeladas|O|O||D||1|Saramuyo kampong mauve congelado
50346802|Manzana dulce sin semilla congeladas|O|O||D||1|Saramuyo sin semilla congelado
50346803|Manzana dulce thai lessand congeladas|O|O||D||1|Saramuyo thai lessand congelado
50346900|Tamarillos congelados|O|O||D||1|Tomates de árbol congelados
50346901|Tamarindo amberlea dorado congelado|O|O||D||1|Tomate de árbol amberlea dorado congelado
50346902|Tamarindo calvo dorado congelado|O|O||D||1|Tomate de árbol calvo dorado congelado
50346903|Tamarindo mina de oro congelado|O|O||D||1|Tomate de árbol mina de oro congelado
50346904|Tamarindo oratia rojo congelado|O|O||D||1|Tomate de árbol oratia rojo congelado
50346905|Tamarindo beau rojo congelado|O|O||D||1|Tomate de árbol beau rojo congelado
50346906|Tamarindo delicia roja congelado|O|O||D||1|Tomate de árbol delicia roja congelado
50347000|Frutas Nominant congeladas|O|O||D||1|Frutas predominantes congeladas
50347001|Cupania congeladas|O|O||D||1|Ackee congelada
50347002|Babaco congelado|O|O||D||1|Carica pentágona congelada
50347003|Banana flor congeladas|O|O||D||1|Flor de plátano congelada
50347004|Baobab congeladas|O|O||D||1
50347005|Naranja agria congeladas|O|O||D||1
50347006|Canistel congeladas|O|O||D||1|Zapote amarillo congelado
50347007|Coco congelado|O|O||D||1
50347008|Baya nube congelado|O|O||D||1|Mora de los pantanos congelada
50347009|Baya drew congeladas|O|O||D||1|Baya de gota congelada
50347010|Durian congeladas|O|O||D||1|Durio congelado
50347011|Baya elder congeladas|O|O||D||1|Baya de sauco congelada
50347012|Feijoa congeladas|O|O||D||1|Guayabo del Brasil congelado
50347013|Mora congeladas|O|O||D||1
50347014|Cretaegus congeladas|O|O||D||1|Majuelo congelado
50347015|Baya miel congeladas|O|O||D||1|Madreselva azul congelada
50347016|Jaca congeladas|O|O||D||1|Yaca congelada
50347017|Jambolan congeladas|O|O||D||1
50347018|Jujube congeladas|O|O||D||1|Azufaifa congelada
50347019|Liches congelados|O|O||D||1|Lichi congelado
50347020|Mangostinos congelados|O|O||D||1|Mangostán congelado
50347021|Medlar congeladas|O|O||D||1
50347022|Mombines congeladas|O|O||D||1|Hobo congelado
50347023|Monstera congeladas|O|O||D||1|Cerimán congelado
50347024|Pepinos congelado|O|O||D||1|Pepino dulce congelado
50347025|Platono congelado|O|O||D||1|Plátano macho congelado
50347026|Peras en escabeche congeladas|O|O||D||1|Tuna congelada
50347027|Mamonsillo congelado|O|O||D||1|Guaya congelada
50347028|Rambután congelado|O|O||D||1|Achotillo congelado
50347029|Manzana rosa congeladas|O|O||D||1|Pero de agua congelado
50347030|Rosele congeladas|O|O||D||1|Flor de jamaica congelada
50347031|Baya rowan congeladas|O|O||D||1|Serba congelada
50347032|Baya buckhom de mar congeladas|O|O||D||1|Espino amarillo congelado
50347033|Baya plata congeladas|O|O||D||1|Olivo de otoño congelado
50347034|Baya sorbete congelado|O|O||D||1|Serba congelada
50347035|Wanabana congeladas|O|O||D||1|Guanábana congelada
50347036|Manzana estrella congeladas|O|O||D||1|Cainito congelado
50347037|Tamarindo congelado|O|O||D||1
50347100|Aronias congeladas|O|O||D||1
50347101|Aronia magia de otoño congeladas|O|O||D||1
50347102|Aronia brillantísima congeladas|O|O||D||1
50347103|Aronia nero congeladas|O|O||D||1
50347104|Aronia viquingo congeladas|O|O||D||1
50347200|Aceitunas congeladas|O|O||D||1
50347201|Aceitunas agrinion congeladas|O|O||D||1|Aceituna agrinion congelada
50347202|Aceitunas alepo congeladas|O|O||D||1|Aceituna alepo congelada
50347203|Aceitunas  alfonso congeladas|O|O||D||1|Aceituna alfonso congelada
50347204|Aceitunas  anfisa congeladas|O|O||D||1|Aceituna anfisa congelada
50347205|Aceitunas  arauco congeladas|O|O||D||1|Aceituna arauco congelada
50347206|Aceitunas  arbequina congeladas|O|O||D||1|Aceituna arbequina congelada
50347207|Aceitunas  atlanta congeladas|O|O||D||1|Aceituna atlanta congelada
50347208|Aceitunas  cerignola congeladas|O|O||D||1|Aceituna cerignola congelada
50347209|Aceitunas  cracked provencal congeladas|O|O||D||1|Aceituna cracked provencal congelada
50347210|Aceitunas  empeltre congeladas|O|O||D||1|Aceituna empeltre congelada
50347211|Aceitunas gaeta  congeladas|O|O||D||1|Aceituna gaeta congelada
50347212|Aceitunas hondoelia congeladas|O|O||D||1|Aceituna hondoelia congelada
50347213|Aceitunas kalamata congeladas|O|O||D||1|Aceituna kalamata congelada
50347214|Aceitunas kura congeladas|O|O||D||1|Aceituna kura congelada
50347215|Aceitunas ligurian congeladas|O|O||D||1|Aceituna ligurian congelada
50347216|Aceitunas lucque congeladas|O|O||D||1|Aceituna lucque congelada
50347217|Aceitunas lugano congeladas|O|O||D||1|Aceituna lugano congelada
50347218|Aceitunas manzanilla congeladas|O|O||D||1|Aceituna manzanilla congelada
50347219|Aceitunas marche congeladas|O|O||D||1|Aceituna marche congelada
50347220|Aceitunas misión congeladas|O|O||D||1|Aceituna misión congelada
50347221|Aceitunas nafplion verde congeladas|O|O||D||1|Aceituna nafplion verde congelada
50347222|Aceitunas nicoise congeladas|O|O||D||1|Aceituna nicoise congelada
50347223|Aceitunas nyons congeladas|O|O||D||1|Aceituna nyons congelada
50347224|Aceitunas picholine congeladas|O|O||D||1|Aceituna picholine congelada
50347225|Aceitunas ponentine congeladas|O|O||D||1|Aceituna ponentine congelada
50347226|Aceitunas royal congeladas|O|O||D||1|Aceituna royal congelada
50347227|Aceitunas seracena congeladas|O|O||D||1|Aceituna seracena congelada
50347228|Aceitunas sevillano congeladas|O|O||D||1|Aceituna sevillano congelada
50347229|Aceitunas sicilian congeladas|O|O||D||1|Aceituna sicilian congelada
50347230|Aceitunas toscanella congeladas|O|O||D||1|Aceituna toscanella congelada
50351500|Manzanas orgánicas congeladas|O|O||D||1
50351501|Manzanas akane congelada orgánica|O|O||D||1|Manzana akane congelada orgánica
50351502|Manzana ambrosia congelada orgánica|O|O||D||1
50351503|Manzanas api congelada orgánica|O|O||D||1|Manzana api congelada orgánica
50351504|Manzanas baldwin congelada orgánica|O|O||D||1|Manzana baldwin congelada orgánica
50351505|Manzanas brabum congelada orgánica|O|O||D||1|Manzana brabum congelada orgánica
50351506|Manzanas bramley congelada orgánica|O|O||D||1|Manzana bramley congelada orgánica
50351507|Manzana joven bramley congelado orgánico|O|O||D||1
50351508|Manzana calville blanche d’hiver congelado orgánico|O|O||D||1
50351509|Manzana cameo congelada orgánica|O|O||D||1
50351510|Manzana charles ross congelada orgánica|O|O||D||1
50351511|Manzana codlin congelada orgánica|O|O||D||1
50351512|Manzana cortland congelada orgánica|O|O||D||1
50351513|Manzana costard congelada orgánica|O|O||D||1
50351514|Manzana court pendu plat congelada orgánica|O|O||D||1
50351515|Manzana  cox´s orange pippin congelada orgánica|O|O||D||1
50351516|Manzana crab congelada orgánica|O|O||D||1
50351517|Manzana crispin congelada orgánica|O|O||D||1
50351518|Manzana delicious congelada orgánica|O|O||D||1
50351519|Manzana duchess congelada orgánica|O|O||D||1
50351520|Manzana earligold congelada orgánica|O|O||D||1
50351521|Manzana early mcintosh congelada orgánica|O|O||D||1
50351522|Manzana elstar congelada orgánica|O|O||D||1
50351523|Manzana empire congelada orgánica|O|O||D||1
50351524|Manzana flower of kent congelada orgánica|O|O||D||1
50351525|Manzana fiji congelada orgánica|O|O||D||1
50351526|Manzana gala congelada orgánica|O|O||D||1
50351527|Manzana gascoyne´s scarlet congelada orgánica|O|O||D||1
50351528|Manzana gillyflower congelada orgánica|O|O||D||1
50351529|Manzana ginger gold congelada orgánica|O|O||D||1
50351530|Manzana gladstone congelada orgánica|O|O||D||1
50351531|Manzana gloster congelada orgánica|O|O||D||1
50351532|Manzana gold supreme congelada orgánica|O|O||D||1
50351533|Manzana golden delicious congelada orgánica|O|O||D||1
50351534|Manzana golden nobel congelada orgánica|O|O||D||1
50351535|Manzana granny smith congelada orgánica|O|O||D||1
50351536|Manzana gravenstain congelada orgánica|O|O||D||1
50351537|Manzana greening congelada orgánica|O|O||D||1
50351538|Manzana greensleeves congelada orgánica|O|O||D||1
50351539|Manzana honeycrisp congelada orgánica|O|O||D||1
50351540|Manzana howgate wonder congelada orgánica|O|O||D||1
50351541|Manzana red ida congelada orgánica|O|O||D||1
50351542|Manzana james grives congelada orgánica|O|O||D||1
50351543|Manzana jersey mac congelada orgánica|O|O||D||1
50351544|Manzana jaster congelada orgánica|O|O||D||1
50351545|Manzana jonagold congelada orgánica|O|O||D||1
50351546|Manzana jonamac congelada orgánica|O|O||D||1
50351547|Manzana  jonathan  congelada orgánica|O|O||D||1
50351548|Manzana katy congelada orgánica|O|O||D||1
50351549|Manzana kidd´s orange red congelada orgánica|O|O||D||1
50351550|Manzana lady congelada orgánica|O|O||D||1
50351551|Manzana law rome congelada orgánica|O|O||D||1
50351552|Manzana laxton congelada orgánica|O|O||D||1
50351553|Manzana lord derby congelada orgánica|O|O||D||1
50351554|Manzana macoun  congelada orgánica|O|O||D||1
50351555|Manzana mcintosh congelada orgánica|O|O||D||1
50351556|Manzana mutsu congelada orgánica|O|O||D||1
50351557|Manzana newtown pippin congelada orgánica|O|O||D||1
50351558|Manzana northen spy congelada orgánica congelada orgánica|O|O||D||1
50351559|Manzana orleans reinette congelada orgánica|O|O||D||1
50351560|Manzana ozark dorado congelada orgánica|O|O||D||1
50351561|Manzana rosa pacifica rose congelada orgánica|O|O||D||1
50351562|Manzana paula roja congelada orgánica|O|O||D||1
50351563|Manzana peamain congelada orgánica|O|O||D||1
50351564|Manzana dama rosada lady congelada orgánica|O|O||D||1
50351565|Manzana pippin congelada orgánica|O|O||D||1
50351566|Manzana pitmaston pineapple congelada orgánica|O|O||D||1
50351567|Manzana pomme dápi congelada orgánica|O|O||D||1
50351568|Manzana dorada primaria congelada orgánica|O|O||D||1
50351569|Manzana roja astrakhan congelada orgánica|O|O||D||1
50351570|Manzana roja boscoop congelada orgánica|O|O||D||1
50351571|Manzana  roja jefe congelada orgánica|O|O||D||1
50351572|Manzana roja deliciosa congelada orgánica|O|O||D||1
50351573|Manzana red grvenstain congelada orgánica|O|O||D||1
50351574|Manzana roma roja congelada orgánica|O|O||D||1
50351575|Manzana roja stayman congelada orgánica|O|O||D||1
50351576|Manzana red york congelada orgánica|O|O||D||1
50351577|Manzana reinette congelada orgánica|O|O||D||1
50351578|Manzana belleza romana congelada orgánica|O|O||D||1
50351579|Manzana russet congelada orgánica|O|O||D||1
50351580|Manzana sierra belleza congelada orgánica|O|O||D||1
50351581|Manzana spartan congelada orgánica|O|O||D||1
50351582|Manzana stark crimson congelada orgánica|O|O||D||1
50351583|Manzana starking congelada orgánica|O|O||D||1
50351584|Manzana stayman congelada orgánica|O|O||D||1
50351585|Manzana stayman winesap congelada orgánica|O|O||D||1
50351586|Manzana summer rambo congelada orgánica|O|O||D||1
50351587|Manzana tsugaru congelada orgánica|O|O||D||1
50351588|Manzana veinte onzas congelada orgánica|O|O||D||1
50351589|Manzana tydeman red congelada orgánica|O|O||D||1
50351590|Manzana vistabella congelada orgánica|O|O||D||1
50351591|Manzana weatley congelada orgánica|O|O||D||1
50351592|Manzana blanca joanetine congelada orgánica|O|O||D||1
50351593|Manzana blanca transparent congelada orgánica|O|O||D||1
50351594|Manzana winesap congelada orgánica|O|O||D||1
50351595|Manzana worcester congelada orgánica|O|O||D||1
50351596|Manzana york imperial congelada orgánica|O|O||D||1
50351600|Albaricoques orgánicos congelados|O|O||D||1|Chabacanos orgánicos congelados
50351601|Abaricoques ambercot congelada orgánica|O|O||D||1|Chabacano ambercot congelado orgánico
50351602|Albaricoques apache congelada orgánica|O|O||D||1|Chabacano apache congelado orgánico
50351603|Albaricoques brittany dorado congelada orgánica|O|O||D||1|Chabacano brittany dorado congelado orgánico
50351604|Albaricoque negra congelada orgánica|O|O||D||1|Chabacano negra congelado orgánico
50351605|Albaricoque blenheim congelada orgánica|O|O||D||1|Chabacano blenheim congelado orgánico
50351606|Albaricoque bonny congelada orgánica|O|O||D||1|Chabacano bonny congelado orgánico
50351607|Albaricoque biluda congelada orgánica|O|O||D||1|Chabacano biluda congelado orgánico
50351608|Albaricoque castlebrite congelada orgánica|O|O||D||1|Chabacano castlebrite congelado orgánico
50351609|Albaricoque  clutha dorada congelada orgánica|O|O||D||1|Chabacano clutha dorada congelado orgánico
50351610|Albaricoque clutha sol congelada orgánica|O|O||D||1|Chabacano clutha sol congelado orgánico
$sat$, E'\n') as l
 where l <> ''
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
