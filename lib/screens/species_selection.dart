import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bienestar_porcino_app/screens/indicator_list.dart'; // eliminado
import '../widgets/menu_drawer.dart';

class SpeciesSelectionPage extends StatelessWidget {
  const SpeciesSelectionPage({Key? key}) : super(key: key);

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('evaluador') ?? '';
    final date = prefs.getString('fecha') ?? '';
    return {'name': name, 'date': date};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text("Selecciona la especie")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Evaluador: ${user['name']}\nFecha: ${user['date']?.split('T').first}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.pets, size: 40),
                  label: const Text("Porcinos", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text("Bienestar Porcino")),
                          drawer: MenuDrawer(species: 'Porcinos'),
                          body: const Center(
                            child: Text(
                              "Usa el menú ☰ para navegar por los pasos de la metodología",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.egg, size: 40),
                  label: const Text("Aves de Postura", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Módulo de Aves en desarrollo 🐔")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
