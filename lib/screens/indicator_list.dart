// ✅ Pantalla moderna para mostrar la lista de indicadores (versión final SIBA)
// ----------------------------------------------------------------------------
// Esta versión mantiene tu diseño moderno PERO ahora sí guarda correctamente
// el progreso en SharedPreferences usando las llaves creadas en IndicatorDetail.
//
// Explicación corta:
// - Los indicadores marcados quedan guardados.
// - Cuando vuelves a entrar ya aparecen marcados.
// - Se lee directamente lo que guardó IndicatorDetail.
// - El diseño sigue igual de elegante que el que te gustó.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'indicator_detail.dart';

class IndicatorList extends StatefulWidget {
  final String category;
  final String categoryTitle;
  final String species;

  const IndicatorList({
    Key? key,
    required this.category,
    required this.categoryTitle,
    required this.species,
  }) : super(key: key);

  @override
  State<IndicatorList> createState() => _IndicatorListState();
}

class _IndicatorListState extends State<IndicatorList> {
  // ✅ Indicadores por categoría y especie (Porcinos y Aves)
  final Map<String, Map<String, List<String>>> speciesIndicators = {
    'porcinos': {
      'recursos': [
        'Estado de los Comederos',
        'Acceso al Agua (flujo)',
        'Estado de limpieza de los bebederos',
        'Altura de los bebederos',
        'Número de bebederos por animal',
        'Protección ante condiciones ambientales',
        'Ventilación',
        'Iluminación',
        'Superficie de descanso',
        'Resguardo para lechones',
        'Espacio disponible para cerdas',
        'Jaulas de libre acceso y/o muros de ocultación para cerdas en corrales',
        'Jaulas adecuadas al tamaño de la cerda',
        'Espacio disponible para verracos',
        'Espacio disponible para precebo, ceba y reemplazos',
        'Inspección de los animales',
        'Instalaciones y elementos para manejo',
        'Material de enriquecimiento',
      ],
      'animal': [
        'Condición Corporal',
        'Heces sobre el cuerpo',
        'Jadeo y/o Temblores',
        'Amonotonamiento (animales tumbados alojados en grupo)',
        'Heridas en el cuerpo',
        'Uso de material de enriquecimiento',
        'Relación Humano – Animal',
      ],
      'gestion': [
        'Identificación de animales',
        'Dietas balanceadas con registro ICA',
        'Alimentaciones adaptadas a necesidades fisiológicas',
        'Ayuno antes del transporte',
        'Plan de contingencia para falta de agua y alimento',
        'Plan para desastres naturales',
        'Plan Sanitario (Prevención, Diagnóstico)',
        'Programas oficiales del ICA',
        'Enfermedades de declaración obligatoria',
        'Tratamiento de animales enfermos',
        'Buenas prácticas de uso de medicamentos',
        'Registro de Mortalidad - Lechones',
        'Registro de Mortalidad - Hembras de cría',
        'Registro de Mortalidad - Precebos y Ceba',
        'Procedimiento de manejo de los animales',
        'Prácticas dolorosas – descolmille y/o limado de colmillos',
        'Prácticas dolorosas – descole',
        'Castración inmunológica y/o castración quirúrgica',
        'Intervenciones quirúrgicas por personal adecuado',
        'Capacitación del personal que realiza sacrificio humanitario o eutanasia',
        'Procedimiento para el sacrificio humanitario',
        'Capacitación del personal en manejo de cerdos, reproducción, salud y bienestar animal'
      ],
    },
    'aves': {
      'recursos': [
        'Estado e integridad de las jaulas/nidales',
        'Calidad de los comederos',
        'Acceso y funcionamiento de bebederos',
        'Calidad de la cama',
        'Confort térmico (ventiladores/cortinas)',
        'Iluminación (fotoperiodo)',
        'Densidad de población',
        'Calidad del agua de bebida',
        'Limpieza y desinfección de instalaciones',
      ],
      'animal': [
        'Estado y limpieza del plumaje',
        'Condición corporal',
        'Presencia de jadeo',
        'Amontonamiento',
        'Lesiones cutáneas (picoteo/heridas)',
        'Deformidad del hueso de la quilla',
        'Pododermatitis',
        'Estado de los ojos y fosas nasales',
        'Integridad del pico',
      ],
      'gestion': [
        'Registros de mortalidad',
        'Plan sanitario (vacunación/desparasitación)',
        'Plan de contingencia',
        'Procedimiento de eutanasia / sacrificio humanitario',
        'Capacitación del personal',
        'Registro de tratamientos veterinarios y tiempo de retiro',
        'Ayuno pre-transporte',
      ],
    }
  };

  // ✅ Normalizar especie (Porcinos -> porcinos, Aves de Postura -> aves)
  String get normSpecies => widget.species.toLowerCase().contains('aves') ? 'aves' : 'porcinos';

  // ✅ Estado de los indicadores completados
  Map<String, bool> doneStatus = {};

  @override
  void initState() {
    super.initState();
    _loadFromPreferences();
  }

  // ✅ Carga desde SharedPreferences lo que ya está hecho
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, bool> temp = {};

    final items = speciesIndicators[normSpecies]?[widget.category] ?? [];

    for (String ind in items) {
      final key = "${normSpecies}_${widget.category}_$ind";
      final exist = prefs.getString(key); // Si existe → ya tiene resultado
      temp[ind] = (exist != null);
    }

    setState(() => doneStatus = temp);
  }

  // ✅ Animación cuando el usuario marca/desmarca manualmente
  void _toggleDone(String indicatorName) {
    setState(() {
      doneStatus[indicatorName] = !(doneStatus[indicatorName] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = speciesIndicators[normSpecies]?[widget.category] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263F30),
        elevation: 0,
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final indicator = items[index];
          final isDone = doneStatus[indicator] ?? false;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone ? const Color(0xFF496B4D).withOpacity(0.4) : const Color(0xFFE8ECE6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

              // ✅ Ícono de estado
              leading: GestureDetector(
                onTap: () => _toggleDone(indicator),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? const Color(0xFF263F30) : Colors.white,
                    border: Border.all(
                      color: isDone ? const Color(0xFF263F30) : const Color(0xFFE8ECE6),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle_outlined,
                    color: isDone ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ),

              // ✅ Título del indicador
              title: Text(
                indicator,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isDone ? FontWeight.w400 : FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  color: isDone ? Colors.grey.shade500 : const Color(0xFF353A35),
                ),
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF7A8279),
              ),

              onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IndicatorDetail(
                        indicatorName: indicator,
                        category: widget.category,
                        species: widget.species,
                      ),
                    ),
                  );

                  // ✅ Si IndicatorDetail devolvió TRUE porque guardó un resultado
                  if (result == true) {
                    _loadFromPreferences(); // Volver a leer SharedPreferences
                  }
                },
              ),
            );
          },
        ),
      );
    }
}
