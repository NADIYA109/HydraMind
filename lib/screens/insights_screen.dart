import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/water_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/insights_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final mood = context.watch<MoodProvider>();
    final insights = context.watch<InsightsProvider>();

    final String insightText = insights.generateInsight(
      water: water,
      mood: mood,
    );

    final int waterPercent = water.dailyGoal == 0
        ? 0
        : ((water.currentIntake / water.dailyGoal) * 100).round();

    return Scaffold(
      //backgroundColor: AppColors.background,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        // backgroundColor: AppColors.background,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // foregroundColor: AppColors.textPrimary,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: const Text('Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Today Summary
            Text(
              'Today’s Summary',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  //color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),

            const SizedBox(height: 20),

            /// Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                //color: Colors.white,
                color: Theme.of(context).cardColor,

                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  /// Water
                  _summaryRow(
                    context,
                    title: 'Hydration',
                    value: '$waterPercent%',
                  ),

                  const SizedBox(height: 12),

                  /// Mood
                  _summaryRow(
                    context,
                    title: 'Mood',
                    value: mood.mood ?? 'Not logged',
                  ),

                  const SizedBox(height: 12),

                  /// Energy
                  _summaryRow(
                    context,
                    title: 'Energy',
                    value: '${mood.energyLevel}/5',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// Insight message
            Text(
              'Insight',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  //color: AppColors.textPrimary,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                insightText,
                style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    //color: AppColors.textPrimary,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),

            const Spacer(),

            /// Footer
            Center(
              child: Text(
                'Insights update daily based on your habits 💧',
                style: TextStyle(
                    fontSize: 13,
                    //color: AppColors.textSecondary,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable row widget
  Widget _summaryRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
