import 'package:flutter/material.dart';
import 'package:hydramind/models/reminder_model.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/reminder_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  /// Fix background restrictions
  Future<void> _fixNotificationRestrictions(BuildContext context) async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    await openAppSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Disable "Pause app activity" & set battery to Unrestricted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Reminder Schedule',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "We will optimise reminder time based on your usage",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: reminderProvider.reminders.isEmpty
                  ? const Center(
                      child: Text(
                        "No reminders yet.\nTap + to add",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: reminderProvider.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminderProvider.reminders[index];
                        return _buildReminderItem(context, reminder);
                      },
                    ),
            ),

            /// WARNING
            GestureDetector(
              onTap: () => _fixNotificationRestrictions(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notifications not working? Set battery to Unrestricted',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      /// ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (time != null) {
            context.read<ReminderProvider>().addReminder(time);
          }
        },
      ),
    );
  }

  /// ================= ITEM =================

  Widget _buildReminderItem(BuildContext context, ReminderModel reminder) {
    final provider = context.read<ReminderProvider>();

    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// TOP ROW
          Row(
            children: [
              /// TIME + EDIT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        /// TIME
                        GestureDetector(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );

                            if (pickedTime != null) {
                              context
                                  .read<ReminderProvider>()
                                  .updateReminderTime(reminder, pickedTime);
                            }
                          },
                          child: Text(
                            time.format(context),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// EDIT ICON
                        GestureDetector(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );

                            if (pickedTime != null) {
                              context
                                  .read<ReminderProvider>()
                                  .updateReminderTime(reminder, pickedTime);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// DAYS
                    Text(
                      _getSelectedDays(reminder.days),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              /// SWITCH
              Switch(
                value: reminder.isEnabled,
                onChanged: (val) {
                  provider.toggleReminder(reminder, val);
                },
              ),

              /// EXPAND
              IconButton(
                icon: Icon(
                  reminder.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  provider.toggleExpand(reminder);
                },
              ),
            ],
          ),

          /// EXPANDED
          if (reminder.isExpanded) ...[
            const SizedBox(height: 10),

            /// DAYS SELECT
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = reminder.days.contains(day);

                final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                return GestureDetector(
                  onTap: () {
                    provider.toggleDay(reminder, day);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      names[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),

            /// DELETE
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  provider.deleteReminder(reminder);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ================= HELPER =================

  String _getSelectedDays(List<int> days) {
    if (days.length == 7) return "Everyday";

    final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => names[d - 1]).join(" ");
  }
}
