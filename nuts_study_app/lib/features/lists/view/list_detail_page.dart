import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_list_model.dart';
import '../providers/list_provider.dart';
import '../providers/list_items_provider.dart';

class ListDetailPage extends StatefulWidget {
  final NoteList? list;

  const ListDetailPage({super.key, this.list});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late TextEditingController _titleController;
  bool isNew = true;
  int? listId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.list?.title ?? '');

    if (widget.list != null && widget.list!.id != null) {
      isNew = false;
      listId = widget.list!.id;
      Future.microtask(() {
        context.read<ListItemsProvider>().loadItems(listId!);
      });
    } else {
      // Si es nueva, nos aseguramos de que la lista de items esté limpia
      Future.microtask(() {
        context.read<ListItemsProvider>().clearItems(); 
      });
    }
  }

  // Función de guardado optimizada
  Future<void> _saveList() async {
    final title = _titleController.text.trim().isEmpty 
        ? "Nueva Lista" 
        : _titleController.text.trim();

    final listProvider = context.read<ListProvider>();

    if (isNew) {
      final newList = await listProvider.addListAndReturn(title);
      listId = newList.id;
      isNew = false;
      if (mounted) context.read<ListItemsProvider>().loadItems(listId!);
    } else {
      await listProvider.updateList(listId!, title);
    }
    setState(() {});
  }

  void _addItemDialog() async {
    // IMPORTANTE: Si es nueva y el usuario intenta añadir un item, 
    // guardamos la lista primero para obtener un listId
    if (isNew) {
      await _saveList();
    }

    if (!mounted) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo elemento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          autocorrect: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ej. Comprar leche'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              
              // Ahora listId ya no es nulo porque _saveList se ejecutó arriba
              context.read<ListItemsProvider>().addItem(
                    listId!,
                    controller.text.trim(),
                  );

              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ListItemsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nueva lista' : 'Editar lista'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      // El botón flotante ahora siempre está disponible
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la lista',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: itemsProvider.items.isEmpty
                  ? const Center(child: Text('No hay elementos'))
                  : ListView.builder(
                      itemCount: itemsProvider.items.length,
                      itemBuilder: (_, index) {
                        final item = itemsProvider.items[index];
                        return CheckboxListTile(
                          value: item.isDone,
                          title: Text(item.text),
                          onChanged: (_) => itemsProvider.toggleItem(item),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            
            // BOTÓN GUARDAR ABAJO ESTILO NOTAS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveList();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: const Text('¿Deseas eliminar esta lista?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<ListProvider>().deleteList(listId!);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}