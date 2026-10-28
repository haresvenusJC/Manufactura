-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 9 de 10 (5786 claves; total 52513)
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
50472106|Repollitas de bruselas rubine orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas rubine orgánica enlatadas o envasadas
50472107|Repollitas de bruselas  widgeon orgánica orgánicas enlatadas o envasadas|O|O||D||1|Coles de Bruselas widgeon orgánica enlatadas o envasadas
50472200|Cebollas de ensalada  orgánicas en lata o en frasco|O|O||D||1|Cebollas de cambray  orgánicas en lata o en frasco
50472201|Cebolla belstville ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray belstville orgánica enlatada o envasada
50472202|Cebolla feast ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray feast orgánica enlatada o envasada
50472203|Cebolla ishikura ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray ishikura orgánica enlatada o envasada
50472204|Cebolla mercado kyoto orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray mercado kyoto orgánica enlatada o envasada
50472205|Cebolla barba roja ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray barba roja orgánica enlatada o envasada
50472206|Cebolla amigo rojo ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray amigo rojo orgánica enlatada o envasada
50472207|Cebolla santa claus orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray santa claus orgánica enlatada o envasada
50472208|Cebolla tokyo ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray tokyo orgánica enlatada o envasada
50472209|Cebolla lisbon blanca ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray lisbon blanca orgánica enlatada o envasada
50472210|Cebolla invierno blanca ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray invierno blanca orgánica enlatada o envasada
50472211|Cebolla final de invierno ensalada orgánica enlatada o envasada|O|O||D||1|Cebolla de cambray final de invierno orgánica enlatada o envasada
50472300|Repollos orgánicos en lata o en frasco|O|O||D||1|Coles orgánicas en lata o en frasco
50472301|Repollo negro orgánico enlatado o envasado|O|O||D||1|Col negro orgánica enlatada o envasada
50472302|Repollo savoy orgánico enlatado o envasado|O|O||D||1|Col savoy orgánica enlatada o envasada
50472303|Repollo zorrillo orgánico enlatado o envasado|O|O||D||1|Col zorrillo orgánica enlatada o envasada
50472304|Repollo blanco orgánico enlatado o envasado|O|O||D||1|Col blanco orgánica enlatada o envasada
50472400|Cardos orgánicos en lata o en frasco|O|O||D||1|Cardos comestibles orgánicos en lata o en frasco
50472401|Cardos lunghi orgánicos enlatados o envasados|O|O||D||1|Cardo comestible lunghi orgánicos enlatados o envasados
50472402|Cardos gobbi orgánicos enlatados o envasados|O|O||D||1|Cardo comestible gobbi orgánicos enlatados o envasados
50472500|Zanahorias  orgánicas en lata o en frasco|O|O||D||1
50472501|Zanahoria amsterdam orgánica enlatada o envasada|O|O||D||1
50472502|Zanahoria rey de otoño orgánica enlatada o envasada|O|O||D||1
50472503|Zanahoria berlicum orgánica enlatada o envasada|O|O||D||1
50472504|Zanahoria chantenay orgánica enlatada o envasada|O|O||D||1
50472505|Zanahoria nantes orgánica enlatada o envasada|O|O||D||1
50472506|Zanahoria mercado de parís orgánica enlatada o envasada|O|O||D||1
50472600|Coliflores  orgánicas en lata o en frasco|O|O||D||1
50472601|Coliflor todo el año  orgánica enlatada o envasada|O|O||D||1
50472602|Coliflor alverda orgánica enlatada o envasada|O|O||D||1
50472603|coliflor otoño gigante 3 orgánica enlatada o envasada|O|O||D||1
50472604|Coliflo rdok elgon orgánica enlatada o envasada|O|O||D||1
50472605|Coliflor bola de nieve temprana orgánica enlatada o envasada|O|O||D||1
50472606|Coliflor luz de lima orgánica enlatada o envasada|O|O||D||1
50472607|Coliflor minaret orgánica enlatada o envasada|O|O||D||1
50472608|Coliflor buque de naranja orgánica enlatada o envasada|O|O||D||1
50472609|Coliflor capa morada orgánica enlatada o envasada|O|O||D||1
50472610|Coliflor bola de nieve orgánica enlatada o envasada|O|O||D||1
50472611|Coliflor invierno walcheren 3 orgánica enlatada o envasada|O|O||D||1
50472612|Coliflor piedra blanca orgánica enlatada o envasada|O|O||D||1
50472700|Apios orgánicos en lata o en frasco|O|O||D||1
50472701|Apio celebridad orgánico enlatado o envasado|O|O||D||1
50472702|Apio nabo orgánico enlatado o envasado|O|O||D||1
50472703|Apio chino orgánico enlatado o envasado|O|O||D||1
50472704|Apio dinant francés orgánico enlatado o envasado|O|O||D||1
50472705|Apio gigante rosado orgánico enlatado o envasado|O|O||D||1
50472706|Apio gigante rojo orgánico enlatado o envasado|O|O||D||1
50472707|Apio gigante blanco orgánico enlatado o envasado|O|O||D||1
50472708|Apio dorado auto escalado orgánico enlatado o envasado|O|O||D||1
50472709|Apio "greensleeves" orgánico enlatado o envasado|O|O||D||1
50472710|Apio hopkins fenlander orgánico enlatado o envasado|O|O||D||1
50472711|Apio torre marfil orgánico enlatado o envasado|O|O||D||1
50472712|Apio lathom blanqueado orgánico enlatado o envasado|O|O||D||1
50472713|Apio sopa de amsterdam orgánico enlatado o envasado|O|O||D||1
50472714|Apio estándar cargado orgánico enlatado o envasado|O|O||D||1
50472715|Apio triunfo alto utah orgánico enlatado o envasado|O|O||D||1
50472800|Acelgas  orgánicas en lata o en frasco|O|O||D||1
50472801|Acelga luz brillante orgánica enlatada o envasada|O|O||D||1
50472802|Acelga gigante fordhook orgánica enlatada o envasada|O|O||D||1
50472803|Acelga luculus orgánica enlatada o envasada|O|O||D||1
50472804|Acelga espinaca perpetua orgánica enlatada o envasada|O|O||D||1
50472805|Acelga ruibarbo orgánica enlatada o envasada|O|O||D||1
50472806|Acelga suizo orgánica enlatada o envasada|O|O||D||1
50472807|Acelga volcán  orgánica enlatada o envasada|O|O||D||1
50472808|Acelga rey blanco orgánica enlatada o envasada|O|O||D||1
50472900|Achicorias orgánicas en lata o en frasco|O|O||D||1|Escarolas orgánicas en lata o en frasco
50472901|Achicoria batavian hoja ancha orgánica enlatada o envasada|O|O||D||1|Escarola batavian hoja ancha orgánica enlatada o envasada
50472902|Achicoria en cornet de bordeaux orgánica enlatada o envasada|O|O||D||1|Escarola en cornet de bordeaux orgánica enlatada o envasada
50472903|Achicoria rollo verde ruffee orgánica enlatada o envasada|O|O||D||1|Escarola rollo verde ruffee orgánica enlatada o envasada
50472904|Achicoria roll verde orgánica enlatada o envasada|O|O||D||1|Escarola roll verde orgánica enlatada o envasada
50472905|Achicoria limnoe lone orgánica enlatada o envasada|O|O||D||1|Escarola limnoe lone orgánica enlatada o envasada
50472906|Achicoria pancalieri riccia orgánica enlatada o envasada|O|O||D||1|Escarola pancalieri riccia orgánica enlatada o envasada
50472907|Achicoria ensalada rey orgánica enlatada o envasada|O|O||D||1|Escarola ensalada rey orgánica enlatada o envasada
50472908|Achicoria sanda orgánica enlatada o envasada|O|O||D||1|Escarola sanda orgánica enlatada o envasada
50472909|Achicoria scarola verde orgánica enlatada o envasada|O|O||D||1|Escarola scarola verde orgánica enlatada o envasada
50472910|Achicoria tres fine maraichere orgánica enlatada o envasada|O|O||D||1|Escarola tres fine maraichere orgánica enlatada o envasada
50472911|Achicoria wallone freisee wescelkkopf orgánica enlatada o envasada|O|O||D||1|Escarola wallone freisee wescelkkopf orgánica enlatada o envasada
50473000|Repollos chinos orgánicos en lata o en frasco|O|O||D||1|Coles chinas orgánicas en lata o en frasco
50473001|Bok choy orgánico enlatado o envasado|O|O||D||1
50473002|Bok choy enano orgánico enlatado o envasado|O|O||D||1
50473003|Flor de repollo chino orgánica enlatada o envasada|O|O||D||1|Flor de col china orgánica enlatada o envasada
50473004|Choy sum orgánico enlatado o envasado|O|O||D||1
50473005|Col (bok choy) enano orgánico enlatado o envasado|O|O||D||1
50473006|Col (bok choy) fengshan orgánico enlatado o envasado|O|O||D||1
50473007|Col (bok choy) jade pagoda orgánico enlatado o envasado|O|O||D||1
50473008|Col (bok choy) kasumi orgánico enlatado o envasado|O|O||D||1
50473009|col (bok choy)  nerva orgánico enlatado o envasado|O|O||D||1
50473010|Col (bok choy) rosette orgánico enlatado o envasado|O|O||D||1
50473011|Col (bok choy) ruffles orgánico enlatado o envasado|O|O||D||1
50473012|Col (bok choy) hoja  santo serrated orgánico enlatado o envasado|O|O||D||1
50473013|Col (bok choy) shangahai orgánico enlatado o envasado|O|O||D||1
50473014|Shantung orgánico enlatado o envasado|O|O||D||1
50473015|Repollo tip top orgánico enlatado o envasado|O|O||D||1|Col china tip top orgánico enlatado o envasado
50473016|Yau choy sum orgánico enlatado o envasado|O|O||D||1
50473100|Cebollines orgánicos en lata o en frasco|O|O||D||1
50473101|Cebollín chino orgánico enlatado o envasado|O|O||D||1
50473200|Maíces orgánicos en lata o en frasco|O|O||D||1
50473201|Maíz aloha orgánico enlatado o envasado|O|O||D||1
50473202|Maíz alpine orgánico enlatado o envasado|O|O||D||1
50473203|Maíz ambrosia orgánico enlatado o envasado|O|O||D||1
50473204|Maíz argent orgánico enlatado o envasado|O|O||D||1
50473205|Maíz aspen orgánico enlatado o envasado|O|O||D||1
50473206|Maíz avalancha orgánico enlatado o envasado|O|O||D||1
50473207|Maíz biqueen orgánico enlatado o envasado|O|O||D||1
50473208|Maíz  bodacious orgánico enlatado o envasado|O|O||D||1
50473209|Maíz  mantequilla y azúcar orgánico enlatado o envasado|O|O||D||1
50473210|Maíz  calico belle orgánico enlatado o envasado|O|O||D||1
50473211|Maíz  camelot orgánico enlatado o envasado|O|O||D||1
50473212|Maíz  challengercrisp ‘n dulce orgánico enlatado o envasado|O|O||D||1
50473213|Maíz  campeón orgánico enlatado o envasado|O|O||D||1
50473214|Maíz  algodón de azúcar orgánico enlatado o envasado|O|O||D||1
50473215|Maíz  dártagnan orgánico enlatado o envasado|O|O||D||1
50473216|Maíz  dazzle orgánico enlatado o envasado|O|O||D||1
50473217|Maíz  diamante y oro orgánico enlatado o envasado|O|O||D||1
50473218|Maíz  divinidad orgánico enlatado o envasado|O|O||D||1
50473219|Maíz  delicia doble orgánico enlatado o envasado|O|O||D||1
50473220|Maíz  gema doble orgánico enlatado o envasado|O|O||D||1
50473221|Maíz  earlivee orgánico enlatado o envasado|O|O||D||1
50473222|Maíz  temprano extra dulce orgánico enlatado o envasado|O|O||D||1
50473223|Maíz excel orgánico enlatado o envasado|O|O||D||1
50473224|Maíz  cruz dorada bantam orgánico enlatado o envasado|O|O||D||1
50473225|Maíz  miel y crema orgánico enlatado o envasado|O|O||D||1
50473226|Maíz  miel y perla orgánico enlatado o envasado|O|O||D||1
50473227|Maíz  miel dulce orgánico enlatado o envasado|O|O||D||1
50473228|Maíz  hudson orgánico enlatado o envasado|O|O||D||1
50473229|Maíz  dorado illini orgánico enlatado o envasado|O|O||D||1
50473230|Maíz  illini extra dulce orgánico enlatado o envasado|O|O||D||1
50473231|Maíz  increíble orgánico enlatado o envasado|O|O||D||1
50473232|Maíz  lochief orgánico enlatado o envasado|O|O||D||1
50473233|Maíz jubileo orgánico enlatado o envasado|O|O||D||1
50473234|Maíz jupbileo super dulce orgánico enlatado o envasado|O|O||D||1
50473235|Maíz  confite korn orgánico enlatado o envasado|O|O||D||1
50473236|Maíz  beso y acuso orgánico enlatado o envasado|O|O||D||1
50473237|Maíz  lancelot orgánico enlatado o envasado|O|O||D||1
50473238|Maíz dulce maple orgánico enlatado o envasado|O|O||D||1
50473239|Maíz  medley orgánico enlatado o envasado|O|O||D||1
50473240|Maíz merlin orgánico enlatado o envasado|O|O||D||1
50473241|Maíz milagro orgánico enlatado o envasado|O|O||D||1
50473242|Maíz nk – 199 orgánico enlatado o envasado|O|O||D||1
50473243|Maíz durazno y crema orgánico enlatado o envasado|O|O||D||1
50473244|Maíz blanco perla orgánico enlatado o envasado|O|O||D||1
50473245|Maíz  pegasus orgánico enlatado o envasado|O|O||D||1
50473246|Maíz  fenomenal orgánico enlatado o envasado|O|O||D||1
50473247|Maíz  dama de platino orgánico enlatado o envasado|O|O||D||1
50473248|Maíz  precioso orgánico enlatado o envasado|O|O||D||1
50473249|Maíz   pristine orgánico enlatado o envasado|O|O||D||1
50473250|Maíz  rápido orgánico enlatado o envasado|O|O||D||1
50473251|Maíz  radiante orgánico enlatado o envasado|O|O||D||1
50473252|Maíz  seneca brave orgánico enlatado o envasado|O|O||D||1
50473253|Maíz  amanecer seneca orgánico enlatado o envasado|O|O||D||1
50473254|Maíz  horizonte seneca orgánico enlatado o envasado|O|O||D||1
50473255|Maíz  brillo de estrella seneca orgánico enlatado o envasado|O|O||D||1
50473256|Maíz  noche blanca seneca orgánico enlatado o envasado|O|O||D||1
50473257|Maíz  showcase orgánico enlatado o envasado|O|O||D||1
50473258|Maíz  reina plateada orgánico enlatado o envasado|O|O||D||1
50473259|Maíz  bella nieve orgánico enlatado o envasado|O|O||D||1
50473260|Maíz nieve de primavera orgánico enlatado o envasado|O|O||D||1
50473261|Maíz  premio de primavera orgánico enlatado o envasado|O|O||D||1
50473262|Maíz  azúcar y oro orgánico enlatado o envasado|O|O||D||1
50473263|Maíz rollo de azúcar orgánico enlatado o envasado|O|O||D||1
50473264|Maíz nieve de azúcar orgánico enlatado o envasado|O|O||D||1
50473265|Maíz baile de sol orgánico enlatado o envasado|O|O||D||1
50473266|Maíz estrella tell orgánico enlatado o envasado|O|O||D||1
50473267|Maíz terminador orgánico enlatado o envasado|O|O||D||1
50473268|Maíz tesoro orgánico enlatado o envasado|O|O||D||1
50473269|Maíz tuxedo orgánico enlatado o envasado|O|O||D||1
50473300|Berros  orgánicos en lata o en frasco|O|O||D||1
50473301|Berros de tierra orgánicos enlatados o envasados|O|O||D||1
50473302|Nasturtium orgánico enlatado o envasado|O|O||D||1
50473303|Berros de agua orgánicos enlatados o envasados|O|O||D||1
50473304|Berros de invierno orgánicos enlatados o envasados|O|O||D||1
50473400|Cocombros orgánicos en lata o en frasco|O|O||D||1|Pepinos cohombro orgánicos en lata o en frasco
50473401|Cocombro arena orgánico enlatado o envasado|O|O||D||1|Pepino cohombro arena orgánico enlatado o envasado
50473402|Cocombro americano orgánico enlatado o envasado|O|O||D||1|Pepino cohombro americano orgánico enlatado o envasado
50473403|Cocombro atena orgánico enlatado o envasado|O|O||D||1|Pepino cohombro atena orgánico enlatado o envasado
50473404|Cocombro blanco lungo de parigi orgánico enlatado o envasado|O|O||D||1|Pepino cohombro blanco lungo de parigi orgánico enlatado o envasado
50473405|Cocombro verde burpless buen sabor orgánico enlatado o envasado|O|O||D||1|Pepino cohombro verde burpless buen sabor orgánico enlatado o envasado
50473406|Cocombro chicago pickling orgánico enlatado o envasado|O|O||D||1|Pepino cohombro chicago pickling orgánico enlatado o envasado
50473407|Cocombro manzana cristal orgánico enlatado o envasado|O|O||D||1|Pepino cohombro manzana cristal orgánico enlatado o envasado
50473408|Cocombro limón cristal orgánico enlatado o envasado|O|O||D||1|Pepino cohombro limón cristal orgánico enlatado o envasado
50473409|Cocombro danimas orgánico enlatado o envasado|O|O||D||1|Pepino cohombro danimas orgánico enlatado o envasado
50473410|Cocombro gherkin orgánico enlatado o envasado|O|O||D||1|Pepino cohombro gherkin orgánico enlatado o envasado
50473411|Cocombro hokus orgánico enlatado o envasado|O|O||D||1|Pepino cohombro hokus orgánico enlatado o envasado
50473412|Cocombro japonés orgánico enlatado o envasado|O|O||D||1|Pepino cohombro japonés orgánico enlatado o envasado
50473413|Cocombro karela orgánico enlatado o envasado|O|O||D||1|Pepino cohombro karela orgánico enlatado o envasado
50473414|Cocombro korila orgánico enlatado o envasado|O|O||D||1|Pepino cohombro korila orgánico enlatado o envasado
50473415|Cocombro verde largo mejorado orgánico enlatado o envasado|O|O||D||1|Pepino cohombro verde largo mejorado orgánico enlatado o envasado
50473416|Cocombro mas mercado orgánico enlatado o envasado|O|O||D||1|Pepino cohombro mas mercado orgánico enlatado o envasado
50473417|Cocombro enano orgánico enlatado o envasado|O|O||D||1|Pepino cohombro enano orgánico enlatado o envasado
50473418|Cocombro pickling nacional orgánico enlatado o envasado|O|O||D||1|Pepino cohombro pickling nacional orgánico enlatado o envasado
50473419|Cocombro persa orgánico enlatado o envasado|O|O||D||1|Pepino cohombro persa orgánico enlatado o envasado
50473420|Cocombro telégrafo orgánico enlatado o envasado|O|O||D||1|Pepino cohombro telégrafo orgánico enlatado o envasado
50473421|Cocombro telégrafo mejorado orgánico enlatado o envasado|O|O||D||1|Pepino cohombro telégrafo mejorado orgánico enlatado o envasado
50473422|Cocombro vert de massy cornichon orgánico enlatado o envasado|O|O||D||1|Pepino cohombro vert de massy cornichon orgánico enlatado o envasado
50473423|Cocombro yamato orgánico enlatado o envasado|O|O||D||1|Pepino cohombro yamato orgánico enlatado o envasado
50473500|Berenjenas orgánicas en lata o en frasco|O|O||D||1
50473501|Berenjena bambino orgánica enlatada o envasada|O|O||D||1
50473502|Berenjena  belleza negra orgánica enlatada o envasada|O|O||D||1
50473503|Berenjena  negra enorme orgánica enlatada o envasada|O|O||D||1
50473504|Berenjena  chino orgánica enlatada o envasada|O|O||D||1
50473505|Berenjena  huevo de pascua orgánica enlatada o envasada|O|O||D||1
50473506|Berenjena  filipino orgánica enlatada o envasada|O|O||D||1
50473507|Berenjena   mercado de florida orgánica enlatada o envasada|O|O||D||1
50473508|Berenjena  india orgánica enlatada o envasada|O|O||D||1
50473509|Berenjena  italiano orgánica enlatada o envasada|O|O||D||1
50473510|Berenjena  japonés orgánica enlatada o envasada|O|O||D||1
50473511|Berenjena  morado largo orgánica enlatada o envasada|O|O||D||1
50473512|Berenjena   rayas larga orgánica enlatada o envasada|O|O||D||1
50473513|Berenjena  mercado de dinero orgánica enlatada o envasada|O|O||D||1
50473514|Berenjena  ova orgánica enlatada o envasada|O|O||D||1
50473515|Berenjena   arveja orgánica enlatada o envasada|O|O||D||1
50473516|Berenjena  tom bajito orgánica enlatada o envasada|O|O||D||1
50473517|Berenjena  siciliano orgánica enlatada o envasada|O|O||D||1
50473518|Berenjena  tailandés orgánica enlatada o envasada|O|O||D||1
50473519|Berenjena  violeta de florencia orgánica enlatada o envasada|O|O||D||1
50473520|Berenjena  blanco orgánica enlatada o envasada|O|O||D||1
50473600|Endivias orgánicas en lata o en frasco|O|O||D||1
50473601|Endivias witloof de brucelas orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473602|Endivias francocastel orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473603|Endivias catalogna de galantina orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473604|Endivias chioggia orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473605|Endivias grumolo verde orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473606|Endivias raíz larga magdeburg orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473607|Endivias palla rosa zorzi precoce orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473608|Endivias radice amare orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473609|Endivias rosa de traviso orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473610|Endivias  rosa de verona orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473611|Endivias soncino orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473612|Endivias sugarthi orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473613|Endivias verona orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473614|Endivias witloof zoom orgánica orgánicas enlatadas o envasadas|O|O||D||1
50473700|Hinojos orgánicos en lata o en frasco|O|O||D||1
50473701|Hinojo cantino orgánico enlatado o envasado|O|O||D||1
50473702|Hinojo fino orgánico enlatado o envasado|O|O||D||1
50473703|Hinojoherald orgánico enlatado o envasado|O|O||D||1
50473704|Hinojo perfección orgánico enlatado o envasado|O|O||D||1
50473705|Hinojo sirio orgánico enlatado o envasado|O|O||D||1
50473706|Hinojo florencia dulce orgánico enlatado o envasado|O|O||D||1
50473707|Hinojo tardo orgánico enlatado o envasado|O|O||D||1
50473800|Ajos orgánicos en lata o en frasco|O|O||D||1
50473801|Ajo tarde california orgánico enlatado o envasado|O|O||D||1
50473802|Ajo tallos chinos orgánico enlatado o envasado|O|O||D||1
50473803|Ajo cebollin  orgánico enlatado o envasado|O|O||D||1
50473804|Ajo germidor orgánico enlatado o envasado|O|O||D||1
50473805|Ajo guardado largo orgánico enlatado o envasado|O|O||D||1
50473806|Ajo ramson orgánico enlatado o envasado|O|O||D||1
50473807|Ajo rocambola orgánico enlatado o envasado|O|O||D||1
50473808|Ajo rosa de lautrec orgánico enlatado o envasado|O|O||D||1
50473809|Ajo solent blanco orgánico enlatado o envasado|O|O||D||1
50473810|Ajo morado español orgánico enlatado o envasado|O|O||D||1
50473811|Ajo valentina italiana orgánico enlatado o envasado|O|O||D||1
50473900|Calabazas orgánicas en lata o en frasco|O|O||D||1
50473901|Petula orgánica enlatada o envasada|O|O||D||1|Luffa orgánica enlatada o envasada
50473902|Melon amargo orgánico enlatado o envasado|O|O||D||1
50473903|Botella calabaza orgánica enlatada o envasada|O|O||D||1|Mate orgánico enlatado o envasado
50473904|Calabash gounds orgánica enlatada o envasada|O|O||D||1|Calabaza de peregrino orgánica enlatada o envasada
50473905|Melón peludo orgánico enlatado o envasado|O|O||D||1
50473906|Calabaza amarga orgánica enlatada o envasada|O|O||D||1
50473907|Loofah suave orgánico enlatado o envasado|O|O||D||1|Zapatillo suave orgánico enlatado o envasado
50473908|Serpiente de calabaza orgánica enlatada o envasada|O|O||D||1|Chichinda orgánica enlatada o envasada
50473909|Calabaza larga amarga orgánica enlatada o envasada|O|O||D||1
50473910|Calabaza tinda orgánica enlatada o envasada|O|O||D||1
50473911|Calabaza tindoori orgánica enlatada o envasada|O|O||D||1
50474000|Guisantes orgánicas en lata o en frasco|O|O||D||1|Chícharos orgánicos en lata o en frasco
50474001|Guisante chino orgánica enlatada o envasada|O|O||D||1|Chícharo chino orgánico enlatado o envasado
50474002|Guisante inglés orgánica enlatada o envasada|O|O||D||1|Chícharo inglés orgánico enlatado o envasado
50474003|Guisante de jardín orgánica enlatada o envasada|O|O||D||1|Chícharo de jardín orgánico enlatado o envasado
50474004|Guisante nieve orgánica enlatada o envasada|O|O||D||1|Chícharo nieve orgánico enlatado o envasado
50474005|Guisante snap dulce orgánica enlatada o envasada|O|O||D||1|Chícharo snap dulce orgánico enlatado o envasado
50474100|Hierbas orgánicas en lata o en frasco|O|O||D||1|Perejil orgánico enlatado o envasado, Yerbabuena o hierbabuena orgánica enlatada o envasada
50474101|Albahaca orgánica enlatada o envasada|O|O||D||1
50474102|Laurel orgánico enlatado o envasado|O|O||D||1
50474103|Borraja orgánica enlatada o envasada|O|O||D||1
50474104|Alcaravea orgánica enlatada o envasada|O|O||D||1
50474105|Perifollo orgánico enlatado o envasado|O|O||D||1
50474106|Cilantro orgánico enlatado o envasado|O|O||D||1
50474107|Chipolinos orgánico enlatado o envasado|O|O||D||1
50474108|Hoja de curry orgánica enlatada o envasada|O|O||D||1
50474109|Eneldo orgánico enlatado o envasado|O|O||D||1
50474110|Epazote orgánico enlatado o envasado|O|O||D||1
50474111|Fenogreco orgánico enlatado o envasado|O|O||D||1
50474112|Limonaria orgánica enlatada o envasada|O|O||D||1|Té de limón orgánico enlatado o envasado
50474113|Mejorana orgánica enlatada o envasada|O|O||D||1
50474114|Menta orgánica enlatada o envasada|O|O||D||1
50474115|Orégano orgánico enlatado o envasado|O|O||D||1
50474116|Pápalo orgánico enlatado o envasado|O|O||D||1
50474117|Pápalo delgado orgánico enlatado o envasado|O|O||D||1
50474118|Perilla orgánica enlatada o envasada|O|O||D||1|Albahaca japonesa orgánica enlatada o envasada
50474119|Recao  orgánico enlatado o envasado|O|O||D||1
50474120|Romero orgánico enlatado o envasado|O|O||D||1
50474121|Salvia orgánica enlatada o envasada|O|O||D||1
50474122|Salsifí orgánica enlatada o envasada|O|O||D||1|Barba cabruna orgánica enlatada o envasada
50474123|Satureja orgánica enlatada o envasada|O|O||D||1|Ajedreas  orgánica enlatada o envasada
50474124|Estragón orgánico enlatado o envasado|O|O||D||1|Tarragón  orgánico enlatado o envasado
50474125|Tomillo orgánico enlatado o envasado|O|O||D||1
50474126|Tumeric orgánico enlatado o envasado|O|O||D||1|Cúrcuma orgánica enlatada o envasada
50474127|Verdolaga orgánica enlatada o envasada|O|O||D||1
50474200|Coles orgánicas en lata o en frasco|O|O||D||1
50474201|Col rizada orgánica enlatada o envasada|O|O||D||1
50474202|Repollo verde orgánico enlatado o envasado|O|O||D||1
50474300|Colinabos orgánicos en lata o en frasco|O|O||D||1|Colirrábanos orgánicos en lata o en frasco
50474301|Colinabo estrella azur orgánico enlatado o envasado|O|O||D||1|Colirrábano estrella azur orgánico enlatado o envasado
50474302|Colinabo verde viena orgánico enlatado o envasado|O|O||D||1|Colirrábano verde viena orgánico enlatado o envasado
50474303|Colinabo lanro orgánico enlatado o envasado|O|O||D||1|Colirrábano lanro orgánico enlatado o envasado
50474304|Colinabo viena morada orgánico enlatado o envasado|O|O||D||1|Colirrábano viena morada orgánico enlatado o envasado
50474305|Colinabo trero rowel orgánico enlatado o envasado|O|O||D||1|Colirrábano trero rowel orgánico enlatado o envasado
50474306|Colinabo viena blanca orgánico enlatado o envasado|O|O||D||1|Colirrábano viena blanca orgánico enlatado o envasado
50474400|Puerros orgánicos en lata o en frasco|O|O||D||1|Poros orgánicos en lata o en frasco
50474401|Puerro cobra gigante otoño orgánico enlatado o envasado|O|O||D||1|Poro cobra gigante otoño orgánico enlatado o envasado
50474402|Puerro otoño mamut 2 orgánico enlatado o envasado|O|O||D||1|Poro otoño mamut 2 orgánico enlatado o envasado
50474403|Puerro blue de solaise orgánico enlatado o envasado|O|O||D||1|Poro blue de solaise orgánico enlatado o envasado
50474404|Puerro cortina orgánico enlatado o envasado|O|O||D||1|Poro cortina orgánico enlatado o envasado
50474405|Puerro prelina orgánico enlatado o envasado|O|O||D||1|Poro prelina orgánico enlatado o envasado
50474406|Puerro salvaje orgánico enlatado o envasado|O|O||D||1|Poro salvaje orgánico enlatado o envasado
50474500|Lentejas  orgánicas en lata o en frasco|O|O||D||1
50474501|Lenteja beluga orgánica enlatada o envasada|O|O||D||1
50474502|Lenteja  verde francesa orgánica enlatada o envasada|O|O||D||1
50474503|Lenteja verde orgánica enlatada o envasada|O|O||D||1
50474504|Lenteja crimson pequeña orgánica enlatada o envasada|O|O||D||1
50474505|Lenteja pardina española orgánica enlatada o envasada|O|O||D||1
50474506|Lenteja roja separada orgánica enlatada o envasada|O|O||D||1
50474507|Lenteja amarilla separad orgánica enlatada o envasada|O|O||D||1
50474508|Lenteja tarahumara rosada orgánica enlatada o envasada|O|O||D||1
50474600|Lechugas orgánicas en lata o en frasco|O|O||D||1
50474601|Lechuga  bibb orgánica enlatada o envasada|O|O||D||1
50474602|Lechuga  boston orgánica enlatada o envasada|O|O||D||1
50474603|Lechuga frisee orgánica enlatada o envasada|O|O||D||1
50474604|Lechuga rosa lola orgánica enlatada o envasada|O|O||D||1
50474605|Lechuga  mixta masculina orgánica enlatada o envasada|O|O||D||1
50474606|Lechuga mizuna orgánica enlatada o envasada|O|O||D||1
50474607|Lechuga hoja roja orgánica enlatada o envasada|O|O||D||1
50474608|Lechuga oja roja roble orgánica enlatada o envasada|O|O||D||1
50474609|Lechuga romana ruby orgánica enlatada o envasada|O|O||D||1
50474610|Lechuga romana bebé roja orgánica enlatada o envasada|O|O||D||1
50474611|Lechuga cabeza de mantequilla orgánica enlatada o envasada|O|O||D||1
50474612|Lechuga china orgánica enlatada o envasada|O|O||D||1|Lechuga orejona orgánica enlatada o envasada
50474613|Lechuga cabeza tostada orgánica enlatada o envasada|O|O||D||1
50474614|Lechuga hoja verde orgánica enlatada o envasada|O|O||D||1
50474615|Lechuga iceberg orgánica enlatada o envasada|O|O||D||1
50474616|Lechuga cordero orgánica enlatada o envasada|O|O||D||1
50474617|Lechuga hoja suelta orgánica enlatada o envasada|O|O||D||1
50474618|Lechuga mache orgánica enlatada o envasada|O|O||D||1
50474619|Lechuga boston roja orgánica enlatada o envasada|O|O||D||1
50474620|Lechuga cabeza roja orgánica enlatada o envasada|O|O||D||1
50474621|Lechuga romana orgánica enlatada o envasada|O|O||D||1
50474622|Lechuga mostza roja rusa orgánica enlatada o envasada|O|O||D||1
50474623|Lechuga tatsoi orgánica enlatada o envasada|O|O||D||1
50474700|Ñames orgánicos en lata o en frasco|O|O||D||1
50474701|Ñame amarilla orgánica enlatada o envasada|O|O||D||1
50474702|Ñame blanca orgánica enlatada o envasada|O|O||D||1
50474703|Ñame coco orgánica enlatada o envasada|O|O||D||1
50474704|Ñame eddoes orgánica enlatada o envasada|O|O||D||1
50474705|Ñame isleña orgánica enlatada o envasada|O|O||D||1
50474706|Ñame lila orgánica enlatada o envasada|O|O||D||1
50474800|Hongos o champiñones orgánicos en lata o en frasco|O|O||D||1
50474801|Champiñón trompeta negra orgánico enlatado o envasado|O|O||D||1
50474802|Champiñón carmelito orgánico enlatado o envasado|O|O||D||1
50474803|Champiñón  orgánico enlatado o envasado|O|O||D||1
50474804|Champiñón chanterelle orgánico enlatado o envasado|O|O||D||1
50474805|Champiñón cremini orgánico enlatado o envasado|O|O||D||1
50474806|Champiñón enoki orgánico enlatado o envasado|O|O||D||1
50474807|Champiñón puercoespín orgánico enlatado o envasado|O|O||D||1
50474808|Champiñón gallina del bosque orgánico enlatado o envasado|O|O||D||1
50474809|Champiñón langosta orgánico enlatado o envasado|O|O||D||1
50474810|Champiñón morels orgánico enlatado o envasado|O|O||D||1
50474811|Champiñón ostra orgánico enlatado o envasado|O|O||D||1
50474812|Champiñón pleurotus orgánico enlatado o envasado|O|O||D||1
50474813|Champiñón pompom orgánico enlatado o envasado|O|O||D||1
50474814|Champiñón porcieni orgánico enlatado o envasado|O|O||D||1
50474815|Champiñón portobello orgánico enlatado o envasado|O|O||D||1
50474816|Champiñón shitake orgánico enlatado o envasado|O|O||D||1
50474817|Champiñón shimeji orgánico enlatado o envasado|O|O||D||1
50474818|Champiñón san jorge orgánico enlatado o envasado|O|O||D||1
50474819|Champiñón blanco orgánico enlatado o envasado|O|O||D||1
50474820|Champiñón tompeta blanca orgánico enlatado o envasado|O|O||D||1
50474821|Champiñón woodear orgánico enlatado o envasado|O|O||D||1
50474900|Mostazas orgánicas en lata o en frasco|O|O||D||1
50474901|Mostaza bambú  orgánica enlatada o envasada|O|O||D||1
50474902|Mostaza ajo orgánica enlatada o envasada|O|O||D||1
50474903|Mostaza hoja gigante orgánica enlatada o envasada|O|O||D||1
50474904|Mostaza rojo en nieve orgánica enlatada o envasada|O|O||D||1
50474905|Mostaza sureño orgánica enlatada o envasada|O|O||D||1
50474906|Mostaza corazón envuelto orgánica enlatada o envasada|O|O||D||1
50475000|Solanáceas (nightshades) orgánicas en lata o en frasco|O|O||D||1
50475001|Lámpara china orgánica enlatada o envasada|O|O||D||1
50475002|Mora de jardín|O|O||D||1
50475003|Naranjilla orgánica orgánicas enlatadas o envasadas|O|O||D||1
50475004|Tomatillo orgánica enlatada o envasada|O|O||D||1
50475100|Okras orgánicas en lata o en frasco|O|O||D||1
50475101|Okra artista orgánica enlatada o envasada|O|O||D||1
50475102|Okra vinotinto orgánica enlatada o envasada|O|O||D||1
50475103|Okra sin columna clemson orgánica enlatada o envasada|O|O||D||1
50475104|Okra verde enano vaina larga orgánica enlatada o envasada|O|O||D||1
50475105|Okra  mamut sin columna orgánica enlatada o envasada|O|O||D||1
50475106|Okra terciopelo rojo orgánica enlatada o envasada|O|O||D||1
50475107|Okra estrella de david reliquia orgánica enlatada o envasada|O|O||D||1
50475200|Cebollas orgánicas en lata o en frasco|O|O||D||1
50475201|Cebolla albion orgánica enlatada o envasada|O|O||D||1
50475202|Cebolla alisia craig orgánica enlatada o envasada|O|O||D||1
50475203|Cebolla hirviendo orgánica enlatada o envasada|O|O||D||1
50475204|Cebolla bufalo orgánica enlatada o envasada|O|O||D||1
50475205|Cebolla bulbo orgánica enlatada o envasada|O|O||D||1
50475206|Cebolla cremosa orgánica enlatada o envasada|O|O||D||1
50475207|Cebolla amarillo expreso o – x orgánica enlatada o envasada|O|O||D||1
50475208|Cebolla kelsae orgánica enlatada o envasada|O|O||D||1
50475209|Cebolla gigante marshal globo fen orgánica enlatada o envasada|O|O||D||1
50475210|Cebolla perla orgánica enlatada o envasada|O|O||D||1
50475211|Cebolla baron rojo orgánica enlatada o envasada|O|O||D||1
50475212|Cebolla roja orgánica enlatada o envasada|O|O||D||1|Cebolla morada orgánica enlatada o envasada
50475213|Cebolla rijnsberger orgánica enlatada o envasada|O|O||D||1
50475214|Cebolla senshyu semi – globo amarillo orgánica enlatada o envasada|O|O||D||1
50475215|Cebolla sturon orgánica enlatada o envasada|O|O||D||1
50475216|Cebolla sturgatter orgánica enlatada o envasada|O|O||D||1
50475217|Cebolla dulce orgánica enlatada o envasada|O|O||D||1
50475218|Cebolla torpedo o rojo italiana orgánica enlatada o envasada|O|O||D||1
50475219|Cebolla roja guardada orgánica enlatada o envasada|O|O||D||1
50475220|Cebolla blanca guardada orgánica enlatada o envasada|O|O||D||1
50475221|Cebolla amarilla guardada orgánica enlatada o envasada|O|O||D||1
50475300|Maníes orgánicos en lata o en frasco|O|O||D||1|Cacahuates orgánicos en lata o en frasco
50475301|Maní bambara orgánico enlatado o envasado|O|O||D||1|Cacahuate bambara orgánico enlatado o envasado
50475302|Maní florunner orgánico enlatado o envasado|O|O||D||1|Cacahuate florunner orgánico enlatado o envasado
50475303|Maní husa / kerstings orgánico enlatado o envasado|O|O||D||1|Cacahuate husa / kerstings  orgánico enlatado o envasado
50475304|Maní español orgánico enlatado o envasado|O|O||D||1|Cacahuate español orgánico enlatado o envasado
50475305|Maní valencia orgánico enlatado o envasado|O|O||D||1|Cacahuate valencia orgánico enlatado o envasado
50475306|Maní virginia orgánico enlatado o envasado|O|O||D||1|Cacahuate virginia orgánico enlatado o envasado
50475400|Alverjas orgánicas en lata o en frasco|O|O||D||1|Alberjones orgánicos en lata o en frasco
50475401|Alverja casco morado orgánico enlatada o encasada|O|O||D||1|Alberjón casco morado orgánico en lata o envasado
50475402|Alverja pinkeye orgánica enlatada o envasada|O|O||D||1|Alberjón pinkeye orgánico en lata o envasado
50475403|Alverja crowder orgánica enlatada o envasada|O|O||D||1|Alberjón crowder orgánico en lata o envasado
50475404|Alverja acre blanca  orgánica enlatada o envasada|O|O||D||1|Alberjón acre blanca orgánico en lata o envasado
50475405|Alverja ojo negro orgánica enlatada o envasada|O|O||D||1|Alberjón ojo negro orgánico en lata o envasado
50475406|Alverja crema zipper orgánica enlatada o envasada|O|O||D||1|Alberjón crema zipper orgánico en lata o envasado
50475500|Pimientos orgánicos en lata o en frasco|O|O||D||1|Chiles orgánicos en lata o en frasco
50475501|Pimentón ají orgánico enlatado o envasado|O|O||D||1|Ají orgánico enlatado o envasado
50475502|Pimentón  árbol orgánico enlatado o envasado|O|O||D||1|Chile de árbol orgánico enlatado o envasado
50475503|Pimentón queso orgánico enlatado o envasado|O|O||D||1
50475504|Pimentón chilaca orgánico enlatado o envasado|O|O||D||1|Chilaca orgánico enlatado o envasado
50475505|Pimentón cubanelles orgánico enlatado o envasado|O|O||D||1|Chile cubanelle o pimienta italiana orgánica enlatada o envasada
50475506|Pimentón fresno orgánico enlatado o envasado|O|O||D||1|Chile fresno orgánico enlatado o envasado
50475507|Pimentón kapia orgánico enlatado o envasado|O|O||D||1|Chile kapia orgánico enlatado o envasado
50475508|Pimentón coreano orgánico enlatado o envasado|O|O||D||1|Chile cheongyang orgánico enlatado o envasado
50475509|Pimentón manzano orgánico enlatado o envasado|O|O||D||1|Chile manzano o de cera orgánico enlatado o envasado
50475510|Pimentón melrose orgánico enlatado o envasado|O|O||D||1
50475511|Pimentón chile amarillo orgánico enlatado o envasado|O|O||D||1|Chile peruano amarillo orgánico enlatado o envasado
50475512|Pimentón aji dulce orgánico enlatado o envasado|O|O||D||1|Ají dulce orgánico enlatado o envasado
50475513|Pimentón anaheim orgánico enlatado o envasado|O|O||D||1
50475514|Pimentón ancho orgánico enlatado o envasado|O|O||D||1|Chile ancho o mulato orgánico enlatado o envasado
50475515|Pimentón campana orgánico enlatado o envasado|O|O||D||1|Chile campana orgánico enlatado o envasado
50475516|Pimentón cascabel orgánico enlatado o envasado|O|O||D||1|Chile cascabel orgánico enlatado o envasado
50475517|Pimentón cayenne orgánico enlatado o envasado|O|O||D||1|Pimienta de Cayena o roja orgánica enlatada o envasada
50475518|Pimentón anfitrión cereza orgánico enlatado o envasado|O|O||D||1
50475519|Pimentón chitespin orgánico enlatado o envasado|O|O||D||1|Chile chiltepín orgánico enlatado o envasado
50475520|Pimentón dedo picante orgánico enlatado o envasado|O|O||D||1|Chile Jwala orgánico enlatado o envasado
50475521|Pimentón guajillo orgánico enlatado o envasado|O|O||D||1|Chile guajillo orgánico enlatado o envasado
50475522|Pimentón guerro orgánico enlatado o envasado|O|O||D||1|Chile güero orgánico enlatado o envasado
50475523|Pimentón habanero orgánico enlatado o envasado|O|O||D||1|Chile habanero orgánico enlatado o envasado
50475524|Pimentón cera de hungria orgánico enlatado o envasado|O|O||D||1|Pimentón húngaro orgánico enlatado o envasado
50475525|Pimentón jalapeño orgánico enlatado o envasado|O|O||D||1|Chile cuaresmeño orgánico enlatado o envasado, Chile jalapeño, seco es chipotle o morita orgánico enlatado o envasado
50475526|Pimentón picante largo orgánico enlatado o envasado|O|O||D||1|Chile cola de rata orgánico enlatado o envasado
50475527|Pimentón marasol orgánico enlatado o envasado|O|O||D||1|Chile mirasol orgánico enlatado o envasado
50475528|Pimentón pasilla orgánico enlatado o envasado|O|O||D||1|Chile pasilla orgánico enlatado o envasado
50475529|Pimentón peperoncini orgánico enlatado o envasado|O|O||D||1
50475530|Pimentón pequin orgánico enlatado o envasado|O|O||D||1|Chile piquín orgánico enlatado o envasado
50475531|Pimentón pimiento orgánico enlatado o envasado|O|O||D||1|Pimiento morrón orgánico enlatado o envasado
50475532|Pimentón poblano orgánico enlatado o envasado|O|O||D||1|Chile poblano orgánico enlatado o envasado
50475533|Pimentón scotch bonnet orgánico enlatado o envasado|O|O||D||1|Pimientos Bonney o rojos Caribe orgánico enlatado o envasado
50475534|Pimentón serrano orgánico enlatado o envasado|O|O||D||1|Chile serrano orgánico enlatado o envasado, Chile verde orgánico enlatado o envasado
50475535|Pimentón tabasco orgánico enlatado o envasado|O|O||D||1|Chile tabasco orgánico enlatado o envasado
50475536|Pimentón tai  orgánico enlatado o envasado|O|O||D||1|Chile ojo de pájaro orgánico enlatado o envasado
50475537|Pimentón tepin orgánico enlatado o envasado|O|O||D||1|Chile mosquito o catarina orgánico enlatado o envasado
50475600|Papas orgánicas en lata o en frasco|O|O||D||1
50475601|Papa blanca larga orgánica enlatada o envasada|O|O||D||1
50475602|Papa redonda blanca orgánica enlatada o envasada|O|O||D||1
50475603|Papa redonda roja orgánica enlatada o envasada|O|O||D||1|Papa de cambray orgánica enlatada o envasada
50475604|Papa  russet orgánica enlatada o envasada|O|O||D||1
50475605|Papa morada orgánica enlatada o envasada|O|O||D||1
50475606|Papa amarilla orgánica enlatada o envasada|O|O||D||1
50475607|Papa nueva orgánica enlatada o envasada|O|O||D||1
50475608|Papa especial orgánica enlatada o envasada|O|O||D||1
50475700|Nabos suecos orgánicos en lata o en frasco|O|O||D||1
50475701|Nabo sueco acme orgánico enlatado o envasado|O|O||D||1
50475702|Nabo sueco angela orgánico enlatado o envasado|O|O||D||1
50475703|Nabo sueco el mejor orgánico enlatado o envasado|O|O||D||1
50475704|Nabo sueco marian orgánico enlatado o envasado|O|O||D||1
50475800|Vegetales marinos orgánicos en lata o en frasco|O|O||D||1
50475801|Agar-agar orgánico enlatado o envasado|O|O||D||1
50475802|Arame  orgánica enlatada o envasada|O|O||D||1
50475803|Alga dulce orgánica enlatada o envasada|O|O||D||1
50475804|Habichuelas vert de mer orgánica enlatada o envasada|O|O||D||1
50475805|Hijiki orgánica enlatada o envasada|O|O||D||1
50475806|Musgo irlandés orgánica enlatada o envasada|O|O||D||1
50475807|Quelpo orgánico enlatado o envasado|O|O||D||1
50475808|Laver orgánico enlatado o envasado|O|O||D||1
50475809|Nori orgánico enlatado o envasado|O|O||D||1
50475810|Alga roja orgánica enlatada o envasada|O|O||D||1
50475811|Kale de mar orgánica enlatada o envasada|O|O||D||1
50475812|Lechuga de mar orgánica enlatada o envasada|O|O||D||1
50475813|Algas de mar orgánica enlatada o envasada|O|O||D||1
50475814|Spirulina orgánica enlatada o envasada|O|O||D||1
50475815|Susabi nuri orgánica enlatada o envasada|O|O||D||1
50475816|Wakame orgánica enlatada o envasada|O|O||D||1
50475900|Chalotes orgánicos en lata o en frasco|O|O||D||1
50475901|Chalote atlántica orgánico enlatado o envasado|O|O||D||1
50475902|Chalote creación orgánico enlatado o envasado|O|O||D||1
50475903|Chalote drittler nido blanco orgánico enlatado o envasado|O|O||D||1
50475904|Chalote gigante mejorado amarillo orgánico enlatado o envasado|O|O||D||1
50475905|Chalote gourmet dorado orgánico enlatado o envasado|O|O||D||1
50475906|Chalote grise de bagnolet orgánico enlatado o envasado|O|O||D||1
50475907|Chalote hative de nort orgánico enlatado o envasado|O|O||D||1
50475908|Chalote pikant orgánico enlatado o envasado|O|O||D||1
50475909|Chalote papa roja orgánico enlatado o envasado|O|O||D||1
50475910|Chalote sante orgánico enlatado o envasado|O|O||D||1
50475911|Chalote topper orgánico enlatado o envasado|O|O||D||1
50476000|Alazanes orgánicos en lata o en frasco|O|O||D||1|Acederas orgánicas en lata o en frasco
50476001|Alazán dock orgánica enlatada o envasada|O|O||D||1|Acedera dock orgánica enlatada o envasada
50476002|Alazán jardín orgánica enlatada o envasada|O|O||D||1|Acedera jardín orgánica enlatada o envasada
50476003|Alazán oveja orgánica enlatada o envasada|O|O||D||1|Acedera oveja orgánica enlatada o envasada
50476004|Alazán madera orgánica enlatada o envasada|O|O||D||1|Acedera madera orgánica enlatada o envasada
50476100|Espinacas orgánicas en lata o en frasco|O|O||D||1
50476101|Espinaca americana orgánica enlatada o envasada|O|O||D||1
50476102|Espinaca bloomsdale orgánica enlatada o envasada|O|O||D||1
50476103|Espinaca invierno gigante orgánica enlatada o envasada|O|O||D||1
50476104|Espinaca horenso orgánica enlatada o envasada|O|O||D||1
50476105|Espinaca planta de hielo orgánica enlatada o envasada|O|O||D||1
50476106|Espinaca  cuarto de cordero orgánica enlatada o envasada|O|O||D||1
50476107|Espinaca malabra orgánica enlatada o envasada|O|O||D||1
50476108|Espinaca mendania orgánica enlatada o envasada|O|O||D||1
50476109|Espinaca nueva zelandia orgánica enlatada o envasada|O|O||D||1
50476110|Espinaca orach orgánica enlatada o envasada|O|O||D||1
50476111|Espinaca savoy orgánica enlatada o envasada|O|O||D||1
50476112|Espinaca hoja de sigma orgánica enlatada o envasada|O|O||D||1
50476113|Espinaca espacio orgánica enlatada o envasada|O|O||D||1
50476114|Espinaca trinidad orgánica enlatada o envasada|O|O||D||1
50476115|Espinaca agua orgánica enlatada o envasada|O|O||D||1
50476116|Espinaca de agua sesa|O|O||D||1
50476200|Calabazas orgánicas en lata o en frasco|O|O||D||1
50476201|Calabaza boston orgánica enlatada o envasada|O|O||D||1
50476202|Calabaza buttemut orgánica enlatada o envasada|O|O||D||1
50476203|Calabaza costata romanesca orgánica enlatada o envasada|O|O||D||1
50476204|Calabaza crookneck orgánica enlatada o envasada|O|O||D||1
50476205|Calabaza  cucuzza orgánica enlatada o envasada|O|O||D||1
50476206|Calabaza  delicata orgánica enlatada o envasada|O|O||D||1
50476207|Calabaza  delisioso orgánica enlatada o envasada|O|O||D||1
50476208|Calabaza verano dorado cuello torcido orgánica enlatada o envasada|O|O||D||1
50476209|Calabaza prolífico temprano cuello recto orgánica enlatada o envasada|O|O||D||1
50476210|Calabaza  oro orgánica enlatada o envasada|O|O||D||1
50476211|Calabaza  jack pequeño orgánica enlatada o envasada|O|O||D||1
50476212|Calabaza  campo de kentucky orgánica enlatada o envasada|O|O||D||1
50476213|Calabaza marrow orgánica enlatada o envasada|O|O||D||1
50476214|Calabaza  medio oriente orgánica enlatada o envasada|O|O||D||1
50476215|Calabaza  miniatura orgánica enlatada o envasada|O|O||D||1
50476216|Calabaza  orangetti orgánica enlatada o envasada|O|O||D||1
50476217|Calabaza pattypan orgánica enlatada o envasada|O|O||D||1
50476218|Calabaza  rondini orgánica enlatada o envasada|O|O||D||1
50476219|Calabaza  redonda orgánica enlatada o envasada|O|O||D||1
50476220|Calabaza  espagueti orgánica enlatada o envasada|O|O||D||1
50476221|Calabaza  estripeti orgánica enlatada o envasada|O|O||D||1
50476222|Calabaza  molde dulce orgánica enlatada o envasada|O|O||D||1
50476223|Calabaza  empanada dulce orgánica enlatada o envasada|O|O||D||1
50476224|Calabaza  premio triple  orgánica enlatada o envasada|O|O||D||1
50476225|Calabaza waltham butternut orgánica enlatada o envasada|O|O||D||1
50476226|Calabaza  arbusto scallop amarillo orgánica enlatada o envasada|O|O||D||1
50476227|Calabaza cuello recto amarillo orgánica enlatada o envasada|O|O||D||1
50476228|Calabaza zafiro orgánica enlatada o envasada|O|O||D||1
50476229|Calabaza zucchini orgánica enlatada o envasada|O|O||D||1
50476300|Batatas orgánicas en lata o en frasco|O|O||D||1|Camotes orgánicos en lata o en frasco
50476301|Batata beauregard orgánica enlatada o envasada|O|O||D||1|Camote beauregard orgánico enlatado o envasado
50476302|Batata centennial orgánica enlatada o envasada|O|O||D||1|Camote centennial orgánico enlatado o envasado
50476303|Batata diane orgánica enlatada o envasada|O|O||D||1|Camote diane orgánico enlatado o envasado
50476304|Batata dulce garnet orgánica enlatada o envasada|O|O||D||1|Camote dulce garnet orgánico enlatado o envasado
50476305|Batata georgia dulce rojo orgánica enlatada o envasada|O|O||D||1|Camote georgia dulce rojo orgánico enlatado o envasado
50476306|Batata  dorado orgánica enlatada o envasada|O|O||D||1|Camote dorado orgánico enlatado o envasado
50476307|Batata hanna  orgánica enlatada o envasada|O|O||D||1|Camote hanna orgánico enlatado o envasado
50476308|Batata japonés orgánica enlatada o envasada|O|O||D||1|Camote japonés orgánico enlatado o envasado
50476309|Batata jersey orgánica enlatada o envasada|O|O||D||1|Camote jersey orgánico enlatado o envasado
50476310|Batata joya orgánica enlatada o envasada|O|O||D||1|Camote joya orgánico enlatado o envasado
50476311|Batata meryland roja orgánica enlatada o envasada|O|O||D||1|Camote meryland roja orgánico enlatado o envasado
50476312|Batata nema dorado orgánica enlatada o envasada|O|O||D||1|Camote nema dorado orgánico enlatado o envasado
50476313|Batata o´henry orgánica enlatada o envasada|O|O||D||1|Camote o´henry orgánico enlatado o envasado
50476314|Batata okinawan orgánica enlatada o envasada|O|O||D||1|Camote okinawan orgánico enlatado o envasado
50476315|Batata naranja orgánica enlatada o envasada|O|O||D||1|Camote naranja orgánico enlatado o envasado
50476316|Batata oriental orgánica enlatada o envasada|O|O||D||1|Camote oriental orgánico enlatado o envasado
50476317|Batata jersey rojo orgánica enlatada o envasada|O|O||D||1|Camote jersey rojo orgánico enlatado o envasado
50476318|Batata mar rojo orgánica enlatada o envasada|O|O||D||1|Camote mar rojo orgánico enlatado o envasado
50476319|Batata brillo rojo orgánica enlatada o envasada|O|O||D||1|Camote brillo rojo orgánico enlatado o envasado
50476320|Batata jersey amarillo orgánica enlatada o envasada|O|O||D||1|Camote jersey amarillo orgánico enlatado o envasado
50476400|Tomates orgánicos en lata o en frasco|O|O||D||1|Jitomates orgánicos en lata o en frasco
50476401|Tomates ailsa craig orgánico enlatado o envasado|O|O||D||1|Jitomate ailsa craig orgánico enlatado o envasado
50476402|Tomates alicante orgánico enlatado o envasado|O|O||D||1|Jitomate alicante orgánico enlatado o envasado
50476403|Tomates ciruela negra orgánico enlatado o envasado|O|O||D||1|Jitomate ciruela negra orgánico enlatado o envasado
50476404|Tomates vino de brandy orgánico enlatado o envasado|O|O||D||1|Jitomate vino de brandy orgánico enlatado o envasado
50476405|Tomates bella cereza orgánico enlatado o envasado|O|O||D||1|Jitomate bella cereza orgánico enlatado o envasado
50476406|Tomates cereza orgánico enlatado o envasado|O|O||D||1|Jitomate cereza orgánico enlatado o envasado
50476407|Tomates delicioso orgánico enlatado o envasado|O|O||D||1|Jitomate delicioso orgánico enlatado o envasado
50476408|Tomates dombito orgánico enlatado o envasado|O|O||D||1|Jitomate dombito orgánico enlatado o envasado
50476409|Tomates delicia del jardín orgánico enlatado o envasado|O|O||D||1|Jitomate delicia del jardín orgánico enlatado o envasado
50476410|Tomates uva orgánico enlatado o envasado|O|O||D||1|Jitomate uva orgánico enlatado o envasado
50476411|Tomates verde orgánico enlatado o envasado|O|O||D||1|Tomate verde orgánico enlatado o envasado
50476412|Tomates super marmande orgánico enlatado o envasado|O|O||D||1|Jitomate super marmande orgánico enlatado o envasado
50476413|Tomates rayas naturales marvel orgánico enlatado o envasado|O|O||D||1|Jitomate rayas naturales marvel orgánico enlatado o envasado
50476414|Tomates minibel orgánico enlatado o envasado|O|O||D||1|Jitomate minibel orgánico enlatado o envasado
50476415|Tomates oaxacan orgánico enlatado o envasado|O|O||D||1|Jitomate oaxaca orgánico enlatado o envasado
50476416|Tomates alerta roja orgánico enlatado o envasado|O|O||D||1|Jitomate alerta roja orgánico enlatado o envasado
50476417|Tomates roma vf orgánico enlatado o envasado|O|O||D||1|Jitomate roma vf orgánico enlatado o envasado
50476418|Tomates marzano zan orgánico enlatado o envasado|O|O||D||1|Jitomate marzano zan orgánico enlatado o envasado
50476419|Tomates shirley orgánico enlatado o envasado|O|O||D||1|Jitomate shirley orgánico enlatado o envasado
50476420|Tomates siberia orgánico enlatado o envasado|O|O||D||1|Jitomate siberia orgánico enlatado o envasado
50476421|Tomates super beefsteak orgánico enlatado o envasado|O|O||D||1|Jitomate super beefsteak orgánico enlatado o envasado
50476422|Tomates tigerella orgánico enlatado o envasado|O|O||D||1|Jitomate tigerella orgánico enlatado o envasado
50476423|Tomates tiny tim orgánico enlatado o envasado|O|O||D||1|Jitomate tiny tim orgánico enlatado o envasado
50476424|Tomates tumbler orgánico enlatado o envasado|O|O||D||1|Jitomate tumbler orgánico enlatado o envasado
50476425|Tomates cocktail amarillo orgánico enlatado o envasado|O|O||D||1
50476426|Tomates forma de pera amarillo orgánico enlatado o envasado|O|O||D||1
50476427|Tomates perfección amarilla orgánico enlatado o envasado|O|O||D||1
50476500|Nabos orgánicos en lata o en frasco|O|O||D||1
50476501|Nabo globo verde orgánico enlatado o envasado|O|O||D||1
50476502|Nabo bola dorada orgánico enlatado o envasado|O|O||D||1
50476503|Nabo mercado de manchester orgánico enlatado o envasado|O|O||D||1
50476504|Nabo top morado milan orgánico enlatado o envasado|O|O||D||1
50476505|Nabo top morado blanco orgánico enlatado o envasado|O|O||D||1
50476506|Nabo bola de nieve orgánico enlatado o envasado|O|O||D||1
50476507|Nabo tokio orgánico enlatado o envasado|O|O||D||1
50476508|Nabo cruz de tokio orgánico enlatado o envasado|O|O||D||1
50476600|Auyamas orgánicas en lata o en frasco|O|O||D||1|Calabazas gigantes orgánicas en lata o en frasco
50476601|Calabaza acorn orgánica enlatada o envasada|O|O||D||1|Calabaza gigante acorn orgánica enlatada o envasada
50476602|Calabaza gigante atlántico orgánica enlatada o envasada|O|O||D||1|Calabaza gigante atlántico orgánica enlatada o envasada
50476603|Calabaza banana rosado orgánica enlatada o envasada|O|O||D||1|Calabaza gigante banana rosado orgánica enlatada o envasada
50476604|Calabaza max grande orgánica enlatada o envasada|O|O||D||1|Calabaza gigante max orgánica enlatada o envasada
50476605|Calabaza  orgánica enlatada o envasada|O|O||D||1|Calabaza de castilla orgánica enlatada o envasada
50476606|Calabaza carnaval orgánica enlatada o envasada|O|O||D||1|Calabaza gigante carnaval orgánica enlatada o envasada
50476607|Auyama queso orgánica enlatada o envasada|O|O||D||1|Calabaza gigante queso orgánica enlatada o envasada
50476608|Calabaza príncipe coronado orgánica enlatada o envasada|O|O||D||1|Calabaza gigante príncipe coronado orgánica enlatada o envasada
50476609|Calabaza  curcibita orgánica enlatada o envasada|O|O||D||1|Calabaza gigante curcibita orgánica enlatada o envasada
50476610|Calabaza cushaw orgánica enlatada o envasada|O|O||D||1|Calabaza gigante cushaw orgánica enlatada o envasada
50476611|Calabaza  gigante auyama orgánica enlatada o envasada|O|O||D||1
50476612|Calabaza  hubbard orgánica enlatada o envasada|O|O||D||1|Calabaza gigante hubbard orgánica enlatada o envasada
50476613|Calabaza  jerrahdale orgánica enlatada o envasada|O|O||D||1|Calabaza gigante jerrahdale orgánica enlatada o envasada
50476614|Calabaza  kabocha orgánica enlatada o envasada|O|O||D||1|Calabaza gigante kabocha orgánica enlatada o envasada
50476615|Calabaza queensland azul orgánica enlatada o envasada|O|O||D||1|Calabaza gigante queensland azul orgánica enlatada o envasada
50476616|Calabaza rouge vif détampes orgánica enlatada o envasada|O|O||D||1|Calabaza gigante rouge vif détampes orgánica enlatada o envasada
50476617|Calabaza  turban turco orgánica enlatada o envasada|O|O||D||1|Calabaza gigante turban turco orgánica enlatada o envasada
50476618|Calabaza  valenciano orgánica enlatada o envasada|O|O||D||1|Calabaza gigante valenciano orgánica enlatada o envasada
50476619|Calabaza  warted hubbard orgánica enlatada o envasada|O|O||D||1|Calabaza gigante warted hubbard orgánica enlatada o envasada
50476620|Auyama whangaparoa orgánica enlatada o envasada|O|O||D||1|Calabaza gigante whangaparoa orgánica enlatada o envasada
50476700|Ñames orgánicos en lata o en frasco|O|O||D||1
50476701|Ñame agria africana orgánica enlatada o envasada|O|O||D||1
50476702|Ñame agria asiática orgánica enlatada o envasada|O|O||D||1
50476703|Ñame china orgánico enlatado o envasado|O|O||D||1
50476704|Ñame globo orgánico enlatado o envasado|O|O||D||1
50476705|Ñame grater orgánico enlatado o envasado|O|O||D||1
50476706|Ñame japonesa orgánico enlatado o envasado|O|O||D||1
50476707|Ñame lesser orgánico enlatado o envasado|O|O||D||1
50476708|Ñame papa orgánico enlatado o envasado|O|O||D||1
50476709|Ñame guinea blanca orgánico enlatado o envasado|O|O||D||1
50476710|Ñame guinea amarillo orgánico enlatado o envasado|O|O||D||1
50476800|Vegetales Nominant orgánicos en lata o en frasco|O|O||D||1|Vegetales predominantes orgánicos en lata o en frasco, Nopal orgánico en lata o en frasco
50476801|Alfalfa orgánica enlatada o envasada|O|O||D||1
50476802|Hojas de aloe orgánica enlatada o envasada|O|O||D||1|Hojas de sábila orgánica enlatada o envasada, Penca de sábila orgánica enlatada o envasada
50476803|Apio orgánico enlatado o envasado|O|O||D||1
50476804|Arrurruz orgánica enlatada o envasada|O|O||D||1
50476805|Punta de flecha orgánica enlatada o envasada|O|O||D||1|Sagittaria orgánica enlatada o envasada
50476806|rúcula orgánica enlatada o envasada|O|O||D||1
50476807|Arum orgánica enlatada o envasada|O|O||D||1|Taro orgánico enlatado o envasado
50476808|Raíz de bambú orgánica enlatada o envasada|O|O||D||1
50476809|Hojas de plátano orgánica enlatada o envasada|O|O||D||1
50476810|Batatas orgánica enlatada o envasada|O|O||D||1
50476811|Brotes de frijol orgánicos enlatados o envasados|O|O||D||1
50476812|Top de remolacha orgánica enlatada o envasada|O|O||D||1|Betabel orgánico enlatado o envasado
50476813|Melón agrio orgánico enlatado o envasado|O|O||D||1|Balsamina orgánica enlatada o envasada
50476814|Bayas de alcaparra orgánica orgánicas enlatadas o envasadas|O|O||D||1
50476815|Carob orgánico enlatado o envasado|O|O||D||1|Algarrobo orgánico enlatado o envasado
50476816|Cha-om orgánico enlatado o envasado|O|O||D||1
50476817|Chayote o guatila orgánico enlatado o envasado|O|O||D||1
50476818|Garbanzo orgánico enlatado o envasado|O|O||D||1
50476819|Verde de crisantemos orgánico enlatado o envasado|O|O||D||1
50476820|Verde de diente de león orgánico enlatado o envasado|O|O||D||1
50476821|Diente de león orgánico enlatado o envasado|O|O||D||1
50476822|Dasheen orgánico enlatado o envasado|O|O||D||1
50476823|Puntas de alverja orgánico enlatado o envasado|O|O||D||1
50476824|Diakon orgánico enlatado o envasado|O|O||D||1|Rábano orgánico enlatado o envasado
50476825|Donqua orgánica enlatada o envasada|O|O||D||1|Ginseng hembra orgánica enlatada o envasada
50476826|Helecho orgánico enlatado o envasado|O|O||D||1|Brotes de helecho orgánico enlatado o envasado
50476827|Gai choi orgánico enlatado o envasado|O|O||D||1|Mostaza castaña orgánica enlatada o envasada
50476828|Gailon orgánico enlatado o envasado|O|O||D||1|Brécol chino orgánico enlatado o envasado
50476829|Galanga orgánica enlatada o envasada|O|O||D||1|Jengibre azul orgánico enlatado o envasado
50476830|Raíz de jengibre orgánica enlatada o envasada|O|O||D||1
50476831|Gobo orgánico enlatado o envasado|O|O||D||1|Garduña orgánica enlatada o envasada
50476832|Brote de lúpulo orgánico enlatado o envasado|O|O||D||1
50476833|Rabano blanco orgánico enlatado o envasado|O|O||D||1|Rábano de caballo orgánico enlatado o envasado
50476834|Jicama orgánica enlatada o envasada|O|O||D||1
50476835|Kuduz orgánica enlatada o envasada|O|O||D||1|Kudzu orgánico enlatado o envasado
50476836|Bulbo de margarita orgánico enlatado o envasado|O|O||D||1|Bulbo de lili chino orgánico enlatado o envasado
50476837|Linkok orgánico enlatado o envasado|O|O||D||1
50476838|Lo bok orgánico enlatado o envasado|O|O||D||1
50476839|Frijol largo orgánico enlatado o envasado|O|O||D||1|Fríjol serpiente orgánico enlatado o envasado
50476840|Raíz de lotus orgánico enlatado o envasado|O|O||D||1|Rosa del Nilo orgánica enlatada o envasada
50476841|Hojas de maguey orgánica enlatada o envasada|O|O||D||1|Hoja de agave orgánica enlatada o envasada, Penca de maguey orgánica enlatada o envasada
50476842|Mallows orgánico enlatado o envasado|O|O||D||1|Malva orgánica enlatada o envasada
50476843|Sapote mamey orgánico enlatado o envasado|O|O||D||1|Mamey orgánico enlatado o envasado
50476844|Moap orgánico enlatado o envasado|O|O||D||1
50476845|Moo orgánico enlatado o envasado|O|O||D||1
50476846|Moqua orgánica enlatada o envasada|O|O||D||1
50476847|Opos orgánicos enlatados o envasados|O|O||D||1
50476848|Corazon de palma orgánico enlatado o envasado|O|O||D||1|Palmito orgánico enlatado o envasado
50476849|Paprika orgánica enlatada o envasada|O|O||D||1
50476850|Purslane orgánica enlatada o envasada|O|O||D||1|Verdolaga orgánica enlatada o envasada
50476851|Raddichios orgánica enlatada o envasada|O|O||D||1|Achicoria morada orgánica enlatada o envasada
50476852|Sinquas orgánica enlatada o envasada|O|O||D||1|Zapallo orgánico enlatado o envasado
50476853|Frijol de soya orgánicos enlatados o envasados|O|O||D||1
50476854|Spoonwart orgánico enlatado o envasado|O|O||D||1|Hierba del escorbuto orgánica enlatada o envasada
50476855|Uva tassele hyacinth orgánico enlatado o envasado|O|O||D||1
50476856|Taro orgánico enlatado o envasado|O|O||D||1|Tales orgánico enlatado o envasado
50476857|Hoja de taro orgánica enlatada o envasada|O|O||D||1
50476858|Tallo de taro orgánico enlatado o envasado|O|O||D||1
50476859|Tapeguaje orgánico enlatado o envasado|O|O||D||1
50476860|Verde tierno orgánico enlatado o envasado|O|O||D||1
50476861|Tindora orgánico enlatado o envasado|O|O||D||1
50476862|Árbol de cebolla orgánico enlatado o envasado|O|O||D||1|Cebollas egipcias orgánica enlatada o envasada
50476863|Udo orgánico enlatado o envasado|O|O||D||1
50476864|Agua castaño orgánico enlatado o envasado|O|O||D||1|Castaña de agua china orgánica enlatada o envasada
50476865|Yumpi orgánico enlatado o envasado|O|O||D||1|Akankong orgánico enlatado o envasado
50476866|Yautia orgánico enlatado o envasado|O|O||D||1|Mapuey orgánico enlatado o envasado
50476867|Yu choy orgánico enlatado o envasado|O|O||D||1
50476868|Yuca orgánica enlatada o envasada|O|O||D||1
50476900|Alverjas dulces orgánicas en lata o en frasco|O|O||D||1|Chícharos orgánicos en lata o en frasco
50476901|Alverja biquini orgánica enlatada o envasada|O|O||D||1|Chícharo biquini orgánico en lata o envasado
50476902|Alverja cavalier orgánica enlatada o envasada|O|O||D||1|Chícharo cavalier orgánico en lata o envasado
50476903|Alverja margarita orgánica enlatada o envasada|O|O||D||1|Chícharo margarita orgánico en lata o envasado
50476904|Alverja dar fon orgánica enlatada o envasada|O|O||D||1|Chícharo dar fon orgánico en lata o envasado
50476905|Alverja "early onward" orgánica enlatada o envasada|O|O||D||1|Chícharo "early onward" orgánico en lata o envasado
50476906|Alverja primer feltham orgánica enlatada o envasada|O|O||D||1|Chícharo primer feltham orgánico en lata o envasado
50476907|Alverja verde hurst shaft orgánica enlatada o envasada|O|O||D||1|Chícharo verde hurst shaft orgánico en lata o envasado
50476908|Guisante oregón sugar pod orgánica enlatada o envasada|O|O||D||1|Chícharo oregón sugar pod orgánico en lata o envasado
50476909|Alverja príncipe alberto orgánica enlatada o envasada|O|O||D||1|Chícharo príncipe alberto orgánico en lata o envasado
50476910|Alverja reuzensuiker orgánica enlatada o envasada|O|O||D||1|Chícharo reuzensuiker orgánico en lata o envasado
51101500|Antibióticos|O|O||D||1
51101503|Cloranfenicol|O|O||D||1|Clorfenamina
51101504|Clindamicina|O|O||D||1|Clindamina
51101507|Penicilina|O|O||D||1|Bencilpenicilina, Ácido benzilpenicilínico
51101508|Sulfonamidas antibióticas|O|O||D||1|Sulfonamidas antibióticas
51101509|Tetraciclina|O|O||D||1
51101510|Oxitetraciclina|O|O||D||1
51101511|Amoxicilina|O|O||D||1
51101512|Cloxacilina|O|O||D||1
51101513|Neomicina|O|O||D||1
51101514|Sulfato framicetina|O|O||D||1
51101515|Clorhidrato de lincomicina|O|O||D||1
51101516|Gramicidina|O|O||D||1
51101518|Ofloxacina|O|O||D||1
51101519|Tiamfenicol|O|O||D||1
51101521|Pristinamicina|O|O||D||1
51101522|Claritromicina|O|O||D||1
51101523|Clorquinaldol|O|O||D||1
51101524|Bacitracina zinc|O|O||D||1
51101525|Peróxido de benzoilo|O|O||D||1
51101526|Polimixinas|O|O||D||1
51101527|Colistina metansulfonato|O|O||D||1
51101528|Tirotricina|O|O||D||1
51101530|Trimetoprima|O|O||D||1|Trimetoprima
51101531|Estreptograminas|O|O||D||1
51101532|Teicoplanina|O|O||D||1
51101533|Rifamicina|O|O||D||1
51101534|Ceftibuten|O|O||D||1
51101535|Cefradina|O|O||D||1
51101536|Moxifloxacina clorhidrato|O|O||D||1|Clorhidrato de moxifloxacina
51101537|Lomefloxacina cloridrato|O|O||D||1|Clorhidrato de lomefloxacina
51101538|Levofloxacina|O|O||D||1|Lecofloxacina
51101539|Grepafloxacina clorhidrato|O|O||D||1|Clorhidrato de grapafloxacina
51101540|Gatifloxacina|O|O||D||1
51101541|Enoxacina|O|O||D||1
51101542|Ciprofloxacina|O|O||D||1
51101543|Cefapirina|O|O||D||1
51101544|Loracarbef|O|O||D||1
51101545|Ceftizoxima|O|O||D||1
51101546|Norfloxacina|O|O||D||1
51101547|Cefprozil|O|O||D||1
51101548|Fosfomicina trometamol|O|O||D||1
51101549|Linezolida|O|O||D||1
51101550|Cefalexina|O|O||D||1
51101551|Ceftriaxona|O|O||D||1
51101552|Ceftazidima|O|O||D||1
51101553|Alatrofloxacina|O|O||D||1
51101554|Dicloxacilina sódica|O|O||D||1
51101555|Aztreonam|O|O||D||1
51101556|Minociclina|O|O||D||1
51101557|Doxiciclina|O|O||D||1
51101558|Demeclociclina|O|O||D||1
51101559|Clortetraciclina|O|O||D||1
51101560|Ticarcilina|O|O||D||1
51101561|Piperacilina|O|O||D||1
51101562|Oxacilina sódica|O|O||D||1
51101563|Mesilato de trovafloxacina|O|O||D||1
51101564|Mezlocilina|O|O||D||1
51101565|Cefpodoxima proxetil|O|O||D||1
51101566|Carbenicilina|O|O||D||1
51101567|Ampicilina|O|O||D||1
51101568|Troleandomicina|O|O||D||1
51101569|Roxitromicina|O|O||D||1
51101570|Eritromicina|O|O||D||1
51101571|Diritromicina|O|O||D||1
51101572|Azitromicina|O|O||D||1
51101573|Cefuroxima|O|O||D||1
51101574|Furazolidona|O|O||D||1
51101575|Nafcilina sódica|O|O||D||1
51101576|Cefalotina|O|O||D||1
51101577|Cefdinir|O|O||D||1
51101578|Cefazolina|O|O||D||1
51101579|Cefamandol|O|O||D||1
51101580|Cefadroxilo|O|O||D||1
51101581|Cefaclor|O|O||D||1
51101582|Tobramicina|O|O||D||1
51101583|Cefditoren|O|O||D||1
51101584|Gentamicina|O|O||D||1
51101585|Netilmicina|O|O||D||1|Sulfato de netilmicina
51101586|Amikacina|O|O||D||1
51101587|Kanamicina|O|O||D||1
51101588|Sparfloxacina|O|O||D||1
51101589|Carbapenémicos incluyendo tienamicinas|O|O||D||1
51101590|Quinupristina|O|O||D||1
51101591|Vancomicina|O|O||D||1
51101592|Cefoxitina|O|O||D||1
51101593|Cefotaxima|O|O||D||1|Cefotaxima, Cefotaxime
51101594|Cefepima|O|O||D||1|Cefepime
51101595|Cefotetan|O|O||D||1
51101596|Cefoperazona|O|O||D||1
51101597|Mupirocina|O|O||D||1
51101598|Cefonicida|O|O||D||1
51101599|Cefixima|O|O||D||1
51101600|Amebicidas, Tricomonacidas y Antiprotozoarios|O|O||D||1
51101601|Atovacuona|O|O||D||1|Atuvacuona
51101602|Clorhidrato de eflomitina|O|O||D||1
51101603|Metronidazol|O|O||D||1
51101604|Antimoniato de meglumina|O|O||D||1
51101606|Rifapentina|O|O||D||1
51101607|Óxido de calcio|O|O||D||1
51101610|Clorocresol|O|O||D||1
51101611|Meropenem|O|O||D||1
51101612|Polynoxylin|O|O||D||1|Polinoxilina
51101613|Isetionato de pentamidina|O|O||D||1
51101614|Furoato de diloxanida|O|O||D||1
51101616|Melarsoprol|O|O||D||1
51101617|Tinidazol|O|O||D||1|Tindamax
51101618|Taurolidina|O|O||D||1
51101619|Secnidazol|O|O||D||1
51101620|Iodoquinol|O|O||D||1
51101624|Clorhidrato de metronidazol|O|O||D||1
51101625|Sulfato de paromomicina|O|O||D||1
51101629|Glucuronato de trimetrexato|O|O||D||1
51101630|Isetionato de propamidina|O|O||D||1
51101631|Nitazoxanida|O|O||D||1
51101632|Faropenem de sodio|O|O||D||1
51101700|Antihelmínticos y otros antiparasitarios|O|O||D||1|Vermífugo
51101701|Albendazol|O|O||D||1
51101702|Mebendazol|O|O||D||1|Lomper, Ovex, Vermo
51101703|Oxamniquina|O|O||D||1
51101704|Citrato de piperazina|O|O||D||1
51101705|Praziquantel|O|O||D||1
51101706|Pamoato de pirantel|O|O||D||1
51101707|Tiabendazol|O|O||D||1
51101708|Sulfanilamida|O|O||D||1
51101709|Niclosamida|O|O||D||1|Niclosamida, Niclosamide
51101710|Piperazina|O|O||D||1|Dietilendiamina
51101711|Citrato de dietilcarbamazina|O|O||D||1
51101712|Tiocianoacetato de isobornilo|O|O||D||1
51101713|Antiparasitario tópico malatión|O|O||D||1
51101714|Metilparabeno|O|O||D||1|Metil p-hidroxibenzoato
51101715|Antiparasitario tópico permetrina|O|O||D||1
51101716|Tetracloroetileno|O|O||D||1
51101717|Ivermectina|O|O||D||1
51101718|Benzoato de bencilo|O|O||D||1
51101719|Butóxido de piperonilo|O|O||D||1
51101720|Lindano|O|O||D||1|Gama-hexaclorociclohexano, Gamexane, Gammalli
51101721|Febantel|O|O||D||1
51101800|Fungicidas|O|O||D||1
51101801|Anfotericina b|O|O||D||1
51101802|Clorhidrato de butenafina|O|O||D||1
51101803|Nitrato de butoconazol|O|O||D||1
51101804|Ciclopiroxolamina|O|O||D||1
51101805|Clotrimazol|O|O||D||1
51101806|Nitrato de econazol|O|O||D||1
51101807|Fluconazol|O|O||D||1
51101808|Flucitosina|O|O||D||1
51101809|Griseofulvina|O|O||D||1
51101810|Itraconazol|O|O||D||1|Voriconazol
51101811|Ketoconazol|O|O||D||1
51101812|Miconazol|O|O||D||1
51101813|Clorhidrato de naftifina|O|O||D||1
51101814|Natamicina|O|O||D||1|Pimaricina
51101815|Nistatina|O|O||D||1
51101816|Nitrato de oxiconazol|O|O||D||1
51101817|Nitrato de sulconazol|O|O||D||1
51101818|Clorhidrato de terbinafina|O|O||D||1
51101819|Nitrato de terconazol|O|O||D||1
51101820|Tioconazol|O|O||D||1
51101821|Tolnaftato|O|O||D||1
51101824|Ácido undecilénico|O|O||D||1
51101825|Ciclopirox|O|O||D||1
51101826|Sulfato de estreptomicina|O|O||D||1
51101827|Isoconazol|O|O||D||1
51101828|Terconazol|O|O||D||1
51101829|Undecilenato de calcio|O|O||D||1
51101830|Ácido octanoico|O|O||D||1|Ácido caprílico
51101831|Triacetina|O|O||D||1|Triacetato de glicerina, Triglicérido triacetoxy propano
51101832|Voriconazol|O|O||D||1
51101834|Nitrato de miconazol|O|O||D||1
51101835|Acetato de caspofungina|O|O||D||1
51101836|Propionato de sodio|O|O||D||1|Propanoato de sodio
51101837|Clorhidrato de amorolfina|O|O||D||1
51101900|Medicamentos contra la malaria|O|O||D||1
51101901|Aminoquinolinas|O|O||D||1
51101902|Clorhidrato de mefloquina|O|O||D||1
51101903|Fosfato de primaquina|O|O||D||1
51101904|Sulfato de quinina|O|O||D||1
51101905|Cloroquina|O|O||D||1
51101906|Proguanil|O|O||D||1
51101907|Pirimetamina|O|O||D||1
51101908|Artemeter|O|O||D||1
51101909|Clorhidrato de cloroquina|O|O||D||1
51101910|Fosfato de cloroquina|O|O||D||1
51101911|Clorhidrato de halofantrina|O|O||D||1
51101912|Sulfato de hidroxicloroquina|O|O||D||1
51101913|Dihidrocloruro amodiaquina|O|O||D||1
51101914|Artesunato de sodio|O|O||D||1|Artesunato Sódico
51101915|Lumefantrina o benflumetol|O|O||D||1|Benfumetol, Lumefantrina
51102000|Medicamentos antituberculosos|O|O||D||1
51102001|Cicloserina|O|O||D||1
51102002|Clorhidrato de etambutol|O|O||D||1
51102003|Isoniazida|O|O||D||1|Isoniacida
51102004|Rifubutina|O|O||D||1|Rifabutina
51102005|Rifampicina|O|O||D||1
51102006|Guayacol|O|O||D||1|Guaiacol
51102007|Tiacetazona|O|O||D||1
51102008|Pirazinamida|O|O||D||1
51102009|Sulfato de capreomicina|O|O||D||1
51102010|Rifabutina|O|O||D||1
51102100|Leprostáticos|O|O||D||1
51102101|Clofazimina|O|O||D||1
51102102|Dapsona|O|O||D||1
51102200|Antiinfecciosos y analgésicos urinarios|O|O||D||1
51102201|Cinoxacina|O|O||D||1
51102202|Clorhidrato de flavoxato|O|O||D||1
51102203|Hipurato de metenamina|O|O||D||1
51102204|Mandelato de metenamina|O|O||D||1
51102205|Ácido nalidíxico|O|O||D||1
51102206|Nitrofurantoina|O|O||D||1
51102207|Cloruro de oxibutinina|O|O||D||1
51102208|Pentosano polisulfato sódico|O|O||D||1
51102209|Clorhidrato de fenazopiridina|O|O||D||1
51102211|Alfuzosina hidrocloruro|O|O||D||1|Clorhidrato de Alfuzosina, Hidrocloruro de Alfuzosina
51102212|Ácido acetohidroxámico|O|O||D||1
51102213|Sulfato  de cefpiroma|O|O||D||1
51102214|Fenazopiridina|O|O||D||1
51102300|Medicamentos antivirales|O|O||D||1
51102301|Aciclovir|O|O||D||1
51102302|Clorhidrato de amantadina|O|O||D||1
51102304|Didanosina|O|O||D||1|DDL
51102305|Famciclovir|O|O||D||1
51102306|Foscarnet sódico|O|O||D||1|Foscavir
51102307|Ganciclovir sódico|O|O||D||1|Cytovene IV, Ganciclovir, Glanicicovir Sódic
51102308|Idoxuridina|O|O||D||1
51102309|Sulfato de indinavir|O|O||D||1|Indinavir
51102310|Lamivudina|O|O||D||1
51102311|Nevirapina|O|O||D||1|Viramune
51102312|Ribavirina|O|O||D||1|Virazole
51102313|Clorhidrato de rimantadina|O|O||D||1
51102314|Ritonavir|O|O||D||1
51102315|Mesilato de saquinavir|O|O||D||1|SQV
51102316|Estavidina|O|O||D||1|D4T
51102317|Trifluradina|O|O||D||1
51102318|Clorhidrato de valaciclovir|O|O||D||1|HCI de valaciclovir, Valtrex
51102319|Vidarabina|O|O||D||1
51102320|Zalcitabina|O|O||D||1
51102321|Zidovudina|O|O||D||1|AZT, Azidotimidina
51102322|Sulfato de abacavir|O|O||D||1
51102323|Cidofovir|O|O||D||1
51102324|Mesilato de delavirdina|O|O||D||1
51102325|Docosanol|O|O||D||1
51102326|Efavirenz|O|O||D||1
51102327|Amprenavir|O|O||D||1
51102328|Fomivirsen sódico|O|O||D||1
51102329|Mesilato de nelfinavir|O|O||D||1|NFV
51102330|Penciclovir|O|O||D||1
51102331|Saquinavir|O|O||D||1
51102332|Fumarato de disoproxilo tenofovir|O|O||D||1|TDF, Tenofovir
51102333|Hidrocloruro de valganciclovir|O|O||D||1|Clorhidrato de valganciclovir, HCI de valganciclovir, Valganciclovi
51102334|Zanamivir|O|O||D||1
51102335|Sodio de aciclovir|O|O||D||1|Aciclovir, Aciclovir sódico, Zovira
51102336|Moroxidina|O|O||D||1
51102337|Adefovir dipivoxil|O|O||D||1
51102338|Oseltamivir|O|O||D||1
51102339|Ganciclovir|O|O||D||1
51102340|Estavudina|O|O||D||1
51102341|Valaciclovir|O|O||D||1
51102342|Valganciclovir|O|O||D||1
51102343|Estavudina, lamivudina y nevirapina|O|O||D||1
51102344|Lamivudine and  zidovudine|O|O||D||1|Lamivudina y zidovudina
51102345|Lopinavir y ritonavir|O|O||D||1
51102346|Zidovudina, neviparina and lamivudina|O|O||D||1|Zidovudina, nevirapina y lamivudina
51102400|Oftálmico|O|O||D||1
51102402|Hipromelosa|O|O||D||1|Hidroxipropilmetilcelulos
51102403|Sulfacetamida|O|O||D||1
51102500|Antihelmínticos veterinarios|O|O||D||1
51102501|Naftenato de cobre|O|O||D||1
51102502|Toltrazuril|O|O||D||1
51102503|Flumetrina|O|O||D||1
51102505|Triclorfon|O|O||D||1
51102506|Oxfendazol|O|O||D||1
51102507|Clorhidrato de piperidolato|O|O||D||1
51102600|Antibióticos veterinarios|O|O||D||1
51102601|Enrofloxacina|O|O||D||1
51102700|Antisépticos|O|O||D||1|Antimicrobianos
51102701|Clofoctol|O|O||D||1
51102702|Agua estéril para irrigación|O|O||D||1
51102705|Cetrimida|O|O||D||1
51102706|Ácido acético  antiséptico|O|O||D||1
51102707|Gluconato de clorhexidina|O|O||D||1
51102708|Formaldehído antiséptico|O|O||D||1
51102709|Peróxido de hidrógeno antiséptico|O|O||D||1|Agua oxigenada
51102710|Antisépticos basados en alcohol o acetona|O|O||D||1
51102711|Oxiquinolina|O|O||D||1
51102712|Antisépticos fenólicos|O|O||D||1
51102713|Povidona yodada|O|O||D||1|Polividona yodada, Povidona, Yodopolivinilpirrolidona
51102714|Solución de cloruro sódico para irrigación|O|O||D||1
51102715|Clioquinol|O|O||D||1
51102717|Nitrofurazona|O|O||D||1
51102718|Nitrato de plata|O|O||D||1
51102719|Yodoformo|O|O||D||1|Triyoduro de carbono, Triyoduro de metilo
51102720|Cloroxilenol|O|O||D||1|Cloro-dimetilfenol, Para-cloro-meta-xilenol
51102721|Ictamol|O|O||D||1
51102722|Geles o soluciones tópicas de yodo|O|O||D||1
51102723|Merbromina|O|O||D||1|Mercurocromo
51102724|Cloruro de benzalconio|O|O||D||1
51102725|Hexilresorcinol|O|O||D||1
51102726|Peróxido de carbamida|O|O||D||1|Peróxido de urea
51102727|Yoduro de timol|O|O||D||1
51102728|Perborato sódico|O|O||D||1
51102729|Cloruro de cetilpiridinio|O|O||D||1
51102730|Isetionato de hexamidina|O|O||D||1
51111500|Agentes Alquilante|O|O||D||1|Agentes contra el cáncer
51111501|Amifostina|O|O||D||1|Amifostine, Ethyol
51111502|Busulfán|O|O||D||1
51111503|Carboplatino|O|O||D||1
51111504|Carmustina|O|O||D||1
51111505|Clorambucil|O|O||D||1|Clorambucilo
51111506|Cisplatino|O|O||D||1|Cis-diaminodicloroplatino
51111507|Ciclofosfamida|O|O||D||1|Citofosfana, Citoxan, Endoxan, Genuxal, Neosar
51111508|Dacarbazina|O|O||D||1|Dacarbacina
51111509|Ifosfamida|O|O||D||1
51111510|Lomustina|O|O||D||1
51111511|Clorhidrato de mecloretamina|O|O||D||1|Clorhidrato de mecloretamina, Clormetina, Mecloretamin
51111512|Melfalán|O|O||D||1
51111513|Mesna|O|O||D||1
51111514|Pipobroman|O|O||D||1
51111515|Estreptozocina|O|O||D||1
51111516|Tiotepa|O|O||D||1|TESPA, Thiophosphoamide, Tiotep
51111517|Mostaza de uracilo|O|O||D||1
51111518|Clorhidrato de melfalan|O|O||D||1
51111519|Temozolomida|O|O||D||1
51111520|Clorhidrato de procarbazina|O|O||D||1
51111521|Altretamina|O|O||D||1
51111522|Ceftriaxona sódica|O|O||D||1
51111600|Antimetabolitos|O|O||D||1
51111601|Cladribina|O|O||D||1|2-Clorodeoxiadenosina, Cladribina
51111602|Citarabina|O|O||D||1|Arabinosilcitosina, Citarabina
51111603|Floxuridina|O|O||D||1
51111604|Fosfato de fludarabina|O|O||D||1|Fludarabina, Fludarabín fosfato
51111605|Fluorouracilo|O|O||D||1
51111606|Hidroxiurea|O|O||D||1
51111609|Mercaptopurina|O|O||D||1|6-mercaptopurina, Mercaptopurina
51111610|Metotrexato|O|O||D||1|MTX
51111611|Tenipósido|O|O||D||1
51111612|Tioguanina|O|O||D||1|2-amino-6-mercaptopurina, 6-Tioguanina
51111613|Lenograstim|O|O||D||1
51111614|Etopósido|O|O||D||1|VP-16
51111615|Glutatión|O|O||D||1
51111616|Capecitabina|O|O||D||1
51111617|Clorhidrato de gemcitabina|O|O||D||1
51111618|Metotrexato de sodio|O|O||D||1|Ametopterina
51111700|Antibióticos antineoplásicos|O|O||D||1|Agentes antitumorales
51111701|Sulfato de bleomicina|O|O||D||1|Blenoxane
51111702|Dactinomicina|O|O||D||1|Actinomicina-D
51111703|Daunorubicinas|O|O||D||1|Daunomicina, Deunorrubicina
51111704|Mitomicina|O|O||D||1
51111705|Mitotano|O|O||D||1
51111706|Clorhidrato de mitoxantrona|O|O||D||1
51111707|Pentostatina|O|O||D||1|Desoxicoformicina, Pentostatina
51111708|Plicamicina|O|O||D||1|Mitramicina, Mitrhacin
51111709|Sulfato de vincristina|O|O||D||1
51111710|Epirubicina|O|O||D||1
51111711|Clorhidrato de doxorubicina|O|O||D||1
51111712|Pirarubicina|O|O||D||1
51111713|Alemtuzumab|O|O||D||1
51111714|Clorhidrato de doxorrubicina liposomal|O|O||D||1
51111715|Epirubicina hidrocloruro|O|O||D||1|Epirubicina
51111716|Rituximab|O|O||D||1
51111717|Trastuzumab|O|O||D||1
51111718|Valrubicina|O|O||D||1
51111719|Clorhidrato de idarrubicina|O|O||D||1
51111720|Infliximab|O|O||D||1
51111721|Ibritumomab tiuxetan|O|O||D||1
51111722|Imatinib|O|O||D||1
51111723|Leuprorelina|O|O||D||1
51111800|Hormonas y antihormonas|O|O||D||1
51111801|Anastrozol|O|O||D||1|Arimidex
51111802|Bicalutamida|O|O||D||1
51111803|Fosfato sódico de estramustina|O|O||D||1|Estramusitina
51111804|Flutamida|O|O||D||1
51111805|Acetato de goserelina|O|O||D||1
51111806|Clorhidrato de irinotecan|O|O||D||1
51111807|Acetato de leuprolide|O|O||D||1|Eligard, Lupron, Viadu
51111808|Nilutamida|O|O||D||1
51111809|Tamoxifeno|O|O||D||1
51111810|Testolactona|O|O||D||1
51111811|Clorhidrato de topotecan|O|O||D||1|Topotecán
51111812|Sulfato de vinblastina|O|O||D||1|Velban, Velsar
51111813|Sulfato de vincristina|O|O||D||1|Vincristina
51111814|Tartrato de vinorelbina|O|O||D||1|Navelbina
51111815|Triptorelina|O|O||D||1
51111816|Buserelina|O|O||D||1
51111817|Citrato de toremifeno|O|O||D||1
51111818|Pamoato de triptorelina|O|O||D||1
51111819|Fulvestrant|O|O||D||1|Faslodex, Fulvestrant
51111820|Letrozol|O|O||D||1|Femara
51111821|Citrato de tamoxifeno|O|O||D||1|Tamoxifeno
51111822|Oxaliplatino|O|O||D||1
51111823|Ácido pamidrónico|O|O||D||1
51111824|Exemestano|O|O||D||1|Aromasin
51111825|Erlotinib|O|O||D||1|Terceva
51111826|Mesilato de  gefitinib|O|O||D||1
51111827|Tibolona|O|O||D||1
51111828|Ciproterona|O|O||D||1
51111900|Productos antitumorales naturales|O|O||D||1
51111901|Asparaginasa|O|O||D||1|Erwinia L-asparaguinasa, L-asparaguinasa
51111902|Docetaxel|O|O||D||1|Taxotere
51111904|Paclitaxel|O|O||D||1|Onxal, Paclitaxel, Taxo
51111905|Porfímero sódico|O|O||D||1|Photofrin
51111906|Pegaspargasa|O|O||D||1|Oncaspar, PEG-L-asparaginasa
51111907|Fenilbutirato de sodio|O|O||D||1
51121500|Agentes antiarritmia|O|O||D||1|Agentes para el ritmo cardiaco
51121501|Adenosina|O|O||D||1
51121502|Digoxina|O|O||D||1
51121503|Gluconato de quinidina|O|O||D||1
51121504|Flecainida|O|O||D||1
51121506|Clorhidrato de sotalol|O|O||D||1
51121507|Clorhidrato de hidroquinidina|O|O||D||1
51121509|Propafenona|O|O||D||1
51121510|Disopiramida|O|O||D||1
51121511|Clorhidrato de amiodarona|O|O||D||1
51121512|Tosilato de bretilio|O|O||D||1
51121513|Fosfato de disopiramida|O|O||D||1
51121514|Dofetilida|O|O||D||1
51121515|Acetato de flecainida|O|O||D||1
51121516|Ibutilida fumarato|O|O||D||1
51121517|Clorhidrato de mexiletina|O|O||D||1
51121518|Clorhidrato de moricizina|O|O||D||1
51121519|Clorhidrato de procainamida|O|O||D||1
51121520|Clorhidrato de propafenona|O|O||D||1
51121521|Quinidina poligalacturonato|O|O||D||1
51121522|Clorhidrato de tocainida|O|O||D||1
51121523|Sulfato de quinidina|O|O||D||1
51121600|Medicamentos antiangina|O|O||D||1
51121601|Nitrato de amilo|O|O||D||1
51121602|Dinitrato de isosorbida|O|O||D||1
51121603|Nitroglicerina|O|O||D||1|Trinitoglicerina, Trinitrato de glicerito
51121604|Tetranitrato de pentaeritrito|O|O||D||1|Pentrita
51121607|Nicorandi|O|O||D||1
51121608|Clorhidrato de nicardipina|O|O||D||1
51121609|Molsidomina|O|O||D||1
51121610|Pralidoxima|O|O||D||1
51121611|Trimetazidina|O|O||D||1|Idaptan
51121614|Mononitrato de isosorbida|O|O||D||1
51121615|Clorhidrato de bepridil|O|O||D||1
51121616|Clorhidrato de isoxsuprina|O|O||D||1
51121617|Ranolazina|O|O||D||1
51121700|Medicamentos antihipertensivos|O|O||D||1
51121701|Diazóxido|O|O||D||1|Proglycem
51121702|Terazosina|O|O||D||1
51121703|Captopril|O|O||D||1
51121704|Lisinopril|O|O||D||1
51121705|Felodipino|O|O||D||1
51121706|Isradipina|O|O||D||1
51121707|Verapamilo|O|O||D||1
51121708|Metildopa|O|O||D||1|Alfametildopa
51121709|Carvedilol|O|O||D||1
51121710|Losartán potásico|O|O||D||1
51121711|Minoxidil|O|O||D||1
51121713|Clorhidrato de diltiazem|O|O||D||1
51121714|Vincamina|O|O||D||1
51121715|Enalapril|O|O||D||1
51121716|Piretanida|O|O||D||1
51121717|Mesilato de eprosartán|O|O||D||1
51121718|Clorhidrato de clonidina|O|O||D||1
51121721|Tartrato de metoprolol|O|O||D||1
51121722|Reserpina|O|O||D||1
51121724|Naftidrofurilo oxalato|O|O||D||1|Nafronil, Nafronil oxalato
51121725|Bisoprolol fumarato|O|O||D||1
51121726|Indapamida|O|O||D||1
51121727|Penbutolol|O|O||D||1
51121728|Prazosina|O|O||D||1|Hypovase, Minipress, Pressin, Vasoflex ,
51121729|Celiprolol|O|O||D||1
51121730|Ramipril|O|O||D||1
51121731|Trandolapril|O|O||D||1
51121732|Combinación de trandolapril y clorhidrato de verapamilo|O|O||D||1|Tarka (nombre comercial de las capsulas)
51121733|Valsartán|O|O||D||1
51121734|Nicotinato de xantinol|O|O||D||1|Niacinato de xantinol
51121735|Candesartán cilexetilo|O|O||D||1
51121737|Clorhidrato de benazepril|O|O||D||1|Benazepril, Lotensin
51121738|Deserpidina|O|O||D||1
51121739|Clorhidrato de verapamilo|O|O||D||1
51121740|Nisoldipino|O|O||D||1
51121741|Diclorhidrato de mibefradil|O|O||D||1
51121742|Diltiazem malato|O|O||D||1
51121743|Besilato de amlodipina|O|O||D||1|Norvac (nombre comercial)
51121744|Maleato de enalpril|O|O||D||1
51121745|Dihidrato de enalaprilato|O|O||D||1
51121746|Mesilato de fenoldopam|O|O||D||1
51121747|Fosinopril sódico|O|O||D||1
51121748|Acetato de guanabenz|O|O||D||1
51121749|Sulfato de guanadrel|O|O||D||1
51121750|Sulfato de guanetidina|O|O||D||1
51121751|Clorhidrato de guanfacina|O|O||D||1
51121752|Hidralazina hidrocloruro|O|O||D||1
51121753|Irbesartán|O|O||D||1
51121754|Clorhidrato de mecamilamina|O|O||D||1
51121755|Clorhidrato de metildopato|O|O||D||1|Alfametildopa
51121756|Metirosina|O|O||D||1|AMPT, a-Metiltirosina
51121757|Clorhidrato de moexipril|O|O||D||1
51121758|Nitroprusiato de sodio|O|O||D||1
51121759|Olmesartán medoxomilo|O|O||D||1
51121760|Perindopril erbumina|O|O||D||1
51121761|Clorhidrato de quinapril|O|O||D||1
51121762|Rauwolfia serpentina|O|O||D||1|Reserpina
51121763|Telmisartán|O|O||D||1
51121764|Quinapril|O|O||D||1
51121765|Metoprolol|O|O||D||1
51121766|Atomoxetina|O|O||D||1
51121767|Nebivolol|O|O||D||1
51121768|Benazepril|O|O||D||1
51121769|Perindopril|O|O||D||1
51121770|Cilazapril|O|O||D||1
51121771|Fosinopril|O|O||D||1
51121772|Gugulsterona|O|O||D||1
51121773|Clorhidrato de lercanidipina|O|O||D||1
51121774|Levosimendán|O|O||D||1|Simdax
51121775|Tirofibán|O|O||D||1
51121777|Trimetazidina  dihidrocloruro|O|O||D||1
51121778|Rilmenidina|O|O||D||1|Dorzolamida, Timol
51121779|Clevidipina|O|O||D||1|Cleviprex
51121780|Losartán|O|O||D||1|Cozaar
51121800|Agentes antihiperlipidémicos/hipocolesterolémicos|O|O||D||1|Agentes para el colesterol (grasa en la sangre)
51121801|Fluvastatina sódica|O|O||D||1
51121802|Lovastatina|O|O||D||1
51121803|Simvastatina|O|O||D||1
51121804|Clofibrato|O|O||D||1
51121805|Gemfibrozilo|O|O||D||1
51121806|Pravastatina de sodio|O|O||D||1
51121807|Polidocanol|O|O||D||1|Aethoxisclerol
51121808|Probucol|O|O||D||1
51121809|Fenofibrato|O|O||D||1
51121810|Atorvastatina de calcio|O|O||D||1
51121811|Cerivastatina sódica|O|O||D||1
51121812|Colina|O|O||D||1
51121813|Bitartrato de colina|O|O||D||1
51121814|Inositol|O|O||D||1
51121815|Racemetionina|O|O||D||1
51121816|Fosfatidilcolina|O|O||D||1|Lecitina, Polienilfosfatidilcolina
51121817|Colestiramina|O|O||D||1
51121818|Atorvastatina|O|O||D||1
51121819|Ezetimiba|O|O||D||1
51121820|Sulfato de condroitina a|O|O||D||1|Condroitín sulfato
51121821|Pravastatina|O|O||D||1
51121822|Mevastatina|O|O||D||1
51121823|Rosuvastatina|O|O||D||1
51121900|Medicamentos usados para insuficiencia cardíaca congestiva|O|O||D||1
51121901|Lactato de inamrinona|O|O||D||1
51121902|Lactato de milrinona|O|O||D||1
51121903|Digitoxina|O|O||D||1|Digitalin, Digitofilina
51121904|Nifedipina|O|O||D||1
51121905|Enoximona|O|O||D||1
51121906|Betaína|O|O||D||1|Trimetilglicina
51121907|Nesiritida|O|O||D||1
51121908|Hoja de digital en polvo o preparados|O|O||D||1
51121909|Eplerenona|O|O||D||1
51121910|Lanatosido c|O|O||D||1|Isolánido
51122100|Vasodilatadores|O|O||D||1
51122101|Mesilato de dihidroergocristina|O|O||D||1
51122102|Clorhidrato de buflomedil|O|O||D||1
51122103|Clorhidrato de linsidomina|O|O||D||1
51122104|Papaverina|O|O||D||1
51122105|Pentifilina|O|O||D||1|Oxipentafilina, Vazofilina
51122107|Tartrato de ifenprodil|O|O||D||1
51122108|Mesilatos ergoloides|O|O||D||1|Co-dergocrina mesilato, Dihidroergotoxina
51122109|Clorhidrato de papaverina|O|O||D||1
51122110|Nimodipina|O|O||D||1|Nimodipino
51122111|Nitrito de amilo|O|O||D||1
51122112|Alprostadil|O|O||D||1|Caveryect, Muse, Prolisin
51122113|Ácido nicotínico|O|O||D||1|Niacina, Vitamina B3, Vitamina P
51122200|Fármacos contra la hipotensión|O|O||D||1
51122201|Ornipresina|O|O||D||1
51122300|Agentes cardiopléjicos|O|O||D||1
51122301|Solución de cardioplejia|O|O||D||1
51131500|Medicamentos antianémicos|O|O||D||1
51131501|Fumarato ferroso|O|O||D||1
51131502|Gluconato ferroso|O|O||D||1
51131503|Sulfato ferroso|O|O||D||1|Sulfato de hierro (II)
51131504|Pidolato de magnesio|O|O||D||1
51131505|Oximetolona|O|O||D||1|Anadrol
51131506|Eritropoyetina|O|O||D||1
51131507|Darbepoetina alfa|O|O||D||1
51131508|Epoetina alfa|O|O||D||1
51131509|Citrato de amonio férrico|O|O||D||1
51131510|Polipéptido de hierro heme|O|O||D||1|Polipéptido hierro hemo
51131511|Hierro polisacárido|O|O||D||1|Polisacárido de hierro
51131512|Pirofosfato férrico|O|O||D||1
51131513|Cacodilato ferroso|O|O||D||1
51131514|Carbonilo de hierro|O|O||D||1|Hierro pentacarbonilo, Pentacarbonilo de hierro
51131515|Hemina o hematina|O|O||D||1
51131516|Hierro sacarosa|O|O||D||1
51131517|Ácido fólico|O|O||D||1|Folacina, Vitamina B9, Ácido pteroil-L-glutámic
51131518|Sulfato ferroso y ácido fólico|O|O||D||1
51131600|Anticoagulantes|O|O||D||1
51131601|Aprotinina|O|O||D||1
51131602|Heparina de calcio|O|O||D||1
51131603|Heparina sódica|O|O||D||1
51131604|Warfarina sódica|O|O||D||1
51131605|Citrato de sodio|O|O||D||1
51131606|Apolato de sodio|O|O||D||1
51131607|Enoxaparina sódica|O|O||D||1
51131608|Lepirudina|O|O||D||1
51131609|Desirudina|O|O||D||1
51131610|Ardeparina de sodio|O|O||D||1
51131611|Dalteparina sódica|O|O||D||1
51131612|Danaparoide sódico|O|O||D||1
51131613|Dicumarol|O|O||D||1
51131614|Anisindiona|O|O||D||1
51131615|Fondaparinux sódico|O|O||D||1
51131616|Tinzaparina sódica|O|O||D||1
51131617|Solución  anticoagulante citrato fosfato dextrosa|O|O||D||1
51131700|Trombolíticos/inhibidores de agregación de plaquetas|O|O||D||1
51131701|Abciximab|O|O||D||1
51131702|Alteplasa|O|O||D||1
51131703|Estreptoquinasa|O|O||D||1
51131704|Uroquinasa|O|O||D||1|Activador del plasminógeno tipo uroquinasa
51131705|Dipiridamol|O|O||D||1|Persantin
51131706|Argatroban|O|O||D||1
51131707|Bivalirudina|O|O||D||1
51131708|Cilostazol|O|O||D||1
51131709|Bisulfato de clopidogrel|O|O||D||1
51131710|Eptifibatida|O|O||D||1
51131711|Tenecteplasa|O|O||D||1
51131712|Clorhidrato de ticlopidina|O|O||D||1
51131713|Monohidrato hidrocloruro  tirofibán|O|O||D||1|Clorhidrato de tirofibán monohidratado
51131714|Anistreplasa|O|O||D||1
51131715|Clorhidrato de anagrelida|O|O||D||1
51131716|Reteplasa|O|O||D||1
51131800|Agentes hemostáticos sistémicos y coagulantes|O|O||D||1
51131801|Fibrinógeno|O|O||D||1
51131802|Factores antihemofílicos o globulinas|O|O||D||1
51131803|Trombina|O|O||D||1
51131804|Oprelvekina|O|O||D||1
51131805|Etamsilato|O|O||D||1
51131806|Subsulfato férrico|O|O||D||1
51131807|Morruato de sodio|O|O||D||1
51131808|Ácido aminocaproico|O|O||D||1
51131809|Dobesilato de calcio|O|O||D||1
51131810|Parche hemostático|O|O||D||1
51131811|Ácido tranexámico|O|O||D||1
51131900|Sustitutos de plasma sanguíneo y extensores y expansores|O|O||D||1
51131901|Poligelina|O|O||D||1
51131903|Gelatina|O|O||D||1
51131904|Plasma sanguíneo humano|O|O||D||1
51131905|Dextrano|O|O||D||1
51131906|Pentastarch|O|O||D||1
51131907|Fracción de proteína de plasma humano|O|O||D||1
51131908|Hetastarch|O|O||D||1
51131909|Albúmina humana|O|O||D||1
51131910|Polividona o povidona|O|O||D||1|Iodopovidona, Polividona yodada, Yodopolivinilpirrolidona
51132000|Agentes hemorreológicos|O|O||D||1
51132001|Pentoxifilina|O|O||D||1
51141500|Anticonvulsivos|O|O||D||1|Antiepilépticos
51141501|Acetazolamida|O|O||D||1
51141502|Clonazepam|O|O||D||1
51141503|Felbamato|O|O||D||1
51141504|Lamotrigina|O|O||D||1
51141505|Fenobarbital|O|O||D||1|Fenobarbitona
51141506|Fenobarbital sódico|O|O||D||1
51141507|Fenitoína|O|O||D||1|Difenilhidantoína
51141508|Etosuximida|O|O||D||1
51141509|Vigabatrina|O|O||D||1
51141510|Barbexaclona|O|O||D||1
51141511|Urbanyl|O|O||D||1
51141512|Clobazam|O|O||D||1
51141513|Carbamazepina|O|O||D||1
51141514|Zonisamida|O|O||D||1
51141515|Etotoína|O|O||D||1
51141516|Fosfenitoína sódica|O|O||D||1
51141517|Gabapentina|O|O||D||1
51141518|Levetiracetam|O|O||D||1
51141519|Mefenitoina|O|O||D||1
51141520|Mefobarbital|O|O||D||1|Mebaral
51141521|Metsuximida|O|O||D||1
51141522|Oxcarbazepina|O|O||D||1
51141523|Parametadiona|O|O||D||1
51141524|Fenacemida|O|O||D||1
51141525|Fenitoína sódica|O|O||D||1
51141526|Primidona|O|O||D||1
51141527|Clorhidrato de tiagabina|O|O||D||1
51141528|Topiramato|O|O||D||1
51141529|Trimetadiona|O|O||D||1
51141530|Valproato de sodio|O|O||D||1|Valproato sódico
51141531|Ácido valproico|O|O||D||1|Valproato de magnesio
51141532|Acetazolamida sódica|O|O||D||1
51141533|Divalproex sódico|O|O||D||1
51141534|Pregabalina|O|O||D||1
51141535|Cabergolina|O|O||D||1
51141536|Citalopram|O|O||D||1
51141537|Clorazepato|O|O||D||1
51141538|Donepezilo|O|O||D||1|Aricep
51141539|Duloxetina|O|O||D||1
51141541|Memantina|O|O||D||1
51141542|Midazolam|O|O||D||1
51141543|Ziprasidona|O|O||D||1
51141600|Antidepresivos|O|O||D||1
51141601|Amitriptilina|O|O||D||1
51141602|Clorhidrato de doxepina|O|O||D||1
51141603|Pamoato de imipramina|O|O||D||1
51141604|Mirtazapina|O|O||D||1
51141605|Hidrocloruro de paroxetina|O|O||D||1
51141606|Clorhidrato de trazodona|O|O||D||1
51141607|Maleato de fluvoxamina|O|O||D||1
51141608|Amitriptilinoxida|O|O||D||1
51141609|Sulfato de tranilcipromina|O|O||D||1
51141610|Clorhidrato de desipramina|O|O||D||1
51141611|Trimipramina mesilato|O|O||D||1
51141612|Sibutramina|O|O||D||1|Reductil
51141613|Clorhidrato de carpipramine|O|O||D||1
51141614|Clomipramina|O|O||D||1
51141615|Trimipramina|O|O||D||1
51141616|Clorhidrato de clomipramina|O|O||D||1
51141617|Bromhidrato de citalopram|O|O||D||1
51141618|Clorhidrato de fluoxetina|O|O||D||1|Prozac
51141619|Hidrocloruro de sertralina|O|O||D||1
51141620|Mosto de st'john|O|O||D||1|Corazoncillo, Hierba de San Juan, Hipericón, Hipérico ,
51141621|Clorhidrato de imipramina|O|O||D||1
51141622|Isocarboxazida|O|O||D||1|Marplan
51141623|Clorhidrato de caprotilina|O|O||D||1|Ludiomil
51141624|Clorhidrato de nefazodona|O|O||D||1
51141625|Clorhidrato de nortriptilina|O|O||D||1
51141626|Clorhidrato de protriptilina|O|O||D||1
51141627|Maleato de trimipramina|O|O||D||1
51141628|Nortriptilina|O|O||D||1
51141629|Amoxapina|O|O||D||1
51141630|Tiroides|O|O||D||1
51141631|Hidrocloruro de bupropión|O|O||D||1
51141632|Sulfato de fenelzina|O|O||D||1
51141633|Oxalato de escitalopram|O|O||D||1|Escitalopram
51141634|Aripiprazol|O|O||D||1
51141635|Clorhidrato de duloxetina|O|O||D||1
51141636|Venlafaxina hcl|O|O||D||1
51141637|Mirtazepina|O|O||D||1
51141638|Venlafaxina|O|O||D||1
51141639|Desvenlafaxina|O|O||D||1|O-desmetilvenlafaxina
51141640|Moclobemida|O|O||D||1|Aurorix
51141700|Agentes antipsicóticos|O|O||D||1
51141701|Fenotiazinas|O|O||D||1|Dibenzotiazina, Tiodifenilamina
51141702|Haloperidol|O|O||D||1
51141703|Olanzapina|O|O||D||1
51141704|Risperidona|O|O||D||1|Risperdal
51141705|Nicergolina|O|O||D||1|Sermion
51141706|Citicolina|O|O||D||1|Ceraxon, Somazina
51141707|Clorhidrato de buspirona|O|O||D||1
51141708|Clordiazepóxido|O|O||D||1
51141709|Flufenazina|O|O||D||1
51141710|Periciazina|O|O||D||1
51141711|Levomepromazina|O|O||D||1
51141712|Zotepina|O|O||D||1
51141713|Palmitato de pipotiazina|O|O||D||1
51141714|Piracetam|O|O||D||1
51141715|Clozapina|O|O||D||1
51141716|Decanoato de haloperidol|O|O||D||1
51141717|Lactato de haloperidol|O|O||D||1
51141718|Clorhidrato de loxapina|O|O||D||1
51141719|Succinato de loxapina|O|O||D||1
51141720|Clorhidrato de molindona|O|O||D||1
51141721|Pimozida|O|O||D||1
51141722|Fumarato de quetiapina|O|O||D||1|Quetidin
51141723|Tiotixeno|O|O||D||1
51141724|Clorhidrato de tiotixeno|O|O||D||1
51141725|Clorhidrato de ziprasidona|O|O||D||1
51141726|Clorhidrato de triflupromazina|O|O||D||1
51141727|Mesilato de ziprasidona|O|O||D||1
51141728|Droperidol|O|O||D||1|Dehidrobenzolperidol
51141729|Clorhidrato de tioridazina|O|O||D||1
51141730|Amisulprida|O|O||D||1
51141731|Modafinilo|O|O||D||1
51141732|Clorpromazina|O|O||D||1
51141800|Hipnóticos|O|O||D||1
51141801|Pentobarbital|O|O||D||1
51141802|Secobarbital sódico|O|O||D||1
51141803|Hidrato de cloral|O|O||D||1
51141804|Estazolam|O|O||D||1
51141805|Triazolam|O|O||D||1
51141806|Butobarbital|O|O||D||1
51141807|Flunitrazepam|O|O||D||1|Rofenol
51141808|Tartrato de zolpidem|O|O||D||1
51141809|Loprazolam mesilato|O|O||D||1
51141810|Zoplicona|O|O||D||1
51141811|Amobarbital sódico|O|O||D||1
51141812|Didrocloruro de dexmedetomidina|O|O||D||1
51141813|Etclorvinol|O|O||D||1|Placidyl
51141814|Clorhidrato de flurazepam|O|O||D||1
51141815|Glutetimida|O|O||D||1|Doriden
51141816|Paraldehído|O|O||D||1|Acetaldehído
51141817|Quazepam|O|O||D||1
51141818|Triptófano|O|O||D||1
51141819|Zaleplon|O|O||D||1
51141820|Pentobarbital sódico|O|O||D||1
51141821|Doxilamina succinato|O|O||D||1
51141822|Butabarbital|O|O||D||1
51141823|Eszopiclona|O|O||D||1
51141900|Tranquilizantes y fármacos ansiolíticos y antimaniacos|O|O||D||1
51141903|Carbonato de litio|O|O||D||1|Carbonato litítico
51141904|Citrato de litio|O|O||D||1
51141907|Sulpirida|O|O||D||1
51141908|Tiaprida|O|O||D||1
51141910|Bromazepam|O|O||D||1
51141911|Tofisopam|O|O||D||1
51141912|Hidrocloruro de chlordiazepoxide|O|O||D||1
51141913|Clormezanone|O|O||D||1
51141914|Clorazapato dipotásico|O|O||D||1
51141915|Halazepam|O|O||D||1
51141916|Lorazepam|O|O||D||1|Acetato de L-lorazepam
51141917|Oxazepam|O|O||D||1
51141918|Meprobamato|O|O||D||1
51141919|Alprazolam|O|O||D||1|Niravam, Xanax
51141920|Diazepam|O|O||D||1|Valium
51141921|Clorhidrato de midazoloam|O|O||D||1
51141922|Temazepam|O|O||D||1
51142000|Analgésicos no narcóticos/antipiréticos|O|O||D||1
51142001|Acetaminofén|O|O||D||1|Acetaminofeno, Paracetamol
51142002|Ácido acetilsalicílico|O|O||D||1|Aspirina
51142003|Mesalamina|O|O||D||1
51142004|Meprobromato|O|O||D||1
51142005|Butetisalicilato de metilo|O|O||D||1
51142006|Oxaceprol|O|O||D||1
51142009|Metamizol sódico|O|O||D||1
51142010|Acetanilida|O|O||D||1|Acetamidobenceno, Acetilaminobenceno
51142011|Salicilato de magnesio|O|O||D||1
51142012|Ácido mefenámico|O|O||D||1
51142013|Salicilamida|O|O||D||1|O-hidroxibenzamida
51142014|Tiosalicilato de sodio|O|O||D||1
51142015|Salicilato de trietanolamina|O|O||D||1
51142016|Solución de antipirina y benzocaína|O|O||D||1
51142017|Salsalato o ácido salicil salicílico|O|O||D||1
51142018|Inyección de alcohol deshidratado|O|O||D||1
51142100|Fármacos antiinflamatorios no esteroideos (NSAID)|O|O||D||1
51142101|Auranofin|O|O||D||1
51142102|Carpofen|O|O||D||1|Carprofeno
51142103|Diclofenaco potásico|O|O||D||1
51142104|Diclofenaco sódico|O|O||D||1
51142105|Flurbiprofeno|O|O||D||1
51142106|Ibuprofeno|O|O||D||1|Brufen
51142107|Indometacina|O|O||D||1
51142108|Ketoprofeno|O|O||D||1
51142109|Naproxeno|O|O||D||1
51142110|Naproxeno sódico|O|O||D||1
51142111|Oxaprozin|O|O||D||1
51142112|Sulindaco|O|O||D||1|Sulindac
51142113|Suprofeno|O|O||D||1
51142114|Clorhidrato de bencidamina|O|O||D||1
51142116|Salicilato de dietilamina|O|O||D||1
51142117|Dietilamina diclofenaco|O|O||D||1
51142118|Nimesulida|O|O||D||1
51142119|Benorilato|O|O||D||1
51142120|Serrapeptasa|O|O||D||1
51142121|Diclofenaco|O|O||D||1|Voltaren
51142122|Auriotomalato de sodio|O|O||D||1
51142123|Ketorolaco trometamol|O|O||D||1
51142124|Etodolac|O|O||D||1|Etodolaco
51142125|Etofenamato|O|O||D||1
51142126|Floctafenina|O|O||D||1
51142127|Emorfazona|O|O||D||1
51142128|Piroxicam|O|O||D||1
51142129|Ácido tiaprofénico|O|O||D||1
51142130|Leflunomida|O|O||D||1
51142131|Celecoxib|O|O||D||1|Celebrex
51142132|Aurotioglucosa|O|O||D||1
51142133|Bromfenac sódico|O|O||D||1
51142134|Salicilato de colina|O|O||D||1
51142135|Fenoprofen cálcico|O|O||D||1
51142136|Flurbiprofen sódico|O|O||D||1
51142137|Indometacina trihidrato sódica|O|O||D||1
51142138|Ketorolac trometamina|O|O||D||1
51142139|Meclofenamato sódico|O|O||D||1
51142140|Meloxicam|O|O||D||1|Mobic
51142141|Nabumetona|O|O||D||1
51142142|Rofecoxib|O|O||D||1
51142143|Tolmetin sódico|O|O||D||1
51142144|Valdecoxib|O|O||D||1
51142145|Adalimumab|O|O||D||1
51142146|Diflunisal|O|O||D||1
51142147|Anakinra|O|O||D||1|Kineret
51142148|Hialuronato de sodio|O|O||D||1
51142149|Glucosamina|O|O||D||1
51142150|Acamprosato calcio|O|O||D||1|Acetil homotaurinato de calcio
51142151|Aceclofenaco|O|O||D||1
51142152|Deracoxib|O|O||D||1
51142153|Etoricoxib|O|O||D||1|Arcoxia
51142154|Lumiracoxib|O|O||D||1
51142155|Clonixinato lisina|O|O||D||1
51142200|Analgésicos narcóticos|O|O||D||1
51142201|Butorfanol tartrato|O|O||D||1
51142202|Fosfato codeina|O|O||D||1
51142203|Sulfato codeina|O|O||D||1
51142205|Clorhidrato meperidina|O|O||D||1
51142206|Sulfato de morfina|O|O||D||1|Roxanol
51142207|Oxicodona|O|O||D||1
51142208|Citrato sufentanilo|O|O||D||1
51142209|Clorhidrato nefopam|O|O||D||1
51142210|Clorhidrato etilmorfina|O|O||D||1
51142211|Hidrocodona|O|O||D||1
51142212|Dihidrocodeina resinato|O|O||D||1
51142213|Napsilato de propoxifeno|O|O||D||1
51142214|Clorhidrato de alfentanil|O|O||D||1
51142215|Hidrocloruro de buprenorfina|O|O||D||1
51142216|Dezocina|O|O||D||1
51142217|Dihidrocodéina tartrato|O|O||D||1
51142218|Dihidrocodéina|O|O||D||1
51142219|Fentanilo|O|O||D||1
51142220|Citrato de fentanilo|O|O||D||1
51142221|Bitartrato de hidrocodona|O|O||D||1
51142222|Hidrocloruro de hidromorfona|O|O||D||1
51142223|Polistirex de hidrocodona|O|O||D||1
51142224|Clorhidrato de acetato de levometadil|O|O||D||1
51142225|Tartrato de levorfanol|O|O||D||1
51142226|Clorhidrato de metadona|O|O||D||1
51142227|Clorhidrato de oxicodona|O|O||D||1
51142228|Clorhidrato de oximorfona|O|O||D||1
51142229|Clorhidrato de pentazocina|O|O||D||1
51142230|Lactato de pentazocina|O|O||D||1
51142231|Clorhidrato de propoxifeno|O|O||D||1
51142232|Clorhidrato de remifentanilo|O|O||D||1
51142233|Codeína|O|O||D||1|Metilmorfina
51142234|Bitartrato de dihidrocodeína|O|O||D||1
51142235|Clorhidrato de tramadol|O|O||D||1
51142237|Dextropropoxifeno|O|O||D||1
51142300|Antagonistas narcóticos|O|O||D||1
51142301|Clorhidrato de nalmefeno|O|O||D||1
51142302|Hidrocloruro de naloxona|O|O||D||1
51142303|Naltrexona|O|O||D||1|Naltraxona
51142304|Clorhidrato de nalbufina|O|O||D||1
51142305|Roxatidina|O|O||D||1
51142306|Clorhidrato de atipamezol|O|O||D||1
51142400|Medicamentos para dolores de cabeza vasculares y migraña|O|O||D||1
51142401|Maleato de metisergida|O|O||D||1
51142402|Succinato de sumatriptán|O|O||D||1
51142403|Tartrato de ergotamina|O|O||D||1
51142404|Dihidroergotamina|O|O||D||1
51142405|Combinación de ácido acetilsalicílico paracetamol|O|O||D||1
51142406|Almotriptán malato|O|O||D||1
51142407|Mesilato de dihidroergotamina|O|O||D||1
51142408|Succinato de frovatriptan|O|O||D||1
51142409|Isometepteno|O|O||D||1
51142410|Naratriptán hidrocloruro|O|O||D||1
51142411|Benzoato de rizatriptán|O|O||D||1
51142412|Bromhidrato de eletriptan|O|O||D||1
51142413|Zolmitriptán|O|O||D||1
51142414|Sumatriptán|O|O||D||1
51142415|Combinación de acetaminofén butalbital|O|O||D||1
51142500|Medicamentos contra el Parkinson|O|O||D||1
51142501|Mesilato de bromocriptina|O|O||D||1
51142502|Carbidopa|O|O||D||1
51142503|Levodopa|O|O||D||1
51142504|Clorhidrato de selegilina|O|O||D||1
51142505|Biperideno|O|O||D||1
51142506|Clorhidrato de biperideno|O|O||D||1
51142507|Mesilato de pergolida|O|O||D||1
51142508|Dihidrocloruro de pramipexol|O|O||D||1
51142509|Clorhidrato de ropinirol|O|O||D||1
51142510|Tolcapone|O|O||D||1
51142511|Entacapona|O|O||D||1
51142512|Tropacine|O|O||D||1
51142513|Rasagilina|O|O||D||1|Azilect
51142514|Levodopa y carbidopa|O|O||D||1
51142600|Estimulantes/anoréxicos|O|O||D||1
51142601|Sulfato de anfetamina|O|O||D||1|Anfetamina
51142602|Fenfluramina|O|O||D||1
51142603|Mazindol|O|O||D||1
51142604|Pemolina|O|O||D||1
51142605|Tartrato de fendimetrazina|O|O||D||1
51142606|Clorhidrato de pipradol|O|O||D||1
51142607|Fenproporex|O|O||D||1
51142608|Trimetilxantina|O|O||D||1
51142609|Clorhidrato de anfepramona|O|O||D||1|Dietilpropion
51142610|Cafeína|O|O||D||1|Guaranina, Mateína, Teín
51142611|Clorhidrato de dexfenfluramina|O|O||D||1
51142612|Clorhidrato de dietilpropión|O|O||D||1
51142613|Clorhidrato de fenfluramina|O|O||D||1
51142614|Clorhidrato de benzfetamina|O|O||D||1
51142615|Clorhidrato de  fentermina|O|O||D||1
51142616|Fentermina de resina|O|O||D||1
51142617|Clorhidrato de sibutramina monohidratada|O|O||D||1
51142618|Clorhidrato de metilfenidato|O|O||D||1
51142619|Espíritu aromático de amoníaco|O|O||D||1
51142700|Fármacos antiinflamatorios no esteroideos veterinarios (VNSAID)|O|O||D||1
51142701|Fenilbutazona|O|O||D||1
51142702|Ácido meclofenámico|O|O||D||1
51142800|Fármacos de tratamiento de la esclerosis lateral amiotrófica (ELA)|O|O||D||1
51142801|Riluzol|O|O||D||1
51142900|Fármacos anestésicos, complementos relacionados y analépticos|O|O||D||1
51142901|Cloroformo|O|O||D||1|Triclorometano, Tricloruro de metilo
51142902|Mezcla eutéctica de anestésicos locales|O|O||D||1
51142903|Ropivacaína|O|O||D||1
51142904|Lidocaína|O|O||D||1|Xilocaína
51142905|Bupivacaína|O|O||D||1
51142906|Clorhidrato de ametocaína|O|O||D||1
51142907|Oxibuprocaína|O|O||D||1
51142908|Lignocaina|O|O||D||1
51142909|Benzocaína|O|O||D||1|4-aminobenzoato
51142910|Prilocaina|O|O||D||1
51142911|Clorhidrato de quinisocaina|O|O||D||1
51142912|Dibucaina|O|O||D||1
51142913|Halotano|O|O||D||1
51142914|Clorhidrato de amilocaína|O|O||D||1
51142915|Septocaina|O|O||D||1
51142916|Hialuronidasa|O|O||D||1
51142917|Mepivacaína|O|O||D||1
51142918|Articaína|O|O||D||1
51142919|Isoflurano|O|O||D||1
51142920|Procaina|O|O||D||1|Novocaina
51142921|Tiopental sódico|O|O||D||1
51142922|Clorhidrato de benoxinato|O|O||D||1
51142923|Butambeno|O|O||D||1
51142924|Clorobutanol|O|O||D||1
51142925|Clorhidrato de cloroprocaína|O|O||D||1
51142927|Desflurano|O|O||D||1
51142928|Clorhidrato de diclonina|O|O||D||1
51142929|Enflurano|O|O||D||1
51142930|Éter|O|O||D||1
51142931|Cloruro de etilo|O|O||D||1|Cloroetano, Monocloroetano
51142932|Clorhidrato de etidocaína|O|O||D||1
51142933|Etomidato|O|O||D||1
51142934|Clorhidrato de ketamina|O|O||D||1
51142935|Levobupivacaína hidrocloruro|O|O||D||1
51142936|Levonordefrina|O|O||D||1
51142937|Clorhidrato de lidocaína|O|O||D||1
51142938|Metohexital sódico|O|O||D||1
51142939|Clorhidrato de pramoxina|O|O||D||1
51142940|Clorhidrato de proparacaína|O|O||D||1
51142941|Propofol|O|O||D||1
51142942|Sevoflurano|O|O||D||1
51142943|Tetracaína|O|O||D||1
51142944|Clorhidrato de tetracaina|O|O||D||1
51142945|Clorhidrato de doxapram|O|O||D||1|Dopram
51142946|Metoxiflurano|O|O||D||1
51142947|Clorhidrato de cincocaína|O|O||D||1
51142948|Diclorotetrafluoroetano|O|O||D||1
51151500|Colinérgicos y inhibidores de la colinesterasa|O|O||D||1|Agentes para el sistema nervioso parasimpático
51151501|Cloruro de betanecol|O|O||D||1
51151502|Cloruro de edrofonio|O|O||D||1|Tensilon
51151503|Fisostigmina|O|O||D||1
51151504|Nitrato de pilocarpina|O|O||D||1
51151505|Clorhidrato de tropatepina|O|O||D||1
51151506|Inhibidor de la esterasa|O|O||D||1
51151507|Cloruro de ambenonio|O|O||D||1
51151508|Dexpantenol|O|O||D||1|Pro-vitamina B5
51151509|Donepezilo clorhidrato|O|O||D||1
51151510|Bromhidrato de galantamina|O|O||D||1
51151511|Bromuro de mepenzolato|O|O||D||1
51151512|Metilsulfato de neostigmina|O|O||D||1
51151513|Bromuro de neostigmina|O|O||D||1
51151514|Bromuro de piridostigmina|O|O||D||1
51151515|Tartrato de rivastigmina|O|O||D||1
51151516|Clorhidrato de tacrina|O|O||D||1
51151517|Clorhidrato de cevimelina|O|O||D||1|Evoxac
51151518|Lecitina o fosfatidilcolina|O|O||D||1
51151600|Agentes bloqueadores colinérgicos|O|O||D||1|Agentes bloqueadores del sistema nervioso parasimpático
51151601|Sulfato de atropina|O|O||D||1
51151602|Mesilato de benztropina|O|O||D||1|Mesilato de benzotropina
51151603|Clorhidrato de prociclidina|O|O||D||1
51151604|Clorhidrato de trihexifenidilo|O|O||D||1
51151605|Clorhidrato de ciclopentolato|O|O||D||1
51151606|Tropicamida|O|O||D||1
51151607|Bromuro de clidinio|O|O||D||1
51151608|Clorhidrato de diciclomina|O|O||D||1
51151609|Bromuro de propantelina|O|O||D||1
51151610|Alcaloides de belladona|O|O||D||1
51151611|Glicopirrolato|O|O||D||1
51151612|Sulfato de hiosciamina|O|O||D||1
51151613|Bromhidrato de escopolamina|O|O||D||1
51151614|Homatropina bromhidrato|O|O||D||1
51151615|Caramifeno|O|O||D||1
51151616|Atropina|O|O||D||1
51151700|Simpatomiméticos (adrenérgicos)|O|O||D||1
51151701|Albuterol|O|O||D||1|Salbutamol
51151702|Tartrato de brimonidina|O|O||D||1
51151703|Epinefrina|O|O||D||1|Adrenalina
51151704|Borato de epinefrina|O|O||D||1
51151705|Clorhidrato de epinefrina|O|O||D||1
51151706|Isoproterenol|O|O||D||1|Isoprenalina
51151707|Sulfato de isoproterenol|O|O||D||1
51151708|Bitartrato de levarterenol|O|O||D||1
51151709|Fenilpropanolamina clorhidrato|O|O||D||1
51151710|Clorhidrato de fenilefrina|O|O||D||1
51151711|Sulfato de terbutalina|O|O||D||1
51151712|Clorhidrato de arbutamina|O|O||D||1
51151713|Clorhidrato de cinamedrina|O|O||D||1
51151714|Sulfato de d-anfetamina|O|O||D||1
51151715|Sulfato de efedrina|O|O||D||1
51151716|Clorhidrato de isoproterenol|O|O||D||1
51151717|Sulfato de mefentermina|O|O||D||1
51151718|Bitartrato de metaraminol|O|O||D||1
51151719|Pseudoefedrina|O|O||D||1|Seudoefedrina
51151720|Xinafoato de salmeterol|O|O||D||1
51151721|Clorhidrato de midodrina|O|O||D||1
51151722|Clorhidrato de levalbuterol|O|O||D||1
51151723|Clorhidrato de tetrahidrozolina|O|O||D||1
51151724|Clorhidrato de nafazolina|O|O||D||1
51151725|Dipivefrina|O|O||D||1
51151726|Fenilpropanolamina|O|O||D||1|Fenilpropalamina
51151727|Norepinefrina bitartrato|O|O||D||1
51151728|Bromhidrato hidroxianfetamina|O|O||D||1
51151730|Epinefrina bitartrato|O|O||D||1|Adrenalina tartrato
51151731|Sulfato de metaproterenol|O|O||D||1
51151732|Clorhidrato de dobutamina|O|O||D||1
51151733|Clorhidrato de dipivefrina|O|O||D||1
51151734|Sulfato de albuterol|O|O||D||1
51151735|Aspartato de anfetamina|O|O||D||1
51151736|Mesilato de isoetarina|O|O||D||1
51151737|Clorhidrato de dopamina|O|O||D||1
51151738|Fumarato de formoterol|O|O||D||1
51151739|Clorhidrato de metoxamina|O|O||D||1
51151740|Clorhidrato de isoetarina|O|O||D||1
51151741|Efedrina|O|O||D||1
51151742|Fenilefrina|O|O||D||1|Metaoxedrina, Neooxedrina
51151743|Clorhidrato de pseudoefedrina|O|O||D||1
51151744|Hidrocloruro de efedrina|O|O||D||1
51151745|Tanato de pseudoefedrina|O|O||D||1
51151746|Sulfato de pseudoefedrina|O|O||D||1
51151747|Hidrocloruro de racepinephrine|O|O||D||1
51151748|Nafazolina|O|O||D||1
51151749|Dextroanfetamina|O|O||D||1|Dexedrine
51151750|Arformoterol|O|O||D||1
51151800|Agentes bloqueadores adrenérgicos|O|O||D||1
51151801|Atenolol|O|O||D||1
51151802|Hidrocloruro de esmolol|O|O||D||1
51151803|Nadolol|O|O||D||1
51151804|Pindolol|O|O||D||1
51151805|Maleato de timolol|O|O||D||1
51151810|Mesilato de fentolamina|O|O||D||1
51151811|Hidrocloruro de yohimbina|O|O||D||1
51151812|Hidrocloruro de propranolol|O|O||D||1
51151813|Acebutolol|O|O||D||1
51151814|Hidrocloruro de betaxolol|O|O||D||1
51151815|Hidrocloruro de tolazolina|O|O||D||1
51151816|Hidrocloruro de prazosín|O|O||D||1
51151817|Hidrocloruro de tamsulosina|O|O||D||1
51151818|Hidrocloruro de carteolol|O|O||D||1
51151819|Hidrocloruro de terazosina|O|O||D||1
51151820|Hidrocloruro de fenoxibenzamina|O|O||D||1
51151821|Sulfato de penbutolol|O|O||D||1
51151822|Succinato de metoprolol|O|O||D||1|Metoprolol
51151823|Hidrocloruro de labetalol|O|O||D||1
51151824|Mesilato de doxazosina|O|O||D||1
51151825|Hidrocloruro de dapiprazol|O|O||D||1
51151900|Relajantes músculo-esqueléticos de acción centrada|O|O||D||1
51151901|Baclofeno|O|O||D||1|Lioresal
51151902|Clorzoxazona|O|O||D||1
51151903|Dantroleno sódico|O|O||D||1
51151904|Metocarbamol|O|O||D||1|Robaxin
51151905|Carisoprodol|O|O||D||1
51151906|Isoxsuprina|O|O||D||1
51151907|Clorhidrato de ritodrina|O|O||D||1
51151908|Citrato de orfenadrina|O|O||D||1
51151910|Nonivamida|O|O||D||1|Vanillilamida de ácido pelargónico
51151911|Suxametonio|O|O||D||1|Succinilcolina
51151912|Tiocolchicósido|O|O||D||1
51151913|Clorfenesina carbamato|O|O||D||1
51151914|Clorhidrato de ciclobenzaprina|O|O||D||1
51151915|Metaxalona|O|O||D||1
51151916|Cloruro de succinilcolina|O|O||D||1|Cloruro de suxametonio
51151917|Clorhidrato de tizanidina|O|O||D||1
51151918|Alfuzosina|O|O||D||1
51151919|Hci cropiverina|O|O||D||1
51151920|Tolterodina|O|O||D||1
51152000|Agentes bloqueadores neuromusculares|O|O||D||1
51152001|Besilato de atracurio|O|O||D||1
51152002|Cloruro de mivacurio|O|O||D||1
51152003|Bromuro de rocuronio|O|O||D||1
51152004|Bromuro de vecuronio|O|O||D||1
51152005|Toxina botulínica|O|O||D||1
51152006|Cisatracurio|O|O||D||1
51152007|Cloruro de doxacurio|O|O||D||1
51152008|Yoduro de metocurina|O|O||D||1
51152009|Bromuro de pancuronio|O|O||D||1
51152010|Bromuro de rapacuronio|O|O||D||1
51152011|Cloruro de tubocurarina|O|O||D||1
51152012|Bromuro de pipecuronio|O|O||D||1
51161500|Antiasmáticos|O|O||D||1
51161501|Mesilato de bitolterol|O|O||D||1
51161502|Nedocromil sódico|O|O||D||1
51161503|Acetato de pirbuterol|O|O||D||1
51161504|Aminofilina|O|O||D||1
51161505|Teofilina|O|O||D||1|Teofilina
51161506|Terbutalina|O|O||D||1
51161507|Formoterol|O|O||D||1
51161508|Sulfato de salbutamol|O|O||D||1
51161510|Teofilina|O|O||D||1|Etofilina
51161511|Cromoglicato de sodio|O|O||D||1|Cromoglicato de sodio
51161513|Difilina|O|O||D||1|Diprofilina
51161514|Oxtrifilina|O|O||D||1
51161515|Montelukast sódico|O|O||D||1
51161516|Zafirlukast|O|O||D||1
51161517|Zileutón|O|O||D||1
51161518|Hidrato de pranlukast|O|O||D||1
51161519|Carmoterol|O|O||D||1
51161520|Ciclesonida|O|O||D||1
51161521|Cilomilast|O|O||D||1
51161522|Tulobuterol|O|O||D||1
51161523|Clorhidrato de reproterol|O|O||D||1
51161524|Bromuro de tiotropio|O|O||D||1
51161525|Beclometasona|O|O||D||1
51161600|Antihistamínicos (bloqueadores H1)|O|O||D||1|Antialérgicos (bloqueadores H1)
51161601|Astemizol|O|O||D||1
51161602|Fumarato de clemastina|O|O||D||1
51161603|Maleato de dexclorfeniramina|O|O||D||1
51161605|Clorhidrato de levocabastina|O|O||D||1
51161606|Loratadina|O|O||D||1|Civeran
51161607|Terfenadina|O|O||D||1
51161608|Clorhidrato de betahistina|O|O||D||1
51161609|Hidrocloruro de triprolidina|O|O||D||1
51161610|Prometazina|O|O||D||1
51161611|Oxomemazina|O|O||D||1
51161612|Ebastina|O|O||D||1
51161613|Mesilato de dihidroergotoxina|O|O||D||1
51161614|Clorhidrato de meclozina|O|O||D||1
51161615|Cetirizina|O|O||D||1|Alercet
51161616|Betahistina|O|O||D||1|Betaserc
51161617|Clorhidrato de buclicina|O|O||D||1
51161618|Alimemazina|O|O||D||1
51161619|Mepiramina maleato|O|O||D||1
51161620|Difenhidramina|O|O||D||1|Dimedrol
51161621|Clorhidrato de fexofenadina|O|O||D||1
51161622|Cromoglicato de sodio|O|O||D||1|Cromolín sódico
51161623|Hidroxizina pamoato|O|O||D||1
51161624|Maleato de  azatadina|O|O||D||1
51161625|Azelastina hidrocloruro|O|O||D||1
51161626|Bosentán|O|O||D||1
51161627|Maleato de bromfeniramina|O|O||D||1
51161628|Maleato de carbinoxamina|O|O||D||1
51161629|Hidrocloruro de cetirizina|O|O||D||1
51161630|Maleato de clorfenamina|O|O||D||1|Clorfeniramina
51161631|Tanato de clorfenamina|O|O||D||1
51161632|Clorhidrato de ciproheptadina|O|O||D||1
51161633|Desloratadina|O|O||D||1
51161634|Maleato de dexbromfeniramina|O|O||D||1
51161635|Clorhidrato de difenhidramina|O|O||D||1
51161636|Tanato de difenhidramina|O|O||D||1
51161637|Clorhidrato de hidroxizina|O|O||D||1
51161638|Fumarato de ketotifeno|O|O||D||1
51161639|Clorhidrato de olopatadina|O|O||D||1|Olopatadina
51161640|Tartrato de fenindamina|O|O||D||1
51161646|Acrivastina|O|O||D||1
51161647|Bromfeniramina|O|O||D||1
51161648|Difumarato de emedastina|O|O||D||1
51161649|Lodoxamida trometamina|O|O||D||1
51161650|Clorhidrato de prometazina|O|O||D||1
51161651|Potasio de pemirolast|O|O||D||1
51161652|Mizolastina|O|O||D||1
51161653|Clorhidrato de epinastina|O|O||D||1
51161654|Levocetirizina dihidrocloruro|O|O||D||1
51161655|Levocetirizina hemihidrato|O|O||D||1
51161700|Medicamentos para alteraciones del tracto respiratorio|O|O||D||1
51161701|Acetilcisteína|O|O||D||1
51161702|Beractant|O|O||D||1
51161703|Budesonida|O|O||D||1
51161704|Palmitato de colfoscerilo|O|O||D||1
51161705|Bromuro de ipratropio|O|O||D||1
51161706|Sobrerol|O|O||D||1
51161707|Clorhidrato de bamifilina|O|O||D||1
51161708|Dornasa alfa|O|O||D||1
51161709|Poractant alfa|O|O||D||1
51161710|Calfactant|O|O||D||1
51161800|Productos para tos, resfriados y antialérgicos|O|O||D||1
51161801|Benzonatato|O|O||D||1
51161802|Guaifenesina|O|O||D||1
51161803|Mentol|O|O||D||1
51161805|Carbocisteína|O|O||D||1|S-carboximetilcisteína
51161806|Cloruro de amonio|O|O||D||1|Clorhidrato amónico, Sal de amoniaco
51161808|Dextrometorfano|O|O||D||1
51161809|Citrato de oxolamina|O|O||D||1
51161810|Folcodina|O|O||D||1
51161811|Bromhexina|O|O||D||1|Ambroxol
51161812|Combinación de acetaminofen y clorfeniramina|O|O||D||1
51161813|Guayacolsulfonato de potasio|O|O||D||1
51161814|Bitartrato de fenilpropanolamina|O|O||D||1
51161815|Tanato de carbetapentano|O|O||D||1
51161817|Clorhidrato de dextrometorfano|O|O||D||1
51161818|Dextrometorfano polistirex|O|O||D||1
51161819|Tanato de dextrometorfano|O|O||D||1
51161820|Aceite de eucalipto o eucaliptol|O|O||D||1
51161900|Descongestionantes nasales|O|O||D||1
51161901|Clorhidrato de oximetazolina|O|O||D||1|Oximetazolina
51161903|Clorhidrato de xilometazolina|O|O||D||1
51171500|Antiácidos y antiflatulentos|O|O||D||1
51171501|Carbonato de calcio|O|O||D||1
51171502|Magaldrato|O|O||D||1
51171503|Hidróxido de magnesio|O|O||D||1
51171504|Antiácidos de bicarbonato de sodio|O|O||D||1
51171505|Simeticona|O|O||D||1
51171507|Hidrotalcita|O|O||D||1
51171508|Carbonato de magnesio|O|O||D||1
51171509|Clorhidrato de betaína|O|O||D||1|Hidrocloruro de betaína
51171510|Trisilicato de magnesio|O|O||D||1
51171511|Hidróxido de aluminio|O|O||D||1
51171513|Dihidroxialuminio-carbonato de sodio|O|O||D||1
51171600|Laxantes|O|O||D||1
51171601|Cáscara sagrada|O|O||D||1
51171602|Docusato de calcio|O|O||D||1
51171603|Docusato potásico|O|O||D||1
51171604|Docusato de sodio|O|O||D||1
51171605|Lactulosa|O|O||D||1
51171606|Sulfato de magnesio|O|O||D||1|Sulfato magnésico
51171607|Mucílago hidrófilo del psilio|O|O||D||1
51171608|Glicerina|O|O||D||1|Glicerol
51171609|Ácido dehidrocólico|O|O||D||1
51171610|Sen o senósidos|O|O||D||1
51171611|Estimulante bisacodilo|O|O||D||1
51171612|Metilcelulosa|O|O||D||1
51171613|Aloína|O|O||D||1
51171614|Bisacodyl|O|O||D||1
51171615|Calcio policarbofilo|O|O||D||1
51171616|Casantranol|O|O||D||1
51171617|Aceite de ricino|O|O||D||1|Aceite de castor
51171618|Monohidrato de cisaprida|O|O||D||1
51171619|Supositorios de glicerina|O|O||D||1
51171620|Citrato de magnesio|O|O||D||1
51171621|Clorhidrato de metoclopramida|O|O||D||1
51171622|Fosfato de sodio|O|O||D||1
51171623|Fenolftaleína|O|O||D||1
51171624|Semilla de psyllium|O|O||D||1
51171626|Bitartrato de potasio|O|O||D||1|Cremor tártaro
51171627|Tartrato de sodio y potasio|O|O||D||1|Sal de Seignette
51171628|Fosfato de potasio|O|O||D||1
51171629|Sulfato de sodio|O|O||D||1|Tetraoxidosulfato de disodio
51171630|Aceite mineral|O|O||D||1
51171631|Polietilenglicol laxante|O|O||D||1
51171632|Cloruro de magnesio|O|O||D||1|Dicloruro de magnesio
51171633|Lubiprostona|O|O||D||1
51171700|Antidiarréicos|O|O||D||1
51171701|Clorhidrato de difenoxina|O|O||D||1
51171702|Hidroclorato de loperamida|O|O||D||1
51171703|Paregorico|O|O||D||1
51171704|Nifuroxazida|O|O||D||1
51171706|Atapulgita|O|O||D||1|Palygorskita
51171707|Subsalicilato de bismuto|O|O||D||1
51171708|Clorhidrato de difenoxilato|O|O||D||1
51171709|Saccharomyces boulardii|O|O||D||1
51171710|Clorhidrato de alosetrón|O|O||D||1
51171711|Caolín y pectina|O|O||D||1
51171712|Pectina  purificada con acidophilus|O|O||D||1
51171800|Agentes antivértigo, antinauseantes y antieméticos|O|O||D||1
51171801|Dronabinol|O|O||D||1|Delta-9-tetrahidrocannabinol
51171802|Clorhidrato de granisetrón|O|O||D||1
51171803|Clorhidrato de meclizina|O|O||D||1
51171804|Clorhidrato de ondansetrón|O|O||D||1
51171805|Clorhidrato de trimetobenzamida|O|O||D||1
51171806|Metoclopramida|O|O||D||1|Metoclol
51171807|Cinarizina|O|O||D||1
51171808|Clorhidrato de difenidol|O|O||D||1|Difenidol
51171809|Ciclizina|O|O||D||1
51171811|Combinacion de dextrosa fructosa y ácido fosfórico|O|O||D||1
51171812|Proclorperazina|O|O||D||1
51171813|Metopimazina|O|O||D||1
51171814|Mesilato de dolasetrón|O|O||D||1|Anzemet
51171815|Clorhidrato de ciclizina|O|O||D||1
51171816|Ondansetrón|O|O||D||1|Zofran
51171817|Edisilato de proclorperazina|O|O||D||1
51171818|Maleato de proclorperazina|O|O||D||1
51171819|Maleato de tietilperacina|O|O||D||1
51171820|Dimenhidrinato|O|O||D||1
51171821|Aprepitant|O|O||D||1
51171822|Clorhidrato de palonosetrón|O|O||D||1
51171823|Granisetrón  base|O|O||D||1
51171900|Fármacos antiúlcera y otros fármacos gastrointestinales (GI) relacionados|O|O||D||1
51171901|Cimetidina|O|O||D||1
51171902|Famotidina|O|O||D||1
51171903|Nizatidina|O|O||D||1
51171904|Clorhidrato de ranitidina|O|O||D||1
51171905|Cisapride|O|O||D||1|Cisaprida
51171906|Lansoprazol|O|O||D||1
51171907|Clordiazepóxido clorhidrato o combinación de bromuro clinidio|O|O||D||1|Librax
51171908|Misoprostol|O|O||D||1|Misodel
51171909|Omeprazol|O|O||D||1
51171910|Pancreatina|O|O||D||1
51171911|Sucralfato|O|O||D||1
51171912|Clorhidrato de cimetidina|O|O||D||1
51171913|Esomeprazol magnesico  trihidrato|O|O||D||1|Esomeprazol
51171914|Pantoprazol sódico sesquihidratado|O|O||D||1
51171915|Pantoprazol sódico|O|O||D||1
51171916|Rabeprazol sódico|O|O||D||1
51171917|Citrato de bismuto ranitidina|O|O||D||1
51171918|Carbonato de aluminio|O|O||D||1
51171919|Amlexanox|O|O||D||1
51171920|Pantopra|O|O||D||1
51171921|Doramectina|O|O||D||1
51171922|Maleato de tegaserod|O|O||D||1
51171923|Racecadotrilo|O|O||D||1
51171924|Ramosetron|O|O||D||1
51171925|Rebamipida|O|O||D||1
51171926|Sevelamer|O|O||D||1
51172000|Medicamentos para enfermedades de la vesícula biliar|O|O||D||1
51172001|Quenodiol|O|O||D||1|Ácido quenodesoxicólico
51172002|Monoctanoina|O|O||D||1
51172003|Ursodiol|O|O||D||1|Ácido ursodesoxicólico
51172004|Dimetilsulfóxido|O|O||D||1|Metil-sulfóxido, Sulfinilbismetano
51172100|Antiespasmódicos|O|O||D||1|Relajantes musculares
51172101|Clorhidrato de mebeverina|O|O||D||1
51172102|Clorhidrato de dicicloverina|O|O||D||1|Sediclon
51172103|Clorhidrato de pitofenona|O|O||D||1
51172105|Floroglucinol|O|O||D||1
51172106|Clorhidrato de oxibutinina|O|O||D||1
51172107|Butilbromuro de hioscina|O|O||D||1|Bromuro de butilescopolamina
51172108|Clorhidrato de viquidil|O|O||D||1
51172109|Trimebutina|O|O||D||1
51172110|Clorhidrato de prozapina|O|O||D||1
51172111|Alverina|O|O||D||1
51181500|Agentes antidiabéticos y agentes hiperglicémicos|O|O||D||1
51181501|Acarbosa|O|O||D||1
51181502|Acetohexamida|O|O||D||1
51181503|Clorpropamida|O|O||D||1
51181504|Glimepirida|O|O||D||1
51181505|Glipizida|O|O||D||1
51181506|Insulina|O|O||D||1
51181508|Glucagón|O|O||D||1
51181509|Gliclazida|O|O||D||1
51181510|Clorhidrato de fenformina|O|O||D||1
51181511|Buformina|O|O||D||1
51181513|Nateglinida|O|O||D||1|Starlix
51181514|Extracto de páncreas|O|O||D||1
51181515|Tolbutamida|O|O||D||1
51181516|Glibenclamida o gliburida|O|O||D||1
51181517|Hidrocloruro de metformina|O|O||D||1
51181519|Miglitol|O|O||D||1
51181520|Clorhidrato de pioglitazona|O|O||D||1
51181521|Repaglinida|O|O||D||1|Prandin
51181522|Maleato de rosiglitazona|O|O||D||1|Avandia
51181523|Tolazamida|O|O||D||1
51181524|Troglitazona|O|O||D||1
51181525|Mosaprida|O|O||D||1
51181526|Epalrestat|O|O||D||1|Sal epalrestat
51181527|Voglibosa|O|O||D||1
51181528|Exenatida|O|O||D||1
51181600|Medicamentos tiroideas y antitiroideas|O|O||D||1
51181601|Levotiroxina sódica|O|O||D||1
51181602|Liotironina sódica|O|O||D||1
51181603|Liotrix|O|O||D||1|T3/T4 Liotrix
51181604|Tirotropina|O|O||D||1|Hormona tirotrópica, TSH
51181605|Metimazol|O|O||D||1|Tiamazol
51181606|Propiltiouracilo|O|O||D||1|6-n-propiltiouracilo, PTU
51181607|Yoduro de potasio|O|O||D||1|Yoduro potásico
51181608|Levotiroxina|O|O||D||1|L-tiroxina, Levotiroximarycelisna
51181609|Yoduro de sodio|O|O||D||1|Yoduro sódico
51181700|Corticosteroides|O|O||D||1
51181701|Betametasona|O|O||D||1
51181702|Corticotropina|O|O||D||1|Adrenocorticotropa
51181703|Cosintropina|O|O||D||1
51181704|Dexametasona|O|O||D||1
51181705|Flunisolida|O|O||D||1
51181706|Hidrocortisona|O|O||D||1|Cortisol
51181707|Metilprednisolona|O|O||D||1
51181708|Prednisolona|O|O||D||1
51181709|Triamcinolona|O|O||D||1
51181710|Desoximetasona|O|O||D||1
51181711|Meprednisona|O|O||D||1|Beta metilprednisona acetato
51181712|Ácido risedrónico|O|O||D||1|Risedronato
51181713|Prednisona|O|O||D||1
51181714|Prednicarbato|O|O||D||1
51181715|Cortisona|O|O||D||1|17-hidroxi-11-corticosterona
51181716|Cortivazol|O|O||D||1
51181717|Acetato de desoxicortona|O|O||D||1
51181718|Deflazacort|O|O||D||1
51181719|Acetónido de fluocinolona|O|O||D||1
51181720|Diacetato de diflorasona|O|O||D||1
51181721|Corticorelina ovina triflutato|O|O||D||1
51181722|Fluticasona|O|O||D||1
51181723|Acetato de hidrocortisona|O|O||D||1
51181724|Hidrocortisona buteprato|O|O||D||1
51181725|Butirato de hidrocortisona|O|O||D||1
51181726|Fosfato sódico de hidrocortisona|O|O||D||1
51181727|Valerato de hidrocortisona|O|O||D||1
51181728|Acetato de metilprednisolona|O|O||D||1
51181729|Succinato sódico de metilprednisolona|O|O||D||1
51181730|Acetato de prednisolona|O|O||D||1
51181731|Acetato de triamcinolona|O|O||D||1
51181732|Diacetato de triamcinolona|O|O||D||1
51181733|Hexacetonido de triamcinolona|O|O||D||1
51181734|Dipropionato de alclometasona|O|O||D||1
51181735|Propionato de halobetasol|O|O||D||1
51181736|Fluorometolona|O|O||D||1
51181737|Halcinonida|O|O||D||1
51181738|Acetato de fludrocortisona|O|O||D||1
51181739|Rimexolona|O|O||D||1
51181740|Fosfato sódico de dexametasona|O|O||D||1
51181741|Loteprednol etabonato|O|O||D||1
51181742|Propionato de clobetasol|O|O||D||1
51181743|Pivalato de clocortolona|O|O||D||1
51181744|Fluocinonida|O|O||D||1
51181745|Flurandrenolida|O|O||D||1
51181746|Amcinonida|O|O||D||1
51181747|Probutato de hidrocortisona|O|O||D||1
51181748|Medrisona|O|O||D||1
51181749|Furoato de mometasona|O|O||D||1
51181750|Desonida|O|O||D||1
51181751|Fosfato sódico de prednisolona|O|O||D||1
51181752|Dipropionato de beclometasona|O|O||D||1
51181753|Acetato de cortisona|O|O||D||1
51181754|Dipropionato de betametasona|O|O||D||1
51181755|Valerato de betametasona|O|O||D||1
51181756|Acetato de melengestrol|O|O||D||1
51181800|Estrógenos, progesteronas y anticonceptivos internos|O|O||D||1
51181801|Clorotrianiseno|O|O||D||1
51181802|Estrona|O|O||D||1|Cetohidroxiestrina, Foliculina, Hormona folicula
51181803|Estrógenos conjugados|O|O||D||1
51181804|Estropipato|O|O||D||1
51181805|Levonorgestrel|O|O||D||1|D-norgestrel
51181806|Acetato de megestrol|O|O||D||1
51181807|Etinilestradiol|O|O||D||1
51181808|Mestranol|O|O||D||1
51181810|Acetato de clormadinona|O|O||D||1
51181811|Desogestrel y etinilestradiol|O|O||D||1
51181812|Dienestrol|O|O||D||1
51181813|Estradiol|O|O||D||1
51181814|Etisterona|O|O||D||1
51181815|Estradiol y acetato de noretisterona|O|O||D||1
51181816|Hidroxiestrona diacetato|O|O||D||1
51181817|Promestrieno|O|O||D||1
51181818|Progesterona|O|O||D||1|Pregn-4-en-3,20-diona
51181819|Promegestona|O|O||D||1
51181820|Gestrinona|O|O||D||1
51181821|Cipionato de estradiol|O|O||D||1
51181822|Valerato de estradiol|O|O||D||1
51181823|Estrógenos esterificados|O|O||D||1
51181824|Diacetato de etinodiol|O|O||D||1
51181825|Dietilestilbestrol|O|O||D||1
51181826|Caproato de hidroxiprogesterona|O|O||D||1
51181827|Acetato de medroxiprogesterona|O|O||D||1|17-acetato de medroxiprogesterona
51181828|Noretindrona|O|O||D||1|19-noretisterona
51181829|Acetato de noretindrona|O|O||D||1|Acetato de noretisterona
51181830|Norgestimato|O|O||D||1
51181831|Norgestrel|O|O||D||1
51181832|Etonogestrel y etinil estradiol|O|O||D||1|Anillo anticonceptivo
51181833|Etinil-estradiol y diacetato de etinodiol|O|O||D||1
51181834|Noretindrona y  etinil estradiol|O|O||D||1
51181835|Altrenogest|O|O||D||1
51181836|Gestodeno|O|O||D||1
51181900|Hormonas gonadotrópicas y estimulantes e inhibidores ováricos|O|O||D||1
51181901|Gonadotropina coriónica|O|O||D||1|Gonadotrofina coriónica humana
51181902|Danazol|O|O||D||1
51181903|Acetato de gonadorelina|O|O||D||1|Gonadorelina acetato
51181904|Acetato de histrelina|O|O||D||1|Implante de histrelina
51181905|Menotropinas|O|O||D||1
51181906|Urofolitropina|O|O||D||1
51181908|Fosfestrol de sodio|O|O||D||1
51181911|Citrato de clomifeno|O|O||D||1|Fenil-1,2-difenil-2-cloroetileno citrato
51181912|Folitropina|O|O||D||1|Hormona foliculoestimul
51181913|Clorhidrato de gonadorelina|O|O||D||1
51181914|Linestrenol|O|O||D||1
51182000|Andrógenos e inhibidores androgénicos|O|O||D||1
51182001|Finasterida|O|O||D||1
51182002|Testosterona|O|O||D||1
51182003|Cipionato de testosterona|O|O||D||1
51182004|Enantato de testosterona|O|O||D||1|Primoteston
51182005|Propionato de testosterona|O|O||D||1|Testosterona propionato
51182006|Acetato de trembolona|O|O||D||1
51182007|Metandriol|O|O||D||1
51182008|Fluoximesterona|O|O||D||1|Halotestin
51182009|Metiltestosterona|O|O||D||1|Metandren
51182010|Decanoato de nandrolona|O|O||D||1
51182011|Fenilpropionato de nandrolona|O|O||D||1
51182012|Prasterona|O|O||D||1|Dehidroepiandrosterona
51182013|Stanozolol|O|O||D||1|Estanozolol
51182014|Dutasteride|O|O||D||1|Dutasterida
51182100|Hormonas de la pituitaria posterior|O|O||D||1
51182101|Acetato de desmopresina|O|O||D||1
51182102|Vasopresina|O|O||D||1|Hormona antidiurética
51182200|Medicamentos para la inducción del parto|O|O||D||1
51182201|Dinoprostona|O|O||D||1
51182202|Maleato de metilergonovina|O|O||D||1
51182203|Oxitocina|O|O||D||1
51182204|Maleato de ergonovina|O|O||D||1|Occitocina
51182300|Hormonas del crecimiento y sus inhibidores|O|O||D||1
51182301|Somatrem|O|O||D||1|Protropin
51182302|Somatropina|O|O||D||1|Hormona somatotropina
51182303|Somatostatina|O|O||D||1|Hormona inhibidora de la liberación de somatotropina
51182304|Acetato de octreotida|O|O||D||1
51182400|Sales de calcio y reguladores del calcio|O|O||D||1
51182401|Cloruro de calcio|O|O||D||1|Cloruro cálcico
51182403|Gluconato de calcio|O|O||D||1|Gluconato cálcico
51182404|Lactato de calcio|O|O||D||1|Lactato Cálcico
51182405|Fosfato de calcio dibase|O|O||D||1
51182406|Alendronato sódico|O|O||D||1|Ácido alendrónico
51182407|Calcitonina|O|O||D||1
51182408|Fosfato  sódico de celulosa|O|O||D||1|Fosfato sódico de celulosa
51182409|Nitrato de galio|O|O||D||1
51182410|Etidronato disódico|O|O||D||1
51182411|Nandrolona|O|O||D||1
51182412|Fosfato calcio tribásico|O|O||D||1
51182413|Calcio fosfato de glicerol|O|O||D||1|Glicerofosfato de calcio
51182415|Ácido zoledrónico|O|O||D||1
51182416|Pamidronato disódico|O|O||D||1
51182417|Risedronato de sodio|O|O||D||1
51182418|Acetato de calcio|O|O||D||1
51182419|Glucoheptonato de calcio  o gluceptato de calcio|O|O||D||1
51182420|Dihidrotaquisterol|O|O||D||1
51182421|Nitrendipino|O|O||D||1
51182422|Benidipina hcl|O|O||D||1
51182423|Ibandronato|O|O||D||1|Ácido ibandrónico
51182424|Raloxifeno hcl|O|O||D||1
51191500|Diuréticos|O|O||D||1
51191501|Clorotiazida|O|O||D||1
51191502|Clortalidona|O|O||D||1|Talamodina
51191503|Metolazona|O|O||D||1
51191504|Bumetanida|O|O||D||1
51191505|Etacrinato de sodio|O|O||D||1
51191506|Clorhidrato de amilorida|O|O||D||1
51191507|Espironolactona|O|O||D||1
51191508|Triamtereno|O|O||D||1
51191509|Manitol|O|O||D||1
51191510|Furosemida|O|O||D||1
51191511|Canrenoato de potasio|O|O||D||1|Canrenoato potásico
51191512|Lasitone|O|O||D||1
51191513|Bendroflumetiazida|O|O||D||1
51191514|Ácido etacrínico|O|O||D||1
51191515|Hidroclorotiazida|O|O||D||1|HCTZ
51191516|Hidroflumetiazida|O|O||D||1
51191517|Isosorbide|O|O||D||1
51191518|Meticlotiazida|O|O||D||1
51191519|Pamabrom|O|O||D||1
51191520|Politiazida|O|O||D||1
51191521|Torasemida|O|O||D||1|Torsemida
51191522|Triclormetiazida|O|O||D||1
51191523|Diurético osmótico urea|O|O||D||1
51191600|Electrolitos|O|O||D||1
51191601|Dextrosa|O|O||D||1|Glucosa
51191602|Electrolitos de cloruro de sodio|O|O||D||1
51191603|Alimentación parenteral total o soluciones apt nutricionales|O|O||D||1|Solución total nutricional parenteral
51191604|Solución ringer lactato|O|O||D||1
51191605|Agua estéril para inyección|O|O||D||1
51191606|Cloruro cúprico|O|O||D||1|Cloruro de cobre
51191700|Agentes alcalinizadores|O|O||D||1
51191701|Trometamina|O|O||D||1|Trometamina ketorolaco
51191702|Lactato de sodio|O|O||D||1
51191703|Acetato de sodio|O|O||D||1|Diacetato de sodio
51191704|Soluciones electrolíticas múltiples|O|O||D||1
51191705|Combinación de ácido cítrico y citrato de potasio|O|O||D||1
51191706|Combinación de ácido cítrico y citrato de sodio|O|O||D||1
51191800|Sales de potasio|O|O||D||1
51191801|Bicarbonato de potasio|O|O||D||1|Carbonato de potasa
51191802|Cloruro de potasio|O|O||D||1
51191803|Gluconato de potasio|O|O||D||1
51191804|Acetato de potasio|O|O||D||1|Sal potásica
51191805|Suplemento de potasio|O|O||D||1
51191900|Suplementos dietéticos y productos de terapia alimenticia|O|O||D||1|Suplementos alimenticios o nutricionales
51191901|Residuo de germen de maíz|O|O||D||1
51191902|Suplementos de amino ácidos|O|O||D||1
51191903|Pentermina|O|O||D||1|Fentermina
51191904|Fosfolípidos|O|O||D||1
51191905|Suplementos vitamínicos|O|O||D||1
51191906|Solución de rehidratación oral|O|O||D||1
51191907|Amonio molibdato|O|O||D||1|Heptamolibdato de Amonio
51191908|Orlistat|O|O||D||1|Tetrahidrolipstatina
51191909|Tiamina|O|O||D||1|Vitamina B1
51191910|Calcitriol|O|O||D||1
51191911|Retinol|O|O||D||1|Antixeroftálmica, Vitamina A
51201500|Inmunodepresores|O|O||D||1
51201501|Azatioprina|O|O||D||1
51201502|Ciclosporina|O|O||D||1
51201503|Mofetilo micofenolato|O|O||D||1
51201504|Tacrolimus|O|O||D||1|Tacrolimús
51201505|Antilinfocitos|O|O||D||1
51201506|Defibrotide|O|O||D||1
51201507|Aldesleukina|O|O||D||1|Interleukin-2
51201508|Basiliximab|O|O||D||1|Simulect
51201509|Daclizumab|O|O||D||1
51201510|Imiquimod|O|O||D||1
51201511|Muromonab cd3|O|O||D||1
51201512|Clorhidrato de micofenolato de mofetilo|O|O||D||1
51201513|Peginterferón|O|O||D||1|Interferón pegilado
51201514|Pimecrolimus|O|O||D||1
51201515|Sirolimus|O|O||D||1|Rapamicina
51201516|Antilinfocito o inmunoglobulina linfocítica|O|O||D||1
51201517|Hidrocloruro de guanidina|O|O||D||1
51201518|Azatioprina sódica|O|O||D||1
51201519|Alefacept|O|O||D||1
51201600|Vacunas, antígenos y toxoides|O|O||D||1
51201601|Antígeno de ántrax|O|O||D||1
51201602|Antígeno brucélico|O|O||D||1
51201603|Vacuna contra el cólera|O|O||D||1
51201604|Difteria|O|O||D||1|Vacuna contra la difteria
51201605|Vacuna contra el virus de la encefalitis|O|O||D||1
51201606|Influenza hemofílica|O|O||D||1|Vacuna contra la influenza hemofilica
51201607|Vacuna contra el virus de hepatitis b|O|O||D||1
51201608|Vacuna contra el virus de la influenza|O|O||D||1
51201609|Vacuna contra el virus del sarampión|O|O||D||1
51201610|Vacuna meningococo|O|O||D||1
51201611|Morbillivirus|O|O||D||1|Vacuna contra morvillivirus
51201612|Vacuna contra el virus de las paperas|O|O||D||1
51201613|Parotiditis|O|O||D||1|Paperas
51201614|Vacuna contra la pertussis|O|O||D||1
51201615|Vacuna contra el neumococo|O|O||D||1
51201616|Vacuna contra el virus del polio|O|O||D||1
51201617|Vacuna contra la rabia|O|O||D||1
51201618|Rotavirus|O|O||D||1|Vacuna contra el rotavirus
51201619|Vacuna contra el virus de la rubeola|O|O||D||1
51201620|Viruela|O|O||D||1|Vacuna contra la viruela
51201621|Toxoide tetánico|O|O||D||1
51201622|Tuberculosis|O|O||D||1|Vacuna contra la tuberculosis
51201623|Vacuna contra el tifo|O|O||D||1|Vacuna contra el tifoidea
51201624|Vacuna contra el virus de la varicela|O|O||D||1
51201625|Vacuna contra la fiebre amarilla|O|O||D||1
51201626|Hepatitis a|O|O||D||1|Vacuna preventiva contra hepatitis
51201627|Vacuna contra la hemofilia b|O|O||D||1
51201628|Vacuna contra los virus del sarampión, paperas y rubeola|O|O||D||1
51201629|Difteria y toxoide tetánico adsorbido|O|O||D||1
51201631|Vacuna contra difteria y toxoide tetánico y pertussis acelular|O|O||D||1
51201632|Difteria y tétano y pertussis celular|O|O||D||1
51201633|Influenza b hemofílica con difteria y tétano y pertussis acelular|O|O||D||1
51201634|Influenza b hemofílica con difteria y tétano y pertussis celular conjugadas|O|O||D||1
51201635|Vacuna contra el virus de la hepatitis a|O|O||D||1
51201636|Vacuna contra la enfermedad de lyme (borreliosis)|O|O||D||1
51201638|Vacuna contra la plaga|O|O||D||1
51201639|Vacuna contra el estafilococo|O|O||D||1
51201646|Vacuna contra el virus del sarampión y la rubeola|O|O||D||1
51201647|Vacuna bcg|O|O||D||1
51201648|Vacuna contra el virus de la rubeola y las paperas|O|O||D||1
51201649|Vacuna contra el virus del papiloma humano|O|O||D||1
51201650|Vacuna contra el virus del COVID|O|O||2020-12-29||1|Vacuna contra SARS-CoV-2,Vacuna contra COVID, Vacuna contra COVID-19
51201700|Vacunas aviares|O|O||D||1
51201701|Hipocruposis|O|O||D||1
51201702|E coli|O|O||D||1|Escherichia coli
51201703|Gumboro|O|O||D||1|Vacuna contra el gumboro
51201704|Bronquitis infecciosa aviar|O|O||D||1|Vacuna contra la bronquitis infecciosa
51201705|Newcastle|O|O||D||1|Vacuna contra el newcastle
51201800|Agentes inmunoestimulantes|O|O||D||1
51201801|Inmunoglobulinas bacterianas|O|O||D||1
51201802|Filgrastim|O|O||D||1
51201803|Pelfigrastim|O|O||D||1|Neulasta
51201804|Sargramostim|O|O||D||1
51201805|Inmunoglobulina rho d|O|O||D||1|RhoGAM
51201806|Inmunoglobulina o gamma igg|O|O||D||1
51201807|Inmunoglobulinas virales|O|O||D||1
51201808|Clorhidrato levamisol|O|O||D||1|L-Tetramisol clorhidrato
51201809|Interferon|O|O||D||1
51201810|Galsulfasa|O|O||D||1
51201811|Talidomida|O|O||D||1
51201900|Agentes de la esclerosis múltiple (EM)|O|O||D||1
51201901|Acetato de glatiramer|O|O||D||1
51211500|Medicamentos antigota|O|O||D||1
51211501|Alopurinol|O|O||D||1
51211502|Colchicina|O|O||D||1|Colquicina
51211503|Probenecid|O|O||D||1
51211504|Sulfinpirazona|O|O||D||1
51211505|Benzbromarona|O|O||D||1
51211600|Antídotos y eméticos|O|O||D||1
51211601|Deferoxamina mesilato|O|O||D||1
51211602|Dexrazoxano|O|O||D||1
51211603|Digoxina inmune fab|O|O||D||1
51211604|Dimercaprol|O|O||D||1
51211605|Edetato disódico|O|O||D||1|Edatamil calcio disódico
51211606|Flumazenil|O|O||D||1|Flumazenilo
51211607|Ipecacuana|O|O||D||1
51211608|Penicilamina|O|O||D||1
51211609|Protamina sulfato|O|O||D||1
51211610|Sulfonato poliestireno sódico|O|O||D||1
51211611|Trientina|O|O||D||1|Trietilentetramina
51211612|Leucovorina|O|O||D||1|Ácido folínico
51211613|Sorbitol|O|O||D||1
51211615|Azul de metileno|O|O||D||1
51211616|Anti venenos|O|O||D||1
51211617|Leucovorina cálcica|O|O||D||1|Leucovorina cálcica
51211618|Antídoto de carbón activado|O|O||D||1
51211619|Edetato cálcico disódico|O|O||D||1
51211620|Fomepizol|O|O||D||1
51211621|Clorhidrato pralidoxima|O|O||D||1
51211622|Tiosulfato de sodio|O|O||D||1
51211623|Succimer|O|O||D||1|Ácido dimercaptosuccínico
51211624|Sulfato de cobre|O|O||D||1|Sulfato cúprico
51211625|Exopeptidasa g2|O|O||D||1
51211900|Fármacos anestésicos veterinarios|O|O||D||1
51211901|Xilacina|O|O||D||1
51212000|Fármacos herbales|O|O||D||1|Fármacos homeopáticos, Medicamentos homeopáticos en general.
51212001|Aceite etérico|O|O||D||1|Aceite esencial
51212002|Extracto de centella asiática|O|O||D||1
51212003|Extracto de ipecacuana|O|O||D||1|Jarabe de ipecacuana
51212004|Aesculus|O|O||D||1|Castaña de indias
51212005|Aconitum napellus (acónito común)|O|O||D||1
51212006|Valeriana|O|O||D||1|Valeriana medicinal
51212007|Ajo|O|O||D||1
51212008|Celidonia mayor|O|O||D||1|Golondrina
51212009|Saponaria|O|O||D||1|Hierba jabonera, Jabonaria
51212010|Prímula|O|O||D||1|Primaveras
51212011|Pimpinella|O|O||D||1
51212012|Cilantro|O|O||D||1
51212013|Hedera hélix|O|O||D||1|Hieda común
51212014|Goma arábiga|O|O||D||1
51212015|Boneset|O|O||D||1
51212016|Echinacea|O|O||D||1
51212017|Acónito|O|O||D||1
51212018|Coccus cacti|O|O||D||1
51212020|Menta de gato|O|O||D||1|Nébeda
51212021|Ginseng|O|O||D||1|Panax ginseng
51212022|Asafétida|O|O||D||1|Ferula assafoetida
51212023|Arándano|O|O||D||1
51212024|Árnica|O|O||D||1
51212025|Bálsamo del perú|O|O||D||1
51212026|Eufrasia|O|O||D||1
51212027|Ginkgo biloba|O|O||D||1|Árbol de los cuarenta escudos
51212028|Hydrastis|O|O||D||1|Hidrastis
51212029|Gotu kola|O|O||D||1|Centella asiática
51212030|Palma enana americana (saw palmetto)|O|O||D||1|Palmito salvaje
51212031|Pygeum africano|O|O||D||1|Extracto lipofílico de ciruelo africano
51212032|Raíz de angélica|O|O||D||1
51212033|Violeta geneciana|O|O||D||1|Violeta de metilo
51212034|Capsaicina|O|O||D||1|Capsicina
51212035|Leche de cardo|O|O||D||1|Cardo mariano
51212036|Cohosh negro|O|O||D||1|Raíz de culebra negra
51212100|Fármacos dentales|O|O||D||1
51212101|Floruro de sodio|O|O||D||1
51212200|Fármacos contra las adicciones|O|O||D||1
51212201|Disulfiram|O|O||D||1
51212202|Nicotina|O|O||D||1
51212203|Nicotina polacrilina|O|O||D||1
51212204|Vareniclina|O|O||D||1
51212300|Radiofármacos y agentes de diagnóstico|O|O||D||1
51212301|Aminohipurato sódico|O|O||D||1
51212302|Aceite etiodizado|O|O||D||1
51212303|Sodio fluoresceína|O|O||D||1
51212304|Indigotindisulfonato sódico|O|O||D||1
51212305|Indocianina verde|O|O||D||1
51212306|Cloruro de metacolina|O|O||D||1
51212307|Metirapona|O|O||D||1
51212308|Sodio de rosa de bengala i 131|O|O||D||1
51212309|Loxaglato de meglumina|O|O||D||1
51212310|Kit de preparación radio farmacéutica|O|O||D||1
51212311|Iopamidol|O|O||D||1
51212400|Fármacos para tratar la disfunción sexual|O|O||D||1
51212401|Sildenafil citrato|O|O||D||1|Viagra
51212402|Clorhidrato de vardenafil|O|O||D||1
51212403|Dapoxetina|O|O||D||1
51212404|Tadalafil|O|O||D||1|Cialis
51212500|Medio de contraste para imágenes médicas|O|O||D||1
51212501|Diazoato|O|O||D||1
51212502|Iodixanol|O|O||D||1
51212503|Sulfato de bario|O|O||D||1
51212504|Gadolinio|O|O||D||1
51212505|Ioversol|O|O||D||1
51241000|Preparados aurales|O|O||D||1
51241001|Dioctil sulfosuccinato de sodio|O|O||D||1
51241002|Oleato polipéptido de trietanolamina|O|O||D||1
51241100|Agentes oftálmicos|O|O||D||1
51241101|Cloruro acetilcolina|O|O||D||1
51241102|Clorhidrato de apraclonidina|O|O||D||1
51241103|Bimatoprost|O|O||D||1
51241104|Brinzolamida|O|O||D||1
51241105|Carbachol|O|O||D||1|Carbacol, Carbamilcolina
51241106|Demecario bromuro|O|O||D||1
51241107|Dorzolimato clorhidrato|O|O||D||1
51241108|Iodeto de ecotiofato|O|O||D||1|Yoduro de Ecotiofato
51241109|Borato de epinephryl|O|O||D||1
51241110|Latanoprost|O|O||D||1
51241111|Clorhidrato de levobunolol|O|O||D||1
51241112|Metipranolol|O|O||D||1
51241113|Sulfato fisostigmina|O|O||D||1
51241114|Clorhidrato de pilocarpina|O|O||D||1
51241115|Timolol|O|O||D||1
51241116|Travoprost|O|O||D||1
51241117|Isopropil unoprostone|O|O||D||1
51241118|Diclorfenamida|O|O||D||1|Diclofenamida
51241119|Metalzolamida|O|O||D||1
51241120|Lágrimas artificiales|O|O||D||1
51241121|Alcohol polivinílico|O|O||D||1
51241200|Agentes dermatológicos|O|O||D||1
51241201|Ácido salicílico|O|O||D||1|Salix
51241202|Ácido azelaico|O|O||D||1|Ácido nonanodioico
51241203|Subcarbonato de bismuto|O|O||D||1
51241204|Ácido bórico|O|O||D||1|Ácido trioxobórico
51241205|Calamina|O|O||D||1
51241206|Cloroxina|O|O||D||1
51241207|Preparaciones tópicas de brea de hulla|O|O||D||1
51241208|Cremas o ungüentos hidrofilacios|O|O||D||1
51241209|Hidroquinona|O|O||D||1
51241210|Salicilato de metilo|O|O||D||1
51241211|Minoxidil solución tópica|O|O||D||1
51241212|Papaina|O|O||D||1
51241213|Preparación tópica de brea de pino|O|O||D||1
51241214|Podofilox|O|O||D||1
51241215|Resina podofilina|O|O||D||1
51241216|Piritionato de zinc|O|O||D||1
51241217|Resorcinol|O|O||D||1|Benceno-1,3-diol
51241218|Sulfato de selenio|O|O||D||1|Disulfuro de selenio
51241219|Tazaroteno|O|O||D||1
51241220|Tretinoina|O|O||D||1|Ácido holo-transretinoico
51241221|Tripsina cristalizada|O|O||D||1
51241222|Dimeticona|O|O||D||1
51241223|Calcipotriene|O|O||D||1|Calcipotrieno
51241224|Antralina o ditranol|O|O||D||1
51241225|Preparaciones tópicas de alcanfor|O|O||D||1
51241226|Preparaciones tópicas de urea|O|O||D||1
51241227|Preparaciones tópicas de aceite de turpentina|O|O||D||1
51241228|Ácido láctico|O|O||D||1|Lactato
51241229|Solución sustituta de la saliva|O|O||D||1
51241230|Niacinamida|O|O||D||1
51241231|Acitetrina|O|O||D||1
51241232|Isotetrinoina|O|O||D||1
51241233|Adapaleno|O|O||D||1
51241234|Ácido fusídico|O|O||D||1
51241300|Astringentes|O|O||D||1
51241301|Acetato de aluminio|O|O||D||1|Acetato alumínico
51241302|Hamamelis o escoba de bruja|O|O||D||1
51241303|Acetato de zinc|O|O||D||1
51241304|Alumbre de amonio|O|O||D||1
51241305|Ácido tánico|O|O||D||1
51251000|Metabolitos|O|O||D||1
51251001|Butafosfan|O|O||D||1
51251002|Ractopamina|O|O||D||1
52101500|Alfombras y felpudos|O|O||D||1
52101501|Alfombras orientales|O|O||D||1
52101502|Alfombras|O|O||D||1
52101503|Alfombras de lana|O|O||D||1
52101504|Alfombras de algodón|O|O||D||1
52101505|Alfombras sintéticas|O|O||D||1
52101506|Alfombras trenzadas|O|O||D||1
52101507|Tapetes de baño|O|O||D||1
52101508|Tapetes de entrada|O|O||D||1
52101509|Tapetes decorativos|O|O||D||1
52101510|Tapetes anti fatiga|O|O||D||1
52101511|Tapetes de caucho o vinilo|O|O||D||1
52101512|Esterillas para sillas|O|O||D||1|Colchoneta de silla
52101513|Protector de carpetas|O|O||D||1|Protector de alfombra
52101514|Tapetes de fibra de vidrio|O|O||D||1
52101515|Cojín de piso|O|O||D||1
52101516|Alfombra de estera de palma|O|O||D||1|Alfombra de paja
52121500|Ropa de cama|O|O||D||1
52121501|Colchas|O|O||D||1
52121502|Edredones|O|O||D||1
52121503|Forros para edredones|O|O||D||1
52121504|Forros para colchones|O|O||D||1
52121505|Almohadas|O|O||D||1
52121506|Rellenos para colchones|O|O||D||1
52121507|Plumones|O|O||D||1|Colchoneta de plumas
52121508|Cobijas|O|O||D||1
52121509|Sábanas|O|O||D||1
52121510|Volantes de cama|O|O||D||1
52121511|Fundas de edredón|O|O||D||1
52121512|Fundas de almohada|O|O||D||1
52121513|Cobertores|O|O||D||1
52121514|Fundas para asientos|O|O||D||1
52121600|Mantelerías de cocina y mesa y accesorios|O|O||D||1
52121601|Limpiones|O|O||D||1|Paño de cocina
52121602|Servilletas|O|O||D||1
52121603|Tiras de mesa|O|O||D||1|Camino de mesa
52121604|Manteles|O|O||D||1
52121605|Guantes de horno o coge ollas para uso doméstico|O|O||D||1
52121606|Individuales de mesa|O|O||D||1
52121607|Faldas de mesa|O|O||D||1
52121608|Clips para faldas de mesa|O|O||D||1|Pinzas para faldas de mesa
52121700|Toallas|O|O||D||1
52121701|Toallas de baño|O|O||D||1
52121702|Toallas playeras|O|O||D||1
52121703|Paños para lavar|O|O||D||1
52121704|Toallas de manos|O|O||D||1
52121705|Toallas para la cara|O|O||D||1
52131500|Cortinas y ropaje|O|O||D||1
52131501|Cortinas|O|O||D||1
52131503|Colgaduras|O|O||D||1|Colgantes para cortina
52131600|Persianas|O|O||D||1
52131601|Persianas venecianas|O|O||D||1
52131602|Persianas enrollables|O|O||D||1
52131603|Postigos interiores|O|O||D||1
52131604|Persianas verticales|O|O||D||1
52131700|Accesorios y ferretería para tratamiento de ventanas|O|O||D||1
52131701|Cenefas|O|O||D||1
52131702|Varillas para cortinas|O|O||D||1|Barra para cortina
52131703|Remates para varillas|O|O||D||1|Remate para barra de cortina
52131704|Anillos o ganchos para cortinas|O|O||D||1
52131705|Rieles metálicos para cortinas|O|O||D||1
52141500|Electrodomésticos para cocina|O|O||D||1
52141501|Neveras para uso doméstico|O|O||D||1
52141502|Hornos microondas para uso doméstico|O|O||D||1
52141503|Trituradores de basura para uso doméstico|O|O||D||1
52141504|Fogones para uso doméstico|O|O||D||1
52141505|Lavadoras de platos para uso doméstico|O|O||D||1
52141506|Congeladores para uso doméstico|O|O||D||1
52141507|Congeladores verticales para uso doméstico|O|O||D||1
52141508|Congeladores horizontales para uso doméstico|O|O||D||1
52141509|Combinación de neveras y congeladores para uso doméstico|O|O||D||1
52141510|Aire acondicionado portátil para uso doméstico|O|O||D||1
52141511|Exprimidores de jugo para uso doméstico|O|O||D||1
52141512|Planchas para waffles para uso doméstico|O|O||D||1
52141513|Abrelatas eléctricos para uso doméstico|O|O||D||1
52141514|Procesadores de alimentos para uso doméstico|O|O||D||1
52141515|Compactadores de basura para uso doméstico|O|O||D||1
52141516|Freidoras para uso doméstico|O|O||D||1
52141517|Máquinas de maíz pira para uso doméstico|O|O||D||1|Máquinas de palomitas de maíz para uso doméstico
52141518|Máquinas para uso doméstico para hacer pan|O|O||D||1
52141519|Hornos convencionales para uso doméstico|O|O||D||1
52141520|Mezcladoras para uso doméstico|O|O||D||1|Batidoras para uso doméstico
52141521|Hornos tostadores para uso doméstico|O|O||D||1
52141522|Tostadoras para uso doméstico|O|O||D||1
52141523|Teteras eléctricas para uso doméstico|O|O||D||1
52141524|Licuadoras para uso doméstico|O|O||D||1
52141525|Hornillas para uso doméstico|O|O||D||1|Estufa
52141526|Cafeteras para uso doméstico|O|O||D||1
52141527|Cuchillos eléctricos para uso doméstico|O|O||D||1
52141528|Woks eléctricos para uso doméstico|O|O||D||1
52141529|Moledoras de café para uso doméstico|O|O||D||1
52141530|Partes de máquinas lavaplatos|O|O||D||1
52141531|Tajadores de alimentos para uso doméstico|O|O||D||1|Rebanadora
52141532|Sartenes eléctricos para uso doméstico|O|O||D||1
52141533|Planchas eléctricas para uso doméstico|O|O||D||1
52141534|Sandwicheras eléctricas para uso doméstico|O|O||D||1
52141535|Parrillas eléctricas interiores para uso doméstico|O|O||D||1
52141536|Pizelles o máquinas para hacer galletas para uso doméstico|O|O||D||1
52141537|Olla de cocción lenta para uso doméstico|O|O||D||1
52141538|Calienta comidas para uso doméstico|O|O||D||1
52141539|Máquinas para hacer té para uso doméstico|O|O||D||1
52141540|Sellador de bolsas al vacío|O|O||D||1
52141541|Esterilizador de teteros para uso doméstico|O|O||D||1
52141542|Moledor de carne para uso doméstico|O|O||D||1
52141543|Aparato eléctrico para cocinar huevos|O|O||D||1
52141544|Aparato para uso doméstico para diversas formas de cocción|O|O||D||1
52141545|Placa de cocina para uso doméstico|O|O||D||1
52141546|Extractor de cocina para uso doméstico|O|O||D||1
52141547|Triturador o moledor de sal y pimienta para uso doméstico|O|O||D||1
52141548|“Pierrade” para uso doméstico|O|O||D||1|Plancha de piedra para uso doméstico
52141549|“Raclette” para uso doméstico|O|O||D||1|Plancha de acero para uso doméstico
52141550|Máquina para uso doméstico para hacer yogurt|O|O||D||1
52141551|Horno de vapor para uso doméstico|O|O||D||1
52141552|Horno asador para uso doméstico|O|O||D||1
52141553|Olla arrocera eléctrica para uso doméstico|O|O||D||1
52141554|Congelador “kimchi” para uso doméstico|O|O||D||1
52141600|Lavadoras y suministros de uso doméstico|O|O||D||1
52141601|Lavadoras de ropa para uso doméstico|O|O||D||1
52141602|Secadoras de ropa para uso doméstico|O|O||D||1
52141603|Planchas de ropa para uso doméstico|O|O||D||1
52141604|Secadoras de calzado|O|O||D||1
52141605|Canastas de ropa|O|O||D||1
52141606|Cestas de ropa|O|O||D||1
52141607|Compuestos para remover arrugas de los textiles|O|O||D||1
52141608|Plancha de vapor para ropa|O|O||D||1
52141609|Dispositivo para uso doméstico para remover manchas|O|O||D||1
52141610|Gabinete de planchado para uso doméstico|O|O||D||1
52141611|Lavadero|O|O||D||1
52141612|Hidroextractor para la ropa|O|O||D||1
52141700|Aparatos de baño domésticos|O|O||D||1
52141701|Cepillos de dientes eléctricos para uso doméstico|O|O||D||1
52141703|Secadores de pelo para uso doméstico|O|O||D||1
52141704|Máquinas de afeitar eléctricas para uso doméstico|O|O||D||1
52141705|Partes de afeitadoras o removedores de vello|O|O||D||1|Cabezas para rastrillos, Navajas para rastrillos
52141706|Secadores de uñas|O|O||D||1
52141707|Secadores de toallas|O|O||D||1
52141708|Pinzas para rizar el cabello|O|O||D||1
52141800|Otros electrodomésticos|O|O||D||1
52141801|Máquinas de coser para uso doméstico|O|O||D||1
52141802|Calentadores de espacios para uso doméstico|O|O||D||1
52141803|Cobijas eléctricas para uso doméstico|O|O||D||1
52141804|Ventiladores eléctricos para uso doméstico|O|O||D||1
52141805|Biombos plegables|O|O||D||1|Mampara plegable
52141806|Peceras o tanques para peces|O|O||D||1
52141807|Abanicos de mano|O|O||D||1
52151500|Utensilios de cocina desechables domésticos|O|O||D||1
52151501|Utensilios de cocina desechables para uso doméstico|O|O||D||1
52151502|Platos desechables para uso doméstico|O|O||D||1
52151503|Cubiertos desechables para uso doméstico|O|O||D||1
52151504|Tazas o vasos o tapas desechables para uso doméstico|O|O||D||1
52151505|Agitadores desechables para uso doméstico|O|O||D||1
52151506|Contenedores de alimentos desechables para uso doméstico|O|O||D||1
52151507|Pitillos desechables para uso doméstico|O|O||D||1|Popotes desechables para uso doméstico
52151600|Utensilios de cocina domésticos|O|O||D||1
52151601|Rodillos para uso doméstico|O|O||D||1|Rodillos para masa de uso doméstico
52151602|Tazones mezcladores para uso doméstico|O|O||D||1
52151603|Ralladores para uso doméstico|O|O||D||1
52151604|Coladores o coladeras para uso doméstico|O|O||D||1
52151605|Destapadores o abrelatas para uso doméstico|O|O||D||1
52151606|Tablas para cortar para uso doméstico|O|O||D||1
52151607|Tazas medidoras para uso doméstico|O|O||D||1
52151608|Brochas para rociar alimentos|O|O||D||1
52151609|Peladora de vegetales|O|O||D||1|Pelador de vegetales
52151610|Cortadores de galletas|O|O||D||1|Moldes de galletas
52151611|Pinzas de cocina para uso doméstico|O|O||D||1|Tenazas de cocina para uso doméstico
52151612|Batidoras de alambre de cocina para uso doméstico|O|O||D||1|Agitador de alambre de cocina para uso doméstico
52151613|Raspadores de comida para uso doméstico|O|O||D||1|Espátula de comida para uso doméstico
52151614|Rejillas enfriadoras para uso doméstico|O|O||D||1|Rejilla de enfriamiento de alambre para uso doméstico
52151615|Cortadores de pizza para uso doméstico|O|O||D||1
52151616|Espátulas de cocina para uso doméstico|O|O||D||1|Palas de cocina para uso doméstico, Volteador de cocina para uso doméstico
52151617|Cucharas de madera para uso doméstico|O|O||D||1
52151618|Paletas de madera para hornear para uso doméstico|O|O||D||1
52151619|Mezclador de masa para uso doméstico|O|O||D||1
52151620|Cernedor para uso doméstico|O|O||D||1|Colador para uso doméstico
52151621|Estampador para galletas para uso doméstico|O|O||D||1|Selladores domésticos de galletas
52151622|Pistola pastelera para uso doméstico|O|O||D||1
52151623|Prensa para galletas para uso doméstico|O|O||D||1
52151624|Afiladores de cuchillos para uso doméstico|O|O||D||1
52151625|Cortadores de galletas para uso doméstico|O|O||D||1
52151626|Mandolina para uso doméstico|O|O||D||1
52151627|Exprimidor de ajo para uso doméstico|O|O||D||1
52151628|Tajador de huevos para uso doméstico|O|O||D||1|Cortadora de huevos para uso doméstico
52151629|Separador de huevos para uso doméstico|O|O||D||1
52151630|Tajadora de queso para uso doméstico|O|O||D||1|Ralladora de queso para uso doméstico
52151631|Molino de alimentos para uso doméstico|O|O||D||1
52151632|Embudos de cocina para uso doméstico|O|O||D||1
52151633|Herramientas para adobar para uso doméstico|O|O||D||1|Equipo para adobar de uso doméstico
52151634|Descorazonadores de manzanas para uso doméstico|O|O||D||1
52151635|Sacabocados para melón o mantequilla para uso doméstico|O|O||D||1
52151636|Palas o cucharas para alimentos para uso doméstico|O|O||D||1
52151637|Tallador de calabazas para uso doméstico|O|O||D||1
52151638|Cepillo para vegetales para uso doméstico|O|O||D||1
52151639|Batidora de huevos para uso doméstico|O|O||D||1
52151640|Estante para secar pasta para uso doméstico|O|O||D||1
52151641|Batidora de crema para uso doméstico|O|O||D||1
52151642|Prensa para masa para uso doméstico|O|O||D||1|Maquina para hacer tortillas, Tortilladora manual
52151643|Máquina para hacer ravioli para uso doméstico|O|O||D||1|Maquina para hacer ravioles
52151644|Rociadores de rocío o de gatillo para uso doméstico|O|O||D||1
52151645|Pincel pastelero para uso doméstico|O|O||D||1
52151646|Pesas para cocina o dietas para uso doméstico|O|O||D||1|Báscula de cocina
52151647|Relojes (temporizadores) de cocina para uso doméstico|O|O||D||1
52151648|Termómetros de alimentos o cocina para uso doméstico|O|O||D||1
52151649|Guía para tajar pan para uso doméstico|O|O||D||1|Guía para rebanar pan para uso doméstico
52151650|Escurridores para uso doméstico|O|O||D||1
52151651|Cucharas de medida para uso doméstico|O|O||D||1
52151652|Exprimidores de limones|O|O||D||1
52151653|Cuchillos para ostras|O|O||D||1
52151654|Pasapurés para papas|O|O||D||1|Machacador de papas
52151655|Centrifugador de ensaladas|O|O||D||1
52151656|Tajador de aguacates|O|O||D||1|Cortadora de aguacate
52151657|Antorchas culinarias|O|O||D||1|Soplete para cocinar
52151658|Cuchillo para masas|O|O||D||1
52151659|Ablandador de carnes manual|O|O||D||1
52151660|Cuchara para spaghetti|O|O||D||1
52151661|Protector de salpicaduras para botellas|O|O||D||1
52151662|Colador de malla|O|O||D||1
52151663|Mortero para moler alimentos|O|O||D||1|Metate, Molcajete
52151700|Cubertería y cuchillería de uso doméstico|O|O||D||1
52151701|Utensilios para servir para uso doméstico|O|O||D||1
52151702|Cuchillos para uso doméstico|O|O||D||1
52151703|Tenedores para uso doméstico|O|O||D||1
52151704|Cucharas para uso doméstico|O|O||D||1
52151705|Apoya cucharas|O|O||D||1
52151706|Palillos|O|O||D||1
52151707|Set de cuchillos para uso doméstico|O|O||D||1
52151708|Cuchillos para mantequilla|O|O||D||1
52151709|Set de cubiertos|O|O||D||1
52151800|Batería de cocina doméstica|O|O||D||1
52151801|Cacerolas de hierro fundido con tapa para uso doméstico|O|O||D||1
52151802|Sartenes para uso doméstico|O|O||D||1
52151803|Cacerolas para uso doméstico|O|O||D||1
52151804|Teteras para uso doméstico|O|O||D||1
52151805|Woks para uso doméstico|O|O||D||1|Wok chino para uso doméstico
52151806|Vaporeras para uso doméstico|O|O||D||1
52151807|Ollas para uso doméstico|O|O||D||1
52151808|Ollas a presión para uso doméstico|O|O||D||1|Olla exprés para uso doméstico
52151809|Sartenes para sofreír para uso doméstico|O|O||D||1
52151810|Samovares para uso doméstico|O|O||D||1|Tetera rusa para uso doméstico
52151811|Planchas para uso doméstico|O|O||D||1
52151812|Cacerolas para baño maría|O|O||D||1
52151813|Protector de salpicaduras para uso doméstico|O|O||D||1
52151900|Utensilios para hornear domésticos|O|O||D||1
52151901|Moldes para muffins para uso doméstico|O|O||D||1
52151902|Cacerola para hornear para uso doméstico|O|O||D||1
52151903|Moldes para ponqués o pies para uso doméstico|O|O||D||1|Moldes para panqué o pay para uso doméstico
52151904|Moldes para asar para uso doméstico|O|O||D||1
52151905|Bandejas de horno para uso doméstico|O|O||D||1
52151906|Cacerolas para parrilla para uso doméstico|O|O||D||1
52151907|Moldes para hornear para uso doméstico|O|O||D||1
52151908|Cacerolas para pizza para uso doméstico|O|O||D||1
52151909|Cacerolas para hacer tortillas para uso doméstico|O|O||D||1
52152000|Platos, utensilios para servir y recipientes para almacenar|O|O||D||1|Biberones o mamilas para bebé
52152001|Jarras para uso doméstico|O|O||D||1
52152002|Contenedores para almacenar alimentos para uso doméstico|O|O||D||1
52152003|Tazones de ponche para uso doméstico|O|O||D||1|Jarros de ponche para uso doméstico
52152004|Platos para uso doméstico|O|O||D||1
52152005|Platos pequeños para uso doméstico|O|O||D||1
52152006|Bandejas o fuentes para uso doméstico|O|O||D||1
52152007|Tazones para servir para uso doméstico|O|O||D||1
52152008|Teteras o cafeteras para uso doméstico|O|O||D||1
52152009|Soperas o ensaladeras para uso doméstico|O|O||D||1
52152010|Frascos al vacío para uso doméstico|O|O||D||1
52152011|Partes internas de frascos al vacío|O|O||D||1
52152012|Cubetas para hielo|O|O||D||1|Charola para cubos de hielo
52152013|Saleros, pimenteros o especieros|O|O||D||1
52152014|Sets de garrafas|O|O||D||1
52152015|Plato para ponqués con tapa para uso doméstico|O|O||D||1|Plato de pastel con tapa para uso doméstico
52152016|Set de servicio de mesa para uso doméstico|O|O||D||1
52152017|Arca de madera para guardar arroz|O|O||D||1|Caja de madera para almacenamiento de arroz
52152018|Loncheras|O|O||D||1
52152100|Cristalería de uso doméstico|O|O||D||1
52152101|Tazas de café o té para uso doméstico|O|O||D||1
52152102|Vasos para beber para uso doméstico|O|O||D||1
52152103|Tazones (“mugs”) para uso doméstico|O|O||D||1
52152104|Copas para uso doméstico|O|O||D||1
52152200|Lavado de platos y accesorios de almacenamiento de platos|O|O||D||1
52152201|Papel para forrar repisas|O|O||D||1
52152202|Escurridor de platos|O|O||D||1
52152203|Cepillo dispensador de jabón|O|O||D||1
52152204|Mesa para preparar alimentos|O|O||D||1
52152300|Suministros de cocina doméstica|O|O||D||1
52152301|Líquido limpiador de hornos para uso doméstico|O|O||D||1
52161500|Equipos audiovisuales|O|O||D||1
52161502|Reproductor de casetes o grabadora|O|O||D||1
52161505|Televisores|O|O||D||1
52161507|Radios reloj|O|O||D||1
52161508|Reproductores de discos laser|O|O||D||1
52161509|Sistemas de estéreo portátiles|O|O||D||1
52161510|Sistemas de audio de alta fidelidad para el hogar|O|O||D||1
52161511|Radios|O|O||D||1
52161512|Altoparlantes|O|O||D||1|Altavoz
52161513|Combinación de televisor, vhs y grabadora dvd|O|O||D||1
52161514|Audífonos|O|O||D||1
52161515|Reproductores o grabadoras de discos compactos|O|O||D||1
52161516|Reproductores o grabadoras de video discos digitales|O|O||D||1
52161517|Ecualizadores|O|O||D||1
52161518|Receptores de sistemas de posicionamiento global|O|O||D||1
52161520|Micrófonos|O|O||D||1
52161521|Receptores de multimedia|O|O||D||1
52161522|Escáneres de radio frecuencia|O|O||D||1
52161523|Transmisores o receptores de radio frecuencia|O|O||D||1
52161524|Receptores de radio|O|O||D||1
52161525|Control remoto|O|O||D||1
52161526|Receptores de satélite|O|O||D||1
52161527|Altavoces activos “subwoofer””|O|O||D||1
52161529|Reproductores o grabadoras de video casetes|O|O||D||1
52161531|Radio fonógrafos|O|O||D||1
52161532|Sistemas de karaoke|O|O||D||1
52161533|Megáfonos|O|O||D||1
52161534|Grabadora de chip de circuito integrado ic|O|O||D||1
52161535|Grabadoras de voz digitales|O|O||D||1
52161536|Grabadoras o reproductores de mini discos|O|O||D||1
52161537|Borradores magnéticos de almacenamiento de medios|O|O||D||1
52161538|Aparatos para rebobinar video cintas|O|O||D||1
52161539|Combinación de reproductor de video disco digital dvd, disco video casete vcd, disco compacto cd|O|O||D||1
52161540|Mezcladores de video|O|O||D||1
52161541|Mezcladores de audio|O|O||D||1
52161542|Pantallas de plasma|O|O||D||1
52161543|Reproductores o grabadoras mp3|O|O||D||1
52161544|Borradores de casetes de audio o video|O|O||D||1
52161545|Grabadoras de video digital|O|O||D||1
52161546|Sintonizadores de televisión|O|O||D||1
52161547|Amplificadores de audio|O|O||D||1
52161548|Consola de audio|O|O||D||1
52161549|Marco para fotografías digitales|O|O||D||1
52161550|Video grabadora personal pvr|O|O||D||1
52161551|Micrófono inalámbrico y sistema de amplificación de instrumentos|O|O||D||1
52161552|Receptor de luz|O|O||D||1
52161553|Reproductor o grabadora de video disco blu ray|O|O||D||1
52161554|Audífono|O|O||D||1|Manos libres
52161555|Set combinado portátil de video multimedia|O|O||D||1
52161556|Distribuidor de video|O|O||D||1
52161557|Consola fija de juegos de computador|O|O||D||1
52161558|Consola portátil de juegos de computador|O|O||D||1
52161559|Gafas tridimensionales 3d para uso con televisores en 3d y computadoras equipadas con gráficos en 3d|O|O||D||1
52161560|Sistema de cine en casa|O|O||D||1
52161600|Accesorios de equipo audiovisual|O|O||D||1
52161601|Almacenador de casetes|O|O||D||1
52161602|Limpiadores de cabezas de audio o video|O|O||D||1
52161603|Adaptador de video casetes compactos|O|O||D||1
52161604|Adaptadores de enchufes hembra de audífonos|O|O||D||1
52161605|Accesorios para reproductores portátiles de medios|O|O||D||1
52161606|Estuches o cubiertas para altavoces|O|O||D||1
52161607|Dispositivo para almacenar discos de vinilo|O|O||D||1
52161608|Caja divisora (“splitter”) scart|O|O||D||1
52161609|Amplificador de señal de discos de vinilo|O|O||D||1
52161610|Soporte para parlantes|O|O||D||1
52161611|Soporte para micrófonos|O|O||D||1
52171000|Tratamientos de pared de baño|O|O||D||1
52171001|Repisa u organizador colgante para elementos de aseo personal|O|O||D||1
52171002|Espejo para baño|O|O||D||1
53101500|Pantalones de deporte, pantalones y pantalones cortos|O|O||D||1|Prendas de vestir
53101501|Pantalones largos o cortos o pantalonetas para niño|O|O||D||1|Pants, pantalones y shorts para niño
53101502|Pantalones largos o cortos o pantalonetas para hombre|O|O||D||1|Pants, pantalones y shorts para hombre
53101503|Pantalones largos o cortos o pantalonetas para niña|O|O||D||1|Pants, pantalones y shorts para niña
53101504|Pantalones largos o cortos o pantalonetas para mujer|O|O||D||1|Pants, pantalones y shorts para mujer
53101505|Pantalones largos o cortos o pantalonetas para bebés|O|O||D||1|Pants, pantalones y shorts para bebés
53101600|Faldas y blusas|O|O||D||1|Prendas de vestir
53101601|Camisas para niño|O|O||D||1|Playeras para niño
53101602|Camisas para hombre|O|O||D||1|Playeras para hombre
53101603|Camisas o blusas para niña|O|O||D||1|Playeras para niña
53101604|Camisas o blusas para mujer|O|O||D||1|Playeras para mujer
53101605|Camisas o blusas para bebé|O|O||D||1|Playeras para bebé
53101700|Suéteres|O|O||D||1|Prendas de vestir
53101701|Sweaters para niño|O|O||D||1|Suéteres para niño
53101702|Sweaters para hombre|O|O||D||1|Suéteres para hombre
53101703|Sweaters para niña|O|O||D||1|Suéteres para niña
53101704|Sweaters para mujer|O|O||D||1|Suéteres para mujer
53101705|Sweaters para bebé|O|O||D||1|Suéteres para bebé
53101800|Abrigos y chaquetas|O|O||D||1|Prendas de vestir
53101801|Abrigos o chaquetas para niño|O|O||D||1|Chamarras para niño
53101802|Abrigos o chaquetas para hombre|O|O||D||1|Chamarras para hombre
53101803|Abrigos o chaquetas para niña|O|O||D||1|Chamarras para niña
53101804|Abrigos o chaquetas para mujer|O|O||D||1|Chamarras para mujer
53101805|Abrigos o chaquetas para bebé|O|O||D||1|Chamarras para bebé
53101900|Trajes|O|O||D||1|Prendas de vestir
53101901|Trajes para niño|O|O||D||1
53101902|Trajes para hombre|O|O||D||1
53101903|Trajes para niña|O|O||D||1
53101904|Trajes para mujer|O|O||D||1
53101905|Trajes para bebé|O|O||D||1
53102000|Vestidos, faldas, saris y kimonos|O|O||D||1|Prendas de vestir
53102001|Vestidos o faldas o saris o kimonos para niña|O|O||D||1
53102002|Vestidos o faldas o saris o kimonos para para mujer|O|O||D||1
53102003|Vestidos o faldas o saris o kimonos para bebé|O|O||D||1
53102100|Batas y monos|O|O||D||1|Prendas de vestir
53102101|Overoles o monos para niño|O|O||D||1
53102102|Overoles o monos para hombre|O|O||D||1
53102103|Overoles o monos para niña|O|O||D||1
53102104|Overoles o monos para mujer|O|O||D||1
53102105|Overoles o monos para bebé|O|O||D||1
53102200|Ropa folclórica|O|O||D||1|Prendas de vestir
53102201|Vestidos folclóricos para niño|O|O||D||1
53102202|Vestidos folclóricos para hombre|O|O||D||1
53102203|Vestidos folclóricos para niña|O|O||D||1
53102204|Vestidos folclóricos para mujer|O|O||D||1
53102205|Vestidos folclóricos para bebé|O|O||D||1
53102300|Ropa interior|O|O||D||1|Prendas de vestir
53102301|Camisetas interiores|O|O||D||1
53102302|Combinaciones|O|O||D||1|Braslis o trusa
53102303|Calzoncillos|O|O||D||1
53102304|Brassieres|O|O||D||1
53102305|Pañales para bebé|O|O||D||1
53102306|Pañales para adulto|O|O||D||1
53102307|Prendas para dar forma al cuerpo|O|O||D||1|Fajas para cuerpo
53102308|Forros para pañales|O|O||D||1
53102309|Rellenos para busto|O|O||D||1
53102310|Forros para rellenos para busto|O|O||D||1
53102400|Medias y calcetines|O|O||D||1|Prendas de vestir
53102401|Medias largas|O|O||D||1
53102402|Calcetines|O|O||D||1
53102403|Medias veladas|O|O||D||1
53102404|Medias veladas gruesas (“tights”)|O|O||D||1
53102500|Accesorios de vestir|O|O||D||1|Prendas de vestir
53102501|Cinturones o tirantes|O|O||D||1
53102502|Corbatas o pañoletas o bufandas|O|O||D||1
53102503|Sombreros|O|O||D||1
53102504|Guantes o mitones|O|O||D||1
53102505|Sombrillas|O|O||D||1
53102506|Bandas para el sudor|O|O||D||1
53102507|Ganchos para colgar la ropa|O|O||D||1
53102508|Bandas para los brazos|O|O||D||1
53102509|Ligas|O|O||D||1
53102510|Borlas|O|O||D||1
53102511|Badanas|O|O||D||1|Pañuelo para la cabeza
53102512|Pañuelos|O|O||D||1
53102513|Bandas para la cabeza|O|O||D||1
53102514|Protectores de bolsillos|O|O||D||1
53102515|Forros para botones|O|O||D||1
53102516|Gorras|O|O||D||1
53102517|Sujeta corbatas|O|O||D||1
53102518|Cheurones|O|O||D||1|Chevron
53102519|Golas|O|O||D||1|Bufandas con gorros o pecheras
53102520|Hombreras o charreteras|O|O||D||1
53102600|Ropa de dormir|O|O||D||1|Prendas de vestir
53102601|Pijamas o camisas de dormir o batas para niño|O|O||D||1
53102602|Pijamas o camisas de dormir o batas para hombre|O|O||D||1
53102603|Pijamas o camisas de dormir o batas para niña|O|O||D||1
53102604|Pijamas o camisas de dormir o batas para mujer|O|O||D||1
53102605|Pijamas o camisas de dormir o batas para bebé|O|O||D||1
53102606|Batas de baño|O|O||D||1
53102700|Uniformes|O|O||D||1|Prendas de vestir
53102701|Uniformes militares|O|O||D||1|Trajes militares
53102702|Uniformes de agentes de aduna|O|O||D||1|Trajes para agentes aduanales
53102703|Uniformes de policías|O|O||D||1|Trajes de policías
53102704|Uniformes institucionales para preparación de alimentos o servicio|O|O||D||1
53102705|Uniformes de colegio|O|O||D||1
53102706|Uniformes de personal de seguridad|O|O||D||1
53102707|Batas de doctor|O|O||D||1
53102708|Uniformes de enfermera|O|O||D||1
53102709|Uniformes de personal de ambulancias|O|O||D||1
53102710|Uniformes corporativos|O|O||D||1
53102711|Batas para personal de peluquerías|O|O||D||1
53102712|Uniformes de paramédicos|O|O||D||1
53102713|Uniformes de acomodadores|O|O||D||1
53102714|Togas judiciales|O|O||D||1
53102715|Uniformes de oficiales de cárceles|O|O||D||1
53102716|Uniformes de presos|O|O||D||1
53102800|Trajes de baño|O|O||D||1|Prendas de vestir
53102801|Vestidos de baño para hombre|O|O||D||1|Trajes de baño para hombre
53102802|Vestidos de baño para mujer|O|O||D||1|Trajes de baño para mujer
53102803|Vestidos de baño para niño|O|O||D||1|Trajes de baño para niño
53102804|Vestidos de baño para niña|O|O||D||1|Trajes de baño para niña
53102805|Vestidos de baño para bebé|O|O||D||1|Trajes de baño para bebé
53102900|Prendas de deporte|O|O||D||1|Prendas de vestir
53102901|Ropa atlética para mujer|O|O||D||1|Ropa deportiva para mujer
53102902|Ropa atlética para hombre|O|O||D||1|Ropa deportiva para hombre
53102903|Ropa atlética para niño|O|O||D||1|Ropa deportiva para niño
53102904|Ropa atlética para niña|O|O||D||1|Ropa deportiva para niña
53103000|Camisetas|O|O||D||1|Prendas de vestir
53103001|Camisetas (t-shirts) para hombre|O|O||D||1
53103100|Chalecos|O|O||D||1|Prendas de vestir
53103101|Chalecos para hombre|O|O||D||1
53103200|Ropas desechables|O|O||D||1|Prendas de vestir
53103201|Bata de trabajo desechable|O|O||D||1
53111500|Botas|O|O||D||1
53111501|Botas para hombre|O|O||D||1
53111502|Botas para mujer|O|O||D||1
53111503|Botas para niño|O|O||D||1
53111504|Botas para niña|O|O||D||1
53111505|Botas para bebé|O|O||D||1
53111600|Zapatos|O|O||D||1
53111601|Zapatos para hombre|O|O||D||1
53111602|Zapatos para mujer|O|O||D||1
53111603|Zapatos para niño|O|O||D||1
53111604|Zapatos para niña|O|O||D||1
53111605|Zapatos para bebé|O|O||D||1
53111700|Zapatillas|O|O||D||1
53111701|Pantuflas para hombre|O|O||D||1
53111702|Pantuflas para mujer|O|O||D||1
53111703|Pantuflas para niño|O|O||D||1
53111704|Pantuflas para niña|O|O||D||1
53111705|Pantuflas para bebé|O|O||D||1
53111800|Sandalias|O|O||D||1
53111801|Sandalias para hombre|O|O||D||1
53111802|Sandalias para mujer|O|O||D||1
53111803|Sandalias para niño|O|O||D||1
53111804|Sandalias para niña|O|O||D||1
53111805|Sandalias para bebé|O|O||D||1
53111900|Calzado deportivo|O|O||D||1
53111901|Calzado atlético para hombre|O|O||D||1|Calzado deportivo para hombre
53111902|Calzado atlético para mujer|O|O||D||1|Calzado deportivo para mujer
53111903|Calzado atlético para niño|O|O||D||1|Calzado deportivo para niño
53111904|Calzado atlético para niña|O|O||D||1|Calzado deportivo para niña
53111905|Calzado atlético para bebé|O|O||D||1|Calzado deportivo para bebé
53112000|Accesorios para el calzado|O|O||D||1
53112001|Calzadores|O|O||D||1
53112002|Cordones para zapatos|O|O||D||1|Agujetas para zapatos
53112003|Almohadillas para talones|O|O||D||1
53112004|Estirador de calzado|O|O||D||1
53112005|Aparato para medir el pie|O|O||D||1
53112100|Chanclos|O|O||D||1|Choclo
53112101|Zapatones para hombre|O|O||D||1|Choclo para hombre
53112102|Zapatones para mujer|O|O||D||1|Choclo para mujer
53112103|Zapatones para niño|O|O||D||1|Choclo para niño
53112104|Zapatones para niña|O|O||D||1|Choclo para niña
53112105|Zapatones para bebé|O|O||D||1|Choclo para bebé
53121500|Maletas|O|O||D||1
53121501|Porta trajes|O|O||D||1
53121502|Sets de maletas|O|O||D||1
53121503|Piezas individuales de maletas|O|O||D||1
53121600|Monederos, bolsos de mano y bolsas|O|O||D||1
53121601|Bolsos o carteras|O|O||D||1
53121602|Tulas|O|O||D||1
53121603|Morrales|O|O||D||1
53121605|Monederos|O|O||D||1
53121606|Estuches para labiales|O|O||D||1
53121607|Cigarrilleras|O|O||D||1
53121608|Bolsas para compras|O|O||D||1
53121700|Carteras|O|O||D||1
53121701|Maletines|O|O||D||1
53121702|Maletines (“attaches”)|O|O||D||1
53121704|Portafolios|O|O||D||1
53121705|Estuches para equipos|O|O||D||1
53121706|Maletines para computador|O|O||D||1
53121800|Juegos y accesorios de viaje|O|O||D||1
53121801|Kits de viaje|O|O||D||1
53121802|Carritos de viaje|O|O||D||1
53121803|Cepillos de ropa|O|O||D||1
53121804|Estuches de maquillaje o manicure|O|O||D||1
53131500|Dentales|O|O||D||1
53131501|Enjuague bucal|O|O||D||1
53131502|Dentífrico|O|O||D||1|Pasta de dientes, Pasta dental, Pasta para diente
53131503|Cepillos de dientes|O|O||D||1
53131504|Seda dental|O|O||D||1|Hilo dental
53131505|Chupos o chupetes para bebé|O|O||D||1|Chupones para bebé
53131506|Kits dentales|O|O||D||1
53131507|Palillos de dientes (mondadientes)|O|O||D||1
53131508|Tabletas para limpiar dentaduras postizas|O|O||D||1
53131509|Refrescadores de aliento|O|O||D||1|Refrescantes para boca
53131510|Pegante para dentaduras postizas|O|O||D||1|Adhesivo de dentadura, Pegamento para dentaduras postizas
53131600|Baño y cuerpo|O|O||D||1
53131601|Gorros de baño|O|O||D||1
53131602|Artículos para el cuidado del cabello|O|O||D||1|Acondicionadores, Cremas para peinar, Desenredadores, Gel, Mouse, Spray
53131603|Afeitadoras|O|O||D||1|Rastrillos
53131604|Cepillos o peinillas para el cabello|O|O||D||1|Peines para el cabello
53131605|Kits de tocador|O|O||D||1
53131606|Desodorantes|O|O||D||1
53131607|Lociones o aceites para manos o cuerpo|O|O||D||1
53131608|Jabones|O|O||D||1
53131609|Productos de protección solar|O|O||D||1
53131610|Artículos para el cuidado de los ojos|O|O||D||1
53131611|Cremas de afeitar|O|O||D||1
53131612|Geles de baño|O|O||D||1
53131613|Productos para el cuidado de la piel|O|O||D||1|Bloqueadores solares, Cremas, Exfoliantes, Lociones corporales, Zacate o mallas para baño
53131614|Productos para el cuidado de los pies|O|O||D||1|Talcos
53131615|Productos para la higiene femenina|O|O||D||1|Desodorantes, Jabones, Tampones, Toallas sanitarias ,
53131616|Cremas o lociones para farmacéuticas|O|O||D||1
53131617|Implementos para la manicure|O|O||D||1
53131618|Implementos para la pedicura|O|O||D||1
53131619|Cosméticos|O|O||D||1
53131620|Perfumes o colonias o fragancias|O|O||D||1
53131621|Corta uñas|O|O||D||1
53131622|Condones|O|O||D||1|Preservativos
53131623|Productos depilatorios o para remover vello|O|O||D||1
53131624|Paños limpiadores desechables|O|O||D||1
53131625|Redecillas para el cabello o la barba|O|O||D||1
53131626|Desinfectante de manos|O|O||D||1|Gel antibacterial para manos
53131627|Limpiador de manos|O|O||D||1
53131628|Champús|O|O||D||1|Shampoo
53131629|Kits de maquillaje|O|O||D||1
53131630|Bálsamo labial|O|O||D||1
53131631|Tatuajes|O|O||D||1
53131632|Marrones calientes|O|O||D||1|Tubos calientes para cabello
53131633|Hebillas para el pelo|O|O||D||1|Broches para el cabello, Pasadores para el cabello
53131634|Productos químicos protectores|O|O||D||1
53131635|Brochas de afeitar|O|O||D||1
53131636|Agua de rosas|O|O||D||1
53131637|Almohadillas de lactancia|O|O||D||1
53131638|Esmalte para uñas|O|O||D||1
53131639|Protectores para incontinencia urinaria|O|O||D||1
53131640|Removedor de esmalte|O|O||D||1|Acetona para las uñas
53131641|Gelatina de petróleo|O|O||D||1|Vaselina
53131642|Bata o capa para cortar el pelo para barberías o peluquerías|O|O||D||1
53131643|Cortador de pelo eléctrico|O|O||D||1|Rasuradora eléctricas para cabello
53131644|Aceites esenciales de aromaterapia|O|O||D||1
53131645|Instrumento o pistola para perforar el lóbulo de la oreja|O|O||D||1
53131646|Removedor de espinillas|O|O||D||1
53131647|Set de higiene y cuidado personal de bebés|O|O||D||1|Talcos para bebé
53131700|Equipo para masaje terapéutico|O|O||D||1
53131701|Unidad masajeadora manual|O|O||D||1
53131702|Máquina masajeadora|O|O||D||1
53131800|Accesorios y materiales para equipo de tatuajes|O|O||D||1
53131801|Tinta para tatuajes|O|O||D||1
53131802|Aguja para tatuajes|O|O||D||1
53141500|Afianzadores de costura|O|O||D||1|Artículos de mercería
53141501|Alfileres rectos|O|O||D||1
53141502|Imperdibles|O|O||D||1|Seguritos, Seguros para ropa
53141503|Cremalleras|O|O||D||1|Cierres
53141504|Hebillas|O|O||D||1
53141505|Botones|O|O||D||1
53141506|Cierres|O|O||D||1|Cierres o broches de presión
53141507|Broches|O|O||D||1
53141508|Remaches para ropa|O|O||D||1
53141600|Suministros de costura variados|O|O||D||1|Artículos de mercería
53141601|Alfileteros|O|O||D||1
53141602|Kits de costura|O|O||D||1
53141603|Dedales|O|O||D||1
53141604|Patrones de costura|O|O||D||1
53141605|Agujas de costura|O|O||D||1
53141606|Bobinas o sujeta bobinas|O|O||D||1
53141607|Indicadores de costura|O|O||D||1
53141608|Aguja pasa cintas|O|O||D||1
53141609|Pasa presillas|O|O||D||1
53141610|Sujetadores de tiza para sastres o textiles|O|O||D||1
53141611|Marcadores de textiles o lápices para textiles o tiza para textiles|O|O||D||1
53141612|Rueda aserrada seguidora de patrones|O|O||D||1
53141613|Papel calcante|O|O||D||1|Papel transfer para estampar
53141614|Agujas de bordado|O|O||D||1
53141615|Agujas de tejer|O|O||D||1
53141616|Lanzaderas para telares|O|O||D||1
53141617|Lanzaderas para tejidos de algodón|O|O||D||1
53141618|Lienzo para bordar|O|O||D||1|Telas para bordar
53141619|Varas magnéticas|O|O||D||1
53141620|Corta costuras|O|O||D||1
53141621|Enhebrador de agujas|O|O||D||1
53141622|Regla para sastrería|O|O||D||1
53141623|Refuerzo o cerrado líquido para hilo|O|O||D||1
53141624|Textiles o agujas para punto de cruz|O|O||D||1
53141625|Diseños para punto de cruz|O|O||D||1
53141626|Aro para bordado|O|O||D||1
53141627|Agujas de croché|O|O||D||1
53141628|Herramientas para hilvanar acolchados|O|O||D||1
53141629|Alfileres para acolchados|O|O||D||1
53141630|Tableros o almohadillas para cortar patrones|O|O||D||1
54101500|Joyería fina|O|O||D||1
54101501|Cadenas de oro o plata o platino|O|O||D||1
54101502|Collares de joyería fina|O|O||D||1
54101503|Anillos de  joyería fina|O|O||D||1
54101504|Aretes de joyería fina|O|O||D||1
54101505|Joyas finas para el cuerpo|O|O||D||1
54101506|Brazaletes de joyería fina|O|O||D||1
54101507|Tiaras|O|O||D||1
54101508|Revestimientos de joyería fina para reducir el tamaño de un anillo|O|O||D||1
54101509|Mancornas de joyería fina|O|O||D||1
54101510|Mariposas para aretes de joyería fina|O|O||D||1
54101511|Prendedores de joyería fina|O|O||D||1
54101512|Aros de prendedores para pasar cadenas de joyería fina|O|O||D||1
54101513|Pisacorbatas|O|O||D||1
54101600|Bisutería|O|O||D||1
54101601|Brazaletes|O|O||D||1
54101602|Collares|O|O||D||1
54101603|Anillos|O|O||D||1
54101604|Aretes|O|O||D||1
54101605|Joyas para el cuerpo|O|O||D||1
54101700|Herramientas y materiales de joyería|O|O||D||1
54101701|Compuestos conservantes|O|O||D||1
54101702|Bloques para producir hemisferios (“dapping punches”)|O|O||D||1
54101703|Molinos de alambre|O|O||D||1
54101704|Mandriles para joyería|O|O||D||1
54101705|Medidores de tamaño para anillos|O|O||D||1
54101706|Materiales o accesorios plásticos amigables maleables a bajas temperaturas|O|O||D||1
54111500|Relojes de pulsera o bolsillo|O|O||D||1
54111501|Relojes de pulso|O|O||D||1
54111502|Relojes de bolsillo|O|O||D||1
54111503|Relojes cronómetros|O|O||D||1
54111504|Cronómetros marinos|O|O||D||1
54111505|Relojes para bucear|O|O||D||1
54111600|Relojes de pared o de mesa|O|O||D||1
54111601|Relojes de pared|O|O||D||1
54111602|Relojes de mesa o repisa|O|O||D||1
54111603|Relojes verticales|O|O||D||1
54111604|Relojes de arena|O|O||D||1
54111605|Relojes maestros electrónicos|O|O||D||1
54111606|Relojes esclavos electrónicos|O|O||D||1
54111700|Piezas de relojes de pulsera o de pared o pie o accesorios|O|O||D||1
54111701|Manecillas para reloj|O|O||D||1
54111702|Cristales para reloj|O|O||D||1
54111703|Placas o puentes para relojes|O|O||D||1
54111704|Correas o bandas o pulseras para relojes|O|O||D||1
54111705|Estuches para relojes|O|O||D||1
54111706|Sujetadores para relojes|O|O||D||1
54111707|Abre estuches para relojes|O|O||D||1
54111708|Péndulos para relojes|O|O||D||1
54111709|Kits para reparar relojes|O|O||D||1
54121500|Piedras preciosas|O|O||D||1
54121501|Diamantes|O|O||D||1
54121502|Esmeraldas|O|O||D||1
54121503|Rubíes|O|O||D||1
54121504|Zafiros|O|O||D||1
54121600|Piedras semipreciosas|O|O||D||1
54121601|Granates|O|O||D||1
54121602|Jades|O|O||D||1
54121603|Ópalos|O|O||D||1
54121700|Perlas|O|O||D||1
54121701|Perlas cultivadas|O|O||D||1
54121702|Perlas naturales|O|O||D||1
54121800|Piedras preciosas o semipreciosas industriales|O|O||D||1
54121801|Diamantes industriales|O|O||D||1
54121802|Granates industriales|O|O||D||1
55101500|Publicaciones impresas|O|O||D||1
55101501|Cartas de navegación o atlas o mapas|O|O||D||1
55101502|Directorios|O|O||D||1
55101503|Catálogos|O|O||D||1
55101504|Periódicos|O|O||D||1
55101505|Historietas cómicas|O|O||D||1
55101506|Revistas|O|O||D||1
55101507|Libros para pintar o colorear o ilustrar para niños|O|O||D||1
55101509|Textos educacionales o vocacionales|O|O||D||1
55101510|Libros para entretenimiento|O|O||D||1
55101513|Tarjetas para intercambiar|O|O||D||1
55101514|Partituras|O|O||D||1|Libro de notas musicales
55101515|Material promocional o reportes anuales|O|O||D||1
55101516|Manuales operativos o de instrucciones|O|O||D||1
55101517|Dibujos dimensionales o de tolerancia|O|O||D||1
55101518|Diagramas o dibujos técnicos|O|O||D||1
55101519|Publicaciones periódicas|O|O||D||1
55101520|Hojas o folletos de instrucciones|O|O||D||1
55101521|Manuales de propietario o usuario|O|O||D||1
55101522|Globos terrestres o celestes|O|O||D||1
55101523|Libros de ejercicios|O|O||D||1
55101524|Libros de referencia|O|O||D||1
55101525|Enciclopedias|O|O||D||1
55101526|Diccionarios|O|O||D||1
55101527|Cancioneros|O|O||D||1
55101528|Libros religiosos|O|O||D||1
55101529|Chequeras o libretas de cuentas|O|O||D||1
55101530|Libros de códigos|O|O||D||1
55101531|Códigos (legales)|O|O||D||1
55101532|Álbumes de graduación o anuarios|O|O||D||1
55111500|Publicaciones electrónicas y música|O|O||D||1
55111501|Directorios electrónicos|O|O||D||1
55111502|Diccionarios electrónicos|O|O||D||1
55111503|Enciclopedias electrónicas|O|O||D||1
55111504|Catálogos electrónicos|O|O||D||1
55111505|Libros en cintas o en discos compactos|O|O||D||1
55111506|Revistas electrónicas|O|O||D||1
55111507|Periódicos electrónicos|O|O||D||1
55111508|Cartas de navegación o mapas o atlas electrónicos|O|O||D||1
55111509|Música de fondo|O|O||D||1
55111510|Películas de cine en celuloide|O|O||D||1
55111511|Películas de cine en video cinta|O|O||D||1
55111512|Música en cintas o discos compactos|O|O||D||1
55111513|Textos electrónicos educacionales o vocacionales|O|O||D||1
55111514|Películas de cine en discos de video digital dvd|O|O||D||1
55111515|Audio cinta de material educacional|O|O||D||1
55111600|Material de referencia de software electrónico|O|O||D||1
55111601|Documentación de software o manuales de usuario electrónicos|O|O||D||1
55121500|Rótulos|O|O||D||1
55121501|Etiquetas para el equipaje|O|O||D||1
55121502|Etiquetas de seguridad|O|O||D||1
55121503|Etiquetas de identificación|O|O||D||1
55121504|Etiquetas para llaves|O|O||D||1
55121505|Porta etiquetas o accesorios|O|O||D||1
55121506|Etiquetas de precio|O|O||D||1
55121507|Etiquetas de bolsas de té o café|O|O||D||1
55121600|Etiquetas|O|O||D||1
55121601|Kits para remover etiquetas|O|O||D||1
55121602|Etiquetas para ropa|O|O||D||1
55121604|Etiquetas para latas o botellas|O|O||D||1
55121605|Etiquetas de direcciones o de correo|O|O||D||1
55121606|Etiquetas auto adhesivas|O|O||D||1
55121607|Calcomanías|O|O||D||1
55121608|Etiquetas de códigos de barra|O|O||D||1
55121609|Etiquetas para paquetes|O|O||D||1
55121610|Etiquetas numeradas consecutivamente|O|O||D||1
55121611|Cintas para hacer etiquetas|O|O||D||1
55121612|Etiquetas para impresoras|O|O||D||1
55121613|Etiquetas de códigos de color|O|O||D||1
55121614|Etiquetas removibles|O|O||D||1
55121615|Puntos o flechas adhesivas|O|O||D||1
55121616|Banderas auto adhesivas|O|O||D||1
55121617|Protectores de etiquetas|O|O||D||1
55121618|Porta etiquetas|O|O||D||1
55121619|Etiquetas no adhesivas|O|O||D||1
55121620|Etiquetas multipropósito|O|O||D||1
55121621|Sellos notariales|O|O||D||1
55121622|Etiquetas criogénicas|O|O||D||1
55121700|Señalización|O|O||D||1
55121701|Placas con inscripción metálicas|O|O||D||1
55121702|Placas con inscripción no metálicas|O|O||D||1
55121703|Señales iluminadas|O|O||D||1
55121704|Señales de seguridad|O|O||D||1
55121705|Señales auto adhesivas|O|O||D||1
55121706|Pancartas|O|O||D||1
55121707|Señales magnéticas|O|O||D||1
55121708|Señales de neón|O|O||D||1
55121710|Signos de tráfico|O|O||D||1
55121712|Señales direccionales|O|O||D||1
55121713|Señales de punto de venta|O|O||D||1
55121714|Pendones|O|O||D||1
55121715|Banderas o accesorios|O|O||D||1
55121716|Señales de madera|O|O||D||1
55121717|Placas de identificación de máquinas|O|O||D||1
55121718|Señales informativas|O|O||D||1
55121719|Componentes de señalización|O|O||D||1
55121720|Emblemas|O|O||D||1
55121721|Caracteres de señalización|O|O||D||1
55121725|Kits de señalización|O|O||D||1
55121726|Paneles de identificación|O|O||D||1
55121728|Cubiertas de señales|O|O||D||1
55121729|Indicadores|O|O||D||1
55121730|Señales de accidente|O|O||D||1
55121731|Marcadores de identificación|O|O||D||1
55121732|Divisores de tamaño|O|O||D||1
55121733|Señales en blanco|O|O||D||1
55121734|Láminas de material para señales|O|O||D||1
55121735|Señales temporales|O|O||D||1
55121800|Documentos de identificación|O|O||D||1
55121801|Discos de impuestos de vehículos|O|O||D||1
55121802|Tarjetas o bandas de identificación o productos similares|O|O||D||1
55121803|Pasaportes|O|O||D||1
55121804|Gafetes o porta gafetes|O|O||D||1
55121806|Kits de bandas de identificación personal o accesorios|O|O||D||1
55121807|Porta productos de identificación o accesorios|O|O||D||1
55121808|Clip para gafete|O|O||D||1
55121900|Señalizaciones|O|O||D||1
55121901|Columnas de publicidad|O|O||D||1
55121902|Stands o puestos|O|O||D||1
55121903|Señales de mensajes portátiles|O|O||D||1
55121904|Carteleras|O|O||D||1
55121905|Astas o partes o accesorios|O|O||D||1
55121906|Stands para banderas|O|O||D||1
55121907|Tableros de avisos|O|O||D||1
55121908|Soportes o stands para señales|O|O||D||1
56101500|Muebles|O|O||D||1
56101501|Stands|O|O||D||1|Burós, Esquineros
56101502|Sofás|O|O||D||1|Salas, Sillones
56101503|Armarios para abrigos|O|O||D||1
56101504|Asientos|O|O||D||1
56101505|Centros de entretenimiento|O|O||D||1
56101506|Futones|O|O||D||1
56101507|Bibliotecas|O|O||D||1|Libreros
56101508|Colchones o sets para dormir|O|O||D||1
56101509|Vestidores o armarios|O|O||D||1|Clóset, Roperos
56101510|Divisiones|O|O||D||1|Muros divisorios
56101513|Cunas o accesorios|O|O||D||1
56101514|Taburetes|O|O||D||1|Bancos
56101515|Camas|O|O||D||1
56101516|Cómodas|O|O||D||1|Cajonera
56101518|Estanterías de pared|O|O||D||1
56101519|Mesas|O|O||D||1
56101520|Casilleros (“lockers”)|O|O||D||1
56101521|Cabeceras o pies de cama|O|O||D||1
56101522|Sillas de brazos|O|O||D||1
56101523|Paragüeros o soportes para paraguas|O|O||D||1
56101524|Mesas de plancha|O|O||D||1|Tablas o burros para planchar
56101525|Forros para mesas de plancha|O|O||D||1|Forros para tablas o burros para planchar
56101526|Bar refrigerador|O|O||D||1|Frigobar
56101527|Secadores de linos tipo hogar|O|O||D||1
56101528|Plantas artificiales|O|O||D||1|Arreglos florales artificiales, Flores artificiales
56101529|Revisteros|O|O||D||1
56101530|Gabinetes de almacenamiento|O|O||D||1|Alacenas, Vitrinas
56101531|Zapateras|O|O||D||1
56101532|Set de muebles|O|O||D||1|Juego de muebles para baños, Juego de muebles para cocinas, Juego de muebles para jardín, Juego de muebles para recamaras, Juego de muebles para salas
56101533|Descansa brazos|O|O||D||1
56101535|Mesas de ruedas|O|O||D||1
56101536|Trípodes para instrumentos|O|O||D||1|Atriles, Tripie para instrumentos musicales
56101537|Tocadores|O|O||D||1
56101538|Mesas o bufetes para el comedor|O|O||D||1|Mueble auxiliar de comedor
56101539|Armazones o partes o accesorios para camas|O|O||D||1|Bastidores para camas, Tambores para camas
56101540|Solterones|O|O||D||1|Percheros
56101541|Ventiladores de colchones|O|O||D||1
56101542|Asientos plegables|O|O||D||1
56101543|Mesa de comedor|O|O||D||1
56101544|Espejos|O|O||D||1|Espejos para muebles
56101545|Espejos decorativos|O|O||D||1
56101600|Muebles para el exterior|O|O||D||1
56101601|Paraguas para jardín|O|O||D||1
56101602|Sillas para jardín|O|O||D||1
56101603|Mesas para jardín o mesas para picnic|O|O||D||1
56101604|Columpios para jardín|O|O||D||1
56101605|Bancos para jardín|O|O||D||1
56101606|Materas|O|O||D||1|Macetas
56101607|Secadora de ropa para exteriores|O|O||D||1
56101608|Estantes para bicicletas|O|O||D||1
56101609|Macetas de arcilla|O|O||D||1
56101610|Soportes para macetas|O|O||D||1
56101700|Muebles de oficina|O|O||D||1
56101701|Cajoneras o estanterías|O|O||D||1
56101702|Gabinetes de archivo o accesorios|O|O||D||1
56101703|Escritorios|O|O||D||1
56101704|Bases para mesas|O|O||D||1
56101705|Vitrinas|O|O||D||1
56101706|Mesas de conferencia|O|O||D||1
56101707|Mesas de dibujo|O|O||D||1
56101708|Archivadores móviles|O|O||D||1
56101710|Carritos o soportes para proyectores|O|O||D||1
56101711|Conectores de muebles modulares|O|O||D||1
56101712|Pedestales|O|O||D||1
56101713|Puestos (mesas) laterales de escritorios|O|O||D||1|Escritorios en L
56101714|Estantes para carpetas de información|O|O||D||1
56101715|Organizadores o clasificadores de correspondencia|O|O||D||1
56101716|Gavetas organizadoras para el escritorio|O|O||D||1
56101717|Eleva mesas|O|O||D||1
56101718|Estantes para periódicos|O|O||D||1
56101719|Mesas auxiliares|O|O||D||1
56101800|Accesorios y muebles de bebé y niño|O|O||D||1
56101803|Coches de bebé|O|O||D||1|Carriolas para bebé
56101804|Cunas o corrales o accesorios|O|O||D||1
56101805|Asientos de bebé para el carro|O|O||D||1
56101806|Asientos de comer (para bebés) o accesorios|O|O||D||1|Periqueras para bebé
56101807|Asientos rebotadores para bebés|O|O||D||1
56101808|Columpios o rebotadores o accesorios|O|O||D||1
56101809|Micas o bacinillas|O|O||D||1|Asientos entrenadores, Bacinicas entrenadoras, Nica entrenador
56101810|Bañeras o tinas para bebés|O|O||D||1
56101811|Cunas|O|O||D||1
56101812|Mesas para cambiar al bebé o accesorios|O|O||D||1
56101813|Asientos para el baño para bebés|O|O||D||1
56101900|Piezas de mobiliario y accesorios|O|O||D||1|Jaladeras
56101901|Tapas de muebles o superficies de trabajo|O|O||D||1
56101902|Discos movibles para muebles|O|O||D||1
56101903|Protectores o almohadillas o copas para las patas de los muebles|O|O||D||1
56101904|Bases o patas o extensiones de patas para muebles|O|O||D||1
56101905|Ensamblajes o secciones de paneles|O|O||D||1
56101906|Tablas de extensión para mesas|O|O||D||1
56101907|Fundas para muebles|O|O||D||1
56111500|Sitios de trabajo y paquetes para la oficina|O|O||D||1
56111501|Paquetes de muebles de recepción para oficinas|O|O||D||1
56111502|Paquetes de muebles para ejecutivos no modulares|O|O||D||1
56111503|Paquetes de muebles para ejecutivos modulares|O|O||D||1
56111504|Paquetes de muebles de gerencia no modulares|O|O||D||1
56111505|Paquetes de muebles de gerencia modulares|O|O||D||1
56111506|Paquetes de muebles para personal no modulares|O|O||D||1
56111507|Paquetes de muebles para personal modulares|O|O||D||1
56111508|Paquetes de muebles para técnicos no modulares|O|O||D||1
56111509|Paquetes de muebles para técnicos modulares|O|O||D||1
56111510|Paquetes de muebles secretariales no modulares|O|O||D||1
56111511|Paquetes de muebles secretariales modulares|O|O||D||1
56111512|Paquetes de muebles para recepción no modulares|O|O||D||1
56111513|Paquetes de muebles de salas de juntas no modulares|O|O||D||1
56111514|Paquetes de muebles de mostrador modulares|O|O||D||1
56111600|Sistemas de paneles|O|O||D||1
56111601|Biombos (mamparas) para sistemas de paneles|O|O||D||1
56111602|Almacenamiento para sistemas de paneles|O|O||D||1
56111603|Organizadores para sistemas de paneles|O|O||D||1
56111604|Superficies de trabajo para sistemas de paneles|O|O||D||1
56111605|Iluminación o electricidad o componentes de información para sistemas de paneles|O|O||D||1
56111606|Partes o accesorios para sistemas de paneles|O|O||D||1
56111700|Casegood y sistemas no modulares|O|O||D||1
56111701|Escritorios no modulares|O|O||D||1
56111702|Cajoneras o estanterías no modulares|O|O||D||1
56111703|Almacenamiento no modular|O|O||D||1
56111704|Organizadores no modular|O|O||D||1
56111705|Iluminación o electricidad o componentes de información no modulares|O|O||D||1
56111706|Partes o accesorios no modulares|O|O||D||1
56111707|Repisas no modulares|O|O||D||1
56111800|Muebles independientes|O|O||D||1
56111801|Iluminación o electricidad o componentes de información de pie|O|O||D||1
56111802|Mesas individuales (sin apoyo)|O|O||D||1
56111803|Almacenamiento individual (sin apoyo)|O|O||D||1
56111804|Organizadores individual (sin apoyo)|O|O||D||1
56111805|Partes o accesorios individuales (sin apoyo)|O|O||D||1
56111806|Silla giratoria para peluquería|O|O||D||1
56111900|Muebles industriales|O|O||D||1
56111901|Iluminación o electricidad o componentes de información industriales|O|O||D||1
56111902|Superficies de trabajo industriales|O|O||D||1
56111903|Unidades de almacenamiento industriales|O|O||D||1
56111904|Organizadores industriales|O|O||D||1
56111905|Partes o accesorios industriales|O|O||D||1
56111906|Gabinetes o cajones o estantes industriales|O|O||D||1
56111907|Carritos de herramientas industriales|O|O||D||1
56112000|Muebles de apoyo de la computadora|O|O||D||1
56112001|Iluminación o electricidad o componentes de información de soporte para computadores|O|O||D||1
56112002|Superficies de trabajo de soporte para computadores|O|O||D||1
56112003|Accesorios de almacenamiento de soporte para computadores|O|O||D||1
56112004|Organizadores de soporte para computadores|O|O||D||1
56112005|Partes o accesorios de soporte para computadores|O|O||D||1
56112100|Asientos|O|O||D||1
56112101|Silletería para auditorios o estadios o uso especiales|O|O||D||1|Asientos para auditorios o estadios o uso especiales, Butacas para auditorios o estadios o uso especiales
56112102|Sillas para grupos de trabajo|O|O||D||1
56112103|Sillas para visitantes|O|O||D||1
56112104|Sillas para ejecutivos|O|O||D||1
56112105|Sillas para descansar|O|O||D||1
56112106|Sillas altas (taburetes)|O|O||D||1
56112107|Partes o accesorios para sillas|O|O||D||1
56112108|Combinación de asiento con escritorio|O|O||D||1
56112109|Bancos|O|O||D||1
56112110|Sillas para músicos|O|O||D||1
56112111|Sillas de seguridad para bebés|O|O||D||1
56112200|Sistemas de escritorios|O|O||D||1
56112201|Biombos (separadores) para escritorio|O|O||D||1
56112202|Componentes para almacenamiento de escritorio|O|O||D||1
56112203|Componentes organizadores par escritorio|O|O||D||1
56112204|Superficies de trabajo|O|O||D||1
56112205|Componentes de iluminación, electricidad o información|O|O||D||1
56112206|Partes y accesorios relacionados con sistemas de escritorio|O|O||D||1
56112300|Partes y accesorios para asientos de auditorios o estadios o de uso especial|O|O||D||1
56112301|Espaldares|O|O||D||1|Respaldos
56112302|Armazones para fijar asientos|O|O||D||1
56112303|Pivotes (ejes) para asientos|O|O||D||1
56112304|Cojín del asiento|O|O||D||1
56121000|Mobiliario de biblioteca|O|O||D||1
56121001|Carritos para libros|O|O||D||1
56121002|Escritorios o componentes de circulación para bibliotecarios|O|O||D||1
56121003|Muebles para devolver libros|O|O||D||1
56121004|Unidades de catálogo de tarjetas|O|O||D||1
56121005|Estanterías para diccionarios|O|O||D||1
56121006|Bancas tapizadas|O|O||D||1
56121007|Tablas de acceso público|O|O||D||1
56121008|Unidades para ojear libros|O|O||D||1|Muebles para hojear libros
56121009|Mesas de lectura inclinadas|O|O||D||1
56121010|Kioscos de libros|O|O||D||1
56121011|Exhibidores de discos compactos o de audio casetes para bibliotecas|O|O||D||1
56121012|Stands de islas giratorias|O|O||D||1
56121014|Bolsas o estantes para bolsas|O|O||D||1
56121015|Estantes móviles para libros|O|O||D||1
56121100|Mobiliario de clase de arte|O|O||D||1
56121101|Caballetes|O|O||D||1
56121102|Mesas de dibujo para estudiantes|O|O||D||1
56121200|Mobiliario de sala de primeros auxilios|O|O||D||1
56121201|Camilla de primeros auxilios|O|O||D||1
56121300|Accesorios de instalaciones educativas generales|O|O||D||1
56121301|Escenarios pequeños (por ejemplo para un coro)|O|O||D||1
56121302|Carritos para mover mesas o asientos|O|O||D||1
56121303|Esteras de caucho para pisos|O|O||D||1|Alfombra de caucho para pisos
56121304|Mesas para planos|O|O||D||1
56121400|Mobiliario de cafetería y comedor|O|O||D||1
56121401|Mesas móviles para bancos|O|O||D||1
56121402|Mesas móviles para taburetes|O|O||D||1
56121403|Mesas móviles|O|O||D||1
56121500|Mobiliario general de aula|O|O||D||1
56121501|Mesas para actividades|O|O||D||1
56121502|Asientos para aulas de clase|O|O||D||1
56121503|Bancos para aulas de clase|O|O||D||1
56121504|Taburetes para aulas de clase|O|O||D||1
56121505|Mesas para aulas de clase|O|O||D||1
56121506|Pupitres|O|O||D||1
56121507|Bancas cubículo (pupitres con bloqueo visual para evitar distracciones)|O|O||D||1
56121508|Pupitres de computador para estudiantes|O|O||D||1
56121509|Mesas de computador para estudiantes|O|O||D||1
56121510|Pupitres de profesor|O|O||D||1
56121600|Mobiliario para el tiempo de descanso y ocio creativo para guardería infantil e instalaciones para niños|O|O||D||1
56121601|Sets de sala de tamaño de niños|O|O||D||1
56121602|Sofás de tamaño de niños|O|O||D||1
56121603|Sillones de tamaño de niños|O|O||D||1
56121604|Pufs de tamaño de niños|O|O||D||1
56121605|Biombos de poca altura o paneles para jugar|O|O||D||1
56121606|Esterillas de descanso para niños|O|O||D||1|Alfombras de descanso para niños
56121607|Estantes o percheros para esterillas de descanso para niños|O|O||D||1
56121608|Catres para niños|O|O||D||1
56121609|Cargadores de catres para niños|O|O||D||1|Cuna portátil
56121610|Centros de actividades para catres para niños|O|O||D||1
56121611|Mesas para bebés|O|O||D||1
56121700|Módulos de almacenamiento general y de libros para las aulas|O|O||D||1
56121701|Unidades de almacenamiento general|O|O||D||1
56121702|Unidades de almacenamiento de libros|O|O||D||1
56121703|Cubos (modulares) para guardar juguetes|O|O||D||1
56121704|Gabinetes institucionales de almacenamiento|O|O||D||1
56121800|Mobiliario y accesorios de aulas vocacionales|O|O||D||1
56121801|Gabinetes para almacenamiento de herramientas de educación técnico o gabinetes con herramientas|O|O||D||1
56121802|Gabinetes para almacenamiento de herramientas de taller general o gabinetes con herramientas|O|O||D||1
56121803|Gabinetes para almacenamiento de herramientas para trabajar en madera o gabinetes con herramientas|O|O||D||1
56121804|Escritorio técnico para instructores|O|O||D||1
56121805|Archivos planos|O|O||D||1
56121900|Mobiliario de demostración|O|O||D||1
56121901|Mesas de demostración de máquinas de coser|O|O||D||1
56121902|Stands exhibidores|O|O||D||1
56121903|Gabinete de preservación de reliquias|O|O||D||1
56122000|Muebles de laboratorio|O|O||D||1
56122001|Bancas de laboratorio|O|O||D||1
56122002|Unidades o accesorios de almacenamiento para laboratorios|O|O||D||1
56122003|Puestos de trabajo para laboratorios|O|O||D||1
56122004|Unidades de bases para lavamanos|O|O||D||1
56131500|Maniquíes y formas|O|O||D||1
56131501|Formas de busto|O|O||D||1
56131502|Formas de cabezas|O|O||D||1
56131503|Formas de cuello|O|O||D||1
56131504|Formas de cuerpo completo o maniquíes|O|O||D||1
56131600|Exhibidores y accesorios auto soportados para mercancías|O|O||D||1
56131601|Stands de piso|O|O||D||1
56131602|Postes de exhibición individuales|O|O||D||1
56131603|Mostradores de venta|O|O||D||1
56131604|Componentes de centros de pinturas de colores|O|O||D||1
56131605|Tablas de madera para exhibir productos de pintura|O|O||D||1
56131606|Abanico para exhibir muestras de pintura|O|O||D||1
56131607|Selección de inspiración de color|O|O||D||1
56131700|Aparatos, estantes, sistemas y accesorios para instalación de mercancías|O|O||D||1
56131701|Barras para colgar artículos|O|O||D||1
56131702|Canastas para mercancías|O|O||D||1
56131703|Ganchos o cascadas exhibidoras|O|O||D||1
56141500|Adornos cerámicos para el hogar|O|O||D||1
56141501|Tazones de cerámica|O|O||D||1
56141502|Platos grandes o pequeños de cerámica|O|O||D||1
56141503|Vasos de cerámica|O|O||D||1
56141504|Estatuillas o figuras de cerámica|O|O||D||1
56141600|Adornos de vidrio para el hogar|O|O||D||1
56141601|Tazones de vidrio|O|O||D||1
56141602|Vasos de vidrio|O|O||D||1
56141603|Platos grandes o pequeños de vidrio|O|O||D||1
56141604|Estatuillas o figuras de vidrio|O|O||D||1
60101000|Kits de matemáticas|O|O||D||1
60101001|Kits de matemáticas para sumar|O|O||D||1
60101002|Kits de matemáticas para dividir|O|O||D||1
60101003|Kits de matemáticas de fracciones|O|O||D||1
60101004|Kits de matemáticas para bachillerato básico|O|O||D||1
60101005|Kits de matemáticas para la primera infancia|O|O||D||1
60101006|Kits de matemáticas para mediciones|O|O||D||1
60101007|Kits de matemáticas para multiplicar|O|O||D||1
60101008|Kits de matemáticas para primaria|O|O||D||1
60101009|Kits de matemáticas para restar|O|O||D||1
60101010|Kits de matemáticas para bachillerato|O|O||D||1
60101100|Materiales electrónicos de aprendizaje|O|O||D||1
60101101|Lectores electrónicos de tarjetas|O|O||D||1
60101102|Materiales de aprendizaje electrónico basados en el plan de estudios|O|O||D||1
60101103|Globos terráqueos electrónicos|O|O||D||1
60101104|Máquinas electrónicas de pruebas|O|O||D||1
60101200|Incentivos educativos|O|O||D||1
60101201|Adhesivos de seguimiento basados en la biblia|O|O||D||1
60101202|Tablas de incentivo basados en la biblia|O|O||D||1
60101203|Adhesivos para pegar en las tablas de incentivo|O|O||D||1
60101204|Tablas de incentivo|O|O||D||1
60101205|Tarjetas perforadas de incentivo|O|O||D||1
60101300|Adhesivos educativos y suministros|O|O||D||1
60101301|Adhesivos basados en la biblia|O|O||D||1
60101302|Adhesivos gigantes|O|O||D||1
60101304|Adhesivos de fotos|O|O||D||1
60101305|Adhesivos de recompensa|O|O||D||1
60101306|Adhesivos perfumados|O|O||D||1
60101307|Adhesivos de formas|O|O||D||1
60101308|Adhesivos brillantes|O|O||D||1
60101309|Adhesivos de recompensa con forma de estrella|O|O||D||1
60101310|Surtidos de adhesivos|O|O||D||1
60101311|Libros de adhesivos|O|O||D||1
60101312|Cajas de adhesivos|O|O||D||1
60101313|Calcomanías para tatuaje|O|O||D||1
60101314|Tarjetas didácticas de sumas|O|O||D||1
60101315|Tarjetas didácticas de cultura general|O|O||D||1|Biografías y monografías
60101316|Tarjetas didácticas en blanco|O|O||D||1
60101317|Tarjetas didácticas de divisiones|O|O||D||1
60101318|Tarjetas didácticas electrónicas|O|O||D||1
60101319|Tarjetas didácticas de equivalencias|O|O||D||1
60101320|Tarjetas didácticas de fracciones|O|O||D||1
60101321|Tarjetas didácticas de mayor que o menor que|O|O||D||1
60101322|Tarjetas didácticas de multiplicaciones|O|O||D||1
60101323|Tarjetas didácticas de restas|O|O||D||1
60101324|Tarjetas didácticas del alfabeto|O|O||D||1
60101325|Tarjetas didácticas de construcción de palabras|O|O||D||1
60101326|Tarjetas didácticas de fonética|O|O||D||1
60101327|Tarjetas didácticas de escritura o escritura a mano|O|O||D||1
60101328|Tarjetas didácticas de los números|O|O||D||1
60101329|Tarjetas didácticas del dinero|O|O||D||1
60101330|Tarjetas didácticas de la hora|O|O||D||1
60101331|Tarjetas de los estados (departamentos)|O|O||D||1
60101400|Premios de la clase|O|O||D||1
60101401|Insignias|O|O||D||1
60101402|Botones de premio|O|O||D||1
60101403|Coronas de celebración|O|O||D||1
60101404|Joyas de recompense|O|O||D||1
60101405|Cintas o escarapelas para el salón de clases|O|O||D||1|Distintivos para premiación
60101600|Diplomas o certificados educativos|O|O||D||1
60101601|Certificados basados en la biblia|O|O||D||1
60101602|Certificados en blanco|O|O||D||1
60101603|Marcos para certificados|O|O||D||1
60101604|Soportes para certificados|O|O||D||1
60101605|Cintas para certificados|O|O||D||1
60101606|Diplomas|O|O||D||1
60101607|Certificados de idioma extranjero|O|O||D||1
60101608|Certificados de buena actitud|O|O||D||1|Certificados de buena conducta
60101609|Certificados específicos de grado|O|O||D||1
60101610|Certificados específicos de asignatura|O|O||D||1
60101700|Materiales de recursos del profesor|O|O||D||1
60101701|Libros de recursos para la evaluación|O|O||D||1
60101702|Calendarios o recortables|O|O||D||1
60101703|Materiales pedagógicos para la formación del carácter|O|O||D||1
60101704|Libros de actividades en clase|O|O||D||1
60101705|Materiales pedagógicos para el pensamiento crítico|O|O||D||1
60101706|Guías para planes de estudios integrados|O|O||D||1
60101707|Guías para el plan de estudios|O|O||D||1
60101708|Gráficos de tela|O|O||D||1
60101709|Materiales para flanelógrafos|O|O||D||1
60101710|Regalos del educador|O|O||D||1
60101711|Sellos para calificar|O|O||D||1
60101712|Pases (permisos) para salir al pasillo|O|O||D||1
60101713|Materiales pedagógicos para la educación en el hogar|O|O||D||1
60101714|Recursos para tareas en casa|O|O||D||1
60101715|Libros de ideas|O|O||D||1
60101716|Materiales para tableros magnéticos|O|O||D||1
60101717|Placas o etiquetas de identificación|O|O||D||1
60101718|Libros de planificación del profesor|O|O||D||1
60101719|Cartelera con bolsillos|O|O||D||1
60101720|Postales de comunicación del profesor|O|O||D||1
60101721|Libros de recursos profesionales para el profesor|O|O||D||1
60101722|Libros de calificaciones de la clase del profesor|O|O||D||1
60101723|Diagramas de asientos de los estudiantes en el salón de clases|O|O||D||1
60101724|Carpetas o formularios del profesor suplente|O|O||D||1
60101725|Libros de actividades o recursos tecnológicos|O|O||D||1
60101726|Guías de referencia sobre tecnología|O|O||D||1
60101727|Materiales pedagógicos  para hacer exámenes|O|O||D||1
60101728|Materiales de pedagógicos para unidades temáticas|O|O||D||1
60101729|Kits de enseñanza para bachillerato básico|O|O||D||1
60101730|Manuales de laboratorio|O|O||D||1
60101731|Rollos o tiras de frases|O|O||D||1
60101732|Punteros|O|O||D||1
60101800|Recursos educativos de las clases religiosas|O|O||D||1
60101801|Guías de referencia bíblica|O|O||D||1
60101802|Obras de teatro basadas en la biblia|O|O||D||1
60101803|Libros de actividades o recursos basados en la biblia|O|O||D||1
60101804|Libros de recursos para actividades en la escuela dominical|O|O||D||1
60101805|Recursos para escuelas bíblicas de vacaciones|O|O||D||1
60101806|Emblemas o símbolos sagrados|O|O||D||1
60101807|Rosarios|O|O||D||1
60101808|Ruedas de oración|O|O||D||1
60101809|Suministros o kits de productos religiosos|O|O||D||1
60101810|Patenas|O|O||D||1
60101811|Vestimentas|O|O||D||1
60101900|Recursos y materiales de destreza alfabética|O|O||D||1
60101901|Libros de actividades del alfabeto|O|O||D||1
60101902|Cubos con el alfabeto|O|O||D||1
60101903|Cintas adhesivas de escritorio con el alfabeto|O|O||D||1
60101904|Kits del alfabeto|O|O||D||1
60101905|Fichas con letras del alfabeto|O|O||D||1
60101906|Postales con el alfabeto|O|O||D||1
60101907|Guías de referencia del alfabeto|O|O||D||1
60101908|Libros de recursos del alfabeto|O|O||D||1
60101909|Sellos del alfabeto|O|O||D||1
60101910|Tarjetas del alfabeto para murales|O|O||D||1
60101911|Alfabetos táctiles|O|O||D||1
60102000|Materiales de recursos de creación de palabras y accesorios|O|O||D||1
60102001|Espejos para uso logopédico|O|O||D||1|Espejos para terapia de lenguaje
60102002|Materiales pedagógicos para ortografía|O|O||D||1
60102003|Libros de actividades para construcción de palabras|O|O||D||1
60102004|Kits para construcción de palabras|O|O||D||1
60102005|Libros de recursos para construcción de palabras|O|O||D||1
60102006|Fichas para construcción de palabras|O|O||D||1
60102007|Murales de palabras|O|O||D||1
60102100|Materiales de recursos de lenguaje|O|O||D||1
60102101|Libros de recursos de adjetivos|O|O||D||1
60102102|Libros de recursos de adverbios|O|O||D||1
60102103|Libros de recursos de gramática|O|O||D||1
60102104|Libros de recursos de sustantivos|O|O||D||1
60102105|Libros de recursos de puntuación|O|O||D||1
60102106|Libros de recursos de verbos|O|O||D||1
60102200|Materiales de recursos de fonética y accesorios|O|O||D||1
60102201|Libros de actividades de fonética|O|O||D||1
60102202|Tarjetas de ejercicios fonéticos de repetición|O|O||D||1
60102203|Kit de fonética|O|O||D||1
60102204|Tarjetas de imágenes de fonética|O|O||D||1
60102205|Libros de recursos de fonética|O|O||D||1
60102206|Fichas de fonética|O|O||D||1
60102300|Libros de lectura y recursos|O|O||D||1
60102301|Libros de actividades de lectura|O|O||D||1
60102302|Libros de lectura para principiantes|O|O||D||1
60102303|Libros de literatura infantil basados en la biblia|O|O||D||1
60102304|Libros de literatura infantil|O|O||D||1
60102305|Habilidades para la lectura crítica|O|O||D||1
60102306|Flanelógrafos|O|O||D||1|Franelógrafos
60102307|Libros de recursos de poesía|O|O||D||1
60102308|Materiales de comprensión de lectura|O|O||D||1
60102309|Kits o materiales de desarrollo de la lectura|O|O||D||1
60102310|Libros de recursos de lectura|O|O||D||1
60102311|Unidades temáticas de lectura|O|O||D||1
60102312|Libros de recursos o actividades de vocabulario.|O|O||D||1
60102400|Recursos de cuenta y temprano aprendizaje de matemáticas y accesorios|O|O||D||1
60102401|Abacos|O|O||D||1|Ábacos
60102402|Libros de recursos o actividades para trabajar con material didáctico manipulable de matemáticas temprana|O|O||D||1|Libros de actividades y material didáctico manipulable de matemáticas temprana
60102403|Tarjetas de actividades para trabajar material didáctico manipulable de matemáticas temprana|O|O||D||1|Tarjetas de actividades para trabajar matemáticas temprana
60102404|Cuentas o sets de actividades con cuentas para matemáticas temprana|O|O||D||1
60102405|Contadores o sets de actividades con contadores para matemáticas temprana|O|O||D||1|Contadores o sets de actividades para matemáticas temprana
60102406|Bandejas o boles para contar o clasificar para matemáticas tempranas|O|O||D||1
60102407|Cordones o sets de cordones para matemáticas temprana|O|O||D||1|Cordones o sets para matemáticas temprana
60102408|Material didáctico manipulable de vinculación o sets de actividades de vinculación para matemáticas temprana|O|O||D||1|Material didáctico manipulable o sets de actividades de vinculación para matemáticas temprana
60102409|Fichas para juegos de matemáticas|O|O||D||1
60102410|Tarjetas con números|O|O||D||1
60102411|Modelos con formas de números o accesorios|O|O||D||1
60102412|Tableros perforados para matemáticas básicas|O|O||D||1
60102413|Ganchos para tablero perforado para  matemáticas temprana|O|O||D||1
60102414|Material didácticos manipulativos de clasificación o sets de actividades de clasificación para matemáticas temprana|O|O||D||1
60102500|Recursos y materiales de numeración y operaciones matemáticas básicas|O|O||D||1
60102501|Libros de recursos o de actividades de la suma|O|O||D||1
60102502|Modelos de las operaciones básicas|O|O||D||1|Libros de las operaciones básicas
60102503|Guías de referencia de las operaciones básicas|O|O||D||1
60102504|Libros de recursos o actividades de la división|O|O||D||1
60102505|Libros de recursos o actividades de la multiplicación|O|O||D||1
60102506|Libros de recursos o actividades de la resta|O|O||D||1
60102507|Cintas adhesivas de escritorio con los números|O|O||D||1
60102508|Tableros o gráficas del uno al cien|O|O||D||1
60102509|Fichas con números del uno al cien|O|O||D||1
60102510|Kits de números|O|O||D||1
60102511|Rectas numéricas|O|O||D||1
60102512|libros de recursos o actividades de numeración|O|O||D||1
60102513|Dominós|O|O||D||1
60102600|Materiales de recursos del profesor de resolución de problemas, datos, posibilidades y probabilidades|O|O||D||1
60102601|Fichas o contadores de dos caras|O|O||D||1
60102602|Pirinolas|O|O||D||1
60102603|Juegos de dados|O|O||D||1
60102604|Libros de recursos o actividades de probabilidades|O|O||D||1
60102605|Libros de recursos o actividades de lógica|O|O||D||1
60102606|Bloques de atributos|O|O||D||1|Bloques de atributos lógicos
60102607|Tarjetas de actividades de bloques de atributos|O|O||D||1|Tarjetas de actividades de bloques de atributos lógicos
60102608|Libros de recursos o actividades de atributos|O|O||D||1|Libros de recursos o actividades de atributos lógicos
60102609|Esterilla de representación gráfica|O|O||D||1|Alfombrilla para representación gráfica
60102610|Libros de recursos o actividades de representación gráfica|O|O||D||1|Representación gráfica de libros de actividades o de recursos
60102611|Juegos de lógica|O|O||D||1
60102612|Kits o sets de atributos|O|O||D||1|Kits o sets de atributos lógicos
60102613|Libros de recursos o actividades de resolución de problemas|O|O||D||1
60102614|Tarjetas de actividades de resolución de problemas|O|O||D||1
60102700|Materiales de recursos del profesor de pensamiento lógico, percepción espacial, identificación de coincidencias y patrones|O|O||D||1
60102701|Libros de recursos o actividades de bloques geométricos o de bloques para patrones|O|O||D||1|Libros o actividades de bloques geométricos o de bloques para patrones
60102702|Bloques para patrones|O|O||D||1
60102703|Tarjetas de patrones o actividades de bloques para patrones|O|O||D||1
60102704|Sets de actividades o juegos de bloques para patrones|O|O||D||1
60102705|Adhesivos de bloques para patrones|O|O||D||1
60102706|Espejo de bloques para patrones|O|O||D||1|Patrón de espejo de bloques
60102707|Afiches o tablas de bloques para patrones|O|O||D||1
60102708|Bloques lógicos|O|O||D||1
60102709|Tarjetas de patrones o actividades de bloques lógicos|O|O||D||1
60102710|Sets de actividades de bloques lógicos|O|O||D||1
60102711|Libros de recursos o actividades del tangram|O|O||D||1
60102712|Tarjetas de patrones o actividades del tangram|O|O||D||1
60102713|Sets de actividades de rompecabezas tangram|O|O||D||1
60102714|Rompecabezas tangram|O|O||D||1
60102715|Libros de recursos y actividades de pentominós|O|O||D||1
60102717|Pentominós|O|O||D||1
60102718|Sets de actividades de pentominós|O|O||D||1
60102800|Materiales de recursos del profesor de valor de posición y base diez|O|O||D||1
60102801|Bloques de base diez|O|O||D||1
60102802|Libros de recursos o actividades de base diez o valor posicional|O|O||D||1
60102803|Tarjetas de actividades de  base diez o valor posicional|O|O||D||1
60102804|Sellos de caucho de base diez|O|O||D||1|Sellos de goma de base diez
60102805|Cuadrículas de valor posicional|O|O||D||1
60102806|Sets de actividades o juegos de valor posicional|O|O||D||1
60102807|Modelos o accesorios de valor posicional|O|O||D||1
60102900|Materiales de recursos del profesor del dinero y la hora|O|O||D||1
60102901|Libros de recursos o actividades sobre el dinero|O|O||D||1
60102902|Billetes de juego para la clase|O|O||D||1
60102903|Monedas de juego para la clase|O|O||D||1
60102904|Cubos o dados de monedas|O|O||D||1
60102905|Dinero magnético|O|O||D||1
60102906|Filminas de billetes|O|O||D||1|Billetes de juguete
60102907|Filminas de monedas|O|O||D||1|Monedas de juguete
60102908|Rompecabezas del dinero|O|O||D||1
60102909|Sellos de caucho del dinero|O|O||D||1|Sellos de goma de dinero
60102910|Alcancía de monedas|O|O||D||1
60102911|Kits o juegos del dinero|O|O||D||1|Juegos de dinero
60102912|Cajas registradoras de juguete|O|O||D||1
60102913|Guías de referencia del dinero|O|O||D||1
60102914|Libros de recursos o actividades de la hora|O|O||D||1
60102915|Sellos de caucho de la hora|O|O||D||1|Sellos de goma de la hora
60102916|Kits de la hora|O|O||D||1
60102917|Guías de referencia de la hora|O|O||D||1
60103000|Fracciones, pentominós y materiales de enseñanza de decimales|O|O||D||1
60103001|Círculos o cuadrados de fracciones|O|O||D||1
60103002|Cuadrados de decimales|O|O||D||1
60103003|Libros de actividades de fracciones|O|O||D||1
60103004|Barras de fracciones|O|O||D||1
60103005|Gráficos de fracciones|O|O||D||1
60103006|Dados de fracciones|O|O||D||1
60103007|Juegos de fracciones|O|O||D||1
60103008|Kits de fracciones|O|O||D||1
60103009|Fichas con fracciones|O|O||D||1
60103010|Discos con fracciones|O|O||D||1
60103012|Libro de actividades de pentominós|O|O||D||1
60103013|Tarjetas de patrones de pentominós|O|O||D||1
60103100|Materiales de recursos del profesor de geometría|O|O||D||1
60103101|Libros de recursos o  actividades de geometría|O|O||D||1
60103102|Afiches o cuadros de geometría|O|O||D||1|Posters o carteles de geometría
60103103|Tableros geométricos|O|O||D||1
60103104|Sets de construcción de formas geométricas|O|O||D||1
60103105|Tableros geométricos de doble cara|O|O||D||1
60103106|Kits de actividades o juegos para tableros geométricos|O|O||D||1
60103107|Bandas elásticas para tableros geométricos|O|O||D||1
60103108|Tarjetas de actividades de tableros geométricos|O|O||D||1
60103109|Instrumentos de dibujo geométrico para la pizarra|O|O||D||1
60103110|Guías de referencia de geometría|O|O||D||1
60103111|Espejo geométrico|O|O||D||1
60103112|Modelos geométricos sólidos|O|O||D||1
60103200|Materiales de recursos del profesor de álgebra|O|O||D||1
60103201|Libros de recursos o de actividades de álgebra|O|O||D||1
60103202|Cubos de centímetro|O|O||D||1
60103203|Guías de referencia de preálgebra o álgebra|O|O||D||1
60103204|Modelos o accesorios de álgebra|O|O||D||1
60103300|Materiales de recursos del profesor de precálculo y cálculo|O|O||D||1
60103301|Libros de recursos o actividades de cálculo|O|O||D||1
60103302|Guías de referencia de precálculo o cálculo|O|O||D||1
60103303|Libros de recursos o actividades de precálculo|O|O||D||1
60103400|Recursos de habilidad de lectura de mapas y geografía y accesorios|O|O||D||1
60103401|Afiches o carteles de geografía|O|O||D||1|Posters o carteles de geografía
60103402|Libros de recursos o actividades de los continentes|O|O||D||1
60103403|Materiales de aprendizaje electrónico de ciencias sociales|O|O||D||1
60103404|Guías de referencia de geografía|O|O||D||1
60103405|Estantes para mapas|O|O||D||1
60103406|Kits de plantillas de mapas|O|O||D||1
60103407|Mapas murales portátiles|O|O||D||1
60103408|Libros de recursos o actividades de geografía|O|O||D||1
60103409|Medidores de mapas|O|O||D||1
60103410|Material didáctico para la enseñanza de mapas|O|O||D||1
60103500|Ciencias políticas|O|O||D||1
60103501|Libros de recursos o actividades de economía|O|O||D||1
60103502|Libros de recursos o actividades del gobierno|O|O||D||1
60103503|Guías de referencia del gobierno|O|O||D||1
60103504|Unidades temáticas de los estados|O|O||D||1
60103600|Recursos y actividades multiculturales|O|O||D||1
60103601|Recursos de civilizaciones de la antigüedad|O|O||D||1
60103602|Recursos de tradiciones, rituales o costumbres|O|O||D||1
60103603|Recursos de diversidad étnica|O|O||D||1
60103604|Recursos de genealogía|O|O||D||1|Recursos para árboles genealógicos
60103605|Recursos para festivos multiculturales|O|O||D||1|Recursos y actividades para celebraciones multiculturales
60103606|Unidades temáticas multiculturales|O|O||D||1
60103700|Recursos de lenguas extranjeras|O|O||D||1
60103701|Recursos para aprender a hablar español|O|O||D||1
60103702|Recursos para aprender a hablar francés|O|O||D||1
60103703|Recursos para aprender a hablar alemán|O|O||D||1
60103704|Recursos para aprender a hablar inglés|O|O||D||1
60103705|Recursos para aprender a hablar latín|O|O||D||1
60103706|Recursos para aprender a hablar italiano|O|O||D||1
60103800|Recursos de enseñanza de historia|O|O||D||1
60103801|Libros de recursos de historia africana|O|O||D||1
60103802|Afiches o cuadros de historia|O|O||D||1|Posters o carteles de historia
60103803|Libros de recursos de historia europea|O|O||D||1
60103804|Mapas históricos|O|O||D||1
60103805|Unidades temáticas de historia|O|O||D||1
60103806|Tarjetas de fotos de historia|O|O||D||1
60103807|Libros de recursos de historia|O|O||D||1
60103808|Recursos de historia de la mujer|O|O||D||1
60103809|Recursos de historia mundial|O|O||D||1
60103900|Organismos vivos, especímenes conservados y materiales relacionados|O|O||D||1
60103903|Modelos de anfibios|O|O||D||1
60103904|Cultivos de hongos|O|O||D||1
60103905|Kits o materiales de cultivos|O|O||D||1
60103906|Cultivos de protozoos|O|O||D||1
60103907|Plantas de acuario|O|O||D||1
60103908|Plantas de terrario|O|O||D||1
60103909|Invertebrados vivos|O|O||D||1
60103911|Vertebrados vivos|O|O||D||1
60103915|Kits o materiales de disección|O|O||D||1
60103916|Embriones conservados|O|O||D||1
60103918|Biosferas|O|O||D||1|Biodomos
60103919|Kits o materiales para experimentos de biología|O|O||D||1
60103920|Kits o materiales para tinción|O|O||D||1|Juegos o materiales para coloración
60103921|Especímenes de ciclo vital preservado|O|O||D||1|Ciclos de vida de ejemplares conservados
60103922|Guías de referencia de biología|O|O||D||1
60103923|Espécimen de esqueleto o hueso o concha|O|O||D||1
60103924|Libros de recursos o actividades de biología|O|O||D||1
60103925|Kits de estudio o actividades de biología|O|O||D||1
60103926|Afiches o cuadros de biología|O|O||D||1|Posters o carteles de biología
60103927|Especímenes preservados de cuerpos u órganos de plantas|O|O||D||1
60103928|Tarjetas de fotos o actividades de biología|O|O||D||1
60103929|Especímenes del ciclo vital de plantas|O|O||D||1|Ciclos de vida de plantas conservados
60103930|Combinación de especímenes y organismos|O|O||D||1
60103931|Especímenes del cuerpo animal, partes u órganos|O|O||D||1|Ejemplares del cuerpo animal, partes u órganos
60103932|Exhibiciones de ecosistemas|O|O||D||1
60103933|Especímenes del cuerpo humano, partes u órganos|O|O||D||1|Ejemplares del cuerpo humano, partes u órganos
60103934|Cultivos de tejidos|O|O||D||1
60103936|Sets o diagramas de anatomía|O|O||D||1
60104000|Biotecnología, bioquímica, genética, microbiología y materiales relacionados|O|O||D||1
60104001|Modelos de ácido desoxirribonucleico (adn)|O|O||D||1
60104002|Kits de experimentos de ácido desoxirribonucleico (adn)|O|O||D||1
60104003|Libros de genética|O|O||D||1
60104004|Kits de genética|O|O||D||1
60104005|Kits de enseñanza de bacterias|O|O||D||1
60104006|Materiales de prueba de bacterias|O|O||D||1
60104007|Kits o materiales de enzimología|O|O||D||1
60104008|Kits o materiales de prueba de proteínas|O|O||D||1
60104100|Sistemas del cuerpo y materiales relacionados|O|O||D||1
60104101|Modelos del cuerpo humano, partes u órganos|O|O||D||1
60104102|Modelos de células|O|O||D||1
60104103|Kits de enseñanza de células|O|O||D||1
60104104|Kits de enseñanza de los sistemas del cuerpo|O|O||D||1
60104105|Materiales de enseñanza de los sistemas del cuerpo|O|O||D||1
60104106|Modelos del cuerpo de plantas, partes u órganos|O|O||D||1
60104107|Modelos del cuerpo de animales, partes u órganos|O|O||D||1
60104200|Pruebas del agua, conservación y ecología|O|O||D||1
60104201|Productos químicos de prueba del agua|O|O||D||1
60104202|Kits de muestreo y pruebas del agua|O|O||D||1
60104203|Modelos del agua|O|O||D||1
60104204|Materiales de ecología acuática|O|O||D||1
60104300|Astronomía|O|O||D||1
60104301|Modelos de astronomía|O|O||D||1
60104302|Diagramas de astronomía|O|O||D||1
60104303|Kits de estudio de astronomía|O|O||D||1
60104304|Compás solar|O|O||D||1
60104305|Simulador solar|O|O||D||1
60104306|Planetario|O|O||D||1
60104307|Modelo planetario|O|O||D||1
60104308|Globo celeste|O|O||D||1
60104309|Carta celeste manual|O|O||D||1
60104400|Geología y ciencias de la tierra|O|O||D||1
60104401|Sets de especímenes de roca|O|O||D||1|Juegos de ejemplares de roca
60104402|Especímenes de roca|O|O||D||1|Ejemplares de roca
60104403|Fósiles|O|O||D||1
60104404|Modelos de accidentes geográficos|O|O||D||1
60104405|Modelos de fósiles|O|O||D||1
60104406|Herramientas para geología de campo|O|O||D||1
60104407|Mesas de simulación de corrientes de agua|O|O||D||1
60104408|Kits de estudio de geología|O|O||D||1
60104409|Aparato para la formación de nubes|O|O||D||1
60104410|Aparato para observación lunar|O|O||D||1|Telescopio
60104411|Simulador del tiempo atmosférico|O|O||D||1
60104412|Aparato de acumulación de tierra|O|O||D||1
60104413|Aparato para la fuerza de coriolis|O|O||D||1
60104414|Globo terrestre|O|O||D||1|Globo terráqueo
60104415|Modelo mineral|O|O||D||1
60104416|Cilindro rotatorio|O|O||D||1
60104500|Química, electroquímica y microquímica|O|O||D||1
60104501|Afiches o cuadros de la tabla periódica|O|O||D||1|Posters o carteles de la tabla periódica
60104502|Kits de análisis del consumidor|O|O||D||1
60104503|Kits para clase de química|O|O||D||1
60104504|Kits de demostración de química|O|O||D||1
60104505|Modelos atómicos|O|O||D||1
60104506|Modelos moleculares|O|O||D||1
60104507|Herramientas para demostración electroquímica|O|O||D||1
60104508|Kits de electroquímica|O|O||D||1
60104509|Pilas de combustible|O|O||D||1
60104511|Instrumentos de microquímica|O|O||D||1
60104512|Aparato para la gota de aceite de millikan|O|O||D||1
60104600|Materiales de física mecánica|O|O||D||1
60104601|Mesas de fuerzas|O|O||D||1
60104602|Modelos de gravedad o sets de modelos|O|O||D||1
60104604|Planos inclinados|O|O||D||1
60104605|Aparato de fricción|O|O||D||1
60104606|Carros de física|O|O||D||1
60104607|Equipo de péndulo|O|O||D||1
60104608|Equipo de torque|O|O||D||1
60104609|Aparato de movimiento de proyectiles|O|O||D||1
60104610|Mesas de aire|O|O||D||1
60104611|Equipos de aire|O|O||D||1
60104612|Aparato para luz o foto|O|O||D||1
60104613|Hemisferio de magdeburgo|O|O||D||1
60104614|Aparato del anillo de newton|O|O||D||1
60104615|Pista de aire|O|O||D||1
60104616|Aparato de fuerza centrípeta|O|O||D||1
60104617|Aparato del modulo elástico de tensión|O|O||D||1
60104618|Demostrador newtoniano|O|O||D||1
60104619|Temporizador de registros|O|O||D||1
60104700|Materiales de física de energía y electricidad|O|O||D||1
60104701|Dispositivos de recolección solar|O|O||D||1
60104702|Kits solares|O|O||D||1
60104703|Kits de demostración de energía|O|O||D||1
60104704|Kits de clases de energía|O|O||D||1
60104705|Kits de demostración de materia|O|O||D||1
60104706|Kits de clases de materia|O|O||D||1
60104707|Manómetros|O|O||D||1
60104708|Aparato de difusión de gases|O|O||D||1
60104709|Aparato de conducción de calor|O|O||D||1
60104710|Aparato de radiación y convección térmica|O|O||D||1
60104711|Aparato para la ley de hooke|O|O||D||1
60104712|Aparato de frank-hertz|O|O||D||1
60104713|Aparato de expansión de líquidos|O|O||D||1
60104714|Aparato para la ley de boyle|O|O||D||1
60104715|Aparato para el principio de pascal|O|O||D||1
60104716|Aparato para el principio de arquímedes|O|O||D||1
60104717|Aparato para el teorema de bernoulli|O|O||D||1
60104718|Aparato de bombeo centrífugo|O|O||D||1
60104719|Tubo de ventury|O|O||D||1|Tubo de venturi
60104720|Aparato para la medición del número de reynolds|O|O||D||1
60104721|Aparato del momento de inercia|O|O||D||1
60104722|Aparato para medir  la fuerza gravitacional|O|O||D||1
60104723|Balanza de torsión|O|O||D||1
60104724|Analizador del sistema de refrigeración|O|O||D||1
60104726|Aparato para la ley de torricelli|O|O||D||1
60104800|Materiales de física del sonido y las ondas|O|O||D||1
60104801|Generadores de ondas|O|O||D||1
60104802|Tanques de ondas|O|O||D||1
60104803|Fuentes de ondas|O|O||D||1
60104804|Sets de demostración de ondas|O|O||D||1
60104805|Diapasones|O|O||D||1
60104806|Demostradores del efecto doppler|O|O||D||1
60104807|Equipo de resonancia|O|O||D||1
60104808|Fonómetros|O|O||D||1|Sonómetro
60104809|Aparato de ondas|O|O||D||1
60104810|Espectroscopios|O|O||D||1
60104811|Diagramas del espectro|O|O||D||1
60104812|Kits de demostración de la luz|O|O||D||1
60104813|Cartas o muestras de colores|O|O||D||1
60104814|Radiómetro|O|O||D||1
60104815|Equipo de refracción o reflexión|O|O||D||1
60104816|Sets o kits ópticos|O|O||D||1
60104817|Aparato del tanque ripple|O|O||D||1
60104818|Aparato de la constante de planck|O|O||D||1
60104819|Lámpara de balmer|O|O||D||1
60104820|Aparato de kundt|O|O||D||1
60104821|Aparato del efecto fotoeléctrico|O|O||D||1
60104822|Set de banco óptico elemental|O|O||D||1
60104823|Oscilador armónico simple|O|O||D||1
60104824|Aparato de óptica de ondas|O|O||D||1|Instrumento óptico
60104825|Aparato de holografía|O|O||D||1|Dispositivo holográfico
60104826|Espejo mágico óptico|O|O||D||1
60104827|Equipo para medición de distancias focales|O|O||D||1|Medidor de distancias focales
60104900|Materiales de física de electricidad|O|O||D||1
60104901|Generadores de van de graff|O|O||D||1
60104902|Aparato de electrostática|O|O||D||1|Generador electrostático
60104903|Kits de electrostática|O|O||D||1
60104904|Kits de electricidad|O|O||D||1
60104905|Tableros de demostración de electricidad|O|O||D||1
60104906|Kits de baterías|O|O||D||1
60104907|Generadores portátiles|O|O||D||1
60104908|Aparato de electromagnetismo|O|O||D||1
60104909|Aparato de magnetismo|O|O||D||1
60104910|Electroimanes|O|O||D||1
60104911|Campanas eléctricas o accesorios|O|O||D||1
60104912|Alambres o cables eléctricos|O|O||D||1
60104913|Aparato para la ley de ohm|O|O||D||1|Óhmetro U ohmímetro
60104914|Tubo de descarga|O|O||D||1
60104915|Aparato para experimentos de transformadores|O|O||D||1
60104916|Aparato del efecto termoeléctrico|O|O||D||1
60104917|Aparato de voltaje constante|O|O||D||1
60104918|Aparato fotoeléctrico|O|O||D||1
60104919|Botella de leyden|O|O||D||1
60104920|Cámara de nubes|O|O||D||1|Cámara de niebla
60104921|Aparato del efecto zeeman|O|O||D||1
60104922|Aparato para la ley de coulomb|O|O||D||1
60104923|Descargador|O|O||D||1
60104924|Aparato para la ley de faraday|O|O||D||1
60104925|Aparato para la ley de fleming|O|O||D||1
60104926|Aparato del efecto hall|O|O||D||1|Sensor de efecto hall
60104927|Sistema de pruebas de armaduras|O|O||D||1
60104928|Tubo de crookes|O|O||D||1
60104929|Generador de campo magnético rotatorio|O|O||D||1
60104930|Dispositivo de demostración de luz fluorescente|O|O||D||1
60105000|Materiales de física nuclear|O|O||D||1
60105001|Sets de radioactividad|O|O||D||1
60105002|Contadores geiger|O|O||D||1|Detector de radiaciones
60105003|Aparato de electrones|O|O||D||1
60105004|Señales de advertencia de radiación|O|O||D||1
60105005|Diapositivas de física nuclear|O|O||D||1|Transparencias de física nuclear
60105006|Diagramas de física nuclear|O|O||D||1|Gráficos de física nuclear
60105100|Cohetes, materiales de vuelo y suministros|O|O||D||1
60105101|Sets de cohetes|O|O||D||1
60105102|Aparato de lanzamiento|O|O||D||1
60105103|Dispositivos para la medición de alturas|O|O||D||1
60105104|Kits de aviones|O|O||D||1
60105200|Materiales educativos de recursos de aptitudes de vida|O|O||D||1
60105201|Materiales de enseñanza para desarrollar habilidades de escucha|O|O||D||1
60105202|Materiales de enseñanza de  habilidades de estudio|O|O||D||1
60105203|Materiales de enseñanza de preparación de exámenes|O|O||D||1
60105300|Materiales educativos de educación de carrera|O|O||D||1
60105301|Materiales de enseñanza de habilidades para la educación o planificación o toma de decisiones para el trabajo|O|O||D||1
60105302|Materiales de enseñanza de  habilidades laborales básicas|O|O||D||1
60105303|Materiales de enseñanza de habilidades para la búsqueda de empleo|O|O||D||1
60105304|Materiales de enseñanza de habilidades para el manejo del tiempo|O|O||D||1
60105305|Materiales de enseñanza de habilidades para entrevistas|O|O||D||1
60105306|Materiales de enseñanza de habilidades para elaborar la hoja de vida|O|O||D||1
60105307|Materiales de enseñanza de formación de ética laboral o actitudes|O|O||D||1
60105308|Materiales de enseñanza para desarrollar habilidades de trabajo en equipo|O|O||D||1
60105309|Materiales de enseñanza de etiqueta  empresarial|O|O||D||1
60105400|Materiales educativos de vida independiente, administración del dinero y economía doméstica|O|O||D||1
60105401|Materiales de enseñanza del manejo del dinero o de las finanzas personales|O|O||D||1
60105402|Materiales de enseñanza de habilidades de consumo y comparación de precios|O|O||D||1
60105403|Materiales de enseñanza de vida independiente|O|O||D||1
60105404|Materiales de enseñanza para la comprensión de los créditos o préstamos de consumo|O|O||D||1
60105405|Materiales de enseñanza de comparación o cobertura de seguros|O|O||D||1
60105406|Materiales de enseñanza para compra de casa|O|O||D||1
60105407|Materiales de enseñanza para alquiler de apartamento|O|O||D||1
60105408|Materiales de enseñanza para compra de carro|O|O||D||1
60105409|Materiales de enseñanza  de publicidad o comercialización de marcas|O|O||D||1
60105410|Materiales de enseñanza de habilidades para la vida en familia o para el establecimiento de relaciones|O|O||D||1
60105411|Materiales de enseñanza para el desarrollo de la autoestima y el autoconcepto|O|O||D||1
60105412|Materiales de enseñanza de prevención de la violencia o de educación para la evasión de la violencia|O|O||D||1
60105413|Materiales de enseñanza  de formación para el manejo de la ira|O|O||D||1
60105414|Materiales educativos para la enseñanza de la paciencia|O|O||D||1
60105415|Materiales de enseñanza de formación de la tolerancia|O|O||D||1
60105416|Materiales de enseñanza de seguridad personal|O|O||D||1
60105417|Materiales de enseñanza de resolución de conflictos personales|O|O||D||1
60105418|Guías de asesoramiento práctico para adolescentes|O|O||D||1
60105419|Materiales de enseñanza de desarrollo de aptitudes sociales|O|O||D||1
60105420|Materiales de enseñanza de modales o etiqueta o cortesía|O|O||D||1
60105421|Materiales de enseñanza para entender o tratar con la diversidad cultural|O|O||D||1
60105422|Materiales de enseñanza para interpretar el lenguaje corporal|O|O||D||1
60105423|Materiales de enseñanza  para el desarrollo de la capacidad de adaptación|O|O||D||1
60105424|Materiales de enseñanza de comprensión del servicio a la comunidad|O|O||D||1
60105425|Materiales de enseñanza para el desarrollo de habilidades de negación|O|O||D||1
60105426|Materiales de enseñanza de habilidades de responsabilidad o toma de decisiones|O|O||D||1
60105427|Materiales de enseñanza de comprensión de los derechos legales de los adolescentes|O|O||D||1
60105428|Materiales de enseñanza de las repercusiones de la deserción escolar|O|O||D||1
60105429|Videos de las relaciones interraciales|O|O||D||1
60105500|Materiales educativos de diseño del hogar y de interiores|O|O||D||1
60105501|Materiales de enseñanza de feng shui|O|O||D||1
60105502|Materiales de enseñanza para utilizar color o pintura para la decoración del hogar|O|O||D||1
60105503|Materiales de enseñanza  para la  planificación o diseño del hogar|O|O||D||1
60105504|Materiales de enseñanza de diseño de jardines|O|O||D||1
60105505|Materiales de enseñanza para la decoración o amueblamiento del hogar|O|O||D||1
60105600|Materiales educativos de preparación de alimentos, nutrición y educación sobre la salud|O|O||D||1
60105601|Materiales de enseñanza de dietas balanceadas o pautas alimentarias|O|O||D||1
60105602|Materiales de enseñanza de habilidades de planificación de menús para planes de estudios de nutrición|O|O||D||1
60105603|Materiales de enseñanza de comprensión del etiquetado nutricional|O|O||D||1
60105604|Materiales de enseñanza de compra de alimentos|O|O||D||1
60105605|Módulos de demostración de opciones de alimentos saludables|O|O||D||1
60105606|Materiales de enseñanza de comprensión de los efectos de las grasas alimenticias|O|O||D||1
60105607|Materiales de enseñanza de comprensión del vegetarianismo|O|O||D||1
60105608|Libros de cocina o recetarios|O|O||D||1
60105609|Materiales de enseñanza de  educación acerca de los trastornos alimenticios|O|O||D||1
60105610|Materiales de enseñanza sobre el control de peso o el ejercicio|O|O||D||1
60105611|Materiales de enseñanza de la medición de sólidos o líquidos en la cocina|O|O||D||1
60105612|Materiales de enseñanza de equivalencias o matemáticas en la cocina|O|O||D||1
60105613|Materiales de enseñanza sobre los utensilios de cocina|O|O||D||1
60105614|Materiales de enseñanza sobre la higiene o la seguridad en la cocina|O|O||D||1
60105615|Materiales de enseñanza sobre la inocuidad de los alimentos|O|O||D||1
60105616|Materiales de enseñanza sobre actividades de la ciencia de los alimentos|O|O||D||1
60105617|Materiales de enseñanza de habilidades culinarias|O|O||D||1
60105618|Materiales de enseñanza de etiqueta o modales en la mesa|O|O||D||1
60105619|Materiales de enseñanza sobre cómo poner la mesa|O|O||D||1
60105620|Materiales de enseñanza de capacitación de los servicios de alimentación|O|O||D||1
60105621|Materiales de enseñanza de educación acerca del abuso de drogas o  tabaco o alcohol|O|O||D||1
60105622|Simuladores para fumar|O|O||D||1|Simuladores para fumadores
60105623|Materiales de enseñanza de comprensión de las adicciones o cómo evitarlas|O|O||D||1
60105624|Materiales de enseñanza de los síntomas de depresión en adolescentes|O|O||D||1
60105625|Materiales de enseñanza de capacitación para evitar el suicidio de adolescentes|O|O||D||1
60105626|Materiales de enseñanza para lidiar con el estrés|O|O||D||1
60105700|Álbumes de recuerdos y suministros|O|O||D||1
60105701|Álbumes de recuerdos|O|O||D||1|Álbumes fotográficos
60105702|Tornillos de extensión para álbumes de recuerdos|O|O||D||1|Extensiones para álbumes de recuerdos
60105703|Papel para álbumes de recuerdos|O|O||D||1
60105704|Barras de pegante libres de ácido|O|O||D||1
60105705|Cinta pegante libre de ácido|O|O||D||1
60105800|Materiales educativos de diseño textil y de ropa|O|O||D||1
60105801|Materiales de enseñanza de habilidades para la costura|O|O||D||1
60105802|Materiales para proyectos de costura|O|O||D||1
60105803|Materiales de enseñanza de comprensión de la confección o hechura de ropa|O|O||D||1
60105804|Materiales de enseñanza de diseño o modas de ropa|O|O||D||1
60105805|Materiales de enseñanza de análisis de colores personales|O|O||D||1
60105806|Materiales de enseñanza de los principios básicos de la comercialización de la moda o la venta al por  menor|O|O||D||1
60105807|Materiales de enseñanza de la ciencia de los tejidos o las fibras|O|O||D||1
60105808|Materiales de enseñanza del cuidado o mantenimiento o lavado de la ropa|O|O||D||1
60105809|Materiales para la enseñanza del arte del color en el diseño  de telas|O|O||D||1
60105810|Materiales de enseñanza sobre pinturas y tintes para telas|O|O||D||1
60105811|Materiales de enseñanza para proyectos de acolchado|O|O||D||1
60105900|Materiales educativos sobre las relaciones y el sexo, el embarazo de adolescentes, aptitudes de crianza y desarrollo del niño|O|O||D||1
60105901|Materiales de enseñanza de educación sexual o enfermedades de transmisión sexual|O|O||D||1
60105902|Materiales de enseñanza de recursos de  nutrición prenatal o abuso fetal|O|O||D||1
60105903|Materiales de enseñanza de habilidades para la crianza de los hijos|O|O||D||1
60105904|Materiales de enseñanza sobre el desarrollo de niño|O|O||D||1
60105905|Materiales de enseñanza de comprensión de la violación en una cita o las habilidades para salir en cita o el acoso|O|O||D||1
60105906|Materiales de enseñanza de educación sobre el parto|O|O||D||1
60105907|Materiales de enseñanza sobre el embarazo, desde la concepción hasta el parto|O|O||D||1
60105908|Materiales de enseñanza de comprensión de los riesgos de defectos de nacimiento|O|O||D||1
60105909|Simuladores de embarazo|O|O||D||1|Chaleco simulador de embarazo
60105910|Simuladores de bebés y accesorios|O|O||D||1|Simuladores infantiles y accesorios
60105911|Materiales de enseñanza de formación sobre puericultura|O|O||D||1
60105912|Materiales de enseñanza de comprensión del abuso infantil  físico o emocional|O|O||D||1
60105913|Materiales de enseñanza para padres sobre educación de habilidades para la disciplina|O|O||D||1
60105914|Materiales de enseñanza de seguridad del hogar o de protección para evitar usos indebidos por los niños|O|O||D||1
60105915|Materiales de enseñanza sobre resucitación cardiopulmonar o apoyo básico de vida|O|O||D||1
60105916|Materiales de enseñanza de comprensión de las enfermedades de la infancia|O|O||D||1
60105917|Materiales de enseñanza de comprensión del trastorno por déficit de atención con hiperactividad|O|O||D||1
60105918|Materiales de enseñanza para el cuidador de niños|O|O||D||1
60105919|Materiales de enseñanza para el cuidado de niños|O|O||D||1
60106000|Guías de planes de estudio, proyectos, actividades y lecciones|O|O||D||1
60106001|Libros de ideas o recursos del plan de estudios de bachillerato básico|O|O||D||1
60106002|Libros de ideas o recursos del plan de estudios de bachillerato|O|O||D||1
60106003|Proyectos de estudio independiente de economía doméstica|O|O||D||1
60106004|Recursos o guías de proyectos o actividades de economía doméstica|O|O||D||1
60106100|Materiales de enseñanza vocacional|O|O||D||1
60106101|Materiales didácticos sobre el automóvil|O|O||D||1
60106102|Materiales didácticos de construcción|O|O||D||1
60106103|Materiales didácticos de diseño o delineación|O|O||D||1
60106104|Materiales didácticos de electricidad o electrónica|O|O||D||1
60106105|Materiales didácticos de artes gráficas o fotografía|O|O||D||1
60106106|Materiales didácticos de  horticultura|O|O||D||1
60106107|Materiales didácticos de manufactura|O|O||D||1
60106108|Materiales didácticos de seguridad o peligro|O|O||D||1
60106109|Materiales didácticos de soldadura|O|O||D||1
60106200|Materiales de enseñanza de tecnología|O|O||D||1
60106201|Materiales didácticos de agricultura|O|O||D||1
60106202|Materiales didácticos de biotecnología|O|O||D||1
60106203|Materiales didácticos de comunicaciones|O|O||D||1
60106204|Materiales didácticos de informática|O|O||D||1
60106205|Materiales didácticos de energía o electricidad|O|O||D||1
60106206|Materiales didácticos del medio ambiente|O|O||D||1
60106207|Materiales didácticos de materiales|O|O||D||1
60106208|Materiales didácticos de medicina|O|O||D||1
60106209|Materiales didácticos de transporte|O|O||D||1
60106210|Materiales didácticos de sistemas de armas|O|O||D||1
60106211|Materiales didácticos del motor o sus partes|O|O||D||1
60106212|Materiales didácticos de instrumentos de navegación|O|O||D||1
60106213|Materiales didácticos de mecánica de fluidos o máquinas|O|O||D||1
60106214|Materiales didácticos de robótica|O|O||D||1
60106215|Materiales didácticos de sistemas de refrigeración|O|O||D||1
60106300|Equipo de enseñanza de ciencia forense y suministros|O|O||D||1
60106301|Kits de ciencias forenses|O|O||D||1
60106302|Materiales de enseñanza de ciencias forenses|O|O||D||1
60106400|Equipo de enseñanza de electrónica y suministros|O|O||D||1
60106401|Kits de electrónica|O|O||D||1
60106402|Suministros para la enseñanza de electrónica|O|O||D||1
60106500|Suministros religiosos|O|O||D||1
60106501|Estatua budista|O|O||D||1
60106502|Estatua de la santa madre y el niño|O|O||D||1|Estatua de la Virgen María y el niño Dios
60106503|Cruz eclesiástica|O|O||D||1
60106504|Servicio de mesa para ritos fúnebres|O|O||D||1
60106505|Quemador de incienso|O|O||D||1
60106506|Harubang|O|O||D||1|Estatua Harubang
60106600|Materiales para pruebas de aptitud y vocacionales|O|O||D||1
60106601|Test de ensamble de bloques|O|O||D||1
60106602|Test de percepción de formas|O|O||D||1
60106603|Test de reacción de velocidad de anticipación|O|O||D||1
60106604|Set de evaluación vocacional|O|O||D||1
60106605|Test de reacción mental|O|O||D||1
60106606|Test de ejecución de trabajos manuales de precisión|O|O||D||1
60106607|Test de movimientos de reacción|O|O||D||1
60106608|Test de coordinación de los dos brazos|O|O||D||1
60106609|Herramienta de discriminación|O|O||D||1
60106610|Herramienta para pruebas de ensamble|O|O||D||1
60106611|Herramienta para pruebas de empaquetado|O|O||D||1
60106612|Test de coordinación ojos- brazos|O|O||D||1
60111000|Pósteres o gráficos del aula|O|O||D||1
60111001|Paquetes de gráficos|O|O||D||1
60111002|Gráficos para el salón de clase|O|O||D||1
60111003|Afiches o sets para el salón de clases|O|O||D||1|Carteles o sets para el salón de clases
60111004|Afiches de creación  personal|O|O||D||1|Carteles de creación personal
60111005|Soportes de gráficos o accesorios|O|O||D||1
60111100|Sets de tablón de anuncios|O|O||D||1
60111101|Sets de carteleras grandes|O|O||D||1
60111102|Sets de carteleras del calendario|O|O||D||1
60111103|Sets de carteleras para la primera infancia|O|O||D||1
60111104|Sets de carteleras de idiomas|O|O||D||1
60111105|Sets carteleras de matemáticas|O|O||D||1
60111106|Sets de carteleras multipropósito|O|O||D||1
60111107|Sets de carteleras de ciencias|O|O||D||1
60111108|Sets de carteleras de temporada|O|O||D||1
60111109|Sets de carteleras de ciencias sociales|O|O||D||1
60111200|Guardas y remates de tablón de anuncios|O|O||D||1
60111201|Pendones para el salón de clase|O|O||D||1|Estandarte para el salón de clases
60111202|Paquetes de bordes|O|O||D||1|Marcos y encajes decorativos
60111203|Carteles para el salón de clase|O|O||D||1
60111204|Bordes o ribetes corrugados|O|O||D||1
60111205|Bordes o ribetes festoneados y troquelados con formas|O|O||D||1|Encajes o ribetes festoneados y troquelados con formas
60111206|Bordes o ribetes brillantes|O|O||D||1|Encajes o ribetes brillantes
60111207|Bordes o ribetes rectos|O|O||D||1|Encajes o ribetes rectos
60111208|Almacenaje de bordes o ribetes|O|O||D||1|Almacenaje de encajes o ribetes
60111300|Letras y números decorativos|O|O||D||1
60111301|Bloques con letras o números|O|O||D||1
60111302|Letras o números sueltos|O|O||D||1
60111303|Letras o números en cursiva|O|O||D||1
60111304|Letras o números autoadhesivos|O|O||D||1
60111305|Letras o números brillantes|O|O||D||1
60111306|Letras o números para calcar|O|O||D||1
60111400|Decoraciones especiales para el aula y accesorios decorativos|O|O||D||1
60111401|Kits de decoración para el salón de clase|O|O||D||1
60111402|Decoraciones para puertas|O|O||D||1
60111403|Móviles|O|O||D||1
60111404|Decoraciones de dos caras|O|O||D||1|Móviles para niños
60111405|Decoraciones para adherir a las ventanas|O|O||D||1|Decoración adherible de doble cara
60111407|Sistemas decorativos de almacenaje|O|O||D||1|Pegatinas para ventanas
60111408|Cintas o cintas onduladas decorativas|O|O||D||1
60111409|Botones decorativos|O|O||D||1
60111410|Figuras o cuerdas decorativas|O|O||D||1
60111411|Aerosoles decorativos|O|O||D||1
60121000|Arte|O|O||D||1
60121001|Pinturas|O|O||D||1
60121002|Esculturas|O|O||D||1
60121003|Estatuas|O|O||D||1
60121004|Retratos|O|O||D||1
60121005|Dibujos|O|O||D||1
60121006|Cuadros|O|O||D||1
60121007|Litografías|O|O||D||1
60121008|Afiches|O|O||D||1
60121009|Vasija decorativa|O|O||D||1
60121010|Pergaminos|O|O||D||1
60121011|Fotografías|O|O||D||1
60121012|Adhesivos decorativos|O|O||D||1|Calcomanías decorativas
60121013|Decoración artística para paredes|O|O||D||1|Pegatinas de pared
60121014|Frutas secas decorativas|O|O||D||1
60121015|Adhesivos decorativos en vinilo|O|O||D||1
60121100|Lienzos, películas, tableros y papeles de artista|O|O||D||1
60121101|Papel para dibujo de sulfito|O|O||D||1|Papel sulfito
60121102|Papel para dibujo de pasta de madera triturada|O|O||D||1|Papel de dibujo
60121103|Papel para dibujo de calcar o pergamino|O|O||D||1|Papel vegetal
60121104|Papel bond para para dibujo|O|O||D||1|Papel bond
60121105|Papel de dibujo para carboncillo o pastel|O|O||D||1
60121106|Papel brístol para dibujo|O|O||D||1
60121107|Hojas de papel para acuarela|O|O||D||1
60121108|Cuadernos de papel para acuarela|O|O||D||1
60121109|Blocs de papel para acuarela|O|O||D||1
60121110|Papel para pintura dactilar|O|O||D||1
60121111|Cartulina de sulfito|O|O||D||1
60121112|Cartulina de pasta de madera triturada|O|O||D||1|Cartulina de papel
60121113|Cartulina metalizada|O|O||D||1
60121114|Papeles para manualidades de origami|O|O||D||1
60121115|Confeti de plástico o de papel|O|O||D||1
60121116|Papel crepé para manualidades|O|O||D||1
60121117|Papel de seda para manualidades|O|O||D||1|Papel de china
60121118|Papel corrugado para manualidades|O|O||D||1
60121119|Papel con impresión de patrones para manualidades|O|O||D||1
60121120|Papel para manualidades autoadhesivo|O|O||D||1
60121121|Papel fluorescente|O|O||D||1
60121123|Papel hecho a mano|O|O||D||1
60121124|Papel kraft|O|O||D||1|Papel estraza
60121125|Paneles de lienzo|O|O||D||1
60121126|Lienzo preestirado|O|O||D||1
60121127|Lienzo imprimado|O|O||D||1
60121128|Lienzo sin imprimar|O|O||D||1
60121129|Paneles de madera comprimida|O|O||D||1
60121130|Cuadernos de papel imitación lienzo|O|O||D||1
60121131|Papel japonés para grabado|O|O||D||1
60121132|Papel para grabado para huecograbado o litografía|O|O||D||1
60121133|Papel para grabado para impresión xilográfica|O|O||D||1
60121134|Papel metálico|O|O||D||1
60121135|Películas de acetato, vinilo o poliéster|O|O||D||1
60121136|Películas de celofán|O|O||D||1
60121137|Hojas de acrílico|O|O||D||1
60121138|Tableros de ilustración|O|O||D||1
60121139|Láminas de paspartú|O|O||D||1
60121140|Tablero de montaje|O|O||D||1
60121141|Tablero de montaje de núcleo de espuma|O|O||D||1
60121142|Cartón duro o cartón de colores de dos caras|O|O||D||1
60121143|Tablero para presentaciones|O|O||D||1
60121144|Papeles borrador para arte|O|O||D||1
60121145|Carteles borrador para arte|O|O||D||1
60121146|Accesorios borrador para arte|O|O||D||1
60121147|Papel brillante|O|O||D||1
60121148|Cartones de colores|O|O||D||1
60121149|Papel vegetal prensado|O|O||D||1
60121150|Papel de construcción|O|O||D||1
60121151|Accesorios o tableros para dibujo o bosquejo|O|O||D||1
60121152|Tablillas de escritura|O|O||D||1
60121153|Hojas de transferencia|O|O||D||1
60121200|Pintura del aula y de bellas artes, medios, aplicadores y accesorios|O|O||D||1
60121201|Pintura témpera líquida tradicional|O|O||D||1
60121202|Pintura témpera líquida contemporánea|O|O||D||1
60121203|Pintura témpera en polvo|O|O||D||1
60121204|Pintura témpera lavable|O|O||D||1
60121205|Pastillas de témpera|O|O||D||1
60121206|Pintura líquida para cuerpo o cara|O|O||D||1
60121207|Pintura en pasta para cuerpo o cara|O|O||D||1
60121208|Pintura de marcador para cuerpo o cara|O|O||D||1
60121209|Pintura de tatuaje provisional|O|O||D||1|Pintura de henna
60121210|Pintura dactilar  lavable|O|O||D||1
60121211|Pintura acrílica estilo escolar|O|O||D||1
60121212|Pintura acrílica para aerógrafo|O|O||D||1
60121213|Pinturas o medios al oleo sintéticos tratados con calor|O|O||D||1
60121214|Pinturas o medios al óleo solubles en agua|O|O||D||1
60121215|Pintura removible de baja viscosidad para vidrio o cerámica|O|O||D||1
60121216|Pintura permanente de baja viscosidad para vidrio o cerámica|O|O||D||1
60121217|Pintura gel removible de alta viscosidad para vidrio o cerámica|O|O||D||1
60121218|Pintura gel permanente de alta viscosidad para vidrio o cerámica|O|O||D||1
60121219|Pintura para cerámica o vidrio horneado|O|O||D||1
60121220|Pintura para vidrio o cerámica de sistema de marcador|O|O||D||1
60121221|Pintura de acuarela de platillo|O|O||D||1
60121222|Pintura de acuarela en tubo|O|O||D||1
60121223|Pintura de acuarela líquida|O|O||D||1
60121224|Pintura de enmascarar para acuarela líquida|O|O||D||1
60121225|Medios para pintura de acuarela|O|O||D||1
60121226|Pinceles para acuarela|O|O||D||1
60121227|Pinceles orientales|O|O||D||1
60121228|Pinceles de utilidad|O|O||D||1
60121229|Pinceles especializados|O|O||D||1
60121230|Pinceles de caballete|O|O||D||1
60121231|Espátulas de paleta|O|O||D||1
60121232|Rodillos para impresión a mano|O|O||D||1
60121233|Sellos de esponja|O|O||D||1
60121234|Espátulas para aplicación de pintura|O|O||D||1
60121235|Pipetas para mezclar pinturas o tintes|O|O||D||1|Pipetas de plástico
60121236|Peinillas o utensilios para aplicación de pintura o tinta|O|O||D||1|Peines o herramientas para la aplicación de pintura o tinta
60121237|Paletas para mezclar pintura o tinta|O|O||D||1
60121238|Vasijas para pintura o para mezclar o almacenar pintura|O|O||D||1
60121239|Botellas o tazas para pintura|O|O||D||1
60121241|Productos de limpieza de utensilios o pinceles|O|O||D||1
60121242|Delantales para pintar|O|O||D||1
60121243|Blusones para artistas|O|O||D||1|Delantales para artistas
60121244|Tiras extensoras|O|O||D||1
60121245|Extensores de lienzo|O|O||D||1
60121246|Caballetes metálicos|O|O||D||1
60121247|Caballetes de madera|O|O||D||1
60121248|Caballetes de sobremesa|O|O||D||1
60121249|Caballetes de presentación|O|O||D||1
60121250|Portafolio para dibujos|O|O||D||1
60121251|Pintura al gouache|O|O||D||1|Pintura acrílica
60121252|Bandejas para pinturas|O|O||D||1
60121253|Aerógrafos para arte|O|O||D||1
60121300|Productos de corte de manualidades y arte|O|O||D||1
60121301|Guillotinas para cortar papel|O|O||D||1
60121302|Cortadora de paspartú|O|O||D||1
60121303|Cuchillas para paspartú|O|O||D||1
60121304|Espátulas de artista|O|O||D||1
60121305|Cortador rotativo de tela o papel|O|O||D||1
60121306|Cortadoras de papel en círculos u óvalos|O|O||D||1
60121400|Enmarcado de cuadro|O|O||D||1
60121401|Marcos de madera preensamblados|O|O||D||1|Portaretratos de madera preensamblados
60121402|Marcos de secciones de madera|O|O||D||1
60121403|Marcos metálicos preensamblados|O|O||D||1|Portaretratos metálicos preensamblados
60121404|Marcos de secciones de metal|O|O||D||1
60121405|Marcos  ajustables|O|O||D||1|Portaretratos ajustables
60121406|Marcos de plástico|O|O||D||1|Portaretratos de plástico
60121407|Marcos en forma de cubo transparente|O|O||D||1
60121408|Clavadoras de puntillas o accesorios para marcos|O|O||D||1
60121409|Caja de ingletes|O|O||D||1
60121410|Dispositivos para colgar cuadros|O|O||D||1
60121411|Paneles acrílicos para marcos|O|O||D||1
60121412|Paneles de vidrio para marcos|O|O||D||1
60121413|Organizadores o álbumes para fotos|O|O||D||1
60121414|Monturas magnéticas para marcos|O|O||D||1
60121415|Kits de marcos|O|O||D||1
60121500|Utensilios de dibujo, suministros y accesorios|O|O||D||1
60121501|Marcadores a base de agua|O|O||D||1|Plumones a base de agua
60121502|Marcadores de base disolvente|O|O||D||1|Plumones de base disolvente
60121503|Marcadores lavables|O|O||D||1|Plumones lavables
60121504|Marcadores para caligrafía|O|O||D||1|Plumones para caligrafía
60121505|Marcadores de tela|O|O||D||1|Plumones para tele
60121506|Marcadores metálicos|O|O||D||1|Plumones metálicos
60121507|Marcadores de témpera o tiza para ventanas|O|O||D||1|Marcador de tiza borrable
60121508|Marcadores de pintura|O|O||D||1
60121509|Crayones de cera|O|O||D||1
60121510|Crayones de base de soya|O|O||D||1
60121511|Crayones especializados|O|O||D||1
60121512|Crayones de acuarela|O|O||D||1
60121513|Pastel seco|O|O||D||1
60121514|Pastel de tiza|O|O||D||1|Pintura al pastel
60121515|Pastel a base de aceite|O|O||D||1
60121516|Carboncillo|O|O||D||1
60121517|Carboncillo vine|O|O||D||1
60121518|Lápices de grafito|O|O||D||1
60121519|Lápices de colores para dibujar de base de cera|O|O||D||1
60121520|Carboncillos|O|O||D||1|Carboncillo comprimido
60121521|Lápices de acuarela|O|O||D||1
60121522|Bolígrafos de base acuosa|O|O||D||1
60121523|Bolígrafos permanentes|O|O||D||1
60121524|Bolígrafos de gel|O|O||D||1|Lápices de carboncillo
60121525|Rapidógrafos|O|O||D||1|Estilógrafo
60121526|Bolígrafos para caligrafía|O|O||D||1
60121531|Borradores de lápices color rosados|O|O||D||1
60121532|Borradores de goma moldeable|O|O||D||1
60121533|Borradores de vinilo|O|O||D||1|Estilógrafo
60121534|Borradores de plástico|O|O||D||1
60121535|Borradores de goma|O|O||D||1
60121536|Borrador de crayón|O|O||D||1
60121537|Plumillas o sus accesorios|O|O||D||1
60121538|Kits de caligrafía|O|O||D||1
60121539|Fijadores de dibujo|O|O||D||1
60121540|Telas de dibujo|O|O||D||1
60121600|Materiales de estudio|O|O||D||1
60121601|Maniquíes de madera|O|O||D||1
60121602|Paneles o espejos de acrílico transparente|O|O||D||1
60121603|Placas de fricción de plástico|O|O||D||1
60121604|Accesorios para ayudas de estudio|O|O||D||1
60121605|Modelos anatómicos|O|O||D||1
60121606|Pantallas de fondo|O|O||D||1
60121700|Suministros y accesorios de grabados|O|O||D||1
60121701|Sellos de estampación de caucho|O|O||D||1|Sellos de caucho
60121702|Almohadilla para sellos de estampación de caucho|O|O||D||1|Almohadilla para sellos  de caucho
60121703|Accesorios para estampación de caucho|O|O||D||1|Accesorios para sellos de caucho
60121704|Linóleo para impresión xilográfica|O|O||D||1
60121705|Bloques de madera para impresión|O|O||D||1
60121706|Bloques sintéticos para impresión|O|O||D||1
60121707|Accesorios para impresión xilográfica|O|O||D||1
60121708|Planchas de huecograbado o litografía|O|O||D||1
60121709|Mantillas para huecograbado o litografía|O|O||D||1
60121710|Limpiones para huecograbado o litografía|O|O||D||1|Tintas a base de agua
60121711|Planchas calientes para huecograbado o litografía|O|O||D||1
60121712|Prensas de impresión para huecograbado o litografía|O|O||D||1
60121713|Rodillos y aplanadoras de impresión|O|O||D||1
60121714|Utensilios de grabado para huecograbado|O|O||D||1
60121715|Estaciones de impresión o pantallas para serigrafía|O|O||D||1
60121716|Accesorios para serigrafía|O|O||D||1
60121717|Punzones para grabado|O|O||D||1
60121718|Extendedores de tinta de impresión|O|O||D||1
60121800|Tintas de dibujo e impresión|O|O||D||1
60121801|Tintas para afiches a base de agua|O|O||D||1
60121802|Tintas acrílicas a base de agua|O|O||D||1
60121803|Tintas para serigrafía a base de aceite|O|O||D||1
60121804|Tintas para textiles a base de agua|O|O||D||1
60121805|Tintas para textiles a base de aceite|O|O||D||1
60121806|Tintas de sublimación para grabado|O|O||D||1
60121807|Tintas para huecograbado o litografía a base de aceite|O|O||D||1
60121808|Tintas para monoimpresión a base de aceite|O|O||D||1
60121809|Tintas para monoimpresión a base de agua|O|O||D||1
60121810|Tintas para dibujar a base de agua|O|O||D||1
60121811|Tintas para dibujar de base solvente|O|O||D||1
60121812|Tintas para caligrafía|O|O||D||1
60121813|Tintas para serigrafía|O|O||D||1
60121814|Barnices litográficos|O|O||D||1
60121900|Materiales de decoración de telas y arte textil y suministros|O|O||D||1
60121901|Muselina|O|O||D||1
60121902|Fieltro|O|O||D||1
60121903|Pieles para manualidades|O|O||D||1
60121904|Mezclas de algodón|O|O||D||1
60121905|Lienzos estampables|O|O||D||1
60121906|Estampables presensibilizados|O|O||D||1
60121907|Estampables de algodón|O|O||D||1
60121908|Estampables mezclados|O|O||D||1
60121909|Ceras para batik|O|O||D||1
60121910|Accesorios para batik|O|O||D||1
60121911|Tela para batik|O|O||D||1
60121912|Difuminadores|O|O||D||1
60122000|Equipo de tejido, pespunteado y cosido y accesorios|O|O||D||1
60122002|Accesorios para tejer|O|O||D||1
60122003|Agujas para coser a mano|O|O||D||1
60122004|Kits de manualidades con cuerda|O|O||D||1
60122005|Telares manuales|O|O||D||1
60122006|Telares de mesa|O|O||D||1
60122007|Telares de piso|O|O||D||1
60122008|Cordón plástico (rexlace)|O|O||D||1
60122009|Accesorios de encordado o acordonado|O|O||D||1
60122100|Velas artesanales|O|O||D||1
60122101|Mechas para la fabricación de velas|O|O||D||1
60122102|Moldes para la fabricación de velas|O|O||D||1
60122103|Accesorios para la fabricación de velas|O|O||D||1
60122200|Ebanistería|O|O||D||1
60122201|Materiales para artesanías en madera|O|O||D||1
60122202|Materiales para acabados|O|O||D||1
60122203|Herramientas para quemado de madera|O|O||D||1
60122204|Herramientas para tallar|O|O||D||1
60122300|Suministros de cestería|O|O||D||1
60122301|Juncos para cestería|O|O||D||1
60122302|Kits para proyectos de cestería|O|O||D||1
60122400|Suministros de vidrieras de colores|O|O||D||1
60122401|Fragmentos de vidrios de colores|O|O||D||1
60122402|Herramientas o accesorios para vidrios de colores|O|O||D||1
60122500|Manualidades de papel y papel artesanal|O|O||D||1
60122501|Utensilios para dar formas al papel|O|O||D||1
60122502|Marcos de papel|O|O||D||1
60122503|Platos o bandejas de papel|O|O||D||1
60122504|Filtros de papel|O|O||D||1
60122506|Blondas de papel|O|O||D||1
60122507|Bastidores o moldes para papel hecho a mano|O|O||D||1
60122508|Láminas absorbentes o fieltros para papel hecho a mano|O|O||D||1
60122509|Pulpa o materias primas para papel hecho a mano|O|O||D||1
60122600|Mosaicos|O|O||D||1
60122601|Azulejos para mosaico|O|O||D||1
60122602|Moldes para mosaicos|O|O||D||1
60122603|Herramientas para mosaicos|O|O||D||1
60122604|Accesorios para mosaicos|O|O||D||1
60122700|Pinturas de esmaltado y accesorios|O|O||D||1
60122701|Pinturas o medios para esmaltar|O|O||D||1
60122702|Formas de cobre|O|O||D||1
60122703|Accesorios para esmaltar|O|O||D||1
60122704|Hornos para esmaltar|O|O||D||1
60122800|Máscaras|O|O||D||1
60122801|Formas para hechura de máscaras|O|O||D||1
60122900|Cuentas o accesorios de enhebrado de cuentas|O|O||D||1
60122901|Cuentas pequeñas|O|O||D||1
60122902|Cuentas tipo “pony”|O|O||D||1
60122903|Cuentas de madera|O|O||D||1
60122904|Cuentas de paja|O|O||D||1
60122905|Cuentas de cerámica|O|O||D||1
60122906|Cuentas de vidrio|O|O||D||1
60122907|Cuentas surtidas o de decoración|O|O||D||1
60122908|Accesorios de cuentas|O|O||D||1
60122909|Cuentas de plástico|O|O||D||1
60123000|Artesanía de espuma|O|O||D||1
60123001|Formas de icopor|O|O||D||1|Formas de espuma de poliestireno EPS, Formas de poliestireno expandido EPS, Formas de unice
60123002|Utensilios para artesanía de espuma|O|O||D||1
60123100|Artesanía de cañas de felpilla|O|O||D||1
60123101|Cañas de felpilla grandes|O|O||D||1
60123102|Cañas de felpilla de algodón|O|O||D||1
60123103|Cañas de felpilla abultadas|O|O||D||1
60123200|Materiales de artesanía de cintas|O|O||D||1
60123201|Lazos de papel|O|O||D||1
60123202|Cintas de seda|O|O||D||1
60123203|Cintas sintéticas|O|O||D||1
60123204|Cintas decorativas|O|O||D||1
60123300|Pompones de artesanía|O|O||D||1
60123301|Pompones acrílicos para manualidades|O|O||D||1
60123302|Pompones brillantes para manualidades|O|O||D||1
60123303|Cuentas de pompones para manualidades|O|O||D||1
60123400|Materiales de ojos móviles|O|O||D||1
60123401|Ojos móviles no autoadhesivos|O|O||D||1
60123402|Ojos móviles autoadhesivos|O|O||D||1
60123403|Ojos móviles decorativos|O|O||D||1
60123500|Materiales de artesanía de cuero|O|O||D||1
60123501|Materiales de cuero o de acordonados de cuero|O|O||D||1
60123502|Accesorios de cuero|O|O||D||1
60123600|Purpurina|O|O||D||1|Brillantina
60123601|Pegante de purpurina|O|O||D||1|Pegamento con brillantina
60123602|Puntos de purpurina|O|O||D||1|Brillantina
60123603|Joyas de purpurina|O|O||D||1|Joyas con brillantina
60123604|Purpurina de plástico|O|O||D||1|Brillantina de plástico
60123605|Purpurina iridiscente|O|O||D||1|Brillantina iridiscente
60123606|Purpurina metálica|O|O||D||1|Brillantina metálica
60123700|Materiales de artesanía de macramé y accesorios|O|O||D||1
60123701|Cordón de macramé|O|O||D||1
60123702|Cuentas para macramé|O|O||D||1
60123703|Accesorios para macramé|O|O||D||1
60123800|Suministros y accesorios de veteado|O|O||D||1
60123801|Tintas para veteado|O|O||D||1
60123802|Accesorios para veteado|O|O||D||1
60123900|Lentejuelas y ribetes|O|O||D||1
60123901|Lentejuelas o ribetes decorativos|O|O||D||1
60124000|Suministros de artesanía del corcho y accesorios|O|O||D||1
60124001|Planchas de corcho|O|O||D||1
60124002|Tapones de corcho o accesorios|O|O||D||1
60124100|Materiales de proyecto multicultural y accesorios|O|O||D||1
60124101|Productos de pintura multicultural|O|O||D||1
60124102|Productos de artesanía multicultural|O|O||D||1
60124200|Proyectos completos de planes de estudios|O|O||D||1
60124201|Esculturas de mylar|O|O||D||1
60124300|Compuestos de modelado y arcilla, equipo de cerámica y accesorios|O|O||D||1
60124301|Arcilla húmeda cocida en horno|O|O||D||1
60124302|Arcilla seca cocida en horno|O|O||D||1
60124303|Mobiliario para hornos|O|O||D||1
60124304|Hornos para a cocción de cerámica|O|O||D||1
60124305|Accesorios de hornos para la cocción de  cerámica|O|O||D||1
60124306|Tornos de alfarero para cerámicas hechas a mano|O|O||D||1
60124307|Extrusoras para materiales de modelado|O|O||D||1
60124308|Conos para hornos de cocción|O|O||D||1
60124309|Paletas de alfarería|O|O||D||1
60124310|Tornos de decoración para alfarería|O|O||D||1
60124311|Utensilios para arcilla o modelado|O|O||D||1
60124312|Azulejos de cerámica cocidos|O|O||D||1
60124313|Recipientes para almacenamiento de arcilla|O|O||D||1
60124314|Compuestos para modelado plastificados no endurecibles|O|O||D||1
60124315|Compuestos para modelado  no endurecibles a base de aceite|O|O||D||1
60124316|Compuestos para modelado o arcilla secados al aire|O|O||D||1
60124317|Masa para modelado|O|O||D||1
60124318|Papel maché|O|O||D||1
60124319|Compuestos para modelado especializados|O|O||D||1
60124320|Compuestos de yeso|O|O||D||1
60124321|Compuestos para modelado o arcilla de endurecimiento en horno|O|O||D||1
60124322|Compuestos para modelado de plástico|O|O||D||1
60124323|Moldes para dar forma a los compuestos para modelado|O|O||D||1
60124324|Kits para modelado de arcilla|O|O||D||1
60124325|Arcilla de papel|O|O||D||1
60124400|Metales de artesanía|O|O||D||1
60124401|Hoja fina de metal de cobre|O|O||D||1|Lámina de cobre para repujado
60124402|Hoja fina de metal de  aluminio|O|O||D||1|Lámina de aluminio para repujado
60124403|Alambre de aluminio|O|O||D||1
60124404|Hoja fina de metal de latón|O|O||D||1|Lámina de latón para repujado
60124406|Placas o láminas de plata|O|O||D||1
60124407|Alambre de plata|O|O||D||1
60124408|Bolitas de peltre|O|O||D||1
60124409|Lingotes de peltre|O|O||D||1
60124410|Placas de láminas de bronce|O|O||D||1
60124411|Alambre de cobre "nu gold"|O|O||D||1
60124412|Alambre suave galvanizado|O|O||D||1
60124500|Suministros y accesorios de escultura|O|O||D||1
60124501|Envoltura de yeso|O|O||D||1
60124502|Resinas para vaciado|O|O||D||1
60124503|Accesorios para esculturas|O|O||D||1
60124504|Repisas para rompecabezas|O|O||D||1
60124505|Ampollas o accesorios|O|O||D||1
60124506|Utensilios o moldes o juguetes de plástico para arena o agua|O|O||D||1
60124507|Arena para jugar|O|O||D||1
60124508|Centros de actividades o mesas de arena o agua|O|O||D||1
60124509|Sets de vehículos|O|O||D||1|Esculturas de vehículos
60124510|Sets de vías de agua|O|O||D||1
60124511|Herramientas de juguete o kits de herramientas de juguete|O|O||D||1
60124512|Escúter|O|O||D||1|Patín del diablo
60124513|Bolsitas de fríjoles (beanbags)|O|O||D||1
60124514|Juguetes táctiles|O|O||D||1
60124515|Juguetes cognitivos|O|O||D||1
60131000|Instrumentos de teclado|O|O||D||1
60131001|Pianos|O|O||D||1
60131002|Acordeones|O|O||D||1
60131003|Órganos musicales|O|O||D||1
60131004|Celestas|O|O||D||1
60131005|Melodión|O|O||D||1|Melódica
60131006|Sintetizador|O|O||D||1
60131007|Melódica|O|O||D||1
60131100|Instrumentos de metal|O|O||D||1
60131101|Trompetas|O|O||D||1
60131102|Trombones|O|O||D||1
60131103|Sousafones|O|O||D||1|Sousáfono
60131104|Saxofones|O|O||D||1
60131105|Silbatos|O|O||D||1
60131106|Clarines|O|O||D||1
60131107|Saxhorno|O|O||D||1|Saxcorno
60131108|Cornos franceses|O|O||D||1|Trompa
60131109|Melófonos|O|O||D||1
60131110|Trompas alto|O|O||D||1|Trompa tenor
60131111|Bombardinos barítono|O|O||D||1
60131112|Fiscornos|O|O||D||1
60131113|Nabal|O|O||D||1
60131114|Tuba|O|O||D||1
60131115|Eufonio|O|O||D||1
60131116|Tubáfono|O|O||D||1
60131200|Instrumentos de viento de madera|O|O||D||1
60131201|Clarinetes|O|O||D||1
60131202|Oboes|O|O||D||1
60131203|Flautas musicales|O|O||D||1
60131204|Flautines|O|O||D||1
60131205|Cornetas musicales|O|O||D||1
60131206|Gaitas|O|O||D||1
60131207|Armónicas|O|O||D||1
60131208|Mirlitones|O|O||D||1|Turuta
60131209|Cornos ingleses|O|O||D||1|Corno inglés
60131210|Ocarinas|O|O||D||1
60131211|Daegum|O|O||D||1
60131212|Danso|O|O||D||1|Tanso
60131213|Tungso|O|O||D||1|Tongso
60131214|Taepyeongso|O|O||D||1
60131215|Jeok|O|O||D||1
60131216|Dangjeok|O|O||D||1
60131217|Dangpirie|O|O||D||1
60131218|Sepiri|O|O||D||1|Piri
60131219|So|O|O||D||1
60131220|Yak|O|O||D||1
60131221|Junggeum|O|O||D||1
60131222|Ji|O|O||D||1
60131223|Sogeum|O|O||D||1
60131224|Hyangpiri|O|O||D||1
60131225|Saenghwang|O|O||D||1
60131226|Hun|O|O||D||1
60131227|Nagak|O|O||D||1
60131228|Fagot|O|O||D||1
60131229|Cornamusa|O|O||D||1
60131230|Contrafagot|O|O||D||1
60131231|Sarrusofón|O|O||D||1
60131232|Corno sirena|O|O||D||1|Sirena
60131233|Flauta dulce|O|O||D||1
60131234|Clave|O|O||D||1
60131235|Quena|O|O||D||1|Flauta de caña
60131236|Quenacho|O|O||D||1
60131237|Zampoña|O|O||D||1
60131300|Instrumentos de cuerda|O|O||D||1
60131301|Clavecines|O|O||D||1
60131302|Clavicordios|O|O||D||1
60131303|Guitarras|O|O||D||1
60131304|Violines|O|O||D||1
60131305|Arpas|O|O||D||1
60131306|Banyos|O|O||D||1|Banjo
60131307|Mandolinas|O|O||D||1
60131308|Violonchelos|O|O||D||1
60131309|Bajos|O|O||D||1
60131310|Gayageum|O|O||D||1
60131311|Geomungo|O|O||D||1
60131312|Ajaeng|O|O||D||1
60131313|Geum|O|O||D||1
60131314|Dangbipa|O|O||D||1|Bipa
60131315|Daejaeng|O|O||D||1
60131316|Seul|O|O||D||1
60131317|Wagonghu|O|O||D||1
60131318|Hyangbipa|O|O||D||1
60131319|Haegeum|O|O||D||1
60131320|Sogonghu|O|O||D||1
60131321|Sugonghu|O|O||D||1
60131322|Yangkum|O|O||D||1
60131323|Wolgeum|O|O||D||1
60131324|Ukelele|O|O||D||1
60131325|Viola|O|O||D||1
60131326|Instrumento nacional morin khuur|O|O||D||1|Morin juur
60131327|Yochin|O|O||D||1
60131328|Yatga|O|O||D||1
60131329|Shanz|O|O||D||1|Schanz
60131400|Instrumentos de percusión|O|O||D||1
60131401|Platillos|O|O||D||1
60131402|Campanas|O|O||D||1
60131403|Panderetas|O|O||D||1
60131404|Castañuelas|O|O||D||1
60131405|Tambores|O|O||D||1
60131406|Xilófonos|O|O||D||1
60131407|Vibráfonos|O|O||D||1|Vibes
60131408|Jing|O|O||D||1
60131409|Janggu|O|O||D||1
60131410|Kkwaengwari|O|O||D||1|Gong coreano, Kkwaenggwari
60131411|Buk|O|O||D||1
60131412|Galgo|O|O||D||1
60131413|Geongo|O|O||D||1
60131414|Gyobanggo|O|O||D||1
60131415|Banghyang|O|O||D||1
60131416|Sakko|O|O||D||1
60131417|Sogo|O|O||D||1
60131418|Yonggo|O|O||D||1
60131419|Ulla|O|O||D||1
60131420|Eunggo|O|O||D||1
60131421|Jabara|O|O||D||1
60131422|Jeolgo|O|O||D||1
60131423|Jwago|O|O||D||1
60131424|Jingo|O|O||D||1
60131425|Teukkyeong|O|O||D||1
60131426|Teukjong|O|O||D||1
60131427|Pyeongyeong|O|O||D||1
60131428|Pyeonjong|O|O||D||1
60131429|Eo|O|O||D||1
60131430|Nogo|O|O||D||1
60131431|Nodo|O|O||D||1
60131432|Noego|O|O||D||1
60131433|Noedo|O|O||D||1
60131434|Bak|O|O||D||1
60131435|Bu|O|O||D||1
60131436|Yeonggo|O|O||D||1
60131437|Yeongdo|O|O||D||1
60131438|Junggo|O|O||D||1
60131439|Chuk|O|O||D||1
60131440|Mugo|O|O||D||1
60131441|Carrillón|O|O||D||1|Xilófono
60131442|Maracas|O|O||D||1
60131443|Cabasas brasil|O|O||D||1
60131444|Timbales|O|O||D||1
60131445|Bongoes|O|O||D||1|Bongos
60131446|Congas|O|O||D||1
60131447|Armónica de metal|O|O||D||1|Lira de metal
60131448|Marimbas|O|O||D||1
60131449|Triángulo instrumental|O|O||D||1
60131450|Maracas|O|O||D||1|Huevo rítmico
60131451|Güiros|O|O||D||1
60131452|Agitadores (shakers) musicales|O|O||D||1|Ganzá
60131453|Gong de madera|O|O||D||1
60131454|Campanas (instrumento)|O|O||D||1|Campanas musicales
60131455|Gong de bronce o latón|O|O||D||1
60131456|Tom-tom|O|O||D||1|Tambor
60131457|Timbal|O|O||D||1
60131458|Palo de lluvia|O|O||D||1
60131459|Tinya|O|O||D||1
60131460|Ton-ton|O|O||D||1|Batería
60131500|Piezas y accesorios de instrumentos musicales|O|O||D||1
60131501|Metrónomos|O|O||D||1
60131502|Lengüetas|O|O||D||1
60131503|Cuerdas o plectros para instrumentos|O|O||D||1
60131504|Clavijas de afinación|O|O||D||1
60131505|Bases o soportes de partituras para instrumentos musicales|O|O||D||1
60131506|Accesorios para instrumentos de cuerda|O|O||D||1
60131507|Accesorio para instrumentos de percusión|O|O||D||1
60131508|Cajas musicales o mecanismos|O|O||D||1
60131509|Boquillas|O|O||D||1
60131510|Fundas o estuches o accesorios para instrumentos musicales|O|O||D||1
60131511|Sordinas|O|O||D||1|Silenciadores musicales
60131512|Barras de afinación|O|O||D||1
60131513|Batutas|O|O||D||1
60131514|Almohadillas de flautín|O|O||D||1
60131515|Unidad de efectos para instrumentos musicales|O|O||D||1
60131516|Afinador de instrumentos electrónicos|O|O||D||1|Metróno de afinación electrónico
60131517|Estuche o maleta de mano protectora para instrumentos musicales|O|O||D||1|Estuche o maleta para instrumentos musicales
60131518|Correa o arnés para instrumentos musicales|O|O||D||1
60131519|Pedestal para instrumentos musicales|O|O||D||1|Soporte o atril para instrumentos musicales
60131520|Baqueta|O|O||D||1
60131600|Sets de instrumentos musicales|O|O||D||1
60131601|Sets de grupos de acompañamiento|O|O||D||1|Conjunto de ritmos para bandas
60131700|Instrumentos musicales de sonidos alternativos|O|O||D||1
60131701|Tubos de percusión|O|O||D||1|Tubo sonoro diatónico
60131702|Golpecitos de disco|O|O||D||1
60131703|Cascos de caballos|O|O||D||1|Pezuña de caballo
60131800|Accesorios de música y danza|O|O||D||1
60131801|Velos para danza|O|O||D||1
60131802|Palitos de ritmo|O|O||D||1|Palos de percusión
60131803|Aros o bastones de ritmo|O|O||D||1|Ula ula o cintas para baile
60141000|Juguetes|O|O||D||1
60141001|Globos o pelotas de juguete|O|O||D||1
60141002|Muñecas|O|O||D||1
60141003|Casas de muñecas|O|O||D||1
60141004|Animales o títeres de peluche|O|O||D||1
60141005|Casas de juego|O|O||D||1
60141006|Bloques de construcción|O|O||D||1
60141007|Juguetes para montar|O|O||D||1
60141008|Juguetes para jalar|O|O||D||1
60141009|Kits de ciencias para niños|O|O||D||1
60141010|Vehículos de juguete|O|O||D||1
60141011|Trenes de juguete|O|O||D||1
60141012|Juguetes inflables|O|O||D||1
60141013|Partes o accesorios de muñecas|O|O||D||1
60141014|Yoyós|O|O||D||1
60141015|Cometas|O|O||D||1|Papalotes
60141016|Tazos|O|O||D||1
60141017|Caleidoscopios|O|O||D||1
60141018|Pompones|O|O||D||1
60141019|Piñatas|O|O||D||1
60141020|Bumeranes|O|O||D||1
60141021|Discos voladores|O|O||D||1
60141022|Baldes de juguete|O|O||D||1
60141023|Juguetes para el baño|O|O||D||1
60141024|Sonajeros|O|O||D||1|Sonajas
60141025|Armas de juguete|O|O||D||1
60141026|Trompos|O|O||D||1
60141100|Juegos|O|O||D||1
60141101|Juegos educativos|O|O||D||1
60141102|Juegos de mesa|O|O||D||1
60141103|Naipes|O|O||D||1
60141104|Juegos de video|O|O||D||1
60141105|Rompecabezas|O|O||D||1
60141106|Dados|O|O||D||1
60141107|Bingo|O|O||D||1
60141108|Juegos clásicos|O|O||D||1
60141109|Juegos colaborativos|O|O||D||1
60141110|Juegos de estrategia|O|O||D||1
60141111|Accesorios para juegos|O|O||D||1
60141112|Libros de juegos|O|O||D||1
60141113|Juegos de lotería|O|O||D||1
60141114|Juegos de memoria|O|O||D||1
60141115|Kits de juegos|O|O||D||1
60141116|Juego baduk o go y accesorios|O|O||D||1|Juego de go y accesorios
60141117|Juego del lut o de cuatro palos y accesorios|O|O||D||1|Juego de loto de cuatro palos y accesorios
60141118|Juego janggi y accesorios|O|O||D||1|Juego de ajedrez coreano y accesorios
60141200|Equipo de juegos activos y accesorios|O|O||D||1
60141201|equipo para motricidad gruesa o equilibrio|O|O||D||1|Juegos de motricidad gruesa o equilibrio
60141202|Piscinas de pelotas y accesorios|O|O||D||1|Alberca de pelotas y accesorios
60141203|Casitas de juego|O|O||D||1|Cabañas de juguete
60141204|Triciclos o carretillas|O|O||D||1|Velocípedo de tres ruedas
60141205|zonas acolchadas de juego|O|O||D||1|Equipos acolchados de juego
60141300|Sistemas de construcción y bloques infantiles|O|O||D||1|Bloques y sistemas de edificaciones para niños
60141302|Sets de construcción|O|O||D||1|Kit de construcción
60141303|Esteras para juegos|O|O||D||1|Alfombra para juegos
60141304|Sistemas de trenes o accesorios|O|O||D||1|Rieles de juguete o accesorios
60141305|Bloques de unidades|O|O||D||1|Bloques de madera para construcción
60141306|Vehículos de juego|O|O||D||1|Automóviles de juguete
60141307|Animales de juguete|O|O||D||1|Criaturas de juguete
60141400|Equipo de representación teatral y accesorios|O|O||D||1
60141401|Disfraces o accesorios|O|O||D||1
60141402|Centros para vestirse|O|O||D||1|Vestidores para niños
60141403|Unidades o accesorios para el cuidado de la casa|O|O||D||1|Artículos de limpieza para el cuidado de la casa
60141404|Platos de comida de  juguete o accesorios|O|O||D||1
60141405|Kits o materiales para juegos de simulación|O|O||D||1|Botiquín de primeros auxilios de juguete
64122100|Contratos de seguros de salud|O|O||D||1
70101500|Explotaciones pesqueras|O|O||D||1|Servicio de explotaciones pesqueras
70101501|Operaciones de pesca comercial|O|O||D||1
70101502|Servicios de puerto para la flota pesquera|O|O||D||1|Servicios portuarios de pesca
70101503|Instalaciones pesqueras en tierra|O|O||D||1|Construcciones para pesca en tierra
70101504|Operaciones de pesca de altura|O|O||D||1|Operaciones de pesca en altamar
70101505|Pesca por sonar|O|O||D||1|Pesca por ondas sonoras
70101506|Pesca de ballenas|O|O||D||1|Pesca de cetáceos
70101507|Pesca de arrastre|O|O||D||1
70101508|Pesca con sedal y anzuelo|O|O||D||1
70101509|Pesca con redes barrederas|O|O||D||1
70101510|Redes de pesca|O|O||D||1|Mallas de pesca
70101600|Vigilancia pesquera|O|O||D||1|Servicio de vigilancia pesquera
70101601|Servicios de información o documentación de la industria pesquera|O|O||D||1
70101602|Servicios de investigación o experimentación de la industria pesquera|O|O||D||1
70101603|Recopilación o distribución de datos de la industria pesquera|O|O||D||1
70101604|Explotación comercial de los recursos pesqueros|O|O||D||1|Gestión comercial pesquera
70101605|Administración de la flota pesquera|O|O||D||1|Gestión de la flota pesquera
70101606|Cooperativas de pesca|O|O||D||1
70101607|Conservación o protección de los recursos pesqueros|O|O||D||1|Preservación o protección de los recursos pesqueros
70101700|Industria y tecnología pesquera|O|O||D||1|Servicios industriales y tecnológicos de pesca
70101701|Servicios tecnológicos de pesca|O|O||D||1
70101702|Servicios de producción de los subproductos de la pesca|O|O||D||1
70101703|Producción pesquera|O|O||D||1|Producción de peces
70101704|Almacenamiento de pescados|O|O||D||1|Almacenaje de pescados
70101800|Recursos pesqueros|O|O||D||1|Servicios de recursos pesqueros
70101801|Recursos de la pesca en aguas interiores|O|O||D||1
70101802|Recursos de estanques piscícolas|O|O||D||1
70101803|Criadero de peces|O|O||D||1|Vivero de peces
70101804|Fincas piscícolas|O|O||D||1|Granjas acuícolas
70101805|Recursos de subproductos de la pesca|O|O||D||1
70101806|Evaluación de los recursos de las pesquerías|O|O||D||1|Valoración de los recursos pesqueros
70101900|Acuicultura|O|O||D||1|Servicios de acuicultura
70101901|Maricultura|O|O||D||1|Cultivo de organismos marinos
70101902|Ostricultura|O|O||D||1|Cultivo de ostras
70101903|Cría de mariscos|O|O||D||1|Cultivo de mariscos
70101904|Cultivo de camarones|O|O||D||1|Cría de camarones
70101905|Piscicultura|O|O||D||1|Cultivo de peces
70111500|Plantas y árboles ornamentales|O|O||D||1|Servicios para plantas y árboles ornamentales
70111501|Servicios de siembra de árboles, arbustos o plantas ornamentales|O|O||D||1|Servicios de siembra de árboles, arbustos o plantas decorativas
70111502|Servicios de poda de arbustos o plantas ornamentales|O|O||D||1|Servicios de poda de arbustos o plantas decorativas
70111503|Servicios de poda de árboles|O|O||D||1
70111504|Servicios de apuntalamiento|O|O||D||1|Servicios de vigorizado
70111505|Servicios de cirugía arbórea|O|O||D||1|Servicios de injertos
70111506|Servicios de arbolistas|O|O||D||1|Servicio de arboristas
70111507|Servicios de traslado de árboles, arbustos o plantas ornamentales|O|O||D||1|Servicios de remoción de árboles, arbustos o plantas decorativas
70111508|Servicios de fumigación  de plantas o árboles ornamentales|O|O||D||1
70111600|Plantas de flor|O|O||D||1|Servicios para plantas de flor
70111601|Servicios de plantación|O|O||D||1|Servicios de siembra
70111602|Servicios de vivero|O|O||D||1|Servicios de criadero de plantas
70111603|Servicios de floricultura|O|O||D||1
70111700|Parques, jardines y huertos|O|O||D||1|Servicios para parques, jardines y huertos
70111701|Servicio de administración o mantenimiento de huertos|O|O||D||1|Servicio de gestión o mantenimiento de huertos
70111702|Servicios de administración o mantenimiento de viñedos|O|O||D||1|Servicio de gestión o mantenimiento de viñas
70111703|Servicios de plantación o mantenimiento de jardines|O|O||D||1
70111704|Servicios de asesoría en horticultura|O|O||D||1|Servicios de consultoría en horticultura
70111705|Servicios de mantenimiento de cementerios|O|O||D||1|Servicios de mantenimiento de panteones
70111706|Servicios de mantenimiento del césped|O|O||D||1|Servicios de mantenimiento del pasto
70111707|Servicio de mantenimiento del césped en las carreteras|O|O||D||1|Servicios de mantenimiento del pasto en las carreteras
70111708|Servicios de acolchado orgánico|O|O||D||1|Servicio de mantillo
70111709|Servicios de siembra|O|O||D||1
70111710|Servicios de corte de césped|O|O||D||1|Servicios de corte de pasto
70111711|Servicios de siembra de ramitas|O|O||D||1
70111712|Servicios de fumigación  de parques o jardines|O|O||D||1
70111713|Servicios de administración o mantenimiento de parques|O|O||D||1|Servicios de gestión o mantenimiento de parques
70121500|Industria lechera|O|O||D||1|Servicios para la industria lechera
70121501|Administración de hatos lecheros|O|O||D||1|Administración de ganados lecheros
70121502|Fomento de la industria láctea|O|O||D||1|Fomento a la industria de la leche
70121503|Tecnología lechera|O|O||D||1
70121504|Servicios de laboratorio de lácteos|O|O||D||1
70121505|Elaboración propia de fincas  lecheras|O|O||D||1|Granja lechera
70121600|Industria ganadera|O|O||D||1|Servicios para la industria ganadera
70121601|Cría de ganado|O|O||D||1
70121602|Servicios de genética ganadera|O|O||D||1
70121603|Sericultura|O|O||D||1|Cría de gusano de seda
70121604|Explotación ganadera|O|O||D||1
70121605|Sistemas de cría en fincas|O|O||D||1
70121606|Servicios de producción de aves de corral|O|O||D||1
70121607|Servicios de reproducción de ganado menor|O|O||D||1
70121608|Servicios de producción bovina|O|O||D||1|Servicios de producción vacuna
70121610|Apicultura|O|O||D||1|Cría de abejas
70121700|Gestión ganadera|O|O||D||1|Servicios de gestión ganadera
70121701|Selección ganadera|O|O||D||1
70121702|Servicios de exhibición de ganado|O|O||D||1
70121703|Servicios de sacrificio de ganado|O|O||D||1
70121704|Administración de hatos|O|O||D||1|Administración de ganado
70121705|Servicios de cría y cuidado del ganado|O|O||D||1|Servicios de cría y cuidado del hato
70121800|Industria de animales domésticos|O|O||D||1|Servicios para la industria de animales domésticos
70121801|Servicios de cría de animales domésticos|O|O||D||1
70121802|Servicios de cuidado de animales domésticos|O|O||D||1
70121803|Servicios de residencia canina|O|O||D||1|Refugios de animales
70121900|Servicios de pastos y dehesas|O|O||D||1|Servicios de pastoreo y manejo de su extensión
70121901|Mejoramiento de pastizales|O|O||D||1|Mejoramiento del prado
70121902|Manejo de pasturas|O|O||D||1|Manejo de hierba
70121903|Investigación de tierras de pastoreo|O|O||D||1
70122000|Salud animal|O|O||D||1|Servicios veterinarios
70122001|Nutrición animal|O|O||D||1
70122002|Control de enfermedades animales|O|O||D||1
70122003|Tripanosomiasis animal|O|O||D||1
70122004|Servicios de control de patas y boca|O|O||D||1
70122005|Servicios de medicación preventiva de salud animal|O|O||D||1|Medicación preventiva para la salud animal
70122006|Servicios de vacunación animal|O|O||D||1
70122007|Administración veterinaria|O|O||D||1|Gestión veterinaria
70122008|Tecnología para laboratorio veterinario|O|O||D||1
70122009|Servicios hospitalarios para animales|O|O||D||1
70122010|Servicios de información de salud animal|O|O||D||1
70131500|Protección del terreno y del suelo|O|O||D||1|Servicios de protección del terreno y suelo
70131501|Servicios de control o evaluación de la desertificación|O|O||D||1
70131502|Servicios de conservación o protección del suelo|O|O||D||1|Servicios de preservación o protección del suelo
70131503|Servicios de control de la erosión|O|O||D||1|Servicios de control del deterioro de suelo
70131504|Fijación de dunas|O|O||D||1
70131505|Acondicionamiento del suelo|O|O||D||1|Acondicionamiento del terreno
70131506|Mejoramiento del suelo|O|O||D||1|Mejoramiento del terreno
70131600|Preparación del terreno y del suelo|O|O||D||1|Servicios de preparación del terreno y suelo
70131601|Servicios de aplicación de fertilizantes|O|O||D||1|Servicios de aplicación de abono
70131602|Servicios de esparcido de cal|O|O||D||1|Servicios de esparcido de caliza
70131603|Servicios de arado|O|O||D||1
70131604|Servicios de preparación de semilleros|O|O||D||1
70131605|Servicios de tratamiento químico del suelo|O|O||D||1|Servicios de tratamientos químicos para terrenos
70131700|Gestión del terreno y del suelo|O|O||D||1|Servicios de gestión para terrenos y suelos
70131701|Planificación de tierras|O|O||D||1|Planificación del uso del terreno
70131702|Evaluación de tierras|O|O||D||1
70131703|Recuperación de tierras|O|O||D||1
70131704|Planificación o valoración de zonas agroecológicas|O|O||D||1|Evaluación o planificación de zonas agroecológicas
70131705|Clasificación del suelo|O|O||D||1|Clasificación de terrenos
70131706|Ordenación de las cuencas hidrográficas|O|O||D||1|Manejo de cuencas
70131707|Análisis de fertilidad del suelo|O|O||D||1|Análisis de fertilidad del terreno
70131708|Pedología|O|O||D||1|Estudio y clasificación del suelo en su ambiente natural
70141500|Producción de cultivos|O|O||D||1|Servicios de producción de cultivos
70141501|Servicios de multiplicación de semillas|O|O||D||1|Servicios de producción de semillas
70141502|Hidroponía|O|O||D||1|Cultivo sin suelo
70141503|Producción de hierba o forraje|O|O||D||1|Producción de pasto o forraje
70141504|Producción de plantas aromáticas|O|O||D||1
70141505|Producción de productos agrícolas para elaboración de bebidas|O|O||D||1
70141506|Producción de cacao|O|O||D||1
70141507|Producción de remolacha azucarera o caña de azúcar|O|O||D||1|Producción de betabel de azúcar o caña de azúcar
70141508|Producción de nueces|O|O||D||1
70141509|Producción de cultivos productores de aceites esenciales|O|O||D||1|Producción de cultivos para la obtención de aceites esenciales
70141510|Producción de plantas textiles|O|O||D||1|Producción de cultivos de fibra
70141511|Producción de fruta|O|O||D||1
70141512|Producción de granos o legumbres|O|O||D||1
70141513|Producción de plantas insecticidas|O|O||D||1
70141514|Producción de plantas medicinales|O|O||D||1
70141515|Producción de raíces o tubérculos|O|O||D||1
70141516|Producción de cereales|O|O||D||1
70141517|Producción de plantas de caucho|O|O||D||1
70141518|Producción de cultivos de especias|O|O||D||1
70141519|Producción de cultivos de tabaco|O|O||D||1
70141520|Producción de hortalizas|O|O||D||1|Producción de vegetales
70141600|Protección de cultivos|O|O||D||1|Servicios de protección de cultivos
70141601|Servicios de fumigación de cultivos|O|O||D||1
70141602|Servicios de control biológico|O|O||D||1
70141603|Servicios de control de las malas hierbas|O|O||D||1|Servicios de control de malezas
70141604|Servicios de herbicidas|O|O||D||1|Servicio de productos químicos para eliminar plantas indeseadas
70141605|Servicios de manejo integrado de plagas|O|O||D||1|Servicios integrados para el control de plagas
70141606|Fitopatología|O|O||D||1|Servicios de control de enfermedades de las plantas
70141607|Control de langostas|O|O||D||1
70141700|Gestión de cultivos|O|O||D||1|Servicios de gestión de cultivos
70141701|Servicios de invernaderos|O|O||D||1|Servicio de criadero de plantas
70141702|Servicios de fertilizantes|O|O||D||1|Servicios de abono de cultivos
70141703|Administración de cultivos|O|O||D||1
70141704|Sustitución de cultivos|O|O||D||1
70141705|Servicios de extensión|O|O||D||1
70141706|Especialización de cultivos|O|O||D||1
70141707|Gestión de sistemas de explotación agrícola de cultivo|O|O||D||1|Manejo del sistema de cultivo
70141708|Servicios de asesoría en la rotación o diversificación de cultivos|O|O||D||1|Servicios de consultoría de rotación o diversificación de cultivos
70141709|Servicios de taxonomía de plantas|O|O||D||1|Servicios de clasificación de plantas
70141710|Entomología de cultivos extensivos|O|O||D||1|Servicios de estudios científicos de insectos en los cultivos
70141800|Plantación y cultivo de cultivos|O|O||D||1|Servicios de plantación y cultivos
70141801|Servicios de siembra de árboles de huerta o viñedos|O|O||D||1|Servicios de plantación de árboles o viñedos
70141802|Servicios de brotes o ramitas|O|O||D||1
70141803|Servicios de cultivos agrícolas|O|O||D||1
70141804|Servicios de siembra de cultivos|O|O||D||1
70141900|Cosecha de cultivos|O|O||D||1|Servicios de cosecha de cultivos
70141901|Servicios de cosecha de granos comerciales|O|O||D||1
70141902|Servicios de cosecha de frutales o nueces|O|O||D||1|Servicio de cosecha de granos
70141903|Servicios de cosecha de cultivos extensivos|O|O||D||1|Servicios de recolección de campos de cultivo
70141904|Servicios de cosecha de semillas|O|O||D||1
70142000|Elaboración de cultivos posterior a la cosecha|O|O||D||1|Servicios de tratamientos posteriores a la cosecha de cultivos
70142001|Servicios relativos a silos|O|O||D||1|Servicios relativos a los almacenes de granos
70142002|Servicios de secado de granos|O|O||D||1
70142003|Servicios de procesamiento de la cosecha|O|O||D||1|Servicios de procesamiento de los cultivos
70142004|Servicios de preparación del mercado para cultivos extensivos|O|O||D||1
70142005|Servicios de preparación del mercado para cultivos comerciales de granos|O|O||D||1
70142006|Servicios de preparación del mercado para productos hortenses|O|O||D||1|Servicios de preparación de mercado de cultivos vegetales
70142007|Servicios de preparación del mercado para productos frutales|O|O||D||1
70142008|Servicios de preparación del mercado para nueces|O|O||D||1
70142009|Servicios de desmotado|O|O||D||1|Servicios de separación de fibras de algodón de las semillas
70142010|Servicios de limpieza de cultivos|O|O||D||1
70142011|Servicios de enfriamiento o refrigeración|O|O||D||1
70151500|Gestión de cultivos forestales|O|O||D||1|Servicios de gestión de cultivos forestales
70151501|Servicios de gestión de recursos forestales|O|O||D||1|Servicios de gestión de recursos de los bosques
70151502|Control de plagas forestales|O|O||D||1|Control de plagas en los bosques
70151503|Organizaciones, asociaciones o cooperativas forestales|O|O||D||1
70151504|Servicios de administración forestal|O|O||D||1
70151505|Inventario forestal|O|O||D||1|Inventario de los bosques
70151506|Seguimiento o evaluación forestal|O|O||D||1|Seguimiento o evaluación de los bosques
70151507|Servicios de forestación|O|O||D||1|Servicios de sembrado de árboles
70151508|Servicios de asistencia forestal|O|O||D||1
70151509|Gestión de viveros forestales|O|O||D||1|Gestión de criadero de árboles
70151510|Planificación sectorial forestal|O|O||D||1
70151600|Industria forestal|O|O||D||1|Servicios para la industria forestal
70151601|Servicios de producción no maderera|O|O||D||1
70151602|Producción de aceites esenciales|O|O||D||1
70151603|Servicios de producción maderera|O|O||D||1
70151604|Producción de colorantes|O|O||D||1
70151605|Producción forestal comestible|O|O||D||1|Producción de bosque comestible
70151606|Servicios de prueba de madera|O|O||D||1
70151700|Cosecha forestal|O|O||D||1|Servicios para la cosecha forestal
70151701|Corte o tala de troncos|O|O||D||1|Corte o tala de árboles
70151702|Cosecha forestal de zonas montañosas|O|O||D||1
70151703|Operaciones especializadas para la cosecha forestal|O|O||D||1
70151704|Cosecha de plantaciones|O|O||D||1
70151705|Cosecha forestal de pantanos o manglares|O|O||D||1
70151706|Cosecha de bosques de zonas templadas|O|O||D||1
70151707|Cosecha de bosques altos tropicales|O|O||D||1
70151800|Servicios de conservación forestal|O|O||D||1
70151801|Conservación de recursos genéticos forestales|O|O||D||1
70151802|Servicios de protección forestal|O|O||D||1|Servicios de protección de bosques
70151803|Rehabilitación de tierras forestales áridas|O|O||D||1
70151804|Rompevientos o barreras naturales de protección forestal|O|O||D||1
70151805|Servicios de conservación de parques o reservas forestales|O|O||D||1
70151806|Ordenación de las cuencas hidrográficas forestales|O|O||D||1
70151807|Control de las torrentes forestales|O|O||D||1
70151900|Recursos forestales|O|O||D||1|Servicios para recursos forestales
70151901|Desarrollo de los recursos forestales|O|O||D||1
70151902|Recursos agrosilvícolas|O|O||D||1|Recursos agroforestales
70151903|Recursos de madera combustible|O|O||D||1
70151904|Silvicultura|O|O||D||1|Cultivo de los bosques, cerros o montes
70151905|Recursos de plantaciones áridas con agua de lluvia|O|O||D||1
70151906|Recursos de plantaciones de hoja ancha|O|O||D||1
70151907|Plantaciones de coníferas|O|O||D||1|Plantaciones de pínidas
70151909|Plantaciones de bosques tropicales húmedos|O|O||D||1
70151910|Recursos de manglares|O|O||D||1
70161500|Fauna|O|O||D||1|Servicios de protección para la fauna
70161501|Protección de la fauna|O|O||D||1
70161600|Flora|O|O||D||1|Servicios de protección para la flora
70161601|Protección de la flora|O|O||D||1
70161700|Ecosistemas|O|O||D||1|Servicios para ecosistemas
70161701|Servicios de ecodesarrollo|O|O||D||1
70161702|Servicios de administración del ecosistema marino|O|O||D||1|Servicios de administración del hábitat marino
70161703|Servicios de administración del ecosistema terrestre|O|O||D||1|Servicios de administración del hábitat terrestre
70161704|Servicios de protección de los ecosistemas|O|O||D||1|Servicios de protección de los hábitat
70171500|Desarrollo|O|O||D||1|Servicios de desarrollo
70171501|Servicios de evaluación de la calidad del agua|O|O||D||1
70171502|Servicios de planificación de los recursos hidráulicos|O|O||D||1|Servicios de planificación de los recursos hídricos
70171503|Inspección de aguas subterráneas o superficiales|O|O||D||1
70171504|Servicios de cartografía de los recursos hidráulicos|O|O||D||1
70171505|Aprovechamiento de los ríos|O|O||D||1|Desarrollo de cuencas hidrográficas
70171506|Servicios para modelado de aguas subterráneas o superficiales|O|O||D||1
70171600|Vigilancia|O|O||D||1|Servicios de vigilancia
70171601|Gestión de la calidad del agua|O|O||D||1
70171602|Servicios de pruebas de agua|O|O||D||1
70171603|Manejo de suelos inundables|O|O||D||1|Gestión de las inundaciones
70171604|Servicios de asesoría en conservación del agua|O|O||D||1|Servicios de consultoría para la conservación del agua
70171605|Servicios de asesoría en derechos de agua|O|O||D||1|Servicios de consultoría en derechos de agua
70171606|Servicios de recuperación de recursos hidráulicos|O|O||D||1|Servicios de recuperación de recursos hídricos
70171607|Servicios de tasación del agua|O|O||D||1|Servicios de fijación de precios del agua
70171700|Riego|O|O||D||1|Servicios para riegos
70171701|Servicios de  mantenimiento o administración  de canales|O|O||D||1
70171702|Servicios de mantenimiento o administración de represas|O|O||D||1
70171703|Servicios de  mantenimiento o administración  de embalses|O|O||D||1
70171704|Servicios de  mantenimiento o administración  de estaciones de bombeo|O|O||D||1
70171705|Servicios de  mantenimiento o administración  de canalizaciones|O|O||D||1|Servicios de mantenimiento o gestión de gasoductos
70171706|Servicios de  mantenimiento o administración  de malecones o diques|O|O||D||1
70171707|Servicios de  mantenimiento o administración  de pozos de agua|O|O||D||1
70171708|Servicios de asesoría en riego|O|O||D||1|Servicios de consultoría en sistemas de riego
70171709|Servicios de administración de sistemas de riego|O|O||D||1
70171800|Servicios de drenaje|O|O||D||1
70171801|Servicios de drenaje de tierras|O|O||D||1
70171802|Drenaje de agua pluviales|O|O||D||1|Drenaje para agua de lluvia
70171803|Servicios de protección contra inundaciones o de control de inundaciones|O|O||D||1|Servicios de protección o control de inundaciones
71101500|Prospección minera|O|O||D||1|Servicios de descubrimientos de yacimientos mineros
71101501|Desarrollos mineros|O|O||D||1
71101502|Sondeos de exploración o extracción de testigos|O|O||D||1|Taladrado de prueba o perforación de núcleo
71101600|Servicios mineros de perforación y voladura|O|O||D||1
71101601|Profundización de pozos de mina|O|O||D||1
71101602|Servicios de voladura de minas|O|O||D||1|Servicios de fragmentación de minas
71101603|Servicio de perforación de pozos de sondeo de minas|O|O||D||1
71101604|Servicio de construcción de pozos de pendiente|O|O||D||1
71101605|Servicio de perforación horizontal de minas|O|O||D||1
71101606|Servicio de instalación de sellamiento subterráneo|O|O||D||1
71101607|Servicio de construcción de techado subterráneo|O|O||D||1|Servicio de construcción de techos subterráneos
71101608|Servicio de construcción de búnkeres|O|O||D||1
71101609|Servicio de construcción de ventilación subterránea|O|O||D||1
71101700|Extracción|O|O||D||1|Servicios de extracción
71101701|Servicios de minería de pozos|O|O||D||1
71101702|Servicios de minería  a cielo abierto|O|O||D||1
71101703|Servicios de explotación a cielo abierto|O|O||D||1
71101704|Servicios de lixiviación sobre el terreno|O|O||D||1|Servicios de extracción de sólido-líquido sobre el terreno
71101705|Bombeo o drenaje|O|O||D||1|Servicios de bombeo o drenaje
71101706|Eliminación de cobertura de rocas|O|O||D||1|Servicios de eliminación de la sobrecarga
71101707|Servicios de embalsamiento o almacenamiento de aguas|O|O||D||1
71101708|Servicios de baldeo de la tierra|O|O||D||1|Servicios de limpieza del suelo
71101709|Servicios de relleno de minas|O|O||D||1
71101710|Servicio de alquiler o leasing de maquinaria para minería|O|O||D||1|Servicio de alquiler o arrendamiento de maquinaria para minas
71112000|Servicios de registrar hoyo encerrado de pozos|O|O||D||1|Servicios de registro de pozos
71112001|Servicios de pruebas de muestras de formación de pozos entubados|O|O||D||1
71112002|Servicios de medición del espesor del revestimiento|O|O||D||1
71112003|Servicios de cortadoras químicas|O|O||D||1
71112004|Servicios de recuperación de tubería electromagnética|O|O||D||1
71112005|Servicios de medición del flujo del pozo|O|O||D||1
71112006|Servicios de medición  de la densidad del fluido del pozo|O|O||D||1
71112007|Servicios de medición de la temperatura del fluido del pozo|O|O||D||1
71112008|Servicios de herramientas de punto libre|O|O||D||1|Servicios de medidores de deformación de punto libre
71112009|Servicios de rayos gamma|O|O||D||1
71112010|Servicios de cortadora a  chorro|O|O||D||1|Servicios de cortadora con agua a presión
71112011|Servicios de medición durante la perforación|O|O||D||1
71112012|Servicios de porosidad por neutrón|O|O||D||1
71112013|Servicios de espectroscopia nuclear|O|O||D||1
71112014|Servicios de obturación de pozos|O|O||D||1|Servicios de obstrucción de pozos
71112015|Servicios de recuperación permanente de tuberías magnéticas|O|O||D||1|Servicios de recuperación de tubos de imanes permanentes
71112017|Servicios de control de medición de la presión del pozo|O|O||D||1
71112018|Servicios de medición del fluido de perforación para registros de producción|O|O||D||1
71112019|Servicios de medición de la densidad para registros de producción|O|O||D||1
71112020|Servicios de video en fondo de pozo para registros de producción|O|O||D||1
71112021|Servicios de medición de flujo para registros de producción|O|O||D||1
71112022|Servicios de medición de presión para registros de producción|O|O||D||1
71112023|Otros servicios para registros de producción|O|O||D||1
71112024|Servicios de medición de temperatura para registros de producción|O|O||D||1
71112025|Servicios de colisión y separación|O|O||D||1
71112026|Servicios acústicos para registros  del pozo|O|O||D||1
71112027|Servicios de herramienta para puntos de atascamiento|O|O||D||1
71112028|Servicios de registro de pozos  de descomposición térmica|O|O||D||1|Servicios de registro de pozos  de deterioro térmico
71112029|Servicios de evaluación de la corrosión de tubos del pozo|O|O||D||1
71112030|Servicios de rendimiento del pozo|O|O||D||1
71112031|Servicios de tubos para pozos|O|O||D||1
71112100|Servicios de registrar pozo de perforación abierta|O|O||D||1|Servicios de registro abierto de pozos
71112101|Servicios de registro acústicos digital|O|O||D||1
71112102|Servicios de registro de la geometría de la perforación|O|O||D||1
71112103|Servicios de registro nuclear de litología y densidad|O|O||D||1
71112105|Servicios de registro acústico dipolar|O|O||D||1
71112106|Servicios de registro de desviaciones|O|O||D||1|Servicios de registro direccional
71112107|Servicios de planimetría direccional|O|O||D||1|Servicios de sondeo direccional
71112108|Servicios de registro de propagación electromagnética|O|O||D||1
71112109|Servicios de muestreo de pruebas de formación|O|O||D||1
71112110|Servicios de registro de identificación de fracturas|O|O||D||1
71112111|Servicios de registro por rayos gamma|O|O||D||1
71112112|Servicios de registro espectroscópico por rayos gamma|O|O||D||1
71112113|Servicios de registro nuclear geoquímico|O|O||D||1
71112114|Servicios de generación de imágenes del pozo|O|O||D||1|Servicios de generación de figuras del pozo
71112115|Servicios de registro por resonancia magnética|O|O||D||1
71112116|Servicios de registro de micro resistencia|O|O||D||1
71112117|Servicios de registro de porosidad  por neutrón|O|O||D||1
71112119|Servicios de registro de resistencia|O|O||D||1
71112120|Servicios de registro acústico de acceso angosto|O|O||D||1|Servicios de registro acústico de acceso estrecho
71112121|Servicios de registro acústico de la relación de adherencia del cemento|O|O||D||1|Servicios de registro de adherencia del cemento
71112122|Servicios de generación de imágenes acústicas del pozo|O|O||D||1
71112123|Servicios de registro de formación de ángulo y dirección de inclinación|O|O||D||1
71112200|Otros servicios de registración|O|O||D||1|Otros servicios para el registro de pozos
71112202|Registro durante servicios de perforación|O|O||D||1|Servicios de registro de pozos durante las pruebas de perforación
71112203|Servicios de registro durante la pesca|O|O||D||1|Servicios de registro de pozos durante la pesca
71112204|Servicios de registro  durante la perforación|O|O||D||1|Servicios de registro de pozos durante la perforación
71112205|Servicios de tubería de perforación transportadas para pozos|O|O||D||1|Servicios de registro de pozos conectados a tuberías de transportación
71112206|Servicios generales de registro de pozos|O|O||D||1
71112300|Servicios sísmicos|O|O||D||1
71112301|Servicios de adquisición de datos sísmicos de tierras de 2d/ 3d/ 4d|O|O||D||1
71112302|Servicios de adquisición de datos sísmicos  marinos de 2d/ 3d/ 4d|O|O||D||1
71112303|Servicios de procesamiento de datos sísmicos de 2d/ 3d/ 4d|O|O||D||1
71112322|Interpretación de datos sísmicos de 2d/ 3d/ 4d|O|O||D||1
71112323|Servicios de estudio de la velocidad del pozo|O|O||D||1|Servicios de investigación de velocidad de perforación
71112324|Otros servicios sísmicos|O|O||D||1
71112325|Servicios de adquisición de datos sísmicos  por sondeo para tierras|O|O||D||1
71112326|Servicios de adquisición de datos sísmicos marinos  por sondeo|O|O||D||1
71112327|Servicios de procesamiento de datos sísmicos por sondeo|O|O||D||1
71112328|Servicios de adquisición de monitoreo de datos sísmicos por sondeo|O|O||D||1
71112329|Servicios de adquisición de datos sísmicos por sondeo durante la perforación|O|O||D||1
71112330|Servicios simultáneos de adquisición de datos sísmicos por sondeo y de superficie|O|O||D||1
71121000|Servicios de bombear cemento|O|O||D||1|Servicios de bombeo de cemento
71121001|Servicios de hardware de tuberías de revestimiento para campos petroleros|O|O||D||1|Servicios de construcción de carcasas para campos petrolíferos
71121002|Servicios de pruebas de laboratorios de cemento para campos petroleros|O|O||D||1
71121008|Servicios de circulación perdida del pozo petrolero|O|O||D||1
71121009|Servicios de eliminación de lodo  del  campo petrolero|O|O||D||1
71121010|Servicios de cementación de tapones|O|O||D||1
71121011|Servicios de bombeo a presión del pozo en el emplazamiento|O|O||D||1|Servicios de bombeo a presión del pozo en sitio
71121012|Servicios de prueba de presión del campo petrolero|O|O||D||1
71121016|Servicios de cementación del pozo con forzamiento de inyección|O|O||D||1|Servicios de cementación a presión, Servicios de cementación forzada
71121017|Servicios de control de agua del pozo|O|O||D||1
71121018|Servicios de evaluación de la cementación del pozo|O|O||D||1
71121024|Servicio de cementación de tubería|O|O||D||1
71121025|Otros servicios de cementación|O|O||D||1
71121100|Servicios de tubería adujada|O|O||D||1
71121101|Servicios de acidización mediante tubería flexible contínua|O|O||D||1|Servicios de acidización mediante carrete de tubería flexible
71121102|Servicios de instalación de cables  mediante tubería  flexible contínua|O|O||D||1
71121103|Servicios de cementación mediante tubería  flexible contínua|O|O||D||1
71121104|Servicios de corte químico mediante tubería flexible contínua|O|O||D||1
71121105|Servicios de limpieza mediante tubería flexible contínua|O|O||D||1
71121106|Servicios de terminación mediante tubería flexible contínua|O|O||D||1
71121107|Servicios de transporte de inflables  mediante tubería flexible contínua|O|O||D||1
71121108|Servicios de extracción de testigos mediante tubería flexible contínua|O|O||D||1
71121109|Servicios de alcance extendido del pozo|O|O||D||1
71121110|Servicios de pesca mediante tubería flexible contínua|O|O||D||1
71121111|Servicios de fracturación mediante tubería flexible contínua|O|O||D||1
71121112|Servicios de presión alta mediante tubería flexible contínua|O|O||D||1
71121113|Servicios de aislamiento horizontal del campo petrolífero|O|O||D||1
71121114|Servicios de registro mediante tubería flexible contínua|O|O||D||1
71121115|Servicios de fresado mediante tubería flexible contínua|O|O||D||1
71121116|Aplicaciones relacionadas con nitrógeno mediante tubería flexible continua|O|O||D||1
71121117|Servicios de perforación mediante tubería flexible contínua|O|O||D||1
71121118|Servicios de tendido de conductos o tuberías de producción|O|O||D||1
71121119|Servicios de intervención en los conductos|O|O||D||1|Servicios de intervención en la tubería para transportar petróleo, Servicios de intervención en oleoductos
71121120|Servicios de control de arena mediante tubería flexible contínua|O|O||D||1
71121121|Servicios abrasivos de limpieza tubular|O|O||D||1|Servicios corrosivos de limpieza tubular
71121122|Servicios de matar el pozo (well kil)l mediante tubería flexible contínua|O|O||D||1
71121123|Servicios de salida de tubería mediante tubería flexible contínua|O|O||D||1
71121200|Servicios de extracción de muestras|O|O||D||1
71121201|Servicios convencionales de extracción de testigos|O|O||D||1
71121202|Servicios de aislamiento de testigos|O|O||D||1
71121203|Servicios de conservación de testigos|O|O||D||1
71121204|Servicios de extracción horizontal de testigos|O|O||D||1
71121205|Servicios de extracción de testigos orientada|O|O||D||1
71121206|Servicios de análisis de testigos ("Core analysis service ")|O|O||D||1
71121207|Servicios de extracción de testigos con esponja|O|O||D||1|Servicios de extracción de núcleo petrolero
71121208|Servicios de extracción de testigos mediante cable conductor recuperable|O|O||D||1|Servicios de extracción mediante línea de acero recuperable
71121209|Servicios de sistemas antiatascamiento|O|O||D||1|Servicios de espectro ensanchado, Servicios de sistemas anti interferencias intencionadas
71121210|Servicios de extracción  motorizada de testigos|O|O||D||1
71121211|Servicios de sistemas de cierre completo|O|O||D||1
71121300|Servicios de herramientas barrenos hacia abajo|O|O||D||1
71121301|Servicios de control de la vibración de perforación en el fondo del pozo|O|O||D||1
71121302|Servicios de ensanchamiento de la perforación en el fondo del pozo|O|O||D||1
71121303|Servicios de protección del ensanche y calibración de la perforación en el fondo del pozo|O|O||D||1
71121304|Servicios de reducción del arrastre o torque en la perforación en el fondo del pozo|O|O||D||1
71121305|Servicios de alivio de atascamiento de los tubos en la perforación en el fondo del pozo|O|O||D||1
71121307|Servicios de reparación de herramientas de perforación en el fondo del pozo|O|O||D||1
71121309|Servicios de estabilización de la perforación en el fondo del pozo|O|O||D||1
71121310|Alquiler de armadura de urgencia bop|O|O||D||1|Alquiler de preventores de superficie
71121400|Servicios de broca de barrena del campo petrolífero|O|O||D||1
71121401|Servicios de diseño de brocas de perforación del campo petrolero|O|O||D||1
71121402|Servicios de optimización hidráulica de las brocas de perforación del campo petrolero|O|O||D||1
71121403|Servicios de planificación de las brocas de perforación del campo petrolero|O|O||D||1
71121404|Servicios de registro de las brocas de perforación del campo petrolero|O|O||D||1
71121405|Servicios de reparación de brocas de perforación del campo petrolero|O|O||D||1
71121406|Contratos de longitud excavada de las brocas de perforación del campo petrolero|O|O||D||1
71121407|Servicio de asistencia para la optimización de la perforación en el emplazamiento del pozo|O|O||D||1
71121408|Servicios de elevación hidráulica de las brocas de perforación|O|O||D||1
71121500|Servicios de medida de perforación|O|O||D||1
71121501|Servicios de medición acústica durante la perforación|O|O||D||1
71121502|Servicios de telemetría acústica durante la perforación|O|O||D||1
71121503|Servicios de medición de calibre durante la perforación|O|O||D||1
71121504|Servicios de medición de la densidad durante la perforación|O|O||D||1
71121505|Servicios del rendimiento de la perforación del campo  petrolero|O|O||D||1
71121506|Servicios de telemetría electromagnética durante la perforación|O|O||D||1
71121507|Servicios de medición de la inclinación de formación durante la perforación|O|O||D||1
71121508|Servicios de medición de la presión de formación durante la perforación|O|O||D||1
71121509|Pozos dirigidos geológicamente|O|O||D||1|Pozos con dirección geológica
71121510|Servicios de geoparada|O|O||D||1
71121511|Servicios de registro de lodo|O|O||D||1
71121512|Servicios de resonancia magnética nuclear|O|O||D||1
71121513|Servicios de medición de la porosidad durante la perforación|O|O||D||1
71121514|Servicios de medición de la resistividad durante la perforación|O|O||D||1
71121515|Servicios de gestión de levantamiento de planos  del pozo|O|O||D||1
71121516|Servicios de inspección de los cables conductores|O|O||D||1
71121600|Servicios de perforación del pozo petrolero|O|O||D||1
71121601|Servicios de personal para revestimiento de  tuberías del pozo|O|O||D||1|Equipos de trabajo para revestimiento de  tuberías del pozo
71121602|Servicios de planificación para el revestimiento de tuberías del pozo|O|O||D||1
71121603|Servicios de fresado para el revestimiento de tuberías del pozo|O|O||D||1
71121604|Servicios de perforación con tubería flexible continua|O|O||D||1|Servicios de perforación con carrete de tubería flexible
71121605|Servicios de planificación de la terminación del pozo|O|O||D||1
71121606|Servicios de perforación direccional de pozo convencional|O|O||D||1
71121607|Servicios de perforación direccional de pozos|O|O||D||1
71121608|Servicios de desarrollo de contratos  para perforación de pozos|O|O||D||1
71121610|Servicios de ingeniería para perforación de pozos|O|O||D||1
71121611|Servicios de fluido o lodo para perforación de pozos|O|O||D||1
71121612|Servicios de perforación de pozos  para entrada de agua|O|O||D||1|Servicios de perforación de pozos  de agua
71121613|Servicios de monitoreo de la torre de perforación del pozo|O|O||D||1
71121614|Control de sólidos durante perforación de pozos|O|O||D||1
71121615|Servicios de apertura de hoyos o estabilización de la perforación de pozos|O|O||D||1|Servicios de apertura o estabilización de la perforación de pozos
71121616|Supervisión de perforación de pozos|O|O||D||1
71121617|Servicios de control de perforación de pozos|O|O||D||1
71121618|Otros servicios generales para perforación de pozos|O|O||D||1
71121619|Servicios de perforación direccional de alcance extendido de pozos|O|O||D||1|Servicios de perforación horizontal de pozos
71121620|Servicios de perforación direccional multilateral de pozos|O|O||D||1
71121621|Servicios de pruebas  o modificaciones de tubos para pozos de petróleo|O|O||D||1
71121622|Servicio de almacenamiento transitorio o recogida de tubos para perforación de pozos|O|O||D||1|Perforación de pozos de recolección o puesta en servicio
71121623|Almacenamiento de tubería de perforación de pozo|O|O||D||1
71121624|Enroscado de tubería de perforación de pozos|O|O||D||1|Roscado de tubería de perforación de pozos
71121625|Servicio de perforación de los orificio de conexión o ratonera|O|O||D||1|Servicio de perforación de pozo piloto o ratonera
71121626|Servicios de perforación direccional de pozos de radio corto|O|O||D||1
71121627|Servicios de ampliación dirigible de paredes por debajo de la tubería de revestimiento durante la perforación del pozo|O|O||D||1
71121628|Servicios de perforación direccional de pozos de radio ultracorto|O|O||D||1
71121629|Servicios de perforación desbalanceada de pozos|O|O||D||1
71121630|Servicios de planificación del pozos|O|O||D||1|Servicios de planificación de pozos
71121631|Servicios de reperforación o retrabajo|O|O||D||1
71121632|Control de desviaciones  en la perforación del pozo|O|O||D||1
71121633|Servicios de empacado de grava del campo petrolero|O|O||D||1
71121634|Servicios de sistemas de cascos  del campo petrolero|O|O||D||1
71121635|Servicios de personal para arrastre de aparejos del pozo|O|O||D||1
71121636|Servicios de equipo de la cabeza del pozo|O|O||D||1|Servicios de equipo de cabezales del pozo
71121637|Servicios de desviación con aparato para cambiar el trazo de perforación|O|O||D||1|Servicio de desviadores de pared de pozo
71121638|Servicios de limpieza de conductos de perforación de pozos|O|O||D||1
71121639|Servicio de alquiler de tubería de perforación en el fondo del pozo|O|O||D||1
71121640|Servicio rodante de tubería|O|O||D||1|Servicio de collarín de seguridad de perforación
71121641|Servicio de perforación direccional dirigible y rotativa|O|O||D||1
71121700|Servicios de pesca en el campo petrolífero|O|O||D||1
71121701|Servicios de diseño del servicio de pesca en el campo petrolífero|O|O||D||1
71121702|Servicios de evaluación económica del servicio de pesca en el campo petrolífero|O|O||D||1
71121703|Servicios de operación del servicio de pesca en el campo petrolífero|O|O||D||1
71121704|Servicios de recuperación de desechos en el campo petrolífero|O|O||D||1
71121705|Servicios de recuperación de tubería en el campo petrolífero|O|O||D||1
71121706|Servicios de perforación o pesca en el campo petrolífero|O|O||D||1|Servicios de perforación o pesca para el campo petrolero
71121800|Servicios de elevación por presión de gas|O|O||D||1
71121805|Servicios de elevadores del eje mayor del yacimiento|O|O||D||1|Servicios de levantamiento Pistón Accionado a Gas
71121806|Servicios de elevadores recíprocos de varilla|O|O||D||1
71121807|Servicios de elevación hidráulica|O|O||D||1
71121808|Servicios de elevadores de cavidad progresiva cvx|O|O||D||1
71121809|Servicios de automatización y optimización de pozos en el emplazamiento|O|O||D||1
71121810|Servicios de elevación por bombeo sumergible electrónico|O|O||D||1
71121811|Otros sistemas de elevación|O|O||D||1
71121812|Servicios de elevadores de gas|O|O||D||1
71121900|Servicios de fluido barreno hacia abajo|O|O||D||1
71121901|Servicios de evaluación de fluidos en el fondo del pozo|O|O||D||1
71121902|Servicios de laboratorio de fluidos de fondo del pozo|O|O||D||1
71121903|Servicios de muestreo de fluidos de fondo de pozo|O|O||D||1
71121904|Servicios de ingeniería para fluidos de fondo de pozo|O|O||D||1
71121905|Servicio de manejo de fluidos residuales|O|O||D||1
71122000|Servicios de perforación de pozo|O|O||D||1
71122001|Servicios de perforación de pozos con tubería flexible continua|O|O||D||1|Servicios de perforación de pozos con carrete de tubería flexible
71122002|Servicios de perforación de pozos con alambre (slickline)|O|O||D||1
71122003|Servicios de perforación de pozos con  tubo directo|O|O||D||1
71122004|Servicios de perforación de pozos con  tubo transportado|O|O||D||1
71122005|Servicios de perforación de pozos con cables conductores|O|O||D||1
71122006|Servicios de perforación de tuberías de pozos|O|O||D||1
71122100|Servicios de control de arena del campo petrolero|O|O||D||1
71122101|Servicios de bombeo de control de arena ácida|O|O||D||1
71122102|Servicios de mezclado de control de arena|O|O||D||1
71122103|Servicios de control de arena en el fluido de limpieza|O|O||D||1
71122104|Servicios de control de arena en el fluido de terminación|O|O||D||1
71122105|Servicios de consolidación de pozos|O|O||D||1
71122107|Servicios de control de arena en el fluido de fracturación|O|O||D||1
71122108|Servicios de pruebas de diseño de fracturación o pre fracturación|O|O||D||1
71122109|Servicios generales/misceláneos  de control de arena|O|O||D||1
71122110|Servicios de control de arena en el fluido transportador de grava|O|O||D||1
71122111|Servicios de pruebas de laboratorio para el control de arena|O|O||D||1
71122112|Servicios de control de arena multizonal|O|O||D||1
71122113|Servicios de monitoreo del control de arena|O|O||D||1
71122114|Servicios de aislamiento temporal del control de arena|O|O||D||1
71122115|Servicios de reacondicionamiento de herramientas del pozo|O|O||D||1
71122116|Servicios de bombeo para control de arena de no fracturación|O|O||D||1
71122200|Servicios de película oleosa|O|O||D||1
71122201|Servicios de pesca con alambre (slickline)|O|O||D||1|Servicios de pesca con línea de acero
71122202|Servicios de elevación con alambre (slickline)|O|O||D||1|Servicios de elevación con línea de acero
71122203|Servicios de manipulación con alambre (slickline)|O|O||D||1|Servicios de manipulación con línea de acero
71122204|Servicios de terminación con alambre (slickline)|O|O||D||1|Servicios de terminación con línea de acero
71122205|Servicios de registro con alambre (slickline)|O|O||D||1|Servicios de registro con línea de acero
71122206|Servicios mecánicos con alambre (slickline)|O|O||D||1|Servicios mecánicos con línea de acero
71122207|Servicios de recuperación de tubos con alambre (slickline)|O|O||D||1|Servicios de recuperación de tubos con línea de acero
71122300|Servicios de pozo submarino|O|O||D||1
71122301|Servicios de buceo en pozos submarinos|O|O||D||1
71122302|Servicios de vehículos operados a control remoto (rov) para pozos submarinos|O|O||D||1
71122303|Servicios de equipo de pruebas o accesorios de pozos submarinos|O|O||D||1
71122304|Servicios de terminación o intervención de pozos submarinos submarino|O|O||D||1
71122305|Servicios de estructura jerárquica (tree) de las pruebas de seguridad de pozos submarinos|O|O||D||1|Servicio de pruebas de seguridad del árbol submarino
71122306|Servicios de mantenimiento de equipo del pozo submarino|O|O||D||1
71122307|Servicios de dragado, zanjado y excavación submarina|O|O||D||1
71122308|Servicio de tendido de cables y tubería submarina|O|O||D||1
71122309|Servicio de inspección y monitoreo del equipo de producción de pozos submarinos|O|O||D||1
71122310|Servicio de ingeniería y administración de proyectos de pozos submarinos|O|O||D||1
71122311|Servicio de ingeniería y diseño inicial de proyectos de pozos submarinos feed|O|O||D||1
71122400|Servicios de pruebas del pozo submarino|O|O||D||1
71122407|Servicios de pruebas de rellenos de perforación|O|O||D||1|Servicios de pruebas de vástago de perforación
71122408|Servicio de pruebas periódicas del pozo|O|O||D||1
71122409|Servicios de pruebas de superficie del pozo|O|O||D||1
71122410|Servicio de pruebas desbalanceadas durante la perforación|O|O||D||1
71122500|Servicios de control de gas o agua|O|O||D||1
71122501|Servicios de diseño del control de gas o agua|O|O||D||1
71122502|Servicios de evaluación del control de gas o agua|O|O||D||1
71122503|Servicios de aislamiento del control de gas o agua|O|O||D||1
71122504|Servicios de pruebas del control de gas o agua|O|O||D||1
71122505|Servicios de pruebas de gas o agua|O|O||D||1
71122506|Servicios de llamarada|O|O||D||1
71122600|Servicios de terminación del pozo|O|O||D||1
71122601|Servicios de terminación de pozos de agujero revestido|O|O||D||1|Servicio de terminación de pozo entubado
71122602|Servicios de fluidos de terminación del pozo|O|O||D||1
71122605|Servicio de terminación de la elevación de gas del pozo|O|O||D||1
71122606|Servicios de terminación de pozos inteligentes|O|O||D||1
71122608|Servicios de terminación multilateral de pozos|O|O||D||1
71122610|Servicios de terminación del control de arena del pozo|O|O||D||1|Servicios de finalización de pozos de control de arena
71122614|Servicios para el rodamiento de líneas|O|O||D||1
71122615|Servicios de terminación de hoyo abierto|O|O||D||1
71122616|Servicios de terminación de pozo con tubo/malla expandible|O|O||D||1
71122700|Servicios de mantenimiento del pozo|O|O||D||1
71122701|Servicios de mantenimiento de la plataforma de pozos petroleros|O|O||D||1
71122702|Servicios de mantenimiento de la unidad de bombeo del campo petrolero|O|O||D||1
71122703|Servicios de reparación de bomba de vástago del campo petrolero|O|O||D||1|Servicios de reparación de bombas de varilla de campo petrolífero
71122704|Servicios de socavación del campo petrolero|O|O||D||1|Servicio de entubación bajo presión de pozos petroleros
71122705|Servicios de mantenimiento vástago de succión del campo petrolero|O|O||D||1
71122706|Servicios de achique de pozos|O|O||D||1
71122707|Servicios de anclaje de tubería del campo petrolero|O|O||D||1
71122708|Servicios mecánicos para bombas del campo petrolero|O|O||D||1
71122709|Servicio de mantenimiento de herramientas en el fondo del pozo|O|O||D||1
71122710|Servicios de mantenimiento de tubos del campo petrolero|O|O||D||1
71122711|Servicio de reacondicionamiento de pozos|O|O||D||1
71122800|Servicios de monitor del pozo petrolero|O|O||D||1
71122801|Servicios de grabación en el fondo del pozo|O|O||D||1
71122802|Servicios de monitoreo del flujo del pozo|O|O||D||1
71122803|Servicios de monitoreo del flujo del pozo petrolero o de gas|O|O||D||1
71122804|Servicios de monitoreo de las fases en el emplazamiento  del pozo|O|O||D||1
71122805|Servicios de monitoreo de las bombas en el emplazamiento del pozo|O|O||D||1
71122806|Servicios de adquisición de datos de la superficie en el emplazamiento del pozo|O|O||D||1
71122807|Servicios de lectura de la superficie en el emplazamiento del pozo|O|O||D||1
71122808|Servicios de grabación de la superficie en el emplazamiento del pozo|O|O||D||1
71122810|Servicios de pruebas de la superficie inferior del pozo|O|O||D||1|Servicio de prueba del subsuelo del pozo
71122900|Aparejos del campo petrolífero|O|O||D||1
71122901|Servicios de aparejos del campo petrolero en aguas profundas|O|O||D||1
71122902|Servicios de plataformas  petroleras autoelevables (jackup)|O|O||D||1
71122903|Servicios de plataformas petroleras en barcazas|O|O||D||1|Servicios de plataformas petroleras en embarcaciones
71122904|Servicios de plataforma petroleras en tierra|O|O||D||1
71122905|Servicios de plataformas petroleras|O|O||D||1
71123000|Servicios integrados|O|O||D||1
71123001|Administración y provisión de todas los servicios de las instalaciones, ingeniería, modificación y mantenimiento para un emplazamiento o plataforma|O|O||D||1
71123002|Administración y operación de todas los servicios de las instalaciones, ingeniería, modificación y mantenimiento para un emplazamiento o plataforma|O|O||D||1
71123003|Servicios de producción y desarrollo de los depósitos de hidrocarburos|O|O||D||1|Servicio de desarrollo y producción de yacimientos de hidrocarburos
71123004|Servicios de construcción/administración de pozos|O|O||D||1
71123005|Administración y provisión de todos los servicios de catering, limpieza, oficina y seguridad en el emplazamiento o plataforma|O|O||D||1
71123006|Desarrollo de campos|O|O||D||1
71123007|Servicios de rehabilitación de campos|O|O||D||1
71131000|Servicios de fracturar del pozo|O|O||D||1
71131001|Servicios de fracturación del pozo con fluido a base de ácido|O|O||D||1|Servicios de fracturación con fluido  base ácido
71131002|Servicios de fracturación del pozo con fluido a base de emulsión|O|O||D||1
71131003|Servicios de fracturación del pozo con fluido a base de espuma|O|O||D||1
71131004|Servicios de fracturación  del pozo de petróleo|O|O||D||1
71131005|Servicios de control de la báscula del pozo de petróleo|O|O||D||1
71131006|Servicios de pruebas de fracturación del pozo|O|O||D||1
71131007|Servicios de evaluación de la fracturación del pozo en el fondo del pozo|O|O||D||1
71131008|Servicios de control de la altura de la fracturación del pozo|O|O||D||1
71131009|Servicios de monitoreo de la fracturación del pozo|O|O||D||1
71131010|Servicios de diseño del servicio de fracturación del pozo|O|O||D||1
71131011|Servicios de evaluación del servicio de fracturación del pozo|O|O||D||1
71131012|Servicios de evaluación de superficie de la fracturación del pozo|O|O||D||1
71131013|Servicios de control de calidad del tratamiento de la fracturación del pozo|O|O||D||1
71131014|Servicios de fracturación  del pozo con fluidos a base de aceite|O|O||D||1
71131015|Otros servicios de fracturación de pozos|O|O||D||1
71131016|Servicios de manejo del esfuerzo de fracturación del pozo|O|O||D||1
71131018|Servicios de fracturación del pozo con fluido lineal a base de agua|O|O||D||1|Servicios de fracturación con fluido lineal  base agua
71131019|Servicios de fracturación de pozos con fluido entrecruzado a base de agua|O|O||D||1|Servicios de fracturación con fluido entrecruzado  base  agua
71131100|Servicios de estimulación de la matriz|O|O||D||1
71131101|Servicios de estimulación de la matriz  a base de ácido|O|O||D||1
71131102|Servicios de estimulación de la matriz de sellamiento de la formación|O|O||D||1
71131103|Servicios de limpieza total orgánica de la matriz|O|O||D||1|Servicios de limpieza con una matriz orgánica
71131104|Servicios de inhibición orgánica de la matriz|O|O||D||1|Servicios de inhibición con una matriz orgánica
71131105|Servicios de limpieza general de la balanza de la matriz|O|O||D||1
71131106|Servicios de inhibición de la balanza de la matriz|O|O||D||1
71131107|Servicios de diseño del tratamiento de la matriz|O|O||D||1|Servicios de diseño de tratamientos matriciales
71131108|Servicios de desviación del tratamiento de la matriz|O|O||D||1|Servicios de desviación de tratamiento matricial
71131109|Servicios de evaluación del tratamiento de la matriz|O|O||D||1
71131110|Servicios del control de calidad del tratamiento de la matriz|O|O||D||1
71131111|Servicios de estimulación de la matriz de base no ácida|O|O||D||1|Servicios de estimulación de la matriz de base no ácida
71131200|Servicios de nitrógeno del campo petrolífero|O|O||D||1
71131201|Servicios de nitrógeno para el pozo|O|O||D||1
71131300|Otros servicios de bombeo del campo petrolífero|O|O||D||1
71131301|Servicios de bombeo del campo petrolero con bocatoma de fondo|O|O||D||1
71131302|Servicios de bombeo del campo petrolero utilizando cables|O|O||D||1
71131303|Servicios de bombeo del campo petrolero con co2|O|O||D||1
71131304|Servicios de bombeo del campo petrolero utilizando tubería flexible continua|O|O||D||1
71131305|Servicios de bombeo en el fondo del pozo|O|O||D||1
71131306|Servicios de terminación dual del pozo|O|O||D||1
71131307|Servicios de bombeo horizontal del pozo|O|O||D||1
71131308|Servicios de operación o arrastre de la instalación de bombeo del campo petrolífero|O|O||D||1|Servicios de extracción o de operación de instalaciones de bombeo de campos petrolíferos
71131309|Servicios de modificación del perfil del pozo|O|O||D||1
71131310|Servicios de bobinado del campo petrolífero|O|O||D||1
71131311|Servicios de bombeo de cavidad progresiva|O|O||D||1
71131312|Servicios de bombeo electrónico sumergible|O|O||D||1
71131313|Servicios de bombeo convencional|O|O||D||1
71131400|Servicios de producción del pozo|O|O||D||1
71131401|Servicios del sistema de llamarada del campo petrolífero|O|O||D||1|Servicios del sistema de llamarada del campo petrolero
71131402|Servicio de aceite o agua caliente para el campo petrolero|O|O||D||1
71131403|Servicio de vapor del campo petrolero|O|O||D||1
71131404|Servicios de recuperación de sulfuro|O|O||D||1|Servicios de eliminación de sulfuro
71131405|Servicios de control de formación de hidratos en las tuberías de producción|O|O||D||1
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
