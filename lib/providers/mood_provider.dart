import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodProvider extends ChangeNotifier {
  String? _mood;          
  int _energyLevel = 3;  
  String _date = _today();

  String? get mood => _mood;
  int get energyLevel => _energyLevel;
  String get date => _date;

  /// Set mood
  void setMood(String value) {
    _mood = value;
    notifyListeners();
  }

  /// Set energy level
  void setEnergyLevel(int value) {
    _energyLevel = value;
    notifyListeners();
  }

  /// Reset daily mood (future use)
  void resetMood() {
    _mood = null;
    _energyLevel = 3;
    _date = _today();
    notifyListeners();
  }

  /// Helper: today's date
  static String _today() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
