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
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';

class SupabaseSyncService {
  static final SupabaseSyncService instance = SupabaseSyncService._internal();

  // URL y Llave pública por defecto de Supabase (Configurable desde la app o SharedPreferences)
  static const String defaultSupabaseUrl = "https://tu-proyecto.supabase.co";
  static const String defaultAnonKey = "tu-anon-key-de-supabase";

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SupabaseSyncService._internal() {
    _initConnectivityListener();
  }

  /// Inicia el listener de conectividad para sincronización automática
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('📶 [SIBA Sync] Conexión a Internet detectada. Iniciando sincronización...');
        syncPendingData();
      }
    });
  }

  /// Cancela suscripciones al cerrar
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Sincroniza todas las respuestas y evaluaciones pendientes con Supabase
  Future<Map<String, dynamic>> syncPendingData() async {
    if (_isSyncing) {
      return {'status': 'in_progress', 'message': 'Sincronización ya en curso'};
    }

    _isSyncing = true;
    int syncedCount = 0;
    int errorCount = 0;

    try {
      // 1. Verificar conectividad real
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('📴 [SIBA Sync] Sin conexión a internet. Los datos se mantendrán en SQLite local.');
        _isSyncing = false;
        return {'status': 'offline', 'message': 'Modo fuera de línea activo'};
      }

      // 2. Obtener credenciales de Supabase
      final prefs = await SharedPreferences.getInstance();
      final supabaseUrl = prefs.getString('supabase_url') ?? defaultSupabaseUrl;
      final anonKey = prefs.getString('supabase_anon_key') ?? defaultAnonKey;

      // 3. Obtener registros no sincronizados de SQLite
      final pendingList = await DatabaseHelper.instance.getPendingToSync();
      if (pendingList.isEmpty) {
        print('✅ [SIBA Sync] No hay registros pendientes por sincronizar.');
        _isSyncing = false;
        return {'status': 'ok', 'synced': 0, 'message': 'Todo sincronizado'};
      }

      print('🔄 [SIBA Sync] Subiendo ${pendingList.length} registros pendientes a Supabase...');

      // 4. Agrupar respuestas o enviar por lotes a la tabla 'evaluaciones'
      final client = HttpClient();
      final uri = Uri.parse('$supabaseUrl/rest/v1/evaluaciones');

      for (var item in pendingList) {
        try {
          final payload = jsonEncode({
            'evaluador_nombre': prefs.getString('user_name') ?? 'Evaluador UFPSO',
            'evaluador_codigo': prefs.getString('user_code') ?? '0192546',
            'especie': item['species'] ?? 'Porcinos',
            'lote_codigo': 'LOTE-GRANJA-${item['species'] ?? "PECUARIO"}',
            'ubicacion': 'Granja Experimental UFPSO',
            'puntaje_global': (item['score'] as num?)?.toDouble() ?? 0.0,
            'nivel_bienestar': _calcularNivel((item['score'] as num?)?.toDouble() ?? 0.0),
            'dictamen': item['observaciones'] ?? 'Evaluación registrada desde la app móvil SIBA.',
            'indicadores_json': [
              {
                'indicatorId': item['indicatorId'],
                'indicatorTitle': item['indicatorTitle'],
                'score': item['score'],
                'timestamp': item['timestamp'],
                'observaciones': item['observaciones'],
                'photo': item['photo'] ?? ''
              }
            ],
            'origen_offline': true
          });

          final request = await client.postUrl(uri);
          request.headers.set('Content-Type', 'application/json');
          request.headers.set('apikey', anonKey);
          request.headers.set('Authorization', 'Bearer $anonKey');
          request.headers.set('Prefer', 'return=minimal');
          request.write(payload);

          final response = await request.close();

          if (response.statusCode >= 200 && response.statusCode < 300) {
            // Marcar como sincronizado en SQLite
            final rowId = item['id'] as int;
            await DatabaseHelper.instance.markAsSynced(rowId, 'supabase_sync_ok');
            syncedCount++;
          } else {
            errorCount++;
            print('⚠️ [SIBA Sync] Error al subir registro ${item['id']}: Código HTTP ${response.statusCode}');
          }
        } catch (e) {
          errorCount++;
          print('⚠️ [SIBA Sync] Excepción al procesar fila ${item['id']}: $e');
        }
      }

      client.close();
      print('🚀 [SIBA Sync] Proceso finalizado. Sincronizados: $syncedCount | Pendientes con error: $errorCount');

      _isSyncing = false;
      return {
        'status': 'complete',
        'synced': syncedCount,
        'errors': errorCount,
        'message': 'Sincronización completada exitosamente'
      };
    } catch (e) {
      _isSyncing = false;
      print('❌ [SIBA Sync] Error general en sincronización: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  String _calcularNivel(double score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bueno';
    if (score >= 40) return 'Regular';
    return 'Crítico';
  }
}
