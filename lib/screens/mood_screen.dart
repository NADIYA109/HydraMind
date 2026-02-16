import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();

    return Scaffold(
      //backgroundColor: AppColors.background,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        //backgroundColor: AppColors.background,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: const Text('How are you feeling today?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Mood selection
            Text(
              'Select your mood',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                //color: AppColors.textPrimary,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moodItem(context, 'Happy', '😊'),
                _moodItem(context, 'Calm', '😌'),
                _moodItem(context, 'Stressed', '😣'),
                _moodItem(context, 'Tired', '😴'),
              ],
            ),

            const SizedBox(height: 32),

            /// Energy level
            Text(
              'Energy level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                //color: AppColors.textPrimary,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 12),

            Slider(
              value: moodProvider.energyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: moodProvider.energyLevel.toString(),
              activeColor: AppColors.primary,
              onChanged: (value) {
                context.read<MoodProvider>().setEnergyLevel(value.toInt());
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Low'),
                Text('High'),
              ],
            ),

            const Spacer(),

            /// Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: moodProvider.mood == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mood saved successfully'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Save Mood',
                  style: TextStyle(
                    fontSize: 16,
                    //color: Colors.white,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single mood item widget
  Widget _moodItem(BuildContext context, String mood, String emoji) {
    final selected = context.watch<MoodProvider>().mood == mood;

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.read<MoodProvider>().setMood(mood);
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 4),
            Text(
              mood,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
