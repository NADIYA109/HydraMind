import 'package:cloud_firestore/cloud_firestore.dart';

class WaterEntry {
  final String id;
  final int amountMl;
  final DateTime createdAt;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.createdAt,
  });

  /// Create water entry from Firestore data
  factory WaterEntry.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return WaterEntry(
      id: id,
      amountMl: data['amountMl'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
