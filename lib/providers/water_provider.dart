import 'package:flutter/material.dart';
import 'package:hydramind/services/firestore_services.dart';
import '../services/firestore_services.dart';
import 'package:intl/intl.dart';

class WaterProvider extends ChangeNotifier {
  int _currentIntake = 0;
  int _dailyGoal = 2000;

  final FirestoreService _firestoreService = FirestoreService();

  int get currentIntake => _currentIntake;
  int get dailyGoal => _dailyGoal;

  double get progress =>
      _dailyGoal == 0 ? 0 : _currentIntake / _dailyGoal;

  String get today =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  void calculateDailyGoal({
    required int weight,
    required String activity,
  }) {
    int base = weight * 35;
    int extra = activity == 'High'
        ? 500
        : activity == 'Moderate'
            ? 300
            : 0;

    _dailyGoal = base + extra;
  _currentIntake = 0;


    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    _currentIntake += amount;
    if (_currentIntake > _dailyGoal) {
      _currentIntake = _dailyGoal;
    }

    await _firestoreService.saveWaterData(
      intake: _currentIntake,
      goal: _dailyGoal,
      date: today,
    );

    notifyListeners();
  }

  /// Load saved data on app start
  Future<void> loadWaterData() async {
   final data = await _firestoreService.fetchWaterData();

  if (data != null && data['date'] == today) {
    _currentIntake = data['intake'] ?? 0;
    _dailyGoal = data['goal'] ?? _dailyGoal;
  } else {
    //New day / first time user
    _currentIntake = 0;
  }

  notifyListeners();
  }

  Future<void> resetDailyWater() async {
  _currentIntake = 0;
  await _firestoreService.saveWaterData(
    intake: 0,
    goal: _dailyGoal,
    date: today,
  );
  notifyListeners();
}

}
