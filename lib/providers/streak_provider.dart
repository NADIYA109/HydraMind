import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakProvider extends ChangeNotifier {
  int _streak = 0;

  int get streak => _streak;

  /// ================= FETCH + CALCULATE =================
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

  /// ================= STREAK LOGIC =================
  int _calculateStreak(List<Map<String, dynamic>> logs) {
    int streak = 0;

    if (logs.isEmpty) return 0;

    // sort latest first
    logs.sort((a, b) => b['date'].compareTo(a['date']));

    DateTime today = DateTime.now();

    //  Check if today exists & completed
    Map<String, dynamic>? todayLog;

    for (var log in logs) {
      DateTime date = DateTime.parse(log['date']);

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        todayLog = log;
        break;
      }
    }

    if (todayLog == null) return 0;

    int intake = todayLog['intake'] ?? 0;
    int goal = todayLog['goal'] ?? 0;

    if (intake < goal) return 0;

    // count streak from today backwards
    DateTime prevDate = DateTime.parse(todayLog['date']);
    streak = 1;

    for (var log in logs.skip(1)) {
      DateTime currentDate = DateTime.parse(log['date']);

      final diff = prevDate.difference(currentDate).inDays;

      int intake = log['intake'] ?? 0;
      int goal = log['goal'] ?? 0;

      if (diff == 1 && intake >= goal) {
        streak++;
        prevDate = currentDate;
      } else {
        break;
      }
    }

    return streak;
  }
}
