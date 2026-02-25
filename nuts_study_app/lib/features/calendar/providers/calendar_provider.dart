import 'package:flutter/material.dart';
import 'package:nuts_study_app/core/database/database_helper.dart';
import 'package:nuts_study_app/features/calendar/model/event_model.dart';
import '../../../core/services/notification_service.dart';

class CalendarProvider extends ChangeNotifier {
  // Ahora usamos una lista plana, sqflite la prefiere así
  List<Event> _allEvents = [];

  CalendarProvider() {
    loadEvents(); // Cargamos los datos de SQLite al iniciar
  }

  // Filtrar eventos para la vista del calendario
  List<Event> eventsForDay(DateTime day) {
    return _allEvents.where((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day).toList();
  }

  // CARGAR DE LA BASE DE DATOS
  Future<void> loadEvents() async {
    _allEvents = await DatabaseHelper.getEvents(); // Método que añadimos al Helper
    notifyListeners();
  }

  // AÑADIR Y GUARDAR
  Future<void> addEvent(DateTime fullDate, String title) async {
    // Generamos un ID único como String (compatible con tu tabla events)
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newEvent = Event(
      id: id, 
      title: title, 
      date: fullDate
    );

    // 1. Guardar en SQLite
    await DatabaseHelper.insertEvent(newEvent);
    
    // 2. Actualizar memoria RAM
    _allEvents.add(newEvent);

    // 3. Programar Notificación (convertimos el ID a int para la notificación)
    await NotificationService.scheduleNotification(
      id: int.parse(id.substring(id.length - 8)), // Tomamos los últimos 8 dígitos
      title: title, 
      date: fullDate
    );
    
    notifyListeners();
  }

  // ELIMINAR DE LA BASE DE DATOS
  Future<void> deleteEvent(Event event) async {
    // 1. Eliminar de SQLite
    await DatabaseHelper.deleteEvent(event.id);
    
    // 2. Eliminar de memoria RAM
    _allEvents.removeWhere((e) => e.id == event.id);
    
    // 3. Cancelar Notificación
    await NotificationService.cancelNotification(
      int.parse(event.id.substring(event.id.length - 8))
    );
    
    notifyListeners();
  }
}