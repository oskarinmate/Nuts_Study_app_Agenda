import 'package:flutter/material.dart';
import '../../../data/models/note_model.dart';
import '../../../data/repositories/note_repository.dart';

class NotesProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();

  List<Note> notes = [];
  bool isLoading = false;

  Future<void> loadNotes() async {
    isLoading = true;
    notifyListeners();

    notes = await _repo.getNotes();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    await _repo.addNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
    await loadNotes();
  }

  Future<void> updateNote(int id, String title, String content) async {
  final note = Note(
    id: id,
    title: title,
    content: content,
    createdAt: DateTime.now(),
  );

  await _repo.updateNote(note);
  await loadNotes();
}
}
