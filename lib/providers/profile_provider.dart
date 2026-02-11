import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileProvider extends ChangeNotifier {
  String? _name;
  int? _age;
  int? _weight;
  String? _activity;
  String? _photoPath;

  bool _isLoading = false;

  String? get name => _name;
  int? get age => _age;
  int? get weight => _weight;
  String? get activity => _activity;
  String? get photoPath => _photoPath;
  bool get isLoading => _isLoading;

  /// SAVE PROFILE (LOCAL IMAGE PATH)
  Future<void> saveProfile({
    required String name,
    required int age,
    required int weight,
    required String activity,
    String? photoPath,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'age': age,
      'weight': weight,
      'activity': activity,
      'photoPath': photoPath,
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _name = name;
    _age = age;
    _weight = weight;
    _activity = activity;
    _photoPath = photoPath;

    _isLoading = false;
    notifyListeners();
  }

  /// LOAD PROFILE
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      _name = data?['name'];
      _age = data?['age'];
      _weight = data?['weight'];
      _activity = data?['activity'];
      _photoPath = data?['photoPath'];
    }

    _isLoading = false;
    notifyListeners();
  }
}
