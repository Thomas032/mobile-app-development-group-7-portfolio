import 'package:cal_tab/services/nutrition_calculator.dart';
import 'package:flutter/material.dart';

class TargetPreviewCard extends StatelessWidget {
  const TargetPreviewCard({super.key, required this.preview});

  final NutritionTargets preview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${preview.calorieGoal} kcal',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          Text(
            'Daily target',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _MiniStat(
            label: 'Protein',
            value: preview.macroTargets.proteinGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Carbs',
            value: preview.macroTargets.carbsGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Fat',
            value: preview.macroTargets.fatGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Fiber',
            value: preview.macroTargets.fiberGrams,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${value.round()} $unit',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
