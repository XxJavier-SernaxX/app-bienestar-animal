import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _key = 'resultsData';

  // Guardar o actualizar resultados
  static Future<void> saveResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_key) ?? [];

    // Agregar nuevo resultado
    existing.add(jsonEncode(result));
    await prefs.setStringList(_key, existing);
  }

  // Leer todos los resultados guardados
  static Future<List<Map<String, dynamic>>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    return saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // Borrar todos los resultados (opcional)
  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
