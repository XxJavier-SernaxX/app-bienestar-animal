// ✅ SERVICIO DE SINCRONIZACIÓN CON FIREBASE
// ---------------------------------------------------------------
// Explicado como estudiante:
//
// Este archivo se encarga de:
// 1. Leer todo lo guardado localmente en SQLite.
// 2. Ver qué cosas NO se han subido todavía (synced = 0).
// 3. Subir esas cosas a Firebase Firestore.
// 4. Si tiene foto → la sube a Firebase Storage.
// 5. Después de subir, marca el registro como "synced = 1" en SQLite.
//
// Así la app funciona sin internet, pero sincroniza cuando sí lo haya.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helpers/database_helper.dart';

class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._();

  FirebaseSyncService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// ✅ Función principal: sincronizar todo lo pendiente
  Future<void> syncPendingData() async {
    try {
      // 1️⃣ Buscar datos pendientes en SQLite
      final pending = await DatabaseHelper.instance.getPendingToSync();

      if (pending.isEmpty) {
        print('✅ No hay datos pendientes por sincronizar');
        return;
      }

      print('🔄 Sincronizando ${pending.length} registros...');

      for (var item in pending) {
        String? photoUrl;

        // 2️⃣ Subir foto si existe
        if (item['photo'] != null && item['photo'].toString().isNotEmpty) {
          final photoFile = File(item['photo']);

          if (photoFile.existsSync()) {
            final storageRef = storage.ref().child(
              'evidencias/${DateTime.now().millisecondsSinceEpoch}.jpg',
            );

            final uploadTask = await storageRef.putFile(photoFile);
            photoUrl = await uploadTask.ref.getDownloadURL();
          }
        }

        // 3️⃣ Subir registro a Firestore
        final doc = await firestore.collection('evaluaciones').add({
          'indicatorId': item['indicatorId'],
          'indicatorTitle': item['indicatorTitle'],
          'score': item['score'],
          'timestamp': item['timestamp'],
          'observaciones': item['observaciones'],
          'species': item['species'],
          'photoUrl': photoUrl,
        });

        // 4️⃣ Marcar como sincronizado
        await DatabaseHelper.instance.markAsSynced(item['id'], doc.id);

        print("✅ Sincronizado el ID local ${item['id']} → Firebase ${doc.id}");
      }

      print('✅ Todos los registros fueron sincronizados correctamente');

    } catch (e) {
      // ⚠️ Si hay error, no hacemos nada (se intentará más tarde)
      print('❌ Error sincronizando: $e');
    }
  }
}
