import 'package:flutter/material.dart';
import '../models/note_list_model.dart';
import '../repository/list_repository.dart';

class ListProvider extends ChangeNotifier {
  final ListRepository _repo = ListRepository();

  List<NoteList> lists = [];
  bool isLoading = false;

  Future<void> loadLists() async {
    isLoading = true;
    notifyListeners();

    lists = await _repo.getLists();

    isLoading = false;
    notifyListeners();
  }

  Future<NoteList> addListAndReturn(String title) async {
    final list = NoteList(
      title: title,
      createdAt: DateTime.now(),
    );

    final newList = await _repo.insertList(list);
    await loadLists();
    return newList;
  }

  Future<void> updateList(int id, String title) async {
    final list = NoteList(
      id: id,
      title: title,
      createdAt: DateTime.now(),
    );

    await _repo.updateList(list);
    await loadLists();
  }

  /// 🗑️ BORRAR LISTA
  Future<void> deleteList(int id) async {
    await _repo.deleteList(id);
    await loadLists();
  }
}
