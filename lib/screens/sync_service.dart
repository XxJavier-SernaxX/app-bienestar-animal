// lib/services/sync_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../helpers/database_helper.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Singleton sencillo
  static final SyncService instance = SyncService._internal();
  SyncService._internal() {
    _init();
  }

  void _init() {
    // Escuchar cambios de conectividad
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _trySync();
      }
    });
  }

  // Intentar sincronizar pendientes
  Future<void> _trySync() async {
    final db = DatabaseHelper.instance;
    final all = await db.getAllResponses(); // todas las filas
    final pending = all.where((r) => (r['synced'] ?? 0) == 0).toList();

    for (var row in pending) {
      try {
        String? photoUrl;
        if (row['photo'] != null && row['photo'].toString().isNotEmpty) {
          final file = File(row['photo']);
          if (file.existsSync()) {
            final ref = _storage.ref().child('evidences/${DateTime.now().millisecondsSinceEpoch}_${row['indicatorId']}.jpg');
            final uploadTask = await ref.putFile(file);
            photoUrl = await uploadTask.ref.getDownloadURL();
          }
        }

        // Documento que subimos a Firestore
        final doc = {
          'indicatorId': row['indicatorId'],
          'indicatorTitle': row['indicatorTitle'],
          'score': row['score'],
          'timestamp': row['timestamp'],
          'evaluador': row['evaluador'],
          'fecha_evaluacion': row['fecha_evaluacion'],
          'observaciones': row['observaciones'],
          'species': row['species'],
          'photoUrl': photoUrl,
        };

        // Colección: 'evaluations' / se puede organizar por project/uid
        await _firestore.collection('evaluations').add(doc);

        // Marcar localmente como sincronizado
        await db.database.then((d) async {
          await d.update(
            'responses',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        });
      } catch (e) {
        // Si falla la subida de alguno, se sigue con los demás
        print('Error sincronizando fila ${row['id']}: $e');
      }
    }
  }

  // Puedes exponer un método público para forzar sync manual:
  Future<void> syncNow() async => _trySync();
}
