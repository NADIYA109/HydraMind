import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  NotificationHelper._internal();
  static final NotificationHelper instance = NotificationHelper._internal();

  FlutterLocalNotificationsPlugin? _plugin;

  Future<void> cancelAll() async {
    if (_plugin == null) return;

    await _plugin!.cancelAll();
  }

  Future<void> cancelById(int id) async {
    if (_plugin == null) return;
    await _plugin!.cancel(id);
  }

  Future<void> initNotifications() async {
    _plugin = FlutterLocalNotificationsPlugin();

    // 1. Initialize Timezones
    tz.initializeTimeZones();

    // 2. Set the local location with a safety net
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // If "Asia/Calcutta" fails, fallback to "Asia/Kolkata" or UTC
      debugPrint("Timezone lookup failed, falling back to Kolkata: $e");
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _plugin!.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification Tapped: ${details.payload}");
      },
    );
  }

  /// PERMISSIONS – Call this to handle Android 13+ and Android 14+
  Future<void> requestPermission() async {
    final androidPlugin = _plugin?.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Request standard notification permission (Android 13+)
    await androidPlugin?.requestNotificationsPermission();

    // Request Exact Alarm permission (Android 14+)
    // This will open the system settings for the user if not granted
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleWeekly({
    required int id,
    required TimeOfDay time,
    required int weekday, // 1=Mon ... 7=Sun
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = _nextInstanceOfWeekday(time, weekday);

    await _plugin!.zonedSchedule(
      id,
      'Hydration Reminder 💧',
      'Time to drink water!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, //  KEY
    );
  }

  tz.TZDateTime _nextInstanceOfWeekday(TimeOfDay time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
