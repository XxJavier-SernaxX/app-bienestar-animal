// ✅ Pantalla moderna de Resultados (SIBA)
// ---------------------------------------------------------------
// Explicación estilo estudiante:
//
// Esta pantalla muestra TODOS los resultados que se han guardado
// en la base de datos SQLite. Aquí puedes ver:
//
// ✅ El puntaje que se obtuvo en cada indicador
// ✅ La observación que escribiste
// ✅ La foto si se tomó evidencia
// ✅ Un promedio general con color (verde, amarillo, naranja o rojo)
//
// También se puede filtrar por especie (porcinos, aves, etc.).

import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class ResultadosScreen extends StatefulWidget {
  final String? species; // Si viene especie, filtra por especie

  const ResultadosScreen({Key? key, this.species}) : super(key: key);

  @override
  _ResultadosScreenState createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  List<Map<String, dynamic>> resultados = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // ✅ Cargar resultados desde SQLite
  Future<void> _loadResults() async {
    final all = await DatabaseHelper.instance.getAllResponses();

    final filtered = widget.species == null
        ? all
        : all.where((e) => e['species'] == widget.species).toList();

    setState(() {
      resultados = filtered;
    });
  }

  // ✅ Calcular promedio general
  double _promedio() {
    if (resultados.isEmpty) return 0;
    final total = resultados.fold<double>(0, (sum, e) => sum + (e['score'] ?? 0));
    return total / resultados.length;
  }

  // ✅ Interpretación del color
  Map<String, dynamic> _interpretacion(double p) {
    if (p >= 85) return {'txt': 'Excelente', 'color': Colors.green.shade700};
    if (p >= 60) return {'txt': 'Bueno', 'color': Colors.yellow.shade800};
    if (p >= 30) return {'txt': 'Regular', 'color': Colors.orange.shade800};
    return {'txt': 'Deficiente', 'color': Colors.red.shade700};
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
          "Resultados finales",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: resultados.isEmpty
          ? const Center(
              child: Text(
                "Aún no hay resultados guardados",
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // -------------------------------------------------------------
                // ✅ Tarjeta de promedio general
                // -------------------------------------------------------------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: interp['color'].withOpacity(.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Promedio General",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${promedio.toStringAsFixed(1)} puntos",
                          style: TextStyle(
                            fontSize: 24,
                            color: interp['color'],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          interp['txt'],
                          style: TextStyle(
                            fontSize: 18,
                            color: interp['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // ✅ Lista de indicadores guardados
                // -------------------------------------------------------------
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
                          // ✅ Foto del indicador
                          Container(
                            height: 70,
                            width: 70,
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
                                ? const Icon(Icons.photo, size: 35, color: Colors.grey)
                                : null,
                          ),

                          const SizedBox(width: 15),

                          // ✅ Información principal del indicador
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
                                const SizedBox(height: 5),
                                Text(
                                  "Puntaje: ${r['score']}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.teal.shade900,
                                  ),
                                ),

                                if (r['observaciones'] != null &&
                                    r['observaciones'].toString().trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      "Obs: ${r['observaciones']}",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
