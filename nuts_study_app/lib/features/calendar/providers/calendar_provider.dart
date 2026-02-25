import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

class CalendarEvent {
  final int id;
  final String title;
  final DateTime date;
  CalendarEvent({required this.id, required this.title, required this.date});
}

class CalendarProvider extends ChangeNotifier {
  final Map<DateTime, List<CalendarEvent>> _events = {};

  List<CalendarEvent> eventsForDay(DateTime day) {
    // Normalizamos la fecha (solo año, mes, día) para usarla como llave
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  Future<void> addEvent(DateTime fullDate, String title) async {
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newEvent = CalendarEvent(id: id, title: title, date: fullDate);

    final dateKey = DateTime(fullDate.year, fullDate.month, fullDate.day);
    _events.putIfAbsent(dateKey, () => []).add(newEvent);

    await NotificationService.scheduleNotification(id: id, title: title, date: fullDate);
    notifyListeners();
  }

  Future<void> deleteEvent(CalendarEvent event) async {
    final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
    _events[dateKey]?.removeWhere((e) => e.id == event.id);
    await NotificationService.cancelNotification(event.id);
    notifyListeners();
  }
}