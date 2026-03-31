import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];

  int _idCounter = 0;

  void addReminder(TimeOfDay time) {
    final reminder = ReminderModel(
      id: _idCounter++,
      hour: time.hour,
      minute: time.minute,
      days: [1, 2, 3, 4, 5, 6, 7],
    );

    reminders.add(reminder);

    _sortReminders();

    scheduleReminder(reminder); // auto schedule
    _saveReminders();

    notifyListeners();
  }

  void scheduleReminder(ReminderModel reminder) {
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);

    for (int day in reminder.days) {
      final uniqueId = reminder.id * 10 + day; //  unique per day

      NotificationHelper.instance.scheduleWeekly(
        id: uniqueId,
        time: time,
        weekday: day,
      );
    }
  }

  void _sortReminders() {
    reminders.sort((a, b) {
      final aTime = a.hour * 60 + a.minute;
      final bTime = b.hour * 60 + b.minute;
      return aTime.compareTo(bTime);
    });
  }

  void toggleReminder(ReminderModel reminder, bool value) {
    reminder.isEnabled = value;

    if (value) {
      scheduleReminder(reminder); //  schedule all selected days
    } else {
      cancelReminder(reminder); //  cancel all
    }
    _sortReminders(); // keep list ordered
    _saveReminders();

    notifyListeners();
  }

  void cancelReminder(ReminderModel reminder) {
    for (int day in reminder.days) {
      final id = reminder.id * 10 + day;
      NotificationHelper.instance.cancelById(id);
    }
  }

  void toggleExpand(ReminderModel reminder) {
    reminder.isExpanded = !reminder.isExpanded;
    notifyListeners();
  }

  void toggleDay(ReminderModel reminder, int day) {
    if (reminder.days.contains(day)) {
      reminder.days.remove(day);
    } else {
      reminder.days.add(day);
    }
    _saveReminders();

    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();

    final data = reminders.map((e) => e.toJson()).toList();

    prefs.setString('reminders', jsonEncode(data));
  }

  void deleteReminder(ReminderModel reminder) {
    cancelReminder(reminder);
    reminders.remove(reminder);
    _saveReminders();

    notifyListeners();
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('reminders');

    if (data != null) {
      final List decoded = jsonDecode(data);

      reminders = decoded.map((e) => ReminderModel.fromJson(e)).toList();

      _sortReminders();

      notifyListeners();
    }
  }

  Future<void> updateReminderTime(
      ReminderModel reminder, TimeOfDay newTime) async {
    // Cancel old notifications
    cancelReminder(reminder);

    //  Update time
    reminder.hour = newTime.hour;
    reminder.minute = newTime.minute;

    // Reschedule
    if (reminder.isEnabled) {
      scheduleReminder(reminder);
    }

    // Save
    await _saveReminders();

    notifyListeners();
  }
}
