// ✅ main.dart – Archivo principal de SIBA (Editorial Edition)
// -------------------------------------------------------
// Sistema de Información de Bienestar Animal - UFPSO
// Marco Normativo: Resolución 136 de 2020 y Resolución 253 de 2020
// Investigadores: Javier Mauricio Serna Osorio & Juan Manuel Garrido Amaya
// -------------------------------------------------------

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
import 'services/supabase_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Firebase si está disponible (con tolerancia offline)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init (offline mode activo): $e');
  }

  // ✅ Inicializar listener de sincronización offline-first con Supabase
  SupabaseSyncService.instance;

  runApp(const BienestarApp());
}

class BienestarApp extends StatelessWidget {
  const BienestarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIBA · Bienestar Animal',
      debugShowCheckedModeBanner: false,

      // ✅ Tema Editorial Agropecuario Premium
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9F5), // Fondo crema pergamino
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF263F30), // Verde bosque profundo
          primary: const Color(0xFF263F30),
          secondary: const Color(0xFF496B4D), // Verde musgo
          tertiary: const Color(0xFFB96E4B),  // Terracota / arcilla
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF263F30),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8ECE6), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF263F30),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
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
        '/indicators': (context) => const IndicatorList(
              category: 'recursos',
              categoryTitle: 'Recursos',
              species: 'porcinos',
            ),

        // ✅ Detalle de indicador
        '/indicator_detail': (context) => const IndicatorDetail(
              indicatorName: 'Condición Corporal',
              category: 'animal',
              species: 'porcinos',
            ),

        // ✅ Resultados finales
        '/resultados': (context) => const ResultadosScreen(
              species: 'porcinos',
            ),
      },
    );
  }
}
