// lib/screens/resultados_screen.dart
import 'package:flutter/material.dart';
import '../utils/storage.dart';

class ResultadosScreen extends StatefulWidget {
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

  Future<void> _loadResults() async {
    final data = await StorageHelper.getResults();
    setState(() {
      resultados = data;
    });
  }

  double _promedio() {
    if (resultados.isEmpty) return 0;
    final total = resultados.fold(0.0, (sum, e) => sum + (e['puntos'] ?? 0.0));
    return total / resultados.length;
  }

  String _interpretacion(double promedio) {
    if (promedio >= 85) return 'Excelente 🟩';
    if (promedio >= 60) return 'Bueno 🟨';
    if (promedio >= 30) return 'Regular 🟧';
    return 'Deficiente 🟥';
  }

  @override
  Widget build(BuildContext context) {
    final promedio = _promedio();

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados Finales')),
      body: resultados.isEmpty
          ? const Center(child: Text('Aún no hay resultados guardados'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Promedio general: ${promedio.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _interpretacion(promedio),
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const Divider(height: 30),
                ...resultados.map((r) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.assignment_turned_in),
                        title: Text(r['indicador'] ?? 'Sin nombre'),
                        subtitle: Text('Puntaje: ${r['puntos'] ?? 0}'),
                        trailing: (r['foto'] != null && r['foto'] != '')
                            ? const Icon(Icons.photo, color: Colors.green)
                            : null,
                      ),
                    )),
              ],
            ),
    );
  }
}
