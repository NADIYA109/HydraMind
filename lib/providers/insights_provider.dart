import 'package:flutter/material.dart';
import 'package:hydramind/providers/mood_provider.dart';
import 'package:hydramind/providers/water_provider.dart';

class InsightsProvider extends ChangeNotifier {

  String generateInsight({
    required WaterProvider water,
    required MoodProvider mood,
  }) {
    final double waterPercent =
        water.dailyGoal == 0 ? 0 : water.currentIntake / water.dailyGoal;

    final String? currentMood = mood.mood;
    final int energy = mood.energyLevel;

    // No mood logged
    if (currentMood == null) {
      return 'Log your mood to receive personalized insights.';
    }

    //  Low hydration + stressed
    if (waterPercent < 0.5 && currentMood == 'Stressed') {
      return 'Low hydration may be increasing your stress. Try sipping water regularly.';
    }

    //  Hydration good but stressed
    if (waterPercent >= 1 && currentMood == 'Stressed') {
      return 'You are well hydrated, but stress may be caused by other factors. Consider taking short breaks or deep breathing.';
    }

    //  Hydration good but low energy
    if (waterPercent >= 1 && energy <= 2) {
      return 'Hydration is on track, but low energy may need rest, nutrition, or sleep.';
    }

    //  Everything good
    if (waterPercent >= 1 && currentMood == 'Happy' && energy >= 3) {
      return 'Great job! Your hydration and mood are both in good balance today.';
    }

    //  Neutral encouragement
    return 'Maintain regular hydration to support your mood and energy throughout the day.';
  }
}
