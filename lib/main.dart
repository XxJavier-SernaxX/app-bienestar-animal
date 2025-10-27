import 'package:flutter/material.dart';

// 🔹 Importa tus pantallas
import 'screens/login_page.dart';
import 'screens/species_selection.dart';
import 'screens/survey_page.dart';
import 'screens/indicator_list.dart';
import 'screens/indicator_detail.dart';
import 'screens/resultados_screen.dart'; // <-- la nueva pantalla de resultados
import 'widgets/menu_drawer.dart';

void main() {
  runApp(const BienestarApp());
}

class BienestarApp extends StatelessWidget {
  const BienestarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metodología Bienestar Animal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),

      // 🔹 Ruta inicial
      initialRoute: '/login',

      // 🔹 Define todas las rutas disponibles
      routes: {
        '/login': (context) => const LoginPage(),
        '/species': (context) => const SpeciesSelectionPage(),

        // Encuestas específicas
        '/porcinos': (context) =>
            SurveyPage(indicator: {'id': 'porcinos', 'title': 'Porcinos'}),
        '/aves': (context) =>
            SurveyPage(indicator: {'id': 'aves', 'title': 'Aves de postura'}),

        // Lista e indicadores
        '/indicators': (context) =>
            const IndicatorList(category: 'recursos', categoryTitle: 'Recursos', species: 'porcinos'),
        '/indicator_detail': (context) => const IndicatorDetail(
              indicatorName: 'Condición corporal',
              category: 'animal',
            ),

        // Resultados finales
        '/resultados': (context) => ResultadosScreen(),
      },
    );
  }
}
