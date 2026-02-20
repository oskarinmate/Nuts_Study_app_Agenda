import 'package:flutter/material.dart';
import 'package:nuts_study_app/features/lists/view/list_page.dart';
import 'package:nuts_study_app/features/notes/provider/notes_provider.dart';
import 'package:provider/provider.dart';

import '../features/lists/providers/list_provider.dart';
import '../features/notes/view/notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      NotesPage(),
      ListsPage(),
    ];

    // 🔥 CARGA GLOBAL AL INICIAR LA APP
    Future.microtask(() {
      context.read<NotesProvider>().loadNotes();
      //context.read<ListProvider>().loadLists();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _pages[_currentIndex],
    appBar: AppBar(
      title: Text(_currentIndex == 0 ? 'Mis notas' : 'Mis listas'),
      backgroundColor: const Color.fromARGB(255, 4, 107, 67), // 🌈 Color más vivo
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color.fromARGB(255, 3, 209, 192), // Color del icono seleccionado
      unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
      backgroundColor: const Color.fromARGB(255, 4, 107, 67), // Fondo del BottomNavigationBar
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Notas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist),
          label: 'Listas',
        ),
      ],
    ),
  );
}

}
