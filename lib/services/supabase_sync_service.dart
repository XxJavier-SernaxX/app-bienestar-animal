// lib/services/supabase_sync_service.dart
// -----------------------------------------------------------------------------
// SERVICIO DE SINCRONIZACIÓN OFFLINE-FIRST CON SUPABASE (POSTGRESQL GRATUITO)
// -----------------------------------------------------------------------------
// Explicación técnica:
// 1. Cuando la app está en los galpones/corrales de la Granja UFPSO sin Wi-Fi,
//    guarda todo en SQLite local (synced = 0).
// 2. Este servicio monitorea la conectividad de red con connectivity_plus.
// 3. Apenas detecta señal de Internet (Wi-Fi o datos móviles), toma todas las
//    evaluaciones e indicadores pendientes y los envía a la API REST de Supabase.
// 4. Tras recibir confirmación exitosa (HTTP 201), actualiza el registro en SQLite
//    a synced = 1.
// 5. Los datos quedan disponibles inmediatamente en el Panel Web de Vercel.
// -----------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';

class SupabaseSyncService {
  static final SupabaseSyncService instance = SupabaseSyncService._internal();

  // URL y Llave de acceso oficial al proyecto Supabase SIBA-UFPSO
  static const String defaultSupabaseUrl = "https://ktbgvnfwtsezzxaoirju.supabase.co";
  static const String defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0Ymd2bmZ3dHNlenp4YW9pcmp1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5NTEzMzkzNSwiZXhwIjoyMTEwNzA5OTM1fQ.uxq6V7bTbqV7y9Hp7ysg2Z1NTc22aTGcZSoe7_8zuAo";

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SupabaseSyncService._internal() {
    _initConnectivityListener();
  }

  /// Inicia el listener de conectividad para sincronización automática
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((dynamic result) {
      bool hasNet = false;
      if (result is List<ConnectivityResult>) {
        hasNet = result.any((r) => r != ConnectivityResult.none);
      } else if (result != ConnectivityResult.none) {
        hasNet = true;
      }
      if (hasNet) {
        debugPrint('📶 [SIBA Sync] Conexión a Internet detectada. Iniciando sincronización...');
        syncPendingData();
      }
    });
  }

  /// Cancela suscripciones al cerrar
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Sincroniza todas las respuestas y evaluaciones pendientes con Supabase
  Future<Map<String, dynamic>> syncPendingData({bool forceAll = false}) async {
    if (_isSyncing) {
      return {'status': 'in_progress', 'message': 'Sincronización ya en curso'};
    }

    _isSyncing = true;
    int syncedCount = 0;
    int errorCount = 0;
    String lastError = '';

    try {
      // 1. Verificar conectividad real
      final dynamic connectivityResult = await Connectivity().checkConnectivity();
      bool isOffline = false;
      if (connectivityResult is List<ConnectivityResult>) {
        isOffline = connectivityResult.every((r) => r == ConnectivityResult.none);
      } else if (connectivityResult == ConnectivityResult.none) {
        isOffline = true;
      }

      if (isOffline) {
        debugPrint('📴 [SIBA Sync] Sin conexión a internet. Los datos se mantendrán en SQLite local.');
        _isSyncing = false;
        return {'status': 'offline', 'message': 'Modo fuera de línea activo'};
      }

      // 2. Obtener credenciales de Supabase
      final prefs = await SharedPreferences.getInstance();
      final supabaseUrl = prefs.getString('supabase_url') ?? defaultSupabaseUrl;
      final anonKey = prefs.getString('supabase_anon_key') ?? defaultAnonKey;

      // 3. Obtener registros de SQLite
      List<Map<String, dynamic>> pendingList = forceAll
          ? await DatabaseHelper.instance.getAllResponses()
          : await DatabaseHelper.instance.getPendingToSync();

      if (pendingList.isEmpty) {
        // Si no hay con synced=0, intentar con todas las respuestas guardadas
        pendingList = await DatabaseHelper.instance.getAllResponses();
      }

      if (pendingList.isEmpty) {
        debugPrint('✅ [SIBA Sync] No hay registros en SQLite para sincronizar.');
        _isSyncing = false;
        return {'status': 'ok', 'synced': 0, 'message': 'No hay evaluaciones locales por sincronizar'};
      }

      debugPrint('🔄 [SIBA Sync] Agrupando ${pendingList.length} indicadores para consolidar evaluaciones...');

      // 4. Agrupar indicadores por especie para crear una auditoría consolidada
      final Map<String, List<Map<String, dynamic>>> groupedBySpecies = {};
      for (var item in pendingList) {
        final species = (item['species'] ?? 'Porcinos').toString();
        groupedBySpecies.putIfAbsent(species, () => []).add(item);
      }

      final client = HttpClient();
      final uri = Uri.parse('$supabaseUrl/rest/v1/evaluaciones');

      final evaluadorNombre = prefs.getString('userName') ?? prefs.getString('user_name') ?? 'Evaluador de Campo';
      final evaluadorCodigo = prefs.getString('userCode') ?? prefs.getString('user_code') ?? '0192546';

      for (var entry in groupedBySpecies.entries) {
        final speciesName = entry.key;
        final items = entry.value;

        try {
          // Promedio global y desglose por categorías
          double sumScores = 0.0;
          double recSum = 0; int recCount = 0;
          double animSum = 0; int animCount = 0;
          double gestSum = 0; int gestCount = 0;

          for (var it in items) {
            final sc = (it['score'] as num?)?.toDouble() ?? 0.0;
            sumScores += sc;
            final cat = (it['category'] ?? it['species'] ?? '').toString().toLowerCase();
            if (cat.contains('recurso')) {
              recSum += sc; recCount++;
            } else if (cat.contains('gestion') || cat.contains('gestión')) {
              gestSum += sc; gestCount++;
            } else {
              animSum += sc; animCount++;
            }
          }
          final double avgGlobal = items.isNotEmpty ? (sumScores / items.length) : 0.0;
          final double roundedGlobal = (avgGlobal * 10).round() / 10.0;
          final double scoreRecursos = recCount > 0 ? ((recSum / recCount) * 10).round() / 10.0 : roundedGlobal;
          final double scoreAnimal = animCount > 0 ? ((animSum / animCount) * 10).round() / 10.0 : roundedGlobal;
          final double scoreGestion = gestCount > 0 ? ((gestSum / gestCount) * 10).round() / 10.0 : roundedGlobal;

          // Subir fotos a Supabase Storage 'evidencias' y construir lista de indicadores
          final List<Map<String, dynamic>> indJsonList = [];
          for (var it in items) {
            String photoVal = (it['photo'] ?? '').toString();
            if (photoVal.isNotEmpty && !photoVal.startsWith('http')) {
              final cloudUrl = await _uploadPhotoFileToSupabase(photoVal, supabaseUrl, anonKey);
              if (cloudUrl != null) {
                photoVal = cloudUrl;
              }
            }

            indJsonList.add({
              'name': it['indicatorTitle'] ?? it['indicatorId'] ?? 'Indicador',
              'indicatorId': it['indicatorId'],
              'score': it['score'] ?? 0,
              'category': it['species'] ?? speciesName,
              'timestamp': it['timestamp'],
              'obs': it['observaciones'] ?? '',
              'photo': photoVal
            });
          }

          final now = DateTime.now();
          final auditId = "AUD-UFPSO-${now.millisecondsSinceEpoch.toString().substring(7)}";

          final payloadMap = {
            'id': auditId,
            'evaluador_nombre': evaluadorNombre,
            'evaluador_codigo': evaluadorCodigo,
            'especie': speciesName,
            'lote_codigo': 'LOTE-GRANJA-$speciesName',
            'ubicacion': 'Granja Experimental UFPSO',
            'score_recursos': scoreRecursos,
            'score_animal': scoreAnimal,
            'score_gestion': scoreGestion,
            'puntaje_global': roundedGlobal,
            'nivel_bienestar': _calcularNivel(roundedGlobal),
            'dictamen': 'Nivel ${_calcularNivel(roundedGlobal)} ($roundedGlobal pts). Auditoría integral de $speciesName realizada en campo vía APK SIBA con ${items.length} indicadores evaluados.',
            'indicadores_json': indJsonList,
            'origen_offline': true
          };

          final payloadBytes = utf8.encode(jsonEncode(payloadMap));

          final request = await client.postUrl(uri);
          request.headers.set('Content-Type', 'application/json; charset=utf-8');
          request.headers.set('apikey', anonKey);
          request.headers.set('Authorization', 'Bearer $anonKey');
          request.headers.set('Prefer', 'return=minimal');
          request.contentLength = payloadBytes.length;
          request.add(payloadBytes);

          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();

          if (response.statusCode >= 200 && response.statusCode < 300) {
            final List<int> rowIds = items.map((it) => it['id'] as int).toList();
            await DatabaseHelper.instance.markMultipleAsSynced(rowIds, auditId);
            syncedCount += items.length;
            debugPrint('✅ [SIBA Sync] Auditoría $auditId subida exitosamente a Supabase Cloud.');
          } else {
            errorCount += items.length;
            lastError = 'HTTP ${response.statusCode}: $responseBody';
            debugPrint('⚠️ [SIBA Sync] Error al subir auditoría $speciesName: $lastError');
          }
        } catch (e) {
          errorCount += items.length;
          lastError = e.toString();
          debugPrint('⚠️ [SIBA Sync] Excepción al consolidar auditoría $speciesName: $e');
        }
      }

      client.close();

      _isSyncing = false;
      if (syncedCount > 0) {
        return {
          'status': 'complete',
          'synced': syncedCount,
          'errors': errorCount,
          'message': '¡Auditoría subida a Supabase exitosamente!'
        };
      } else {
        return {
          'status': errorCount > 0 ? 'error' : 'ok',
          'synced': 0,
          'errors': errorCount,
          'message': errorCount > 0 ? 'Error al subir a Supabase: $lastError' : 'No había datos pendientes'
        };
      }
    } catch (e) {
      _isSyncing = false;
      debugPrint('❌ [SIBA Sync] Error general en sincronización: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<String?> _uploadPhotoFileToSupabase(String localPath, String supabaseUrl, String key) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      final fileName = "EVIDENCIA_APK_${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
      final uploadUri = Uri.parse('$supabaseUrl/storage/v1/object/evidencias/$fileName');
      final request = await HttpClient().postUrl(uploadUri);
      request.headers.set('Authorization', 'Bearer $key');
      request.headers.set('apikey', key);
      request.headers.set('Content-Type', 'image/jpeg');
      request.headers.set('x-upsert', 'true');
      request.contentLength = bytes.length;
      request.add(bytes);
      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('☁ [SIBA Sync] Foto subida exitosamente a Supabase Storage: $fileName');
        return '$supabaseUrl/storage/v1/object/public/evidencias/$fileName';
      } else {
        final err = await response.transform(utf8.decoder).join();
        debugPrint('⚠️ [SIBA Sync] Error al subir foto (${response.statusCode}): $err');
      }
    } catch (e) {
      debugPrint('⚠️ [SIBA Sync] Excepción al subir foto a Supabase Storage: $e');
    }
    return null;
  }

  String _calcularNivel(double score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bueno';
    if (score >= 40) return 'Regular';
    return 'Crítico';
  }
}
