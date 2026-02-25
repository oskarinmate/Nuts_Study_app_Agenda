import 'package:nuts_study_app/features/calendar/model/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Asegúrate de importar tu modelo Event

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'notes.db');

    _db = await openDatabase(
      path,
      version: 2, 
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Si el usuario viene de la v1, creamos la tabla que falta
          await db.execute('''
            CREATE TABLE IF NOT EXISTS events(
              id TEXT PRIMARY KEY,
              title TEXT,
              date TEXT
            )
          ''');
        }
      },
    );

    return _db!;
  }

  static Future<void> _createTables(Database db) async {
    // Tablas existentes...
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS list_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listId INTEGER,
        text TEXT,
        isDone INTEGER
      )
    ''');

    // NUEVA TABLA PARA EVENTOS/RECORDATORIOS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events(
        id TEXT PRIMARY KEY,
        title TEXT,
        date TEXT
      )
    ''');
  }

  // --- MÉTODOS PARA EVENTOS ---

  static Future<int> insertEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return maps.map((e) => Event.fromMap(e)).toList();
  }

  static Future<int> deleteEvent(String id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}