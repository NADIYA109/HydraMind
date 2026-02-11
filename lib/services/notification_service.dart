import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  NotificationHelper._internal();
  static final NotificationHelper instance = NotificationHelper._internal();

  FlutterLocalNotificationsPlugin? _plugin;

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

  /// SCHEDULE REMINDER
  Future<void> scheduleAt(TimeOfDay time) async {
    if (_plugin == null) throw Exception('Notification plugin not initialized');

    final now = tz.TZDateTime.now(tz.local);

    // Create the scheduled time for today
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule it for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('Current Time: $now');
    debugPrint('Scheduled for: $scheduled');

    const androidDetails = AndroidNotificationDetails(
      'daily_water_reminder', // Channel ID
      'Water Reminders', // Channel Name
      channelDescription: 'Hydration reminders for HydraApp',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    await _plugin!.zonedSchedule(
      1,
      'Hydration Reminder 💧',
      'Time to drink water!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Important Reminders',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// CANCEL ALL
  Future<void> cancelAll() async {
    await _plugin?.cancelAll();
  }
}
