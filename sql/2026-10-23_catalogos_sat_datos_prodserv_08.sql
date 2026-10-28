-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 8 de 10 (5288 claves; total 52513)
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
50414702|Champiñón carmelito orgánico|O|O||D||1
50414703|Champiñón  orgánico|O|O||D||1
50414704|Champiñón chanterelle orgánico|O|O||D||1
50414705|Champiñón cremini orgánico|O|O||D||1
50414706|Champiñón enoki orgánico|O|O||D||1
50414707|Champiñón puercoespín orgánico|O|O||D||1
50414708|Champiñón gallina del bosque orgánico|O|O||D||1
50414709|Champiñón langosta orgánico|O|O||D||1
50414710|Champiñón morels orgánico|O|O||D||1
50414711|Champiñón ostra orgánico|O|O||D||1
50414712|Champiñón pleurotus orgánico|O|O||D||1
50414713|Champiñón pompom orgánico|O|O||D||1
50414714|Champiñón porcieni orgánico|O|O||D||1
50414715|Champiñón portobello orgánico|O|O||D||1
50414716|Champiñón shitake orgánico|O|O||D||1
50414717|Champiñón shimeji orgánico|O|O||D||1
50414718|Champiñón san jorge orgánico|O|O||D||1
50414719|Champiñón blanco orgánico|O|O||D||1
50414720|Champiñón trompeta blanca orgánico|O|O||D||1
50414721|Champiñón woodear orgánico|O|O||D||1
50414800|Mostazas  orgánicas|O|O||D||1
50414801|Mostaza bambú orgánica|O|O||D||1
50414802|Mostaza ajo orgánica|O|O||D||1
50414803|Mostaza hoja gigante orgánica|O|O||D||1
50414804|Mostaza rojo en nieve orgánica|O|O||D||1
50414805|Mostaza sureño orgánica|O|O||D||1
50414806|Mostaza corazón envuelto orgánica|O|O||D||1
50415000|Solanáceas (nightshades)  orgánicas|O|O||D||1
50415001|Lámpara china orgánica|O|O||D||1
50415002|Mora de jardín orgánica|O|O||D||1
50415003|Naranjilla orgánica|O|O||D||1
50415004|Tomatillo orgánico|O|O||D||1
50415100|Okras  orgánicas|O|O||D||1
50415101|Okra artista orgánica|O|O||D||1
50415102|Okra vinotinto orgánica|O|O||D||1
50415103|Okra sin columna clemson orgánica|O|O||D||1
50415104|Okra verde enano vaina larga orgánica|O|O||D||1
50415105|Okra  mamut sin columna orgánica|O|O||D||1
50415106|Okra terciopelo rojo orgánica|O|O||D||1
50415107|Okra estrella de david reliquia orgánica|O|O||D||1
50415200|Cebollas  orgánicas|O|O||D||1
50415201|Cebolla albion orgánica|O|O||D||1
50415202|Cebolla alisia craig orgánica|O|O||D||1
50415203|Cebolla hirviendo orgánica|O|O||D||1
50415204|Cebolla bufalo orgánica|O|O||D||1
50415205|Cebolla bulbo  orgánica|O|O||D||1
50415206|Cebolla cremosa orgánica|O|O||D||1
50415207|Cebolla amarillo expreso o – x orgánica|O|O||D||1
50415208|Cebolla kelsae orgánica|O|O||D||1
50415209|Cebolla gigante marshal globo fen orgánica|O|O||D||1
50415210|Cebolla perla orgánica|O|O||D||1
50415211|Cebolla baron rojo orgánica|O|O||D||1
50415212|Cebolla roja orgánica|O|O||D||1|Cebolla morada orgánica
50415213|Cebolla rijnsberger orgánica|O|O||D||1
50415214|Cebolla senshyu semi – globo amarillo orgánica|O|O||D||1
50415215|Cebolla sturon orgánica|O|O||D||1
50415216|Cebolla stuttgarter orgánica|O|O||D||1
50415217|Cebolla dulce orgánica|O|O||D||1
50415218|Cebolla torpedo o rojo italiana orgánica|O|O||D||1
50415219|Cebolla roja guardada orgánica|O|O||D||1
50415220|Cebolla blanca guardada orgánica|O|O||D||1
50415221|Cebolla amarilla guardada orgánica|O|O||D||1
50415300|Maníes orgánicos|O|O||D||1|Cacahuates orgánicos
50415301|Maní bambarra orgánico|O|O||D||1|Cacahuate bambarra orgánico
50415302|Maní florunner  orgánico|O|O||D||1|Cacahuate florunner orgánico
50415303|Maní hausa / kersting orgánico|O|O||D||1|Cacahuate hausa / kersting orgánico
50415304|Maní español orgánico|O|O||D||1|Cacahuate español orgánico
50415305|Maní de valencia orgánico|O|O||D||1|Cacahuate de valencia orgánico
50415306|Maní de virginia orgánico|O|O||D||1|Cacahuate de virginia orgánico
50415400|Alverjas Orgánicas|O|O||D||1|Alberjones orgánicos
50415401|Alverja casco morado orgánica|O|O||D||1|Alberjón casco morado orgánico
50415402|Alverja pinkeye orgánica|O|O||D||1|Alberjón pinkeye orgánico
50415403|Alverja crowder orgánica|O|O||D||1|Alberjón crowder orgánico
50415404|Alverja acre blanco orgánica|O|O||D||1|Alberjón acre blanco orgánico
50415405|Alverja ojo negro orgánica|O|O||D||1|Alberjón ojo negro orgánico
50415406|Alverja crema zipper orgánica|O|O||D||1|Alberjón crema zipper orgánico
50415500|Pimientos orgánicos|O|O||D||1|Chiles orgánicos
50415501|Pimentón ají  orgánico|O|O||D||1|Ají orgánico
50415502|Pimentón  árbol orgánico|O|O||D||1|Chile de árbol orgánico
50415503|Pimentón queso orgánico|O|O||D||1
50415504|Pimentón chilaca orgánico|O|O||D||1|Chilaca orgánico
50415505|Pimentón cubanelles orgánico|O|O||D||1|Chile cubanelle o pimienta italiana orgánica
50415506|Pimentón fresno orgánico|O|O||D||1|Chile fresno orgánico
50415507|Pimentón kapia orgánico|O|O||D||1|Chile kapia orgánico
50415508|Pimentón coreano orgánico|O|O||D||1|Chile cheongyang orgánico
50415509|Pimentón manzano orgánico|O|O||D||1|Chile manzano o de cera orgánico
50415510|Pimentón melrose orgánico|O|O||D||1
50415511|Pimentón chile amarillo orgánico|O|O||D||1|Chile peruano amarillo orgánico
50415512|Pimentón aji dulce orgánico|O|O||D||1|Ají dulce orgánico
50415513|Pimentón anaheim orgánico|O|O||D||1
50415514|Pimentón ancho orgánico|O|O||D||1|Chile ancho o mulato orgánico
50415515|Pimentón campana orgánico|O|O||D||1|Chile campana orgánico
50415516|Pimentón cascabel orgánico|O|O||D||1|Chile cascabel orgánico
50415517|Pimentón cayenne orgánico|O|O||D||1|Pimienta de Cayena o roja orgánica
50415518|Pimentón anfitrión cereza orgánico|O|O||D||1
50415519|Pimentón chitespin orgánico|O|O||D||1|Chile chiltepín orgánico
50415520|Pimentón dedo picante orgánico|O|O||D||1|Chile Jwala orgánico
50415521|Pimentón guajillo orgánico|O|O||D||1|Chile guajillo orgánico
50415522|Pimentón guerro orgánico|O|O||D||1|Chile güero orgánico
50415523|Pimentón habanero orgánico|O|O||D||1|Chile habanero orgánico
50415524|Pimentón cera de hungria orgánico|O|O||D||1|Pimentón húngaro orgánico
50415525|Pimentón jalapeño orgánico|O|O||D||1|Chile cuaresmeño orgánico, Chile jalapeño orgánico
50415526|Pimentón picante largo orgánico|O|O||D||1|Chile cola de rata orgánico
50415527|Pimentón marasol orgánico|O|O||D||1|Chile mirasol orgánico
50415528|Pimentón pasilla orgánico|O|O||D||1|Chile pasilla orgánico
50415529|Pimentón peperoncini orgánico|O|O||D||1
50415530|Pimentón pequin orgánico|O|O||D||1|Chile piquín orgánico
50415531|Pimentón pimiento orgánico|O|O||D||1|Pimiento morrón orgánico
50415532|Pimentón poblano orgánico|O|O||D||1|Chile poblano orgánico
50415533|Pimentón scotch bonnet orgánico|O|O||D||1|Pimientos Bonney o rojos Caribe orgánicos
50415534|Pimentón serrano orgánico|O|O||D||1|Chile serrano orgánico, Chile verde orgánico
50415535|Pimentón tabasco orgánico|O|O||D||1|Chile tabasco orgánico
50415536|Pimentón tai  orgánico|O|O||D||1|Chile ojo de pájaro orgánico
50415537|Pimentón tepin orgánico|O|O||D||1|Chile mosquito o catarina orgánico
50415600|Papas  orgánicas|O|O||D||1
50415601|Papa blanca larga orgánica|O|O||D||1
50415602|Papa redonda blanca orgánica|O|O||D||1
50415603|Papa redonda roja orgánica|O|O||D||1|Papa de cambray orgánica
50415604|Papa  russet orgánica|O|O||D||1
50415605|Papa morada orgánica|O|O||D||1
50415606|Papa amarilla orgánica|O|O||D||1
50415607|Papa nueva orgánica|O|O||D||1
50415608|Papa especial orgánica|O|O||D||1
50415700|Nabos suecos orgánicos|O|O||D||1
50415701|Nabo sueco acme orgánico|O|O||D||1
50415702|Nabo sueco angela orgánico|O|O||D||1
50415703|Nabo sueco el mejor orgánico|O|O||D||1
50415704|Nabo sueco marian orgánico|O|O||D||1
50415800|Vegetales marinos orgánicos|O|O||D||1
50415801|Agar-agar orgánico|O|O||D||1
50415802|Arame  orgánica|O|O||D||1
50415803|Alga dulce orgánica|O|O||D||1
50415804|Habichuelas vert de mer orgánica|O|O||D||1
50415805|Hijiki orgánica|O|O||D||1
50415806|Musgo irlandés orgánico|O|O||D||1
50415807|Quelpo orgánico|O|O||D||1
50415808|Laver orgánica|O|O||D||1
50415809|Nori orgánico|O|O||D||1
50415810|Alga roja orgánica|O|O||D||1
50415811|Kale de mar orgánico|O|O||D||1
50415812|Lechuga de mar orgánica|O|O||D||1
50415813|Algas de mar orgánica|O|O||D||1
50415814|Spirulina orgánica|O|O||D||1
50415815|Susabi nuri orgánico|O|O||D||1
50415816|Wakame orgánica|O|O||D||1
50415900|Chalotes orgánicos|O|O||D||1
50415901|Chalote atlántica orgánico|O|O||D||1
50415902|Chalote creación orgánico|O|O||D||1
50415903|Chalote drittler nido blanco orgánico|O|O||D||1
50415904|Chalote gigante mejorado amarillo orgánico|O|O||D||1
50415905|Chalote gourmet dorado orgánico|O|O||D||1
50415906|Chalote grise de bagnolet orgánico|O|O||D||1
50415907|Chalote hative de nort orgánico|O|O||D||1
50415908|Chalote pikant orgánico|O|O||D||1
50415909|Chalote papa roja orgánico|O|O||D||1
50415910|Chalote sante orgánico|O|O||D||1
50415911|Chalote topper orgánico|O|O||D||1
50416000|Alazanes orgánicos|O|O||D||1|Acederas orgánicas
50416001|Alazán dock orgánica|O|O||D||1|Acedera dock orgánica
50416002|Alazán jardín orgánica|O|O||D||1|Acedera jardín orgánica
50416003|Alazán oveja orgánica|O|O||D||1|Acedera oveja orgánica
50416004|Alazán madera orgánica|O|O||D||1|Acedera madera orgánica
50416100|Espinacas  orgánicas|O|O||D||1
50416101|Espinaca americana orgánica|O|O||D||1
50416102|Espinaca bloomsdale orgánica|O|O||D||1
50416103|Espinaca invierno gigante orgánica|O|O||D||1
50416104|Espinaca horenso orgánica|O|O||D||1
50416105|Espinaca cuarto de cordero orgánica|O|O||D||1
50416106|Espinaca malabar orgánica|O|O||D||1
50416107|Espinaca medania orgánica|O|O||D||1
50416108|Espinaca orach orgánica|O|O||D||1
50416109|Espinaca savoy orgánica|O|O||D||1
50416110|Espinaca hoja de sigma orgánica|O|O||D||1
50416111|Espinaca espacio orgánica|O|O||D||1
50416112|Espinaca trinidad orgánica|O|O||D||1
50416113|Espinaca salvaje orgánica|O|O||D||1
50416114|Espinaca nueva zelandia orgánica|O|O||D||1
50416115|Espinaca iceplant orgánica|O|O||D||1
50416200|Calabazas orgánicas|O|O||D||1
50416201|Calabaza boston  orgánica|O|O||D||1
50416202|Calabaza buttemut orgánica|O|O||D||1
50416203|Calabaza costata romanesca orgánica|O|O||D||1
50416204|Calabaza crookneck orgánica|O|O||D||1
50416205|Calabaza  cucuzza orgánica|O|O||D||1
50416206|Calabaza  delicata orgánica|O|O||D||1
50416207|Calabaza  delisioso orgánica|O|O||D||1
50416208|Calabaza verano dorado cuello torsido orgánica|O|O||D||1
50416209|Calabaza prolífico temprano cuello recto  orgánica|O|O||D||1
50416210|Calabaza  oro orgánica|O|O||D||1
50416211|Calabaza  jack pequeño orgánica|O|O||D||1
50416212|Calabaza  campo de kentucky orgánica|O|O||D||1
50416213|Calabaza marrow orgánica|O|O||D||1
50416214|Calabaza  medio oriente orgánica|O|O||D||1
50416215|Calabaza  miniatura orgánica|O|O||D||1
50416216|Calabaza  orangetti orgánica|O|O||D||1
50416217|Calabaza pattypan orgánica|O|O||D||1
50416218|Calabaza  rondini orgánica|O|O||D||1
50416219|Calabaza  redonda orgánica|O|O||D||1
50416220|Calabaza  espagueti orgánica|O|O||D||1
50416221|Calabaza  estripeti orgánica|O|O||D||1
50416222|Calabaza  molde dulce orgánica|O|O||D||1
50416223|Calabaza  empanada dulce orgánica|O|O||D||1
50416224|Calabaza  premio triple orgánica|O|O||D||1
50416225|Calabaza waltham butternut orgánica|O|O||D||1
50416226|Calabaza  arbusto scallop amarillo orgánica|O|O||D||1
50416227|Calabaza cuello recto amarillo orgánica|O|O||D||1
50416228|Calabaza zafiro orgánica|O|O||D||1
50416229|Calabaza zucchini orgánica|O|O||D||1
50416300|Batatas orgánicas|O|O||D||1|Camotes orgánicos
50416301|Batata beauregard orgánica|O|O||D||1|Camote beauregard orgánico
50416302|Batata centennial orgánica|O|O||D||1|Camote centennial orgánico
50416303|Batata diane orgánica|O|O||D||1|Camote diane orgánico
50416304|Batata dulce garnet orgánica|O|O||D||1|Camote dulce garnet orgánico
50416305|Batata georgia dulce rojo orgánica|O|O||D||1|Camote georgia dulce rojo orgánico
50416306|Batata  dorado orgánica|O|O||D||1|Camote dorado orgánico
50416307|Batata hanna  orgánica|O|O||D||1|Camote hanna orgánico
50416308|Batata japonés orgánica|O|O||D||1|Camote japonés orgánico
50416309|Batata jersey orgánica|O|O||D||1|Camote jersey orgánico
50416310|Batata joya orgánica|O|O||D||1|Camote joya orgánico
50416311|Batata meryland roja orgánica|O|O||D||1|Camote meryland roja orgánico
50416312|Batata nema dorado orgánica|O|O||D||1|Camote nema dorado orgánico
50416313|Batata o´henry orgánica|O|O||D||1|Camote o´henry orgánico
50416314|Batata okinawan orgánica|O|O||D||1|Camote okinawan orgánico
50416315|Batata naranja orgánica|O|O||D||1|Camote naranja orgánico
50416316|Batata oriental orgánica|O|O||D||1|Camote oriental orgánico
50416317|Batata jersey rojo orgánica|O|O||D||1|Camote jersey rojo orgánico
50416318|Batata mar rojo orgánica|O|O||D||1|Camote mar rojo orgánico
50416319|Batata brillo rojo orgánica|O|O||D||1|Camote brillo rojo orgánico
50416320|Batata jersey amarillo orgánica|O|O||D||1|Camote jersey amarillo orgánico
50416400|Tomates orgánicos|O|O||D||1|Jitomates orgánicos
50416401|Tomates ailsa craig  orgánicos|O|O||D||1|Jitomate ailsa craig orgánico
50416402|Tomates alicante orgánicos|O|O||D||1|Jitomate alicante orgánico
50416403|Tomates ciruela negra orgánicos|O|O||D||1|Jitomate ciruela negra orgánico
50416404|Tomates vino de brandy orgánicos|O|O||D||1|Jitomate vino de brandy orgánico
50416405|Tomates bella cereza orgánicos|O|O||D||1|Jitomate bella cereza orgánico
50416406|Tomates cereza orgánicos|O|O||D||1|Jitomate cereza orgánico
50416407|Tomates delicioso orgánicos|O|O||D||1|Jitomate delicioso orgánico
50416408|Tomates dombito orgánicos|O|O||D||1|Jitomate dombito orgánico
50416409|Tomates delicia del jardín orgánicos|O|O||D||1|Jitomate delicia del jardín orgánico
50416410|Tomates uva orgánicos|O|O||D||1|Jitomate uva orgánico
50416411|Tomates verde orgánicos|O|O||D||1|Tomate verde orgánico
50416412|Tomates super marmande orgánicos|O|O||D||1|Jitomate super marmande orgánico
50416413|Tomates rayas naturales marvel orgánicos|O|O||D||1|Jitomate rayas naturales marvel orgánico
50416414|Tomates minibel orgánicos|O|O||D||1|Jitomate minibel orgánico
50416415|Tomates oaxacan orgánicos|O|O||D||1|Jitomate oaxaca orgánico
50416416|Tomates alerta roja orgánicos|O|O||D||1|Jitomate alerta roja orgánico
50416417|Tomates roma vf orgánicos|O|O||D||1|Jitomate roma vf orgánico
50416418|Tomates marzano zan orgánicos|O|O||D||1|Jitomate marzano zan orgánico
50416419|Tomates shirley orgánicos|O|O||D||1|Jitomate shirley orgánico
50416420|Tomates siberia orgánicos|O|O||D||1|Jitomate siberia orgánico
50416421|Tomates super beefsteak orgánicos|O|O||D||1|Jitomate super beefsteak orgánico
50416422|Tomates tigerella orgánicos|O|O||D||1|Jitomate tigerella orgánico
50416423|Tomates tiny tim orgánicos|O|O||D||1|Jitomate tiny tim orgánico
50416424|Tomates tumbler orgánicos|O|O||D||1|Jitomate tumbler orgánico
50416425|Tomates cocktail amarillo orgánicos|O|O||D||1
50416426|Tomates forma de pera amarillo orgánicos|O|O||D||1
50416427|Tomates perfección amarilla orgánicos|O|O||D||1
50416500|Nabos orgánicos|O|O||D||1
50416501|Nabo globo verde orgánico|O|O||D||1
50416502|Nabo bola dorada orgánico|O|O||D||1
50416503|Nabo mercado de manchester orgánico|O|O||D||1
50416504|Nabo top morado milan orgánico|O|O||D||1
50416505|Nabo top morado blanco orgánico|O|O||D||1
50416506|Nabo bola de nieve orgánico|O|O||D||1
50416507|Nabo tokio orgánico|O|O||D||1
50416508|Nabo cruz de tokio orgánico|O|O||D||1
50416600|Auyamas orgánicas|O|O||D||1|Calabazas gigantes orgánicas
50416601|Calabaza acorn orgánica|O|O||D||1|Calabaza gigante acorn orgánica
50416602|Calabaza gigante atlántico orgánica|O|O||D||1|Calabaza gigante atlántico orgánica
50416603|Calabaza banana rosado orgánica|O|O||D||1|Calabaza gigante banana rosado orgánica
50416604|Calabaza max grande orgánica|O|O||D||1|Calabaza gigante max orgánica
50416605|Calabaza  orgánica|O|O||D||1|Calabaza de castilla orgánica
50416606|Calabaza carnaval orgánica|O|O||D||1|Calabaza gigante carnaval orgánica
50416607|Auyama queso orgánica|O|O||D||1|Calabaza gigante queso orgánica
50416608|Calabaza príncipe coronado orgánica|O|O||D||1|Calabaza gigante príncipe coronado orgánica
50416609|Calabaza  curcibita orgánica|O|O||D||1|Calabaza gigante curcibita orgánica
50416610|Calabaza cushaw orgánica|O|O||D||1|Calabaza gigante cushaw orgánica
50416611|Calabaza  gigante auyama orgánica|O|O||D||1
50416612|Calabaza  hubbard orgánica|O|O||D||1|Calabaza gigante hubbard orgánica
50416613|Calabaza  jerrahdale orgánica|O|O||D||1|Calabaza gigante jerrahdale orgánica
50416614|Calabaza  kabocha orgánica|O|O||D||1|Calabaza gigante kabocha orgánica
50416615|Calabaza queensland azul orgánica|O|O||D||1|Calabaza gigante queensland azul orgánica
50416616|Calabaza rouge vif détampes orgánica|O|O||D||1|Calabaza gigante rouge vif détampes orgánica
50416617|Calabaza  turban turco orgánica|O|O||D||1|Calabaza gigante turban turco orgánica
50416618|Calabaza  valenciano orgánica|O|O||D||1|Calabaza gigante valenciano orgánica
50416619|Calabaza  warted hubbard orgánica|O|O||D||1|Calabaza gigante warted hubbard orgánica
50416620|Auyama whangaparoa orgánica|O|O||D||1|Calabaza gigante whangaparoa orgánica
50416700|Maíces Orgánicos|O|O||D||1
50416701|Ñame agria africana orgánico|O|O||D||1
50416702|Ñame agria asiática orgánico|O|O||D||1
50416703|Ñame china orgánico|O|O||D||1
50416704|Ñame globo orgánico|O|O||D||1
50416705|Ñame grater orgánico|O|O||D||1
50416706|Ñame japonesa|O|O||D||1
50416707|Ñame lesser orgánico|O|O||D||1
50416708|Ñame papa orgánico|O|O||D||1
50416709|Ñame guinea blanca orgánico|O|O||D||1
50416710|Ñame guinea amarillo orgánico|O|O||D||1
50416800|Ñames orgánicos|O|O||D||1
50416801|Maíz aloha orgánico|O|O||D||1
50416802|Maíz alpine orgánico|O|O||D||1
50416803|Maíz ambrosia orgánico|O|O||D||1
50416804|Maíz argent orgánico|O|O||D||1
50416805|Maíz aspen orgánico|O|O||D||1
50416806|Maíz avalancha orgánico|O|O||D||1
50416807|Maíz biqueen orgánico|O|O||D||1
50416808|Maíz  bodacious orgánico|O|O||D||1
50416809|Maíz  mantequilla y azúcar orgánico|O|O||D||1
50416810|Maíz  calico belle orgánico|O|O||D||1
50416811|Maíz  camelot orgánico|O|O||D||1
50416812|Maíz  challengercrisp ‘n dulce orgánico|O|O||D||1
50416813|Maíz  campeón orgánico|O|O||D||1
50416814|Maíz  algodón de azúcar orgánico|O|O||D||1
50416815|Maíz  dártagnan orgánico|O|O||D||1
50416816|Maíz  dazzle orgánico|O|O||D||1
50416817|Maíz  diamante y oro orgánico|O|O||D||1
50416818|Maíz  divinidad orgánico|O|O||D||1
50416819|Maíz  delicia doble orgánico|O|O||D||1
50416820|Maíz  gema doble orgánico|O|O||D||1
50416821|Maíz  earlivee orgánico|O|O||D||1
50416822|Maíz  temprano extra dulce orgánico|O|O||D||1
50416823|Maíz excel orgánico|O|O||D||1
50416824|Maíz  cruz dorada bantam orgánico|O|O||D||1
50416825|Maíz  miel y crema orgánico|O|O||D||1
50416826|Maíz  miel y perla orgánico|O|O||D||1
50416827|Maíz  miel dulce orgánico|O|O||D||1
50416828|Maíz  hudson orgánico|O|O||D||1
50416829|Maíz  dorado illini orgánico|O|O||D||1
50416830|Maíz  illini extra dulce orgánico|O|O||D||1
50416831|Maíz  increíble orgánico|O|O||D||1
50416832|Maíz  lochief orgánico|O|O||D||1
50416833|Maíz jubileo orgánico|O|O||D||1
50416834|Maíz jupbileo super dulce orgánico|O|O||D||1
50416835|Maíz  confite korn orgánico|O|O||D||1
50416836|Maíz  beso y acuso orgánico|O|O||D||1
50416837|Maíz  lancelot orgánico|O|O||D||1
50416838|Maíz dulce maple orgánico|O|O||D||1
50416839|Maíz  medley orgánico|O|O||D||1
50416840|Maíz merlin orgánico|O|O||D||1
50416841|Maíz milagro orgánico|O|O||D||1
50416842|Maíz nk – 199 orgánico|O|O||D||1
50416843|Maíz durazno y crema orgánico|O|O||D||1
50416844|Maíz blanco perla orgánico|O|O||D||1
50416845|Maíz  pegasus orgánico|O|O||D||1
50416846|Maíz  fenomenal orgánico|O|O||D||1
50416847|Maíz  dama de platino orgánico|O|O||D||1
50416848|Maíz  precioso orgánico|O|O||D||1
50416849|Maíz   pristine orgánico|O|O||D||1
50416850|Maíz  rápido orgánico|O|O||D||1
50416851|Maíz  radiante orgánico|O|O||D||1
50416852|Maíz  seneca brave orgánico|O|O||D||1
50416853|Maíz  amanecer seneca orgánico|O|O||D||1
50416854|Maíz  horizonte seneca orgánico|O|O||D||1
50416855|Maíz  brillo de estrella seneca orgánico|O|O||D||1
50416856|Maíz  noche blanca seneca orgánico|O|O||D||1
50416857|Maíz  showcase orgánico|O|O||D||1
50416858|Maíz  reina plateada orgánico|O|O||D||1
50416859|Maíz  bella nieve orgánico|O|O||D||1
50416860|Maíz nieve de primavera orgánico|O|O||D||1
50416861|Maíz  premio de primavera orgánico|O|O||D||1
50416862|Maíz  azúcar y oro orgánico|O|O||D||1
50416863|Maíz rollo de azúcar orgánico|O|O||D||1
50416864|Maíz nieve de azúcar orgánico|O|O||D||1
50416865|Maíz baile de sol orgánico|O|O||D||1
50416866|Maíz estrella tell orgánico|O|O||D||1
50416867|Maíz terminador orgánico|O|O||D||1
50416868|Maíz tesoro orgánico|O|O||D||1
50416869|Maíz tuxedo orgánico|O|O||D||1
50417000|Vegetales Nominant|O|O||D||1|Vegetales predominantes orgánicos, Nopal orgánico
50417001|Alfafa orgánico|O|O||D||1
50417002|Hojas de aloe orgánica|O|O||D||1|Hoja de sábila orgánica, Penca de sábila orgánica
50417003|Apio orgánico|O|O||D||1
50417004|Arrurruz orgánica|O|O||D||1
50417005|Punta de flecha orgánica|O|O||D||1|Sagittaria orgánica
50417006|rúcula orgánica|O|O||D||1
50417007|Arum orgánica|O|O||D||1|Taro orgánico
50417008|Raíz de bambú orgánica|O|O||D||1
50417009|Hojas de platano orgánica|O|O||D||1
50417010|Batatas orgánica|O|O||D||1
50417011|Brotes de frijol orgánico|O|O||D||1
50417012|Top de remolacha orgánico|O|O||D||1|Betabel orgánico
50417013|Melón agrio orgánico|O|O||D||1|Balsamina orgánica
50417014|Bayas de alcaparra orgánicas|O|O||D||1
50417015|Carob orgánico|O|O||D||1|Algarrobo orgánico
50417016|Cha-om orgánico|O|O||D||1
50417017|Chayote o guatila orgánico|O|O||D||1
50417018|Garbanzo orgánico|O|O||D||1
50417019|Verde de crisantemos orgánico|O|O||D||1
50417020|Verde de diente de león orgánico|O|O||D||1
50417021|Diente de león orgánico|O|O||D||1
50417022|Dasheen orgánico|O|O||D||1
50417023|Puntas de alverja orgánicas|O|O||D||1
50417024|Diakon orgánico|O|O||D||1|Rábano orgánico
50417025|Donqua orgánica|O|O||D||1|Ginseng hembra orgánica
50417026|Helecho orgánico|O|O||D||1|Brotes de helecho orgánico
50417027|Gai choi orgánico|O|O||D||1|Mostaza castaña orgánica
50417028|Gailon orgánico|O|O||D||1|Brécol chino orgánico
50417029|Galanga orgánico|O|O||D||1|Jengibre azul orgánico
50417030|Raíz de jengibre orgánico|O|O||D||1
50417031|Gobo orgánico|O|O||D||1|Garduña orgánica
50417032|Brote de lúpulo orgánico|O|O||D||1
50417033|Rabano blanco orgánico|O|O||D||1|Rábano de caballo orgánico
50417034|Jicama orgánica|O|O||D||1
50417035|Kuduz orgánico|O|O||D||1|Kudzu orgánico
50417036|Bulbo de margarita orgánico|O|O||D||1|Bulbo de lili chino orgánico
50417037|Linkok orgánico|O|O||D||1
50417038|Lo bok orgánico|O|O||D||1
50417039|Frijol largo orgánico|O|O||D||1|Fríjol serpiente orgánico
50417040|Raíz de lotus orgánico|O|O||D||1|Rosa del Nilo orgánica
50417041|Hojas de maguey orgánicas|O|O||D||1|Hoja de agave orgánica, Penca de maguey orgánica
50417042|Mallows orgánico|O|O||D||1|Malva orgánica
50417043|Sapote mamey orgánico|O|O||D||1|Mamey orgánico
50417044|Moap orgánico|O|O||D||1
50417045|Moo orgánico|O|O||D||1
50417046|Moqua orgánica|O|O||D||1
50417047|Opos orgánico|O|O||D||1
50417048|Corazon de palma orgánico|O|O||D||1|Palmito orgánico
50417049|Paprika orgánica|O|O||D||1
50417050|Purslane orgánico|O|O||D||1|Verdolaga orgánica
50417051|Raddichios orgánico|O|O||D||1|Achicoria morada orgánica
50417052|Sinquas orgánico|O|O||D||1|Zapallo orgánico
50417053|Frijol de soya orgánicos|O|O||D||1
50417054|Spoonwart orgánico|O|O||D||1|Hierba del escorbuto orgánica
50417055|Uva tassele hyacinth orgánico|O|O||D||1
50417056|Taro orgánico|O|O||D||1|Tales orgánica
50417057|Hoja de taro orgánico|O|O||D||1
50417058|Tallo de taro orgánico|O|O||D||1
50417059|Tapeguaje orgánico|O|O||D||1
50417060|Verde tierno orgánico|O|O||D||1
50417061|Tindora orgánico|O|O||D||1
50417062|Árbol de cebolla orgánico|O|O||D||1|Cebollas egipcias orgánica
50417063|Udo orgánico|O|O||D||1
50417064|Agua castaño orgánica|O|O||D||1|Castaña de agua china orgánica
50417065|Agua espinaca orgánica|O|O||D||1|Akankong orgánico
50417066|Yumpi orgánico|O|O||D||1|Mapuey orgánico
50417067|Yautia orgánico|O|O||D||1
50417068|Yu choy orgánico|O|O||D||1
50417069|Yuca orgánica|O|O||D||1
50417100|Alverjas dulces orgánicas|O|O||D||1|Chícharos orgánicos
50417101|Alverja biquini orgánica|O|O||D||1|Chícharo biquini orgánico
50417102|Alverja cavalier orgánica|O|O||D||1|Chícharo cavalier orgánico
50417103|Alverja margarita orgánica|O|O||D||1|Chícharo margarita orgánico
50417104|Alverja darfon orgánica|O|O||D||1|Chícharo darfon orgánico
50417105|Alverja "early onward" orgánica|O|O||D||1|Chícharo "early onward" orgánico
50417106|Alverja primer feltham orgánica|O|O||D||1|Chícharo primer feltham orgánico
50417107|Alverja verde hurst shaft orgánica|O|O||D||1|Chícharo verde hurst shaft orgánico
50417108|Guisante oregón sugar pod orgánicas|O|O||D||1|Chícharo oregón sugar pod orgánico
50417109|Alverja príncipe alberto orgánica|O|O||D||1|Chícharo príncipe alberto orgánico
50417110|Alverja reuzensuiker orgánica|O|O||D||1|Chícharo reuzensuiker orgánico
50421500|Alcachofas Secas|O|O||D||1
50421501|Alcachofa brittany seca|O|O||D||1
50421502|Alcachofa cantonesa seca|O|O||D||1
50421503|Alcachofa francesa seca|O|O||D||1
50421504|Alcachofa globo verde seca|O|O||D||1
50421505|Alcachofa gros camus de bretaña seca|O|O||D||1
50421506|Alcachofa midi seca|O|O||D||1
50421507|Alcachofa globo morado seca|O|O||D||1
50421508|Alcachofa morado cecilia seca|O|O||D||1
50421509|Alcachofa romanesco seca|O|O||D||1
50421510|Alcachofa espinoso sardo seca|O|O||D||1
50421511|Alcachofa vert de laon seca|O|O||D||1
50421512|Alcachofa violeta de chiggiia seca|O|O||D||1
50421513|Alcachofa violeta de toscana seca|O|O||D||1
50421600|Espárragos Secos|O|O||D||1
50421601|Espárragos connovers colosal secos|O|O||D||1
50421602|Espárragos franklin srcos|O|O||D||1
50421603|Espárragos mamut gigante secos|O|O||D||1
50421604|Espárragos lucullus secos|O|O||D||1
50421605|Espárragos martha washington secos|O|O||D||1
50421700|Aguacates Secos|O|O||D||1
50421701|Aguacate ajax b – 7 seco|O|O||D||1
50421702|Aguacate arue seco|O|O||D||1
50421703|Aguacate bacon seco|O|O||D||1
50421704|Aguacate benik seco|O|O||D||1
50421705|Aguacate bernecker seco|O|O||D||1
50421706|Aguacate beta seco|O|O||D||1
50421707|Aguacate biondo seco|O|O||D||1
50421708|Aguacate príncipe negro seco|O|O||D||1
50421709|Aguacate blair seco|O|O||D||1
50421710|Aguacate blair cabina seco|O|O||D||1
50421711|Aguacate cabina 1 seco|O|O||D||1
50421712|Aguacate cabina 3 seco|O|O||D||1
50421713|Aguacate cabina 5 seco|O|O||D||1
50421714|Aguacate cabina 7 seco|O|O||D||1
50421715|Aguacate cabina 8 seco|O|O||D||1
50421716|Aguacate brooks 1978 seco|O|O||D||1
50421717|Aguacate brookslate seco|O|O||D||1
50421718|Aguacate california haas seco|O|O||D||1
50421719|Aguacate catalina seco|O|O||D||1
50421720|Aguacate chica seco|O|O||D||1
50421721|Aguacate choquette seco|O|O||D||1
50421722|Aguacate cristina seco|O|O||D||1
50421723|Aguacate collison seco|O|O||D||1
50421724|Aguacate donnie seco|O|O||D||1
50421725|Aguacate dr dupis numero 2 seco|O|O||D||1
50421726|Aguacate dr. dupie  seco|O|O||D||1
50421727|Aguacate ettinger seco|O|O||D||1
50421728|Aguacate fuch seco|O|O||D||1
50421729|Aguacate fuch gwen secos|O|O||D||1
50421730|Aguacate fuerte seco|O|O||D||1
50421731|Aguacate gotham seco|O|O||D||1
50421732|Aguacate gossman seco|O|O||D||1
50421733|Aguacate guatemala sin pepa seco|O|O||D||1
50421734|Aguacate hall seco|O|O||D||1
50421735|Aguacate hardee seco|O|O||D||1
50421736|Aguacate haas seco|O|O||D||1
50421737|Aguacate herman seco|O|O||D||1
50421738|Aguacate hickson seco|O|O||D||1
50421739|Aguacate k-5 seco|O|O||D||1
50421740|Aguacate k- 9 seco|O|O||D||1
50421741|Aguacate cordero haas seco|O|O||D||1
50421742|Aguacate leona seco|O|O||D||1
50421743|Aguacate leona linda seco|O|O||D||1
50421744|Aguacate lisa p seco|O|O||D||1
50421745|Aguacate lisa loretta seco|O|O||D||1
50421746|Aguacate loretta seco|O|O||D||1
50421747|Aguacate lula seco|O|O||D||1
50421748|Aguacate lula mascarthur seco|O|O||D||1
50421749|Aguacate marcus seco|O|O||D||1
50421750|Aguacate melendez seco|O|O||D||1
50421751|Aguacate meya seco|O|O||D||1
50421752|Aguacate miguel p seco|O|O||D||1
50421753|Aguacate monroe seco|O|O||D||1
50421754|Aguacate murrieta verde seco|O|O||D||1
50421755|Aguacate nabal seco|O|O||D||1
50421756|Aguacate nadir seco|O|O||D||1
50421757|Aguacate nesbitt seco|O|O||D||1
50421758|Aguacate peterson seco|O|O||D||1
50421759|Aguacate pinelli seco|O|O||D||1
50421760|Aguacate pinkerton seco|O|O||D||1
50421761|Aguacate pollock seco|O|O||D||1
50421762|Aguacate puebla seco|O|O||D||1
50421763|Aguacate reed seco|O|O||D||1
50421764|Aguacaterue seco|O|O||D||1
50421765|Aguacateruehle seco|O|O||D||1
50421766|Aguacate ryan seco|O|O||D||1
50421767|Aguacate semil seco|O|O||D||1
50421768|Aguacate semil 43 seco|O|O||D||1
50421769|Aguacate simonds seco|O|O||D||1
50421770|Aguacate simpson seco|O|O||D||1
50421771|Aguacate taylor seco|O|O||D||1
50421772|Aguacate tonelada seco|O|O||D||1
50421773|Aguacate torre seco|O|O||D||1
50421774|Aguacate torre li seco|O|O||D||1
50421775|Aguacate trapp seco|O|O||D||1
50421776|Aguacate semilla de caribe seco|O|O||D||1
50421777|Aguacate wagner seco|O|O||D||1
50421778|Aguacate waldin seco|O|O||D||1
50421779|Aguacate wurtz seco|O|O||D||1
50421780|Aguacate zio p seco|O|O||D||1
50421781|Aguacate ziu seco|O|O||D||1
50421782|Aguacate zultano seco|O|O||D||1
50421800|Fríjoles Secos|O|O||D||1
50421801|Frijoles anasazi ® secos|O|O||D||1
50421802|Frijoles appaloosa secos|O|O||D||1
50421803|Frijoles azuki secos|O|O||D||1
50421804|Frijoles barlotti secos|O|O||D||1
50421805|Frijoles appaloosa negra secos|O|O||D||1
50421806|Frijoles negros secos|O|O||D||1
50421807|Frijoles gran negros secos|O|O||D||1
50421808|Frijoles shackamaxon negro secos|O|O||D||1
50421809|Frijoles ojo negro secos|O|O||D||1
50421810|Frijoles bobby secos|O|O||D||1
50421811|Frijoles bolita secos|O|O||D||1
50421812|Frijoles esposa perezosa carmelita secos|O|O||D||1
50421813|Frijoles calipso secos|O|O||D||1
50421814|Frijoles canelini secos|O|O||D||1
50421815|Frijoles castor secos|O|O||D||1
50421816|Frijoles amarillo chino secos|O|O||D||1
50421817|Frijoles lengua de dragón secos|O|O||D||1
50421818|Frijoles soldado europeo secos|O|O||D||1
50421819|Frijoles fava secos|O|O||D||1
50421820|Frijoles flageolet secos|O|O||D||1
50421821|Frijoles  horticultura francesa secos|O|O||D||1
50421822|Frijoles marina francesa secos|O|O||D||1
50421823|Frijoles coco gigante blanco secos|O|O||D||1
50421824|Frijoles verdes secos|O|O||D||1
50421825|Frijoles romano verde secos|O|O||D||1
50421826|Frijoles guar gum secos|O|O||D||1
50421827|Frijoles haricot secos|O|O||D||1
50421828|Frijoles hyacinth secos|O|O||D||1
50421829|Frijoles tipo italiano secos|O|O||D||1
50421830|Frijoles asombro jackson secos|O|O||D||1
50421831|Frijoles ganado jacobs  secos|O|O||D||1
50421832|Frijoles asombro kentucky secos|O|O||D||1
50421833|Frijoles riñón secos|O|O||D||1
50421834|Frijoles lima secos|O|O||D||1
50421835|Frijoles madera secos|O|O||D||1
50421836|Frijoles medula secos|O|O||D||1
50421837|Frijoles mat secos|O|O||D||1
50421838|Frijoles monstoler ganzo salvaje secos|O|O||D||1
50421839|Frijoles  mortgage lifter secos|O|O||D||1
50421840|Frijoles polilla secos|O|O||D||1
50421841|Frijoles mung secos|O|O||D||1
50421842|Frijoles munsi wolf secos|O|O||D||1
50421843|Frijoles nuna secos|O|O||D||1
50421844|Frijoles pinto secos|O|O||D||1
50421845|Frijoles runner secos|O|O||D||1
50421846|String beans secos|O|O||D||1|Ayecote seco, Fríjol gordo seco
50421847|Frijoles habichuelas secos|O|O||D||1|Ejote seco, Fríjol tierno seco
50421848|Frijoles tamarind secos|O|O||D||1
50421849|Frijoles tonka secos|O|O||D||1
50421850|Frijoles cera secos|O|O||D||1
50421851|Frijoles winged secos|O|O||D||1
50421852|Frijoles largos secos|O|O||D||1
50421900|Remolachas  Secas|O|O||D||1|Betabeles secos
50421901|Remolacha acción seca|O|O||D||1|Betabel acción seco
50421902|Remolacha albina vereduna seca|O|O||D||1|Betabel albina vereduna seco
50421903|Remolacha barababiotela de chiggia seca|O|O||D||1|Betabel barababiotela de chiggia seco
50421904|Remolacha boltardy seca|O|O||D||1|Betabel boltardy seco
50421905|Remolacha bonel seca|O|O||D||1|Betabel bonel seco
50421906|Remolacha burpees dorado seca|O|O||D||1|Betabel burpees dorado seco
50421907|Remolacha cheltenham tapa verde seca|O|O||D||1|Betabel cheltenham tapa verde seco
50421908|Remolacha cheltenham mono seca|O|O||D||1|Betabel cheltenham mono seco
50421909|Remolacha chioggia seca|O|O||D||1|Betabel chioggia seco
50421910|Remolacha cilindra seca|O|O||D||1|Betabel cilindra seco
50421911|Remolacha dégypte seca|O|O||D||1|Betabel dégypte seco
50421912|Remolacha detroit 2 rojo oscuro seca|O|O||D||1|Betabel detroit 2 rojo oscuro seco
50421913|Remolacha detroit 2 bala chiquita seca|O|O||D||1|Betabel detroit 2 bala chiquita seco
50421914|Remolacha egipcia plana  seca|O|O||D||1|Betabel egipcia plana seco
50421915|Remolacha  raíz de nabo egipcio seca|O|O||D||1|Betabel raíz de nabo egipcio seco
50421916|Remolacha fomanova seca|O|O||D||1|Betabel fomanova seco
50421917|Remolacha forono seca|O|O||D||1|Betabel forono seco
50421918|Remolacha monaco seca|O|O||D||1|Betabel mónaco seco
50421919|Remolacha monograma seca|O|O||D||1|Betabel monograma seco
50421920|Remolacha pronto seca|O|O||D||1|Betabel pronto seco
50421921|Remolacha regalía seca|O|O||D||1|Betabel regalía seco
50421922|Remolacha dulce seca|O|O||D||1|Betabel dulce seco
50422000|Brócolis  Secas|O|O||D||1
50422001|Brócolini seco|O|O||D||1
50422002|Brócoli romanesco seco|O|O||D||1
50422003|Brócoli raab seco|O|O||D||1
50422004|Brócoli chino seco|O|O||D||1
50422100|Repollitos de Bruselas  Secas|O|O||D||1|Coles de Bruselas secas
50422101|Repollitas de bruselas citade secas|O|O||D||1|Coles de Bruselas citade secas
50422102|Repollitas de bruselas falstaff secas|O|O||D||1|Coles de Bruselas falstaff secas
50422103|Repollitas de bruselas oliver secas|O|O||D||1|Coles de Bruselas oliver secas
50422104|Repollitas de bruselas peer gynt secas|O|O||D||1|Coles de Bruselas peer gynt secas
50422105|Repollitas de bruselas rampart secas|O|O||D||1|Coles de Bruselas rampart secas
50422106|Repollitas de bruselas rubine secas|O|O||D||1|Coles de Bruselas rubine secas
50422107|Repollitas de bruselas  widgeon secas|O|O||D||1|Coles de Bruselas widgeon secas
50422200|Cebollas de ensalada  Secas|O|O||D||1|Cebollas de cambray  Secas
50422201|Cebolla belstville ensalada seca|O|O||D||1|Cebolla de cambray belstville seca
50422202|Cebolla feast ensalada seca|O|O||D||1|Cebolla de cambray feast seca
50422203|Cebolla ishikura ensalada seca|O|O||D||1|Cebolla de cambray ishikura seca
50422204|Cebolla mercado kyoto seca|O|O||D||1|Cebolla de cambray mercado kyoto seca
50422205|Cebolla barba roja ensalada seca|O|O||D||1|Cebolla de cambray barba roja seca
50422206|Cebolla amigo rojo ensalada seca|O|O||D||1|Cebolla de cambray amigo rojo seca
50422207|Cebolla santa claus seca|O|O||D||1|Cebolla de cambray santa claus seca
50422208|Cebolla tokyo ensalada seca|O|O||D||1|Cebolla de cambray tokyo seca
50422209|Cebolla lisbon blanca ensalada seca|O|O||D||1|Cebolla de cambray lisbon blanca seca
50422210|Cebolla invierno blanca ensalada seca|O|O||D||1|Cebolla de cambray invierno blanca seca
50422211|Cebolla final de invierno ensalada seca|O|O||D||1|Cebolla de cambray final de invierno seca
50422300|Repollos Secos|O|O||D||1|Coles secas
50422301|Repollo negro seco|O|O||D||1|Col negro seca
50422302|Repollo savoy seco|O|O||D||1|Col savoy seca
50422303|Repollo zorrillo seco|O|O||D||1|Col zorrillo seca
50422304|Repollo blanco seco|O|O||D||1|Col blanco seca
50422400|Cardos Secos|O|O||D||1|Cardos comestibles secos
50422401|Cardos lunghi secos|O|O||D||1|Cardo comestible lunghi secos
50422402|Cardos gobbi secos|O|O||D||1|Cardo comestible gobbi secos
50422500|Zanahorias  Secas|O|O||D||1
50422501|Zanahoria amsterdam seca|O|O||D||1
50422502|Zanahoria rey de otoño seca|O|O||D||1
50422503|Zanahoria berlicum seca|O|O||D||1
50422504|Zanahoria chantenay seca|O|O||D||1
50422505|Zanahoria nantes seca|O|O||D||1
50422506|Zanahoria mercado de parís seca|O|O||D||1
50422600|Coliflores  Secas|O|O||D||1
50422601|Coliflor todo el año seca|O|O||D||1
50422602|Coliflor alverda seca|O|O||D||1
50422603|coliflor otoño gigante 3 seca|O|O||D||1
50422604|Coliflo rdok elgon seca|O|O||D||1
50422605|Coliflor bola de nieve temprana seca|O|O||D||1
50422606|Coliflor luz de lima seca|O|O||D||1
50422607|Coliflor minaret seca|O|O||D||1
50422608|Coliflor buque de naranja seca|O|O||D||1
50422609|Coliflor capa morada seca|O|O||D||1
50422610|Coliflor bola de nieve seca|O|O||D||1
50422611|Coliflor invierno walcheren 3 seca|O|O||D||1
50422612|Coliflor piedra blanca seca|O|O||D||1
50422700|Apios Secos|O|O||D||1
50422701|Apio celebridad seco|O|O||D||1
50422702|Apio nabo seco|O|O||D||1
50422703|Apio chino seco|O|O||D||1
50422704|Apio dinant francés seco|O|O||D||1
50422705|Apio gigante rosado seco|O|O||D||1
50422706|Apio gigante rojo seco|O|O||D||1
50422707|Apio gigante blanco seco|O|O||D||1
50422708|Apio dorado auto escalado seco|O|O||D||1
50422709|Apio "greensleeves" seco|O|O||D||1
50422710|Apio hopkins fenlander seco|O|O||D||1
50422711|Apio torre marfil seco|O|O||D||1
50422712|Apio lathom blanqueado seco|O|O||D||1
50422713|Apio sopa de amsterdam seco|O|O||D||1
50422714|Apio estándar cargado seco|O|O||D||1
50422715|Apio triunfo alto utah seco|O|O||D||1
50422800|Acelgas  Secas|O|O||D||1
50422801|Acelga luz brillante seca|O|O||D||1
50422802|Acelga gigante fordhook seca|O|O||D||1
50422803|Acelga luculus seca|O|O||D||1
50422804|Acelga espinaca perpetua seca|O|O||D||1
50422805|Acelga ruibarbo seca|O|O||D||1
50422806|Acelga suizo seca|O|O||D||1
50422807|Acelga volcán  seca|O|O||D||1
50422808|Acelga rey blanco seca|O|O||D||1
50422900|Achicorias Secas|O|O||D||1|Escarolas Secas
50422901|Achicoria batavian hoja ancha seca|O|O||D||1|Escarola batavian hoja ancha seca
50422902|Achicoria en cornet de bordeaux seca|O|O||D||1|Escarola en cornet de bordeaux seca
50422903|Achicoria rollo verde ruffee seca|O|O||D||1|Escarola rollo verde ruffee seca
50422904|Achicoria roll verde seca|O|O||D||1|Escarola roll verde seca
50422905|Achicoria limnoe lone seca|O|O||D||1|Escarola limnoe lone seca
50422906|Achicoria pancalieri riccia seca|O|O||D||1|Escarola pancalieri riccia seca
50422907|Achicoria ensalada rey seca|O|O||D||1|Escarola ensalada rey seca
50422908|Achicoria sanda seca|O|O||D||1|Escarola sanda seca
50422909|Achicoria scarola verde seca|O|O||D||1|Escarola scarola verde seca
50422910|Achicoria tres fine maraichere seca|O|O||D||1|Escarola tres fine maraichere seca
50422911|Achicoria wallone freisee wescelkkopf seca|O|O||D||1|Escarola wallone freisee wescelkkopf seca
50423000|Repollos chinos secos|O|O||D||1|Coles chinas secas
50423001|Bok choy seco|O|O||D||1
50423002|Bok choy enano seco|O|O||D||1
50423003|Flor de repollo chino seca|O|O||D||1|Flor de col china seca
50423004|Choy sum seco|O|O||D||1
50423005|Col (bok choy) enano seco|O|O||D||1
50423006|Col (bok choy) fengshan seco|O|O||D||1
50423007|Col (bok choy) jade pagoda seco|O|O||D||1
50423008|Col (bok choy) kasumi seco|O|O||D||1
50423009|col (bok choy)  nerva seco|O|O||D||1
50423010|Col (bok choy) rosette seco|O|O||D||1
50423011|Col (bok choy) ruffles seco|O|O||D||1
50423012|Col (bok choy) hoja  santo serrated seco|O|O||D||1
50423013|Col (bok choy) shangahai seco|O|O||D||1
50423014|Shantung seco|O|O||D||1
50423015|Repollo tip top seco|O|O||D||1|Col china tip top seco
50423016|Yau choy sum seco|O|O||D||1
50423100|Cebollines Secos|O|O||D||1
50423101|Cebollín chino seco|O|O||D||1
50423200|Maíces Secos|O|O||D||1
50423201|Maíz aloha seco|O|O||D||1
50423202|Maíz alpine seco|O|O||D||1
50423203|Maíz ambrosia seco|O|O||D||1
50423204|Maíz argent seco|O|O||D||1
50423205|Maíz aspen seco|O|O||D||1
50423206|Maíz avalancha seco|O|O||D||1
50423207|Maíz biqueen seco|O|O||D||1
50423208|Maíz  bodacious seco|O|O||D||1
50423209|Maíz  mantequilla y azúcar seco|O|O||D||1
50423210|Maíz  calico belle seco|O|O||D||1
50423211|Maíz  camelot seco|O|O||D||1
50423212|Maíz  challengercrisp ‘n dulce seco|O|O||D||1
50423213|Maíz  campeón seco|O|O||D||1
50423214|Maíz  algodón de azúcar seco|O|O||D||1
50423215|Maíz  dártagnan seco|O|O||D||1
50423216|Maíz  dazzle seco|O|O||D||1
50423217|Maíz  diamante y oro seco|O|O||D||1
50423218|Maíz  divinidad seco|O|O||D||1
50423219|Maíz  delicia doble seco|O|O||D||1
50423220|Maíz  gema doble seco|O|O||D||1
50423221|Maíz  earlivee seco|O|O||D||1
50423222|Maíz  temprano extra dulce seco|O|O||D||1
50423223|Maíz excel seco|O|O||D||1
50423224|Maíz  cruz dorada bantam seco|O|O||D||1
50423225|Maíz  miel y crema seco|O|O||D||1
50423226|Maíz  miel y perla seco|O|O||D||1
50423227|Maíz  miel dulce seco|O|O||D||1
50423228|Maíz  hudson seco|O|O||D||1
50423229|Maíz  dorado illini seco|O|O||D||1
50423230|Maíz  illini extra dulce seco|O|O||D||1
50423231|Maíz  increíble seco|O|O||D||1
50423232|Maíz  lochief seco|O|O||D||1
50423233|Maíz jubileo seco|O|O||D||1
50423234|Maíz jupbileo super dulce seco|O|O||D||1
50423235|Maíz  confite korn seco|O|O||D||1
50423236|Maíz  beso y acuso seco|O|O||D||1
50423237|Maíz  lancelot seco|O|O||D||1
50423238|Maíz dulce maple seco|O|O||D||1
50423239|Maíz  medley seco|O|O||D||1
50423240|Maíz merlin seco|O|O||D||1
50423241|Maíz milagro seco|O|O||D||1
50423242|Maíz nk – 199 seco|O|O||D||1
50423243|Maíz durazno y crema seco|O|O||D||1
50423244|Maíz blanco perla seco|O|O||D||1
50423245|Maíz  pegasus seco|O|O||D||1
50423246|Maíz  fenomenal seco|O|O||D||1
50423247|Maíz  dama de platino seco|O|O||D||1
50423248|Maíz  precioso seco|O|O||D||1
50423249|Maíz   pristine seco|O|O||D||1
50423250|Maíz  rápido seco|O|O||D||1
50423251|Maíz  radiante seco|O|O||D||1
50423252|Maíz  seneca brave seco|O|O||D||1
50423253|Maíz  amanecer seneca seco|O|O||D||1
50423254|Maíz  horizonte seneca seco|O|O||D||1
50423255|Maíz  brillo de estrella seneca seco|O|O||D||1
50423256|Maíz  noche blanca seneca seco|O|O||D||1
50423257|Maíz  showcase seco|O|O||D||1
50423258|Maíz  reina plateada seco|O|O||D||1
50423259|Maíz  bella nieve seco|O|O||D||1
50423260|Maíz nieve de primavera seco|O|O||D||1
50423261|Maíz  premio de primavera seco|O|O||D||1
50423262|Maíz  azúcar y oro seco|O|O||D||1
50423263|Maíz rollo de azúcar seco|O|O||D||1
50423264|Maíz nieve de azúcar seco|O|O||D||1
50423265|Maíz baile de sol seco|O|O||D||1
50423266|Maíz estrella tell seco|O|O||D||1
50423267|Maíz terminador seco|O|O||D||1
50423268|Maíz tesoro seco|O|O||D||1
50423269|Maíz tuxedo seco|O|O||D||1
50423300|Berros  Secos|O|O||D||1
50423301|Berros de tierra secos|O|O||D||1
50423302|Nasturtium seco|O|O||D||1
50423303|Berros de agua secos|O|O||D||1
50423304|Berros de invierno secos|O|O||D||1
50423400|Cocombros secos|O|O||D||1|Pepinos cohombro secos
50423401|Cocombro arena seco|O|O||D||1|Pepino cohombro arena seco
50423402|Cocombro americano seco|O|O||D||1|Pepino cohombro americano seco
50423403|Cocombro atena seco|O|O||D||1|Pepino cohombro atena seco
50423404|Cocombro blanco lungo de parigi seco|O|O||D||1|Pepino cohombro blanco lungo de parigi seco
50423405|Cocombro verde burpless buen sabor seco|O|O||D||1|Pepino cohombro verde burpless buen sabor seco
50423406|Cocombro chicago pickling seco|O|O||D||1|Pepino cohombro chicago pickling seco
50423407|Cocombro manzana cristal seco|O|O||D||1|Pepino cohombro manzana cristal seco
50423408|Cocombro limón cristal seco|O|O||D||1|Pepino cohombro limón cristal seco
50423409|Cocombro danimas seco|O|O||D||1|Pepino cohombro danimas seco
50423410|Cocombro gherkin seco|O|O||D||1|Pepino cohombro gherkin seco
50423411|Cocombro hokus seco|O|O||D||1|Pepino cohombro hokus seco
50423412|Cocombro japonés seco|O|O||D||1|Pepino cohombro japonés seco
50423413|Cocombro karela seco|O|O||D||1|Pepino cohombro karela seco
50423414|Cocombro korila seco|O|O||D||1|Pepino cohombro korila seco
50423415|Cocombro verde largo mejorado seco|O|O||D||1|Pepino cohombro verde largo mejorado seco
50423416|Cocombro mas mercado seco|O|O||D||1|Pepino cohombro mas mercado seco
50423417|Cocombro enano seco|O|O||D||1|Pepino cohombro enano seco
50423418|Cocombro pickling nacional seco|O|O||D||1|Pepino cohombro pickling nacional seco
50423419|Cocombro persa seco|O|O||D||1|Pepino cohombro persa seco
50423420|Cocombro telégrafo seco|O|O||D||1|Pepino cohombro telégrafo seco
50423421|Cocombro telégrafo mejorado seco|O|O||D||1|Pepino cohombro telégrafo mejorado seco
50423422|Cocombro vert de massy cornichon seco|O|O||D||1|Pepino cohombro vert de massy cornichon seco
50423423|Cocombro yamato seco|O|O||D||1|Pepino cohombro yamato seco
50423500|Berenjenas Secas|O|O||D||1
50423501|Berenjena bambino seca|O|O||D||1
50423502|Berenjena  belleza negra seca|O|O||D||1
50423503|Berenjena  negra enorme seca|O|O||D||1
50423504|Berenjena  chino seca|O|O||D||1
50423505|Berenjena  huevo de pascua seca|O|O||D||1
50423506|Berenjena  filipino seca|O|O||D||1
50423507|Berenjena   mercado de florida seca|O|O||D||1
50423508|Berenjena  india seca|O|O||D||1
50423509|Berenjena  italiano seca|O|O||D||1
50423510|Berenjena  japonés seca|O|O||D||1
50423511|Berenjena  morado largo seca|O|O||D||1
50423512|Berenjena   rayas larga seca|O|O||D||1
50423513|Berenjena  mercado de dinero seca|O|O||D||1
50423514|Berenjena  ova seca|O|O||D||1
50423515|Berenjena   arveja seca|O|O||D||1
50423516|Berenjena  tom bajito seca|O|O||D||1
50423517|Berenjena  siciliano seca|O|O||D||1
50423518|Berenjena  tailandés seca|O|O||D||1
50423519|Berenjena  violeta de florencia seca|O|O||D||1
50423520|Berenjena  blanco seca|O|O||D||1
50423600|Endivias Secas|O|O||D||1
50423601|Endivias witloof de brucelas secas|O|O||D||1
50423602|Endivias francocastel secas|O|O||D||1
50423603|Endivias catalogna de galantina secas|O|O||D||1
50423604|Endivias chioggia secas|O|O||D||1
50423605|Endivias grumolo verde secas|O|O||D||1
50423606|Endivias raíz larga magdeburg secas|O|O||D||1
50423607|Endivias palla rosa zorzi precoce secas|O|O||D||1
50423608|Endivias radice amare secas|O|O||D||1
50423609|Endivias rosa de traviso secas|O|O||D||1
50423610|Endivias  rosa de verona secas|O|O||D||1
50423611|Endivias soncino secas|O|O||D||1
50423612|Endivias sugarthi secas|O|O||D||1
50423613|Endivias verona secas|O|O||D||1
50423614|Endivias witloof zoom secas|O|O||D||1
50423700|Hinojos Secos|O|O||D||1
50423701|Hinojo cantino seco|O|O||D||1
50423702|Hinojo fino seco|O|O||D||1
50423703|Hinojoherald seco|O|O||D||1
50423704|Hinojo perfección seco|O|O||D||1
50423705|Hinojo sirio seco|O|O||D||1
50423706|Hinojo florencia dulce seco|O|O||D||1
50423707|Hinojo tardo seco|O|O||D||1
50423800|Ajos Secos|O|O||D||1
50423801|Ajo tarde california seco|O|O||D||1
50423802|Ajo tallos chinos seco|O|O||D||1
50423803|Ajo cebollin  seco|O|O||D||1
50423804|Ajo germidor seco|O|O||D||1
50423805|Ajo guardado largo seco|O|O||D||1
50423806|Ajo ramson seco|O|O||D||1
50423807|Ajo rocambola seco|O|O||D||1
50423808|Ajo rosa de lautrec seco|O|O||D||1
50423809|Ajo solent blanco seco|O|O||D||1
50423810|Ajo morado español seco|O|O||D||1
50423811|Ajo valentina italiana seco|O|O||D||1
50423900|Calabazas Secas|O|O||D||1
50423901|Petula seca|O|O||D||1|Luffa seca
50423902|Melon amargo seco|O|O||D||1
50423903|Botella calabaza seca|O|O||D||1|Acocote seco
50423904|Calabash gounds seca|O|O||D||1|Guaje o jícaro seco
50423905|Melón peludo seco|O|O||D||1
50423906|Calabaza amarga seca|O|O||D||1
50423907|Loofah suave seco|O|O||D||1|Esponja vegetal, Zacate vegetal
50423908|Serpiente de calabaza seca|O|O||D||1|Chichinda seca
50423909|Calabaza larga amarga seca|O|O||D||1
50423910|Calabaza tinda seca|O|O||D||1
50423911|Calabaza tindoori seca|O|O||D||1
50424000|Guisantes Secas|O|O||D||1|Chícharos secos
50424001|Guisante chino seca|O|O||D||1|Chícharo chino seco
50424002|Guisante inglés seca|O|O||D||1|Chícharo inglés seco
50424003|Guisante de jardín seca|O|O||D||1|Chícharo de jardín seco
50424004|Guisante nieve seca|O|O||D||1|Chícharo nieve seco
50424005|Guisante snap dulce seca|O|O||D||1|Chícharo snap dulce seco
50424100|Hierbas Secas|O|O||D||1|Perejil seco, Yerbabuena o hierbabuena seca
50424101|Albahaca seca|O|O||D||1
50424102|Laurel seco|O|O||D||1
50424103|Borraja seca|O|O||D||1
50424104|Alcaravea seca|O|O||D||1
50424105|Perifollo seco|O|O||D||1
50424106|Cilantro seco|O|O||D||1
50424107|Chipolinos seco|O|O||D||1
50424108|Hoja de curry seca|O|O||D||1
50424109|Eneldo seco|O|O||D||1
50424110|Epazote seco|O|O||D||1
50424111|Fenogreco seco|O|O||D||1
50424112|Limonaria seca|O|O||D||1|Té de limón seco
50424113|Mejorana seca|O|O||D||1
50424114|Menta seca|O|O||D||1
50424115|Orégano seco|O|O||D||1
50424116|Pápalo seco|O|O||D||1
50424117|Pápalo delgado seco|O|O||D||1
50424118|Perilla seca|O|O||D||1|Albahaca japonesa seca
50424119|Recao  seco|O|O||D||1
50424120|Romero seco|O|O||D||1
50424121|Salvia seca|O|O||D||1
50424122|Salsifí seca|O|O||D||1|Barba cabruna seca
50424123|Satureja seca|O|O||D||1|Ajedreas  seca
50424124|Estragón seco|O|O||D||1|Tarragón  seco
50424125|Tomillo seco|O|O||D||1
50424126|Tumeric seco|O|O||D||1|Cúrcuma seca
50424127|Verdolaga seca|O|O||D||1
50424200|Coles Secas|O|O||D||1
50424201|Col rizada seca|O|O||D||1
50424202|Repollo verde seco|O|O||D||1
50424300|Colinabos Secos|O|O||D||1|Colirrábanos Secos
50424301|Colinabo estrella azur seco|O|O||D||1|Colirrábano estrella azur seco
50424302|Colinabo verde viena seco|O|O||D||1|Colirrábano verde viena seco
50424303|Colinabo lanro seco|O|O||D||1|Colirrábano lanro seco
50424304|Colinabo viena morada seco|O|O||D||1|Colirrábano viena morada seco
50424305|Colinabo trero rowel seco|O|O||D||1|Colirrábano trero rowel seco
50424306|Colinabo viena blanca seco|O|O||D||1|Colirrábano viena blanca seco
50424400|Puerros Secos|O|O||D||1|Poros Secos
50424401|Puerro cobra gigante otoño seco|O|O||D||1|Poro cobra gigante otoño seco
50424402|Puerro otoño mamut 2 seco|O|O||D||1|Poro otoño mamut 2 seco
50424403|Puerro blue de solaise seco|O|O||D||1|Poro blue de solaise seco
50424404|Puerro cortina seco|O|O||D||1|Poro cortina seco
50424405|Puerro prelina seco|O|O||D||1|Poro prelina seco
50424406|Puerro salvaje seco|O|O||D||1|Poro salvaje seco
50424500|Lentejas  Secas|O|O||D||1
50424501|Lenteja beluga seca|O|O||D||1
50424502|Lenteja  verde francesa seca|O|O||D||1
50424503|Lenteja verde seca|O|O||D||1
50424504|Lenteja crimson pequeña seca|O|O||D||1
50424505|Lenteja pardina española seca|O|O||D||1
50424506|Lenteja roja separada seca|O|O||D||1
50424507|Lenteja amarilla separad seca|O|O||D||1
50424508|Lenteja tarahumara rosada seca|O|O||D||1
50424600|Lechugas Secas|O|O||D||1
50424601|Lechuga  bibb seca|O|O||D||1
50424602|Lechuga  boston seca|O|O||D||1
50424603|Lechuga frisee seca|O|O||D||1
50424604|Lechuga rosa lola seca|O|O||D||1
50424605|Lechuga  mixta masculina seca|O|O||D||1
50424606|Lechuga mizuna seca|O|O||D||1
50424607|Lechuga hoja roja seca|O|O||D||1
50424608|Lechuga oja roja roble seca|O|O||D||1
50424609|Lechuga romana ruby seca|O|O||D||1
50424610|Lechuga romana bebé roja seca|O|O||D||1
50424611|Lechuga cabeza de mantequilla seca|O|O||D||1
50424612|Lechuga china seca|O|O||D||1|Lechuga orejona seca
50424613|Lechuga cabeza tostada seca|O|O||D||1
50424614|Lechuga hoja verde seca|O|O||D||1
50424615|Lechuga iceberg seca|O|O||D||1
50424616|Lechuga cordero seca|O|O||D||1
50424617|Lechuga hoja suelta seca|O|O||D||1
50424618|Lechuga mache seca|O|O||D||1
50424619|Lechuga boston roja seca|O|O||D||1
50424620|Lechuga cabeza roja seca|O|O||D||1
50424621|Lechuga romana seca|O|O||D||1
50424622|Lechuga mostza roja rusa seca|O|O||D||1
50424623|Lechuga tatsoi seca|O|O||D||1
50424700|Ñames Secos|O|O||D||1
50424701|Ñame amarilla seca|O|O||D||1
50424702|Ñame blanca seca|O|O||D||1
50424703|Ñame coco seca|O|O||D||1
50424704|Ñame eddoes seca|O|O||D||1
50424705|Ñame isleña seca|O|O||D||1
50424706|Ñame lila seca|O|O||D||1
50424800|Hongos o champiñones Secos|O|O||D||1
50424801|Champiñón trompeta negra seco|O|O||D||1
50424802|Champiñón carmelito seco|O|O||D||1
50424803|Champiñón  seco|O|O||D||1
50424804|Champiñón chanterelle seco|O|O||D||1
50424805|Champiñón cremini seco|O|O||D||1
50424806|Champiñón enoki seco|O|O||D||1
50424807|Champiñón puercoespín seco|O|O||D||1
50424808|Champiñón gallina del bosque seco|O|O||D||1
50424809|Champiñón langosta seco|O|O||D||1
50424810|Champiñón morels seco|O|O||D||1
50424811|Champiñón ostra seco|O|O||D||1
50424812|Champiñón pleurotus seco|O|O||D||1
50424813|Champiñón pompom seco|O|O||D||1
50424814|Champiñón porcieni seco|O|O||D||1
50424815|Champiñón portobello seco|O|O||D||1
50424816|Champiñón shitake seco|O|O||D||1
50424817|Champiñón shimeji seco|O|O||D||1
50424818|Champiñón san jorge seco|O|O||D||1
50424819|Champiñón blanco seco|O|O||D||1
50424820|Champiñón tompeta blanca seco|O|O||D||1
50424821|Champiñón woodear seco|O|O||D||1
50424900|Mostazas Secas|O|O||D||1
50424901|Mostaza bambú  seca|O|O||D||1
50424902|Mostaza ajo seca|O|O||D||1
50424903|Mostaza hoja gigante seca|O|O||D||1
50424904|Mostaza rojo en nieve seca|O|O||D||1
50424905|Mostaza sureño seca|O|O||D||1
50424906|Mostaza corazón envuelto seca|O|O||D||1
50425000|Solanáceas (nightshades) Secas|O|O||D||1
50425001|Lámpara china seca|O|O||D||1
50425002|Mora de jardín|O|O||D||1
50425003|Naranjilla secas|O|O||D||1
50425004|Tomatillo seca|O|O||D||1
50425100|Okras Secas|O|O||D||1
50425101|Okra artista seca|O|O||D||1
50425102|Okra vinotinto seca|O|O||D||1
50425103|Okra sin columna clemson seca|O|O||D||1
50425104|Okra verde enano vaina larga seca|O|O||D||1
50425105|Okra  mamut sin columna seca|O|O||D||1
50425106|Okra terciopelo rojo seca|O|O||D||1
50425107|Okra estrella de david reliquia seca|O|O||D||1
50425200|Cebollas Secas|O|O||D||1
50425201|Cebolla albion seca|O|O||D||1
50425202|Cebolla alisia craig seca|O|O||D||1
50425203|Cebolla hirviendo seca|O|O||D||1
50425204|Cebolla bufalo seca|O|O||D||1
50425205|Cebolla bulbo seca|O|O||D||1
50425206|Cebolla cremosa seca|O|O||D||1
50425207|Cebolla amarillo expreso o – x seca|O|O||D||1
50425208|Cebolla kelsae seca|O|O||D||1
50425209|Cebolla gigante marshal globo fen seca|O|O||D||1
50425210|Cebolla perla seca|O|O||D||1
50425211|Cebolla baron rojo seca|O|O||D||1
50425212|Cebolla roja seca|O|O||D||1|Cebolla morada seca
50425213|Cebolla rijnsberger seca|O|O||D||1
50425214|Cebolla senshyu semi – globo amarillo seca|O|O||D||1
50425215|Cebolla sturon seca|O|O||D||1
50425216|Cebolla sturgatter seca|O|O||D||1
50425217|Cebolla dulce seca|O|O||D||1
50425218|Cebolla torpedo o rojo italiana seca|O|O||D||1
50425219|Cebolla roja guardada seca|O|O||D||1
50425220|Cebolla blanca guardada seca|O|O||D||1
50425221|Cebolla amarilla guardada seca|O|O||D||1
50425300|Alverjas Secas|O|O||D||1|Cacahuates secos
50425301|Maní bambara seco|O|O||D||1|Cacahuate bambara seco
50425302|Maní florunner seco|O|O||D||1|Cacahuate florunner seco
50425303|Maní husa / kerstings seco|O|O||D||1|Cacahuate husa / kerstings seco
50425304|Maní español seco|O|O||D||1|Cacahuate español seco
50425305|Maní valencia seco|O|O||D||1|Cacahuate valencia seco
50425306|Maní virginia seco|O|O||D||1|Cacahuate virginia seco
50425400|Maníes Secos|O|O||D||1|Cacahuates secos
50425401|Alverja casco morado seca|O|O||D||1|Cacahuate casco morado seco
50425402|Alverja pinkeye seca|O|O||D||1|Cacahuate pinkeye seco
50425403|Alverja crowder seca|O|O||D||1|Cacahuate crowder seco
50425404|Alverja acre blanco seca|O|O||D||1|Cacahuate acre blanco seco
50425405|Alverja ojo negro seca|O|O||D||1|Cacahuate ojo negro seco
50425406|Alverja crema zipper seca|O|O||D||1|Cacahuate crema zipper seco
50425500|Pimientos Secos|O|O||D||1|Chiles secos
50425501|Pimentón ají seco|O|O||D||1|Ají seco
50425502|Pimentón  árbol seco|O|O||D||1|Chile de árbol seco
50425503|Pimentón queso seco|O|O||D||1
50425504|Pimentón chilaca seco|O|O||D||1|Chilaca
50425505|Pimentón cubanelles seco|O|O||D||1|Chile cubanelle o pimienta italiana seca
50425506|Pimentón fresno seco|O|O||D||1|Chile fresno seco
50425507|Pimentón kapia seco|O|O||D||1|Chile kapia seco
50425508|Pimentón coreano seco|O|O||D||1|Chile cheongyang seco
50425509|Pimentón manzano seco|O|O||D||1|Chile manzano o de cera
50425510|Pimentón melrose seco|O|O||D||1
50425511|Pimentón chile amarillo seco|O|O||D||1|Chile peruano amarillo seco
50425512|Pimentón aji dulce seco|O|O||D||1|Ají dulce seco
50425513|Pimentón anaheim seco|O|O||D||1
50425514|Pimentón ancho seco|O|O||D||1|Chile ancho o mulato
50425515|Pimentón campana seco|O|O||D||1|Chile campana seco
50425516|Pimentón cascabel seco|O|O||D||1|Chile cascabel
50425517|Pimentón cayenne seco|O|O||D||1|Pimienta de Cayena o roja seca
50425518|Pimentón anfitrión cereza seco|O|O||D||1
50425519|Pimentón chitespin seco|O|O||D||1|Chile chiltepín seco
50425520|Pimentón dedo picante seco|O|O||D||1|Chile Jwala seco
50425521|Pimentón guajillo seco|O|O||D||1|Chile guajillo
50425522|Pimentón guerro seco|O|O||D||1|Chile güero seco
50425523|Pimentón habanero seco|O|O||D||1|Chile habanero seco
50425524|Pimentón cera de hungria seco|O|O||D||1|Pimentón húngaro seco
50425525|Pimentón jalapeño seco|O|O||D||1|Chile chipotle o morita
50425526|Pimentón picante largo seco|O|O||D||1|Chile cola de rata seco
50425527|Pimentón marasol seco|O|O||D||1|Chile mirasol
50425528|Pimentón pasilla seco|O|O||D||1|Chile pasilla
50425529|Pimentón peperoncini seco|O|O||D||1
50425530|Pimentón pequin seco|O|O||D||1|Chile piquín seco
50425531|Pimentón pimiento seco|O|O||D||1|Pimiento morrón seco
50425532|Pimentón poblano seco|O|O||D||1|Chile poblano
50425533|Pimentón scotch bonnet seco|O|O||D||1|Pimientos Bonney o rojos Caribe seco
50425534|Pimentón serrano seco|O|O||D||1|Chile serrano, Chile verde
50425535|Pimentón tabasco seco|O|O||D||1|Chile tabasco seco
50425536|Pimentón tai  seco|O|O||D||1|Chile ojo de pájaro seco
50425537|Pimentón tepin seco|O|O||D||1|Chile mosquito o catarina
50425538|Pimentón panca chilli seco|O|O||D||1|Chile panca seco
50425600|Papas Secas|O|O||D||1
50425601|Papa blanca larga seca|O|O||D||1
50425602|Papa redonda blanca seca|O|O||D||1
50425603|Papa redonda roja seca|O|O||D||1|Papa de cambray seca
50425604|Papa  russet seca|O|O||D||1
50425605|Papa morada seca|O|O||D||1
50425606|Papa amarilla seca|O|O||D||1
50425607|Papa nueva seca|O|O||D||1
50425608|Papa especial seca|O|O||D||1
50425609|Tocosh seco|O|O||D||1
50425700|Nabos suecos secos|O|O||D||1
50425701|Nabo sueco acme seco|O|O||D||1
50425702|Nabo sueco angela seco|O|O||D||1
50425703|Nabo sueco el mejor seco|O|O||D||1
50425704|Nabo sueco marian seco|O|O||D||1
50425800|Vegetales marinos Secos|O|O||D||1
50425801|Agar-agar seco|O|O||D||1
50425802|Arame  seca|O|O||D||1
50425803|Alga dulce seca|O|O||D||1
50425804|Habichuelas vert de mer seca|O|O||D||1
50425805|Hijiki seca|O|O||D||1
50425806|Musgo irlandés seca|O|O||D||1
50425807|Quelpo seco|O|O||D||1
50425808|Laver seco|O|O||D||1
50425809|Nori seco|O|O||D||1
50425810|Alga roja seca|O|O||D||1
50425811|Kale de mar seca|O|O||D||1
50425812|Lechuga de mar seca|O|O||D||1
50425813|Algas de mar seca|O|O||D||1
50425814|Spirulina seca|O|O||D||1
50425815|Susabi nuri seca|O|O||D||1
50425816|Wakame seca|O|O||D||1
50425900|Chalotes Secos|O|O||D||1
50425901|Chalote atlántica seco|O|O||D||1
50425902|Chalote creación seco|O|O||D||1
50425903|Chalote drittler nido blanco seco|O|O||D||1
50425904|Chalote gigante mejorado amarillo seco|O|O||D||1
50425905|Chalote gourmet dorado seco|O|O||D||1
50425906|Chalote grise de bagnolet seco|O|O||D||1
50425907|Chalote hative de nort seco|O|O||D||1
50425908|Chalote pikant seco|O|O||D||1
50425909|Chalote papa roja seco|O|O||D||1
50425910|Chalote sante seco|O|O||D||1
50425911|Chalote topper seco|O|O||D||1
50426000|Alazanes Secos|O|O||D||1|Acederas secas
50426001|Alazán dock seca|O|O||D||1|Acedera dock seca
50426002|Alazán jardín seca|O|O||D||1|Acedera jardín seca
50426003|Alazán oveja seca|O|O||D||1|Acedera oveja seca
50426004|Alazán madera seca|O|O||D||1|Acedera madera seca
50426100|Espinacas Secas|O|O||D||1
50426101|Espinaca americana seca|O|O||D||1
50426102|Espinaca bloomsdale seca|O|O||D||1
50426103|Espinaca invierno gigante seca|O|O||D||1
50426104|Espinaca horenso seca|O|O||D||1
50426105|Espinaca planta de hielo seca|O|O||D||1
50426106|Espinaca  cuarto de cordero seca|O|O||D||1
50426107|Espinaca malabra seca|O|O||D||1
50426108|Espinaca mendania seca|O|O||D||1
50426109|Espinaca nueva zelandia seca|O|O||D||1
50426110|Espinaca orach seca|O|O||D||1
50426111|Espinaca savoy seca|O|O||D||1
50426112|Espinaca hoja de sigma seca|O|O||D||1
50426113|Espinaca espacio seca|O|O||D||1
50426114|Espinaca trinidad seca|O|O||D||1
50426115|Espinaca agua seca|O|O||D||1
50426116|Espinaca de agua sesa|O|O||D||1
50426200|Calabazas Secas|O|O||D||1
50426201|Calabaza boston seca|O|O||D||1
50426202|Calabaza buttemut seca|O|O||D||1
50426203|Calabaza costata romanesca seca|O|O||D||1
50426204|Calabaza crookneck seca|O|O||D||1
50426205|Calabaza  cucuzza seca|O|O||D||1
50426206|Calabaza  delicata seca|O|O||D||1
50426207|Calabaza  delisioso seca|O|O||D||1
50426208|Calabaza verano dorado cuello torcido seca|O|O||D||1
50426209|Calabaza prolífico temprano cuello recto seca|O|O||D||1
50426210|Calabaza  oro seca|O|O||D||1
50426211|Calabaza  jack pequeño seca|O|O||D||1
50426212|Calabaza  campo de kentucky seca|O|O||D||1
50426213|Calabaza marrow seca|O|O||D||1
50426214|Calabaza  medio oriente seca|O|O||D||1
50426215|Calabaza  miniatura seca|O|O||D||1
50426216|Calabaza  orangetti seca|O|O||D||1
50426217|Calabaza pattypan seca|O|O||D||1
50426218|Calabaza  rondini seca|O|O||D||1
50426219|Calabaza  redonda seca|O|O||D||1
50426220|Calabaza  espagueti seca|O|O||D||1
50426221|Calabaza  estripeti seca|O|O||D||1
50426222|Calabaza  molde dulce seca|O|O||D||1
50426223|Calabaza  empanada dulce seca|O|O||D||1
50426224|Calabaza  premio triple  seca|O|O||D||1
50426225|Calabaza waltham butternut seca|O|O||D||1
50426226|Calabaza  arbusto scallop amarillo seca|O|O||D||1
50426227|Calabaza cuello recto amarillo seca|O|O||D||1
50426228|Calabaza zafiro seca|O|O||D||1
50426229|Calabaza zucchini seca|O|O||D||1
50426300|Batatas Secas|O|O||D||1|Camotes secos
50426301|Batata beauregard seca|O|O||D||1|Camote beauregard seca
50426302|Batata centennial seca|O|O||D||1|Camote centennial seca
50426303|Batata diane seca|O|O||D||1|Camote diane seca
50426304|Batata dulce garnet seca|O|O||D||1|Camote dulce garnet seca
50426305|Batata georgia dulce rojo seca|O|O||D||1|Camote georgia dulce rojo seca
50426306|Batata  dorado seca|O|O||D||1|Camote dorado seca
50426307|Batata hanna  seca|O|O||D||1|Camote hanna seca
50426308|Batata japonés seca|O|O||D||1|Camote japonés seca
50426309|Batata jersey seca|O|O||D||1|Camote jersey seca
50426310|Batata joya seca|O|O||D||1|Camote joya seca
50426311|Batata meryland roja seca|O|O||D||1|Camote meryland roja seca
50426312|Batata nema dorado seca|O|O||D||1|Camote nema dorado seca
50426313|Batata o´henry seca|O|O||D||1|Camote o´henry seca
50426314|Batata okinawan seca|O|O||D||1|Camote okinawan seca
50426315|Batata naranja seca|O|O||D||1|Camote naranja seca
50426316|Batata oriental seca|O|O||D||1|Camote oriental seca
50426317|Batata jersey rojo seca|O|O||D||1|Camote jersey rojo seca
50426318|Batata mar rojo seca|O|O||D||1|Camote mar rojo seca
50426319|Batata brillo rojo seca|O|O||D||1|Camote brillo rojo seca
50426320|Batata jersey amarillo seca|O|O||D||1|Camote jersey amarillo seca
50426400|Tomates Secos|O|O||D||1|Jitomates Secos
50426401|Tomates ailsa craig seco|O|O||D||1|Jitomate ailsa craig seco
50426402|Tomates alicante seco|O|O||D||1|Jitomate alicante seco
50426403|Tomates ciruela negra seco|O|O||D||1|Jitomate ciruela negra seco
50426404|Tomates vino de brandy seco|O|O||D||1|Jitomate vino de brandy seco
50426405|Tomates bella cereza seco|O|O||D||1|Jitomate bella cereza seco
50426406|Tomates cereza seco|O|O||D||1|Jitomate cereza seco
50426407|Tomates delicioso seco|O|O||D||1|Jitomate delicioso seco
50426408|Tomates dombito seco|O|O||D||1|Jitomate dombito seco
50426409|Tomates delicia del jardín seco|O|O||D||1|Jitomate delicia del jardín seco
50426410|Tomates uva seco|O|O||D||1|Jitomate uva seco
50426411|Tomates verde seco|O|O||D||1|Tomate verde seco
50426412|Tomates super marmande seco|O|O||D||1|Jitomate super marmande seco
50426413|Tomates rayas naturales marvel seco|O|O||D||1|Jitomate rayas naturales marvel seco
50426414|Tomates minibel seco|O|O||D||1|Jitomate minibel seco
50426415|Tomates oaxacan seco|O|O||D||1|Jitomate oaxaca seco
50426416|Tomates alerta roja seco|O|O||D||1|Jitomate alerta roja seco
50426417|Tomates roma vf seco|O|O||D||1|Jitomate roma vf seco
50426418|Tomates marzano zan seco|O|O||D||1|Jitomate marzano zan seco
50426419|Tomates shirley seco|O|O||D||1|Jitomate shirley seco
50426420|Tomates siberia seco|O|O||D||1|Jitomate siberia seco
50426421|Tomates super beefsteak seco|O|O||D||1|Jitomate super beefsteak seco
50426422|Tomates tigerella seco|O|O||D||1|Jitomate tigerella seco
50426423|Tomates tiny tim seco|O|O||D||1|Jitomate tiny tim seco
50426424|Tomates tumbler seco|O|O||D||1|Jitomate tumbler seco
50426425|Tomates cocktail amarillo seco|O|O||D||1
50426426|Tomates forma de pera amarillo seco|O|O||D||1
50426427|Tomates perfección amarilla seco|O|O||D||1
50426500|Nabos Secos|O|O||D||1
50426501|Nabo globo verde seco|O|O||D||1
50426502|Nabo bola dorada seco|O|O||D||1
50426503|Nabo mercado de manchester seco|O|O||D||1
50426504|Nabo top morado milan seco|O|O||D||1
50426505|Nabo top morado blanco seco|O|O||D||1
50426506|Nabo bola de nieve seco|O|O||D||1
50426507|Nabo tokio seco|O|O||D||1
50426508|Nabo cruz de tokio seco|O|O||D||1
50426600|Auyamas Secas|O|O||D||1|Calabazas gigantes Secas
50426601|Calabaza acorn seca|O|O||D||1|Calabaza gigante acorn seca
50426602|Calabaza gigante atlántico seca|O|O||D||1|Calabaza gigante atlántico seca
50426603|Calabaza banana rosado seca|O|O||D||1|Calabaza gigante banana rosado seca
50426604|Calabaza max grande seca|O|O||D||1|Calabaza gigante max seca
50426605|Calabaza  seca|O|O||D||1|Calabaza de castilla seca
50426606|Calabaza carnaval seca|O|O||D||1|Calabaza gigante carnaval seca
50426607|Auyama queso seca|O|O||D||1|Calabaza gigante queso seca
50426608|Calabaza príncipe coronado seca|O|O||D||1|Calabaza gigante príncipe coronado seca
50426609|Calabaza  curcibita seca|O|O||D||1|Calabaza gigante curcibita seca
50426610|Calabaza cushaw seca|O|O||D||1|Calabaza gigante cushaw seca
50426611|Calabaza  gigante auyama seca|O|O||D||1
50426612|Calabaza  hubbard seca|O|O||D||1|Calabaza gigante hubbard seca
50426613|Calabaza  jerrahdale seca|O|O||D||1|Calabaza gigante jerrahdale seca
50426614|Calabaza  kabocha seca|O|O||D||1|Calabaza gigante kabocha seca
50426615|Calabaza queensland azul seca|O|O||D||1|Calabaza gigante queensland azul seca
50426616|Calabaza rouge vif détampes seca|O|O||D||1|Calabaza gigante rouge vif détampes seca
50426617|Calabaza  turban turco seca|O|O||D||1|Calabaza gigante turban turco seca
50426618|Calabaza  valenciano seca|O|O||D||1|Calabaza gigante valenciano seca
50426619|Calabaza  warted hubbard seca|O|O||D||1|Calabaza gigante warted hubbard seca
50426620|Auyama whangaparoa seca|O|O||D||1|Calabaza gigante whangaparoa seca
50426700|Ñames Secos|O|O||D||1
50426701|Ñame agria africana seca|O|O||D||1
50426702|Ñame agria asiática seca|O|O||D||1
50426703|Ñame china seco|O|O||D||1
50426704|Ñame globo seco|O|O||D||1
50426705|Ñame grater seco|O|O||D||1
50426706|Ñame japonesa seco|O|O||D||1
50426707|Ñame lesser seco|O|O||D||1
50426708|Ñame papa seco|O|O||D||1
50426709|Ñame guinea blanca seco|O|O||D||1
50426710|Ñame guinea amarillo seco|O|O||D||1
50426800|Vegetales Nominant Secos|O|O||D||1|Vegetales predominantes secos, Nopal seco
50426801|Alfalfa seca|O|O||D||1
50426802|Hojas de aloe seca|O|O||D||1|Hoja de sábila seca, Penca de sábila seca
50426803|Apio seco|O|O||D||1
50426804|Arrurruz seca|O|O||D||1
50426805|Punta de flecha seca|O|O||D||1|Sagittaria seca
50426806|rúcula seca|O|O||D||1
50426807|Arum seca|O|O||D||1|Taro seco
50426808|Raíz de bambú seca|O|O||D||1
50426809|Hojas de plátano seca|O|O||D||1
50426810|Batatas seca|O|O||D||1
50426811|Brotes de frijol secos|O|O||D||1
50426812|Top de remolacha seca|O|O||D||1|Betabel seco
50426813|Melón agrio seco|O|O||D||1|Balsamina seca
50426814|Bayas de alcaparra secas|O|O||D||1
50426815|Carob seco|O|O||D||1|Algarrobo seco
50426816|Cha-om seco|O|O||D||1
50426817|Chayote o guatila seco|O|O||D||1
50426818|Garbanzo seco|O|O||D||1
50426819|Verde de crisantemos seco|O|O||D||1
50426820|Verde de diente de león seco|O|O||D||1
50426821|Diente de león seco|O|O||D||1
50426822|Dasheen seco|O|O||D||1
50426823|Puntas de alverja seco|O|O||D||1
50426824|Diakon seco|O|O||D||1|Rábano seco
50426825|Donqua seca|O|O||D||1|Ginseng hembra seca
50426826|Helecho seco|O|O||D||1|Brotes de helecho seco
50426827|Gai choi seco|O|O||D||1|Mostaza castaña seca
50426828|Gailon seco|O|O||D||1|Brécol chino seco
50426829|Galanga seca|O|O||D||1|Jengibre azul seco
50426830|Raíz de jengibre seca|O|O||D||1
50426831|Gobo seco|O|O||D||1|Garduña seca
50426832|Brote de lúpulo seco|O|O||D||1
50426833|Rabano blanco seco|O|O||D||1|Rábano de caballo seco
50426834|Jicama seca|O|O||D||1
50426835|Kuduz seca|O|O||D||1|Kudzu seco
50426836|Bulbo de margarita seco|O|O||D||1|Bulbo de lili chino seco
50426837|Linkok seco|O|O||D||1
50426838|Lo bok seco|O|O||D||1
50426839|Frijol largo seco|O|O||D||1|Fríjol serpiente seco
50426840|Raíz de lotus seco|O|O||D||1|Rosa del Nilo seca
50426841|Hojas de maguey seca|O|O||D||1|Hoja de agave seca, Penca de maguey seca
50426842|Mallows seco|O|O||D||1|Malva seca
50426843|Sapote mamey seco|O|O||D||1|Mamey seco
50426844|Moap seco|O|O||D||1
50426845|Moo seco|O|O||D||1
50426846|Moqua seca|O|O||D||1
50426847|Opos secos|O|O||D||1
50426848|Corazon de palma seco|O|O||D||1|Palmito seco
50426849|Paprika seca|O|O||D||1
50426850|Purslane seca|O|O||D||1|Verdolaga seca
50426851|Raddichios seca|O|O||D||1|Achicoria morada seca
50426852|Sinquas seca|O|O||D||1|Zapallo seco
50426853|Frijol de soya secos|O|O||D||1
50426854|Spoonwart seco|O|O||D||1|Hierba del escorbuto seca
50426855|Uva tassele hyacinth seco|O|O||D||1
50426856|Taro seco|O|O||D||1|Tales seca
50426857|Hoja de taro seca|O|O||D||1
50426858|Tallo de taro seco|O|O||D||1
50426859|Tapeguaje seco|O|O||D||1
50426860|Verde tierno seco|O|O||D||1
50426861|Tindora seco|O|O||D||1
50426862|Árbol de cebolla seco|O|O||D||1|Cebollas egipcias seca
50426863|Udo seco|O|O||D||1
50426864|Agua castaño seco|O|O||D||1|Castaña de agua china seca
50426865|Yumpi seco|O|O||D||1|Akankong seco
50426866|Yautia seco|O|O||D||1|Mapuey seco
50426867|Yu choy seco|O|O||D||1
50426868|Yuca seca|O|O||D||1
50426900|Alverjas dulces Secas|O|O||D||1|Chícharos secos
50426901|Alverja biquini seca|O|O||D||1|Chícharo biquini seco
50426902|Alverja cavalier seca|O|O||D||1|Chícharo cavalier seco
50426903|Alverja margarita seca|O|O||D||1|Chícharo margarita seco
50426904|Alverja dar fon seca|O|O||D||1|Chícharo dar fon seco
50426905|Alverja "early onward" seca|O|O||D||1|Chícharo "early onward" seco
50426906|Alverja primer feltham seca|O|O||D||1|Chícharo primer feltham seco
50426907|Alverja verde hurst shaft seca|O|O||D||1|Chícharo verde hurst shaft seco
50426908|Guisante oregón sugar pod seca|O|O||D||1|Chícharo oregón sugar pod seco
50426909|Alverja príncipe alberto seca|O|O||D||1|Chícharo príncipe alberto seco
50426910|Alverja reuzensuiker seca|O|O||D||1|Chícharo reuzensuiker seco
50431500|Alcachofas orgánicas secas|O|O||D||1
50431501|Alcachofa brittany orgánica seca|O|O||D||1
50431502|Alcachofa cantonesa orgánica seca|O|O||D||1
50431503|Alcachofa francesa orgánica seca|O|O||D||1
50431504|Alcachofa globo verde orgánica seca|O|O||D||1
50431505|Alcachofa gros camus de bretaña orgánica seca|O|O||D||1
50431506|Alcachofa midi orgánica seca|O|O||D||1
50431507|Alcachofa globo morado orgánica seca|O|O||D||1
50431508|Alcachofa morado cecilia orgánica seca|O|O||D||1
50431509|Alcachofa romanesco orgánica seca|O|O||D||1
50431510|Alcachofa espinoso sardo orgánica seca|O|O||D||1
50431511|Alcachofa vert de laon orgánica seca|O|O||D||1
50431512|Alcachofa violeta de chiggiia orgánica seca|O|O||D||1
50431513|Alcachofa violeta de toscana orgánica seca|O|O||D||1
50431600|Espárragos orgánicos secos|O|O||D||1
50431601|Espárragos connovers colosal orgánicos secos|O|O||D||1
50431602|Espárragos franklin orgánicos secos|O|O||D||1
50431603|Espárragos mamut gigante orgánicos secos|O|O||D||1
50431604|Espárragos lucullus orgánicos secos|O|O||D||1
50431605|Espárragos martha washington orgánicos secos|O|O||D||1
50431700|Aguacates orgánicos secos|O|O||D||1
50431701|Aguacate ajax b – 7 orgánico seco|O|O||D||1
50431702|Aguacate arue orgánico seco|O|O||D||1
50431703|Aguacate bacon orgánico seco|O|O||D||1
50431704|Aguacate benik orgánico seco|O|O||D||1
50431705|Aguacate bernecker orgánico seco|O|O||D||1
50431706|Aguacate beta orgánico seco|O|O||D||1
50431707|Aguacate biondo orgánico seco|O|O||D||1
50431708|Aguacate príncipe negro orgánico seco|O|O||D||1
50431709|Aguacate blair orgánico seco|O|O||D||1
50431710|Aguacate blair cabina orgánico seco|O|O||D||1
50431711|Aguacate cabina 1 orgánico seco|O|O||D||1
50431712|Aguacate cabina 3 orgánico seco|O|O||D||1
50431713|Aguacate cabina 5 orgánico seco|O|O||D||1
50431714|Aguacate cabina 7 orgánico seco|O|O||D||1
50431715|Aguacate cabina 8 orgánico seco|O|O||D||1
50431716|Aguacate brooks 1978 orgánico seco|O|O||D||1
50431717|Aguacate brookslate orgánico seco|O|O||D||1
50431718|Aguacate california haas orgánico seco|O|O||D||1
50431719|Aguacate catalina orgánico seco|O|O||D||1
50431720|Aguacate chica orgánico seco|O|O||D||1
50431721|Aguacate choquette orgánico seco|O|O||D||1
50431722|Aguacate cristina orgánico seco|O|O||D||1
50431723|Aguacate collison orgánico seco|O|O||D||1
50431724|Aguacate donnie orgánico seco|O|O||D||1
50431725|Aguacate dr dupis numero 2 orgánico seco|O|O||D||1
50431726|Aguacate dr. dupie  orgánico seco|O|O||D||1
50431727|Aguacate ettinger orgánico seco|O|O||D||1
50431728|Aguacate fuch orgánico seco|O|O||D||1
50431729|Aguacate fuch gwen orgánico seco|O|O||D||1
50431730|Aguacate fuerte orgánico seco|O|O||D||1
50431731|Aguacate gotham orgánico seco|O|O||D||1
50431732|Aguacate gossman orgánico seco|O|O||D||1
50431733|Aguacate guatemala sin pepa orgánico seco|O|O||D||1
50431734|Aguacate hall orgánico seco|O|O||D||1
50431735|Aguacate hardee orgánico seco|O|O||D||1
50431736|Aguacate haas orgánico seco|O|O||D||1
50431737|Aguacate herman orgánico seco|O|O||D||1
50431738|Aguacate hickson orgánico seco|O|O||D||1
50431739|Aguacate k-5 orgánico seco|O|O||D||1
50431740|Aguacate k- 9 orgánico seco|O|O||D||1
50431741|Aguacate cordero haas orgánico seco|O|O||D||1
50431742|Aguacate leona orgánico seco|O|O||D||1
50431743|Aguacate leona linda orgánico seco|O|O||D||1
50431744|Aguacate lisa p orgánico seco|O|O||D||1
50431745|Aguacate lisa loretta orgánico seco|O|O||D||1
50431746|Aguacate loretta orgánico seco|O|O||D||1
50431747|Aguacate lula orgánico seco|O|O||D||1
50431748|Aguacate lula mascarthur orgánico seco|O|O||D||1
50431749|Aguacate marcus orgánico seco|O|O||D||1
50431750|Aguacate melendez orgánico seco|O|O||D||1
50431751|Aguacate meya orgánico seco|O|O||D||1
50431752|Aguacate miguel p orgánico seco|O|O||D||1
50431753|Aguacate monroe orgánico seco|O|O||D||1
50431754|Aguacate murrieta verde orgánico seco|O|O||D||1
50431755|Aguacate nabal orgánico seco|O|O||D||1
50431756|Aguacate nadir orgánico seco|O|O||D||1
50431757|Aguacate nesbitt orgánico seco|O|O||D||1
50431758|Aguacate peterson orgánico seco|O|O||D||1
50431759|Aguacate pinelli orgánico seco|O|O||D||1
50431760|Aguacate pinkerton orgánico seco|O|O||D||1
50431761|Aguacate pollock orgánico seco|O|O||D||1
50431762|Aguacate puebla orgánico seco|O|O||D||1
50431763|Aguacate reed orgánico seco|O|O||D||1
50431764|Aguacaterue orgánico seco|O|O||D||1
50431765|Aguacateruehle orgánico seco|O|O||D||1
50431766|Aguacate ryan orgánico seco|O|O||D||1
50431767|Aguacate semil orgánico seco|O|O||D||1
50431768|Aguacate semil 43 orgánico seco|O|O||D||1
50431769|Aguacate simonds orgánico seco|O|O||D||1
50431770|Aguacate simpson orgánico seco|O|O||D||1
50431771|Aguacate taylor orgánico seco|O|O||D||1
50431772|Aguacate tonelada orgánico seco|O|O||D||1
50431773|Aguacate torre orgánico seco|O|O||D||1
50431774|Aguacate torre li orgánico seco|O|O||D||1
50431775|Aguacate trapp orgánico seco|O|O||D||1
50431776|Aguacate semilla de caribe orgánico seco|O|O||D||1
50431777|Aguacate wagner orgánico seco|O|O||D||1
50431778|Aguacate waldin orgánico seco|O|O||D||1
50431779|Aguacate wurtz orgánico seco|O|O||D||1
50431780|Aguacate zio p orgánico seco|O|O||D||1
50431781|Aguacate ziu orgánico seco|O|O||D||1
50431782|Aguacate zultano orgánico seco|O|O||D||1
50431800|Fríjoles orgánicos secos|O|O||D||1
50431801|Frijoles anasazi ® orgánicos secos|O|O||D||1
50431802|Frijoles appaloosa orgánicos secos|O|O||D||1
50431803|Frijoles azuki orgánicos secos|O|O||D||1
50431804|Frijoles barlotti orgánicos secos|O|O||D||1
50431805|Frijoles appaloosa negra orgánicos secos|O|O||D||1
50431806|Frijoles negros orgánicos secos|O|O||D||1
50431807|Frijoles gran negros orgánicos secos|O|O||D||1
50431808|Frijoles shackamaxon negro orgánicos secos|O|O||D||1
50431809|Frijoles ojo negro orgánicos secos|O|O||D||1
50431810|Frijoles bobby orgánicos secos|O|O||D||1
50431811|Frijoles bolita orgánicos secos|O|O||D||1
50431812|Frijoles esposa perezosa carmelita orgánicos secos|O|O||D||1
50431813|Frijoles calipso orgánicos secos|O|O||D||1
50431814|Frijoles canelini orgánicos secos|O|O||D||1
50431815|Frijoles castor orgánicos secos|O|O||D||1
50431816|Frijoles amarillo chino orgánicos secos|O|O||D||1
50431817|Frijoles lengua de dragón orgánicos secos|O|O||D||1
50431818|Frijoles soldado europeo orgánicos secos|O|O||D||1
50431819|Frijoles fava orgánicos secos|O|O||D||1
50431820|Frijoles flageolet orgánicos secos|O|O||D||1
50431821|Frijoles  horticultura francesa orgánicos secos|O|O||D||1
50431822|Frijoles marina francesa orgánicos secos|O|O||D||1
50431823|Frijoles coco gigante blanco orgánicos secos|O|O||D||1
50431824|Frijoles verdes orgánicos secos|O|O||D||1
50431825|Frijoles romano verde orgánicos secos|O|O||D||1
50431826|Frijoles guar gum orgánicos secos|O|O||D||1
50431827|Frijoles haricot orgánicos secos|O|O||D||1
50431828|Frijoles hyacinth orgánicos secos|O|O||D||1
50431829|Frijoles tipo italiano orgánicos secos|O|O||D||1
50431830|Frijoles asombro jackson orgánicos secos|O|O||D||1
50431831|Frijoles ganado jacobs  orgánicos secos|O|O||D||1
50431832|Frijoles asombro kentucky orgánicos secos|O|O||D||1
50431833|Frijoles riñón orgánicos secos|O|O||D||1
50431834|Frijoles lima orgánicos secos|O|O||D||1
50431835|Frijoles madera orgánicos secos|O|O||D||1
50431836|Frijoles medula orgánicos secos|O|O||D||1
50431837|Frijoles mat orgánicos secos|O|O||D||1
50431838|Frijoles monstoler ganzo salvaje orgánicos secos|O|O||D||1
50431839|Frijoles  mortgage lifter orgánicos secos|O|O||D||1
50431840|Frijoles polilla orgánicos secos|O|O||D||1
50431841|Frijoles mung orgánicos secos|O|O||D||1
50431842|Frijoles munsi wolf orgánicos secos|O|O||D||1
50431843|Frijoles nuna orgánicos secos|O|O||D||1
50431844|Frijoles pinto orgánicos secos|O|O||D||1
50431845|Frijoles runner orgánicos secos|O|O||D||1
50431846|String beans orgánicos secos|O|O||D||1|Ayecote orgánico seco, Fríjol gordo orgánico seco
50431847|Frijoles habichuelas orgánicos secos|O|O||D||1|Ejote orgánico seco, Fríjol tierno orgánico seco
50431848|Frijoles tamarind orgánicos secos|O|O||D||1
50431849|Frijoles tonka orgánicos secos|O|O||D||1
50431850|Frijoles cera orgánicos secos|O|O||D||1
50431851|Frijoles winged orgánicos secos|O|O||D||1
50431852|Frijoles largos orgánicos secos|O|O||D||1
50431900|Remolachas  orgánicas secas|O|O||D||1|Betabeles orgánicos secos
50431901|Remolacha acción orgánica seca|O|O||D||1|Betabel acción orgánico seco
50431902|Remolacha albina vereduna orgánica seca|O|O||D||1|Betabel albina vereduna orgánico seco
50431903|Remolacha barababiotela de chiggia orgánica seca|O|O||D||1|Betabel barababiotela de chiggia orgánico seco
50431904|Remolacha boltardy orgánica seca|O|O||D||1|Betabel boltardy orgánico seco
50431905|Remolacha bonel orgánica seca|O|O||D||1|Betabel bonel orgánico seco
50431906|Remolacha burpees dorado orgánica seca|O|O||D||1|Betabel burpees dorado orgánico seco
50431907|Remolacha cheltenham tapa verde orgánica seca|O|O||D||1|Betabel cheltenham tapa verde orgánico seco
50431908|Remolacha cheltenham mono orgánica seca|O|O||D||1|Betabel cheltenham mono orgánico seco
50431909|Remolacha chioggia orgánica seca|O|O||D||1|Betabel chioggia orgánico seco
50431910|Remolacha cilindra orgánica seca|O|O||D||1|Betabel cilindra orgánico seco
50431911|Remolacha dégypte orgánica seca|O|O||D||1|Betabel dégypte orgánico seco
50431912|Remolacha detroit 2 rojo oscuro orgánica seca|O|O||D||1|Betabel detroit 2 rojo oscuro orgánico seco
50431913|Remolacha detroit 2 bala chiquita orgánica seca|O|O||D||1|Betabel detroit 2 bala chiquita orgánico seco
50431914|Remolacha egipcia plana  orgánica seca|O|O||D||1|Betabel egipcia plana orgánico seco
50431915|Remolacha  raíz de nabo egipcio orgánica seca|O|O||D||1|Betabel raíz de nabo egipcio orgánico seco
50431916|Remolacha fomanova orgánica seca|O|O||D||1|Betabel fomanova orgánico seco
50431917|Remolacha forono orgánica seca|O|O||D||1|Betabel forono orgánico seco
50431918|Remolacha monaco orgánica seca|O|O||D||1|Betabel mónaco orgánico seco
50431919|Remolacha monograma orgánica seca|O|O||D||1|Betabel monograma orgánico seco
50431920|Remolacha pronto orgánica seca|O|O||D||1|Betabel pronto orgánico seco
50431921|Remolacha regalía orgánica seca|O|O||D||1|Betabel regalía orgánico seco
50431922|Remolacha dulce orgánica seca|O|O||D||1|Betabel dulce orgánico seco
50432000|Brócolis  orgánicas secas|O|O||D||1
50432001|Brócolini orgánico seco|O|O||D||1
50432002|Brócoli romanesco orgánico seco|O|O||D||1
50432003|Brócoli raab orgánico seco|O|O||D||1
50432004|Brócoli chino orgánico seco|O|O||D||1
50432100|Repollitos de Bruselas  orgánicas secas|O|O||D||1|Coles de Bruselas orgánicas secas
50432101|Repollitas de bruselas citade orgánicas secas|O|O||D||1|Coles de Bruselas citade orgánicas secas
50432102|Repollitas de bruselas falstaff orgánicas secas|O|O||D||1|Coles de Bruselas falstaff orgánicas secas
50432103|Repollitas de bruselas oliver orgánicas secas|O|O||D||1|Coles de Bruselas oliver orgánicas secas
50432104|Repollitas de bruselas peer gynt orgánicas secas|O|O||D||1|Coles de Bruselas peer gynt orgánicas secas
50432105|Repollitas de bruselas rampart orgánicas secas|O|O||D||1|Coles de Bruselas rampart orgánicas secas
50432106|Repollitas de bruselas rubine orgánicas secas|O|O||D||1|Coles de Bruselas rubine orgánicas secas
50432107|Repollitas de bruselas  widgeon orgánicas secas|O|O||D||1|Coles de Bruselas widgeon orgánicas secas
50432200|Cebollas de ensalada  orgánicas secas|O|O||D||1|Cebollas de cambray  orgánicas secas
50432201|Cebolla belstville ensalada orgánica seca|O|O||D||1|Cebolla de cambray belstville orgánica seca
50432202|Cebolla feast ensalada orgánica seca|O|O||D||1|Cebolla de cambray feast orgánica seca
50432203|Cebolla ishikura ensalada orgánica seca|O|O||D||1|Cebolla de cambray ishikura orgánica seca
50432204|Cebolla mercado kyoto orgánica seca|O|O||D||1|Cebolla de cambray mercado kyoto orgánica seca
50432205|Cebolla barba roja ensalada orgánica seca|O|O||D||1|Cebolla de cambray barba roja orgánica seca
50432206|Cebolla amigo rojo ensalada orgánica seca|O|O||D||1|Cebolla de cambray amigo rojo orgánica seca
50432207|Cebolla santa claus orgánica seca|O|O||D||1|Cebolla de cambray santa claus orgánica seca
50432208|Cebolla tokyo ensalada orgánica seca|O|O||D||1|Cebolla de cambray tokyo orgánica seca
50432209|Cebolla lisbon blanca ensalada orgánica seca|O|O||D||1|Cebolla de cambray lisbon blanca orgánica seca
50432210|Cebolla invierno blanca ensalada orgánica seca|O|O||D||1|Cebolla de cambray invierno blanca orgánica seca
50432211|Cebolla final de invierno ensalada orgánica seca|O|O||D||1|Cebolla de cambray final de invierno orgánica seca
50432300|Repollos orgánicos secos|O|O||D||1|Coles orgánicas secas
50432301|Repollo negro orgánico seco|O|O||D||1|Col negro orgánica seca
50432302|Repollo savoy orgánico seco|O|O||D||1|Col savoy orgánica seca
50432303|Repollo zorrillo orgánico seco|O|O||D||1|Col zorrillo orgánica seca
50432304|Repollo blanco orgánico seco|O|O||D||1|Col blanco orgánica seca
50432400|Cardos orgánicos secos|O|O||D||1|Cardos comestibles orgánicos secos
50432401|Cardos lunghi orgánicos secos|O|O||D||1|Cardo comestible lunghi orgánicos secos
50432402|Cardos gobbi orgánicos secos|O|O||D||1|Cardo comestible gobbi orgánicos secos
50432500|Zanahorias  orgánicas secas|O|O||D||1
50432501|Zanahoria amsterdam orgánica seca|O|O||D||1
50432502|Zanahoria rey de otoño orgánica seca|O|O||D||1
50432503|Zanahoria berlicum orgánica seca|O|O||D||1
50432504|Zanahoria chantenay orgánica seca|O|O||D||1
50432505|Zanahoria nantes orgánica seca|O|O||D||1
50432506|Zanahoria mercado de parís orgánica seca|O|O||D||1
50432600|Coliflores  orgánicas secas|O|O||D||1
50432601|Coliflor todo el año  orgánica seca|O|O||D||1
50432602|Coliflor alverda orgánica seca|O|O||D||1
50432603|coliflor otoño gigante 3 orgánica seca|O|O||D||1
50432604|Coliflo rdok elgon orgánica seca|O|O||D||1
50432605|Coliflor bola de nieve temprana orgánica seca|O|O||D||1
50432606|Coliflor luz de lima orgánica seca|O|O||D||1
50432607|Coliflor minaret orgánica seca|O|O||D||1
50432608|Coliflor buque de naranja orgánica seca|O|O||D||1
50432609|Coliflor capa morada orgánica seca|O|O||D||1
50432610|Coliflor bola de nieve orgánica seca|O|O||D||1
50432611|Coliflor invierno walcheren 3 orgánica seca|O|O||D||1
50432612|Coliflor piedra blanca orgánica seca|O|O||D||1
50432700|Apios orgánicos secos|O|O||D||1
50432701|Apio celebridad orgánico seco|O|O||D||1
50432702|Apio nabo orgánico seco|O|O||D||1
50432703|Apio chino orgánico seco|O|O||D||1
50432704|Apio dinant francés orgánico seco|O|O||D||1
50432705|Apio gigante rosado orgánico seco|O|O||D||1
50432706|Apio gigante rojo orgánico seco|O|O||D||1
50432707|Apio gigante blanco orgánico seco|O|O||D||1
50432708|Apio dorado auto escalado orgánico seco|O|O||D||1
50432709|Apio "greensleeves" orgánico seco|O|O||D||1
50432710|Apio hopkins fenlander orgánico seco|O|O||D||1
50432711|Apio torre marfil orgánico seco|O|O||D||1
50432712|Apio lathom blanqueado orgánico seco|O|O||D||1
50432713|Apio sopa de amsterdam orgánico seco|O|O||D||1
50432714|Apio estándar cargado orgánico seco|O|O||D||1
50432715|Apio triunfo alto utah orgánico seco|O|O||D||1
50432800|Acelgas  orgánicas secas|O|O||D||1
50432801|Acelga luz brillante orgánica seca|O|O||D||1
50432802|Acelga gigante fordhook orgánica seca|O|O||D||1
50432803|Acelga luculus orgánica seca|O|O||D||1
50432804|Acelga espinaca perpetua orgánica seca|O|O||D||1
50432805|Acelga ruibarbo orgánica seca|O|O||D||1
50432806|Acelga suizo orgánica seca|O|O||D||1
50432807|Acelga volcán  orgánica seca|O|O||D||1
50432808|Acelga rey blanco orgánica seca|O|O||D||1
50432900|Achicorias orgánicas secas|O|O||D||1|Escarolas orgánicas secas
50432901|Achicoria batavian hoja ancha orgánica seca|O|O||D||1|Escarola batavian hoja ancha orgánica seca
50432902|Achicoria en cornet de bordeaux orgánica seca|O|O||D||1|Escarola en cornet de bordeaux orgánica seca
50432903|Achicoria rollo verde ruffee orgánica seca|O|O||D||1|Escarola rollo verde ruffee orgánica seca
50432904|Achicoria roll verde orgánica seca|O|O||D||1|Escarola roll verde orgánica seca
50432905|Achicoria limnoe lone orgánica seca|O|O||D||1|Escarola limnoe lone orgánica seca
50432906|Achicoria pancalieri riccia orgánica seca|O|O||D||1|Escarola pancalieri riccia orgánica seca
50432907|Achicoria ensalada rey orgánica seca|O|O||D||1|Escarola ensalada rey orgánica seca
50432908|Achicoria sanda orgánica seca|O|O||D||1|Escarola sanda orgánica seca
50432909|Achicoria scarola verde orgánica seca|O|O||D||1|Escarola scarola verde orgánica seca
50432910|Achicoria tres fine maraichere orgánica seca|O|O||D||1|Escarola tres fine maraichere orgánica seca
50432911|Achicoria wallone freisee wescelkkopf orgánica seca|O|O||D||1|Escarola wallone freisee wescelkkopf orgánica seca
50433000|Repollos chinos orgánicos secos|O|O||D||1|Coles chinas orgánicas secas
50433001|Bok choy orgánico seco|O|O||D||1
50433002|Bok choy enano orgánico seco|O|O||D||1
50433003|Flor de repollo chino orgánica seca|O|O||D||1|Flor de col china orgánica seca
50433004|Choy sum orgánico seco|O|O||D||1
50433005|Col (bok choy) enano orgánico seco|O|O||D||1
50433006|Col (bok choy) fengshan orgánico seco|O|O||D||1
50433007|Col (bok choy) jade pagoda orgánico seco|O|O||D||1
50433008|Col (bok choy) kasumi orgánico seco|O|O||D||1
50433009|col (bok choy)  nerva orgánico seco|O|O||D||1
50433010|Col (bok choy) rosette orgánico seco|O|O||D||1
50433011|Col (bok choy) ruffles orgánico seco|O|O||D||1
50433012|Col (bok choy) hoja  santo serrated orgánico seco|O|O||D||1
50433013|Col (bok choy) shangahai orgánico seco|O|O||D||1
50433014|Shantung orgánico seco|O|O||D||1
50433015|Repollo tip top orgánico seco|O|O||D||1|Col china tip top orgánico seco
50433016|Yau choy sum orgánico seco|O|O||D||1
50433100|Cebollines orgánicos secos|O|O||D||1
50433101|Cebollín chino orgánico seco|O|O||D||1
50433200|Maíces orgánicos secos|O|O||D||1
50433201|Maíz aloha orgánico seco|O|O||D||1
50433202|Maíz alpine orgánico seco|O|O||D||1
50433203|Maíz ambrosia orgánico seco|O|O||D||1
50433204|Maíz argent orgánico seco|O|O||D||1
50433205|Maíz aspen orgánico seco|O|O||D||1
50433206|Maíz avalancha orgánico seco|O|O||D||1
50433207|Maíz biqueen orgánico seco|O|O||D||1
50433208|Maíz  bodacious orgánico seco|O|O||D||1
50433209|Maíz  mantequilla y azúcar orgánico seco|O|O||D||1
50433210|Maíz  calico belle orgánico seco|O|O||D||1
50433211|Maíz  camelot orgánico seco|O|O||D||1
50433212|Maíz  challengercrisp ‘n dulce orgánico seco|O|O||D||1
50433213|Maíz  campeón orgánico seco|O|O||D||1
50433214|Maíz  algodón de azúcar orgánico seco|O|O||D||1
50433215|Maíz  dártagnan orgánico seco|O|O||D||1
50433216|Maíz  dazzle orgánico seco|O|O||D||1
50433217|Maíz  diamante y oro orgánico seco|O|O||D||1
50433218|Maíz  divinidad orgánico seco|O|O||D||1
50433219|Maíz  delicia doble orgánico seco|O|O||D||1
50433220|Maíz  gema doble orgánico seco|O|O||D||1
50433221|Maíz  earlivee orgánico seco|O|O||D||1
50433222|Maíz  temprano extra dulce orgánico seco|O|O||D||1
50433223|Maíz excel orgánico seco|O|O||D||1
50433224|Maíz  cruz dorada bantam orgánico seco|O|O||D||1
50433225|Maíz  miel y crema orgánico seco|O|O||D||1
50433226|Maíz  miel y perla orgánico seco|O|O||D||1
50433227|Maíz  miel dulce orgánico seco|O|O||D||1
50433228|Maíz  hudson orgánico seco|O|O||D||1
50433229|Maíz  dorado illini orgánico seco|O|O||D||1
50433230|Maíz  illini extra dulce orgánico seco|O|O||D||1
50433231|Maíz  increíble orgánico seco|O|O||D||1
50433232|Maíz  lochief orgánico seco|O|O||D||1
50433233|Maíz jubileo orgánico seco|O|O||D||1
50433234|Maíz jupbileo super dulce orgánico seco|O|O||D||1
50433235|Maíz  confite korn orgánico seco|O|O||D||1
50433236|Maíz  beso y acuso orgánico seco|O|O||D||1
50433237|Maíz  lancelot orgánico seco|O|O||D||1
50433238|Maíz dulce maple orgánico seco|O|O||D||1
50433239|Maíz  medley orgánico seco|O|O||D||1
50433240|Maíz merlin orgánico seco|O|O||D||1
50433241|Maíz milagro orgánico seco|O|O||D||1
50433242|Maíz nk – 199 orgánico seco|O|O||D||1
50433243|Maíz durazno y crema orgánico seco|O|O||D||1
50433244|Maíz blanco perla orgánico seco|O|O||D||1
50433245|Maíz  pegasus orgánico seco|O|O||D||1
50433246|Maíz  fenomenal orgánico seco|O|O||D||1
50433247|Maíz  dama de platino orgánico seco|O|O||D||1
50433248|Maíz  precioso orgánico seco|O|O||D||1
50433249|Maíz   pristine orgánico seco|O|O||D||1
50433250|Maíz  rápido orgánico seco|O|O||D||1
50433251|Maíz  radiante orgánico seco|O|O||D||1
50433252|Maíz  seneca brave orgánico seco|O|O||D||1
50433253|Maíz  amanecer seneca orgánico seco|O|O||D||1
50433254|Maíz  horizonte seneca orgánico seco|O|O||D||1
50433255|Maíz  brillo de estrella seneca orgánico seco|O|O||D||1
50433256|Maíz  noche blanca seneca orgánico seco|O|O||D||1
50433257|Maíz  showcase orgánico seco|O|O||D||1
50433258|Maíz  reina plateada orgánico seco|O|O||D||1
50433259|Maíz  bella nieve orgánico seco|O|O||D||1
50433260|Maíz nieve de primavera orgánico seco|O|O||D||1
50433261|Maíz  premio de primavera orgánico seco|O|O||D||1
50433262|Maíz  azúcar y oro orgánico seco|O|O||D||1
50433263|Maíz rollo de azúcar orgánico seco|O|O||D||1
50433264|Maíz nieve de azúcar orgánico seco|O|O||D||1
50433265|Maíz baile de sol orgánico seco|O|O||D||1
50433266|Maíz estrella tell orgánico seco|O|O||D||1
50433267|Maíz terminador orgánico seco|O|O||D||1
50433268|Maíz tesoro orgánico seco|O|O||D||1
50433269|Maíz tuxedo orgánico seco|O|O||D||1
50433300|Berros  orgánicos secos|O|O||D||1
50433301|Berros de tierra orgánicos secos|O|O||D||1
50433302|Nasturtium orgánico seco|O|O||D||1
50433303|Berros de agua orgánicos secos|O|O||D||1
50433304|Berros de invierno orgánicos secos|O|O||D||1
50433400|Cocombros orgánicos secos|O|O||D||1|Pepinos cohombro orgánicos secos
50433401|Cocombro arena orgánico seco|O|O||D||1|Pepino cohombro arena orgánico seco
50433402|Cocombro americano orgánico seco|O|O||D||1|Pepino cohombro americano orgánico seco
50433403|Cocombro atena orgánico seco|O|O||D||1|Pepino cohombro atena orgánico seco
50433404|Cocombro blanco lungo de parigi orgánico seco|O|O||D||1|Pepino cohombro blanco lungo de parigi orgánico seco
50433405|Cocombro verde burpless buen sabor orgánico seco|O|O||D||1|Pepino cohombro verde burpless buen sabor orgánico seco
50433406|Cocombro chicago pickling orgánico seco|O|O||D||1|Pepino cohombro chicago pickling orgánico seco
50433407|Cocombro manzana cristal orgánico seco|O|O||D||1|Pepino cohombro manzana cristal orgánico seco
50433408|Cocombro limón cristal orgánico seco|O|O||D||1|Pepino cohombro limón cristal orgánico seco
50433409|Cocombro danimas orgánico seco|O|O||D||1|Pepino cohombro danimas orgánico seco
50433410|Cocombro gherkin orgánico seco|O|O||D||1|Pepino cohombro gherkin orgánico seco
50433411|Cocombro hokus orgánico seco|O|O||D||1|Pepino cohombro hokus orgánico seco
50433412|Cocombro japonés orgánico seco|O|O||D||1|Pepino cohombro japonés orgánico seco
50433413|Cocombro karela orgánico seco|O|O||D||1|Pepino cohombro karela orgánico seco
50433414|Cocombro korila orgánico seco|O|O||D||1|Pepino cohombro korila orgánico seco
50433415|Cocombro verde largo mejorado orgánico seco|O|O||D||1|Pepino cohombro verde largo mejorado orgánico seco
50433416|Cocombro mas mercado orgánico seco|O|O||D||1|Pepino cohombro mas mercado orgánico seco
50433417|Cocombro enano orgánico seco|O|O||D||1|Pepino cohombro enano orgánico seco
50433418|Cocombro pickling nacional orgánico seco|O|O||D||1|Pepino cohombro pickling nacional orgánico seco
50433419|Cocombro persa orgánico seco|O|O||D||1|Pepino cohombro persa orgánico seco
50433420|Cocombro telégrafo orgánico seco|O|O||D||1|Pepino cohombro telégrafo orgánico seco
50433421|Cocombro telégrafo mejorado orgánico seco|O|O||D||1|Pepino cohombro telégrafo mejorado orgánico seco
50433422|Cocombro vert de massy cornichon orgánico seco|O|O||D||1|Pepino cohombro vert de massy cornichon orgánico seco
50433423|Cocombro yamato orgánico seco|O|O||D||1|Pepino cohombro yamato orgánico seco
50433500|Berenjenas orgánicas secas|O|O||D||1
50433501|Berenjena bambino orgánica seca|O|O||D||1
50433502|Berenjena  belleza negra orgánica seca|O|O||D||1
50433503|Berenjena  negra enorme orgánica seca|O|O||D||1
50433504|Berenjena  chino orgánica seca|O|O||D||1
50433505|Berenjena  huevo de pascua orgánica seca|O|O||D||1
50433506|Berenjena  filipino orgánica seca|O|O||D||1
50433507|Berenjena   mercado de florida orgánica seca|O|O||D||1
50433508|Berenjena  india orgánica seca|O|O||D||1
50433509|Berenjena  italiano orgánica seca|O|O||D||1
50433510|Berenjena  japonés orgánica seca|O|O||D||1
50433511|Berenjena  morado largo orgánica seca|O|O||D||1
50433512|Berenjena   rayas larga orgánica seca|O|O||D||1
50433513|Berenjena  mercado de dinero orgánica seca|O|O||D||1
50433514|Berenjena  ova orgánica seca|O|O||D||1
50433515|Berenjena   arveja orgánica seca|O|O||D||1
50433516|Berenjena  tom bajito orgánica seca|O|O||D||1
50433517|Berenjena  siciliano orgánica seca|O|O||D||1
50433518|Berenjena  tailandés orgánica seca|O|O||D||1
50433519|Berenjena  violeta de florencia orgánica seca|O|O||D||1
50433520|Berenjena  blanco orgánica seca|O|O||D||1
50433600|Endivias orgánicas secas|O|O||D||1
50433601|Endivias witloof de brucelas orgánicas secas|O|O||D||1
50433602|Endivias francocastel orgánicas secas|O|O||D||1
50433603|Endivias catalogna de galantina orgánicas secas|O|O||D||1
50433604|Endivias chioggia orgánicas secas|O|O||D||1
50433605|Endivias grumolo verde orgánicas secas|O|O||D||1
50433606|Endivias raíz larga magdeburg orgánicas secas|O|O||D||1
50433607|Endivias palla rosa zorzi precoce orgánicas secas|O|O||D||1
50433608|Endivias radice amare orgánicas secas|O|O||D||1
50433609|Endivias rosa de traviso orgánicas secas|O|O||D||1
50433610|Endivias  rosa de verona orgánicas secas|O|O||D||1
50433611|Endivias soncino orgánicas secas|O|O||D||1
50433612|Endivias sugarthi orgánicas secas|O|O||D||1
50433613|Endivias verona orgánicas secas|O|O||D||1
50433614|Endivias witloof zoom orgánicas secas|O|O||D||1
50433700|Hinojos orgánicos secos|O|O||D||1
50433701|Hinojo cantino orgánico seco|O|O||D||1
50433702|Hinojo fino orgánico seco|O|O||D||1
50433703|Hinojoherald orgánico seco|O|O||D||1
50433704|Hinojo perfección orgánico seco|O|O||D||1
50433705|Hinojo sirio orgánico seco|O|O||D||1
50433706|Hinojo florencia dulce orgánico seco|O|O||D||1
50433707|Hinojo tardo orgánico seco|O|O||D||1
50433800|Ajos orgánicos secos|O|O||D||1
50433801|Ajo tarde california orgánico seco|O|O||D||1
50433802|Ajo tallos chinos orgánico seco|O|O||D||1
50433803|Ajo cebollin  orgánico seco|O|O||D||1
50433804|Ajo germidor orgánico seco|O|O||D||1
50433805|Ajo guardado largo orgánico seco|O|O||D||1
50433806|Ajo ramson orgánico seco|O|O||D||1
50433807|Ajo rocambola orgánico seco|O|O||D||1
50433808|Ajo rosa de lautrec orgánico seco|O|O||D||1
50433809|Ajo solent blanco orgánico seco|O|O||D||1
50433810|Ajo morado español orgánico seco|O|O||D||1
50433811|Ajo valentina italiana orgánico seco|O|O||D||1
50433900|Calabazas orgánicas secas|O|O||D||1
50433901|Petula orgánica seca|O|O||D||1|Luffa orgánica seca
50433902|Melon amargo orgánico seco|O|O||D||1
50433903|Botella calabaza orgánica seca|O|O||D||1|Acocote orgánico seco
50433904|Calabash gounds orgánica seca|O|O||D||1|Guaje o jícaro seco
50433905|Melón peludo orgánico seco|O|O||D||1
50433906|Calabaza amarga orgánica seca|O|O||D||1
50433907|Loofah suave orgánico seco|O|O||D||1|Esponja vegetal orgánica, Zacate vegetal orgánico
50433908|Serpiente de calabaza orgánica seca|O|O||D||1|Chichinda orgánica seca
50433909|Calabaza larga amarga orgánica seca|O|O||D||1
50433910|Calabaza tinda orgánica seca|O|O||D||1
50433911|Calabaza tindoori orgánica seca|O|O||D||1
50434000|Guisantes orgánicas secas|O|O||D||1|Chícharos orgánicos secos
50434001|Guisante chino orgánica seca|O|O||D||1|Chícharo chino orgánico seco
50434002|Guisante inglés orgánica seca|O|O||D||1|Chícharo inglés orgánico seco
50434003|Guisante de jardín orgánica seca|O|O||D||1|Chícharo de jardín orgánico seco
50434004|Guisante nieve orgánica seca|O|O||D||1|Chícharo nieve orgánico seco
50434005|Guisante snap dulce orgánica seca|O|O||D||1|Chícharo snap dulce orgánico seco
50434100|Hierbas orgánicas secas|O|O||D||1|Perejil orgánico seco, Yerbabuena o hierbabuena orgánica seca
50434101|Albahaca orgánica seca|O|O||D||1
50434102|Laurel orgánico seco|O|O||D||1
50434103|Borraja orgánica seca|O|O||D||1
50434104|Alcaravea orgánica seca|O|O||D||1
50434105|Perifollo orgánico seco|O|O||D||1
50434106|Cilantro orgánico seco|O|O||D||1
50434107|Chipolinos orgánico seco|O|O||D||1
50434108|Hoja de curry orgánica seca|O|O||D||1
50434109|Eneldo orgánico seco|O|O||D||1
50434110|Epazote orgánico seco|O|O||D||1
50434111|Fenogreco orgánico seco|O|O||D||1
50434112|Limonaria orgánica seca|O|O||D||1|Té de limón orgánico seco
50434113|Mejorana orgánica seca|O|O||D||1
50434114|Menta orgánica seca|O|O||D||1
50434115|Orégano orgánico seco|O|O||D||1
50434116|Pápalo orgánico seco|O|O||D||1
50434117|Pápalo delgado orgánico seco|O|O||D||1
50434118|Perilla orgánica seca|O|O||D||1|Albahaca japonesa orgánica seca
50434119|Recao  orgánico seco|O|O||D||1
50434120|Romero orgánico seco|O|O||D||1
50434121|Salvia orgánica seca|O|O||D||1
50434122|Salsifí orgánica seca|O|O||D||1|Barba cabruna orgánica seca
50434123|Satureja orgánica seca|O|O||D||1|Ajedreas  orgánica seca
50434124|Estragón orgánico seco|O|O||D||1|Tarragón  orgánico seco
50434125|Tomillo orgánico seco|O|O||D||1
50434126|Tumeric orgánico seco|O|O||D||1|Cúrcuma orgánica seca
50434127|Verdolaga orgánica seca|O|O||D||1
50434200|Coles orgánicas secas|O|O||D||1
50434201|Col rizada orgánica seca|O|O||D||1
50434202|Repollo verde orgánico seco|O|O||D||1
50434300|Colinabos orgánicos secos|O|O||D||1|Colirrábanos orgánicos secos
50434301|Colinabo estrella azur orgánico seco|O|O||D||1|Colirrábano estrella azur orgánico seco
50434302|Colinabo verde viena orgánico seco|O|O||D||1|Colirrábano verde viena orgánico seco
50434303|Colinabo lanro orgánico seco|O|O||D||1|Colirrábano lanro orgánico seco
50434304|Colinabo viena morada orgánico seco|O|O||D||1|Colirrábano viena morada orgánico seco
50434305|Colinabo trero rowel orgánico seco|O|O||D||1|Colirrábano trero rowel orgánico seco
50434306|Colinabo viena blanca orgánico seco|O|O||D||1|Colirrábano viena blanca orgánico seco
50434400|Puerros orgánicos secos|O|O||D||1|Poros orgánicos secos
50434401|Puerro cobra gigante otoño orgánico seco|O|O||D||1|Poro cobra gigante otoño orgánico seco
50434402|Puerro otoño mamut 2 orgánico seco|O|O||D||1|Poro otoño mamut 2 orgánico seco
50434403|Puerro blue de solaise orgánico seco|O|O||D||1|Poro blue de solaise orgánico seco
50434404|Puerro cortina orgánico seco|O|O||D||1|Poro cortina orgánico seco
50434405|Puerro prelina orgánico seco|O|O||D||1|Poro prelina orgánico seco
50434406|Puerro salvaje orgánico seco|O|O||D||1|Poro salvaje orgánico seco
50434500|Lentejas  orgánicas secas|O|O||D||1
50434501|Lenteja beluga orgánica seca|O|O||D||1
50434502|Lenteja  verde francesa orgánica seca|O|O||D||1
50434503|Lenteja verde orgánica seca|O|O||D||1
50434504|Lenteja crimson pequeña orgánica seca|O|O||D||1
50434505|Lenteja pardina española orgánica seca|O|O||D||1
50434506|Lenteja roja separada orgánica seca|O|O||D||1
50434507|Lenteja amarilla separad orgánica seca|O|O||D||1
50434508|Lenteja tarahumara rosada orgánica seca|O|O||D||1
50434600|Lechugas orgánicas secas|O|O||D||1
50434601|Lechuga  bibb orgánica seca|O|O||D||1
50434602|Lechuga  boston orgánica seca|O|O||D||1
50434603|Lechuga frisee orgánica seca|O|O||D||1
50434604|Lechuga rosa lola orgánica seca|O|O||D||1
50434605|Lechuga  mixta masculina orgánica seca|O|O||D||1
50434606|Lechuga mizuna orgánica seca|O|O||D||1
50434607|Lechuga hoja roja orgánica seca|O|O||D||1
50434608|Lechuga oja roja roble orgánica seca|O|O||D||1
50434609|Lechuga romana ruby orgánica seca|O|O||D||1
50434610|Lechuga romana bebé roja orgánica seca|O|O||D||1
50434611|Lechuga cabeza de mantequilla orgánica seca|O|O||D||1
50434612|Lechuga china orgánica seca|O|O||D||1|Lechuga orejona orgánica seca
50434613|Lechuga cabeza tostada orgánica seca|O|O||D||1
50434614|Lechuga hoja verde orgánica seca|O|O||D||1
50434615|Lechuga iceberg orgánica seca|O|O||D||1
50434616|Lechuga cordero orgánica seca|O|O||D||1
50434617|Lechuga hoja suelta orgánica seca|O|O||D||1
50434618|Lechuga mache orgánica seca|O|O||D||1
50434619|Lechuga boston roja orgánica seca|O|O||D||1
50434620|Lechuga cabeza roja orgánica seca|O|O||D||1
50434621|Lechuga romana orgánica seca|O|O||D||1
50434622|Lechuga mostza roja rusa orgánica seca|O|O||D||1
50434623|Lechuga tatsoi orgánica seca|O|O||D||1
50434700|Ñames orgánicos secos|O|O||D||1
50434701|Ñame amarilla orgánica seca|O|O||D||1
50434702|Ñame blanca orgánica seca|O|O||D||1
50434703|Ñame coco orgánica seca|O|O||D||1
50434704|Ñame eddoes orgánica seca|O|O||D||1
50434705|Ñame isleña orgánica seca|O|O||D||1
50434706|Ñame lila orgánica seca|O|O||D||1
50434800|Hongos o champiñones orgánicos secos|O|O||D||1
50434801|Champiñón trompeta negra orgánico seco|O|O||D||1
50434802|Champiñón carmelito orgánico seco|O|O||D||1
50434803|Champiñón  orgánico seco|O|O||D||1
50434804|Champiñón chanterelle orgánico seco|O|O||D||1
50434805|Champiñón cremini orgánico seco|O|O||D||1
50434806|Champiñón enoki orgánico seco|O|O||D||1
50434807|Champiñón puercoespín orgánico seco|O|O||D||1
50434808|Champiñón gallina del bosque orgánico seco|O|O||D||1
50434809|Champiñón langosta orgánico seco|O|O||D||1
50434810|Champiñón morels orgánico seco|O|O||D||1
50434811|Champiñón ostra orgánico seco|O|O||D||1
50434812|Champiñón pleurotus orgánico seco|O|O||D||1
50434813|Champiñón pompom orgánico seco|O|O||D||1
50434814|Champiñón porcieni orgánico seco|O|O||D||1
50434815|Champiñón portobello orgánico seco|O|O||D||1
50434816|Champiñón shitake orgánico seco|O|O||D||1
50434817|Champiñón shimeji orgánico seco|O|O||D||1
50434818|Champiñón san jorge orgánico seco|O|O||D||1
50434819|Champiñón blanco orgánico seco|O|O||D||1
50434820|Champiñón tompeta blanca orgánico seco|O|O||D||1
50434821|Champiñón woodear orgánico seco|O|O||D||1
50434900|Mostazas orgánicas secas|O|O||D||1
50434901|Mostaza bambú  orgánica seca|O|O||D||1
50434902|Mostaza ajo orgánica seca|O|O||D||1
50434903|Mostaza hoja gigante orgánica seca|O|O||D||1
50434904|Mostaza rojo en nieve orgánica seca|O|O||D||1
50434905|Mostaza sureño orgánica seca|O|O||D||1
50434906|Mostaza corazón envuelto orgánica seca|O|O||D||1
50435000|Solanáceas (nightshades) orgánicas secas|O|O||D||1
50435001|Lámpara china orgánica seca|O|O||D||1
50435002|Mora de jardín|O|O||D||1
50435003|Naranjilla orgánicas secas|O|O||D||1
50435004|Tomatillo orgánica seca|O|O||D||1
50435100|Okras orgánicas secas|O|O||D||1
50435101|Okra artista orgánica seca|O|O||D||1
50435102|Okra vinotinto orgánica seca|O|O||D||1
50435103|Okra sin columna clemson orgánica seca|O|O||D||1
50435104|Okra verde enano vaina larga orgánica seca|O|O||D||1
50435105|Okra  mamut sin columna orgánica seca|O|O||D||1
50435106|Okra terciopelo rojo orgánica seca|O|O||D||1
50435107|Okra estrella de david reliquia orgánica seca|O|O||D||1
50435200|Cebollas orgánicas secas|O|O||D||1
50435201|Cebolla albion orgánica seca|O|O||D||1
50435202|Cebolla alisia craig orgánica seca|O|O||D||1
50435203|Cebolla hirviendo orgánica seca|O|O||D||1
50435204|Cebolla bufalo orgánica seca|O|O||D||1
50435205|Cebolla bulbo orgánica seca|O|O||D||1
50435206|Cebolla cremosa orgánica seca|O|O||D||1
50435207|Cebolla amarillo expreso o – x orgánica seca|O|O||D||1
50435208|Cebolla kelsae orgánica seca|O|O||D||1
50435209|Cebolla gigante marshal globo fen orgánica seca|O|O||D||1
50435210|Cebolla perla orgánica seca|O|O||D||1
50435211|Cebolla baron rojo orgánica seca|O|O||D||1
50435212|Cebolla roja orgánica seca|O|O||D||1|Cebolla morada orgánica seca
50435213|Cebolla rijnsberger orgánica seca|O|O||D||1
50435214|Cebolla senshyu semi – globo amarillo orgánica seca|O|O||D||1
50435215|Cebolla sturon orgánica seca|O|O||D||1
50435216|Cebolla sturgatter orgánica seca|O|O||D||1
50435217|Cebolla dulce orgánica seca|O|O||D||1
50435218|Cebolla torpedo o rojo italiana orgánica seca|O|O||D||1
50435219|Cebolla roja guardada orgánica seca|O|O||D||1
50435220|Cebolla blanca guardada orgánica seca|O|O||D||1
50435221|Cebolla amarilla guardada orgánica seca|O|O||D||1
50435300|Maníes orgánicos secos|O|O||D||1|Cacahuates orgánicos secos
50435301|Maní bambara orgánico seco|O|O||D||1|Cacahuate bambara orgánico seco
50435302|Maní florunner orgánico seco|O|O||D||1|Cacahuate florunner orgánico seco
50435303|Maní husa / kerstings orgánico seco|O|O||D||1|Cacahuate husa / kerstings  orgánico seco
50435304|Maní español orgánico seco|O|O||D||1|Cacahuate español orgánico seco
50435305|Maní valencia orgánico seco|O|O||D||1|Cacahuate valencia orgánico seco
50435306|Maní virginia orgánico seco|O|O||D||1|Cacahuate virginia orgánico seco
50435400|Alverjas orgánicas secas|O|O||D||1|Alberjones orgánicos secos
50435401|Alverja casco morado seca orgánica|O|O||D||1|Alberjón casco morado seco orgánico
50435402|Alverja pinkeye seca orgánica|O|O||D||1|Alberjón pinkeye seco orgánico
50435403|Alverja crowder seca orgánica|O|O||D||1|Alberjón crowder seco orgánico
50435404|Alverja acre blanco orgánica seca|O|O||D||1|Alberjón acre blanco orgánico seco
50435405|Alverja ojo negro seca orgánica|O|O||D||1|Alberjón ojo negro seco orgánico
50435406|Alverja crema zipper seca orgánica|O|O||D||1|Alberjón crema zipper seco orgánico
50435500|Pimientos orgánicos secos|O|O||D||1|Chiles orgánico seco
50435501|Pimentón ají orgánico seco|O|O||D||1|Ají orgánico seco
50435502|Pimentón  árbol orgánico seco|O|O||D||1|Chile de árbol orgánico seco
50435503|Pimentón queso orgánico seco|O|O||D||1
50435504|Pimentón chilaca orgánico seco|O|O||D||1|Chilaca
50435505|Pimentón cubanelles orgánico seco|O|O||D||1|Chile cubanelle o pimienta italiana orgánica seca
50435506|Pimentón fresno orgánico seco|O|O||D||1|Chile fresno orgánico seco
50435507|Pimentón kapia orgánico seco|O|O||D||1|Chile kapia orgánico seco
50435508|Pimentón coreano orgánico seco|O|O||D||1|Chile cheongyang orgánico seco
50435509|Pimentón manzano orgánico seco|O|O||D||1|Chile manzano o de cera
50435510|Pimentón melrose orgánico seco|O|O||D||1
50435511|Pimentón chile amarillo orgánico seco|O|O||D||1|Chile peruano amarillo orgánico seco
50435512|Pimentón aji dulce orgánico seco|O|O||D||1|Ají dulce orgánico seco
50435513|Pimentón anaheim orgánico seco|O|O||D||1
50435514|Pimentón ancho orgánico seco|O|O||D||1|Chile ancho o mulato
50435515|Pimentón campana orgánico seco|O|O||D||1|Chile campana orgánico seco
50435516|Pimentón cascabel orgánico seco|O|O||D||1|Chile cascabel
50435517|Pimentón cayenne orgánico seco|O|O||D||1|Pimienta de Cayena o roja orgánico seca
50435518|Pimentón anfitrión cereza orgánico seco|O|O||D||1
50435519|Pimentón chitespin orgánico seco|O|O||D||1|Chile chiltepín orgánico seco
50435520|Pimentón dedo picante orgánico seco|O|O||D||1|Chile Jwala orgánico seco
50435521|Pimentón guajillo orgánico seco|O|O||D||1|Chile guajillo
50435522|Pimentón guerro orgánico seco|O|O||D||1|Chile güero orgánico seco
50435523|Pimentón habanero orgánico seco|O|O||D||1|Chile habanero orgánico seco
50435524|Pimentón cera de hungria orgánico seco|O|O||D||1|Pimentón húngaro orgánico seco
50435525|Pimentón jalapeño orgánico seco|O|O||D||1|Chile chipotle o morita
50435526|Pimentón picante largo orgánico seco|O|O||D||1|Chile cola de rata orgánico seco
50435527|Pimentón marasol orgánico seco|O|O||D||1|Chile mirasol
50435528|Pimentón pasilla orgánico seco|O|O||D||1|Chile pasilla
50435529|Pimentón peperoncini orgánico seco|O|O||D||1
50435530|Pimentón pequin orgánico seco|O|O||D||1|Chile piquín orgánico seco
50435531|Pimentón pimiento orgánico seco|O|O||D||1|Pimiento morrón orgánico seco
50435532|Pimentón poblano orgánico seco|O|O||D||1|Chile poblano
50435533|Pimentón scotch bonnet orgánico seco|O|O||D||1|Pimientos Bonney o rojos Caribe orgánico seco
50435534|Pimentón serrano orgánico seco|O|O||D||1|Chile serrano, Chile verde
50435535|Pimentón tabasco orgánico seco|O|O||D||1|Chile tabasco orgánico seco
50435536|Pimentón tai  orgánico seco|O|O||D||1|Chile ojo de pájaro orgánico seco
50435537|Pimentón tepin orgánico seco|O|O||D||1|Chile mosquito o catarina
50435600|Papas orgánicas secas|O|O||D||1|Chiles
50435601|Papa blanca larga orgánica seca|O|O||D||1|Chile panca seco
50435602|Papa redonda blanca orgánica seca|O|O||D||1
50435603|Papa redonda roja orgánica seca|O|O||D||1|Papa de cambray orgánica seca
50435604|Papa  russet orgánica seca|O|O||D||1
50435605|Papa morada orgánica seca|O|O||D||1
50435606|Papa amarilla orgánica seca|O|O||D||1
50435607|Papa nueva orgánica seca|O|O||D||1
50435608|Papa especial orgánica seca|O|O||D||1
50435700|Nabos suecos orgánicos secos|O|O||D||1
50435701|Nabo sueco acme orgánico seco|O|O||D||1
50435702|Nabo sueco angela orgánico seco|O|O||D||1
50435703|Nabo sueco el mejor orgánico seco|O|O||D||1
50435704|Nabo sueco marian orgánico seco|O|O||D||1
50435800|Vegetales marinos orgánicos secos|O|O||D||1
50435801|Agar-agar orgánico seco|O|O||D||1
50435802|Arame  orgánica seca|O|O||D||1
50435803|Alga dulce orgánica seca|O|O||D||1
50435804|Habichuelas vert de mer orgánica seca|O|O||D||1
50435805|Hijiki orgánica seca|O|O||D||1
50435806|Musgo irlandés orgánica seca|O|O||D||1
50435807|Quelpo orgánico seco|O|O||D||1
50435808|Laver orgánico seco|O|O||D||1
50435809|Nori orgánico seco|O|O||D||1
50435810|Alga roja orgánica seca|O|O||D||1
50435811|Kale de mar orgánica seca|O|O||D||1
50435812|Lechuga de mar orgánica seca|O|O||D||1
50435813|Algas de mar orgánica seca|O|O||D||1
50435814|Spirulina orgánica seca|O|O||D||1
50435815|Susabi nuri orgánica seca|O|O||D||1
50435816|Wakame orgánica seca|O|O||D||1
50435900|Chalotes orgánicos secos|O|O||D||1
50435901|Chalote atlántica orgánico seco|O|O||D||1
50435902|Chalote creación orgánico seco|O|O||D||1
50435903|Chalote drittler nido blanco orgánico seco|O|O||D||1
50435904|Chalote gigante mejorado amarillo orgánico seco|O|O||D||1
50435905|Chalote gourmet dorado orgánico seco|O|O||D||1
50435906|Chalote grise de bagnolet orgánico seco|O|O||D||1
50435907|Chalote hative de nort orgánico seco|O|O||D||1
50435908|Chalote pikant orgánico seco|O|O||D||1
50435909|Chalote papa roja orgánico seco|O|O||D||1
50435910|Chalote sante orgánico seco|O|O||D||1
50435911|Chalote topper orgánico seco|O|O||D||1
50436000|Alazanes orgánicos secos|O|O||D||1|Acederas orgánicas secas
50436001|Alazán dock orgánica seca|O|O||D||1|Acedera dock orgánica seca
50436002|Alazán jardín orgánica seca|O|O||D||1|Acedera jardín orgánica seca
50436003|Alazán oveja orgánica seca|O|O||D||1|Acedera oveja orgánica seca
50436004|Alazán madera orgánica seca|O|O||D||1|Acedera madera orgánica seca
50436100|Espinacas orgánicas secas|O|O||D||1
50436101|Espinaca americana orgánica seca|O|O||D||1
50436102|Espinaca bloomsdale orgánica seca|O|O||D||1
50436103|Espinaca invierno gigante orgánica seca|O|O||D||1
50436104|Espinaca horenso orgánica seca|O|O||D||1
50436105|Espinaca planta de hielo orgánica seca|O|O||D||1
50436106|Espinaca  cuarto de cordero orgánica seca|O|O||D||1
50436107|Espinaca malabra orgánica seca|O|O||D||1
50436108|Espinaca mendania orgánica seca|O|O||D||1
50436109|Espinaca nueva zelandia orgánica seca|O|O||D||1
50436110|Espinaca orach orgánica seca|O|O||D||1
50436111|Espinaca savoy orgánica seca|O|O||D||1
50436112|Espinaca hoja de sigma orgánica seca|O|O||D||1
50436113|Espinaca espacio orgánica seca|O|O||D||1
50436114|Espinaca trinidad orgánica seca|O|O||D||1
50436115|Espinaca agua orgánica seca|O|O||D||1
50436116|Espinaca de agua sesa|O|O||D||1
50436200|Calabazas orgánicas secas|O|O||D||1
50436201|Calabaza boston orgánica seca|O|O||D||1
50436202|Calabaza buttemut orgánica seca|O|O||D||1
50436203|Calabaza costata romanesca orgánica seca|O|O||D||1
50436204|Calabaza crookneck orgánica seca|O|O||D||1
50436205|Calabaza  cucuzza orgánica seca|O|O||D||1
50436206|Calabaza  delicata orgánica seca|O|O||D||1
50436207|Calabaza  delisioso orgánica seca|O|O||D||1
50436208|Calabaza verano dorado cuello torcido orgánica seca|O|O||D||1
50436209|Calabaza prolífico temprano cuello recto orgánica seca|O|O||D||1
50436210|Calabaza  oro orgánica seca|O|O||D||1
50436211|Calabaza  jack pequeño orgánica seca|O|O||D||1
50436212|Calabaza  campo de kentucky orgánica seca|O|O||D||1
50436213|Calabaza marrow orgánica seca|O|O||D||1
50436214|Calabaza  medio oriente orgánica seca|O|O||D||1
50436215|Calabaza  miniatura orgánica seca|O|O||D||1
50436216|Calabaza  orangetti orgánica seca|O|O||D||1
50436217|Calabaza pattypan orgánica seca|O|O||D||1
50436218|Calabaza  rondini orgánica seca|O|O||D||1
50436219|Calabaza  redonda orgánica seca|O|O||D||1
50436220|Calabaza  espagueti orgánica seca|O|O||D||1
50436221|Calabaza  estripeti orgánica seca|O|O||D||1
50436222|Calabaza  molde dulce orgánica seca|O|O||D||1
50436223|Calabaza  empanada dulce orgánica seca|O|O||D||1
50436224|Calabaza  premio triple  orgánica seca|O|O||D||1
50436225|Calabaza waltham butternut orgánica seca|O|O||D||1
50436226|Calabaza  arbusto scallop amarillo orgánica seca|O|O||D||1
50436227|Calabaza cuello recto amarillo orgánica seca|O|O||D||1
50436228|Calabaza zafiro orgánica seca|O|O||D||1
50436229|Calabaza zucchini orgánica seca|O|O||D||1
50436300|Batatas orgánicas secas|O|O||D||1|Camotes orgánicos secos
50436301|Batata beauregard orgánica seca|O|O||D||1|Camote beauregard orgánico seca
50436302|Batata centennial orgánica seca|O|O||D||1|Camote centennial orgánico seca
50436303|Batata diane orgánica seca|O|O||D||1|Camote diane orgánico seca
50436304|Batata dulce garnet orgánica seca|O|O||D||1|Camote dulce garnet orgánico seca
50436305|Batata georgia dulce rojo orgánica seca|O|O||D||1|Camote georgia dulce rojo orgánico seca
50436306|Batata  dorado orgánica seca|O|O||D||1|Camote dorado orgánico seca
50436307|Batata hanna  orgánica seca|O|O||D||1|Camote hanna orgánico seca
50436308|Batata japonés orgánica seca|O|O||D||1|Camote japonés orgánico seca
50436309|Batata jersey orgánica seca|O|O||D||1|Camote jersey orgánico seca
50436310|Batata joya orgánica seca|O|O||D||1|Camote joya orgánico seca
50436311|Batata meryland roja orgánica seca|O|O||D||1|Camote meryland roja orgánico seca
50436312|Batata nema dorado orgánica seca|O|O||D||1|Camote nema dorado orgánico seca
50436313|Batata o´henry orgánica seca|O|O||D||1|Camote o´henry orgánico seca
50436314|Batata okinawan orgánica seca|O|O||D||1|Camote okinawan orgánico seca
50436315|Batata naranja orgánica seca|O|O||D||1|Camote naranja orgánico seca
50436316|Batata oriental orgánica seca|O|O||D||1|Camote oriental orgánico seca
50436317|Batata jersey rojo orgánica seca|O|O||D||1|Camote jersey rojo orgánico seca
50436318|Batata mar rojo orgánica seca|O|O||D||1|Camote mar rojo orgánico seca
50436319|Batata brillo rojo orgánica seca|O|O||D||1|Camote brillo rojo orgánico seca
50436320|Batata jersey amarillo orgánica seca|O|O||D||1|Camote jersey amarillo orgánico seca
50436400|Tomates orgánicos secos|O|O||D||1|Jitomates orgánicos secos
50436401|Tomates ailsa craig orgánico seco|O|O||D||1|Jitomate ailsa craig orgánico seco
50436402|Tomates alicante orgánico seco|O|O||D||1|Jitomate alicante orgánico seco
50436403|Tomates ciruela negra orgánico seco|O|O||D||1|Jitomate ciruela negra orgánico seco
50436404|Tomates vino de brandy orgánico seco|O|O||D||1|Jitomate vino de brandy orgánico seco
50436405|Tomates bella cereza orgánico seco|O|O||D||1|Jitomate bella cereza orgánico seco
50436406|Tomates cereza orgánico seco|O|O||D||1|Jitomate cereza orgánico seco
50436407|Tomates delicioso orgánico seco|O|O||D||1|Jitomate delicioso orgánico seco
50436408|Tomates dombito orgánico seco|O|O||D||1|Jitomate dombito orgánico seco
50436409|Tomates delicia del jardín orgánico seco|O|O||D||1|Jitomate delicia del jardín orgánico seco
50436410|Tomates uva orgánico seco|O|O||D||1|Jitomate uva orgánico seco
50436411|Tomates verde orgánico seco|O|O||D||1|Tomate verde orgánico seco
50436412|Tomates super marmande orgánico seco|O|O||D||1|Jitomate super marmande orgánico seco
50436413|Tomates rayas naturales marvel orgánico seco|O|O||D||1|Jitomate rayas naturales marvel orgánico seco
50436414|Tomates minibel orgánico seco|O|O||D||1|Jitomate minibel orgánico seco
50436415|Tomates oaxacan orgánico seco|O|O||D||1|Jitomate oaxaca orgánico seco
50436416|Tomates alerta roja orgánico seco|O|O||D||1|Jitomate alerta roja orgánico seco
50436417|Tomates roma vf orgánico seco|O|O||D||1|Jitomate roma vf orgánico seco
50436418|Tomates marzano zan orgánico seco|O|O||D||1|Jitomate marzano zan orgánico seco
50436419|Tomates shirley orgánico seco|O|O||D||1|Jitomate shirley orgánico seco
50436420|Tomates siberia orgánico seco|O|O||D||1|Jitomate siberia orgánico seco
50436421|Tomates super beefsteak orgánico seco|O|O||D||1|Jitomate super beefsteak orgánico seco
50436422|Tomates tigerella orgánico seco|O|O||D||1|Jitomate tigerella orgánico seco
50436423|Tomates tiny tim orgánico seco|O|O||D||1|Jitomate tiny tim orgánico seco
50436424|Tomates tumbler orgánico seco|O|O||D||1|Jitomate tumbler orgánico seco
50436425|Tomates cocktail amarillo orgánico seco|O|O||D||1
50436426|Tomates forma de pera amarillo orgánico seco|O|O||D||1
50436427|Tomates perfección amarilla orgánico seco|O|O||D||1
50436500|Nabos orgánicos secos|O|O||D||1
50436501|Nabo globo verde orgánico seco|O|O||D||1
50436502|Nabo bola dorada orgánico seco|O|O||D||1
50436503|Nabo mercado de manchester orgánico seco|O|O||D||1
50436504|Nabo top morado milan orgánico seco|O|O||D||1
50436505|Nabo top morado blanco orgánico seco|O|O||D||1
50436506|Nabo bola de nieve orgánico seco|O|O||D||1
50436507|Nabo tokio orgánico seco|O|O||D||1
50436508|Nabo cruz de tokio orgánico seco|O|O||D||1
50436600|Auyamas orgánicas secas|O|O||D||1|Calabazas gigantes orgánicas secas
50436601|Calabaza acorn seca orgánica|O|O||D||1|Calabaza gigante acorn seca orgánica
50436602|Calabaza gigante atlántico orgánica seca|O|O||D||1|Calabaza gigante atlántico orgánica seca
50436603|Calabaza banana rosado orgánica seca|O|O||D||1|Calabaza gigante banana rosado orgánica seca
50436604|Calabaza max grande orgánica seca|O|O||D||1|Calabaza gigante max orgánica seca
50436605|Calabaza  orgánica seca|O|O||D||1|Calabaza de castilla orgánica seca
50436606|Calabaza carnaval orgánica seca|O|O||D||1|Calabaza gigante carnaval orgánica seca
50436607|Auyama queso orgánica seca|O|O||D||1|Calabaza gigante queso orgánica seca
50436608|Calabaza príncipe coronado orgánica seca|O|O||D||1|Calabaza gigante príncipe coronado orgánica seca
50436609|Calabaza  curcibita orgánica seca|O|O||D||1|Calabaza gigante curcibita orgánica seca
50436610|Calabaza cushaw orgánica seca|O|O||D||1|Calabaza gigante cushaw orgánica seca
50436611|Calabaza  gigante auyama orgánica seca|O|O||D||1
50436612|Calabaza  hubbard orgánica seca|O|O||D||1|Calabaza gigante hubbard orgánica seca
50436613|Calabaza  jerrahdale orgánica seca|O|O||D||1|Calabaza gigante jerrahdale orgánica seca
50436614|Calabaza  kabocha orgánica seca|O|O||D||1|Calabaza gigante kabocha orgánica seca
50436615|Calabaza queensland azul orgánica seca|O|O||D||1|Calabaza gigante queensland azul orgánica seca
50436616|Calabaza rouge vif détampes orgánica seca|O|O||D||1|Calabaza gigante rouge vif détampes orgánica seca
50436617|Calabaza  turban turco orgánica seca|O|O||D||1|Calabaza gigante turban turco orgánica seca
50436618|Calabaza  valenciano orgánica seca|O|O||D||1|Calabaza gigante valenciano orgánica seca
50436619|Calabaza  warted hubbard orgánica seca|O|O||D||1|Calabaza gigante warted hubbard orgánica seca
50436620|Auyama whangaparoa orgánica seca|O|O||D||1|Calabaza gigante whangaparoa orgánica seca
50436700|Ñames orgánicos secos|O|O||D||1
50436701|Ñame agria africana orgánica seca|O|O||D||1
50436702|Ñame agria asiática orgánica seca|O|O||D||1
50436703|Ñame china orgánico seco|O|O||D||1
50436704|Ñame globo orgánico seco|O|O||D||1
50436705|Ñame grater orgánico seco|O|O||D||1
50436706|Ñame japonesa orgánico seco|O|O||D||1
50436707|Ñame lesser orgánico seco|O|O||D||1
50436708|Ñame papa orgánico seco|O|O||D||1
50436709|Ñame guinea blanca orgánico seco|O|O||D||1
50436710|Ñame guinea amarillo orgánico seco|O|O||D||1
50436800|Vegetales Nominant orgánicos secos|O|O||D||1|Vegetales predominantes orgánicos secos, Nopal orgánico seco
50436801|Alfalfa orgánica seca|O|O||D||1
50436802|Hojas de aloe orgánica seca|O|O||D||1|Hoja de sábila orgánica seca, Penca de sábila orgánica seca
50436803|Apio orgánico seco|O|O||D||1
50436804|Arrurruz orgánica seca|O|O||D||1
50436805|Punta de flecha orgánica seca|O|O||D||1|Sagittaria orgánica seca
50436806|rúcula orgánica seca|O|O||D||1
50436807|Arum orgánica seca|O|O||D||1|Taro orgánico seco
50436808|Raíz de bambú orgánica seca|O|O||D||1
50436809|Hojas de plátano orgánica seca|O|O||D||1
50436810|Batatas orgánica seca|O|O||D||1
50436811|Brotes de frijol orgánicos secos|O|O||D||1
50436812|Top de remolacha orgánica seca|O|O||D||1|Betabel orgánico seco
50436813|Melón agrio orgánico seco|O|O||D||1|Balsamina orgánica seca
50436814|Bayas de alcaparra orgánicas secas|O|O||D||1
50436815|Carob orgánico seco|O|O||D||1|Algarrobo orgánico seco
50436816|Cha-om orgánico seco|O|O||D||1
50436817|Chayote o guatila orgánico seco|O|O||D||1
50436818|Garbanzo orgánico seco|O|O||D||1
50436819|Verde de crisantemos orgánico seco|O|O||D||1
50436820|Verde de diente de león orgánico seco|O|O||D||1
50436821|Diente de león orgánico seco|O|O||D||1
50436822|Dasheen orgánico seco|O|O||D||1
50436823|Puntas de alverja orgánico seco|O|O||D||1
50436824|Diakon orgánico seco|O|O||D||1|Rábano orgánico seco
50436825|Donqua orgánica seca|O|O||D||1|Ginseng hembra orgánica seca
50436826|Helecho orgánico seco|O|O||D||1|Brotes de helecho orgánico seco
50436827|Gai choi orgánico seco|O|O||D||1|Mostaza castaña orgánica seca
50436828|Gailon orgánico seco|O|O||D||1|Brécol chino orgánico seco
50436829|Galanga orgánica seca|O|O||D||1|Jengibre azul orgánico seco
50436830|Raíz de jengibre orgánica seca|O|O||D||1
50436831|Gobo orgánico seco|O|O||D||1|Garduña orgánica seca
50436832|Brote de lúpulo orgánico seco|O|O||D||1
50436833|Rabano blanco orgánico seco|O|O||D||1|Rábano de caballo orgánico seco
50436834|Jicama orgánica seca|O|O||D||1
50436835|Kuduz orgánica seca|O|O||D||1|Kudzu orgánico seco
50436836|Bulbo de margarita orgánico seco|O|O||D||1|Bulbo de lili chino orgánico seco
50436837|Linkok orgánico seco|O|O||D||1
50436838|Lo bok orgánico seco|O|O||D||1
50436839|Frijol largo orgánico seco|O|O||D||1|Fríjol serpiente orgánico seco
50436840|Raíz de lotus orgánico seco|O|O||D||1|Rosa del Nilo orgánica seca
50436841|Hojas de maguey orgánica seca|O|O||D||1|Hoja de agave orgánica seca, Penca de maguey orgánica seca
50436842|Mallows orgánico seco|O|O||D||1|Malva orgánica seca
50436843|Sapote mamey orgánico seco|O|O||D||1|Mamey orgánico seco
50436844|Moap orgánico seco|O|O||D||1
50436845|Moo orgánico seco|O|O||D||1
50436846|Moqua orgánica seca|O|O||D||1
50436847|Opos orgánicos secos|O|O||D||1
50436848|Corazon de palma orgánico seco|O|O||D||1|Palmito orgánico seco
50436849|Paprika orgánica seca|O|O||D||1
50436850|Purslane orgánica seca|O|O||D||1|Verdolaga orgánica seca
50436851|Raddichios orgánica seca|O|O||D||1|Achicoria morada orgánica seca
50436852|Sinquas orgánica seca|O|O||D||1|Zapallo orgánico seco
50436853|Frijol de soya orgánicos secos|O|O||D||1
50436854|Spoonwart orgánico seco|O|O||D||1|Hierba del escorbuto orgánica seca
50436855|Uva tassele hyacinth orgánico seco|O|O||D||1
50436856|Taro orgánico seco|O|O||D||1|Tales orgánica seca
50436857|Hoja de taro orgánica seca|O|O||D||1
50436858|Tallo de taro orgánico seco|O|O||D||1
50436859|Tapeguaje orgánico seco|O|O||D||1
50436860|Verde tierno orgánico seco|O|O||D||1
50436861|Tindora orgánico seco|O|O||D||1
50436862|Árbol de cebolla orgánico seco|O|O||D||1|Cebollas egipcias orgánica seca
50436863|Udo orgánico seco|O|O||D||1
50436864|Agua castaño orgánico seco|O|O||D||1|Castaña de agua china orgánica seca
50436865|Yumpi orgánico seco|O|O||D||1|Akankong orgánico seco
50436866|Yautia orgánico seco|O|O||D||1|Mapuey orgánico seco
50436867|Yu choy orgánico seco|O|O||D||1
50436868|Yuca orgánica seca|O|O||D||1
50436900|Alverjas dulces orgánicas secas|O|O||D||1|Chícharos orgánicos secos
50436901|Alverja biquini orgánica seca|O|O||D||1|Chícharo biquini orgánico seco
50436902|Alverja cavalier orgánica seca|O|O||D||1|Chícharo cavalier orgánico seco
50436903|Alverja margarita orgánica seca|O|O||D||1|Chícharo margarita orgánico seco
50436904|Alverja dar fon orgánica seca|O|O||D||1|Chícharo dar fon orgánico seco
50436905|Alverja "early onward" orgánica seca|O|O||D||1|Chícharo "early onward" orgánico seco
50436906|Alverja primer feltham orgánica seca|O|O||D||1|Chícharo primer feltham orgánico seco
50436907|Alverja verde hurst shaft orgánica seca|O|O||D||1|Chícharo verde hurst shaft orgánico seco
50436908|Guisante oregón sugar pod orgánica seca|O|O||D||1|Chícharo oregón sugar pod orgánico seco
50436909|Alverja príncipe alberto orgánica seca|O|O||D||1|Chícharo príncipe alberto orgánico seco
50436910|Alverja reuzensuiker orgánica seca|O|O||D||1|Chícharo reuzensuiker orgánico seco
50441500|Alcachofas congeladas|O|O||D||1
50441501|Alcachofa brittany congelada|O|O||D||1
50441502|Alcachofa cantonesa congelada|O|O||D||1
50441503|Alcachofa francesa congelada|O|O||D||1
50441504|Alcachofa globo verde congelada|O|O||D||1
50441505|Alcachofa gros camus de bretaña congelada|O|O||D||1
50441506|Alcachofa midi congelada|O|O||D||1
50441507|Alcachofa globo morado congelada|O|O||D||1
50441508|Alcachofa morado cecilia congelada|O|O||D||1
50441509|Alcachofa romanesco congelada|O|O||D||1
50441510|Alcachofa espinoso sardo congelada|O|O||D||1
50441511|Alcachofa vert de laon congelada|O|O||D||1
50441512|Alcachofa violeta de chiggiia congelada|O|O||D||1
50441513|Alcachofa violeta de toscana congelada|O|O||D||1
50441600|Espárragos congelados|O|O||D||1
50441601|Espárragos connovers colosal congelados|O|O||D||1
50441602|Espárragos franklin congelados|O|O||D||1
50441603|Espárragos mamut gigante congelados|O|O||D||1
50441604|Espárragos lucullus congelados|O|O||D||1
50441605|Espárragos martha washington congelados|O|O||D||1
50441700|Aguacates congelados|O|O||D||1
50441701|Aguacate ajax b – 7 congelado|O|O||D||1
50441702|Aguacate arue congelado|O|O||D||1
50441703|Aguacate bacon congelado|O|O||D||1
50441704|Aguacate benik congelado|O|O||D||1
50441705|Aguacate bernecker congelado|O|O||D||1
50441706|Aguacate beta congelado|O|O||D||1
50441707|Aguacate biondo congelado|O|O||D||1
50441708|Aguacate príncipe negro congelado|O|O||D||1
50441709|Aguacate blair congelado|O|O||D||1
50441710|Aguacate blair cabina congelado|O|O||D||1
50441711|Aguacate cabina 1 congelado|O|O||D||1
50441712|Aguacate cabina 3 congelado|O|O||D||1
50441713|Aguacate cabina 5 congelado|O|O||D||1
50441714|Aguacate cabina 7 congelado|O|O||D||1
50441715|Aguacate cabina 8 congelado|O|O||D||1
50441716|Aguacate brooks 1978 congelado|O|O||D||1
50441717|Aguacate brookslate congelado|O|O||D||1
50441718|Aguacate california haas congelado|O|O||D||1
50441719|Aguacate catalina congelado|O|O||D||1
50441720|Aguacate chica congelado|O|O||D||1
50441721|Aguacate choquette congelado|O|O||D||1
50441722|Aguacate cristina congelado|O|O||D||1
50441723|Aguacate collison congelado|O|O||D||1
50441724|Aguacate donnie congelado|O|O||D||1
50441725|Aguacate dr dupis numero 2 congelado|O|O||D||1
50441726|Aguacate dr. dupie  congelado|O|O||D||1
50441727|Aguacate ettinger congelado|O|O||D||1
50441728|Aguacate fuch congelado|O|O||D||1
50441729|Aguacate fuch gwen congelado|O|O||D||1
50441730|Aguacate fuerte congelado|O|O||D||1
50441731|Aguacate gotham congelado|O|O||D||1
50441732|Aguacate gossman congelado|O|O||D||1
50441733|Aguacate guatemala sin pepa congelado|O|O||D||1
50441734|Aguacate hall congelado|O|O||D||1
50441735|Aguacate hardee congelado|O|O||D||1
50441736|Aguacate haas congelado|O|O||D||1
50441737|Aguacate herman congelado|O|O||D||1
50441738|Aguacate hickson congelado|O|O||D||1
50441739|Aguacate k-5 congelado|O|O||D||1
50441740|Aguacate k- 9 congelado|O|O||D||1
50441741|Aguacate cordero haas congelado|O|O||D||1
50441742|Aguacate leona congelado|O|O||D||1
50441743|Aguacate leona linda congelado|O|O||D||1
50441744|Aguacate lisa p congelado|O|O||D||1
50441745|Aguacate lisa loretta congelado|O|O||D||1
50441746|Aguacate loretta congelado|O|O||D||1
50441747|Aguacate lula congelado|O|O||D||1
50441748|Aguacate lula mascarthur congelado|O|O||D||1
50441749|Aguacate marcus congelado|O|O||D||1
50441750|Aguacate melendez congelado|O|O||D||1
50441751|Aguacate meya congelado|O|O||D||1
50441752|Aguacate miguel p congelado|O|O||D||1
50441753|Aguacate monroe congelado|O|O||D||1
50441754|Aguacate murrieta verde congelado|O|O||D||1
50441755|Aguacate nabal congelado|O|O||D||1
50441756|Aguacate nadir congelado|O|O||D||1
50441757|Aguacate nesbitt congelado|O|O||D||1
50441758|Aguacate peterson congelado|O|O||D||1
50441759|Aguacate pinelli congelado|O|O||D||1
50441760|Aguacate pinkerton congelado|O|O||D||1
50441761|Aguacate pollock congelado|O|O||D||1
50441762|Aguacate puebla congelado|O|O||D||1
50441763|Aguacate reed congelado|O|O||D||1
50441764|Aguacaterue congelado|O|O||D||1
50441765|Aguacateruehle congelado|O|O||D||1
50441766|Aguacate ryan congelado|O|O||D||1
50441767|Aguacate semil congelado|O|O||D||1
50441768|Aguacate semil 43 congelado|O|O||D||1
50441769|Aguacate simonds congelado|O|O||D||1
50441770|Aguacate simpson congelado|O|O||D||1
50441771|Aguacate taylor congelado|O|O||D||1
50441772|Aguacate tonelada congelado|O|O||D||1
50441773|Aguacate torre congelado|O|O||D||1
50441774|Aguacate torre li congelado|O|O||D||1
50441775|Aguacate trapp congelado|O|O||D||1
50441776|Aguacate semilla de caribe congelado|O|O||D||1
50441777|Aguacate wagner congelado|O|O||D||1
50441778|Aguacate waldin congelado|O|O||D||1
50441779|Aguacate wurtz congelado|O|O||D||1
50441780|Aguacate zio p congelado|O|O||D||1
50441781|Aguacate ziu congelado|O|O||D||1
50441782|Aguacate zultano congelado|O|O||D||1
50441800|Fríjoles congelados|O|O||D||1
50441801|Frijoles anasazi ® congelados|O|O||D||1
50441802|Frijoles appaloosa congelados|O|O||D||1
50441803|Frijoles azuki congelados|O|O||D||1
50441804|Frijoles barlotti congelados|O|O||D||1
50441805|Frijoles appaloosa negra congelados|O|O||D||1
50441806|Frijoles negros congelados|O|O||D||1
50441807|Frijoles gran negros congelados|O|O||D||1
50441808|Frijoles shackamaxon negro congelados|O|O||D||1
50441809|Frijoles ojo negro congelados|O|O||D||1
50441810|Frijoles bobby congelados|O|O||D||1
50441811|Frijoles bolita congelados|O|O||D||1
50441812|Frijoles esposa perezosa carmelita congelados|O|O||D||1
50441813|Frijoles calipso congelados|O|O||D||1
50441814|Frijoles canelini congelados|O|O||D||1
50441815|Frijoles castor congelados|O|O||D||1
50441816|Frijoles amarillo chino congelados|O|O||D||1
50441817|Frijoles lengua de dragón congelados|O|O||D||1
50441818|Frijoles soldado europeo congelados|O|O||D||1
50441819|Frijoles fava congelados|O|O||D||1
50441820|Frijoles flageolet congelados|O|O||D||1
50441821|Frijoles  horticultura francesa congelados|O|O||D||1
50441822|Frijoles marina francesa congelados|O|O||D||1
50441823|Frijoles coco gigante blanco congelados|O|O||D||1
50441824|Frijoles verdes congelados|O|O||D||1
50441825|Frijoles romano verde congelados|O|O||D||1
50441826|Frijoles guar gum congelados|O|O||D||1
50441827|Frijoles haricot congelados|O|O||D||1
50441828|Frijoles hyacinth congelados|O|O||D||1
50441829|Frijoles tipo italiano congelados|O|O||D||1
50441830|Frijoles asombro jackson congelados|O|O||D||1
50441831|Frijoles ganado jacobs  congelados|O|O||D||1
50441832|Frijoles asombro kentucky congelados|O|O||D||1
50441833|Frijoles riñón congelados|O|O||D||1
50441834|Frijoles lima congelados|O|O||D||1
50441835|Frijoles madera congelados|O|O||D||1
50441836|Frijoles medula congelados|O|O||D||1
50441837|Frijoles mat congelados|O|O||D||1
50441838|Frijoles monstoler ganzo salvaje congelados|O|O||D||1
50441839|Frijoles  mortgage lifter congelados|O|O||D||1
50441840|Frijoles polilla congelados|O|O||D||1
50441841|Frijoles mung congelados|O|O||D||1
50441842|Frijoles munsi wolf congelados|O|O||D||1
50441843|Frijoles nuna congelados|O|O||D||1
50441844|Frijoles pinto congelados|O|O||D||1
50441845|Frijoles runner congelados|O|O||D||1
50441846|String beans congelados|O|O||D||1|Ayecote congelado, Fríjol gordo congelado
50441847|Frijoles habichuelas congelados|O|O||D||1|Ejote congelado, Fríjol tierno congelado
50441848|Frijoles tamarind congelados|O|O||D||1
50441849|Frijoles tonka congelados|O|O||D||1
50441850|Frijoles cera congelados|O|O||D||1
50441851|Frijoles winged congelados|O|O||D||1
50441852|Frijoles largos congelados|O|O||D||1
50441900|Remolachas  congeladas|O|O||D||1|Betabeles congelados
50441901|Remolacha acción congelada|O|O||D||1|Betabel acción congelado
50441902|Remolacha albina vereduna congelada|O|O||D||1|Betabel albina vereduna congelado
50441903|Remolacha barababiotela de chiggia congelada|O|O||D||1|Betabel barababiotela de chiggia congelado
50441904|Remolacha boltardy congelada|O|O||D||1|Betabel boltardy congelado
50441905|Remolacha bonel congelada|O|O||D||1|Betabel bonel congelado
50441906|Remolacha burpees dorado congelada|O|O||D||1|Betabel burpees dorado congelado
50441907|Remolacha cheltenham tapa verde congelada|O|O||D||1|Betabel cheltenham tapa verde congelado
50441908|Remolacha cheltenham mono congelada|O|O||D||1|Betabel cheltenham mono congelado
50441909|Remolacha chioggia congelada|O|O||D||1|Betabel chioggia congelado
50441910|Remolacha cilindra congelada|O|O||D||1|Betabel cilindra congelado
50441911|Remolacha dégypte congelada|O|O||D||1|Betabel dégypte congelado
50441912|Remolacha detroit 2 rojo oscuro congelada|O|O||D||1|Betabel detroit 2 rojo oscuro congelado
50441913|Remolacha detroit 2 bala chiquita congelada|O|O||D||1|Betabel detroit 2 bala chiquita congelado
50441914|Remolacha egipcia plana  congelada|O|O||D||1|Betabel egipcia plana congelado
50441915|Remolacha  raíz de nabo egipcio congelada|O|O||D||1|Betabel raíz de nabo egipcio congelado
50441916|Remolacha fomanova congelada|O|O||D||1|Betabel fomanova congelado
50441917|Remolacha forono congelada|O|O||D||1|Betabel forono congelado
50441918|Remolacha monaco congelada|O|O||D||1|Betabel mónaco congelado
50441919|Remolacha monograma congelada|O|O||D||1|Betabel monograma congelado
50441920|Remolacha pronto congelada|O|O||D||1|Betabel pronto congelado
50441921|Remolacha regalía congelada|O|O||D||1|Betabel regalía congelado
50441922|Remolacha dulce congelada|O|O||D||1|Betabel dulce congelado
50442000|Brócolis  congeladas|O|O||D||1
50442001|Brócolini congelado|O|O||D||1
50442002|Brócoli romanesco congelado|O|O||D||1
50442003|Brócoli raab congelado|O|O||D||1
50442004|Brócoli chino congelado|O|O||D||1
50442100|Repollitos de Bruselas  congeladas|O|O||D||1|Coles de Bruselas congeladas
50442101|Repollitas de bruselas citade congeladas|O|O||D||1|Coles de Bruselas citade congeladas
50442102|Repollitas de bruselas falstaff congeladas|O|O||D||1|Coles de Bruselas falstaff congeladas
50442103|Repollitas de bruselas oliver congeladas|O|O||D||1|Coles de Bruselas oliver congeladas
50442104|Repollitas de bruselas peer gynt congeladas|O|O||D||1|Coles de Bruselas peer gynt congeladas
50442105|Repollitas de bruselas rampart congeladas|O|O||D||1|Coles de Bruselas rampart congeladas
50442106|Repollitas de bruselas rubine congeladas|O|O||D||1|Coles de Bruselas rubine congeladas
50442107|Repollitas de bruselas  widgeon congeladas|O|O||D||1|Coles de Bruselas widgeon congeladas
50442200|Cebollas de ensalada  congeladas|O|O||D||1|Cebollas de cambray  congeladas
50442201|Cebolla belstville ensalada congelada|O|O||D||1|Cebolla de cambray belstville congelada
50442202|Cebolla feast ensalada congelada|O|O||D||1|Cebolla de cambray feast congelada
50442203|Cebolla ishikura ensalada congelada|O|O||D||1|Cebolla de cambray ishikura congelada
50442204|Cebolla mercado kyoto congelada|O|O||D||1|Cebolla de cambray mercado kyoto congelada
50442205|Cebolla barba roja ensalada congelada|O|O||D||1|Cebolla de cambray barba roja congelada
50442206|Cebolla amigo rojo ensalada congelada|O|O||D||1|Cebolla de cambray amigo rojo congelada
50442207|Cebolla santa claus congelada|O|O||D||1|Cebolla de cambray santa claus congelada
50442208|Cebolla tokyo ensalada congelada|O|O||D||1|Cebolla de cambray tokyo congelada
50442209|Cebolla lisbon blanca ensalada congelada|O|O||D||1|Cebolla de cambray lisbon blanca congelada
50442210|Cebolla invierno blanca ensalada congelada|O|O||D||1|Cebolla de cambray invierno blanca congelada
50442211|Cebolla final de invierno ensalada congelada|O|O||D||1|Cebolla de cambray final de invierno congelada
50442300|Repollos congelados|O|O||D||1|Coles congeladas
50442301|Repollo negro congelado|O|O||D||1|Col negro congelada
50442302|Repollo savoy congelado|O|O||D||1|Col savoy congelada
50442303|Repollo zorrillo congelado|O|O||D||1|Col zorrillo congelada
50442304|Repollo blanco congelado|O|O||D||1|Col blanco congelada
50442400|Cardos congelados|O|O||D||1|Cardos comestibles congelados
50442401|Cardos lunghi congelados|O|O||D||1|Cardo comestible lunghi congelados
50442402|Cardos gobbi congelados|O|O||D||1|Cardo comestible gobbi congelados
50442500|Zanahorias  congeladas|O|O||D||1
50442501|Zanahoria amsterdam congelada|O|O||D||1
50442502|Zanahoria rey de otoño congelada|O|O||D||1
50442503|Zanahoria berlicum congelada|O|O||D||1
50442504|Zanahoria chantenay congelada|O|O||D||1
50442505|Zanahoria nantes congelada|O|O||D||1
50442506|Zanahoria mercado de parís congelada|O|O||D||1
50442600|Coliflores  congeladas|O|O||D||1
50442601|Coliflor todo el año  congelada|O|O||D||1
50442602|Coliflor alverda congelada|O|O||D||1
50442603|coliflor otoño gigante 3 congelada|O|O||D||1
50442604|Coliflo rdok elgon congelada|O|O||D||1
50442605|Coliflor bola de nieve temprana congelada|O|O||D||1
50442606|Coliflor luz de lima congelada|O|O||D||1
50442607|Coliflor minaret congelada|O|O||D||1
50442608|Coliflor buque de naranja congelada|O|O||D||1
50442609|Coliflor capa morada congelada|O|O||D||1
50442610|Coliflor bola de nieve congelada|O|O||D||1
50442611|Coliflor invierno walcheren 3 congelada|O|O||D||1
50442612|Coliflor piedra blanca congelada|O|O||D||1
50442700|Apios congelados|O|O||D||1
50442701|Apio celebridad congelado|O|O||D||1
50442702|Apio nabo congelado|O|O||D||1
50442703|Apio chino congelado|O|O||D||1
50442704|Apio dinant francés congelado|O|O||D||1
50442705|Apio gigante rosado congelado|O|O||D||1
50442706|Apio gigante rojo congelado|O|O||D||1
50442707|Apio gigante blanco congelado|O|O||D||1
50442708|Apio dorado auto escalado congelado|O|O||D||1
50442709|Apio "greensleeves" congelado|O|O||D||1
50442710|Apio hopkins fenlander congelado|O|O||D||1
50442711|Apio torre marfil congelado|O|O||D||1
50442712|Apio lathom blanqueado congelado|O|O||D||1
50442713|Apio sopa de amsterdam congelado|O|O||D||1
50442714|Apio estándar cargado congelado|O|O||D||1
50442715|Apio triunfo alto utah congelado|O|O||D||1
50442800|Acelgas  congeladas|O|O||D||1
50442801|Acelga luz brillante congelada|O|O||D||1
50442802|Acelga gigante fordhook congelada|O|O||D||1
50442803|Acelga luculus congelada|O|O||D||1
50442804|Acelga espinaca perpetua congelada|O|O||D||1
50442805|Acelga ruibarbo congelada|O|O||D||1
50442806|Acelga suizo congelada|O|O||D||1
50442807|Acelga volcán  congelada|O|O||D||1
50442808|Acelga rey blanco congelada|O|O||D||1
50442900|Achicorias congeladas|O|O||D||1|Escarolas congeladas
50442901|Achicoria batavian hoja ancha congelada|O|O||D||1|Escarola batavian hoja ancha congelada
50442902|Achicoria en cornet de bordeaux congelada|O|O||D||1|Escarola en cornet de bordeaux congelada
50442903|Achicoria rollo verde ruffee congelada|O|O||D||1|Escarola rollo verde ruffee congelada
50442904|Achicoria roll verde congelada|O|O||D||1|Escarola roll verde congelada
50442905|Achicoria limnoe lone congelada|O|O||D||1|Escarola limnoe lone congelada
50442906|Achicoria pancalieri riccia congelada|O|O||D||1|Escarola pancalieri riccia congelada
50442907|Achicoria ensalada rey congelada|O|O||D||1|Escarola ensalada rey congelada
50442908|Achicoria sanda congelada|O|O||D||1|Escarola sanda congelada
50442909|Achicoria scarola verde congelada|O|O||D||1|Escarola scarola verde congelada
50442910|Achicoria tres fine maraichere congelada|O|O||D||1|Escarola tres fine maraichere congelada
50442911|Achicoria wallone freisee wescelkkopf congelada|O|O||D||1|Escarola wallone freisee wescelkkopf congelada
50443000|Repollos chinos congelados|O|O||D||1|Coles chinas congeladas
50443001|Bok choy congelado|O|O||D||1
50443002|Bok choy enano congelado|O|O||D||1
50443003|Flor de repollo chino congelada|O|O||D||1|Flor de col china congelada
50443004|Choy sum congelado|O|O||D||1
50443005|Col (bok choy) enano congelado|O|O||D||1
50443006|Col (bok choy) fengshan congelado|O|O||D||1
50443007|Col (bok choy) jade pagoda congelado|O|O||D||1
50443008|Col (bok choy) kasumi congelado|O|O||D||1
50443009|col (bok choy)  nerva congelado|O|O||D||1
50443010|Col (bok choy) rosette congelado|O|O||D||1
50443011|Col (bok choy) ruffles congelado|O|O||D||1
50443012|Col (bok choy) hoja  santo serrated congelado|O|O||D||1
50443013|Col (bok choy) shangahai congelado|O|O||D||1
50443014|Shantung congelado|O|O||D||1
50443015|Repollo tip top congelado|O|O||D||1|Col china tip top congelado
50443016|Yau choy sum congelado|O|O||D||1
50443100|Cebollines congelados|O|O||D||1
50443101|Cebollín chino congelado|O|O||D||1
50443200|Maíces congelados|O|O||D||1
50443201|Maíz aloha congelado|O|O||D||1
50443202|Maíz alpine congelado|O|O||D||1
50443203|Maíz ambrosia congelado|O|O||D||1
50443204|Maíz argent congelado|O|O||D||1
50443205|Maíz aspen congelado|O|O||D||1
50443206|Maíz avalancha congelado|O|O||D||1
50443207|Maíz biqueen congelado|O|O||D||1
50443208|Maíz  bodacious congelado|O|O||D||1
50443209|Maíz  mantequilla y azúcar congelado|O|O||D||1
50443210|Maíz  calico belle congelado|O|O||D||1
50443211|Maíz  camelot congelado|O|O||D||1
50443212|Maíz  challengercrisp ‘n dulce congelado|O|O||D||1
50443213|Maíz  campeón congelado|O|O||D||1
50443214|Maíz  algodón de azúcar congelado|O|O||D||1
50443215|Maíz  dártagnan congelado|O|O||D||1
50443216|Maíz  dazzle congelado|O|O||D||1
50443217|Maíz  diamante y oro congelado|O|O||D||1
50443218|Maíz  divinidad congelado|O|O||D||1
50443219|Maíz  delicia doble congelado|O|O||D||1
50443220|Maíz  gema doble congelado|O|O||D||1
50443221|Maíz  earlivee congelado|O|O||D||1
50443222|Maíz  temprano extra dulce congelado|O|O||D||1
50443223|Maíz excel congelado|O|O||D||1
50443224|Maíz  cruz dorada bantam congelado|O|O||D||1
50443225|Maíz  miel y crema congelado|O|O||D||1
50443226|Maíz  miel y perla congelado|O|O||D||1
50443227|Maíz  miel dulce congelado|O|O||D||1
50443228|Maíz  hudson congelado|O|O||D||1
50443229|Maíz  dorado illini congelado|O|O||D||1
50443230|Maíz  illini extra dulce congelado|O|O||D||1
50443231|Maíz  increíble congelado|O|O||D||1
50443232|Maíz  lochief congelado|O|O||D||1
50443233|Maíz jubileo congelado|O|O||D||1
50443234|Maíz jupbileo super dulce congelado|O|O||D||1
50443235|Maíz  confite korn congelado|O|O||D||1
50443236|Maíz  beso y acuso congelado|O|O||D||1
50443237|Maíz  lancelot congelado|O|O||D||1
50443238|Maíz dulce maple congelado|O|O||D||1
50443239|Maíz  medley congelado|O|O||D||1
50443240|Maíz merlin congelado|O|O||D||1
50443241|Maíz milagro congelado|O|O||D||1
50443242|Maíz nk – 199 congelado|O|O||D||1
50443243|Maíz durazno y crema congelado|O|O||D||1
50443244|Maíz blanco perla congelado|O|O||D||1
50443245|Maíz  pegasus congelado|O|O||D||1
50443246|Maíz  fenomenal congelado|O|O||D||1
50443247|Maíz  dama de platino congelado|O|O||D||1
50443248|Maíz  precioso congelado|O|O||D||1
50443249|Maíz   pristine congelado|O|O||D||1
50443250|Maíz  rápido congelado|O|O||D||1
50443251|Maíz  radiante congelado|O|O||D||1
50443252|Maíz  seneca brave congelado|O|O||D||1
50443253|Maíz  amanecer seneca congelado|O|O||D||1
50443254|Maíz  horizonte seneca congelado|O|O||D||1
50443255|Maíz  brillo de estrella seneca congelado|O|O||D||1
50443256|Maíz  noche blanca seneca congelado|O|O||D||1
50443257|Maíz  showcase congelado|O|O||D||1
50443258|Maíz  reina plateada congelado|O|O||D||1
50443259|Maíz  bella nieve congelado|O|O||D||1
50443260|Maíz nieve de primavera congelado|O|O||D||1
50443261|Maíz  premio de primavera congelado|O|O||D||1
50443262|Maíz  azúcar y oro congelado|O|O||D||1
50443263|Maíz rollo de azúcar congelado|O|O||D||1
50443264|Maíz nieve de azúcar congelado|O|O||D||1
50443265|Maíz baile de sol congelado|O|O||D||1
50443266|Maíz estrella tell congelado|O|O||D||1
50443267|Maíz terminador congelado|O|O||D||1
50443268|Maíz tesoro congelado|O|O||D||1
50443269|Maíz tuxedo congelado|O|O||D||1
50443300|Berros  congelados|O|O||D||1
50443301|Berros de tierra congelados|O|O||D||1
50443302|Nasturtium congelado|O|O||D||1
50443303|Berros de agua congelados|O|O||D||1
50443304|Berros de invierno congelados|O|O||D||1
50443400|Cocombros congelados|O|O||D||1|Pepinos cohombro congelados
50443401|Cocombro arena congelado|O|O||D||1|Pepino cohombro arena congelado
50443402|Cocombro americano congelado|O|O||D||1|Pepino cohombro americano congelado
50443403|Cocombro atena congelado|O|O||D||1|Pepino cohombro atena congelado
50443404|Cocombro blanco lungo de parigi congelado|O|O||D||1|Pepino cohombro blanco lungo de parigi congelado
50443405|Cocombro verde burpless buen sabor congelado|O|O||D||1|Pepino cohombro verde burpless buen sabor congelado
50443406|Cocombro chicago pickling congelado|O|O||D||1|Pepino cohombro chicago pickling congelado
50443407|Cocombro manzana cristal congelado|O|O||D||1|Pepino cohombro manzana cristal congelado
50443408|Cocombro limón cristal congelado|O|O||D||1|Pepino cohombro limón cristal congelado
50443409|Cocombro danimas congelado|O|O||D||1|Pepino cohombro danimas congelado
50443410|Cocombro gherkin congelado|O|O||D||1|Pepino cohombro gherkin congelado
50443411|Cocombro hokus congelado|O|O||D||1|Pepino cohombro hokus congelado
50443412|Cocombro japonés congelado|O|O||D||1|Pepino cohombro japonés congelado
50443413|Cocombro karela congelado|O|O||D||1|Pepino cohombro karela congelado
50443414|Cocombro korila congelado|O|O||D||1|Pepino cohombro korila congelado
50443415|Cocombro verde largo mejorado congelado|O|O||D||1|Pepino cohombro verde largo mejorado congelado
50443416|Cocombro mas mercado congelado|O|O||D||1|Pepino cohombro mas mercado congelado
50443417|Cocombro enano congelado|O|O||D||1|Pepino cohombro enano congelado
50443418|Cocombro pickling nacional congelado|O|O||D||1|Pepino cohombro pickling nacional congelado
50443419|Cocombro persa congelado|O|O||D||1|Pepino cohombro persa congelado
50443420|Cocombro telégrafo congelado|O|O||D||1|Pepino cohombro telégrafo congelado
50443421|Cocombro telégrafo mejorado congelado|O|O||D||1|Pepino cohombro telégrafo mejorado congelado
50443422|Cocombro vert de massy cornichon congelado|O|O||D||1|Pepino cohombro vert de massy cornichon congelado
50443423|Cocombro yamato congelado|O|O||D||1|Pepino cohombro yamato congelado
50443500|Berenjenas congeladas|O|O||D||1
50443501|Berenjena bambino congelada|O|O||D||1
50443502|Berenjena  belleza negra congelada|O|O||D||1
50443503|Berenjena  negra enorme congelada|O|O||D||1
50443504|Berenjena  chino congelada|O|O||D||1
50443505|Berenjena  huevo de pascua congelada|O|O||D||1
50443506|Berenjena  filipino congelada|O|O||D||1
50443507|Berenjena   mercado de florida congelada|O|O||D||1
50443508|Berenjena  india congelada|O|O||D||1
50443509|Berenjena  italiano congelada|O|O||D||1
50443510|Berenjena  japonés congelada|O|O||D||1
50443511|Berenjena  morado largo congelada|O|O||D||1
50443512|Berenjena   rayas larga congelada|O|O||D||1
50443513|Berenjena  mercado de dinero congelada|O|O||D||1
50443514|Berenjena  ova congelada|O|O||D||1
50443515|Berenjena   arveja congelada|O|O||D||1
50443516|Berenjena  tom bajito congelada|O|O||D||1
50443517|Berenjena  siciliano congelada|O|O||D||1
50443518|Berenjena  tailandés congelada|O|O||D||1
50443519|Berenjena  violeta de florencia congelada|O|O||D||1
50443520|Berenjena  blanco congelada|O|O||D||1
50443600|Endivias congeladas|O|O||D||1
50443601|Endivias witloof de brucelas congeladas|O|O||D||1
50443602|Endivias francocastel congeladas|O|O||D||1
50443603|Endivias catalogna de galantina congeladas|O|O||D||1
50443604|Endivias chioggia congeladas|O|O||D||1
50443605|Endivias grumolo verde congeladas|O|O||D||1
50443606|Endivias raíz larga magdeburg congeladas|O|O||D||1
50443607|Endivias palla rosa zorzi precoce congeladas|O|O||D||1
50443608|Endivias radice amare congeladas|O|O||D||1
50443609|Endivias rosa de traviso congeladas|O|O||D||1
50443610|Endivias  rosa de verona congeladas|O|O||D||1
50443611|Endivias soncino congeladas|O|O||D||1
50443612|Endivias sugarthi congeladas|O|O||D||1
50443613|Endivias verona congeladas|O|O||D||1
50443614|Endivias witloof zoom congeladas|O|O||D||1
50443700|Hinojos congelados|O|O||D||1
50443701|Hinojo cantino congelado|O|O||D||1
50443702|Hinojo fino congelado|O|O||D||1
50443703|Hinojoherald congelado|O|O||D||1
50443704|Hinojo perfección congelado|O|O||D||1
50443705|Hinojo sirio congelado|O|O||D||1
50443706|Hinojo florencia dulce congelado|O|O||D||1
50443707|Hinojo tardo congelado|O|O||D||1
50443800|Ajos congelados|O|O||D||1
50443801|Ajo tarde california congelado|O|O||D||1
50443802|Ajo tallos chinos congelado|O|O||D||1
50443803|Ajo cebollin  congelado|O|O||D||1
50443804|Ajo germidor congelado|O|O||D||1
50443805|Ajo guardado largo congelado|O|O||D||1
50443806|Ajo ramson congelado|O|O||D||1
50443807|Ajo rocambola congelado|O|O||D||1
50443808|Ajo rosa de lautrec congelado|O|O||D||1
50443809|Ajo solent blanco congelado|O|O||D||1
50443810|Ajo morado español congelado|O|O||D||1
50443811|Ajo valentina italiana congelado|O|O||D||1
50443900|Calabazas congeladas|O|O||D||1
50443901|Petula congelada|O|O||D||1|Luffa congelada
50443902|Melon amargo congelado|O|O||D||1
50443903|Botella calabaza congelada|O|O||D||1|Mate congelado
50443904|Calabash gounds congelada|O|O||D||1|Calabaza de peregrino congelada
50443905|Melón peludo congelado|O|O||D||1
50443906|Calabaza amarga congelada|O|O||D||1
50443907|Loofah suave congelado|O|O||D||1|Zapatillo suave congelado
50443908|Serpiente de calabaza congelada|O|O||D||1|Chichinda congelada
50443909|Calabaza larga amarga congelada|O|O||D||1
50443910|Calabaza tinda congelada|O|O||D||1
50443911|Calabaza tindoori congelada|O|O||D||1
50444000|Guisantes congeladas|O|O||D||1|Chícharos congelados
50444001|Guisante chino congelada|O|O||D||1|Chícharo chino congelado
50444002|Guisante inglés congelada|O|O||D||1|Chícharo inglés congelado
50444003|Guisante de jardín congelada|O|O||D||1|Chícharo de jardín congelado
50444004|Guisante nieve congelada|O|O||D||1|Chícharo nieve congelado
50444005|Guisante snap dulce congelada|O|O||D||1|Chícharo snap dulce congelado
50444100|Hierbas congeladas|O|O||D||1|Perejil congelado, Yerbabuena o hierbabuena congelada
50444101|Albahaca congelada|O|O||D||1
50444102|Laurel congelado|O|O||D||1
50444103|Borraja congelada|O|O||D||1
50444104|Alcaravea congelada|O|O||D||1
50444105|Perifollo congelado|O|O||D||1
50444106|Cilantro congelado|O|O||D||1
50444107|Chipolinos congelado|O|O||D||1
50444108|Hoja de curry congelada|O|O||D||1
50444109|Eneldo congelado|O|O||D||1
50444110|Epazote congelado|O|O||D||1
50444111|Fenogreco congelado|O|O||D||1
50444112|Limonaria congelada|O|O||D||1|Té de limón congelado
50444113|Mejorana congelada|O|O||D||1
50444114|Menta congelada|O|O||D||1
50444115|Orégano congelado|O|O||D||1
50444116|Pápalo congelado|O|O||D||1
50444117|Pápalo delgado congelado|O|O||D||1
50444118|Perilla congelada|O|O||D||1|Albahaca japonesa congelada
50444119|Recao  congelado|O|O||D||1
50444120|Romero congelado|O|O||D||1
50444121|Salvia congelada|O|O||D||1
50444122|Salsifí congelada|O|O||D||1|Barba cabruna congelada
50444123|Satureja congelada|O|O||D||1|Ajedreas  congelada
50444124|Estragón congelado|O|O||D||1|Tarragón  congelado
50444125|Tomillo congelado|O|O||D||1
50444126|Tumeric congelado|O|O||D||1|Cúrcuma congelada
50444127|Verdolaga congelada|O|O||D||1
50444200|Coles congeladas|O|O||D||1
50444201|Col rizada congelada|O|O||D||1
50444202|Repollo verde congelado|O|O||D||1
50444300|Colinabos congelados|O|O||D||1|Colirrábanos congelados
50444301|Colinabo estrella azur congelado|O|O||D||1|Colirrábano estrella azur congelado
50444302|Colinabo verde viena congelado|O|O||D||1|Colirrábano verde viena congelado
50444303|Colinabo lanro congelado|O|O||D||1|Colirrábano lanro congelado
50444304|Colinabo viena morada congelado|O|O||D||1|Colirrábano viena morada congelado
50444305|Colinabo trero rowel congelado|O|O||D||1|Colirrábano trero rowel congelado
50444306|Colinabo viena blanca congelado|O|O||D||1|Colirrábano viena blanca congelado
50444400|Puerros congelados|O|O||D||1|Poros congelados
50444401|Puerro cobra gigante otoño congelado|O|O||D||1|Poro cobra gigante otoño congelado
50444402|Puerro otoño mamut 2 congelado|O|O||D||1|Poro otoño mamut 2 congelado
50444403|Puerro blue de solaise congelado|O|O||D||1|Poro blue de solaise congelado
50444404|Puerro cortina congelado|O|O||D||1|Poro cortina congelado
50444405|Puerro prelina congelado|O|O||D||1|Poro prelina congelado
50444406|Puerro salvaje congelado|O|O||D||1|Poro salvaje congelado
50444500|Lentejas  congeladas|O|O||D||1
50444501|Lenteja beluga congelada|O|O||D||1
50444502|Lenteja  verde francesa congelada|O|O||D||1
50444503|Lenteja verde congelada|O|O||D||1
50444504|Lenteja crimson pequeña congelada|O|O||D||1
50444505|Lenteja pardina española congelada|O|O||D||1
50444506|Lenteja roja separada congelada|O|O||D||1
50444507|Lenteja amarilla separad congelada|O|O||D||1
50444508|Lenteja tarahumara rosada congelada|O|O||D||1
50444600|Lechugas congeladas|O|O||D||1
50444601|Lechuga  bibb congelada|O|O||D||1
50444602|Lechuga  boston congelada|O|O||D||1
50444603|Lechuga frisee congelada|O|O||D||1
50444604|Lechuga rosa lola congelada|O|O||D||1
50444605|Lechuga  mixta masculina congelada|O|O||D||1
50444606|Lechuga mizuna congelada|O|O||D||1
50444607|Lechuga hoja roja congelada|O|O||D||1
50444608|Lechuga oja roja roble congelada|O|O||D||1
50444609|Lechuga romana ruby congelada|O|O||D||1
50444610|Lechuga romana bebé roja congelada|O|O||D||1
50444611|Lechuga cabeza de mantequilla congelada|O|O||D||1
50444612|Lechuga china congelada|O|O||D||1|Lechuga orejona congelada
50444613|Lechuga cabeza tostada congelada|O|O||D||1
50444614|Lechuga hoja verde congelada|O|O||D||1
50444615|Lechuga iceberg congelada|O|O||D||1
50444616|Lechuga cordero congelada|O|O||D||1
50444617|Lechuga hoja suelta congelada|O|O||D||1
50444618|Lechuga mache congelada|O|O||D||1
50444619|Lechuga boston roja congelada|O|O||D||1
50444620|Lechuga cabeza roja congelada|O|O||D||1
50444621|Lechuga romana congelada|O|O||D||1
50444622|Lechuga mostza roja rusa congelada|O|O||D||1
50444623|Lechuga tatsoi congelada|O|O||D||1
50444700|Ñames congelados|O|O||D||1
50444701|Ñame amarilla congelada|O|O||D||1
50444702|Ñame blanca congelada|O|O||D||1
50444703|Ñame coco congelada|O|O||D||1
50444704|Ñame eddoes congelada|O|O||D||1
50444705|Ñame isleña congelada|O|O||D||1
50444706|Ñame lila congelada|O|O||D||1
50444800|Hongos o champiñones congelados|O|O||D||1
50444801|Champiñón trompeta negra congelado|O|O||D||1
50444802|Champiñón carmelito congelado|O|O||D||1
50444803|Champiñón  congelado|O|O||D||1
50444804|Champiñón chanterelle congelado|O|O||D||1
50444805|Champiñón cremini congelado|O|O||D||1
50444806|Champiñón enoki congelado|O|O||D||1
50444807|Champiñón puercoespín congelado|O|O||D||1
50444808|Champiñón gallina del bosque congelado|O|O||D||1
50444809|Champiñón langosta congelado|O|O||D||1
50444810|Champiñón morels congelado|O|O||D||1
50444811|Champiñón ostra congelado|O|O||D||1
50444812|Champiñón pleurotus congelado|O|O||D||1
50444813|Champiñón pompom congelado|O|O||D||1
50444814|Champiñón porcieni congelado|O|O||D||1
50444815|Champiñón portobello congelado|O|O||D||1
50444816|Champiñón shitake congelado|O|O||D||1
50444817|Champiñón shimeji congelado|O|O||D||1
50444818|Champiñón san jorge congelado|O|O||D||1
50444819|Champiñón blanco congelado|O|O||D||1
50444820|Champiñón tompeta blanca congelado|O|O||D||1
50444821|Champiñón woodear congelado|O|O||D||1
50444900|Mostazas congeladas|O|O||D||1
50444901|Mostaza bambú  congelada|O|O||D||1
50444902|Mostaza ajo congelada|O|O||D||1
50444903|Mostaza hoja gigante congelada|O|O||D||1
50444904|Mostaza rojo en nieve congelada|O|O||D||1
50444905|Mostaza sureño congelada|O|O||D||1
50444906|Mostaza corazón envuelto congelada|O|O||D||1
50445000|Solanáceas (nightshades) congeladas|O|O||D||1
50445001|Lámpara china congelada|O|O||D||1
50445002|Mora de jardín|O|O||D||1
50445003|Naranjilla congeladas|O|O||D||1
50445004|Tomatillo congelada|O|O||D||1
50445100|Okras congeladas|O|O||D||1
50445101|Okra artista congelada|O|O||D||1
50445102|Okra vinotinto congelada|O|O||D||1
50445103|Okra sin columna clemson congelada|O|O||D||1
50445104|Okra verde enano vaina larga congelada|O|O||D||1
50445105|Okra  mamut sin columna congelada|O|O||D||1
50445106|Okra terciopelo rojo congelada|O|O||D||1
50445107|Okra estrella de david reliquia congelada|O|O||D||1
50445200|Cebollas congeladas|O|O||D||1
50445201|Cebolla albion congelada|O|O||D||1
50445202|Cebolla alisia craig congelada|O|O||D||1
50445203|Cebolla hirviendo congelada|O|O||D||1
50445204|Cebolla bufalo congelada|O|O||D||1
50445205|Cebolla bulbo congelada|O|O||D||1
50445206|Cebolla cremosa congelada|O|O||D||1
50445207|Cebolla amarillo expreso o – x congelada|O|O||D||1
50445208|Cebolla kelsae congelada|O|O||D||1
50445209|Cebolla gigante marshal globo fen congelada|O|O||D||1
50445210|Cebolla perla congelada|O|O||D||1
50445211|Cebolla baron rojo congelada|O|O||D||1
50445212|Cebolla roja congelada|O|O||D||1|Cebolla morada congelada
50445213|Cebolla rijnsberger congelada|O|O||D||1
50445214|Cebolla senshyu semi – globo amarillo congelada|O|O||D||1
50445215|Cebolla sturon congelada|O|O||D||1
50445216|Cebolla sturgatter congelada|O|O||D||1
50445217|Cebolla dulce congelada|O|O||D||1
50445218|Cebolla torpedo o rojo italiana congelada|O|O||D||1
50445219|Cebolla roja guardada congelada|O|O||D||1
50445220|Cebolla blanca guardada congelada|O|O||D||1
50445221|Cebolla amarilla guardada congelada|O|O||D||1
50445300|Maníes congelados|O|O||D||1|Cacahuates congelados
50445301|Maní bambara congelado|O|O||D||1|Cacahuate bambara congelado
50445302|Maní florunner congelado|O|O||D||1|Cacahuate florunner congelado
50445303|Maní husa / kerstings congelado|O|O||D||1|Cacahuate husa / kerstings  congelado
50445304|Maní español congelado|O|O||D||1|Cacahuate español congelado
50445305|Maní valencia congelado|O|O||D||1|Cacahuate valencia congelado
50445306|Maní virginia congelado|O|O||D||1|Cacahuate virginia congelado
50445400|Alverjas congeladas|O|O||D||1|Alberjones congelados
50445401|Alverja casco morado congelada|O|O||D||1|Alberjón casco morado congelado
50445402|Alverja pinkeye congelada|O|O||D||1|Alberjón pinkeye congelado
50445403|Alverja crowder congelada|O|O||D||1|Alberjón crowder congelado
50445404|Alverja acre blanco congelada|O|O||D||1|Alberjón acre blanco congelado
50445405|Alverja ojo negro congelada|O|O||D||1|Alberjón ojo negro congelado
50445406|Alverja crema zipper congelada|O|O||D||1|Alberjón crema zipper congelado
50445500|Pimientos congelados|O|O||D||1|Chiles congelados
50445501|Pimentón ají congelado|O|O||D||1|Ají congelado
50445502|Pimentón  árbol congelado|O|O||D||1|Chile de árbol congelado
50445503|Pimentón queso congelado|O|O||D||1
50445504|Pimentón chilaca congelado|O|O||D||1|Chilaca congelado
50445505|Pimentón cubanelles congelado|O|O||D||1|Chile cubanelle o pimienta italiana congelada
50445506|Pimentón fresno congelado|O|O||D||1|Chile fresno congelado
50445507|Pimentón kapia congelado|O|O||D||1|Chile kapia congelado
50445508|Pimentón coreano congelado|O|O||D||1|Chile cheongyang congelado
50445509|Pimentón manzano congelado|O|O||D||1|Chile manzano o de cera congelado
50445510|Pimentón melrose congelado|O|O||D||1
50445511|Pimentón chile amarillo congelado|O|O||D||1|Chile peruano amarillo congelado
50445512|Pimentón aji dulce congelado|O|O||D||1|Ají dulce congelado
50445513|Pimentón anaheim congelado|O|O||D||1
50445514|Pimentón ancho congelado|O|O||D||1|Chile ancho o mulato congelado
50445515|Pimentón campana congelado|O|O||D||1|Chile campana congelado
50445516|Pimentón cascabel congelado|O|O||D||1|Chile cascabel congelado
50445517|Pimentón cayenne congelado|O|O||D||1|Pimienta de Cayena o roja congelada
50445518|Pimentón anfitrión cereza congelado|O|O||D||1
50445519|Pimentón chitespin congelado|O|O||D||1|Chile chiltepín congelado
50445520|Pimentón dedo picante congelado|O|O||D||1|Chile Jwala congelado
50445521|Pimentón guajillo congelado|O|O||D||1|Chile guajillo congelado
50445522|Pimentón guerro congelado|O|O||D||1|Chile güero congelado
50445523|Pimentón habanero congelado|O|O||D||1|Chile habanero congelado
50445524|Pimentón cera de hungria congelado|O|O||D||1|Pimentón húngaro congelado
50445525|Pimentón jalapeño congelado|O|O||D||1|Chile cuaresmeño congelado, Chile jalapeño, seco es chipotle o morita congelado
50445526|Pimentón picante largo congelado|O|O||D||1|Chile cola de rata congelado
50445527|Pimentón marasol congelado|O|O||D||1|Chile mirasol congelado
50445528|Pimentón pasilla congelado|O|O||D||1|Chile pasilla congelado
50445529|Pimentón peperoncini congelado|O|O||D||1
50445530|Pimentón pequin congelado|O|O||D||1|Chile piquín congelado
50445531|Pimentón pimiento congelado|O|O||D||1|Pimiento morrón congelado
50445532|Pimentón poblano congelado|O|O||D||1|Chile poblano congelado
50445533|Pimentón scotch bonnet congelado|O|O||D||1|Pimientos Bonney o rojos Caribe congelado
50445534|Pimentón serrano congelado|O|O||D||1|Chile serrano congelado, Chile verde congelado
50445535|Pimentón tabasco congelado|O|O||D||1|Chile tabasco congelado
50445536|Pimentón tai  congelado|O|O||D||1|Chile ojo de pájaro congelado
50445537|Pimentón tepin congelado|O|O||D||1|Chile mosquito o catarina congelado
50445600|Papas congeladas|O|O||D||1
50445601|Papa blanca larga congelada|O|O||D||1
50445602|Papa redonda blanca congelada|O|O||D||1
50445603|Papa redonda roja congelada|O|O||D||1|Papa de cambray congelada
50445604|Papa  russet congelada|O|O||D||1
50445605|Papa morada congelada|O|O||D||1
50445606|Papa amarilla congelada|O|O||D||1
50445607|Papa nueva congelada|O|O||D||1
50445608|Papa especial congelada|O|O||D||1
50445609|Papa coctel congelada|O|O||D||1
50445610|Papa peruanita congelada|O|O||D||1
50445611|Papa huayro congelada|O|O||D||1
50445700|Nabos suecos congelados|O|O||D||1
50445701|Nabo sueco acme congelado|O|O||D||1
50445702|Nabo sueco angela congelado|O|O||D||1
50445703|Nabo sueco el mejor congelado|O|O||D||1
50445704|Nabo sueco marian congelado|O|O||D||1
50445800|Vegetales marinos congelados|O|O||D||1
50445801|Agar-agar congelado|O|O||D||1
50445802|Arame  congelada|O|O||D||1
50445803|Alga dulce congelada|O|O||D||1
50445804|Habichuelas vert de mer congelada|O|O||D||1
50445805|Hijiki congelada|O|O||D||1
50445806|Musgo irlandés congelada|O|O||D||1
50445807|Quelpo congelado|O|O||D||1
50445808|Laver congelado|O|O||D||1
50445809|Nori congelado|O|O||D||1
50445810|Alga roja congelada|O|O||D||1
50445811|Kale de mar congelada|O|O||D||1
50445812|Lechuga de mar congelada|O|O||D||1
50445813|Algas de mar congelada|O|O||D||1
50445814|Spirulina congelada|O|O||D||1
50445815|Susabi nuri congelada|O|O||D||1
50445816|Wakame congelada|O|O||D||1
50445900|Chalotes congelados|O|O||D||1
50445901|Chalote atlántica congelado|O|O||D||1
50445902|Chalote creación congelado|O|O||D||1
50445903|Chalote drittler nido blanco congelado|O|O||D||1
50445904|Chalote gigante mejorado amarillo congelado|O|O||D||1
50445905|Chalote gourmet dorado congelado|O|O||D||1
50445906|Chalote grise de bagnolet congelado|O|O||D||1
50445907|Chalote hative de niort congelado|O|O||D||1
50445908|Chalote pikant congelado|O|O||D||1
50445909|Chalote papa roja congelado|O|O||D||1
50445910|Chalote sante congelado|O|O||D||1
50445911|Chalote topper congelado|O|O||D||1
50446000|Alazanes congelados|O|O||D||1|Acederas congeladas
50446001|Alazán dock congelada|O|O||D||1|Acedera dock congelada
50446002|Alazán jardín congelada|O|O||D||1|Acedera jardín congelada
50446003|Alazán oveja congelada|O|O||D||1|Acedera oveja congelada
50446004|Alazán madera congelada|O|O||D||1|Acedera madera congelada
50446100|Espinacas congeladas|O|O||D||1
50446101|Espinaca americana congelada|O|O||D||1
50446102|Espinaca bloomsdale congelada|O|O||D||1
50446103|Espinaca invierno gigante congelada|O|O||D||1
50446104|Espinaca horenso congelada|O|O||D||1
50446105|Espinaca planta de hielo congelada|O|O||D||1
50446106|Espinaca  cuarto de cordero congelada|O|O||D||1
50446107|Espinaca malabra congelada|O|O||D||1
50446108|Espinaca mendania congelada|O|O||D||1
50446109|Espinaca nueva zelandia congelada|O|O||D||1
50446110|Espinaca orach congelada|O|O||D||1
50446111|Espinaca savoy congelada|O|O||D||1
50446112|Espinaca hoja de sigma congelada|O|O||D||1
50446113|Espinaca espacio congelada|O|O||D||1
50446114|Espinaca trinidad congelada|O|O||D||1
50446115|Espinaca agua congelada|O|O||D||1
50446116|Espinaca de agua sesa|O|O||D||1
50446200|Calabazas congeladas|O|O||D||1
50446201|Calabaza boston congelada|O|O||D||1
50446202|Calabaza buttemut congelada|O|O||D||1
50446203|Calabaza costata romanesca congelada|O|O||D||1
50446204|Calabaza crookneck congelada|O|O||D||1
50446205|Calabaza  cucuzza congelada|O|O||D||1
50446206|Calabaza  delicata congelada|O|O||D||1
50446207|Calabaza  delisioso congelada|O|O||D||1
50446208|Calabaza verano dorado cuello torcido congelada|O|O||D||1
50446209|Calabaza prolífico temprano cuello recto congelada|O|O||D||1
50446210|Calabaza  oro congelada|O|O||D||1
50446211|Calabaza  jack pequeño congelada|O|O||D||1
50446212|Calabaza  campo de kentucky congelada|O|O||D||1
50446213|Calabaza marrow congelada|O|O||D||1
50446214|Calabaza  medio oriente congelada|O|O||D||1
50446215|Calabaza  miniatura congelada|O|O||D||1
50446216|Calabaza  orangetti congelada|O|O||D||1
50446217|Calabaza pattypan congelada|O|O||D||1
50446218|Calabaza  rondini congelada|O|O||D||1
50446219|Calabaza  redonda congelada|O|O||D||1
50446220|Calabaza  espagueti congelada|O|O||D||1
50446221|Calabaza  estripeti congelada|O|O||D||1
50446222|Calabaza  molde dulce congelada|O|O||D||1
50446223|Calabaza  empanada dulce congelada|O|O||D||1
50446224|Calabaza  premio triple  congelada|O|O||D||1
50446225|Calabaza waltham butternut congelada|O|O||D||1
50446226|Calabaza  arbusto scallop amarillo congelada|O|O||D||1
50446227|Calabaza cuello recto amarillo congelada|O|O||D||1
50446228|Calabaza zafiro congelada|O|O||D||1
50446229|Calabaza zucchini congelada|O|O||D||1
50446300|Batatas congeladas|O|O||D||1|Camotes congelados
50446301|Batata beauregard congelada|O|O||D||1|Camote beauregard congelado
50446302|Batata centennial congelada|O|O||D||1|Camote centennial congelado
50446303|Batata diane congelada|O|O||D||1|Camote diane congelado
50446304|Batata dulce garnet congelada|O|O||D||1|Camote dulce garnet congelado
50446305|Batata georgia dulce rojo congelada|O|O||D||1|Camote georgia dulce rojo congelado
50446306|Batata  dorado congelada|O|O||D||1|Camote dorado congelado
50446307|Batata hanna  congelada|O|O||D||1|Camote hanna congelado
50446308|Batata japonés congelada|O|O||D||1|Camote japonés congelado
50446309|Batata jersey congelada|O|O||D||1|Camote jersey congelado
50446310|Batata joya congelada|O|O||D||1|Camote joya congelado
50446311|Batata meryland roja congelada|O|O||D||1|Camote meryland roja congelado
50446312|Batata nema dorado congelada|O|O||D||1|Camote nema dorado congelado
50446313|Batata o´henry congelada|O|O||D||1|Camote o´henry congelado
50446314|Batata okinawan congelada|O|O||D||1|Camote okinawan congelado
50446315|Batata naranja congelada|O|O||D||1|Camote naranja congelado
50446316|Batata oriental congelada|O|O||D||1|Camote oriental congelado
50446317|Batata jersey rojo congelada|O|O||D||1|Camote jersey rojo congelado
50446318|Batata mar rojo congelada|O|O||D||1|Camote mar rojo congelado
50446319|Batata brillo rojo congelada|O|O||D||1|Camote brillo rojo congelado
50446320|Batata jersey amarillo congelada|O|O||D||1|Camote jersey amarillo congelado
50446321|Batata morada congelada|O|O||D||1|Camote morada congelado
50446400|Tomates congelados|O|O||D||1|Jitomates congelados
50446401|Tomates ailsa craig congelado|O|O||D||1|Jitomate ailsa craig congelado
50446402|Tomates alicante congelado|O|O||D||1|Jitomate alicante congelado
50446403|Tomates ciruela negra congelado|O|O||D||1|Jitomate ciruela negra congelado
50446404|Tomates vino de brandy congelado|O|O||D||1|Jitomate vino de brandy congelado
50446405|Tomates bella cereza congelado|O|O||D||1|Jitomate bella cereza congelado
50446406|Tomates cereza congelado|O|O||D||1|Jitomate cereza congelado
50446407|Tomates delicioso congelado|O|O||D||1|Jitomate delicioso congelado
50446408|Tomates dombito congelado|O|O||D||1|Jitomate dombito congelado
50446409|Tomates delicia del jardín congelado|O|O||D||1|Jitomate delicia del jardín congelado
50446410|Tomates uva congelado|O|O||D||1|Jitomate uva congelado
50446411|Tomates verde congelado|O|O||D||1|Tomate verde congelado
50446412|Tomates super marmande congelado|O|O||D||1|Jitomate super marmande congelado
50446413|Tomates rayas naturales marvel congelado|O|O||D||1|Jitomate rayas naturales marvel congelado
50446414|Tomates minibel congelado|O|O||D||1|Jitomate minibel congelado
50446415|Tomates oaxacan congelado|O|O||D||1|Jitomate oaxaca congelado
50446416|Tomates alerta roja congelado|O|O||D||1|Jitomate alerta roja congelado
50446417|Tomates roma vf congelado|O|O||D||1|Jitomate roma vf congelado
50446418|Tomates marzano zan congelado|O|O||D||1|Jitomate marzano zan congelado
50446419|Tomates shirley congelado|O|O||D||1|Jitomate shirley congelado
50446420|Tomates siberia congelado|O|O||D||1|Jitomate siberia congelado
50446421|Tomates super beefsteak congelado|O|O||D||1|Jitomate super beefsteak congelado
50446422|Tomates tigerella congelado|O|O||D||1|Jitomate tigerella congelado
50446423|Tomates tiny tim congelado|O|O||D||1|Jitomate tiny tim congelado
50446424|Tomates tumbler congelado|O|O||D||1|Jitomate tumbler congelado
50446425|Tomates cocktail amarillo congelado|O|O||D||1
50446426|Tomates forma de pera amarillo congelado|O|O||D||1
50446427|Tomates perfección amarilla congelado|O|O||D||1
50446500|Nabos congelados|O|O||D||1
50446501|Nabo globo verde congelado|O|O||D||1
50446502|Nabo bola dorada congelado|O|O||D||1
50446503|Nabo mercado de manchester congelado|O|O||D||1
50446504|Nabo top morado milan congelado|O|O||D||1
50446505|Nabo top morado blanco congelado|O|O||D||1
50446506|Nabo bola de nieve congelado|O|O||D||1
50446507|Nabo tokio congelado|O|O||D||1
50446508|Nabo cruz de tokio congelado|O|O||D||1
50446600|Auyamas congeladas|O|O||D||1|Calabazas gigantes congeladas
50446601|Calabaza acorn congelada|O|O||D||1|Calabaza gigante acorn congelada
50446602|Calabaza gigante atlántico congelada|O|O||D||1|Calabaza gigante atlántico congelada
50446603|Calabaza banana rosado congelada|O|O||D||1|Calabaza gigante banana rosado congelada
50446604|Calabaza max grande congelada|O|O||D||1|Calabaza gigante max congelada
50446605|Calabaza  congelada|O|O||D||1|Calabaza de castilla congelada
50446606|Calabaza carnaval congelada|O|O||D||1|Calabaza gigante carnaval congelada
50446607|Auyama queso congelada|O|O||D||1|Calabaza gigante queso congelada
50446608|Calabaza príncipe coronado congelada|O|O||D||1|Calabaza gigante príncipe coronado congelada
50446609|Calabaza  curcibita congelada|O|O||D||1|Calabaza gigante curcibita congelada
50446610|Calabaza cushaw congelada|O|O||D||1|Calabaza gigante cushaw congelada
50446611|Calabaza  gigante auyama congelada|O|O||D||1
50446612|Calabaza  hubbard congelada|O|O||D||1|Calabaza gigante hubbard congelada
50446613|Calabaza  jerrahdale congelada|O|O||D||1|Calabaza gigante jerrahdale congelada
50446614|Calabaza  kabocha congelada|O|O||D||1|Calabaza gigante kabocha congelada
50446615|Calabaza queensland azul congelada|O|O||D||1|Calabaza gigante queensland azul congelada
50446616|Calabaza rouge vif détampes congelada|O|O||D||1|Calabaza gigante rouge vif détampes congelada
50446617|Calabaza  turban turco congelada|O|O||D||1|Calabaza gigante turban turco congelada
50446618|Calabaza  valenciano congelada|O|O||D||1|Calabaza gigante valenciano congelada
50446619|Calabaza  warted hubbard congelada|O|O||D||1|Calabaza gigante warted hubbard congelada
50446620|Auyama whangaparoa congelada|O|O||D||1|Calabaza gigante whangaparoa congelada
50446700|Ñames congelados|O|O||D||1
50446701|Ñame agria africana congelada|O|O||D||1
50446702|Ñame agria asiática congelada|O|O||D||1
50446703|Ñame china congelado|O|O||D||1
50446704|Ñame globo congelado|O|O||D||1
50446705|Ñame grater congelado|O|O||D||1
50446706|Ñame japonesa congelado|O|O||D||1
50446707|Ñame lesser congelado|O|O||D||1
50446708|Ñame papa congelado|O|O||D||1
50446709|Ñame guinea blanca congelado|O|O||D||1
50446710|Ñame guinea amarillo congelado|O|O||D||1
50446800|Vegetales Nominant congelados|O|O||D||1|Vegetales predominantes congelados, Nopal congelado
50446801|Alfalfa congelada|O|O||D||1
50446802|Hojas de aloe congelada|O|O||D||1|Hoja de sábila congelada, Penca de sábila congelada
50446803|Apio congelado|O|O||D||1
50446804|Arrurruz congelada|O|O||D||1
50446805|Punta de flecha congelada|O|O||D||1|Sagittaria congelada
50446806|rúcula congelada|O|O||D||1
50446807|Arum congelada|O|O||D||1|Taro congelado
50446808|Raíz de bambú congelada|O|O||D||1
50446809|Hojas de plátano congelada|O|O||D||1
50446810|Batatas congelada|O|O||D||1
50446811|Brotes de frijol congelados|O|O||D||1
50446812|Top de remolacha congelada|O|O||D||1|Betabel congelado
50446813|Melón agrio congelado|O|O||D||1|Balsamina congelada
50446814|Bayas de alcaparra congeladas|O|O||D||1
50446815|Carob congelado|O|O||D||1|Algarrobo congelado
50446816|Cha-om congelado|O|O||D||1
50446817|Chayote o guatila congelado|O|O||D||1
50446818|Garbanzo congelado|O|O||D||1
50446819|Verde de crisantemos congelado|O|O||D||1
50446820|Verde de diente de león congelado|O|O||D||1
50446821|Diente de león congelado|O|O||D||1
50446822|Dasheen congelado|O|O||D||1
50446823|Puntas de alverja congelado|O|O||D||1
50446824|Diakon congelado|O|O||D||1|Rábano congelado
50446825|Donqua congelada|O|O||D||1|Ginseng hembra congelada
50446826|Helecho congelado|O|O||D||1|Brotes de helecho congelado
50446827|Gai choi congelado|O|O||D||1|Mostaza castaña congelada
50446828|Gailon congelado|O|O||D||1|Brécol chino congelado
50446829|Galanga congelada|O|O||D||1|Jengibre azul congelado
50446830|Raíz de jengibre congelada|O|O||D||1
50446831|Gobo congelado|O|O||D||1|Garduña congelada
50446832|Brote de lúpulo congelado|O|O||D||1
50446833|Rabano blanco congelado|O|O||D||1|Rábano de caballo congelado
50446834|Jicama congelada|O|O||D||1
50446835|Kuduz congelada|O|O||D||1|Kudzu congelado
50446836|Bulbo de margarita congelado|O|O||D||1|Bulbo de lili chino congelado
50446837|Linkok congelado|O|O||D||1
50446838|Lo bok congelado|O|O||D||1
50446839|Frijol largo congelado|O|O||D||1|Fríjol serpiente congelado
50446840|Raíz de lotus congelado|O|O||D||1|Rosa del Nilo congelada
50446841|Hojas de maguey congelada|O|O||D||1|Hoja de agave congelada, Penca de maguey congelada
50446842|Mallows congelado|O|O||D||1|Malva congelada
50446843|Sapote mamey congelado|O|O||D||1|Mamey congelada
50446844|Moap congelado|O|O||D||1
50446845|Moo congelado|O|O||D||1
50446846|Moqua congelada|O|O||D||1
50446847|Opos congelados|O|O||D||1
50446848|Corazon de palma congelado|O|O||D||1|Palmito congelado
50446849|Paprika congelada|O|O||D||1
50446850|Purslane congelada|O|O||D||1|Verdolaga congelada
50446851|Raddichios congelada|O|O||D||1|Achicoria morada congelada
50446852|Sinquas congelada|O|O||D||1|Zapallo congelado
50446853|Frijol de soya congelados|O|O||D||1
50446854|Spoonwart congelado|O|O||D||1|Hierba del escorbuto congelada
50446855|Uva tassele hyacinth congelado|O|O||D||1
50446856|Taro congelado|O|O||D||1|Tales congelada
50446857|Hoja de taro congelada|O|O||D||1
50446858|Tallo de taro congelado|O|O||D||1
50446859|Tapeguaje congelado|O|O||D||1
50446860|Verde tierno congelado|O|O||D||1
50446861|Tindora congelado|O|O||D||1
50446862|Árbol de cebolla congelado|O|O||D||1|Cebollas egipcias congelada
50446863|Udo congelado|O|O||D||1
50446864|Agua castaño congelado|O|O||D||1|Castaña de agua china congelada
50446865|Yumpi congelado|O|O||D||1|Akankong congelado
50446866|Yautia congelado|O|O||D||1|Mapuey congelado
50446867|Yu choy congelado|O|O||D||1
50446868|Yuca congelada|O|O||D||1
50446900|Alverjas dulces congeladas|O|O||D||1|Chícharos congelados
50446901|Alverja biquini congelada|O|O||D||1|Chícharo biquini congelado
50446902|Alverja cavalier congelada|O|O||D||1|Chícharo cavalier congelado
50446903|Alverja margarita congelada|O|O||D||1|Chícharo margarita congelado
50446904|Alverja dar fon congelada|O|O||D||1|Chícharo dar fon congelado
50446905|Alverja "early onward" congelada|O|O||D||1|Chícharo "early onward" congelado
50446906|Alverja primer feltham congelada|O|O||D||1|Chícharo primer feltham congelado
50446907|Alverja verde hurst shaft congelada|O|O||D||1|Chícharo verde hurst shaft congelado
50446908|Guisante oregón sugar pod congelada|O|O||D||1|Chícharo oregón sugar pod congelado
50446909|Alverja príncipe alberto congelada|O|O||D||1|Chícharo príncipe alberto congelado
50446910|Alverja reuzensuiker congelada|O|O||D||1|Chícharo reuzensuiker congelado
50451500|Alcachofas orgánicas congeladas|O|O||D||1
50451501|Alcachofa brittany orgánica congelada|O|O||D||1
50451502|Alcachofa cantonesa orgánica congelada|O|O||D||1
50451503|Alcachofa francesa orgánica congelada|O|O||D||1
50451504|Alcachofa globo verde orgánica congelada|O|O||D||1
50451505|Alcachofa gros camus de bretaña orgánica congelada|O|O||D||1
50451506|Alcachofa midi orgánica congelada|O|O||D||1
50451507|Alcachofa globo morado orgánica congelada|O|O||D||1
50451508|Alcachofa morado cecilia orgánica congelada|O|O||D||1
50451509|Alcachofa romanesco orgánica congelada|O|O||D||1
50451510|Alcachofa espinoso sardo orgánica congelada|O|O||D||1
50451511|Alcachofa vert de laon orgánica congelada|O|O||D||1
50451512|Alcachofa violeta de chiggiia orgánica congelada|O|O||D||1
50451513|Alcachofa violeta de toscana orgánica congelada|O|O||D||1
50451600|Espárragos orgánicos congelados|O|O||D||1
50451601|Espárragos connovers colosal orgánicos congelados|O|O||D||1
50451602|Espárragos franklin orgánicos congelados|O|O||D||1
50451603|Espárragos mamut gigante orgánicos congelados|O|O||D||1
50451604|Espárragos lucullus orgánicos congelados|O|O||D||1
50451605|Espárragos martha washington orgánicos congelados|O|O||D||1
50451700|Aguacates orgánicos congelados|O|O||D||1
50451701|Aguacate ajax b – 7 orgánico congelado|O|O||D||1
50451702|Aguacate arue orgánico congelado|O|O||D||1
50451703|Aguacate bacon orgánico congelado|O|O||D||1
50451704|Aguacate benik orgánico congelado|O|O||D||1
50451705|Aguacate bernecker orgánico congelado|O|O||D||1
50451706|Aguacate beta orgánico congelado|O|O||D||1
50451707|Aguacate biondo orgánico congelado|O|O||D||1
50451708|Aguacate príncipe negro orgánico congelado|O|O||D||1
50451709|Aguacate blair orgánico congelado|O|O||D||1
50451710|Aguacate blair cabina orgánico congelado|O|O||D||1
50451711|Aguacate cabina 1 orgánico congelado|O|O||D||1
50451712|Aguacate cabina 3 orgánico congelado|O|O||D||1
50451713|Aguacate cabina 5 orgánico congelado|O|O||D||1
50451714|Aguacate cabina 7 orgánico congelado|O|O||D||1
50451715|Aguacate cabina 8 orgánico congelado|O|O||D||1
50451716|Aguacate brooks 1978 orgánico congelado|O|O||D||1
50451717|Aguacate brookslate orgánico congelado|O|O||D||1
50451718|Aguacate california haas orgánico congelado|O|O||D||1
50451719|Aguacate catalina orgánico congelado|O|O||D||1
50451720|Aguacate chica orgánico congelado|O|O||D||1
50451721|Aguacate choquette orgánico congelado|O|O||D||1
50451722|Aguacate cristina orgánico congelado|O|O||D||1
50451723|Aguacate collison orgánico congelado|O|O||D||1
50451724|Aguacate donnie orgánico congelado|O|O||D||1
50451725|Aguacate dr dupis numero 2 orgánico congelado|O|O||D||1
50451726|Aguacate dr. dupie  orgánico congelado|O|O||D||1
50451727|Aguacate ettinger orgánico congelado|O|O||D||1
50451728|Aguacate fuch orgánico congelado|O|O||D||1
50451729|Aguacate fuch gwen orgánico congelado|O|O||D||1
50451730|Aguacate fuerte orgánico congelado|O|O||D||1
50451731|Aguacate gotham orgánico congelado|O|O||D||1
50451732|Aguacate gossman orgánico congelado|O|O||D||1
50451733|Aguacate guatemala sin pepa orgánico congelado|O|O||D||1
50451734|Aguacate hall orgánico congelado|O|O||D||1
50451735|Aguacate hardee orgánico congelado|O|O||D||1
50451736|Aguacate haas orgánico congelado|O|O||D||1
50451737|Aguacate herman orgánico congelado|O|O||D||1
50451738|Aguacate hickson orgánico congelado|O|O||D||1
50451739|Aguacate k-5 orgánico congelado|O|O||D||1
50451740|Aguacate k- 9 orgánico congelado|O|O||D||1
50451741|Aguacate cordero haas orgánico congelado|O|O||D||1
50451742|Aguacate leona orgánico congelado|O|O||D||1
50451743|Aguacate leona linda orgánico congelado|O|O||D||1
50451744|Aguacate lisa p orgánico congelado|O|O||D||1
50451745|Aguacate lisa loretta orgánico congelado|O|O||D||1
50451746|Aguacate loretta orgánico congelado|O|O||D||1
50451747|Aguacate lula orgánico congelado|O|O||D||1
50451748|Aguacate lula mascarthur orgánico congelado|O|O||D||1
50451749|Aguacate marcus orgánico congelado|O|O||D||1
50451750|Aguacate melendez orgánico congelado|O|O||D||1
50451751|Aguacate meya orgánico congelado|O|O||D||1
50451752|Aguacate miguel p orgánico congelado|O|O||D||1
50451753|Aguacate monroe orgánico congelado|O|O||D||1
50451754|Aguacate murrieta verde orgánico congelado|O|O||D||1
50451755|Aguacate nabal orgánico congelado|O|O||D||1
50451756|Aguacate nadir orgánico congelado|O|O||D||1
50451757|Aguacate nesbitt orgánico congelado|O|O||D||1
50451758|Aguacate peterson orgánico congelado|O|O||D||1
50451759|Aguacate pinelli orgánico congelado|O|O||D||1
50451760|Aguacate pinkerton orgánico congelado|O|O||D||1
50451761|Aguacate pollock orgánico congelado|O|O||D||1
50451762|Aguacate puebla orgánico congelado|O|O||D||1
50451763|Aguacate reed orgánico congelado|O|O||D||1
50451764|Aguacaterue orgánico congelado|O|O||D||1
50451765|Aguacateruehle orgánico congelado|O|O||D||1
50451766|Aguacate ryan orgánico congelado|O|O||D||1
50451767|Aguacate semil orgánico congelado|O|O||D||1
50451768|Aguacate semil 43 orgánico congelado|O|O||D||1
50451769|Aguacate simonds orgánico congelado|O|O||D||1
50451770|Aguacate simpson orgánico congelado|O|O||D||1
50451771|Aguacate taylor orgánico congelado|O|O||D||1
50451772|Aguacate tonelada orgánico congelado|O|O||D||1
50451773|Aguacate torre orgánico congelado|O|O||D||1
50451774|Aguacate torre li orgánico congelado|O|O||D||1
50451775|Aguacate trapp orgánico congelado|O|O||D||1
50451776|Aguacate semilla de caribe orgánico congelado|O|O||D||1
50451777|Aguacate wagner orgánico congelado|O|O||D||1
50451778|Aguacate waldin orgánico congelado|O|O||D||1
50451779|Aguacate wurtz orgánico congelado|O|O||D||1
50451780|Aguacate zio p orgánico congelado|O|O||D||1
50451781|Aguacate ziu orgánico congelado|O|O||D||1
50451782|Aguacate zultano orgánico congelado|O|O||D||1
50451800|Fríjoles orgánicos congelados|O|O||D||1
50451801|Frijoles anasazi ® orgánicos congelados|O|O||D||1
50451802|Frijoles appaloosa orgánicos congelados|O|O||D||1
50451803|Frijoles azuki orgánicos congelados|O|O||D||1
50451804|Frijoles barlotti orgánicos congelados|O|O||D||1
50451805|Frijoles appaloosa negra orgánicos congelados|O|O||D||1
50451806|Frijoles negros orgánicos congelados|O|O||D||1
50451807|Frijoles gran negros orgánicos congelados|O|O||D||1
50451808|Frijoles shackamaxon negro orgánicos congelados|O|O||D||1
50451809|Frijoles ojo negro orgánicos congelados|O|O||D||1
50451810|Frijoles bobby orgánicos congelados|O|O||D||1
50451811|Frijoles bolita orgánicos congelados|O|O||D||1
50451812|Frijoles esposa perezosa carmelita orgánicos congelados|O|O||D||1
50451813|Frijoles calipso orgánicos congelados|O|O||D||1
50451814|Frijoles canelini orgánicos congelados|O|O||D||1
50451815|Frijoles castor orgánicos congelados|O|O||D||1
50451816|Frijoles amarillo chino orgánicos congelados|O|O||D||1
50451817|Frijoles lengua de dragón orgánicos congelados|O|O||D||1
50451818|Frijoles soldado europeo orgánicos congelados|O|O||D||1
50451819|Frijoles fava orgánicos congelados|O|O||D||1
50451820|Frijoles flageolet orgánicos congelados|O|O||D||1
50451821|Frijoles  horticultura francesa orgánicos congelados|O|O||D||1
50451822|Frijoles marina francesa orgánicos congelados|O|O||D||1
50451823|Frijoles coco gigante blanco orgánicos congelados|O|O||D||1
50451824|Frijoles verdes orgánicos congelados|O|O||D||1
50451825|Frijoles romano verde orgánicos congelados|O|O||D||1
50451826|Frijoles guar gum orgánicos congelados|O|O||D||1
50451827|Frijoles haricot orgánicos congelados|O|O||D||1
50451828|Frijoles hyacinth orgánicos congelados|O|O||D||1
50451829|Frijoles tipo italiano orgánicos congelados|O|O||D||1
50451830|Frijoles asombro jackson orgánicos congelados|O|O||D||1
50451831|Frijoles ganado jacobs  orgánicos congelados|O|O||D||1
50451832|Frijoles asombro kentucky orgánicos congelados|O|O||D||1
50451833|Frijoles riñón orgánicos congelados|O|O||D||1
50451834|Frijoles lima orgánicos congelados|O|O||D||1
50451835|Frijoles madera orgánicos congelados|O|O||D||1
50451836|Frijoles medula orgánicos congelados|O|O||D||1
50451837|Frijoles mat orgánicos congelados|O|O||D||1
50451838|Frijoles monstoler ganzo salvaje orgánicos congelados|O|O||D||1
50451839|Frijoles  mortgage lifter orgánicos congelados|O|O||D||1
50451840|Frijoles polilla orgánicos congelados|O|O||D||1
50451841|Frijoles mung orgánicos congelados|O|O||D||1
50451842|Frijoles munsi wolf orgánicos congelados|O|O||D||1
50451843|Frijoles nuna orgánicos congelados|O|O||D||1
50451844|Frijoles pinto orgánicos congelados|O|O||D||1
50451845|Frijoles runner orgánicos congelados|O|O||D||1
50451846|String beans orgánicos congelados|O|O||D||1|Ayecote orgánico congelado, Fríjol gordo orgánico congelado
50451847|Frijoles habichuelas orgánicos congelados|O|O||D||1|Ejote orgánico congelado, Fríjol tierno orgánico congelado
50451848|Frijoles tamarind orgánicos congelados|O|O||D||1
50451849|Frijoles tonka orgánicos congelados|O|O||D||1
50451850|Frijoles cera orgánicos congelados|O|O||D||1
50451851|Frijoles winged orgánicos congelados|O|O||D||1
50451852|Frijoles largos orgánicos congelados|O|O||D||1
50451900|Remolachas  orgánicas congeladas|O|O||D||1|Betabeles orgánicos congelados
50451901|Remolacha acción orgánica congelada|O|O||D||1|Betabel acción orgánico congelado
50451902|Remolacha albina vereduna orgánica congelada|O|O||D||1|Betabel albina vereduna orgánico congelado
50451903|Remolacha barababiotela de chiggia orgánica congelada|O|O||D||1|Betabel barababiotela de chiggia orgánico congelado
50451904|Remolacha boltardy orgánica congelada|O|O||D||1|Betabel boltardy orgánico congelado
50451905|Remolacha bonel orgánica congelada|O|O||D||1|Betabel bonel orgánico congelado
50451906|Remolacha burpees dorado orgánica congelada|O|O||D||1|Betabel burpees dorado orgánico congelado
50451907|Remolacha cheltenham tapa verde orgánica congelada|O|O||D||1|Betabel cheltenham tapa verde orgánico congelado
50451908|Remolacha cheltenham mono orgánica congelada|O|O||D||1|Betabel cheltenham mono orgánico congelado
50451909|Remolacha chioggia orgánica congelada|O|O||D||1|Betabel chioggia orgánico congelado
50451910|Remolacha cilindra orgánica congelada|O|O||D||1|Betabel cilindra orgánico congelado
50451911|Remolacha dégypte orgánica congelada|O|O||D||1|Betabel dégypte orgánico congelado
50451912|Remolacha detroit 2 rojo oscuro orgánica congelada|O|O||D||1|Betabel detroit 2 rojo oscuro orgánico congelado
50451913|Remolacha detroit 2 bala chiquita orgánica congelada|O|O||D||1|Betabel detroit 2 bala chiquita orgánico congelado
50451914|Remolacha egipcia plana  orgánica congelada|O|O||D||1|Betabel egipcia plana orgánico congelado
50451915|Remolacha  raíz de nabo egipcio orgánica congelada|O|O||D||1|Betabel raíz de nabo egipcio orgánico congelado
50451916|Remolacha fomanova orgánica congelada|O|O||D||1|Betabel fomanova orgánico congelado
50451917|Remolacha forono orgánica congelada|O|O||D||1|Betabel forono orgánico congelado
50451918|Remolacha monaco orgánica congelada|O|O||D||1|Betabel mónaco orgánico congelado
50451919|Remolacha monograma orgánica congelada|O|O||D||1|Betabel monograma orgánico congelado
50451920|Remolacha pronto orgánica congelada|O|O||D||1|Betabel pronto orgánico congelado
50451921|Remolacha regalía orgánica congelada|O|O||D||1|Betabel regalía orgánico congelado
50451922|Remolacha dulce orgánica congelada|O|O||D||1|Betabel dulce orgánico congelado
50452000|Brócolis  orgánicas congeladas|O|O||D||1
50452001|Brócolini orgánico congelado|O|O||D||1
50452002|Brócoli romanesco orgánico congelado|O|O||D||1
50452003|Brócoli raab orgánico congelado|O|O||D||1
50452004|Brócoli chino orgánico congelado|O|O||D||1
50452100|Repollitos de Bruselas  orgánicas congeladas|O|O||D||1|Coles de Bruselas orgánicas congeladas
50452101|Repollitas de bruselas citade orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas citade orgánica orgánicas congeladas
50452102|Repollitas de bruselas falstaff orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas falstaff orgánica orgánicas congeladas
50452103|Repollitas de bruselas oliver orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas oliver orgánica orgánicas congeladas
50452104|Repollitas de bruselas peer gynt orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas peer gynt orgánica orgánicas congeladas
50452105|Repollitas de bruselas rampart orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas rampart orgánica orgánicas congeladas
50452106|Repollitas de bruselas rubine orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas rubine orgánica orgánicas congeladas
50452107|Repollitas de bruselas  widgeon orgánica orgánicas congeladas|O|O||D||1|Coles de Bruselas widgeon orgánica orgánicas congeladas
50452200|Cebollas de ensalada  orgánicas congeladas|O|O||D||1|Cebollas de cambray  orgánicas congeladas
50452201|Cebolla belstville ensalada orgánica congelada|O|O||D||1|Cebolla de cambray belstville orgánica congelada
50452202|Cebolla feast ensalada orgánica congelada|O|O||D||1|Cebolla de cambray feast orgánica congelada
50452203|Cebolla ishikura ensalada orgánica congelada|O|O||D||1|Cebolla de cambray ishikura orgánica congelada
50452204|Cebolla mercado kyoto orgánica congelada|O|O||D||1|Cebolla de cambray mercado kyoto orgánica congelada
50452205|Cebolla barba roja ensalada orgánica congelada|O|O||D||1|Cebolla de cambray barba roja orgánica congelada
50452206|Cebolla amigo rojo ensalada orgánica congelada|O|O||D||1|Cebolla de cambray amigo rojo orgánica congelada
50452207|Cebolla santa claus orgánica congelada|O|O||D||1|Cebolla de cambray santa claus orgánica congelada
50452208|Cebolla tokyo ensalada orgánica congelada|O|O||D||1|Cebolla de cambray tokyo orgánica congelada
50452209|Cebolla lisbon blanca ensalada orgánica congelada|O|O||D||1|Cebolla de cambray lisbon blanca orgánica congelada
50452210|Cebolla invierno blanca ensalada orgánica congelada|O|O||D||1|Cebolla de cambray invierno blanca orgánica congelada
50452211|Cebolla final de invierno ensalada orgánica congelada|O|O||D||1|Cebolla de cambray final de invierno orgánica congelada
50452300|Repollos orgánicos congelados|O|O||D||1|Coles orgánicas congeladas
50452301|Repollo negro orgánico congelado|O|O||D||1|Col negro orgánica congelada
50452302|Repollo savoy orgánico congelado|O|O||D||1|Col savoy orgánica congelada
50452303|Repollo zorrillo orgánico congelado|O|O||D||1|Col zorrillo orgánica congelada
50452304|Repollo blanco orgánico congelado|O|O||D||1|Col blanco orgánica congelada
50452400|Cardos orgánicos congelados|O|O||D||1|Cardos comestibles orgánicos congelados
50452401|Cardos lunghi orgánicos congelados|O|O||D||1|Cardo comestible lunghi orgánicos congelados
50452402|Cardos gobbi orgánicos congelados|O|O||D||1|Cardo comestible gobbi orgánicos congelados
50452500|Zanahorias  orgánicas congeladas|O|O||D||1
50452501|Zanahoria amsterdam orgánica congelada|O|O||D||1
50452502|Zanahoria rey de otoño orgánica congelada|O|O||D||1
50452503|Zanahoria berlicum orgánica congelada|O|O||D||1
50452504|Zanahoria chantenay orgánica congelada|O|O||D||1
50452505|Zanahoria nantes orgánica congelada|O|O||D||1
50452506|Zanahoria mercado de parís orgánica congelada|O|O||D||1
50452600|Coliflores  orgánicas congeladas|O|O||D||1
50452601|Coliflor todo el año  orgánica congelada|O|O||D||1
50452602|Coliflor alverda orgánica congelada|O|O||D||1
50452603|coliflor otoño gigante 3 orgánica congelada|O|O||D||1
50452604|Coliflo rdok elgon orgánica congelada|O|O||D||1
50452605|Coliflor bola de nieve temprana orgánica congelada|O|O||D||1
50452606|Coliflor luz de lima orgánica congelada|O|O||D||1
50452607|Coliflor minaret orgánica congelada|O|O||D||1
50452608|Coliflor buque de naranja orgánica congelada|O|O||D||1
50452609|Coliflor capa morada orgánica congelada|O|O||D||1
50452610|Coliflor bola de nieve orgánica congelada|O|O||D||1
50452611|Coliflor invierno walcheren 3 orgánica congelada|O|O||D||1
50452612|Coliflor piedra blanca orgánica congelada|O|O||D||1
50452700|Apios orgánicos congelados|O|O||D||1
50452701|Apio celebridad orgánico congelado|O|O||D||1
50452702|Apio nabo orgánico congelado|O|O||D||1
50452703|Apio chino orgánico congelado|O|O||D||1
50452704|Apio dinant francés orgánico congelado|O|O||D||1
50452705|Apio gigante rosado orgánico congelado|O|O||D||1
50452706|Apio gigante rojo orgánico congelado|O|O||D||1
50452707|Apio gigante blanco orgánico congelado|O|O||D||1
50452708|Apio dorado auto escalado orgánico congelado|O|O||D||1
50452709|Apio "greensleeves" orgánico congelado|O|O||D||1
50452710|Apio hopkins fenlander orgánico congelado|O|O||D||1
50452711|Apio torre marfil orgánico congelado|O|O||D||1
50452712|Apio lathom blanqueado orgánico congelado|O|O||D||1
50452713|Apio sopa de amsterdam orgánico congelado|O|O||D||1
50452714|Apio estándar cargado orgánico congelado|O|O||D||1
50452715|Apio triunfo alto utah orgánico congelado|O|O||D||1
50452800|Acelgas  orgánicas congeladas|O|O||D||1
50452801|Acelga luz brillante orgánica congelada|O|O||D||1
50452802|Acelga gigante fordhook orgánica congelada|O|O||D||1
50452803|Acelga luculus orgánica congelada|O|O||D||1
50452804|Acelga espinaca perpetua orgánica congelada|O|O||D||1
50452805|Acelga ruibarbo orgánica congelada|O|O||D||1
50452806|Acelga suizo orgánica congelada|O|O||D||1
50452807|Acelga volcán  orgánica congelada|O|O||D||1
50452808|Acelga rey blanco orgánica congelada|O|O||D||1
50452900|Achicorias orgánicas congeladas|O|O||D||1|Escarolas orgánicas congeladas
50452901|Achicoria batavian hoja ancha orgánica congelada|O|O||D||1|Escarola batavian hoja ancha orgánica congelada
50452902|Achicoria en cornet de bordeaux orgánica congelada|O|O||D||1|Escarola en cornet de bordeaux orgánica congelada
50452903|Achicoria rollo verde ruffee orgánica congelada|O|O||D||1|Escarola rollo verde ruffee orgánica congelada
50452904|Achicoria roll verde orgánica congelada|O|O||D||1|Escarola roll verde orgánica congelada
50452905|Achicoria limnoe lone orgánica congelada|O|O||D||1|Escarola limnoe lone orgánica congelada
50452906|Achicoria pancalieri riccia orgánica congelada|O|O||D||1|Escarola pancalieri riccia orgánica congelada
50452907|Achicoria ensalada rey orgánica congelada|O|O||D||1|Escarola ensalada rey orgánica congelada
50452908|Achicoria sanda orgánica congelada|O|O||D||1|Escarola sanda orgánica congelada
50452909|Achicoria scarola verde orgánica congelada|O|O||D||1|Escarola scarola verde orgánica congelada
50452910|Achicoria tres fine maraichere orgánica congelada|O|O||D||1|Escarola tres fine maraichere orgánica congelada
50452911|Achicoria wallone freisee wescelkkopf orgánica congelada|O|O||D||1|Escarola wallone freisee wescelkkopf orgánica congelada
50453000|Repollos chinos orgánicos congelados|O|O||D||1|Coles chinas orgánicas congeladas
50453001|Bok choy orgánico congelado|O|O||D||1
50453002|Bok choy enano orgánico congelado|O|O||D||1
50453003|Flor de repollo chino orgánica congelada|O|O||D||1|Flor de col china orgánica congelada
50453004|Choy sum orgánico congelado|O|O||D||1
50453005|Col (bok choy) enano orgánico congelado|O|O||D||1
50453006|Col (bok choy) fengshan orgánico congelado|O|O||D||1
50453007|Col (bok choy) jade pagoda orgánico congelado|O|O||D||1
50453008|Col (bok choy) kasumi orgánico congelado|O|O||D||1
50453009|col (bok choy)  nerva orgánico congelado|O|O||D||1
50453010|Col (bok choy) rosette orgánico congelado|O|O||D||1
50453011|Col (bok choy) ruffles orgánico congelado|O|O||D||1
50453012|Col (bok choy) hoja  santo serrated orgánico congelado|O|O||D||1
50453013|Col (bok choy) shangahai orgánico congelado|O|O||D||1
50453014|Shantung orgánico congelado|O|O||D||1
50453015|Repollo tip top orgánico congelado|O|O||D||1|Col china tip top orgánico congelado
50453016|Yau choy sum orgánico congelado|O|O||D||1
50453100|Cebollines orgánicos congelados|O|O||D||1
50453101|Cebollín chino  orgánico congelado|O|O||D||1
50453200|Maíces orgánicos congelados|O|O||D||1
50453201|Maíz aloha orgánico congelado|O|O||D||1
50453202|Maíz alpine orgánico congelado|O|O||D||1
50453203|Maíz ambrosia orgánico congelado|O|O||D||1
50453204|Maíz argent orgánico congelado|O|O||D||1
50453205|Maíz aspen orgánico congelado|O|O||D||1
50453206|Maíz avalancha orgánico congelado|O|O||D||1
50453207|Maíz biqueen orgánico congelado|O|O||D||1
50453208|Maíz  bodacious orgánico congelado|O|O||D||1
50453209|Maíz  mantequilla y azúcar orgánico congelado|O|O||D||1
50453210|Maíz  calico belle orgánico congelado|O|O||D||1
50453211|Maíz  camelot orgánico congelado|O|O||D||1
50453212|Maíz  challengercrisp ‘n dulce orgánico congelado|O|O||D||1
50453213|Maíz  campeón orgánico congelado|O|O||D||1
50453214|Maíz  algodón de azúcar orgánico congelado|O|O||D||1
50453215|Maíz  dártagnan orgánico congelado|O|O||D||1
50453216|Maíz  dazzle orgánico congelado|O|O||D||1
50453217|Maíz  diamante y oro orgánico congelado|O|O||D||1
50453218|Maíz  divinidad orgánico congelado|O|O||D||1
50453219|Maíz  delicia doble orgánico congelado|O|O||D||1
50453220|Maíz  gema doble orgánico congelado|O|O||D||1
50453221|Maíz  earlivee orgánico congelado|O|O||D||1
50453222|Maíz  temprano extra dulce orgánico congelado|O|O||D||1
50453223|Maíz excel orgánico congelado|O|O||D||1
50453224|Maíz  cruz dorada bantam orgánico congelado|O|O||D||1
50453225|Maíz  miel y crema orgánico congelado|O|O||D||1
50453226|Maíz  miel y perla orgánico congelado|O|O||D||1
50453227|Maíz  miel dulce orgánico congelado|O|O||D||1
50453228|Maíz  hudson orgánico congelado|O|O||D||1
50453229|Maíz  dorado illini orgánico congelado|O|O||D||1
50453230|Maíz  illini extra dulce orgánico congelado|O|O||D||1
50453231|Maíz  increíble orgánico congelado|O|O||D||1
50453232|Maíz  lochief orgánico congelado|O|O||D||1
50453233|Maíz jubileo orgánico congelado|O|O||D||1
50453234|Maíz jupbileo super dulce orgánico congelado|O|O||D||1
50453235|Maíz  confite korn orgánico congelado|O|O||D||1
50453236|Maíz  beso y acuso orgánico congelado|O|O||D||1
50453237|Maíz  lancelot orgánico congelado|O|O||D||1
50453238|Maíz dulce maple orgánico congelado|O|O||D||1
50453239|Maíz  medley orgánico congelado|O|O||D||1
50453240|Maíz merlin orgánico congelado|O|O||D||1
50453241|Maíz milagro orgánico congelado|O|O||D||1
50453242|Maíz nk – 199 orgánico congelado|O|O||D||1
50453243|Maíz durazno y crema orgánico congelado|O|O||D||1
50453244|Maíz blanco perla orgánico congelado|O|O||D||1
50453245|Maíz  pegasus orgánico congelado|O|O||D||1
50453246|Maíz  fenomenal orgánico congelado|O|O||D||1
50453247|Maíz  dama de platino orgánico congelado|O|O||D||1
50453248|Maíz  precioso orgánico congelado|O|O||D||1
50453249|Maíz   pristine orgánico congelado|O|O||D||1
50453250|Maíz  rápido orgánico congelado|O|O||D||1
50453251|Maíz  radiante orgánico congelado|O|O||D||1
50453252|Maíz  seneca brave orgánico congelado|O|O||D||1
50453253|Maíz  amanecer seneca orgánico congelado|O|O||D||1
50453254|Maíz  horizonte seneca orgánico congelado|O|O||D||1
50453255|Maíz  brillo de estrella seneca orgánico congelado|O|O||D||1
50453256|Maíz  noche blanca seneca orgánico congelado|O|O||D||1
50453257|Maíz  showcase orgánico congelado|O|O||D||1
50453258|Maíz  reina plateada orgánico congelado|O|O||D||1
50453259|Maíz  bella nieve orgánico congelado|O|O||D||1
50453260|Maíz nieve de primavera orgánico congelado|O|O||D||1
50453261|Maíz  premio de primavera orgánico congelado|O|O||D||1
50453262|Maíz  azúcar y oro orgánico congelado|O|O||D||1
50453263|Maíz rollo de azúcar orgánico congelado|O|O||D||1
50453264|Maíz nieve de azúcar orgánico congelado|O|O||D||1
50453265|Maíz baile de sol orgánico congelado|O|O||D||1
50453266|Maíz estrella tell orgánico congelado|O|O||D||1
50453267|Maíz terminador orgánico congelado|O|O||D||1
50453268|Maíz tesoro orgánico congelado|O|O||D||1
50453269|Maíz tuxedo orgánico congelado|O|O||D||1
50453300|Berros  orgánicos congelados|O|O||D||1
50453301|Berros de tierra orgánicos congelados|O|O||D||1
50453302|Nasturtium orgánico congelado|O|O||D||1
50453303|Berros de agua orgánicos congelados|O|O||D||1
50453304|Berros de invierno orgánicos congelados|O|O||D||1
50453400|Cocombros orgánicos congelados|O|O||D||1|Pepinos cohombro orgánicos congelados
50453401|Cocombro arena orgánico congelado|O|O||D||1|Pepino cohombro arena orgánico congelado
50453402|Cocombro americano orgánico congelado|O|O||D||1|Pepino cohombro americano orgánico congelado
50453403|Cocombro atena orgánico congelado|O|O||D||1|Pepino cohombro atena orgánico congelado
50453404|Cocombro blanco lungo de parigi orgánico congelado|O|O||D||1|Pepino cohombro blanco lungo de parigi orgánico congelado
50453405|Cocombro verde burpless buen sabor orgánico congelado|O|O||D||1|Pepino cohombro verde burpless buen sabor orgánico congelado
50453406|Cocombro chicago pickling orgánico congelado|O|O||D||1|Pepino cohombro chicago pickling orgánico congelado
50453407|Cocombro manzana cristal orgánico congelado|O|O||D||1|Pepino cohombro manzana cristal orgánico congelado
50453408|Cocombro limón cristal orgánico congelado|O|O||D||1|Pepino cohombro limón cristal orgánico congelado
50453409|Cocombro danimas orgánico congelado|O|O||D||1|Pepino cohombro danimas orgánico congelado
50453410|Cocombro gherkin orgánico congelado|O|O||D||1|Pepino cohombro gherkin orgánico congelado
50453411|Cocombro hokus orgánico congelado|O|O||D||1|Pepino cohombro hokus orgánico congelado
50453412|Cocombro japonés orgánico congelado|O|O||D||1|Pepino cohombro japonés orgánico congelado
50453413|Cocombro karela orgánico congelado|O|O||D||1|Pepino cohombro karela orgánico congelado
50453414|Cocombro korila orgánico congelado|O|O||D||1|Pepino cohombro korila orgánico congelado
50453415|Cocombro verde largo mejorado orgánico congelado|O|O||D||1|Pepino cohombro verde largo mejorado orgánico congelado
50453416|Cocombro mas mercado orgánico congelado|O|O||D||1|Pepino cohombro mas mercado orgánico congelado
50453417|Cocombro enano orgánico congelado|O|O||D||1|Pepino cohombro enano orgánico congelado
50453418|Cocombro pickling nacional orgánico congelado|O|O||D||1|Pepino cohombro pickling nacional orgánico congelado
50453419|Cocombro persa orgánico congelado|O|O||D||1|Pepino cohombro persa orgánico congelado
50453420|Cocombro telégrafo orgánico congelado|O|O||D||1|Pepino cohombro telégrafo orgánico congelado
50453421|Cocombro telégrafo mejorado orgánico congelado|O|O||D||1|Pepino cohombro telégrafo mejorado orgánico congelado
50453422|Cocombro vert de massy cornichon orgánico congelado|O|O||D||1|Pepino cohombro vert de massy cornichon orgánico congelado
50453423|Cocombro yamato orgánico congelado|O|O||D||1|Pepino cohombro yamato orgánico congelado
50453500|Berenjenas orgánicas congeladas|O|O||D||1
50453501|Berenjena bambino orgánica congelada|O|O||D||1
50453502|Berenjena  belleza negra orgánica congelada|O|O||D||1
50453503|Berenjena  negra enorme orgánica congelada|O|O||D||1
50453504|Berenjena  chino orgánica congelada|O|O||D||1
50453505|Berenjena  huevo de pascua orgánica congelada|O|O||D||1
50453506|Berenjena  filipino orgánica congelada|O|O||D||1
50453507|Berenjena   mercado de florida orgánica congelada|O|O||D||1
50453508|Berenjena  india orgánica congelada|O|O||D||1
50453509|Berenjena  italiano orgánica congelada|O|O||D||1
50453510|Berenjena  japonés orgánica congelada|O|O||D||1
50453511|Berenjena  morado largo orgánica congelada|O|O||D||1
50453512|Berenjena   rayas larga orgánica congelada|O|O||D||1
50453513|Berenjena  mercado de dinero orgánica congelada|O|O||D||1
50453514|Berenjena  ova orgánica congelada|O|O||D||1
50453515|Berenjena   arveja orgánica congelada|O|O||D||1
50453516|Berenjena  tom bajito orgánica congelada|O|O||D||1
50453517|Berenjena  siciliano orgánica congelada|O|O||D||1
50453518|Berenjena  tailandés orgánica congelada|O|O||D||1
50453519|Berenjena  violeta de florencia orgánica congelada|O|O||D||1
50453520|Berenjena  blanco orgánica congelada|O|O||D||1
50453600|Endivias orgánicas congeladas|O|O||D||1
50453601|Endivias witloof de brucelas orgánica orgánicas congeladas|O|O||D||1
50453602|Endivias francocastel orgánica orgánicas congeladas|O|O||D||1
50453603|Endivias catalogna de galantina orgánica orgánicas congeladas|O|O||D||1
50453604|Endivias chioggia orgánica orgánicas congeladas|O|O||D||1
50453605|Endivias grumolo verde orgánica orgánicas congeladas|O|O||D||1
50453606|Endivias raíz larga magdeburg orgánica orgánicas congeladas|O|O||D||1
50453607|Endivias palla rosa zorzi precoce orgánica orgánicas congeladas|O|O||D||1
50453608|Endivias radice amare orgánica orgánicas congeladas|O|O||D||1
50453609|Endivias rosa de traviso orgánica orgánicas congeladas|O|O||D||1
50453610|Endivias  rosa de verona orgánica orgánicas congeladas|O|O||D||1
50453611|Endivias soncino orgánica orgánicas congeladas|O|O||D||1
50453612|Endivias sugarthi orgánica orgánicas congeladas|O|O||D||1
50453613|Endivias verona orgánica orgánicas congeladas|O|O||D||1
50453614|Endivias witloof zoom orgánica orgánicas congeladas|O|O||D||1
50453700|Hinojos orgánicos congelados|O|O||D||1
50453701|Hinojo cantino orgánico congelado|O|O||D||1
50453702|Hinojo fino orgánico congelado|O|O||D||1
50453703|Hinojoherald orgánico congelado|O|O||D||1
50453704|Hinojo perfección orgánico congelado|O|O||D||1
50453705|Hinojo sirio orgánico congelado|O|O||D||1
50453706|Hinojo florencia dulce orgánico congelado|O|O||D||1
50453707|Hinojo tardo orgánico congelado|O|O||D||1
50453800|Ajos orgánicos congelados|O|O||D||1
50453801|Ajo tarde california orgánico congelado|O|O||D||1
50453802|Ajo tallos chinos orgánico congelado|O|O||D||1
50453803|Ajo cebollin  orgánico congelado|O|O||D||1
50453804|Ajo germidor orgánico congelado|O|O||D||1
50453805|Ajo guardado largo orgánico congelado|O|O||D||1
50453806|Ajo ramson orgánico congelado|O|O||D||1
50453807|Ajo rocambola orgánico congelado|O|O||D||1
50453808|Ajo rosa de lautrec orgánico congelado|O|O||D||1
50453809|Ajo solent blanco orgánico congelado|O|O||D||1
50453810|Ajo morado español orgánico congelado|O|O||D||1
50453811|Ajo valentina italiana orgánico congelado|O|O||D||1
50453900|Calabazas orgánicas congeladas|O|O||D||1
50453901|Petula orgánica congelada|O|O||D||1|Luffa orgánica congelada
50453902|Melon amargo orgánico congelado|O|O||D||1
50453903|Botella calabaza orgánica congelada|O|O||D||1|Mate orgánico congelado
50453904|Calabash gounds orgánica congelada|O|O||D||1|Calabaza de peregrino orgánica congelada
50453905|Melón peludo orgánico congelado|O|O||D||1
50453906|Calabaza amarga orgánica congelada|O|O||D||1
50453907|Loofah suave orgánico congelado|O|O||D||1|Zapatillo suave orgánico congelado
50453908|Serpiente de calabaza orgánica congelada|O|O||D||1|Chichinda orgánica congelada
50453909|Calabaza larga amarga orgánica congelada|O|O||D||1
50453910|Calabaza tinda orgánica congelada|O|O||D||1
50453911|Calabaza tindoori orgánica congelada|O|O||D||1
50454000|Guisantes orgánicas congeladas|O|O||D||1|Chícharos orgánicos congelados
50454001|Guisante chino orgánica congelada|O|O||D||1|Chícharo chino orgánico congelado
50454002|Guisante inglés orgánica congelada|O|O||D||1|Chícharo inglés orgánico congelado
50454003|Guisante de jardín orgánica congelada|O|O||D||1|Chícharo de jardín orgánico congelado
50454004|Guisante nieve orgánica congelada|O|O||D||1|Chícharo nieve orgánico congelado
50454005|Guisante snap dulce orgánica congelada|O|O||D||1|Chícharo snap dulce orgánico congelado
50454100|Hierbas orgánicas congeladas|O|O||D||1|Perejil orgánico congelado, Yerbabuena o hierbabuena congelada
50454101|Albahaca orgánica congelada|O|O||D||1
50454102|Laurel orgánico congelado|O|O||D||1
50454103|Borraja orgánica congelada|O|O||D||1
50454104|Alcaravea orgánica congelada|O|O||D||1
50454105|Perifollo orgánico congelado|O|O||D||1
50454106|Cilantro orgánico congelado|O|O||D||1
50454107|Chipolinos orgánico congelado|O|O||D||1
50454108|Hoja de curry orgánica congelada|O|O||D||1
50454109|Eneldo orgánico congelado|O|O||D||1
50454110|Epazote orgánico congelado|O|O||D||1
50454111|Fenogreco orgánico congelado|O|O||D||1
50454112|Limonaria orgánica congelada|O|O||D||1|Té de limón orgánico congelado
50454113|Mejorana orgánica congelada|O|O||D||1
50454114|Menta orgánica congelada|O|O||D||1
50454115|Orégano orgánico congelado|O|O||D||1
50454116|Pápalo orgánico congelado|O|O||D||1
50454117|Pápalo delgado orgánico congelado|O|O||D||1
50454118|Perilla orgánica congelada|O|O||D||1|Albahaca japonesa orgánica congelada
50454119|Recao  orgánico congelado|O|O||D||1
50454120|Romero orgánico congelado|O|O||D||1
50454121|Salvia orgánica congelada|O|O||D||1
50454122|Salsifí orgánica congelada|O|O||D||1|Barba cabruna orgánica congelada
50454123|Satureja orgánica congelada|O|O||D||1|Ajedreas  orgánica congelada
50454124|Estragón orgánico congelado|O|O||D||1|Tarragón  orgánica congelado
50454125|Tomillo orgánico congelado|O|O||D||1
50454126|Tumeric orgánico congelado|O|O||D||1|Cúrcuma orgánica congelada
50454127|Verdolaga orgánica congelada|O|O||D||1
50454200|Coles orgánicas congeladas|O|O||D||1
50454201|Col rizada orgánica congelada|O|O||D||1
50454202|Repollo verde orgánico congelado|O|O||D||1
50454300|Colinabos orgánicos congelados|O|O||D||1|Colirrábanos orgánicos congelados
50454301|Colinabo estrella azur orgánico congelado|O|O||D||1|Colirrábano estrella azur orgánico congelado
50454302|Colinabo verde viena orgánico congelado|O|O||D||1|Colirrábano verde viena orgánico congelado
50454303|Colinabo lanro orgánico congelado|O|O||D||1|Colirrábano lanro orgánico congelado
50454304|Colinabo viena morada orgánico congelado|O|O||D||1|Colirrábano viena morada orgánico congelado
50454305|Colinabo trero rowel orgánico congelado|O|O||D||1|Colirrábano trero rowel orgánico congelado
50454306|Colinabo viena blanca orgánico congelado|O|O||D||1|Colirrábano viena blanca orgánico congelado
50454400|Puerros orgánicos congelados|O|O||D||1|Poros orgánicos congelados
50454401|Puerro cobra gigante otoño orgánico congelado|O|O||D||1|Poro cobra gigante otoño orgánico congelado
50454402|Puerro otoño mamut 2 orgánico congelado|O|O||D||1|Poro otoño mamut 2 orgánico congelado
50454403|Puerro blue de solaise orgánico congelado|O|O||D||1|Poro blue de solaise orgánico congelado
50454404|Puerro cortina orgánico congelado|O|O||D||1|Poro cortina orgánico congelado
50454405|Puerro prelina orgánico congelado|O|O||D||1|Poro prelina orgánico congelado
50454406|Puerro salvaje orgánico congelado|O|O||D||1|Poro salvaje orgánico congelado
50454500|Lentejas  orgánicas congeladas|O|O||D||1
50454501|Lenteja beluga orgánica congelada|O|O||D||1
50454502|Lenteja  verde francesa orgánica congelada|O|O||D||1
50454503|Lenteja verde orgánica congelada|O|O||D||1
50454504|Lenteja crimson pequeña orgánica congelada|O|O||D||1
50454505|Lenteja pardina española orgánica congelada|O|O||D||1
50454506|Lenteja roja separada orgánica congelada|O|O||D||1
50454507|Lenteja amarilla separad orgánica congelada|O|O||D||1
50454508|Lenteja tarahumara rosada orgánica congelada|O|O||D||1
50454600|Lechugas orgánicas congeladas|O|O||D||1
50454601|Lechuga  bibb orgánica congelada|O|O||D||1
50454602|Lechuga  boston orgánica congelada|O|O||D||1
50454603|Lechuga frisee orgánica congelada|O|O||D||1
50454604|Lechuga rosa lola orgánica congelada|O|O||D||1
50454605|Lechuga  mixta masculina orgánica congelada|O|O||D||1
50454606|Lechuga mizuna orgánica congelada|O|O||D||1
50454607|Lechuga hoja roja orgánica congelada|O|O||D||1
50454608|Lechuga oja roja roble orgánica congelada|O|O||D||1
50454609|Lechuga romana ruby orgánica congelada|O|O||D||1
50454610|Lechuga romana bebé roja orgánica congelada|O|O||D||1
50454611|Lechuga cabeza de mantequilla orgánica congelada|O|O||D||1
50454612|Lechuga china orgánica congelada|O|O||D||1|Lechuga orejona orgánica congelada
50454613|Lechuga cabeza tostada orgánica congelada|O|O||D||1
50454614|Lechuga hoja verde orgánica congelada|O|O||D||1
50454615|Lechuga iceberg orgánica congelada|O|O||D||1
50454616|Lechuga cordero orgánica congelada|O|O||D||1
50454617|Lechuga hoja suelta orgánica congelada|O|O||D||1
50454618|Lechuga mache orgánica congelada|O|O||D||1
50454619|Lechuga boston roja orgánica congelada|O|O||D||1
50454620|Lechuga cabeza roja orgánica congelada|O|O||D||1
50454621|Lechuga romana orgánica congelada|O|O||D||1
50454622|Lechuga mostza roja rusa orgánica congelada|O|O||D||1
50454623|Lechuga tatsoi orgánica congelada|O|O||D||1
50454700|Ñames orgánicos congelados|O|O||D||1
50454701|Ñame amarilla orgánica congelada|O|O||D||1
50454702|Ñame blanca orgánica congelada|O|O||D||1
50454703|Ñame coco orgánica congelada|O|O||D||1
50454704|Ñame eddoes orgánica congelada|O|O||D||1
50454705|Ñame isleña orgánica congelada|O|O||D||1
50454706|Ñame lila orgánica congelada|O|O||D||1
50454800|Hongos o champiñones orgánicos congelados|O|O||D||1
50454801|Champiñón trompeta negra orgánico congelado|O|O||D||1
50454802|Champiñón carmelito orgánico congelado|O|O||D||1
50454803|Champiñón  orgánico congelado|O|O||D||1
50454804|Champiñón chanterelle orgánico congelado|O|O||D||1
50454805|Champiñón cremini orgánico congelado|O|O||D||1
50454806|Champiñón enoki orgánico congelado|O|O||D||1
50454807|Champiñón puercoespín orgánico congelado|O|O||D||1
50454808|Champiñón gallina del bosque orgánico congelado|O|O||D||1
50454809|Champiñón langosta orgánico congelado|O|O||D||1
50454810|Champiñón morels orgánico congelado|O|O||D||1
50454811|Champiñón ostra orgánico congelado|O|O||D||1
50454812|Champiñón pleurotus orgánico congelado|O|O||D||1
50454813|Champiñón pompom orgánico congelado|O|O||D||1
50454814|Champiñón porcieni orgánico congelado|O|O||D||1
50454815|Champiñón portobello orgánico congelado|O|O||D||1
50454816|Champiñón shitake orgánico congelado|O|O||D||1
50454817|Champiñón shimeji orgánico congelado|O|O||D||1
50454818|Champiñón san jorge orgánico congelado|O|O||D||1
50454819|Champiñón blanco orgánico congelado|O|O||D||1
50454820|Champiñón tompeta blanca orgánico congelado|O|O||D||1
50454821|Champiñón woodear orgánico congelado|O|O||D||1
50454900|Mostazas orgánicas congeladas|O|O||D||1
50454901|Mostaza bambú  orgánica congelada|O|O||D||1
50454902|Mostaza ajo orgánica congelada|O|O||D||1
50454903|Mostaza hoja gigante orgánica congelada|O|O||D||1
50454904|Mostaza rojo en nieve orgánica congelada|O|O||D||1
50454905|Mostaza sureño orgánica congelada|O|O||D||1
50454906|Mostaza corazón envuelto orgánica congelada|O|O||D||1
50455000|Solanáceas (nightshades) orgánicas congeladas|O|O||D||1
50455001|Lámpara china orgánica congelada|O|O||D||1
50455002|Mora de jardín|O|O||D||1
50455003|Naranjilla orgánica orgánicas congeladas|O|O||D||1
50455004|Tomatillo orgánica congelada|O|O||D||1
50455100|Okras orgánicas congeladas|O|O||D||1
50455101|Okra artista orgánica congelada|O|O||D||1
50455102|Okra vinotinto orgánica congelada|O|O||D||1
50455103|Okra sin columna clemson orgánica congelada|O|O||D||1
50455104|Okra verde enano vaina larga orgánica congelada|O|O||D||1
50455105|Okra  mamut sin columna orgánica congelada|O|O||D||1
50455106|Okra terciopelo rojo orgánica congelada|O|O||D||1
50455107|Okra estrella de david reliquia orgánica congelada|O|O||D||1
50455200|Cebollas orgánicas congeladas|O|O||D||1
50455201|Cebolla albion orgánica congelada|O|O||D||1
50455202|Cebolla alisia craig orgánica congelada|O|O||D||1
50455203|Cebolla hirviendo orgánica congelada|O|O||D||1
50455204|Cebolla bufalo orgánica congelada|O|O||D||1
50455205|Cebolla bulbo orgánica congelada|O|O||D||1
50455206|Cebolla cremosa orgánica congelada|O|O||D||1
50455207|Cebolla amarillo expreso o – x orgánica congelada|O|O||D||1
50455208|Cebolla kelsae orgánica congelada|O|O||D||1
50455209|Cebolla gigante marshal globo fen orgánica congelada|O|O||D||1
50455210|Cebolla perla orgánica congelada|O|O||D||1
50455211|Cebolla baron rojo orgánica congelada|O|O||D||1
50455212|Cebolla roja orgánica congelada|O|O||D||1|Cebolla morada orgánica congelada
50455213|Cebolla rijnsberger orgánica congelada|O|O||D||1
50455214|Cebolla senshyu semi – globo amarillo orgánica congelada|O|O||D||1
50455215|Cebolla sturon orgánica congelada|O|O||D||1
50455216|Cebolla sturgatter orgánica congelada|O|O||D||1
50455217|Cebolla dulce orgánica congelada|O|O||D||1
50455218|Cebolla torpedo o rojo italiana orgánica congelada|O|O||D||1
50455219|Cebolla roja guardada orgánica congelada|O|O||D||1
50455220|Cebolla blanca guardada orgánica congelada|O|O||D||1
50455221|Cebolla amarilla guardada orgánica congelada|O|O||D||1
50455300|Maníes orgánicos congelados|O|O||D||1|Cacahuates orgánicos congelados
50455301|Maní bambara orgánico congelado|O|O||D||1|Cacahuate bambara orgánico congelado
50455302|Maní florunner orgánico congelado|O|O||D||1|Cacahuate florunner orgánico congelado
50455303|Maní husa / kerstings orgánico congelado|O|O||D||1|Cacahuate husa / kerstings  orgánico congelado
50455304|Maní español orgánico congelado|O|O||D||1|Cacahuate español orgánico congelado
50455305|Maní valencia orgánico congelado|O|O||D||1|Cacahuate valencia orgánico congelado
50455306|Maní virginia orgánico congelado|O|O||D||1|Cacahuate virginia orgánico congelado
50455400|Alverjas orgánicas congeladas|O|O||D||1|Alberjones orgánicos congelados
50455401|Alverja casco morado orgánico y congelado|O|O||D||1|Alberjón casco morado orgánico y congelado
50455402|Alverja pinkeye orgánica y congelado|O|O||D||1|Alberjón pinkeye orgánico y congelado
50455403|Alverja crowder orgánica y congelado|O|O||D||1|Alberjón crowder orgánico y congelado
50455404|Alverja acre blanca  orgánoca y congelada|O|O||D||1|Alberjón acre blanca orgánico y congelado
50455405|Alverja ojo negro orgánica y congelada|O|O||D||1|Alberjón ojo negro orgánico y congelado
50455406|Alverja crema zipper orgánica y congelada|O|O||D||1|Alberjón crema zipper orgánico y congelado
50455500|Pimientos orgánicos congelados|O|O||D||1|Chiles orgánicos congelados
50455501|Pimentón ají orgánico congelado|O|O||D||1|Ají orgánico congelado
50455502|Pimentón  árbol orgánico congelado|O|O||D||1|Chile de árbol orgánico congelado
50455503|Pimentón queso orgánico congelado|O|O||D||1
50455504|Pimentón chilaca orgánico congelado|O|O||D||1|Chilaca orgánico congelado
50455505|Pimentón cubanelles orgánico congelado|O|O||D||1|Chile cubanelle o pimienta italiana orgánica congelada
50455506|Pimentón fresno orgánico congelado|O|O||D||1|Chile fresno orgánico congelado
50455507|Pimentón kapia orgánico congelado|O|O||D||1|Chile kapia orgánico congelado
50455508|Pimentón coreano orgánico congelado|O|O||D||1|Chile cheongyang orgánico congelado
50455509|Pimentón manzano orgánico congelado|O|O||D||1|Chile manzano o de cera orgánico congelado
50455510|Pimentón melrose orgánico congelado|O|O||D||1
50455511|Pimentón chile amarillo orgánico congelado|O|O||D||1|Chile peruano amarillo orgánico congelado
50455512|Pimentón aji dulce orgánico congelado|O|O||D||1|Ají dulce orgánico congelado
50455513|Pimentón anaheim orgánico congelado|O|O||D||1
50455514|Pimentón ancho orgánico congelado|O|O||D||1|Chile ancho o mulato orgánico congelado
50455515|Pimentón campana orgánico congelado|O|O||D||1|Chile campana orgánico congelado
50455516|Pimentón cascabel orgánico congelado|O|O||D||1|Chile cascabel orgánico congelado
50455517|Pimentón cayenne orgánico congelado|O|O||D||1|Pimienta de Cayena o roja orgánico congelada
50455518|Pimentón anfitrión cereza orgánico congelado|O|O||D||1
50455519|Pimentón chitespin orgánico congelado|O|O||D||1|Chile chiltepín orgánico congelado
50455520|Pimentón dedo picante orgánico congelado|O|O||D||1|Chile Jwala orgánico congelado
50455521|Pimentón guajillo orgánico congelado|O|O||D||1|Chile guajillo orgánico congelado
50455522|Pimentón guerro orgánico congelado|O|O||D||1|Chile güero orgánico congelado
50455523|Pimentón habanero orgánico congelado|O|O||D||1|Chile habanero orgánico congelado
50455524|Pimentón cera de hungria orgánico congelado|O|O||D||1|Pimentón húngaro orgánico congelado
50455525|Pimentón jalapeño orgánico congelado|O|O||D||1|Chile cuaresmeño orgánico congelado, Chile jalapeño, seco es chipotle o morita orgánico congelado
50455526|Pimentón picante largo orgánico congelado|O|O||D||1|Chile cola de rata orgánico congelado
50455527|Pimentón marasol orgánico congelado|O|O||D||1|Chile mirasol orgánico congelado
50455528|Pimentón pasilla orgánico congelado|O|O||D||1|Chile pasilla orgánico congelado
50455529|Pimentón peperoncini orgánico congelado|O|O||D||1
50455530|Pimentón pequin orgánico congelado|O|O||D||1|Chile piquín orgánico congelado
50455531|Pimentón pimiento orgánico congelado|O|O||D||1|Pimiento morrón orgánico congelado
50455532|Pimentón poblano orgánico congelado|O|O||D||1|Chile poblano orgánico congelado
50455533|Pimentón scotch bonnet orgánico congelado|O|O||D||1|Pimientos Bonney o rojos Caribe orgánico congelado
50455534|Pimentón serrano orgánico congelado|O|O||D||1|Chile serrano orgánico congelado, Chile verde orgánico congelado
50455535|Pimentón tabasco orgánico congelado|O|O||D||1|Chile tabasco orgánico congelado
50455536|Pimentón tai  orgánico congelado|O|O||D||1|Chile ojo de pájaro orgánico congelado
50455537|Pimentón tepin orgánico congelado|O|O||D||1|Chile mosquito o catarina orgánico congelado
50455600|Papas orgánicas congeladas|O|O||D||1
50455601|Papa blanca larga orgánica congelada|O|O||D||1
50455602|Papa redonda blanca orgánica congelada|O|O||D||1
50455603|Papa redonda roja orgánica congelada|O|O||D||1|Papa de cambray orgánica congelada
50455604|Papa  russet orgánica congelada|O|O||D||1
50455605|Papa morada orgánica congelada|O|O||D||1
50455606|Papa amarilla orgánica congelada|O|O||D||1
50455607|Papa nueva orgánica congelada|O|O||D||1
50455608|Papa especial orgánica congelada|O|O||D||1
50455700|Nabos suecos orgánicos congelados|O|O||D||1
50455701|Nabo sueco acme orgánico congelado|O|O||D||1
50455702|Nabo sueco angela orgánico congelado|O|O||D||1
50455703|Nabo sueco el mejor orgánico congelado|O|O||D||1
50455704|Nabo sueco marian orgánico congelado|O|O||D||1
50455800|Vegetales marinos orgánicos congelados|O|O||D||1
50455801|Agar-agar orgánico congelado|O|O||D||1
50455802|Arame  orgánica congelada|O|O||D||1
50455803|Alga dulce orgánica congelada|O|O||D||1
50455804|Habichuelas vert de mer orgánica congelada|O|O||D||1
50455805|Hijiki orgánica congelada|O|O||D||1
50455806|Musgo irlandés orgánica congelada|O|O||D||1
50455807|Quelpo orgánico congelado|O|O||D||1
50455808|Laver orgánico congelado|O|O||D||1
50455809|Nori orgánico congelado|O|O||D||1
50455810|Alga roja orgánica congelada|O|O||D||1
50455811|Kale de mar orgánica congelada|O|O||D||1
50455812|Lechuga de mar orgánica congelada|O|O||D||1
50455813|Algas de mar orgánica congelada|O|O||D||1
50455814|Spirulina orgánica congelada|O|O||D||1
50455815|Susabi nuri orgánica congelada|O|O||D||1
50455816|Wakame orgánica congelada|O|O||D||1
50455900|Chalotes orgánicos congelados|O|O||D||1
50455901|Chalote atlántica orgánico congelado|O|O||D||1
50455902|Chalote creación orgánico congelado|O|O||D||1
50455903|Chalote drittler nido blanco orgánico congelado|O|O||D||1
50455904|Chalote gigante mejorado amarillo orgánico congelado|O|O||D||1
50455905|Chalote gourmet dorado orgánico congelado|O|O||D||1
50455906|Chalote grise de bagnolet orgánico congelado|O|O||D||1
50455907|Chalote hative de nort orgánico congelado|O|O||D||1
50455908|Chalote pikant orgánico congelado|O|O||D||1
50455909|Chalote papa roja orgánico congelado|O|O||D||1
50455910|Chalote sante orgánico congelado|O|O||D||1
50455911|Chalote topper orgánico congelado|O|O||D||1
50456000|Alazanes orgánicos congelados|O|O||D||1|Acederas orgánicas congeladas
50456001|Alazán dock orgánica congelada|O|O||D||1|Acedera dock orgánica congelada
50456002|Alazán jardín orgánica congelada|O|O||D||1|Acedera jardín orgánica congelada
50456003|Alazán oveja orgánica congelada|O|O||D||1|Acedera oveja orgánica congelada
50456004|Alazán madera orgánica congelada|O|O||D||1|Acedera madera orgánica congelada
50456100|Espinacas orgánicas congeladas|O|O||D||1
50456101|Espinaca americana orgánica congelada|O|O||D||1
50456102|Espinaca bloomsdale orgánica congelada|O|O||D||1
50456103|Espinaca invierno gigante orgánica congelada|O|O||D||1
50456104|Espinaca horenso orgánica congelada|O|O||D||1
50456105|Espinaca planta de hielo orgánica congelada|O|O||D||1
50456106|Espinaca  cuarto de cordero orgánica congelada|O|O||D||1
50456107|Espinaca malabra orgánica congelada|O|O||D||1
50456108|Espinaca mendania orgánica congelada|O|O||D||1
50456109|Espinaca nueva zelandia orgánica congelada|O|O||D||1
50456110|Espinaca orach orgánica congelada|O|O||D||1
50456111|Espinaca savoy orgánica congelada|O|O||D||1
50456112|Espinaca hoja de sigma orgánica congelada|O|O||D||1
50456113|Espinaca espacio orgánica congelada|O|O||D||1
50456114|Espinaca trinidad orgánica congelada|O|O||D||1
50456115|Espinaca agua orgánica congelada|O|O||D||1
50456116|Espinaca de agua sesa|O|O||D||1
50456200|Calabazas orgánicas congeladas|O|O||D||1
50456201|Calabaza boston orgánica congelada|O|O||D||1
50456202|Calabaza buttemut orgánica congelada|O|O||D||1
50456203|Calabaza costata romanesca orgánica congelada|O|O||D||1
50456204|Calabaza crookneck orgánica congelada|O|O||D||1
50456205|Calabaza  cucuzza orgánica congelada|O|O||D||1
50456206|Calabaza  delicata orgánica congelada|O|O||D||1
50456207|Calabaza  delisioso orgánica congelada|O|O||D||1
50456208|Calabaza verano dorado cuello torcido orgánica congelada|O|O||D||1
50456209|Calabaza prolífico temprano cuello recto orgánica congelada|O|O||D||1
50456210|Calabaza  oro orgánica congelada|O|O||D||1
50456211|Calabaza  jack pequeño orgánica congelada|O|O||D||1
50456212|Calabaza  campo de kentucky orgánica congelada|O|O||D||1
50456213|Calabaza marrow orgánica congelada|O|O||D||1
50456214|Calabaza  medio oriente orgánica congelada|O|O||D||1
50456215|Calabaza  miniatura orgánica congelada|O|O||D||1
50456216|Calabaza  orangetti orgánica congelada|O|O||D||1
50456217|Calabaza pattypan orgánica congelada|O|O||D||1
50456218|Calabaza  rondini orgánica congelada|O|O||D||1
50456219|Calabaza  redonda orgánica congelada|O|O||D||1
50456220|Calabaza  espagueti orgánica congelada|O|O||D||1
50456221|Calabaza  estripeti orgánica congelada|O|O||D||1
50456222|Calabaza  molde dulce orgánica congelada|O|O||D||1
50456223|Calabaza  empanada dulce orgánica congelada|O|O||D||1
50456224|Calabaza  premio triple  orgánica congelada|O|O||D||1
50456225|Calabaza waltham butternut orgánica congelada|O|O||D||1
50456226|Calabaza  arbusto scallop amarillo orgánica congelada|O|O||D||1
50456227|Calabaza cuello recto amarillo orgánica congelada|O|O||D||1
50456228|Calabaza zafiro orgánica congelada|O|O||D||1
50456229|Calabaza zucchini orgánica congelada|O|O||D||1
50456300|Batatas orgánicas congeladas|O|O||D||1|Camotes orgánicos congelados
50456301|Batata beauregard orgánica congelada|O|O||D||1|Camote beauregard orgánico congelado
50456302|Batata centennial orgánica congelada|O|O||D||1|Camote centennial orgánico congelado
50456303|Batata diane orgánica congelada|O|O||D||1|Camote diane orgánico congelado
50456304|Batata dulce garnet orgánica congelada|O|O||D||1|Camote dulce garnet orgánico congelado
50456305|Batata georgia dulce rojo orgánica congelada|O|O||D||1|Camote georgia dulce rojo orgánico congelado
50456306|Batata  dorado orgánica congelada|O|O||D||1|Camote dorado orgánico congelado
50456307|Batata hanna  orgánica congelada|O|O||D||1|Camote hanna orgánico congelado
50456308|Batata japonés orgánica congelada|O|O||D||1|Camote japonés orgánico congelado
50456309|Batata jersey orgánica congelada|O|O||D||1|Camote jersey orgánico congelado
50456310|Batata joya orgánica congelada|O|O||D||1|Camote joya orgánico congelado
50456311|Batata meryland roja orgánica congelada|O|O||D||1|Camote meryland roja orgánico congelado
50456312|Batata nema dorado orgánica congelada|O|O||D||1|Camote nema dorado orgánico congelado
50456313|Batata o´henry orgánica congelada|O|O||D||1|Camote o´henry orgánico congelado
50456314|Batata okinawan orgánica congelada|O|O||D||1|Camote okinawan orgánico congelado
50456315|Batata naranja orgánica congelada|O|O||D||1|Camote naranja orgánico congelado
50456316|Batata oriental orgánica congelada|O|O||D||1|Camote oriental orgánico congelado
50456317|Batata jersey rojo orgánica congelada|O|O||D||1|Camote jersey rojo orgánico congelado
50456318|Batata mar rojo orgánica congelada|O|O||D||1|Camote mar rojo orgánico congelado
50456319|Batata brillo rojo orgánica congelada|O|O||D||1|Camote brillo rojo orgánico congelado
50456320|Batata jersey amarillo orgánica congelada|O|O||D||1|Camote jersey amarillo orgánico congelado
50456400|Tomates orgánicos congelados|O|O||D||1|Jitomates orgánicos congelados
50456401|Tomates ailsa craig orgánico congelado|O|O||D||1|Jitomate ailsa craig orgánico congelado
50456402|Tomates alicante orgánico congelado|O|O||D||1|Jitomate alicante orgánico congelado
50456403|Tomates ciruela negra orgánico congelado|O|O||D||1|Jitomate ciruela negra orgánico congelado
50456404|Tomates vino de brandy orgánico congelado|O|O||D||1|Jitomate vino de brandy orgánico congelado
50456405|Tomates bella cereza orgánico congelado|O|O||D||1|Jitomate bella cereza orgánico congelado
50456406|Tomates cereza orgánico congelado|O|O||D||1|Jitomate cereza orgánico congelado
50456407|Tomates delicioso orgánico congelado|O|O||D||1|Jitomate delicioso orgánico congelado
50456408|Tomates dombito orgánico congelado|O|O||D||1|Jitomate dombito orgánico congelado
50456409|Tomates delicia del jardín orgánico congelado|O|O||D||1|Jitomate delicia del jardín orgánico congelado
50456410|Tomates uva orgánico congelado|O|O||D||1|Jitomate uva orgánico congelado
50456411|Tomates verde orgánico congelado|O|O||D||1|Tomate verde orgánico congelado
50456412|Tomates super marmande orgánico congelado|O|O||D||1|Jitomate super marmande orgánico congelado
50456413|Tomates rayas naturales marvel orgánico congelado|O|O||D||1|Jitomate rayas naturales marvel orgánico congelado
50456414|Tomates minibel orgánico congelado|O|O||D||1|Jitomate minibel orgánico congelado
50456415|Tomates oaxacan orgánico congelado|O|O||D||1|Jitomate oaxaca orgánico congelado
50456416|Tomates alerta roja orgánico congelado|O|O||D||1|Jitomate alerta roja orgánico congelado
50456417|Tomates roma vf orgánico congelado|O|O||D||1|Jitomate roma vf orgánico congelado
50456418|Tomates marzano zan orgánico congelado|O|O||D||1|Jitomate marzano zan orgánico congelado
50456419|Tomates shirley orgánico congelado|O|O||D||1|Jitomate shirley orgánico congelado
50456420|Tomates siberia orgánico congelado|O|O||D||1|Jitomate siberia orgánico congelado
50456421|Tomates super beefsteak orgánico congelado|O|O||D||1|Jitomate super beefsteak orgánico congelado
50456422|Tomates tigerella orgánico congelado|O|O||D||1|Jitomate tigerella orgánico congelado
50456423|Tomates tiny tim orgánico congelado|O|O||D||1|Jitomate tiny tim orgánico congelado
50456424|Tomates tumbler orgánico congelado|O|O||D||1|Jitomate tumbler orgánico congelado
50456425|Tomates cocktail amarillo orgánico congelado|O|O||D||1
50456426|Tomates forma de pera amarillo orgánico congelado|O|O||D||1
50456427|Tomates perfección amarilla orgánico congelado|O|O||D||1
50456500|Nabos orgánicos congelados|O|O||D||1
50456501|Nabo globo verde orgánico congelado|O|O||D||1
50456502|Nabo bola dorada orgánico congelado|O|O||D||1
50456503|Nabo mercado de manchester orgánico congelado|O|O||D||1
50456504|Nabo top morado milan orgánico congelado|O|O||D||1
50456505|Nabo top morado blanco orgánico congelado|O|O||D||1
50456506|Nabo bola de nieve orgánico congelado|O|O||D||1
50456507|Nabo tokio orgánico congelado|O|O||D||1
50456508|Nabo cruz de tokio orgánico congelado|O|O||D||1
50456600|Auyamas orgánicas congeladas|O|O||D||1|Calabazas gigantes orgánicas congeladas
50456601|Calabaza acorn congelada orgánica|O|O||D||1|Calabaza gigante acorn congelada orgánica
50456602|Calabaza gigante atlántico orgánica congelada|O|O||D||1|Calabaza gigante atlántico orgánica congelada
50456603|Calabaza banana rosado orgánica congelada|O|O||D||1|Calabaza gigante banana rosado orgánica congelada
50456604|Calabaza max grande orgánica congelada|O|O||D||1|Calabaza gigante max orgánica congelada
50456605|Calabaza  orgánica congelada|O|O||D||1|Calabaza de castilla orgánica congelada
50456606|Calabaza carnaval orgánica congelada|O|O||D||1|Calabaza gigante carnaval orgánica congelada
50456607|Auyama queso orgánica congelada|O|O||D||1|Calabaza gigante queso orgánica congelada
50456608|Calabaza príncipe coronado orgánica congelada|O|O||D||1|Calabaza gigante príncipe coronado orgánica congelada
50456609|Calabaza  curcibita orgánica congelada|O|O||D||1|Calabaza gigante curcibita orgánica congelada
50456610|Calabaza cushaw orgánica congelada|O|O||D||1|Calabaza gigante cushaw orgánica congelada
50456611|Calabaza  gigante auyama orgánica congelada|O|O||D||1
50456612|Calabaza  hubbard orgánica congelada|O|O||D||1|Calabaza gigante hubbard orgánica congelada
50456613|Calabaza  jerrahdale orgánica congelada|O|O||D||1|Calabaza gigante jerrahdale orgánica congelada
50456614|Calabaza  kabocha orgánica congelada|O|O||D||1|Calabaza gigante kabocha orgánica congelada
50456615|Calabaza queensland azul orgánica congelada|O|O||D||1|Calabaza gigante queensland azul orgánica congelada
50456616|Calabaza rouge vif détampes orgánica congelada|O|O||D||1|Calabaza gigante rouge vif détampes orgánica congelada
50456617|Calabaza  turban turco orgánica congelada|O|O||D||1|Calabaza gigante turban turco orgánica congelada
50456618|Calabaza  valenciano orgánica congelada|O|O||D||1|Calabaza gigante valenciano orgánica congelada
50456619|Calabaza  warted hubbard orgánica congelada|O|O||D||1|Calabaza gigante warted hubbard orgánica congelada
50456620|Auyama whangaparoa orgánica congelada|O|O||D||1|Calabaza gigante whangaparoa orgánica congelada
50456700|Ñames orgánicos congelados|O|O||D||1
50456701|Ñame agria africana orgánica congelada|O|O||D||1
50456702|Ñame agria asiática orgánica congelada|O|O||D||1
50456703|Ñame china orgánico congelado|O|O||D||1
50456704|Ñame globo orgánico congelado|O|O||D||1
50456705|Ñame grater orgánico congelado|O|O||D||1
50456706|Ñame japonesa orgánico congelado|O|O||D||1
50456707|Ñame lesser orgánico congelado|O|O||D||1
50456708|Ñame papa orgánico congelado|O|O||D||1
50456709|Ñame guinea blanca orgánico congelado|O|O||D||1
50456710|Ñame guinea amarillo orgánico congelado|O|O||D||1
50456800|Vegetales Nominant orgánicos congelados|O|O||D||1|Vegetales predominantes orgánicos congelados, Nopal orgánico congelado
50456801|Alfalfa orgánica congelada|O|O||D||1
50456802|Hojas de aloe orgánica congelada|O|O||D||1|Hoja de sábila orgánica congelada, Penca de sábila orgánica congelada
50456803|Apio orgánico congelado|O|O||D||1
50456804|Arrurruz orgánica congelada|O|O||D||1
50456805|Punta de flecha orgánica congelada|O|O||D||1|Sagittaria orgánica congelada
50456806|rúcula orgánica congelada|O|O||D||1
50456807|Arum orgánica congelada|O|O||D||1|Taro orgánico congelado
50456808|Raíz de bambú orgánica congelada|O|O||D||1
50456809|Hojas de plátano orgánica congelada|O|O||D||1
50456810|Batatas orgánica congelada|O|O||D||1
50456811|Brotes de frijol orgánicos congelados|O|O||D||1
50456812|Top de remolacha orgánica congelada|O|O||D||1|Betabel orgánico congelado
50456813|Melón agrio orgánico congelado|O|O||D||1|Balsamina orgánica congelada
50456814|Bayas de alcaparra orgánica orgánicas congeladas|O|O||D||1
50456815|Carob orgánico congelado|O|O||D||1|Algarrobo orgánico congelado
50456816|Cha-om orgánico congelado|O|O||D||1
50456817|Chayote o guatila orgánico congelado|O|O||D||1
50456818|Garbanzo orgánico congelado|O|O||D||1
50456819|Verde de crisantemos orgánico congelado|O|O||D||1
50456820|Verde de diente de león orgánico congelado|O|O||D||1
50456821|Diente de león orgánico congelado|O|O||D||1
50456822|Dasheen orgánico congelado|O|O||D||1
50456823|Puntas de alverja orgánico congelado|O|O||D||1
50456824|Diakon orgánico congelado|O|O||D||1|Rábano orgánico congelado
50456825|Donqua orgánica congelada|O|O||D||1|Ginseng hembra orgánica congelada
50456826|Helecho orgánico congelado|O|O||D||1|Brotes de helecho orgánico congelado
50456827|Gai choi orgánico congelado|O|O||D||1|Mostaza castaña orgánica congelada
50456828|Gailon orgánico congelado|O|O||D||1|Brécol chino orgánico congelado
50456829|Galanga orgánica congelada|O|O||D||1|Jengibre azul orgánico congelado
50456830|Raíz de jengibre orgánica congelada|O|O||D||1
50456831|Gobo orgánico congelado|O|O||D||1|Garduña orgánica congelada
50456832|Brote de lúpulo orgánico congelado|O|O||D||1
50456833|Rabano blanco orgánico congelado|O|O||D||1|Rábano de caballo orgánico congelado
50456834|Jicama orgánica congelada|O|O||D||1
50456835|Kuduz orgánica congelada|O|O||D||1|Kudzu orgánico congelado
50456836|Bulbo de margarita orgánico congelado|O|O||D||1|Bulbo de lili chino orgánico congelado
50456837|Linkok orgánico congelado|O|O||D||1
50456838|Lo bok orgánico congelado|O|O||D||1
50456839|Frijol largo orgánico congelado|O|O||D||1|Fríjol serpiente orgánico congelado
50456840|Raíz de lotus orgánico congelado|O|O||D||1|Rosa del Nilo orgánica congelada
50456841|Hojas de maguey orgánica congelada|O|O||D||1|Hoja de agave orgánica congelada, Penca de maguey orgánica congelada
50456842|Mallows orgánico congelado|O|O||D||1|Malva orgánica congelada
50456843|Sapote mamey orgánico congelado|O|O||D||1|Mamey orgánico congelado
50456844|Moap orgánico congelado|O|O||D||1
50456845|Moo orgánico congelado|O|O||D||1
50456846|Moqua orgánica congelada|O|O||D||1
50456847|Opos orgánicos congelados|O|O||D||1
50456848|Corazon de palma orgánico congelado|O|O||D||1|Palmito orgánico congelado
50456849|Paprika orgánica congelada|O|O||D||1
50456850|Purslane orgánica congelada|O|O||D||1|Verdolaga orgánica congelada
50456851|Raddichios orgánica congelada|O|O||D||1|Achicoria morada orgánica congelada
50456852|Sinquas orgánica congelada|O|O||D||1|Zapallo orgánico congelado
50456853|Frijol de soya orgánicos congelados|O|O||D||1
50456854|Spoonwart orgánico congelado|O|O||D||1|Hierba del escorbuto orgánica congelada
50456855|Uva tassele hyacinth orgánico congelado|O|O||D||1
50456856|Taro orgánico congelado|O|O||D||1|Tales orgánica congelada
50456857|Hoja de taro orgánica congelada|O|O||D||1
50456858|Tallo de taro orgánico congelado|O|O||D||1
50456859|Tapeguaje orgánico congelado|O|O||D||1
50456860|Verde tierno orgánico congelado|O|O||D||1
50456861|Tindora orgánico congelado|O|O||D||1
50456862|Árbol de cebolla orgánico congelado|O|O||D||1|Cebollas egipcias orgánica congelada
50456863|Udo orgánico congelado|O|O||D||1
50456864|Agua castaño orgánico congelado|O|O||D||1|Castaña de agua chinas orgánica congelada
50456865|Yumpi orgánico congelado|O|O||D||1|Akankong orgánico congelado
50456866|Yautia orgánico congelado|O|O||D||1|Mapuey orgánico congelado
50456867|Yu choy orgánico congelado|O|O||D||1
50456868|Yuca orgánica congelada|O|O||D||1
50456900|Alverjas dulces orgánicas congeladas|O|O||D||1|Chícharos orgánicos congelados
50456901|Alverja biquini orgánica congelada|O|O||D||1|Chícharo biquini orgánico congelado
50456902|Alverja cavalier orgánica congelada|O|O||D||1|Chícharo cavalier orgánico congelado
50456903|Alverja margarita orgánica congelada|O|O||D||1|Chícharo margarita orgánico congelado
50456904|Alverja dar fon orgánica congelada|O|O||D||1|Chícharo dar fon orgánico congelado
50456905|Alverja "early onward" orgánica congelada|O|O||D||1|Chícharo "early onward" orgánico congelado
50456906|Alverja primer feltham orgánica congelada|O|O||D||1|Chícharo primer feltham orgánico congelado
50456907|Alverja verde hurst shaft orgánica congelada|O|O||D||1|Chícharo verde hurst shaft orgánico congelado
50456908|Guisante oregón sugar pod orgánica congelada|O|O||D||1|Chícharo oregón sugar pod orgánico congelado
50456909|Alverja príncipe alberto orgánica congelada|O|O||D||1|Chícharo príncipe alberto orgánico congelado
50456910|Alverja reuzensuiker orgánica congelada|O|O||D||1|Chícharo reuzensuiker orgánico congelado
50461500|Alcachofas en lata o en frasco|O|O||D||1
50461501|Alcachofa brittany enlatada o envasada|O|O||D||1
50461502|Alcachofa cantonesa enlatada o envasada|O|O||D||1
50461503|Alcachofa francesa enlatada o envasada|O|O||D||1
50461504|Alcachofa globo verde enlatada o envasada|O|O||D||1
50461505|Alcachofa gros camus de bretaña enlatada o envasada|O|O||D||1
50461506|Alcachofa midi enlatada o envasada|O|O||D||1
50461507|Alcachofa globo morado enlatada o envasada|O|O||D||1
50461508|Alcachofa morado cecilia enlatada o envasada|O|O||D||1
50461509|Alcachofa romanesco enlatada o envasada|O|O||D||1
50461510|Alcachofa espinoso sardo enlatada o envasada|O|O||D||1
50461511|Alcachofa vert de laon enlatada o envasada|O|O||D||1
50461512|Alcachofa violeta de chiggiia enlatada o envasada|O|O||D||1
50461513|Alcachofa violeta de toscana enlatada o envasada|O|O||D||1
50461600|Espárragos en lata o en frasco|O|O||D||1
50461601|Espárragos connovers colosal enlatados o envasados|O|O||D||1
50461602|Espárragos franklin enlatados o envasados|O|O||D||1
50461603|Espárragos mamut gigante enlatados o envasados|O|O||D||1
50461604|Espárragos lucullus enlatados o envasados|O|O||D||1
50461605|Espárragos martha washington enlatados o envasados|O|O||D||1
50461700|Aguacates en lata o en frasco|O|O||D||1
50461701|Aguacate ajax b – 7 enlatado o envasado|O|O||D||1
50461702|Aguacate arue enlatado o envasado|O|O||D||1
50461703|Aguacate bacon enlatado o envasado|O|O||D||1
50461704|Aguacate benik enlatado o envasado|O|O||D||1
50461705|Aguacate bernecker enlatado o envasado|O|O||D||1
50461706|Aguacate beta enlatado o envasado|O|O||D||1
50461707|Aguacate biondo enlatado o envasado|O|O||D||1
50461708|Aguacate príncipe negro enlatado o envasado|O|O||D||1
50461709|Aguacate blair enlatado o envasado|O|O||D||1
50461710|Aguacate blair cabina enlatado o envasado|O|O||D||1
50461711|Aguacate cabina 1 enlatado o envasado|O|O||D||1
50461712|Aguacate cabina 3 enlatado o envasado|O|O||D||1
50461713|Aguacate cabina 5 enlatado o envasado|O|O||D||1
50461714|Aguacate cabina 7 enlatado o envasado|O|O||D||1
50461715|Aguacate cabina 8 enlatado o envasado|O|O||D||1
50461716|Aguacate brooks 1978 enlatado o envasado|O|O||D||1
50461717|Aguacate brookslate enlatado o envasado|O|O||D||1
50461718|Aguacate california haas enlatado o envasado|O|O||D||1
50461719|Aguacate catalina enlatado o envasado|O|O||D||1
50461720|Aguacate chica enlatado o envasado|O|O||D||1
50461721|Aguacate choquette enlatado o envasado|O|O||D||1
50461722|Aguacate cristina enlatado o envasado|O|O||D||1
50461723|Aguacate collison enlatado o envasado|O|O||D||1
50461724|Aguacate donnie enlatado o envasado|O|O||D||1
50461725|Aguacate dr dupis numero 2 enlatado o envasado|O|O||D||1
50461726|Aguacate dr. dupie  enlatado o envasado|O|O||D||1
50461727|Aguacate ettinger enlatado o envasado|O|O||D||1
50461728|Aguacate fuch enlatado o envasado|O|O||D||1
50461729|Aguacate fuch gwen enlatado o envasado|O|O||D||1
50461730|Aguacate fuerte enlatado o envasado|O|O||D||1
50461731|Aguacate gotham enlatado o envasado|O|O||D||1
50461732|Aguacate gossman enlatado o envasado|O|O||D||1
50461733|Aguacate guatemala sin pepa enlatado o envasado|O|O||D||1
50461734|Aguacate hall enlatado o envasado|O|O||D||1
50461735|Aguacate hardee enlatado o envasado|O|O||D||1
50461736|Aguacate haas enlatado o envasado|O|O||D||1
50461737|Aguacate herman enlatado o envasado|O|O||D||1
50461738|Aguacate hickson enlatado o envasado|O|O||D||1
50461739|Aguacate k-5 enlatado o envasado|O|O||D||1
50461740|Aguacate k- 9 enlatado o envasado|O|O||D||1
50461741|Aguacate cordero haas enlatado o envasado|O|O||D||1
50461742|Aguacate leona enlatado o envasado|O|O||D||1
50461743|Aguacate leona linda enlatado o envasado|O|O||D||1
50461744|Aguacate lisa p enlatado o envasado|O|O||D||1
50461745|Aguacate lisa loretta enlatado o envasado|O|O||D||1
50461746|Aguacate loretta enlatado o envasado|O|O||D||1
50461747|Aguacate lula enlatado o envasado|O|O||D||1
50461748|Aguacate lula mascarthur enlatado o envasado|O|O||D||1
50461749|Aguacate marcus enlatado o envasado|O|O||D||1
50461750|Aguacate melendez enlatado o envasado|O|O||D||1
50461751|Aguacate meya enlatado o envasado|O|O||D||1
50461752|Aguacate miguel p enlatado o envasado|O|O||D||1
50461753|Aguacate monroe enlatado o envasado|O|O||D||1
50461754|Aguacate murrieta verde enlatado o envasado|O|O||D||1
50461755|Aguacate nabal enlatado o envasado|O|O||D||1
50461756|Aguacate nadir enlatado o envasado|O|O||D||1
50461757|Aguacate nesbitt enlatado o envasado|O|O||D||1
50461758|Aguacate peterson enlatado o envasado|O|O||D||1
50461759|Aguacate pinelli enlatado o envasado|O|O||D||1
50461760|Aguacate pinkerton enlatado o envasado|O|O||D||1
50461761|Aguacate pollock enlatado o envasado|O|O||D||1
50461762|Aguacate puebla enlatado o envasado|O|O||D||1
50461763|Aguacate reed enlatado o envasado|O|O||D||1
50461764|Aguacaterue enlatado o envasado|O|O||D||1
50461765|Aguacateruehle enlatado o envasado|O|O||D||1
50461766|Aguacate ryan enlatado o envasado|O|O||D||1
50461767|Aguacate semil enlatado o envasado|O|O||D||1
50461768|Aguacate semil 43 enlatado o envasado|O|O||D||1
50461769|Aguacate simonds enlatado o envasado|O|O||D||1
50461770|Aguacate simpson enlatado o envasado|O|O||D||1
50461771|Aguacate taylor enlatado o envasado|O|O||D||1
50461772|Aguacate tonelada enlatado o envasado|O|O||D||1
50461773|Aguacate torre enlatado o envasado|O|O||D||1
50461774|Aguacate torre li enlatado o envasado|O|O||D||1
50461775|Aguacate trapp enlatado o envasado|O|O||D||1
50461776|Aguacate semilla de caribe enlatado o envasado|O|O||D||1
50461777|Aguacate wagner enlatado o envasado|O|O||D||1
50461778|Aguacate waldin enlatado o envasado|O|O||D||1
50461779|Aguacate wurtz enlatado o envasado|O|O||D||1
50461780|Aguacate zio p enlatado o envasado|O|O||D||1
50461781|Aguacate ziu enlatado o envasado|O|O||D||1
50461782|Aguacate zultano enlatado o envasado|O|O||D||1
50461800|Fríjoles en lata o en frasco|O|O||D||1
50461801|Frijoles anasazi ® enlatados o envasados|O|O||D||1
50461802|Frijoles appaloosa enlatados o envasados|O|O||D||1
50461803|Frijoles azuki enlatados o envasados|O|O||D||1
50461804|Frijoles barlotti enlatados o envasados|O|O||D||1
50461805|Frijoles appaloosa negra enlatados o envasados|O|O||D||1
50461806|Frijoles negros enlatados o envasados|O|O||D||1
50461807|Frijoles gran negros enlatados o envasados|O|O||D||1
50461808|Frijoles shackamaxon negro enlatados o envasados|O|O||D||1
50461809|Frijoles ojo negro enlatados o envasados|O|O||D||1
50461810|Frijoles bobby enlatados o envasados|O|O||D||1
50461811|Frijoles bolita enlatados o envasados|O|O||D||1
50461812|Frijoles esposa perezosa carmelita enlatados o envasados|O|O||D||1
50461813|Frijoles calipso enlatados o envasados|O|O||D||1
50461814|Frijoles canelini enlatados o envasados|O|O||D||1
50461815|Frijoles castor enlatados o envasados|O|O||D||1
50461816|Frijoles amarillo chino enlatados o envasados|O|O||D||1
50461817|Frijoles lengua de dragón enlatados o envasados|O|O||D||1
50461818|Frijoles soldado europeo enlatados o envasados|O|O||D||1
50461819|Frijoles fava enlatados o envasados|O|O||D||1
50461820|Frijoles flageolet enlatados o envasados|O|O||D||1
50461821|Frijoles  horticultura francesa enlatados o envasados|O|O||D||1
50461822|Frijoles marina francesa enlatados o envasados|O|O||D||1
50461823|Frijoles coco gigante blanco enlatados o envasados|O|O||D||1
50461824|Frijoles verdes enlatados o envasados|O|O||D||1
50461825|Frijoles romano verde enlatados o envasados|O|O||D||1
50461826|Frijoles guar gum enlatados o envasados|O|O||D||1
50461827|Frijoles haricot enlatados o envasados|O|O||D||1
50461828|Frijoles hyacinth enlatados o envasados|O|O||D||1
50461829|Frijoles tipo italiano enlatados o envasados|O|O||D||1
50461830|Frijoles asombro jackson enlatados o envasados|O|O||D||1
50461831|Frijoles ganado jacobs  enlatados o envasados|O|O||D||1
50461832|Frijoles asombro kentucky enlatados o envasados|O|O||D||1
50461833|Frijoles riñón enlatados o envasados|O|O||D||1
50461834|Frijoles lima enlatados o envasados|O|O||D||1
50461835|Frijoles madera enlatados o envasados|O|O||D||1
50461836|Frijoles medula enlatados o envasados|O|O||D||1
50461837|Frijoles mat enlatados o envasados|O|O||D||1
50461838|Frijoles monstoler ganzo salvaje enlatados o envasados|O|O||D||1
50461839|Frijoles  mortgage lifter enlatados o envasados|O|O||D||1
50461840|Frijoles polilla enlatados o envasados|O|O||D||1
50461841|Frijoles mung enlatados o envasados|O|O||D||1
50461842|Frijoles munsi wolf enlatados o envasados|O|O||D||1
50461843|Frijoles nuna enlatados o envasados|O|O||D||1
50461844|Frijoles pinto enlatados o envasados|O|O||D||1
50461845|Frijoles runner enlatados o envasados|O|O||D||1
50461846|String beans enlatados o envasados|O|O||D||1|Ayecote enlatado o envasado, Fríjol gordo enlatado o envasado
50461847|Frijoles habichuelas enlatados o envasados|O|O||D||1|Ejote enlatado o envasado, Fríjol tierno enlatado o envasado
50461848|Frijoles tamarind enlatados o envasados|O|O||D||1
50461849|Frijoles tonka enlatados o envasados|O|O||D||1
50461850|Frijoles cera enlatados o envasados|O|O||D||1
50461851|Frijoles winged enlatados o envasados|O|O||D||1
50461852|Frijoles largos enlatados o envasados|O|O||D||1
50461900|Remolachas  en lata o en frasco|O|O||D||1|Betabeles en lata o en frasco
50461901|Remolacha acción enlatada o envasada|O|O||D||1|Betabel acción enlatado o envasado
50461902|Remolacha albina vereduna enlatada o envasada|O|O||D||1|Betabel albina vereduna enlatado o envasado
50461903|Remolacha barababiotela de chiggia enlatada o envasada|O|O||D||1|Betabel barababiotela de chiggia enlatado o envasado
50461904|Remolacha boltardy enlatada o envasada|O|O||D||1|Betabel boltardy enlatado o envasado
50461905|Remolacha bonel enlatada o envasada|O|O||D||1|Betabel bonel enlatado o envasado
50461906|Remolacha burpees dorado enlatada o envasada|O|O||D||1|Betabel burpees dorado enlatado o envasado
50461907|Remolacha cheltenham tapa verde enlatada o envasada|O|O||D||1|Betabel cheltenham tapa verde enlatado o envasado
50461908|Remolacha cheltenham mono enlatada o envasada|O|O||D||1|Betabel cheltenham mono enlatado o envasado
50461909|Remolacha chioggia enlatada o envasada|O|O||D||1|Betabel chioggia enlatado o envasado
50461910|Remolacha cilindra enlatada o envasada|O|O||D||1|Betabel cilindra enlatado o envasado
50461911|Remolacha dégypte enlatada o envasada|O|O||D||1|Betabel dégypte enlatado o envasado
50461912|Remolacha detroit 2 rojo oscuro enlatada o envasada|O|O||D||1|Betabel detroit 2 rojo oscuro enlatado o envasado
50461913|Remolacha detroit 2 bala chiquita enlatada o envasada|O|O||D||1|Betabel detroit 2 bala chiquita enlatado o envasado
50461914|Remolacha egipcia plana  enlatada o envasada|O|O||D||1|Betabel egipcia plana enlatado o envasado
50461915|Remolacha  raíz de nabo egipcio enlatada o envasada|O|O||D||1|Betabel raíz de nabo egipcio enlatado o envasado
50461916|Remolacha fomanova enlatada o envasada|O|O||D||1|Betabel fomanova enlatado o envasado
50461917|Remolacha forono enlatada o envasada|O|O||D||1|Betabel forono enlatado o envasado
50461918|Remolacha monaco enlatada o envasada|O|O||D||1|Betabel mónaco enlatado o envasado
50461919|Remolacha monograma enlatada o envasada|O|O||D||1|Betabel monograma enlatado o envasado
50461920|Remolacha pronto enlatada o envasada|O|O||D||1|Betabel pronto enlatado o envasado
50461921|Remolacha regalía enlatada o envasada|O|O||D||1|Betabel regalía enlatado o envasado
50461922|Remolacha dulce enlatada o envasada|O|O||D||1|Betabel dulce enlatado o envasado
50462000|Brócolis  en lata o en frasco|O|O||D||1
50462001|Brócolini enlatado o envasado|O|O||D||1
50462002|Brócoli romanesco enlatado o envasado|O|O||D||1
50462003|Brócoli raab enlatado o envasado|O|O||D||1
50462004|Brócoli chino enlatado o envasado|O|O||D||1
50462100|Repollitos de Bruselas  en lata o en frasco|O|O||D||1|Coles de Bruselas en lata o en frasco
50462101|Repollitas de bruselas citade orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas citade orgánica enlatadas o envasadas
50462102|Repollitas de bruselas falstaff orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas falstaff orgánica enlatadas o envasadas
50462103|Repollitas de bruselas oliver orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas oliver orgánica enlatadas o envasadas
50462104|Repollitas de bruselas peer gynt orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas peer gynt orgánica enlatadas o envasadas
50462105|Repollitas de bruselas rampart orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas rampart orgánica enlatadas o envasadas
50462106|Repollitas de bruselas rubine orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas rubine orgánica enlatadas o envasadas
50462107|Repollitas de bruselas  widgeon orgánica enlatadas o envasadas|O|O||D||1|Coles de Bruselas widgeon orgánica enlatadas o envasadas
50462200|Cebollas de ensalada  en lata o en frasco|O|O||D||1|Cebollas de cambray  en lata o en frasco
50462201|Cebolla belstville ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray belstville enlatada o envasada
50462202|Cebolla feast ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray feast enlatada o envasada
50462203|Cebolla ishikura ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray ishikura enlatada o envasada
50462204|Cebolla mercado kyoto enlatada o envasada|O|O||D||1|Cebolla de cambray mercado kyoto enlatada o envasada
50462205|Cebolla barba roja ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray barba roja enlatada o envasada
50462206|Cebolla amigo rojo ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray amigo rojo enlatada o envasada
50462207|Cebolla santa claus enlatada o envasada|O|O||D||1|Cebolla de cambray santa claus enlatada o envasada
50462208|Cebolla tokyo ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray tokyo enlatada o envasada
50462209|Cebolla lisbon blanca ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray lisbon blanca enlatada o envasada
50462210|Cebolla invierno blanca ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray invierno blanca enlatada o envasada
50462211|Cebolla final de invierno ensalada enlatada o envasada|O|O||D||1|Cebolla de cambray final de invierno enlatada o envasada
50462300|Repollos en lata o en frasco|O|O||D||1|Coles en lata o en frasco
50462301|Repollo negro enlatado o envasado|O|O||D||1|Col negro enlatada o envasada
50462302|Repollo savoy enlatado o envasado|O|O||D||1|Col savoy enlatada o envasada
50462303|Repollo zorrillo enlatado o envasado|O|O||D||1|Col zorrillo enlatada o envasada
50462304|Repollo blanco enlatado o envasado|O|O||D||1|Col blanco enlatada o envasada
50462400|Cardos en lata o en frasco|O|O||D||1|Cardos comestibles en lata o en frasco
50462401|Cardos lunghi enlatados o envasados|O|O||D||1|Cardo comestible lunghi enlatados o envasados
50462402|Cardos gobbi enlatados o envasados|O|O||D||1|Cardo comestible gobbi enlatados o envasados
50462500|Zanahorias  en lata o en frasco|O|O||D||1
50462501|Zanahoria amsterdam enlatada o envasada|O|O||D||1
50462502|Zanahoria rey de otoño enlatada o envasada|O|O||D||1
50462503|Zanahoria berlicum enlatada o envasada|O|O||D||1
50462504|Zanahoria chantenay enlatada o envasada|O|O||D||1
50462505|Zanahoria nantes enlatada o envasada|O|O||D||1
50462506|Zanahoria mercado de parís enlatada o envasada|O|O||D||1
50462600|Coliflores  en lata o en frasco|O|O||D||1
50462601|Coliflor todo el año  enlatada o envasada|O|O||D||1
50462602|Coliflor alverda enlatada o envasada|O|O||D||1
50462603|coliflor otoño gigante 3 enlatada o envasada|O|O||D||1
50462604|Coliflo rdok elgon enlatada o envasada|O|O||D||1
50462605|Coliflor bola de nieve temprana enlatada o envasada|O|O||D||1
50462606|Coliflor luz de lima enlatada o envasada|O|O||D||1
50462607|Coliflor minaret enlatada o envasada|O|O||D||1
50462608|Coliflor buque de naranja enlatada o envasada|O|O||D||1
50462609|Coliflor capa morada enlatada o envasada|O|O||D||1
50462610|Coliflor bola de nieve enlatada o envasada|O|O||D||1
50462611|Coliflor invierno walcheren 3 enlatada o envasada|O|O||D||1
50462612|Coliflor piedra blanca enlatada o envasada|O|O||D||1
50462700|Apios en lata o en frasco|O|O||D||1
50462701|Apio celebridad enlatado o envasado|O|O||D||1
50462702|Apio nabo enlatado o envasado|O|O||D||1
50462703|Apio chino enlatado o envasado|O|O||D||1
50462704|Apio dinant francés enlatado o envasado|O|O||D||1
50462705|Apio gigante rosado enlatado o envasado|O|O||D||1
50462706|Apio gigante rojo enlatado o envasado|O|O||D||1
50462707|Apio gigante blanco enlatado o envasado|O|O||D||1
50462708|Apio dorado auto escalado enlatado o envasado|O|O||D||1
50462709|Apio "greensleeves" enlatado o envasado|O|O||D||1
50462710|Apio hopkins fenlander enlatado o envasado|O|O||D||1
50462711|Apio torre marfil enlatado o envasado|O|O||D||1
50462712|Apio lathom blanqueado enlatado o envasado|O|O||D||1
50462713|Apio sopa de amsterdam enlatado o envasado|O|O||D||1
50462714|Apio estándar cargado enlatado o envasado|O|O||D||1
50462715|Apio triunfo alto utah enlatado o envasado|O|O||D||1
50462800|Acelgas  en lata o en frasco|O|O||D||1
50462801|Acelga luz brillante enlatada o envasada|O|O||D||1
50462802|Acelga gigante fordhook enlatada o envasada|O|O||D||1
50462803|Acelga luculus enlatada o envasada|O|O||D||1
50462804|Acelga espinaca perpetua enlatada o envasada|O|O||D||1
50462805|Acelga ruibarbo enlatada o envasada|O|O||D||1
50462806|Acelga suizo enlatada o envasada|O|O||D||1
50462807|Acelga volcán  enlatada o envasada|O|O||D||1
50462808|Acelga rey blanco enlatada o envasada|O|O||D||1
50462900|Achicorias en lata o en frasco|O|O||D||1|Escarolas en lata o en frasco
50462901|Achicoria batavian hoja ancha enlatada o envasada|O|O||D||1|Escarola batavian hoja ancha enlatada o envasada
50462902|Achicoria en cornet de bordeaux enlatada o envasada|O|O||D||1|Escarola en cornet de bordeaux enlatada o envasada
50462903|Achicoria rollo verde ruffee enlatada o envasada|O|O||D||1|Escarola rollo verde ruffee enlatada o envasada
50462904|Achicoria roll verde enlatada o envasada|O|O||D||1|Escarola roll verde enlatada o envasada
50462905|Achicoria limnoe lone enlatada o envasada|O|O||D||1|Escarola limnoe lone enlatada o envasada
50462906|Achicoria pancalieri riccia enlatada o envasada|O|O||D||1|Escarola pancalieri riccia enlatada o envasada
50462907|Achicoria ensalada rey enlatada o envasada|O|O||D||1|Escarola ensalada rey enlatada o envasada
50462908|Achicoria sanda enlatada o envasada|O|O||D||1|Escarola sanda enlatada o envasada
50462909|Achicoria scarola verde enlatada o envasada|O|O||D||1|Escarola scarola verde enlatada o envasada
50462910|Achicoria tres fine maraichere enlatada o envasada|O|O||D||1|Escarola tres fine maraichere enlatada o envasada
50462911|Achicoria wallone freisee wescelkkopf enlatada o envasada|O|O||D||1|Escarola wallone freisee wescelkkopf enlatada o envasada
50463000|Repollos chinos en lata o en frasco|O|O||D||1|Coles chinas en lata o en frasco
50463001|Bok choy enlatado o envasado|O|O||D||1
50463002|Bok choy enano enlatado o envasado|O|O||D||1
50463003|Flor de repollo chino enlatada o envasada|O|O||D||1|Flor de col china enlatada o envasada
50463004|Choy sum enlatado o envasado|O|O||D||1
50463005|Col (bok choy) enano enlatado o envasado|O|O||D||1
50463006|Col (bok choy) fengshan enlatado o envasado|O|O||D||1
50463007|Col (bok choy) jade pagoda enlatado o envasado|O|O||D||1
50463008|Col (bok choy) kasumi enlatado o envasado|O|O||D||1
50463009|col (bok choy)  nerva enlatado o envasado|O|O||D||1
50463010|Col (bok choy) rosette enlatado o envasado|O|O||D||1
50463011|Col (bok choy) ruffles enlatado o envasado|O|O||D||1
50463012|Col (bok choy) hoja  santo serrated enlatado o envasado|O|O||D||1
50463013|Col (bok choy) shangahai enlatado o envasado|O|O||D||1
50463014|Shantung enlatado o envasado|O|O||D||1
50463015|Repollo tip top enlatado o envasado|O|O||D||1|Col china tip top enlatado o envasado
50463016|Yau choy sum enlatado o envasado|O|O||D||1
50463100|Cebollines en lata o en frasco|O|O||D||1
50463101|Cebollín chino enlatado o envasado|O|O||D||1
50463200|Maíces en lata o en frasco|O|O||D||1
50463201|Maíz aloha enlatado o envasado|O|O||D||1
50463202|Maíz alpine enlatado o envasado|O|O||D||1
50463203|Maíz ambrosia enlatado o envasado|O|O||D||1
50463204|Maíz argent enlatado o envasado|O|O||D||1
50463205|Maíz aspen enlatado o envasado|O|O||D||1
50463206|Maíz avalancha enlatado o envasado|O|O||D||1
50463207|Maíz biqueen enlatado o envasado|O|O||D||1
50463208|Maíz  bodacious enlatado o envasado|O|O||D||1
50463209|Maíz  mantequilla y azúcar enlatado o envasado|O|O||D||1
50463210|Maíz  calico belle enlatado o envasado|O|O||D||1
50463211|Maíz  camelot enlatado o envasado|O|O||D||1
50463212|Maíz  challengercrisp ‘n dulce enlatado o envasado|O|O||D||1
50463213|Maíz  campeón enlatado o envasado|O|O||D||1
50463214|Maíz  algodón de azúcar enlatado o envasado|O|O||D||1
50463215|Maíz  dártagnan enlatado o envasado|O|O||D||1
50463216|Maíz  dazzle enlatado o envasado|O|O||D||1
50463217|Maíz  diamante y oro enlatado o envasado|O|O||D||1
50463218|Maíz  divinidad enlatado o envasado|O|O||D||1
50463219|Maíz  delicia doble enlatado o envasado|O|O||D||1
50463220|Maíz  gema doble enlatado o envasado|O|O||D||1
50463221|Maíz  earlivee enlatado o envasado|O|O||D||1
50463222|Maíz  temprano extra dulce enlatado o envasado|O|O||D||1
50463223|Maíz excel enlatado o envasado|O|O||D||1
50463224|Maíz  cruz dorada bantam enlatado o envasado|O|O||D||1
50463225|Maíz  miel y crema enlatado o envasado|O|O||D||1
50463226|Maíz  miel y perla enlatado o envasado|O|O||D||1
50463227|Maíz  miel dulce enlatado o envasado|O|O||D||1
50463228|Maíz  hudson enlatado o envasado|O|O||D||1
50463229|Maíz  dorado illini enlatado o envasado|O|O||D||1
50463230|Maíz  illini extra dulce enlatado o envasado|O|O||D||1
50463231|Maíz  increíble enlatado o envasado|O|O||D||1
50463232|Maíz  lochief enlatado o envasado|O|O||D||1
50463233|Maíz jubileo enlatado o envasado|O|O||D||1
50463234|Maíz jupbileo super dulce enlatado o envasado|O|O||D||1
50463235|Maíz  confite korn enlatado o envasado|O|O||D||1
50463236|Maíz  beso y acuso enlatado o envasado|O|O||D||1
50463237|Maíz  lancelot enlatado o envasado|O|O||D||1
50463238|Maíz dulce maple enlatado o envasado|O|O||D||1
50463239|Maíz  medley enlatado o envasado|O|O||D||1
50463240|Maíz merlin enlatado o envasado|O|O||D||1
50463241|Maíz milagro enlatado o envasado|O|O||D||1
50463242|Maíz nk – 199 enlatado o envasado|O|O||D||1
50463243|Maíz durazno y crema enlatado o envasado|O|O||D||1
50463244|Maíz blanco perla enlatado o envasado|O|O||D||1
50463245|Maíz  pegasus enlatado o envasado|O|O||D||1
50463246|Maíz  fenomenal enlatado o envasado|O|O||D||1
50463247|Maíz  dama de platino enlatado o envasado|O|O||D||1
50463248|Maíz  precioso enlatado o envasado|O|O||D||1
50463249|Maíz   pristine enlatado o envasado|O|O||D||1
50463250|Maíz  rápido enlatado o envasado|O|O||D||1
50463251|Maíz  radiante enlatado o envasado|O|O||D||1
50463252|Maíz  seneca brave enlatado o envasado|O|O||D||1
50463253|Maíz  amanecer seneca enlatado o envasado|O|O||D||1
50463254|Maíz  horizonte seneca enlatado o envasado|O|O||D||1
50463255|Maíz  brillo de estrella seneca enlatado o envasado|O|O||D||1
50463256|Maíz  noche blanca seneca enlatado o envasado|O|O||D||1
50463257|Maíz  showcase enlatado o envasado|O|O||D||1
50463258|Maíz  reina plateada enlatado o envasado|O|O||D||1
50463259|Maíz  bella nieve enlatado o envasado|O|O||D||1
50463260|Maíz nieve de primavera enlatado o envasado|O|O||D||1
50463261|Maíz  premio de primavera enlatado o envasado|O|O||D||1
50463262|Maíz  azúcar y oro enlatado o envasado|O|O||D||1
50463263|Maíz rollo de azúcar enlatado o envasado|O|O||D||1
50463264|Maíz nieve de azúcar enlatado o envasado|O|O||D||1
50463265|Maíz baile de sol enlatado o envasado|O|O||D||1
50463266|Maíz estrella tell enlatado o envasado|O|O||D||1
50463267|Maíz terminador enlatado o envasado|O|O||D||1
50463268|Maíz tesoro enlatado o envasado|O|O||D||1
50463269|Maíz tuxedo enlatado o envasado|O|O||D||1
50463300|Berros  en lata o en frasco|O|O||D||1
50463301|Berros de tierra enlatados o envasados|O|O||D||1
50463302|Nasturtium enlatado o envasado|O|O||D||1
50463303|Berros de agua enlatados o envasados|O|O||D||1
50463304|Berros de invierno enlatados o envasados|O|O||D||1
50463400|Cocombros en lata o en frasco|O|O||D||1|Pepinos cohombro en lata o en frasco
50463401|Cocombro arena enlatado o envasado|O|O||D||1|Pepino cohombro arena enlatado o envasado
50463402|Cocombro americano enlatado o envasado|O|O||D||1|Pepino cohombro americano enlatado o envasado
50463403|Cocombro atena enlatado o envasado|O|O||D||1|Pepino cohombro atena enlatado o envasado
50463404|Cocombro blanco lungo de parigi enlatado o envasado|O|O||D||1|Pepino cohombro blanco lungo de parigi enlatado o envasado
50463405|Cocombro verde burpless buen sabor enlatado o envasado|O|O||D||1|Pepino cohombro verde burpless buen sabor enlatado o envasado
50463406|Cocombro chicago pickling enlatado o envasado|O|O||D||1|Pepino cohombro chicago pickling enlatado o envasado
50463407|Cocombro manzana cristal enlatado o envasado|O|O||D||1|Pepino cohombro manzana cristal enlatado o envasado
50463408|Cocombro limón cristal enlatado o envasado|O|O||D||1|Pepino cohombro limón cristal enlatado o envasado
50463409|Cocombro danimas enlatado o envasado|O|O||D||1|Pepino cohombro danimas enlatado o envasado
50463410|Cocombro gherkin enlatado o envasado|O|O||D||1|Pepino cohombro gherkin enlatado o envasado
50463411|Cocombro hokus enlatado o envasado|O|O||D||1|Pepino cohombro hokus enlatado o envasado
50463412|Cocombro japonés enlatado o envasado|O|O||D||1|Pepino cohombro japonés enlatado o envasado
50463413|Cocombro karela enlatado o envasado|O|O||D||1|Pepino cohombro karela enlatado o envasado
50463414|Cocombro korila enlatado o envasado|O|O||D||1|Pepino cohombro korila enlatado o envasado
50463415|Cocombro verde largo mejorado enlatado o envasado|O|O||D||1|Pepino cohombro verde largo mejorado enlatado o envasado
50463416|Cocombro mas mercado enlatado o envasado|O|O||D||1|Pepino cohombro mas mercado enlatado o envasado
50463417|Cocombro enano enlatado o envasado|O|O||D||1|Pepino cohombro enano enlatado o envasado
50463418|Cocombro pickling nacional enlatado o envasado|O|O||D||1|Pepino cohombro pickling nacional enlatado o envasado
50463419|Cocombro persa enlatado o envasado|O|O||D||1|Pepino cohombro persa enlatado o envasado
50463420|Cocombro telégrafo enlatado o envasado|O|O||D||1|Pepino cohombro telégrafo enlatado o envasado
50463421|Cocombro telégrafo mejorado enlatado o envasado|O|O||D||1|Pepino cohombro telégrafo mejorado enlatado o envasado
50463422|Cocombro vert de massy cornichon enlatado o envasado|O|O||D||1|Pepino cohombro vert de massy cornichon enlatado o envasado
50463423|Cocombro yamato enlatado o envasado|O|O||D||1|Pepino cohombro yamato enlatado o envasado
50463500|Berenjenas en lata o en frasco|O|O||D||1
50463501|Berenjena bambino enlatada o envasada|O|O||D||1
50463502|Berenjena  belleza negra enlatada o envasada|O|O||D||1
50463503|Berenjena  negra enorme enlatada o envasada|O|O||D||1
50463504|Berenjena  chino enlatada o envasada|O|O||D||1
50463505|Berenjena  huevo de pascua enlatada o envasada|O|O||D||1
50463506|Berenjena  filipino enlatada o envasada|O|O||D||1
50463507|Berenjena   mercado de florida enlatada o envasada|O|O||D||1
50463508|Berenjena  india enlatada o envasada|O|O||D||1
50463509|Berenjena  italiano enlatada o envasada|O|O||D||1
50463510|Berenjena  japonés enlatada o envasada|O|O||D||1
50463511|Berenjena  morado largo enlatada o envasada|O|O||D||1
50463512|Berenjena   rayas larga enlatada o envasada|O|O||D||1
50463513|Berenjena  mercado de dinero enlatada o envasada|O|O||D||1
50463514|Berenjena  ova enlatada o envasada|O|O||D||1
50463515|Berenjena   arveja enlatada o envasada|O|O||D||1
50463516|Berenjena  tom bajito enlatada o envasada|O|O||D||1
50463517|Berenjena  siciliano enlatada o envasada|O|O||D||1
50463518|Berenjena  tailandés enlatada o envasada|O|O||D||1
50463519|Berenjena  violeta de florencia enlatada o envasada|O|O||D||1
50463520|Berenjena  blanco enlatada o envasada|O|O||D||1
50463600|Endivias en lata o en frasco|O|O||D||1
50463601|Endivias witloof de brucelas orgánica enlatadas o envasadas|O|O||D||1
50463602|Endivias francocastel orgánica enlatadas o envasadas|O|O||D||1
50463603|Endivias catalogna de galantina orgánica enlatadas o envasadas|O|O||D||1
50463604|Endivias chioggia orgánica enlatadas o envasadas|O|O||D||1
50463605|Endivias grumolo verde orgánica enlatadas o envasadas|O|O||D||1
50463606|Endivias raíz larga magdeburg orgánica enlatadas o envasadas|O|O||D||1
50463607|Endivias palla rosa zorzi precoce orgánica enlatadas o envasadas|O|O||D||1
50463608|Endivias radice amare orgánica enlatadas o envasadas|O|O||D||1
50463609|Endivias rosa de traviso orgánica enlatadas o envasadas|O|O||D||1
50463610|Endivias  rosa de verona orgánica enlatadas o envasadas|O|O||D||1
50463611|Endivias soncino orgánica enlatadas o envasadas|O|O||D||1
50463612|Endivias sugarthi orgánica enlatadas o envasadas|O|O||D||1
50463613|Endivias verona orgánica enlatadas o envasadas|O|O||D||1
50463614|Endivias witloof zoom orgánica enlatadas o envasadas|O|O||D||1
50463700|Hinojos en lata o en frasco|O|O||D||1
50463701|Hinojo cantino enlatado o envasado|O|O||D||1
50463702|Hinojo fino enlatado o envasado|O|O||D||1
50463703|Hinojoherald enlatado o envasado|O|O||D||1
50463704|Hinojo perfección enlatado o envasado|O|O||D||1
50463705|Hinojo sirio enlatado o envasado|O|O||D||1
50463706|Hinojo florencia dulce enlatado o envasado|O|O||D||1
50463707|Hinojo tardo enlatado o envasado|O|O||D||1
50463800|Ajos en lata o en frasco|O|O||D||1
50463801|Ajo tarde california enlatado o envasado|O|O||D||1
50463802|Ajo tallos chinos enlatado o envasado|O|O||D||1
50463803|Ajo cebollin  enlatado o envasado|O|O||D||1
50463804|Ajo germidor enlatado o envasado|O|O||D||1
50463805|Ajo guardado largo enlatado o envasado|O|O||D||1
50463806|Ajo ramson enlatado o envasado|O|O||D||1
50463807|Ajo rocambola enlatado o envasado|O|O||D||1
50463808|Ajo rosa de lautrec enlatado o envasado|O|O||D||1
50463809|Ajo solent blanco enlatado o envasado|O|O||D||1
50463810|Ajo morado español enlatado o envasado|O|O||D||1
50463811|Ajo valentina italiana enlatado o envasado|O|O||D||1
50463900|Calabazas en lata o en frasco|O|O||D||1
50463901|Petula enlatada o envasada|O|O||D||1|Luffa enlatada o envasada
50463902|Melon amargo enlatado o envasado|O|O||D||1
50463903|Botella calabaza enlatada o envasada|O|O||D||1|Mate enlatado o envasado
50463904|Calabash gounds enlatada o envasada|O|O||D||1|Calabaza de peregrino enlatada o envasada
50463905|Melón peludo enlatado o envasado|O|O||D||1
50463906|Calabaza amarga enlatada o envasada|O|O||D||1
50463907|Loofah suave enlatado o envasado|O|O||D||1|Zapatillo suave enlatado o envasado
50463908|Serpiente de calabaza enlatada o envasada|O|O||D||1|Chichinda enlatada o envasada
50463909|Calabaza larga amarga enlatada o envasada|O|O||D||1
50463910|Calabaza tinda enlatada o envasada|O|O||D||1
50463911|Calabaza tindoori enlatada o envasada|O|O||D||1
50464000|Guisantes en lata o en frasco|O|O||D||1|Chícharos en lata o en frasco
50464001|Guisante chino enlatada o envasada|O|O||D||1|Chícharo chino enlatado o envasado
50464002|Guisante inglés enlatada o envasada|O|O||D||1|Chícharo inglés enlatado o envasado
50464003|Guisante de jardín enlatada o envasada|O|O||D||1|Chícharo de jardín enlatado o envasado
50464004|Guisante nieve enlatada o envasada|O|O||D||1|Chícharo nieve enlatado o envasado
50464005|Guisante snap dulce enlatada o envasada|O|O||D||1|Chícharo snap dulce enlatado o envasado
50464100|Hierbas en lata o en frasco|O|O||D||1|Perejil enlatado o envasado, Yerbabuena o hierbabuena enlatada o envasada
50464101|Albahaca enlatada o envasada|O|O||D||1
50464102|Laurel enlatado o envasado|O|O||D||1
50464103|Borraja enlatada o envasada|O|O||D||1
50464104|Alcaravea enlatada o envasada|O|O||D||1
50464105|Perifollo enlatado o envasado|O|O||D||1
50464106|Cilantro enlatado o envasado|O|O||D||1
50464107|Chipolinos enlatado o envasado|O|O||D||1
50464108|Hoja de curry enlatada o envasada|O|O||D||1
50464109|Eneldo enlatado o envasado|O|O||D||1
50464110|Epazote enlatado o envasado|O|O||D||1
50464111|Fenogreco enlatado o envasado|O|O||D||1
50464112|Limonaria enlatada o envasada|O|O||D||1|Té de limón enlatado o envasado
50464113|Mejorana enlatada o envasada|O|O||D||1
50464114|Menta enlatada o envasada|O|O||D||1
50464115|Orégano enlatado o envasado|O|O||D||1
50464116|Pápalo enlatado o envasado|O|O||D||1
50464117|Pápalo delgado enlatado o envasado|O|O||D||1
50464118|Perilla enlatada o envasada|O|O||D||1|Albahaca japonesa enlatada o envasada
50464119|Recao  enlatado o envasado|O|O||D||1
50464120|Romero enlatado o envasado|O|O||D||1
50464121|Salvia enlatada o envasada|O|O||D||1
50464122|Salsifí enlatada o envasada|O|O||D||1|Barba cabruna enlatada o envasada
50464123|Satureja enlatada o envasada|O|O||D||1|Ajedreas  enlatada o envasada
50464124|Estragón enlatado o envasado|O|O||D||1|Tarragón  enlatado o envasado
50464125|Tomillo enlatado o envasado|O|O||D||1
50464126|Tumeric enlatado o envasado|O|O||D||1|Cúrcuma enlatada o envasada
50464127|Verdolaga enlatada o envasada|O|O||D||1
50464200|Coles en lata o en frasco|O|O||D||1
50464201|Col rizada enlatada o envasada|O|O||D||1
50464202|Repollo verde enlatado o envasado|O|O||D||1
50464300|Colinabos en lata o en frasco|O|O||D||1|Colirrábanos en lata o en frasco
50464301|Colinabo estrella azur enlatado o envasado|O|O||D||1|Colirrábano estrella azur enlatado o envasado
50464302|Colinabo verde viena enlatado o envasado|O|O||D||1|Colirrábano verde viena enlatado o envasado
50464303|Colinabo lanro enlatado o envasado|O|O||D||1|Colirrábano lanro enlatado o envasado
50464304|Colinabo viena morada enlatado o envasado|O|O||D||1|Colirrábano viena morada enlatado o envasado
50464305|Colinabo trero rowel enlatado o envasado|O|O||D||1|Colirrábano trero rowel enlatado o envasado
50464306|Colinabo viena blanca enlatado o envasado|O|O||D||1|Colirrábano viena blanca enlatado o envasado
50464400|Puerros en lata o en frasco|O|O||D||1|Poros en lata o en frasco
50464401|Puerro cobra gigante otoño enlatado o envasado|O|O||D||1|Poro cobra gigante otoño enlatado o envasado
50464402|Puerro otoño mamut 2 enlatado o envasado|O|O||D||1|Poro otoño mamut 2 enlatado o envasado
50464403|Puerro blue de solaise enlatado o envasado|O|O||D||1|Poro blue de solaise enlatado o envasado
50464404|Puerro cortina enlatado o envasado|O|O||D||1|Poro cortina enlatado o envasado
50464405|Puerro prelina enlatado o envasado|O|O||D||1|Poro prelina enlatado o envasado
50464406|Puerro salvaje enlatado o envasado|O|O||D||1|Poro salvaje enlatado o envasado
50464500|Lentejas  en lata o en frasco|O|O||D||1
50464501|Lenteja beluga enlatada o envasada|O|O||D||1
50464502|Lenteja  verde francesa enlatada o envasada|O|O||D||1
50464503|Lenteja verde enlatada o envasada|O|O||D||1
50464504|Lenteja crimson pequeña enlatada o envasada|O|O||D||1
50464505|Lenteja pardina española enlatada o envasada|O|O||D||1
50464506|Lenteja roja separada enlatada o envasada|O|O||D||1
50464507|Lenteja amarilla separad enlatada o envasada|O|O||D||1
50464508|Lenteja tarahumara rosada enlatada o envasada|O|O||D||1
50464600|Lechugas en lata o en frasco|O|O||D||1
50464601|Lechuga  bibb enlatada o envasada|O|O||D||1
50464602|Lechuga  boston enlatada o envasada|O|O||D||1
50464603|Lechuga frisee enlatada o envasada|O|O||D||1
50464604|Lechuga rosa lola enlatada o envasada|O|O||D||1
50464605|Lechuga  mixta masculina enlatada o envasada|O|O||D||1
50464606|Lechuga mizuna enlatada o envasada|O|O||D||1
50464607|Lechuga hoja roja enlatada o envasada|O|O||D||1
50464608|Lechuga oja roja roble enlatada o envasada|O|O||D||1
50464609|Lechuga romana ruby enlatada o envasada|O|O||D||1
50464610|Lechuga romana bebé roja enlatada o envasada|O|O||D||1
50464611|Lechuga cabeza de mantequilla enlatada o envasada|O|O||D||1
50464612|Lechuga china enlatada o envasada|O|O||D||1|Lechuga orejona enlatada o envasada
50464613|Lechuga cabeza tostada enlatada o envasada|O|O||D||1
50464614|Lechuga hoja verde enlatada o envasada|O|O||D||1
50464615|Lechuga iceberg enlatada o envasada|O|O||D||1
50464616|Lechuga cordero enlatada o envasada|O|O||D||1
50464617|Lechuga hoja suelta enlatada o envasada|O|O||D||1
50464618|Lechuga mache enlatada o envasada|O|O||D||1
50464619|Lechuga boston roja enlatada o envasada|O|O||D||1
50464620|Lechuga cabeza roja enlatada o envasada|O|O||D||1
50464621|Lechuga romana enlatada o envasada|O|O||D||1
50464622|Lechuga mostza roja rusa enlatada o envasada|O|O||D||1
50464623|Lechuga tatsoi enlatada o envasada|O|O||D||1
50464700|Ñames en lata o en frasco|O|O||D||1
50464701|Ñame amarilla enlatada o envasada|O|O||D||1
50464702|Ñame blanca enlatada o envasada|O|O||D||1
50464703|Ñame coco enlatada o envasada|O|O||D||1
50464704|Ñame eddoes enlatada o envasada|O|O||D||1
50464705|Ñame isleña enlatada o envasada|O|O||D||1
50464706|Ñame lila enlatada o envasada|O|O||D||1
50464800|Hongos o champiñones en lata o en frasco|O|O||D||1
50464801|Champiñón trompeta negra enlatado o envasado|O|O||D||1
50464802|Champiñón carmelito enlatado o envasado|O|O||D||1
50464803|Champiñón  enlatado o envasado|O|O||D||1
50464804|Champiñón chanterelle enlatado o envasado|O|O||D||1
50464805|Champiñón cremini enlatado o envasado|O|O||D||1
50464806|Champiñón enoki enlatado o envasado|O|O||D||1
50464807|Champiñón puercoespín enlatado o envasado|O|O||D||1
50464808|Champiñón gallina del bosque enlatado o envasado|O|O||D||1
50464809|Champiñón langosta enlatado o envasado|O|O||D||1
50464810|Champiñón morels enlatado o envasado|O|O||D||1
50464811|Champiñón ostra enlatado o envasado|O|O||D||1
50464812|Champiñón pleurotus enlatado o envasado|O|O||D||1
50464813|Champiñón pompom enlatado o envasado|O|O||D||1
50464814|Champiñón porcieni enlatado o envasado|O|O||D||1
50464815|Champiñón portobello enlatado o envasado|O|O||D||1
50464816|Champiñón shitake enlatado o envasado|O|O||D||1
50464817|Champiñón shimeji enlatado o envasado|O|O||D||1
50464818|Champiñón san jorge enlatado o envasado|O|O||D||1
50464819|Champiñón blanco enlatado o envasado|O|O||D||1
50464820|Champiñón tompeta blanca enlatado o envasado|O|O||D||1
50464821|Champiñón woodear enlatado o envasado|O|O||D||1
50464900|Mostazas en lata o en frasco|O|O||D||1
50464901|Mostaza bambú  enlatada o envasada|O|O||D||1
50464902|Mostaza ajo enlatada o envasada|O|O||D||1
50464903|Mostaza hoja gigante enlatada o envasada|O|O||D||1
50464904|Mostaza rojo en nieve enlatada o envasada|O|O||D||1
50464905|Mostaza sureño enlatada o envasada|O|O||D||1
50464906|Mostaza corazón envuelto enlatada o envasada|O|O||D||1
50465000|Solanáceas (nightshades) en lata o en frasco|O|O||D||1
50465001|Lámpara china enlatada o envasada|O|O||D||1
50465002|Mora de jardín|O|O||D||1
50465003|Naranjilla orgánica enlatadas o envasadas|O|O||D||1
50465004|Tomatillo enlatada o envasada|O|O||D||1
50465100|Okras en lata o en frasco|O|O||D||1
50465101|Okra artista enlatada o envasada|O|O||D||1
50465102|Okra vinotinto enlatada o envasada|O|O||D||1
50465103|Okra sin columna clemson enlatada o envasada|O|O||D||1
50465104|Okra verde enano vaina larga enlatada o envasada|O|O||D||1
50465105|Okra  mamut sin columna enlatada o envasada|O|O||D||1
50465106|Okra terciopelo rojo enlatada o envasada|O|O||D||1
50465107|Okra estrella de david reliquia enlatada o envasada|O|O||D||1
50465200|Cebollas en lata o en frasco|O|O||D||1
50465201|Cebolla albion enlatada o envasada|O|O||D||1
50465202|Cebolla alisia craig enlatada o envasada|O|O||D||1
50465203|Cebolla hirviendo enlatada o envasada|O|O||D||1
50465204|Cebolla bufalo enlatada o envasada|O|O||D||1
50465205|Cebolla bulbo enlatada o envasada|O|O||D||1
50465206|Cebolla cremosa enlatada o envasada|O|O||D||1
50465207|Cebolla amarillo expreso o – x enlatada o envasada|O|O||D||1
50465208|Cebolla kelsae enlatada o envasada|O|O||D||1
50465209|Cebolla gigante marshal globo fen enlatada o envasada|O|O||D||1
50465210|Cebolla perla enlatada o envasada|O|O||D||1
50465211|Cebolla baron rojo enlatada o envasada|O|O||D||1
50465212|Cebolla roja enlatada o envasada|O|O||D||1|Cebolla morada enlatada o envasada
50465213|Cebolla rijnsberger enlatada o envasada|O|O||D||1
50465214|Cebolla senshyu semi – globo amarillo enlatada o envasada|O|O||D||1
50465215|Cebolla sturon enlatada o envasada|O|O||D||1
50465216|Cebolla sturgatter enlatada o envasada|O|O||D||1
50465217|Cebolla dulce enlatada o envasada|O|O||D||1
50465218|Cebolla torpedo o rojo italiana enlatada o envasada|O|O||D||1
50465219|Cebolla roja guardada enlatada o envasada|O|O||D||1
50465220|Cebolla blanca guardada enlatada o envasada|O|O||D||1
50465221|Cebolla amarilla guardada enlatada o envasada|O|O||D||1
50465300|Maníes en lata o en frasco|O|O||D||1|Cacahuates en lata o en frasco
50465301|Maní bambara enlatado o envasado|O|O||D||1|Cacahuate bambara enlatado o envasado
50465302|Maní florunner enlatado o envasado|O|O||D||1|Cacahuate florunner enlatado o envasado
50465303|Maní husa / kerstings enlatado o envasado|O|O||D||1|Cacahuate husa / kerstings  enlatado o envasado
50465304|Maní español enlatado o envasado|O|O||D||1|Cacahuate español enlatado o envasado
50465305|Maní valencia enlatado o envasado|O|O||D||1|Cacahuate valencia enlatado o envasado
50465306|Maní virginia enlatado o envasado|O|O||D||1|Cacahuate virginia enlatado o envasado
50465400|Alverjas en lata o en frasco|O|O||D||1|Alberjones en lata o en frasco
50465401|Alverja casco morado enlatada o envasada|O|O||D||1|Alberjón casco morado en lata o envasado
50465402|Alverja pinkeye enlatada o envasada|O|O||D||1|Alberjón pinkeye en lata o envasado
50465403|Alverja crowder enlatada o envasada|O|O||D||1|Alberjón crowder en lata o envasado
50465404|Alverja acre blanca enlatada o envasada|O|O||D||1|Alberjón acre blanca en lata o envasado
50465405|Alverja ojo negro enlatada o envasada|O|O||D||1|Alberjón ojo negro en lata o envasado
50465406|Alverja crema zipper enlatada o envasada|O|O||D||1|Alberjón crema zipper en lata o envasado
50465500|Pimientos en lata o en frasco|O|O||D||1|Chiles en lata o en frasco
50465501|Pimentón ají enlatado o envasado|O|O||D||1|Ají enlatado o envasado
50465502|Pimentón  árbol enlatado o envasado|O|O||D||1|Chile de árbol enlatado o envasado
50465503|Pimentón queso enlatado o envasado|O|O||D||1
50465504|Pimentón chilaca enlatado o envasado|O|O||D||1|Chilaca enlatado o envasado
50465505|Pimentón cubanelles enlatado o envasado|O|O||D||1|Chile cubanelle o pimienta italiana enlatada o envasada
50465506|Pimentón fresno enlatado o envasado|O|O||D||1|Chile fresno enlatado o envasado
50465507|Pimentón kapia enlatado o envasado|O|O||D||1|Chile kapia enlatado o envasado
50465508|Pimentón coreano enlatado o envasado|O|O||D||1|Chile cheongyang enlatado o envasado
50465509|Pimentón manzano enlatado o envasado|O|O||D||1|Chile manzano o de cera enlatado o envasado
50465510|Pimentón melrose enlatado o envasado|O|O||D||1
50465511|Pimentón chile amarillo enlatado o envasado|O|O||D||1|Chile peruano amarillo enlatado o envasado
50465512|Pimentón aji dulce enlatado o envasado|O|O||D||1|Ají dulce enlatado o envasado
50465513|Pimentón anaheim enlatado o envasado|O|O||D||1
50465514|Pimentón ancho enlatado o envasado|O|O||D||1|Chile ancho o mulato enlatado o envasado
50465515|Pimentón campana enlatado o envasado|O|O||D||1|Chile campana enlatado o envasado
50465516|Pimentón cascabel enlatado o envasado|O|O||D||1|Chile cascabel enlatado o envasado
50465517|Pimentón cayenne enlatado o envasado|O|O||D||1|Pimienta de Cayena o roja enlatada o envasada
50465518|Pimentón anfitrión cereza enlatado o envasado|O|O||D||1
50465519|Pimentón chitespin enlatado o envasado|O|O||D||1|Chile chiltepín enlatado o envasado
50465520|Pimentón dedo picante enlatado o envasado|O|O||D||1|Chile Jwala enlatado o envasado
50465521|Pimentón guajillo enlatado o envasado|O|O||D||1|Chile guajillo enlatado o envasado
50465522|Pimentón guerro enlatado o envasado|O|O||D||1|Chile güero enlatado o envasado
50465523|Pimentón habanero enlatado o envasado|O|O||D||1|Chile habanero enlatado o envasado
50465524|Pimentón cera de hungria enlatado o envasado|O|O||D||1|Pimentón húngaro enlatado o envasado
50465525|Pimentón jalapeño enlatado o envasado|O|O||D||1|Chile cuaresmeño enlatado o envasado, Chile jalapeño, seco es chipotle o morita enlatado o envasado
50465526|Pimentón picante largo enlatado o envasado|O|O||D||1|Chile cola de rata enlatado o envasado
50465527|Pimentón marasol enlatado o envasado|O|O||D||1|Chile mirasol enlatado o envasado
50465528|Pimentón pasilla enlatado o envasado|O|O||D||1|Chile pasilla enlatado o envasado
50465529|Pimentón peperoncini enlatado o envasado|O|O||D||1
50465530|Pimentón pequin enlatado o envasado|O|O||D||1|Chile piquín enlatado o envasado
50465531|Pimentón pimiento enlatado o envasado|O|O||D||1|Pimiento morrón enlatado o envasado
50465532|Pimentón poblano enlatado o envasado|O|O||D||1|Chile poblano enlatado o envasado
50465533|Pimentón scotch bonnet enlatado o envasado|O|O||D||1|Pimientos Bonney o rojos Caribe enlatado o envasado
50465534|Pimentón serrano enlatado o envasado|O|O||D||1|Chile serrano enlatado o envasado, Chile verde enlatado o envasado
50465535|Pimentón tabasco enlatado o envasado|O|O||D||1|Chile tabasco enlatado o envasado
50465536|Pimentón tai  enlatado o envasado|O|O||D||1|Chile ojo de pájaro enlatado o envasado
50465537|Pimentón tepin enlatado o envasado|O|O||D||1|Chile mosquito o catarina enlatado o envasado
50465600|Papas en lata o en frasco|O|O||D||1
50465601|Papa blanca larga enlatada o envasada|O|O||D||1
50465602|Papa redonda blanca enlatada o envasada|O|O||D||1
50465603|Papa redonda roja enlatada o envasada|O|O||D||1|Papa de cambray enlatada o envasada
50465604|Papa  russet enlatada o envasada|O|O||D||1
50465605|Papa morada enlatada o envasada|O|O||D||1
50465606|Papa amarilla enlatada o envasada|O|O||D||1
50465607|Papa nueva enlatada o envasada|O|O||D||1
50465608|Papa especial enlatada o envasada|O|O||D||1
50465700|Nabos suecos en lata o en frasco|O|O||D||1
50465701|Nabo sueco acme enlatado o envasado|O|O||D||1
50465702|Nabo sueco angela enlatado o envasado|O|O||D||1
50465703|Nabo sueco el mejor enlatado o envasado|O|O||D||1
50465704|Nabo sueco marian enlatado o envasado|O|O||D||1
50465800|Vegetales marinos en lata o en frasco|O|O||D||1
50465801|Agar-agar enlatado o envasado|O|O||D||1
50465802|Arame  enlatada o envasada|O|O||D||1
50465803|Alga dulce enlatada o envasada|O|O||D||1
50465804|Habichuelas vert de mer enlatada o envasada|O|O||D||1
50465805|Hijiki enlatada o envasada|O|O||D||1
50465806|Musgo irlandés enlatada o envasada|O|O||D||1
50465807|Quelpo enlatado o envasado|O|O||D||1
50465808|Laver enlatado o envasado|O|O||D||1
50465809|Nori enlatado o envasado|O|O||D||1
50465810|Alga roja enlatada o envasada|O|O||D||1
50465811|Kale de mar enlatada o envasada|O|O||D||1
50465812|Lechuga de mar enlatada o envasada|O|O||D||1
50465813|Algas de mar enlatada o envasada|O|O||D||1
50465814|Spirulina enlatada o envasada|O|O||D||1
50465815|Susabi nuri enlatada o envasada|O|O||D||1
50465816|Wakame enlatada o envasada|O|O||D||1
50465900|Chalotes en lata o en frasco|O|O||D||1
50465901|Chalote atlántica enlatado o envasado|O|O||D||1
50465902|Chalote creación enlatado o envasado|O|O||D||1
50465903|Chalote drittler nido blanco enlatado o envasado|O|O||D||1
50465904|Chalote gigante mejorado amarillo enlatado o envasado|O|O||D||1
50465905|Chalote gourmet dorado enlatado o envasado|O|O||D||1
50465906|Chalote grise de bagnolet enlatado o envasado|O|O||D||1
50465907|Chalote hative de nort enlatado o envasado|O|O||D||1
50465908|Chalote pikant enlatado o envasado|O|O||D||1
50465909|Chalote papa roja enlatado o envasado|O|O||D||1
50465910|Chalote sante enlatado o envasado|O|O||D||1
50465911|Chalote topper enlatado o envasado|O|O||D||1
50466000|Alazanes en lata o en frasco|O|O||D||1|Acederas en lata o en frasco
50466001|Alazán dock enlatada o envasada|O|O||D||1|Acedera dock enlatada o envasada
50466002|Alazán jardín enlatada o envasada|O|O||D||1|Acedera jardín enlatada o envasada
50466003|Alazán oveja enlatada o envasada|O|O||D||1|Acedera oveja enlatada o envasada
50466004|Alazán madera enlatada o envasada|O|O||D||1|Acedera madera enlatada o envasada
50466100|Espinacas en lata o en frasco|O|O||D||1
50466101|Espinaca americana enlatada o envasada|O|O||D||1
50466102|Espinaca bloomsdale enlatada o envasada|O|O||D||1
50466103|Espinaca invierno gigante enlatada o envasada|O|O||D||1
50466104|Espinaca horenso enlatada o envasada|O|O||D||1
50466105|Espinaca planta de hielo enlatada o envasada|O|O||D||1
50466106|Espinaca  cuarto de cordero enlatada o envasada|O|O||D||1
50466107|Espinaca malabra enlatada o envasada|O|O||D||1
50466108|Espinaca mendania enlatada o envasada|O|O||D||1
50466109|Espinaca nueva zelandia enlatada o envasada|O|O||D||1
50466110|Espinaca orach enlatada o envasada|O|O||D||1
50466111|Espinaca savoy enlatada o envasada|O|O||D||1
50466112|Espinaca hoja de sigma enlatada o envasada|O|O||D||1
50466113|Espinaca espacio enlatada o envasada|O|O||D||1
50466114|Espinaca trinidad enlatada o envasada|O|O||D||1
50466115|Espinaca agua enlatada o envasada|O|O||D||1
50466116|Espinaca de agua sesa|O|O||D||1
50466200|Calabazas en lata o en frasco|O|O||D||1
50466201|Calabaza boston enlatada o envasada|O|O||D||1
50466202|Calabaza buttemut enlatada o envasada|O|O||D||1
50466203|Calabaza costata romanesca enlatada o envasada|O|O||D||1
50466204|Calabaza crookneck enlatada o envasada|O|O||D||1
50466205|Calabaza  cucuzza enlatada o envasada|O|O||D||1
50466206|Calabaza  delicata enlatada o envasada|O|O||D||1
50466207|Calabaza  delisioso enlatada o envasada|O|O||D||1
50466208|Calabaza verano dorado cuello torcido enlatada o envasada|O|O||D||1
50466209|Calabaza prolífico temprano cuello recto enlatada o envasada|O|O||D||1
50466210|Calabaza  oro enlatada o envasada|O|O||D||1
50466211|Calabaza  jack pequeño enlatada o envasada|O|O||D||1
50466212|Calabaza  campo de kentucky enlatada o envasada|O|O||D||1
50466213|Calabaza marrow enlatada o envasada|O|O||D||1
50466214|Calabaza  medio oriente enlatada o envasada|O|O||D||1
50466215|Calabaza  miniatura enlatada o envasada|O|O||D||1
50466216|Calabaza  orangetti enlatada o envasada|O|O||D||1
50466217|Calabaza pattypan enlatada o envasada|O|O||D||1
50466218|Calabaza  rondini enlatada o envasada|O|O||D||1
50466219|Calabaza  redonda enlatada o envasada|O|O||D||1
50466220|Calabaza  espagueti enlatada o envasada|O|O||D||1
50466221|Calabaza  estripeti enlatada o envasada|O|O||D||1
50466222|Calabaza  molde dulce enlatada o envasada|O|O||D||1
50466223|Calabaza  empanada dulce enlatada o envasada|O|O||D||1
50466224|Calabaza  premio triple  enlatada o envasada|O|O||D||1
50466225|Calabaza waltham butternut enlatada o envasada|O|O||D||1
50466226|Calabaza  arbusto scallop amarillo enlatada o envasada|O|O||D||1
50466227|Calabaza cuello recto amarillo enlatada o envasada|O|O||D||1
50466228|Calabaza zafiro enlatada o envasada|O|O||D||1
50466229|Calabaza zucchini enlatada o envasada|O|O||D||1
50466300|Batatas en lata o en frasco|O|O||D||1|Camotes en lata o en frasco
50466301|Batata beauregard enlatada o envasada|O|O||D||1|Camote beauregard enlatado o envasado
50466302|Batata centennial enlatada o envasada|O|O||D||1|Camote centennial enlatado o envasado
50466303|Batata diane enlatada o envasada|O|O||D||1|Camote diane enlatado o envasado
50466304|Batata dulce garnet enlatada o envasada|O|O||D||1|Camote dulce garnet enlatado o envasado
50466305|Batata georgia dulce rojo enlatada o envasada|O|O||D||1|Camote georgia dulce rojo enlatado o envasado
50466306|Batata  dorado enlatada o envasada|O|O||D||1|Camote dorado enlatado o envasado
50466307|Batata hanna  enlatada o envasada|O|O||D||1|Camote hanna enlatado o envasado
50466308|Batata japonés enlatada o envasada|O|O||D||1|Camote japonés enlatado o envasado
50466309|Batata jersey enlatada o envasada|O|O||D||1|Camote jersey enlatado o envasado
50466310|Batata joya enlatada o envasada|O|O||D||1|Camote joya enlatado o envasado
50466311|Batata meryland roja enlatada o envasada|O|O||D||1|Camote meryland roja enlatado o envasado
50466312|Batata nema dorado enlatada o envasada|O|O||D||1|Camote nema dorado enlatado o envasado
50466313|Batata o´henry enlatada o envasada|O|O||D||1|Camote o´henry enlatado o envasado
50466314|Batata okinawan enlatada o envasada|O|O||D||1|Camote okinawan enlatado o envasado
50466315|Batata naranja enlatada o envasada|O|O||D||1|Camote naranja enlatado o envasado
50466316|Batata oriental enlatada o envasada|O|O||D||1|Camote oriental enlatado o envasado
50466317|Batata jersey rojo enlatada o envasada|O|O||D||1|Camote jersey rojo enlatado o envasado
50466318|Batata mar rojo enlatada o envasada|O|O||D||1|Camote mar rojo enlatado o envasado
50466319|Batata brillo rojo enlatada o envasada|O|O||D||1|Camote brillo rojo enlatado o envasado
50466320|Batata jersey amarillo enlatada o envasada|O|O||D||1|Camote jersey amarillo enlatado o envasado
50466400|Tomates en lata o en frasco|O|O||D||1|Jitomates en lata o en frasco
50466401|Tomates ailsa craig enlatado o envasado|O|O||D||1|Jitomate ailsa craig enlatado o envasado
50466402|Tomates alicante enlatado o envasado|O|O||D||1|Jitomate alicante enlatado o envasado
50466403|Tomates ciruela negra enlatado o envasado|O|O||D||1|Jitomate ciruela negra enlatado o envasado
50466404|Tomates vino de brandy enlatado o envasado|O|O||D||1|Jitomate vino de brandy enlatado o envasado
50466405|Tomates bella cereza enlatado o envasado|O|O||D||1|Jitomate bella cereza enlatado o envasado
50466406|Tomates cereza enlatado o envasado|O|O||D||1|Jitomate cereza enlatado o envasado
50466407|Tomates delicioso enlatado o envasado|O|O||D||1|Jitomate delicioso enlatado o envasado
50466408|Tomates dombito enlatado o envasado|O|O||D||1|Jitomate dombito enlatado o envasado
50466409|Tomates delicia del jardín enlatado o envasado|O|O||D||1|Jitomate delicia del jardín enlatado o envasado
50466410|Tomates uva enlatado o envasado|O|O||D||1|Jitomate uva enlatado o envasado
50466411|Tomates verde enlatado o envasado|O|O||D||1|Tomate verde enlatado o envasado
50466412|Tomates super marmande enlatado o envasado|O|O||D||1|Jitomate super marmande enlatado o envasado
50466413|Tomates rayas naturales marvel enlatado o envasado|O|O||D||1|Jitomate rayas naturales marvel enlatado o envasado
50466414|Tomates minibel enlatado o envasado|O|O||D||1|Jitomate minibel enlatado o envasado
50466415|Tomates oaxacan enlatado o envasado|O|O||D||1|Jitomate oaxaca enlatado o envasado
50466416|Tomates alerta roja enlatado o envasado|O|O||D||1|Jitomate alerta roja enlatado o envasado
50466417|Tomates roma vf enlatado o envasado|O|O||D||1|Jitomate roma vf enlatado o envasado
50466418|Tomates marzano zan enlatado o envasado|O|O||D||1|Jitomate marzano zan enlatado o envasado
50466419|Tomates shirley enlatado o envasado|O|O||D||1|Jitomate shirley enlatado o envasado
50466420|Tomates siberia enlatado o envasado|O|O||D||1|Jitomate siberia enlatado o envasado
50466421|Tomates super beefsteak enlatado o envasado|O|O||D||1|Jitomate super beefsteak enlatado o envasado
50466422|Tomates tigerella enlatado o envasado|O|O||D||1|Jitomate tigerella enlatado o envasado
50466423|Tomates tiny tim enlatado o envasado|O|O||D||1|Jitomate tiny tim enlatado o envasado
50466424|Tomates tumbler enlatado o envasado|O|O||D||1|Jitomate tumbler enlatado o envasado
50466425|Tomates cocktail amarillo enlatado o envasado|O|O||D||1
50466426|Tomates forma de pera amarillo enlatado o envasado|O|O||D||1
50466427|Tomates perfección amarilla enlatado o envasado|O|O||D||1
50466500|Nabos en lata o en frasco|O|O||D||1
50466501|Nabo globo verde enlatado o envasado|O|O||D||1
50466502|Nabo bola dorada enlatado o envasado|O|O||D||1
50466503|Nabo mercado de manchester enlatado o envasado|O|O||D||1
50466504|Nabo top morado milan enlatado o envasado|O|O||D||1
50466505|Nabo top morado blanco enlatado o envasado|O|O||D||1
50466506|Nabo bola de nieve enlatado o envasado|O|O||D||1
50466507|Nabo tokio enlatado o envasado|O|O||D||1
50466508|Nabo cruz de tokio enlatado o envasado|O|O||D||1
50466600|Auyamas en lata o en frasco|O|O||D||1|Calabazas gigantes en lata o en frasco
50466601|Calabaza acorn enlatada o envasada|O|O||D||1|Calabaza gigante acorn enlatada o envasada
50466602|Calabaza gigante atlántico enlatada o envasada|O|O||D||1|Calabaza gigante atlántico enlatada o envasada
50466603|Calabaza banana rosado enlatada o envasada|O|O||D||1|Calabaza gigante banana rosado enlatada o envasada
50466604|Calabaza max grande enlatada o envasada|O|O||D||1|Calabaza gigante max enlatada o envasada
50466605|Calabaza  enlatada o envasada|O|O||D||1|Calabaza de castilla enlatada o envasada
50466606|Calabaza carnaval enlatada o envasada|O|O||D||1|Calabaza gigante carnaval enlatada o envasada
50466607|Auyama queso enlatada o envasada|O|O||D||1|Calabaza gigante queso enlatada o envasada
50466608|Calabaza príncipe coronado enlatada o envasada|O|O||D||1|Calabaza gigante príncipe coronado enlatada o envasada
50466609|Calabaza  curcibita enlatada o envasada|O|O||D||1|Calabaza gigante curcibita enlatada o envasada
50466610|Calabaza cushaw enlatada o envasada|O|O||D||1|Calabaza gigante cushaw enlatada o envasada
50466611|Calabaza  gigante auyama enlatada o envasada|O|O||D||1
50466612|Calabaza  hubbard enlatada o envasada|O|O||D||1|Calabaza gigante hubbard enlatada o envasada
50466613|Calabaza  jerrahdale enlatada o envasada|O|O||D||1|Calabaza gigante jerrahdale enlatada o envasada
50466614|Calabaza  kabocha enlatada o envasada|O|O||D||1|Calabaza gigante kabocha enlatada o envasada
50466615|Calabaza queensland azul enlatada o envasada|O|O||D||1|Calabaza gigante queensland azul enlatada o envasada
50466616|Calabaza rouge vif détampes enlatada o envasada|O|O||D||1|Calabaza gigante rouge vif détampes enlatada o envasada
50466617|Calabaza  turban turco enlatada o envasada|O|O||D||1|Calabaza gigante turban turco enlatada o envasada
50466618|Calabaza  valenciano enlatada o envasada|O|O||D||1|Calabaza gigante valenciano enlatada o envasada
50466619|Calabaza  warted hubbard enlatada o envasada|O|O||D||1|Calabaza gigante warted hubbard enlatada o envasada
50466620|Auyama whangaparoa enlatada o envasada|O|O||D||1|Calabaza gigante whangaparoa enlatada o envasada
50466700|Ñames en lata o en frasco|O|O||D||1
50466701|Ñame agria africana enlatada o envasada|O|O||D||1
50466702|Ñame agria asiática enlatada o envasada|O|O||D||1
50466703|Ñame china enlatado o envasado|O|O||D||1
50466704|Ñame globo enlatado o envasado|O|O||D||1
50466705|Ñame grater enlatado o envasado|O|O||D||1
50466706|Ñame japonesa enlatado o envasado|O|O||D||1
50466707|Ñame lesser enlatado o envasado|O|O||D||1
50466708|Ñame papa enlatado o envasado|O|O||D||1
50466709|Ñame guinea blanca enlatado o envasado|O|O||D||1
50466710|Ñame guinea amarillo enlatado o envasado|O|O||D||1
50466800|Vegetales Nominant en lata o en frasco|O|O||D||1|Vegetales predominantes en lata o en frasco, Nopal en lata o en frasco
50466801|Alfalfa enlatada o envasada|O|O||D||1
50466802|Hojas de aloe enlatada o envasada|O|O||D||1|Hoja de sábila enlatada o envasada, Penca de sábila enlatada o envasada
50466803|Apio enlatado o envasado|O|O||D||1
50466804|Arrurruz enlatada o envasada|O|O||D||1
50466805|Punta de flecha enlatada o envasada|O|O||D||1|Sagittaria enlatada o envasada
50466806|rúcula enlatada o envasada|O|O||D||1
50466807|Arum enlatada o envasada|O|O||D||1|Taro enlatado o envasado
50466808|Raíz de bambú enlatada o envasada|O|O||D||1
50466809|Hojas de plátano enlatada o envasada|O|O||D||1
50466810|Batatas enlatada o envasada|O|O||D||1
50466811|Brotes de frijol enlatados o envasados|O|O||D||1
50466812|Top de remolacha enlatada o envasada|O|O||D||1|Betabel enlatado o envasado
50466813|Melón agrio enlatado o envasado|O|O||D||1|Balsamina enlatada o envasada
50466814|Bayas de alcaparra orgánica enlatadas o envasadas|O|O||D||1
50466815|Carob enlatado o envasado|O|O||D||1|Algarrobo enlatado o envasado
50466816|Cha-om enlatado o envasado|O|O||D||1
50466817|Chayote o guatila enlatado o envasado|O|O||D||1
50466818|Garbanzo enlatado o envasado|O|O||D||1
50466819|Verde de crisantemos enlatado o envasado|O|O||D||1
50466820|Verde de diente de león enlatado o envasado|O|O||D||1
50466821|Diente de león enlatado o envasado|O|O||D||1
50466822|Dasheen enlatado o envasado|O|O||D||1
50466823|Puntas de alverja enlatado o envasado|O|O||D||1
50466824|Diakon enlatado o envasado|O|O||D||1|Rábano enlatado o envasado
50466825|Donqua enlatada o envasada|O|O||D||1|Ginseng hembra enlatada o envasada
50466826|Helecho enlatado o envasado|O|O||D||1|Brotes de helecho enlatado o envasado
50466827|Gai choi enlatado o envasado|O|O||D||1|Mostaza castaña enlatada o envasada
50466828|Gailon enlatado o envasado|O|O||D||1|Brécol chino enlatado o envasado
50466829|Galanga enlatada o envasada|O|O||D||1|Jengibre azul enlatado o envasado
50466830|Raíz de jengibre enlatada o envasada|O|O||D||1
50466831|Gobo enlatado o envasado|O|O||D||1|Garduña enlatada o envasada
50466832|Brote de lúpulo enlatado o envasado|O|O||D||1
50466833|Rabano blanco enlatado o envasado|O|O||D||1|Rábano de caballo enlatado o envasado
50466834|Jicama enlatada o envasada|O|O||D||1
50466835|Kuduz enlatada o envasada|O|O||D||1|Kudzu enlatado o envasado
50466836|Bulbo de margarita enlatado o envasado|O|O||D||1|Bulbo de lili chino enlatado o envasado
50466837|Linkok enlatado o envasado|O|O||D||1
50466838|Lo bok enlatado o envasado|O|O||D||1
50466839|Frijol largo enlatado o envasado|O|O||D||1|Fríjol serpiente enlatado o envasado
50466840|Raíz de lotus enlatado o envasado|O|O||D||1|Rosa del Nilo enlatada o envasada
50466841|Hojas de maguey enlatada o envasada|O|O||D||1|Hoja de agave enlatada o envasada, Penca de maguey enlatada o envasada
50466842|Mallows enlatado o envasado|O|O||D||1|Malva enlatada o envasada
50466843|Sapote mamey enlatado o envasado|O|O||D||1|Mamey enlatado o envasado
50466844|Moap enlatado o envasado|O|O||D||1
50466845|Moo enlatado o envasado|O|O||D||1
50466846|Moqua enlatada o envasada|O|O||D||1
50466847|Opos enlatados o envasados|O|O||D||1
50466848|Corazon de palma enlatado o envasado|O|O||D||1|Palmito enlatado o envasado
50466849|Paprika enlatada o envasada|O|O||D||1
50466850|Purslane enlatada o envasada|O|O||D||1|Verdolaga enlatada o envasada
50466851|Raddichios enlatada o envasada|O|O||D||1|Achicoria morada enlatada o envasada
50466852|Sinquas enlatada o envasada|O|O||D||1|Zapallo enlatado o envasado
50466853|Frijol de soya enlatados o envasados|O|O||D||1
50466854|Spoonwart enlatado o envasado|O|O||D||1|Hierba del escorbuto enlatada o envasada
50466855|Uva tassele hyacinth enlatado o envasado|O|O||D||1
50466856|Taro enlatado o envasado|O|O||D||1|Tales enlatado o envasado
50466857|Hoja de taro enlatada o envasada|O|O||D||1
50466858|Tallo de taro enlatado o envasado|O|O||D||1
50466859|Tapeguaje enlatado o envasado|O|O||D||1
50466860|Verde tierno enlatado o envasado|O|O||D||1
50466861|Tindora enlatado o envasado|O|O||D||1
50466862|Árbol de cebolla enlatado o envasado|O|O||D||1|Cebollas egipcias enlatada o envasada
50466863|Udo enlatado o envasado|O|O||D||1
50466864|Agua castaño enlatado o envasado|O|O||D||1|Castaña  de agua china enlatada o envasada
50466865|Yumpi enlatado o envasado|O|O||D||1|Akankong enlatado o envasado
50466866|Yautia enlatado o envasado|O|O||D||1|Mapuey enlatado o envasado
50466867|Yu choy enlatado o envasado|O|O||D||1
50466868|Yuca enlatada o envasada|O|O||D||1
50466900|Alverjas dulces en lata o en frasco|O|O||D||1|Chícharos en lata o en frasco
50466901|Alverja biquini enlatada o envasada|O|O||D||1|Chícharo biquini en lata o envasado
50466902|Alverja cavalier enlatada o envasada|O|O||D||1|Chícharo cavalier en lata o envasado
50466903|Alverja margarita enlatada o envasada|O|O||D||1|Chícharo margarita en lata o envasado
50466904|Alverja dar fon enlatada o envasada|O|O||D||1|Chícharo dar fon en lata o envasado
50466905|Alverja "early onward" enlatada o envasada|O|O||D||1|Chícharo "early onward" en lata o envasado
50466906|Alverja primer feltham enlatada o envasada|O|O||D||1|Chícharo primer feltham en lata o envasado
50466907|Alverja verde hurst shaft enlatada o envasada|O|O||D||1|Chícharo verde hurst shaft en lata o envasado
50466908|Guisante oregón sugar pod enlatada o envasada|O|O||D||1|Chícharo oregón sugar pod en lata o envasado
50466909|Alverja príncipe alberto enlatada o envasada|O|O||D||1|Chícharo príncipe alberto en lata o envasado
50466910|Alverja reuzensuiker enlatada o envasada|O|O||D||1|Chícharo reuzensuiker en lata o envasado
50467000|Kimchis dulces en lata o en frasco|O|O||D||1|Col agria (kimchi coreano) en lata o en frasco
50467001|Baechukimchis|O|O||D||1|Baechukimchis
50467002|Rábanos jóvenes kimichi|O|O||D||1|Col agria (kimchi coreano) joven
50467003|Rábano de agua kimichi|O|O||D||1|Col agria (kimchi coreano) de agua
50467004|Rábanos joven  escabeche kimichi|O|O||D||1|Col agria (kimchi coreano) joven en escabeche
50467005|Rábanos cortados kimichi|O|O||D||1|Col agria (kimchi coreano) cortados
50467006|Jangjorims enlatado|O|O||D||1
50467007|Atún enlatada|O|O||D||1|Atún enlatado
50471500|Alcachofas orgánicas en lata o en frasco|O|O||D||1
50471501|Alcachofa brittany orgánica enlatada o envasada|O|O||D||1
50471502|Alcachofa cantonesa orgánica enlatada o envasada|O|O||D||1
50471503|Alcachofa francesa orgánica enlatada o envasada|O|O||D||1
50471504|Alcachofa globo verde orgánica enlatada o envasada|O|O||D||1
50471505|Alcachofa gros camus de bretaña orgánica enlatada o envasada|O|O||D||1
50471506|Alcachofa midi orgánica enlatada o envasada|O|O||D||1
50471507|Alcachofa globo morado orgánica enlatada o envasada|O|O||D||1
50471508|Alcachofa morado cecilia orgánica enlatada o envasada|O|O||D||1
50471509|Alcachofa romanesco orgánica enlatada o envasada|O|O||D||1
50471510|Alcachofa espinoso sardo orgánica enlatada o envasada|O|O||D||1
50471511|Alcachofa vert de laon orgánica enlatada o envasada|O|O||D||1
50471512|Alcachofa violeta de chiggiia orgánica enlatada o envasada|O|O||D||1
50471513|Alcachofa violeta de toscana orgánica enlatada o envasada|O|O||D||1
50471600|Espárragos orgánicos en lata o en frasco|O|O||D||1
50471601|Espárragos connovers colosal orgánicos enlatados o envasados|O|O||D||1
50471602|Espárragos franklin orgánicos enlatados o envasados|O|O||D||1
50471603|Espárragos mamut gigante orgánicos enlatados o envasados|O|O||D||1
50471604|Espárragos lucullus orgánicos enlatados o envasados|O|O||D||1
50471605|Espárragos martha washington orgánicos enlatados o envasados|O|O||D||1
50471700|Aguacates orgánicos en lata o en frasco|O|O||D||1
50471701|Aguacate ajax b – 7 orgánico enlatado o envasado|O|O||D||1
50471702|Aguacate arue orgánico enlatado o envasado|O|O||D||1
50471703|Aguacate bacon orgánico enlatado o envasado|O|O||D||1
50471704|Aguacate benik orgánico enlatado o envasado|O|O||D||1
50471705|Aguacate bernecker orgánico enlatado o envasado|O|O||D||1
50471706|Aguacate beta orgánico enlatado o envasado|O|O||D||1
50471707|Aguacate biondo orgánico enlatado o envasado|O|O||D||1
50471708|Aguacate príncipe negro orgánico enlatado o envasado|O|O||D||1
50471709|Aguacate blair orgánico enlatado o envasado|O|O||D||1
50471710|Aguacate blair cabina orgánico enlatado o envasado|O|O||D||1
50471711|Aguacate cabina 1 orgánico enlatado o envasado|O|O||D||1
50471712|Aguacate cabina 3 orgánico enlatado o envasado|O|O||D||1
50471713|Aguacate cabina 5 orgánico enlatado o envasado|O|O||D||1
50471714|Aguacate cabina 7 orgánico enlatado o envasado|O|O||D||1
50471715|Aguacate cabina 8 orgánico enlatado o envasado|O|O||D||1
50471716|Aguacate brooks 1978 orgánico enlatado o envasado|O|O||D||1
50471717|Aguacate brookslate orgánico enlatado o envasado|O|O||D||1
50471718|Aguacate california haas orgánico enlatado o envasado|O|O||D||1
50471719|Aguacate catalina orgánico enlatado o envasado|O|O||D||1
50471720|Aguacate chica orgánico enlatado o envasado|O|O||D||1
50471721|Aguacate choquette orgánico enlatado o envasado|O|O||D||1
50471722|Aguacate cristina orgánico enlatado o envasado|O|O||D||1
50471723|Aguacate collison orgánico enlatado o envasado|O|O||D||1
50471724|Aguacate donnie orgánico enlatado o envasado|O|O||D||1
50471725|Aguacate dr dupis numero 2 orgánico enlatado o envasado|O|O||D||1
50471726|Aguacate dr. dupie  orgánico enlatado o envasado|O|O||D||1
50471727|Aguacate ettinger orgánico enlatado o envasado|O|O||D||1
50471728|Aguacate fuch orgánico enlatado o envasado|O|O||D||1
50471729|Aguacate fuch gwen orgánico enlatado o envasado|O|O||D||1
50471730|Aguacate fuerte orgánico enlatado o envasado|O|O||D||1
50471731|Aguacate gotham orgánico enlatado o envasado|O|O||D||1
50471732|Aguacate gossman orgánico enlatado o envasado|O|O||D||1
50471733|Aguacate guatemala sin pepa orgánico enlatado o envasado|O|O||D||1
50471734|Aguacate hall orgánico enlatado o envasado|O|O||D||1
50471735|Aguacate hardee orgánico enlatado o envasado|O|O||D||1
50471736|Aguacate haas orgánico enlatado o envasado|O|O||D||1
50471737|Aguacate herman orgánico enlatado o envasado|O|O||D||1
50471738|Aguacate hickson orgánico enlatado o envasado|O|O||D||1
50471739|Aguacate k-5 orgánico enlatado o envasado|O|O||D||1
50471740|Aguacate k- 9 orgánico enlatado o envasado|O|O||D||1
50471741|Aguacate cordero haas orgánico enlatado o envasado|O|O||D||1
50471742|Aguacate leona orgánico enlatado o envasado|O|O||D||1
50471743|Aguacate leona linda orgánico enlatado o envasado|O|O||D||1
50471744|Aguacate lisa p orgánico enlatado o envasado|O|O||D||1
50471745|Aguacate lisa loretta orgánico enlatado o envasado|O|O||D||1
50471746|Aguacate loretta orgánico enlatado o envasado|O|O||D||1
50471747|Aguacate lula orgánico enlatado o envasado|O|O||D||1
50471748|Aguacate lula mascarthur orgánico enlatado o envasado|O|O||D||1
50471749|Aguacate marcus orgánico enlatado o envasado|O|O||D||1
50471750|Aguacate melendez orgánico enlatado o envasado|O|O||D||1
50471751|Aguacate meya orgánico enlatado o envasado|O|O||D||1
50471752|Aguacate miguel p orgánico enlatado o envasado|O|O||D||1
50471753|Aguacate monroe orgánico enlatado o envasado|O|O||D||1
50471754|Aguacate murrieta verde orgánico enlatado o envasado|O|O||D||1
50471755|Aguacate nabal orgánico enlatado o envasado|O|O||D||1
50471756|Aguacate nadir orgánico enlatado o envasado|O|O||D||1
50471757|Aguacate nesbitt orgánico enlatado o envasado|O|O||D||1
50471758|Aguacate peterson orgánico enlatado o envasado|O|O||D||1
50471759|Aguacate pinelli orgánico enlatado o envasado|O|O||D||1
50471760|Aguacate pinkerton orgánico enlatado o envasado|O|O||D||1
50471761|Aguacate pollock orgánico enlatado o envasado|O|O||D||1
50471762|Aguacate puebla orgánico enlatado o envasado|O|O||D||1
50471763|Aguacate reed orgánico enlatado o envasado|O|O||D||1
50471764|Aguacaterue orgánico enlatado o envasado|O|O||D||1
50471765|Aguacateruehle orgánico enlatado o envasado|O|O||D||1
50471766|Aguacate ryan orgánico enlatado o envasado|O|O||D||1
50471767|Aguacate semil orgánico enlatado o envasado|O|O||D||1
50471768|Aguacate semil 43 orgánico enlatado o envasado|O|O||D||1
50471769|Aguacate simonds orgánico enlatado o envasado|O|O||D||1
50471770|Aguacate simpson orgánico enlatado o envasado|O|O||D||1
50471771|Aguacate taylor orgánico enlatado o envasado|O|O||D||1
50471772|Aguacate tonelada orgánico enlatado o envasado|O|O||D||1
50471773|Aguacate torre orgánico enlatado o envasado|O|O||D||1
50471774|Aguacate torre li orgánico enlatado o envasado|O|O||D||1
50471775|Aguacate trapp orgánico enlatado o envasado|O|O||D||1
50471776|Aguacate semilla de caribe orgánico enlatado o envasado|O|O||D||1
50471777|Aguacate wagner orgánico enlatado o envasado|O|O||D||1
50471778|Aguacate waldin orgánico enlatado o envasado|O|O||D||1
50471779|Aguacate wurtz orgánico enlatado o envasado|O|O||D||1
50471780|Aguacate zio p orgánico enlatado o envasado|O|O||D||1
50471781|Aguacate ziu orgánico enlatado o envasado|O|O||D||1
50471782|Aguacate zultano orgánico enlatado o envasado|O|O||D||1
50471800|Fríjoles orgánicos en lata o en frasco|O|O||D||1
50471801|Frijoles anasazi ® orgánicos enlatados o envasados|O|O||D||1
50471802|Frijoles appaloosa orgánicos enlatados o envasados|O|O||D||1
50471803|Frijoles azuki orgánicos enlatados o envasados|O|O||D||1
50471804|Frijoles barlotti orgánicos enlatados o envasados|O|O||D||1
50471805|Frijoles appaloosa negra orgánicos enlatados o envasados|O|O||D||1
50471806|Frijoles negros orgánicos enlatados o envasados|O|O||D||1
50471807|Frijoles gran negros orgánicos enlatados o envasados|O|O||D||1
50471808|Frijoles shackamaxon negro orgánicos enlatados o envasados|O|O||D||1
50471809|Frijoles ojo negro orgánicos enlatados o envasados|O|O||D||1
50471810|Frijoles bobby orgánicos enlatados o envasados|O|O||D||1
50471811|Frijoles bolita orgánicos enlatados o envasados|O|O||D||1
50471812|Frijoles esposa perezosa carmelita orgánicos enlatados o envasados|O|O||D||1
50471813|Frijoles calipso orgánicos enlatados o envasados|O|O||D||1
50471814|Frijoles canelini orgánicos enlatados o envasados|O|O||D||1
50471815|Frijoles castor orgánicos enlatados o envasados|O|O||D||1
50471816|Frijoles amarillo chino orgánicos enlatados o envasados|O|O||D||1
50471817|Frijoles lengua de dragón orgánicos enlatados o envasados|O|O||D||1
50471818|Frijoles soldado europeo orgánicos enlatados o envasados|O|O||D||1
50471819|Frijoles fava orgánicos enlatados o envasados|O|O||D||1
50471820|Frijoles flageolet orgánicos enlatados o envasados|O|O||D||1
50471821|Frijoles  horticultura francesa orgánicos enlatados o envasados|O|O||D||1
50471822|Frijoles marina francesa orgánicos enlatados o envasados|O|O||D||1
50471823|Frijoles coco gigante blanco orgánicos enlatados o envasados|O|O||D||1
50471824|Frijoles verdes orgánicos enlatados o envasados|O|O||D||1
50471825|Frijoles romano verde orgánicos enlatados o envasados|O|O||D||1
50471826|Frijoles guar gum orgánicos enlatados o envasados|O|O||D||1
50471827|Frijoles haricot orgánicos enlatados o envasados|O|O||D||1
50471828|Frijoles hyacinth orgánicos enlatados o envasados|O|O||D||1
50471829|Frijoles tipo italiano orgánicos enlatados o envasados|O|O||D||1
50471830|Frijoles asombro jackson orgánicos enlatados o envasados|O|O||D||1
50471831|Frijoles ganado jacobs  orgánicos enlatados o envasados|O|O||D||1
50471832|Frijoles asombro kentucky orgánicos enlatados o envasados|O|O||D||1
50471833|Frijoles riñón orgánicos enlatados o envasados|O|O||D||1
50471834|Frijoles lima orgánicos enlatados o envasados|O|O||D||1
50471835|Frijoles madera orgánicos enlatados o envasados|O|O||D||1
50471836|Frijoles medula orgánicos enlatados o envasados|O|O||D||1
50471837|Frijoles mat orgánicos enlatados o envasados|O|O||D||1
50471838|Frijoles monstoler ganzo salvaje orgánicos enlatados o envasados|O|O||D||1
50471839|Frijoles  mortgage lifter orgánicos enlatados o envasados|O|O||D||1
50471840|Frijoles polilla orgánicos enlatados o envasados|O|O||D||1
50471841|Frijoles mung orgánicos enlatados o envasados|O|O||D||1
50471842|Frijoles munsi wolf orgánicos enlatados o envasados|O|O||D||1
50471843|Frijoles nuna orgánicos enlatados o envasados|O|O||D||1
50471844|Frijoles pinto orgánicos enlatados o envasados|O|O||D||1
50471845|Frijoles runner orgánicos enlatados o envasados|O|O||D||1
50471846|String beans orgánicos enlatados o envasados|O|O||D||1|Ayecote orgánico enlatado o envasado, Fríjol gordo orgánico enlatado o envasado
50471847|Frijoles habichuelas orgánicos enlatados o envasados|O|O||D||1|Ejote orgánico enlatado o envasado, Fríjol tierno orgánico enlatado o envasado
50471848|Frijoles tamarind orgánicos enlatados o envasados|O|O||D||1
50471849|Frijoles tonka orgánicos enlatados o envasados|O|O||D||1
50471850|Frijoles cera orgánicos enlatados o envasados|O|O||D||1
50471851|Frijoles winged orgánicos enlatados o envasados|O|O||D||1
50471852|Frijoles largos orgánicos enlatados o envasados|O|O||D||1
50471900|Remolachas  orgánicas en lata o en frasco|O|O||D||1|Betabeles orgánicos en lata o en frasco
50471901|Remolacha acción orgánica enlatada o envasada|O|O||D||1|Betabel acción orgánico enlatado o envasado
50471902|Remolacha albina vereduna orgánica enlatada o envasada|O|O||D||1|Betabel albina vereduna orgánico enlatado o envasado
50471903|Remolacha barababiotela de chiggia orgánica enlatada o envasada|O|O||D||1|Betabel barababiotela de chiggia orgánico enlatado o envasado
50471904|Remolacha boltardy orgánica enlatada o envasada|O|O||D||1|Betabel boltardy orgánico enlatado o envasado
50471905|Remolacha bonel orgánica enlatada o envasada|O|O||D||1|Betabel bonel orgánico enlatado o envasado
50471906|Remolacha burpees dorado orgánica enlatada o envasada|O|O||D||1|Betabel burpees dorado orgánico enlatado o envasado
50471907|Remolacha cheltenham tapa verde orgánica enlatada o envasada|O|O||D||1|Betabel cheltenham tapa verde orgánico enlatado o envasado
50471908|Remolacha cheltenham mono orgánica enlatada o envasada|O|O||D||1|Betabel cheltenham mono orgánico enlatado o envasado
50471909|Remolacha chioggia orgánica enlatada o envasada|O|O||D||1|Betabel chioggia orgánico enlatado o envasado
50471910|Remolacha cilindra orgánica enlatada o envasada|O|O||D||1|Betabel cilindra orgánico enlatado o envasado
50471911|Remolacha dégypte orgánica enlatada o envasada|O|O||D||1|Betabel dégypte orgánico enlatado o envasado
50471912|Remolacha detroit 2 rojo oscuro orgánica enlatada o envasada|O|O||D||1|Betabel detroit 2 rojo oscuro orgánico enlatado o envasado
50471913|Remolacha detroit 2 bala chiquita orgánica enlatada o envasada|O|O||D||1|Betabel detroit 2 bala chiquita orgánico enlatado o envasado
50471914|Remolacha egipcia plana  orgánica enlatada o envasada|O|O||D||1|Betabel egipcia plana orgánico enlatado o envasado
50471915|Remolacha  raíz de nabo egipcio orgánica enlatada o envasada|O|O||D||1|Betabel raíz de nabo egipcio orgánico enlatado o envasado
50471916|Remolacha fomanova orgánica enlatada o envasada|O|O||D||1|Betabel fomanova orgánico enlatado o envasado
50471917|Remolacha forono orgánica enlatada o envasada|O|O||D||1|Betabel forono orgánico enlatado o envasado
50471918|Remolacha monaco orgánica enlatada o envasada|O|O||D||1|Betabel mónaco orgánico enlatado o envasado
50471919|Remolacha monograma orgánica enlatada o envasada|O|O||D||1|Betabel monograma orgánico enlatado o envasado
50471920|Remolacha pronto orgánica enlatada o envasada|O|O||D||1|Betabel pronto orgánico enlatado o envasado
50471921|Remolacha regalía orgánica enlatada o envasada|O|O||D||1|Betabel regalía orgánico enlatado o envasado
50471922|Remolacha dulce orgánica enlatada o envasada|O|O||D||1|Betabel dulce orgánico enlatado o envasado
50472000|Brócolis  orgánicas en lata o en frasco|O|O||D||1
50472001|Brócolini orgánico enlatado o envasado|O|O||D||1
50472002|Brócoli romanesco orgánico enlatado o envasado|O|O||D||1
50472003|Brócoli raab orgánico enlatado o envasado|O|O||D||1
50472004|Brócoli chino orgánico enlatado o envasado|O|O||D||1
50472100|Repollitos de Bruselas  orgánicas en lata o en frasco|O|O||D||1|Coles de Bruselas orgánicas en lata o en frasco
50472101|Repollitas de bruselas citade orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas citade orgánica enlatadas o envasadas
50472102|Repollitas de bruselas falstaff orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas falstaff orgánica enlatadas o envasadas
50472103|Repollitas de bruselas oliver orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas oliver orgánica enlatadas o envasadas
50472104|Repollitas de bruselas peer gynt orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas peer gynt orgánica enlatadas o envasadas
50472105|Repollitas de bruselas rampart orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas rampart orgánica enlatadas o envasadas
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
