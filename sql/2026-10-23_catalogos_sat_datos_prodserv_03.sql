-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 3 de 10 (5028 claves; total 52513)
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
25111511|Barco de tripulación de gas o petróleo|O|O||D||1
25111512|Barco de trabajo de gas o petróleo|O|O||D||1
25111513|Barco para sísmica|O|O||D||1
25111514|Rompehielos|O|O||D||1
25111515|Carguero de gas líquido|O|O||D||1
25111516|Bote de caucho inflable|O|O||D||1
25111517|Batiscafo (hovercraft)|O|O||D||1|Aerodeslizador
25111518|Buque hospital|O|O||D||1
25111519|Bote de carreras|O|O||D||1
25111520|Boya|O|O||D||1|Baliza flotante
25111521|Ancla marina|O|O||D||1
25111522|Carguero tanquero químico|O|O||D||1|Buque de carga con tanque químico
25111523|Buque fábrica|O|O||D||1
25111524|Buque granelero|O|O||D||1
25111525|Buque roll on – roll off|O|O||D||1|Buques de remolque de autos
25111526|Buque taladro|O|O||D||1
25111527|Bote de remos|O|O||D||1
25111528|Bote de cuarentena|O|O||D||1
25111529|Buque de meteorología|O|O||D||1
25111530|Bote de piloto|O|O||D||1
25111531|Barco para levantamientos hidrográficos|O|O||D||1
25111532|Nave para recolección de escombros|O|O||D||1
25111533|Buque de entrenamiento|O|O||D||1
25111534|Buque de investigación|O|O||D||1
25111535|Buque para el tendido de cable|O|O||D||1
25111600|Embarcaciones de seguridad y salvamento|O|O||D||1
25111601|Lanchas o balsas salvavidas|O|O||D||1
25111602|Nave para apagar incendios|O|O||D||1
25111603|Buques o botes de rescate|O|O||D||1
25111700|Embarcaciones militares|O|O||D||1
25111701|Submarinos|O|O||D||1
25111702|Portaviones|O|O||D||1
25111703|Barcos de munición|O|O||D||1
25111704|Barcos de asalto anfibio|O|O||D||1
25111705|Muelles anfibios de transporte|O|O||D||1
25111706|Buques anfibios de comando|O|O||D||1
25111707|Buques de comando|O|O||D||1
25111708|Buques de guerra|O|O||D||1
25111709|Destructores|O|O||D||1
25111710|Buques de desembarco|O|O||D||1
25111711|Buques de apoyo de combate rápido|O|O||D||1
25111712|Fragatas|O|O||D||1
25111713|Buques petroleros de escuadra|O|O||D||1
25111714|Embarcación de desembarque de uso general|O|O||D||1
25111715|Embarcación mecanizada o de uso general|O|O||D||1
25111716|Buques buscaminas|O|O||D||1
25111717|Buques dragaminas|O|O||D||1
25111718|Embarcaciones de patrulla costera|O|O||D||1
25111719|Buques nodriza para submarinos|O|O||D||1
25111720|Botes para desembarco de tanques|O|O||D||1
25111721|Embarcaciones de desembarque aerodeslizadas|O|O||D||1
25111722|Barco guardacostas|O|O||D||1
25111723|Bote de patrulla pesquera|O|O||D||1
25111724|Nave de entrenamiento de pesca|O|O||D||1
25111725|Nave de investigación de pesca|O|O||D||1
25111726|Nave para el control de la contaminación marina|O|O||D||1
25111800|Embarcaciones de recreo|O|O||D||1
25111801|Embarcaciones a vela de recreo|O|O||D||1
25111802|Lanchas de recreo a motor|O|O||D||1
25111803|Lanchas de recreo a remo|O|O||D||1
25111804|Canoas o kayaks|O|O||D||1
25111805|Artefactos a motor de uso personal|O|O||D||1
25111806|Balsas|O|O||D||1
25111807|Lanchas pequeñas|O|O||D||1
25111808|Yates|O|O||D||1
25111900|Sistemas y premontajes de embarcaciones marítimas|O|O||D||1
25111901|Sistemas de comunicaciones de embarcaciones marítimas|O|O||D||1|Sistemas de comunicaciones marinas
25111902|Hélices marítimas|O|O||D||1|Hélices para barcos
25111903|Velas|O|O||D||1
25111904|Remos|O|O||D||1
25111905|Sistemas balísticos de la marina|O|O||D||1
25111906|Cuñas de ancla|O|O||D||1
25111907|Cables de ancla|O|O||D||1
25111908|Recuperadores de ancla|O|O||D||1
25111909|Rodillos de ancla|O|O||D||1
25111910|Rampas de embarcaciones|O|O||D||1
25111911|Bicheros|O|O||D||1
25111912|Recogedores de botavaras|O|O||D||1|Enrolladores de vela mayor
25111913|Escotillas de cubierta|O|O||D||1
25111914|Argollas de amarre|O|O||D||1
25111915|Escaleras de muelle|O|O||D||1
25111916|Señales de teñido de emergencia|O|O||D||1|Señales visuales de socorro
25111917|Alabantes|O|O||D||1|Bolardos De Amarre
25111918|Sistemas de recogido de velas|O|O||D||1
25111919|Protectores de la quilla|O|O||D||1
25111920|Defensas|O|O||D||1|Guardabarros marinos
25111921|Cuellos de ganso marinos|O|O||D||1
25111922|Cabos de amarre|O|O||D||1
25111923|Bloqueos de remos|O|O||D||1
25111924|Reflectores de radar|O|O||D||1
25111925|Timones|O|O||D||1
25111926|Refuerzos de velas|O|O||D||1
25111927|Botavaras|O|O||D||1
25111928|Fundas de velas|O|O||D||1
25111929|Sacas|O|O||D||1
25111930|Palos de espinaquer|O|O||D||1
25111931|Plataformas de popa|O|O||D||1
25111932|Cortavientos|O|O||D||1
25111933|Relojes de mareas|O|O||D||1
25111934|Cañas de timones|O|O||D||1
25111935|Berlingas|O|O||D||1
25111936|Propulsor marino|O|O||D||1
25111937|Protector de mástil|O|O||D||1
25111938|Generador marino de agua fresca|O|O||D||1
25111939|Engranaje de dirección marino|O|O||D||1
25111940|Simulador de navegación marina|O|O||D||1
25121500|Locomotoras y vagonetas eléctricas|O|O||D||1
25121501|Locomotoras diesel de carga|O|O||D||1
25121502|Locomotoras eléctricas de carga|O|O||D||1
25121503|Locomotoras diesel de pasajeros|O|O||D||1
25121504|Locomotoras eléctricas de pasajeros|O|O||D||1
25121600|Vagones de ferrocarril y tranvía|O|O||D||1
25121601|Vagones de carga|O|O||D||1
25121602|Vagones cisterna|O|O||D||1
25121603|Vagones de pasajeros|O|O||D||1
25121604|Vagones tolva o góndolas|O|O||D||1
25121605|Tranvías|O|O||D||1
25121700|Equipo y sistemas de apoyo ferroviario|O|O||D||1
25121701|Sistemas de cambiavías|O|O||D||1
25121702|Traviesas|O|O||D||1
25121703|Vías férreas|O|O||D||1
25121704|Eclisas|O|O||D||1|Bridas
25121705|Enganches de rieles|O|O||D||1
25121706|Aparatos de tracción|O|O||D||1
25121707|Conjuntos de bogie|O|O||D||1|Montajes de bogíes
25121708|Riel férreo pesado|O|O||D||1
25121709|Riel férreo pesado de segundo uso|O|O||D||1
25121710|Riel férreo liviano|O|O||D||1
25121711|Riel férreo liviano de segundo uso|O|O||D||1
25121712|Amarre férreo de acero|O|O||D||1
25121713|Contacto eléctrico de rieles|O|O||D||1
25121714|Conmutador férreo de giro de rieles pesados|O|O||D||1
25121715|Conmutador férreo de giro de rieles livianos|O|O||D||1
25121716|Amarre férreo de madera|O|O||D||1|Lazo de madera del ferrocarril
25121717|Unión eléctrica de rieles|O|O||D||1|Corbata de madera del ferrocarril
25131500|Aeronave de alas fijas motorizada|O|O||D||1
25131501|Aeronave agrícola de ala fija|O|O||D||1|Juntas de carril aisladas
25131502|Avión de carga de hélice|O|O||D||1
25131503|Hidroaviones|O|O||D||1
25131504|Avión de hélice comercial de pasajeros|O|O||D||1
25131505|Avión jet de carga|O|O||D||1
25131506|Avión jet de pasajeros|O|O||D||1
25131507|Avión de hélice privado o de negocios|O|O||D||1
25131508|Jet privado o de negocios|O|O||D||1
25131509|Aeronave de entrenamiento de ala fija|O|O||D||1
25131600|Aeronave de alas giratorias civil y comercial|O|O||D||1
25131601|Helicópteros de pasajeros|O|O||D||1
25131602|Helicópteros de carga|O|O||D||1
25131603|Helicópteros agrícolas|O|O||D||1
25131604|Helicópteros médicos o de rescate|O|O||D||1
25131605|Aeronave de entrenamiento de ala rotativa o helicóptero de entrenamiento|O|O||D||1
25131700|Aeronave de ala fija militar|O|O||D||1
25131701|Avión bombardero|O|O||D||1
25131702|Avión cazabombardero|O|O||D||1
25131703|Avión de caza|O|O||D||1
25131704|Avión de ataque|O|O||D||1
25131705|Aviones no tripulados objetivo o de reconocimiento|O|O||D||1
25131706|Hidroaviones militares|O|O||D||1
25131707|Aeronave de reconocimiento o vigilancia|O|O||D||1
25131708|Avión antisubmarino|O|O||D||1
25131709|Avión de transporte militar|O|O||D||1
25131800|Avión especial|O|O||D||1
25131801|Dirigibles|O|O||D||1
25131802|Aeromodelo|O|O||D||1
25131900|Avión militar de ala giratoria|O|O||D||1
25131902|Helicópteros de transporte militar|O|O||D||1
25131903|Helicópteros de ataque|O|O||D||1
25131904|Helicópteros de reconocimiento|O|O||D||1
25131905|Helicópteros antisubmarinos|O|O||D||1
25131906|Aeronave de alas giratorias basculantes|O|O||D||1
25132000|Avión de recreo|O|O||D||1
25132001|Aerodeslizadores|O|O||D||1
25132002|Globos aerostáticos|O|O||D||1
25132003|Planeadores|O|O||D||1
25132004|Parapente|O|O||D||1
25132005|Aviones ultralivianos|O|O||D||1
25151500|Naves espaciales|O|O||D||1
25151501|Nave espacial tripulada|O|O||D||1
25151502|Estructuras de naves espaciales|O|O||D||1
25151700|Satélites|O|O||D||1
25151701|Satélites de comunicación|O|O||D||1
25151702|Satélites meteorológicos|O|O||D||1
25151703|Satélites militares|O|O||D||1
25151704|Satélites científicos o de investigación|O|O||D||1
25151705|Satélites de navegación|O|O||D||1
25151706|Satélites geoestacionarios|O|O||D||1
25151707|Satélites de órbita cercana a la tierra|O|O||D||1
25151708|Satélites de órbita sincronizada con el sol|O|O||D||1
25151709|Satélites geo – sincronizados|O|O||D||1|Satélites geosincrónicos
25161500|Vehículos a pedal|O|O||D||1
25161501|Bicicletas de turismo|O|O||D||1
25161502|Monociclos|O|O||D||1
25161503|Triciclos|O|O||D||1
25161504|Bicicletas tándem|O|O||D||1
25161505|Bicicletas de montaña|O|O||D||1
25161506|Bicicletas de carreras|O|O||D||1
25161507|Bicicletas|O|O||D||1
25161508|Bicicletas reclinadas|O|O||D||1
25161509|Bicicletas para niños|O|O||D||1
25161510|Bicicletas de cuatro ruedas o cuadriciclos|O|O||D||1
25171500|Limpiaparabrisas|O|O||D||1|Refacciones automotrices o autopartes
25171502|limpiaparabrisas para automóviles|O|O||D||1
25171503|Limpiaparabrisas para locomotoras|O|O||D||1|Limpiaparabrisas para tren
25171504|Limpiaparabrisas marítimos|O|O||D||1|Limpiadores de parabrisas marinos
25171505|Limpiaparabrisas de camión|O|O||D||1
25171506|Bomba de lava parabrisas|O|O||D||1|Bomba de agua para limpiaparabrisas
25171507|Cuchillas limpiadoras|O|O||D||1|Pluma limpiaparabrisas
25171508|Motor del limpiaparabrisas|O|O||D||1
25171600|Sistemas de descarchado y antiniebla|O|O||D||1|Refacciones automotrices o autopartes
25171602|Sistemas de desescarchado y antiniebla para automóviles|O|O||D||1
25171603|Sistemas de desescarchado y antiniebla para trenes|O|O||D||1
25171700|Sistemas de frenado y componentes|O|O||D||1|Refacciones automotrices o autopartes
25171702|Sistemas de frenado para automóviles|O|O||D||1
25171703|Sistemas de frenado para trenes|O|O||D||1
25171704|Chutes de arrastre|O|O||D||1
25171705|Rotores|O|O||D||1
25171706|Calibrador de frenaje|O|O||D||1|Cáliper de freno
25171707|Freno de tambor|O|O||D||1|Pinzas de freno
25171708|Freno de disco|O|O||D||1|Balatas
25171709|Freno enfriado con líquido|O|O||D||1
25171710|Cilindros principales|O|O||D||1
25171711|Cilindros esclavos|O|O||D||1
25171712|Zapatas de freno de tambor|O|O||D||1
25171713|Almohadillas de discos de freno|O|O||D||1|Almohadillas para balatas, Pastillas de freno de disco
25171714|Tambor de freno|O|O||D||1
25171715|Rotores de frenos de disco|O|O||D||1
25171716|Líneas de freno|O|O||D||1|Mangueras de frenos
25171717|Pistones de freno|O|O||D||1
25171718|Kits de reparación de frenos|O|O||D||1
25171719|Refuerzos de frenado|O|O||D||1
25171720|Freno de circuito dual|O|O||D||1
25171721|Freno mecánico o de parqueo|O|O||D||1|Freno de mano
25171722|Tornillo de rosca de purga del freno|O|O||D||1
25171723|Sistema de frenos antibloqueo – ABS|O|O||D||1
25171724|Bobina del sistema de frenos antibloqueo – ABS|O|O||D||1
25171725|Freno de banda|O|O||D||1
25171900|Ruedas y acabados|O|O||D||1|Refacciones automotrices o autopartes
25171901|Rines o ruedas para automóviles|O|O||D||1
25171902|Ruedas para trenes|O|O||D||1
25171903|Rines o ruedas para camiones|O|O||D||1
25171905|Válvulas de neumáticos|O|O||D||1|Pivotes para llantas
25171906|Cubiertas de llantas de automóviles|O|O||D||1
25172000|Componentes de sistema de suspensión|O|O||D||1|Refacciones automotrices o autopartes
25172001|Sistemas de suspensión para automóviles|O|O||D||1
25172002|Sistemas de suspensión para camiones|O|O||D||1
25172003|Amortiguadores para camiones|O|O||D||1
25172004|Amortiguadores para automóviles|O|O||D||1
25172005|Sistemas de suspensión para trenes|O|O||D||1
25172007|Puntales|O|O||D||1
25172009|Buje de automóvil|O|O||D||1
25172010|Barra anti -  ladeo|O|O||D||1|Barra de sacudimiento
25172011|Amortiguadores de choque|O|O||D||1|Amortiguadores
25172012|Placa deslizante|O|O||D||1
25172013|Brazo de control de automóvil|O|O||D||1
25172014|Sistema activo de suspensión|O|O||D||1
25172100|Componentes y sistemas de seguridad de vehículo|O|O||D||1|Refacciones automotrices o autopartes
25172101|Airbags|O|O||D||1|Bolsas de aire
25172104|Cinturones de seguridad|O|O||D||1
25172105|Sistemas para evitar choques|O|O||D||1
25172106|Sistemas sensores de impacto|O|O||D||1
25172108|Apoyacabezas|O|O||D||1|Cabeceras de automóviles
25172109|Latas de propulsor de airbags|O|O||D||1|Botes de propulsor de bolsa de aire
25172110|Pito de vehículo|O|O||D||1|Claxon de vehículo
25172111|Sistema remoto de bloqueo|O|O||D||1|Sistema de cierre remoto
25172112|Sistemas de control de la estabilidad del vehículo|O|O||D||1
25172113|Sistemas de control de la tracción del vehículo|O|O||D||1
25172114|Bloqueadores de ruedas|O|O||D||1|Birlos para llantas
25172115|Sistema de bloqueo central|O|O||D||1|Cierre centralizado
25172116|Cadenas de llantas para nieve|O|O||D||1
25172117|Ensamble de cubierta de airbag|O|O||D||1|Ensamble de cubierta de la bolsa de aire
25172118|Ensamble de tela de airbag|O|O||D||1|Ensamble de tela de la bolsa de aire
25172119|Tela de airbag|O|O||D||1|Tela de la bolsa de aire
25172120|Inflador de airbag|O|O||D||1
25172121|Inflador de airbag del conductor|O|O||D||1|Inflador de la bolsa de aire del conductor
25172122|Inflador de airbag del pasajero|O|O||D||1|Inflador de la bolsa de aire del pasajero
25172123|Inflador de airbag de rodilla|O|O||D||1|Inflador de la bolsa de aire de rodilla
25172124|Inflador de airbag lateral|O|O||D||1|Inflador de la bolsa de aire lateral
25172125|Inflador de airbag de cortina|O|O||D||1|Inflador de la bolsa de aire de cortina
25172126|Tejido de cinturones de seguridad|O|O||D||1
25172127|Sensor de peso de asientos|O|O||D||1
25172128|Sensor de tensión del cinturón de seguridad bts|O|O||D||1
25172129|Sistema de información del conductor|O|O||D||1|Tablero de información del conductor
25172130|Control de acceso del vehículo sin llave o fob|O|O||D||1|Transmisor fob
25172131|Inmovilizador|O|O||D||1|Bastón
25172200|Puertas para vehículos|O|O||D||1|Refacciones automotrices o autopartes
25172201|Puertas de automotores desmontables|O|O||D||1
25172203|Puertas de automotores|O|O||D||1
25172204|Puertas de persiana para camiones|O|O||D||1|Puertas enrollables para camiones
25172205|Compuertas inferiores o puertas elevadoras|O|O||D||1|Plataformas elevadoras
25172300|Ventanas y parabrisas para vehículos|O|O||D||1|Refacciones automotrices o autopartes
25172301|Parabrisas para automotores|O|O||D||1
25172303|Ventanas para automotores|O|O||D||1|Ventanas automotrices
25172304|Cremallera de ventana o ensamble regulatorio|O|O||D||1|Ensamble de ventana o regulador de ventana
25172305|Parabrisas para vehículo de dos ruedas|O|O||D||1
25172400|Depósitos y sistemas de combustible|O|O||D||1|Refacciones automotrices o autopartes
25172404|Sistemas de almacenaje de combustible híbrido|O|O||D||1
25172405|Sistemas de inyección de combustible|O|O||D||1
25172406|Tanques de combustible|O|O||D||1
25172407|Elementos respiraderos|O|O||D||1|Elementos de evacuación
25172408|Tapas de aceite o combustible|O|O||D||1
25172409|Módulo de combustible|O|O||D||1|Bomba de gasolina
25172410|Inyector o anillo de combustible|O|O||D||1
25172411|Flotador de tanque de combustible|O|O||D||1
25172500|Neumáticos y cámaras de neumáticos|O|O||D||1|Refacciones automotrices o autopartes
25172502|Neumático para llantas de automóviles|O|O||D||1
25172503|Llantas para camiones pesados|O|O||D||1
25172504|Llantas para automóviles o camionetas|O|O||D||1
25172505|Llantas de bicicleta|O|O||D||1
25172506|Neumáticos de bicicleta|O|O||D||1
25172507|Cordón de llanta|O|O||D||1|Cable del neumático
25172508|Labrado de llanta|O|O||D||1|Dibujo de las llantas
25172509|Neumáticos para llantas de camiones pesados|O|O||D||1
25172510|Neumático de espuma|O|O||D||1
25172511|Kit de reparación de llantas|O|O||D||1
25172512|Llanta de motocicleta|O|O||D||1
25172600|Acabados y revestimientos exterior para vehículos|O|O||D||1|Refacciones automotrices o autopartes
25172601|Acabados para automotores|O|O||D||1
25172602|Guardabarros|O|O||D||1|Salpicadera de moto
25172603|Parachoques para automotores|O|O||D||1|Paragolpes automotrices
25172604|Espejos retrovisores|O|O||D||1
25172605|Parrillas de vehículos|O|O||D||1
25172606|Capós de vehículos|O|O||D||1|Cofre de vehículos
25172607|Paneles laterales de vehículos|O|O||D||1
25172608|Tableros|O|O||D||1
25172609|Faldón anti – fango|O|O||D||1
25172610|Placa de matrícula|O|O||D||1
25172611|Guarda – bómper|O|O||D||1|Protector de parachoques del vehículo
25172700|Sistemas de control medioambiental|O|O||D||1|Refacciones automotrices o autopartes
25172702|Sistemas de control medioambiental espacial|O|O||D||1
25172703|Sistemas de control medioambiental marítimo|O|O||D||1
25172704|Sistema control temperatura vehículo|O|O||D||1|Sistemas de climatización de vehículos
25172705|Cerca para aceite|O|O||D||1
25172706|Protector de limo|O|O||D||1
25172707|Separador de aceite|O|O||D||1
25172708|Máquina para el control de algas|O|O||D||1
25172709|Aire acondicionado vehicular|O|O||D||1
25172710|Calentador vehicular|O|O||D||1
25172711|Purificador de aire para vehículos|O|O||D||1
25172800|Sistemas y componentes hidráulicos|O|O||D||1|Refacciones automotrices o autopartes
25172802|Sistemas hidráulicos para automotores|O|O||D||1
25172803|Sistemas hidráulicos marítimos|O|O||D||1
25172900|Iluminación exterior para vehículos|O|O||D||1|Refacciones automotrices o autopartes
25172901|Iluminación exterior para automóviles|O|O||D||1
25172903|Iluminación exterior para vagones de tren|O|O||D||1
25172904|Iluminación exterior para buques o barcos|O|O||D||1
25172905|Sistema para lavar o limpiar la farola delantera|O|O||D||1|Limpiaparabrisas o lavaparabrisas
25172906|Reflectores|O|O||D||1
25172907|Luz frontal del vehículo|O|O||D||1|Faros de automóviles
25172908|Luz trasera del vehículo|O|O||D||1|Calaveras de automóviles
25173000|Iluminación interior para vehículos|O|O||D||1|Refacciones automotrices o autopartes
25173001|Iluminación interior para automóviles|O|O||D||1
25173003|Iluminación interior para vagones de tren|O|O||D||1
25173004|Iluminación interior para buques o barcos|O|O||D||1
25173005|Ensamblajes de iluminación de las placas|O|O||D||1|Conjuntos de placa de luz
25173006|Lente no recubierto para iluminación interior del vehículo|O|O||D||1|Lente de iluminación interior del vehículo no revestido
25173007|Lente recubierto para iluminación interior del vehículo|O|O||D||1|Lente de iluminación interior de vehículo revestido
25173008|Tubo de luz de vehículo|O|O||D||1
25173100|Sistemas y componentes de localización y navegación|O|O||D||1|Refacciones automotrices o autopartes
25173107|Sistemas de posicionamiento global de vehículos|O|O||D||1|Sistema de Localización global de vehículos
25173108|Sistemas de navegación vehicular|O|O||D||1|Sistema GPS
25173300|Sistemas de control principal|O|O||D||1|Refacciones automotrices o autopartes
25173303|Sistemas de computador|O|O||D||1|Sistemas informáticos para automóviles
25173304|Sistemas electrónicos de ignición|O|O||D||1
25173700|Controles de emisión y de escape|O|O||D||1|Refacciones automotrices o autopartes
25173701|Convertidores catalíticos|O|O||D||1|Catalizador
25173702|Silenciadores de exhosto o resonadores|O|O||D||1
25173703|Colector de escape|O|O||D||1
25173704|Adaptadores de silenciadores|O|O||D||1
25173705|Amortiguadores de chispas|O|O||D||1
25173706|Alfombra catalítica|O|O||D||1
25173707|Sustrato catalítico|O|O||D||1
25173708|Recubrimiento y solución para desechos catalíticos|O|O||D||1
25173800|Sistemas de tren de transmisión|O|O||D||1|Refacciones automotrices o autopartes
25173801|Ejes de manejo|O|O||D||1
25173802|Ejes no de manejo|O|O||D||1
25173803|Carcasas de eje|O|O||D||1
25173804|Husillos de giro de eje|O|O||D||1
25173805|Diferenciales|O|O||D||1
25173806|Juntas de velocidad constante|O|O||D||1
25173807|Ejes de cardán|O|O||D||1
25173808|Equipo de reparar ejes|O|O||D||1
25173809|Buje de eje|O|O||D||1
25173810|Juntas de cardán|O|O||D||1
25173811|Ejes de tracción|O|O||D||1
25173812|Transmisiones manuales|O|O||D||1
25173813|Transmisiones automáticas|O|O||D||1
25173815|Cables de embrague|O|O||D||1
25173816|Componentes hidráulicos de embrague|O|O||D||1
25173817|Cadenas de los engranajes conductores|O|O||D||1|Cadenas de transmisión
25173818|Eje propulsor|O|O||D||1
25173819|Cigüeñal de la hélice marina|O|O||D||1
25173820|Transmisión continuamente variable|O|O||D||1
25173821|Ensamblaje de unidad de transferencia|O|O||D||1
25173900|Componentes eléctricos|O|O||D||1|Refacciones automotrices o autopartes
25173901|Ignición|O|O||D||1|Encendido
25173902|Arranque del motor|O|O||D||1
25173903|Componente de corte y protección eléctrica al interior del vehículo|O|O||D||1
25174000|Sistema de refrigerar de motor|O|O||D||1|Refacciones automotrices o autopartes
25174001|Ventilador|O|O||D||1
25174002|Radiadores de motor|O|O||D||1
25174003|Tapas de radiador|O|O||D||1
25174004|Refrigerante de motor|O|O||D||1
25174005|Indicadores de aguja del tablero|O|O||D||1
25174006|Ensamble de manguera de agua refrigerante|O|O||D||1
25174100|Sistemas de tejado|O|O||D||1|Refacciones automotrices o autopartes
25174101|Salida de emergencia de vehículos|O|O||D||1
25174102|Techos permanentes convertibles|O|O||D||1
25174103|Techos duros desmontables|O|O||D||1
25174104|Techos blandos desmontables|O|O||D||1
25174105|Sistemas de rejillas de techo|O|O||D||1|Sistemas de barras de techo
25174106|Sunroofs o techos corredizos|O|O||D||1|Quemacocos
25174107|Deflectores de viento|O|O||D||1
25174200|Sistema de dirección|O|O||D||1|Refacciones automotrices o autopartes
25174201|Sacos de dirección|O|O||D||1|Visor de viento
25174202|Suspensión de dirección|O|O||D||1
25174203|Junta de bola|O|O||D||1
25174204|Sistema de dirección hidráulica|O|O||D||1|Rótula de dirección
25174205|Bielas|O|O||D||1
25174206|Contramanivela|O|O||D||1
25174207|Varillas de dirección|O|O||D||1
25174208|Eje de bloqueo|O|O||D||1
25174209|Piñones|O|O||D||1
25174210|Cable de afinamiento de dirección hidráulica|O|O||D||1|Cable de ajuste de dirección hidráulica
25174211|Timones o volantes|O|O||D||1|Volantes
25174212|Ensambles de columna de dirección|O|O||D||1
25174213|Ensambles de cilindro de dirección|O|O||D||1
25174214|Timones o volantes de madera|O|O||D||1|Volante de madera
25174215|Timones o volantes de cuero|O|O||D||1|Volante de cuero
25174216|Brazo articulado de dirección|O|O||D||1
25174217|Engranaje de dirección de vehículo|O|O||D||1|Equipo de dirección de vehículos
25174400|Sistemas del interior de vehículos|O|O||D||1|Refacciones automotrices o autopartes
25174401|Biseles|O|O||D||1
25174402|Consolas|O|O||D||1
25174403|Paneles de puerta|O|O||D||1
25174404|Tapizado del techo|O|O||D||1
25174405|Grupos de instrumentos|O|O||D||1
25174406|Paneles de instrumentos|O|O||D||1
25174407|Pedales|O|O||D||1
25174408|Puntos para energía o para encendedores|O|O||D||1|Puertos de alimentación o encendedores
25174409|Visores de sol|O|O||D||1|Viseras de sol
25174410|Componentes y sistemas de sonido del vehículo|O|O||D||1|Sistema de audio para el vehículo
25174411|Acolchado de caucho de la llave|O|O||D||1
25174412|Aplique decorativo del vehículo|O|O||D||1|Aplicación decorativa para vehículos
25174413|Escudo o emblema interior del vehículo|O|O||D||1
25174414|Tacógrafo|O|O||D||1|Tacómetro de un automóvil
25174415|Indicador de la presión de aceite del vehículo|O|O||D||1
25174416|Encendedor de cigarrillos del vehículo|O|O||D||1
25174417|Interruptor de combinación del vehículo|O|O||D||1
25174418|Tapetes del vehículo|O|O||D||1
25174419|Sistema de audio video del vehículo|O|O||D||1
25174420|Cenicero del vehículo|O|O||D||1
25174421|Cortina del vehículo|O|O||D||1
25174600|Sistemas de asientos del vehículo|O|O||D||1|Refacciones automotrices o autopartes
25174601|Fundas de asientos|O|O||D||1
25174602|Cojinería de asientos|O|O||D||1|Cojines de asiento
25174603|Marcos de asientos|O|O||D||1
25174604|Silla de timonel de bote|O|O||D||1|Asiento del timón o del barco
25174605|Silla de motocicleta|O|O||D||1
25174700|Componentes de ciclo no motorizado o accesorios|O|O||D||1|Componentes de bicicletas o accesorios
25174701|Pedales de bicicleta|O|O||D||1
25174702|Rayos de bicicleta|O|O||D||1
25174703|Caja trasera de motocicleta|O|O||D||1
25174704|Canasta para vehículo de dos ruedas|O|O||D||1
25174705|Caja para llevar el correo en vehículo de dos ruedas|O|O||D||1
25174800|Componentes y sistemas de vehículos especializados|O|O||D||1|Refacciones automotrices o autopartes
25174801|Estabilizador de camión de succión o gato de piso|O|O||D||1
25174802|Boom para vehículos de rescate o de remolque|O|O||D||1
25174803|Gancho de remolcar|O|O||D||1
25174804|Mástil lateral para vehículo|O|O||D||1
25174805|Aspersor de arena para vehículo|O|O||D||1|Esparcidor de arena o sal para vehículos
25174806|Pijama para vehículo a la medida|O|O||D||1|Funda cubre auto
25174807|Bisagra de vehículo|O|O||D||1
25174808|Caja de almacenamiento de accesorio para vehículos|O|O||D||1
25174809|Escalera de vehículo|O|O||D||1
25174810|Gato de vehículo|O|O||D||1
25174900|Aisladores y amortiguadores de vibración de vehículos|O|O||D||1|Refacciones automotrices o autopartes
25174901|Aislador y amortiguador moldeado para la vibración del vehículo|O|O||D||1|Amortiguador y aislador de vibraciones de vehículos moldeados
25174902|Aislador y amortiguador extruido para la vibración del vehículo|O|O||D||1|Amortiguador y aislador de vibraciones del vehículo extruido
25174903|Aislador y amortiguador fundido para la vibración del vehículo|O|O||D||1|Amortiguador y aislador de vibraciones
25175000|Sistemas de cargado eléctrico de vehículos|O|O||D||1|Refacciones automotrices o autopartes
25175001|Cargador portátil para vehículo eléctrico|O|O||D||1
25175002|Estación de carga de vehículo eléctrico|O|O||D||1
25175003|Kit para cargar vehículo eléctrico|O|O||D||1
25181600|Chasis automotriz|O|O||D||1|Chasis para automotor
25181601|Chasis para automóviles|O|O||D||1|Armazón para automóviles
25181602|Chasis para camiones|O|O||D||1|Armazón para camiones
25181603|Bastidores de motos|O|O||D||1|Chasis para motos
25181604|Carrocería de camión de carga|O|O||D||1
25181605|Carrocería de volqueta|O|O||D||1|Carrocería para camión de volteo
25181606|Carrocería de tráiler|O|O||D||1|Plataforma de tráiler
25181607|Cabina de tractor|O|O||D||1
25181608|Bastidor de vehículo|O|O||D||1
25181609|Tráiler granelero|O|O||D||1|Tráiler para remolque granelero
25181610|Tráiler para carga aérea|O|O||D||1|Tráiler para remolcar carga aérea
25181611|Tráiler dolly|O|O||D||1|Vehículo sin motor para conexión
25181612|Tráiler agrícola|O|O||D||1|Remolque agrícola
25181700|Remolques para productos y materiales|O|O||D||1|Vehículos para traslado de productos y materiales
25181701|Tráiler para contenedores|O|O||D||1|Tráiler para remolque de contenedores
25181702|Tráiler cama alta|O|O||D||1|Tráiler con plataforma
25181703|Remolques para ganado|O|O||D||1
25181704|Remolques carrotanque sin temperatura controlada|O|O||D||1|Tanques de almacenamiento sin temperatura controlada
25181705|Remolques carrotanque con temperatura controlada|O|O||D||1|Tanques de almacenamiento con temperatura controlada
25181706|Remolques contenedor con temperatura controlada|O|O||D||1|Contenedores de temperatura controlada
25181707|Remolques para transporte de automóviles (niñeras)|O|O||D||1|Madrinas para transporte de automóviles, Plataforma para transporte de automóviles
25181708|Enganches de remolque|O|O||D||1|Gancho de remolque
25181709|Pala cargadora|O|O||D||1|Cuchara cargadora, Pala cargadora frontal, Pala mecánic
25181710|Placas de matrícula de tráiler|O|O||D||1|Placas de tráiler
25181711|Remolque de motonieve|O|O||D||1|Trineo remolque
25181712|Remolque de motocicleta|O|O||D||1
25181713|Remolque de botes|O|O||D||1
25181714|Semi – remolque|O|O||D||1|Caja de remolque
25181715|Tráiler volqueta|O|O||D||1|Remolque góndola, Remolque volquete, Tráiler de volte
25181716|Chasís tráiler|O|O||D||1|Armazón para tráiler
25181717|Tráiler cama baja|O|O||D||1|Remolque para cama baja, Tráiler con plataforma baja
25181718|Tráiler con carrete de cable|O|O||D||1|Tráiler con remolque de carrete de cable
25181719|Tráiler refrigerado|O|O||D||1|Tráiler con remolque de refrigeración
25191500|Sistemas y equipo de apoyo para transporte aéreo|O|O||D||1
25191501|Sistemas de entrenamiento de apoyo terrestre|O|O||D||1
25191502|Sistemas de ensayo o mantenimiento de apoyo terrestre|O|O||D||1
25191503|Sistemas integrados de información de mantenimiento|O|O||D||1
25191504|Simuladores de vuelo para aviones|O|O||D||1|Simuladores o entrenadores de vuelo de aeronaves
25191505|Medios de carga y descarga para aviones|O|O||D||1|Palet de carga y descarga de aviones
25191506|Equipo para recargar combustible de aviones|O|O||D||1|Equipo de reabastecimiento de combustible de aviones
25191507|Equipo para deshielo de aviones|O|O||D||1|Equipos de deshielo de aeronaves
25191508|Pasarela telescópica para aviones|O|O||D||1|Puente de espera, embarque o llegada para aviones
25191509|Tractores remolcadores para aviones|O|O||D||1|Remolcador de aviones
25191510|Unidades de potencia para pista aérea|O|O||D||1
25191511|Equipo de lavabos para aeronaves|O|O||D||1|Equipo de servicio de lavado para aviones
25191512|Escalerillas transportables o rodantes|O|O||D||1|Escaleras transportables o rodantes
25191513|Kit de mantenimiento de vehículo de soporte en tierra|O|O||D||1
25191514|Barra de remolque de avión|O|O||D||1|Barra de remolque para avión ligero
25191515|Sistema de aproximación controlado por tierra|O|O||D||1|Sistema de aterrizaje instrumental
25191516|Unidad neumática para arranque de aeronaves|O|O||D||1|Unidad de arranque de aire de la aeronave
25191517|Camión calefactor y de aire acondicionado para aeronaves|O|O||D||1
25191518|Equipo sensor de pruebas aeronáuticas|O|O||D||1|Sistema de pruebas aeronáuticas
25191519|Adaptador de remolcado de aviones|O|O||D||1
25191520|Cámara de prueba ambiental|O|O||D||1
25191521|Sistema retráctil de soporte de cable gancho|O|O||D||1
25191522|Set de mantenimiento de motor de aeronave|O|O||D||1
25191523|Tractor para remolcar contenedores de equipaje aéreo|O|O||D||1|Remolcador o tractor de equipaje de avión
25191524|Banda transportadora para cargar equipaje en el avión|O|O||D||1
25191525|Camión para cargar combustible al avión|O|O||D||1
25191600|Sistemas y equipo de apoyo para transporte espacial|O|O||D||1
25191601|Simuladores de vuelo de naves espaciales|O|O||D||1
25191602|Sistemas de suministro de carga para naves espaciales|O|O||D||1
25191603|Vehículos de lanzamiento líquido|O|O||D||1
25191604|Vehículos de lanzamiento sólido|O|O||D||1
25191605|Módulos de servicio para naves espaciales|O|O||D||1
25191700|Equipo para el mantenimiento de vehículo|O|O||D||1
25191701|Equipos de balanceo de llantas|O|O||D||1|Equipos de balanceo de neumáticos
25191702|Equipos de alineación de llantas|O|O||D||1|Equipos de alineación de neumáticos
25191703|Máquinas para cambiar llantas|O|O||D||1|Cambiadores de neumáticos, Desmontadora de llantas
25191704|Pedestales de vehículo o motor|O|O||D||1|Soporte de vehículo o motor
25191705|Balanza de pistón y varilla de motor|O|O||D||1|Balanza de presión y motor de levas
25191706|Gato para levantar material rodante férreo|O|O||D||1|Colector elevador de material rodante ferroviario
25191707|Mesa ferroviaria para levantar motor y componente|O|O||D||1
25191708|Balanceo de carburador|O|O||D||1
25191709|Ajustador de potencia|O|O||D||1|Regulador de potencia
25191710|Lapeadora de válvulas|O|O||D||1
25191711|Pulidora de válvulas|O|O||D||1|Pasta pulidora de válvulas
25191712|Cortador de asientos de válvulas|O|O||D||1|Cortador de asientos de obturador
25191713|Dispositivo para reciclar anticongelante|O|O||D||1
25191714|Torno para frenos de tambor|O|O||D||1
25191715|Pulidora de zapatas de freno|O|O||D||1
25191716|Alicate para resortes de freno|O|O||D||1
25191717|Máquina para enderezar carrocerías de vehículos|O|O||D||1
25191718|Carrito para reparar carros por debajo|O|O||D||1
25191719|Llave para tuercas de llantas|O|O||D||1
25191720|Llave de bujías|O|O||D||1
25191721|Limpiador de bujías|O|O||D||1
25191722|Juego de herramientas de motor|O|O||D||1
25191723|Calentador de pistones|O|O||D||1
25191724|Kit para reconstruir transmisión automática|O|O||D||1
25191725|Máquina perforadora para automóviles|O|O||D||1
25191726|Máquina perfeccionadora para automóviles|O|O||D||1
25191727|Alineador de varillas de conexión|O|O||D||1
25191728|Balanceador de cigüeñal|O|O||D||1|Balanceador de eje con engranaje
25191729|Pulidora de cigüeñal|O|O||D||1
25191730|Luz de toma de tiempos|O|O||D||1|Luz de sincronización
25191731|Limpiador de convertidor de torque|O|O||D||1
25191732|Perno roscado para pistón|O|O||D||1
25191733|Pulidora de pistones|O|O||D||1
25191734|Compresor de resorte de válvula|O|O||D||1|Compresor de muelles de válvula
25191735|Compresor de anillo de pistón|O|O||D||1
25191736|Simulador de conducción de vehículo|O|O||D||1
25191737|Inflador automático de llantas|O|O||D||1|Inflador automático de neumáticos
25191738|Abridor de llantas|O|O||D||1|Esparcidor de neumáticos
25191739|Tester de simulación de engranajes de dirección|O|O||D||1
25191740|Máquina para lavar vehículos|O|O||D||1|Lavadora de vehículos
25191741|Máquina para lavar trenes|O|O||D||1|Lavadora de ferrocarril
25191742|Máquina para lavar partes de vehículos|O|O||D||1|Lavadora de partes de vehículos
25191743|Máquina para lavar componentes de ferrocarril|O|O||D||1|Lavadora de componentes ferroviarios
25191800|Equipo de medición y prueba de vehículos|O|O||D||1
25191801|Probador de inducidos|O|O||D||1
25191802|Tacómetro de ángulo de contacto|O|O||D||1
25191803|Tester de humo diesel|O|O||D||1|Probador de humo diésel
25191804|Probador de radiador|O|O||D||1|Probador de presión del radiador
25191805|Probador de distribuidor de motor|O|O||D||1
25191806|Hidrómetro de batería|O|O||D||1
25191807|Detector de fugas de aceite de rodamiento|O|O||D||1
25191808|Probador de freno|O|O||D||1
25191809|Probador de ángulo de deslizamiento|O|O||D||1
25191810|Dinamómetro de chasis|O|O||D||1
25191811|Probador del velocímetro|O|O||D||1
25191812|Probador de bloqueo|O|O||D||1
25191813|Tester de brecha de bujías|O|O||D||1|Indicador de espacio entre bujías
25191814|Tester de bujías|O|O||D||1|Probador de bujías
25191815|Tester del inducido|O|O||D||1|Probador de armadura
25191816|Tester del resorte tipo compresión|O|O||D||1|Comprobador de muelles de compresión
25191817|Medidor de presión de la compresión|O|O||D||1
25191818|Tester del elemento limpiador de aire|O|O||D||1|Probador de elemento de filtro de aire
25191819|Tester de simulación de los frenos anti bloqueo abs|O|O||D||1|Sistema de frenado antibloqueo probador de simulación ABS
25191820|Multímetro de motor|O|O||D||1
25191821|Tester de simulador de motor|O|O||D||1|Probador de simulación de motor
25191822|Tester de inyector de motor|O|O||D||1|Probador del inyector del motor
25191823|Lecho de prueba de motor|O|O||D||1|Banco de prueba del motor
25191824|Probador de puesta a punto del motor|O|O||D||1
25191825|Medidor de consumo de combustible|O|O||D||1
25191826|Tester de fugas de aceite|O|O||D||1|Comprobador de fugas de aceite
25191827|Tester de simulación de suspensión de control electrónico ecs|O|O||D||1
25191828|Tester de transmisión automática|O|O||D||1|Probador de transmisión automática
25191829|Sistema de inspección de control electrónico|O|O||D||1
25191830|Tester de luz frontal|O|O||D||1|Probador de faros
25191831|Tester del regulador de ventanas del vehículo|O|O||D||1
25191832|Medidor de vacío para mantenimiento de vehículo|O|O||D||1|Válvula de vacío para servicio de vehículos
25191833|Medidor de avance del camber|O|O||D||1|Calibrador de caster
25191834|Tester de resistencia de bobina de condensación o ohm|O|O||D||1|Resistencia del condensador de bobina o ohm
25191835|Válvula de presión de ruedas|O|O||D||1
25191836|Medidor de convergencia de las ruedas delanteras|O|O||D||1
25191837|Medidor de radio de giro|O|O||D||1
25191838|Sistema de inspección de vehículos automotores|O|O||D||1
25201500|Fuselaje y componentes de avión|O|O||D||1
25201501|Spoilers de avión|O|O||D||1|Aerofrenos
25201502|Aletas de avión|O|O||D||1
25201503|Estabilizadores horizontales de avión|O|O||D||1
25201504|Aletas canard de avión|O|O||D||1
25201505|Listones de avión|O|O||D||1
25201506|Flaps o transmisión de flaps de avión|O|O||D||1|Aletas o transmisión de aletas de avión
25201507|Timones de avión|O|O||D||1|Timones de dirección
25201508|Elevadores de avión|O|O||D||1
25201509|Alerones de avión|O|O||D||1
25201510|Propulsores de avión|O|O||D||1
25201511|Alas de avión|O|O||D||1
25201512|Fuselajes de avión|O|O||D||1
25201513|Cúpulas protectoras de la antena de avión|O|O||D||1
25201514|Rotores de avión|O|O||D||1
25201515|Ventilador de elevación de avión|O|O||D||1
25201516|Escudetes de avión|O|O||D||1
25201517|Muebles de avión|O|O||D||1
25201518|Dobladores de avión|O|O||D||1
25201519|Nervaduras de avión|O|O||D||1
25201520|Largueros de avión|O|O||D||1
25201521|Aleta compensadora para aspa de hélice|O|O||D||1
25201522|Vaina universal de helicóptero|O|O||D||1
25201600|Sistemas de situación y navegación aeroespacial y componentes|O|O||D||1
25201601|Sistemas de control digital del altitud del avión|O|O||D||1
25201602|Faros de navegación de avión|O|O||D||1
25201603|Sistemas de seguimiento de aire a tierra|O|O||D||1
25201604|Sistemas de guía aeronáutica|O|O||D||1
25201605|Controles de volante de avión|O|O||D||1
25201606|Sistemas de control de la altitud del nave espacial|O|O||D||1
25201700|Sistemas relacionados con las comunicaciones de vuelo|O|O||D||1
25201701|Sistemas de comunicación del avión|O|O||D||1
25201702|Registradores de datos de vuelo|O|O||D||1|Caja negra
25201703|Contramedidas de avión|O|O||D||1|Contramedidas Infrarrojas
25201704|Sistemas de codificación o de decodificación|O|O||D||1
25201705|Sistemas de telemetría de aeronaves|O|O||D||1
25201706|Electrónica de interfaz del avión|O|O||D||1
25201707|Giroscopio del avión|O|O||D||1
25201708|Cámaras de avión|O|O||D||1
25201709|Sondas o sensores de avión|O|O||D||1
25201710|Guías de onda del avión|O|O||D||1
25201800|Sistemas de control principal del avión|O|O||D||1
25201801|Sistemas de computadores de vuelo|O|O||D||1
25201802|Módulos de comando de naves especiales|O|O||D||1
25201900|Sistemas de urgencia del avión|O|O||D||1
25201901|Sistemas de control o extinción de incendios en aeronaves|O|O||D||1
25201902|Sistemas de escape o eyección de aeronaves|O|O||D||1
25201903|Sistemas de advertencia del avión|O|O||D||1|Sistema de alerta de tráfico y evasión de colisión, Sistemas de aviso de aeronaves
25201904|Paracaídas|O|O||D||1
25202000|Sistemas de energía de avión|O|O||D||1
25202001|Células solares de la nave espacial|O|O||D||1|Celdas solares de la nave especial
25202002|Formaciones solares de la nave espacial|O|O||D||1
25202003|Unidades de la fuente de alimentación de avión|O|O||D||1|Unidades de suministro de energía para aviones
25202004|Sistemas de grupo electrógeno de pista (apu)|O|O||D||1|Sistemas de alimentación auxiliar APUs
25202100|Instrumentación de vuelo|O|O||D||1
25202101|Indicadores de la cabina aeroespacial|O|O||D||1
25202102|Medidores de la cabina aeroespacial|O|O||D||1|Medidores de la cabina de vuelo
25202103|Paneles de despliegue aeroespacial de la cabina|O|O||D||1
25202104|Paneles de interruptores aeroespaciales de la cabina|O|O||D||1
25202105|Presentación visual de cabeza levantada (hud)|O|O||D||1
25202200|Sistemas del aterrizaje y de frenos del avión|O|O||D||1
25202201|Sistemas de frenar del avión|O|O||D||1|Sistemas de frenado de aeronaves
25202202|Rampas de arrastre de avión|O|O||D||1|Carro de arrastre de avión, Remolcador de aviones
25202203|Ruedas de avión|O|O||D||1
25202204|Montajes del tren de aterrizaje|O|O||D||1
25202205|Llantas de avión|O|O||D||1|Neumáticos de avión
25202206|Controles anti – deslizamiento de avión|O|O||D||1
25202207|Contrafuerte del tren de aterrizaje|O|O||D||1|Brazo de arrastre del tren de aterrizaje, Estribo del tren de aterrizaje
25202300|Controles de pasajeros de avión|O|O||D||1
25202301|Cinturones de seguridad del avión|O|O||D||1
25202302|Arneses de seguridad del avión|O|O||D||1
25202400|Sistemas y depósitos de combustible del avión|O|O||D||1
25202401|Tanques interiores de combustible del avión|O|O||D||1|Depósitos de combustible interno de las aeronaves
25202402|Depósitos desechables de combustible del avión|O|O||D||1
25202403|Tanques de propelente del avión|O|O||D||1|Tanque propulsor de aeronaves
25202404|Sistemas híbridos de almacenaje de combustible de avión|O|O||D||1
25202405|Sistemas de manejo de combustible del avión|O|O||D||1
25202406|Post – impulsores|O|O||D||1|Sistema de propulsión
25202500|Equipo de avión|O|O||D||1
25202501|Sistemas hidráulicos de avión|O|O||D||1
25202502|Iluminación exterior de avión|O|O||D||1
25202503|Iluminación interior de avión|O|O||D||1
25202504|Limpiaparabrisas de avión|O|O||D||1
25202505|Sistemas de descongelación o sistemas de desempañar a bordo de avión|O|O||D||1
25202506|Puertas de avión|O|O||D||1
25202507|Ventanas de avión|O|O||D||1
25202508|Parabrisas de avión|O|O||D||1
25202509|Montajes de choque del avión|O|O||D||1|Soporte de choque para aeronaves
25202510|Conjuntos de anillo colector del avión|O|O||D||1|Anillo colector de avión
25202600|Sistemas y componentes del control ambiental del avión|O|O||D||1
25202601|Controladores ambientales del avión|O|O||D||1
25202602|Reguladores ambientales del avión|O|O||D||1
25202603|Turbinas para enfriar el avión|O|O||D||1|Turbinas de enfriamiento de aeronaves
25202604|Ventiladores para enfriar el avión|O|O||D||1|Ventiladores de enfriamiento de aeronaves
25202605|Intercambiadores de calor del avión|O|O||D||1
25202606|Separadores del agua del avión|O|O||D||1
25202607|Equipo del oxígeno del avión|O|O||D||1
25202700|Acumuladores del avión|O|O||D||1
25202701|Acumuladores hidráulicos del avión|O|O||D||1|Acumuladores hidráulicos de aeronaves
25202702|Acumuladores neumáticos del avión|O|O||D||1
26101100|Motores eléctricos de corriente alterna AC|O|O||D||1
26101101|Motor ac automotriz|O|O||D||1|Motor de corriente alterna para automóvil, Motor eléctrico de corriente alterna para automóvil
26101102|Motor ac de freno|O|O||D||1|Motor de corriente alterna de freno
26101103|Motor ac de trabajo de granja|O|O||D||1|Motor de corriente alterna de trabajo de granja
26101105|Motor ac de calefacción y enfriamiento|O|O||D||1|Motor de corriente alterna de calefacción y enfriamiento
26101106|Motor ac inversor|O|O||D||1|Motor de corriente alterna inversor
26101107|Motor ac de bomba|O|O||D||1|Motor de corriente alterna de bomba
26101108|Motor ac de compresor|O|O||D||1|Motor de corriente alterna de compresor
26101109|Motor ac sincrónico|O|O||D||1|Motor de corriente alterna sincrónico
26101110|Motor ac multi – velocidad|O|O||D||1|Motor de corriente alterna multi velocidad
26101111|Motor ac de de lavadora a presión|O|O||D||1|Motor de corriente alterna de lavado a presión
26101112|Motor ac de propósito general|O|O||D||1|Motor de corriente alterna de propósito general
26101113|Motor ac sumergible|O|O||D||1|Motor de corriente alterna sumergible
26101114|Motor ac de inducción|O|O||D||1|Motor de corriente alterna de inducción
26101115|Motor ac multi – fase|O|O||D||1|Motor de corriente alterna multi fase
26101116|Motor ac de fase sencilla|O|O||D||1|Motor de corriente alterna de fase sencilla
26101117|Motor ac de eje motriz|O|O||D||1|Motor de corriente alterna de eje motriz
26101200|Motores eléctricos de corriente directa DC|O|O||D||1
26101201|Motor dc en derivación|O|O||D||1|Motor de corriente directa en derivación
26101202|Motor dc de pasos|O|O||D||1|Motor de corriente directa de pasos
26101203|Motor dc sin núcleo|O|O||D||1|Motor de corriente directa sin núcleo
26101204|Motor dc con excitación en derivación|O|O||D||1|Motor de corriente directa con excitación en derivación
26101205|Servo motor dc|O|O||D||1|Servomotor de corriente directa
26101206|Motor dc de ángulo de torque limitado|O|O||D||1|Motor de corriente directa de ángulo de torque limitado
26101207|Motor dc linear|O|O||D||1|Motor de corriente directa linear
26101208|Motor dc de imán permanente|O|O||D||1|Motor de corriente directa de imán permanente
26101209|Motor dc sin escobillas|O|O||D||1|Motor de corriente directa sin escobillas
26101210|Motor dc de excitación compuesta|O|O||D||1|Motor de corriente directa de excitación compuesta
26101211|Motor ultrasónico o de vibración|O|O||D||1
26101212|Motor de huso|O|O||D||1
26101300|Motores no eléctricos|O|O||D||1
26101301|Motor de aire|O|O||D||1|Motor de arranque
26101302|Alternador|O|O||D||1
26101303|Dinamotor|O|O||D||1
26101304|Motor hidráulico|O|O||D||1
26101306|Motor de cohete líquido|O|O||D||1
26101309|Motor de cohete sólido|O|O||D||1
26101310|Motor de torque|O|O||D||1
26101311|Motor universal|O|O||D||1
26101312|Motor de pistón axial|O|O||D||1
26101313|Motor de pistón radial|O|O||D||1
26101400|Componentes de motores o generadores|O|O||D||1
26101401|Inducido|O|O||D||1|Bobina de arranque
26101402|Adaptador de base de motor|O|O||D||1
26101403|Freno de motor|O|O||D||1
26101404|Escobilla de motor|O|O||D||1
26101405|Bobina de motor|O|O||D||1
26101406|Montura o base de motor|O|O||D||1
26101408|Poste de motor|O|O||D||1
26101409|Rotor de motor|O|O||D||1
26101410|Estator de motor|O|O||D||1
26101411|Laminación de motor|O|O||D||1
26101412|Kit de reparación de motor|O|O||D||1
26101413|Carcasa de motor|O|O||D||1
26101414|Transportador de escobillas de motor|O|O||D||1
26101415|Conmutador de motor|O|O||D||1
26101500|Motores|O|O||D||1
26101501|Motores hidráulicos|O|O||D||1
26101502|Motores neumáticos|O|O||D||1
26101503|Motores a gas|O|O||D||1
26101504|Motores diesel|O|O||D||1
26101505|Motores de vapor|O|O||D||1
26101506|Motores de turbina|O|O||D||1
26101507|Motores de turbina con hélice|O|O||D||1
26101508|Motores térmicos|O|O||D||1
26101509|Motores hidroeléctricos|O|O||D||1
26101510|Máquinas rotativas|O|O||D||1
26101511|Motores de turbina hidráulica|O|O||D||1
26101512|Motores turbohélice|O|O||D||1
26101513|Kit de reparación de motores|O|O||D||1
26101514|Motor de jet|O|O||D||1
26101515|Motor fuera de borda a gasolina|O|O||D||1
26101700|Accesorios y componentes de motor|O|O||D||1
26101701|Quemadores para aeronaves|O|O||D||1
26101702|Compresores de motor de avión|O|O||D||1|Compresores de motores de aeronaves
26101703|Difusores de motor de avión|O|O||D||1
26101704|Monturas de motor|O|O||D||1|Soportes del motor
26101705|Gatos de tornillo de los ejes motores del avión|O|O||D||1
26101706|Unidades de transmisión del avión|O|O||D||1
26101707|Ejes compensadores|O|O||D||1
26101708|Seguidores de la leva|O|O||D||1
26101709|Elevadores de árbol de levas|O|O||D||1
26101710|Carburadores|O|O||D||1
26101711|Bielas|O|O||D||1
26101712|Válvulas de ventilación del cárter|O|O||D||1
26101713|Culata de cilindro|O|O||D||1|Tapa del cilindro
26101715|Tapas de motor|O|O||D||1
26101716|Forjas del motor|O|O||D||1
26101717|Calentadores de motor|O|O||D||1
26101718|Sistemas de ignición de motor|O|O||D||1
26101719|Súper cargadores|O|O||D||1
26101720|Turbocargador|O|O||D||1
26101721|Poleas del motor|O|O||D||1
26101723|Lata de vapor de combustible|O|O||D||1
26101724|Tapón brillante|O|O||D||1
26101725|Medidores de varilla de aceite|O|O||D||1|Bayoneta para medir aceite, Varilla del nivel de aceite
26101726|Coladores de aceite|O|O||D||1|Filtros de aceite
26101727|Anillo de pistón|O|O||D||1
26101728|Tubos de varilla de empuje|O|O||D||1
26101729|Bolas de brazo oscilante|O|O||D||1|Brazo oscilante articulación de bolas buje
26101730|Ejes de brazo oscilante|O|O||D||1|Soporte suspensión
26101731|Brazos oscilantes|O|O||D||1
26101732|Bujía de encendido|O|O||D||1
26101733|Chorro de carburador|O|O||D||1
26101734|Diafragmas de carburador|O|O||D||1
26101735|Batea de aceite|O|O||D||1|Bandeja recolectora de aceite, Colector de aceite
26101736|Pistones|O|O||D||1
26101737|Cadena de distribución|O|O||D||1
26101738|Múltiples de entrada|O|O||D||1
26101740|Inyectores de combustible|O|O||D||1
26101741|Manguitos de motor|O|O||D||1|Mangueras de calefacción para motor
26101742|Distribuidores de inyección de combustible|O|O||D||1
26101743|Válvulas de motor|O|O||D||1
26101747|Varas de empuje|O|O||D||1
26101748|Volante de inercia del motor|O|O||D||1
26101749|Cigüeñal|O|O||D||1
26101750|Válvula de estrangulación|O|O||D||1
26101751|Controles electrónicos de motor|O|O||D||1
26101754|Asiento de válvula del motor|O|O||D||1
26101755|Guía de válvula|O|O||D||1
26101756|Adaptadores del carburador|O|O||D||1
26101757|Accesorios de las bujías|O|O||D||1
26101758|Ajustadores del balancín|O|O||D||1
26101759|Adaptadores del motor de arranque|O|O||D||1
26101760|Vástagos del estárter|O|O||D||1
26101761|Tapones del árbol de levas|O|O||D||1
26101762|Varillaje de los componentes del motor|O|O||D||1
26101763|Tapones del anticongelante|O|O||D||1
26101764|Revestimiento de los cilindros|O|O||D||1
26101765|Amortiguadores de vibración|O|O||D||1
26101766|Reguladores|O|O||D||1
26101767|Estator de turbina|O|O||D||1
26101768|Eje de turbina|O|O||D||1
26101769|Bobina de ignición|O|O||D||1
26101770|Control electrónico de motor para motores a gasolina|O|O||D||1|Control electrónico de motor a gasolina
26101771|Control electrónico de motor para motores diesel|O|O||D||1|Control electrónico de motor diésel
26101772|Limpiador de inyector|O|O||D||1
26101773|Válvula de medición proporcional diesel|O|O||D||1|Válvula dosificadora proporcional diésel
26101774|Válvula solenoide ara purgar lata|O|O||D||1|Válvula solenoide de purga de cárter
26101775|Válvula de alta presión diesel|O|O||D||1
26101776|Bobina del inmovilizador|O|O||D||1
26101777|Bobina del inyector de combustible gasolina|O|O||D||1
26101778|Bobina del inyector de combustible diesel|O|O||D||1
26101779|Arnés pasacables para cableado|O|O||D||1|Arnés de cableado
26101780|Inyector de aceite o válvula de medición|O|O||D||1
26101781|Pasador de pistón|O|O||D||1
26101782|Distribuidor de ignición|O|O||D||1
26101783|Unión de husillos hidráulicos|O|O||D||1
26101784|Araña del diferencial|O|O||D||1
26101785|Elemento colador de aceite|O|O||D||1|Colador de aceite
26101786|Alza válvulas|O|O||D||1|Varilla levanta válvulas
26101787|Válvula y bastidor de admisión|O|O||D||1
26101900|Componentes de motor de combustión interna|O|O||D||1
26101903|Árbol de distribución|O|O||D||1
26101904|Boquilla de inyección de combustible|O|O||D||1
26101905|Bloque de cilindros|O|O||D||1
26111500|Transmisión de energía cinética|O|O||D||1
26111503|Dispositivos de velocidad regulables|O|O||D||1
26111504|Correas de la transmisión|O|O||D||1|Bandas de transmisión
26111505|Cadenas de la transmisión|O|O||D||1
26111506|Aparatos de movimiento rectilíneo|O|O||D||1
26111508|Despegues de energía|O|O||D||1
26111509|Culatas de transmisión|O|O||D||1
26111510|Árboles de transmisión|O|O||D||1
26111512|Ejes|O|O||D||1
26111513|Cadenas transmisoras de potencia|O|O||D||1
26111514|Uniones de charnela|O|O||D||1|Uniones para codos
26111515|Servo controlador|O|O||D||1
26111516|Transmisión escalonada o transmisión stepper o graduador escalonado|O|O||D||1
26111517|Portaengranajes|O|O||D||1
26111518|Puntal tensor|O|O||D||1
26111519|Convertidores de torque|O|O||D||1
26111520|Muñones|O|O||D||1
26111521|Cabeza del impulsor|O|O||D||1
26111522|Conjunto del impulsor|O|O||D||1
26111523|Topes de retención|O|O||D||1
26111524|Unidades de engranajes|O|O||D||1
26111525|Transmisiones de tambor|O|O||D||1
26111527|Sistemas de control de movimiento integrados|O|O||D||1
26111528|Transmisiones hidrostáticas|O|O||D||1
26111529|Transmisiones hidrocinéticas|O|O||D||1
26111530|Leva de transmisión|O|O||D||1
26111531|Manguitos de la transmisión|O|O||D||1
26111532|Soportes o conjuntos del eje|O|O||D||1
26111533|Tensores de cadena|O|O||D||1
26111534|Cubos de la transmisión|O|O||D||1
26111535|Tornillos esféricos o conjuntos de tornillos esféricos|O|O||D||1
26111536|Reductor de velocidad montado sobre eje|O|O||D||1
26111537|Reductor de velocidad con tornillo|O|O||D||1
26111538|Reductor de velocidad de hélice|O|O||D||1
26111539|Reductor de velocidad de hélice y tornillo|O|O||D||1
26111540|Reductor de velocidad planetario|O|O||D||1
26111541|Reductor de velocidad cicloidal|O|O||D||1
26111542|Reductor aumentador de velocidad de bisel|O|O||D||1
26111543|Reductor de velocidad de tracción|O|O||D||1
26111544|Controlador de velocidad|O|O||D||1
26111545|Adaptador de freno de tambor|O|O||D||1
26111546|Disco de turbina|O|O||D||1
26111547|Cubo de apriete|O|O||D||1
26111548|Palanca de cambios|O|O||D||1
26111549|Escalón del eje|O|O||D||1
26111600|Generadores de potencia|O|O||D||1
26111601|Generadores diesel|O|O||D||1
26111602|Generadores hidroeléctricos|O|O||D||1
26111603|Generadores eólicos|O|O||D||1
26111604|Generadores a gas|O|O||D||1
26111605|Generadores térmicos|O|O||D||1
26111606|Generadores hidráulicos|O|O||D||1
26111607|Generadores solares|O|O||D||1
26111608|Generadores de vapor|O|O||D||1
26111609|Generador de turbina de gas|O|O||D||1
26111610|Generador selsyn|O|O||D||1
26111611|Generador auxiliar|O|O||D||1
26111612|Generador de impulso|O|O||D||1
26111613|Generador de marea|O|O||D||1
26111700|Baterías, pilas y accesorios|O|O||D||1
26111701|Baterías recargables|O|O||D||1|Pilas recacrgables
26111702|Pilas alcalinas|O|O||D||1|Baterías alcalinas
26111703|Baterías para vehículos|O|O||D||1
26111704|Cargadores de baterías|O|O||D||1|Cargadores de pilas
26111705|Pilas secas|O|O||D||1
26111706|Pilas electrónicas|O|O||D||1
26111707|Baterías de plomo-ácido|O|O||D||1
26111708|Baterías de ferroníquel|O|O||D||1
26111709|Baterías de níquel-cadmio|O|O||D||1
26111710|Bloques de pilas específicas para productos|O|O||D||1
26111711|Baterías de litio|O|O||D||1
26111712|Baterías de níquel- hidrógeno|O|O||D||1
26111713|Baterías térmicas|O|O||D||1
26111714|Zinc aire|O|O||D||1|Batería mecánicamente recargables, Batería no recargable
26111715|Batería de carbono zinc|O|O||D||1
26111716|Batería de oxido de mercurio|O|O||D||1
26111717|Baterías del manganeso|O|O||D||1
26111718|Baterías de óxido de plata|O|O||D||1|Pila de plata
26111719|Probadores de baterías|O|O||D||1|Probadores de pilas
26111720|Soportes de batería|O|O||D||1|Soportes de pilas
26111721|Baterías de níquel-hidruro metálico|O|O||D||1
26111722|Adaptador de batería o accesorios|O|O||D||1|Adaptador de pilas o accesorios
26111723|Puertas, tapas o estantes de baterías|O|O||D||1|Tapas o cajas para pilas
26111724|Kits de herramientas para baterías|O|O||D||1
26111725|Baterías de níquel-cloruro de sodio|O|O||D||1
26111726|Unidad de balasto de batería fluorescente|O|O||D||1
26111727|Descargador de baterías|O|O||D||1|Descargador de pilas
26111728|Celda estándar|O|O||D||1
26111729|Unidad de cargador de batería de auto|O|O||D||1|Unidad de carga automática de la batería
26111800|Componentes de la transmisión|O|O||D||1
26111801|Correas en v|O|O||D||1|Accionamientos de correa en v, Bandas en v
26111802|Correas de distribución de engranaje|O|O||D||1
26111803|Correas redondas|O|O||D||1
26111804|Correas planas|O|O||D||1
26111805|Tensores de correa|O|O||D||1
26111806|Poleas de transmisión|O|O||D||1
26111807|Polea de distribución|O|O||D||1
26111808|Trantorque|O|O||D||1
26111809|Defensas de correa|O|O||D||1
26111810|Bridas de la polea de distribución|O|O||D||1
26111811|Banda sincrónica|O|O||D||1
26111812|Polea sincrónica|O|O||D||1
26111813|Polea de velocidad variable|O|O||D||1
26111814|Banda hexagonal|O|O||D||1
26111815|Polea de cono|O|O||D||1
26111816|Polea plana|O|O||D||1
26111900|Embragues|O|O||D||1
26111901|Embragues de placa|O|O||D||1|Clutch
26111902|Embragues de diafragma|O|O||D||1
26111903|Embrague centrífugo|O|O||D||1
26111904|Embrague semi centrífugo|O|O||D||1
26111905|Embrague de rueda libre|O|O||D||1
26111907|Acoplamiento de fluido|O|O||D||1
26111908|Embragues de leva|O|O||D||1
26111909|Embragues eléctricos|O|O||D||1
26111910|Embragues hidráulicos|O|O||D||1
26111911|Embrague neumático|O|O||D||1
26111912|Embrague mecánico|O|O||D||1
26111913|Unidad de detención de embrague|O|O||D||1
26111914|Embrague de mandíbula|O|O||D||1
26111915|Embrague automático|O|O||D||1
26111916|Embrague semi automático|O|O||D||1
26111917|Embrague electromagnético|O|O||D||1
26112000|Piezas y accesorios de embragues|O|O||D||1
26112001|Placa de presión|O|O||D||1
26112002|Placa impulsada|O|O||D||1
26112003|Placas de embrague|O|O||D||1
26112004|Kits de reparación del embrague|O|O||D||1|Paquete de reparación de embrague
26112100|Sistemas de frenado industriales|O|O||D||1
26112101|Sistemas de frenos neumáticos o de aire|O|O||D||1
26112102|Sistemas de frenos hidráulicos|O|O||D||1
26112103|Sistemas de frenos mecánicos|O|O||D||1
26112104|Conjuntos de embrague de frenado|O|O||D||1
26112105|Sistemas de frenado eléctrico|O|O||D||1
26121500|Alambre eléctrico|O|O||D||1
26121501|Alambre calentador|O|O||D||1
26121505|Alambre para artefactos|O|O||D||1
26121507|Alambre para radio o televisión|O|O||D||1
26121508|Alambre para automoción o aviación|O|O||D||1
26121509|Alambre para imanes|O|O||D||1
26121510|Alambre de trole|O|O||D||1
26121514|Alambre subterráneo|O|O||D||1
26121515|Alambre de silicio-amianto (sa)|O|O||D||1
26121517|Hilo de cobre|O|O||D||1
26121519|Alambre de aluminio revestido de cobre|O|O||D||1
26121520|Alambre de cobre-acero|O|O||D||1
26121521|Alambre de bronce|O|O||D||1
26121522|Alambre pelado|O|O||D||1
26121523|Alambre forrado pero no aislado|O|O||D||1
26121524|Alambre aislado o forrado|O|O||D||1
26121532|Alambre para interconexiones|O|O||D||1
26121533|Alambre de kaptan|O|O||D||1
26121534|Alambre de poliamida|O|O||D||1
26121536|Cordón de extensión|O|O||D||1
26121538|Conjunto de cable|O|O||D||1
26121539|Cables para cableado|O|O||D||1
26121540|Cable galvanizado|O|O||D||1|Alambre galvanizado
26121541|Conductores de bus|O|O||D||1
26121542|Cable de instalación|O|O||D||1
26121543|Cable resistente al calor|O|O||D||1
26121544|Cable de bajada|O|O||D||1
26121545|Cable portátil eléctrico|O|O||D||1
26121546|Cable de cobre recubierto de estaño|O|O||D||1
26121547|Cable de bronce|O|O||D||1
26121548|Cable rectangular|O|O||D||1
26121600|Cables eléctricos y accesorios|O|O||D||1
26121601|Cable de calentamiento|O|O||D||1
26121602|Cable submarino|O|O||D||1
26121603|Cable de mando|O|O||D||1
26121604|Cable para señales|O|O||D||1|Cable HDMI
26121606|Cable coaxial|O|O||D||1
26121607|Cable de fibra óptica|O|O||D||1
26121608|Cable aéreo|O|O||D||1
26121609|Cable de redes|O|O||D||1
26121610|Cable de bronce|O|O||D||1
26121611|Cable desnudo|O|O||D||1
26121612|Cable forrado pero no aislado|O|O||D||1
26121613|Cable aislado o forrado|O|O||D||1
26121614|Cable de construcción|O|O||D||1
26121615|Cable para ser enterrado de forma directa|O|O||D||1
26121616|Cable de telecomunicaciones|O|O||D||1
26121617|Cable triaxial|O|O||D||1
26121618|Cable de poliqueno reticulado|O|O||D||1
26121619|Cable de floropolímero|O|O||D||1
26121620|Cable para interconexiones|O|O||D||1
26121621|Cable de kaptan|O|O||D||1
26121622|Cable de poliamida|O|O||D||1
26121623|Cable de radiofrecuencia (rf)|O|O||D||1
26121624|Cable plano o de cinta|O|O||D||1
26121628|Cables blindados|O|O||D||1
26121629|Cable de alimentación|O|O||D||1
26121630|Accesorios de cable|O|O||D||1
26121631|Cable coaxial exterior de planta|O|O||D||1
26121632|Cable de comunicaciones exterior de planta|O|O||D||1|Cable de planta exterior
26121633|Cable de telecomunicaciones exterior de planta|O|O||D||1|Cable de planta exterior
26121634|Cable de cobre|O|O||D||1
26121635|Rollos de cable|O|O||D||1
26121636|Cables de alimentación|O|O||D||1
26121637|Cable de fibra óptica de exterior|O|O||D||1
26121638|Materiales de engaste|O|O||D||1
26121639|Multi – cables combinados o a la medida|O|O||D||1
26121640|Cables resistentes al calor|O|O||D||1
26121641|Cables de instalación|O|O||D||1
26121642|Cable de instrumentación|O|O||D||1
26121643|Cable eléctrico reforzado de acero desnudo|O|O||D||1
26121644|Cable eléctrico de aluminio desnudo|O|O||D||1
26121645|Cable eléctrico de cobre desnudo|O|O||D||1
26121646|Cable de seguimiento y máquina de minería|O|O||D||1
26121647|Ensamble de cable de seguimiento y máquina de minería|O|O||D||1
26121648|Kit de terminación de cable de alto voltaje|O|O||D||1|Paquete de terminación de cable de alto voltaje
26121649|Kit de unión de cable de alto voltaje|O|O||D||1|Paquete de unión de cables de alta tensión
26121650|Conjunto de cable de fibra óptica|O|O||D||1
26121651|Cable so resistente al aceite|O|O||D||1
26121652|Conjunto de cordón eléctrico|O|O||D||1
26121653|Cable toll|O|O||D||1
26121654|Cable de frecuencia de carrier|O|O||D||1
26121655|Cable de fibra óptica simplex y dúplex|O|O||D||1
26121656|Cable de fibra óptica submarina|O|O||D||1
26121657|Cable de fibra óptica retardante de fuego|O|O||D||1
26121658|Cable de transmisión de aluminio conductor resistente al movimiento|O|O||D||1
26121659|Cable de bajada de servicio cuádruple de aluminio conductor|O|O||D||1
26121660|Cable de bajada de servicio dúplex de aluminio conductor|O|O||D||1
26121661|Cable de aluminio conductor subterráneo de entrada de servicio|O|O||D||1
26121662|Cable de aluminio conductor de entrada de servicio|O|O||D||1
26121663|Cable sencillo de aluminio conductor de servicio|O|O||D||1
26121664|Alambre de aluminio conductor recubierto de polietileno|O|O||D||1
26121665|Cable de aluminio de bajada de servicio triple|O|O||D||1
26121666|Conjunto de cable de comunicación|O|O||D||1
26121700|Cableado preformado|O|O||D||1
26121701|Cableado preformado de panel|O|O||D||1
26121702|Cableado preformado troncal|O|O||D||1
26121703|Cableado preformado de comunicación|O|O||D||1
26121704|Arnés de alambrado especial|O|O||D||1
26121706|Conjunto coaxial|O|O||D||1
26121707|Conjunto de cable plano flexible|O|O||D||1
26121708|Conjunto de cable de batería|O|O||D||1
26121709|Conjunto de cordón embobinado|O|O||D||1
26121710|Arnés de cableado sensor oxígeno|O|O||D||1|Arnés cableado de sensor de oxigeno
26121711|Varilla de pistón|O|O||D||1
26121800|Cable automotriz|O|O||D||1
26121802|Cable automotriz de núcleo sencillo de 60 voltios clase a|O|O||D||1
26121803|Cable automotriz de núcleo sencillo de 60 voltios clase b|O|O||D||1
26121804|Cable automotriz de núcleo sencillo de 60 voltios clase c|O|O||D||1
26121805|Cable automotriz de núcleo sencillo de 60 voltios clase d|O|O||D||1
26121806|Cable automotriz de núcleo sencillo de 60 voltios clase e|O|O||D||1
26121807|Cable automotriz de núcleo sencillo de 60 voltios clase f|O|O||D||1
26121808|Cable automotriz de núcleo sencillo de 60 voltios clase g|O|O||D||1
26121809|Cable automotriz de núcleo sencillo de 60 voltios clase h|O|O||D||1
26121810|Cable automotriz de núcleo sencillo de 600 voltios clase a|O|O||D||1
26121811|Cable automotriz de núcleo sencillo de 600 voltios clase b|O|O||D||1
26121812|Cable automotriz de núcleo sencillo de 600 voltios clase c|O|O||D||1
26121813|Cable automotriz de núcleo sencillo de 600 voltios clase d|O|O||D||1
26121814|Cable automotriz de núcleo sencillo de 600 voltios clase e|O|O||D||1
26121815|Cable automotriz de núcleo sencillo de 600 voltios clase f|O|O||D||1
26121816|Cable automotriz de núcleo sencillo de 600 voltios clase g|O|O||D||1
26121817|Cable automotriz de núcleo sencillo de 600 voltios clase h|O|O||D||1
26121818|Cable automotriz de núcleo múltiple de 60 voltios clase a|O|O||D||1
26121819|Cable automotriz de núcleo múltiple de 60 voltios clase b|O|O||D||1
26121820|Cable automotriz de núcleo múltiple de 60 voltios clase c|O|O||D||1
26121821|Cable automotriz de núcleo múltiple de 60 voltios clase d|O|O||D||1
26121822|Cable automotriz de núcleo múltiple de 60 voltios clase e|O|O||D||1
26121823|Cable automotriz de núcleo múltiple de 60 voltios clase f|O|O||D||1
26121824|Cable automotriz de núcleo múltiple de 60 voltios clase g|O|O||D||1
26121825|Cable automotriz de núcleo múltiple de 60 voltios clase h|O|O||D||1
26121826|Cable automotriz de núcleo múltiple de 600 voltios clase a|O|O||D||1
26121827|Cable automotriz de núcleo múltiple de 600 voltios clase b|O|O||D||1
26121828|Cable automotriz de núcleo múltiple de 600 voltios clase c|O|O||D||1
26121829|Cable automotriz de núcleo múltiple de 600 voltios clase d|O|O||D||1
26121830|Cable automotriz de núcleo múltiple de 600 voltios clase e|O|O||D||1
26121831|Cable automotriz de núcleo múltiple de 600 voltios clase f|O|O||D||1
26121832|Cable automotriz de núcleo múltiple de 600 voltios clase g|O|O||D||1
26121833|Cable automotriz de núcleo múltiple de 600 voltios clase h|O|O||D||1
26121834|Cable automotriz trenzado de 60 voltios clase a|O|O||D||1
26121835|Cable automotriz trenzado de 60 voltios clase b|O|O||D||1
26121836|Cable automotriz trenzado de 60 voltios clase c|O|O||D||1
26121837|Cable automotriz trenzado de 60 voltios clase d|O|O||D||1
26121838|Cable automotriz trenzado de 60 voltios clase e|O|O||D||1
26121839|Cable automotriz trenzado de 60 voltios clase f|O|O||D||1
26121840|Cable automotriz trenzado de 60 voltios clase g|O|O||D||1
26121841|Cable automotriz trenzado de 60 voltios clase h|O|O||D||1
26121842|Cable automotriz trenzado de 600 voltios clase a|O|O||D||1
26121843|Cable automotriz trenzado de 600 voltios clase b|O|O||D||1
26121844|Cable automotriz trenzado de 600 voltios clase c|O|O||D||1
26121845|Cable automotriz trenzado de 600 voltios clase d|O|O||D||1
26121846|Cable automotriz trenzado de 600 voltios clase e|O|O||D||1
26121847|Cable automotriz trenzado de 600 voltios clase f|O|O||D||1
26121848|Cable automotriz trenzado de 600 voltios clase g|O|O||D||1
26121849|Cable automotriz trenzado de 600 voltios clase h|O|O||D||1
26121850|Cable automotriz de núcleo múltiple seleccionado de 60 voltios|O|O||D||1
26121851|Cable automotriz de núcleo múltiple seleccionado de 600 voltios|O|O||D||1
26121852|Cable automotriz de núcleo de ignición|O|O||D||1|Cable de encendido de automóvil
26131500|Centrales eléctricas|O|O||D||1
26131501|Centrales eléctricas de diesel|O|O||D||1
26131502|Centrales eléctricas geotérmicas|O|O||D||1
26131503|Centrales hidroeléctricas|O|O||D||1
26131504|Centrales de gas|O|O||D||1
26131505|Centrales de energía  marina|O|O||D||1
26131506|Centrales de energía a petróleo|O|O||D||1
26131507|Centrales de energía solar|O|O||D||1
26131508|Centrales termoeléctricas|O|O||D||1
26131509|Central de energía eólica|O|O||D||1
26131510|Central térmica|O|O||D||1
26131600|Equipo de cribado o estructuras de tubo de escape|O|O||D||1
26131601|Pantallas de agua móviles|O|O||D||1
26131602|Travesaños corredizos|O|O||D||1
26131603|Rejillas de agua|O|O||D||1
26131604|Filtros fijos|O|O||D||1
26131605|Estructuras de toma|O|O||D||1
26131606|Chimenea de acero|O|O||D||1
26131607|Chimenea de concreto|O|O||D||1
26131608|Chimeneas de ventilación o antorchas|O|O||D||1
26131609|Chimeneas de admisión|O|O||D||1|Pilas de admisión de escape
26131610|Chimeneas de derivación|O|O||D||1
26131611|Secciones de silenciador|O|O||D||1
26131612|Conductos de salida de escape|O|O||D||1
26131613|Juntas de dilatación de conductos de escape|O|O||D||1|Juntas de dilatación de escape
26131614|Amortiguadores de cierre de la chimenea|O|O||D||1
26131615|Amortiguadores de desviación de escape|O|O||D||1
26131616|Amortiguadores de aislamiento de escape|O|O||D||1
26131617|Amortiguador de veleta|O|O||D||1
26131618|Amortiguador de cabezal|O|O||D||1
26131700|Equipo de detección o vigilancia de producción de energía|O|O||D||1
26131701|Detectores de gases inflamables o peligrosos para generadores|O|O||D||1
26131702|Detectores de llama de sistemas de combustión de turbina de gas|O|O||D||1
26131800|Equipo de control de producción de energía|O|O||D||1
26131801|Paneles de control eléctrico para generadores|O|O||D||1
26131802|Paneles de control de compresores|O|O||D||1
26131803|Paneles de protección o control de generadores|O|O||D||1
26131804|Paneles de control de turbina de gas|O|O||D||1
26131807|Paneles de control de turbinas de vapor|O|O||D||1
26131808|Conmutadores de control de carga de subestación|O|O||D||1
26131811|Reactores de limitación de intensidad|O|O||D||1
26131812|Conmutadores con aislamiento de gas|O|O||D||1
26131813|Conmutadores de desconexión de estaciones de maniobra|O|O||D||1
26131814|Disipador de sobretensiones de estaciones de maniobra|O|O||D||1|Pararrayos de interruptor
26141600|Equipo para ensamblaje subcrítico|O|O||D||1
26141601|Combustible para conjunto subcrítico|O|O||D||1
26141602|Componentes para conjunto subcrítico|O|O||D||1
26141603|Moderador para conjunto subcrítico|O|O||D||1|Moderador de montaje subcrítico
26141700|Equipo para dosimetría|O|O||D||1
26141701|Dosímetros de cámara de ionización|O|O||D||1
26141702|Dosímetros|O|O||D||1
26141703|Sistemas de dosimetría de patrón secundario|O|O||D||1
26141704|Dosímetros fantasma|O|O||D||1
26141800|Aparatos para celda caliente|O|O||D||1
26141801|Equipo teledirigido para recintos radiactivos|O|O||D||1
26141802|Aparato de visión teledirigido para recintos radiactivos|O|O||D||1
26141803|Puertas de blindaje para recintos radiactivos|O|O||D||1
26141804|Toma muestras para recintos radiactivos|O|O||D||1
26141805|Material de elaboración de muestras para recintos radiactivos|O|O||D||1
26141806|Herramientas especiales para recintos radiactivos|O|O||D||1
26141807|Ventanas de vidrio de plomo para recintos radiactivos|O|O||D||1
26141808|Sistemas de descontaminación para recintos radiactivos|O|O||D||1
26141809|Aparatos de penetración para recintos radiactivos|O|O||D||1
26141900|Instrumentos nucleónicos industriales|O|O||D||1
26141901|Sistemas nucleónicos industriales de medida de polvo en el aire|O|O||D||1|Sistemas de medición de polvo nuclear industrial
26141902|Sistemas nucleónicos industriales de medida de la densidad|O|O||D||1
26141904|Indicadores de nivel de líquido nucleónico industrial|O|O||D||1
26141905|Sistemas de medida de masa nucleónica industrial por unidad de mineral|O|O||D||1
26141906|Sistemas de medida de la humedad industrial nucleónica|O|O||D||1
26141907|Sistemas de medida el espesor industrial nucleónico|O|O||D||1
26141908|Sistemas de medida del flujo industrial nucleónico|O|O||D||1
26141909|Separadores de isótopos|O|O||D||1
26141910|Instalaciones de producción de isótopos|O|O||D||1
26141911|Medidores de actividad del calibrador de isótopos|O|O||D||1
26142000|Equipo de irradiación|O|O||D||1
26142001|Fuentes de irradiación gamma|O|O||D||1
26142002|Sistemas de imanes|O|O||D||1
26142003|Unidades electrónicas nucleares nim|O|O||D||1
26142004|Irradiadores de neutrones|O|O||D||1
26142005|Cápsulas para ensayos de irradiación|O|O||D||1
26142006|Sistema de transferencia de muestras de irradiación|O|O||D||1
26142007|Generadores de neutrones|O|O||D||1
26142100|Equipos para reactores nucleares|O|O||D||1
26142101|Recipientes de irradiación de especímenes para reactores nucleares|O|O||D||1
26142106|Sistemas de varilla de mando para reactores nucleares|O|O||D||1
26142108|Instrumentación de flujo de neutrones incorporada al núcleo para reactores nucleares|O|O||D||1
26142117|Instrumentación de terremotos para reactores nucleares|O|O||D||1
26142200|Equipo para combustible nuclear|O|O||D||1
26142201|Tubos con revestimiento para combustible nuclear|O|O||D||1
26142202|Sistemas de detección de fallo de elementos para reactores nucleares|O|O||D||1
26142300|Equipos protectores contra la radiación|O|O||D||1
26142302|Blindajes de plomo|O|O||D||1
26142303|Distintivo de película|O|O||D||1
26142304|Equipo radiográfico|O|O||D||1
26142306|Recipientes blindados contra la radiación|O|O||D||1
26142307|Cámaras de plomo para protección contra la radiación|O|O||D||1
26142308|Ladrillos de plomo para protección contra la radiación|O|O||D||1
26142310|Cajas selladas con guantes para protección contra la radiación|O|O||D||1
26142311|Ventanas para blindaje contra la radiación|O|O||D||1
26142312|Plomo para blindaje contra la radiación|O|O||D||1
26142400|Equipo para residuos radiactivos|O|O||D||1
26142401|Compactadores o incineradores para el tratamiento de residuos radiactivos|O|O||D||1
26142402|Absorbentes de radiaciones nucleares|O|O||D||1|Absorbentes de radiación nuclear
26142403|Evaporadores, concentradores o secadores de energía atómica|O|O||D||1
26142404|Sistemas de inter - bloqueo de las puertas|O|O||D||1|Sistema de bloqueo de puertas
26142405|Sistemas de dosificación de residuos radiactivos|O|O||D||1
26142406|Sistemas de solidificación de residuos radiactivos|O|O||D||1
26142407|Sistemas de eliminación de residuos radiactivos|O|O||D||1
26142408|Instalaciones para el tratamiento de residuos radiactivos|O|O||D||1
27111500|Herramientas de corte y engarzado y punzones|O|O||D||1
27111501|Hojas de cuchillo|O|O||D||1
27111502|Navajas de afeitar|O|O||D||1
27111503|Cuchillos de diversas aplicaciones|O|O||D||1|Cuchillos para uso general
27111504|Navajas de bolsillo|O|O||D||1
27111505|Sets para manicure|O|O||D||1|Estuche de manicure
27111506|Cizallas|O|O||D||1
27111507|Cortadores de metal|O|O||D||1|Cúter o cutter
27111508|Sierras|O|O||D||1
27111509|Barrenas|O|O||D||1
27111510|Herramientas para desforrar|O|O||D||1|Herramienta para cortar
27111511|Cortadores de alambres|O|O||D||1|Pinzas de cortar alambre
27111512|Cortadores de pernos|O|O||D||1|Pinzas cortadoras de pernos
27111513|Cortadores de manguera|O|O||D||1
27111514|Cortadores de vidrio|O|O||D||1
27111515|Taladro de mano|O|O||D||1
27111516|Alicates de perforación|O|O||D||1|Perforadora
27111517|Dispensadores o juegos de hojas de cuchilla|O|O||D||1
27111518|Herramienta para engastar y doblar alambre|O|O||D||1
27111519|Tijeras para estaño|O|O||D||1
27111520|Rompetuercas|O|O||D||1
27111521|Recortadoras de chapa de uña vibratoria|O|O||D||1
27111522|Herramienta para aboquillar o ensanchar|O|O||D||1
27111523|Raspador de vidrio|O|O||D||1
27111524|Cortadora de ribetes|O|O||D||1|Cortadora de rollos
27111525|Tenazas|O|O||D||1
27111526|Herramienta para quitar rebabas|O|O||D||1
27111527|Cortador de tacos|O|O||D||1
27111529|Tijeras aisladas|O|O||D||1
27111530|Tijeras de pescador|O|O||D||1
27111531|Tijeras para el pelo|O|O||D||1|Tijeras para el cabello
27111532|Tijeras de joyería|O|O||D||1
27111533|Tijeras de carnicero|O|O||D||1
27111534|Compás de corte|O|O||D||1
27111535|Tijeras de alambre|O|O||D||1
27111536|Cortador de círculos|O|O||D||1
27111537|Broca para madera|O|O||D||1
27111538|Broca forstner|O|O||D||1
27111539|Broca para madera plana|O|O||D||1
27111540|Broca para baldosa|O|O||D||1
27111541|Punta guía de bola|O|O||D||1
27111542|Broca de punto de espuela|O|O||D||1
27111543|Broca de mampostería|O|O||D||1
27111544|Sierra de hender|O|O||D||1|Serrucho de Hender
27111545|Sierra de hender biselada|O|O||D||1
27111546|Sierra de panel|O|O||D||1
27111547|Sierra de pisos|O|O||D||1
27111548|Sierra tenon|O|O||D||1
27111549|Sierra para herraduras|O|O||D||1
27111550|Sierra de moño|O|O||D||1
27111551|Sierra de troncos|O|O||D||1
27111552|Segueta|O|O||D||1
27111553|Sierra de dos hombres|O|O||D||1
27111554|Afilador de cuchillas|O|O||D||1
27111555|Punzón central|O|O||D||1
27111556|Punzón hueco|O|O||D||1
27111557|Punzón cónico|O|O||D||1
27111558|Pinzón de pasador paralelo|O|O||D||1
27111559|Sierra para metales|O|O||D||1
27111560|Mini alicates|O|O||D||1
27111561|Caja de ingletear|O|O||D||1|Caja de mitre
27111562|Cortadora de cables|O|O||D||1
27111600|Herramientas de perfilar|O|O||D||1
27111601|Mazas de hierro|O|O||D||1|Mazos de hierro
27111602|Martillos|O|O||D||1
27111603|Yunques|O|O||D||1
27111604|Hachas de mano|O|O||D||1
27111605|Picas|O|O||D||1
27111607|Herramientas de recalcar|O|O||D||1|Herramientas de estampado
27111608|Enderezadores manuales de cables|O|O||D||1
27111609|Enderezadores eléctricos de cables|O|O||D||1
27111610|Componentes de martillo y mazo|O|O||D||1
27111611|Martillo para picar piedra|O|O||D||1
27111612|Martillo o mazo que no saca chispas|O|O||D||1|Mazo
27111613|Hachuela que no sacan chispas|O|O||D||1|Hacha antichispas
27111614|Pica que no saca chispas|O|O||D||1|Pica antichispas
27111615|Almádena o martillo macho|O|O||D||1|Martillo antichispas
27111616|Martillo de bola|O|O||D||1
27111617|Martillo de caucho|O|O||D||1
27111618|Martillo de garra|O|O||D||1
27111619|Martillo de bola de cruz y derecho|O|O||D||1
27111620|Martillo de bola de pasador|O|O||D||1
27111621|Martillo mazo|O|O||D||1
27111622|Martillo de carpintería|O|O||D||1
27111623|Tapador de botellas manual|O|O||D||1
27111700|Llaves inglesas y guías|O|O||D||1
27111701|Destornilladores|O|O||D||1|Desarmadores
27111702|Llaves para tuercas|O|O||D||1
27111703|Juegos de enchufes|O|O||D||1
27111704|Enchufes|O|O||D||1
27111705|Llaves de tuercas de boca cerrada|O|O||D||1
27111706|Llave de tuercas de boca abierta|O|O||D||1
27111707|Llaves ajustables|O|O||D||1|Llaves inglesas, Llaves perico
27111708|Llaves para tubos|O|O||D||1
27111709|Extractor de tornillos|O|O||D||1
27111710|Llaves allen|O|O||D||1|Llaves hexagonales
27111711|Trinquetes|O|O||D||1
27111712|Extractores|O|O||D||1
27111713|Llaves de combinación|O|O||D||1
27111714|Llaves de especialidad|O|O||D||1
27111715|Llaves de torsión|O|O||D||1
27111716|Llave torx|O|O||D||1
27111717|Extractores de tubería|O|O||D||1
27111718|Extractores de grifo|O|O||D||1
27111720|Llave manual en t para grifos|O|O||D||1
27111721|Manivelas|O|O||D||1
27111722|Troqueleras|O|O||D||1
27111723|Llaves de tubo|O|O||D||1
27111724|Llaves de gancho|O|O||D||1
27111725|Llaves tubulares de desplazamiento|O|O||D||1
27111726|Llaves de tuercas|O|O||D||1
27111727|Llaves macho con mango en t|O|O||D||1|Llave para taladro
27111728|Juego de destornilladores|O|O||D||1|Juego de desarmadores
27111729|Juego de llaves|O|O||D||1|Juego de llaves inglesas
27111730|Llave giratoria de dos extremos|O|O||D||1
27111731|Destornillador de precisión|O|O||D||1|Desarmador de precisión
27111732|Destornillador que no saca chispas|O|O||D||1|Desarmador antichispas
27111733|Destornillador de mango flexible|O|O||D||1|Desarmador de varilla flexible
27111734|Destornillador de múltiples puntas|O|O||D||1|Desarmador de punta múltiple
27111735|Destornillador de trinquete|O|O||D||1|Desarmador de trinquete
27111736|Destornillador aislado|O|O||D||1|Desarmador aislado
27111737|Destornillador manual automático de empujar|O|O||D||1|Desarmador semiautomático
27111738|Destornillador tester de voltaje|O|O||D||1|Desarmador probador de voltaje
27111739|Destornillador de torque|O|O||D||1|Desarmador de torsión
27111740|Destornillador telescópico|O|O||D||1|Desarmador telescópico
27111741|Destornillador de mango intercambiable|O|O||D||1|Desarmador de varilla intercambiable
27111742|Destornillador de impacto|O|O||D||1|Desarmador de impacto
27111743|Llave de anillos|O|O||D||1|Llave inglesa
27111744|Llave de compensación de anillos|O|O||D||1|Llave anular
27111745|Llave de anillo dividido|O|O||D||1|Llave inglesa doble
27111746|Llave bulldog|O|O||D||1
27111747|Llave de caja|O|O||D||1
27111748|Llave de huella|O|O||D||1
27111749|Llave de tubo o stillson|O|O||D||1
27111750|Pinza de presión|O|O||D||1
27111751|Llave de grifos|O|O||D||1|Llave de grifo
27111752|Llave de obstrucción|O|O||D||1|Llave angular
27111753|Llave de trinquete|O|O||D||1
27111754|Llave en s|O|O||D||1
27111755|Llave en y|O|O||D||1
27111756|Llave de pata de cuervo|O|O||D||1|Llave de pata
27111757|Llave de golpe especial o slugging|O|O||D||1|Llave de giro
27111758|Llave dinamométrica de disparo automático|O|O||D||1|Palanca de Leva
27111759|Llave de cuchilla|O|O||D||1
27111760|Llave de tuercas de llantas|O|O||D||1
27111761|Llave de bomba de agua|O|O||D||1
27111762|Llave de trinquete de cabeza flexible|O|O||D||1
27111763|Llave allen|O|O||D||1
27111764|Guías de broca|O|O||D||1
27111765|Llave para destapar tambores|O|O||D||1|Llave para abrir tambos
27111766|Llave de rin cruzado|O|O||D||1
27111767|Destornillador de compensación o en “l”|O|O||D||1|Destornillador
27111800|Herramientas de medida y bocetaje|O|O||D||1
27111801|Cintas métricas|O|O||D||1|Flexómetro
27111802|Escalas|O|O||D||1
27111803|Escuadras|O|O||D||1
27111804|Plomadas|O|O||D||1
27111806|Calibrador de clavos|O|O||D||1|Medidor de clavos
27111807|Bordes rectos|O|O||D||1
27111809|Biseles|O|O||D||1
27111810|Buscadores de pernos|O|O||D||1
27111811|Regla doblable|O|O||D||1|Regla flexible
27111812|Regla larga|O|O||D||1
27111813|Línea de plomada|O|O||D||1|Línea plomada
27111814|Espejo de inspección|O|O||D||1
27111815|Escuadra de combinación|O|O||D||1
27111816|Juego de bola indicadora|O|O||D||1|Juego de bolas gage
27111817|Regla de encogimiento|O|O||D||1
27111818|Soporte del indicador del|O|O||D||1|Soporte indicador de cuadrante
27111819|Espécimen de comparación de rugosidad|O|O||D||1|Galgas de comparación de rugosidad
27111820|Escuadra maestra|O|O||D||1
27111821|Escuadra cilíndrica|O|O||D||1
27111822|Instrumento de medición de ángulos|O|O||D||1
27111823|Calibrador de centro|O|O||D||1
27111824|Calibrador de ángulo|O|O||D||1
27111825|Placa de seno|O|O||D||1
27111826|Placa de superficie de precisión|O|O||D||1
27111827|Placa de ángulo ajustable|O|O||D||1
27111828|Placa de ángulo fijo|O|O||D||1
27111829|Paralelo óptico|O|O||D||1
27111900|Herramientas gruesas y de acabado|O|O||D||1
27111901|Cortafríos|O|O||D||1|Cincel corta frío
27111903|Cepillos de carpintero|O|O||D||1
27111904|Raspa|O|O||D||1
27111905|Esmeriladoras|O|O||D||1
27111906|Cinceles de madera|O|O||D||1
27111907|Cepillos de alambre|O|O||D||1
27111908|Piedras o herramientas o equipos de afilar|O|O||D||1
27111909|Espátulas|O|O||D||1
27111910|Buriles|O|O||D||1|Cuchilla para torno
27111911|Formones|O|O||D||1|Cinceles de corte transversal
27111912|Perforador de madera|O|O||D||1
27111913|Arreglador de bordes|O|O||D||1|Recortador de bordes
27111914|Cincel de punta de bola|O|O||D||1|Cincel de punta
27111915|Cincel de cantera|O|O||D||1
27111916|Removedor de techos|O|O||D||1
27111917|Aplicador de goma|O|O||D||1
27111918|Lija manual|O|O||D||1
27111919|Lima bastarda|O|O||D||1
27111920|Lima de segundo corte|O|O||D||1
27111921|Lima de corte liso|O|O||D||1
27111922|Lima de corte en cruz|O|O||D||1
27111923|Lima de sierra de cadena|O|O||D||1|Afiladora de dientes de motosierra
27111924|Lima de corte raspa|O|O||D||1
27111925|Lima de aguja|O|O||D||1
27111926|Lima plana de aluminio|O|O||D||1
27111927|Lima de aluminio semicircular|O|O||D||1
27111928|Lima rallo de queso|O|O||D||1
27111929|Lima de mano plana|O|O||D||1
27111930|Lima redonda|O|O||D||1
27111931|Lima semicircular|O|O||D||1
27111932|Lima de escuadra|O|O||D||1
27111933|Lima triangular de tres escuadras|O|O||D||1
27111934|Lima plana cónica|O|O||D||1
27111935|Lima de navaja|O|O||D||1
27111936|Lima de guarda|O|O||D||1
27111937|Lima laminada|O|O||D||1
27111938|Lima de torno de ángulo largo|O|O||D||1
27111939|Lima semicircular para tubería|O|O||D||1
27111940|Lima de sierra maderera|O|O||D||1
27111941|Lima de sierra cónica|O|O||D||1
27111942|Lima de sierra de extremo doble|O|O||D||1
27111943|Lima de granjero|O|O||D||1
27111944|Lima de precisión|O|O||D||1
27111945|Lima curva para grabar troqueles|O|O||D||1
27111946|Lima curva de platería|O|O||D||1
27111948|Raspador semicircular de madera|O|O||D||1
27111949|Raspador semicircular de gabinete|O|O||D||1
27111950|Raspador circular de madera|O|O||D||1
27111951|Raspador de zapatas de cuatro en mano|O|O||D||1
27111952|Raspador de caballos|O|O||D||1
27111953|Raspador de peletero|O|O||D||1
27111954|Escariador cónico de vástago de puente|O|O||D||1|Escariador vástago de puente
27111955|Escariador redondo de vástago de puente|O|O||D||1|Escariador redondeado
27111956|Bruñidor|O|O||D||1
27111957|Limpiador de boquillas|O|O||D||1
27111958|Lapeador de mano|O|O||D||1
27112000|Herramientas manuales de jardinería, agricultura y forestación|O|O||D||1|Herramientas manuales de floricultura, cultivo y reforestación
27112001|Machetes|O|O||D||1
27112002|Azadones|O|O||D||1
27112003|Rastrillos|O|O||D||1
27112004|Palas|O|O||D||1
27112005|Hachas|O|O||D||1
27112006|Guadañas|O|O||D||1
27112007|Tijeras de podar|O|O||D||1|Tijeras para podar pasto
27112008|Azadas|O|O||D||1|Azadillas
27112009|Raspadores|O|O||D||1
27112010|Horquilla de jardín|O|O||D||1
27112011|Mangos de herramientas|O|O||D||1
27112012|Criba jardinera|O|O||D||1|Cernidor de jardinería
27112013|Excavadora de hoyos para postes|O|O||D||1|Perforadora de hoyos para postes
27112014|Cortadora de pasto|O|O||D||1|Desbrozadora para pasto
27112015|Escarificador de prados|O|O||D||1|Podadora de pasto
27112016|Tijeras para setos|O|O||D||1|Tijeras podadoras de arbustos
27112017|Barras de cavar o barretones|O|O||D||1
27112018|Plantador de bulbos|O|O||D||1
27112019|Sierra podadora|O|O||D||1
27112020|Hoz|O|O||D||1
27112021|Aireador de césped|O|O||D||1
27112022|Cizalla para bordes|O|O||D||1|Cortadoras de borde
27112023|Cultivador a mano|O|O||D||1
27112024|Juego de herramientas para jardín en miniatura|O|O||D||1
27112025|Azada de mango corto|O|O||D||1|Azadillas de mango corto
27112026|Cuña de mango|O|O||D||1
27112027|Escoba de jardín|O|O||D||1|Rastrillo
27112028|Descortezadora de árboles|O|O||D||1
27112029|Regadera de jardín|O|O||D||1
27112030|Gancho podador|O|O||D||1
27112031|Cedazo de jardín|O|O||D||1
27112032|Azuela|O|O||D||1|Hacha con hoja curveada
27112033|Juego de herramientas de jardín|O|O||D||1
27112034|Cortador de raíces|O|O||D||1
27112035|Cortador de setos|O|O||D||1
27112036|Trituradora de jardín|O|O||D||1|Trituradora de ramas
27112037|Cortador de brochas|O|O||D||1
27112038|Sierra de cadena de jardín|O|O||D||1
27112039|Podadora de 2 manos|O|O||D||1
27112040|Sonda de suelo|O|O||D||1
27112041|Cuchillo de injertos|O|O||D||1|Navaja para injertar
27112042|Medidor de ancho de troncos|O|O||D||1|Instrumentos de medición forestal
27112043|Herramienta para diagnóstico de árboles o resistógrafo|O|O||D||1
27112044|Juego de inyecciones para troncos de árboles|O|O||D||1
27112045|Cortador de césped|O|O||D||1
27112046|Recogedor de pasto cortado|O|O||D||1|Recolector de pasto cortado
27112047|Cortador de ramas altas|O|O||D||1
27112100|Herramientas de sujeción y fijación|O|O||D||1
27112101|Dobladores de tubos|O|O||D||1|Roladora de tubo
27112102|Tornillos de banco|O|O||D||1
27112103|Pinza de mano|O|O||D||1
27112104|Tenazas|O|O||D||1
27112105|Pinzas|O|O||D||1
27112106|Alicates de guardalínea|O|O||D||1|Pinzas de electricista
27112107|Alicates boquianchos ajustables|O|O||D||1|Pinzas de boquilla ajustable
27112108|Alicates de punta de aguja|O|O||D||1|Pinzas de punta de aguja
27112109|Herramientas magnéticas|O|O||D||1|Herramientas imantadas
27112110|Pinzas de anillo de retención|O|O||D||1|Pinzas para anillo de retención
27112111|Alicates de lagarto|O|O||D||1|Pinzas de lagarto
27112112|Tenazas de ranura y lengüeta|O|O||D||1|Pinzas de ranura y lengüeta
27112113|Alicates de articulación movible o de ranura|O|O||D||1|Pinzas de junta ajustable o ranura
27112114|Pinzas de corte diagonal|O|O||D||1
27112115|Pinzas de cerrado|O|O||D||1|Pinzas de presión
27112116|Pinzas de cerca|O|O||D||1|Pinzas para cercas
27112117|Tenazas de corte final|O|O||D||1|Pinzas para corte final
27112119|Cambiador de bombilla de luz|O|O||D||1|Brazo largo para cambiar focos
27112120|Grapas c|O|O||D||1|Prensa C
27112121|Grapa de ángulo|O|O||D||1|Abrazaderas de ángulo
27112122|Alicates de hoja metálica|O|O||D||1|Alicates de chapa
27112123|Prensa de mesa|O|O||D||1
27112124|Tensionadores|O|O||D||1
27112125|Alicates de punta redonda|O|O||D||1|Pinzas de punta
27112126|Alicates planos|O|O||D||1|Pinzas de punta plana
27112127|Llaves de cinta|O|O||D||1
27112128|Alicates de punta curvada|O|O||D||1|Pinzas de punta curva
27112129|Abrazaderas de mango redondo|O|O||D||1
27112130|Abrazaderas de tres garras|O|O||D||1
27112131|Abrazadera para la apertura de mandíbula|O|O||D||1
27112132|Abrazaderas de fijación|O|O||D||1
27112133|Abrazaderas con mango en t|O|O||D||1|Abrazaderas de manillar en T
27112134|Alicates de punta larga|O|O||D||1|Pinzas de punta larga
27112135|Alicates aislados|O|O||D||1|Pinzas aisladas
27112136|Alicates que no sacan chispa|O|O||D||1|Pinzas antichispas
27112137|Juego de alicates|O|O||D||1|Juego de pinzas
27112138|Enderezador manual de tubos|O|O||D||1
27112139|Alicates de combinación|O|O||D||1|Pinzas de combinación
27112140|Alicates circlip|O|O||D||1|Pinzas circlip
27112141|Alicates de vidrio|O|O||D||1|Cortadores de vidrio
27112142|Alicates muli – herramienta|O|O||D||1|Alicates múltiple
27112143|Alicates para cortar baldosas|O|O||D||1|Cortadoras de loza
27112144|Alicates de nariz doblada|O|O||D||1
27112145|Alicates de articulación movible|O|O||D||1|Alicates de unión deslizante
27112146|Tornillo de base pivote|O|O||D||1|Tornillo de sujeción
27112147|Alicates de engaste|O|O||D||1|Alicates de crimpado
27112148|Alicates electrónicos|O|O||D||1
27112149|Alicates electrostáticos|O|O||D||1
27112150|Alicates de joyería|O|O||D||1|Pinzas de joyero
27112151|Alicates pelacables|O|O||D||1|Pinzas pela cables
27112152|Almeja triclover|O|O||D||1
27112153|Engrapadora de banda|O|O||D||1
27112154|Tornillo fresador|O|O||D||1
27112155|Expansor de anillo de pistón|O|O||D||1
27112156|Tornillo de mano|O|O||D||1
27112157|Tornillo de taladro|O|O||D||1
27112158|Tornillo de pata|O|O||D||1
27112159|Tornillo de cadena|O|O||D||1
27112160|Torcedor de cables|O|O||D||1|Tornillo de alambre
27112161|Herramienta para empacar cables|O|O||D||1|Herramienta para sujeción de cable
27112162|Unión para reglas|O|O||D||1
27112200|Herramientas de albañilería y concreto|O|O||D||1
27112201|Palustres|O|O||D||1|Cuchara para mezcla
27112202|Palustres o llanas de madera|O|O||D||1
27112203|Bordeadoras|O|O||D||1
27112205|Vibradores de concreto|O|O||D||1
27112206|Tabla de mortero|O|O||D||1
27112207|Ariete de mano|O|O||D||1
27112208|Pica|O|O||D||1|Copiador de perfiles para corte
27112209|Pala de mampostería|O|O||D||1
27112210|Unidor de ladrillos|O|O||D||1
27112211|Llenador de uniones|O|O||D||1
27112212|Herramienta de frente de brocal|O|O||D||1|Herramienta de bordillo
27112213|Chute de concreto|O|O||D||1|Tolva de concreto
27112215|Alisador de bordes|O|O||D||1|Alisador de bordes para concreto
27112216|Marcador de baldosas|O|O||D||1|Marcador de azulejos
27112217|Partidor de baldosas|O|O||D||1|Cortador de azulejos
27112218|Sierra eléctrica para baldosas|O|O||D||1|Sierra eléctrica de azulejos
27112219|Pellizcador de baldosas|O|O||D||1|Pinzas para azulejo
27112220|Sierra de mano para baldosas|O|O||D||1|Sierra de mano para azulejo
27112221|Broca para baldosas|O|O||D||1|Broca especial para azulejo
27112222|Cortador de baldosas|O|O||D||1|Cortador de azulejos
27112223|Lima para baldosas|O|O||D||1|Lima para azulejo
27112224|Copiador de perfiles para corte|O|O||D||1
27112225|Esparcidor muescado|O|O||D||1|Espaciador entallado
27112226|Palustre para baldosas|O|O||D||1|Cuchara para azulejos
27112227|Esparcidor de lechada|O|O||D||1
27112228|Removedor de lechada|O|O||D||1
27112229|Cincel para remover baldosas|O|O||D||1|Cincel de cuña para remover azulejo
27112230|Llenador de juntas|O|O||D||1|Puntero tuck para relleno de juntas
27112231|Herramienta para escalones|O|O||D||1
27112232|Ranuradora|O|O||D||1
27112300|Herramientas de marcar|O|O||D||1|Herramienta de sellado y marcado
27112301|Hierro de marcar|O|O||D||1|Fierro quemador
27112302|Punzones o alwznas|O|O||D||1
27112303|Punzón de trazar|O|O||D||1
27112304|Líneas de marcar con tiza|O|O||D||1
27112305|Marcadores o soportes de metal|O|O||D||1
27112306|Sellos de metal|O|O||D||1
27112307|Tizas para trazar líneas|O|O||D||1
27112308|Carrito marcador|O|O||D||1
27112309|Lápiz marcador|O|O||D||1
27112310|Soporte de tiza|O|O||D||1|Sujetadores de gis
27112311|Tiza para marcar|O|O||D||1|Gis para marcar
27112312|Medidor superficial|O|O||D||1|Medidor de superficies
27112313|Marcador de dimensiones|O|O||D||1
27112400|Herramientas de inserción y ajuste|O|O||D||1
27112401|Pistolas de grapas|O|O||D||1
27112402|Ribeteadoras|O|O||D||1|Maquinas de coser u orleadora
27112403|Colocadores de abrazaderas|O|O||D||1
27112404|Herramientas para poner anclajes|O|O||D||1|Herramienta de fijación
27112405|Calentadores de pernos|O|O||D||1
27112406|Pistolas de etiquetado|O|O||D||1|Pistola etiquetadora
27112407|Desprendedor de etiqueta de seguridad|O|O||D||1
27112408|Removedor industrial de ganchos|O|O||D||1
27112409|Pistola remachadora explosiva|O|O||D||1|Pistola remachadora expansiva
27112410|Pistola para amarrar cables|O|O||D||1|Pistola para atadura de cables
27112500|Herramientas para apalancar y curvar|O|O||D||1
27112501|Herramientas curvatubos|O|O||D||1|Dobladoras para tubo
27112502|Palancas|O|O||D||1|Barra para palanquear
27112503|Dobladoras de tubos|O|O||D||1
27112504|Cuñas|O|O||D||1
27112505|Ganchos para empaquetaduras|O|O||D||1|Ganchos de embalaje
27112506|Manchas de impresión|O|O||D||1
27112507|Varilla patecabra|O|O||D||1|Barreta pata de cabra
27112508|Doblador de cables|O|O||D||1
27112600|Herramientas para precintar|O|O||D||1|Herramientas para asegurar y etiquetar
27112601|Espátulas para enmasillar|O|O||D||1
27112602|Herramientas de calafateado|O|O||D||1
27112603|Herramienta de inserción|O|O||D||1
27112604|Recipiente para plastilina|O|O||D||1|Cuenco de masilla
27112700|Herramientas mecánicas|O|O||D||1
27112701|Fuelles eléctricos|O|O||D||1|Cubre polvos eléctricos
27112702|Pulidoras eléctricas|O|O||D||1
27112703|Taladradoras eléctricas|O|O||D||1
27112704|Amoladora eléctricas|O|O||D||1|Pulidor eléctrico
27112705|Martillos de demolición|O|O||D||1|Rotomartillo de demolición
27112706|Cepillos eléctricos|O|O||D||1|Cepillo eléctrico industrial
27112707|Cuchillas eléctricas|O|O||D||1
27112708|Lijadoras eléctricas|O|O||D||1
27112709|Sierras eléctricas|O|O||D||1
27112710|Pistolas de tornillos eléctricas|O|O||D||1|Pistola atornilladora eléctrica
27112711|Pistolas de grapas eléctricas|O|O||D||1
27112712|Ribeteadoras eléctricas|O|O||D||1|Cortadores eléctricos
27112713|Aprietatuercas neumático de percusión|O|O||D||1|Pistolas de alto impacto neumáticas
27112714|Pistolas de calafateo eléctricas|O|O||D||1
27112715|Martillos cinceladores eléctricos|O|O||D||1
27112716|Pistolas de clavos eléctricas|O|O||D||1
27112717|Pistolas de calor|O|O||D||1
27112718|Grabadores|O|O||D||1
27112719|Pistolas para engomar|O|O||D||1
27112720|Herramientas de par de torsión|O|O||D||1|Herramientas de tensionado y de torsión
27112721|Juntador de capas de material|O|O||D||1
27112722|Biseladora|O|O||D||1
27112723|Cizallas eléctricas|O|O||D||1
27112724|Pellizcadoras eléctricas|O|O||D||1
27112725|Ribeteadora eléctrica|O|O||D||1|Máquina de coser eléctrica
27112726|Cortador de varillas eléctrico|O|O||D||1
27112727|Pistola de mortero|O|O||D||1
27112728|Soplete eléctrico|O|O||D||1
27112729|Conector de tubos|O|O||D||1
27112730|Pistola de grasa eléctrica|O|O||D||1
27112731|Tijeras eléctricas|O|O||D||1
27112732|Doblador de tubos eléctrico|O|O||D||1
27112733|Cortador de ángulos|O|O||D||1
27112734|Sierra de vaivén|O|O||D||1
27112735|Sierra de espiral|O|O||D||1
27112736|Cortador de muros|O|O||D||1
27112737|Lija orbital|O|O||D||1
27112738|Lija de detalle|O|O||D||1
27112739|Lija de banda|O|O||D||1
27112740|Lija de banca|O|O||D||1
27112741|Lima lija o lija dedo|O|O||D||1
27112742|Lija de disco|O|O||D||1
27112743|Sierra de brazo elástico|O|O||D||1|Sierra de brazo
27112744|Sierra neumática|O|O||D||1|Sierra caladora neumática
27112745|Sierra de concreto|O|O||D||1|Sierra para concreto
27112746|Sierra de cadena|O|O||D||1
27112747|Sierra recíproca|O|O||D||1|Sierra intercambiable
27112748|Sierra ingleteadora|O|O||D||1|Cortadora ingletadora
27112749|Pulidora de ángulo|O|O||D||1|Rectificadora angular
27112750|Herramienta compresora a batería|O|O||D||1
27112800|Conexiones de herramientas y accesorios|O|O||D||1
27112802|Hojas de sierra|O|O||D||1|Discos cortadores
27112803|Fresadoras con mango|O|O||D||1|Brocas de fresado, Matrices
27112804|Troqueles o punzones de estampar|O|O||D||1
27112805|Troqueles de roscado|O|O||D||1
27112806|Machos de roscado|O|O||D||1|Machuelos
27112807|Cuñas|O|O||D||1
27112808|Anillos metálicos|O|O||D||1|Sujetadores de collar para brocas y troqueles
27112809|Portaherramientas|O|O||D||1
27112810|Equipos para reparar roscas|O|O||D||1
27112811|Árboles|O|O||D||1|Mandril industrial
27112812|Avellanadores|O|O||D||1
27112813|Vara de extensión|O|O||D||1
27112814|Brocas de destornillador|O|O||D||1
27112815|Brocas para poner tuercas|O|O||D||1
27112818|Sombreretes o revestimientos de prensas de tornillo|O|O||D||1
27112819|Cuchillas de corte para encuadernación|O|O||D||1
27112820|Troqueles de herramienta engarzadora de lengüetas|O|O||D||1
27112821|Brocas de buriladora|O|O||D||1
27112822|Adaptadores de cubo|O|O||D||1
27112823|Cadenas de corte|O|O||D||1
27112824|Portabrocas|O|O||D||1
27112825|Juegos de plantillas de herramienta|O|O||D||1|Plantilla ajustable de medición
27112826|Caladora|O|O||D||1
27112827|Dispositivos para imantar y viceversa|O|O||D||1|Imantador para herramientas
27112828|Enchufes de impacto|O|O||D||1|Casquillos de impacto
27112829|Anexos de llave de impacto y sus accesorios|O|O||D||1|Llaves de impacto, acoplamientos y accesorios
27112830|Accesorios y suministros de destornillador|O|O||D||1|Desarmador, suministros y accesorios
27112831|Accesorios y suministros de llave|O|O||D||1|Llave inglesa, suministros y accesorios
27112832|Anexos t accesorios de enchufe|O|O||D||1
27112833|Estuche de brocas|O|O||D||1
27112834|Estuche de roscador manual de tubos|O|O||D||1
27112835|Escariador de máquina|O|O||D||1
27112836|Juego de brocas de destornillador|O|O||D||1
27112837|Escariador manual|O|O||D||1
27112838|Disco de corte|O|O||D||1
27112839|Broca de cincel|O|O||D||1
27112840|Broca guía|O|O||D||1
27112841|Broca manual para metal|O|O||D||1
27112842|Broca manual para madera|O|O||D||1
27112843|Broca manual para piedra|O|O||D||1
27112844|Placa de lapeado|O|O||D||1
27112845|Juego de brocas|O|O||D||1
27112846|Adaptador de pistola de calor|O|O||D||1
27112847|Estuche de troqueles|O|O||D||1
27112900|Herramientas dispensadoras|O|O||D||1
27112901|Pistolas de grasa|O|O||D||1
27112902|Chimeneas industriales|O|O||D||1|Fogones
27112903|Rociador manual|O|O||D||1
27112904|Pistola de resina|O|O||D||1|Pistolete de resina
27112905|Lata de aceite|O|O||D||1|Bote de aceite
27112906|Pistolas de calafateado|O|O||D||1|Pistolas para impermeabilizar
27112907|Separadores de difusión|O|O||D||1
27112908|Pistola de aceite|O|O||D||1|Pistolete de aceite
27112909|Trapero para techos|O|O||D||1
27112910|Almacenamiento portátil para desperdicio de aceite|O|O||D||1|Reposito portátil para desperdicio de aceite
27112911|Copa de aceite|O|O||D||1
27112912|Cambiador de aceite|O|O||D||1|Dosificador de aceite
27112913|Lubricador de aceite|O|O||D||1
27112914|Lubricador de grasa|O|O||D||1
27112915|Dispensador de gas natural|O|O||D||1|Dosificador de gas
27112916|Dispensador de combustible líquido o bomba de gasolina|O|O||D||1|Dosificador de combustible líquido o bomba de
27113000|Cepillos|O|O||D||1
27113001|Cepillos de aruñar|O|O||D||1|Cepillo de alambre
27113002|Cepillos de tubo|O|O||D||1|Escobilla de tubo
27113003|Cepillos de aplicar|O|O||D||1|Cepillo para impermeabilizar
27113004|Cepillos de extensor|O|O||D||1|Rodillo para impermeabilizar
27113005|Cepillo de techado|O|O||D||1|Escoba cepillo
27113100|Herramientas de arrastre|O|O||D||1
27113101|Cinta guía|O|O||D||1
27113102|Tirador de fusible|O|O||D||1|Extractor de fusibles
27113103|Buril|O|O||D||1|Cuchilla de corte
27113104|Extractores de estacas|O|O||D||1|Removedor de estaca
27113105|Extensor de resortes|O|O||D||1
27113200|Juegos de herramientas|O|O||D||1
27113201|Conjuntos generales de herramientas|O|O||D||1
27113202|Kit de herramientas para ajustar rodamiento|O|O||D||1
27113203|Kit de herramienta para computadores|O|O||D||1
27113204|Kits de electricista|O|O||D||1
27113300|Herramientas manuales de precisión|O|O||D||1
27113301|Resortes de retorno a presión|O|O||D||1
27121500|Prensas hidráulicas|O|O||D||1
27121501|Suspensiones a presión retornables|O|O||D||1
27121502|Bastidores de prensa hidráulica|O|O||D||1
27121503|Columnas de prensa hidráulica|O|O||D||1
27121504|Prensa hidráulica industrial|O|O||D||1
27121600|Pistones y cilindros hidráulicos|O|O||D||1
27121601|Pistones de cilindro|O|O||D||1
27121602|Cilindros hidráulicos|O|O||D||1
27121603|Vástagos de pistón de cilindro hidráulico|O|O||D||1
27121604|Kits de reparación de cilindro hidráulico o sus componentes|O|O||D||1
27121605|Cuerpos de cilindro hidráulico|O|O||D||1
27121606|Soportes de montaje para cilindros hidráulicos|O|O||D||1
27121700|Accesorios de tubería y manga hidráulica|O|O||D||1
27121701|Conectores hidráulicos rápidos|O|O||D||1|Coples hidráulicos rápidos
27121702|Injertos o injertos dobles hidráulicos|O|O||D||1|Injertos dobles hidráulicos
27121703|Férulas|O|O||D||1|Ferrules
27121704|Uniones hidráulicas|O|O||D||1|Acoples hidráulicos
27121705|Codos hidráulicos o de compresión|O|O||D||1|Codos hidráulicos de alta compresión
27121706|Tuercas de férula|O|O||D||1
27121707|Conectores de pliegue|O|O||D||1|Conectores de cripado
27121800|Herramientas hidráulicas|O|O||D||1
27121801|Levantadores de cubierta de manhole|O|O||D||1
27121802|Acumuladores hidráulicos|O|O||D||1
27121803|Almejas hidráulicas|O|O||D||1
27121804|Cizallas hidráulicas|O|O||D||1
27121805|Extractor hidráulico|O|O||D||1
27121806|Doblador de tubos hidráulico|O|O||D||1
27121807|Halador hidráulico|O|O||D||1|Extractor hidráulico
27121808|Cortador de cadenas hidráulico|O|O||D||1
27121809|Herramienta hidráulica para romper tuercas|O|O||D||1|Herramienta hidráulica de corte de tuerca
27121810|Herramienta engastadora hidráulica manual|O|O||D||1|Herramienta hidráulica de crimpado manual
27121811|Accesorio de herramienta engastadora hidráulica|O|O||D||1|Accesorio de herramienta crimpado hidráulica
27121812|Remoto hidráulico|O|O||D||1|Mando a distancia hidráulico
27131500|Herramientas neumáticas|O|O||D||1
27131501|Llaves de impacto neumático|O|O||D||1|Pistola neumática de impacto
27131502|Pistola de aire comprimido|O|O||D||1
27131504|Martillo neumático|O|O||D||1|Martillo cincelador neumático
27131505|Taladro neumático|O|O||D||1|Taladro de impacto neumático
27131506|Clavadora de clavos neumática|O|O||D||1|Clavadora neumática
27131507|Máquinas de lijado neumáticas|O|O||D||1
27131508|Motores neumáticos|O|O||D||1|Motores de aire comprimido
27131509|Acumuladores neumáticos|O|O||D||1|Acumulador de aire comprimido
27131510|Depósitos de acumulador|O|O||D||1
27131511|Rectificadoras neumáticas|O|O||D||1
27131512|Destornillador neumático|O|O||D||1
27131513|Lima neumática|O|O||D||1
27131514|Alicates neumáticos|O|O||D||1|Alicates neumático de corte
27131515|Llave neumática de no – impacto|O|O||D||1|Llave de impacto
27131516|Lápiz grabador neumático|O|O||D||1
27131517|Grapadora neumática industrial|O|O||D||1
27131518|Herramienta neumática para remover vidrios de autos|O|O||D||1|Pistola neumática para remover o desprender parabrisas
27131519|Punzón neumático o de aire|O|O||D||1
27131520|Cortador neumático de varillas|O|O||D||1
27131521|Ribeteador neumático|O|O||D||1
27131522|Lija neumática miniatura|O|O||D||1
27131523|Martillo neumático|O|O||D||1
27131524|Avellanadora neumática|O|O||D||1|Maquina avellanadora de tubo neumático
27131525|Cizallas neumáticas|O|O||D||1
27131526|Prensa neumática|O|O||D||1
27131527|Juego de herramientas neumáticas|O|O||D||1
27131528|Sacador de puntillas neumático|O|O||D||1
27131600|Accesorios de aire y conectores|O|O||D||1
27131601|Múltiples de aire|O|O||D||1
27131603|Reguladores de aire|O|O||D||1|Reguladores de aire comprimido
27131604|Lubricadores neumáticos|O|O||D||1
27131605|Cortina de aire|O|O||D||1
27131608|Conos o almohadillas de vacío|O|O||D||1
27131609|Silenciadores neumáticos|O|O||D||1
27131610|Kits de reparación del engrasador o el regulador|O|O||D||1
27131613|Acoplamiento neumático|O|O||D||1
27131614|Adaptadores neumáticos|O|O||D||1
27131615|Generador neumático de vacío|O|O||D||1
27131700|Cilindros neumáticos y componentes|O|O||D||1
27131701|Cilindros neumáticos|O|O||D||1
27131702|Accesorios de vástago de cilindro neumático|O|O||D||1
27131703|Pistones de cilindro neumático|O|O||D||1
27131704|Vástagos de pistón de cilindro neumático|O|O||D||1
27131705|Cuerpo de cilindro neumático|O|O||D||1
27131706|Capacetes de cilindro neumático|O|O||D||1
27131707|Kits de reparación de cilindro neumático o sus componentes|O|O||D||1
27131708|Soportes de montaje para cilindros neumáticos|O|O||D||1
27131709|Anillos amortiguadores de cilindro neumático|O|O||D||1
27141000|Herramientas de carrocería|O|O||D||1
27141001|Herramientas de recorte o moldeo|O|O||D||1
27141100|Herramientas de suspensión|O|O||D||1
27141101|Extractor del volante|O|O||D||1
30101500|Ángulos|O|O||D||1
30101501|Ángulos de aleación ferrosa|O|O||D||1
30101502|Ángulos de aleación no ferrosa|O|O||D||1
30101503|Ángulos de hierro|O|O||D||1
30101504|Ángulos de acero|O|O||D||1
30101505|Ángulos de acero inoxidable|O|O||D||1
30101506|Ángulos de aluminio|O|O||D||1
30101507|Ángulos de magnesio|O|O||D||1
30101508|Ángulos de titanio|O|O||D||1
30101509|Ángulos de cobre|O|O||D||1
30101510|Ángulos de latón|O|O||D||1
30101511|Ángulos de bronce|O|O||D||1
30101512|Ángulos de zinc|O|O||D||1
30101513|Ángulos de estaño|O|O||D||1
30101514|Ángulos de plomo|O|O||D||1
30101515|Ángulos de plástico|O|O||D||1
30101516|Ángulos de caucho|O|O||D||1
30101517|Ángulos de metales preciosos|O|O||D||1
30101700|Vigas|O|O||D||1
30101701|Vigas de aleación ferrosa|O|O||D||1
30101702|Vigas de aleación no ferrosa|O|O||D||1
30101703|Vigas de hierro|O|O||D||1
30101704|Vigas de acero|O|O||D||1
30101705|Vigas de acero inoxidable|O|O||D||1
30101706|Vigas de aluminio|O|O||D||1
30101707|Vigas de magnesio|O|O||D||1
30101708|Vigas de titanio|O|O||D||1
30101709|Vigas de cobre|O|O||D||1
30101710|Vigas de latón|O|O||D||1
30101711|Vigas de bronce|O|O||D||1
30101712|Vigas de zinc|O|O||D||1
30101713|Vigas de estaño|O|O||D||1
30101714|Vigas de plomo|O|O||D||1
30101715|Vigas de plástico|O|O||D||1
30101716|Vigas de caucho|O|O||D||1
30101717|Vigas de concreto|O|O||D||1
30101718|Vigas de metales preciosos|O|O||D||1
30101719|Vigas de haydita|O|O||D||1
30101720|Vigas de triplex|O|O||D||1
30101800|Conductos|O|O||D||1
30101801|Conductos de aleación ferrosa|O|O||D||1
30101802|Conductos de aleación no ferrosa|O|O||D||1
30101803|Conductos de hierro|O|O||D||1
30101804|Conductos de acero|O|O||D||1
30101805|Conductos de acero inoxidable|O|O||D||1
30101806|Conductos de aluminio|O|O||D||1
30101807|Conductos de magnesio|O|O||D||1
30101808|Conductos de titanio|O|O||D||1
30101809|Conductos de cobre|O|O||D||1
30101810|Conductos de latón|O|O||D||1
30101811|Conductos de bronce|O|O||D||1
30101812|Conductos de zinc|O|O||D||1
30101813|Conductos de estaño|O|O||D||1
30101814|Conductos de plomo|O|O||D||1
30101815|Conductos de plástico|O|O||D||1
30101816|Conductos de caucho|O|O||D||1
30101817|Conductos de metales preciosos|O|O||D||1
30101818|Conductos de fibra de vidrio|O|O||D||1
30102000|Hoja|O|O||D||1
30102001|Lámina de aleación ferrosa|O|O||D||1
30102002|Lámina de aleación no ferrosa|O|O||D||1
30102003|Lámina de hierro|O|O||D||1
30102004|Lámina de acero|O|O||D||1
30102005|Lámina de acero inoxidable|O|O||D||1
30102006|Lámina de aluminio|O|O||D||1
30102007|Lámina de magnesio|O|O||D||1
30102008|Lámina de titanio|O|O||D||1
30102009|Lámina de cobre|O|O||D||1
30102010|Lámina de latón|O|O||D||1
30102011|Lámina de bronce|O|O||D||1
30102012|Lámina de zinc|O|O||D||1
30102013|Lámina de estaño|O|O||D||1
30102014|Lámina de plomo|O|O||D||1
30102015|Lámina de plástico|O|O||D||1
30102016|Lámina de tántalo|O|O||D||1
30102200|Plancha|O|O||D||1
30102201|Placa de aleación ferrosa|O|O||D||1
30102202|Placa de aleación no ferrosa|O|O||D||1
30102203|Placa de hierro|O|O||D||1
30102204|Placa de acero|O|O||D||1
30102205|Placa de acero inoxidable|O|O||D||1
30102206|Placa de aluminio|O|O||D||1
30102207|Placa de magnesio|O|O||D||1|Placa de aleación de magnesio
30102208|Placa de titanio|O|O||D||1
30102209|Placa de cobre|O|O||D||1
30102210|Placa de latón|O|O||D||1
30102211|Placa de bronce|O|O||D||1
30102212|Placa de zinc|O|O||D||1|Plancha de zinc para revestimiento
30102213|Placa de estaño|O|O||D||1
30102214|Placa de plomo|O|O||D||1|Plancha de plomo
30102215|Placa de plástico|O|O||D||1
30102216|Placa de caucho|O|O||D||1
30102217|Placa de concreto|O|O||D||1
30102218|Placa de metales preciosos|O|O||D||1
30102220|Placa de níquel|O|O||D||1
30102221|Placa de fibra|O|O||D||1
30102222|Placa de viruta|O|O||D||1
30102223|Placa de enchape de madera|O|O||D||1
30102224|Placa de tablero de papel o madera (coreboard)|O|O||D||1
30102225|Placa de corcho|O|O||D||1
30102226|Placa de butilo|O|O||D||1
30102227|Placa de tántalo|O|O||D||1
30102300|Perfiles|O|O||D||1
30102301|Perfiles de aleación ferrosa|O|O||D||1
30102302|Perfiles de aleación no ferrosa|O|O||D||1
30102303|Perfiles de hierro|O|O||D||1
30102304|Perfiles de acero|O|O||D||1
30102305|Perfiles de acero inoxidable|O|O||D||1
30102306|Perfiles de aluminio|O|O||D||1
30102307|Perfiles de magnesio|O|O||D||1|Perfiles de aleación de magnesio
30102308|Perfiles de titanio|O|O||D||1
30102309|Perfiles de cobre|O|O||D||1
30102310|Perfiles de latón|O|O||D||1
30102311|Perfiles de bronce|O|O||D||1
30102312|Perfiles de zinc|O|O||D||1
30102313|Perfiles de estaño|O|O||D||1
30102314|Perfiles de plomo|O|O||D||1
30102315|Perfiles de plástico|O|O||D||1
30102316|Perfiles de caucho|O|O||D||1
30102400|Varillas|O|O||D||1
30102401|Varillas de aleación ferrosa|O|O||D||1
30102402|Varillas de aleación no ferrosa|O|O||D||1
30102403|Varillas de hierro|O|O||D||1
30102404|Varillas de acero|O|O||D||1
30102405|Varillas de acero inoxidable|O|O||D||1
30102406|Varillas de aluminio|O|O||D||1
30102407|Varillas de magnesio|O|O||D||1
30102408|Varillas de titanio|O|O||D||1
30102409|Varillas de cobre|O|O||D||1
30102410|Varillas de latón|O|O||D||1
30102411|Varillas de bronce|O|O||D||1
30102412|Varillas de zinc|O|O||D||1
30102413|Varillas de estaño|O|O||D||1
30102414|Varillas de plomo|O|O||D||1
30102415|Varillas de plástico|O|O||D||1
30102416|Varillas de caucho|O|O||D||1
30102417|Varillas de níquel|O|O||D||1
30102800|Pilotaje|O|O||D||1
30102801|Pilares de aluminio|O|O||D||1
30102802|Pilares de concreto|O|O||D||1
30102803|Pilares de acero|O|O||D||1
30102804|Pilares de madera|O|O||D||1
30102900|Pilares|O|O||D||1
30102901|Postes de cemento o concreto|O|O||D||1
30102903|Postes de metal|O|O||D||1
30102904|Postes de madera|O|O||D||1
30102905|Postes de plástico|O|O||D||1
30102906|Postes de fibra de vidrio|O|O||D||1
30102907|Postes de madera tratada|O|O||D||1
30103100|Rieles|O|O||D||1
30103101|Rieles de acero|O|O||D||1
30103102|Rieles de aluminio|O|O||D||1
30103103|Rieles de metal|O|O||D||1
30103104|Rieles de madera|O|O||D||1
30103200|Enrejado|O|O||D||1
30103201|Rejilla de acero|O|O||D||1
30103202|Rejilla de acero inoxidable|O|O||D||1
30103203|Rejilla de aluminio|O|O||D||1
30103204|Rejilla de fibra de vidrio|O|O||D||1
30103205|Rejilla de hierro|O|O||D||1
30103206|Rejilla de plástico|O|O||D||1
30103207|Rejilla laminada|O|O||D||1
30103208|Rejilla de madera|O|O||D||1
30103500|Alma de panal|O|O||D||1|Núcleo de panal
30103501|Núcleo de panal de aluminio|O|O||D||1
30103502|Núcleo de panal de magnesio|O|O||D||1
30103503|Núcleo de panal de espuma|O|O||D||1
30103504|Núcleo de panal de plástico|O|O||D||1
30103505|Núcleo de panal de madera|O|O||D||1
30103506|Núcleo de panal de metal ferroso|O|O||D||1
30103507|Núcleo de panal de bronce|O|O||D||1
30103508|Núcleo de panal de cobre|O|O||D||1
30103509|Núcleo de panal de acero|O|O||D||1
30103510|Núcleo de panal de plomo|O|O||D||1
30103511|Núcleo de panal de zinc|O|O||D||1
30103512|Núcleo de panal de titanio|O|O||D||1
30103513|Núcleo de panal de latón|O|O||D||1
30103514|Núcleo de panal de metal no ferroso|O|O||D||1
30103515|Núcleo de panal de metales preciosos|O|O||D||1
30103600|Productos estructurales|O|O||D||1|Solera
30103601|Vigas de madera|O|O||D||1
30103602|Vigas compuestas de madera|O|O||D||1
30103603|Madera para marcos|O|O||D||1
30103604|Revestimiento o láminas de madera|O|O||D||1
30103605|Tablones de madera|O|O||D||1
30103606|Armazones de madera|O|O||D||1|Estructuras de madera
30103607|Viguetas de madera|O|O||D||1
30103608|Postes de madera o postes telefónicos|O|O||D||1
30103609|Tabla de tabique de ventilación|O|O||D||1
30103610|Bloque de soporte en minas|O|O||D||1
30103611|Esteras de troncos|O|O||D||1
30103612|Vínculos de ferrocarril|O|O||D||1
30103613|Elemento prefabricado de hyadita|O|O||D||1
30103614|Vigueta de placa de acero|O|O||D||1
30103615|Viga de placa|O|O||D||1|Vigas planas
30103616|Marco compuesto|O|O||D||1|Marco rígido compuesto
30103617|Marco de madera|O|O||D||1
30103618|Marco de acero|O|O||D||1
30103619|Elemento de concreto prefabricado|O|O||D||1|Elemento prefabricado de hormigón
30103620|Bloque de soporte en minas tratado|O|O||D||1
30103621|Vínculo de ferrocarril no tratado|O|O||D||1
30103622|Troncos cuadrados|O|O||D||1|Madera cuadrada
30103623|Barra o malla de refuerzo|O|O||D||1
30103700|Trenza|O|O||D||1
30103701|Trenza de acero inoxidable|O|O||D||1
30103800|Fibras y filamentos mecánicos|O|O||D||1
30103801|Fibra de acero|O|O||D||1
30103802|Fibra de estaño|O|O||D||1
30103803|Fibra de aluminio|O|O||D||1
30103804|Fibra de aleación|O|O||D||1
30103900|Ejes|O|O||D||1
30103901|Socavón con cabeza|O|O||D||1
30111500|Concreto y morteros|O|O||D||1|Cemento y morteros
30111501|Concreto aireado|O|O||D||1|Cemento aireado
30111502|Concreto conductor|O|O||D||1|Cemento conductivo
30111503|Concreto aislante|O|O||D||1|Cemento aislante
30111504|Morteros|O|O||D||1
30111505|Concreto premezclado|O|O||D||1|Cemento premezclado
30111506|Lechada|O|O||D||1|Mezcla de cemento
30111507|Concreto curado en suelo|O|O||D||1|Suelo cemento
30111508|Concreto permeable al agua|O|O||D||1|Cemento permeable
30111509|Concreto basado en asfalto|O|O||D||1|Hormigón asfáltico
30111600|Cemento y cal|O|O||D||1
30111601|Cemento|O|O||D||1
30111602|Cal clorada|O|O||D||1
30111603|Cal hidráulica|O|O||D||1
30111604|Cal apagada|O|O||D||1
30111605|Cal magra|O|O||D||1
30111607|Cal viva|O|O||D||1
30111700|Yesos|O|O||D||1
30111701|Enlucido de yeso|O|O||D||1|Yeso fino para enlucir
30111800|Agregados|O|O||D||1
30111801|Agregado natural|O|O||D||1
30111802|Agregado artificial|O|O||D||1|Agregados manufacturados
30111900|Elementos para reforzar concreto|O|O||D||1
30111901|Fibra para reforzar concreto|O|O||D||1
30111902|Junta de expansión de construcción|O|O||D||1|Juntas de dilatación de construcción
30111903|Lámina de malla de alambre|O|O||D||1|Armex
30121500|Derivados bituminosos|O|O||D||1|Materiales bituminosos
30121501|Alquitrán de carbón hulla|O|O||D||1
30121503|Creosota|O|O||D||1
30121504|Bitumen|O|O||D||1|Betún
30121600|Asfaltos|O|O||D||1
30121601|Asfalto|O|O||D||1
30121602|Brea|O|O||D||1
30121603|Gilsonita|O|O||D||1
30121604|Residuos de alquitrán o petróleo|O|O||D||1
30121605|Marcos de pozo con tapas del registro|O|O||D||1|Aro y tapa para registro
30121700|Materiales de construcción de caminos y carrileras|O|O||D||1
30121701|Geomalla|O|O||D||1
30121702|Geotextil|O|O||D||1|Geotejido
30121703|Riel de puente|O|O||D||1|Viga carril de puente
30121704|Losa de concreto|O|O||D||1|Forjado
30121705|Losa de pavimento|O|O||D||1
30121706|Borde de concreto|O|O||D||1|Bordillos de hormigón
30121707|Tablero de protección contra el ruido|O|O||D||1
30121708|Baldosa de ladrillo|O|O||D||1|Loseta tipo ladrillo
30121709|Roca triturada sin grado|O|O||D||1
30121710|Piedra de pavimento|O|O||D||1|Piedra pavimentada
30121711|Borde de piedra natural|O|O||D||1
30121712|Cubierta de poste|O|O||D||1|Cubierta para poste
30121713|Tapa de manhole|O|O||D||1|Tapa de alcantarilla, Tapa para registro
30121714|Caja de manhole|O|O||D||1|Caja de registro
30121715|Junta de expansión de puente|O|O||D||1|Juntas de dilatación de puentes
30121716|Montura de asiento de puente|O|O||D||1
30121717|Baranda|O|O||D||1|Barandilla
30121718|Cerca de seguridad y red cara la caída de rocas|O|O||D||1
30121719|Separador de seguridad de calle|O|O||D||1|Barreras de contención
30121800|Materiales de arquitectura paisajística|O|O||D||1
30121801|Rejilla para árbol|O|O||D||1
30121802|Varilla de protección de árbol|O|O||D||1|Protector de árboles de varilla
30121803|Prado artificial|O|O||D||1|Césped artificial
30121900|Materiales para estabilización y refuerzo de suelos|O|O||D||1
30121901|Estabilizador de suelo|O|O||D||1
30131500|Bloques|O|O||D||1
30131502|Bloques de concreto|O|O||D||1|Blocks de concreto
30131503|Bloques de piedra|O|O||D||1
30131504|Bloques de cerámica|O|O||D||1
30131505|Bloques de haydita|O|O||D||1
30131506|Losa de roca natural|O|O||D||1
30131507|Bloque de concreto liviano|O|O||D||1
30131508|Bloque de vidrio|O|O||D||1
30131509|Bloque a prueba de sonido|O|O||D||1|Bloque de absorción acústica de sonido
30131510|Bloque de concreto para revestimiento|O|O||D||1|Bloque de hormigón para revestimiento
30131511|Unidad de concreto de escollera|O|O||D||1|Bloques de concreto para malecón
30131512|Bloque de concreto aireado de peso liviano esterilizado en autoclave|O|O||D||1|Bloque de hormigón celular aireado autoclavado
30131513|Bloque de caucho|O|O||D||1
30131514|Bloque de culvert construido de concreto reforzado|O|O||D||1|Bloque de alcantarilla construido de hormigón armado
30131515|Bloque de madera|O|O||D||1
30131516|Bloque braille|O|O||D||1
30131517|Bloque de adobe|O|O||D||1
30131600|Ladrillos|O|O||D||1
30131602|Ladrillos de cerámica|O|O||D||1
30131603|Ladrillos de concreto|O|O||D||1|Tabicón, Tabique
30131604|Ladrillos de piedra|O|O||D||1
30131605|Ladrillo sílico – calcáreo|O|O||D||1
30131606|Ladrillo de loess|O|O||D||1
30131607|Ladrillo de arcilla|O|O||D||1
30131608|Ladrillo vitrificado con sal|O|O||D||1
30131609|Ladrillo manufacturado|O|O||D||1
30131610|Ladrillo antifuego|O|O||D||1|Ladrillo corta fuego
30131700|Azulejos y baldosas|O|O||D||1
30131702|Losas o baldosas de piedra|O|O||D||1
30131703|Losas o baldosas de concreto|O|O||D||1
30131704|Losas o baldosas de cerámica|O|O||D||1
30131705|Lápidas|O|O||D||1
30131706|Losas o baldosas de metal|O|O||D||1
30141500|Aislamiento térmico|O|O||D||1
30141501|Burletes|O|O||D||1
30141503|Aislamiento de espuma|O|O||D||1
30141505|Revestimiento de aislamiento térmico|O|O||D||1
30141508|Aislamiento de fibra|O|O||D||1|Aislamiento de fibra de vidrio
30141510|Barrido de puerta|O|O||D||1|Sello de barrido de puerta
30141511|Película de ventana|O|O||D||1
30141512|Kits de aislamiento térmico|O|O||D||1
30141513|Ladrillos aislantes térmicos|O|O||D||1
30141514|Aislación de poliestireno expandido eps|O|O||D||1
30141515|Aislación de poliestireno extruido xps|O|O||D||1
30141516|Aislación de lana mineral|O|O||D||1
30141600|Aislamiento especial|O|O||D||1
30141601|Aislación acústica|O|O||D||1
30141603|Escudos térmicas|O|O||D||1
30141604|Aislación por recubrimiento aerosol|O|O||D||1
30141605|Material a prueba de incendios|O|O||D||1|Material de aislamiento resistente al calor
30141700|Capas de sellamiento de aislamiento|O|O||D||1
30141701|Capa sellante de tabla de asfalto|O|O||D||1
30141702|Capa sellante plástica|O|O||D||1
30141703|Capa sellante ce caucho|O|O||D||1|Capa sellante de caucho
30151500|Material para tejados y techos|O|O||D||1
30151501|Techado prearmado|O|O||D||1|Techos de rollo
30151502|Valles de techo|O|O||D||1
30151503|Textiles de techado|O|O||D||1
30151505|Membranas para techos|O|O||D||1
30151507|Huelgos|O|O||D||1
30151508|Tejas de asfalto|O|O||D||1
30151509|Armazones|O|O||D||1|Bloque de soporte de goma
30151510|Tejados de pizarra|O|O||D||1
30151511|Tejas de concreto|O|O||D||1
30151512|Tejas de ladrillo|O|O||D||1
30151513|Tejas de cerámica|O|O||D||1
30151514|Tejas metálicas|O|O||D||1
30151515|Tejas de madera|O|O||D||1
30151600|Accesorios para tejados|O|O||D||1
30151601|Plafones de tejado|O|O||D||1
30151602|Planchas de escurrimiento|O|O||D||1
30151603|Parada de grava|O|O||D||1
30151605|Drenajes de tejados|O|O||D||1
30151607|Claraboyas de ventilación|O|O||D||1|Tragaluces de ventilación
30151608|Sofitos|O|O||D||1
30151609|Bordes de tejado|O|O||D||1|Bordillos de techo
30151610|Escarificadores de tejado|O|O||D||1
30151700|Canalones de tejado y accesorios|O|O||D||1
30151701|Boquillas de bajantes|O|O||D||1
30151702|Dinteles para goteo|O|O||D||1|Tapones de goteo
30151703|Canaletas|O|O||D||1
30151704|Bloques contra salpicaduras|O|O||D||1|Remates contra el agua
30151800|Materiales para revestimiento de paredes y exterior|O|O||D||1
30151801|Postigos|O|O||D||1|Contraventana
30151802|Recubrimiento|O|O||D||1
30151803|Empalmes de revestimiento de paredes|O|O||D||1
30151805|Estucado|O|O||D||1
30151806|Muros de bloque de vidrio|O|O||D||1
30151807|Materiales para terminados exteriores|O|O||D||1
30151808|Molde de ladrillo|O|O||D||1
30151900|Materiales y productos para acabados|O|O||D||1
30151901|Toldos|O|O||D||1|Cubierta de lona
30151902|Marquesinas|O|O||D||1
30152000|Cercado|O|O||D||1
30152001|Cercado de metal|O|O||D||1
30152002|Cercado de madera|O|O||D||1
30152003|Vallado de fibrocemento|O|O||D||1
30152100|Superficie|O|O||D||1
30152101|Acero de perdigones|O|O||D||1
30161500|Materiales para acabados de paredes|O|O||D||1
30161501|Fibra prensada|O|O||D||1|Fibra de madera prensada
30161502|Papel de colgadura|O|O||D||1|Papel tapiz
30161503|Drywall|O|O||D||1|Tablaroca
30161504|Protectores de esquinas|O|O||D||1
30161505|Paneles o empanelado|O|O||D||1
30161508|Rodillo de papel de colgadura|O|O||D||1|Rodillo de papel tapiz
30161509|Tabla de yeso|O|O||D||1
30161510|Cobertura de pared plástica|O|O||D||1|Revestimiento de pared de plástico
30161511|Tela de pared|O|O||D||1|Tejidos para pared
30161600|Materiales para techos|O|O||D||1
30161601|Baldosines acústicos para techos|O|O||D||1|Azulejos de techo acústicos
30161602|Paneles para techos|O|O||D||1|Lamina panel para techo
30161603|Encofrados|O|O||D||1
30161604|Sistemas de cielo raso|O|O||D||1
30161700|Suelos|O|O||D||1
30161701|Alfombrado|O|O||D||1
30161702|Pisos de madera|O|O||D||1
30161703|Linóleo|O|O||D||1
30161705|Pisos de caucho|O|O||D||1
30161706|Pisos de baldosa o piedra|O|O||D||1
30161707|Pisos de vinilo|O|O||D||1
30161708|Alfombras de nudos|O|O||D||1
30161709|Alfombras de penachos|O|O||D||1
30161710|Pisos laminados|O|O||D||1
30161711|Alfombras para exteriores|O|O||D||1
30161712|Perfiles laminados para suelos|O|O||D||1
30161713|Almohadilla para alfombras|O|O||D||1
30161714|Suelo de corcho|O|O||D||1
30161715|Enrejados de madera|O|O||D||1
30161717|Pisos para accesos|O|O||D||1
30161718|Piso de acero antideslizante|O|O||D||1
30161719|Fieltro para alfombras|O|O||D||1
30161720|Panel de piso|O|O||D||1
30161721|Umbral de piso|O|O||D||1
30161800|Ebanistería|O|O||D||1
30161801|Armarios|O|O||D||1
30161803|Armarios domésticos|O|O||D||1
30161804|Armarios de escuela|O|O||D||1
30161805|Armarios de laboratorio|O|O||D||1
30161806|Closet|O|O||D||1
30161807|Cajón|O|O||D||1
30161808|Ensamble para deslizamiento del cajón|O|O||D||1
30161809|Almohadillas contra cierre brusco|O|O||D||1
30161810|Gabinete tri – view|O|O||D||1
30161900|Moldeado y carpintería mecánica|O|O||D||1
30161901|Puertas de rejilla|O|O||D||1
30161902|Columnas|O|O||D||1
30161903|Paneles de madera|O|O||D||1
30161904|Cornisas|O|O||D||1
30161905|Cercos de puertas|O|O||D||1
30161906|Moldes|O|O||D||1
30161908|Piezas de escaleras|O|O||D||1
30162000|Molduras y carpintería|O|O||D||1
30162001|Laminado de alta presión|O|O||D||1
30162002|Laminado especial|O|O||D||1
30162003|Laminado de metal|O|O||D||1
30162004|Laminado de reborde|O|O||D||1
30162005|Lámina térmica rígida o rtf|O|O||D||1
30162100|Laminados interiores|O|O||D||1
30162101|Escaleras de acero|O|O||D||1
30162102|Escaleras de madera|O|O||D||1
30162103|Escaleras de concreto|O|O||D||1
30162104|Arista del escalón|O|O||D||1|Escalón
30162200|Mostradores|O|O||D||1
30162201|Mesón laminado|O|O||D||1|Mesón de cocina laminado
30162202|Mesón de mármol cultivado|O|O||D||1|Mesón de cocina de mármol cultivado
30162203|Mesón de superficie sólida|O|O||D||1|Masón de cocina de superficie sólida
30162204|Mesón de granito|O|O||D||1|Masón de cocina de granito
30162300|Accesorios para gabinetes|O|O||D||1
30162301|Piezas o ensamble de “lazy susan”|O|O||D||1
30162302|Engaste de rejilla o cajón para condimentos|O|O||D||1
30162303|Piezas o ensamble de caneca de la basura de sacar|O|O||D||1|Piezas para contenedor de basura
30162304|Piezas o ensamble de despensa|O|O||D||1|Accesorios para muebles de despensa
30162305|Piezas o ensamble de bandeja de inclinar|O|O||D||1|Piezas para cajón de inclinación hacia afuera
30162306|Piezas o ensamble de montura de puerta o toalla deslizable|O|O||D||1
30162307|Piezas o ensamble de ancheta de sacar o voltear|O|O||D||1
30162308|Tapa o ensamble de caja para el pan|O|O||D||1
30162309|Estante para copas|O|O||D||1
30162310|Bandera rodante|O|O||D||1|Cajón deslizable para bajo mesa
30162311|Recipiente de almacenamiento de deslizar o su ensamble|O|O||D||1
30162400|Muros divisorios|O|O||D||1
30162401|Pared plegable|O|O||D||1
30162402|Pantalla o biombo o cubículo|O|O||D||1
30162403|Sistema de pared interior|O|O||D||1
30162404|Pared de cuarto frío|O|O||D||1|Pared de almacenamiento en frio
30171500|Puertas|O|O||D||1
30171501|Puertas de cristal|O|O||D||1
30171502|Puertas de pantalla|O|O||D||1
30171503|Puertas rodantes|O|O||D||1
30171504|Puertas de madera|O|O||D||1
30171505|Puertas de metal|O|O||D||1
30171506|Contrapuertas|O|O||D||1
30171507|Marcos de puertas o quicios|O|O||D||1
30171508|Puertas corrediza empotrable|O|O||D||1
30171509|Puertas giratorias|O|O||D||1
30171510|Puertas automáticas|O|O||D||1
30171511|Puerta de vaivén|O|O||D||1
30171512|Abridores de puertas|O|O||D||1|Puerta con brazo hidráulico
30171513|Rodapiés|O|O||D||1|Placa de puerta o protector
30171514|Cerradores de puertas|O|O||D||1|Brazo hidráulico
30171515|Puerta de inspección|O|O||D||1
30171516|Pantalla para puertas|O|O||D||1
30171517|Puertas a prueba de sonido|O|O||D||1|Puertas aislantes de sonido
30171518|Puertas imperfectas|O|O||D||1
30171519|Puertas anti – explosión|O|O||D||1
30171520|Loop de puerta y ventana|O|O||D||1
30171521|Puerta hermética contra agua|O|O||D||1|Puerta contra inundación
30171522|Puerta hermética sin circulación de aire|O|O||D||1
30171523|Puerta de escape de incendio|O|O||D||1
30171524|Puerta de protección contra rayos|O|O||D||1
30171525|Puerta de presión|O|O||D||1
30171526|Puerta plegable|O|O||D||1
30171600|Ventanas|O|O||D||1
30171604|Ventanas de guillotina|O|O||D||1
30171605|Ventanas de apertura horizontal|O|O||D||1
30171606|Ventanas giratorias|O|O||D||1
30171607|Ventanas con hoja de desplazamiento horizontal|O|O||D||1
30171608|Ventanas basculantes o de montante|O|O||D||1|Ventanas de inclinación o travesaño
30171609|Ventanas fijas|O|O||D||1
30171610|Miradores|O|O||D||1|Ventanas de bahía
30171611|Ventana de miradores|O|O||D||1|Ventanas de arco
30171612|Ventanas salientes|O|O||D||1|Ventanas proyectadas
30171613|Paredes de vidrio|O|O||D||1|Cancelería, Canceles
30171614|Pantallas de ventana|O|O||D||1|Película protectora para cristales de ventana
30171615|Ventanas francesas o puerta – ventanas|O|O||D||1
30171700|Productos de cristal|O|O||D||1
30171701|Adoquines|O|O||D||1
30171703|Vidrio biselado|O|O||D||1
30171704|Vidrio con plomo|O|O||D||1
30171705|Vidrio laminado|O|O||D||1
30171706|Vidrio templado|O|O||D||1
30171707|Vidrio de seguridad|O|O||D||1
30171708|Vidrio flotado|O|O||D||1
30171709|Vidrio con alambre incrustado|O|O||D||1|Vidrio armado
30171710|Vidrio de aislación|O|O||D||1
30171711|Vidrio corrugado|O|O||D||1
30171712|Vitrales|O|O||D||1
30171800|Claraboyas|O|O||D||1|Tragaluces
30171801|Claraboyas fijas|O|O||D||1|Tragaluz fijo
30171802|Claraboyas con ventilación|O|O||D||1|Tragaluz con ventilación
30171803|Claraboyas de tubo|O|O||D||1|Tragaluz tubular
30171804|Tapa de humo|O|O||D||1
30171900|Marcos de ventanas|O|O||D||1
30171901|Marcos para ventanas de guillotina|O|O||D||1
30171902|Marcos para ventanas de apertura horizontal|O|O||D||1
30171903|Marcos para ventanas giratorias|O|O||D||1
30171904|Marcos para ventanas con hojas de desplazamiento horizontal|O|O||D||1
30171905|Marcos para ventanas basculantes o de montante|O|O||D||1|Marcos de ventana de inclinación o travesaño
30171906|Marcos para ventanas fijas|O|O||D||1
30171907|Alfeizar o antepecho|O|O||D||1|Travesaño de ventana
30171908|Arco de ventana|O|O||D||1
30172000|Puertas|O|O||D||1
30172001|Puerta de barra sencilla|O|O||D||1|Puerta de una sola barra
30172002|Puerta de doble barra|O|O||D||1|Puerta de doble barra
30172100|Puertas para garaje y operadores|O|O||D||1
30172101|Puerta de garaje pan|O|O||D||1
30172102|Puerta de garaje en sándwich aislada|O|O||D||1|Puerta de garaje de panel sándwich
30172103|Puerta de garaje de madera|O|O||D||1
30172104|Puerta de garaje de carroza|O|O||D||1|Puerta de garaje de carro
30172105|Puerta de garaje de pantalla|O|O||D||1
30172106|Puerta de garaje de de pvc|O|O||D||1
30172107|Puerta de garaje de eslabones de cadena|O|O||D||1
30172108|Puerta de garaje rodante|O|O||D||1
30172109|Componente de puerta de garaje|O|O||D||1
30172110|Accesorio de puerta de garaje|O|O||D||1
30172111|Operador completo de puerta de garaje|O|O||D||1
30172112|Componente de operador de puerta de garaje|O|O||D||1
30172113|Accesorio de operador de puerta de garaje|O|O||D||1
30181500|Porcelana sanitaria|O|O||D||1
30181501|Tinas o bañeras|O|O||D||1
30181502|Bidés|O|O||D||1|Bidet
30181503|Duchas|O|O||D||1|Regadera
30181504|Lavamanos|O|O||D||1|Lavabo
30181505|Inodoros o excusados|O|O||D||1|Cuarto de baño
30181506|Orinales|O|O||D||1
30181507|Cerramientos para bañeras o duchas|O|O||D||1|Bañera
30181508|Divisiones de baños|O|O||D||1
30181511|Inodoros o excusados|O|O||D||1
30181514|Tapa de tanque del inodoro|O|O||D||1
30181515|Tanque del inodoro|O|O||D||1
30181516|Sauna|O|O||D||1
30181517|Jacuzzi|O|O||D||1
30181600|Instalaciones residenciales no sanitarias|O|O||D||1|Accesorios para cuarto de baño
30181601|Jabonera|O|O||D||1
30181602|Toallero|O|O||D||1
30181603|Bizcocho o asiento del inodoro|O|O||D||1|Asiento de inodoro
30181604|Tapa del bizcocho|O|O||D||1|Tapa de inodoro
30181605|Desagüe|O|O||D||1
30181606|Ganchos de baño|O|O||D||1
30181607|Cortina de baño o su ensamble|O|O||D||1
30181608|Varilla de ducha|O|O||D||1
30181609|Soporte para frascos de ducha|O|O||D||1
30181610|Soporte de  papel higiénico|O|O||D||1
30181611|Soporte de cepillos de dientes o vaso|O|O||D||1
30181612|Gancho para la máquina afeitadora|O|O||D||1
30181613|Faldón de la tina o del jacuzzi|O|O||D||1
30181614|Dispensador de jabón|O|O||D||1
30181700|Grifos|O|O||D||1|Llaves
30181701|Llave de registro|O|O||D||1|Fregadero, Llave de paso, Tarj
30181800|Cabezas, chorros y partes y accesorios de grifos y duchas|O|O||D||1|Grifería y cabezales de ducha, chorros y piezas y accesorios
30181801|Pomo de ducha|O|O||D||1|Regadera
30181802|Aireador de la ducha|O|O||D||1|Filtro aireador para regadera
30181803|Ducha teléfono|O|O||D||1|Regadera de extensión manual
30181804|Grifo|O|O||D||1|Llaves para regadera
30181805|Ducha combinada fija y teléfono|O|O||D||1|Sistema de regadera mixta
30181806|Chorros|O|O||D||1|Bañera de hidromasaje
30181807|Boquilla|O|O||D||1|Tubo de bañera con desviador
30181808|Válvulas ocultas|O|O||D||1|Válvulas para regaderas
30181809|Kit de reparación de duchas teléfono|O|O||D||1|Juego de reparación para ducha manual
30181810|Ajuste de grifo|O|O||D||1
30181811|Kit de reparación de grifo|O|O||D||1
30181812|Rociador de cuerpo|O|O||D||1|Regaderas corporales
30191500|Escaleras y andamios|O|O||D||1
30191501|Escaleras|O|O||D||1
30191502|Andamios|O|O||D||1
30191505|Taburete escalonado|O|O||D||1|Banquillo
30191506|Escalón de plataforma|O|O||D||1|Escaleras de plataforma
30191507|Escalera de combinación|O|O||D||1|Escalera combinada extensible
30191508|Escalera de techo|O|O||D||1|Escaleras plegables para techo
30191509|Escalera de escape de incendios|O|O||D||1|Escalera de escape contra incendios
30191510|Escalera de extinguidor de incendios|O|O||D||1|Escalera para sofocar incendios
30191600|Escaleras y accesorios de andamiaje|O|O||D||1
30191601|Barandas|O|O||D||1|Barandilla
30191602|Estabilizadores de andamiaje|O|O||D||1
30191603|Piso del andamiaje|O|O||D||1
30191604|Varillas cruzadas del andamio|O|O||D||1
30191605|Marco del andamio|O|O||D||1
30191606|Escalera del andamio|O|O||D||1
30191607|Contrapeso del andamio|O|O||D||1
30191608|Ménsula del andamio|O|O||D||1
30191609|Plataforma del andamio|O|O||D||1
30191610|Pescante del andamio|O|O||D||1
30191611|Dispositivo de fijación del andamio|O|O||D||1
30191612|Cuerda de alambre del andamio|O|O||D||1
30191613|Plataforma de la escalera|O|O||D||1
30191614|Bandeja de la escalera|O|O||D||1
30191615|Descanso de la escalera|O|O||D||1
30191616|Red de seguridad de construcción|O|O||D||1
30191617|Cerramiento de seguridad de la construcción|O|O||D||1
30191700|Cobertizos y remolques de construcción|O|O||D||1
30191701|Caseta de construcción|O|O||D||1
30191702|Tráiler de construcción|O|O||D||1
30191800|Equipos y materiales para construcciones temporales y apoyo al mantenimiento|O|O||D||1
30191801|Formaleta estructural|O|O||D||1
30191802|Accesorio de formaleta estructural|O|O||D||1
30191803|Espaciador estructural|O|O||D||1
30241500|Componentes de consolidación de estructuras portátiles|O|O||D||1
30241501|Conector de marcos de tubos|O|O||D||1
30241502|Placa de anclaje|O|O||D||1
30241503|Anillo de soporte|O|O||D||1
30241504|Placa base|O|O||D||1
30241505|Cúpula|O|O||D||1
30241506|Campana funicular|O|O||D||1
30241507|Aguilón|O|O||D||1
30241508|Poste grúa y accesorios|O|O||D||1
30241509|Sección de mástil y poste rey|O|O||D||1
30241510|Poste lateral|O|O||D||1
30241511|Estaca o clavija|O|O||D||1
30241512|Travesaño|O|O||D||1
30241513|Marco en a de acero|O|O||D||1
30241514|Sujetador estructural|O|O||D||1
30241515|Herramienta de alineación estructural|O|O||D||1
30241600|Componentes estructurales de tribunas, gradas y escalera|O|O||D||1
30241601|Tarima y accesorios de la tribuna|O|O||D||1
30241602|Escalón|O|O||D||1
30241603|Durmiente|O|O||D||1
30241604|Elevador de escalones|O|O||D||1
30241700|Componentes soporte y cobertura de tiendas, carpas y estructuras de membrana|O|O||D||1
30241701|Viga o riel o tubería de marco|O|O||D||1
30241702|Sección de lienzo de estructura portátil|O|O||D||1
30251500|Estructuras de soporte de techos bajo tierra|O|O||D||1
30251501|Perno y armazón de combinación de techo|O|O||D||1
30251502|Placa de techo|O|O||D||1
30251503|Cápsula o cartucho de resina adhesiva|O|O||D||1
30251504|Celda de expansión|O|O||D||1
30251505|Estera de nervadura|O|O||D||1
30261500|Barras de latón|O|O||D||1
30261501|Barra de latón enrollado en caliente c 360|O|O||D||1
30261502|Barra de latón forjado en caliente c 360|O|O||D||1
30261503|Barra de latón enrollado en caliente c 464|O|O||D||1
30261504|Barra de latón forjado en caliente c 464|O|O||D||1
30261505|Barra de latón estirado en frío c 464|O|O||D||1
30261600|Láminas de latón|O|O||D||1
30261601|Lámina de latón enrollado en caliente c 360|O|O||D||1
30261602|Lámina de latón forjado en caliente c 464|O|O||D||1
30261603|Lámina de latón enrollado en frío c 464|O|O||D||1
30261700|Lingotes, bandas, palanquillas y alambres de latón|O|O||D||1
30261701|Alambre de latón|O|O||D||1
30261702|Banda de latón|O|O||D||1
30261703|Palanquilla de latón|O|O||D||1
30261704|Lingote de latón|O|O||D||1
30261800|Barras y láminas de magnesio|O|O||D||1
30261801|Barra de magnesio extruida|O|O||D||1
30261802|Lámina de magnesio enrollada en frío|O|O||D||1
30261900|Lingotes, bandas, palanquillas y alambres de magnesio|O|O||D||1
30261901|Alambre de magnesio|O|O||D||1
30261902|Banda de magnesio|O|O||D||1
30261903|Palanquilla de magnesio|O|O||D||1
30261904|Lingote de magnesio|O|O||D||1
30262000|Barras y láminas de titanio|O|O||D||1
30262001|Barra de titanio fundida|O|O||D||1
30262002|Lámina de titanio enrollada en caliente|O|O||D||1
30262100|Lingotes, bandas, palanquillas y alambres de titanio|O|O||D||1
30262101|Alambre de titanio|O|O||D||1
30262102|Banda de titanio|O|O||D||1
30262103|Palanquilla de titanio|O|O||D||1
30262104|Lingote de titanio|O|O||D||1
30262200|Barras de cobre|O|O||D||1
30262201|Barra de cobre estirada en frío|O|O||D||1
30262202|Barra de cobre enrollada en caliente|O|O||D||1
30262300|Láminas de cobre|O|O||D||1
30262301|Lámina de cobre enrollada en caliente|O|O||D||1
30262302|Lámina de cobre enrollada en frío|O|O||D||1
30262400|Lingotes, bandas, palanquillas y alambres de cobre|O|O||D||1
30262401|Alambre de cobre|O|O||D||1
30262402|Banda de cobre enrollada en caliente|O|O||D||1
30262403|Banda de cobre enrollada en frío|O|O||D||1
30262404|Palanquilla de cobre|O|O||D||1
30262405|Lingote de cobre|O|O||D||1
30262500|Barras de bronce|O|O||D||1
30262501|Barra de bronce fósforo enrollada en caliente|O|O||D||1
30262502|Barra de bronce fósforo enrollada en frío|O|O||D||1
30262503|Barra de bronce aluminio enrollada en caliente|O|O||D||1
30262504|Barra de bronce aluminio estirada en frío|O|O||D||1
30262505|Barra de bronce silicona enrollada en caliente|O|O||D||1
30262506|Barra de bronce silicona estirada en frío|O|O||D||1
30262600|Láminas de bronce|O|O||D||1
30262601|Lámina de bronce fósforo enrollada en caliente|O|O||D||1
30262602|Lámina de bronce fósforo enrollada en frío|O|O||D||1
30262603|Lámina de bronce aluminio enrollada en caliente|O|O||D||1
30262604|Lámina de bronce aluminio estirada en frío|O|O||D||1
30262605|Lámina de bronce silicona enrollada en caliente|O|O||D||1
30262606|Lámina de bronce silicona estirada en frío|O|O||D||1
30262700|Lingotes, bandas, palanquillas y alambres de bronce|O|O||D||1
30262701|Rollo de alambre de bronce|O|O||D||1
30262702|Banda de bronce|O|O||D||1
30262703|Palanquilla de bronce|O|O||D||1
30262704|Lingote de bronce|O|O||D||1
30262800|Barras y láminas de zinc|O|O||D||1
30262801|Barra de zinc enrollada en caliente|O|O||D||1
30262802|Lámina de zinc enrollada en caliente|O|O||D||1
30262900|Lingotes, bandas, palanquillas y alambres de zinc|O|O||D||1
30262901|Alambre de zinc|O|O||D||1
30262902|Banda de zinc|O|O||D||1
30262903|Palanquilla de zinc|O|O||D||1
30262904|Lingote de zinc|O|O||D||1
30263000|Barras de estaño|O|O||D||1
30263001|Barra de estaño estirada en frío|O|O||D||1
30263002|Barra de estaño enrollada en caliente|O|O||D||1
30263100|Láminas de estaño|O|O||D||1
30263101|Lámina de estaño enrollada en caliente|O|O||D||1
30263102|Lámina de estaño enrollada en frío|O|O||D||1
30263200|Lingotes, bandas, palanquillas y alambres de estaño|O|O||D||1
30263201|Alambre de estaño|O|O||D||1
30263202|Banda de estaño|O|O||D||1
30263203|Lingote de estaño|O|O||D||1
30263300|Barras de plomo|O|O||D||1
30263301|Barra de plomo extruido|O|O||D||1
30263302|Barra de plomo enrollada en caliente|O|O||D||1
30263303|Barra de plomo estirada en frío|O|O||D||1
30263400|Láminas de plomo|O|O||D||1
30263401|Lámina de plomo enrollada en caliente|O|O||D||1
30263402|Lámina de plomo enrollada en frío|O|O||D||1
30263500|Lingotes, bandas, palanquillas y alambres de plomo|O|O||D||1
30263501|Alambre de plomo|O|O||D||1
30263502|Banda de plomo|O|O||D||1
30263503|Palanquilla de plomo|O|O||D||1
30263504|Lingote de plomo|O|O||D||1
30263600|Barras de acero al carbón|O|O||D||1
30263601|Barra de acero al carbón serie sae 1000 estirada en frío|O|O||D||1
30263602|Barra de acero al carbón serie sae 1100 estirada en frío|O|O||D||1
30263603|Barra de acero al carbón serie sae 1200 estirada en frío|O|O||D||1
30263604|Barra de acero al carbón serie sae 1500 estirada en frío|O|O||D||1
30263605|Barra de acero al carbón serie sae 1000 enrollada en caliente|O|O||D||1
30263606|Barra de acero al carbón serie sae 1100 enrollada en caliente|O|O||D||1
30263607|Barra de acero al carbón serie sae 1200 enrollada en caliente|O|O||D||1
30263608|Barra de acero al carbón serie sae 1500 enrollada en caliente|O|O||D||1
30263700|Barras de aleación de acero|O|O||D||1
30263701|Barra de aleación de acero  serie sae 4000 estirada en frío|O|O||D||1
30263702|Barra de aleación de acero  serie sae 5000 estirada en frío|O|O||D||1
30263703|Barra de aleación de acero  serie sae 6000 estirada en frío|O|O||D||1
30263704|Barra de aleación de acero  serie sae 8000 estirada en frío|O|O||D||1
30263705|Barra de aleación de acero  serie sae 9000 estirada en frío|O|O||D||1
30263706|Barra de aleación de acero  serie sae 4000 enrollada en caliente|O|O||D||1
30263707|Barra de aleación de acero  serie sae 5000 enrollada en caliente|O|O||D||1
30263708|Barra de aleación de acero  serie sae 6000 enrollada en caliente|O|O||D||1
30263709|Barra de aleación de acero  serie sae 8000 enrollada en caliente|O|O||D||1
30263710|Barra de aleación de acero  serie sae 9000 enrollada en caliente|O|O||D||1
30263800|Barras de acero de herramienta|O|O||D||1|Barras de acero para herramientas
30263801|Barra de acero de herramienta estirada en frío|O|O||D||1
30263802|Barra de acero de herramienta enrollada en caliente|O|O||D||1
30263900|Barras de acero especial|O|O||D||1
30263901|Barra de acero de alta resistencia baja aleación hsla enrollada en caliente|O|O||D||1|Barra de acero laminado en caliente de alta resistencia y baja aleación HSLA
30264000|Láminas de acero al carbón|O|O||D||1|Hojas de acero al carbono
30264001|Lámina de acero al carbón serie sae 1000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1000
30264002|Lámina de acero al carbón serie sae 1100 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1100
30264003|Lámina de acero al carbón serie sae 1200 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1200
30264004|Lámina de acero al carbón serie sae 1500 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1500
30264005|Lámina de acero al carbón electro galvanizada serie sae 1000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1000 galvanizada
30264006|Lámina de acero al carbón electro galvanizada serie sae 1100 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1100 galvanizada
30264007|Lámina de acero al carbón electro galvanizada serie sae 1200 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1200 galvanizada
30264008|Lámina de acero al carbón electro galvanizada serie sae 1500 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1500 galvanizada
30264009|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1000 galvanizada en caliente
30264010|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1100 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1100 galvanizada en caliente
30264011|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1200 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1200 galvanizada en caliente
30264012|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1500 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de acero al carbono SAE 1500 galvanizada en caliente
30264013|Lámina de acero al carbón serie sae 1000 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1000
30264014|Lámina de acero al carbón serie sae 1100 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1100
30264015|Lámina de acero al carbón serie sae 1200 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1200
30264016|Lámina de acero al carbón serie sae 1500 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1500
30264017|Lámina de acero al carbón electro galvanizada serie sae 1000 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1000 galvanizada
30264018|Lámina de acero al carbón electro galvanizada serie sae 1100 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1100 galvanizada
30264019|Lámina de acero al carbón electro galvanizada serie sae 1200 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1200 galvanizada
30264020|Lámina de acero al carbón electro galvanizada serie sae 1500 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1500 galvanizada
30264021|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1000 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1000 galvanizada en caliente
30264022|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1100 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1100 galvanizada en caliente
30264023|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1200 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1200 galvanizada en caliente
30264024|Lámina de acero al carbón inmersión en caliente galvanizada serie sae 1500 enrollada en frío|O|O||D||1|Hoja laminada en frío de acero al carbono SAE 1500 galvanizada en caliente
30264100|Láminas de aleación de acero|O|O||D||1|Hojas de aleación de acero
30264101|Lámina de aleación de acero al carbón serie sae 4000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de aleación de acero SAE 4000
30264102|Lámina de aleación de acero al carbón serie sae 5000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de aleación de acero SAE 5000
30264103|Lámina de aleación de acero al carbón serie sae 6000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de aleación de acero SAE 6000
30264104|Lámina de aleación de acero al carbón serie sae 8000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de aleación de acero SAE 8000
30264105|Lámina de aleación de acero al carbón serie sae 9000 enrollada en caliente|O|O||D||1|Hoja laminada en caliente de aleación de acero SAE 9000
30264106|Lámina de aleación de acero al carbón serie sae 4000 enrollada en frío|O|O||D||1|Hoja laminada en frío de aleación de acero SAE 4000
30264107|Lámina de aleación de acero al carbón serie sae 5000 enrollada en frío|O|O||D||1|Hoja laminada en frío de aleación de acero SAE 5000
30264108|Lámina de aleación de acero al carbón serie sae 6000 enrollada en frío|O|O||D||1|Hoja laminada en frío de aleación de acero SAE 6000
30264109|Lámina de aleación de acero al carbón serie sae 8000 enrollada en frío|O|O||D||1|Hoja laminada en frío de aleación de acero SAE 8000
30264110|Lámina de aleación de acero al carbón serie sae 9000 enrollada en frío|O|O||D||1|Hoja laminada en frío de aleación de acero SAE 9000
30264200|Láminas de acero de herramienta|O|O||D||1
30264201|Lámina de acero de alta resistencia baja aleación hsla enrollada en caliente|O|O||D||1|Hoja laminada en caliente de alta resistencia de acero de baja aleación HSLA
30264202|Lámina de acero de alta resistencia baja aleación hsla enrollada en frío|O|O||D||1|Hoja laminada en frío HSLA de baja resistencia
30264203|Lámina de acero aluminizado|O|O||D||1|Hoja de acero aluminizado
30264204|Lámina de acero corrugada|O|O||D||1|Hoja de acero corrugado
30264300|Láminas de acero especial|O|O||D||1|Hojas de acero especial
30264301|Alambre de acero perforado|O|O||D||1|Rollo de acero perforado
30264302|Alambre de acero embebido|O|O||D||1|Rollo de acero en relieve
30264303|Alambre de acero aluminizado|O|O||D||1|Rollo de acero aluminizado
30264304|Alambre de acero inmersión en caliente galvanizado|O|O||D||1|Rollo de acero galvanizado en caliente
30264305|Alambre de acero electro galvanizado|O|O||D||1|Rollo de acero electro galvanizado
30264400|Lingotes, bandas, palanquillas y alambres de al carbón|O|O||D||1|Alambre al carbón laminado en caliente sin tratamiento, Alambre de púas, Alambre recocido, Alambrón ,
30264401|Alambre de acero al carbón serie sae 1100 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1100
30264402|Alambre de acero al carbón serie sae 1200 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1200
30264403|Alambre de acero al carbón serie sae 1500 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1500
30264404|Banda de acero al carbón serie sae 1100 enrollada en frío|O|O||D||1|Rollo laminado en frío de acero al carbono SAE 1100
30264405|Banda de acero al carbón serie sae 1200 enrollada en frío|O|O||D||1|Rollo laminado en frío de acero al carbono SAE 1200
30264406|Banda de acero al carbón serie sae 1500 enrollada en frío|O|O||D||1|Rollo laminado en frío de acero al carbono SAE 1500
30264407|Banda de acero al carbón serie sae 1100 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1100
30264408|Banda de acero al carbón serie sae 1200 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1200
30264409|Banda de acero al carbón serie sae 1500 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero al carbono SAE 1500
30264410|Palanquilla de acero al carbón enrollado en caliente|O|O||D||1|Palanquilla laminada en caliente de acero al carbono
30264411|Palanquilla de acero al carbón enrollado en frío|O|O||D||1|Palanquilla laminada en frío de acero al carbono
30264412|Lingote de acero al carbón enrollado en caliente|O|O||D||1|Lingote de acero al carbono laminado en caliente
30264413|Lingote de acero al carbón enrollado en frío|O|O||D||1|Lingote laminado en frío de acero al carbono
30264500|Barras de acero inoxidable|O|O||D||1
30264501|Barra de acero inoxidable serie sae 200 estirada en frío|O|O||D||1
30264502|Barra de acero inoxidable serie sae 300 estirada en frío|O|O||D||1
30264503|Barra de acero inoxidable serie sae 400 estirada en frío|O|O||D||1
30264504|Barra de acero inoxidable serie sae 200 enrollada en caliente|O|O||D||1
30264505|Barra de acero inoxidable serie sae 300 enrollada en caliente|O|O||D||1
30264506|Barra de acero inoxidable serie sae 400 enrollada en caliente|O|O||D||1
30264600|Láminas de acero inoxidable|O|O||D||1|Hojas de acero inoxidable
30264601|Lámina de acero inoxidable serie sae 200 enrollada en caliente|O|O||D||1|Hojas de acero inoxidable laminada en caliente serie sae 200
30264602|Lámina de acero inoxidable serie sae 300 enrollada en caliente|O|O||D||1|Hojas de acero inoxidable laminada en caliente serie sae 300
30264603|Lámina de acero inoxidable serie sae 400 enrollada en caliente|O|O||D||1|Hojas de acero inoxidable laminada en caliente serie sae 400
30264604|Lámina de acero inoxidable serie sae 200 enrollada en frío|O|O||D||1|Hojas de acero inoxidable laminada en frío SAE 200
30264605|Lámina de acero inoxidable serie sae 300 enrollada en frío|O|O||D||1|Hojas de acero inoxidable laminada en frío SAE 300
30264606|Lámina de acero inoxidable serie sae 400 enrollada en frío|O|O||D||1|Hojas de acero inoxidable laminada en frío SAE 400
30264700|Alambre de acero inoxidable|O|O||D||1
30264701|Alambre de acero inoxidable serie sae 300 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero inoxidable SAE 300
30264702|Alambre de acero inoxidable serie sae 400 enrollada en caliente|O|O||D||1|Rollo laminado en caliente de acero inoxidable SAE 400
30264703|Alambre de acero inoxidable serie sae 200 enrollada en frío|O|O||D||1|Rollo laminada en frío de acero inoxidable SAE 200
30264704|Alambre de acero inoxidable serie sae 300 enrollada en frío|O|O||D||1|Rollo laminada en frío de acero inoxidable SAE 300
30264705|Alambre de acero inoxidable serie sae 400 enrollada en frío|O|O||D||1|Rollo laminada en frío de acero inoxidable SAE 400
30264800|Bandas de acero inoxidable|O|O||D||1|Tiras de acero inoxidable
30264801|Banda de acero inoxidable serie sae 200 enrollada en caliente|O|O||D||1|Tira laminada en caliente de acero inoxidable SAE 200
30264802|Banda de acero inoxidable serie sae 300 enrollada en caliente|O|O||D||1|Tira laminada en caliente de acero inoxidable SAE 300
30264803|Banda de acero inoxidable serie sae 400 enrollada en caliente|O|O||D||1|Tira laminada en caliente de acero inoxidable SAE 400
30264804|Banda de acero inoxidable serie sae 200 enrollada en frío|O|O||D||1|Tira laminada en frío de acero inoxidable SAE 200
30264805|Banda de acero inoxidable serie sae 300 enrollada en frío|O|O||D||1|Tira laminada en frío de acero inoxidable SAE 300
30264806|Banda de acero inoxidable serie sae 400 enrollada en frío|O|O||D||1|Tira laminada en frío de acero inoxidable SAE 400
30264900|Barras de aluminio|O|O||D||1
30264901|Barra de aluminio serie sae 1000 estirada en frío|O|O||D||1
30264902|Barra de aluminio serie sae 1000 enrollada en caliente|O|O||D||1
30264903|Barra de aluminio serie sae 2000 estirada en frío|O|O||D||1
30264904|Barra de aluminio serie sae 2000 enrollada en caliente|O|O||D||1
30264905|Barra de aluminio serie sae 3000 estirada en frío|O|O||D||1
30264906|Barra de aluminio serie sae 3000 enrollada en caliente|O|O||D||1
30264907|Barra de aluminio serie sae 4000 estirada en frío|O|O||D||1
30264908|Barra de aluminio serie sae 4000 enrollada en caliente|O|O||D||1
30264909|Barra de aluminio serie sae 5000 estirada en frío|O|O||D||1
30264910|Barra de aluminio serie sae 5000 enrollada en caliente|O|O||D||1
30264911|Barra de aluminio serie sae 6000 estirada en frío|O|O||D||1
30264912|Barra de aluminio serie sae 6000 enrollada en caliente|O|O||D||1
30265000|Láminas de aluminio|O|O||D||1|Hojas de aluminio
30265001|Lámina de aluminio serie sae 1000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 1000
30265002|Lámina de aluminio serie sae 1000 enrollada en caliente|O|O||D||1|Hoja de aluminio laminada en caliente SAE 1000
30265003|Lámina de aluminio serie sae 2000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 2000
30265004|Lámina de aluminio serie sae 2000 enrollada en caliente|O|O||D||1|Hoja de aluminio laminada en caliente SAE 2000
30265005|Lámina de aluminio serie sae 3000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 3000
30265006|Lámina de aluminio serie sae 3000 enrollada en caliente|O|O||D||1|Hoja de aluminio laminada en caliente SAE 3000
30265007|Lámina de aluminio serie sae 4000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 4000
30265008|Lámina de aluminio serie sae 4000 enrollada en caliente|O|O||D||1|Hoja de aluminio laminada en caliente SAE 4000
30265009|Lámina de aluminio serie sae 5000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 5000
30265010|Lámina de aluminio serie sae 5000 enrollada en caliente|O|O||D||1|Hoja de aluminio laminada en caliente SAE 5000
30265011|Lámina de aluminio serie sae 6000 enrollada en frío|O|O||D||1|Hoja de aluminio laminada en frío SAE 6000
30265012|Lámina de aluminio serie sae 6000 enrollada en caliente|O|O||D||1|Hoja de aluminio corrugado
30265100|Alambre de aluminio|O|O||D||1
30265101|Alambre de aluminio serie sae 1000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 1000
30265102|Alambre de aluminio serie sae 2000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 2000
30265103|Alambre de aluminio serie sae 3000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 3000
30265104|Alambre de aluminio serie sae 4000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 4000
30265105|Alambre de aluminio serie sae 5000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 5000
30265106|Alambre de aluminio serie sae 6000 enrollada en caliente|O|O||D||1|Rollo de aluminio laminado en caliente serie SAE 6000
30265200|Bandas y lingotes de aluminio|O|O||D||1|Tiras y lingotes de aluminio
30265201|Banda de aluminio|O|O||D||1|Tiras de aluminio
30265202|Lingote de aluminio|O|O||D||1
30265300|Barras de hierro|O|O||D||1
30265301|Barra fundida de hierro dúctil|O|O||D||1
30265302|Barra fundida de hierro gris|O|O||D||1
30265303|Barra fundida de hierro blanco|O|O||D||1
30265304|Barra fundida de hierro maleable|O|O||D||1
30265400|Láminas de hierro|O|O||D||1
30265401|Lámina de hierro dúctil enrollada en caliente|O|O||D||1
30265402|Lámina de hierro gris enrollada en caliente|O|O||D||1
30265403|Lámina de hierro blanco enrollada en caliente|O|O||D||1
30265404|Lámina de hierro maleable enrollada en caliente|O|O||D||1
30265500|Lingotes, bandas, palanquillas y alambres de hierro|O|O||D||1
30265501|Alambre de hierro dúctil|O|O||D||1
30265502|Banda de hierro dúctil|O|O||D||1
30265503|Palanquilla de hierro dúctil|O|O||D||1
30265504|Palanquilla de hierro gris|O|O||D||1
30265505|Palanquilla de hierro blanco|O|O||D||1
30265506|Palanquilla de hierro maleable|O|O||D||1
30265600|Barras y láminas de aleaciones ferrosas|O|O||D||1
30265601|Barra de aleación ferrosa|O|O||D||1|Barra de aleación ferrosa
30265602|Lámina de aleación ferrosa|O|O||D||1|Hoja de aleación ferrosa
30265700|Lingotes, bandas, palanquillas y alambres de aleaciones ferrosas|O|O||D||1|Lingotes, tiras, palanquillas y rollos de aleaciones ferrosas
30265701|Alambre de aleación ferrosa|O|O||D||1|Rollo de aleación ferrosa
30265702|Banda de aleación ferrosa|O|O||D||1|Tira de aleación ferrosa
30265703|Palanquilla de aleación ferrosa|O|O||D||1
30265704|Lingote de extrusión de aleación ferrosa|O|O||D||1
30265800|Barras y láminas plásticas|O|O||D||1|Barras y hojas de plástico
30265801|Barra de plástico|O|O||D||1
30265802|Lámina de plástico|O|O||D||1|Hoja de plástico
30265803|Lámina corrugada de plástico|O|O||D||1|Hoja de plástico corrugado
30265900|Alambre y bandas de plástico|O|O||D||1
30265901|Alambre de plástico|O|O||D||1|Rollo de plástico
30265902|Banda de plástico|O|O||D||1|Tira de plástico
30266000|Barras de metales preciosos y metales especiales|O|O||D||1
30266001|Barra de metal precioso|O|O||D||1
30266002|Barra de aleación no ferrosa|O|O||D||1
30266100|Láminas de metales preciosos y metales especiales|O|O||D||1|Metales preciosos y hojas de metales especiales
30266101|Lámina de aleación de berilio|O|O||D||1|Hoja de aleación de berilio
30266102|Lámina de metal compuesto|O|O||D||1|Hoja de metal compuesto
30266103|Lámina de aleación de no ferrosa|O|O||D||1|Hoja de aleación no ferrosa
30266200|Lingotes, bandas, palanquillas y alambres de metales preciosos y metales especiales|O|O||D||1
30266201|Alambre de grafito|O|O||D||1|Rollo de grafito
30266202|Alambre de aleación no ferrosa|O|O||D||1|Rollo de aleación no ferrosa
30266203|Alambre de metal precioso|O|O||D||1|Rollo de metal precioso
30266204|Banda de aleación no ferrosa|O|O||D||1|Tira de aleación no ferrosa
30266205|Palanquilla de aleación no ferrosa|O|O||D||1
30266206|Palanquilla de metal precioso|O|O||D||1
30266207|Lingote de metal precioso|O|O||D||1
30266208|Lingote de antimonio|O|O||D||1
30266209|Lingote de cadmio|O|O||D||1
30266210|Lingote de circonio|O|O||D||1
30266211|Lingote de cobalto|O|O||D||1
30266212|Lingote de molibdeno|O|O||D||1
30266213|lingote de arsénico|O|O||D||1
30266214|Lingote de bismuto|O|O||D||1
30266215|Lingote de indio|O|O||D||1
30266216|Lingote de extrusión de aleación no ferrosa|O|O||D||1
30266300|Materiales estructurales de madera|O|O||D||1
30266301|Barra de madera|O|O||D||1
30266400|Barras y láminas de materiales especiales|O|O||D||1
30266401|Barra de caucho|O|O||D||1
30266402|Lámina de caucho|O|O||D||1|Hoja de caucho
30266403|Lámina de caucho espuma|O|O||D||1|Hoja de caucho espuma
30266404|Lámina de caucho y corcho|O|O||D||1|Hoja de caucho y corcho
30266405|Lámina de fibra comprimida|O|O||D||1|Hoja de fibra comprimida
30266406|Lámina de fibra comprimida con metal insertado|O|O||D||1|Hoja de fibra comprimida con metal insertado
30266407|Lámina de fibra y caucho|O|O||D||1|Hoja de fibra y caucho
30266408|Lámina de asbesto|O|O||D||1|Hoja de asbesto
30266410|Barra de tántalo|O|O||D||1|Barra de Tantalio
30266500|Lingotes, bandas, palanquillas y alambres de  materiales especiales|O|O||D||1
30266501|Banda de caucho|O|O||D||1|Tira de caucho
30266502|Alambre de fibra comprimida|O|O||D||1|Rollo de fibra comprimida
30266503|Alambre de fibra y caucho|O|O||D||1|Rollo de fibra y caucho
30266504|Banda de tántalo|O|O||D||1|Tira de Tantalio
30266600|Láminas y lingotes de níckel|O|O||D||1|Hojas y lingotes de níquel
30266601|Lámina de níquel|O|O||D||1|Hoja de níquel
30266602|Lingote de níquel|O|O||D||1
30266700|Trasmisiones|O|O||D||1
30266701|Transmisión de acero|O|O||D||1|Barra de transmisión de acero, Eje de transmisión de acero
30266702|Transmisión de acero inoxidable|O|O||D||1|Barra de transmisión de acero inoxidable, Eje de transmisión de acero inoxidable
31101600|Moldeos en arena|O|O||D||1
31101601|Fundición en arena de aleación no ferrosa|O|O||D||1
31101602|Fundición en arena de aleación ferrosa|O|O||D||1
31101603|Fundición en arena de acero|O|O||D||1
31101604|Fundición en arena de acero inoxidable|O|O||D||1
31101606|Fundición en arena de aluminio|O|O||D||1
31101607|Fundición en arena de magnesio|O|O||D||1
31101608|Fundición en arena de titanio|O|O||D||1
31101609|Fundición en arena de berilio|O|O||D||1
31101610|Fundición en arena de cobre|O|O||D||1
31101611|Fundición en arena de latón|O|O||D||1
31101612|Fundición en arena de bronce|O|O||D||1
31101613|Fundición en arena de zinc|O|O||D||1
31101614|Fundición en arena de estaño|O|O||D||1
31101615|Fundición en arena de plomo|O|O||D||1
31101616|Fundición en arena de metal precioso|O|O||D||1
31101617|Fundición en arena de hierro gris|O|O||D||1
31101618|Fundición en arena de hierro dúctil|O|O||D||1
31101619|Fundición en arena de hierro maleable|O|O||D||1
31101700|Piezas fundidas en molde permanente|O|O||D||1
31101701|Objetos de aleación no ferrosa fundidos en molde fijo|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde permanente
31101702|Objetos de aleación ferrosa fundidos en molde fijo|O|O||D||1|Piezas de aleación ferrosa fundidas en molde permanente
31101703|Objetos de acero fundidos en molde fijo|O|O||D||1|Piezas de acero fundidas en molde permanente
31101704|Objetos de acero inoxidable fundidos en molde fijo|O|O||D||1|Piezas de acero inoxidable fundidas en molde permanente
31101705|Objetos de hierro fundidos en molde fijo|O|O||D||1|Piezas de hierro fundidas en molde permanente
31101706|Objetos de aluminio fundidos en molde fijo|O|O||D||1|Piezas de aluminio fundidas en molde permanente
31101707|Objetos de magnesio fundidos en molde fijo|O|O||D||1|Piezas de magnesio fundidas en molde permanente
31101708|Objetos de titanio fundidos en molde fijo|O|O||D||1|Piezas de titanio fundidas en molde permanente
31101709|Objetos de berilio fundidos en molde fijo|O|O||D||1|Piezas de berilio fundidas en molde permanente
31101710|Objetos de cobre fundidos en molde fijo|O|O||D||1|Piezas de cobre fundidas en molde permanente
31101711|Objetos de latón fundidos en molde fijo|O|O||D||1|Piezas de latón fundidas en molde permanente
31101712|Objetos de bronce fundidos en molde fijo|O|O||D||1|Piezas de bronce fundidas en molde permanente
31101713|Objetos de zinc fundidos en molde fijo|O|O||D||1|Piezas de zinc fundidas en molde permanente
31101714|Objetos de estaño fundidos en molde fijo|O|O||D||1|Piezas de estaño fundidas en molde permanente
31101715|Objetos de plomo fundidos en molde fijo|O|O||D||1|Piezas de plomo fundidas en molde permanente
31101716|Objetos de metal precioso fundidos en molde fijo|O|O||D||1|Piezas de metal precioso fundidas en molde permanente
31101800|Piezas fundidas por moldeo en cáscara|O|O||D||1|Piezas fundidas en moldes de fundición de cáscara
31101801|Objetos de aleación no ferrosa fundidos por moldeo en cáscara|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de cáscara
31101802|Objetos de aleación ferrosa fundidos por moldeo en cáscara|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de cáscara
31101803|Objetos de acero fundidos por moldeo en cáscara|O|O||D||1|Piezas de acero fundidas en molde de cáscara
31101804|Objetos de acero inoxidable fundidos por moldeo en cáscara|O|O||D||1|Piezas de acero inoxidable fundidas en molde de cáscara
31101806|Objetos de aluminio fundidos por moldeo en cáscara|O|O||D||1|Piezas de aluminio fundidas en molde de cáscara
31101807|Objetos de magnesio fundidos por moldeo en cáscara|O|O||D||1|Piezas de magnesio fundidas en molde de cáscara
31101808|Objetos de titanio fundidos por moldeo en cáscara|O|O||D||1|Piezas de titanio fundidas en molde de cáscara
31101809|Objetos de berilio fundidos por moldeo en cáscara|O|O||D||1|Piezas de berilio fundidas en molde de cáscara
31101810|Objetos de cobre fundidos por moldeo en cáscara|O|O||D||1|Piezas de cobre fundidas en molde de cáscara
31101811|Objetos de latón fundidos por moldeo en cáscara|O|O||D||1|Piezas de latón fundidas en molde de cáscara
31101812|Objetos de bronce fundidos por moldeo en cáscara|O|O||D||1|Piezas de bronce fundidas en molde de cáscara
31101813|Objetos de zinc fundidos por moldeo en cáscara|O|O||D||1|Piezas de zinc fundidas en molde de cáscara
31101814|Objetos de estaño fundidos por moldeo en cáscara|O|O||D||1|Piezas de estaño fundidas en molde de cáscara
31101815|Objetos de plomo fundidos por moldeo en cáscara|O|O||D||1|Piezas de plomo fundidas en molde de cáscara
31101816|Objetos de metal precioso fundidos por moldeo en cáscara|O|O||D||1|Piezas de metal precioso fundidas en molde de cáscara
31101817|Objetos de hierro dúctil fundidos por moldeo en cáscara|O|O||D||1|Piezas de hierro fundidas en molde de cáscara
31101900|Piezas fundidas a la cera perdida|O|O||D||1
31101901|Objetos de aleación no ferrosa fundidos a la cera perdida|O|O||D||1|Piezas de aleación no ferrosa fundidas a la cera perdida
31101902|Objetos de aleación ferrosa fundidos a la cera perdida|O|O||D||1|Piezas de aleación ferrosa fundidas a la cera perdida
31101903|Objetos de acero fundidos a la cera perdida|O|O||D||1|Piezas de acero fundidas a la cera perdida
31101904|Objetos de acero inoxidable fundidos a la cera perdida|O|O||D||1|Piezas de acero inoxidable fundidas a la cera perdida
31101905|Objetos de hierro fundidos a la cera perdida|O|O||D||1|Piezas de hierro fundidas a la cera perdida
31101906|Objetos de aluminio fundidos a la cera perdida|O|O||D||1|Piezas de aluminio fundidas a la cera perdida
31101907|Objetos de magnesio fundidos a la cera perdida|O|O||D||1|Piezas de magnesio fundidas a la cera perdida
31101908|Objetos de zinc fundidos a la cera perdida|O|O||D||1|Piezas de zinc fundidas a la cera perdida
31101909|Objetos de estaño fundidos a la cera perdida|O|O||D||1|Piezas de estaño fundidas a la cera perdida
31101910|Objetos de plomo fundidos a la cera perdida|O|O||D||1|Piezas de plomo fundidas a la cera perdida
31101911|Objetos de metal precioso fundidos a la cera perdida|O|O||D||1|Piezas de metal precioso fundidas a la cera perdida
31101912|Objetos de titanio fundidos a la cera perdida|O|O||D||1|Piezas de titanio fundidas a la cera perdida
31101914|Objetos de aleación de acero fundidos a la cera perdida|O|O||D||1|Piezas de aleación de acero fundidas a la cera perdida
31102000|Piezas de fundición centrífuga|O|O||D||1|Fundiciones centrífugas
31102001|Objetos de fundición centrífuga de aleación no ferrosa|O|O||D||1|Piezas de aleación no ferrosa hechas mediante fundición centrifuga
31102002|Objetos de fundición centrífuga de aleación ferrosa|O|O||D||1|Piezas de aleación ferrosa hechas mediante fundición centrifuga
31102003|Objetos de fundición centrífuga de acero|O|O||D||1|Piezas de acero hechas mediante fundición centrifuga
31102004|Objetos de fundición centrífuga de acero inoxidable|O|O||D||1|Piezas de acero inoxidable hechas mediante fundición centrifuga
31102005|Objetos de fundición centrífuga de hierro|O|O||D||1|Piezas de hierro hechas mediante fundición centrifuga
31102006|Objetos de fundición centrífuga de aluminio|O|O||D||1|Piezas de aluminio hechas mediante fundición centrifuga
31102007|Objetos de fundición centrífuga de magnesio|O|O||D||1|Piezas de magnesio hechas mediante fundición centrifuga
31102008|Objetos de fundición centrífuga de titanio|O|O||D||1|Piezas de titanio hechas mediante fundición centrifuga
31102009|Objetos de fundición centrífuga de berilio|O|O||D||1|Piezas de berilio hechas mediante fundición centrifuga
31102010|Objetos de fundición centrífuga de cobre|O|O||D||1|Piezas de cobre hechas mediante fundición centrifuga
31102011|Objetos de fundición centrífuga de latón|O|O||D||1|Piezas de latón hechas mediante fundición centrifuga
31102012|Objetos de fundición centrífuga de bronce|O|O||D||1|Piezas de bronce hechas mediante fundición centrifuga
31102013|Objetos de fundición centrífuga de zinc|O|O||D||1|Piezas de zinc hechas mediante fundición centrifuga
31102014|Objetos de fundición centrífuga de estaño|O|O||D||1|Piezas de estaño hechas mediante fundición centrifuga
31102015|Objetos de fundición centrífuga de plomo|O|O||D||1|Piezas de plomo hechas mediante fundición centrifuga
31102016|Objetos de fundición centrífuga de metal precioso|O|O||D||1|Piezas de metal precioso hechas mediante fundición centrifuga
31102100|Piezas fundidas en molde cerámico|O|O||D||1
31102101|Objetos de aleación no ferrosa fundidos en molde cerámico|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de cerámica
31102102|Objetos de aleación ferrosa fundidos en molde cerámico|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de cerámica
31102103|Objetos de acero fundidos en molde cerámico|O|O||D||1|Piezas de acero fundidas en molde de cerámica
31102104|Objetos de acero inoxidable fundidos en molde cerámico|O|O||D||1|Piezas de acero inoxidable fundidas en molde de cerámica
31102105|Objetos de hierro fundidos en molde cerámico|O|O||D||1|Piezas de hierro fundidas en molde de cerámica
31102106|Objetos de aluminio fundidos en molde cerámico|O|O||D||1|Piezas de aluminio fundidas en molde de cerámica
31102107|Objetos de magnesio fundidos en molde cerámico|O|O||D||1|Piezas de magnesio fundidas en molde de cerámica
31102108|Objetos de titanio fundidos en molde cerámico|O|O||D||1|Piezas de titanio fundidas en molde de cerámica
31102109|Objetos de berilio fundidos en molde cerámico|O|O||D||1|Piezas de berilio fundidas en molde de cerámica
31102110|Objetos de cobre fundidos en molde cerámico|O|O||D||1|Piezas de cobre fundidas en molde de cerámica
31102111|Objetos de latón fundidos en molde cerámico|O|O||D||1|Piezas de latón fundidas en molde de cerámica
31102112|Objetos de bronce fundidos en molde cerámico|O|O||D||1|Piezas de bronce fundidas en molde de cerámica
31102113|Objetos de zinc fundidos en molde cerámico|O|O||D||1|Piezas de zinc fundidas en molde de cerámica
31102114|Objetos de estaño fundidos en molde cerámico|O|O||D||1|Piezas de estaño fundidas en molde de cerámica
31102115|Objetos de plomo fundidos en molde cerámico|O|O||D||1|Piezas de plomo fundidas en molde de cerámica
31102116|Objetos de metal precioso fundidos en molde cerámico|O|O||D||1|Piezas de metal precioso fundidas en molde de cerámica
31102200|Piezas fundidas en molde de grafito|O|O||D||1|Fundiciones en molde de grafito
31102201|Objetos de aleación no ferrosa fundidos en molde de grafito|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de grafito
31102202|Objetos de aleación ferrosa fundidos en molde de grafito|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de grafito
31102203|Objetos de acero fundidos en molde de grafito|O|O||D||1|Piezas de acero fundidas en molde de grafito
31102204|Objetos de acero inoxidable fundidos en molde de grafito|O|O||D||1|Piezas de acero inoxidable fundidas en molde de grafito
31102205|Objetos de hierro fundidos en molde de grafito|O|O||D||1|Piezas de hierro fundidas en molde de grafito
31102206|Objetos de aluminio fundidos en molde de grafito|O|O||D||1|Piezas de aluminio fundidas en molde de grafito
31102207|Objetos de magnesio fundidos en molde de grafito|O|O||D||1|Piezas de magnesio fundidas en molde de grafito
31102208|Objetos de titanio fundidos en molde de grafito|O|O||D||1|Piezas de titanio fundidas en molde de grafito
31102209|Objetos de berilio fundidos en molde de grafito|O|O||D||1|Piezas de berilio fundidas en molde de grafito
31102210|Objetos de cobre fundidos en molde de grafito|O|O||D||1|Piezas de cobre fundidas en molde de grafito
31102211|Objetos de latón fundidos en molde de grafito|O|O||D||1|Piezas de latón fundidas en molde de grafito
31102212|Objetos de bronce fundidos en molde de grafito|O|O||D||1|Piezas de bronce fundidas en molde de grafito
31102213|Objetos de zinc fundidos en molde de grafito|O|O||D||1|Piezas de zinc fundidas en molde de grafito
31102214|Objetos de estaño fundidos en molde de grafito|O|O||D||1|Piezas de estaño fundidas en molde de grafito
31102215|Objetos de plomo fundidos en molde de grafito|O|O||D||1|Piezas de plomo fundidas en molde de grafito
31102216|Objetos de metal precioso fundidos en molde de grafito|O|O||D||1|Piezas de metal precioso fundidas en molde de grafito
31102300|Piezas fundidas en molde de yeso|O|O||D||1
31102301|Objetos de aleación no ferrosa fundidos en molde de yeso|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de yeso
31102302|Objetos de aleación ferrosa fundidos en molde de yeso|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de yeso
31102303|Objetos de acero fundidos en molde de yeso|O|O||D||1|Piezas de acero fundidas en molde de yeso
31102304|Objetos de acero inoxidable fundidos en molde de yeso|O|O||D||1|Piezas de acero inoxidable fundidas en molde de yeso
31102305|Objetos de hierro fundidos en molde de yeso|O|O||D||1|Piezas de hierro fundidas en molde de yeso
31102306|Objetos de aluminio fundidos en molde de yeso|O|O||D||1|Piezas de aluminio fundidas en molde de yeso
31102307|Objetos de magnesio fundidos en molde de yeso|O|O||D||1|Piezas de magnesio fundidas en molde de yeso
31102308|Objetos de titanio fundidos en molde de yeso|O|O||D||1|Piezas de titanio fundidas en molde de yeso
31102309|Objetos de berilio fundidos en molde de yeso|O|O||D||1|Piezas de berilio fundidas en molde de yeso
31102310|Objetos de cobre fundidos en molde de yeso|O|O||D||1|Piezas de cobre fundidas en molde de yeso
31102311|Objetos de latón fundidos en molde de yeso|O|O||D||1|Piezas de latón fundidas en molde de yeso
31102312|Objetos de bronce fundidos en molde de yeso|O|O||D||1|Piezas de bronce fundidas en molde de yeso
31102313|Objetos de zinc fundidos en molde de yeso|O|O||D||1|Piezas de zinc fundidas en molde de yeso
31102314|Objetos de estaño fundidos en molde de yeso|O|O||D||1|Piezas de estaño fundidas en molde de yeso
31102315|Objetos de plomo fundidos en molde de yeso|O|O||D||1|Piezas de plomo fundidas en molde de yeso
31102316|Objetos de metal precioso fundidos en molde de yeso|O|O||D||1|Piezas de metal precioso fundidas en molde de yeso
31102400|Fundiciones en V|O|O||D||1|Fundición en proceso V
31102401|Objetos de aleación no ferrosa fundidos por proceso en v|O|O||D||1|Piezas de aleación no ferrosa fundidas por proceso V
31102402|Objetos de aleación ferrosa fundidos por proceso en v|O|O||D||1|Piezas de aleación ferrosa fundidas por proceso V
31102403|Objetos de acero fundidos por proceso en v|O|O||D||1|Piezas de acero fundidas por proceso V
31102404|Objetos de acero inoxidable fundidos por proceso en v|O|O||D||1|Piezas de acero inoxidable por proceso  V
31102405|Objetos de hierro fundidos por proceso en v|O|O||D||1|Piezas de hierro fundidas por proceso V
31102406|Objetos de aluminio fundidos por proceso en v|O|O||D||1|Piezas de aluminio fundidas por proceso V
31102407|Objetos de magnesio fundidos por proceso en v|O|O||D||1|Piezas de magnesio fundidas por proceso V
31102408|Objetos de titanio fundidos por proceso en v|O|O||D||1|Piezas de titanio fundidas por proceso V
31102409|Objetos de berilio fundidos por proceso en v|O|O||D||1|Piezas de berilio fundidas por proceso V
31102410|Objetos de cobre fundidos por proceso en v|O|O||D||1|Piezas de cobre fundidas por proceso V
31102411|Objetos de latón fundidos por proceso en v|O|O||D||1|Piezas de latón fundidas por proceso V
31102412|Objetos de bronce fundidos por proceso en v|O|O||D||1|Piezas de bronce fundidas por proceso V
31102413|Objetos de zinc fundidos por proceso en v|O|O||D||1|Piezas de zinc fundidas por proceso V
31102414|Objetos de estaño fundidos por proceso en v|O|O||D||1|Piezas de estaño fundidas por proceso V
31102415|Objetos de plomo fundidos por proceso en v|O|O||D||1|Piezas de plomo fundidas por proceso V
31102416|Objetos de metal precioso fundidos por proceso en v|O|O||D||1|Piezas de metal precioso fundidas por proceso V
31102500|Fundiciones con troquel y ensambles de fundiciones permanentes de baja presión|O|O||D||1|Fundiciones en molde y ensambles de fundiciones permanentes de baja presión
31102501|Objetos de aluminio de baja presión fundidos en molde fijo|O|O||D||1|Piezas de aluminio fundidos a baja presión en molde permanente
31102600|Fundiciones con troquel y ensambles de fundiciones  de alta presión|O|O||D||1|Fundiciones en molde y ensambles de fundiciones  de alta presión
31102601|Objetos de aluminio de alta presión fundidos en molde fijo|O|O||D||1|Piezas de aluminio fundidos en molde a alta presión
31102602|Objetos de aluminio de alta presión moldeados con troquel|O|O||D||1|Piezas de zinc fundidos en molde a alta presión
31102603|Objetos de zinc de alta presión moldeados con troquel|O|O||D||1|Piezas de magnesio fundidos en molde a alta presión
31102700|Fundiciones y ensambles de fundiciones por apriete|O|O||D||1|Fundiciones y ensambles de fundiciones a presión
31102701|Objetos de aluminio moldeados por apriete (squeeze)|O|O||D||1|Piezas de aluminio fundidas a presión
31102800|Fundiciones con troquel y ensambles de fundiciones semi - sólidas|O|O||D||1|Fundiciones en molde y ensambles de fundiciones semi - sólidas
31102801|Objetos de aluminio de alta presión moldeados con troquel|O|O||D||1|Fundición semi-sólida de aluminio
31102900|Moldeos con troquel y ensambles de fundiciones permanentes a gravedad|O|O||D||1|Fundiciones en molde y ensambles de fundiciones en moldes permanentes a gravedad
31102901|Objetos de aluminio moldeados por gravedad permanente|O|O||D||1|Piezas de aluminio fundidas en moldes permanentes a gravedad
31111500|Extrusiones de perfiles|O|O||D||1
31111501|Extrusiones de perfiles de aluminio|O|O||D||1
31111502|Extrusiones de perfiles de berilio|O|O||D||1
31111503|Extrusiones de perfiles de latón|O|O||D||1
31111504|Extrusiones de perfiles de bronce|O|O||D||1
31111505|Extrusiones de perfiles de cobre|O|O||D||1
31111506|Extrusiones de perfiles de aleación ferrosa|O|O||D||1
31111507|Extrusiones de perfiles de plomo|O|O||D||1
31111508|Extrusiones de perfiles de magnesio|O|O||D||1
31111509|Extrusiones de perfiles de aleación no ferrosa|O|O||D||1
31111510|Extrusiones de perfiles de plástico|O|O||D||1
31111511|Extrusiones de perfiles de metal precioso|O|O||D||1
31111512|Extrusiones de perfiles de caucho|O|O||D||1
31111513|Extrusiones de perfiles de acero inoxidable|O|O||D||1
31111514|Extrusiones de perfiles de acero|O|O||D||1
31111515|Extrusiones de perfiles de estaño|O|O||D||1
31111516|Extrusiones de perfiles de titanio|O|O||D||1
31111517|Extrusiones de perfiles de zinc|O|O||D||1
31111600|Extrusiones por percusión|O|O||D||1|Extrusiones por impacto
31111601|Extrusiones por impacto de aluminio|O|O||D||1|Extrusiones de perfiles de aluminio por impacto
31111602|Extrusiones por impacto de berilio|O|O||D||1|Extrusiones de perfiles de berilio por impacto
31111603|Extrusiones por impacto de latón|O|O||D||1|Extrusiones de perfiles de latón por impacto
31111604|Extrusiones por impacto de bronce|O|O||D||1|Extrusiones de perfiles de bronce por impacto
31111605|Extrusiones por impacto de cobre|O|O||D||1|Extrusiones de perfiles de cobre por impacto
31111606|Extrusiones por impacto de aleación ferrosa|O|O||D||1|Extrusiones de perfiles de aleación ferrosa por impacto
31111607|Extrusiones por impacto de plomo|O|O||D||1|Extrusiones de perfiles de plomo por impacto
31111608|Extrusiones por impacto de magnesio|O|O||D||1|Extrusiones de perfiles de magnesio por impacto
31111609|Extrusiones por impacto de aleación no ferrosa|O|O||D||1|Extrusiones de perfiles de aleación no ferrosa por impacto
31111610|Extrusiones por impacto de plástico|O|O||D||1|Extrusiones de perfiles de plástico por impacto
31111611|Extrusiones por impacto de metal precioso|O|O||D||1|Extrusiones de perfiles de metal precioso por impacto
31111612|Extrusiones por impacto de caucho|O|O||D||1|Extrusiones de perfiles de caucho por impacto
31111613|Extrusiones por impacto de acero inoxidable|O|O||D||1|Extrusiones de perfiles de acero inoxidable por impacto
31111614|Extrusiones por impacto de acero|O|O||D||1|Extrusiones de perfiles de acero por impacto
31111615|Extrusiones por impacto de estaño|O|O||D||1|Extrusiones de perfiles de estaño por impacto
31111616|Extrusiones por impacto de titanio|O|O||D||1|Extrusiones de perfiles de titanio por impacto
31111617|Extrusiones por impacto de zinc|O|O||D||1|Extrusiones de perfiles de zinc por impacto
31111700|Extrusiones en frío|O|O||D||1
31111701|Extrusiones en frío de aluminio|O|O||D||1|Extrusiones de perfiles de aluminio en frío
31111702|Extrusiones en frío de berilio|O|O||D||1|Extrusiones de perfiles de berilio en frío
31111703|Extrusiones en frío de latón|O|O||D||1|Extrusiones de perfiles de latón en frío
31111704|Extrusiones en frío de bronce|O|O||D||1|Extrusiones de perfiles de bronce en frío
31111705|Extrusiones en frío de cobre|O|O||D||1|Extrusiones de perfiles de cobre en frío
31111706|Extrusiones en frío de aleación ferrosa|O|O||D||1|Extrusiones de perfiles de aleación ferrosa en frío
31111707|Extrusiones en frío de plomo|O|O||D||1|Extrusiones de perfiles de plomo en frío
31111708|Extrusiones en frío de magnesio|O|O||D||1|Extrusiones de perfiles de magnesio en frío
31111709|Extrusiones en frío de aleación no ferrosa|O|O||D||1|Extrusiones de perfiles de aleación ferrosa en frío
31111710|Extrusiones en frío de plástico|O|O||D||1|Extrusiones de perfiles de plástico en frío
31111711|Extrusiones en frío de metal precioso|O|O||D||1|Extrusiones de perfiles de metal precioso en frío
31111712|Extrusiones en frío de caucho|O|O||D||1|Extrusiones de perfiles de caucho en frío
31111713|Extrusiones en frío de acero inoxidable|O|O||D||1|Extrusiones de perfiles de acero inoxidable en frío
31111714|Extrusiones en frío de acero|O|O||D||1|Extrusiones de perfiles de acero en frío
31111715|Extrusiones en frío de estaño|O|O||D||1|Extrusiones de perfiles de estaño en frío
31111716|Extrusiones en frío de titanio|O|O||D||1|Extrusiones de perfiles de titanio en frío
31111717|Extrusiones en frío de zinc|O|O||D||1|Extrusiones de perfiles de zinc en frío
31121000|Piezas fundidas mecanizadas de proceso v|O|O||D||1|Piezas fundidas por proceso v mecanizadas
31121001|Objetos fundidos maquinados por proceso v de aleaciones no ferrosas|O|O||D||1|Piezas de aleaciones no ferrosas  fundidas por proceso v mecanizadas
31121002|Objetos fundidos maquinados por proceso v de aleaciones ferrosas|O|O||D||1|Piezas de aleaciones ferrosas  fundidas por proceso v mecanizadas
31121003|Objetos fundidos maquinados por proceso v de acero|O|O||D||1|Piezas de acero  fundidas por proceso v mecanizadas
31121004|Objetos fundidos maquinados por proceso v de acero inoxidable|O|O||D||1|Piezas de acero inoxidable fundidas por proceso v mecanizadas
31121005|Objetos fundidos maquinados por proceso v de hierro|O|O||D||1|Piezas de hierro fundidas por proceso v mecanizadas
31121006|Objetos fundidos maquinados por proceso v de aluminio|O|O||D||1|Piezas de aluminio  fundidas por proceso v mecanizadas
31121007|Objetos fundidos maquinados por proceso v de magnesio|O|O||D||1|Piezas de magnesio  fundidas por proceso v mecanizadas
31121008|Objetos fundidos maquinados por proceso v de titanio|O|O||D||1|Piezas de titanio  fundidas por proceso v mecanizadas
31121009|Objetos fundidos maquinados por proceso v de berilio|O|O||D||1|Piezas de berilio  fundidas por proceso v mecanizadas
31121010|Objetos fundidos maquinados por proceso v de cobre|O|O||D||1|Piezas de cobre  fundidas por proceso v mecanizadas
31121011|Objetos fundidos maquinados por proceso v de latón|O|O||D||1|Piezas de latón  fundidas por proceso v mecanizadas
31121012|Objetos fundidos maquinados por proceso v de bronce|O|O||D||1|Piezas de bronce fundidas por proceso v mecanizadas
31121013|Objetos fundidos maquinados por proceso v de zinc|O|O||D||1|Piezas de zinc  fundidas por proceso v mecanizadas
31121014|Objetos fundidos maquinados por proceso v de estaño|O|O||D||1|Piezas de estaño  fundidas por proceso v mecanizadas
31121015|Objetos fundidos maquinados por proceso v de plomo|O|O||D||1|Piezas de plomo fundidas por proceso v mecanizadas
31121016|Objetos fundidos maquinados por proceso v de metal precioso|O|O||D||1|Piezas de metal precioso  fundidas por proceso v mecanizadas
31121017|Objetos fundidos maquinados por proceso v de compuestos|O|O||D||1|Piezas de compuestos  fundidas por proceso v mecanizadas
31121018|Objetos fundidos maquinados por proceso v de aleación de níquel|O|O||D||1|Piezas de aleación de níquel fundidas por proceso v mecanizadas
31121019|Objetos fundidos maquinados por proceso v no metálico|O|O||D||1|Piezas no metálicas  fundidas por proceso v mecanizadas
31121100|Fundiciones a troquel mecanizadas|O|O||D||1|Fundiciones en molde mecanizadas
31121101|Objetos fundidos maquinados con troquel de aleaciones no ferrosas|O|O||D||1|Piezas de aluminio fundidas en molde mecanizadas
31121102|Objetos fundidos maquinados con troquel de aleaciones ferrosas|O|O||D||1|Piezas de aleaciones ferrosas fundidas en molde mecanizadas
31121103|Objetos fundidos maquinados con troquel de acero|O|O||D||1|Piezas de hierro fundidas en molde mecanizadas
31121104|Objetos fundidos maquinados con troquel de acero inoxidable|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde mecanizadas
31121105|Objetos fundidos maquinados con troquel de hierro|O|O||D||1|Piezas de acero inoxidable fundidas en molde mecanizadas
31121106|Objetos fundidos maquinados con troquel de aluminio|O|O||D||1|Piezas de acero fundidas en molde mecanizadas
31121107|Objetos fundidos maquinados con troquel de magnesio|O|O||D||1|Piezas de magnesio fundidas en molde mecanizadas
31121108|Objetos fundidos maquinados con troquel de titanio|O|O||D||1|Piezas de zinc fundidas en molde mecanizadas
31121109|Objetos fundidos maquinados con troquel de berilio|O|O||D||1|Piezas de estaño fundidas en molde mecanizadas
31121110|Objetos fundidos maquinados con troquel de cobre|O|O||D||1|Piezas de titanio fundidas en molde mecanizadas
31121111|Objetos fundidos maquinados con troquel de latón|O|O||D||1|Piezas de berilio fundidas en molde mecanizadas
31121112|Objetos fundidos maquinados con troquel de bronce|O|O||D||1|Piezas de metal precioso fundidas en molde mecanizadas
31121113|Objetos fundidos maquinados con troquel de zinc|O|O||D||1|Piezas de cobre fundidas en molde mecanizadas
31121114|Objetos fundidos maquinados con troquel de estaño|O|O||D||1|Piezas de plomo fundidas en molde mecanizadas
31121115|Objetos fundidos maquinados con troquel de plomo|O|O||D||1|Piezas de latón fundidas en molde mecanizadas
31121116|Objetos fundidos maquinados con troquel de metal precioso|O|O||D||1|Piezas de bronce fundidas en molde mecanizadas
31121117|Objetos fundidos maquinados con troquel de compuestos|O|O||D||1|Piezas de compuestos fundidas en molde mecanizadas
31121118|Objetos fundidos maquinados con troquel de aleación de níquel|O|O||D||1|Piezas de aleaciones de níquel fundidas en molde mecanizadas
31121119|Objetos fundidos maquinados con troquel no metálico|O|O||D||1|Piezas no metálicas fundidas en molde mecanizadas
31121120|Objetos de aluminio de alta presión fundidos maquinados con troquel|O|O||D||1|Piezas de aluminio fundidas a alta presión en molde mecanizadas
31121121|Ensamble de objetos de aluminio de alta presión fundidos maquinados con troquel|O|O||D||1|Ensamble de piezas de aluminio fundidas a alta presión en molde mecanizadas
31121122|Objetos de magnesio de alta presión fundidos maquinados con troquel|O|O||D||1|Piezas de magnesio fundidas a alta presión en molde mecanizadas
31121123|Ensamble de objetos de magnesio de alta presión fundidos maquinados con troquel|O|O||D||1|Ensamble de piezas de magnesio fundidas a alta presión en molde mecanizadas
31121124|Objetos de zinc de alta presión fundidos maquinados con troquel|O|O||D||1|Piezas de zinc fundidas a alta presión en molde mecanizadas
31121125|Ensamble de objetos de zinc de alta presión fundidos maquinados con troquel|O|O||D||1|Ensamble de piezas de zinc fundidas a alta presión en molde mecanizadas
31121200|Fundiciones en arena mecanizadas|O|O||D||1
31121201|Objetos maquinados de aleación no ferrosa fundidos en arena|O|O||D||1|Piezas de aleación no ferrosa fundidas a la arena mecanizadas
31121202|Objetos maquinados de aleación ferrosa fundidos en arena|O|O||D||1|Piezas de aleación ferrosa fundidas a la arena mecanizadas
31121203|Objetos maquinados de acero fundidos en arena|O|O||D||1|Piezas de acero fundidas a la arena mecanizadas
31121204|Objetos maquinados de acero inoxidable fundidos en arena|O|O||D||1|Piezas de acero inoxidable fundidas a la arena mecanizadas
31121205|Objetos maquinados de hierro fundidos en arena|O|O||D||1|Piezas de hierro fundidas a la arena mecanizadas
31121206|Objetos maquinados de aluminio fundidos en arena|O|O||D||1|Piezas de aluminio fundidas a la arena mecanizadas
31121207|Objetos maquinados de magnesio fundidos en arena|O|O||D||1|Piezas de magnesio fundidas a la arena mecanizadas
31121208|Objetos maquinados de titanio fundidos en arena|O|O||D||1|Piezas de titanio fundidas a la arena mecanizadas
31121209|Objetos maquinados de berilio fundidos en arena|O|O||D||1|Piezas de berilio fundidas a la arena mecanizadas
31121210|Objetos maquinados de cobre fundidos en arena|O|O||D||1|Piezas de cobre fundidas a la arena mecanizadas
31121211|Objetos maquinados de latón fundidos en arena|O|O||D||1|Piezas de latón fundidas a la arena mecanizadas
31121212|Objetos maquinados de bronce fundidos en arena|O|O||D||1|Piezas de bronce fundidas a la arena mecanizadas
31121213|Objetos maquinados de cinc fundidos en arena|O|O||D||1|Piezas de zinc fundidas a la arena mecanizadas
31121214|Objetos maquinados de estaño fundidos en arena|O|O||D||1|Piezas de estaño fundidas a la arena mecanizadas
31121215|Objetos maquinados de plomo fundidos en arena|O|O||D||1|Piezas de plomo fundidas a la arena mecanizadas
31121216|Objetos maquinados de metal precioso fundidos en arena|O|O||D||1|Piezas de metal precioso fundidas a la arena mecanizadas
31121217|Objetos maquinados de compuestos fundidos en arena|O|O||D||1|Piezas de compuesto fundidas a la arena mecanizadas
31121218|Objetos maquinados de aleación de níquel fundidos en arena|O|O||D||1|Piezas de aleación de níquel fundidas a la arena mecanizadas
31121219|Objetos maquinados no metálicos fundidos en arena|O|O||D||1|Piezas no metálicas fundidas a la arena mecanizadas
31121220|Objetos maquinados de aluminio fundidos en arena|O|O||D||1|Pieza de aluminio fundida a la arena mecanizadas
31121221|Ensamble de objetos maquinados de aluminio fundidos en arena|O|O||D||1|Ensamble de piezas de aluminio fundidos a la arena mecanizadas
31121222|Objetos maquinados de hierro dúctil fundidos en arena|O|O||D||1|Piezas de hierro dúctil fundidos a la arena mecanizadas
31121223|Ensamble de objetos maquinados de hierro dúctil fundidos en arena|O|O||D||1|Ensamble de piezas de hierro dúctil fundidos a la arena mecanizadas
31121224|Objetos maquinados de hierro gris fundidos en arena|O|O||D||1|Piezas de hierro gris fundidos a la arena mecanizadas
31121225|Ensamble de objetos maquinados de hierro gris fundidos en arena|O|O||D||1|Ensamble de piezas de hierro gris fundidos a la arena mecanizadas
31121226|Objetos maquinados de hierro maleable fundidos en arena|O|O||D||1|Piezas de hierro maleable fundidos a la arena mecanizadas
31121227|Ensamble de objetos maquinados de hierro maleable fundidos en arena|O|O||D||1|Ensamble de piezas de hierro maleable fundidos a la arena mecanizadas
31121300|Fundiciones de molde permanente mecanizadas|O|O||D||1
31121301|Objetos maquinados en molde permanente de aleación no ferrosa fundidos|O|O||D||1|Piezas de aleación no ferrosa  fundidas en molde permanente mecanizadas
31121302|Objetos maquinados en molde permanente de aleación ferrosa fundidos|O|O||D||1|Piezas de aleación ferrosa  fundidas en molde permanente mecanizadas
31121303|Objetos maquinados en molde permanente de acero fundidos|O|O||D||1|Piezas de acero fundidas en molde permanente mecanizadas
31121304|Objetos maquinados en molde permanente de acero inoxidable fundidos|O|O||D||1|Piezas de acero inoxidable fundidas en molde permanente mecanizadas
31121305|Objetos maquinados en molde permanente de hierro fundidos|O|O||D||1|Piezas de hierro fundidas en molde permanente mecanizadas
31121306|Objetos maquinados en molde permanente de aluminio fundidos|O|O||D||1|Piezas de aluminio fundidas en molde permanente mecanizadas
31121307|Objetos maquinados en molde permanente de magnesio fundidos|O|O||D||1|Piezas de magnesio fundidas en molde permanente mecanizadas
31121308|Objetos maquinados en molde permanente de titanio fundidos|O|O||D||1|Piezas de titanio fundidas en molde permanente mecanizadas
31121309|Objetos maquinados en molde permanente de berilio fundidos|O|O||D||1|Piezas de berilio fundidas en molde permanente mecanizadas
31121310|Objetos maquinados en molde permanente de cobre fundidos|O|O||D||1|Piezas de cobre fundidas en molde permanente mecanizadas
31121311|Objetos maquinados en molde permanente de latón fundidos|O|O||D||1|Piezas de latón fundidas en molde permanente mecanizadas
31121312|Objetos maquinados en molde permanente de bronce fundidos|O|O||D||1|Piezas de bronce  fundidas en molde permanente mecanizadas
31121313|Objetos maquinados en molde permanente de cinc fundidos|O|O||D||1|Piezas de zinc  fundidas en molde permanente mecanizadas
31121314|Objetos maquinados en molde permanente de estaño fundidos|O|O||D||1|Piezas de estaño fundidas en molde permanente mecanizadas
31121315|Objetos maquinados en molde permanente de plomo fundidos|O|O||D||1|Piezas de plomo fundidas en molde permanente mecanizadas
31121316|Objetos maquinados en molde permanente de metal precioso fundidos|O|O||D||1|Piezas de metal precioso fundidas en molde permanente mecanizadas
31121317|Objetos maquinados en molde permanente de compuestos fundidos|O|O||D||1|Piezas de compuestos  fundidas en molde permanente mecanizadas
31121318|Objetos maquinados en molde permanente de aleación de níquel fundidos|O|O||D||1|Piezas de aleación de níquel  fundidas en molde permanente mecanizadas
31121319|Objetos maquinados en molde permanente no metálicos fundidos|O|O||D||1|Piezas no metálicas  fundidas en molde permanente mecanizadas
31121320|Objetos maquinados en molde permanente de aluminio de baja presión fundidos|O|O||D||1|Piezas de aluminio fundidas a baja presión en molde permanente mecanizadas
31121321|Ensamble de objetos maquinados en molde permanente de aluminio de baja presión fundidos|O|O||D||1|Ensamble de piezas de aluminio fundidas a baja presión en molde permanente mecanizadas
31121400|Fundiciones de molde de yeso mecanizadas|O|O||D||1
31121401|Objetos maquinados de aleación no ferrosa fundidos en molde de yeso|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de yeso mecanizadas
31121402|Objetos maquinados de aleación ferrosa fundidos en molde de yeso|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de yeso mecanizadas
31121403|Objetos maquinados de acero fundidos en molde de yeso|O|O||D||1|Piezas de acero fundidas en molde de yeso mecanizadas
31121404|Objetos maquinados de acero inoxidable fundidos en molde de yeso|O|O||D||1|Piezas de acero inoxidable fundidas en molde de yeso mecanizadas
31121405|Objetos maquinados de hierro fundidos en molde de yeso|O|O||D||1|Piezas de hierro fundidas en molde de yeso mecanizadas
31121406|Objetos maquinados de aluminio fundidos en molde de yeso|O|O||D||1|Piezas de aluminio fundidas en molde de yeso mecanizadas
31121407|Objetos maquinados de magnesio fundidos en molde de yeso|O|O||D||1|Piezas de magnesio fundidas en molde de yeso mecanizadas
31121408|Objetos maquinados de titanio fundidos en molde de yeso|O|O||D||1|Piezas de titanio fundidas en molde de yeso mecanizadas
31121409|Objetos maquinados de berilio fundidos en molde de yeso|O|O||D||1|Piezas de berilio fundidas en molde de yeso mecanizadas
31121410|Objetos maquinados de cobre fundidos en molde de yeso|O|O||D||1|Piezas de cobre fundidas en molde de yeso mecanizadas
31121411|Objetos maquinados de latón fundidos en molde de yeso|O|O||D||1|Piezas de latón fundidas en molde de yeso mecanizadas
31121412|Objetos maquinados de bronce fundidos en molde de yeso|O|O||D||1|Piezas de bronce fundidas en molde de yeso mecanizadas
31121413|Objetos maquinados de cinc fundidos en molde de yeso|O|O||D||1|Piezas de zinc fundidas en molde de yeso mecanizadas
31121414|Objetos maquinados de estaño fundidos en molde de yeso|O|O||D||1|Piezas de estaño fundidas en molde de yeso mecanizadas
31121415|Objetos maquinados de plomo fundidos en molde de yeso|O|O||D||1|Piezas de plomo fundidas en molde de yeso mecanizadas
31121416|Objetos maquinados de metal precioso fundidos en molde de yeso|O|O||D||1|Piezas de metal precioso fundidas en molde de yeso mecanizadas
31121417|Objetos maquinados de compuestos fundidos en molde de yeso|O|O||D||1|Piezas de compuestos fundidas en molde de yeso mecanizadas
31121418|Objetos maquinados de aleación de níquel fundidos en molde de yeso|O|O||D||1|Piezas de aleación de níquel fundidas en molde de yeso mecanizadas
31121419|Objetos maquinados no metálicos fundidos en molde de yeso|O|O||D||1|Piezas no metálicas fundidas en molde de yeso mecanizadas
31121500|Fundiciones de molde de concha|O|O||D||1
31121501|Objetos maquinados de aleación no ferrosa fundidos en molde en concha|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de cáscara mecanizadas
31121502|Objetos maquinados de aleación ferrosa fundidos en molde en concha|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de cáscara mecanizadas
31121503|Objetos maquinados de acero fundidos en molde en concha|O|O||D||1|Piezas de acero fundidas en molde de cáscara mecanizadas
31121504|Objetos maquinados de acero inoxidable fundidos en molde en concha|O|O||D||1|Piezas de acero inoxidable fundidas en molde de cáscara mecanizadas
31121505|Objetos maquinados de hierro fundidos en molde en concha|O|O||D||1|Piezas de hierro fundidas en molde de cáscara mecanizadas
31121506|Objetos maquinados de aluminio fundidos en molde en concha|O|O||D||1|Piezas de aluminio fundidas en molde de cáscara mecanizadas
31121507|Objetos maquinados de magnesio fundidos en molde en concha|O|O||D||1|Piezas de magnesio fundidas en molde de cáscara mecanizadas
31121508|Objetos maquinados de titanio fundidos en molde en concha|O|O||D||1|Piezas de titanio fundidas en molde de cáscara mecanizadas
31121509|Objetos maquinados de berilio fundidos en molde en concha|O|O||D||1|Piezas de berilio fundidas en molde de cáscara mecanizadas
31121510|Objetos maquinados de cobre fundidos en molde en concha|O|O||D||1|Piezas de cobre fundidas en molde de cáscara mecanizadas
31121511|Objetos maquinados de latón fundidos en molde en concha|O|O||D||1|Piezas de latón fundidas en molde de cáscara mecanizadas
31121512|Objetos maquinados de bronce fundidos en molde en concha|O|O||D||1|Piezas de bronce fundidas en molde de cáscara mecanizadas
31121513|Objetos maquinados de cinc fundidos en molde en concha|O|O||D||1|Piezas de zinc fundidas en molde de cáscara mecanizadas
31121514|Objetos maquinados de estaño fundidos en molde en concha|O|O||D||1|Piezas de estaño fundidas en molde de cáscara mecanizadas
31121515|Objetos maquinados de plomo fundidos en molde en concha|O|O||D||1|Piezas de plomo fundidas en molde de cáscara mecanizadas
31121516|Objetos maquinados de metal precioso fundidos en molde en concha|O|O||D||1|Piezas de metal precioso fundidas en molde de cáscara mecanizadas
31121517|Objetos maquinados de compuestos fundidos en molde en concha|O|O||D||1|Piezas de compuestos fundidas en molde de cáscara mecanizadas
31121518|Objetos maquinados de aleación de níquel fundidos en molde en concha|O|O||D||1|Piezas de aleación de níquel fundidas en molde de cáscara mecanizadas
31121519|Objetos maquinados no metálicos fundidos en molde en concha|O|O||D||1|Piezas no metálicas fundidas en molde de cáscara mecanizadas
31121520|Objetos maquinados de hierro dúctil fundidos en molde en concha|O|O||D||1|Piezas de hierro dúctil fundidas en molde de cáscara mecanizadas
31121521|Ensamble de objetos maquinados de hierro dúctil fundidos en molde en concha|O|O||D||1|Ensamble de piezas de hierro dúctil fundidas en molde de cáscara mecanizadas
31121600|Piezas fundidas mecanizadas de inversión|O|O||D||1
31121601|Objetos maquinados de aleación no ferrosa fundidos a la cera perdida|O|O||D||1|Piezas de aleación no ferrosa fundidas a la cera perdida mecanizadas
31121602|Objetos maquinados de aleación ferrosa fundidos a la cera perdida|O|O||D||1|Piezas de aleación ferrosa fundidas a la cera perdida mecanizadas
31121603|Objetos maquinados de acero fundidos a la cera perdida|O|O||D||1|Piezas de acero fundidas a la cera perdida mecanizadas
31121604|Objetos maquinados de acero inoxidable fundidos a la cera perdida|O|O||D||1|Piezas de acero inoxidable fundidas a la cera perdida mecanizadas
31121605|Objetos maquinados de hierro fundidos a la cera perdida|O|O||D||1|Piezas de hierro fundidas a la cera perdida mecanizadas
31121606|Objetos maquinados de aluminio fundidos a la cera perdida|O|O||D||1|Piezas de aluminio fundidas a la cera perdida mecanizadas
31121607|Objetos maquinados de magnesio fundidos a la cera perdida|O|O||D||1|Piezas de magnesio fundidas a la cera perdida mecanizadas
31121608|Objetos maquinados de zinc fundidos a la cera perdida|O|O||D||1|Piezas de zinc fundidas a la cera perdida mecanizadas
31121609|Objetos maquinados de estaño fundidos a la cera perdida|O|O||D||1|Piezas de estaño fundidas a la cera perdida mecanizadas
31121610|Objetos maquinados de plomo fundidos a la cera perdida|O|O||D||1|Piezas de plomo fundidas a la cera perdida mecanizadas
31121611|Objetos maquinados de metales preciosos fundidos a la cera perdida|O|O||D||1|Piezas de metal precioso fundidas a la cera perdida mecanizadas
31121612|Objetos maquinados de titanio fundidos a la cera perdida|O|O||D||1|Piezas de titanio fundidas a la cera perdida mecanizadas
31121613|Objetos maquinados compuestos fundidos a la cera perdida|O|O||D||1|Piezas de compuestos fundidas a la cera perdida mecanizadas
31121614|Objetos maquinados de aleación de níquel fundidos a la cera perdida|O|O||D||1|Piezas de aleación de níquel fundidas a la cera perdida mecanizadas
31121615|Objetos maquinados no metálicos fundidos a la cera perdida|O|O||D||1|Piezas no metálicas fundidas a la cera perdida mecanizadas
31121616|Ensamble de objetos maquinados aluminio fundidos a la cera perdida|O|O||D||1|Ensamble de piezas de acero inoxidable  fundidas a la cera perdida mecanizadas
31121617|Objetos maquinados de aleación de acero fundidos a la cera perdida|O|O||D||1|Piezas de aleación de acero fundidas a la cera perdida mecanizadas
31121618|Ensamble de objetos maquinados aleación de acero fundidos a la cera perdida|O|O||D||1|Ensamble de piezas de aleación acero fundidas a la cera perdida mecanizadas
31121700|Piezas fundidas centrífugas mecanizadas|O|O||D||1
31121701|Objetos maquinados centrifugados de aleación no ferrosa fundidos|O|O||D||1|Piezas de aleación no ferrosa hechas mediante fundición centrífuga mecanizadas
31121702|Objetos maquinados centrifugados de aleación ferrosa fundidos|O|O||D||1|Piezas de aleación ferrosa hechas mediante fundición centrífuga mecanizadas
31121703|Objetos maquinados centrifugados de acero fundidos|O|O||D||1|Piezas de acero hechas mediante fundición centrífuga mecanizadas
31121704|Objetos maquinados centrifugados de acero inoxidable fundidos|O|O||D||1|Piezas de acero inoxidable hechas mediante fundición centrífuga mecanizadas
31121705|Objetos maquinados centrifugados de hierro fundidos|O|O||D||1|Piezas de hierro hechas mediante fundición centrífuga mecanizadas
31121706|Objetos maquinados centrifugados de aluminio fundidos|O|O||D||1|Piezas de aluminio hechas mediante fundición centrífuga mecanizadas
31121707|Objetos maquinados centrifugados de magnesio fundidos|O|O||D||1|Piezas de magnesio hechas mediante fundición centrífuga mecanizadas
31121708|Objetos maquinados centrifugados de titanio fundidos|O|O||D||1|Piezas de titanio hechas mediante fundición centrífuga mecanizadas
31121709|Objetos maquinados centrifugados de berilio fundidos|O|O||D||1|Piezas de berilio hechas mediante fundición centrífuga mecanizadas
31121710|Objetos maquinados centrifugados de cobre fundidos|O|O||D||1|Piezas de cobre hechas mediante fundición centrífuga mecanizadas
31121711|Objetos maquinados centrifugados de latón fundidos|O|O||D||1|Piezas de latón hechas mediante fundición centrífuga mecanizadas
31121712|Objetos maquinados centrifugados de bronce fundidos|O|O||D||1|Piezas de bronce hechas mediante fundición centrífuga mecanizadas
31121713|Objetos maquinados centrifugados de cinc fundidos|O|O||D||1|Piezas de zinc hechas mediante fundición centrífuga mecanizadas
31121714|Objetos maquinados centrifugados de estaño fundidos|O|O||D||1|Piezas de estaño hechas mediante fundición centrífuga mecanizadas
31121715|Objetos maquinados centrifugados de plomo fundidos|O|O||D||1|Piezas de plomo hechas mediante fundición centrífuga mecanizadas
31121716|Objetos maquinados centrifugados de metal precioso fundidos|O|O||D||1|Piezas de metal precioso hechas mediante fundición centrífuga mecanizadas
31121717|Objetos maquinados centrifugados de compuestos fundidos|O|O||D||1|Piezas de compuesto hechas mediante fundición centrífuga mecanizadas
31121718|Objetos maquinados centrifugados de aleación de níquel fundidos|O|O||D||1|Piezas de aleación de níquel hechas mediante fundición centrífuga mecanizadas
31121719|Objetos maquinados centrifugados no metálicos fundidos|O|O||D||1|Piezas no metálicas hechas mediante fundición centrífuga mecanizadas
31121800|Fundiciones labradas de molde de cerámica|O|O||D||1
31121801|Objetos maquinados de aleación no ferrosa fundidos en molde cerámico|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de cerámica mecanizadas
31121802|Objetos maquinados de aleación ferrosa fundidos en molde cerámico|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de cerámica mecanizadas
31121803|Objetos maquinados de acero fundidos en molde cerámico|O|O||D||1|Piezas de acero fundidas en molde de cerámica mecanizadas
31121804|Objetos maquinados de acero inoxidable fundidos en molde cerámico|O|O||D||1|Piezas de acero inoxidable fundidas en molde de cerámica mecanizadas
31121805|Objetos maquinados de hierro fundidos en molde cerámico|O|O||D||1|Piezas de hierro fundidas en molde de cerámica mecanizadas
31121806|Objetos maquinados de aluminio fundidos en molde cerámico|O|O||D||1|Piezas de aluminio fundidas en molde de cerámica mecanizadas
31121807|Objetos maquinados de magnesio fundidos en molde cerámico|O|O||D||1|Piezas de magnesio fundidas en molde de cerámica mecanizadas
31121808|Objetos maquinados de titanio fundidos en molde cerámico|O|O||D||1|Piezas de titanio fundidas en molde de cerámica mecanizadas
31121809|Objetos maquinados de berilio fundidos en molde cerámico|O|O||D||1|Piezas de berilio fundidas en molde de cerámica mecanizadas
31121810|Objetos maquinados de cobre fundidos en molde cerámico|O|O||D||1|Piezas de cobre fundidas en molde de cerámica mecanizadas
31121811|Objetos maquinados de latón fundidos en molde cerámico|O|O||D||1|Piezas de latón fundidas en molde de cerámica mecanizadas
31121812|Objetos maquinados de bronce fundidos en molde cerámico|O|O||D||1|Piezas de bronce fundidas en molde de cerámica mecanizadas
31121813|Objetos maquinados de cinc fundidos en molde cerámico|O|O||D||1|Piezas de zinc fundidas en molde de cerámica mecanizadas
31121814|Objetos maquinados de estaño fundidos en molde cerámico|O|O||D||1|Piezas de estaño fundidas en molde de cerámica mecanizadas
31121815|Objetos maquinados de plomo fundidos en molde cerámico|O|O||D||1|Piezas de plomo fundidas en molde de cerámica mecanizadas
31121816|Objetos maquinados de metal precioso fundidos en molde cerámico|O|O||D||1|Piezas de metal precioso fundidas en molde de cerámica mecanizadas
31121817|Objetos maquinados de compuestos fundidos en molde cerámico|O|O||D||1|Piezas de compuesto fundidas en molde de cerámica mecanizadas
31121818|Objetos maquinados de aleación de níquel fundidos en molde cerámico|O|O||D||1|Piezas de aleación de níquel fundidas en molde de cerámica mecanizadas
31121819|Objetos maquinados no metálicos fundidos en molde cerámico|O|O||D||1|Piezas no metálicas fundidas en molde de cerámica mecanizadas
31121900|Fundiciones labradas de molde de grafito|O|O||D||1
31121901|Objetos maquinados de aleación no ferrosa fundidos en molde de grafito|O|O||D||1|Piezas de aleación no ferrosa fundidas en molde de grafito mecanizadas
31121902|Objetos maquinados de aleación ferrosa fundidos en molde de grafito|O|O||D||1|Piezas de aleación ferrosa fundidas en molde de grafito mecanizadas
31121903|Objetos maquinados de acero fundidos en molde de grafito|O|O||D||1|Piezas de acero fundidas en molde de grafito mecanizadas
31121904|Objetos maquinados de acero inoxidable fundidos en molde de grafito|O|O||D||1|Piezas de acero inoxidable fundidas en molde de grafito mecanizadas
31121905|Objetos maquinados de hierro fundidos en molde de grafito|O|O||D||1|Piezas de hierro fundidas en molde de grafito mecanizadas
31121906|Objetos maquinados de aluminio fundidos en molde de grafito|O|O||D||1|Piezas de aluminio fundidas en molde de grafito mecanizadas
31121907|Objetos maquinados de magnesio fundidos en molde de grafito|O|O||D||1|Piezas de magnesio fundidas en molde de grafito mecanizadas
31121908|Objetos maquinados de titanio fundidos en molde de grafito|O|O||D||1|Piezas de titanio fundidas en molde de grafito mecanizadas
31121909|Objetos maquinados de berilio fundidos en molde de grafito|O|O||D||1|Piezas de berilio fundidas en molde de grafito mecanizadas
31121910|Objetos maquinados de cobre fundidos en molde de grafito|O|O||D||1|Piezas de cobre fundidas en molde de grafito mecanizadas
31121911|Objetos maquinados de latón fundidos en molde de grafito|O|O||D||1|Piezas de latón fundidas en molde de grafito mecanizadas
31121912|Objetos maquinados de bronce fundidos en molde de grafito|O|O||D||1|Piezas de bronce fundidas en molde de grafito mecanizadas
31121913|Objetos maquinados de cinc fundidos en molde de grafito|O|O||D||1|Piezas de zinc fundidas en molde de grafito mecanizadas
31121914|Objetos maquinados de estaño fundidos en molde de grafito|O|O||D||1|Piezas de estaño fundidas en molde de grafito mecanizadas
31121915|Objetos maquinados de plomo fundidos en molde de grafito|O|O||D||1|Piezas de plomo fundidas en molde de grafito mecanizadas
31121916|Objetos maquinados de metal precioso fundidos en molde de grafito|O|O||D||1|Piezas de metal precioso fundidas en molde de grafito mecanizadas
31121917|Objetos maquinados de compuestos fundidos en molde de grafito|O|O||D||1|Piezas de compuesto fundidas en molde de grafito mecanizadas
31121918|Objetos maquinados de aleación de níquel fundidos en molde de grafito|O|O||D||1|Piezas de aleación de níquel fundidas en molde de grafito mecanizadas
31121919|Objetos maquinados no metálicos fundidos en molde de grafito|O|O||D||1|Piezas no metálicas fundidas en molde de grafito mecanizadas
31122000|Fundiciones y ensambles de fundiciones maquinadas por apriete|O|O||D||1
31122001|Objetos maquinados de aluminio moldeados por apriete (squeeze)|O|O||D||1|Piezas de aluminio fundidas a presión mecanizadas
31122002|Ensamble de objetos maquinados de aluminio moldeados por apriete (squeeze)|O|O||D||1|Ensamble de piezas de aluminio fundidas a presión mecanizadas
31122100|Fundiciones y ensambles de fundiciones maquinadas semi - sólidas|O|O||D||1
31122101|Objetos maquinados de aluminio moldeados semisólidos|O|O||D||1|Piezas de aluminio fundidas semi - solidas mecanizadas
31122102|Ensamble de objetos maquinados de aluminio moldeados semisólidos|O|O||D||1|Ensamble de piezas de aluminio fundidas semi - solidas mecanizadas
31122200|Fundiciones y ensambles de fundiciones maquinadas por gravedad permanente|O|O||D||1
31122201|Objetos maquinados de aluminio moldeados por gravedad permanente|O|O||D||1|Piezas de aluminio fundidas en moldes permanentes a gravedad mecanizadas
31122202|Ensamble de objetos maquinados de aluminio moldeados por gravedad permanente|O|O||D||1|Ensamble de piezas de aluminio fundidas en moldes permanentes a gravedad mecanizadas
31132000|Componentes de metal en polvo|O|O||D||1
31132001|Componentes de metal ferroso pulverizado|O|O||D||1|Materia de metal ferroso en polvo
31132002|Partes de metal no ferroso pulverizado|O|O||D||1|Fracción de metal no ferroso en polvo, Pedazo de metal no ferroso en polvo, Trozo de metal no ferroso en polv
31132100|Forjas de acero|O|O||D||1|Fragua de acero
31132101|Forja de acero maquinado forjado en frío|O|O||D||1|Fragua de acero forjado en frío mecanizado
31132102|Forja de acero tratado con calor forjado en frío|O|O||D||1|Fragua de acero tratado con calor forjado en frío
31132103|Forja de acero maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de acero tratado con calor forjado en frío mecanizado
31132104|Forja de acero tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de acero tratado con calor forjado y dimensionado en frío
31132105|Forja de acero maquinado forjado en tibio|O|O||D||1|Fragua de acero forjado en tibio mecanizado
31132106|Forja de acero tratado con calor forjado en tibio|O|O||D||1|Fragua de acero tratado con calor forjado en tibio
31132107|Forja de acero maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de acero tratado con calor forjado en tibio mecanizado
31132108|Forja de acero tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de acero tratado con calor forjado en tibio y dimensionado en frío
31132109|Forja de acero maquinado forjado en caliente|O|O||D||1|Fragua de acero forjado en caliente mecanizado
31132110|Forja de acero tratado con calor forjado en caliente|O|O||D||1|Fragua de acero tratado y forjado con calor
31132111|Forja de acero maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de acero tratado y forjado con calor mecanizado
31132112|Forja de acero tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de acero tratado y forjado con calor y dimensionado en frío
31132200|Forjas de latón|O|O||D||1|Fragua de latón
31132201|Forja de latón maquinado forjado en frío|O|O||D||1|Fragua de latón forjado en frío mecanizado
31132202|Forja de latón tratado con calor forjado en frío|O|O||D||1|Fragua de latón tratado con calor forjado en frío
31132203|Forja de latón maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de latón tratado con calor forjado en frío mecanizado
31132204|Forja de latón tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de latón tratado con calor forjado y dimensionado en frío
31132205|Forja de latón maquinado forjado en tibio|O|O||D||1|Fragua de latón forjado en tibio mecanizado
31132206|Forja de latón tratado con calor forjado en tibio|O|O||D||1|Fragua de latón tratado con calor forjado en tibio
31132207|Forja de latón maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de latón tratado con calor forjado en tibio mecanizado
31132208|Forja de latón tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de latón tratado con calor forjado en tibio y dimensionado en frío
31132300|Forjas de aluminio|O|O||D||1|Fragua de aluminio
31132301|Forja de aluminio maquinado forjado en frío|O|O||D||1|Fragua de aluminio forjado en frío mecanizado
31132302|Forja de aluminio tratado con calor forjado en frío|O|O||D||1|Fragua de aluminio tratado con calor forjado en frío
31132303|Forja de aluminio maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de aluminio tratado con calor forjado en frío mecanizado
31132304|Forja de aluminio tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de aluminio tratado con calor forjado en frío y dimensionado en frío
31132305|Forja de aluminio maquinado forjado en tibio|O|O||D||1|Fragua de aluminio forjado en tibio mecanizado
31132306|Forja de aluminio tratado con calor forjado en tibio|O|O||D||1|Fragua de aluminio tratado con calor forjado en tibio
31132307|Forja de aluminio maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de aluminio tratado con calor forjado en tibio mecanizado
31132308|Forja de aluminio tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de aluminio tratado con calor forjado en tibio y dimensionado en frío
31132400|Forjas de aleaciones no ferrosas|O|O||D||1|Fragua de aleaciones no ferrosas
31132401|Forja de aleación no ferrosa maquinado forjado en frío|O|O||D||1|Fragua de aleaciones no ferrosas forjadas en frío mecanizadas
31132402|Forja de aleación no ferrosa tratado con calor forjado en frío|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas en frío
31132403|Forja de aleación no ferrosa maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas en frío mecanizadas
31132404|Forja de aleación no ferrosa tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas y dimensionadas en frío
31132405|Forja de aleación no ferrosa maquinado forjado en tibio|O|O||D||1|Fragua de aleaciones no ferrosas forjadas en tibio mecanizadas
31132406|Forja de aleación no ferrosa tratado con calor forjado en tibio|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas en tibio
31132407|Forja de aleación no ferrosa maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas en tibio mecanizadas
31132408|Forja de aleación no ferrosa tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de aleaciones no ferrosas tratadas con calor forjadas en tibio y dimensionadas en frío
31132409|Forja de aleación no ferrosa maquinado forjado en caliente|O|O||D||1|Fragua de aleaciones no ferrosas forjadas en calor mecanizadas
31132410|Forja de aleación no ferrosa tratado con calor forjado en caliente|O|O||D||1|Fragua de aleaciones no ferrosas tratadas y forjadas con calor
31132411|Forja de aleación no ferrosa maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de aleaciones no ferrosas tratadas y forjadas con calor mecanizadas
31132412|Forja de aleación no ferrosa tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de aleaciones no ferrosas tratadas y forjadas con calor y dimensionadas en frío
31132500|Forjas de aleaciones ferrosas|O|O||D||1|Fragua de aleaciones ferrosas
31132501|Forja de aleación ferrosa maquinado forjado en frío|O|O||D||1|Fragua de aleaciones ferrosas forjadas en frío mecanizadas
31132502|Forja de aleación ferrosa tratado con calor forjado en frío|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas en frío
31132503|Forja de aleación ferrosa maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas en frío mecanizadas
31132504|Forja de aleación ferrosa tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas y dimensionadas en frío
31132505|Forja de aleación ferrosa maquinado forjado en tibio|O|O||D||1|Fragua de aleaciones ferrosas forjadas en tibio mecanizadas
31132506|Forja de aleación ferrosa tratado con calor forjado en tibio|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas en tibio
31132507|Forja de aleación ferrosa maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas en tibio mecanizadas
31132508|Forja de aleación ferrosa tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de aleaciones ferrosas tratadas con calor forjadas en tibio y dimensionadas en frío
31132509|Forja de aleación ferrosa maquinado forjado en caliente|O|O||D||1|Fragua de aleaciones ferrosas forjadas en calor mecanizadas
31132510|Forja de aleación ferrosa tratado con calor forjado en caliente|O|O||D||1|Fragua de aleaciones ferrosas tratadas y forjadas con calor
31132511|Forja de aleación ferrosa maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de aleaciones ferrosas tratadas y forjadas con calor mecanizadas
31132512|Forja de aleación ferrosa tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de aleaciones ferrosas tratadas y forjadas con calor y dimensionadas en frío
31132600|Forjas de acero inoxidable|O|O||D||1|Fragua de acero inoxidable
31132601|Forja de acero inoxidable maquinado forjado en frío|O|O||D||1|Fragua de acero inoxidable forjado en frío mecanizados
31132602|Forja de acero inoxidable tratado con calor forjado en frío|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado en frío
31132603|Forja de acero inoxidable maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado en frío mecanizadas
31132604|Forja de acero inoxidable tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado y dimensionado en frío
31132605|Forja de acero inoxidable maquinado forjado en tibio|O|O||D||1|Fragua de acero inoxidable forjado en tibio mecanizados
31132606|Forja de acero inoxidable tratado con calor forjado en tibio|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado en tibio
31132607|Forja de acero inoxidable maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado en tibio mecanizado
31132608|Forja de acero inoxidable tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de acero inoxidable tratado con calor forjado en tibio y dimensionado en frío
31132609|Forja de acero inoxidable maquinado forjado en caliente|O|O||D||1|Fragua de acero inoxidable forjado en calor mecanizados
31132610|Forja de acero inoxidable tratado con calor forjado en caliente|O|O||D||1|Fragua de acero inoxidable tratado y forjado con calor
31132611|Forja de acero inoxidable maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de acero inoxidable tratado y forjado con calor mecanizados
31132612|Forja de acero inoxidable tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de acero inoxidable tratado y forjado con calor y dimensionado en frío
31132700|Forjas de hierro|O|O||D||1|Fragua de hierro
31132701|Forja de hierro maquinado forjado en frío|O|O||D||1|Fragua de hierro forjado en frío mecanizado
31132702|Forja de hierro tratado con calor forjado en frío|O|O||D||1|Fragua de hierro tratado con calor forjado en frío
31132703|Forja de hierro maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de hierro tratado con calor forjado en frío mecanizado
31132704|Forja de hierro tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de hierro tratado con calor forjado y dimensionado en frío
31132705|Forja de hierro maquinado forjado en tibio|O|O||D||1|Fragua de hierro forjado en tibio mecanizado
31132706|Forja de hierro tratado con calor forjado en tibio|O|O||D||1|Fragua de hierro tratado con calor forjado en tibio
31132707|Forja de hierro maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de hierro tratado con calor forjado en tibio mecanizado
31132708|Forja de hierro tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de hierro tratado con calor forjado en tibio y dimensionado en frío
31132709|Forja de hierro maquinado forjado en caliente|O|O||D||1|Fragua de hierro forjado en calor mecanizados
31132710|Forja de hierro tratado con calor forjado en caliente|O|O||D||1|Fragua de hierro tratado y forjado con calor
31132711|Forja de hierro maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de hierro tratado y forjado con calor mecanizados
31132712|Forja de hierro tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de hierro tratado y forjado con calor y dimensionado en frío
31132800|Forjas de magnesio|O|O||D||1|Fragua de magnesio
31132801|Forja de magnesio maquinado forjado en frío|O|O||D||1|Fragua de magnesio forjado en frío mecanizado
31132802|Forja de magnesio tratado con calor forjado en frío|O|O||D||1|Fragua de magnesio tratado con calor forjado en frío
31132803|Forja de magnesio maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de magnesio tratado con calor forjado en frío mecanizado
31132804|Forja de magnesio tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de magnesio tratado con calor forjado y dimensionado en frío
31132805|Forja de magnesio maquinado forjado en tibio|O|O||D||1|Fragua de magnesio forjado en tibio mecanizado
31132806|Forja de magnesio tratado con calor forjado en tibio|O|O||D||1|Fragua de magnesio tratado con calor forjado en tibio
31132807|Forja de magnesio maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de magnesio tratado con calor forjado en tibio mecanizado
31132808|Forja de magnesio tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de magnesio tratado con calor forjado en tibio y dimensionado en frío
31132809|Forja de magnesio maquinado forjado en caliente|O|O||D||1|Fragua de magnesio forjado en calor mecanizados
31132810|Forja de magnesio tratado con calor forjado en caliente|O|O||D||1|Fragua de magnesio tratado y forjado con calor
31132811|Forja de magnesio maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de magnesio tratado y forjado con calor mecanizados
31132812|Forja de magnesio tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de magnesio inoxidable tratado y forjado con calor y dimensionado en frío
31132900|Forjas de titanio|O|O||D||1|Fragua de titanio
31132901|Forja de titanio maquinado forjado en frío|O|O||D||1|Fragua de titanio forjado en frío mecanizado
31132902|Forja de titanio tratado con calor forjado en frío|O|O||D||1|Fragua de titanio tratado con calor forjado en frío
31132903|Forja de titanio maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de titanio tratado con calor forjado en frío mecanizado
31132904|Forja de titanio tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de titanio tratado con calor forjado y dimensionado en frío
31132905|Forja de titanio maquinado forjado en tibio|O|O||D||1|Fragua de titanio forjado en tibio mecanizado
31132906|Forja de titanio tratado con calor forjado en tibio|O|O||D||1|Fragua de titanio tratado con calor forjado en tibio
31132907|Forja de titanio maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de titanio tratado con calor forjado en tibio mecanizado
31132908|Forja de titanio tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de titanio tratado con calor forjado en tibio y dimensionado en frío
31132909|Forja de titanio maquinado forjado en caliente|O|O||D||1|Fragua de titanio forjado en calor mecanizados
31132910|Forja de titanio tratado con calor forjado en caliente|O|O||D||1|Fragua de titanio tratado y forjado con calor
31132911|Forja de titanio maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de titanio tratado y forjado con calor mecanizados
31132912|Forja de titanio tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de titanio inoxidable tratado y forjado con calor y dimensionado en frío
31133000|Forjas de berilio|O|O||D||1|Fragua de berilio
31133001|Forja de berilio maquinado forjado en frío|O|O||D||1|Fragua de berilio forjado en frío mecanizado
31133002|Forja de berilio tratado con calor forjado en frío|O|O||D||1|Fragua de berilio tratado con calor forjado en frío
31133003|Forja de berilio maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de berilio tratado con calor forjado en frio mecanizado
31133004|Forja de berilio tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de berilio tratado con calor forjado y dimensionado en frío
31133005|Forja de berilio maquinado forjado en tibio|O|O||D||1|Fragua de berilio forjado en tibio mecanizado
31133006|Forja de berilio tratado con calor forjado en tibio|O|O||D||1|Fragua de berilio tratado con calor forjado en tibio
31133007|Forja de berilio maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de berilio tratado con calor forjado en tibio mecanizado
31133008|Forja de berilio tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de berilio tratado con calor forjado en tibio y dimensionado en frío
31133009|Forja de berilio maquinado forjado en caliente|O|O||D||1|Fragua de berilio forjado en calor mecanizados
31133010|Forja de berilio tratado con calor forjado en caliente|O|O||D||1|Fragua de berilio tratado y forjado con calor
31133011|Forja de berilio maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de berilio tratado y forjado con calor mecanizados
31133012|Forja de berilio tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de berilio inoxidable tratado y forjado con calor y dimensionado en frío
31133100|Forjas de cobre|O|O||D||1|Fragua de cobre
31133101|Forja de cobre maquinado forjado en frío|O|O||D||1|Fragua de cobre forjado en frío mecanizado
31133102|Forja de cobre tratado con calor forjado en frío|O|O||D||1|Fragua de cobre tratado con calor forjado en frío
31133103|Forja de cobre maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de cobre tratado con calor forjado en frío mecanizado
31133104|Forja de cobre tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de cobre tratado con calor forjado y dimensionado en frío
31133105|Forja de cobre maquinado forjado en tibio|O|O||D||1|Fragua de cobre forjado en tibio mecanizado
31133106|Forja de cobre tratado con calor forjado en tibio|O|O||D||1|Fragua de cobre tratado con calor forjado en tibio
31133107|Forja de cobre maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de cobre tratado con calor forjado en tibio mecanizado
31133108|Forja de cobre tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de cobre tratado con calor forjado en tibio y dimensionado en frío
31133109|Forja de cobre maquinado forjado en caliente|O|O||D||1|Fragua de cobre forjado en calor mecanizados
31133110|Forja de cobre tratado con calor forjado en caliente|O|O||D||1|Fragua de cobre tratado y forjado con calor
31133111|Forja de cobre maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de cobre tratado y forjado con calor mecanizados
31133112|Forja de cobre tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de cobre inoxidable tratado y forjado con calor y dimensionado en frío
31133200|Forjas de zinc|O|O||D||1|Fragua de cinc
31133201|Forja de zinc maquinado forjado en frío|O|O||D||1|Fragua de cinc forjado en frío mecanizado
31133202|Forja de zinc tratado con calor forjado en frío|O|O||D||1|Fragua de cinc tratado con calor forjado en frío
31133203|Forja de zinc maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de cinc tratado con calor forjado en frío mecanizado
31133204|Forja de zinc tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de cinc tratado con calor forjado y dimensionado en frío
31133205|Forja de zinc maquinado forjado en tibio|O|O||D||1|Fragua de cinc forjado en tibio mecanizado
31133206|Forja de zinc tratado con calor forjado en tibio|O|O||D||1|Fragua de cinc tratado con calor forjado en tibio
31133207|Forja de zinc maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de cinc tratado con calor forjado en tibio mecanizado
31133208|Forja de zinc tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de cinc tratado con calor forjado en tibio y dimensionado en frío
31133209|Forja de zinc maquinado forjado en caliente|O|O||D||1|Fragua de cinc forjado en calor mecanizados
31133210|Forja de zinc tratado con calor forjado en caliente|O|O||D||1|Fragua de cinc tratado y forjado con calor
31133211|Forja de zinc maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de cinc tratado y forjado con calor mecanizados
31133212|Forja de zinc tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de cinc inoxidable tratado y forjado con calor y dimensionado en frío
31133300|Forjas de bronce|O|O||D||1|Fragua de bronce
31133301|Forja de bronce maquinado forjado en frío|O|O||D||1|Fragua de bronce forjado en frío mecanizado
31133302|Forja de bronce tratado con calor forjado en frío|O|O||D||1|Fragua de bronce tratado con calor forjado en frío
31133303|Forja de bronce maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de bronce tratado con calor forjado en frío mecanizado
31133304|Forja de bronce tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de bronce tratado con calor forjado y dimensionado en frío
31133305|Forja de bronce maquinado forjado en tibio|O|O||D||1|Fragua de bronce forjado en tibio mecanizado
31133306|Forja de bronce tratado con calor forjado en tibio|O|O||D||1|Fragua de bronce tratado con calor forjado en tibio
31133307|Forja de bronce maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de bronce tratado con calor forjado en tibio mecanizado
31133308|Forja de bronce tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de bronce tratado con calor forjado en tibio y dimensionado en frío
31133309|Forja de bronce maquinado forjado en caliente|O|O||D||1|Fragua de bronce forjado en calor mecanizados
31133310|Forja de bronce tratado con calor forjado en caliente|O|O||D||1|Fragua de bronce tratado y forjado con calor
31133311|Forja de bronce maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de bronce tratado y forjado con calor mecanizados
31133312|Forja de bronce tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de bronce inoxidable tratado y forjado con calor y dimensionado en frío
31133400|Forjas de estaño|O|O||D||1|Fragua de estaño
31133401|Forja de estaño maquinado forjado en frío|O|O||D||1|Fragua de estaño forjado en frío mecanizado
31133402|Forja de estaño tratado con calor forjado en frío|O|O||D||1|Fragua de estaño tratado con calor forjado en frío
31133403|Forja de estaño maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de estaño tratado con calor forjado en frío mecanizado
31133404|Forja de estaño tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de estaño tratado con calor forjado y dimensionado en frío
31133405|Forja de estaño maquinado forjado en tibio|O|O||D||1|Fragua de estaño forjado en tibio mecanizado
31133406|Forja de estaño tratado con calor forjado en tibio|O|O||D||1|Fragua de estaño tratado con calor forjado en tibio
31133407|Forja de estaño maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de estaño tratado con calor forjado en tibio mecanizado
31133408|Forja de estaño tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de estaño tratado con calor forjado en tibio y dimensionado en frío
31133409|Forja de estaño maquinado forjado en caliente|O|O||D||1|Fragua de estaño forjado en calor mecanizados
31133410|Forja de estaño tratado con calor forjado en caliente|O|O||D||1|Fragua de estaño tratado y forjado con calor
31133411|Forja de estaño maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de estaño tratado y forjado con calor mecanizados
31133412|Forja de estaño tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de estaño inoxidable tratado y forjado con calor y dimensionado en frío
31133500|Forjas de plomo|O|O||D||1|Fragua de plomo
31133501|Forja de plomo maquinado forjado en frío|O|O||D||1|Fragua de plomo forjado en frío mecanizado
31133502|Forja de plomo tratado con calor forjado en frío|O|O||D||1|Fragua de plomo tratado con calor forjado en frío
31133503|Forja de plomo maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de plomo tratado con calor forjado en frío mecanizado
31133504|Forja de plomo tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de plomo tratado con calor forjado y dimensionado en frío
31133505|Forja de plomo maquinado forjado en tibio|O|O||D||1|Fragua de plomo forjado en tibio mecanizado
31133506|Forja de plomo tratado con calor forjado en tibio|O|O||D||1|Fragua de plomo tratado con calor forjado en tibio
31133507|Forja de plomo maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de plomo tratado con calor forjado en tibio mecanizado
31133508|Forja de plomo tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de plomo tratado con calor forjado en tibio y dimensionado en frío
31133509|Forja de plomo maquinado forjado en caliente|O|O||D||1|Fragua de plomo forjado en calor mecanizados
31133510|Forja de plomo tratado con calor forjado en caliente|O|O||D||1|Fragua de plomo tratado y forjado con calor
31133511|Forja de plomo maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de plomo tratado y forjado con calor mecanizados
31133512|Forja de plomo tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de plomo inoxidable tratado y forjado con calor y dimensionado en frío
31133600|Forjas de metales preciosos|O|O||D||1|Fragua de metales preciosas
31133601|Forja de metal precioso maquinado forjado en frío|O|O||D||1|Fragua de metal precioso forjado en frío mecanizado
31133602|Forja de metal precioso tratado con calor forjado en frío|O|O||D||1|Fragua de metal precioso tratado con calor forjado en frío
31133603|Forja de metal precioso maquinado y tratado con calor forjado en frío|O|O||D||1|Fragua de metal precioso tratado con calor forjado en frío mecanizado
31133604|Forja de metal precioso tratado con calor y dimensionado en frío forjado en frío|O|O||D||1|Fragua de metal precioso tratado con calor forjado y dimensionado en frío
31133605|Forja de metal precioso maquinado forjado en tibio|O|O||D||1|Fragua de metal precioso forjado en tibio mecanizado
31133606|Forja de metal precioso tratado con calor forjado en tibio|O|O||D||1|Fragua de metal precioso tratado con calor forjado en tibio
31133607|Forja de metal precioso maquinado y tratado con calor forjado en tibio|O|O||D||1|Fragua de metal precioso tratado con calor forjado en tibio mecanizado
31133608|Forja de metal precioso tratado con calor y dimensionado en frío forjado en tibio|O|O||D||1|Fragua de metal precioso tratado con calor forjado en tibio y dimensionado en frío
31133609|Forja de metal precioso maquinado forjado en caliente|O|O||D||1|Fragua de metal precioso forjado en calor mecanizados
31133610|Forja de metal precioso tratado con calor forjado en caliente|O|O||D||1|Fragua de metal precioso tratado y forjado con calor
31133611|Forja de metal precioso maquinado y tratado con calor forjado en caliente|O|O||D||1|Fragua de metal precioso tratado y forjado con calor mecanizados
31133612|Forja de metal precioso tratado con calor y dimensionado en frío forjado en caliente|O|O||D||1|Fragua de metal precioso inoxidable tratado y forjado con calor y dimensionado en frío
31133700|Metales en polvos y aleaciones de metal|O|O||D||1|Metales y aleaciones de metal pulverizados
31133701|Fricción material de metal en polvo y aleación de metal|O|O||D||1|Material de fricción de metal y aleaciones de metal pulverizados
31133702|Contacto eléctrico de metal en polvo y aleación de metal|O|O||D||1|Contacto eléctrico de metal y aleaciones de metal pulverizados
31133703|Carburo cementado de metal en polvo y aleación de metal|O|O||D||1|Carburo cementado de metal y aleaciones de metal pulverizados
31133704|Matriz metal diamante de metal en polvo y aleación de metal|O|O||D||1|Matriz de metal de diamante de metal y aleaciones de metal pulverizados
31133705|Recubrimiento conformal de silicona|O|O||D||1|Revestimiento conformal de silicón
31133706|Recubrimiento conformal de acrílico|O|O||D||1|Revestimiento conformal de acrílico
31133707|Recubrimiento conformal de poliuretano|O|O||D||1|Revestimiento conformal de poliuretano
31133708|Recubrimiento conformal de epóxido|O|O||D||1|Revestimiento conformal de epóxido
31133709|Recubrimiento conformal de parilene|O|O||D||1|Revestimiento conformal de pariele
31133710|Sellante de silicona|O|O||D||1|Sellante de silicón
31133711|Sellante de poliuretano|O|O||D||1
31141500|Molduras por inyección|O|O||D||1
31141501|Molduras por inyección de plástico|O|O||D||1
31141502|Molduras por inyección de caucho|O|O||D||1
31141503|Molduras por inyección de vidrio|O|O||D||1
31141600|Molduras al vacío|O|O||D||1
31141601|Molduras al vacío de plástico|O|O||D||1
31141602|Molduras al vacío de caucho|O|O||D||1
31141603|Molduras al vacío de vidrio|O|O||D||1
31141700|Moldeados por inyección de aire|O|O||D||1|Molduras por soplado
31141701|Moldeados plásticos por inyección de aire|O|O||D||1|Moldura plásticos por soplado
31141702|Moldeados de caucho por inyección de aire|O|O||D||1|Moldura de caucho por soplado
31141800|Moldeos por inyección y reacción (RIM)|O|O||D||1|Moldura de inyección con reacción RIM
31141801|Moldeados de inyección de reacción de plástico|O|O||D||1|Moldura de inyección con reacción de plástico
31141802|Moldeados de inyección de reacción de caucho|O|O||D||1|Moldura de inyección con reacción de caucho
31141900|Moldeados de inyección con inserción|O|O||D||1|Moldura de inyección con inserción
31141901|Moldeado plástico con inserción previa a la inyección|O|O||D||1|Moldura de plástico de inyección con inserción
31142000|Ensambles de moldeados termoplásticos|O|O||D||1|Ensambles de moldura termoplásticos
31142001|Ensamble de moldeado termoplástico por compresión|O|O||D||1|Ensambles de moldura termoplásticos por compresión
31142002|Ensamble de moldeado termoplástico por inmersión|O|O||D||1|Ensambles de moldura termoplásticos por inmersión
31142003|Ensamble de moldeado termoplástico por aire|O|O||D||1|Ensambles de moldura termoplásticos por aire
31142004|Ensamble de moldeado termoplástico por inyección|O|O||D||1|Ensambles de moldura termoplásticos por inyección
31142005|Ensamble de moldeado termoplástico por inyección asistida por gas|O|O||D||1|Ensambles de moldura termoplásticos por inyección asistida por gas
31142006|Ensamble de moldeado termoplástico por inyección de alta precisión|O|O||D||1|Ensambles de moldura termoplásticos por inyección de alta precisión
31142007|Ensamble de moldeado termoplástico por transferencia|O|O||D||1|Ensambles de moldura termoplásticos por transferencia
31142100|Engastes de moldeado termoplástico|O|O||D||1
31142101|Engaste de moldeado termoplástico por compresión|O|O||D||1|Moldeo de polímeros por compresión
31142102|Engaste de moldeado termoplástico por inmersión|O|O||D||1|Moldeo de polímeros por inmersión
31142103|Engaste de moldeado termoplástico por aire|O|O||D||1|Moldeo de polímeros por aire
31142104|Engaste de moldeado termoplástico por inyección|O|O||D||1|Moldeo de polímeros por inyección
31142105|Engaste de moldeado termoplástico por inyección asistida por gas|O|O||D||1|Moldeo de polímeros por inyección asistida por gas
31142106|Engaste de moldeado termoplástico por inyección de alta precisión|O|O||D||1|Moldeo de polímeros por inyección de alta precisión
31142107|Engaste de moldeado termoplástico por transferencia|O|O||D||1|Moldeo de polímeros por transferencia
31142200|Ensambles de engastes termoplástico moldeado por disparo múltiple|O|O||D||1
31142201|Ensamble de engaste termoplástico moldeado por disparo múltiple por compresión|O|O||D||1|Montura de polímeros por   disparo múltiple por compresión
31142202|Ensamble de engaste termoplástico moldeado por disparo múltiple por inmersión|O|O||D||1|Montura de polímeros por disparo múltiple por inmersión
31142203|Ensamble de engaste termoplástico moldeado por disparo múltiple por aire|O|O||D||1|Montura de polímeros por disparo múltiple por aire
31142204|Ensamble de engaste termoplástico moldeado por disparo múltiple por inyección|O|O||D||1|Montura de polímeros por disparo múltiple por inyección
31142205|Ensamble de engaste termoplástico moldeado por disparo múltiple por inyección asistida por gas|O|O||D||1|Montura de polímeros por disparo múltiple por inyección asistida por gas
31142206|Ensamble de engaste termoplástico moldeado por disparo múltiple por inyección de alta precisión|O|O||D||1|Montura de polímeros por disparo múltiple por inyección de alta precisión
31142207|Ensamble de engaste termoplástico moldeado por disparo múltiple por transferencia|O|O||D||1|Montura de polímeros por disparo múltiple por transferencia
31142300|Ensambles de engastes termoplástico moldeado por inyección|O|O||D||1
31142301|Ensamble de engaste termoplástico moldeado por compresión|O|O||D||1|Montura de polímeros por compresión
31142302|Ensamble de engaste termoplástico moldeado por inmersión|O|O||D||1|Montura de polímeros por inmersión
31142303|Ensamble de engaste termoplástico moldeado por aire|O|O||D||1|Montura de polímeros por aire
31142304|Ensamble de engaste termoplástico moldeado por inyección|O|O||D||1|Montura de polímeros por inyección
31142305|Ensamble de engaste termoplástico moldeado por inyección asistida por gas|O|O||D||1|Montura de polímeros por inyección asistida por gas
31142306|Ensamble de engaste termoplástico moldeado por inyección de alta precisión|O|O||D||1|Montura de polímeros por inyección de alta precisión
31142307|Ensamble de engaste termoplástico moldeado por transferencia|O|O||D||1|Montura de polímeros por transferencia
31142400|Ensambles de moldeado termofraguado|O|O||D||1
31142401|Ensamble de moldeado termofraguado por compresión|O|O||D||1|Ensamble de moldeo termoestable por compresión
31142402|Ensamble de moldeado termofraguado por inmersión|O|O||D||1|Ensamble de moldeo termoestable por inmersión
31142403|Ensamble de moldeado termofraguado por aire|O|O||D||1|Ensamble de moldeo termoestable por aire
31142404|Ensamble de moldeado termofraguado por inyección|O|O||D||1|Ensamble de moldeo termoestable por inyección
31142405|Ensamble de moldeado termofraguado por inyección asistida por gas|O|O||D||1|Ensamble de moldeo termoestable por inyección asistida por gas
31142406|Ensamble de moldeado termofraguado por inyección de alta precisión|O|O||D||1|Ensamble de moldeo termoestable por inyección de alta precisión
31142407|Ensamble de moldeado termofraguado por transferencia|O|O||D||1|Ensamble de moldeo termoestable por transferencia
31142500|Engastes de moldeado termofraguado|O|O||D||1
31142501|Engaste de moldeado termofraguado por compresión|O|O||D||1|Moldeo termoestable por compresión
31142502|Engaste de moldeado termofraguado por inmersión|O|O||D||1|Moldeo termoestable por inmersión
31142503|Engaste de moldeado termofraguado por aire|O|O||D||1|Moldeo termoestable por aire
31142504|Engaste de moldeado termofraguado por inyección|O|O||D||1|Moldeo termoestable por inyección
31142505|Engaste de moldeado termofraguado por inyección asistida por gas|O|O||D||1|Moldeo termoestable por inyección asistida por gas
31142506|Engaste de moldeado termofraguado por inyección de alta precisión|O|O||D||1|Moldeo termoestable por inyección de alta precisión
31142507|Engaste de moldeado termofraguado por transferencia|O|O||D||1|Moldeo termoestable por transferencia
31142600|Ensambles de engaste termofraguado moldeado por disparo múltiple|O|O||D||1
31142601|Ensamble de engaste termofraguado moldeado por disparo múltiple por compresión|O|O||D||1|Ensamblaje de molduras termoestables por disparo múltiple por compresión
31142602|Ensamble de engaste termofraguado moldeado por disparo múltiple por inmersión|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por inmersión
31142603|Ensamble de engaste termofraguado moldeado por disparo múltiple por aire|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por aire
31142604|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección
31142605|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección asistida por gas|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección asistida por gas
31142606|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección de alta precisión|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por inyección de alta precisión
31142607|Ensamble de engaste termofraguado moldeado por disparo múltiple por transferencia|O|O||D||1|Ensamble de engaste termofraguado moldeado por disparo múltiple por transferencia
31142700|Ensambles de engaste termofraguado moldeado|O|O||D||1
31142701|Ensamble de engaste termofraguado moldeado por compresión|O|O||D||1|Ensamblaje de molduras termoestables por compresión
31142702|Ensamble de engaste termofraguado moldeado por inmersión|O|O||D||1|Ensamblaje de molduras termoestables por inmersión
31142703|Ensamble de engaste termofraguado moldeado por aire|O|O||D||1|Ensamblaje de molduras termoestables por aire
31142704|Ensamble de engaste termofraguado moldeado por inyección|O|O||D||1|Ensamblaje de molduras termoestables por inyección
31142705|Ensamble de engaste termofraguado moldeado por inyección asistida por gas|O|O||D||1|Ensamblaje de molduras termoestables por inyección asistida por gas
31142706|Ensamble de engaste termofraguado moldeado por inyección de alta precisión|O|O||D||1|Ensamblaje de molduras termoestables por inyección de alta precisión
31142707|Ensamble de engaste termofraguado moldeado por transferencia|O|O||D||1|Ensamblaje de molduras termoestables por transferencia
31142800|Moldeados por inmersión|O|O||D||1
31142801|Moldeado por inmersión de plástico o plastisol|O|O||D||1
31142802|Moldeado por inmersión de látex|O|O||D||1
31142803|Moldeado por inmersión de neopreno|O|O||D||1
31142804|Moldeado por inmersión de uretano|O|O||D||1
31142900|Moldeados decorados en el molde por inyección|O|O||D||1
31142901|Aplique en molde para moldeado por inyección|O|O||D||1|Aplicación en molde para moldear por inyección
31142902|Tinta en molde para traspaso por moldeo por inyección|O|O||D||1
31142903|Molde para moldeado por inyección de color|O|O||D||1
31142904|Moldeado por inyección de disparos múltiples|O|O||D||1
31143000|Moldeados asistidos por gas|O|O||D||1
31143001|Moldeado de plástico asistido por gas|O|O||D||1
31143002|Moldeado de espuma estructural asistido por gas|O|O||D||1
31143100|Ensambles de moldeado termoplástico terminados|O|O||D||1
31143101|Ensamble de moldeado termoplástico terminado por inyección|O|O||D||1|Ensamble de molde de polímero terminado por inyección
31143102|Ensamble de moldeado termoplástico terminado por compresión|O|O||D||1|Ensamble de molde de polímero terminado por compresión
31143103|Ensamble de moldeado termoplástico terminado por inyección asistida por gas|O|O||D||1|Ensamble de molde de polímero terminado por inyección asistida por gas
31143200|Moldeados decorados por inyección post moldeado|O|O||D||1
31143201|Moldeado por inyección pintado|O|O||D||1
31143202|Moldeado por inyección plateado|O|O||D||1|Moldeado por inyección cromado
31143203|Moldeado por inyección metalizado|O|O||D||1
31143204|Moldeado por inyección tratado con láser|O|O||D||1
31143205|Moldeado por inyección pintado y tratado con láser|O|O||D||1
31151500|Cuerdas|O|O||D||1
31151501|Cuerda de algodón|O|O||D||1|Lazo de algodón, Soga de algodón
31151502|Cuerda de poliéster|O|O||D||1|Lazo de poliéster, Soga de poliéster
31151503|Cuerda de polipropileno|O|O||D||1|Lazo de polipropileno, Soga de polipropileno
31151504|Cuerda de nylon|O|O||D||1|Lazo de nylon, Soga de nylon
31151505|Cable de acero|O|O||D||1
31151506|Cuerda de cáñamo|O|O||D||1
31151507|Cuerda o pita|O|O||D||1
31151508|Cabuya|O|O||D||1|Cuerda de ixtle
31151509|Cuerda de caucho|O|O||D||1|Soga de caucho
31151510|Cuerda de rayón|O|O||D||1|Soga de rayón
31151511|Cuerda de lino|O|O||D||1|Soga de lino
31151512|Cuerda de polietileno|O|O||D||1
31151513|Cuerda de fibra de coco|O|O||D||1
31151514|Cuerda de yute|O|O||D||1
31151515|Cuerda de esparto|O|O||D||1|Mecate
31151516|Cuerda de rafia|O|O||D||1|Mecate
31151517|Cuerda de aloe|O|O||D||1
31151518|Cuerda impregnada|O|O||D||1
31151519|Cuerda de látex|O|O||D||1
31151520|Cuerda de vinylon|O|O||D||1|Cuerda de vinalón
31151521|Cuerda de asbesto|O|O||D||1
31151600|Cadenas|O|O||D||1
31151601|Cadenas de seguridad|O|O||D||1
31151603|Cadenas de rodillos|O|O||D||1
31151604|Cadenas resistentes de bobina|O|O||D||1
31151605|Cadenas de banda|O|O||D||1
31151606|Cadena "jack"|O|O||D||1
31151607|Cadenas corrientes|O|O||D||1
31151608|Cadenas de bola|O|O||D||1
31151609|Eslabones de cadena|O|O||D||1
31151610|Cadena de pasador hueco|O|O||D||1|Cadena de rodillos
31151611|Cadena silenciosa|O|O||D||1
31151612|Cadena de bloque|O|O||D||1
31151613|Cadena de ingeniería|O|O||D||1
31151614|Cadena transportadora|O|O||D||1
31151615|Cadena de rodillo o sobre placa|O|O||D||1
31151616|Cadena tipo muela|O|O||D||1
31151617|Cadena draga línea|O|O||D||1
31151618|Cadena de muro alto|O|O||D||1
31151619|Cadena de escalón de escalera eléctrica|O|O||D||1
31151700|Cable mecánico|O|O||D||1
31151702|Cables de control no eléctrico|O|O||D||1
31151703|Cables elevadores|O|O||D||1
31151704|Cable-vías|O|O||D||1
31151705|Cable de acero no eléctrico|O|O||D||1
31151706|Cable de cobre no eléctrico|O|O||D||1
31151707|Cable de aluminio no eléctrico|O|O||D||1
31151708|Cable guy|O|O||D||1
31151709|Cable de hierro no eléctrico|O|O||D||1
31151710|Cable sintético|O|O||D||1
31151800|Alambre mecánico|O|O||D||1
31151803|Cuerda de acero para piano|O|O||D||1
31151804|Alambre de grapa|O|O||D||1
31151805|Alambre de multi – filamentos|O|O||D||1
31151806|Alambre laminado|O|O||D||1
31151900|Correas|O|O||D||1
31151901|Correas de metal|O|O||D||1
31151902|Correas de cuero|O|O||D||1
31151903|Correas de fibra|O|O||D||1
31151904|Correas plásticas|O|O||D||1
31151905|Correas de caucho|O|O||D||1
31151906|Correas para amarrar los raches|O|O||D||1|Correa de amarre con trinquete
31152000|Cable de seguridad|O|O||D||1
31152001|Alambre de navaja|O|O||D||1|Correa de amarre con gancho
31152002|Alambre de púas|O|O||D||1|Alambre navaja
31152100|Cordones|O|O||D||1
31152101|Cordón de algodón|O|O||D||1
31152102|Cordón de nylon|O|O||D||1
31152103|Cordón metálico|O|O||D||1
31152104|Cordón de silicona|O|O||D||1
31152105|Cordón de látex|O|O||D||1
31152106|Cordón de poliéster|O|O||D||1
31152107|Cordón de neopreno|O|O||D||1
31152108|Cordón de polipropileno|O|O||D||1
31152109|Cordón de caucho|O|O||D||1
31152110|Cordón de asbesto|O|O||D||1
31152111|Cordón de fibra de vidrio|O|O||D||1
31152112|Cordón de fibra cerámica|O|O||D||1
31152200|Alambres no eléctricos de hierro y acero|O|O||D||1
31152201|Cable de acero bajo en carbono|O|O||D||1
31152202|Cable de acero semiduro|O|O||D||1|Alambre recocido
31152203|Cable de acero inoxidable|O|O||D||1|Alambre de acero semiduro
31152204|Cable de acero trenzado|O|O||D||1|Alambre de acero inoxidable
31152205|Cable de acero templado con aceite|O|O||D||1|Alambre de acero tipo trenzado
31152206|Cable de acero recubierto|O|O||D||1
31152207|Cable de acero de concreto pretensado|O|O||D||1
31152208|Cable de acero de concreto pretensado trenzado|O|O||D||1
31152209|Alambre de hierro|O|O||D||1
31152300|Alambres no eléctricos de metales no ferrosos|O|O||D||1
31152301|Alambre de plomo o aleación de plomo|O|O||D||1
31152302|Alambre de níquel o aleación de níquel|O|O||D||1
31152303|Alambre de aleación nicromo|O|O||D||1
31152304|Alambre de cobre o aleación de cobre|O|O||D||1
31152305|Alambre de aluminio o aleación de aluminio|O|O||D||1
31152306|Alambre de estaño o aleación de estaño|O|O||D||1
31152307|Alambre de titanio o aleación de titanio|O|O||D||1
31161500|Tornillos|O|O||D||1
31161501|Tornillos de perno|O|O||D||1
31161502|Tornillos de anclaje|O|O||D||1
31161503|Clavo-tornillo|O|O||D||1|Pija
31161504|Tornillos de máquina|O|O||D||1|Tornillo con punta de clavo
31161505|Tornillos de presión|O|O||D||1
31161506|Tornillos para lámina metálica|O|O||D||1
31161507|Tornillos roscadores|O|O||D||1
31161508|Tornillos de rosca para madera|O|O||D||1
31161509|Tornillos para drywall|O|O||D||1
31161510|Tornillo cautivo|O|O||D||1|Pija, Tornillos para tablaroca
31161511|Tornillos de apriete|O|O||D||1|Pija
31161512|Tornillos de rosca para laminados|O|O||D||1
31161513|Tornillos de cabeza perdida|O|O||D||1
31161514|Tornillos de soldadura|O|O||D||1
31161516|Tornillo de orejas|O|O||D||1
31161517|Tornillo de hombros|O|O||D||1
31161518|Tornillo de enchufe|O|O||D||1
31161519|Tornillo de balde elevador|O|O||D||1
31161520|Tornillo de cabeza hexagonal|O|O||D||1
31161521|Tornillo de carruaje|O|O||D||1
31161522|Tornillo de ojo|O|O||D||1
31161523|Tronillo de ala|O|O||D||1|Tornillo mariposa
31161524|Tornillo decorativo|O|O||D||1
31161525|Tornillo para plástico|O|O||D||1
31161526|Tornillo de concreto|O|O||D||1
31161527|Tornillo en t o cabeza de martillo|O|O||D||1
31161528|Tornillo auto – entrante|O|O||D||1
31161529|Tornillo de gato|O|O||D||1|Tornillo barrenado
31161530|Tornillo grub|O|O||D||1|Tornillo mecánico de gato
31161531|Tornillo especializado|O|O||D||1|Tornillo para excavar
31161532|Tornillo allen|O|O||D||1
31161533|Tornillo con arandela ensamblada|O|O||D||1
31161534|Tornillo de rosca trapezoidal|O|O||D||1|Pija, Tornillo con rondana
31161600|Pernos|O|O||D||1
31161601|Pernos de anclaje|O|O||D||1
31161602|Pernos ciegos|O|O||D||1|Armella
31161603|Pernos de carruaje|O|O||D||1
31161604|Pernos de horquilla|O|O||D||1|Tornillo carrocería
31161605|Pernos de cilindro|O|O||D||1
31161606|Cerrojos de puerta|O|O||D||1
31161607|Pernos de expansión|O|O||D||1
31161608|Tirafondos|O|O||D||1|Taquete de expansión
31161609|Tornillo de fiador|O|O||D||1|Perno tirafondo
31161610|Pernos de ojo|O|O||D||1
31161611|Pernos de sujeción|O|O||D||1
31161612|Pernos de espiga o de reborde|O|O||D||1
31161613|Pernos de tensión|O|O||D||1
31161614|Pernos estructurales|O|O||D||1
31161616|Pernos en u|O|O||D||1
31161617|Pernos de ala|O|O||D||1|Abrazadera tipo U
31161618|Varilla roscada|O|O||D||1|Tornillo mariposa
31161619|Pernos prisioneros|O|O||D||1|Varilla barrenada
31161620|Pernos de cabeza hexagonal|O|O||D||1
31161621|Pernos elevadores|O|O||D||1
31161622|Perno de cizalla|O|O||D||1
31161623|Perno de cable|O|O||D||1|Tornillo de cizalla
31161624|Perno de resina|O|O||D||1
31161625|Perno de carrilera|O|O||D||1
31161626|Perno sems de cabeza plana|O|O||D||1
31161627|Ensamble de pernos|O|O||D||1
31161628|Perno de cabeza cuadrada|O|O||D||1
31161629|Perno de cabeza redonda|O|O||D||1
31161630|Perno en blanco|O|O||D||1
31161631|Perno de hombro|O|O||D||1
31161632|Perno de roca|O|O||D||1
31161633|Perno de estufa|O|O||D||1
31161634|Perno de sobre – cuello|O|O||D||1
31161635|Perno con arandela ensamblada|O|O||D||1
31161636|Perno de soldadura|O|O||D||1
31161637|Perno de cabeza de enchufe|O|O||D||1
31161638|Perno t|O|O||D||1
31161639|Perno de gancho|O|O||D||1
31161640|Perno garfio|O|O||D||1
31161700|Tuercas|O|O||D||1
31161701|Tuercas de anclaje|O|O||D||1
31161702|Tuercas de rodamiento|O|O||D||1
31161703|Tuercas ciegas|O|O||D||1|Tuerca balero
31161704|Tuercas de cañón|O|O||D||1
31161705|Tuerca tapa|O|O||D||1
31161706|Tuercas cautivas|O|O||D||1
31161707|Tuercas almenadas|O|O||D||1
31161708|Tuercas de canal|O|O||D||1
31161709|Tuercas sujetadoras|O|O||D||1
31161710|Tuercas de expansión|O|O||D||1
31161711|Tuercas de ojo|O|O||D||1
31161712|Tuercas de brida|O|O||D||1
31161713|Tuercas de manguera|O|O||D||1
31161714|Tuercas de inserción|O|O||D||1
31161716|Contratuercas|O|O||D||1
31161717|Tuercas de aletas|O|O||D||1
31161718|Tuercas de fiador|O|O||D||1|Tuercas de mariposa
31161719|Tuercas giratorias|O|O||D||1
31161720|Tuercas limitadoras|O|O||D||1
31161721|Tuercas de resorte|O|O||D||1|Tuercas unión macho con macho
31161722|Tuercas de unión|O|O||D||1
31161723|Tuercas de placa con rosca|O|O||D||1
31161724|Tuercas de prensa|O|O||D||1|Tuerca de clip
31161725|Tuercas abrazaderas|O|O||D||1
31161726|Tuercas domo|O|O||D||1
31161727|Tuercas hexagonales|O|O||D||1
31161728|Tuercas de acople|O|O||D||1
31161729|Tuercas estriadas|O|O||D||1
31161730|Tuercas cuadradas|O|O||D||1
31161731|Tuercas soldables|O|O||D||1
31161732|Tuerca medialuna|O|O||D||1
31161733|Tuerca en t o ranura de tuerca en t|O|O||D||1
31161734|Tuerca redonda con ranura|O|O||D||1
31161735|Tuerca de jaula|O|O||D||1
31161736|Tapa de tuerca decorativa|O|O||D||1
31161737|Tuerca de cizalla|O|O||D||1
31161738|Tuerca keps o k|O|O||D||1
31161739|Tuerca de soldadura|O|O||D||1|Tuerca dentada
31161740|Tuerca perno|O|O||D||1
31161741|Tuerca de llave interna|O|O||D||1|Tornillo con tuerca
31161800|Arandelas|O|O||D||1|Rondanas
31161801|Arandelas de seguridad|O|O||D||1|Rondanas de seguridad
31161802|Arandelas achaflanadas|O|O||D||1
31161803|Arandelas de fijación|O|O||D||1|Rondanas de fijación
31161804|Arandelas curvas|O|O||D||1|Rondanas curvas
31161805|Arandelas aislantes eléctricas|O|O||D||1|Rondanas aislantes
31161806|Arandelas de acabado|O|O||D||1|Rondanas de acabado
31161807|Arandelas planas|O|O||D||1|Rondanas planas
31161808|Arandelas abiertas|O|O||D||1|Rondanas abiertas
31161809|Arandelas reductoras|O|O||D||1|Rondanas reductoras
31161810|Arandelas de separación|O|O||D||1|Rondanas de separación
31161811|Arandelas de resorte|O|O||D||1|Rondanas de resorte
31161812|Arandelas cuadradas|O|O||D||1|Rondanas cuadradas
31161813|Arandelas giratorias|O|O||D||1|Rondanas giratorias
31161814|Arandelas de empuje|O|O||D||1|Rondanas de empuje
31161815|Arandelas de tope|O|O||D||1|Rondanas de tope
31161816|Espaciadores y separadores|O|O||D||1
31161817|Arandelas cónicas|O|O||D||1|Empaque cónico
31161818|Arandelas de sellado|O|O||D||1|Empaque de sellado
31161819|Juegos de arandelas|O|O||D||1
31161820|Arandelas en domo o esféricas|O|O||D||1
31161821|Arandela roscada|O|O||D||1|Rondana roscada
31161822|Arandelas con dientes de seguridad|O|O||D||1
31161823|Arandela distribuidora|O|O||D||1
31161824|Arandela para perno de techo|O|O||D||1
31161825|Arandela belleville|O|O||D||1
31161826|Arandela dentada|O|O||D||1
31161827|Arandela recortada|O|O||D||1
31161828|Arandela con ranura|O|O||D||1
31161829|Arandela retenedora|O|O||D||1
31161830|Arandelas de ola|O|O||D||1
31161831|Arandela reductora de vibración|O|O||D||1
31161832|Arandelas avellanadas|O|O||D||1
31161833|Arandela empaque|O|O||D||1
31161834|Arandelas de copa|O|O||D||1
31161835|Arandelas de pestaña|O|O||D||1
31161836|Arandelas de placa de anclaje|O|O||D||1
31161837|Arandelas de división|O|O||D||1
31161838|Arandelas lenguadas|O|O||D||1
31161900|Muelles|O|O||D||1
31161901|Muelles helicoidales|O|O||D||1|Resortes
31161902|Muelles|O|O||D||1
31161903|Muelles espirales|O|O||D||1
31161904|Resortes de compresión|O|O||D||1
31161905|Resortes para estampas|O|O||D||1
31161906|Muelles de disco|O|O||D||1
31161907|Muelles de extensión|O|O||D||1
31161908|Muelles de torsión|O|O||D||1
31161909|Muelle en ola|O|O||D||1
31161910|Resorte de alambre|O|O||D||1
31161911|Ensamble de resorte|O|O||D||1
31161912|Resorte de válvula inyectora|O|O||D||1
31162000|Clavos|O|O||D||1
31162001|Chinches|O|O||D||1|Tachuelas
31162002|Clavos de sombrerete|O|O||D||1|Remaches
31162003|Clavos de acabado|O|O||D||1
31162004|Clavos de mampostería|O|O||D||1|Clavos para concreto u hormigón
31162005|Clavos para tejados|O|O||D||1
31162006|Clavos de alambre|O|O||D||1
31162007|Clavos de tapicería|O|O||D||1
31162008|Pasadores de arrastre|O|O||D||1
31162009|Clavo de fibra cemento|O|O||D||1
31162010|Clavo de herradura|O|O||D||1
31162011|Puntilla decorativa|O|O||D||1
31162012|Clavo de levantamientos topográficos|O|O||D||1
31162013|Clave de botes|O|O||D||1
31162014|Clavo ferroviario|O|O||D||1
31162100|Anclas|O|O||D||1
31162101|Anclajes de concreto|O|O||D||1
31162102|Anclajes de cuña|O|O||D||1
31162103|Anclajes de pared|O|O||D||1
31162104|Anclajes de tornillo|O|O||D||1
31162105|Anclajes de resina|O|O||D||1
31162106|Anclaje de tubería|O|O||D||1
31162107|Anclajes de expansión de clavo|O|O||D||1
31162108|Anclajes de amarre|O|O||D||1
31162109|Anclaje de cimentación|O|O||D||1
31162200|Remaches|O|O||D||1
31162201|Remaches ciegos|O|O||D||1
31162202|Remaches de corona|O|O||D||1
31162203|Remaches de cabeza plana|O|O||D||1
31162204|Remaches completos|O|O||D||1
31162205|Remaches de trinquetes|O|O||D||1
31162206|Remaches de estañador|O|O||D||1
31162207|Remaches de compresión|O|O||D||1
31162208|Remaches de tonelero|O|O||D||1
31162209|Remaches de botón|O|O||D||1
31162210|Remaches articulados|O|O||D||1
31162211|Remaches sólidos|O|O||D||1
31162212|Remache con mandril|O|O||D||1
31162213|Remache aerodinámico|O|O||D||1
31162214|Remache semi – tubular|O|O||D||1
31162215|Remache tubular|O|O||D||1
31162216|Remache de hombro|O|O||D||1
31162300|Ferretería de montaje|O|O||D||1
31162301|Perfiles de montaje|O|O||D||1
31162303|Barras de montaje|O|O||D||1
31162304|Regletas de montaje|O|O||D||1
31162305|Abrazaderas de montaje|O|O||D||1
31162306|Soportes colgantes de montaje|O|O||D||1
31162307|Placas de montaje|O|O||D||1
31162308|Paneles de montaje|O|O||D||1
31162309|Estantes de montaje|O|O||D||1
31162310|Correas de montaje|O|O||D||1
31162311|Bujes de pared|O|O||D||1
31162312|Pasadores de montaje|O|O||D||1
31162313|Kits de montaje|O|O||D||1
31162314|Espaciador de baldosas|O|O||D||1
31162400|Fijadores varios|O|O||D||1
31162401|Aros interiores|O|O||D||1
31162402|Cerraduras|O|O||D||1
31162403|Goznes o bisagras|O|O||D||1
31162404|Grapas|O|O||D||1
31162405|Tensores|O|O||D||1
31162406|Cierres para zunchado|O|O||D||1|Sujetador de estructuras verticales.
31162407|Pestillo|O|O||D||1|Cerrojo, Pasador
31162409|Pasador de horquilla|O|O||D||1
31162410|Pasadores estriados|O|O||D||1
31162411|Anillos elásticos|O|O||D||1
31162412|Horquilla|O|O||D||1
31162413|Cierre de presión|O|O||D||1
31162414|Abrazadera|O|O||D||1
31162415|Uñeta|O|O||D||1
31162416|Pasadores de conexión o acoplamiento|O|O||D||1
31162417|Pasadores de alineación|O|O||D||1
31162418|Ataduras de torsión|O|O||D||1
31162419|Anillos y eslabones|O|O||D||1
31162420|Bisagra de ingeniería|O|O||D||1
31162421|Trampa|O|O||D||1
31162500|Soportes y puntales|O|O||D||1|Soportería
31162501|Soportes para estanterías|O|O||D||1
31162502|Soportes en escuadra|O|O||D||1
31162503|Puntales|O|O||D||1
31162504|Soportes para accesorios eléctricos|O|O||D||1
31162505|Soportes de montaje magnético|O|O||D||1
31162506|Soporte de pared|O|O||D||1
31162507|Soportes de piñón|O|O||D||1
31162508|Soporte de eje de ojo|O|O||D||1
31162600|Ganchos|O|O||D||1
31162601|Ganchos giratorios|O|O||D||1
31162602|Ganchos de resorte|O|O||D||1
31162603|Ganchos en s|O|O||D||1
31162604|Ganchos de seguridad|O|O||D||1
31162605|Ganchos de suspensión|O|O||D||1
31162606|Ganchos en j|O|O||D||1
31162607|Ganchos de alambre para riostras|O|O||D||1
31162608|Ganchos de grúa|O|O||D||1
31162609|Ganchos de atornillar|O|O||D||1
31162610|Ganchos de tablero|O|O||D||1
31162611|Gancho de deslizamiento|O|O||D||1
31162612|Gancho cuadrado|O|O||D||1
31162613|Gancho en forma de 8|O|O||D||1
31162614|Gancho fijo|O|O||D||1
31162700|Roldanas pivotantes y Ruedas|O|O||D||1
31162701|Ruedas para muebles|O|O||D||1
31162702|Ruedas|O|O||D||1
31162703|Deslizadoras|O|O||D||1
31162704|Puntas de rodillo|O|O||D||1|Rodillos con puntas
31162800|Ferretería en general|O|O||D||1
31162801|Chapas o pomos|O|O||D||1
31162802|Insertos|O|O||D||1|Tubería para insertar
31162803|Grilletes|O|O||D||1
31162804|Topes de puerta|O|O||D||1
31162805|Cable dedal|O|O||D||1
31162806|Cubiertas de tornillos|O|O||D||1
31162807|Palancas|O|O||D||1
31162808|Barras de pánico|O|O||D||1
31162809|Pasadores posicionadores|O|O||D||1
31162810|Empalmes o placas de unión|O|O||D||1
31162811|Collar del eje|O|O||D||1
31162812|Mangas de prensado|O|O||D||1
31162813|Ganchos para cerda de ropa|O|O||D||1
31162814|Kit de sujetadores varios|O|O||D||1
31162815|Calce|O|O||D||1
31162816|Hilera|O|O||D||1
31162817|Soporte de cuerda de ropa|O|O||D||1
31162818|Ánodo anti corrosión|O|O||D||1
31162819|Palanca de control|O|O||D||1
31162900|Mordazas|O|O||D||1
31162901|Abrazaderas de espiga|O|O||D||1
31162902|Abrazaderas de resorte|O|O||D||1
31162903|Abrazaderas de tornillo|O|O||D||1
31162904|Abrazadera de cable metálico|O|O||D||1
31162905|Abrazadera para viga doble t|O|O||D||1
31162906|Abrazaderas de manguera o tubo|O|O||D||1
31162907|Abrazadera de extensión|O|O||D||1
31162908|Abrazadera en miniatura|O|O||D||1
31162909|Abrazadera isofónica|O|O||D||1
31162910|Abrazadera de taladro|O|O||D||1
31162911|Abrazadera de tornillo manual|O|O||D||1
31162912|Abrazadera de banda|O|O||D||1
31162913|Abrazadera de banco|O|O||D||1
31162914|Abrazadera de red|O|O||D||1
31162915|Abrazadera de ingletes|O|O||D||1
31162916|Abrazadera de acción rápida|O|O||D||1
31162917|Abrazadera de agarre rápido|O|O||D||1
31162918|Abrazadera de potencia|O|O||D||1
31162919|Abrazadera de velocidad|O|O||D||1
31162920|Abrazadera de marco de fotos|O|O||D||1
31163000|Embragues|O|O||D||1
31163001|Acoples elastoméricos|O|O||D||1
31163002|Acoples por engranaje|O|O||D||1
31163003|Acoples metálicos|O|O||D||1
31163004|Acoples en miniatura|O|O||D||1
31163005|Manguitos de acoplamiento|O|O||D||1
31163006|Acoples de rejilla|O|O||D||1
31163007|Acoples de cadena|O|O||D||1
31163008|Acoples de disco|O|O||D||1
31163009|Acoples rígidos|O|O||D||1
31163010|Acoples de araña|O|O||D||1
31163011|Acoples de mordaza|O|O||D||1
31163012|Acoples medios|O|O||D||1
31163013|Acoples de ejes|O|O||D||1
31163014|Acoples giratorio|O|O||D||1
31163015|Acoples oldham|O|O||D||1
31163016|Acoples de varilla|O|O||D||1
31163017|Varilla de acople|O|O||D||1
31163018|Acoples de fuelle|O|O||D||1
31163019|Acoples magnéticos|O|O||D||1
31163020|Acoples de brida|O|O||D||1
31163021|Acople universal flexible|O|O||D||1
31163022|Acoples de abrazadera|O|O||D||1
31163023|Acoples de mariposa|O|O||D||1
31163024|Acoples de brida tipo flexible|O|O||D||1
31163025|Acoples de mariposa partida|O|O||D||1
31163026|Acoples de media vuelta|O|O||D||1
31163027|Acoples de cadena giratoria|O|O||D||1
31163028|Acoples de rejilla de tipo flexible|O|O||D||1
31163029|Acoples de clip de fricción|O|O||D||1
31163030|Acoples duraflex|O|O||D||1
31163031|Acoples de vendedores|O|O||D||1
31163032|Adapatador eléctrico de acoples|O|O||D||1
31163100|Conectores|O|O||D||1
31163101|Desconectores rápidos|O|O||D||1|Corta corriente
31163102|Férula|O|O||D||1|Virola
31163103|Conector de remolque|O|O||D||1
31163200|Herraje de retención|O|O||D||1
31163201|Pasadores de resorte|O|O||D||1
31163202|Anillos de retención|O|O||D||1
31163203|Pasador de espiga|O|O||D||1
31163204|Pasador de horquilla|O|O||D||1
31163205|Pasadores de cono|O|O||D||1
31163207|Horquillas de eje o de disco|O|O||D||1
31163208|Bloquecillo|O|O||D||1
31163209|Soportes o retenes del rodamiento|O|O||D||1
31163210|Collares de retención|O|O||D||1
31163211|Grapas de retención|O|O||D||1
31163212|Pasadores roscados|O|O||D||1
31163213|Pasadores de pivote|O|O||D||1
31163214|Pasadores de deslizamiento|O|O||D||1
31163215|Pasadores estriados|O|O||D||1
31163216|Colgador de cable|O|O||D||1
31163217|Bujes de bloqueo de tubo de desconexión rápida|O|O||D||1
31163218|Manga para adaptación de rodamiento|O|O||D||1
31163219|Pasador cilíndrico|O|O||D||1
31163220|Juego de pines diversos|O|O||D||1
31163221|Llave de pasador|O|O||D||1
31163222|Llave cuadrada|O|O||D||1
31163223|Llave rectangular|O|O||D||1
31163224|Llave cónica|O|O||D||1
31163225|Llave de broche de cuña|O|O||D||1
31163226|Anillo de seguridad|O|O||D||1
31163227|Anillo en eje (flinger)|O|O||D||1
31163228|Anillo partido|O|O||D||1
31163229|Clip retenedor metálico|O|O||D||1
31163230|Clip retenedor plástico|O|O||D||1|Duola retenedora de plástico
31163231|Collar de retención de tubos|O|O||D||1|Abrazadera
31163300|Espaciadores|O|O||D||1
31163301|Montante de dos extremos|O|O||D||1|Separador doble broche
31163302|Montante para soldar|O|O||D||1|Perno de soldadura, Perno para sujetar
31163303|Montante de bola|O|O||D||1|Separador de bola
31163304|Montante complejo|O|O||D||1|Remache espaciador compuesto
31163400|Redes de metal y estructuras de cribado|O|O||D||1
31163401|Gavión|O|O||D||1|Contenedor de malla de metal
31171500|Rodamientos|O|O||D||1|Baleros
31171501|Rodamientos embridados|O|O||D||1
31171502|Rodamientos radiales|O|O||D||1|Baleros con pestaña
31171503|Rodamientos de rueda|O|O||D||1|Baleros para rueda
31171504|Rodamientos de balineras|O|O||D||1|Baleros de balines
31171505|Rodamientos de rodillos|O|O||D||1|Baleros de rodillos
31171506|Rodamientos lineales|O|O||D||1|Baleros lineales
31171507|Rodamientos de empuje|O|O||D||1|Baleros de empuje, Baleros de presión
31171508|Rodamientos de cabeza de biela|O|O||D||1|Balero para biela
31171509|Rodamientos de manguito interior|O|O||D||1|Balero de manguito
31171510|Rodamientos esféricos|O|O||D||1|Balero esféricos
31171511|Soportes de cojinetes|O|O||D||1|Soportes de cojinetes para baleros
31171512|Rodamiento de agujas|O|O||D||1|Balancines o semibalancines, Balero de agujas
31171513|Rodamientos colgaderos|O|O||D||1|Baleros colgantes
31171515|Rodamientos simples|O|O||D||1|Baleros simples
31171516|Rodamientos cónicos|O|O||D||1|Baleros cónicos
31171518|Jaula de rodamiento|O|O||D||1|Jaula para baleros
31171519|Carcasas o pedestales de rodamientos|O|O||D||1
31171520|Muñones de rodamientos|O|O||D||1
31171522|Rodamientos magnéticos|O|O||D||1
31171523|Rodamientos neumáticos|O|O||D||1|Baleros neumáticos
31171524|Tapas de rodamientos|O|O||D||1|Tapas de baleros
31171525|Revestimientos de rodamiento|O|O||D||1
31171526|Almohadillas de rodamiento|O|O||D||1|Empaque de balero
31171527|Conos de rodamiento|O|O||D||1
31171528|Rodamiento partido|O|O||D||1
31171529|Sombreretes de rodamiento|O|O||D||1
31171530|Rodamiento de seguimiento de levas|O|O||D||1
31171531|Rodamiento de contacto angular|O|O||D||1
31171532|Rodamiento auto – alineante|O|O||D||1
31171533|Rodamiento y marco ajustables|O|O||D||1
31171534|Rodamiento de base cónica|O|O||D||1
31171535|Rodamiento de cartucho|O|O||D||1
31171536|Rodamiento de insertar|O|O||D||1
31171537|Rodamiento de combinación|O|O||D||1
31171538|Rodamiento de cuatro puntos|O|O||D||1
31171539|Balinera|O|O||D||1
31171540|Aguja de rodamiento|O|O||D||1
31171541|Rodillo de rodamiento|O|O||D||1
31171542|Rodamiento tensionador|O|O||D||1
31171543|Rodamiento de flexión|O|O||D||1
31171544|Bloque de rodamiento plummer|O|O||D||1
31171545|Cubierta de rodamiento|O|O||D||1
31171546|Rodamiento reversible|O|O||D||1
31171547|Rodamiento cilíndrico|O|O||D||1
31171548|Manguito de retiro de rodamiento|O|O||D||1
31171549|Rodamiento de joyería|O|O||D||1
31171550|Rodamiento combinado de rodillo y balinera|O|O||D||1
31171551|Rodamiento sin aceite|O|O||D||1
31171552|Rodamiento de balinera de empuje|O|O||D||1
31171553|Rodamiento de rodillo de empuje|O|O||D||1
31171554|Rodamiento guía|O|O||D||1
31171555|Ensamble de adaptador de rodamiento de rodillos|O|O||D||1
31171556|Rodamiento inserto de alto desempeño|O|O||D||1
31171557|Buje de chumacera|O|O||D||1
31171558|Rodillo de movimiento lineal y giratorio|O|O||D||1
31171559|Placa de bloqueo para rodamiento de rodillo|O|O||D||1
31171560|Anillo de presión de bloqueo para rodamiento de rodillo|O|O||D||1
31171561|Manguito adaptador para rodamiento de rodillo|O|O||D||1
31171562|Rodamiento inserto con bloqueo de tornillo|O|O||D||1
31171563|Rodamiento de insertar con collar de bloqueo excéntrico|O|O||D||1
31171564|Rodamiento de insertar con anillo interior estándar|O|O||D||1
31171600|Cojinetes|O|O||D||1
31171603|Bujes de taladro|O|O||D||1
31171604|Bujes pilotos|O|O||D||1
31171605|Bujes de eje|O|O||D||1
31171606|Bujes de brida|O|O||D||1
31171607|Buje de desgaste|O|O||D||1
31171608|Buje en blanco|O|O||D||1
31171609|Manga de buje|O|O||D||1
31171610|Buje forjado en frío|O|O||D||1
31171700|Engranajes|O|O||D||1|Engranes
31171704|Engranajes de fricción|O|O||D||1
31171706|Engranajes cónicos|O|O||D||1
31171707|Engranajes rectos|O|O||D||1
31171708|Engranajes biselados|O|O||D||1
31171709|Engranajes cremallera|O|O||D||1
31171710|Engranajes piñón|O|O||D||1
31171711|Engranajes de anillo|O|O||D||1
31171712|Engranajes de tornillo sin fin|O|O||D||1
31171713|Engranajes laterales|O|O||D||1
31171714|Engranajes helicoidales|O|O||D||1
31171715|Engranajes cilíndricos|O|O||D||1
31171716|Engranajes en espina de pescado|O|O||D||1
31171800|Ruedas industriales|O|O||D||1
31171801|Ruedas dentadas|O|O||D||1
31171802|Ruedas motrices|O|O||D||1
31171803|Rueda voladora|O|O||D||1|Rueda volante
31171804|Poleas|O|O||D||1
31171805|Cepillos de rueda|O|O||D||1
31171806|Ruedas de rodillos|O|O||D||1
31171900|Ruedas dentadas|O|O||D||1
31171901|Ruedas dentadas para cadena de rodillos|O|O||D||1
31171902|Ruedas dentadas para cadena de ingeniería|O|O||D||1
31171903|Ruedas dentadas para cadena de transporte|O|O||D||1
31171904|Ruedas dentadas para cadena silenciosa|O|O||D||1
31171905|Rueda dentada o polea de cadena|O|O||D||1
31181700|Embalajes y empaquetaduras|O|O||D||1
31181701|Empaques|O|O||D||1|Embalaje
31181702|Prensaestopas|O|O||D||1|Embalaje de fibra sintética
31181703|Deflectores de aceite|O|O||D||1
31181704|Caja de relleno|O|O||D||1|Caja para empacar
31181705|Anillo de sello de soporte|O|O||D||1|Junta de anillo de soporte
31181800|Cubiertas automotrices|O|O||D||1
31181801|Manija de palanca de cambios de transmisión automotriz|O|O||D||1|Cubierta de palanca de cambios
31181802|Cubierta de bujía|O|O||D||1
31191500|Abrasivos y medios de abrasivo|O|O||D||1
31191501|Papeles abrasivos|O|O||D||1|Papel de lija
31191502|Pulidor|O|O||D||1
31191504|Telas abrasivas|O|O||D||1|Fibra abrasiva, Paño abrasivo
31191505|Almohadillas abrasivas|O|O||D||1|Esponja abrasiva
31191506|Discos abrasivos|O|O||D||1
31191507|Cintas abrasivas|O|O||D||1
31191508|Polvo de diamante|O|O||D||1
31191509|Pulidores abrasivos|O|O||D||1
31191510|Piedras abrasivas|O|O||D||1
31191511|Virutas de acero|O|O||D||1
31191512|Chorro de balines o perdigones|O|O||D||1|Chorreado abrasivo
31191513|Cuentas de vidrio|O|O||D||1
31191514|Medio amortiguador|O|O||D||1|Maquina de pulido
31191515|Malla abrasiva|O|O||D||1
31191516|Rollos de cartucho abrasivo|O|O||D||1
31191517|Planchas de esmeril|O|O||D||1
31191518|Carburo de tungsteno|O|O||D||1|Carburo de wolframio
31191519|Tambores abrasivos|O|O||D||1
31191520|Abrasivo estrella|O|O||D||1
31191521|Cepillo abrasivo|O|O||D||1
31191600|Ruedas abrasivas|O|O||D||1
31191601|Ruedas abrasivas cúbicas de nitrato borozon|O|O||D||1
31191602|Ruedas abrasivas de diamante|O|O||D||1
31191603|Ruedas abrasivas de carburo de tungsteno|O|O||D||1
31201500|Cinta adhesiva|O|O||D||1
31201501|Cinta de ductos|O|O||D||1|Cinta americana
31201502|Cinta aislante eléctrica|O|O||D||1|Cinta de aislar o aislante
31201503|Cinta de enmascarar|O|O||D||1|Masking
31201504|Cinta para alfombras|O|O||D||1
31201505|Cinta doble faz|O|O||D||1
31201506|Cinta de bísmalemida|O|O||D||1
31201507|Cinta de fibra de vidrio|O|O||D||1
31201508|Cinta de grafito|O|O||D||1
31201509|Cinta de nylon|O|O||D||1
31201510|Cinta impregnada de resina|O|O||D||1
31201511|Cinta de malla metálica|O|O||D||1
31201512|Cinta transparente|O|O||D||1|Diurex
31201513|Cintas antideslizantes de seguridad|O|O||D||1
31201514|Cinta de sellado de hilo de poli tetrafluoretileno (ptfe)|O|O||D||1|Cinta de teflón
31201515|Cintas de papel|O|O||D||1
31201516|Cinta reflectiva|O|O||D||1
31201517|Cinta para empaquetar|O|O||D||1|Cinta canela
31201518|Cinta conductora de electricidad|O|O||D||1
31201519|Cinta para reparar tubería o manguera|O|O||D||1
31201520|Cinta para marcar los pasillos|O|O||D||1
31201521|Cinta metálica|O|O||D||1
31201522|Cinta de transferencia adhesiva|O|O||D||1
31201523|Cinta de tela|O|O||D||1
31201524|Cinta para codificación de color|O|O||D||1
31201525|Cinta de vinilo|O|O||D||1
31201526|Cinta magnética|O|O||D||1
31201527|Cintas de espuma|O|O||D||1
31201528|Cinta de montaje|O|O||D||1
31201529|Cinta de perfilar|O|O||D||1
31201530|Cinta de papel de aluminio|O|O||D||1
31201531|Cinta de polietileno|O|O||D||1
31201532|Cinta de cloruro de polivinilo pvc|O|O||D||1|Cinta adhesiva de PVC, Cinta pvc para tuberia
31201533|Cinta de hoja de plomo|O|O||D||1
31201534|Cinta de caucho|O|O||D||1
31201535|Cinta para empalmes de cables|O|O||D||1
31201536|Cinta de lanilla de polietileno|O|O||D||1
31201537|Cinta de arrancar|O|O||D||1|Cinta de rasgado para empaques
31201600|Otros adhesivos y selladores|O|O||D||1
31201601|Adhesivos químicos|O|O||D||1
31201602|Pastas|O|O||D||1
31201603|Gomas|O|O||D||1|Pegamento de cola
31201604|Cementos de caucho|O|O||D||1
31201605|Masillas|O|O||D||1|Plastilina epóxica
31201606|Calafateos|O|O||D||1
31201607|Aglomerante epoxy|O|O||D||1|Resina epoxídica
31201608|Adhesivos de espuma|O|O||D||1
31201609|Adhesivos de termo impregnación|O|O||D||1
31201610|Pegamentos|O|O||D||1|Lápiz adhesivo
31201611|Adhesivos de lámina|O|O||D||1
31201612|Selladores de rosca|O|O||D||1
31201613|Adhesivo reusable|O|O||D||1
31201614|Lacre|O|O||D||1|Pasta laca
31201615|Activadores del adhesivo|O|O||D||1
31201616|Adhesivos líquidos|O|O||D||1|Pegamento líquido
31201617|Cementos disolventes|O|O||D||1
31201618|Compuesto de unión de drywall|O|O||D||1
31201619|Adhesivo instantáneo|O|O||D||1
31201620|Adhesivo reactivo|O|O||D||1
31201621|Adhesivo en aerosol|O|O||D||1
31201622|Adhesivo multi – propósito|O|O||D||1
31201623|Adhesivo de contacto|O|O||D||1
31201624|Adhesivo de montura|O|O||D||1
31201625|Base de masilla|O|O||D||1
31201626|Adhesivo sensible a la presión psa|O|O||D||1
31201627|Adhesivo anaeróbico|O|O||D||1
31201628|Sellante de impregnación|O|O||D||1
31201629|Encapsulación de silicona|O|O||D||1
31201630|Sellante de espuma|O|O||D||1
31201631|Compuesto sellante|O|O||D||1
31201632|Adhesivo de silicona|O|O||D||1
31201633|Adhesivo de fluorocarbono|O|O||D||1
31201634|Adhesivo acrílico anaeróbico|O|O||D||1
31201635|Adhesivo de poliuretano|O|O||D||1
31201636|Adhesivo de cianoacrilato|O|O||D||1
31201637|Material de comunicación tipo espuma para detener el agua|O|O||D||1|Espuma contra fugas de agua
31211500|Pinturas y tapa poros|O|O||D||1
31211501|Pinturas de esmalte|O|O||D||1
31211502|Pinturas de agua|O|O||D||1
31211503|Pinturas basadas en pigmentos|O|O||D||1
31211504|Pinturas de revestimiento|O|O||D||1
31211505|Pinturas de aceite|O|O||D||1
31211506|Pinturas de látex|O|O||D||1
31211507|Pinturas en aerosol|O|O||D||1
31211508|Pinturas acrílicas|O|O||D||1
31211509|Bases para esmalte|O|O||D||1
31211510|Bases de poliuretano|O|O||D||1
31211511|Bases de uretano|O|O||D||1
31211512|Bases de látex|O|O||D||1
31211513|Pintura de marcado invertido|O|O||D||1
31211514|Compuesto de galvanización en frío|O|O||D||1
31211515|Pintura basada en disolvente|O|O||D||1|Pinturas de aceite
31211516|Pintura de terminado al horno|O|O||D||1
31211517|Pintura de terminado patrón|O|O||D||1|Pintura de acabados y patrones
31211518|Pintura antióxido|O|O||D||1|Pintura anticorrosión
31211519|Pintura de aluminio|O|O||D||1
31211520|Pintura anti – incrustante|O|O||D||1|Pintura anti incrustante
31211521|Pintura premezclada|O|O||D||1
31211522|Pintura de trabajo pesado|O|O||D||1|Pintura revestimiento
31211600|Aditivos para pinturas|O|O||D||1
31211601|Lechada de cal con cola para blanquear paredes|O|O||D||1|Revestimiento de cal
31211602|Lechada de cal con cola para blanquear paredes|O|O||D||1|Materiales y acabados texturizados
31211603|Secantes de pintura|O|O||D||1|Secador de pintura
31211604|Diluyentes para pinturas|O|O||D||1
31211605|Agentes antideslizantes|O|O||D||1
31211606|Agentes niveladores|O|O||D||1|Aditivos para aplanar
31211607|Inhibidor ultravioleta|O|O||D||1|Aditivo anti radiación ultravioleta, Aditivo anti-UV
31211700|Acabados en general|O|O||D||1
31211701|Vitrificados|O|O||D||1|Esmalte
31211702|Lustres|O|O||D||1|Aditivos abrillantadores
31211703|Lacas|O|O||D||1
31211704|Sellantes|O|O||D||1|Selladores
31211705|Barniz de laca|O|O||D||1
31211706|Tinturas|O|O||D||1|Pinturas para teñir, Tintes colorantes
31211707|Barnices|O|O||D||1|Barniz
31211708|Recubrimiento de polvo|O|O||D||1
31211709|Tinturas de terminación|O|O||D||1|Colorantes para acabado
31211800|Disolventes y diluyentes para pinturas|O|O||D||1
31211801|Removedores de pintura o barniz|O|O||D||1
31211802|Compuestos para arrancar pintura o barniz|O|O||D||1
31211803|Diluyentes para pinturas y barnices|O|O||D||1|Thinner
31211900|Aplicadores de pintura y accesorios para pintar|O|O||D||1
31211901|Paños para herramientas|O|O||D||1
31211902|Herramientas para bordes|O|O||D||1
31211903|Equipo para protección|O|O||D||1
31211904|Brochas|O|O||D||1
31211905|Mezcladores de pintura|O|O||D||1
31211906|Rodillos de pintar|O|O||D||1
31211908|Pistolas de pintar|O|O||D||1
31211909|Bandejas de pintura|O|O||D||1
31211910|Guantes para pintar|O|O||D||1
31211912|Varillas telescópicas|O|O||D||1|Extensión telescópica para rodillo
31211913|Boquillas de pintura|O|O||D||1|Caps para aerosol, Válvulas para aerosol
31211914|Cepillos de aire|O|O||D||1|Aerógrafo
31211915|Coladores de pintura|O|O||D||1
31211916|Forradores de bandeja de pintura|O|O||D||1
31211917|Cubiertas para rodillos de pintura|O|O||D||1
31211918|Accesorio o máscara de pintura|O|O||D||1
31221600|Productos para curtidos|O|O||D||1
31221601|Extractos inorgánicos para curtiembre|O|O||D||1|Extractos inorgánicos para curtir piel
31221602|Extractos orgánicos de origen animal para curtiembre|O|O||D||1|Extractos orgánicos de origen animal para curtir piel
31221603|Extractos orgánicos de origen vegetal para curtiembre|O|O||D||1|Extractos orgánicos de origen vegetal para curtir piel
31231100|Material en barra labrada|O|O||D||1
31231101|Aluminio en barra labrada|O|O||D||1
31231102|Berilio en barra labrada|O|O||D||1
31231103|Latón en barra labrada|O|O||D||1
31231104|Bronce en barra labrada|O|O||D||1
31231105|Cobre en barra labrada|O|O||D||1
31231106|Hierro en barra labrada|O|O||D||1
31231107|Plomo en barra labrada|O|O||D||1
31231108|Magnesio en barra labrada|O|O||D||1
31231109|Metal precioso en barra labrada|O|O||D||1
31231110|Acero inoxidable en barra labrada|O|O||D||1
31231111|Estaño en barra labrada|O|O||D||1
31231112|Titanio en barra labrada|O|O||D||1
31231113|Cinc en barra labrada|O|O||D||1
31231114|Aleación no ferrosa en barra labrada|O|O||D||1
31231115|Aleación ferrosa en barra labrada|O|O||D||1
31231116|Acero en barra labrada|O|O||D||1
31231117|Compuestos en barra labrada|O|O||D||1
31231118|Aleación de níquel en barra labrada|O|O||D||1
31231119|Material no metálico en barra labrada|O|O||D||1
31231120|Acero plata en barra labrada|O|O||D||1
31231200|Material en placas labrado|O|O||D||1
31231201|Aluminio en placa labrada|O|O||D||1
31231202|Berilio en placa labrada|O|O||D||1
31231203|Latón en placa labrada|O|O||D||1
31231204|Bronce en placa labrada|O|O||D||1
31231205|Cobre en placa labrada|O|O||D||1
31231206|Hierro en placa labrada|O|O||D||1
31231207|Plomo en placa labrada|O|O||D||1
31231208|Magnesio en placa labrada|O|O||D||1
31231209|Metal precioso en placa labrada|O|O||D||1
31231210|Acero inoxidable en placa labrada|O|O||D||1
31231211|Estaño en placa labrada|O|O||D||1
31231212|Titanio en placa labrada|O|O||D||1
31231213|Cinc en placa labrada|O|O||D||1
31231214|Aleación no ferrosa en placa labrada|O|O||D||1
31231215|Aleación ferrosa en placa labrada|O|O||D||1
31231216|Acero en placa labrada|O|O||D||1
31231217|Compuestos en placa labrada|O|O||D||1
31231218|Aleación de níquel en placa labrada|O|O||D||1
31231219|Material no metálico en placa labrada|O|O||D||1
31231400|Suplementos|O|O||D||1
31231401|Platina de latón|O|O||D||1
31231402|Platina de acero|O|O||D||1
31231403|Platina de acero inoxidable|O|O||D||1
31231404|Platina de aluminio|O|O||D||1
31231405|Platina de cobre|O|O||D||1
31241500|Lentes y prismas|O|O||D||1
31241501|Lentes|O|O||D||1
31241502|Prismas|O|O||D||1
31241600|Cristales ópticos|O|O||D||1
31241601|Cristales de filtro|O|O||D||1|Cristales bloqueadores
31241602|Discos de cristal|O|O||D||1
31241603|Vidrio moldeado|O|O||D||1
31241604|Cristales de prismas|O|O||D||1
31241605|Cristales de silicio|O|O||D||1
31241606|Cristales de germanio|O|O||D||1
31241607|Barras redondas|O|O||D||1
31241608|Barras cuadradas|O|O||D||1
31241609|Cristales indicadores de muestra|O|O||D||1
31241610|Blancos de material óptico infrarrojo|O|O||D||1|Cristal liso
31241700|Espejos|O|O||D||1
31241701|Espejos torneados con herramienta de diamante|O|O||D||1
31241702|Espejos metálicos|O|O||D||1
31241703|Espejos parabólicos|O|O||D||1
31241704|Espejos sin revestimiento|O|O||D||1
31241705|Espejos para láser|O|O||D||1
31241706|Espejos planos|O|O||D||1
31241800|Filtros ópticos|O|O||D||1
31241801|Filtros ópticos de banda ancha|O|O||D||1
31241802|Filtros de gradiente|O|O||D||1
31241803|Filtros infrarrojos|O|O||D||1
31241804|Filtros de láser|O|O||D||1
31241805|Filtros de banda estrecha|O|O||D||1
31241806|Filtros de película de plástico|O|O||D||1
31241807|Filtros visuales|O|O||D||1
31241808|Filtros dicróicos|O|O||D||1
31241809|Filtros de lyot|O|O||D||1
31241810|Filtros de gelatina|O|O||D||1
31241811|Filtros de color|O|O||D||1
31241812|Filtros polarizantes|O|O||D||1
31241813|Filtros de reflexión|O|O||D||1
31241814|Filtros de succión|O|O||D||1
31241815|Filtros de interferencia|O|O||D||1
31241900|Bóvedas ópticas|O|O||D||1
31241901|Bóvedas de especialidad|O|O||D||1
31241902|Bóvedas torneadas con diamante|O|O||D||1
31241903|Bóvedas metálicas|O|O||D||1
31241904|Bóvedas de vidrio moldeado|O|O||D||1
31241905|Bóvedas moldeadas del policarbonato|O|O||D||1
31241906|Bóvedas reproducidas|O|O||D||1
31241907|Bóvedas formadas|O|O||D||1
31241908|Bóvedas frangibles|O|O||D||1
31242000|Ventanas de láser y lentes|O|O||D||1
31242001|Ventana externa de láser o lentes|O|O||D||1
31242002|Ventanas de lentes infrarrojos o de láser|O|O||D||1
31242003|Ventana visual de láser o lentes|O|O||D||1
31242100|Accesorios de dispositivos ópticos|O|O||D||1
31242101|Monturas ópticas|O|O||D||1
31242103|Aberturas o ranuras ópticas|O|O||D||1
31242104|Soportes o carriles ópticos|O|O||D||1
31242105|Identificadores de fibra óptica|O|O||D||1
31242106|Recubrimientos ópticos|O|O||D||1
31242107|Tablero de pruebas ópticas|O|O||D||1
31242200|Componentes ópticos variados|O|O||D||1
31242201|Divisores del haz óptico|O|O||D||1
31242202|Polarizadores|O|O||D||1
31242203|Despolarizadores|O|O||D||1
31242204|Difusores ópticos|O|O||D||1
31242205|Retardadores ópticos|O|O||D||1
31242206|Vidrios ópticamente planos|O|O||D||1
31242207|Montajes ópticos experimentales|O|O||D||1
31242208|Picadores ópticos|O|O||D||1
31251500|Activadores|O|O||D||1
31251501|Activadores eléctricos|O|O||D||1
31251502|Activadores electrónicos|O|O||D||1
31251503|Activadores hidráulicos|O|O||D||1
31251504|Activadores neumáticos|O|O||D||1
31251505|Servoválvula|O|O||D||1
31251506|Activadores por engranajes|O|O||D||1
31251507|Activadores giratorios|O|O||D||1
31251508|Activadores fotoeléctricos|O|O||D||1
31251509|Activadores electromagnéticos|O|O||D||1
31251510|Solenoides|O|O||D||1
31251511|Activadores lineales|O|O||D||1
31251512|Activadores automotrices hvac|O|O||D||1
31251513|Activadores  de compuerta|O|O||D||1
31251514|Activador electromecánico de aeronaves|O|O||D||1
31251600|Componentes de robot|O|O||D||1
31251601|Efectores finales robóticos|O|O||D||1
31261500|Cubiertas y cajas|O|O||D||1
31261501|Cubiertas y carcasas de plástico|O|O||D||1
31261502|Cubiertas y carcasas de metal|O|O||D||1
31261503|Cubiertas y carcasas de acero|O|O||D||1
31261504|Carcasas de cajas de cambios|O|O||D||1
31261505|Carcasas de embrague|O|O||D||1
31261600|Cascos y envolturas|O|O||D||1
31261601|Envoltorios o recubrimientos de plástico|O|O||D||1|Armazón o cubierta de plástico
31261602|Envoltorios o recubrimientos de metal|O|O||D||1|Armazón o cubierta metálica
31261603|Envoltorios o recubrimientos de acero|O|O||D||1|Armazón o cubierta de acero
31261700|Cerramientos o alojamientos insonorizantes|O|O||D||1
31261701|Carcasa  insonorizante de máquina|O|O||D||1
31261702|Cerramiento insonorizante de conjunto de generador montado|O|O||D||1
31261703|Carcasa insonorizante de bomba|O|O||D||1
31261704|Carcasa insonorizante de admisión de aire|O|O||D||1
31271600|Piezas hechas con torno de roscar|O|O||D||1
31271601|Piezas hechas en torno de roscar de metal|O|O||D||1
31271602|Piezas hechas en torno de roscar no metales|O|O||D||1
31281500|Componentes estampados|O|O||D||1|Elementos para estampados
31281502|Componentes de aluminio estampados|O|O||D||1
31281503|Componentes de aleaciones ferrosas estampados|O|O||D||1
31281504|Componentes de hierro estampados|O|O||D||1
31281505|Componentes de aleaciones no ferrosas estampados|O|O||D||1
31281506|Componentes de acero inoxidable estampados|O|O||D||1
31281507|Componentes de acero al carbono estampados|O|O||D||1
31281508|Componentes de magnesio estampados|O|O||D||1
31281509|Componentes de zinc estampados|O|O||D||1
31281510|Componentes de estaño estampados|O|O||D||1
31281511|Componentes de titanio estampados|O|O||D||1
31281512|Componentes de berilio estampados|O|O||D||1
31281513|Componentes de metal precioso estampados|O|O||D||1
31281514|Componentes de cobre estampados|O|O||D||1
31281515|Componentes de plomo estampados|O|O||D||1
31281516|Componentes de latón estampados|O|O||D||1
31281517|Componentes de bronce estampados|O|O||D||1
31281518|Componentes compuestos estampados|O|O||D||1
31281519|Componentes de aleación de níquel estampados|O|O||D||1
31281520|Componentes no metálicos estampados|O|O||D||1
31281521|Estampados recubiertos|O|O||D||1
31281522|Componente de berilio cobre estampado|O|O||D||1|Elemento para estampado de cobre berilio
31281523|Componente estampado de cobre latón plateado|O|O||D||1|Elemento para estampado de cobre latón plateado
31281524|Componente estampado de aluminio sae serie 1000|O|O||D||1|Elemento para estampado de aluminio sae serie 1000
31281525|Componente estampado de aluminio sae serie 3000|O|O||D||1|Elemento para estampado de aluminio sae serie 3000
31281526|Componente estampado de aluminio sae serie 5000|O|O||D||1|Elemento para estampado de aluminio sae serie 5000
31281527|Componente estampado de aluminio sae serie 6000|O|O||D||1|Elemento para estampado de aluminio sae serie 6000
31281528|Componente estampado de inconel|O|O||D||1|Elemento para estampado de inconel
31281529|Componente estampado de acero al carbón sae serie 1000 enrollado en frío recubierto de estaño|O|O||D||1
31281530|Componente estampado de acero al carbón sae serie 1000 enrollado en caliente|O|O||D||1
31281531|Componente estampado de aleación de aleación de acero enrollada en caliente|O|O||D||1
31281532|Componente estampado de acero al carbón sae serie 1000 enrollado en frío|O|O||D||1
31281533|Componente estampado de acero inoxidable sae serie 200 enrollado en frío|O|O||D||1
31281534|Componente estampado de acero inoxidable sae serie 300 enrollado en frío|O|O||D||1
31281535|Componente estampado de acero inoxidable sae serie 400 enrollado en frío|O|O||D||1
31281536|Componente estampado de aleación de aleación de acero enrollada en frío|O|O||D||1
31281537|Componente estampado de acero al carbón sae serie 1000 enrollado en frío galvanizado en caliente por inmersión|O|O||D||1
31281538|Componente estampado de acero al carbón sae serie 1000 enrollado en frío electro  galvanizado|O|O||D||1
31281700|Componentes soldados|O|O||D||1
31281701|Componentes de metal soldado|O|O||D||1|Elementos de metal soldado
31281800|Componentes perforados|O|O||D||1
31281801|Componentes de aluminio perforados|O|O||D||1
31281802|Componentes de aleación ferrosa perforados|O|O||D||1
31281803|Componentes de hierro perforados|O|O||D||1
31281804|Componentes de aleaciones no ferrosas perforados|O|O||D||1
31281805|Componentes de acero inoxidable perforados|O|O||D||1
31281806|Componentes de acero al carbono perforados|O|O||D||1
31281807|Componentes compuestos perforados|O|O||D||1|Compuestos perforados
31281808|Componentes de aleación de níquel perforados|O|O||D||1|Aleación de níquel perforado
31281809|Componentes no metálicos perforados|O|O||D||1
31281810|Componentes de titanio perforados|O|O||D||1
31281811|Componentes de berilio perforados|O|O||D||1
31281812|Componentes de metal precioso perforados|O|O||D||1
31281813|Componentes de cobre perforados|O|O||D||1
31281814|Componentes de plomo perforados|O|O||D||1
31281815|Componentes de latón perforados|O|O||D||1
31281816|Componentes de bronce perforados|O|O||D||1
31281817|Componentes de magnesio perforados|O|O||D||1
31281818|Componentes de zinc perforados|O|O||D||1
31281819|Componentes de estaño perforados|O|O||D||1
31281900|Componentes formados por estiraje|O|O||D||1
31281901|Componentes de aluminio formados por estiramiento|O|O||D||1|Alambre de aluminio
31281902|Componentes de berilio formados por estiramiento|O|O||D||1|Alambre de berilio
31281903|Componentes de latón formados por estiramiento|O|O||D||1|Alambre de latón
31281904|Componentes de bronce formados por estiramiento|O|O||D||1|Alambre de bronce
31281905|Componentes compuestos formados por estiramiento|O|O||D||1
31281906|Componentes de cobre formados por estiramiento|O|O||D||1|Alambre de cobre
31281907|Componentes de aleación ferrosa formados por estiramiento|O|O||D||1
31281908|Componentes de hierro formados por estiramiento|O|O||D||1
31281909|Componentes de plomo formados por estiramiento|O|O||D||1
31281910|Componentes de magnesio formados por estiramiento|O|O||D||1
31281911|Componentes de aleación de níquel formados por estiramiento|O|O||D||1
31281912|Componentes de aleación no ferrosa formados por estiramiento|O|O||D||1
31281913|Componentes no metálicos formados por estiramiento|O|O||D||1
31281914|Componentes de metal precioso formados por estiramiento|O|O||D||1
31281915|Componentes de acero inoxidable formados por estiramiento|O|O||D||1
31281916|Componentes de acero formados por estiramiento|O|O||D||1
31281917|Componentes de estaño formados por estiramiento|O|O||D||1
31281918|Componentes de titanio formados por estiramiento|O|O||D||1
31281919|Componentes de zinc formados por estiramiento|O|O||D||1
31282000|Componentes hidro formados|O|O||D||1
31282001|Componentes de aluminio hidroformados|O|O||D||1
31282002|Componentes de berilio hidroformados|O|O||D||1
31282003|Componentes de latón hidroformados|O|O||D||1
31282004|Componentes de bronce hidroformados|O|O||D||1
31282005|Componentes compuestos hidroformados|O|O||D||1
31282006|Componentes de cobre hidroformados|O|O||D||1
31282007|Componentes de aleación ferrosa hidroformados|O|O||D||1
31282008|Componentes de hierro hidroformados|O|O||D||1
31282009|Componentes de plomo hidroformados|O|O||D||1
31282010|Componentes de magnesio hidroformados|O|O||D||1
31282011|Componentes de aleación de níquel hidroformados|O|O||D||1
31282012|Componentes de aleación no ferrosa hidroformados|O|O||D||1
31282013|Componentes no metálicos hidroformados|O|O||D||1
31282014|Componentes de metal precioso hidroformados|O|O||D||1
31282015|Componentes de acero inoxidable hidroformados|O|O||D||1
31282016|Componentes de acero hidroformados|O|O||D||1
31282017|Componentes de estaño hidroformados|O|O||D||1
31282018|Componentes de titanio hidroformados|O|O||D||1
31282019|Componentes de zinc hidroformados|O|O||D||1
31282100|Componentes formados con rotación|O|O||D||1
31282101|Componentes de aluminio formados en torno|O|O||D||1
31282102|Componentes de berilio formados en torno|O|O||D||1
31282103|Componentes de latón formados en torno|O|O||D||1
31282104|Componentes de bronce formados en torno|O|O||D||1
31282105|Componentes compuestos formados en torno|O|O||D||1
31282106|Componentes de cobre formados en torno|O|O||D||1
31282107|Componentes de aleación ferrosa formados en torno|O|O||D||1
31282108|Componentes de hierro formados en torno|O|O||D||1
31282109|Componentes de plomo formados en torno|O|O||D||1
31282110|Componentes de magnesio formados en torno|O|O||D||1
31282111|Componentes de aleación de níquel formados en torno|O|O||D||1
31282112|Componentes de aleación no ferrosa formados en torno|O|O||D||1
31282113|Componentes no metálicos formados en torno|O|O||D||1
31282114|Componentes de metal precioso formados en torno|O|O||D||1
31282115|Componentes de acero inoxidable formados en torno|O|O||D||1
31282116|Componentes de acero formados en torno|O|O||D||1
31282117|Componentes de estaño formados en torno|O|O||D||1
31282118|Componentes de titanio formados en torno|O|O||D||1
31282119|Componentes de zinc formados en torno|O|O||D||1
31282200|Componentes formados con rodillo|O|O||D||1
31282201|Componentes de aluminio formados enrollados|O|O||D||1
31282202|Componentes de berilio formados enrollados|O|O||D||1
31282203|Componentes de latón formados enrollados|O|O||D||1
31282204|Componentes de bronce formados enrollados|O|O||D||1
31282205|Componentes compuestos formados enrollados|O|O||D||1
31282206|Componentes de cobre formados enrollados|O|O||D||1
31282207|Componentes de aleación ferrosa formados enrollados|O|O||D||1
31282208|Componentes de hierro formados enrollados|O|O||D||1
31282209|Componentes de plomo formados enrollados|O|O||D||1
31282210|Componentes de magnesio formados enrollados|O|O||D||1
31282211|Componentes de aleación de níquel formados enrollados|O|O||D||1
31282212|Componentes de aleación no ferrosa formados enrollados|O|O||D||1
31282213|Componentes no metálicos formados enrollados|O|O||D||1
31282214|Componentes de metal precioso formados enrollados|O|O||D||1
31282215|Componentes de acero inoxidable formados enrollados|O|O||D||1
31282216|Componentes de acero formados enrollados|O|O||D||1
31282217|Componentes de estaño formados enrollados|O|O||D||1
31282218|Componentes de titanio formados enrollados|O|O||D||1
31282219|Componentes de zinc formados enrollados|O|O||D||1
31282300|Componentes formados por estiramiento por presión|O|O||D||1
31282301|Componentes de aluminio formados por estiramiento por presión|O|O||D||1
31282302|Componentes de berilio formados por estiramiento por presión|O|O||D||1
31282303|Componentes de latón formados por estiramiento por presión|O|O||D||1
31282304|Componentes de bronce formados por estiramiento por presión|O|O||D||1
31282305|Componentes compuestos formados por estiramiento por presión|O|O||D||1
31282306|Componentes de cobre formados por estiramiento por presión|O|O||D||1
31282307|Componentes de aleación ferrosa formados por estiramiento por presión|O|O||D||1
31282308|Componentes de hierro formados por estiramiento por presión|O|O||D||1
31282309|Componentes de plomo formados por estiramiento por presión|O|O||D||1
31282310|Componentes de magnesio formados por estiramiento por presión|O|O||D||1
31282311|Componentes de aleación de níquel formados por estiramiento por presión|O|O||D||1
31282312|Componentes de aleación no ferrosa formados por estiramiento por presión|O|O||D||1
31282313|Componentes no metálicos formados por estiramiento por presión|O|O||D||1
31282314|Componentes de metal precioso formados por estiramiento por presión|O|O||D||1
31282315|Componentes de acero inoxidable formados por estiramiento por presión|O|O||D||1
31282316|Componentes de acero formados por estiramiento por presión|O|O||D||1
31282317|Componentes de estaño formados por estiramiento por presión|O|O||D||1
31282318|Componentes de titanio formados por estiramiento por presión|O|O||D||1
31282319|Componentes de zinc formados por estiramiento por presión|O|O||D||1
31282400|Componentes formados de explosivos|O|O||D||1
31282401|Componentes de aluminio formados con explosivos|O|O||D||1
31282402|Componentes de berilio formados con explosivos|O|O||D||1
31282403|Componentes de latón formados con explosivos|O|O||D||1
31282404|Componentes de bronce formados con explosivos|O|O||D||1
31282405|Componentes compuestos formados con explosivos|O|O||D||1
31282406|Componentes de cobre formados con explosivos|O|O||D||1
31282407|Componentes de aleación ferrosa formados con explosivos|O|O||D||1
31282408|Componentes de hierro formados con explosivos|O|O||D||1
31282409|Componentes de plomo formados con explosivos|O|O||D||1
31282410|Componentes de magnesio formados con explosivos|O|O||D||1
31282411|Componentes de aleación de níquel formados con explosivos|O|O||D||1
31282412|Componentes de aleación no ferrosa formados con explosivos|O|O||D||1
31282413|Componentes no metálicos formados con explosivos|O|O||D||1
31282414|Componentes de metal precioso formados con explosivos|O|O||D||1
31282415|Componentes de acero inoxidable formados con explosivos|O|O||D||1
31282416|Componentes de acero formados con explosivos|O|O||D||1
31282417|Componentes de estaño formados con explosivos|O|O||D||1
31282418|Componentes de titanio formados con explosivos|O|O||D||1
31282419|Componentes de zinc formados con explosivos|O|O||D||1
31291100|Estiramientos por presión hidrostática labrados|O|O||D||1
31291101|Componentes de aluminio maquinados por extrusión hidrostática|O|O||D||1
31291102|Componentes de berilio maquinados por extrusión hidrostática|O|O||D||1
31291103|Componentes de latón maquinados por extrusión hidrostática|O|O||D||1
31291104|Componentes de bronce maquinados por extrusión hidrostática|O|O||D||1
31291105|Componentes de cobre maquinados por extrusión hidrostática|O|O||D||1
31291106|Componentes de aleación ferrosa maquinados por extrusión hidrostática|O|O||D||1
31291107|Componentes de plomo maquinados por extrusión hidrostática|O|O||D||1
31291108|Componentes de magnesio maquinados por extrusión hidrostática|O|O||D||1
31291109|Componentes de aleación no ferrosa maquinados por extrusión hidrostática|O|O||D||1
31291110|Componentes plásticos maquinados por extrusión hidrostática|O|O||D||1
31291111|Componentes de metal precioso maquinados por extrusión hidrostática|O|O||D||1
31291112|Componentes de caucho maquinados por extrusión hidrostática|O|O||D||1
31291113|Componentes de acero inoxidable maquinados por extrusión hidrostática|O|O||D||1
31291114|Componentes de acero maquinados por extrusión hidrostática|O|O||D||1
31291115|Componentes de estaño maquinados por extrusión hidrostática|O|O||D||1
31291116|Componentes de titanio maquinados por extrusión hidrostática|O|O||D||1
31291117|Componentes de zinc maquinados por extrusión hidrostática|O|O||D||1
31291118|Componentes compuestos maquinados por extrusión hidrostática|O|O||D||1
31291119|Componentes de aleación de níquel maquinados por extrusión hidrostática|O|O||D||1
31291120|Componentes no metálicos maquinados por extrusión hidrostática|O|O||D||1
31291200|Estiramientos por presión de impacto labrados|O|O||D||1
31291201|Componentes de aluminio maquinados por extrusión de impacto|O|O||D||1
31291202|Componentes de berilio maquinados por extrusión de impacto|O|O||D||1
31291203|Componentes de latón maquinados por extrusión de impacto|O|O||D||1
31291204|Componentes de bronce maquinados por extrusión de impacto|O|O||D||1
31291205|Componentes de cobre maquinados por extrusión de impacto|O|O||D||1
31291206|Componentes de aleación ferrosa maquinados por extrusión de impacto|O|O||D||1
31291207|Componentes de plomo maquinados por extrusión de impacto|O|O||D||1
31291208|Componentes de magnesio maquinados por extrusión de impacto|O|O||D||1
31291209|Componentes de aleación no ferrosa maquinados por extrusión de impacto|O|O||D||1
31291210|Componentes plásticos maquinados por extrusión de impacto|O|O||D||1
31291211|Componentes de metal precioso maquinados por extrusión de impacto|O|O||D||1
31291212|Componentes de caucho maquinados por extrusión de impacto|O|O||D||1
31291213|Componentes de acero inoxidable maquinados por extrusión de impacto|O|O||D||1
31291214|Componentes de acero maquinados por extrusión de impacto|O|O||D||1
31291215|Componentes de estaño maquinados por extrusión de impacto|O|O||D||1
31291216|Componentes de titanio maquinados por extrusión de impacto|O|O||D||1
31291217|Componentes de zinc maquinados por extrusión de impacto|O|O||D||1
31291218|Componentes compuestos maquinados por extrusión de impacto|O|O||D||1
31291219|Componentes de aleación de níquel maquinados por extrusión de impacto|O|O||D||1
31291220|Componentes no metálicos maquinados por extrusión de impacto|O|O||D||1
31291300|Estiramientos por presión en frío labrados|O|O||D||1
31291301|Componentes de aluminio maquinados por extrusión en frío|O|O||D||1
31291302|Componentes de berilio maquinados por extrusión en frío|O|O||D||1
31291303|Componentes de latón maquinados por extrusión en frío|O|O||D||1
31291304|Componentes de bronce maquinados por extrusión en frío|O|O||D||1
31291305|Componentes de cobre maquinados por extrusión en frío|O|O||D||1
31291306|Componentes de aleación ferrosa maquinados por extrusión en frío|O|O||D||1
31291307|Componentes de plomo maquinados por extrusión en frío|O|O||D||1
31291308|Componentes de magnesio maquinados por extrusión en frío|O|O||D||1
31291309|Componentes de aleación no ferrosa maquinados por extrusión en frío|O|O||D||1
31291310|Componentes plásticos maquinados por extrusión en frío|O|O||D||1
31291311|Componentes de metal precioso maquinados por extrusión en frío|O|O||D||1
31291312|Componentes de caucho maquinados por extrusión en frío|O|O||D||1
31291313|Componentes de acero inoxidable maquinados por extrusión en frío|O|O||D||1
31291314|Componentes de acero maquinados por extrusión en frío|O|O||D||1
31291315|Componentes de estaño maquinados por extrusión en frío|O|O||D||1
31291316|Componentes de titanio maquinados por extrusión en frío|O|O||D||1
31291317|Componentes de zinc maquinados por extrusión en frío|O|O||D||1
31291318|Componentes compuestos maquinados por extrusión en frío|O|O||D||1
31291319|Componentes de aleación de níquel maquinados por extrusión en frío|O|O||D||1
31291320|Componentes no metálicos maquinados por extrusión en frío|O|O||D||1
31291400|Estiramientos por presión en caliente labrados|O|O||D||1
31291401|Componentes de aluminio maquinados por extrusión en caliente|O|O||D||1
31291402|Componentes de berilio maquinados por extrusión en caliente|O|O||D||1
31291403|Componentes de latón maquinados por extrusión en caliente|O|O||D||1
31291404|Componentes de bronce maquinados por extrusión en caliente|O|O||D||1
31291405|Componentes de cobre maquinados por extrusión en caliente|O|O||D||1
31291406|Componentes de aleación ferrosa maquinados por extrusión en caliente|O|O||D||1
31291407|Componentes de plomo maquinados por extrusión en caliente|O|O||D||1
31291408|Componentes de magnesio maquinados por extrusión en caliente|O|O||D||1
31291409|Componentes de aleación no ferrosa maquinados por extrusión en caliente|O|O||D||1
31291410|Componentes plásticos maquinados por extrusión en caliente|O|O||D||1
31291411|Componentes de metal precioso maquinados por extrusión en caliente|O|O||D||1
31291412|Componentes de caucho maquinados por extrusión en caliente|O|O||D||1
31291413|Componentes de acero inoxidable maquinados por extrusión en caliente|O|O||D||1
31291414|Componentes de acero maquinados por extrusión en caliente|O|O||D||1
31291415|Componentes de estaño maquinados por extrusión en caliente|O|O||D||1
31291416|Componentes de titanio maquinados por extrusión en caliente|O|O||D||1
31291417|Componentes de zinc maquinados por extrusión en caliente|O|O||D||1
31291418|Componentes compuestos maquinados por extrusión en caliente|O|O||D||1
31291419|Componentes de aleación de níquel maquinados por extrusión en caliente|O|O||D||1
31291420|Componentes no metálicos maquinados por extrusión en caliente|O|O||D||1
31301100|Forjas labradas con troquel abierto|O|O||D||1
31301101|Forjas de aleación no ferrosa maquinadas con troquel abierto|O|O||D||1
31301102|Forjas de aleación ferrosa maquinadas con troquel abierto|O|O||D||1
31301103|Forjas de acero maquinadas con troquel abierto|O|O||D||1
31301104|Forjas de acero inoxidable maquinadas con troquel abierto|O|O||D||1
31301105|Forjas de hierro maquinadas con troquel abierto|O|O||D||1
31301106|Forjas de aluminio maquinadas con troquel abierto|O|O||D||1
31301107|Forjas de magnesio maquinadas con troquel abierto|O|O||D||1
31301108|Forjas de titanio maquinadas con troquel abierto|O|O||D||1
31301109|Forjas de berilio maquinadas con troquel abierto|O|O||D||1
31301110|Forjas de cobre maquinadas con troquel abierto|O|O||D||1
31301111|Forjas de latón maquinadas con troquel abierto|O|O||D||1
31301112|Forjas de bronce maquinadas con troquel abierto|O|O||D||1
31301113|Forjas de zinc maquinadas con troquel abierto|O|O||D||1
31301114|Forjas de estaño maquinadas con troquel abierto|O|O||D||1
31301115|Forjas de plomo maquinadas con troquel abierto|O|O||D||1
31301116|Forjas de metales preciosos maquinadas con troquel abierto|O|O||D||1
31301117|Forjas compuestas maquinadas con troquel abierto|O|O||D||1
31301118|Forjas de aleación de níquel maquinadas con troquel abierto|O|O||D||1
31301119|Forjas no metálicas maquinadas con troquel abierto|O|O||D||1
31301200|Forjas labradas con troquel cerrado|O|O||D||1
31301201|Forjas de aleación no ferrosa maquinadas con troquel cerrado|O|O||D||1
31301202|Forjas de aleación ferrosa maquinadas con troquel cerrado|O|O||D||1
31301203|Forjas de acero maquinadas con troquel cerrado|O|O||D||1
31301204|Forjas de acero inoxidable maquinadas con troquel cerrado|O|O||D||1
31301205|Forjas de hierro maquinadas con troquel cerrado|O|O||D||1
31301206|Forjas de aluminio maquinadas con troquel cerrado|O|O||D||1
31301207|Forjas de magnesio maquinadas con troquel cerrado|O|O||D||1
31301208|Forjas de titanio maquinadas con troquel cerrado|O|O||D||1
31301209|Forjas de berilio maquinadas con troquel cerrado|O|O||D||1
31301210|Forjas de cobre maquinadas con troquel cerrado|O|O||D||1
31301211|Forjas de latón maquinadas con troquel cerrado|O|O||D||1
31301212|Forjas de bronce maquinadas con troquel cerrado|O|O||D||1
31301213|Forjas de zinc maquinadas con troquel cerrado|O|O||D||1
31301214|Forjas de estaño maquinadas con troquel cerrado|O|O||D||1
31301215|Forjas de plomo maquinadas con troquel cerrado|O|O||D||1
31301216|Forjas de metales preciosos maquinadas con troquel cerrado|O|O||D||1
31301217|Forjas compuestas maquinadas con troquel cerrado|O|O||D||1
31301218|Forjas de aleación de níquel maquinadas con troquel cerrado|O|O||D||1
31301219|Forjas no metálicas maquinadas con troquel cerrado|O|O||D||1
31301300|Forjas labradas de troquel de impresión|O|O||D||1
31301301|Forjas de aleación no ferrosa maquinadas con impresión por troquel|O|O||D||1
31301302|Forjas de aleación ferrosa maquinadas con impresión por troquel|O|O||D||1
31301303|Forjas de acero maquinadas con impresión por troquel|O|O||D||1
31301304|Forjas de acero inoxidable maquinadas con impresión por troquel|O|O||D||1
31301305|Forjas de hierro maquinadas con impresión por troquel|O|O||D||1
31301306|Forjas de aluminio maquinadas con impresión por troquel|O|O||D||1
31301307|Forjas de magnesio maquinadas con impresión por troquel|O|O||D||1
31301308|Forjas de titanio maquinadas con impresión por troquel|O|O||D||1
31301309|Forjas de berilio maquinadas con impresión por troquel|O|O||D||1
31301310|Forjas de cobre maquinadas con impresión por troquel|O|O||D||1
31301311|Forjas de latón maquinadas con impresión por troquel|O|O||D||1
31301312|Forjas de bronce maquinadas con impresión por troquel|O|O||D||1
31301313|Forjas de zinc maquinadas con impresión por troquel|O|O||D||1
31301314|Forjas de estaño maquinadas con impresión por troquel|O|O||D||1
31301315|Forjas de plomo maquinadas con impresión por troquel|O|O||D||1
31301316|Forjas de metales preciosos maquinadas con impresión por troquel|O|O||D||1
31301317|Forjas compuestas maquinadas con impresión por troquel|O|O||D||1
31301318|Forjas de aleación de níquel maquinadas con impresión por troquel|O|O||D||1
31301319|Forjas no metálicas maquinadas con impresión por troquel|O|O||D||1
31301400|Forjas labradas por reducción|O|O||D||1
31301401|Forjas de aleación no ferrosa maquinadas por reducción|O|O||D||1
31301402|Forjas de aleación ferrosa maquinadas por reducción|O|O||D||1
31301403|Forjas de acero maquinadas por reducción|O|O||D||1
31301404|Forjas de acero inoxidable maquinadas por reducción|O|O||D||1
31301405|Forjas de hierro maquinadas por reducción|O|O||D||1
31301406|Forjas de aluminio maquinadas por reducción|O|O||D||1
31301407|Forjas de magnesio maquinadas por reducción|O|O||D||1
31301408|Forjas de titanio maquinadas por reducción|O|O||D||1
31301409|Forjas de berilio maquinadas por reducción|O|O||D||1
31301410|Forjas de cobre maquinadas por reducción|O|O||D||1
31301411|Forjas de latón maquinadas por reducción|O|O||D||1
31301412|Forjas de bronce maquinadas por reducción|O|O||D||1
31301413|Forjas de zinc maquinadas por reducción|O|O||D||1
31301414|Forjas de estaño maquinadas por reducción|O|O||D||1
31301415|Forjas de plomo maquinadas por reducción|O|O||D||1
31301416|Forjas de metales preciosos maquinadas por reducción|O|O||D||1
31301417|Forjas compuestas maquinadas por reducción|O|O||D||1
31301418|Forjas de aleación de níquel maquinadas por reducción|O|O||D||1
31301419|Forjas no metálicas maquinadas por reducción|O|O||D||1
31301500|Forjas labradas de anillo cilindrado|O|O||D||1
31301501|Forjas de aluminio maquinadas por anillo enrollado|O|O||D||1
31301502|Forjas de berilio maquinadas por anillo enrollado|O|O||D||1
31301503|Forjas de latón maquinadas por anillo enrollado|O|O||D||1
31301504|Forjas de bronce maquinadas por anillo enrollado|O|O||D||1
31301505|Forjas de cobre maquinadas por anillo enrollado|O|O||D||1
31301506|Forjas de hierro maquinadas por anillo enrollado|O|O||D||1
31301507|Forjas de plomo maquinadas por anillo enrollado|O|O||D||1
31301508|Forjas de magnesio maquinadas por anillo enrollado|O|O||D||1
31301509|Forjas de metal precioso maquinadas por anillo enrollado|O|O||D||1
31301510|Forjas de acero inoxidable maquinadas por anillo enrollado|O|O||D||1
31301511|Forjas de estaño maquinadas por anillo enrollado|O|O||D||1
31301512|Forjas de titanio maquinadas por anillo enrollado|O|O||D||1
31301513|Forjas de zinc maquinadas por anillo enrollado|O|O||D||1
31301514|Forjas de aleación no ferrosa maquinadas por anillo enrollado|O|O||D||1
31301515|Forjas de aleación ferrosa maquinadas por anillo enrollado|O|O||D||1
31301516|Forjas de acero maquinadas por anillo enrollado|O|O||D||1
31301517|Forjas compuestas maquinadas por anillo enrollado|O|O||D||1
31301518|Forjas de aleación de níquel maquinadas por anillo enrollado|O|O||D||1
31301519|Forjas no metálicos maquinadas por anillo enrollado|O|O||D||1
31311100|Conjuntos de tubería soldada de solvente|O|O||D||1
31311101|Ensambles de tubería soldada de solvente de aluminio|O|O||D||1
31311102|Ensambles de tubería soldada de solvente de acero de carbono|O|O||D||1
31311103|Ensambles de tubería soldada de solvente de aleación hast x|O|O||D||1|Ensambles de tubería soldada de solvente de aleación de hastelloy x
31311104|Ensambles de tubería soldada de solvente de inconel|O|O||D||1
31311105|Ensambles de tubería soldada de solvente de acero de aleación baja|O|O||D||1
31311106|Ensambles de tubería soldada de solvente no metálico|O|O||D||1
31311109|Ensambles de tubería soldada de solvente de acero inoxidable|O|O||D||1
31311110|Ensambles de tubería soldada de solvente de titanio|O|O||D||1
31311111|Ensambles de tubería soldada de solvente de aleación wasp|O|O||D||1
31311112|Ensambles de tubería soldada de solvente de cobre|O|O||D||1
31311113|Ensambles de tubería soldada de solvente de latón|O|O||D||1
31311200|Conjuntos de tubería remachada|O|O||D||1
31311201|Ensambles de tubería remachada de aluminio|O|O||D||1
31311202|Ensambles de tubería remachada de acero al carbono|O|O||D||1
31311203|Ensambles de tubería remachada de aleación hast x|O|O||D||1|Ensambles de tubería remachada de aleación de hastelloy x
31311204|Ensambles de tubería remachada de inconel|O|O||D||1
31311205|Ensambles de tubería remachada de acero de aleación baja|O|O||D||1
31311206|Ensambles de tubería remachada no metálica|O|O||D||1
31311209|Ensambles de tubería remachada de acero inoxidable|O|O||D||1
31311210|Ensambles de tubería remachada de titanio|O|O||D||1
31311211|Ensambles de tubería remachada de aleación wasp|O|O||D||1
31311212|Ensambles de tubería remachada de cobre|O|O||D||1
31311213|Ensambles de tubería remachada de latón|O|O||D||1
31311300|Conjuntos empernados de tubería|O|O||D||1
31311301|Ensambles de tubería atornillada de aluminio|O|O||D||1
31311302|Ensambles de tubería atornillada de acero al carbono|O|O||D||1
31311303|Ensambles de tubería atornillada de aleación hast x|O|O||D||1|Ensambles de tubería atornillada de aleación hastelloy x
31311304|Ensambles de tubería atornillada de inconel|O|O||D||1
31311305|Ensambles de tubería atornillada de acero de aleación baja|O|O||D||1
31311306|Ensambles de tubería atornillada no metálica|O|O||D||1
31311309|Ensambles de tubería atornillada de acero inoxidable|O|O||D||1
31311310|Ensambles de tubería atornillada de titanio|O|O||D||1
31311311|Ensambles de tubería atornillada de aleación wasp|O|O||D||1
31311312|Ensambles de tubería atornillada de cobre|O|O||D||1
31311313|Ensambles de tubería atornillada de latón|O|O||D||1
31311400|Conjuntos de tuberías soldadas con ultra violeta UV|O|O||D||1
31311401|Ensambles de tubería soldada con ultra violeta de aluminio|O|O||D||1
31311402|Ensambles de tubería soldada con ultra violeta de acero al carbono|O|O||D||1
31311403|Ensambles de tubería soldada con ultra violeta de aleación hast x|O|O||D||1|Ensambles de tubería soldada con ultra violeta de aleación hastelloy x
31311404|Ensambles de tubería soldada con ultra violeta de inconel|O|O||D||1
31311405|Ensambles de tubería soldada con ultra violeta de acero de aleación baja|O|O||D||1
31311406|Ensambles de tubería soldada con ultra violeta no metálica|O|O||D||1
31311409|Ensambles de tubería soldada con ultra violeta de acero inoxidable|O|O||D||1
31311410|Ensambles de tubería soldada con ultra violeta de titanio|O|O||D||1
31311411|Ensambles de tubería soldada con ultra violeta de aleación wasp|O|O||D||1
31311412|Ensambles de tubería soldada con ultra violeta de cobre|O|O||D||1
31311413|Ensambles de tubería soldada con ultra violeta de latón|O|O||D||1
31311500|Conjuntos de tubería soldado o soldado con latón|O|O||D||1
31311501|Ensambles de tubería con soldadura fuerte o débil de aluminio|O|O||D||1
31311502|Ensambles de tubería con soldadura fuerte o débil de acero al carbono|O|O||D||1
31311503|Ensambles de tubería con soldadura fuerte o débil de aleación hast x|O|O||D||1|Ensambles de tubería con soldadura fuerte o débil de aleación hastelloy x
31311504|Ensambles de tubería con soldadura fuerte o débil de inconel|O|O||D||1
31311505|Ensambles de tubería con soldadura fuerte o débil de acero de aleación baja|O|O||D||1
31311506|Ensambles de tubería con soldadura fuerte o débil no metálica|O|O||D||1
31311509|Ensambles de tubería con soldadura fuerte o débil de acero inoxidable|O|O||D||1
31311510|Ensambles de tubería con soldadura fuerte o débil de titanio|O|O||D||1
31311511|Ensambles de tubería con soldadura fuerte o débil de aleación wasp|O|O||D||1
31311512|Ensambles de tubería con soldadura fuerte o débil de cobre|O|O||D||1
31311513|Ensambles de tubería con soldadura fuerte o débil de latón|O|O||D||1
31311600|Conjuntos de tubería soldada sónica|O|O||D||1
31311601|Ensambles de tubería con soldadura sónica de aluminio|O|O||D||1
31311602|Ensambles de tubería con soldadura sónica de acero al carbono|O|O||D||1
31311603|Ensambles de tubería con soldadura sónica de aleación hast x|O|O||D||1|Ensambles de tubería con soldadura sónica de aleación hastelloy x
31311604|Ensambles de tubería con soldadura sónica de inconel|O|O||D||1
31311605|Ensambles de tubería con soldadura sónica de acero de aleación baja|O|O||D||1
31311606|Ensambles de tubería con soldadura sónica no metálica|O|O||D||1
31311609|Ensambles de tubería con soldadura sónica de acero inoxidable|O|O||D||1
31311610|Ensambles de tubería con soldadura sónica de titanio|O|O||D||1
31311611|Ensambles de tubería con soldadura sónica de aleación wasp|O|O||D||1
31311612|Ensambles de tubería con soldadura sónica de cobre|O|O||D||1
31311613|Ensambles de tubería con soldadura sónica de latón|O|O||D||1
31311700|Conjuntos de tubería pegada|O|O||D||1
31311701|Ensambles de tubería pegada de aluminio|O|O||D||1
31311702|Ensambles de tubería pegada de acero al carbono|O|O||D||1
31311703|Ensambles de tubería pegada de aleación hast x|O|O||D||1|Ensambles de tubería pegada de aleación hastelloy x
31311704|Ensambles de tubería pegada de inconel|O|O||D||1
31311705|Ensambles de tubería pegada de acero de aleación baja|O|O||D||1
31311706|Ensambles de tubería pegada no metálica|O|O||D||1
31311709|Ensambles de tubería pegada de acero inoxidable|O|O||D||1
31311710|Ensambles de tubería pegada de titanio|O|O||D||1
31311711|Ensambles de tubería pegada de aleación wasp|O|O||D||1
31311712|Ensambles de tubería pegada de cobre|O|O||D||1
31311713|Ensambles de tubería pegada de latón|O|O||D||1
31321100|Conjuntos ligados de material en barras|O|O||D||1
31321101|Ensambles de barras pegadas de aluminio|O|O||D||1
31321102|Ensambles de barras pegadas de acero al carbono|O|O||D||1
31321103|Ensambles de barras pegadas de aleación hast x|O|O||D||1|Ensambles de barras pegadas de aleación hastelloy x
31321104|Ensambles de barras pegadas de inconel|O|O||D||1
31321105|Ensambles de barras pegadas de acero de aleación baja|O|O||D||1
31321106|Ensambles de barras pegadas no metálica|O|O||D||1
31321109|Ensambles de barras pegadas de acero inoxidable|O|O||D||1
31321110|Ensambles de barras pegadas de titanio|O|O||D||1
31321111|Ensambles de barras pegadas de aleación wasp|O|O||D||1
31321112|Ensambles de barras pegadas de cobre|O|O||D||1
31321113|Ensambles de barras pegadas de latón|O|O||D||1
31321200|Conjuntos soldados de solvente de material en barras|O|O||D||1
31321201|Ensambles de barras soldadas con solvente de aluminio|O|O||D||1
31321202|Ensambles de barras soldadas con solvente de acero al carbono|O|O||D||1
31321203|Ensambles de barras soldadas con solvente de aleación hast x|O|O||D||1|Ensambles de barras soldadas con solvente de aleación hastelloy x
31321204|Ensambles de barras soldadas con solvente de inconel|O|O||D||1
31321205|Ensambles de barras soldadas con solvente de acero de aleación baja|O|O||D||1
31321206|Ensambles de barras soldadas con solvente no metálica|O|O||D||1
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
