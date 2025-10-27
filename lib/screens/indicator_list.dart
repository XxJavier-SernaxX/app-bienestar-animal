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
      'Estado de los comederos',
      'Acceso y calidad del agua',
      'Condiciones del alojamiento',
      'Iluminación',
      'Ventilación',
      'Densidad animal',
    ],
    'animal': [
      'Condición corporal',
      'Lesiones cutáneas',
      'Cojeras',
      'Conducta social y agresividad',
      'Mortalidad y morbilidad',
    ],
    'gestion': [
      'Registros sanitarios',
      'Capacitación del personal',
      'Protocolos de bioseguridad',
      'Manejo de animales enfermos',
      'Transporte y sacrificio',
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IndicatorDetail(
                      indicatorName: item,
                      category: widget.category,
                    ),
                  ),
                ).then((_) => _loadDoneStatus()); // actualiza después de volver
              },
            ),
          );
        },
      ),
    );
  }
}
