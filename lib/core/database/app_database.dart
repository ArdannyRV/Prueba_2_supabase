import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('elecciones_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla para cache de mesas asignadas
    await db.execute('''
      CREATE TABLE mesas_local (
        id TEXT PRIMARY KEY,
        veedor_id TEXT,
        numero_mesa INTEGER,
        recinto_nombre TEXT,
        tiene_acta_alcaldia INTEGER,
        tiene_acta_prefectura INTEGER
      )
    ''');

    // Tabla principal para actas locales
    await db.execute('''
      CREATE TABLE actas_local (
        id TEXT PRIMARY KEY,
        mesa_id TEXT,
        dignidad TEXT,
        votos_blancos INTEGER,
        votos_nulos INTEGER,
        total_sufragantes INTEGER,
        latitud REAL,
        longitud REAL,
        foto_local_path TEXT,
        foto_url TEXT,
        corregida INTEGER,
        created_at TEXT,
        updated_at TEXT,
        remote_id TEXT,
        sync_status TEXT,
        server_snapshot TEXT
      )
    ''');

    // Tabla para los votos por candidato (sin sync_status separado, porque se sincronizan junto al acta)
    await db.execute('''
      CREATE TABLE votos_candidatos_local (
        id TEXT PRIMARY KEY,
        acta_local_id TEXT,
        candidato_id TEXT,
        cantidad INTEGER,
        FOREIGN KEY (acta_local_id) REFERENCES actas_local (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de caché de candidatos
    await db.execute('''
      CREATE TABLE candidatos_local (
        id TEXT PRIMARY KEY,
        nombre_candidato TEXT,
        organizacion_politica TEXT,
        dignidad TEXT,
        lista_numero INTEGER
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE candidatos_local (
          id TEXT PRIMARY KEY,
          nombre_candidato TEXT,
          organizacion_politica TEXT,
          dignidad TEXT,
          lista_numero INTEGER
        )
      ''');
    }
  }
}
