import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Save water data
  Future<void> saveWaterData({
    required int intake,
    required int goal,
    required String date,
    String? mood,
    int? energy,
  }) async {
    if (_userId == null) return;

    await _db.collection('users').doc(_userId).set({
      'water': {
        'intake': intake,
        'goal': goal,
        'date': date,
      }
    }, SetOptions(merge: true));

    await saveDailyLog(
      intake: intake,
      goal: goal,
      date: date,
      mood: mood,
      energy: energy,
    );
  }

  /// Reset water data
  Future<void> resetWaterData() async {
    if (_userId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await _db.collection('users').doc(_userId).set({
      'water': {
        'intake': 0,
        'date': today,
      }
    }, SetOptions(merge: true));
  }

  /// Fetch water data
  Future<Map<String, dynamic>?> fetchWaterData() async {
    if (_userId == null) return null;

    final doc = await _db.collection('users').doc(_userId).get();
    return doc.data()?['water'];
  }

  Future<void> saveDailyLog({
    required int intake,
    required int goal,
    required String date,
    String? mood,
    int? energy,
  }) async {
    if (_userId == null) return;

    print(" SAVING LOG: $date | $mood | $energy");

    print(" FIRESTORE DAILY LOG SAVED");

    await _db
        .collection('users')
        .doc(_userId)
        .collection('daily_logs')
        .doc(date) // (date as doc id)
        .set({
      'intake': intake,
      'goal': goal,
      'mood': mood ?? "Not Set",
      'energy': energy ?? " 0",
      'date': date,
    }, SetOptions(merge: true));
  }
}
