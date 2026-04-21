import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementProvider extends ChangeNotifier {
  List<String> unlockedBadges = [];
  List<String> previousBadges = [];

  Set<String> shownBadges = {};
  int lastCheckedStreak = -1;
  bool isLoaded = false;
  bool isBadgesLoaded = false;

  AchievementProvider() {
    loadShownBadges();
    loadUnlockedBadges();
  }

  void checkAchievements(int streak) {
    previousBadges = List.from(unlockedBadges);
    if (streak >= 1 && !unlockedBadges.contains("Starter 💧")) {
      unlockedBadges.add("Starter 💧");
    }

    if (streak >= 3 && !unlockedBadges.contains("Consistent 👍")) {
      unlockedBadges.add("Consistent 👍");
    }

    if (streak >= 7 && !unlockedBadges.contains("Strong 🔥")) {
      unlockedBadges.add("Strong 🔥");
    }

    if (streak >= 14 && !unlockedBadges.contains("Pro 💪")) {
      unlockedBadges.add("Pro 💪");
    }

    if (streak >= 30 && !unlockedBadges.contains("Master 💎")) {
      unlockedBadges.add("Master 💎");
    }

    saveUnlockedBadges();

    notifyListeners();
  }

  Future<void> loadShownBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('shownBadges') ?? [];
    shownBadges = data.toSet();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> loadUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('unlockedBadges') ?? [];

    unlockedBadges = data;
    isBadgesLoaded = true;

    notifyListeners();
  }

  Future<void> saveUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlockedBadges', unlockedBadges);
  }

  Future<void> saveShownBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('shownBadges', shownBadges.toList());
  }
}
