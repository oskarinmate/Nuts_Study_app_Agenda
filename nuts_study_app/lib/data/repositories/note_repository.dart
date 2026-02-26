import 'package:nuts_study_app/core/database/database_helper.dart';
import 'package:nuts_study_app/data/models/note_model.dart';
import 'package:nuts_study_app/features/folder/model/folder_model.dart';

class NoteRepository {
  // --- NOTAS ---
  Future<List<Note>> getNotes() async {
    final db = await DatabaseHelper.database; // Acceso estático directo
    final maps = await db.query('notes', orderBy: 'createdAt DESC');
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> addNote(Note note) async {
    final db = await DatabaseHelper.database;
    await db.insert('notes', note.toMap());
  }

  Future<void> updateNote(Note note) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- CARPETAS / MATERIAS ---
  Future<List<Folder>> getFolders() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('folders');
    return maps.map((e) => Folder.fromMap(e)).toList();
  }

  Future<void> deleteFolder(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addFolder(Folder folder) async {
    final db = await DatabaseHelper.database;
    await db.insert('folders', folder.toMap());
  }
}