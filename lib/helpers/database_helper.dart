import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    await initDB();
    return _database!;
  }

  /// Inicializa la base de datos SQLite
  Future<void> initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'bienestar.db');
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Crea la tabla principal
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicatorId TEXT,
        indicatorTitle TEXT,
        score INTEGER,
        timestamp TEXT,
        evaluador TEXT,
        fecha_evaluacion TEXT,
        observaciones TEXT,
        species TEXT
      )
    ''');
  }

  /// Si ya existe una versión anterior, agrega las columnas nuevas sin borrar datos
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE responses ADD COLUMN evaluador TEXT");
        await db.execute("ALTER TABLE responses ADD COLUMN fecha_evaluacion TEXT");
      } catch (e) {
        // Si ya existen las columnas, ignora el error
        print('Columnas ya existentes o error al actualizar DB: $e');
      }
    }

    // Version 3: agregar columnas observaciones y species
    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE responses ADD COLUMN observaciones TEXT");
        await db.execute("ALTER TABLE responses ADD COLUMN species TEXT");
      } catch (e) {
        print('Columnas observaciones/species ya existentes o error al actualizar DB: $e');
      }
    }
  }

  /// Inserta una respuesta nueva
  Future<int> insertResponse(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('responses', row);
  }

  /// Obtiene todas las respuestas guardadas
  Future<List<Map<String, dynamic>>> getAllResponses() async {
    final db = await instance.database;
    return await db.query('responses', orderBy: 'timestamp DESC');
  }

  /// Borra todas las respuestas
  Future<void> clearResponses() async {
    final db = await instance.database;
    await db.delete('responses');
  }

  /// Cierra la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
