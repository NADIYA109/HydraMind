import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Map<String, dynamic>> _weeklyData = [];

  List<Map<String, dynamic>> get weeklyData => _weeklyData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadWeeklyReport() async {
    _isLoading = true;
    notifyListeners();

    _weeklyData = await _service.fetchWeeklyLogs();

    _isLoading = false;
    notifyListeners();
  }

  int calculateStreak(List<Map<String, dynamic>> data) {
    int streak = 0;

    // check in reverse
    for (int i = data.length - 1; i >= 0; i--) {
      final intake = data[i]['intake'] ?? 0;
      final goal = data[i]['goal'] ?? 1;

      if (intake >= goal) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
