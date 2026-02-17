import 'package:flutter/material.dart';
import 'package:hydramind/services/firestore_services.dart';
import 'package:intl/intl.dart';

class WaterProvider extends ChangeNotifier {
  int _currentIntakeMl = 0; // Always stored in ML internally
  int _dailyGoalMl = 2000;
  int _recommendedGoalMl =
      2000; // fixed calculated goal // Always stored in ML internally
  String _unit = 'ml'; // ml or oz

  final FirestoreService _firestoreService = FirestoreService();

  // ================== GETTERS ==================

  int get currentIntake =>
      _unit == 'ml' ? _currentIntakeMl : (_currentIntakeMl / 29.57).round();

  int get dailyGoal =>
      _unit == 'ml' ? _dailyGoalMl : (_dailyGoalMl / 29.57).round();

  String get unit => _unit;

  double get progress =>
      _dailyGoalMl == 0 ? 0 : _currentIntakeMl / _dailyGoalMl;

  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get recommendedGoal =>
      _unit == 'ml' ? _recommendedGoalMl : (_recommendedGoalMl / 29.57).round();
  // ================== UNIT CHANGE ==================

  void changeUnit(String newUnit) {
    _unit = newUnit;
    notifyListeners();
  }

  // ================== GOAL CALCULATION ==================

  void calculateDailyGoal({
    required int weight,
    required int age,
    required String activity,
  }) {
    double mlPerKg;

    if (age <= 30) {
      mlPerKg = 40;
    } else if (age <= 55) {
      mlPerKg = 35;
    } else if (age <= 65) {
      mlPerKg = 30;
    } else {
      mlPerKg = 28;
    }

    double baseGoal = weight * mlPerKg;

    double activityExtra;

    switch (activity) {
      case 'High':
        activityExtra = 700;
        break;
      case 'Moderate':
        activityExtra = 400;
        break;
      default:
        activityExtra = 0;
    }

    _recommendedGoalMl = (baseGoal + activityExtra).round();

    // default daily goal equals recommended initially
    _dailyGoalMl = _recommendedGoalMl;

    notifyListeners();
  }

  // ================== MANUAL GOAL UPDATE (SLIDER) ==================

  Future<void> updateDailyGoal(int value) async {
    if (_unit == 'ml') {
      _dailyGoalMl = value;
    } else {
      _dailyGoalMl = (value * 29.57).round();
    }

    await _firestoreService.saveWaterData(
      intake: _currentIntakeMl,
      goal: _dailyGoalMl,
      date: today,
    );

    notifyListeners();
  }

  // ================== ADD WATER ==================

  Future<void> addWater(int amount) async {
    int amountInMl = _unit == 'ml' ? amount : (amount * 29.57).round();

    _currentIntakeMl += amountInMl;

    if (_currentIntakeMl > _dailyGoalMl) {
      _currentIntakeMl = _dailyGoalMl;
    }

    await _firestoreService.saveWaterData(
      intake: _currentIntakeMl,
      goal: _dailyGoalMl,
      date: today,
    );

    notifyListeners();
  }

  // ================== LOAD DATA ==================
  Future<void> loadWaterData() async {
    final data = await _firestoreService.fetchWaterData();

    if (data != null && data['date'] == today) {
      _currentIntakeMl = data['intake'] ?? 0;
      _dailyGoalMl = data['goal'] ?? _dailyGoalMl;
    } else {
      _currentIntakeMl = 0;
    }

    notifyListeners();
  }

  // ================== RESET ==================

  Future<void> resetDailyWater() async {
    _currentIntakeMl = 0;

    await _firestoreService.saveWaterData(
      intake: 0,
      goal: _dailyGoalMl,
      date: today,
    );

    notifyListeners();
  }
}
