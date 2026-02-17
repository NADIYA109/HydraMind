import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class UnitSelectionDialog extends StatelessWidget {
  const UnitSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Select Unit",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitOption(
            context,
            value: 'ml',
            title: "Milliliters (ml)",
            selected: water.unit == 'ml',
          ),
          const SizedBox(height: 12),
          _unitOption(
            context,
            value: 'oz',
            title: "Fluid Ounces (oz)",
            selected: water.unit == 'oz',
          ),
        ],
      ),
    );
  }

  Widget _unitOption(
    BuildContext context, {
    required String value,
    required String title,
    required bool selected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        context.read<WaterProvider>().changeUnit(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
