import 'package:flutter/material.dart';
import 'package:hydramind/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool reminderEnabled = false;
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  /// CRITICAL: Handles both Battery Optimization and App Hibernation
  Future<void> _fixNotificationRestrictions() async {
    // 1. Request to Ignore Battery Optimizations (Sets app to 'Unrestricted')
    // This addresses the "Background power consumption" issue.
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // 2. Open App Settings for 'Pause app activity'
    // There is no direct API to toggle "Pause app activity if unused" automatically.
    // We must send the user to the App Info page .
    await openAppSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please disable "Pause app activity if unused" in the settings page.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Reminder Toggle Card
            _buildCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Water Reminder',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Receive notifications at your preferred time',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: reminderEnabled,
                    onChanged: (val) => setState(() => reminderEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time Picker Card
            _buildCard(
              onTap: reminderEnabled ? _pickTime : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reminder Time'),
                  Text(selectedTime.format(context),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (reminderEnabled)
              GestureDetector(
                onTap: _fixNotificationRestrictions,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications blocked? Tap to set Battery to "Unrestricted" and disable "Pause app activity".',
                          style: TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Save Settings',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    );
  }

  Future<void> _pickTime() async {
    final time =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (time != null) setState(() => selectedTime = time);
  }

  void _saveSettings() async {
    if (!reminderEnabled) return;
    try {
      await NotificationHelper.instance.scheduleAt(selectedTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reminder successfully scheduled!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error scheduling reminder'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}
