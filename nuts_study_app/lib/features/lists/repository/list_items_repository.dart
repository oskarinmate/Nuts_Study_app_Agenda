import 'package:nuts_study_app/data/models/note_list_item_model.dart';
import '../../../core/database/database_helper.dart';


class ListItemsRepository {
  /// 🔹 Obtener ítems por lista
  Future<List<NoteListItem>> getItemsByListId(int listId) async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'list_items',
      where: 'listId = ?',
      whereArgs: [listId],
      orderBy: 'id ASC',
    );

    return result.map((e) => NoteListItem.fromMap(e)).toList();
  }

  /// 🔹 Insertar ítem
  Future<NoteListItem> insertItem(NoteListItem item) async {
    final db = await DatabaseHelper.database;

    final id = await db.insert('list_items', item.toMap());

    return item.copyWith(id: id);
  }

  /// 🔹 Actualizar ítem
  Future<void> updateItem(NoteListItem item) async {
    final db = await DatabaseHelper.database;

    await db.update(
      'list_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 🔹 Eliminar ítem
  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.database;

    await db.delete(
      'list_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
