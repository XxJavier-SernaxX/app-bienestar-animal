// lib/screens/results_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ResultsPage extends StatefulWidget {
  final String species;
  const ResultsPage({super.key, required this.species});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Map<String, dynamic> results = {};

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final Map<String, dynamic> loaded = {};

    final normSpecies = widget.species.toLowerCase().contains('aves') ? 'aves' : 'porcinos';

    // Filtrar por especie: guardamos claves con el prefijo '{species}_...'
    for (var key in allKeys) {
      if (!key.startsWith('${normSpecies}_')) continue;
      final data = prefs.getString(key);
      if (data != null) {
        loaded[key] = jsonDecode(data);
      }
    }

    setState(() => results = loaded);
  }

  String _getRecommendation(int score, String name) {
    if (score == 100) return '✅ $name: Excelente, sin observaciones.';
    if (score == 55) return '🟨 $name: Parcial, revisar condiciones.';
    if (score == 20) return '🟥 $name: Requiere atención, corregir pronto.';
    return '❌ $name: No cumple, urgente mejorar.';
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados finales')),
        body: const Center(child: Text('Aún no hay resultados guardados.')),
      );
    }

    final List<Widget> recommendations = [];
    results.forEach((key, value) {
      final indicatorName = key.split('_').last;
      final score = value['score'] ?? 0;
      recommendations.add(Text(_getRecommendation(score, indicatorName)));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados finales')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Recomendaciones generales:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...recommendations,
          ],
        ),
      ),
    );
  }
}
