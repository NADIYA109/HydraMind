import 'package:flutter/material.dart';
import 'package:hydramind/models/reminder_model.dart';
import 'package:hydramind/services/notification_service.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/reminder_provider.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  // Weekday names used in reminder selection
  static const List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

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
            // Reminder info
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
                      'Set reminders to stay consistent with your hydration goal',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reminder list
            Expanded(
              child: reminderProvider.reminders.isEmpty
                  ? const Center(
                      child: Text(
                        'No reminders yet.\nTap + to add',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: reminderProvider.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminderProvider.reminders[index];

                        return _buildReminderItem(
                          context,
                          reminder,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      // Add new reminder
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (time != null) {
            await NotificationHelper.instance.requestPermission();

            if (!context.mounted) return;

            await context.read<ReminderProvider>().addReminder(time);
          }
        },
      ),
    );
  }

  // Builds each reminder card
  Widget _buildReminderItem(
    BuildContext context,
    ReminderModel reminder,
  ) {
    final provider = context.read<ReminderProvider>();

    final time = TimeOfDay(
      hour: reminder.hour,
      minute: reminder.minute,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _editReminderTime(
                              context,
                              reminder,
                              time,
                            );
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
                        GestureDetector(
                          onTap: () async {
                            await _editReminderTime(
                              context,
                              reminder,
                              time,
                            );
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
                    Text(
                      _getSelectedDays(reminder.days),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isEnabled,
                onChanged: (value) async {
                  await provider.toggleReminder(
                    reminder,
                    value,
                  );
                },
              ),
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

          // Selected reminder days
          if (reminder.isExpanded) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = reminder.days.contains(day);

                return GestureDetector(
                  onTap: () async {
                    await provider.toggleDay(
                      reminder,
                      day,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _dayNames[index],
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

            // Delete reminder
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  await provider.deleteReminder(reminder);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Opens time picker and updates reminder time
  Future<void> _editReminderTime(
    BuildContext context,
    ReminderModel reminder,
    TimeOfDay currentTime,
  ) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (pickedTime == null || !context.mounted) return;

    await context.read<ReminderProvider>().updateReminderTime(
          reminder,
          pickedTime,
        );
  }

  // Converts selected day numbers to weekday names
  String _getSelectedDays(List<int> days) {
    if (days.length == 7) return 'Everyday';

    return days.map((day) => _dayNames[day - 1]).join(' ');
  }
}
