import 'package:flutter/material.dart';
import '../widgets/menu_drawer.dart';
import 'survey_detail_page.dart';

class SurveyPage extends StatefulWidget {
  final Map<String, String> indicator;

  const SurveyPage({super.key, required this.indicator});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final Map<String, bool> completed = {
    'Estado de los comederos': false,
    'Condición corporal': false,
    'Espacio y movimiento': false,
    'Alimentación': false,
    'Hidratación': false,
    'Comportamiento': false,
    'Salud general': false,
  };

  void _updateStep(String step, bool done) {
    setState(() {
      completed[step] = done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Evaluación - ${widget.indicator['title']}')),
      drawer: MenuDrawer(species: widget.indicator['title'] ?? ''),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: completed.keys.map((step) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CheckboxListTile(
              title: Text(step),
              value: completed[step],
              onChanged: (value) async {
                // Abrir la encuesta individual
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurveyDetailPage(stepName: step, species: widget.indicator['title'] ?? ''),
                  ),
                );
                if (result == true) {
                  _updateStep(step, true);
                }
              },
              secondary: const Icon(Icons.assignment),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }).toList(),
      ),
    );
  }
}
