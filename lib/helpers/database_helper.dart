// ✅ BASE DE DATOS LOCAL + SOPORTE PARA SINCRONIZAR CON FIREBASE
// ---------------------------------------------------------------
// Explicado como estudiante:
// Esta base de datos guarda todo en el celular.
// Cada registro tiene un campo "synced":
//    0 = todavía no se ha subido a Firebase
//    1 = ya está sincronizado
//
// Cuando haya internet, una función sincronizará todo lo pendiente.

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDB();
    return _database!;
  }

  Future<void> initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'siba.db');

    _database = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicatorId TEXT,
        indicatorTitle TEXT,
        score INTEGER,
        timestamp TEXT,
        observaciones TEXT,
        species TEXT,
        photo TEXT,

        synced INTEGER DEFAULT 0,       -- ✅ 0=pendiente / 1=subido
        firebase_id TEXT                -- ✅ ID del documento en Firebase
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE responses ADD COLUMN synced INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE responses ADD COLUMN firebase_id TEXT");
      await db.execute("ALTER TABLE responses ADD COLUMN photo TEXT");
    }
  }

  /// ✅ Insertar fila
  Future<int> insertResponse(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('responses', row);
  }

  /// ✅ Obtener todos los registros
  Future<List<Map<String, dynamic>>> getAllResponses() async {
    final db = await instance.database;
    return await db.query('responses', orderBy: 'timestamp DESC');
  }

  /// ✅ Obtener registros pendientes por sincronizar
  Future<List<Map<String, dynamic>>> getPendingToSync() async {
    final db = await instance.database;
    return await db.query('responses', where: 'synced = ?', whereArgs: [0]);
  }

  /// ✅ Marcar como sincronizado
  Future<void> markAsSynced(int id, String firebaseId) async {
    final db = await instance.database;
    await db.update(
      'responses',
      {'synced': 1, 'firebase_id': firebaseId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ Borrar todo (si se necesita)
  Future<void> clearResponses() async {
    final db = await instance.database;
    await db.delete('responses');
  }
}
