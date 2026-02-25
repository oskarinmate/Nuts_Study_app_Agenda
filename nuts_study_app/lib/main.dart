import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Imports de tu proyecto
import 'core/services/notification_service.dart';
import 'features/calendar/providers/calendar_provider.dart';
import 'features/notes/provider/notes_provider.dart';
import 'features/lists/providers/list_provider.dart';
import 'features/lists/providers/list_items_provider.dart';
import 'home/home_page.dart';

Future<void> main() async {
  // 1. Inicializar el binding de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar servicios de forma segura
  try {
    await NotificationService.init();
    await initializeDateFormatting('es_ES', '');
  } catch (e) {
    debugPrint("Error durante la inicialización: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Si usas alguna librería como ScreenUtil, asegúrate de que esté aquí.
    // Si no, el MultiProvider debe ser el padre directo del MaterialApp.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProvider(create: (_) => ListItemsProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nuts Study App',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        // Delegados para evitar errores de idioma
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),
        home: const HomePage(),
      ),
    );
  }
}