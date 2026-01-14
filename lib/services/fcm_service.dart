import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hydramind/services/notification_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Permission
  static Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Get token
  static Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM TOKEN: $token');
    return token;
  }

  /// SAVE TOKEN TO FIRESTORE (THIS IS STEP-2)
  static Future<void> saveTokenToFirestore() async {
    final token = await getToken();
    if (token == null) return;

    await _firestore.collection('users').doc('dummyUser').set(
      {
        'fcmToken': token,
        'timezone': 'Asia/Kolkata',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    debugPrint('FCM token saved to Firestore');
  }

  /// Foreground listener
  static void onMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground: ${message.notification?.title}');
    });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  NotificationService.showFromFCM(message);
});

  }
}
