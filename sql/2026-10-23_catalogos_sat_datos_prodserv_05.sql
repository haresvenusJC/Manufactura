-- =====================================================================
--  Catálogo SAT c_ClaveProdServ — DATOS, parte 5 de 10 (5163 claves; total 52513)
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
42161701|Hemofiltro|O|O||D||1
42161702|Bolsas de recolección de hemofiltración|O|O||D||1
42161703|Puertos de infusión para hemofiltración|O|O||D||1
42161704|Puertos de muestreo para hemofiltración|O|O||D||1
42161800|Equipo y suministros de terapia renal sustitutiva continua (CRRT)|O|O||D||1
42161801|Unidades de diálisis arterio venosa continua cavhd o productos relacionados|O|O||D||1
42161802|Unidades de hemofiltración arterio venosa continua cavh o productos relacionados|O|O||D||1
42161803|Unidades de hemodiálisis o hemofiltración  venosa continua o productos relacionados|O|O||D||1
42161804|Unidades de ultrafiltración continua lenta scuf o productos relacionados|O|O||D||1
42161900|Equipo y suministros para aféresis terapéutica|O|O||D||1
42161901|Kit para procedimientos de aféresis terapéutica|O|O||D||1
42171500|Productos de servicio médico de urgencia en la gestión de desastre|O|O||D||1
42171501|Bolsas para cuerpos para desastres para servicios médicos de emergencia|O|O||D||1
42171502|Etiquetas de triage para servicios médicos de emergencia|O|O||D||1
42171600|Productos de sacar, inmovilizar y trasladar de servicios médicos de urgencia|O|O||D||1
42171601|Camillas o accesorios para evacuación aérea|O|O||D||1
42171602|Camillas o accesorios para ambulancias|O|O||D||1
42171603|Prendas anti choque|O|O||D||1
42171604|Camillas canasta o accesorios|O|O||D||1
42171605|Ojales de cable de rescate|O|O||D||1
42171606|Férulas inflables para servicios médicos de emergencia|O|O||D||1
42171607|Collares cervicales o de extracción de víctimas para servicios médicos de emergencia|O|O||D||1
42171608|Inmovilizadores de cabeza para servicios médicos de emergencia|O|O||D||1
42171609|Correas de retención o espinales para servicios médicos de emergencia|O|O||D||1
42171610|Inmovilizadores de torso para servicios médicos de emergencia|O|O||D||1
42171611|Literas o camillas o accesorios para respuesta de emergencia|O|O||D||1
42171612|Camillas o accesorios redondas|O|O||D||1
42171613|Tablas espinales|O|O||D||1
42171614|Tubos o contenedores para rescate en agua|O|O||D||1
42171700|Mantas de servicios médicos de urgencia|O|O||D||1
42171701|Cobijas para emergencias o rescates|O|O||D||1
42171702|Cobijas para primeros auxilios|O|O||D||1
42171703|Cobertores o cobijas de protección contra el calor para servicios médicos de emergencia|O|O||D||1
42171704|Fajas para bebés o porta bebés para servicios médicos de emergencia|O|O||D||1
42171800|Equipo de servicios médicos de urgencia de gestión del vía de aire|O|O||D||1
42171801|Kits de intubación o vía aérea oro faríngea para servicios médicos de emergencia|O|O||D||1
42171802|Kits de laringoscopia para servicios médicos de emergencia|O|O||D||1
42171803|Unidades o accesorios de succión para servicios médicos de emergencia|O|O||D||1
42171804|Kits de cricotiroidotomía o tubo traqueal para servicios médicos de emergencia|O|O||D||1
42171805|Desplegadores de mandíbula|O|O||D||1
42171806|Palos para convulsiones|O|O||D||1
42171900|Cajas o bolsas de almacenaje para servicios médicos de urgencia|O|O||D||1
42171901|Bolsas de manejo de vía aérea para servicios médicos de emergencia|O|O||D||1
42171902|Estuches de desfibriladores para servicios médicos de emergencia|O|O||D||1
42171903|Estuches de medicamentos para servicios médicos de emergencia|O|O||D||1
42171904|Estuches o bolsas de productos de extracción para servicios médicos de emergencia|O|O||D||1
42171905|Estuches intravenosos iv para servicios médicos de emergencia|O|O||D||1
42171906|Estuches de intubación para servicios médicos de emergencia|O|O||D||1
42171907|Bolsas de laringoscopia para servicios médicos de emergencia|O|O||D||1
42171908|Estuches de soporte de vida para servicios médicos de emergencia|O|O||D||1
42171909|Paquetes de trauma para respuesta de larga distancia ldr para servicios médicos de emergencia|O|O||D||1
42171910|Estuches paramédicos para servicios médicos de emergencia|O|O||D||1|Botiquines para servicios de emergencia
42171911|Estuches de oxígeno portátil o resucitación para servicios médicos de emergencia|O|O||D||1
42171912|Estuches o bolsas de rescate para servicios médicos de emergencia|O|O||D||1
42171913|Estuches o bolsas de respuesta para servicios médicos de emergencia|O|O||D||1|Maletines para sevicios médicos de emergencia
42171914|Estuches o bolsas de trauma para servicios médicos de emergencia|O|O||D||1
42171915|Estuches o bolsas para técnicos médicos de emergencia emt|O|O||D||1
42171916|Estuches para transportar o almacenar sets de inmovilización para servicios médicos de emergencia|O|O||D||1
42171917|Estuches o bolsas o accesorios de primeros auxilios para servicios médicos de emergencia|O|O||D||1
42171918|Estuches de equipos de tratamiento de víctimas de gas para servicios médicos de emergencia|O|O||D||1
42171919|Bolsas o revestimientos de evacuación para servicios médicos de emergencia|O|O||D||1
42171920|Estuches o accesorios de ropa para servicios médicos de emergencia|O|O||D||1
42172000|Kits para los servicios médicos de urgencias y campo|O|O||D||1
42172001|Kits de primeros auxilios para servicios médicos de emergencia|O|O||D||1|Botiquín de primeros auxilios, Botiquín médico
42172002|Kits de primera respuesta para servicios médicos de emergencia|O|O||D||1|Maletín paramédico para emergencias pre-hospitalarias
42172003|Kits intravenosos iv para servicios médicos de emergencia|O|O||D||1
42172004|Kits de soporte de vida para servicios médicos de emergencia|O|O||D||1
42172005|Kits de trauma de respuesta de larga distancia ldr para servicios médicos de emergencia|O|O||D||1
42172006|Kits obstétricos para servicios médicos de emergencia|O|O||D||1
42172007|Kits de oxígeno o resucitación para servicios médicos de emergencia|O|O||D||1
42172008|Kits de rapel para servicios médicos de emergencia|O|O||D||1
42172009|Kits de búsqueda y rescate para servicios médicos de emergencia|O|O||D||1
42172010|Kits de trauma para servicios médicos de emergencia|O|O||D||1
42172011|Kits para técnicos médicos de emergencia emt|O|O||D||1
42172012|Kits de ventriculostomía para servicios médicos de emergencia|O|O||D||1
42172013|Kits de evacuación para servicios médicos de emergencia|O|O||D||1
42172014|Kits o suministros de transporte de pacientes para servicios médicos de emergencia|O|O||D||1
42172015|Kits de tratamiento dental para servicios médicos de emergencia|O|O||D||1
42172016|Kits de fracturas para servicios médicos de emergencia|O|O||D||1
42172017|Kits de equipos médicos de laboratorio o de campo o productos relacionados|O|O||D||1
42172018|Kit de lavado gástrico|O|O||D||1
42172100|Productos de resucitación de servicios médicos de emergencia|O|O||D||1
42172101|Desfibriladores externos automatizados aed o paletas duras|O|O||D||1
42172102|Escudos o máscaras protectoras para resucitación cardiopulmonar cpr|O|O||D||1
42172103|Kits aspiradores o resucitadores para emergencias|O|O||D||1
42172104|Tablas de resucitación cardiopulmonar cpr|O|O||D||1
42172105|Accesorios para desfibriladores externos automatizados aed|O|O||D||1
42172200|Suministros de servicios médicos de emergencia|O|O||D||1
42172201|Pinzas o torniquetes para servicios médicos de emergencia|O|O||D||1
42181500|Evaluación diagnóstica y productos de examen de uso general|O|O||D||1
42181501|Depresores de lengua o cuchillos o baja lenguas|O|O||D||1|Abatelenguas, Depresor lingual
42181502|Transiluminadores para exámenes de uso médico|O|O||D||1
42181503|Lubricantes o gelatinas personales o para examen|O|O||D||1
42181504|Sets de hemacitómetros|O|O||D||1
42181505|Sets o accesorios de muestreadores de células endometriales|O|O||D||1
42181506|Kits de determinación de asalto sexual|O|O||D||1
42181507|Bandas para sujetar el espejo a la frente o accesorios para exámenes médicos|O|O||D||1
42181508|Pañitos limpiadores para equipo diagnóstico|O|O||D||1
42181509|Sets de examen físico para cirujanos de vuelo|O|O||D||1
42181510|Medidores de ictericia transcutáneos|O|O||D||1
42181511|Evaluadores de impotencia masculina|O|O||D||1
42181512|Cucharas para examen de portadores de tifoidea|O|O||D||1
42181513|Kits de irrigación de los senos nasales|O|O||D||1
42181514|Fotómetros de hemoglobina|O|O||D||1
42181515|Bandejas de procedimiento para exámenes|O|O||D||1
42181516|Unidades o accesorios de electromiografía emg|O|O||D||1
42181518|Estuche para sets de instrumentos médicos o sus accesorios|O|O||D||1
42181519|Portador de gotas|O|O||D||1
42181520|Medidor de presión intratoráxica|O|O||D||1
42181521|Monitor de presión de fluido espinal|O|O||D||1
42181522|Aparato para análisis de manera de caminar|O|O||D||1
42181523|Sistema de prueba y evaluación isocinética|O|O||D||1
42181524|Analizador de rigidez|O|O||D||1
42181525|Ataxiágrafo|O|O||D||1
42181526|Algesímetro|O|O||D||1
42181527|Dinamómetro médico|O|O||D||1
42181528|Dispositivo para medir la resistencia de la piel|O|O||D||1
42181529|Estesiómetro|O|O||D||1
42181530|Sistema de inducción de sudor de iontoforesis|O|O||D||1
42181531|Instrumento medidor de conductividad eléctrica de la piel|O|O||D||1
42181532|Medidor de respuesta galvánica de la piel|O|O||D||1
42181533|Dispositivo de medición de la velocidad de conducción del nervio|O|O||D||1
42181534|Electroglotógrafo|O|O||D||1
42181535|Condicionador de señales electrónicas fisiológicas|O|O||D||1
42181536|Dispositivo eléctrico de detección de caries|O|O||D||1
42181537|Instrumento para medir la fuerza de la mordida para uso odontológico|O|O||D||1
42181538|Dispositivo medidor del sonido de oclusión para uso odontológico|O|O||D||1
42181600|Unidades de presión sanguínea y productos relacionados|O|O||D||1
42181601|Unidades de presión de sangre aneroides|O|O||D||1
42181602|Unidades de presión de sangre electrónicas|O|O||D||1
42181603|Unidades de presión de sangre de mercurio|O|O||D||1
42181604|Válvulas o peras inflables de liberación de presión del aire en la sangre|O|O||D||1
42181605|Mangas o vejigas de presión de la sangre|O|O||D||1
42181606|Mangueras de inflar o mangueras neumáticas o adaptadores de presión de sangre|O|O||D||1
42181607|Unidades de registro de presión de sangre|O|O||D||1
42181608|Accesorios para instrumentos de medición de presión de sangre|O|O||D||1
42181609|Kits de domo de monitoreo de presión de sangre|O|O||D||1
42181610|Kits de mangas de presión de sangre|O|O||D||1
42181611|Manómetro de presión venosa central cvp|O|O||D||1
42181612|Soportes móviles de presión de sangre|O|O||D||1
42181700|Unidades de electrocardiografía (ECG) y productos relacionados|O|O||D||1
42181701|Unidades de electrocardiografía ekg|O|O||D||1
42181702|Adaptadores o cables o conductores para electrocardiografía ekg|O|O||D||1
42181703|Probadores de cables o conductores o unidades de electrocardiografía ekg|O|O||D||1
42181704|Calibradores o reglas de electrocardiografía ekg|O|O||D||1
42181705|Registros gráficos de electrocardiografía ekg|O|O||D||1
42181706|Pantallas de monitor para electrocardiografía ekg|O|O||D||1
42181707|Electrodos de tira o anillo para electrocardiografía ekg neonatal|O|O||D||1
42181708|Electrodos de parche para electrocardiografía ekg|O|O||D||1
42181710|Probadores de superficie de electrodos para electrocardiografía ekg|O|O||D||1
42181711|Sistemas telefónicos receptores o transmisores para electrocardiografía ekg|O|O||D||1
42181712|Analizadores de unidad de electrocardiografía ekg|O|O||D||1
42181713|Sistemas de monitoreo de electrocardiografía ekg continua de larga duración o holter|O|O||D||1
42181714|Kits de accesorios de monitoreo para electrocardiografía ekg|O|O||D||1
42181715|Soluciones o cremas para electrodos|O|O||D||1
42181716|Accesorios para electrocardiografía ekg|O|O||D||1
42181717|Bombillos de electrodos para electrocardiografía ekg|O|O||D||1
42181718|Esferos para registro de electrocardiografía ekg|O|O||D||1
42181719|Transmisor o telemetría o accesorios para electrocardiografía ekg|O|O||D||1
42181720|Sistema de monitoreo de estrés por ejercicio|O|O||D||1
42181721|Esfigmógrafo|O|O||D||1
42181722|Analizador de ondas de pulso|O|O||D||1
42181800|Oxímetros de pulso|O|O||D||1
42181801|Unidades para oxímetros de pulso|O|O||D||1
42181802|Cables para oxímetros de pulso|O|O||D||1
42181803|Sondas o sensores para oxímetros de pulso|O|O||D||1
42181804|Accesorios para sondas o sensores para oxímetros de pulso|O|O||D||1
42181805|Accesorios para unidades de oxímetros de pulso|O|O||D||1
42181900|Unidades de control de cuidado intenso y productos relacionados|O|O||D||1
42181901|Unidades o accesorios para cuidado intensivo fetal o monitoreo materno|O|O||D||1
42181902|Unidades o accesorios para monitoreo de presión intracraneal icp|O|O||D||1
42181903|Unidades o accesorios para monitoreo de salida cardiaca co|O|O||D||1
42181904|Unidades o accesorios para unidades de signos vitales multi parámetro|O|O||D||1
42181905|Cables para monitor transductor para uso médico|O|O||D||1
42181906|Catéteres para monitoreo de presión intrauterina|O|O||D||1
42181907|Aparatos para metabolismo basal|O|O||D||1
42181908|Sets o accesorios de monitoreo de presión intra compartimientos|O|O||D||1
42181910|Kits intrauterinos transcervicales|O|O||D||1
42181911|Electrodos para cuero cabelludo fetal|O|O||D||1
42181912|Monitor electroencefalográfico fetal|O|O||D||1
42182000|Especulo y scopios y accesorios para uso del reconocimiento diagnóstico médico|O|O||D||1
42182001|Espéculos para examen anal o rectal|O|O||D||1
42182002|Anoscopios o proctoscopios|O|O||D||1
42182003|Colposcopios o vaginoscopios o accesorios|O|O||D||1
42182004|Dermatoscopios|O|O||D||1
42182005|Oftalmoscopios u otoscopios o sets de escopios|O|O||D||1
42182006|Espéculos para examen de laringe o bucofaríngeo|O|O||D||1
42182007|Bombillos o lámparas de escopios para exámenes médicos|O|O||D||1
42182008|Manijas de escopios o cargadores de escopios para exámenes médicos|O|O||D||1
42182009|Puntas de espéculos para escopios o dispensadores de puntas de espéculos para uso médico|O|O||D||1
42182010|Sujetadores o soportes para espéculos para exámenes médicos|O|O||D||1
42182011|Espéculos o puntas de dilatación o dispensadores de puntas para exámenes médicos|O|O||D||1
42182012|Espéculos o dilatadores para exámenes nasales|O|O||D||1
42182013|Espéculos para examen vaginal|O|O||D||1
42182014|Accesorios para otoscopios u oftalmoscopios|O|O||D||1
42182015|Espéculos para otoscopia|O|O||D||1
42182016|Nasofaringoscopios o accesorios|O|O||D||1
42182017|Sets de espéculos para oído|O|O||D||1
42182018|Broncoscopios o accesorios|O|O||D||1
42182019|Kits de dilatación|O|O||D||1
42182020|Angioscopios o accesorios|O|O||D||1
42182100|Estetoscopio y productos relacionados|O|O||D||1
42182101|Estetoscopios electrónicos o accesorios|O|O||D||1
42182102|Dopplers vasculares de mano o accesorios|O|O||D||1
42182103|Estetoscopio acústico para uso médico o accesorios|O|O||D||1
42182104|Estetoscopio de cabeza|O|O||D||1
42182105|Cubiertas para estetoscopios de cabeza|O|O||D||1
42182106|Fonocardiográfos estetoscópicos|O|O||D||1
42182107|Estetoscopios auriculares|O|O||D||1
42182108|Termorreguladores de pacientes|O|O||D||1
42182200|Termómetros médicos y accesorios|O|O||D||1
42182201|Termómetros electrónicos para uso médico|O|O||D||1
42182202|Termómetros de fibra óptica para uso médico|O|O||D||1
42182203|Estuches o forros para transportar termómetros para uso médico|O|O||D||1
42182204|Estantes para termómetros para uso médico|O|O||D||1
42182205|Fundas para puntas o sondas de termómetros para uso médico|O|O||D||1
42182206|Termómetros de mercurio para uso médico|O|O||D||1
42182207|Monitores de temperatura continua o de tendencia de temperatura del paciente|O|O||D||1
42182208|Bandas de temperatura del paciente|O|O||D||1
42182209|Sondas para termómetros|O|O||D||1
42182210|Termómetros de vidrio no de mercurio para uso médico|O|O||D||1
42182211|Sistema de termografía infrarroja|O|O||D||1
42182212|Termómetro de cristal líquido|O|O||D||1
42182300|Productos del examen neurológico|O|O||D||1
42182301|Molinillos de diagnóstico para uso médico|O|O||D||1
42182302|Martillos o martillos quirúrgicos para reflejos|O|O||D||1
42182303|Tarjetas de examen neurosiquiátrico|O|O||D||1
42182304|Sets o kits de pruebas de diagnóstico sicológico|O|O||D||1
42182305|Sets para procedimientos mielográficos|O|O||D||1
42182306|Discriminadores neurológicos|O|O||D||1
42182307|Alfileres neurológicos|O|O||D||1
42182308|Electroencefalógrafo eeg o accesorios|O|O||D||1
42182310|Electromiógrafos|O|O||D||1
42182311|Sensores neurológicos|O|O||D||1
42182312|Electrodos o sets para electromiógrafos|O|O||D||1
42182313|Sets para diagnóstico neurológico|O|O||D||1
42182314|Dispositivo de retroalimentación biológica|O|O||D||1
42182315|Analizador de espectro electroencefalográfico|O|O||D||1
42182316|Detector de respuesta evocada|O|O||D||1
42182400|Productos para probar el oír|O|O||D||1
42182401|Audiómetros o accesorios|O|O||D||1
42182402|Vibradores de hueso audiométricos o analizadores de oído medio|O|O||D||1
42182403|Cabinas audiométricas o cámaras acústicas para pruebas de audición|O|O||D||1
42182404|Sets de calibración de unidades de evaluación de función auditiva|O|O||D||1
42182405|Unidades de evaluación de función auditiva|O|O||D||1
42182406|Grabadoras gráficas de pruebas auditivas|O|O||D||1
42182407|Fenestrómetros de oído|O|O||D||1
42182408|Electrococleógrafos|O|O||D||1
42182409|Analizadores de audífonos o sistemas de prueba|O|O||D||1
42182410|Estuches para diapasones para uso médico|O|O||D||1
42182411|Martillos para diapasones para uso médico|O|O||D||1
42182412|Diapasones para uso médico|O|O||D||1
42182413|Sets de diapasones para uso médico|O|O||D||1
42182414|Analizadores de tinnitus (acúfenos)|O|O||D||1
42182415|Tubos de toynbee para diagnóstico|O|O||D||1
42182416|Timpanómetros o sus accesorios|O|O||D||1
42182417|Cordones de audiometría|O|O||D||1
42182418|Guías para fenestrómetro|O|O||D||1
42182419|Aparatos para control de audición|O|O||D||1
42182420|Sondas aurales|O|O||D||1
42182421|Calibradores de tapones o accesorios|O|O||D||1
42182422|Bolsas inflables para oído|O|O||D||1
42182500|Metros de función nasal|O|O||D||1
42182501|Olfatómetros|O|O||D||1
42182502|Medidores de flujo nasal o rinoanemómetros|O|O||D||1
42182600|Lámparas o luces de examen médico|O|O||D||1
42182601|Luces o lámparas de pie para exámenes médicos|O|O||D||1
42182602|Luces o lámparas instaladas para exámenes médicos|O|O||D||1
42182603|Luces de techo o lámparas de techo o accesorios para exámenes médicos|O|O||D||1
42182604|Linternas para exámenes médicos|O|O||D||1
42182700|Dispositivos de medición de talla de examen médico|O|O||D||1
42182701|Goniómetros|O|O||D||1
42182702|Cintas de medición para uso médico|O|O||D||1
42182703|Reglas de medición de altura de pacientes|O|O||D||1
42182704|Evaluadores de dobleces de piel|O|O||D||1
42182705|Analizador de composición del cuerpo|O|O||D||1
42182706|Malla o dispositivo de medición de heridas|O|O||D||1
42182707|Inclinómetro|O|O||D||1
42182800|Básculas médicas de peso|O|O||D||1
42182801|Básculas de pañales|O|O||D||1
42182802|Básculas de bebés|O|O||D||1
42182803|Básculas de mesa o cama para pacientes para uso general|O|O||D||1
42182804|Básculas de asiento para pacientes|O|O||D||1
42182805|Básculas de piso para pacientes|O|O||D||1
42182806|Básculas de eslinga para pacientes|O|O||D||1
42182807|Básculas de plataforma para sillas de ruedas|O|O||D||1
42182808|Forros o revestimientos para básculas de pesaje|O|O||D||1
42182900|Mesas de examen de especialidad y productos relacionados|O|O||D||1
42182901|Mesas de examen obstétrico o ginecológico|O|O||D||1
42182902|Mesas de examen con apoya pies para examen obstétrico o ginecológico|O|O||D||1
42182903|Mesas para examen pediátrico|O|O||D||1
42182904|Mesas de retención o sistemas de medición para examen pediátrico|O|O||D||1
42183000|Productos de examen diagnóstico oftálmico|O|O||D||1
42183001|Carteleras para examen de ojos o tarjetas de visión|O|O||D||1
42183002|Topógrafos corneales|O|O||D||1
42183003|Exoftalmómetros|O|O||D||1
42183004|Queratoscopios|O|O||D||1
42183005|Colorímetros oftálmicos|O|O||D||1
42183006|Distómetros oftálmicos|O|O||D||1
42183007|Tambores oftálmicos o sus accesorios|O|O||D||1
42183008|Eutiscopios oftálmicos|O|O||D||1
42183009|Lentes de prueba del ojo o sus accesorios para uso oftálmico|O|O||D||1
42183010|Lensómetros para uso oftálmico|O|O||D||1
42183011|Perímetros para uso oftálmico|O|O||D||1
42183012|Fotómetros para uso oftálmico|O|O||D||1
42183013|Prismas para uso oftálmico|O|O||D||1
42183014|Retinoscopios para uso oftálmico|O|O||D||1
42183015|Lámparas de hendidura para uso oftálmico|O|O||D||1
42183016|Espectrofotómetros para uso oftálmico|O|O||D||1
42183017|Espéculos para uso oftálmico|O|O||D||1
42183018|Tonómetros o accesorios para uso oftálmico|O|O||D||1
42183019|Transiluminadores para uso oftálmico|O|O||D||1
42183020|Trazadores de campo visual para uso oftálmico|O|O||D||1
42183021|Analizadores de función visual para uso oftálmico|O|O||D||1
42183022|Visiómetros para uso oftálmico|O|O||D||1
42183023|Oftalmómetros|O|O||D||1
42183024|Mesas para instrumentos o accesorios para uso oftálmico|O|O||D||1
42183026|Oftalmodinamómetros|O|O||D||1
42183027|Kits o accesorios de pruebas de monitoreo tangente|O|O||D||1
42183028|Accesorios para retinoscopio para uso oftálmico|O|O||D||1
42183029|Unidades de forópter|O|O||D||1
42183030|Oclusores de ojos|O|O||D||1
42183031|Sets o accesorios de placas pseudoisocromáticas|O|O||D||1
42183032|Taquistoscopio|O|O||D||1
42183033|Sets de ajuste de anteojos|O|O||D||1
42183034|Estereoscopios para probar la visión|O|O||D||1
42183035|Queratómetros refractores de combinación|O|O||D||1
42183036|Placas base para oftalmómetros|O|O||D||1
42183037|Proyectores de cuadros o accesorios|O|O||D||1
42183038|Almohadillas de uso oftálmico|O|O||D||1
42183039|Sujetadores de lentes oftálmicos|O|O||D||1
42183040|Herramientas o accesorios para optómetras|O|O||D||1
42183041|Linternas de pruebas de percepción del color|O|O||D||1
42183042|Aparatos de percepción de profundidad|O|O||D||1
42183043|Bombillos para oftalmómetros|O|O||D||1
42183044|Pantallas tangentes|O|O||D||1
42183045|Sistemas de electroretinograma|O|O||D||1
42183046|Sets o accesorios de prueba de visión binocular|O|O||D||1
42183047|Soportes miradores para pruebas de agudeza visual|O|O||D||1
42183048|Barras de fijación de niños para uso oftálmico|O|O||D||1
42183049|Cámara de fundus|O|O||D||1
42183050|Nistagmógrafo|O|O||D||1
42183051|Pupilómetro|O|O||D||1
42183052|Regla de punto cercano|O|O||D||1
42183053|Medidor de distancia entre pupilas|O|O||D||1
42183054|Pletismografía ocular|O|O||D||1
42183055|Contador de células endoteliales|O|O||D||1
42183056|Cámara anterior|O|O||D||1
42183057|Monitor de movimiento del ojo|O|O||D||1
42183058|Instrumento láser de campo de visión|O|O||D||1
42183059|Foto simulador|O|O||D||1
42183060|Tiras de schirmer|O|O||D||1
42183061|Aplicadores de presión ocular|O|O||D||1
42183062|Cámara de iris|O|O||D||1
42183063|Unidad de electrólisis oftálmica|O|O||D||1
42183064|Lentes de contacto terapéuticos|O|O||D||1
42183065|Lentes de contacto prescritos|O|O||D||1
42183066|Cámara corneal|O|O||D||1
42183067|Lentes de examen de diagnóstico de visión para uso oftálmico|O|O||D||1
42183100|Medidores de la capacidad gustativa|O|O||D||1
42183101|Gustómetros|O|O||D||1
42183200|Equipo y suministros de alergología|O|O||D||1
42183201|Instrumentos o accesorios para detectar o probar alergias|O|O||D||1
42183300|Accesorios de unidades de examen de otorrinolaringología y productos relacionados|O|O||D||1
42183301|Accesorios para espejos de examen de oído nariz garganta ent|O|O||D||1
42191500|Manejo de materiales de facilidad médica y equipo de distribución|O|O||D||1
42191501|Sistema de tubo neumático clínico|O|O||D||1
42191502|Bandejas o cubiertas para medicinas|O|O||D||1
42191600|Sistemas de construcción de facilidad médica|O|O||D||1
42191601|Iluminación para habitaciones de pacientes o accesorios|O|O||D||1
42191602|Iluminación para salas de cirugía o accesorios|O|O||D||1
42191603|Paneles de instrumentos para equipos hospitalarios|O|O||D||1
42191604|Brazos de monitoreo clínico|O|O||D||1
42191605|Columnas para equipos eléctricos hospitalarios|O|O||D||1
42191606|Brazos de techo para instalaciones médicas|O|O||D||1
42191607|Cortinas de cubículo o pantallas o hardware de rieles de cortinas para pacientes|O|O||D||1
42191608|Controles de enfermería o monitores de salida|O|O||D||1
42191609|Sistemas de pared principal para uso clínico|O|O||D||1
42191610|Módulos de trabajo para uso clínico|O|O||D||1
42191611|Módulos o sistemas de comunicación de enfermería|O|O||D||1
42191612|Sistemas de intercomunicación hospitalaria|O|O||D||1
42191613|Transmisor de seguridad para bebés o niños|O|O||D||1
42191700|Productos de gas de hospital|O|O||D||1
42191701|Pistas de servicio de electricidad o gas para uso médico|O|O||D||1
42191702|Columnas de entrega de gas para uso médico|O|O||D||1
42191703|Salidas de gas para uso médico|O|O||D||1
42191704|Sistemas de compresión de aire gas para uso médico|O|O||D||1
42191705|Alarmas de gas para uso médico|O|O||D||1
42191706|Colector de gas para uso medico|O|O||D||1
42191707|Sistemas de vacío para uso médico|O|O||D||1
42191708|Gabinetes de control de presión de aire para uso médico|O|O||D||1
42191709|Válvulas de cierre de gas o cajas de válvulas para uso médico|O|O||D||1
42191710|Carros o puestos o accesorios para cilindros de gas para uso médico|O|O||D||1
42191711|Tanques de aire comprimido o accesorios para uso quirúrgico|O|O||D||1
42191800|Camas de paciente y accesorios|O|O||D||1
42191801|Mesas para encima de la cama o accesorios|O|O||D||1
42191802|Incubadoras o calentadores de bebés para uso clínico|O|O||D||1
42191803|Moisés o cunas o camas pediátricas o accesorios|O|O||D||1
42191804|Barandas para camas para uso médico o quirúrgico|O|O||D||1
42191805|Columnas suspendidas para uso médico|O|O||D||1
42191806|Barras de trapecio para uso clínico|O|O||D||1
42191807|Camas o accesorios de cuidado del paciente para uso general|O|O||D||1
42191808|Camas o accesorios de cuidado del paciente para cuidado especial|O|O||D||1
42191809|Almohadillas o bombas de presión alterna|O|O||D||1
42191810|Colchones o accesorios para el cuidado del paciente|O|O||D||1
42191811|Cunas de posicionamiento para bebés|O|O||D||1
42191812|Kits de suministros de incubadoras para bebés|O|O||D||1
42191813|Forros de catre para el cuidado del paciente|O|O||D||1
42191814|Accesorios para incubadora o calentadora de bebés para uso clínico|O|O||D||1
42191900|Armarios clínicos|O|O||D||1
42191901|Gabinetes clínicos para junto a la cama o accesorios|O|O||D||1
42191902|Armarios para uso hospitalario|O|O||D||1
42191903|Gabinetes de monitoreo para uso médico|O|O||D||1
42191904|Gabinetes o cajas fuertes para narcóticos|O|O||D||1
42191905|Gabinetes de tratamiento para uso médico|O|O||D||1
42191906|Gabinetes calentadores de cobijas o soluciones|O|O||D||1
42191907|Gabinetes o muebles de almacenamiento de instrumentos para uso médico|O|O||D||1
42191908|Carritos de historias clínicas o accesorios|O|O||D||1
42191909|Gabinete computarizado dispensador de medicamentos|O|O||D||1
42192000|Mesas de examen o de procedimiento clínico|O|O||D||1
42192001|Mesas de examen o procedimientos médicos para uso general|O|O||D||1
42192002|Accesorios para mesas de examen o procedimientos médicos para uso general excluyendo sábanas para cubrirlas|O|O||D||1
42192003|Mesas para masajes de terapia física|O|O||D||1
42192100|Asientos y taburetes clínicos y productos relacionados|O|O||D||1
42192101|Asientos o accesorios para sacar sangre o flebotomía|O|O||D||1
42192102|Reclinadoras o accesorios para uso hospitalario|O|O||D||1
42192103|Asientos para pacientes|O|O||D||1
42192104|Taburetes médicos y accesorios|O|O||D||1
42192106|Asientos para visitantes de instalaciones médicas|O|O||D||1
42192107|Asientos de examen clínico o accesorios|O|O||D||1
42192200|Productos para transporte de paciente|O|O||D||1
42192201|Camillas con ruedas o accesorios para el transporte de pacientes|O|O||D||1
42192202|Elevadores de camillas o de tijeras|O|O||D||1
42192203|Asientos geriátricos o accesorios|O|O||D||1
42192204|Incubadoras para el transporte de pacientes o accesorios|O|O||D||1
42192205|Accesorios para carritos de pacientes|O|O||D||1
42192206|Carritos de pacientes|O|O||D||1
42192207|Camillas para pacientes o accesorios para camillas|O|O||D||1
42192208|Accesorios para sillas de ruedas|O|O||D||1
42192209|Rampas para sillas de ruedas|O|O||D||1
42192210|Sillas de ruedas|O|O||D||1
42192211|Tablas para mover pacientes o sus accesorios|O|O||D||1
42192212|Esterilla o sábana para transferencia de pacientes|O|O||D||1
42192213|Unidad de sistema de calefacción para mantener o evacuar pacientes o accesorios|O|O||D||1
42192214|Elevador de sillas de ruedas|O|O||D||1
42192300|Elevadores de paciente|O|O||D||1
42192301|Elevadores de pacientes o accesorios|O|O||D||1
42192302|Elevadores hidráulicos o accesorios para uso clínico|O|O||D||1
42192303|Asientos suspendidos o eslingas para pacientes|O|O||D||1
42192304|Montacargas de techo para pacientes|O|O||D||1
42192305|Eslingas para bebés o accesorios|O|O||D||1
42192400|Transporte de equipo médico y traslado de productos|O|O||D||1
42192401|Carritos de emergencia o resucitación|O|O||D||1
42192402|Carritos específicos para equipos de diagnóstico o monitoreo|O|O||D||1
42192403|Carritos de aislamiento para uso médico|O|O||D||1
42192404|Carritos o accesorios para uso médico|O|O||D||1
42192405|Puestos móviles de irrigación|O|O||D||1
42192406|Carritos para transportar orinales|O|O||D||1
42192500|Protectores para equipo médico|O|O||D||1
42192501|Forros para equipos médicos|O|O||D||1
42192502|Bolsas para equipos médicos|O|O||D||1
42192600|Dispositivos de dosificación y medición de medicamentos y suministros|O|O||D||1
42192601|Moldes de supositorios|O|O||D||1
42192602|Dispensadores de pastillas o medicamentos o accesorios|O|O||D||1
42192603|Tazas o botellas para administrar medicamentos o accesorios|O|O||D||1
42192604|Sistemas o accesorios para la entrega de drogas|O|O||D||1|Sistema de administración de fármacos
42192605|Kits de encapsulamiento de aneurismas|O|O||D||1
42192606|Soplador de polvos|O|O||D||1|Nebulizador manual
42201500|Sistemas de tomografía informatizada (TAC o CT) médica y productos relacionados|O|O||D||1
42201501|Instalación de unidad estacionaria completa para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201502|Unidades móviles o transportables o unidad de camión para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201503|Componentes de sistema tridimensional para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201504|Componentes de hueso de contenido mineral para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201505|Consolas para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201507|Componentes de sistema helicoidal para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201508|Monitores para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201509|Acondicionadores de energía para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201510|Simuladores o dispositivos de aseguramiento de calidad o de calibración para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201511|Escáneres o tubos para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201512|Mesas o puestos o asientos para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201513|Componentes de sistema ultra rápido para tomografía computarizada ct o cat para uso médico|O|O||D||1
42201600|Productos de resonancia magnética (MRI) médica|O|O||D||1
42201601|Instalación de unidad estacionaria completa de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201602|Sistemas móviles o transportables o de camión de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201603|Componentes de sistema tridimensional de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201604|Simuladores o dispositivos de aseguramiento de calidad o calibración de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201605|Bobinas de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201607|Monitores de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201608|Consolas primarias o remotas o secundarias de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201609|Escáneres de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201610|Instrumentos quirúrgicos o sistemas de guía de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201611|Mesas de imágenes de resonancia magnética mri para uso médico|O|O||D||1
42201700|Productos de hacer imágenes de ultrasonido médico y de doppler y de eco|O|O||D||1
42201701|Ultrasonido cardiaco o doppler o unidades de eco o cardioscopios|O|O||D||1
42201702|Ultrasonido o unidades de eco fetales o ginecológicas|O|O||D||1
42201703|Ultrasonido o unidades de eco mamográficas|O|O||D||1
42201704|Densitómetros de hueso por ultrasonido para uso médico|O|O||D||1
42201705|Forros para ultrasonido o doppler o eco sonda para uso médico|O|O||D||1
42201706|Sondas para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201707|Calentadores de gel para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201708|Geles para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201709|Monitores para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201710|Impresoras para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201711|Transductores o accesorios para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201712|Unidades de ultrasonido o doppler o eco pulso o ecografía de diagnóstico general para uso médico|O|O||D||1
42201713|Componentes tridimensionales para ultrasonido o doppler o eco para uso médico|O|O||D||1
42201714|Tensiómetros|O|O||D||1
42201715|Sondas o accesorios para ultrasonido o eco vaginal|O|O||D||1
42201716|Unidades de ultrasonido vascular|O|O||D||1
42201717|Almohadillas de transmisión de ultrasonido para uso médico|O|O||D||1
42201718|Escáneres oftálmicos de ultrasonido para uso médico|O|O||D||1
42201719|Lociones de escáner por ultrasonido para uso médico|O|O||D||1
42201800|Productos radiográficos de diagnóstico médico|O|O||D||1
42201801|Películas de rayos x para cardiología|O|O||D||1
42201802|Equipos de rayos x para cardiología|O|O||D||1
42201803|Equipos de rayos x para mamografías|O|O||D||1
42201804|Unidades de brazo c de rayos x para uso médico|O|O||D||1
42201805|Equipo de cine fluoroscopio para uso médico|O|O||D||1
42201806|Equipo de radiología y fluoroscopia rf para uso médico|O|O||D||1
42201807|Escáneres de radioisótopos para uso médico|O|O||D||1
42201808|Rejillas móviles de rayos x para uso médico|O|O||D||1
42201809|Inyectores o accesorios de agentes de contraste para imágenes para uso médico|O|O||D||1
42201810|Casetes o película de rayos x de uso general para uso médico|O|O||D||1
42201811|Dispositivos de aseguramiento de calidad o calibración de rayos x para uso médico|O|O||D||1
42201812|Mesas o puestos o asientos o gabinetes o accesorios de rayos x para uso médico|O|O||D||1
42201813|Unidades de tomografía de rayos x para uso médico|O|O||D||1
42201814|Tubos de rayos x para uso médico|O|O||D||1
42201815|Unidades de rayos x de uso diagnóstico general para uso médico|O|O||D||1
42201816|Unidades de xerorradiografía para uso médico|O|O||D||1
42201817|Densitómetros de hueso de rayos x|O|O||D||1
42201818|Cuñas de pisada y trompos de combinación para equipo radiográfico|O|O||D||1
42201819|Colgadores o sus accesorios para películas de rayos x|O|O||D||1
42201820|Rejillas de equipo radiográfico para uso médico|O|O||D||1
42201821|Sujeta casetes de película radiográfica|O|O||D||1
42201822|Estuches o fundas o accesorios para equipos de rayos x para uso médico|O|O||D||1
42201823|Unidad de tubo y transformador de rayos x para uso médico|O|O||D||1
42201824|Sets de artrografía para uso médico|O|O||D||1
42201825|Insertos de tubo de aparatos de rayos x para uso médico|O|O||D||1
42201826|Kits de reparación de aparatos de rayos x para uso médico|O|O||D||1
42201827|Kits de reparación de carpa de cuarto oscuro de rayos x para uso médico|O|O||D||1
42201828|Filtros de aparatos de rayos x para uso médico|O|O||D||1
42201829|Localizadores radiográficos|O|O||D||1
42201830|Pantallas intensificadoras de rayos x para uso médico|O|O||D||1
42201831|Tapas de casetes o películas de rayos x para uso médico|O|O||D||1
42201832|Cubiertas de casetes o película radiográfica|O|O||D||1
42201833|Cambiadores de casetes o película radiográfica|O|O||D||1
42201834|Ensamblajes rectificadores de aparatos de rayos x radiográficos para uso médico|O|O||D||1
42201835|Ensamblajes de unidades de tubos de aparatos de rayos x para uso médico|O|O||D||1
42201836|Ensamblajes de bandas de compresión de aparatos de rayos x para uso médico|O|O||D||1
42201837|Enfriadores de agua de rayos x para uso médico|O|O||D||1
42201838|Catéteres o kits de catéteres de enteroclisis para uso médico|O|O||D||1
42201839|Bandejas de procedimientos de imágenes para uso médico|O|O||D||1
42201840|Dispositivos sellantes vasculares|O|O||D||1
42201841|Papeles de rayos x diagnósticos para uso médico|O|O||D||1
42201843|Marcador de piel de rayos x para uso médico|O|O||D||1
42201844|Regla diagnóstica de rayos x para uso médico|O|O||D||1
42201845|Funda o inserto o sobre para película de radiología|O|O||D||1
42201846|Colimador de rayos x radiográfico y fluoroscópico|O|O||D||1
42201847|Sistema móvil de rayos x|O|O||D||1
42201848|Sistema digital de imágenes de rayos x|O|O||D||1
42201849|Escáner fluorescente|O|O||D||1
42201850|Sistema de tomografía nuclear|O|O||D||1
42201851|Contador beta o gama para uso clínico|O|O||D||1
42201852|Pantalla fluorescente|O|O||D||1
42201900|Fuentes de iluminación y equipo de visión de película radiográfica médica|O|O||D||1
42201901|Luces de punto caliente de película de rayos x para uso médico|O|O||D||1
42201902|Sistemas de estanterías de despliegue largas de rayos x para uso médico|O|O||D||1
42201903|Cajas de despliegue de película de rayos x para uso médico|O|O||D||1
42201904|Ventanas o pantallas iluminadoras de película de rayos x para uso médico|O|O||D||1
42201905|Estuches de transferencia de película de rayos x para uso médico|O|O||D||1
42201906|Ganchos iluminadores de película de rayos x para uso médico|O|O||D||1
42201907|Estereoscopios de película de rayos x para uso médico|O|O||D||1
42201908|Viseras para monitores fluoroscopios para uso médico|O|O||D||1
42202000|Cámaras médicas gamma de diagnóstico y productos relacionados|O|O||D||1
42202001|Cámaras gamma de uso general para uso médico|O|O||D||1
42202002|Sistemas de navegación o accesorios para mapeo linfático|O|O||D||1
42202003|Sondas para mapeo linfático|O|O||D||1
42202004|Colimadores para mapeo linfático|O|O||D||1
42202005|Paquete de procedimiento para mapeo linfático|O|O||D||1
42202006|Densitómetro óseo|O|O||D||1
42202100|Productos de Braquiterapia|O|O||D||1
42202101|Contenedores o semillas de intra cavidad para braquiterapia|O|O||D||1
42202102|Catéteres o jeringas o insertores o aplicadores para braquiterapia|O|O||D||1
42202103|Contenedores de almacenamiento de semillas para braquiterapia|O|O||D||1
42202104|Kits de captura de semillas para braquiterapia|O|O||D||1
42202105|Unidades de braquiterapia|O|O||D||1
42202106|Sistema de aplicador radionúclido manual|O|O||D||1
42202200|Productos de radiación gamma|O|O||D||1
42202201|Colimadores o cascos de cuchillo gamma para radio cirugía|O|O||D||1
42202202|Unidades o centelladores de cuchillos gamma radio quirúrgicos|O|O||D||1
42202203|Sets de almohadillas para cascos de radio cirugía|O|O||D||1
42202204|Sistema de re inhalación radionúclido|O|O||D||1
42202205|Bloque de moldeo de haz de terapia de radiación|O|O||D||1
42202300|Productos de acelerador lineal de terapia de radiación de intensidad modulada (IMRT) médica|O|O||D||1
42202301|Unidades bidimensionales de terapia de radiación de intensidad modulada de acelerador lineal imrt para uso médico|O|O||D||1
42202302|Unidades tridimensionales de terapia de radiación de intensidad modulada de acelerador lineal imrt para uso médico|O|O||D||1
42202303|Colimadores de terapia de radiación de intensidad modulada de acelerador lineal imrt para uso médico|O|O||D||1
42202400|Equipo de tomografía por emisión de positrones (PET) médica y productos relacionados|O|O||D||1
42202401|Unidades de tomografía de emisión de positrones pet para uso médico|O|O||D||1
42202500|Equipo de tomografía informatizada por emisión de fotones simples (SPECT) médica y productos relacionados|O|O||D||1
42202501|Unidades de tomografía de emisión computarizada de fotones únicos spect para uso médico|O|O||D||1
42202600|Productos de administración de radioisótopos y radioimunoterapia|O|O||D||1
42202601|Suministros para terapia de irradiación de tiroides|O|O||D||1
42202602|Kits de pruebas para radio inmunoterapia|O|O||D||1
42202700|Productos de radioterapia tele terapia|O|O||D||1
42202701|Equipo de cobalto 60 para teleterapia radioterapia|O|O||D||1
42202702|Aceleradores lineales para teleterapia radioterapia|O|O||D||1
42202703|Máquinas de rayos x de ortovoltaje para teleterapia radioterapia|O|O||D||1
42202704|Máquinas de rayos x superficiales para teleterapia radioterapia|O|O||D||1
42202900|Equipo radiográfico médico de bajo consumo eléctrico|O|O||D||1
42202901|Unidades de rayos x de baja energía para uso médico|O|O||D||1
42203000|Aceleradores médicos lineales y productos relacionados|O|O||D||1
42203001|Aceleradores lineales móviles o transportables para uso médico|O|O||D||1
42203100|Instrumentos radio biológicos|O|O||D||1
42203101|Micro dosímetros de efecto radio biológico|O|O||D||1
42203200|Simuladores de radioterapia|O|O||D||1
42203201|Simuladores de planeación de radioterapia rf de fluoroscopia y rayos x|O|O||D||1
42203202|Simuladores de radioterapia de tomografía computarizada ct o cat|O|O||D||1
42203300|Sistemas médicos estereotáctica|O|O||D||1
42203301|Sistemas de terapia estereotáctica sin marco|O|O||D||1
42203302|Marcos para la cabeza para terapia estereotáctica|O|O||D||1
42203303|Sistemas de biopsia estereotáctica|O|O||D||1
42203400|Productos para hacer imágenes vasculares y para cardiología intervencionista y laboratorios de cateterización cardiaca|O|O||D||1
42203401|Stents coronarios|O|O||D||1
42203402|Catéteres o sets de diagnóstico o intervención vascular|O|O||D||1
42203403|Introductores de catéteres o sets de diagnóstico o intervención vascular|O|O||D||1
42203404|Alambre guía para imágenes vasculares|O|O||D||1
42203405|Catéter inflable para angioplastia|O|O||D||1
42203406|Dispositivos de remoción de catéteres o sets de diagnóstico o intervención vascular|O|O||D||1
42203407|Sets de entrega de medios de contraste para angiografía|O|O||D||1
42203408|Kits de fundas cardiovasculares|O|O||D||1
42203409|Valvulotomos angioscópicos|O|O||D||1
42203410|Funda de catéter cardiovascular|O|O||D||1
42203411|Carritos para catéteres|O|O||D||1
42203412|Stents periféricos|O|O||D||1
42203413|Bobina vascular|O|O||D||1
42203414|Filtro vascular|O|O||D||1
42203415|Equipo de laboratorio de cateterización cardíaca|O|O||D||1
42203416|Catéter de ablación cardíaca|O|O||D||1
42203417|Endógrafo|O|O||D||1
42203418|Catéter para arterectomía|O|O||D||1
42203419|Stents biliares|O|O||D||1
42203420|Lazo para imágenes vasculares|O|O||D||1
42203421|Bandejas o paquetes para diagnóstico o intervención vascular|O|O||D||1
42203422|Pegante de embolización|O|O||D||1
42203423|Esfera de embolización|O|O||D||1
42203424|Dispositivo de cierre de sitio de procedimiento de cateterización|O|O||D||1
42203425|Catéter para embolectomía trombectomía|O|O||D||1
42203426|Dispositivo de torsión de alambre de guía para angiografía|O|O||D||1
42203427|Aguja de introducción para angiografía|O|O||D||1
42203428|Válvula de control y válvula hemostática para angiografía|O|O||D||1
42203429|Catéter para pericardiocentesis|O|O||D||1
42203430|Catéter de mapeo para electrofisiología|O|O||D||1
42203500|Marcapasos cardiacos o productos relacionados|O|O||D||1
42203501|Generador de marcapasos cardíaco o marcapasos de terapia de re sincronización cardíaca|O|O||D||1
42203502|Cables o electrodos o accesorios para marcapasos cardíacos|O|O||D||1
42203503|Introductores de cables o sets para marcapasos cardíacos|O|O||D||1
42203504|Grabadora cardíaca|O|O||D||1
42203505|Desfibrilador cardiovertidor implantable icd o desfibrilador para terapia de re sincronización cardíaca crt-d|O|O||D||1
42203506|Cables o electrodos de desfibrilador cardiovertidor implantable icd o desfibrilador para terapia de re sincronización cardíaca crt-d|O|O||D||1
42203600|Productos de archivar y información de toma de imágenes radiológicos médicos|O|O||D||1
42203601|Equipos de sistema de red de imágenes digitales de defensa din|O|O||D||1
42203602|Equipos de sistema estándar de comunicaciones de imágenes digitales en medicina dicom|O|O||D||1
42203603|Sistemas de computador para archivo de fotografías médicas pacs|O|O||D||1
42203604|Hardware de sistema de archivo de película de rayos x para usos médicos|O|O||D||1
42203605|Software de sistema de archivo de película de rayos x para usos médicos|O|O||D
42203606|Sistemas de telerradiografía|O|O||D||1
42203700|Suministros y equipo de procesado de toma de imágenes médicos|O|O||D||1
42203701|Estampadores de luz del día para películas de rayos x o impresoras de identificación para uso médico|O|O||D||1
42203702|Procesadores para luz del día o cuarto oscuro de imágenes médicas|O|O||D||1
42203703|Cajas de paso de seguridad de rayos x para uso médico|O|O||D||1
42203704|Toners o desarrolladores para uso médico|O|O||D||1
42203705|Impresoras láser en seco para imágenes o reproductores de imágenes para uso médico|O|O||D||1
42203706|Kits de químicos para procesar películas de rayos x de uso médico|O|O||D||1
42203707|Equipos o suministros de cuarto oscuro de rayos x para uso médico|O|O||D||1
42203708|Fijadores para procesar película de rayos x para uso médico|O|O||D||1
42203709|Sets de calibradores para sistemas de combinación de desplegadores e impresoras de rayos x|O|O||D||1
42203710|Marcadores de películas de rayos x para uso médico|O|O||D||1
42203800|Auxilios de posicionamiento radiológico médico|O|O||D||1
42203801|Ayudas de posicionamiento para tomografía computarizada ct o cat para uso médico|O|O||D||1
42203802|Ayudas de posicionamiento para imágenes de resonancia magnética mri para uso médico|O|O||D||1
42203803|Ayudas de posicionamiento para uso radiológico general para uso médico|O|O||D||1
42203804|Ayudas de posicionamiento para terapias de radiación|O|O||D||1
42203900|Productos para controlar o detectar radiación médica|O|O||D||1
42203901|Dosímetros de radiación para uso médico|O|O||D||1
42203902|Películas o brazaletes de radiación para uso médico|O|O||D||1
42203903|Sistema de terapia de radiación de neutrones para uso médico|O|O||D||1
42204000|Productos de protección y resguardo radiológico médico|O|O||D||1
42204001|Estantes para delantales de protección radiológica para uso médico|O|O||D||1
42204002|Delantales o máscaras o cortinas de protección radiológica para uso médico|O|O||D||1
42204003|Contenedores portátiles de protección para materiales radiológicos radiactivos para uso médico|O|O||D||1
42204004|Auriculares de protección radiológica para uso médico|O|O||D||1
42204005|Guantes de protección radiológica para uso médico|O|O||D||1
42204006|Pantallas de pie o portátiles de protección radiológica para uso médico|O|O||D||1
42204007|Paneles instalados de piso o techo o pared de protección radiológica para uso médico|O|O||D||1
42204008|Cámaras o habitaciones o cajas fuertes de protección radiológica para uso médico|O|O||D||1
42204009|Anteojos de protección radiológica para uso médico|O|O||D||1
42204100|Equipo caliente de laboratorio y productos relacionados para medicina nuclear|O|O||D||1
42204101|Sujetador o cargador o protector para jeringas|O|O||D||1
42211500|Ayuda de ambulación y traslado y posicionar para personas físicamente discapacitadas|O|O||D||1
42211501|Bastones o accesorios para bastones|O|O||D||1
42211502|Muletas o accesorios para muletas|O|O||D||1
42211503|Dispositivos de posicionamiento|O|O||D||1
42211504|Levantadores o ayudas para ponerse de pie|O|O||D||1
42211505|Accesorios para caminadores o andadores|O|O||D||1
42211506|Caminadores o andadores|O|O||D||1
42211507|Dispositivos de cuerpo entero para deslizarse o voltearse|O|O||D||1
42211508|Dispositivos o accesorios de movilidad multifuncional|O|O||D||1
42211509|Cascos protectores de cabeza o cara o dispositivos o accesorios para los discapacitados físicamente|O|O||D||1
42211600|Baño y ayudas de baño para personas físicamente discapacitadas|O|O||D||1
42211601|Tablas para bañarse para los discapacitados físicamente|O|O||D||1
42211602|Cepillos de baño o esponjas o estropajos para los discapacitados físicamente|O|O||D||1
42211603|Elevadores para baño o accesorios para los discapacitados físicamente|O|O||D||1
42211604|Guantes de baño para los discapacitados físicamente|O|O||D||1
42211605|Almohadas de baño para los discapacitados físicamente|O|O||D||1
42211606|Cómodas o accesorios para los discapacitados físicamente|O|O||D||1
42211607|Asientos de inodoro elevados para los discapacitados físicamente|O|O||D||1
42211608|Barras de sujeción o barandas para la tina para los discapacitados físicamente|O|O||D||1
42211610|Asientos o sillas para la ducha o el baño para los discapacitados físicamente|O|O||D||1
42211611|Baños de asiento para los discapacitados físicamente|O|O||D||1
42211612|Soportes de brazos para el inodoro para los discapacitados físicamente|O|O||D||1
42211613|Marcos para el inodoro para los discapacitados físicamente|O|O||D||1
42211614|Asientos de inodoro para los discapacitados físicamente|O|O||D||1
42211615|Levantadores de asientos de inodoro para los discapacitados físicamente|O|O||D||1
42211616|Ayudas de higiene o estimulación de tocador para los discapacitados físicamente|O|O||D||1
42211617|Bancos de transferencia para los discapacitados físicamente|O|O||D||1
42211618|Alarma de pulso de mojada en la cama para los discapacitados físicamente|O|O||D||1
42211619|Jabón protector de ojos y oídos para los discapacitados físicamente|O|O||D||1
42211620|Bandeja o contenedor de champú para los discapacitados físicamente|O|O||D||1
42211700|Ayudas de comunicación para personas físicamente discapacitadas|O|O||D||1
42211701|Interruptores de comunicación adaptativa para los discapacitados físicamente|O|O||D||1
42211702|Dispositivos braille para los discapacitados físicamente|O|O||D||1
42211703|Papel o plástico para escribir braille para los discapacitados físicamente|O|O||D||1
42211704|Señaladores de cabeza o palitos para la boca para los discapacitados físicamente|O|O||D||1
42211705|Ayudas auditivas para los discapacitados físicamente|O|O||D||1
42211706|Tableros de letras o símbolos para los discapacitados físicamente|O|O||D||1
42211707|Dispositivos de telecomunicación tdd o teletipos tty para los discapacitados físicamente|O|O||D||1
42211708|Ayudas telefónicas para los discapacitados físicamente|O|O||D||1
42211709|Ayudas de mecanografía para los discapacitados físicamente|O|O||D||1
42211710|Ayudas de escritura para los discapacitados físicamente|O|O||D||1
42211711|Sintetizadores de voz para los discapacitados físicamente|O|O||D||1
42211712|Estuches para ayudas auditivas|O|O||D||1
42211800|Ayuda para vestirse y asearse para personas físicamente discapacitadas|O|O||D||1
42211801|Ganchos para abotonarse para los discapacitados físicamente|O|O||D||1
42211802|Kits para vestirse para los discapacitados físicamente|O|O||D||1
42211803|Palos para vestirse para los discapacitados físicamente|O|O||D||1
42211804|Cepillos de pelo o peinillas para los discapacitados físicamente|O|O||D||1
42211805|Espejo de inspección para los discapacitados físicamente|O|O||D||1
42211806|Aplicadores de lociones para los discapacitados físicamente|O|O||D||1
42211807|Cuidado de la boca para los discapacitados físicamente|O|O||D||1
42211808|Cortaúñas o limas para los discapacitados físicamente|O|O||D||1
42211809|Ganchos para sujetarse los pantalones para los discapacitados físicamente|O|O||D||1
42211810|Calzadores para los discapacitados físicamente|O|O||D||1
42211811|Hormas de zapatos para los discapacitados físicamente|O|O||D||1
42211812|Media o ayudas para apilar para los discapacitados físicamente|O|O||D||1
42211813|Jaladores de cremalleras para los discapacitados físicamente|O|O||D||1
42211900|Ayuda de preparación de comida y bebida y alimentos para personas físicamente discapacitadas|O|O||D||1
42211901|Materiales anti resbalón para los discapacitados físicamente|O|O||D||1
42211902|Dispositivos de ayuda para cocinar para los discapacitados físicamente|O|O||D||1
42211903|Abre latas para los físicamente discapacitados|O|O||D||1
42211904|Picadores para los discapacitados físicamente|O|O||D||1
42211905|Tazas o tazones (mugs) para los discapacitados físicamente|O|O||D||1
42211906|Sujetadores de cubiertos o de utensilios para los discapacitados físicamente|O|O||D||1
42211907|Cubiertos o utensilios para los discapacitados físicamente|O|O||D||1
42211908|Tablas para cortar o pelar para los discapacitados físicamente|O|O||D||1
42211909|Sujetadores de bebida para los discapacitados físicamente|O|O||D||1
42211910|Baberos o recogedores de comida para los discapacitados físicamente|O|O||D||1
42211911|Forros para comida para los discapacitados físicamente|O|O||D||1
42211912|Sujetadores para dispositivos de cocina para los discapacitados físicamente|O|O||D||1
42211913|Temporizadores digitales jumbo para los discapacitados físicamente|O|O||D||1
42211914|Ayudas para medir para los discapacitados físicamente|O|O||D||1
42211915|Auto alimentadores o accesorios para los discapacitados físicamente|O|O||D||1
42211916|Pitillos o sujeta pitillos para los discapacitados físicamente|O|O||D||1
42211917|Vajillas para los discapacitados físicamente|O|O||D||1
42211918|Balanzas de comida habladoras para los discapacitados físicamente|O|O||D||1
42212000|Cuidado de la casa y ayuda para el cuidado de la casa para personas físicamente discapacitadas|O|O||D||1
42212001|Abridores de puertas para los discapacitados físicamente|O|O||D||1
42212002|Dispositivos para echar llave o sujetadores para los discapacitados físicamente|O|O||D||1
42212003|Dispositivos para abrir puertas para los discapacitados físicamente|O|O||D||1
42212004|Extensiones de interruptores de luz para los discapacitados físicamente|O|O||D||1
42212005|Plumeros o cepillos de mango largo para los discapacitados físicamente|O|O||D||1
42212006|Tijeras que se abren solas para los discapacitados físicamente|O|O||D||1
42212007|Cepillos de succión para los discapacitados físicamente|O|O||D||1
42212100|Aparatos de tiempo libre y recreo para personas físicamente discapacitadas|O|O||D||1
42212101|Barajadores de naipe automáticos para los discapacitados físicamente|O|O||D||1
42212102|Juegos de mesa para los discapacitados físicamente|O|O||D||1
42212103|Sujetadores de libros para los discapacitados físicamente|O|O||D||1
42212104|Naipes de figuras grandes o braille para los discapacitados físicamente|O|O||D||1
42212105|Equipo de camping para los discapacitados físicamente|O|O||D||1
42212106|Ayudas de pesca o cacería para los discapacitados físicamente|O|O||D||1
42212107|Ayudas de flotación o natación para los discapacitados físicamente|O|O||D||1
42212108|Herramientas de jardinería para los discapacitados físicamente|O|O||D||1
42212109|Herramientas o materiales o equipos de manualidades para los discapacitados físicamente|O|O||D||1
42212110|Volteadores de páginas para los discapacitados físicamente|O|O||D||1
42212111|Sujetadores de naipes para los discapacitados físicamente|O|O||D||1
42212112|Ayudas de costura para los discapacitados físicamente|O|O||D||1
42212113|Ayudas para fumar para los discapacitados físicamente|O|O||D||1
42212200|Auxilio de manejo de medicamentos para personas físicamente discapacitadas|O|O||D||1
42212201|Trituradores o partidores de píldoras para los discapacitados físicamente|O|O||D||1
42212202|Organizadores de píldoras para los discapacitados físicamente|O|O||D||1
42212203|Recordadores de píldoras para los discapacitados físicamente|O|O||D||1
42212204|Exprimidores de tubos para los discapacitados físicamente|O|O||D||1
42212300|Ayuda para llegar o agarrar para personas físicamente discapacitadas|O|O||D||1
42212301|Materiales o dispositivos de agarre para los discapacitados físicamente|O|O||D||1
42212302|Sujetadores para los discapacitados físicamente|O|O||D||1
42212303|Abridores de contenedores para los discapacitados físicamente|O|O||D||1
42212304|Alcanzadores para los discapacitados físicamente|O|O||D||1
42221500|Accesorios y catéteres y cánulas intravenosas y arteriales|O|O||D||1
42221501|Catéteres de línea arterial|O|O||D||1
42221502|Válvulas de descarga de catéteres arteriales de línea continua|O|O||D||1
42221503|Catéteres venosos centrales|O|O||D||1
42221504|Catéteres intravenosos periféricos para uso general|O|O||D||1
42221505|Catéteres pediátricos o intravenosos para venas del cuero cabelludo o arteriales|O|O||D||1
42221506|Catéteres umbilicales|O|O||D||1
42221507|Kits de arranque intravenoso o arterial sin catéter|O|O||D||1
42221508|Kits de cuidado de la piel para catéter arterial o intravenoso|O|O||D||1
42221509|Bandejas para catéteres intravenosos o arteriales|O|O||D||1
42221512|Cánulas intravenosas o arteriales y accesorios|O|O||D||1
42221513|Kits de cateterización cardiovascular|O|O||D||1
42221514|Catéter de arteria pulmonar|O|O||D||1
42221515|Kit de reparación de catéter venoso central|O|O||D||1
42221516|Oclusor de la punta del catéter|O|O||D||1
42221517|Catéter para hemodiálisis|O|O||D||1
42221518|Material de vendaje de férulas|O|O||D||1
42221600|Tubería y juegos de administración arterial o intravenoso y productos relacionados|O|O||D||1
42221601|Detectores de burbujas de aire para administración arterial o intravenosa|O|O||D||1
42221602|Puertos o lugares de inyección o tapas o protectores para administración arterial o intravenosa|O|O||D||1
42221603|Tubos de extensión arteriales o intravenosos|O|O||D||1
42221604|Adaptadores o conectores o candados o tapas o protectores para tubos arteriales o intravenosos|O|O||D||1
42221605|Válvulas de chequeo de tubos arteriales o intravenosos|O|O||D||1
42221606|Pinzas de tubos intravenosos o arteriales|O|O||D||1
42221607|Filtros o pantallas para tubos arteriales o intravenosos de uso general|O|O||D||1
42221608|Etiquetas o cintas de identificación de tubos intravenosos o arteriales|O|O||D||1
42221609|Sets de administración de tubos intravenosos o arteriales|O|O||D||1
42221610|Puertos o tapas o protectores de entrada de espiga de tubos intravenosos|O|O||D||1
42221611|Espigas o tapas o protectores de tubos intravenosos|O|O||D||1
42221612|Puertos de inyección o llaves de paso o colectores sin aguja de tubos arteriales o intravenosos|O|O||D||1
42221613|Cierres o broches de extensión de transferencia de tubos intravenosos|O|O||D||1
42221614|Kits de administración de tubos intravenosos con catéter|O|O||D||1
42221615|Tubos intravenosos de medicación secundaria|O|O||D||1
42221616|Sets de extensión arterial o intravenosa|O|O||D||1
42221617|Calentadores de resistencia para agujas|O|O||D||1
42221618|Bandejas para procedimientos arteriales o intravenosos|O|O||D||1
42221619|Kit colector de inyecciones sin aguja|O|O||D||1
42221700|Bolsas de infusión y recipientes y productos relacionados intravenosos y arteriales|O|O||D||1
42221701|Bolsas o contenedores de infusión arterial o intravenosa de único puerto|O|O||D||1
42221702|Bolsas o contenedores de transferencia de infusión arterial o intravenosa|O|O||D||1
42221703|Calentadores de fluido de infusión arterial o intravenosa|O|O||D||1
42221704|Bolsas de infusión de presión arterial o intravenosa|O|O||D||1
42221705|Ensamblajes de vial de infusión de analgésicos|O|O||D||1
42221706|Picos de bolsas o contenedores de transferencia de infusión arterial o intravenosa|O|O||D||1
42221707|Sets o kits de infusión de analgésicos|O|O||D||1
42221800|Aparatos para posicionar aguja y catéter intravenoso o arterial|O|O||D||1
42221801|Forros para tablas de brazo arterial o intravenoso|O|O||D||1
42221802|Tablas de brazo arterial o intravenoso|O|O||D||1
42221803|Cintas o vendajes o correas o mangas para posicionamiento de catéter arterial o intravenoso|O|O||D||1
42221900|Productos de regulación y medida del flujo intravenoso o arterial|O|O||D||1
42221901|Flujómetros o reguladores intravenosos calibrados por dial|O|O||D||1
42221902|Contadores o reguladores de goteo intravenoso|O|O||D||1
42221903|Detectores ultrasónicos de flujo de sangre|O|O||D||1
42221904|Flujómetro de sangre electromagnético|O|O||D||1
42221905|Flujómetro de sangre láser|O|O||D||1
42221906|Flujómetro de sangre de resonancia magnética|O|O||D||1
42222000|Bombas de infusión intravenosa, así como sus analizadores, sensores y accesorios|O|O||D||1
42222001|Bombas de infusión intravenosa de uso general|O|O||D||1
42222002|Bombas de infusión de jeringa intravenosa|O|O||D||1
42222003|Bombas de infusión intravenosa multicanal|O|O||D||1
42222004|Bombas de infusión controlada de analgésicos para pacientes|O|O||D||1
42222005|Partes o accesorios de bombas intravenosas|O|O||D||1
42222006|Analizadores o sensores de bombas de infusión intravenosas|O|O||D||1
42222007|Transductores de bombas de infusión intravenosas|O|O||D||1
42222008|Kits o accesorios de bombas de infusión|O|O||D||1
42222009|Actuador de jeringa para un inyector|O|O||D||1
42222100|Sistemas de transporte y suspensión de equipo arterial y intravenoso|O|O||D||1
42222101|Colgadores de equipos de línea arterial o intravenosa|O|O||D||1
42222102|Rieles o colgadores montados para sistemas de infusión intravenosa por gravedad|O|O||D||1
42222103|Postes de infusión intravenosa para sillas de ruedas|O|O||D||1
42222104|Postes o puestos de línea arterial o intravenosa|O|O||D||1
42222200|Sistemas de inyectar y retirar intravenosos sin aguja|O|O||D||1
42222201|Sets de jeringas de inyección intravenosa sin aguja o cánula de inyección|O|O||D||1
42222202|Cánulas o adaptadores o decantadores para el retiro de vial o bolsa sin aguja|O|O||D||1
42222300|Productos de transfusión y administración de sangre|O|O||D||1
42222301|Kits de administración de transfusión de sangre|O|O||D||1
42222302|Filtros o accesorios o pantallas para transfusión de sangre|O|O||D||1
42222303|Sistemas de identificación para administración o transfusión de sangre|O|O||D||1
42222304|Tubos para administración o transfusión de sangre|O|O||D||1
42222305|Pinzas para tubos de administración o transfusión de sangre|O|O||D||1
42222306|Sistemas de recolección de desechos para administración o transfusión de sangre|O|O||D||1
42222307|Sistemas de calentamiento o transfusión de sangre|O|O||D||1
42222308|Bolsas o contenedores para administración o transfusión de sangre|O|O||D||1
42222309|Sistemas de conservación para administración o transfusión de sangre|O|O||D||1
42231500|Suministros y equipo de alimentación enteral|O|O||D||1
42231501|Bombas de infusión para alimentación enteral|O|O||D||1
42231502|Sets de administración de alimentación enteral|O|O||D||1
42231503|Sets o bandejas de irrigación para alimentación enteral|O|O||D||1
42231504|Bolsas o contenedores para nutrición enteral|O|O||D||1
42231505|Adaptadores o conectores o extensiones para alimentación enteral|O|O||D||1
42231506|Dispositivos para asegurar tubos naso entéricos|O|O||D||1
42231507|Cepillos para limpiar tubos enterales|O|O||D||1
42231508|Válvulas de fijación de alimentación enteral|O|O||D||1
42231509|Cámaras de pesaje de nutrición enteral|O|O||D||1
42231510|Sets de tubos de bombeo de infusión para alimentación enteral|O|O||D||1
42231600|Accesorios o dispositivos de acceso de jejunostomía y gastronomía|O|O||D||1
42231601|Tubos de gastrostomía para uso general|O|O||D||1
42231602|Tubos para gastrostomía endoscópica percutánea|O|O||D||1
42231603|Tubos para yeyunostomía|O|O||D||1
42231604|Botones de acceso gástrico|O|O||D||1
42231605|Sujetadores de tubos de gastrostomía o yeyunostomía|O|O||D||1
42231606|Kits de descompresión del colon|O|O||D||1
42231608|Sets de catéter y aguja para yeyunostomía|O|O||D||1
42231609|Kits de tubos de alimentación para gastrostomía|O|O||D||1
42231700|Tubos naso-entéricos|O|O||D||1
42231701|Tubos nasogástricos|O|O||D||1
42231702|Tubos nasoyeyunales|O|O||D||1
42231703|Tubos de descompresión gástrica|O|O||D||1
42231704|Tubos naso entéricos no clasificados en otra parte|O|O||D||1
42231705|Filtros nasogástricos|O|O||D||1
42231800|Fórmulas y productos para apoyo nutritivo|O|O||D||1|Suplementos alimenticios
42231801|Fórmulas de suplementos para adultos de uso general|O|O||D||1
42231802|Fórmulas de suplementos pediátricos|O|O||D||1
42231803|Fórmulas de suplementos específicos para enfermedades de adultos|O|O||D||1
42231804|Fórmulas de suplementos específicos para enfermedades pediátricas|O|O||D||1
42231805|Barras nutricionales o pudín u otros suplementos|O|O||D||1
42231806|Espesantes de comidas o bebidas nutricionales para uso médico|O|O||D||1
42231807|Chupos de teteros|O|O||D||1
42231808|Botellas de alimentación o accesorios|O|O||D||1
42231900|Equipo y suministros de lactancia materna|O|O||D||1
42231901|Bombas de seno o sus accesorios|O|O||D||1
42231902|Conchas o protectores de senos|O|O||D||1
42231903|Kits de bombas de senos|O|O||D||1
42231904|Almohada para lactancia|O|O||D||1
42232000|Trituradores de pastillas, cortapastillas y productos relacionados|O|O||D||1
42232001|Pulverizadores de tabletas o accesorios|O|O||D||1
42232002|Dispensadores o accesorios de pulverizadores de tabletas|O|O||D||1
42232003|Cortadores de tabletas o accesorios|O|O||D||1
42241500|Suministros de vaciado de escayola y tablillas|O|O||D||1
42241501|Zapatos de yeso|O|O||D||1
42241502|Materiales para acolchonar yesos o tablillas|O|O||D||1
42241503|Protectores de yesos o tablillas|O|O||D||1
42241504|Media o revestimientos para yeso o tablillas|O|O||D||1
42241505|Rollos o cintas para enyesar para uso ortopédico|O|O||D||1
42241506|Material de yeso para tablillas para uso ortopédico|O|O||D||1
42241507|Sistemas de tablillas ortopédicas|O|O||D||1
42241509|Componentes de ortesis termoplástica|O|O||D||1
42241510|Kits o materiales para tablillas termoplásticas|O|O||D||1
42241511|Sets de tablillas de tracción|O|O||D||1
42241512|Materiales de unión de yesos o tablillas|O|O||D||1
42241513|Estuches para transportar y almacenar tablillas o tablillas pre cortadas o sistemas de tablillas|O|O||D||1
42241514|Rollos de instrumentos para sets o accesorios de tablillas|O|O||D||1
42241515|Estuches para tablillas o accesorios|O|O||D||1
42241516|Marcador para material de entablillado|O|O||D||1
42241517|Esparcidor de yeso|O|O||D||1
42241600|Equipo y piezas y accesorios de vaciado de escayola|O|O||D||1
42241601|Carritos para yeso o tablillas|O|O||D||1
42241602|Cortadores o sierras para yeso|O|O||D||1
42241603|Sistemas de remoción de yeso|O|O||D||1
42241604|Vacíos de yeso|O|O||D||1
42241606|Bandejas de impresión de yeso|O|O||D||1
42241607|Puestos de yeso|O|O||D||1
42241700|Productos blandos ortopédicos para la extremidad inferior|O|O||D||1
42241701|Fieltros de recubrimiento ortopédico para tobillo o pie|O|O||D||1
42241702|Fieltros de recubrimiento ortopédico para cadera|O|O||D||1
42241703|Soportes de abrazaderas de rodilla o de abrazaderas de rodilla articuladas|O|O||D||1
42241704|Inmovilizadores o vendas artroscópicas para rodilla|O|O||D||1
42241705|Fieltros de recubrimiento ortopédico para pierna o accesorios|O|O||D||1
42241706|Productos ortóticos o para el cuidado de los pies|O|O||D||1
42241707|Abrazaderas para caminar|O|O||D||1
42241708|Almohadas para fractura del fémur|O|O||D||1
42241709|Zapatos post operatorios o accesorios|O|O||D||1
42241800|Productos blando ortopédicos para el torso y extremidad superior|O|O||D||1
42241801|Fieltros de recubrimiento ortopédico para el brazo|O|O||D||1
42241802|Fieltros de recubrimiento ortopédico para la espalda o lumbares o para el sacro|O|O||D||1
42241803|Collares cervicales o abrazaderas para el cuello|O|O||D||1
42241804|Fieltros de recubrimiento ortopédico para la clavícula|O|O||D||1
42241805|Fieltros de recubrimiento ortopédico para el codo|O|O||D||1
42241806|Fieltros de recubrimiento ortopédico para el antebrazo o la muñeca o el pulgar|O|O||D||1
42241807|Fieltros de recubrimiento ortopédico para la mano o el dedo|O|O||D||1
42241808|Fieltros de recubrimiento ortopédico para las costillas o el abdomen|O|O||D||1
42241809|Fieltros de recubrimiento ortopédico para los hombros|O|O||D||1
42241811|Faja para hernias|O|O||D||1
42241900|Suministros de tablillas dinámicas y batangas|O|O||D||1
42241901|Kits de tablillas estabilizadoras|O|O||D||1
42241902|Partes o accesorios de tablillas estabilizadoras|O|O||D||1
42242000|Dispositivos, accesorios y suministros protésicos|O|O||D||1
42242001|Dispositivos prostéticos para las extremidades inferiores|O|O||D||1
42242002|Dispositivos prostéticos para las extremidades superiores|O|O||D||1
42242003|Dispositivos o accesorios de sujeción prostética|O|O||D||1
42242004|Media o forro prostético de muñón|O|O||D||1
42242100|Suministros y accesorios de tracción ortopédica|O|O||D||1
42242101|Suministros de tracción de brazo|O|O||D||1
42242102|Suministros de tracción de mano o dedos|O|O||D||1
42242103|Suministros de tracción de cabeza o cuello|O|O||D||1
42242104|Suministros de tracción de piernas|O|O||D||1
42242105|Carritos móviles de tracción|O|O||D||1
42242106|Suministros de tracción de pelvis o espalda|O|O||D||1
42242107|Suministros de terapia de tracción de perno|O|O||D||1
42242108|Hardware o pesas de tracción ortopédica|O|O||D||1
42242109|Fieltros de recubrimiento de tracción ortopédica para uso general|O|O||D||1
42242300|Equipo y suministros ortopédicos|O|O||D||1
42242301|Bombas de cicatriz ortopédica|O|O||D||1
42242302|Aplicaciones ortopédicas de miembro superior|O|O||D||1
42251500|Productos de terapia y evaluación sensoria y perceptual y dexteridad y cognitiva|O|O||D||1
42251501|Productos de enseñanza para vestirse|O|O||D||1
42251502|Productos para evaluación o pruebas cognitivas o de destreza o de percepción o sensoriales|O|O||D||1
42251503|Juegos terapéuticos|O|O||D||1
42251504|Tableros perforados o tableros de actividades de uso terapéutico|O|O||D||1
42251505|Rompecabezas de uso terapéutico|O|O||D||1
42251506|Cajas de decoración de uso terapéutico|O|O||D||1
42251600|Equipo y dispositivos de ejercicio de rehabilitación|O|O||D||1
42251601|Vigas de balance o de soporte o mecedoras para rehabilitación o terapia|O|O||D||1
42251602|Dispositivos para escalar para rehabilitación o terapia|O|O||D||1
42251603|Dispositivos o accesorios de moción pasiva continua cpm|O|O||D||1
42251604|Patines de ejercicio de extremidades para rehabilitación o terapia|O|O||D||1
42251605|Pedales de ejercicio para rehabilitación o terapia|O|O||D||1
42251606|Tablas para ejercicios sin gravedad para rehabilitación o terapia|O|O||D||1
42251607|Poleas o accesorios para rehabilitación o terapia|O|O||D||1
42251608|Bandas de ejercicio o masilla o tubos o accesorios para rehabilitación o terapia|O|O||D||1
42251609|Patinetas o patines de ocho figuras para rehabilitación o terapia|O|O||D||1
42251610|Pelotas o accesorios terapéuticos|O|O||D||1
42251611|Dispositivos de movimiento vestibular para rehabilitación o terapia|O|O||D||1
42251612|Pesas o sets o accesorios para rehabilitación o terapia|O|O||D||1
42251613|Bandas caminadoras ejercitadoras para rehabilitación o terapia|O|O||D||1
42251614|Bolsas de arena o sets de bolsas de arena para rehabilitación o terapia|O|O||D||1
42251615|Cinturones de pesas o kits para rehabilitación o terapia|O|O||D||1
42251616|Vibradores eléctricos para rehabilitación o terapia|O|O||D||1
42251617|Asientos acolchonados o accesorios terapéuticos|O|O||D||1
42251618|Ejercitadoras de muñecas para rehabilitación o terapia|O|O||D||1
42251619|Arcilla cerámica terapéutica o accesorios|O|O||D||1
42251620|Esterillas o plataformas para rehabilitación o terapia|O|O||D||1
42251621|Ejercitadoras de bota para rehabilitación o terapia|O|O||D||1
42251622|Ejercitadoras de pulmón para rehabilitación o terapia|O|O||D||1
42251623|Aparatos o suministros para terapia ultrasónica|O|O||D||1
42251624|Máquinas de pesas para rehabilitación o terapia|O|O||D||1
42251625|Equipos de ejercicio de mandíbulas|O|O||D||1
42251700|Productos para entrenamiento del modo de andar|O|O||D||1
42251701|Cinturones de manera de caminar para rehabilitación o terapia|O|O||D||1
42251702|Rampas de entrenamiento para rehabilitación o terapia|O|O||D||1
42251703|Escaleras de entrenamiento para rehabilitación o terapia|O|O||D||1
42251704|Barras de manera de caminar para rehabilitación o terapia|O|O||D||1
42251705|Barras paralelas para rehabilitación o terapia|O|O||D||1
42251706|Caminadoras o bicicletas o ejercitadoras de manera de caminar|O|O||D||1
42251800|Equipo para hacer dura el trabajo para rehabilitación o terapia|O|O||D||1
42251801|Tableros de salto o accesorios para rehabilitación o terapia|O|O||D||1
42251802|Cajas de levantar o accesorios para rehabilitación o terapia|O|O||D||1
42251803|Árboles de tubos o accesorios para rehabilitación o terapia|O|O||D||1
42251804|Carros de halar o empujar o accesorios para rehabilitación o terapia|O|O||D||1
42251805|Mesas o estaciones de trabajo o accesorios para rehabilitación o terapia|O|O||D||1
42261500|Suministros y instrumentos para disección de patología|O|O||D||1
42261501|Tijeras para autopsias|O|O||D||1
42261502|Fórceps de disección de uso general para autopsias|O|O||D||1
42261503|Sondas de bala para autopsias|O|O||D||1
42261504|Jaladores de hilo o aguja para autopsias|O|O||D||1
42261505|Cuchillos o cuchillas para autopsias|O|O||D||1
42261506|Cinceles u osteotomos para autopsias|O|O||D||1
42261507|Hilo post mortem|O|O||D||1
42261508|Agujas post mortem|O|O||D||1
42261509|Kits de disección para autopsias|O|O||D||1
42261510|Ganchos de incisión post mortem|O|O||D||1
42261511|Directores de vena para autopsias|O|O||D||1
42261512|Sierras para autopsias|O|O||D||1
42261513|Cuchillas de sierra o accesorios para autopsias|O|O||D||1
42261514|Tablas o almohadillas de disección|O|O||D||1
42261515|Estuches para instrumentos o accesorios quirúrgicos post mortem|O|O||D||1
42261516|Rollos de instrumentos para instrumentos o accesorios quirúrgicos post mortem|O|O||D||1
42261600|Suministros y equipo de autopsia|O|O||D||1
42261601|Recolectores de polvo de huesos|O|O||D||1
42261602|Bolsa para cadáver de uso médico|O|O||D||1
42261604|Apoya cabezas para autopsias|O|O||D||1
42261605|Tablas de cuerpo para autopsias|O|O||D||1
42261606|Balanzas colgantes para autopsias|O|O||D||1
42261607|Bolsas o contenedores para especímenes para autopsias|O|O||D||1
42261608|Kits de enfermedades infecciosas para autopsias|O|O||D||1
42261609|Cintas o brazaletes de identificación post mortem|O|O||D||1
42261610|Aspiradoras o tubos de vacío para recolección de fluidos para autopsias|O|O||D||1
42261611|Termómetros rectales post mortem|O|O||D||1
42261612|Dispositivos para enderezar dedos post mortem|O|O||D||1
42261613|Kits de construcción de tejidos de cadáveres|O|O||D||1
42261700|Muebles de autopsia|O|O||D||1
42261701|Estaciones de trabajo para autopsia macroscópica o accesorios|O|O||D||1
42261702|Lavaderos o accesorios para autopsias|O|O||D||1
42261703|Tablas o accesorios para autopsias|O|O||D||1
42261704|Tablas para necropsia o accesorios|O|O||D||1
42261705|Tablas o accesorios para disección de animales post mortem|O|O||D||1
42261706|Estaciones de trabajo para embalsamar o accesorios|O|O||D||1
42261707|Estaciones de trabajo para autopsias de drenaje o accesorios|O|O||D||1
42261800|Equipo y suministros de transporte y almacenaje del cadáver|O|O||D||1
42261801|Gabinetes de almacenamiento de cadáveres|O|O||D||1
42261802|Transportadores de cadáveres|O|O||D||1
42261803|Poleas de elevación de tijeras para cadáveres|O|O||D||1
42261804|Gabinetes refrigeradores para las morgues|O|O||D||1
42261805|Cuartos refrigeradores para la morgue|O|O||D||1
42261806|Congeladores para morgues|O|O||D||1
42261807|Carritos de autopsia|O|O||D||1
42261808|Bandejas para cadáveres|O|O||D||1
42261809|Dispositivos de elevación o transferencia de cadáveres|O|O||D||1
42261810|Contenedores para transporte de cuerpos|O|O||D||1
42261900|Equipo y suministros forenses clínicos|O|O||D||1
42261901|Materiales de huellas dactilares o impresión post mortem|O|O||D||1
42261902|Máscaras anti putrefacción|O|O||D||1
42261903|Kits o suministros de detección de sangre post mortem|O|O||D||1
42261904|Kits de recolección de evidencia biológica|O|O||D||1
42262000|Equipo y suministros de embalsamar|O|O||D||1
42262001|Inyectores de cavidad para embalsamar|O|O||D||1
42262002|Tubos de drenaje de venas para embalsamar|O|O||D||1
42262003|Fluidos para embalsamar o tratamientos químicos|O|O||D||1
42262004|Tubos de inyección para embalsamar|O|O||D||1
42262005|Lavaderos o accesorios para embalsamar|O|O||D||1
42262006|Kits para embalsamar|O|O||D||1
42262007|Agujas inyectoras para embalsamar|O|O||D||1
42262008|Protectores de ojos|O|O||D||1
42262100|Equipo y suministros funerarios|O|O||D||1
42262101|Trajes mortuorios|O|O||D||1
42262102|Paquetes mortuorios|O|O||D||1
42262103|Lienzos mortuorios|O|O||D||1
42262104|Aspiradoras mortuorias|O|O||D||1
42262105|Compuestos endurecedores mortuorios|O|O||D||1
42271500|Productos para el control respiratorio|O|O||D||1
42271501|Monitores de apnea o accesorios|O|O||D||1
42271502|Monitores de gas arterial o accesorios|O|O||D||1
42271503|Monitores de óxido de carbono exhalado o suministros|O|O||D||1
42271504|Estetoscopios esofágicos|O|O||D||1
42271505|Kits de monitoreo respiratorio o sus accesorios|O|O||D||1
42271506|Monitores de oxígeno o suministros|O|O||D||1
42271600|Productos de comprobación y tratamiento de las funciones pulmonares|O|O||D||1
42271601|Pletismógrafos de cuerpo|O|O||D||1
42271602|Espirómetros o sus accesorios o suministros|O|O||D||1
42271603|Pantallas de función pulmonar para junto a la cama|O|O||D||1
42271604|Flujómetros de pico|O|O||D||1
42271605|Calculadoras de función pulmonar|O|O||D||1
42271606|Dispositivos de calibración pulmonar|O|O||D||1
42271607|Tubos de función pulmonar o accesorios|O|O||D||1
42271608|Productos de prueba de estrés pulmonar|O|O||D||1
42271609|Monitores de estudio de sueño o accesorios|O|O||D||1
42271610|Monitores transcutáneos o productos relacionados|O|O||D||1
42271611|Monitores de ventilación pulmonar|O|O||D||1
42271612|Analizadores o monitores de gas pulmonar|O|O||D||1
42271613|Monitores de presión pulmonar|O|O||D||1
42271614|Monitores de temperatura respiratoria|O|O||D||1
42271615|Neumotacos|O|O||D||1
42271616|Filtros de monitoreo de función pulmonar|O|O||D||1
42271617|Percusores de pecho|O|O||D||1
42271618|Estilógrafos grabadores para espirómetros|O|O||D||1
42271619|Entrenador de músculos de inhalación|O|O||D||1
42271620|Monitor de agua en los pulmones|O|O||D||1
42271621|Dispositivo de terapia de presión de exhalación positiva pep|O|O||D||1
42271622|Chaleco de despeje de vías aéreas|O|O||D||1
42271700|Sistemas y dispositivos de terapia de entrega de oxígeno|O|O||D||1
42271701|Cilindros de gas o dispositivos relacionados para uso médico|O|O||D||1
42271702|Concentradores de oxígeno|O|O||D||1
42271703|Mezcladores de aire de oxígeno|O|O||D||1
42271704|Temporizadores de oxígeno|O|O||D||1
42271705|Conectores o adaptadores de suministro de oxígeno|O|O||D||1
42271706|Compresores para terapia respiratoria|O|O||D||1
42271707|Sensores de flujo o reguladores o componentes|O|O||D||1
42271708|Máscaras de oxígeno o partes para uso médico|O|O||D||1
42271709|Cánulas nasales para uso médico|O|O||D||1
42271710|Catéteres nasales o kits de cateterización para uso médico|O|O||D||1
42271711|Capuchas para la cabeza para uso médico|O|O||D||1
42271712|Carpas de aerosol para uso médico|O|O||D||1
42271713|Cámaras hiperbáricas para uso médico|O|O||D||1
42271714|Incubadoras para uso médico|O|O||D||1
42271715|Tubos o conectores de oxígeno para uso médico|O|O||D||1
42271716|Estuches para insufladores nasales|O|O||D||1
42271717|Inhaladores o sets|O|O||D||1
42271718|Accesorios para productos de sistemas de entrega de oxígeno para terapia o sus suministros|O|O||D||1
42271719|Insuflador de oxígeno o sus accesorios|O|O||D||1
42271720|Convertidores de oxígeno líquido|O|O||D||1
42271721|Filtros de concentradores de oxígeno|O|O||D||1
42271722|Computador de toma de oxígeno|O|O||D||1
42271800|Productos de terapia aerosol y humedad respiratoria|O|O||D||1
42271801|Humidificadores o vaporizadores respiratorios|O|O||D||1
42271802|Nebulizadores o accesorios|O|O||D||1
42271803|Sets de transferencia para terapia respiratoria|O|O||D||1
42271900|Productos para la gestión de la vía aérea|O|O||D||1
42271901|Vías aéreas faríngeas|O|O||D||1
42271902|Tubos esofágicos|O|O||D||1
42271903|Tubos endotraqueales|O|O||D||1
42271904|Tubos de traqueotomía|O|O||D||1
42271905|Tubos endobronquiales|O|O||D||1
42271906|Kits de reparación de tubos endotraqueales o de traqueotomía|O|O||D||1
42271907|Productos de aspiradores respiratorios o accesorios|O|O||D||1
42271908|Sujetadores de vías aéreas artificiales|O|O||D||1
42271909|Accesorios de vías aéreas artificiales|O|O||D||1
42271910|Sets endotraqueales o de traqueotomía|O|O||D||1
42271911|Kits de manómetros respiratorios|O|O||D||1
42271912|Tubos nasofaríngeos|O|O||D||1
42271913|Vías aéreas faríngeas o kits de vías aéreas|O|O||D||1
42271914|Mordazas de presión de vías aéreas|O|O||D||1
42271915|Accesorios de traqueotomía|O|O||D||1
42271916|Faringómetro o accesorios|O|O||D||1
42272000|Suministros de intubación|O|O||D||1
42272001|Laringoscopios o accesorios|O|O||D||1
42272002|Aerosoles laríngeos|O|O||D||1
42272003|Bloques de mordida|O|O||D||1
42272004|Estiletes de intubación|O|O||D||1
42272005|Fórceps de intubación|O|O||D||1
42272006|Introductores|O|O||D||1
42272007|Herramientas de doblado|O|O||D||1
42272008|Sondas o guías de intubación|O|O||D||1
42272009|Detectores de dióxido de carbono para pacientes|O|O||D||1
42272011|Catéteres de succión o sus accesorios|O|O||D||1
42272016|Quillas laríngeas o accesorios|O|O||D||1
42272017|Componentes o accesorios de intubación|O|O||D||1
42272100|Ventiladores de presión mecánica negativa|O|O||D||1
42272101|Pulmón de hierro|O|O||D||1
42272102|Productos de coraza de pecho|O|O||D||1
42272200|Ventiladores y accesorios de presión mecánica positiva|O|O||D||1
42272201|Máquinas respiradoras de presión positiva intermitente ippb|O|O||D||1|Respiradores para SARS-CoV-2, Respiradores para COVID, Respiradores para COVID-19
42272202|Máquinas de presión de aire positivo continuo no invasivo|O|O||D||1
42272203|Máquinas de doble nivel no invasivas|O|O||D||1
42272204|Ventiladores de transporte|O|O||D||1
42272205|Ventiladores para cuidados intensivos de adultos o pediátricos|O|O||D||1
42272206|Ventiladores para cuidado intensivo de bebés|O|O||D||1
42272207|Ventiladores de alta frecuencia|O|O||D||1
42272208|Ventiladores de cuidado en casa|O|O||D||1
42272209|Circuitos de ventiladores o de respiración|O|O||D||1
42272210|Bolsas de circuito de respiración|O|O||D||1
42272211|Productos de hiperventilación|O|O||D||1
42272212|Válvulas de presión de exhalación y positiva peep|O|O||D||1
42272213|Máscaras o correas de presión de vías aéreas positivas continuas cpap|O|O||D||1
42272214|Conectores o adaptadores o válvulas de circuitos|O|O||D||1
42272215|Suministros de chequeo de ventiladores|O|O||D||1
42272216|Termómetros de ventiladores|O|O||D||1
42272217|Trampas de agua para ventiladores|O|O||D||1
42272218|Puertos o líneas de muestreo de gas para ventiladores|O|O||D||1
42272219|Intercambiadores o filtros de calor o humedad para ventiladores|O|O||D||1
42272220|Accesorios para ventiladores|O|O||D||1
42272221|Productos de humidificación para ventiladores|O|O||D||1
42272222|Productos de retiro del tubo para ventiladores|O|O||D||1
42272223|Accesorios o suministros para respiradores|O|O||D||1
42272224|Kits de circuitos para ventiladores|O|O||D||1
42272225|Accesorios de presión para vías aéreas positivas de doble nivel bi pap|O|O||D||1
42272300|Suministros de resucitadores|O|O||D||1
42272301|Resucitadores manuales|O|O||D||1
42272302|Resucitadores neumáticos|O|O||D||1
42272303|Máscaras o accesorios de resucitación|O|O||D||1
42272304|Componentes o accesorios de resucitación|O|O||D||1
42272305|Conectores de resucitación|O|O||D||1
42272306|Kits de resucitación|O|O||D||1
42272307|Estuches para aparatos o accesorios de resucitación|O|O||D||1
42272500|Aparatos de anestesia, y accesorios y suministros|O|O||D||1
42272501|Aparatos de gas de anestesia|O|O||D||1
42272502|Unidades de absorción para aparatos de gas de anestesia|O|O||D||1
42272503|Inhaladores de anestesia o unidades de inhalación o accesorios|O|O||D||1
42272505|Tubos para aparatos de gas de anestesia o ensamblajes de tubos o ajustes de tubos o accesorios|O|O||D||1
42272506|Filtros de pantalla para aparatos de anestesia|O|O||D||1
42272507|Control de temperatura para aparatos de anestesia|O|O||D||1
42272508|Bomba intratecal|O|O||D||1
42272509|Calibradores para máquina de anestesia o accesorios|O|O||D||1
42272510|Kits o accesorios para actualización de máquina de anestesia|O|O||D||1
42281500|Equipo y accesorios de esterilizadores y de autoclave|O|O||D||1
42281501|Esterilizadores químicos o de gas|O|O||D||1
42281502|Esterilizadores de aire seco o de aire caliente|O|O||D||1
42281503|Esterilizadores de filtro|O|O||D||1
42281504|Esterilizadores de bolas de vidrio|O|O||D||1
42281505|Manijas de elevación para contenedores o bandejas de esterilización|O|O||D||1
42281506|Dispositivos o accesorios eléctricos para limpieza de instrumentos|O|O||D||1
42281507|Esterilizadores de radiación|O|O||D||1
42281508|Autoclaves o esterilizadores de vapor|O|O||D||1
42281509|Contenedores o bandejas de esterilización|O|O||D||1
42281510|Ganchos o estantes o sujetadores para instrumentos de esterilización|O|O||D||1
42281511|Lámparas de esterilización|O|O||D||1
42281512|Tapas de esterilización|O|O||D||1
42281513|Placas de identificación de esterilización|O|O||D||1
42281514|Calentadores sanitarios o accesorios|O|O||D||1
42281515|Gabinetes de esterilización|O|O||D||1
42281516|Filtros de esterilización|O|O||D||1
42281517|Sistemas de recuperación de agua de esterilización|O|O||D||1
42281518|Barras para cánulas de esterilización|O|O||D||1
42281519|Esterilizadores de agujas|O|O||D||1
42281521|Sets de esterilización|O|O||D||1
42281522|Instrumentos de esterilización o insertos de estuches de esterilización|O|O||D||1
42281523|Mangas de filtro de esterilización|O|O||D||1
42281524|Adaptadores o ensamblajes de adaptadores de esterilización|O|O||D||1
42281525|Aireador de gas o químico o de radiación de esterilización|O|O||D||1
42281526|Prueba de indicador biológico para incubadoras|O|O||D||1
42281527|Concentrado o casete o cartucho de esterilizante de esterilización|O|O||D||1
42281528|Accesorios para esterilizador químico o de gas|O|O||D||1
42281529|Accesorios para esterilizador de aire seco o de aire caliente|O|O||D||1
42281530|Accesorios para esterilizador o autoclave de vapor|O|O||D||1
42281531|Esterilizador ultravioleta|O|O||D||1
42281532|Esterilizador de plasma de gas|O|O||D||1
42281600|Soluciones de desinfectantes y esterilización en frío|O|O||D||1
42281603|Desinfectante o esterilizador de instrumentos|O|O||D||1
42281604|Desinfectantes de superficies para uso médico|O|O||D||1
42281605|Compuestos anti fijación para uso médico|O|O||D||1
42281606|Fumigadores de gas para uso médico|O|O||D||1
42281700|Soluciones y equipo de limpieza pre- esterilización|O|O||D||1
42281701|Limpiadores de cámara para autoclaves o esterilizadores|O|O||D||1
42281702|Baldes de remojo desinfectantes|O|O||D||1|Cubetas de remojo desinfectantes
42281703|Kits de cuidado de instrumentos|O|O||D||1
42281704|Limpiadores o detergentes para instrumentos|O|O||D||1
42281705|Equipo de lavado desinfectante para equipos e instrumentos de uso médico|O|O||D||1
42281706|Lubricantes o leche para instrumentos|O|O||D||1
42281707|Almohadillas para remover manchas de los instrumentos|O|O||D||1
42281708|Limpiadores de carros de esterilización|O|O||D||1
42281709|Cepillos de limpieza de esterilización|O|O||D||1
42281710|Desodorantes de esterilización|O|O||D||1
42281711|Desincrustadores de esterilización|O|O||D||1
42281712|Equipo de limpieza ultrasónica|O|O||D||1
42281713|Baldes de escurrido de esterilización|O|O||D||1|Cubetas de escurrido para esterilización
42281800|Controles y indicadores de esterilización|O|O||D||1
42281801|Tiras de prueba de desinfección|O|O||D||1
42281802|Etiquetas de esterilización|O|O||D||1
42281803|Kits biológicos de esterilización|O|O||D||1
42281804|Controles de esterilización|O|O||D||1
42281805|Registros indicadores de esterilización|O|O||D||1
42281806|Tiras indicadoras de esterilización|O|O||D||1
42281807|Cintas indicadoras de esterilización|O|O||D||1
42281808|Papeles u hojas de esterilización|O|O||D||1
42281809|Sobres de almacenamiento de registros de esterilización|O|O||D||1
42281810|Paquetes de prueba y accesorios de esterilización|O|O||D||1
42281811|Candado para contenedor de esterilización|O|O||D||1
42281900|Suministros de empaquetar y envoltura de esterilización|O|O||D||1
42281901|Sujetadores o carritos para envoltorios o sobres de esterilización|O|O||D||1
42281902|Fundas o sobre fundas de esterilización|O|O||D||1
42281903|Cubiertas contra el polvo de esterilización|O|O||D||1
42281904|Bolsas de esterilización|O|O||D||1
42281905|Selladores en caliente de esterilización|O|O||D||1
42281906|Bandas de instrumentos de esterilización|O|O||D||1
42281907|Protectores de instrumentos de esterilización|O|O||D||1
42281908|Recubrimientos de bandejas de instrumentos de esterilización|O|O||D||1
42281909|Pistolas o cintas o esferos etiquetadores de esterilización|O|O||D||1
42281912|Toallas de esterilización|O|O||D||1
42281913|Tunos de esterilización|O|O||D||1
42281914|Contenedores desechables de esterilización|O|O||D||1
42281915|Rollos de esterilización|O|O||D||1
42281916|Talegos de esterilización|O|O||D||1
42291500|Instrumentos quirúrgicos y productos relacionados para biopsia de los huesos|O|O||D||1
42291501|Molinos para biopsia de hueso para uso quirúrgico o productos relacionados|O|O||D||1
42291502|Trepanadores para biopsia de hueso para uso quirúrgico|O|O||D||1
42291600|Instrumentos quirúrgicos de cortar y lazos y productos relacionados|O|O||D||1
42291601|Escalpelos o cuchillos o manijas de cuchillos láser para uso quirúrgico|O|O||D||1
42291602|Tornillos o cables o alfileres o instrumentos para cortar alambre para uso quirúrgico|O|O||D||1
42291603|Fórceps para cortar hueso para uso quirúrgico|O|O||D||1
42291604|Sierras de mano o sierras de alambre o manijas para sierras para huesos para uso quirúrgico|O|O||D||1
42291605|Brocas para uso quirúrgico|O|O||D||1
42291606|Cinceles o perforadoras para uso quirúrgico|O|O||D||1
42291607|Curetas o lanzaderas para uso quirúrgico|O|O||D||1
42291608|Bloques o tablas o plataformas de cortado para uso quirúrgico|O|O||D||1
42291609|Pinzas para uso quirúrgico|O|O||D||1
42291610|Planos para uso quirúrgico|O|O||D||1
42291611|Raspadores para uso quirúrgico|O|O||D||1
42291612|Tenazas para uso quirúrgico|O|O||D||1
42291613|Escalpelos o cuchillos o cuchillas o trepanadores o accesorios para uso quirúrgico|O|O||D||1
42291614|Tijeras para uso quirúrgico|O|O||D||1
42291615|Tijeras para uso quirúrgico|O|O||D||1
42291616|Pinzas o cables de pinzas para uso quirúrgico|O|O||D||1
42291617|Espitas para uso quirúrgico|O|O||D||1
42291619|Tomos (pinzas de resección) para uso quirúrgico|O|O||D||1
42291620|Trocadores quirúrgicos para uso general o accesorios|O|O||D||1
42291621|Removedores de anillos de los dedos|O|O||D||1
42291622|Adenotomos|O|O||D||1
42291623|Periosteotomos|O|O||D||1
42291624|Meniscotomos|O|O||D||1
42291625|Instrumentos de incisión del talón de los bebés|O|O||D||1
42291627|Taladros quirúrgicos o sus accesorios|O|O||D||1
42291700|Taladros quirúrgicos de mano y escariadores y instrumentos de punción y accesorios y productos relacionados|O|O||D||1
42291701|Brocas de mano o de torsión o kits de brocas o accesorios para uso quirúrgico|O|O||D||1
42291702|Escariadores o punzones de mano para uso quirúrgico|O|O||D||1
42291703|Perforadoras para uso quirúrgico|O|O||D||1
42291704|Punzones o sujeta punzones o accesorios para uso quirúrgico|O|O||D||1
42291705|Adaptadores de escariadores para uso quirúrgico|O|O||D||1
42291707|Kits de craneotomía|O|O||D||1
42291708|Brocas o accesorios para uso quirúrgico|O|O||D||1
42291709|Cuchillas de sierra o accesorios para uso quirúrgico|O|O||D||1
42291710|Gancho amniótico|O|O||D||1
42291800|Abrazaderas quirúrgicas y fórceps y ligadores quirúrgicos y instrumentos relacionados|O|O||D||1
42291801|Aplicadores de ligantes de bandas o bandas o productos relacionados para uso quirúrgico|O|O||D||1
42291802|Pinzas o ganchos o fórceps o accesorios para uso quirúrgico|O|O||D||1
42291803|Pinzas o fórceps láser para uso quirúrgico|O|O||D||1
42291804|Pinzas o campana de circuncisión|O|O||D||1
42291805|Pinza de cordón umbilical de recién nacidos|O|O||D||1
42291900|Posicionadores y portadores de tubos y instrumentos quirúrgicos|O|O||D||1
42291901|Sujetadores o posicionadores de instrumentos quirúrgicos|O|O||D||1
42291902|Sujetadores o posicionadores de tubos para uso quirúrgico|O|O||D||1
42292000|Espejos quirúrgicos|O|O||D||1
42292001|Espejos de otolaringología o accesorios para uso quirúrgico|O|O||D||1
42292100|Insertadores y extractores quirúrgicos y productos relacionados|O|O||D||1
42292101|Insertores o kits de insertores para uso quirúrgico|O|O||D||1
42292102|Extractores para uso quirúrgico|O|O||D||1
42292103|Porta tubos o llaves para uso quirúrgico|O|O||D||1
42292200|Aproximadores y compresores y depresores quirúrgicos y productos relacionados|O|O||D||1
42292201|Aproximadores para uso quirúrgico|O|O||D||1
42292202|Compresores para uso quirúrgico|O|O||D||1
42292203|Depresores para uso quirúrgico|O|O||D||1
42292300|Hierros de flexión y herramientas de plegar y tenazas y tensionadores y torceduras quirúrgicos y productos relacionados|O|O||D||1
42292301|Instrumentos para doblar para uso quirúrgico|O|O||D||1
42292302|Engarzadores para uso quirúrgico|O|O||D||1
42292303|Alicates para uso quirúrgico|O|O||D||1
42292304|Tensores para uso quirúrgico|O|O||D||1
42292305|Agarres para uso quirúrgico|O|O||D||1
42292306|Fórceps o tenazas de alambre para uso quirúrgico|O|O||D||1
42292307|Llaves para uso quirúrgico|O|O||D||1
42292400|Machos de roscar y impulsores quirúrgicos y productos relacionados|O|O||D||1
42292401|Roscas para uso quirúrgico|O|O||D||1
42292402|Controladores o sus partes o accesorios para uso quirúrgico|O|O||D||1
42292403|Mangos de hachas para uso quirúrgico|O|O||D||1
42292500|Martillos y malletes y impactadores y prensas quirúrgicos y productos relacionados|O|O||D||1
42292501|Tapones para uso quirúrgico|O|O||D||1
42292502|Martillos o martillos quirúrgicos para uso quirúrgico|O|O||D||1
42292503|Impactadores o empacadores para uso quirúrgico|O|O||D||1
42292504|Prensas para uso quirúrgico|O|O||D||1
42292505|Martillos o cabezas de martillo para uso quirúrgico|O|O||D||1
42292600|Dilatadores y sondas y ranuras quirúrgicas y productos relacionados|O|O||D||1
42292601|Dilatadores o accesorios para uso quirúrgico|O|O||D||1
42292602|Muescas para uso quirúrgico|O|O||D||1
42292603|Sondas o directores para uso quirúrgico|O|O||D||1
42292700|Disectores y Elevadores y Piquetas quirúrgicos y productos relacionados|O|O||D||1
42292701|Disectores para uso quirúrgico|O|O||D||1
42292702|Levantadores o niveladores para uso quirúrgico|O|O||D||1
42292703|Elevadores para uso quirúrgico|O|O||D||1
42292704|Picas para uso quirúrgico|O|O||D||1
42292800|Instrumentos quirúrgicos de marcar|O|O||D||1
42292801|Instrumentos de marcación oftálmica|O|O||D||1
42292802|Instrumentos de marcación quirúrgica para uso general|O|O||D||1
42292803|Dispositivo de sellamiento y marcado de biopsias|O|O||D||1
42292900|Instrumentos quirúrgicos de cerrar la sutura de tejido y productos relacionados|O|O||D||1
42292901|Instrumentos de cerclaje para uso quirúrgico|O|O||D||1
42292902|Sujetadores de aguja láser para uso quirúrgico|O|O||D||1
42292903|Sujetadores de agujas quirúrgicas para uso general|O|O||D||1
42292904|Suturas quirúrgicas o pasadores de alambre o productos relacionados|O|O||D||1
42292907|Sistemas para estirar la piel|O|O||D||1
42292908|Dispositivos de costura de bolsa para uso quirúrgico|O|O||D||1
42293000|Dispositivos quirúrgicos de medir y productos relacionados|O|O||D||1
42293001|Calibradores o reglas para uso quirúrgico|O|O||D||1
42293002|Sondas o varas de medición para uso quirúrgico|O|O||D||1
42293003|Instrumentos de medición de ganchos para uso quirúrgico|O|O||D||1
42293004|Instrumentos quirúrgicos de determinación de tamaño para uso general|O|O||D||1
42293005|Instrumentos de determinación de tamaño de válvula para uso quirúrgico|O|O||D||1
42293006|Cintas de medición para uso quirúrgico|O|O||D||1
42293100|Retractores quirúrgicos y productos relacionados|O|O||D||1
42293101|Retractores láser para uso quirúrgico|O|O||D||1
42293102|Ganchos de retracción para uso quirúrgico|O|O||D||1
42293103|Retractores de fibra óptica iluminados para uso quirúrgico|O|O||D||1
42293104|Mordazas o accesorios para uso quirúrgico|O|O||D||1
42293105|Retractores de inclinación para uso quirúrgico|O|O||D||1
42293106|Sets de retractores para uso quirúrgico|O|O||D||1
42293107|Retractores quirúrgicos para uso general|O|O||D||1
42293108|Estabilizadores para uso quirúrgico|O|O||D||1
42293109|Protectores de tejidos para uso quirúrgico|O|O||D||1
42293110|Retractores ortopédicos|O|O||D||1
42293111|Retractores oftálmicos|O|O||D||1
42293112|Retractores torácicos o cardiovasculares|O|O||D||1
42293113|Retractores de vena|O|O||D||1
42293114|Retractores bucales|O|O||D||1
42293115|Retractores traqueales|O|O||D||1
42293116|Retractores rectales|O|O||D||1
42293117|Retractores gastrointestinales|O|O||D||1
42293118|Retractores uterinos|O|O||D||1
42293119|Retractores abdominales|O|O||D||1
42293120|Retractores de columna o nervios|O|O||D||1
42293121|Retractores de glándulas|O|O||D||1
42293122|Retractores de oído|O|O||D||1
42293123|Retractores para cirugía plástica|O|O||D||1
42293124|Retractores de nervios|O|O||D||1
42293125|Retractores de esternón|O|O||D||1
42293126|Retractores para amputación|O|O||D||1
42293127|Retractores de tejidos|O|O||D||1
42293128|Retractores de piel|O|O||D||1
42293129|Retractores para micro cirugía|O|O||D||1
42293130|Retractores de pulmón|O|O||D||1
42293131|Retractores de párpado|O|O||D||1
42293132|Retractores de dedos|O|O||D||1
42293133|Anillos de retracción para uso quirúrgico|O|O||D||1
42293134|Retractores cervicales|O|O||D||1
42293135|Retractores de labios|O|O||D||1
42293136|Adaptadores de retractores|O|O||D||1
42293137|Cuchillas retractoras ortopédicas|O|O||D||1
42293138|Retractores para urología o sus accesorios para uso quirúrgico|O|O||D||1
42293139|Accesorios para retractores|O|O||D||1
42293200|Instrumentos quirúrgicos de mioma|O|O||D||1
42293201|Destornilladores para miomas para uso quirúrgico|O|O||D||1
42293300|Distractores y esparcidores y separadores quirúrgicos y productos relacionados|O|O||D||1
42293301|Distractores o accesorios para uso quirúrgico|O|O||D||1
42293302|Separadores para uso quirúrgico|O|O||D||1
42293303|Espéculos para uso quirúrgico|O|O||D||1
42293304|Extensores para uso quirúrgico|O|O||D||1
42293400|Manipuladores y posicionadores quirúrgicos de implante y productos relacionados|O|O||D||1
42293401|Guías para uso quirúrgico|O|O||D||1
42293403|Sujetadores de implantes para uso quirúrgico|O|O||D||1
42293404|Empujadores para uso quirúrgico|O|O||D||1
42293405|Instrumentos de manipulación para uso quirúrgico|O|O||D||1
42293406|Posicionadores de implantes para uso quirúrgico|O|O||D||1
42293407|Filiforme para dilatar el uréter o la uretra|O|O||D||1
42293408|Seguidor para uréter o uretra|O|O||D||1
42293500|Cánulas y puntas y estiletes de irrigación y succión quirúrgica y productos relacionados|O|O||D||1
42293501|Piezas de mano de irrigación o succión o cánulas o puntas o productos relacionados para uso quirúrgico|O|O||D||1
42293502|Cánulas o puntas de succión o irrigación láser o productos relacionados para uso quirúrgico|O|O||D||1
42293503|Dispositivos o curetas de extracción al vacío o productos relacionados para uso quirúrgico|O|O||D||1
42293504|Suministros o accesorios de irrigación o aspiración oftálmica|O|O||D||1
42293505|Sondas de drenaje de succión para uso quirúrgico|O|O||D||1
42293506|Bulbos de succión para uso quirúrgico|O|O||D||1
42293507|Reservorios de succión para uso quirúrgico|O|O||D||1
42293508|Suministros o accesorios de irrigación o aspiración de oído nariz y garganta ent|O|O||D||1
42293509|Sets o accesorios de irrigación para uso quirúrgico|O|O||D||1
42293600|Bougies quirúrgicos y sondas y obturadores y productos relacionados|O|O||D||1
42293601|Bujías para uso quirúrgico|O|O||D||1
42293602|Obturadores para uso quirúrgico|O|O||D||1
42293603|Sondas para uso quirúrgico|O|O||D||1
42293700|Machacadoras y excavadoras y fragmentadoras quirúrgicas y productos relacionados|O|O||D||1
42293701|Trituradores para uso quirúrgico|O|O||D||1
42293702|Excavadoras para uso quirúrgico|O|O||D||1
42293703|Molinos de hueso para uso quirúrgico|O|O||D||1
42293800|Agarradores y buscadores y excavadores y desmoldadores quirúrgicos y productos relacionados|O|O||D||1
42293801|Pasadores para uso quirúrgico|O|O||D||1
42293802|Buscadores para uso quirúrgico|O|O||D||1
42293803|Removedores para uso quirúrgico|O|O||D||1
42293804|Excavadoras o accesorios quirúrgicos.|O|O||D||1
42293900|Instrumentos quirúrgicos para empaque de heridas y productos relacionados|O|O||D||1
42293901|Anillos de laparoscopia para uso quirúrgico|O|O||D||1
42293902|Instrumentos para cubrir heridas para uso quirúrgico|O|O||D||1
42294000|Espátulas y cucharas y cucharones quirúrgicos y productos relacionados|O|O||D||1
42294001|Cucharas hondas para uso quirúrgico|O|O||D||1
42294002|Espátulas para uso quirúrgico|O|O||D||1
42294003|Cucharas para uso quirúrgico|O|O||D||1
42294100|Dispositivos esqueléticos quirúrgicos de tracción y productos relacionados|O|O||D||1
42294101|Lazos de tracción o bucles de tracción o productos relacionados para uso quirúrgico|O|O||D||1
42294102|Dispositivos de tracción del cráneo para uso quirúrgico o productos relacionados|O|O||D||1
42294103|Collares de tracción para uso quirúrgico|O|O||D||1
42294200|Juegos de instrumentos y sistemas y bandejas quirúrgicos|O|O||D||1
42294201|Sets de instrumentos quirúrgicos torácicos o cardiovasculares|O|O||D||1
42294202|Sets o sistemas de instrumentos de fijación externa|O|O||D||1
42294203|Sets de instrumentos quirúrgicos generales|O|O||D||1
42294204|Sets de instrumentos para micro cirugía, cirugía plástica o cirugía delicada|O|O||D||1
42294205|Sets de instrumentos neuroquirúrgicos o espinales|O|O||D||1
42294206|Sets de instrumentos para cirugía oftálmica|O|O||D||1
42294207|Sets de instrumentos para cirugía maxilofacial|O|O||D||1
42294208|Sistemas de instrumentos para revisión ortopédica o completa de articulaciones|O|O||D||1
42294209|Sistemas de instrumentos para fijación de trauma ortopédico|O|O||D||1
42294210|Sets de instrumentos para cirugía otolaringológica|O|O||D||1
42294211|Bandejas de procedimientos o instrumentos especiales o a la medida para uso quirúrgico|O|O||D||1
42294212|Sets de instrumentos para cirugía urológica|O|O||D||1
42294213|Sets de instrumentos para cirugía por laparoscopia|O|O||D||1
42294214|Sets de instrumentos para cirugía de traqueotomía|O|O||D||1
42294215|Sets de instrumentos para cirugía de craneotomía|O|O||D||1
42294216|Sets de instrumentos para cirugía de angiografía|O|O||D||1
42294217|Sets de instrumentos para cirugía gastroscópica|O|O||D||1
42294218|Sets de instrumentos para cirugía de oído nariz y garganta ent|O|O||D||1
42294219|Sets de instrumentos para cirugía ortopédica|O|O||D||1
42294220|Sistemas de recuperación y entrega de sangre|O|O||D||1
42294300|Instrumentos de biopsia de invasiva mínima del pecho y suministros y equipo|O|O||D||1
42294301|Conductores o módulos de disparo o accesorios para biopsia de seno mínimamente invasiva|O|O||D||1
42294302|Unidades de carga premium para biopsia de seno mínimamente invasiva|O|O||D||1
42294303|Guías de aguja para biopsia de seno mínimamente invasiva|O|O||D||1
42294304|Instrumentos marcadores para biopsia de seno mínimamente invasiva|O|O||D||1
42294305|Unidades de vacío o accesorios para biopsia de seno mínimamente invasiva|O|O||D||1
42294306|Aguja de localización de seno|O|O||D||1
42294400|Sistemas cardiacos y vasculares|O|O||D||1
42294401|Sistemas de cosecha de venas|O|O||D||1
42294402|Sistemas de visualización coronaria|O|O||D||1
42294500|Instrumentos de especialidad oftálmica y productos relacionados|O|O||D||1
42294501|Conformadores o protectores para cirugía oftálmica|O|O||D||1
42294502|Pesas de párpados para cirugía oftálmica|O|O||D||1
42294503|Anillos de fijación para cirugía oftálmica|O|O||D||1
42294504|Instrumentos de membrana intraocular para cirugía oftálmica|O|O||D||1
42294505|Placas de párpado para cirugía oftálmica|O|O||D||1
42294506|Rotadores de núcleo para cirugía oftálmica|O|O||D||1
42294507|Fresas o manijas o removedores de anillos de óxido para uso oftálmico|O|O||D||1
42294508|Puntas de aguja de irrigación o aspiración para uso oftálmico|O|O||D||1
42294509|Agujas para cirugía oftálmica|O|O||D||1
42294510|Esponjas para cirugía oftálmica|O|O||D||1
42294511|Cuchillos o cuchillas o tijeras o accesorios para cirugía oftálmica|O|O||D||1
42294512|Protectores de ojos o sus accesorios|O|O||D||1
42294513|Kits de vitrectomía oftálmica|O|O||D||1
42294514|Sondas de borrado hemostático|O|O||D||1
42294515|Pulidores de lentes oftálmicos|O|O||D||1
42294516|Sujetadores de ojos o sus accesorios|O|O||D||1
42294517|Insertos ópticos|O|O||D||1
42294518|Sets de ajuste de insertos ópticos|O|O||D||1
42294519|Cucharas o curetas oftálmicas|O|O||D||1
42294520|Sujetadores de lentes o accesorios para uso oftálmico|O|O||D||1
42294521|Componentes de combado escleral|O|O||D||1
42294522|Sets de punctum de tapón para uso oftálmico|O|O||D||1
42294523|Suministros para cirugía plástica oftálmica o sus productos relacionados|O|O||D||1
42294524|Magnetos de ojos para cirugía oftálmica|O|O||D||1
42294525|Sets de instrumentos médicos oftálmicos|O|O||D||1
42294526|Dilatadores o sets de lagrimales|O|O||D||1
42294527|Gas intraocular|O|O||D||1
42294528|Agente visco elástico o dispositivo visco quirúrgico|O|O||D||1
42294529|Cistotomo|O|O||D||1
42294530|Lente de vitrectomía|O|O||D||1
42294531|Lente láser para uso oftálmico|O|O||D||1
42294600|Productos de autotransfusión|O|O||D||1
42294601|Bolsas de autotransfusión o transferencia de sangre|O|O||D||1
42294602|Kits de contenedores de autotransfusión o kits centrífugos|O|O||D||1
42294603|Unidades de autotransfusión|O|O||D||1
42294604|Filtros de autotransfusión|O|O||D||1
42294605|Reservorios o sus accesorios de autotransfusión|O|O||D||1
42294606|Sets o kits de tubos de autotransfusión|O|O||D||1
42294607|Válvulas de autotransfusión|O|O||D||1
42294700|Equipo de perfusión de corazón abierto y monitores y accesorios y productos relacionados|O|O||D||1
42294701|Máquinas o accesorios de corazón y pulmones|O|O||D||1
42294702|Bombas y accesorios de balón intra aórtico|O|O||D||1
42294703|Dispositivos o accesorios de succión intra cardíaca|O|O||D||1
42294704|Filtros de perfusión o productos relacionados|O|O||D||1
42294705|Monitores de parámetros de sangre de perfusión o accesorios o productos relacionados|O|O||D||1
42294706|Trampas de burbujas de perfusión|O|O||D||1
42294707|Sets de cardioplegia de perfusión|O|O||D||1
42294708|Reservorios de cardiotomía de perfusión|O|O||D||1
42294709|Sistemas centrífugos de perfusión o accesorios|O|O||D||1
42294710|Equipos o accesorios calentadores o enfriadores o duales calentadores o enfriadores de perfusión|O|O||D||1
42294711|Hemoconcentradores de perfusión o accesorios|O|O||D||1
42294712|Monitores de saturación de oxígeno o hematocritos de perfusión o accesorios|O|O||D||1
42294713|Oxigenadores de perfusión o accesorios|O|O||D||1
42294714|Cabezas de bombas de perfusión|O|O||D||1
42294715|Tubos de empaque de bombas de perfusión|O|O||D||1
42294716|Reservorios venosos de perfusión|O|O||D||1
42294717|Dispositivos de asistencia ventricular|O|O||D||1
42294718|Bombas de perfusión|O|O||D||1
42294719|Reservorios cardiovasculares|O|O||D||1
42294720|Agujas de monitoreo de temperatura|O|O||D||1
42294721|Punzones aórticos|O|O||D||1
42294722|Sets de drenaje ventricular|O|O||D||1
42294723|Kits de inserción de bomba de inflar intra aórtica|O|O||D||1
42294724|Introductor de bomba de inflar intra aórtica|O|O||D||1
42294800|Endoscopios y accesorios y productos relacionados|O|O||D||1
42294801|Endoscopios rígidos o accesorios o productos relacionados|O|O||D||1
42294802|Endoscopios flexibles o accesorios o productos relacionados|O|O||D||1
42294803|Cistouretroscopios|O|O||D||1
42294804|Resectoscopios|O|O||D||1
42294805|Laparascopios o telescopios laparoscópicos|O|O||D||1
42294806|Cistoscopios|O|O||D||1
42294807|Esfinterómetros endoscópicos|O|O||D||1
42294808|Esofagoscopios o sus accesorios|O|O||D||1
42294900|Instrumentos endoscópicos y suministros accesorios y productos relacionados|O|O||D||1
42294901|Posicionadores o sujetadores de endoscopios o instrumentos|O|O||D||1
42294902|Aplicadores o elevadores de endoscopios|O|O||D||1
42294903|Agujas de aspiración o biopsia endoscópica|O|O||D||1
42294904|Bloques de mordida o correas endoscópicas|O|O||D||1
42294905|Cepillos de limpieza endoscópica o productos relacionados|O|O||D||1
42294906|Instrumentos de cortar para uso endoscópico|O|O||D||1
42294907|Cepillos de citología endoscópica o microbiología|O|O||D||1
42294908|Pinzas o disectores o agarraderas o fórceps o ligantes endoscópicos|O|O||D||1
42294909|Dilatadores o dispositivos inflables endoscópicos o productos relacionados|O|O||D||1
42294910|Electrodos o cables endoscópicos|O|O||D||1
42294911|Kits de fijación endoscópica|O|O||D||1
42294912|Sistemas o accesorios de manejo de fluido endoscópico|O|O||D||1
42294913|Balones hemostáticos o agujas o tubos o accesorios endoscópicos|O|O||D||1
42294914|Sets de instrumentos endoscópicos|O|O||D||1
42294915|Desplegadores de instrumentos endoscópicos|O|O||D||1
42294916|Filtros de insuflación endoscópica|O|O||D||1
42294917|Agujas de insuflación endoscópica|O|O||D||1
42294918|Tubos de insuflación endoscópica|O|O||D||1
42294919|Introductores o alambres guía o alambres de deslizamiento endoscópicos|O|O||D||1
42294920|Instrumentos o accesorios láser endoscópicos|O|O||D||1
42294921|Sistemas de empujadores de nudos o de entrega endoscópicos|O|O||D||1
42294922|Ligantes endoscópicos|O|O||D||1
42294923|Manipuladores endoscópicos|O|O||D||1
42294924|Instrumentos o accesorios manuales monopolares o bipolares para endoscopia o productos relacionados|O|O||D||1
42294925|Agujas o punzones para endoscopia|O|O||D||1
42294926|Sobre tubos para endoscopia|O|O||D||1
42294927|Paquetes o bandejas o kits de instrumentos para endoscopia|O|O||D||1
42294928|Sondas para endoscopia|O|O||D||1
42294929|Retractores para endoscopia|O|O||D||1
42294930|Pinzas o alambres de pinzas o accesorios para endoscopia|O|O||D||1
42294931|Fórceps o dispositivos de recuperación de especímenes para endoscopia|O|O||D||1
42294933|Puntas de irrigación o succión o sondas de coagulación o accesorios para endoscopia|O|O||D||1
42294934|Dispositivos de sutura para endoscopia|O|O||D||1
42294935|Trocar o funda u obturador o cánula para endoscopia|O|O||D||1
42294936|Elementos de trabajo o canales de trabajo para endoscopia|O|O||D||1
42294937|Dispositivos reductores de empañe para endoscopia o espejos|O|O||D||1
42294938|Tapas sellantes para endoscopia|O|O||D||1
42294939|Válvulas o accesorios para endoscopia|O|O||D||1
42294940|Convertidores para endoscopia|O|O||D||1
42294941|Sets de drenaje biliar para endoscopia|O|O||D||1
42294942|Sellos de instrumentos para endoscopia|O|O||D||1
42294943|Unidades de válvulas para endoscopia|O|O||D||1
42294944|Kits de accesorios para endoscopia|O|O||D||1
42294945|Esponjas para endoscopia|O|O||D||1
42294946|Mordazas para endoscopia|O|O||D||1
42294947|Diafragmas para endoscopia|O|O||D||1
42294948|Piezas bucales para endoscopia|O|O||D||1
42294949|Manijas de guía de alambre para endoscopia|O|O||D||1
42294950|Brocas o taladros para endoscopia|O|O||D||1
42294951|Sets de instrumentos para uniones pequeñas para endoscopia|O|O||D||1
42294952|Recuperadores o sets para endoscopia|O|O||D||1
42294953|Extractores para endoscopia|O|O||D||1
42294954|Dispositivos o accesorios para remover especímenes o tejidos para endoscopia|O|O||D||1
42294955|Ganchos o accesorios para endoscopia|O|O||D||1
42294956|Localizadores de guía de alambre para endoscopia|O|O||D||1
42294957|Cuchillas de afeitar o accesorios para endoscopia|O|O||D||1
42294958|Aditamentos y accesorios de cortar y sellar vasos para endoscopia|O|O||D||1
42295000|Equipo endoscópico y accesorios y productos relacionados|O|O||D||1
42295001|Unidades o accesorios de mantenimiento para endoscopia|O|O||D||1
42295002|Gabinetes de almacenamiento o accesorios para endoscopia|O|O||D||1
42295003|Colgadores de pared o accesorios para endoscopia|O|O||D||1
42295004|Carritos de equipos o procedimientos o accesorios para endoscopia|O|O||D||1
42295005|Sets de equipos endoscópicos|O|O||D||1
42295006|Unidades de sonda de calor o sondas de calor o accesorios para endoscopia|O|O||D||1
42295007|Sistemas de imágenes o accesorios para endoscopia|O|O||D||1
42295008|Unidades o accesorios de insuflación o distensión para endoscopia|O|O||D||1
42295009|Fuentes de luz quirúrgica o accesorios para endoscopia|O|O||D||1
42295010|Impresoras o accesorios para endoscopia|O|O||D||1
42295011|Video cámaras o grabadoras o adaptadores o accesorios para endoscopia|O|O||D||1
42295012|Botellas de agua o accesorios para endoscopia|O|O||D||1
42295013|Protectores o cubiertas de puntas de endoscopios|O|O||D||1
42295014|Estuches de instrumentos para endoscopia|O|O||D||1
42295015|Lentes endoscópicos|O|O||D||1
42295016|Video cable quirúrgico o endoscópico|O|O||D||1
42295100|Equipo quirúrgico y accesorios y productos relacionados|O|O||D||1
42295101|Puestos de lavamanos para uso quirúrgico|O|O||D||1
42295102|Equipos o accesorios para criocirugía|O|O||D||1
42295103|Mesas o accesorios para procedimientos de cesáreas o salas de partos o productos relacionados|O|O||D||1
42295104|Equipo electro quirúrgico o electro cauterizante|O|O||D||1
42295105|Mesas de instrumentos para uso quirúrgico u obstétrico o accesorios o productos relacionados|O|O||D||1
42295106|Bandejas mayo para el canto o puestos mayo para uso quirúrgico o sus accesorios|O|O||D||1
42295107|Carritos para estuches de salas de cirugía o carritos de procedimiento o gabinetes de pared o accesorios|O|O||D||1
42295108|Mesas de fractura de pacientes para salas de cirugía o mesas ortopédicas o accesorios o productos relacionados|O|O||D||1
42295109|Baldes para salas de cirugía o accesorios o productos relacionados|O|O||D||1
42295111|Dispositivos de posicionamiento de los pacientes para salas de cirugía o accesorios|O|O||D||1
42295112|Mesas de procedimientos para salas de cirugía o accesorios o productos relacionados|O|O||D||1
42295114|Equipos de facoemulsificación o extrusión o accesorios para cirugía oftálmica|O|O||D||1
42295115|Taburetes de cirujanos o accesorios|O|O||D||1
42295116|Escalones para salas de cirugía o accesorios|O|O||D||1
42295118|Equipos de bombas de irrigación para uso quirúrgico o lavado pulsado o accesorios con o sin succión|O|O||D||1
42295119|Láseres para uso quirúrgico o accesorios|O|O||D||1
42295120|Litotriptores o accesorios para uso quirúrgico|O|O||D||1
42295121|Microscopios o lupas o magnificadores o accesorios para uso quirúrgico|O|O||D||1
42295122|Torniquetes neumáticos o eléctricos o accesorios para uso quirúrgico|O|O||D||1
42295123|Máquinas de succión o extractores al vacío o aspiradores quirúrgicos ultrasónicos o reguladores o accesorios para uso quirúrgico|O|O||D||1
42295124|Evacuadores de humo o accesorios para uso quirúrgico|O|O||D||1
42295125|Mesas urológicas o accesorios para uso quirúrgico|O|O||D||1
42295126|Equipos de cirugía fragmatoma de retina vítrea para cirugía oftálmica|O|O||D||1
42295127|Equipos o accesorios de microcirugía|O|O||D||1
42295128|Instrumentos quirúrgicos maxilofaciales o accesorios|O|O||D||1
42295129|Dispensadores de medicamentos para salas de cirugía o productos relacionados|O|O||D||1
42295130|Tubos o accesorios de conexión de instrumentos quirúrgicos|O|O||D||1
42295131|Puestos o accesorios de equipos quirúrgicos|O|O||D||1
42295132|Estuches o accesorios para equipos quirúrgicos|O|O||D||1
42295133|Estantes de tornillos ortopédicos o accesorios|O|O||D||1
42295134|Sets o accesorios de suministro quirúrgico general|O|O||D||1
42295135|Dispositivos o accesorios de control ortopédico|O|O||D||1
42295136|Instrumentos de control para uso quirúrgico|O|O||D||1
42295137|Equipos o suministros o accesorios para gastroenterología|O|O||D||1
42295138|Dispositivos o accesorios de dilatación urológica para uso quirúrgico|O|O||D||1
42295139|Rollos de instrumentos para instrumentos quirúrgicos o accesorios|O|O||D||1
42295140|Gabinetes o muebles para instrumentos quirúrgicos|O|O||D||1
42295141|Kit de salvamento de sangre intra operativa|O|O||D||1
42295142|Máquina de salvamento de sangre intra operativa|O|O||D||1
42295143|Accesorios o aditamentos electro quirúrgicos o electro cauterizantes|O|O||D||1
42295144|Unidad de microondas quirúrgico|O|O||D||1
42295145|Depilador tipo aguja|O|O||D||1
42295146|Depilador tipo pinza|O|O||D||1
42295147|Instrumento de ultrasonido para uso quirúrgico|O|O||D||1
42295148|Sistema de navegación para uso quirúrgico|O|O||D||1
42295200|Equipo quirúrgico de energía y accesorios y productos relacionados|O|O||D||1
42295201|Dermotomos o aparatos para dermoabrasión o dermoreticulador para uso quirúrgico o accesorios|O|O||D||1
42295202|Sierras eléctricas o de pila o neumáticas o colocadores de tornillos o accesorios para uso quirúrgico|O|O||D||1
42295203|Sets o accesorios de equipos eléctricos para uso quirúrgico|O|O||D||1
42295204|Escariadores para uso quirúrgico|O|O||D||1
42295205|Equipos de afeitado o piezas de mano o cuchillas o accesorios para uso quirúrgico|O|O||D||1
42295206|Unidades de cirugía endoscópica|O|O||D||1
42295207|Guía o manga para taladro de uso quirúrgico|O|O||D||1
42295300|Suministros y accesorios para cirugía de corazón abierto y productos relacionados|O|O||D||1
42295301|Sopladores o vaporizadores o accesorios de uso quirúrgico|O|O||D||1
42295302|Cánulas de perfusión de uso quirúrgico|O|O||D||1
42295303|Catéteres o conectores o accesorios de uso quirúrgico|O|O||D||1
42295304|Almohadillas para nervios frénicos o almohadas cardíacas de uso quirúrgico|O|O||D||1
42295305|Torniquetes u oclusores vasculares o ligantes o accesorios de uso quirúrgico|O|O||D||1
42295306|Lanzaderas de vasos o cintas de retracción de uso quirúrgico|O|O||D||1
42295307|Decapantes de arteria carótida o accesorios de uso quirúrgico|O|O||D||1
42295308|Sets de perfusión coronaria|O|O||D||1
42295400|Suministros quirúrgicos auxiliares|O|O||D||1
42295401|Lápices de cauterización operados mediante pilas de uso quirúrgico|O|O||D||1
42295402|Esferos para marcar de uso quirúrgico|O|O||D||1
42295405|Introductores o ganchos de guía o guías de alambre o deslizadores de alambre para cirugía no endoscópica o procedimientos de corazón abierto|O|O||D||1
42295406|Esponja especial para laparotomía o detectable por rayos x o de uso quirúrgico|O|O||D||1
42295407|Máscaras para pacientes de uso quirúrgico|O|O||D||1
42295408|Cepillos para manos para cirujanos o soluciones o accesorios|O|O||D||1
42295409|Aplicadores de uso quirúrgico|O|O||D||1
42295410|Sets o paquetes de cuencas de uso quirúrgico|O|O||D||1
42295411|Sujetadores o interruptores de cuchilla de uso quirúrgico|O|O||D||1
42295413|Cepillos de canal de uso quirúrgico|O|O||D||1
42295414|Paquetes para procedimientos especiales o a la medida de uso quirúrgico|O|O||D||1
42295415|Fundas para equipos de uso quirúrgico|O|O||D||1
42295416|Evacuadores de uso quirúrgico|O|O||D||1
42295417|Fundas o manijas para luces de uso quirúrgico|O|O||D||1
42295418|Esterillas magnéticas de uso quirúrgico|O|O||D||1
42295419|Estimuladores de nervios o accesorios de uso quirúrgico|O|O||D||1
42295420|Catéteres endoscópicos o quirúrgicos o kits de cateterización o bolsas de drenaje|O|O||D||1
42295421|Lavado de preparación o soluciones de pintura para uso quirúrgico|O|O||D||1
42295422|Lavado o kits de preparación del paciente para uso quirúrgico|O|O||D||1
42295423|Mostradores de instrumentos afilados o esponjas para uso quirúrgico|O|O||D||1
42295424|Kits de afeitado o cuchillas de preparación o corta uñas para uso quirúrgico|O|O||D||1
42295425|Palitos o lápices o cristales de nitrato de plata para uso quirúrgico|O|O||D||1
42295426|Trampas o contenedores de recolección de especímenes para uso quirúrgico|O|O||D||1
42295427|Cepillos para instrumentos estériles o estiletes instrumentales o pañitos limpiadores de instrumentos para uso quirúrgico|O|O||D||1
42295428|Tubos o accesorios de irrigación o succión para uso quirúrgico|O|O||D||1
42295431|Cortinas transparentes de incisión o bolsas para instrumentos para uso quirúrgico|O|O||D||1
42295433|Catéteres urológicos o accesorios para uso quirúrgico|O|O||D||1
42295435|Protectores o escudos para oídos|O|O||D||1
42295436|Anillos de anastomosis|O|O||D||1
42295437|Sets de utensilios o gabinetes o accesorios para uso quirúrgico|O|O||D||1
42295439|Alisadores de hueso para uso ortopédico|O|O||D||1
42295440|Adaptadores de catéteres endoscópicos|O|O||D||1
42295441|Sets de recuperación para uso quirúrgico|O|O||D||1
42295445|Insertos de bandejas para aparatos quirúrgicos|O|O||D||1
42295446|Retenedores de órganos internos|O|O||D||1
42295448|Guardas de salpicaduras o accesorios para uso quirúrgico|O|O||D||1
42295450|Cargadores de baldes o accesorios para uso quirúrgico|O|O||D||1
42295451|Guantes de preparación para uso quirúrgico|O|O||D||1
42295452|Tazas de preparación para uso quirúrgico|O|O||D||1
42295453|Drenajes o sets o accesorios para uso quirúrgico|O|O||D||1
42295454|Protectores de mano para uso quirúrgico|O|O||D||1
42295455|Kits de resina para reparación craneal|O|O||D||1
42295456|Fieltros para uso quirúrgico|O|O||D||1
42295457|Lentes o capuchas de cascos para uso quirúrgico|O|O||D||1
42295458|Equipos para secar o empolvar guantes quirúrgicos|O|O||D||1
42295459|Dispositivos para decantar fluidos para uso quirúrgico|O|O||D||1
42295460|Capas protectoras para implantes ortopédicos|O|O||D||1
42295461|Pegamento para tejidos o sistemas o aplicadores o accesorios|O|O||D||1
42295462|Catéteres uro dinámicos o accesorios|O|O||D||1
42295463|Catéteres uretrales|O|O||D||1
42295464|Solución para preservación de órganos|O|O||D||1
42295465|Sistema de monitoreo neurofisiológico|O|O||D||1
42295466|Cemento para huesos para uso quirúrgico|O|O||D||1
42295467|Mezcladora de cemento para huesos para uso quirúrgico|O|O||D||1
42295468|Inyector de cemento para huesos o accesorios para uso quirúrgico|O|O||D||1
42295469|Kits de cemento para huesos o accesorios para uso quirúrgico|O|O||D||1
42295470|Sistema de concentración de plaquetas|O|O||D||1
42295471|Sistema de aspiración de médula ósea|O|O||D||1
42295500|Implantes quirúrgico y ensanchadores y extensores y alambres quirúrgicos y productos relacionados|O|O||D||1
42295502|Implantes de tejido humano|O|O||D||1
42295503|Puertos de infusión implantables o accesorios|O|O||D||1
42295505|Implantes oftálmicos|O|O||D||1
42295506|Implantes maxilofaciales bucales o sets|O|O||D||1
42295508|Implantes para otolaringología o sets|O|O||D||1
42295509|Implantes plásticos o cosméticos o expansores de tejidos o sets|O|O||D||1
42295510|Barreras de adhesión para uso quirúrgico|O|O||D||1
42295511|Estimuladores de hueso para uso quirúrgico|O|O||D||1
42295512|Derivaciones implantables o extensores de derivaciones para uso quirúrgico|O|O||D||1
42295513|Productos de malla o de barreras de tejido para uso quirúrgico|O|O||D||1
42295514|Láminas de silicona|O|O||D||1
42295515|Implantes de tejidos sintéticos|O|O||D||1
42295516|Implantes urológicos o sets|O|O||D||1
42295517|Extensores cardiovasculares|O|O||D||1
42295518|Protectores de ganchos|O|O||D||1
42295519|Kit de preparación para prótesis de pene|O|O||D||1
42295520|Kit de ventriculostomía|O|O||D||1
42295521|Implante gastrointestinal|O|O||D||1
42295522|Estimulador de nervios implantable|O|O||D||1
42295523|Implante o eslinga ginecológica|O|O||D||1
42295524|Lente intraocular iol|O|O||D||1
42295525|Implante de tejido biológico|O|O||D||1
42295526|Sistema de implantes de pelo|O|O||D||1
42295600|Productos y accesorios de drenaje de fluido cerebroespinal|O|O||D||1
42295601|Catéter o adaptador de drenaje ventricular cerebral|O|O||D||1
42295602|Bolsa o reservorio de drenaje ventricular cerebral externa|O|O||D||1
42295603|Drenaje de fluido cerebroespinal lumbar o kit|O|O||D||1
42295800|Sistemas y accesorios de termo - ablación quirúrgica|O|O||D||1
42295801|Casete de ablación térmica para uso quirúrgico|O|O||D||1
42295802|Set de tubos de ablación térmica para uso quirúrgico|O|O||D||1
42295803|Catéteres de ablación térmica para uso quirúrgico|O|O||D||1
42295900|Stents quirúrgicos|O|O||D||1
42295901|Stents gastrointestinales|O|O||D||1
42295902|Stents traqueales|O|O||D||1
42295903|Stents urológicos|O|O||D||1
42295904|Stents uterinos o vaginales|O|O||D||1
42295905|Endoprótesis o stents de pared o tubos|O|O||D||1
42295906|Stents esofágicos|O|O||D||1
42296000|Implantes cardiovasculares|O|O||D||1
42296001|Válvula aórtica|O|O||D||1
42296002|Conducto cardiovascular|O|O||D||1
42296003|Válvula mitral|O|O||D||1
42296004|Válvula tricúspide|O|O||D||1
42296005|Anillo de anuloplastia|O|O||D||1
42296006|Gancho vascular|O|O||D||1
42296007|Oclusor cardiovascular|O|O||D||1
42296008|Válvula pulmonar|O|O||D||1
42296100|Implantes neuroquirúrgicos|O|O||D||1
42296101|Clip implantable para aneurisma|O|O||D||1
42296102|Clip temporal para aneurisma|O|O||D||1
42296103|Reemplazo dural o dispositivo de reparación|O|O||D||1
42296104|Placa craneal o cubierta de orificio de broca|O|O||D||1
42296105|Malla craneal|O|O||D||1
42296106|Gancho de reparación de nervios|O|O||D||1
42296107|Pinza craneal|O|O||D||1
42296200|Equipo y accesorios de robótica quirúrgica y productos relacionados|O|O||D||1
42296201|Instrumentos robóticos de aplicación de clips para uso quirúrgico|O|O||D||1
42296202|Instrumentos robóticos de disección para uso quirúrgico|O|O||D||1
42296203|Instrumentos robóticos de electro cauterización para uso quirúrgico|O|O||D||1
42296204|Agarradores o fórceps robóticos para uso quirúrgico|O|O||D||1
42296205|Instrumentos robóticos de gancho para uso quirúrgico|O|O||D||1
42296206|Empujador de nudos o sistema de entrega robótico para uso quirúrgico|O|O||D||1
42296207|Conductor de aguja robótico para uso quirúrgico|O|O||D||1
42296208|Instrumento robótico de retracción para uso quirúrgico|O|O||D||1
42296209|Escalpelo y cuchilla robótica para uso quirúrgico|O|O||D||1
42296210|Tijeras robóticas para uso quirúrgico|O|O||D||1
42296211|Instrumento robótico de energía ultrasónica para uso quirúrgico|O|O||D||1
42296212|Trocar o funda u obturador o cánula robótica para uso quirúrgico|O|O||D||1
42301500|Ayudas para formación médica|O|O||D||1
42301501|Modelos humanos anatómicos para educación o entrenamiento médico|O|O||D||1
42301502|Maniquíes humanos anatómicos para educación o entrenamiento médico|O|O||D||1
42301503|Ayudas de entrenamiento para resucitación cardiopulmonar cpr|O|O||D||1
42301504|Kits para educación o entrenamiento médico|O|O||D||1
42301505|Portapapeles para enfermeras o médicos|O|O||D||1
42301506|Estetoscopios de doble audífono|O|O||D||1
42301507|Videos de entrenamiento para la educación del personal médico|O|O||D||1
42301508|Videos de operación o de instrucciones para equipos médicos|O|O||D||1
42311500|Vendas y vendajes y productos relacionados|O|O||D||1|Vendas, apósitos y productos relacionados
42311501|Clips para vendajes o compresas|O|O||D||1|Ganchos para vendas elásticas, Material de curación
42311502|Kits de inicio de vendajes o compresas|O|O||D||1|Juego de vendas, vendajes y gasas, Material de curación
42311503|Enrolladores de vendajes|O|O||D||1|Rodillos para vendas
42311504|Vendajes o compresas para el cuidado de quemaduras|O|O||D||1
42311505|Vendajes o compresas para uso general|O|O||D||1|Material de curación, Vendas de uso general
42311506|Vendas o compresas de compresión o presión|O|O||D||1
42311508|Bandejas para compresas|O|O||D||1
42311510|Vendajes de espuma|O|O||D||1
42311511|Vendajes de gasa|O|O||D||1|Gasas de uso general, Material de curación
42311512|Esponjas de gasa|O|O||D||1
42311513|Compresas de gel|O|O||D||1
42311514|Vendajes germicidas|O|O||D||1
42311515|Vendajes hidrocoloides|O|O||D||1
42311517|Adhesivos líquidos para vendajes o compresas|O|O||D||1
42311518|Parches o almohadillas para los ojos para uso médico|O|O||D||1
42311519|Tiras no adhesivas para uso médico|O|O||D||1
42311520|Cintas no adhesivas para uso médico|O|O||D||1
42311521|Compresas de presión negativa|O|O||D||1|Apósitos de presión negativa
42311522|Compresas oclusivas|O|O||D||1
42311523|Vendajes de pasta|O|O||D||1|Vendas de yeso
42311524|Compresas de petrolato|O|O||D||1
42311527|Compresas de película transparente|O|O||D||1
42311528|Sistemas de compresas húmedas|O|O||D||1
42311531|Cubiertas para compresas|O|O||D||1
42311537|Tijeras para vendajes o sus suministros|O|O||D||1
42311538|Kits de hiperalimentación|O|O||D||1
42311539|Aplicadores de vendajes|O|O||D||1
42311540|Compresas de alginato|O|O||D||1
42311541|Compresas biológicas|O|O||D||1
42311542|Compresas de control de olor|O|O||D||1
42311543|Retenedor de vendajes|O|O||D||1|Mallas elásticas para vendajes
42311600|Agentes hemoestáticos tópicos exógenos|O|O||D||1
42311601|Esponjas de gelatina absorbible|O|O||D||1
42311602|Cera para huesos|O|O||D||1
42311603|Celulosa oxidada|O|O||D||1
42311604|Hemostáticos de colágeno micro fibrilar|O|O||D||1
42311605|Parche no absorbible de trombina|O|O||D||1
42311700|Cintas adhesivas médicas y quirúrgicas y productos relacionados para el uso en especialidades|O|O||D||1
42311702|Cintas umbilicales para bebés|O|O||D||1
42311703|Cintas médicas o quirúrgicas para pegar la piel|O|O||D||1
42311704|Dispensadores de cinta médica o quirúrgica|O|O||D||1
42311705|Removedores de cinta médica o quirúrgica|O|O||D||1
42311707|Cintas de tejido para uso quirúrgico|O|O||D||1
42311708|Cintas adherentes médicas o quirúrgicas para uso general|O|O||D||1
42311900|Drenajes médicos de incisión y bolsas de drenaje y depósitos y productos relacionados|O|O||D||1
42311901|Accesorios de drenaje para uso médico|O|O||D||1
42311902|Bolsas o reservorios de drenaje de incisiones para uso médico|O|O||D||1
42311903|Drenajes de incisión para uso médico|O|O||D||1
42312000|Cierre de tejidos médicos y productos relacionados|O|O||D||1
42312001|Cierres de mariposa para piel|O|O||D||1
42312002|Clips para cierre de piel|O|O||D||1
42312003|Tiras de cierre para la piel o para heridas|O|O||D||1
42312004|Removedores de pegamento o adhesivo para uso médico|O|O||D||1
42312005|Adhesivos o pegamentos de cierre de piel para uso médico|O|O||D||1
42312006|Aplicadores de clip para uso interno para uso médico|O|O||D||1
42312007|Clips de uso interno para uso médico|O|O||D||1
42312008|Removedores de ganchos o clips para uso médico|O|O||D||1
42312009|Cosedoras para uso interno|O|O||D||1
42312010|Cosedoras para cierre de piel|O|O||D||1
42312011|Ganchos para uso interno|O|O||D||1
42312012|Ganchos para cierre de piel|O|O||D||1
42312014|Kits de cierre de tejidos o bandejas o paquetes o sets|O|O||D||1
42312100|Suministros de ostomía y productos no quirúrgicos de drenaje de heridas|O|O||D||1
42312101|Adhesivos para aplicación en ostomía|O|O||D||1
42312102|Aplicaciones para ostomía|O|O||D||1
42312103|Limpiadores o desodorantes para ostomía|O|O||D||1
42312104|Suministros de recolección para ostomía|O|O||D||1
42312105|Kits de barreras de piel o cuidado protector para ostomía|O|O||D||1
42312106|Insertos para ostomía|O|O||D||1
42312107|Obleas para ostomía|O|O||D||1
42312108|Bolsas de drenaje para ostomía|O|O||D||1
42312109|Anillos de bolsa para ostomía|O|O||D||1
42312110|Kits de inicio para ostomía|O|O||D||1
42312111|Fundas de bolsa para ostomía|O|O||D||1
42312112|Cinturón o accesorios para ostomía|O|O||D||1
42312113|Tapones de bolsa para ostomía|O|O||D||1
42312115|Mangas de irrigación para ostomía|O|O||D||1
42312200|Sutura y productos relacionados|O|O||D||1
42312201|Suturas|O|O||D||1
42312202|Kits o bandejas o paquetes o sets para sutura|O|O||D||1
42312203|Botones o puentes o accesorios relacionados para sutura|O|O||D||1
42312204|Botas y dispositivos de captura para sutura|O|O||D||1
42312205|Carritos o estantes para sutura|O|O||D||1
42312206|Agujas para sutura|O|O||D||1
42312207|Kits de remoción o bandejas o paquetes o sets para sutura|O|O||D||1
42312208|Removedores de suturas|O|O||D||1
42312300|Productos para limpiar la herida y desbridamiento|O|O||D||1
42312301|Absorbentes para limpieza de heridas|O|O||D||1
42312302|Esponjas de debridación|O|O||D||1
42312303|Sistemas de lavado pulsado o accesorios relacionados para el tratamiento de heridas|O|O||D||1
42312304|Productos de debridación autolítica para uso médico|O|O||D||1
42312305|Productos de debridación enzimática para uso médico|O|O||D||1
42312306|Productos de debridación mecánica para uso médico|O|O||D||1
42312307|Productos de debridación quirúrgica para uso médico|O|O||D||1
42312309|Sistemas de irrigación de heridas|O|O||D||1
42312310|Botellas limpiadoras|O|O||D||1
42312311|Kits de desinfectantes|O|O||D||1
42312312|Bandejas de cuidado de heridas o de limpieza|O|O||D||1
42312313|Soluciones de limpieza de heridas|O|O||D||1|Soluciones antisépticas
42312400|Productos para la curación de heridas|O|O||D||1
42312401|Relleno de alginato de calcio para heridas|O|O||D||1
42312402|Férulas o stents nasales|O|O||D||1
42312403|Tiras de relleno para cuidado de heridas|O|O||D||1
42312500|Dispositivos de sujeción de heridas, y accesorios y suministros|O|O||D||1
42312501|Ligaduras de soporte mamario|O|O||D||1
42312502|Ligaduras abdominales|O|O||D||1
42312503|Soportes para escroto|O|O||D||1
42312504|Prenda de soporte facial|O|O||D||1
42312600|Productos de terapia de presión negativa para heridas|O|O||D||1
42312601|Equipo de terapia de presión negativa para heridas|O|O||D||1
42312602|Kits o sistemas de terapia de presión negativa para heridas|O|O||D||1
42312700|Productos de terapia de oxígeno para heridas tópicas|O|O||D||1
42312701|Cámara de uso único de terapia de oxígeno para heridas tópicas|O|O||D||1
42321500|Implantes de trauma ortopédico|O|O||D||1
42321501|Alambre quirúrgico ortopédico|O|O||D||1
42321502|Guía de alambre ortopédico o gancho guía o varilla guía|O|O||D||1
42321503|Extensor de gancho óseo o sustituto|O|O||D||1
42321504|Clavo intramedular|O|O||D||1
42321505|Placas óseas|O|O||D||1
42321506|Destornillador óseo|O|O||D||1
42321507|Set de fijación interna|O|O||D||1
42321508|Tuercas ortopédicas|O|O||D||1
42321509|Lavadora ortopédica|O|O||D||1
42321510|Tapa ortopédica|O|O||D||1
42321512|Pernos de fijación ósea|O|O||D||1
42321513|Perno o alambre de fijación temporal|O|O||D||1
42321514|Grapa de fijación ósea|O|O||D||1
42321515|Hoja de sierra intramedular|O|O||D||1
42321516|Tornillo de cierre intramedular|O|O||D||1
42321600|Implantes espinales|O|O||D||1
42321601|Disco intervertebral|O|O||D||1
42321602|Cable espinal|O|O||D||1
42321603|Balón de cifoplastia|O|O||D||1
42321604|Dispositivo de unión cruzada espinal|O|O||D||1
42321605|Armazón intracorpórea espinal|O|O||D||1
42321606|Dispositivo de descompresión espinal|O|O||D||1
42321607|Gancho espinal|O|O||D||1
42321608|Dispositivo de fusión intracorpórea|O|O||D||1
42321609|Varilla espinal|O|O||D||1
42321610|Destornillador espinal|O|O||D||1
42321611|Placa espinal|O|O||D||1
42321612|Anillo de manga o tapa de extremo espinal|O|O||D||1
42321613|Tornillo múltiple o bloqueador espinal|O|O||D||1
42321614|Perno espinal|O|O||D||1
42321615|Silla o cuna espinal|O|O||D||1
42321616|Conector o acoplador espinal|O|O||D||1
42321617|Grapa espinal|O|O||D||1
42321618|Lavadora espinal|O|O||D||1
42321619|Restrictor de cemento espinal|O|O||D||1
42321620|Perno espinal|O|O||D||1
42321621|Tornillo o alambre de fijación espinal temporal|O|O||D||1
42321622|Kit o sistema de implante espinal|O|O||D||1
42321700|Implantes de cadera|O|O||D||1
42321701|Tapa acetabular de una pieza|O|O||D||1
42321702|Concha acetabular|O|O||D||1
42321703|Revestimiento de taza acetabular|O|O||D||1
42321704|Cabeza femoral|O|O||D||1
42321705|Centralizador distal de tallo femoral|O|O||D||1
42321706|Extensión de vástago de la cadera femoral|O|O||D||1
42321707|Kit o sistema de reemplazo total de cadera|O|O||D||1
42321708|Vástago de la cadera femoral|O|O||D||1
42321709|Prótesis hemiartroplástica de cadera de una pieza|O|O||D||1
42321710|Adaptador de componente de cadera modular femoral|O|O||D||1
42321711|Componente femoral resurgente|O|O||D||1
42321712|Centralizador proximal de tallo femoral|O|O||D||1
42321713|Tornillo acetabular|O|O||D||1
42321714|Aumento acetabular|O|O||D||1
42321715|Componente de cadera bipolar o unipolar|O|O||D||1
42321716|Restrictor de cemento de canal femoral|O|O||D||1
42321717|Tornillo componente de cadera|O|O||D||1
42321718|Armazón acetabular|O|O||D||1
42321719|Malla acetabular|O|O||D||1
42321720|Cubierta de orificio de tornillo acetabular|O|O||D||1
42321721|Eliminador o tapón de orificio acetabular|O|O||D||1
42321722|Anillo acetabular|O|O||D||1
42321723|Cuello femoral|O|O||D||1
42321800|Implantes de rodilla|O|O||D||1
42321801|Componente de rodilla femoral|O|O||D||1
42321802|Tallo de extensión de rodilla femoral|O|O||D||1
42321803|Tallo de extensión de tibia|O|O||D||1
42321804|Implante de rótula|O|O||D||1
42321805|Placa de base para la tibia|O|O||D||1
42321806|Inserto para la tibia|O|O||D||1
42321808|Kit o sistema de remplazo total de rodilla|O|O||D||1
42321809|Aumento de tibia o fémur o rótula|O|O||D||1
42321810|Tornillo de placa de base de la tibia|O|O||D||1
42321811|Tornillo de conexión de aumento|O|O||D||1
42321812|Espaciador de articulación de rodilla|O|O||D||1
42321813|Cuña de rodilla femoral|O|O||D||1
42321900|Implantes de hombro|O|O||D||1
42321902|Cabeza de húmero|O|O||D||1
42321903|Tallo de húmero|O|O||D||1
42321904|Componente de húmero resurgente|O|O||D||1
42321905|Esfera glenoidea|O|O||D||1
42321906|Componente de fijación glenoidea|O|O||D||1
42321907|Revestimiento o protector de inserto de húmero|O|O||D||1
42321908|Restrictor de cemento para el canal humeral|O|O||D||1
42321909|Concha o receptáculo humeral|O|O||D||1
42321910|Centralizador o manga de tallo humeral|O|O||D||1
42321911|Cuerpo humeral|O|O||D||1
42321912|Kit o sistema de remplazo total o parcial de hombro|O|O||D||1
42322000|Implantes ortopédicos de articulaciones distales|O|O||D||1
42322001|Implante de articulación de tobillo|O|O||D||1
42322002|Implante de articulación de muñeca|O|O||D||1
42322003|Implante de articulación de codo|O|O||D||1
42322004|Implante de articulación de dedo|O|O||D||1
42322005|Implante de articulación de dedos del pie|O|O||D||1
42322006|Varilla o espaciador de tendones|O|O||D||1
42322100|Implantes ortopédicos de prueba|O|O||D||1
42322101|Implante de ensayo de rodilla|O|O||D||1
42322102|Implante de ensayo de cadera|O|O||D||1
42322103|Implante de ensayo de hombro|O|O||D||1
42322104|V de articulación distal|O|O||D||1
42322105|Implante de ensayo de columna|O|O||D||1
42322106|Implante de ensayo de trauma|O|O||D||1
42322200|Productos para la fijación de tejidos blandos|O|O||D||1
42322201|Tornillo de interferencia|O|O||D||1
42322202|Anclaje no suturado de tejidos blandos|O|O||D||1
42322203|Anclaje de sutura|O|O||D||1
42322204|Lavador de fijación de tejidos blandos|O|O||D||1
42322205|Perno de fijación de tejidos blandos|O|O||D||1
42322206|Grapa de tejidos blandos|O|O||D||1
43191500|Dispositivos de comunicación personal|O|O||D||1
43191501|Teléfonos móviles|O|O||D||1|Celular o Smartphone
43191502|Busca personas|O|O||D||1
43191503|Teléfonos de pago|O|O||D||1
43191504|Teléfonos fijos|O|O||D||1
43191505|Máquinas contestadoras|O|O||D||1
43191507|Teléfonos para propósitos especiales|O|O||D||1
43191508|Teléfonos digitales|O|O||D||1
43191509|Teléfonos análogos|O|O||D||1
43191510|Radios de dos vías|O|O||D||1
43191511|Teléfonos ip|O|O||D||1
43191512|Teléfonos inalámbricos de telecomunicaciones inalámbricas digitales optimizadas dect|O|O||D||1
43191513|Video teléfono|O|O||D||1
43191514|Teléfono satelital|O|O||D||1
43191515|Teléfono manos libres|O|O||D||1
43191516|Sistema de conmutador telefónico|O|O||D||1
43191600|Partes o accesorios de dispositivos de comunicación personal|O|O||D||1
43191601|Placas frontales de teléfonos móviles|O|O||D||1|Display para celular o Smartphone, Micas para celular o Smartphone
43191602|Marcadores de teléfonos|O|O||D||1
43191603|Cables de extensión para teléfonos|O|O||D||1
43191604|Placas frontales de teléfonos|O|O||D||1
43191605|Cables para auriculares de teléfonos|O|O||D||1
43191606|Auriculares de teléfonos|O|O||D||1|Diademas para teléfonos
43191607|Almohadillas para el oído o el parlante de los auriculares de teléfonos|O|O||D||1
43191608|Tubos de voz para los auriculares de teléfonos|O|O||D||1
43191609|Teléfonos de diadema|O|O||D||1
43191610|Soportes o sujetadores o puestos de comunicación personal|O|O||D||1
43191611|Protectores de líneas telefónicas|O|O||D||1
43191612|Descansa teléfonos|O|O||D||1
43191614|Convertidores de voz para teléfonos|O|O||D||1
43191615|Set telefónico manos libres para vehículos|O|O||D||1
43191616|Consola central para teléfonos|O|O||D||1
43191618|Unidades de grabación de conversaciones|O|O||D||1
43191619|Dispositivos de señalización para teléfonos|O|O||D||1
43191621|Adaptadores de auriculares|O|O||D||1
43191622|Módulos o accesorios de busca personas|O|O||D||1
43191623|Teléfono de pago con mecanismos|O|O||D||1
43191624|Recipientes de monedas para teléfonos de pago|O|O||D||1
43191625|Cajas de monedas para teléfonos de pago|O|O||D||1
43191626|Tolvas para teléfonos de pago|O|O||D||1
43191627|Puertas de seguridad para las cajas de monedas de teléfonos de pago|O|O||D||1
43191628|Protectores de micrófono para teléfonos de pago|O|O||D||1
43191629|Pieles o placas frontales para notebook o palm|O|O||D||1|Carcasas o micas para tabletas
43191630|Kits de iniciación para teléfonos móviles|O|O||D||1
43191631|Clavijas de adaptadores o kits de campo o kits de viaje para teléfonos o módems|O|O||D||1|Cargadores de celular para vehículos
43191632|Antenas para teléfonos|O|O||D||1
43191633|Subconjuntos para conmutadores telefónicos|O|O||D||1
43191634|Tablero de extensión para conmutador telefónico|O|O||D||1
43201400|Tarjetas del sistema|O|O||D||1
43201401|Tarjetas aceleradoras de gráficas o video|O|O||D||1
43201402|Tarjetas de módulos de memoria|O|O||D||1
43201403|Tarjetas de módem|O|O||D||1
43201404|Tarjetas de interface de red|O|O||D||1
43201405|Tarjetas receptoras de red óptica|O|O||D||1
43201406|Tarjetas transmisoras de red óptica|O|O||D||1
43201407|Tarjetas periféricas controladoras|O|O||D||1
43201409|Tarjetas de interface de red inalámbrica|O|O||D||1
43201410|Tarjetas o puertos de interruptor|O|O||D||1
43201411|Tarjeta de interconexión de componente periférico pci|O|O||D||1
43201412|Tarjeta pcmcia o pc|O|O||D||1
43201413|Tarjeta debanda magnética|O|O||D||1
43201414|Protector de disco duro|O|O||D||1
43201415|Tarjeta de módulo de identidad del suscriptor sim|O|O||D||1
43201416|Tablero de adquisición de datos|O|O||D||1
43201417|Tableros multimedia integrados|O|O||D||1
43201500|Módulos o interfaces de procesadores de tablero (board) del sistema|O|O||D||1
43201501|Tarjetas de interface de telecomunicaciones de modo de transferencia asincrónico atm|O|O||D||1
43201502|Tarjetas de aceleración de audio|O|O||D||1
43201503|Procesadores de unidad de procesamiento central cpu|O|O||D||1
43201507|Placas secundarias|O|O||D||1
43201508|Módulo de fibra de compensación de dispersión dcfm|O|O||D||1
43201509|Módulos de intercambio de comunicación de datos|O|O||D||1
43201513|Placa central de microordenador.|O|O||D||1
43201522|Tarjetas de puertos paralelos|O|O||D||1
43201531|Tarjetas de captura de video|O|O||D||1
43201533|Interfaces de interface digital de instrumentos musicales midi|O|O||D||1
43201534|Interfaces de componentes de intercambio codec|O|O||D||1
43201535|Puertos seriales infrarrojos|O|O||D||1
43201537|Servidores de impresoras|O|O||D||1
43201538|Enfriadores de unidades de procesamiento central|O|O||D||1
43201539|Procesador central controlador de consola|O|O||D||1
43201540|Convertidor de canales|O|O||D||1
43201541|Procesador central de interface canal a canal|O|O||D||1
43201542|Unidad de control|O|O||D||1
43201543|Procesador central de instalación de acoplamientos|O|O||D||1
43201544|Convertidor o controlador de bus de interface|O|O||D||1
43201545|Tarjetas de fax|O|O||D||1
43201546|Tarjetas de audio conferencia|O|O||D||1
43201547|Tarjetas de voz|O|O||D||1
43201549|Interruptores de interface de bus|O|O||D||1
43201550|Dispositivo de sincronización de paquete de datos de red|O|O||D||1
43201552|Adaptadores para hardware o telefonía|O|O||D||1
43201553|Convertidores de transceptores y medios|O|O||D||1
43201554|Sintonizadores de televisión personal por computador pc tv|O|O||D||1
43201555|Sintonizadores de radio para pc|O|O||D||1
43201556|Adaptadores de interconexión de sistemas para pequeños computadores scsi|O|O||D||1
43201557|Controladores de arreglo redundante de discos independientes raid|O|O||D||1
43201558|Controlador de canales de fibra|O|O||D||1
43201559|Tarjetas de puerto serial|O|O||D||1
43201560|Coprocesador|O|O||D||1
43201600|Componentes del chasis|O|O||D||1
43201601|Carcasas de computadoras|O|O||D||1
43201602|Carcasas de equipos de red|O|O||D||1
43201603|Componentes de apilamiento de carcasas|O|O||D||1
43201604|Bahías o canastas para equipos electrónicos|O|O||D||1
43201605|Expansores|O|O||D||1
43201608|Marcos de drive removibles|O|O||D||1
43201609|Bandejas o ensamblajes para almacenamiento de dispositivos|O|O||D||1
43201610|Placas traseras o paneles o ensamblajes|O|O||D||1
43201611|Bastidores (dispositivos de montaje) para computadores|O|O||D||1
43201612|Placas frontales para computadores|O|O||D||1
43201614|Extensores de consola|O|O||D||1
43201615|Kits de cubiertas para bahías de drives|O|O||D||1
43201616|Torres de arreglo de drives de discos duros|O|O||D||1
43201617|Armazones para tarjetas|O|O||D||1
43201618|Componente de rack de computador|O|O||D||1
43201619|Ventilador enfriador de computador|O|O||D||1
43201800|Dispositivos de almacenamiento|O|O||D||1
43201801|Unidades de disco flexible|O|O||D||1
43201802|Series de disco duro|O|O||D||1
43201803|Unidades de disco duro|O|O||D||1
43201806|Series de cintas|O|O||D||1
43201807|Unidades de cintas|O|O||D||1
43201808|Disco compacto cd de sólo lectura|O|O||D||1
43201809|Disco compacto cd de lectura y escritura|O|O||D||1
43201810|Disco versátil digital dvd de sólo lectura|O|O||D||1
43201811|Disco versátil digital dvd de lectura y escritura|O|O||D||1
43201812|Unidades de magneto óptico mo|O|O||D||1
43201813|Unidades de medios removibles de alta capacidad|O|O||D||1
43201814|Equipos electrónicos de duplicación de medios o información|O|O||D||1
43201815|Unidades de lectura y escritura de arquitectura de interconexión de componentes periféricos|O|O||D||1
43201816|Unidades ópticas de ultra densidad udo o autocargardores o bibliotecas|O|O||D||1
43201817|Unidades de disco compacto cd|O|O||D||1
43201818|Unidades de discos digitales de video dvd|O|O||D||1
43201819|Disco versátil digital de alta definición hd dvd de sólo lectura|O|O||D||1
43201820|Disco versátil digital de alta definición hd dvd de lectura y escritura|O|O||D||1
43201821|Disco de blu-ray bd de sólo lectura|O|O||D||1
43201822|Disco de blu-ray br de lectura y escritura|O|O||D||1
43201823|Reproductor de unidades multimedia de disco duro hdd|O|O||D||1
43201825|Publicador de discos|O|O||D||1
43201826|Series de memoria de discos compactos cd de sólo lectura|O|O||D||1
43201827|Dispositivo de almacenamiento de disco duro portátil|O|O||D||1
43201828|Audio disco de video digital dvd a|O|O||D||1
43201829|Video disco de video digital dvd v|O|O||D||1
43201830|Unidad de estado sólido ssd|O|O||D||1
43201831|Unidad de memoria de telecomunicaciones|O|O||D||1
43201832|Cargador de discos (juke box) compactos u ópticos|O|O||D||1
43201833|Sistema de conversión de digital a análogo|O|O||D||1
43201834|Controlador de dispositivo de almacenamiento|O|O||D||1
43201835|Dispositivo de almacenamiento unido a la red nas|O|O||D||1
43201900|Accesorios de dispositivos de almacenamiento|O|O||D||1
43201902|Cambiadores de discos ópticos|O|O||D||1
43201903|Bibliotecas de unidades de cinta|O|O||D||1
43201904|Audio video de video discos digitales dvd av|O|O||D||1
43202000|Dispositivos de almacenamiento extraíbles|O|O||D||1
43202001|Discos compactos cd|O|O||D||1
43202002|Cintas en blanco|O|O||D||1
43202003|Discos versátiles digitales dvd|O|O||D||1
43202004|Discos flexibles|O|O||D||1
43202005|Tarjeta flash de almacenamiento de memoria|O|O||D||1
43202006|Discos magneto ópticos mo|O|O||D||1
43202007|Discos en blanco de medios removibles de gran capacidad|O|O||D||1
43202008|Discos en blanco de alta densidad óptica udo|O|O||D||1
43202009|Cintas de audio en blanco|O|O||D||1
43202010|Unidad pen o flash|O|O||D||1
43202100|Accesorios de dispositivos de almacenamiento extraíbles|O|O||D||1
43202101|Estuches para discos compactos|O|O||D||1
43202102|Estuches para discos flexibles|O|O||D||1
43202103|Sujetadores de almacenadores de multimedia|O|O||D||1
43202104|Almacenadores para video cintas de escáner de hélice vertical vhs o accesorios|O|O||D||1
43202105|Gabinetes para medios múltiples|O|O||D||1
43202106|Estuches o billeteras para medios portátiles|O|O||D||1
43202107|Maleta para discos compactos o discos digitales versátiles cd/dvd|O|O||D||1
43202108|Estuche para tarjeta de memoria|O|O||D||1
43202200|Subconjuntos para dispositivos electrónicos|O|O||D||1|Accesorios de computadora
43202201|Partes de piezas de teléfono|O|O||D||1
43202202|Generadores de timbres de teléfono|O|O||D||1
43202204|Timbres externos o sus partes|O|O||D||1
43202205|Teclas o teclados|O|O||D||1
43202206|Componentes de dispositivo de entrada o unidad de almacenamiento|O|O||D||1
43202207|Brazos y ensamblaje de cabezal|O|O||D||1
43202208|Ensamblajes de plomo|O|O||D||1
43202209|Ensamblajes de apilamiento de cabezales|O|O||D||1
43202210|Tope de protección anti choque|O|O||D||1
43202211|Platos o discos|O|O||D||1
43202212|Ensamblajes de cabezal de lectura y escritura|O|O||D||1
43202213|Unidades de disco de motor|O|O||D||1
43202214|Ensamblajes de regleta|O|O||D||1
43202215|Cable de teclado o mouse|O|O||D||1
43202216|Cable de conexión de impresora|O|O||D||1
43202217|Sujetador de cables de computador|O|O||D||1
43202218|Cubierta de cables de computador|O|O||D||1
43202219|Ensamblaje de cabezales de control de aire acondicionado de ventilación de automotores hvac|O|O||D||1
43202220|Módulo de energía de aire acondicionado de ventilación de automotores hvac|O|O||D||1
43202221|Ensamblaje de resistencias de aire acondicionado de ventilación de automotores hvac|O|O||D||1
43202222|Cables de computador|O|O||D||1|Cables de computadora
43211500|Computadores|O|O||D||1|Computadoras
43211501|Servidores de computador|O|O||D||1|Servidores de computadoras
43211502|Servidores de computador de gama alta|O|O||D||1|Servidores de computadoras de gama alta
43211503|Computadores notebook|O|O||D||1|Computadoras notebook
43211504|Asistentes personales digitales pda u organizadores|O|O||D||1|Agendas u organizadores digitales
43211505|Terminal de punto de venta pos|O|O||D||1
43211506|Computadores de cliente ligero|O|O||D||1|Ordenadores ligeros
43211507|Computadores de escritorio|O|O||D||1|Computadora de escritorio, Equipo de cómputo
43211508|Computadores personales|O|O||D||1|Computadoras personales o laptop, Equipo de cómputo
43211509|Computadores de tableta|O|O||D||1|Tabletas
43211510|Consola central o terminales básicos (no inteligentes)|O|O||D||1
43211511|Dispositivos de computación de vestir|O|O||D||1
43211512|Computadores centrales|O|O||D||1|Computadoras centrales
43211513|Computadores personales ultra móviles|O|O||D||1|Computadoras personales ultrabook
43211514|Kioscos de computadores|O|O||D||1|Kioscos de computadoras
43211515|Estaciones de trabajo para computadores|O|O||D||1|Estaciones de trabajo para computadoras
43211516|Minicomputadores|O|O||D||1|Minicomputadoras
43211517|Computadores análogos|O|O||D||1|Computadoras análogas
43211518|Computadores de múltiples pantallas|O|O||D||1|Computadoras de múltiples pantallas
43211600|Accesorios de computador|O|O||D||1|Accesorios de computadora
43211601|Cajas de interruptores de computador|O|O||D||1|Cajas de interruptores de computadora
43211602|Estaciones de acoplamiento|O|O||D||1
43211603|Replicadores de puertos|O|O||D||1
43211604|Cajas de interruptores periféricos|O|O||D||1
43211605|Actualizaciones de procesadores de señales|O|O||D||1
43211606|Kits de multimedia|O|O||D||1
43211607|Parlantes de computador|O|O||D||1|Altavoz para computadora, Bocina para computadora
43211608|Equipo codificador y decodificador|O|O||D||1
43211609|Concentrador de bus serial universal o conectores|O|O||D||1
43211610|Kits de países o localización para computadores|O|O||D||1
43211611|Kits de arranque de mano pda|O|O||D||1
43211612|Kits de accesorios de computador|O|O||D||1|Kits de accesorios para computadoras
43211613|Puestos para computadores o notebooks|O|O||D||1|Puestos para computadoras o notebooks
43211614|Adaptador de bus serial universal usb bluetooth|O|O||D||1
43211615|Puerto de expansión de computador notebook|O|O||D||1|Puerto de expansión de computadora notebook
43211616|Sujetador de asistente personal digital pda|O|O||D||1
43211617|Cable de extensión de bus serial universal usb|O|O||D||1
43211618|Módem de radio servicio de paquete general de bus serial universal|O|O||D||1
43211619|Estuche para transportar computadores notebook|O|O||D||1|Estuche para transportar computadoras notebook
43211700|Dispositivos informáticos de entrada de datos|O|O||D||1
43211701|Equipo de lectura de código de barras|O|O||D||1
43211702|Lectores y codificadores de banda magnética|O|O||D||1
43211704|Equipo de reconocimiento de billetes|O|O||D||1
43211705|Almohadillas o joy sticks de juegos|O|O||D||1
43211706|Teclados|O|O||D||1
43211707|Lápiz (stylus) para computador de luz|O|O||D||1
43211708|Mouse o bola de seguimiento para computador|O|O||D||1
43211709|Lápiz (stylus) de presión|O|O||D||1
43211710|Dispositivos de identificación de radio frecuencia|O|O||D||1
43211711|Escáneres|O|O||D||1
43211712|Tabletas de gráficos|O|O||D||1
43211713|Almohadillas (pads) táctil (touch)|O|O||D||1
43211714|Equipos de identificación biométrica|O|O||D||1
43211715|Terminales portátiles de ingreso de información|O|O||D||1
43211717|Sistemas de reconocimiento de caracteres ópticos|O|O||D||1
43211718|Sistemas de visión basados en cámaras para recolección automática de información|O|O||D||1
43211719|Micrófonos de voz para computadores|O|O||D||1
43211720|Terminales de pago para puntos de venta|O|O||D||1
43211721|Lectores de tarjetas perforadas|O|O||D||1
43211722|Escáneres de tarjetas de presentación|O|O||D||1
43211723|Equipos de votación electrónica o de conteo de votos|O|O||D||1
43211724|Kit periférico para computador|O|O||D||1
43211725|Limpiador de discos compactos o de discos versátiles digitales cd/dvd|O|O||D||1
43211726|Esferográfico digital|O|O||D||1
43211727|Dispositivo magnético de reconocimiento de caracteres en tinta micr|O|O||D||1
43211728|Terminal simple de tarjetas inteligentes|O|O||D||1
43211729|Lector de marcas ópticas|O|O||D||1
43211730|Sistema de adquisición de datos|O|O||D||1
43211731|Analizador de datos|O|O||D||1
43211732|Lector de películas digitales|O|O||D||1
43211800|Accesorios de dispositivos de entrada de datos de computador|O|O||D||1
43211801|Forros de dispositivos de ingreso de datos al computador|O|O||D||1
43211802|Almohadillas (pads) para mouse|O|O||D||1
43211803|Pieles (películas transparentes) para teclados|O|O||D||1
43211804|Cajones o estantes para tableros|O|O||D||1
43211805|Dispositivos para almacenamiento de kits de servicio|O|O||D||1
43211806|Descansa muñecas para teclado|O|O||D||1
43211807|Descansa muñecas para mouse|O|O||D||1
43211900|Monitores y pantallas de computador|O|O||D||1
43211901|Monitores para tubos de rayo catódico crt|O|O||D||1
43211902|Paneles o monitores de pantalla de cristal líquido lcd|O|O||D||1
43211903|Monitores de pantalla táctil (touch)|O|O||D||1
43211904|Paneles de pantalla de plasma pdp|O|O||D||1
43211905|Pantallas emisoras de luz orgánica|O|O||D||1
43211906|Pantallas de caracteres|O|O||D||1
43211907|Cascos de realidad virtual|O|O||D||1
43211908|Pantallas de vacío fluorescente|O|O||D||1
43211909|Pantallas emisoras de diodos de poli luz|O|O||D||1
43211910|Mecanismo de inclinación de pantallas|O|O||D||1
43211911|Vidrio de pantalla táctil (touch)|O|O||D||1
43211912|Película de pantalla táctil (touch)|O|O||D||1
43211913|Pantalla activa lcd|O|O||D||1
43211914|Pantalla pasiva lcd|O|O||D||1
43212000|Accesorios de pantallas de computador|O|O||D||1
43212001|Protectores de brillo para pantallas de computador|O|O||D||1
43212002|Brazos o soportes para monitores|O|O||D||1
43212100|Impresoras de computador|O|O||D||1
43212101|Impresoras de banda|O|O||D||1
43212102|Impresoras de matriz de puntos|O|O||D||1
43212103|Impresoras de sublimación de teñido|O|O||D||1
43212104|Impresoras de inyección de tinta|O|O||D||1
43212105|Impresoras láser|O|O||D||1
43212106|Impresoras de matriz de líneas|O|O||D||1
43212107|Impresoras de plotter|O|O||D||1
43212108|Impresoras de cinta térmica|O|O||D||1
43212109|Impresoras de etiquetas para bolsas|O|O||D||1
43212110|Impresoras de múltiples funciones|O|O||D||1
43212111|Impresoras de tiquetes aéreos o pases de abordaje atb|O|O||D||1
43212112|Impresoras de recibos para puntos de venta pos|O|O||D||1
43212113|Impresoras de discos compactos cd o de etiquetado|O|O||D||1
43212114|Impresoras de imágenes digitales|O|O||D||1
43212115|Impresoras de códigos de barra|O|O||D||1
43212116|Impresoras de etiquetas de identificación de radio frecuencia rfid|O|O||D||1
43212117|Controlador para impresoras|O|O||D||1
43212200|Sistemas de manejo de almacenamiento de datos de computador|O|O||D||1
43212201|Sistema de almacenamiento virtual|O|O||D||1
43221500|Sistemas de gestión de llamadas o accesorios|O|O||D||1
43221501|Sistemas de atención automatizada|O|O||D||1
43221502|Distribuidor automático de llamadas acd|O|O||D||1
43221503|Alto parlantes para telecomunicaciones|O|O||D||1
43221504|Central telefónica interna pbx|O|O||D||1
43221505|Identificador de llamadas telefónicas autónoma|O|O||D||1
43221506|Consola de teleconferencias|O|O||D||1
43221507|Auto marcadores|O|O||D||1
43221508|Campos de lámpara de teléfono ocupado|O|O||D||1
43221509|Sistemas de contabilización de llamadas telefónicas|O|O||D||1
43221510|Desviador o retransmisor de llamadas telefónicas|O|O||D||1
43221513|Secuenciadores de llamadas telefónicas|O|O||D||1
43221514|Unidades de respaldo de marcación telefónica|O|O||D||1
43221515|Dispositivos para compartir líneas telefónicas|O|O||D||1
43221516|Monitores de estado de líneas telefónicas|O|O||D||1
43221517|Unidades de observación de servicio de equipos de telefonía|O|O||D||1
43221518|Dispositivos para restringir llamadas para equipos de telefonía|O|O||D||1
43221519|Sistemas de correo de voz|O|O||D||1
43221520|Equipos interactivos de reconocimiento de voz|O|O||D||1
43221521|Unidades de acceso remoto de telecomunicaciones|O|O||D||1
43221522|Equipos de teleconferencia|O|O||D||1
43221523|Grabadora de música o mensaje en espera|O|O||D||1
43221524|Adaptador de música en espera|O|O||D||1
43221525|Sistemas de intercomunicación|O|O||D||1
43221526|Sistemas de entrada de teléfono|O|O||D||1
43221527|Protector de “chuzadas” (acceso ilegal) de cable|O|O||D||1
43221528|Unidad de señales de supervisión|O|O||D||1
43221529|Medidor de llamadas|O|O||D||1
43221530|Dispositivo de señales de conmutador|O|O||D||1
43221600|Componentes y equipo de acceso de abonado de línea digital (DSL) y accesorios|O|O||D||1
43221601|Separador de sistema de antiguo teléfono simple de empresa cautiva pots de circuito de subscriptor digital dsl|O|O||D||1
43221602|Estante para separador de empresa cautiva de circuito de subscriptor digital dsl|O|O||D||1
43221603|Separador de sistema de antiguo teléfono simple pots de equipo de premisa de cliente cpe de circuito de subscriptor digital dsl|O|O||D||1
43221604|Equipo de circuito o línea de subscriptor digital xdsl|O|O||D||1
43221700|Equipo fijo de red y componentes|O|O||D||1
43221701|Equipo central de televisión|O|O||D||1
43221702|Equipo de acceso de televisión|O|O||D||1
43221703|Antenas de televisión|O|O||D||1
43221704|Equipo central de radio|O|O||D||1
43221705|Equipo de radio acceso|O|O||D||1
43221706|Antenas de radio|O|O||D||1
43221707|Equipo central de microondas|O|O||D||1
43221708|Equipo de acceso de microondas|O|O||D||1
43221709|Antenas de microondas|O|O||D||1
43221710|Equipo central de satélite|O|O||D||1
43221711|Equipo de acceso de satélite|O|O||D||1
43221712|Antenas de satélite|O|O||D||1
43221713|Equipo central de onda corta|O|O||D||1
43221714|Equipo de acceso de onda corta|O|O||D||1
43221715|Antenas de onda corta|O|O||D||1
43221716|Equipo central de buscapersonas|O|O||D||1
43221717|Equipo de acceso de buscapersonas|O|O||D||1
43221718|Antenas de radar|O|O||D||1
43221719|Antenas de aeronaves|O|O||D||1
43221720|Antenas de automotores|O|O||D||1
43221721|Equipo de comunicación de información de radio frecuencia|O|O||D||1
43221722|Antena de sistema de posicionamiento geográfico gps|O|O||D||1
43221723|Antena de celular|O|O||D||1
43221724|Generador sincronizado de tiempo|O|O||D||1
43221725|Divisor de señales|O|O||D||1
43221726|Reflector para antenas|O|O||D||1
43221727|Accesorio para antenas|O|O||D||1
43221728|Radomos o domo para radares|O|O||D||1
43221729|Antenas portátiles|O|O||D||1
43221730|Transmisor de telecomunicaciones por cable|O|O||D||1
43221731|Sistema de comunicación bajo el agua|O|O||D||1
43221732|Unidad de control de altavoces|O|O||D||1
43221733|Sistema de medición de lectura automática remota|O|O||D||1
43221800|Dispositivos de red óptica|O|O||D||1
43221801|Amplificadores ópticos|O|O||D||1
43221802|Filtros de redes o comunicaciones ópticas|O|O||D||1
43221803|Adaptadores ópticos|O|O||D||1
43221804|Láseres de red óptica|O|O||D||1
43221805|Equipo de red de modo de transferencia asincrónica atm|O|O||D||1
43221806|Equipos de red de red óptica sincrónica sonet|O|O||D||1
43221807|Filtros multiplexados de división de longitud de onda densa de telecomunicaciones dwdm|O|O||D||1
43221808|Equipos de telecomunicaciones jerárquicas digitales sincrónicas sdh|O|O||D||1
43221809|Transmisor óptico|O|O||D||1
43221810|Multiplexador óptico|O|O||D||1
43221811|Interruptor óptico|O|O||D||1
43222500|Equipo de seguridad de red|O|O||D||1
43222501|Equipo de seguridad de red cortafuegos (firewall)|O|O||D||1
43222502|Equipo de seguridad de redes vpn|O|O||D||1
43222503|Equipos de seguridad de evaluación de vulnerabilidad|O|O||D||1
43222504|Transmisor de interferencias de radio|O|O||D||1
43222600|Equipo de servicio de red|O|O||D||1
43222602|Equipo de centro distribuidor de cables|O|O||D||1
43222604|Equipo de red de entrega de contenido|O|O||D||1
43222605|Puerta de acceso de redes|O|O||D||1
43222606|Kit de inicio de nodo de servicio de internet|O|O||D||1
43222607|Equipo de motor de caché|O|O||D||1
43222608|Repetidores de red|O|O||D||1
43222609|Enrutadores (routers) de red|O|O||D||1
43222610|Concentradores o hubs de servicio de red|O|O||D||1
43222611|Unidades de servicio de canales o información de red|O|O||D||1
43222612|Interruptores de red|O|O||D||1
43222615|Interruptor de área de almacenamiento de red san|O|O||D||1
43222619|Equipo de video de red|O|O||D||1
43222620|Interruptor multi servicios|O|O||D||1
43222621|Interruptor de contenido|O|O||D||1
43222622|Dispositivo para balancear la carga del servidor|O|O||D||1
43222623|Equipos de conexión cruzada digital dcx|O|O||D||1
43222624|Equipos de conexión cruzada óptica|O|O||D||1
43222625|Servidores de acceso|O|O||D||1
43222626|Módems de cable|O|O||D||1
43222627|Dispositivos de acceso de redes digitales de servicios integrados isdn|O|O||D||1
43222628|Módems|O|O||D||1
43222629|Bancos de módems|O|O||D||1
43222630|Unidades de acceso multi estaciones|O|O||D||1
43222631|Estaciones base de fidelidad inalámbricas|O|O||D||1
43222632|Agregadores de banda ancha|O|O||D||1
43222633|Adaptadores de manejo remoto|O|O||D||1
43222634|Dispositivo de monitoreo o manejo de redes|O|O||D||1
43222635|Kit de actualización de equipo de redes|O|O||D||1
43222636|Motor de aplicación de redes|O|O||D||1
43222637|Red óptica pasiva de gigabytes gpon|O|O||D||1
43222638|Equipos de red de línea dedicada manejada mlln|O|O||D||1
43222639|Hardware de subsistemas multimedia de protocolo de internet ip|O|O||D||1
43222640|Punto de acceso inalámbrico|O|O||D||1
43222641|Dispositivo de protocolo de internet compartido|O|O||D||1
43222642|Interruptor de enrutador (router)|O|O||D||1
43222643|Probador de cable de red|O|O||D||1
43222644|Controlador de tráfico de red|O|O||D||1
43222700|Equipo telegráfico|O|O||D||1
43222701|Teclas de telégrafo|O|O||D||1
43222702|Electro magnetos de telégrafo|O|O||D||1|Electroimanes de telégrafo
43222703|Receptor acústico de telégrafo|O|O||D||1|Sondas para telégrafo
43222704|Conmutador de telégrafo|O|O||D||1
43222800|Equipo de telefonía|O|O||D||1
43222801|Equipo de conexión cruzada digital dcx de banda estrecha o de banda ancha|O|O||D||1|Equipos DCX de banda ancha o banda estrecha de interconexión digital
43222802|Equipo de circuito de conmutador|O|O||D||1|Equipos de conmutadores de circuitos
43222803|Cargador de circuito digital dlc|O|O||D||1|Porta bobina digital DLC
43222805|Equipo de central telefónica privada pbx|O|O||D||1|Central privada automática PBX
43222806|Bloques de conexiones|O|O||D||1|Bloque de conexión rápida para telefonía
43222811|Unidades de alarma de equipos de telefonía|O|O||D||1|Unidades de alarma de equipos de telefonía
43222813|Kits de partes de conmutadores telefónicos|O|O||D||1
43222814|Kits de instalación o modificación de equipos de telecomunicaciones|O|O||D||1
43222815|Unidades de terminales de telecomunicaciones|O|O||D||1
43222816|Operadores de introducción de datos de telefonía|O|O||D||1
43222817|Repetidores de telecomunicaciones|O|O||D||1|Amplificadores de telecomunicaciones
43222818|Estructura de terminal de distribución de teléfono|O|O||D||1
43222819|Paneles de conexión de puertos|O|O||D||1|Bahía de rutas de puertos
43222820|Equipo electrónico para cancelar eco de voz|O|O||D||1|Anuladores de eco de voz
43222822|Multiplexor de división de tiempo tdm|O|O||D||1
43222823|Multiplexor de división de onda wdm|O|O||D||1
43222824|Enrolladores de cables aéreos|O|O||D||1
43222825|Kits de modificación de teléfonos|O|O||D||1
43222826|Terminal portadora|O|O||D||1
43222827|Multiplexor o mux|O|O||D||1
43222900|Accesorios de equipo de telefonía|O|O||D||1
43222901|Acondicionadores de línea|O|O||D||1|Reguladores de voltaje
43222902|Secadores de aire para cables de telefonía|O|O||D||1
43222903|Torre o soporte para telecomunicaciones|O|O||D||1
43223000|Equipo de teletipo|O|O||D||1
43223001|Dispositivos de entrada de teletipos|O|O||D||1
43223100|Componentes y equipo de infraestructura de redes móviles y digitales|O|O||D||1
43223101|Equipos y componentes de red básica móvil gsm 2g|O|O||D||1
43223102|Equipos y componentes de red de acceso inalámbrica gsm 2g|O|O||D||1
43223103|Equipos y componentes de red básica móvil gprs 2.5g|O|O||D||1
43223104|Equipos y componentes de red de acceso inalámbrica gprs 2.5g|O|O||D||1
43223105|Equipos y componentes de red básica móvil umts 3g|O|O||D||1
43223106|Equipos y componentes de red de acceso inalámbrica 3g umts|O|O||D||1
43223107|Equipos y componentes de red básica móvil wlan|O|O||D||1
43223108|Equipos y componentes de acceso inalámbrico wlan|O|O||D||1
43223109|Equipo de interrupción ssp in|O|O||D||1
43223110|Equipo básico móvil in|O|O||D||1
43223111|Equipos y componentes de red básica móvil oss|O|O||D||1
43223112|Equipos y componentes de red de acceso inalámbrica oss|O|O||D||1
43223113|Antenas lan umt gsm|O|O||D||1
43223200|Plataformas de mensajería por móvil|O|O||D||1
43223201|Portal de mensajes de voz|O|O||D||1
43223202|Centro de servicio de mensajes cortos|O|O||D||1
43223203|Centros de servicio multimedia|O|O||D||1
43223204|Plataforma de mensajes unificados|O|O||D||1
43223205|Plataforma de mensajes instantáneos|O|O||D||1
43223206|Puerta de enlace de internet inalámbrico|O|O||D||1
43223207|Sistema de flujo de video|O|O||D||1
43223208|Plataforma de juegos móvil o de mensajes|O|O||D
43223209|Plataforma de servicios de mensajes basados en locación|O|O||D||1
43223210|Sistemas de mensajes de micro pagos|O|O||D||1
43223211|Controladores de buscapersonas|O|O||D||1
43223212|Terminales de buscapersonas|O|O||D||1
43223300|Dispositivos y equipos para instalación de conectividad de redes y Datacom|O|O||D||1
43223301|Sistema y accesorios de conexión cruzada de comunicación de datos|O|O||D||1
43223302|Etiqueta de comunicación de datos|O|O||D||1
43223303|Cable de conexión de comunicación de datos|O|O||D||1
43223305|Ensamblaje de paneles de manejo de cables de red|O|O||D||1
43223306|Gabinete o cerramiento para sistemas de red|O|O||D||1
43223307|Caja de cables para sistemas de red|O|O||D||1
43223308|Estantes para equipos de sistemas de red|O|O||D||1
43223309|Panel de conexión|O|O||D||1|Bahía de rutas, Panel de conexiones
43223310|Conector de fibra óptica|O|O||D||1
43223311|Atenuador de fibra óptica|O|O||D||1
43223312|Pela cables de fibra óptica|O|O||D||1|Pinza Pela cables de fibra óptica
43223313|Engarzador de fibra óptica|O|O||D||1|Pinza Engarzador de fibra óptica
43223314|Dispositivo para pulir fibra óptica|O|O||D||1|Lustrador de fibra óptica
43223315|Set de cuchillas para herramientas de fibra óptica|O|O||D||1|Juego de herramientas de fibra óptica
43223316|Punzón de fibra óptica|O|O||D||1
43223317|Removedor de búfer de fibra óptica|O|O||D||1|Removedor de tampón de fibra óptica
43223318|Emisor de fibra óptica|O|O||D||1
43223319|Detector de fibra óptica|O|O||D||1
43223320|Probador de continuidad de fibra óptica|O|O||D||1
43223321|Clip conector de fibra óptica|O|O||D||1|Broche conector de fibra óptica
43223322|Gancho de soporte de fibra óptica|O|O||D||1
43223323|Adaptador de fibra óptica|O|O||D||1
43223324|Película pulidora de fibra óptica|O|O||D||1
43223325|Hisopos para fibra óptica|O|O||D||1
43223326|Cable de conexión de fibra óptica|O|O||D||1
43223327|Localizador de fallas de fibra óptica|O|O||D||1
43223328|Panel de conexión de fibra óptica|O|O||D||1|Panel de conexiones de fibra óptica
43223329|Fuente de luz de fibra óptica|O|O||D||1|Alimentador de luz de fibra óptica
43223330|Herramientas de ensamblaje de conector de fibra óptica|O|O||D||1|Herramientas de montaje de conector de fibra óptica, Instrumentos de ensamble de conector de fibra óptica
43223331|Inserto de fibra óptica|O|O||D||1
43223332|Kit de herramientas de fibra óptica|O|O||D||1
43223333|Lente de alcance de fibra óptica|O|O||D||1|Ocular de alcance de fibra óptica
43223334|Set de herramientas y tintes de fibra óptica|O|O||D||1
43223335|Cable de música de fibra óptica|O|O||D||1|Cable de fibra óptica de música
43223336|Adaptador de alcance de fibra óptica|O|O||D||1
43223337|Cerramiento de fibra óptica|O|O||D||1|Caja de fibra óptica
43223338|Cerramiento de conexión de fibra óptica|O|O||D||1|Cierre de conexión para fibra óptica
43223339|Caja de distribución de fibra óptica|O|O||D||1
43223340|Empalmadora de fusión de fibra óptica|O|O||D||1
43223341|Combinadora|O|O||D||1|Combinador
43223342|Kit de conexión y guía de onda|O|O||D||1|Guía de ondas y kit de conexión
43223343|Herramienta de “punchdown” de red|O|O||D||1|Herramienta de perforación de red
43231500|Software funcional específico de la empresa|O|O||D
43231501|Software de mesa de ayuda o centro de llamadas (call center)|O|O||D
43231503|Software de adquisiciones|O|O||D
43231505|Software de recursos humanos|O|O||D|||Programa de recursos humanos
43231506|Software de logística de planeación de requerimiento de materiales y cadena de suministros|O|O||D|||Programa de logística de planeación de requerimiento de materiales y cadena de suministros
43231507|Software de manejo de proyectos|O|O||D|||Programa de manejo de proyectos
43231508|Software de manejo de inventarios|O|O||D|||Programa de manejo de inventarios
43231509|Software de barras de códigos|O|O||D|||Programa de barras de códigos
43231510|Software para hacer etiquetas|O|O||D|||Programa para hacer etiquetas
43231511|Software de sistemas expertos|O|O||D|||Programa de sistemas expertos
43231512|Software de manejo de licencias|O|O||D|||Programa de manejo de licencias
43231513|Software para oficinas|O|O||D|||Programa para oficinas
43231514|Software de ventas y mercadeo|O|O||D|||Programa de ventas y mercadeo
43231515|Software de envío y embarque|O|O||D|||Programa de envío y embarque
43231600|Software de planificación de recursos empresariales (ERP) y contabilidad financiera|O|O||D
43231601|Software de contabilidad|O|O||D|||Programa de contabilidad
43231602|Software de planeación de recursos del negocio erp|O|O||D|||Programa de planeación de recursos del negocio erp
43231603|Software de preparación tributaria|O|O||D|||Programa de preparación tributaria
43231604|Software de análisis financiero|O|O||D|||Programa de análisis financiero
43231605|Software de contabilidad de tiempo|O|O||D|||Programa de contabilidad de tiempo
43232000|Software de entretenimiento o juegos de computador|O|O||D
43232001|Juegos de acción|O|O||D|||Videojuego de acción
43232002|Juegos de aventuras|O|O||D|||Videojuego de aventuras
43232003|Juegos de deportes|O|O||D|||Videojuegos de deportes
43232004|Software familiar|O|O||D|||Programa familiar
43232005|Software de edición de música o sonido|O|O||D|||Programa de edición de música de sonido
43232100|Software de edición y creación de contenidos|O|O||D
43232101|Software de diseño de patrones|O|O||D|||Programa de diseño de patrones
43232102|Software de imágenes gráficas o de fotografía|O|O||D|||Programa de imágenes gráficas o de fotografía
43232103|Software de creación y edición de video|O|O||D|||Programa de creación y edición de video
43232104|Software de procesamiento de palabras|O|O||D|||Programa de procesamiento de palabras
43232105|Software de gráficas|O|O||D|||Programa de gráficas
43232106|Software de presentación|O|O||D|||Programa de presentación
43232107|Software de creación y edición de páginas web|O|O||D|||Programa de creación y edición de páginas web
43232108|Software de calendario y programación de citas|O|O||D|||Programa de calendario y programación de citas
43232110|Software de hoja de cálculo|O|O||D|||Programa de hoja de cálculo
43232111|Software de lector de caracteres ópticos ocr o de escáner|O|O||D|||Lector óptico de caracteres OCR o programa de escaneado
43232112|Software de autoedición|O|O||D|||Programa de edición electrónica
43232200|Software de gestión de contenidos|O|O||D
43232201|Software de flujo de trabajo de contenido|O|O||D|||Programa de flujo de trabajo de contenido
43232202|Software de manejo de documentos|O|O||D|||Programa de administración de documentos
43232203|Software de versiones de archivo|O|O||D|||Programa de control de versiones de archivos
43232204|Software de ingreso de texto incrustado|O|O||D|||Programa de ingreso de texto incrustado
43232205|Software de tipos de letra|O|O||D|||Programa de fuentes, Programa de tips de letra
43232300|Software de consultas y gestión de datos|O|O||D
43232301|Software de categorización o clasificación|O|O||D|||Programa de categorización o clasificación
43232302|Software de agrupamiento de recursos|O|O||D|||Programa de agrupamiento de recursos
43232303|Software de manejo de relaciones con el cliente crm|O|O||D|||Programa de manejo de relaciones con el cliente crm
43232304|Software de sistemas de manejo de base datos|O|O||D|||Programa de sistemas de manejo de base de datos
43232305|Software de reportes de bases de datos|O|O||D|||Programa de informes de bases de datos, Programa de reportes de bases de datos
43232306|Software de interface y preguntas de usuario de base de datos|O|O||D|||Interfaz para usuario de base de datos y programa de consulta
43232307|Software de extracción de datos|O|O||D|||Programa de extracción de datos
43232309|Software de recuperación o búsqueda de información|O|O||D|||Programa de recuperación o búsqueda de información
43232310|Software de manejo de metadata|O|O||D|||Programa de administración de datos, Programa de manejo de datos
43232311|Software de manejo de base de datos orientada al objeto|O|O||D|||Programa de administración de base de datos orientada a objetos, Programa de manejo de base de datos orientada al objeto
43232312|Software de servidor de portales|O|O||D|||Programa de servidor de portales
43232313|Software de servidor de transacciones|O|O||D|||Programa de servidor de transacciones
43232400|Programas de desarrollo|O|O||D
43232401|Software de manejo de configuraciones|O|O||D|||Programa de administración de configuraciones, Programa de manejo de configuraciones
43232402|Software de entorno de desarrollo|O|O||D|||Programa de entorno de desarrollo
43232403|Software de integración de aplicaciones de empresas|O|O||D|||Programa de integración de aplicaciones de empresas
43232404|Software de desarrollo de interface de usuario gráfica|O|O||D|||Programa de desarrollo de interfaz gráfica de usuario
43232405|Software de desarrollo orientado a objetos o componentes|O|O||D|||Programa de desarrollo orientado a objetos o componentes
43232406|Software de pruebas de programas|O|O||D|||Programa para pruebas de calidad de uso o ejecución
43232407|Software de arquitectura de sistemas y análisis de requerimientos|O|O||D|||Programa de arquitectura de sistemas y análisis de requerimientos
43232408|Software de desarrollo de plataformas web|O|O||D|||Programa de desarrollo de plataformas web
43232409|Software para compilar y descompilar|O|O||D|||Programa del compilador y del decompilador
43232500|Software educativo o de referencia|O|O||D
43232501|Software de idiomas extranjeros (traductores)|O|O||D|||Programa de lengua extranjera, Programa para traducciones
43232502|Software de entrenamiento basado en computadores|O|O||D|||Programa de entrenamiento basado en computadoras
43232503|Correctores de ortografía|O|O||D|||Correctores de ortográficos
43232504|Software de navegación de rutas|O|O||D|||Programa de navegación de rutas
43232505|Software educacional multimedios|O|O||D|||Programa educacional multimedios
43232506|Software de enciclopedias|O|O||D|||Programa de enciclopedias
43232507|Software de diccionarios|O|O||D|||Programa de diccionarios
43232508|Software de libretas de teléfonos|O|O||D|||Programa de la agenda telefónica, Programa de libretas de teléfonos
43232600|Software específico para la industria|O|O||D
43232601|Software de soporte de aviación en tierra|O|O||D|||Programa de soporte terrestre de aviación
43232602|Software de pruebas de aviación|O|O||D|||Programa de pruebas de aviación
43232603|Software de manejo de instalaciones|O|O||D|||Programa de administración de instalaciones
43232604|Software de diseño asistido de computador cad|O|O||D|||Programa CAD de diseño asistido por computadora, Programa CAD de diseño asistido por ordenador
43232605|Software analítico o científico|O|O||D|||Programa analítico o científico
43232606|Software de cumplimiento (compliance)|O|O||D|||Programa de GRC
43232607|Software de control de vuelos|O|O||D|||Programa de control de vuelos
43232608|Software de control industrial|O|O||D|||Programa de Vigilancia industrial, Programa de control industrial, Programa de supervisión industria
43232609|Software de bibliotecas|O|O||D|||Programa de bibliotecas
43232610|Software médico|O|O||D
43232611|Software de puntos de venta pos|O|O||D|||Programa punto de venta POS
43232612|Software de fabricación asistida por computador cam|O|O||D|||Programa de fabricación asistida por computadora CAM
43232613|Software de sistema de ejecución de fabricación mes|O|O||D|||Programa de sistema de ejecución de fabricación mes
43232614|Sistema de fabricación asistida por computador cam y de diseño asistido por computador cad|O|O||D|||Sistema de fabricación asistida por computadora CAM y de diseño asistido CAD
43232700|Software de aplicaciones de red|O|O||D
43232701|Software de servidor de aplicaciones|O|O||D|||Programa de servidor de aplicaciones
43232702|Software de comunicaciones de escritorio|O|O||D|||Programa de comunicaciones de escritorio
43232703|Software de respuesta de voz interactiva|O|O||D|||Programa interactivo de respuesta de voz
43232704|Software de servicios de directorio por internet|O|O||D|||Programa de servicios de directorio por internet
43232705|Software de navegador de internet|O|O||D|||Programa de navegador de internet
43232800|Software de administración de redes|O|O||D
43232801|Software de monitoreo de red|O|O||D|||Programa de monitoreo de red
43232802|Software de optimización del sistema operativo de red|O|O||D|||Programa de mejora del sistema operativo de red, Programa de optimización del sistema operativo de red
43232803|Software de manejo de red óptica|O|O||D|||Programa de administración de red óptica, Programa de manejo de red óptica
43232804|Software de administración|O|O||D|||Programa de administración
43232805|Software de subsistema de multimedia de protocolo de internet ip|O|O||D|||Programa de subsistema de multimedia de protocolo de internet ip
43232900|Software para trabajo en redes|O|O||D
43232901|Software de acceso|O|O||D|||Programa de acceso
43232902|Software de servidor de comunicaciones|O|O||D|||Programa de servidor de comunicaciones
43232903|Software de centro de contactos|O|O||D|||Programa de centro de contactos
43232904|Software de fax|O|O||D|||Programa de fax
43232905|Software de lan|O|O||D|||Programa de red de área local (LAN)
43232906|Software de multiplexor|O|O||D|||Programa de multiplexor
43232907|Software de almacenamiento de red|O|O||D|||Programa de almacenamiento de red
43232908|Software de interruptor o enrutador|O|O||D|||Programa de interruptor o enrutador
43232909|Software y firmware de interruptor wan|O|O||D|||Programa de conmutación o red de área amplia o firmware
43232910|Software inalámbrico|O|O||D|||Programa inalámbrico
43232911|Software de emulación de terminal de conectividad de red|O|O||D|||Programa de emulación de terminal de conectividad de red
43232912|Software de puerta de acceso|O|O||D|||Programa de puerta de acceso
43232913|Software de puente|O|O||D|||Programa de puente
43232914|Software de módem|O|O||D|||Programa de módem
43232915|Software de interconectividad de plataformas|O|O||D|||Programa de interconectividad de plataformas
43232916|Software irda de transferencia de información infrarrojo|O|O||D
43233000|Software de entorno operativo|O|O||D
43233001|Software de sistema de archivo|O|O||D|||Programa de sistema de archivo
43233002|Software de sistema de operación de red|O|O||D|||Programa de sistema de operación de red
43233004|Software de sistema operativo|O|O||D|||Programa de sistema operativo
43233005|Firmware de computador|O|O||D|||Firmware de computadora, Firmware de ordenador
43233200|Software de seguridad y protección|O|O||D
43233201|Software de servidor de autenticación|O|O||D|||Programa de servidor de autenticación
43233203|Software de manejo de seguridad de red o de redes privadas virtuales vpn|O|O||D|||Programa de administración de seguridad de red o de redes privadas virtuales vpn, Programa de manejo de seguridad de red o de redes privadas virtuales vpn
43233204|Software de equipos de seguridad de red y de redes privadas virtuales vpn|O|O||D|||Programa de equipos de seguridad de red y de redes privadas virtuales vpn
43233205|Software de seguridad de transacciones y de protección contra virus|O|O||D|||Programa de seguridad de transacciones y de protección contra virus
43233400|Software de controladores de dispositivos y utilidades|O|O||D
43233401|Software de servidor de discos compactos cd|O|O||D|||Programa de servidor de discos compactos cd
43233402|Software de conversión de información|O|O||D|||Programa de conversión de datos, Programa de conversión de información, Programa de transformación de informació
43233403|Software de compresión de información|O|O||D|||Programa de compresión de información, Programa de contracción de información, Programa para comprimir informació
43233404|Software discos compactos cd o dvd o tarjetas de sonido|O|O||D|||Software o controladores para unidades de CD, DVD o tarjeta de sonido
43233405|Software de controladores o sistemas de dispositivos|O|O||D|||Programa de controladores o sistemas de dispositivos
43233406|Software de controladores de ethernet|O|O||D|||Programa de controladores de ethernet
43233407|Software de controladores de tarjetas de gráficos|O|O||D|||Programa de controladores de tarjetas de gráficos
43233410|Software de controladores de impresoras|O|O||D|||Programa de controladores de impresoras
43233411|Software de protectores de pantalla|O|O||D|||Programa de protectores de pantalla
43233413|Software de reconocimiento de voz|O|O||D|||Programa de reconocimiento de voz
43233414|Software de carga de almacenamiento de medios|O|O||D|||Programa de carga de medios de almacenamiento
43233415|Software de respaldo o archivo|O|O||D|||Programa de respaldo o archivo
43233416|Plataformas de codificación – decodificación|O|O||D||1
43233417|Componentes de software de reconocimiento de escritura manuscrita|O|O||D||1|Componentes del programa de reconocimiento de escritura a mano
43233418|Controladores de memoria|O|O||D
43233419|Plataformas de multimedia|O|O||D
43233420|Software de conversión de texto a voz|O|O||D||1|Programa de conversión de texto a voz
43233421|Controladores de video|O|O||D
43233500|Software de intercambio de información|O|O||D
43233501|Software de correo electrónico|O|O||D|||Programa de correo electrónico
43233502|Software de video conferencias|O|O||D|||Programa de videoconferencias
43233503|Software de conferencias de red|O|O||D|||Programa de conferencias de red
43233504|Software de mensajería instantánea|O|O||D|||Programa de mensajería instantánea
43233505|Software de música ambiental o publicidad para mensajería|O|O||D|||Programa de música ambiental o publicidad para mensajería
43233506|Software de creación de mapas|O|O||D|||Programa de creación de mapas
43233507|Software estándar específico para operadores de móviles|O|O||D|||Programa estándar específico para operadores de móviles
43233508|Software de aplicación específica para operadores de móviles|O|O||D|||Programa de aplicación específica para operadores de móviles
43233509|Software de servicios de mensajería para móviles|O|O||D|||Programa de servicios de mensajería para móviles
43233510|Software de servicios de internet para móviles|O|O||D|||Programa de servicios de internet para móviles
43233511|Software de servicios basados en ubicación para móviles|O|O||D|||Programa de servicios basados en localización móvil, Programa de servicios basados en ubicación para móviles
43233512|Software de tonos de timbre|O|O||D|||Programa de tonos de timbre
43233600|Software de equipo eléctrico|O|O||D
43233601|Software de controlador del motor|O|O||D|||Programa de controlador del motor
43233602|Software de monitor de energía|O|O||D|||Programa de monitor de energía
43233603|Software de control lógico programable|O|O||D|||Programa de control lógico programable
43233700|Software de administración de sistemas|O|O||D
43233701|Software de manejo de sistemas de empresas|O|O||D|||Programa de administración de sistemas de empresas, Programa de manejo de sistemas de empresas
44101500|Máquinas de duplicación|O|O||D||1
44101501|Fotocopiadoras|O|O||D||1|Copiadora
44101503|Máquinas multifuncionales|O|O||D||1
44101504|Emisores (senders) digitales|O|O||D||1
44101505|Duplicadores digitales|O|O||D||1
44101506|Máquinas de interruptor de fax|O|O||D||1
44101507|Máquina de fax de inyección de tinta|O|O||D||1
44101508|Máquina de fax láser|O|O||D||1
44101509|Máquina de fax térmica|O|O||D||1
44101510|Fax o radiofax climático|O|O||D||1
44101600|Máquinas para procesamiento de papel y accesorios|O|O||D||1
44101601|Máquinas cortadoras de papel o accesorios|O|O||D||1
44101602|Máquinas perforadoras o para unir papel|O|O||D||1|Máquinas para perforar o encuadernar papel
44101603|Máquinas trituradoras de papel o accesorios|O|O||D||1
44101604|Tablas de protección de base|O|O||D||1|Tableros de protección base
44101605|Máquinas para emparejar papel|O|O||D||1|Máquinas para nivelar papel
44101606|Máquinas para clasificar papel|O|O||D||1
44101607|Máquinas de prensa de papel|O|O||D||1
44101700|Accesorios para impresoras, fotocopiadoras y aparatos de fax|O|O||D||1
44101701|Opciones de color o actualizaciones|O|O||D||1
44101702|Bandejas de impresión a doble cara|O|O||D||1|Bandejas de impresión  dúplex
44101703|Unidades de impresión a doble cara|O|O||D||1|Unidades de impresión dúplex
44101704|Terminales de facsímil|O|O||D||1
44101705|Bandejas o alimentadores de máquinas de oficina|O|O||D||1
44101706|Unidades de fotoconductores o imágenes|O|O||D||1
44101707|Unidades de grapadoras|O|O||D||1
44101708|Filtros de ozono|O|O||D||1
44101709|Ensamblajes de réplica|O|O||D||1
44101710|Ensamblajes magnéticos de recogida|O|O||D||1
44101711|Compresor de ensamblaje|O|O||D||1
44101712|Apiladores de buzón de correo|O|O||D||1
44101713|Contadores de copias|O|O||D||1
44101714|Unidades de facsímil para máquinas de oficina|O|O||D||1
44101715|Cubiertas de platinas|O|O||D||1
44101716|Unidades de perforación de orificios|O|O||D||1
44101718|Adaptadores infrarrojos|O|O||D||1
44101719|Accesorios de copiado o escaneado|O|O||D||1
44101720|Fuentes de lenguaje|O|O||D||1|Fuentes de idioma
44101721|Husos de medios|O|O||D||1
44101722|Actualizaciones de energía de buzón de correo multi recipientes|O|O||D||1|Actualizaciones de alimentación de buzones de múltiples compartimientos
44101723|Buzones de correo multi recipientes|O|O||D||1
44101724|Actualizaciones de multi funciones|O|O||D||1|Actualizaciones multifuncionales
44101725|Gabinetes de impresora|O|O||D||1
44101726|Actualizaciones de emulación de impresoras|O|O||D||1
44101727|Puestos para impresoras|O|O||D||1
44101728|Alimentadores de rollos|O|O||D||1
44101729|Apiladores de salida|O|O||D||1
44101730|Clasificador automático de documentos|O|O||D||1
44101800|Máquinas calculadoras y accesorios|O|O||D||1
44101802|Máquinas sumadoras|O|O||D||1|Sumadoras
44101803|Máquinas contabilizadoras|O|O||D||1|Máquinas de contabilidad
44101804|Cajas registradoras|O|O||D||1|Máquinas registradoras
44101805|Cintas para calculadoras|O|O||D||1|Carrete de cinta para calculadora
44101806|Cintas para cajas registradoras|O|O||D||1
44101807|Calculadoras de bolsillo|O|O||D||1
44101808|Calculadoras científicas|O|O||D||1
44101809|Calculadoras de escritorio|O|O||D||1
44101810|Calculadoras impresoras|O|O||D||1
44101900|Máquinas para endosar y escribir cheques|O|O||D||1
44101901|Máquinas de endoso de cheques|O|O||D||1
44101902|Máquinas para escribir cheques|O|O||D||1
44101903|Máquinas de actualización de chequeras o tiqueteras|O|O||D||1
44102000|Suministros para plastificado|O|O||D||1
44102001|Película de laminación|O|O||D||1
44102002|Bolsas de laminadores|O|O||D||1
44102003|Láminas de transferencia|O|O||D||1
44102004|Láminas creativas|O|O||D||1
44102100|Máquinas de correo|O|O||D||1
44102101|Máquinas de franqueo o estampillado|O|O||D||1
44102102|Máquinas para abrir correspondencia|O|O||D||1|Máquinas de apertura de correspondencia
44102103|Máquinas para sellar correspondencia|O|O||D||1
44102104|Máquinas para cancelar estampillas|O|O||D||1
44102105|Máquinas para direcciones|O|O||D||1|Máquinas de direccionamiento
44102106|Dobladores de cartas|O|O||D||1
44102107|Colocadores de estampillas|O|O||D||1
44102108|Accesorios para máquinas de correo|O|O||D||1
44102109|Máquina automática para postales o correspondencia|O|O||D||1
44102200|Accesorios para escáneres|O|O||D||1
44102201|Endosador|O|O||D||1
44102202|Alimentadores de documentos para escáneres|O|O||D||1
44102203|Adaptadores de transparencia para escáneres|O|O||D||1
44102300|Empaquetadoras|O|O||D||1
44102301|Máquinas de agrupación|O|O||D||1
44102302|Máquinas para envolver paquetes|O|O||D||1
44102303|Prensas de sellamiento|O|O||D||1|Prensas de sellado
44102304|Máquinas selladoras|O|O||D||1|Selladoras
44102305|Tensionadores o selladoras para zunchado|O|O||D||1|Tensores o selladores de fleje y cintillo
44102306|Máquinas para amarrar|O|O||D||1|Máquinas para sujetar
44102307|Intercaladores|O|O||D||1
44102400|Etiquetadoras|O|O||D||1
44102402|Máquinas para fechar o numerar|O|O||D||1
44102403|Máquinas de prensa de identificación id|O|O||D||1
44102404|Máquinas para aplicar de etiquetas|O|O||D||1|Máquinas etiquetadoras
44102405|Máquinas para hacer etiquetas|O|O||D||1
44102406|Equipos para rotulado|O|O||D||1
44102407|Grabadora de relieve para cinta|O|O||D||1
44102408|Sistemas de etiquetado automático|O|O||D||1
44102409|Sistemas de etiquetado semiautomáticos|O|O||D||1
44102411|Dispensadores de etiquetas|O|O||D||1
44102412|Cartuchos de etiquetas adhesivas|O|O||D||1
44102413|Kit de sistema de etiquetado de discos versátiles digitales o discos compactos cd/dvd|O|O||D||1
44102414|Estampilla auto abastecedora de tinta|O|O||D||1
44102500|Máquinas clasificadoras|O|O||D||1
44102501|Máquinas contadoras de dinero|O|O||D||1
44102502|Sorteadoras|O|O||D||1
44102503|Máquinas para envolver monedas|O|O||D||1
44102600|Máquinas de escribir y accesorios|O|O||D||1
44102602|Máquinas de escribir|O|O||D||1
44102603|Ruedas de margarita para impresoras|O|O||D||1
44102604|Máquinas de estenotipio|O|O||D||1
44102605|Máquinas para dictado|O|O||D||1
44102606|Cinta de máquinas de escribir|O|O||D||1|Cinta de nylon para máquinas de escribir
44102607|Procesadores de palabras|O|O||D||1
44102608|Elementos de impresión para máquinas de escribir|O|O||D||1|Componentes de impresión para máquinas de escribir, Dispositivos de impresión para máquinas de escribir
44102609|Kits de accesorios o suministros para máquinas de escribir|O|O||D||1
44102610|Kits de inicio para máquinas de escribir|O|O||D||1
44102800|Máquinas encuadernadoras y plastificadoras|O|O||D||1
44102801|Laminadoras|O|O||D||1
44102802|Máquinas de encuadernación térmica|O|O||D||1|Máquinas para empastado térmico, Máquinas para encuadernado térmico
44102803|Máquina de encuadernación en espiral|O|O||D||1|Máquina de encuadernado en espiral
44102804|Máquina de encuadernación de peinilla|O|O||D||1|Máquina de encuadernado de peine
44102805|Máquina perforadora de encuadernación|O|O||D||1|Máquina perforadora para encuadernado
44102806|Máquina de encuadernación de alambre|O|O||D||1|Máquina para encuadernado de alambre
44102900|Accesorios de máquinas de oficina|O|O||D||1
44102901|Kits de viaje para máquinas de oficina|O|O||D||1
44102902|Accesorios de almacenamiento para máquinas de almacenamiento|O|O||D||1|Accesorios de almacenamiento para máquinas de oficina
44102903|Limpiadoras de cinta|O|O||D||1|Limpiadores de cinta
44102904|Aerosol de aire comprimido|O|O||D||1
44102905|Pequeñas bolsas de papel de sales absorbentes húmedas|O|O||D||1
44102906|Kits de limpieza de computadores o equipos de oficina|O|O||D||1|Kits de limpieza de computadoras o equipos de oficina, Kits de limpieza de ordenadores o equipos de oficina
44102907|Forros para equipos para protegerlos del polvo|O|O||D||1|Cubiertas antipolvo para equipos, Fundas antipolvo para equipos
44102908|Limpiadores de discos compactos o removedores de rayones|O|O||D||1
44102909|Limpiadores de unidades de discos compactos|O|O||D||1
44102910|Laminadora|O|O||D||1
44102911|Pañitos limpiadores para máquinas de oficina|O|O||D||1|Paños de limpieza para máquinas de oficina
44102912|Soluciones limpiadoras para equipos de oficina|O|O||D||1|Soluciones de limpieza para equipos de oficina
44102913|Destructor de discos compactos|O|O||D||1
44103000|Fusores y Accesorios|O|O||D||1
44103001|Almohadillas o filtros limpiadores de fusores|O|O||D||1
44103002|Aceite de fusores|O|O||D||1
44103003|Limpiador de fusores|O|O||D||1
44103004|Fusores|O|O||D||1
44103005|Lámparas o ensamblajes de fusores|O|O||D||1
44103100|Suministros para impresora, fax y fotocopiadora|O|O||D||1
44103101|Correas de impresoras, fax o fotocopiadoras|O|O||D||1|Cinturones de impresora o de facsímil o de fotocopiadora
44103103|Tóner para impresoras o fax|O|O||D||1
44103104|Rollos de transferencia|O|O||D||1|Rodillos de transferencia
44103105|Cartuchos de tinta|O|O||D||1
44103106|Barras de tinta|O|O||D||1
44103107|Suministros de limpieza de impresoras o faxes o fotocopiadoras|O|O||D||1
44103108|Reveladores para impresoras o fotocopiadoras|O|O||D||1
44103109|Tambores para impresoras o faxes o fotocopiadoras|O|O||D||1
44103110|Cabezales de impresión|O|O||D||1
44103111|Rollos de tinta|O|O||D||1|Rodillos de tinta
44103112|Cinta de impresora|O|O||D||1
44103113|Kits de correctores de fase o inyección de tinta|O|O||D||1
44103114|Kits de recubrimiento de inyección de tinta|O|O||D||1
44103116|Kit para impresora|O|O||D||1
44103117|Cintas de fax|O|O||D||1
44103118|Película de transparencia|O|O||D||1
44103119|Papel de transferencia en caliente para copiadoras|O|O||D||1|Papel térmico para copiadoras
44103120|Recolectores de tóner|O|O||D||1
44103121|Guías de rollo para impresoras, faxes o fotocopiadoras|O|O||D||1
44103122|Bandas de impresión|O|O||D||1
44103123|Lápices de plotter|O|O||D||1|Plumas para plotter
44103124|Cinta térmica|O|O||D||1
44103125|Kit de mantenimiento de impresoras|O|O||D||1
44103126|Tinta de máquina duplicadora digital|O|O||D||1
44103200|Máquinas y accesorios de registrar la hora para la oficina|O|O||D||1
44103201|Máquina de tarjetas de tiempo|O|O||D||1
44103202|Máquinas estampadoras de tiempo|O|O||D||1
44103203|Cinta de repuesto para máquinas de tarjetas de tiempo|O|O||D||1|Cinta de reemplazo de máquina de tarjeta de tiempo
44103204|Estantes para tarjetas de tiempo|O|O||D||1
44103205|Tarjetas u hojas de tiempo|O|O||D||1
44103206|Máquina de huellas para control de tiempo y de acceso|O|O||D||1|Biométrico para control de tiempo y acceso
44103500|Suministros de máquinas de encuadernar|O|O||D||1
44103502|Tapas de encuadernación|O|O||D||1|Cubiertas de encuadernación, Pastas de encuadernación
44103503|Lomos o cierres de encuadernación|O|O||D||1|Encuadernación de espinas o broches
44103504|Alambres o espirales de encuadernación|O|O||D||1|Bobinas de encuadernación o bucles de alambre
44103505|Peinillas o tiras de encuadernación|O|O||D||1|Peines o tiras de encuadernación
44103506|Cinta de encuadernación|O|O||D||1|Cinta adhesiva para encuadernación
44103507|Kits de encuadernación|O|O||D||1
44103508|Punzones de tinta de encuadernación|O|O||D||1
44103600|Equipo de eliminación de casetes y accesorios|O|O||D||1
44103601|Trituradores de casetes o cintas|O|O||D||1
44111500|Agendas y accesorios|O|O||D||1
44111501|Sujetadores o dispensadores de mensajes|O|O||D||1
44111502|Organizadores de cajones de escritorio|O|O||D||1
44111503|Organizadores o bandejas para el escritorio|O|O||D||1
44111506|Sujetadores o dispensadores de papeles o tacos|O|O||D||1
44111507|Sujeta libros|O|O||D||1
44111509|Sujetadores de esferos o lápices|O|O||D||1
44111510|Organizadores o accesorios de colgar|O|O||D||1
44111511|Sistemas de despliegue o sus accesorios|O|O||D||1
44111512|Estante de literatura|O|O||D||1|Anaquel de literatura, Estantería de literatura, Librer
44111513|Soportes para diarios o calendarios|O|O||D||1
44111514|Estantes u organizadores para estampillas|O|O||D||1|Bastidores de estampillas u organizadores
44111515|Cajas u organizadores de almacenamiento de archivos|O|O||D||1|Caja de almacenamiento de libros, Organizador de expedientes
44111516|Organizadores personales|O|O||D||1|Agendas
44111517|Puestos de estudio|O|O||D||1|Mueble de estudio, Mueble de trabajo, Puesto de trabaj
44111518|Sujetadores de tarjetas de presentación|O|O||D||1|Tarjetero
44111519|Repisas de distribución de documentos|O|O||D||1
44111520|Almohadillas o protectores de superficie|O|O||D||1
44111521|Sujetadores de copias|O|O||D||1|Broche sujetador de archivo, Clip, Clip sujetador de papel tipo maripos
44111522|Sujetadores de libros|O|O||D||1
44111600|Suministros para el manejo de efectivo|O|O||D||1
44111601|Bolsas para billetes o billeteras|O|O||D||1
44111603|Sorteadores de monedas|O|O||D||1|Contador de monedas
44111604|Envoltorios para monedas o cintas para billetes|O|O||D||1
44111605|Cajas para efectivo o tiquetes|O|O||D||1|Cajas para efectivo o Maquinas registradoras
44111606|Bandejas de cajas de efectivo|O|O||D||1
44111607|Archivos de cheques|O|O||D||1|Chequera
44111608|Bancos de monedas|O|O||D||1
44111609|Detectores de billetes falsos o suministros|O|O||D||1
44111610|Bandejas de monedas|O|O||D||1
44111611|Clips para billetes|O|O||D||1|Pinza para billetes
44111612|Sellos para bolsas de monedas|O|O||D||1|Tira plástica para bolsa de monedas
44111613|Sujetadores de tarjetas de crédito|O|O||D||1|Pinzas para sujetar tarjetas de crédito
44111614|Estantes de correas de billetes|O|O||D||1
44111615|Bolsas de depósito|O|O||D||1
44111616|Separadores de cheques|O|O||D||1
44111617|Máquinas de inspección de monedas|O|O||D||1
44111618|Tarjetas de teléfono público o tarjetas de teléfono|O|O||D||1
44111800|Suministros de dibujo|O|O||D||1
44111801|Ayudas para esténciles o textos|O|O||D||1
44111802|Película de dibujo|O|O||D||1|Acetato para dibujo
44111803|Compases|O|O||D||1|Compás
44111804|Papeles de dibujo|O|O||D||1
44111805|Curvas|O|O||D||1|Curvas para dibujo
44111806|Transportadores|O|O||D||1
44111807|Escalas|O|O||D||1|Escalímetro
44111808|Reglas t|O|O||D||1
44111809|Plantillas|O|O||D||1
44111810|Triángulos|O|O||D||1
44111812|Kits o sets de dibujo|O|O||D||1
44111813|Puntos o cintas de dibujo|O|O||D||1
44111814|Forros de protección para superficies de trabajo|O|O||D||1
44111815|Forros para mesas de dibujo|O|O||D||1
44111816|Máquina de dibujo multiplexora|O|O||D||1
44111817|Divisor de dibujo|O|O||D||1
44111818|Eidógrafo|O|O||D||1|Pantógrafo
44111900|Tableros|O|O||D||1
44111901|Tableros de planeación o accesorios|O|O||D||1
44111902|Tableros electrónicos de copia o accesorios|O|O||D||1
44111903|Caballetes o accesorios|O|O||D||1
44111904|Tableros de cartas o accesorios|O|O||D||1
44111905|Tableros de borrado en seco o accesorios|O|O||D||1
44111906|Tableros de tiza o accesorios|O|O||D||1|Pizarrón de gis
44111907|Tableros de noticias o accesorios|O|O||D||1
44111908|Tableros magnéticos o accesorios|O|O||D||1
44111909|Kits o accesorios para limpieza de tableros|O|O||D||1
44111910|Rieles o sujetadores para colgar tableros|O|O||D||1
44111911|Tableros blancos interactivos o accesorios|O|O||D||1|Pizarrones blancos interactivos o accesorios
44111912|Borradores para tableros blancos|O|O||D||1|Borradores para pizarrones blancos
44111913|Borradores de pila para tableros blancos|O|O||D||1|Borradores de pila para pizarrones blancos
44111914|Tabla de soporte para escribir|O|O||D||1
44112000|Sistemas de planificación|O|O||D||1
44112001|Libretas de direcciones o repuestos|O|O||D||1|Directorio
44112002|Calendarios|O|O||D||1|Almanaque
44112004|Planeadores de reuniones|O|O||D||1
44112005|Libretas de citas o repuestos|O|O||D||1
44112006|Diarios o repuestos|O|O||D||1
44112007|Cajas de sugerencias|O|O||D||1
44112008|Planeadores de pared o repuestos|O|O||D||1
44121500|Suministros de correo|O|O||D||1
44121501|Tubos de sobres|O|O||D||1|Tubos de envío
44121503|Sobres|O|O||D||1
44121504|Sobres de ventana|O|O||D||1
44121505|Sobres especiales|O|O||D||1
44121506|Sobres estándar|O|O||D||1
44121507|Sobres de catálogos o de gancho|O|O||D||1
44121508|Repositorios para mensajes|O|O||D||1
44121509|Bolsas para correo|O|O||D||1
44121510|Sellos para correo|O|O||D||1
44121511|Cajas para correo|O|O||D||1
44121512|Tapas de tubos para correo|O|O||D||1
44121513|Estampillas postales|O|O||D||1
44121600|Suministros de escritorio|O|O||D||1|Artículos de papelería
44121604|Estampillas|O|O||D||1
44121605|Dispensadores de cinta|O|O||D||1
44121611|Punzones para papel u ojales|O|O||D||1|Perforadoras
44121612|Cortadoras de papel o repuestos|O|O||D||1
44121613|Removedores de grapas (saca ganchos)|O|O||D||1|Quita grapas
44121614|Campanas de llamada|O|O||D||1|Timbre de llamada
44121615|Grapadoras|O|O||D||1|Engrapadoras
44121617|Abridor manual de cartas|O|O||D||1|Abrecartas
44121618|Tijeras|O|O||D||1
44121619|Tajalápices manuales|O|O||D||1|Sacapuntas
44121620|Protector de plástico para dedos|O|O||D||1|Dedal de plástico
44121621|Almohadillas para escritorio o sus accesorios|O|O||D||1
44121622|Humidificadores|O|O||D||1|Cera de dedos para contar
44121623|Abridor de cartas mecánico|O|O||D||1|Abrecartas mecánico
44121624|Herramientas de grabado en relieve|O|O||D||1|Puntas de grabado
44121625|Pisa papeles|O|O||D||1
44121626|Removedor de adhesivo|O|O||D||1
44121627|Marcadores de libros|O|O||D||1|Separadores para libros
44121628|Contenedores o dispensadores de clips|O|O||D||1
44121630|Kit de cosedora|O|O||D||1|Juego de repuestos para engrapadoras
44121631|Dispensadores de goma o repuestos|O|O||D||1|Dispensadores de rollos adhesivos y repuestos
44121632|Afilador de tijeras|O|O||D||1
44121633|Dispensadores de estampillas postales|O|O||D||1
44121634|Rollos adhesivos|O|O||D||1
44121635|Husos para cinta adhesiva|O|O||D||1|Carrete para cinta adhesiva
44121636|Tajalápices eléctricos|O|O||D||1|Sacapuntas eléctrico
44121700|Instrumentos de escritura|O|O||D||1|Artículos de papelería
44121701|Bolígrafos|O|O||D||1
44121702|Sets de esferos o lápices|O|O||D||1|Sets de bolígrafos o lápices
44121703|Estilógrafos|O|O||D||1
44121704|Esferos de punta redonda|O|O||D||1|Bolígrafos de punta redonda
44121705|Lápices mecánicos|O|O||D||1|Lapiceros
44121706|Lápices de madera|O|O||D||1
44121707|Lápices de colores|O|O||D||1
44121708|Marcadores|O|O||D||1
44121709|Crayolas|O|O||D||1
44121710|Tiza para escribir o accesorios|O|O||D||1|Gis para escribir o accesorios
44121711|Rotuladores|O|O||D||1|Plumines
44121712|Repuestos de marcadores|O|O||D||1
44121713|Plumas de estilógrafos|O|O||D||1
44121714|Asideras para lápices o esferos|O|O||D||1|Goma ergonómica para lápices
44121715|Combinaciones de esfero y lápiz|O|O||D||1|Bolígrafo multifunción con lápiz
44121716|Resaltadores|O|O||D||1|Marcatextos
44121717|Combinación de esfero y resaltador|O|O||D||1|Bolígrafo multifunción con marcatextos
44121718|Sets de esferos asegurados|O|O||D||1|Estuche de bolígrafos giratorios
44121719|Estilógrafos desechables|O|O||D||1
44121720|Esferos multi función|O|O||D||1|Bolígrafos multifunción
44121721|Esfero de tinta borrable|O|O||D||1|Bolígrafo de tinta borrable
44121800|Medios de corrección|O|O||D||1|Artículos de papelería
44121801|Película o cinta de corrección|O|O||D||1|Corrector de cinta
44121802|Fluido de corrección|O|O||D||1|Corrector líquido
44121804|Borradores|O|O||D||1|Goma para borrar
44121805|Esferos de corrección|O|O||D||1|Lápiz corrector
44121806|Repuestos para esferos de corrección|O|O||D||1|Repuestos para lápiz corrector
44121807|Repuestos para borradores|O|O||D||1
44121808|Borradores eléctricos|O|O||D||1|Borrador eléctrico
44121809|Sujeta borrador|O|O||D||1|Borrador mecánico
44121900|Repuestos de tinta y minas de lápices|O|O||D||1|Artículos de papelería
44121902|Repuestos de minas|O|O||D||1|Puntillas de grafito
44121904|Repuestos de tinta|O|O||D||1
44121905|Almohadillas de tinta o estampillas|O|O||D||1
44121906|Cartuchos para rotuladores|O|O||D||1
44121907|Repuestos de tinta para estilógrafos|O|O||D||1
44121908|Repuestos de tinta para bolígrafos|O|O||D||1
44122000|Carpetas de archivo, carpetas y separadores|O|O||D||1|Artículos de papelería
44122001|Archivos para tarjetas de índex|O|O||D||1|Carpetas para archivos con índice
44122002|Protectores de hojas|O|O||D||1
44122003|Carpetas|O|O||D||1
44122005|Cubiertas para revistas o libros|O|O||D||1
44122008|Índices de fichas|O|O||D||1
44122009|Archivos para tarjetas rotativas o de presentación|O|O||D||1
44122010|Separadores|O|O||D||1|Separadores de hojas
44122011|Folders|O|O||D||1
44122012|Portapapeles|O|O||D||1
44122013|Cubiertas para informes|O|O||D||1
44122014|Levantadores de hojas|O|O||D||1
44122015|Respaldos para archivos|O|O||D||1
44122016|Sujetador de documentos|O|O||D||1|Tabla sujetadora de documentos
44122017|Folders de colgar o accesorios|O|O||D||1|Bastidor para carpetas colgantes de archivo
44122018|Insertos o pestañas para archivos|O|O||D||1
44122019|Bolsillos para archivos o accesorios|O|O||D||1|Protector de hojas para carpeta
44122020|Bolsillos para tarjetas|O|O||D||1|Protector de tarjetas
44122021|Álbumes de estampillas|O|O||D||1
44122022|Accesorios de carpetas de folders|O|O||D||1
44122023|Tabletas gráficas para arquitectura|O|O||D||1
44122024|Manijas de carpetas|O|O||D||1
44122025|Bolsillos de carpetas o accesorios|O|O||D||1
44122026|Garras para papel|O|O||D||1
44122027|Folders de archivo expandibles|O|O||D||1
44122028|Canales para montar carpetas|O|O||D||1
44122029|Folders de clasificación|O|O||D||1
44122030|Kit de folders|O|O||D||1|Paquete de folders
44122031|Marco de rieles laterales para colgar folders|O|O||D||1
44122032|Folders de conferencias|O|O||D||1
44122033|Archivo de acordeón para folders|O|O||D||1
44122034|Separador de páginas de libros|O|O||D||1|Separadores de libros
44122100|Suministros de sujeción|O|O||D||1|Artículos de papelería
44122101|Cauchos|O|O||D||1|Ligas
44122103|Sujetadores de cierre|O|O||D||1
44122104|Clips para papel|O|O||D||1
44122105|Clips para carpetas o bulldog|O|O||D||1|Broches para hojas perforadas
44122106|Alfileres o taches|O|O||D||1
44122107|Grapas|O|O||D||1
44122109|Sujetador de aro y bucle|O|O||D||1
44122110|Monturas adhesivas|O|O||D||1
44122111|Refuerzos para orificios|O|O||D||1|Refuerzos adhesivos
44122112|Sujetadores de cabeza redonda|O|O||D||1
44122113|Sujetadores de etiquetas|O|O||D||1
44122114|Postes roscados|O|O||D||1
44122115|Esquinas adhesivas|O|O||D||1
44122116|Clips de bolsas|O|O||D||1
44122117|Anillos para libros|O|O||D||1
44122118|Sujetadores de pinza|O|O||D||1
44122119|Sujetadores auto adhesivos|O|O||D||1
44122120|Postes de carpetas|O|O||D||1
44122121|Clips de pared o tablero|O|O||D||1
44122122|Tachuelas magnéticas|O|O||D||1
45101500|Maquinaria y equipo de imprenta|O|O||D||1
45101501|Impresoras heliográficas|O|O||D||1
45101502|Prensas de impresión de offset|O|O||D||1
45101503|Equipos de impresión tipográfica|O|O||D||1
45101504|Equipos litográficos|O|O||D||1
45101505|Máquinas impresoras de fotograbados|O|O||D||1
45101506|Máquinas de serigrafía|O|O||D||1
45101507|Prensas impresoras|O|O||D||1
45101508|Máquinas perforadoras|O|O||D||1
45101509|Impresora rotativa ultravioleta uv|O|O||D||1
45101510|Impresora flexo gráfica|O|O||D||1
45101511|Impresora de inyección de tinta para aplicaciones de impresión comercial|O|O||D||1
45101512|Impresora de transferencia térmica para aplicaciones de impresión comercial|O|O||D||1
45101513|Impresora de estampado en caliente|O|O||D||1
45101514|Impresora de almohadillas|O|O||D||1
45101515|Impresora básica|O|O||D||1
45101516|Clichés de impresión de almohadillas|O|O||D||1
45101517|Prensa de pruebas de offset|O|O||D||1
45101518|Prensa de platinas de impresión|O|O||D||1
45101600|Accesorios para máquinas de imprenta|O|O||D||1
45101602|Equipos de cuarto oscuro de offset|O|O||D||1
45101603|Consumibles de impresión de offset|O|O||D||1
45101604|Procesadores de platinas de impresión de offset|O|O||D||1
45101606|Procesadores de película de offset|O|O||D||1
45101607|Lámparas de arco de serigrafía|O|O||D||1
45101608|Pantallas de serigrafía|O|O||D||1
45101609|Bastidores de impresión de serigrafía|O|O||D||1
45101610|Armazones de impresión al vacío de serigrafía|O|O||D||1
45101611|Escobillas de serigrafía|O|O||D||1
45101612|Plecas (cuchillas doctor)|O|O||D||1
45101700|Accesorios de imprenta|O|O||D||1
45101701|Ensambladoras de impresión|O|O||D||1
45101702|Guillotinas de impresión|O|O||D||1
45101703|Intercaladores o desintercaladores de impresión|O|O||D||1
45101704|Cortadoras de impresión|O|O||D||1
45101705|Bordeadoras de impresión|O|O||D||1
45101706|Punzones de impresión|O|O||D||1
45101707|Platinas de impresión|O|O||D||1
45101708|Leznas de impresión|O|O||D||1
45101709|Película de impresión|O|O||D||1
45101800|Equipo y accesorios para el cosido y encuadernación de libros|O|O||D||1
45101801|Máquinas para arrugas de los libros|O|O||D||1
45101802|Máquinas cortadoras de libros|O|O||D||1
45101803|Máquinas perforadoras de libros|O|O||D||1
45101804|Máquinas cosedoras de libros|O|O||D||1
45101805|Máquinas de emparejamiento de libros|O|O||D||1
45101806|Máquinas recogedoras de libros|O|O||D||1
45101807|Máquinas dobladoras de libros|O|O||D||1
45101808|Máquinas de encuadernado térmico de libros|O|O||D||1
45101900|Equipo y accesorios de laboratorio de imprenta|O|O||D||1
45101901|Máquinas de anillado de libros|O|O||D||1
45101902|Clisadores|O|O||D||1
45101903|Máquinas de perforación de papel|O|O||D||1
45101904|Alargadores|O|O||D||1
45101905|Tableros de dibujo o retoque|O|O||D||1
45102000|Máquinas y accesorios de composición|O|O||D||1
45102001|Máquinas de composición de intertipos|O|O||D||1
45102002|Máquinas de composición de linotipos|O|O||D||1
45102003|Materiales de fotocomposición|O|O||D||1
45102004|Máquinas de composición de monotipos|O|O||D||1
45102005|Máquinas de configuración de fototipos|O|O||D||1
45111500|Atriles, sistemas de sonido y accesorios|O|O||D||1
45111501|Atriles autónomos|O|O||D||1
45111502|Atriles de mesa|O|O||D||1
45111503|Mazos o bloques de sonido|O|O||D||1
45111504|Componentes de luz o energía o datos para atriles|O|O||D||1
45111600|Proyectores y suministros|O|O||D||1
45111601|Señaladores|O|O||D||1|Señalador laser y punteros
45111602|Lámparas de proyección|O|O||D||1
45111603|Pantallas o desplegadores para proyección|O|O||D||1
45111604|Proyectores de filminas|O|O||D||1
45111605|Equipos de transparencias o suministros|O|O||D||1
45111606|Paneles de proyección de despliegue de cristal líquido|O|O||D||1
45111607|Proyectores de techo|O|O||D||1
45111608|Proyectores de películas|O|O||D||1
45111609|Proyectores multimedia|O|O||D||1
45111610|Epidiascopios|O|O||D||1|Proyector de opacos
45111612|Controles de disolución|O|O||D||1
45111613|Proyectores de tubo de rayo catódico|O|O||D||1
45111614|Proyectores de despliegue de cristal líquido|O|O||D||1
45111615|Lentes de proyección|O|O||D||1
45111616|Proyectores de video|O|O||D||1
45111617|Proyector de techo o carritos de video|O|O||D||1
45111618|Cajas de luces de presentaciones|O|O||D||1
45111619|Bobina para películas|O|O||D||1
45111620|Copiadora de películas de filminas|O|O||D||1|Copiadora de diapositivas y negativos fotográficos
45111700|Equipo de composición y presentación de sonido, hardware y controladores|O|O||D||1
45111701|Dispositivos de audición asistida|O|O||D||1
45111702|Cajas de conectores de audio|O|O||D||1
45111703|Centros de escucha|O|O||D||1|Estéreo modular
45111704|Consolas de mezclado de audio|O|O||D||1
45111705|Sistemas de comunicación pública|O|O||D||1
45111706|Combinación de mezclador y amplificador de audio|O|O||D||1|Mezclador y amplificador
45111707|Conector y caja de escenario de equipo de audio|O|O||D||1|Cajas de conexión para empotrar en escenarios
45111708|Controlador de dominio de transmisión|O|O||D||1
45111709|Amplificador remoto|O|O||D||1
45111710|Unidad de timbre y sirena|O|O||D||1
45111711|Deflector (bafle) de micrófono|O|O||D||1
45111712|Duplicador de cintas|O|O||D||1|Duplicadores de casete
45111713|Amplificador de distribución de audio|O|O||D||1
45111714|Convertidor de audio de análogo a digital ad|O|O||D||1
45111715|Convertidor de audio de digital a análogo da|O|O||D||1
45111716|Estación de audio digital daw|O|O||D||1
45111717|Reverberador|O|O||D||1
45111718|Unidad de retardo|O|O||D||1
45111719|Monitor de audio|O|O||D||1
45111720|Analizador de espectro de audio|O|O||D||1
45111721|Grabadora de cintas bobina a bobina|O|O||D||1
45111722|Lector de casetes|O|O||D||1
45111723|Grabadora de discos duros|O|O||D||1
45111724|Cabezas magnéticas|O|O||D||1
45111800|Equipo de presentación de vídeo y de mezcla de vídeo y sonido, hardware y controladores|O|O||D||1
45111801|Sistemas de control de medios|O|O||D||1
45111802|Soportes para televisiones|O|O||D||1
45111803|Convertidores de barrido (scan)|O|O||D||1
45111804|Duplicadores de línea|O|O||D||1
45111805|Editores de video|O|O||D||1
45111806|Sistemas de aprendizaje a distancia|O|O||D||1
45111807|Interfaces|O|O||D||1
45111808|Controles de iluminación|O|O||D||1
45111809|Accesorios de soporte de televisiones|O|O||D||1
45111810|Presentadores visuales|O|O||D||1
45111811|Monitor de precisión de video|O|O||D||1
45111812|Dispositivo de despliegue de información visual|O|O||D||1
45111813|Operador de introducción de datos corriente abajo|O|O||D||1
45111814|Equipo de efectos de video digital dve|O|O||D||1
45111815|Consola de audio video|O|O||D||1
45111816|Generador de logos|O|O||D||1
45111817|Generador de caracteres|O|O||D||1
45111818|Reducidor de ruido de videos|O|O||D||1
45111819|Mezclador de videos|O|O||D||1
45111820|Amplificador de procesamiento de videos|O|O||D||1
45111821|Generador de sincronización|O|O||D||1
45111822|Convertidor de tasa de aspecto de televisión|O|O||D||1
45111823|Convertidor de estándares de video|O|O||D||1
45111824|Convertidor de sincronización|O|O||D||1
45111825|Sincronizador de marco|O|O||D||1
45111826|Codificador de grupo de expertos de películas animadas mpeg|O|O||D||1
45111827|Verificador de video cintas|O|O||D||1
45111828|Indicador (prompter)|O|O||D||1
45111829|Cámara de proceso|O|O||D||1
45111900|Equipos, hardware y controladores para sistemas de teleconferencia y videoconferencia|O|O||D||1
45111901|Sistemas de audio conferencias|O|O||D||1
45111902|Sistemas de video conferencias|O|O||D||1
45112000|Equipo y suministros de microfilm|O|O||D||1
45112001|Dispositivos para ver micro fichas o micro cintas|O|O||D||1
45112002|Impresoras lectoras de micro fichas|O|O||D||1
45112003|Componentes o accesorios de micro fichas o micro cintas|O|O||D||1
45112004|Componentes o accesorios de impresoras lectoras de micro fichas|O|O||D||1
45121500|Cámaras|O|O||D||1
45121501|Cámaras fijas|O|O||D||1
45121502|Cámaras de impresión instantánea|O|O||D||1
45121503|Cámaras desechables|O|O||D||1
45121504|Cámaras digitales|O|O||D||1
45121505|Cámaras cinematográficas|O|O||D||1
45121506|Cámaras de video conferencia|O|O||D||1
45121510|Cámaras aéreas|O|O||D||1
45121511|Cámaras de alta velocidad|O|O||D||1
45121512|Cámaras para debajo del agua|O|O||D||1
45121513|Cámaras de offset|O|O||D||1
45121514|Cámara fotocopiadora|O|O||D||1
45121515|Cámaras grabadoras o video cámaras manuales|O|O||D||1
45121516|Cámaras grabadoras o video cámaras digitales|O|O||D||1
45121517|Cámaras para documentos|O|O||D||1
45121518|Kits de cámaras|O|O||D||1
45121519|Cámaras de baja luz|O|O||D||1
45121520|Cámaras de web|O|O||D||1
45121521|Cámaras de inspección|O|O||D||1
45121522|Cámaras infrarrojas|O|O||D||1
45121523|Cámaras astronómicas|O|O||D||1
45121600|Accesorios para cámaras|O|O||D||1
45121601|Flashes o iluminación para cámaras|O|O||D||1
45121602|Trípodes para cámaras|O|O||D||1|Tripiés para cámara
45121603|Lentes para cámaras|O|O||D||1
45121604|Oclusores para cámaras|O|O||D||1
45121605|Marcos de pantalla|O|O||D||1
45121606|Arneses para cámaras|O|O||D||1
45121607|Bloques o sujetadores para cámaras|O|O||D||1
45121608|Ensamblajes para cámaras|O|O||D||1
45121609|Abrazaderas para cámaras|O|O||D||1
45121610|Cables para cámaras|O|O||D||1
45121611|Cubiertas para lentes|O|O||D||1
45121612|Mesas para cámaras|O|O||D||1
45121613|Contenedores o forros para cámaras|O|O||D||1|Estuches para cámaras, Fundas para cámaras
45121614|Kits de reacondicionamiento|O|O||D||1
45121615|Anillos para cámaras|O|O||D||1
45121616|Cabezales panorámicos|O|O||D||1
45121617|Bolsas para cámaras|O|O||D||1|Estuche para cámaras, Mochilas para cámaras
45121618|Adaptadores de lentes para cámaras|O|O||D||1
45121619|Billeteras para “picture card”|O|O||D||1
45121620|Adaptadores de electricidad para cámaras|O|O||D||1
45121621|Adaptadores para “picture card”|O|O||D||1
45121622|Limpiadores para lentes de cámara|O|O||D||1
45121623|Controladores de cámara|O|O||D||1
45121624|Reflector de luz para fotografía|O|O||D||1
45121625|Disparador|O|O||D||1
45121626|Respaldo de cámara digital (dispositivo que permite editar e imprimir)|O|O||D||1
45121627|Difusor de flash de cámara|O|O||D||1
45121628|Filtro de lente de cámara|O|O||D||1
45121629|Motor de arrastre de cámara|O|O||D||1
45121630|Reflector de parasol de cámara|O|O||D||1
45121700|Equipo de procesamiento fotográfico|O|O||D||1
45121701|Secadores de película|O|O||D||1
45121702|Lavadores de película|O|O||D||1
45121703|Cortadores de película|O|O||D||1
45121704|Editores de película|O|O||D||1
45121705|Alargadores fotográficos|O|O||D||1
45121706|Cortadoras o bordeadoras de fotografías|O|O||D||1
45121707|Secadora de impresión de fotografías|O|O||D||1
45121708|Lavadora de impresión de fotografías|O|O||D||1
45121709|Procesador de película automático|O|O||D||1
45121710|Tambor de hojas de película|O|O||D||1
45121711|Controlador de color|O|O||D||1
45121712|Escritorio de edición de película|O|O||D||1
45121713|Máquina de inspección de película|O|O||D||1
45121714|Lector de película|O|O||D||1
45121715|Colgador de película|O|O||D||1
45121716|Impresora de contacto|O|O||D||1
45121717|Sistema de platinas de película|O|O||D||1
45121718|Densitómetro de película|O|O||D||1
45121719|Kiosco de impresión de fotografías digitales|O|O||D||1
45121720|Cargador de película|O|O||D||1
45121800|Equipo y suministros de producción de microfilmes|O|O||D||1
45121801|Cámaras de micro filmado|O|O||D||1
45121802|Duplicadores de micro filmado|O|O||D||1
45121803|Filtros de cubierta de micro filmado|O|O||D||1
45121804|Procesadores de micro filmado|O|O||D||1
45121805|Componentes o accesorios de cámara de micro filmado|O|O||D||1
45121806|Componentes o accesorios de duplicador de micro filmado|O|O||D||1
45121807|Componentes o accesorios de filtro de cubierta de micro filmado|O|O||D||1
45121808|Componentes o accesorios de procesadores de micro filmado|O|O||D||1
45121809|Suministros de película de micro filmado|O|O||D||1
45121810|Componentes o accesorios diversos de micro filmado|O|O||D||1
45131500|Película para cámara fotográfica|O|O||D||1
45131501|Película de color|O|O||D||1
45131502|Película de blanco y negro|O|O||D||1
45131503|Película de fotografía instantánea|O|O||D||1
45131505|Película de rayos x|O|O||D||1
45131506|Película de filminas|O|O||D||1|Película de diapositivas
45131507|Micro filmado procesado|O|O||D||1
45131508|Película de negativos|O|O||D||1
45131509|Película reconocedora de color|O|O||D||1
45131510|Tinte fotográfico|O|O||D||1
45131600|Medios cinematográficos|O|O||D||1
45131601|Película de cámara de películas animadas|O|O||D||1
45131604|Cintas de video en blanco|O|O||D||1
45131700|Almacenamiento para soportes audiovisuales|O|O||D||1
45131701|Bandejas u organizadores para filminas|O|O||D||1|Organizador de diapositivas
45141500|Productos químicos para elaboración fotográfica|O|O||D||1
45141501|Solución reveladora|O|O||D||1
45141502|Fijadores|O|O||D||1|Solución fijadora para fotografías
45141503|Kit de procesamiento de revelado de fotografías|O|O||D||1
45141504|Solución de optimización y corrección de fotografías|O|O||D||1
45141600|Suministros de cuarto oscuro|O|O||D||1
45141601|Bandejas de revelado|O|O||D||1
45141602|Tanques de revelado|O|O||D||1
45141603|Pinzas de revelado|O|O||D||1
45141604|Procesador de impresión fotográfica|O|O||D||1
45141605|Purificador de fotografías|O|O||D||1
45141606|Bobina de tanque de revelado|O|O||D||1
45141607|Cámara oscura|O|O||D||1
45141608|Escurridor de película|O|O||D||1
45141609|Mesa de trabajo de máquina reveladora de película|O|O||D||1
45141610|Temporizador fotográfico|O|O||D||1
45141611|Regulador de temperatura para procesamiento fotográfico|O|O||D||1
45141612|Cuarto oscuro portátil|O|O||D||1
46101500|Armas de fuego|O|O||D||1
46101501|Ametralladoras|O|O||D||1|Escopeta, Metralleta, Subfusi
46101502|Escopetas para la policía p seguridad|O|O||D||1|Fusil
46101503|Rifles militares|O|O||D||1
46101504|Pistolas|O|O||D||1
46101505|Rifles de aire o pistolas de aire|O|O||D||1|Rifles de municiones, Rifles de salva
46101506|Partes de revólveres o pistolas|O|O||D||1
46101600|Munición|O|O||D||1
46101601|Municiones de defensa u orden público|O|O||D||1|Armamentos, Balas
46101700|Sistemas de manipulación de munición|O|O||D||1
46101701|Sistemas de manipulación de municiones de tanque|O|O||D||1|Sistemas de manejo de balas de tanque, Sistemas de manejo de municiones de tanque
46101702|Sistemas de manipulación de municiones de aeronaves|O|O||D||1|Sistemas de manejo de armamento de aeronaves
46101703|Contenedor de explosivos|O|O||D||1
46101800|Accesorios de armas y municiones|O|O||D||1
46101801|Estuches para revólveres|O|O||D||1|Estuches para pistolas, Fundas para armas de fuego
46101802|Cinturón para cartuchos|O|O||D||1|Canana para cartuchos, Carrillera para cartuchos
46111700|Sensores de rayos infrarrojos (IR)|O|O||D||1
46111701|Enfriadores infrarrojos ir|O|O||D||1
46111702|Detectores infrarrojos ir|O|O||D||1|Sensores infrarrojos ir
46111703|Iluminadores infrarrojos ir|O|O||D||1
46111704|Receptores infrarrojos ir|O|O||D||1|Recibidores infrarrojos ir
46111705|Telescopios infrarrojos ir|O|O||D||1|Lente infrarrojos ir
46151500|Equipo de control de masas|O|O||D||1
46151501|Barricadas|O|O||D||1|Muros, Parapetos
46151502|Cascos anti motines|O|O||D||1
46151503|Escudos anti motines|O|O||D||1|Protecciones antimotines
46151504|Armadura para el cuerpo|O|O||D||1|Vestidura para el cuerpo
46151505|Barreras|O|O||D||1
46151506|Bastones anti motines|O|O||D||1|Cachavas anti motines, Garrotes anti motines, Macanas anti motine
46151507|Sistema de control de filas|O|O||D||1|Sistema de manejo de filas
46151600|Equipo de seguridad y control|O|O||D||1
46151601|Esposas|O|O||D||1|Ataduras, Grilletes
46151602|Cachiporras|O|O||D||1|Bastones, Garrotes
46151604|Analizadores de alcohol|O|O||D||1|Alcoholímetro, Alcohómetro
46151605|Detectores de armas o explosivos y suministros|O|O||D||1
46151606|Kits de pruebas de narcóticos|O|O||D||1|Kits de pruebas de drogas, Kits de pruebas de sedantes
46151607|Cabos de amarre de seguridad|O|O||D||1|Aparejos de amarre de seguridad, Destorcedores de amarre de seguridad
46151608|Dispositivos de protección contra bombas y suministros|O|O||D||1|Dispositivos y suministros de protección contra bombas
46151609|Discriminador de documentos de identificación|O|O||D||1|Discriminador de tarjeta de identificación
46151700|Equipo forense y accesorios y suministros|O|O||D||1
46151702|Aplicadores o cepillos de huellas dactilares|O|O||D||1
46151703|Tinta de huellas dactilares|O|O||D||1
46151704|Removedores de tinta de huellas dactilares|O|O||D||1
46151705|Rodillos de tinta para huellas dactilares o de palma de la mano|O|O||D||1
46151706|Kit de impresión latente de huellas dactilares|O|O||D||1
46151707|Levantadores de huellas dactilares|O|O||D||1
46151708|Magnificadores para uso forense|O|O||D||1
46151709|Esferos de marcado de huellas dactilares|O|O||D||1|Marcadores de huellas dactilares
46151710|Polvos de huellas dactilares|O|O||D||1
46151711|Levantadores de huellas plantares|O|O||D||1
46151712|Estaciones de trabajo químico para uso forense|O|O||D||1
46151713|Químicos de impresiones latentes para uso forense|O|O||D||1
46151714|Gabinetes de secado de evidencia|O|O||D||1
46151715|Equipo de huellas dactilares|O|O||D||1
46151716|Detector de mentiras|O|O||D||1
46151800|Equipo y accesorios y suministros de control de explosivos|O|O||D||1
46151801|Contenedor de protección de onda expansiva|O|O||D||1|Recipiente de contención de onda expansiva
46151900|Equipo y accesorios y suministros para el control químico biológico|O|O||D||1
46151901|Remolque de descontaminación biológica química|O|O||D||1
46161500|Control de tráfico|O|O||D||1
46161501|Sistemas de señalización para aeropuertos|O|O||D||1|Sistemas de señalización aeroportuaria
46161502|Sistemas de señalización para ferrocarriles|O|O||D||1|Sistemas de señalización ferroviaria
46161503|Sistemas de señalización marinos|O|O||D||1|Sistemas de señalización marítima
46161504|Señales de tráfico|O|O||D||1|Señalamientos de tránsito vehicular
46161505|Medidores de estacionamiento|O|O||D||1|Parquímetros
46161506|Máquinas para derretir nieve o hielo|O|O||D||1
46161507|Cintas o cadenas de barrera|O|O||D||1
46161508|Conos o delineadores de tráfico|O|O||D||1
46161509|Paradas de velocidad|O|O||D||1
46161510|Sistemas de barrera para puertas|O|O||D||1|Métodos de barrera de puertas
46161511|Balizas de tráfico|O|O||D||1|Faro para control de tráfico, Semáforos
46161512|Cadenas de tráfico|O|O||D||1
46161513|Cerca de seguridad de tráfico|O|O||D||1|Barrera de seguridad de tráfico, Malla de seguridad de tráfico
46161514|Montantes de carretera cats eye|O|O||D||1|Montantes ojo de gato
46161515|Amortiguador de choques|O|O||D||1|Cojín de choque, Muro de contención
46161516|Sistema de reconocimiento de placas|O|O||D||1|Sistema de reconocimiento de matrículas
46161517|Riel de división de carriles|O|O||D||1
46161518|Tambor canalizador de control de tráfico|O|O||D||1|Barril de tráfico
46161519|Cinta de carriles de tráfico|O|O||D||1|Cinta de marcado de carril
46161520|Señales de mensaje variable|O|O||D||1
46161521|Luz de advertencia de entrada y salida de estacionamientos|O|O||D||1
46161522|Luz de advertencia de cercanía de estacionamientos|O|O||D||1
46161523|Máquina para derretir nieve en estacionamientos|O|O||D||1|Máquina para fundir nieve en estacionamientos
46161524|Analizador de flujo de tráfico|O|O||D||1
46161525|Cable de bucle para detección de vehículos|O|O||D||1|Bobina de detección de vehículos
46161526|Sensor de peatones|O|O||D||1
46161527|Sensor de flujo de tráfico|O|O||D||1
46161528|Luz de advertencia para aeropuertos|O|O||D||1
46161529|Dispositivo de guía de voz para personas invidentes|O|O||D||1
46161530|Puerta de barrera de estacionamiento|O|O||D||1|Barrera de estacionamiento
46161531|Espejo de seguridad de tráfico|O|O||D||1
46161600|Seguridad del Agua|O|O||D||1
46161601|Líneas de flotadores|O|O||D||1|Líneas de flotación de cuerda
46161602|Salvavidas|O|O||D||1|Boya de vida, Flotadores
46161603|Alarmas de piscina|O|O||D||1
46161604|Chalecos o protectores salvavidas|O|O||D||1|Chalecos salvavidas
46161605|Boya salvavidas|O|O||D||1
46161700|Equipo y accesorios de rescate|O|O||D||1
46161701|Línea salvavidas descendente|O|O||D||1
46161702|Bolsa de aire de rescate|O|O||D||1
46161703|Esterilla aérea de seguridad|O|O||D||1|Colchón neumático de rescate
46161704|Lanzador de línea de rescate|O|O||D||1
46161705|Set de equipos hidráulicos de rescate|O|O||D||1|Equipo de rescate hidráulico
46161706|Tienda de aire|O|O||D||1
46161707|Abridor de puertas de rescate|O|O||D||1
46161708|Red de rescate|O|O||D||1|Malla de rescate
46161710|Luz de rescate|O|O||D||1
46161711|Detector de vida|O|O||D||1
46161712|Alerta de seguridad personal|O|O||D||1
46161713|Dispositivo de señales de humo|O|O||D||1|Aparato de señales de humo
46161714|Línea salvavidas|O|O||D||1
46161715|Equipo de rescate en espacios confinados|O|O||D||1
46171500|Cerraduras, elementos de seguridad y accesorios|O|O||D||1
46171501|Candados|O|O||D||1
46171502|Candados de cable|O|O||D||1
46171503|Sets de candados|O|O||D||1|Juegos de candados
46171504|Candados de botón para oprimir|O|O||D||1|Cerraduras electrónicas
46171505|Llaves|O|O||D||1
46171506|Cajas fuertes|O|O||D||1
46171507|Barras de seguridad|O|O||D||1
46171508|Candados de números|O|O||D||1|Candados de combinación
46171509|Gabinetes u organizadores con llave|O|O||D||1|Armarios y organizadores con llave
46171510|Candados de tiempo|O|O||D||1
46171511|Dispositivos de bloqueo|O|O||D||1|Aparatos de bloqueo
46171512|Candados de instrumentos|O|O||D||1|Cerraduras de instrumentos
46171513|Levas de bloqueo|O|O||D||1
46171514|Cadenas de seguridad o accesorios|O|O||D||1|Cadenas o accesorios de seguridad
46171515|Cadenas de llaves o estuches de llaves|O|O||D||1|Llaveros o estuches para llaves
46171516|Guardas para puertas|O|O||D||1|Protectores de puertas
46171517|Señales de chapa|O|O||D||1
46171518|Placa de impacto eléctrica|O|O||D||1|Placa eléctrica
46171519|Accesorio cilíndrico para candados|O|O||D||1
46171520|Candados eléctricos|O|O||D||1
46171521|Placa de impacto no eléctrica|O|O||D||1
46171522|Cerramientos para candados|O|O||D||1|Caja de cerradura
46171523|Sistema de bloqueo mecánico|O|O||D||1
46171524|Candado de llave de tarjeta|O|O||D||1|Cerradura con tarjeta
46171600|Equipo de vigilancia y detección|O|O||D||1
46171602|Alarmas de seguridad|O|O||D||1
46171603|Temporizadores de reloj|O|O||D||1
46171604|Sistemas de alarma|O|O||D||1|Sistemas de seguridad
46171605|Timbres de puerta|O|O||D||1
46171606|Sirenas|O|O||D||1|Alarmas
46171607|Timbres de zumbido|O|O||D||1
46171608|Detectores de movimiento|O|O||D||1|Sensores de movimiento
46171609|Espejos convexos de seguridad|O|O||D||1
46171610|Cámaras de seguridad|O|O||D||1|Videocámaras de seguridad
46171611|Sistemas de identificación de video|O|O||D||1|Dispositivos de identificación de video
46171612|Monitores de video|O|O||D||1|Pantallas de video
46171613|Detectores de gas|O|O||D||1
46171615|Cámaras de optimización de luz o dispositivos de visión|O|O||D||1|Cámaras o dispositivos de visión que mejoran la luz
46171616|Detectores de radar|O|O||D||1
46171617|Ojos (mirillas) para puertas|O|O||D||1
46171618|Campanas para puertas|O|O||D||1|Timbres
46171619|Sistemas de seguridad o de control de acceso|O|O||D||1
46171620|Cortinas de luz de seguridad|O|O||D||1
46171621|Grabadoras de video o audio de vigilancia|O|O||D||1|Grabadoras de video o audio de vigilancia
46171622|Sistema de televisión de circuito cerrado cctv|O|O||D||1|Sistema de circuito cerrado de televisión
46171623|Alarma de seguridad para el hogar|O|O||D||1
46171624|Sistema de rayos x para inspección de equipaje|O|O||D||1
46171625|Sistema de monitoreo de comunicaciones por radio|O|O||D||1|Sistema de control de comunicaciones por radio
46171626|Equipo de visión nocturna|O|O||D||1|Gafas de visión nocturna, Lentes de visión nocturna
46171627|Sistema de señalización inalámbrica para sordos|O|O||D||1|Sistema de señalización inalámbrica para personas con impedimentos auditivos
46171628|Indicador automático de la hora|O|O||D||1|Relojes digitales
46171629|Espejo de señales|O|O||D||1
46171630|Sensor de nivel de agua y lluvia para vehículos|O|O||D||1|Detector de nivel de agua y lluvia para vehículos
46171631|Alarma sísmica|O|O||D||1
46171632|Sensor infrarrojo pasivo|O|O||D||1|Detector infrarrojo pasivo
46171633|Detector de metales de seguridad|O|O||D||1
46171634|Papel detector de agentes químicos|O|O||D||1
46171635|Detector de agentes químicos|O|O||D||1
46171636|Equipo de transmisión de facsímil de seguridad|O|O||D||1
46171637|Dispositivo de interceptación electrónica|O|O||D||1|Aparatos de interceptación electrónica
46171638|Detector y alarma de radiación|O|O||D||1
46171639|Video compensador de tráfico|O|O||D||1
46171640|Sistema de monitoreo automático de tráfico|O|O||D||1
46181500|Ropa de seguridad|O|O||D||1
46181501|Delantales protectores|O|O||D||1|Batas de protección, Guardapolvos de protección, Mandiles de protecció
46181502|Chalecos anti balas|O|O||D||1
46181503|Overoles de protección|O|O||D||1|Prenda de uso industrial
46181504|Guantes de protección|O|O||D||1|Guantes protectores
46181505|Rodilleras de protección|O|O||D||1
46181506|Ponchos de protección|O|O||D||1|Impermeables
46181507|Chalecos de seguridad|O|O||D||1|Prendas de seguridad
46181508|Ropa para demorar el fuego|O|O||D||1|Ropa ignífuga o de antifuego
46181509|Ropa de protección contra materiales peligrosos|O|O||D||1
46181512|Ropa para cuartos de limpieza|O|O||D||1|Ropa para la limpieza de habitaciones
46181514|Protectores de codos|O|O||D||1
46181516|Mangas de seguridad|O|O||D||1
46181517|Vestidos de aislamiento o de flotación|O|O||D||1|Trajes aislados o de flotación
46181518|Ropa resistente al calor|O|O||D||1
46181520|Protectores de piernas|O|O||D||1|Protectores para las extremidades
46181522|Capuchas de seguridad|O|O||D||1|Capuchones de seguridad, Gorros de seguridad
46181526|Camisas protectoras|O|O||D||1|Camisas de protección
46181527|Pantalones protectores|O|O||D||1|Pantalones de seguridad
46181528|Vestido protector|O|O||D||1|Traje de protección
46181529|Ropa aislante para entornos fríos|O|O||D||1
46181530|Forros protectores de dedos|O|O||D||1|Dediles de protección
46181531|Ropa reflectora o accesorios|O|O||D||1
46181532|Batas de laboratorio|O|O||D||1|Delantales de laboratorio, Mandiles de laboratorio
46181533|Batas protectoras|O|O||D||1|Delantales de protección, Mandiles de protección
46181534|Muñequeras protectoras|O|O||D||1
46181535|Medias o medias largas protectoras|O|O||D||1|Calcetines o medias de protección
46181536|Guantes anti cortadas|O|O||D||1|Mitones anti cortadas
46181537|Guantes aislantes|O|O||D||1|Mitones aislantes
46181538|Guantes térmicos|O|O||D||1|Mitones térmicos
46181539|Guantes anti vibraciones|O|O||D||1|Mitones anti vibraciones
46181540|Guantes de soldadura|O|O||D||1|Mitones de soldadura
46181541|Guantes resistentes a los químicos|O|O||D||1|Mitones resistentes a los químicos
46181542|Mitones protectores|O|O||D||1|Guantes de protección para deporte
46181543|Chaqueta o gabardina impermeable|O|O||D||1|Chaquetas o impermeables
46181544|Pantalones impermeable|O|O||D||1|Pantalones aislantes
46181545|Vestido impermeable|O|O||D||1|Traje impermeable
46181546|Capa impermeable|O|O||D||1
46181547|Cubiertas de capa impermeables|O|O||D||1
46181548|Delantal de soldadura|O|O||D||1|Bata para soldadura, Mandil para soldadura
46181549|Bufandas|O|O||D||1|Polaina de cuello
46181550|Bufandas protectoras|O|O||D||1|Bandas protectoras
46181551|Chaqueta de malla protectora|O|O||D||1|Chamarra de malla para protección
46181552|Lámpara de cabeza para minería|O|O||D||1|Faro de cabeza para minería, Foco de cabeza para minería, Luz de cabeza para minerí
46181600|Calzado de protección|O|O||D||1
46181601|Calzado para demorar el fuego|O|O||D||1|Calzado ignífugo o antifuego, Calzado para combatir el fuego
46181602|Calzado protector contra materiales peligrosos|O|O||D||1|Calzado protector de materiales peligrosos
46181603|Calzado para cuartos de limpieza|O|O||D||1
46181604|Botas de seguridad|O|O||D||1
46181605|Zapatos de seguridad|O|O||D||1
46181606|Forros para calzado|O|O||D||1|Cubiertas para calzado
46181607|Zuecos protectores|O|O||D||1|Calzado zueco de protección
46181608|Sandalias protectoras|O|O||D||1
46181609|Plantillas protectoras|O|O||D||1|Plantillas de protección
46181610|Zapatos aislados para clima frío|O|O||D||1|Zapato con aislamiento de clima frío
46181611|Botas impermeables|O|O||D||1|Calzado impermeable
46181612|Botas militares|O|O||D||1|Calzado militar
46181613|Botas para escalar montañas|O|O||D||1|Botas de montaña
46181700|Protectores de cara y cabeza|O|O||D||1
46181701|Cascos|O|O||D||1
46181702|Escudos faciales|O|O||D||1|Protectores faciales
46181703|Máscaras de soldadura|O|O||D||1|Máscaras y caretas para soldar
46181704|Cascos de seguridad|O|O||D||1|Cascos industriales
46181705|Cascos para motociclistas|O|O||D||1
46181706|Partes de cascos o accesorios|O|O||D||1|Partes o accesorios para casco
46181707|Partes de escudos faciales o accesorios|O|O||D||1|Partes o accesorios para protectores faciales
46181708|Red protectora para el cabello|O|O||D||1|Malla protectora para el cabello
46181709|Kit de protección facial|O|O||D||1|Accesorios de protección facial
46181710|Capucha protectora|O|O||D||1
46181711|Casco de soldadura|O|O||D||1
46181800|Protección y accesorios para la visión|O|O||D||1
46181801|Sujetadores o estuches de anteojos|O|O||D||1|Fundas para lentes, Soportes o estuches para lentes
46181802|Anteojos de seguridad|O|O||D||1
46181803|Protectores de ojos|O|O||D||1
46181804|Gafas protectoras|O|O||D||1
46181805|Filtros de despliegue de video|O|O||D||1|Filtros de visualización de vídeo
46181806|Limpiadores de lentes|O|O||D||1|Limpiadores de gafas
46181808|Cubiertas protectoras para gafas de seguridad|O|O||D||1|Tapas protectoras para gafas de seguridad
46181809|Ligas para protectores de ojos|O|O||D||1|Ligas para lentes
46181810|Lavadores de ojos o estaciones para lavado de ojos|O|O||D||1
46181811|Lentes protectores|O|O||D||1
46181900|Protectores auditivos|O|O||D||1
46181901|Tapones de oídos|O|O||D||1|Tapones para los oídos
46181902|Tapa oídos|O|O||D||1
46181903|Partes de repuesto o accesorios para tapa oídos|O|O||D||1|Piezas o accesorios de repuesto para tapa oídos
46181904|Dispensador de tapones para oídos|O|O||D||1
46182000|Protección de la respiración|O|O||D||1
46182001|Máscaras o accesorios|O|O||D||1|Caretas o accesorios
46182002|Respiradores|O|O||D||1
46182003|Máscaras de gas|O|O||D||1|Máscaras y caretas antigás
46182004|Aparatos respiratorios auto contenidos que suministran aire para respirar o accesorios|O|O||D||1
46182005|Filtros o accesorios para máscaras o respiradores|O|O||D||1|Filtros o accesorios para caretas o respiradores
46182006|Películas protectoras|O|O||D||1
46182007|Sistema de respirador accionado purificador de aire papr o accesorios|O|O||D||1|Sistema de purificación de aire PAPRs o accesorios
46182100|Equipo y suministros antiestáticos|O|O||D||1
46182101|Muñequeras antiestáticas|O|O||D||1|Brazaletes antiestáticos, Pulseras antiestáticas
46182102|Correas de conexión a tierra para el talón|O|O||D||1|Tirantes de conexión a tierra para el talón
46182103|Hardware de conexión a tierra|O|O||D||1|Abrazadera para barra de cobre
46182104|Esterillas de piso antiestáticas|O|O||D||1|Alfombrillas antiestáticas
46182105|Esterillas de mesa de trabajo antiestáticas|O|O||D||1|Alfombrillas de mesa de trabajo antiestáticas
46182106|Cinturones antiestáticos|O|O||D||1
46182107|Kits de mantenimiento antiestáticos|O|O||D||1
46182108|Correas antiestáticas para los dedos de los pies|O|O||D||1
46182200|Equipo de apoyo ergonómico|O|O||D||1
46182201|Cinturones de soporte de la espalda|O|O||D||1|Ceñidores de soporte para la espalda, Fajas de soporte para la espalda, Pretinas de soporte para la espald
46182202|Soportes para codos|O|O||D||1
46182203|Descansos de soporte para la espalda|O|O||D||1
46182204|Férulas para la muñeca|O|O||D||1
46182205|Descansos para los pies|O|O||D||1|Reposapiés
46182206|Descansos para las muñecas|O|O||D||1|Respaldo de muñeca
46182207|Soportes para las pantorrillas|O|O||D||1|Fajas para las pantorrillas
46182208|Plantillas para zapatos|O|O||D||1|Plantillas de calzado
46182209|Soportes para las rodillas|O|O||D||1|Rodilleras
46182210|Protector o férula para los muslos|O|O||D||1
46182211|Protector lumbar o férula de espalda|O|O||D||1|Protector dorsal o férula de espalda
46182212|Protector o soporte de hombro|O|O||D||1|Protector de hombros
46182213|Almohada cervical|O|O||D||1|Cojín cervical
46182300|Protección anti caída y equipo de rescate|O|O||D||1
46182301|Salvavidas o equipo salvavidas|O|O||D||1|Equipo de salvamento
46182302|Acollador de protección contra caídas|O|O||D||1|Cordón de protección contra caídas
46182303|Rebobinadores de arneses de seguridad|O|O||D||1|Bobinadoras de arnés de seguridad
46182304|Conector de anclaje|O|O||D||1|Dispositivo de anclaje
46182305|Acollador de auto retracción|O|O||D||1|Cordón autoextraíble
46182306|Arneses o cinturones de seguridad|O|O||D||1|Armadura de seguridad o cinturones
46182307|Arneses de evacuación|O|O||D||1
46182308|Agarres para halar|O|O||D||1
46182309|Escaleras de cuerda de seguridad y escaleras de cable de acero|O|O||D||1
46182310|Dispositivos mecánicos para conectar cargas a las cuerdas|O|O||D||1|Adaptadores mecánicos para conectar cargas a las cuerdas
46182311|Dispositivos de detención|O|O||D||1|Adaptadores de detención
46182312|Anillos para disminuir el desgaste de la cuerda|O|O||D||1|Anillos para reducir el deterioro de la cuerda
46182313|Bucle metálico para conectar componentes en sistemas críticos de seguridad|O|O||D||1
46182314|Eslingas de seguridad|O|O||D||1|Cinchas de seguridad
46182315|Barandas de caucho|O|O||D||1|Barandillas de caucho
46182400|Equipo de limpieza de seguridad y materiales de descontaminación|O|O||D||1
46182401|Ducha de descontaminación|O|O||D||1
46182402|Unidades de lavado de seguridad|O|O||D||1
46182403|Cabina de limpieza|O|O||D||1
46182404|Armario (locker) de limpieza|O|O||D||1|Estante de limpieza, Mueble de limpieza, Ropero de limpieza, Vitrina de limpieza ,
46182405|Ducha de aire|O|O||D||1
46182406|Caja de paso de aire|O|O||D||1
46182500|Armas o dispositivos de seguridad personal|O|O||D||1
46182501|Repelentes para ataques caninos|O|O||D||1
46182502|Luz de seguridad personal|O|O||D||1
46182503|Alarma de bajo voltaje|O|O||D||1|Alarma de baja tensión
46182504|Panel de control de alarmas contra incendio|O|O||D||1
46182505|Detector de fuga a tierra y alarma contra incendios|O|O||D||1
46182506|Equipo de protección contra interferencia electromagnética emi|O|O||D||1
46182507|Material de protección contra interferencia electromagnética emi|O|O||D||1
46191500|Prevención contra incendios|O|O||D||1
46191501|Detectores de humo|O|O||D||1
46191502|Detectores de calor|O|O||D||1
46191503|Recubrimientos o plastilinas o sellantes resistentes al calor|O|O||D||1
46191504|Detectores de llama|O|O||D||1
46191505|Sistemas de alarma contra incendios|O|O||D||1
46191506|Extintor de llamas|O|O||D||1|Parallamas
46191507|Sistema pasivo de detención del fuego|O|O||D||1
46191508|Sistema de monitoreo de cinturón|O|O||D||1
46191509|Detector de vapor tóxico|O|O||D||1
46191510|Dispositivo de observación térmica tod|O|O||D||1
46191511|Detector de punto caliente del incendio|O|O||D||1
46191600|Equipo contra incendios|O|O||D||1
46191601|Extintores|O|O||D||1|Extintor de incendios
46191602|Sistemas de rociado para incendio|O|O||D||1
46191603|Mangueras o boquillas para incendios|O|O||D||1|Mangueras o toberas de incendio
46191604|Cobijas para incendios|O|O||D||1|Mantas de fuego
46191605|Herramientas manuales de supresión de incendios|O|O||D||1
46191606|Espuma de supresión de incendios o compuestos similares|O|O||D||1
46191607|Aparatos respiratorios para incendios|O|O||D||1
46191608|Sistema de supresión de incendios|O|O||D||1|Sistema de eliminación de incendios
46191609|Equipos de escape de incendios|O|O||D||1
46191610|Cabezales de rociadores de incendios|O|O||D||1
46191611|Carretilla para la manguera contra incendios|O|O||D||1
46191612|Bomba de agua portátil|O|O||D||1
46191613|Agente extinguidor de incendios|O|O||D||1
46191614|Proveedor de espuma líquida contra incendios|O|O||D||1
46191615|Tubo vertical de alimentación de agua contra incendios|O|O||D||1|Tubo vertical de suministro de agua de incendio
46191616|Tanques de agua para extinguir incendios para helicópteros|O|O||D||1
46191617|Lavadora de fuego para mangueras|O|O||D||1
46191618|Base para extintores de fuego|O|O||D||1
46191619|Monitor de agua para incendios|O|O||D||1
46191620|Ventilador de escape de humo|O|O||D||1
46191621|Caja de almacenamiento de extintores de incendios|O|O||D||1|Caja de almacenamiento de extinguidores
46201000|Equipo de entrenamiento en seguridad pública|O|O||D||1
46201001|Maniquí de rescate|O|O||D||1|Muñeco para prácticas de rescate
46201002|Sistema de simulación de entrenamiento en manejo de desastres|O|O||D||1
46201100|Equipo de entrenamiento de armas pequeñas|O|O||D||1
46201101|Rifle de imitación|O|O||D||1|Carabina de imitación, Escopeta de imitación, Máuser de imitació
46201102|Campo de pruebas de disparo|O|O||D||1|Campo de entrenamiento de tiro al blanco, Campo de tiro o disparo
47101500|Equipo para el tratamiento y suministro de agua|O|O||D||1|Garrafones para agua, Vitroleros para agua
47101501|Equipo de carbón activado|O|O||D||1
47101502|Equipo de remoción de amoniaco|O|O||D||1
47101503|Equipo de filtración de carbón|O|O||D||1
47101504|Equipo de remoción de bacterias|O|O||D||1
47101505|Equipo de manejo de cloro|O|O||D||1
47101506|Equipo de control de corrosión|O|O||D||1
47101507|Cámaras de sílice|O|O||D||1
47101508|Equipos de desalinización|O|O||D||1
47101509|Equipos de fluorización|O|O||D||1
47101510|Equipos de remoción de hierro|O|O||D||1
47101511|Equipos de intercambio de hierro|O|O||D||1
47101512|Mezcladores o agitadores|O|O||D||1
47101513|Generadores de oxígeno|O|O||D||1
47101514|Equipos de purificación de agua|O|O||D||1
47101516|Medidores de turbiedad|O|O||D||1|Turbidímetros
47101517|Equipos de desinfección ultravioleta|O|O||D||1
47101518|Acondicionadores de agua|O|O||D||1
47101519|Accesorios para suavizar el agua|O|O||D||1|Accesorios para descalcificar el agua, Accesorios para el ablandamiento del agua
47101521|Equipos de ultra filtrado|O|O||D||1|Equipo de ultrafiltración
47101522|Sistemas empacados de tratamiento de agua|O|O||D||1
47101523|Tanques de recolección|O|O||D||1
47101524|Equipos de compostaje de barro o algas|O|O||D||1
47101525|Equipo de desagüe|O|O||D||1
47101526|Máquinas de peletización de lodo|O|O||D||1
47101527|Trituradores de lodo|O|O||D||1
47101528|Secadores para tratamiento de agua|O|O||D||1
47101529|Incineradores|O|O||D||1
47101530|Equipo de control de olores|O|O||D||1
47101531|Tanques sépticos|O|O||D||1
47101532|Tanques de asentamiento|O|O||D||1
47101533|Estaciones de elevación|O|O||D||1
47101534|Distribuidores de aguas residuales|O|O||D||1
47101535|Equipo de disposición de lodo|O|O||D||1
47101536|Recolectores de lodo|O|O||D||1
47101537|Equipo acondicionador de lodo|O|O||D||1
47101538|Tanques digestores de lodo o aguas residuales|O|O||D||1
47101539|Equipo de remoción de lodo o aguas residuales|O|O||D||1
47101540|Alimentador de químicos|O|O||D||1
47101541|Equipo de ozono de tratamiento de aguas|O|O||D||1
47101542|Equipo de flotación de aire|O|O||D||1
47101543|Aireador de superficie|O|O||D||1
47101544|Difusor de aire para tratamiento de aguas residuales|O|O||D||1
47101545|Contactor biológico rotatorio rbc|O|O||D||1
47101546|Sistema de remoción de arena|O|O||D||1
47101547|Dispositivo de lavado de superficies|O|O||D||1
47101548|Consola de control de filtro|O|O||D||1
47101549|Filtro de gravedad|O|O||D||1
47101550|Filtro de compresión|O|O||D||1
47101551|Filtro de flujo ascendente|O|O||D||1
47101552|Filtro de cama movible|O|O||D||1
47101553|Filtro de fibra|O|O||D||1
47101554|Probador de jarro|O|O||D||1|Probador de tarro
47101555|Tabique de interceptación|O|O||D||1
47101556|Bandeja de goteo de agua|O|O||D||1
47101557|Plato inclinado para asentamiento|O|O||D||1
47101558|Removedor de espuma|O|O||D||1|Interruptor de espuma
47101559|Equipo de remoción de mugre|O|O||D||1
47101560|Equipo de bajo drenaje de filtración|O|O||D||1
47101561|Equipo de tratamiento de adulteración|O|O||D||1
47101562|Pantalla de tambor|O|O||D||1
47101563|Separador coalescente de aguas residuales|O|O||D||1
47101564|Triturador de desperdicios|O|O||D||1|Molino de desperdicios
47101565|Quemador de gas de desperdicios|O|O||D||1
47101566|Filtro de medios múltiples|O|O||D||1
47101567|Máquina de electrodiálisis|O|O||D||1
47101568|Unidad de limpieza de piscinas|O|O||D||1
47101569|Control plano de aguas residuales|O|O||D||1
47101570|Cuneta de oxidación|O|O||D||1
47101571|Unidad de neutralización de gas de cloro|O|O||D||1
47101572|Control de disco|O|O||D||1
47101573|Floculador|O|O||D||1
47101574|Reactor de lotes de secuenciación|O|O||D||1
47101600|Consumibles para el tratamiento de agua|O|O||D||1
47101601|Alguicidas|O|O||D||1
47101602|Anti incrustante|O|O||D||1
47101603|Limpiadores anti calcáreos|O|O||D||1
47101604|Químicos de alimentación de calderas|O|O||D||1|Productos químicos para alimentación de calderas
47101605|Químicos de remoción bacteriana|O|O||D||1|Productos químicos para la eliminación de bacterias
47101606|Químicos de control de corrosión|O|O||D||1|Productos químicos de control de la corrosión
47101607|Químicos de control de olor|O|O||D||1|Productos químicos para el control de olores
47101608|Floculantes|O|O||D||1
47101609|Microbicidas|O|O||D||1
47101610|Compuestos para suavizar el agua|O|O||D||1
47101611|Demulsificantes|O|O||D||1|Demulsificadores
47101612|Polielectrolitos|O|O||D||1
47101613|Soluciones de neutralización|O|O||D||1
47101614|Agente espesante de lodo|O|O||D||1
47101615|Químico de fluorización del agua|O|O||D||1
47111500|Equipo de lavado y secado|O|O||D||1
47111501|Máquinas lavadoras o secadoras combinadas tipo lavandería|O|O||D||1|Lavadoras o secadoras combinadas
47111502|Máquinas lavadoras tipo lavandería|O|O||D||1|Máquinas lavadoras industriales
47111503|Secadoras de ropa|O|O||D||1
47111505|Puestos para equipos de lavandería|O|O||D||1|Espacios para equipo de lavandería, Estaciones de equipo de lavandería, Lugares de equipo de lavanderí
47111506|Extractor centrífugo de lavandería|O|O||D||1|Extractor centrífugo de ropa
47111507|Puesto de secado de lavandería|O|O||D||1|Espacios para secado de lavandería, Estación de secado de lavandería, Lugares de secado de lavanderí
47111508|Tabla de manchas de lavandería|O|O||D||1|Mesa para manchas de lavandería
47111509|Mesa de trabajo de lavandería|O|O||D||1
47111600|Equipo de planchado|O|O||D||1
47111601|Máquinas para planchar o prensas|O|O||D||1
47111602|Máquinas para doblar|O|O||D||1
47111603|Máquinas de vapor para planchar|O|O||D||1|Máquinas de prensado a vapor
47111700|Equipo de limpieza en seco|O|O||D||1
47111701|Máquinas de lavado en seco|O|O||D||1
47121500|Carritos y accesorios para limpieza|O|O||D||1
47121501|Carritos de portero|O|O||D||1|Carritos de limpieza para conserjes
47121502|Accesorios de carrito de portero|O|O||D||1|Accesorios de carro de limpieza para conserjes
47121600|Máquinas y accesorios para pisos|O|O||D||1
47121602|Aspiradoras|O|O||D||1
47121603|Brilladoras de pisos|O|O||D||1|Pulidoras de suelo
47121604|Aspiradoras de combinación secas o húmedas|O|O||D||1
47121605|Depuradores para pisos|O|O||D||1|Limpiadores de pisos
47121606|Barredoras de alfombras|O|O||D||1
47121607|Suministros o accesorios de aspiradoras|O|O||D||1|Provisiones accesorios de aspiradoras
47121608|Almohadillas de máquinas de piso|O|O||D||1
47121609|Equipo de limpieza de alfombras|O|O||D||1
47121610|Máquina para lavar pisos|O|O||D||1|Lavadora de pisos
47121611|Raspadores de pisos|O|O||D||1
47121612|Barredoras para pisos|O|O||D||1|Barredoras de suelo
47121613|Accesorios para brilladoras de pisos|O|O||D||1|Accesorios para pulidor de suelos
47121700|Envases y accesorios para residuos|O|O||D||1
47121701|Bolsas de basura|O|O||D||1
47121702|Contenedores de desperdicios o revestimientos rígidos|O|O||D||1|Recipientes de residuos o revestimientos rígidos
47121703|Urnas de incineración o accesorios|O|O||D||1
47121704|Tapas de contenedores de basura|O|O||D||1|Tapas para contenedores de residuos
47121705|Bolsas de arena para urnas de incineración|O|O||D||1
47121706|Ceniceros|O|O||D||1
47121707|Bolsas para mareo|O|O||D||1
47121708|Bolsas higiénicas|O|O||D||1
47121709|Contenedor de residuos peligrosos|O|O||D||1
47121800|Equipo de limpieza|O|O||D||1
47121801|Plumeros para limpiar el polvo|O|O||D||1
47121802|Removedores de pelusa|O|O||D||1
47121803|Esponjas o esponjillas|O|O||D||1
47121804|Baldes para limpieza|O|O||D||1
47121805|Limpiadores de presión o de vapor|O|O||D||1
47121806|Escurridor de trapero|O|O||D||1
47121807|Émbolo del lavaplatos o inodoro|O|O||D||1
47121808|Equipo de limpieza de drenajes o tubos|O|O||D||1|Equipo de limpieza de desagüe o tubería
47121809|Sartenes desengrasantes|O|O||D||1
47121810|Dispensador de trapos para limpiar|O|O||D||1|Dispensador de trapos de limpieza
47121811|Máquinas para limpiar ductos|O|O||D||1|Máquinas de limpieza de ductos
47121812|Raspadores de limpieza|O|O||D||1
47121813|Cuchillas de repuesto para raspadores|O|O||D||1
47121814|Separador de polvo|O|O||D||1
47121815|Limpiador de piscinas|O|O||D||1
47121900|Accesorios de equipo de limpieza|O|O||D||1
47121901|Cartucheras para esponjas o esponjillas|O|O||D||1
47121902|Accesorios para esponjas o esponjillas|O|O||D||1
47121903|Accesorios para limpiadores de vapor o presión|O|O||D||1
47131500|Trapos y paños de limpieza|O|O||D||1
47131501|Trapos|O|O||D||1|Franelas, Jergas para limpieza
47131502|Pañitos o toallas para limpiar|O|O||D||1|Paños o toallitas de limpieza
47131503|Gamuzas o cueros para lavar|O|O||D||1
47131600|Escobas, traperos, cepillos y accesorios|O|O||D||1
47131601|Cepillos o recogedores para polvo|O|O||D||1
47131602|Almohadillas para restregar|O|O||D||1|Fibras para restregar
47131603|Esponjas|O|O||D||1|Estropajo
47131604|Escobas|O|O||D||1
47131605|Cepillos de limpieza|O|O||D||1
47131608|Cepillos de baño|O|O||D||1
47131609|Manijas de escobas o traperos|O|O||D||1|Mangos de escobas o trapeadores
47131610|Aplicador de terminado para pisos|O|O||D||1|Aplicador de acabado de suelos
47131611|Recogedor de basura|O|O||D||1
47131612|Cauchos de repuesto|O|O||D||1|Bombas destapacaños
47131613|Sujetador de traperos o escobas|O|O||D||1|Porta escobas
47131614|Pinzas para equipos de limpieza|O|O||D||1
47131615|Cabezas de escoba|O|O||D||1
47131616|Sujetadores de pañitos de limpieza|O|O||D||1
47131617|Traperos para polvo|O|O||D||1|Trapeadores para polvo
47131618|Traperos húmedos|O|O||D||1|Trapeadores húmedos
47131619|Cabezas de traperos|O|O||D||1|Cabezas de trapeadores
47131700|Suministros para aseos|O|O||D||1
47131701|Dispensadores de toallas de papel|O|O||D||1
47131702|Dispensadores de productos sanitarios|O|O||D||1|Dispensadores de artículos sanitarios
47131703|Receptáculos para residuos sanitarios|O|O||D||1|Recipientes de residuos sanitarios
47131704|Dispensadores institucionales de jabón o loción|O|O||D||1
47131705|Accesorios para urinales o inodoros|O|O||D||1|Accesorios para mingitorios, Accesorios para urinarios
47131706|Dispensadores de ambientadores|O|O||D||1
47131707|Secadores de manos institucionales|O|O||D||1
47131709|Dispensadores de pañuelos faciales|O|O||D||1
47131710|Dispensadores de papel higiénico|O|O||D||1
47131711|Dispensadores de limpiador|O|O||D||1
47131800|Soluciones de limpieza y desinfección|O|O||D||1
47131801|Limpiadores de pisos|O|O||D||1
47131802|Terminados o ceras para pisos|O|O||D||1
47131803|Desinfectantes para uso doméstico|O|O||D||1
47131804|Limpiadores de amoniaco|O|O||D||1
47131805|Limpiadores de propósito general|O|O||D||1|Ceras limpiadoras, Pulidores
47131806|Pulidores o ceras para muebles|O|O||D||1
47131807|Blanqueadores|O|O||D||1|Cloro, Hipoclorito de sodio, Lejí
47131808|Germicida seco|O|O||D||1
47131809|Productos para limpiar o brillar zapatos|O|O||D||1|Artículos para limpieza o pulido de calzado
47131810|Productos para el lavaplatos|O|O||D||1|Detergente o jabón para trastes
47131811|Productos de lavandería|O|O||D||1|Detergente o jabón para ropa, Suavizante de telas
47131812|Refrescador de aire|O|O||D||1
47131813|Limpiador de pantallas|O|O||D||1
47131814|Limpiadores o pulidores de metales|O|O||D||1|Limpiadores o abrillantadores de metales
47131815|Limpiador de drenajes|O|O||D||1
47131816|Desodorantes|O|O||D||1|Aromatizantes de ambientes
47131817|Protectores de uso doméstico o para automotores|O|O||D||1|Protectores domésticos o automotrices
47131818|Antiséptico de aire|O|O||D||1|Desinfectante de aire
47131819|Limpiadores cáusticos|O|O||D||1
47131820|Limpiadores derivados del petróleo|O|O||D||1
47131821|Compuestos desengrasantes|O|O||D||1
47131822|Compuestos para remover carbón|O|O||D||1
47131823|Descongelantes o deshieladores|O|O||D||1
47131824|Limpiadores de vidrio o ventanas|O|O||D||1
47131825|Limpiadores de superficie de contacto|O|O||D||1
47131826|Limpiadores de alfombras o tapizados|O|O||D||1
47131827|Limpiadores o removedores de manchas|O|O||D||1|Quitamanchas
47131828|Limpiadores de automotores|O|O||D||1
47131829|Limpiadores de baños|O|O||D||1
47131830|Limpiadores de muebles|O|O||D||1
47131831|Ácido muriático|O|O||D||1
47131832|Productos anti polvo|O|O||D||1|Productos contra el polvo
47131833|Antisépticos para uso en alimentos|O|O||D||1|Desinfectantes de alimentos
47131834|Soluciones para limpiar joyas|O|O||D||1|Limpiadores de plata y oro
47131835|Agente desulfurizante|O|O||D||1
47131900|Absorbentes|O|O||D||1
47131901|Almohadillas absorbentes|O|O||D||1
47131902|Absorbentes granulares|O|O||D||1
47131903|Compuesto taponador|O|O||D||1
47131904|Medias absorbentes|O|O||D||1|Calcetines absorbentes
47131905|Kits para derrames|O|O||D||1
47131906|Bandejas absorbentes|O|O||D||1
47131907|Escobas absorbentes|O|O||D||1
47131908|Almohadas absorbentes|O|O||D||1
47131909|Almohadillas o rollos absorbentes|O|O||D||1
47131910|Polímero súper absorbente|O|O||D||1
47132100|Kits de limpieza|O|O||D||1
47132101|Kits de limpieza industrial|O|O||D||1
47132102|Kits de limpieza para uso general|O|O||D||1
48101500|Equipo para cocinar o calentar|O|O||D||1
48101501|Baños maría para uso comercial|O|O||D||1
48101502|Hornos de barbecue para uso comercial|O|O||D||1|Hornos de barbacoa para uso comercial, Parrillas de asado para uso comercial
48101503|Asadores de uso comercial|O|O||D||1
48101504|Parrillas de carbón para uso comercial|O|O||D||1|Asadores de carbón para uso comercial, Potros de carbón para uso comercial
48101505|Cafeteras o máquinas para hacer té helado de uso comercial|O|O||D||1|Molinillos o máquinas para hacer té helado de uso comercial
48101506|Calentadoras de café para uso comercial|O|O||D||1|Calentadores de café para uso comercial
48101507|Hornos de convección para uso comercial|O|O||D||1|Cocinas de convección para uso comercial, Fogones de convección para uso comercial
48101508|Tostadoras sinfín para uso comercial|O|O||D||1
48101509|Freidoras para uso comercial|O|O||D||1
48101510|Calentadoras de comida para uso comercial|O|O||D||1|Calentadores de comida para uso comercial
48101511|Planchas para uso comercial|O|O||D||1
48101512|Parrillas metálicas para uso comercial|O|O||D||1|Asadores metálicos para uso comercial
48101513|Lámparas de calor para uso comercial|O|O||D||1
48101514|Ollas de vapor de alta presión para uso comercial|O|O||D||1|Vaporeras de alta presión para uso comercial
48101515|Parrillas para perros calientes para uso comercial|O|O||D||1|Parrillas de hot dog de uso comercial
48101516|Hornos microondas para uso comercial|O|O||D||1
48101517|Hornos para uso comercial|O|O||D||1
48101518|Ollas para cocinar pasta para uso comercial|O|O||D||1|Cacerolas para cocinar pasta para uso comercial, Cazuelas para cocinar pasta para uso comercial
48101519|Hornos de pizza para uso comercial|O|O||D||1|Fogones de pizza para uso comercial
48101520|Máquinas de maíz pira para uso comercial|O|O||D||1|Máquinas para hacer palomitas de maíz para uso comercial
48101521|Planchas de estufa para uso comercial|O|O||D||1
48101522|Asadores para uso comercial|O|O||D||1
48101523|Ahumadores u hornos para ahumar para uso comercial|O|O||D||1
48101524|Ollas de vapor para uso comercial|O|O||D||1
48101525|Tostadoras para uso comercial|O|O||D||1
48101526|Hierros para waffles para uso comercial|O|O||D||1
48101527|Barbecues|O|O||D||1|Asadores, Parrillas
48101528|Máquinas de crepes para uso comercial|O|O||D||1
48101529|Ollas de presión o freidoras de presión|O|O||D||1|Ollas exprés o freidoras de presión
48101530|Ollas arroceras para uso comercial|O|O||D||1|Arroceras para uso comercial
48101531|Ollas o calderas para salmón para uso comercial|O|O||D||1
48101532|Máquinas o accesorios para algodón dulce para uso comercial|O|O||D||1
48101533|Horno de combinación para uso comercial|O|O||D||1
48101534|Tabla de hervir para uso comercial|O|O||D||1
48101535|Parrillas “salamandra”|O|O||D||1|Asadores "salamandra"
48101536|Horno de pastelería para uso comercial|O|O||D||1
48101537|Horno sinfín para uso comercial|O|O||D||1
48101538|Parrilla de doble contacto para uso comercial|O|O||D||1|Contacto de Prensa Parrilla
48101539|Unidad de filtración de grasa para uso comercial|O|O||D||1|Unidad de filtración de aceite para uso comercial
48101540|Unidad de calentamiento wok para uso comercial|O|O||D||1|Sartén wok para uso comercial
48101541|Almacenador y escurridor de papas fritas para uso comercial|O|O||D||1
48101542|Tetera revestida de inclinación para uso comercial|O|O||D||1
48101543|Sartén revestido para uso comercial|O|O||D||1
48101544|Sartén para usar directamente en el calor para uso comercial|O|O||D||1
48101545|Puesto para horno para uso comercial|O|O||D||1
48101546|Máquina de decocción para uso comercial|O|O||D||1
48101600|Equipos para preparado de alimentos|O|O||D||1
48101601|Mezcladores para uso comercial|O|O||D||1|Mezcladoras de uso comercial
48101602|Abrelatas eléctricos para uso comercial|O|O||D||1
48101603|Cortadores o cortadores en cubos o en dados para uso comercial|O|O||D||1
48101604|Moledoras de café para uso comercial|O|O||D||1|Molinillos de café para uso comercial, Trituradoras de café para uso comercial
48101605|Moledoras de alimentos para uso comercial|O|O||D||1
48101606|Rallos para uso comercial|O|O||D||1|Ralladores de uso comercial
48101607|Exprimidores de jugo para uso comercial|O|O||D||1|Exprimidores de uso comercial
48101608|Licuadoras para uso comercial|O|O||D||1
48101609|Máquinas de pasta para uso comercial|O|O||D||1
48101610|Peladores para uso comercial|O|O||D||1
48101611|Escalas para uso comercial|O|O||D||1|Balanzas de uso comercial, Básculas de uso comercial
48101612|Procesadores de alimentos para uso comercial|O|O||D||1
48101613|Máquinas de amasar para uso comercial|O|O||D||1
48101614|Sets o bolsas para hielo para uso comercial|O|O||D||1|Bolsas de hielo para uso comercial
48101615|Lavadoras de platos para uso comercial|O|O||D||1|Lavavajillas de uso comercial
48101616|Tajadores de alimentos para uso comercial|O|O||D||1|Cortadores de alimentos para uso comercial
48101617|Espátulas plásticas para uso comercial|O|O||D||1|Espátulas flexibles de plástico para uso comercial
48101618|Partes de máquinas para lavar platos para uso comercial|O|O||D||1|Partes de máquinas lavavajillas para uso comercial
48101619|Sistema de esterilización de agua|O|O||D||1
48101700|Distribuidores automáticos de comida y bebida|O|O||D||1
48101701|Dispensador de bebidas carbonatadas|O|O||D||1|Máquinas de bebidas carbonatadas
48101702|Dispensador de bebidas no carbonatadas|O|O||D||1|Máquinas de bebidas no carbonatadas
48101703|Dispensadores de leche|O|O||D||1
48101704|Bombas de melaza (syrup)|O|O||D||1|Bombas de melaza (jarabe)
48101705|Máquinas de cappuccino o expreso|O|O||D||1|Dispensador de cappuccino o expreso
48101706|Máquinas de leche malteada|O|O||D||1
48101707|Máquinas de helados suaves|O|O||D||1|Dispensadores de helados suaves
48101708|Máquinas de granizados|O|O||D||1|Dispensador de bebidas granizadas
48101709|Dispensadores de hielo|O|O||D||1|Máquinas dispensadoras de hielo
48101710|Fuentes o contenedores de burbujeo de bebidas|O|O||D||1
48101711|Dispensadores de agua embotellada o accesorios|O|O||D||1
48101712|Dispensadores de tazas|O|O||D||1
48101713|Mezcladores de cócteles o accesorios|O|O||D||1|Coctelera o accesorios
48101714|Dispensadores de agua caliente|O|O||D||1
48101715|Máquina ralladora de hielo|O|O||D||1|Ralladores de hielo
48101716|Purificador de agua|O|O||D||1|Purificadores de agua
48101800|Menaje y utensilios de cocina|O|O||D||1
48101801|Cubiertos para uso comercial|O|O||D||1
48101802|Moldes para uso comercial|O|O||D||1|Gelatinero, flanero y moldes para pastel
48101803|Cucharones para uso comercial|O|O||D||1
48101804|Tazas medidoras para uso comercial|O|O||D||1
48101805|Tazones para mezclar para uso comercial|O|O||D||1
48101806|Latas de ponqués o pies para uso comercial|O|O||D||1|Platos para panqués o pasteles de uso comercial
48101807|Latas de pizza para uso comercial|O|O||D||1|Platos para pizza de uso comercial
48101808|Sartenes de salsa o para sofreír para uso comercial|O|O||D||1|Sartenes para salsas y para saltear de uso comercial
48101809|Ollas para salsas o cocción para uso comercial|O|O||D||1
48101810|Tapas para sartenes u ollas para uso comercial|O|O||D||1|Tapas para cacerolas u ollas para uso comercial
48101811|Rodillos de amasar para uso comercial|O|O||D||1
48101812|Coladeras para uso comercial|O|O||D||1|Filtros de uso comercial
48101813|Batidoras manuales para uso comercial|O|O||D||1
48101814|Woks para uso comercial|O|O||D||1
48101815|Cucharas de servir para uso comercial|O|O||D||1
48101816|Bolsa para cubiertos para uso comercial|O|O||D||1
48101817|Equipos o moldes para decorar ponqués|O|O||D||1|Moldes para decorar panqués
48101818|Desinfectante de vajillas|O|O||D||1
48101819|Esterilizador de manos|O|O||D||1|Esterilizador para manos
48101820|Campana extractora para uso comercial|O|O||D||1|Campana de cocina para uso comercial
48101900|Tazas para servicio de mesa|O|O||D||1
48101901|Vajilla fina para servicio de comidas|O|O||D||1|Porcelana fina para servicio de comidas
48101902|Cubertería para servicio de comidas|O|O||D||1|Cubiertos para servicio de comida
48101903|Vasos para servicio de comidas|O|O||D||1
48101904|Copas para servicio de comidas|O|O||D||1
48101905|Tazas o tazones (mugs) para servicio de comidas|O|O||D||1
48101906|Canastas para servir para servicio de comidas|O|O||D||1|Charolas para servicio de comidas
48101907|Jarras para servicio de comidas|O|O||D||1
48101908|Ollas para servicio de comidas|O|O||D||1|Cacerolas para servicio de comidas, Cazuelas para servicio de comidas
48101909|Teteras o cafeteras para servicio de comidas|O|O||D||1
48101910|Vasijas de barro para servicio de comidas|O|O||D||1
48101911|Baldes de hielo o baldes para enfriar el vino para servicio de comidas|O|O||D||1|Hieleras de vino para servicio de comida
48101912|Dispensadores de condimentos para servicio de comidas|O|O||D||1
48101913|Tazones de ponche para servicio de comidas|O|O||D||1
48101914|Botellones de vino para servicio de comidas|O|O||D||1
48101915|Bandejas para servicio de comidas|O|O||D||1|Recipientes para servicio de comidas
48101916|Dispensadores de servilletas para servicio de comidas|O|O||D||1|Servilletero para servicio de comidas
48101917|Aparatos de fondue para servicio de comidas|O|O||D||1
48101918|Rollos para cubrir la mesa para servicio de comidas|O|O||D||1
48101919|Vasos o tazas o tazones (mugs) o tapas de contenedores para servicio de comidas|O|O||D||1
48101920|Dispensadores de pitillos|O|O||D||1|Porta popotes
48102000|Mobiliario de restaurantes|O|O||D||1
48102001|Sillas para restaurantes|O|O||D||1
48102002|Cabinas para restaurantes|O|O||D||1|Muebles para restaurantes
48102003|Barras de ensalada|O|O||D||1
48102004|Superficies de mesa|O|O||D||1
48102005|Taburetes de bar|O|O||D||1|Asientos de bar, Banquillos de bar
48102006|Bares permanentes|O|O||D||1
48102007|Bares portátiles|O|O||D||1
48102008|Mesas para condimentos|O|O||D||1
48102009|Mesas para servir o dispensar comidas|O|O||D||1
48102010|Carrito para recoger tazas|O|O||D||1|Carrito de servicio
48102100|Suministros y equipo de manipulación y almacenamiento|O|O||D||1
48102101|Mostradores|O|O||D||1|Vitrinas
48102102|Mostradores para mantener caliente la comida|O|O||D||1|Contenedor de alimentos calientes, Vitrinas para mantener caliente la comida
48102103|Mostradores refrigerados|O|O||D||1
48102104|Mostradores para helados|O|O||D||1|Vitrina para helados
48102105|Equipos para enfriar vasos|O|O||D||1|Equipo refrigerador de vasos
48102106|Contenedores fríos|O|O||D||1
48102107|Guantes para abastecimiento de comidas por encargo (catering) o dispensadores de guantes|O|O||D||1
48102108|Papel aluminio para envolver alimentos|O|O||D||1
48102109|Papel plástico para envolver alimentos|O|O||D||1
48111000|Máquinas expendedoras de líquidos|O|O||D||1
48111001|Máquinas dispensadoras de porciones únicas con tazas|O|O||D||1|Máquinas dispensadoras porciones individuales con tazas
48111002|Maquinas dispensadoras de cantidades grandes|O|O||D||1|Máquinas dispensadoras de cantidades a granel
48111100|Máquinas expendedoras de piezas/unidades|O|O||D||1
48111101|Máquinas expendedoras de botellas o latas|O|O||D||1
48111102|Máquinas de bolas de dulce o novedades para niños|O|O||D||1
48111103|Máquinas exhibidoras de botanas o productos en paquetes pequeños|O|O||D||1|Máquinas de presentación de productos de aperitivos o pequeños paquetes
48111104|Máquinas expendedoras de comidas a la carta|O|O||D||1|Máquinas expendedoras de alimentos a la carta
48111105|Máquinas de confitería helada|O|O||D||1
48111106|Dispensadores de ítems de acomodación personal|O|O||D||1
48111107|Máquinas de cigarrillos|O|O||D||1|Dispensadoras de cigarrillos
48111108|Dispensadores de medicamentos|O|O||D||1
48111109|Máquina para lustrar calzado|O|O||D||1
48111200|Máquinas expendedoras de alimentos mandados hacer|O|O||D||1
48111201|Máquinas expendedoras de papas a la francesa|O|O||D||1
48111202|Máquinas expendedoras de maíz pira|O|O||D||1|Máquinas expendedoras de palomitas de maíz
48111300|Máquinas expendedoras servicios y boletas|O|O||D||1
48111301|Máquinas expendedoras de boletas|O|O||D||1
48111302|Máquinas expendedoras de pólizas de seguros|O|O||D||1
48111303|Máquinas de estampillas|O|O||D||1
48111304|Máquina automática de verificación de tiquete y cobro|O|O||D||1|Máquina expendedora de tickets y módulo de cobro
48111305|Máquinas automáticas de cambio de moneda|O|O||D||1
48111306|Sistema de manejo de clientes para restaurantes|O|O||D||1
48111400|Máquinas expendedoras de dinero efectivo|O|O||D||1
48111401|Máquinas de cajero automático atm|O|O||D||1|Cajeros automáticos
48111402|Máquinas para cambiar billetes en monedas|O|O||D||1
48111403|Máquinas para cambiar moneda extranjera|O|O||D||1|Máquinas de cambio de moneda extranjera
48111404|Equipos de transferencia electrónica de fondos para puntos de venta|O|O||D||1
48111405|Accesorios para máquinas de cajero automático|O|O||D||1|Accesorios para cajeros automáticos
48111406|Sistema de numeración de filas|O|O||D||1
48121100|Máquinas de Juego operadas con monedas|O|O||D||1
48121101|Máquinas de póker o tragamonedas|O|O||D||1
48121102|Máquinas de lotería|O|O||D||1
48121200|Mesas de Juego y Juegos|O|O||D||1
48121201|Ruedas de ruleta|O|O||D||1
48121202|Mesas de naipes|O|O||D||1|Mesas de cartas
48121300|Gestión de Juego y sistemas de apuestas en red|O|O||D||1
48121301|Sistemas de manejo de mesas de juego|O|O||D||1|Sistemas de gestión de juegos de mesa
48121302|Juegos de apuestas en red|O|O||D||1
48131500|Productos de entierro o tumbas|O|O||D||1|Productos funerarios
48131501|Cajas de cenizas funerarias o urnas de cremación|O|O||D||1
48131502|Ataúdes|O|O||D||1|Féretros
48131503|Mortajas|O|O||D||1|Vestiduras
48131504|Lápidas|O|O||D||1
48131505|Tabla de ofrecimientos en piedra|O|O||D||1
49101600|Coleccionables|O|O||D||1
49101601|Antigüedades|O|O||D||1
49101602|Recuerdos (souvenirs)|O|O||D||1
49101603|Colecciones de monedas|O|O||D||1
49101604|Colecciones de estampillas|O|O||D||1
49101605|Alfombras antiguas|O|O||D||1
49101606|Artículos excavados|O|O||D||1
49101607|Colecciones de historietas cómicas|O|O||D||1|Colecciones de cómics
49101608|Instrumentos musicales antiguos|O|O||D||1
49101609|Ornamentos o decoraciones|O|O||D||1|Adornos o decoraciones
49101611|Amuletos|O|O||D||1
49101612|Hologramas|O|O||D||1
49101613|Cristales de vidrio|O|O||D||1
49101614|Máscaras rituales o para teatro|O|O||D||1
49101700|Premios|O|O||D||1
49101701|Medallas|O|O||D||1
49101702|Trofeos|O|O||D||1
49101704|Placas|O|O||D||1
49101705|Certificados|O|O||D||1
49101706|Premios de fotografía|O|O||D||1
49101707|Certificado de logro|O|O||D||1|Reconocimiento
49101708|Coronas|O|O||D||1
49101709|Tabletas de conmemoración|O|O||D||1
49121500|Equipos para camping y exteriores|O|O||D||1
49121502|Almohadas para dormir para acampar|O|O||D||1
49121503|Carpas|O|O||D||1|Carpas para eventos, Tiendas de campaña
49121504|Sleeping bags (bolsas para dormir)|O|O||D||1
49121505|Cajas de hielo|O|O||D||1|Hieleras
49121506|Kit de reparación de carpas|O|O||D||1
49121507|Colchones neumáticos|O|O||D||1|Colchones de aire
49121508|Mosquiteros|O|O||D||1
49121509|Estufas para acampar o para exteriores|O|O||D||1
49121510|Enfriadores de bebidas|O|O||D||1|Refrigeradores de bebidas
49121511|Reverberos para acampar o exteriores|O|O||D||1|Cocinillas para acampar o exteriores
49121512|Estacas para carpas|O|O||D||1
49121513|Tornillos para carpas|O|O||D||1
49121600|Muebles de camping|O|O||D||1
49121601|Asientos o taburetes para acampar|O|O||D||1|Banquillos para acampar, Sillas para acampar
49121602|Mesas para acampar|O|O||D||1
49121603|Catres para acampar|O|O||D||1|Cama para acampar
49131500|Aparejos de pesca|O|O||D||1
49131501|Cañas de pescar|O|O||D||1
49131502|Hilo de pesca|O|O||D||1|Cuerda de pesca
49131503|Carreteles de pesca|O|O||D||1|Carretes de pescar
49131504|Cebos para pesca|O|O||D||1|Señuelos de pesca
49131505|Carnadas|O|O||D||1|Trampa para pesca
49131506|Pesas para pesca|O|O||D||1|Plomos para pesca
49131600|Productos de cacería|O|O||D||1
49131601|Llamadas de animales|O|O||D||1
49131602|Señuelos para deportes|O|O||D||1
49131603|Trampas para deportes|O|O||D||1
49131604|Escopetas para deportes|O|O||D||1
49131605|Rifles para deportes|O|O||D||1
49131606|Munición para deportes|O|O||D||1
49131607|Cañones de escopetas|O|O||D||1
49141500|Escafandras autónomas y tubos de respiración|O|O||D||1
49141501|Compensadores de flotación|O|O||D||1
49141502|Tanques de buceo|O|O||D||1
49141503|Reguladores para buceo|O|O||D||1
49141504|Instrumentos de buceo o accesorios|O|O||D||1|Accesorios para buceo
49141505|Máscaras o aletas o esnórqueles|O|O||D||1
49141506|Trajes isotérmicos|O|O||D||1|Trajes de buceo
49141507|Trajes secos|O|O||D||1|Trajes secos de buceo
49141508|Botas para buceo|O|O||D||1
49141509|Capucha para buceo|O|O||D||1
49141600|Equipos y accesorios para windsurf y natación|O|O||D||1
49141602|Tablas de esquí acuático o tablas para arrodillarse o boogieboards|O|O||D||1
49141603|Esquís acuáticos o accesorios|O|O||D||1
49141604|Equipos de windsurfing|O|O||D||1|Equipos de tabla a vela
49141605|Tablas de surf|O|O||D||1
49141606|Anteojos de natación o aletas de natación|O|O||D||1|Lentes o aletas de natación
49141607|Equipo de paravelismo|O|O||D||1|Equipo de parapente
49151500|Equipos de esquí y snowboard|O|O||D||1
49151501|Botas de esquí|O|O||D||1
49151502|Esquís|O|O||D||1
49151503|Varillas de esquí|O|O||D||1|Postes de esquí
49151504|Amarres|O|O||D||1
49151505|Tablas de esquí en nieve|O|O||D||1
49151506|Guantes de esquí|O|O||D||1
49151600|Equipos de patinaje y hockey sobre hielo|O|O||D||1
49151601|Discos de hockey|O|O||D||1
49151602|Patines de hielo|O|O||D||1
49151603|Palos de hockey|O|O||D||1|Bastón de hockey
49161500|Equipos para deportes de campo|O|O||D||1
49161501|Toboganes de bloqueo para futbol|O|O||D||1
49161502|Guantes de beisbol|O|O||D||1|Manilla de béisbol, Manoplas de béisbol
49161503|Pelotas de beisbol|O|O||D||1
49161504|Balones de futbol|O|O||D||1
49161505|Balones de soccer|O|O||D||1
49161506|Bates de beisbol|O|O||D||1
49161507|Bases de beisbol|O|O||D||1
49161508|Máquinas para lanzar (pitching)|O|O||D||1
49161509|Balones de softbol|O|O||D||1
49161510|Muñecos para jugadas de futbol|O|O||D||1
49161511|Palos de lacrosse|O|O||D||1
49161512|Pelotas de lacrosse|O|O||D||1|Bolas de lacrosse
49161513|Palos de hockey de campo|O|O||D||1
49161514|Bolas de hockey de campo|O|O||D||1
49161515|Pelotas de equipos de balonmano|O|O||D||1
49161516|Sets escolares de equipos de balonmano|O|O||D||1
49161517|Equipo protector para beisbol o softbol|O|O||D||1|Equipo de protección para béisbol o softbol
49161518|Ayudas para batear en beisbol|O|O||D||1
49161519|Defensas traseras o cercas para beisbol|O|O||D||1
49161520|Bates de softbol|O|O||D||1
49161521|Guantes de softbol|O|O||D||1|Manilla de softbol, Manopla de softbol
49161522|Tees de patada para futbol|O|O||D||1
49161523|Equipo de futbol de bandera|O|O||D||1|Accesorios para futbol bandera, Accesorios para tocho bandera
49161524|Equipo de marcado de campo para soccer|O|O||D||1|Accesorios de marcado de campo para soccer
49161525|Equipo protector para soccer|O|O||D||1
49161526|Ayudas de entrenamiento para soccer|O|O||D||1|Accesorios de entrenamiento para soccer
49161527|Palo de gateball|O|O||D||1
49161600|Equipos para deportes de raqueta y pista|O|O||D||1
49161601|Raquetas de racquetball|O|O||D||1
49161602|Raquetas de bádminton|O|O||D||1
49161603|Pelotas de básquetbol|O|O||D||1|Balones de básquetbol
49161604|Pelotas de tenis|O|O||D||1
49161605|Pelotas de racquet|O|O||D||1
49161606|Pelotas de squash|O|O||D||1
49161607|Raquetas de tenis|O|O||D||1
49161608|Balones de voleibol|O|O||D||1|Pelotas de voleibol
49161609|Gallitos de bádminton|O|O||D||1
49161610|Raquetas de squash|O|O||D||1
49161611|Ayudas de entrenamiento para tenis|O|O||D||1|Accesorios para entrenamiento de tenis
49161612|Equipo de cancha de tenis|O|O||D||1
49161613|Almacenamiento para balones o redes de voleibol|O|O||D||1|Bolsa de almacenamiento para balones o redes de voleibol, Contenedor de almacenamiento para balones o redes de voleibol
49161614|Estándares gimnásticos para voleibol|O|O||D||1
49161615|Sistemas de juego completo para basquetbol|O|O||D||1|Sistemas de juego completo para baloncesto
49161616|Equipo protector para hockey de piso|O|O||D||1|Accesorios de protección para hockey de piso
49161617|Postes para red|O|O||D||1
49161618|Espiros|O|O||D||1
49161619|Cuerdas para raquetas|O|O||D||1
49161620|Agarres (“grips”) para raquetas|O|O||D||1|Agarraderas de raqueta
49161621|Máquinas para cuerdas de raqueta|O|O||D||1
49161700|Equipos para deportes de pista|O|O||D||1
49161701|Jabalinas|O|O||D||1|Lanzas
49161702|Barras para saltar|O|O||D||1
49161703|Discos|O|O||D||1|Disco de lanzamiento
49161704|Balas de lanzamiento|O|O||D||1
49161705|Garrochas|O|O||D||1|Pértigas
49161706|Obstáculos|O|O||D||1|Bloques y obstáculos
49161707|Bastones|O|O||D||1|Bastones de relevo
49161708|Barra de salto y garrocha|O|O||D||1|Barra de salto y pértiga
49161709|Círculo de lanzamiento de disco|O|O||D||1
49161710|Martillo para lanzar|O|O||D||1
49161711|Círculo de lanzamiento de bala|O|O||D||1
49171500|Equipos de gimnasia|O|O||D||1
49171501|Barras o postes gimnásticos|O|O||D||1|Barras de gimnasia o vigas
49171502|Cuerdas o anillos o accesorios para trepar gimnásticos|O|O||D||1
49171503|Equipo de garrocha para uso gimnástico|O|O||D||1
49171504|Trampolines para uso gimnástico|O|O||D||1
49171505|Equipo de equilibrio|O|O||D||1
49171506|Caballo de borrén delantero para uso gimnástico|O|O||D||1
49171507|Club indio para uso gimnástico|O|O||D||1
49171508|Trampolín de salto o “beatboard” para uso gimnástico|O|O||D||1
49171509|Caja de salto para uso gimnástico|O|O||D||1
49171600|Equipos de boxeo|O|O||D||1
49171601|Rings para boxeo|O|O||D||1
49171602|Sacos de boxeo|O|O||D||1|Costal Para Boxeo
49171603|Guantes de boxeo|O|O||D||1
49171604|Campana de boxeo|O|O||D||1
49181500|Equipos y juegos de mesa|O|O||D||1
49181501|Mesas de billar|O|O||D||1
49181502|Tacos de pool|O|O||D||1|Palo de billar
49181503|Juegos de tejo|O|O||D||1
49181504|Juegos de pinball|O|O||D||1
49181505|Bolas de billar|O|O||D||1
49181506|Mesas para hockey aéreo o accesorios|O|O||D||1
49181507|Mesas de tenis (ping pong)|O|O||D||1
49181508|Raquetas de ping pong|O|O||D||1
49181509|Bolas de ping pong|O|O||D||1
49181510|Mesas de foosball|O|O||D||1|Mesas de futbolito
49181511|Bolas de foosball|O|O||D||1|Pelotas de futbolín
49181512|Jugadores de repuesto para foosball|O|O||D||1|Jugadores de repuesto para foosball, Muñecos de repuesto para foosball
49181513|Puntas de tacos de billar|O|O||D||1
49181514|Tiza de billar|O|O||D||1
49181515|Estantes de billar|O|O||D||1|Anaqueles de billar, Muebles de billar
49181600|Equipo y juegos de tiro al blanco|O|O||D||1
49181601|Objetivos para tiro con arco|O|O||D||1
49181602|Arcos|O|O||D||1
49181603|Flechas|O|O||D||1
49181604|Dardos|O|O||D||1
49181605|Tableros de dardos|O|O||D||1
49181606|Equipo de tiro al plato|O|O||D||1
49181607|Objetivos para lanzar|O|O||D||1|Objetivos de lanzamiento
49181608|Cuerdas para arcos|O|O||D||1
49181609|Guantes para tiro con arco|O|O||D||1|Mitones para tiro con arco
49181610|Protectores de brazos para tiro con arco|O|O||D||1
49181611|Puestos de objetivos para tiro con arco|O|O||D||1|Bases de objetivos para tiro con arco
49181612|Defensas traseras para tiro con arco|O|O||D||1
49181613|Gukgung (arco coreano)|O|O||D||1
49181614|Ballesta para tiro con arco|O|O||D||1
49201500|Equipo de entrenamiento para aeróbicos|O|O||D||1
49201501|Trotadoras|O|O||D||1|Caminadoras
49201502|Escaladores de escaleras|O|O||D||1
49201503|Bicicletas estáticas|O|O||D||1
49201504|Máquinas de remos|O|O||D||1
49201512|Lazos para saltar|O|O||D||1|Cuerdas para saltar
49201513|Trampolines para ejercicios|O|O||D||1
49201514|Pelotas para ejercicios|O|O||D||1|Bola de la gimnasia
49201515|Equipos de paso para aeróbicos (“step”)|O|O||D||1|Equipo aeróbico de paso
49201516|Bicicletas elípticas|O|O||D||1
49201517|Máquina de inversión|O|O||D||1|Tabla de Inversión
49201518|Barras de pared|O|O||D||1|Barras de dominadas montable en pared
49201519|Torbellino de cuerpo|O|O||D||1
49201520|Set de paletas para viaje|O|O||D||1
49201600|Equipo de entrenamiento de pesas y resistencia|O|O||D||1
49201601|Pesas|O|O||D||1
49201602|Pesas de 280 libras|O|O||D||1
49201603|Máquinas de resistencia para la parte inferior del cuerpo|O|O||D||1
49201604|Bancos o estantes para pesas|O|O||D||1|Soportes para pesas
49201605|Máquinas de resistencia para la parte superior del cuerpo|O|O||D||1
49201606|Pesas de estado físico|O|O||D||1
49201607|Máquinas de pilates|O|O||D||1
49201608|Máquina para dar fuerza de agarre|O|O||D||1
49201609|Bandas de resistencia|O|O||D||1|Cintas de resistencia
49201610|Tubos de resistencia|O|O||D||1
49201611|Multi gimnasios|O|O||D||1
49201612|Pesas de entrenamiento|O|O||D||1
49211600|Equipo de golf|O|O||D||1
49211601|Talegas de golf|O|O||D||1|Bolsa de golf, Saco de golf
49211602|Bolas de golf|O|O||D||1|Pelota de golf
49211603|Tacos de golf|O|O||D||1
49211604|Tees de golf|O|O||D||1
49211605|Forros para las cabezas de los tacos de golf|O|O||D||1|Cubiertas para las cabezas de los tacos de golf
49211606|Guantes de golf|O|O||D||1
49211607|Divot fijador|O|O||D||1
49211608|Golfscopios|O|O||D||1
49211609|Compañero de putting para golf|O|O||D||1
49211700|Equipo de bolos y accesorios y suministros|O|O||D||1
49211701|Equipo de bolos|O|O||D||1
49211702|Suministros de bolos|O|O||D||1
49211703|Accesorios de bolos|O|O||D||1
49211800|Equipo de clase de educación física|O|O||D||1
49211801|Equipo de paracaidismo|O|O||D||1
49211802|Aros de hula o equipos de hula|O|O||D||1
49211803|Equipos de orientación|O|O||D||1
49211804|Materiales o marcadores de identificación de equipos|O|O||D||1
49211805|Cuerdas|O|O||D||1
49211806|Almacenamiento de equipos de educación física|O|O||D||1
49211807|Herramientas de evaluación para educación física|O|O||D||1
49211808|Herramienta para medir la obesidad|O|O||D||1
49211809|Herramienta para medir el cuerpo|O|O||D||1
49211810|Pistola de radar para medir la velocidad|O|O||D||1|Radar para medir la velocidad
49211811|Ergómetro|O|O||D||1
49211812|Dispositivo de medición de la flexión del tronco|O|O||D||1
49211813|Medidor de saltos|O|O||D||1
49211814|Instrumento de medición de fatiga|O|O||D||1
49211815|Sistema de medición de reacción de todo el cuerpo|O|O||D||1
49211816|Analizador de carreras|O|O||D||1
49211817|Instrumento de medición de fuerza muscular|O|O||D||1
49211818|Balón medicinal|O|O||D||1
49211819|Sistema de análisis de movimiento|O|O||D||1
49211820|Dinamómetro de agarre|O|O||D||1
49211821|Dinamómetro de espalda, piernas y pecho|O|O||D||1
49211822|Kit de evaluación de músculos de la mano|O|O||D||1
49211823|Instrumento de medición para el cuerpo humano|O|O||D||1
49211824|Kit de evaluación de postura|O|O||D||1
49211825|Dispositivo de prueba de inteligencia|O|O||D||1
49211826|Equipo de medición de características corporales|O|O||D||1
49211827|Probador de movimiento de dedos|O|O||D||1
49211828|Probador de estabilidad de la mano|O|O||D||1
49211829|Analizador de circulación sanguínea|O|O||D||1
49211830|Probador de paso lateral|O|O||D||1
49211831|Probador de abdomen (sentadillas)|O|O||D||1
49211832|Probador de equilibrio|O|O||D||1
49211833|Probador de resistencia de corazón y pulmones|O|O||D||1
49221500|Accesorios para deporte|O|O||D||1
49221501|Tableros de anotaciones para deportes|O|O||D||1|Marcadores deportivos
49221502|Porterías|O|O||D||1
49221503|Equipos de seguridad deportiva excepto para la cabeza|O|O||D||1
49221504|Artículos de seguridad para la cabeza para uso deportivo|O|O||D||1|Cascos deportivos de seguridad
49221505|Mallas o redes para deportes|O|O||D||1
49221506|Almohadillas o acolchado para deportes|O|O||D||1|Cojines o acolchado para deportes
49221507|Tableros de basquetbol|O|O||D||1|Tableros de baloncesto
49221508|Aros de basquetbol|O|O||D||1|Aro de baloncesto
49221509|Patines o cuchillas de patines|O|O||D||1
49221510|Gorras deportivas|O|O||D||1
49221511|Bolsas para equipos deportivos|O|O||D||1|Maletas para equipos deportivos
49221512|Patinetas|O|O||D||1
49221513|Banca para jugadores|O|O||D||1
49221514|Asiento o puesto para el árbitro|O|O||D||1|Silla o stand de arbitro
49221515|Bomba para inflar balones|O|O||D||1
49221516|Pistola de arranque|O|O||D||1
49221517|Bloque de arranque|O|O||D||1
49221518|Postes de mallas|O|O||D||1
49221519|Espada de esgrima|O|O||D||1|Florete para esgrima, Sable para esgrima
49221520|Puesto de herramientas atléticas|O|O||D||1
49221521|Carrito de productos deportivos|O|O||D||1
49221522|Maniquí de entrenamiento atlético|O|O||D||1
49221523|Podio de premiación|O|O||D||1
49221524|Chaqueta para esgrima|O|O||D||1
49221525|Tubo interior de caucho para atletismo|O|O||D||1
49221526|Cinturón para levantar pesas|O|O||D||1|Fajas para levantar pesas
49221527|Espada de bambú|O|O||D||1|Sable de bambú
49221528|Tablero trasero de basquetbol|O|O||D||1|Tablero trasero de baloncesto
49221529|Máquina de juzgamiento de esgrima|O|O||D||1
49221530|Temporizador para deportes|O|O||D||1
49221531|Poste para columpiarse|O|O||D||1
49221532|Sistema de juegos para patios de recreo|O|O||D||1
49221533|Tablas flotantes para natación|O|O||D||1|Tabla para natación
49241500|Equipo de parques infantiles|O|O||D||1
49241501|Columpios para patios de recreo|O|O||D||1|Columpios para parques infantiles
49241502|Aparatos de trepar para patios de recreo|O|O||D||1|Aparatos de escalamiento para juegos
49241503|Carruseles para patios de recreo|O|O||D||1|Carruseles para parques infantiles
49241504|Rodaderos para patios de recreo|O|O||D||1
49241505|Balanzas para patios de recreo|O|O||D||1
49241506|Túneles para patios de recreo|O|O||D||1
49241507|Cajas de arena para patios de recreo|O|O||D||1
49241508|Graderías para patios de recreo|O|O||D||1
49241509|Equipo para escalar muros|O|O||D||1|Equipo para trepar muros
49241510|Equipos para escalar lazos|O|O||D||1|Equipos de escalada de cuerda
49241511|Pérgolas|O|O||D||1
49241600|Equipo de recreo|O|O||D||1
49241601|Sets de croquet|O|O||D||1|Juegos de croquet
49241602|Equipos de bolos de jardín|O|O||D||1
49241603|Equipos de pistas para lanzar herraduras|O|O||D||1
49241604|Dardos de jardín|O|O||D||1|Dardos de césped
49241700|Equipo y suministros de piscina y spa|O|O||D||1
49241701|Trampolines|O|O||D||1
49241702|Rodaderos de piscina|O|O||D||1
49241703|Soplador de spa|O|O||D||1
49241704|Kit o soluciones de prueba de agua|O|O||D||1
49241705|Limpiador automático de piscinas|O|O||D||1
49241706|Cobija solar|O|O||D||1|Manta solar
49241707|Caldera para piscinas o spa|O|O||D||1|Calentador para piscinas o spa
49241708|Generador de ozono|O|O||D||1
49241709|Rieles para cortinas solares|O|O||D||1
49241710|Almohada para spa|O|O||D||1|Cojín para spa
49241711|Cubiertas para spa|O|O||D||1
49241712|Químicos para piscinas o piscinas de hidromasaje|O|O||D||1
49241800|Equipos de sauna|O|O||D||1
49241801|Caldera para sauna|O|O||D||1
50101700|Frutos secos|O|O||D||1|Almendras
50101716|Nueces y semillas enteras|O|O||D||1
50101717|Nueces y semillas sin cascara|O|O||D||1
50111500|Carne y aves de corral|O|O||D||1
50111513|Carne, mínimamente procesada sin aditivos|O|O||D||1
50111514|Cerdo, mínimamente procesado sin aditivos|O|O||D||1|Chanchos, mínimamente procesado sin aditivos, Cochinillos, mínimamente procesado sin aditivos, Cochinos, mínimamente procesado sin aditivos, Cuche, mínimamente procesado sin aditivos, Cuinos, mínimamente procesado sin aditivos, Gorrinos, mínimamente procesado sin aditivos, Lechones, mínimamente procesado sin aditivos, Marranos, mínimamente procesado sin aditivos, Porcinos, mínimamente procesado sin aditivos, Puercos, mínimamente procesado sin aditivos,Lechones, mínimamente procesado sin aditivos
50111515|Pollo, mínimamente procesado sin aditivos|O|O||D||1|Gallina, mínimamente procesada sin aditivos
50111516|Carne, mínimamente procesado con aditivos|O|O||D||1
50111517|Ternera, mínimamente procesado sin aditivos|O|O||D||1
50111518|Ternera, mínimamente procesado con aditivos|O|O||D||1
50111519|Cerdo, mínimamente procesado con aditivos|O|O||D||1|Chanchos, mínimamente procesado con aditivos, Cochinillos, mínimamente procesado con aditivos, Cochinos, mínimamente procesado con aditivos, Cuche, mínimamente procesado con aditivos, Cuinos, mínimamente procesado con aditivos, Gorrinos, mínimamente procesado con aditivos, Lechones, mínimamente procesado con aditivos, Marranos, mínimamente procesado con aditivos, Porcinos, mínimamente procesado con aditivos, Puercos, mínimamente procesado con aditivos,Lechones, mínimamente procesado con aditivos
50111520|Pollo, mínimamente procesado con aditivos|O|O||D||1|Gallina, mínimamente procesado con aditivos
50111521|Pavo, mínimamente procesado sin aditivos|O|O||D||1
50111522|Pavo, mínimamente procesado con aditivos|O|O||D||1
50111523|Cordero , mínimamente procesado sin aditivos|O|O||D||1
50111524|Cordero , mínimamente procesado con aditivos|O|O||D||1
50111525|Chivo, mínimamente procesado sin aditivos|O|O||D||1
50111526|Chivo, mínimamente procesado con aditivos|O|O||D||1
50111527|Carne especializada, mínimamente procesada sin aditivos|O|O||D||1
50111528|Carne especializada , mínimamente procesado con aditivos|O|O||D||1
50111529|Aves especializadas, mínimamente procesada sin aditivos|O|O||D||1
50111530|Aves especializadas, mínimamente procesada con aditivos|O|O||D||1
50111531|Carne especial mixta, mínimamente procesada sin aditivos|O|O||D||1
50111532|Carne especial mixta, mínimamente procesada con aditivos|O|O||D||1
50111533|Pato, mínimamente procesada con aditivos|O|O||D||1
50111534|Pato, mínimamente procesada sin aditivos|O|O||D||1
50111535|Caballo,  mínimamente procesada sin aditivos|O|O||D||1|Equino, mínimamente procesada sin aditivos
50111536|Caballo, mínimamente procesada con aditivos|O|O||D||1|Equino, mínimamente procesada con aditivos
50111537|Conejo, mínimamente procesada sin aditivos|O|O||D||1
50111538|Conejo, , mínimamente procesada con aditivos|O|O||D||1
50111539|Rana,, mínimamente procesada sin aditivos|O|O||D||1
50111540|Rana, mínimamente procesada con aditivos|O|O||D||1
50111541|Caracol de tierra, mínimamente procesada sin aditivos|O|O||D||1
50111542|Caracol de tierra,  mínimamente procesada con aditivos|O|O||D||1
50111543|Culebra, mínimamente procesada sin aditivos|O|O||D||1|Víbora, mínimamente procesada sin aditivos
50111544|Culebra,  mínimamente procesada con aditivos|O|O||D||1|Víbora, mínimamente procesada con aditivos
50111545|Tortuga, mínimamente procesada sin aditivos|O|O||D||1
50111546|Tortuga, mínimamente procesada con aditivos|O|O||D||1
50111547|Bisonte o búfalo, mínimamente procesada sin aditivos|O|O||D||1
50111548|Bisonte o búfalo, mínimamente procesada con aditivos|O|O||D||1
50111549|Llama o alpaca, mínimamente procesada sin aditivos|O|O||D||1
50111550|Llama o alpaca, mínimamente procesada con aditivos|O|O||D||1
50111551|Ganso, mínimamente procesada sin aditivos|O|O||D||1
50111552|Ganso, , mínimamente procesada con aditivos|O|O||D||1
50111553|Avestruz, mínimamente procesada sin aditivos|O|O||D||1
50111554|Avestruz, mínimamente procesada con aditivos|O|O||D||1
50111555|Jabalí, mínimamente procesada sin aditivos|O|O||D||1
50111556|Jabalí, mínimamente procesada con aditivos|O|O||D||1
50111557|Venado, mínimamente procesada sin aditivos|O|O||D||1
50111558|Venado, mínimamente procesada con aditivos|O|O||D||1
50111559|Faisán, mínimamente procesada sin aditivos|O|O||D||1
50111560|Faisán, mínimamente procesada con aditivos|O|O||D||1
50111561|Codorniz, mínimamente procesada sin aditivos|O|O||D||1
50111562|Codorniz, mínimamente procesada con aditivos|O|O||D||1
50112000|Carnes procesadas y preparadas|O|O||D||1
50112004|Carne, procesada sin aditivos|O|O||D||1
50112005|Carne, procesada con aditivos|O|O||D||1
50112006|Ternera. procesada sin aditivos|O|O||D||1
50112007|Ternera, procesada con aditivos|O|O||D||1
50112008|Cerdo, procesado sin aditivos|O|O||D||1|Chanchos, procesado sin aditivos, Cochinillos, procesado sin aditivos, Cochinos, procesado sin aditivos, Cuche , procesado sin aditivos, Cuinos, procesado sin aditivos, Gorrinos, procesado sin aditivos, Lechones, procesado sin aditivos, Marranos, procesado sin aditivos, Porcinos, procesado sin aditivos, Puercos, procesado sin aditivos,Lechones, procesado sin aditivos
50112009|Cerdo, procesado con aditivos|O|O||D||1|Chanchos, procesado con aditivos, Cochinillos, procesado con aditivos, Cochinos, procesado con aditivos, Cuche , procesado con aditivos, Cuinos, procesado con aditivos, Gorrinos, procesado con aditivos, Jamón de cerdo, Lechones, procesado con aditivos, Marranos, procesado con aditivos, Porcinos, procesado con aditivos, Puercos, procesado con aditivos, , Jamón de cerdo
50112010|Pollo, procesado sin aditivos|O|O||D||1|Gallina, procesado sin aditivos
50112011|Pollo, procesado con aditivos|O|O||D||1|Gallina, procesado con aditivos
50112012|Pavo, procesado sin aditivos|O|O||D||1
50112013|Pavo, procesado con aditivos|O|O||D||1|Jamón de pavo
50112014|Cordero, procesado sin aditivos|O|O||D||1
50112015|Cordero, procesado con aditivos|O|O||D||1
50112016|Chivo. procesado sin aditivos|O|O||D||1
50112017|Chivo, procesado con aditivos|O|O||D||1
50112018|Carne especializada, procesada sin aditivo|O|O||D||1
50112019|Carne especializada, procesada con aditivo|O|O||D||1
50112020|Aves especializadas, procesada sin aditivos|O|O||D||1
50112021|Aves especializadas, procesada con aditivos|O|O||D||1
50112022|Carne especializada mixta, procesada sin aditivos|O|O||D||1
50112023|Carne especializada mixta, procesada con aditivos|O|O||D||1
50112024|Pato, procesado con aditivos|O|O||D||1
50112025|Pato, procesado sin aditivos|O|O||D||1
50112026|Caballo, procesado sin aditivos|O|O||D||1|Equino, procesado sin aditivos
50112027|Caballo, procesado con aditivos|O|O||D||1|Equino, procesado con aditivos
50112028|Conejo, procesado sin aditivos|O|O||D||1
50112029|Conejo, procesado con aditivos|O|O||D||1
50112030|Rana, procesado sin aditivos|O|O||D||1
50112031|Rana, procesado con aditivos|O|O||D||1
50112032|Caracol de tierra, procesado sin aditivos|O|O||D||1
50112033|Caracol de tierra, procesado con aditivo|O|O||D||1
50112034|Culebra, procesado, sin aditivos|O|O||D||1|Víbora, procesado, sin aditivos
50112035|Culebra, procesado con aditivos|O|O||D||1|Víbora, procesado con aditivos
50112036|Tortuga, procesada sin aditivos|O|O||D||1
50112037|Tortuga, procesada con aditivos|O|O||D||1
50112038|Visón  o búfalo, procesado sin aditivos|O|O||D||1
50112039|Visón  o búfalo, procesado con aditivos|O|O||D||1
50112040|Llama o alpaca, procesado sin aditivos|O|O||D||1
50112041|Llama o alpaca, procesado con aditivos|O|O||D||1
50112042|Ganso, procesado sin aditivos|O|O||D||1
50112043|Ganso, procesado con aditivos|O|O||D||1
50112044|Avestruz, procesado sin aditivos|O|O||D||1
50112045|Avestruz, procesado con aditivos|O|O||D||1
50112046|Jabalí, procesado sin aditivos|O|O||D||1
50112047|Jabalí, procesado con aditivos|O|O||D||1
50112048|Venado, procesado sin aditivos|O|O||D||1
50112049|Venado, procesado con aditivos|O|O||D||1
50112050|Faisán,  procesado sin aditivos|O|O||D||1
50112051|Faisán, procesado con aditivos|O|O||D||1
50112052|Codorniz, procesado sin aditivos|O|O||D||1
50112053|Codorniz, procesado con aditivos|O|O||D||1
50121500|Pescado|O|O||D||1
50121537|Pescado congelado|O|O||D||1
50121538|Pescado almacenado en repisa|O|O||D||1|Atún enlatado, Salmón enlatado, Sardina enlatad
50121539|Pescado fresco|O|O||D||1
50121600|Marisco fresco|O|O||D||1
50121611|Mariscos frescos|O|O||D||1
50121612|Mariscos congelados|O|O||D||1
50121613|Mariscos almacenados en repisa|O|O||D||1
50121700|Invertebrados acuáticos|O|O||D||1
50121705|Invertebrados acuáticos frescos|O|O||D||1|Almejas, Ostiones, Pulpo
50121706|Invertebrados acuáticos congelados|O|O||D||1|Almejas, Ostiones, Pulpo
50121707|Invertebrados acuáticos almacenado en repisa|O|O||D||1|Almejas, Ostiones, Pulpo
50121800|Plantas acuáticas|O|O||D||1
50121802|Plantas acuáticas frescas|O|O||D||1
50121803|Plantas acuáticas congeladas|O|O||D||1
50121804|Plantas acuáticas almacenadas en repisa|O|O||D||1
50121900|Pescados y mariscos preservados en sal|O|O||D||1
50121901|Pulpo en escabeche|O|O||D||1
50121902|Huevos de abadejo salado|O|O||D||1
50121903|Camarón salado|O|O||D||1
50131600|Huevos y sustitutos|O|O||D||1
50131609|Huevos preparados|O|O||D||1
50131612|Huevos en la cascara de gallina|O|O||D||1|Huevos de gallina en cáscara
50131613|Huevos en la cascara  de pato|O|O||D||1|Huevos de pato en cáscara
50131614|Huevos en la cascara de emú|O|O||D||1|Huevos de emú en cáscara
50131615|Huevos en la cascara de ganso|O|O||D||1|Huevos de ganso en cáscara
50131616|Huevos en la cascara de gallineta|O|O||D||1|Huevos de gallina de guinea en cáscara
50131617|Huevos en la cascara de avestruz|O|O||D||1|Huevos de avestruz en cáscara
50131618|Huevos en la cascara codorniz|O|O||D||1|Huevos de codorniz en cáscara
50131619|Huevos en la cascara de ñandú|O|O||D||1|Huevos de ñandú en cáscara
50131620|Huevos en la cascara de paloma|O|O||D||1|Huevos de paloma en cáscara
50131621|Huevos en la cascara de pavo|O|O||D||1|Huevos de pavo en cáscara
50131622|Huevos en la cascara de pájaros especializados|O|O||D||1|Huevos de otras aves en cáscara
50131623|Huevos con cascara sin clasificación de gallina|O|O||D||1|Huevos criollos de gallina en cáscara (nido)
50131624|Huevos con cascara sin clasificación de aves que son distintas de gallina|O|O||D||1|Huevos criollos de otras aves en cáscara (nido)
50131625|Huevos industriales revisados y sucios de gallina|O|O||D||1|Huevos sucios de gallina
50131626|Huevos industriales revisados y sucios que son distintas de gallina|O|O||D||1|Huevos sucios de otras aves
50131627|Huevos cocidos de gallina|O|O||D||1
50131628|Huevos cocidos distintos de gallina|O|O||D||1
50131629|Productos derivados de huevos y sustitutos de gallina|O|O||D||1
50131630|Huevos de gallina deshidratados|O|O||D||1
50131631|Productos derivados de huevos y sustitutos de aves distinto a gallina|O|O||D||1
50131632|Huevos distinto a gallina deshidratados|O|O||D||1
50131633|Extracto de huevo de gallina|O|O||D||1
50131634|Extracto de huevo de aves distinto a gallina|O|O||D||1
50131635|Imitación de huevo|O|O||D||1
50131700|Productos de leche y mantequilla|O|O||D||1|Productos lácteos y mantequilla
50131701|Productos de leche o mantequilla frescos|O|O||D||1|Crema, Crema de leche, Lácteos probióticos, Nata, Suero de mantequilla, Yogurt
50131702|Productos de leche o mantequilla de estante|O|O||D||1|Crema, Leche condensada, Leche evaporada, Leche maternizada, Leche saborizada, Lácteos probióticos, Nata, Suero de mantequilla, YogurtNata
50131703|Productos de leche o mantequilla congelados|O|O||D||1|Base para helado, Mantecado
50131704|Leche en polvo|O|O||D||1
50131705|Proteína de suero de leche|O|O||D||1
50131706|Lactosa|O|O||D||1|Leche cruda, Leche de otros animales, Leche de vaca, Leche fresca ,
50131800|Queso|O|O||D||1
50131801|Queso natural|O|O||D||1
50131802|Queso procesado|O|O||D||1
50131803|Imitación de queso|O|O||D||1
50151500|Grasas y aceites vegetales comestibles|O|O||D||1
50151513|Aceites vegetales o  de planta comestibles|O|O||D||1|Aceite de ajonjolí, Aceite de canola (colza), Aceite de coco, Aceite de cártamo, Aceite de girasol, Aceite de linaza, Aceite de maíz, Aceite de olivo (oliva), Aceite de soya, Margarina,Aceite de maíz
50151514|Grasas saturadas de vegetales o plantas comestibles|O|O||D||1
50151515|Leche de soya|O|O||D||1
50151600|Grasas y aceites animales comestibles|O|O||D||1
50151604|Aceites animal comestibles|O|O||D||1|Animales marinos, Hígado de bacalao
50151605|Grasa saturada animal comestibles|O|O||D||1|Manteca, Sebo
50161500|Chocolates, azúcares, edulcorantes productos|O|O||D||1
50161509|Azucares naturales o productos endulzantes|O|O||D||1|Azúcar moscabada o morena, Inulina de maguey o agave, Piloncill
50161510|Endulzantes artificiales|O|O||D||1|Azúcar refinada, Edulcorantes artificiales, Sustitutos de azúca
50161511|Chocolate o sustituto de chocolate|O|O||D||1
50161512|Almíbar|O|O||D||1|Jarabe
50161800|Productos de confitería|O|O||D||1|Dulces de confite
50161813|Chocolate o sustituto de chocolate, confite|O|O||D||1
50161814|Azúcar o sustituto de azúcar, confite|O|O||D||1
50161815|Goma de mascar|O|O||D||1
50161900|Productos de azúcar|O|O||D||1
50171500|Hierbas y especias y extractos|O|O||D||1|Especias o extractos
50171548|Hierbas frescas|O|O||D||1
50171550|Especies o extractos|O|O||D||1|Ajo molido, Anís, Azafrán, Canela, Cebolla molida, Clavo de olor, Comino, Curry, Cúrcuma, Hierbas de olor, Pimienta, Tomillo, Comino
50171551|Sal de mesa|O|O||D||1
50171552|Mezcla para adobar|O|O||D||1
50171553|Polvo de pimentón rojo|O|O||D||1|Chile piquín molido,2
50171554|Tallo de hierbas y semillas para infusiones|O|O||D||1
50171700|Vinagres y vinos de cocinar|O|O||D||1
50171707|Vinagres|O|O||D||1
50171708|Vinos para cocinar|O|O||D||1
50171800|Salsas y condimentos y productos para untar|O|O||D||1
50171830|Salsas o condimentos o cremas de untar o marinados|O|O||D||1|Aderezo de mayonesa, Mayonesa, Mostaza, 13
50171831|Salsas para cocinar|O|O||D||1
50171832|Salsas para ensaladas o dips|O|O||D||1|Cátsup, Queso amarillo para fundir, Salsa de tomate, Salsa picante
50171833|Cremas de untar saladas o patés|O|O||D||1
50171834|Pasta de frijol chino|O|O||D||1
50171900|Salmuera y salsa y aceitunas|O|O||D||1
50171901|Encurtidos|O|O||D||1|Aceitunas, Cebollitas, Chiles en vinagre, Elotitos, Zanahorias baby,-1
50171902|Condimento|O|O||D||1
50171904|Conserva|O|O||D||1|Conservas de frutas,-1
50172000|Productos de fríjol de soya fermentados|O|O||D||1
50172001|Salsa soya|O|O||D||1
50172002|Pasta de pimientos picantes basada en soya|O|O||D||1
50172003|Pasta de frijol de soya|O|O||D||1
50172004|Pasta mixta basada en soya|O|O||D||1
50172005|Mejoo o frijol de soya fermentado|O|O||D||1
50172006|Queso de soya|O|O||D||1
50181700|Suministros y mezclas para hornear|O|O||D||1
50181708|Mezclas para hornear|O|O||D||1|Harinas para repostería, Levadura en polvo, , -
50181709|Suministros para hornear|O|O||D||1|Empaques, Envolturas, Moldes,
50181900|Pan, galletas y pastelitos dulces|O|O||D||1
50181901|Pan fresco|O|O||D||1|Bigotes, Bolillos, Bísquets, Cemitas, Churros, Cocoles, Conchas, Cuernitos, Donas, Orejas, Pan de feria, Pan de muerto, Conchas, Pan integral, Pan salado, Panquecitos, Roscas de reyes, Teleras, Trenzas,
50181902|Pan congelado|O|O||D||1|Pan congelado precocido
50181903|Galletas sencillas de sal|O|O||D||1
50181904|Pan seco o cascaras de pan o pan tostado ( crotones)|O|O||D||1
50181905|Galletas de dulce|O|O||D||1|Surtido de galletas
50181906|Pan de repisa|O|O||D||1|Bigotes, Bolillos, Bísquets, Cemitas, Churros, Cocoles, Conchas, Cuernitos, Donas, Orejas, Pan de feria, Pan de muerto, Conchas, Pan integral, Pan salado, Panquecitos, Roscas de reyes, Teleras, Trenzas,
50181907|Maza congelada para galletas|O|O||D||1|Masa congelada para galletas
50181908|Maza congelada para pan|O|O||D||1|Masa congelada para pan
50181909|Galletas de soda|O|O||D||1|Galletas horneadas saladas
50182000|Tartas y empanadas y pastas|O|O||D||1
50182001|Ponqués pasteles o biscochos frescos|O|O||D||1|Panqués y pasteles frescos
50182002|Ponqués pasteles o biscochos congelados|O|O||D||1|Panqués y pasteles congelados
50182003|Maza para pastelería congelada|O|O||D||1|Masa para pastelería congelada
50182004|Maza para galletas de soda congelada|O|O||D||1|Masa para galletas de soda congelada
50182005|Galletas de arroz|O|O||D||1
50191500|Sopas y estofados|O|O||D||1
50191505|Sopas o sudados preparados fresco|O|O||D||1|Estofados preparados frescos, Sopa de verduras
50191506|Sopas o sudados preparados congelados|O|O||D||1|Estafados preparados congelados
50191507|Sopas o sudados preparados de repisa|O|O||D||1|Estofados preparados de repisa
50192100|Botanas|O|O||D||1|Dulces tradicionales mexicanos
50192109|Papas fritas de talego o mezclas|O|O||D||1|Botanas surtidas
50192110|Nueces o fruta disecada|O|O||D||1|Nueces y frutas secas
50192111|Carne seca o procesada|O|O||D||1
50192112|Maíz pira|O|O||D||1|Maíz palomero, Maíz para palomitas, Palomitas de maí
50192113|Mariscos y filete de pescado seco|O|O||D||1
50192300|Postres y decoraciones de postres|O|O||D||1
50192301|Postres preparados|O|O||D||1|Flanes, Fresas con crema, Gelatina
50192302|Complementos de postres|O|O||D||1
50192303|Helado de sabor o helado o postre de helado o yogurt congelado|O|O||D||1|Cubos de hielo de sabores, Paletas de hielo
50192304|Conos o copas de helado comestibles|O|O||D||1
50192400|Mermeladas y gelatinas y pastas de untar de nuez y dulce y conservas de fruta|O|O||D||1
50192401|Mermeladas o preservativos de fruta|O|O||D||1|Mermeladas, jaleas o conservas de fruta
50192402|Mantequilla de nueces o mixto|O|O||D||1|Mantequilla de nueces mixtas
50192403|Miel|O|O||D||1|Miel de abeja, Miel de agave, Miel de mague
50192404|Cristales de gelatina o mermelada|O|O||D||1|Grenetina, Polvo para preparar flan, Polvo para preparar gelatin
50192405|Gelatina real procesada|O|O||D||1|Productos procesados de jalea real
50192406|Gelatina de almidón de nuez|O|O||D||1|Jaleas de bellotas
50192500|Sándwiches y panecillos con relleno|O|O||D||1|Bocadillos
50192501|Emparedados frescos|O|O||D||1|Bocadillos frescos, Sándwiches frescos
50192502|Emparedados congelados|O|O||D||1|Bocadillos congelados, Sándwiches congelados
50192503|Rellenos frescos para emparedados|O|O||D||1|Rellenos frescos para bocadillos, Rellenos frescos para sándwiches
50192504|Rellenos congelados para emparedados|O|O||D||1|Rellenos congelados para bocadillos, Rellenos congelados para sándwiches
50192600|Acompañamientos preparados|O|O||D||1
50192601|Papas preparadas frescas o arroz o pasta o relleno|O|O||D||1
50192602|Papas preparadas y congeladas o arroz o pasta o relleno|O|O||D||1
50192603|Papas preparadas de repisa o arroz o pasta o relleno|O|O||D||1
50192700|Platos combinados empaquetados|O|O||D||1
50192701|Comidas combinadas frescas|O|O||D||1
50192702|Comidas combinadas congeladas|O|O||D||1
50192703|Comidas combinadas de repisa|O|O||D||1
50192800|Empanadas y quiches y pasteles|O|O||D||1
50192801|Pasteles de sal frescos|O|O||D||1|Empanadas frescas, Pastes frescos
50192802|Pasteles de sal congelados|O|O||D||1|Empanadas congeladas, Pastes congelados
50192803|Pasteles de sal de repisa|O|O||D||1|Empanadas de repisa, Pastes de repisa
50192900|Pasta o tallarines natural|O|O||D||1
50192901|Pasta sencilla o fideos|O|O||D||1
50192902|Pasta o fideos de repisa|O|O||D||1
50193000|Bebidas y Comidas Infantiles|O|O||D||1
50193001|Comida para infante|O|O||D||1|Alimentos infantiles
50193002|Bebidas para infantes|O|O||D||1|Bebidas infantiles
50193100|Materiales y mezclas instantáneas|O|O||D||1|Arcones navideños, Despensas básicas
50193101|Mezcla de botanas instantáneas|O|O||D||1|Pastas para elaborar botanas
50193102|Mezcla  de postres|O|O||D||1|Ingredientes preparados para postres
50193103|Mezcla de salsa|O|O||D||1|Ingredientes preparados para salsas
50193104|Base para sopas|O|O||D||1|Caldillo de tomate, Caldo de camarón, Caldo de pollo, Caldo de res, Consome de pollo, Cremas, Pure de tomate, Sazonadores, Pure de tomate
50193105|Mezcla para rebosar o de pan|O|O||D||1|Empanizadores
50193106|Puré instantáneo|O|O||D||1
50193107|Puré de papa instantáneo|O|O||D||1
50193108|Puré preparado de varios vegetales|O|O||D||1
50193200|Ensaladas preparadas|O|O||D||1
50193201|Ensalada fresca preparada|O|O||D||1
50193202|Ensalada preparada congelada|O|O||D||1
50193203|Ensalada fresca de repisa|O|O||D||1
50201700|Café y té|O|O||D||1
50201706|Café|O|O||D||1|Café molido
50201707|Sustituto de café|O|O||D||1
50201708|Bebida de café|O|O||D||1
50201709|Café instantáneo|O|O||D||1|Café soluble
50201710|Té de hoja|O|O||D||1
50201711|Té instantáneo|O|O||D||1
50201712|Bebidas de té|O|O||D||1
50201713|Bolsas de té|O|O||D||1|Sobres de té
50201714|Cremas no lácteas|O|O||D||1
50201715|Té de frutas|O|O||D||1
50202200|Bebidas alcohólicas|O|O||D||1|Bebidas fermentadas y destiladas, Pulque
50202201|Cerveza|O|O||D||1
50202202|Cidra|O|O||D||1|Sidra
50202203|Vino|O|O||D||1
50202204|Vino fortificado|O|O||D||1
50202205|Vino espumoso|O|O||D||1
50202206|Licor destilado|O|O||D||1|Aguardiente o charanda, Brandy, Coñac, Ginebra, Licor de cocuy, Mezcal, Ron, Tequila, Vodka, Whisky,Ron
50202207|Cocteles de alcohol o bebidas mixtas|O|O||D||1
50202208|Takju - vino de arroz coreano|O|O||D||1
50202209|Soju - bebida destilada de grano|O|O||D||1
50202210|Vino de arroz|O|O||D||1
50202300|Bebidas no alcohólicas|O|O||D||1
50202301|Agua|O|O||D||1|Agua embotellada, Agua potable, Agua purificad
50202302|Hielo|O|O||D||1
50202303|Jugos congelados|O|O||D||1
50202304|Jugos de repisa|O|O||D||1|Jugos de fruta naturales o con conservadores envasados
50202305|Jugo fresco|O|O||D||1
50202306|Refrescos|O|O||D||1
50202307|Bebida de chocolate o malta u otros|O|O||D||1
50202308|Cocteles libre de alcohol o mezcla de bebidas|O|O||D||1
50202309|Bebidas deportivas o de energía|O|O||D||1
50202310|Agua mineral|O|O||D||1
50202311|Bebida mixta de polvo|O|O||D||1|Concentrados y jarabes para preparar bebidas saborizadas, Polvo de sabores para preparar aguas
50202400|Jugos o concentrados de cítricos frescos|O|O||D||1
50202401|Jugo de mandarina clementina|O|O||D||1
50202403|Jugo de kumquat|O|O||D||1|Jugo de naranjos chinos (kumquats)
50202404|Jugo de limón|O|O||D||1
50202405|Jugo de limón amarillo|O|O||D||1
50202406|Jugo de lima|O|O||D||1
50202407|Jugo de mandarina|O|O||D||1
50202408|Jugo de tangelo minneola|O|O||D||1|Jugo de mandarina y pomelo (minneola)
50202409|Jugo de naranja|O|O||D||1
50202410|Jugo de pomelo|O|O||D||1|Jugo de toronja
50202411|Jugo de satsuma|O|O||D||1|Jugo de tangerina satsuma
50202412|Jugo de tangelo|O|O||D||1
50202413|Jugo de tangerina|O|O||D||1
50202414|Jugo de temple|O|O||D||1|Jugo de mandarina royal
50202415|Jugo de ugli|O|O||D||1|Jugo de mandarina y pomelo (ugli)
50202416|Concentrado de mandarina clementina|O|O||D||1
50202418|Concentrado de kumquat|O|O||D||1|Concentrado de naranjos chinos (kumquats)
50202419|Concentrado de limón|O|O||D||1
50202420|Concentrado de limón amarillo|O|O||D||1
50202421|Concentrado de mandarina|O|O||D||1
50202422|Concentrado de minneola|O|O||D||1|Concentrado de mandarina y pomelo (minneola)
50202423|Concentrado de naranja|O|O||D||1
50202424|Concentrado de pomelo|O|O||D||1|Concentrado de toronja
50202425|Concentrado de satsuma|O|O||D||1|Concentrado de tangerina satsuma
50202426|Concentrado de tangelo|O|O||D||1
50202427|Concentrado de mandarina|O|O||D||1
50202428|Concentrado de temple|O|O||D||1|Concentrado de mandarina royal
50202429|Concentrado de ugli|O|O||D||1|Concentrado de mandarina y pomelo (ugli)
50202500|Jugos o concentrados de bayas frescas|O|O||D||1
50202501|Concentrado de mora|O|O||D||1
50202502|Concentrado de agras|O|O||D||1|Concentrado de frutos azules del bosque
50202503|Concentrado de arándano|O|O||D||1|Concentrado de arándano rojo
50202504|Concentrado de uva|O|O||D||1
50202505|Concentrado de frambuesa|O|O||D||1
50202506|Concentrado de fresa|O|O||D||1
50202507|Jugo de boysenberry|O|O||D||1|Jugo de zarzamora boysen
50202508|Jugo de grosella|O|O||D||1
50202509|Jugo de mora|O|O||D||1
50202510|Jugo de agras|O|O||D||1|Jugo de frutos azules del bosque
50202511|Jugo de frambuesa|O|O||D||1
50202512|Jugo de fresa|O|O||D||1
50202513|Jugo de uva|O|O||D||1
50202600|Jugos o concentrados de especies con pepitas frescas|O|O||D||1
50202601|Jugo de manzana|O|O||D||1
50202602|Jugo de pera|O|O||D||1
50202700|Jugos o concentrados de especies con una semilla grande frescas|O|O||D||1
50202701|Jugo de albaricoque|O|O||D||1|Jugo de chabacano
50202702|Jugo de cereza|O|O||D||1
50202703|Jugo de nectarina|O|O||D||1
50202704|Jugo de durazno|O|O||D||1
50202705|Jugo de ciruela|O|O||D||1
50202706|Jugo de ciruela pasa|O|O||D||1
50202800|Jugos o concentrados de especies tropicales frescas|O|O||D||1
50202801|Concentrado de crema de coco|O|O||D||1
50202802|Concentrado de fruta de kiwi|O|O||D||1|Concentrado de kiwi
50202803|Concentrado de mango|O|O||D||1
50202804|Concentrado de maracuyá|O|O||D||1
50202805|Concentrado de piña|O|O||D||1
50202806|Concentrado de carambola|O|O||D||1|Concentrado de fruta de estrella
50203000|Jugos o concentrados de melones frescos|O|O||D||1
50203001|Concentrado de cantalupo|O|O||D||1|Concentrado de melón cantalupo
50203002|Concentrado de melón honeydrew|O|O||D||1|Concentrado de melón verde
50203003|Concentrado de melón|O|O||D||1
50211502|Cigarrillos o cigarros|O|O||D||1
50211503|Tabaco para pipa o tabaco de hoja|O|O||D||1
50211504|Tabaco para mascar|O|O||D||1
50211505|Cigarrillos herbales|O|O||D||1
50211506|Rapé|O|O||D||1|Tabaco para aspirar
50211600|Productos, suministros y accesorios para tabaco|O|O||D||1
50211607|Papel para cigarrillos o filtros|O|O||D||1|Papel de liar
50211608|Encendedores o mecha|O|O||D||1
50211609|Pipas para fumar|O|O||D||1
50211610|Limpiadores de tabaco para pipas|O|O||D||1
50211611|Juego de fumador|O|O||D||1
50211612|Encendedores para cigarrillos|O|O||D||1
50221000|Legumbres|O|O||D||1
50221001|Granos|O|O||D||1
50221002|Harina|O|O||D||1
50221100|Cereales|O|O||D||1|Granola, Muesli
50221101|Grano de cereal|O|O||D||1
50221102|Grano de harina|O|O||D||1
50221200|Cereales procesados|O|O||D||1
50221201|Cereal caliente o listo para comer|O|O||D||1
50221202|Barras de desayuno o de salud|O|O||D||1|Barras nutritivas
50221300|Harina y productos de molinos|O|O||D||1|Masa, Mole en pasta, Mole en polvo, Nixtamal, Tortillas de harina, Tortillas de maíz, Tortillas de maíz azul, Tortillas de nopal, Tortillas integrales, Tostadas, Tostadas de maíz horneadas, Totopos, Tortillas de maíz azul
50221301|Harina vegetal|O|O||D||1
50221302|Malta de cebada|O|O||D||1
50221303|Almidón o harina comestible|O|O||D||1|Harina de fécula de maíz, Maicena
50221304|Harina de papa|O|O||D||1
50301500|Manzanas|O|O||D||1
50301501|Manzanas akane|O|O||D||1|Manzana akane
50301502|Manzana ambrosia|O|O||D||1
50301503|Manzanas api|O|O||D||1|Manzana api
50301504|Manzanas baldwin|O|O||D||1|Manzana baldwin
50301505|Manzanas brabum|O|O||D||1|Manzana brabum
50301506|Manzanas bramley|O|O||D||1|Manzana bramley
50301507|Manzana joven bramley|O|O||D||1
50301508|Manzana calville blanche d’hiver|O|O||D||1
50301509|Manzana cameo|O|O||D||1
50301510|Manzana charles ross|O|O||D||1
50301511|Manzana codlin|O|O||D||1
50301512|Manzana cortland|O|O||D||1
50301513|Manzana costard|O|O||D||1
50301514|Manzana court pendu plat|O|O||D||1
50301515|Manzana  cox´s orange pippin|O|O||D||1
50301516|Manzana crab|O|O||D||1
50301517|Manzana crispin|O|O||D||1
50301518|Manzana delicious|O|O||D||1
50301519|Manzana duchess|O|O||D||1
50301520|Manzana earlidorado|O|O||D||1
50301521|Manzana early mcintosh|O|O||D||1
50301522|Manzana elstar|O|O||D||1
50301523|Manzana imperio|O|O||D||1
50301524|Manzana flor de kent|O|O||D||1
50301525|Manzana fuji|O|O||D||1
50301526|Manzana gala|O|O||D||1
50301527|Manzana gascoyne´s scarlet|O|O||D||1
50301528|Manzana gilliflower|O|O||D||1
50301529|Manzana ginger dorado|O|O||D||1
50301530|Manzana gladstone|O|O||D||1
50301531|Manzana gloster|O|O||D||1
50301532|Manzana dorado supreme|O|O||D||1
50301533|Manzana dorado delicious|O|O||D||1
50301534|Manzana dorado nobel|O|O||D||1
50301535|Manzana granny smith|O|O||D||1
50301536|Manzana gravenstain|O|O||D||1
50301537|Manzana greening|O|O||D||1
50301538|Manzana greensleeves|O|O||D||1
50301539|Manzana honeycrisp|O|O||D||1
50301540|Manzana howgate wonder|O|O||D||1
50301541|Manzana rojo ida|O|O||D||1
50301542|Manzana james grives|O|O||D||1
50301543|Manzana jersey mac|O|O||D||1
50301544|Manzana jester|O|O||D||1
50301545|Manzana jonadorado|O|O||D||1
50301546|Manzana jonamac|O|O||D||1
50301547|Manzana  jonathan|O|O||D||1
50301548|Manzana katy|O|O||D||1
50301549|Manzana kidd´s orange rojo|O|O||D||1
50301550|Manzana dama|O|O||D||1
50301551|Manzana ley de roma|O|O||D||1
50301552|Manzana laxton|O|O||D||1
50301553|Manzana lord derby|O|O||D||1
50301554|Manzana macoun|O|O||D||1
50301555|Manzana mcintosh|O|O||D||1
50301556|Manzana mutsu|O|O||D||1
50301557|Manzana newtown pippin|O|O||D||1
50301558|Manzana northen spy|O|O||D||1
50301559|Manzana orleans reinette|O|O||D||1
50301560|Manzana ozark dorado|O|O||D||1
50301561|Manzana pacific rose|O|O||D||1
50301562|Manzana paula rojo|O|O||D||1
50301563|Manzana peamain|O|O||D||1
50301564|Manzana dama rosada|O|O||D||1
50301565|Manzana pippin|O|O||D||1
50301566|Manzana pitmaston piña|O|O||D||1
50301567|Manzana pomme dápi|O|O||D||1
50301568|Manzana prime dorado|O|O||D||1
50301569|Manzana rojo astrachan|O|O||D||1
50301570|Manzana rojo boscoop|O|O||D||1
50301571|Manzana  jefe rojo|O|O||D||1
50301572|Manzana rojo delecioso|O|O||D||1
50301573|Manzana rojo gravenstain|O|O||D||1
50301574|Manzana roma roja|O|O||D||1
50301575|Manzana rojo stayman|O|O||D||1
50301576|Manzana rojo york|O|O||D||1
50301577|Manzana reinette|O|O||D||1
50301578|Manzana bellesa de roma|O|O||D||1
50301579|Manzana russet|O|O||D||1
50301580|Manzana  belleza sierra|O|O||D||1
50301581|Manzana spartan|O|O||D||1
50301582|Manzana stark crimson|O|O||D||1
50301583|Manzana starrey|O|O||D||1
50301584|Manzana stayman|O|O||D||1
50301585|Manzana stayman winesap|O|O||D||1
50301586|Manzana summer rambo|O|O||D||1
50301587|Manzana tsugaru|O|O||D||1
50301588|Manzanaveine onzas|O|O||D||1
50301589|Manzana tydeman rojo|O|O||D||1
50301590|Manzana vistabella|O|O||D||1
50301591|Manzana weatley|O|O||D||1
50301592|Manzana blanco joanetine|O|O||D||1
50301593|Manzana blanco transparente|O|O||D||1
50301594|Manzana winesap|O|O||D||1
50301595|Manzana worcester|O|O||D||1
50301596|Manzana york imperial|O|O||D||1
50301597|Manzana anna|O|O||D||1
50301600|Albaricoques|O|O||D||1|Chabacanos
50301601|Abaricoques ambercot|O|O||D||1|Chabacano ambercot
50301602|Albaricoques apache|O|O||D||1|Chabacano apache
50301603|Albaricoques brittany dorado|O|O||D||1|Chabacano brittany dorado
50301604|Albaricoque negro|O|O||D||1|Chabacano negro
50301605|Albaricoque blenheim|O|O||D||1|Chabacano blenheim
50301606|Albaricoque bonny|O|O||D||1|Chabacano bonny
50301607|Albaricoque biluda|O|O||D||1|Chabacano biluda
50301608|Albaricoque castlebrite|O|O||D||1|Chabacano castlebrite
50301609|Albaricoque  clutha dorado|O|O||D||1|Chabacano clutha dorado
50301610|Albaricoque clutha sun|O|O||D||1|Chabacano clutha sun
50301611|Albaricoque derby royal|O|O||D||1|Chabacano derby royal
50301612|Albaricoque dina|O|O||D||1|Chabacano dina
50301613|Albaricoque earlicot|O|O||D||1|Chabacano earlicot
50301614|Albaricoque earliman|O|O||D||1|Chabacano earliman
50301615|Albaricoque early bright|O|O||D||1|Chabacano early bright
50301616|Albaricoque  flaming dorado|O|O||D||1|Chabacano flaming dorado
50301617|Albaricoque frenso|O|O||D||1|Chabacano frenso
50301618|Albaricoque dorado bright|O|O||D||1|Chabacano dorado bright
50301619|Albaricoque doradobar|O|O||D||1|Chabacano doradobar
50301620|Albaricoque doradoen sweet|O|O||D||1|Chabacano doradoen sweet
50301621|Albaricoque doradorich|O|O||D||1|Chabacano dorado rich
50301622|Albaricoque helena|O|O||D||1|Chabacano helena
50301623|Albaricoque honeycot|O|O||D||1|Chabacano honey cot
50301624|Albaricoque imperial|O|O||D||1|Chabacano imperial
50301625|Albaricoque jordanne|O|O||D||1|Chabacano jordanne
50301626|Albaricoque jumbo cot|O|O||D||1|Chabacano jumbo cot
50301627|Albaricoque kandy kot|O|O||D||1|Chabacano kandy kot
50301628|Albaricoque katy|O|O||D||1|Chabacano katy
50301629|Albaricoque rey|O|O||D||1|Chabacano rey
50301630|Albaricoque lambertin|O|O||D||1|Chabacano lambertin
50301631|Albaricoque loma|O|O||D||1|Chabacano loma
50301632|Albaricoque lulu belle|O|O||D||1|Chabacano lulu belle
50301633|Albaricoque modesto|O|O||D||1|Chabacano modesto
50301634|Albaricoque moorpark|O|O||D||1|Chabacano moorpark
50301635|Albaricoque orangerojo|O|O||D||1|Chabacano orange rojo
50301636|Albaricoque palstein|O|O||D||1|Chabacano palstein
50301637|Albaricoque patterson|O|O||D||1|Chabacano patterson
50301638|Albaricoque perfection|O|O||D||1|Chabacano perfection
50301639|Albaricoque poppy|O|O||D||1|Chabacano poppy
50301640|Albaricoque poppycot|O|O||D||1|Chabacano poppy cot
50301641|Albaricoque queen|O|O||D||1|Chabacano queen
50301642|Albaricoque riland|O|O||D||1|Chabacano riland
50301643|Albaricoque rival|O|O||D||1|Chabacano rival
50301644|Albaricoque robada|O|O||D||1|Chabacano robada
50301645|Albaricoque royal|O|O||D||1|Chabacano royal
50301646|Albaricoque  royal blenheim|O|O||D||1|Chabacano royal blenheim
50301647|Albaricoque  royal orange|O|O||D||1|Chabacano royal orange
50301648|Albaricoque sundrop|O|O||D||1|Chabacano sundrop
$sat$, E'[\r\n]+') as l
 where l ~ '^[0-9]{8}[|]'
on conflict (clave) do update set descripcion=excluded.descripcion, incluir_iva=excluded.incluir_iva,
  incluir_ieps=excluded.incluir_ieps, complemento=excluded.complemento, vigente_desde=excluded.vigente_desde,
  vigente_hasta=excluded.vigente_hasta, franja_fronteriza=excluded.franja_fronteriza, palabras_similares=excluded.palabras_similares;
commit;
