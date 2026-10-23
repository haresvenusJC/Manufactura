-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 2 de 10 (5867 claves; total 52513)
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
10402219|Rosal cortado seco isis|O|O||D||1
10402220|Rosal cortado seco joy o light versilia|O|O||D||1
10402221|Rosal cortado seco juliet ausjameson|O|O||D||1
10402222|Rosal cortado seco la parisienne|O|O||D||1
10402223|Rosal cortado seco la perla|O|O||D||1
10402224|Rosal cortado seco lovita sunblaze|O|O||D||1
10402225|Rosal cortado seco malilena o marilena|O|O||D||1
10402226|Rosal cortado seco monyna|O|O||D||1
10402227|Rosal cortado seco nectarine|O|O||D||1
10402228|Rosal cortado seco oriental curiosa|O|O||D||1
10402229|Rosal cortado seco osiana|O|O||D||1
10402230|Rosal cortado seco preach avalanche|O|O||D||1
10402231|Rosal cortado seco peach deja vu|O|O||D||1
10402232|Rosal cortado seco picanto|O|O||D||1
10402233|Rosal cortado seco prima donna|O|O||D||1
10402234|Rosal cortado seco sheril|O|O||D||1
10402235|Rosal cortado seco sirocco|O|O||D||1
10402236|Rosal cortado seco tamara|O|O||D||1
10402237|Rosal cortado seco taxo|O|O||D||1
10402238|Rosal cortado seco trust|O|O||D||1
10402239|Rosal cortado seco valencia|O|O||D||1
10402240|Rosal cortado seco cinci|O|O||D||1
10402241|Rosal cortado seco wanda|O|O||D||1
10402300|Rosas cortadas secas rosados|O|O||D||1
10402301|Rosal cortado seco aerobic|O|O||D||1
10402302|Rosal cortado seco after party|O|O||D||1
10402303|Rosal cortado seco amsterdam|O|O||D||1
10402304|Rosal cortado seco aqua rose|O|O||D||1
10402305|Rosal cortado seco attache|O|O||D||1
10402306|Rosal cortado seco attitude|O|O||D||1
10402307|Rosal cortado seco ballet|O|O||D||1
10402308|Rosal cortado seco belami|O|O||D||1
10402309|Rosal cortado seco bella voo o belle vue|O|O||D||1
10402310|Rosal cortado seco bling bling|O|O||D||1
10402311|Rosal cortado seco blushing akito|O|O||D||1
10402312|Rosal cortado seco brooke|O|O||D||1
10402313|Rosal cortado seco bugatti|O|O||D||1
10402314|Rosal cortado seco cadillac|O|O||D||1
10402315|Rosal cortado seco carnaval|O|O||D||1
10402316|Rosal cortado seco cereza|O|O||D||1
10402317|Rosal cortado seco charming|O|O||D||1
10402318|Rosal cortado seco cherry o|O|O||D||1
10402319|Rosal cortado seco ciciolina|O|O||D||1
10402320|Rosal cortado seco classic cezanne|O|O||D||1
10402321|Rosal cortado seco clasic duett|O|O||D||1
10402322|Rosal cortado seco cosmiq|O|O||D||1
10402323|Rosal cortado seco dark engagement|O|O||D||1
10402324|Rosal cortado seco daytona|O|O||D||1
10402325|Rosal cortado seco dekora|O|O||D||1
10402326|Rosal cortado seco dolores|O|O||D||1
10402327|Rosal cortado seco eliza|O|O||D||1
10402328|Rosal cortado seco baccara|O|O||D||1
10402329|Rosal cortado seco full house|O|O||D||1
10402330|Rosal cortado seco funky|O|O||D||1
10402331|Rosal cortado seco giliane|O|O||D||1
10402332|Rosal cortado seco gran europe|O|O||D||1
10402333|Rosal cortado seco habari|O|O||D||1
10402334|Rosal cortado seco hanseat|O|O||D||1
10402335|Rosal cortado seco high and amazing|O|O||D||1
10402336|Rosal cortado seco high and bonita|O|O||D||1
10402337|Rosal cortado seco high and booming|O|O||D||1
10402338|Rosal cortado seco high and fantasy|O|O||D||1
10402339|Rosal cortado seco high and rich|O|O||D||1
10402340|Rosal cortado seco hot lady|O|O||D||1
10402341|Rosal cortado seco hot princess|O|O||D||1
10402342|Rosal cortado seco inspiration|O|O||D||1
10402343|Rosal cortado seco jeimy|O|O||D||1
10402344|Rosal cortado seco kachita|O|O||D||1
10402345|Rosal cortado seco karen|O|O||D||1
10402346|Rosal cortado seco kenji|O|O||D||1
10402347|Rosal cortado seco kiko|O|O||D||1
10402348|Rosal cortado seco laser|O|O||D||1
10402349|Rosal cortado seco latin duett|O|O||D||1
10402350|Rosal cortado seco latin fever|O|O||D||1
10402351|Rosal cortado seco lifestyle|O|O||D||1
10402352|Rosal cortado seco light orlando|O|O||D||1
10402353|Rosal cortado seco lovely dreams|O|O||D||1
10402354|Rosal cortado seco loyalty|O|O||D||1
10402355|Rosal cortado seco malibu|O|O||D||1
10402356|Rosal cortado seco mata – hari|O|O||D||1
10402357|Rosal cortado seco memphis|O|O||D||1
10402358|Rosal cortado seco mi amor|O|O||D||1
10402359|Rosal cortado seco miami|O|O||D||1
10402360|Rosal cortado seco michelle|O|O||D||1
10402361|Rosal cortado seco mikaela|O|O||D||1
10402362|Rosal cortado seco orchestra|O|O||D||1
10402363|Rosal cortado seco orlando|O|O||D||1
10402364|Rosal cortado seco osadia|O|O||D||1
10402365|Rosal cortado seco paeonia freelander|O|O||D||1
10402366|Rosal cortado seco paula|O|O||D||1
10402367|Rosal cortado seco pavarotti|O|O||D||1
10402368|Rosal cortado seco pink intuition|O|O||D||1
10402369|Rosal cortado seco poison|O|O||D||1
10402370|Rosal cortado seco princess|O|O||D||1
10402371|Rosal cortado seco queen mary|O|O||D||1
10402372|Rosal cortado seco raphaela|O|O||D||1
10402373|Rosal cortado seco raspberry|O|O||D||1
10402374|Rosal cortado seco ravel|O|O||D||1
10402375|Rosal cortado seco riviera|O|O||D||1
10402376|Rosal cortado seco sade|O|O||D||1
10402377|Rosal cortado seco sashimi|O|O||D||1
10402378|Rosal cortado seco shanya|O|O||D||1
10402379|Rosal cortado seco shocking versilia|O|O||D||1
10402380|Rosal cortado seco solitaire|O|O||D||1
10402381|Rosal cortado seco something different|O|O||D||1
10402382|Rosal cortado seco splendid renate|O|O||D||1
10402383|Rosal cortado seco star|O|O||D||1
10402384|Rosal cortado seco sweet candia|O|O||D||1
10402385|Rosal cortado seco sweet moments|O|O||D||1
10402386|Rosal cortado seco sweet unique|O|O||D||1
10402387|Rosal cortado seco taboo|O|O||D||1
10402388|Rosal cortado seco timona|O|O||D||1
10402389|Rosal cortado seco topaz|O|O||D||1
10402390|Rosal cortado seco vogue|O|O||D||1
10402391|Rosal cortado seco voila|O|O||D||1
10402392|Rosal cortado seco wild|O|O||D||1
10402393|Rosal cortado seco yves piaget|O|O||D||1
10402400|Rosas cortadas secas rojos o burgundy|O|O||D||1
10402401|Rosal cortado seco african dawn|O|O||D||1
10402402|Rosal cortado seco amada|O|O||D||1
10402403|Rosal cortado seco black baccara|O|O||D||1
10402404|Rosal cortado seco black beauty|O|O||D||1
10402405|Rosal cortado seco black finess o black magic|O|O||D||1
10402406|Rosal cortado seco black magic|O|O||D||1
10402407|Rosal cortado seco bohemian o pasarela|O|O||D||1
10402408|Rosal cortado seco breathless|O|O||D||1
10402409|Rosal cortado seco caballero|O|O||D||1
10402410|Rosal cortado seco carrera|O|O||D||1
10402411|Rosal cortado seco charlene|O|O||D||1
10402412|Rosal cortado seco charlotte|O|O||D||1
10402413|Rosal cortado seco cherry lady|O|O||D||1
10402414|Rosal cortado seco cherry love|O|O||D||1
10402415|Rosal cortado seco classy rose|O|O||D||1
10402416|Rosal cortado seco colorado velvet|O|O||D||1
10402417|Rosal cortado seco corazón|O|O||D||1
10402418|Rosal cortado seco corrida|O|O||D||1
10402419|Rosal cortado seco dynamite|O|O||D||1
10402420|Rosal cortado seco eurored|O|O||D||1
10402421|Rosal cortado seco fashion|O|O||D||1
10402422|Rosal cortado seco fire and ice|O|O||D||1
10402423|Rosal cortado seco first red|O|O||D||1
10402424|Rosal cortado seco forever young|O|O||D||1
10402425|Rosal cortado seco freedom|O|O||D||1
10402426|Rosal cortado seco freestyle|O|O||D||1
10402427|Rosal cortado seco friendship|O|O||D||1
10402428|Rosal cortado seco gospel|O|O||D||1
10402429|Rosal cortado seco graffity|O|O||D||1
10402430|Rosal cortado seco grand gala|O|O||D||1
10402431|Rosal cortado seco grand prix|O|O||D||1
10402432|Rosal cortado seco grand classe|O|O||D||1
10402433|Rosal cortado seco hearts|O|O||D||1
10402434|Rosal cortado seco heat|O|O||D||1
10402435|Rosal cortado seco hocus pocus|O|O||D||1
10402436|Rosal cortado seco lady in red|O|O||D||1
10402437|Rosal cortado seco latin lady|O|O||D||1
10402438|Rosal cortado seco legend|O|O||D||1
10402439|Rosal cortado seco lulu|O|O||D||1
10402440|Rosal cortado seco luna rossa|O|O||D||1
10402441|Rosal cortado seco luxor|O|O||D||1
10402442|Rosal cortado seco madame delbard o carola|O|O||D||1
10402443|Rosal cortado seco miss paris|O|O||D||1
10402444|Rosal cortado seco nicole|O|O||D||1
10402445|Rosal cortado seco night fever|O|O||D||1
10402446|Rosal cortado seco obsession|O|O||D||1
10402447|Rosal cortado seco opium|O|O||D||1
10402448|Rosal cortado seco paz|O|O||D||1
10402449|Rosal cortado seco preference|O|O||D||1
10402450|Rosal cortado seco red berlin|O|O||D||1
10402451|Rosal cortado seco red bull|O|O||D||1
10402452|Rosal cortado seco red calypso|O|O||D||1
10402453|Rosal cortado seco red diamond|O|O||D||1
10402454|Rosal cortado seco red fantasy|O|O||D||1
10402455|Rosal cortado seco red france|O|O||D||1
10402456|Rosal cortado seco red intuition|O|O||D||1
10402457|Rosal cortado seco red jewel|O|O||D||1
10402458|Rosal cortado seco red magic|O|O||D||1
10402459|Rosal cortado seco red one|O|O||D||1
10402460|Rosal cortado seco red paris|O|O||D||1
10402461|Rosal cortado seco red princess|O|O||D||1
10402462|Rosal cortado seco red sensation o colorad|O|O||D||1
10402463|Rosal cortado seco red unique|O|O||D||1
10402464|Rosal cortado seco rockefeller|O|O||D||1
10402465|Rosal cortado seco romeo|O|O||D||1
10402466|Rosal cortado seco rouge baiser|O|O||D||1
10402467|Rosal cortado seco roulette|O|O||D||1
10402468|Rosal cortado seco royal massai|O|O||D||1
10402469|Rosal cortado seco royal red|O|O||D||1
10402470|Rosal cortado seco samurai|O|O||D||1
10402471|Rosal cortado seco sexy red|O|O||D||1
10402472|Rosal cortado seco starfire|O|O||D||1
10402473|Rosal cortado seco tango|O|O||D||1
10402474|Rosal cortado seco tiger tail|O|O||D||1
10402475|Rosal cortado seco tinto|O|O||D||1
10402476|Rosal cortado seco top secret|O|O||D||1
10402477|Rosal cortado seco vital|O|O||D||1
10402478|Rosal cortado seco wisdom|O|O||D||1
10402479|Rosal cortado seco xantia|O|O||D||1
10402480|Rosal cortado seco xcite|O|O||D||1
10402500|Rosas cortadas secas sweetheart|O|O||D||1|Rosas La Minuette cortadas secas
10402501|Rosal cortado seco burgundy sweetheart|O|O||D||1|Rosa La Minuette cortada seca burgundy
10402502|Rosal cortado seco cream sweetheart|O|O||D||1|Rosa La Minuette cortada seca cream
10402503|Rosal cortado seco hot pink sweetheart|O|O||D||1|Rosa La Minuette cortada seca hot pink
10402504|Rosal cortado seco lavender sweetheart|O|O||D||1|Rosa La Minuette cortada seca lavender
10402505|Rosal cortado seco light pink sweetheart|O|O||D||1|Rosa La Minuette cortada seca light pink
10402506|Rosal cortado seco orange sweetheart|O|O||D||1|Rosa La Minuette cortada seca orange
10402507|Rosal cortado seco peach sweetheart|O|O||D||1|Rosa La Minuette cortada seca peach
10402508|Rosal cortado seco red sweetheart|O|O||D||1|Rosa La Minuette cortada seca red
10402509|Rosal cortado seco white sweetheart|O|O||D||1|Rosa La Minuette cortada seca white
10402510|Rosal cortado seco yelllow sweetheart|O|O||D||1|Rosa La Minuette cortada seca yellow
10402600|Rosas cortadas secas blancos|O|O||D||1
10402601|Rosal cortado seco absolut|O|O||D||1
10402602|Rosal cortado seco aida|O|O||D||1
10402603|Rosal cortado seco akito|O|O||D||1
10402604|Rosal cortado seco amelia|O|O||D||1
10402605|Rosal cortado seco anastasia|O|O||D||1
10402606|Rosal cortado seco andean crystal|O|O||D||1
10402607|Rosal cortado seco angel|O|O||D||1
10402608|Rosal cortado seco annemarie|O|O||D||1
10402609|Rosal cortado seco avalanche|O|O||D||1
10402610|Rosal cortado seco bianca|O|O||D||1
10402611|Rosal cortado seco blizzard|O|O||D||1
10402612|Rosal cortado seco bridal akito|O|O||D||1
10402613|Rosal cortado seco domenica|O|O||D||1
10402614|Rosal cortado seco escimo|O|O||D||1
10402615|Rosal cortado seco farfalla|O|O||D||1
10402616|Rosal cortado seco high and peace|O|O||D||1
10402617|Rosal cortado seco high and pure|O|O||D||1
10402618|Rosal cortado seco inocencia o innocenti|O|O||D||1
10402619|Rosal cortado seco ivory|O|O||D||1
10402620|Rosal cortado seco mondial|O|O||D||1
10402621|Rosal cortado seco mount everest|O|O||D||1
10402622|Rosal cortado seco nova zembla|O|O||D||1
10402623|Rosal cortado seco patience o auspator|O|O||D||1
10402624|Rosal cortado seco polar star|O|O||D||1
10402625|Rosal cortado seco polo|O|O||D||1
10402626|Rosal cortado seco proud|O|O||D||1
10402627|Rosal cortado seco snowy jewel|O|O||D||1
10402628|Rosal cortado seco tibet|O|O||D||1
10402629|Rosal cortado seco tineke|O|O||D||1
10402630|Rosal cortado seco vitality|O|O||D||1
10402631|Rosal cortado seco white cadillac|O|O||D||1
10402632|Rosal cortado seco white dove|O|O||D||1
10402700|Rosas cortadas secas amarillos|O|O||D||1
10402701|Rosal cortado seco aalsmeer gold|O|O||D||1
10402702|Rosal cortado seco alina|O|O||D||1
10402703|Rosal cortado seco ambiance|O|O||D||1
10402704|Rosal cortado seco aquarel|O|O||D||1
10402705|Rosal cortado seco autumn|O|O||D||1
10402706|Rosal cortado seco brasil|O|O||D||1
10402707|Rosal cortado seco candle light|O|O||D||1
10402708|Rosal cortado seco cantata o cantate|O|O||D||1
10402709|Rosal cortado seco capriccio|O|O||D||1
10402710|Rosal cortado seco caribbean|O|O||D||1
10402711|Rosal cortado seco circus|O|O||D||1
10402712|Rosal cortado seco citran|O|O||D||1
10402713|Rosal cortado seco concorde|O|O||D||1
10402714|Rosal cortado seco conga|O|O||D||1
10402715|Rosal cortado seco deja vu|O|O||D||1
10402716|Rosal cortado seco desire|O|O||D||1
10402717|Rosal cortado seco donia sol|O|O||D||1
10402718|Rosal cortado seco dueto|O|O||D||1
10402719|Rosal cortado seco erin|O|O||D||1
10402720|Rosal cortado seco exotic curiosa|O|O||D||1
10402721|Rosal cortado seco feria|O|O||D||1
10402722|Rosal cortado seco fire bird|O|O||D||1
10402723|Rosal cortado seco florida|O|O||D||1
10402724|Rosal cortado seco friendly|O|O||D||1
10402725|Rosal cortado seco gallinda|O|O||D||1
10402726|Rosal cortado seco geisha|O|O||D||1
10402727|Rosal cortado seco gelbe|O|O||D||1
10402728|Rosal cortado seco gelosia o yellow flame|O|O||D||1
10402729|Rosal cortado seco gold rush|O|O||D||1
10402730|Rosal cortado seco gold star|O|O||D||1
10402731|Rosal cortado seco gold strike|O|O||D||1
10402732|Rosal cortado seco golda|O|O||D||1
10402733|Rosal cortado seco golden fashion|O|O||D||1
10402734|Rosal cortado seco golden gate|O|O||D||1
10402735|Rosal cortado seco gran dorado|O|O||D||1
10402736|Rosal cortado seco helio|O|O||D||1
10402737|Rosal cortado seco high and exotic|O|O||D||1
10402738|Rosal cortado seco high and yellow|O|O||D||1
10402739|Rosal cortado seco high and yellow magic|O|O||D||1
10402740|Rosal cortado seco high society|O|O||D||1
10402741|Rosal cortado seco hummer|O|O||D||1
10402742|Rosal cortado seco idole o elle|O|O||D||1
10402743|Rosal cortado seco inti|O|O||D||1
10402744|Rosal cortado seco jet set|O|O||D||1
10402745|Rosal cortado seco judy|O|O||D||1
10402746|Rosal cortado seco jupiter|O|O||D||1
10402747|Rosal cortado seco konfetti|O|O||D||1
10402748|Rosal cortado seco kyara o kira|O|O||D||1
10402749|Rosal cortado seco latin beauty|O|O||D||1
10402750|Rosal cortado seco latin spirit|O|O||D||1
10402751|Rosal cortado seco latina|O|O||D||1
10402752|Rosal cortado seco lina|O|O||D||1
10402753|Rosal cortado seco lindsey|O|O||D||1
10402754|Rosal cortado seco male|O|O||D||1
10402755|Rosal cortado seco marie clare|O|O||D||1
10402756|Rosal cortado seco marisa|O|O||D||1
10402757|Rosal cortado seco matchball|O|O||D||1
10402758|Rosal cortado seco melon|O|O||D||1
10402759|Rosal cortado seco mohana|O|O||D||1
10402760|Rosal cortado seco okie dokie|O|O||D||1
10402761|Rosal cortado seco pailine|O|O||D||1
10402762|Rosal cortado seco parrot|O|O||D||1
10402763|Rosal cortado seco rio d oro|O|O||D||1
10402764|Rosal cortado seco salami|O|O||D||1
10402765|Rosal cortado seco santa fe|O|O||D||1
10402766|Rosal cortado seco skyline|O|O||D||1
10402767|Rosal cortado seco sonrisa|O|O||D||1
10402768|Rosal cortado seco star ambiance|O|O||D||1
10402769|Rosal cortado seco starbust|O|O||D||1
10402770|Rosal cortado seco sun king|O|O||D||1
10402771|Rosal cortado seco sunmaster|O|O||D||1
10402772|Rosal cortado seco sunny milva|O|O||D||1
10402773|Rosal cortado seco sushi|O|O||D||1
10402774|Rosal cortado seco tabasco|O|O||D||1
10402775|Rosal cortado seco tara|O|O||D||1
10402776|Rosal cortado seco tresor 2000|O|O||D||1
10402777|Rosal cortado seco ooty|O|O||D||1
10402778|Rosal cortado seco yellow coral|O|O||D||1
10402779|Rosal cortado seco yellow finess|O|O||D||1
10402780|Rosal cortado seco yellow submarine|O|O||D||1
10402781|Rosal cortado seco yellow sunset|O|O||D||1
10402782|Rosal cortado seco yelllow timeless|O|O||D||1
10402800|Rosas cortadas secas spray|O|O||D||1
10402801|Rosal cortado seco alegría spray|O|O||D||1
10402802|Rosal cortado seco andrea follies|O|O||D||1
10402803|Rosal cortado seco antara follies|O|O||D||1
10402804|Rosal cortado seco arrow follies|O|O||D||1
10402805|Rosal cortado seco babe spray|O|O||D||1
10402806|Rosal cortado seco bellina collection|O|O||D||1
10402807|Rosal cortado seco blue moon|O|O||D||1
10402808|Rosal cortado seco chablis spray|O|O||D||1
10402809|Rosal cortado seco cherry follies|O|O||D||1
10402810|Rosal cortado seco chess spray|O|O||D||1
10402811|Rosal cortado seco classic lydia spray|O|O||D||1
10402812|Rosal cortado seco cream gracia spray|O|O||D||1
10402813|Rosal cortado seco cream lydia srpay|O|O||D||1
10402814|Rosal cortado seco cream sensation spray|O|O||D||1
10402815|Rosal cortado seco cremita spray|O|O||D||1
10402816|Rosal cortado seco diablo spray|O|O||D||1
10402817|Rosal cortado seco electra spray|O|O||D||1
10402818|Rosal cortado seco fire king spray|O|O||D||1
10402819|Rosal cortado seco fleurspray|O|O||D||1
10402820|Rosal cortado seco girlie follies spray|O|O||D||1
10402821|Rosal cortado seco giselle follies spray|O|O||D||1
10402822|Rosal cortado seco golden collection spray|O|O||D||1
10402823|Rosal cortado seco golden mimi spray|O|O||D||1
10402824|Rosal cortado seco gracia spray|O|O||D||1
10402825|Rosal cortado seco hot majolica spray|O|O||D||1
10402826|Rosal cortado seco hot pink follies spray|O|O||D||1
10402827|Rosal cortado seco ilse spray|O|O||D||1
10402828|Rosal cortado seco jelena spray|O|O||D||1
10402829|Rosal cortado seco laminuette spray|O|O||D||1
10402830|Rosal cortado seco lavender follies spray|O|O||D||1
10402831|Rosal cortado seco limoncello spray|O|O||D||1
10402832|Rosal cortado seco little silver spray|O|O||D||1
10402833|Rosal cortado seco lovely lydia spray|O|O||D||1
10402834|Rosal cortado seco lucy spray|O|O||D||1
10402835|Rosal cortado seco lydia spray|O|O||D||1
10402836|Rosal cortado seco macarena spray|O|O||D||1
10402837|Rosal cortado seco magic sensation spray|O|O||D||1
10402838|Rosal cortado seco majolica spray|O|O||D||1
10402839|Rosal cortado seco mambo número 5 spray|O|O||D||1
10402840|Rosal cortado seco mambo spray|O|O||D||1
10402841|Rosal cortado seco marlene spray|O|O||D||1
10402842|Rosal cortado seco mimi eden spray|O|O||D||1
10402843|Rosal cortado seco minou spray|O|O||D||1
10402844|Rosal cortado seco nikita spray|O|O||D||1
10402845|Rosal cortado seco novel collection spray|O|O||D||1
10402846|Rosal cortado seco orange success spray|O|O||D||1
10402847|Rosal cortado seco pepita spray|O|O||D||1
10402848|Rosal cortado seco pink flash spray|O|O||D||1
10402849|Rosal cortado seco pink sensation spray|O|O||D||1
10402850|Rosal cortado seco porcelina spray|O|O||D||1
10402851|Rosal cortado seco princess spray|O|O||D||1
10402852|Rosal cortado seco purple mikado spray|O|O||D||1
10402853|Rosal cortado seco red angel spray|O|O||D||1
10402854|Rosal cortado seco red collection spray|O|O||D||1
10402855|Rosal cortado seco red hero spray|O|O||D||1
10402856|Rosal cortado seco red mikado spray|O|O||D||1
10402857|Rosal cortado seco red vision spray|O|O||D||1
10402858|Rosal cortado seco ritmo spray|O|O||D||1
10402859|Rosal cortado seco romance mikado o eva spray|O|O||D||1
10402860|Rosal cortado seco romántica follies spray|O|O||D||1
10402861|Rosal cortado seco rubicon spray|O|O||D||1
10402862|Rosal cortado seco rumba spray|O|O||D||1
10402863|Rosal cortado seco salsa spray|O|O||D||1
10402864|Rosal cortado seco sangrita spray|O|O||D||1
10402865|Rosal cortado seco santa bárbara spray|O|O||D||1
10402866|Rosal cortado seco sashaba spray|O|O||D||1
10402867|Rosal cortado seco scarlett spray|O|O||D||1
10402868|Rosal cortado seco seline spray|O|O||D||1
10402869|Rosal cortado seco sensation spray|O|O||D||1
10402870|Rosal cortado seco silver collection spray|O|O||D||1
10402871|Rosal cortado seco silver sensation spray|O|O||D||1
10402872|Rosal cortado seco snowdance spray|O|O||D||1
10402873|Rosal cortado seco snowflake spray|O|O||D||1
10402874|Rosal cortado seco suncity spray|O|O||D||1
10402875|Rosal cortado seco super nova spray|O|O||D||1
10402876|Rosal cortado seco sweet sensation spray|O|O||D||1
10402877|Rosal cortado seco taifun o typhoon spray|O|O||D||1
10402878|Rosal cortado seco tamango spray|O|O||D||1
10402879|Rosal cortado seco tanger follies spray|O|O||D||1
10402880|Rosal cortado seco tiara spray|O|O||D||1
10402881|Rosal cortado seco tiramisú spray|O|O||D||1
10402882|Rosal cortado seco twinkle bride spray|O|O||D||1
10402883|Rosal cortado seco viviane spray|O|O||D||1
10402884|Rosal cortado seco white majolica spray|O|O||D||1
10402885|Rosal cortado seco white mikado spray|O|O||D||1
10402886|Rosal cortado seco xentina spray|O|O||D||1
10402887|Rosal cortado seco yellow babe spray|O|O||D||1
10402888|Rosal cortado seco yellow follies spray|O|O||D||1
10411500|Anturios cortado secos|O|O||D||1|Lirios flamingo cortados secos
10411501|Anturio cortado seco chocolate|O|O||D||1|Lirio flamingo cortado seco chocolate
10411502|Anturio cortado seco rojo oscuro|O|O||D||1|Lirio flamingo cortado seco rojo oscuro
10411503|Anturio cortado seco verde|O|O||D||1|Lirio flamingo cortado seco verde
10411504|Anturio cortado seco rosado fuerte|O|O||D||1|Lirio flamingo cortado seco rosado fuerte
10411505|Anturio cortado seco mickey mouse|O|O||D||1|Lirio flamingo cortado seco mickey mouse
10411506|Anturio cortado seco obake verde y blanco|O|O||D||1|Lirio flamingo cortado seco obake verde y blanco
10411507|Anturio cortado seco obake rojo y verde|O|O||D||1|Lirio flamingo cortado seco obake rojo y verde
10411508|Anturio cortado seco anaranjado|O|O||D||1|Lirio flamingo cortado seco anaranjado
10411509|Anturio cortado seco durazno|O|O||D||1|Lirio flamingo cortado seco durazno
10411510|Anturio cortado seco picasso o pecoso|O|O||D||1|Lirio flamingo cortado seco picasso o pecoso
10411511|Anturio cortado seco rojo|O|O||D||1|Lirio flamingo cortado seco rojo
10411512|Anturio cortado seco splash|O|O||D||1|Lirio flamingo cortado seco splash
10411513|Anturio cortado seco tropic fire|O|O||D||1|Lirio flamingo cortado seco tropic fire
10411514|Anturio cortado seco verde tulipán|O|O||D||1|Lirio flamingo cortado seco verde tulipán
10411515|Anturio cortado seco rosado tulipán|O|O||D||1|Lirio flamingo cortado seco rosado tulipán
10411516|Anturio cortado seco púrpura tulipán|O|O||D||1|Lirio flamingo cortado seco púrpura tulipán
10411517|Anturio cortado seco rojo tulipán|O|O||D||1|Lirio flamingo cortado seco rojo tulipán
10411518|Anturio cortado seco blanco|O|O||D||1|Lirio flamingo cortado seco blanco
10411519|Anturio cortado seco blanco salvaje|O|O||D||1|Lirio flamingo cortado seco blanco salvaje
10411600|Allium cortado seco|O|O||D||1|Cebolletas ornamentales cortadas secas
10411601|Allium cortado seco ambassador|O|O||D||1|Cebolleta ornamental cortada seca ambassador
10411602|Allium cortado seco ampeloprasum|O|O||D||1|Cebolleta ornamental cortada seca ampeloprasum
10411603|Allium cortado seco bullit o drumstick|O|O||D||1|Cebolleta ornamental cortada seca bullit o drumstick
10411604|Allium cortado seco christophii|O|O||D||1|Cebolleta ornamental cortada seca christophii
10411605|Allium cortado seco cowanii|O|O||D||1|Cebolleta ornamental cortada seca cowanii
10411606|Allium cortado seco gigante|O|O||D||1|Cebolleta ornamental cortada seca gigante
10411607|Allium cortado seco gladiador|O|O||D||1|Cebolleta ornamental cortada seca gladiador
10411608|Allium cortado seco globemaster|O|O||D||1|Cebolleta ornamental cortada seca globemaster
10411609|Allium cortado seco bola de golf|O|O||D||1|Cebolleta ornamental cortada seca bola de golf
10411610|Allium cortado seco cabello|O|O||D||1|Cebolleta ornamental cortada seca cabello
10411611|Allium cortado seco rosado gigante|O|O||D||1|Cebolleta ornamental cortada seca rosado gigante
10411612|Allium cortado seco sensación púrpura|O|O||D||1|Cebolleta ornamental cortada seca sensación púrpura
10411613|Allium cortado seco sicilum hanging|O|O||D||1|Cebolleta ornamental cortada seca sicilum hanging
10411614|Allium cortado seco spider schubertii|O|O||D||1|Cebolleta ornamental cortada seca spider schubertii
10411615|Allium cortado seco spray moly|O|O||D||1|Cebolleta ornamental cortada seca spray moly
10411616|Allium cortado seco spray roseum|O|O||D||1|Cebolleta ornamental cortada seca spray roseum
10411617|Allium cortado seco tuberosum|O|O||D||1|Cebolleta ornamental cortada seca tuberosum
10411618|Allium cortado seco unifolium o spray|O|O||D||1|Cebolleta ornamental cortada seca unifolium o spray
10411619|Allium cortado seco monte everest blanco|O|O||D||1|Cebolleta ornamental cortada seca monte everest blanco
10411700|Astromelia cortada seca|O|O||D||1|Lirios de campo cortados secos
10411701|Astromelia cortada seca agropoli|O|O||D||1|Lirio de campo cortado seco agropoli
10411702|Astromelia cortada seca bourgogne|O|O||D||1|Lirio de campo cortado seco bourgogne
10411703|Astromelia cortada seca cairo|O|O||D||1|Lirio de campo cortado seco cairo
10411704|Astromelia cortada seca charmes|O|O||D||1|Lirio de campo cortado seco charmes
10411705|Astromelia cortada seca cherry bay|O|O||D||1|Lirio de campo cortado seco cherry bay
10411706|Astromelia cortada seca cherry white|O|O||D||1|Lirio de campo cortado seco cherry white
10411707|Astromelia cortada seca dame blanche|O|O||D||1|Lirio de campo cortado seco dame blanche
10411708|Astromelia cortada seca diamond|O|O||D||1|Lirio de campo cortado seco diamond
10411709|Astromelia cortada seca gran canaria|O|O||D||1|Lirio de campo cortado seco gran canaria
10411710|Astromelia cortada seca harlekijn|O|O||D||1|Lirio de campo cortado seco harlekijn
10411711|Astromelia cortada seca indian summer|O|O||D||1|Lirio de campo cortado seco indian summer
10411712|Astromelia cortada seca jamaica|O|O||D||1|Lirio de campo cortado seco jamaica
10411713|Astromelia cortada seca macondo|O|O||D||1|Lirio de campo cortado seco macondo
10411714|Astromelia cortada seca mistique|O|O||D||1|Lirio de campo cortado seco mistique
10411715|Astromelia cortada seca my fair|O|O||D||1|Lirio de campo cortado seco my fair
10411716|Astromelia cortada seca new cairo|O|O||D||1|Lirio de campo cortado seco new cairo
10411717|Astromelia cortada seca nice|O|O||D||1|Lirio de campo cortado seco nice
10411718|Astromelia cortada seca orange bowl|O|O||D||1|Lirio de campo cortado seco orange bowl
10411719|Astromelia cortada seca orange queens|O|O||D||1|Lirio de campo cortado seco orange queens
10411720|Astromelia cortada seca orange sun|O|O||D||1|Lirio de campo cortado seco orange sun
10411721|Astromelia cortada seca paris|O|O||D||1|Lirio de campo cortado seco parís
10411722|Astromelia cortada seca picasso|O|O||D||1|Lirio de campo cortado seco picasso
10411723|Astromelia cortada seca pink panther|O|O||D||1|Lirio de campo cortado seco pink panther
10411724|Astromelia cortada seca prima donna|O|O||D||1|Lirio de campo cortado seco prima donna
10411725|Astromelia cortada seca red silhouette|O|O||D||1|Lirio de campo cortado seco red silhouette
10411726|Astromelia cortada seca sacha|O|O||D||1|Lirio de campo cortado seco sacha
10411727|Astromelia cortada seca salmón|O|O||D||1|Lirio de campo cortado seco salmón
10411728|Astromelia cortada seca santiago|O|O||D||1|Lirio de campo cortado seco santiago
10411729|Astromelia cortada seca senna|O|O||D||1|Lirio de campo cortado seco senna
10411730|Astromelia cortada seca snowball|O|O||D||1|Lirio de campo cortado seco snowball
10411731|Astromelia cortada seca sublime|O|O||D||1|Lirio de campo cortado seco sublime
10411732|Astromelia cortada seca tropicana|O|O||D||1|Lirio de campo cortado seco tropicana
10411733|Astromelia cortada seca virginia|O|O||D||1|Lirio de campo cortado seco virginia
10411734|Astromelia cortada seca blanca|O|O||D||1|Lirio de campo cortado seco blanca
10411800|Amaranto cortado seco|O|O||D||1
10411801|Amaranto cortado seco verde colgante|O|O||D||1
10411802|Amaranto cortado seco rojo colgante|O|O||D||1
10411803|Amaranto cortado seco bronce erguido|O|O||D||1
10411804|Amaranto cortado seco verde erguido|O|O||D||1
10411805|Amaranto cortado seco rojo erguido|O|O||D||1
10411900|Amaryllis cortado seco|O|O||D||1|Amaryllis cortada seca
10411901|Amaryllis cortado seco naranja|O|O||D||1|Amaryllis cortada seca naranja
10411902|Amaryllis cortado seco orange nagano|O|O||D||1|Amaryllis cortada seca orange nagano
10411903|Amaryllis cortado seco pigmeo mini|O|O||D||1|Amaryllis cortada seca pigmeo mini
10411904|Amaryllis cortado seco red lion|O|O||D||1|Amaryllis cortada seca red lion
10411905|Amaryllis cortado seco rilona|O|O||D||1|Amaryllis cortada seca rilona
10411906|Amaryllis cortado seco royal velvet|O|O||D||1|Amaryllis cortada seca royal velvet
10411907|Amaryllis cortado seco sonatini naranja|O|O||D||1|Amaryllis cortada seca sonatini naranja
10411908|Amaryllis cortado seco sonatini rojo|O|O||D||1|Amaryllis cortada seca sonatini rojo
10411909|Amaryllis cortado seco tango|O|O||D||1|Amaryllis cortada seca tango
10411910|Amaryllis cortado seco tinto night|O|O||D||1|Amaryllis cortada seca tinto night
10412000|Anémona cortada seca|O|O||D||1
10412001|Anémona cortada seca aubergine|O|O||D||1
10412002|Anémona cortada seca negra|O|O||D||1
10412003|Anémona cortada seca azul|O|O||D||1
10412004|Anémona cortada seca cereza|O|O||D||1
10412005|Anémona cortada seca coronaria|O|O||D||1
10412006|Anémona cortada seca rosado fuerte|O|O||D||1
10412007|Anémona cortada seca rosado claro|O|O||D||1
10412008|Anémona cortada seca rosado|O|O||D||1
10412009|Anémona cortada seca púrpura|O|O||D||1
10412010|Anémona cortada seca roja|O|O||D||1
10412011|Anémona cortada seca blanca|O|O||D||1
10412100|Asclepia cortada seca|O|O||D||1|Algodoncillos cortados secos
10412101|Asclepia cortada seca lavanda|O|O||D||1|Algodoncillo cortado seco lavanda
10412102|Asclepia cortada seca moby dick|O|O||D||1|Algodoncillo cortado seco moby dick
10412103|Asclepia cortada seca tuberosa|O|O||D||1|Algodoncillo cortado seco tuberosa
10412104|Asclepia cortada seca blanca|O|O||D||1|Algodoncillo cortado seco blanca
10412200|Aster cortada seca|O|O||D||1|Estrellas cortadas secas
10412201|Aster cortada seca beauty|O|O||D||1|Estrella cortada seca beauty
10412202|Aster cortada seca japonés azul|O|O||D||1|Estrella cortada seca japonés azul
10412203|Aster cortada seca japonés verde|O|O||D||1|Estrella cortada seca japonés verde
10412204|Aster cortada seca japonés rosado fuerte|O|O||D||1|Estrella cortada seca japonés rosado fuerte
10412205|Aster cortada seca japonés lavanda|O|O||D||1|Estrella cortada seca japonés lavanda
10412206|Aster cortada seca japonés rosado claro|O|O||D||1|Estrella cortada seca japonés rosado claro
10412207|Aster cortada seca japonés durazno|O|O||D||1|Estrella cortada seca japonés durazno
10412208|Aster cortada seca japonés rosado|O|O||D||1|Estrella cortada seca japonés rosado
10412209|Aster cortada seca japonés púrpura|O|O||D||1|Estrella cortada seca japonés púrpura
10412210|Aster cortada seca japonés rojo|O|O||D||1|Estrella cortada seca japonés rojo
10412211|Aster cortada seca japonés spider|O|O||D||1|Estrella cortada seca japonés spider
10412212|Aster cortada seca japonés  blanco|O|O||D||1|Estrella cortada seca japonés blanco
10412213|Aster cortada seca novi belgii rosado fuerte|O|O||D||1|Estrella cortada seca novi belgii rosado fuerte
10412214|Aster cortada seca novi belgii lavanda|O|O||D||1|Estrella cortada seca novi belgii lavanda
10412215|Aster cortada seca novi belgii rosado|O|O||D||1|Estrella cortada seca novi belgii rosado
10412216|Aster cortada seca novi belgii púrpura|O|O||D||1|Estrella cortada seca novi belgii púrpura
10412217|Aster cortada seca novi belgii blanco|O|O||D||1|Estrella cortada seca novi belgii blanco
10412218|Aster cortada seca solidago|O|O||D||1|Estrella cortada seca solidago
10412219|Aster cortada seca spider|O|O||D||1|Estrella cortada seca spider
10412300|Berzelia cortada seca|O|O||D||1
10412301|Berzelia lanuginosa cortada seca abrotnoides|O|O||D||1
10412302|Berzelia lanuginosa cortada seca fireball|O|O||D||1
10412303|Berzelia lanuginosa cortada seca galpinii|O|O||D||1
10412304|Berzelia lanuginosa cortada seca galpini o baubles|O|O||D||1
10412305|Berzelia lanuginosa cortada seca squarrosa|O|O||D||1
10412400|Bouvaria cortada seca|O|O||D||1|Trompetillas cortadas secas
10412401|Bouvardia cortada seca doble rosado fuerte|O|O||D||1|Trompetilla cortada seca doble rosado fuerte
10412402|Bouvardia cortada seca rosado claro|O|O||D||1|Trompetilla cortada seca rosado claro
10412403|Bouvardia cortada seca doble rosado claro|O|O||D||1|Trompetilla cortada seca doble rosado claro
10412404|Bouvardia cortada seca roja|O|O||D||1|Trompetilla cortada seca roja
10412405|Bouvardia cortada seca blanca|O|O||D||1|Trompetilla cortada seca blanca
10412500|Brodiaea cortada seca|O|O||D||1
10412501|Brodiaea cortada seca congesta|O|O||D||1
10412502|Brodiaea cortada seca congesta lavanda|O|O||D||1
10412503|Brodiaea cortada seca jacinta|O|O||D||1
10412504|Brodiaea cortada seca ida maija|O|O||D||1
10412505|Brodiaea cortada seca starlight|O|O||D||1
10412600|Calla cortada seca|O|O||D||1|Alcatraces cortados secos
10412601|Calla cortada seca green goddess|O|O||D||1|Alcatraz cortado seco green goddess
10412602|Calla cortada seca ramillete albertville|O|O||D||1|Alcatraz cortado seco ramillete albertville
10412603|Calla cortada seca ramillete aranal|O|O||D||1|Alcatraz cortado seco ramillete aranal
10412604|Calla cortada seca ramillete black eyed beauty|O|O||D||1|Alcatraz cortado seco ramillete black eyed beauty
10412605|Calla cortada seca black star|O|O||D||1|Alcatraz cortado seco black star
10412606|Calla cortada seca brisbane|O|O||D||1|Alcatraz cortado seco brisbane
10412607|Calla cortada seca crystal blush|O|O||D||1|Alcatraz cortado seco crystal blush
10412608|Calla cortada seca crystal pink|O|O||D||1|Alcatraz cortado seco crystal pink
10412609|Calla cortada seca crystal white|O|O||D||1|Alcatraz cortado seco crystal white
10412610|Calla cortada seca dark captain romanc|O|O||D||1|Alcatraz cortado seco dark captain romance
10412611|Calla cortada seca ramillete dark mozart|O|O||D||1|Alcatraz cortado seco ramillete dark mozart
10412612|Calla cortada seca ramillete dark naomi|O|O||D||1|Alcatraz cortado seco ramillete dark naomi
10412613|Calla cortada seca ramillete deformed calla|O|O||D||1|Alcatraz cortado seco ramillete deformed calla
10412614|Calla cortada seca ramillete dordogne|O|O||D||1|Alcatraz cortado seco ramillete dordogne
10412615|Calla cortada seca ramillete etude|O|O||D||1|Alcatraz cortado seco ramillete etude
10412616|Calla cortada seca ramillete farao|O|O||D||1|Alcatraz cortado seco ramillete farao
10412617|Calla cortada seca ramillete fire glow|O|O||D||1|Alcatraz cortado seco ramillete fire glow
10412618|Calla cortada seca ramillete florex gold|O|O||D||1|Alcatraz cortado seco ramillete florex gold
10412619|Calla cortada seca ramillete garnet glow|O|O||D||1|Alcatraz cortado seco ramillete garnet glow
10412620|Calla cortada seca ramillete hot chocolate|O|O||D||1|Alcatraz cortado seco ramillete hot chocolate
10412621|Calla cortada seca ramillete lavender improved|O|O||D||1|Alcatraz cortado seco ramillete lavender improved
10412622|Calla cortada seca ramillete light cromance|O|O||D||1|Alcatraz cortado seco ramillete light cromance
10412623|Calla cortada seca ramillete little suzy|O|O||D||1|Alcatraz cortado seco ramillete little suzy
10412624|Calla cortada seca ramillete majestic red|O|O||D||1|Alcatraz cortado seco ramillete majestic red
10412625|Calla cortada seca ramillete mango|O|O||D||1|Alcatraz cortado seco ramillete mango
10412626|Calla cortada seca ramillete merlot|O|O||D||1|Alcatraz cortado seco ramillete merlot
10412627|Calla cortada seca ramillete mozart|O|O||D||1|Alcatraz cortado seco ramillete mozart
10412628|Calla cortada seca ramillete naomi|O|O||D||1|Alcatraz cortado seco ramillete naomi
10412629|Calla cortada seca ramillete night cap|O|O||D||1|Alcatraz cortado seco ramillete night cap
10412630|Calla cortada seca ramillete odessa|O|O||D||1|Alcatraz cortado seco ramillete odessa
10412631|Calla cortada seca ramillete pacific pink|O|O||D||1|Alcatraz cortado seco ramillete pacific pink
10412632|Calla cortada seca ramillete passion fruit|O|O||D||1|Alcatraz cortado seco ramillete passion fruit
10412633|Calla cortada seca ramillete picasso|O|O||D||1|Alcatraz cortado seco ramillete picasso
10412634|Calla cortada seca ramillete pillow talk|O|O||D||1|Alcatraz cortado seco ramillete pillow talk
10412635|Calla cortada seca ramillete pink persuation|O|O||D||1|Alcatraz cortado seco ramillete pink persuation
10412636|Calla cortada seca ramillete pisa|O|O||D||1|Alcatraz cortado seco ramillete pisa
10412637|Calla cortada seca ramillete pot of|O|O||D||1|Alcatraz cortado seco ramillete pot of
10412638|Calla cortada seca ramillete red sox|O|O||D||1|Alcatraz cortado seco ramillete red sox
10412639|Calla cortada seca ramillete rosa|O|O||D||1|Alcatraz cortado seco ramillete rosa
10412640|Calla cortada seca ramillete ruby light rose|O|O||D||1|Alcatraz cortado seco ramillete ruby light rose
10412641|Calla cortada seca ramillete samur|O|O||D||1|Alcatraz cortado seco ramillete samur
10412642|Calla cortada seca ramillete sapporo|O|O||D||1|Alcatraz cortado seco ramillete sapporo
10412643|Calla cortada seca ramillete schwarzwalder|O|O||D||1|Alcatraz cortado seco ramillete schwarzwalder
10412644|Calla cortada seca ramillete serrada|O|O||D||1|Alcatraz cortado seco ramillete serrada
10412645|Calla cortada seca ramillete solemio|O|O||D||1|Alcatraz cortado seco ramillete solemio
10412646|Calla cortada seca ramillete sunrise|O|O||D||1|Alcatraz cortado seco ramillete sunrise
10412647|Calla cortada seca ramillete super mac|O|O||D||1|Alcatraz cortado seco ramillete super mac
10412648|Calla cortada seca ramillete swan lake|O|O||D||1|Alcatraz cortado seco ramillete swan lake
10412649|Calla cortada seca ramillete vermeer|O|O||D||1|Alcatraz cortado seco ramillete vermeer
10412650|Calla cortada seca ramillete white butterfly|O|O||D||1|Alcatraz cortado seco ramillete white butterfly
10412651|Calla cortada seca ramillete amarilla|O|O||D||1|Alcatraz cortado seco ramillete amarilla
10412652|Calla cortada seca ramillete yellow mozart|O|O||D||1|Alcatraz cortado seco ramillete yellow mozart
10412653|Calla cortada seca ramillete white large|O|O||D||1|Alcatraz cortado seco ramillete white large
10412800|Celosia cortada seca|O|O||D||1|Flores de terciopelo cortadas secas
10412801|Cresta de gallo (celosia) cortada seca verde|O|O||D||1|Flor de terciopelo cortada seca verde
10412802|Cresta de gallo (celosia) cortada seca anaranjado|O|O||D||1|Flor de terciopelo cortada seca anaranjado
10412803|Cresta de gallo (celosia) cortada seca rosado|O|O||D||1|Flor de terciopelo cortada seca rosado
10412804|Cresta de gallo (celosia) cortada seca púrpura|O|O||D||1|Flor de terciopelo cortada seca púrpura
10412805|Cresta de gallo (celosia) cortada seca rojo|O|O||D||1|Flor de terciopelo cortada seca rojo
10412806|Cresta de gallo (celosia) cortada seca amarillo|O|O||D||1|Flor de terciopelo cortada seca amarillo
10412807|Cresta de gallo (celosia) cortada seca plume light|O|O||D||1|Flor de terciopelo cortada seca plume light
10412808|Cresta de gallo (celosia) cortada seca plume orange|O|O||D||1|Flor de terciopelo cortada seca plume orange
10412809|Cresta de gallo (celosia) cortada seca plume purple|O|O||D||1|Flor de terciopelo cortada seca plume purple
10412810|Cresta de gallo (celosia) cortada seca plume red|O|O||D||1|Flor de terciopelo cortada seca plume red
10412811|Cresta de gallo (celosia) cortada seca plume yellow|O|O||D||1|Flor de terciopelo cortada seca plume yellow
10412812|Cresta de gallo (celosia) cortada seca wheat pink|O|O||D||1|Flor de terciopelo cortada seca wheat pink
10412813|Cresta de gallo (celosia) cortada seca wheat yellow|O|O||D||1|Flor de terciopelo cortada seca wheat yellow
10412900|Narciso cortado seco|O|O||D||1
10412901|Narciso cortado seco dick wilden|O|O||D||1
10412902|Narciso cortado seco dutch master|O|O||D||1
10412903|Narciso cortado seco ice follies|O|O||D||1
10412904|Narciso cortado seco ice king|O|O||D||1
10412905|Narciso cortado seco johan strauss|O|O||D||1
10412906|Narciso cortado seco yellow carlton|O|O||D||1
10413000|Dalia cortada seca|O|O||D||1
10413001|Dalia cortada seca bicolor|O|O||D||1
10413002|Dalia cortada seca rosado fuerte|O|O||D||1
10413003|Dalia cortada seca rosado claro|O|O||D||1
10413004|Dalia cortada seca rosado medio|O|O||D||1
10413005|Dalia cortada seca anaranjado|O|O||D||1
10413006|Dalia cortada seca durazno|O|O||D||1
10413007|Dalia cortada seca púrpura|O|O||D||1
10413008|Dalia cortada seca roja|O|O||D||1
10413009|Dalia cortada seca blanca|O|O||D||1
10413010|Dalia cortada seca amarilla|O|O||D||1
10413100|Delphinium cortado seco|O|O||D||1
10413101|Delphinium cortado seco bella azul oscuro|O|O||D||1
10413102|Delphinium cortado seco bella azul claro|O|O||D||1
10413103|Delphinium cortado seco bella blanco|O|O||D||1
10413104|Delphinium cortado seco azul sombra|O|O||D||1
10413105|Delphinium cortado seco híbrido azul oscuro|O|O||D||1
10413106|Delphinium cortado seco híbrido azul claro|O|O||D||1
10413107|Delphinium cortado seco híbrido malva|O|O||D||1
10413108|Delphinium cortado seco híbrido rosado|O|O||D||1
10413109|Delphinium cortado seco híbrido púrpura|O|O||D||1
10413110|Delphinium cortado seco híbrido rojo|O|O||D||1
10413111|Delphinium cortado seco híbrido blanco|O|O||D||1
10413112|Delphinium cortado seco princesa carolina|O|O||D||1
10413113|Delphinium cortado seco volkerfrieden|O|O||D||1
10413200|Clavel (dianthus) cortado seco|O|O||D||1|Clavelinas cortadas secas
10413201|Clavel (dianthus) cortado seco chocolate|O|O||D||1|Clavelina cortada seca chocolate
10413202|Clavel (dianthus) cortado seco fucsia|O|O||D||1|Clavelina cortada seca fucsia
10413203|Clavel (dianthus) cortado seco bola verde|O|O||D||1|Clavelina cortada seca bola verde
10413204|Clavel (dianthus) cortado seco rosado fuerte|O|O||D||1|Clavelina cortada seca rosado fuerte
10413205|Clavel (dianthus) cortado seco lavanda|O|O||D||1|Clavelina cortada seca lavanda
10413206|Clavel (dianthus) cortado seco frambuesa|O|O||D||1|Clavelina cortada seca frambuesa
10413207|Clavel (dianthus) cortado seco rojo|O|O||D||1|Clavelina cortada seca rojo
10413208|Clavel (dianthus) cortado seco rosado|O|O||D||1|Clavelina cortada seca rosado
10413300|Eremruses cortadas secas|O|O||D||1
10413301|Eremurus cortado seco deruyter híbrido|O|O||D||1
10413302|Eremurus cortado seco himalaicus blanco|O|O||D||1
10413303|Eremurus cortado seco anaranjado|O|O||D||1
10413304|Eremurus cortado seco durazno|O|O||D||1
10413305|Eremurus cortado seco amarillo|O|O||D||1
10413400|Brezo (erica) cortada seca|O|O||D||1|Brecinas cortadas secas
10413401|Brezo (erica) cortado seco campunalarus|O|O||D||1|Brecina cortada seca campunalarus
10413402|Brezo (erica) cortado seco conica|O|O||D||1|Brecina cortada seca cónica
10413403|Brezo (erica) cortado seco green ice|O|O||D||1|Brecina cortada seca green ice
10413404|Brezo (erica) cortado seco rosado|O|O||D||1|Brecina cortada seca rosado
10413405|Brezo (erica) cortado seco príncipe de gales|O|O||D||1|Brecina cortada seca príncipe de gales
10413500|Euphorbia cortada seca|O|O||D||1|Coronas de Cristo cortadas secas
10413501|Euphorbia cortada seca characias|O|O||D||1|Corona de Cristo cortada seca characias
10413502|Euphorbia cortada seca griffithii fireglow|O|O||D||1|Corona de Cristo cortada seca griffithii fireglow
10413503|Euphorbia cortada seca martini|O|O||D||1|Corona de Cristo cortada seca martini
10413504|Euphorbia cortada seca anaranjada|O|O||D||1|Corona de Cristo cortada seca anaranjada
10413505|Euphorbia cortada seca durazno|O|O||D||1|Corona de Cristo cortada seca durazno
10413506|Euphorbia cortada seca rosada|O|O||D||1|Corona de Cristo cortada seca rosada
10413507|Euphorbia cortada seca roja|O|O||D||1|Corona de Cristo cortada seca roja
10413508|Euphorbia cortada seca blanca|O|O||D||1|Corona de Cristo cortada seca blanca
10413509|Euphorbia cortada seca amarilla|O|O||D||1|Corona de Cristo cortada seca amarilla
10413510|Euphorbia cortada seca amarilla spurge|O|O||D||1|Corona de Cristo cortada seca amarilla spurge
10413600|Fresia cortada seca|O|O||D||1|Freesias cortadas secas
10413601|Fresia cortada seca crema|O|O||D||1|Freesia cortada seca crema
10413602|Fresia cortada seca doble blanca|O|O||D||1|Freesia cortada seca doble blanca
10413603|Fresia cortada seca doble amarilla|O|O||D||1|Freesia cortada seca doble amarilla
10413604|Fresia cortada seca rosado fuerte|O|O||D||1|Freesia cortada seca rosado fuerte
10413605|Fresia cortada seca lady brunet|O|O||D||1|Freesia cortada seca lady brunet
10413606|Fresia cortada seca lavanda|O|O||D||1|Freesia cortada seca lavanda
10413607|Fresia cortada seca rosado medio|O|O||D||1|Freesia cortada seca rosado medio
10413608|Fresia cortada seca anaranjado|O|O||D||1|Freesia cortada seca anaranjado
10413609|Fresia cortada seca pimpinela|O|O||D||1|Freesia cortada seca pimpinela
10413610|Fresia cortada seca rosada|O|O||D||1|Freesia cortada seca rosada
10413611|Fresia cortada seca pùrpura|O|O||D||1|Freesia cortada seca púrpura
10413612|Fresia cortada seca roja|O|O||D||1|Freesia cortada seca roja
10413613|Fresia cortada seca blanca|O|O||D||1|Freesia cortada seca blanca
10413614|Fresia cortada seca amarilla|O|O||D||1|Freesia cortada seca amarilla
10413700|Ajedrezada cortada seca|O|O||D||1
10413701|Ajedrezada cortada seca acmopelata|O|O||D||1
10413702|Ajedrezada cortada seca assyriaca|O|O||D||1
10413703|Ajedrezada cortada seca assyriaca uva vulpis|O|O||D||1
10413704|Ajedrezada cortada seca elysee|O|O||D||1
10413705|Ajedrezada cortada seca imperialis anaranjada|O|O||D||1
10413706|Ajedrezada cortada seca imperialis amarilla|O|O||D||1
10413707|Ajedrezada cortada seca meleagris|O|O||D||1
10413708|Ajedrezada cortada seca michailowski|O|O||D||1
10413709|Ajedrezada cortada seca uva vulpis|O|O||D||1
10413800|Hiniesta cortada seca|O|O||D||1
10413801|Hiniesta cortada seca verde|O|O||D||1
10413802|Hiniesta cortada seca rosado fuerte|O|O||D||1
10413803|Hiniesta cortada seca lavanda|O|O||D||1
10413804|Hiniesta cortada seca rosado claro|O|O||D||1
10413805|Hiniesta cortada seca durazno|O|O||D||1
10413806|Hiniesta cortada seca púrpura|O|O||D||1
10413807|Hiniesta cortada seca blanco|O|O||D||1
10413808|Hiniesta cortada seca amarillo|O|O||D||1
10413900|Margarita cortada seca|O|O||D||1|Gerberas cortadas secas
10413901|Margarita cortada seca crema de centro negro|O|O||D||1|Gerbera cortada seca crema de centro negro
10413902|Margarita cortada seca crema|O|O||D||1|Gerbera cortada seca crema
10413903|Margarita cortada seca dorada|O|O||D||1|Gerbera cortada seca dorada
10413904|Margarita cortada seca rosado fuerte|O|O||D||1|Gerbera cortada seca rosado fuerte
10413905|Margarita cortada seca rosado claro|O|O||D||1|Gerbera cortada seca rosado claro
10413906|Margarita cortada seca magenta|O|O||D||1|Gerbera cortada seca magenta
10413907|Margarita cortada seca mini coral|O|O||D||1|Gerbera cortada seca mini coral
10413908|Margarita cortada seca mini fucsia|O|O||D||1|Gerbera cortada seca mini fucsia
10413909|Margarita cortada seca mini rosado fuerte|O|O||D||1|Gerbera cortada seca mini rosado fuerte
10413910|Margarita cortada seca mini anaranjado claro de centro negro|O|O||D||1|Gerbera cortada seca mini anaranjado claro de centro negro
10413911|Margarita cortada seca mini anaranjado de centro negro|O|O||D||1|Gerbera cortada seca mini anaranjado de centro negro
10413912|Margarita cortada seca mini anaranjado|O|O||D||1|Gerbera cortada seca mini anaranjado
10413913|Margarita cortada seca mini rojo de centro negro|O|O||D||1|Gerbera cortada seca mini rojo de centro negro
10413914|Margarita cortada seca mini blanco|O|O||D||1|Gerbera cortada seca mini blanco
10413915|Margarita cortada seca mini amarillo claro de centro negro|O|O||D||1|Gerbera cortada seca mini amarillo claro de centro negro
10413916|Margarita cortada seca anaranjado de centro negro|O|O||D||1|Gerbera cortada seca anaranjado de centro negro
10413917|Margarita cortada seca anaranjada|O|O||D||1|Gerbera cortada seca anaranjada
10413918|Margarita cortada seca durazno de centro negro|O|O||D||1|Gerbera cortada seca durazno de centro negro
10413919|Margarita cortada seca durazno|O|O||D||1|Gerbera cortada seca durazno
10413920|Margarita cortada seca rosada de centro negro|O|O||D||1|Gerbera cortada seca rosada de centro negro
10413921|Margarita cortada seca rosada|O|O||D||1|Gerbera cortada seca rosada
10413922|Margarita cortada seca roja de centro negro|O|O||D||1|Gerbera cortada seca roja de centro negro
10413923|Margarita cortada seca roja|O|O||D||1|Gerbera cortada seca roja
10413924|Margarita cortada seca spider durazno|O|O||D||1|Gerbera cortada seca spider durazno
10413925|Margarita cortada seca spider roja|O|O||D||1|Gerbera cortada seca spider roja
10413926|Margarita cortada seca terracota|O|O||D||1|Gerbera cortada seca terracota
10413927|Margarita cortada seca blanca de centro negro|O|O||D||1|Gerbera cortada seca blanca de centro negro
10413928|Margarita cortada seca blanca|O|O||D||1|Gerbera cortada seca blanca
10413929|Margarita cortada seca amarilla|O|O||D||1|Gerbera cortada seca amarilla
10414000|Jengibre cortado seco|O|O||D||1|Flores de jengibre cortadas secas
10414001|Jengibre cortado seco  indonesio|O|O||D||1|Flor de jengibre cortada seca indonesio
10414002|Jengibre cortado seco jungle king rosado|O|O||D||1|Flor de jengibre cortada seca jungle king rosado
10414003|Jengibre cortado seco jungle king rojo|O|O||D||1|Flor de jengibre cortada seca jungle king rojo
10414004|Jengibre cortado seco rosado|O|O||D||1|Flor de jengibre cortada seca rosado
10414005|Jengibre cortado seco rojo|O|O||D||1|Flor de jengibre cortada seca rojo
10414006|Jengibre cortado seco torch|O|O||D||1|Flor de jengibre cortada seca torch
10414100|Gladiolo cortado seco|O|O||D||1|Gladiolas cortadas secas
10414101|Gladiolo cortado seco burgundy|O|O||D||1|Gladiola cortado seco burgundy
10414102|Gladiolo cortado seco fucsia|O|O||D||1|Gladiola cortado seco fucsia
10414103|Gladiolo cortado seco verde|O|O||D||1|Gladiola cortado seco verde
10414104|Gladiolo cortado seco rosado fuerte|O|O||D||1|Gladiola cortado seco rosado fuerte
10414105|Gladiolo cortado seco rosado claro|O|O||D||1|Gladiola cortado seco rosado claro
10414106|Gladiolo cortado seco anaranjado|O|O||D||1|Gladiola cortado seco anaranjado
10414107|Gladiolo cortado seco durazno|O|O||D||1|Gladiola cortado seco durazno
10414108|Gladiolo cortado seco rosado medio|O|O||D||1|Gladiola cortado seco rosado medio
10414109|Gladiolo cortado seco púrpura|O|O||D||1|Gladiola cortado seco púrpura
10414110|Gladiolo cortado seco rojo bi – color|O|O||D||1|Gladiola cortado seco rojo bi - color
10414111|Gladiolo cortado seco rojo|O|O||D||1|Gladiola cortado seco rojo
10414112|Gladiolo cortado seco salmón|O|O||D||1|Gladiola cortado seco salmón
10414113|Gladiolo cortado seco blanco|O|O||D||1|Gladiola cortado seco blanco
10414114|Gladiolo cortado seco amarillo|O|O||D||1|Gladiola cortado seco amarillo
10414200|Godetia cortada seca|O|O||D||1
10414201|Godetia cortada seca bicolor|O|O||D||1
10414202|Godetia cortada seca fucsia|O|O||D||1
10414203|Godetia cortada seca rosado fuerte|O|O||D||1
10414204|Godetia cortada seca anaranjada|O|O||D||1
10414205|Godetia cortada seca roja|O|O||D||1
10414206|Godetia cortada seca blanca|O|O||D||1
10414300|Bromelia cortada seca|O|O||D||1
10414301|Bromelia lingulata cortada seca anaranjada|O|O||D||1
10414302|Bromelia lingulata cortada seca roja|O|O||D||1
10414303|Bromelia lingulata cortada seca blanca|O|O||D||1
10414304|Bromelia lingulata cortada seca amarilla|O|O||D||1
10414305|Bromelia variegata cortada seca|O|O||D||1
10414400|Gypsophilia cortada seca|O|O||D||1|Nubes cortadas secas
10414401|Gypsophilia cortada seca bambino|O|O||D||1|Nube cortada seca bambino
10414402|Gypsophilia cortada seca million stars|O|O||D||1|Nube cortada seca million stars
10414403|Gypsophilia cortada seca mirabella|O|O||D||1|Nube cortada seca mirabella
10414404|Gypsophilia cortada seca new love|O|O||D||1|Nube cortada seca new love
10414405|Gypsophilia cortada seca orión|O|O||D||1|Nube cortada seca orión
10414406|Gypsophilia cortada seca perfecta|O|O||D||1|Nube cortada seca perfecta
10414500|Brezo cortado seco|O|O||D||1|Biércol cortado seco
10414501|Brezo cortado seco augustine|O|O||D||1|Biércol cortado seco augustine
10414502|Brezo cortado seco érica cuatro hermanas|O|O||D||1|Biércol cortado seco érica cuatro hermanas
10414503|Brezo cortado seco francés|O|O||D||1|Biércol cortado seco francés
10414504|Brezo cortado seco verde|O|O||D||1|Biércol cortado seco verde
10414505|Brezo cortado seco sterling range blanco|O|O||D||1|Biércol cortado seco sterling range blanco
10414506|Brezo cortado seco rosado sunset|O|O||D||1|Biércol cortado seco rosado sunset
10414507|Brezo cortado seco blanco|O|O||D||1|Biércol cortado seco blanco
10414600|Heliconia cortada seca|O|O||D||1|Pinzas de langosta cortadas secas
10414601|Heliconia cortada seca bihai claw|O|O||D||1|Pinza de langosta cortada seca bihai claw
10414602|Heliconia cortada seca bihai flash|O|O||D||1|Pinza de langosta cortada seca bihai flash
10414603|Heliconia cortada seca bihai lobster claw|O|O||D||1|Pinza de langosta cortada seca bihai lobster claw
10414604|Heliconia cortada seca caribea red|O|O||D||1|Pinza de langosta cortada seca caribea red
10414605|Heliconia cortada seca caribea yellow|O|O||D||1|Pinza de langosta cortada seca caribea yellow
10414606|Heliconia cortada seca christmas|O|O||D||1|Pinza de langosta cortada seca christmas
10414607|Heliconia cortada seca edge of night|O|O||D||1|Pinza de langosta cortada seca edge of night
10414608|Heliconia cortada seca green bihai|O|O||D||1|Pinza de langosta cortada seca green bihai
10414609|Heliconia cortada seca marginata lutea|O|O||D||1|Pinza de langosta cortada seca marginata lútea
10414610|Heliconia cortada seca psitt fire opal|O|O||D||1|Pinza de langosta cortada seca psitt fire opal
10414611|Heliconia cortada seca psittacorum|O|O||D||1|Pinza de langosta cortada seca psittacorum
10414612|Heliconia cortada seca richmond red|O|O||D||1|Pinza de langosta cortada seca richmond red
10414613|Heliconia cortada seca rostrata|O|O||D||1|Pinza de langosta cortada seca rostrata
10414614|Heliconia cortada seca sexy pink|O|O||D||1|Pinza de langosta cortada seca sexy pink
10414615|Heliconia cortada seca sexy scarlett|O|O||D||1|Pinza de langosta cortada seca sexy scarlett
10414616|Heliconia cortada seca shogun|O|O||D||1|Pinza de langosta cortada seca shogun
10414617|Heliconia cortada seca small red|O|O||D||1|Pinza de langosta cortada seca small red
10414618|Heliconia cortada seca southern cross|O|O||D||1|Pinza de langosta cortada seca southern cross
10414619|Heliconia cortada seca wagneriana|O|O||D||1|Pinza de langosta cortada seca wagneriana
10414700|Jacinto cortado seco|O|O||D||1
10414701|Jacinto cortado seco bean|O|O||D||1
10414702|Jacinto cortado seco durazno|O|O||D||1
10414703|Jacinto cortado seco azul|O|O||D||1
10414704|Jacinto cortado seco fucsia|O|O||D||1
10414705|Jacinto cortado seco rosado fuerte|O|O||D||1
10414706|Jacinto cortado seco lavanda|O|O||D||1
10414707|Jacinto cortado seco azul claro|O|O||D||1
10414708|Jacinto cortado seco rosado medio|O|O||D||1
10414709|Jacinto cortado seco rosado|O|O||D||1
10414710|Jacinto cortado seco estrella púrpura|O|O||D||1
10414711|Jacinto cortado seco blanco|O|O||D||1
10414712|Jacinto cortado seco amarillo|O|O||D||1
10414800|Hydrangea cortada seca|O|O||D||1|Hortensias cortadas secas
10414801|Hydrangea cortada seca anabella|O|O||D||1|Hortensia cortada seca anabella
10414802|Hydrangea cortada seca azul antiguo|O|O||D||1|Hortensia cortada seca azul antiguo
10414803|Hydrangea cortada seca azul antiguo  o verde o nueva zelandia|O|O||D||1|Hortensia cortada seca azul antiguo o verde o nueva zelandia
10414804|Hydrangea cortada seca verde antiguo|O|O||D||1|Hortensia cortada seca verde antiguo
10414805|Hydrangea cortada seca rosado antiguo|O|O||D||1|Hortensia cortada seca rosado antiguo
10414806|Hydrangea cortada seca púrpura antiguo o nueva zelandia|O|O||D||1|Hortensia cortada seca púrpura antiguo o nueva zelandia
10414807|Hydrangea cortada seca aubergene o nueva zelandia|O|O||D||1|Hortensia cortada seca aubergene o nueva zelandia
10414808|Hydrangea cortada seca azul oscuro|O|O||D||1|Hortensia cortada seca azul oscuro
10414809|Hydrangea cortada seca rosado oscuro|O|O||D||1|Hortensia cortada seca rosado oscuro
10414810|Hydrangea cortada seca púrpura oscuro|O|O||D||1|Hortensia cortada seca púrpura oscuro
10414811|Hydrangea cortada seca berenjena|O|O||D||1|Hortensia cortada seca berenjena
10414812|Hydrangea cortada seca verde teñida|O|O||D||1|Hortensia cortada seca verde teñida
10414813|Hydrangea cortada seca limón verde|O|O||D||1|Hortensia cortada seca limón verde
10414814|Hydrangea cortada seca rosado fuerte|O|O||D||1|Hortensia cortada seca rosado fuerte
10414815|Hydrangea cortada seca jumbo blanca|O|O||D||1|Hortensia cortada seca jumbo blanca
10414816|Hydrangea cortada seca lavanda o nueva zelandia|O|O||D||1|Hortensia cortada seca lavanda o nueva zelandia
10414817|Hydrangea cortada seca azul claro|O|O||D||1|Hortensia cortada seca azul claro
10414818|Hydrangea cortada seca rosado claro grande|O|O||D||1|Hortensia cortada seca rosado claro grande
10414819|Hydrangea cortada seca verde lima grande|O|O||D||1|Hortensia cortada seca verde lima grande
10414820|Hydrangea cortada seca mini verde|O|O||D||1|Hortensia cortada seca mini verde
10414821|Hydrangea cortada seca oakleaf|O|O||D||1|Hortensia cortada seca oakleaf
10414822|Hydrangea cortada seca oakleaf copo de nieve|O|O||D||1|Hortensia cortada seca oakleaf copo de nieve
10414823|Hydrangea cortada seca rosado teñido|O|O||D||1|Hortensia cortada seca rosado teñido
10414824|Hydrangea cortada seca rosado|O|O||D||1|Hortensia cortada seca rosado
10414825|Hydrangea cortada seca púrpura o nueva zelandia|O|O||D||1|Hortensia cortada seca púrpura o nueva zelandia
10414826|Hydrangea cortada seca rojo teñido|O|O||D||1|Hortensia cortada seca rojo teñido
10414827|Hydrangea cortada seca shocking blue|O|O||D||1|Hortensia cortada seca shocking blue
10414828|Hydrangea cortada seca tardiva|O|O||D||1|Hortensia cortada seca tardiva
10414829|Hydrangea cortada seca blanca|O|O||D||1|Hortensia cortada seca blanca
10414900|Iris cortada seca|O|O||D||1
10414901|Iris cortada seca negra barbada|O|O||D||1
10414902|Iris cortada seca azul barbada|O|O||D||1
10414903|Iris cortada seca lavanda barbada|O|O||D||1
10414904|Iris cortada seca barbada azul clara|O|O||D||1
10414905|Iris cortada seca barbada púrpura|O|O||D||1
10414906|Iris cortada seca barbada roja|O|O||D||1
10414907|Iris cortada seca barbada blanca|O|O||D||1
10414908|Iris cortada seca baerbada blanca y púrpura|O|O||D||1
10414909|Iris cortada seca amarilla barbada|O|O||D||1
10414910|Iris cortada seca blue elegance|O|O||D||1
10414911|Iris cortada seca casablanca|O|O||D||1
10414912|Iris cortada seca golden beau|O|O||D||1
10414913|Iris cortada seca hildegard|O|O||D||1
10414914|Iris cortada seca hong kong|O|O||D||1
10414915|Iris cortada seca ideal|O|O||D||1
10414916|Iris cortada seca professor blue|O|O||D||1
10414917|Iris cortada seca purple|O|O||D||1
10414918|Iris cortada seca spuria|O|O||D||1
10414919|Iris cortada seca telstar|O|O||D||1
10415000|Pata de canguro cortada seca|O|O||D||1
10415001|Pata de canguro cortada seca bicolor|O|O||D||1
10415002|Pata de canguro cortada seca negra|O|O||D||1
10415003|Pata de canguro cortada seca verde|O|O||D||1
10415004|Pata de canguro cortada seca anaranjada|O|O||D||1
10415005|Pata de canguro cortada seca rosada|O|O||D||1
10415006|Pata de canguro cortada seca roja|O|O||D||1
10415007|Pata de canguro cortada seca amarilla|O|O||D||1
10415100|Delfinio cortado seco|O|O||D||1|Delphinium (larkspurs) cortados secos
10415101|Delfinio cortada seca azul nube|O|O||D||1|Delphinium (larkspurs) cortado seco azul nube
10415102|Delfinio cortada seca rosado fuerte|O|O||D||1|Delphinium (larkspurs) cortado seco rosado fuerte
10415103|Delfinio cortada seca lavanda|O|O||D||1|Delphinium (larkspurs) cortado seco lavanda
10415104|Delfinio cortada seca rosado claro|O|O||D||1|Delphinium (larkspurs) cortado seco rosado claro
10415105|Delfinio cortada seca púrpura|O|O||D||1|Delphinium (larkspurs) cortado seco púrpura
10415106|Delfinio cortada seca blanca|O|O||D||1|Delphinium (larkspurs) cortado seco blanca
10415200|Lepto cortado seco|O|O||D||1
10415201|Lepto cortado seco azul o floreciente|O|O||D||1
10415202|Lepto cortado seco rosado fuerte|O|O||D||1
10415203|Lepto cortado seco rosado claro|O|O||D||1
10415204|Lepto cortado seco rosado|O|O||D||1
10415205|Lepto cortado seco rojo|O|O||D||1
10415206|Lepto cortado seco blanco|O|O||D||1
10415300|Lila cortada seca|O|O||D||1
10415301|Lila  cortada seca híbrida francesa lavanda|O|O||D||1
10415302|Lila  cortada seca híbrida francesa púrpura|O|O||D||1
10415303|Lila  cortada seca púrpura|O|O||D||1
10415304|Lila  cortada seca vino|O|O||D||1
10415305|Lila  cortada seca blanca|O|O||D||1
10415306|Lila  cortada seca blanca salvaje|O|O||D||1
10415400|Azucena cortada seca|O|O||D||1|Lilis cortadas secas
10415401|Azucena cortada seca alteza longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca alteza longiflorum e híbrido asiática
10415402|Azucena cortada seca black out|O|O||D||1|Lili cortada seca black out
10415403|Azucena cortada seca rosado oscuro|O|O||D||1|Lili cortada seca rosado oscuro
10415404|Azucena cortada seca leéctrica asiática|O|O||D||1|Lili cortada seca eléctrica asiática
10415405|Azucena cortada seca festival asiática|O|O||D||1|Lili cortada seca festival asiática
10415406|Azucena cortada seca ginebra asiática|O|O||D||1|Lili cortada seca ginebra asiática
10415407|Azucena cortada seca rosado claro asiática|O|O||D||1|Lili cortada seca rosado claro asiática
10415408|Azucena cortada seca colombina asiática|O|O||D||1|Lili cortada seca colombina asiática
10415409|Azucena cortada seca miss américa púrpura asiática|O|O||D||1|Lili cortada seca miss américa púrpura asiática
10415410|Azucena cortada seca monte negro asiática|O|O||D||1|Lili cortada seca monte negro asiática
10415411|Azucena cortada seca anaranjada asiática|O|O||D||1|Lili cortada seca anaranjada asiática
10415412|Azucena cortada seca durazno cannes asiática|O|O||D||1|Lili cortada seca durazno cannes asiática
10415413|Azucena cortada seca risada asiática|O|O||D||1|Lili cortada seca risada asiática
10415414|Azucena cortada seca sancerre asiátia|O|O||D||1|Lili cortada seca sancerre asiática
10415415|Azucena cortada seca white dream asiática|O|O||D||1|Lili cortada seca white dream asiática
10415416|Azucena cortada seca amarilla asiática|O|O||D||1|Lili cortada seca amarilla asiática
10415417|Azucena cortada seca diamante brillante longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca diamante brillante longiflorum e híbrido asiática
10415418|Azucena cortada seca brindisi longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca brindisi longiflorum e híbrido asiática
10415419|Azucena cortada seca carmine longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca carmine longiflorum e híbrido asiática
10415420|Azucena cortada seca cinnabar longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca cinnabar longiflorum e híbrido asiática
10415421|Azucena cortada seca club longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca club longiflorum e híbrido asiática
10415422|Azucena cortada seca discovery longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca discovery longiflorum e híbrido asiática
10415423|Azucena cortada seca de pascua|O|O||D||1|Lili cortada seca de pascua
10415424|Azucena cortada seca isis longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca isis longiflorum e híbrido asiática
10415425|Azucena cortada seca la hybrid justice longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca la hybrid justice longiflorum e híbrido asiática
10415426|Azucena cortada seca lace longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca lace longiflorum e híbrido asiática
10415427|Azucena cortada seca lirio de los valles|O|O||D||1|Lili cortada seca lirio de los valles
10415428|Azucena cortada seca love longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca love longiflorum e híbrido asiática
10415429|Azucena cortada seca menorca longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca menorca longiflorum e híbrido asiática
10415430|Azucena cortada seca oriental acapulco|O|O||D||1|Lili cortada seca oriental acapulco
10415431|Azucena cortada seca oriental albion|O|O||D||1|Lili cortada seca oriental albión
10415432|Azucena cortada seca oriental argentina|O|O||D||1|Lili cortada seca oriental argentina
10415433|Azucena cortada seca oriental auratum|O|O||D||1|Lili cortada seca oriental auratum
10415434|Azucena cortada seca oriental barbaresco|O|O||D||1|Lili cortada seca oriental barbaresco
10415435|Azucena cortada seca oriental bernini|O|O||D||1|Lili cortada seca oriental bernini
10415436|Azucena cortada seca oriental beseno|O|O||D||1|Lili cortada seca oriental beseno
10415437|Azucena cortada seca oriental broadway|O|O||D||1|Lili cortada seca oriental broadway
10415438|Azucena cortada seca oriental canada|O|O||D||1|Lili cortada seca oriental canadá
10415439|Azucena cortada seca oriental casablanca|O|O||D||1|Lili cortada seca oriental casablanca
10415440|Azucena cortada seca oriental chili|O|O||D||1|Lili cortada seca oriental chili
10415441|Azucena cortada seca oriental chrystal|O|O||D||1|Lili cortada seca oriental chrystal
10415442|Azucena cortada seca oriental cobra|O|O||D||1|Lili cortada seca oriental cobra
10415443|Azucena cortada seca oriental conca d’ or|O|O||D||1|Lili cortada seca oriental conca d' ivor
10415444|Azucena cortada seca oriental cote d’ ivor|O|O||D||1|Lili cortada seca oriental cote d' ivor
10415445|Azucena cortada seca oriental dizzy|O|O||D||1|Lili cortada seca oriental dizzy
10415446|Azucena cortada seca oriental fireball|O|O||D||1|Lili cortada seca oriental fireball
10415447|Azucena cortada seca oriental gluhwein|O|O||D||1|Lili cortada seca oriental gluhwein
10415448|Azucena cortada seca oriental goldband|O|O||D||1|Lili cortada seca oriental goldband
10415449|Azucena cortada seca oriental halifax|O|O||D||1|Lili cortada seca oriental halifax
10415450|Azucena cortada seca oriental kathryn|O|O||D||1|Lili cortada seca oriental kathryn
10415451|Azucena cortada seca oriental kyoto|O|O||D||1|Lili cortada seca oriental kyoto
10415452|Azucena cortada seca oriental la mancha|O|O||D||1|Lili cortada seca oriental la mancha
10415453|Azucena cortada seca oriental medusa|O|O||D||1|Lili cortada seca oriental medusa
10415454|Azucena cortada seca oriental montezuma|O|O||D||1|Lili cortada seca oriental montezuma
10415455|Azucena cortada seca oriental muscadet|O|O||D||1|Lili cortada seca oriental muscadet
10415456|Azucena cortada seca oriental nippon|O|O||D||1|Lili cortada seca oriental nippon
10415457|Azucena cortada seca oriental opus one|O|O||D||1|Lili cortada seca oriental opus one
10415458|Azucena cortada seca oriental pompeii|O|O||D||1|Lili cortada seca oriental pompeii
10415459|Azucena cortada seca oriental rialto|O|O||D||1|Lili cortada seca oriental rialto
10415460|Azucena cortada seca oriental robina|O|O||D||1|Lili cortada seca oriental robina
10415461|Azucena cortada seca oriental rousilon|O|O||D||1|Lili cortada seca oriental rousilon
10415462|Azucena cortada seca oriental siberia|O|O||D||1|Lili cortada seca oriental siberia
10415463|Azucena cortada seca oriental sorbonne|O|O||D||1|Lili cortada seca oriental sorbonne
10415464|Azucena cortada seca oriental starfighter|O|O||D||1|Lili cortada seca oriental starfighter
10415465|Azucena cortada seca oriental stargazer|O|O||D||1|Lili cortada seca oriental stargazer
10415466|Azucena cortada seca oriental sumatra|O|O||D||1|Lili cortada seca oriental sumatra
10415467|Azucena cortada seca oriental time out|O|O||D||1|Lili cortada seca oriental time out
10415468|Azucena cortada seca oriental tom pouche|O|O||D||1|Lili cortada seca oriental tom pouche
10415469|Azucena cortada seca oriental tropical|O|O||D||1|Lili cortada seca oriental tropical
10415470|Azucena cortada seca oriental white cup|O|O||D||1|Lili cortada seca oriental white cup
10415471|Azucena cortada seca oriental white merostar|O|O||D||1|Lili cortada seca oriental white merostar
10415472|Azucena cortada seca oriental white montana|O|O||D||1|Lili cortada seca oriental white montana
10415473|Azucena cortada seca oriental white stargazer|O|O||D||1|Lili cortada seca oriental white stargazer
10415474|Azucena cortada seca oriental yellow band|O|O||D||1|Lili cortada seca oriental yellow band
10415475|Azucena cortada seca oriental yellow dream|O|O||D||1|Lili cortada seca oriental yellow dream
10415476|Azucena cortada seca oriental yellow queen|O|O||D||1|Lili cortada seca oriental yellow queen
10415477|Azucena cortada seca oriental yellow star|O|O||D||1|Lili cortada seca oriental yellow star
10415478|Azucena cortada seca oriental yeloween|O|O||D||1|Lili cortada seca oriental yelloween
10415479|Azucena cortada seca ot red dutch|O|O||D||1|Lili cortada seca ot red dutch
10415480|Azucena cortada seca sonata nimph|O|O||D||1|Lili cortada seca sonata nimph
10415481|Azucena cortada seca sonata shocking|O|O||D||1|Lili cortada seca sonata shocking
10415482|Azucena cortada seca sonata triumphateer|O|O||D||1|Lili cortada seca sonata triumphateer
10415483|Azucena cortada seca sunset longiflorum e híbrido asiática|O|O||D||1|Lili cortada seca sunset longiflorum e híbrido asiática
10415484|Azucena cortada seca de agua|O|O||D||1|Lili cortada seca de agua
10415500|Lavanda cortada seca|O|O||D||1
10415501|Lavanda marina cortada seca misty peach|O|O||D||1
10415502|Lavanda marina cortada seca misty rosada|O|O||D||1
10415503|Lavanda marina cortada seca misty blanca|O|O||D||1
10415504|Lavanda marina cortada seca misty amarilla|O|O||D||1
10415505|Lavanda marina cortada seca safora|O|O||D||1
10415506|Lavanda marina cortada seca sinensis|O|O||D||1
10415600|Lisianthus cortado seco|O|O||D||1|Eustomas cortadas secas
10415601|Lisianthus cortado seco crema|O|O||D||1|Eustoma cortada seca crema
10415602|Lisianthus cortado seco rosado fuerte|O|O||D||1|Eustoma cortada seca rosado fuerte
10415603|Lisianthus cortado seco verde|O|O||D||1|Eustoma cortada seca verde
10415604|Lisianthus cortado seco lavanda|O|O||D||1|Eustoma cortada seca lavanda
10415605|Lisianthus cortado seco rosado claro|O|O||D||1|Eustoma cortada seca rosado claro
10415606|Lisianthus cortado seco mini blanco|O|O||D||1|Eustoma cortada seca mini blanco
10415607|Lisianthus cortado seco durazno|O|O||D||1|Eustoma cortada seca durazno
10415608|Lisianthus cortado seco rosado con borde blanco|O|O||D||1|Eustoma cortada seca rosado con borde blanco
10415609|Lisianthus cortado seco púrpura|O|O||D||1|Eustoma cortada seca púrpura
10415610|Lisianthus cortado seco púrpura con borde blanco|O|O||D||1|Eustoma cortada seca púrpura con borde blanco
10415611|Lisianthus cortado seco blanco con borde rosado|O|O||D||1|Eustoma cortada seca blanco con borde rosado
10415612|Lisianthus cortado seco blanco|O|O||D||1|Eustoma cortada seca blanco
10415613|Lisianthus cortado seco blanco con borde pùrpura|O|O||D||1|Eustoma cortada seca blanco con borde púrpura
10415700|Muscari cortada seca|O|O||D||1
10415701|Muscari cortada seca armeniacum|O|O||D||1
10415702|Muscari cortada seca bortyoides blanca|O|O||D||1
10415703|Muscari cortada seca verde|O|O||D||1
10415704|Muscari cortada seca latifolia|O|O||D||1
10415705|Muscari cortada seca valerie finn|O|O||D||1
10415800|Narciso cortado seco|O|O||D||1
10415801|Narciso cortado seco alegría|O|O||D||1
10415802|Narciso cortado seco amanecer dorado|O|O||D||1
10415803|Narciso cortado seco abba paperwhite|O|O||D||1
10415804|Narciso cortado seco paperwhite|O|O||D||1
10415805|Narciso cortado seco ojo de faisán|O|O||D||1
10415806|Narciso cortado seco soleil d’ or|O|O||D||1
10415807|Narciso cortado seco tete a tete|O|O||D||1
10415808|Narciso cortado seco thalia|O|O||D||1
10416000|Pimientos ornamentales cortado secos|O|O||D||1|Paprikas ornamentales cortadas secas
10416001|Pimiento chile cortado seco ornamental|O|O||D||1|Paprika ornamental cortada seca
10416002|Pimiento mezclado cortado seco ornamental|O|O||D||1|Paprika ornamental mezclada cortada seca
10416003|Pimiento anaranjado cortado seco ornamental|O|O||D||1|Paprika ornamental anaranjada cortada seca
10416004|Pimiento rojo cortado seco ornamental|O|O||D||1|Paprika ornamental roja cortada seca
10416005|Pimiento amarillo cortado seco ornamental|O|O||D||1|Paprika ornamental amarilla cortada seca
10416100|Estrella de Belén cortada seca|O|O||D||1
10416101|Estrella de belén cortada seca arábica|O|O||D||1
10416102|Estrella de belén cortada seca dubium anaranjada|O|O||D||1
10416103|Estrella de belén cortada seca umbellada|O|O||D||1
10416104|Estrella de belén cortada seca dubium blanca|O|O||D||1
10416105|Estrella de belén cortada seca dubium amarilla|O|O||D||1
10416200|Peonia cortada seca|O|O||D||1
10416201|Peonia cortada seca alexander fleming|O|O||D||1
10416202|Peonia cortada seca coral charm|O|O||D||1
10416203|Peonia cortada seca suset|O|O||D||1
10416204|Peonia cortada seca coral supreme|O|O||D||1
10416205|Peonia cortada seca gardenia doble|O|O||D||1
10416206|Peonia cortada seca doble jues eli oscura|O|O||D||1
10416207|Peonia cortada seca soble duquesa blanca|O|O||D||1
10416208|Peonia cortada seca felix crousse|O|O||D||1
10416209|Peonia cortada seca festiva máxima|O|O||D||1
10416210|Peonia cortada seca tesoro del jardín|O|O||D||1
10416211|Peonia cortada seca kansas rosado oscuro|O|O||D||1
10416212|Peonia cortada seca karl rosenfelt|O|O||D||1
10416213|Peonia cortada seca paula fay|O|O||D||1
10416214|Peonia cortada seca encanto rojo|O|O||D||1
10416215|Peonia cortada seca pasion roja|O|O||D||1
10416216|Peonia cortada seca sarah bernhardt roja|O|O||D||1
10416217|Peonia cortada seca scarlet o’ hara|O|O||D||1
10416218|Peonia cortada seca shirley temple|O|O||D||1
10416300|Banksia cortada seca|O|O||D||1|Flores cortadas secas de árbol madreselva australiano
10416301|Banksia cortada seca ashbyi|O|O||D||1|Flor de árbol madreselva australiano cortada seca ashbyi
10416302|Banksia cortada seca baxteri|O|O||D||1|Flor de árbol madreselva australiano cortada seca baxteri
10416306|Banksia cortada seca coccinea|O|O||D||1|Flor de árbol madreselva australiano cortada seca coccínea
10416311|Banksia cortada seca ericifolia|O|O||D||1|Flor de árbol madreselva australiano cortada seca ericifolia
10416315|Banksia cortada seca verde|O|O||D||1|Flor de árbol madreselva australiano cortada seca verde
10416322|Banksia cortada seca menziesii|O|O||D||1|Flor de árbol madreselva australiano cortada seca menziesii
10416325|Banksia cortada seca blanco natural|O|O||D||1|Flor de árbol madreselva australiano cortada seca blanco natural
10416326|Banksia cortada seca anaranjado|O|O||D||1|Flor de árbol madreselva australiano cortada seca anaranjado
10416332|Banksia cortada seca rosada|O|O||D||1|Flor de árbol madreselva australiano cortada seca rosada
10416400|Ranúculo cortado seco|O|O||D||1
10416401|Ranúnculo cortado seco chocolate|O|O||D||1
10416402|Ranúnculo cortado seco elegancia|O|O||D||1
10416403|Ranúnculo cortado seco verde|O|O||D||1
10416404|Ranúnculo cortado seco grimaldi|O|O||D||1
10416405|Ranúnculo cortado seco rosado fuerte|O|O||D||1
10416406|Ranúnculo cortado seco rosado claro|O|O||D||1
10416407|Ranúnculo cortado seco anaranjado|O|O||D||1
10416408|Ranúnculo cortado seco centro verde|O|O||D||1
10416409|Ranúnculo cortado seco rosado|O|O||D||1
10416410|Ranúnculo cortado seco rojo|O|O||D||1
10416411|Ranúnculo cortado seco blanco|O|O||D||1
10416412|Ranúnculo cortado seco amarillo|O|O||D||1
10416413|Ranúnculo cortado seco salmón|O|O||D||1
10416500|Escabiosa cortada seca|O|O||D||1|Flores del acerico cortadas secas
10416501|Escabiosa cortada seca anual|O|O||D||1|Flor del acerico cortada seca anual
10416502|Escabiosa cortada seca negra|O|O||D||1|Flor del acerico cortada seca negra
10416503|Escabiosa cortada seca caucásica azul|O|O||D||1|Flor del acerico cortada seca caucásica azul
10416504|Escabiosa cortada seca caucásica rosada|O|O||D||1|Flor del acerico cortada seca caucásica rosada
10416505|Escabiosa cortada seca caucásica vainas|O|O||D||1|Flor del acerico cortada seca caucásica vainas
10416506|Escabiosa cortada seca caucásica blanca|O|O||D||1|Flor del acerico cortada seca caucásica blanca
10416507|Escabiosa cortada seca fresa|O|O||D||1|Flor del acerico cortada seca fresa
10416600|Retama de escobas cortada seca|O|O||D||1
10416601|Retama de escobas cortada seca rosada|O|O||D||1
10416602|Retama de escobas cortada seca púrpura|O|O||D||1
10416603|Retama de escobas cortada seca blanca|O|O||D||1
10416604|Retama de escobas cortada seca amarilla|O|O||D||1
10416700|Boca de dragón cortada seca|O|O||D||1
10416701|Boca de dragón cortada seca bicolor|O|O||D||1
10416702|Boca de dragón cortada seca burgundy|O|O||D||1
10416703|Boca de dragón cortada seca rosado fuerte|O|O||D||1
10416704|Boca de dragón cortada seca lavanda|O|O||D||1
10416705|Boca de dragón cortada seca anaranjado claro|O|O||D||1
10416706|Boca de dragón cortada seca rosado claro|O|O||D||1
10416707|Boca de dragón cortada seca anaranjado|O|O||D||1
10416708|Boca de dragón cortada seca blanco|O|O||D||1
10416709|Boca de dragón cortada seca amarillo|O|O||D||1
10416800|Romero del pantano cortada seca|O|O||D||1|Siemprevivas azules cortadas secas
10416801|Romero del pantano cortada seca azul|O|O||D||1|Siempreviva azul cortada seca azul
10416802|Romero del pantano cortada seca lavanda|O|O||D||1|Siempreviva azul cortada seca lavanda
10416803|Romero del pantano cortada seca durazno|O|O||D||1|Siempreviva azul cortada seca durazno
10416804|Romero del pantano cortada seca rosada|O|O||D||1|Siempreviva azul cortada seca rosada
10416805|Romero del pantano cortada seca púrpura|O|O||D||1|Siempreviva azul cortada seca púrpura
10416806|Romero del pantano cortada seca espuma de mar|O|O||D||1|Siempreviva azul cortada seca espuma de mar
10416807|Romero del pantano cortada seca blanca|O|O||D||1|Siempreviva azul cortada seca blanca
10416808|Romero del pantano cortada seca amarilla|O|O||D||1|Siempreviva azul cortada seca amarilla
10416900|Matiola cortada seca|O|O||D||1|Alhelís cortadas secas
10416901|Matiola cortada seca apricot|O|O||D||1|Alhelí cortada seca apricot
10416902|Matiola cortada seca crema|O|O||D||1|Alhelí cortada seca crema
10416903|Matiola cortada seca fucsia|O|O||D||1|Alhelí cortada seca fucsia
10416904|Matiola cortada seca lavanda|O|O||D||1|Alhelí cortada seca lavanda
10416905|Matiola cortada seca lavanda claro|O|O||D||1|Alhelí cortada seca lavanda claro
10416906|Matiola cortada seca rosado pacífico|O|O||D||1|Alhelí cortada seca rosado pacífico
10416907|Matiola cortada seca púrpura|O|O||D||1|Alhelí cortada seca púrpura
10416908|Matiola cortada seca rojo rubí|O|O||D||1|Alhelí cortada seca rojo rubí
10416909|Matiola cortada seca enamorada rosda|O|O||D||1|Alhelí cortada seca enamorada rosada
10416910|Matiola cortada seca blanca|O|O||D||1|Alhelí cortada seca blanca
10417000|Girasol cortada seca|O|O||D||1
10417001|Girasol cortada seca tinte festivo|O|O||D||1
10417002|Girasol cortada seca mahogany|O|O||D||1
10417003|Girasol cortada seca rayo de sol|O|O||D||1
10417004|Girasol cortada seca brillo del sol|O|O||D||1
10417005|Girasol cortada seca salpicada de sol|O|O||D||1
10417006|Girasol cortada seca oso de peluche|O|O||D||1
10417100|Guisante de olor cortado seco|O|O||D||1
10417101|Guisante de olor cortado seco verde teñido|O|O||D||1
10417102|Guisante de olor cortado seco rosado fuerte|O|O||D||1
10417103|Guisante de olor cortado seco lavanda|O|O||D||1
10417104|Guisante de olor cortado seco rosado claro|O|O||D||1
10417105|Guisante de olor cortado seco anaranjado|O|O||D||1
10417106|Guisante de olor cortado seco durazno teñido|O|O||D||1
10417107|Guisante de olor cortado seco púrpura|O|O||D||1
10417108|Guisante de olor cortado seco blanco|O|O||D||1
10417200|Cardo cortado seco|O|O||D||1
10417201|Cardo cortado seco alpinum|O|O||D||1
10417202|Cardo cortado seco echinops|O|O||D||1
10417203|Cardo cortado seco eryngium árabe|O|O||D||1
10417204|Cardo cortado seco eryngium azul|O|O||D||1
10417205|Cardo cortado seco eryngium orión|O|O||D||1
10417206|Cardo cortado seco eryngium frambuesa|O|O||D||1
10417207|Cardo cortado seco eryngium supernova|O|O||D||1
10417208|Cardo cortado seco eryngium campanita|O|O||D||1
10417300|Tulipán cortado seco|O|O||D||1
10417301|Tulipán cortado seco adrem|O|O||D||1
10417302|Tulipán cortado seco apricot|O|O||D||1
10417303|Tulipán cortado seco bicolor rojo y amarillo|O|O||D||1
10417304|Tulipán cortado seco doble bicolor|O|O||D||1
10417305|Tulipán cortado seco doble rosado|O|O||D||1
10417306|Tulipán cortado seco doble rojo|O|O||D||1
10417307|Tulipán cortado seco doble blanco|O|O||D||1
10417308|Tulipán cortado seco doble amarillo|O|O||D||1
10417309|Tulipán cortado seco francés avignon|O|O||D||1
10417310|Tulipán cortado seco francés camarque|O|O||D||1
10417311|Tulipán cortado seco francés dordogne|O|O||D||1
10417312|Tulipán cortado seco francés fiat|O|O||D||1
10417313|Tulipán cortado seco francés flamboyant|O|O||D||1
10417314|Tulipán cortado seco francés flaming parrot|O|O||D||1
10417315|Tulipán cortado seco francés florissa|O|O||D||1
10417316|Tulipán cortado seco francés doble maureen|O|O||D||1
10417317|Tulipán cortado seco francés maureen|O|O||D||1
10417318|Tulipán cortado seco francés menton|O|O||D||1
10417319|Tulipán cortado seco francés montpellier|O|O||D||1
10417320|Tulipán cortado seco francés naranja unique|O|O||D||1
10417321|Tulipán cortado seco francés peonia reconocido único|O|O||D||1
10417322|Tulipán cortado seco francés loro rosado|O|O||D||1
10417323|Tulipán cortado seco francés princesa unique|O|O||D||1
10417324|Tulipán cortado seco francés reconocido|O|O||D||1
10417325|Tulipán cortado seco francés schepppers|O|O||D||1
10417326|Tulipán cortado seco francés gamuza|O|O||D||1
10417327|Tulipán cortado seco francés toyota|O|O||D||1
10417328|Tulipán cortado seco francés loro weber|O|O||D||1
10417329|Tulipán cortado seco francés loro blanco|O|O||D||1
10417330|Tulipán cortado seco lavanda de borde crespo|O|O||D||1
10417331|Tulipán cortado seco rosado fuerte|O|O||D||1
10417332|Tulipán cortado seco rosado fuerte hoja variegada|O|O||D||1
10417333|Tulipán cortado seco lavanda|O|O||D||1
10417334|Tulipán cortado seco rosado claro hoja variegada|O|O||D||1
10417335|Tulipán cortado seco viuda alegre|O|O||D||1
10417336|Tulipán cortado seco anaranjado|O|O||D||1
10417337|Tulipán cortado seco loro negro|O|O||D||1
10417338|Tulipán cortado seco loro estela rijnveld|O|O||D||1
10417339|Tulipán cortado seco llameante|O|O||D||1
10417340|Tulipán cortado seco loro verde|O|O||D||1
10417341|Tulipán cortado seco loro lavanda|O|O||D||1
10417342|Tulipán cortado seco loro anaranjado|O|O||D||1
10417343|Tulipán cortado seco loro durazno|O|O||D||1
10417344|Tulipán cortado seco loro rosado|O|O||D||1
10417345|Tulipán cortado seco loro rojo|O|O||D||1
10417346|Tulipán cortado seco loro rojo rococó|O|O||D||1
10417347|Tulipán cortado seco loro weber|O|O||D||1
10417348|Tulipán cortado seco loro blanco|O|O||D||1
10417349|Tulipán cortado seco loro rosado|O|O||D||1
10417350|Tulipán cortado seco rosado|O|O||D||1
10417351|Tulipán cortado seco púrpura|O|O||D||1
10417352|Tulipán cortado seco rojo|O|O||D||1
10417353|Tulipán cortado seco especias|O|O||D||1
10417354|Tulipán cortado seco blanco|O|O||D||1
10417355|Tulipán cortado seco amarillo|O|O||D||1
10417400|Flor de cera cortada seca|O|O||D||1
10417401|Flor de cera cortada seca alba|O|O||D||1
10417402|Flor de cera cortada seca bicolor|O|O||D||1
10417403|Flor de cera cortada seca chichilla|O|O||D||1
10417404|Flor de cera cortada seca reina danzante|O|O||D||1
10417405|Flor de cera cortada seca dinamarca|O|O||D||1
10417406|Flor de cera cortada seca denmar|O|O||D||1
10417407|Flor de cera cortada seca híbrida pastel flor gema|O|O||D||1
10417408|Flor de cera cortada seca híbrida rosada flor gem|O|O||D||1
10417409|Flor de cera cortada seca híbrida blanca rubia|O|O||D||1
10417410|Flor de cera cortada seca híbrida eric john|O|O||D||1
10417411|Flor de cera cortada seca híbrida dama pintada|O|O||D||1
10417412|Flor de cera cortada seca híbrida revelación|O|O||D||1
10417413|Flor de cera cortada seca híbrida bola de nieve|O|O||D||1
10417414|Flor de cera cortada seca juriens brook|O|O||D||1
10417415|Flor de cera cortada seca lady stephanie rosada|O|O||D||1
10417416|Flor de cera cortada seca madonna|O|O||D||1
10417417|Flor de cera cortada seca mini blanca|O|O||D||1
10417418|Flor de cera cortada seca anaranjada|O|O||D||1
10417419|Flor de cera cortada seca perla|O|O||D||1
10417420|Flor de cera cortada seca pixie moon|O|O||D||1
10417421|Flor de cera cortada seca orgullo púrpura|O|O||D||1
10417422|Flor de cera cortada seca roja|O|O||D||1
10417423|Flor de cera cortada seca wanaroo|O|O||D||1
10417424|Flor de cera cortada seca amarilla|O|O||D||1
10417500|Hierba de aquiles cortada seca|O|O||D||1
10417501|Hierba de aquiles cortada seca burgundy|O|O||D||1
10417502|Hierba de aquiles cortada seca crema campesina|O|O||D||1
10417503|Hierba de aquiles cortada seca rosado campesino|O|O||D||1
10417504|Hierba de aquiles cortada seca moonshine|O|O||D||1
10417505|Hierba de aquiles cortada seca anaranjado|O|O||D||1
10417506|Hierba de aquiles cortada seca durazno|O|O||D||1
10417507|Hierba de aquiles cortada seca rosada|O|O||D||1
10417508|Hierba de aquiles cortada seca rojo teñido|O|O||D||1
10417509|Hierba de aquiles cortada seca blanca|O|O||D||1
10417510|Hierba de aquiles cortada seca amarilla|O|O||D||1
10417600|Zinia cortada seca|O|O||D||1|Cinias (guadalajaras) cortadas secas
10417601|Zinia cortada seca rosado fuerte|O|O||D||1|Cinia (guadalajara) cortada seca rosado fuerte
10417602|Zinia cortada seca mini|O|O||D||1|Cinia (guadalajara) cortada seca mini
10417603|Zinia cortada seca rosado|O|O||D||1|Cinia (guadalajara) cortada seca rosado
10417604|Zinia cortada seca rojo|O|O||D||1|Cinia (guadalajara) cortada seca rojo
10417605|Zinia cortada seca salmón|O|O||D||1|Cinia (guadalajara) cortada seca salmón
10417606|Zinia cortada seca amarillo|O|O||D||1|Cinia (guadalajara) cortada seca amarillo
10417700|Forsythia cortada seca|O|O||D||1
10417701|Forsythia cortada seca viridissima|O|O||D||1
10417702|Forsythia cortada seca giraldiana|O|O||D||1
10417703|Forsythia cortada seca mira|O|O||D||1
10417704|Forsythia cortada seca suspensa|O|O||D||1
10417705|Forsythia cortada seca intermedia|O|O||D||1
10417706|Forsythia cortada seca variabilis|O|O||D||1
10417707|Forsythia cortada seca ovate|O|O||D||1
10417708|Forsythia cortada seca intermedia lynwood|O|O||D||1
10417800|Geranio cortado seco|O|O||D||1
10417801|Geranio cortado seco argenteum|O|O||D||1
10417802|Geranio cortado seco cinereum|O|O||D||1
10417803|Geranio cortado seco clarkei|O|O||D||1
10417804|Geranio cortado seco dalmaticum|O|O||D||1
10417805|Geranio cortado seco endressii|O|O||D||1
10417806|Geranio cortado seco eriostemon|O|O||D||1
10417807|Geranio cortado seco farreri|O|O||D||1
10417808|Geranio cortado seco himalayense o grandiflora|O|O||D||1
10417809|Geranio cortado seco ibericum|O|O||D||1
10417810|Geranio cortado seco macrorhizum o raiz grande|O|O||D||1
10417811|Geranio cortado seco maculatum|O|O||D||1
10417812|Geranio cortado seco nodosum|O|O||D||1
10417813|Geranio cortado seco phaeum|O|O||D||1
10417814|Geranio cortado seco platypetalum|O|O||D||1
10417815|Geranio cortado seco pratense|O|O||D||1
10417816|Geranio cortado seco procurrens|O|O||D||1
10417817|Geranio cortado seco psilostemon|O|O||D||1
10417818|Geranio cortado seco pylzowianum|O|O||D||1
10417819|Geranio cortado seco renardii|O|O||D||1
10417820|Geranio cortado seco sanguineum o sangruento|O|O||D||1
10417821|Geranio cortado seco sylvaticum|O|O||D||1
10417822|Geranio cortado seco traversii|O|O||D||1
10417823|Geranio cortado seco tuberosum|O|O||D||1
10417824|Geranio cortado seco versicolor|O|O||D||1
10417825|Geranio cortado seco wallachianum|O|O||D||1
10417826|Geranio cortado seco wlassovianum|O|O||D||1
10417827|Geranio cortado seco x magnificum o llamativo|O|O||D||1
10417900|Amaryllis cortada seca|O|O||D||1|Lirios estrella cortados secos
10417901|Amaryllis cortada seca aglaiae|O|O||D||1|Lirio estrella cortado seco aglaiae
10417902|Amaryllis cortada seca amaru|O|O||D||1|Lirio estrella cortado seco amaru
10417903|Amaryllis cortada seca angustifolium|O|O||D||1|Lirio estrella cortado seco angustifolium
10417904|Amaryllis cortada seca anzaldoi|O|O||D||1|Lirio estrella cortado seco anzaldoi
10417905|Amaryllis cortada seca araripinum|O|O||D||1|Lirio estrella cortado seco araripinum
10417906|Amaryllis cortada seca arboricola|O|O||D||1|Lirio estrella cortado seco arborícola
10417907|Amaryllis cortada seca argentinum|O|O||D||1|Lirio estrella cortado seco argentinum
10417908|Amaryllis cortada seca aulicum|O|O||D||1|Lirio estrella cortado seco aulicum
10417909|Amaryllis cortada seca aviflorum|O|O||D||1|Lirio estrella cortado seco aviflorum
10417910|Amaryllis cortada seca barreirasum|O|O||D||1|Lirio estrella cortado seco barreirasum
10417911|Amaryllis cortada seca blossfeldiae|O|O||D||1|Lirio estrella cortado seco blossfeldiae
10417912|Amaryllis cortada seca blumenavium|O|O||D||1|Lirio estrella cortado seco blumenavium
10417913|Amaryllis cortada seca brasilianum|O|O||D||1|Lirio estrella cortado seco brasilianum
10417914|Amaryllis cortada seca breviflorum|O|O||D||1|Lirio estrella cortado seco breviflorum
10417915|Amaryllis cortada seca bukasovii|O|O||D||1|Lirio estrella cortado seco bukasovii
10417916|Amaryllis cortada seca calyptratum|O|O||D||1|Lirio estrella cortado seco calyptratum
10417917|Amaryllis cortada seca caupolicanense|O|O||D||1|Lirio estrella cortado seco caupolicanense
10417918|Amaryllis cortada seca chionedyanthum|O|O||D||1|Lirio estrella cortado seco chionedyanthum
10417919|Amaryllis cortada seca condemaita|O|O||D||1|Lirio estrella cortado seco condemaita
10417920|Amaryllis cortada seca corriense|O|O||D||1|Lirio estrella cortado seco corriense
10417921|Amaryllis cortada seca cuzcoense|O|O||D||1|Lirio estrella cortado seco cuzcoense
10417922|Amaryllis cortada seca curitibanum|O|O||D||1|Lirio estrella cortado seco curitibanum
10417923|Amaryllis cortada seca cybister|O|O||D||1|Lirio estrella cortado seco cybister
10417924|Amaryllis cortada seca divijuliani|O|O||D||1|Lirio estrella cortado seco divijuliani
10417925|Amaryllis cortada seca evansiae|O|O||D||1|Lirio estrella cortado seco evansiae
10417926|Amaryllis cortada seca ferreyrae|O|O||D||1|Lirio estrella cortado seco ferreyrae
10417927|Amaryllis cortada seca forgetii|O|O||D||1|Lirio estrella cortado seco forgetii
10417928|Amaryllis cortada seca fosteri|O|O||D||1|Lirio estrella cortado seco fosteri
10417929|Amaryllis cortada seca fuscum|O|O||D||1|Lirio estrella cortado seco fuscum
10417930|Amaryllis cortada seca glaucescens|O|O||D||1|Lirio estrella cortado seco glaucescens
10417931|Amaryllis cortada seca goianum|O|O||D||1|Lirio estrella cortado seco goianum
10417932|Amaryllis cortada seca guarapuavicum|O|O||D||1|Lirio estrella cortado seco guarapuavicum
10417933|Amaryllis cortada seca harrisonii|O|O||D||1|Lirio estrella cortado seco harrisonii
10417934|Amaryllis cortada seca hugoi|O|O||D||1|Lirio estrella cortado seco hugoi
10417935|Amaryllis cortada seca iguazuanum|O|O||D||1|Lirio estrella cortado seco iguazuanum
10417936|Amaryllis cortada seca illustre|O|O||D||1|Lirio estrella cortado seco illustre
10417937|Amaryllis cortada seca intiflorum|O|O||D||1|Lirio estrella cortado seco intiflorum
10417938|Amaryllis cortada seca kromeri|O|O||D||1|Lirio estrella cortado seco kromeri
10417939|Amaryllis cortada seca lapacense|O|O||D||1|Lirio estrella cortado seco lapacense
10417940|Amaryllis cortada seca leonardii|O|O||D||1|Lirio estrella cortado seco leonardii
10417941|Amaryllis cortada seca leopoldii|O|O||D||1|Lirio estrella cortado seco leopoldii
10417942|Amaryllis cortada seca macbridei|O|O||D||1|Lirio estrella cortado seco macbridei
10417943|Amaryllis cortada seca machupijchense|O|O||D||1|Lirio estrella cortado seco machupijchense
10417944|Amaryllis cortada seca mandonii|O|O||D||1|Lirio estrella cortado seco mandonii
10417945|Amaryllis cortada seca minasgerais|O|O||D||1|Lirio estrella cortado seco minasgerais
10417946|Amaryllis cortada seca miniatum|O|O||D||1|Lirio estrella cortado seco miniatum
10417947|Amaryllis cortada seca mollevillquense|O|O||D||1|Lirio estrella cortado seco mollevillquense
10417948|Amaryllis cortada seca morelianum|O|O||D||1|Lirio estrella cortado seco morelianum
10417949|Amaryllis cortada seca nelsonii|O|O||D||1|Lirio estrella cortado seco nelsonii
10417950|Amaryllis cortada seca oconoquense|O|O||D||1|Lirio estrella cortado seco oconoquense
10417951|Amaryllis cortada seca papilio|O|O||D||1|Lirio estrella cortado seco papilio
10417952|Amaryllis cortada seca paquichanum|O|O||D||1|Lirio estrella cortado seco paquichanum
10417953|Amaryllis cortada seca paradisiacum|O|O||D||1|Lirio estrella cortado seco paradisiacum
10417954|Amaryllis cortada seca pardinum|O|O||D||1|Lirio estrella cortado seco pardinum
10417955|Amaryllis cortada seca parodii|O|O||D||1|Lirio estrella cortado seco parodii
10417956|Amaryllis cortada seca petiolatum|O|O||D||1|Lirio estrella cortado seco petiolatum
10417957|Amaryllis cortada seca psittacinum|O|O||D||1|Lirio estrella cortado seco psittacinum
10417958|Amaryllis cortada seca puniceum|O|O||D||1|Lirio estrella cortado seco puniceum
10417959|Amaryllis cortada seca reginae|O|O||D||1|Lirio estrella cortado seco reginae
10417960|Amaryllis cortada seca reticulatum|O|O||D||1|Lirio estrella cortado seco reticulatum
10417961|Amaryllis cortada seca rubropictum|O|O||D||1|Lirio estrella cortado seco rubropictum
10417962|Amaryllis cortada seca santacatarina|O|O||D||1|Lirio estrella cortado seco
10417963|Amaryllis cortada seca solandraeflorum|O|O||D||1|Lirio estrella cortado seco solandraeflorum
10417964|Amaryllis cortada seca starkiorum|O|O||D||1|Lirio estrella cortado seco starkiorum
10417965|Amaryllis cortada seca striatum|O|O||D||1|Lirio estrella cortado seco striatum
10417966|Amaryllis cortada seca stylosum|O|O||D||1|Lirio estrella cortado seco stylosum
10417967|Amaryllis cortada seca teyucuarense|O|O||D||1|Lirio estrella cortado seco teyucuarense
10417968|Amaryllis cortada seca traubii|O|O||D||1|Lirio estrella cortado seco traubii
10417969|Amaryllis cortada seca vargasii|O|O||D||1|Lirio estrella cortado seco vargasii
10417970|Amaryllis cortada seca variegatum|O|O||D||1|Lirio estrella cortado seco variegatum
10417971|Amaryllis cortada seca vittatum|O|O||D||1|Lirio estrella cortado seco vittatum
10417972|Amaryllis cortada seca yungacense|O|O||D||1|Lirio estrella cortado seco yungacense
10418000|Rubdeckia cortada seca|O|O||D||1|Equináceas cortadas secas
10418001|Rubdeckia cortada seca alpicola|O|O||D||1|Equinácea cortada seca alpicola
10418002|Rubdeckia cortada seca amplexicaulis|O|O||D||1|Equinácea cortada seca amplexicaulis
10418003|Rubdeckia cortada seca auriculata|O|O||D||1|Equinácea cortada seca auriculata
10418004|Rubdeckia cortada seca bicolor|O|O||D||1|Equinácea cortada seca bicolor
10418005|Rubdeckia cortada seca californica|O|O||D||1|Equinácea cortada seca califórnica
10418006|Rubdeckia cortada seca fulgida|O|O||D||1|Equinácea cortada seca fulgida
10418007|Rubdeckia cortada seca glaucescens|O|O||D||1|Equinácea cortada seca glaucescens
10418008|Rubdeckia cortada seca graminifolia|O|O||D||1|Equinácea cortada seca graminifolia
10418009|Rubdeckia cortada seca grandiflora|O|O||D||1|Equinácea cortada seca grandiflora
10418010|Rubdeckia cortada seca heliopsidis|O|O||D||1|Equinácea cortada seca heliopsidis
10418011|Rubdeckia cortada seca hirta|O|O||D||1|Equinácea cortada seca hirta
10418012|Rubdeckia cortada seca klamathensis|O|O||D||1|Equinácea cortada seca klamathensis
10418013|Rubdeckia cortada seca laciniata|O|O||D||1|Equinácea cortada seca laciniata
10418014|Rubdeckia cortada seca máxima|O|O||D||1|Equinácea cortada seca máxima
10418015|Rubdeckia cortada seca missouriensis|O|O||D||1|Equinácea cortada seca missouriensis
10418016|Rubdeckia cortada seca mohrii|O|O||D||1|Equinácea cortada seca mohrii
10418017|Rubdeckia cortada seca mollis|O|O||D||1|Equinácea cortada seca mollis
10418018|Rubdeckia cortada seca montana|O|O||D||1|Equinácea cortada seca montana
10418019|Rubdeckia cortada seca nítida|O|O||D||1|Equinácea cortada seca nítida
10418020|Rubdeckia cortada seca occidentalis|O|O||D||1|Equinácea cortada seca occidentalis
10418021|Rubdeckia cortada seca pinnata|O|O||D||1|Equinácea cortada seca pinnata
10418022|Rubdeckia cortada seca scabrifolia|O|O||D||1|Equinácea cortada seca scabrifolia
10418023|Rubdeckia cortada seca serotina|O|O||D||1|Equinácea cortada seca serótina
10418024|Rubdeckia cortada seca speciosa|O|O||D||1|Equinácea cortada seca speciosa
10418025|Rubdeckia cortada seca subtomentosa|O|O||D||1|Equinácea cortada seca subtomentosa
10418026|Rubdeckia cortada seca texana|O|O||D||1|Equinácea cortada seca texana
10418027|Rubdeckia cortada seca triloba|O|O||D||1|Equinácea cortada seca triloba
10418100|Protea cortada seca|O|O||D||1
10418101|Protea cortada seca bouquet|O|O||D||1
10418102|Protea cortada seca cepillo botella|O|O||D||1
10418103|Protea cortada seca carnaval|O|O||D||1
10418104|Protea cortada seca follaje cordata|O|O||D||1
10418105|Protea cortada seca grandiceps|O|O||D||1
10418106|Protea cortada seca visón verde|O|O||D||1
10418107|Protea cortada seca hiedra|O|O||D||1
10418108|Protea cortada seca rey|O|O||D||1
10418109|Protea cortada seca nana cones|O|O||D||1
10418110|Protea cortada seca alfiletero anaranjada|O|O||D||1
10418111|Protea cortada seca alfiletero tango|O|O||D||1
10418112|Protea cortada seca alfiletero amarillo|O|O||D||1
10418113|Protea cortada seca hielo rosado|O|O||D||1
10418114|Protea cortada seca visón rosado|O|O||D||1
10418115|Protea cortada seca reina|O|O||D||1
10418116|Protea cortada seca repens|O|O||D||1
10418117|Protea cortada seca cuchara de rosas|O|O||D||1
10418118|Protea cortada seca silvia|O|O||D||1
10418119|Protea cortada seca sugarbush|O|O||D||1
10418120|Protea cortada seca susara|O|O||D||1
10418121|Protea cortada seca waratha|O|O||D||1
10418122|Protea cortada seca visón blanco|O|O||D||1
10418200|leucadendron cortado seco|O|O||D||1
10418201|Leucadendron cortado seco argenteum|O|O||D||1
10418202|Leucadendron cortado seco delicia de crema|O|O||D||1
10418203|Leucadendron cortado seco cumosum|O|O||D||1
10418204|Leucadendron cortado seco discolor|O|O||D||1
10418205|Leucadendron cortado seco galpini|O|O||D||1
10418206|Leucadendron cortado seco mina de oro|O|O||D||1
10418207|Leucadendron cortado seco oro inca|O|O||D||1
10418208|Leucadendron cortado seco bufón|O|O||D||1
10418209|Leucadendron cortado seco laxum|O|O||D||1
10418210|Leucadendron cortado seco mini|O|O||D||1
10418211|Leucadendron cortado seco oro patea|O|O||D||1
10418212|Leucadendron cortado seco petra|O|O||D||1
10418213|Leucadendron cortado seco plumosum|O|O||D||1
10418214|Leucadendron cortado seco roseta|O|O||D||1
10418215|Leucadendron cortado seco atardecer safari|O|O||D||1
10418216|Leucadendron cortado seco atardecer safari spr|O|O||D||1
10418217|Leucadendron cortado seco speciosa|O|O||D||1
10418218|Leucadendron cortado seco spray|O|O||D||1
10418219|Leucadendron cortado seco maravilla wilson|O|O||D||1
10418220|Leucadendron cortado seco yarden|O|O||D||1
10418300|leucospermum cortado seco|O|O||D||1
10418301|Leucospermum cortado seco album|O|O||D||1
10418302|Leucospermum cortado seco attenuatum|O|O||D||1
10418303|Leucospermum cortado seco calligerum|O|O||D||1
10418304|Leucospermum cortado seco conocarpodendron|O|O||D||1
10418305|Leucospermum cortado seco cordatum|O|O||D||1
10418306|Leucospermum cortado seco cuneiforme|O|O||D||1
10418307|Leucospermum cortado seco formosum|O|O||D||1
10418308|Leucospermum cortado seco glabrum|O|O||D||1
10418309|Leucospermum cortado seco grandiflorum|O|O||D||1
10418310|Leucospermum cortado seco harmatum|O|O||D||1
10418311|Leucospermum cortado seco heterophyllum|O|O||D||1
10418312|Leucospermum cortado seco innovans|O|O||D||1
10418313|Leucospermum cortado seco muirii|O|O||D||1
10418314|Leucospermum cortado seco oleifolium|O|O||D||1
10418315|Leucospermum cortado seco patersonii|O|O||D||1
10418316|Leucospermum cortado seco pluridens|O|O||D||1
10418317|Leucospermum cortado seco praemorsum|O|O||D||1
10418318|Leucospermum cortado seco prostratum|O|O||D||1
10418319|Leucospermum cortado seco rodolentum|O|O||D||1
10418320|Leucospermum cortado seco saxatile|O|O||D||1
10418321|Leucospermum cortado seco secundifolium|O|O||D||1
10418322|Leucospermum cortado seco tomentosus|O|O||D||1
10418323|Leucospermum cortado seco truncatulum|O|O||D||1
10418324|Leucospermum cortado seco utriculosum|O|O||D||1
10418325|Leucospermum cortado seco winterii|O|O||D||1
10418326|Leucospermum cortado seco arenarium|O|O||D||1
10418327|Leucospermum cortado seco bolusii|O|O||D||1
10418328|Leucospermum cortado seco catherinae|O|O||D||1
10418329|Leucospermum cortado seco conocarpum|O|O||D||1
10418330|Leucospermum cortado seco cordifolium|O|O||D||1
10418331|Leucospermum cortado seco erubescens|O|O||D||1
10418332|Leucospermum cortado seco gerrardii|O|O||D||1
10418333|Leucospermum cortado seco gracile|O|O||D||1
10418334|Leucospermum cortado seco gueinzii|O|O||D||1
10418335|Leucospermum cortado seco harpagonatum|O|O||D||1
10418336|Leucospermum cortado seco hypophyllocarpodendron|O|O||D||1
10418337|Leucospermum cortado seco lineare|O|O||D||1
10418338|Leucospermum cortado seco mundii|O|O||D||1
10418339|Leucospermum cortado seco parile|O|O||D||1
10418340|Leucospermum cortado seco pendunculatum|O|O||D||1
10418341|Leucospermum cortado seco praecox|O|O||D||1
10418342|Leucospermum cortado seco profugum|O|O||D||1
10418343|Leucospermum cortado seco reflexum|O|O||D||1
10418344|Leucospermum cortado seco royenifolium|O|O||D||1
10418345|Leucospermum cortado seco saxosum|O|O||D||1
10418346|Leucospermum cortado seco spathulatum|O|O||D||1
10418347|Leucospermum cortado seco tottum|O|O||D||1
10418348|Leucospermum cortado seco truncatum|O|O||D||1
10418349|Leucospermum cortado seco vestitum|O|O||D||1
10418350|Leucospermum cortado seco wittebergense|O|O||D||1
10421500|Agapanto cortado seco|O|O||D||1|Flor del amor cortada seca
10421501|Agapanto cortado seco azul|O|O||D||1|Flor del amor cortada seca azul
10421502|Agapanto cortado seco blanco|O|O||D||1|Flor del amor cortada seca blanco
10421600|Alchimilla cortada seca|O|O||D||1|Pie de león cortado seco
10421601|Alchimilla cortada seca capa de dama|O|O||D||1|Pie de león cortado seco capa de dama
10421602|Alchimilla cortada seca robustica|O|O||D||1|Pie de león cortado seco robustica
10421700|Astilbe cortado seco|O|O||D||1|Barba falsa de cabra cortadas secas
10421701|Astilbe cortado seco rosado fuerte|O|O||D||1|Barba falsa de cabra cortada seca rosado fuerte
10421702|Astilbe cortado seco rosado claro|O|O||D||1|Barba falsa de cabra cortada seca rosado claro
10421703|Astilbe cortado seco rojo|O|O||D||1|Barba falsa de cabra cortada seca rojo
10421704|Astilbe cortado seco blanco|O|O||D||1|Barba falsa de cabra cortada seca blanco
10421800|angélica cortada seca|O|O||D||1
10421801|Angélica cortada seca gigas|O|O||D||1
10421802|Angélica cortada seca sylvestris|O|O||D||1
10421900|ajenjo cortado seco|O|O||D||1
10421901|Ajenjo cortado seco verde|O|O||D||1
10421902|Ajenjo cortado seco rey dorado|O|O||D||1
10422000|Flor de alcachofa cortada seca|O|O||D||1
10422001|Flor de alcachofa cortada seca chocolate|O|O||D||1
10422002|Flor de alcachofa cortada seca verde|O|O||D||1
10422003|Flor de alcachofa cortada seca púrpura o floreciente|O|O||D||1
10422100|Astrantia cortada seca|O|O||D||1
10422101|Astrantia cortada seca rosada|O|O||D||1
10422102|Astrantia cortada seca blanca|O|O||D||1
10422200|Flor de banano cortada seca|O|O||D||1
10422201|Flor de banano cortada seca anaranjada|O|O||D||1
10422202|Flor de banano cortada seca antorcha anaranjada|O|O||D||1
10422203|Flor de banano cortada seca púrpura|O|O||D||1
10422300|Baptisia cortada seca|O|O||D||1
10422301|Baptisia cortada seca australis|O|O||D||1
10422302|Baptisia cortada seca sphaerocarpa|O|O||D||1
10422400|Boronia cortada seca|O|O||D||1
10422401|Boronia cortada seca rosada|O|O||D||1
10422402|Boronia cortada seca amarilla|O|O||D||1
10422500|Bromelia cortada seca|O|O||D||1
10422501|Bromelia cortada seca amarilla reg|O|O||D||1
10422502|Bromelia cortada seca roja reg|O|O||D||1
10422600|Brunia cortada seca|O|O||D||1
10422601|Brunia albiflora cortada seca|O|O||D||1
10422602|Brunia albiflora cortada seca verde|O|O||D||1
10422603|Brunia cortada seca rocío de plata|O|O||D||1
10422700|Catalea cortada seca|O|O||D||1|Calatheas cortadas secas
10422701|Calatea cortada seca cigarro|O|O||D||1|Calathea cortada seca cigarro
10422702|Calatea cortada seca hielo verde|O|O||D||1|Calathea cortada seca hielo verde
10422703|Calatea cortada seca serpiente cascabel|O|O||D||1|Calathea cortada seca serpiente cascabel
10422800|Calcynia cortada seca|O|O||D||1
10422801|Calcynia cortada seca rosada|O|O||D||1
10422802|Calcynia cortada seca princesa|O|O||D||1
10422803|Calcynia cortada seca blanca|O|O||D||1
10422900|Caléndula cortada seca|O|O||D||1
10422901|Caléndula cortada seca anaranjada|O|O||D||1
10422902|Caléndula cortada seca amarilla|O|O||D||1
10423000|Campanilla cortada seca|O|O||D||1
10423001|Campanilla cortada seca azul|O|O||D||1
10423002|Campanilla cortada seca rosada|O|O||D||1
10423003|Campanilla cortada seca blanca|O|O||D||1
10423100|Cestrum cortado seco|O|O||D||1
10423101|Cestrum cortado seco rojo|O|O||D||1
10423102|Cestrum cortado seco rojo zohar|O|O||D||1
10423103|Cestrum cortado seco amarillo|O|O||D||1
10423200|Chasmante cortada seca|O|O||D||1
10423201|Chasmante floribunda cortada seca amarilla|O|O||D||1
10423202|Chasmante floribunda cortada seca anaranjada|O|O||D||1
10423300|Costus cortada seca|O|O||D||1
10423301|Costus barbada cortada seca|O|O||D||1
10423302|Costus cortada seca cabeza de indio|O|O||D||1
10423400|Vara de San José cortada seca|O|O||D||1|Montbretias cortadas secas
10423401|Vara de san josé lucifer cortada seca|O|O||D||1|Montbretia lucifer cortada seca
10423402|Vara de san josé cortada seca vainas|O|O||D||1|Montbretia cortada seca vainas
10423403|Vara de san josé cortada seca amarilla|O|O||D||1|Montbretia cortada seca amarilla
10423500|Lirio del Fuego cortado seco|O|O||D||1|Vallotas cortadas secas
10423501|Lirio del fuego cortado seco anaranjado brillante|O|O||D||1|Vallota cortada seca anaranjado brillante
10423502|Lirio del fuego cortado seco crema|O|O||D||1|Vallota cortada seca crema
10423503|Lirio del fuego cortado seco anaranjado|O|O||D||1|Vallota cortada seca anaranjado
10423504|Lirio del fuego cortado seco amarillo|O|O||D||1|Vallota cortada seca amarillo
10423600|Flor del muelle cortada seca|O|O||D||1
10423601|Flor del muelle cortada seca verde|O|O||D||1
10423602|Flor del muelle cortada seca roja|O|O||D||1
10423700|Planta erizo cortada seca|O|O||D||1
10423701|Planta erizo cortada seca tintura negra|O|O||D||1
10423702|Planta erizo cortada seca tintura anaranjada|O|O||D||1
10423800|Manzanilla cortada seca|O|O||D||1
10423801|Manzanilla cortada seca sencilla vegmo|O|O||D||1
10423802|Manzanilla cortada seca doble blanca|O|O||D||1
10423803|Manzanilla cortada seca bola de nieve|O|O||D||1
10423804|Manzanilla cortada seca blanca|O|O||D||1
10423900|Nomeolvides cortada seca|O|O||D||1
10423901|Nomeolvides cortada seca azul|O|O||D||1
10423902|Nomeolvides cortada seca blanca|O|O||D||1
10424000|Gallardia cortada seca|O|O||D||1
10424001|Gallardia cortada seca anaranjada|O|O||D||1
10424002|Gallardia cortada seca amarilla|O|O||D||1
10424100|Genciana cortada seca|O|O||D||1
10424101|Genciana cortada seca azul|O|O||D||1
10424102|Genciana cortada seca blanca|O|O||D||1
10424200|Gladiolo cortado seco|O|O||D||1
10424201|Gladiolo cortado seco glamini rosado|O|O||D||1
10424202|Gladiolo cortado seco glamini rojo|O|O||D||1
10424300|Gloriosa cortada seca|O|O||D||1
10424301|Gloriosa cortada seca anaranjada|O|O||D||1
10424302|Gloriosa cortada seca roja|O|O||D||1
10424303|Gloriosa cortada seca amarilla|O|O||D||1
10424400|Violeta silvestre cortada seca|O|O||D||1|Vadamallis cortadas secas
10424401|Violeta silvestre cortada seca anaranjada|O|O||D||1|Vadamalli cortada seca anaranjada
10424402|Violeta silvestre cortada seca roja|O|O||D||1|Vadamalli cortada seca roja
10424500|Eléboro cortado seco|O|O||D||1|Hierbas de ballesteros cortadas secas
10424501|Eléboro cortado seco verde|O|O||D||1|Hierba de ballesteros cortado seco verde
10424502|Eléboro cortado seco rayo de luna|O|O||D||1|Hierba de ballesteros cortado seco rayo de luna
10424600|Ixia cortada seca|O|O||D||1
10424601|Ixia cortada seca rosada|O|O||D||1
10424602|Ixia cortada seca blanca|O|O||D||1
10424700|Liatrises cortadas secas|O|O||D||1
10424701|Liatris cortada seca púrpura|O|O||D||1
10424702|Liatris cortada seca spray|O|O||D||1
10424703|Liatris cortada seca blanca|O|O||D||1
10424800|Lysimachia cortada seca|O|O||D||1
10424801|Lysimachia punctata cortada seca|O|O||D||1
10424802|Lysimachia vulgaris cortada seca|O|O||D||1
10424803|Lysimachia blanca cortada seca|O|O||D||1
10424804|Lysimachia amarilla cortada seca|O|O||D||1
10424900|Maraca cortada seca|O|O||D||1
10424901|Maraca cortada seca marrón|O|O||D||1
10424902|Maraca cortada seca shampoo ginger|O|O||D||1
10425000|Caléndula cortada seca|O|O||D||1
10425001|Caléndula cortada seca francesa|O|O||D||1
10425002|Caléndula cortada seca verde|O|O||D||1
10425003|Caléndula (marigold) cortada seca anaranjada|O|O||D||1
10425004|Caléndula (marigold) cortada seca amarilla|O|O||D||1
10425100|Mimosa cortada seca|O|O||D||1
10425101|Mimosa cortada seca azul o púrpura|O|O||D||1
10425102|Mimosa dedo cortada seca|O|O||D||1
10425103|Mimosa cortada seca floribunda o italia|O|O||D||1
10425104|Mimosa cortada seca mirandola|O|O||D||1
10425200|Nerina cortada seca|O|O||D||1
10425201|Nerina cortada seca rosada|O|O||D||1
10425202|Nerina samiensis blanca|O|O||D||1
10425300|Flor de nogal cortada seca|O|O||D||1
10425301|Flor colgante de nogal blanco cortada seca|O|O||D||1
10425302|Flor sin hojas de nogal blanco cortada seca|O|O||D||1
10425303|Flor erecta de nogal blanco brasileño cortada seca|O|O||D||1
10425400|Phlox cortada seca|O|O||D||1
10425401|Phlox cortada seca rosado oscur|O|O||D||1
10425402|Phlox cortada seca lavanda|O|O||D||1
10425403|Phlox cortada seca rosado claro|O|O||D||1
10425404|Phlox cortada seca blanca|O|O||D||1
10425500|physostegia cortada seca|O|O||D||1|Plantas obediente cortadas secas
10425501|Physostegia cortada seca rosada|O|O||D||1|Planta obediente cortada seca rosada
10425502|Physostegia cortada seca vainas|O|O||D||1|Planta obediente cortada seca vainas
10425503|Physostegia cortada seca blanca|O|O||D||1|Planta obediente cortada seca blanca
10425600|Saponaria cortada seca|O|O||D||1|Jabonarias cortadas secas
10425601|Saponaria cortada seca rosada|O|O||D||1|Jabonaria cortada seca rosada
10425602|Saponaria cortada seca blanca|O|O||D||1|Jabonaria cortada seca blanca
10425700|Sarracenias cortadas secas|O|O||D||1
10425701|Sarracenia cortada seca flava rugelii|O|O||D||1
10425800|Sicilia cortada seca|O|O||D||1|Scillas cortadas secas
10425801|Sicilia cortada seca campanulata azul|O|O||D||1|Scilla cortada seca campanulata azul
10425802|Sicilia cortada seca campanulata rosada|O|O||D||1|Scilla cortada seca campanulata rosada
10425803|Sicilia cortada seca campanulata blanca|O|O||D||1|Scilla cortada seca campanulata blanca
10425804|Sicilia cortada seca peruana|O|O||D||1|Scilla cortada seca peruana
10425900|Sedum cortada seca|O|O||D||1
10425901|Sedum cortada seca marrón|O|O||D||1
10425902|Sedum cortada seca verde|O|O||D||1
10425903|Sedum cortada seca rosada|O|O||D||1
10425904|Sedum cortada seca roja|O|O||D||1
10426000|Especies individuales o variedades de flores cortadas secas|O|O||D||1|Arreglos florales secos, Flor de cempasúchil cortada seca
10426001|Agrsotema cortada seca|O|O||D||1
10426002|Kniphophia o assegai poker cortada seca|O|O||D||1
10426003|Bellis perennis cortada seca|O|O||D||1
10426004|Campana de irlanda o molucella cortada seca|O|O||D||1
10426005|Ave del paraíso cortada seca|O|O||D||1
10426006|Novia sonrojada cortada seca|O|O||D||1
10426007|Buddleia o arbusto mariposa cortada seca|O|O||D||1
10426008|Bupleurum griffithii cortada seca|O|O||D||1
10426009|California ginesta cortada seca|O|O||D||1
10426010|Callicarpa púrpura cortada seca|O|O||D||1
10426011|Campanilla blanca cortada seca|O|O||D||1
10426012|Penacho dulce cortada seca|O|O||D||1
10426013|Cariopteris cortada seca|O|O||D||1
10426014|Centaurea o marco polo cortada seca|O|O||D||1
10426015|Linterna china cortada seca|O|O||D||1
10426016|Clematis recta purpurea cortada seca|O|O||D||1
10426017|Cleome spinosa cortada seca|O|O||D||1
10426018|Coreopsis cortada seca|O|O||D||1
10426019|Farolitos de la virgen azul cortada seca|O|O||D||1
10426020|Cosmos chocolate cortada seca|O|O||D||1
10426021|Cotinus coggygria cortada seca|O|O||D||1
10426022|Craspedia o billy bolas cortada seca|O|O||D||1
10426023|Deutzia alta cortada seca|O|O||D||1
10426024|Diosma cortada seca|O|O||D||1
10426025|Echeveria suculenta chupahuevos cortada seca|O|O||D||1
10426026|Echinacea purpurea cortada seca|O|O||D||1
10426027|Edelweiss cortada seca|O|O||D||1
10426028|Erythronium pagoda cortada seca|O|O||D||1
10426029|Flor de eucalipto cortada seca|O|O||D||1
10426030|Eucaris o lirio del amazonas cortado seco|O|O||D||1
10426031|Eucomis o lirio de piña cortado seco|O|O||D||1
10426032|Eupatorium maculatum cortado seco|O|O||D||1
10426033|Filipendula cortada seca|O|O||D||1
10426034|Digitalis cortado seco|O|O||D||1
10426035|Gilia globo cortada seca|O|O||D||1
10426036|Globularia de ojo azul cortada seca|O|O||D||1
10426037|Washington hawthorne cortada seca|O|O||D||1
10426038|Helenio cortada seca|O|O||D||1
10426039|Helianto cortada seca|O|O||D||1
10426040|Herperis matronalis cortada seca|O|O||D||1
10426041|Houttuynia cordata chameleon cortada seca|O|O||D||1
10426042|Jacinto con bulbo cortada seca|O|O||D||1
10426043|Maiz indio cortado seco|O|O||D||1
10426044|Jack in the pulpit cortado seco|O|O||D||1
10426045|Arbol del cielo japonés cortado seco|O|O||D||1
10426046|Enredadera de jazmin florecida cortada seca|O|O||D||1
10426047|Jatropha curcas o pólvora cortada seca|O|O||D||1
10426048|Knautia cortada seca|O|O||D||1
10426049|Kochia sedifolia cortada seca|O|O||D||1
10426050|Lachenalia romaud cortada seca|O|O||D||1
10426051|Flor de oreja de oveja cortada seca|O|O||D||1
10426052|Lavanda cortada seca|O|O||D||1
10426053|Leucocoryne speciosa cortada seca|O|O||D||1
10426054|Lythrum cortada seca|O|O||D||1
10426055|Malva zebrina cortada seca|O|O||D||1
10426056|Margarita blanca cortada seca|O|O||D||1
10426057|Montbretia amarilla cortada seca|O|O||D||1
10426058|Nebelia cortada seca|O|O||D||1
10426059|Nicotiana cortada seca|O|O||D||1
10426060|Nigella damascena o amor en la niebla cortada seca|O|O||D||1
10426061|Nigella cortada seca|O|O||D||1
10426062|Orquídea de monja cortada seca|O|O||D||1
10426063|Orquídea verde paphiopedilum cortada seca|O|O||D||1
10426064|Paranomus cortada seca|O|O||D||1
10426065|Penstemon husker rojo cortado seco|O|O||D||1
10426066|Manzana peruana cortada seca|O|O||D||1|Cactus cortado seco
10426067|Phlomis sarnia cortada seca|O|O||D||1
10426068|Didiscus o flor de encaje rosada cortada seca|O|O||D||1
10426069|Platycodon o flor globo cortada seca|O|O||D||1
10426070|Retzia capensis cortada seca|O|O||D||1
10426071|Ricino común cortado seco|O|O||D||1
10426072|Nieve en el monte cortada seca|O|O||D||1
10426073|Solidago teñida cortada seca|O|O||D||1
10426074|Scilla blanca cortada seca|O|O||D||1|Cebolla albarrana cortada seca (ornamental)
10426075|Stachys byzantina cortada seca|O|O||D||1
10426076|Flor de paja cortada seca|O|O||D||1
10426077|Oscularia suculenta cortada seca|O|O||D||1
10426078|Flor de tillasandia cortada seca|O|O||D||1
10426079|Triteleia cortada seca|O|O||D||1
10426080|Tritoma naranja o chuzo caliente cortada seca roja|O|O||D||1
10426081|Veronicastrum virginiana cortada seca|O|O||D||1
10426082|Bromelia vriesea splendens cortada seca|O|O||D||1|Pluma de indio cortada seca
10426084|Hipericim o hierba de san juan cortada seca|O|O||D||1
10426085|Spirea cortada seca|O|O||D||1
10426086|Yerba de san bonifacio cortada seca|O|O||D||1
10426100|Sello de salomón (polygonato) cortada seca|O|O||D||1
10426101|Sello de salomón (polygonato) falso cortada seca|O|O||D||1
10426102|Sello de salomón (polygonato) variegado cortada seca|O|O||D||1
10426200|Tanaceto cortado seco|O|O||D||1
10426201|Tanaceto cortado seco amazonas|O|O||D||1
10426202|Tanaceto cortado seco victoria doble blanco|O|O||D||1
10426203|Tanaceto cortado seco victoria sencillo blanco|O|O||D||1
10426204|Tanaceto cortado seco vegmo amarillo|O|O||D||1
10426300|Traquelio cortado seco|O|O||D||1|Flores de la viuda cortadas secas
10426301|Trachelium jade cortada seca|O|O||D||1|Flor de la viuda jade cortada seca
10426302|Trachelium púrpura cortada seca|O|O||D||1|Flor de la viuda púrpura cortada seca
10426303|Trachelium blanca cortada seca|O|O||D||1|Flor de la viuda blanca cortada seca
10426400|Tuberosas cortadas secas|O|O||D||1|Nardos cortados secos
10426401|Tuberosa cortada seca doble|O|O||D||1|Nardo cortado seco doble
10426402|Tuberosa cortada seca sencilla|O|O||D||1|Nardo cortado seco sencillo
10426500|Tweedias cortadas secas|O|O||D||1
10426501|Tweedia azul cortada seca|O|O||D||1
10426502|Tweedia blanca cortada seca|O|O||D||1
10426600|Verónicas cortadas secas|O|O||D||1
10426601|Verónica cortada seca rosada|O|O||D||1
10426602|Verónica cortada seca púrpura|O|O||D||1
10426603|Verónica cortada seca blanca|O|O||D||1
10426700|Watsonias cortadas secas|O|O||D||1
10426701|Watsonia cortada seca anaranjada|O|O||D||1
10426702|Watsonia cortada seca rosada|O|O||D||1
10426703|Watsonia cortada seca roja|O|O||D||1
10426704|Watsonia cortada seca blanca|O|O||D||1
10431500|Crisantemo cortado seco pompón|O|O||D||1
10431501|Crisantemo cortado seco pompón delirock|O|O||D||1
10431502|Crisantemo cortado seco pompón discovery|O|O||D||1
10431503|Crisantemo cortado seco pompón focus|O|O||D||1
10431504|Crisantemo cortado seco pompón jeanne|O|O||D||1
10431505|Crisantemo cortado seco pompón lady|O|O||D||1
10431506|Crisantemo cortado seco pompón leidi|O|O||D||1
10431507|Crisantemo cortado seco pompón lexy|O|O||D||1
10431508|Crisantemo cortado seco pompón ole|O|O||D||1
10431509|Crisantemo cortado seco pompón revise|O|O||D||1
10431510|Crisantemo cortado seco pompón estadista|O|O||D||1
10431511|Crisantemo cortado seco pompón dulce|O|O||D||1
10431512|Crisantemo cortado seco pompón yoko ono|O|O||D||1
10431513|Crisantemo cortado seco pompón zip|O|O||D||1
10431600|Crisantemo cortado seco pompón margarita|O|O||D||1
10431601|Crisantemo cortado seco pompón artista rosado|O|O||D||1
10431602|Crisantemo cortado seco pompón artista amarillo|O|O||D||1
10431603|Crisantemo cortado seco pompón atlantis rosado|O|O||D||1
10431604|Crisantemo cortado seco pompón atlantis blanco|O|O||D||1
10431605|Crisantemo cortado seco pompón atlantis amarillo|O|O||D||1
10431606|Crisantemo cortado seco pompón bennie jolink|O|O||D||1
10431607|Crisantemo cortado seco pompón bennie jolink amarillo|O|O||D||1
10431608|Crisantemo cortado seco pompón managua bronce|O|O||D||1
10431609|Crisantemo cortado seco pompón clave|O|O||D||1
10431610|Crisantemo cortado seco pompón ficción coral|O|O||D||1
10431611|Crisantemo cortado seco pompón cumbia|O|O||D||1
10431612|Crisantemo cortado seco pompón cantata oscura|O|O||D||1
10431613|Crisantemo cortado seco pompón lineker oscuro|O|O||D||1
10431614|Crisantemo cortado seco pompón dipper|O|O||D||1
10431615|Crisantemo cortado seco pompón rosado elite|O|O||D||1
10431616|Crisantemo cortado seco pompón blanco elite|O|O||D||1
10431617|Crisantemo cortado seco pompón amarillo elite|O|O||D||1
10431618|Crisantemo cortado seco pompón factor|O|O||D||1
10431619|Crisantemo cortado seco pompón ficción|O|O||D||1
10431620|Crisantemo cortado seco pompón fuerza|O|O||D||1
10431621|Crisantemo cortado seco pompón reagan mejorado|O|O||D||1
10431622|Crisantemo cortado seco pompón life|O|O||D||1
10431623|Crisantemo cortado seco pompón managua anaranjado|O|O||D||1
10431624|Crisantemo cortado seco pompón novedsd bronce cocarde|O|O||D||1
10431625|Crisantemo cortado seco pompón reagan anaranjado|O|O||D||1
10431626|Crisantemo cortado seco pompón orinoco|O|O||D||1
10431627|Crisantemo cortado seco pompón petra|O|O||D||1
10431628|Crisantemo cortado seco pompón balsas rosado|O|O||D||1
10431629|Crisantemo cortado seco pompón mona lisa rosado|O|O||D||1
10431630|Crisantemo cortado seco pompón reagan rosado|O|O||D||1
10431631|Crisantemo cortado seco pompón marfil reagan|O|O||D||1
10431632|Crisantemo cortado seco pompón reagan rosado|O|O||D||1
10431633|Crisantemo cortado seco pompón rebasco|O|O||D||1
10431634|Crisantemo cortado seco pompón redock|O|O||D||1
10431635|Crisantemo cortado seco pompón salmón lineker|O|O||D||1
10431636|Crisantemo cortado seco pompón sheba|O|O||D||1
10431637|Crisantemo cortado seco pompón sirius|O|O||D||1
10431638|Crisantemo cortado seco pompón reagan espléndido|O|O||D||1
10431639|Crisantemo cortado seco pompón reagan soleado|O|O||D||1
10431640|Crisantemo cortado seco pompón tina|O|O||D||1
10431641|Crisantemo cortado seco pompón vero|O|O||D||1
10431642|Crisantemo cortado seco pompón volare|O|O||D||1
10431643|Crisantemo cortado seco pompón vida blanca|O|O||D||1
10431644|Crisantemo cortado seco pompón regan blanco|O|O||D||1
10431645|Crisantemo cortado seco pompón rino blanco|O|O||D||1
10431646|Crisantemo cortado seco pompón vero amarillo|O|O||D||1
10431647|Crisantemo cortado seco pompón zenith|O|O||D||1
10431700|Crisantemo cortado seco espollado cremon|O|O||D||1
10431701|Crisantemo cortado seco espollado cremon annecy oscura|O|O||D||1
10431702|Crisantemo cortado seco espollado cremon|O|O||D||1
10431703|Crisantemo cortado seco espollado cremon atlantis rosado|O|O||D||1
10431704|Crisantemo cortado seco espollado cremon eleonora bronce|O|O||D||1
10431705|Crisantemo cortado seco espollado cremon eleonora lila|O|O||D||1
10431706|Crisantemo cortado seco espollado cremon eleonora rosado|O|O||D||1
10431707|Crisantemo cortado seco espollado cremon eleonora nieve|O|O||D||1
10431708|Crisantemo cortado seco espollado cremon eleonora amarillo|O|O||D||1
10431709|Crisantemo cortado seco espollado cremon idea|O|O||D||1
10431710|Crisantemo cortado seco espollado cremon ivanna púrpura|O|O||D||1
10431711|Crisantemo cortado seco espollado cremon minka rosado|O|O||D||1
10431712|Crisantemo cortado seco espollado cremon listo|O|O||D||1
10431713|Crisantemo cortado seco espollado cremon sinatra|O|O||D||1
10431714|Crisantemo cortado seco rover rojo|O|O||D||1
10431800|Crisantemo cortado seco espollado football|O|O||D||1
10431801|Crisantemo cortado seco espollado blaze|O|O||D||1
10431802|Crisantemo cortado seco espollado beso de football|O|O||D||1
10431803|Crisantemo cortado seco espollado football lavanda / rosado|O|O||D||1
10431804|Crisantemo cortado seco espollado football resouci|O|O||D||1
10431805|Crisantemo cortado seco espollado footbal blanco|O|O||D||1
10431806|Crisantemo cortado seco espollado football amarillo|O|O||D||1
10431807|Crisantemo cortado seco espollado promenade|O|O||D||1
10431808|Crisantemo cortado seco espollado rebonnet|O|O||D||1
10431809|Crisantemo cortado seco espollado reflex|O|O||D||1
10431810|Crisantemo cortado seco espollado residence|O|O||D||1
10431811|Crisantemo cortado seco espollado resomee perla|O|O||D||1
10431812|Crisantemo cortado seco espollado resouci|O|O||D||1
10431900|Crisantemo spider cortado seco|O|O||D||1
10431901|Crisantemo spider cortado seco anastasia bronce|O|O||D||1
10431902|Crisantemo spider cortado seco anastasia bronce oscuro|O|O||D||1
10431903|Crisantemo spider cortado seco anastasia verde|O|O||D||1
10431904|Crisantemo spider cortado seco anastasia lila|O|O||D||1
10431905|Crisantemo spider cortado seco anastasia rosado|O|O||D||1
10431906|Crisantemo spider cortado seco anastasia púrpura|O|O||D||1
10431907|Crisantemo spider cortado seco anastasia soleado|O|O||D||1
10431908|Crisantemo spider cortado seco anastasia blanco|O|O||D||1
10431909|Crisantemo spider cortado seco bradford|O|O||D||1
10431910|Crisantemo spider cortado seco delistar blanco|O|O||D||1
10431911|Crisantemo spider cortado seco delistar amarillo|O|O||D||1
10431912|Crisantemo spider cortado seco minka|O|O||D||1
10431913|Crisantemo spider cortado seco natasha soleado|O|O||D||1
10431914|Crisantemo spider cortado seco pirouette|O|O||D||1
10431915|Crisantemo spider cortado seco reflejo|O|O||D||1
10431916|Crisantemo spider cortado seco regata|O|O||D||1
10431917|Crisantemo spider cortado seco render|O|O||D||1
10431918|Crisantemo spider cortado seco repertorio|O|O||D||1
10431919|Crisantemo spider cortado seco resolute|O|O||D||1
10431920|Crisantemo spider cortado seco resomac|O|O||D||1
10431921|Crisantemo spider cortado seco trébol|O|O||D||1
10431922|Crisantemo spider cortado seco talante bronce|O|O||D||1
10431923|Crisantemo spider cortado seco super blanco|O|O||D||1
10431924|Crisantemo spider cortado seco super amarillo|O|O||D||1
10431925|Crisantemo spider cortado seco tierno|O|O||D||1
10431926|Crisantemo spider cortado seco zembia|O|O||D||1
10432000|Crisantemo cortado seco  novelty|O|O||D||1
10432001|Crisantemo cortado seco pompón anecy rosado|O|O||D||1
10432002|Crisantemo cortado seco pompón ardilo royal|O|O||D||1
10432003|Crisantemo cortado seco pompón athos|O|O||D||1
10432004|Crisantemo cortado seco pompón biarritz|O|O||D||1
10432005|Crisantemo cortado seco pompón bradford anaranjado|O|O||D||1
10432006|Crisantemo cortado seco pompón bradford|O|O||D||1
10432007|Crisantemo cortado seco pompón vela|O|O||D||1
10432008|Crisantemo cortado seco pompón candor|O|O||D||1
10432009|Crisantemo cortado seco pompón gallardía|O|O||D||1
10432010|Crisantemo cortado seco pompón décima|O|O||D||1
10432012|Crisantemo cortado seco pompón delisun|O|O||D||1
10432013|Crisantemo cortado seco pompón dion|O|O||D||1
10432014|Crisantemo cortado seco pompón dorena|O|O||D||1
10432015|Crisantemo cortado seco pompón dublín|O|O||D||1
10432016|Crisantemo cortado seco pompón everglades|O|O||D||1
10432017|Crisantemo cortado seco pompón buenmozo|O|O||D||1
10432018|Crisantemo cortado seco pompón hasting|O|O||D||1
10432019|Crisantemo cortado seco pompón high five|O|O||D||1
10432020|Crisantemo cortado seco pompón mundial mejorado|O|O||D||1
10432021|Crisantemo cortado seco pompón juanes|O|O||D||1
10432022|Crisantemo cortado seco pompón kiato verde|O|O||D||1
10432023|Crisantemo cortado seco pompón kiato|O|O||D||1
10432024|Crisantemo cortado seco pompón kiwi|O|O||D||1
10432025|Crisantemo cortado seco pompón madeira|O|O||D||1
10432026|Crisantemo cortado seco pompón magneto|O|O||D||1
10432027|Crisantemo cortado seco pompón marimo|O|O||D||1
10432028|Crisantemo cortado seco pompón matrix|O|O||D||1
10432029|Crisantemo cortado seco pompón miletta|O|O||D||1
10432030|Crisantemo cortado seco pompón monalisa|O|O||D||1
10432031|Crisantemo cortado seco pompón omaha|O|O||D||1
10432032|Crisantemo cortado seco pompón orinoco púrpura|O|O||D||1
10432033|Crisantemo cortado seco pompón orinoco amarillo|O|O||D||1
10432034|Crisantemo cortado seco pompón verde pacífico|O|O||D||1
10432035|Crisantemo cortado seco pompón blanco puma|O|O||D||1
10432036|Crisantemo cortado seco pompón amarillo puma|O|O||D||1
10432037|Crisantemo cortado seco pompón mundial púrpura|O|O||D||1
10432038|Crisantemo cortado seco pompón regata|O|O||D||1
10432039|Crisantemo cortado seco pompón remco|O|O||D||1
10432040|Crisantemo cortado seco pompón royal mundial|O|O||D||1
10432041|Crisantemo cortado seco pompón sabrina|O|O||D||1
10432042|Crisantemo cortado seco pompón shakira blanco|O|O||D||1
10432043|Crisantemo cortado seco pompón sharp|O|O||D||1
10432044|Crisantemo cortado seco pompón shock|O|O||D||1
10432045|Crisantemo cortado seco pompón sizzle verde|O|O||D||1
10432046|Crisantemo cortado seco pompón sizzle rosado|O|O||D||1
10432047|Crisantemo cortado seco pompón sizzle|O|O||D||1
10432048|Crisantemo cortado seco pompón sizzle púrpura|O|O||D||1
10432049|Crisantemo cortado seco pompón sizzle salmón|O|O||D||1
10432050|Crisantemo cortado seco pompón sizzle amarillo|O|O||D||1
10432051|Crisantemo cortado seco pompón bandera española|O|O||D||1
10432052|Crisantemo cortado seco pompón starbust o copo de nieve|O|O||D||1
10432053|Crisantemo cortado seco pompón cisne|O|O||D||1
10432054|Crisantemo cortado seco pompón tedcha anaranjado|O|O||D||1
10432055|Crisantemo cortado seco pompón tierno|O|O||D||1
10432056|Crisantemo cortado seco pompón oropel|O|O||D||1
10432057|Crisantemo cortado seco pompón toque|O|O||D||1
10432058|Crisantemo cortado seco pompón troyes|O|O||D||1
10432059|Crisantemo cortado seco pompón valesca|O|O||D||1
10432060|Crisantemo cortado seco pompón anaranjado vikingo|O|O||D||1
10432061|Crisantemo cortado seco pompón vikingo|O|O||D||1
10432062|Crisantemo cortado seco pompón reloj|O|O||D||1
10432063|Crisantemo cortado seco pompón aguja blanco|O|O||D||1
10432064|Crisantemo cortado seco pompón noche blanca|O|O||D||1
10432065|Crisantemo cortado seco pompón artista amarillo|O|O||D||1
10432066|Crisantemo cortado seco pompón ficción amarillo|O|O||D||1
10432067|Crisantemo cortado seco pompón sharp amarillo|O|O||D||1
10432100|Crisantemo cortado seco santini|O|O||D||1
10432101|Crisantemo cortado seco pompón alma|O|O||D||1
10432102|Crisantemo cortado seco pompón barón|O|O||D||1
10432103|Crisantemo cortado seco pompón bernardo|O|O||D||1
10432104|Crisantemo cortado seco pompón bistro|O|O||D||1
10432105|Crisantemo cortado seco pompón bodega|O|O||D||1
10432106|Crisantemo cortado seco pompón brisa|O|O||D||1
10432107|Crisantemo cortado seco pompón centella bronce|O|O||D||1
10432108|Crisantemo cortado seco pompón costa blanca|O|O||D||1
10432109|Crisantemo cortado seco pompón creta|O|O||D||1
10432110|Crisantemo cortado seco pompón deliflame|O|O||D||1
10432111|Crisantemo cortado seco pompón dalila|O|O||D||1
10432112|Crisantemo cortado seco pompón dígito|O|O||D||1
10432113|Crisantemo cortado seco pompón evilio|O|O||D||1
10432114|Crisantemo cortado seco pompón furense|O|O||D||1
10432115|Crisantemo cortado seco pompón guía|O|O||D||1
10432116|Crisantemo cortado seco pompón kerry|O|O||D||1
10432117|Crisantemo cortado seco pompón kess|O|O||D||1
10432118|Crisantemo cortado seco pompón lima|O|O||D||1
10432119|Crisantemo cortado seco pompón lupo|O|O||D||1
10432120|Crisantemo cortado seco pompón lineker anaranjado|O|O||D||1
10432121|Crisantemo cortado seco pompón panuco rojo|O|O||D||1
10432122|Crisantemo cortado seco pompón costa rosado|O|O||D||1
10432123|Crisantemo cortado seco pompón rafael|O|O||D||1
10432124|Crisantemo cortado seco pompón refine|O|O||D||1
10432125|Crisantemo cortado seco pompón regaliz|O|O||D||1
10432126|Crisantemo cortado seco pompón renella|O|O||D||1
10432127|Crisantemo cortado seco pompón retorno|O|O||D||1
10432128|Crisantemo cortado seco pompón río|O|O||D||1
10432129|Crisantemo cortado seco pompón sabas|O|O||D||1
10432130|Crisantemo cortado seco pompón target|O|O||D||1
10432131|Crisantemo cortado seco pompón texto|O|O||D||1
10432132|Crisantemo cortado seco pompón caballo amarillo|O|O||D||1
10441500|Clavel cortado seco de floración sencilla|O|O||D||1
10441501|Clavel cortado seco de floración sencilla burgundy bicolor|O|O||D||1
10441502|Clavel cortado seco de floración sencilla burgundy|O|O||D||1
10441503|Clavel cortado seco de floración sencilla cinderella|O|O||D||1
10441504|Clavel cortado seco de floración sencilla crema bicolor|O|O||D||1
10441505|Clavel cortado seco de floración sencilla crema|O|O||D||1
10441506|Clavel cortado seco de floración sencilla verde o prado|O|O||D||1
10441507|Clavel cortado seco de floración sencilla rosado fuerte|O|O||D||1
10441508|Clavel cortado seco de floración sencilla verde claro|O|O||D||1
10441509|Clavel cortado seco de floración sencilla rosado claro|O|O||D||1
10441510|Clavel cortado seco de floración sencilla anaranjado bicolor|O|O||D||1
10441511|Clavel cortado seco de floración sencilla anaranjado|O|O||D||1
10441512|Clavel cortado seco de floración sencilla durazno|O|O||D||1
10441513|Clavel cortado seco de floración sencilla menta bicolor|O|O||D||1
10441514|Clavel cortado seco de floración sencilla rosado bicolor|O|O||D||1
10441515|Clavel cortado seco de floración sencilla rosado|O|O||D||1
10441516|Clavel cortado seco de floración sencilla púrpura bicolor|O|O||D||1
10441517|Clavel cortado seco de floración sencilla rojo bicolor|O|O||D||1
10441518|Clavel cortado seco de floración sencilla rojo|O|O||D||1
10441519|Clavel cortado seco de floración sencilla blanco|O|O||D||1
10441520|Clavel cortado seco de floración sencilla amarillo|O|O||D||1
10441600|Clavel cortado seco mini o spray|O|O||D||1
10441601|Clavel cortado seco mini o spray burgundy|O|O||D||1
10441602|Clavel cortado seco mini o spray|O|O||D||1
10441603|Clavel cortado seco mini o spray rosado fuerte|O|O||D||1
10441604|Clavel cortado seco mini o spray lavanda|O|O||D||1
10441605|Clavel cortado seco mini o spray rosado claro|O|O||D||1
10441606|Clavel cortado seco mini o spray anaranjado|O|O||D||1
10441607|Clavel cortado seco mini o spray durazno|O|O||D||1
10441608|Clavel cortado seco mini o spray menta|O|O||D||1
10441609|Clavel cortado seco mini o spray rosado|O|O||D||1
10441610|Clavel cortado seco mini o spray púrpura bicolor|O|O||D||1
10441611|Clavel cortado seco mini o spray púrpura|O|O||D||1
10441612|Clavel cortado seco mini o spray rojo|O|O||D||1
10441613|Clavel cortado seco mini o spray blanco|O|O||D||1
10441614|Clavel cortado seco mini o spray amarillo|O|O||D||1
10451500|Orquidea cypripedium  o pantuflas de dama cortada seca|O|O||D||1
10451501|Orquidea cypripedium cortada seca verde|O|O||D||1
10451502|Orquidea cypripedium cortada seca francia|O|O||D||1
10451503|Orquidea cypripedium cortada seca púrpura rey arturo|O|O||D||1
10451504|Orquidea paphiopedilum cortada seca verde|O|O||D||1
10451505|Orquidea aranthera maggie vie cortada seca|O|O||D||1
10451600|Orquídea mocara cortada seca|O|O||D||1
10451601|Orquídea mocara cortada seca omyai|O|O||D||1
10451602|Orquídea mocara cortada seca roja|O|O||D||1
10451603|Orquídea mocara cortada seca calipso|O|O||D||1
10451604|Orquídea mocara cortada seca nora|O|O||D||1
10451605|Orquídea mocara cortada seca panee|O|O||D||1
10451700|Orquídea catleya cortada seca|O|O||D||1
10451701|Orquídea cattleya cortada seca blanca|O|O||D||1
10451702|Orquídea cattleya cortada seca r b lavanda|O|O||D||1
10451800|Orquídea disa cortada seca|O|O||D||1
10451801|Orquídea disa cortada seca roja|O|O||D||1
10451802|Orquídea disa cortada seca anaranjada|O|O||D||1
10451803|Orquídea disa cortada seca rosada|O|O||D||1
10451804|Orquídea disa cortada seca anaranjada y amarilla bicolor|O|O||D||1
10451805|Orquídea disa cortada seca durazno y amarilla bicolor|O|O||D||1
10451806|Orquídea disa cortada seca amarilla y roja bicolor|O|O||D||1
10451900|Orquídea arachnis cortada seca|O|O||D||1
10451901|Orquídea arachnis cortada seca james storie roja|O|O||D||1
10451902|Orquídea arachnis cortada seca maggie oei roja|O|O||D||1
10451903|Orquídea arachnis cortada seca maggie oei amarilla|O|O||D||1
10451904|Orquídea arachnis cortada seca maroon maggie|O|O||D||1
10451905|Orquídea arachnis cortada seca merry maggie|O|O||D||1
10452000|Orquídea phalaenopsis cortada seca|O|O||D||1
10452001|Orquídea phalaenopsis cortada seca amabilis|O|O||D||1
10452002|Orquídea phalaenopsis cortada seca amboinensis|O|O||D||1
10452003|Orquídea phalaenopsis cortada seca afrodita|O|O||D||1
10452004|Orquídea phalaenopsis cortada seca appendiculata|O|O||D||1
10452005|Orquídea phalaenopsis cortada seca bastianii|O|O||D||1
10452006|Orquídea phalaenopsis cortada seca bellina|O|O||D||1
10452007|Orquídea phalaenopsis cortada seca borneensis|O|O||D||1
10452008|Orquídea phalaenopsis cortada seca braceana|O|O||D||1
10452009|Orquídea phalaenopsis cortada seca buyssoniana|O|O||D||1
10452010|Orquídea phalaenopsis cortada seca celebensis|O|O||D||1
10452011|Orquídea phalaenopsis cortada seca chibae|O|O||D||1
10452012|Orquídea phalaenopsis cortada seca cochlearis|O|O||D||1
10452013|Orquídea phalaenopsis cortada seca corningiana|O|O||D||1
10452014|Orquídea phalaenopsis cortada seca cornu-cervi|O|O||D||1
10452015|Orquídea phalaenopsis cortada seca deliciosa|O|O||D||1
10452016|Orquídea phalaenopsis cortada seca doweryënsis|O|O||D||1
10452017|Orquídea phalaenopsis cortada seca equestris|O|O||D||1
10452018|Orquídea phalaenopsis cortada seca fasciata|O|O||D||1
10452019|Orquídea phalaenopsis cortada seca fimbriata|O|O||D||1
10452020|Orquídea phalaenopsis cortada seca floresensis|O|O||D||1
10452021|Orquídea phalaenopsis cortada seca fuscata|O|O||D||1
10452022|Orquídea phalaenopsis cortada seca gibbosa|O|O||D||1
10452023|Orquídea phalaenopsis cortada seca hainanensis|O|O||D||1
10452024|Orquídea phalaenopsis cortada seca hieroglyphica|O|O||D||1
10452025|Orquídea phalaenopsis cortada seca honghenensis|O|O||D||1
10452026|Orquídea phalaenopsis cortada seca inscriptiosinensis|O|O||D||1
10452027|Orquídea phalaenopsis cortada seca javanica|O|O||D||1
10452028|Orquídea phalaenopsis cortada seca kunstleri|O|O||D||1
10452029|Orquídea phalaenopsis cortada seca lamelligera|O|O||D||1
10452030|Orquídea phalaenopsis cortada seca lindenii|O|O||D||1
10452031|Orquídea phalaenopsis cortada seca lobbii|O|O||D||1
10452032|Orquídea phalaenopsis cortada seca lowii|O|O||D||1
10452033|Orquídea phalaenopsis cortada seca lueddemanniana|O|O||D||1
10452034|Orquídea phalaenopsis cortada seca mambo|O|O||D||1
10452035|Orquídea phalaenopsis cortada seca luteola|O|O||D||1
10452036|Orquídea phalaenopsis cortada seca maculata|O|O||D||1
10452037|Orquídea phalaenopsis cortada seca malipoensis|O|O||D||1
10452038|Orquídea phalaenopsis cortada seca mannii|O|O||D||1
10452039|Orquídea phalaenopsis cortada seca mariae|O|O||D||1
10452040|Orquídea phalaenopsis cortada seca micholitzii|O|O||D||1
10452041|Orquídea phalaenopsis cortada seca modesta|O|O||D||1
10452042|Orquídea phalaenopsis cortada seca mysorensis|O|O||D||1
10452043|Orquídea phalaenopsis cortada seca pallens|O|O||D||1
10452044|Orquídea phalaenopsis cortada seca pantherina|O|O||D||1
10452045|Orquídea phalaenopsis cortada seca parishii|O|O||D||1
10452046|Orquídea phalaenopsis cortada seca petelotii|O|O||D||1
10452047|Orquídea phalaenopsis cortada seca philippinensis|O|O||D||1
10452048|Orquídea phalaenopsis cortada seca pulcherrima|O|O||D||1
10452049|Orquídea phalaenopsis cortada seca pulchra|O|O||D||1
10452050|Orquídea phalaenopsis cortada seca regnieriana|O|O||D||1
10452051|Orquídea phalaenopsis cortada seca reichenbachiana|O|O||D||1
10452052|Orquídea phalaenopsis cortada seca nivacolor|O|O||D||1
10452053|Orquídea phalaenopsis cortada seca sanderiana|O|O||D||1
10452054|Orquídea phalaenopsis cortada seca schilleriana|O|O||D||1
10452055|Orquídea phalaenopsis cortada seca speciosa|O|O||D||1
10452056|Orquídea phalaenopsis cortada seca stobartiana|O|O||D||1
10452057|Orquídea phalaenopsis cortada seca stuartiana|O|O||D||1
10452058|Orquídea phalaenopsis cortada seca sumatrana|O|O||D||1
10452059|Orquídea phalaenopsis cortada seca taenialis|O|O||D||1
10452060|Orquídea phalaenopsis cortada seca tetraspis|O|O||D||1
10452061|Orquídea phalaenopsis cortada seca venosa|O|O||D||1
10452062|Orquídea phalaenopsis cortada seca violácea|O|O||D||1
10452063|Orquídea phalaenopsis cortada seca viridis|O|O||D||1
10452064|Orquídea phalaenopsis cortada seca wilsonii|O|O||D||1
10452065|Orquídea phalaenopsis cortada seca zebrina|O|O||D||1
10452067|Orquídea phalaenopsis cortada seca labio lavanda|O|O||D||1
10452100|Orquídea dendrobium cortada seca|O|O||D||1
10452101|Orquídea dendrobium cortada seca bom|O|O||D||1
10452102|Orquídea dendrobium cortada seca burana|O|O||D||1
10452103|Orquídea dendrobium cortada seca chita|O|O||D||1
10452104|Orquídea dendrobium cortada seca fátima|O|O||D||1
10452105|Orquídea dendrobium cortada seca intuwong|O|O||D||1
10452106|Orquídea dendrobium cortada seca jumbo blanca|O|O||D||1
10452107|Orquídea dendrobium cortada seca kating dang|O|O||D||1
10452108|Orquídea dendrobium cortada seca libertad|O|O||D||1
10452109|Orquídea dendrobium cortada seca hawaii|O|O||D||1
10452110|Orquídea dendrobium cortada seca sakura sweet rosada|O|O||D||1
10452111|Orquídea dendrobium cortada seca sensacional púrpura|O|O||D||1
10452112|Orquídea dendrobium cortada seca blanca|O|O||D||1
10452200|Orquídea cymbidium cortada seca|O|O||D||1
10452201|Orquídea cymbidium cortada seca crema|O|O||D||1
10452202|Orquídea cymbidium cortada seca verde|O|O||D||1
10452203|Orquídea cymbidium cortada seca mini verde|O|O||D||1
10452204|Orquídea cymbidium cortada seca mini rosada|O|O||D||1
10452205|Orquídea cymbidium cortada seca mini roja|O|O||D||1
10452206|Orquídea cymbidium cortada seca mini blanca|O|O||D||1
10452207|Orquídea cymbidium cortada seca mini amarilla|O|O||D||1
10452208|Orquídea cymbidium cortada seca chocolate|O|O||D||1
10452209|Orquídea cymbidium cortada seca rosado oscuro|O|O||D||1
10452210|Orquídea cymbidium cortada seca anaranjada|O|O||D||1
10452211|Orquídea cymbidium cortada seca rosada|O|O||D||1
10452212|Orquídea cymbidium cortada seca blanca|O|O||D||1
10452213|Orquídea cymbidium cortada seca amarilla|O|O||D||1
10452300|Orquídea oncidium cortada seca|O|O||D||1
10452301|Orquídea oncidium cortada seca ducha dorada|O|O||D||1
10452302|Orquídea oncidium cortada seca rhamsey|O|O||D||1
10452400|Orquídea vanda cortada seca|O|O||D||1
10452401|Orquídea vanda alizarin|O|O||D||1
10452402|Orquídea vanda rosada fuerte|O|O||D||1
10452403|Orquídea vanda lavanda|O|O||D||1
10452404|Orquídea vanda púrpura|O|O||D||1
10452405|Orquídea vanda hazme cosquillas rosada|O|O||D||1
10452406|Orquídea vanda amarilla|O|O||D||1
10501500|Aspidistras cortadas frescas|O|O||D||1|Pilistras cortadas frescas
10501501|Aspidistra cortada fresca verde|O|O||D||1|Pilistra cortada fresca verde
10501502|Aspidistra cortada fresca vía láctea|O|O||D||1|Pilistra cortada fresca vía láctea
10501503|Aspidistra cortada fresca variegada|O|O||D||1|Pilistra cortada fresca variegada
10501600|Chili verde cortado fresco|O|O||D||1
10501601|Chili verde cortado fresco avellana|O|O||D||1
10501602|Chili verde cortado fresco romerillo|O|O||D||1
10501603|Chili verde cortado fresco pacarilla|O|O||D||1
10501604|Chili verde cortado fresco musgo|O|O||D||1
10501700|Haya cortada fresca|O|O||D||1
10501701|Haya cortada fresca bronce|O|O||D||1
10501702|Haya cortada fresca verde|O|O||D||1
10501703|Haya cortada fresca rojo|O|O||D||1
10501800|Hojas de eucalipto cortadas prescas|O|O||D||1
10501801|Eucalipto cortado fresco bebé azul|O|O||D||1
10501802|Eucalipto cortado fresco alto bonsai|O|O||D||1
10501803|Eucalipto cortado fresco pluma|O|O||D||1
10501804|Eucalipto cortado fresco gunnii|O|O||D||1
10501805|Eucalipto cortado fresco parvifolia|O|O||D||1
10501806|Eucalipto cortado fresco preservado|O|O||D||1
10501807|Eucalipto cortado fresco sin semilla|O|O||D||1
10501808|Eucalipto cortado fresco sin semilla y sin hojas|O|O||D||1
10501809|Eucalipto cortado fresco sin semillas llorón|O|O||D||1
10501810|Eucalipto cortado fresco dólar de plata|O|O||D||1
10501811|Eucalipto cortado fresco alto espiral|O|O||D||1
10501812|Eucalipto cortado fresco azul verdadero|O|O||D||1
10501813|Eucalipto cortado fresco sauce sin semillas|O|O||D||1
10501900|Helechos cortados frescos|O|O||D||1
10501901|Helecho cortado fresco coontie|O|O||D||1
10501902|Helecho cortado fresco pluma|O|O||D||1
10501903|Helecho cortado fresco plano|O|O||D||1
10501904|Helecho cortado fresco pelo de mujer|O|O||D||1
10501905|Helecho cortado fresco ming|O|O||D||1
10501906|Helecho cortado fresco espada florida alto|O|O||D||1
10501907|Helecho cortado fresco árbol cortado|O|O||D||1
10501908|Helecho cortado fresco sombrilla|O|O||D||1
10502000|Hojas o follajes cortados frescos|O|O||D||1
10502001|Follaje fresco cortado de melaluca australiana|O|O||D||1
10502002|Follaje fresco cortado de lepto azul|O|O||D||1
10502003|Follaje fresco cortado de corylus avellana|O|O||D||1
10502004|Follaje fresco cortado de hosta verde|O|O||D||1
10502005|Follaje fresco cortado de hosta variegada|O|O||D||1
10502006|Follaje fresco cortado de kunzia|O|O||D||1
10502007|Follaje fresco cortado de jade|O|O||D||1
10502008|Follaje fresco cortado de magnolia|O|O||D||1
10502009|Follaje fresco cortado de meyeril o foxtail|O|O||D||1
10502010|Follaje fresco cortado de olivo|O|O||D||1
10502011|Follaje fresco cortado de pistacho|O|O||D||1
10502012|Follaje fresco cortado de ciruelo|O|O||D||1
10502013|Follaje fresco cortado de robellini|O|O||D||1
10502014|Follaje fresco cortado de viburnum|O|O||D||1
10502015|Follaje fresco cortado de xanadu|O|O||D||1
10502016|Follaje fresco cortado de sanderiana|O|O||D||1
10502017|Follaje fresco cortado de gardenia|O|O||D||1
10502100|Pastos costados frescos|O|O||D||1|Pastos ornamentales cortados frescos
10502101|Pasto fresco cortado lirio florida|O|O||D||1|Pasto ornamental cortado fresco lirio florida
10502102|Pasto fresco cortado variegado|O|O||D||1|Pasto ornamental cortado fresco variegado
10502103|Pasto fresco cortado oso|O|O||D||1|Pasto ornamental cortado fresco oso
10502104|Pasto fresco cortado bambú|O|O||D||1|Pasto ornamental cortado fresco bambú
10502105|Pasto fresco cortado caña|O|O||D||1|Pasto ornamental cortado fresco caña
10502106|Pasto fresco cortado descorchador|O|O||D||1|Pasto ornamental cortado fresco descorchador
10502107|Pasto fresco cortado pluma|O|O||D||1|Pasto ornamental cortado fresco pluma
10502108|Pasto fresco cortado flexi|O|O||D||1|Pasto ornamental cortado fresco flexi
10502109|Pasto fresco cortado fuente|O|O||D||1|Pasto ornamental cortado fresco fuente
10502110|Pasto fresco cortado carrizo|O|O||D||1|Pasto ornamental cortado fresco carrizo
10502111|Pasto fresco cortado millet|O|O||D||1|Pasto ornamental cortado fresco millet
10502112|Pasto fresco cortado millet negro|O|O||D||1|Pasto ornamental cortado fresco millet negro
10502113|Pasto fresco cortado milo|O|O||D||1|Pasto ornamental cortado fresco milo
10502114|Pasto fresco cortado avena variegada|O|O||D||1|Pasto ornamental cortado fresco avena variegada
10502115|Pasto fresco cortado phalaris canariensis|O|O||D||1|Pasto ornamental cortado fresco phalaris canariensis
10502116|Pasto fresco cortado ciruela púrpiura|O|O||D||1|Pasto ornamental cortado fresco ciruela púrpura
10502117|Pasto fresco cortado cascabel|O|O||D||1|Pasto ornamental cortado fresco cascabel
10502118|Pasto fresco cortado cinta|O|O||D||1|Pasto ornamental cortado fresco cinta
10502119|Pasto fresco cortado avena marina|O|O||D||1|Pasto ornamental cortado fresco avena marina
10502120|Pasto fresco cortado steelgrass|O|O||D||1|Pasto ornamental cortado fresco steelgrass
10502121|Pasto fresco cortado cebra variegado|O|O||D||1|Pasto ornamental cortado fresco cebra variegado
10502122|Pasto fresco cortado panicum o jungla|O|O||D||1|Pasto ornamental cortado fresco panicum o jungla
10502123|Pasto fresco cortado pampas|O|O||D||1|Pasto ornamental cortado fresco pampas
10502124|Pasto fresco cortado pimienta|O|O||D||1|Pasto ornamental cortado fresco pimienta
10502125|Pasto fresco cortado cebra|O|O||D||1|Pasto ornamental cortado fresco cebra
10502200|mora huckleberry fresca cortada|O|O||D||1|Follajes de arándanos azules frescos
10502201|Mora huckleberry fresca cortada verde|O|O||D||1|Follaje de arándano azul fresco cortado verde
10502202|Mora huckleberry fresca cortada roja|O|O||D||1|Follaje de arándano azul fresco cortado rojo
10502300|Hiedra cortada fresca|O|O||D||1
10502301|Hiedra fresca cortada verde|O|O||D||1
10502302|Hiedra fresca cortada varigada|O|O||D||1
10502303|Hiedra fresca cortada erecta|O|O||D||1
10502304|Hiedra fresca cortada verde de árbol|O|O||D||1
10502305|Hiedra fresca cortada varirgada de árbol|O|O||D||1
10502400|Integrifolia cortada fresca|O|O||D||1
10502401|Integrifolia fresca cortada roja|O|O||D||1
10502402|Integrifolia fresca cortada natural|O|O||D||1
10502500|Mirto cortado fresco|O|O||D||1|Follajes de mirtillos
10502501|Mirto fresco cortado enano|O|O||D||1|Follaje de mirtillo fresco cortado enano
10502502|Mirto fresco cortado variegado|O|O||D||1|Follaje de mirtillo fresco cortado variegado
10502600|Hojas frescas cortadas de roble|O|O||D||1
10502601|Hojas frescas cortadas de roble rojo de holanda|O|O||D||1
10502700|Oregonia fresca cortada|O|O||D||1
10502701|Oregonia fresca cortada verde|O|O||D||1
10502702|Oregonia fresca cortada plateada|O|O||D||1
10502703|Oregonia fresca cortada variegada|O|O||D||1
10502800|pittosporum fresco cortado|O|O||D||1
10502801|Pittosporum fresco cortado verde|O|O||D||1
10502802|Pittosporum fresco cortado nevatus|O|O||D||1
10502803|Pittosporum fresco cortado nueva zelandia|O|O||D||1
10502804|Pittosporum fresco cortado nigra|O|O||D||1
10502805|Pittosporum fresco cortado variegado|O|O||D||1
10502900|Hojas frescas cortadas de especies sencillas|O|O||D||1
10502901|Acanto o cordone fresca cortada|O|O||D||1
10502902|Pluma de acacia púrpura fresca cortada|O|O||D||1
10502903|Adina rubella fresca cortada|O|O||D||1
10502904|Agonis flexuosa fresca cortada|O|O||D||1
10502905|Azara dentata fresca cortada|O|O||D||1
10502906|Arbusto barker fresca cortada|O|O||D||1
10502907|Corona de laurel fresca cortada|O|O||D||1
10502908|Llama azul fresca cortada|O|O||D||1
10502909|Buxus africana fresca cortada|O|O||D||1
10502910|Laurel fresca cortada|O|O||D||1
10502911|Hoja de camelia fresca cortada|O|O||D||1
10502912|Cedro dorado de nueva zelandia fresca cortada|O|O||D||1
10502913|Ceratopetalum de nueva zelandia fresca cortada|O|O||D||1
10502914|Choisya ternata fresca cortada|O|O||D||1
10502915|Cocculus fresca cortada|O|O||D||1
10502916|Croto fresca cortada|O|O||D||1
10502917|Datura fresca cortada|O|O||D||1
10502918|Dusty miller fresca cortada|O|O||D||1
10502919|Elegia capensis fresca cortada|O|O||D||1
10502920|Hoja de euonymous fresca cortada|O|O||D||1
10502921|Hoja de lino fresca cortada|O|O||D||1
10502922|Hoja de galax fresca cortada|O|O||D||1
10502923|Hoja de oro fresca cortada|O|O||D||1
10502924|Hoja de gravillea fresca cortada|O|O||D||1
10502925|Hoja de pasto cola de caballo o culebra fresca cortada|O|O||D||1
10502926|Acacia hoja de navaja fresca cortada|O|O||D||1
10502927|Hoja de laurel fresca cortada|O|O||D||1
10502928|Hoja de cuero fresca cortada|O|O||D||1
10502929|Hoja de ligularia fresca cortada|O|O||D||1
10502930|Hoja de ligularia  argentea fresca cortada|O|O||D||1
10502931|Lophomyrtus fresca cortada|O|O||D||1
10502932|Lycopodium  o pino princresa fresca cortada|O|O||D||1
10502933|Mahonia aquifolium fresca cortada|O|O||D||1
10502934|Hoja de nagi fresca cortada|O|O||D||1
10502935|Palma de abanico palmetto fresca cortada|O|O||D||1
10502936|Papyrus umbrella florida fresca cortada|O|O||D||1
10502937|Pennycress fresca cortada|O|O||D||1
10502938|Photinia robin rojo fresca cortada|O|O||D||1
10502939|Diablo de nueve cortezas o physocarpus fresca cortada|O|O||D||1
10502940|Pimelea nivea fresca cortada|O|O||D||1
10502941|Hoja de pistacho fresca cortada|O|O||D||1
10502942|Plumosa fresca cortada|O|O||D||1
10502943|Podocarpus fresca cortada|O|O||D||1
10502944|Pokeweed fresca cortada|O|O||D||1
10502945|Photinia  de punta roja fresca cortada|O|O||D||1
10502946|Rhamnus o buckthorn variegada fresca cortada|O|O||D||1
10502947|Rododendro en flor fresca cortada|O|O||D||1
10502948|Hoja de rosio fresca cortada|O|O||D||1
10502949|Ruscus florida largo fresca cortada|O|O||D||1
10502950|Ruscus italiana fresca cortada|O|O||D||1
10502951|Salal u hoja de limón fresca cortada|O|O||D||1
10502952|Ruscifolia sarcococca fresca cortada|O|O||D||1
10502953|Cheflera fresca cortada|O|O||D||1
10502954|Avena de mar uniola latifolia fresca cortada|O|O||D||1
10502955|Tomillo plateado fresca cortada|O|O||D||1
10502956|Skimmia fresca cortada|O|O||D||1
10502957|Springeri fresca cortada|O|O||D||1
10502958|Tulepods fresca cortada|O|O||D||1
10502959|Weigelia fresca cortada|O|O||D||1
11101500|Minerales|O|O||D||1
11101501|Mica|O|O||D||1
11101502|Lija o esmeril|O|O||D||1|Esmeril mineral
11101503|Cuarzo|O|O||D||1|Óxido de silicio
11101504|Pirita|O|O||D||1|Disulfuro de hierro
11101505|Azufre o sulfuro|O|O||D||1
11101506|Tiza|O|O||D||1|Barra de yeso, Creta, Gi
11101507|Grafito|O|O||D||1
11101508|Dolomita|O|O||D||1|Caliza de magnesio
11101509|Magnesita|O|O||D||1|Giobertita
11101510|Asbesto (amianto)|O|O||D||1
11101511|Calcio|O|O||D||1
11101512|Borato|O|O||D||1
11101513|Criolita|O|O||D||1|Hexafluoroaluminato de sodio
11101514|Feldespato|O|O||D||1
11101515|Leucita|O|O||D||1
11101516|Nefelita|O|O||D||1|Nefelina
11101517|Esteatita|O|O||D||1|Piedra jabón
11101518|Talco|O|O||D||1
11101519|Diamante en bruto|O|O||D||1
11101520|Granates|O|O||D||1
11101521|Carburo de silicio|O|O||D||1|Carborundio, Carborundo
11101522|Carbón activado|O|O||D||1|Carbón activo
11101523|Mulita|O|O||D||1|Porcelainita, Porcelanita
11101524|Fluorita|O|O||D||1|Espato flúor, Fluorina
11101525|Kieserita|O|O||D||1
11101526|Carnalita|O|O||D||1|Cornalina
11101527|Sílice de diatomeas|O|O||D||1|Tierra de diatomeas
11101528|Óxido de aluminio activado|O|O||D||1
11101529|Zeolita|O|O||D||1
11101530|Calcita|O|O||D||1
11101531|Serpentina|O|O||D||1|Serpentina (mineral)
11101532|Peridoto|O|O||D||1|Crisolito, Olivino
11101533|Pirofilita|O|O||D||1
11101534|Diamante pulido|O|O||D||1
11101600|Minerales metálicos|O|O||D||1
11101601|Mineral de hierro|O|O||D||1|Mena de hierro
11101602|Mineral de titanio|O|O||D||1|Mena de titanio
11101603|Mineral de uranio|O|O||D||1|Mena de uranio
11101604|Mineral de cobre|O|O||D||1|Mena de cobre
11101605|Mineral de aluminio|O|O||D||1|Mena de aluminio
11101606|Mineral de níquel|O|O||D||1|Mena de níquel
11101607|Mineral de plata|O|O||D||1|Mena de plata
11101608|Mineral de plomo|O|O||D||1|Mena de plomo
11101609|Mineral de zinc|O|O||D||1|Mena de zinc
11101610|Mineral de estaño|O|O||D||1|Mena de estaño
11101611|Mineral de manganeso|O|O||D||1|Mena de manganeso
11101612|Mineral de cromo|O|O||D||1|Mena de cromo
11101613|Mineral de tungsteno o wolframio|O|O||D||1|Mena de tungsteno o wolframio
11101614|Mineral de molibdeno|O|O||D||1|Mena de molibdeno
11101615|Mineral de cobalto|O|O||D||1|Mena de cobalto
11101616|Mineral de oro|O|O||D||1|Mena de oro
11101617|Mineral de tántalo|O|O||D||1|Mena de tántalo
11101618|Mineral de platino|O|O||D||1|Mena de platino
11101619|Mineral de vermiculita|O|O||D||1|Mena de vermiculita
11101620|Mineral de torio|O|O||D||1|Mena de torio
11101621|Mineral de cianita|O|O||D||1|Mena de cianita
11101622|Mineral de antimonio|O|O||D||1|Mena de antimonio
11101623|Mineral de zirconio|O|O||D||1|Mena de zirconio
11101624|Mineral de magnetita|O|O||D||1|Mena de magnetita
11101625|Mineral de bauxita|O|O||D||1|Mena de bauxita
11101700|Metales de Base|O|O||D||1
11101701|Escoria o ceniza|O|O||D||1
11101702|Grafito natural|O|O||D||1
11101704|Acero|O|O||D||1
11101705|Aluminio|O|O||D||1
11101706|Níquel|O|O||D||1
11101708|Bismuto|O|O||D||1
11101709|Antimonio|O|O||D||1
11101710|Cadmio|O|O||D||1
11101711|Aleación no ferrosa|O|O||D||1
11101712|Aleación ferrosa|O|O||D||1
11101713|Hierro|O|O||D||1
11101714|Plomo|O|O||D||1
11101716|Estaño|O|O||D||1
11101717|Indio|O|O||D||1|Indio (metal)
11101718|Paladio|O|O||D||1
11101719|Zinc|O|O||D||1
11101800|Metales preciosos|O|O||D||1
11101801|Oro|O|O||D||1
11101802|Plata|O|O||D||1
11101803|Platino|O|O||D||1
11101900|Productos minerales intermedios, procesados y refinados|O|O||D||1
11101901|Concentrado de mineral de hierro|O|O||D||1|Mineral de hierro desmenuzado
11101902|Concentrado de níquel|O|O||D||1
11101903|Briqueta o compacto de níquel|O|O||D||1
11101904|Mate de níquel|O|O||D||1|Níquel mate
11101905|Aluminio liquido|O|O||D||1
11101906|Concentrado de cobre|O|O||D||1
11101907|Cátodo de cobre|O|O||D||1
11101908|Sínter o perdigones de manganeso|O|O||D||1|Toba de manganeso
11111500|Barro y Tierra|O|O||D||1
11111501|Tierra|O|O||D||1
11111502|Material de relleno|O|O||D||1|Tierra para relleno
11111503|Capa vegetal|O|O||D||1|Suelo orgánico
11111504|Tierra de cristal|O|O||D||1|Tierra de hidrogel
11111505|Suelo artificial|O|O||D||1
11111600|Piedra|O|O||D||1
11111601|Yeso|O|O||D||1|Piedra de yeso
11111602|Travertino|O|O||D||1
11111603|Alabastro|O|O||D||1
11111604|Granito|O|O||D||1
11111605|Mármol|O|O||D||1
11111606|Pizarra|O|O||D||1|Roca de pizarra
11111607|Arenisca|O|O||D||1|Psamita
11111608|Caliza|O|O||D||1
11111609|Basalto|O|O||D||1
11111610|Piedra pómez|O|O||D||1|Liparita, Pumita
11111611|Gravilla|O|O||D||1|Grava
11111612|Caliza en polvo|O|O||D||1|Polvo de piedra caliza o polvo de mina de roca
11111613|Wollastonita|O|O||D||1
11111700|Arena|O|O||D||1
11111701|Arena de sílice|O|O||D||1|Arena sílice
11111800|Arcillas|O|O||D||1
11111801|Terracota|O|O||D||1
11111802|Arcilla refractaria|O|O||D||1
11111803|Caolín u otras arcillas caolínicas|O|O||D||1|Caolinita
11111804|Bentonita|O|O||D||1|Arcilla montmorillonita, Arena sanitaria para gatos
11111805|Andalucita|O|O||D||1
11111806|Mullita|O|O||D||1
11111807|Chamota|O|O||D||1|Cerámica triturada, Grancilla terracota
11111808|Arcilla común|O|O||D||1
11111809|Arcilla de bola|O|O||D||1
11111810|Tierra de fuller|O|O||D||1|Tierra de batan
11111811|Haydita|O|O||D||1|Arcilla expandida
11111812|Vermiculita|O|O||D||1
11121500|Savia|O|O||D||1
11121502|Resina|O|O||D||1
11121503|Laca|O|O||D||1
11121600|Madera|O|O||D||1
11121603|Troncos|O|O||D||1
11121604|Madera blanda|O|O||D||1
11121605|Ratán|O|O||D||1
11121606|Corcho|O|O||D||1
11121607|Pulpa de madera|O|O||D||1
11121608|Bambú|O|O||D||1
11121610|Maderas duras|O|O||D||1
11121612|Médula de madera|O|O||D||1
11121614|Madera de teca|O|O||D||1
11121615|Madera de álamo|O|O||D||1
11121616|Madera de pino|O|O||D||1
11121617|Madera de roble|O|O||D||1
11121618|Madera de arce|O|O||D||1
11121619|Madera de cerezo|O|O||D||1
11121620|Madera de tornillo|O|O||D||1
11121700|Productos secundarios de la explotación forestal|O|O||D||1
11121701|Aserrín|O|O||D||1|Viruta de madera
11121702|Astillas de madera|O|O||D||1
11121703|Musgo de turba|O|O||D||1|Esfagno, Musgo de turbera
11121705|Corteza|O|O||D||1
11121706|Composta de madera|O|O||D||1
11121707|Viruta de madera|O|O||D||1
11121708|Harina de madera|O|O||D||1
11121709|Bálsamos|O|O||D||1
11121710|Brea de madera|O|O||D||1|Alquitrán de madera
11121800|Fibras de plantas|O|O||D||1
11121801|Cáñamo|O|O||D||1
11121802|Algodón|O|O||D||1
11121803|Lino|O|O||D||1
11121804|Yute|O|O||D||1
11121805|Sisal|O|O||D||1|Fibra de maguey, Henequén de agave
11121806|Fibra de coco|O|O||D||1
11121807|Fibras de abacá|O|O||D||1|Cáñamo de manila
11121808|Ramio|O|O||D||1
11121809|Paja|O|O||D||1
11121810|Mijo común o ixtle o piasava|O|O||D||1
11121900|Productos de perfumería|O|O||D||1
11121901|Raíz de regaliz|O|O||D||1
11122000|Productos de madera diseñados|O|O||D||1
11122001|Triplex|O|O||D||1|Madera contrachapada, Triplay
11122002|Tablex|O|O||D||1|Tablero aglomerados
11122003|Corrugado|O|O||D||1|Fibra de madera de densidad media
11122004|Enchapes de madera|O|O||D||1
11122005|Madera laminada engomada|O|O||D||1|Madera laminada encolada
11122006|Madera tratada|O|O||D||1
11131500|Cuero, pieles o materiales textiles de animales|O|O||D||1
11131501|Plumas|O|O||D||1|Plumas de animales
11131502|Pieles|O|O||D||1
11131503|Pelo animal|O|O||D||1
11131504|Cueros|O|O||D||1
11131505|Mohair sin procesar|O|O||D||1|Pelo de cabra de angora sin procesar
11131506|Lana sin procesar|O|O||D||1
11131507|Gamuza|O|O||D||1
11131508|Cuero de grano completo|O|O||D||1
11131600|Otros productos de animales|O|O||D||1
11131602|Semen|O|O||D||1|Semen animal
11131603|Excreciones|O|O||D||1|Abono orgánico para tierra, Excreciones animales
11131604|Huevas de pescado|O|O||D||1
11131605|Huesos|O|O||D||1
11131607|Embriones|O|O||D||1
11131608|Artículos de concha|O|O||D||1
11141600|Desechos no metálicos y chatarra|O|O||D||1|Productos reciclables
11141601|Desecho o desperdicio textil|O|O||D||1|Productos textiles
11141602|Desecho o desperdicio plástico|O|O||D||1|Productos plásticos
11141603|Desechos de aceite|O|O||D||1|Productos de aceite
11141604|Desechos de papel|O|O||D||1|Productos de papel
11141605|Desecho o desperdicios de vidrio|O|O||D||1|Productos de vidrio
11141606|Desecho o desperdicios de madera|O|O||D||1|Productos de madera
11141607|Desecho o desperdicios de caucho|O|O||D||1|Productos de caucho
11141608|Desecho o desperdicios peligrosos|O|O||D||1
11141609|Composición de cuero|O|O||D||1|Productos compuestos de cuero
11141610|Desecho o desperdicios de cuero|O|O||D||1|Productos de cuero
11141700|Desperdicios o restos de alimentos y tabaco|O|O||D||1
11141701|Desecho o desperdicios de alimentos|O|O||D||1
11141702|Desecho o desperdicios de tabaco|O|O||D||1
11151500|Fibras|O|O||D||1
11151501|Fibras de acetato|O|O||D||1|Fibras de acetato de celulosa
11151502|Fibras de nylon|O|O||D||1
11151503|Fibras de poliéster|O|O||D||1
11151504|Fibras de acrílico|O|O||D||1
11151505|Fibras de viscosas|O|O||D||1
11151506|Fibras de rayón|O|O||D||1
11151507|Fibras de algodón|O|O||D||1
11151508|Fibras de lana|O|O||D||1
11151509|Fibras de seda|O|O||D||1
11151510|Fibras vegetales|O|O||D||1
11151511|Fibras de polipropileno|O|O||D||1
11151512|Fibras de vidrio|O|O||D||1
11151513|Fibras cerámicas|O|O||D||1
11151514|Fibras de polímero de aramida|O|O||D||1
11151515|Fibras de asbesto|O|O||D||1
11151516|Fibras de poliuretano o spándex|O|O||D||1|Fibra de licra
11151517|Fibras de alcohol polivinilo|O|O||D||1|Fibras de alcohol polivinílico
11151518|Fibras de polietileno|O|O||D||1
11151519|Fibras de lana de roca o lana mineral|O|O||D||1
11151600|Hebras|O|O||D||1
11151601|Hebra de algodón|O|O||D||1
11151602|Hebra de seda|O|O||D||1
11151603|Hebra de poliéster|O|O||D||1
11151604|Hebra de poliamida|O|O||D||1
11151605|Hebra de bismaleimida|O|O||D||1
11151606|Hebra de fibra de vidrio|O|O||D||1
11151607|Hebra de grafito|O|O||D||1
11151608|Hebra de nylon|O|O||D||1
11151609|Hebra de resina impregnada|O|O||D||1
11151610|Hebra de caucho o látex|O|O||D||1
11151611|Hebra de spandex|O|O||D||1
11151612|Hebra de asbesto|O|O||D||1
11151700|Hilos|O|O||D||1
11151701|Hilado de lana|O|O||D||1|Hilo de lana
11151702|Hilado de algodón|O|O||D||1|Hilo de algodón
11151703|Hilado de poliéster|O|O||D||1|Hilo de poliéster
11151704|Hilado de acrílico|O|O||D||1|Hilo de acrílico
11151705|Hilado de seda|O|O||D||1|Hilo de seda
11151706|Hilado de ramie|O|O||D||1|Hilo de ramio
11151708|Hilado de pelo animal|O|O||D||1|Hilo de pelo animal
11151709|Hilado de sintético|O|O||D||1|Hilo de sintético
11151710|Hilado de yute|O|O||D||1|Hilo de yute
11151711|Hilado de fibra de coco|O|O||D||1|Hilo de fibra de coco
11151712|Hilado de papel|O|O||D||1|Hilo de papel
11151713|Hilado de cáñamo|O|O||D||1|Hilo cáñamo
11151714|Hilado de vidrio|O|O||D||1|Hilo de vidrio
11151715|Hilado de lino|O|O||D||1|Hilo de lino
11151716|Hilado mezclado|O|O||D||1|Hilo mezclado
11161500|Tejidos de seda|O|O||D||1
11161501|Textiles de seda de tejido simple|O|O||D||1|Textiles de seda de tejido sencillo
11161502|Textiles de seda de tejido  jacquard|O|O||D||1
11161503|Textiles de lana|O|O||D||1
11161504|Textiles de tejido de pana|O|O||D||1
11161600|Tejidos de lana|O|O||D||1
11161601|Tejidos de lana en tafetán|O|O||D||1
11161602|Tejidos de lana urdidos a la jacquard|O|O||D||1
11161603|Tejidos de lana de punto|O|O||D||1
11161604|Tejidos de lana de ligamento de sarga|O|O||D||1
11161700|Tejidos de algodón|O|O||D||1
11161701|Textiles de algodón de tejido simple|O|O||D||1
11161702|Textiles de algodón de tejido de pana|O|O||D||1|Textiles de algodón de tejido sarga
11161703|Tela de algodón oxford|O|O||D||1
11161704|Textiles de algodón tejido|O|O||D||1|Textiles de punto de algodón
11161705|Textiles de terciopelo de algodón|O|O||D||1
11161800|Tejidos sintéticos|O|O||D||1
11161801|Textil sintético de tejido sintético|O|O||D||1
11161802|Textil sintético de tejido jacquard|O|O||D||1
11161803|Textil sintético de tejido dobby|O|O||D||1
11161804|Textil sintético tejido|O|O||D||1
11161805|Textil sintético de terciopelo|O|O||D||1
11161806|Textil sintético de tejido de pana|O|O||D||1
11161807|Textil sintético de felpa|O|O||D||1
11162000|Tejidos de materiales vegetales no de algodón|O|O||D||1
11162001|Textil de fibra vegetal tejida distinta de algodón simple|O|O||D||1
11162002|Textil de fibra vegetal tejida distinta de algodón|O|O||D||1
11162003|Tela de arpillera o cáñamo o yute|O|O||D||1
11162100|Tejidos o telas especiales|O|O||D||1
11162101|Tela o textil de queso|O|O||D||1
11162102|Tela o textil de bismaleimida|O|O||D||1
11162104|Tela o textil de grafito|O|O||D||1
11162105|Tela o textil de vidrio|O|O||D||1
11162107|Tela de resina impregnada|O|O||D||1
11162108|Tela malla de alambre|O|O||D||1
11162109|Encaje|O|O||D||1
11162110|Malla red|O|O||D||1
11162111|Malla|O|O||D||1
11162112|Telas revestidas|O|O||D||1
11162113|Telas para tapicería|O|O||D||1
11162114|Telas o cintas de sujeción por contacto|O|O||D||1
11162115|Trenza elástica|O|O||D||1
11162116|Tela de fique o estopa|O|O||D||1
11162117|Tela de caucho|O|O||D||1
11162118|Tela de hilado de papel|O|O||D||1|Tela de hilo de papel
11162119|Tela de calcado|O|O||D||1
11162120|Tela de cernido|O|O||D||1
11162121|Artículos de pasamanería y ornamentales|O|O||D||1
11162122|Tela de sujeción|O|O||D||1
11162123|Tela de cinta|O|O||D||1|Listón
11162124|Tela de fieltro|O|O||D||1
11162125|Tela de correas|O|O||D||1
11162126|Tela acolchada|O|O||D||1
11162127|Tela de camuflaje|O|O||D||1
11162128|Tela de paracaídas|O|O||D||1
11162129|Tela marquisette|O|O||D||1
11162130|Tela dosel|O|O||D||1
11162131|Tela para ribeteado|O|O||D||1
11162132|Tela de damasco|O|O||D||1
11162133|Tela de satín|O|O||D||1
11162200|Telas no tejidas|O|O||D||1
11162201|Telas no tejidas ligadas térmicamente|O|O||D||1
11162202|Telas no tejidas hidroentrelazadas|O|O||D||1|Materiales no tejidos entrelazados en hiladura
11162300|Cueros|O|O||D||1
11162301|Cuero de gamuza|O|O||D||1
11162302|Cuero de cabra|O|O||D||1
11162303|Cuero de oveja|O|O||D||1
11162304|Cuero acharolado|O|O||D||1
11162305|Cuero de vaca|O|O||D||1
11162306|Cuero de cerdo|O|O||D||1|Cuero de chanchos, Cuero de cochinillos, Cuero de cochinos, Cuero de cuche, Cuero de cuinos, Cuero de gorrinos, Cuero de lechones, Cuero de marranos, Cuero de porcinos, Cuero de puercos,Cuero de lechones
11162307|Cuero sintético o de imitación|O|O||D||1
11162308|Cuero de búfalo|O|O||D||1
11162309|Cuero de reptil|O|O||D||1
11162310|Cuero de caballo|O|O||D||1
11162311|Cuero de becerro|O|O||D||1|Cuero de ternera
11162400|Guata|O|O||D||1
11162401|Guata de algodón|O|O||D||1
11162402|Guata sintética|O|O||D||1
11171500|Aceros básicos|O|O||D||1
11171501|Acero e24-2 o a37-2|O|O||D||1
11171600|Aleaciones de acero inoxidable|O|O||D||1
11171601|Aleación de acero inoxidable 304|O|O||D||1
11171602|Aleación de acero inoxidable 304i|O|O||D||1
11171603|Aleación de acero inoxidable 316|O|O||D||1
11171604|Aleación de ferroníquel|O|O||D||1
11171700|Aceros rápidos|O|O||D||1
11171701|Acero de alta velocidad z90wdcv6542 o m2|O|O||D||1
11171702|Acero de alta velocidad z90wdkcv65542 or m35|O|O||D||1|Acero de alta velocidad Z90WDKCV65542 o M35
11171800|Superaleaciones de níquel|O|O||D||1
11171801|Súper aleación inconel 600|O|O||D||1
11171900|Superaleaciones de titanio|O|O||D||1
11171901|Súper aleación ta6v|O|O||D||1
11172000|Aleaciones de aluminio|O|O||D||1
11172001|Aleación de aluminio 7178|O|O||D||1
11172002|Aluminio refundido|O|O||D||1|Refundición de aluminio
11172003|Aleación de hierro y aluminio|O|O||D||1
11172100|Superaleaciones de cobalto|O|O||D||1
11172101|Aleación pigmalión ú 846|O|O||D||1|Aleación pigmalión o 846
11172200|Aleaciones con base de magnesio|O|O||D||1
11172201|Aleación de aluminio y manganeso|O|O||D||1
11172300|Aleaciones con base de manganeso|O|O||D||1
11172301|Aleación de ferro manganeso|O|O||D||1
11172302|Aleación de ferro manganeso carbono medio|O|O||D||1|Aleación de ferro-manganeso de media emisión de carbono
11172303|Aleación de silicona manganeso|O|O||D||1|Aleación de manganeso de silicio
11172304|Aleación de ferro manganeso carbono bajo|O|O||D||1|Aleación de ferro-manganeso de baja emisión de carbono
11181500|Óxidos metálicos no férreos|O|O||D||1
11181501|Óxido de molibdeno|O|O||D||1
11181502|Óxido de titanio|O|O||D||1
11181503|Óxido de indio|O|O||D||1
11181504|Óxido de estaño|O|O||D||1
11181505|Arcilla de sellado|O|O||D||1
11181506|Óxido de vanadio|O|O||D||1
11181507|Óxido de níquel|O|O||D||1
11181508|Óxido de manganeso|O|O||D||1
11191500|Cuerpos sólidos de metal|O|O||D||1
11191501|Sólidos de níquel|O|O||D||1
11191502|Sólidos de acero básico|O|O||D||1
11191503|Sólidos de aleación ferrosa|O|O||D||1
11191504|Sólidos de aleación no ferrosa|O|O||D||1
11191505|Sólidos de súper aleación|O|O||D||1
11191600|Chatarra|O|O||D||1
11191601|Chatarra de níquel|O|O||D||1
11191602|Chatarra de acero básico|O|O||D||1
11191603|Chatarra de aleación ferrosa|O|O||D||1
11191604|Chatarra de aleación no ferrosa|O|O||D||1
11191605|Chatarra de súper aleación|O|O||D||1
11191606|Destrozos automovilísticos para chatarra o desecho|O|O||D||1|Demolición o desguace de automóviles para los residuos o desechos
11191607|Chatarra de cobre|O|O||D||1
11191608|Chatarra de plomo|O|O||D||1
11191609|Chatarra de zinc|O|O||D||1
11191610|Chatarra de aluminio|O|O||D||1
11191611|Chatarra de estaño|O|O||D||1
11191700|Virutas|O|O||D||1
11191701|Torneados (virutas) de níquel|O|O||D||1|Virutas de níquel
11191702|Torneados (virutas) de bronce|O|O||D||1|Virutas de bronce
11191800|Subproductos del metal|O|O||D||1
11191801|Escoria de manganeso|O|O||D||1|Desecho de manganeso
11191802|Sulfuro de cobre|O|O||D||1
11191803|Sulfuro de níquel|O|O||D||1
12131500|Explosivos|O|O||D||1
12131501|Dinamita|O|O||D||1
12131502|Cartuchos explosivos|O|O||D||1
12131503|Explosivos propelentes|O|O||D||1
12131504|Cargas explosivas|O|O||D||1
12131505|Explosivos plásticos|O|O||D||1
12131506|Explosivos aluminizados|O|O||D||1
12131507|Explosivos de nitrato de amonio|O|O||D||1
12131508|Explosivos de polvo de nitroglicerina|O|O||D||1
12131509|Nitrato de amonio y fuel oil - anfo|O|O||D||1
12131600|Pirotecnia|O|O||D||1
12131601|Fuegos artificiales|O|O||D||1
12131602|Señales de niebla|O|O||D||1
12131603|Cohetes de lluvia|O|O||D||1
12131604|Antorchas|O|O||D||1
12131605|Materiales pirotécnicos para el teatro o la televisión|O|O||D||1
12131700|Encendedores|O|O||D||1
12131701|Estopines|O|O||D||1
12131702|Detonadores|O|O||D||1
12131703|Mechas explosivas|O|O||D||1
12131704|Iniciadores explosivos|O|O||D||1
12131705|Fulminantes explosivos|O|O||D||1
12131706|Fósforos|O|O||D||1
12131707|Encendedores|O|O||D||1
12131708|Caja detonadora|O|O||D||1
12131709|Apisonadores de explosivos|O|O||D||1
12131800|Propulsores|O|O||D||1
12131801|Propelente en polvo|O|O||D||1|Propulsores en polvo
12131802|Propelente sólido|O|O||D||1|Propulsores sólido
12131803|Propelente de pistola|O|O||D||1|Propulsores de pistola
12131804|Propelente de alta energía|O|O||D||1|Propulsores de alta energía
12131805|Propelente en gel|O|O||D||1|Propulsores en gel
12131806|Propelente híbridos|O|O||D||1|Propulsores híbridos
12141500|Metales de tierra|O|O||D||1
12141501|Berilio be|O|O||D||1
12141502|Magnesio mg|O|O||D||1
12141503|Calcio ca|O|O||D||1
12141504|Estroncio sr|O|O||D||1
12141505|Bario ba|O|O||D||1
12141506|Radio ra|O|O||D||1
12141600|Metales de tierra rara|O|O||D||1
12141601|Cerio ce|O|O||D||1
12141602|Disprosio dy|O|O||D||1
12141603|Erbio er|O|O||D||1
12141604|Europio eu|O|O||D||1
12141605|Gadolinio gd|O|O||D||1
12141606|Holmio ho|O|O||D||1
12141607|Lantano la|O|O||D||1
12141608|Lutecio lu|O|O||D||1
12141609|Neodimio nd|O|O||D||1
12141610|Praseodimio pr|O|O||D||1
12141611|Promecio pm|O|O||D||1
12141612|Samario sm|O|O||D||1
12141613|Escandio sc|O|O||D||1
12141614|Terbio tb|O|O||D||1
12141615|Tulio tm|O|O||D||1
12141616|Iterbio yb|O|O||D||1
12141617|Itrio y|O|O||D||1
12141700|Metales de transición|O|O||D||1
12141701|Actinio ac|O|O||D||1
12141702|Aluminio al|O|O||D||1
12141703|Americio am|O|O||D||1
12141704|Antimonio sb|O|O||D||1
12141705|Berkelio bk|O|O||D||1
12141706|Bismuto bi|O|O||D||1
12141707|Cadmio ca|O|O||D||1
12141708|Californio cf|O|O||D||1
12141709|Cromo cr|O|O||D||1
12141710|Cobalto co|O|O||D||1
12141711|Cobre cu|O|O||D||1
12141712|Curio cm|O|O||D||1
12141713|Einstenio es|O|O||D||1
12141714|Fermio fm|O|O||D||1
12141715|Galio ga|O|O||D||1
12141716|Germanio ge|O|O||D||1
12141717|Oro au|O|O||D||1
12141718|Hafnio hf|O|O||D||1
12141719|Indio in|O|O||D||1
12141720|Iridio ir|O|O||D||1
12141721|Hierro fe|O|O||D||1
12141722|Lawrencio lr|O|O||D||1
12141723|Plomo pb|O|O||D||1
12141724|Manganeso mn|O|O||D||1
12141725|Mendelevio md|O|O||D||1
12141726|Mercurio hg|O|O||D||1
12141727|Molibdeno mo|O|O||D||1
12141728|Neptunio np|O|O||D||1
12141729|Níquel ni|O|O||D||1
12141730|Niobio nb|O|O||D||1
12141731|Nobelio no|O|O||D||1
12141732|Osmio os|O|O||D||1
12141733|Paladio pd|O|O||D||1
12141734|Platino pyt|O|O||D||1
12141735|Plutonio pu|O|O||D||1
12141736|Protactinio pa|O|O||D||1
12141737|Renio re|O|O||D||1
12141738|Rodio rh|O|O||D||1
12141739|Rutenio ru|O|O||D||1
12141740|Plata ag|O|O||D||1
12141741|Tántalo ta|O|O||D||1
12141742|Tecnecio te|O|O||D||1
12141743|Talio tl|O|O||D||1
12141744|Torio th|O|O||D||1
12141745|Estaño sn|O|O||D||1
12141746|Titanio ti|O|O||D||1
12141747|Tungsteno w|O|O||D||1
12141748|Uranio u|O|O||D||1
12141749|Vanadio v|O|O||D||1
12141750|Zinc zn|O|O||D||1
12141751|Zirconio zr|O|O||D||1
12141752|Bohrio bh|O|O||D||1
12141753|Dubnio db|O|O||D||1
12141754|Hassio hs|O|O||D||1
12141755|Rutherfordio rf|O|O||D||1
12141756|Seaborgio sg|O|O||D||1
12141757|Ununnilium uum|O|O||D||1
12141758|Unununium uuu|O|O||D||1
12141759|Ununbium uub|O|O||D||1
12141760|Polonio po|O|O||D||1
12141800|Metales álcalis|O|O||D||1
12141801|Cesio cs|O|O||D||1
12141802|Francio fm|O|O||D||1
12141803|Litio li|O|O||D||1
12141804|Potasio k|O|O||D||1
12141805|Rubidio rb|O|O||D||1
12141806|Sodio na|O|O||D||1
12141900|No-metales y gases elementales y puros|O|O||D||1
12141901|Cloro cl|O|O||D||1
12141902|Hidrógeno h|O|O||D||1
12141903|Nitrógeno n|O|O||D||1
12141904|Oxígeno o|O|O||D||1
12141905|Flúor f|O|O||D||1
12141906|Arsénico as|O|O||D||1
12141907|Boro b|O|O||D||1
12141908|Carbono c|O|O||D||1
12141909|Fósforo p|O|O||D||1
12141910|Selenio se|O|O||D||1
12141911|Silicona si|O|O||D||1
12141912|Azufre s|O|O||D||1
12141913|Telurio te|O|O||D||1
12141914|Astato at|O|O||D||1
12141915|Bromo br|O|O||D||1
12141916|Yodo i|O|O||D||1
12142000|Gases nobles|O|O||D||1
12142001|Gas xenón xe|O|O||D||1
12142002|Gas radón rn|O|O||D||1
12142003|Gas criptón kr|O|O||D||1
12142004|Gas argón ar|O|O||D||1
12142005|Gas helio he|O|O||D||1
12142006|Gas neón ne|O|O||D||1
12142100|Gases naturales y gases mixtos|O|O||D||1
12142101|Gases compuestos de hidrógeno|O|O||D||1
12142102|Gases compuestos clorados|O|O||D||1
12142103|Amoniaco|O|O||D||1
12142104|Gas dióxido de carbono|O|O||D||1|Anhídrido carbónico
12142105|Aire industrial|O|O||D||1
12142106|Mezclas de gas inerte|O|O||D||1|Mezclas de gases inertes
12142107|Sulfato de hidrógeno|O|O||D||1|Gas de alcantarilla, Ácido hidrosulfúrico
12142108|Monóxido de carbono|O|O||D||1|Gas carbonoso
12142109|Hielo seco|O|O||D||1
12142110|Amoniaco líquido|O|O||D||1
12142200|Isótopos|O|O||D||1
12142201|Disolvente deuterado|O|O||D||1
12142202|Agua pesada|O|O||D||1|Agua deuterada
12142203|Fuentes alfa|O|O||D||1
12142204|Fuentes beta|O|O||D||1
12142205|Fuentes de cobalto|O|O||D||1
12142206|Fuentes gamma|O|O||D||1
12142207|Fuentes radio – isótopo|O|O||D||1|Fuentes de radioisótopos
12142208|Fuentes de calibración|O|O||D||1
12161500|Indicadores y reactivos|O|O||D||1
12161501|Etiquetas de afinidad|O|O||D||1|Inhibidores de enzimas
12161502|Agentes de entrecruzamiento|O|O||D||1
12161503|Kits de reactivos|O|O||D||1
12161504|Reactivos sulfhidrilo|O|O||D||1
12161505|Agentes de intercalación|O|O||D||1
12161506|Agentes de desvío|O|O||D||1|Desviadores químicos
12161507|Reactivo cupferrón|O|O||D||1
12161600|Catalizadores|O|O||D||1
12161601|Catalizadores ácidos|O|O||D||1
12161602|Catalizadores de combustión|O|O||D||1
12161603|Catalizadores a la medida|O|O||D||1|Catalizadores personalizado
12161604|Catalizadores de ruptura|O|O||D||1
12161605|Catalizadores fe tratamiento|O|O||D||1|Catalizadores para tratamiento
12161606|Catalizadores reformadores|O|O||D||1|Reformado catalítico
12161700|Amortiguadores|O|O||D||1
12161701|Mezclas de anfólito|O|O||D||1
12161702|Soluciones reguladoras de bicarbonato|O|O||D||1
12161703|Otras soluciones reguladoras|O|O||D||1|Otras disoluciones amortiguadoras
12161704|Soluciones reguladoras ácidas|O|O||D||1|Disoluciones amortiguadoras ácidas
12161705|Soluciones reguladoras básicas|O|O||D||1|Disoluciones amortiguadoras básicas
12161706|Soluciones reguladoras neutrales|O|O||D||1|Disoluciones amortiguadoras neutrales
12161800|Coloides|O|O||D||1
12161801|Geles|O|O||D||1
12161802|Suspensiones|O|O||D||1
12161803|Aerosoles|O|O||D||1
12161804|Emulsiones|O|O||D||1
12161805|Agentes gelificantes naturales|O|O||D||1|Agentes aglutinante hidrosoluble natural
12161806|Agentes gelificantes sintéticos|O|O||D||1|Agentes aglutinante hidrosoluble sintético
12161807|Estabilizadores de gel|O|O||D||1
12161808|Agentes de suspensión|O|O||D||1
12161809|Gel de silicona|O|O||D||1|Silicona en gel
12161900|Surfactantes|O|O||D||1
12161901|Agentes anti – espuma|O|O||D||1
12161902|Surfactantes detergentes|O|O||D||1|Detergentes tensoactivos
12161903|Agentes de espuma|O|O||D||1|Agentes espumantes
12161904|Agentes de dispersión|O|O||D||1
12161905|Enjuagues|O|O||D||1
12161906|Agentes de humectación|O|O||D||1|Agentes humectantes
12161907|Aditivos de inundación de agua|O|O||D||1
12161908|Alkil sulfatos|O|O||D||1|Sulfato de alquilo
12161909|Betaínas|O|O||D||1
12161910|Sulfatos de éter|O|O||D||1
12161911|Cuaternarios|O|O||D||1
12161912|Sultaína|O|O||D||1
12161913|Coadyuvante de rociado|O|O||D||1|Adyuvante de rociado
12162000|Plastificantes|O|O||D||1
12162002|Poliméricos|O|O||D||1|Polímeros
12162003|Aceites agrícolas|O|O||D||1
12162004|Sulfonamidas|O|O||D||1|Sulfas
12162005|Glutaratos|O|O||D||1
12162006|Plastificante ester aromático|O|O||D||1|Plastificadores de éster aromático
12162100|Retardadores de llama|O|O||D||1
12162101|Retardantes brominados|O|O||D||1|Retardantes de llama bromados
12162200|Anti-oxidantes|O|O||D||1|Ácido alfa lipoico (ALA)
12162201|Ácido ascórbico|O|O||D||1|Vitamina C
12162202|Beta caroteno|O|O||D||1|Caroteno
12162203|Butilhidroxianisol|O|O||D||1|Hidroxibutilanisol
12162204|Butilado hidroxitolueno|O|O||D||1|Butil hidroxitolueno
12162205|Citrato de calcio|O|O||D||1|Citrato cálcico, Sal amarga
12162206|Cantaxantina|O|O||D||1
12162207|Melatonina|O|O||D||1
12162208|Ácido nordihidroguaiarético|O|O||D||1
12162209|Galato de propilo|O|O||D||1
12162210|Silibinina|O|O||D||1|Silibina
12162211|Dióxido de azufre|O|O||D||1
12162212|Ubicquinona o coenzima q10|O|O||D||1
12162300|Agentes de curación|O|O||D||1
12162301|Agentes de curado transmitidos por el agua|O|O||D||1|Agentes de curado de cemento
12162302|Aceleradores de cemento|O|O||D||1|Aditivo acelerador de fraguado
12162303|Retardantes de cemento|O|O||D||1|Aditivos retardadores de fraguado
12162304|Acelerador adhesivo|O|O||D||1
12162305|Aditivo de concreto|O|O||D||1
12162400|Rompedores de polímero|O|O||D||1
12162401|Rompedores de polímero ácido|O|O||D||1
12162402|Rompedores de polímero orgánico|O|O||D||1
12162500|Rompedores de emulsión|O|O||D||1
12162501|Rompedores de emulsión agua en aceite|O|O||D||1
12162502|Rompedores de emulsión aceite en agua|O|O||D||1
12162503|Ayudas de flotación|O|O||D||1|Floculante
12162600|Estabilizadores de arcilla|O|O||D||1
12162601|Estabilizadores de arcilla inorgánica|O|O||D||1
12162602|Estabilizadores de arcilla orgánica|O|O||D||1
12162700|Aditivos de pérdida de fluido|O|O||D||1
12162701|Aditivos de pérdida de fluido de polímeros modificados|O|O||D||1
12162702|Aditivos de pérdida de fluido de polímeros naturales|O|O||D||1
12162800|Reductores de fricción|O|O||D||1
12162801|Reductores de fricción aniónico|O|O||D||1
12162802|Reductores de fricción catódica|O|O||D||1
12162900|Agentes de control de parafina asfaltenos|O|O||D||1
12162901|Agentes de control de asfaltenos de parafina tipo solvente|O|O||D||1
12162902|Agentes de control de asfaltenos de parafina modificados cristal|O|O||D||1
12162903|Agentes de control de asfaltenos de parafina tipo dispersante|O|O||D||1
12163000|Mezclas para quitar barro|O|O||D||1
12163001|Agentes de limpieza de lodo|O|O||D||1|Productos de limpieza para lodo
12163100|Anti lodo (sludger)|O|O||D||1
12163101|Aditivos anti – lodos|O|O||D||1
12163102|Desfloculante|O|O||D||1
12163200|Agentes de migración anti gas|O|O||D||1
12163201|Aditivos de migración anti gas|O|O||D||1
12163300|Agentes de expansión|O|O||D||1
12163301|Agentes de expansión de cemento|O|O||D||1
12163400|Extensores|O|O||D||1
12163401|Extensores de cemento|O|O||D||1
12163500|Sellador de pozo petrolífero|O|O||D||1
12163501|Sellantes de cemento|O|O||D||1
12163600|Inhibidores de corrosión|O|O||D||1
12163601|Inhibidores de corrosión en la producción de petróleo|O|O||D||1
12163602|Inhibidores de corrosión en la producción de gas|O|O||D||1
12163700|Reguladores de hidrato de gas|O|O||D||1
12163701|Controladores de hidrato de gas|O|O||D||1
12163800|Limpiadores químicos|O|O||D||1
12163801|Eliminadores de sulfuro de hidrógeno|O|O||D||1
12163802|Eliminadores de oxígeno|O|O||D||1
12163900|Reguladores de sarro|O|O||D||1
12163901|Inhibidores de incrustaciones|O|O||D||1
12163902|Removedores o convertidores de incrustaciones|O|O||D||1|Desincrustantes o convertidores
12164000|Bactericidas|O|O||D||1
12164001|Microbicidas registrados|O|O||D||1|Agentes microbicidas registrados
12164100|In situ|O|O||D||1
12164101|Aditivos in situ|O|O||D||1
12164102|Aditivos ácidos|O|O||D||1
12164200|Retardadores|O|O||D||1
12164201|Inhibidores anti – corrosión|O|O||D||1|Inhibidor antioxidante
12164300|Controladores de hierro|O|O||D||1
12164301|Aditivos de control de hierro|O|O||D||1
12164302|Aditivos secuestradores de hierro|O|O||D||1|Agentes quelantes de hierro
12164303|Inhibidor de la corrosión de hierro|O|O||D||1|Inhibidor antioxidante de hierro
12164400|No emulsificadoras|O|O||D||1
12164401|Aditivos no emulsificantes|O|O||D||1|Aditivos de alimentos o fármacos
12164500|Aditivos de alimentos y fármacos|O|O||D||1
12164501|Preservativos de alimentos|O|O||D||1|Conservadores de alimentos
12164502|sabores o extractos|O|O||D||1|Saborizantes y extractos
12164503|Aditivos de fragancia|O|O||D||1
12164504|Endulzantes|O|O||D||1|Edulcorantes
12164505|Excipiente|O|O||D||1
12164506|Aglutinante de tabletas|O|O||D||1|Adhesivo de tabletas
12164507|Recubrimiento de tabletas|O|O||D||1|Recubrimiento de comprimidos
12164508|Desintegrante|O|O||D||1
12164509|Agente antiapelmazante|O|O||D||1|Agente antiaglomerante
12164600|Modificadores de papel, plástico y tela|O|O||D||1
12164601|Agente de dimensionamiento|O|O||D||1
12164602|Agente de espesamiento|O|O||D||1
12164603|Abrillantador óptico|O|O||D||1|Agente blanqueador óptico
12164604|Agente antiestática|O|O||D||1
12164605|Micro – floculante|O|O||D||1
12164606|Estabilizador de luz y ultravioleta|O|O||D||1
12164700|Antisépticos industriales|O|O||D||1
12164701|Aditivo antiséptico|O|O||D||1
12164800|Agentes reductores de agua|O|O||D||1
12164801|Agente reductor de agua en cemento|O|O||D||1
12164802|Agente detenedor o hinchador de agua|O|O||D||1
12164803|Repelente estructural de agua|O|O||D||1
12164900|Agentes de impermeabilización|O|O||D||1
12164901|Recubrimiento impermeable de uretano|O|O||D||1|Revestimiento impermeable de uretano
12164902|Recubrimiento impermeable de asfalto|O|O||D||1|Revestimiento impermeable de asfalto
12164903|Recubrimiento impermeable epoxi|O|O||D||1|Revestimiento impermeable epoxi
12164904|Recubrimiento impermeable inorgánico|O|O||D||1|Revestimiento impermeable inorgánico
12164905|Agente de impermeabilización|O|O||D||1|Aditivo de hidrófugo, Aditivo impermeabilizante
12165000|Agentes anti encogimiento|O|O||D||1
12165001|Concreto anti – contracción del cemento|O|O||D||1
12165100|Químicos para mejorar la recuperación de petróleo|O|O||D||1
12165101|Gel de polímero|O|O||D||1
12165102|Surfactante dispersante|O|O||D||1|Tensioactivos dispersante
12165103|Surfactante polímero álcali asp|O|O||D||1|Tensioactivos polímero álcali ASP
12165104|Polímero surfactante sp|O|O||D||1|Polímero surfactante SP
12171500|Tintes|O|O||D||1
12171501|Colorantes fluorescentes|O|O||D||1
12171502|Colorantes ftaleínicos|O|O||D||1
12171503|Colorantes rosanilina|O|O||D||1
12171504|Colorantes fdc seguros para alimentos o cosméticos|O|O||D||1|Colorantes FDC para alimentos o medicamentos o cosméticos
12171505|Lacado|O|O||D||1
12171506|Colorantes naturales|O|O||D||1
12171507|Colorantes de azufre|O|O||D||1
12171508|Colorantes de cuba o tina|O|O||D||1
12171509|Colorantes reactivos|O|O||D||1
12171510|Colorantes solventes|O|O||D||1
12171511|Colorantes ácidos|O|O||D||1
12171600|Pigmentos|O|O||D||1
12171602|Óxidos metálicos inorgánicos|O|O||D||1
12171603|Negro carbono|O|O||D||1
12171604|Dióxido de titanio|O|O||D||1
12171605|Pigmentos orgánicos|O|O||D||1
12171606|Zeaxantina|O|O||D||1
12171607|Verde parís|O|O||D||1
12171608|Caput mortuum (púrpura de cardenal)|O|O||D||1
12171609|Verde cadmio|O|O||D||1
12171610|Anaranjado cadmio|O|O||D||1
12171611|Amarillo cadmio|O|O||D||1
12171612|Rojo cadmio|O|O||D||1
12171613|Rojo ocre|O|O||D||1
12171614|Amarillo ocre|O|O||D||1
12171615|Sanguina|O|O||D||1
12171616|Azul de prusia|O|O||D||1
12171617|Rojo veneciano|O|O||D||1
12171618|Verde cromo|O|O||D||1
12171619|Auerolina (amarillo de cobalto)|O|O||D||1
12171620|Amarillo cromo|O|O||D||1
12171621|Pigmento fluorescente|O|O||D||1
12171700|Compuestos de colores y dispersiones|O|O||D||1
12171701|Concentrado de color de polímero|O|O||D||1
12171702|Dispersiones de pigmento|O|O||D||1
12171703|Tintas|O|O||D||1
12181500|Ceras|O|O||D||1
12181501|Ceras sintéticas|O|O||D||1
12181502|Ceras naturales|O|O||D||1
12181503|Parafinas|O|O||D||1
12181504|Petrolatos|O|O||D||1
12181600|Aceites|O|O||D||1
12181601|Aceites sintéticos|O|O||D||1
12181602|Aceites naturales|O|O||D||1
12191500|Solventes hidrocarbonatos|O|O||D||1
12191501|Disolventes aromáticos|O|O||D||1
12191502|Disolventes alifáticos|O|O||D||1
12191503|Fenoles o sus sustitutos y derivados|O|O||D||1
12191504|Alcanos cíclicos|O|O||D||1
12191600|Solventes oxigenados|O|O||D||1
12191601|Solventes de alcohol|O|O||D||1
12191602|Solventes activos|O|O||D||1
12352000|Compuestos aromáticos y alifáticos|O|O||D||1
12352001|Alcanos|O|O||D||1
12352002|Alquenos|O|O||D||1
12352003|Alquinos|O|O||D||1
12352005|Compuestos aromáticos o heterocíclicos|O|O||D||1
12352100|Derivados orgánicos y compuestos sustituidos|O|O||D||1
12352101|Compuestos halogenados orgánicos|O|O||D||1
12352102|Compuestos orgánicos nitro o nitroso|O|O||D||1
12352103|Compuestos órgano – metálicos|O|O||D||1
12352104|Alcoholes o sus sustitutos|O|O||D||1
12352105|Alcoholes tio (mercaptanos)|O|O||D||1
12352106|Ácidos orgánicos o sus sustitutos|O|O||D||1
12352107|Sales orgánicas o sus sustitutos|O|O||D||1
12352108|Esteres o sus sustitutos|O|O||D||1
12352111|Amidas o imidas|O|O||D||1
12352112|Esteres o sus sustitutos|O|O||D||1
12352113|Tioéteres|O|O||D||1
12352114|Aldehídos o sus sustitutos|O|O||D||1
12352115|Cetonas o quinonas o sus sustitutos|O|O||D||1
12352116|Amines o imines o sus sustitutos|O|O||D||1
12352117|Cianuros o isocianuros|O|O||D||1
12352118|Cianatos o isocianatos o tiocianatos o isotiocianatos|O|O||D||1
12352119|Óxidos orgánicos|O|O||D||1
12352120|Peróxidos orgánicos|O|O||D||1
12352121|Hidróxidos orgánicos|O|O||D||1
12352123|Ureidos o purinas o sus derivados|O|O||D||1
12352124|Azo compuestos o sus sustitutos|O|O||D||1
12352125|Azidas o azinas|O|O||D||1
12352126|Oximas|O|O||D||1
12352127|Hidracinas o hidracidas o sus sustitutos|O|O||D||1
12352128|Fosfinas|O|O||D||1
12352129|Amidinas o imidinas|O|O||D||1
12352130|Intermedios de acrilato o metacrilato|O|O||D||1
12352131|Pirrolidona|O|O||D||1
12352132|Triclosán|O|O||D||1
12352133|Condicionador de congelación|O|O||D||1
12352135|Glicol propileno|O|O||D||1
12352136|Glicol trietileno|O|O||D||1
12352137|Glicol etileno|O|O||D||1
12352200|Productos bioquímicos|O|O||D||1
12352201|Carbohidratos o sus derivados|O|O||D||1
12352202|Proteínas|O|O||D||1
12352203|Anticuerpos|O|O||D||1
12352204|Enzimas|O|O||D||1
12352205|Nutrientes|O|O||D||1
12352206|Tejidos|O|O||D||1
12352207|Cultivos y fluidos|O|O||D||1
12352208|Ácido nucleico|O|O||D||1
12352209|Aminoácidos o sus derivados|O|O||D||1
12352210|Alcaloides|O|O||D||1
12352211|Grasas o lípidos|O|O||D||1
12352212|Terpenoides|O|O||D||1
12352300|Compuestos inorgánicos|O|O||D||1
12352301|Ácidos inorgánicos|O|O||D||1
12352302|Sales metálicas inorgánicas|O|O||D||1
12352303|Óxidos inorgánicos|O|O||D||1
12352304|Peróxidos inorgánicos|O|O||D||1
12352305|Hidróxidos inorgánicos|O|O||D||1
12352306|Hídridos inorgánicos|O|O||D||1
12352307|Halidos ácidos o sus sustitutos|O|O||D||1
12352308|Silicatos|O|O||D||1
12352309|Sílice|O|O||D||1
12352310|Siliconas|O|O||D||1
12352311|Alúmina y otros compuestos de aluminio|O|O||D||1
12352312|Permanganato de potasio|O|O||D||1
12352313|Ácido trifluoroacético tfa|O|O||D||1
12352314|Sulfato de amonio|O|O||D||1
12352315|Caucho de silicona líquida|O|O||D||1
12352316|Hidróxido de sodio|O|O||D||1
12352317|Fluoruro de aluminio|O|O||D||1
12352318|Fluoruro de calcio|O|O||D||1
12352319|Hidróxido de calcio|O|O||D||1
12352320|Hidróxido de potasio|O|O||D||1
12352321|Glicol acetileno|O|O||D||1
12352400|Mezclas|O|O||D||1
12352401|Mezclas químicas orgánicas|O|O||D||1
12352402|Mezclas químicas inorgánicas|O|O||D||1
12352500|Fijadores|O|O||D||1
12352501|Formaldehidos|O|O||D||1
12352502|Glutarales|O|O||D||1
12352503|Taninos|O|O||D||1
12352600|Compuestos fluorados|O|O||D||1
13101500|Caucho natural|O|O||D||1
13101501|Caucho látex|O|O||D||1|Hule
13101502|Caucho crepe|O|O||D||1
13101503|Caucho hoja ahumada|O|O||D||1
13101504|Caucho espuma natural|O|O||D||1
13101505|Caucho bloque o borona|O|O||D||1|Goma de borrar de caucho
13101600|Caucho procesado y sintético|O|O||D||1
13101601|Caucho vulcanizado|O|O||D||1
13101602|Caucho clorado|O|O||D||1
13101603|Caucho clorhidrato|O|O||D||1
13101604|Caucho ciclizado|O|O||D||1
13101605|Caucho isomerizado|O|O||D||1
13101606|Caucho termoplástico|O|O||D||1
13101607|Compuesto de caucho|O|O||D||1
13101608|Caucho reclamado|O|O||D||1|Caucho reciclado o reutilizado
13101700|Elastómeros|O|O||D||1
13101701|Butadieno acilonitrilo nbr|O|O||D||1
13101702|Nitrilo altamente saturado nhbr|O|O||D||1
13101703|Fluorocarbono fcm|O|O||D||1
13101704|Propileno etileno epe|O|O||D||1
13101705|Butadieno estireno|O|O||D||1
13101706|Clorpreno cr|O|O||D||1
13101707|Isopreno isobutileno iir / xiir|O|O||D||1
13101708|Silicona vmq y pmq y pvmq|O|O||D||1
13101709|Fluorosilicona fvmq|O|O||D||1
13101710|Poliacrilato acm|O|O||D||1
13101711|Etileno acrílico aem|O|O||D||1
13101712|Polietileno clorosulfonatado csm|O|O||D||1
13101713|Cloropolietileno cm|O|O||D||1
13101714|Epicloridrina|O|O||D||1
13101715|Polisopreno natural nr|O|O||D||1
13101716|Polisopreno sintético ir|O|O||D||1
13101717|Poliéster uretano au|O|O||D||1
13101718|Poliéster uretano eu|O|O||D||1
13101719|Polibutadieno br|O|O||D||1
13101720|Poli éter bloque amida peba|O|O||D||1|Bloque de poliéster de amida o PEBA
13101721|Estireno bloque copolímero tes|O|O||D||1
13101722|Copoliester|O|O||D||1
13101723|Termoplástico|O|O||D||1
13101724|Poliolefínico|O|O||D||1
13101725|Etileno propileno dieno epdm|O|O||D||1|Dieno de etileno propileno o EPDM
13101900|Plásticos termoformados|O|O||D||1
13101902|Fenólico pf|O|O||D||1
13101903|Poliéster no saturado up|O|O||D||1
13101904|Urea uf|O|O||D||1|Urea o formaldehído de plástico
13101905|Melamina mf|O|O||D||1
13101906|Poliuretano termoestable pur|O|O||D||1
13102000|Plásticos termoplásticos|O|O||D||1
13102001|Acrilonitrilo butadieno estireno abs|O|O||D||1
13102002|Aleaciones de acrilonitrilo butadieno estireno abs|O|O||D||1
13102003|Polímero acetal|O|O||D||1
13102005|Acrilonitrilo estireno acrílico asa|O|O||D||1
13102006|Aleaciones de acrilonitrilo estireno acrílico asa|O|O||D||1
13102008|Fluoropolímeros ptfe|O|O||D||1
13102010|Polímero cristal líquido lcp|O|O||D||1
13102011|Nylons poliamida pa|O|O||D||1
13102012|(no hay sugerencias) pbt|O|O||D||1|Tereftalato de polibutileno PBT
13102013|Policarbonato pc|O|O||D||1
13102014|Polietereterquetona peek|O|O||D||1|Polieteretercetona PEEK
13102016|Polietersulfona pes|O|O||D||1
13102017|Polietileno de baja densidad hdpe|O|O||D||1
13102018|Polietileno de alta densidad ldpe|O|O||D||1
13102019|Polietileno de media densidad mdpe|O|O||D||1
13102020|Polietileno tereftalato pet|O|O||D||1
13102021|Polimida pi|O|O||D||1
13102022|Polipropileno pp|O|O||D||1
13102024|Óxido de polifenileno ppo|O|O||D||1
13102025|Sulfuro de polifenileno pps|O|O||D||1
13102026|Poliestireno (icopor) ps|O|O||D||1|Espuma de poliestireno EPS, Poliestireno expandido EPS, Unice
13102027|Poliestireno de alto impacto hips|O|O||D||1
13102028|Polisulfona psu|O|O||D||1
13102029|Poliuretano termoplástico rígido rptu|O|O||D||1
13102030|Cloruro de polivinilo pvc|O|O||D||1
13102031|Éter de polifenilene ppe|O|O||D||1
13102032|Poliolefina termoplástica tpo|O|O||D||1
13111000|Resinas|O|O||D||1
13111001|Epoxi|O|O||D||1|Resina de epoxi o poliepóxido
13111002|Resina fenólica|O|O||D||1
13111003|Resina polester no saturada|O|O||D||1
13111004|Resina estireno butadieno acrilonitrilo|O|O||D||1
13111005|Resina acrílica estireno acrilonitrilo|O|O||D||1
13111006|Resina aleación acrílica estireno acrilonitrilo|O|O||D||1
13111007|Resina fliuoropolímero|O|O||D||1
13111008|Resina acetato vinilo etileno|O|O||D||1
13111009|Resina polímero cristal líquido|O|O||D||1
13111010|Nylon|O|O||D||1
13111011|Tetralftalato polibutileno|O|O||D||1
13111012|Resina de policarbonato|O|O||D||1
13111013|Resina polietereterquetona|O|O||D||1
13111014|Resina polieterimida|O|O||D||1
13111015|Resina polietersulfona|O|O||D||1
13111016|Polietileno|O|O||D||1
13111017|Resina terftalato polietileno|O|O||D||1
13111018|Resina polimida|O|O||D||1
13111019|Resina polipropileno|O|O||D||1
13111020|Resina poliftalamida|O|O||D||1
13111021|Óxido de polietileno|O|O||D||1
13111022|Resina sulfuro de polifenilene|O|O||D||1
13111023|Resina de poliestireno|O|O||D||1
13111024|Resina de polisulfona|O|O||D||1
13111025|Resina de cloruro de polivinilo|O|O||D||1
13111026|Resina de acrilonitrilo de estireno|O|O||D||1
13111027|Formaldehído de urea|O|O||D||1
13111028|Alquido|O|O||D||1
13111029|Formaldehído de melamina|O|O||D||1
13111030|Poliacetal|O|O||D||1
13111031|Poliamida|O|O||D||1
13111032|Grupo alilo|O|O||D||1
13111033|Ácido acrílico de etileno|O|O||D||1
13111034|Compuesto cloruro de polivinilo|O|O||D||1
13111035|Solución de vinilo|O|O||D||1
13111036|Fenoxi|O|O||D||1
13111037|Resina compuesta|O|O||D||1
13111038|Pirolidina polivinilo|O|O||D||1
13111039|Tereftalato de polietileno o glicol modificado|O|O||D||1
13111040|Fijador de hidrocarburo|O|O||D||1
13111041|Mezclas de policarbonato|O|O||D||1
13111042|Alcohol polivinilo|O|O||D||1
13111043|Butiral polivinilo|O|O||D||1
13111044|Compuesto de moldeo de poliéster|O|O||D||1
13111045|Acetato de polivinilo|O|O||D||1
13111046|Éter de polivinilo|O|O||D||1
13111047|Polivinilo formal|O|O||D||1
13111048|Acrílico de estireno|O|O||D||1
13111049|Polímeros de propileno de etileno|O|O||D||1
13111050|Óxido de polipropileno|O|O||D||1
13111051|Éter de polipropileno|O|O||D||1
13111052|Sulfona de polipropileno|O|O||D||1
13111053|Polimetilacrilato|O|O||D||1
13111054|Anhídrido maléico de estireno|O|O||D||1
13111055|Poliestireno sindiotáctico|O|O||D||1
13111056|Cloruro de polivinilo clorado|O|O||D||1
13111057|Poliéster termoplástico|O|O||D||1
13111058|Resinas de indeno|O|O||D||1
13111059|Resinas plásticas|O|O||D||1
13111060|Resinas de petróleo|O|O||D||1
13111061|Resinas de poliuretano|O|O||D||1
13111062|Resinas de polieter|O|O||D||1
13111063|Resinas recicladas|O|O||D||1
13111064|Resinas acrílicas|O|O||D||1
13111065|Resinas celulosas|O|O||D||1
13111066|Resinas de polipropileno|O|O||D||1
13111067|Alcohol etileno vinilo|O|O||D||1
13111068|Polietileno lineal de baja densidad|O|O||D||1
13111069|Resina de poliacrilonitrilo|O|O||D||1
13111070|Resina de poliamida – imida|O|O||D||1
13111071|Resina de poliarileterquetona|O|O||D||1|Resina de poliariletercetona
13111072|Resina de polibenzimidasola|O|O||D||1
13111073|Resina de polimetilpenteno|O|O||D||1
13111074|Fluoruro de polivinildeno|O|O||D||1
13111075|Aleación estireno uradieno acrilonitrilo policarbonato pc abs|O|O||D||1
13111076|Polietileno entrecruzado pex|O|O||D||1
13111077|Poliamida 6 – 12|O|O||D||1
13111078|Poliamida 6 – 6|O|O||D||1
13111079|Poliamida 4 – 6|O|O||D||1
13111080|Nylon poliamida de alta temperatura htn|O|O||D||1
13111081|Poliamida 12|O|O||D||1
13111082|Poliamida 6|O|O||D||1
13111100|Colofonia|O|O||D||1
13111101|Rosina de madera|O|O||D||1|Colofonia de madera, Resina de madera
13111102|Rosina de goma|O|O||D||1|Resina de goma
13111103|Rosina aceite de pino|O|O||D||1|Resina de aceite de pino
13111200|Películas|O|O||D||1
13111201|Películas de polietileno|O|O||D||1|Resina de aceite alto
13111202|Películas de poliuretano|O|O||D||1
13111203|Películas de acetato|O|O||D||1
13111204|Películas de acrílico|O|O||D||1
13111205|Películas coextruídas|O|O||D||1
13111206|Películas de fluoropolímero|O|O||D||1
13111207|Películas metalizadas|O|O||D||1
13111208|Películas de nylon|O|O||D||1
13111209|Películas de policarbonato|O|O||D||1
13111210|Películas de poliéster|O|O||D||1
13111211|Películas de polipropileno|O|O||D||1
13111212|Polipropileno orientado axialmente|O|O||D||1
13111213|Películas de poliamida|O|O||D||1
13111214|Películas de poliestireno|O|O||D||1
13111215|Películas de cloruro de polivinilo flexible|O|O||D||1
13111216|Películas de cloruro de polivinilo rígido|O|O||D||1
13111217|Películas de alcohol vinilo etileno|O|O||D||1
13111218|Películas de cloruro de polivinilo|O|O||D||1
13111219|Películas de alcohol polivinilo|O|O||D||1
13111220|Películas de recubiertas de silicona|O|O||D||1
13111300|Espumas|O|O||D||1|Espuma de poliuretano, Espuma rígida de poliuretano para arreglos florales, Espuma rígida de resina fenólica para arreglos florale
13111301|Espumas de poliolefina|O|O||D||1
13111302|Espumas de poli éter|O|O||D||1|Espuma de poliéster
13111303|Espumas de silicona|O|O||D||1
13111304|Espumas de terpolímero propileno etileno|O|O||D||1
13111305|Espumas de neopreno|O|O||D||1
13111306|Espumas de cloruro de polivinilo|O|O||D||1
13111307|Espumas de caucho|O|O||D||1
13111308|Espumas de poliestireno|O|O||D||1
14101500|Materias primas|O|O||D||1
14101501|Pulpa de papel|O|O||D||1
14111500|Papel de imprenta y papel de escribir|O|O||D||1
14111501|Papel cebolla|O|O||D||1
14111502|Papel vitela|O|O||D||1
14111503|Papel pergamino|O|O||D||1
14111504|Papel en formas continuas|O|O||D||1
14111505|Papel mimeógrafo|O|O||D||1
14111506|Papel para impresión de computadores|O|O||D||1
14111507|Papel para impresora o fotocopiadora|O|O||D||1
14111508|Papel para fax|O|O||D||1
14111509|Papel membreteado|O|O||D||1
14111510|Papel para plotter|O|O||D||1
14111511|Papel de escritura|O|O||D||1
14111512|Papel para gráficos|O|O||D||1
14111513|Papel de libro|O|O||D||1
14111514|Blocs o cuadernos de papel|O|O||D||1
14111515|Papel para sumadora o máquina registradora|O|O||D||1
14111516|Repuestos de papel para cuaderno|O|O||D||1
14111518|Tarjetas de índice|O|O||D||1
14111519|Papeles cartulina|O|O||D||1
14111520|Papel secante|O|O||D||1
14111523|Papel calcante|O|O||D||1|Calca
14111524|Papel folio|O|O||D||1
14111525|Papel multipropósito|O|O||D||1
14111526|Papel libretas o libros de mensajes telefónicos|O|O||D||1|Cuadernos de mensajes telefónicos
14111527|Papel autocopiante|O|O||D||1
14111528|Papel magnético|O|O||D||1
14111529|Rollos de télex|O|O||D||1
14111530|Papel de notas autoadhesivas|O|O||D||1
14111531|Papel libros o cuadernos para bitácoras|O|O||D||1
14111532|Papel kits de papeles surtidos|O|O||D||1
14111533|Papel cuadernillos o formularios de exámenes|O|O||D||1
14111534|Papeles para notación musical o manuscritos|O|O||D||1|Cuadernos pautados o pentagramados
14111535|Papeles para telégrafo|O|O||D||1
14111536|Tarjetas de préstamo de bibliotecas|O|O||D||1
14111537|Etiquetas de papel|O|O||D||1
14111538|Papel digital|O|O||D||1
14111539|Papel de monitoreo o calcado o registro médico|O|O||D||1
14111540|Papel de estampilla|O|O||D||1
14111541|Papel lector de marcas ópticas|O|O||D||1|Papel para lector de marcas ópticas
14111542|Papel coreano para papelería|O|O||D||1
14111543|Piedra de tinta|O|O||D||1
14111600|Papel fantasía|O|O||D||1
14111601|Papel o bolsas o cajas de regalo|O|O||D||1
14111604|Tarjetas de presentación|O|O||D||1
14111605|Tarjetas postales, de saludo o de notas|O|O||D||1
14111606|Papel para artes o artesanías|O|O||D||1
14111607|Tableros para afiches|O|O||D||1|Cartulinas
14111608|Certificados de regalo|O|O||D||1
14111609|Papel de cubierta|O|O||D||1
14111610|Papel de construcción|O|O||D||1
14111611|Tarjetas de invitación o de anuncio|O|O||D||1
14111613|Papel de pancartas|O|O||D||1
14111614|Papel o tejidos de álbum|O|O||D||1
14111615|Papeles de afiche|O|O||D||1|Papel para cartel o póster
14111616|Papeles para forrar|O|O||D||1
14111617|Papel leathack (verjurado)|O|O||D||1|Papel estampado
14111618|Papel kent|O|O||D||1|Papel de dibujo
14111700|Productos de papel para uso personal|O|O||D||1
14111701|Pañuelos faciales|O|O||D||1
14111702|Cubiertos de asientos de sanitario|O|O||D||1
14111703|Toallas de papel|O|O||D||1
14111704|Papel higiénico|O|O||D||1
14111705|Servilletas de papel|O|O||D||1
14111706|Manteles de papel|O|O||D||1
14111800|Papeles de uso comercial|O|O||D||1
14111801|Boletas o rollos de boletería|O|O||D||1
14111802|Recibos o libros de recibos|O|O||D||1
14111803|Comprobantes|O|O||D||1
14111804|Facturas o libros de facturas|O|O||D||1
14111805|Cheques o chequeras|O|O||D||1
14111806|Formularios o cuestionarios de negocios|O|O||D||1
14111807|Libros comerciales para múltiples usos|O|O||D||1
14111808|Formatos contables o libros de contabilidad|O|O||D||1
14111809|Formas o libros de conocimientos de embarque|O|O||D||1
14111810|Formatos o libros de personal|O|O||D||1
14111811|Formatos o libros de ventas|O|O||D||1
14111812|Formatos o libros de inventarios|O|O||D||1
14111813|Formatos o libros de correspondencia|O|O||D||1
14111814|Formatos o libros de impuestos|O|O||D||1
14111815|Tarjetas de identificación|O|O||D||1
14111816|Tarjetas de huellas digitales de solicitante|O|O||D||1|Fichas para huellas dactilares, Tarjetas para huellas dactilares
14111817|Formato de verificación de depósito|O|O||D||1
14111818|Papel térmico|O|O||D||1
14111819|Formularios p libros de reservas|O|O||D||1|Formularios o libros para reservación
14111820|Formas o cupones de juegos de azar|O|O||D||1
14111821|Formatos o libros de órdenes|O|O||D||1
14111822|Formatos o libros de entregas|O|O||D||1
14111823|Formatos o libros de control|O|O||D||1
14111824|Libreta de prescripciones farmacéuticas|O|O||D||1
14111825|Menú|O|O||D||1
14111826|Certificados de nacimiento|O|O||D||1
14111827|Certificados de defunción|O|O||D||1
14111828|Papelería comercial membreteada|O|O||D||1
14121500|Cartón y papel para embalaje|O|O||D||1
14121501|Cartón blanqueado|O|O||D||1
14121502|Cartón no blanqueado|O|O||D||1
14121503|Cartón|O|O||D||1
14121504|Papel de empaque|O|O||D||1
14121505|Material de fibra|O|O||D||1
14121506|Fibra corrugada|O|O||D||1
14121507|Papel inhibidor de la corrosión volátil o vci|O|O||D||1
14121600|Papel de seda|O|O||D||1
14121601|Papel crepé sin blanquear|O|O||D||1
14121602|Papel crepé semi blanqueado|O|O||D||1
14121603|Pañuelos de papel resistentes a la humedad|O|O||D||1
14121604|Pañuelos de papel libres de ácido|O|O||D||1
14121605|Pañuelos de papel kraft|O|O||D||1
14121700|Papeles laminados|O|O||D||1
14121701|Papeles adheridos con película|O|O||D||1
14121702|Papeles cilindro o papel pesado multi – capas|O|O||D||1
14121703|Hojas de papel aluminio laminado|O|O||D||1
14121800|Papeles recubiertos|O|O||D||1
14121801|Papeles recubiertos de arcilla|O|O||D||1
14121802|Papeles recubiertos de polietileno|O|O||D||1
14121803|Papeles recubiertos de poliéster|O|O||D||1
14121804|Papeles recubiertos de silicona|O|O||D||1
14121805|Papeles recubiertos tratados con látex|O|O||D||1
14121806|Papel de parafinado|O|O||D||1
14121807|Papel mantequilla|O|O||D||1
14121808|Papel para congelador|O|O||D||1
14121809|Papel de enmascarar|O|O||D||1
14121810|Papeles carbón|O|O||D||1
14121811|Papeles de copiado sensibilizados|O|O||D||1
14121812|Papel de fotografía|O|O||D||1
14121900|Papel prensa y de offset|O|O||D||1
14121901|Papel periódico estándar|O|O||D||1
14121902|Papel periódico de colores|O|O||D||1
14121903|Papel periódico de alto brillo|O|O||D||1
14121904|Papel offset|O|O||D||1
14121905|Papeles tímpano|O|O||D||1|Papeles Tympan
14122100|Papeles de base sin recubrir|O|O||D||1
14122101|Papel kraft súper calandrado|O|O||D||1
14122102|Papel kraft terminado o satinado en máquina|O|O||D||1
14122103|Papel no recubierto no tratado|O|O||D||1
14122104|Papel crepé no tratado|O|O||D||1
14122105|Papel crepé tratado con látex|O|O||D||1
14122106|Papel no recubierto tratado con látex|O|O||D||1
14122107|Papel base corrugado|O|O||D||1
14122200|Papeles especializados de uso industrial|O|O||D||1
14122201|Papel para germinación de semillas|O|O||D||1
14122202|Papel para bolsas de te|O|O||D||1
15101500|Petróleo y Destilados|O|O||D||1
15101502|Kerosene|O|O||D||1
15101503|Nafta|O|O||D||1
15101504|Combustible de aviación|O|O||D||1
15101505|Combustible diesel|O|O||D||1
15101506|Gasolina|O|O||D|2020-01-15|1
15101507|Benceno|O|O||D||1|hidrocarburo aromático
15101508|Petróleo crudo|O|O||D||1
15101509|Combustible marítimo|O|O||D||1
15101510|Condensado|O|O||D||1
15101511|Etanol|O|O||D||1
15101512|Coque de petróleo o petcoke|O|O||D||1
15101513|Combustible diesel para uso fuera de carretera|O|O||D||1
15101514|Gasolina regular menor a 91 octanos|O|O||2020-01-16||1
15101515|Gasolina premium mayor o igual a 91 octanos|O|O||2020-01-16||1
15101600|Combustibles sólidos o gelificados|O|O||D||1
15101601|Carbón sub – bituminosos o débil|O|O||D||1
15101602|Lignito|O|O||D||1|Carbón mineral
15101603|Turba|O|O||D||1|Carbón ligero
15101604|Coque|O|O||D||1
15101605|Carbón de leña o vegetal|O|O||D||1
15101606|Combustibles de alcohol gelatinoso|O|O||D||1
15101607|Hexaminas|O|O||D||1
15101608|Trioxanos|O|O||D||1
15101609|Briqueta|O|O||D||1|Bloque sólido combustible
15101610|Carbón de cascara de coco|O|O||D||1
15101611|Antracita o carbón duro|O|O||D||1
15101612|Carbón metalúrgico|O|O||D||1
15101613|Carbón sin procesar|O|O||D||1
15101614|Carbón energético|O|O||D||1
15101700|Aceites combustibles|O|O||D||1
15101701|Fuel oil de calefacción # 2|O|O||D||1|Combustible de calefacción no. 2
15101702|Fuel oils pesados residuales # 4 ó # 6|O|O||D||1|Aceites combustibles residuales pesados no. 4 o no. 6, Combustóleo no. 4 o no. 6, Petróleos residuales pesados no. 4 o no.
15101800|Combustibles o biocombustibles líquidos basados en plantas|O|O||D||1
15101801|Biodiesel|O|O||D||1
15111500|Combustibles gaseosos|O|O||D||1
15111501|Propano|O|O||D||1
15111502|Metano|O|O||D||1
15111503|Propileno|O|O||D||1
15111504|Etileno|O|O||D||1
15111505|Butano|O|O||D||1
15111506|Acetileno|O|O||D||1
15111507|Gas de agua o gas productor|O|O||D||1
15111508|Gas de carbón|O|O||D||1
15111509|Gas metilacetileno propadieno mapp|O|O||D||1
15111510|Gas licuado de petróleo|O|O||D||1|Gas LP
15111511|Gas natural licuado gnl|O|O||D||1
15111512|Gas natural|O|O||2020-01-16||1
15111700|Aditivos para carburante|O|O||D||1
15111701|Espesantes de combustible|O|O||D||1
15111702|Inhibidores de hielo para sistemas de combustibles|O|O||D||1
15121500|Preparados lubricantes|O|O||D||1
15121501|Aceite motor|O|O||D||1
15121502|Aceite de corte|O|O||D||1
15121503|Aceite de engranajes|O|O||D||1
15121504|Aceite hidráulico|O|O||D||1
15121505|Aceite de transformador o aislador|O|O||D||1
15121508|Aceite de transmisión|O|O||D||1
15121509|Aceite de frenos|O|O||D||1
15121510|Anti – excoriación|O|O||D||1
15121511|Pastas de ensamble|O|O||D||1
15121512|Anti adhesivos|O|O||D||1
15121513|Lubricantes de grafito|O|O||D||1
15121514|Lubricantes espray|O|O||D||1
15121515|Compuestos anti – adherentes o anti – manchas|O|O||D||1
15121516|Eliminador de fugas|O|O||D||1
15121517|Jabones lubricantes|O|O||D||1
15121518|Fluidos de amortiguación|O|O||D||1
15121519|Aceites de lubricación de relojes|O|O||D||1
15121520|Lubricantes de propósito general|O|O||D||1
15121521|Aceites para lubricación de bombas|O|O||D||1
15121522|Aceites para lubricación de armas|O|O||D||1
15121523|Fluidos para preparación de lentes|O|O||D||1
15121524|Aceites de templado|O|O||D||1
15121525|Aceite atemperante|O|O||D||1|Aceites de enfriamiento
15121526|Lubricantes para equipo de procesamiento de alimentos|O|O||D||1
15121527|Aceite de turbina|O|O||D||1
15121528|Fluido hidráulico resistente al fuego|O|O||D||1
15121529|Aceite para máquinas de refrigeración|O|O||D||1
15121530|Aceite o fluido de transferencia de calor|O|O||D||1
15121800|Anticorrosivos|O|O||D||1
15121801|Repelente de humedad|O|O||D||1
15121802|Lubricante anti – corrosión|O|O||D||1
15121803|Removedor de óxido|O|O||D||1
15121804|Preparación contra óxido|O|O||D||1
15121805|Pastas anti – soldado|O|O||D||1
15121806|Aceites penetrantes|O|O||D||1
15121807|Anticongelante|O|O||D||1
15121900|Grasas|O|O||D||1
15121901|Grasa de silicona|O|O||D||1
15121902|Grasa|O|O||D||1
15121903|Grasa fluoropolímero|O|O||D||1
15121904|Grasa de lana|O|O||D||1
15121905|Grasa térmica|O|O||D||1
15131500|Combustible nuclear|O|O||D||1
15131502|Uranio empobrecido|O|O||D||1
15131503|Uranio enriquecido|O|O||D||1
15131504|Iridio|O|O||D||1
15131505|Plutonio enriquecido|O|O||D||1
15131506|Plutonio empobrecido|O|O||D||1
15131600|Instalación de combustible de fisión|O|O||D||1
15131601|Barra de combustible nuclear|O|O||D||1
20101500|Equipo de corte|O|O||D||1
20101501|Equipo de minería continua|O|O||D||1
20101502|Cizallas de pared alta|O|O||D||1
20101503|Cortadores de carbón|O|O||D||1
20101504|Cortadores de roca|O|O||D||1
20101505|Cadena de corte para minería|O|O||D||1
20101506|Barra de corte|O|O||D||1
20101600|Cribas y equipos de alimentación|O|O||D||1
20101601|Pantallas|O|O||D||1
20101602|Alimentadores|O|O||D||1
20101603|Pantalla de hoyo de desagüe|O|O||D||1
20101617|Motorreductor|O|O||D||1
20101618|Canaleta alimentadora|O|O||D||1
20101619|Banda alimentadora para pesar|O|O||D||1
20101620|Vibro – alimentador electromagnético|O|O||D||1
20101621|Vibro – alimentador electromecánico|O|O||D||1
20101700|Trituradoras, quebrantadoras y amoladores|O|O||D||1
20101701|Trituradores de roca|O|O||D||1
20101702|Trituradores de rollo|O|O||D||1
20101703|Trituradores de cono|O|O||D||1
20101704|Trituradores giratorios|O|O||D||1
20101705|Trituradores de impacto|O|O||D||1
20101706|Trituradores de mandíbula|O|O||D||1
20101707|Plantas de trituración|O|O||D||1
20101708|Molino de varilla|O|O||D||1
20101709|Molino de bola|O|O||D||1
20101710|Maquinaria de pulverización|O|O||D||1
20101711|Rompedores de roca|O|O||D||1
20101712|Moledores de roca|O|O||D||1
20101713|Moledoras de ciclón o vórtex|O|O||D||1|Molinos de ciclón o vórtices, Rectificadoras de ciclones o vórtices
20101714|Placas de mandíbula|O|O||D||1
20101715|Broca trituradora|O|O||D||1
20101716|Martillo triturador|O|O||D||1
20101800|Sistemas mecanizados de soporte en tierra|O|O||D||1
20101801|Apernador de cable|O|O||D||1
20101802|Apernador de tijera|O|O||D||1
20101803|Apernador de boom|O|O||D||1
20101804|Equipo para aplicar concreto lanzado o shotcrete|O|O||D||1|Equipo de proyección de hormigón proyectado, Equipos de pulverización de hormigón proyectado
20101805|Repuestos o accesorios de sistema mecanizado de soporte en tierra|O|O||D||1
20101810|Conmutadores|O|O||D||1
20101900|Sistemas secundarios de ruptura de roca|O|O||D||1
20101901|Sistema blockholer o taladro y cargue|O|O||D||1|Sistemas de perforación y carga
20101902|Sistemas de impacto repetitivo|O|O||D||1
20101903|Repuestos o accesorios de sistema secundario de ruptura de roca|O|O||D||1
20102000|Sistemas de exploración y desarrollo|O|O||D||1
20102001|Taladros de barreno profundo en el hoyo ith o abajo del hoyo dth|O|O||D||1
20102002|Taladros de barreo profundo de martillo superior|O|O||D||1
20102003|Jumbos neumáticos para perforación de pozos|O|O||D||1|Eje neumático hundimiento jumbos
20102004|Jumbos hidráulicos para perforación de pozos|O|O||D||1
20102005|Jumbos neumáticos de desarrollo horizontal|O|O||D||1
20102006|Jumbos hidráulicos de desarrollo horizontal|O|O||D||1
20102007|Taladros de núcleo|O|O||D||1
20102008|Repuestos o accesorios de sistema de exploración o desarrollo|O|O||D||1
20102100|Barrenas de rocas|O|O||D||1
20102101|Taladros de roca neumáticos|O|O||D||1
20102102|Taladros de roca hidráulicos|O|O||D||1
20102103|Taladros de roca manuales|O|O||D||1
20102104|Repuestos y accesorios de taladros de roca|O|O||D||1
20102105|Broca o barrena de acero|O|O||D||1
20102106|Broca o barrena de vacío|O|O||D||1
20102200|Maquinaria de cargue de explosivos|O|O||D||1
20102201|Maquinaria para cargar nitrato de amonio y fuel oil - anfo|O|O||D||1
20102202|Maquinaria para cargar emulsión|O|O||D||1
20102203|Repuestos y accesorios para maquinaria de cargue de explosivos|O|O||D||1|Repuestos y accesorios para maquinaria de carga de explosivos
20102300|Vehículos de servicio de minería subterránea|O|O||D||1
20102301|Transporte de personal|O|O||D||1
20102302|Vehículos grúa|O|O||D||1
20102303|Cama bajas para el transporte de material|O|O||D||1
20102304|Transportadores de carga a granel|O|O||D||1
20102305|Vehículos utilitarios|O|O||D||1
20102306|Vehículos de plataforma elevable o elevadores de tijera|O|O||D||1
20102307|Repuestos o accesorios de vehículo de servicio minero subterráneo|O|O||D||1
20111500|Equipo de exploración y perforación|O|O||D||1
20111504|Equipos para perforar pozos de agua|O|O||D||1
20111505|Equipo para la exploración de uranio|O|O||D||1
20111600|Maquinaria de perforación y explotación|O|O||D||1
20111601|Maquinaria de sondeo o de perforación|O|O||D||1
20111602|Maquinaria de ensamble en fondo de pozo|O|O||D||1
20111603|Martillos perforadores|O|O||D||1
20111604|Taladro sobre orugas|O|O||D||1
20111606|Vibradores neumáticos|O|O||D||1
20111607|Maquinaria para hacer túneles|O|O||D||1
20111608|Martillos de poder|O|O||D||1
20111609|Taladro de platina|O|O||D||1
20111610|Maquinaria de inspección de alcantarillas|O|O||D||1
20111611|Taladros giratorios|O|O||D||1
20111612|Taladros de perforación de pozos|O|O||D||1
20111613|Taladros de barreno profundo|O|O||D||1|Taladros para agujeros profundos
20111614|Brocas industriales|O|O||D||1
20111615|Perforadora de avance|O|O||D||1
20111616|Torre de perforación|O|O||D||1
20111617|Carros de perforación|O|O||D||1
20111618|Caña de pecar de fondo de pozo|O|O||D||1
20111619|Cono de perforación de pozos|O|O||D||1
20111620|Agarre de martillo|O|O||D||1
20111621|Oscilador de revestimiento|O|O||D||1
20111622|Taladro de circulación reversa|O|O||D||1|Taladro de circulación inversa
20111623|Almeja de diafragma de muro|O|O||D||1|Cubierta de pared de diafragma
20111700|Accesorios de perforación y explotación|O|O||D||1
20111701|Instrumentos audiovisuales para inspección de pozos|O|O||D||1
20111702|Tapones o anclajes de tubos|O|O||D||1
20111703|Recubrimientos de perforación|O|O||D||1
20111704|Pantallas de perforación|O|O||D||1
20111705|Puntos de pozo|O|O||D||1
20111706|Cuñas de perforación|O|O||D||1
20111707|Adaptadores de herramientas de perforación|O|O||D||1
20111708|Columnas de perforación|O|O||D||1
20111709|Herramientas o kits de accesorios para perforar pozos|O|O||D||1
20111710|Kit de reparación de tapones y tuberías de perforación|O|O||D||1
20111711|Partes y accesorios de tuberías de perforación|O|O||D||1
20111712|Tubo de lavado|O|O||D||1
20111713|Mástil de perforación|O|O||D||1
20111714|Conector de tubería flexible|O|O||D||1
20111715|Recubrimiento de tajo del sitio del pozo|O|O||D||1
20121000|Equipo acidificante|O|O||D||1
20121001|Unidades de mezcla acidificante|O|O||D||1
20121002|Sensores de densidad acidificante|O|O||D||1
20121003|Unidades de bombeo acidificante|O|O||D||1|Maquina de bombeo acidificante, Unidades de bombeo de acidificación
20121004|Unidades acidificantes|O|O||D||1|Maquina acidificantes, Unidades de acidificación
20121005|Tubería de aire acidificante|O|O||D||1
20121006|Inyectores de bola acidificantes|O|O||D||1
20121007|Equipo de ácido líquido a granel|O|O||D||1
20121008|Cajas de gota acidificante|O|O||D||1
20121009|Medidores de acidificación|O|O||D||1
20121010|Cajas de unión de acidificación|O|O||D||1|Cajas de conexiones acidificantes, Cajas de empalme de acidificación
20121011|Sensores de presión de acidificación|O|O||D||1
20121012|Tubería de proceso acidificante|O|O||D||1
20121013|Uniones estrechas de acidificación|O|O||D||1
20121014|Pivotes de acidificación|O|O||D||1
20121015|Hierros de tratamiento de acidificación|O|O||D||1
20121016|Protectores de árboles de acidificación|O|O||D||1
20121100|Equipo para cementar|O|O||D||1
20121101|Unidades de mezclado|O|O||D||1|Maquina de mezclado
20121102|Tapones de puente|O|O||D||1
20121103|Equipo de cemento líquido a granel|O|O||D||1
20121104|Equipo de material de cemento a granel|O|O||D||1|Equipo de materiales a granel de cemento
20121105|Sensores de densidad del cemento|O|O||D||1
20121106|Unidades de flotación de cemento a granel|O|O||D||1|Maquina de flotación de cemento a granel
20121107|Herramientas de flotación de cemento|O|O||D||1
20121108|Tapones limpiadores de equipo de flotación de cemento|O|O||D||1
20121109|Unidades de bombeo de cemento|O|O||D||1|Maquina de bombeo de cemento
20121110|Retenedores de cemento|O|O||D||1
20121111|Centralizadores|O|O||D||1
20121112|Acoples de pestillo expreso|O|O||D||1
20121113|Collares de flotación|O|O||D||1
20121114|Zapatas de flotación|O|O||D||1
20121115|Herramientas para cementación de campos petroleros|O|O||D||1
20121116|Tapones recuperables de cementación|O|O||D||1
20121118|Cabezales de cemento bajo el mar|O|O||D||1
20121119|Cabezales de cemento en superficie|O|O||D||1
20121120|Centralizador de arco|O|O||D||1
20121121|Centralizador de cuchilla|O|O||D||1
20121122|Centralizador sub de arco|O|O||D||1
20121123|Kit de herramientas de cementación|O|O||D||1|Equipo de herramientas de cementación
20121124|Kit de equipo de flotación de cemento|O|O||D||1|Equipo  de flotación de cemento
20121125|Kit de retención de cemento|O|O||D||1|Equipo retención de cemento
20121126|Partes y accesorios del centralizador|O|O||D||1
20121127|Estabilizador|O|O||D||1
20121128|Herramienta de torque y arrastre de reducción|O|O||D||1
20121129|Partes y accesorios de la herramienta de torque y arrastre de reducción|O|O||D||1
20121130|Partes y accesorios del tapón de puente|O|O||D||1
20121200|Equipo de fracturar|O|O||D||1
20121201|Equipo de fractura líquida a granel|O|O||D||1
20121202|Equipo de fractura a granel usando unidades de soporte|O|O||D||1
20121203|Unidades de control de fracturación|O|O||D||1|Maquina de control de fracturación
20121204|Sensores de densidad de fracturación|O|O||D||1
20121205|Unidades múltiples de fracturación|O|O||D||1
20121206|Equipo de transporte de fracturación usando unidades de soporte|O|O||D||1
20121207|Unidades de bombeo de fracturación|O|O||D||1|Maquina de bombeo de fracturación
20121208|Unidades de mezclado de lechada fracturación|O|O||D||1|Maquina de mezclado de lechada fracturación
20121209|Unidades de mezcla de gel|O|O||D||1|Maquina  de mezcla de gel
20121210|Misiles de fracturación|O|O||D||1|Unidades de fusión del gel
20121211|Monitores de integridad de bombeo|O|O||D||1
20121212|Tapones de servicio de fracturación|O|O||D||1
20121213|Unidades de estimulación de bombeo|O|O||D||1
20121300|Equipo de control de arena|O|O||D||1
20121301|Tapones obturadores|O|O||D||1|Unidades de bombeo de estimulación
20121302|Flotadores|O|O||D||1
20121303|Sistemas frac pack|O|O||D||1
20121304|Sistemas paquete de gravilla|O|O||D||1|Sistemas de embalaje Frac
20121305|Zapatas guía|O|O||D||1|Sistemas de paquete de Frac
20121306|Boquillas de acometida|O|O||D||1|Sistemas de embalaje de grava
20121307|Acoples de conformación|O|O||D||1|Sistemas de paquete de grava
20121308|Rebosamientos de tuberías de producción|O|O||D||1
20121309|Obturadores de control de arena|O|O||D||1
20121310|Equipo de granel líquido para control de arena|O|O||D||1
20121311|Equipo que usa unidades de soporte para control de arena a granel|O|O||D||1|Equipos de apoyo a granel de control de arena
20121312|Sensores de densidad de control de arena|O|O||D||1
20121313|Unidades múltiples de control de arena|O|O||D||1|Maquina múltiple de control de arena
20121314|Equipo de transporte de arena usando unidades de soporte|O|O||D||1
20121315|Unidades control de bombeo de arena|O|O||D||1
20121316|Pantallas de control de arena|O|O||D||1
20121317|Unidades de mezclado de lechada control de arena|O|O||D||1|Maquina de mezclado de lechada control de arena
20121318|Detectores de arena|O|O||D||1
20121319|Localizadores de ensamble de sello|O|O||D||1
20121320|Uniones de cizalla|O|O||D||1|Empalmes de esquileo, Juntas de corte
20121321|Herramientas de levantamiento de manga|O|O||D||1
20121322|Mangas deslizantes|O|O||D||1|Herramientas de desplazamiento para sistemas de manguitos
20121323|Cuerdas de velocidad|O|O||D||1|Cadenas de velocidad
20121324|Anillo de control de arena|O|O||D||1
20121325|Patrón de tubo muescado|O|O||D||1|Patrón de tubería ranurada, Patrón de tubo ranurado
20121326|Partes y accesorios de pantalla de control de arena|O|O||D||1
20121400|Herramientas y equipo de terminación|O|O||D||1|Herramientas y equipo de acabado
20121401|Subs de atrapado de bola|O|O||D||1
20121402|Uniones de voladura|O|O||D||1
20121403|Boquillas de voladura|O|O||D||1
20121404|Tapón calibrador de cierre|O|O||D||1
20121405|Dispositivos de circulación de producción|O|O||D||1
20121406|Equipo de prueba de culminación|O|O||D||1
20121407|Protectores de línea de control|O|O||D||1
20121408|Herramientas de deflexión|O|O||D||1
20121409|Uniones de expansión de culminación|O|O||D||1
20121410|Acoples de flujo|O|O||D||1
20121411|Equipo de elevación de gas|O|O||D||1
20121412|Herramientas de estabilización de colgador|O|O||D||1
20121413|Bombas hidráulicas de culminación|O|O||D||1
20121414|Herramientas hidráulicas de curado|O|O||D||1
20121415|Sistemas de inyección|O|O||D||1
20121416|Boquillas de estabilización|O|O||D||1
20121417|Colgadores de línea|O|O||D||1
20121418|Herramientas de halar tapones|O|O||D||1
20121419|Herramientas de correr tapones|O|O||D||1
20121420|Tapones de producción|O|O||D||1
20121421|Equipos de bombeo a través de la línea de flujo|O|O||D||1
20121422|Uniones de seguridad de culminación|O|O||D||1
20121423|Ensambles de sello de culminación|O|O||D||1
20121424|Sello hoyo u hoyo pulido|O|O||D||1
20121425|Mandriles de bolsillos laterales|O|O||D||1
20121427|Válvulas de seguridad sub – superficie|O|O||D||1
20121428|Uniones de desplazamiento|O|O||D||1
20121429|Anclajes de tubería|O|O||D||1
20121430|Ensamblajes de flujo paralelo|O|O||D||1
20121431|Tapón inflable|O|O||D||1|Embalador inflable, Empacador inflable
20121432|Partes y accesorios de válvula de control de pozo|O|O||D||1
20121433|Kit de reparación de culminación de hoyo revestido|O|O||D||1|Equipo de reparación de culminación de hoyo revestido, Equipo de reparación de terminación de entubado
20121434|Kit de reparación de manga deslizante|O|O||D||1|Equipo de reparación de mango deslizante
20121435|Kit adaptador de fraguado|O|O||D||1|Equipo adaptador de ajuste, Equipo adaptador de fraguado
20121436|Partes y accesorios para el sistema de muelle de pistón|O|O||D||1
20121437|Partes y accesorios para las válvulas de seguridad de sub – superficie|O|O||D||1
20121438|Partes y accesorios para válvula de muelle de  gas|O|O||D||1
20121439|Mandril tapón de producción|O|O||D||1
20121440|Sub tapón de revestimiento del anillo|O|O||D||1
20121441|Herramienta de fraguado del revestimiento|O|O||D||1
20121442|Bloque de arrastre|O|O||D||1
20121443|Kit de herramientas de fraguado de tapón de revestimiento|O|O||D||1|Equipo de herramientas de fraguado de tapón de revestimiento
20121444|Kit de reparación del sistema de revestimiento|O|O||D||1|Equipo de reparación del sistema de revestimiento
20121445|Accesorios y partes|O|O||D||1|Accesorios y piezas de empacador de producción, Piezas y accesorios de embalaje de producción
20121446|Tapón superior revestimiento|O|O||D||1
20121447|Collar fraguado del revestimiento|O|O||D||1
20121448|Junk bonnet|O|O||D||1
20121449|Equipo de muelle de pistón|O|O||D||1
20121450|Mandril muelle de gas|O|O||D||1
20121451|Válvula muelle de gas|O|O||D||1
20121500|Herramientas convencionales de perforación|O|O||D||1
20121501|Preventor de reventones|O|O||D||1
20121502|Controles del preventor de reventones|O|O||D||1
20121503|Raspadores de revestimiento|O|O||D||1|Raspadores de carcasa
20121504|Collar de perforación|O|O||D||1
20121505|Equipo de núcleos|O|O||D||1
20121506|Protectores de rosca de tubería de perforación|O|O||D||1
20121507|Uniones de herramientas de tubería de perforación|O|O||D||1
20121508|Tubo de perforación|O|O||D||1
20121509|Anillos de calibre|O|O||D||1
20121510|Abridores de hoyos|O|O||D||1
20121511|Escariadores de hoyos|O|O||D||1|Escariadores de orificios
20121513|Amortiguadores de fondo de pozo|O|O||D||1
20121514|Subs de perforación|O|O||D||1|Submarinos de perforación
20121515|Estabilizadores de fondo de pozo|O|O||D||1
20121516|Propulsores|O|O||D||1
20121517|Partes y accesorios de escariadores de hoyos de perforación|O|O||D||1
20121518|Cabeza de control giratorio|O|O||D||1
20121519|Partes y accesorios de la cabeza de control giratorio|O|O||D||1
20121520|Partes y accesorios del preventor de reventones|O|O||D||1
20121521|Partes y accesorios de los amortiguadores de fondo de pozo|O|O||D||1
20121522|Partes y accesorios de los raspadores de revestimiento|O|O||D||1
20121523|Tarro de perforación|O|O||D||1
20121524|Partes y accesorios del tarro de perforación|O|O||D||1
20121600|Brocas de barrena|O|O||D||1
20121601|Brocas de cortadora fija|O|O||D||1
20121602|Brocas de diamante natural|O|O||D||1
20121603|Brocas de boquilla|O|O||D||1
20121604|Brocas pdc|O|O||D||1
20121605|Brocas cónicas de rodillo de botón de inserción|O|O||D||1
20121606|Brocas de rodillo de diente de acero|O|O||D||1
20121607|Brocas de núcleo|O|O||D||1
20121608|Brocas de bloque|O|O||D||1
20121609|Brocas de minería continuas|O|O||D||1
20121610|Brocas de alimentador|O|O||D||1
20121611|Broca de tamaño grande|O|O||D||1
20121612|Broca de techo|O|O||D||1
20121613|Accesorios de broca|O|O||D||1
20121700|Herramientas de pesca|O|O||D||1
20121701|Bumper subs|O|O||D||1
20121702|Parches de revestimiento|O|O||D||1
20121703|Impulsores de tarro|O|O||D||1
20121704|Subs de chatarra|O|O||D||1
20121705|Molinos o zapatas de quemado|O|O||D||1
20121706|Rebosamientos|O|O||D||1
20121707|Lanzas de pesca en campo petrolero|O|O||D||1
20121708|Herramientas de pesca no especificada|O|O||D||1
20121709|Tubo y extensión de lavado de pesca|O|O||D||1
20121710|Extensión de rebosamiento|O|O||D||1
20121711|Sub de pesca|O|O||D||1
20121712|Partes y accesorios de parche de revestimiento|O|O||D||1
20121713|Buje de operación de tubo de lavado|O|O||D||1
20121714|Bloque de impresión de pesca|O|O||D||1
20121715|Kit de pesca de sistema de cable de acero|O|O||D||1|Equipo de pesca de sistema de línea de alambre
20121716|Partes y accesorios de la canasta de chatarra|O|O||D||1
20121717|Pescante de agarre|O|O||D||1
20121718|Control de pescante|O|O||D||1
20121719|Tapón de pescante|O|O||D||1
20121720|Partes y accesorios de pescante|O|O||D||1
20121721|Imán de pesca|O|O||D||1
20121722|Grifo de ajuste|O|O||D||1
20121723|Agarre de lanza de pescar|O|O||D||1
20121724|Partes y accesorios de lanza de pescar|O|O||D||1
20121725|Cortador de revestimiento|O|O||D||1
20121726|Grifo de caja|O|O||D||1
20121727|Canasta de desperdicios|O|O||D||1
20121728|Tarro de pesca|O|O||D||1
20121800|Equipo de perforación direccional|O|O||D||1
20121801|Herramientas de geo - dirección|O|O||D||1
20121802|Motores de lodo|O|O||D||1
20121803|Herramientas dirigibles giratorias|O|O||D||1
20121804|Sistemas de control de superficie de perforación direccional|O|O||D||1
20121805|Herramientas de perforación direccional de hoyo derecho|O|O||D||1
20121806|Registro mientras herramientas perforan lwd|O|O||D||1|Registro de herramientas de perforación LWD
20121807|Partes y accesorios de registro mientras herramientas perforan lwd|O|O||D||1
20121808|Estabilizador de perforación direccional|O|O||D||1
20121809|Partes y accesorios de herramientas dirigibles giratorias|O|O||D||1
20121810|Sub de taladro direccional|O|O||D||1
20121811|Hélice de perforación direccional|O|O||D||1
20121812|Collar de perforación direccional|O|O||D||1
20121813|Partes y accesorios de motores de lodo|O|O||D||1
20121900|Equipo de medir y registro del pozo|O|O||D||1
20121901|Herramientas acústicas|O|O||D||1
20121902|Instrumentos de control de perforación o lodo|O|O||D||1
20121903|Herramientas de medición de desempeño de perforación|O|O||D||1
20121904|Equipo de medición de flujo|O|O||D||1
20121905|Herramientas de resonancia magnética nuclear|O|O||D||1
20121906|Herramientas nucleares|O|O||D||1
20121907|Equipos de registro de producción|O|O||D||1
20121908|Herramientas de resistividad|O|O||D||1
20121909|Sistemas de levantamiento|O|O||D||1
20121910|Sistemas de telemetría|O|O||D||1
20121911|Herramientas ultrasónicas|O|O||D||1
20121912|Equipo de presión de registro de fondo de pozo|O|O||D||1
20121913|Equipo de prueba de registro de fondo de pozo|O|O||D||1
20121914|Unidades de registro de pozo|O|O||D||1
20121915|Registro de densidad de granel|O|O||D||1
20121916|Cable de fondo de pozo de sensor óptico|O|O||D||1
20121917|Mandril y accesorios de sensor óptico|O|O||D||1
20121918|Cable de superficie de sensor óptico|O|O||D||1
20121919|Herramientas y accesorios de inspección de revestimiento|O|O||D||1
20121920|Herramientas y accesorios de indicador de punto libre|O|O||D||1
20121921|Medidor de radiación|O|O||D||1
20121922|Partes y accesorios de herramienta de rayos gamma|O|O||D||1
20121923|Herramientas y partes de imaginería de pozo|O|O||D||1|Herramienta y piezas de imagen de pozo
20122000|Equipo de prueba y Accesorios|O|O||D||1
20122001|Barra de desplazamiento|O|O||D||1
20122002|Mangas de desplazamiento|O|O||D||1
20122003|Conejo de desplazamiento|O|O||D||1
20122004|Accesorios de prueba|O|O||D||1
20122005|Boquillas de prueba|O|O||D||1
20122006|Tapones de prueba|O|O||D||1
20122100|Equipo de Perforación|O|O||D||1
20122101|Pistolas de cápsulas|O|O||D||1
20122102|Pistolas de revestimiento|O|O||D||1
20122103|Cabezas de despliegue|O|O||D||1
20122104|Explosivos de perforación|O|O||D||1
20122105|Cabezas de disparo|O|O||D||1
20122106|Adaptadores de pistola|O|O||D||1
20122107|Pistola de disparo de alta densidad|O|O||D||1
20122108|Tapones bull de perforación|O|O||D||1
20122109|Herramientas de poner tapones|O|O||D||1
20122110|Equipo de posicionamiento de perforación|O|O||D||1
20122111|Pistolas festoneadas|O|O||D||1
20122112|Subs en tándem|O|O||D||1
20122113|Accesorios de pistola de perforación de tubos completa|O|O||D||1
20122114|Pistola de perforación de tubos completa|O|O||D||1
20122115|Subs ventilación bajo balance|O|O||D||1
20122200|Equipo de prueba del pozo|O|O||D||1
20122201|Booms de bengalas|O|O||D||1
20122202|Quemadores de bengalas|O|O||D||1
20122203|Herramientas de prueba de hoyo|O|O||D||1
20122204|Colector del choke|O|O||D||1|Colectores de estrangulamiento
20122205|Colector de desviación|O|O||D||1
20122206|Canastas de flowhead|O|O||D||1
20122207|Pivote de flowhead|O|O||D||1
20122208|Flowheads|O|O||D||1
20122209|Herramientas de formación de cierre|O|O||D||1
20122210|Bengalas de gas|O|O||D||1
20122211|Analizadores de gas de lodos|O|O||D||1
20122212|Muestreadores de petróleo|O|O||D||1
20122213|Separadores de pruebas de pozo|O|O||D||1
20122214|Tubería de superficie de pruebas de pozo|O|O||D||1
20122215|Tanques de compensación|O|O||D||1
20122216|Herramientas de prueba de fondo de pozo|O|O||D||1
20122300|Equipo de Slickline - Cable de Recuperación|O|O||D||1
20122301|Cabezas de adaptador de cable de recuperación|O|O||D||1
20122302|Retardo de envío del cable de recuperación|O|O||D||1
20122303|Guías de campana de cable de recuperación|O|O||D||1
20122304|Cajas ciegas de cable de recuperación|O|O||D||1
20122305|Equipo de presión de fondo de hoyo de cable de recuperación|O|O||D||1
20122306|Herramientas de calibración de cable de recuperación|O|O||D||1
20122307|Volcado de cemento de rescate de equipos cable de recuperación|O|O||D||1
20122308|Cortadores químicos de cable de recuperación|O|O||D||1
20122309|Centralizadores de cadena de herramientas de almeja de cable de recuperación|O|O||D||1
20122310|Centralizadores de cable de acero de almeja de cable de recuperación|O|O||D||1|Pinza Slickline en centralizadores de cadena de herramienta
20122311|Localizadores de collar de cable de recuperación|O|O||D||1
20122312|Colectores de cable de recuperación|O|O||D||1
20122313|Herramientas de colisión de cable de recuperación|O|O||D||1
20122314|Cruces de cable de recuperación|O|O||D||1
20122315|Equipo de medición de profundidad de cable de recuperación|O|O||D||1
20122316|Frasco dewar de cable de recuperación|O|O||D||1
20122317|Herramientas del dipmeter de cable de recuperación|O|O||D||1
20122318|Herramientas direccionales de cable de recuperación|O|O||D||1
20122319|Herramientas de vaya con el diablo de cable de recuperación|O|O||D||1
20122320|Abridores de hoyos de cable de recuperación|O|O||D||1
20122321|Cortadores jet de cable de recuperación|O|O||D||1
20122322|Disparos de desperdicios de cable de recuperación|O|O||D||1
20122323|Herramientas de kickover de cable de recuperación|O|O||D||1
20122324|Uniones de nudillos de cable de recuperación|O|O||D||1
20122325|Bloques de impresión de cable de recuperación|O|O||D||1
20122326|Mandriles de ubicación de cable de recuperación|O|O||D||1
20122327|Mandriles de bloqueo de cable de recuperación|O|O||D||1
20122328|Lubricadores de cable de recuperación|O|O||D||1
20122329|Achicadores mecánicos de cable de recuperación|O|O||D||1
20122330|Plugback mecánico de cable de recuperación|O|O||D||1
20122331|Otras herramientas de cable de recuperación|O|O||D||1
20122332|Raspadores de parafina de cable de recuperación|O|O||D||1
20122333|Enchufe de línea de cable de recuperación|O|O||D||1
20122334|Tenazas para halar o correr el cable de recuperación|O|O||D||1|Pinzas Slickline para correr y tirar
20122335|Herramientas para cortar el cable de recuperación|O|O||D||1
20122336|Roldanas o bloques de piso de la cable de recuperación|O|O||D||1
20122338|Accesorios de herramientas para halar el cable de recuperación|O|O||D||1|Accesorios para herramientas de tracción Slickline
20122339|Herramientas para halar el cable de recuperación|O|O||D||1|Herramientas de tracción Slickline
20122340|Herramientas para correr el cable de recuperación|O|O||D||1
20122341|Unidades de cable de recuperación|O|O||D||1
20122342|Alambre del cable de recuperación|O|O||D||1
20122343|Herramientas sónicas del cable de recuperación|O|O||D||1
20122344|Barras espaciadoras del cable de recuperación|O|O||D||1
20122345|Terminales de prensado del cable de recuperación|O|O||D||1
20122346|Dispositivos de tensión del cable de recuperación|O|O||D||1
20122347|Tapones de tubos de cable de recuperación|O|O||D||1
20122348|Herramientas ultrasónicas cable de recuperación|O|O||D||1
20122349|Agarres del cable de recuperación|O|O||D||1
20122350|Tarros del cable de recuperación|O|O||D||1
20122351|Raspadores del cable de recuperación|O|O||D||1
20122352|Lanza del cable de recuperación|O|O||D||1
20122353|Tallos del cable de recuperación|O|O||D||1
20122354|Válvulas del cable de recuperación|O|O||D||1
20122356|Preventores del cable de recuperación|O|O||D||1
20122357|Aceleradores de tarro del cable de recuperación|O|O||D||1
20122358|Dardo de prueba|O|O||D||1
20122359|Accesorios y partes de herramientas de corrida del cable de recuperación|O|O||D||1
20122360|Punzón de la línea de cable|O|O||D||1
20122361|Válvula de pie|O|O||D||1
20122362|Guía de campana de la línea de cable|O|O||D||1
20122363|Hallador de cable|O|O||D||1
20122364|Cadena de herramientas de línea de cable|O|O||D||1
20122365|Partes y accesorios del centralizador de cable de recuperación|O|O||D||1
20122366|Descentralizador magnético|O|O||D||1
20122367|Herramienta de alado de la línea de cable|O|O||D||1
20122368|Mandril de la línea de cable|O|O||D||1
20122369|Herramienta de establecer línea de cable|O|O||D||1
20122370|Cruce de línea de cable|O|O||D||1
20122371|Centralizador de cable de recuperación|O|O||D||1
20122372|Acople de pivote de línea de cable|O|O||D||1
20122373|Partes y accesorios de herramienta de kickover del cable de recuperación|O|O||D||1
20122400|Equipo de sistemas de producción|O|O||D||1
20122401|Dispositivo golpeador de cable|O|O||D||1
20122402|Evaporadores de producción de campo de petróleo|O|O||D||1
20122403|Probadores hipot|O|O||D||1
20122404|Maquinas de vueltas de campo de petróleo|O|O||D||1
20122405|Elevadores finales de motor|O|O||D||1
20122406|Probadores dieléctricos de aceite|O|O||D||1
20122407|Unidades de llenado al vacío de aceite|O|O||D||1
20122408|Enderezadores de eje de producción de campo petrolero|O|O||D||1
20122409|Bobina de producción de campo de petróleo|O|O||D||1
20122410|Analizadores de vibración|O|O||D||1
20122500|Equipo para tubería flexible|O|O||D||1
20122501|Herramientas de arenadora|O|O||D||1
20122502|Unidades de camión grúa de tubería flexible|O|O||D||1
20122503|Unidades de tubería flexible|O|O||D||1|Cespol
20122504|Paquetes de manguera de tubería flexible|O|O||D||1
20122505|Sistemas inflables de tubería flexible|O|O||D||1
20122506|Cabezales de inyector de tubería flexible|O|O||D||1
20122507|Equipo de elevación de tubería flexible|O|O||D||1
20122508|Casas de operadores|O|O||D||1
20122509|Fuentes de poder de tubería flexible|O|O||D||1
20122510|Rollos de tubería flexible|O|O||D||1
20122511|Carretes de embobinar tubería flexible|O|O||D||1
20122512|Guías de tubería|O|O||D||1
20122513|Enganches de boca de pozo|O|O||D||1
20122514|Estructuras de soporte de boca de pozo|O|O||D||1
20122515|Tubería flexible de campo petrolero|O|O||D||1
20122516|Cadena de herramientas de tubería flexible|O|O||D||1
20122518|Centralizador de tubería flexible|O|O||D||1
20122600|Equipo sísmico|O|O||D||1
20122601|Sensores análogos sísmicos|O|O||D||1
20122602|Arreglos sísmicos|O|O||D||1
20122603|Aves de cable de serpentina sísmica|O|O||D||1
20122604|Tanqueros de taladro sísmico|O|O||D||1
20122605|Geófonos sísmicos|O|O||D||1
20122606|Sistemas de gravedad sísmicos|O|O||D||1
20122607|Sistemas de malacate de cañón sísmico|O|O||D||1
20122608|Hidrofonos sísmicos|O|O||D||1
20122609|Fuentes de impulso sísmicos|O|O||D||1
20122610|Cables serpentinas marinos sísmicos|O|O||D||1
20122611|Cables del fondo del océano sísmico|O|O||D||1
20122612|Sistemas magnéticos sísmicos|O|O||D||1
20122613|Equipo de posicionar sísmico|O|O||D||1
20122614|Arietes sísmicos|O|O||D||1
20122615|Receptores sísmicos|O|O||D||1
20122616|Sistemas de refracción sísmicos|O|O||D||1
20122617|Controladores de fuente sísmicos|O|O||D||1
20122618|Dispositivos de bobinar sísmicos|O|O||D||1
20122619|Bloques de remolque sísmicos|O|O||D||1
20122620|Puntos de remolque sísmicos|O|O||D||1
20122621|Vibradores sísmicos|O|O||D||1
20122622|Sistemas de grabar sísmicos|O|O||D||1
20122623|Sistemas de procesamiento de datos sísmicos|O|O||D||1
20122700|Mercancía tubular para campo petrolero|O|O||D||1
20122701|Revestimiento para campo petrolero|O|O||D||1
20122702|Acoples para campo petrolero|O|O||D||1
20122703|Tubería corta para campo petrolero|O|O||D||1
20122704|Tubería para campo petrolero|O|O||D||1
20122705|Recubrimiento de tubería para campo petrolero|O|O||D||1
20122706|Revestimiento de conductor|O|O||D||1
20122707|Equipo para operar el revestimiento para conductor|O|O||D||1
20122708|Cruces de la tubería de perforación|O|O||D||1
20122709|Protectores de rosca para campo petrolero|O|O||D||1
20122710|Dispositivo para parar el revestimiento|O|O||D||1
20122800|Equipo y plataformas de reacondicionamiento y perforación|O|O||D||1
20122801|Agitadores de lodos|O|O||D||1
20122802|Depósitos de lodos|O|O||D||1
20122803|Equipo de aire para perforaciones|O|O||D||1
20122804|Taladros en barcazas|O|O||D||1
20122806|Desviadores de fluido|O|O||D||1
20122807|Aparejos de maniobras|O|O||D||1
20122808|Equipo para lecho de perforación|O|O||D||1
20122809|Pivotes de perforación|O|O||D||1
20122810|Barco – taladro de perforación|O|O||D||1
20122811|Elevadores de taladro de perforación|O|O||D||1
20122812|Estribos del taladro de perforación|O|O||D||1
20122813|Unidades de reacondicionamiento hidráulico|O|O||D||1
20122814|Sistemas de gatos para mover el taladro de perforación|O|O||D||1
20122815|Taladro de perforación marina movido con gatos|O|O||D||1
20122816|Bujes kelly|O|O||D||1
20122817|Válvulas kelly|O|O||D||1
20122818|Escobillas kelly|O|O||D||1
20122819|Kellys|O|O||D||1
20122820|Taladro de perforación en tierra|O|O||D||1
20122821|Equipo de limpieza de lodo|O|O||D||1
20122822|Múltiples para lodo|O|O||D||1
20122823|Mezcladoras de lodo|O|O||D||1
20122824|Equipo para manejo de tubería|O|O||D||1
20122825|Plataforma de taladro de perforación|O|O||D||1
20122826|Pivote de energía o transmisión superior|O|O||D||1
20122827|Patines para taladro|O|O||D||1
20122828|Elevadores del taladro de perforación|O|O||D||1
20122829|Mesas giratorias de taladro de perforación|O|O||D||1
20122830|Plataformas auto – elevadoras para el reacondicionamiento|O|O||D||1
20122831|Taladros de perforación semi – sumergibles|O|O||D||1
20122832|Deslizadores del lecho de perforación|O|O||D||1
20122833|Tenazas de reposición|O|O||D||1
20122834|Llave doble automática|O|O||D||1
20122835|Equipo viajero|O|O||D||1
20122836|Barcos de reacondicionamiento|O|O||D||1
20122837|Taladros de reacondicionamiento|O|O||D||1
20122838|Separadores de lodo (lutita)|O|O||D||1
20122839|Desgasificadores de lodo|O|O||D||1
20122840|Bloques de corona|O|O||D||1
20122841|Bloques móviles|O|O||D||1
20122842|Desarenadores de lodo|O|O||D||1
20122843|Separadores de granos finos de lodo|O|O||D||1
20122844|Tenazas de energía|O|O||D||1|Pinzas eléctricas
20122845|Partes y accesorios para el manejo de tubería|O|O||D||1
20122846|Trampolín|O|O||D||1
20122847|Sub y enchufe de elevador|O|O||D||1
20122848|Dispositivo de arreglo horizontal o unidad de trepidación|O|O||D||1
20122849|Araña de revestimiento de pozo|O|O||D||1
20122851|Unidad de potencia hidráulica|O|O||D||1
20122900|Equipo de registrar datos de superficie|O|O||D||1
20122901|Conductos de registrar datos de superficie|O|O||D||1
20122902|Sensores de registrar datos de superficie|O|O||D||1
20122903|Unidades de registrar datos de superficie|O|O||D||1
20123000|Equipo multilateral|O|O||D||1
20123001|Revestimiento multilateral|O|O||D||1
20123002|Uniones multilaterales|O|O||D||1
20123003|Tapones multilaterales|O|O||D||1
20123004|Partes y accesorios de tapones multilaterales|O|O||D||1
20123100|Herramienta para salida de revestimientos|O|O||D||1
20123101|Herramienta de ajuste de salida de revestimientos|O|O||D||1
20123102|Whipstock de salida de revestimientos|O|O||D||1
20123200|Equipo de expansión en profundidad|O|O||D||1
20123201|Herramienta ranurada de ajuste expandible|O|O||D||1
20123202|Kit de reparación expandible|O|O||D||1
20123203|Revestimiento expandible|O|O||D||1
20123300|Herramientas para revestimientos mientras se perfora|O|O||D||1
20123301|Zapata de taladro|O|O||D||1
20123302|Partes y accesorios de zapata de taladro|O|O||D||1
20123303|Lanza de taladro|O|O||D||1
20123304|Partes y accesorios de lanza de taladro|O|O||D||1
20131000|Lodo de perforar y materiales|O|O||D||1
20131001|Agentes de control de filtración|O|O||D||1
20131002|Espaciadores de fluido|O|O||D||1
20131003|Agentes de circulación perdida|O|O||D||1
20131004|Lodos con base de petróleo|O|O||D||1
20131005|Aumentadores de la rata de penetración|O|O||D||1
20131006|Fluidos centradores|O|O||D||1
20131007|Lodos con base sintética|O|O||D||1
20131008|Agentes para adelgazar el lodo|O|O||D||1
20131009|Lodos con base en agua|O|O||D||1
20131010|Agentes para engruesar el lodo|O|O||D||1
20131100|Apuntalantes de fracturamiento de pozo|O|O||D||1
20131101|Apuntaladores cerámicos|O|O||D||1
20131102|Arenas de fracturación|O|O||D||1
20131103|Apuntaladores cerámicos cubiertos de resina|O|O||D||1
20131104|Arenas de fracturación cubiertas de resina|O|O||D||1
20131105|Bauxitas sinterizadas cubierta de resina|O|O||D||1
20131106|Bauxitas sinterizadas|O|O||D||1
20131200|Fluidos de completar|O|O||D||1
20131201|Salmueras divalentes|O|O||D||1
20131202|Salmueras monovalentes|O|O||D||1
20131300|Cemento de pozo petrolero|O|O||D||1
20131301|Cemento a granel de pozo petrolero|O|O||D||1
20131302|Pozo petrolero cemento tipo i clase a|O|O||D||1
20131303|Pozo petrolero cemento tipo ii clase b|O|O||D||1
20131304|Pozo petrolero cemento clase c|O|O||D||1
20131305|Pozo petrolero cemento clase g|O|O||D||1
20131306|Pozo petrolero cemento clase h|O|O||D||1
20131307|Cemento liviano de pozo petrolero|O|O||D||1
20131308|Pozo petrolero cemento estándar fino tipo iii|O|O||D||1
20141000|Equipo de cabeza de pozo|O|O||D||1
20141001|Actuadores de boca de pozo|O|O||D||1
20141002|Bombas de balancín de boca de pozo|O|O||D||1
20141003|Líneas de flujo de boca de pozo|O|O||D||1
20141004|Válvulas de compuerta de boca de pozo|O|O||D||1
20141005|Reguladores de producción de boca de pozo|O|O||D||1
20141006|Accesorios de boca de pozo o flujo debajo de la superficie de boca de pozo|O|O||D||1
20141007|Accesorios de boca de pozo o flujo de superficie de boca de pozo|O|O||D||1
20141008|Válvulas de seguridad de la superficie de boca de pozo|O|O||D||1
20141011|Adaptador de cabeza de tubería|O|O||D||1
20141012|Revestimiento del cabezal de la carcasa|O|O||D||1
20141013|Carrete del cabezal de la tubería|O|O||D||1
20141014|Carrete del cabezal del revestimiento|O|O||D||1
20141015|Conexiones en t o en cruz de la boca de pozo|O|O||D||1
20141016|Base de llegada de la boca de pozo|O|O||D||1
20141017|Cuerpo de transporte boca de pozo|O|O||D||1
20141018|Colgador de boca de pozo|O|O||D||1
20141100|Sistemas de inyección químicos|O|O||D||1
20141101|Sistemas de inyección de parafina|O|O||D||1
20141200|Equipo de desarenar|O|O||D||1
20141201|Equipo de desarenar producción|O|O||D||1
20141300|Anclas y bombas de chorro de barrenas hacia abajo|O|O||D||1
20141301|Bombas de chorro de fondo de pozo|O|O||D||1
20141302|Partes y accesorios de bombas de chorro de fondo de pozo|O|O||D||1
20141303|Tubería de perforación|O|O||D||1
20141400|Accesorios de producción de barrenas hacia abajo|O|O||D||1
20141401|Topes de tubería|O|O||D||1
20141500|Bombas de barrenas hacia abajo|O|O||D||1
20141501|Bombas eléctricas de fondo de pozo|O|O||D||1
20141502|Bomba de fondo de pozo de cavidad progresiva|O|O||D||1
20141600|Bombas de exportación|O|O||D||1
20141601|Bombas neumáticas de exportación|O|O||D||1
20141700|Plataformas de almacenaje y producción a poca distancia de la costa|O|O||D||1
20141701|Plataformas fijas de producción costa afuera|O|O||D||1
20141702|Plataformas flotantes de producción costa afuera|O|O||D||1
20141703|Plataformas flotantes de almacenamiento costa afuera|O|O||D||1
20141704|Plataformas flotantes de brazo de tensión de producción costa afuera|O|O||D||1
20141705|Plataformas flotantes de brazo de tensión de almacenamiento costa afuera|O|O||D||1
20141800|Contadores para medir el flujo de producción del pozo|O|O||D||1
20141801|Contadores de la turbina de gas de producción del pozo|O|O||D||1
20141900|Equipo de tratamiento de gas|O|O||D||1
20141901|Equipo de tratamiento de gas para producción del pozo|O|O||D||1
20142000|Regeneradores de glicol|O|O||D||1
20142001|Regeneradores de glicol de pozo petrolero|O|O||D||1
20142100|Tratadores de calentadores|O|O||D||1
20142101|Tratadores de calentadores de aceite para pozo|O|O||D||1
20142200|Calentadores de línea|O|O||D||1
20142201|Calentadores de línea eléctrica|O|O||D||1
20142300|Deslizaderos de inyección de producción|O|O||D||1
20142301|Patines de inyección neumática de metanol|O|O||D||1
20142400|Equipo para el lecho del océano|O|O||D||1
20142401|Equipo para producción submarina de boca de pozo|O|O||D||1
20142402|Tuberías submarinas umbilicales o flexibles|O|O||D||1
20142403|Sistema múltiple de distribución de producción submarina|O|O||D||1
20142404|Sistema de bombeo y separación anular vertical|O|O||D||1
20142405|Cruz de producción y componente submarino|O|O||D||1
20142406|Sistema de control submarino|O|O||D||1
20142407|Ensamble de terminación umbilical submarina|O|O||D||1
20142500|Equipo para tratar agua producida|O|O||D||1
20142501|Centrífugas de petróleo del agua del campo petrolífero|O|O||D||1
20142600|Instrumentación del sistema de control de producción|O|O||D||1
20142601|Sistemas inalámbricos de control de producción|O|O||D||1
20142700|Unidades de bombear|O|O||D||1
20142701|Gatos de la varilla de bombeo|O|O||D||1
20142702|Bombas de barra|O|O||D||1
20142703|Bombas de barra mecánica|O|O||D||1
20142704|Ensamble de marco de bombeo y extensión|O|O||D||1
20142705|Ensamble de biela|O|O||D||1
20142706|Ensamble de ecualizador pitman|O|O||D||1
20142707|Ensamble de cabezote|O|O||D||1
20142708|Ensamble de puesto samson|O|O||D||1
20142709|Ensamble de viga de caminar|O|O||D||1
20142710|Ensamble de barra de colgador|O|O||D||1
20142800|Separadores de producción|O|O||D||1
20142801|Separadores de agua petróleo|O|O||D||1
20142900|Tanques y recipientes almacenadores|O|O||D||1
20142901|Tanques almacenadores de petróleo|O|O||D||1
20142902|Tanque de fibra de vidrio|O|O||D||1
20142903|Tanque de acero|O|O||D||1
20142904|Tanque plástico|O|O||D||1
20142905|Tanque receptor de aire|O|O||D||1
20143000|Vástagos de succión|O|O||D||1
20143001|Vástagos de succión de aleación de acero|O|O||D||1
20143002|Varillas cortas|O|O||D||1
20143003|Vástago continuo de succión|O|O||D||1
20143004|Pin de terminación roscada de vástago continuo de succión|O|O||D||1
20143005|Acople deslizante de vástago continuo de succión|O|O||D||1
20143300|Equipo para servicio de oleoductos|O|O||D||1
20143301|Dispositivo limpiador de oleoductos|O|O||D||1
20143302|Equipo para inspeccionar el interior del oleoducto|O|O||D||1
20143303|Cortador robótico del interior del oleoducto|O|O||D||1
21101500|Maquinaria agrícola para preparación del suelo|O|O||D||1
21101501|Arados|O|O||D||1
21101502|Pulverizadores|O|O||D||1
21101503|Cultivadoras|O|O||D||1
21101504|Desmalezadoras|O|O||D||1
21101505|Máquinas desyerbadoras|O|O||D||1
21101506|Máquinas aplanadoras o niveladoras|O|O||D||1
21101507|Rodillos agrícolas|O|O||D||1
21101508|Rodillos para prados o terrenos deportivos|O|O||D||1
21101509|Máquina para drenaje de zanjas|O|O||D||1
21101511|Chorros de riego|O|O||D||1
21101512|Gastos generales de riego|O|O||D||1
21101513|Discos|O|O||D||1
21101514|Arados de subsuelo|O|O||D||1
21101516|Sembradoras|O|O||D||1
21101517|Motocultivador giratorio o de potencia|O|O||D||1
21101518|Esterilizador de suelo|O|O||D||1
21101519|Inyector de suelo|O|O||D||1
21101520|Lanzallamas|O|O||D||1
21101521|Mezclador de fertilizante|O|O||D||1
21101522|Arado de bordes o arado|O|O||D||1
21101523|Sistema automatizado de manejo de maquinaria agrícola|O|O||D||1
21101600|Maquinaria agrícola para siembra y plantado|O|O||D||1
21101601|Plantadoras|O|O||D||1
21101602|Transplantadoras|O|O||D||1
21101603|Sembradoras de grano|O|O||D||1
21101604|Sembradoras de semillas|O|O||D||1
21101605|Equipo para tratamiento de semillas|O|O||D||1
21101606|Excavadoras de agujeros|O|O||D||1
21101607|Remolque de sembradora|O|O||D||1
21101608|Gabinete o cámara para crecimiento de plantas|O|O||D||1
21101609|Cama de semillas (semillero)|O|O||D||1
21101610|Máquina de cubrimiento del suelo|O|O||D||1
21101611|Controlador de tasa de flujo de fertilizante|O|O||D||1
21101612|Germinador de semillas|O|O||D||1
21101700|Maquinaria agrícola para cosechar|O|O||D||1
21101701|Cortadoras de pasto|O|O||D||1
21101702|Máquina segadora de heno|O|O||D||1
21101703|Cosechadoras|O|O||D||1
21101704|Cosechadoras “trilladoras” o mixtas|O|O||D||1
21101705|Trilladoras|O|O||D||1
21101706|Separadores de cultivos|O|O||D||1
21101707|Piezas de cosechadora o accesorios|O|O||D||1
21101708|Piezas de segadora o accesorios|O|O||D||1
21101709|Embaladora|O|O||D||1
21101710|Secadora de cosecha|O|O||D||1
21101711|Desgranadora|O|O||D||1
21101712|Máquina automática cortadora y empaquetadora de flores|O|O||D||1
21101800|Aparatos dispersores o aspersores para agricultura|O|O||D||1
21101801|Rociadores|O|O||D||1|Hidrolavadora
21101802|Guarda polvos|O|O||D||1
21101803|Aspersores de agua|O|O||D||1
21101804|Dispersores o distribuidores de fertilizante|O|O||D||1
21101805|Generadores de niebla o neblina|O|O||D||1
21101806|Compostadores|O|O||D||1
21101807|Equipo y suministros para polinización|O|O||D||1
21101808|Equipo para protección contra las heladas|O|O||D||1
21101809|Sistema para la fumigación del grano|O|O||D||1
21101900|Equipo para aves de corral y ganado|O|O||D||1
21101901|Ordeñadoras|O|O||D||1
21101902|Equipo para cría de ganado|O|O||D||1
21101903|Incubadoras o polleras para aves de corral|O|O||D||1
21101904|Mezcladoras de forraje|O|O||D||1
21101905|Equipo para identificación de ganado|O|O||D||1
21101906|Equipo de inspección o recolección de huevos|O|O||D||1
21101907|Máquinas para abrevar animales|O|O||D||1
21101908|Tanques refrigeradores de leche|O|O||D||1
21101909|Equipo para el esquilar o peluquear de animales|O|O||D||1
21101910|Peine de lana|O|O||D||1
21101911|Compostador para gallinaza|O|O||D||1
21101912|Espacio para inmovilizar ganado|O|O||D||1
21101913|Cortador de picos|O|O||D||1
21101914|Cerca eléctrica para ganado|O|O||D||1
21101915|Medidor de grasa en la espalda de los cerdos|O|O||D||1|Medidor de grasa en la espalda de los chanchos, Medidor de grasa en la espalda de los cochinillos, Medidor de grasa en la espalda de los cochinos, Medidor de grasa en la espalda de los cuche, Medidor de grasa en la espalda de los cuinos, Medidor de grasa en la espalda de los gorrinos, Medidor de grasa en la espalda de los lechones, Medidor de grasa en la espalda de los marranos, Medidor de grasa en la espalda de los porcinos, Medidor de grasa en la espalda de los puercos,Medidor de grasa en la espalda de los lechones
21102000|Maquinaria agrícola para limpieza, selección o clasificación|O|O||D||1
21102001|Máquinas limpiadoras de semillas, grano o legumbres secas|O|O||D||1
21102002|Máquinas seleccionadoras de semillas, grano o legumbres secas|O|O||D||1
21102003|Clasificadoras de semillas, grano o legumbres secas|O|O||D||1
21102004|Equipo para limpieza y descascarillado de arroz|O|O||D||1
21102005|Molino para trituración|O|O||D||1
21102006|Molinos de martillo|O|O||D||1
21102007|Clasificadora de frutas|O|O||D||1
21102008|Equipo para limpiar o descascarar cebada|O|O||D||1
21102100|Maquinaria y equipo para transformación agrícola|O|O||D||1
21102101|Máquinas agrícolas de briqueta|O|O||D||1
21102102|Expulsor de aceite de semilla|O|O||D||1
21102200|Maquinaria y equipo para silvicultura|O|O||D||1
21102201|Descortezadoras|O|O||D||1
21102202|Equipo de explotación forestal|O|O||D||1
21102203|Equipo de reforestación|O|O||D||1
21102204|Sierras para silvicultura|O|O||D||1
21102205|Deslizadores forestales|O|O||D||1
21102206|Barrenos para aumento forestal|O|O||D||1
21102207|Hipsómetro para silvicultura|O|O||D||1
21102300|Equipo para invernadero|O|O||D||1
21102301|Equipo de riego para invernadero|O|O||D||1
21102302|Materas para invernadero|O|O||D||1
21102303|Equipo de ventilación para invernadero|O|O||D||1
21102304|Equipo aislante para invernadero|O|O||D||1
21102305|Material para sombras para agricultura|O|O||D||1
21102306|Inyector de fertilizante hidropónico|O|O||D||1
21102400|Equipo para insectos|O|O||D||1
21102401|Equipo para apicultura|O|O||D||1
21102402|Equipo para gusanos de seda|O|O||D||1
21102403|Equipo para la cría de mariposas|O|O||D||1
21102404|Equipo para la cría de escarabajos|O|O||D||1
21111500|Equipo de pesca comercial|O|O||D||1
21111501|Anzuelos para pesca comercial|O|O||D||1
21111502|Carretes para pesca comercial|O|O||D||1
21111503|Aparejos para pesca comercial|O|O||D||1
21111504|Redes para pesca comercial|O|O||D||1
21111506|Flotadores para pesca comercial|O|O||D||1
21111507|Plomos o pesos comerciales|O|O||D||1
21111508|Transportadores de redes de pesca|O|O||D||1
21111600|Equipo para acuicultura|O|O||D||1
21111601|Equipo para piscicultura marina|O|O||D||1
21111602|Suministros para piscicultura|O|O||D||1
22101500|Maquinaria para trabajo de desmonte|O|O||D||1
22101501|Cargadores frontales|O|O||D||1
22101502|Niveladoras|O|O||D||1
22101504|Piloteadoras|O|O||D||1
22101505|Aplanadoras|O|O||D||1|Apisonadora
22101507|Bateadoras|O|O||D||1
22101508|Máquinas para abrir zanjas|O|O||D||1|Excavadora de zanjas
22101509|Retroexcavadoras|O|O||D||1|Excavadora mixta, Retrocargadora
22101511|Compactadores|O|O||D||1
22101513|Dragalíneas|O|O||D||1|Dragalina
22101514|Dragas|O|O||D||1
22101516|Excavadoras de fosos|O|O||D||1|Perforadora de pozos
22101518|Raspadores elevadores|O|O||D||1
22101519|Máquina giratoria con cazoleta de rastrillos abiertas|O|O||D||1
22101520|Máquina giratoria con rastrillos elevadores|O|O||D||1
22101521|Rastrilladora arrastrada|O|O||D||1
22101522|Buldóceres de orugas|O|O||D||1
22101523|Buldóceres de ruedas|O|O||D||1
22101524|Excavadoras móviles|O|O||D||1
22101525|Excavadoras de ruedas|O|O||D||1
22101526|Excavadoras de orugas|O|O||D||1
22101527|Transportes integrados de carga|O|O||D||1
22101528|Cargadores de ruedas|O|O||D||1
22101529|Cargadores sobre patines con dirección|O|O||D||1
22101530|Raspadores abiertos|O|O||D||1
22101531|Cañones para quitar nieve|O|O||D||1
22101532|Cargadores de orugas|O|O||D||1|Cargadores de cadenas
22101533|Arrancadoras de troncos|O|O||D||1
22101534|Excavadoras de campaña|O|O||D||1
22101535|Extractor de pilotes|O|O||D||1
22101536|Lavador de llantas|O|O||D||1
22101537|Cortadora de pilotes de concreto|O|O||D||1
22101538|Quitanieves|O|O||D||1
22101600|Equipo de pavimentación|O|O||D||1
22101602|Equipo de apisonamiento|O|O||D||1
22101603|Ensanchadores de carreteras|O|O||D||1
22101604|Placas vibradoras|O|O||D||1
22101605|Acabadoras de asfalto|O|O||D||1
22101606|Esparcidoras de gravilla|O|O||D||1
22101607|Pavimentadoras|O|O||D||1
22101608|Aplanadoras en frío|O|O||D||1
22101609|Mezcladoras de material de pavimentación|O|O||D||1
22101610|Distribuidoras de agregados|O|O||D||1
22101611|Distribuidoras de material bituminoso|O|O||D||1
22101612|Escarificadoras de carreteras|O|O||D||1
22101613|Aplanadoras calentadoras de la superficie de la carretera|O|O||D||1
22101614|Revestimientos de pavimento de concreto|O|O||D||1
22101615|Trituradoras de pavimento|O|O||D||1
22101616|Máquinas para hacer andenes|O|O||D||1
22101617|Máquinas de relleno|O|O||D||1
22101618|Equipos de preparación de superficies de rodamiento o mecanismos para su colocación|O|O||D||1
22101619|Máquinas pulidoras|O|O||D||1
22101620|Máquinas de limpieza o acabado de juntas|O|O||D||1
22101621|Distribuidora de asfalto|O|O||D||1
22101622|Recicladora de asfalto|O|O||D||1
22101623|Máquina pavimentadora y de terminados|O|O||D||1
22101624|Máquina para marcar calles|O|O||D||1
22101625|Máquina pulidora de concreto|O|O||D||1
22101626|Planta mezcladora de asfalto|O|O||D||1
22101627|Fusor de asfalto|O|O||D||1
22101628|Lavadora de agregados|O|O||D||1
22101629|Secadora de agregados|O|O||D||1
22101630|Removedor de marcas de calles|O|O||D||1
22101631|Guía de piloteadora|O|O||D||1
22101700|Componentes de equipo pesado|O|O||D||1
22101701|Palas excavadoras|O|O||D||1
22101702|Palas mecánicas para el de movimiento de tierra o sus piezas o accesorios|O|O||D||1
22101703|Cuchillas o dientes u otros filos cortantes|O|O||D||1
22101704|Escarificadores|O|O||D||1
22101705|Orugas: eslabones o zapatas o sus piezas|O|O||D||1|Orugas, eslabones o zapatas o sus piezas
22101706|Cucharas de pala|O|O||D||1
22101707|Cables de retención|O|O||D||1
22101708|Extractores|O|O||D||1
22101709|Cucharones bivalvos|O|O||D||1
22101710|Remolques quitanieves|O|O||D||1
22101711|Herramientas de trituración de pavimento o accesorios|O|O||D||1
22101712|Herramientas de piloteadoras o sus piezas o accesorios|O|O||D||1
22101713|Brazo de retroexcavadora o secciones del brazo|O|O||D||1
22101714|Kits de reparación o piezas de apisonadora|O|O||D||1
22101715|Plantas o alimentadoras de dosificación|O|O||D||1
22101716|Kits de conversión de maquinaria de construcción|O|O||D||1
22101717|Vertederas de movimiento de tierra|O|O||D||1
22101718|Sistemas de control de aplanadora|O|O||D||1
22101719|Portaherramientas de corredera transversal de aplanadora|O|O||D||1
22101720|Zapatas perfiladoras de zanjadora|O|O||D||1
22101721|Brocas y accesorios de la hincadora de estacas|O|O||D||1
22101722|Cuchara dentada|O|O||D||1|Dientes del cucharón
22101723|Cortador lateral de cuchara|O|O||D||1
22101724|Cincel cortador hidráulico|O|O||D||1
22101800|Grúas de elevación|O|O||D||1
22101801|Manlift o elevador de personal|O|O||D||1|Plataforma elevadora
22101802|Elevador de plataforma|O|O||D||1
22101803|Elevador de boom articulado|O|O||D||1
22101804|Elevador de boom telescópico|O|O||D||1
22101900|Maquinaria y accesorios de construcción de edificios|O|O||D||1
22101901|Mezcladoras o plantas de concreto|O|O||D||1
22101902|Mezcladoras de argamasa, pañete o mortero|O|O||D||1
22101903|Mezcladoras de grada giratoria|O|O||D||1
22101904|Máquinas de curado|O|O||D||1
22101905|Distribuidoras de concreto|O|O||D||1
22101906|Equipo de apuntalamiento|O|O||D||1
22101907|Puntales de zanja|O|O||D||1
22101908|Drenaje de cartón o drenaje de pabilo|O|O||D||1
22102000|Equipo y maquinaria de demolición de edificios|O|O||D||1
22102001|Kits de equipo de demolición|O|O||D||1
22102002|Bola para demolición|O|O||D||1|Bola de derribo
23101500|Maquinaria para trabajar madera, piedra, cerámica y similares|O|O||D||1
23101501|Caladoras|O|O||D||1|Sierra de Vaivén
23101502|Taladros|O|O||D||1
23101503|Brochadoras|O|O||D||1
23101504|Máquinas dobladoras|O|O||D||1
23101505|Maquinas abre huecos|O|O||D||1
23101506|Esmeriladoras|O|O||D||1|Amoladora de banco, Esmeril de banco
23101507|Troqueladoras|O|O||D||1
23101508|Cortadoras|O|O||D||1
23101509|Lijadoras|O|O||D||1
23101510|Pulidoras|O|O||D||1
23101511|Máquinas para tornear|O|O||D||1
23101512|Sierras mecánicas|O|O||D||1
23101513|Fresadoras|O|O||D||1
23101514|Cepilladoras|O|O||D||1
23101515|Máquinas para grabar|O|O||D||1
23101516|Máquina de martillar con la peña de cuentas de vidrio|O|O||D||1
23101517|Máquinas de sanblasteado|O|O||D||1
23101518|Máquina de picar con chorro de perdigones|O|O||D||1
23101519|Robots|O|O||D||1
23101520|Máquinas Ram de electro descarga|O|O||D||1
23101521|Máquina de descarga de electrodo de cátodo de alambre|O|O||D||1
23101522|Rompevirutas|O|O||D||1
23101525|Lijadora de huso oscilante|O|O||D||1
23101528|Lijadora de tambor|O|O||D||1
23101529|Rodillo esparcidor de goma|O|O||D||1
23101530|Máquina cola de milano|O|O||D||1
23101531|Máquina combinada de carpintería|O|O||D||1
23101532|Máquina espigadora|O|O||D||1
23101533|Prensa fría|O|O||D||1
23101534|Aplicador de banda de orillos|O|O||D||1
23101535|Máquina para unir espesores distintos|O|O||D||1
23101536|Máquina de clavijas|O|O||D||1
23101537|Lijadora de banda y disco|O|O||D||1
23101538|Desbastadora para carpintería|O|O||D||1
23111500|Maquinaria y equipo para destilado y transformación de petróleo|O|O||D||1
23111501|Equipo de hidroprocesamiento de destilado|O|O||D||1
23111502|Máquina para destilación de crudo|O|O||D||1
23111503|Equipo de ruptura catalítica|O|O||D||1
23111504|Equipo de hidro - ruptura|O|O||D||1
23111505|Maquinaria de isomerización|O|O||D||1
23111506|Máquina coquizadora|O|O||D||1
23111507|Maquinaria para recuperación de gas|O|O||D||1
23111600|Maquinaria de hidrotratamiento|O|O||D||1
23111601|Hidrotratador de nafta|O|O||D||1|Hidrotratadora de nafta
23111602|Hidrotratador de destilado|O|O||D||1|Hidrotratadora de destilado
23111603|Hidrotratador de alimentación catalítica|O|O||D||1|Hidrotratadora de alimentación catalítica
23111604|Hidrotratador de lubricantes|O|O||D||1|Hidrotratadora de lubricantes
23111605|Hidrotratador de gasolina|O|O||D||1|Hidrotratadora de gasolina
23111606|Hidrotratador de aceite residual|O|O||D||1|Hidrotratadora de aceite residual
23121500|Maquinaria y accesorios para transformados textiles|O|O||D||1
23121501|Maquinaria para bordados|O|O||D||1
23121502|Maquinaria para afelpado|O|O||D||1
23121503|Devanadoras o encarretadoras|O|O||D||1
23121504|Máquinas de Torción|O|O||D||1
23121505|Máquina para pegar puntadas|O|O||D||1
23121506|Tejedoras|O|O||D||1
23121507|Urdidoras|O|O||D||1
23121508|Máquinas de acabados|O|O||D||1
23121509|Husos|O|O||D||1
23121510|Máquinas para hacer encaje|O|O||D||1
23121511|Máquinas para lavar textiles|O|O||D||1
23121512|Máquinas cardadoras|O|O||D||1
23121513|Enrolladoras de ensamble de hilaza|O|O||D||1
23121514|Cortadora de hilaza|O|O||D||1
23121515|Máquina levantadora|O|O||D||1
23121516|Máquina quemadora|O|O||D||1
23121517|Máquina enrolladora fina|O|O||D||1
23121518|Máquina para desenrollar hebras|O|O||D||1
23121519|Sistema de hilado de laboratorio|O|O||D||1
23121520|Máquina combadora|O|O||D||1
23121600|Maquinaria, equipo y accesorios para trabajo textil|O|O||D||1
23121601|Máquinas para forrar botones|O|O||D||1
23121602|Máquinas para coser botones|O|O||D||1
23121603|Máquinas de hacer ojales|O|O||D||1
23121604|Máquinas cortadoras de tela|O|O||D||1
23121605|Máquinas para rellenar cojines|O|O||D||1
23121606|Máquinas plegadoras o rebobinadoras|O|O||D||1
23121607|Máquinas blanqueadoras|O|O||D||1
23121608|Máquinas para doblar telas o paños|O|O||D||1
23121609|Máquinas bobinadoras o desenrolladoras|O|O||D||1
23121610|Máquinas para teñir|O|O||D||1
23121611|Máquinas cortadoras o festoneadoras|O|O||D||1
23121612|Agujas para máquina de cose|O|O||D||1
23121613|Máquinas para procesar seda|O|O||D||1
23121614|Máquinas de coser|O|O||D||1
23121615|Mesas para cortar telas|O|O||D||1
23121616|Probadoras de tinturas|O|O||D||1
23131500|Equipo y suministros de trituración, lijado y pulido|O|O||D||1
23131501|Compuestos abrasivos|O|O||D||1
23131502|Ruedas de fieltro|O|O||D||1
23131503|Ruedas de esmerilado|O|O||D||1
23131504|Compuestos para brillado|O|O||D||1
23131505|Cabezas de pulir|O|O||D||1
23131506|Ruedas para pulir|O|O||D||1
23131507|Tela para lijar|O|O||D||1
23131508|Tambores para lijar|O|O||D||1
23131509|Cilindros o brilladoras|O|O||D||1
23131510|Suministros o medios de cilindro|O|O||D||1
23131511|Pivotes de agua|O|O||D||1
23131512|Bandejas de agua|O|O||D||1
23131513|Bloques para lijar|O|O||D||1
23131514|Piedras montadas|O|O||D||1
23131515|Rectificadora de piedra de moler|O|O||D||1
23131600|Equipo y accesorios de facetaje|O|O||D||1
23131601|Accesorios para hacer facetas o pulir caras|O|O||D||1
23131602|Máquinas para hacer facetas o pulir caras|O|O||D||1
23131603|Pulidoras para hacer facetas o pulir caras|O|O||D||1
23131604|Sierras para hacer facetas o pulir caras|O|O||D||1
23131700|Equipo del cabbing|O|O||D||1
23131701|Accesorios para hacer cabuchones|O|O||D||1|Accesorios para hacer cabujones
23131702|Cinturones para hacer cabuchones|O|O||D||1|Cinturones para hacer cabujones
23131703|Discos para hacer cabuchones|O|O||D||1|Discos para hacer cabujones
23131704|Máquinas para hacer cabuchones|O|O||D||1|Máquinas para hacer cabujones
23141600|Maquinaria y accesorios para el preparado del cuero|O|O||D||1
23141601|Máquinas para descarnar cuero|O|O||D||1
23141602|Máquinas para curtir cuero|O|O||D||1
23141603|Máquinas para teñir cuero|O|O||D||1
23141604|Máquinas para desengrasar cuero|O|O||D||1
23141605|Prensadoras de cuero|O|O||D||1
23141606|Máquina escurridora|O|O||D||1
23141607|Impermeable|O|O||D||1
23141608|Máquina para quitar el pelo|O|O||D||1
23141700|Maquinaria y accesorios para trabajar y reparar cuero|O|O||D||1
23141701|Máquinas cortadoras de cuero|O|O||D||1
23141702|Máquinas ribeteadoras de cuero|O|O||D||1
23141703|Máquinas clavadoras de cuero|O|O||D||1
23141704|Equipo para talabartería|O|O||D||1|Equipo para guarnicionería
23151500|Maquinaria, equipo y suministros para la elaboración de caucho y plástico|O|O||D||1
23151501|Máquinas de moldeo por soplado|O|O||D||1
23151502|Máquinas revestidoras|O|O||D||1
23151503|Extrusoras|O|O||D||1
23151504|Máquinas de moldeo por inyección|O|O||D||1
23151506|Prensas de caucho o plástico|O|O||D||1
23151507|Máquinas termo modeladoras|O|O||D||1
23151508|Máquinas para moldear al vacío|O|O||D||1
23151509|Vulcanizadoras|O|O||D||1
23151510|Maquinaria para cortar plástico|O|O||D||1
23151511|Maquinaria para triturar plástico|O|O||D||1
23151512|Molinos de caucho o plástico|O|O||D||1
23151513|Moldes de extrusión de caucho o plástico|O|O||D||1
23151514|Moldes de inyección para plástico|O|O||D||1
23151515|Moldes de termoformar|O|O||D||1
23151516|Pasadores del eyector|O|O||D||1
23151517|Cilindro imd para decoración en molde|O|O||D||1
23151518|Equipo de moldeo por inmersión|O|O||D||1
23151519|Equipo de moldeado y procesamiento de uretano|O|O||D||1
23151520|Equipo de moldeado giratorio|O|O||D||1
23151600|Maquinaria, equipo y suministros para la industria del cemento, cerámica y vidrio|O|O||D||1
23151601|Sopladores o secadores|O|O||D||1
23151602|Trituradoras|O|O||D||1
23151603|Máquinas de soldadura por fusión o de estirado de vidrio|O|O||D||1
23151604|Esmeriladoras p pulidoras|O|O||D||1
23151606|Máquinas moldeadoras de cemento o cerámica o vidrio o similar|O|O||D||1
23151607|Prensas|O|O||D||1
23151608|Tamices|O|O||D||1
23151609|Instrumento para soplar vidrio|O|O||D||1
23151610|Extractor micropipeta|O|O||D||1
23151700|Maquinaria, equipo y suministros de la industria óptica|O|O||D||1
23151701|Máquinas para pulir lentes|O|O||D||1
23151702|Equipo de medición de lentes|O|O||D||1
23151703|Equipo de esmerilado de lentes|O|O||D||1
23151704|Equipos de ensayo de lentes|O|O||D||1
23151705|Equipo para recubrir el vacío óptico|O|O||D||1
23151800|Maquinaria, equipo y suministros de la industria farmacéutica|O|O||D||1
23151801|Equipo para llenado de ampolletas|O|O||D||1
23151802|Colocadores de tapas, insertadores de algodón o aplicadores de sellos de seguridad|O|O||D||1
23151803|Máquinas encapsuladoras|O|O||D||1
23151804|Reactores, fermentadores o digestores|O|O||D||1
23151805|Máquinas dosificadoras de barrena para llenado o cerrado hermético|O|O||D||1
23151806|Filtros o ultrafiltros farmacéuticos|O|O||D||1
23151807|Secadores por congelación o liofilizadores|O|O||D||1
23151808|Granuladores|O|O||D||1
23151809|Máquinas farmacéuticas de tamizado|O|O||D||1
23151810|Máquinas de procesado o llenado estéril o aséptico|O|O||D||1
23151811|Máquinas para hacer ensayos de tabletas o cápsulas|O|O||D||1
23151812|Contadores de tabletas|O|O||D||1
23151813|Máquinas de hacer tabletas|O|O||D||1
23151814|Equipo de producción de vacunas|O|O||D||1
23151816|Columnas de cromatografía|O|O||D||1
23151817|Medios de cromatografía|O|O||D||1
23151818|Dispositivos de prueba de esterilidad|O|O||D||1
23151819|Comprobadores de integridad de los filtros|O|O||D||1
23151821|Adaptador de cartucho filtro|O|O||D||1
23151822|Adaptadores o conectores o accesorios para soportes de filtros farmacéuticos|O|O||D||1
23151823|Radiofármaco de diagnóstico|O|O||D||1
23151824|Equipos o accesorios para hacer compuestos farmacológicos|O|O||D||1
23151825|Unidad de tanque para filtrar y mezclar|O|O||D||1
23151900|Maquinaria, equipo y suministros para la elaboración y el procesamiento de papel|O|O||D||1
23151901|Cortadores|O|O||D||1
23151902|Rajadores|O|O||D||1
23151903|Máquinas de lavado o para sacar el agua|O|O||D||1
23151904|Rebobinadoras|O|O||D||1
23151905|Máquinas para hacer pulpa de madera|O|O||D||1
23151906|Calandrias para hacer papel o cartón|O|O||D||1
23151907|Cedazo o tambor de pantalla|O|O||D||1
23151908|Refinador mecánico de pulpa|O|O||D||1
23151909|Máquina para hacer pulpa|O|O||D||1
23151910|Flotador|O|O||D||1
23151911|Máquina de papel|O|O||D||1
23152000|Manejo del Web y maquinaria de control y equipo y suministros|O|O||D||1
23152001|Tratadores de corona|O|O||D||1
23152002|Tratadores por llama|O|O||D||1
23152100|Maquinaria y equipo de separación|O|O||D||1
23152101|Pantallas o piezas o equipo vibratorios de separación|O|O||D||1
23152102|Pantallas o piezas o equipo estacionario de separación|O|O||D||1
23152103|Pantallas o piezas o equipo de clasificación neumática|O|O||D||1
23152104|Equipo o piezas y pantallas de separación centrífuga|O|O||D||1
23152105|Vibrador electromecánico|O|O||D||1
23152106|Pantalla vibratoria de separación de perfil uretano|O|O||D||1
23152107|Pantalla vibratoria de separación de alambre de perfil|O|O||D||1
23152108|Pantalla vibratoria de separación de la estampadora|O|O||D||1
23152109|Pantalla vibratoria de separación de la estampadora recubierta de uretano|O|O||D||1
23152110|Pantalla vibratoria de separación de alambre de uretano o caucho|O|O||D||1
23152111|Pantalla vibratoria de separación de alambre tejido|O|O||D||1
23152112|Pantalla vibratoria de separación de alambre tejido recubierto de uretano|O|O||D||1
23152113|Tamiz vibratorio|O|O||D||1
23152200|Mesa y estantes para fabricación|O|O||D||1
23152201|Mesas rotatorias|O|O||D||1
23152202|Bancos de apilado|O|O||D||1
23152203|Bancos de pruebas de componentes o motores|O|O||D||1
23152204|Resguardo de la máquina|O|O||D||1
23152205|Mesas de sierra de banda|O|O||D||1
23152206|Protección de barrera|O|O||D||1
23152900|Maquinaria empacadora|O|O||D||1
23152901|Maquinaria de envolver|O|O||D||1
23152902|Maquinaria de formar, rellenar o sellar|O|O||D||1
23152903|Empacadora al vacío|O|O||D||1
23152904|Tolvas para empacar|O|O||D||1
23152905|Máquinas para el formado de cartón|O|O||D||1
23152906|Maquinas para encintar|O|O||D||1
23152907|Suministros para maquinaria de empaque|O|O||D||1
23152908|Máquina para lavar botellas|O|O||D||1
23152909|Máquina para organizar materias primas|O|O||D||1
23152910|Máquina para hacer bolsas automáticas|O|O||D||1
23153000|Dispositivos y sistemas de guía, posicionamiento y sujeción|O|O||D||1
23153001|Plantilla de medición|O|O||D||1
23153002|Plantilla de guía|O|O||D||1
23153003|Plantilla maestro|O|O||D||1
23153004|Plantilla de aguja|O|O||D||1
23153005|Plantilla de eje|O|O||D||1
23153006|Plantilla de chequeo|O|O||D||1
23153007|Plantilla de instalación|O|O||D||1
23153008|Plantilla de cámara|O|O||D||1
23153009|Plantilla de captación|O|O||D||1
23153010|Plantilla de eliminación|O|O||D||1
23153011|Plantilla de boquilla|O|O||D||1
23153012|Plantilla de deslizamiento|O|O||D||1
23153013|Plantilla de centrado|O|O||D||1
23153014|Plantilla de inspección|O|O||D||1
23153015|Plantilla de alimentador|O|O||D||1
23153016|Plantilla de embrague|O|O||D||1
23153017|Plantilla de alineación|O|O||D||1
23153018|Plantilla de posicionamiento|O|O||D||1
23153019|Placa elevadora|O|O||D||1
23153020|Guía de cinta|O|O||D||1
23153021|Mordaza de alimentación de cinta|O|O||D||1
23153022|Alimentador mecánico|O|O||D||1
23153023|Arnés del alimentador|O|O||D||1
23153024|Mordaza de alimentación|O|O||D||1
23153025|Agarrador mecánico|O|O||D||1
23153026|Mordaza de soporte|O|O||D||1
23153027|Conjunto de mordaza|O|O||D||1
23153028|Mordaza estacionaria|O|O||D||1
23153029|Bloque de plantilla|O|O||D||1
23153030|Guías de desplazamiento lineal|O|O||D||1
23153031|Plantillas de medición|O|O||D||1
23153032|Plantilla de anillo|O|O||D||1
23153033|Placa de garganta|O|O||D||1
23153034|Rieles de máquina|O|O||D||1
23153035|Placa|O|O||D||1
23153036|Placas de cerrojo|O|O||D||1
23153037|Conjunto de rodillos de alimentación|O|O||D||1
23153038|Caballete|O|O||D||1
23153039|Carro de riel de maquinado|O|O||D||1
23153100|Componentes y accesorios de maquinaria industrial|O|O||D||1
23153101|Tope de paso|O|O||D||1
23153102|Limitador de papel|O|O||D||1
23153103|Almohadilla de topa|O|O||D||1
23153129|Limpiador de la vía de máquina|O|O||D||1
23153130|Soportes de máquina o aisladores de vibración|O|O||D||1
23153131|Placas o barras o cintas de desgaste|O|O||D||1
23153132|Deflectores de polvo|O|O||D||1
23153133|Diente de rueda de cadena|O|O||D||1
23153134|Rodillos de avance o de arrastre|O|O||D||1
23153135|Cubiertas de rodillos de avance|O|O||D||1
23153136|Conductores de aserrín|O|O||D||1
23153137|Cubiertas guardapolvos de máquina|O|O||D||1
23153138|Cabezales de corte o desbastado|O|O||D||1
23153139|Camas guía|O|O||D||1
23153140|Brazos articulados|O|O||D||1
23153141|Alambre de máquina de electro descarga edm|O|O||D||1
23153142|Fuelles de acordeón|O|O||D||1
23153143|Boquillas de rociado|O|O||D||1
23153144|Bloque de rociado|O|O||D||1
23153145|Pistola de rociado|O|O||D||1
23153200|Robótica|O|O||D||1
23153201|Robots de pintura|O|O||D||1
23153202|Robots para levantar o poner|O|O||D||1
23153203|Robots de sellado adhesivo|O|O||D||1
23153204|Robots de soldadura|O|O||D||1
23153205|Robot para atender maquinaria|O|O||D||1
23153206|Robot para remover material|O|O||D||1
23153207|Robot de limpieza|O|O||D||1
23153400|Ensambladoras|O|O||D||1
23153401|Sistemas de aplicación de pegante o adhesivo|O|O||D||1
23153402|Accesorios de ensamblaje|O|O||D||1
23153403|Ensamblaje especializado|O|O||D||1
23153404|Sistemas de ensamblaje para vehículos de chasis (vo)|O|O||D||1
23153405|Ensamblaje de componentes ilimitados|O|O||D||1
23153406|Líneas completas de tren motor|O|O||D||1
23153407|Dispositivo de montaje de superficies|O|O||D||1
23153408|Prueba de llenado|O|O||D||1
23153409|Multihusillo fijo de corredera roscada|O|O||D||1
23153410|Patines de carrocería|O|O||D||1
23153411|Inflado de montaje de llantas|O|O||D||1
23153412|Cizalla de guillotina|O|O||D||1
23153413|Aplicación de recepción (pu) de inserción de vidrio|O|O||D||1
23153414|Brazos articulados de movimiento giratorio|O|O||D||1
23153415|Acoplamiento automático del chasis|O|O||D||1
23153416|Componentes flexibles|O|O||D||1
23153417|Maquinas diversas para ensamble|O|O||D||1
23153418|Accesorios o herramientas par ensamble a la medida|O|O||D||1
23153419|Máquina de estación sencilla a la medida|O|O||D||1
23153420|Máquina para el ensamble de cables y alambres|O|O||D||1
23153421|Máquina torcedora o hebradora|O|O||D||1
23153500|Sistemas de pintura|O|O||D||1
23153501|Sistemas de aplicación de pintura|O|O||D||1
23153502|Caseta para reparación de pintura|O|O||D||1
23153503|Hornos de sistemas de pintura|O|O||D||1
23153504|Ingeniería o disposición de la planta de pintura|O|O||D||1
23153505|Sistema de pintura llave en mano|O|O||D||1
23153506|Sistema de pintura de fosfato o “e coat”|O|O||D||1
23153507|Taller de pintura variado|O|O||D||1
23153508|Sistemas diversos de pintura|O|O||D||1
23153600|Máquinas para el marcado de partes|O|O||D||1
23153601|Máquinas para el arcado al ácido|O|O||D||1|Máquinas de marcado ácido
23153602|Maquinas para el marcado láser|O|O||D||1
23153603|Máquinas para el marcado pinstamp|O|O||D||1
23153604|Herramienta para el marcado láser|O|O||D||1
23153605|Máquina para el marcado con puntos|O|O||D||1
23153606|Máquina para el marcado por electro – grabado|O|O||D||1
23153607|Máquina para el marcado por chorro de tinta|O|O||D||1
23153608|Máquina para el marcado de tubos electrónicos|O|O||D||1
23153700|Equipo de aseguramiento o torque de precisión|O|O||D||1
23153701|Torquímetro de impacto|O|O||D||1
23153702|Torquímetro|O|O||D||1
23153800|Sistemas de revestimiento|O|O||D||1
23153801|Fluxer electrostático|O|O||D||1
23153802|Máquina para rebobinar bobinas eléctricas|O|O||D||1
23161500|Máquinas y equipo de fundición|O|O||D||1
23161501|Fuelles de fundición|O|O||D||1
23161502|Quemadores de fundición|O|O||D||1
23161503|Horno de secado del núcleo|O|O||D||1
23161506|Crisoles de fundición|O|O||D||1
23161507|Convertidores para fundición|O|O||D||1
23161510|Máquinas fundidoras|O|O||D||1
23161514|Prensas de dimensionamiento o grabado en relieve|O|O||D||1
23161516|Máquina de troqueles de fundición|O|O||D||1
23161517|Maquina moldeadora fundidora|O|O||D||1
23161600|Suministros de fundición|O|O||D||1
23161601|Fuelles de fundición|O|O||D||1
23161602|Arcillas de fundición|O|O||D||1
23161603|Frascos de fundición|O|O||D||1
23161605|Cucharas de fundición|O|O||D||1
23161606|Troqueles de fundición|O|O||D||1
23161607|Arena de fundición|O|O||D||1
23161608|Palas de fundición|O|O||D||1
23161700|Troqueles y herramientas de fundición|O|O||D||1
23161701|Caja para la formación de núcleos de arena|O|O||D||1
23161702|Patrón de formación de troqueles de arena|O|O||D||1
23181500|Maquinaria para la elaboración de alimentos|O|O||D||1
23181501|Maquinaria de llenado|O|O||D||1
23181502|Maquinaria de molido|O|O||D||1
23181504|Maquinaria de tamizado|O|O||D||1
23181505|Maquinaria para deshidratación|O|O||D||1
23181506|Maquinaria de lavado|O|O||D||1
23181507|Maquinaria de triturado|O|O||D||1
23181508|Máquinas blanqueadoras|O|O||D||1
23181509|Maquinaria de clasificación|O|O||D||1
23181510|Atadoras de carne|O|O||D||1
23181511|Conformadora|O|O||D||1
23181512|Enfriadora|O|O||D||1
23181513|Preespolvoreadora|O|O||D||1
23181514|Máquina para elaboración de queso|O|O||D||1
23181515|Máquina para elaborar tofu (queso de soya)|O|O||D||1
23181516|Máquina para elaborar fideos|O|O||D||1
23181517|Máquina para elaborar frijol de soya fermentado|O|O||D||1
23181518|Dispositivo para fermentar alimentos|O|O||D||1
23181600|Maquinaria para corte de alimentos|O|O||D||1
23181601|Maquinaria para cortar en cubos|O|O||D||1
23181602|Máquina tajadora|O|O||D||1
23181603|Máquina picadora|O|O||D||1
23181604|Máquina cortadora|O|O||D||1
23181605|Máquina ralladora|O|O||D||1
23181606|Máquina peladora|O|O||D||1
23181700|Maquinaria para cocinar o ahumar alimentos|O|O||D||1
23181701|Máquina para ahumar|O|O||D||1
23181702|Maquinaria para asar|O|O||D||1
23181703|Maquinaria para cocinar|O|O||D||1
23181704|Máquina para cocinar al vapor|O|O||D||1
23181705|Máquina para esterilizar alimentos|O|O||D||1
23181800|Maquinaria industrial para elaboración de bebidas|O|O||D||1
23181801|Equipo y suministros para elaboración de café|O|O||D||1
23181802|Maquinaria para elaboración de zumos|O|O||D||1
23181803|Máquinas para hacer hielo|O|O||D||1
23181804|Máquinas para hacer helados|O|O||D||1
23181805|Partes y accesorios de máquinas para hacer hielo|O|O||D||1
23181806|Esterilizador de bebidas|O|O||D||1
23191000|Mezcladores por tandas|O|O||D||1
23191001|Mezcladora cambiadora|O|O||D||1
23191002|Mezcladora de cuchilla helicoidal|O|O||D||1
23191003|Mezcladora con doble brazo amasador|O|O||D||1
23191004|Mezcladoras intensivas|O|O||D||1
23191005|Mezcladoras de rodillo|O|O||D||1
23191006|Mezcladora de arena|O|O||D||1
23191100|Mezcladores continuos|O|O||D||1
23191101|Mezcladora de tornillo sencillo|O|O||D||1
23191102|Mezcladora de tornillo doble|O|O||D||1
23191200|Piezas de mezcladora y accesorios|O|O||D||1
23191201|Rastrillos de mezcladora|O|O||D||1
23191202|Cuchillas de mezcladora|O|O||D||1
23201000|Sistemas de contacto líquido gas|O|O||D||1
23201001|Columnas de placa|O|O||D||1
23201002|Columnas cargadas|O|O||D||1
23201003|Contacto de líquido disperso|O|O||D||1
23201004|Columna de pared mojada|O|O||D||1
23201005|Columnas de burbuja|O|O||D||1
23201006|Columna de destilación|O|O||D||1
23201007|Columna cargada de destilación|O|O||D||1
23201008|Bandeja de destilación|O|O||D||1
23201100|Absorción e intercambio de iones|O|O||D||1
23201101|Recipiente absorbente|O|O||D||1
23201102|Recipiente absorbente a presión ambiental|O|O||D||1
23201200|Equipo de secado industrial|O|O||D||1
23201201|Secadores atomizadores|O|O||D||1
23201202|Secadores de aire|O|O||D||1
23201203|Secadores de lecho fluido|O|O||D||1
23201204|Equipo para el secado de comida|O|O||D||1
23211000|Maquinaria de ensamblaje electrónico y equipo de soporte|O|O||D||1
23211001|Colocadores de chips|O|O||D||1
23211002|Maquinaria suministradora de pegamento|O|O||D||1
23211003|Maquina de inserción de terminales|O|O||D||1
23211100|Maquinaria de procesamiento y fabricación electrónica|O|O||D||1
23211101|Sistemas de procesamiento de semiconductores|O|O||D||1
23211102|Máquina para hacer tarjetas de circuitos impresos|O|O||D||1
23211103|Pegador de alambre al wafer|O|O||D||1
23211104|Monitor de inspección de chip semiconductor|O|O||D||1
23211105|Dispositivo para sellar porosidad o impregnación de vacío|O|O||D||1
23211106|Implantador de iones|O|O||D||1
23221000|Equipo y maquinaria del departamento de recepción|O|O||D||1
23221001|Sistema de descarga de jaulas|O|O||D||1
23221002|Lavador de jaulas|O|O||D||1
23221100|Equipo y maquinaria del departamento de matanza y desplumamiento|O|O||D||1
23221101|Aturdidor|O|O||D||1
23221102|Máquina desplumadora de pollos|O|O||D||1
23221200|Equipo y maquinaria del departamento de eviscerado|O|O||D||1
23221201|Cortador de aves|O|O||D||1
23231000|Descortezadoras y accesorios|O|O||D||1
23231001|Portaherramientas|O|O||D||1
23231002|Herramienta de carburo|O|O||D||1
23231100|Sierras de cinta y accesorios|O|O||D||1
23231101|Rueda de sierra de cinta|O|O||D||1
23231102|Guía de sierra|O|O||D||1
23231200|Sierras circulares y accesorios|O|O||D||1
23231201|Espaciador de sierra|O|O||D||1
23231202|Eje de sierra|O|O||D||1
23231300|Canteadoras|O|O||D||1
23231301|Rodillo alimentador|O|O||D||1
23231302|Rodillo de sujeción|O|O||D||1
23231400|Sierras de recorte y accesorios|O|O||D||1
23231401|Guía de alineación de la madera|O|O||D||1
23231402|Sierra cero|O|O||D||1
23231500|Clasificadoras de maderos y accesorios|O|O||D||1
23231501|Barras portasierra|O|O||D||1
23231502|Eslinga de contenedor|O|O||D||1
23231600|Apiladoras de maderos y accesorios|O|O||D||1
23231601|Soporte de reborde|O|O||D||1
23231602|Rodillo de terminación|O|O||D||1
23231700|Secaderos de madera y equipo y accesorios|O|O||D||1
23231701|Deflector|O|O||D||1
23231800|Troceadoras de madera y accesorios|O|O||D||1
23231801|Fijador de cuchilla|O|O||D||1
23231900|Cepilladoras y accesorios|O|O||D||1
23231901|Lecho base|O|O||D||1
23231902|Placa trasera|O|O||D||1
23231903|Guía refrigerada por agua|O|O||D||1
23232000|Terminadoras de madera y accesorios|O|O||D||1
23232001|Porta cuchillas|O|O||D||1
23232100|Sierras retestadoras y accesorios|O|O||D||1
23232101|Soporte guía ajustable|O|O||D||1
23232200|Empalmadoras por entalladura múltiple y accesorios|O|O||D||1
23232201|Boquilla de pegamento|O|O||D||1
23241400|Máquinas rectificadoras de metales|O|O||D||1
23241401|Rectificador de banco|O|O||D||1
23241402|Máquina de rectificar superficies|O|O||D||1
23241403|Maquina de rectificación interna|O|O||D||1
23241404|Maquina de rectificación externa|O|O||D||1
23241405|Maquina de rectificación sin centro|O|O||D||1
23241406|Maquina ultrasónica|O|O||D||1
23241407|Máquina de rectificación cilíndrica|O|O||D||1
23241408|Máquina de rectificación de cuchillo|O|O||D||1
23241409|Máquina de rectificación de perfil óptico|O|O||D||1
23241410|Máquina de rectificación de tornillo sinfín|O|O||D||1
23241411|Máquina pulidora|O|O||D||1
23241500|Máquinas cortadoras de metales|O|O||D||1
23241501|Equipo de maquinado abrasivo a chorro|O|O||D||1
23241502|Máquina electromecánica ecm|O|O||D||1
23241503|Máquina de cortado con llama|O|O||D||1
23241504|Herramienta de corte de engranajes|O|O||D||1
23241505|Máquina láser para cortar|O|O||D||1
23241506|Máquina de corte plasma|O|O||D||1
23241507|Máquina de aserrado y corte|O|O||D||1
23241508|Máquina de corte con chorro de agua|O|O||D||1
23241509|Máquina de sierra de banda para metal|O|O||D||1
23241510|Máquina cizalladora de metal|O|O||D||1
23241511|Máquina para hacer roscas|O|O||D||1
23241600|Herramientas cortadoras de metales|O|O||D||1
23241601|Herramienta perforador|O|O||D||1
23241602|Punzón|O|O||D||1
23241603|Máquina para avellanado|O|O||D||1
23241605|Carburo de perforación|O|O||D||1
23241606|Taladros de acero de alta velocidad|O|O||D||1
23241608|Cortador de quemador|O|O||D||1
23241609|Cuchillos y biseles|O|O||D||1
23241610|Cortador de tubos|O|O||D||1
23241611|Escariador|O|O||D||1
23241612|Cortador de formas|O|O||D||1
23241613|Cortador de cepillado|O|O||D||1
23241614|Fresadora sólida|O|O||D||1
23241615|Grifos|O|O||D||1
23241616|Cortador de cable o alambre|O|O||D||1
23241617|Escariador de hoyos para pines|O|O||D||1
23241618|Escariador alineador de hoyos|O|O||D||1
23241619|Escariador de tubos|O|O||D||1
23241620|Escariador de concha|O|O||D||1
23241621|Cuchilla de sierra de varilla|O|O||D||1
23241622|Cortador de ángulo sencillo|O|O||D||1
23241623|Fresadora lateral|O|O||D||1
23241624|Fresadora cilíndrica plana|O|O||D||1
23241625|Fresadora de concha para extremos|O|O||D||1
23241626|Cortador convexo|O|O||D||1
23241627|Cortador cóncavo|O|O||D||1
23241628|Cortador redondeador de esquinas|O|O||D||1
23241629|Sierra para hacer ranuras en metal|O|O||D||1
23241630|Cortador de ranuras en t|O|O||D||1
23241631|Cortador de asiento woodruff|O|O||D||1
23241632|Cortador de cola de milano|O|O||D||1
23241633|Cortador conformador de engranajes|O|O||D||1
23241634|Taladro largo|O|O||D||1
23241635|Taladro de precisión|O|O||D||1
23241636|Taladros de herrero|O|O||D||1
23241637|Taladro de hoyo profundo|O|O||D||1
23241638|Cortador de hoyos con punta de carburo|O|O||D||1
23241639|Taladro de huso|O|O||D||1
23241640|Taladro multi – pasos|O|O||D||1
23241641|Taladro multi paso hex|O|O||D||1
23241642|Roscadora de velocidad|O|O||D||1
23241643|Escariador largo|O|O||D||1
23241644|Láser de dióxido de carbono|O|O||D||1
23241645|Escariador limador de precisión de agujeros|O|O||D||1
23241646|Escariador ajustable|O|O||D||1
23241647|Escariador cónico de agujero de precisión|O|O||D||1
23241700|Máquinas rebabadoras de metales|O|O||D||1
23241701|Maquina de granallado|O|O||D||1
23241702|Máquina rebabadora de energía térmica|O|O||D||1
23241703|Máquina de terminado vibradora o de barril|O|O||D||1
23241800|Máquinas taladradoras de metales|O|O||D||1
23241801|Taladro radial o prensa de taladro|O|O||D||1
23241802|Taladro de segmentos|O|O||D||1
23241803|Taladro de cañón|O|O||D||1
23241804|Taladro controlado numéricamente|O|O||D||1
23241805|Máquina de taladro de mesa rotativa|O|O||D||1
23241806|Máquina de taladro de múltiples cabezas de huso|O|O||D||1
23241807|Máquina de taladro de brazo radial|O|O||D||1
23241808|Máquina de taladro de hoyo profundo|O|O||D||1
23241809|Máquina de taladro de banco|O|O||D||1
23241900|Máquinas perforadoras de metales|O|O||D||1
23241901|Máquina perforadora original|O|O||D||1
23241902|Máquina perforadora con plantilla|O|O||D||1
23241903|Máquinas para dar formas al metal|O|O||D||1
23241904|Máquinas para dar formas internas al metal|O|O||D||1
23241905|Máquinas para dar formas al metal en la superficie|O|O||D||1
23241906|Máquina perforadora vertical|O|O||D||1
23242100|Accesorios para máquinas de cortar metales|O|O||D||1
23242101|Cortadora de barras o varillas|O|O||D||1
23242102|Soporte de electrodos|O|O||D||1
23242103|Relieve de forma|O|O||D||1
23242104|Herramientas o brocas de formado|O|O||D||1
23242105|Inserto indexable|O|O||D||1
23242106|Cuerpos o soportes de herramientas indexables|O|O||D||1
23242107|Inserto de carburo|O|O||D||1
23242108|Inserto de cerámica|O|O||D||1
23242109|Inserto de diamante|O|O||D||1
23242110|Inserto de acero|O|O||D||1
23242111|Torreta de torno|O|O||D||1
23242112|Cuchilla de sierra de banda para cortar metal|O|O||D||1
23242113|Cuchilla de sierra circular para cortar metal|O|O||D||1
23242114|Soportes firmes|O|O||D||1
23242115|Tailstock|O|O||D||1
23242116|Anexo de máquina de enroscado|O|O||D||1
23242117|Anexo de máquina de hacer roscas|O|O||D||1
23242118|Herramienta de moleteado|O|O||D||1
23242119|Broca de torno|O|O||D||1
23242120|Base de tabla de máquina|O|O||D||1
23242200|Máquinas para fabricación de engranajes|O|O||D||1
23242201|Generador de engranajes biselados|O|O||D||1
23242202|Máquina talladora de engranajes|O|O||D||1
23242203|Máquina para el perfeccionamiento de engranajes|O|O||D||1
23242204|Máquinas de volteado de engranajes|O|O||D||1
23242205|Máquina para dar forma a engranajes|O|O||D||1
23242206|Máquina de cepillado|O|O||D||1
23242207|Máquina pulidora de engranajes|O|O||D||1
23242208|Máquina para biselar los dientes de engranajes|O|O||D||1
23242300|Tornos y centros de torneado|O|O||D||1
23242301|Máquina  automática de barra|O|O||D||1
23242302|Torno o máquina sujetadora automática|O|O||D||1
23242303|Centro giratorio horizontal|O|O||D||1
23242304|Torno para duplicar contornos o trazadora|O|O||D||1
23242305|Torno de torreta|O|O||D||1
23242306|Centro giratorio vertical|O|O||D||1
23242307|Tornillo de avance|O|O||D||1
23242308|Máquina centradora|O|O||D||1
23242400|Centros de maquinado|O|O||D||1
23242401|Centro maquinado horizontal|O|O||D||1
23242402|Centro maquinado universal o multi - tarea|O|O||D||1
23242403|Centro maquinado vertical|O|O||D||1
23242500|Máquinas para el fresado de metales|O|O||D||1
23242501|Máquina fresadora de lecho|O|O||D||1
23242502|Máquina fresadora de puente|O|O||D||1
23242503|Máquina fresadora de columna y rodilla|O|O||D||1
23242504|Máquina fresadora de pórtico|O|O||D||1
23242505|Máquina fresadora de perfilado y duplicación|O|O||D||1
23242506|Máquina fresadora de columna desplazada|O|O||D||1
23242507|Máquina fresadora universal|O|O||D||1
23242508|Máquina fresadora de copia|O|O||D||1
23242509|Máquina fresadora de torreta|O|O||D||1
23242510|Máquina fresadora de estilo planeador|O|O||D||1
23242511|Máquina fresadora de extremo|O|O||D||1
23242600|Maquinas para el cortado de metales especializados o diversos|O|O||D||1
23242601|Máquina biseladora|O|O||D||1
23242602|Máquina de bruñido|O|O||D||1
23242603|Máquina para hacer chaflanes|O|O||D||1
23242604|Máquina para lapeado|O|O||D||1
23242605|Máquina pulidora de metal|O|O||D||1
23242606|Máquina de procesamiento en capas delgadas|O|O||D||1
23242607|Máquina de súper  - terminado|O|O||D||1
23242608|Preseteador de herramientas|O|O||D||1
23242609|Máquina para perfeccionado|O|O||D||1
23242610|Maquina de dimensionamiento de hoyos de diamante|O|O||D||1
23242611|Máquina para hacer bordes|O|O||D||1
23242612|Máquina para grabado de metales|O|O||D||1
23242613|Máquina para hacer tornillos hembra|O|O||D||1
23242614|Máquina para hacer llavería|O|O||D||1
23242615|Máquina para hacer surcos en metal|O|O||D||1
23242700|Maquinaria para molinos de tubos|O|O||D||1
23242701|Máquina para hacer componentes tubulares doblados|O|O||D||1
23242702|Máquina para hacer componentes tubulares soldados|O|O||D||1
23251500|Maquinaria para tubulares doblados|O|O||D||1
23251501|Freno de prensa hidráulica|O|O||D||1
23251502|Freno de prensa manual|O|O||D||1
23251503|Máquina para el doblado de metal|O|O||D||1
23251504|Doblador de tangentes|O|O||D||1
23251505|Máquina dobladora de tubos|O|O||D||1
23251506|Terminador de puntas de tubos|O|O||D||1
23251507|Doblador de alas|O|O||D||1
23251508|Máquina dobladora de barras de acero|O|O||D||1
23251509|Máquina para reducir diámetro de alambres|O|O||D||1
23251600|Máquinas para enrollado de metales|O|O||D||1
23251601|Máquina enrolladora de hebras|O|O||D||1
23251602|Máquina para el formado de láminas metálicas|O|O||D||1
23251603|Prensa de rodillos|O|O||D||1
23251700|Máquinas de forjado|O|O||D||1
23251701|Prensa de forja de cizalla|O|O||D||1
23251702|Prensa de forja de impresión y troquel cerrado|O|O||D||1
23251703|Prensa de forja de troquel abierto|O|O||D||1
23251704|Máquinas de forjado radial|O|O||D||1
23251705|Máquina de forjado rollo|O|O||D||1
23251706|Rebabas giratorias|O|O||D||1|Fresas rotativas
23251707|Prensa de recortado|O|O||D||1|Prensas de recorte
23251708|Máquina de forjado de alta velocidad|O|O||D||1
23251709|Máquina de forjado de martillo de aire|O|O||D||1
23251710|Máquina de forjado de martillo de resorte|O|O||D||1
23251711|Máquina de forjado de martillo a vapor|O|O||D||1
23251712|Máquina de forjado de martillo de caída|O|O||D||1
23251713|Máquina de forjado de terminaciones prensadas|O|O||D||1|Máquina forjadora de esmerilado
23251714|Forja de compresión o prensa de manivela|O|O||D||1
23251800|Troqueles y herramientas para el formado de metales|O|O||D||1
23251801|Troquel de doblado|O|O||D||1
23251802|Troquel de corte|O|O||D||1
23251803|Troquel de fundición a presión|O|O||D||1
23251804|Troquel de terminado de bordes|O|O||D||1
23251805|Troquel de forja|O|O||D||1
23251806|Troquel de extrusión de metal|O|O||D||1
23251807|Sello de metal|O|O||D||1
23251808|Mandril para el doblado de tubos|O|O||D||1
23251809|Troquel giratorio|O|O||D||1
23251810|Troquel de estampado|O|O||D||1
23251811|Troquel de regla de acero|O|O||D||1
23251812|Troquel de roscado|O|O||D||1
23251813|Troquel de cableado|O|O||D||1
23251814|Troquel de dibujo|O|O||D||1
23251900|Maquinaria y equipo para la fabricación de contenedores de metal|O|O||D||1
23251901|Alimentador de láminas de metal|O|O||D||1
23261500|Máquinas para prototipos rápidos|O|O||D||1
23261501|Máquina de modelado  por deposición con fusible fdm|O|O||D||1
23261502|Máquina de método de chorro de tinta|O|O||D||1
23261503|Máquina para la manufactura de objeto laminado|O|O||D||1
23261504|Máquina láser para la formación de polvo|O|O||D||1
23261505|Máquina láser selectiva de sinterización|O|O||D||1
23261506|Máquina de estero – litografía|O|O||D||1
23261507|Máquina impresora tridimensional|O|O||D||1
23271400|Máquinas soldadoras|O|O||D||1
23271401|Máquina para soldadura arco sumergida|O|O||D||1
23271402|Máquina de soldadura ultrasónica|O|O||D||1
23271403|Máquina de soldadura de proyección|O|O||D||1
23271404|Máquina de soldadura arco plasma|O|O||D||1
23271405|Máquina de soldadura láser|O|O||D||1
23271406|Máquina de soldadura aislada|O|O||D||1
23271407|Máquina de soldadura de gas inerte de tungsteno|O|O||D||1
23271408|Máquina de soldadura de gas inerte de metal|O|O||D||1
23271409|Máquina de soldadura de barra o soldadura arco metálico protegida|O|O||D||1
23271410|Rectificador de soldadura|O|O||D||1
23271411|Soldadura plástica|O|O||D||1
23271412|Soldadura termita|O|O||D||1
23271413|Máquina de soldadura de rayo electrón ebw|O|O||D||1
23271414|Máquina de soldadura electro escoria esw|O|O||D||1
23271415|Máquina de soldadura de contacto o presión fría|O|O||D||1
23271416|Máquina de soldadura de fricción fw|O|O||D||1
23271417|Máquina de soldadura con estaño|O|O||D||1
23271418|Máquina de soldadura por junta eléctrica|O|O||D||1
23271419|Soldadura con recalado|O|O||D||1
23271420|Soldadura de cordón|O|O||D||1|Soldadura de costura
23271421|Soldadura de cuchilla de sierra de banda|O|O||D||1
23271422|Soldadura de montantes o soldadura arco de montantes|O|O||D||1
23271423|Soldadura de arco de corriente alterna ac|O|O||D||1
23271424|Soldadura de arco de corriente directa dc|O|O||D||1
23271500|Maquinaria de soldadura fuerte|O|O||D||1
23271501|Máquina de soldadura fuerte para hornos|O|O||D||1
23271502|Máquina de soldadura fuerte por inducción|O|O||D||1
23271600|Maquinaria de soldadura débil|O|O||D||1
23271601|Máquina de soldadura débil para hornos|O|O||D||1
23271602|Máquina de soldadura por inducción|O|O||D||1
23271603|Hierro de soldadura débil|O|O||D||1
23271604|Máquina de soldadura de onda|O|O||D||1
23271605|Horno de reflujo|O|O||D||1
23271606|Máquina de soldadura débil selectiva|O|O||D||1
23271607|Máquina automática de soldadura débil|O|O||D||1
23271700|Accesorios para soldar, soldadura fuerte y soldadura débil|O|O||D||1
23271701|Soplete|O|O||D||1
23271702|Soplete grande|O|O||D||1
23271703|Anillo de soldadura|O|O||D||1
23271704|Pistola para des – soldar|O|O||D||1
23271705|Bomba para des – soldar|O|O||D||1
23271706|Punta para des – soldar|O|O||D||1
23271707|Aparato para soldar o soldar fuerte o cortar  gas|O|O||D||1
23271708|Barra indicadora de temperatura|O|O||D||1
23271709|Generador de soldadura|O|O||D||1
23271710|Lima limpiadora de soldadura o soldadura fuerte|O|O||D||1|Limpiador de puntas de soldadura
23271711|Punta de soldadura o corte|O|O||D||1
23271712|Kit de soldadura  o soldadura débil|O|O||D||1
23271713|Manipulador y posicionador de soldadura|O|O||D||1
23271714|Pantalla de soldadura|O|O||D||1|Mascara de soldar
23271715|Cuchilla perfiladora de punta de soldadura|O|O||D||1
23271716|Accesorios de perfilación de punta de soldadura|O|O||D||1
23271717|Supresor de retorno|O|O||D||1|Pararrayos de retroceso
23271718|Protector para soldadura|O|O||D||1|Manta de soldadura
23271800|Suministros para soldar, soldadura fuerte y soldadura débil|O|O||D||1
23271801|Espray anti – salpicaduras|O|O||D||1|Aerosol contra salpicaduras para soldadura
23271802|Fundente de soldadura fuerte|O|O||D||1|Decapantes para soldadura fuerte
23271803|Desoldador de trenza|O|O||D||1
23271804|Varilla de soldadura fuerte o soldadura de gas|O|O||D||1|Barra de soldadura o soldadura de gas
23271805|Polvo de hierro|O|O||D||1
23271806|Cautín|O|O||D||1|Soldador eléctrico
23271807|Fluido de soldadura|O|O||D||1|Líquido de soldadura
23271808|Fundente de soldadura débil|O|O||D||1|Flujo de soldadura débil
23271809|Pinta de soldadura|O|O||D||1|Punta de soldadura
23271810|Electrodo de soldadura|O|O||D||1|Varilla de soldadura
23271811|Fundente de soldadura|O|O||D||1|Flujo de soldadura
23271812|Barra de soldadura|O|O||D||1
23271813|Alambre de soldadura|O|O||D||1
23271814|Electrodo de corte|O|O||D||1|Electrodo para corte y biselado
23271815|Barra de cautín|O|O||D||1|Barra de soldadura
23271816|Pasta de cautín|O|O||D||1|Pasta de soldadura
23271817|Polvo de cautín|O|O||D||1|Soldadura en polvo
23271818|Alambre de cautín|O|O||D||1|Alambre para soldar
23271819|Fundente de unión de metal|O|O||D||1
23271820|Estabilizador de humedad de electrodo de soldadura|O|O||D||1
23271821|Soplete de soldadura|O|O||D||1
23281500|Máquinas para recubrir o platear|O|O||D||1
23281501|Máquina anodizdora|O|O||D||1|Máquina de anodización
23281502|Máquina de baño electrolítico|O|O||D||1
23281503|Máquina de rociado térmico|O|O||D||1
23281504|Máquina de plateado de barril|O|O||D||1
23281600|Máquinas para tratamiento de calor|O|O||D||1
23281601|Máquina de inducción de calentamiento|O|O||D||1
23281602|Máquina de enfriamiento rápido|O|O||D||1|Máquina de quench
23281603|Horno para endurecimiento durante tratamiento de calor|O|O||D||1|Horno de endurecimiento por edad de tratamiento térmico
23281700|Máquinas para tratamiento mecánico de superficie|O|O||D||1
23281701|Máquina de revestimiento|O|O||D||1
23281702|Máquina de perdigonado|O|O||D||1
23281703|Máquina de arena (sand blast)|O|O||D||1|Máquina de chorro de arena
23281704|Máquina de electro descarga para endurecimiento de superficies|O|O||D||1
23281800|Accesorios y herramientas para el tratamiento de metal|O|O||D||1
23281801|Parrilla de galvanoplastia|O|O||D||1|Estante galvanoplastia
23281802|Parrilla de deposición de calor físico|O|O||D||1|Estante de deposición física de vapor (PVD)
23281900|Maquinaria y suministros para la limpieza del metal|O|O||D||1
23281901|Limpiador electroquímico de metal|O|O||D||1
23281902|Limpiador químico de metal|O|O||D||1
23281903|Limpiador de metal mecánico o ultrasónico|O|O||D||1
23281904|Equipo de lavado y limpiado acuoso|O|O||D||1
23281905|Equipo de desengrase térmico|O|O||D||1
23291500|Herramientas de perforación industrial|O|O||D||1
23291501|Taladro soldado|O|O||D||1
23291502|Taladro de parte superior o frontal intercambiable|O|O||D||1
23291503|Taladro de inserto indexable|O|O||D||1
23291504|Molino de parte superior o frontal intercambiable|O|O||D||1
23291600|Herramientas de molienda industrial|O|O||D||1
23291601|Inserto de molienda|O|O||D||1|Inserto de fresado
23291700|Herramientas de escariado industrial|O|O||D||1
23291701|Cuchilla de escariador|O|O||D||1
23291702|Escariador soldado|O|O||D||1
23291703|Escariador sólido|O|O||D||1
23291704|Escariador indexable|O|O||D||1
23291800|Herramientas de roscado industrial|O|O||D||1
23291801|Soporte de roscado axial|O|O||D||1
23291802|Soporte de roscado externo|O|O||D||1
23291803|Soporte de roscado interno|O|O||D||1
23291804|Inserto de roscado|O|O||D||1
23291900|Herramientas de barrenado industrial|O|O||D||1
23291901|Cabeza de perforación|O|O||D||1
23291902|Herramienta de perforación burda|O|O||D||1
23301500|Maquinaria, equipos y accesorios para el trabajo de alambre|O|O||D||1
23301501|Equipo para cortado de cable y alambre y ensamble de terminales|O|O||D||1
24101500|Camiones industriales|O|O||D||1
24101501|Carretas|O|O||D||1
24101502|Vehículos de transporte a grane|O|O||D||1|Transportadores a granel
24101503|Vehículo dolly|O|O||D||1|Remolque dolly
24101504|Carretones de mano o accesorios|O|O||D||1|Carros de mano o accesorios
24101505|Camiones de pallets|O|O||D||1|Carritos con plataforma
24101506|Carretas de empujar|O|O||D||1
24101507|Carretillas|O|O||D||1
24101508|Plataformas rodantes|O|O||D||1
24101509|Vagones|O|O||D||1
24101510|Contenedor de basura plástico|O|O||D||1
24101511|Trolleys de estante|O|O||D||1|Carritos de estantería
24101512|Bugies eléctricos|O|O||D||1|Calesa eléctrica
24101513|Remolcador|O|O||D||1|Remolcador
24101514|Camión plataforma|O|O||D||1|Camión de plataforma
24101515|Camión pórtico|O|O||D||1
24101516|Plataforma auto propulsada|O|O||D||1
24101517|Tractor de remolque eléctrico|O|O||D||1
24101600|Equipo de izaje y accesorios|O|O||D||1
24101601|Ascensores|O|O||D||1
24101602|Montacargas|O|O||D||1
24101603|Elevadores forklift|O|O||D||1|Carretilla elevadora
24101604|Elevadores|O|O||D||1
24101605|Equipo de carga|O|O||D||1
24101606|Apiladoras|O|O||D||1
24101608|Malacates o güinches|O|O||D||1|Malacates o winches
24101609|Inclinadores|O|O||D||1
24101610|Manipuladores|O|O||D||1
24101611|Eslingas|O|O||D||1
24101612|Gatos|O|O||D||1
24101613|Bloques o poleas|O|O||D||1
24101614|Sacos de aire para cargar|O|O||D||1
24101615|Rampas de carga|O|O||D||1
24101616|Dispositivo debajo de gancho|O|O||D||1
24101617|Elevador de tijera|O|O||D||1|Mesa elevadora
24101618|Instalador de tuberías|O|O||D||1
24101619|Puentes grúas|O|O||D||1
24101620|Camión grúas|O|O||D||1|Grúa móvil de cadena
24101621|Grúas todo terreno|O|O||D||1
24101622|Grúas para terrenos difíciles|O|O||D||1
24101623|Torre grúas|O|O||D||1
24101624|Grúas hidráulicas sobre camión|O|O||D||1
24101625|Camión grúas convencionales|O|O||D||1
24101626|Escaleras mecánicas o cintas rodantes|O|O||D||1
24101627|Troleys de viga|O|O||D||1|Carros de viga
24101628|Horquillas ajustables|O|O||D||1
24101629|Accesorios o suministros de elevador forklift o transportador vertical|O|O||D||1|Accesorios o suministros de montacargas o ascensores
24101630|Grúas de taller|O|O||D||1
24101631|Tazas de succión|O|O||D||1
24101632|Izajes laterales|O|O||D||1
24101633|Tambores de elevación|O|O||D||1
24101634|Sacos de cadena|O|O||D||1
24101635|Gatos de tornillo|O|O||D||1
24101636|Bolsas de contrapeso y contrapesos|O|O||D||1
24101637|Eslinga de material de nylon|O|O||D||1
24101638|Eslinga de cuerda|O|O||D||1
24101639|Molinete|O|O||D||1
24101640|Unidad de engranaje transversal|O|O||D||1
24101641|Grillete|O|O||D||1
24101642|Grúa flotante|O|O||D||1
24101643|Trolly de lavado y secado|O|O||D||1|Carritos de limpieza y lavandería
24101644|Ascensor de cocina|O|O||D||1
24101645|Grúa sobre orugas|O|O||D||1
24101646|Grúa ferroviaria|O|O||D||1
24101647|Almeja para izaje de material|O|O||D||1
24101648|Almeja para izaje de placas|O|O||D||1
24101649|Grúa güinche|O|O||D||1|Grúa de cabrestante
24101650|Guy derrick|O|O||D||1|Torre derrick
24101651|Cabrestante|O|O||D||1
24101652|Grúa de mástil|O|O||D||1
24101653|Puentegrúa|O|O||D||1
24101654|Grúa gantry o de pórtico|O|O||D||1
24101655|Sistema de parqueadero vertical|O|O||D||1
24101656|Grúa halada por tractor|O|O||D||1|Grúa tractor
24101657|Grúa montada sobre tractor|O|O||D||1
24101658|Imán de izaje|O|O||D||1
24101659|Gato o dolly móvil vertical|O|O||D||1|Vehículo conector o plataforma móvil
24101660|Elevador de baterías|O|O||D||1
24101661|Elevador de vehículo|O|O||D||1
24101662|Cubierta de güinche|O|O||D||1|Cubierta del cabrestante
24101700|Transportadores y accesorios|O|O||D||1
24101701|Rodillo transportador|O|O||D||1
24101702|Transbordadores a bolas|O|O||D||1|Tablas de transferencia de bolas
24101703|Acumuladoras de rocas|O|O||D||1
24101704|Alimentadores para banda transportadora|O|O||D||1
24101705|Tornillo de banda transportadora|O|O||D||1
24101706|Troles o vagonetas y accesorios|O|O||D||1
24101707|Banda transportadora sobre rieles|O|O||D||1
24101708|Banda transportadora extensible|O|O||D||1
24101709|Transportador de rodillos|O|O||D||1
24101710|Paradas de paquetes|O|O||D||1
24101711|Tornamesas|O|O||D||1|Placas giratorias
24101712|Bandas transportadoras|O|O||D||1
24101713|Aparato de cangilones|O|O||D||1|Transportadores de cangilones
24101714|Bandas transportadoras aéreas|O|O||D||1
24101715|Sistema de bandas transportadoras|O|O||D||1
24101716|Poleas de banda transportadora|O|O||D||1
24101717|Rodillos de banda transportadora|O|O||D||1
24101718|Sujeciones de la banda transportadora|O|O||D||1
24101719|Cepillos de la banda transportadora|O|O||D||1
24101721|Cubierta de trolley|O|O||D||1
24101722|Banda transportadora de cadena|O|O||D||1
24101723|Rodillos o tambores motorizados|O|O||D||1
24101724|Bastidores de banda transportadora|O|O||D||1
24101725|Articulaciones o eslabones de banda transportadora|O|O||D||1
24101726|Revestimiento de la banda transportadora|O|O||D||1
24101727|Banda transportadora vibratoria|O|O||D||1
24101728|Soportes de la banda transportadora|O|O||D||1
24101729|Balde de elevador de cangilones|O|O||D||1|Cucharon elevador
24101730|Banda transportadora de tornillo|O|O||D||1
24101731|Faldón de la banda transportadora|O|O||D||1|Junta de la cinta transportadora
24101732|Soporte del rodillo de la banda transportadora|O|O||D||1
24101733|Soporte del rodillo de retorno de la banda transportadora|O|O||D||1
24101734|Raspador en v|O|O||D||1
24101735|Deslizador de aire|O|O||D||1
24101736|Sistema de transporte de fase densa|O|O||D||1
24101737|Sistema de transporte de fase liviana|O|O||D||1
24101738|Compuerta de barra|O|O||D||1
24101739|Unidad receptora de granel|O|O||D||1
24101740|Banda transportadora de ángulo alto|O|O||D||1
24101741|Raspador interno de banda|O|O||D||1
24101742|Raspador externo de banda|O|O||D||1
24101743|Socavón final de banda transportadora|O|O||D||1|Eje trasero del transportador
24101744|Socavón de inicio de banda transportadora|O|O||D||1|Eje del cabezal del transportador
24101745|Banda transportadora sobre ruedas|O|O||D||1
24101746|Banda transportadora portátil|O|O||D||1
24101747|Soporte de banda transportadora|O|O||D||1
24101748|Banda transportadora tripper o disparadora|O|O||D||1
24101749|Sistema de transporte por bandas|O|O||D||1
24101750|Banda transportadora aérea|O|O||D||1
24101800|Equipo para muelles|O|O||D||1
24101801|Niveladores para muelles|O|O||D||1
24101802|Retenedoras para muelles|O|O||D||1
24101803|Rampas para muelles|O|O||D||1
24101804|Puertas de cintas|O|O||D||1|Puertas de tira
24101805|Parachoques para muelles|O|O||D||1|Parachoques de los muelles
24101806|Escaleras para muelles|O|O||D||1
24101807|Planchas para muelles|O|O||D||1
24101808|Cuñas para ruedas|O|O||D||1|Calzos para ruedas
24101809|Carriles de muelle o accesorios|O|O||D||1
24101900|Equipo para manejo de canecas|O|O||D||1
24101901|Abridores de canecas|O|O||D||1|Abridores de tambor
24101902|Agarradores para canecas|O|O||D||1|Agarre de tambor
24101903|Elevadores de canecas|O|O||D||1|Elevadores de tambor
24101904|Soportes para canecas|O|O||D||1|Cunas de tambor
24101905|Cubierta de derrames|O|O||D||1
24101906|Recuperadores de canecas|O|O||D||1
24101907|Soportes de contención de derrames|O|O||D||1
24101908|Caballete para canecas|O|O||D||1|Estantería y estaciones de trasiego
24102000|Disposición en estantes y almacenamiento|O|O||D||1
24102001|Sistemas de estanterías para equipo electrónico montado sobre estantes|O|O||D||1|Sistemas de bastidor para equipos electrónicos de montaje en bastidor
24102002|Manipuladores para recipientes|O|O||D||1
24102004|Estanterías para almacenaje|O|O||D||1
24102005|Sistemas automatizados de almacenaje o recuperación|O|O||D||1
24102006|Bancos de trabajo|O|O||D||1
24102007|Carretes de almacenamiento de estantes|O|O||D||1
24102008|Soportes de carretes portátiles|O|O||D||1
24102009|Rieles montados sobre pared|O|O||D||1
24102010|Estantería de vidrio|O|O||D||1
24102011|Accesorio de biblioteca|O|O||D||1|Estante y accesorios para libros
24102100|Equipo y suministros para almacenaje|O|O||D||1
24102101|Equipo para manejo de carga|O|O||D||1|Equipos de manipulación de cargas
24102102|Carrusel de bodegaje|O|O||D||1|Carruseles de almacén
24102103|Encajadoras de bodegaje|O|O||D||1|Encajonadoras de almacén
24102104|Despaletizadoras|O|O||D||1
24102105|Paletizadoras|O|O||D||1
24102106|Equipo de retractilado industrial|O|O||D||1|Equipos de embalaje de plástico
24102107|Maquinaria para encartonar|O|O||D||1
24102108|Compactadores de empaque|O|O||D||1
24102109|Ganchos para sacos|O|O||D||1
24102200|Herramientas para envasado|O|O||D||1
24102201|Dispensadores de película elástica|O|O||D||1
24102202|Dispensadores de cinta para sellar cajas|O|O||D||1
24102203|Herramientas o equipos para sellar bolsas|O|O||D||1
24102204|Dispensador de zunchos|O|O||D||1|Distribuidor de flejes
24102208|Infladores de aire|O|O||D||1
24102209|Máquina para cortar moldes|O|O||D||1|Troqueladora
24102210|Prensa de embalar|O|O||D||1|Prensa de empacado
24102300|Vehículos guiados automáticos AGV|O|O||D||1
24102301|Vehículo automático guiado por códigos de barras|O|O||D||1
24102302|Vehículo automático guiado a través del cableado|O|O||D||1|Vehículos guiados automáticos AGV
24111500|Bolsas|O|O||D||1
24111501|Bolsas de lona|O|O||D||1
24111502|Bolsas de papel|O|O||D||1
24111503|Bolsas plásticas|O|O||D||1|Bolsas de plástico
24111505|Contendedores de granel intermedios flexibles|O|O||D||1
24111506|Redes o bolsas de lavandería|O|O||D||1
24111507|Bolsas de herramientas|O|O||D||1
24111508|Bolsas de carpa|O|O||D||1
24111509|Bolsas de agua|O|O||D||1
24111510|Bolsas y paquetes de cuerda|O|O||D||1
24111511|Bolsas de malla de fibra|O|O||D||1
24111512|Bolsas de paja|O|O||D||1
24111513|Bolsas de algodón|O|O||D||1
24111514|Bolsas con cremallera|O|O||D||1
24111800|Tanques y cilindros y sus accesorios|O|O||D||1
24111801|Reservorios|O|O||D||1|Embalse
24111802|Tanques o cilindros de aire o gas|O|O||D||1
24111803|Tanques de almacenamiento|O|O||D||1
24111804|Tanques de calibración|O|O||D||1
24111805|Tanques de productos químicos|O|O||D||1
24111806|Tanques de inmersión|O|O||D||1
24111807|Tanques de expansión|O|O||D||1
24111808|Tanques de almacenaje de combustible|O|O||D||1
24111809|Tanques de procesamiento|O|O||D||1
24111810|Tanques de almacenamiento de agua|O|O||D||1|Tinaco
24111811|Bombonas|O|O||D||1|Tanque de almacenamiento
24111812|Pileta de contención|O|O||D||1
24111813|Tanques de lavado|O|O||D||1
24111814|Tanques de agua caliente|O|O||D||1
24111815|Tanques de condensado de vapor|O|O||D||1
24111816|Tanque o cilindro de gas licuado|O|O||D||1|Tanque estacionario
24111817|Silo de cemento|O|O||D||1|Deposito de cemento
24111818|Sello de tanque|O|O||D||1
24112000|Arcones y cestas|O|O||D||1
24112003|Tolvas no metálicas|O|O||D||1|Contenedores no metálicos
24112004|Tolvas metálicas|O|O||D||1|Contenedores metálicos
24112005|Canastas metálicas|O|O||D||1
24112006|Canastas no metálicas|O|O||D||1
24112007|Estante para el manejo de material|O|O||D||1
24112100|Toneles, cubas y bidones|O|O||D||1
24112101|Toneles|O|O||D||1
24112102|Barriles|O|O||D||1
24112108|Tambores metálicos|O|O||D||1|Tambos metálicos
24112109|Tambores no metálicos|O|O||D||1|Tambos no metálicos
24112110|Contenedores intermedios a granel|O|O||D||1
24112111|Estabilizador|O|O||D||1
24112112|Tapa de tambor|O|O||D||1
24112200|Latas y cubos|O|O||D||1
24112204|Cubos metálicos|O|O||D||1|Cubetas metálicas
24112205|Cubos no metálicos|O|O||D||1|Cubetas no metálicas
24112206|Bidones metálicos para líquido inflamable|O|O||D||1|Latas metálicas con líquido inflamable
24112207|Bidones no metálicos para líquido inflamable|O|O||D||1|Latas no metálicas con líquido inflamable
24112208|Conjunto pulverizador|O|O||D||1|Equipo de rociado
24112209|Contenedor de paredes rectas|O|O||D||1|Bidón
24112400|Cofres, armarios y baúles de almacenaje|O|O||D||1
24112401|Cofres, cajas o armarios para herramientas|O|O||D||1
24112402|Armarios para materiales peligrosos|O|O||D||1|Gabinetes de materiales peligrosos
24112403|Cinturón para herramientas|O|O||D||1
24112404|Caja|O|O||D||1
24112406|Compartimentos de caja o estantería|O|O||D||1|Divisiones de caja o estantería
24112407|Buzones|O|O||D||1
24112408|Cajas antiestática|O|O||D||1
24112409|Tapas para cajas|O|O||D||1
24112411|Estuches para transporte|O|O||D||1|Baúl para transportar
24112412|Estuches para transporte de equipo|O|O||D||1|Baúl para transporte de equipo
24112413|Cajas o estuches para guardar banderas|O|O||D||1
24112414|Caja de almacenamiento refrigerado|O|O||D||1
24112415|Urnas de votos|O|O||D||1|Urna electoral
24112500|Cartón ondulado y otros materiales para distribución|O|O||D||1
24112501|Cartones acanalados ranurados|O|O||D||1
24112502|Cajas de transporte cortadas con troquel de una sola pieza|O|O||D||1
24112503|Cartones acanalados de transporte cortados con troquel con tapas separadas|O|O||D||1
24112504|Cajas moldeadas|O|O||D||1
24112505|Formas de cartón corrugado|O|O||D||1
24112600|contenedores para líquidos|O|O||D||1
24112601|Jarras|O|O||D||1
24112602|Frascos|O|O||D||1
24112700|Estibas|O|O||D||1
24112701|Pallets de madera|O|O||D||1|Tarimas de madera
24112702|Pallets plásticos|O|O||D||1|Tarimas de plástico
24112800|Contenedores de carga|O|O||D||1
24112801|Contenedor de carga seca|O|O||D||1
24112802|Contenedor de carga open top|O|O||D||1|Contenedor superior abierto
24112803|Contenedor de carga de plataforma|O|O||D||1
24112804|Contenedor de carga flatrack|O|O||D||1|Contenedor de carga plana
24112805|Contenedor de carga de temperatura controlada|O|O||D||1|Contenedor de carga controlado por temperatura
24112900|Embalajes|O|O||D||1
24112901|Embalaje de madera|O|O||D||1|Cajas de madera para embalaje
24112902|Embalaje de plástico|O|O||D||1|Cajas de plástico para embalaje
24113000|Lámina termo - retráctil|O|O||D||1
24113001|Lámina termo - retráctil corrogada|O|O||D||1|Hoja de deslizamiento ondulado
24113002|Lámina termo - retráctil de cartón o cartulina sólida|O|O||D||1|Hoja de deslizamiento de cartón o cartulina sólida
24113003|Lámina termo - retráctil plástica|O|O||D||1|Hoja de deslizamiento de plástico
24121500|Cajas, bolsas y sacos para empaquetado|O|O||D||1
24121502|Sacos o bolsas para empacar|O|O||D||1
24121503|Cajas para empacar|O|O||D||1
24121504|Empaques cardados|O|O||D||1
24121506|Cajas conductivas|O|O||D||1
24121507|Cajas instaladas rígidas|O|O||D||1
24121508|Cartones de huevos|O|O||D||1
24121509|Bandejas para empacar|O|O||D||1
24121510|Empaques para bolsas de te|O|O||D||1
24121511|Cartón de empacar|O|O||D||1
24121512|Ladrillos de hielo o “cold packs”|O|O||D||1|Embalaje en frío o ladrillo de hielo
24121513|Estuche para empacar|O|O||D||1
24121800|Latas para envasado|O|O||D||1
24121801|Latas de aerosol|O|O||D||1
24121802|Latas de pintura o barniz|O|O||D||1
24121803|Latas de bebida|O|O||D||1
24121804|Latas de comida|O|O||D||1
24121805|Latas de acero|O|O||D||1
24121806|Latas de aluminio|O|O||D||1
24121807|Recipientes de plástico|O|O||D||1
24121808|Recipientes de fibra de cartón|O|O||D||1
24122000|Botellas|O|O||D||1
24122001|Botellas para apretar|O|O||D||1
24122002|Botellas de plástico|O|O||D||1
24122003|Botellas de cristal|O|O||D||1
24122004|Tapones o tapas|O|O||D||1
24122005|Botellas de aplicador|O|O||D||1
24122006|Aplicador|O|O||D||1
24131500|Refrigeradores industriales|O|O||D||1
24131501|Refrigerador y congelador combinado|O|O||D||1
24131502|Refrigeradores de nitrógeno líquido|O|O||D||1
24131503|Cuartos fríos|O|O||D||1|Cuarto de almacenamiento en frio
24131504|Contenedores refrigerados|O|O||D||1
24131505|Buques refrigerados|O|O||D||1
24131506|Tanques refrigerados|O|O||D||1
24131507|Congelador de golpe|O|O||D||1|Abatidor de temperatura
24131508|Gabinete refrigerado|O|O||D||1|Refrigerador de gabinete
24131509|Refrigerador bajo el mostrador|O|O||D||1
24131510|Refrigerador de mostrador|O|O||D||1
24131511|Gabinete de refrigeración para pastelería|O|O||D||1|Vitrina de refrigeración para pasteles
24131512|Estación de preparación con gabinete refrigerado|O|O||D||1
24131513|Refrigerante|O|O||D||1
24131514|Unidad de almacenamiento de pre - enfriamiento y frío|O|O||D||1|Unidad de prerefrigeración y almacenamiento en frío
24131600|Congeladores industriales|O|O||D||1
24131601|Congeladores horizontales|O|O||D||1
24131602|Congeladores verticales|O|O||D||1
24131603|Congeladores a bajas temperaturas|O|O||D||1
24131604|Equipo de secado por congelación|O|O||D||1
24131605|Cuartos fríos|O|O||D||1|Congeladores de almacenamiento
24131606|Congeladores de placa|O|O||D||1
24131607|Congeladores de golpe de frío|O|O||D||1|Refrigeradores industriales
24131608|Gabinete de congelación para pastelería|O|O||D||1
24131609|Congelador bajo el mostrador|O|O||D||1|Bajomostradores de congelación
24131610|Congelador de mostrador|O|O||D||1
24131900|Máquinas de hacer el hielo|O|O||D||1
24131901|Máquinas para hacer cubos de hielo|O|O||D||1
24131902|Máquinas para hacer bloques de hielo|O|O||D||1
24131903|Máquinas para hacer hojuelas de hielo|O|O||D||1|Máquinas industriales para copos  de hielo
24141500|Suministros para seguridad y protección|O|O||D||1
24141501|Película elástica para envoltura|O|O||D||1
24141502|Láminas elásticas de embalaje|O|O||D||1
24141504|Sellos de seguridad a prueba de manipulación|O|O||D||1
24141506|Encerados|O|O||D||1
24141507|Película anti-estática para empacar|O|O||D||1
24141508|Soporte angular de cartón|O|O||D||1|Soporte de esquinas de cartón
24141510|Protectores de cables|O|O||D||1
24141511|Amarres de carga|O|O||D||1
24141512|Absorbentes de empaquetado|O|O||D||1
24141513|Empaques blíster|O|O||D||1|Empaques de ampolla de plástico
24141514|Películas para empacar|O|O||D||1
24141515|Red de protección|O|O||D||1
24141516|Desecante|O|O||D||1|Gel sílice
24141517|Polifilm|O|O||D||1|Película de polietileno
24141518|Láminas separadoras|O|O||D||1|Hoja separadora
24141519|Bandas o correas de acero para empacar|O|O||D||1
24141520|Bandas o correas no metálicas para empacar|O|O||D||1
24141600|Suministros de acolchados|O|O||D||1
24141601|Empaque de burbujas|O|O||D||1
24141602|Materiales de termoformado|O|O||D||1
24141603|Amortiguación|O|O||D||1
24141604|Relleno|O|O||D||1|Materiales de acolchado
24141605|Materiales de empaque rellenos de aire|O|O||D||1
24141606|Bolitas de poliestireno|O|O||D||1
24141607|Separadores de cartón|O|O||D||1
24141608|Protecciones externas|O|O||D||1
24141700|Tubos y núcleos de embalaje y etiquetas y accesorios|O|O||D||1
24141701|Tubos o núcleos de papel|O|O||D||1
24141702|Tapones de extremidad tubo o núcleo|O|O||D||1
24141703|Piezas de papel|O|O||D||1
24141704|Instrucciones o insertos impresos|O|O||D||1
24141705|Tubos plegables|O|O||D||1
24141706|Carrete|O|O||D||1
24141707|Carretel|O|O||D||1
24141708|Asas de paquetes|O|O||D||1
24141709|Tubos o tapones de cápsulas|O|O||D||1
24141710|Etiqueta de alambre|O|O||D||1
25101500|Vehículos de pasajeros|O|O||D||1
25101501|Minibuses|O|O||D||1|Minibús
25101502|Autobuses|O|O||D||1|Camiones de pasajeros
25101503|Carros|O|O||D||1|Automóviles
25101504|Station wagons|O|O||D||1|Vagones
25101505|Minivans o vans|O|O||D||1|Furgonetas
25101506|Limosinas|O|O||D||1
25101507|Camiones ligeros o vehículos utilitarios deportivos|O|O||D||1
25101508|Carro deportivo|O|O||D||1
25101509|Carro eléctrico|O|O||D||1
25101600|Vehículos de transporte de productos y materiales|O|O||D||1
25101601|Volquetas|O|O||D||1|Camión de volteo
25101602|Remolques|O|O||D||1
25101604|Camiones de reparto|O|O||D||1
25101609|Camiones de manipulación de sedimento y aguas residuales|O|O||D||1
25101610|Carrotanques|O|O||D||1|Camiones para transportar líquidos
25101611|Camiones de carga|O|O||D||1
25101612|Camiones concreteros|O|O||D||1|Camión de concreto
25101613|Camiones para bombear concreto|O|O||D||1|Camiones bomba de hormigón
25101700|Vehículos de protección y salvamento|O|O||D||1
25101701|Camiones de bomberos y de rescate|O|O||D||1
25101702|Carros policiales|O|O||D||1
25101703|Ambulancias|O|O||D||1
25101800|Bicicletas de motor|O|O||D||1
25101801|Motocicletas|O|O||D||1|Motoneta
25101802|Scooters|O|O||D||1|Patín del diablo
25101803|Velomotores|O|O||D||1|Bicicleta eléctrica, Ciclomotor
25101804|Sidecar de motocicleta|O|O||D||1|Vehículo lateral para motocicletas
25101900|Vehículos especializados o de recreo|O|O||D||1
25101901|Tractores agrícolas|O|O||D||1
25101902|Casas rodantes|O|O||D||1
25101903|Trineos motorizados o motos de nieve|O|O||D||1
25101904|Carritos de golf|O|O||D||1
25101905|Vehículos todoterreno de ruedas o de tracción|O|O||D||1
25101906|Karts|O|O||D||1|Go karts
25101907|Remolques de camping o caravanas|O|O||D||1|Casa rodante
25101908|Cuatrimoto|O|O||D||1
25101909|Vehículos anfibios|O|O||D||1
25101910|Camiones aspersores de agua|O|O||D||1|Pipas de agua
25101911|Camión con plataforma aérea de trabajo|O|O||D||1|Camión con plataforma de trabajo
25101912|Camión escalera|O|O||D||1
25101913|Camión refrigerador|O|O||D||1
25101914|Carro de la basura o vehículo de recolección de desperdicios|O|O||D||1|Camiones de basura
25101915|Camión petrolero|O|O||D||1
25101916|Camión tolva|O|O||D||1
25101917|Camabaja|O|O||D||1
25101918|Vehículo eléctrico de vecindario|O|O||D||1|Vehículo eléctrico vecinal (NEV)
25101919|Barredora de calles|O|O||D||1
25101920|Carro de seguridad|O|O||D||1
25101921|Carros para transporte de líquidos exceptuando petróleo|O|O||D||1|Camiones furgones
25101922|Camión de reparación de calles|O|O||D||1
25101923|Tractor de orugas|O|O||D||1
25101924|Vehículo limpiador de barandas|O|O||D||1|Camión para limpieza de barandillas vehiculares
25101925|Camión de signos|O|O||D||1
25101926|Camión quitanieves|O|O||D||1
25101927|Camión esparcidor de sal|O|O||D||1
25101928|Camión de medios móvil|O|O||D||1
25101929|Van oficina|O|O||D||1|Furgoneta de oficina móvil
25101930|Camión con equipo de iluminación|O|O||D||1
25101931|Van para radiodifusión externa|O|O||D||1
25101932|Camión para controlar multitudes|O|O||D||1
25101933|Camión grúa|O|O||D||1
25101934|Coche fúnebre|O|O||D||1|Carroza fúnebre
25101935|Camión rociador de líquidos|O|O||D||1
25101936|Camión de vacío|O|O||D||1
25101937|Bus para tratamiento y exámenes médicos|O|O||D||1|Autobús de examen y tratamiento médico
25101938|Sangre – móvil|O|O||D||1|Unidad móvil de donación de sangre
25102000|Vehículos de guerra|O|O||D||1
25102001|Tanques|O|O||D||1
25102002|Carros de combate acorazados|O|O||D||1
25102003|Artillería motorizada|O|O||D||1
25102100|Camiones tractores|O|O||D||1
25102101|Tractores delanteros de cabina baja|O|O||D||1
25102102|Tractomulas de nariz alargada con cama|O|O||D||1
25102103|Tractomulas de nariz alargada sin cama|O|O||D||1
25102104|Tractomulas con cabina encima del motor con cama|O|O||D||1
25102105|Tractomulas con cabina encima del motor sin cama|O|O||D||1
25102106|Cabezote|O|O||D||1|Cabeza del tractor
25111500|Embarcaciones marítimas comerciales|O|O||D||1
25111501|Barcos pesqueros|O|O||D||1
25111502|Botes de pesca|O|O||D||1
25111503|Buques de carga o de contenedores|O|O||D||1
25111504|Embarcación para dragados|O|O||D||1|Nave de dragado
25111505|Buques cisterna|O|O||D||1|Buque tanque
25111506|Remolcadores|O|O||D||1
25111507|Barcazas|O|O||D||1
25111508|Transbordadores de pasajeros o vehículos|O|O||D||1|Transbordador marítimo
25111509|Buques de cruceros|O|O||D||1|Barcos de crucero
25111510|Naves de salvamento|O|O||D||1
$sat$, E'\n') as l
 where l <> ''
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
