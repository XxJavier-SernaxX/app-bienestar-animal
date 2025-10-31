// ✅ main.dart – Archivo principal de SIBA
// -------------------------------------------------------
// Explicación tipo estudiante:
// Este archivo es como el “cerebro inicial” de la app.
// Aquí se configura Firebase, el estilo visual y todas las rutas.
// También dice cuál pantalla se abre primero (login).

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Archivo de configuración de Firebase
import 'firebase_options.dart';

// 🔹 Pantallas
import 'screens/login_page.dart';
import 'screens/species_selection.dart';
import 'screens/survey_page.dart';
import 'screens/indicator_list.dart';
import 'screens/indicator_detail.dart';
import 'screens/resultados_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Firebase ANTES de arrancar la app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BienestarApp());
}

class BienestarApp extends StatelessWidget {
  const BienestarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIBA - Bienestar Animal',
      debugShowCheckedModeBanner: false,

      // ✅ Tema general de la app
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),

      // ✅ Pantalla inicial
      initialRoute: '/login',

      // ✅ Rutas de la aplicación
      routes: {
        '/login': (context) => const LoginPage(),

        '/species': (context) => const SpeciesSelectionPage(),

        // ✅ Encuestas
        '/porcinos': (context) => SurveyPage(
              indicator: {'id': 'porcinos', 'title': 'Porcinos'},
            ),

        '/aves': (context) => SurveyPage(
              indicator: {'id': 'aves', 'title': 'Aves de postura'},
            ),

        // ✅ Lista de indicadores (por defecto recursos para porcinos)
        '/indicators': (context) => IndicatorList(
              category: 'recursos',
              categoryTitle: 'Recursos',
              species: 'porcinos',
            ),

        // ✅ Detalle de indicador
        '/indicator_detail': (context) => IndicatorDetail(
              indicatorName: 'Condición Corporal',
              category: 'animal',
            ),

        // ✅ Resultados finales
        '/resultados': (context) => const ResultadosScreen(
              species: 'porcinos',
            ),
      },
    );
  }
}
