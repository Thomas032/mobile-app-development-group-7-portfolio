import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:flutter/material.dart';

class MicronutrientView extends StatelessWidget {
  const MicronutrientView({super.key, required this.summary});

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    final nutrients = [
      (
        label: 'Fiber',
        value: summary.fiberConsumedGrams.toStringAsFixed(1),
        unit: 'g',
      ),
      (
        label: 'Sugar',
        value: summary.sugarConsumedGrams.toStringAsFixed(1),
        unit: 'g',
      ),
      (
        label: 'Sodium',
        value: summary.sodiumConsumedMilligrams.toStringAsFixed(0),
        unit: 'mg',
      ),
      (
        label: 'Sat. Fat',
        value: summary.saturatedFatConsumedGrams.toStringAsFixed(1),
        unit: 'g',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < nutrients.length; i++) ...[
          _MicroNutrientRow(
            label: nutrients[i].label,
            value: nutrients[i].value,
            unit: nutrients[i].unit,
          ),
          if (i != nutrients.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MicroNutrientRow extends StatelessWidget {
  const _MicroNutrientRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value $unit',
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
