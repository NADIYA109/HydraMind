import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM TOKEN: $token');
    return token;
  }

  static Future<void> saveTokenToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    debugPrint('FCM token saved for user: ${user.uid}');
  }

  /// (OPTIONAL) foreground log only
  static void onMessageListener() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground msg: ${message.notification?.title}');
    });
  }
}
