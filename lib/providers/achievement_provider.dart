import 'package:flutter/material.dart';

class AchievementProvider extends ChangeNotifier {
  List<String> unlockedBadges = [];
  List<String> previousBadges = [];
  Set<String> shownBadges = {};
  int lastCheckedStreak = -1;

  void checkAchievements(int streak) {
    previousBadges = List.from(unlockedBadges);

    unlockedBadges.clear();

    if (streak >= 1) unlockedBadges.add("Starter 💧");
    if (streak >= 3) unlockedBadges.add("Consistent 👍");
    if (streak >= 7) unlockedBadges.add("Strong 🔥");
    if (streak >= 14) unlockedBadges.add("Pro 💪");
    if (streak >= 30) unlockedBadges.add("Master 💎");

    notifyListeners();
  }
}
