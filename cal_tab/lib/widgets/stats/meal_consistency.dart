import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';

class MealConsistencyCard extends StatelessWidget {
  const MealConsistencyCard({super.key, required this.snapshot});

  final StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal rhythm',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${snapshot.loggedDays}/7 days logged',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < MealType.values.length; i++) ...[
            _MealConsistencyRow(
              mealType: MealType.values[i],
              daysLogged: snapshot.mealDaysLogged[MealType.values[i]] ?? 0,
            ),
            if (i != MealType.values.length - 1) const SizedBox(height: 13),
          ],
        ],
      ),
    );
  }
}

class _MealConsistencyRow extends StatelessWidget {
  const _MealConsistencyRow({required this.mealType, required this.daysLogged});

  final MealType mealType;
  final int daysLogged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.28),
            shape: BoxShape.circle,
          ),
          child: Icon(mealType.icon, color: colors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mealType.descriptiveLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$daysLogged/7',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: Key('stats_meal_${mealType.name}_progress'),
                  value: daysLogged / 7,
                  minHeight: 6,
                  color: colors.primary,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

