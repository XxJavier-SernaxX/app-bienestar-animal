// ✅ Pantalla moderna de detalle del indicador (SIBA)
// ---------------------------------------------------------------
// Explicación estudiante:
// Esta pantalla sirve para evaluar un indicador.
// El usuario elige una calificación (100, 55, 20, 0 puntos).
// También puede tomar una foto como evidencia.
// Al final guarda todo en la memoria del celular (SharedPreferences) y en la base de datos local.

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';

class IndicatorDetail extends StatefulWidget {
  final String indicatorName;
  final String category;
  final String species;

  const IndicatorDetail({
    Key? key,
    required this.indicatorName,
    required this.category,
    required this.species,
  }) : super(key: key);

  @override
  State<IndicatorDetail> createState() => _IndicatorDetailState();
}

class _IndicatorDetailState extends State<IndicatorDetail> {
  int? selectedScore;   // ✅ La calificación escogida
  File? _image;         // ✅ Foto tomada
  final TextEditingController _observationsController = TextEditingController();

  // ✅ Tabla de puntuaciones personalizada para Porcinos
  final Map<String, Map<int, String>> porcinoScores = {
    'Estado de los Comederos': {
      100: 'Todos los comederos limpios y sin riesgo de contaminación.',
      55: 'Más del 50% limpios y sin riesgo.',
      0: 'Hasta el 50% limpios y/o con riesgo de contaminación.',
    },
    'Acceso al Agua (flujo)': {
      100: 'Cumple el 100% de los bebederos.',
      55: 'Cumple entre 75% y menos del 100%.',
      20: 'Cumple entre más del 50% y menos del 75%.',
      0: 'Cumple hasta el 50%.',
    },
    'Estado de limpieza de los bebederos': {
      100: 'Todos limpios.',
      55: 'Hasta el 25% sucios.',
      20: 'Más del 25% y hasta el 50% sucios.',
      0: 'Más del 50% sucios.',
    },
    'Altura de los bebederos': {
      100: 'Todos los bebederos a la altura correcta.',
      55: 'Más del 50% a la altura correcta.',
      20: 'Hasta el 50% a la altura correcta.',
      0: 'Ninguno a la altura correcta.',
    },
    'Número de bebederos por animal': {
      100: '1 bebedero por cada 10 animales y al menos 2 disponibles por animal.',
      80: '1 bebedero por cada 10 animales, pero sin 2 disponibles por animal.',
      55: 'Número insuficiente, pero con 2 bebederos por animal.',
      20: 'Número insuficiente y sin 2 bebederos por animal.',
    },
    'Protección ante condiciones ambientales': {
      100: 'Todos los animales protegidos adecuadamente.',
      55: 'Más del 50% protegidos adecuadamente.',
      20: 'Hasta el 50% protegidos adecuadamente.',
      0: 'Ninguno protegido adecuadamente.',
    },
    'Ventilación': {
      100: 'Ventilación correcta en todos los sitios registrados o evaluados.',
      55: 'Hasta 10% de sitios evaluados con ventilación incorrecta.',
      20: 'Mayor de 10% hasta 25% con ventilación incorrecta.',
      0: 'Más del 25% con ventilación incorrecta.',
    },
    'Iluminación': {
      100: 'En todos los sitios evaluados se cumplen los dos indicadores.',
      55: 'Hasta en el 10% no se cumplen ambos.',
      20: 'Hasta en el 25% no se cumplen ambos.',
      0: 'En más del 25% no se cumplen ambos.',
    },
    'Superficie de descanso': {
      100: 'Cumple.',
      0: 'No cumple.',
    },
    'Resguardo para lechones': {
      100: 'Cumple.',
      0: 'No cumple.',
    },
    'Espacio disponible para cerdas': {
      100: 'Todas las cerdas cuentan con espacio adecuado según normativa.',
      55: 'Más del 50% cuenta con espacio adecuado.',
      20: 'Hasta el 50% cuenta con espacio adecuado.',
      0: 'Ninguna cuenta con espacio adecuado.',
    },
    'Jaulas de libre acceso y/o muros de ocultación para cerdas en corrales': {
      100: 'Todas las jaulas y muros cumplen con los criterios de libre acceso y ocultación.',
      55: 'Más del 50% cumplen con los criterios.',
      20: 'Hasta el 50% cumplen con los criterios.',
      0: 'Ninguna cumple con los criterios.',
    },
    'Jaulas adecuadas al tamaño de la cerda': {
      100: 'Cumple.',
      0: 'No cumple.',
    },
    'Espacio disponible para verracos': {
      100: 'Corrales > 7,2 m² y ancho > 2,64 m. / Jaulas > 2,88 m largo y > 0,84 m ancho.',
      55: 'Corrales 6–7,2 m² y ancho 2,2–2,64 m. / Jaulas 2,4–2,88 m largo y 0,7–0,84 m ancho.',
      0: 'Corrales < 6 m² o ancho < 2,2 m / Jaulas < 2,4 m largo o < 0,7 m ancho.',
    },
    'Espacio disponible para precebo, ceba y reemplazos': {
      100: 'K ≥ 0.040',
      55: '0.034 ≤ K ≤ 0.039',
      0: 'K ≤ 0.033',
    },
    'Inspección de los animales': {
      100: 'En todas las zonas se pueden inspeccionar correctamente los animales.',
      55: 'En una zona no se cumple.',
      20: 'En dos zonas no se cumple.',
      0: 'En más de dos zonas no se cumple.',
    },
    'Instalaciones y elementos para manejo': {
      100: 'Cumple (manejo sin lesiones).',
      0: 'No cumple.',
    },
    'Material de enriquecimiento': {
      100: 'Cumple (acceso permanente a material de enriquecimiento adecuado).',
      0: 'No cumple.',
    },
    'Condición Corporal': {
      100: '<10% con condición 2 y <10% con condición 1.',
      55: '10–20% con condición 2 y 10–15% con condición 1.',
      20: '10–20% con condición 2 y 15–20% con condición 1.',
      0: '>20% con condición 1 y/o >20% con condición 2.',
    },
    'Heces sobre el cuerpo': {
      100: 'Hasta 2,5% de animales sucios (cerdas/verracos) o 10% camadas (lechones) o 6% (precebo/ceba).',
      55: 'Entre 2,5–10% (cerdas/verracos) o 10–20% (lechones) o 6–16% (precebo/ceba).',
      20: '10–15% (cerdas/verracos) o 20–30% (lechones) o 16–60% (precebo/ceba).',
      0: '>15% (cerdas/verracos) o >30% (lechones) o >60% (precebo/ceba).',
    },
    'Jadeo y/o Temblores': {
      100: '0% de animales con jadeos o temblores.',
      55: '≤8% de animales afectados.',
      0: '>8% de animales afectados.',
    },
    'Amontonamiento': {
      100: '0% de animales amontonados.',
      55: '≤20% amontonados.',
      0: '>20% amontonados.',
    },
    'Heridas en el cuerpo': {
      100: '≤5% con lesiones graves.',
      55: '>5% y ≤15% con lesiones graves.',
      20: '>15% y ≤20% con lesiones graves.',
      0: '>20% con lesiones graves.',
    },
    'Uso de material de enriquecimiento': {
      100: '≥50% usan el material.',
      80: '≥40% usan el material.',
      55: '≥30% usan el material.',
      20: '≥20% usan el material.',
      0: '<20% usan el material.',
    },
    'Relación Humano–Animal': {
      100: '≤10% con puntuación 2 (cerdas) o 0% grupos (ceba).',
      55: '>10% y ≤20% (cerdas) o <35% grupos (ceba).',
      20: '35–75% de grupos con puntuación 2 (ceba).',
      0: '>20% (cerdas) o ≥75% (ceba).',
    },
    'Identificación de animales': {
      100: 'Identificación mediante métodos aceptados (chapetas, tatuajes, marcado en frío, radiofrecuencia).',
      0: 'Identificación con métodos que causan lesión o pérdida de parte sensible (muescas, hierro caliente, etc.).',
    },
    'Dietas balanceadas con registro ICA': {
      100: 'Dieta comercial con registro ICA.',
      55: 'Dieta no comercial con documento de nutricionista, zootecnista o médico veterinario zootecnista.',
      0: 'Dieta no comercial sin documento de nutricionista, zootecnista o médico veterinario zootecnista.',
    },
    'Alimentaciones adaptadas a necesidades fisiológicas': {
      100: 'Se cumplen los 5 aspectos indicados en la descripción.',
      55: 'Se cumplen 4 aspectos indicados en la descripción.',
      20: 'Se cumplen 3 aspectos indicados en la descripción.',
      0: 'Se cumplen menos de 3 aspectos y/o se encuentran alimentos vencidos.',
    },
    'Ayuno antes del transporte': {
      100: 'Se dispone de registro y se respetan los tiempos en todos los casos.',
      0: 'No se respetan los tiempos o no se dispone de registros.',
    },
    'Plan de contingencia para falta de agua y alimento': {
      100: 'Se dispone del protocolo documentado y cumple con los requisitos.',
      0: 'No se dispone del protocolo documentado.',
    },
    'Plan para desastres naturales': {
      100: 'Se dispone de plan de contingencia documentado y conocimiento del mismo por parte del personal.',
      0: 'No se dispone de plan de contingencia o el personal no lo conoce.',
    },
    'Plan Sanitario (Prevención, Diagnóstico)': {
      100: 'Predio con plan sanitario documentado, actualizado y elaborado por MV o MVZ con matrícula vigente.',
      0: 'No se cuenta con plan sanitario documentado o vigente.',
    },
    'Programas oficiales del ICA': {
      100: 'Cumple con los programas oficiales del ICA y cuenta con RUV y chapeta vigente.',
      0: 'No cumple con los programas oficiales del ICA o carece de documentación requerida.',
    },
    'Enfermedades de declaración obligatoria': {
      100: 'Se informa inmediatamente al ICA y se cuenta con instructivo visible y personal capacitado.',
      0: 'No se informa al ICA o no existe instructivo visible y comprendido por el personal.',
    },
    'Tratamiento de animales enfermos': {
      100: 'Los animales enfermos se identifican, aíslan y tratan oportunamente según protocolo documentado.',
      0: 'No se evidencia identificación, aislamiento o tratamiento adecuado de los animales enfermos.',
    },
    'Buenas prácticas de uso de medicamentos': {
      100: 'Cumple con todas las buenas prácticas del uso de medicamentos: productos con registro ICA, sin sustancias prohibidas, vigencia controlada, respeto del tiempo de retiro, registro de tratamientos firmado por MV/MVZ, prescripción profesional, almacenamiento adecuado, no uso de antimicrobianos como promotores, instrumentos limpios y disposición correcta de residuos.',
      0: 'No cumple con las buenas prácticas del uso de medicamentos o presenta faltas en alguno de los puntos verificados.',
    },
    'Registro de Mortalidad - Lechones': {
      100: '0% - <10%',
      80: '10% - <11%',
      55: '11% - <12%',
      20: '12% - ≤13%',
      0: '>13%',
    },
    'Registro de Mortalidad - Hembras de cría': {
      100: '0% - <5%',
      80: '5% - <6%',
      55: '6% - <10%',
      20: '10% - ≤12%',
      0: '>12%',
    },
    'Registro de Mortalidad - Precebos y Ceba': {
      100: 'Precebo: 0% - ≤2%, Ceba: 0% - ≤1%',
      55: 'Precebo: 2.1% – 3.8%, Ceba: 1.1% - 2.8%',
      20: 'Precebo: >3.8% - 5%, Ceba: >2.8% - 4.5%',
      0: 'Precebo: >5%, Ceba: >4.5%',
    },
    'Procedimiento de manejo de los animales': {
      100: 'Existe procedimiento documentado que describe movilización y arreo sin brusquedad, prohibición de elementos lesivos y técnicas correctas de sujeción según etapa productiva.',
      0: 'No existe procedimiento documentado o no contiene los elementos mínimos requeridos.',
    },
    'Prácticas dolorosas – descolmille y/o limado de colmillos': {
      100: 'No se realiza descolmille o limado de colmillos, o se hace limado selectivo por personal capacitado.',
      55: 'Se realiza limado de colmillos rutinario por personal capacitado o corte selectivo por personal capacitado.',
      0: 'Se realiza corte rutinario o cualquier práctica por personal no capacitado.',
    },
    'Prácticas dolorosas – descole': {
      100: 'No se realiza descole, o se realiza con uso de anestesia y analgesia por personal capacitado y avalado por MV/MVZ con documento justificativo.',
      55: 'Se realiza descole antes de los siete días sin anestesia ni analgesia, por personal capacitado y avalado por MV/MVZ con documento justificativo.',
      0: 'Se realiza corte de cola sin anestesia ni analgesia después de los siete días de vida o por personal no capacitado o sin documento justificativo.',
    },
    'Castración inmunológica y/o castración quirúrgica': {
      100: 'No se realiza castración quirúrgica, o se realiza castración inmunológica siguiendo las instrucciones del rotulado, o castración quirúrgica con anestesia y analgesia por personal capacitado y avalado por el MV o MVZ.',
      55: 'Se realiza castración quirúrgica sin anestesia ni analgesia antes de los siete días de vida por personal capacitado y avalado por el MV o MVZ.',
      0: 'Se realiza castración inmunológica sin seguir las instrucciones del rotulado, o castración quirúrgica a más de siete días sin anestesia ni analgesia o por personal no capacitado o no avalado por el MV o MVZ.',
    },
    'Intervenciones quirúrgicas por personal adecuado': {
      100: 'Todas las intervenciones quirúrgicas, tanto menores como mayores, se realizan por MV o MVZ con matrícula profesional vigente, o por personal entrenado con competencias demostrables, bajo protocolos de analgesia y/o anestesia aprobados.',
      0: 'Las intervenciones quirúrgicas no se realizan por personal adecuado o no cumplen con los protocolos de analgesia and anestesia requeridos.',
    },
    'Capacitación del personal que realiza sacrificio humanitario o eutanasia': {
      100: 'Todo el personal que realiza sacrificio humanitario o eutanasia está debidamente capacitado y/o autorizado por un MV o MVZ con matrícula profesional vigente, y cuenta con registro o certificación de dicha capacitación.',
      0: 'No se cuenta con registro o certificación de capacitación del personal que realiza sacrificio humanitario o eutanasia.',
    },
    'Procedimiento para el sacrificio humanitario': {
      100: 'Se cumplen todos los descriptores: existe procedimiento documentado acorde con la OMSA, se cuentan con los elementos adecuados en buen estado y se llevan registros completos.',
      55: 'Se cumplen dos descriptores del indicador.',
      20: 'Se cumple un descriptor del indicador.',
      0: 'No se cumple ningún descriptor del indicador.',
    },
    'Capacitación del personal en manejo de cerdos, reproducción, salud y bienestar animal': {
      100: 'Todo el personal está capacitado en manejo, reproducción, salud y bienestar animal, cuenta con registro o certificado de formación y demuestra conocimiento al ser entrevistado.',
      0: 'El personal no cuenta con capacitación, registro o conocimientos suficientes sobre manejo, reproducción, salud o bienestar animal.',
    },
  };

  // ✅ Tabla de puntuaciones personalizada para Aves de Postura
  final Map<String, Map<int, String>> avesScores = {
    'Estado e integridad de las jaulas/nidales': {
      100: 'Todas las jaulas y nidales limpios, en buen estado, sin alambres salientes ni filos que lesionen.',
      55: 'Más del 80% de las jaulas/nidales en buen estado.',
      20: 'Entre 50% y 80% de las jaulas/nidales en buen estado.',
      0: 'Menos del 50% de las jaulas/nidales en buen estado, o presencia de riesgos graves de atrapamiento/lesión.',
    },
    'Calidad de los comederos': {
      100: 'Comederos limpios, con alimento suficiente y bien distribuido, sin desperdicio ni contaminación.',
      55: 'Más del 80% de los comederos en condiciones óptimas.',
      0: 'Menos del 50% limpios o con presencia de hongos/humedad.',
    },
    'Acceso y funcionamiento de bebederos': {
      100: 'Bebederos 100% funcionales, con flujo constante y limpios.',
      55: 'Entre 75% y 99% funcionales y limpios.',
      20: 'Entre 50% y 74% funcionales y limpios.',
      0: 'Menos del 50% de bebederos funcionales o sin flujo de agua.',
    },
    'Calidad de la cama': {
      100: 'Cama suelta, seca, limpia y con profundidad adecuada (sin apelmazamiento).',
      55: 'Cama con ligera humedad en menos del 20% del área.',
      20: 'Cama apelmazada o húmeda en 20% a 50% del área.',
      0: 'Cama totalmente apelmazada, húmeda o con costra en más del 50% del área.',
    },
    'Confort térmico (ventiladores/cortinas)': {
      100: 'Temperatura y ventilación adecuadas. Sistemas de cortinas o ventiladores funcionando al 100%.',
      55: 'Leves desviaciones de temperatura sin signos visibles de estrés en aves.',
      0: 'Fallas en ventilación/cortinas o signos evidentes de estrés térmico generalizado.',
    },
    'Iluminación (fotoperiodo)': {
      100: 'Intensidad de luz uniforme y fotoperiodo adecuado según la etapa productiva (registros al día).',
      55: 'Zonas con sombras o ligeras fallas en temporizadores/registros.',
      0: 'Luz inadecuada o ausencia total de fotoperiodo controlado.',
    },
    'Densidad de población': {
      100: 'Densidad óptima que cumple la norma técnica ICA para el sistema (jaula o piso).',
      55: 'Densidad ligeramente alta, pero sin afectar la movilidad de las aves.',
      0: 'Hacinamiento evidente, las aves no pueden desplazarse o extender las alas.',
    },
    'Calidad del agua de bebida': {
      100: 'Agua potable tratada (clorada entre 1-3 ppm), con análisis físico-químico y microbiológico al día.',
      55: 'Agua tratada pero con registros desactualizados o nivel de cloro fuera de rango.',
      0: 'Agua sin tratamiento ni desinfección o análisis microbiológico positivo.',
    },
    'Limpieza y desinfección de instalaciones': {
      100: 'Instalaciones y alrededores limpios, sin acumulación de estiércol ni vectores (moscas/roedores).',
      55: 'Presencia leve de vectores o retraso en retiro de estiércol.',
      0: 'Deficiente higiene, alta infestación de moscas/roedores o acumulación excesiva de humedad.',
    },
    'Estado y limpieza del plumaje': {
      100: 'Plumaje limpio, completo y sin parásitos externos en más del 90% del lote.',
      55: 'Pérdida moderada de plumaje (cuello/pecho) en 10-25% del lote.',
      20: 'Pérdida severa de plumaje o suciedad en 25-50% del lote.',
      0: 'Más del 50% del lote con plumaje deficiente, sucio o con presencia de parásitos.',
    },
    'Condición corporal': {
      100: 'Menos del 5% del lote con baja condición corporal (aves flacas/desnutridas).',
      55: 'Entre 5% y 15% de aves del lote con baja condición corporal.',
      20: 'Entre 15% y 25% con baja condición corporal.',
      0: 'Más del 25% de las aves evaluadas con desnutrición severa.',
    },
    'Presencia de jadeo': {
      100: '0% de aves con signos de jadeo.',
      55: 'Menos del 10% de aves jadeando.',
      0: 'Más del 10% de aves jadeando (estrés térmico severo).',
    },
    'Amontonamiento': {
      100: 'Aves distribuidas uniformemente en el galpón o jaulas.',
      55: 'Leve amontonamiento en esquinas o zonas específicas sin asfixia.',
      0: 'Amontonamiento severo con riesgo de asfixia o aplastamiento.',
    },
    'Lesiones cutáneas (picoteo/heridas)': {
      100: 'Menos del 5% del lote con heridas o picoteo de cloaca/piel.',
      55: 'Entre 5% y 15% de aves con lesiones o picoteo leve.',
      20: 'Entre 15% y 30% de aves con lesiones visibles.',
      0: 'Más del 30% de las aves con heridas abiertas o canibalismo activo.',
    },
    'Deformidad del hueso de la quilla': {
      100: 'Menos del 5% de aves con quilla desviada o fracturada.',
      55: 'Entre 5% y 15% de aves con deformidad de quilla.',
      20: 'Entre 15% y 30% con deformidad de quilla.',
      0: 'Más del 30% de las aves con deformidades o fracturas palpables.',
    },
    'Pododermatitis': {
      100: '0% a 5% de aves con lesiones en las almohadillas plantares.',
      55: 'Entre 5% y 15% de aves con lesiones o callos plantares leves.',
      0: 'Más del 15% de aves con pododermatitis severa o cojera.',
    },
    'Estado de los ojos y fosas nasales': {
      100: 'Ojos limpios, brillantes y fosas nasales secas (0% de secreción).',
      55: 'Menos del 10% de aves con secreción ocular/nasal leve.',
      0: 'Más del 10% de aves con conjuntivitis, hinchazón facial o disnea.',
    },
    'Integridad del pico': {
      100: 'Picos íntegros o con despique correcto (rombo y cicatrizado), sin dolor ni deformidades.',
      55: 'Despique deficiente (desuniforme) en menos del 15% de las aves.',
      0: 'Picos severamente lesionados, crecimiento excesivo o despique deficiente en más del 15%.',
    },
    'Registros de mortalidad': {
      100: 'Registros de mortalidad diarios al día, causa identificada y disposición correcta de cadáveres.',
      55: 'Registros incompletos o retraso de pocos días en la actualización.',
      0: 'Sin registros de mortalidad o disposición inadecuada de cadáveres.',
    },
    'Plan sanitario (vacunación/desparasitación)': {
      100: 'Plan sanitario al día, firmado por MV/MVZ, vacunas oficiales aplicadas y registradas.',
      0: 'Sin plan sanitario documentado o incumplimiento de vacunas obligatorias.',
    },
    'Plan de contingencia': {
      100: 'Planes documentados para corte de energía/agua y desastres naturales, y personal capacitado.',
      0: 'Sin plan de contingencia escrito ni planta eléctrica de respaldo funcional.',
    },
    'Procedimiento de eutanasia / sacrificio humanitario': {
      100: 'Protocolo de eutanasia escrito basado en bienestar animal, equipos adecuados y personal capacitado.',
      0: 'Sin protocolo escrito, uso de métodos crueles o personal no capacitado.',
    },
    'Capacitación del personal': {
      100: '100% del personal con certificación o registro de capacitación en bienestar avícola.',
      55: 'Capacitación parcial o en proceso de renovación.',
      0: 'Personal sin capacitación demostrable en bienestar animal.',
    },
    'Registro de tratamientos veterinarios y tiempo de retiro': {
      100: 'Registros de tratamientos veterinarios completos, recetas médicas y respeto estricto del tiempo de retiro.',
      0: 'Sin registros de tratamientos o no se respeta el tiempo de retiro en huevos.',
    },
    'Ayuno pre-transporte': {
      100: 'Tiempos de ayuno pre-transporte (retiro de alimento pero no de agua) programados y registrados correctamente.',
      0: 'Sin registros de ayuno o privación de agua innecesaria antes del transporte.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSavedResult();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  // ✅ Cargar resultado guardado desde SharedPreferences
  Future<void> _loadSavedResult() async {
    final prefs = await SharedPreferences.getInstance();
    final normSpecies = widget.species.toLowerCase().contains('aves') ? 'aves' : 'porcinos';
    final key = "${normSpecies}_${widget.category}_${widget.indicatorName}";
    final dataStr = prefs.getString(key);
    if (dataStr != null) {
      final data = jsonDecode(dataStr);
      setState(() {
        selectedScore = data['puntos'];
        if (data['foto'] != null && data['foto'] != '') {
          _image = File(data['foto']);
        }
        if (data['observaciones'] != null) {
          _observationsController.text = data['observaciones'];
        }
      });
    }
  }

  // ✅ Tomar foto desde la cámara
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() => _image = File(photo.path));
    }
  }

  // ✅ Eliminar foto
  void _deletePhoto() {
    setState(() => _image = null);
  }

  // ✅ Guardar calificación, observaciones y foto
  Future<void> _saveResult() async {
    if (selectedScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una calificación antes de guardar")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final normSpecies = widget.species.toLowerCase().contains('aves') ? 'aves' : 'porcinos';
    final key = "${normSpecies}_${widget.category}_${widget.indicatorName}";

    final result = {
      "indicador": widget.indicatorName,
      "categoria": widget.category,
      "puntos": selectedScore,
      "foto": _image?.path,
      "observaciones": _observationsController.text.trim(),
    };

    await prefs.setString(key, jsonEncode(result));

    // ✅ Guardar en SQLite para que aparezca en Resultados
    final response = {
      'indicatorId': widget.indicatorName.toLowerCase().replaceAll(' ', '_'),
      'indicatorTitle': widget.indicatorName,
      'score': selectedScore,
      'timestamp': DateTime.now().toIso8601String(),
      'observaciones': _observationsController.text.trim(),
      'species': widget.species,
      'photo': _image?.path,
    };
    await DatabaseHelper.instance.insertResponse(response);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Resultado guardado")),
    );

    Navigator.pop(context, true); // ✅ Marca como hecho en IndicatorList
  }

  @override
  Widget build(BuildContext context) {
    final normSpecies = widget.species.toLowerCase().contains('aves') ? 'aves' : 'porcinos';
    final scoreLabels = (normSpecies == 'aves' ? avesScores[widget.indicatorName] : porcinoScores[widget.indicatorName]) ??
        {100: 'Cumple', 55: 'Más del 50% cumple', 0: 'No cumple'};

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.indicatorName),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------
            // ✅ TÍTULO
            // ----------------------------------------------------------
            Text(
              "Selecciona una calificación:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),

            const SizedBox(height: 15),

            // ----------------------------------------------------------
            // ✅ TARJETAS MODERNAS PARA CALIFICACIONES
            // ----------------------------------------------------------
            ...scoreLabels.entries.map((entry) {
              final score = entry.key;
              final text = entry.value;
              final isSelected = selectedScore == score;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.08),
                    )
                  ],
                ),
                child: InkWell(
                  onTap: () => setState(() => selectedScore = score),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.white : Colors.teal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "$score puntos — $text",
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // ✅ FOTO
            // ----------------------------------------------------------
            Text(
              "Evidencia fotográfica:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            const SizedBox(height: 12),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.08),
                  )
                ],
                image: _image != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_image!),
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.25),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),

              child: Stack(
                children: [
                  if (_image == null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey.shade500),
                          const SizedBox(height: 10),
                          Text(
                            "Aún no hay foto",
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 16),
                          )
                        ],
                      ),
                    ),

                  // ✅ Botón tomar foto
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Tomar foto"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ),

                  // ✅ Botón eliminar foto
                  if (_image != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton.icon(
                        onPressed: _deletePhoto,
                        icon: const Icon(Icons.delete),
                        label: const Text("Eliminar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------------
            // ✅ OBSERVACIONES
            // ----------------------------------------------------------
            Text(
              "Observaciones (opcional):",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí tus observaciones...',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 35),

            // ----------------------------------------------------------
            // ✅ BOTÓN GUARDAR
            // ----------------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Guardar resultado",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
