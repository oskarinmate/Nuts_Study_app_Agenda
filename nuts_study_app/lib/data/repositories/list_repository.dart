import 'package:nuts_study_app/features/lists/models/note_list_model.dart';

import '../../../core/database/database_helper.dart';


class ListRepository {
  Future<List<NoteList>> getLists() async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'lists',
      orderBy: 'createdAt DESC',
    );

    return result.map((e) => NoteList.fromMap(e)).toList();
  }

  Future<int> insertList(NoteList list) async {
    final db = await DatabaseHelper.database;
    return await db.insert('lists', list.toMap());
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

  Future<void> deleteList(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('lists', where: 'id = ?', whereArgs: [id]);
    await db.delete('list_items', where: 'listId = ?', whereArgs: [id]);
  }
}
