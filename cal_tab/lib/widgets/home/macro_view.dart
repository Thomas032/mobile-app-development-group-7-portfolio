import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/widgets/home/calorie_status_bar.dart';
import 'package:cal_tab/widgets/home/macro_details.dart';
import 'package:flutter/material.dart';

class MacroView extends StatelessWidget {
  const MacroView({super.key, required this.summary, required this.profile});

  final DailyNutritionSummary summary;
  final UserProfile profile;

  Color _gaugeColor(BuildContext context, double progress) {
    if (progress > 1.15) return Theme.of(context).colorScheme.error;
    if (progress >= 0.85) return Theme.of(context).colorScheme.primary;
    return const Color(0xFFFF9500);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final calorieProgress = summary.calorieProgress;
    final barColor = _gaugeColor(context, calorieProgress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 102,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.caloriesConsumed} kcal',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/ ${summary.calorieGoal}',
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CalorieStatusBar(progress: calorieProgress, color: barColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MacroMiniTile(
                label: 'Protein',
                consumed: summary.proteinConsumedGrams,
                target: profile.macroTargets.proteinGrams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MacroMiniTile(
                label: 'Carbs',
                consumed: summary.carbsConsumedGrams,
                target: profile.macroTargets.carbsGrams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MacroMiniTile(
                label: 'Fat',
                consumed: summary.fatConsumedGrams,
                target: profile.macroTargets.fatGrams,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
