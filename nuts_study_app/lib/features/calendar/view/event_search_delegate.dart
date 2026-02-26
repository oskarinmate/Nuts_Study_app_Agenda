import 'package:flutter/material.dart';
import '../model/event_model.dart'; 

class EventSearchDelegate extends SearchDelegate {
  final List<Event> events;

  EventSearchDelegate(this.events);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear), 
          onPressed: () => query = '', // Limpia el buscador
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null), // Sale del buscador
      );

  @override
  Widget buildResults(BuildContext context) => _buildEventList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildEventList();

  Widget _buildEventList() {
    // 🔥 AQUÍ ES DONDE BUSCAMOS POR NOMBRE
    // Filtramos la lista: si el título contiene lo que escribiste, lo muestra
    final results = events
        .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No se encontraron recordatorios con ese nombre'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          leading: const Icon(Icons.notifications_active, color: Colors.deepPurple),
          title: Text(event.title), // Muestra el Nombre/Título
          subtitle: Text("Fecha: ${event.date.toString().split(' ')[0]}"), // Muestra la fecha abajo
          onTap: () {
            // Al tocarlo, cerramos el buscador y devolvemos el evento
            close(context, event);
          },
        );
      },
    );
  }
}