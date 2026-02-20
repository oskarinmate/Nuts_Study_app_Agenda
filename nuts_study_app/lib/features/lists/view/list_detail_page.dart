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

    _titleController = TextEditingController(
      text: widget.list?.title ?? '',
    );

    if (widget.list != null && widget.list!.id != null) {
      isNew = false;
      listId = widget.list!.id;

      Future.microtask(() {
        context.read<ListItemsProvider>().loadItems(listId!);
      });
    }
  }

  Future<void> _saveList() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final listProvider = context.read<ListProvider>();

    if (isNew) {
      final newList = await listProvider.addListAndReturn(title);
      listId = newList.id;
      isNew = false;

      context.read<ListItemsProvider>().loadItems(listId!);
    } else {
      await listProvider.updateList(listId!, title);
    }

    setState(() {});
  }

  void _addItemDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo elemento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej. Comprar leche',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

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
  void _confirmDelete() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar lista'),
      content: const Text(
        'Esta acción eliminará la lista y todos sus elementos. ¿Deseas continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            await context.read<ListProvider>().deleteList(listId!);
            Navigator.pop(context); // cerrar dialog
            Navigator.pop(context); // volver a la pantalla anterior
          },
          child: const Text('Eliminar'),
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveList,
          ),
          if (!isNew)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      floatingActionButton: !isNew
          ? FloatingActionButton(
              onPressed: _addItemDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título de la lista',
              ),
              onSubmitted: (_) => _saveList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: itemsProvider.items.isEmpty
                  ? const Center(
                      child: Text('No hay elementos'),
                    )
                  : ListView.builder(
                      itemCount: itemsProvider.items.length,
                      itemBuilder: (_, index) {
                        final item = itemsProvider.items[index];
                        return CheckboxListTile(
                          value: item.isDone,
                          title: Text(item.text),
                          onChanged: (_) {
                            itemsProvider.toggleItem(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
