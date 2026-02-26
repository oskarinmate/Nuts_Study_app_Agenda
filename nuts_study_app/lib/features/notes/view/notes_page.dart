import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';
import 'note_detail_page.dart';
import 'folder_detail_page.dart';
import '../../../data/models/note_model.dart';
import '../../../shared/widgets/add_note_bottom_sheet.dart';
import '../../lists/view/list_detail_page.dart';
import 'package:nuts_study_app/features/folder/model/folder_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
    // Cargamos datos al iniciar
    Future.microtask(() {
      final provider = context.read<NotesProvider>();
      provider.loadFolders();
      provider.loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas y Carpetas'),
        actions: [
          // 🔍 BUSCADOR
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context, 
                delegate: NoteSearchDelegate(provider.notes),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _showNewFolderDialog(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (provider.folders.isEmpty && provider.notes.isEmpty)
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    // --- SECCIÓN DE CARPETAS (MATERIAS) ---
                    if (provider.folders.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Carpetas', 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildFolderCard(provider.folders[index]),
                          childCount: provider.folders.length,
                        ),
                      ),
                    ),

                    // --- SECCIÓN DE NOTAS SUELTAS ---
                    if (provider.notes.any((n) => n.folderId == null))
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Notas sueltas', 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final unorganizedNotes = provider.notes.where((n) => n.folderId == null).toList();
                          final note = unorganizedNotes[index];
                          
                          // ✅ DISMISSIBLE RESTAURADO PARA ARRASTRAR Y BORRAR
                          return Dismissible(
                            key: Key('note_${note.id}'),
                            direction: DismissDirection.endToStart,
                            background: _buildDeleteBackground(),
                            onDismissed: (_) {
                              provider.deleteNote(note.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Nota "${note.title}" eliminada')),
                              );
                            },
                            child: _buildNoteCard(note, Colors.blueGrey),
                          );
                        },
                        childCount: provider.notes.where((n) => n.folderId == null).length,
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFolderCard(Folder folder) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FolderDetailPage(folder: folder)),
        );
      },
      // 🔥 BORRAR MATERIA CON PULSACIÓN LARGA
      onLongPress: () => _showDeleteFolderDialog(folder),
      child: Container(
        decoration: BoxDecoration(
          color: Color(folder.colorValue).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(folder.colorValue), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_special, size: 40, color: Color(folder.colorValue)),
            const SizedBox(height: 8),
            Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteFolderDialog(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar materia?'),
        content: Text('Esto no borrará tus notas, solo la carpeta "${folder.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<NotesProvider>().deleteFolder(folder.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    int selectedColor = Colors.blue.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Nueva Materia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Nombre (ej. FISICA)'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map((color) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = color.value),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 15,
                      child: selectedColor == color.value 
                        ? const Icon(Icons.check, size: 16, color: Colors.white) 
                        : null,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty) return;
                context.read<NotesProvider>().addFolder(controller.text, selectedColor);
                Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.note_alt, color: color, size: 30),
        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent, 
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      );

  Widget _buildEmptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey),
            Text('No hay materias ni notas', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );

  Widget _buildFAB(BuildContext context) => FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 224, 19),
        onPressed: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => AddNoteBottomSheet(
            onAddNote: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteDetailPage()));
            },
            onAddList: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ListDetailPage()));
            },
          ),
        ),
        child: const Icon(Icons.add),
      );
}

// 🔥 CLASE DEL BUSCADOR RESTAURADA
class NoteSearchDelegate extends SearchDelegate {
  final List<Note> notes;
  NoteSearchDelegate(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = notes
        .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.note),
        title: Text(results[index].title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailPage(note: results[index])),
          );
        },
      ),
    );
  }
}