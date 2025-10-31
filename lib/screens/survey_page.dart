// ✅ Página moderna para responder los indicadores por especie
// ---------------------------------------------------------------
// Explicación simple:
// Esta pantalla muestra todos los pasos o partes que tiene la evaluación
// (por ejemplo, "comederos", "alimentación", "salud", etc).
// Cada tarjeta representa un paso. Si el usuario entra y responde, se marca como completado.
// Además, si sale y vuelve, los datos se guardan usando el helper de almacenamiento.

import 'package:flutter/material.dart';
import '../widgets/menu_drawer.dart';
import '../utils/storage.dart';
import 'survey_detail_page.dart';

class SurveyPage extends StatefulWidget {
  final Map<String, String> indicator; // ejemplo: {'id': 'porcinos', 'title': 'Porcinos'}

  const SurveyPage({super.key, required this.indicator});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // 🔹 Pasos o partes de la evaluación
  final Map<String, bool> completed = {
    'Estado de los comederos': false,
    'Condición corporal': false,
    'Espacio y movimiento': false,
    'Alimentación': false,
    'Hidratación': false,
    'Comportamiento': false,
    'Salud general': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  // ✅ Cargar progreso guardado desde memoria
  Future<void> _loadSavedProgress() async {
    final saved = await StorageHelper.getResults();
    for (var result in saved) {
      if (result['species'] == widget.indicator['title']) {
        final step = result['indicador'];
        if (completed.containsKey(step)) {
          completed[step] = true;
        }
      }
    }
    setState(() {});
  }

  // ✅ Guardar progreso
  Future<void> _saveProgress(String step) async {
    await StorageHelper.saveResult({
      'species': widget.indicator['title'],
      'indicador': step,
      'done': true,
      'date': DateTime.now().toString(),
    });
  }

  // ✅ Actualiza el estado visual
  void _updateStep(String step, bool done) {
    setState(() {
      completed[step] = done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 AppBar moderno con botón atrás
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 3,
        title: Text(
          'Evaluación - ${widget.indicator['title']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔹 Menú lateral
      drawer: MenuDrawer(species: widget.indicator['title'] ?? ''),

      // 🔹 Lista moderna de tarjetas
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: completed.keys.map((step) {
          final isDone = completed[step] ?? false;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: Card(
              elevation: 4,
              shadowColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

                // 🔹 Icono principal con check animado
                leading: GestureDetector(
                  onTap: () {
                    _updateStep(step, !isDone);
                    if (!isDone) _saveProgress(step);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.teal : Colors.white,
                      border: Border.all(
                        color: isDone ? Colors.teal : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isDone ? Icons.check : Icons.circle_outlined,
                      color: isDone ? Colors.white : Colors.grey.shade600,
                      size: 26,
                    ),
                  ),
                ),

                // 🔹 Texto del indicador
                title: Text(
                  step,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration:
                        isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isDone ? Colors.grey : Colors.black,
                  ),
                ),

                // 🔹 Icono para entrar al detalle del paso
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 20, color: Colors.teal),

                // 🔹 Al tocar, abre la encuesta detallada
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurveyDetailPage(
                        stepName: step,
                        species: widget.indicator['title'] ?? '',
                      ),
                    ),
                  );

                  // ✅ Si se completa en la pantalla detalle
                  if (result == true) {
                    _updateStep(step, true);
                    _saveProgress(step);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
