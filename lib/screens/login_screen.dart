import 'package:flutter/material.dart';
import 'package:hydramind/screens/email_auth_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

enum AuthType { email, google }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthType? selectedAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Row(
                children: const [
                  Icon(Icons.water_drop_outlined,
                      color: AppColors.primary, size: 28),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              const Text(
                AppStrings.welcome,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),

              const SizedBox(height: 8),

              const Text(
                AppStrings.subtitle,
                style: TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 40),

              // Continue with Email
              authButton(
                text: AppStrings.continueWithEmail,
                isSelected: selectedAuth == AuthType.email,
                onTap: () {
                  setState(() {
                    selectedAuth = AuthType.email;
                  });
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                     builder: (_) => const EmailAuthScreen(),
                     ),
                   );
                },
              ),

              const SizedBox(height: 16),

              // ✅ Continue with Google
              authButton(
                text: AppStrings.continueWithGoogle,
                isSelected: selectedAuth == AuthType.google,
                onTap: () {
                  setState(() {
                    selectedAuth = AuthType.google;
                  });
                },
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  AppStrings.termsText,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Button
  Widget authButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? AppColors.primary : Colors.white,
          foregroundColor:
              isSelected ? Colors.white : AppColors.textPrimary,
          side: isSelected
              ? BorderSide.none
              : const BorderSide(color: AppColors.textLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
