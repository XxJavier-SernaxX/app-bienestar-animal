import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultsPage extends StatefulWidget {
  final String species;

  const ResultsPage({super.key, required this.species});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Map<String, dynamic>> loaded = [];

    for (var key in keys) {
      if (key.startsWith(widget.species)) {
        final name = key.split('_').skip(1).join(' ').replaceAll('_rating', '');
        if (key.endsWith('_rating')) {
          final rating = prefs.getString(key);
          final photoPath = prefs.getString('${widget.species}_${name}_photo');
          loaded.add({
            'name': name,
            'rating': rating,
            'photo': photoPath,
          });
        }
      }
    }

    setState(() {
      results = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados guardados')),
      body: results.isEmpty
          ? const Center(child: Text('No hay resultados guardados aún.'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Calificación: ${item['rating']}'),
                    trailing: item['photo'] != null
                        ? Image.file(File(item['photo']), width: 60, height: 60)
                        : const Icon(Icons.photo_camera_back_outlined),
                  ),
                );
              },
            ),
    );
  }
}
