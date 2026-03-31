import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, "1. Introduction"),
              _sectionText(
                context,
                "HydraMind values your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our application.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "2. Information We Collect"),
              _sectionText(
                context,
                "We may collect personal information such as your name, age, weight, activity level, and hydration data to provide personalized hydration recommendations.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "3. How We Use Your Information"),
              _sectionText(
                context,
                "Your information is used to calculate daily hydration goals, improve user experience, and provide insights based on your habits.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "4. Data Storage"),
              _sectionText(
                context,
                "Hydration data and profile information may be securely stored using Firebase services. We do not sell or share your personal data with third parties.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "5. Notifications"),
              _sectionText(
                context,
                "We use local notifications to remind you to drink water. These notifications can be customized or disabled at any time.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "6. Data Security"),
              _sectionText(
                context,
                "We take reasonable measures to protect your information. However, no method of electronic storage is 100% secure.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "7. Your Control"),
              _sectionText(
                context,
                "You can edit your profile, adjust goals, or reset your data anytime within the app settings.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "8. Changes to This Policy"),
              _sectionText(
                context,
                "We may update this Privacy Policy from time to time. Changes will be reflected within the app.",
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Last updated: ${DateTime.now().year}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _sectionText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
        ),
      ),
    );
  }
}
