import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/note_list_model.dart';

class ListRepository {
  Future<List<NoteList>> getLists() async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'lists',
      orderBy: 'createdAt DESC',
    );

    return result.map((e) => NoteList.fromMap(e)).toList();
  }

  Future<NoteList> insertList(NoteList list) async {
    final db = await DatabaseHelper.database;
    final id = await db.insert('lists', list.toMap());
    return list.copyWith(id: id);
  }

  Future<void> updateList(NoteList list) async {
    final db = await DatabaseHelper.database;

    await db.update(
      'lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  /// 🗑️ BORRAR LISTA + ITEMS
  Future<void> deleteList(int listId) async {
    final db = await DatabaseHelper.database;

    // borrar items primero
    await db.delete(
      'list_items',
      where: 'listId = ?',
      whereArgs: [listId],
    );

    // borrar lista
    await db.delete(
      'lists',
      where: 'id = ?',
      whereArgs: [listId],
    );
  }
}
