import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';
// ✅ IMPORTA AQUÍ TU BUSCADOR (Ajusta la ruta si es necesario)
import 'event_search_delegate.dart'; 

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _titleController = TextEditingController();

  void _showAddEventDialog() {
    DateTime temporaryDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Selecciona Hora y Título",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: temporaryDateTime,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newDateTime) {
                  temporaryDateTime = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    newDateTime.hour,
                    newDateTime.minute,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                autocorrect: true,
                enableSuggestions: true,
                textCapitalization: TextCapitalization.sentences,
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Título del recordatorio",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCELAR"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty) return;
                      context.read<CalendarProvider>().addEvent(
                            temporaryDateTime,
                            _titleController.text,
                          );
                      _titleController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("GUARDAR"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final events = provider.eventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario"),
        // ✅ BOTÓN DE BÚSQUEDA AGREGADO
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
            // 1. Ahora usamos 'allEvents' que es el getter que creamos en el Provider
            final eventsList = provider.allEvents; 
            
            // 2. Abrimos el buscador pasándole la lista directamente
            final selectedEvent = await showSearch(
              context: context,
              delegate: EventSearchDelegate(eventsList),
            );

            // 3. Si seleccionó un evento, movemos el calendario a esa fecha
            if (selectedEvent != null) {
              setState(() {
                _selectedDay = selectedEvent.date;
                _focusedDay = selectedEvent.date;
              });
            }
          },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: provider.eventsForDay,
            onDaySelected: (s, f) => setState(() {
              _selectedDay = s;
              _focusedDay = f;
            }),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const Divider(),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("Sin eventos para hoy"))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final e = events[index];
                      final isPast = e.date.isBefore(DateTime.now());
                      return ListTile(
                        leading: Icon(Icons.alarm, color: isPast ? Colors.grey : Colors.blue),
                        title: Text(
                          e.title,
                          style: TextStyle(decoration: isPast ? TextDecoration.lineThrough : null),
                        ),
                        subtitle: Text(DateFormat('hh:mm a').format(e.date)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.deleteEvent(e),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 224, 19),
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}