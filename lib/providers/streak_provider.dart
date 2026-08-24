import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakProvider extends ChangeNotifier {
  int _streak = 0;

  int get streak => _streak;

  /// FETCH + CALCULATE
  Future<void> loadStreak() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .get();

    final logs = snapshot.docs.map((doc) => doc.data()).toList();

    _streak = _calculateStreak(logs);

    notifyListeners();
  }

  int _calculateStreak(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return 0;

    logs.sort((a, b) => b['date'].compareTo(a['date']));

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    Map<String, dynamic>? todayLog;

    for (final log in logs) {
      final logDate = DateTime.parse(log['date']);

      final normalizedDate = DateTime(
        logDate.year,
        logDate.month,
        logDate.day,
      );

      if (normalizedDate == today) {
        todayLog = log;
        break;
      }
    }

    DateTime expectedDate;

    final todayCompleted = todayLog != null &&
        (todayLog['intake'] ?? 0) >= (todayLog['goal'] ?? 0);

    if (todayCompleted) {
      expectedDate = today;
    } else {
      expectedDate = today.subtract(
        const Duration(days: 1),
      );
    }

    int streak = 0;

    for (final log in logs) {
      final logDate = DateTime.parse(log['date']);

      final normalizedDate = DateTime(
        logDate.year,
        logDate.month,
        logDate.day,
      );

      if (normalizedDate.isAfter(expectedDate)) {
        continue;
      }

      if (normalizedDate != expectedDate) {
        break;
      }

      final intake = log['intake'] ?? 0;
      final goal = log['goal'] ?? 0;

      if (goal <= 0 || intake < goal) {
        break;
      }

      streak++;

      expectedDate = expectedDate.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }
}
