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
  // ✅ Indicadores por categoría
  final Map<String, List<String>> indicators = {
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
  };

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

    for (String ind in indicators[widget.category]!) {
      final key = "${widget.category}_$ind";
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
    final items = indicators[widget.category]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 3,
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final indicator = items[index];
          final isDone = doneStatus[indicator] ?? false;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 10),

                // ✅ Ícono animado a la izquierda
                leading: GestureDetector(
                  onTap: () => _toggleDone(indicator),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.teal : Colors.white,
                      border: Border.all(
                        color: isDone ? Colors.teal : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.circle_outlined,
                      color: isDone ? Colors.white : Colors.grey.shade600,
                      size: 26,
                    ),
                  ),
                ),

                // ✅ Título del indicador
                title: Text(
                  indicator,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isDone ? Colors.grey : Colors.black,
                  ),
                ),

                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 20, color: Colors.teal),

                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IndicatorDetail(
                        indicatorName: indicator,
                        category: widget.category,
                      ),
                    ),
                  );

                  // ✅ Si IndicatorDetail devolvió TRUE porque guardó un resultado
                  if (result == true) {
                    _loadFromPreferences(); // Volver a leer SharedPreferences
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
