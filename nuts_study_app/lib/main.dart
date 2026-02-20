import 'package:flutter/material.dart';
import 'package:nuts_study_app/features/notes/provider/notes_provider.dart';
import 'package:provider/provider.dart';

import 'home/home_page.dart';
import 'features/lists/providers/list_provider.dart';
import 'features/lists/providers/list_items_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProvider(create: (_) => ListItemsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(), // 👈 CLAVE
      ),
    );
  }
}
