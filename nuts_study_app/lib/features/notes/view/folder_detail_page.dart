import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';
import 'note_detail_page.dart';
import '../../folder/model/folder_model.dart';

class FolderDetailPage extends StatelessWidget {
  final Folder folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    // Filtramos las notas de esta carpeta
    final folderNotes = provider.notes.where((n) => n.folderId == folder.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        backgroundColor: Color(folder.colorValue).withOpacity(0.5),
      ),
      body: folderNotes.isEmpty
          ? const Center(child: Text("No hay notas aquí todavía"))
          : ListView.builder(
              itemCount: folderNotes.length,
              itemBuilder: (context, index) {
                final note = folderNotes[index];
                return ListTile(
                  leading: const Icon(Icons.note),
                  title: Text(note.title),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(folder.colorValue),
        child: const Icon(Icons.add),
        onPressed: () {
          // PASAMOS EL ID DE LA MATERIA PARA QUE SE GUARDE DENTRO
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailPage(initialFolderId: folder.id),
            ),
          );
        },
      ),
    );
  }
}