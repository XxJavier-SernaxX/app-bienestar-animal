// 🐷 Pantalla de selección de especie
// -----------------------------------------------------------
// Explicación simple:
// Esta pantalla muestra el nombre y la fecha del evaluador.
// Si NO hay fecha guardada, pone automáticamente la del día de hoy.
// El usuario puede devolver atrás si quiere cambiar nombre/fecha.
//
// Tiene tarjetas más elegantes para elegir Porcinos o Aves.
// -----------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/menu_drawer.dart';

class SpeciesSelectionPage extends StatelessWidget {
  const SpeciesSelectionPage({super.key});

  // -----------------------------------------------------------
  // Cargar el nombre y la fecha del usuario
  // -----------------------------------------------------------
  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('userName') ?? '';
    String date = prefs.getString('selectedDate') ?? '';

    // Si no hay fecha guardada → usar la del día actual
    if (date.isEmpty) {
      final now = DateTime.now();
      date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      await prefs.setString('selectedDate', date);
    }

    return {'name': name, 'date': date};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
            title: const Text("Elegir especie", style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),

          // -----------------------------------------------------------
          // CUERPO PRINCIPAL
          // -----------------------------------------------------------
          body: Column(
            children: [
              // -----------------------------------------------------------
              // HEADER CON NOMBRE Y FECHA
              // -----------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Evaluador: ${user['name']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Fecha: ${user['date']}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // -----------------------------------------------------------
              // TARJETAS DE OPCIONES
              // -----------------------------------------------------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // ---------------- TARJETA PORCINOS ----------------
                      _SpeciesCard(
                        icon: Icons.pets,
                        title: "Porcinos",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text("Bienestar Porcino"),
                                  backgroundColor: Colors.green,
                                ),
                                drawer: MenuDrawer(species: 'Porcinos'),
                                body: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        child: Image.asset(
                                          'assets/porcino1.jpg',
                                          height: 230,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
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
                                            SizedBox(height: 15),
                                            Text(
                                              "Usa el menú ☰ para explorar la evaluación del bienestar animal.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
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

                      const SizedBox(height: 25),

                      // ---------------- TARJETA AVES ----------------
                      _SpeciesCard(
                        icon: Icons.egg,
                        title: "Aves de Postura",
                        color: Colors.orange,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Módulo de Aves en desarrollo 🐔"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------
// TARJETA COMO BOTÓN MODERNO
// -----------------------------------------------------------
class _SpeciesCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SpeciesCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(25),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 18),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
