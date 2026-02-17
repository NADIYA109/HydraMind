import 'package:flutter/material.dart';
import 'package:hydramind/providers/theme_provider.dart';
import 'package:hydramind/screens/daily_goal_dialog.dart';
import 'package:hydramind/screens/edit_profile_screen.dart';
import 'package:hydramind/screens/spalsh_screen.dart';
import 'package:hydramind/screens/unit_selection_dialog.dart';
import 'package:hydramind/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/water_provider.dart';
//import '../providers/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final water = context.watch<WaterProvider>();

    return Scaffold(
      //backgroundColor: AppColors.background,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        //backgroundColor: AppColors.background,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Text(
          "Settings",
          style: TextStyle(
            //color: AppColors.textPrimary,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ACCOUNT SECTION
              Text(
                "Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  //color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionContainer(
                context,
                children: [
                  _buildTile(
                    context,
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _buildTile(
                    context,
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content:
                                const Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await AuthService.logout();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// APP PREFERENCES
              Text(
                "App Preferences",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  // color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionContainer(
                context,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      context.read<ThemeProvider>().toggleTheme(val);
                    },
                    title: Text(
                      themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// HYDRATION SECTION
              Text(
                "Hydration",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  //color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionContainer(
                context,
                children: [
                  _buildTile(
                    context,
                    icon: Icons.local_drink_outlined,
                    title: "Daily Goal",
                    subtitle: "${water.dailyGoal} ${water.unit}",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const DailyGoalDialog(),
                      );
                    },
                  ),
                  _divider(),
                  _buildTile(
                    context,
                    icon: Icons.straighten,
                    title: "Unit Preference",
                    //subtitle: water.unit,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const UnitSelectionDialog(),
                      );
                    },
                  ),
                  _divider(),
                  _buildTile(
                    context,
                    icon: Icons.refresh,
                    title: "Reset Today’s Data",
                    onTap: () {
                      _showResetDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// ABOUT SECTION
              Text(
                "About",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  //color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionContainer(
                context,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.privacy_tip_outlined),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        //color: AppColors.textPrimary,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text(
                      "App Version",
                      style: TextStyle(
                        // color: AppColors.textPrimary,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text("1.0.0"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        //color: Colors.white,
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          //color: AppColors.textPrimary,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Reset Today’s Data?",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            "This will clear your water intake for today. Your goal will remain the same.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await context.read<WaterProvider>().resetDailyWater();

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Today's data has been reset 💧"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _divider() {
    return const Divider(height: 1);
  }
}
