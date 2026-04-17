import 'package:flutter/material.dart';
import 'package:hydramind/screens/forgot_password_screen.dart';
import 'package:hydramind/screens/main_navigation_screen.dart';
import 'package:hydramind/screens/profile_setup_screen.dart';
import 'package:hydramind/services/auth_service.dart';
import '../core/constants/app_colors.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // Email validation
  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  // Strong password validation
  bool isStrongPassword(String password) {
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$&*~]'));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset errors
    setState(() {
      emailError = null;
      passwordError = null;
    });

    bool hasError = false;

    // Email validation

    if (email.isEmpty) {
      emailError = "Email is required";
      hasError = true;
    } else if (!isValidEmail(email)) {
      emailError = "Enter a valid email";
      hasError = true;
    }

    // Password validation
    if (password.isEmpty) {
      passwordError = "Password is required";
      hasError = true;
    } else if (!isLogin && !isStrongPassword(password)) {
      passwordError = "Min 6 chars, 1 uppercase, 1 number, 1 symbol";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
        isLogin: isLogin,
      );

      final profileComplete = await AuthService.isProfileComplete(user!.uid);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => profileComplete
              ? const MainNavigationScreen()
              : const ProfileSetupScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        passwordError = "Invalid email or password";
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              isLogin ? 'Login with Email' : 'Create an Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLogin
                  ? 'Enter your credentials to continue'
                  : 'Sign up to start your hydration journey',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailError,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color:
                        emailError != null ? Colors.red : Colors.grey.shade400,
                  ),
                ),
              ),
              onChanged: (_) {
                if (emailError != null) {
                  setState(() => emailError = null);
                }
              },
            ),

            const SizedBox(height: 16),
            //Password field
            TextField(
              controller: _passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: passwordError,
                prefixIcon: const Icon(Icons.lock_outline),

                //  Show/Hide toggle
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: passwordError != null
                        ? Colors.red
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              onChanged: (_) {
                if (passwordError != null) {
                  setState(() => passwordError = null);
                }
              },
            ),

            const SizedBox(height: 8),
            //  Forgot Password
            if (isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            //Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          //color: Colors.white,
                          color: Theme.of(context).cardColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                    emailError = null;
                    passwordError = null;
                  });
                },
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Login',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 39, 66, 73)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
