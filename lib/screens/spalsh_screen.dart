import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydramind/screens/login_screen.dart';
import 'package:hydramind/screens/main_navigation_screen.dart';
import 'package:hydramind/screens/profile_setup_screen.dart';
import 'package:hydramind/services/fcm_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      //Save FCM token only if user is logged in
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FCMService.saveTokenToFirestore();
        FCMService.onMessageListener();
      }

      //Splash delay
      await Future.delayed(const Duration(seconds: 3));

      // final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      //Not logged in
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      //Logged in -> check profile in firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        //No document at all -> profile incomplete
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
        return;
      }

      final data = doc.data();

      final bool profileComplete = data?['name'] != null &&
          data?['age'] != null &&
          data?['weight'] != null &&
          data?['activity'] != null;

      if (profileComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.accent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.water_drop_outlined,
                size: 90,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
