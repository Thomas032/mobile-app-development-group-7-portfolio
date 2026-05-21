import 'dart:math' as math;

import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:flutter/material.dart';

class CalorieTrendCard extends StatelessWidget {
  const CalorieTrendCard({super.key, required this.snapshot});

  final StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily calories',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _TargetPill(label: 'Target ${snapshot.profile.calorieGoal}'),
            ],
          ),
          const SizedBox(height: 18),
          _CalorieBars(snapshot: snapshot),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusDot(color: colors.primary),
              const SizedBox(width: 6),
              Text(
                '${snapshot.totalCalories} kcal logged',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  const _TargetPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CalorieBars extends StatelessWidget {
  const _CalorieBars({required this.snapshot});

  final StatsSnapshot snapshot;

  static const _chartHeight = 140.0;
  static const _labelHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxCalories = snapshot.maxChartCalories;
    final targetTop =
        _chartHeight *
        (1 - (snapshot.profile.calorieGoal / maxCalories).clamp(0.0, 1.0));

    return SizedBox(
      height: _chartHeight + _labelHeight,
      child: Column(
        children: [
          SizedBox(
            height: _chartHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: targetTop,
                  child: Container(
                    height: 1,
                    color: colors.primary.withValues(alpha: 0.28),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in snapshot.days)
                      Expanded(
                        child: _CalorieBar(
                          day: day,
                          maxCalories: maxCalories,
                          target: snapshot.profile.calorieGoal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: _labelHeight - 8,
            child: Row(
              children: [
                for (final day in snapshot.days)
                  Expanded(
                    child: Text(
                      _weekdayLabel(day.date),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieBar extends StatelessWidget {
  const _CalorieBar({
    required this.day,
    required this.maxCalories,
    required this.target,
  });

  final StatsDay day;
  final double maxCalories;
  final int target;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final calories = day.summary.caloriesConsumed;
    final height = calories <= 0
        ? 8.0
        : math.max(12.0, _CalorieBars._chartHeight * calories / maxCalories);
    final barColor = day.hasEntries
        ? _progressColor(context, calories / target)
        : colors.surfaceContainerHigh;

    return Tooltip(
      message: '${shortDate(day.date)}: $calories kcal',
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 0.58,
          child: Container(
            key: Key('stats_calorie_bar_${logDateKey(day.date)}'),
            height: height.clamp(8.0, _CalorieBars._chartHeight).toDouble(),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

Color _progressColor(BuildContext context, double progress) {
  if (progress > 1.15) {
    return Theme.of(context).colorScheme.error;
  }
  if (progress >= 0.85) {
    return Theme.of(context).colorScheme.primary;
  }
  return const Color(0xFFFF9500);
}

String _weekdayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}
