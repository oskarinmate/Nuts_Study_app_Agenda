import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';
import 'note_detail_page.dart';
import '../../../data/models/note_model.dart';
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
    Future.microtask(() => context.read<NotesProvider>().loadNotes());
  }

  Color _getCardColor(int index) {
    const colors = [Color(0xFF42A5F5), Color(0xFF66BB6A), Color(0xFFFFCA28), Color(0xFFAB47BC), Color(0xFFFF7043)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: NoteSearch(provider.notes)),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.notes.length,
                  itemBuilder: (context, index) {
                    final note = provider.notes[index];
                    final color = _getCardColor(index);

                    return Dismissible(
                      key: Key('note_${note.id}'),
                      direction: DismissDirection.endToStart,
                      background: _buildDeleteBackground(),
                      onDismissed: (_) => provider.deleteNote(note.id!),
                      child: _buildNoteCard(note, color),
                    );
                  },
                ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildNoteCard(Note note, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailPage(note: note))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.note_alt, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Text(note.title ?? "Sin título", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt, size: 80, color: Colors.grey),
          Text('No hay notas todavía', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(255, 0, 224, 19),
      onPressed: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => AddNoteBottomSheet(
          onAddNote: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteDetailPage())); },
          onAddList: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ListDetailPage())); },
        ),
      ),
      child: const Icon(Icons.note_alt),
    );
  }
}

// BUSCADOR DE NOTAS
class NoteSearch extends SearchDelegate {
  final List<Note> notes;
  NoteSearch(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => _buildList(context);
  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = notes.where((n) => (n.title?.toLowerCase() ?? "").contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(filtered[i].title ?? ""),
        onTap: () { close(context, null); Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailPage(note: filtered[i]))); },
      ),
    );
  }
}