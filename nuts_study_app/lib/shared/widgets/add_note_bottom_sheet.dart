import 'package:flutter/material.dart';

class AddNoteBottomSheet extends StatelessWidget {
  final VoidCallback onAddNote;
  final VoidCallback onAddList;

  const AddNoteBottomSheet({
    super.key,
    required this.onAddNote,
    required this.onAddList,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Nueva nota'),
              onTap: onAddNote,
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Nueva lista'),
              onTap: onAddList,
            ),
          ],
        ),
      ),
    );
  }
}
