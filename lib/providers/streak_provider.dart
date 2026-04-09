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

    // sort latest first
    logs.sort((a, b) => b['date'].compareTo(a['date']));

    DateTime? prevDate;

    for (var log in logs) {
      DateTime currentDate = DateTime.parse(log['date']);

      int intake = log['intake'] ?? 0;
      int goal = log['goal'] ?? 0;

      if (prevDate != null) {
        final diff = prevDate.difference(currentDate).inDays;

        if (diff != 1) break; // gap -> streak break
      }

      if (intake >= goal) {
        streak++;
        prevDate = currentDate;
      } else {
        break; // goal miss -> break
      }
    }

    return streak;
  }
}
