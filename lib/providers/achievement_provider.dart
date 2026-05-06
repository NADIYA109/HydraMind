import 'package:flutter/material.dart';
import 'package:hydramind/services/firestore_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementProvider extends ChangeNotifier {
  List<String> unlockedBadges = [];
  List<String> previousBadges = [];

  Set<String> shownBadges = {};
  int lastCheckedStreak = -1;
  bool isLoaded = false;
  bool isBadgesLoaded = false;
  final FirestoreService _firestoreService = FirestoreService();

  AchievementProvider() {
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
    final data = await _firestoreService.fetchAchievements();

    if (data != null) {
      unlockedBadges = List<String>.from(data['unlockedBadges'] ?? []);
      shownBadges = Set<String>.from(data['shownBadges'] ?? []);
    }

    isBadgesLoaded = true;
    notifyListeners();
  }

  Future<void> saveUnlockedBadges() async {
    await _firestoreService.saveAchievements(
      unlockedBadges: unlockedBadges,
      shownBadges: shownBadges.toList(),
    );
  }

  Future<void> saveShownBadges() async {
    await _firestoreService.saveAchievements(
      unlockedBadges: unlockedBadges,
      shownBadges: shownBadges.toList(),
    );
  }

  void resetAchievements() {
    unlockedBadges = [];
    shownBadges = {};
    lastCheckedStreak = -1;
    isBadgesLoaded = false;
    notifyListeners();
  }
}
