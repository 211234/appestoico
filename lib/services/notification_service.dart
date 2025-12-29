import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    // Configuración de Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuración de iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar cuando el usuario toca la notificación
      },
    );

    _initialized = true;
  }

  // Programar una notificación diaria
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time, required TimeOfDay scheduledTime,
  }) async {
    await initialize();

    // Convertir TimeOfDay a DateTime de hoy
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si ya pasó la hora de hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Convertir a TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Recordatorios Diarios',
          channelDescription: 'Recordatorios estoicos diarios',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF8C00),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
    );

    // Guardar en preferencias
    await _saveScheduledNotification(id, title, body, time);
  }

  // Cancelar una notificación
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _removeScheduledNotification(id);
  }

  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_notifications');
  }

  // Obtener notificaciones programadas
  static Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('scheduled_notifications');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Guardar notificación programada en preferencias
  static Future<void> _saveScheduledNotification(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getScheduledNotifications();

    // Remover si ya existe
    notifications.removeWhere((n) => n['id'] == id);

    // Agregar nueva
    notifications.add({
      'id': id,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
    });

    await prefs.setString('scheduled_notifications', jsonEncode(notifications));
  }

  // Remover notificación de preferencias
  static Future<void> _removeScheduledNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getScheduledNotifications();
    notifications.removeWhere((n) => n['id'] == id);
    await prefs.setString('scheduled_notifications', jsonEncode(notifications));
  }

  // Verificar si hay una notificación programada para un ID
  static Future<bool> hasScheduledNotification(int id) async {
    final notifications = await getScheduledNotifications();
    return notifications.any((n) => n['id'] == id);
  }

  // Obtener hora programada para una notificación
  static Future<TimeOfDay?> getScheduledTime(int id) async {
    final notifications = await getScheduledNotifications();
    final notification = notifications.firstWhere(
      (n) => n['id'] == id,
      orElse: () => {},
    );

    if (notification.isEmpty) return null;

    return TimeOfDay(
      hour: notification['hour'] as int,
      minute: notification['minute'] as int,
    );
  }

  // Reprogramar todas las notificaciones (útil después de reiniciar la app)
  static Future<void> rescheduleAllNotifications() async {
    final notifications = await getScheduledNotifications();
    for (final notification in notifications) {
      await scheduleDailyNotification(
        id: notification['id'] as int,
        title: notification['title'] as String,
        body: notification['body'] as String,
        time: TimeOfDay(
          hour: notification['hour'] as int,
          minute: notification['minute'] as int,
        ),
        scheduledTime: TimeOfDay(
          hour: notification['hour'] as int,
          minute: notification['minute'] as int,
        ),
      );
    }
  }

  // Generar ID único para cada recordatorio
  static int getReminderNotificationId(String reminderKey) {
    // Convertir el string a un hash numérico
    return reminderKey.hashCode.abs() % 1000000;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {}

  static getChallengeNotificationId(String challengeKey) {}
}
