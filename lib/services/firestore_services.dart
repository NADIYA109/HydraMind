import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String userId = 'demo_user'; // temp ...auth later

  /// Save water data
  Future<void> saveWaterData({
    required int intake,
    required int goal,
    required String date,
  }) async {
    await _db.collection('users').doc(userId).set({
      'water': {
        'intake': intake,
        'goal': goal,
        'date': date,
      }
    }, SetOptions(merge: true));
  }


Future<void> resetWaterData() async {
  await _db.collection('users').doc(userId).set({
    'water': {
      'intake': 0,
      'date': DateTime.now().toIso8601String(),
    }
  }, SetOptions(merge: true));
}

  /// Fetch water data
  Future<Map<String, dynamic>?> fetchWaterData() async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['water'];
  }
}
