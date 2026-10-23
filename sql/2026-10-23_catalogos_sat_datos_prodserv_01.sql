-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 1 de 10 (5555 claves; total 52513)
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
01010101|No existe en el catálogo|O|O||D|||Público en general
10101500|Animales vivos de granja|O|O||D||1
10101501|Gatos vivos|O|O||D||1
10101502|Perros|O|O||D||1
10101504|Visón|O|O||D||1
10101505|Ratas|O|O||D||1
10101506|Caballos|O|O||D||1|Equinos, Potrancas, Potras, Potrillos, Potros, Yeguas
10101507|Ovejas|O|O||D||1|Borregos, Carneros
10101508|Cabras|O|O||D||1|Borregos cimarrones, Cabritos, Cabros, Carnero de las Rocosas, Chivas, Chivatos, Chivos, Irascos, Machos cabríos, Chivos
10101509|Asnos|O|O||D||1|Borricos, Burros
10101510|Ratones|O|O||D||1
10101511|Cerdos|O|O||D||1|Cerdo montés, Chanchos, Chanchos almizcleros, Chanchos de monte, Cochinillos, Cochinos, Cochinos de monte, Cuche, Cuinos, Gorrinos, Jabalíes americanos, Lechones, Cochinos de monte, Pecaríes, Porcinos, Puercos, Puercos de monte, Tayatos
10101512|Conejos|O|O||D||1|Liebres
10101513|Cobayas o conejillos de indias|O|O||D||1|Chanchito de Indias, Cobayos, Cuilo, Cuyo
10101514|Primates|O|O||D||1|Changos, Chimpancés, Gorilas, Lémures, Macacos, Micos, Monos, Orangutanes, Simios, Monos
10101515|Armadillos|O|O||D||1|Toches
10101516|Ganado vacuno|O|O||D||1|Bueyes, Búfalos, Cebús, Otros vacunos o bovinos, Toros, Vacas
10101517|Camellos|O|O||D||1|Dromedarios
10101600|Pájaros y aves de corral vivos|O|O||D||1
10101601|Pollos vivos|O|O||D||1|Gallinas, Gallinas de guinea, Gallos, Pintadas, Pollitos
10101602|Patos vivos|O|O||D||1
10101603|Pavos vivos|O|O||D||1|Gallipavos, Guajolotes, Pavos salvajes
10101604|Gansos vivos|O|O||D||1
10101605|Faisanes vivos|O|O||D||1
10101700|Peces vivos|O|O||D||1
10101701|Salmones vivos|O|O||D||1
10101702|Trucha viva|O|O||D||1
10101703|Tilapia viva|O|O||D||1|Mojarra
10101704|Carpa viva|O|O||D||1
10101705|Anguilas vivas|O|O||D||1
10101800|Mariscos e invertebrados acuáticos vivos|O|O||D||1
10101801|Camarón vivo|O|O||D||1|Esquilas
10101802|Almejas vivas|O|O||D||1
10101803|Mejillones vivos|O|O||D||1
10101804|Ostras vivas|O|O||D||1
10101805|Cangrejos vivos|O|O||D||1
10101806|Abulones vivos|O|O||D||1|Orejas de mar
10101807|Pulpo vivo|O|O||D||1|Octópodo
10101808|Calamar vivo|O|O||D||1
10101809|Sanguijuelas|O|O||D||1|Hirudineas, Hirudos, Hirudíneo
10101900|Insectos vivos|O|O||D||1
10101901|Mariposas|O|O||D||1
10101902|Escarabajos|O|O||D||1|Mariquitas, Sanjuaneros
10101903|Abejas|O|O||D||1
10101904|Gusanos de seda|O|O||D||1|Crisálida, Larva, Orug
10102000|Animales salvajes vivos|O|O||D||1
10102001|Elefantes|O|O||D||1|Paquidermos
10102002|Zorros vivos|O|O||D||1|Zorras
10102100|Huevos de aves para incubar|O|O||D||1
10111300|Accesorios, equipo y tratamientos para los animales domésticos|O|O||D||1|Accesorios, equipo y medicamentos para animales domésticos
10111301|Juguetes para mascotas|O|O||D||1
10111302|Productos para el aseo y cuidado de mascotas|O|O||D||1
10111303|Equipo para el manejo de desperdicios de las mascotas|O|O||D||1
10111304|Tazones o equipo para alimentación de mascotas|O|O||D||1
10111305|Tratamientos medicados para mascotas|O|O||D||1|Tratamientos medicinales para mascotas
10111306|Kits para el entrenamiento de mascotas domésticas|O|O||D||1
10111307|Cobijas para mascotas|O|O||D||1|Mantas para mascotas, Sábanas para mascotas
10121500|Pienso para ganado|O|O||D||1|Alimento para ganado
10121501|Salvado de trigo puro|O|O||D||1
10121502|Avena para forraje|O|O||D||1
10121503|Maíz para forraje|O|O||D||1
10121504|Sorgo para forraje|O|O||D||1
10121505|Heno|O|O||D||1
10121506|Tortas oleaginosas|O|O||D||1|Torta de aceite para ganado
10121507|Forraje compuesto|O|O||D||1
10121600|Alimento para pájaros y aves de corral|O|O||D||1
10121601|Alimento vivo para aves|O|O||D||1
10121602|Alpiste|O|O||D||1
10121603|Botanas o comida recreacional para aves|O|O||D||1
10121604|Alimento avícola|O|O||D||1
10121700|Alimento para peces|O|O||D||1
10121701|Salmuera fresca o congelada|O|O||D||1
10121702|Alimento granulado para peces|O|O||D||1
10121703|Alimento en hojuelas para peces|O|O||D||1
10121800|Alimento para perros y gatos|O|O||D||1
10121801|Comida seca para perros|O|O||D||1
10121802|Comida húmeda para perros|O|O||D||1
10121803|Leche para perros o gatos|O|O||D||1
10121804|Comida seca para gatos|O|O||D||1
10121805|Comida húmeda para gatos|O|O||D||1
10121806|Botanas o comida recreacional para gatos o perros|O|O||D||1
10121900|Alimento para roedores|O|O||D||1
10121901|Comida granulada para roedores|O|O||D||1
10122000|Alimento para reptiles|O|O||D||1
10122001|Comida granulada para reptiles|O|O||D||1
10122002|Comida húmeda para reptiles|O|O||D||1
10122003|Comida viva para reptiles|O|O||D||1
10122100|Comida para animales variados|O|O||D||1|Comida para diversos animales
10122101|Comida para cerdos|O|O||D||1|Comida para chanchos, Comida para cochinillos, Comida para cochinos, Comida para cuche, Comida para cuinos, Comida para gorrinos, Comida para lechones, Comida para marranos, Comida para porcinos, Comida para puercos, Comida para lechones
10122102|Comida para visones|O|O||D||1
10122103|Comida para monos|O|O||D||1
10122104|Comida para conejos|O|O||D||1
10131500|Cobertizos para animales|O|O||D||1
10131506|Establos para ganado|O|O||D||1
10131507|Casas para mascotas domesticadas|O|O||D||1
10131508|Camas para mascotas|O|O||D||1
10131600|Recipientes para animales|O|O||D||1|Contenedores de comida para animales
10131601|Jaulas o sus accesorios|O|O||D||1
10131602|Perreras|O|O||D||1
10131603|Equipaje para el transporte de animales|O|O||D||1
10131604|Correas para perros|O|O||D||1
10131700|Hábitat para animales|O|O||D||1|Ambientes para animales
10131701|Terrarios|O|O||D||1
10131702|Acuarios|O|O||D||1
10141500|Talabartería|O|O||D||1|Guarniciones para caballerías
10141501|Sillas de montar|O|O||D||1
10141502|Fustas y látigos|O|O||D||1
10141503|Herraduras para caballo|O|O||D||1
10141504|Herraduras para mula|O|O||D||1
10141505|Sillín o pelero|O|O||D||1
10141600|Arneses|O|O||D||1
10141601|Bridas|O|O||D||1|Correas para caballos
10141602|Yugos|O|O||D||1
10141603|Bocados para caballos|O|O||D||1|Embocaduras para caballo
10141604|Riendas|O|O||D||1|Correas
10141605|Estribos|O|O||D||1
10141606|Correas o traíllas|O|O||D||1
10141607|Arneses de cuello para animales|O|O||D||1
10141608|Arneses o sus accesorios|O|O||D||1
10141609|Sujetadores|O|O||D||1
10141610|Bozales|O|O||D||1
10141611|Soportes para correas|O|O||D||1
10151500|Semillas y plántulas vegetales|O|O||D||1|Semillas y vástagos vegetales
10151501|Semillas o plántulas de fríjol|O|O||D||1|Semillas o vástago primario de fríjol, Semillas o vástago primario de fríjol blanco, Semillas o vástago primario de fríjol negro, Semillas o vástago primario de fríjol rojo adzuki
10151502|Semillas o plántulas de zanahoria|O|O||D||1|Semillas o vástago primario de zanahoria
10151503|Semillas o plántulas de apio|O|O||D||1|Semillas o vástago primario de apio
10151504|Semillas o plántulas de chiles|O|O||D||1|Semillas o vástago primario de chiles
10151505|Semillas o plántulas de calabacín|O|O||D||1|Semillas o vástago primario de calabacín
10151506|Semillas o plántulas de alverja|O|O||D||1|Semillas o vástago primario de chícharo, Semillas o vástago primario de guisante
10151507|Semillas o plántulas de pepino cohombro|O|O||D||1|Semillas o vástago primario de pepino cohombro
10151508|Semillas o plántulas de berenjena|O|O||D||1|Semillas o vástago primario de berenjena
10151509|Semillas o plántulas de endivias|O|O||D||1|Semillas o vástago primario de endivias
10151510|Semillas o plántulas de ajo|O|O||D||1|Semillas o vástago primario de ajo
10151511|Semillas o plántulas de puerro|O|O||D||1|Semillas o vástago primario de puerro
10151512|Semillas o plántulas de lechuga|O|O||D||1|Semillas o vástago primario de lechuga
10151513|Semillas o plántulas de maíz|O|O||D||1|Semillas o vástago primario de maíz
10151514|Semillas o plántulas de melón|O|O||D||1|Semillas o vástago primario de melón
10151515|Semillas o plántulas cebolla|O|O||D||1|Semillas o vástago primario de cebolla
10151516|Semillas o plántulas de soya|O|O||D||1|Semillas o vástago primario de soya
10151517|Semillas o plántulas de espinaca|O|O||D||1|Semillas o vástago primario de espinaca
10151518|Semillas o plántulas de tomate|O|O||D||1|Semillas o vástago primario de tomate
10151519|Semillas o plántulas de nabo|O|O||D||1|Semillas o vástago primario de nabo
10151520|Semillas o plántulas de acelga|O|O||D||1|Semillas o vástago primario de acelga
10151521|Semillas o plántulas de pimiento morrón|O|O||D||1|Semillas o vástago primario de pimiento morrón
10151522|Semillas o plántulas de remolacha|O|O||D||1|Semillas o vástago primario de betabel
10151523|Semillas o plántulas de coliflor|O|O||D||1|Semillas o vástago primario de coliflor
10151524|Semillas o plántulas de perejil|O|O||D||1|Semillas o vástago primario de perejil
10151525|Semillas o plántulas de brócoli|O|O||D||1|Semillas o vástago primario de brócoli
10151526|Semillas o plántulas de repollo|O|O||D||1|Semillas o vástago primario de col
10151527|Semillas o plántulas de papa|O|O||D||1|Semillas o vástago primario de patata
10151528|Semillas o plántulas de batata|O|O||D||1|Semillas o vástago primario de camote
10151529|Semillas o plántulas de calabaza|O|O||D||1|Semillas o vástago primario de calabaza
10151530|Semillas o plántulas de rábano|O|O||D||1|Semillas o vástago primario de rabanito, Semillas o vástago primario de rábano
10151531|Semillas o plántulas de repollitos de bruselas|O|O||D||1|Semillas o vástago primario de col de Bruselas
10151532|Semillas o plántulas de ahuyama|O|O||D||1|Semillas o vástago primario de calabaza de castilla
10151533|Semillas o plántulas de okra|O|O||D||1|Semillas o vástago primario de okra
10151534|Semillas o plántulas de melón cantalupo|O|O||D||1|Semillas o vástago primario de melón cantalupo
10151535|Semillas o plántulas de maní|O|O||D||1|Semillas o vástago primario de cacahuate
10151536|Semillas o plántulas de caigua|O|O||D||1|Semillas o vástago primario de caigua
10151537|Semillas o plántulas de espárrago|O|O||D||1|Semillas o vástago primario de espárrago
10151538|Semillas o plántulas de garbanzo|O|O||D||1|Semillas o vástago primario de garbanzo
10151539|Semillas o plántulas de haba|O|O||D||1|Semillas o vástago primario de haba
10151600|Semillas de cereales|O|O||D||1
10151601|Semillas de trigo|O|O||D||1
10151602|Semillas de canola|O|O||D||1|Semillas de colza
10151603|Semillas de cebada|O|O||D||1
10151604|Semillas de mijo|O|O||D||1
10151605|Semillas de avena|O|O||D||1
10151606|Semillas de ajonjolí|O|O||D||1|Semillas de sésamo
10151607|Semillas de linaza|O|O||D||1|Semillas de lino
10151608|Semillas de aceite de ricino|O|O||D||1|Semillas de ricino
10151609|Semillas de maíz|O|O||D||1
10151610|Semillas de centeno|O|O||D||1
10151611|Semillas de sorgo|O|O||D||1
10151612|Semillas o plántulas de kiwicha|O|O||D||1|Semillas o vástagos de amaranto
10151613|Semillas o plántulas de quínoa|O|O||D||1|Semillas o vástagos de quinua
10151700|Semillas y plántulas de hierba y forraje|O|O||D||1|Semillas y vástagos de hierba y forraje
10151701|Semillas o plántulas de arroz|O|O||D||1
10151702|Semillas o plántulas de trébol|O|O||D||1
10151703|Semillas o plántulas de alfalfa|O|O||D||1
10151704|Semillas o plántulas de pasto|O|O||D||1|Semillas o vástagos para césped
10151705|Semillas o plántulas de veza (gachas / guija)|O|O||D||1
10151706|Semillas o plántulas de guar|O|O||D||1
10151800|Semillas y plántulas de especias|O|O||D||1|Semillas y vástagos de especias
10151801|Semillas o plántulas de pimienta|O|O||D||1
10151802|Semillas o plántulas de vainilla|O|O||D||1
10151803|Semillas o plántulas de canela|O|O||D||1
10151804|Semillas o plántulas de clavo de olor|O|O||D||1
10151805|Semillas o plántulas de cilantro|O|O||D||1
10151806|Semillas o plántulas de jengibre|O|O||D||1
10151807|Semillas o plántulas de azafrán|O|O||D||1
10151808|Semillas o plántulas de tomillo|O|O||D||1
10151809|Semillas o plántulas de curry|O|O||D||1|Semillas o vástagos de curri
10151810|Semillas o plántulas de mostaza|O|O||D||1
10151811|Semillas o plántulas de ginseng|O|O||D||1
10151812|Semillas o plántulas de champiñones|O|O||D||1
10151813|Semillas o plántulas de sacha inchi|O|O||D||1
10151814|Semillas o plántulas de achiote|O|O||D||1
10151815|Semillas o plántulas de kudzu|O|O||D||1
10151816|Semillas o plántulas de albahaca|O|O||D||1
10151817|Semillas o plántulas de anís|O|O||D||1|Semillas o vástago de badiana
10151900|Semillas, bulbos, plántulas y esquejes de flores|O|O||D||1|Semillas, bulbos, vástagos y codos de flores
10151901|Semillas, bulbos, plántulas o esquejes de tulipán|O|O||D||1
10151902|Semillas, plántulas o esquejes de rosa|O|O||D||1
10151903|Semillas, bulbos, plántulas o esquejes de narciso|O|O||D||1
10151904|Semillas de girasol|O|O||D||1|Semillas de acahual, Semillas de mirasol
10151905|Bulbos o tallos de jacinto|O|O||D||1
10151906|Bulbos de lirio|O|O||D||1
10151907|Semillas o plántulas de veza|O|O||D||1
10152000|Semillas y esquejes de árboles y arbustos|O|O||D||1
10152001|Semillas o esquejes de árboles frutales|O|O||D||1
10152002|Semillas o esquejes de coníferas|O|O||D||1
10152003|Semillas o esquejes de árboles de frutos secos|O|O||D||1
10152004|Plántulas de latifoliados|O|O||D||1
10152005|Plántulas de coníferas|O|O||D||1
10152006|Semillas o yemas de pino|O|O||D||1
10152007|Semillas o yemas de algarrobo|O|O||D||1
10152100|Residuos que no sean de piensos|O|O||D||1|Residuos que no sean alimento
10152101|Extracción de los residuos de semilla de babool|O|O||D||1
10152102|Residuos de semilla de colza|O|O||D||1
10152103|Residuo de semillas de linaza|O|O||D||1
10152104|Torta de neem|O|O||D||1
10152200|Semillas de cultivos fibrosos y semilleros|O|O||D||1
10152201|Semillas o plántulas de algodón|O|O||D||1
10152202|Semillas o plántulas de lino|O|O||D||1|Semillas o vástago de linaza
10152300|Plántulas y semillas de leguminosas|O|O||D||1
10152400|Plántulas y semillas de tubérculos|O|O||D||1
10161500|Árboles y arbustos|O|O||D||1
10161501|Aceitunos|O|O||D||1
10161502|Cafetos|O|O||D||1
10161503|Cacaoteros|O|O||D||1|Cocoa
10161504|Manzanos|O|O||D||1
10161505|Peros|O|O||D||1
10161506|Naranjos|O|O||D||1
10161507|Rododendros|O|O||D||1|Azaleas
10161508|Plantas de te|O|O||D||1
10161509|Coníferas|O|O||D||1
10161510|Abetos rojos (píceas)|O|O||D||1|Abetos falsos
10161511|Pinos|O|O||D||1
10161512|Abetos|O|O||D||1
10161513|Palmeras|O|O||D||1
10161514|Casuarina|O|O||D||1|Roble hembra
10161515|Ciprés|O|O||D||1
10161516|Eucalipto|O|O||D||1
10161517|Árbol de quinua|O|O||D||1|Árbol de quina
10161518|Magnolio|O|O||D||1
10161519|Mioporo|O|O||D||1|Siempreverde
10161520|Acalifa|O|O||D||1|Cola de zorro roja
10161521|Tecomaria capensis o madreselva del cabo|O|O||D||1|Bignonia roja
10161522|Arbusto croton bolaina|O|O||D||1|Croton variegado
10161523|Abutillón|O|O||D||1|Malva
10161524|Ficus|O|O||D||1|Higuera
10161525|Lúcumo|O|O||D||1
10161526|Aguacatal|O|O||D||1
10161527|Guanábano|O|O||D||1
10161528|Carambolo|O|O||D||1|Membrillo torombolo
10161529|Ciruelo|O|O||D||1
10161530|Árbol de quince|O|O||D||1|Árbol de membrillo
10161600|Plantas florales|O|O||D||1|Agave, Caña de azúcar, Mague
10161602|Poinsettias|O|O||D||1|Nochebuena
10161604|Azaleas|O|O||D||1
10161605|Cactos|O|O||D||1|Cactus, Nopal
10161606|Ageratum púrpura|O|O||D||1|Agérato mexicano
10161800|Plantas sin flor|O|O||D||1
10161801|Helechos|O|O||D||1
10161802|Hiedras|O|O||D||1
10161803|Filodendros|O|O||D||1|Trepadora
10161804|Líquenes|O|O||D||1
10161805|Vides|O|O||D||1|Parra, Vid
10161900|Productos florales secos|O|O||D||1
10161901|Vainas secas|O|O||D||1
10161902|Follaje seco|O|O||D||1
10161903|Helechos secos|O|O||D||1
10161905|Ramas y tallos secos|O|O||D||1
10161906|Penachos de gramíneas secos|O|O||D||1
10161907|Flores secas prensadas|O|O||D||1
10161908|Pétalos secos|O|O||D||1
10171500|Abonos orgánicos y nutrientes para plantas|O|O||D||1
10171501|Estiércol o guano|O|O||D||1
10171502|Hormonas para plantas|O|O||D||1
10171503|Harina de pescado|O|O||D||1
10171504|Abono|O|O||D||1
10171505|Nutriente foliar|O|O||D||1
10171506|Humus|O|O||D||1
10171600|Abonos químicos y nutrientes para plantas|O|O||D||1
10171601|Fertilizante nitrogenado|O|O||D||1
10171602|Fertilizante de potasio|O|O||D||1
10171603|Fertilizante de fósforo|O|O||D||1
10171604|Fertilizante de sulfuro|O|O||D||1
10171605|Mezclas de nitrógeno – fósforo – potasio – npk|O|O||D||1
10171606|Fertilizarte de sílice puro|O|O||D||1
10171607|Fertilizante con magnesio|O|O||D||1
10171608|Fertilizante micro elemento|O|O||D||1
10171609|Fertilizante fosfato de sílice|O|O||D||1
10171610|Fertilizante potasio de sílice|O|O||D||1
10171611|Fertilizante de calcio|O|O||D||1
10171700|Herbicidas|O|O||D||1
10171701|Matamalezas|O|O||D||1
10171702|Fungicidas|O|O||D||1
10171800|Acondicionadores de suelos|O|O||D||1
10171801|Acondicionador orgánico de suelos|O|O||D||1
10171802|Acondicionador inorgánico de suelos|O|O||D||1
10191500|Pesticidas o repelentes de plagas|O|O||D||1
10191506|Mata – roedores|O|O||D||1|Veneno para roedores
10191507|Repelentes de aves|O|O||D||1
10191508|Protectores contra termitas|O|O||D||1
10191509|Insecticidas|O|O||D||1
10191510|Abamectina|O|O||D||1
10191511|Fipronil|O|O||D||1
10191700|Dispositivos para control de plagas|O|O||D||1
10191701|Trampas para control animal|O|O||D||1
10191703|Trampas para el control de insectos voladores|O|O||D||1
10191704|Matamoscas|O|O||D||1
10191705|Lazos|O|O||D||1
10191706|Cepos|O|O||D||1|Ratoneras
10191707|Repelente ultrasónico de pestes|O|O||D||1|Ahuyentador Ultrasónico
10201500|Rosales vivos azules o lavanda o púrpura|O|O||D||1
10201501|Rosal vivo allure o sterling 95|O|O||D||1
10201502|Rosal vivo amnesia|O|O||D||1
10201503|Rosal vivo augusta louise|O|O||D||1
10201504|Rosal vivo avant garde|O|O||D||1
10201505|Rosal vivo blue bird|O|O||D||1
10201506|Rosal vivo curiosa|O|O||D||1
10201507|Rosal vivo cool water|O|O||D||1
10201508|Rosal vivo delilah|O|O||D||1
10201509|Rosal vivo double party|O|O||D||1
10201510|Rosal vivo faith|O|O||D||1
10201511|Rosal vivo mami blue o mammy blue|O|O||D||1
10201512|Rosal vivo marítimo|O|O||D||1
10201513|Rosal vivo milano|O|O||D||1
10201514|Rosal vivo mistery|O|O||D||1
10201515|Rosal vivo ocean song o boyfriend|O|O||D||1
10201516|Rosal vivo cezanne púrpura|O|O||D||1
10201517|Rosal vivo purple fragrance|O|O||D||1
10201518|Rosal vivo sanaa|O|O||D||1
10201519|Rosal vivo silverstone|O|O||D||1
10201520|Rosal vivo soulmate|O|O||D||1
10201521|Rosal vivo stranger|O|O||D||1
10201522|Rosal vivo tinted blue|O|O||D||1
10201523|Rosal vivo two faces|O|O||D||1
10201600|Rosales vivos chocolate o marrón|O|O||D||1
10201601|Rosal vivo black lava|O|O||D||1
10201602|Rosal vivo cimarron|O|O||D||1
10201603|Rosal vivo coffee break|O|O||D||1
10201604|Rosal vivo estelle|O|O||D||1
10201605|Rosal vivo gypsy leonidas|O|O||D||1
10201606|Rosal vivo leonidas|O|O||D||1
10201607|Rosal vivo matilda|O|O||D||1
10201608|Rosal vivo sunny leonidas|O|O||D||1
10201609|Rosal vivo terra nostra|O|O||D||1
10201610|Rosal vivo terracotta|O|O||D||1
10201700|Rosales vivos crema|O|O||D||1
10201701|Rosal vivo advenire|O|O||D||1
10201702|Rosal vivo alex|O|O||D||1
10201703|Rosal vivo antique brass|O|O||D||1
10201704|Rosal vivo aubade|O|O||D||1
10201705|Rosal vivo beach|O|O||D||1
10201706|Rosal vivo belle pearl|O|O||D||1
10201707|Rosal vivo blush de los andes|O|O||D||1
10201708|Rosal vivo camel|O|O||D||1
10201709|Rosal vivo caramel antike o caramel antique|O|O||D||1
10201710|Rosal vivo champagne|O|O||D||1
10201711|Rosal vivo clear ocean|O|O||D||1
10201712|Rosal vivo combo|O|O||D||1
10201713|Rosal vivo creme de la creme|O|O||D||1
10201714|Rosal vivo emanuella|O|O||D||1
10201715|Rosal vivo evolution|O|O||D||1
10201716|Rosal vivo fedora|O|O||D||1
10201717|Rosal vivo fenice|O|O||D||1
10201718|Rosal vivo french vanilla|O|O||D||1
10201719|Rosal vivo hollywood|O|O||D||1
10201720|Rosal vivo ilios|O|O||D||1
10201721|Rosal vivo jelena|O|O||D||1
10201722|Rosal vivo kameleon|O|O||D||1
10201723|Rosal vivo kentucky|O|O||D||1
10201724|Rosal vivo kings pride|O|O||D||1
10201725|Rosal vivo latin fusion|O|O||D||1
10201726|Rosal vivo lemon dream|O|O||D||1
10201727|Rosal vivo magic moka|O|O||D||1
10201728|Rosal vivo mamamia|O|O||D||1
10201729|Rosal vivo message|O|O||D||1
10201730|Rosal vivo muneca o munieca|O|O||D||1
10201731|Rosal vivo parfum de rosas|O|O||D||1
10201732|Rosal vivo porcelina|O|O||D||1
10201733|Rosal vivo privilege|O|O||D||1
10201734|Rosal vivo quicksand|O|O||D||1
10201735|Rosal vivo rollercoaster|O|O||D||1
10201736|Rosal vivo romantic curiosa|O|O||D||1
10201737|Rosal vivo safari|O|O||D||1
10201738|Rosal vivo sahara|O|O||D||1
10201739|Rosal vivo sandy femma|O|O||D||1
10201740|Rosal vivo talea|O|O||D||1
10201741|Rosal vivo timeless|O|O||D||1
10201742|Rosal vivo transition|O|O||D||1
10201743|Rosal vivo trump|O|O||D||1
10201744|Rosal vivo twin|O|O||D||1
10201745|Rosal vivo vendela|O|O||D||1
10201746|Rosal vivo virginia|O|O||D||1
10201800|Rosales vivos verdes o lima|O|O||D||1
10201801|Rosal vivo amandine|O|O||D||1
10201802|Rosal vivo caipirinha|O|O||D||1
10201803|Rosal vivo green fashion|O|O||D||1
10201804|Rosal vivo green tea|O|O||D||1
10201805|Rosal vivo jade|O|O||D||1
10201806|Rosal vivo limbo|O|O||D||1
10201807|Rosal vivo limena o limenia|O|O||D||1
10201808|Rosal vivo limona|O|O||D||1
10201809|Rosal vivo old dutch|O|O||D||1
10201810|Rosal vivo super green|O|O||D||1
10201811|Rosal vivo sweet green|O|O||D||1
10201812|Rosal vivo viva|O|O||D||1
10201813|Rosal vivo zazu|O|O||D||1
10201900|Rosales vivos rosado claro|O|O||D||1
10201901|Rosal vivo anna|O|O||D||1
10201902|Rosal vivo bella vita|O|O||D||1
10201903|Rosal vivo bridal dream|O|O||D||1
10201904|Rosal vivo candy bianca|O|O||D||1
10201905|Rosal vivo caress|O|O||D||1
10201906|Rosal vivo carolina|O|O||D||1
10201907|Rosal vivo climax|O|O||D||1
10201908|Rosal vivo danny|O|O||D||1
10201909|Rosal vivo dolce vita|O|O||D||1
10201910|Rosal vivo elite|O|O||D||1
10201911|Rosal vivo emma|O|O||D||1
10201912|Rosal vivo engagement|O|O||D||1
10201913|Rosal vivo esther|O|O||D||1
10201914|Rosal vivo excalibur|O|O||D||1
10201915|Rosal vivo exciting|O|O||D||1
10201916|Rosal vivo first lady|O|O||D||1
10201917|Rosal vivo geraldine|O|O||D||1
10201918|Rosal vivo gotcha|O|O||D||1
10201919|Rosal vivo harmonie|O|O||D||1
10201920|Rosal vivo heaven|O|O||D||1
10201921|Rosal vivo high and elegant|O|O||D||1
10201922|Rosal vivo katherine|O|O||D||1
10201923|Rosal vivo king kong|O|O||D||1
10201924|Rosal vivo livia|O|O||D||1
10201925|Rosal vivo lorena|O|O||D||1
10201926|Rosal vivo lovely|O|O||D||1
10201927|Rosal vivo maaike|O|O||D||1
10201928|Rosal vivo marilyn|O|O||D||1
10201929|Rosal vivo marlise|O|O||D||1
10201930|Rosal vivo miranda o ausimmon|O|O||D||1
10201931|Rosal vivo mona lisa|O|O||D||1
10201932|Rosal vivo nirvana|O|O||D||1
10201933|Rosal vivo o hara|O|O||D||1
10201934|Rosal vivo ole|O|O||D||1
10201935|Rosal vivo olga|O|O||D||1
10201936|Rosal vivo pacífica|O|O||D||1
10201937|Rosal vivo party mix|O|O||D||1
10201938|Rosal vivo peckoubo o pekcoubo|O|O||D||1
10201939|Rosal vivo phoebe o ausnotice|O|O||D||1
10201940|Rosal vivo pink farfalla|O|O||D||1
10201941|Rosal vivo pink finess|O|O||D||1
10201942|Rosal vivo pink magic|O|O||D||1
10201943|Rosal vivo pink osiana|O|O||D||1
10201944|Rosal vivo pretty woman|O|O||D||1
10201945|Rosal vivo romance|O|O||D||1
10201946|Rosal vivo romantic antike o antique|O|O||D||1
10201947|Rosal vivo rosalind o astew|O|O||D||1
10201948|Rosal vivo rosita vendela|O|O||D||1
10201949|Rosal vivo secret garden|O|O||D||1
10201950|Rosal vivo solaire|O|O||D||1
10201951|Rosal vivo sophie|O|O||D||1
10201952|Rosal vivo sweet akito|O|O||D||1
10201953|Rosal vivo sweet avalanche|O|O||D||1
10201954|Rosal vivo sweet elegance|O|O||D||1
10201955|Rosal vivo sweet pink|O|O||D||1
10201956|Rosal vivo titanic|O|O||D||1
10201957|Rosal vivo toscanini|O|O||D||1
10201958|Rosal vivo vania|O|O||D||1
10201959|Rosal vivo vanity|O|O||D||1
10201960|Rosal vivo vision|O|O||D||1
10201961|Rosal vivo vivaldi|O|O||D||1
10201962|Rosal vivo whisper|O|O||D||1
10202000|Rosales vivos multicolor rosados|O|O||D||1
10202001|Rosal vivo attracta|O|O||D||1
10202002|Rosal vivo boheme|O|O||D||1
10202003|Rosal vivo carousel|O|O||D||1
10202004|Rosal vivo cezanne|O|O||D||1
10202005|Rosal vivo crazy one|O|O||D||1
10202006|Rosal vivo dance valley|O|O||D||1
10202007|Rosal vivo duett|O|O||D||1
10202008|Rosal vivo esperance|O|O||D||1
10202009|Rosal vivo fiesta|O|O||D||1
10202010|Rosal vivo halloween|O|O||D||1
10202011|Rosal vivo highlander|O|O||D||1
10202012|Rosal vivo hot ambiance|O|O||D||1
10202013|Rosal vivo la belle|O|O||D||1
10202014|Rosal vivo laguna|O|O||D||1
10202015|Rosal vivo latin ambiance|O|O||D||1
10202016|Rosal vivo latin breeze|O|O||D||1
10202017|Rosal vivo long arifa|O|O||D||1
10202018|Rosal vivo murano|O|O||D||1
10202019|Rosal vivo n-joy rose|O|O||D||1
10202020|Rosal vivo panama|O|O||D||1
10202021|Rosal vivo peppermint|O|O||D||1
10202022|Rosal vivo pijama party|O|O||D||1
10202023|Rosal vivo portofino|O|O||D||1
10202024|Rosal vivo priceless|O|O||D||1
10202025|Rosal vivo queen amazon|O|O||D||1
10202026|Rosal vivo ranuncula|O|O||D||1
10202027|Rosal vivo rossini|O|O||D||1
10202028|Rosal vivo sabina o sabrina|O|O||D||1
10202029|Rosal vivo scandal|O|O||D||1
10202030|Rosal vivo silvery pink|O|O||D||1
10202031|Rosal vivo something else|O|O||D||1
10202032|Rosal vivo soutine|O|O||D||1
10202033|Rosal vivo sovereign|O|O||D||1
10202034|Rosal vivo super disco|O|O||D||1
10202035|Rosal vivo ts 1968|O|O||D||1
10202036|Rosal vivo variance|O|O||D||1
10202037|Rosal vivo verdi|O|O||D||1
10202100|Rosales vivos anaranjados|O|O||D||1
10202101|Rosal vivo alhambra|O|O||D||1
10202102|Rosal vivo aloha|O|O||D||1
10202103|Rosal vivo amber|O|O||D||1
10202104|Rosal vivo apache|O|O||D||1
10202105|Rosal vivo arabia|O|O||D||1
10202106|Rosal vivo bengala|O|O||D||1
10202107|Rosal vivo bibi|O|O||D||1
10202108|Rosal vivo caramba|O|O||D||1
10202109|Rosal vivo caramella|O|O||D||1
10202110|Rosal vivo carla|O|O||D||1
10202111|Rosal vivo cartagena|O|O||D||1
10202112|Rosal vivo chanson|O|O||D||1
10202113|Rosal vivo charmer|O|O||D||1
10202114|Rosal vivo cherry brandy|O|O||D||1
10202115|Rosal vivo chilis|O|O||D||1
10202116|Rosal vivo cinnamon|O|O||D||1
10202117|Rosal vivo colandro|O|O||D||1
10202118|Rosal vivo coral sea|O|O||D||1
10202119|Rosal vivo corvette o red corvette|O|O||D||1
10202120|Rosal vivo dark milva|O|O||D||1
10202121|Rosal vivo donna|O|O||D||1
10202122|Rosal vivo dreamer|O|O||D||1
10202123|Rosal vivo el dorado|O|O||D||1
10202124|Rosal vivo el toro|O|O||D||1
10202125|Rosal vivo elena|O|O||D||1
10202126|Rosal vivo ensueño|O|O||D||1
10202127|Rosal vivo euforia|O|O||D||1
10202128|Rosal vivo exótica|O|O||D||1
10202129|Rosal vivo fancy amazon|O|O||D||1
10202130|Rosal vivo fiction|O|O||D||1
10202131|Rosal vivo finess|O|O||D||1
10202132|Rosal vivo flameco|O|O||D||1
10202133|Rosal vivo free spirit|O|O||D||1
10202134|Rosal vivo gelato|O|O||D||1
10202135|Rosal vivo gypsy curiosa|O|O||D||1
10202136|Rosal vivo high and magic|O|O||D||1
10202137|Rosal vivo high and orange magic|O|O||D||1
10202138|Rosal vivo iguana o alegra|O|O||D||1
10202139|Rosal vivo impulse|O|O||D||1
10202140|Rosal vivo indian femma|O|O||D||1
10202141|Rosal vivo indian sunset|O|O||D||1
10202142|Rosal vivo karusso|O|O||D||1
10202143|Rosal vivo kerio|O|O||D||1
10202144|Rosal vivo kiki|O|O||D||1
10202145|Rosal vivo latin circus|O|O||D||1
10202146|Rosal vivo leonisa|O|O||D||1
10202147|Rosal vivo lipstick|O|O||D||1
10202148|Rosal vivo lobita|O|O||D||1
10202149|Rosal vivo luca|O|O||D||1
10202150|Rosal vivo manitou|O|O||D||1
10202151|Rosal vivo mariana|O|O||D||1
10202152|Rosal vivo marjan o pk sensation|O|O||D||1
10202153|Rosal vivo milonga|O|O||D||1
10202154|Rosal vivo milva|O|O||D||1
10202155|Rosal vivo miracle|O|O||D||1
10202156|Rosal vivo mirage|O|O||D||1
10202157|Rosal vivo monte carlo|O|O||D||1
10202158|Rosal vivo movie star|O|O||D||1
10202159|Rosal vivo nikita|O|O||D||1
10202160|Rosal vivo orange flame|O|O||D||1
10202161|Rosal vivo orange france|O|O||D||1
10202162|Rosal vivo orange intuition|O|O||D||1
10202163|Rosal vivo orange unique|O|O||D||1
10202164|Rosal vivo orangine u orangina|O|O||D||1
10202165|Rosal vivo papaya|O|O||D||1
10202166|Rosal vivo pareo|O|O||D||1
10202167|Rosal vivo peach sherbet|O|O||D||1
10202168|Rosal vivo queensday|O|O||D||1
10202169|Rosal vivo rosselle|O|O||D||1
10202170|Rosal vivo royal circus|O|O||D||1
10202171|Rosal vivo sari|O|O||D||1
10202172|Rosal vivo sensual|O|O||D||1
10202173|Rosal vivo soap|O|O||D||1
10202174|Rosal vivo sombrero|O|O||D||1
10202175|Rosal vivo spicy|O|O||D||1
10202176|Rosal vivo star 2000|O|O||D||1
10202177|Rosal vivo summer versilia|O|O||D||1
10202178|Rosal vivo trixx|O|O||D||1
10202179|Rosal vivo tropical amazon|O|O||D||1
10202180|Rosal vivo utopia|O|O||D||1
10202181|Rosal vivo valentine|O|O||D||1
10202182|Rosal vivo verano|O|O||D||1
10202183|Rosal vivo versilia|O|O||D||1
10202184|Rosal vivo voodoo|O|O||D||1
10202185|Rosal vivo wow|O|O||D||1
10202186|Rosal vivo yabadabadoo|O|O||D||1
10202200|Rosales vivos durazno|O|O||D||1
10202201|Rosal vivo alejandra|O|O||D||1
10202202|Rosal vivo azafran|O|O||D||1
10202203|Rosal vivo big fun|O|O||D||1
10202204|Rosal vivo cabaret|O|O||D||1
10202205|Rosal vivo capuccino|O|O||D||1
10202206|Rosal vivo carpe diem|O|O||D||1
10202207|Rosal vivo cosima|O|O||D||1
10202208|Rosal vivo cumbia|O|O||D||1
10202209|Rosal vivo dream|O|O||D||1
10202210|Rosal vivo epoca|O|O||D||1
10202211|Rosal vivo fado|O|O||D||1
10202212|Rosal vivo femma|O|O||D||1
10202213|Rosal vivo guajira|O|O||D||1
10202214|Rosal vivo high and arena|O|O||D||1
10202215|Rosal vivo high and dandy|O|O||D||1
10202216|Rosal vivo high and lucky|O|O||D||1
10202217|Rosal vivo high and peach|O|O||D||1
10202218|Rosal vivo imagination|O|O||D||1
10202219|Rosal vivo isis|O|O||D||1
10202220|Rosal vivo joy o light versilia|O|O||D||1
10202221|Rosal vivo juliet ausjameson|O|O||D||1
10202222|Rosal vivo la parisienne|O|O||D||1
10202223|Rosal vivo la perla|O|O||D||1
10202224|Rosal vivo lovita sunblaze|O|O||D||1
10202225|Rosal vivo malilena o marilena|O|O||D||1
10202226|Rosal vivo monyna|O|O||D||1
10202227|Rosal vivo nectarine|O|O||D||1
10202228|Rosal vivo oriental curiosa|O|O||D||1
10202229|Rosal vivo osiana|O|O||D||1
10202230|Rosal vivo peach avalanche|O|O||D||1
10202231|Rosal vivo peach deja vu|O|O||D||1
10202232|Rosal vivo picanto|O|O||D||1
10202233|Rosal vivo prima donna|O|O||D||1
10202234|Rosal vivo sheril|O|O||D||1
10202235|Rosal vivo sirocco|O|O||D||1
10202236|Rosal vivo tamara|O|O||D||1
10202237|Rosal vivo taxo|O|O||D||1
10202238|Rosal vivo trust|O|O||D||1
10202239|Rosal vivo valencia|O|O||D||1
10202240|Rosal vivo vinci|O|O||D||1
10202241|Rosal vivo wanda|O|O||D||1
10202300|Rosales vivos rosados|O|O||D||1
10202301|Rosal vivo aerobic|O|O||D||1
10202302|Rosal vivo after party|O|O||D||1
10202303|Rosal vivo amsterdam|O|O||D||1
10202304|Rosal vivo aqua rose|O|O||D||1
10202305|Rosal vivo attache|O|O||D||1
10202306|Rosal vivo attitude|O|O||D||1
10202307|Rosal vivo ballet|O|O||D||1
10202308|Rosal vivo belami|O|O||D||1
10202309|Rosal vivo bella voo o belle vue|O|O||D||1
10202310|Rosal vivo bling bling|O|O||D||1
10202311|Rosal vivo blushing akito|O|O||D||1
10202312|Rosal vivo brooke|O|O||D||1
10202313|Rosal vivo bugatti|O|O||D||1
10202314|Rosal vivo cadillac|O|O||D||1
10202315|Rosal vivo carnaval|O|O||D||1
10202316|Rosal vivo cereza|O|O||D||1
10202317|Rosal vivo charming unique|O|O||D||1
10202318|Rosal vivo cherry o|O|O||D||1
10202319|Rosal vivo ciciolina|O|O||D||1
10202320|Rosal vivo classic cezanne|O|O||D||1
10202321|Rosal vivo clasic duett|O|O||D||1
10202322|Rosal vivo cosmiq|O|O||D||1
10202323|Rosal vivo dark engagement|O|O||D||1
10202324|Rosal vivo daytona|O|O||D||1
10202325|Rosal vivo dekora|O|O||D||1
10202326|Rosal vivo dolores|O|O||D||1
10202327|Rosal vivo eliza|O|O||D||1
10202328|Rosal vivo flash baccara|O|O||D||1
10202329|Rosal vivo full house|O|O||D||1
10202330|Rosal vivo funky|O|O||D||1
10202331|Rosal vivo giliane|O|O||D||1
10202332|Rosal vivo gran europe|O|O||D||1
10202333|Rosal vivo habari|O|O||D||1
10202334|Rosal vivo hanseat|O|O||D||1
10202335|Rosal vivo high and amazing|O|O||D||1
10202336|Rosal vivo high and bonita|O|O||D||1
10202337|Rosal vivo high and booming|O|O||D||1
10202338|Rosal vivo high and fantasy|O|O||D||1
10202339|Rosal vivo high and rich|O|O||D||1
10202340|Rosal vivo hot lady|O|O||D||1
10202341|Rosal vivo hot princess|O|O||D||1
10202342|Rosal vivo inspiration|O|O||D||1
10202343|Rosal vivo jeimy|O|O||D||1
10202344|Rosal vivo kachita|O|O||D||1
10202345|Rosal vivo karen|O|O||D||1
10202346|Rosal vivo kenji|O|O||D||1
10202347|Rosal vivo kiko|O|O||D||1
10202348|Rosal vivo laser|O|O||D||1
10202349|Rosal vivo latin duett|O|O||D||1
10202350|Rosal vivo latin fever|O|O||D||1
10202351|Rosal vivo lifestyle|O|O||D||1
10202352|Rosal vivo light orlando|O|O||D||1
10202353|Rosal vivo lovely dreams|O|O||D||1
10202354|Rosal vivo loyalty|O|O||D||1
10202355|Rosal vivo malibu|O|O||D||1
10202356|Rosal vivo mata-hari|O|O||D||1
10202357|Rosal vivo memphis|O|O||D||1
10202358|Rosal vivo mi amor|O|O||D||1
10202359|Rosal vivo miami|O|O||D||1
10202360|Rosal vivo michelle|O|O||D||1
10202361|Rosal vivo mikaela|O|O||D||1
10202362|Rosal vivo orchestra|O|O||D||1
10202363|Rosal vivo orlando|O|O||D||1
10202364|Rosal vivo osadia|O|O||D||1
10202365|Rosal vivo paeonia freelander|O|O||D||1
10202366|Rosal vivo paula|O|O||D||1
10202367|Rosal vivo pavarotti|O|O||D||1
10202368|Rosal vivo pink intuition|O|O||D||1
10202369|Rosal vivo poison|O|O||D||1
10202370|Rosal vivo princess|O|O||D||1
10202371|Rosal vivo queen mary|O|O||D||1
10202372|Rosal vivo raphaela|O|O||D||1
10202373|Rosal vivo raspberry ice|O|O||D||1
10202374|Rosal vivo ravel|O|O||D||1
10202375|Rosal vivo riviera|O|O||D||1
10202376|Rosal vivo sade|O|O||D||1
10202377|Rosal vivo sashimi|O|O||D||1
10202378|Rosal vivo shanya|O|O||D||1
10202379|Rosal vivo shocking versilia|O|O||D||1
10202380|Rosal vivo solitaire|O|O||D||1
10202381|Rosal vivo something different|O|O||D||1
10202382|Rosal vivo splendid renate|O|O||D||1
10202383|Rosal vivo star|O|O||D||1
10202384|Rosal vivo sweet candia|O|O||D||1
10202385|Rosal vivo sweet moments|O|O||D||1
10202386|Rosal vivo sweet unique|O|O||D||1
10202387|Rosal vivo taboo|O|O||D||1
10202388|Rosal vivo timona|O|O||D||1
10202389|Rosal vivo topaz|O|O||D||1
10202390|Rosal vivo vogue|O|O||D||1
10202391|Rosal vivo voila|O|O||D||1
10202392|Rosal vivo wild one|O|O||D||1
10202393|Rosal vivo yves piaget|O|O||D||1
10202400|Rosales vivos rojos o burgundy|O|O||D||1
10202401|Rosal vivo african dawn|O|O||D||1
10202402|Rosal vivo amada|O|O||D||1
10202403|Rosal vivo black baccara|O|O||D||1
10202404|Rosal vivo black beauty|O|O||D||1
10202405|Rosal vivo black finess o black magic|O|O||D||1
10202406|Rosal vivo black magic|O|O||D||1
10202407|Rosal vivo bohemian o pasarela|O|O||D||1
10202408|Rosal vivo breathless|O|O||D||1
10202409|Rosal vivo caballero|O|O||D||1
10202410|Rosal vivo carrera|O|O||D||1
10202411|Rosal vivo charlene|O|O||D||1
10202412|Rosal vivo charlotte|O|O||D||1
10202413|Rosal vivo cherry lady|O|O||D||1
10202414|Rosal vivo cherry love|O|O||D||1
10202415|Rosal vivo classy rose|O|O||D||1
10202416|Rosal vivo colorado velvet|O|O||D||1
10202417|Rosal vivo corazon|O|O||D||1
10202418|Rosal vivo corrida|O|O||D||1
10202419|Rosal vivo dynamite|O|O||D||1
10202420|Rosal vivo eurored|O|O||D||1
10202421|Rosal vivo fashion|O|O||D||1
10202422|Rosal vivo fire and ice|O|O||D||1
10202423|Rosal vivo first red|O|O||D||1
10202424|Rosal vivo forever young|O|O||D||1
10202425|Rosal vivo freedom|O|O||D||1
10202426|Rosal vivo freestyle|O|O||D||1
10202427|Rosal vivo friendship|O|O||D||1
10202428|Rosal vivo gospel|O|O||D||1
10202429|Rosal vivo graffity|O|O||D||1
10202430|Rosal vivo grand gala|O|O||D||1
10202431|Rosal vivo grand prix|O|O||D||1
10202432|Rosal vivo grand classe|O|O||D||1
10202433|Rosal vivo hearts|O|O||D||1
10202434|Rosal vivo heat|O|O||D||1
10202435|Rosal vivo hocus pocus|O|O||D||1
10202436|Rosal vivo lady in red|O|O||D||1
10202437|Rosal vivo latin lady|O|O||D||1
10202438|Rosal vivo legend|O|O||D||1
10202439|Rosal vivo lulu|O|O||D||1
10202440|Rosal vivo luna rossa|O|O||D||1
10202441|Rosal vivo luxor|O|O||D||1
10202442|Rosal vivo madame delbard o carola|O|O||D||1
10202443|Rosal vivo miss paris|O|O||D||1
10202444|Rosal vivo nicole|O|O||D||1
10202445|Rosal vivo night fever|O|O||D||1
10202446|Rosal vivo obsession|O|O||D||1
10202447|Rosal vivo opium|O|O||D||1
10202448|Rosal vivo paz|O|O||D||1
10202449|Rosal vivo preference|O|O||D||1
10202450|Rosal vivo red berlin|O|O||D||1
10202451|Rosal vivo red bull|O|O||D||1
10202452|Rosal vivo red calypso|O|O||D||1
10202453|Rosal vivo red diamond|O|O||D||1
10202454|Rosal vivo red fantasy|O|O||D||1
10202455|Rosal vivo red france|O|O||D||1
10202456|Rosal vivo red intuition|O|O||D||1
10202457|Rosal vivo red jewel|O|O||D||1
10202458|Rosal vivo red magic|O|O||D||1
10202459|Rosal vivo red one|O|O||D||1
10202460|Rosal vivo red paris|O|O||D||1
10202461|Rosal vivo red princess|O|O||D||1
10202462|Rosal vivo red sensation o colorad|O|O||D||1
10202463|Rosal vivo red unique|O|O||D||1
10202464|Rosal vivo rockefeller|O|O||D||1
10202465|Rosal vivo romeo|O|O||D||1
10202466|Rosal vivo rouge baiser|O|O||D||1
10202467|Rosal vivo roulette|O|O||D||1
10202468|Rosal vivo royal massai|O|O||D||1
10202469|Rosal vivo royal red|O|O||D||1
10202470|Rosal vivo samurai|O|O||D||1
10202471|Rosal vivo sexy red|O|O||D||1
10202472|Rosal vivo starfire|O|O||D||1
10202473|Rosal vivo tango|O|O||D||1
10202474|Rosal vivo tiger tail|O|O||D||1
10202475|Rosal vivo tinto|O|O||D||1
10202476|Rosal vivo top secret|O|O||D||1
10202477|Rosal vivo vital|O|O||D||1
10202478|Rosal vivo wisdom|O|O||D||1
10202479|Rosal vivo xantia|O|O||D||1
10202480|Rosal vivo xcite|O|O||D||1
10202500|Rosales vivos sweetheart|O|O||D||1|Rosales La Minuette
10202501|Rosal vivo burgundy sweetheart|O|O||D||1|Rosal vivo La Minuette burgundy
10202502|Rosal vivo cream sweetheart|O|O||D||1|Rosal vivo La Minuette cream
10202503|Rosal vivo hot pink sweetheart|O|O||D||1|Rosal vivo La Minuette hot pink
10202504|Rosal vivo lavender sweetheart|O|O||D||1|Rosal vivo La Minuette lavender
10202505|Rosal vivo light pink sweetheart|O|O||D||1|Rosal vivo La Minuette light pink
10202506|Rosal vivo orange sweetheart|O|O||D||1|Rosal vivo La Minuette orange
10202507|Rosal vivo peach sweetheart|O|O||D||1|Rosal vivo La Minuette peach
10202508|Rosal vivo red sweetheart|O|O||D||1|Rosal vivo La Minuette red
10202509|Rosal vivo white sweetheart|O|O||D||1|Rosal vivo La Minuette white
10202510|Rosal vivo yelllow sweetheart|O|O||D||1|Rosal vivo La Minuette yellow
10202600|Rosales vivos blancos|O|O||D||1
10202601|Rosal vivo absolut|O|O||D||1
10202602|Rosal vivo aida|O|O||D||1
10202603|Rosal vivo akito|O|O||D||1
10202604|Rosal vivo amelia|O|O||D||1
10202605|Rosal vivo anastasia|O|O||D||1
10202606|Rosal vivo andean crystal|O|O||D||1
10202607|Rosal vivo angel|O|O||D||1
10202608|Rosal vivo annemarie|O|O||D||1
10202609|Rosal vivo avalanche|O|O||D||1
10202610|Rosal vivo bianca|O|O||D||1
10202611|Rosal vivo blizzard|O|O||D||1
10202612|Rosal vivo bridal akito|O|O||D||1
10202613|Rosal vivo domenica|O|O||D||1
10202614|Rosal vivo escimo|O|O||D||1
10202615|Rosal vivo farfalla|O|O||D||1
10202616|Rosal vivo high and peace|O|O||D||1
10202617|Rosal vivo high and pure|O|O||D||1
10202618|Rosal vivo inocencia o innocenti|O|O||D||1
10202619|Rosal vivo ivory|O|O||D||1
10202620|Rosal vivo mondial|O|O||D||1
10202621|Rosal vivo mount everest|O|O||D||1
10202622|Rosal vivo nova zembla|O|O||D||1
10202623|Rosal vivo patience o auspator|O|O||D||1
10202624|Rosal vivo polar star|O|O||D||1
10202625|Rosal vivo polo|O|O||D||1
10202626|Rosal vivo proud|O|O||D||1
10202627|Rosal vivo snowy jewel|O|O||D||1
10202628|Rosal vivo tibet|O|O||D||1
10202629|Rosal vivo tineke|O|O||D||1
10202630|Rosal vivo vitality|O|O||D||1
10202631|Rosal vivo white cadillac|O|O||D||1
10202632|Rosal vivo white dove|O|O||D||1
10202700|Rosales vivos amarillos|O|O||D||1
10202701|Rosal vivo aalsmeer gold|O|O||D||1
10202702|Rosal vivo alina|O|O||D||1
10202703|Rosal vivo ambiance|O|O||D||1
10202704|Rosal vivo aquarel|O|O||D||1
10202705|Rosal vivo autumn|O|O||D||1
10202706|Rosal vivo brasil|O|O||D||1
10202707|Rosal vivo candle light|O|O||D||1
10202708|Rosal vivo cantata o cantate|O|O||D||1
10202709|Rosal vivo capriccio|O|O||D||1
10202710|Rosal vivo caribbean|O|O||D||1
10202711|Rosal vivo circus|O|O||D||1
10202712|Rosal vivo citran|O|O||D||1
10202713|Rosal vivo concorde|O|O||D||1
10202714|Rosal vivo conga|O|O||D||1
10202715|Rosal vivo deja vu|O|O||D||1
10202716|Rosal vivo desire|O|O||D||1
10202717|Rosal vivo donia sol|O|O||D||1
10202718|Rosal vivo dueto|O|O||D||1
10202719|Rosal vivo erin|O|O||D||1
10202720|Rosal vivo exotic curiosa|O|O||D||1
10202721|Rosal vivo feria|O|O||D||1
10202722|Rosal vivo fire bird|O|O||D||1
10202723|Rosal vivo florida|O|O||D||1
10202724|Rosal vivo friendly|O|O||D||1
10202725|Rosal vivo gallinda|O|O||D||1
10202726|Rosal vivo geisha|O|O||D||1
10202727|Rosal vivo gelbe|O|O||D||1
10202728|Rosal vivo gelosia o yellow flame|O|O||D||1
10202729|Rosal vivo gold rush|O|O||D||1
10202730|Rosal vivo gold star|O|O||D||1
10202731|Rosal vivo gold strike|O|O||D||1
10202732|Rosal vivo golda|O|O||D||1
10202733|Rosal vivo golden fashion|O|O||D||1
10202734|Rosal vivo golden gate|O|O||D||1
10202735|Rosal vivo gran dorado|O|O||D||1
10202736|Rosal vivo helio|O|O||D||1
10202737|Rosal vivo high and exotic|O|O||D||1
10202738|Rosal vivo high and yellow flame|O|O||D||1
10202739|Rosal vivo high and yellow magic|O|O||D||1
10202740|Rosal vivo high society|O|O||D||1
10202741|Rosal vivo hummer|O|O||D||1
10202742|Rosal vivo idole o elle|O|O||D||1
10202743|Rosal vivo inti|O|O||D||1
10202744|Rosal vivo jet set|O|O||D||1
10202745|Rosal vivo judy|O|O||D||1
10202746|Rosal vivo jupiter|O|O||D||1
10202747|Rosal vivo konfetti|O|O||D||1
10202748|Rosal vivo kyara o kira|O|O||D||1
10202749|Rosal vivo latin beauty|O|O||D||1
10202750|Rosal vivo latin spirit|O|O||D||1
10202751|Rosal vivo latina|O|O||D||1
10202752|Rosal vivo lina|O|O||D||1
10202753|Rosal vivo lindsey|O|O||D||1
10202754|Rosal vivo male|O|O||D||1
10202755|Rosal vivo marie clare|O|O||D||1
10202756|Rosal vivo marisa|O|O||D||1
10202757|Rosal vivo matchball|O|O||D||1
10202758|Rosal vivo melon|O|O||D||1
10202759|Rosal vivo mohana|O|O||D||1
10202760|Rosal vivo okie dokie|O|O||D||1
10202761|Rosal vivo pailine|O|O||D||1
10202762|Rosal vivo parrot|O|O||D||1
10202763|Rosal vivo rio d oro|O|O||D||1
10202764|Rosal vivo salami|O|O||D||1
10202765|Rosal vivo santa fe|O|O||D||1
10202766|Rosal vivo skyline|O|O||D||1
10202767|Rosal vivo sonrisa|O|O||D||1
10202768|Rosal vivo star ambiance|O|O||D||1
10202769|Rosal vivo starbust|O|O||D||1
10202770|Rosal vivo sun king|O|O||D||1
10202771|Rosal vivo sunmaster|O|O||D||1
10202772|Rosal vivo sunny milva|O|O||D||1
10202773|Rosal vivo sushi|O|O||D||1
10202774|Rosal vivo tabasco|O|O||D||1
10202775|Rosal vivo tara|O|O||D||1
10202776|Rosal vivo tresor 2000|O|O||D||1
10202777|Rosal vivo ooty|O|O||D||1
10202778|Rosal vivo yellow coral|O|O||D||1
10202779|Rosal vivo yellow finess|O|O||D||1
10202780|Rosal vivo yellow submarine|O|O||D||1
10202781|Rosal vivo yellow sunset|O|O||D||1
10202782|Rosal vivo yelllow timeless|O|O||D||1
10202800|Rosales vivos spray|O|O||D||1
10202801|Rosal vivo alegria spray|O|O||D||1
10202802|Rosal vivo andrea follies spray|O|O||D||1
10202803|Rosal vivo antara follies spray|O|O||D||1
10202804|Rosal vivo arrow follies spray|O|O||D||1
10202805|Rosal vivo babe spray|O|O||D||1
10202806|Rosal vivo bellina collection spray|O|O||D||1
10202807|Rosal vivo blue moon spray|O|O||D||1
10202808|Rosal vivo chablis spray|O|O||D||1
10202809|Rosal vivo cherry follies spray|O|O||D||1
10202810|Rosal vivo chess spray|O|O||D||1
10202811|Rosal vivo classic lydia spray|O|O||D||1
10202812|Rosal vivo cream gracia spray|O|O||D||1
10202813|Rosal vivo cream lydia spray|O|O||D||1
10202814|Rosal vivo cream sensation spray|O|O||D||1
10202815|Rosal vivo cremita spray|O|O||D||1
10202816|Rosal vivo diablo spray|O|O||D||1
10202817|Rosal vivo electra spray|O|O||D||1
10202818|Rosal vivo fire king spray|O|O||D||1
10202819|Rosal vivo fleur spray|O|O||D||1
10202820|Rosal vivo girlie follies spray|O|O||D||1
10202821|Rosal vivo giselle follies spray|O|O||D||1
10202822|Rosal vivo golden collection spray|O|O||D||1
10202823|Rosal vivo golden mimi spray|O|O||D||1
10202824|Rosal vivo gracia spray|O|O||D||1
10202825|Rosal vivo hot majolica spray|O|O||D||1
10202826|Rosal vivo hot pink follies spray|O|O||D||1
10202827|Rosal vivo ilse spray|O|O||D||1
10202828|Rosal vivo jelena spray|O|O||D||1
10202829|Rosal vivo laminuette spray|O|O||D||1
10202830|Rosal vivo lavender follies spray|O|O||D||1
10202831|Rosal vivo limoncello spray|O|O||D||1
10202832|Rosal vivo little silver spray|O|O||D||1
10202833|Rosal vivo lovely lydia spray|O|O||D||1
10202834|Rosal vivo lucy spray|O|O||D||1
10202835|Rosal vivo lydia spray|O|O||D||1
10202836|Rosal vivo macarena spray|O|O||D||1
10202837|Rosal vivo magic sensation spray|O|O||D||1
10202838|Rosal vivo majolica spray|O|O||D||1
10202839|Rosal vivo mambo number 5 spray|O|O||D||1
10202840|Rosal vivo mambo spray|O|O||D||1
10202841|Rosal vivo marlene spray|O|O||D||1
10202842|Rosal vivo mimi eden spray|O|O||D||1
10202843|Rosal vivo minou spray|O|O||D||1
10202844|Rosal vivo nikita spray|O|O||D||1
10202845|Rosal vivo novel collection spray|O|O||D||1
10202846|Rosal vivo orange success spray|O|O||D||1
10202847|Rosal vivo pepita spray|O|O||D||1
10202848|Rosal vivo pink flash spray|O|O||D||1
10202849|Rosal vivo pink sensation spray|O|O||D||1
10202850|Rosal vivo porcelina spray|O|O||D||1
10202851|Rosal vivo princess spray|O|O||D||1
10202852|Rosal vivo purple mikado spray|O|O||D||1
10202853|Rosal vivo red angel spray|O|O||D||1
10202854|Rosal vivo red collection spray|O|O||D||1
10202855|Rosal vivo red hero spray|O|O||D||1
10202856|Rosal vivo red mikado spray|O|O||D||1
10202857|Rosal vivo red vision spray|O|O||D||1
10202858|Rosal vivo ritmo spray|O|O||D||1
10202859|Rosal vivo romance mikado o eva spray|O|O||D||1
10202860|Rosal vivo romantica follies spray|O|O||D||1
10202861|Rosal vivo rubicon spray|O|O||D||1
10202862|Rosal vivo rumba spray|O|O||D||1
10202863|Rosal vivo salsa spray|O|O||D||1
10202864|Rosal vivo sangrita spray|O|O||D||1
10202865|Rosal vivo santa barbara spray|O|O||D||1
10202866|Rosal vivo sashaba spray|O|O||D||1
10202867|Rosal vivo scarlett spray|O|O||D||1
10202868|Rosal vivo seline spray|O|O||D||1
10202869|Rosal vivo sensation spray|O|O||D||1
10202870|Rosal vivo silver collection spray|O|O||D||1
10202871|Rosal vivo silver sensation spray|O|O||D||1
10202872|Rosal vivo snowdance spray|O|O||D||1
10202873|Rosal vivo snowflake spray|O|O||D||1
10202874|Rosal vivo suncity spray|O|O||D||1
10202875|Rosal vivo super nova spray|O|O||D||1
10202876|Rosal vivo sweet sensation spray|O|O||D||1
10202877|Rosal vivo taifun o typhoon spray|O|O||D||1
10202878|Rosal vivo tamango spray|O|O||D||1
10202879|Rosal vivo tanger follies spray|O|O||D||1
10202880|Rosal vivo tiara spray|O|O||D||1
10202881|Rosal vivo tiramisú spray|O|O||D||1
10202882|Rosal vivo twinkle bride spray|O|O||D||1
10202883|Rosal vivo viviane spray|O|O||D||1
10202884|Rosal vivo white majolica spray|O|O||D||1
10202885|Rosal vivo white mikado spray|O|O||D||1
10202886|Rosal vivo xentina spray|O|O||D||1
10202887|Rosal vivo yellow babe spray|O|O||D||1
10202888|Rosal vivo yellow follies spray|O|O||D||1
10211500|Anturios vivos|O|O||D||1|Lirios flamingo vivos
10211501|Anturio vivo chocolate|O|O||D||1|Lirio flamingo vivo chocolate
10211502|Anturio vivo rojo oscuro|O|O||D||1|Lirio flamingo vivo rojo oscuro
10211503|Anturio vivo verde|O|O||D||1|Lirio flamingo vivo verde
10211504|Anturio vivo rosado fuerte|O|O||D||1|Lirio flamingo vivo rosado fuerte
10211505|Anturio vivo mickey mouse|O|O||D||1|Lirio flamingo vivo mickey mouse
10211506|Anturio vivo obake verde y blanco|O|O||D||1|Lirio flamingo vivo obake verde y blanco
10211507|Anturio vivo obake rojo y verde|O|O||D||1|Lirio flamingo vivo obake rojo y verde
10211508|Anturio vivo anaranjado|O|O||D||1|Lirio flamingo vivo anaranjado
10211509|Anturio vivo durazno|O|O||D||1|Lirio flamingo vivo durazno
10211510|Anturio vivo picasso o pecoso|O|O||D||1|Lirio flamingo vivo picasso o pecoso
10211511|Anturio vivo rojo|O|O||D||1|Lirio flamingo vivo rojo
10211512|Anturio vivo salpicadura|O|O||D||1|Lirio flamingo vivo salpicadura
10211513|Anturio vivo fuego del trópico|O|O||D||1|Lirio flamingo vivo fuego del trópico
10211514|Anturio vivo tulipán verde|O|O||D||1|Lirio flamingo vivo tulipán verde
10211515|Anturio vivo tulipán rosado|O|O||D||1|Lirio flamingo vivo tulipán rosado
10211516|Anturio vivo tulipán púrpura|O|O||D||1|Lirio flamingo vivo tulipán púrpura
10211517|Anturio vivo tulipán rojo|O|O||D||1|Lirio flamingo vivo tulipán rojo
10211518|Anturio vivo blanco|O|O||D||1|Lirio flamingo vivo blanco
10211519|Anturio vivo cosa salvaje|O|O||D||1|Lirio flamingo vivo cosa salvaje
10211600|Allium vivo|O|O||D||1|Cebolletas ornamentales vivas
10211601|Allium vivo embajador|O|O||D||1|Cebolleta ornamental viva embajador
10211602|Allium vivo ampeloprasum|O|O||D||1|Cebolleta ornamental viva ampeloprasum
10211603|Allium vivo bullit o drumstick|O|O||D||1|Cebolleta ornamental viva bullit o drumstick
10211604|Allium vivo christophii|O|O||D||1|Cebolleta ornamental viva christophii
10211605|Allium vivo cowanii spray white|O|O||D||1|Cebolleta ornamental viva cowanii spray white
10211606|Allium vivo gigante|O|O||D||1|Cebolleta ornamental viva gigante
10211607|Allium vivo gladiador|O|O||D||1|Cebolleta ornamental viva gladiador
10211608|Allium vivo globemaster|O|O||D||1|Cebolleta ornamental viva globemaster
10211609|Allium vivo bola de golf blanca|O|O||D||1|Cebolleta ornamental viva bola de golf blanca
10211610|Allium vivo cabello|O|O||D||1|Cebolleta ornamental viva cabello
10211611|Allium vivo rosado gigante|O|O||D||1|Cebolleta ornamental viva rosado gigante
10211612|Allium vivo sensación púrpura|O|O||D||1|Cebolleta ornamental viva sensación púrpura
10211613|Allium vivo sicilum hanging|O|O||D||1|Cebolleta ornamental viva sicilum hanging
10211614|Allium vivo spider schubertii|O|O||D||1|Cebolleta ornamental viva spider schubertii
10211615|Allium vivo spray moly|O|O||D||1|Cebolleta ornamental viva spray moly
10211616|Allium vivo spray roseum|O|O||D||1|Cebolleta ornamental viva spray roseum
10211617|Allium vivo tuberosum|O|O||D||1|Cebolleta ornamental viva tuberosum
10211618|Allium vivo unifolium o spray allium|O|O||D||1|Cebolleta ornamental viva unifolium o spray Cebolleta ornamental
10211619|Allium vivo monte everest blanco|O|O||D||1|Cebolleta ornamental viva monte everest blanco
10211700|Astromelia viva|O|O||D||1|Lirios de campo vivos
10211701|Astromelia viva agropoli|O|O||D||1|Lirio de campo vivo agropoli
10211702|Astromelia viva bourgogne|O|O||D||1|Lirio de campo vivo bourgogne
10211703|Astromelia viva cairo|O|O||D||1|Lirio de campo vivo cairo
10211704|Astromelia viva charmes|O|O||D||1|Lirio de campo vivo charmes
10211705|Astromelia viva cherry bay|O|O||D||1|Lirio de campo vivo cherry bay
10211706|Astromelia viva cherry white|O|O||D||1|Lirio de campo vivo cherry white
10211707|Astromelia viva dame blanche|O|O||D||1|Lirio de campo vivo dame blanche
10211708|Astromelia viva diamond|O|O||D||1|Lirio de campo vivo diamond
10211709|Astromelia viva gran canaria|O|O||D||1|Lirio de campo vivo gran canaria
10211710|Astromelia viva harlekijn|O|O||D||1|Lirio de campo vivo harlekijn
10211711|Astromelia viva indian summer|O|O||D||1|Lirio de campo vivo indian summer
10211712|Astromelia viva jamaica|O|O||D||1|Lirio de campo vivo jamaica
10211713|Astromelia viva macondo|O|O||D||1|Lirio de campo vivo macondo
10211714|Astromelia viva mistique|O|O||D||1|Lirio de campo vivo mistique
10211715|Astromelia viva my fair|O|O||D||1|Lirio de campo vivo my fair
10211716|Astromelia viva new cairo|O|O||D||1|Lirio de campo vivo new cairo
10211717|Astromelia viva nice|O|O||D||1|Lirio de campo vivo nice
10211718|Astromelia viva orange bowl|O|O||D||1|Lirio de campo vivo orange bowl
10211719|Astromelia viva orange queens|O|O||D||1|Lirio de campo vivo orange queens
10211720|Astromelia viva orange sun|O|O||D||1|Lirio de campo vivo orange sun
10211721|Astromelia viva paris|O|O||D||1|Lirio de campo vivo parís
10211722|Astromelia viva picasso|O|O||D||1|Lirio de campo vivo picasso
10211723|Astromelia viva pink panther|O|O||D||1|Lirio de campo vivo pink panther
10211724|Astromelia viva prima donna|O|O||D||1|Lirio de campo vivo prima donna
10211725|Astromelia viva red silhouette|O|O||D||1|Lirio de campo vivo red silhouette
10211726|Astromelia viva sacha|O|O||D||1|Lirio de campo vivo sacha
10211727|Astromelia viva salmon|O|O||D||1|Lirio de campo vivo salmón
10211728|Astromelia viva santiago|O|O||D||1|Lirio de campo vivo santiago
10211729|Astromelia viva senna|O|O||D||1|Lirio de campo vivo senna
10211730|Astromelia viva snowball|O|O||D||1|Lirio de campo vivo snowball
10211731|Astromelia viva sublime|O|O||D||1|Lirio de campo vivo sublime
10211732|Astromelia viva tropicana|O|O||D||1|Lirio de campo vivo tropicana
10211733|Astromelia viva virginia|O|O||D||1|Lirio de campo vivo virginia
10211734|Astromelia viva white|O|O||D||1|Lirio de campo vivo white
10211800|Amaranto vivo|O|O||D||1
10211801|Amaranto vivo verde colgante|O|O||D||1
10211802|Amaranto vivo rojo colgante|O|O||D||1
10211803|Amaranto vivo bonce erguido|O|O||D||1
10211804|Amaranto vivo verde erguido|O|O||D||1
10211805|Amaranto vivo rojo erguido|O|O||D||1
10211900|Amaryllis vivo|O|O||D||1|Amaryllis viva
10211901|Amaryllis vivo naranja|O|O||D||1|Amaryllis viva naranja
10211902|Amaryllis vivo orange nagano|O|O||D||1|Amaryllis viva orange nagano
10211903|Amaryllis vivo pygmee mini|O|O||D||1|Amaryllis viva pygmee mini
10211904|Amaryllis vivo red lion|O|O||D||1|Amaryllis viva red lion
10211905|Amaryllis vivo rilona|O|O||D||1|Amaryllis viva rilona
10211906|Amaryllis vivo royal velvet|O|O||D||1|Amaryllis viva royal velvet
10211907|Amaryllis vivo sonatini orange|O|O||D||1|Amaryllis viva sonatini orange
10211908|Amaryllis vivo sonatini red|O|O||D||1|Amaryllis viva sonatini red
10211909|Amaryllis vivo tango|O|O||D||1|Amaryllis viva tango
10211910|Amaryllis vivo tinto night|O|O||D||1|Amaryllis viva tinto night
10212000|Anémona viva|O|O||D||1
10212001|Anémona viva aubergine|O|O||D||1
10212002|Anémona viva negra|O|O||D||1
10212003|Anémona viva azul|O|O||D||1
10212004|Anémona viva cereza|O|O||D||1
10212005|Anémona viva coronaria|O|O||D||1
10212006|Anémona viva rosada fuerte|O|O||D||1
10212007|Anémona viva rosada claro|O|O||D||1
10212008|Anémona viva rosada|O|O||D||1
10212009|Anémona viva púrpura|O|O||D||1
10212010|Anémona viva roja|O|O||D||1
10212011|Anémona viva blanca|O|O||D||1
10212100|Asclepia viva|O|O||D||1|Algodoncillos vivos
10212101|Asclepia viva lavanda|O|O||D||1|Algodoncillo vivo lavanda
10212102|Asclepia viva moby dick|O|O||D||1|Algodoncillo vivo moby dick
10212103|Asclepia viva tuberosa|O|O||D||1|Algodoncillo vivo tuberoso
10212104|Asclepia viva blanca|O|O||D||1|Algodoncillo vivo blanco
10212200|Aster viva|O|O||D||1|Estrellas vivas
10212201|Aster viva belleza|O|O||D||1|Estrella viva belleza
10212202|Aster viva azul japonés|O|O||D||1|Estrella viva azul japonés
10212203|Aster viva verde japonés|O|O||D||1|Estrella viva verde japonés
10212204|Aster viva rosado fuerte japonés|O|O||D||1|Estrella viva rosado fuerte japonés
10212205|Aster viva lavanda japonés|O|O||D||1|Estrella viva lavanda japonés
10212206|Aster viva rosado claro japonés|O|O||D||1|Estrella viva rosado claro japonés
10212207|Aster viva durazno japonés|O|O||D||1|Estrella viva durazno japonés
10212208|Aster viva rosado japonés|O|O||D||1|Estrella viva rosado japonés
10212209|Aster viva púrpura japonés|O|O||D||1|Estrella viva púrpura japonés
10212210|Aster viva rojo japonés|O|O||D||1|Estrella viva rojo japonés
10212211|Aster viva araña japonés|O|O||D||1|Estrella viva araña japonés
10212212|Aster viva blanca japonés|O|O||D||1|Estrella viva blanca japonés
10212213|Aster viva rosado fuerte novi belgii|O|O||D||1|Estrella viva rosado fuerte novi belgii
10212214|Aster viva lavanda novi belgii|O|O||D||1|Estrella viva lavanda novi belgii
10212215|Aster viva rosado novi belgii|O|O||D||1|Estrella viva rosado novi belgii
10212216|Aster viva púrpura novi belgii|O|O||D||1|Estrella viva púrpura novi belgii
10212217|Aster viva blanca novi belgii|O|O||D||1|Estrella viva blanca novi belgii
10212218|Aster viva solidago|O|O||D||1|Estrella viva solidago
10212219|Aster viva araña|O|O||D||1|Estrella viva araña
10212300|Berzelia viva|O|O||D||1
10212301|Berzelia lanuginosa viva abrotanoides|O|O||D||1
10212302|Berzelia lanuginosa viva fireball|O|O||D||1
10212303|Berzelia lanuginosa viva galpinii|O|O||D||1
10212304|Berzelia lanuginosa viva galpini o baubles|O|O||D||1
10212305|Berzelia lanuginosa viva squarrosa|O|O||D||1
10212400|Bouvaria viva|O|O||D||1|Trompetillas vivas
10212401|Bouvardia viva doble rosado fuerte|O|O||D||1|Trompetilla viva doble rosado fuerte
10212402|Bouvardia viva rosado claro|O|O||D||1|Trompetilla viva rosado claro
10212403|Bouvardia viva doble rosado claro|O|O||D||1|Trompetilla viva doble rosado claro
10212404|Bouvardia viva roja|O|O||D||1|Trompetilla viva roja
10212405|Bouvardia viva blanca|O|O||D||1|Trompetilla viva blanca
10212500|Brodiaea viva|O|O||D||1
10212501|Brodiaea viva congesta|O|O||D||1
10212502|Brodiaea viva congesta lavanda|O|O||D||1
10212503|Brodiaea viva hyacintha|O|O||D||1
10212504|Brodiaea viva ida maija|O|O||D||1
10212505|Brodiaea viva starlight|O|O||D||1
10212600|Calla viva|O|O||D||1|Alcatraces vivos
10212601|Calla viva green goddess|O|O||D||1|Alcatraz vivo green goddess
10212602|Calla viva ramillete albertville|O|O||D||1|Alcatraz vivo ramillete albertville
10212603|Calla viva ramillete aranal|O|O||D||1|Alcatraz vivo ramillete aranal
10212604|Calla viva ramillete black eyed beauty|O|O||D||1|Alcatraz vivo ramillete black eyed beauty
10212605|Calla viva ramillete black star|O|O||D||1|Alcatraz vivo ramillete black star
10212606|Calla viva ramillete brisbane|O|O||D||1|Alcatraz vivo ramillete brisbane
10212607|Calla viva ramillete crystal blush|O|O||D||1|Alcatraz vivo ramillete crystal blush
10212608|Calla viva ramillete crystal pink|O|O||D||1|Alcatraz vivo ramillete crystal pink
10212609|Calla viva ramillete crystal white|O|O||D||1|Alcatraz vivo ramillete crystal white
10212610|Calla viva ramillete dark captain romanc|O|O||D||1|Alcatraz vivo ramillete dark captain romance
10212611|Calla viva ramillete dark mozart|O|O||D||1|Alcatraz vivo ramillete dark mozart
10212612|Calla viva ramillete dark naomi|O|O||D||1|Alcatraz vivo ramillete dark naomi
10212613|Calla viva ramillete deformed calla|O|O||D||1|Alcatraz vivo ramillete deformed calla
10212614|Calla viva ramillete dordogne|O|O||D||1|Alcatraz vivo ramillete dordogne
10212615|Calla viva ramillete etude|O|O||D||1|Alcatraz vivo ramillete etude
10212616|Calla viva ramillete farao|O|O||D||1|Alcatraz vivo ramillete farao
10212617|Calla viva ramillete fire glow|O|O||D||1|Alcatraz vivo ramillete fire glow
10212618|Calla viva ramillete florex gold|O|O||D||1|Alcatraz vivo ramillete florex gold
10212619|Calla viva ramillete garnet glow|O|O||D||1|Alcatraz vivo ramillete garnet glow
10212620|Calla viva ramillete hot chocolate|O|O||D||1|Alcatraz vivo ramillete hot chocolate
10212621|Calla viva ramillete lavender improved|O|O||D||1|Alcatraz vivo ramillete lavender improved
10212622|Calla viva ramillete light cromance|O|O||D||1|Alcatraz vivo ramillete light cromance
10212623|Calla viva ramillete little suzy|O|O||D||1|Alcatraz vivo ramillete little suzy
10212624|Calla viva ramillete majestic red|O|O||D||1|Alcatraz vivo ramillete majestic red
10212625|Calla viva ramillete mango|O|O||D||1|Alcatraz vivo ramillete mango
10212626|Calla viva ramillete merlot|O|O||D||1|Alcatraz vivo ramillete merlot
10212627|Calla viva ramillete mozart|O|O||D||1|Alcatraz vivo ramillete mozart
10212628|Calla viva ramillete naomi|O|O||D||1|Alcatraz vivo ramillete naomi
10212629|Calla viva ramillete night cap|O|O||D||1|Alcatraz vivo ramillete night cap
10212630|Calla viva ramillete odessa|O|O||D||1|Alcatraz vivo ramillete odessa
10212631|Calla viva ramillete pacific pink|O|O||D||1|Alcatraz vivo ramillete pacific pink
10212632|Calla viva ramillete passion fruit|O|O||D||1|Alcatraz vivo ramillete passion fruit
10212633|Calla viva ramillete picasso|O|O||D||1|Alcatraz vivo ramillete picasso
10212634|Calla viva ramillete pillow talk|O|O||D||1|Alcatraz vivo ramillete pillow talk
10212635|Calla viva ramillete pink persuation|O|O||D||1|Alcatraz vivo ramillete pink persuation
10212636|Calla viva ramillete pisa|O|O||D||1|Alcatraz vivo ramillete pisa
10212637|Calla viva ramillete pot of|O|O||D||1|Alcatraz vivo ramillete pot of
10212638|Calla viva ramillete red sox|O|O||D||1|Alcatraz vivo ramillete red sox
10212639|Calla viva ramillete rosa|O|O||D||1|Alcatraz vivo ramillete rosa
10212640|Calla viva ramillete ruby light rose|O|O||D||1|Alcatraz vivo ramillete ruby light rose
10212641|Calla viva ramillete samur|O|O||D||1|Alcatraz vivo ramillete samur
10212642|Calla viva ramillete sapporo|O|O||D||1|Alcatraz vivo ramillete sapporo
10212643|Calla viva ramillete schwarzwalder|O|O||D||1|Alcatraz vivo ramillete schwarzwalder
10212644|Calla viva ramillete serrada|O|O||D||1|Alcatraz vivo ramillete serrada
10212645|Calla viva ramillete solemio|O|O||D||1|Alcatraz vivo ramillete solemio
10212646|Calla viva ramillete sunrise|O|O||D||1|Alcatraz vivo ramillete sunrise
10212647|Calla viva ramillete super mac|O|O||D||1|Alcatraz vivo ramillete super mac
10212648|Calla viva ramillete swan lake|O|O||D||1|Alcatraz vivo ramillete swan lake
10212649|Calla viva ramillete vermeer|O|O||D||1|Alcatraz vivo ramillete vermeer
10212650|Calla viva ramillete white butterfly|O|O||D||1|Alcatraz vivo ramillete white butterfly
10212651|Calla viva ramillete yellow|O|O||D||1|Alcatraz vivo ramillete yellow
10212652|Calla viva ramillete yellow mozart|O|O||D||1|Alcatraz vivo ramillete yellow mozart
10212653|Calla viva ramillete white large|O|O||D||1|Alcatraz vivo ramillete white large
10212800|Celosia viva|O|O||D||1|Flores de terciopelo vivas
10212801|Celosia viva cresta de gallo verde|O|O||D||1|Flor de terciopelo viva verde
10212802|Celosia viva cresta de gallo anaranjado|O|O||D||1|Flor de terciopelo viva anaranjado
10212803|Celosia viva cresta de gallo rosado|O|O||D||1|Flor de terciopelo viva rosado
10212804|Celosia viva cresta de gallo púrpura|O|O||D||1|Flor de terciopelo viva púrpura
10212805|Celosia viva cresta de gallo rojo|O|O||D||1|Flor de terciopelo viva rojo
10212806|Celosia viva cresta de gallo amarillo|O|O||D||1|Flor de terciopelo viva amarillo
10212807|Celosia viva pluma rosado claro|O|O||D||1|Flor de terciopelo viva plume light
10212808|Celosia viva pluma anaranjado|O|O||D||1|Flor de terciopelo viva plume orange
10212809|Celosia viva pluma púrpura|O|O||D||1|Flor de terciopelo viva plume purple
10212810|Celosia viva pluma rojo|O|O||D||1|Flor de terciopelo viva plume red
10212811|Celosia viva pluma amarillo|O|O||D||1|Flor de terciopelo viva plume yellow
10212812|Celosia viva trigo rosado|O|O||D||1|Flor de terciopelo viva wheat pink
10212813|Celosia viva trigo amarillo|O|O||D||1|Flor de terciopelo viva wheat yellow
10212900|Narciso vivo|O|O||D||1
10212901|Narciso vivo dick wilden|O|O||D||1
10212902|Narciso vivo dutch master|O|O||D||1
10212903|Narciso vivo ice follies|O|O||D||1
10212904|Narciso vivo ice king|O|O||D||1
10212905|Narciso vivo johan strauss|O|O||D||1
10212906|Narciso vivo yellow carlton|O|O||D||1
10213000|Dalia viva|O|O||D||1
10213001|Dalia viva bicolor|O|O||D||1
10213002|Dalia viva rosado fuerte|O|O||D||1
10213003|Dalia viva rosado claro|O|O||D||1
10213004|Dalia viva rosado medio|O|O||D||1
10213005|Dalia viva anaranjado|O|O||D||1
10213006|Dalia viva durazno|O|O||D||1
10213007|Dalia viva púrpura|O|O||D||1
10213008|Dalia viva roja|O|O||D||1
10213009|Dalia viva blanca|O|O||D||1
10213010|Dalia viva amarilla|O|O||D||1
10213100|Delphinium vivo|O|O||D||1
10213101|Delphinium vivo bella azul oscuro|O|O||D||1
10213102|Delphinium vivo bella azul claro|O|O||D||1
10213103|Delphinium vivo bella blanco|O|O||D||1
10213104|Delphinium vivo azul sombra|O|O||D||1
10213105|Delphinium vivo híbrido azul oscuro|O|O||D||1
10213106|Delphinium vivo híbrido azul claro|O|O||D||1
10213107|Delphinium vivo híbrido malva|O|O||D||1
10213108|Delphinium vivo híbrido rosado|O|O||D||1
10213109|Delphinium vivo híbrido púrpura|O|O||D||1
10213110|Delphinium vivo híbrido rojo|O|O||D||1
10213111|Delphinium vivo híbrido blanco|O|O||D||1
10213112|Delphinium vivo princesa carolina|O|O||D||1
10213113|Delphinium vivo volkerfrieden|O|O||D||1
10213200|Clavel (dianthus) vivo|O|O||D||1|Clavelinas vivas
10213201|Clavel (dianthus) vivo chocolate|O|O||D||1|Clavelina viva chocolate
10213202|Clavel (dianthus) vivo fucsia|O|O||D||1|Clavelina viva fucsia
10213203|Clavel (dianthus) vivo bola verde|O|O||D||1|Clavelina viva bola verde
10213204|Clavel (dianthus) vivo rosado fuerte|O|O||D||1|Clavelina viva rosado fuerte
10213205|Clavel (dianthus) vivo lavanda|O|O||D||1|Clavelina viva lavanda
10213206|Clavel (dianthus) vivo frambuesa|O|O||D||1|Clavelina viva frambuesa
10213207|Clavel (dianthus) vivo rojo|O|O||D||1|Clavelina viva rojo
10213208|Clavel (dianthus) vivo rosado|O|O||D||1|Clavelina viva rosado
10213300|Eremruses vivas|O|O||D||1
10213301|Eremurus vivo deruyter híbrido|O|O||D||1
10213302|Eremurus vivo himalaicus blanco|O|O||D||1
10213303|Eremurus vivo anaranjado|O|O||D||1
10213304|Eremurus vivo durazno|O|O||D||1
10213305|Eremurus vivo amarillo|O|O||D||1
10213400|Brezo (erica) viva|O|O||D||1|Brecinas vivas
10213401|Brezo (erica) vivo campunalarus|O|O||D||1|Brecina viva campunalarus
10213402|Brezo (erica) vivo conica|O|O||D||1|Brecina viva cónica
10213403|Brezo (erica) vivo green ice|O|O||D||1|Brecina viva green ice
10213404|Brezo (erica) vivo rosado|O|O||D||1|Brecina viva rosado
10213405|Brezo (erica) vivo príncipe de gales|O|O||D||1|Brecina viva príncipe de gales
10213500|Euphorbia viva|O|O||D||1|Coronas de Cristo vivas
10213501|Euphorbia viva characias|O|O||D||1|Corona de Cristo viva characias
10213502|Euphorbia viva griffithii fireglow|O|O||D||1|Corona de Cristo viva griffithii fireglow
10213503|Euphorbia viva martini|O|O||D||1|Corona de Cristo viva martini
10213504|Euphorbia viva anaranjada|O|O||D||1|Corona de Cristo viva anaranjada
10213505|Euphorbia viva durazno|O|O||D||1|Corona de Cristo viva durazno
10213506|Euphorbia viva rosada|O|O||D||1|Corona de Cristo viva rosada
10213507|Euphorbia viva roja|O|O||D||1|Corona de Cristo viva roja
10213508|Euphorbia viva blanca|O|O||D||1|Corona de Cristo viva blanca
10213509|Euphorbia viva amarilla|O|O||D||1|Corona de Cristo viva amarilla
10213510|Euphorbia viva amarilla spurge|O|O||D||1|Corona de Cristo viva amarilla spurge
10213600|Fresia viva|O|O||D||1|Freesias vivas
10213601|Fresia viva crema|O|O||D||1|Freesia viva crema
10213602|Fresia viva doble blanca|O|O||D||1|Freesia viva doble blanca
10213603|Fresia viva doble amarilla|O|O||D||1|Freesia viva doble amarilla
10213604|Fresia viva rosado fuerte|O|O||D||1|Freesia viva rosado fuerte
10213605|Fresia viva lady brunet|O|O||D||1|Freesia viva lady brunet
10213606|Fresia viva lavanda|O|O||D||1|Freesia viva lavanda
10213607|Fresia viva rosado medio|O|O||D||1|Freesia viva rosado medio
10213608|Fresia viva anaranjado|O|O||D||1|Freesia viva anaranjado
10213609|Fresia viva pimpinela|O|O||D||1|Freesia viva pimpinela
10213610|Fresia viva rosada|O|O||D||1|Freesia viva rosada
10213611|Fresia viva pùrpura|O|O||D||1|Freesia viva púrpura
10213612|Fresia viva roja|O|O||D||1|Freesia viva roja
10213613|Fresia viva blanca|O|O||D||1|Freesia viva blanca
10213614|Fresia viva amarilla|O|O||D||1|Freesia viva amarilla
10213700|Ajedrezada viva|O|O||D||1
10213701|Ajedrezada viva acmopelata|O|O||D||1
10213702|Ajedrezada viva assyriaca|O|O||D||1
10213703|Ajedrezada viva assyriaca uva vulpis|O|O||D||1
10213704|Ajedrezada viva elysee|O|O||D||1
10213705|Ajedrezada viva imperialis anaranjada|O|O||D||1
10213706|Ajedrezada viva imperialis amarilla|O|O||D||1
10213707|Ajedrezada viva meleagris|O|O||D||1
10213708|Ajedrezada viva michailowski|O|O||D||1
10213709|Ajedrezada viva uva vulpis|O|O||D||1
10213800|Hiniesta viva|O|O||D||1
10213801|Hiniesta viva verde|O|O||D||1
10213802|Hiniesta viva rosado fuerte|O|O||D||1
10213803|Hiniesta viva lavanda|O|O||D||1
10213804|Hiniesta viva rosado claro|O|O||D||1
10213805|Hiniesta viva durazno|O|O||D||1
10213806|Hiniesta viva púrpura|O|O||D||1
10213807|Hiniesta viva blanco|O|O||D||1
10213808|Hiniesta viva amarillo|O|O||D||1
10213900|Margarita viva|O|O||D||1|Gerberas vivas
10213901|Margarita viva crema de centro negro|O|O||D||1|Gerbera viva crema de centro negro
10213902|Margarita viva crema|O|O||D||1|Gerbera viva crema
10213903|Margarita viva dorada|O|O||D||1|Gerbera viva dorada
10213904|Margarita viva rosado fuerte|O|O||D||1|Gerbera viva rosado fuerte
10213905|Margarita viva rosado claro|O|O||D||1|Gerbera viva rosado claro
10213906|Margarita viva magenta|O|O||D||1|Gerbera viva magenta
10213907|Margarita viva mini coral|O|O||D||1|Gerbera viva mini coral
10213908|Margarita viva mini fucsia|O|O||D||1|Gerbera viva mini fucsia
10213909|Margarita viva mini rosado fuerte|O|O||D||1|Gerbera viva mini rosado fuerte
10213910|Margarita viva mini anaranjado claro de centro negro|O|O||D||1|Gerbera viva mini anaranjado claro de centro negro
10213911|Margarita viva mini anaranjado de centro negro|O|O||D||1|Gerbera viva mini anaranjado de centro negro
10213912|Margarita viva mini anaranjado|O|O||D||1|Gerbera viva mini anaranjado
10213913|Margarita viva mini rojo de centro negro|O|O||D||1|Gerbera viva mini rojo de centro negro
10213914|Margarita viva mini blanco|O|O||D||1|Gerbera viva mini blanco
10213915|Margarita viva mini amarillo claro de centro negro|O|O||D||1|Gerbera viva mini amarillo claro de centro negro
10213916|Margarita viva anaranjado de centro negro|O|O||D||1|Gerbera viva anaranjado de centro negro
10213917|Margarita viva anaranjada|O|O||D||1|Gerbera viva anaranjada
10213918|Margarita viva durazno de centro negro|O|O||D||1|Gerbera viva durazno de centro negro
10213919|Margarita viva durazno|O|O||D||1|Gerbera viva durazno
10213920|Margarita viva rosada de centro negro|O|O||D||1|Gerbera viva rosada de centro negro
10213921|Margarita viva rosada|O|O||D||1|Gerbera viva rosada
10213922|Margarita viva roja de centro negro|O|O||D||1|Gerbera viva roja de centro negro
10213923|Margarita viva roja|O|O||D||1|Gerbera viva roja
10213924|Margarita viva spider durazno|O|O||D||1|Gerbera viva spider durazno
10213925|Margarita viva spider roja|O|O||D||1|Gerbera viva spider roja
10213926|Margarita viva terracota|O|O||D||1|Gerbera viva terracota
10213927|Margarita viva blanca de centro negro|O|O||D||1|Gerbera viva blanca de centro negro
10213928|Margarita viva blanca|O|O||D||1|Gerbera viva blanca
10213929|Margarita viva amarilla|O|O||D||1|Gerbera viva amarilla
10214000|Jengibre vivo|O|O||D||1|Flores de jengibre vivas
10214001|Jengibre vivo  indonesio|O|O||D||1|Flor de jengibre viva indonesio
10214002|Jengibre vivo jungle king rosado|O|O||D||1|Flor de jengibre viva jungle king rosado
10214003|Jengibre vivo jungle king rojo|O|O||D||1|Flor de jengibre viva jungle king rojo
10214004|Jengibre vivo rosado|O|O||D||1|Flor de jengibre viva rosado
10214005|Jengibre vivo rojo|O|O||D||1|Flor de jengibre viva rojo
10214006|Jengibre vivo torch|O|O||D||1|Flor de jengibre viva torch
10214100|Gladiolo vivo|O|O||D||1|Gladiolas vivas
10214101|Gladiolo vivo vinotinto|O|O||D||1|Gladiola viva burgundy
10214102|Gladiolo vivo fucsia|O|O||D||1|Gladiola viva fucsia
10214103|Gladiolo vivo verde|O|O||D||1|Gladiola viva verde
10214104|Gladiolo vivo rosado fuerte|O|O||D||1|Gladiola viva rosado fuerte
10214105|Gladiolo vivo rosado claro|O|O||D||1|Gladiola viva rosado claro
10214106|Gladiolo vivo anaranjado|O|O||D||1|Gladiola viva anaranjado
10214107|Gladiolo vivo durazno|O|O||D||1|Gladiola viva durazno
10214108|Gladiolo vivo rosado medio|O|O||D||1|Gladiola viva rosado medio
10214109|Gladiolo vivo púrpura|O|O||D||1|Gladiola viva púrpura
10214110|Gladiolo vivo rojo bicolor|O|O||D||1|Gladiola viva rojo bicolor
10214111|Gladiolo vivo rojo|O|O||D||1|Gladiola viva rojo
10214112|Gladiolo vivo salmón|O|O||D||1|Gladiola viva salmón
10214113|Gladiolo vivo blanco|O|O||D||1|Gladiola viva blanco
10214114|Gladiolo vivo amarillo|O|O||D||1|Gladiola viva amarillo
10214200|Godetia viva|O|O||D||1
10214201|Godetia viva bicolor|O|O||D||1
10214202|Godetia viva fucsia|O|O||D||1
10214203|Godetia viva rosado fuerte|O|O||D||1
10214204|Godetia viva anaranjada|O|O||D||1
10214205|Godetia viva roja|O|O||D||1
10214206|Godetia viva blanca|O|O||D||1
10214300|Bromelia viva|O|O||D||1
10214301|Bromelia lingulata viva anaranjada|O|O||D||1
10214302|Bromelia lingulata viva roja|O|O||D||1
10214303|Bromelia lingulata viva blanca|O|O||D||1
10214304|Bromelia lingulata viva amarilla|O|O||D||1
10214305|Bromelia variegata viva|O|O||D||1
10214400|Gypsophilia viva|O|O||D||1|Nubes vivas
10214401|Gypsophilia viva bambino|O|O||D||1|Nube viva bambino
10214402|Gypsophilia viva million stars|O|O||D||1|Nube viva million stars
10214403|Gypsophilia viva mirabella|O|O||D||1|Nube viva mirabella
10214404|Gypsophilia viva new love|O|O||D||1|Nube viva new love
10214405|Gypsophilia viva orión|O|O||D||1|Nube viva orión
10214406|Gypsophilia viva perfecta|O|O||D||1|Nube viva perfecta
10214500|Brezo vivo|O|O||D||1|Biércol vivo
10214501|Brezo vivo augustine|O|O||D||1|Biércol vivo augustine
10214502|Brezo vivo érica cuatro hermanas|O|O||D||1|Biércol vivo érica cuatro hermanas
10214503|Brezo vivo francés|O|O||D||1|Biércol vivo francés
10214504|Brezo vivo verde|O|O||D||1|Biércol vivo verde
10214505|Brezo sterling range blanco vivo|O|O||D||1|Biércol vivo sterling range blanco
10214506|Brezo vivo rosado sunset|O|O||D||1|Biércol vivo rosado sunset
10214507|Brezo vivo blanco|O|O||D||1|Biércol vivo blanco
10214600|Heliconia viva|O|O||D||1|Pinzas de langosta vivas
10214601|Heliconia viva bihai claw|O|O||D||1|Pinza de langosta viva bihai claw
10214602|Heliconia viva bihai flash|O|O||D||1|Pinza de langosta viva bihai flash
10214603|Heliconia viva bihai lobster claw|O|O||D||1|Pinza de langosta viva bihai lobster claw
10214604|Heliconia viva caribea red|O|O||D||1|Pinza de langosta viva caribea red
10214605|Heliconia viva caribea yellow|O|O||D||1|Pinza de langosta viva caribea yellow
10214606|Heliconia viva christmas|O|O||D||1|Pinza de langosta viva christmas
10214607|Heliconia viva edge of night|O|O||D||1|Pinza de langosta viva edge of night
10214608|Heliconia viva green bihai|O|O||D||1|Pinza de langosta viva green bihai
10214609|Heliconia viva marginata lutea|O|O||D||1|Pinza de langosta viva marginata lútea
10214610|Heliconia viva psitt fire opal|O|O||D||1|Pinza de langosta viva psitt fire opal
10214611|Heliconia viva psittacorum|O|O||D||1|Pinza de langosta viva psittacorum
10214612|Heliconia viva richmond red|O|O||D||1|Pinza de langosta viva richmond red
10214613|Heliconia viva rostrata|O|O||D||1|Pinza de langosta viva rostrata
10214614|Heliconia viva sexy pink|O|O||D||1|Pinza de langosta viva sexy pink
10214615|Heliconia viva sexy scarlett|O|O||D||1|Pinza de langosta viva sexy scarlett
10214616|Heliconia viva shogun|O|O||D||1|Pinza de langosta viva shogun
10214617|Heliconia viva small red|O|O||D||1|Pinza de langosta viva small red
10214618|Heliconia viva southern cross|O|O||D||1|Pinza de langosta viva southern cross
10214619|Heliconia viva wagneriana|O|O||D||1|Pinza de langosta viva wagneriana
10214700|Jacinto vivo|O|O||D||1
10214701|Jacinto vivo bean|O|O||D||1
10214702|Jacinto vivo durazno|O|O||D||1
10214703|Jacinto vivo azul|O|O||D||1
10214704|Jacinto vivo fucsia|O|O||D||1
10214705|Jacinto vivo rosado fuerte|O|O||D||1
10214706|Jacinto vivo lavanda|O|O||D||1
10214707|Jacinto vivo azul claro|O|O||D||1
10214708|Jacinto vivo rosado medio|O|O||D||1
10214709|Jacinto vivo rosado|O|O||D||1
10214710|Jacinto vivo estrella púrpura|O|O||D||1
10214711|Jacinto vivo blanco|O|O||D||1
10214712|Jacinto vivo amarillo|O|O||D||1
10214800|Hydrangea viva|O|O||D||1|Hortensias vivas
10214801|Hydrangea viva anabella|O|O||D||1|Hortensia viva anabella
10214802|Hydrangea viva azul antiguo|O|O||D||1|Hortensia viva azul antiguo
10214803|Hydrangea viva azul antiguo  o verde o nueva zelandia|O|O||D||1|Hortensia viva azul antiguo o verde o nueva zelandia
10214804|Hydrangea viva verde antiguo|O|O||D||1|Hortensia viva verde antiguo
10214805|Hydrangea viva rosado antiguo|O|O||D||1|Hortensia viva rosado antiguo
10214806|Hydrangea viva púrpura antiguo o nueva zelandia|O|O||D||1|Hortensia viva púrpura antiguo o nueva zelandia
10214807|Hydrangea viva aubergene o nueva zelandia|O|O||D||1|Hortensia viva aubergene o nueva zelandia
10214808|Hydrangea viva azul oscuro|O|O||D||1|Hortensia viva azul oscuro
10214809|Hydrangea viva rosado oscuro|O|O||D||1|Hortensia viva rosado oscuro
10214810|Hydrangea viva púrpura oscuro|O|O||D||1|Hortensia viva púrpura oscuro
10214811|Hydrangea viva berenjena|O|O||D||1|Hortensia viva berenjena
10214812|Hydrangea viva verde teñida|O|O||D||1|Hortensia viva verde teñida
10214813|Hydrangea viva limón verde|O|O||D||1|Hortensia viva limón verde
10214814|Hydrangea viva rosado fuerte|O|O||D||1|Hortensia viva rosado fuerte
10214815|Hydrangea viva jumbo blanca|O|O||D||1|Hortensia viva jumbo blanca
10214816|Hydrangea viva lavanda o nueva zelandia|O|O||D||1|Hortensia viva lavanda o nueva zelandia
10214817|Hydrangea viva azul claro|O|O||D||1|Hortensia viva azul claro
10214818|Hydrangea viva rosado claro grande|O|O||D||1|Hortensia viva rosado claro grande
10214819|Hydrangea viva verde lima grande|O|O||D||1|Hortensia viva verde lima grande
10214820|Hydrangea viva mini verde|O|O||D||1|Hortensia viva mini verde
10214821|Hydrangea viva oakleaf|O|O||D||1|Hortensia viva oakleaf
10214822|Hydrangea viva oakleaf copo de nieve|O|O||D||1|Hortensia viva oakleaf copo de nieve
10214823|Hydrangea viva rosado teñido|O|O||D||1|Hortensia viva rosado teñido
10214824|Hydrangea viva rosado|O|O||D||1|Hortensia viva rosado
10214825|Hydrangea viva púrpura o nueva zelandia|O|O||D||1|Hortensia viva púrpura o nueva zelandia
10214826|Hydrangea viva rojo teñido|O|O||D||1|Hortensia viva rojo teñido
10214827|Hydrangea viva shocking blue|O|O||D||1|Hortensia viva shocking blue
10214828|Hydrangea viva tardiva|O|O||D||1|Hortensia viva tardiva
10214829|Hydrangea viva blanca|O|O||D||1|Hortensia viva blanca
10214900|Iris Viva|O|O||D||1
10214901|Iris viva negra barbada|O|O||D||1
10214902|Iris viva azul barbada|O|O||D||1
10214903|Iris viva lavanda barbada|O|O||D||1
10214904|Iris viva barbada azul clara|O|O||D||1
10214905|Iris viva barbada púrpura|O|O||D||1
10214906|Iris viva barbada roja|O|O||D||1
10214907|Iris viva barbada blanca|O|O||D||1
10214908|Iris viva baerbada blanca y púrpura|O|O||D||1
10214909|Iris viva amarilla barbada|O|O||D||1
10214910|Iris viva blue elegance|O|O||D||1
10214911|Iris viva casablanca|O|O||D||1
10214912|Iris viva golden beau|O|O||D||1
10214913|Iris viva hildegard|O|O||D||1
10214914|Iris viva hong kong|O|O||D||1
10214915|Iris viva ideal|O|O||D||1
10214916|Iris viva professor blue|O|O||D||1
10214917|Iris viva purple|O|O||D||1
10214918|Iris viva spuria|O|O||D||1
10214919|Iris viva telstar|O|O||D||1
10215000|Pata de canguro viva|O|O||D||1
10215001|Pata de canguro viva bicolor|O|O||D||1
10215002|Pata de canguro viva negra|O|O||D||1
10215003|Pata de canguro viva verde|O|O||D||1
10215004|Pata de canguro viva anaranjada|O|O||D||1
10215005|Pata de canguro viva rosada|O|O||D||1
10215006|Pata de canguro viva roja|O|O||D||1
10215007|Pata de canguro viva amarilla|O|O||D||1
10215100|Delfinio vivo|O|O||D||1|Delphinium (larkspurs) vivos
10215101|Delfinio viva azul nube|O|O||D||1|Delphinium (larkspurs) vivo azul nube
10215102|Delfinio viva rosado fuerte|O|O||D||1|Delphinium (larkspurs) vivo rosado fuerte
10215103|Delfinio viva lavanda|O|O||D||1|Delphinium (larkspurs) vivo lavanda
10215104|Delfinio viva rosado claro|O|O||D||1|Delphinium (larkspurs) vivo rosado claro
10215105|Delfinio viva púrpura|O|O||D||1|Delphinium (larkspurs) vivo púrpura
10215106|Delfinio viva blanca|O|O||D||1|Delphinium (larkspurs) vivo blanca
10215200|Lepto vivo|O|O||D||1
10215201|Lepto vivo azul o floreciente|O|O||D||1
10215202|Lepto vivo rosado fuerte|O|O||D||1
10215203|Lepto vivo rosado claro|O|O||D||1
10215204|Lepto vivo rosado|O|O||D||1
10215205|Lepto vivo rojo|O|O||D||1
10215206|Lepto vivo blanco|O|O||D||1
10215300|Lila viva|O|O||D||1
10215301|Lila  viva híbrida francesa lavanda|O|O||D||1
10215302|Lila  viva híbrida francesa púrpura|O|O||D||1
10215303|Lila  viva púrpura|O|O||D||1
10215304|Lila  viva vino|O|O||D||1
10215305|Lila  viva blanca|O|O||D||1
10215306|Lila  viva blanca salvaje|O|O||D||1
10215400|Azucena viva|O|O||D||1|Lili viva
10215401|Azucena viva alteza longiflorum e híbrido asiática|O|O||D||1|Lili viva alteza longiflorum e híbrido asiática
10215402|Azucena viva black out|O|O||D||1|Lili viva black out
10215403|Azucena viva rosado oscuro|O|O||D||1|Lili viva rosado oscuro
10215404|Azucena viva leéctrica asiática|O|O||D||1|Lili viva eléctrica asiática
10215405|Azucena viva festival asiática|O|O||D||1|Lili viva festival asiática
10215406|Azucena viva ginebra asiática|O|O||D||1|Lili viva ginebra asiática
10215407|Azucena viva rosado claro asiática|O|O||D||1|Lili viva rosado claro asiática
10215408|Azucena viva colombina asiática|O|O||D||1|Lili viva colombina asiática
10215409|Azucena viva miss américa púrpura asiática|O|O||D||1|Lili viva miss américa púrpura asiática
10215410|Azucena viva monte negro asiática|O|O||D||1|Lili viva monte negro asiática
10215411|Azucena viva anaranjada asiática|O|O||D||1|Lili viva anaranjada asiática
10215412|Azucena viva durazno cannes asiática|O|O||D||1|Lili viva durazno cannes asiática
10215413|Azucena viva rosada asiática|O|O||D||1|Lili viva rosada asiática
10215414|Azucena viva sancerre asiátia|O|O||D||1|Lili viva sancerre asiática
10215415|Azucena viva white dream asiática|O|O||D||1|Lili viva white dream asiática
10215416|Azucena viva amarilla asiática|O|O||D||1|Lili viva amarilla asiática
10215417|Azucena viva diamante brillante longiflorum e híbrido asiática|O|O||D||1|Lili viva diamante brillante longiflorum e híbrido asiática
10215418|Azucena viva brindisi longiflorum e híbrido asiática|O|O||D||1|Lili viva brindisi longiflorum e híbrido asiática
10215419|Azucena viva carmine longiflorum e híbrido asiática|O|O||D||1|Lili viva carmine longiflorum e híbrido asiática
10215420|Azucena viva cinnabar longiflorum e híbrido asiática|O|O||D||1|Lili viva cinnabar longiflorum e híbrido asiática
10215421|Azucena viva club longiflorum e híbrido asiática|O|O||D||1|Lili viva club longiflorum e híbrido asiática
10215422|Azucena viva discovery longiflorum e híbrido asiática|O|O||D||1|Lili viva discovery longiflorum e híbrido asiática
10215423|Azucena viva de pascua|O|O||D||1|Lili viva de pascua
10215424|Azucena viva isis longiflorum e híbrido asiática|O|O||D||1|Lili viva isis longiflorum e híbrido asiática
10215425|Azucena viva la hybrid justice longiflorum e híbrido asiática|O|O||D||1|Lili viva la hybrid justice longiflorum e híbrido asiática
10215426|Azucena viva lace longiflorum e híbrido asiática|O|O||D||1|Lili viva lace longiflorum e híbrido asiática
10215427|Azucena viva lirio de los valles|O|O||D||1|Lili viva lirio de los valles
10215428|Azucena viva love longiflorum e híbrido asiática|O|O||D||1|Lili viva love longiflorum e híbrido asiática
10215429|Azucena viva menorca longiflorum e híbrido asiática|O|O||D||1|Lili viva menorca longiflorum e híbrido asiática
10215430|Azucena viva oriental acapulco|O|O||D||1|Lili viva oriental acapulco
10215431|Azucena viva oriental albion|O|O||D||1|Lili viva oriental albión
10215432|Azucena viva oriental argentina|O|O||D||1|Lili viva oriental argentina
10215433|Azucena viva oriental auratum|O|O||D||1|Lili viva oriental auratum
10215434|Azucena viva oriental barbaresco|O|O||D||1|Lili viva oriental barbaresco
10215435|Azucena viva oriental bernini|O|O||D||1|Lili viva oriental bernini
10215436|Azucena viva oriental beseno|O|O||D||1|Lili viva oriental beseno
10215437|Azucena viva oriental broadway|O|O||D||1|Lili viva oriental broadway
10215438|Azucena viva oriental canada|O|O||D||1|Lili viva oriental canadá
10215439|Azucena viva oriental casablanca|O|O||D||1|Lili viva oriental casablanca
10215440|Azucena viva oriental chili|O|O||D||1|Lili viva oriental chili
10215441|Azucena viva oriental chrystal|O|O||D||1|Lili viva oriental chrystal
10215442|Azucena viva oriental cobra|O|O||D||1|Lili viva oriental cobra
10215443|Azucena viva oriental conca d’ or|O|O||D||1|Lili viva oriental conca d' ivor
10215444|Azucena viva oriental cote d’ ivor|O|O||D||1|Lili viva oriental cote d' ivor
10215445|Azucena viva oriental dizzy|O|O||D||1|Lili viva oriental dizzy
10215446|Azucena viva oriental fireball|O|O||D||1|Lili viva oriental fireball
10215447|Azucena viva oriental gluhwein|O|O||D||1|Lili viva oriental gluhwein
10215448|Azucena viva oriental goldband|O|O||D||1|Lili viva oriental goldband
10215449|Azucena viva oriental halifax|O|O||D||1|Lili viva oriental halifax
10215450|Azucena viva oriental kathryn|O|O||D||1|Lili viva oriental kathryn
10215451|Azucena viva oriental kyoto|O|O||D||1|Lili viva oriental kyoto
10215452|Azucena viva oriental la mancha|O|O||D||1|Lili viva oriental la mancha
10215453|Azucena viva oriental medusa|O|O||D||1|Lili viva oriental medusa
10215454|Azucena viva oriental montezuma|O|O||D||1|Lili viva oriental montezuma
10215455|Azucena viva oriental muscadet|O|O||D||1|Lili viva oriental muscadet
10215456|Azucena viva oriental nippon|O|O||D||1|Lili viva oriental nippon
10215457|Azucena viva oriental opus one|O|O||D||1|Lili viva oriental opus one
10215458|Azucena viva oriental pompeii|O|O||D||1|Lili viva oriental pompeii
10215459|Azucena viva oriental rialto|O|O||D||1|Lili viva oriental rialto
10215460|Azucena viva oriental robina|O|O||D||1|Lili viva oriental robina
10215461|Azucena viva oriental rousilon|O|O||D||1|Lili viva oriental rousilon
10215462|Azucena viva oriental siberia|O|O||D||1|Lili viva oriental siberia
10215463|Azucena viva oriental sorbonne|O|O||D||1|Lili viva oriental sorbonne
10215464|Azucena viva oriental starfighter|O|O||D||1|Lili viva oriental starfighter
10215465|Azucena viva oriental stargazer|O|O||D||1|Lili viva oriental stargazer
10215466|Azucena viva oriental sumatra|O|O||D||1|Lili viva oriental sumatra
10215467|Azucena viva oriental time out|O|O||D||1|Lili viva oriental time out
10215468|Azucena viva oriental tom pouche|O|O||D||1|Lili viva oriental tom pouche
10215469|Azucena viva oriental tropical|O|O||D||1|Lili viva oriental tropical
10215470|Azucena viva oriental white cup|O|O||D||1|Lili viva oriental white cup
10215471|Azucena viva oriental white merostar|O|O||D||1|Lili viva oriental white merostar
10215472|Azucena viva oriental white montana|O|O||D||1|Lili viva oriental white montana
10215473|Azucena viva oriental white stargazer|O|O||D||1|Lili viva oriental white stargazer
10215474|Azucena viva oriental yellow band|O|O||D||1|Lili viva oriental yellow band
10215475|Azucena viva oriental yellow dream|O|O||D||1|Lili viva oriental yellow dream
10215476|Azucena viva oriental yellow queen|O|O||D||1|Lili viva oriental yellow queen
10215477|Azucena viva oriental yellow star|O|O||D||1|Lili viva oriental yellow star
10215478|Azucena viva oriental yeloween|O|O||D||1|Lili viva oriental yelloween
10215479|Azucena viva ot red dutch|O|O||D||1|Lili viva ot red dutch
10215480|Azucena viva sonata nimph|O|O||D||1|Lili viva sonata nimph
10215481|Azucena viva sonata shocking|O|O||D||1|Lili viva sonata shocking
10215482|Azucena viva sonata triumphateer|O|O||D||1|Lili viva sonata triumphateer
10215483|Azucena viva sunset longiflorum e híbrido asiática|O|O||D||1|Lili viva sunset longiflorum e híbrido asiática
10215484|Azucena viva de agua|O|O||D||1|Lili viva de agua
10215500|Lavanda viva|O|O||D||1
10215501|Lavanda marina viva misty peach|O|O||D||1
10215502|Lavanda marina viva misty rosada|O|O||D||1
10215503|Lavanda marina viva misty blanca|O|O||D||1
10215504|Lavanda marina viva misty amarilla|O|O||D||1
10215505|Lavanda marina viva safora|O|O||D||1
10215506|Lavanda marina viva sinensis|O|O||D||1
10215600|Lisianthus vivo|O|O||D||1|Eustomas vivas
10215601|Lisianthus vivo crema|O|O||D||1|Eustoma viva crema
10215602|Lisianthus vivo rosado fuerte|O|O||D||1|Eustoma viva rosado fuerte
10215603|Lisianthus vivo verde|O|O||D||1|Eustoma viva verde
10215604|Lisianthus vivo lavanda|O|O||D||1|Eustoma viva lavanda
10215605|Lisianthus vivo rosado claro|O|O||D||1|Eustoma viva rosado claro
10215606|Lisianthus vivo mini blanco|O|O||D||1|Eustoma viva mini blanco
10215607|Lisianthus vivo durazno|O|O||D||1|Eustoma viva durazno
10215608|Lisianthus vivo rosado con borde blanco|O|O||D||1|Eustoma viva rosado con borde blanco
10215609|Lisianthus vivo púrpura|O|O||D||1|Eustoma viva púrpura
10215610|Lisianthus vivo púrpura con borde blanco|O|O||D||1|Eustoma viva púrpura con borde blanco
10215611|Lisianthus vivo blanco con borde rosado|O|O||D||1|Eustoma viva blanco con borde rosado
10215612|Lisianthus vivo blanco|O|O||D||1|Eustoma viva blanco
10215613|Lisianthus vivo blanco con borde púrpura|O|O||D||1|Eustoma viva blanco con borde púrpura
10215700|Muscari viva|O|O||D||1
10215701|Muscari viva armeniacum|O|O||D||1
10215702|Muscari viva bortyoides blanca|O|O||D||1
10215703|Muscari viva verde|O|O||D||1
10215704|Muscari viva latifolia|O|O||D||1
10215705|Muscari viva valerie finn|O|O||D||1
10215800|Narciso vivo|O|O||D||1
10215801|Narciso vivo alegría|O|O||D||1
10215802|Narciso vivo amanecer dorado|O|O||D||1
10215803|Narciso vivo abba paperwhite|O|O||D||1
10215804|Narciso vivo paperwhite|O|O||D||1
10215805|Narciso vivo ojo de faisán|O|O||D||1
10215806|Narciso vivo soleil d’ or|O|O||D||1
10215807|Narciso vivo tete a tete|O|O||D||1
10215808|Narciso vivo thalia|O|O||D||1
10216000|Pimientos ornamentales vivos|O|O||D||1|Paprikas ornamentales vivas
10216001|Pimiento chile vivo ornamental|O|O||D||1|Paprika ornamental viva
10216002|Pimiento mezclado vivo ornamental|O|O||D||1|Paprika ornamental mezclada viva
10216003|Pimiento anaranjado vivo ornamental|O|O||D||1|Paprika ornamental anaranjada viva
10216004|Pimiento rojo vivo ornamental|O|O||D||1|Paprika ornamental roja viva
10216005|Pimiento amarillo vivo ornamental|O|O||D||1|Paprika ornamental amarilla viva
10216100|Estrella de Belén viva|O|O||D||1
10216101|Estrella de belén viva arábica|O|O||D||1
10216102|Estrella de belén viva dubium anaranjada|O|O||D||1
10216103|Estrella de belén viva umbellada|O|O||D||1
10216104|Estrella de belén viva dubium blanca|O|O||D||1
10216105|Estrella de belén viva dubium amarilla|O|O||D||1
10216200|Peonia viva|O|O||D||1
10216201|Peonia viva alexander fleming|O|O||D||1
10216202|Peonia viva coral charm|O|O||D||1
10216203|Peonia viva suset|O|O||D||1
10216204|Peonia viva coral supreme|O|O||D||1
10216205|Peonia viva gardenia doble|O|O||D||1
10216206|Peonia viva doble jues eli oscura|O|O||D||1
10216207|Peonia viva soble duquesa blanca|O|O||D||1
10216208|Peonia viva felix crousse|O|O||D||1
10216209|Peonia viva festiva máxima|O|O||D||1
10216210|Peonia viva tesoro del jardín|O|O||D||1
10216211|Peonia viva kansas rosado oscuro|O|O||D||1
10216212|Peonia viva karl rosenfelt|O|O||D||1
10216213|Peonia viva paula fay|O|O||D||1
10216214|Peonia viva encanto rojo|O|O||D||1
10216215|Peonia viva pasion roja|O|O||D||1
10216216|Peonia viva sarah bernhardt roja|O|O||D||1
10216217|Peonia viva scarlet o’ hara|O|O||D||1
10216218|Peonia viva shirley temple|O|O||D||1
10216300|Banksia viva|O|O||D||1|Flores vivas de árbol madreselva australiano
10216301|Banksia viva ashbyi|O|O||D||1|Flor de árbol madreselva australiano viva ashbyi
10216302|Banksia viva baxteri|O|O||D||1|Flor de árbol madreselva australiano viva baxteri
10216306|Banksia viva coccinea|O|O||D||1|Flor de árbol madreselva australiano viva coccínea
10216311|Banksia viva ericifolia|O|O||D||1|Flor de árbol madreselva australiano viva ericifolia
10216315|Banksia viva verde|O|O||D||1|Flor de árbol madreselva australiano viva verde
10216322|Banksia viva menziesii|O|O||D||1|Flor de árbol madreselva australiano viva menziesii
10216325|Banksia viva blanco natural|O|O||D||1|Flor de árbol madreselva australiano viva blanco natural
10216326|Banksia viva anaranjado|O|O||D||1|Flor de árbol madreselva australiano viva anaranjado
10216332|Banksia viva rosada|O|O||D||1|Flor de árbol madreselva australiano viva rosada
10216400|Ranúculo vivo|O|O||D||1
10216401|Ranúnculo vivo chocolate|O|O||D||1
10216402|Ranúnculo vivo elegancia|O|O||D||1
10216403|Ranúnculo vivo verde|O|O||D||1
10216404|Ranúnculo vivo grimaldi|O|O||D||1
10216405|Ranúnculo vivo rosado fuerte|O|O||D||1
10216406|Ranúnculo vivo rosado claro|O|O||D||1
10216407|Ranúnculo vivo anaranjado|O|O||D||1
10216408|Ranúnculo vivo centro verde|O|O||D||1
10216409|Ranúnculo vivo rosado|O|O||D||1
10216410|Ranúnculo vivo rojo|O|O||D||1
10216411|Ranúnculo vivo blanco|O|O||D||1
10216412|Ranúnculo vivo amarillo|O|O||D||1
10216413|Ranúnculo vivo salmón|O|O||D||1
10216500|Escabiosa viva|O|O||D||1|Flores del acerico vivas
10216501|Escabiosa viva anual|O|O||D||1|Flor del acerico viva anual
10216502|Escabiosa viva negra|O|O||D||1|Flor del acerico viva negra
10216503|Escabiosa viva caucásica azul|O|O||D||1|Flor del acerico viva caucásica azul
10216504|Escabiosa viva caucásica rosada|O|O||D||1|Flor del acerico viva caucásica rosada
10216505|Escabiosa viva caucásica vainas|O|O||D||1|Flor del acerico viva caucásica vainas
10216506|Escabiosa viva caucásica blanca|O|O||D||1|Flor del acerico viva caucásica blanca
10216507|Escabiosa viva fresa|O|O||D||1|Flor del acerico viva fresa
10216600|Retama de escobas viva|O|O||D||1
10216601|Retama de escobas viva rosada|O|O||D||1
10216602|Retama de escobas viva púrpura|O|O||D||1
10216603|Retama de escobas viva blanca|O|O||D||1
10216604|Retama de escobas viva amarilla|O|O||D||1
10216700|Boca de dragón viva|O|O||D||1
10216701|Boca de dragón viva bicolor|O|O||D||1
10216702|Boca de dragón viva burgundy|O|O||D||1
10216703|Boca de dragón viva rosado fuerte|O|O||D||1
10216704|Boca de dragón viva lavanda|O|O||D||1
10216705|Boca de dragón viva anaranjado claro|O|O||D||1
10216706|Boca de dragón viva rosado claro|O|O||D||1
10216707|Boca de dragón viva anaranjado|O|O||D||1
10216708|Boca de dragón viva blanco|O|O||D||1
10216709|Boca de dragón viva amarillo|O|O||D||1
10216800|Romero del pantano viva|O|O||D||1|Siemprevivas azules vivas
10216801|Romero del pantano viva azul|O|O||D||1|Siempreviva azul viva color azul
10216802|Romero del pantano viva lavanda|O|O||D||1|Siempreviva azul viva lavanda
10216803|Romero del pantano viva durazno|O|O||D||1|Siempreviva azul viva durazno
10216804|Romero del pantano viva rosada|O|O||D||1|Siempreviva azul viva rosada
10216805|Romero del pantano viva púrpura|O|O||D||1|Siempreviva azul viva púrpura
10216806|Romero del pantano viva espuma de mar|O|O||D||1|Siempreviva azul viva espuma de mar
10216807|Romero del pantano viva blanca|O|O||D||1|Siempreviva azul viva blanca
10216808|Romero del pantano viva amarilla|O|O||D||1|Siempreviva azul viva amarilla
10216900|Matiola viva|O|O||D||1|Alhelís vivas
10216901|Matiola viva apricot|O|O||D||1|Alhelí viva apricot
10216902|Matiola viva crema|O|O||D||1|Alhelí viva crema
10216903|Matiola viva fucsia|O|O||D||1|Alhelí viva fucsia
10216904|Matiola viva lavanda|O|O||D||1|Alhelí viva lavanda
10216905|Matiola viva lavanda claro|O|O||D||1|Alhelí viva lavanda claro
10216906|Matiola viva rosada|O|O||D||1|Alhelí viva rosada
10216907|Matiola viva púrpura|O|O||D||1|Alhelí viva púrpura
10216908|Matiola viva rojo rubí|O|O||D||1|Alhelí viva rojo rubí
10216909|Matiola viva enamorada rosda|O|O||D||1|Alhelí viva enamorada rosada
10216910|Matiola viva blanca|O|O||D||1|Alhelí viva blanca
10217000|Girasol viva|O|O||D||1
10217001|Girasol viva tinte festivo|O|O||D||1
10217002|Girasol viva mahogany|O|O||D||1
10217003|Girasol viva rayo de sol|O|O||D||1
10217004|Girasol viva brillo del sol|O|O||D||1
10217005|Girasol viva salpicada de sol|O|O||D||1
10217006|Girasol viva oso de peluche|O|O||D||1
10217100|Guisante de olor vivo|O|O||D||1
10217101|Guisante de olor vivo verde teñido|O|O||D||1
10217102|Guisante de olor vivo rosado fuerte|O|O||D||1
10217103|Guisante de olor vivo lavanda|O|O||D||1
10217104|Guisante de olor vivo rosado claro|O|O||D||1
10217105|Guisante de olor vivo anaranjado|O|O||D||1
10217106|Guisante de olor vivo durazno teñido|O|O||D||1
10217107|Guisante de olor vivo púrpura|O|O||D||1
10217108|Guisante de olor vivo blanco|O|O||D||1
10217200|Cardo vivo|O|O||D||1
10217201|Cardo vivo alpinum|O|O||D||1
10217202|Cardo vivo echinops|O|O||D||1
10217203|Cardo vivo eryngium árabe|O|O||D||1
10217204|Cardo vivo eryngium azul|O|O||D||1
10217205|Cardo vivo eryngium orión|O|O||D||1
10217206|Cardo vivo eryngium frambuesa|O|O||D||1
10217207|Cardo vivo eryngium supernova|O|O||D||1
10217208|Cardo vivo eryngium campanita|O|O||D||1
10217300|Tulipán vivo|O|O||D||1
10217301|Tulipán vivo adrem|O|O||D||1
10217302|Tulipán vivo apricot|O|O||D||1
10217303|Tulipán vivo bicolor rojo y amarillo|O|O||D||1
10217304|Tulipán vivo doble bicolor|O|O||D||1
10217305|Tulipán vivo doble rosado|O|O||D||1
10217306|Tulipán vivo doble rojo|O|O||D||1
10217307|Tulipán vivo doble blanco|O|O||D||1
10217308|Tulipán vivo doble amarillo|O|O||D||1
10217309|Tulipán vivo francés avignon|O|O||D||1
10217310|Tulipán vivo francés camarque|O|O||D||1
10217311|Tulipán vivo francés dordogne|O|O||D||1
10217312|Tulipán vivo francés fiat|O|O||D||1
10217313|Tulipán vivo francés flamboyant|O|O||D||1
10217314|Tulipán vivo francés flaming parrot|O|O||D||1
10217315|Tulipán vivo francés florissa|O|O||D||1
10217316|Tulipán vivo francés doble maureen|O|O||D||1
10217317|Tulipán vivo francés maureen|O|O||D||1
10217318|Tulipán vivo francés menton|O|O||D||1
10217319|Tulipán vivo francés montpellier|O|O||D||1
10217320|Tulipán vivo francés naranja unique|O|O||D||1
10217321|Tulipán vivo francés peonia reconocido único|O|O||D||1
10217322|Tulipán vivo francés loro rosado|O|O||D||1
10217323|Tulipán vivo francés princesa unique|O|O||D||1
10217324|Tulipán vivo francés reconocido|O|O||D||1
10217325|Tulipán vivo francés schepppers|O|O||D||1
10217326|Tulipán vivo francés gamuza|O|O||D||1
10217327|Tulipán vivo francés toyota|O|O||D||1
10217328|Tulipán vivo francés loro weber|O|O||D||1
10217329|Tulipán vivo francés loro blanco|O|O||D||1
10217330|Tulipán vivo lavanda de borde crespo|O|O||D||1
10217331|Tulipán vivo rosado fuerte|O|O||D||1
10217332|Tulipán vivo rosado fuerte hoja variegada|O|O||D||1
10217333|Tulipán vivo lavanda|O|O||D||1
10217334|Tulipán vivo rosado claro hoja variegada|O|O||D||1
10217335|Tulipán vivo viuda alegre|O|O||D||1
10217336|Tulipán vivo anaranjado|O|O||D||1
10217337|Tulipán vivo loro negro|O|O||D||1
10217338|Tulipán vivo loro estela rijnveld|O|O||D||1
10217339|Tulipán vivo llameante|O|O||D||1
10217340|Tulipán vivo loro verde|O|O||D||1
10217341|Tulipán vivo loro lavanda|O|O||D||1
10217342|Tulipán vivo loro anaranjado|O|O||D||1
10217343|Tulipán vivo loro durazno|O|O||D||1
10217344|Tulipán vivo loro rosado|O|O||D||1
10217345|Tulipán vivo loro rojo|O|O||D||1
10217346|Tulipán vivo loro rojo rococó|O|O||D||1
10217347|Tulipán vivo loro weber|O|O||D||1
10217348|Tulipán vivo loro blanco|O|O||D||1
10217349|Tulipán vivo loro amarillo|O|O||D||1
10217350|Tulipán vivo rosado|O|O||D||1
10217351|Tulipán vivo púrpura|O|O||D||1
10217352|Tulipán vivo rojo|O|O||D||1
10217353|Tulipán vivo especias|O|O||D||1
10217354|Tulipán vivo blanco|O|O||D||1
10217355|Tulipán vivo amarillo|O|O||D||1
10217400|Flor de cera viva|O|O||D||1
10217401|Flor de cera viva alba|O|O||D||1
10217402|Flor de cera viva bicolor|O|O||D||1
10217403|Flor de cera viva chichilla|O|O||D||1
10217404|Flor de cera viva reina danzante|O|O||D||1
10217405|Flor de cera viva dinamarca|O|O||D||1
10217406|Flor de cera viva denmar|O|O||D||1
10217407|Flor de cera viva híbrida pastel flor gema|O|O||D||1
10217408|Flor de cera viva híbrida rosada flor gem|O|O||D||1
10217409|Flor de cera viva híbrida blanca rubia|O|O||D||1
10217410|Flor de cera viva híbrida eric john|O|O||D||1
10217411|Flor de cera viva híbrida dama pintada|O|O||D||1
10217412|Flor de cera viva híbrida revelación|O|O||D||1
10217413|Flor de cera viva híbrida bola de nieve|O|O||D||1
10217414|Flor de cera viva juriens brook|O|O||D||1
10217415|Flor de cera viva lady stephanie rosada|O|O||D||1
10217416|Flor de cera viva madonna|O|O||D||1
10217417|Flor de cera viva mini blanca|O|O||D||1
10217418|Flor de cera viva anaranjada|O|O||D||1
10217419|Flor de cera viva perla|O|O||D||1
10217420|Flor de cera viva pixie moon|O|O||D||1
10217421|Flor de cera viva orgullo púrpura|O|O||D||1
10217422|Flor de cera viva roja|O|O||D||1
10217423|Flor de cera viva wanaroo|O|O||D||1
10217424|Flor de cera viva amarilla|O|O||D||1
10217500|Hierba de aquiles viva|O|O||D||1
10217501|Hierba de aquiles viva vinotinto|O|O||D||1
10217502|Hierba de aquiles viva crema campesina|O|O||D||1
10217503|Hierba de aquiles viva rosado campesino|O|O||D||1
10217504|Hierba de aquiles viva luz de luna|O|O||D||1
10217505|Hierba de aquiles viva anaranjado|O|O||D||1
10217506|Hierba de aquiles viva durazno|O|O||D||1
10217507|Hierba de aquiles viva rosada|O|O||D||1
10217508|Hierba de aquiles viva rojo teñido|O|O||D||1
10217509|Hierba de aquiles viva blanca|O|O||D||1
10217510|Hierba de aquiles viva amarilla|O|O||D||1
10217600|Zinnia viva|O|O||D||1|Cinias (guadalajaras) vivas
10217601|Zinia viva amarilla|O|O||D||1|Cinia (guadalajara) viva amarilla
10217602|Zinia viva mini|O|O||D||1|Cinia (guadalajara) viva mini
10217603|Zinia viva rosado|O|O||D||1|Cinia (guadalajara) viva rosado
10217604|Zinia viva rojo|O|O||D||1|Cinia (guadalajara) viva rojo
10217605|Zinia viva salmón|O|O||D||1|Cinia (guadalajara) viva salmón
10217606|Zinia viva amarillo|O|O||D||1|Cinia (guadalajara) viva amarillo
10217700|Forsythia viva|O|O||D||1
10217701|Forsythia viva viridissima|O|O||D||1
10217702|Forsythia viva giraldiana|O|O||D||1
10217703|Forsythia viva mira|O|O||D||1
10217704|Forsythia viva suspensa|O|O||D||1
10217705|Forsythia viva intermedia|O|O||D||1
10217706|Forsythia viva variabilis|O|O||D||1
10217707|Forsythia viva ovate|O|O||D||1
10217708|Forsythia viva intermedia lynwood|O|O||D||1
10217800|Geranio vivo|O|O||D||1
10217801|Geranio vivo argenteum|O|O||D||1
10217802|Geranio vivo cinereum|O|O||D||1
10217803|Geranio vivo clarkei|O|O||D||1
10217804|Geranio vivo dalmaticum|O|O||D||1
10217805|Geranio vivo endressii|O|O||D||1
10217806|Geranio vivo eriostemon|O|O||D||1
10217807|Geranio vivo farreri|O|O||D||1
10217808|Geranio vivo himalayense o grandiflora|O|O||D||1
10217809|Geranio vivo ibericum|O|O||D||1
10217810|Geranio vivo macrorhizum o raiz grande|O|O||D||1
10217811|Geranio vivo maculatum|O|O||D||1
10217812|Geranio vivo nodosum|O|O||D||1
10217813|Geranio vivo phaeum|O|O||D||1
10217814|Geranio vivo platypetalum|O|O||D||1
10217815|Geranio vivo pratense|O|O||D||1
10217816|Geranio vivo procurrens|O|O||D||1
10217817|Geranio vivo psilostemon|O|O||D||1
10217818|Geranio vivo pylzowianum|O|O||D||1
10217819|Geranio vivo renardii|O|O||D||1
10217820|Geranio vivo sanguineum o sangruento|O|O||D||1
10217821|Geranio vivo sylvaticum|O|O||D||1
10217822|Geranio vivo traversii|O|O||D||1
10217823|Geranio vivo tuberosum|O|O||D||1
10217824|Geranio vivo versicolor|O|O||D||1
10217825|Geranio vivo wallachianum|O|O||D||1
10217826|Geranio vivo wlassovianum|O|O||D||1
10217827|Geranio vivo x magnificum o llamativo|O|O||D||1
10217900|Amaryllis viva|O|O||D||1|Lirios estrella vivos
10217901|Amaryllis viva aglaiae|O|O||D||1|Lirio estrella vivo aglaiae
10217902|Amaryllis viva amaru|O|O||D||1|Lirio estrella vivo amaru
10217903|Amaryllis viva angustifolium|O|O||D||1|Lirio estrella vivo angustifolium
10217904|Amaryllis viva anzaldoi|O|O||D||1|Lirio estrella vivo anzaldoi
10217905|Amaryllis viva araripinum|O|O||D||1|Lirio estrella vivo araripinum
10217906|Amaryllis viva arboricola|O|O||D||1|Lirio estrella vivo arborícola
10217907|Amaryllis viva argentinum|O|O||D||1|Lirio estrella vivo argentinum
10217908|Amaryllis viva aulicum|O|O||D||1|Lirio estrella vivo aulicum
10217909|Amaryllis viva aviflorum|O|O||D||1|Lirio estrella vivo aviflorum
10217910|Amaryllis viva barreirasum|O|O||D||1|Lirio estrella vivo barreirasum
10217911|Amaryllis viva blossfeldiae|O|O||D||1|Lirio estrella vivo blossfeldiae
10217912|Amaryllis viva blumenavium|O|O||D||1|Lirio estrella vivo blumenavium
10217913|Amaryllis viva brasilianum|O|O||D||1|Lirio estrella vivo brasilianum
10217914|Amaryllis viva breviflorum|O|O||D||1|Lirio estrella vivo breviflorum
10217915|Amaryllis viva bukasovii|O|O||D||1|Lirio estrella vivo bukasovii
10217916|Amaryllis viva calyptratum|O|O||D||1|Lirio estrella vivo calyptratum
10217917|Amaryllis viva caupolicanense|O|O||D||1|Lirio estrella vivo caupolicanense
10217918|Amaryllis viva chionedyanthum|O|O||D||1|Lirio estrella vivo chionedyanthum
10217919|Amaryllis viva condemaita|O|O||D||1|Lirio estrella vivo condemaita
10217920|Amaryllis viva corriense|O|O||D||1|Lirio estrella vivo corriense
10217921|Amaryllis viva cuzcoense|O|O||D||1|Lirio estrella vivo cuzcoense
10217922|Amaryllis viva curitibanum|O|O||D||1|Lirio estrella vivo curitibanum
10217923|Amaryllis viva cybister|O|O||D||1|Lirio estrella vivo cybister
10217924|Amaryllis viva divijuliani|O|O||D||1|Lirio estrella vivo divijuliani
10217925|Amaryllis viva evansiae|O|O||D||1|Lirio estrella vivo evansiae
10217926|Amaryllis viva ferreyrae|O|O||D||1|Lirio estrella vivo ferreyrae
10217927|Amaryllis viva forgetii|O|O||D||1|Lirio estrella vivo forgetii
10217928|Amaryllis viva fosteri|O|O||D||1|Lirio estrella vivo fosteri
10217929|Amaryllis viva fuscum|O|O||D||1|Lirio estrella vivo fuscum
10217930|Amaryllis viva glaucescens|O|O||D||1|Lirio estrella vivo glaucescens
10217931|Amaryllis viva goianum|O|O||D||1|Lirio estrella vivo goianum
10217932|Amaryllis viva guarapuavicum|O|O||D||1|Lirio estrella vivo guarapuavicum
10217933|Amaryllis viva harrisonii|O|O||D||1|Lirio estrella vivo harrisonii
10217934|Amaryllis viva hugoi|O|O||D||1|Lirio estrella vivo hugoi
10217935|Amaryllis viva iguazuanum|O|O||D||1|Lirio estrella vivo iguazuanum
10217936|Amaryllis viva illustre|O|O||D||1|Lirio estrella vivo illustre
10217937|Amaryllis viva intiflorum|O|O||D||1|Lirio estrella vivo intiflorum
10217938|Amaryllis viva kromeri|O|O||D||1|Lirio estrella vivo kromeri
10217939|Amaryllis viva lapacense|O|O||D||1|Lirio estrella vivo lapacense
10217940|Amaryllis viva leonardii|O|O||D||1|Lirio estrella vivo leonardii
10217941|Amaryllis viva leopoldii|O|O||D||1|Lirio estrella vivo leopoldii
10217942|Amaryllis viva macbridei|O|O||D||1|Lirio estrella vivo macbridei
10217943|Amaryllis viva machupijchense|O|O||D||1|Lirio estrella vivo machupijchense
10217944|Amaryllis viva mandonii|O|O||D||1|Lirio estrella vivo mandonii
10217945|Amaryllis viva minasgerais|O|O||D||1|Lirio estrella vivo minasgerais
10217946|Amaryllis viva miniatum|O|O||D||1|Lirio estrella vivo miniatum
10217947|Amaryllis viva mollevillquense|O|O||D||1|Lirio estrella vivo mollevillquense
10217948|Amaryllis viva morelianum|O|O||D||1|Lirio estrella vivo morelianum
10217949|Amaryllis viva nelsonii|O|O||D||1|Lirio estrella vivo nelsonii
10217950|Amaryllis viva oconoquense|O|O||D||1|Lirio estrella vivo oconoquense
10217951|Amaryllis viva papilio|O|O||D||1|Lirio estrella vivo papilio
10217952|Amaryllis viva paquichanum|O|O||D||1|Lirio estrella vivo paquichanum
10217953|Amaryllis viva paradisiacum|O|O||D||1|Lirio estrella vivo paradisiacum
10217954|Amaryllis viva pardinum|O|O||D||1|Lirio estrella vivo pardinum
10217955|Amaryllis viva parodii|O|O||D||1|Lirio estrella vivo parodii
10217956|Amaryllis viva petiolatum|O|O||D||1|Lirio estrella vivo petiolatum
10217957|Amaryllis viva psittacinum|O|O||D||1|Lirio estrella vivo psittacinum
10217958|Amaryllis viva puniceum|O|O||D||1|Lirio estrella vivo puniceum
10217959|Amaryllis viva reginae|O|O||D||1|Lirio estrella vivo reginae
10217960|Amaryllis viva reticulatum|O|O||D||1|Lirio estrella vivo reticulatum
10217961|Amaryllis viva rubropictum|O|O||D||1|Lirio estrella vivo rubropictum
10217962|Amaryllis viva santacatarina|O|O||D||1|Lirio estrella vivo santa catarina
10217963|Amaryllis viva solandraeflorum|O|O||D||1|Lirio estrella vivo solandraeflorum
10217964|Amaryllis viva starkiorum|O|O||D||1|Lirio estrella vivo starkiorum
10217965|Amaryllis viva striatum|O|O||D||1|Lirio estrella vivo striatum
10217966|Amaryllis viva stylosum|O|O||D||1|Lirio estrella vivo stylosum
10217967|Amaryllis viva teyucuarense|O|O||D||1|Lirio estrella vivo teyucuarense
10217968|Amaryllis viva traubii|O|O||D||1|Lirio estrella vivo traubii
10217969|Amaryllis viva vargasii|O|O||D||1|Lirio estrella vivo vargasii
10217970|Amaryllis viva variegatum|O|O||D||1|Lirio estrella vivo variegatum
10217971|Amaryllis viva vittatum|O|O||D||1|Lirio estrella vivo vittatum
10217972|Amaryllis viva yungacense|O|O||D||1|Lirio estrella vivo yungacense
10218000|Rubdeckia viva|O|O||D||1|Equináceas vivas
10218001|Rubdeckia viva alpicola|O|O||D||1|Equinácea viva alpicola
10218002|Rubdeckia viva amplexicaulis|O|O||D||1|Equinácea viva amplexicaulis
10218003|Rubdeckia viva auriculata|O|O||D||1|Equinácea viva auriculata
10218004|Rubdeckia viva bicolor|O|O||D||1|Equinácea viva bicolor
10218005|Rubdeckia viva californica|O|O||D||1|Equinácea viva califórnica
10218006|Rubdeckia viva fulgida|O|O||D||1|Equinácea viva fulgida
10218007|Rubdeckia viva glaucescens|O|O||D||1|Equinácea viva glaucescens
10218008|Rubdeckia viva graminifolia|O|O||D||1|Equinácea viva graminifolia
10218009|Rubdeckia viva grandiflora|O|O||D||1|Equinácea viva grandiflora
10218010|Rubdeckia viva heliopsidis|O|O||D||1|Equinácea viva heliopsidis
10218011|Rubdeckia viva hirta|O|O||D||1|Equinácea viva hirta
10218012|Rubdeckia viva klamathensis|O|O||D||1|Equinácea viva klamathensis
10218013|Rubdeckia viva laciniata|O|O||D||1|Equinácea viva laciniata
10218014|Rubdeckia viva máxima|O|O||D||1|Equinácea viva máxima
10218015|Rubdeckia viva missouriensis|O|O||D||1|Equinácea viva missouriensis
10218016|Rubdeckia viva mohrii|O|O||D||1|Equinácea viva mohrii
10218017|Rubdeckia viva mollis|O|O||D||1|Equinácea viva mollis
10218018|Rubdeckia viva montana|O|O||D||1|Equinácea viva montana
10218019|Rubdeckia viva nítida|O|O||D||1|Equinácea viva nítida
10218020|Rubdeckia viva occidentalis|O|O||D||1|Equinácea viva occidentalis
10218021|Rubdeckia viva pinnata|O|O||D||1|Equinácea viva pinnata
10218022|Rubdeckia viva scabrifolia|O|O||D||1|Equinácea viva scabrifolia
10218023|Rubdeckia viva serotina|O|O||D||1|Equinácea viva serótina
10218024|Rubdeckia viva speciosa|O|O||D||1|Equinácea viva speciosa
10218025|Rubdeckia viva subtomentosa|O|O||D||1|Equinácea viva subtomentosa
10218026|Rubdeckia viva texana|O|O||D||1|Equinácea viva texana
10218027|Rubdeckia viva triloba|O|O||D||1|Equinácea viva triloba
10218100|Protea viva|O|O||D||1
10218101|Protea viva bouquet|O|O||D||1
10218102|Protea viva cepillo botella|O|O||D||1
10218103|Protea viva carnaval|O|O||D||1
10218104|Protea viva follaje cordata|O|O||D||1
10218105|Protea viva grandiceps|O|O||D||1
10218106|Protea viva visón verde|O|O||D||1
10218107|Protea viva hiedra|O|O||D||1
10218108|Protea viva rey|O|O||D||1
10218109|Protea viva nana cones|O|O||D||1
10218110|Protea viva alfiletero anaranjada|O|O||D||1
10218111|Protea viva alfiletero tango|O|O||D||1
10218112|Protea viva alfiletero amarillo|O|O||D||1
10218113|Protea viva hielo rosado|O|O||D||1
10218114|Protea viva visón rosado|O|O||D||1
10218115|Protea viva reina|O|O||D||1
10218116|Protea viva repens|O|O||D||1
10218117|Protea viva cuchara de rosas|O|O||D||1
10218118|Protea viva silvia|O|O||D||1
10218119|Protea viva sugarbush|O|O||D||1
10218120|Protea viva susara|O|O||D||1
10218121|Protea viva waratha|O|O||D||1
10218122|Protea viva visón blanco|O|O||D||1
10218200|leucadendron vivo|O|O||D||1
10218201|Leucadendron vivo argenteum|O|O||D||1
10218202|Leucadendron vivo delicia de crema|O|O||D||1
10218203|Leucadendron vivo cumosum|O|O||D||1
10218204|Leucadendron vivo discolor|O|O||D||1
10218205|Leucadendron vivo galpini|O|O||D||1
10218206|Leucadendron vivo mina de oro|O|O||D||1
10218207|Leucadendron vivo oro inca|O|O||D||1
10218208|Leucadendron vivo bufón|O|O||D||1
10218209|Leucadendron vivo laxum|O|O||D||1
10218210|Leucadendron vivo mini|O|O||D||1
10218211|Leucadendron vivo oro patea|O|O||D||1
10218212|Leucadendron vivo petra|O|O||D||1
10218213|Leucadendron vivo plumosum|O|O||D||1
10218214|Leucadendron vivo roseta|O|O||D||1
10218215|Leucadendron vivo atardecer safari|O|O||D||1
10218216|Leucadendron vivo atardecer safari spr|O|O||D||1
10218217|Leucadendron vivo speciosa|O|O||D||1
10218218|Leucadendron vivo spray|O|O||D||1
10218219|Leucadendron vivo maravilla wilson|O|O||D||1
10218220|Leucadendron vivo yarden|O|O||D||1
10218300|leucospermum vivo|O|O||D||1
10218301|Leucospermum vivo album|O|O||D||1
10218302|Leucospermum vivo attenuatum|O|O||D||1
10218303|Leucospermum vivo calligerum|O|O||D||1
10218304|Leucospermum vivo conocarpodendron|O|O||D||1
10218305|Leucospermum vivo cordatum|O|O||D||1
10218306|Leucospermum vivo cuneiforme|O|O||D||1
10218307|Leucospermum vivo formosum|O|O||D||1
10218308|Leucospermum vivo glabrum|O|O||D||1
10218309|Leucospermum vivo grandiflorum|O|O||D||1
10218310|Leucospermum vivo harmatum|O|O||D||1
10218311|Leucospermum vivo heterophyllum|O|O||D||1
10218312|Leucospermum vivo innovans|O|O||D||1
10218313|Leucospermum vivo muirii|O|O||D||1
10218314|Leucospermum vivo oleifolium|O|O||D||1
10218315|Leucospermum vivo patersonii|O|O||D||1
10218316|Leucospermum vivo pluridens|O|O||D||1
10218317|Leucospermum vivo praemorsum|O|O||D||1
10218318|Leucospermum vivo prostratum|O|O||D||1
10218319|Leucospermum vivo rodolentum|O|O||D||1
10218320|Leucospermum vivo saxatile|O|O||D||1
10218321|Leucospermum vivo secundifolium|O|O||D||1
10218322|Leucospermum vivo tomentosus|O|O||D||1
10218323|Leucospermum vivo truncatulum|O|O||D||1
10218324|Leucospermum vivo utriculosum|O|O||D||1
10218325|Leucospermum vivo winterii|O|O||D||1
10218326|Leucospermum vivo arenarium|O|O||D||1
10218327|Leucospermum vivo bolusii|O|O||D||1
10218328|Leucospermum vivo catherinae|O|O||D||1
10218329|Leucospermum vivo conocarpum|O|O||D||1
10218330|Leucospermum vivo cordifolium|O|O||D||1
10218331|Leucospermum vivo erubescens|O|O||D||1
10218332|Leucospermum vivo gerrardii|O|O||D||1
10218333|Leucospermum vivo gracile|O|O||D||1
10218334|Leucospermum vivo gueinzii|O|O||D||1
10218335|Leucospermum vivo harpagonatum|O|O||D||1
10218336|Leucospermum vivo hypophyllocarpodendron|O|O||D||1
10218337|Leucospermum vivo lineare|O|O||D||1
10218338|Leucospermum vivo mundii|O|O||D||1
10218339|Leucospermum vivo parile|O|O||D||1
10218340|Leucospermum vivo pendunculatum|O|O||D||1
10218341|Leucospermum vivo praecox|O|O||D||1
10218342|Leucospermum vivo profugum|O|O||D||1
10218343|Leucospermum vivo reflexum|O|O||D||1
10218344|Leucospermum vivo royenifolium|O|O||D||1
10218345|Leucospermum vivo saxosum|O|O||D||1
10218346|Leucospermum vivo spathulatum|O|O||D||1
10218347|Leucospermum vivo tottum|O|O||D||1
10218348|Leucospermum vivo truncatum|O|O||D||1
10218349|Leucospermum vivo vestitum|O|O||D||1
10218350|Leucospermum vivo wittebergense|O|O||D||1
10221500|Agapanto vivo|O|O||D||1|Flor del amor viva
10221501|Agapanto vivo azul|O|O||D||1|Flor del amor viva azul
10221502|Agapanto vivo blanco|O|O||D||1|Flor del amor viva blanco
10221600|Alchimilla viva|O|O||D||1|Pie de león vivo
10221601|Alchimilla viva capa de dama|O|O||D||1|Pie de león vivo capa de dama
10221602|Alchimilla viva robustica|O|O||D||1|Pie de león vivo robustica
10221700|Astilbe vivo|O|O||D||1|Barba falsa de cabra vivas
10221701|Astilbe vivo rosado fuerte|O|O||D||1|Barba falsa de cabra viva rosado fuerte
10221702|Astilbe vivo rosado claro|O|O||D||1|Barba falsa de cabra viva rosado claro
10221703|Astilbe vivo rojo|O|O||D||1|Barba falsa de cabra viva rojo
10221704|Astilbe vivo blanco|O|O||D||1|Barba falsa de cabra viva blanco
10221800|angélica viva|O|O||D||1
10221801|Angélica viva gigas|O|O||D||1
10221802|Angélica viva sylvestris|O|O||D||1
10221900|ajenjo vivo|O|O||D||1
10221901|Ajenjo vivo verde|O|O||D||1
10221902|Ajenjo vivo rey plata|O|O||D||1
10222000|Flor de alcachofa viva|O|O||D||1
10222001|Flor de alcachofa viva chocolate|O|O||D||1
10222002|Flor de alcachofa viva verde|O|O||D||1
10222003|Flor de alcachofa viva púrpura o floreciente|O|O||D||1
10222100|Astrantia viva|O|O||D||1
10222101|Astrantia viva rosada|O|O||D||1
10222102|Astrantia viva blanca|O|O||D||1
10222200|Flor de banano viva|O|O||D||1
10222201|Flor de banano viva anaranjada|O|O||D||1
10222202|Flor de banano viva antorcha anaranjada|O|O||D||1
10222203|Flor de banano viva púrpura|O|O||D||1
10222300|Baptisia viva|O|O||D||1
10222301|Baptisia viva australis|O|O||D||1
10222302|Baptisia viva sphaerocarpa|O|O||D||1
10222400|Boronia viva|O|O||D||1
10222401|Boronia viva rosada|O|O||D||1
10222402|Boronia viva amarilla|O|O||D||1
10222500|Bromelia viva|O|O||D||1
10222501|Bromelia viva amarilla reg|O|O||D||1
10222502|Bromelia viva roja reg|O|O||D||1
10222600|Brunia viva|O|O||D||1
10222601|Brunia viva albiflora|O|O||D||1
10222602|Brunia viva albiflora verde|O|O||D||1
10222603|Brunia viva rocío de plata|O|O||D||1
10222700|Catalea viva|O|O||D||1|Calatheas vivas
10222701|Calatea viva cigarro|O|O||D||1|Calathea viva cigarro
10222702|Calatea hielo verde|O|O||D||1|Calathea viva hielo verde
10222703|Calatea serpiente cascabel|O|O||D||1|Calathea viva serpiente cascabel
10222800|Calcynia viva|O|O||D||1
10222801|Calcynia viva rosada|O|O||D||1
10222802|Calcynia viva princesa|O|O||D||1
10222803|Calcynia viva blanca|O|O||D||1
10222900|Caléndula viva|O|O||D||1
10222901|Caléndula viva anaranjada|O|O||D||1
10222902|Caléndula viva amarilla|O|O||D||1
10223000|Campanilla viva|O|O||D||1
10223001|Campanilla viva azul|O|O||D||1
10223002|Campanilla viva rosada|O|O||D||1
10223003|Campanilla viva blanca|O|O||D||1
10223100|Cestrum vivo|O|O||D||1
10223101|Cestrum vivo rojo|O|O||D||1
10223102|Cestrum vivo rojo zohar|O|O||D||1
10223103|Cestrum vivo amarillo|O|O||D||1
10223200|Chasmante viva|O|O||D||1
10223201|Chasmante floribunda viva amarilla|O|O||D||1
10223202|Chasmante floribunda viva anaranjada|O|O||D||1
10223300|Costus viva|O|O||D||1
10223301|Costus barbada viva|O|O||D||1
10223302|Costus viva cabeza de indio|O|O||D||1
10223400|Vara de San José viva|O|O||D||1|Montbretias vivas
10223401|Vara de san josé lucifer viva|O|O||D||1|Montbretia lucifer viva
10223402|Vara de san josé viva vainas|O|O||D||1|Montbretia viva vainas
10223403|Vara de san josé viva amarilla|O|O||D||1|Montbretia viva amarilla
10223500|Lirio del Fuego vivo|O|O||D||1|Vallotas vivas
10223501|Lirio del fuego vivo anaranjado brillante|O|O||D||1|Vallota viva anaranjado brillante
10223502|Lirio del fuego vivo crema|O|O||D||1|Vallota viva crema
10223503|Lirio del fuego vivo anaranjado|O|O||D||1|Vallota viva anaranjado
10223504|Lirio del fuego vivo amarillo|O|O||D||1|Vallota viva amarillo
10223600|Flor del muelle viva|O|O||D||1
10223601|Flor del muelle viva verde|O|O||D||1
10223602|Flor del muelle viva roja|O|O||D||1
10223700|Planta erizo viva|O|O||D||1
10223701|Planta erizo viva tintura negra|O|O||D||1
10223702|Planta erizo viva tintura anaranjada|O|O||D||1
10223800|Manzanilla viva|O|O||D||1
10223801|Manzanilla viva sencilla vegmo|O|O||D||1
10223802|Manzanilla viva doble blanca|O|O||D||1
10223803|Manzanilla viva bola de nieve|O|O||D||1
10223804|Manzanilla viva blanca|O|O||D||1
10223900|Nomeolvides viva|O|O||D||1
10223901|Nomeolvides viva azul|O|O||D||1
10223902|Nomeolvides viva blanca|O|O||D||1
10224000|Gallardia viva|O|O||D||1
10224001|Gallardia viva anaranjada|O|O||D||1
10224002|Gallardia viva amarilla|O|O||D||1
10224100|Genciana viva|O|O||D||1
10224101|Genciana viva azul|O|O||D||1
10224102|Genciana viva blanca|O|O||D||1
10224200|Gladiolo vivo|O|O||D||1
10224201|Gladiolo vivo glamini rosado|O|O||D||1
10224202|Gladiolo vivo glamini rojo|O|O||D||1
10224300|Gloriosa viva|O|O||D||1
10224301|Gloriosa viva anaranjada|O|O||D||1
10224302|Gloriosa viva roja|O|O||D||1
10224303|Gloriosa viva amarilla|O|O||D||1
10224400|Violeta silvestre viva|O|O||D||1|Vadamallis vivas
10224401|Violeta silvestre viva anaranjada|O|O||D||1|Vadamalli viva anaranjada
10224402|Violeta silvestre viva roja|O|O||D||1|Vadamalli viva roja
10224500|Eléboro vivo|O|O||D||1|Hierbas de ballesteros vivas
10224501|Eléboro vivo verde|O|O||D||1|Hierba de ballesteros vivo verde
10224502|Eléboro vivo rayo de luna|O|O||D||1|Hierba de ballesteros vivo rayo de luna
10224600|Ixia viva|O|O||D||1
10224601|Ixia viva rosada|O|O||D||1
10224602|Ixia viva blanca|O|O||D||1
10224700|Liatrises vivas|O|O||D||1
10224701|Liatris viva púrpura|O|O||D||1
10224702|Liatris viva spray|O|O||D||1
10224703|Liatris viva blanca|O|O||D||1
10224800|Lysimachia viva|O|O||D||1
10224801|Lysimachia punctata viva|O|O||D||1
10224802|Lysimachia vulgaris viva|O|O||D||1
10224803|Lysimachia blanca viva|O|O||D||1
10224804|Lysimachia amarilla viva|O|O||D||1
10224900|Maraca viva|O|O||D||1
10224901|Maraca viva marrón|O|O||D||1
10224902|Maraca viva shampoo ginger|O|O||D||1
10225000|Caléndula viva|O|O||D||1
10225001|Caléndula viva francesa|O|O||D||1
10225002|Caléndula viva verde|O|O||D||1
10225003|Caléndula (marigold) viva anaranjada|O|O||D||1
10225004|Caléndula (marigold) viva amarilla|O|O||D||1
10225100|Mimosa viva|O|O||D||1
10225101|Mimosa viva azul o púrpura|O|O||D||1
10225102|Mimosa dedo viva|O|O||D||1
10225103|Mimosa viva floribunda o italia|O|O||D||1
10225104|Mimosa viva mirandola|O|O||D||1
10225200|Nerina viva|O|O||D||1
10225201|Nerina viva rosada|O|O||D||1
10225202|Nerina samiensis blanca|O|O||D||1
10225300|Flor de nogal viva|O|O||D||1
10225301|Flor colgante de nogal blanco viva|O|O||D||1
10225302|Flor sin hojas de nogal blanco viva|O|O||D||1
10225303|Flor erecta de nogal blanco brasileño viva|O|O||D||1
10225400|Phlox viva|O|O||D||1
10225401|Phlox viva rosado oscur|O|O||D||1
10225402|Phlox viva lavanda|O|O||D||1
10225403|Phlox viva rosado claro|O|O||D||1
10225404|Phlox viva blanca|O|O||D||1
10225500|physostegia viva|O|O||D||1|Plantas obedientes vivas
10225501|Physostegia viva rosada|O|O||D||1|Planta obediente viva rosada
10225502|Physostegia viva vainas|O|O||D||1|Planta obediente viva vainas
10225503|Physostegia viva blanca|O|O||D||1|Planta obediente viva blanca
10225600|Saponaria viva|O|O||D||1|Jabonarias vivas
10225601|Saponaria viva rosada|O|O||D||1|Jabonaria viva rosada
10225602|Saponaria viva blanca|O|O||D||1|Jabonaria viva blanca
10225700|Sarracenias vivas|O|O||D||1
10225701|Sarracenia viva flava rugelii|O|O||D||1
10225800|Sicilia viva|O|O||D||1|Scillas vivas
10225801|Sicilia viva campanulata azul|O|O||D||1|Scilla viva campanulata azul
10225802|Sicilia viva campanulata rosada|O|O||D||1|Scilla viva campanulata rosada
10225803|Sicilia viva campanulata blanca|O|O||D||1|Scilla viva campanulata blanca
10225804|Sicilia viva peruana|O|O||D||1|Scilla viva peruana
10225900|Sedum viva|O|O||D||1
10225901|Sedum viva marrón|O|O||D||1
10225902|Sedum viva verde|O|O||D||1
10225903|Sedum viva rosada|O|O||D||1
10225904|Sedum viva roja|O|O||D||1
10226000|Especies individuales o variedades de flores vivas|O|O||D||1|Flor de cempasúchil
10226001|Agrsotema viva|O|O||D||1
10226002|Kniphophia o assegai poker viva|O|O||D||1
10226003|Bellis perennis viva|O|O||D||1
10226004|Campana de irlanda o molucella viva|O|O||D||1
10226005|Ave del paraíso viva|O|O||D||1
10226006|Novia sonrojada viva|O|O||D||1
10226007|Buddleia o arbusto mariposa viva|O|O||D||1
10226008|Bupleurum griffithii viva|O|O||D||1
10226009|California ginesta viva|O|O||D||1
10226010|Callicarpa púrpura viva|O|O||D||1
10226011|Campanilla blanca viva|O|O||D||1
10226012|Penacho dulce viva|O|O||D||1
10226013|Cariopteris viva|O|O||D||1
10226014|Centaurea o marco polo viva|O|O||D||1
10226015|Linterna china viva|O|O||D||1
10226016|Clematis recta purpurea viva|O|O||D||1
10226017|Cleome spinosa viva|O|O||D||1
10226018|Coreopsis viva|O|O||D||1
10226019|Farolitos de la virgen azul viva|O|O||D||1
10226020|Cosmos chocolate viva|O|O||D||1
10226021|Cotinus coggygria viva|O|O||D||1
10226022|Craspedia o billy bolas viva|O|O||D||1
10226023|Deutzia alta viva|O|O||D||1
10226024|Diosma viva|O|O||D||1
10226025|Echeveria suculenta chupahuevos viva|O|O||D||1
10226026|Echinacea purpurea viva|O|O||D||1
10226027|Edelweiss viva|O|O||D||1
10226028|Erythronium pagoda viva|O|O||D||1
10226029|Flor de eucalipto viva|O|O||D||1
10226030|Eucaris o lirio del amazonas vivo|O|O||D||1
10226031|Eucomis o lirio de piña vivo|O|O||D||1
10226032|Eupatorium maculatum vivo|O|O||D||1
10226033|Filipendula viva|O|O||D||1
10226034|Digitalis vivo|O|O||D||1
10226035|Gilia globo viva|O|O||D||1
10226036|Globularia de ojo azul viva|O|O||D||1
10226037|Washington hawthorne viva|O|O||D||1
10226038|Helenio viva|O|O||D||1
10226039|Helianto viva|O|O||D||1
10226040|Herperis matronalis viva|O|O||D||1
10226041|Houttuynia cordata chameleon viva|O|O||D||1
10226042|Jacinto con bulbo viva|O|O||D||1
10226043|Maiz indio vivo|O|O||D||1
10226044|Jack en el púlpito vivo|O|O||D||1
10226045|Arbol del cielo japonés vivo|O|O||D||1
10226046|Enredadera de jazmin florecida viva|O|O||D||1
10226047|Jatropha curcas o pólvora viva|O|O||D||1
10226048|Knautia viva|O|O||D||1
10226049|Kochia sedifolia viva|O|O||D||1
10226050|Lachenalia romaud viva|O|O||D||1
10226051|Flor de oreja de oveja viva|O|O||D||1
10226052|Lavanda viva|O|O||D||1
10226053|Leucocoryne speciosa viva|O|O||D||1
10226054|Lythrum viva|O|O||D||1
10226055|Malva zebrina viva|O|O||D||1
10226056|Margarita blanca viva|O|O||D||1
10226057|Montbretia amarilla viva|O|O||D||1
10226058|Nebelia viva|O|O||D||1
10226059|Nicotiana viva verde|O|O||D||1
10226060|Nigella damascena o amor en la niebla viva|O|O||D||1
10226061|Nigella viva|O|O||D||1
10226062|Orquídea de monja viva|O|O||D||1
10226063|Orquídea verde paphiopedilum|O|O||D||1
10226064|Paranomus viva|O|O||D||1
10226065|Penstemon husker rojo vivo|O|O||D||1
10226066|Manzana peruana viva|O|O||D||1|Cactus vivo
10226067|Phlomis sarnia viva|O|O||D||1
10226068|Didiscus o flor de encaje rosada viva|O|O||D||1
10226069|Platycodon o flor globo viva|O|O||D||1
10226070|Retzia capensis viva|O|O||D||1
10226071|Ricino común vivo|O|O||D||1
10226072|Nieve en el monte viva|O|O||D||1
10226073|Solidago teñida viva|O|O||D||1
10226074|Scilla blanca viva|O|O||D||1|Cebolla albarrana viva (ornamental)
10226075|Stachys byzantina viva|O|O||D||1
10226076|Flor de paja viva|O|O||D||1
10226077|Oscularia suculenta viva|O|O||D||1
10226078|Flor de tillasandia viva|O|O||D||1
10226079|Triteleia viva|O|O||D||1
10226080|Tritoma naranja o chuzo caliente viva roja|O|O||D||1
10226081|Veronicastrum virginiana viva|O|O||D||1
10226082|Bromelia vriesea splendens viva|O|O||D||1|Pluma de indio viva
10226084|Hipericim o hierba de san juan viva|O|O||D||1
10226085|Spirea viva|O|O||D||1
10226086|Yerba de san bonifacio viva|O|O||D||1
10226100|Sello de salomón (polygonato) viva|O|O||D||1
10226101|Sello de salomón (polygonato) falso viva|O|O||D||1
10226102|Sello de salomón (polygonato) variegado viva|O|O||D||1
10226200|Tanaceto vivo|O|O||D||1
10226201|Tanaceto vivo amazonas|O|O||D||1
10226202|Tanaceto vivo victoria doble blanco|O|O||D||1
10226203|Tanaceto vivo victoria sencillo blanco|O|O||D||1
10226204|Tanaceto vivo vegmo amarillo|O|O||D||1
10226300|Traquelio vivo|O|O||D||1|Flores de la viuda vivas
10226301|Trachelium jade viva|O|O||D||1|Flor de la viuda jade viva
10226302|Trachelium púrpura viva|O|O||D||1|Flor de la viuda púrpura viva
10226303|Trachelium blanca viva|O|O||D||1|Flor de la viuda blanca viva
10226400|Tuberosas vivas|O|O||D||1|Nardos vivos
10226401|Tuberosa viva doble|O|O||D||1|Nardo vivo doble
10226402|Tuberosa viva sencilla|O|O||D||1|Nardo vivo sencillo
10226500|Tweedias vivas|O|O||D||1
10226501|Tweedia azul viva|O|O||D||1
10226502|Tweedia blanca viva|O|O||D||1
10226600|Verónicas vivas|O|O||D||1
10226601|Verónica viva rosada|O|O||D||1
10226602|Verónica viva púrpura|O|O||D||1
10226603|Verónica viva blanca|O|O||D||1
10226700|Watsonias vivas|O|O||D||1
10226701|Watsonia viva anaranjada|O|O||D||1
10226702|Watsonia viva rosada|O|O||D||1
10226703|Watsonia viva roja|O|O||D||1
10226704|Watsonia viva blanca|O|O||D||1
10231500|Crisantemo vivo pompón|O|O||D||1
10231501|Crisantemo vivo pompón delirock|O|O||D||1
10231502|Crisantemo vivo pompón discovery|O|O||D||1
10231503|Crisantemo vivo pompón focus|O|O||D||1
10231504|Crisantemo vivo pompón jeanne|O|O||D||1
10231505|Crisantemo vivo pompón lady|O|O||D||1
10231506|Crisantemo vivo pompón leidi|O|O||D||1
10231507|Crisantemo vivo pompón lexy|O|O||D||1
10231508|Crisantemo vivo pompón ole|O|O||D||1
10231509|Crisantemo vivo pompón revise|O|O||D||1
10231510|Crisantemo vivo pompón estadista|O|O||D||1
10231511|Crisantemo vivo pompón dulce|O|O||D||1
10231512|Crisantemo vivo pompón yoko ono|O|O||D||1
10231513|Crisantemo vivo pompón zip|O|O||D||1
10231600|Crisantemo vivo pompón margarita|O|O||D||1
10231601|Crisantemo vivo pompón artista rosado|O|O||D||1
10231602|Crisantemo vivo pompón artista amarillo|O|O||D||1
10231603|Crisantemo vivo pompón atlantis rosado|O|O||D||1
10231604|Crisantemo vivo pompón atlantis blanco|O|O||D||1
10231605|Crisantemo vivo pompón atlantis amarillo|O|O||D||1
10231606|Crisantemo vivo pompón bennie jolink|O|O||D||1
10231607|Crisantemo vivo pompón bennie jolink amarillo|O|O||D||1
10231608|Crisantemo vivo pompón managua bronce|O|O||D||1
10231609|Crisantemo vivo pompón clave|O|O||D||1
10231610|Crisantemo vivo pompón ficción coral|O|O||D||1
10231611|Crisantemo vivo pompón cumbia|O|O||D||1
10231612|Crisantemo vivo pompón cantata oscura|O|O||D||1
10231613|Crisantemo vivo pompón lineker oscuro|O|O||D||1
10231614|Crisantemo vivo pompón dipper|O|O||D||1
10231615|Crisantemo vivo pompón rosado elite|O|O||D||1
10231616|Crisantemo vivo pompón blanco elite|O|O||D||1
10231617|Crisantemo vivo pompón amarillo elite|O|O||D||1
10231618|Crisantemo vivo pompón factor|O|O||D||1
10231619|Crisantemo vivo pompón ficción|O|O||D||1
10231620|Crisantemo vivo pompón fuerza|O|O||D||1
10231621|Crisantemo vivo pompón reagan mejorado|O|O||D||1
10231622|Crisantemo vivo pompón life|O|O||D||1
10231623|Crisantemo vivo pompón managua anaranjado|O|O||D||1
10231624|Crisantemo vivo pompón novedsd bronce cocarde|O|O||D||1
10231625|Crisantemo vivo pompón reagan anaranjado|O|O||D||1
10231626|Crisantemo vivo pompón orinoco|O|O||D||1
10231627|Crisantemo vivo pompón petra|O|O||D||1
10231628|Crisantemo vivo pompón balsas rosado|O|O||D||1
10231629|Crisantemo vivo pompón mona lisa rosado|O|O||D||1
10231630|Crisantemo vivo pompón reagan rosado|O|O||D||1
10231631|Crisantemo vivo pompón marfil reagan|O|O||D||1
10231632|Crisantemo vivo pompón reagan rosado|O|O||D||1
10231633|Crisantemo vivo pompón rebasco|O|O||D||1
10231634|Crisantemo vivo pompón redock|O|O||D||1
10231635|Crisantemo vivo pompón salmón lineker|O|O||D||1
10231636|Crisantemo vivo pompón sheba|O|O||D||1
10231637|Crisantemo vivo pompón sirius|O|O||D||1
10231638|Crisantemo vivo pompón reagan espléndido|O|O||D||1
10231639|Crisantemo vivo pompón reagan soleado|O|O||D||1
10231640|Crisantemo vivo pompón tina|O|O||D||1
10231641|Crisantemo vivo pompón vero|O|O||D||1
10231642|Crisantemo vivo pompón volare|O|O||D||1
10231643|Crisantemo vivo pompón vida blanca|O|O||D||1
10231644|Crisantemo vivo pompón regan blanco|O|O||D||1
10231645|Crisantemo vivo pompón rino blanco|O|O||D||1
10231646|Crisantemo vivo pompón vero amarillo|O|O||D||1
10231647|Crisantemo vivo pompón zenith|O|O||D||1
10231700|Crisantemo vivo espollado cremon|O|O||D||1
10231701|Crisantemo vivo espollado cremon annecy oscura|O|O||D||1
10231702|Crisantemo vivo espollado cremon|O|O||D||1
10231703|Crisantemo vivo espollado cremon atlantis rosado|O|O||D||1
10231704|Crisantemo vivo espollado cremon eleonora bronce|O|O||D||1
10231705|Crisantemo vivo espollado cremon eleonora lila|O|O||D||1
10231706|Crisantemo vivo espollado cremon eleonora rosado|O|O||D||1
10231707|Crisantemo vivo espollado cremon eleonora nieve|O|O||D||1
10231708|Crisantemo vivo espollado cremon eleonora amarillo|O|O||D||1
10231709|Crisantemo vivo espollado cremon idea|O|O||D||1
10231710|Crisantemo vivo espollado cremon ivanna púrpura|O|O||D||1
10231711|Crisantemo vivo espollado cremon minka rosado|O|O||D||1
10231712|Crisantemo vivo espollado cremon listo|O|O||D||1
10231713|Crisantemo vivo espollado cremon sinatra|O|O||D||1
10231714|Crisantemo vivo rover rojo|O|O||D||1
10231800|Crisantemo vivo espollado football|O|O||D||1
10231801|Crisantemo vivo espollado blaze|O|O||D||1
10231802|Crisantemo vivo espollado beso de football|O|O||D||1
10231803|Crisantemo vivo espollado football lavanda / rosado|O|O||D||1
10231804|Crisantemo vivo espollado football resouci|O|O||D||1
10231805|Crisantemo vivo espollado footbal blanco|O|O||D||1
10231806|Crisantemo vivo espollado football amarillo|O|O||D||1
10231807|Crisantemo vivo espollado promenade|O|O||D||1
10231808|Crisantemo vivo espollado rebonnet|O|O||D||1
10231809|Crisantemo vivo espollado reflex|O|O||D||1
10231810|Crisantemo vivo espollado residence|O|O||D||1
10231811|Crisantemo vivo espollado resomee perla|O|O||D||1
10231812|Crisantemo vivo espollado resouci|O|O||D||1
10231900|Crisantemo spider vivo|O|O||D||1
10231901|Crisantemo spider vivo anastasia bronce|O|O||D||1
10231902|Crisantemo spider vivo anastasia bronce oscuro|O|O||D||1
10231903|Crisantemo spider vivo anastasia verde|O|O||D||1
10231904|Crisantemo spider vivo anastasia lila|O|O||D||1
10231905|Crisantemo spider vivo anastasia rosado|O|O||D||1
10231906|Crisantemo spider vivo anastasia púrpura|O|O||D||1
10231907|Crisantemo spider vivo anastasia soleado|O|O||D||1
10231908|Crisantemo spider vivo anastasia blanco|O|O||D||1
10231909|Crisantemo spider vivo bradford|O|O||D||1
10231910|Crisantemo spider vivo delistar blanco|O|O||D||1
10231911|Crisantemo spider vivo delistar amarillo|O|O||D||1
10231912|Crisantemo spider vivo minka|O|O||D||1
10231913|Crisantemo spider vivo natasha soleado|O|O||D||1
10231914|Crisantemo spider vivo pirouette|O|O||D||1
10231915|Crisantemo spider vivo reflejo|O|O||D||1
10231916|Crisantemo spider vivo regata|O|O||D||1
10231917|Crisantemo spider vivo render|O|O||D||1
10231918|Crisantemo spider vivo repertorio|O|O||D||1
10231919|Crisantemo spider vivo resolute|O|O||D||1
10231920|Crisantemo spider vivo resomac|O|O||D||1
10231921|Crisantemo spider vivo trébol|O|O||D||1
10231922|Crisantemo spider vivo talante bronce|O|O||D||1
10231923|Crisantemo spider vivo super blanco|O|O||D||1
10231924|Crisantemo spider vivo super amarillo|O|O||D||1
10231925|Crisantemo spider vivo tierno|O|O||D||1
10231926|Crisantemo spider vivo zembia|O|O||D||1
10232000|Crisantemo vivo  novelty|O|O||D||1
10232001|Crisantemo vivo pompón anecy rosado|O|O||D||1
10232002|Crisantemo vivo pompón ardilo royal|O|O||D||1
10232003|Crisantemo vivo pompón athos|O|O||D||1
10232004|Crisantemo vivo pompón biarritz|O|O||D||1
10232005|Crisantemo vivo pompón bradford anaranjado|O|O||D||1
10232006|Crisantemo vivo pompón bradford|O|O||D||1
10232007|Crisantemo vivo pompón vela|O|O||D||1
10232008|Crisantemo vivo pompón candor|O|O||D||1
10232009|Crisantemo vivo pompón gallardía|O|O||D||1
10232010|Crisantemo vivo pompón décima|O|O||D||1
10232012|Crisantemo vivo pompón delisun|O|O||D||1
10232013|Crisantemo vivo pompón dion|O|O||D||1
10232014|Crisantemo vivo pompón dorena|O|O||D||1
10232015|Crisantemo vivo pompón dublín|O|O||D||1
10232016|Crisantemo vivo pompón everglades|O|O||D||1
10232017|Crisantemo vivo pompón buenmozo|O|O||D||1
10232018|Crisantemo vivo pompón hasting|O|O||D||1
10232019|Crisantemo vivo pompón high five|O|O||D||1
10232020|Crisantemo vivo pompón mundial mejorado|O|O||D||1
10232021|Crisantemo vivo pompón juanes|O|O||D||1
10232022|Crisantemo vivo pompón kiato verde|O|O||D||1
10232023|Crisantemo vivo pompón kiato|O|O||D||1
10232024|Crisantemo vivo pompón kiwi|O|O||D||1
10232025|Crisantemo vivo pompón madeira|O|O||D||1
10232026|Crisantemo vivo pompón magneto|O|O||D||1
10232027|Crisantemo vivo pompón marimo|O|O||D||1
10232028|Crisantemo vivo pompón matrix|O|O||D||1
10232029|Crisantemo vivo pompón miletta|O|O||D||1
10232030|Crisantemo vivo pompón monalisa|O|O||D||1
10232031|Crisantemo vivo pompón omaha|O|O||D||1
10232032|Crisantemo vivo pompón orinoco púrpura|O|O||D||1
10232033|Crisantemo vivo pompón orinoco amarillo|O|O||D||1
10232034|Crisantemo vivo pompón verde pacífico|O|O||D||1
10232035|Crisantemo vivo pompón blanco puma|O|O||D||1
10232036|Crisantemo vivo pompón amarillo puma|O|O||D||1
10232037|Crisantemo vivo pompón mundial púrpura|O|O||D||1
10232038|Crisantemo vivo pompón regata|O|O||D||1
10232039|Crisantemo vivo pompón remco|O|O||D||1
10232040|Crisantemo vivo pompón royal mundial|O|O||D||1
10232041|Crisantemo vivo pompón sabrina|O|O||D||1
10232042|Crisantemo vivo pompón shakira blanco|O|O||D||1
10232043|Crisantemo vivo pompón sharp|O|O||D||1
10232044|Crisantemo vivo pompón shock|O|O||D||1
10232045|Crisantemo vivo pompón sizzle verde|O|O||D||1
10232046|Crisantemo vivo pompón sizzle rosado|O|O||D||1
10232047|Crisantemo vivo pompón sizzle|O|O||D||1
10232048|Crisantemo vivo pompón sizzle púrpura|O|O||D||1
10232049|Crisantemo vivo pompón sizzle salmón|O|O||D||1
10232050|Crisantemo vivo pompón sizzle amarillo|O|O||D||1
10232051|Crisantemo vivo pompón bandera española|O|O||D||1
10232052|Crisantemo vivo pompón starbust o copo de nieve|O|O||D||1
10232053|Crisantemo vivo pompón cisne|O|O||D||1
10232054|Crisantemo vivo pompón tedcha anaranjado|O|O||D||1
10232055|Crisantemo vivo pompón tierno|O|O||D||1
10232056|Crisantemo vivo pompón oropel|O|O||D||1
10232057|Crisantemo vivo pompón toque|O|O||D||1
10232058|Crisantemo vivo pompón troyes|O|O||D||1
10232059|Crisantemo vivo pompón valesca|O|O||D||1
10232060|Crisantemo vivo pompón anaranjado vikingo|O|O||D||1
10232061|Crisantemo vivo pompón vikingo|O|O||D||1
10232062|Crisantemo vivo pompón reloj|O|O||D||1
10232063|Crisantemo vivo pompón aguja blanco|O|O||D||1
10232064|Crisantemo vivo pompón noche blanca|O|O||D||1
10232065|Crisantemo vivo pompón artista amarillo|O|O||D||1
10232066|Crisantemo vivo pompón ficción amarillo|O|O||D||1
10232067|Crisantemo vivo pompón sharp amarillo|O|O||D||1
10232100|Crisantemo vivo santini|O|O||D||1
10232101|Crisantemo vivo pompón alma|O|O||D||1
10232102|Crisantemo vivo pompón barón|O|O||D||1
10232103|Crisantemo vivo pompón bernardo|O|O||D||1
10232104|Crisantemo vivo pompón bistro|O|O||D||1
10232105|Crisantemo vivo pompón bodega|O|O||D||1
10232106|Crisantemo vivo pompón brisa|O|O||D||1
10232107|Crisantemo vivo pompón centella bronce|O|O||D||1
10232108|Crisantemo vivo pompón costa blanca|O|O||D||1
10232109|Crisantemo vivo pompón creta|O|O||D||1
10232110|Crisantemo vivo pompón deliflame|O|O||D||1
10232111|Crisantemo vivo pompón dalila|O|O||D||1
10232112|Crisantemo vivo pompón dígito|O|O||D||1
10232113|Crisantemo vivo pompón evilio|O|O||D||1
10232114|Crisantemo vivo pompón furense|O|O||D||1
10232115|Crisantemo vivo pompón guía|O|O||D||1
10232116|Crisantemo vivo pompón kerry|O|O||D||1
10232117|Crisantemo vivo pompón kess|O|O||D||1
10232118|Crisantemo vivo pompón lima|O|O||D||1
10232119|Crisantemo vivo pompón lupo|O|O||D||1
10232120|Crisantemo vivo pompón lineker anaranjado|O|O||D||1
10232121|Crisantemo vivo pompón panuco rojo|O|O||D||1
10232122|Crisantemo vivo pompón costa rosado|O|O||D||1
10232123|Crisantemo vivo pompón rafael|O|O||D||1
10232124|Crisantemo vivo pompón refine|O|O||D||1
10232125|Crisantemo vivo pompón regaliz|O|O||D||1
10232126|Crisantemo vivo pompón renella|O|O||D||1
10232127|Crisantemo vivo pompón retorno|O|O||D||1
10232128|Crisantemo vivo pompón río|O|O||D||1
10232129|Crisantemo vivo pompón sabas|O|O||D||1
10232130|Crisantemo vivo pompón target|O|O||D||1
10232131|Crisantemo vivo pompón texto|O|O||D||1
10232132|Crisantemo vivo pompón caballo amarillo|O|O||D||1
10241500|Clavel vivo de floración sencilla|O|O||D||1
10241501|Clavel vivo de floración sencilla burgundy bicolor|O|O||D||1
10241502|Clavel vivo de floración sencilla burgundy|O|O||D||1
10241503|Clavel vivo de floración sencilla cinderella|O|O||D||1
10241504|Clavel vivo de floración sencilla crema bicolor|O|O||D||1
10241505|Clavel vivo de floración sencilla crema|O|O||D||1
10241506|Clavel vivo de floración sencilla verde o prado|O|O||D||1
10241507|Clavel vivo de floración sencilla rosado fuerte|O|O||D||1
10241508|Clavel vivo de floración sencilla verde claro|O|O||D||1
10241509|Clavel vivo de floración sencilla rosado claro|O|O||D||1
10241510|Clavel vivo de floración sencilla anaranjado bicolor|O|O||D||1
10241511|Clavel vivo de floración sencilla anaranjado|O|O||D||1
10241512|Clavel vivo de floración sencilla durazno|O|O||D||1
10241513|Clavel vivo de floración sencilla menta bicolor|O|O||D||1
10241514|Clavel vivo de floración sencilla rosado bicolor|O|O||D||1
10241515|Clavel vivo de floración sencilla rosado|O|O||D||1
10241516|Clavel vivo de floración sencilla púrpura bicolor|O|O||D||1
10241517|Clavel vivo de floración sencilla rojo bicolor|O|O||D||1
10241518|Clavel vivo de floración sencilla rojo|O|O||D||1
10241519|Clavel vivo de floración sencilla blanco|O|O||D||1
10241520|Clavel vivo de floración sencilla amarillo|O|O||D||1
10241600|Clavel vivo mini o spray|O|O||D||1
10241601|Clavel vivo mini o spray burgundy|O|O||D||1
10241602|Clavel vivo mini o spray crema|O|O||D||1
10241603|Clavel vivo mini o spray rosado fuerte|O|O||D||1
10241604|Clavel vivo mini o spray lavanda|O|O||D||1
10241605|Clavel vivo mini o spray rosado claro|O|O||D||1
10241606|Clavel vivo mini o spray anaranjado|O|O||D||1
10241607|Clavel vivo mini o spray durazno|O|O||D||1
10241608|Clavel vivo mini o spray menta|O|O||D||1
10241609|Clavel vivo mini o spray rosado|O|O||D||1
10241610|Clavel vivo mini o spray púrpura bicolor|O|O||D||1
10241611|Clavel vivo mini o spray púrpura|O|O||D||1
10241612|Clavel vivo mini o spray rojo|O|O||D||1
10241613|Clavel vivo mini o spray blanco|O|O||D||1
10241614|Clavel vivo mini o spray amarillo|O|O||D||1
10251500|Orquidea cypripedium  o pantuflas de dama viva|O|O||D||1
10251501|Orquidea cypripedium viva verde|O|O||D||1
10251502|Orquidea cypripedium viva francia|O|O||D||1
10251503|Orquidea cypripedium viva púrpura rey arturo|O|O||D||1
10251504|Orquidea paphiopedilum viva verde|O|O||D||1
10251505|Orquidea aranthera maggie vie viva|O|O||D||1
10251600|Orquídea mocara viva|O|O||D||1
10251601|Orquídea mocara viva omyai|O|O||D||1
10251602|Orquídea mocara viva roja|O|O||D||1
10251603|Orquídea mocara viva calipso|O|O||D||1
10251604|Orquídea mocara viva nora|O|O||D||1
10251605|Orquídea mocara viva panee|O|O||D||1
10251700|Orquídea catleya viva|O|O||D||1
10251701|Orquídea cattleya viva blanca|O|O||D||1
10251702|Orquídea cattleya viva r b lavanda|O|O||D||1
10251800|Orquídea disa viva|O|O||D||1
10251801|Orquídea disa viva roja|O|O||D||1
10251802|Orquídea disa viva anaranjada|O|O||D||1
10251803|Orquídea disa viva rosada|O|O||D||1
10251804|Orquídea disa viva anaranjada y amarilla bicolor|O|O||D||1
10251805|Orquídea disa viva durazno y amarilla bicolor|O|O||D||1
10251806|Orquídea disa viva amarilla y roja bicolor|O|O||D||1
10251900|Orquídea arachnis viva|O|O||D||1
10251901|Orquídea arachnis viva james storie roja|O|O||D||1
10251902|Orquídea arachnis viva maggie oei roja|O|O||D||1
10251903|Orquídea arachnis viva maggie oei amarilla|O|O||D||1
10251904|Orquídea arachnis viva maroon maggie|O|O||D||1
10251905|Orquídea arachnis viva merry maggie|O|O||D||1
10252000|Orquídea phalaenopsis viva|O|O||D||1
10252001|Orquídea phalaenopsis viva amabilis|O|O||D||1
10252002|Orquídea phalaenopsis viva amboinensis|O|O||D||1
10252003|Orquídea phalaenopsis viva afrodita|O|O||D||1
10252004|Orquídea phalaenopsis viva appendiculata|O|O||D||1
10252005|Orquídea phalaenopsis viva bastianii|O|O||D||1
10252006|Orquídea phalaenopsis viva bellina|O|O||D||1
10252007|Orquídea phalaenopsis viva borneensis|O|O||D||1
10252008|Orquídea phalaenopsis viva braceana|O|O||D||1
10252009|Orquídea phalaenopsis viva buyssoniana|O|O||D||1
10252010|Orquídea phalaenopsis viva celebensis|O|O||D||1
10252011|Orquídea phalaenopsis viva chibae|O|O||D||1
10252012|Orquídea phalaenopsis viva cochlearis|O|O||D||1
10252013|Orquídea phalaenopsis viva corningiana|O|O||D||1
10252014|Orquídea phalaenopsis viva cornu-cervi|O|O||D||1
10252015|Orquídea phalaenopsis viva deliciosa|O|O||D||1
10252016|Orquídea phalaenopsis viva doweryënsis|O|O||D||1
10252017|Orquídea phalaenopsis viva equestris|O|O||D||1
10252018|Orquídea phalaenopsis viva fasciata|O|O||D||1
10252019|Orquídea phalaenopsis viva fimbriata|O|O||D||1
10252020|Orquídea phalaenopsis viva floresensis|O|O||D||1
10252021|Orquídea phalaenopsis viva fuscata|O|O||D||1
10252022|Orquídea phalaenopsis viva gibbosa|O|O||D||1
10252023|Orquídea phalaenopsis viva hainanensis|O|O||D||1
10252024|Orquídea phalaenopsis viva hieroglyphica|O|O||D||1
10252025|Orquídea phalaenopsis viva honghenensis|O|O||D||1
10252026|Orquídea phalaenopsis viva inscriptiosinensis|O|O||D||1
10252027|Orquídea phalaenopsis viva javanica|O|O||D||1
10252028|Orquídea phalaenopsis viva kunstleri|O|O||D||1
10252029|Orquídea phalaenopsis viva lamelligera|O|O||D||1
10252030|Orquídea phalaenopsis viva lindenii|O|O||D||1
10252031|Orquídea phalaenopsis viva lobbii|O|O||D||1
10252032|Orquídea phalaenopsis viva lowii|O|O||D||1
10252033|Orquídea phalaenopsis viva lueddemanniana|O|O||D||1
10252034|Orquídea phalaenopsis viva mambo|O|O||D||1
10252035|Orquídea phalaenopsis viva luteola|O|O||D||1
10252036|Orquídea phalaenopsis viva maculata|O|O||D||1
10252037|Orquídea phalaenopsis viva malipoensis|O|O||D||1
10252038|Orquídea phalaenopsis viva mannii|O|O||D||1
10252039|Orquídea phalaenopsis viva mariae|O|O||D||1
10252040|Orquídea phalaenopsis viva micholitzii|O|O||D||1
10252041|Orquídea phalaenopsis viva modesta|O|O||D||1
10252042|Orquídea phalaenopsis viva mysorensis|O|O||D||1
10252043|Orquídea phalaenopsis viva pallens|O|O||D||1
10252044|Orquídea phalaenopsis viva pantherina|O|O||D||1
10252045|Orquídea phalaenopsis viva parishii|O|O||D||1
10252046|Orquídea phalaenopsis viva petelotii|O|O||D||1
10252047|Orquídea phalaenopsis viva philippinensis|O|O||D||1
10252048|Orquídea phalaenopsis viva pulcherrima|O|O||D||1
10252049|Orquídea phalaenopsis viva pulchra|O|O||D||1
10252050|Orquídea phalaenopsis viva regnieriana|O|O||D||1
10252051|Orquídea phalaenopsis viva reichenbachiana|O|O||D||1
10252052|Orquídea phalaenopsis viva nivacolor|O|O||D||1
10252053|Orquídea phalaenopsis viva sanderiana|O|O||D||1
10252054|Orquídea phalaenopsis viva schilleriana|O|O||D||1
10252055|Orquídea phalaenopsis viva speciosa|O|O||D||1
10252056|Orquídea phalaenopsis viva stobartiana|O|O||D||1
10252057|Orquídea phalaenopsis viva stuartiana|O|O||D||1
10252058|Orquídea phalaenopsis viva sumatrana|O|O||D||1
10252059|Orquídea phalaenopsis viva taenialis|O|O||D||1
10252060|Orquídea phalaenopsis viva tetraspis|O|O||D||1
10252061|Orquídea phalaenopsis viva venosa|O|O||D||1
10252062|Orquídea phalaenopsis viva violácea|O|O||D||1
10252063|Orquídea phalaenopsis viva viridis|O|O||D||1
10252064|Orquídea phalaenopsis viva wilsonii|O|O||D||1
10252065|Orquídea phalaenopsis viva zebrina|O|O||D||1
10252067|Orquídea phalaenopsis viva labio lavanda|O|O||D||1
10252100|Orquídea dendrobium viva|O|O||D||1
10252101|Orquídea dendrobium viva bom|O|O||D||1
10252102|Orquídea dendrobium viva burana|O|O||D||1
10252103|Orquídea dendrobium viva chita|O|O||D||1
10252104|Orquídea dendrobium viva fátima|O|O||D||1
10252105|Orquídea dendrobium viva intuwong|O|O||D||1
10252106|Orquídea dendrobium viva jumbo blanca|O|O||D||1
10252107|Orquídea dendrobium viva kating dang|O|O||D||1
10252108|Orquídea dendrobium viva libertad|O|O||D||1
10252109|Orquídea dendrobium viva hawaii|O|O||D||1
10252110|Orquídea dendrobium viva sakura sweet rosada|O|O||D||1
10252111|Orquídea dendrobium viva sensacional púrpura|O|O||D||1
10252112|Orquídea dendrobium viva blanca|O|O||D||1
10252200|Orquídea cymbidium viva|O|O||D||1
10252201|Orquídea cymbidium viva crema|O|O||D||1
10252202|Orquídea cymbidium viva verde|O|O||D||1
10252203|Orquídea cymbidium viva mini verde|O|O||D||1
10252204|Orquídea cymbidium viva mini rosada|O|O||D||1
10252205|Orquídea cymbidium viva mini roja|O|O||D||1
10252206|Orquídea cymbidium viva mini blanca|O|O||D||1
10252207|Orquídea cymbidium viva mini amarilla|O|O||D||1
10252208|Orquídea cymbidium viva chocolate|O|O||D||1
10252209|Orquídea cymbidium viva rosado oscuro|O|O||D||1
10252210|Orquídea cymbidium viva anaranjada|O|O||D||1
10252211|Orquídea cymbidium viva rosada|O|O||D||1
10252212|Orquídea cymbidium viva blanca|O|O||D||1
10252213|Orquídea cymbidium viva amarilla|O|O||D||1
10252300|Orquídea oncidium viva|O|O||D||1
10252301|Orquídea oncidium viva ducha dorada|O|O||D||1
10252302|Orquídea oncidium viva rhamsey|O|O||D||1
10252400|Orquídea vanda viva|O|O||D||1
10252401|Orquídea vanda alizarin|O|O||D||1
10252402|Orquídea vanda rosada fuerte|O|O||D||1
10252403|Orquídea vanda lavanda|O|O||D||1
10252404|Orquídea vanda púrpura|O|O||D||1
10252405|Orquídea vanda hazme cosquillas rosada|O|O||D||1
10252406|Orquídea vanda amarilla|O|O||D||1
10301500|Rosas cortadas frescas azules o lavanda o púrpura|O|O||D||1
10301501|Rosal cortado fresco allure o sterling 95|O|O||D||1
10301502|Rosal cortado fresco amnesia|O|O||D||1
10301503|Rosal cortado fresco augusta louise|O|O||D||1
10301504|Rosal cortado fresco avant garde|O|O||D||1
10301505|Rosal cortado fresco blue bird|O|O||D||1
10301506|Rosal cortado fresco curiosa|O|O||D||1
10301507|Rosal cortado fresco cool water|O|O||D||1
10301508|Rosal cortado fresco delilah|O|O||D||1
10301509|Rosal cortado fresco double party|O|O||D||1
10301510|Rosal cortado fresco faith|O|O||D||1
10301511|Rosal cortado fresco mami blue o mammy blue|O|O||D||1
10301512|Rosal cortado fresco maritime|O|O||D||1
10301513|Rosal cortado fresco milano|O|O||D||1
10301514|Rosal cortado fresco mistery|O|O||D||1
10301515|Rosal cortado fresco ocean song o boyfriend|O|O||D||1
10301516|Rosal cortado fresco cezanne púrpura|O|O||D||1
10301517|Rosal cortado fresco purple fragrance|O|O||D||1
10301518|Rosal cortado fresco sanaa|O|O||D||1
10301519|Rosal cortado fresco silverstone|O|O||D||1
10301520|Rosal cortado fresco soulmate|O|O||D||1
10301521|Rosal cortado fresco stranger|O|O||D||1
10301522|Rosal cortado fresco tinted blue|O|O||D||1
10301523|Rosal cortado fresco two faces|O|O||D||1
10301600|Rosas cortadas frescas chocolate o marrón|O|O||D||1
10301601|Rosal cortado fresco black lava|O|O||D||1
10301602|Rosal cortado fresco cimarrón|O|O||D||1
10301603|Rosal cortado fresco coffee break|O|O||D||1
10301604|Rosal cortado fresco estelle|O|O||D||1
10301605|Rosal cortado fresco gypsy leonidas|O|O||D||1
10301606|Rosal cortado fresco leonidas|O|O||D||1
10301607|Rosal cortado fresco matilda|O|O||D||1
10301608|Rosal cortado fresco sunny leonidas|O|O||D||1
10301609|Rosal cortado fresco terra nostra|O|O||D||1
10301610|Rosal cortado fresco terracotta|O|O||D||1
10301700|Rosas cortadas frescas crema|O|O||D||1
10301701|Rosal cortado fresco advenire|O|O||D||1
10301702|Rosal cortado fresco alex|O|O||D||1
10301703|Rosal cortado fresco antique brass|O|O||D||1
10301704|Rosal cortado fresco aubade|O|O||D||1
10301705|Rosal cortado fresco beach|O|O||D||1
10301706|Rosal cortado fresco belle pearl|O|O||D||1
10301707|Rosal cortado fresco blush o blush de los andes|O|O||D||1
10301708|Rosal cortado fresco camel|O|O||D||1
10301709|Rosal cortado fresco caramel antike o caramel antique|O|O||D||1
10301710|Rosal cortado fresco champagne|O|O||D||1
10301711|Rosal cortado fresco clear ocean|O|O||D||1
10301712|Rosal cortado fresco combo|O|O||D||1
10301713|Rosal cortado fresco creme de la creme|O|O||D||1
10301714|Rosal cortado fresco emanuella|O|O||D||1
10301715|Rosal cortado fresco evolution|O|O||D||1
10301716|Rosal cortado fresco fedora|O|O||D||1
10301717|Rosal cortado fresco fenice|O|O||D||1
10301718|Rosal cortado fresco french vanilla|O|O||D||1
10301719|Rosal cortado fresco hollywood|O|O||D||1
10301720|Rosal cortado fresco ilios|O|O||D||1
10301721|Rosal cortado fresco jelena|O|O||D||1
10301722|Rosal cortado fresco kameleon|O|O||D||1
10301723|Rosal cortado fresco kentucky|O|O||D||1
10301724|Rosal cortado fresco kings pride|O|O||D||1
10301725|Rosal cortado fresco latin fusion|O|O||D||1
10301726|Rosal cortado fresco lemon dream|O|O||D||1
10301727|Rosal cortado fresco magic moka|O|O||D||1
10301728|Rosal cortado fresco mama mia|O|O||D||1
10301729|Rosal cortado fresco message|O|O||D||1
10301730|Rosal cortado fresco muñeca o munieca|O|O||D||1
10301731|Rosal cortado fresco parfum de rosas|O|O||D||1
10301732|Rosal cortado fresco porcelina|O|O||D||1
10301733|Rosal cortado fresco privilege|O|O||D||1
10301734|Rosal cortado fresco quick sand|O|O||D||1
10301735|Rosal cortado fresco rollercoaster|O|O||D||1
10301736|Rosal cortado fresco romantic curiosa|O|O||D||1
10301737|Rosal cortado fresco safari|O|O||D||1
10301738|Rosal cortado fresco sahara|O|O||D||1
10301739|Rosal cortado fresco sandy femma|O|O||D||1
10301740|Rosal cortado fresco talea|O|O||D||1
10301741|Rosal cortado fresco timeless|O|O||D||1
10301742|Rosal cortado fresco transition|O|O||D||1
10301743|Rosal cortado fresco trump|O|O||D||1
10301744|Rosal cortado fresco twin|O|O||D||1
10301745|Rosal cortado fresco vendela|O|O||D||1
10301746|Rosal cortado fresco virginia|O|O||D||1
10301800|Rosas cortadas frescas verdes o lima|O|O||D||1
10301801|Rosal cortado fresco amandina|O|O||D||1
10301802|Rosal cortado fresco caipirinha|O|O||D||1
10301803|Rosal cortado fresco green fashion|O|O||D||1
10301804|Rosal cortado fresco green tea|O|O||D||1
10301805|Rosal cortado fresco jade|O|O||D||1
10301806|Rosal cortado fresco limbo|O|O||D||1
10301807|Rosal cortado fresco limeña o limenia|O|O||D||1
10301808|Rosal cortado fresco limona|O|O||D||1
10301809|Rosal cortado fresco old dutch|O|O||D||1
10301810|Rosal cortado fresco super green|O|O||D||1
10301811|Rosal cortado fresco sweet green|O|O||D||1
10301812|Rosal cortado fresco cortada fresca|O|O||D||1
10301813|Rosal cortado fresco zazu|O|O||D||1
10301900|Rosas cortadas frescas rosado claro|O|O||D||1
10301901|Rosal cortado fresco anna|O|O||D||1
10301902|Rosal cortado fresco bella vita|O|O||D||1
10301903|Rosal cortado fresco bridal dream|O|O||D||1
10301904|Rosal cortado fresco candy bianca|O|O||D||1
10301905|Rosal cortado fresco caress|O|O||D||1
10301906|Rosal cortado fresco carolina|O|O||D||1
10301907|Rosal cortado fresco climax|O|O||D||1
10301908|Rosal cortado fresco danny|O|O||D||1
10301909|Rosal cortado fresco dolce vita|O|O||D||1
10301910|Rosal cortado fresco elite|O|O||D||1
10301911|Rosal cortado fresco emma|O|O||D||1
10301912|Rosal cortado fresco engagement|O|O||D||1
10301913|Rosal cortado fresco esther|O|O||D||1
10301914|Rosal cortado fresco excalibur|O|O||D||1
10301915|Rosal cortado fresco exciting|O|O||D||1
10301916|Rosal cortado fresco first lady|O|O||D||1
10301917|Rosal cortado fresco geraldine|O|O||D||1
10301918|Rosal cortado fresco gotcha|O|O||D||1
10301919|Rosal cortado fresco harmonie|O|O||D||1
10301920|Rosal cortado fresco heaven|O|O||D||1
10301921|Rosal cortado fresco high and elegant|O|O||D||1
10301922|Rosal cortado fresco katherine|O|O||D||1
10301923|Rosal cortado fresco king kong|O|O||D||1
10301924|Rosal cortado fresco livia|O|O||D||1
10301925|Rosal cortado fresco lorena|O|O||D||1
10301926|Rosal cortado fresco lovely|O|O||D||1
10301927|Rosal cortado fresco maaike|O|O||D||1
10301928|Rosal cortado fresco marilyn|O|O||D||1
10301929|Rosal cortado fresco marlise|O|O||D||1
10301930|Rosal cortado fresco miranda o ausimmon|O|O||D||1
10301931|Rosal cortado fresco mona lisa|O|O||D||1
10301932|Rosal cortado fresco nirvana|O|O||D||1
10301933|Rosal cortado fresco o’hara|O|O||D||1
10301934|Rosal cortado fresco ole|O|O||D||1
10301935|Rosal cortado fresco olga|O|O||D||1
10301936|Rosal cortado fresco pacífica|O|O||D||1
10301937|Rosal cortado fresco party mix|O|O||D||1
10301938|Rosal cortado fresco pekoubo o pekcoubo|O|O||D||1
10301939|Rosal cortado fresco phoebe o ausnotice|O|O||D||1
10301940|Rosal cortado fresco pink farfalla|O|O||D||1
10301941|Rosal cortado fresco pink finess|O|O||D||1
10301942|Rosal cortado fresco pink magic|O|O||D||1
10301943|Rosal cortado fresco pink osiana|O|O||D||1
10301944|Rosal cortado fresco pretty woman|O|O||D||1
10301945|Rosal cortado fresco romance|O|O||D||1
10301946|Rosal cortado fresco romantic antike o antique|O|O||D||1
10301947|Rosal cortado fresco rosalind o astew|O|O||D||1
10301948|Rosal cortado fresco rosita vendela|O|O||D||1
10301949|Rosal cortado fresco secret garden|O|O||D||1
10301950|Rosal cortado fresco solaire|O|O||D||1
10301951|Rosal cortado fresco sophie|O|O||D||1
10301952|Rosal cortado fresco sweet akito|O|O||D||1
10301953|Rosal cortado fresco sweet avalanche|O|O||D||1
10301954|Rosal cortado fresco sweet elegance|O|O||D||1
10301955|Rosal cortado fresco sweet pink|O|O||D||1
10301956|Rosal cortado fresco titanic|O|O||D||1
10301957|Rosal cortado fresco toscanini|O|O||D||1
10301958|Rosal cortado fresco vania|O|O||D||1
10301959|Rosal cortado fresco vanity|O|O||D||1
10301960|Rosal cortado fresco vision|O|O||D||1
10301961|Rosal cortado fresco vivaldi|O|O||D||1
10301962|Rosal cortado fresco whisper|O|O||D||1
10302000|Rosas cortadas frescas multicolor rosados|O|O||D||1
10302001|Rosal cortado fresco attracta|O|O||D||1
10302002|Rosal cortado fresco boheme|O|O||D||1
10302003|Rosal cortado fresco carousel|O|O||D||1
10302004|Rosal cortado fresco cezanne|O|O||D||1
10302005|Rosal cortado fresco crazy one|O|O||D||1
10302006|Rosal cortado fresco dance valley|O|O||D||1
10302007|Rosal cortado fresco duett|O|O||D||1
10302008|Rosal cortado fresco esperance|O|O||D||1
10302009|Rosal cortado fresco fiesta|O|O||D||1
10302010|Rosal cortado fresco halloween|O|O||D||1
10302011|Rosal cortado fresco highlander|O|O||D||1
10302012|Rosal cortado fresco hot ambiance|O|O||D||1
10302013|Rosal cortado fresco la belle|O|O||D||1
10302014|Rosal cortado fresco laguna|O|O||D||1
10302015|Rosal cortado fresco latin ambiance|O|O||D||1
10302016|Rosal cortado fresco latin breeze|O|O||D||1
10302017|Rosal cortado fresco long arifa|O|O||D||1
10302018|Rosal cortado fresco murano|O|O||D||1
10302019|Rosal cortado fresco n – joy rose|O|O||D||1
10302020|Rosal cortado fresco panama|O|O||D||1
10302021|Rosal cortado fresco peppermint|O|O||D||1
10302022|Rosal cortado fresco pujama party|O|O||D||1
10302023|Rosal cortado fresco portofino|O|O||D||1
10302024|Rosal cortado fresco priceless|O|O||D||1
10302025|Rosal cortado fresco queen amazon|O|O||D||1
10302026|Rosal cortado fresco ranuncula|O|O||D||1
10302027|Rosal cortado fresco rossini|O|O||D||1
10302028|Rosal cortado fresco sabina o sabrina|O|O||D||1
10302029|Rosal cortado fresco scandal|O|O||D||1
10302030|Rosal cortado fresco silvery pink|O|O||D||1
10302031|Rosal cortado fresco something else|O|O||D||1
10302032|Rosal cortado fresco southine|O|O||D||1
10302033|Rosal cortado fresco sovereign|O|O||D||1
10302034|Rosal cortado fresco super disco|O|O||D||1
10302035|Rosal cortado fresco ts 1968|O|O||D||1
10302036|Rosal cortado fresco variance|O|O||D||1
10302037|Rosal cortado fresco verdi|O|O||D||1
10302100|Rosas cortadas frescas anaranjados|O|O||D||1
10302101|Rosal cortado fresco alhambra|O|O||D||1
10302102|Rosal cortado fresco aloha|O|O||D||1
10302103|Rosal cortado fresco amber|O|O||D||1
10302104|Rosal cortado fresco apache|O|O||D||1
10302105|Rosal cortado fresco arabia|O|O||D||1
10302106|Rosal cortado fresco bengala|O|O||D||1
10302107|Rosal cortado fresco bibi|O|O||D||1
10302108|Rosal cortado fresco caramba|O|O||D||1
10302109|Rosal cortado fresco caramella|O|O||D||1
10302110|Rosal cortado fresco carla|O|O||D||1
10302111|Rosal cortado fresco cartagena|O|O||D||1
10302112|Rosal cortado fresco chanson|O|O||D||1
10302113|Rosal cortado fresco charmer|O|O||D||1
10302114|Rosal cortado fresco cherry brandy|O|O||D||1
10302115|Rosal cortado fresco chilis|O|O||D||1
10302116|Rosal cortado fresco cinnamon|O|O||D||1
10302117|Rosal cortado fresco colandro|O|O||D||1
10302118|Rosal cortado fresco coral sea|O|O||D||1
10302119|Rosal cortado fresco corvette o red covette|O|O||D||1
10302120|Rosal cortado fresco dark milva|O|O||D||1
10302121|Rosal cortado fresco donna|O|O||D||1
10302122|Rosal cortado fresco dreamer|O|O||D||1
10302123|Rosal cortado fresco el dorado|O|O||D||1
10302124|Rosal cortado fresco el toro|O|O||D||1
10302125|Rosal cortado fresco elena|O|O||D||1
10302126|Rosal cortado fresco ensueño|O|O||D||1
10302127|Rosal cortado fresco euforia|O|O||D||1
10302128|Rosal cortado fresco exótica|O|O||D||1
10302129|Rosal cortado fresco fancy amazon|O|O||D||1
10302130|Rosal cortado fresco fiction|O|O||D||1
10302131|Rosal cortado fresco finess|O|O||D||1
10302132|Rosal cortado fresco flameco|O|O||D||1
10302133|Rosal cortado fresco free spirit|O|O||D||1
10302134|Rosal cortado fresco gelato|O|O||D||1
10302135|Rosal cortado fresco gypsy curiosa|O|O||D||1
10302136|Rosal cortado fresco high and magic|O|O||D||1
10302137|Rosal cortado fresco high and orange|O|O||D||1
10302138|Rosal cortado fresco iguana o alegra|O|O||D||1
10302139|Rosal cortado fresco impulse|O|O||D||1
10302140|Rosal cortado fresco indian femma|O|O||D||1
10302141|Rosal cortado fresco indian sunset|O|O||D||1
10302142|Rosal cortado fresco karusso|O|O||D||1
10302143|Rosal cortado fresco kerio|O|O||D||1
10302144|Rosal cortado fresco kiki|O|O||D||1
10302145|Rosal cortado fresco latin circus|O|O||D||1
10302146|Rosal cortado fresco leonisa|O|O||D||1
10302147|Rosal cortado fresco lipstick|O|O||D||1
10302148|Rosal cortado fresco lobita|O|O||D||1
10302149|Rosal cortado fresco lica|O|O||D||1
10302150|Rosal cortado fresco manitou|O|O||D||1
10302151|Rosal cortado fresco mariana|O|O||D||1
10302152|Rosal cortado fresco marjan o pk sensation|O|O||D||1
10302153|Rosal cortado fresco milonga|O|O||D||1
10302154|Rosal cortado fresco milva|O|O||D||1
10302155|Rosal cortado fresco miracle|O|O||D||1
10302156|Rosal cortado fresco mirage|O|O||D||1
10302157|Rosal cortado fresco monte carlo|O|O||D||1
10302158|Rosal cortado fresco movie star|O|O||D||1
10302159|Rosal cortado fresco nikita|O|O||D||1
10302160|Rosal cortado fresco orange flame|O|O||D||1
10302161|Rosal cortado fresco orange france|O|O||D||1
10302162|Rosal cortado fresco orange intuition|O|O||D||1
10302163|Rosal cortado fresco orange unique|O|O||D||1
10302164|Rosal cortado fresco orangine u orangina|O|O||D||1
10302165|Rosal cortado fresco papaya|O|O||D||1
10302166|Rosal cortado fresco pareo|O|O||D||1
10302167|Rosal cortado fresco peach|O|O||D||1
10302168|Rosal cortado fresco queensday|O|O||D||1
10302169|Rosal cortado fresco rosselle|O|O||D||1
10302170|Rosal cortado fresco royal circus|O|O||D||1
10302171|Rosal cortado fresco sari|O|O||D||1
10302172|Rosal cortado fresco sensual|O|O||D||1
10302173|Rosal cortado fresco soap|O|O||D||1
10302174|Rosal cortado fresco sombrero|O|O||D||1
10302175|Rosal cortado fresco spicy|O|O||D||1
10302176|Rosal cortado fresco estrella 2000|O|O||D||1
10302177|Rosal cortado fresco summer versilia|O|O||D||1
10302178|Rosal cortado fresco trixx|O|O||D||1
10302179|Rosal cortado fresco tropical amazon|O|O||D||1
10302180|Rosal cortado fresco utopia|O|O||D||1
10302181|Rosal cortado fresco valentine|O|O||D||1
10302182|Rosal cortado fresco verano|O|O||D||1
10302183|Rosal cortado fresco versilia|O|O||D||1
10302184|Rosal cortado fresco voodoo|O|O||D||1
10302185|Rosal cortado fresco wow|O|O||D||1
10302186|Rosal cortado fresco yabadabadoo|O|O||D||1
10302200|Rosas cortadas frescas durazno|O|O||D||1
10302201|Rosal cortado fresco alejandra|O|O||D||1
10302202|Rosal cortado fresco azafrán|O|O||D||1
10302203|Rosal cortado fresco big fun|O|O||D||1
10302204|Rosal cortado fresco cabaret|O|O||D||1
10302205|Rosal cortado fresco capuccino|O|O||D||1
10302206|Rosal cortado fresco carpe diem|O|O||D||1
10302207|Rosal cortado fresco cosima|O|O||D||1
10302208|Rosal cortado fresco cumbia|O|O||D||1
10302209|Rosal cortado fresco dream|O|O||D||1
10302210|Rosal cortado fresco época|O|O||D||1
10302211|Rosal cortado fresco fado|O|O||D||1
10302212|Rosal cortado fresco femma|O|O||D||1
10302213|Rosal cortado fresco guajira|O|O||D||1
10302214|Rosal cortado fresco high and arena|O|O||D||1
10302215|Rosal cortado fresco high and dandy|O|O||D||1
10302216|Rosal cortado fresco high and lucky|O|O||D||1
10302217|Rosal cortado fresco high and peach|O|O||D||1
10302218|Rosal cortado fresco imagination|O|O||D||1
10302219|Rosal cortado fresco isis|O|O||D||1
10302220|Rosal cortado fresco joy o light versilia|O|O||D||1
10302221|Rosal cortado fresco juliet ausjameson|O|O||D||1
10302222|Rosal cortado fresco la parisienne|O|O||D||1
10302223|Rosal cortado fresco la perla|O|O||D||1
10302224|Rosal cortado fresco lovita sunblaze|O|O||D||1
10302225|Rosal cortado fresco malilena o marilena|O|O||D||1
10302226|Rosal cortado fresco monyna|O|O||D||1
10302227|Rosal cortado fresco nectarine|O|O||D||1
10302228|Rosal cortado fresco oriental curiosa|O|O||D||1
10302229|Rosal cortado fresco osiana|O|O||D||1
10302230|Rosal cortado fresco preach avalanche|O|O||D||1
10302231|Rosal cortado fresco peach deja vu|O|O||D||1
10302232|Rosal cortado fresco picanto|O|O||D||1
10302233|Rosal cortado fresco prima donna|O|O||D||1
10302234|Rosal cortado fresco sheril|O|O||D||1
10302235|Rosal cortado fresco sirocco|O|O||D||1
10302236|Rosal cortado fresco tamara|O|O||D||1
10302237|Rosal cortado fresco taxo|O|O||D||1
10302238|Rosal cortado fresco trust|O|O||D||1
10302239|Rosal cortado fresco valencia|O|O||D||1
10302240|Rosal cortado fresco cinci|O|O||D||1
10302241|Rosal cortado fresco wanda|O|O||D||1
10302300|Rosas cortadas frescas rosados|O|O||D||1
10302301|Rosal cortado fresco aerobic|O|O||D||1
10302302|Rosal cortado fresco after party|O|O||D||1
10302303|Rosal cortado fresco amsterdam|O|O||D||1
10302304|Rosal cortado fresco aqua rose|O|O||D||1
10302305|Rosal cortado fresco attache|O|O||D||1
10302306|Rosal cortado fresco attitude|O|O||D||1
10302307|Rosal cortado fresco ballet|O|O||D||1
10302308|Rosal cortado fresco belami|O|O||D||1
10302309|Rosal cortado fresco bella voo o belle vue|O|O||D||1
10302310|Rosal cortado fresco bling bling|O|O||D||1
10302311|Rosal cortado fresco blushing akito|O|O||D||1
10302312|Rosal cortado fresco brooke|O|O||D||1
10302313|Rosal cortado fresco bugatti|O|O||D||1
10302314|Rosal cortado fresco cadillac|O|O||D||1
10302315|Rosal cortado fresco carnaval|O|O||D||1
10302316|Rosal cortado fresco cereza|O|O||D||1
10302317|Rosal cortado fresco charming|O|O||D||1
10302318|Rosal cortado fresco cherry o|O|O||D||1
10302319|Rosal cortado fresco ciciolina|O|O||D||1
10302320|Rosal cortado fresco classic cezanne|O|O||D||1
10302321|Rosal cortado fresco clasic duett|O|O||D||1
10302322|Rosal cortado fresco cosmiq|O|O||D||1
10302323|Rosal cortado fresco dark engagement|O|O||D||1
10302324|Rosal cortado fresco daytona|O|O||D||1
10302325|Rosal cortado fresco dekora|O|O||D||1
10302326|Rosal cortado fresco dolores|O|O||D||1
10302327|Rosal cortado fresco eliza|O|O||D||1
10302328|Rosal cortado fresco baccara|O|O||D||1
10302329|Rosal cortado fresco full house|O|O||D||1
10302330|Rosal cortado fresco funky|O|O||D||1
10302331|Rosal cortado fresco giliane|O|O||D||1
10302332|Rosal cortado fresco gran europe|O|O||D||1
10302333|Rosal cortado fresco habari|O|O||D||1
10302334|Rosal cortado fresco hanseat|O|O||D||1
10302335|Rosal cortado fresco high and amazing|O|O||D||1
10302336|Rosal cortado fresco high and bonita|O|O||D||1
10302337|Rosal cortado fresco high and booming|O|O||D||1
10302338|Rosal cortado fresco high and fantasy|O|O||D||1
10302339|Rosal cortado fresco high and rich|O|O||D||1
10302340|Rosal cortado fresco hot lady|O|O||D||1
10302341|Rosal cortado fresco hot princess|O|O||D||1
10302342|Rosal cortado fresco inspiration|O|O||D||1
10302343|Rosal cortado fresco jeimy|O|O||D||1
10302344|Rosal cortado fresco kachita|O|O||D||1
10302345|Rosal cortado fresco karen|O|O||D||1
10302346|Rosal cortado fresco kenji|O|O||D||1
10302347|Rosal cortado fresco kiko|O|O||D||1
10302348|Rosal cortado fresco laser|O|O||D||1
10302349|Rosal cortado fresco latin duett|O|O||D||1
10302350|Rosal cortado fresco latin fever|O|O||D||1
10302351|Rosal cortado fresco lifestyle|O|O||D||1
10302352|Rosal cortado fresco light orlando|O|O||D||1
10302353|Rosal cortado fresco lovely dreams|O|O||D||1
10302354|Rosal cortado fresco loyalty|O|O||D||1
10302355|Rosal cortado fresco malibu|O|O||D||1
10302356|Rosal cortado fresco mata – hari|O|O||D||1
10302357|Rosal cortado fresco memphis|O|O||D||1
10302358|Rosal cortado fresco mi amor|O|O||D||1
10302359|Rosal cortado fresco miami|O|O||D||1
10302360|Rosal cortado fresco michelle|O|O||D||1
10302361|Rosal cortado fresco mikaela|O|O||D||1
10302362|Rosal cortado fresco orchestra|O|O||D||1
10302363|Rosal cortado fresco orlando|O|O||D||1
10302364|Rosal cortado fresco osadia|O|O||D||1
10302365|Rosal cortado fresco paeonia freelander|O|O||D||1
10302366|Rosal cortado fresco paula|O|O||D||1
10302367|Rosal cortado fresco pavarotti|O|O||D||1
10302368|Rosal cortado fresco pink intuition|O|O||D||1
10302369|Rosal cortado fresco poison|O|O||D||1
10302370|Rosal cortado fresco princess|O|O||D||1
10302371|Rosal cortado fresco queen mary|O|O||D||1
10302372|Rosal cortado fresco raphaela|O|O||D||1
10302373|Rosal cortado fresco raspberry|O|O||D||1
10302374|Rosal cortado fresco ravel|O|O||D||1
10302375|Rosal cortado fresco riviera|O|O||D||1
10302376|Rosal cortado fresco sade|O|O||D||1
10302377|Rosal cortado fresco sashimi|O|O||D||1
10302378|Rosal cortado fresco shanya|O|O||D||1
10302379|Rosal cortado fresco shocking versilia|O|O||D||1
10302380|Rosal cortado fresco solitaire|O|O||D||1
10302381|Rosal cortado fresco something different|O|O||D||1
10302382|Rosal cortado fresco splendid renate|O|O||D||1
10302383|Rosal cortado fresco star|O|O||D||1
10302384|Rosal cortado fresco sweet candia|O|O||D||1
10302385|Rosal cortado fresco sweet moments|O|O||D||1
10302386|Rosal cortado fresco sweet unique|O|O||D||1
10302387|Rosal cortado fresco taboo|O|O||D||1
10302388|Rosal cortado fresco timona|O|O||D||1
10302389|Rosal cortado fresco topaz|O|O||D||1
10302390|Rosal cortado fresco vogue|O|O||D||1
10302391|Rosal cortado fresco voila|O|O||D||1
10302392|Rosal cortado fresco wild|O|O||D||1
10302393|Rosal cortado fresco yves piaget|O|O||D||1
10302400|Rosas cortadas frescas rojos o burgundy|O|O||D||1
10302401|Rosal cortado fresco african dawn|O|O||D||1
10302402|Rosal cortado fresco amada|O|O||D||1
10302403|Rosal cortado fresco black baccara|O|O||D||1
10302404|Rosal cortado fresco black beauty|O|O||D||1
10302405|Rosal cortado fresco black finess o black magic|O|O||D||1
10302406|Rosal cortado fresco black magic|O|O||D||1
10302407|Rosal cortado fresco bohemian o pasarela|O|O||D||1
10302408|Rosal cortado fresco breathless|O|O||D||1
10302409|Rosal cortado fresco caballero|O|O||D||1
10302410|Rosal cortado fresco carrera|O|O||D||1
10302411|Rosal cortado fresco charlene|O|O||D||1
10302412|Rosal cortado fresco charlotte|O|O||D||1
10302413|Rosal cortado fresco cherry lady|O|O||D||1
10302414|Rosal cortado fresco cherry love|O|O||D||1
10302415|Rosal cortado fresco classy rose|O|O||D||1
10302416|Rosal cortado fresco colorado velvet|O|O||D||1
10302417|Rosal cortado fresco corazón|O|O||D||1
10302418|Rosal cortado fresco corrida|O|O||D||1
10302419|Rosal cortado fresco dynamite|O|O||D||1
10302420|Rosal cortado fresco eurored|O|O||D||1
10302421|Rosal cortado fresco fashion|O|O||D||1
10302422|Rosal cortado fresco fire and ice|O|O||D||1
10302423|Rosal cortado fresco first red|O|O||D||1
10302424|Rosal cortado fresco forever young|O|O||D||1
10302425|Rosal cortado fresco freedom|O|O||D||1
10302426|Rosal cortado fresco freestyle|O|O||D||1
10302427|Rosal cortado fresco friendship|O|O||D||1
10302428|Rosal cortado fresco gospel|O|O||D||1
10302429|Rosal cortado fresco graffity|O|O||D||1
10302430|Rosal cortado fresco grand gala|O|O||D||1
10302431|Rosal cortado fresco grand prix|O|O||D||1
10302432|Rosal cortado fresco grand classe|O|O||D||1
10302433|Rosal cortado fresco hearts|O|O||D||1
10302434|Rosal cortado fresco heat|O|O||D||1
10302435|Rosal cortado fresco hocus pocus|O|O||D||1
10302436|Rosal cortado fresco lady in red|O|O||D||1
10302437|Rosal cortado fresco latin lady|O|O||D||1
10302438|Rosal cortado fresco legend|O|O||D||1
10302439|Rosal cortado fresco lulu|O|O||D||1
10302440|Rosal cortado fresco luna rossa|O|O||D||1
10302441|Rosal cortado fresco luxor|O|O||D||1
10302442|Rosal cortado fresco madame delbard o carola|O|O||D||1
10302443|Rosal cortado fresco miss paris|O|O||D||1
10302444|Rosal cortado fresco nicole|O|O||D||1
10302445|Rosal cortado fresco night fever|O|O||D||1
10302446|Rosal cortado fresco obsession|O|O||D||1
10302447|Rosal cortado fresco opium|O|O||D||1
10302448|Rosal cortado fresco paz|O|O||D||1
10302449|Rosal cortado fresco preference|O|O||D||1
10302450|Rosal cortado fresco red berlin|O|O||D||1
10302451|Rosal cortado fresco red bull|O|O||D||1
10302452|Rosal cortado fresco red calypso|O|O||D||1
10302453|Rosal cortado fresco red diamond|O|O||D||1
10302454|Rosal cortado fresco red fantasy|O|O||D||1
10302455|Rosal cortado fresco red france|O|O||D||1
10302456|Rosal cortado fresco red intuition|O|O||D||1
10302457|Rosal cortado fresco red jewel|O|O||D||1
10302458|Rosal cortado fresco red magic|O|O||D||1
10302459|Rosal cortado fresco red one|O|O||D||1
10302460|Rosal cortado fresco red paris|O|O||D||1
10302461|Rosal cortado fresco red princess|O|O||D||1
10302462|Rosal cortado fresco red sensation o colorad|O|O||D||1
10302463|Rosal cortado fresco red unique|O|O||D||1
10302464|Rosal cortado fresco rockefeller|O|O||D||1
10302465|Rosal cortado fresco romeo|O|O||D||1
10302466|Rosal cortado fresco rouge baiser|O|O||D||1
10302467|Rosal cortado fresco roulette|O|O||D||1
10302468|Rosal cortado fresco royal massai|O|O||D||1
10302469|Rosal cortado fresco royal red|O|O||D||1
10302470|Rosal cortado fresco samurai|O|O||D||1
10302471|Rosal cortado fresco sexy red|O|O||D||1
10302472|Rosal cortado fresco starfire|O|O||D||1
10302473|Rosal cortado fresco tango|O|O||D||1
10302474|Rosal cortado fresco tiger tail|O|O||D||1
10302475|Rosal cortado fresco tinto|O|O||D||1
10302476|Rosal cortado fresco top secret|O|O||D||1
10302477|Rosal cortado fresco vital|O|O||D||1
10302478|Rosal cortado fresco wisdom|O|O||D||1
10302479|Rosal cortado fresco xantia|O|O||D||1
10302480|Rosal cortado fresco xcite|O|O||D||1
10302500|Rosas cortadas frescas sweetheart|O|O||D||1|Rosas La Minuette cortadas frescas
10302501|Rosal cortado fresco burgundy sweetheart|O|O||D||1|Rosa La Minuette cortada fresca burgundy
10302502|Rosal cortado fresco cream sweetheart|O|O||D||1|Rosa La Minuette cortada fresca cream
10302503|Rosal cortado fresco hot pink sweetheart|O|O||D||1|Rosa La Minuette cortada fresca hot pink
10302504|Rosal cortado fresco lavender sweetheart|O|O||D||1|Rosa La Minuette cortada fresca lavender
10302505|Rosal cortado fresco light pink sweetheart|O|O||D||1|Rosa La Minuette cortada fresca light pink
10302506|Rosal cortado fresco orange sweetheart|O|O||D||1|Rosa La Minuette cortada fresca orange
10302507|Rosal cortado fresco peach sweetheart|O|O||D||1|Rosa La Minuette cortada fresca peach
10302508|Rosal cortado fresco red sweetheart|O|O||D||1|Rosa La Minuette cortada fresca red
10302509|Rosal cortado fresco white sweetheart|O|O||D||1|Rosa La Minuette cortada fresca white
10302510|Rosal cortado fresco yelllow sweetheart|O|O||D||1|Rosa La Minuette cortada fresca yellow
10302600|Rosas cortadas frescas blancos|O|O||D||1
10302601|Rosal cortado fresco absolut|O|O||D||1
10302602|Rosal cortado fresco aida|O|O||D||1
10302603|Rosal cortado fresco akito|O|O||D||1
10302604|Rosal cortado fresco amelia|O|O||D||1
10302605|Rosal cortado fresco anastasia|O|O||D||1
10302606|Rosal cortado fresco andean crystal|O|O||D||1
10302607|Rosal cortado fresco angel|O|O||D||1
10302608|Rosal cortado fresco annemarie|O|O||D||1
10302609|Rosal cortado fresco avalanche|O|O||D||1
10302610|Rosal cortado fresco bianca|O|O||D||1
10302611|Rosal cortado fresco blizzard|O|O||D||1
10302612|Rosal cortado fresco bridal akito|O|O||D||1
10302613|Rosal cortado fresco domenica|O|O||D||1
10302614|Rosal cortado fresco escimo|O|O||D||1
10302615|Rosal cortado fresco farfalla|O|O||D||1
10302616|Rosal cortado fresco high and peace|O|O||D||1
10302617|Rosal cortado fresco high and pure|O|O||D||1
10302618|Rosal cortado fresco inocencia o innocenti|O|O||D||1
10302619|Rosal cortado fresco ivory|O|O||D||1
10302620|Rosal cortado fresco mondial|O|O||D||1
10302621|Rosal cortado fresco mount everest|O|O||D||1
10302622|Rosal cortado fresco nova zembla|O|O||D||1
10302623|Rosal cortado fresco patience o auspator|O|O||D||1
10302624|Rosal cortado fresco polar star|O|O||D||1
10302625|Rosal cortado fresco polo|O|O||D||1
10302626|Rosal cortado fresco proud|O|O||D||1
10302627|Rosal cortado fresco snowy jewel|O|O||D||1
10302628|Rosal cortado fresco tibet|O|O||D||1
10302629|Rosal cortado fresco tineke|O|O||D||1
10302630|Rosal cortado fresco vitality|O|O||D||1
10302631|Rosal cortado fresco white cadillac|O|O||D||1
10302632|Rosal cortado fresco white dove|O|O||D||1
10302700|Rosas cortadas frescas amarillos|O|O||D||1
10302701|Rosal cortado fresco aalsmeer gold|O|O||D||1
10302702|Rosal cortado fresco alina|O|O||D||1
10302703|Rosal cortado fresco ambiance|O|O||D||1
10302704|Rosal cortado fresco aquarel|O|O||D||1
10302705|Rosal cortado fresco autumn|O|O||D||1
10302706|Rosal cortado fresco brasil|O|O||D||1
10302707|Rosal cortado fresco candle light|O|O||D||1
10302708|Rosal cortado fresco cantata o cantate|O|O||D||1
10302709|Rosal cortado fresco capriccio|O|O||D||1
10302710|Rosal cortado fresco caribbean|O|O||D||1
10302711|Rosal cortado fresco circus|O|O||D||1
10302712|Rosal cortado fresco citran|O|O||D||1
10302713|Rosal cortado fresco concorde|O|O||D||1
10302714|Rosal cortado fresco conga|O|O||D||1
10302715|Rosal cortado fresco deja vu|O|O||D||1
10302716|Rosal cortado fresco desire|O|O||D||1
10302717|Rosal cortado fresco donia sol|O|O||D||1
10302718|Rosal cortado fresco dueto|O|O||D||1
10302719|Rosal cortado fresco erin|O|O||D||1
10302720|Rosal cortado fresco exotic curiosa|O|O||D||1
10302721|Rosal cortado fresco feria|O|O||D||1
10302722|Rosal cortado fresco fire bird|O|O||D||1
10302723|Rosal cortado fresco florida|O|O||D||1
10302724|Rosal cortado fresco friendly|O|O||D||1
10302725|Rosal cortado fresco gallinda|O|O||D||1
10302726|Rosal cortado fresco geisha|O|O||D||1
10302727|Rosal cortado fresco gelbe|O|O||D||1
10302728|Rosal cortado fresco gelosia o yellow flame|O|O||D||1
10302729|Rosal cortado fresco gold rush|O|O||D||1
10302730|Rosal cortado fresco gold star|O|O||D||1
10302731|Rosal cortado fresco gold strike|O|O||D||1
10302732|Rosal cortado fresco golda|O|O||D||1
10302733|Rosal cortado fresco golden fashion|O|O||D||1
10302734|Rosal cortado fresco golden gate|O|O||D||1
10302735|Rosal cortado fresco gran dorado|O|O||D||1
10302736|Rosal cortado fresco helio|O|O||D||1
10302737|Rosal cortado fresco high and exotic|O|O||D||1
10302738|Rosal cortado fresco high and yellow|O|O||D||1
10302739|Rosal cortado fresco high and yellow magic|O|O||D||1
10302740|Rosal cortado fresco high society|O|O||D||1
10302741|Rosal cortado fresco hummer|O|O||D||1
10302742|Rosal cortado fresco idole o elle|O|O||D||1
10302743|Rosal cortado fresco inti|O|O||D||1
10302744|Rosal cortado fresco jet set|O|O||D||1
10302745|Rosal cortado fresco judy|O|O||D||1
10302746|Rosal cortado fresco jupiter|O|O||D||1
10302747|Rosal cortado fresco konfetti|O|O||D||1
10302748|Rosal cortado fresco kyara o kira|O|O||D||1
10302749|Rosal cortado fresco latin beauty|O|O||D||1
10302750|Rosal cortado fresco latin spirit|O|O||D||1
10302751|Rosal cortado fresco latina|O|O||D||1
10302752|Rosal cortado fresco lina|O|O||D||1
10302753|Rosal cortado fresco lindsey|O|O||D||1
10302754|Rosal cortado fresco male|O|O||D||1
10302755|Rosal cortado fresco marie clare|O|O||D||1
10302756|Rosal cortado fresco marisa|O|O||D||1
10302757|Rosal cortado fresco matchball|O|O||D||1
10302758|Rosal cortado fresco melon|O|O||D||1
10302759|Rosal cortado fresco mohana|O|O||D||1
10302760|Rosal cortado fresco okie dokie|O|O||D||1
10302761|Rosal cortado fresco pailine|O|O||D||1
10302762|Rosal cortado fresco parrot|O|O||D||1
10302763|Rosal cortado fresco rio d oro|O|O||D||1
10302764|Rosal cortado fresco salami|O|O||D||1
10302765|Rosal cortado fresco santa fe|O|O||D||1
10302766|Rosal cortado fresco skyline|O|O||D||1
10302767|Rosal cortado fresco sonrisa|O|O||D||1
10302768|Rosal cortado fresco star ambiance|O|O||D||1
10302769|Rosal cortado fresco starbust|O|O||D||1
10302770|Rosal cortado fresco sun king|O|O||D||1
10302771|Rosal cortado fresco sunmaster|O|O||D||1
10302772|Rosal cortado fresco sunny milva|O|O||D||1
10302773|Rosal cortado fresco sushi|O|O||D||1
10302774|Rosal cortado fresco tabasco|O|O||D||1
10302775|Rosal cortado fresco tara|O|O||D||1
10302776|Rosal cortado fresco tresor 2000|O|O||D||1
10302777|Rosal cortado fresco ooty|O|O||D||1
10302778|Rosal cortado fresco yellow coral|O|O||D||1
10302779|Rosal cortado fresco yellow finess|O|O||D||1
10302780|Rosal cortado fresco yellow submarine|O|O||D||1
10302781|Rosal cortado fresco yellow sunset|O|O||D||1
10302782|Rosal cortado fresco yelllow timeless|O|O||D||1
10302800|Rosas cortadas frescas spray|O|O||D||1
10302801|Rosal cortado fresco alegría spray|O|O||D||1
10302802|Rosal cortado fresco andrea follies|O|O||D||1
10302803|Rosal cortado fresco antara follies|O|O||D||1
10302804|Rosal cortado fresco arrow follies|O|O||D||1
10302805|Rosal cortado fresco babe spray|O|O||D||1
10302806|Rosal cortado fresco bellina collection|O|O||D||1
10302807|Rosal cortado fresco blue moon|O|O||D||1
10302808|Rosal cortado fresco chablis spray|O|O||D||1
10302809|Rosal cortado fresco cherry follies|O|O||D||1
10302810|Rosal cortado fresco chess spray|O|O||D||1
10302811|Rosal cortado fresco classic lydia spray|O|O||D||1
10302812|Rosal cortado fresco cream gracia spray|O|O||D||1
10302813|Rosal cortado fresco cream lydia srpay|O|O||D||1
10302814|Rosal cortado fresco cream sensation spray|O|O||D||1
10302815|Rosal cortado fresco cremita spray|O|O||D||1
10302816|Rosal cortado fresco diablo spray|O|O||D||1
10302817|Rosal cortado fresco electra spray|O|O||D||1
10302818|Rosal cortado fresco fire king spray|O|O||D||1
10302819|Rosal cortado fresco fleurspray|O|O||D||1
10302820|Rosal cortado fresco girlie follies spray|O|O||D||1
10302821|Rosal cortado fresco giselle follies spray|O|O||D||1
10302822|Rosal cortado fresco golden collection spray|O|O||D||1
10302823|Rosal cortado fresco golden mimi spray|O|O||D||1
10302824|Rosal cortado fresco gracia spray|O|O||D||1
10302825|Rosal cortado fresco hot majolica spray|O|O||D||1
10302826|Rosal cortado fresco hot pink follies spray|O|O||D||1
10302827|Rosal cortado fresco ilse spray|O|O||D||1
10302828|Rosal cortado fresco jelena spray|O|O||D||1
10302829|Rosal cortado fresco laminuette spray|O|O||D||1
10302830|Rosal cortado fresco lavender follies spray|O|O||D||1
10302831|Rosal cortado fresco limoncello spray|O|O||D||1
10302832|Rosal cortado fresco little silver spray|O|O||D||1
10302833|Rosal cortado fresco lovely lydia spray|O|O||D||1
10302834|Rosal cortado fresco lucy spray|O|O||D||1
10302835|Rosal cortado fresco lydia spray|O|O||D||1
10302836|Rosal cortado fresco macarena spray|O|O||D||1
10302837|Rosal cortado fresco magic sensation spray|O|O||D||1
10302838|Rosal cortado fresco majolica spray|O|O||D||1
10302839|Rosal cortado fresco mambo número 5 spray|O|O||D||1
10302840|Rosal cortado fresco mambo spray|O|O||D||1
10302841|Rosal cortado fresco marlene spray|O|O||D||1
10302842|Rosal cortado fresco mimi eden spray|O|O||D||1
10302843|Rosal cortado fresco minou spray|O|O||D||1
10302844|Rosal cortado fresco nikita spray|O|O||D||1
10302845|Rosal cortado fresco novel collection spray|O|O||D||1
10302846|Rosal cortado fresco orange success spray|O|O||D||1
10302847|Rosal cortado fresco pepita spray|O|O||D||1
10302848|Rosal cortado fresco pink flash spray|O|O||D||1
10302849|Rosal cortado fresco pink sensation spray|O|O||D||1
10302850|Rosal cortado fresco porcelina spray|O|O||D||1
10302851|Rosal cortado fresco princess spray|O|O||D||1
10302852|Rosal cortado fresco purple mikado spray|O|O||D||1
10302853|Rosal cortado fresco red angel spray|O|O||D||1
10302854|Rosal cortado fresco red collection spray|O|O||D||1
10302855|Rosal cortado fresco red hero spray|O|O||D||1
10302856|Rosal cortado fresco red mikado spray|O|O||D||1
10302857|Rosal cortado fresco red vision spray|O|O||D||1
10302858|Rosal cortado fresco ritmo spray|O|O||D||1
10302859|Rosal cortado fresco romance mikado o eva spray|O|O||D||1
10302860|Rosal cortado fresco romántica follies spray|O|O||D||1
10302861|Rosal cortado fresco rubicon spray|O|O||D||1
10302862|Rosal cortado fresco rumba spray|O|O||D||1
10302863|Rosal cortado fresco salsa spray|O|O||D||1
10302864|Rosal cortado fresco sangrita spray|O|O||D||1
10302865|Rosal cortado fresco santa bárbara spray|O|O||D||1
10302866|Rosal cortado fresco sashaba spray|O|O||D||1
10302867|Rosal cortado fresco scarlett spray|O|O||D||1
10302868|Rosal cortado fresco seline spray|O|O||D||1
10302869|Rosal cortado fresco sensation spray|O|O||D||1
10302870|Rosal cortado fresco silver collection spray|O|O||D||1
10302871|Rosal cortado fresco silver sensation spray|O|O||D||1
10302872|Rosal cortado fresco snowdance spray|O|O||D||1
10302873|Rosal cortado fresco snowflake spray|O|O||D||1
10302874|Rosal cortado fresco suncity spray|O|O||D||1
10302875|Rosal cortado fresco super nova spray|O|O||D||1
10302876|Rosal cortado fresco sweet sensation spray|O|O||D||1
10302877|Rosal cortado fresco taifun o typhoon spray|O|O||D||1
10302878|Rosal cortado fresco tamango spray|O|O||D||1
10302879|Rosal cortado fresco tanger follies spray|O|O||D||1
10302880|Rosal cortado fresco tiara spray|O|O||D||1
10302881|Rosal cortado fresco tiramisú spray|O|O||D||1
10302882|Rosal cortado fresco twinkle bride spray|O|O||D||1
10302883|Rosal cortado fresco viviane spray|O|O||D||1
10302884|Rosal cortado fresco white majolica spray|O|O||D||1
10302885|Rosal cortado fresco white mikado spray|O|O||D||1
10302886|Rosal cortado fresco xentina spray|O|O||D||1
10302887|Rosal cortado fresco yellow babe spray|O|O||D||1
10302888|Rosal cortado fresco yellow follies spray|O|O||D||1
10311500|Anturios cortados frescos|O|O||D||1|Lirios flamingo cortados frescos
10311501|Anturio cortado fresco chocolate|O|O||D||1|Lirio flamingo cortado fresco chocolate
10311502|Anturio cortado fresco rojo oscuro|O|O||D||1|Lirio flamingo cortado fresco rojo oscuro
10311503|Anturio cortado fresco verde|O|O||D||1|Lirio flamingo cortado fresco verde
10311504|Anturio cortado fresco rosado fuerte|O|O||D||1|Lirio flamingo cortado fresco rosado fuerte
10311505|Anturio cortado fresco mickey mouse|O|O||D||1|Lirio flamingo cortado fresco mickey mouse
10311506|Anturio cortado fresco obake verde y blanco|O|O||D||1|Lirio flamingo cortado fresco obake verde y blanco
10311507|Anturio cortado fresco obake rojo y verde|O|O||D||1|Lirio flamingo cortado fresco obake rojo y verde
10311508|Anturio cortado fresco anaranjado|O|O||D||1|Lirio flamingo cortado fresco anaranjado
10311509|Anturio cortado fresco durazno|O|O||D||1|Lirio flamingo cortado fresco durazno
10311510|Anturio cortado fresco picasso o pecoso|O|O||D||1|Lirio flamingo cortado fresco picasso o pecoso
10311511|Anturio cortado fresco rojo|O|O||D||1|Lirio flamingo cortado fresco rojo
10311512|Anturio cortado fresco splash|O|O||D||1|Lirio flamingo cortado fresco splash
10311513|Anturio cortado fresco tropic fire|O|O||D||1|Lirio flamingo cortado fresco tropic fire
10311514|Anturio cortado fresco verde tulipán|O|O||D||1|Lirio flamingo cortado fresco verde tulipán
10311515|Anturio cortado fresco rosado tulipán|O|O||D||1|Lirio flamingo cortado fresco rosado tulipán
10311516|Anturio cortado fresco púrpura tulipán|O|O||D||1|Lirio flamingo cortado fresco púrpura tulipán
10311517|Anturio cortado fresco rojo tulipán|O|O||D||1|Lirio flamingo cortado fresco rojo tulipán
10311518|Anturio cortado fresco blanco|O|O||D||1|Lirio flamingo cortado fresco blanco
10311519|Anturio cortado fresco blanco salvaje|O|O||D||1|Lirio flamingo cortado fresco blanco salvaje
10311600|Allium cortado fresco|O|O||D||1|Cebolletas ornamentales cortadas frescas
10311601|Allium cortado fresco ambassador|O|O||D||1|Cebolleta ornamental cortada fresca ambassador
10311602|Allium cortado fresco ampeloprasum|O|O||D||1|Cebolleta ornamental cortada fresca ampeloprasum
10311603|Allium cortado fresco bullit o drumstick|O|O||D||1|Cebolleta ornamental cortada fresca bullit o drumstick
10311604|Allium cortado fresco christophii|O|O||D||1|Cebolleta ornamental cortada fresca christophii
10311605|Allium cortado fresco cowanii|O|O||D||1|Cebolleta ornamental cortada fresca cowanii
10311606|Allium cortado fresco gigante|O|O||D||1|Cebolleta ornamental cortada fresca gigante
10311607|Allium cortado fresco gladiador|O|O||D||1|Cebolleta ornamental cortada fresca gladiador
10311608|Allium cortado fresco globemaster|O|O||D||1|Cebolleta ornamental cortada fresca globemaster
10311609|Allium cortado fresco bola de golf|O|O||D||1|Cebolleta ornamental cortada fresca bola de golf
10311610|Allium cortado fresco cabello|O|O||D||1|Cebolleta ornamental cortada fresca cabello
10311611|Allium cortado fresco rosado gigante|O|O||D||1|Cebolleta ornamental cortada fresca rosado gigante
10311612|Allium cortado fresco sensación púrpura|O|O||D||1|Cebolleta ornamental cortada fresca sensación púrpura
10311613|Allium cortado fresco sicilum hanging|O|O||D||1|Cebolleta ornamental cortada fresca sicilum hanging
10311614|Allium cortado fresco spider schubertii|O|O||D||1|Cebolleta ornamental cortada fresca spider schubertii
10311615|Allium cortado fresco spray moly|O|O||D||1|Cebolleta ornamental cortada fresca spray moly
10311616|Allium cortado fresco spray roseum|O|O||D||1|Cebolleta ornamental cortada fresca spray roseum
10311617|Allium cortado fresco tuberosum|O|O||D||1|Cebolleta ornamental cortada fresca tuberosum
10311618|Allium cortado fresco unifolium o spray|O|O||D||1|Cebolleta ornamental cortada fresca unifolium o spray
10311619|Allium cortado fresco monte everest blanco|O|O||D||1|Cebolleta ornamental cortada fresca monte everest blanco
10311700|Astromelia cortada fresca|O|O||D||1|Lirios de campo cortados frescos
10311701|Astromelia cortada fresca agropoli|O|O||D||1|Lirio de campo cortado fresco agropoli
10311702|Astromelia cortada fresca bourgogne|O|O||D||1|Lirio de campo cortado fresco bourgogne
10311703|Astromelia cortada fresca cairo|O|O||D||1|Lirio de campo cortado fresco cairo
10311704|Astromelia cortada fresca charmes|O|O||D||1|Lirio de campo cortado fresco charmes
10311705|Astromelia cortada fresca cherry bay|O|O||D||1|Lirio de campo cortado fresco cherry bay
10311706|Astromelia cortada fresca cherry white|O|O||D||1|Lirio de campo cortado fresco cherry white
10311707|Astromelia cortada fresca dame blanche|O|O||D||1|Lirio de campo cortado fresco dame blanche
10311708|Astromelia cortada fresca diamond|O|O||D||1|Lirio de campo cortado fresco diamond
10311709|Astromelia cortada fresca gran canaria|O|O||D||1|Lirio de campo cortado fresco gran canaria
10311710|Astromelia cortada fresca harlekijn|O|O||D||1|Lirio de campo cortado fresco harlekijn
10311711|Astromelia cortada fresca indian summer|O|O||D||1|Lirio de campo cortado fresco indian summer
10311712|Astromelia cortada fresca jamaica|O|O||D||1|Lirio de campo cortado fresco jamaica
10311713|Astromelia cortada fresca macondo|O|O||D||1|Lirio de campo cortado fresco macondo
10311714|Astromelia cortada fresca mistique|O|O||D||1|Lirio de campo cortado fresco mistique
10311715|Astromelia cortada fresca my fair|O|O||D||1|Lirio de campo cortado fresco my fair
10311716|Astromelia cortada fresca new cairo|O|O||D||1|Lirio de campo cortado fresco new cairo
10311717|Astromelia cortada fresca nice|O|O||D||1|Lirio de campo cortado fresco nice
10311718|Astromelia cortada fresca orange bowl|O|O||D||1|Lirio de campo cortado fresco orange bowl
10311719|Astromelia cortada fresca orange queens|O|O||D||1|Lirio de campo cortado fresco orange queens
10311720|Astromelia cortada fresca orange sun|O|O||D||1|Lirio de campo cortado fresco orange sun
10311721|Astromelia cortada fresca paris|O|O||D||1|Lirio de campo cortado fresco parís
10311722|Astromelia cortada fresca picasso|O|O||D||1|Lirio de campo cortado fresco picasso
10311723|Astromelia cortada fresca pink panther|O|O||D||1|Lirio de campo cortado fresco pink panther
10311724|Astromelia cortada fresca prima donna|O|O||D||1|Lirio de campo cortado fresco prima donna
10311725|Astromelia cortada fresca red silhouette|O|O||D||1|Lirio de campo cortado fresco red silhouette
10311726|Astromelia cortada fresca sacha|O|O||D||1|Lirio de campo cortado fresco sacha
10311727|Astromelia cortada fresca salmón|O|O||D||1|Lirio de campo cortado fresco salmón
10311728|Astromelia cortada fresca santiago|O|O||D||1|Lirio de campo cortado fresco santiago
10311729|Astromelia cortada fresca senna|O|O||D||1|Lirio de campo cortado fresco senna
10311730|Astromelia cortada fresca snowball|O|O||D||1|Lirio de campo cortado fresco snowball
10311731|Astromelia cortada fresca sublime|O|O||D||1|Lirio de campo cortado fresco sublime
10311732|Astromelia cortada fresca tropicana|O|O||D||1|Lirio de campo cortado fresco tropicana
10311733|Astromelia cortada fresca virginia|O|O||D||1|Lirio de campo cortado fresco virginia
10311734|Astromelia cortada fresca blanca|O|O||D||1|Lirio de campo cortado fresco blanca
10311800|Amaranto cortado fresco|O|O||D||1
10311801|Amaranto cortado fresco verde colgante|O|O||D||1
10311802|Amaranto cortado fresco rojo colgante|O|O||D||1
10311803|Amaranto cortado fresco bronce erguido|O|O||D||1
10311804|Amaranto cortado fresco verde erguido|O|O||D||1
10311805|Amaranto cortado fresco rojo erguido|O|O||D||1
10311900|Amaryllis cortado fresco|O|O||D||1|Amaryllis cortada fresca
10311901|Amaryllis cortado fresco naranja|O|O||D||1|Amaryllis cortada fresca naranja
10311902|Amaryllis cortado fresco orange nagano|O|O||D||1|Amaryllis cortada fresca orange nagano
10311903|Amaryllis cortado fresco pigmeo mini|O|O||D||1|Amaryllis cortada fresca pigmeo mini
10311904|Amaryllis cortado fresco red lion|O|O||D||1|Amaryllis cortada fresca red lion
10311905|Amaryllis cortado fresco rilona|O|O||D||1|Amaryllis cortada fresca rilona
10311906|Amaryllis cortado fresco royal velvet|O|O||D||1|Amaryllis cortada fresca royal velvet
10311907|Amaryllis cortado fresco sonatini naranja|O|O||D||1|Amaryllis cortada fresca sonatini naranja
10311908|Amaryllis cortado fresco sonatini rojo|O|O||D||1|Amaryllis cortada fresca sonatini rojo
10311909|Amaryllis cortado fresco tango|O|O||D||1|Amaryllis cortada fresca tango
10311910|Amaryllis cortado fresco tinto night|O|O||D||1|Amaryllis cortada fresca tinto night
10312000|Anémona cortada fresca|O|O||D||1
10312001|Anémona cortada fresca aubergine|O|O||D||1
10312002|Anémona cortada fresca negra|O|O||D||1
10312003|Anémona cortada fresca azul|O|O||D||1
10312004|Anémona cortada fresca cereza|O|O||D||1
10312005|Anémona cortada fresca coronaria|O|O||D||1
10312006|Anémona cortada fresca rosado fuerte|O|O||D||1
10312007|Anémona cortada fresca rosado claro|O|O||D||1
10312008|Anémona cortada fresca rosado|O|O||D||1
10312009|Anémona cortada fresca púrpura|O|O||D||1
10312010|Anémona cortada fresca roja|O|O||D||1
10312011|Anémona cortada fresca blanca|O|O||D||1
10312100|Asclepia cortada fresca|O|O||D||1|Algodoncillos cortados frescos
10312101|Asclepia cortada fresca lavanda|O|O||D||1|Algodoncillo cortado fresco lavanda
10312102|Asclepia cortada fresca moby dick|O|O||D||1|Algodoncillo cortado fresco moby dick
10312103|Asclepia cortada fresca tuberosa|O|O||D||1|Algodoncillo cortado fresco tuberosa
10312104|Asclepia cortada fresca blanca|O|O||D||1|Algodoncillo cortado fresco blanca
10312200|Aster cortada fresca|O|O||D||1|Estrellas cortadas frescas
10312201|Aster cortada fresca beauty|O|O||D||1|Estrella cortada fresca beauty
10312202|Aster cortada fresca japonés azul|O|O||D||1|Estrella cortada fresca japonés azul
10312203|Aster cortada fresca japonés verde|O|O||D||1|Estrella cortada fresca japonés verde
10312204|Aster cortada fresca japonés rosado fuerte|O|O||D||1|Estrella cortada fresca japonés rosado fuerte
10312205|Aster cortada fresca japonés lavanda|O|O||D||1|Estrella cortada fresca japonés lavanda
10312206|Aster cortada fresca japonés rosado claro|O|O||D||1|Estrella cortada fresca japonés rosado claro
10312207|Aster cortada fresca japonés durazno|O|O||D||1|Estrella cortada fresca japonés durazno
10312208|Aster cortada fresca japonés rosado|O|O||D||1|Estrella cortada fresca japonés rosado
10312209|Aster cortada fresca japonés púrpura|O|O||D||1|Estrella cortada fresca japonés púrpura
10312210|Aster cortada fresca japonés rojo|O|O||D||1|Estrella cortada fresca japonés rojo
10312211|Aster cortada fresca japonés spider|O|O||D||1|Estrella cortada fresca japonés spider
10312212|Aster cortada fresca japonés  blanco|O|O||D||1|Estrella cortada fresca japonés blanco
10312213|Aster cortada fresca novi belgii rosado fuerte|O|O||D||1|Estrella cortada fresca novi belgii rosado fuerte
10312214|Aster cortada fresca novi belgii lavanda|O|O||D||1|Estrella cortada fresca novi belgii lavanda
10312215|Aster cortada fresca novi belgii rosado|O|O||D||1|Estrella cortada fresca novi belgii rosado
10312216|Aster cortada fresca novi belgii púrpura|O|O||D||1|Estrella cortada fresca novi belgii púrpura
10312217|Aster cortada fresca novi belgii blanco|O|O||D||1|Estrella cortada fresca novi belgii blanco
10312218|Aster cortada fresca solidago|O|O||D||1|Estrella cortada fresca solidago
10312219|Aster cortada fresca spider|O|O||D||1|Estrella cortada fresca spider
10312300|Berzelia cortada fresca|O|O||D||1
10312301|Berzelia lanuginosa cortada fresca abrotnoides|O|O||D||1
10312302|Berzelia lanuginosa cortada fresca fireball|O|O||D||1
10312303|Berzelia lanuginosa cortada fresca galpinii|O|O||D||1
10312304|Berzelia lanuginosa cortada fresca galpini o baubles|O|O||D||1
10312305|Berzelia lanuginosa cortada fresca squarrosa|O|O||D||1
10312400|Bouvaria cortada fresca|O|O||D||1|Trompetillas cortadas frescas
10312401|Bouvardia cortada fresca doble rosado fuerte|O|O||D||1|Trompetilla cortada fresca doble rosado fuerte
10312402|Bouvardia cortada fresca rosado claro|O|O||D||1|Trompetilla cortada fresca rosado claro
10312403|Bouvardia cortada fresca doble rosado claro|O|O||D||1|Trompetilla cortada fresca doble rosado claro
10312404|Bouvardia cortada fresca roja|O|O||D||1|Trompetilla cortada fresca roja
10312405|Bouvardia cortada fresca blanca|O|O||D||1|Trompetilla cortada fresca blanca
10312500|Brodiaea cortada fresca|O|O||D||1
10312501|Brodiaea cortada fresca congesta|O|O||D||1
10312502|Brodiaea cortada fresca congesta lavanda|O|O||D||1
10312503|Brodiaea cortada fresca jacinta|O|O||D||1
10312504|Brodiaea cortada fresca ida maija|O|O||D||1
10312505|Brodiaea cortada fresca starlight|O|O||D||1
10312600|Calla cortada fresca|O|O||D||1|Alcatraces cortados frescos
10312601|Calla cortada fresca green goddess|O|O||D||1|Alcatraz cortado fresco green goddess
10312602|Calla cortada fresca ramillete albertville|O|O||D||1|Alcatraz cortado fresco ramillete albertville
10312603|Calla cortada fresca ramillete aranal|O|O||D||1|Alcatraz cortado fresco ramillete aranal
10312604|Calla cortada fresca ramillete black eyed beauty|O|O||D||1|Alcatraz cortado fresco ramillete black eyed beauty
10312605|Calla cortada fresca black star|O|O||D||1|Alcatraz cortado fresco black star
10312606|Calla cortada fresca brisbane|O|O||D||1|Alcatraz cortado fresco brisbane
10312607|Calla cortada fresca crystal blush|O|O||D||1|Alcatraz cortado fresco crystal blush
10312608|Calla cortada fresca crystal pink|O|O||D||1|Alcatraz cortado fresco crystal pink
10312609|Calla cortada fresca crystal white|O|O||D||1|Alcatraz cortado fresco crystal white
10312610|Calla cortada fresca dark captain romanc|O|O||D||1|Alcatraz cortado fresco dark captain romance
10312611|Calla cortada fresca ramillete dark mozart|O|O||D||1|Alcatraz cortado fresco ramillete dark mozart
10312612|Calla cortada fresca ramillete dark naomi|O|O||D||1|Alcatraz cortado fresco ramillete dark naomi
10312613|Calla cortada fresca ramillete deformed calla|O|O||D||1|Alcatraz cortado fresco ramillete deformed calla
10312614|Calla cortada fresca ramillete dordogne|O|O||D||1|Alcatraz cortado fresco ramillete dordogne
10312615|Calla cortada fresca ramillete etude|O|O||D||1|Alcatraz cortado fresco ramillete etude
10312616|Calla cortada fresca ramillete farao|O|O||D||1|Alcatraz cortado fresco ramillete farao
10312617|Calla cortada fresca ramillete fire glow|O|O||D||1|Alcatraz cortado fresco ramillete fire glow
10312618|Calla cortada fresca ramillete florex gold|O|O||D||1|Alcatraz cortado fresco ramillete florex gold
10312619|Calla cortada fresca ramillete garnet glow|O|O||D||1|Alcatraz cortado fresco ramillete garnet glow
10312620|Calla cortada fresca ramillete hot chocolate|O|O||D||1|Alcatraz cortado fresco ramillete hot chocolate
10312621|Calla cortada fresca ramillete lavender improved|O|O||D||1|Alcatraz cortado fresco ramillete lavender improved
10312622|Calla cortada fresca ramillete light cromance|O|O||D||1|Alcatraz cortado fresco ramillete light cromance
10312623|Calla cortada fresca ramillete little suzy|O|O||D||1|Alcatraz cortado fresco ramillete little suzy
10312624|Calla cortada fresca ramillete majestic red|O|O||D||1|Alcatraz cortado fresco ramillete majestic red
10312625|Calla cortada fresca ramillete mango|O|O||D||1|Alcatraz cortado fresco ramillete mango
10312626|Calla cortada fresca ramillete merlot|O|O||D||1|Alcatraz cortado fresco ramillete merlot
10312627|Calla cortada fresca ramillete mozart|O|O||D||1|Alcatraz cortado fresco ramillete mozart
10312628|Calla cortada fresca ramillete naomi|O|O||D||1|Alcatraz cortado fresco ramillete naomi
10312629|Calla cortada fresca ramillete night cap|O|O||D||1|Alcatraz cortado fresco ramillete night cap
10312630|Calla cortada fresca ramillete odessa|O|O||D||1|Alcatraz cortado fresco ramillete odessa
10312631|Calla cortada fresca ramillete pacific pink|O|O||D||1|Alcatraz cortado fresco ramillete pacific pink
10312632|Calla cortada fresca ramillete passion fruit|O|O||D||1|Alcatraz cortado fresco ramillete passion fruit
10312633|Calla cortada fresca ramillete picasso|O|O||D||1|Alcatraz cortado fresco ramillete picasso
10312634|Calla cortada fresca ramillete pillow talk|O|O||D||1|Alcatraz cortado fresco ramillete pillow talk
10312635|Calla cortada fresca ramillete pink persuation|O|O||D||1|Alcatraz cortado fresco ramillete pink persuation
10312636|Calla cortada fresca ramillete pisa|O|O||D||1|Alcatraz cortado fresco ramillete pisa
10312637|Calla cortada fresca ramillete pot of|O|O||D||1|Alcatraz cortado fresco ramillete pot of
10312638|Calla cortada fresca ramillete red sox|O|O||D||1|Alcatraz cortado fresco ramillete red sox
10312639|Calla cortada fresca ramillete rosa|O|O||D||1|Alcatraz cortado fresco ramillete rosa
10312640|Calla cortada fresca ramillete ruby light rose|O|O||D||1|Alcatraz cortado fresco ramillete ruby light rose
10312641|Calla cortada fresca ramillete samur|O|O||D||1|Alcatraz cortado fresco ramillete samur
10312642|Calla cortada fresca ramillete sapporo|O|O||D||1|Alcatraz cortado fresco ramillete sapporo
10312643|Calla cortada fresca ramillete schwarzwalder|O|O||D||1|Alcatraz cortado fresco ramillete schwarzwalder
10312644|Calla cortada fresca ramillete serrada|O|O||D||1|Alcatraz cortado fresco ramillete serrada
10312645|Calla cortada fresca ramillete solemio|O|O||D||1|Alcatraz cortado fresco ramillete solemio
10312646|Calla cortada fresca ramillete sunrise|O|O||D||1|Alcatraz cortado fresco ramillete sunrise
10312647|Calla cortada fresca ramillete super mac|O|O||D||1|Alcatraz cortado fresco ramillete super mac
10312648|Calla cortada fresca ramillete swan lake|O|O||D||1|Alcatraz cortado fresco ramillete swan lake
10312649|Calla cortada fresca ramillete vermeer|O|O||D||1|Alcatraz cortado fresco ramillete vermeer
10312650|Calla cortada fresca ramillete white butterfly|O|O||D||1|Alcatraz cortado fresco ramillete white butterfly
10312651|Calla cortada fresca ramillete amarilla|O|O||D||1|Alcatraz cortado fresco ramillete amarilla
10312652|Calla cortada fresca ramillete yellow mozart|O|O||D||1|Alcatraz cortado fresco ramillete yellow mozart
10312653|Calla cortada fresca ramillete white large|O|O||D||1|Alcatraz cortado fresco ramillete white large
10312800|Celosia cortada fresca|O|O||D||1|Flores de terciopelo cortadas frescas
10312801|Cresta de gallo (celosia) cortada fresca verde|O|O||D||1|Flor de terciopelo cortada fresca verde
10312802|Cresta de gallo (celosia) cortada fresca anaranjado|O|O||D||1|Flor de terciopelo cortada fresca anaranjado
10312803|Cresta de gallo (celosia) cortada fresca rosado|O|O||D||1|Flor de terciopelo cortada fresca rosado
10312804|Cresta de gallo (celosia) cortada fresca púrpura|O|O||D||1|Flor de terciopelo cortada fresca púrpura
10312805|Cresta de gallo (celosia) cortada fresca rojo|O|O||D||1|Flor de terciopelo cortada fresca rojo
10312806|Cresta de gallo (celosia) cortada fresca amarillo|O|O||D||1|Flor de terciopelo cortada fresca amarillo
10312807|Cresta de gallo (celosia) cortada fresca plume light|O|O||D||1|Flor de terciopelo cortada fresca plume light
10312808|Cresta de gallo (celosia) cortada fresca plume orange|O|O||D||1|Flor de terciopelo cortada fresca plume orange
10312809|Cresta de gallo (celosia) cortada fresca plume purple|O|O||D||1|Flor de terciopelo cortada fresca plume purple
10312810|Cresta de gallo (celosia) cortada fresca plume red|O|O||D||1|Flor de terciopelo cortada fresca plume red
10312811|Cresta de gallo (celosia) cortada fresca plume yellow|O|O||D||1|Flor de terciopelo cortada fresca plume yellow
10312812|Cresta de gallo (celosia) cortada fresca wheat pink|O|O||D||1|Flor de terciopelo cortada fresca wheat pink
10312813|Cresta de gallo (celosia) cortada fresca wheat yellow|O|O||D||1|Flor de terciopelo cortada fresca wheat yellow
10312900|Narciso cortado fresco|O|O||D||1
10312901|Narciso cortado fresco dick wilden|O|O||D||1
10312902|Narciso cortado fresco dutch master|O|O||D||1
10312903|Narciso cortado fresco ice follies|O|O||D||1
10312904|Narciso cortado fresco ice king|O|O||D||1
10312905|Narciso cortado fresco johan strauss|O|O||D||1
10312906|Narciso cortado fresco yellow carlton|O|O||D||1
10313000|Dalia cortada fresca|O|O||D||1
10313001|Dalia cortada fresca bicolor|O|O||D||1
10313002|Dalia cortada fresca rosado fuerte|O|O||D||1
10313003|Dalia cortada fresca rosado claro|O|O||D||1
10313004|Dalia cortada fresca rosado medio|O|O||D||1
10313005|Dalia cortada fresca anaranjado|O|O||D||1
10313006|Dalia cortada fresca durazno|O|O||D||1
10313007|Dalia cortada fresca púrpura|O|O||D||1
10313008|Dalia cortada fresca roja|O|O||D||1
10313009|Dalia cortada fresca blanca|O|O||D||1
10313010|Dalia cortada fresca amarilla|O|O||D||1
10313100|Delphinium cortado fresco|O|O||D||1
10313101|Delphinium cortado fresco bella azul oscuro|O|O||D||1
10313102|Delphinium cortado fresco bella azul claro|O|O||D||1
10313103|Delphinium cortado fresco bella blanco|O|O||D||1
10313104|Delphinium cortado fresco azul sombra|O|O||D||1
10313105|Delphinium cortado fresco híbrido azul oscuro|O|O||D||1
10313106|Delphinium cortado fresco híbrido azul claro|O|O||D||1
10313107|Delphinium cortado fresco híbrido malva|O|O||D||1
10313108|Delphinium cortado fresco híbrido rosado|O|O||D||1
10313109|Delphinium cortado fresco híbrido púrpura|O|O||D||1
10313110|Delphinium cortado fresco híbrido rojo|O|O||D||1
10313111|Delphinium cortado fresco híbrido blanco|O|O||D||1
10313112|Delphinium cortado fresco princesa carolina|O|O||D||1
10313113|Delphinium cortado fresco volkerfrieden|O|O||D||1
10313200|Clavel (dianthus) cortado fresco|O|O||D||1|Clavelinas cortadas frescas
10313201|Clavel (dianthus) cortado fresco chocolate|O|O||D||1|Clavelina cortada fresca chocolate
10313202|Clavel (dianthus) cortado fresco fucsia|O|O||D||1|Clavelina cortada fresca fucsia
10313203|Clavel (dianthus) cortado fresco bola verde|O|O||D||1|Clavelina cortada fresca bola verde
10313204|Clavel (dianthus) cortado fresco rosado fuerte|O|O||D||1|Clavelina cortada fresca rosado fuerte
10313205|Clavel (dianthus) cortado fresco lavanda|O|O||D||1|Clavelina cortada fresca lavanda
10313206|Clavel (dianthus) cortado fresco frambuesa|O|O||D||1|Clavelina cortada fresca frambuesa
10313207|Clavel (dianthus) cortado fresco rojo|O|O||D||1|Clavelina cortada fresca rojo
10313208|Clavel (dianthus) cortado fresco rosado|O|O||D||1|Clavelina cortada fresca rosado
10313300|Eremruses cortadas frescas|O|O||D||1
10313301|Eremurus cortado fresco deruyter híbrido|O|O||D||1
10313302|Eremurus cortado fresco himalaicus blanco|O|O||D||1
10313303|Eremurus cortado fresco anaranjado|O|O||D||1
10313304|Eremurus cortado fresco durazno|O|O||D||1
10313305|Eremurus cortado fresco amarillo|O|O||D||1
10313400|Brezo (erica) cortada fresca|O|O||D||1|Brecinas cortadas frescas
10313401|Brezo (erica) cortado fresco campunalarus|O|O||D||1|Brecina cortada fresca campunalarus
10313402|Brezo (erica) cortado fresco conica|O|O||D||1|Brecina cortada fresca cónica
10313403|Brezo (erica) cortado fresco green ice|O|O||D||1|Brecina cortada fresca green ice
10313404|Brezo (erica) cortado fresco rosado|O|O||D||1|Brecina cortada fresca rosado
10313405|Brezo (erica) cortado fresco príncipe de gales|O|O||D||1|Brecina cortada fresca príncipe de gales
10313500|Euphorbia cortada fresca|O|O||D||1|Coronas de Cristo cortadas frescas
10313501|Euphorbia cortada fresca characias|O|O||D||1|Corona de Cristo cortada fresca characias
10313502|Euphorbia cortada fresca griffithii fireglow|O|O||D||1|Corona de Cristo cortada fresca griffithii fireglow
10313503|Euphorbia cortada fresca martini|O|O||D||1|Corona de Cristo cortada fresca martini
10313504|Euphorbia cortada fresca anaranjada|O|O||D||1|Corona de Cristo cortada fresca anaranjada
10313505|Euphorbia cortada fresca durazno|O|O||D||1|Corona de Cristo cortada fresca durazno
10313506|Euphorbia cortada fresca rosada|O|O||D||1|Corona de Cristo cortada fresca rosada
10313507|Euphorbia cortada fresca roja|O|O||D||1|Corona de Cristo cortada fresca roja
10313508|Euphorbia cortada fresca blanca|O|O||D||1|Corona de Cristo cortada fresca blanca
10313509|Euphorbia cortada fresca amarilla|O|O||D||1|Corona de Cristo cortada fresca amarilla
10313510|Euphorbia cortada fresca amarilla spurge|O|O||D||1|Corona de Cristo cortada fresca amarilla spurge
10313600|Fresia cortada fresca|O|O||D||1|Freesias cortadas frescas
10313601|Fresia cortada fresca crema|O|O||D||1|Freesia cortada fresca crema
10313602|Fresia cortada fresca doble blanca|O|O||D||1|Freesia cortada fresca doble blanca
10313603|Fresia cortada fresca doble amarilla|O|O||D||1|Freesia cortada fresca doble amarilla
10313604|Fresia cortada fresca rosado fuerte|O|O||D||1|Freesia cortada fresca rosado fuerte
10313605|Fresia cortada fresca lady brunet|O|O||D||1|Freesia cortada fresca lady brunet
10313606|Fresia cortada fresca lavanda|O|O||D||1|Freesia cortada fresca lavanda
10313607|Fresia cortada fresca rosado medio|O|O||D||1|Freesia cortada fresca rosado medio
10313608|Fresia cortada fresca anaranjado|O|O||D||1|Freesia cortada fresca anaranjado
10313609|Fresia cortada fresca pimpinela|O|O||D||1|Freesia cortada fresca pimpinela
10313610|Fresia cortada fresca rosada|O|O||D||1|Freesia cortada fresca rosada
10313611|Fresia cortada fresca pùrpura|O|O||D||1|Freesia cortada fresca púrpura
10313612|Fresia cortada fresca roja|O|O||D||1|Freesia cortada fresca roja
10313613|Fresia cortada fresca blanca|O|O||D||1|Freesia cortada fresca blanca
10313614|Fresia cortada fresca amarilla|O|O||D||1|Freesia cortada fresca amarilla
10313700|Ajedrezada cortada fresca|O|O||D||1
10313701|Ajedrezada cortada fresca acmopelata|O|O||D||1
10313702|Ajedrezada cortada fresca assyriaca|O|O||D||1
10313703|Ajedrezada cortada fresca assyriaca uva vulpis|O|O||D||1
10313704|Ajedrezada cortada fresca elysee|O|O||D||1
10313705|Ajedrezada cortada fresca imperialis anaranjada|O|O||D||1
10313706|Ajedrezada cortada fresca imperialis amarilla|O|O||D||1
10313707|Ajedrezada cortada fresca meleagris|O|O||D||1
10313708|Ajedrezada cortada fresca michailowski|O|O||D||1
10313709|Ajedrezada cortada fresca uva vulpis|O|O||D||1
10313800|Hiniesta cortada fresca|O|O||D||1
10313801|Hiniesta cortada fresca verde|O|O||D||1
10313802|Hiniesta cortada fresca rosado fuerte|O|O||D||1
10313803|Hiniesta cortada fresca lavanda|O|O||D||1
10313804|Hiniesta cortada fresca rosado claro|O|O||D||1
10313805|Hiniesta cortada fresca durazno|O|O||D||1
10313806|Hiniesta cortada fresca púrpura|O|O||D||1
10313807|Hiniesta cortada fresca blanco|O|O||D||1
10313808|Hiniesta cortada fresca amarillo|O|O||D||1
10313900|Margarita cortada fresca|O|O||D||1|Gerberas cortadas frescas
10313901|Margarita cortada fresca crema de centro negro|O|O||D||1|Gerbera cortada fresca crema de centro negro
10313902|Margarita cortada fresca crema|O|O||D||1|Gerbera cortada fresca crema
10313903|Margarita cortada fresca dorada|O|O||D||1|Gerbera cortada fresca dorada
10313904|Margarita cortada fresca rosado fuerte|O|O||D||1|Gerbera cortada fresca rosado fuerte
10313905|Margarita cortada fresca rosado claro|O|O||D||1|Gerbera cortada fresca rosado claro
10313906|Margarita cortada fresca magenta|O|O||D||1|Gerbera cortada fresca magenta
10313907|Margarita cortada fresca mini coral|O|O||D||1|Gerbera cortada fresca mini coral
10313908|Margarita cortada fresca mini fucsia|O|O||D||1|Gerbera cortada fresca mini fucsia
10313909|Margarita cortada fresca mini rosado fuerte|O|O||D||1|Gerbera cortada fresca mini rosado fuerte
10313910|Margarita cortada fresca mini anaranjado claro de centro negro|O|O||D||1|Gerbera cortada fresca mini anaranjado claro de centro negro
10313911|Margarita cortada fresca mini anaranjado de centro negro|O|O||D||1|Gerbera cortada fresca mini anaranjado de centro negro
10313912|Margarita cortada fresca mini anaranjado|O|O||D||1|Gerbera cortada fresca mini anaranjado
10313913|Margarita cortada fresca mini rojo de centro negro|O|O||D||1|Gerbera cortada fresca mini rojo de centro negro
10313914|Margarita cortada fresca mini blanco|O|O||D||1|Gerbera cortada fresca mini blanco
10313915|Margarita cortada fresca mini amarillo claro de centro negro|O|O||D||1|Gerbera cortada fresca mini amarillo claro de centro negro
10313916|Margarita cortada fresca anaranjado de centro negro|O|O||D||1|Gerbera cortada fresca anaranjado de centro negro
10313917|Margarita cortada fresca anaranjada|O|O||D||1|Gerbera cortada fresca anaranjada
10313918|Margarita cortada fresca durazno de centro negro|O|O||D||1|Gerbera cortada fresca durazno de centro negro
10313919|Margarita cortada fresca durazno|O|O||D||1|Gerbera cortada fresca durazno
10313920|Margarita cortada fresca rosada de centro negro|O|O||D||1|Gerbera cortada fresca rosada de centro negro
10313921|Margarita cortada fresca rosada|O|O||D||1|Gerbera cortada fresca rosada
10313922|Margarita cortada fresca roja de centro negro|O|O||D||1|Gerbera cortada fresca roja de centro negro
10313923|Margarita cortada fresca roja|O|O||D||1|Gerbera cortada fresca roja
10313924|Margarita cortada fresca spider durazno|O|O||D||1|Gerbera cortada fresca spider durazno
10313925|Margarita cortada fresca spider roja|O|O||D||1|Gerbera cortada fresca spider roja
10313926|Margarita cortada fresca terracota|O|O||D||1|Gerbera cortada fresca terracota
10313927|Margarita cortada fresca blanca de centro negro|O|O||D||1|Gerbera cortada fresca blanca de centro negro
10313928|Margarita cortada fresca blanca|O|O||D||1|Gerbera cortada fresca blanca
10313929|Margarita cortada fresca amarilla|O|O||D||1|Gerbera cortada fresca amarilla
10314000|Jengibre cortado fresco|O|O||D||1|Flores de jengibre cortadas frescas
10314001|Jengibre cortado fresco  indonesio|O|O||D||1|Flor de jengibre cortada fresca indonesio
10314002|Jengibre cortado fresco jungle king rosado|O|O||D||1|Flor de jengibre cortada fresca jungle king rosado
10314003|Jengibre cortado fresco jungle king rojo|O|O||D||1|Flor de jengibre cortada fresca jungle king rojo
10314004|Jengibre cortado fresco rosado|O|O||D||1|Flor de jengibre cortada fresca rosado
10314005|Jengibre cortado fresco rojo|O|O||D||1|Flor de jengibre cortada fresca rojo
10314006|Jengibre cortado fresco torch|O|O||D||1|Flor de jengibre cortada fresca torch
10314100|Gladiolo cortado fresco|O|O||D||1|Gladiolas cortadas frescas
10314101|Gladiolo cortado fresco burgundy|O|O||D||1|Gladiola cortada fresca burgundy
10314102|Gladiolo cortado fresco fucsia|O|O||D||1|Gladiola cortada fresca fucsia
10314103|Gladiolo cortado fresco verde|O|O||D||1|Gladiola cortada fresca verde
10314104|Gladiolo cortado fresco rosado fuerte|O|O||D||1|Gladiola cortada fresca rosado fuerte
10314105|Gladiolo cortado fresco rosado claro|O|O||D||1|Gladiola cortada fresca rosado claro
10314106|Gladiolo cortado fresco anaranjado|O|O||D||1|Gladiola cortada fresca anaranjado
10314107|Gladiolo cortado fresco durazno|O|O||D||1|Gladiola cortada fresca durazno
10314108|Gladiolo cortado fresco rosado medio|O|O||D||1|Gladiola cortada fresca rosado medio
10314109|Gladiolo cortado fresco púrpura|O|O||D||1|Gladiola cortada fresca púrpura
10314110|Gladiolo cortado fresco rojo bi – color|O|O||D||1|Gladiola cortada fresca rojo bi - color
10314111|Gladiolo cortado fresco rojo|O|O||D||1|Gladiola cortada fresca rojo
10314112|Gladiolo cortado fresco salmón|O|O||D||1|Gladiola cortada fresca salmón
10314113|Gladiolo cortado fresco blanco|O|O||D||1|Gladiola cortada fresca blanco
10314114|Gladiolo cortado fresco amarillo|O|O||D||1|Gladiola cortada fresca amarillo
10314200|Godetia cortada fresca|O|O||D||1
10314201|Godetia cortada fresca bicolor|O|O||D||1
10314202|Godetia cortada fresca fucsia|O|O||D||1
10314203|Godetia cortada fresca rosado fuerte|O|O||D||1
10314204|Godetia cortada fresca anaranjada|O|O||D||1
10314205|Godetia cortada fresca roja|O|O||D||1
10314206|Godetia cortada fresca blanca|O|O||D||1
10314300|Bromelia cortada fresca|O|O||D||1
10314301|Bromelia lingulata cortada fresca anaranjada|O|O||D||1
10314302|Bromelia lingulata cortada fresca roja|O|O||D||1
10314303|Bromelia lingulata cortada fresca blanca|O|O||D||1
10314304|Bromelia lingulata cortada fresca amarilla|O|O||D||1
10314305|Bromelia variegata cortada fresca|O|O||D||1
10314400|Gypsophilia cortada fresca|O|O||D||1|Nubes cortadas frescas
10314401|Gypsophilia cortada fresca bambino|O|O||D||1|Nube cortada fresca bambino
10314402|Gypsophilia cortada fresca million stars|O|O||D||1|Nube cortada fresca million stars
10314403|Gypsophilia cortada fresca mirabella|O|O||D||1|Nube cortada fresca mirabella
10314404|Gypsophilia cortada fresca new love|O|O||D||1|Nube cortada fresca new love
10314405|Gypsophilia cortada fresca orión|O|O||D||1|Nube cortada fresca orión
10314406|Gypsophilia cortada fresca perfecta|O|O||D||1|Nube cortada fresca perfecta
10314500|Brezo cortado fresco|O|O||D||1|Biércol cortado fresco
10314501|Brezo cortado fresco augustine|O|O||D||1|Biércol cortado fresco augustine
10314502|Brezo cortado fresco érica cuatro hermanas|O|O||D||1|Biércol cortado fresco érica cuatro hermanas
10314503|Brezo cortado fresco francés|O|O||D||1|Biércol cortado fresco francés
10314504|Brezo cortado fresco verde|O|O||D||1|Biércol cortado fresco verde
10314505|Brezo corte fresco sterling range blanco|O|O||D||1|Biércol cortado fresco sterling range blanco
10314506|Brezo cortado fresco rosado sunset|O|O||D||1|Biércol cortado fresco rosado sunset
10314507|Brezo cortado fresco blanco|O|O||D||1|Biércol cortado fresco blanco
10314600|Heliconia cortada fresca|O|O||D||1|Pinzas de langosta cortadas frescas
10314601|Heliconia cortada fresca bihai claw|O|O||D||1|Pinza de langosta cortada fresca bihai claw
10314602|Heliconia cortada fresca bihai flash|O|O||D||1|Pinza de langosta cortada fresca bihai flash
10314603|Heliconia cortada fresca bihai lobster claw|O|O||D||1|Pinza de langosta cortada fresca bihai lobster claw
10314604|Heliconia cortada fresca caribea red|O|O||D||1|Pinza de langosta cortada fresca caribea red
10314605|Heliconia cortada fresca caribea yellow|O|O||D||1|Pinza de langosta cortada fresca caribea yellow
10314606|Heliconia cortada fresca christmas|O|O||D||1|Pinza de langosta cortada fresca christmas
10314607|Heliconia cortada fresca edge of night|O|O||D||1|Pinza de langosta cortada fresca edge of night
10314608|Heliconia cortada fresca green bihai|O|O||D||1|Pinza de langosta cortada fresca green bihai
10314609|Heliconia cortada fresca marginata lutea|O|O||D||1|Pinza de langosta cortada fresca marginata lútea
10314610|Heliconia cortada fresca psitt fire opal|O|O||D||1|Pinza de langosta cortada fresca psitt fire opal
10314611|Heliconia cortada fresca psittacorum|O|O||D||1|Pinza de langosta cortada fresca psittacorum
10314612|Heliconia cortada fresca richmond red|O|O||D||1|Pinza de langosta cortada fresca richmond red
10314613|Heliconia cortada fresca rostrata|O|O||D||1|Pinza de langosta cortada fresca rostrata
10314614|Heliconia cortada fresca sexy pink|O|O||D||1|Pinza de langosta cortada fresca sexy pink
10314615|Heliconia cortada fresca sexy scarlett|O|O||D||1|Pinza de langosta cortada fresca sexy scarlett
10314616|Heliconia cortada fresca shogun|O|O||D||1|Pinza de langosta cortada fresca shogun
10314617|Heliconia cortada fresca small red|O|O||D||1|Pinza de langosta cortada fresca small red
10314618|Heliconia cortada fresca southern cross|O|O||D||1|Pinza de langosta cortada fresca southern cross
10314619|Heliconia cortada fresca wagneriana|O|O||D||1|Pinza de langosta cortada fresca wagneriana
10314700|Jacinto cortado fresco|O|O||D||1
10314701|Jacinto cortado fresco bean|O|O||D||1
10314702|Jacinto cortado fresco durazno|O|O||D||1
10314703|Jacinto cortado fresco azul|O|O||D||1
10314704|Jacinto cortado fresco fucsia|O|O||D||1
10314705|Jacinto cortado fresco rosado fuerte|O|O||D||1
10314706|Jacinto cortado fresco lavanda|O|O||D||1
10314707|Jacinto cortado fresco azul claro|O|O||D||1
10314708|Jacinto cortado fresco rosado medio|O|O||D||1
10314709|Jacinto cortado fresco rosado|O|O||D||1
10314710|Jacinto cortado fresco estrella púrpura|O|O||D||1
10314711|Jacinto cortado fresco blanco|O|O||D||1
10314712|Jacinto cortado fresco amarillo|O|O||D||1
10314800|Hydrangea cortada fresca|O|O||D||1|Hortensias cortadas frescas
10314801|Hydrangea cortada fresca anabella|O|O||D||1|Hortensia cortada fresca anabella
10314802|Hydrangea cortada fresca azul antiguo|O|O||D||1|Hortensia cortada fresca azul antiguo
10314803|Hydrangea cortada fresca azul antiguo  o verde o nueva zelandia|O|O||D||1|Hortensia cortada fresca azul antiguo o verde o nueva zelandia
10314804|Hydrangea cortada fresca verde antiguo|O|O||D||1|Hortensia cortada fresca verde antiguo
10314805|Hydrangea cortada fresca rosado antiguo|O|O||D||1|Hortensia cortada fresca rosado antiguo
10314806|Hydrangea cortada fresca púrpura antiguo o nueva zelandia|O|O||D||1|Hortensia cortada fresca púrpura antiguo o nueva zelandia
10314807|Hydrangea cortada fresca aubergene o nueva zelandia|O|O||D||1|Hortensia cortada fresca aubergene o nueva zelandia
10314808|Hydrangea cortada fresca azul oscuro|O|O||D||1|Hortensia cortada fresca azul oscuro
10314809|Hydrangea cortada fresca rosado oscuro|O|O||D||1|Hortensia cortada fresca rosado oscuro
10314810|Hydrangea cortada fresca púrpura oscuro|O|O||D||1|Hortensia cortada fresca púrpura oscuro
10314811|Hydrangea cortada fresca berenjena|O|O||D||1|Hortensia cortada fresca berenjena
10314812|Hydrangea cortada fresca verde teñida|O|O||D||1|Hortensia cortada fresca verde teñida
10314813|Hydrangea cortada fresca limón verde|O|O||D||1|Hortensia cortada fresca limón verde
10314814|Hydrangea cortada fresca rosado fuerte|O|O||D||1|Hortensia cortada fresca rosado fuerte
10314815|Hydrangea cortada fresca jumbo blanca|O|O||D||1|Hortensia cortada fresca jumbo blanca
10314816|Hydrangea cortada fresca lavanda o nueva zelandia|O|O||D||1|Hortensia cortada fresca lavanda o nueva zelandia
10314817|Hydrangea cortada fresca azul claro|O|O||D||1|Hortensia cortada fresca azul claro
10314818|Hydrangea cortada fresca rosado claro grande|O|O||D||1|Hortensia cortada fresca rosado claro grande
10314819|Hydrangea cortada fresca verde lima grande|O|O||D||1|Hortensia cortada fresca verde lima grande
10314820|Hydrangea cortada fresca mini verde|O|O||D||1|Hortensia cortada fresca mini verde
10314821|Hydrangea cortada fresca oakleaf|O|O||D||1|Hortensia cortada fresca oakleaf
10314822|Hydrangea cortada fresca oakleaf copo de nieve|O|O||D||1|Hortensia cortada fresca oakleaf copo de nieve
10314823|Hydrangea cortada fresca rosado teñido|O|O||D||1|Hortensia cortada fresca rosado teñido
10314824|Hydrangea cortada fresca rosado|O|O||D||1|Hortensia cortada fresca rosado
10314825|Hydrangea cortada fresca púrpura o nueva zelandia|O|O||D||1|Hortensia cortada fresca púrpura o nueva zelandia
10314826|Hydrangea cortada fresca rojo teñido|O|O||D||1|Hortensia cortada fresca rojo teñido
10314827|Hydrangea cortada fresca shocking blue|O|O||D||1|Hortensia cortada fresca shocking blue
10314828|Hydrangea cortada fresca tardiva|O|O||D||1|Hortensia cortada fresca tardiva
10314829|Hydrangea cortada fresca blanca|O|O||D||1|Hortensia cortada fresca blanca
10314900|Iris cortada fresca|O|O||D||1
10314901|Iris cortada fresca negra barbada|O|O||D||1
10314902|Iris cortada fresca azul barbada|O|O||D||1
10314903|Iris cortada fresca lavanda barbada|O|O||D||1
10314904|Iris cortada fresca barbada azul clara|O|O||D||1
10314905|Iris cortada fresca barbada púrpura|O|O||D||1
10314906|Iris cortada fresca barbada roja|O|O||D||1
10314907|Iris cortada fresca barbada blanca|O|O||D||1
10314908|Iris cortada fresca baerbada blanca y púrpura|O|O||D||1
10314909|Iris cortada fresca amarilla barbada|O|O||D||1
10314910|Iris cortada fresca blue elegance|O|O||D||1
10314911|Iris cortada fresca casablanca|O|O||D||1
10314912|Iris cortada fresca golden beau|O|O||D||1
10314913|Iris cortada fresca hildegard|O|O||D||1
10314914|Iris cortada fresca hong kong|O|O||D||1
10314915|Iris cortada fresca ideal|O|O||D||1
10314916|Iris cortada fresca professor blue|O|O||D||1
10314917|Iris cortada fresca purple|O|O||D||1
10314918|Iris cortada fresca spuria|O|O||D||1
10314919|Iris cortada fresca telstar|O|O||D||1
10315000|Pata de canguro cortada fresca|O|O||D||1
10315001|Pata de canguro cortada fresca bicolor|O|O||D||1
10315002|Pata de canguro cortada fresca negra|O|O||D||1
10315003|Pata de canguro cortada fresca verde|O|O||D||1
10315004|Pata de canguro cortada fresca anaranjada|O|O||D||1
10315005|Pata de canguro cortada fresca rosada|O|O||D||1
10315006|Pata de canguro cortada fresca roja|O|O||D||1
10315007|Pata de canguro cortada fresca amarilla|O|O||D||1
10315100|Delfinio cortado fresco|O|O||D||1|Delphinium (larkspurs) cortados frescos
10315101|Delfinio cortada fresca azul nube|O|O||D||1|Delphinium (larkspurs) cortado fresco azul nube
10315102|Delfinio cortada fresca rosado fuerte|O|O||D||1|Delphinium (larkspurs) cortado fresco rosado fuerte
10315103|Delfinio cortada fresca lavanda|O|O||D||1|Delphinium (larkspurs) cortado fresco lavanda
10315104|Delfinio cortada fresca rosado claro|O|O||D||1|Delphinium (larkspurs) cortado fresco rosado claro
10315105|Delfinio cortada fresca púrpura|O|O||D||1|Delphinium (larkspurs) cortado fresco púrpura
10315106|Delfinio cortada fresca blanca|O|O||D||1|Delphinium (larkspurs) cortado fresco blanca
10315200|Lepto cortado fresco|O|O||D||1
10315201|Lepto cortado fresco azul o floreciente|O|O||D||1
10315202|Lepto cortado fresco rosado fuerte|O|O||D||1
10315203|Lepto cortado fresco rosado claro|O|O||D||1
10315204|Lepto cortado fresco rosado|O|O||D||1
10315205|Lepto cortado fresco rojo|O|O||D||1
10315206|Lepto cortado fresco blanco|O|O||D||1
10315300|Lila cortada fresca|O|O||D||1
10315301|Lila  cortada fresca híbrida francesa lavanda|O|O||D||1
10315302|Lila  cortada fresca híbrida francesa púrpura|O|O||D||1
10315303|Lila  cortada fresca púrpura|O|O||D||1
10315304|Lila  cortada fresca vino|O|O||D||1
10315305|Lila  cortada fresca blanca|O|O||D||1
10315306|Lila  cortada fresca blanca salvaje|O|O||D||1
10315400|Azucena cortada fresca|O|O||D||1|Lilis cortadas frescas
10315401|Azucena cortada fresca alteza longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca alteza longiflorum e híbrido asiática
10315402|Azucena cortada fresca black out asiática|O|O||D||1|Lili cortada fresca black out asiática
10315403|Azucena cortada fresca rosado oscuro asiática|O|O||D||1|Lili cortada fresca rosado oscuro asiática
10315404|Azucena cortada fresca leéctrica asiática|O|O||D||1|Lili cortada fresca eléctrica asiática
10315405|Azucena cortada fresca festival asiática|O|O||D||1|Lili cortada fresca festival asiática
10315406|Azucena cortada fresca ginebra asiática|O|O||D||1|Lili cortada fresca ginebra asiática
10315407|Azucena cortada fresca rosado claro asiática|O|O||D||1|Lili cortada fresca rosado claro asiática
10315408|Azucena cortada fresca colombina asiática|O|O||D||1|Lili cortada fresca colombina asiática
10315409|Azucena cortada fresca miss américa púrpura asiática|O|O||D||1|Lili cortada fresca miss américa púrpura asiática
10315410|Azucena cortada fresca monte negro asiática|O|O||D||1|Lili cortada fresca monte negro asiática
10315411|Azucena cortada fresca anaranjada asiática|O|O||D||1|Lili cortada fresca anaranjada asiática
10315412|Azucena cortada fresca durazno cannes asiática|O|O||D||1|Lili cortada fresca durazno cannes asiática
10315413|Azucena cortada fresca risada asiática|O|O||D||1|Lili cortada fresca risada asiática
10315414|Azucena cortada fresca sancerre asiátia|O|O||D||1|Lili cortada fresca sancerre asiática
10315415|Azucena cortada fresca white dream asiática|O|O||D||1|Lili cortada fresca white dream asiática
10315416|Azucena cortada fresca amarilla asiática|O|O||D||1|Lili cortada fresca amarilla asiática
10315417|Azucena cortada fresca diamante brillante longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca diamante brillante longiflorum e híbrido asiática
10315418|Azucena cortada fresca brindisi longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca brindisi longiflorum e híbrido asiática
10315419|Azucena cortada fresca carmine longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca carmine longiflorum e híbrido asiática
10315420|Azucena cortada fresca cinnabar longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca cinnabar longiflorum e híbrido asiática
10315421|Azucena cortada fresca club longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca club longiflorum e híbrido asiática
10315422|Azucena cortada fresca discovery longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca discovery longiflorum e híbrido asiática
10315423|Azucena cortada fresca de pascua|O|O||D||1|Lili cortada fresca de pascua
10315424|Azucena cortada fresca isis longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca isis longiflorum e híbrido asiática
10315425|Azucena cortada fresca la hybrid justice longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca la hybrid justice longiflorum e híbrido asiática
10315426|Azucena cortada fresca lace longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca lace longiflorum e híbrido asiática
10315427|Azucena cortada fresca lirio de los valles|O|O||D||1|Lili cortada fresca lirio de los valles
10315428|Azucena cortada fresca love longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca love longiflorum e híbrido asiática
10315429|Azucena cortada fresca menorca longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca menorca longiflorum e híbrido asiática
10315430|Azucena cortada fresca oriental acapulco|O|O||D||1|Lili cortada fresca oriental acapulco
10315431|Azucena cortada fresca oriental albion|O|O||D||1|Lili cortada fresca oriental albión
10315432|Azucena cortada fresca oriental argentina|O|O||D||1|Lili cortada fresca oriental argentina
10315433|Azucena cortada fresca oriental auratum|O|O||D||1|Lili cortada fresca oriental auratum
10315434|Azucena cortada fresca oriental barbaresco|O|O||D||1|Lili cortada fresca oriental barbaresco
10315435|Azucena cortada fresca oriental bernini|O|O||D||1|Lili cortada fresca oriental bernini
10315436|Azucena cortada fresca oriental beseno|O|O||D||1|Lili cortada fresca oriental beseno
10315437|Azucena cortada fresca oriental broadway|O|O||D||1|Lili cortada fresca oriental broadway
10315438|Azucena cortada fresca oriental canada|O|O||D||1|Lili cortada fresca oriental canadá
10315439|Azucena cortada fresca oriental casablanca|O|O||D||1|Lili cortada fresca oriental casablanca
10315440|Azucena cortada fresca oriental chili|O|O||D||1|Lili cortada fresca oriental chili
10315441|Azucena cortada fresca oriental chrystal|O|O||D||1|Lili cortada fresca oriental chrystal
10315442|Azucena cortada fresca oriental cobra|O|O||D||1|Lili cortada fresca oriental cobra
10315443|Azucena cortada fresca oriental conca d’ or|O|O||D||1|Lili cortada fresca oriental conca d' ivor
10315444|Azucena cortada fresca oriental cote d’ ivor|O|O||D||1|Lili cortada fresca oriental cote d' ivor
10315445|Azucena cortada fresca oriental dizzy|O|O||D||1|Lili cortada fresca oriental dizzy
10315446|Azucena cortada fresca oriental fireball|O|O||D||1|Lili cortada fresca oriental fireball
10315447|Azucena cortada fresca oriental gluhwein|O|O||D||1|Lili cortada fresca oriental gluhwein
10315448|Azucena cortada fresca oriental goldband|O|O||D||1|Lili cortada fresca oriental goldband
10315449|Azucena cortada fresca oriental halifax|O|O||D||1|Lili cortada fresca oriental halifax
10315450|Azucena cortada fresca oriental kathryn|O|O||D||1|Lili cortada fresca oriental kathryn
10315451|Azucena cortada fresca oriental kyoto|O|O||D||1|Lili cortada fresca oriental kyoto
10315452|Azucena cortada fresca oriental la mancha|O|O||D||1|Lili cortada fresca oriental la mancha
10315453|Azucena cortada fresca oriental medusa|O|O||D||1|Lili cortada fresca oriental medusa
10315454|Azucena cortada fresca oriental montezuma|O|O||D||1|Lili cortada fresca oriental montezuma
10315455|Azucena cortada fresca oriental muscadet|O|O||D||1|Lili cortada fresca oriental muscadet
10315456|Azucena cortada fresca oriental nippon|O|O||D||1|Lili cortada fresca oriental nippon
10315457|Azucena cortada fresca oriental opus one|O|O||D||1|Lili cortada fresca oriental opus one
10315458|Azucena cortada fresca oriental pompeii|O|O||D||1|Lili cortada fresca oriental pompeii
10315459|Azucena cortada fresca oriental rialto|O|O||D||1|Lili cortada fresca oriental rialto
10315460|Azucena cortada fresca oriental robina|O|O||D||1|Lili cortada fresca oriental robina
10315461|Azucena cortada fresca oriental rousilon|O|O||D||1|Lili cortada fresca oriental rousilon
10315462|Azucena cortada fresca oriental siberia|O|O||D||1|Lili cortada fresca oriental siberia
10315463|Azucena cortada fresca oriental sorbonne|O|O||D||1|Lili cortada fresca oriental sorbonne
10315464|Azucena cortada fresca oriental starfighter|O|O||D||1|Lili cortada fresca oriental starfighter
10315465|Azucena cortada fresca oriental stargazer|O|O||D||1|Lili cortada fresca oriental stargazer
10315466|Azucena cortada fresca oriental sumatra|O|O||D||1|Lili cortada fresca oriental sumatra
10315467|Azucena cortada fresca oriental time out|O|O||D||1|Lili cortada fresca oriental time out
10315468|Azucena cortada fresca oriental tom pouche|O|O||D||1|Lili cortada fresca oriental tom pouche
10315469|Azucena cortada fresca oriental tropical|O|O||D||1|Lili cortada fresca oriental tropical
10315470|Azucena cortada fresca oriental white cup|O|O||D||1|Lili cortada fresca oriental white cup
10315471|Azucena cortada fresca oriental white merostar|O|O||D||1|Lili cortada fresca oriental white merostar
10315472|Azucena cortada fresca oriental white montana|O|O||D||1|Lili cortada fresca oriental white montana
10315473|Azucena cortada fresca oriental white stargazer|O|O||D||1|Lili cortada fresca oriental white stargazer
10315474|Azucena cortada fresca oriental yellow band|O|O||D||1|Lili cortada fresca oriental yellow band
10315475|Azucena cortada fresca oriental yellow dream|O|O||D||1|Lili cortada fresca oriental yellow dream
10315476|Azucena cortada fresca oriental yellow queen|O|O||D||1|Lili cortada fresca oriental yellow queen
10315477|Azucena cortada fresca oriental yellow star|O|O||D||1|Lili cortada fresca oriental yellow star
10315478|Azucena cortada fresca oriental yeloween|O|O||D||1|Lili cortada fresca oriental yelloween
10315479|Azucena cortada fresca ot red dutch|O|O||D||1|Lili cortada fresca ot red dutch
10315480|Azucena cortada fresca sonata nimph|O|O||D||1|Lili cortada fresca sonata nimph
10315481|Azucena cortada fresca sonata shocking|O|O||D||1|Lili cortada fresca sonata shocking
10315482|Azucena cortada fresca sonata triumphateer|O|O||D||1|Lili cortada fresca sonata triumphateer
10315483|Azucena cortada fresca sunset longiflorum e híbrido asiática|O|O||D||1|Lili cortada fresca sunset longiflorum e híbrido asiática
10315484|Azucena cortada fresca de agua|O|O||D||1|Lili cortada fresca de agua
10315500|Lavanda cortada fresca|O|O||D||1
10315501|Lavanda marina cortada fresca misty peach|O|O||D||1
10315502|Lavanda marina cortada fresca misty rosada|O|O||D||1
10315503|Lavanda marina cortada fresca misty blanca|O|O||D||1
10315504|Lavanda marina cortada fresca misty amarilla|O|O||D||1
10315505|Lavanda marina cortada fresca safora|O|O||D||1
10315506|Lavanda marina cortada fresca sinensis|O|O||D||1
10315600|Lisianthus cortado fresco|O|O||D||1|Eustomas cortadas frescas
10315601|Lisianthus cortado fresco crema|O|O||D||1|Eustoma cortada fresca crema
10315602|Lisianthus cortado fresco rosado fuerte|O|O||D||1|Eustoma cortada fresca rosado fuerte
10315603|Lisianthus cortado fresco verde|O|O||D||1|Eustoma cortada fresca verde
10315604|Lisianthus cortado fresco lavanda|O|O||D||1|Eustoma cortada fresca lavanda
10315605|Lisianthus cortado fresco rosado claro|O|O||D||1|Eustoma cortada fresca rosado claro
10315606|Lisianthus cortado fresco mini blanco|O|O||D||1|Eustoma cortada fresca mini blanco
10315607|Lisianthus cortado fresco durazno|O|O||D||1|Eustoma cortada fresca durazno
10315608|Lisianthus cortado fresco rosado con borde blanco|O|O||D||1|Eustoma cortada fresca rosado con borde blanco
10315609|Lisianthus cortado fresco púrpura|O|O||D||1|Eustoma cortada fresca púrpura
10315610|Lisianthus cortado fresco púrpura con borde blanco|O|O||D||1|Eustoma cortada fresca púrpura con borde blanco
10315611|Lisianthus cortado fresco blanco con borde rosado|O|O||D||1|Eustoma cortada fresca blanco con borde rosado
10315612|Lisianthus cortado fresco blanco|O|O||D||1|Eustoma cortada fresca blanco
10315613|Lisianthus cortado fresco blanco con borde pùrpura|O|O||D||1|Eustoma cortada fresca blanco con borde púrpura
10315700|Muscari cortada fresca|O|O||D||1
10315701|Muscari cortada fresca armeniacum|O|O||D||1
10315702|Muscari cortada fresca bortyoides blanca|O|O||D||1
10315703|Muscari cortada fresca verde|O|O||D||1
10315704|Muscari cortada fresca latifolia|O|O||D||1
10315705|Muscari cortada fresca valerie finn|O|O||D||1
10315800|Narciso cortado fresco|O|O||D||1
10315801|Narciso cortado fresco alegría|O|O||D||1
10315802|Narciso cortado fresco amanecer dorado|O|O||D||1
10315803|Narciso cortado fresco abba paperwhite|O|O||D||1
10315804|Narciso cortado fresco paperwhite|O|O||D||1
10315805|Narciso cortado fresco ojo de faisán|O|O||D||1
10315806|Narciso cortado fresco soleil d’ or|O|O||D||1
10315807|Narciso cortado fresco tete a tete|O|O||D||1
10315808|Narciso cortado fresco thalia|O|O||D||1
10316000|Pimientos ornamentales cortados frescos|O|O||D||1|Paprikas ornamentales cortadas frescas
10316001|Pimiento chile cortado fresco ornamental|O|O||D||1|Paprika ornamental cortada fresca
10316002|Pimiento mezclado cortado fresco ornamental|O|O||D||1|Paprika ornamental mezclada cortada fresca
10316003|Pimiento anaranjado cortado fresco ornamental|O|O||D||1|Paprika ornamental anaranjada cortada fresca
10316004|Pimiento rojo cortado fresco ornamental|O|O||D||1|Paprika ornamental roja cortada fresca
10316005|Pimiento amarillo cortado fresco ornamental|O|O||D||1|Paprika ornamental amarilla cortada fresca
10316100|Estrella de Belén cortada fresca|O|O||D||1
10316101|Estrella de belén cortada fresca arábica|O|O||D||1
10316102|Estrella de belén cortada fresca dubium anaranjada|O|O||D||1
10316103|Estrella de belén cortada fresca umbellada|O|O||D||1
10316104|Estrella de belén cortada fresca dubium blanca|O|O||D||1
10316105|Estrella de belén cortada fresca dubium amarilla|O|O||D||1
10316200|Peonia cortada fresca|O|O||D||1
10316201|Peonia cortada fresca alexander fleming|O|O||D||1
10316202|Peonia cortada fresca coral charm|O|O||D||1
10316203|Peonia cortada fresca suset|O|O||D||1
10316204|Peonia cortada fresca coral supreme|O|O||D||1
10316205|Peonia cortada fresca gardenia doble|O|O||D||1
10316206|Peonia cortada fresca doble jues eli oscura|O|O||D||1
10316207|Peonia cortada fresca soble duquesa blanca|O|O||D||1
10316208|Peonia cortada fresca felix crousse|O|O||D||1
10316209|Peonia cortada fresca festiva máxima|O|O||D||1
10316210|Peonia cortada fresca tesoro del jardín|O|O||D||1
10316211|Peonia cortada fresca kansas rosado oscuro|O|O||D||1
10316212|Peonia cortada fresca karl rosenfelt|O|O||D||1
10316213|Peonia cortada fresca paula fay|O|O||D||1
10316214|Peonia cortada fresca encanto rojo|O|O||D||1
10316215|Peonia cortada fresca pasion roja|O|O||D||1
10316216|Peonia cortada fresca sarah bernhardt roja|O|O||D||1
10316217|Peonia cortada fresca scarlet o’ hara|O|O||D||1
10316218|Peonia cortada fresca shirley temple|O|O||D||1
10316300|Banksia cortada fresca|O|O||D||1|Flores cortadas frescas de árbol madreselva australiano
10316301|Banksia cortada fresca ashbyi|O|O||D||1|Flor de árbol madreselva australiano cortada fresca ashbyi
10316302|Banksia cortada fresca baxteri|O|O||D||1|Flor de árbol madreselva australiano cortada fresca baxteri
10316306|Banksia cortada fresca coccinea|O|O||D||1|Flor de árbol madreselva australiano cortada fresca coccínea
10316311|Banksia cortada fresca ericifolia|O|O||D||1|Flor de árbol madreselva australiano cortada fresca ericifolia
10316315|Banksia cortada fresca verde|O|O||D||1|Flor de árbol madreselva australiano cortada fresca verde
10316322|Banksia cortada fresca menziesii|O|O||D||1|Flor de árbol madreselva australiano cortada fresca menziesii
10316325|Banksia cortada fresca blanco natural|O|O||D||1|Flor de árbol madreselva australiano cortada fresca blanco natural
10316326|Banksia cortada fresca anaranjado|O|O||D||1|Flor de árbol madreselva australiano cortada fresca anaranjado
10316332|Banksia cortada fresca rosada|O|O||D||1|Flor de árbol madreselva australiano cortada fresca rosada
10316400|Ranúculo cortado fresco|O|O||D||1
10316401|Ranúnculo cortado fresco chocolate|O|O||D||1
10316402|Ranúnculo cortado fresco elegancia|O|O||D||1
10316403|Ranúnculo cortado fresco verde|O|O||D||1
10316404|Ranúnculo cortado fresco grimaldi|O|O||D||1
10316405|Ranúnculo cortado fresco rosado fuerte|O|O||D||1
10316406|Ranúnculo cortado fresco rosado claro|O|O||D||1
10316407|Ranúnculo cortado fresco anaranjado|O|O||D||1
10316408|Ranúnculo cortado fresco centro verde|O|O||D||1
10316409|Ranúnculo cortado fresco rosado|O|O||D||1
10316410|Ranúnculo cortado fresco rojo|O|O||D||1
10316411|Ranúnculo cortado fresco blanco|O|O||D||1
10316412|Ranúnculo cortado fresco amarillo|O|O||D||1
10316413|Ranúnculo cortado fresco salmón|O|O||D||1
10316500|Escabiosa cortada fresca|O|O||D||1|Flores del acerico cortadas frescas
10316501|Escabiosa cortada fresca anual|O|O||D||1|Flor del acerico cortada fresca anual
10316502|Escabiosa cortada fresca negra|O|O||D||1|Flor del acerico cortada fresca negra
10316503|Escabiosa cortada fresca caucásica azul|O|O||D||1|Flor del acerico cortada fresca caucásica azul
10316504|Escabiosa cortada fresca caucásica rosada|O|O||D||1|Flor del acerico cortada fresca caucásica rosada
10316505|Escabiosa cortada fresca caucásica vainas|O|O||D||1|Flor del acerico cortada fresca caucásica vainas
10316506|Escabiosa cortada fresca caucásica blanca|O|O||D||1|Flor del acerico cortada fresca caucásica blanca
10316507|Escabiosa cortada fresca fresa|O|O||D||1|Flor del acerico cortada fresca fresa
10316600|Retama de escobas cortada fresca|O|O||D||1
10316601|Retama de escobas cortada fresca rosada|O|O||D||1
10316602|Retama de escobas cortada fresca púrpura|O|O||D||1
10316603|Retama de escobas cortada fresca blanca|O|O||D||1
10316604|Retama de escobas cortada fresca amarilla|O|O||D||1
10316700|Boca de dragón cortada fresca|O|O||D||1
10316701|Boca de dragón cortada fresca bicolor|O|O||D||1
10316702|Boca de dragón cortada fresca burgundy|O|O||D||1
10316703|Boca de dragón cortada fresca rosado fuerte|O|O||D||1
10316704|Boca de dragón cortada fresca lavanda|O|O||D||1
10316705|Boca de dragón cortada fresca anaranjado claro|O|O||D||1
10316706|Boca de dragón cortada fresca rosado claro|O|O||D||1
10316707|Boca de dragón cortada fresca anaranjado|O|O||D||1
10316708|Boca de dragón cortada fresca blanco|O|O||D||1
10316709|Boca de dragón cortada fresca amarillo|O|O||D||1
10316800|Romero del pantano cortada fresca|O|O||D||1|Siemprevivas azules cortadas frescas
10316801|Romero del pantano cortada fresca azul|O|O||D||1|Siempreviva azul cortada fresca azul
10316802|Romero del pantano cortada fresca lavanda|O|O||D||1|Siempreviva azul cortada fresca lavanda
10316803|Romero del pantano cortada fresca durazno|O|O||D||1|Siempreviva azul cortada fresca durazno
10316804|Romero del pantano cortada fresca rosada|O|O||D||1|Siempreviva azul cortada fresca rosada
10316805|Romero del pantano cortada fresca púrpura|O|O||D||1|Siempreviva azul cortada fresca púrpura
10316806|Romero del pantano cortada fresca espuma de mar|O|O||D||1|Siempreviva azul cortada fresca espuma de mar
10316807|Romero del pantano cortada fresca blanca|O|O||D||1|Siempreviva azul cortada fresca blanca
10316808|Romero del pantano cortada fresca amarilla|O|O||D||1|Siempreviva azul cortada fresca amarilla
10316900|Matiola cortada fresca|O|O||D||1|Alhelís cortadas frescas
10316901|Matiola cortada fresca apricot|O|O||D||1|Alhelí cortada fresca apricot
10316902|Matiola cortada fresca crema|O|O||D||1|Alhelí cortada fresca crema
10316903|Matiola cortada fresca fucsia|O|O||D||1|Alhelí cortada fresca fucsia
10316904|Matiola cortada fresca lavanda|O|O||D||1|Alhelí cortada fresca lavanda
10316905|Matiola cortada fresca lavanda claro|O|O||D||1|Alhelí cortada fresca lavanda claro
10316906|Matiola cortada fresca rosada|O|O||D||1|Alhelí cortada fresca rosada
10316907|Matiola cortada fresca púrpura|O|O||D||1|Alhelí cortada fresca púrpura
10316908|Matiola cortada fresca rojo rubí|O|O||D||1|Alhelí cortada fresca rojo rubí
10316909|Matiola cortada fresca enamorada rosda|O|O||D||1|Alhelí cortada fresca enamorada rosada
10316910|Matiola cortada fresca blanca|O|O||D||1|Alhelí cortada fresca blanca
10317000|Girasol cortada fresca|O|O||D||1
10317001|Girasol cortada fresca tinte festivo|O|O||D||1
10317002|Girasol cortada fresca mahogany|O|O||D||1
10317003|Girasol cortada fresca rayo de sol|O|O||D||1
10317004|Girasol cortada fresca brillo del sol|O|O||D||1
10317005|Girasol cortada fresca salpicada de sol|O|O||D||1
10317006|Girasol cortada fresca oso de peluche|O|O||D||1
10317100|Guisante de olor cortado fresco|O|O||D||1
10317101|Guisante de olor cortado fresco verde teñido|O|O||D||1
10317102|Guisante de olor cortado fresco rosado fuerte|O|O||D||1
10317103|Guisante de olor cortado fresco lavanda|O|O||D||1
10317104|Guisante de olor cortado fresco rosado claro|O|O||D||1
10317105|Guisante de olor cortado fresco anaranjado|O|O||D||1
10317106|Guisante de olor cortado fresco durazno teñido|O|O||D||1
10317107|Guisante de olor cortado fresco púrpura|O|O||D||1
10317108|Guisante de olor cortado fresco blanco|O|O||D||1
10317200|Cardo cortado fresco|O|O||D||1
10317201|Cardo cortado fresco alpinum|O|O||D||1
10317202|Cardo cortado fresco echinops|O|O||D||1
10317203|Cardo cortado fresco eryngium árabe|O|O||D||1
10317204|Cardo cortado fresco eryngium azul|O|O||D||1
10317205|Cardo cortado fresco eryngium orión|O|O||D||1
10317206|Cardo cortado fresco eryngium frambuesa|O|O||D||1
10317207|Cardo cortado fresco eryngium supernova|O|O||D||1
10317208|Cardo cortado fresco eryngium campanita|O|O||D||1
10317300|Tulipán cortado fresco|O|O||D||1
10317301|Tulipán cortado fresco adrem|O|O||D||1
10317302|Tulipán cortado fresco apricot|O|O||D||1
10317303|Tulipán cortado fresco bicolor rojo y amarillo|O|O||D||1
10317304|Tulipán cortado fresco doble bicolor|O|O||D||1
10317305|Tulipán cortado fresco doble rosado|O|O||D||1
10317306|Tulipán cortado fresco doble rojo|O|O||D||1
10317307|Tulipán cortado fresco doble blanco|O|O||D||1
10317308|Tulipán cortado fresco doble amarillo|O|O||D||1
10317309|Tulipán cortado fresco francés avignon|O|O||D||1
10317310|Tulipán cortado fresco francés camarque|O|O||D||1
10317311|Tulipán cortado fresco francés dordogne|O|O||D||1
10317312|Tulipán cortado fresco francés fiat|O|O||D||1
10317313|Tulipán cortado fresco francés flamboyant|O|O||D||1
10317314|Tulipán cortado fresco francés flaming parrot|O|O||D||1
10317315|Tulipán cortado fresco francés florissa|O|O||D||1
10317316|Tulipán cortado fresco francés doble maureen|O|O||D||1
10317317|Tulipán cortado fresco francés maureen|O|O||D||1
10317318|Tulipán cortado fresco francés menton|O|O||D||1
10317319|Tulipán cortado fresco francés montpellier|O|O||D||1
10317320|Tulipán cortado fresco francés naranja unique|O|O||D||1
10317321|Tulipán cortado fresco francés peonia reconocido único|O|O||D||1
10317322|Tulipán cortado fresco francés loro rosado|O|O||D||1
10317323|Tulipán cortado fresco francés princesa unique|O|O||D||1
10317324|Tulipán cortado fresco francés reconocido|O|O||D||1
10317325|Tulipán cortado fresco francés schepppers|O|O||D||1
10317326|Tulipán cortado fresco francés gamuza|O|O||D||1
10317327|Tulipán cortado fresco francés toyota|O|O||D||1
10317328|Tulipán cortado fresco francés loro weber|O|O||D||1
10317329|Tulipán cortado fresco francés loro blanco|O|O||D||1
10317330|Tulipán cortado fresco lavanda de borde crespo|O|O||D||1
10317331|Tulipán cortado fresco rosado fuerte|O|O||D||1
10317332|Tulipán cortado fresco rosado fuerte hoja variegada|O|O||D||1
10317333|Tulipán cortado fresco lavanda|O|O||D||1
10317334|Tulipán cortado fresco rosado claro hoja variegada|O|O||D||1
10317335|Tulipán cortado fresco viuda alegre|O|O||D||1
10317336|Tulipán cortado fresco anaranjado|O|O||D||1
10317337|Tulipán cortado fresco loro negro|O|O||D||1
10317338|Tulipán cortado fresco loro estela rijnveld|O|O||D||1
10317339|Tulipán cortado fresco llameante|O|O||D||1
10317340|Tulipán cortado fresco loro verde|O|O||D||1
10317341|Tulipán cortado fresco loro lavanda|O|O||D||1
10317342|Tulipán cortado fresco loro anaranjado|O|O||D||1
10317343|Tulipán cortado fresco loro durazno|O|O||D||1
10317344|Tulipán cortado fresco loro rosado|O|O||D||1
10317345|Tulipán cortado fresco loro rojo|O|O||D||1
10317346|Tulipán cortado fresco loro rojo rococó|O|O||D||1
10317347|Tulipán cortado fresco loro weber|O|O||D||1
10317348|Tulipán cortado fresco loro blanco|O|O||D||1
10317349|Tulipán cortado fresco loro rosado|O|O||D||1
10317350|Tulipán cortado fresco rosado|O|O||D||1
10317351|Tulipán cortado fresco púrpura|O|O||D||1
10317352|Tulipán cortado fresco rojo|O|O||D||1
10317353|Tulipán cortado fresco especias|O|O||D||1
10317354|Tulipán cortado fresco blanco|O|O||D||1
10317355|Tulipán cortado fresco amarillo|O|O||D||1
10317400|Flor de cera cortada fresca|O|O||D||1
10317401|Flor de cera cortada fresca alba|O|O||D||1
10317402|Flor de cera cortada fresca bicolor|O|O||D||1
10317403|Flor de cera cortada fresca chichilla|O|O||D||1
10317404|Flor de cera cortada fresca reina danzante|O|O||D||1
10317405|Flor de cera cortada fresca dinamarca|O|O||D||1
10317406|Flor de cera cortada fresca denmar|O|O||D||1
10317407|Flor de cera cortada fresca híbrida pastel flor gema|O|O||D||1
10317408|Flor de cera cortada fresca híbrida rosada flor gema|O|O||D||1
10317409|Flor de cera cortada fresca híbrida blanca rubia|O|O||D||1
10317410|Flor de cera cortada fresca híbrida eric john|O|O||D||1
10317411|Flor de cera cortada fresca híbrida dama pintada|O|O||D||1
10317412|Flor de cera cortada fresca híbrida revelación|O|O||D||1
10317413|Flor de cera cortada fresca híbrida bola de nieve|O|O||D||1
10317414|Flor de cera cortada fresca juriens brook|O|O||D||1
10317415|Flor de cera cortada fresca lady stephanie rosada|O|O||D||1
10317416|Flor de cera cortada fresca madonna|O|O||D||1
10317417|Flor de cera cortada fresca mini blanca|O|O||D||1
10317418|Flor de cera cortada fresca anaranjada|O|O||D||1
10317419|Flor de cera cortada fresca perla|O|O||D||1
10317420|Flor de cera cortada fresca pixie moon|O|O||D||1
10317421|Flor de cera cortada fresca orgullo púrpura|O|O||D||1
10317422|Flor de cera cortada fresca roja|O|O||D||1
10317423|Flor de cera cortada fresca wanaroo|O|O||D||1
10317424|Flor de cera cortada fresca amarilla|O|O||D||1
10317500|Hierba de aquiles cortada fresca|O|O||D||1
10317501|Hierba de aquiles cortada fresca burgundy|O|O||D||1
10317502|Hierba de aquiles cortada fresca crema campesina|O|O||D||1
10317503|Hierba de aquiles cortada fresca rosado campesino|O|O||D||1
10317504|Hierba de aquiles cortada fresca moonshine|O|O||D||1
10317505|Hierba de aquiles cortada fresca anaranjado|O|O||D||1
10317506|Hierba de aquiles cortada fresca durazno|O|O||D||1
10317507|Hierba de aquiles cortada fresca rosada|O|O||D||1
10317508|Hierba de aquiles cortada fresca rojo teñido|O|O||D||1
10317509|Hierba de aquiles cortada fresca blanca|O|O||D||1
10317510|Hierba de aquiles cortada fresca amarilla|O|O||D||1
10317600|Zinia cortada fresca|O|O||D||1|Cinias (guadalajaras) cortadas frescas
10317601|Zinia cortada fresca amarilla|O|O||D||1|Cinia (guadalajara) cortada fresca amarilla
10317602|Zinia cortada fresca mini|O|O||D||1|Cinia (guadalajara) cortada fresca mini
10317603|Zinia cortada fresca rosado|O|O||D||1|Cinia (guadalajara) cortada fresca rosado
10317604|Zinia cortada fresca rojo|O|O||D||1|Cinia (guadalajara) cortada fresca rojo
10317605|Zinia cortada fresca salmón|O|O||D||1|Cinia (guadalajara) cortada fresca salmón
10317606|Zinia cortada fresca amarillo|O|O||D||1|Cinia (guadalajara) cortada fresca amarillo
10317700|Forsythia cortada fresca|O|O||D||1
10317701|Forsythia cortada fresca viridissima|O|O||D||1
10317702|Forsythia cortada fresca giraldiana|O|O||D||1
10317703|Forsythia cortada fresca mira|O|O||D||1
10317704|Forsythia cortada fresca suspensa|O|O||D||1
10317705|Forsythia cortada fresca intermedia|O|O||D||1
10317706|Forsythia cortada fresca variabilis|O|O||D||1
10317707|Forsythia cortada fresca ovate|O|O||D||1
10317708|Forsythia cortada fresca intermedia lynwood|O|O||D||1
10317800|Geranio cortado fresco|O|O||D||1
10317801|Geranio cortado fresco argenteum|O|O||D||1
10317802|Geranio cortado fresco cinereum|O|O||D||1
10317803|Geranio cortado fresco clarkei|O|O||D||1
10317804|Geranio cortado fresco dalmaticum|O|O||D||1
10317805|Geranio cortado fresco endressii|O|O||D||1
10317806|Geranio cortado fresco eriostemon|O|O||D||1
10317807|Geranio cortado fresco farreri|O|O||D||1
10317808|Geranio cortado fresco himalayense o grandiflora|O|O||D||1
10317809|Geranio cortado fresco ibericum|O|O||D||1
10317810|Geranio cortado fresco macrorhizum o raiz grande|O|O||D||1
10317811|Geranio cortado fresco maculatum|O|O||D||1
10317812|Geranio cortado fresco nodosum|O|O||D||1
10317813|Geranio cortado fresco phaeum|O|O||D||1
10317814|Geranio cortado fresco platypetalum|O|O||D||1
10317815|Geranio cortado fresco pratense|O|O||D||1
10317816|Geranio cortado fresco procurrens|O|O||D||1
10317817|Geranio cortado fresco psilostemon|O|O||D||1
10317818|Geranio cortado fresco pylzowianum|O|O||D||1
10317819|Geranio cortado fresco renardii|O|O||D||1
10317820|Geranio cortado fresco sanguineum o sangruento|O|O||D||1
10317821|Geranio cortado fresco sylvaticum|O|O||D||1
10317822|Geranio cortado fresco traversii|O|O||D||1
10317823|Geranio cortado fresco tuberosum|O|O||D||1
10317824|Geranio cortado fresco versicolor|O|O||D||1
10317825|Geranio cortado fresco wallachianum|O|O||D||1
10317826|Geranio cortado fresco wlassovianum|O|O||D||1
10317827|Geranio cortado fresco x magnificum o llamativo|O|O||D||1
10317900|Amaryllis cortada fresca|O|O||D||1|Lirios estrella cortados frescos
10317901|Amaryllis cortada fresca aglaiae|O|O||D||1|Lirio estrella cortado fresco aglaiae
10317902|Amaryllis cortada fresca amaru|O|O||D||1|Lirio estrella cortado fresco amaru
10317903|Amaryllis cortada fresca angustifolium|O|O||D||1|Lirio estrella cortado fresco angustifolium
10317904|Amaryllis cortada fresca anzaldoi|O|O||D||1|Lirio estrella cortado fresco anzaldoi
10317905|Amaryllis cortada fresca araripinum|O|O||D||1|Lirio estrella cortado fresco araripinum
10317906|Amaryllis cortada fresca arboricola|O|O||D||1|Lirio estrella cortado fresco arborícola
10317907|Amaryllis cortada fresca argentinum|O|O||D||1|Lirio estrella cortado fresco argentinum
10317908|Amaryllis cortada fresca aulicum|O|O||D||1|Lirio estrella cortado fresco aulicum
10317909|Amaryllis cortada fresca aviflorum|O|O||D||1|Lirio estrella cortado fresco aviflorum
10317910|Amaryllis cortada fresca barreirasum|O|O||D||1|Lirio estrella cortado fresco barreirasum
10317911|Amaryllis cortada fresca blossfeldiae|O|O||D||1|Lirio estrella cortado fresco blossfeldiae
10317912|Amaryllis cortada fresca blumenavium|O|O||D||1|Lirio estrella cortado fresco blumenavium
10317913|Amaryllis cortada fresca brasilianum|O|O||D||1|Lirio estrella cortado fresco brasilianum
10317914|Amaryllis cortada fresca breviflorum|O|O||D||1|Lirio estrella cortado fresco breviflorum
10317915|Amaryllis cortada fresca bukasovii|O|O||D||1|Lirio estrella cortado fresco bukasovii
10317916|Amaryllis cortada fresca calyptratum|O|O||D||1|Lirio estrella cortado fresco calyptratum
10317917|Amaryllis cortada fresca caupolicanense|O|O||D||1|Lirio estrella cortado fresco caupolicanense
10317918|Amaryllis cortada fresca chionedyanthum|O|O||D||1|Lirio estrella cortado fresco chionedyanthum
10317919|Amaryllis cortada fresca condemaita|O|O||D||1|Lirio estrella cortado fresco condemaita
10317920|Amaryllis cortada fresca corriense|O|O||D||1|Lirio estrella cortado fresco corriense
10317921|Amaryllis cortada fresca cuzcoense|O|O||D||1|Lirio estrella cortado fresco cuzcoense
10317922|Amaryllis cortada fresca curitibanum|O|O||D||1|Lirio estrella cortado fresco curitibanum
10317923|Amaryllis cortada fresca cybister|O|O||D||1|Lirio estrella cortado fresco cybister
10317924|Amaryllis cortada fresca divijuliani|O|O||D||1|Lirio estrella cortado fresco divijuliani
10317925|Amaryllis cortada fresca evansiae|O|O||D||1|Lirio estrella cortado fresco evansiae
10317926|Amaryllis cortada fresca ferreyrae|O|O||D||1|Lirio estrella cortado fresco ferreyrae
10317927|Amaryllis cortada fresca forgetii|O|O||D||1|Lirio estrella cortado fresco forgetii
10317928|Amaryllis cortada fresca fosteri|O|O||D||1|Lirio estrella cortado fresco fosteri
10317929|Amaryllis cortada fresca fuscum|O|O||D||1|Lirio estrella cortado fresco fuscum
10317930|Amaryllis cortada fresca glaucescens|O|O||D||1|Lirio estrella cortado fresco glaucescens
10317931|Amaryllis cortada fresca goianum|O|O||D||1|Lirio estrella cortado fresco goianum
10317932|Amaryllis cortada fresca guarapuavicum|O|O||D||1|Lirio estrella cortado fresco guarapuavicum
10317933|Amaryllis cortada fresca harrisonii|O|O||D||1|Lirio estrella cortado fresco harrisonii
10317934|Amaryllis cortada fresca hugoi|O|O||D||1|Lirio estrella cortado fresco hugoi
10317935|Amaryllis cortada fresca iguazuanum|O|O||D||1|Lirio estrella cortado fresco iguazuanum
10317936|Amaryllis cortada fresca illustre|O|O||D||1|Lirio estrella cortado fresco illustre
10317937|Amaryllis cortada fresca intiflorum|O|O||D||1|Lirio estrella cortado fresco intiflorum
10317938|Amaryllis cortada fresca kromeri|O|O||D||1|Lirio estrella cortado fresco kromeri
10317939|Amaryllis cortada fresca lapacense|O|O||D||1|Lirio estrella cortado fresco lapacense
10317940|Amaryllis cortada fresca leonardii|O|O||D||1|Lirio estrella cortado fresco leonardii
10317941|Amaryllis cortada fresca leopoldii|O|O||D||1|Lirio estrella cortado fresco leopoldii
10317942|Amaryllis cortada fresca macbridei|O|O||D||1|Lirio estrella cortado fresco macbridei
10317943|Amaryllis cortada fresca machupijchense|O|O||D||1|Lirio estrella cortado fresco machupijchense
10317944|Amaryllis cortada fresca mandonii|O|O||D||1|Lirio estrella cortado fresco mandonii
10317945|Amaryllis cortada fresca minasgerais|O|O||D||1|Lirio estrella cortado fresco minasgerais
10317946|Amaryllis cortada fresca miniatum|O|O||D||1|Lirio estrella cortado fresco miniatum
10317947|Amaryllis cortada fresca mollevillquense|O|O||D||1|Lirio estrella cortado fresco mollevillquense
10317948|Amaryllis cortada fresca morelianum|O|O||D||1|Lirio estrella cortado fresco morelianum
10317949|Amaryllis cortada fresca nelsonii|O|O||D||1|Lirio estrella cortado fresco nelsonii
10317950|Amaryllis cortada fresca oconoquense|O|O||D||1|Lirio estrella cortado fresco oconoquense
10317951|Amaryllis cortada fresca papilio|O|O||D||1|Lirio estrella cortado fresco papilio
10317952|Amaryllis cortada fresca paquichanum|O|O||D||1|Lirio estrella cortado fresco paquichanum
10317953|Amaryllis cortada fresca paradisiacum|O|O||D||1|Lirio estrella cortado fresco paradisiacum
10317954|Amaryllis cortada fresca pardinum|O|O||D||1|Lirio estrella cortado fresco pardinum
10317955|Amaryllis cortada fresca parodii|O|O||D||1|Lirio estrella cortado fresco parodii
10317956|Amaryllis cortada fresca petiolatum|O|O||D||1|Lirio estrella cortado fresco petiolatum
10317957|Amaryllis cortada fresca psittacinum|O|O||D||1|Lirio estrella cortado fresco psittacinum
10317958|Amaryllis cortada fresca puniceum|O|O||D||1|Lirio estrella cortado fresco puniceum
10317959|Amaryllis cortada fresca reginae|O|O||D||1|Lirio estrella cortado fresco reginae
10317960|Amaryllis cortada fresca reticulatum|O|O||D||1|Lirio estrella cortado fresco reticulatum
10317961|Amaryllis cortada fresca rubropictum|O|O||D||1|Lirio estrella cortado fresco rubropictum
10317962|Amaryllis cortada fresca santacatarina|O|O||D||1|Lirio estrella cortado fresco
10317963|Amaryllis cortada fresca solandraeflorum|O|O||D||1|Lirio estrella cortado fresco solandraeflorum
10317964|Amaryllis cortada fresca starkiorum|O|O||D||1|Lirio estrella cortado fresco starkiorum
10317965|Amaryllis cortada fresca striatum|O|O||D||1|Lirio estrella cortado fresco striatum
10317966|Amaryllis cortada fresca stylosum|O|O||D||1|Lirio estrella cortado fresco stylosum
10317967|Amaryllis cortada fresca teyucuarense|O|O||D||1|Lirio estrella cortado fresco teyucuarense
10317968|Amaryllis cortada fresca traubii|O|O||D||1|Lirio estrella cortado fresco traubii
10317969|Amaryllis cortada fresca vargasii|O|O||D||1|Lirio estrella cortado fresco vargasii
10317970|Amaryllis cortada fresca variegatum|O|O||D||1|Lirio estrella cortado fresco variegatum
10317971|Amaryllis cortada fresca vittatum|O|O||D||1|Lirio estrella cortado fresco vittatum
10317972|Amaryllis cortada fresca yungacense|O|O||D||1|Lirio estrella cortado fresco yungacense
10318000|Rubdeckia cortada fresca|O|O||D||1|Equináceas cortadas frescas
10318001|Rubdeckia cortada fresca alpicola|O|O||D||1|Equinácea cortada fresca alpicola
10318002|Rubdeckia cortada fresca amplexicaulis|O|O||D||1|Equinácea cortada fresca amplexicaulis
10318003|Rubdeckia cortada fresca auriculata|O|O||D||1|Equinácea cortada fresca auriculata
10318004|Rubdeckia cortada fresca bicolor|O|O||D||1|Equinácea cortada fresca bicolor
10318005|Rubdeckia cortada fresca californica|O|O||D||1|Equinácea cortada fresca califórnica
10318006|Rubdeckia cortada fresca fulgida|O|O||D||1|Equinácea cortada fresca fulgida
10318007|Rubdeckia cortada fresca glaucescens|O|O||D||1|Equinácea cortada fresca glaucescens
10318008|Rubdeckia cortada fresca graminifolia|O|O||D||1|Equinácea cortada fresca graminifolia
10318009|Rubdeckia cortada fresca grandiflora|O|O||D||1|Equinácea cortada fresca grandiflora
10318010|Rubdeckia cortada fresca heliopsidis|O|O||D||1|Equinácea cortada fresca heliopsidis
10318011|Rubdeckia cortada fresca hirta|O|O||D||1|Equinácea cortada fresca hirta
10318012|Rubdeckia cortada fresca klamathensis|O|O||D||1|Equinácea cortada fresca klamathensis
10318013|Rubdeckia cortada fresca laciniata|O|O||D||1|Equinácea cortada fresca laciniata
10318014|Rubdeckia cortada fresca máxima|O|O||D||1|Equinácea cortada fresca máxima
10318015|Rubdeckia cortada fresca missouriensis|O|O||D||1|Equinácea cortada fresca missouriensis
10318016|Rubdeckia cortada fresca mohrii|O|O||D||1|Equinácea cortada fresca mohrii
10318017|Rubdeckia cortada fresca mollis|O|O||D||1|Equinácea cortada fresca mollis
10318018|Rubdeckia cortada fresca montana|O|O||D||1|Equinácea cortada fresca montana
10318019|Rubdeckia cortada fresca nítida|O|O||D||1|Equinácea cortada fresca nítida
10318020|Rubdeckia cortada fresca occidentalis|O|O||D||1|Equinácea cortada fresca occidentalis
10318021|Rubdeckia cortada fresca pinnata|O|O||D||1|Equinácea cortada fresca pinnata
10318022|Rubdeckia cortada fresca scabrifolia|O|O||D||1|Equinácea cortada fresca scabrifolia
10318023|Rubdeckia cortada fresca serotina|O|O||D||1|Equinácea cortada fresca serótina
10318024|Rubdeckia cortada fresca speciosa|O|O||D||1|Equinácea cortada fresca speciosa
10318025|Rubdeckia cortada fresca subtomentosa|O|O||D||1|Equinácea cortada fresca subtomentosa
10318026|Rubdeckia cortada fresca texana|O|O||D||1|Equinácea cortada fresca texana
10318027|Rubdeckia cortada fresca triloba|O|O||D||1|Equinácea cortada fresca triloba
10318100|Protea cortada fresca|O|O||D||1
10318101|Protea cortada fresca bouquet|O|O||D||1
10318102|Protea cortada fresca cepillo botella|O|O||D||1
10318103|Protea cortada fresca carnaval|O|O||D||1
10318104|Protea cortada fresca follaje cordata|O|O||D||1
10318105|Protea cortada fresca grandiceps|O|O||D||1
10318106|Protea cortada fresca visón verde|O|O||D||1
10318107|Protea cortada fresca hiedra|O|O||D||1
10318108|Protea cortada fresca rey|O|O||D||1
10318109|Protea cortada fresca nana cones|O|O||D||1
10318110|Protea cortada fresca alfiletero anaranjada|O|O||D||1
10318111|Protea cortada fresca alfiletero tango|O|O||D||1
10318112|Protea cortada fresca alfiletero amarillo|O|O||D||1
10318113|Protea cortada fresca hielo rosado|O|O||D||1
10318114|Protea cortada fresca visón rosado|O|O||D||1
10318115|Protea cortada fresca reina|O|O||D||1
10318116|Protea cortada fresca repens|O|O||D||1
10318117|Protea cortada fresca cuchara de rosas|O|O||D||1
10318118|Protea cortada fresca silvia|O|O||D||1
10318119|Protea cortada fresca sugarbush|O|O||D||1
10318120|Protea cortada fresca susara|O|O||D||1
10318121|Protea cortada fresca waratha|O|O||D||1
10318122|Protea cortada fresca visón blanco|O|O||D||1
10318200|leucadendron cortado fresco|O|O||D||1
10318201|Leucadendron cortado fresco argenteum|O|O||D||1
10318202|Leucadendron cortado fresco delicia de crema|O|O||D||1
10318203|Leucadendron cortado fresco cumosum|O|O||D||1
10318204|Leucadendron cortado fresco discolor|O|O||D||1
10318205|Leucadendron cortado fresco galpini|O|O||D||1
10318206|Leucadendron cortado fresco mina de oro|O|O||D||1
10318207|Leucadendron cortado fresco oro inca|O|O||D||1
10318208|Leucadendron cortado fresco bufón|O|O||D||1
10318209|Leucadendron cortado fresco laxum|O|O||D||1
10318210|Leucadendron cortado fresco mini|O|O||D||1
10318211|Leucadendron cortado fresco oro patea|O|O||D||1
10318212|Leucadendron cortado fresco petra|O|O||D||1
10318213|Leucadendron cortado fresco plumosum|O|O||D||1
10318214|Leucadendron cortado fresco roseta|O|O||D||1
10318215|Leucadendron cortado fresco atardecer safari|O|O||D||1
10318216|Leucadendron cortado fresco atardecer safari spr|O|O||D||1
10318217|Leucadendron cortado fresco speciosa|O|O||D||1
10318218|Leucadendron cortado fresco spray|O|O||D||1
10318219|Leucadendron cortado fresco maravilla wilson|O|O||D||1
10318220|Leucadendron cortado fresco yarden|O|O||D||1
10318300|leucospermum cortado fresco|O|O||D||1
10318301|Leucospermum cortado fresco album|O|O||D||1
10318302|Leucospermum cortado fresco attenuatum|O|O||D||1
10318303|Leucospermum cortado fresco calligerum|O|O||D||1
10318304|Leucospermum cortado fresco conocarpodendron|O|O||D||1
10318305|Leucospermum cortado fresco cordatum|O|O||D||1
10318306|Leucospermum cortado fresco cuneiforme|O|O||D||1
10318307|Leucospermum cortado fresco formosum|O|O||D||1
10318308|Leucospermum cortado fresco glabrum|O|O||D||1
10318309|Leucospermum cortado fresco grandiflorum|O|O||D||1
10318310|Leucospermum cortado fresco harmatum|O|O||D||1
10318311|Leucospermum cortado fresco heterophyllum|O|O||D||1
10318312|Leucospermum cortado fresco innovans|O|O||D||1
10318313|Leucospermum cortado fresco muirii|O|O||D||1
10318314|Leucospermum cortado fresco oleifolium|O|O||D||1
10318315|Leucospermum cortado fresco patersonii|O|O||D||1
10318316|Leucospermum cortado fresco pluridens|O|O||D||1
10318317|Leucospermum cortado fresco praemorsum|O|O||D||1
10318318|Leucospermum cortado fresco prostratum|O|O||D||1
10318319|Leucospermum cortado fresco rodolentum|O|O||D||1
10318320|Leucospermum cortado fresco saxatile|O|O||D||1
10318321|Leucospermum cortado fresco secundifolium|O|O||D||1
10318322|Leucospermum cortado fresco tomentosus|O|O||D||1
10318323|Leucospermum cortado fresco truncatulum|O|O||D||1
10318324|Leucospermum cortado fresco utriculosum|O|O||D||1
10318325|Leucospermum cortado fresco winterii|O|O||D||1
10318326|Leucospermum cortado fresco arenarium|O|O||D||1
10318327|Leucospermum cortado fresco bolusii|O|O||D||1
10318328|Leucospermum cortado fresco catherinae|O|O||D||1
10318329|Leucospermum cortado fresco conocarpum|O|O||D||1
10318330|Leucospermum cortado fresco cordifolium|O|O||D||1
10318331|Leucospermum cortado fresco erubescens|O|O||D||1
10318332|Leucospermum cortado fresco gerrardii|O|O||D||1
10318333|Leucospermum cortado fresco gracile|O|O||D||1
10318334|Leucospermum cortado fresco gueinzii|O|O||D||1
10318335|Leucospermum cortado fresco harpagonatum|O|O||D||1
10318336|Leucospermum cortado fresco hypophyllocarpodendron|O|O||D||1
10318337|Leucospermum cortado fresco lineare|O|O||D||1
10318338|Leucospermum cortado fresco mundii|O|O||D||1
10318339|Leucospermum cortado fresco parile|O|O||D||1
10318340|Leucospermum cortado fresco pendunculatum|O|O||D||1
10318341|Leucospermum cortado fresco praecox|O|O||D||1
10318342|Leucospermum cortado fresco profugum|O|O||D||1
10318343|Leucospermum cortado fresco reflexum|O|O||D||1
10318344|Leucospermum cortado fresco royenifolium|O|O||D||1
10318345|Leucospermum cortado fresco saxosum|O|O||D||1
10318346|Leucospermum cortado fresco spathulatum|O|O||D||1
10318347|Leucospermum cortado fresco tottum|O|O||D||1
10318348|Leucospermum cortado fresco truncatum|O|O||D||1
10318349|Leucospermum cortado fresco vestitum|O|O||D||1
10318350|Leucospermum cortado fresco wittebergense|O|O||D||1
10321500|Agapanto cortado fresco|O|O||D||1|Flor del amor cortada fresca
10321501|Agapanto cortado fresco azul|O|O||D||1|Flor del amor cortada fresca azul
10321502|Agapanto cortado fresco blanco|O|O||D||1|Flor del amor cortada fresca blanco
10321600|Alchimilla cortada fresca|O|O||D||1|Pie de león cortado fresco
10321601|Alchimilla cortada fresca capa de dama|O|O||D||1|Pie de león cortado fresco capa de dama
10321602|Alchimilla cortada fresca robustica|O|O||D||1|Pie de león cortado fresco robustica
10321700|Astilbe cortado fresco|O|O||D||1|Barba falsa de cabra cortadas frescas
10321701|Astilbe cortado fresco rosado fuerte|O|O||D||1|Barba falsa de cabra cortada fresca rosado fuerte
10321702|Astilbe cortado fresco rosado claro|O|O||D||1|Barba falsa de cabra cortada fresca rosado claro
10321703|Astilbe cortado fresco rojo|O|O||D||1|Barba falsa de cabra cortada fresca rojo
10321704|Astilbe cortado fresco blanco|O|O||D||1|Barba falsa de cabra cortada fresca blanco
10321800|angélica cortada fresca|O|O||D||1
10321801|Angélica cortada fresca gigas|O|O||D||1
10321802|Angélica cortada fresca sylvestris|O|O||D||1
10321900|ajenjo cortado fresco|O|O||D||1
10321901|Ajenjo cortado fresco verde|O|O||D||1
10321902|Ajenjo cortado fresco rey dorado|O|O||D||1
10322000|Flor de alcachofa cortada fresca|O|O||D||1
10322001|Flor de alcachofa cortada fresca chocolate|O|O||D||1
10322002|Flor de alcachofa cortada fresca verde|O|O||D||1
10322003|Flor de alcachofa cortada fresca púrpura o floreciente|O|O||D||1
10322100|Astrantia cortada fresca|O|O||D||1
10322101|Astrantia cortada fresca rosada|O|O||D||1
10322102|Astrantia cortada fresca blanca|O|O||D||1
10322200|Flor de banano cortada fresca|O|O||D||1
10322201|Flor de banano cortada fresca anaranjada|O|O||D||1
10322202|Flor de banano cortada fresca antorcha anaranjada|O|O||D||1
10322203|Flor de banano cortada fresca púrpura|O|O||D||1
10322300|Baptisia cortada fresca|O|O||D||1
10322301|Baptisia cortada fresca australis|O|O||D||1
10322302|Baptisia cortada fresca sphaerocarpa|O|O||D||1
10322400|Boronia cortada fresca|O|O||D||1
10322401|Boronia cortada fresca rosada|O|O||D||1
10322402|Boronia cortada fresca amarilla|O|O||D||1
10322500|Bromelia cortada fresca|O|O||D||1
10322501|Bromelia cortada fresca amarilla reg|O|O||D||1
10322502|Bromelia cortada fresca roja reg|O|O||D||1
10322600|Brunia cortada fresca|O|O||D||1
10322601|Brunia albiflora cortada fresca|O|O||D||1
10322602|Brunia albiflora cortada fresca verde|O|O||D||1
10322603|Brunia cortada fresca rocío de plata|O|O||D||1
10322700|Catalea cortada fresca|O|O||D||1|Calatheas cortadas frescas
10322701|Calatea cortada fresca cigarro|O|O||D||1|Calathea cortada fresca cigarro
10322702|Calatea cortada fresca hielo verde|O|O||D||1|Calathea cortada fresca hielo verde
10322703|Calatea cortada fresca serpiente cascabel|O|O||D||1|Calathea cortada fresca serpiente cascabel
10322800|Calcynia cortada fresca|O|O||D||1
10322801|Calcynia cortada fresca rosada|O|O||D||1
10322802|Calcynia cortada fresca princesa|O|O||D||1
10322803|Calcynia cortada fresca blanca|O|O||D||1
10322900|Caléndula cortada fresca|O|O||D||1
10322901|Caléndula cortada fresca anaranjada|O|O||D||1
10322902|Caléndula cortada fresca amarilla|O|O||D||1
10323000|Campanilla cortada fresca|O|O||D||1
10323001|Campanilla cortada fresca azul|O|O||D||1
10323002|Campanilla cortada fresca rosada|O|O||D||1
10323003|Campanilla cortada fresca blanca|O|O||D||1
10323100|Cestrum cortado fresco|O|O||D||1
10323101|Cestrum cortado fresco rojo|O|O||D||1
10323102|Cestrum cortado fresco rojo zohar|O|O||D||1
10323103|Cestrum cortado fresco amarillo|O|O||D||1
10323200|Chasmante cortada fresca|O|O||D||1
10323201|Chasmante floribunda cortada fresca amarilla|O|O||D||1
10323202|Chasmante floribunda cortada fresca anaranjada|O|O||D||1
10323300|Costus cortada fresca|O|O||D||1
10323301|Costus barbada cortada fresca|O|O||D||1
10323302|Costus cortada fresca cabeza de indio|O|O||D||1
10323400|Vara de San José cortada fresca|O|O||D||1|Montbretias cortadas frescas
10323401|Vara de san josé lucifer cortada fresca|O|O||D||1|Montbretia lucifer cortada fresca
10323402|Vara de san josé cortada fresca vainas|O|O||D||1|Montbretia cortada fresca vainas
10323403|Vara de san josé cortada fresca amarilla|O|O||D||1|Montbretia cortada fresca amarilla
10323500|Lirio del Fuego cortado fresco|O|O||D||1|Vallotas cortadas frescas
10323501|Lirio del fuego cortado fresco anaranjado brillante|O|O||D||1|Vallota cortada fresca anaranjado brillante
10323502|Lirio del fuego cortado fresco crema|O|O||D||1|Vallota cortada fresca crema
10323503|Lirio del fuego cortado fresco anaranjado|O|O||D||1|Vallota cortada fresca anaranjado
10323504|Lirio del fuego cortado fresco amarillo|O|O||D||1|Vallota cortada fresca amarillo
10323600|Flor del muelle cortada fresca|O|O||D||1
10323601|Flor del muelle cortada fresca verde|O|O||D||1
10323602|Flor del muelle cortada fresca roja|O|O||D||1
10323700|Planta erizo cortada fresca|O|O||D||1
10323701|Planta erizo cortada fresca tintura negra|O|O||D||1
10323702|Planta erizo cortada fresca tintura anaranjada|O|O||D||1
10323800|Manzanilla cortada fresca|O|O||D||1
10323801|Manzanilla cortada fresca sencilla vegmo|O|O||D||1
10323802|Manzanilla cortada fresca doble blanca|O|O||D||1
10323803|Manzanilla cortada fresca bola de nieve|O|O||D||1
10323804|Manzanilla cortada fresca blanca|O|O||D||1
10323900|Nomeolvides cortada fresca|O|O||D||1
10323901|Nomeolvides cortada fresca azul|O|O||D||1
10323902|Nomeolvides cortada fresca blanca|O|O||D||1
10324000|Gallardia cortada fresca|O|O||D||1
10324001|Gallardia cortada fresca anaranjada|O|O||D||1
10324002|Gallardia cortada fresca amarilla|O|O||D||1
10324100|Genciana cortada fresca|O|O||D||1
10324101|Genciana cortada fresca azul|O|O||D||1
10324102|Genciana cortada fresca blanca|O|O||D||1
10324200|Gladiolo cortado fresco|O|O||D||1
10324201|Gladiolo cortado fresco glamini rosado|O|O||D||1
10324202|Gladiolo cortado fresco glamini rojo|O|O||D||1
10324300|Gloriosa cortada fresca|O|O||D||1
10324301|Gloriosa cortada fresca anaranjada|O|O||D||1
10324302|Gloriosa cortada fresca roja|O|O||D||1
10324303|Gloriosa cortada fresca amarilla|O|O||D||1
10324400|Violeta silvestre cortada fresca|O|O||D||1|Vadamallis cortadas frescas
10324401|Violeta silvestre cortada fresca anaranjada|O|O||D||1|Vadamalli cortada fresca anaranjada
10324402|Violeta silvestre cortada fresca roja|O|O||D||1|Vadamalli cortada fresca roja
10324500|Eléboro cortado fresco|O|O||D||1|Hierbas de ballesteros cortadas frescas
10324501|Eléboro cortado fresco verde|O|O||D||1|Hierba de ballesteros cortado fresco verde
10324502|Eléboro cortado fresco rayo de luna|O|O||D||1|Hierba de ballesteros cortado fresco rayo de luna
10324600|Ixia cortada fresca|O|O||D||1
10324601|Ixia cortada fresca rosada|O|O||D||1
10324602|Ixia cortada fresca blanca|O|O||D||1
10324700|Liatrises cortadas frescas|O|O||D||1
10324701|Liatris cortada fresca púrpura|O|O||D||1
10324702|Liatris cortada fresca spray|O|O||D||1
10324703|Liatris cortada fresca blanca|O|O||D||1
10324800|Lysimachia cortada fresca|O|O||D||1
10324801|Lysimachia punctata cortada fresca|O|O||D||1
10324802|Lysimachia vulgaris cortada fresca|O|O||D||1
10324803|Lysimachia blanca cortada fresca|O|O||D||1
10324804|Lysimachia amarilla cortada fresca|O|O||D||1
10324900|Maraca cortada fresca|O|O||D||1
10324901|Maraca cortada fresca marrón|O|O||D||1
10324902|Maraca cortada fresca shampoo ginger|O|O||D||1
10325000|Caléndula cortada fresca|O|O||D||1
10325001|Caléndula cortada fresca francesa|O|O||D||1
10325002|Caléndula cortada fresca verde|O|O||D||1
10325003|Caléndula (marigold) cortada fresca anaranjada|O|O||D||1
10325004|Caléndula (marigold) cortada fresca amarilla|O|O||D||1
10325100|Mimosa cortada fresca|O|O||D||1
10325101|Mimosa cortada fresca azul o púrpura|O|O||D||1
10325102|Mimosa dedo cortada fresca|O|O||D||1
10325103|Mimosa cortada fresca floribunda o italia|O|O||D||1
10325104|Mimosa cortada fresca mirandola|O|O||D||1
10325200|Nerina cortada fresca|O|O||D||1
10325201|Nerina cortada fresca rosada|O|O||D||1
10325202|Nerina samiensis blanca|O|O||D||1
10325300|Flor de nogal cortada fresca|O|O||D||1
10325301|Flor colgante de nogal blanco cortada fresca|O|O||D||1
10325302|Flor sin hojas de nogal blanco cortada fresca|O|O||D||1
10325303|Flor erecta de nogal blanco brasileño cortada fresca|O|O||D||1
10325400|Phlox cortada fresca|O|O||D||1
10325401|Phlox cortada fresca rosado oscur|O|O||D||1
10325402|Phlox cortada fresca lavanda|O|O||D||1
10325403|Phlox cortada fresca rosado claro|O|O||D||1
10325404|Phlox cortada fresca blanca|O|O||D||1
10325500|physostegia cortada fresca|O|O||D||1|Plantas obediente cortadas frescas
10325501|Physostegia cortada fresca rosada|O|O||D||1|Planta obediente cortada fresca rosada
10325502|Physostegia cortada fresca vainas|O|O||D||1|Planta obediente cortada fresca vainas
10325503|Physostegia cortada fresca blanca|O|O||D||1|Planta obediente cortada fresca blanca
10325600|Saponaria cortada fresca|O|O||D||1|Jabonarias cortadas frescas
10325601|Saponaria cortada fresca rosada|O|O||D||1|Jabonaria cortada fresca rosada
10325602|Saponaria cortada fresca blanca|O|O||D||1|Jabonaria cortada fresca blanca
10325700|Sarracenias cortadas frescas|O|O||D||1
10325701|Sarracenia cortada fresca flava rugelii|O|O||D||1
10325800|Sicilia cortada fresca|O|O||D||1|Scillas cortadas frescas
10325801|Sicilia cortada fresca campanulata azul|O|O||D||1|Scilla cortada fresca campanulata azul
10325802|Sicilia cortada fresca campanulata rosada|O|O||D||1|Scilla cortada fresca campanulata rosada
10325803|Sicilia cortada fresca campanulata blanca|O|O||D||1|Scilla cortada fresca campanulata blanca
10325804|Sicilia cortada fresca peruana|O|O||D||1|Scilla cortada fresca peruana
10325900|Sedum cortada fresca|O|O||D||1
10325901|Sedum cortada fresca marrón|O|O||D||1
10325902|Sedum cortada fresca verde|O|O||D||1
10325903|Sedum cortada fresca rosada|O|O||D||1
10325904|Sedum cortada fresca roja|O|O||D||1
10326000|Especies individuales o variedades de flores cortadas frescas|O|O||D||1|Arreglos florales frescos, Coronas funerarias, Flor de cempasúchil cortada fresc
10326001|Agrsotema cortada fresca|O|O||D||1
10326002|Kniphophia o assegai poker cortada fresca|O|O||D||1
10326003|Bellis perennis cortada fresca|O|O||D||1
10326004|Campana de irlanda o molucella cortada fresca|O|O||D||1
10326005|Ave del paraíso cortada fresca|O|O||D||1
10326006|Novia sonrojada cortada fresca|O|O||D||1
10326007|Buddleia o arbusto mariposa cortada fresca|O|O||D||1
10326008|Bupleurum griffithii cortada fresca|O|O||D||1
10326009|California ginesta cortada fresca|O|O||D||1
10326010|Callicarpa púrpura cortada fresca|O|O||D||1
10326011|Campanilla blanca cortada fresca|O|O||D||1
10326012|Penacho dulce cortada fresca|O|O||D||1
10326013|Cariopteris cortada fresca|O|O||D||1
10326014|Centaurea o marco polo cortada fresca|O|O||D||1
10326015|Linterna china cortada fresca|O|O||D||1
10326016|Clematis recta purpurea cortada fresca|O|O||D||1
10326017|Cleome spinosa cortada fresca|O|O||D||1
10326018|Coreopsis cortada fresca|O|O||D||1
10326019|Farolitos de la virgen azul cortada fresca|O|O||D||1
10326020|Cosmos chocolate cortada fresca|O|O||D||1
10326021|Cotinus coggygria cortada fresca|O|O||D||1
10326022|Craspedia o billy bolas cortada fresca|O|O||D||1
10326023|Deutzia alta cortada fresca|O|O||D||1
10326024|Diosma cortada fresca|O|O||D||1
10326025|Echeveria suculenta chupahuevos cortada fresca|O|O||D||1
10326026|Echinacea purpurea cortada fresca|O|O||D||1
10326027|Edelweiss cortada fresca|O|O||D||1
10326028|Erythronium pagoda cortada fresca|O|O||D||1
10326029|Flor de eucalipto cortada fresca|O|O||D||1
10326030|Eucaris o lirio del amazonas cortado fresco|O|O||D||1
10326031|Eucomis o lirio de piña cortado fresco|O|O||D||1
10326032|Eupatorium maculatum cortado fresco|O|O||D||1
10326033|Filipendula cortada fresca|O|O||D||1
10326034|Digitalis cortado fresco|O|O||D||1
10326035|Gilia globo cortada fresca|O|O||D||1
10326036|Globularia de ojo azul cortada fresca|O|O||D||1
10326037|Washington hawthorne cortada fresca|O|O||D||1
10326038|Helenio cortada fresca|O|O||D||1
10326039|Helianto cortada fresca|O|O||D||1
10326040|Herperis matronalis cortada fresca|O|O||D||1
10326041|Houttuynia cordata chameleon cortada fresca|O|O||D||1
10326042|Jacinto con bulbo cortada fresca|O|O||D||1
10326043|Maiz indio cortado fresco|O|O||D||1
10326044|Aro cortado fresco|O|O||D||1
10326045|Arbol del cielo japonés cortado fresco|O|O||D||1
10326046|Enredadera de jazmin florecida cortada fresca|O|O||D||1
10326047|Jatropha curcas o pólvora cortada fresca|O|O||D||1
10326048|Knautia cortada fresca|O|O||D||1
10326049|Kochia sedifolia cortada fresca|O|O||D||1
10326050|Lachenalia romaud cortada fresca|O|O||D||1
10326051|Flor de oereja de oveja cortada fresca|O|O||D||1
10326052|Lavanda cortada fresca|O|O||D||1
10326053|Leucocoryne speciosa cortada fresca|O|O||D||1
10326054|Lythrum cortada fresca|O|O||D||1
10326055|Malva zebrina cortada fresca|O|O||D||1
10326056|Margarita blanca cortada fresca|O|O||D||1
10326057|Montbretia amarilla cortada fresca|O|O||D||1
10326058|Nebelia cortada fresca|O|O||D||1
10326059|Nicotiana cortada fresca|O|O||D||1
10326060|Nigella damascena o amor en la niebla cortada fresca|O|O||D||1
10326061|Vainas nigella cortada fresca|O|O||D||1
10326062|Orquídea de monja cortada fresca|O|O||D||1
10326063|Orquídea verde paphiopedilum|O|O||D||1
10326064|Paranomus cortada fresca|O|O||D||1
10326065|Penstemon husker rojo cortado fresco|O|O||D||1
10326066|Manzana peruana cortada fresca|O|O||D||1|Cactus cortado fresco
10326067|Phlomis sarnia cortada fresca|O|O||D||1
10326068|Didiscus o flor de encaje rosada cortada fresca|O|O||D||1
10326069|Platycodon o flor globo cortada fresca|O|O||D||1
10326070|Retzia capensis cortada fresca|O|O||D||1
10326071|Ricino común cortado fresco|O|O||D||1
10326072|Nieve en el monte cortada fresca|O|O||D||1
10326073|Solidago teñida cortada fresca|O|O||D||1
10326074|Scilla blanca cortada fresca|O|O||D||1|Cebolla albarrana cortada fresca (ornamental)
10326075|Stachys byzantina cortada fresca|O|O||D||1
10326076|Flor de paja cortada fresca|O|O||D||1
10326077|Oscularia suculenta cortada fresca|O|O||D||1
10326078|Flor de tillasandia cortada fresca|O|O||D||1
10326079|Triteleia cortada fresca|O|O||D||1
10326080|Tritoma naranja o chuzo caliente cortada fresca roja|O|O||D||1
10326081|Veronicastrum virginiana cortada fresca|O|O||D||1
10326082|Bromelia vriesea splendens cortada fresca|O|O||D||1|Pluma de indio cortada fresca
10326084|Hipericim o hierba de san juan cortada fresca|O|O||D||1
10326085|Spirea cortada fresca|O|O||D||1
10326086|Yerba de san bonifacio cortada fresca|O|O||D||1
10326100|Sello de salomón (polygonato) cortada fresca|O|O||D||1
10326101|Sello de salomón (polygonato) falso cortada fresca|O|O||D||1
10326102|Sello de salomón (polygonato) variegado cortada fresca|O|O||D||1
10326200|Tanaceto cortado fresco|O|O||D||1
10326201|Tanaceto cortado fresco amazonas|O|O||D||1
10326202|Tanaceto cortado fresco victoria doble blanco|O|O||D||1
10326203|Tanaceto cortado fresco victoria sencillo blanco|O|O||D||1
10326204|Tanaceto cortado fresco vegmo amarillo|O|O||D||1
10326300|Traquelio cortado fresco|O|O||D||1|Flores de la viuda cortadas frescas
10326301|Trachelium jade cortada fresca|O|O||D||1|Flor de la viuda jade cortada fresca
10326302|Trachelium púrpura cortada fresca|O|O||D||1|Flor de la viuda púrpura cortada fresca
10326303|Trachelium blanca cortada fresca|O|O||D||1|Flor de la viuda blanca cortada fresca
10326400|Tuberosas cortadas frescas|O|O||D||1|Nardos cortados frescos
10326401|Tuberosa cortada fresca doble|O|O||D||1|Nardo cortado fresco doble
10326402|Tuberosa cortada fresca sencilla|O|O||D||1|Nardo cortado fresco sencillo
10326500|Tweedias cortadas frescas|O|O||D||1
10326501|Tweedia azul cortada fresca|O|O||D||1
10326502|Tweedia blanca cortada fresca|O|O||D||1
10326600|Verónicas cortadas frescas|O|O||D||1
10326601|Verónica cortada fresca rosada|O|O||D||1
10326602|Verónica cortada fresca púrpura|O|O||D||1
10326603|Verónica cortada fresca blanca|O|O||D||1
10326700|Watsonias cortadas frescas|O|O||D||1
10326701|Watsonia cortada fresca anaranjada|O|O||D||1
10326702|Watsonia cortada fresca rosada|O|O||D||1
10326703|Watsonia cortada fresca roja|O|O||D||1
10326704|Watsonia cortada fresca blanca|O|O||D||1
10331500|Crisantemo cortado fresco pompón|O|O||D||1
10331501|Crisantemo cortado fresco pompón delirock|O|O||D||1
10331502|Crisantemo cortado fresco pompón discovery|O|O||D||1
10331503|Crisantemo cortado fresco pompón focus|O|O||D||1
10331504|Crisantemo cortado fresco pompón jeanne|O|O||D||1
10331505|Crisantemo cortado fresco pompón lady|O|O||D||1
10331506|Crisantemo cortado fresco pompón leidi|O|O||D||1
10331507|Crisantemo cortado fresco pompón lexy|O|O||D||1
10331508|Crisantemo cortado fresco pompón ole|O|O||D||1
10331509|Crisantemo cortado fresco pompón revise|O|O||D||1
10331510|Crisantemo cortado fresco pompón estadista|O|O||D||1
10331511|Crisantemo cortado fresco pompón dulce|O|O||D||1
10331512|Crisantemo cortado fresco pompón yoko ono|O|O||D||1
10331513|Crisantemo cortado fresco pompón zip|O|O||D||1
10331600|Crisantemo cortado fresco pompón margarita|O|O||D||1
10331601|Crisantemo cortado fresco pompón artista rosado|O|O||D||1
10331602|Crisantemo cortado fresco pompón artista amarillo|O|O||D||1
10331603|Crisantemo cortado fresco pompón atlantis rosado|O|O||D||1
10331604|Crisantemo cortado fresco pompón atlantis blanco|O|O||D||1
10331605|Crisantemo cortado fresco pompón atlantis amarillo|O|O||D||1
10331606|Crisantemo cortado fresco pompón bennie jolink|O|O||D||1
10331607|Crisantemo cortado fresco pompón bennie jolink amarillo|O|O||D||1
10331608|Crisantemo cortado fresco pompón managua bronce|O|O||D||1
10331609|Crisantemo cortado fresco pompón clave|O|O||D||1
10331610|Crisantemo cortado fresco pompón ficción coral|O|O||D||1
10331611|Crisantemo cortado fresco pompón cumbia|O|O||D||1
10331612|Crisantemo cortado fresco pompón cantata oscura|O|O||D||1
10331613|Crisantemo cortado fresco pompón lineker oscuro|O|O||D||1
10331614|Crisantemo cortado fresco pompón dipper|O|O||D||1
10331615|Crisantemo cortado fresco pompón rosado elite|O|O||D||1
10331616|Crisantemo cortado fresco pompón blanco elite|O|O||D||1
10331617|Crisantemo cortado fresco pompón amarillo elite|O|O||D||1
10331618|Crisantemo cortado fresco pompón factor|O|O||D||1
10331619|Crisantemo cortado fresco pompón ficción|O|O||D||1
10331620|Crisantemo cortado fresco pompón fuerza|O|O||D||1
10331621|Crisantemo cortado fresco pompón reagan mejorado|O|O||D||1
10331622|Crisantemo cortado fresco pompón life|O|O||D||1
10331623|Crisantemo cortado fresco pompón managua anaranjado|O|O||D||1
10331624|Crisantemo cortado fresco pompón novedsd bronce cocarde|O|O||D||1
10331625|Crisantemo cortado fresco pompón reagan anaranjado|O|O||D||1
10331626|Crisantemo cortado fresco pompón orinoco|O|O||D||1
10331627|Crisantemo cortado fresco pompón petra|O|O||D||1
10331628|Crisantemo cortado fresco pompón balsas rosado|O|O||D||1
10331629|Crisantemo cortado fresco pompón mona lisa rosado|O|O||D||1
10331630|Crisantemo cortado fresco pompón reagan rosado|O|O||D||1
10331631|Crisantemo cortado fresco pompón marfil reagan|O|O||D||1
10331632|Crisantemo cortado fresco pompón reagan rosado|O|O||D||1
10331633|Crisantemo cortado fresco pompón rebasco|O|O||D||1
10331634|Crisantemo cortado fresco pompón redock|O|O||D||1
10331635|Crisantemo cortado fresco pompón salmón lineker|O|O||D||1
10331636|Crisantemo cortado fresco pompón sheba|O|O||D||1
10331637|Crisantemo cortado fresco pompón sirius|O|O||D||1
10331638|Crisantemo cortado fresco pompón reagan espléndido|O|O||D||1
10331639|Crisantemo cortado fresco pompón reagan soleado|O|O||D||1
10331640|Crisantemo cortado fresco pompón tina|O|O||D||1
10331641|Crisantemo cortado fresco pompón vero|O|O||D||1
10331642|Crisantemo cortado fresco pompón volare|O|O||D||1
10331643|Crisantemo cortado fresco pompón vida blanca|O|O||D||1
10331644|Crisantemo cortado fresco pompón regan blanco|O|O||D||1
10331645|Crisantemo cortado fresco pompón rino blanco|O|O||D||1
10331646|Crisantemo cortado fresco pompón vero amarillo|O|O||D||1
10331647|Crisantemo cortado fresco pompón zenith|O|O||D||1
10331700|Crisantemo cortado fresco espollado cremon|O|O||D||1
10331701|Crisantemo cortado fresco espollado cremon annecy oscura|O|O||D||1
10331702|Crisantemo cortado fresco espollado cremon|O|O||D||1
10331703|Crisantemo cortado fresco espollado cremon atlantis rosado|O|O||D||1
10331704|Crisantemo cortado fresco espollado cremon eleonora bronce|O|O||D||1
10331705|Crisantemo cortado fresco espollado cremon eleonora lila|O|O||D||1
10331706|Crisantemo cortado fresco espollado cremon eleonora rosado|O|O||D||1
10331707|Crisantemo cortado fresco espollado cremon eleonora nieve|O|O||D||1
10331708|Crisantemo cortado fresco espollado cremon eleonora amarillo|O|O||D||1
10331709|Crisantemo cortado fresco espollado cremon idea|O|O||D||1
10331710|Crisantemo cortado fresco espollado cremon ivanna púrpura|O|O||D||1
10331711|Crisantemo cortado fresco espollado cremon minka rosado|O|O||D||1
10331712|Crisantemo cortado fresco espollado cremon listo|O|O||D||1
10331713|Crisantemo cortado fresco espollado cremon sinatra|O|O||D||1
10331714|Crisantemo cortado fresco rover rojo|O|O||D||1
10331800|Crisantemo cortado fresco espollado football|O|O||D||1
10331801|Crisantemo cortado fresco espollado blaze|O|O||D||1
10331802|Crisantemo cortado fresco espollado beso de football|O|O||D||1
10331803|Crisantemo cortado fresco espollado football lavanda / rosado|O|O||D||1
10331804|Crisantemo cortado fresco espollado football resouci|O|O||D||1
10331805|Crisantemo cortado fresco espollado footbal blanco|O|O||D||1
10331806|Crisantemo cortado fresco espollado football amarillo|O|O||D||1
10331807|Crisantemo cortado fresco espollado promenade|O|O||D||1
10331808|Crisantemo cortado fresco espollado rebonnet|O|O||D||1
10331809|Crisantemo cortado fresco espollado reflex|O|O||D||1
10331810|Crisantemo cortado fresco espollado residence|O|O||D||1
10331811|Crisantemo cortado fresco espollado resomee perla|O|O||D||1
10331812|Crisantemo cortado fresco espollado resouci|O|O||D||1
10331900|Crisantemo spider cortado fresco|O|O||D||1
10331901|Crisantemo spider cortado fresco anastasia bronce|O|O||D||1
10331902|Crisantemo spider cortado fresco anastasia bronce oscuro|O|O||D||1
10331903|Crisantemo spider cortado fresco anastasia verde|O|O||D||1
10331904|Crisantemo spider cortado fresco anastasia lila|O|O||D||1
10331905|Crisantemo spider cortado fresco anastasia rosado|O|O||D||1
10331906|Crisantemo spider cortado fresco anastasia púrpura|O|O||D||1
10331907|Crisantemo spider cortado fresco anastasia soleado|O|O||D||1
10331908|Crisantemo spider cortado fresco anastasia blanco|O|O||D||1
10331909|Crisantemo spider cortado fresco bradford|O|O||D||1
10331910|Crisantemo spider cortado fresco delistar blanco|O|O||D||1
10331911|Crisantemo spider cortado fresco delistar amarillo|O|O||D||1
10331912|Crisantemo spider cortado fresco minka|O|O||D||1
10331913|Crisantemo spider cortado fresco natasha soleado|O|O||D||1
10331914|Crisantemo spider cortado fresco pirouette|O|O||D||1
10331915|Crisantemo spider cortado fresco reflejo|O|O||D||1
10331916|Crisantemo spider cortado fresco regata|O|O||D||1
10331917|Crisantemo spider cortado fresco render|O|O||D||1
10331918|Crisantemo spider cortado fresco repertorio|O|O||D||1
10331919|Crisantemo spider cortado fresco resolute|O|O||D||1
10331920|Crisantemo spider cortado fresco resomac|O|O||D||1
10331921|Crisantemo spider cortado fresco trébol|O|O||D||1
10331922|Crisantemo spider cortado fresco talante bronce|O|O||D||1
10331923|Crisantemo spider cortado fresco super blanco|O|O||D||1
10331924|Crisantemo spider cortado fresco super amarillo|O|O||D||1
10331925|Crisantemo spider cortado fresco tierno|O|O||D||1
10331926|Crisantemo spider cortado fresco zembia|O|O||D||1
10332000|Crisantemo cortado fresco  novelty|O|O||D||1
10332001|Crisantemo cortado fresco pompón anecy rosado|O|O||D||1
10332002|Crisantemo cortado fresco pompón ardilo royal|O|O||D||1
10332003|Crisantemo cortado fresco pompón athos|O|O||D||1
10332004|Crisantemo cortado fresco pompón biarritz|O|O||D||1
10332005|Crisantemo cortado fresco pompón bradford anaranjado|O|O||D||1
10332006|Crisantemo cortado fresco pompón bradford|O|O||D||1
10332007|Crisantemo cortado fresco pompón esperma|O|O||D||1
10332008|Crisantemo cortado fresco pompón candor|O|O||D||1
10332009|Crisantemo cortado fresco pompón gallardía|O|O||D||1
10332010|Crisantemo cortado fresco pompón décima|O|O||D||1
10332012|Crisantemo cortado fresco pompón delisun|O|O||D||1
10332013|Crisantemo cortado fresco pompón dion|O|O||D||1
10332014|Crisantemo cortado fresco pompón dorena|O|O||D||1
10332015|Crisantemo cortado fresco pompón dublín|O|O||D||1
10332016|Crisantemo cortado fresco pompón everglades|O|O||D||1
10332017|Crisantemo cortado fresco pompón buenmozo|O|O||D||1
10332018|Crisantemo cortado fresco pompón hasting|O|O||D||1
10332019|Crisantemo cortado fresco pompón high five|O|O||D||1
10332020|Crisantemo cortado fresco pompón mundial mejorado|O|O||D||1
10332021|Crisantemo cortado fresco pompón juanes|O|O||D||1
10332022|Crisantemo cortado fresco pompón kiato verde|O|O||D||1
10332023|Crisantemo cortado fresco pompón kiato|O|O||D||1
10332024|Crisantemo cortado fresco pompón kiwi|O|O||D||1
10332025|Crisantemo cortado fresco pompón madeira|O|O||D||1
10332026|Crisantemo cortado fresco pompón magneto|O|O||D||1
10332027|Crisantemo cortado fresco pompón marimo|O|O||D||1
10332028|Crisantemo cortado fresco pompón matrix|O|O||D||1
10332029|Crisantemo cortado fresco pompón miletta|O|O||D||1
10332030|Crisantemo cortado fresco pompón monalisa|O|O||D||1
10332031|Crisantemo cortado fresco pompón omaha|O|O||D||1
10332032|Crisantemo cortado fresco pompón orinoco púrpura|O|O||D||1
10332033|Crisantemo cortado fresco pompón orinoco amarillo|O|O||D||1
10332034|Crisantemo cortado fresco pompón verde pacífico|O|O||D||1
10332035|Crisantemo cortado fresco pompón blanco puma|O|O||D||1
10332036|Crisantemo cortado fresco pompón amarillo puma|O|O||D||1
10332037|Crisantemo cortado fresco pompón mundial púrpura|O|O||D||1
10332038|Crisantemo cortado fresco pompón regata|O|O||D||1
10332039|Crisantemo cortado fresco pompón remco|O|O||D||1
10332040|Crisantemo cortado fresco pompón royal mundial|O|O||D||1
10332041|Crisantemo cortado fresco pompón sabrina|O|O||D||1
10332042|Crisantemo cortado fresco pompón shakira blanco|O|O||D||1
10332043|Crisantemo cortado fresco pompón sharp|O|O||D||1
10332044|Crisantemo cortado fresco pompón shock|O|O||D||1
10332045|Crisantemo cortado fresco pompón sizzle verde|O|O||D||1
10332046|Crisantemo cortado fresco pompón sizzle rosado|O|O||D||1
10332047|Crisantemo cortado fresco pompón sizzle|O|O||D||1
10332048|Crisantemo cortado fresco pompón sizzle púrpura|O|O||D||1
10332049|Crisantemo cortado fresco pompón sizzle salmón|O|O||D||1
10332050|Crisantemo cortado fresco pompón sizzle amarillo|O|O||D||1
10332051|Crisantemo cortado fresco pompón bandera española|O|O||D||1
10332052|Crisantemo cortado fresco pompón starbust o copo de nieve|O|O||D||1
10332053|Crisantemo cortado fresco pompón cisne|O|O||D||1
10332054|Crisantemo cortado fresco pompón tedcha anaranjado|O|O||D||1
10332055|Crisantemo cortado fresco pompón tierno|O|O||D||1
10332056|Crisantemo cortado fresco pompón oropel|O|O||D||1
10332057|Crisantemo cortado fresco pompón toque|O|O||D||1
10332058|Crisantemo cortado fresco pompón troyes|O|O||D||1
10332059|Crisantemo cortado fresco pompón valesca|O|O||D||1
10332060|Crisantemo cortado fresco pompón anaranjado vikingo|O|O||D||1
10332061|Crisantemo cortado fresco pompón vikingo|O|O||D||1
10332062|Crisantemo cortado fresco pompón reloj|O|O||D||1
10332063|Crisantemo cortado fresco pompón aguja blanco|O|O||D||1
10332064|Crisantemo cortado fresco pompón noche blanca|O|O||D||1
10332065|Crisantemo cortado fresco pompón artista amarillo|O|O||D||1
10332066|Crisantemo cortado fresco pompón ficción amarillo|O|O||D||1
10332067|Crisantemo cortado fresco pompón sharp amarillo|O|O||D||1
10332100|Crisantemo cortado fresco santini|O|O||D||1
10332101|Crisantemo cortado fresco pompón alma|O|O||D||1
10332102|Crisantemo cortado fresco pompón barón|O|O||D||1
10332103|Crisantemo cortado fresco pompón bernardo|O|O||D||1
10332104|Crisantemo cortado fresco pompón bistro|O|O||D||1
10332105|Crisantemo cortado fresco pompón bodega|O|O||D||1
10332106|Crisantemo cortado fresco pompón brisa|O|O||D||1
10332107|Crisantemo cortado fresco pompón centella bronce|O|O||D||1
10332108|Crisantemo cortado fresco pompón costa blanca|O|O||D||1
10332109|Crisantemo cortado fresco pompón creta|O|O||D||1
10332110|Crisantemo cortado fresco pompón deliflame|O|O||D||1
10332111|Crisantemo cortado fresco pompón dalila|O|O||D||1
10332112|Crisantemo cortado fresco pompón dígito|O|O||D||1
10332113|Crisantemo cortado fresco pompón evilio|O|O||D||1
10332114|Crisantemo cortado fresco pompón furense|O|O||D||1
10332115|Crisantemo cortado fresco pompón guía|O|O||D||1
10332116|Crisantemo cortado fresco pompón kerry|O|O||D||1
10332117|Crisantemo cortado fresco pompón kess|O|O||D||1
10332118|Crisantemo cortado fresco pompón lima|O|O||D||1
10332119|Crisantemo cortado fresco pompón lupo|O|O||D||1
10332120|Crisantemo cortado fresco pompón lineker anaranjado|O|O||D||1
10332121|Crisantemo cortado fresco pompón panuco rojo|O|O||D||1
10332122|Crisantemo cortado fresco pompón costa rosado|O|O||D||1
10332123|Crisantemo cortado fresco pompón rafael|O|O||D||1
10332124|Crisantemo cortado fresco pompón refine|O|O||D||1
10332125|Crisantemo cortado fresco pompón regaliz|O|O||D||1
10332126|Crisantemo cortado fresco pompón renella|O|O||D||1
10332127|Crisantemo cortado fresco pompón retorno|O|O||D||1
10332128|Crisantemo cortado fresco pompón río|O|O||D||1
10332129|Crisantemo cortado fresco pompón sabas|O|O||D||1
10332130|Crisantemo cortado fresco pompón target|O|O||D||1
10332131|Crisantemo cortado fresco pompón texto|O|O||D||1
10332132|Crisantemo cortado fresco pompón caballo amarillo|O|O||D||1
10341500|Bouquet cortado fresco de rosa|O|O||D||1
10341501|Bouquet cortado fresco de rosa azul o lavanda o púrpura|O|O||D||1
10341600|Bouquet cortado fresco de clavel|O|O||D||1
10341601|Bouquet cortado fresco de clavel burgundi bi color|O|O||D||1
10341700|Bouquet cortado fresco de mini clavel|O|O||D||1
10341701|Bouquet cortado fresco de mini clavel burgundy|O|O||D||1
10341800|Bouquet cortado fresco de lirio|O|O||D||1|Bouquet cortado fresco de lilis
10341801|Bouquet cortado fresco de lirio asiático black out|O|O||D||1|Bouquet cortado fresco de lili asiático black out
10341900|Bouquet cortado fresco de crisantemo pompón|O|O||D||1|Bouquet cortado fresco de crisantemo de margarita
10341901|Bouquet cortado fresco de crisantemo pompón margarita|O|O||D||1|Bouquet cortado fresco de crisantemo de margarita pompón
10342000|Bouquet cortado fresco de astromelia|O|O||D||1|Bouquet cortado fresco de lirio de campo
10342001|Bouquet cortado fresco de astromelia agropoli|O|O||D||1|Bouquet cortado fresco de lirio de campo agropoli
10342100|Bouquet cortado fresco de flores tropicales|O|O||D||1
10342101|Bouquet cortado fresco de orquidea dendrobium|O|O||D||1
10342200|Bouquet cortado fresco floral mixto|O|O||D||1
10342201|Bouquet cortado fresco de rosa clavel peonía|O|O||D||1
10351500|Bouquet cortado fresco de clavel de floración sencilla|O|O||D||1
10351501|Clavel cortado fresco de floración sencilla burgundy bicolor|O|O||D||1
10351502|Clavel cortado fresco de floración sencilla burgundy|O|O||D||1
10351503|Clavel cortado fresco de floración sencilla cinderella|O|O||D||1
10351504|Clavel cortado fresco de floración sencilla crema bicolor|O|O||D||1
10351505|Clavel cortado fresco de floración sencilla crema|O|O||D||1
10351506|Clavel cortado fresco de floración sencilla verde o prado|O|O||D||1
10351507|Clavel cortado fresco de floración sencilla rosado fuerte|O|O||D||1
10351508|Clavel cortado fresco de floración sencilla verde claro|O|O||D||1
10351509|Clavel cortado fresco de floración sencilla rosado claro|O|O||D||1
10351510|Clavel cortado fresco de floración sencilla anaranjado bicolor|O|O||D||1
10351511|Clavel cortado fresco de floración sencilla anaranjado|O|O||D||1
10351512|Clavel cortado fresco de floración sencilla durazno|O|O||D||1
10351513|Clavel cortado fresco de floración sencilla menta bicolor|O|O||D||1
10351514|Clavel cortado fresco de floración sencilla rosado bicolor|O|O||D||1
10351515|Clavel cortado fresco de floración sencilla rosado|O|O||D||1
10351516|Clavel cortado fresco de floración sencilla púrpura bicolor|O|O||D||1
10351517|Clavel cortado fresco de floración sencilla rojo bicolor|O|O||D||1
10351518|Clavel cortado fresco de floración sencilla rojo|O|O||D||1
10351519|Clavel cortado fresco de floración sencilla blanco|O|O||D||1
10351520|Clavel cortado fresco de floración sencilla amarillo|O|O||D||1
10351600|Bouquet cortado fresco de clavel min o spray|O|O||D||1
10351601|Clavel cortado fresco mini o spray burgundy|O|O||D||1
10351602|Clavel cortado fresco mini o spray|O|O||D||1
10351603|Clavel cortado fresco mini o spray rosado fuerte|O|O||D||1
10351604|Clavel cortado fresco mini o spray lavanda|O|O||D||1
10351605|Clavel cortado fresco mini o spray rosado claro|O|O||D||1
10351606|Clavel cortado fresco mini o spray anaranjado|O|O||D||1
10351607|Clavel cortado fresco mini o spray durazno|O|O||D||1
10351608|Clavel cortado fresco mini o spray menta|O|O||D||1
10351609|Clavel cortado fresco mini o spray rosado|O|O||D||1
10351610|Clavel cortado fresco mini o spray púrpura bicolor|O|O||D||1
10351611|Clavel cortado fresco mini o spray púrpura|O|O||D||1
10351612|Clavel cortado fresco mini o spray rojo|O|O||D||1
10351613|Clavel cortado fresco mini o spray blanco|O|O||D||1
10351614|Clavel cortado fresco mini o spray amarillo|O|O||D||1
10361500|Orquidea cypripedium  o pantuflas de dama cortada fresca|O|O||D||1
10361501|Orquidea cypripedium cortada fresca verde|O|O||D||1
10361502|Orquidea cypripedium cortada fresca francia|O|O||D||1
10361503|Orquidea cypripedium cortada fresca púrpura rey arturo|O|O||D||1
10361504|Orquidea paphiopedilum cortada fresca verde|O|O||D||1
10361505|Orquidea aranthera maggie vie cortada fresca|O|O||D||1
10361600|Orquídea mocara cortada fresca|O|O||D||1
10361601|Orquídea mocara cortada fresca omyai|O|O||D||1
10361602|Orquídea mocara cortada fresca roja|O|O||D||1
10361603|Orquídea mocara cortada fresca calipso|O|O||D||1
10361604|Orquídea mocara cortada fresca nora|O|O||D||1
10361605|Orquídea mocara cortada fresca panee|O|O||D||1
10361700|Orquídea catleya cortada fresca|O|O||D||1
10361701|Orquídea cattleya cortada fresca blanca|O|O||D||1
10361702|Orquídea cattleya cortada fresca r b lavanda|O|O||D||1
10361800|Orquídea disa cortada fresca|O|O||D||1
10361801|Orquídea disa cortada fresca roja|O|O||D||1
10361802|Orquídea disa cortada fresca anaranjada|O|O||D||1
10361803|Orquídea disa cortada fresca rosada|O|O||D||1
10361804|Orquídea disa cortada fresca anaranjada y amarilla bicolor|O|O||D||1
10361805|Orquídea disa cortada fresca durazno y amarilla bicolor|O|O||D||1
10361806|Orquídea disa cortada fresca amarilla y roja bicolor|O|O||D||1
10361900|Orquídea arachnis cortada fresca|O|O||D||1
10361901|Orquídea arachnis cortada fresca james storie roja|O|O||D||1
10361902|Orquídea arachnis cortada fresca maggie oei roja|O|O||D||1
10361903|Orquídea arachnis cortada fresca maggie oei amarilla|O|O||D||1
10361904|Orquídea arachnis cortada fresca maroon maggie|O|O||D||1
10361905|Orquídea arachnis cortada fresca merry maggie|O|O||D||1
10362000|Orquídea phalaenopsis cortada fresca|O|O||D||1
10362001|Orquídea phalaenopsis cortada fresca amabilis|O|O||D||1
10362002|Orquídea phalaenopsis cortada fresca amboinensis|O|O||D||1
10362003|Orquídea phalaenopsis cortada fresca afrodita|O|O||D||1
10362004|Orquídea phalaenopsis cortada fresca appendiculata|O|O||D||1
10362005|Orquídea phalaenopsis cortada fresca bastianii|O|O||D||1
10362006|Orquídea phalaenopsis cortada fresca bellina|O|O||D||1
10362007|Orquídea phalaenopsis cortada fresca borneensis|O|O||D||1
10362008|Orquídea phalaenopsis cortada fresca braceana|O|O||D||1
10362009|Orquídea phalaenopsis cortada fresca buyssoniana|O|O||D||1
10362010|Orquídea phalaenopsis cortada fresca celebensis|O|O||D||1
10362011|Orquídea phalaenopsis cortada fresca chibae|O|O||D||1
10362012|Orquídea phalaenopsis cortada fresca cochlearis|O|O||D||1
10362013|Orquídea phalaenopsis cortada fresca corningiana|O|O||D||1
10362014|Orquídea phalaenopsis cortada fresca cornu-cervi|O|O||D||1
10362015|Orquídea phalaenopsis cortada fresca deliciosa|O|O||D||1
10362016|Orquídea phalaenopsis cortada fresca doweryënsis|O|O||D||1
10362017|Orquídea phalaenopsis cortada fresca equestris|O|O||D||1
10362018|Orquídea phalaenopsis cortada fresca fasciata|O|O||D||1
10362019|Orquídea phalaenopsis cortada fresca fimbriata|O|O||D||1
10362020|Orquídea phalaenopsis cortada fresca floresensis|O|O||D||1
10362021|Orquídea phalaenopsis cortada fresca fuscata|O|O||D||1
10362022|Orquídea phalaenopsis cortada fresca gibbosa|O|O||D||1
10362023|Orquídea phalaenopsis cortada fresca hainanensis|O|O||D||1
10362024|Orquídea phalaenopsis cortada fresca hieroglyphica|O|O||D||1
10362025|Orquídea phalaenopsis cortada fresca honghenensis|O|O||D||1
10362026|Orquídea phalaenopsis cortada fresca inscriptiosinensis|O|O||D||1
10362027|Orquídea phalaenopsis cortada fresca javanica|O|O||D||1
10362028|Orquídea phalaenopsis cortada fresca kunstleri|O|O||D||1
10362029|Orquídea phalaenopsis cortada fresca lamelligera|O|O||D||1
10362030|Orquídea phalaenopsis cortada fresca lindenii|O|O||D||1
10362031|Orquídea phalaenopsis cortada fresca lobbii|O|O||D||1
10362032|Orquídea phalaenopsis cortada fresca lowii|O|O||D||1
10362033|Orquídea phalaenopsis cortada fresca lueddemanniana|O|O||D||1
10362034|Orquídea phalaenopsis cortada fresca mambo|O|O||D||1
10362035|Orquídea phalaenopsis cortada fresca luteola|O|O||D||1
10362036|Orquídea phalaenopsis cortada fresca maculata|O|O||D||1
10362037|Orquídea phalaenopsis cortada fresca malipoensis|O|O||D||1
10362038|Orquídea phalaenopsis cortada fresca mannii|O|O||D||1
10362039|Orquídea phalaenopsis cortada fresca mariae|O|O||D||1
10362040|Orquídea phalaenopsis cortada fresca micholitzii|O|O||D||1
10362041|Orquídea phalaenopsis cortada fresca modesta|O|O||D||1
10362042|Orquídea phalaenopsis cortada fresca mysorensis|O|O||D||1
10362043|Orquídea phalaenopsis cortada fresca pallens|O|O||D||1
10362044|Orquídea phalaenopsis cortada fresca pantherina|O|O||D||1
10362045|Orquídea phalaenopsis cortada fresca parishii|O|O||D||1
10362046|Orquídea phalaenopsis cortada fresca petelotii|O|O||D||1
10362047|Orquídea phalaenopsis cortada fresca philippinensis|O|O||D||1
10362048|Orquídea phalaenopsis cortada fresca pulcherrima|O|O||D||1
10362049|Orquídea phalaenopsis cortada fresca pulchra|O|O||D||1
10362050|Orquídea phalaenopsis cortada fresca regnieriana|O|O||D||1
10362051|Orquídea phalaenopsis cortada fresca reichenbachiana|O|O||D||1
10362052|Orquídea phalaenopsis cortada fresca nivacolor|O|O||D||1
10362053|Orquídea phalaenopsis cortada fresca sanderiana|O|O||D||1
10362054|Orquídea phalaenopsis cortada fresca schilleriana|O|O||D||1
10362055|Orquídea phalaenopsis cortada fresca speciosa|O|O||D||1
10362056|Orquídea phalaenopsis cortada fresca stobartiana|O|O||D||1
10362057|Orquídea phalaenopsis cortada fresca stuartiana|O|O||D||1
10362058|Orquídea phalaenopsis cortada fresca sumatrana|O|O||D||1
10362059|Orquídea phalaenopsis cortada fresca taenialis|O|O||D||1
10362060|Orquídea phalaenopsis cortada fresca tetraspis|O|O||D||1
10362061|Orquídea phalaenopsis cortada fresca venosa|O|O||D||1
10362062|Orquídea phalaenopsis cortada fresca violácea|O|O||D||1
10362063|Orquídea phalaenopsis cortada fresca viridis|O|O||D||1
10362064|Orquídea phalaenopsis cortada fresca wilsonii|O|O||D||1
10362065|Orquídea phalaenopsis cortada fresca zebrina|O|O||D||1
10362067|Orquídea phalaenopsis cortada fresca labio lavanda|O|O||D||1
10362100|Orquídea dendrobium cortada fresca|O|O||D||1
10362101|Orquídea dendrobium cortada fresca bom|O|O||D||1
10362102|Orquídea dendrobium cortada fresca burana|O|O||D||1
10362103|Orquídea dendrobium cortada fresca chita|O|O||D||1
10362104|Orquídea dendrobium cortada fresca fátima|O|O||D||1
10362105|Orquídea dendrobium cortada fresca intuwong|O|O||D||1
10362106|Orquídea dendrobium cortada fresca jumbo blanca|O|O||D||1
10362107|Orquídea dendrobium cortada fresca kating dang|O|O||D||1
10362108|Orquídea dendrobium cortada fresca libertad|O|O||D||1
10362109|Orquídea dendrobium cortada fresca hawaii|O|O||D||1
10362110|Orquídea dendrobium cortada fresca sakura sweet rosada|O|O||D||1
10362111|Orquídea dendrobium cortada fresca sensacional púrpura|O|O||D||1
10362112|Orquídea dendrobium cortada fresca blanca|O|O||D||1
10362200|Orquídea cymbidium cortada fresca|O|O||D||1
10362201|Orquídea cymbidium cortada fresca crema|O|O||D||1
10362202|Orquídea cymbidium cortada fresca verde|O|O||D||1
10362203|Orquídea cymbidium cortada fresca mini verde|O|O||D||1
10362204|Orquídea cymbidium cortada fresca mini rosada|O|O||D||1
10362205|Orquídea cymbidium cortada fresca mini roja|O|O||D||1
10362206|Orquídea cymbidium cortada fresca mini blanca|O|O||D||1
10362207|Orquídea cymbidium cortada fresca mini amarilla|O|O||D||1
10362208|Orquídea cymbidium cortada fresca chocolate|O|O||D||1
10362209|Orquídea cymbidium cortada fresca rosado oscuro|O|O||D||1
10362210|Orquídea cymbidium cortada fresca anaranjada|O|O||D||1
10362211|Orquídea cymbidium cortada fresca rosada|O|O||D||1
10362212|Orquídea cymbidium cortada fresca blanca|O|O||D||1
10362213|Orquídea cymbidium cortada fresca amarilla|O|O||D||1
10362300|Orquídea oncidium cortada fresca|O|O||D||1
10362301|Orquídea oncidium cortada fresca ducha dorada|O|O||D||1
10362302|Orquídea oncidium cortada fresca rhamsey|O|O||D||1
10362400|Orquídea vanda cortada fresca|O|O||D||1
10362401|Orquídea cortada fresca vanda alizarin|O|O||D||1
10362402|Orquídea cortada fresca vanda rosada fuerte|O|O||D||1
10362403|Orquídea cortada fresca vanda lavanda|O|O||D||1
10362404|Orquídea cortada fresca vanda púrpura|O|O||D||1
10362405|Orquídea cortada fresca vanda hazme cosquillas rosada|O|O||D||1
10362406|Orquídea cortada fresca vanda amarilla|O|O||D||1
10401500|Rosas cortadas secas azules o lavanda o púrpura|O|O||D||1
10401501|Rosal cortado seco allure o sterling 95|O|O||D||1
10401502|Rosal cortado seco amnesia|O|O||D||1
10401503|Rosal cortado seco augusta louise|O|O||D||1
10401504|Rosal cortado seco avant garde|O|O||D||1
10401505|Rosal cortado seco blue bird|O|O||D||1
10401506|Rosal cortado seco curiosa|O|O||D||1
10401507|Rosal cortado seco cool water|O|O||D||1
10401508|Rosal cortado seco delilah|O|O||D||1
10401509|Rosal cortado seco double party|O|O||D||1
10401510|Rosal cortado seco faith|O|O||D||1
10401511|Rosal cortado seco mami blue o mammy blue|O|O||D||1
10401512|Rosal cortado seco maritime|O|O||D||1
10401513|Rosal cortado seco milano|O|O||D||1
10401514|Rosal cortado seco mistery|O|O||D||1
10401515|Rosal cortado seco ocean song o boyfriend|O|O||D||1
10401516|Rosal cortado seco cezanne púrpura|O|O||D||1
10401517|Rosal cortado seco purple fragrance|O|O||D||1
10401518|Rosal cortado seco sanaa|O|O||D||1
10401519|Rosal cortado seco silverstone|O|O||D||1
10401520|Rosal cortado seco soulmate|O|O||D||1
10401521|Rosal cortado seco stranger|O|O||D||1
10401522|Rosal cortado seco tinted blue|O|O||D||1
10401523|Rosal cortado seco two faces|O|O||D||1
10401600|Rosas cortadas secas chocolate o marrón|O|O||D||1
10401601|Rosal cortado seco black lava|O|O||D||1
10401602|Rosal cortado seco cimarrón|O|O||D||1
10401603|Rosal cortado seco coffee break|O|O||D||1
10401604|Rosal cortado seco estelle|O|O||D||1
10401605|Rosal cortado seco gypsy leonidas|O|O||D||1
10401606|Rosal cortado seco leonidas|O|O||D||1
10401607|Rosal cortado seco matilda|O|O||D||1
10401608|Rosal cortado seco sunny leonidas|O|O||D||1
10401609|Rosal cortado seco terra nostra|O|O||D||1
10401610|Rosal cortado seco terracotta|O|O||D||1
10401700|Rosas cortadas secas crema|O|O||D||1
10401701|Rosal cortado seco advenire|O|O||D||1
10401702|Rosal cortado seco alex|O|O||D||1
10401703|Rosal cortado seco antique brass|O|O||D||1
10401704|Rosal cortado seco aubade|O|O||D||1
10401705|Rosal cortado seco beach|O|O||D||1
10401706|Rosal cortado seco belle pearl|O|O||D||1
10401707|Rosal cortado seco blush o blush de los andes|O|O||D||1
10401708|Rosal cortado seco camel|O|O||D||1
10401709|Rosal cortado seco caramel antike o caramel antique|O|O||D||1
10401710|Rosal cortado seco champagne|O|O||D||1
10401711|Rosal cortado seco clear ocean|O|O||D||1
10401712|Rosal cortado seco combo|O|O||D||1
10401713|Rosal cortado seco creme de la creme|O|O||D||1
10401714|Rosal cortado seco emanuella|O|O||D||1
10401715|Rosal cortado seco evolution|O|O||D||1
10401716|Rosal cortado seco fedora|O|O||D||1
10401717|Rosal cortado seco fenice|O|O||D||1
10401718|Rosal cortado seco french vanilla|O|O||D||1
10401719|Rosal cortado seco hollywood|O|O||D||1
10401720|Rosal cortado seco ilios|O|O||D||1
10401721|Rosal cortado seco jelena|O|O||D||1
10401722|Rosal cortado seco kameleon|O|O||D||1
10401723|Rosal cortado seco kentucky|O|O||D||1
10401724|Rosal cortado seco kings pride|O|O||D||1
10401725|Rosal cortado seco latin fusion|O|O||D||1
10401726|Rosal cortado seco lemon dream|O|O||D||1
10401727|Rosal cortado seco magic moka|O|O||D||1
10401728|Rosal cortado seco mama mia|O|O||D||1
10401729|Rosal cortado seco message|O|O||D||1
10401730|Rosal cortado seco muñeca o munieca|O|O||D||1
10401731|Rosal cortado seco parfum de rosas|O|O||D||1
10401732|Rosal cortado seco porcelina|O|O||D||1
10401733|Rosal cortado seco privilege|O|O||D||1
10401734|Rosal cortado seco quick sand|O|O||D||1
10401735|Rosal cortado seco rollercoaster|O|O||D||1
10401736|Rosal cortado seco romantic curiosa|O|O||D||1
10401737|Rosal cortado seco safari|O|O||D||1
10401738|Rosal cortado seco sahara|O|O||D||1
10401739|Rosal cortado seco sandy femma|O|O||D||1
10401740|Rosal cortado seco talea|O|O||D||1
10401741|Rosal cortado seco timeless|O|O||D||1
10401742|Rosal cortado seco transition|O|O||D||1
10401743|Rosal cortado seco trump|O|O||D||1
10401744|Rosal cortado seco twin|O|O||D||1
10401745|Rosal cortado seco vendela|O|O||D||1
10401746|Rosal cortado seco virginia|O|O||D||1
10401800|Rosas cortadas secas verdes o lima|O|O||D||1
10401801|Rosal cortado seco amandina|O|O||D||1
10401802|Rosal cortado seco caipirinha|O|O||D||1
10401803|Rosal cortado seco green fashion|O|O||D||1
10401804|Rosal cortado seco green tea|O|O||D||1
10401805|Rosal cortado seco jade|O|O||D||1
10401806|Rosal cortado seco limbo|O|O||D||1
10401807|Rosal cortado seco limeña o limenia|O|O||D||1
10401808|Rosal cortado seco limona|O|O||D||1
10401809|Rosal cortado seco old dutch|O|O||D||1
10401810|Rosal cortado seco super green|O|O||D||1
10401811|Rosal cortado seco sweet green|O|O||D||1
10401812|Rosal cortado seco cortada seca|O|O||D||1
10401813|Rosal cortado seco zazu|O|O||D||1
10401900|Rosas cortadas secas rosado claro|O|O||D||1
10401901|Rosal cortado seco anna|O|O||D||1
10401902|Rosal cortado seco bella vita|O|O||D||1
10401903|Rosal cortado seco bridal dream|O|O||D||1
10401904|Rosal cortado seco candy bianca|O|O||D||1
10401905|Rosal cortado seco caress|O|O||D||1
10401906|Rosal cortado seco carolina|O|O||D||1
10401907|Rosal cortado seco climax|O|O||D||1
10401908|Rosal cortado seco danny|O|O||D||1
10401909|Rosal cortado seco dolce vita|O|O||D||1
10401910|Rosal cortado seco elite|O|O||D||1
10401911|Rosal cortado seco emma|O|O||D||1
10401912|Rosal cortado seco engagement|O|O||D||1
10401913|Rosal cortado seco esther|O|O||D||1
10401914|Rosal cortado seco excalibur|O|O||D||1
10401915|Rosal cortado seco exciting|O|O||D||1
10401916|Rosal cortado seco first lady|O|O||D||1
10401917|Rosal cortado seco geraldine|O|O||D||1
10401918|Rosal cortado seco gotcha|O|O||D||1
10401919|Rosal cortado seco harmonie|O|O||D||1
10401920|Rosal cortado seco heaven|O|O||D||1
10401921|Rosal cortado seco high and elegant|O|O||D||1
10401922|Rosal cortado seco katherine|O|O||D||1
10401923|Rosal cortado seco king kong|O|O||D||1
10401924|Rosal cortado seco livia|O|O||D||1
10401925|Rosal cortado seco lorena|O|O||D||1
10401926|Rosal cortado seco lovely|O|O||D||1
10401927|Rosal cortado seco maaike|O|O||D||1
10401928|Rosal cortado seco marilyn|O|O||D||1
10401929|Rosal cortado seco marlise|O|O||D||1
10401930|Rosal cortado seco miranda o ausimmon|O|O||D||1
10401931|Rosal cortado seco mona lisa|O|O||D||1
10401932|Rosal cortado seco nirvana|O|O||D||1
10401933|Rosal cortado seco o’hara|O|O||D||1
10401934|Rosal cortado seco ole|O|O||D||1
10401935|Rosal cortado seco olga|O|O||D||1
10401936|Rosal cortado seco pacífica|O|O||D||1
10401937|Rosal cortado seco party mix|O|O||D||1
10401938|Rosal cortado seco pekoubo o pekcoubo|O|O||D||1
10401939|Rosal cortado seco phoebe o ausnotice|O|O||D||1
10401940|Rosal cortado seco pink farfalla|O|O||D||1
10401941|Rosal cortado seco pink finess|O|O||D||1
10401942|Rosal cortado seco pink magic|O|O||D||1
10401943|Rosal cortado seco pink osiana|O|O||D||1
10401944|Rosal cortado seco pretty woman|O|O||D||1
10401945|Rosal cortado seco romance|O|O||D||1
10401946|Rosal cortado seco romantic antike o antique|O|O||D||1
10401947|Rosal cortado seco rosalind o astew|O|O||D||1
10401948|Rosal cortado seco rosita vendela|O|O||D||1
10401949|Rosal cortado seco secret garden|O|O||D||1
10401950|Rosal cortado seco solaire|O|O||D||1
10401951|Rosal cortado seco sophie|O|O||D||1
10401952|Rosal cortado seco sweet akito|O|O||D||1
10401953|Rosal cortado seco sweet avalanche|O|O||D||1
10401954|Rosal cortado seco sweet elegance|O|O||D||1
10401955|Rosal cortado seco sweet pink|O|O||D||1
10401956|Rosal cortado seco titanic|O|O||D||1
10401957|Rosal cortado seco toscanini|O|O||D||1
10401958|Rosal cortado seco vania|O|O||D||1
10401959|Rosal cortado seco vanity|O|O||D||1
10401960|Rosal cortado seco vision|O|O||D||1
10401961|Rosal cortado seco vivaldi|O|O||D||1
10401962|Rosal cortado seco whisper|O|O||D||1
10402000|Rosas cortadas secas multicolor rosados|O|O||D||1
10402001|Rosal cortado seco attracta|O|O||D||1
10402002|Rosal cortado seco boheme|O|O||D||1
10402003|Rosal cortado seco carousel|O|O||D||1
10402004|Rosal cortado seco cezanne|O|O||D||1
10402005|Rosal cortado seco crazy one|O|O||D||1
10402006|Rosal cortado seco dance valley|O|O||D||1
10402007|Rosal cortado seco duett|O|O||D||1
10402008|Rosal cortado seco esperance|O|O||D||1
10402009|Rosal cortado seco fiesta|O|O||D||1
10402010|Rosal cortado seco halloween|O|O||D||1
10402011|Rosal cortado seco highlander|O|O||D||1
10402012|Rosal cortado seco hot ambiance|O|O||D||1
10402013|Rosal cortado seco la belle|O|O||D||1
10402014|Rosal cortado seco laguna|O|O||D||1
10402015|Rosal cortado seco latin ambiance|O|O||D||1
10402016|Rosal cortado seco latin breeze|O|O||D||1
10402017|Rosal cortado seco long arifa|O|O||D||1
10402018|Rosal cortado seco murano|O|O||D||1
10402019|Rosal cortado seco n – joy rose|O|O||D||1
10402020|Rosal cortado seco panama|O|O||D||1
10402021|Rosal cortado seco peppermint|O|O||D||1
10402022|Rosal cortado seco pujama party|O|O||D||1
10402023|Rosal cortado seco portofino|O|O||D||1
10402024|Rosal cortado seco priceless|O|O||D||1
10402025|Rosal cortado seco queen amazon|O|O||D||1
10402026|Rosal cortado seco ranuncula|O|O||D||1
10402027|Rosal cortado seco rossini|O|O||D||1
10402028|Rosal cortado seco sabina o sabrina|O|O||D||1
10402029|Rosal cortado seco scandal|O|O||D||1
10402030|Rosal cortado seco silvery pink|O|O||D||1
10402031|Rosal cortado seco something else|O|O||D||1
10402032|Rosal cortado seco southine|O|O||D||1
10402033|Rosal cortado seco sovereign|O|O||D||1
10402034|Rosal cortado seco super disco|O|O||D||1
10402035|Rosal cortado seco ts 1968|O|O||D||1
10402036|Rosal cortado seco variance|O|O||D||1
10402037|Rosal cortado seco verdi|O|O||D||1
10402100|Rosas cortadas secas anaranjados|O|O||D||1
10402101|Rosal cortado seco alhambra|O|O||D||1
10402102|Rosal cortado seco aloha|O|O||D||1
10402103|Rosal cortado seco amber|O|O||D||1
10402104|Rosal cortado seco apache|O|O||D||1
10402105|Rosal cortado seco arabia|O|O||D||1
10402106|Rosal cortado seco bengala|O|O||D||1
10402107|Rosal cortado seco bibi|O|O||D||1
10402108|Rosal cortado seco caramba|O|O||D||1
10402109|Rosal cortado seco caramella|O|O||D||1
10402110|Rosal cortado seco carla|O|O||D||1
10402111|Rosal cortado seco cartagena|O|O||D||1
10402112|Rosal cortado seco chanson|O|O||D||1
10402113|Rosal cortado seco charmer|O|O||D||1
10402114|Rosal cortado seco cherry brandy|O|O||D||1
10402115|Rosal cortado seco chilis|O|O||D||1
10402116|Rosal cortado seco cinnamon|O|O||D||1
10402117|Rosal cortado seco colandro|O|O||D||1
10402118|Rosal cortado seco coral sea|O|O||D||1
10402119|Rosal cortado seco corvette o red covette|O|O||D||1
10402120|Rosal cortado seco dark milva|O|O||D||1
10402121|Rosal cortado seco donna|O|O||D||1
10402122|Rosal cortado seco dreamer|O|O||D||1
10402123|Rosal cortado seco el dorado|O|O||D||1
10402124|Rosal cortado seco el toro|O|O||D||1
10402125|Rosal cortado seco elena|O|O||D||1
10402126|Rosal cortado seco ensueño|O|O||D||1
10402127|Rosal cortado seco euforia|O|O||D||1
10402128|Rosal cortado seco exótica|O|O||D||1
10402129|Rosal cortado seco fancy amazon|O|O||D||1
10402130|Rosal cortado seco fiction|O|O||D||1
10402131|Rosal cortado seco finess|O|O||D||1
10402132|Rosal cortado seco flameco|O|O||D||1
10402133|Rosal cortado seco free spirit|O|O||D||1
10402134|Rosal cortado seco gelato|O|O||D||1
10402135|Rosal cortado seco gypsy curiosa|O|O||D||1
10402136|Rosal cortado seco high and magic|O|O||D||1
10402137|Rosal cortado seco high and orange|O|O||D||1
10402138|Rosal cortado seco iguana o alegra|O|O||D||1
10402139|Rosal cortado seco impulse|O|O||D||1
10402140|Rosal cortado seco indian femma|O|O||D||1
10402141|Rosal cortado seco indian sunset|O|O||D||1
10402142|Rosal cortado seco karusso|O|O||D||1
10402143|Rosal cortado seco kerio|O|O||D||1
10402144|Rosal cortado seco kiki|O|O||D||1
10402145|Rosal cortado seco latin circus|O|O||D||1
10402146|Rosal cortado seco leonisa|O|O||D||1
10402147|Rosal cortado seco lipstick|O|O||D||1
10402148|Rosal cortado seco lobita|O|O||D||1
10402149|Rosal cortado seco luca|O|O||D||1
10402150|Rosal cortado seco manitou|O|O||D||1
10402151|Rosal cortado seco mariana|O|O||D||1
10402152|Rosal cortado seco marjan o pk sensation|O|O||D||1
10402153|Rosal cortado seco milonga|O|O||D||1
10402154|Rosal cortado seco milva|O|O||D||1
10402155|Rosal cortado seco miracle|O|O||D||1
10402156|Rosal cortado seco mirage|O|O||D||1
10402157|Rosal cortado seco monte carlo|O|O||D||1
10402158|Rosal cortado seco movie star|O|O||D||1
10402159|Rosal cortado seco nikita|O|O||D||1
10402160|Rosal cortado seco orange flame|O|O||D||1
10402161|Rosal cortado seco orange france|O|O||D||1
10402162|Rosal cortado seco orange intuition|O|O||D||1
10402163|Rosal cortado seco orange unique|O|O||D||1
10402164|Rosal cortado seco orangine u orangina|O|O||D||1
10402165|Rosal cortado seco papaya|O|O||D||1
10402166|Rosal cortado seco pareo|O|O||D||1
10402167|Rosal cortado seco peach sherbet|O|O||D||1
10402168|Rosal cortado seco queensday|O|O||D||1
10402169|Rosal cortado seco rosselle|O|O||D||1
10402170|Rosal cortado seco royal circus|O|O||D||1
10402171|Rosal cortado seco sari|O|O||D||1
10402172|Rosal cortado seco sensual|O|O||D||1
10402173|Rosal cortado seco soap|O|O||D||1
10402174|Rosal cortado seco sombrero|O|O||D||1
10402175|Rosal cortado seco spicy|O|O||D||1
10402176|Rosal cortado seco estrella 2000|O|O||D||1
10402177|Rosal cortado seco summer versilia|O|O||D||1
10402178|Rosal cortado seco trixx|O|O||D||1
10402179|Rosal cortado seco tropical amazon|O|O||D||1
10402180|Rosal cortado seco utopia|O|O||D||1
10402181|Rosal cortado seco valentine|O|O||D||1
10402182|Rosal cortado seco verano|O|O||D||1
10402183|Rosal cortado seco versilia|O|O||D||1
10402184|Rosal cortado seco voodoo|O|O||D||1
10402185|Rosal cortado seco wow|O|O||D||1
10402186|Rosal cortado seco yabadabadoo|O|O||D||1
10402200|Rosas cortadas secas durazno|O|O||D||1
10402201|Rosal cortado seco alejandra|O|O||D||1
10402202|Rosal cortado seco azafrán|O|O||D||1
10402203|Rosal cortado seco big fun|O|O||D||1
10402204|Rosal cortado seco cabaret|O|O||D||1
10402205|Rosal cortado seco capuccino|O|O||D||1
10402206|Rosal cortado seco carpe diem|O|O||D||1
10402207|Rosal cortado seco cosima|O|O||D||1
10402208|Rosal cortado seco cumbia|O|O||D||1
10402209|Rosal cortado seco dream|O|O||D||1
10402210|Rosal cortado seco época|O|O||D||1
10402211|Rosal cortado seco fado|O|O||D||1
10402212|Rosal cortado seco femma|O|O||D||1
10402213|Rosal cortado seco guajira|O|O||D||1
10402214|Rosal cortado seco high and arena|O|O||D||1
10402215|Rosal cortado seco high and dandy|O|O||D||1
10402216|Rosal cortado seco high and lucky|O|O||D||1
10402217|Rosal cortado seco high and peach|O|O||D||1
10402218|Rosal cortado seco imagination|O|O||D||1
$sat$, E'\n') as l
 where l <> ''
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
