import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String? _name;
  int? _age;
  int? _weight;
  String? _activity;

  String? get name => _name;
  int? get age => _age;
  int? get weight => _weight;
  String? get activity => _activity;

  void saveProfile({
    required String name,
    required int age,
    required int weight,
    required String activity,
  }) {
    _name = name;
    _age = age;
    _weight = weight;
    _activity = activity;
    notifyListeners();
  }
}
