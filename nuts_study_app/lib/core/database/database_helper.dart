import 'package:nuts_study_app/features/calendar/model/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  // Getter estático: Compatible con todos los repositorios
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
          await db.execute('''
            CREATE TABLE IF NOT EXISTS events(
              id TEXT PRIMARY KEY, title TEXT, date TEXT
            )
          ''');
        }
      },
    );
    return _db!;
  }

  static Future<void> _createTables(Database db) async {
    // 1. Materias (Folders)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // 2. Notas (con relación a materias)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        createdAt TEXT,
        folderId INTEGER,
        FOREIGN KEY (folderId) REFERENCES folders (id) ON DELETE SET NULL
      )
    ''');

    // 3. Listas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        createdAt TEXT
      )
    ''');

    // 4. Ítems de listas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS list_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listId INTEGER,
        text TEXT,
        isDone INTEGER
      )
    ''');

    // 5. Eventos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events(
        id TEXT PRIMARY KEY,
        title TEXT,
        date TEXT
      )
    ''');
  }

  // Métodos estáticos para eventos (Calendario)
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