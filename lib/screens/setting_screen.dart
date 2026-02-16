import 'package:flutter/material.dart';
import 'package:hydramind/providers/theme_provider.dart';
import 'package:hydramind/screens/edit_profile_screen.dart';
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
                    onTap: () {},
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
                    subtitle: "${water.dailyGoal} ml",
                    onTap: () {},
                  ),
                  _divider(),
                  _buildTile(
                    context,
                    icon: Icons.straighten,
                    title: "Unit Preference",
                    subtitle: "ml",
                    onTap: () {},
                  ),
                  _divider(),
                  _buildTile(
                    context,
                    icon: Icons.refresh,
                    title: "Reset Today’s Data",
                    onTap: () {},
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

  Widget _divider() {
    return const Divider(height: 1);
  }
}
