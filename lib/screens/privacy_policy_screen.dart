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
              _sectionTitle(context, "Introduction"),
              _sectionText(
                context,
                "HydraMind values your privacy and is committed to protecting your personal information. This Privacy Policy explains how the app collects, uses, and protects user data.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Information We Collect"),
              _sectionText(
                context,
                "HydraMind may collect limited user information, including user profile information, email address for authentication, hydration and mood tracking data, reminder preferences, and app settings. This information is used only to provide and improve app functionality and user experience. ",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Authentication"),
              _sectionText(
                context,
                "HydraMind supports Email/Password and Google Sign-In authentication through Firebase Authentication. Your login information is securely handled by Firebase services.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Permissions Used"),
              _sectionText(
                  context,
                  "HydraMind may request the following permissions for app functionality:\n\n"
                  "• INTERNET – To connect with Firebase services and sync app data.\n\n"
                  "• POST_NOTIFICATIONS – To send hydration reminder notifications.\n\n"
                  "• RECEIVE_BOOT_COMPLETED – To restore reminders after device restart.\n\n"
                  "• SCHEDULE_EXACT_ALARM – To schedule accurate hydration reminders.\n\n"
                  "• REQUEST_IGNORE_BATTERY_OPTIMIZATIONS – To help reminders work properly in the background."
                  // "• READ_MEDIA_IMAGES – To allow users to select a profile photo from gallery.",
                  ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Data Security"),
              _sectionText(
                context,
                "We take reasonable measures to protect user information and prevent unauthorized access, misuse, or disclosure of data.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Third-Party Services"),
              _sectionText(
                context,
                "HydraMind may use trusted third-party services such as Firebase Authentication and Firebase Firestore for secure login and data storage.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Children's Privacy"),
              _sectionText(
                context,
                "HydraMind is not intended for children under the age of 13.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Changes to This Privacy Policy"),
              _sectionText(
                context,
                "This Privacy Policy may be updated from time to time. Any changes will be reflected on this page.",
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Contact Us"),
              _sectionText(
                context,
                "If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n"
                "Email: hydramind.app@gmail.com",
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
