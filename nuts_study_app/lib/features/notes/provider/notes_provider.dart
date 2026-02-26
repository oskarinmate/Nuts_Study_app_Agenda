import 'package:flutter/material.dart';
import '../../../data/models/note_model.dart';
import '../../../data/repositories/note_repository.dart';
import '../../folder/model/folder_model.dart';

class NotesProvider extends ChangeNotifier {
  final NoteRepository _repo = NoteRepository();

  List<Note> _notes = [];
  List<Folder> _folders = [];
  bool _isLoading = false;

  // Getters
  List<Note> get notes => _notes;
  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;

  // --- MÉTODOS DE CARGA ---

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await loadFolders();
      await loadNotes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotes() async {
    _notes = await _repo.getNotes();
    notifyListeners();
  }

  Future<void> loadFolders() async {
    _folders = await _repo.getFolders();
    notifyListeners();
  }

  // --- MÉTODOS DE NOTAS ---

  Future<void> addNote(String title, String content, {int? folderId}) async {
    final newNote = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
      folderId: folderId,
    );
    await _repo.addNote(newNote);
    await loadNotes();
  }

  Future<void> updateNote(int id, String title, String content, {int? folderId}) async {
    final updatedNote = Note(
      id: id,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      folderId: folderId,
    );
    await _repo.updateNote(updatedNote);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
    await loadNotes();
  }

  // --- MÉTODOS DE CARPETAS (MATERIAS) ---

  Future<void> addFolder(String name, int colorValue) async {
    final folder = Folder(name: name, colorValue: colorValue);
    await _repo.addFolder(folder);
    await loadFolders();
  }
  Future<void> deleteFolder(int id) async {
    await _repo.deleteFolder(id);
    await loadFolders();
    await loadNotes(); // Las notas de esa carpeta ahora serán "sueltas"
  }

  // Método opcional para obtener el nombre de una carpeta por su ID
  String getFolderName(int? folderId) {
    if (folderId == null) return "Sin materia";
    final folder = _folders.firstWhere(
      (f) => f.id == folderId,
      orElse: () => Folder(name: "Desconocida", colorValue: 0xFF9E9E9E),
    );
    return folder.name;
  }
}