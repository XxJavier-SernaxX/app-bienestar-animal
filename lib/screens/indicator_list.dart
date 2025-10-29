// lib/screens/indicator_list.dart
import 'package:flutter/material.dart';
import '../utils/storage.dart';
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
  // Mapa de indicadores por categoría
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

  // Para marcar los indicadores hechos
  Map<String, bool> doneStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDoneStatus();
  }

  Future<void> _loadDoneStatus() async {
    final saved = await StorageHelper.getResults();
    setState(() {
      for (var result in saved) {
        doneStatus[result['indicador']] = true;
      }
    });
  }

  Future<void> _markAsDone(String indicatorName) async {
    setState(() {
      doneStatus[indicatorName] = !(doneStatus[indicatorName] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = indicators[widget.category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isDone = doneStatus[item] ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: Checkbox(
                value: isDone,
                onChanged: (val) {
                  _markAsDone(item);
                },
              ),
              title: Text(item),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IndicatorDetail(
                      indicatorName: item,
                      category: widget.category,
                    ),
                  ),
                );

                // 🔹 Si la pantalla de detalle devuelve true, marcar automáticamente como hecho
                if (result == true) {
                  setState(() {
                    doneStatus[item] = true;
                  });
                }

                _loadDoneStatus(); // sigue actualizando desde SharedPreferences
              },
            ),
          );
        },
      ),
    );
  }
}
