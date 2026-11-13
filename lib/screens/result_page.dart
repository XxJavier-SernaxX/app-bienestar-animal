// ✅ ResultsPage — Versión moderna y conectada a la base de datos (SQLite)
// ---------------------------------------------------------------
// Explicación simple:
// Esta pantalla muestra TODOS los resultados guardados dentro de la base
// de datos, incluyendo:
//  ✅ Nombre del indicador
//  ✅ Puntaje obtenido
//  ✅ Observaciones
//  ✅ Foto tomada (si hay)
//
// También calcula el promedio general y te lo muestra arriba con un estilo
// visual fácil de entender (verde, amarillo, naranja o rojo).

import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class ResultsPage extends StatefulWidget {
  final String species;

  const ResultsPage({super.key, required this.species});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> resultados = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // ✅ Cargar datos desde la base de datos SQLite
  Future<void> _loadResults() async {
    final data = await DatabaseHelper.instance.getAllResponses();

    // Filtrar por especie seleccionada
    final filtered = data.where((e) {
      if (e['species'] == null) return false;
      final dbSp = e['species'].toString().toLowerCase();
      final filterSp = widget.species.toLowerCase();
      return dbSp == filterSp || dbSp.contains(filterSp) || filterSp.contains(dbSp);
    }).toList();

    setState(() {
      resultados = filtered;
    });
  }

  // ✅ Calcular promedio
  double _promedio() {
    if (resultados.isEmpty) return 0;
    final total = resultados.fold<double>(0, (sum, e) => sum + (e['score'] ?? 0));
    return total / resultados.length;
  }

  // ✅ Traducir promedio a mensaje y color
  Map<String, dynamic> _interpretacion(double p) {
    if (p >= 85) {
      return {'msg': 'Excelente', 'color': Colors.green.shade600};
    } else if (p >= 60) {
      return {'msg': 'Bueno', 'color': Colors.yellow.shade800};
    } else if (p >= 30) {
      return {'msg': 'Regular', 'color': Colors.orange.shade700};
    } else {
      return {'msg': 'Deficiente', 'color': Colors.red.shade600};
    }
  }

  @override
  Widget build(BuildContext context) {
    final promedio = _promedio();
    final interp = _interpretacion(promedio);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 3,
        title: const Text(
          'Resultados Guardados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ Contenido
      body: resultados.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay resultados guardados.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ----------------------------------------------------
                // ✅ Tarjeta del promedio general
                // ----------------------------------------------------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: interp['color'].withOpacity(.15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Promedio general:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.teal.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${promedio.toStringAsFixed(1)} puntos",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: interp['color'],
                          ),
                        ),
                        Text(
                          interp['msg'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: interp['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ----------------------------------------------------
                // ✅ Lista de resultados individuales
                // ----------------------------------------------------
                ...resultados.map((r) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // ✅ Foto o icono
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                              image: r['photo'] != null && r['photo'] != ''
                                  ? DecorationImage(
                                      image: FileImage(File(r['photo'])),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (r['photo'] == null || r['photo'] == '')
                                ? const Icon(Icons.photo, size: 30, color: Colors.grey)
                                : null,
                          ),

                          const SizedBox(width: 15),

                          // ✅ Info detallada
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['indicatorTitle'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Puntaje: ${r['score']}",
                                  style: TextStyle(
                                    color: Colors.teal.shade900,
                                    fontSize: 15,
                                  ),
                                ),
                                if (r['observaciones'] != null &&
                                    r['observaciones'].toString().trim().isNotEmpty)
                                  Text(
                                    "Obs: ${r['observaciones']}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList()
              ],
            ),
    );
  }
}
