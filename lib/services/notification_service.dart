import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  NotificationHelper._internal();

  static final NotificationHelper instance = NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initNotifications() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timeZoneName),
      );
    } catch (e) {
      debugPrint(
        'Timezone lookup failed: $e',
      );

      tz.setLocalLocation(
        tz.getLocation('Asia/Kolkata'),
      );
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint(
          'Notification tapped: ${details.payload}',
        );
      },
    );

    _initialized = true;
  }

  Future<void> requestPermission() async {
    await initNotifications();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> cancelAll() async {
    await initNotifications();

    await _plugin.cancelAll();
  }

  Future<void> cancelById(int id) async {
    await initNotifications();

    await _plugin.cancel(id);
  }

  Future<void> scheduleWeekly({
    required int id,
    required TimeOfDay time,
    required int weekday,
  }) async {
    await initNotifications();

    final scheduledDate = _nextInstanceOfWeekday(
      time,
      weekday,
    );
    await _plugin.zonedSchedule(
      id,
      'Hydration Reminder 💧',
      'Time to drink water!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminder',
          channelDescription: 'Hydration reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfWeekday(
    TimeOfDay time,
    int weekday,
  ) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(
        const Duration(days: 1),
      );
    }
    return scheduled;
  }
}
