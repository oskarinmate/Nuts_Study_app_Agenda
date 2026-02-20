import '../models/note_model.dart';
import '../../core/database/database_helper.dart';

class NoteRepository {
  Future<List<Note>> getNotes() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');

    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> addNote(Note note) async {
    final db = await DatabaseHelper.database;
    await db.insert('notes', note.toMap());
  }

  Future<void> deleteNote(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
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
}
