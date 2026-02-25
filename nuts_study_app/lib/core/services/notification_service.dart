import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    }

    // 🚩 CAMBIO CLAVE: Cambiamos ic_launcher por launcher_icon
    // Si usaste flutter_launcher_icons, el nombre estándar es launcher_icon
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings, 
        iOS: DarwinInitializationSettings()
      ),
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      // Pedimos los permisos aquí mismo
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      
      const channel = AndroidNotificationChannel(
        'RECORDATORIO!!!!', 
        'Recuerda', 
        importance: Importance.max
      );
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  static Future<void> scheduleNotification({required int id, required String title, required DateTime date}) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id, 
      "RECORDATORIO!!!!", 
      title, 
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'RECORDATORIO!!!!', 
          'Recuerda', 
          importance: Importance.max, 
          priority: Priority.high,
          // 🚩 TAMBIÉN AQUÍ: Aseguramos que use el nuevo icono
          icon: '@mipmap/launcher_icon', 
        )
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async => await _notifications.cancel(id);
}