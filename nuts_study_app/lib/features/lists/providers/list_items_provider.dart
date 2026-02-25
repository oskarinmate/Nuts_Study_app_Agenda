import 'package:flutter/material.dart';
import 'package:nuts_study_app/data/models/note_list_item_model.dart';
import '../repository/list_items_repository.dart';

class ListItemsProvider extends ChangeNotifier {
  final ListItemsRepository _repository = ListItemsRepository();

  List<NoteListItem> _items = [];
  bool _isLoading = false;

  List<NoteListItem> get items => _items;
  bool get isLoading => _isLoading;

  /// 🔹 Cargar ítems de una lista (PARAMETRO POSICIONAL)
  Future<void> loadItems(int listId) async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getItemsByListId(listId);

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Agregar ítem
  Future<void> addItem(int listId, String text) async {
    if (text.trim().isEmpty) return;

    final item = NoteListItem(
      listId: listId,
      text: text,
      isDone: false,
    );

    final insertedItem = await _repository.insertItem(item);
    _items.add(insertedItem);

    notifyListeners();
  }

  /// 🔹 Marcar / desmarcar ítem
  Future<void> toggleItem(NoteListItem item) async {
    final updatedItem = item.copyWith(
      isDone: !item.isDone,
    );

    await _repository.updateItem(updatedItem);

    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  /// 🔹 Eliminar ítem
  Future<void> deleteItem(NoteListItem item) async {
    if (item.id == null) return;

    await _repository.deleteItem(item.id!);
    _items.removeWhere((e) => e.id == item.id);

    notifyListeners();
  }

  /// 🔹 Limpiar estado
  void clear() {
    _items = [];
    notifyListeners();
  }

  void clearItems() {
  _items = []; // O como se llame tu lista interna
  notifyListeners();
}
}
