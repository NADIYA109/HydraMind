import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_model.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];

  int _idCounter = 0;

  String? get _reminderKey {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return null;

    return 'reminders_$userId';
  }

  Future<void> addReminder(TimeOfDay time) async {
    final reminder = ReminderModel(
      id: _idCounter++,
      hour: time.hour,
      minute: time.minute,
      days: [1, 2, 3, 4, 5, 6, 7],
    );

    reminders.add(reminder);

    _sortReminders();

    await scheduleReminder(reminder);
    await _saveReminders();

    notifyListeners();
  }

  Future<void> scheduleReminder(
    ReminderModel reminder,
  ) async {
    if (!reminder.isEnabled) return;

    final time = TimeOfDay(
      hour: reminder.hour,
      minute: reminder.minute,
    );

    await Future.wait(
      reminder.days.map((day) {
        final uniqueId = reminder.id * 10 + day;

        return NotificationHelper.instance.scheduleWeekly(
          id: uniqueId,
          time: time,
          weekday: day,
        );
      }),
    );
  }

  void _sortReminders() {
    reminders.sort((a, b) {
      final aTime = a.hour * 60 + a.minute;
      final bTime = b.hour * 60 + b.minute;

      return aTime.compareTo(bTime);
    });
  }

  Future<void> toggleReminder(
    ReminderModel reminder,
    bool value,
  ) async {
    reminder.isEnabled = value;

    if (value) {
      await scheduleReminder(reminder);
    } else {
      await cancelReminder(reminder);
    }

    _sortReminders();

    await _saveReminders();

    notifyListeners();
  }

  Future<void> cancelReminder(
    ReminderModel reminder,
  ) async {
    await Future.wait(
      reminder.days.map((day) {
        final id = reminder.id * 10 + day;

        return NotificationHelper.instance.cancelById(id);
      }),
    );
  }

  void toggleExpand(ReminderModel reminder) {
    reminder.isExpanded = !reminder.isExpanded;

    notifyListeners();
  }

  Future<void> toggleDay(
    ReminderModel reminder,
    int day,
  ) async {
    // Keep at least one reminder day selected
    if (reminder.days.contains(day) && reminder.days.length == 1) {
      return;
    }

    final notificationId = reminder.id * 10 + day;

    if (reminder.days.contains(day)) {
      await NotificationHelper.instance.cancelById(
        notificationId,
      );

      reminder.days.remove(day);
    } else {
      reminder.days.add(day);

      if (reminder.isEnabled) {
        final time = TimeOfDay(
          hour: reminder.hour,
          minute: reminder.minute,
        );

        await NotificationHelper.instance.scheduleWeekly(
          id: notificationId,
          time: time,
          weekday: day,
        );
      }
    }

    await _saveReminders();

    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final key = _reminderKey;

    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();

    final data = reminders.map((reminder) => reminder.toJson()).toList();

    await prefs.setString(
      key,
      jsonEncode(data),
    );
  }

  Future<void> deleteReminder(
    ReminderModel reminder,
  ) async {
    await cancelReminder(reminder);

    reminders.remove(reminder);

    await _saveReminders();

    notifyListeners();
  }

  Future<void> loadReminders() async {
    final key = _reminderKey;

    if (key == null) {
      reminders = [];
      _idCounter = 0;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString(key);

    // Migrate reminders saved by older app versions
    if (data == null) {
      final oldData = prefs.getString('reminders');

      if (oldData != null) {
        data = oldData;

        await prefs.setString(
          key,
          oldData,
        );

        await prefs.remove('reminders');
      }
    }

    if (data == null) {
      reminders = [];
      _idCounter = 0;
      notifyListeners();
      return;
    }

    final List<dynamic> decoded = jsonDecode(data);

    reminders = decoded.map((item) => ReminderModel.fromJson(item)).toList();

    _sortReminders();

    if (reminders.isNotEmpty) {
      final maxId = reminders
          .map((reminder) => reminder.id)
          .reduce((a, b) => a > b ? a : b);

      _idCounter = maxId + 1;
    } else {
      _idCounter = 0;
    }

    notifyListeners();
  }

  /// Restore scheduled notifications after login
  Future<void> restoreReminderSchedules() async {
    for (final reminder in reminders) {
      if (reminder.isEnabled) {
        await scheduleReminder(reminder);
      }
    }
  }

  Future<void> clearForLogout() async {
    for (final reminder in List<ReminderModel>.from(reminders)) {
      await cancelReminder(reminder);
    }

    reminders = [];
    _idCounter = 0;

    notifyListeners();
  }

  Future<void> updateReminderTime(
    ReminderModel reminder,
    TimeOfDay newTime,
  ) async {
    await cancelReminder(reminder);

    reminder.hour = newTime.hour;
    reminder.minute = newTime.minute;

    if (reminder.isEnabled) {
      await scheduleReminder(reminder);
    }

    _sortReminders();

    await _saveReminders();

    notifyListeners();
  }
}
