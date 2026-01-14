import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReminderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> saveReminder({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    await _firestore.collection('users').doc('dummyUser').set(
      {
        'reminder': {
          'enabled': enabled,
          'hour': time.hour,
          'minute': time.minute,
          'timeString':
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }
}
