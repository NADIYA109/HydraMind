import 'package:flutter/material.dart';
import 'package:hydramind/providers/mood_provider.dart';
import 'package:hydramind/providers/water_provider.dart';

class InsightsProvider extends ChangeNotifier {
  List<String> generateInsights({
    required WaterProvider water,
    required MoodProvider mood,
  }) {
    List<String> insights = [];

    final double waterPercent =
        water.dailyGoal == 0 ? 0 : water.currentIntake / water.dailyGoal;

    final String? currentMood = mood.mood;
    final int energy = mood.energyLevel;

    /// No mood logged
    if (currentMood == null) {
      return ['Log your mood to receive personalized insights.'];
    }

    /// ================= HYDRATION =================
    if (waterPercent < 0.5) {
      insights.add("💧 Your hydration is low today.");
    } else if (waterPercent < 1) {
      insights.add("💧 You are halfway there, keep drinking water.");
    } else {
      insights.add("💧 Great! You met your hydration goal.");
    }

    /// ================= MOOD =================
    if (currentMood == 'Stressed') {
      insights.add("😣 You felt stressed today. Try relaxation or breaks.");
    } else if (currentMood == 'Happy') {
      insights.add("😊 You were in a positive mood today!");
    } else if (currentMood == 'Calm') {
      insights.add("😌 You maintained a calm and balanced mood.");
    } else if (currentMood == 'Tired') {
      insights.add("😴 You seemed tired today. Rest might help.");
    }

    /// ================= ENERGY =================
    if (energy == 1) {
      insights.add("⚡ Very low energy. Take proper rest.");
    } else if (energy == 2) {
      insights.add("⚡ Low energy levels. Stay hydrated and eat well.");
    } else if (energy == 3) {
      insights.add("⚡ Moderate energy. Try to stay consistent.");
    } else if (energy == 4) {
      insights.add("⚡ Good energy levels today!");
    } else if (energy == 5) {
      insights.add("⚡ Excellent energy! Keep it up!");
    }

    /// ================= COMBINED SMART INSIGHTS =================

    // Low water + stressed
    if (waterPercent < 0.5 && currentMood == 'Stressed') {
      insights.add("💡 Low hydration may be increasing your stress.");
    }

    // Good hydration + low energy
    if (waterPercent >= 1 && energy <= 2) {
      insights.add(
          "💡 Even with good hydration, low energy may need rest or sleep.");
    }

    // Perfect day
    if (waterPercent >= 1 && currentMood == 'Happy' && energy >= 4) {
      insights
          .add("🎯 Perfect balance! Hydration, mood, and energy are great.");
    }

    /// Fallback (never empty)
    if (insights.isEmpty) {
      insights.add("Maintain healthy habits for better insights.");
    }

    return insights;
  }
}
