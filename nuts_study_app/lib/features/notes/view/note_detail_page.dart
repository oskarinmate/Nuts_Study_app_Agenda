import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/note_model.dart';
import '../provider/notes_provider.dart';
import 'package:nuts_study_app/core/services/pdf_service.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note;
  final int? initialFolderId; // Para saber en qué carpeta guardar

  const NoteDetailPage({super.key, this.note, this.initialFolderId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotesProvider>();
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar nota' : 'Nueva nota'),
        actions: isEditing ? [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PdfService.exportNote(widget.note!),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await provider.deleteNote(widget.note!.id!);
              Navigator.pop(context);
            },
          ),
        ] : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;

                if (isEditing) {
                  await provider.updateNote(
                    widget.note!.id!,
                    titleCtrl.text,
                    contentCtrl.text,
                    folderId: widget.note!.folderId, // Mantiene su materia
                  );
                } else {
                  await provider.addNote(
                    titleCtrl.text,
                    contentCtrl.text,
                    folderId: widget.initialFolderId, // Guarda en la materia donde estamos
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}