// lib/screens/indicator_detail.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IndicatorDetail extends StatefulWidget {
  final String indicatorName;
  final String category;

  const IndicatorDetail({
    Key? key,
    required this.indicatorName,
    required this.category,
  }) : super(key: key);

  @override
  State<IndicatorDetail> createState() => _IndicatorDetailState();
}

class _IndicatorDetailState extends State<IndicatorDetail> {
  int? selectedScore;
  File? _image;

  // === Tabla de puntuaciones personalizadas por indicador ===
  final Map<String, Map<int, String>> indicatorScores = {
    // ---- RECURSOS ----
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

    // ---- ANIMAL ----
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
    //GESTION
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
      0: 'Las intervenciones quirúrgicas no se realizan por personal adecuado o no cumplen con los protocolos de analgesia y anestesia requeridos.',
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

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _image = File(photo.path));
    }
  }

  Future<void> _saveResult() async {
  if (selectedScore == null) return;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${widget.category}_${widget.indicatorName}';
  final result = {
    'score': selectedScore,
    'photo': _image?.path,
  };

  prefs.setString(key, jsonEncode(result));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Resultado guardado correctamente ✅')),
  );

  // 🔹 Devuelve true al cerrar, para indicar que se guardó
  Navigator.pop(context, true);
}

  @override
  Widget build(BuildContext context) {
    final scoreLabels = indicatorScores[widget.indicatorName] ??
        {100: 'Cumple completamente', 55: 'Más del 50% cumple', 0: 'No cumple'};
    return Scaffold(
      appBar: AppBar(title: Text(widget.indicatorName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccione una calificación:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...scoreLabels.entries.map((entry) {
              return RadioListTile<int>(
                title: Text('${entry.key} puntos - ${entry.value}'),
                value: entry.key,
                groupValue: selectedScore,
                onChanged: (value) => setState(() => selectedScore = value),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              Image.file(_image!, height: 150, fit: BoxFit.cover),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveResult,
              child: const Text('Guardar resultado'),
            ),
          ],
        ),
      ),
    );
  }
}
