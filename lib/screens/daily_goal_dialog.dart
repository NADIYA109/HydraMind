import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class DailyGoalDialog extends StatefulWidget {
  const DailyGoalDialog({super.key});

  @override
  State<DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends State<DailyGoalDialog> {
  double? tempGoal;

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();

    if (tempGoal == null) {
      tempGoal = water.dailyGoal.toDouble();
    }

    return AlertDialog(
      title: const Text("Adjust Daily Goal"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${tempGoal!.round()} ${water.unit}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: tempGoal!,
            min: water.unit == 'ml' ? 1000 : 30,
            max: water.unit == 'ml' ? 5000 : 170,
            divisions: 50,
            onChanged: (value) {
              setState(() {
                tempGoal = value;
              });
            },
          ),
          const SizedBox(height: 6),
          Text(
            "Recommended: ${water.recommendedGoal} ${water.unit}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            context.read<WaterProvider>().updateDailyGoal(tempGoal!.round());

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
