import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_detail_page.dart';

import '../../../shared/widgets/add_note_bottom_sheet.dart';
import '../../lists/view/list_detail_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();

    // 🔥 Carga las notas al iniciar
    Future.microtask(() {
      context.read<NotesProvider>().loadNotes();
    });
  }

  Color _getCardColor(int index) {
    const colors = [
      Color(0xFF42A5F5),
      Color(0xFF66BB6A),
      Color(0xFFFFCA28),
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.note_alt, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay notas todavía',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.notes.length,
                  itemBuilder: (context, index) {
                    final note = provider.notes[index];
                    final color = _getCardColor(index);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteDetailPage(note: note),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.8), color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.note_alt, color: Colors.white, size: 30),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  note.title ?? "Sin título",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) {
              return AddNoteBottomSheet(
                onAddNote: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoteDetailPage(),
                    ),
                  );
                },
                onAddList: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ListDetailPage(),
                    ),
                  );
                },
              );
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 0, 224, 19),
        child: const Icon(Icons.add),
      ),
    );
  }
}
