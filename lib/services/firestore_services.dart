import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Save water data
  Future<void> saveWaterData({
    required int intake,
    required int goal,
    required String date,
  }) async {
    if (_userId == null) return;

    await _db.collection('users').doc(_userId).set({
      'water': {
        'intake': intake,
        'goal': goal,
        'date': date,
      }
    }, SetOptions(merge: true));
  }

  /// Reset water data
  Future<void> resetWaterData() async {
    if (_userId == null) return;

    await _db.collection('users').doc(_userId).set({
      'water': {
        'intake': 0,
        'date': DateTime.now().toIso8601String(),
      }
    }, SetOptions(merge: true));
  }

  /// Fetch water data
  Future<Map<String, dynamic>?> fetchWaterData() async {
    if (_userId == null) return null;

    final doc = await _db.collection('users').doc(_userId).get();
    return doc.data()?['water'];
  }
}
