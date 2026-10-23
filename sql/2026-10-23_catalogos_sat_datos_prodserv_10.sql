-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 10 de 10 (3087 claves; total 52513)
--  Fecha: 2026-10-23  ·  Fuente: ...SAT26.xlsx (versión 4.0, publicada 2020-12-29)
--  Correr DESPUÉS de sql/2026-10-23_catalogos_sat_estructura.sql; las partes en cualquier orden.
--  Idempotente (upsert). Pegar COMPLETO en Supabase -> SQL Editor (≈216 KB).
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
71131406|Servicios de eliminación de depósitos de sulfato de hierro|O|O||D||1
71131407|Servicios de modelado de forzamiento de inyección|O|O||D||1
71131408|Servicios de modelado de formación de hidratos|O|O||D||1
71131409|Servicios de monitoreo de tratamientos químicos|O|O||D||1
71131410|Servicios de limpieza de conductos|O|O||D||1
71131411|Servicio de mejoramiento del flujo en los conductos|O|O||D||1
71131412|Servicios de mejoramiento y restauración de pozos|O|O||D||1
71131413|Servicios de inhibición de la corrosión|O|O||D||1
71131414|Servicios de inhibición de escamas|O|O||D||1|Servicios de inhibición de incrustaciones
71131415|Servicios de garantía del flujo en los conductos|O|O||D||1
71131416|Servicios de eliminación de impurezas|O|O||D||1
71131417|Servicios de control de incrustaciones orgánicas|O|O||D||1
71131418|Servicios de control de hongos y bacterias|O|O||D||1
71131419|Servicio de recolección de gas|O|O||D||1
71131420|Servicio de filtraciones de reflujo del pozo|O|O||D||1
71141000|Servicios de emergencia de control del pozo|O|O||D||1
71141001|Servicios de control de la presión del pozo|O|O||D||1
71141002|Servicios de tapado del pozo|O|O||D||1
71141003|Servicios de lucha contra incendios en el pozo|O|O||D||1
71141004|Servicios de control de pozos descontrolados|O|O||D||1
71141005|Reacondicionamiento de pozos muertos|O|O||D||1
71141006|Operaciones de congelamiento del pozo|O|O||D||1
71141007|Diseño e implementación de pozos de alivio|O|O||D||1
71141008|Servicios de ingeniería para el control de pozos|O|O||D||1
71141100|Servicios de tapar y abandono del pozo|O|O||D||1
71141101|Servicios de abandono de pozos|O|O||D||1
71141102|Servicios de taponamiento de pozos|O|O||D||1|Servicios de cierre de pozos
71141103|Servicios de eliminación de la plataforma para el abandono del pozo|O|O||D||1
71141104|Servicios de corte de tubería para el abandono y taponamiento de pozos|O|O||D||1|Servicios de corte de tubería para el abandono y cierre de pozos
71141200|Servicios de restaurar el sitio del pozo|O|O||D||1
71141201|Servicios de limpieza o achique del pozo|O|O||D||1
71141202|Servicios de restauración del emplazamiento del pozo|O|O||D||1
71151000|Servicios de comunicación de datos del campo petrolífero|O|O||D||1
71151001|Servicios de transmisión de mensajes y datos del campo petrolero|O|O||D||1
71151002|Servicios de transmisión de gráficas del campo petrolero|O|O||D||1
71151003|Servicios de monitoreo en tiempo real de datos del pozo en el campo petrolero|O|O||D||1
71151004|Servicios de transmisión satelital de datos del pozo en el campo petrolero|O|O||D||1
71151005|Servicios de transmisión de datos del pozo en el campo petrolero|O|O||D||1
71151007|Servicios de programas de capacitación de simulación basados en computador|O|O||D||1
71151100|Servicios de gerencia de datos del campo petrolífero|O|O||D||1
71151101|Servicios de administración de datos de los activos del campo petrolero|O|O||D||1
71151102|Servicios de minería de datos del campo petrolero|O|O||D||1
71151103|Servicios de gestión  de datos de registro del campo petrolero|O|O||D||1
71151104|Servicios de gestión de datos cartográficos del campo petrolero|O|O||D||1
71151105|Servicios de gestión de datos sísmicos|O|O||D||1
71151106|Copias de seguridad  y almacenamiento de datos|O|O||D||1
71151200|Servicios de modelo económico y de riesgo del campo petrolífero|O|O||D||1
71151201|Servicios de preparación del presupuesto del campo petrolero|O|O||D||1
71151202|Servicios de planificación del capital del campo petrolero|O|O||D||1
71151203|Servicios de estructura jerárquica (tree) de las decisiones del campo petrolero|O|O||D||1
71151300|Servicios de interpretación del campo petrolífero|O|O||D||1
71151301|Servicios de mapas de burbujas del campo petrolero|O|O||D||1
71151302|Estudios de casos del campo petrolero|O|O||D||1
71151303|Análisis del decaimiento del campo petrolero|O|O||D||1
71151304|Estudios de campo del campo petrolero|O|O||D||1
71151305|Servicios de interpretación de la fracturación  del campo petrolero|O|O||D||1
71151306|Servicios de geología|O|O||D||1
71151307|Servicios de geofísica|O|O||D||1
71151308|Servicios de interpretación del empaque con grava|O|O||D||1
71151309|Servicios de cartografía de cuadrícula del campo petrolero|O|O||D||1
71151310|Servicios de visualización o cartografía del campo petrolero|O|O||D||1
71151311|Servicios de petrofísica|O|O||D||1
71151315|Servicios de mecánica de rocas|O|O||D||1
71151316|Servicios de tanques de almacenamiento|O|O||D||1|Servicios de depósitos de almacenamiento
71151317|Evaluación general de la formación|O|O||D||1
71151318|Servicios de procesamiento de la forma de ondas acústicas|O|O||D||1|Servicios de procesamiento de ondas acústicas
71151319|Procesamiento de servicios geomecánicos|O|O||D||1
71151320|Servicios de interpretación y procesamiento de resonancia magnética nuclear|O|O||D||1
71151321|Servicios de interpretación y procesamiento de la resistividad|O|O||D||1
71151322|Procesamiento de la dirección y el ángulo de inclinación|O|O||D||1
71151323|Procesamiento de imágenes de la perforación|O|O||D||1
71151324|Registro durante procesamiento de perforación|O|O||D||1
71151325|Servicios de procesamiento e interpretación de los neutrones pulsados|O|O||D||1
71151326|Procesamiento general de los registros de producción y agujeros revestidos|O|O||D||1
71151327|Procesamiento de los servicios de análisis de inspección de la tubería|O|O||D||1
71151400|Servicios de ingeniería del pozo|O|O||D||1
71151401|Servicios de diseño de las tareas de cementación del pozo|O|O||D||1
71151402|Servicios de diseño de las tareas con tubería flexible continua|O|O||D||1
71151403|Servicios de diseño de la tarea de perforar el pozo|O|O||D||1|Servicios de diseño de los trabajos de perforación de pozos
71151404|Servicios de diseño de las tareas de fracturación del pozo|O|O||D||1|Servicios de diseño de los trabajos de fractura de pozos
71151405|Servicios de diseño de la tareas de estimulación de la matriz|O|O||D||1|Servicios de diseño de los trabajos de estimulación matricial
71151406|Servicios de diseño de las tareas para el control de arena del pozo|O|O||D||1|Servicios de diseño de los trabajos para el control de arena del pozo
71161000|Servicios de modelar del campo petrolífero|O|O||D||1
71161001|Modelos de terminación  del campo petrolero|O|O||D||1
71161002|Modelos de perforación del campo petrolero|O|O||D||1
71161003|Modelos económicos del campo petrolero|O|O||D||1
71161004|Modelos del desarrollo del campo del campo petrolero|O|O||D||1
71161005|Modelos de producción del campo petrolero|O|O||D||1
71161006|Servicios de gestión de riesgo del campo petrolero|O|O||D||1
71161007|Modelos geológicos o geofísicos|O|O||D||1
71161008|Modelos de yacimientos|O|O||D||1
71161100|Gerencia de la ingeniería de producción del campo petrolífero|O|O||D||1
71161101|Servicios de elevadores artificiales del campo petrolero|O|O||D||1
71161102|Servicios de recuperación aumentada del petróleo|O|O||D||1|Servicios mejorados de recuperación de petróleo
71161103|Servicios de inyección del pozo|O|O||D||1
71161104|Servicios de análisis del sistema de producción del campo petrolero|O|O||D||1
71161105|Servicios de perforación de pozos|O|O||D||1
71161106|Servicios de química de la producción del campo petrolero|O|O||D||1
71161107|Servicios de monitoreo de la producción del campo  petrolero|O|O||D||1
71161109|Servicios de estimulación  del pozo|O|O||D||1
71161110|Servicios de almacenamiento subterráneo de gas|O|O||D||1
71161111|Servicios de administración del agua del campo petrolífero|O|O||D||1|Servicios de gestión del agua para campos petrolíferos
71161200|Gerencia de las operaciones de producción del campo petrolífero|O|O||D||1
71161201|Servicios de lubricación en caliente del campo petrolero|O|O||D||1|Servicio de unidades de aceite caliente
71161202|Servicios de operaciones de arriendo|O|O||D||1|Operaciones de arrendamiento de yacimientos petrolíferos
71161203|Servicios de registro del campo petrolero|O|O||D||1
71161204|Servicios de corte de parafina en el campo petrolero|O|O||D||1
71161205|Servicios de planificación de campos petroleros|O|O||D||1
71161206|Servicios de procesamiento de campos petroleros|O|O||D||1
71161300|Servicios de manejo de proyectos del campo|O|O||D||1
71161301|Servicios de inspección o auditoría de campos petroleros|O|O||D||1
71161302|Servicios de planificación de respuesta de emergencia del campo petrolero|O|O||D||1
71161303|Servicios de desarrollo de campos petroleros|O|O||D||1
71161304|Servicios de monitoreo del rendimiento del campo petrolero|O|O||D||1
71161305|Servicios de presentación informes del campo petrolero|O|O||D||1
71161306|Servicios de entrega (handover) o plan de sucesión del campo petrolero|O|O||D||1|Plan de sucesión de campos petrolíferos o servicios de traspaso
71161307|Servicios de matriz de entrenamiento del campo petrolero|O|O||D||1
71161308|Servicios de aprovisionamiento o logística del emplazamiento del pozo|O|O||D||1
71161400|Servicios de manejo de proyectos del campo petrolero|O|O||D||1
71161402|Servicios de ingeniería para la terminación del pozo|O|O||D||1
71161403|Servicios de anclaje (deadman)|O|O||D||1
71161405|Servicios de revestimiento de pozos en su emplazamiento|O|O||D||1
71161407|Servicios de unidad  jaladora para el pozo|O|O||D||1|Servicio de unidad de tracción de pozos
71161408|Servicios en la costa|O|O||D||1
71161409|Servicios de revestimiento de pozos de exploración|O|O||D||1
71161410|Servicios de camiones de vacío en el emplazamiento del pozo|O|O||D||1
71161411|Servicios de ingeniería de aplicaciones desbalanceadas|O|O||D||1
71161413|Servicios de construcción o fabricación de pozos|O|O||D||1
71161414|Servicio de botes elevadores para el reacondicionamiento de pozos|O|O||D||1|Servicio de barcos elevadores para el reacondicionamiento de pozos
71161500|Servicios de operación del lugar de la perforación|O|O||D||1
71161503|Servicios de pruebas de equipo o inspección del emplazamiento del pozo|O|O||D||1
71161600|Otros servicios de soporte para campos petroleros|O|O||D||1
71161601|Servicios de dibujo para campos petroleros|O|O||D||1|Servicios de planos para campos petroleros
71161602|Servicios de corretaje de equipos para campos petroleros|O|O||D||1
71161603|Servicios de investigación y desarrollo de campos petroleros|O|O||D||1
71161604|Servicios de certificación de campos petroleros|O|O||D||1
71161605|Servicios de consultoría de campos petroleros|O|O||D||1
71161606|Servicio de licencia tecnológica para gas y petróleo|O|O||D||1
72101500|Servicios de apoyo para la construcción|O|O||D||1
72101501|Servicios de todero|O|O||D||1|Servicio de empleados de mantenimiento, Servicio de trabajadores de mantenimiento
72101504|Servicios de verificación de desastres o contingencias|O|O||D||1
72101505|Servicios de cerrajería|O|O||D||1
72101506|Servicios de mantenimiento de ascensores|O|O||D||1|Servicios de mantenimiento de elevadores
72101507|Servicio de mantenimiento de edificios|O|O||D||1
72101508|Servicio de limpieza de pisos|O|O||D||1
72101509|Servicio de mantenimiento o reparación de equipos y sistemas de protección contra incendios|O|O||D||1
72101510|Mantenimiento o reparación del sistema de plomería|O|O||D||1
72101511|Servicio de instalación o mantenimiento o reparación de aires acondicionados|O|O||D||1
72101512|Servicio de construcción de malacates|O|O||D||1|Servicio de elevadores de construcción
72101513|Servicio de construcción fuera del sitio (offsite)|O|O||D||1|Servicio de construcción exterior
72101514|Servicio de construcción de zonas de desperdicios|O|O||D||1
72101515|Servicio de trabajos por hundimiento|O|O||D||1
72101516|Servicio de inspección, mantenimiento o reparación de extinguidores de fuego|O|O||D||1
72101517|Servicio de mantenimiento o reparación de generadores portátiles|O|O||D||1
72101518|Servicio de alquiler de generadores portátiles|O|O||D||1|Servicio de arrendamiento de generadores portátiles, Servicio de renta de generadores portátiles
72102100|Control de plagas|O|O||D||1
72102101|Servicios de verificación de presencia de aves|O|O||D||1|Servicios de sistemas anti aves
72102102|Servicios de control de termitas|O|O||D||1
72102103|Servicios de exterminación o fumigación|O|O||D||1
72102104|Control estructural de plagas|O|O||D||1|Control estructural de pestes
72102105|Captura de animales|O|O||D||1
72102106|Control de roedores|O|O||D||1|Control de ratones
72102900|Servicios de mantenimiento y reparación de instalaciones|O|O||D||1
72102902|Servicios de paisajismo|O|O||D||1|Servicios de jardinería
72102903|Servicios de eliminación de nieve|O|O||D||1|Servicios de retirada de nieve
72102905|Mantenimiento de terrenos exteriores|O|O||D||1
72103100|Instalación y reparación de servicios de bandas transportadoras|O|O||D||1
72103101|Instalación de sistemas de transporte de materiales|O|O||D||1
72103102|Reparación de sistemas de transporte de materiales|O|O||D||1
72103103|Servicio transportador de superficie|O|O||D||1
72103104|Servicio transportador subterráneo|O|O||D||1
72103300|Servicios de mantenimiento y reparación de infraestructura|O|O||D||1
72103301|Servicios o reparaciones o mantenimiento de calles o parqueaderos|O|O||D||1|Mantenimiento o reparaciones o servicios de estacionamiento o de caminos
72103302|Mantenimiento o soporte de equipo de telecomunicaciones|O|O||D||1
72103304|Servicios de barrido de calles o parqueaderos|O|O||D||1|Servicios de barrido de aparcamiento o de carretera
72111000|Servicios de construcción de unidades unifamiliares|O|O||D||1
72111001|Servicios de reparación o ampliación por remodelación de viviendas unifamiliares|O|O||D||1
72111002|Servicio de remodelación general de viviendas unifamiliares|O|O||D||1
72111003|Servicio de reparación de casas móviles en el sitio|O|O||D||1|Servicios de reparación a domicilio
72111004|Servicio de construcción y reparación de patios y terrazas|O|O||D||1
72111005|Servicio de reparación por daños ocasionados por fuego de viviendas unifamiliares|O|O||D||1
72111006|Servicio de construcción de casas unifamiliares nuevas|O|O||D||1
72111007|Servicio de instalación de casas unifamiliares prefabricadas|O|O||D||1
72111008|Servicio de construcción de casas en la ciudad o casas jardín unifamiliares nuevas|O|O||D||1
72111100|Servicios de construcción de unidades multifamiliares|O|O||D||1
72111101|Servicio de construcción de apartamentos nuevos|O|O||D||1
72111102|Servicio de construcción de cooperativas nuevas|O|O||D||1
72111103|Servicio de construcción de condominios nuevos|O|O||D||1
72111104|Servicio de construcción de residenciales estudiantiles nuevas|O|O||D||1|Servicio de construcción de residencias estudiantiles nuevas
72111105|Servicio de construcción de hoteles o moteles nuevos|O|O||D||1
72111106|Servicio de remodelación de apartamentos|O|O||D||1|Servicio de remodelación de departamentos
72111107|Servicio de remodelación de apartamentos cooperativos|O|O||D||1|Servicio de remodelación de departamentos cooperativos
72111108|Servicio de remodelación de condominios|O|O||D||1
72111109|Servicio de remodelación de residencias estudiantiles|O|O||D||1
72111110|Servicio de remodelación de hoteles o moteles|O|O||D||1
72111111|Servicios de contratación general para la construcción de residencias|O|O||D||1|Servicios de contratista general para la construcción de residencias
72121000|Servicios de construcción de edificios industriales y bodegas nuevas|O|O||D||1
72121001|Servicio de construcción y remodelación de plantas de lavado en seco|O|O||D||1
72121002|Servicio de construcción y remodelación de plantas de elaboración o empaque de productos alimenticios|O|O||D||1
72121003|Servicio de construcción y remodelación de elevadores de granos|O|O||D||1
72121004|Servicio de construcción o remodelación de molinos de papel o pulpa|O|O||D||1
72121005|Servicio de construcción y remodelación de plantas de productos farmacéuticos|O|O||D||1
72121006|Servicio de instalación y remodelación de edificaciones industriales prefabricadas|O|O||D||1
72121007|Servicio de construcción y remodelación de plantas ensambladoras de automóviles y camiones|O|O||D||1
72121008|Servicio de construcción y remodelación de bodegas|O|O||D||1|Servicio de construcción y remodelación de almacenes
72121100|Servicios de construcción de edificios comerciales y de oficina|O|O||D||1
72121101|Servicio de construcción de edificios comerciales y de oficinas nuevos|O|O||D||1
72121102|Servicio de instalación de edificios comerciales y de oficinas prefabricados|O|O||D||1
72121103|Servicios de renovación y reparación de edificios comerciales y de oficinas|O|O||D||1
72121104|Servicio de construcción de restaurantes|O|O||D||1
72121105|Servicio de construcción de centros y galerías comerciales|O|O||D||1
72121200|Servicios de construcción de edificios agrícolas|O|O||D||1
72121201|Servicio de construcción de edificaciones para fincas|O|O||D||1|Servicio de construcción de granjas
72121202|Servicio de construcción de invernaderos|O|O||D||1
72121203|Servicio de construcción de edificaciones para servicios agrícolas y de silos|O|O||D||1
72121300|Servicios de construcción de talleres automotrices y estaciones de servicio|O|O||D||1
72121301|Servicio de construcción de garajes automotrices|O|O||D||1|Servicio de construcción de cocheras automotrices
72121302|Servicio de construcción de estaciones de servicios automotrices|O|O||D||1
72121400|Servicios de construcción de edificios públicos especializados|O|O||D||1
72121401|Servicio de construcción de edificios de bancos|O|O||D||1|Servicio de construcción de edificios bancarios
72121402|Servicio de construcción de estaciones de bomberos|O|O||D||1
72121403|Servicio de construcción de hospitales|O|O||D||1
72121404|Servicio de construcción de oficinas de correo|O|O||D||1
72121405|Servicios de construcción de edificios religiosos|O|O||D||1|Servicios de construcción de iglesias
72121406|Servicio de construcción de edificios de escuelas|O|O||D||1
72121407|Servicio de construcción de mausoleos|O|O||D||1|Servicio de construcción de criptas
72121408|Servicio de construcción de estadios|O|O||D||1
72121409|Construcción de bibliotecas públicas|O|O||D||1
72121410|Construcción de terminales y hangares de aeropuertos|O|O||D||1
72121500|Servicios de construcción de plantas industriales|O|O||D||1
72121501|Servicio de construcción de plantas químicas|O|O||D||1
72121502|Servicio de construcción de estaciones de carga y descarga de las minas|O|O||D||1
72121503|Servicio de construcción de refinerías de petróleo|O|O||D||1
72121504|Servicio de construcción de plantas de eliminación de aguas|O|O||D||1
72121505|Servicio construcción de plantas de tratamiento de aguas residuales y aguas negras|O|O||D||1
72121506|Servicio de construcción de centrales eléctricas|O|O||D||1
72121507|Construcción, mantenimiento y reparación de tanques|O|O||D||1
72121508|Servicio de construcción de plantas de preparación|O|O||D||1
72121509|Servicios eléctricos subterráneos|O|O||D||1
72121510|Servicio de construcción de sistemas flotantes de descarga y almacenamiento de la producción de gas y petróleo|O|O||D||1
72121511|Servicio de montaje y puesta en servicio de instalaciones de gas y petróleo mar adentro|O|O||D||1|Servicio de conexión y puesta en servicio de instalaciones de producción de petróleo y gas en alta mar
72121512|Servicio de integración e instalación de complejos de producción de gas y petróleo mar adentro|O|O||D||1|Servicio de instalación e integración de estructuras de producción de petróleo y gas en alta mar
72121513|Servicio de fabricación modular de plantas de gas y petróleo|O|O||D||1
72121514|Servicio de fabricación de plataformas y superestructuras  de producción de gas y petróleo|O|O||D||1
72121515|Servicio de fabricación de cascos para sistema  flotantes de producción de gas y petróleo|O|O||D||1
72121516|Servicios de fabricación de instalaciones fijas de producción de gas y petróleo mar adentro|O|O||D||1
72121517|Servicio de construcción de plantas de gas natural líquido gnl|O|O||D||1
72141000|Servicios de construcción de autopistas y carreteras|O|O||D||1
72141001|Servicio de construcción de calles y carreteras nuevas|O|O||D||1
72141002|Servicio de construcción y reparación de barandas de seguridad y señales de calles y carreteras|O|O||D||1|Servicio de construcción y reparación de vallas de contención y señales viales y carreteras
72141003|Servicio de mantenimiento de calles y carreteras|O|O||D||1
72141004|Servicio de instalación de reflectores para carreteras|O|O||D||1
72141100|Servicios de pavimentación y superficies de edificios de infraestructura|O|O||D||1
72141101|Servicio de construcción de pistas aeroportuarias|O|O||D||1
72141102|Servicio de nivelación del terreno|O|O||D||1
72141103|Servicio de pavimentación de calles y carreteras|O|O||D||1
72141104|Servicio de repavimentación de calles y carreteras|O|O||D||1
72141105|Servicio de construcción y reparación de aceras|O|O||D||1
72141106|Servicio de construcción de carreteras de grava o tierra|O|O||D||1
72141107|Servicio de construcción y reparación de puentes|O|O||D||1
72141108|Servicio de construcción y reparación de túneles|O|O||D||1
72141109|Servicio de construcción y reparación de viaductos|O|O||D||1
72141110|Servicio de construcción de ramales para gas y petróleo|O|O||D||1|Servicio de construcción de líneas de distribución de petróleo y gas
72141111|Servicio de construcción de tubería maestra de gas|O|O||D||1|Servicio de construcción de tubería principal de gas
72141112|Servicio de construcción de estaciones compresoras de gas natural|O|O||D||1
72141113|Servicio de construcción de tuberías para gas y petróleo|O|O||D||1
72141114|Servicio de revestimiento de tuberías|O|O||D||1
72141115|Servicio de tendido de cables eléctricos|O|O||D||1
72141116|Servicio de tendido de cables de televisión|O|O||D||1
72141117|Servicio de tendido de cables de comunicación y teléfonos|O|O||D||1
72141118|Servicio de construcción de torres de transmisión para telecomunicaciones|O|O||D||1
72141119|Servicio de construcción de acueductos|O|O||D||1
72141120|Servicio de construcción de líneas de alcantarillado|O|O||D||1|Servicio de construcción de líneas de desagüe
72141121|Servicio de construcción de tubería maestra de agua|O|O||D||1|Servicio de construcción de tubería principal de agua
72141122|Servicio de construcción de líneas de energía eléctrica|O|O||D||1
72141123|Servicio de construcción de bocas de acceso|O|O||D||1|Servicio de construcción de coladeras
72141124|Servicio de tendido de tubería|O|O||D||1
72141125|Servicio de construcción de estaciones de bombeo|O|O||D||1
72141126|Servicio de construcción de servicios públicos subterráneos|O|O||D||1
72141200|Servicios de construcción marina|O|O||D||1|Servicios de construcciones marítimas
72141201|Servicio de perforación de compuertas flotantes|O|O||D||1|Servicio de perforación de cajón hidráulico
72141202|Servicio de construcción de canales|O|O||D||1
72141203|Servicio de construcción de represas|O|O||D||1
72141204|Servicio de construcción de dársenas|O|O||D||1|Servicio de construcción de muelles
72141205|Servicio de construcción de sistemas de drenaje|O|O||D||1
72141206|Servicio de dragado|O|O||D||1|Servicio de  limpieza de los sedimentos en cursos de agua, lagos, bahías
72141207|Servicio de construcción de muelles|O|O||D||1|Servicio de construcción portuaria
72141208|Servicio de construcción de sistemas de riego|O|O||D||1|Servicio de construcción de sistemas de irrigación
72141209|Servicio de construcción de diques o malecones|O|O||D||1|Servicio de construcción de escolleras
72141210|Servicio de construcción de marinas|O|O||D||1|Servicio construcción de puerto deportivo
72141211|Servicio de construcción de embarcaderos|O|O||D||1
72141212|servicio de construcción de estanques|O|O||D||1
72141213|Servicio de construcción de vías de agua|O|O||D||1
72141214|Servicio de movimiento de pilas de láminas|O|O||D||1
72141215|Servicio de construcción submarina|O|O||D||1
72141216|Servicio de embarcaciones para construcciones en alta mar|O|O||D||1
72141300|Servicio de construcción de facilidades atléticas y recreativas|O|O||D||1|Servicio de construcción de instalaciones atléticas y recreativas
72141301|Servicio de construcción de canchas de atletismo|O|O||D||1
72141302|Servicio de construcción de campos de golf|O|O||D||1
72141303|Servicio de construcción de canchas de tenis|O|O||D||1
72141400|Servicios de construcción y reparación de facilidades de detención|O|O||D||1|Servicios de construcción y reparación de instalaciones penitenciarias
72141401|Servicio de construcción de instalaciones de detención|O|O||D||1|Servicio de construcción de cárceles, Servicio de construcción de prisiones
72141402|Remodelación y reparación de instalaciones de detención|O|O||D||1|Remodelación y reparación de cárceles, Remodelación y reparación de prisiones
72141500|Servicios de preparación de tierras|O|O||D||1
72141502|Servicio de recuperación de tierras|O|O||D||1
72141503|Servicio de remoción de piedras|O|O||D||1
72141504|Servicio de remoción de madera|O|O||D||1
72141505|Servicio de movimiento de tierras|O|O||D||1
72141507|Servicio de movimiento de pilotes|O|O||D||1
72141508|Servicio de voladura, excepto para demolición de edificios|O|O||D||1
72141509|Servicio de zanjado|O|O||D||1
72141510|Servicios de demolición|O|O||D||1
72141511|Servicio de excavación|O|O||D||1
72141600|Servicios de construcción de sistemas de tránsito masivo|O|O||D||1
72141601|Servicio de construcción de riel ligero|O|O||D||1
72141602|Servicio de corte para derecho de vía|O|O||D||1
72141603|Servicio de construcción de lechos de vía para ferrocarril y vías férreas|O|O||D||1
72141604|Servicio de construcción de metro|O|O||D||1
72141605|Servicio de tendido de rieles ferroviarios|O|O||D||1
72141700|Servicios de alquiler o arrendamiento de equipo y maquinaria de construcción|O|O||D||1
72141701|Servicio de alquiler o leasing de maquinaria para construcción|O|O||D||1|Renta de maquinaria de construcción
72141702|Servicio de alquiler o leasing de equipo para construcción|O|O||D||1|Renta de equipo para construcción
72151000|Servicios de construcción y mantenimiento de calderas y hornos|O|O||D||1
72151001|Servicio de mantenimiento de calderas|O|O||D||1|Servicio de mantenimiento de boiler, Servicio de mantenimiento de calentador
72151002|Servicio de instalación y montaje de calderas|O|O||D||1|Servicio de instalación y montaje de boilers, Servicio de instalación y montaje de calentadores
72151003|Servicio de mantenimiento y reparación de sistemas de calefacción|O|O||D||1
72151004|Servicio de mantenimiento y reparación de sistemas de calefacción por agua caliente|O|O||D||1
72151005|Instalación de controladores de presión de calderas|O|O||D||1|Instalación de controladores de presión de boilers, Instalación de controladores de presión de calentadores
72151006|Mantenimiento o reparación u operación de  controladores de presión de calderas|O|O||D||1|Mantenimiento o reparación u operación de  controladores de presión de boilers, Mantenimiento o reparación u operación de  controladores de presión de calentadores
72151100|Servicios de construcción de plomería|O|O||D||1
72151101|Servicio de construcción de sistemas sépticos|O|O||D||1
72151102|Servicio de instalación de sistemas de rociadores contra incendio|O|O||D||1
72151103|Servicio de instalación de sistemas de rociadores para riego|O|O||D||1
72151200|Servicios de construcción y mantenimiento de HVAC calefacción y enfriamiento y aire acondicionado|O|O||D||1
72151201|Servicio de construcción mecánica hvac|O|O||D||1
72151202|Servicio de construcción de tubería mediante proceso hvac|O|O||D||1
72151203|Servicio de construcción de energía solar hvac|O|O||D||1
72151204|Servicio de trabajo de ductos y ventilación hvac|O|O||D||1
72151205|Servicio de construcción de refrigeración hvac|O|O||D||1
72151206|Servicio de construcción de sistemas de calefacción hvac|O|O||D||1
72151207|Servicio de instalación y mantenimiento acondicionamiento del aire, enfriamiento y calefacción hvac|O|O||D||1
72151300|Servicios de pintura e instalación de papel de colgadura|O|O||D||1|Servicios de pintura e instalación de papel de tapiz
72151301|Servicio de pintura residencial|O|O||D||1
72151302|Servicio de pintura comercial|O|O||D||1
72151303|Servicio de pintura industrial|O|O||D||1
72151304|Servicio de pintura de aeronaves|O|O||D||1
72151305|Servicio de pintura de puentes|O|O||D||1
72151306|Servicio de marcación de pavimento|O|O||D||1|Servicio de marcación de asfalto
72151307|Servicio de pintura de buques|O|O||D||1
72151308|Servicio de colgadura de papel|O|O||D||1|Servicio de tapizado de papel
72151400|Servicios de construcción de recubrimientos de muros|O|O||D||1
72151401|Servicio comercial de construcción y revestimiento de paredes|O|O||D||1
72151402|Servicio residencial de construcción y cubrimiento de paredes|O|O||D||1
72151500|Servicios de sistemas eléctricos|O|O||D||1|Servicios de instalaciones eléctricas
72151501|Servicios de instalación de iluminación|O|O||D||1|Servicio de instalación eléctrica, Servicio de instalación para cableado
72151502|Servicio de construcción de sistemas de energía eléctrica|O|O||D||1
72151503|Servicio de instalación de plantas de cogeneración|O|O||D||1
72151504|Servicio de acondicionamiento de energía para computadores|O|O||D||1|Servicio de acondicionamiento de la energía del ordenador
72151505|Servicio de instalación de energía de emergencia o de reserva|O|O||D||1
72151506|Servicio de instalación de mecanismos de control y dispositivos relacionados|O|O||D||1|Servicio de instalación de aparellaje y dispositivos relacionados
72151507|Servicio de instalación de controles electrónicos|O|O||D||1
72151508|Servicio de instalación de controles computarizados|O|O||D||1
72151509|Servicio de instalación de controles de la  administración de la energía|O|O||D||1|Servicio de instalación de controles de administración de energía
72151510|Servicio de instalación de controles del sistema ambiental|O|O||D||1
72151511|Servicio de mantenimiento o reparación de sistemas de iluminación|O|O||D||1
72151514|Servicio de mantenimiento de energía de emergencia o de reserva|O|O||D||1
72151515|Servicio de inspección eléctrica|O|O||D||1
72151600|Servicios de sistemas especializados de comunicación|O|O||D||1
72151601|Servicio de instalación de televisión por cable|O|O||D||1
72151602|Servicio de instalación de cables de fibra óptica|O|O||D||1
72151603|Servicio de instalación de equipos de sonido especializados|O|O||D||1
72151604|Servicio de  instalación de teléfonos y equipos para teléfonos|O|O||D||1
72151605|Servicio de cableado para video, datos y voz|O|O||D||1
72151606|Ingeniería subterránea para equipos de comunicaciones|O|O||D||1
72151607|Ingeniería de superficie para equipos de comunicaciones|O|O||D||1|Ingeniería de campo para equipos de comunicación
72151608|Servicio de mantenimiento o reparación de sistemas satelitales|O|O||D||1
72151609|Servicio de soporte del eje de sistemas satelitales|O|O||D||1|Servicio de soporte del concentrador del sistema satelital
72151700|Servicios de instalación de sistemas de seguridad física e industrial|O|O||D||1
72151701|Servicio de instalación de sistemas de control de acceso|O|O||D||1
72151702|Servicio de instalación de sistemas de televisión de circuito cerrado|O|O||D||1
72151703|Servicio de instalación de sistemas de alarmas contra robo y detección de fuego|O|O||D||1|Servicio de instalación de sistemas de detección de incendios y sistemas de alarma antirrobo
72151704|Servicio de instalación y mantenimiento de sistemas instrumentados de seguridad|O|O||D||1
72151800|Servicios de mantenimiento y reparación de instalación de máquinas|O|O||D||1
72151801|Instalación y mantenimiento cajeros automáticos|O|O||D||1|Instalación y mantenimiento de máquinas bancarias
72151802|Servicio de refacción y reparación de componentes de maquinaria|O|O||D||1
72151803|Servicio de instalación y mantenimiento de máquinas expendedoras|O|O||D||1
72151900|Servicios de albañilería y mampostería|O|O||D||1
72151901|Servicio de cimentación de construcciones|O|O||D||1
72151903|Servicio de colocación de ladrillos|O|O||D||1
72151904|Servicio de construcción y mantenimiento de chimeneas|O|O||D||1
72151905|Servicio de mampostería en bloques de concreto|O|O||D||1|Servicio de colocación de bloques de concreto
72151906|Servicio de instalación de tubería de drenaje|O|O||D||1
72151907|Servicio de mampostería en mármol en exteriores|O|O||D||1|Servicio de colocación de mármol en exteriores
72151908|Servicios de mampostería en ladrillos a prueba de ácido o refractarios|O|O||D||1|Servicio de colocación de ladrillos a prueba de ácido o refractarios
72151909|Servicio de mampostería en piedra|O|O||D||1|Servicio de colocación de piedra
72151910|Servicio de restauración o renovación de juntas con mortero|O|O||D||1
72151911|Servicio de instalación de adoquines unitarios|O|O||D||1
72152000|Servicios de pañetado y drywall|O|O||D||1
72152001|Servicio de instalación y reparación de drywall|O|O||D||1|Servicio de instalación y reparación de paneles de yeso, Servicio de instalación y reparación de tablaroca
72152002|Servicio de instalación y reparación de frescos|O|O||D||1
72152003|Servicio de instalación y reparación de repisas para chimenea|O|O||D||1
72152004|Servicio de enyesado ornamental o sencillo|O|O||D||1
72152005|Servicio de instalación y reparación de estuco|O|O||D||1
72152100|Servicios acústicos y de aislamiento|O|O||D||1
72152101|Servicio de trabajos acústicos y de cielorraso|O|O||D||1
72152102|Servicio de aislamiento y acabado de exteriores|O|O||D||1
72152103|Servicio de aislamiento de edificaciones|O|O||D||1
72152104|Servicio de películas de aislamiento de reflexión solar|O|O||D||1
72152200|Servicios de baldosas Terrazo y mármol y mosaicos|O|O||D||1
72152201|Servicio de instalación de mármol en interiores|O|O||D||1
72152202|Servicio creación y reparación de mosaicos|O|O||D||1
72152203|Servicio de instalación y reparación de terrazos|O|O||D||1
72152204|Servicio de instalación de baldosas de cerámica|O|O||D||1|Servicio de instalación de losas de cerámica
72152300|Servicios de carpintería|O|O||D||1
72152301|Servicio de carpintería rústica|O|O||D||1
72152302|Servicio de ebanistería|O|O||D||1
72152303|Servicio de construcción e instalación de gabinetes|O|O||D||1
72152400|Servicios de montaje e instalación de ventanas y puertas|O|O||D||1
72152401|Servicio de instalación o colocación de puertas de garaje|O|O||D||1|Servicio de instalación o colocación de puertas de cocheras
72152402|Servicio de instalación de ventanas y puertas prefabricadas|O|O||D||1
72152403|Servicio de enmarcación de vías de entrada y de salida|O|O||D||1
72152404|Servicio de instalación de clavos metálicos|O|O||D||1
72152405|Servicio de instalación de artefactos fijos en tiendas|O|O||D||1
72152500|Servicios de instalación de pisos|O|O||D||1
72152501|Servicio de instalación de sistemas de pisos de acceso|O|O||D||1
72152502|Servicio de instalación de baldosas de asfalto|O|O||D||1|Servicio de instalación de losa de asfalto
72152503|Servicio de instalación de tapetes|O|O||D||1|Servicio de instalación de alfombras
72152504|Servicio de instalación de baldosas de cerámica  para pisos|O|O||D||1
72152505|Servicio de instalación de linóleo|O|O||D||1
72152506|Servicio de instalación de piso de revestimiento elástico|O|O||D||1|Servicio de instalación de suelo con revestimiento elástico
72152507|Servicio de instalación de láminas y baldosas de vinilo para pisos|O|O||D||1
72152508|Servicio de instalación y acabados de pisos de madera|O|O||D||1
72152509|Servicio de nivelación de pisos|O|O||D||1
72152600|Servicios de techado y paredes externas y láminas de metal|O|O||D||1
72152601|Servicio de techado|O|O||D||1
72152602|Servicio de tubos de desagüe y bajantes|O|O||D||1
72152603|Servicio de instalación de claraboyas|O|O||D||1|Servicio de instalación de tragaluces
72152604|Servicio de laminas metálicas arquitectónicas|O|O||D||1
72152605|Servicio de instalación y reparación de cielorrasos|O|O||D||1
72152606|Servicio de instalación y reparación de paredes externas|O|O||D||1
72152607|Servicio de instalación de canaletas de descarga|O|O||D||1|Servicio de instalación de tolvas
72152700|Servicios de instalación y reparación de concreto|O|O||D||1
72152701|Servicio de estuco de concreto en exteriores|O|O||D||1
72152702|Servicio de lechada|O|O||D||1
72152703|Servicio de instalación de hormigón proyectado|O|O||D||1
72152704|Servicio de construcción de bordes de acera|O|O||D||1|Servicio de construcción de banquetas
72152705|Servicio de instalación de aceras o rampas|O|O||D||1|Servicio de instalación de banquetas o rampas
72152706|Servicio de construcción de caminos particulares para vehículos|O|O||D||1
72152707|Servicio de construcción de muros de retención|O|O||D||1|Servicio de construcción de muros de contención
72152708|Servicio de construcción de parqueaderos|O|O||D||1|Servicio de construcción de estacionamientos
72152709|Servicio de trasiego de concreto|O|O||D||1|Servicio de bombeo de hormigón
72152710|Servicio de cimentación y nivelación para construcciones|O|O||D||1
72152711|Servicio de construcción de patios de concreto|O|O||D||1
72152800|Servicios de perforación de pozos de agua|O|O||D||1
72152801|Servicio de perforación de pozos de agua domésticos|O|O||D||1
72152802|Servicio de perforación de pozos de aguas geotermales|O|O||D||1
72152900|Servicios de montaje de acero estructural|O|O||D||1
72152901|Servicio de instalación de frentes metálicos de edificios|O|O||D||1
72152902|Servicio de colocación de refuerzos de concreto|O|O||D||1|Servicio de colocación de refuerzo de hormigón
72152903|Servicio de instalación de la parte frontal del ascensor|O|O||D||1
72152904|Servicio de instalación de sistemas de muros metálicos en exteriores|O|O||D||1
72152905|Servicio de trabajos en hierro estructural|O|O||D||1
72152906|Servicio de enrasillado y enlistonado metálicos|O|O||D||1
72152907|Servicio de colocación de armaduras estructurales para concreto prevaciado|O|O||D||1
72152908|Servicio de instalación de conductos de humo|O|O||D||1
72152909|Servicio de instalación de tanques de almacenamiento metálicos|O|O||D||1
72153000|Servicios de vidrios y ventanería|O|O||D||1
72153001|Servicio de instalación de vidriado a prueba de balas|O|O||D||1|Servicio de instalación de vidrio a prueba de balas
72153002|Servicio de instalación y reparación de vidrios en ventanas|O|O||D||1
72153100|Servicios de construcción de facilidades atléticas y recreativas|O|O||D||1
72153101|Servicio de instalación de canchas de bolos|O|O||D||1
72153102|Servicio de construcción de canchas deportivas en interiores|O|O||D||1
72153103|Servicio de construcción de campos de juegos e instalación de equipos|O|O||D||1
72153104|Servicio de construcción e instalación de spas o yacusis|O|O||D||1
72153105|Servicio de construcción de piscinas|O|O||D||1
72153200|Servicios de recubrimiento, impermeabilización protección contra clima y fuego|O|O||D||1
72153201|Servicio de revestimiento en plástico para estructuras de concreto|O|O||D||1
72153202|Servicio de revestimiento para estructuras metálicas|O|O||D||1
72153203|Servicio de control de corrosión|O|O||D||1
72153204|Servicio de impermeabilización|O|O||D||1|Servicio de aplicación de materiales hidrófugos
72153205|Servicio de enmasillado|O|O||D||1|Servicio de sellado
72153206|Servicio de protección ignífuga en edificios|O|O||D||1
72153207|Servicio de alisado de superficies de concreto|O|O||D||1
72153208|Servicio de instalación de tuberías y calderas|O|O||D||1|Servicio de instalación de tuberías y boilers, Servicio de instalación de tuberías y calentadores
72153209|Servicio de impermeabilización|O|O||D||1
72153300|Servicios de mantenimiento e instalación de equipo de estación de servicio|O|O||D||1
72153301|Servicio de instalación de bombas de gasolina|O|O||D||1
72153302|Servicio de instalación de bombas de diesel|O|O||D||1
72153303|Servicio de mantenimiento o reparación de equipos de estaciones de servicio|O|O||D||1
72153400|Servicios de aparejamiento y andamiaje|O|O||D||1
72153401|Servicios de aparejos|O|O||D||1
72153402|Servicios de andamiaje|O|O||D||1
72153500|Servicios de limpieza estructural externa|O|O||D||1
72153501|Servicio de limpieza de exteriores de edificios|O|O||D||1
72153502|Servicio de limpieza con chorro de arena en exteriores de edificios|O|O||D||1
72153503|Servicio de limpieza a vapor en exteriores de edificios|O|O||D||1
72153504|Limpieza con chorro de agua de alta presión|O|O||D||1
72153505|Servicio de limpieza del emplazamiento de la obra|O|O||D||1|Servicio de limpieza del lugar de la obra
72153506|Servicio de limpieza general posconstrucción de edificios nuevos|O|O||D||1
72153507|Servicio para retiro de materiales en el emplazamiento de la construcción|O|O||D||1|Servicio para retiro de materiales en el lugar de la construcción
72153600|Servicios de terminado interior, dotación y remodelación|O|O||D||1
72153601|Servicio de acabado y reparación de tinas|O|O||D||1
72153602|Servicio de instalación y reparación de organizadores de clósets|O|O||D||1
72153603|Servicio de instalación de mostradores|O|O||D||1
72153604|Servicio de instalación de rieles para cortinas|O|O||D||1
72153605|Servicio de remodelación de cocinas y baños|O|O||D||1
72153606|Servicio de instalación de muebles de oficina|O|O||D||1
72153607|Servicio de instalación de azulejos plásticos en la pared|O|O||D||1|Servicio de instalación de loseta vinílica
72153608|Servicio de instalación de cortinas o persianas|O|O||D||1
72153609|Servicio de instalación de aparatos comerciales y domésticos|O|O||D||1
72153610|Servicio de instalación de chimeneas prefabricadas|O|O||D||1
72153611|Servicio de instalación de gabinetes de cocina|O|O||D||1
72153612|Diseño o decoración de interiores|O|O||D||1
72153613|Servicio de alquiler y mantenimiento de mobiliario para oficina|O|O||D||1|Renta de mobiliario para oficina, Servicio de arrendamiento y mantenimiento de mobiliario para oficina
72153700|Servicios de instalación, mantenimiento y reparación de equipos y construcción de parqueaderos|O|O||D||1|Servicios de instalación, mantenimiento y reparación de equipos y construcción de estacionamientos
72153701|Servicio de instalación de equipos en instalaciones de parqueaderos|O|O||D||1|Servicio de instalación de equipos para estacionamientos
72153702|Mantenimiento de parqueaderos|O|O||D||1|Servicio de mantenimiento de estacionamientos
72153900|Servicio de preparación de obras de construcción|O|O||D||1
72153901|Trabajos de apuntalamiento y socalzado|O|O||D||1
72153902|Montaje y amarre en el sitio para casas móviles|O|O||D||1|Instalación y amarre en el sitio para casas móviles
72154000|Servicios de edificios especializados y comercios|O|O||D||1
72154001|Servicio de instalación de antenas|O|O||D||1
72154002|Servicio de instalación de césped artificial|O|O||D||1|Servicio de instalación de pasto artificial
72154003|Servicio de instalación de toldos|O|O||D||1|Servicio de instalación de cubiertas de lona
72154004|Servicio de movimiento de edificios|O|O||D||1|Servicio de transporte de casa móvil
72154005|Servicio de empalme de cables|O|O||D||1
72154006|Servicio de perforación con extracción de testigos y corte|O|O||D||1
72154007|Servicio de achique|O|O||D||1|Servicio de extracción de agua
72154008|Servicio de taladro y aserrado con diamante|O|O||D||1|Servicio de perforación y aserrado con diamante
72154009|Servicios de instalación de dársenas industriales y sus equipos|O|O||D||1|Servicios de instalación de rampas mecánicas para carga y descarga y sus equipos
72154010|Servicio de instalación, mantenimiento y reparación de ascensores|O|O||D||1
72154011|Servicio de aplicación de resina epoxi|O|O||D||1|Servicio de aplicación de poliepóxido
72154012|Servicio de instalación y desmantelamiento de formas de concreto|O|O||D||1|Servicio de montaje y desmontaje de hormigón
72154013|Servicio de construcción de cercas|O|O||D||1|Servicio de construcción de vallas
72154014|Servicio de instalación y mantenimiento de fibra de vidrio|O|O||D||1
72154015|Servicio de instalación de escaleras de emergencia|O|O||D||1
72154016|Servicio de construcción de carrozas (desfile)|O|O||D||1
72154017|Servicio de instalación de equipos para servicio de comida|O|O||D||1
72154018|Servicios de instalación de fuentes|O|O||D||1
72154019|Servicio de detección de fugas de gases|O|O||D||1
72154020|Servicio de instalación de sistemas de gases médicos|O|O||D||1
72154021|Servicio de coloreado de vidrio|O|O||D||1|Servicio de tintado de vidrio
72154022|Servicio de instalación y mantenimiento de equipos hidráulicos|O|O||D||1
72154023|Servicio de instalación de conductores de rayos|O|O||D||1|Servicio de instalación de pararrayos
72154024|Servicio de herrajes y trabajos de metalistería ornamentales|O|O||D||1|Servicio de trabajo de hierro y metal decorativo
72154025|Servicio de bombeo y drenaje de tanques de almacenamiento de petróleo|O|O||D||1
72154026|Servicio de reabastecimiento de pilas de hidrógeno|O|O||D||1
72154027|Servicio de excavación de agujeros para postes|O|O||D||1
72154028|Servicio de instalación y mantenimiento de avisos|O|O||D||1|Servicio de instalación y mantenimiento de espectaculares
72154029|Servicio de instalación y reparación de campanario jack|O|O||D||1|Servicio de instalación y reparación de ornamentos en edificios
72154030|Servicio de instalación y reparación campanas de torre|O|O||D||1|Servicio de instalación y reparación campanarios
72154031|Servicios de soldadura en el sitio|O|O||D||1|Servicios de soldadura a domicilio
72154032|Servicio de instalación y reparación de ventanas, puertas y alambrado|O|O||D||1
72154033|Servicio de construcción, erección y reparación de la utilería o el plató o del decorado teatral|O|O||D||1
72154034|Servicio de instalación de tanques de almacenamiento subterráneos de petróleo|O|O||D||1
72154035|Servicio de reabastecimiento de combustible de centrales nucleares|O|O||D||1
72154036|Servicio de instalación de sistemas centralizados de limpieza por aspirado|O|O||D||1|Servicio de instalación de aspiración central
72154037|Servicio de instalación de cajas fuertes o bóvedas|O|O||D||1
72154038|Instalación de protección de onda aérea para el servicio de salas de computadores|O|O||D||1
72154039|Servicio de entablado de emergencia de edificaciones|O|O||D||1
72154040|Servicio de instalación de líneas de protección subterráneas|O|O||D||1
72154041|Servicio de instalación de sistemas de determinación de objetivos|O|O||D||1
72154042|Servicio de erección de mástiles de bandera|O|O||D||1|Servicio de instalación de mástiles de bandera
72154043|Servicio de fumigación industrial y comercial|O|O||D||1
72154044|Servicio de uso o canalización de agua en madera|O|O||D||1
72154045|Servicio de disminución del nivel de aguas de superficie|O|O||D||1
72154046|Servicio de instalación de escaleras eléctricas|O|O||D||1
72154047|Servicio de mesa elevadora|O|O||D||1
72154048|Servicio de balcones y pasillos exteriores|O|O||D||1
72154049|Servicio de protección solar|O|O||D||1|Servicio de láminas de protección solar
72154050|Servicio de mantenimiento o reparación de carritos de la compra|O|O||D||1|Servicio de mantenimiento o reparación de carritos de autoservicio
72154051|Servicio de reubicación de tumbas|O|O||D||1|Servicio de reubicación de lapidas
72154052|Servicio de renovación  y reparación posdesastre|O|O||D||1
72154053|Servicio de reparación de emisoras|O|O||D||1
72154054|Servicios de carga o eliminación de catalizadores|O|O||D||1
72154055|Servicio de limpieza de tanques|O|O||D||1
72154056|Servicio de mantenimiento o reparación de tanques|O|O||D||1
72154057|Servicio de alquiler de tanques de almacenamiento|O|O||D||1|Servicio de renta de tanques de almacenamiento
72154058|Servicio de prueba de tanques y líneas|O|O||D||1
72154059|Servicios de detección, sellado y reparación de fugas|O|O||D||1
72154060|Servicio de desgasificación|O|O||D||1
72154061|Servicio de filtración de aire|O|O||D||1
72154062|Servicio de fabricación de roscas en caliente|O|O||D||1|Servicio de interconexión en vivo en tuberías
72154063|Servicio de cierre de línea o de taponamiento|O|O||D||1
72154064|Servicio de alquiler de equipos portátiles para iluminación|O|O||D||1|Servicio de renta de equipos portátiles para iluminación
72154065|Mantenimiento de equipos eléctricos de copiado|O|O||D||1
72154066|Mantenimiento general de equipos de oficina|O|O||D||1
72154100|Servicios de mantenimiento y reparación de equipo de sistemas de distribución y acondicionamiento|O|O||D||1
72154101|Servicio de alquiler y mantenimiento de compresores de aire|O|O||D||1|Servicio de renta y mantenimiento de compresores de aire
72154102|Servicio de mantenimiento o reparación de intercambiadores de calor|O|O||D||1
72154103|Servicio de mantenimiento o reparación de bombas rotativas|O|O||D||1
72154104|Servicio de mantenimiento y reparación de cajas de cambios|O|O||D||1|Servicio de mantenimiento y reparación de reductores
72154105|Servicio de mantenimiento y reparación de válvulas de control|O|O||D||1
72154106|Servicio de alquiler y mantenimiento de compresores alternativos|O|O||D||1|Servicio de renta y mantenimiento de compresores alternativos
72154107|Servicio de alquiler y mantenimiento de compresores centrífugos|O|O||D||1|Servicio de renta y mantenimiento de compresores centrífugos
72154108|Servicio de mantenimiento o reparación de bombas alternativas|O|O||D||1
72154109|Servicio de mantenimiento o reparación de bombas centrífugas|O|O||D||1
72154110|Servicio de mantenimiento y reparación de torres de refrigeración con ventilador de aletas|O|O||D||1|Servicio de mantenimiento y reparación de torres de enfriamiento
72154200|Servicios de mantenimiento y reparación de instalación de instrumentación|O|O||D||1
72154201|Servicio de instalación y mantenimiento de instrumentos o medidores|O|O||D||1
72154300|Servicios de mantenimiento y reparación de equipo motivo y generación de energía eléctrica|O|O||D||1
72154301|Servicio de mantenimiento o reparación de equipos de turbina|O|O||D||1
72154302|Servicio de instalación y mantenimiento de motores|O|O||D||1
72154400|Servicios de mantenimiento y fabricación de accesorios para tuberías|O|O||D||1
72154401|Servicios de fabricación de accesorios para tuberías|O|O||D||1
72154402|Servicio de mantenimiento o reparación de accesorios para tuberías|O|O||D||1
72154500|Servicios de mantenimiento e instalación de equipo pesado|O|O||D||1
72154501|Servicio de mantenimiento y reparación de equipo pesado|O|O||D||1
72154502|Servicio de mantenimiento y reparación de grúas|O|O||D||1
72154503|Servicio de alquiler de grúas|O|O||D||1|Servicio de renta de grúas
73101500|Producción petroquímica y de plástico|O|O||D||1
73101501|Servicios de refinación de petróleo|O|O||D||1
73101502|Servicios de producción de gas natural|O|O||D||1
73101503|Servicios de producción de aceites o grasas|O|O||D||1
73101504|Servicios de producción de carbón|O|O||D||1
73101505|Servicios de fabricación de plásticos, resinas o fibras|O|O||D||1
73101600|Producción de químicos y fertilizantes|O|O||D||1
73101601|Servicios de producción de químicos inorgánicos|O|O||D||1
73101602|Servicios de producción de sosa, cloro o soda cáustica|O|O||D||1|Servicios de producción de sosa, cloro o sosa cáustica
73101603|Servicios de producción de ácidos inorgánicos|O|O||D||1
73101604|Servicios de producción de químicos orgánicos|O|O||D||1
73101605|Servicios de producción de acetileno o derivados|O|O||D||1
73101606|Servicios de producción de etileno o derivados|O|O||D||1|Servicios de producción de eteno o derivados
73101607|Servicios de producción de etileno o metanol o derivados|O|O||D||1|Servicios de producción de alcohol etílico o alcohol metanol o derivados
73101608|Servicios de producción de fertilizantes|O|O||D||1
73101609|Servicios de minería o transformación de potasa|O|O||D||1|Servicios de minería o transformación de carbonato de potasio
73101610|Servicios de producción de pesticidas|O|O||D||1|Servicios de producción de plaguicida
73101611|Servicios de producción de pinturas, barnices o lacas|O|O||D||1
73101612|Servicios de producción de jabones o preparaciones para limpieza o perfumes o cosméticos|O|O||D||1
73101613|Servicios de producción de disolventes, glicoles o detergentes|O|O||D||1|Servicios de producción de disolventes, etilenglicoles o detergentes
73101614|Servicios de fermentos o enzimas|O|O||D||1
73101700|Producción farmacéutica|O|O||D||1
73101701|Servicios de producción de medicamentos o medicinas|O|O||D||1
73101702|Servicios de producción de vacunas, sueros o antibióticos|O|O||D||1
73101703|Servicios de producción de productos farmacéuticos|O|O||D||1|Servicios de fabricación de medicamentos homeopáticos
73101800|Producción bioquímica y de biotecnología|O|O||D||1
73101801|Servicios de producción de biomasa|O|O||D||1
73101802|Servicios de producción de bioproteínas|O|O||D||1
73101900|Producción de caucho|O|O||D||1
73101901|Servicios de moledura de caucho|O|O||D||1|Servicios de fresadora de caucho
73101902|Servicios de producción de neumáticos o tubos de caucho|O|O||D||1|Servicios de producción de llantas o tubos de caucho
73101903|Servicios de producción de calzado de caucho o plástico|O|O||D||1|Servicios de reparación y mantenimiento de calzado de caucho o plástico
73111500|Procesamiento de madera|O|O||D||1
73111501|Servicios de aserradero|O|O||D||1
73111502|Servicios de producción de chapas|O|O||D||1
73111503|Servicios de fabricación de paneles de base de madera|O|O||D||1
73111504|Servicios de fabricación de envases de madera|O|O||D||1
73111505|Servicios de fabricación de muebles|O|O||D||1|Reparación de muebles, Servicio de tapicería de muebles
73111506|Servicios de fabricación de productos de corcho|O|O||D||1
73111507|Servicios de elaboración de bejuco o mimbre|O|O||D||1|Servicios de procesamiento de caña o mimbre
73111600|Procesamiento de pulpa y papel|O|O||D||1
73111601|Servicios de producción de pulpa|O|O||D||1
73111602|Servicios de producción de papel o cartón|O|O||D||1
73111603|Servicios de producción de tabla de madera dura o de fibra|O|O||D||1|Servicios de producción de paneles duros o de fibra
73111604|Servicios de producción o reciclaje de papel|O|O||D||1
73121500|Procesos de fundición y refinación y formado de metales|O|O||D||1
73121501|Servicios de producción de aleaciones ferrosas|O|O||D||1
73121502|Servicios de procesos de combinación de metales básicos|O|O||D||1
73121503|Servicios de refracción para la producción de hierro o acero|O|O||D||1
73121504|Servicios de fabricación de hierro o acero|O|O||D||1
73121505|Servicios de forja de  hierro o acero|O|O||D||1
73121506|Servicios de procesos de preacabado de hierro o acero|O|O||D||1
73121507|Servicios de  acabado en la transformación de metales|O|O||D||1
73121508|Servicios de fundición de metales|O|O||D||1
73121509|Servicios de purificación de metales|O|O||D||1|Servicios de refinación de metales
73121600|Terminación de metales|O|O||D||1
73121601|Servicios de corte de metales|O|O||D||1
73121602|Servicios de herrería|O|O||D||1|Servicio de fragua
73121603|Servicios de calentamiento de metales|O|O||D||1
73121606|Servicios de forja de metales|O|O||D||1
73121607|Servicios de extracción de metales|O|O||D||1
73121608|Servicios de extrusión de metales|O|O||D||1
73121610|Servicios de herrería|O|O||D||1|Servicios de herraduras
73121611|Servicios de hojalatería|O|O||D||1
73121612|Servicios de revestimiento con metal antifricción|O|O||D||1
73121613|Servicios de fundición de metales|O|O||D||1
73121614|Servicios de pruebas no destructivas|O|O||D||1
73121800|Servicios de industria de productos de minerales no metálicos|O|O||D||1
73121801|Servicios de fabricación de cerámica o porcelana o loza de barro|O|O||D||1
73121802|Servicios de fabricación vidrio o productos de vidrio|O|O||D||1
73121803|Servicios de fabricación de productos de arcilla estructural|O|O||D||1
73121804|Servicios de fabricación de cemento o cal o yeso|O|O||D||1
73121805|Servicios de fabricación de productos de concreto o agregados o piedra|O|O||D||1|Servicio de fabricación de ladrillos
73121806|Servicios de fabricación de abrasivos|O|O||D||1
73121807|Servicios de fabricación de productos de asbesto|O|O||D||1
73131500|Procesamiento de bebidas|O|O||D||1
73131501|Servicios de destilación o mezcla de licores|O|O||D||1
73131502|Servicios de elaboración del vino|O|O||D||1
73131503|Servicios de elaboración de la cerveza|O|O||D||1
73131504|Servicios de elaboración de bebidas de frutas no alcohólicas|O|O||D||1|Servicios de elaboración de bebidas sin alcohol a base de frutas
73131505|Servicios de elaboración de bebidas de agua|O|O||D||1
73131506|Servicios de elaboración de bebidas de infusión|O|O||D||1
73131507|Servicios de elaboración del café|O|O||D||1
73131508|Servicios de elaboración del té|O|O||D||1
73131600|Procesamiento de carnes y aves y peces y mariscos|O|O||D||1
73131601|Servicios de elaboración de productos cárnicos o derivados|O|O||D||1
73131602|Servicios de procesamiento de pescado o productos de pescado|O|O||D||1
73131603|Servicios de procesamiento de aves de corral|O|O||D||1
73131604|Servicios de inspección o higiene de la carne|O|O||D||1
73131605|Servicios de operación o administración de plantas cárnicas|O|O||D||1|Servicios de operación o gestión de plantas cárnicas
73131606|Servicios de matadero|O|O||D||1
73131607|Servicios de carnicería|O|O||D||1
73131608|Servicios de conservación en cámara frigorífica|O|O||D||1
73131700|Procesamiento de frutas y vegetales|O|O||D||1
73131701|Servicios de limpieza de frutas o verduras|O|O||D||1
73131702|Servicios de rociado de frutas o verduras|O|O||D||1
73131703|Servicios de empaque de frutas o verduras|O|O||D||1
73131800|Procesamiento de lácteos y huevos|O|O||D||1
73131801|Servicios de elaboración de la leche|O|O||D||1|Servicios de procesamiento de la leche
73131802|Servicios de la elaboración  de huevos|O|O||D||1|Servicios de procesamiento de huevos
73131803|Servicios de elaboración de quesos|O|O||D||1|Servicios de procesamiento de quesos
73131804|Servicios de elaboración de mantequilla o crema de leche|O|O||D||1
73131900|Procesamiento de granos y azúcar y aceites y grasas|O|O||D||1
73131902|Servicios de elaboración de productos a base de cereal|O|O||D||1|Servicios de procesamiento de productos a base de cereal
73131903|Servicios de elaboración de azúcar o productos de azúcar|O|O||D||1|Servicios de procesamiento de azúcar o productos de azúcar
73131904|Servicios de elaboración de aceites o grasas vegetales|O|O||D||1|Servicios de procesamiento de aceites o grasas vegetales
73131905|Servicios de elaboración de especias|O|O||D||1|Servicios de procesamiento de especias
73131906|Servicios de elaboración de productos de panadería|O|O||D||1|Servicios de procesamiento de productos de panadería
73141500|Producción de fibra|O|O||D||1
73141501|Servicios de fabricación de fibra de rayón o acetato|O|O||D||1
73141502|Servicios de fabricación de fibra de vidrio|O|O||D||1
73141503|Servicios de fabricación de fibra de seda|O|O||D||1
73141504|Servicios de fabricación de fibra de algodón|O|O||D||1
73141505|Servicios de fabricación de fibra de lana|O|O||D||1
73141506|Servicios de fabricación de fibra de poliéster|O|O||D||1
73141507|Servicios de fabricación de fibra de poliamida|O|O||D||1
73141508|Servicios de fabricación de fibra acrílica|O|O||D||1
73141600|Procesamiento de hebras e hilos|O|O||D||1
73141601|Servicios de elaboración de hilo|O|O||D||1|Servicios de procesamiento de hilo
73141602|Servicios de elaboración de hilado|O|O||D||1|Servicios de procesamiento de hilado
73141700|Producción de telas y cuero|O|O||D||1
73141701|Servicios de fabricación de géneros de tejido ancho|O|O||D||1|Servicios de fabricación de telas de tejido ancho
73141702|Servicios de fabricación de géneros de tejido angosto|O|O||D||1|Servicios de fabricación de telas de tejido angosto
73141703|Servicios de fabricación de tejidos de punto|O|O||D||1
73141704|Servicios de fabricación de tapetes o alfombras|O|O||D||1
73141705|Servicios de fabricación de sogas, cuerdas o cordeles|O|O||D||1
73141706|Servicios de teñido o impresión y acabado|O|O||D||1
73141707|Servicios de fabricación de   trajes o chaquetas o abrigos tejidos|O|O||D||1
73141708|Servicios de fabricación de prendas exteriores tejidas|O|O||D||1
73141709|Servicios de curtido o teñido de pieles|O|O||D||1
73141710|Servicios de fabricación de calzado de cuero|O|O||D||1|Servicios de reparación y mantenimiento de calzado de cuero
73141711|Servicios de fabricación de maletas o bolsos de cuero|O|O||D||1|Servicios de reparación y mantenimiento de maletas o bolsos de cuero
73141712|Servicios de fabricación de curtidos o acabados de cuero|O|O||D||1
73141713|Servicios de géneros telas no tejidas|O|O||D||1|Servicios de telas no tejidas
73141714|Servicios de hilo o tejido trenzado|O|O||D||1
73141715|Servicios de costura industrial|O|O||D||1
73151500|Servicios de ensamble|O|O||D||1|Servicios de maquila
73151501|Servicios de cadena de montaje|O|O||D||1|Servicios de línea de montaje
73151502|Servicios de sellamiento de uniones|O|O||D||1
73151503|Servicio de fabricación y diseños originales|O|O||D||1
73151504|Servicio de fabricación de productos electrónicos|O|O||D||1
73151505|Servicio de entrega en secuencia|O|O||D||1
73151506|Servicio de subensamble o ensamble definitivo|O|O||D||1
73151600|Servicios de empaque|O|O||D||1
73151601|Servicios de plantas de conservas|O|O||D||1
73151602|Servicios de empacado de subproductos agrícolas|O|O||D||1
73151603|Servicios de empacado de productos no alimenticios|O|O||D||1
73151604|Servicios de empacado de productos farmacéuticos|O|O||D||1
73151605|Servicios de empacado para exhibición en el punto de venta|O|O||D||1
73151606|Servicios de empacado a mano|O|O||D||1
73151607|Servicios de empacado mecanizado|O|O||D||1|Servicios de embalaje asistido por máquina
73151608|Servicio de empaque en estuche|O|O||D||1
73151700|Tratamiento de materiales|O|O||D||1
73151701|Servicios de tratamiento de materiales  de impermeabilización|O|O||D||1
73151702|Servicios de tratamiento de materiales de protección contra incendios|O|O||D||1
73151703|Servicios de tratamiento de materiales  anticorrosivos|O|O||D||1
73151704|Servicio de anodización del aluminio|O|O||D||1
73151705|Servicio de acabado para el tratamiento de materiales anodizados|O|O||D||1
73151800|Servicios de conversión|O|O||D||1
73151801|Servicios de enchapes|O|O||D||1|Servicios de laminado
73151802|Servicios de corte en tiras|O|O||D||1
73151803|Servicios de corte a troquel|O|O||D||1
73151804|Servicios de plegado|O|O||D||1
73151805|Servicios de laminación|O|O||D||1
73151900|Servicios a la industria de impresión|O|O||D||1
73151901|Servicios de impresión industrial flexográfica|O|O||D||1|Servicios de impresión industrial con placa flexible con relieve
73151902|Servicios de impresión industrial a roto grabado|O|O||D||1
73151903|Servicios de impresión industrial  a pantalla|O|O||D||1
73151904|Servicios de impresión industrial offset|O|O||D||1
73151905|Servicios de impresión industrial digital|O|O||D||1
73151906|Servicios de impresión industrial de transferencia térmica|O|O||D||1
73151907|Servicios de impresión y duplicación de discos compactos dc|O|O||D||1
73152000|Servicios de llenado|O|O||D||1
73152001|Servicios de llenado con líquido|O|O||D||1|Servicios de llenado de líquido
73152002|Servicios de llenado con aerosol|O|O||D||1|Servicios de llenado de aerosol
73152003|Servicios de llenado con pasta|O|O||D||1|Servicios de llenado de pasta
73152004|Servicios de llenado con  polvo|O|O||D||1|Servicios de llenado de polvo
73152100|Servicios de mantenimiento y reparación de equipo de manufactura|O|O||D||1
73152101|Servicio de mantenimiento de equipo industrial|O|O||D||1
73152102|Servicio de reparación de equipo industrial|O|O||D||1
73152103|Servicios de mantenimiento de equipos de ingeniería|O|O||D||1
73152104|Servicio de mantenimiento y reparación de equipos para empacar|O|O||D||1|Servicio de mantenimiento y reparación de equipos de embalaje
73152105|Refacción de equipos de pruebas|O|O||D||1|Restauración de equipos de pruebas
73152106|Servicio de mantenimiento y reparación de equipos para calentar y hornear|O|O||D||1
73152107|Servicio de reconstrucción y refacción de equipos maquinados|O|O||D||1|Servicio de reconstrucción y restauración de equipos maquinados
73152108|Servicio de mantenimiento y reparación de equipos eléctricos|O|O||D||1
73152109|Servicios de mantenimiento y alquiler de básculas industriales|O|O||D||1|Servicios de mantenimiento y renta de básculas industriales
73152112|Servicio de prueba, mantenimiento o reparación de válvulas o partes de válvulas|O|O||D||1
73161500|Manufactura de maquinaria|O|O||D||1|Maquila de maquinaria
73161501|Servicios de fabricación de motores o  turbinas|O|O||D||1
73161502|Servicios de fabricación de maquinaria o equipos agrícolas|O|O||D||1
73161503|Servicios de fabricación de máquinas herramienta, labrado de metales o madera|O|O||D||1
73161504|Servicios de fabricación de maquinaria o plantas industriales especiales|O|O||D||1
73161505|Servicios de fabricación de maquinaria o equipos para construcción|O|O||D||1
73161506|Servicios de fabricación de maquinaria o equipos para minería|O|O||D||1
73161507|Servicios de fabricación de maquinaria o equipo para productos alimenticios|O|O||D||1
73161508|Servicios de fabricación de maquinaria o equipos para impresión de papel|O|O||D||1
73161509|Servicios de fabricación de maquinaria o equipos metalúrgicos|O|O||D||1
73161510|Servicios de fabricación de maquinaria o equipos para productos químicos o farmacéuticos|O|O||D||1
73161511|Servicios de fabricación de maquinaria o equipo para fábricas de cemento|O|O||D||1|Servicios de fabricación de maquinaria o equipo para plantas de cemento
73161512|Servicios de fabricación de maquinaria o equipo textil|O|O||D||1
73161513|Servicios de fabricación de calderas para centrales eléctricas|O|O||D||1|Servicios de fabricación de boilers para centrales eléctricas
73161514|Servicios de fabricación de hornos|O|O||D||1
73161515|Servicios de fabricación de maquinaria o equipo de oficina|O|O||D||1
73161516|Servicios de fabricación de equipo de elevación, elevación o transporte|O|O||D||1
73161517|Servicios de fabricación de equipos de aire acondicionado, ventilación o refrigeración|O|O||D||1
73161518|Servicios de fabricación de electrodomésticos o máquinas de uso doméstico excepto eléctricas|O|O||D||1
73161519|Servicios de fabricación de bombas o compresores|O|O||D||1
73161600|Manufactura de equipo de transporte|O|O||D||1|Maquila de equipo de transporte
73161601|Servicios de construcción de barcos o botes de pesca|O|O||D||1
73161602|Servicios de fabricación de material rodante para ferrocarriles|O|O||D||1|Servicios de fabricación de material rodante ferroviario
73161603|Servicios de fabricación de locomotoras|O|O||D||1
73161604|Servicios de fabricación de vehículos de motor|O|O||D||1
73161605|Servicios de fabricación de partes y accesorios de vehículos de motor|O|O||D||1
73161606|Servicios de fabricación de motocicletas o bicicletas|O|O||D||1
73161607|Servicios de fabricación de aeronaves o naves espaciales|O|O||D||1
73171500|Manufactura de bienes eléctricos|O|O||D||1|Maquila de bienes eléctricos
73171501|Servicios de fabricación de equipo de generación, transmisión o distribución de energía|O|O||D||1
73171502|Servicios de fabricación de pilas secas o acumuladores|O|O||D||1|Servicios de fabricación de baterías secas o acumuladores
73171503|Servicios de fabricación de herramientas eléctricas|O|O||D||1
73171504|Servicios de fabricación de instrumentos de pruebas o de mediciones|O|O||D||1
73171505|Servicios de fabricación de aparatos de radio o televisión|O|O||D||1
73171506|Servicios de fabricación de equipos de comunicaciones|O|O||D||1
73171507|Servicios de fabricación de aparatos electrodomésticos|O|O||D||1
73171508|Servicios de fabricación de alambre o cable aislado|O|O||D||1
73171510|Servicios de fabricación de accesorios o material eléctricos|O|O||D||1
73171511|Servicios de fabricación de equipos electrónicos|O|O||D||1
73171512|Servicios de fabricación de computadores electrónicos o equipos de procesamiento de datos|O|O||D||1
73171513|Servicios epitaxiales|O|O||D||1
73171600|Manufactura de instrumentos de precisión|O|O||D||1|Maquila de instrumentos de precisión
73171601|Servicios de fabricación de instrumentos científicos o equipos de medición|O|O||D||1
73171602|Servicios de fabricación de equipo médico o dental|O|O||D||1
73171603|Servicios de fabricación de equipo óptico o fotográfico|O|O||D||1
73171604|Servicios de fabricación de relojes o relojes de pulsera|O|O||D||1
73171605|Servicios de fabricación de equipos de laboratorio|O|O||D||1
73171606|Servicios de actualización de equipos de pruebas|O|O||D||1
73181000|Servicios de maquinado|O|O||D||1
73181001|Servicios de tornería|O|O||D||1|Servicios de torneado
73181002|Servicios de maquinado por electrodescarga edm|O|O||D||1
73181003|Servicios de maquinado electroquímico ecm|O|O||D||1
73181004|Servicios de fresado químico|O|O||D||1
73181005|Servicios de troquelado|O|O||D||1
73181006|Servicios de estampación|O|O||D||1
73181007|Servicios de taladrado|O|O||D||1
73181008|Servicios de perforación|O|O||D||1
73181009|Servicios de tarraja con macho|O|O||D||1
73181010|Servicios de láser|O|O||D||1
73181011|Servicios de doblado|O|O||D||1
73181012|Servicios de fresado|O|O||D||1|Servicios de molienda
73181013|Servicios de limpieza con chorro de perdigones|O|O||D||1|Servicios de limpieza con agua a presión
73181014|Servicios de pulida|O|O||D||1|Servicio de encerado, Servicio de lustrado
73181015|Servicios de corte con llama de gas|O|O||D||1|Servicio de oxicorte
73181016|Servicios de corte con láser|O|O||D||1
73181017|Servicios de corte con plasma|O|O||D||1
73181018|Servicios de corte con chorro de agua|O|O||D||1|Servicios de corte con presión de agua
73181019|Servicios de rodamiento|O|O||D||1|Servicios de rolado
73181020|Servicios de tratamiento de superficies|O|O||D||1
73181021|Servicios de fresado|O|O||D||1
73181022|Servicios de  pulverización|O|O||D||1|Servicios de pulverización de metales
73181023|Servicio de afilado|O|O||D||1
73181100|Servicios de revestimiento|O|O||D||1
73181101|Servicios de electro revestimiento|O|O||D||1
73181102|Servicios de bañado|O|O||D||1|Servicios de pintado por inmersión de agua
73181103|Servicios de envoltura|O|O||D||1
73181104|Servicios de pintura|O|O||D||1
73181105|Servicios de recubrimiento rollo a rollo (web)|O|O||D||1
73181106|Servicios de enchapado|O|O||D||1|Servicios de enchapado de metales
73181107|Servicio de enchapado con barril de aleación de cinc|O|O||D||1
73181108|Servicio de enchapado con estaño|O|O||D||1
73181109|Servicio de niquelado|O|O||D||1
73181110|Servicio de niquelado químico|O|O||D||1
73181111|Servicio de enchapado con metales preciosos|O|O||D||1
73181112|Servicio de recubrimiento con teflón|O|O||D||1
73181113|Servicio de recubrimiento orgánico con aluminio de cinc|O|O||D||1
73181114|Servicio de electro recubrimiento con barril|O|O||D||1
73181115|Servicio de cromoniquelado|O|O||D||1
73181116|Servicio de cromado denso delgado|O|O||D||1
73181117|Servicio de recubrimiento con soplete|O|O||D||1
73181118|Servicio de electrorecubrimiento en  estantería|O|O||D||1|Servicio de recubrimiento eléctrico
73181119|Servicio de recubrimiento con pintura en polvo|O|O||D||1
73181120|Servicio de enchapado en barril de cinc|O|O||D||1|Servicio de galvanizado
73181121|Servicio de enchapado en estantería con aleación de cinc|O|O||D||1|Servicio de galvanoplastia de aleación de zinc
73181122|Servicio de recubrimiento en estantería de cinc con barniz|O|O||D||1
73181123|Servicio de recubrimiento en barril de cinc con barniz|O|O||D||1
73181124|Servicio de recubrimiento de fosfato|O|O||D||1
73181125|Servicio de recubrimiento tipo diamante|O|O||D||1
73181200|Servicios de formado|O|O||D||1
73181201|Servicios de  formación por extracción|O|O||D||1|Servicios de conformado en frío
73181202|Servicios de hidro conformado|O|O||D||1
73181203|Servicios de conformación por enrollado|O|O||D||1|Servicios de maquina de perfiladora
73181204|Servicios de conformación  por estirado|O|O||D||1
73181205|Servicios de conformación porgiro|O|O||D||1
73181206|Servicios de formación con explosivos|O|O||D||1|Servicios de hidroconformado por explosión
73181300|Servicios de tratamiento de calor|O|O||D||1
73181301|servicios de temple y enfriamiento|O|O||D||1
73181302|Servicios de recocido|O|O||D||1
73181303|Servicios de normalización|O|O||D||1
73181304|Servicios de  envejecimiento o estabilización|O|O||D||1
73181305|Servicio de tratamiento térmico de latón|O|O||D||1
73181306|Servicio de tratamiento térmico de temple y enfriamiento|O|O||D||1
73181307|Servicio de tratamiento térmico de endurecimiento por precipitación|O|O||D||1
73181308|Servicio de tratamiento térmico de carbonitruro|O|O||D||1
73181309|Servicio de tratamiento térmico de nitruro|O|O||D||1
73181310|Servicio de tratamiento térmico de temple y enfriamiento al vacío|O|O||D||1
73181311|Servicio de tratamiento térmico de recocido al vacío|O|O||D||1
73181312|Servicio de tratamiento térmico carburante|O|O||D||1
73181313|Servicio de tratamiento térmico de inducción|O|O||D||1
73181314|Servicio de tratamiento térmico austempering|O|O||D||1
73181900|Servicios de soldadura|O|O||D||1
73181901|Servicios de soldadura de arco|O|O||D||1|Servicios de soldadura de electrógena
73181902|Servicios de soldadura con gas metal inerte mig|O|O||D||1|Servicios de soldadura a gas y arco metálico
73181903|Servicios de soldadura con tungsteno a gas inerte (tig)|O|O||D||1|Servicios de soldadura de gas inerte tungsteno
73181904|Servicios de soldadura con láser|O|O||D||1
73181905|Servicios de soldadura  por puntos|O|O||D||1
73181906|Servicios de soldadura con proyección|O|O||D||1
73181907|Servicios de soldadura fuerte con latón|O|O||D||1
73181908|Servicios de soldadura|O|O||D||1
76101500|Desinfección|O|O||D||1
76101501|Servicios de higienización de lavabos|O|O||D||1|Servicios de sanitización de baños
76101502|Servicios de limpieza de baños|O|O||D||1
76101503|Servicios de desinfección o desodorización|O|O||D||1|Servicios de esterilización o desodorización
76101600|Descontaminación de materiales peligrosos|O|O||D||1
76101601|Servicios de descontaminación radiactiva|O|O||D||1
76101602|Encapsulación  o eliminación de asbesto|O|O||D||1|Encapsulación  o eliminación de amianto
76101603|Encapsulación o reducción/eliminación de pintura con plomo|O|O||D||1
76101604|Servicio de reducción/eliminación de moho|O|O||D||1
76101605|Servicio de filtración y descontaminación a base de carbono|O|O||D||1
76101606|Servicio de limpieza de equipos a base de químicos|O|O||D||1
76111500|Servicios de limpieza y mantenimiento de edificios generales y de oficinas|O|O||D||1
76111501|Servicios de limpieza de edificios|O|O||D||1|Servicios de aseo de edificios
76111503|Servicios de mantenimiento del alumbrado|O|O||D||1|Servicios de mantenimiento de iluminación
76111504|Servicios de limpieza de ventanas o persianas|O|O||D||1
76111505|Servicios de limpieza de telas y muebles|O|O||D||1|Servicios de lavado de telas y muebles
76111506|Servicios de paisajismo de plantas interiores|O|O||D||1
76111600|Servicios de limpieza de componentes de edificios|O|O||D||1
76111601|Servicios de limpieza de baldosas o cielorraso acústicos|O|O||D||1|Servicios de limpieza de azulejos o techos falsos
76111602|Limpieza de conductos de aire|O|O||D||1|Lavado de conductos de aire
76111603|Limpieza de chimeneas|O|O||D||1|Lavado de chimeneas
76111604|Encerado de pisos y limpieza de tapetes|O|O||D||1|Pulido de pisos y limpieza de alfombras
76111605|Limpieza de campanas o ventiladores extractores de humo|O|O||D||1
76111800|Limpieza de vehículos de transporte|O|O||D||1
76111801|Limpieza de carros o barcos|O|O||D||1|Lavado de carros o barcos, Servicio de autolavado
76121500|Recolección y disposición de basuras|O|O||D||1
76121501|Recolección o destrucción o transformación o eliminación de basuras|O|O||D||1
76121502|Recolección o transformación o eliminación de residuos líquidos|O|O||D||1
76121503|Servicios de limpieza de calles|O|O||D||1|Servicios de barrido de calles
76121600|Disposición de desechos no peligrosos|O|O||D||1
76121601|Vertedero de basuras|O|O||D||1|Basurero
76121602|Operaciones de relleno sanitario|O|O||D||1
76121603|Eliminación de fangos cloacales|O|O||D||1
76121604|Servicios de disposición de animales muertos|O|O||D||1|Servicios de eliminación de animales muertos
76121700|Tratamiento de desechos líquidos|O|O||D||1
76121701|Servicios de tratamiento de aguas negras|O|O||D||1|Servicios de tratamiento de aguas residuales
76121702|Servicios de tratamiento químico|O|O||D||1
76121900|Disposición de desechos peligrosos|O|O||D||1
76121901|Eliminación de residuos médicos|O|O||D||1
76121902|Recolección o eliminación de residuos ácidos|O|O||D||1
76121903|Destoxificación química|O|O||D||1|Desintoxicación química
76121904|Eliminación aguas residuales peligrosas|O|O||D||1
76122000|Servicios de basurero|O|O||D||1
76122001|Relleno sanitario para residuos genéricos no peligrosos|O|O||D||1
76122002|Relleno sanitario para residuos especiales no peligrosos|O|O||D||1
76122003|Relleno sanitario para residuos peligrosos|O|O||D||1
76122004|Relleno sanitario para residuos universales o peligrosos de bajo riesgo|O|O||D||1
76122100|Servicios de mezcla de desechos a combustible|O|O||D||1
76122101|Mezcla de combustibles para residuos genéricos no peligrosos|O|O||D||1
76122102|Mezcla de combustible para residuos especiales no peligrosos|O|O||D||1
76122103|Mezcla de combustibles para residuos peligrosos|O|O||D||1
76122200|Servicios de incineración de desechos|O|O||D||1
76122201|Incineración para residuos genéricos no peligrosos|O|O||D||1
76122202|Incineración para residuos especiales no peligrosos|O|O||D||1
76122203|Incineración para residuos peligrosos|O|O||D||1
76122300|Servicios de reciclables|O|O||D||1
76122301|Reciclaje de disolventes|O|O||D||1|Reciclaje de solventes
76122302|Reciclaje de aceite usado|O|O||D||1
76122303|Reciclaje de trapos para limpiar|O|O||D||1
76122304|Reciclaje de residuos peligrosos|O|O||D||1
76122305|Reciclaje de productos basados en computadores|O|O||D||1
76122306|Reciclaje de papel|O|O||D||1
76122307|Reciclaje de cartón|O|O||D||1
76122308|Reciclaje de madera|O|O||D||1
76122309|Reciclaje de plástico|O|O||D||1
76122310|Reciclaje de metal|O|O||D||1
76122311|Reciclaje de vidrio|O|O||D||1
76122312|Reciclaje de icopor|O|O||D||1|Reciclaje de espuma de poliestireno EPS, Reciclaje de poliestireno expandido EPS, Reciclaje de unice
76122313|Reciclaje de vinilo|O|O||D||1
76122314|Reciclaje de lámparas fluorescentes|O|O||D||1
76122315|Reciclaje de balastros para lámparas|O|O||D||1
76122400|Honorarios de disposición y tratamiento de basuras|O|O||D||1|Servicios de disposición y tratamiento de basuras
76122401|Tarifa de sobreestadía|O|O||D||1|Costo por demora, Tarifa por demora
76122402|Tarifa de uso de equipos|O|O||D||1|Costo de uso de equipos
76122403|Tarifa de recuperación de combustible|O|O||D||1|Costo de recuperación de combustible
76122404|Tarifa de residuos peligrosos|O|O||D||1|Costo de residuos peligrosos
76122405|Tarifa de mano de obra|O|O||D||1|Costo de mano de obra
76122406|Tarifa de equipo de protección personal|O|O||D||1|Costo de equipo de protección personal
76122407|Tarifa de transporte de basura|O|O||D||1|Costo de transporte de basura
76122408|Tarifa estatal, departamental o local de residuos o reciclaje|O|O||D||1|Costo estatal, departamental o local de residuos o reciclaje
76131500|Tratamiento de basura nuclear|O|O||D||1
76131501|tratamiento de desechos radioactivos|O|O||D||1|Tratamiento de residuos radiactivos
76131502|Servicios de confinación de material  radioactivo|O|O||D||1
76131600|Limpieza de derrames tóxicos|O|O||D||1
76131601|Confinación de vertidos tóxicos|O|O||D||1
76131602|Limpieza total de derramamiento de sustancias tóxicas|O|O||D||1
76131700|Limpieza de derrames de petróleo|O|O||D||1
76131701|Servicios de eliminación o control de residuos petroleros|O|O||D||1
76131702|Servicios de tratamiento de derramamiento  de petróleo|O|O||D||1
77101500|Evaluación de impacto ambiental|O|O||D||1
77101501|Evaluación riesgos o peligros|O|O||D||1
77101502|Estándares ambientales|O|O||D||1
77101503|Análisis de indicadores ambientales|O|O||D||1
77101504|Servicios de evaluación de impacto ambiental (eia)|O|O||D||1
77101505|Monitoreo ambiental|O|O||D||1|Vigilancia ambiental
77101600|Planeación ambiental|O|O||D||1
77101601|Planificación del desarrollo ambiental urbano|O|O||D||1
77101602|Planificación de la estrategia de conservación forestal|O|O||D||1
77101603|Planificación de la estrategia de conservación marítima|O|O||D||1|Planificación de la estrategia de conservación marina
77101604|Servicios de planificación de la estrategia de gestión o conservación de recursos naturales|O|O||D||1
77101605|Creación o planificación de instituciones ambientales|O|O||D||1
77101700|Servicios de asesoría ambiental|O|O||D||1|Servicios de consultoría ambiental
77101701|Servicios de asesoramiento sobre ciencias ambientales|O|O||D||1|Servicios de consultoría sobre ciencias ambientales
77101702|Servicios de asesoramiento sobre química ambiental|O|O||D||1|Servicios de consultoría sobre química ambiental
77101703|Servicios de asesoramiento sobre ética ambiental|O|O||D||1|Servicios de consultoría sobre ética ambiental
77101704|Servicios de asesoramiento sobre tecnología ambiental|O|O||D||1|Servicios de consultoría sobre tecnología ambiental
77101705|Servicios de  asesoramiento sobre economía ambiental|O|O||D||1|Servicios de consultoría sobre economía ambiental
77101706|Servicios de asesoramiento sobre derecho ambiental|O|O||D||1|Servicios de consultoría sobre derecho ambiental
77101707|Servicios de asesoramiento sobre ecología|O|O||D||1|Servicios de consultoría sobre ecología
77101800|Auditoría ambiental|O|O||D||1
77101801|Sistemas de información ambiental|O|O||D||1
77101802|Servicios de auditoria ambiental de empresas|O|O||D||1
77101803|Servicios de auditoria ambiental sectoriales|O|O||D||1
77101804|Servicios de auditoria ambiental de actividades específicas|O|O||D||1
77101805|Servicios de control de la calidad ambiental|O|O||D||1
77101806|Servicios de control de seguridad ambiental|O|O||D||1
77101900|Servicios de investigación de contaminación|O|O||D||1
77101901|Estudio de emplazamientos industriales|O|O||D||1|Investigación de emplazamientos industriales
77101902|Estudio de vertederos de desechos industriales|O|O||D||1|Investigación de vertederos de desechos industriales
77101903|Estudio de emplazamientos de fábricas de gas|O|O||D||1|Investigación de emplazamientos de fábricas de gas
77101904|Estudios de emplazamientos  de vertederos de desechos de fábricas de productos químicos o refinerías de petróleo|O|O||D||1|Investigación de emplazamientos  de vertederos de desechos de fábricas de productos químicos o refinerías de petróleo
77101905|Estudio de emplazamientos de plantas de tratamiento  de la madera|O|O||D||1|Investigación de emplazamientos de plantas de tratamiento  de la madera
77101906|Estudios de emplazamientos de depósitos o terminales de petroleros|O|O||D||1|Investigación de emplazamientos de depósitos o terminales de petroleros
77101907|Estudio de emplazamientos de plantas de limpieza en seco|O|O||D||1|Investigación de emplazamientos de plantas de limpieza en seco
77101908|Estudio de emplazamientos de fundición|O|O||D||1|Investigación de emplazamientos de fundición
77101909|Estudios de emplazamientos de planta de reciclado|O|O||D||1|Investigación de emplazamientos de planta de reciclado
77101910|Estudio de plantas de transformación de alimentos en el sitio|O|O||D||1|Investigación de plantas de transformación de alimentos en el sitio
77102000|Servicios de reporte ambiental|O|O||D||1
77102001|Servicio de certificación de cumplimiento de requisitos legales|O|O||D||1
77102002|Servicio de cumplimiento de presentación de informes sobre emisiones|O|O||D||1
77102003|Servicio de presentación de informes sobre accidentes o de cumplimiento de normas de seguridad|O|O||D||1
77102004|Servicio de presentación de informes sobre generación o eliminación de residuos|O|O||D||1
77111500|Servicios de seguridad ambiental|O|O||D||1
77111501|Servicios de protección del paisaje|O|O||D||1
77111502|Servicios de protección de la capa de ozono|O|O||D||1
77111503|Servicios de protección contra la contaminación de alimentos o pienso|O|O||D||1|Servicios de protección contra la contaminación de alimentos o comida
77111504|Servicios de protección recursos genéticos|O|O||D||1
77111505|Servicios de protección de sustancias tóxicas|O|O||D||1
77111506|Servicios de protección contra la radiación|O|O||D||1
77111507|Servicios de protección de las especies en peligro de extinción|O|O||D||1
77111508|Servicios de protección contra riesgos o peligros naturales|O|O||D||1
77111600|Rehabilitación ambiental|O|O||D||1
77111601|Rehabilitación en emplazamientos industriales|O|O||D||1|Restauración en emplazamientos industriales
77111602|Servicios de descontaminación ambiental|O|O||D||1
77111603|Servicios de recuperación de tierras|O|O||D||1|Servicios de restitución de tierras
77121500|Contaminación del aire|O|O||D||1
77121501|Gestión de la calidad del aire|O|O||D||1
77121502|Servicios transfronterizos de gestión o control de la contaminación del aire|O|O||D||1
77121503|Servicios de protección contra la contaminación del aire|O|O||D||1|Servicios de centros de verificación vehicular
77121504|Servicios de monitoreo o medición de la contaminación del aire|O|O||D||1|Servicios de vigilancia o medición de la contaminación del aire
77121505|Servicios de detección de gases tóxicos|O|O||D||1
77121506|Control del metano|O|O||D||1
77121507|Servicios de monitoreo del dióxido de carbono|O|O||D||1|Servicios de monitoreo del bióxido de carbono
77121508|Monitoreo de partículas en el aire|O|O||D||1
77121509|Servicios de monitoreo de la reducción de la capa de ozono|O|O||D||1|Servicios de vigilancia de la reducción de la capa de ozono
77121600|Contaminación del suelo|O|O||D||1
77121601|Servicios de protección contra la contaminación del suelo|O|O||D||1
77121602|Servicios de eliminación de suelos contaminados|O|O||D||1|Servicios de eliminación de tierras contaminadas
77121603|Tratamiento o rehabilitación de suelos contaminados|O|O||D||1|Tratamiento o restauración de suelos contaminados
77121604|Servicios de asesorías sobre la contaminación del suelo|O|O||D||1|Servicios de consultoría sobre la contaminación del suelo
77121605|Cartografía de la contaminación del suelo|O|O||D||1
77121606|Medición o monitoreo de la contaminación del suelo|O|O||D||1
77121607|Evaluación de la contaminación por fertilizantes orgánicos|O|O||D||1
77121608|Evaluación de la contaminación por pesticidas|O|O||D||1
77121609|Evaluación de la contaminación por nitratos|O|O||D||1
77121610|Evaluación de la contaminación por fosfatos|O|O||D||1
77121700|Contaminación del agua|O|O||D||1
77121701|Servicio de monitoreo o control de la contaminación de las aguas de superficie|O|O||D||1|Servicio de vigilancia o control de la contaminación de las aguas de superficie
77121702|Servicios de rehabilitación de las aguas de superficie|O|O||D||1|Servicios de rehabilitación de aguas superficiales contaminadas
77121703|Servicios de protección contra la polución de las aguas de superficie|O|O||D||1|Servicios de protección de las aguas de superficiales contra la contaminación
77121704|Servicios de tratamiento de las aguas de superficie|O|O||D||1
77121705|Servicios de drenaje de la contaminación de las aguas de superficie|O|O||D||1
77121706|Servicios transfronterizos de gestión o control de la contaminación de las agua|O|O||D||1
77121707|Servicios de monitoreo o control de la contaminación de las aguas subterráneas|O|O||D||1|Servicios de vigilancia o control de la contaminación de las aguas subterráneas
77121708|Servicios de drenaje de la contaminación de las aguas subterráneas|O|O||D||1
77121709|Tratamiento o rehabilitación de la contaminación de las aguas subterráneas|O|O||D||1|Tratamiento o restauración de la contaminación de las aguas subterráneas
77131500|Contaminación de petróleo|O|O||D||1
77131501|Servicios de monitoreo del derrame de petróleo|O|O||D||1|Servicios de vigilancia del derrame de petróleo
77131502|Servicios de control del derrame de petróleo|O|O||D||1
77131503|Servicios de rehabilitación por el derrame de petróleo|O|O||D||1|Servicios de restauración por el derrame de petróleo
77131600|Contaminación auditiva|O|O||D||1
77131601|Servicios de control del ruido|O|O||D||1
77131602|Servicios de protección contra la contaminación acústica|O|O||D||1
77131603|Servicios de monitoreo de la contaminación acústica|O|O||D||1|Servicios de vigilancia de la contaminación acústica
77131604|Servicios de asesoría sobre la contaminación acústica|O|O||D||1|Servicios de consultoría sobre la contaminación acústica
77131700|Contaminación de sustancias tóxicas|O|O||D||1
77131701|Servicios de monitoreo de sustancias tóxicas|O|O||D||1|Servicios de vigilancia de sustancias tóxicas
77131702|Servicios de rehabilitación por sustancias tóxicas|O|O||D||1|Servicios de restauración por sustancias tóxicas
78101500|Transporte de carga aérea|O|O||D||1
78101501|Transporte nacional aéreo de carga|O|O||D||1
78101502|Transporte internacional aéreo de carga|O|O||D||1
78101503|Transporte aéreo blindado|O|O||D||1
78101600|Transporte de carga por ferrocarril|O|O||D||1
78101601|Servicios de transporte en furgones|O|O||D||1|Servicios de transporte en vagones
78101602|Servicios de transporte ferroviario de carga a granel|O|O||D||1|Servicios de transporte ferroviario de mercancía a granel
78101603|Transporte de ganado por ferrocarril|O|O||D||1|Transporte ferroviario de ganado
78101604|Vehículos de servicios de transporte|O|O||D||1|Servicios de transporte de vehículos por ferrocarril
78101605|Servicio de alquiler de carrotanques de ferrocarril|O|O||D||1|Servicio de renta de carrotanques de ferrocarril
78101606|Servicio de alquiler de furgones de ferrocarril o carros de carga|O|O||D||1|Servicio de renta de vagones de ferrocarril o carros de carga
78101700|Transporte de carga por mar|O|O||D||1
78101701|Servicios de transporte nacional por buque|O|O||D||1|Servicios de transporte nacional por embarcación
78101702|Servicios de transporte internacional por buque|O|O||D||1|Servicios de transporte internacional por embarcación
78101703|Servicios de transporte nacional por barcazas|O|O||D||1
78101704|Servicios de transporte internacional por barcazas|O|O||D||1
78101705|Transporte marítimo blindado|O|O||D||1
78101706|Servicio de embarcaciones para suministros a plataformas de gas y petróleo mar adentro|O|O||D||1|Servicio de buques para suministros a plataformas de gas y petróleo en alta mar
78101800|Transporte de carga por carretera|O|O||D||1
78101801|Servicios de transporte de carga por carretera (en camión) en área local|O|O||D||1|Servicios de transporte de carga local
78101802|Servicios transporte de carga por carretera (en camión) a nivel regional y nacional|O|O||D||1|Servicios de transporte de carga foráneo
78101803|Servicios de transporte de vehículos|O|O||D||1|Servicios de transporte de vehículos por carretera
78101804|Servicios de reubicación|O|O||D||1|Servicios de fletes y mudanzas
78101805|Servicio de alquiler de remolques o camiones cisterna|O|O||D||1|Servicio de renta de remolques o camiones cisterna
78101806|Servicios transporte de carga por carretera a nivel internacional|O|O||D||1
78101807|Servicios de transporte de carga de petróleo o químicos  por carretera|O|O||D||1
78101900|Transporte de carga intermodal|O|O||D||1
78101901|Transporte aéreo a marítimo|O|O||D||1|Transporte con salida aérea y destino marítimo
78101902|Transporte marítimo a ferroviario|O|O||D||1|Transporte con salida marítima y destino ferroviario
78101903|Transporte marino a carretera (por camión)|O|O||D||1|Transporte con salida marítima y destino a carretera (por camión)
78101904|Transporte aéreo a carretera (por camión)|O|O||D||1|Transporte con salida aérea y destino a carretera (por camión)
78101905|Transporte por vagones de ferrocarril|O|O||D||1
78102000|Transporte de carga en naves espaciales|O|O||D||1
78102001|Servicios de lanzamiento de satélites|O|O||D||1
78102002|Servicios de carga explosiva experimental|O|O||D||1
78102100|Servicios de oleoductos|O|O||D||1
78102101|Transporte de productos derivados del petróleo|O|O||D||1|Transporte de productos petrolíferos
78102102|Transporte de agua|O|O||D||1
78102103|Servicio de inspección en línea  de tuberías|O|O||D||1
78102200|Servicios postales de paqueteo y courrier|O|O||D||1
78102201|Servicios de entrega postal nacional|O|O||D||1
78102202|Servicios de apartado postal|O|O||D||1|Servicios de apartado de correos
78102203|Servicios de envío, recogida o entrega de correo|O|O||D||1
78102204|Servicios de entrega a nivel mundial de cartas o paquetes pequeños|O|O||D||1|Servicios de mensajería y paquetería a nivel mundial
78102205|Servicios de entrega local de cartas o paquetes pequeños|O|O||D||1|Servicios de mensajería y paquetería en territorio nacional
78102206|Servicios de mensajería en bicicleta o motocicleta|O|O||D||1
78111500|Transporte de pasajeros aérea|O|O||D||1
78111501|Servicios de helicópteros|O|O||D||1
78111502|Viajes en aviones comerciales|O|O||D||1
78111503|Viajes en aviones fletados|O|O||D||1|Viajes en aviones alquilados
78111600|Transporte de pasajeros por ferrocarril|O|O||D||1
78111601|Servicios de transporte en vehículos de tren ligero lrv|O|O||D||1|Servicios de transporte de tren ligero
78111602|Transporte en metro|O|O||D||1
78111603|Servicios ferroviarios continentales o intercontinentales|O|O||D||1
78111700|Transporte de pasajeros por mar|O|O||D||1
78111701|Taxis acuáticos|O|O||D||1
78111702|Cruceros nocturnos|O|O||D||1|Cruceros por barco durante la noche
78111703|Excursiones de recorrido turístico en barco|O|O||D||1|Paseos en barco
78111704|Servicio de alquiler o leasing de embarcaciones marinas|O|O||D||1|Servicio de alquiler o arrendamiento de embarcaciones marítimas
78111705|Servicio de transporte del personal de plataformas de gas y petróleo en alta mar|O|O||D||1
78111802|Servicios de buses con horarios programados|O|O||D||1|Servicios de autobuses programados
78111803|Servicios de buses contratados|O|O||D||1|Servicios de alquiler de autobuses
78111804|Servicios de taxi|O|O||D||1
78111807|Tarifas del parqueadero|O|O||D||1|Tarifas de parquímetros
78111808|Alquiler de vehículos|O|O||D||1|Renta de vehículos
78111809|Leasing de vehículos sedán, cupé o camioneta|O|O||D||1
78111810|Servicio de limosinas o town cars|O|O||D||1
78111811|Alquiler de vehículos de camión ligero y vehículos de utilidad deportiva|O|O||D||1
78111812|Leasing de vehículos  de van o minivans para pasajeros|O|O||D||1
78111900|Transporte espacial|O|O||D||1
78111901|Misiones experimentales o educativas|O|O||D||1|Transporte para misiones experimentales o educativas
78121500|Empaque|O|O||D||1
78121501|Contenedorización de mercancías|O|O||D||1|Transporte de mercancías en cantidades menores de embalaje
78121502|Servicios de embalaje|O|O||D||1|Servicios de empaque
78121600|Servicios de manejo de materiales|O|O||D||1
78121601|Carga y descarga de mercancías|O|O||D||1
78121602|Servicios de pesaje|O|O||D||1
78121603|Tarifa de los fletes|O|O||D||1|Servicio de fletes de carga
78121604|Servicio de arriendo o leasing de montacargas|O|O||D||1|Servicio de renta de montacargas
78131500|Bodegaje de productos agrícolas|O|O||D||1
78131501|Servicios de silos|O|O||D||1|Servicio de almacenes para grano
78131502|Servicios de elevadores de granos|O|O||D||1
78131600|Almacenamiento de bienes generales|O|O||D||1
78131601|Almacenaje de mercancías embandejadas|O|O||D||1|Almacenaje de mercancías en palets
78131602|Almacenaje de archivos de carpetas|O|O||D||1
78131603|Almacenaje de muebles|O|O||D||1
78131700|Almacenamiento a granel|O|O||D||1
78131701|Servicios de almacenaje en tierra|O|O||D||1
78131702|Servicio de almacenaje sobre la superficie o en depósitos|O|O||D||1
78131800|Bodegaje y almacenamiento especializado|O|O||D||1
78131801|Almacenaje refrigerado|O|O||D||1
78131802|Servicios de almacenaje bajo control aduanero|O|O||D||1
78131803|Almacenaje de materiales peligrosos|O|O||D||1
78131804|Servicios de almacenaje de documentos|O|O||D||1
78131805|Almacenaje de cajeros automáticos|O|O||D||1
78131806|Servicio de autoalmacenaje o minialmacenaje|O|O||D||1|Servicio de mini bodegas
78141500|Servicios de organización de transportes|O|O||D||1
78141501|Servicios de expedidores de fletes|O|O||D||1|Servicios de agentes de carga
78141502|Servicios de agentes aduaneros|O|O||D||1
78141503|Servicios de comparación de tarifas de la industria del transporte o de auditoria de fletes|O|O||D||1
78141504|Refacturación y fletes manejados por proveedores o vendedores|O|O||D||1
78141600|Inspección|O|O||D||1
78141601|Servicios de inspección del empaquetado|O|O||D||1|Servicios de inspección de embalajes
78141602|Servicios de vigilancia de la carga|O|O||D||1
78141603|Inspecciones de control de plagas|O|O||D||1|Inspecciones de control de pestes
78141700|Servicios a la navegación|O|O||D||1
78141701|Servicios de remolcadores|O|O||D||1
78141702|Operaciones de puentes levadizos|O|O||D||1
78141703|Servicios de comunicaciones o de navegación marítima|O|O||D||1
78141704|Servicio de anclaje (deadman)|O|O||D||1|Servicio de anclaje de peso muerto
78141800|Servicios al terminal|O|O||D||1
78141801|Servicios de estiba|O|O||D||1
78141802|Servicios de atraque de buques|O|O||D||1|Servicios de anclaje de buques en puerto, Servicios de anclaje de embarcaciones en puerto
78141803|Servicios de tiendas en buques|O|O||D||1
78141804|Gestión de instalaciones de terminales de carga|O|O||D||1
78141805|Servicio de explotación de instalaciones de aviación o aeropuertos o aeródromos|O|O||D||1
78141806|Servicios de apoyo en la costa para gas y petróleo|O|O||D||1
78141900|Servicios de alquiler de contenedores de transporte|O|O||D||1
78141901|Servicios de alquiler de canastas de almacenamiento|O|O||D||1|Servicios de renta de canastas de almacenamiento
78141902|Alquiler de contenedores cerrados|O|O||D||1|Renta de contenedores cerrados
78181500|Servicios de mantenimiento y reparación de vehículos|O|O||D||1|Servicio de taller mecánico
78181501|Servicio de pintura o reparación de carrocerías de vehículos|O|O||D||1|Servicios de hojalatería y pintura
78181502|Reparación de transmisiones|O|O||D||1
78181503|Servicio de cambio fluidos de transmisión o de aceite|O|O||D||1
78181504|Reparación de trenes de aterrizaje|O|O||D||1
78181505|Servicios de inspección de vehículos|O|O||D||1|Servicios de inspección de autos
78181506|Servicios de reposición de vidrios de vehículos|O|O||D||1|Servicios de reposición de vidrios de autos
78181507|Reparación y mantenimiento automotor y de camiones ligeros|O|O||D||1|Mantenimiento automotriz, Mantenimiento y reparación de automóviles y camiones ligeros
78181508|Mantenimiento y reparación de camiones pesados|O|O||D||1
78181509|Servicio de inspección y mantenimiento de vagones ferroviarios|O|O||D||1|Servicio de inspección y mantenimiento de vagones de ferrocarril
78181600|Servicios de panel y pintura|O|O||D||1|Servicio de taller mecánico
78181601|Servicio de chapistería|O|O||D||1
78181700|Servicios de soporte de llenado de combustible de vehículos y almacenamiento de vehículos|O|O||D||1
78181701|Servicio de abastecimiento de combustible para vehículos|O|O||D||1
78181702|De almacenaje de vehículos de transporte|O|O||D||1
78181703|Servicio de parqueadero de vehículos|O|O||D||1|Servicio de estacionamiento de autos
78181800|Servicios de mantenimiento y reparación de aeronaves|O|O||D||1
78181801|Mantenimiento de las alas fijas de aeronaves|O|O||D||1|Mantenimiento de las alas fijas de aviones
78181802|Mantenimiento de las alas rotatorias de aeronaves|O|O||D||1|Mantenimiento de las alas rotatorias de aviones
78181900|Servicios de mantenimiento y reparación de equipo de navegación|O|O||D||1
78181901|Mantenimiento o reparación de equipos de navegación|O|O||D||1
80101500|Servicios de consultoría de negocios y administración corporativa|O|O||D||1|Servicios administrativos
80101501|Servicios de asesoramiento sobre la puesta en marcha de empresas nuevas|O|O||D||1|Consultoría para la apertura de nuevas empresas
80101502|Servicios de asesoramiento sobre fusiones de empresas|O|O||D||1|Consultoría para fusiones de empresas
80101503|Servicios de asesoramiento sobre liquidaciones o ventas de empresas|O|O||D||1|Consultoría para liquidaciones o ventas de empresas
80101504|Servicios de asesoramiento sobre planificación estratégica|O|O||D||1|Consultoría en planificación estratégica
80101505|Desarrollo de políticas u objetivos empresariales|O|O||D||1|Consultoría en políticas u objetivos empresariales, Viáticos pagados a empleados
80101506|Asesoramiento en estructuras organizacionales|O|O||D||1|Consultoría en estructuras organizacionales
80101507|Servicios de asesoramiento sobre tecnologías de la información|O|O||D||1|Consultoría en tecnologías de la información
80101508|Servicios de asesoramiento sobre  inteligencia empresarial|O|O||D||1|Consultoría en inteligencia empresarial
80101509|Servicios de asesoramiento para asuntos gubernamentales y de relaciones comunitarias|O|O||D||1|Consultoría en asuntos gubernamentales y de relaciones comunitarias
80101510|Servicio de asesoramiento para la  gestión de riesgo|O|O||D||1|Consultoría en gestión de riesgos
80101511|Servicio de asesoramiento en recursos humanos|O|O||D||1|Consultoría en recursos humanos
80101600|Gerencia de proyectos|O|O||D||1
80101601|Estudios de factibilidad o selección de ideas de proyectos|O|O||D||1
80101602|Estudios regionales o locales para proyectos|O|O||D||1
80101603|Evaluación económica o financiera de proyectos|O|O||D||1
80101604|Planificación o administración de proyectos|O|O||D||1
80101605|Servicios temporales de redacción|O|O||D||1|Servicios de elaboración de proyectos
80101700|Gerencia industrial|O|O||D||1
80101701|Servicios de gestión de fábricas|O|O||D||1
80101702|Estudios o implementación de productividad y eficacia|O|O||D||1
80101703|Servicios de estandarización de especificaciones|O|O||D||1
80101704|Análisis de cadenas de suministro o servicios de reingeniería|O|O||D||1
80101705|Servicios de cooperativas o consorcios|O|O||D||1
80101706|Servicios profesionales de adquisiciones|O|O||D||1
80101707|Servicios de cabildeo|O|O||D||1
80101708|Servicio de gestión de sustancias químicas|O|O||D||1
80111500|Desarrollo de recursos humanos|O|O||D||1|Servicios de capacitación de personal
80111501|Perfeccionamiento de la función de gestión|O|O||D||1|Servicios de mejoras en las habilidades de gestión
80111502|Planificación de compensaciones o beneficios|O|O||D||1
80111503|Relaciones laborales o con los sindicatos|O|O||D||1|Relaciones laborales o sindicales
80111504|Formación o desarrollo laboral|O|O||D||1
80111505|Auditorías de productividad de los recursos humanos|O|O||D||1|Auditorías de productividad del capital humano
80111506|Reubicación de personal|O|O||D||1
80111507|Servicios de empleo en otros organismos|O|O||D||1|Servicios de recolocación de personal
80111508|Programas de reconocimiento de servicios|O|O||D||1
80111509|Servicio de evaluación de puestos de trabajo|O|O||D||1
80111510|Servicio de redacción y desarrollo de la descripción de puestos de trabajo|O|O||D||1
80111600|Servicios de personal temporal|O|O||D||1|Servicios de agencias de colocación de personal
80111601|Asistencia de oficina o administrativa temporal|O|O||D||1|Colocación de personal temporal para asistencia administrativa o de oficina, Colocación de personal temporal para limpieza de inmuebles
80111602|Necesidades de personal de mercadeo temporal|O|O||D||1|Colocación de personal temporal para mercadotecnía
80111603|Necesidades de dotación de personal de producción temporal|O|O||D||1|Colocación de personal temporal para producción
80111604|Necesidades de dotación de personal técnico temporal|O|O||D||1|Colocación de personal temporal técnico
80111605|Necesidades de dotación de personal financiero temporal|O|O||D||1|Colocación de personal temporal financiero
80111606|Necesidades de dotación de personal medico  temporal|O|O||D||1|Colocación de personal temporal médico
80111607|Necesidades de dotación de personal jurídico temporal|O|O||D||1|Colocación de personal temporal jurídico
80111608|Desarrolladores temporales de software de tecnologías de la información|O|O||D||1|Colocación de personal temporal en desarrollo de software para tecnologías de la información
80111609|Administradores temporales de bases de datos o de sistemas de tecnologías de la información|O|O||D||1|Administradores temporales de bases de datos o de sistemas de tecnologías de la información
80111610|Especialistas en interconexión de tecnologías de la información temporales|O|O||D||1|Colocación de personal temporal especialista en interconexión de tecnologías de la información
80111611|Personal  temporal  de almacén|O|O||D||1|Colocación de personal temporal para almacén
80111612|Conductores temporales|O|O||D||1|Colocación de personal temporal para chofer
80111613|Trabajadores manuales temporales|O|O||D||1|Colocación de personal temporal para trabajos manuales
80111614|Servicios temporales de ingeniería|O|O||D||1|Colocación de personal temporal de ingeniería
80111615|Personal maquinista temporal|O|O||D||1|Colocación de personal temporal para maquinista
80111616|Personal temporal de servicio al cliente|O|O||D||1|Colocación de personal temporal de atención al cliente
80111617|Servicios temporales de arquitectura|O|O||D||1|Colocación de personal temporal de arquitectura
80111618|Servicios temporales de construcción|O|O||D||1|Colocación de personal temporal para construcción
80111619|Servicios creativos temporales|O|O||D||1|Colocación de personal temporal para servicios creativos
80111620|Servicios temporales de recursos humanos|O|O||D||1|Colocación de personal temporal en recursos humanos
80111621|Servicios temporales de investigación y desarrollo|O|O||D||1|Colocación de personal temporal para investigación y desarrollo
80111622|Servicios temporales ambientales en salud y seguridad|O|O||D||1|Colocación de personal temporal para servicios ambientales, de salud y seguridad
80111623|Servicios temporales de compras y logística|O|O||D||1|Colocación de personal temporal para compras y logística
80111624|Dotación de personal de viaje temporal|O|O||D||1|Colocación de personal temporal para viajes
80111625|Trabajadores manuales de subterráneos temporales|O|O||D||1|Colocación de personal temporal para trabajos en subterráneos, minas o ductos
80111700|Reclutamiento de personal|Sí|O||D||1|Servicios de agencias de colocación de personal
80111701|Servicios de contratación de personal|Sí|O||D||1|Servicios de outsourcing, Servicios de subcontratación de personal
80111702|Servicios de comprobación de referencias o antecedentes|O|O||D||1|Servicios de verificación de referencias y antecedentes
80111703|Servicios de preselección  de hojas de vida o  currículum vitae|O|O||D||1
80111704|Necesidades de personal de mercadeo permanente|O|O||D||1|Colocación de personal fijo para mercadotecnia
80111705|Personal maquinista permanente|O|O||D||1|Colocación de personal fijo para maquinista
80111706|Asistencia administrativa o de oficina permanente|O|O||D||1|Colocación de personal fijo para asistencia administrativa o de oficina, Colocación de personal fijo para limpieza de inmuebles
80111707|Necesidades de dotación de personal técnico permanente|O|O||D||1|Colocación de personal fijo técnico
80111708|Necesidades de dotación personal  financiero permanente|O|O||D||1|Colocación de personal fijo financiero
80111709|Necesidades de personal médico permanente|O|O||D||1|Colocación de personal fijo médico
80111710|Necesidades de dotación de personal jurídico permanente|O|O||D||1|Colocación de personal fijol jurídico
80111711|Desarrolladores de software de tecnologías de la información permanentes|O|O||D||1|Colocación de personal fijo en desarrollo de software para tecnologías de la información
80111712|Especialistas en redes de tecnologías de la información permanentes|O|O||D||1|Colocación de personal fijo especialista en redes de tecnologías de la información
80111713|Administradores permanentes de bases de datos o de sistemas de tecnologías de la información|O|O||D||1|Administradores fijos de bases de datos o de sistemas de tecnologías de la información
80111714|Conductores permanentes|O|O||D||1|Colocación de personal fijo para chofer
80111715|Personal profesional permanente|O|O||D||1|Colocación de personal fijo profesional
80111716|Necesidades de dotación de personal de tecnologías de la información permanente|O|O||D||1|Colocación de personal fijo en tecnologías de la información
80121500|Servicios de derecho penal|O|O||D||1|Asesoría jurídica
80121501|Servicios legales de justicia juvenil o de adolescentes|O|O||D||1|Servicios legales de justicia de menores
80121502|Servicios para procesos de apelación|O|O||D||1
80121503|Servicios para defensa o de derecho penal|O|O||D||1
80121600|Servicios de derecho comercial|O|O||D||1|Asesoría jurídica
80121601|Servicios legales sobre competencia o regulaciones gubernamentales|O|O||D||1
80121602|Servicios legales de quiebra|O|O||D||1|Servicios legales de bancarrota, Servicios legales para embargos
80121603|Derecho societario|O|O||D||1|Honorarios de notarios, Serivicios de derecho mercantil, Servicios notariale
80121604|Derecho de patentes, marcas o derechos de autor|O|O||D||1|Regalías por derechos de autor
80121605|Derecho sobre liquidación (de sociedades)|O|O||D||1
80121606|Derecho inmobiliario|O|O||D||1|Derecho bienes inmuebles
80121607|Derecho tributario|O|O||D||1
80121608|Derecho de fusiones o adquisiciones|O|O||D||1|Derecho de combinaciones o adquisiciones
80121609|Servicios de investigación legal|O|O||D||1
80121610|Servicios legales de cobro de deudas o cartera.|O|O||D||1
80121611|Derecho de reclamación por tratamiento médico.|O|O||D||1
80121700|Servicios de responsabilidad civil|O|O||D||1|Asesoría jurídica
80121701|Servicios legales de malpraxis o negligencia profesional|O|O||D||1|Servicios legales de mala practica o negligencia profesional
80121702|Servicios legales sobre daños a personas|O|O||D||1
80121703|Servicios legales de sobre la  propiedad|O|O||D||1|Honorarios de notarios, Servicios notariales
80121704|Servicios legales sobre contratos|O|O||D||1|Honorarios de notarios, Servicios notariales
80121705|Servicios legales sobre beneficios de los empleados|O|O||D||1
80121706|Servicios legales sobre derecho laboral|O|O||D||1
80121707|Servicios legales para disputas laborales|O|O||D||1
80121800|Servicios de derecho de familia|O|O||D||1|Asesoría jurídica
80121801|Servicios sobre derecho de divorcio|O|O||D||1
80121802|Servicios legales para adopción|O|O||D||1
80121803|Derecho migratorio o de naturalización|O|O||D||1
80121804|Servicios legales para tutorías o de custodia|O|O||D||1|Servicios legales de tutela o de custodia
80121900|Servicios de participación compensada legal|O|O||D||1
80121901|Servicio como miembro del jurado|O|O||D||1
80121902|Servicio como testigo|O|O||D||1
80121903|Servicio como testigo experto|O|O||D||1
80131500|Alquiler y arrendamiento de propiedades o edificaciones|O|O||D||1|Arrendamiento de bienes inmuebles
80131501|Arrendamiento de residencias|O|O||D||1|Renta de casa habitación
80131502|Arrendamiento de instalaciones comerciales o industriales|O|O||D||1|Renta de local comercial
80131503|Arrendamientos de tierras|O|O||D||1|Renta de terreno
80131504|Servicio de alojamiento temporal offshore|O|O||D||1
80131505|Servicio de arrendamiento de oficinas portátiles o modulares|O|O||D||1|Renta o alquiler de oficinas portátiles o modulares
80131506|Servicio de arrendamiento de baños portátiles|O|O||D||1|Renta o alquiler de baños portátiles
80131600|Ventas de propiedades y edificios|O|O||D||1
80131601|Corredores o agentes inmobiliarios|O|O||D||1
80131602|Subasta inmobiliaria|O|O||D||1|Subasta de bienes inmuebles
80131603|Venta de tierras residenciales|O|O||D||1
80131604|Venta de tierras comerciales o industriales|O|O||D||1
80131605|Venta de edificio comercial|O|O||D||1
80131700|Servicios de custodia y título|O|O||D||1
80131701|Servicios para la restitución de títulos de propiedad|O|O||D||1
80131702|Servicios de estudio de títulos|O|O||D||1
80131703|Servicios de cuenta de depósito en garantía|O|O||D||1
80131800|Servicios de administración inmobiliaria|O|O||D||1
80131801|Administración de propiedades|O|O||D||1|Cuotas de mantenimiento, Gestión de propiedades
80131802|Servicios de avalúo de inmuebles|O|O||D||1|Servicios de avalúo inmobiliario
80131803|Servicios de listado de inmuebles|O|O||D||1|Servicios de listado de inmobiliario
80141500|Investigación de mercados|O|O||D||1
80141501|Análisis de mercados|O|O||D||1
80141502|Estadísticas comerciales de distribución o de servicios|O|O||D||1
80141503|Previsión de precios de las mercancías|O|O||D||1
80141504|Preparación de estudios de mercado de mercancías|O|O||D||1
80141505|Planes de comercialización|O|O||D||1|Planes de mercadeo
80141506|Investigación de mercado s basada en internet|O|O||D||1|Investigación de mercados basada en internet
80141507|Investigaciones  o clínicas o grupos focales  basados en el consumidor|O|O||D||1|Investigaciones y grupos de enfoque basados en el consumidor
80141508|Estudios de predicciones sindicados o privados|O|O||D||1|Estudios de exploración y diagnóstico
80141509|Análisis competitivo o de inteligencia del mercado|O|O||D||1
80141510|Encuestas telefónicas para investigaciones de mercado|O|O||D||1
80141511|Encuestas impresas para investigaciones de mercado|O|O||D||1
80141512|Encuestas para investigaciones de mercados en el lugar|O|O||D||1|Encuestas en sitio para investigaciones de mercado
80141513|Entrevistas personales para investigaciones de mercado|O|O||D||1
80141514|Encuestas por correo electrónico para la investigación de mercados|O|O||D||1
80141600|Actividades de ventas y promoción de negocios|O|O||D||1|Comisiones
80141601|Servicios de promoción de ventas|O|O||D||1|Servicios de comisionistas
80141602|Servicios de relaciones públicas|O|O||D||1
80141603|Telemercadeo|O|O||D||1
80141604|Servicios de posicionamiento del  nombre de los productos|O|O||D||1
80141605|Mercancía promocional|O|O||D||1
80141606|Cumplimiento del mercadeo directo|O|O||D||1
80141607|Gestión de eventos|O|O||D||1|Organización de eventos, Administración de eventos
80141609|Patrocinio de eventos o de celebridades|O|O||D||1
80141610|Liquidaciones|O|O||D||1|Anticipos de clientes, Saldos
80141611|Servicios de personalización de obsequios o productos|O|O||D||1
80141612|Programas de venta o de mercadeo|O|O||D||1|Servicios de comisionistas
80141613|Programas posventas|O|O||D||1|Servicios de comisionistas
80141614|Servicios o programas de relaciones públicas|O|O||D||1
80141615|Vehículo usado, de alquiler o de exposición|O|O||D||1|Vehículo usado, de renta o de exposición
80141616|Materiales en puntos de venta, excluido el material impreso|O|O||D||1
80141617|Capacitación en iniciativas estratégicas en los concesionarios|O|O||D||1
80141618|Agencias de mercadeo  de venta, incluido el material impreso|O|O||D||1
80141619|Servicios de administración del centro de relaciones con el consumidor (crc)|O|O||D||1
80141620|Soporte de iniciativas estratégicas en los concesionarios|O|O||D||1
80141621|Automovilismo|O|O||D||1
80141622|Servicios de talleres postales|O|O||D||1|Tiendas de sobres para cartas
80141623|Servicio de comercialización|O|O||D||1
80141624|Servicio de gestión de programas de reconocimiento|O|O||D||1|Servicio de administración de programas de reconocimiento
80141625|Servicio de gestión de programas de incentivos|O|O||D||1|Servicio de administración de programas de incentivos
80141626|Servicio de gestión de programas promocionales|O|O||D||1|Servicio de administración de programas promocionales
80141627|Servicio de gestión de publicidad cooperativa o compartida|O|O||D||1|Servicio de administración de publicidad cooperativa o compartida
80141628|Servicio de distribuidores por comisión|O|O||D||1
80141629|Servicio de manejo de bonificaciones|O|O||D||1|Servicio de gestión de reembolso
80141630|Servicio de comercialización directa de materiales impresos|O|O||D||1
80141700|Distribución|O|O||D||1
80141701|Servicios de venta directa|O|O||D||1
80141702|Servicios de distribución mayorista|O|O||D||1|Servicios de distribución al mayoreo
80141703|Servicios de distribución minorista|O|O||D||1|Servicios de distribución al menudeo
80141704|Operaciones de franquicias|O|O||D||1
80141705|Servicios de subastas|O|O||D||1
80141706|Servicio de intermediación de productos|O|O||D||1
80141800|Servicios de correo|O|O||D||1
80141801|Servicios de recopilación de listas de direcciones|O|O||D||1|Servicios de compilación de listas de direcciones
80141802|Servicio de administración de listas de direcciones|O|O||D||1|Servicio de gestión de listas de direcciones
80141803|Servicio de escritura de direcciones|O|O||D||1
80141900|Exhibiciones y ferias comerciales|O|O||D||1
80141901|Ferias de automóviles u otras exposiciones|O|O||D||1|Exposiciones de autos u otras exposiciones
80141902|Reuniones y eventos|O|O||D||1
80141903|Talento o entretenimiento|O|O||D||1
80151500|Facilitación del comercio|O|O||D||1
80151501|Servicios de proyeción o políticas de productos básicos|O|O||D||1
80151502|Expansión comercial|O|O||D||1|Ampliación comercial
80151503|Servicios de información comercial|O|O||D||1
80151504|Servicios de promoción comercial|O|O||D||1
80151505|Empresas multinacionales de comercialización|O|O||D||1
80151600|Servicios de comercio internacional|O|O||D||1|Comercio exterior
80151601|Desarrollo de las exportaciones|O|O||D||1
80151602|Planificación de las importaciones|O|O||D||1
80151603|Proyecciones de las exportaciones|O|O||D||1
80151604|Servicios de adquisición de importaciones|O|O||D||1
80151605|Servicios de consultoría aduanera|O|O||D||1|Servicios de asesoría aduanera
80161500|Servicios de apoyo gerencial|O|O||D||1
80161501|Servicios secretariales o de administración de oficinas|O|O||D||1
80161502|Servicios de planificación de reuniones|O|O||D||1
80161503|Servicios de entrada por teclado|O|O||D||1
80161504|Servicios de oficina|O|O||D||1
80161505|Servicios de administración de flotas|O|O||D||1
80161506|Servicios de archivo de datos|O|O||D||1
80161507|Servicios audiovisuales|O|O||D||1
80161508|Servicios de destrucción de documentos|O|O||D||1|Servicios de eliminación de documentos
80161600|Supervisión de instalaciones de negocios|O|O||D||1
80161601|Servicios de administración de la propiedad|O|O||D||1|Servicios de gestión de la propiedad
80161602|Servicios de recepción o inventariado|O|O||D||1
80161603|Gestión o administración de proyectos de mobiliario|O|O||D||1
80161700|Servicios de recuperación de activos|O|O||D||1
80161701|Servicio de disposición o venta de subproductos|O|O||D||1
80161702|Servicio de disposición o venta de bienes de capital|O|O||D||1|Servicio de disposición o venta de bienes duraderos
80161703|Servicio de disposición o venta de materiales no capitalizables sobrantes u obsoletos|O|O||D||1
80161800|Servicios de alquiler o arrendamiento de equipo de oficina|O|O||D||1
80161801|Servicio de alquiler o leasing de fotocopiadoras|O|O||D||1|Servicio de alquiler o arrendamiento de fotocopiadoras
81101500|Ingeniería civil|O|O||D||1
81101501|Ingeniería de pozos|O|O||D||1
81101502|Dibujo técnico|O|O||D||1
81101503|Ingeniería de puertos|O|O||D||1|Ingeniería portuaria
81101505|Ingeniería estructural|O|O||D||1
81101506|Arquitectura naval|O|O||D||1
81101507|Ingeniería de represas|O|O||D||1|Ingeniería de presas
81101508|Ingeniería arquitectónica|O|O||D||1
81101509|Ingeniería aeroportuaria|O|O||D||1
81101510|Ingeniería de carreteras|O|O||D||1
81101511|Ingeniería ferroviaria|O|O||D||1
81101512|Servicios de sistemas de información geográfica (sig)|O|O||D||1|Servicios de topografía
81101513|Gestión de construcción de edificios|O|O||D||1|Honorarios de arquitectos, Servicios de construcción, Servicios profesionales de arquitectur
81101514|Ingeniería geotécnica o geosísmica|O|O||D||1
81101515|Ingeniería de infraestructura de instalaciones o fábricas|O|O||D||1
81101516|Servicio de consultoría de energía o servicios públicos|O|O||D||1|Servicio de asesoría de energía o servicios públicos
81101600|Ingeniería mecánica|O|O||D||1
81101601|Dibujo mecánico|O|O||D||1
81101602|Diseño de envolturas de productos mecánicos|O|O||D||1|Diseño de gabinetes de productos mecánicos
81101603|Diseño de máquinas herramientas|O|O||D||1
81101604|Diseño de transmisión de potencia|O|O||D||1
81101605|Servicios electromecánicos|O|O||D||1
81101700|Ingeniería eléctrica y electrónica|O|O||D||1
81101701|Servicios de ingeniería eléctrica|O|O||D||1
81101702|Diseño de circuitos electrónicos|O|O||D||1
81101703|Servicios de pruebas técnicas|O|O||D||1|Servicios de pruebas de ingeniería
81101706|Mantenimiento de equipos de laboratorio|O|O||D||1
81101707|Mantenimiento de equipos de impresión|O|O||D||1
81101710|Servicio de reclamación de wafers|O|O||D||1|Servicios de recuperación de obleas de silicio
81101711|Servicios de fabricación de componentes electrónicos|O|O||D||1
81101713|Servicio técnico y de diseño de instrumentos de medición y de registro electrónicos|O|O||D||1
81101800|Ingeniería química|O|O||D||1
81101801|Ingeniería de plásticos|O|O||D||1
81101802|Servicios de ingeniería de procesos químicos|O|O||D||1
81101900|Ingeniería de petróleos y gas|O|O||D||1
81101902|Ingeniería de producción para petróleo o gas|O|O||D||1
81102000|Ingeniería de minas|O|O||D||1
81102001|Minería hidráulica|O|O||D||1
81102100|Ingeniería de océanos|O|O||D||1
81102101|Ingeniería de costas|O|O||D||1|Ingeniería costera
81102200|Ingeniería de transporte|O|O||D||1
81102201|Ingeniería de tráfico|O|O||D||1|Ingeniería de tránsito
81102202|red de transporte urbano|O|O||D||1
81102203|Vías de navegación interior|O|O||D||1|Vías navegables interiores
81102300|Ingeniería aeronáutica|O|O||D||1
81102301|Diseño de aviónica|O|O||D||1
81102400|Ingeniería de transmisión de energía eléctrica|O|O||D||1
81102401|Construcción de líneas de tendido aéreo de alto voltaje|O|O||D||1|Construcción de línea aérea de alto voltaje
81102402|Mantenimiento y reparación  de líneas de tendido aéreo de alto voltaje|O|O||D||1|Mantenimiento y reparación de líneas aéreas de alto voltaje
81102500|Servicios de permisos|O|O||D||1
81102501|Servicio para obtener licencia en operación de minas|O|O||D||1
81102600|Servicios de muestreo|O|O||D||1
81102601|Servicio de muestreo de carbón|O|O||D||1
81102700|Servicios de diseño e ingeniería de sistemas instrumentados de control|O|O||D||1
81102701|Servicio de ingeniería para sistemas de control y monitoreo de incendios y gas|O|O||D||1
81102702|Servicio de ingeniería y diseño para sistemas de control de procesos|O|O||D||1
81111500|Ingeniería de software o hardware|O|O||D||1
81111501|Diseño de aplicaciones de software de la unidad central|O|O||D||1
81111502|Diseños de aplicaciones para computadores personales (pc)|O|O||D||1|Diseño de aplicaciones para ordenadores personales (PC)
81111503|Diseño de integración de sistemas|O|O||D||1
81111504|Servicios de programación de aplicaciones|O|O||D||1
81111505|Servicios de programación de sistemas operativos|O|O||D||1
81111506|Servicios de programación para clientes o servidores|O|O||D||1
81111507|Servicios de programación de aplicaciones de bases de datos (erp)|O|O||D||1
81111508|Servicios de implementación de aplicaciones|O|O||D||1
81111509|Servicios de desarrollo de aplicaciones para clientes de internet / intranet|O|O||D||1
81111510|Servicios de desarrollo de aplicaciones para servidores de internet / intranet|O|O||D||1
81111600|Programadores de computador|O|O||D||1
81111601|Programación para visual basic|O|O||D||1
81111602|Programación para java|O|O||D||1
81111603|Programación para html|O|O||D||1|Programación para Lenguaje de Marcado para Hipertextos
81111604|Programación para algol|O|O||D||1|Programación para lenguaje algorítmico
81111605|Programación para assembler|O|O||D||1|Programación para lenguaje ensamblador
81111606|Programación para basic|O|O||D||1|Programación de Código simbólico de instrucciones de propósito general para principiantes
81111607|Programación para c, c++|O|O||D||1
81111608|Programación para cobol|O|O||D||1|Programación para Lenguaje Común Orientado a Negocios
81111609|Programación para fortran|O|O||D||1
81111610|Programación para pascal|O|O||D||1
81111611|Programación para pl/1|O|O||D||1|Lenguaje de programación 1
81111612|Lenguajes de programación o de marca patentada|O|O||D||1
81111613|Programación para perl|O|O||D||1
81111700|Sistemas de manejo de información MIS|O|O||D||1
81111701|Diseño de comunicaciones por redes de cobertura amplia|O|O||D||1
81111702|Diseño de comunicaciones por redes de área local|O|O||D||1
81111703|Diseño del intercambio electrónico de datos (ied)|O|O||D||1
81111704|Diseño de bases de datos|O|O||D||1
81111705|Arquitectura de sistemas|O|O||D||1
81111706|Servicios de planificación de redes|O|O||D||1
81111707|Servicios de planificación de sistemas|O|O||D||1
81111708|Servicios de planificación de telecomunicaciones|O|O||D||1
81111800|Servicios de sistemas y administración de componentes de sistemas|O|O||D||1
81111801|Seguridad de los computadores, redes o internet|O|O||D||1|Seguridad informática o en red o Internet
81111802|Servicios de administración de la unidad central|O|O||D||1
81111803|Mantenimiento o soporte de redes de área local (lan)|O|O||D||1
81111804|Mantenimiento o soporte de redes de cobertura amplia (wan)|O|O||D||1|Mantenimiento o soporte de redes de cobertura ancha (WAN)
81111805|Mantenimiento o soporte de sistemas patentados o autorizados|O|O||D||1
81111806|Servicio de análisis de bases de datos|O|O||D||1
81111808|Servicio de análisis de sistemas|O|O||D||1
81111809|Servicio de instalación de sistemas|O|O||D||1
81111810|Servicios de codificación de software|O|O||D||1|Servicios de codificación de programas
81111811|Servicios de soporte técnico o de mesa de ayuda|O|O||D||1|Servicios asistencia técnica
81111812|Servicio de mantenimiento o soporte del hardware del computador|O|O||D||1|Servicio de soporte de mantenimiento de hardware de la computadora
81111814|Servicio de colocación|O|O||D||1
81111818|Garantía de terceros|O|O||D||1|Servicio de garantía de terceros
81111819|Servicios de garantía de calidad|O|O||D||1
81111820|Servicios de funcionalidad del sistema|O|O||D||1
81111900|Sistemas de recuperación de información|O|O||D||1
81111901|Recuperación de información de las bases de datos|O|O||D||1
81111902|Servicio de recuperación de información de las bases de datos en línea|O|O||D||1
81112000|Servicios de datos|O|O||D||1
81112001|Servicio de procesamiento de datos en línea|O|O||D||1
81112002|Servicios de procesamiento o preparación de datos|O|O||D||1
81112003|Servicios de centros de datos|O|O||D||1
81112004|Servicios de recuperación de desastres|O|O||D||1
81112005|Servicio de escaneo de documentos|O|O||D||1|Servicio de digitalización de documentos
81112006|servicios de almacenamiento de datos|O|O||D||1
81112007|Servicios de estandarización de datos o contenidos|O|O||D||1
81112008|Servicios de generación de originales de cd-rom|O|O||D||1
81112009|Servicios de clasificación de datos o contenidos|O|O||D||1
81112010|Servicio de conversión de datos|O|O||D||1
81112100|Servicios de internet|O|O||D||1
81112101|Proveedores de servicio de internet (psi)|O|O||D||1
81112102|Proveedor de servicio de correo electrónico|O|O||D||1
81112103|Servicios de diseño de sitios web www|O|O||D||1
81112104|Proveedores de motores de búsqueda en la web|O|O||D||1
81112105|Servicios de hospedaje de operación de sitios web|O|O||D||1
81112106|Proveedores de servicios de aplicación|O|O||D||1
81112107|Nombres de los dominio de internet|O|O||D||1
81112200|Mantenimiento y soporte de software|O|O||D||1|Mantenimiento y soporte de programas para computadoras
81112201|Tarifas de soporte o mantenimiento|O|O||D||1
81112202|Actualizaciones o parches de software|O|O||D||1
81112203|Servicio de actualización o parcheo de firmware|O|O||D||1
81112204|Mantenimiento de software de sistemas operativos|O|O||D||1|Mantenimiento de programas para sistemas operativos
81112205|Mantenimiento de software de sistemas de gestión de bases de datos|O|O||D||1|Mantenimiento de programas para sistemas de gestión de bases de datos
81112206|Mantenimiento de software de búsqueda o recuperación de la información|O|O||D||1|Mantenimiento de programas para búsqueda o recuperación de la información
81112207|Mantenimiento de software de videoconferencias|O|O||D||1|Mantenimiento de programas para videoconferencias
81112208|Mantenimiento de software de protección y seguridad|O|O||D||1|Mantenimiento de programas para protección y seguridad
81112209|Mantenimiento de software de desarrollo|O|O||D||1|Mantenimiento de programas para desarrollo
81112210|Mantenimiento de software de gestión de sistemas|O|O||D||1|Mantenimiento de programas para gestión de sistemas
81112211|Mantenimiento de software de planificación de recursos empresariales|O|O||D||1|Mantenimiento de programas para planificación de recursos empresariales
81112212|Mantenimiento de software de administración de relaciones con el consumidor|O|O||D||1|Mantenimiento de programas para administración de relaciones con el consumidor
81112213|Mantenimiento del software de contabilidad|O|O||D||1|Mantenimiento de programas para contabilidad
81112214|Mantenimiento de software de autoría y edición de contenido|O|O||D||1|Mantenimiento de programas para autoría y edición de contenido
81112215|Mantenimiento de software de gestión del contenido|O|O||D||1|Mantenimiento de programas para gestión del contenido
81112216|Mantenimiento de software de referencia o educativo|O|O||D||1|Mantenimiento de programas para referencia o educativo
81112217|Mantenimiento de software específico de industrias|O|O||D||1|Mantenimiento de programa específico de industrias
81112218|Aplicaciones para el mantenimiento de software.|O|O||D||1|Aplicaciones para el mantenimiento de programas
81112219|Mantenimiento de software de juegos o entretenimiento de computador|O|O||D||1|Mantenimiento de programas para juegos o entretenimiento de computadora
81112220|Mantenimiento de software de servidores|O|O||D||1|Mantenimiento de programas para servidores
81112221|Servicio de mantenimiento del software del punto de venta|O|O||D||1|Mantenimiento de programas para puntos de venta
81112222|Mantenimiento de software de gestión mantenimiento y operación de las instalaciones|O|O||D||1|Mantenimiento de programas para gestión mantenimiento y operación de las instalaciones
81112300|Mantenimiento y soporte de hardware de computador|O|O||D||1|Mantenimiento y soporte de programas para computadoras
81112301|Mantenimiento de sistemas de almacenamiento de discos|O|O||D||1
81112302|Mantenimiento de sistemas de copias de seguridad o de nearline|O|O||D||1
81112303|Mantenimiento de computadores “mainframe”|O|O||D||1|Mantenimiento de grandes ordenadores
81112304|Mantenimiento de servidores unix|O|O||D||1
81112305|Mantenimiento de servidores x86|O|O||D||1
81112306|Mantenimiento de impresoras|O|O||D||1
81112307|Mantenimiento de pc o puestos de trabajo o cuadernos|O|O||D||1|Mantenimiento de PC, estaciones de trabajo o portátiles
81112308|Servicio de soporte y mantenimiento de hardware de puntos de venta|O|O||D||1
81112309|Servicio de instalación o implementación de hardware de puntos de venta|O|O||D||1
81112400|Servicios de alquiler o arrendamiento de hardware de computador|O|O||D||1
81112401|Alquiler de hardware de computadores|O|O||D||1|Renta de componentes materiales de computadoras, Renta de equipos de cómputo, Servicio de cafeinternet o cibercaf
81112500|Servicios de alquiler o arrendamiento de licencias de software de computador|O|O||D||1
81112501|Servicio de licencias del software del computador|O|O||D||1|Servicio de licencias de programas para computadora
81112502|Servicio de arriendo o leasing de software de computadores|O|O||D||1|Servicio de renta o alquiler de programas para computadora
81121500|Análisis económico|O|O||D||1|Servicio de análisis económico
81121501|Análisis macroeconómico|O|O||D||1
81121502|Análisis microeconómico|O|O||D||1
81121503|Econometría|O|O||D||1
81121504|Proyecciones económicas|O|O||D||1|Servicio de previsiones económicas
81121600|Sistemas y emisiones monetarias|O|O||D||1
81121601|Política monetaria|O|O||D||1
81121602|Sistemas monetarios|O|O||D||1
81121603|Análisis monetario|O|O||D||1
81121604|Liquidez monetaria|O|O||D||1
81121605|Reservas de metales preciosos|O|O||D||1
81121606|Control de cambio de divisas|O|O||D||1
81121607|Mercados cambio de divisas|O|O||D||1
81131500|Metodología y Análisis|O|O||D||1|Servicios de metodología y análisis
81131501|Análisis de factores|O|O||D||1
81131502|Análisis multivariate|O|O||D||1
81131503|Análisis de regresión|O|O||D||1
81131504|Encuestas por muestreo|O|O||D||1
81131505|Análisis de series temporales|O|O||D||1
81141500|Control de calidad|O|O||D||1|Servicios de control de calidad
81141501|Ensayo de materiales|O|O||D||1|Determinación de propiedades mecánicas de los materiales
81141502|Síntesis de materiales|O|O||D||1
81141503|Inspección de materiales o productos|O|O||D||1
81141504|Reparación o calibración de pruebas de equipo|O|O||D||1
81141505|Desarrollo de estándares de producción|O|O||D||1
81141506|Ensayo de productos|O|O||D||1
81141600|Manejo de cadena de suministros|O|O||D||1|Servicios de manejo de cadena de suministros
81141601|Logística|O|O||D||1|Maniobras terrestres, aéreas y marítimas
81141602|Análisis de tránsito|O|O||D||1
81141603|Economía o finanzas del transporte|O|O||D||1
81141604|Facilitación del transporte|O|O||D||1
81141605|Infraestructura del transporte|O|O||D||1
81141606|Planificación del transporte|O|O||D||1
81141700|Planeación y control de producción|O|O||D||1|Servicios de planeación y control de producción
81141701|Planificación de la producción|O|O||D||1
81141702|Control de la producción|O|O||D||1
81141703|Programación de la producción|O|O||D||1|Calendarización de la producción
81141704|Servicios de análisis o recopilación de estadísticas de producción|O|O||D||1
81141800|Administración de instalaciones|O|O||D||1|Servicios de administración de instalaciones
81141801|Análisis de riesgo o seguridad|O|O||D||1
81141802|Higiene o ventilación industrial|O|O||D||1
81141803|Control del ruido o de la acústica|O|O||D||1
81141804|Servicio de inspección de equipos|O|O||D||1
81141805|Servicio de inspección de edificios|O|O||D||1|Servicio de inspección de instalaciones
81141806|Servicios de inspección de líneas de energía eléctrica|O|O||D||1
81141807|Servicios de inspección de plomería o alcantarillado|O|O||D||1
81141900|Servicios de investigación y desarrollo de tecnología manufacturera|O|O||D||1
81141901|Servicio de investigación y desarrollo de productos|O|O||D||1
81141902|Servicio de investigación y desarrollo de aplicaciones o tecnología|O|O||D||1
81151500|Meteorología|O|O||D||1|Servicios de meteorología
81151501|Climatología|O|O||D||1|Servicios de estudios del clima y sus variaciones
81151502|Servicios meteorológicos|O|O||D||1
81151503|Hidrometeorología|O|O||D||1|Servicios de estudios del ciclo del agua
81151600|Cartografía|O|O||D||1|Servicios de cartografía
81151601|Cartografía|O|O||D||1|Servicios de cartografía
81151602|Producción de mapas|O|O||D||1|Servicios de producción de mapas
81151603|Fotogrametría|O|O||D||1|Servicios de mapas mediante fotografía aérea
81151604|Agrimensura|O|O||D||1|Servicios de delimitación de superficies conforme a derecho
81151700|Geología|O|O||D||1|Servicios de geología
81151701|Fotogeología|O|O||D||1|Servicios de interpretación de fotografía aérea
81151702|Geología estratigráfica|O|O||D||1|Servicios de estudio e interpretación de rocas sedimentarias estratificadas
81151703|Estudios geológicos|O|O||D||1|Servicios de estudios geológicos
81151704|Exploración geológica|O|O||D||1|Servicios de exploración geológica
81151705|Servicios arqueológicos|O|O||D||1
81151800|Oceanografía e hidrología|O|O||D||1|Servicios de oceanografía e hidrología
81151801|Estudio oceanográfico|O|O||D||1|Servicios de estudios oceanográficos
81151802|Oceanografía estuarina|O|O||D||1|Servicios de estudios de desembocaduras de ríos a mares u océanos
81151803|Oceanografía física|O|O||D||1|Servicios de estudios de las condiciones y procesos físicos de los océanos
81151804|Estudios hidrológicos|O|O||D||1|Servicios de estudios hidrológicos
81151805|Estudios batimétricos|O|O||D||1|Servicios de estudios de profundidades marinas
81151806|Exploración submarina|O|O||D||1|Servicios de exploración submarina
81151900|Geofísica|O|O||D||1|Servicios de geofísica
81151901|Estudios geofísicos|O|O||D||1|Servicios de estudios geofísicos
81151902|Exploración geofísica|O|O||D||1|Servicios de exploración geofísica
81151903|Interpretación de fotografía geofísica|O|O||D||1|Servicios de interpretación de fotografía geofísica
81151904|Geofísica aeromagnética|O|O||D||1|Servicios de geofísica aeromagnética
81161500|Servicios de administración de acceso|O|O||D||1|Servicios de administración de acceso a través de redes
81161501|Servicio de administración de aplicaciones de software|O|O||D||1
81161502|Servicio de administración de cuentas en la red|O|O||D||1
81161503|Servicio de administración de carpetas en la red|O|O||D||1
81161600|Servicios de correo electrónico y mensajería|O|O||D||1
81161601|Servicio de administración de mensajería instantánea|O|O||D||1
81161700|Servicios de telecomunicaciones|O|O||D||1
81161701|Servicio de administración de fax|O|O||D||1
81161702|Servicio de soporte para fax|O|O||D||1
81161703|Servicio de administración de telefonía móvil|O|O||D||1|Servicio de administración de telefonía celular
81161704|Servicio de soporte para telefonía móvil|O|O||D||1|Servicio de soporte para telefonía celular
81161705|Servicio de administración de radiobúsquedas|O|O||D||1
81161706|Servicio de soporte para radiobúsquedas|O|O||D||1
81161707|Servicio de administración telefónica|O|O||D||1
81161708|Servicio de soporte telefónico|O|O||D||1
81161709|Servicio de administración del correo de voz|O|O||D||1
81161710|Servicios de soporte del correo de voz|O|O||D||1
81161711|Servicio de videoconferencias|O|O||D||1
81161712|Servicio de voz en la red|O|O||D||1
81161800|Servicios de alquiler o arrendamiento de equipos o plataformas de voz y datos o multimedia|O|O||D||1
81161801|Servicio de arriendo o leasing de plataformas o equipos de comunicación de datos|O|O||D||1|Servicios de renta o alquiler de plataformas o equipos de comunicación de datos
82101500|Publicidad impresa|O|O||D||1|Servicios de publicidad impresa
82101501|Publicidad en vallas|O|O||D||1|Servicios de publicidad en espectaculares
82101502|Publicidad en afiches|O|O||D||1|Servicios de publicidad en cartel, Servicios de publicidad en posters
82101503|Publicidad en revistas|O|O||D||1
82101504|Publicidad en periódicos|O|O||D||1
82101505|Publicidad en volantes o cupones|O|O||D||1|Servicios de publicidad en folletos o cupones
82101506|Servicios de publicidad en transporte público|O|O||D||1
82101507|Servicios de distribución o de publicidad o de boletines de sobre compras|O|O||D||1
82101508|Publicidad en páginas amarillas o en directorios comerciales o de servicios|O|O||D||1|Servicios de publicidad en páginas amarillas o en directorios comerciales o de servicios
82101600|Publicidad difundida|O|O||D||1|Servicios de publicidad difundida
82101601|Publicidad en radio|O|O||D||1|Servicios de publicidad en radio
82101602|Publicidad en televisión|O|O||D||1|Servicios de publicidad en televisión
82101603|Publicidad en internet|O|O||D||1|Servicios de publicidad en internet
82101604|Publicidad en los cines|O|O||D||1|Servicios de publicidad en cines
82101605|Servicio de producción de comerciales para televisión|O|O||D||1
82101700|Publicidad aérea|O|O||D||1|Servicios de publicidad aérea
82101701|Servicios de publicidad en pancartas|O|O||D||1|Servicios de publicidad en lonas
82101702|Servicios de publicidad aérea|O|O||D||1
82101800|Servicios de agencia de publicidad|O|O||D||1
82101801|Servicios de campañas publicitarias|O|O||D||1
82101802|Servicios de producción publicitaria|O|O||D||1
82101900|Colocación y cumplimiento de medios|O|O||D||1|Servicios de colocación y cumplimiento en medios
82101901|Inserción en radio|O|O||D||1|Servicios de colocación de publicidad en radio
82101902|Inserción en televisión|O|O||D||1|Servicios de colocación de publicidad en televisión
82101903|Inserción en internet|O|O||D||1|Servicios de colocación de publicidad en internet
82101904|Inserción en cines|O|O||D||1|Servicios de colocación de publicidad en cines
82101905|Inserción en medios impresos|O|O||D||1|Servicios de colocación de publicidad en medios impresos
82111500|Escritura técnica|O|O||D||1|Servicios de escritura técnica
82111501|Servicios de redacción  de instrucciones|O|O||D||1
82111502|Servicios de redacción de manuales|O|O||D||1|Servicios de elaboración de manuales
82111503|Redacción de artículos académicos o científicos|O|O||D||1
82111600|Escritura no técnica|O|O||D||1|Servicios de escritura no técnica
82111601|Servicios de redacción de cartas|O|O||D||1
82111602|Servicios de redacción del currículum vítae|O|O||D||1
82111603|Servicios de informes de tribunales|O|O||D||1
82111604|Servicios de transcripción|O|O||D||1
82111700|Escritura creativa|O|O||D||1|Servicios de escritura creativa
82111701|Servicios de escritores de artículos|O|O||D||1|Regalías por derechos de autor
82111702|Servicios de autores de libros|O|O||D||1|Regalías por derechos de autor
82111703|Servicios de autores de poesía|O|O||D||1|Regalías por derechos de autor
82111704|Escritura de textos publicitarios|O|O||D||1|Servicios de redactor creativo
82111705|Escritura de discursos|O|O||D||1
82111800|Servicios editoriales y de soporte|O|O||D||1
82111801|Servicios de edición|O|O||D||1
82111802|Servicios de comprobación de hechos|O|O||D||1|Servicios de verificación de hechos
82111803|Servicios de corrección de pruebas|O|O||D||1
82111804|Servicios de traducción escrita|O|O||D||1
82111900|Servicios de noticias y publicidad|O|O||D||1
82111901|Servicios de comunicados de prensa|O|O||D||1
82111902|Servicios de boletines informativos de interés especial|O|O||D||1
82111903|Servicios telegráficos de agencias de noticias|O|O||D||1
82111904|Servicios de entrega de periódicos o material  publicitario|O|O||D||1
82112000|Servicios de interpretación de idiomas de forma presencial|O|O||D||1|Servicios de traductores de idiomas
82112001|Servicio de interpretación en persona de afgano o pastún|O|O||D||1|Servicios de traductor en afgano o pastún
82112002|Servicio de interpretación en persona de albanés|O|O||D||1|Servicios de traductor en albanés
82112003|Servicio de interpretación en persona amárico|O|O||D||1|Servicios de traductor en amárico
82112004|Servicio de interpretación en persona de árabe|O|O||D||1|Servicios de traductor en árabe
82112005|Servicio de interpretación en persona de armenio|O|O||D||1|Servicios de traductor en armenio
82112006|Servicio de interpretación en persona de bangladés|O|O||D||1|Servicios de traductor en bangladés
82112007|Servicio de interpretación en persona de bielorruso|O|O||D||1|Servicios de traductor en bielorruso
82112008|Servicio de interpretación en persona de bengalí|O|O||D||1|Servicios de traductor en bengalí
82112009|Servicio de interpretación en persona de bosnio|O|O||D||1|Servicios de traductor en bosnio
82112010|Servicio de interpretación en persona de búlgaro|O|O||D||1|Servicios de traductor en búlgaro
82112011|Servicio de interpretación en persona de camboyano|O|O||D||1|Servicios de traductor en camboyano
82112012|Servicio de interpretación en persona de chino|O|O||D||1|Servicios de traductor en chino
82112013|Servicio de interpretación en persona de creole|O|O||D||1|Servicios de traductor en creole
82112014|Servicio de interpretación en persona de croata|O|O||D||1|Servicios de traductor en croata
82112015|Servicio de interpretación en persona de checo|O|O||D||1|Servicios de traductor en checo
82112016|Servicio de interpretación en persona de danés|O|O||D||1|Servicios de traductor en danés
82112017|Servicio de interpretación en persona de dinka|O|O||D||1|Servicios de traductor en dinka
82112018|Servicio de interpretación en persona de holandés|O|O||D||1|Servicios de traductor en holandés
82112019|Servicio de interpretación en persona de egipcio|O|O||D||1|Servicios de traductor en egipcio
82112020|Servicio de interpretación en persona de fanti|O|O||D||1|Servicios de traductor en fanti
82112021|Servicio de interpretación en persona de fanti o persa|O|O||D||1|Servicios de traductor en fanti o persa
82112022|Servicio de interpretación en persona de francés|O|O||D||1|Servicios de traductor en francés
82112023|Servicio de interpretación en persona de alemán|O|O||D||1|Servicios de traductor en alemán
82112024|Servicio de interpretación en persona de griego|O|O||D||1|Servicios de traductor en griego
82112025|Servicio de interpretación en persona de guyaratí|O|O||D||1|Servicios de traductor en guyaratí
82112026|Servicio de interpretación en persona de hebreo|O|O||D||1|Servicios de traductor en hebreo
82112027|Servicio de interpretación en persona de hindi|O|O||D||1|Servicios de traductor en hindi
82112028|Servicio de interpretación en persona de hmong|O|O||D||1|Servicios de traductor en hmong
82112029|Servicio de interpretación en persona de indoamericano|O|O||D||1|Servicios de traductor en indoamericano
82112030|Servicio de interpretación en persona de indonesio|O|O||D||1|Servicios de traductor en indonesio
82112031|Servicio de interpretación en persona de italiano|O|O||D||1|Servicios de traductor en italiano
82112032|Servicio de interpretación en persona de jamaiquino|O|O||D||1|Servicios de traductor en jamaiquino
82112033|Servicio de interpretación en persona de japonés|O|O||D||1|Servicios de traductor en japonés
82112034|Servicio de interpretación en persona de kirguís|O|O||D||1|Servicios de traductor en kirguís
82112035|Servicio de interpretación en persona de coreano|O|O||D||1|Servicios de traductor en coreano
82112036|Servicio de interpretación en persona de kurdo|O|O||D||1|Servicios de traductor en kurdo
82112037|Servicio de interpretación en persona de lituano|O|O||D||1|Servicios de traductor en lituano
82112038|Servicio de interpretación en persona de malayalam|O|O||D||1|Servicios de traductor en malayalam
82112039|Servicio de interpretación en persona de mandinga|O|O||D||1|Servicios de traductor en mandinga
82112040|Servicio de interpretación en persona de nativo americano|O|O||D||1|Servicios de traductor en nativo americano
82112041|Servicio de interpretación en persona de pakistaní|O|O||D||1|Servicios de traductor en pakistaní
82112042|Servicio de interpretación en persona de panyabí oriental|O|O||D||1|Servicios de traductor en panyabí oriental
82112043|Servicio de interpretación en persona de panyabí occidental|O|O||D||1|Servicios de traductor en panyabí occidental
82112044|Servicio de interpretación en persona de polaco|O|O||D||1|Servicios de traductor en polaco
82112045|Servicio de interpretación en persona de portugués|O|O||D||1|Servicios de traductor en portugués
82112046|Servicio de interpretación en persona de rumano|O|O||D||1|Servicios de traductor en rumano
82112047|Servicio de interpretación en persona de romaní|O|O||D||1|Servicios de traductor en romaní
82112048|Servicio de interpretación en persona de ruso|O|O||D||1|Servicios de traductor en ruso
82112049|Servicio de interpretación en persona de ruandés|O|O||D||1|Servicios de traductor en ruandés
82112050|Servicio de interpretación en persona de samoano|O|O||D||1|Servicios de traductor en samoano
82112051|Servicio de interpretación en persona de serbio|O|O||D||1|Servicios de traductor en serbio
82112052|Servicio de interpretación en persona de serbocroata|O|O||D||1|Servicios de traductor en serbocroata
82112053|Servicio de interpretación en persona de esloveno|O|O||D||1|Servicios de traductor en esloveno
82112054|Servicio de interpretación en persona de somalí|O|O||D||1|Servicios de traductor en somalí
82112055|Servicio de interpretación en persona de español|O|O||D||1|Servicios de traductor en español
82112056|Servicio de interpretación en persona de suajili|O|O||D||1|Servicios de traductor en suajili
82112057|Servicio de interpretación en persona de sueco|O|O||D||1|Servicios de traductor en sueco
82112058|Servicio de interpretación en persona de taiwanés|O|O||D||1|Servicios de traductor en taiwanés
82112059|Servicio de interpretación en persona de tailandés|O|O||D||1|Servicios de traductor en tailandés
82112060|Servicio de interpretación en persona de tibetano|O|O||D||1|Servicios de traductor en tibetano
82112061|Servicio de interpretación en persona de turco|O|O||D||1|Servicios de traductor en turco
82112062|Servicio de interpretación en persona de ucraniano|O|O||D||1|Servicios de traductor en ucraniano
82112063|Servicio de interpretación en persona de vietnamita|O|O||D||1|Servicios de traductor en vietnamita
82112064|Servicio de interpretación en persona de yidis|O|O||D||1|Servicios de traductor en yidis
82112065|Servicio de interpretación en persona de yugoslavo|O|O||D||1|Servicios de traductor en yugoslavo
82112066|Servicio de interpretación en persona de húngaro|O|O||D||1|Servicios de traductor en húngaro
82121500|Impresión|O|O||D||1
82121501|Planificación  y trazados de producciones gráficas|O|O||D||1
82121502|Tipografía|O|O||D||1
82121503|Impresión digital|O|O||D||1
82121504|Impresión tipográfica o por serigrafía|O|O||D||1
82121505|Impresión promocional o publicitaria|O|O||D||1
82121506|Impresión de publicaciones|O|O||D||1
82121507|Impresión de papelería o formularios comerciales|O|O||D||1
82121508|Impresión de envolturas, etiquetas, sellos o bolsas|O|O||D||1
82121509|Impresión de valores o instrumentos financieros|O|O||D||1
82121510|Impresión textil|O|O||D||1
82121511|Impresión de hoja de instrucciones o manual técnico|O|O||D||1
82121512|Impresión en relieve|O|O||D||1
82121600|Grabado|O|O||D||1
82121601|Grabado de monedas|O|O||D||1
82121602|Impresión de rollo grabado|O|O||D||1
82121603|Grabado de planchas metálicas|O|O||D||1
82121700|Fotocopiado|O|O||D||1
82121701|Servicios de copias en blanco y negro o de cotejo|O|O||D||1
82121702|Servicios de copias a color o de cotejo|O|O||D||1
82121800|Publicación|O|O||D||1
82121801|Publicación de libros de texto o de investigación|O|O||D||1
82121802|Servicios de publicaciones financiadas por el autor|O|O||D||1
82121900|Empaste de libros|O|O||D||1
82121901|Encuadernación en rústica|O|O||D||1
82121902|Encuadernación espiral|O|O||D||1|Servicios de engargolado
82121903|Encuadernación con pegante|O|O||D||1
82121904|Encuadernación por carda o grapa|O|O||D||1
82121905|Restauración o reparación de encuadernaciones|O|O||D||1|Restauración o reparación de engargolado
82121906|Bronceado o dorado o ribeteado o bordeado|O|O||D||1
82121907|Servicios de encuadernación en vitela|O|O||D||1
82121908|Servicios de fabricación de maletas|O|O||D||1
82131500|Servicios de procesado de películas|O|O||D||1
82131501|Elaboración o reproducción de película fija|O|O||D||1
82131502|Elaboración o reproducción de películas de cine|O|O||D||1
82131503|Servicios de microficha|O|O||D||1
82131504|Separación de colores|O|O||D||1
82131505|Servicio de posproducción de películas|O|O||D||1
82131600|Fotógrafos y cinematógrafos|O|O||D||1
82131601|Servicios de fotografía aérea|O|O||D||1
82131602|Cinematografía|O|O||D||1
82131603|Servicios de producción de vídeos|O|O||D||1
82131604|Servicios de estudio fotográfico  o fotos fijas|O|O||D||1
82141500|Servicios de diseño artístico|O|O||D||1
82141501|Servicios de redacción de gráficas y planes y trazados|O|O||D||1
82141502|Diseño o gráficos artísticos|O|O||D||1
82141503|Fotocomposición|O|O||D||1
82141504|Servicios de diseño de gráficos o gráficas|O|O||D||1
82141505|Servicios de diseño por computador|O|O||D||1
82141506|Servicios de diseño de empaques|O|O||D||1
82141507|Servicios de diseño de serigrafía|O|O||D||1
82141600|Servicios de exhibición gráfica|O|O||D||1
82141601|Servicios fotográficos, de montaje o enmarcado|O|O||D||1
82141602|Montaje de exposición de artículos|O|O||D||1|Desmontaje de exposición de artículos
82151500|Servicios de artes visuales|O|O||D||1
82151501|Servicios de pintores|O|O||D||1
82151502|Servicios de litógrafos|O|O||D||1
82151503|Servicios de caricaturistas|O|O||D||1
82151504|Servicios de escultores|O|O||D||1
82151505|Servicios de fabricantes de cerámica|O|O||D||1
82151506|Servicios de sopladores de vidrio|O|O||D||1
82151507|Servicios de hiladoras, telares o tejedoras|O|O||D||1
82151508|Servicios de taxidermia|O|O||D||1
82151600|Artistas de circo|O|O||D||1
82151601|Servicios de entrenadores de animales|O|O||D||1
82151602|Servicios de acróbatas|O|O||D||1
82151603|Servicios de magos|O|O||D||1
82151604|Servicios de payasos|O|O||D||1
82151700|Profesionales de las artes escénicas|O|O||D||1
82151701|Servicios de actuación|O|O||D||1
82151702|Servicios de comediantes|O|O||D||1
82151703|Servicios de bailarines|O|O||D||1
82151704|Servicios de músicos|O|O||D||1
82151705|Servicios de vocalistas|O|O||D||1
82151706|Servicios coreográficos|O|O||D||1
83101500|Servicios de acueducto y alcantarillado|O|O||D||1|Servicios de agua y alcantarillado
83101501|Abastecimiento de agua|O|O||D||1
83101502|Gestión de recursos hidráulicos|O|O||D||1
83101503|Gestión de control de la calidad del agua|O|O||D||1
83101504|Gestión de distribución del agua|O|O||D||1
83101505|Servicios de asesoramiento de política hidráulica|O|O||D||1
83101506|Servicios de tratamiento de aguas|O|O||D||1
83101507|Servicios de desalinización|O|O||D||1
83101508|Agua para la ciudad|O|O||D||1
83101509|Agua para servicios|O|O||D||1
83101510|Agua fría|O|O||D||1
83101600|Servicios de petróleo y gas|O|O||D||1
83101601|Suministro de gas natural|O|O||D||1
83101602|Suministro de fuel-oil|O|O||D||1
83101603|Servicios de oleoductos|O|O||D||1
83101604|Servicios de gasoductos|O|O||D||1
83101605|Carga de las instalaciones de gas|O|O||D||1
83101800|Servicios eléctricos|O|O||D||1
83101801|Suministro de electricidad monofásica|O|O||D||1
83101802|Suministro de electricidad bifásica|O|O||D||1
83101803|Suministro de electricidad  trifásica|O|O||D||1
83101804|Servicios de transmisión de energía eléctrica|O|O||D||1
83101805|Distribución de energía eléctrica industrial|O|O||D||1
83101806|Distribución de energía eléctrica rural|O|O||D||1
83101807|Distribución de energía eléctrica municipal|O|O||D||1
83101808|Monitoreo de la calidad de la energía|O|O||D||1
83101900|Conservación de energía|O|O||D||1
83101901|Programas de conservación de energía|O|O||D||1
83101902|Medidas de reducción de utilización de la energía|O|O||D||1
83101903|Calefacción del distrito|O|O||D||1
83111500|Comunicaciones telefónicas locales y de larga distancia|O|O||D||1
83111501|Servicio de telefonía local|O|O||D||1
83111502|Servicios telefónicos de larga distancia|O|O||D||1
83111503|Servicios de proveedores de teléfonos con pago|O|O||D||1
83111504|Servicios de tarjetas telefónicas prepagadas|O|O||D||1
83111505|Servicios de asistencia telefónica|O|O||D||1
83111506|Servicios de conferencia telefónica|O|O||D||1
83111507|Servicios de buró de central de llamadas ("call center")|O|O||D||1
83111508|Servicios de llamar sin pago (hacia el interior)|O|O||D||1
83111510|Servicio de respuesta de voz interactiva|O|O||D||1
83111511|Servicio de telecomunicaciones de retransmisión en trama|O|O||D||1
83111600|Servicios de comunicaciones móviles|O|O||D||1
83111601|Servicios en la red para mejorar las señales de telecomunicaciones|O|O||D||1
83111602|Servicios de sistemas de comunicación por satélite o terrestre|O|O||D||1
83111603|Servicios de telefonía celular|O|O||D||1
83111604|Servicios de radiobúsqueda|O|O||D||1
83111605|Leasing de segmentos de espacio|O|O||D||1
83111700|Servicios de facsímil y telégrafos|O|O||D||1
83111701|Servicios de transmisión por fax|O|O||D||1
83111702|Servicios de transmisión telegráfica|O|O||D||1
83111703|Servicios de transmisión por telex|O|O||D||1
83111800|Servicios de televisión|O|O||D||1
83111801|Servicios de televisión por cable|O|O||D||1
83111802|Servicios de televisión por circuito cerrado|O|O||D||1
83111803|Servicios de construcción o alquiler de antenas de televisión|O|O||D||1
83111804|Administración de emisoras de televisión|O|O||D||1
83111900|Servicios de radio|O|O||D||1
83111901|Administración de emisoras de radio|O|O||D||1
83111902|Servicios o redes de radioaficionados|O|O||D||1
83111903|Sistemas de radio de corto alcance|O|O||D||1
83111904|Servicios de estudios o equipos radiofónicos|O|O||D||1
83111905|Servicios bilaterales internacionales y líneas privadas internacionales arrendadas|O|O||D||1
83112200|Servicios mejorados de telecomunicaciones|O|O||D||1
83112201|Servicios de red en modo de transferencia asíncrona (atm)|O|O||D||1
83112202|Servicios de redes públicas de retransmisión de tramas|O|O||D||1
83112203|Servicios de redes gestionadas por redes  virtuales privadas (vpn)|O|O||D||1
83112204|Servicios de redes manejadas  x75|O|O||D||1
83112205|Servicios de redes manejadas x25|O|O||D||1
83112206|Servicio de administración de la capacidad del radio direccional para la recuperación de desastres|O|O||D||1
83112300|Servicios de telecomunicaciones por fibra|O|O||D||1
83112301|Fibra oscura|O|O||D||1
83112302|Multiplexado de división de la longitud de onda densa (dwdm)|O|O||D||1
83112303|Multiplexado de división de onda (wdm)|O|O||D||1
83112304|Servicios de transmisión óptica (ocx)|O|O||D||1
83112400|Servicios de telecomunicaciones de marcado conmutado y circuito de línea dedicada alquilada|O|O||D||1
83112401|Servicios de circuitos de conmutación automática de alta velocidad|O|O||D||1
83112402|Servicios de redes digitales de servicios integrados (isdn)|O|O||D||1
83112403|Circuitos de telecomunicaciones digitales punto a punto|O|O||D||1
83112404|Circuitos de telecomunicaciones analógicas multipunto|O|O||D||1
83112405|Circuitos de telecomunicaciones analógicas punto a punto|O|O||D||1
83112406|Línea digital de abonado (dsl)|O|O||D||1
83112500|Capacidades de eje troncal|O|O||D||1
83112501|Capacidad del cable submarino y capacidad pop a pop del cable submarino|O|O||D||1
83112502|Capacidades de eje troncal terrestre|O|O||D||1
83112503|Derechos de paso para el tránsito por sistemas de semicircuitos, procesamiento de datos distribuidos (ddp) y alquiler administrativo|O|O||D||1
83112504|Derechos no defendibles (iru) de utilización de sistemas de cables submarinos o terrestres|O|O||D||1
83112505|Funcionalidad de interconexión|O|O||D||1
83112506|Servicio de infraestructura técnica de la capacidad de soporte del radio direccional|O|O||D||1
83112600|Acceso de clientes|O|O||D||1|Accesos digitales para clientes
83112601|Capacidades de bucle local|O|O||D||1|Línea de suscripción digital (DSL)
83112602|Líneas domésticas alquiladas|O|O||D||1
83112603|Líneas de acceso internacional|O|O||D||1
83112604|Servicios de acceso de discado|O|O||D||1
83112605|Líneas internacionales externas|O|O||D||1
83112606|Servicio de acceso del cliente en la capacidad del radio direccional|O|O||D||1
83121500|Bibliotecas|O|O||D||1
83121501|Bibliotecas municipales para uso del público en general|O|O||D||1
83121502|Bibliotecas de universidades o colleges|O|O||D||1
83121503|Bibliotecas privadas|O|O||D||1
83121504|Bibliotecas gubernamentales o militares nacionales|O|O||D||1
83121600|Centros de información|O|O||D||1
83121601|Cámaras de comercio|O|O||D||1
83121602|Servicios de juntas de turismo|O|O||D||1
83121603|Sistemas de recuperación de la información computarizada|O|O||D||1
83121604|Sistemas de recuperación de la información de la base de datos en línea|O|O||D||1
83121605|Servicios de recuperación de información de la base de datos a distancia|O|O||D||1
83121606|Localización de saltos|O|O||D||1
83121700|Servicios de comunicación masiva|O|O||D||1
83121701|Servicios relacionados con la televisión|O|O||D||1
83121702|Servicios relacionados con la radio|O|O||D||1
83121703|Servicios relacionados con el internet|O|O||D||1
83121704|Sistemas de alerta ciudadana|O|O||D||1
84101500|Asistencia de desarrollo|O|O||D||1
84101501|Asistencia financiera|O|O||D||1
84101502|Programas de movilización de ahorros|O|O||D||1
84101503|Acuerdos de garantía|O|O||D||1
84101600|Financiación de ayudas|O|O||D||1|Ayuda financiera
84101601|Cofinanciación|O|O||D||1|Cofinanciamiento
84101602|Ayuda bilateral o multilateral|O|O||D||1|Donativos del extranjero
84101603|Ayuda no gubernamental|O|O||D||1|Donativos
84101604|Ayuda gubernamental|O|O||D||1|Programas gubernamentales de apoyo
84101700|Manejo de deuda|O|O||D||1|Intereses no provenientes del sistema financiero
84101701|Negociación de la deuda|O|O||D||1
84101702|Reorganización de la deuda|O|O||D||1|Reorganización de la deuda con intereses moratorios
84101703|Amortización de la deuda|O|O||D||1
84101704|Servicios de cobro de la deuda|O|O||D||1|Servicios de cobranza
84101705|Servicios de recuperación|O|O||D||1
84111500|Servicios contables|O|O||D||1|Honorarios contables
84111501|Servicio de contabilidad de costos|O|O||D||1
84111502|Servicio de contabilidad financiera|O|O||D||1
84111503|Servicio de contabilidad fiscal|O|O||D||1
84111504|Servicios de  teneduría de libros|O|O||D||1|Servicios de resguardo de contabilidad
84111505|Servicios de contabilidad de sueldos y salarios|O|O||D||1|Servicios de nómina
84111506|Servicios de facturación|O|O||D||1
84111507|Servicio de contabilidad de inventario|O|O||D||1
84111508|Servicio de administración de exportaciones  y de contabilidad|O|O||D||1
84111600|Servicios de auditoría|O|O||D||1|Honorarios contables
84111601|Auditorias de cierre del ejercicio|O|O||D||1
84111602|Revisiones trimestrales|O|O||D||1
84111603|Auditorias internas|O|O||D||1
84111700|Finanzas corporativas|O|O||D||1
84111701|Servicios de tesorería|O|O||D||1
84111702|Servicios o programas de relaciones de inversionistas|O|O||D||1
84111703|Servicios de preparación o revisión de presupuestos|O|O||D||1
84111800|Asuntos y preparación de impuestos|O|O||D||1
84111801|Gestores fiscales|O|O||D||1
84111802|Servicios de asesoría  fiscal|O|O||D||1|Servicios de consultoría fiscal
84121500|Instituciones bancarias|O|O||D||1
84121501|Bancos privados|O|O||D||1
84121502|Bancos públicos|O|O||D||1
84121503|Cooperativas de crédito|O|O||D||1
84121504|Instituciones financieras de fomento|O|O||D||1
84121600|Servicios de transferencia de fondos y canje y cambios|O|O||D||1
84121601|Servicios de compensación de fondos|O|O||D||1
84121602|Servicios de cartas de crédito|O|O||D||1
84121603|Servicios de cambio de divisas|Sí|O||D||1
84121604|Servicios de transacción de divisas al contado|Sí|O||D||1
84121605|Servicios de conversión de moneda|O|O||D||1
84121606|Servicios de procesamiento de remesas|O|O||D||1
84121607|Servicio financiero de alquiler de operaciones|O|O||D||1
84121700|Asesoría de inversiones|O|O||D||1
84121701|Asesores de inversiones|O|O||D||1
84121702|Política de inversiones|O|O||D||1
84121703|Análisis de inversiones|O|O||D||1
84121704|Acuerdos de inversiones|O|O||D||1
84121705|Datos del mercado|O|O||D||1
84121800|Servicios de mercados de títulos valores y commodities|O|O||D||1
84121801|Servicios de contratación bursátil|O|O||D||1
84121802|Servicios de mercados de productos básicos o de futuros|O|O||D||1
84121803|Bonos del estado|O|O||D||1
84121804|Bonos emitidos por el sector privado|O|O||D||1
84121805|Servicios de mercado de metales preciosos|O|O||D||1
84121806|Servicios de custodia de valores|O|O||D||1
84121900|Banca hipotecaria|O|O||D||1
84121901|Financiación de vivienda|O|O||D||1
84121902|Servicios de refinanciación|O|O||D||1
84121903|Financiación de hipotecas comerciales|O|O||D||1
84122000|Servicios de cajillas de seguridad|O|O||D||1
84122001|Servicios de verificación de depósitos|O|O||D||1
84131500|Servicios de seguros para estructuras y propiedades y posesiones|O|O||D||1
84131501|Seguros de edificios o del contenido de edificios|O|O||D||1
84131502|Seguros de propietarios de casa o rentistas|O|O||D||1
84131503|Seguro de automóviles o camiones|O|O||D||1
84131504|Seguros de carga|O|O||D||1
84131505|Seguros marítimos|O|O||D||1
84131506|Servicios de reaseguros|O|O||D||1
84131507|Seguro de interrupción de los procesos de negocios|O|O||D||1
84131508|Seguro de aportación de dinero durante el viaje|O|O||D||1
84131509|Seguro completo de proyectos|O|O||D||1
84131510|Seguro a todo riesgo para contratistas|O|O||D||1
84131511|Seguro de deterioro de valores|O|O||D||1
84131512|Seguro de equipos electrónicos|O|O||D||1
84131513|Seguro a todo riesgo de levantamientos|O|O||D||1
84131514|Seguro de garantía de fidelidad|O|O||D||1
84131515|Seguro colectivo de joyeros|O|O||D||1
84131516|Seguro de indemnización profesional|O|O||D||1
84131517|Seguro de viaje|O|O||D||1
84131601|Seguros de vida|O|O||D||1|Seguros personales
84131602|Seguros de asistencia médica y hospitalización|O|O||D||1|Seguros de gastos médicos mayores, Seguros de salud, Seguros personale
84131603|Seguros de daños personales por accidente|O|O||D||1|Seguros personales
84131604|Seguro de invalidez|O|O||D||1|Seguros laborales
84131605|Seguro de accidentes de trabajo|O|O||D||1|Seguros laborales
84131606|Seguros de desempleo|O|O||D||1|Seguros laborales
84131607|Seguro de responsabilidad civil|O|O||D||1|Seguros contra terceros
84131608|Administración y revisión de reclamos médicos|O|O||D||1|Seguros contra terceros
84131609|Programas de asistencia a empleados|O|O||D||1|Seguros laborales
84131610|Cuentas de gasto flexible (fsa)|O|O||D||1|Seguros personales
84131700|Fondos de pensiones|O|O||D||1
84131701|Fondos de pensiones administrados por el empleador|O|O||D||1
84131702|Fondos de pensiones administrados por sindicatos o gremios|O|O||D||1
84131801|Fondos de pensiones autodirigidos o patrocinados por el empleador|O|O||D||1|Planes privados de pensión
84131802|Planes de jubilación autodirigidos o de iniciativa propia|O|O||D||1|Planes privados de pensión
84141500|Agencias  de crédito gubernamental|O|O||D||1
84141501|Servicios de crédito agrícola|O|O||D||1
84141502|Entidades de préstamos para la pequeña empresa|O|O||D||1
84141503|Programas empresariales de propiedad minoritaria|O|O||D||1
84141600|Agencias de crédito personal|O|O||D||1|Agencias de crédito personal o monederos electrónicos
84141601|Servicios de recopilación o reporte de información para créditos al consumidor|O|O||D||1
84141602|Proveedores de servicios de tarjetas de crédito|O|O||D||1|Proveedores de servicios de tarjetas de crédito o monederos electrónicos
84141700|Agencias de crédito comercial|O|O||D||1
84141701|Servicios de recopilación de información  o reporte para créditos empresariales|O|O||D||1
84141702|Servicios de red de valor agregado (van)|O|O||D||1
85101501|Servicios hospitalarios de emergencia o quirúrgicos|O|O||D||1
85101502|Servicios clínicos especializados privados|O|O||D||1
85101503|Servicios de consultorios médicos|O|O||D||1|Servicios de sutura y curación
85101504|Servicios de hospitales siquiátricos|O|O||D||1
85101505|Servicios respiratorios hospitalarios|O|O||D||1
85101506|Servicios hospitalarios para el abuso de sustancias|O|O||D||1
85101507|Centros asistenciales de urgencia|O|O||D||1
85101508|Centros o servicios móviles de atención de salud|O|O||D||1
85101509|Servicios hospitalarios ginecológicos u obstétricos|O|O||D||1
85101601|Servicios de enfermería|O|O||D||1
85101602|Servicios de obstetricia o de preparación para el parto|O|O||D||1
85101603|Servicios de cuidados personal en instituciones especializadas|O|O||D||1
85101604|Servicios de asistencia de personal médico|O|O||D||1
85101605|Auxiliares de salud a domicilio|O|O||D||1
85101701|Política de salud|O|O||D||1
85101702|Legislación o regulaciones sobre salud|O|O||D||1
85101703|Planificación de servicios médicos|O|O||D||1
85101704|Economía de la salud|O|O||D||1
85101705|Administración de salud pública|O|O||D||1
85101706|Servicios tradicionales de la atención de salud|O|O||D||1
85101707|Servicios de evaluación de sistemas de salud|O|O||D||1
85111500|Prevención y control de enfermedades contagiosas|O|O||D||1
85111501|Servicios de prevención o control del sida|O|O||D||1
85111502|Servicios de prevención o control de enfermedades parasitarias|O|O||D||1
85111503|Servicios de prevención o control de enfermedades causadas por hongos|O|O||D||1
85111504|Servicios de prevención o control de la tuberculosis|O|O||D||1
85111505|Servicios de prevención o control de la lepra|O|O||D||1
85111506|Servicios de prevención o control de enfermedades bacterianas|O|O||D||1
85111507|Servicios de prevención o control de enfermedades de transmisión sexual|O|O||D||1
85111508|Servicios de prevención o control de enfermedades virales|O|O||D||1
85111509|Servicios de prevención o control de enfermedades zoonóticas|O|O||D||1
85111510|Servicios de vacunación|O|O||D||1
85111511|Servicios de cuarentena|O|O||D||1
85111512|Servicios de inmunización|O|O||D||1
85111513|Servicios de desinsectación|O|O||D||1
85111514|Servicios de prevención o control de epidemias|O|O||D||1
85111600|Prevención y control de enfermedades no contagiosas|O|O||D||1
85111601|Servicios de prevención o control de enfermedades óseas|O|O||D||1
85111602|Servicios de prevención o control de cáncer o leucemia|O|O||D||1
85111603|Servicios de prevención o control de enfermedades endocrinas|O|O||D||1
85111604|Servicios de prevención o control de enfermedades cardiovasculares|O|O||D||1
85111605|Servicios de prevención o control inmunológico|O|O||D||1
85111606|Servicios de prevención o control de alergias|O|O||D||1
85111607|Servicios de prevención o control de trastornos neurológicos|O|O||D||1
85111608|Servicios de prevención o control de enfermedades nutricionales|O|O||D||1
85111609|Servicios de prevención o control de la enfermedad por radiación|O|O||D||1
85111610|Servicios de prevención o control de enfermedades del sistema digestivo|O|O||D||1
85111611|Servicios de prevención o control de enfermedades oculares|O|O||D||1
85111612|Servicios de prevención o control de enfermedades respiratorias|O|O||D||1
85111613|Servicios de prevención o control de enfermedades tropicales|O|O||D||1
85111614|Servicios de prevención o control de enfermedades de la niñez|O|O||D||1
85111615|Servicios de prevención o control de enfermedades diarreicas|O|O||D||1
85111616|Servicios de prevención o control del alcoholismo|O|O||D||1
85111617|Servicios de prevención o control de la drogadicción|O|O||D||1
85111700|Manejo y control de vectores de enfermedad|O|O||D||1
85111701|Servicios de manejo o control de garrapatas|O|O||D||1
85111702|Servicios de manejo o control de la mosca tsé-tsé|O|O||D||1
85111703|Servicios de manejo o control de bacterias|O|O||D||1
85111704|Servicios de manejo o control de mosquitos|O|O||D||1
85121501|Servicios de atención domiciliaria por médicos de atención primaria|O|O||D||1
85121502|Servicios de consulta de médicos de atención primaria|O|O||D||1|Servicios de consulta médica
85121503|Servicios de control de médicos de atención primaria|O|O||D||1
85121504|Servicios médicos de emergencia de médicos de atención primaria|O|O||D||1
85121600|Servicios médicos de doctores especialistas|O|O||D||1|Honorarios médicos
85121601|Servicios de ginecología y obstetricia|O|O||D||1
85121602|Servicios de nefrología|O|O||D||1
85121603|Servicios de cardiología|O|O||D||1
85121604|Servicios de especialistas pulmonares|O|O||D||1
85121605|Servicios de gastroenterólogos|O|O||D||1
85121606|Servicios geriátricos|O|O||D||1
85121607|Servicios de siquiatras|O|O||D||1|Servicios de psiquiatras
85121608|Servicios de psicología|O|O||D||1|Honorarios de psicología
85121609|Servicios de  cirugía|O|O||D||1
85121610|Servicios de oftalmólogos|O|O||D||1
85121611|Servicios de dermatología|O|O||D||1
85121612|Servicios de ortopedia|O|O||D||1
85121613|Servicios pediátricos|O|O||D||1
85121614|Servicios de especialista del sistema nervioso|O|O||D||1
85121700|Servicios de prestadores especialistas de servicios de salud|O|O||D||1|Honorarios médicos
85121701|Servicios de psicoterapeutas|O|O||D||1|Servicios de psicoterapia
85121702|Servicios de optómetras|O|O||D||1
85121703|Servicios de podiatras|O|O||D||1
85121704|Servicios de logopedas|O|O||D||1
85121705|Servicios de acupuntura|O|O||D||1
85121706|Servicios quiroprácticos|O|O||D||1
85121800|Laboratorios médicos|O|O||D||1|Servicios de análisis clínicos
85121801|Servicios de laboratorios de análisis de sangre|O|O||D||1
85121802|Servicios de laboratorios bacteriológicos|O|O||D||1
85121803|Servicios de laboratorios biológicos|O|O||D||1
85121804|Servicios de laboratorios patológicos|O|O||D||1
85121805|Servicios de laboratorios de análisis de orina|O|O||D||1
85121806|Servicios de laboratorios neurológicos|O|O||D||1
85121807|Servicios de laboratorios de ultrasonido|O|O||D||1
85121808|Servicios de laboratorios de rayos x|O|O||D||1
85121809|Servicios de bancos de sangre, esperma u órganos de trasplante|O|O||D||1
85121810|Detección de drogas o alcohol|O|O||D||1
85121811|Servicios de laboratorios de detección del COVID|O|O||2020-12-29||1|Análisis clínicos, Pruebas para detección del SARS-CoV-2, Pruebas para detección del COVID, Pruebas para detección del COVID-19
85121900|Farmacéuticos|O|O||D||1
85121901|Servicios de preparación farmacéutica|O|O||D||1|Servicios de preparación de medicamentos homeopáticos
85121902|Servicios farmacéuticos comerciales|O|O||D||1
85122000|Servicios dentales|O|O||D||1|Honorarios médicos
85122001|Servicios de odontólogos|O|O||D||1|Servicios de dentistas
85122002|Servicios de higienistas dentales|O|O||D||1
85122003|Servicios de personal de apoyo odontológico|O|O||D||1
85122004|Servicios de cirujanos orales|O|O||D||1|Servicios de cirujanos maxilofaciales
85122005|Servicios de ortodoncia|O|O||D||1
85122100|Servicios de rehabilitación|O|O||D||1
85122101|Servicios de fisioterapia|O|O||D||1
85122102|Servicios de terapia ocupacional|O|O||D||1
85122103|Servicios de rehabilitación para el abuso de sustancias|O|O||D||1
85122104|Servicios de rehabilitación deportiva|O|O||D||1
85122105|Servicios de trastornos alimenticios|O|O||D||1
85122106|Servicios de lesiones cerebrales o de la médula espinal|O|O||D||1
85122107|Servicios de rehabilitación para personas invidentes o con problemas de vista|O|O||D||1
85122108|Terapia del habla o del lenguaje|O|O||D||1
85122109|Servicios de rehabilitación para personas con discapacidades crónicas|O|O||D||1
85122200|Servicios de evaluación y valoración de salud individual|O|O||D||1
85122201|Valoración del estado de salud individual|O|O||D||1
85131500|Servicios de medicina experimental|O|O||D||1
85131501|Servicios de trasplante de órganos|O|O||D||1
85131502|Ensayos clínicos de medicamentos de uso humano|O|O||D||1
85131503|Experimentación con animales|O|O||D||1
85131504|Experimentación con humanos|O|O||D||1
85131505|Experimentación espacial|O|O||D||1
85131600|Ética médica|O|O||D||1
85131602|Código de conducta médica|O|O||D||1
85131603|Sociedades médicas|O|O||D||1
85131604|Servicios internacionales de monitoreo de  medicamentos|O|O||D||1
85131700|Ciencia e investigación médica|O|O||D||1
85131701|Servicios de investigación farmacéutica|O|O||D||1
85131702|Servicios de investigación bacteriológica|O|O||D||1
85131703|Servicios de investigación biomédica|O|O||D||1
85131704|Servicios de investigación cardiológica|O|O||D||1
85131705|Servicios de investigación anatómica|O|O||D||1
85131706|Servicios de investigaciones patológicas|O|O||D||1
85131707|Servicios de investigación embriológica|O|O||D||1
85131708|Servicios de investigación epidemiológica|O|O||D||1
85131709|Servicios de investigación genética|O|O||D||1
85131710|Servicios de investigación inmunológica|O|O||D||1
85131711|Servicios de investigación fisiológica|O|O||D||1
85131712|Servicios de investigación toxicológica|O|O||D||1
85131713|Servicios de investigación neurológica|O|O||D||1
85141500|Curanderos|O|O||D||1
85141501|Servicios de hechiceros o vudús|O|O||D||1
85141502|Servicios de curanderos|O|O||D||1
85141503|Chamanes|O|O||D||1
85141504|Trabajo con la energía|O|O||D||1
85141600|Tratamientos herbales|O|O||D||1
85141601|Servicios de medicina herbolaria  o de herbolarios|O|O||D||1
85141602|Curas médicas con algas o algas marinas|O|O||D||1
85141603|Servicios de curas con fuentes termales|O|O||D||1
85141700|Práctica homeopática|O|O||D||1|Servicios médicos de homeopatía
85141701|Valoración del diagnóstico inicial|O|O||D||1
85141702|Consultas de remedios|O|O||D||1
85151500|Tecnología de alimentos|O|O||D||1
85151501|Servicios de control de la higiene de los alimentos|O|O||D||1
85151502|Servicios de control de la contaminación de alimentos|O|O||D||1
85151503|Servicios de gestión o control de la conservación de los alimentos|O|O||D||1
85151504|Servicios de asesoría o control en la  preparación de alimentos|O|O||D||1|Servicios de consultoría para el control en la preparación de alimentos
85151505|Servicios de investigación alimentaria|O|O||D||1
85151506|Estudios sobre alimentos o hábitos alimentarios|O|O||D||1
85151507|Servicios de estándares de calidad o aditivos alimentarios|O|O||D||1
85151508|Servicios de análisis de alimentos|O|O||D||1
85151600|Asuntos nutricionales|O|O||D||1
85151601|Servicios de programación de la nutrición|O|O||D||1
85151603|Servicios de rehabilitación nutricional|O|O||D||1
85151604|Evaluación de proyectos de nutrición|O|O||D||1
85151605|Estrategias de desarrollo alimentario o nutricional|O|O||D||1
85151607|Control o programas de dietas|O|O||D||1
85151700|Planeación y ayuda de política de alimentos|O|O||D||1
85161500|Reparación de equipo médico o quirúrgico|O|O||D||1
85161501|Mantenimiento o reparación de equipo médico mayor (capital)|O|O||D||1
85161502|Mantenimiento o reparación de equipo médico menor|O|O||D||1
85161503|Mantenimiento o reparación instrumental medico o quirúrgico|O|O||D||1
85161504|Acuerdo de servicios de equipos médicos o quirúrgicos|O|O||D||1
85161505|Tarifa de embarque y alquiler de equipo medico o quirúrgico o de implantes|O|O||D||1
85171500|Servicios funerarios y asociados|O|O||D||1
85171501|Excavación de tumbas|O|O||D||1
85171600|Cuidado en hospicios|O|O||D||1
85171601|Servicio de administración de hospicios|O|O||D||1
86101500|Servicios de entrenamiento en Agricultura y silvicultura y otros recursos naturales|O|O||D||1
86101501|Formación profesional para la agroindustria|O|O||D||1
86101502|Formación profesional para la industria láctea|O|O||D||1
86101503|Formación profesional para la industria cárnica|O|O||D||1
86101504|Servicios de formación profesional agrícola|O|O||D||1
86101505|Servicios de formación profesional para jóvenes rurales o granjeros|O|O||D||1
86101506|Servicios de formación profesional forestal|O|O||D||1
86101507|Servicios de formación profesional pesquera|O|O||D||1
86101508|Servicios de formación profesional ambiental|O|O||D||1
86101509|Servicios de formación profesional en recursos naturales|O|O||D||1
86101600|Servicios de capacitación vocacional científica|O|O||D||1
86101601|Servicios de formación profesional en informática|O|O||D||1
86101602|Servicios de formación profesional relacionada con la energía|O|O||D||1
86101603|Servicios de formación  profesional  en química|O|O||D||1
86101604|Servicios de formación  profesional en biología|O|O||D||1
86101605|Servicios de formación  profesional médica|O|O||D||1
86101606|Servicios de formación profesional en electrónica|O|O||D||1
86101607|Servicios de formación profesional en telecomunicaciones|O|O||D||1
86101608|Servicios de formación profesional en hidráulica|O|O||D||1
86101609|Servicios de formación profesional industrial|O|O||D||1
86101610|Servicios de formación profesional en ingeniería|O|O||D||1
86101700|Servicios de capacitación vocacional no - científica|O|O||D||1
86101701|Servicios de formación profesional en comunicaciones|O|O||D||1
86101702|Capacitación relacionada con el turismo|O|O||D||1
86101703|Capacitación sobre bibliotecas o documentación|O|O||D||1
86101704|Capacitación sobre cadenas de aprovisionamiento o suministro|O|O||D||1
86101705|Capacitación administrativa|O|O||D||1
86101706|Servicios de formación profesional en asistencia sanitaria|O|O||D||1
86101707|Servicios de formación profesional sobre cuidado personal|O|O||D||1
86101708|Servicios de alfabetización|O|O||D||1
86101709|Servicios de capacitación en seguridad|O|O||D||1
86101710|Servicios de formación pedagógica|O|O||D||1
86101711|Servicios de capacitación sobre la lucha contra incendios|O|O||D||1
86101712|Servicios de formación profesional en artesanías|O|O||D||1
86101713|Servicios de formación profesional en derecho|O|O||D||1
86101714|Servicios de formación profesional  en ejecución de la ley|O|O||D||1
86101715|Servicios de formación profesional en transporte por carretera o ferrocarril|O|O||D||1
86101716|Servicios de formación profesional en transporte marítimo|O|O||D||1
86101800|Entrenamiento en servicio y desarrollo de mano de obra|O|O||D||1
86101801|Formación de recursos humanos para el sector bancario o financiero|O|O||D||1
86101802|Servicios de capacitación en readiestramiento o repaso|O|O||D||1
86101803|Servicios de rehabilitación vocacional|O|O||D||1
86101804|Formación de recursos humanos para el sector  comercial|O|O||D||1
86101805|Formación de recursos humanos para el sector  industrial|O|O||D||1
86101806|Formación de recursos humanos para el sector de la salud|O|O||D||1
86101807|Formación de recursos humanos para el sector de gestión|O|O||D||1
86101808|Servicios de formación de recursos humanos para el sector  público|O|O||D||1
86101810|Capacitación en habilidades personales|O|O||D||1
86111500|Servicios de aprendizaje a distancia|O|O||D||1|Colegiaturas
86111501|Servicios de orientación para el aprendizaje a distancia|O|O||D||1
86111502|Servicios de enseñanza a distancia|O|O||D||1
86111503|Servicios de aprendizaje diplomado a distancia|O|O||D||1
86111504|Servicios de aprendizaje no diplomado a distancia|O|O||D||1
86111505|Servicios de evaluación del aprendizaje a distancia|O|O||D||1
86111600|Educación de adultos|O|O||D||1
86111601|Cursos nocturnos|O|O||D||1
86111602|Servicios de educación de tiempo parcial para adultos|O|O||D||1
86111603|Educación para padres|O|O||D||1
86111604|Educación para empleados|O|O||D||1
86111700|Educación de idiomas|O|O||D||1
86111701|Enseñanza de idiomas extranjeros basada en la conversación|O|O||D||1
86111702|Enseñanza de idiomas extranjeros por inmersión|O|O||D||1
86111800|Intercambios estudiantiles|O|O||D||1
86111801|Intercambios educativos entre universidades|O|O||D||1
86111802|Intercambios educativos entre escuelas|O|O||D||1
86121500|Escuelas preescolares, primarias y secundarias|O|O||D||1|Colegiaturas
86121501|Servicios educativos preescolares|O|O||D||1
86121502|Escuelas religiosas de educación primaria o secundaria|O|O||D||1
86121503|Escuelas privadas de educación primaria o secundaria|O|O||D||1
86121504|Escuelas públicas de educación primaria o secundaria|O|O||D||1
86121600|Bachillerato o profesional técnico|O|O||D||1|Colegiaturas
86121601|Bachillerato o equivalente|O|O||D||1
86121602|Profesional técnico|O|O||D||1
86121700|Universidades y politécnicos|O|O||D||1|Colegiaturas
86121701|Programas de pregrado|O|O||D||1
86121702|Programas de posgrado|O|O||D||1
86121800|Escuelas profesionales|O|O||D||1|Colegiaturas
86121802|Seminarios teológicos|O|O||D||1
86121803|Escuelas profesionales técnicas|O|O||D||1
86121804|Escuelas profesionales no técnicas|O|O||D||1
86131500|Bellas Artes|O|O||D||1
86131501|Estudios de teatro|O|O||D||1
86131502|Pintura|O|O||D||1
86131503|Esculturas|O|O||D||1
86131504|Estudios de medios de comunicación|O|O||D||1
86131600|Música y drama|O|O||D||1|Renta o alquiler de instrumentos musicales
86131601|Escuelas de música|O|O||D||1
86131602|Educación en baile|O|O||D||1
86131603|Estudios de arte dramático|O|O||D||1
86131700|Conducción de vehículos, buques y aeronaves|O|O||D||1
86131701|Servicios de escuelas de enseñanza automovilística|O|O||D||1
86131702|Servicios de escuelas de aviación|O|O||D||1
86131703|Servicios de escuelas náuticas de yates y veleros|O|O||D||1
86131800|Educación militar|O|O||D||1
86131900|Escuelas para gente con discapacidades|O|O||D||1|Colegiaturas
86131901|Servicios de escolarización primaria para personas discapacitadas|O|O||D||1
86131902|Servicios de escolarización secundaria para personas discapacitadas|O|O||D||1
86131903|Escuelas especializadas para personas discapacitadas|O|O||D||1
86131904|Servicios de rehabilitación especializados para personas discapacitadas|O|O||D||1
86132000|Servicios de educación y capacitación en administración|O|O||D||1
86132001|Servicio de entrenamiento (coaching) ejecutivo|O|O||D||1
86141500|Servicios de guía educativa|O|O||D||1|Honorarios de profesores o catedráticos
86141501|Servicios de asesorías educativas|O|O||D||1|Servicios de profesores particulares
86141502|Servicios de orientación para la cooperación  universitaria|O|O||D||1
86141503|Servicios de asesoría para estudios en el extranjero|O|O||D||1
86141600|Organizaciones de estudiantes|O|O||D||1
86141601|Clubes de ocio para estudiantes|O|O||D||1
86141602|Sindicatos de estudiantes|O|O||D||1
86141603|Organizaciones para viajes de estudiantes|O|O||D||1
86141700|Tecnología educacional|O|O||D||1
86141701|Laboratorios de idiomas|O|O||D||1
86141702|Tecnología audiovisual|O|O||D||1
86141703|Instrucción programada asistida por computador|O|O||D||1|Instrucción programada asistida por computadora
86141704|Servicios de biblioteca o documentación|O|O||D||1|Servicios bibliotecarios y de archivística
90101500|Establecimientos para comer y beber|O|O||D||1|Consumo de alimentos y bebidas
90101501|Restaurantes|O|O||D||1
90101502|Bares|O|O||D||1|Consumo de bebidas alcohólicas
90101503|Establecimientos de comida rápida|O|O||D||1
90101504|Vendedores callejeros de alimentos|O|O||D||1|Alitas de pollo preparadas y demás menudencia, Antojitos mexicanos, Bebidas alcohólicas y no alcohólicas preparadas, Dulces y botanas preparadas, Elotes y esquites, Gelatinas y flanes, Hamburguesas, hot dogs y sincronizadas, Hot cakes y otros postres, Tacos y tortas, Tamales, atole y café, Vasos de fruta preparados, , Hamburguesas, hot dogs y sincronizadas
90101600|Servicios de banquetes y catering|O|O||D||1
90101601|Instalaciones para banquetes|O|O||D||1
90101602|Servicios de carpas para fiestas|O|O||D||1
90101603|Servicios de cáterin|O|O||D||1
90101604|Servicios de cáterin en la obra o lugar de trabajo|O|O||D||1
90101700|Servicios de cafetería|O|O||D||1
90101701|Administración de cafeterías al pie de obra|O|O||D||1
90101800|Servicios de comida para llevar y a domicilio|O|O||D||1
90101801|Comidas para llevar preparadas profesionalmente|O|O||D||1
90101802|Servicios de comidas a domicilio|O|O||D||1
90111500|Hoteles y moteles y pensiones|O|O||D||1
90111501|Hoteles|O|O||D||1
90111502|Posadas o centros turísticos|O|O||D||1
90111503|Hospedajes de cama y desayuno|O|O||D||1
90111504|Servicios de alquiler de cabañas|O|O||D||1
90111600|Facilidades para encuentros|O|O||D||1
90111601|Centros de conferencias|O|O||D||1
90111602|Instalaciones para videoconferencias|O|O||D||1
90111603|Salas de reuniones o banquetes|O|O||D||1
90111604|Marquesinas|O|O||D||1
90111700|Facilidades para acampar|O|O||D||1|Instalaciones para acampar
90111701|Campin|O|O||D||1|Campamentos
90111702|Parques nacionales|O|O||D||1
90111703|Instalaciones de campin para vehículos recreativos|O|O||D||1|Instalaciones para acampar con vehículos
90111800|Cuartos de hotel|O|O||D||1
90111801|Habitación sencilla|O|O||D||1
90111802|Habitación doble|O|O||D||1
90111803|Suite|O|O||D||1
90121500|Agentes de viajes|O|O||D||1
90121501|Servicios de organización de excursiones|O|O||D||1
90121502|Agencias de viajes|O|O||D||1
90121503|Servicios de fletamento|O|O||D||1
90121600|Asistencia en documentos de viajes|O|O||D||1
90121601|Servicios de pasaportes|O|O||D||1
90121602|Servicios de visas o de documentos complementarios|O|O||D||1
90121603|Servicio de verificación de tiquetes de pasajeros|O|O||D||1|Servicio de verificación de pases de abordar
90121700|Guías e intérpretes|O|O||D||1
90121701|Guías locales o de excursiones|O|O||D||1
90121702|Intérpretes|O|O||D||1
90121800|Servicios de asistencia de emergencia en viajes|O|O||D||1
90121801|Asistencia de las agencias de viaje para emergencias|O|O||D||1
90131500|Actuaciones en vivo|O|O||D||1
90131501|Actuaciones u obras teatrales|O|O||D||1
90131502|Actuaciones de danza|O|O||D||1
90131503|Ópera|O|O||D||1
90131504|Conciertos|O|O||D||1
90131600|Actuaciones grabadas o películas|O|O||D||1
90131601|Películas cinematográficas|O|O||D||1
90131602|Entretenimiento grabado en video|O|O||D||1
90131603|Servicio de distribución de cine|O|O||D||1
90141500|Eventos profesionales deportivos|O|O||D||1
90141501|Juego de liga|O|O||D||1
90141502|Eventos competitivos|O|O||D||1
90141503|Exposiciones|O|O||D||1
90141600|Promoción y patrocinio de eventos deportivos|O|O||D||1
90141601|Eventos deportivos profesionales patrocinados por empresas|O|O||D||1
90141602|Eventos deportivos aficionados patrocinados por empresas|O|O||D||1
90141603|Servicios de promoción de eventos deportivos|O|O||D||1
90141700|Deportes aficionados y recreacionales|O|O||D||1
90141701|Ligas deportivas juveniles de competencias|O|O||D||1
90141702|Ligas deportivas de adultos|O|O||D||1
90141703|Deportes juveniles|O|O||D||1
90151500|Atracciones turísticas|O|O||D||1
90151501|Museos|O|O||D||1
90151502|Lugares históricos o culturales|O|O||D||1
90151503|Parques zoológicos|O|O||D||1
90151600|Shows viajeros|O|O||D||1
90151601|Circos|O|O||D||1
90151602|Empresas de excursiones turísticas|O|O||D||1
90151603|Exposiciones de arte|O|O||D||1
90151700|Parques de diversiones|O|O||D||1
90151701|Parques temáticos|O|O||D||1
90151702|Parques acuáticos|O|O||D||1
90151703|Campos de minigolf|O|O||D||1
90151800|Carnavales y ferias|O|O||D||1
90151801|Carnavales ambulantes|O|O||D||1
90151802|Servicios de organización o administración de ferias|O|O||D||1
90151803|Construcción o creación de pabellones de feria|O|O||D||1
90151900|Establecimientos de Juegos de azar y de apuestas|O|O||D||1
90151901|Casinos|O|O||D||1
90151902|Clubes de cartas|O|O||D||1
90151903|Hipódromos|O|O||D||1
90152000|Clubes nocturnos y salones de baile|O|O||D||1
90152001|Clubes nocturnos|O|O||D||1
90152002|Salones de baile|O|O||D||1
90152100|Servicios de conserjería|O|O||D||1
90152101|Servicios de asistencia personal|O|O||D||1
91101500|Facilidades de spa y ejercicios y rejuvenecimiento|O|O||D||1
91101501|Gimnasios o centros de salud|O|O||D||1
91101502|Spas|O|O||D||1
91101503|Servicios de masajes|O|O||D||1
91101504|Clases de aeróbicos o ejercicios|O|O||D||1
91101505|Baños turcos o de vapor o rituales|O|O||D||1
91101600|Cuidado facial y corporal|O|O||D||1
91101601|Tratamientos faciales o corporales|O|O||D||1
91101602|Consulta de maquillaje|O|O||D||1
91101603|Servicios de tatuajes|O|O||D||1
91101604|Servicios de pirsin corporal|O|O||D||1
91101605|Electrólisis|O|O||D||1
91101700|Cuidado del pelo|O|O||D||1
91101701|Servicios de corte y tinte de pelo|O|O||D||1
91101702|Servicios de extensiones o reemplazo de cabello|O|O||D||1
91101800|Alquiler de ropa|O|O||D||1
91101801|Alquiler de esmóquines o trajes de etiqueta|O|O||D||1
91101802|Alquiler de vestidos o  trajes de noche o de novia|O|O||D||1
91101803|Alquiler de disfraces|O|O||D||1
91101900|Consultores de modas|O|O||D||1|Servicios de diseños de moda y otros diseños especializados
91101901|Asesor de colores|O|O||D||1
91101902|Estilista de moda|O|O||D||1
91101903|Asesor de vestuario|O|O||D||1
91101904|Servicio de sastrería|O|O||D||1
91111500|Servicios de lavandería|O|O||D||1
91111501|Alquiler de uniformes|O|O||D||1
91111502|Servicios de lavandería|O|O||D||1
91111503|Lavado en seco|O|O||D||1
91111504|Lavandería de autoservicio operadas con monedas|O|O||D||1
91111600|Asistencia y cuidado del hogar|O|O||D||1|Servicios de cerrajería
91111601|Servicios de ama de llaves|O|O||D||1
91111602|Servicios de cuidado de patios o piscinas|O|O||D||1
91111603|Servicios de cocina o preparación de comidas|O|O||D||1|Servicios de cocineros domésticos
91111700|Servicios de compra y trueque de consumo|O|O||D||1
91111701|Servicios de envío de ropa usada|O|O||D||1
91111703|Servicios de compra de vestuario|O|O||D||1|Renta o alquiler de vestuario
91111800|Cuidado y almacenamiento de ítems personales|O|O||D||1|Cuidado y almacenamiento de artículos personales
91111801|Servicios de valet|O|O||D||1
91111803|Alquiler de casilleros|O|O||D||1|Renta de casilleros, Servicios de paquetería
91111900|Servicios de cuidado temporal|O|O||D||1
91111901|Servicios de guardería para niños o bebés|O|O||D||1|Servicios de estancias infantiles
91111902|Servicios de niñera o cuidado de niños|O|O||D||1
91111903|Servicios asistenciales diurnos para  ancianos|O|O||D||1
91111904|Servicios de vivienda asistida|O|O||D||1
92101500|Servicios de policía|O|O||D||1
92101501|Servicios de vigilancia|O|O||D||1
92101503|Programas de ayuda a la comunidad|O|O||D||1
92101504|Programas para la disuasión de delitos|O|O||D||1
92101600|Servicios de bomberos|O|O||D||1
92101601|Servicios contra incendios municipales o nacionales|O|O||D||1
92101602|Servicios de cuerpos de bomberos voluntarios|O|O||D||1
92101603|Servicios para la  prevención de incendios|O|O||D||1
92101604|Servicios contra incendios en bosques o tierras vírgenes|O|O||D||1
92101700|Sistemas de cárceles y prisiones|O|O||D||1
92101800|Sistemas judiciales|O|O||D||1
92101804|Multas u honorarios de procesos penales|O|O||D||1
92101900|Servicios de rescate|O|O||D||1
92101901|Equipos de búsqueda y salvamento|O|O||D||1
92101902|Servicios de ambulancia|O|O||D||1
92101903|Servicios de helicópteros de salvamento|O|O||D||1
92101904|Servicios de salvavidas para piscina o playa|O|O||D||1
92111800|Personal y disciplina militar|O|O||D||1
92121500|Servicios de guardias|O|O||D||1
92121502|Servicios de protección contra robos|O|O||D||1
92121503|Alquiler de perros guardianes|O|O||D||1
92121504|Servicios de guardas de seguridad|O|O||D||1|Servicios de seguridad privada, Servicios de vigilencia
92121600|Servicios de detectives|O|O||D||1
92121601|Agencias de detectives|O|O||D||1
92121602|Servicios de huellas dactilares|O|O||D||1
92121603|Servicios de detección de mentiras|O|O||D||1
92121604|Servicios de investigación privada|O|O||D||1
92121700|Servicios de sistemas de seguridad|O|O||D||1
92121701|Vigilancia o mantenimiento o monitoreo de alarmas|O|O||D||1
92121702|Mantenimiento o monitoreo de alarmas contra incendios|O|O||D||1
92121703|Servicios antirrobo para  tiendas o empresas|O|O||D||1
92121704|Mantenimiento o monitoreo de sistemas de vigilancia de confinamiento|O|O||D||1
92121800|Servicios de Carros blindados y transporte de valores|O|O||D||1
92121801|Servicio de carros blindados|O|O||D||1
92121802|Servicio de transporte de dinero|O|O||D||1
92121803|Servicio de almacenamiento de dinero|O|O||D||1
92121900|Servicios de seguridad marina|O|O||D||1
92121901|Servicio de botes de seguridad|O|O||D||1
93101500|Cuerpos políticos|O|O||D||1
93101501|Servicios de representación de partidos políticos|O|O||D||1
93121500|Diplomacia|O|O||D||1
93121503|Servicios de seguridad para diplomáticos|O|O||D||1
93121600|Relaciones internacionales y cooperación|O|O||D||1
93121608|Servicio de enlace con organizaciones no gubernamentales|O|O||D||1
93121700|Organizaciones internacionales|O|O||D||1
93131500|Programas de refugiados|O|O||D||1
93131501|Servicios de protección de los derechos humanos|O|O||D||1
93131502|Servicios de promoción de los derechos humanos|O|O||D||1
93131503|Servicios de educación o divulgación de información sobre derechos humanos|O|O||D||1
93131504|Servicios de asistencia de emergencia a refugiados|O|O||D||1
93131505|Servicios de campos de refugiados|O|O||D||1
93131506|Servicios de reasentamientos o repatriación de refugiados|O|O||D||1
93131507|Servicios de asistencia a desplazados|O|O||D||1
93131600|Planeación y programas de políticas de alimentación y nutrición|O|O||D||1
93131601|Programas de erradicación del hambre|O|O||D||1
93131602|Servicios de suministro de alimentos de emergencia|O|O||D||1
93131603|Servicios del programa mundial de alimentos|O|O||D||1
93131604|Servicios de la organización para la  alimentación y la agricultura|O|O||D||1
93131605|Servicios del fondo común para los  productos básicos|O|O||D||1
93131606|Servicios del fondo internacional para el desarrollo agrícola|O|O||D||1
93131607|Servicios de distribución de alimentos|O|O||D||1
93131608|Servicios de suministro de alimentos|O|O||D||1
93131609|Políticas o programas de ayuda alimentaría|O|O||D||1
93131610|Servicios de planificación de alimentos|O|O||D||1
93131611|Servicios de seguridad alimentaria|O|O||D||1
93131612|Administración de reservas alimentarias|O|O||D||1
93131613|Servicios de control o  administración de excedentes o escasez de alimentos|O|O||D||1
93131700|Programas de salud|O|O||D||1
93131701|Campañas contra el tabaco|O|O||D||1
93131702|Programas de sanidad|O|O||D||1
93131703|Programas de investigación|O|O||D||1
93131704|Servicios de prevención o control de enfermedades|O|O||D||1
93131705|Programas de prevención o control de abuso de drogas|O|O||D||1
93131800|Preparación y alivio de desastres|O|O||D||1
93131801|Servicios de prevención de desastres|O|O||D||1
93131802|Servicios de respuesta contra desastres|O|O||D||1
93131803|Servicios de viviendas de emergencia|O|O||D||1
93141500|Desarrollo y servicios sociales|O|O||D||1
93141504|Servicios de cuidado en hogares adoptivos u orfanatos|O|O||D||1
93141505|Servicios de adopción|O|O||D||1
93141510|Estudios de estructura sociales o servicios relacionados|O|O||D||1
93141511|Estudios de grupos sociales o servicios relacionados|O|O||D||1
93141514|Servicios socioculturales|O|O||D||1
93141600|Población|O|O||D||1
93141601|Servicios de censo de la población|O|O||D||1
93141602|Servicios de estudios de muestras de población|O|O||D||1
93141605|Servicios de tendencias o proyecciones de la población|O|O||D||1
93141606|Servicios de estadísticas de natalidad|O|O||D||1
93141608|Servicios de distribución o análisis de la población|O|O||D||1
93141609|Servicios de análisis de la composición de la población|O|O||D||1
93141610|Estudios demográficos|O|O||D||1
93141700|Cultura|O|O||D||1
93141701|Organizaciones de eventos culturales|O|O||D||1
93141702|Servicios de promoción cultural|O|O||D||1
93141703|Servicios relacionados con el arte|O|O||D||1|Artesanías y obras de arte, Servicios de restauración de obras de arte y artesanías
93141704|Servicios de composición de canciones|O|O||D||1
93141705|Servicios de redacción literaria|O|O||D||1
93141706|Servicios de protección de minorías|O|O||D||1
93141707|Servicios de preservación o  promoción del patrimonio cultural|O|O||D||1
93141708|Servicios de museos|O|O||D||1
93141709|Servicios de política cultural|O|O||D||1
93141710|Servicios de lenguas arcaicas o indígenas|O|O||D||1
93141711|Servicios de promoción de artesanías tradicionales|O|O||D||1
93141712|Servicios de protección de la propiedad intelectual o cultural|O|O||D||1
93141713|Servicios de protección de sitios históricos o monumentos|O|O||D||1
93141714|Mitología|O|O||D||1
93141800|Empleo|O|O||D||1
93141801|Servicios de promoción o planificación del empleo|O|O||D||1
93141802|Servicios de reclutamiento|O|O||D||1
93141803|Servicios de estándares laborales internacionales|O|O||D||1
93141804|Servicios de registros laborales internacionales|O|O||D||1
93141806|Servicios de estadísticas o predicciones del empleo|O|O||D||1
93141808|Servicios de seguridad o salud ocupacional|O|O||D||1
93141810|Servicios de perspectivas de desarrollo profesional|O|O||D||1
93141811|Servicios de promoción|O|O||D||1
93141812|Servicios de inspección laboral|O|O||D||1
93141813|Servicios del consejo del trabajo|O|O||D||1
93141814|Servicios laborales internacionales|O|O||D||1
93141900|Desarrollo rural|O|O||D||1
93141901|Servicios bancarios comerciales agrícolas|O|O||D||1
93141902|Servicios de inversión rural|O|O||D||1
93141903|Servicios de organización o gestión de instituciones agrícolas|O|O||D||1
93141904|Servicios de cooperativas agrícolas o rurales|O|O||D||1
93141905|Servicios de investigación agrícola|O|O||D||1
93141906|Servicios de organizaciones de agricultores o campesinos|O|O||D||1
93141909|Servicios de administración de la tierra|O|O||D||1
93141910|Servicios para el desarrollo insular|O|O||D||1
93142000|Desarrollo urbano|O|O||D||1
93142001|Servicios de planificación de la ordenación urbana|O|O||D||1
93142002|Servicios de administración de tierras urbanas|O|O||D||1
93142003|Servicios de programación de inversiones urbanas|O|O||D||1
93142004|Servicios de reestructuración de  barrios marginales|O|O||D||1
93142005|Servicios de alumbrado urbano|O|O||D||1
93142006|Servicios de control o regulación del desarrollo urbano|O|O||D||1
93142007|Servicios de estándares o regulación de edificios urbanos|O|O||D||1
93142008|Servicios comunitarios urbanos|O|O||D||1
93142009|Servicios de administración o gestión de proyectos o programas urbanos|O|O||D||1
93142100|Desarrollo regional|O|O||D||1
93142101|Servicios de planificación de desarrollo regional|O|O||D||1
93142102|Servicios de cooperación económica|O|O||D||1
93142103|Servicios de cooperación técnica|O|O||D||1
93142104|Servicios de planificación sectorial|O|O||D||1
93151500|Administración pública|O|O||D||1
93151501|Servicios financieros o de  gestión  administrativa de empresas  públicas|O|O||D||1
93151502|Servicios de sistemas de información o control de empresas públicas|O|O||D||1
93151512|Servicios de instituciones públicas|O|O||D||1
93151516|Permiso de construcción|O|O||D||1
93151600|Finanzas públicas|O|O||D||1
93151608|Servicios bancarios gubernamentales o centrales|O|O||D||1
93151609|Servicios de loterías|O|O||D||1|Billetes de lotería impresos o electrónicos
93151611|Subsidios|O|O||D||1
93161500|Impuesto de renta|O|O||D||1
93161501|Impuesto nacional sobre la renta|O|O||D||1
93161502|Impuesto municipal sobre la renta|O|O||D||1
93161503|Impuesto sobre el incremento de capital|O|O||D||1
93161504|Impuesto sobre beneficios extraordinarios|O|O||D||1
93161600|Impuestos distintos del impuesto de renta|O|O||D||1
93161601|Impuesto sobre los bienes|O|O||D||1
93161602|Impuesto sobre la tierra|O|O||D||1
93161603|Impuesto al valor agregado (iva)|O|O||D||1
93161604|Impuesto sobre nóminas|O|O||D||1
93161605|Impuesto sobre las ventas|O|O||D||1
93161606|Impuesto de seguridad social|O|O||D||1
93161607|Impuesto a la sucesión o sobre transferencia de propiedad|O|O||D||1
93161608|Derechos o impuestos aduaneros|O|O||D||1
93161609|Arancel o tarifa|O|O||D||1
93161700|Administración tributaria|O|O||D||1
93161702|Incentivos tributarios|O|O||D||1
93161800|Temas tributarios|O|O||D||1
93161803|Investigación tributaria|O|O||D||1
93161804|Crédito fiscal de inversión|O|O||D||1
93171500|Política comercial|O|O||D||1
93171501|Acuerdos comerciales|O|O||D||1
93171502|Negociaciones comerciales|O|O||D||1
93171503|Formulación de políticas nacionales de productos básicos|O|O||D||1
93171504|Desarrollo de pequeñas industrias|O|O||D||1
93171600|Comercio internacional|O|O||D||1
93171700|Administración y cumplimiento aduanero|O|O||D||1
93171701|Convenciones aduaneras|O|O||D||1
93171702|Trámites aduaneros|O|O||D||1
93171800|Análisis de comercio|O|O||D||1
93171801|Proyecciones comerciales|O|O||D||1
93171802|Proyecciones de la balanza comercial|O|O||D||1
93171803|Estadísticas comerciales|O|O||D||1
94101500|Asociaciones de negocios|O|O||D||1|Agrupaciones y cámaras representativas
94101501|Asociaciones de la industria agrícola|O|O||D||1
94101502|Asociaciones reguladoras|O|O||D||1
94101503|Asociaciones empresariales sectoriales|O|O||D||1
94101504|Asociaciones empresariales internacionales|O|O||D||1
94101505|Asociaciones de empleadores|O|O||D||1
94101600|Asociaciones profesionales|O|O||D||1|Agrupaciones y colegios de profesionistas
94101601|Asociaciones de odontólogos|O|O||D||1
94101602|Asociaciones de médicos|O|O||D||1
94101603|Asociaciones de enfermeras|O|O||D||1
94101604|Asociaciones de contadores|O|O||D||1
94101605|Asociaciones de arquitectos|O|O||D||1
94101606|Colegios de abogados|O|O||D||1
94101607|Asociaciones educativas o de profesores|O|O||D||1
94101608|Asociaciones de ingenieros|O|O||D||1
94101609|Asociaciones científicas|O|O||D||1
94101610|Juntas de revisión de estándares profesionales|O|O||D||1
94101700|Asociaciones de personal|O|O||D||1
94101701|Clubes de ocio del personal|O|O||D||1
94101702|Asociaciones deportivas del personal|O|O||D||1
94101703|Asociaciones de personal femenino|O|O||D||1
94101704|Asociaciones de personal pensionado|O|O||D||1
94101705|Asociaciones de personal administrativo|O|O||D||1
94101800|Sindicatos|O|O||D||1
94101801|Sindicatos de obreros o trabajadores generales|O|O||D||1
94111700|Residencias religiosas|O|O||D||1
94111701|Residencias religiosas privadas|O|O||D||1
94111702|Residencias de comunidades religiosas|O|O||D||1
94111703|Residencias para retiros religiosos|O|O||D||1
94111704|Residencias religiosas temporales|O|O||D||1
94111800|Organizaciones y servicios de peregrinaje|O|O||D||1
94111801|Organizaciones o servicios de peregrinaje a la meca|O|O||D||1
94111802|Organizaciones o servicios de peregrinaje al vaticano|O|O||D||1
94111803|Servicios de asistencia para viajes de peregrinaje|O|O||D||1
94111804|Servicios de operadores turísticos de peregrinaje|O|O||D||1
94111900|Servicios misioneros|O|O||D||1
94111901|Servicios de órdenes religiosas|O|O||D||1
94111902|Servicios de misioneros evangélicos|O|O||D||1
94111903|Servicios misioneros educativos|O|O||D||1
94112000|Servicios confesionarios|O|O||D||1
94112001|Servicios relacionados con el hinduismo|O|O||D||1
94112002|Servicios relacionados con el budismo|O|O||D||1
94112003|Servicios relacionados con el cristianismo|O|O||D||1
94112004|Servicios relacionados con el islamismo|O|O||D||1
94112005|Servicios relacionados con el judaísmo|O|O||D||1
94121500|Clubes deportivos|O|O||D||1
94121501|Clubes de deportes en hielo|O|O||D||1
94121502|Clubes deportivos de vela o natación|O|O||D||1
94121503|Clubes deportivos de caza o tiro|O|O||D||1
94121504|Clubes deportivos de campos al aire libre|O|O||D||1
94121505|Clubes deportivos de canchas cubiertas o al aire libre|O|O||D||1
94121506|Clubes deportivos de invierno|O|O||D||1
94121507|Clubes deportivos de playa o acuáticos|O|O||D||1
94121508|Clubes deportivos de ciclismo|O|O||D||1
94121509|Clubes deportivos de montañismo|O|O||D||1
94121510|Clubes deportivos de carreras|O|O||D||1
94121511|Clubes deportivos de vuelo|O|O||D||1
94121512|Clubes deportivos profesionales o semiprofesionales|O|O||D||1
94121513|Servicios de operadores de eventos en estadios|O|O||D||1
94121514|Servicios de promotores o directores técnicos de clubes deportivos|O|O||D||1
94121600|Clubes de hobbies|O|O||D||1
94121601|Clubes de aficionados a los juegos de cartas|O|O||D||1
94121602|Clubes de artesanías|O|O||D||1
94121603|Clubes de aficionados a la poesía o la literatura|O|O||D||1
94121604|Clubes de aficionados a la cocina|O|O||D||1
94121605|Clubes de aficionados a la jardinería|O|O||D||1
94121606|Club de aficionados al coleccionismo|O|O||D||1
94121607|Club de exploradores (scouts)|O|O||D||1
94121700|Clubes de aficionados|O|O||D||1
94121701|Clubes o servicios para aficionados al teatro|O|O||D||1
94121702|Clubes o servicios para aficionados a la música|O|O||D||1
94121703|Clubes o servicios para aficionados al baile a la danza|O|O||D||1
94121704|Clubes o servicios para aficionados a las bellas artes|O|O||D||1
94121800|Clubes sociales|O|O||D||1
94121801|Clubes juveniles|O|O||D||1
94121802|Clubes para la tercera edad|O|O||D||1
94121803|Clubes para reuniones sociales|O|O||D||1
94121804|Clubes sociales para personas discapacitadas|O|O||D||1
94121805|Clubes sociales para veteranos de guerra|O|O||D||1
94131500|Organizaciones no gubernamentales|O|O||D||1
94131501|Servicios ambientales no gubernamentales|O|O||D||1
94131502|Servicios no gubernamentales de ayuda de emergencia|O|O||D||1
94131503|Servicios no gubernamentales de asistencia técnica|O|O||D||1
94131504|Servicios no gubernamentales de ayuda al desarrollo|O|O||D||1
94131600|Organizaciones de caridad|O|O||D||1
94131601|Servicios de albergue de organizaciones de beneficencia|O|O||D||1
94131602|Servicios de socorro alimentario|O|O||D||1
94131603|Servicios de asistencia legal|O|O||D||1
94131604|Servicios de movilización de recursos|O|O||D||1|Donativos en especie
94131605|Servicios de asistencia de ayuda internacional|O|O||D||1
94131606|Servicios de orfanatos o adopción|O|O||D||1
94131607|Organizaciones de asistencia a los adultos mayores|O|O||D||1
94131608|Organizaciones de asistencia a presos|O|O||D||1
94131700|Asociaciones verdes|O|O||D||1
94131701|Asociaciones ecologistas radicales|O|O||D||1
94131702|Asociaciones ecofeministas|O|O||D||1
94131703|Organizaciones políticas ecológicas|O|O||D||1
94131704|Movimientos o servicios de activistas ecológicos|O|O||D||1
94131800|Movimientos|O|O||D||1
94131805|Servicios de preservación cultural de las minorías étnicas|O|O||D||1
94131900|Asociaciones protectoras de animales|O|O||D||1
94131901|Movimientos para la liberación de animales|O|O||D||1
94131902|Asociaciones para la protección de las especies en peligro de extinción|O|O||D||1
94131903|Asociaciones para la protección de animales amenazados|O|O||D||1
94132000|Asociaciones de defensa y promoción de los derechos humanos|O|O||D||1
94132001|Servicios de defensa de los derechos de los niños|O|O||D||1
94132002|Servicios de defensa de los presos|O|O||D||1
94132003|Asociaciones para la defensa de la tortura física o mental|O|O||D||1
94132004|Asociaciones para la defensa de la libertad de expresión|O|O||D||1
95101500|Lotes residenciales|O|O||D
95101501|Parcela para vivienda unifamiliar|O|O||D|||Terreno para vivienda unifamiliar
95101502|Parcela para edificio de apartamentos|O|O||D|||Terreno para edificio de apartamentos
95101503|Parcela para apartamentos cooperativos|O|O||D|||Terreno para apartamentos cooperativos
95101504|Parcela para condominio|O|O||D|||Terreno para condominio
95101505|Parcela para residencia universitaria|O|O||D|||Terreno para residencia universitaria
95101506|Parcela para subdivisión de vivienda|O|O||D|||Terreno para subdivisión de vivienda
95101507|Parcela para hotel|O|O||D|||Terreno para hotel
95101508|Parcela para motel|O|O||D|||Terreno para motel
95101509|Parcela para casas móviles|O|O||D|||Terreno para casas móviles
95101510|Parque de casas móviles|O|O||D
95101600|Lotes comerciales|O|O||D
95101601|Parque empresarial|O|O||D
95101602|Campus de oficinas|O|O||D
95101603|Sitio para centro comercial de calle|O|O||D
95101700|Lotes industriales|O|O||D
95101701|Parque aéreo|O|O||D
95101702|Sitio para planta ensambladora|O|O||D|||Terreno para planta ensambladora
95101703|Sitio para fábrica|O|O||D|||Terreno para fábrica
95101704|Sitio para planta manufacturera|O|O||D|||Terreno para planta manufacturera
95101705|Sitio para marina|O|O||D|||Terreno para marina
95101706|Sitio para planta empacadora|O|O||D|||Terreno para planta empacadora
95101707|Sitio para telecomunicaciones|O|O||D|||Terreno para telecomunicaciones
95101708|Sitio para empresa pública|O|O||D|||Terreno para empresa pública
95101800|Lotes de terrenos gubernamentales|O|O||D
95101807|Patio de mantenimiento|O|O||D
95101900|Tierras agrícolas|O|O||D
95101901|Granja|O|O||D
95101902|Rancho|O|O||D
95101903|Huerto|O|O||D
95111500|Vías de tráfico limitado|O|O||D
95111501|Servidumbre|O|O||D
95111502|Derecho de paso|O|O||D
95111503|Carreteras de acceso|O|O||D
95111504|Rampa o vía de acceso a una autopista|O|O||D
95111600|Vías de tráfico abierto|O|O||D
95111602|Carretera o autopista  o autopista de peaje interestatal|O|O||D||1|Cuota o tarifa de peaje en carreteras y autopistas federales
95111603|Carretera o autopista  o autopista de peaje interestatal|O|O||D||1|Cuota o tarifa de peaje en carreteras y autopistas concesionadas
95111609|Cruce de carretera con una carretera principal|O|O||D
95111610|Carretera circunvalar|O|O||D
95111615|Cruce de carreteras|O|O||D
95121500|Edificios y estructuras comerciales y de entretenimiento|O|O||D
95121501|Galería comercial|O|O||D
95121502|Estructura de parqueo|O|O||D|||Estructura para estacionamiento
95121503|Cafetería|O|O||D
95121504|Edificio para tienda|O|O||D
95121505|Centro comercial|O|O||D
95121506|Teatro|O|O||D
95121507|Mercado|O|O||D
95121508|Zona de juegos o patios de recreo para niños|O|O||D
95121509|Zoológico|O|O||D
95121510|Jardín|O|O||D
95121511|Parque|O|O||D
95121512|Instalación recreativa al lado del agua|O|O||D
95121513|Banco|O|O||D
95121514|Oficina de tiquetes|O|O||D|||Oficina de boletos
95121515|Caída de agua artificial|O|O||D
95121516|Muro de piedras y piedras  artificiales|O|O||D
95121517|Crematorio|O|O||D
95121600|Edificios y estructuras de transporte|O|O||D
95121601|Puente de acero|O|O||D
95121602|Dique seco|O|O||D
95121603|Estación de buses|O|O||D
95121604|Garaje para buses|O|O||D
95121605|Edificio de servicios o reparaciones automotrices|O|O||D
95121606|Estación ferroviaria|O|O||D
95121607|Depósito ferroviario|O|O||D
95121608|Estación ferroviarias  subterráneas|O|O||D
95121609|Depósito de tranvías|O|O||D
95121610|Plataforma de tranvías|O|O||D
95121611|Edificio de aeropuertos|O|O||D
95121612|Torre de control aeroportuaria|O|O||D
95121613|Campo de aviación|O|O||D
95121614|Pista|O|O||D
95121615|Muelle|O|O||D
95121616|Embarcadero|O|O||D
95121617|Dársena|O|O||D
95121618|Marina|O|O||D
95121619|Marina de yates|O|O||D
95121620|Rompeolas|O|O||D
95121621|Malecón|O|O||D
95121622|Edificio de terminal de ferry|O|O||D
95121623|Terminal ro-ro|O|O||D
95121624|Faro|O|O||D
95121640|Tubería|O|O||D||1
95121641|Estación de bombeo|O|O||D
95121642|Estación de bombeo de aguas residuales|O|O||D
95121643|Descargas de aguas residuales|O|O||D||1
95121644|Parqueadero|O|O||D|||Estacionamiento
95121646|Estructura para parqueo de bicicletas|O|O||D||1|Estructura de estacionamiento para bicicletas
95121700|Edificios y estructuras públicos|O|O||D
95121701|Oficina postal|O|O||D
95121702|Estación de policía|O|O||D
95121703|Edificio de juzgados|O|O||D
95121704|Edificio de prisión|O|O||D
95121705|Estación de bomberos|O|O||D
95121706|Estación de ambulancias|O|O||D
95121707|Edificio de rescate de montaña|O|O||D
95121708|Estación de botes salvavidas|O|O||D
95121709|Edificio de guardacostas|O|O||D
95121710|Estación de servicio de rescate|O|O||D
95121711|Centro cívico|O|O||D
95121712|Galería de arte|O|O||D
95121800|Edificios y estructuras utilitarios|O|O||D
95121801|Estación de radares|O|O||D
95121802|Subestación|O|O||D
95121804|Torre de agua|O|O||D
95121805|Pozo|O|O||D
95121806|Estación base para telefonía móvil|O|O||D
95121808|Plataforma de gas o petróleo|O|O||D
95121900|Edificios y estructuras educacionales y de administración|O|O||D
95121901|Escuela politécnica|O|O||D
95121902|Centro de formación tecnológica|O|O||D
95121903|Aula|O|O||D
95121904|Biblioteca|O|O||D
95121905|Laboratorio de idiomas|O|O||D
95121906|Edificio de laboratorio|O|O||D
95121907|Estación meteorológica|O|O||D
95121908|Instalación para investigación o prueba|O|O||D
95121909|Escuela primaria|O|O||D
95121910|Escuela de bachillerato clásico|O|O||D
95121911|Escuela de bachillerato|O|O||D
95121913|Universidad|O|O||D
95122000|Edificios y estructuras hospitalarias|O|O||D
95122001|Clínica|O|O||D
95122002|Hogar de convalecencia|O|O||D
95122003|Sala de operaciones o quirófano|O|O||D
95122004|Unidad de cuidados intensivos|O|O||D
95122005|Sala de detección y diagnóstico|O|O||D
95122006|Sala de fluoroscopio|O|O||D
95122007|Sala o laboratorio de patología|O|O||D
95122008|Sala de cateterismo|O|O||D
95122100|Edificios y estructuras de acomodaciones|O|O||D
95122101|Casa residencial|O|O||D
95122102|Apartamento o piso|O|O||D
95122103|Asilo de niños|O|O||D
95122104|Guardería de niños|O|O||D
95122105|Hogar de ancianos|O|O||D
95122106|Hostal|O|O||D
95122300|Edificios y estructuras de salud y deportivas|O|O||D
95122301|Estadio|O|O||D
95122302|Campo deportivo|O|O||D
95122303|Pista de carreras|O|O||D
95122304|Polideportivo|O|O||D
95122305|Spa|O|O||D
95122306|Gimnasio|O|O||D
95122307|Piscina|O|O||D
95122308|Instalación para deportes acuáticos|O|O||D
95122400|Edificios y estructuras industriales|O|O||D
95122401|Taller|O|O||D
95122402|Instalación para conservación en cámaras frigoríficas|O|O||D
95122403|Tienda de descuentos|O|O||D
95122500|Edificios y estructuras agrícolas y de cultivos y pesca|O|O||D
95122501|Granero|O|O||D
95122502|Establo|O|O||D
95122503|Canal de riego|O|O||D
95122600|Edificios y estructuras religiosas|O|O||D
95122700|Edificios y estructuras de defensa|O|O||D
95131500|Tarimas y graderías|O|O||D||1
95131501|Graderías plegables|O|O||D||1
95131502|Graderías móviles|O|O||D||1
95131503|Graderías portátiles|O|O||D||1
95131600|Edificios y estructuras comerciales e industriales portátiles|O|O||D||1
95131601|Taquillas portátiles|O|O||D||1
95131602|Cuarto de baño portátil|O|O||D||1|Servicios en baños portátiles, Servicios en baños públicos
95131603|Oficina en el emplazamiento|O|O||D||1
95131604|Unidad de cocina portátil|O|O||D||1
95131605|Casa contenedor|O|O||D||1
95131606|Cabina de ventas portátil|O|O||D||1
95131700|Tiendas carpas y estructuras de membrana|O|O||D||1
95131701|Estructura textil tipo armazón|O|O||D||1
95131702|Carpa de poste o de tensión|O|O||D||1
95141500|Edificios y estructuras prefabricados para fincas|O|O||D
95141501|Silo|O|O||D|||Depósitos para granos
95141502|Invernadero|O|O||D
95141600|Edificios y estructuras prefabricados residenciales|O|O||D||1
95141601|Casa|O|O||D
95141602|Casa móvil|O|O||D||1
95141603|Cabaña|O|O||D
95141604|Garaje|O|O||D
95141605|Gazebo|O|O||D||1|Kiosco, Pabellón
95141606|Cocina para casa|O|O||D||1
95141700|Edificios y estructuras prefabricados comerciales e industriales|O|O||D
95141701|Oficina en la planta|O|O||D
95141702|Cabina de pintura|O|O||D
95141703|Galpón de almacenaje|O|O||D|||Almacén
95141704|Sala blanca|O|O||D
95141705|Casa de guardias|O|O||D
95141706|Bodega|O|O||D
95141707|Auditorio|O|O||D
95141708|Cocina para oficina|O|O||D||1
95141709|Conservatorio|O|O||D
95141710|Cabina telefónica|O|O||D||1
95141711|Cabina de peaje|O|O||D||1
95141800|Edificios y estructuras prefabricados de emergencia y alivio|O|O||D
95141801|Albergue|O|O||D
95141802|Carpa o salón de emergencia|O|O||D||1
95141803|Unidad de contenedor|O|O||D||1
95141900|Edificios y estructuras prefabricados médicos|O|O||D
95141901|Unidad médica|O|O||D
95141902|Unidad de laboratorio|O|O||D
95141903|Unidad odontológica|O|O||D
95141904|Unidades quirúrgicas|O|O||D
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
