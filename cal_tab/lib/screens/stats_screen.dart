import 'dart:math' as math;

import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(dailyLogControllerProvider);
    final snapshot = _StatsSnapshot.from(
      logState: logState,
      profile: profile,
      anchorDate: DateTime.now(),
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return ListView(
            key: const Key('stats_main_scroll'),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatsHeader(snapshot: snapshot),
                      const SizedBox(height: 20),
                      _WeeklyOverview(snapshot: snapshot),
                      const SizedBox(height: 20),
                      _CalorieTrendCard(snapshot: snapshot),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _MacroAveragesCard(snapshot: snapshot),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MealConsistencyCard(snapshot: snapshot),
                            ),
                          ],
                        )
                      else ...[
                        _MacroAveragesCard(snapshot: snapshot),
                        const SizedBox(height: 20),
                        _MealConsistencyCard(snapshot: snapshot),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.snapshot});

  final _StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                snapshot.rangeLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.query_stats_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                '7 days',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyOverview extends StatelessWidget {
  const _WeeklyOverview({required this.snapshot});

  final _StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumns = constraints.maxWidth >= 460;
              final metrics = [
                _MetricData(
                  icon: Icons.local_fire_department_rounded,
                  value: '${snapshot.averageCalories}',
                  label: 'Avg kcal',
                  detail: 'per day',
                  color: colors.primary,
                ),
                _MetricData(
                  icon: Icons.check_circle_rounded,
                  value: '${snapshot.targetDays}/7',
                  label: 'Target days',
                  detail: 'near goal',
                  color: const Color(0xFF34C759),
                ),
                _MetricData(
                  icon: Icons.bolt_rounded,
                  value: '${snapshot.streakDays}',
                  label: 'Streak',
                  detail: snapshot.streakDays == 1 ? 'day' : 'days',
                  color: const Color(0xFFFF9500),
                ),
              ];

              if (!useColumns) {
                return Column(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      _MetricTile(data: metrics[i], horizontal: true),
                      if (i != metrics.length - 1)
                        Divider(
                          height: 24,
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    Expanded(child: _MetricTile(data: metrics[i])),
                    if (i != metrics.length - 1)
                      SizedBox(
                        height: 64,
                        child: VerticalDivider(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final String detail;
  final Color color;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data, this.horizontal = false});

  final _MetricData data;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(data.icon, color: data.color, size: 21),
    );
    final copy = Column(
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          data.detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );

    if (horizontal) {
      return Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(child: copy),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [icon, const SizedBox(height: 10), copy],
    );
  }
}

class _CalorieTrendCard extends StatelessWidget {
  const _CalorieTrendCard({required this.snapshot});

  final _StatsSnapshot snapshot;

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

  final _StatsSnapshot snapshot;

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

  final _StatsDay day;
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
      message: '${_shortDate(day.date)}: $calories kcal',
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

class _MacroAveragesCard extends StatelessWidget {
  const _MacroAveragesCard({required this.snapshot});

  final _StatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final macros = [
      _MacroStat(
        label: 'Protein',
        average: snapshot.averageProteinGrams,
        target: snapshot.profile.macroTargets.proteinGrams,
        color: const Color(0xFFFF9500),
      ),
      _MacroStat(
        label: 'Carbs',
        average: snapshot.averageCarbsGrams,
        target: snapshot.profile.macroTargets.carbsGrams,
        color: const Color(0xFF34C759),
      ),
      _MacroStat(
        label: 'Fat',
        average: snapshot.averageFatGrams,
        target: snapshot.profile.macroTargets.fatGrams,
        color: const Color(0xFFFF8E80),
      ),
      _MacroStat(
        label: 'Fiber',
        average: snapshot.averageFiberGrams,
        target: snapshot.profile.macroTargets.fiberGrams,
        color: const Color(0xFF6D7B6B),
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macro averages',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.loggedDays == 0
                ? 'Logged-day avg'
                : 'Across ${snapshot.loggedDays} logged days',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < macros.length; i++) ...[
            _MacroAverageRow(stat: macros[i]),
            if (i != macros.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _MacroStat {
  const _MacroStat({
    required this.label,
    required this.average,
    required this.target,
    required this.color,
  });

  final String label;
  final double average;
  final double target;
  final Color color;
}

class _MacroAverageRow extends StatelessWidget {
  const _MacroAverageRow({required this.stat});

  final _MacroStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = stat.target <= 0
        ? 0.0
        : (stat.average / stat.target).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stat.label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${stat.average.round()}/${stat.target.round()}g',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            key: Key('stats_macro_${stat.label.toLowerCase()}_progress'),
            value: progress,
            minHeight: 8,
            color: stat.color,
            backgroundColor: stat.color.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }
}

class _MealConsistencyCard extends StatelessWidget {
  const _MealConsistencyCard({required this.snapshot});

  final _StatsSnapshot snapshot;

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
          child: Icon(_mealIcon(mealType), color: colors.primary, size: 18),
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
                      _mealLabel(mealType),
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

class _StatsSnapshot {
  const _StatsSnapshot({
    required this.profile,
    required this.days,
    required this.streakDays,
  });

  final UserProfile profile;
  final List<_StatsDay> days;
  final int streakDays;

  DateTime get startDate => days.first.date;
  DateTime get endDate => days.last.date;
  int get totalCalories =>
      days.fold(0, (sum, day) => sum + day.summary.caloriesConsumed);
  int get averageCalories => (totalCalories / days.length).round();
  int get loggedDays => days.where((day) => day.hasEntries).length;
  int get targetDays => days.where((day) => day.isNearCalorieGoal).length;
  double get maxChartCalories {
    final maxLogged = days.fold<int>(
      profile.calorieGoal,
      (max, day) => math.max(max, day.summary.caloriesConsumed),
    );
    return math.max(1.0, maxLogged * 1.12);
  }

  double get averageProteinGrams =>
      _averageLoggedDayMacro((summary) => summary.proteinConsumedGrams);

  double get averageCarbsGrams =>
      _averageLoggedDayMacro((summary) => summary.carbsConsumedGrams);

  double get averageFatGrams =>
      _averageLoggedDayMacro((summary) => summary.fatConsumedGrams);

  double get averageFiberGrams =>
      _averageLoggedDayMacro((summary) => summary.fiberConsumedGrams);

  Map<MealType, int> get mealDaysLogged {
    return {
      for (final mealType in MealType.values)
        mealType: days
            .where(
              (day) => day.entries.any((entry) => entry.mealType == mealType),
            )
            .length,
    };
  }

  String get rangeLabel {
    return '${_shortDate(startDate)} - ${_shortDate(endDate)}';
  }

  static _StatsSnapshot from({
    required DailyLogState logState,
    required UserProfile profile,
    required DateTime anchorDate,
  }) {
    final endDate = normalizeLogDate(anchorDate);
    final days = List.generate(7, (index) {
      final date = endDate.subtract(Duration(days: 6 - index));
      final entries = logState.entriesForDate(date);
      return _StatsDay(
        date: date,
        entries: entries,
        summary: logState.summaryFor(date: date, profile: profile),
      );
    });

    return _StatsSnapshot(
      profile: profile,
      days: days,
      streakDays: logState.streakDays(endDate),
    );
  }

  double _averageLoggedDayMacro(
    double Function(DailyNutritionSummary summary) valueFor,
  ) {
    final logged = days.where((day) => day.hasEntries).toList();
    if (logged.isEmpty) {
      return 0;
    }

    final total = logged.fold<double>(
      0,
      (sum, day) => sum + valueFor(day.summary),
    );
    return total / logged.length;
  }
}

class _StatsDay {
  const _StatsDay({
    required this.date,
    required this.entries,
    required this.summary,
  });

  final DateTime date;
  final List<MealEntry> entries;
  final DailyNutritionSummary summary;

  bool get hasEntries => entries.isNotEmpty;
  bool get isNearCalorieGoal {
    if (!hasEntries) {
      return false;
    }

    final progress = summary.calorieProgress;
    return progress >= 0.85 && progress <= 1.15;
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

IconData _mealIcon(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => Icons.free_breakfast_outlined,
    MealType.snackMorning => Icons.bakery_dining_outlined,
    MealType.lunch => Icons.lunch_dining_outlined,
    MealType.snackAfternoon => Icons.cookie_outlined,
    MealType.dinner => Icons.dinner_dining_outlined,
    MealType.secondDinner => Icons.nightlight_outlined,
  };
}

String _mealLabel(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => 'Breakfast',
    MealType.snackMorning => 'Morning snack',
    MealType.lunch => 'Lunch',
    MealType.snackAfternoon => 'Afternoon snack',
    MealType.dinner => 'Dinner',
    MealType.secondDinner => 'Second dinner',
  };
}

String _weekdayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
