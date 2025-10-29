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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
                          appBar:
                              AppBar(title: const Text("Bienestar Porcino")),
                          drawer: MenuDrawer(species: 'Porcinos'),
                          body: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Imagen superior
                                Image.asset(
                                  'assets/porcino1.jpg',
                                  fit: BoxFit.cover,
                                  height: 230,
                                ),
                                const SizedBox(height: 20),

                                // Texto explicativo y didáctico
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    children: const [
                                      Text(
                                        "Bienvenido al módulo de Bienestar Porcino 🐷",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Usa el menú ☰ para explorar los pasos de la metodología. "
                                        "Aquí podrás evaluar las condiciones de bienestar animal, "
                                        "analizar resultados y registrar observaciones importantes.",
                                        style: TextStyle(
                                            fontSize: 16, height: 1.4),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Recuerda que cada sección incluye indicadores clave sobre "
                                        "alimentación, manejo, salud y comportamiento. ¡Explora, aprende y evalúa!",
                                        style: TextStyle(
                                            fontSize: 16, height: 1.4),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                  label: const Text("Aves de Postura",
                      style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Módulo de Aves en desarrollo 🐔")),
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
