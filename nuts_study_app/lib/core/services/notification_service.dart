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
      // FIX: Convertimos a String para evitar error de tipo
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings()),
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      
      const channel = AndroidNotificationChannel('RECORDATORIO!!!!', 'Recuerda', importance: Importance.max);
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  static Future<void> scheduleNotification({required int id, required String title, required DateTime date}) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id, "RECORDATORIO!!!!", title, scheduledDate,
      const NotificationDetails(android: AndroidNotificationDetails('RECORDATORIO!!!!', 'Recuerda', importance: Importance.max, priority: Priority.high)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async => await _notifications.cancel(id);
}