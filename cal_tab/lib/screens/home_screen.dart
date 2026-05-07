import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:cal_tab/widgets/log_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(dailyLogControllerProvider);
    final today = DateTime.now();
    final selectedDate = ref.watch(selectedLogDateProvider);
    final summary = logState.summaryFor(date: selectedDate, profile: profile);
    final selectedEntries = logState.entriesForDate(selectedDate);
    final streak = logState.streakDays(today);

    return SafeArea(
      child: Column(
        children: [
          _TopBar(
            streak: streak,
            date: selectedDate,
            onDatePressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(today.year - 5),
                lastDate: DateTime(today.year + 5),
                currentDate: today,
              );

              if (pickedDate != null && context.mounted) {
                ref.read(selectedLogDateProvider.notifier).select(pickedDate);
              }
            },
          ),
          Expanded(
            child: ListView(
              key: const Key('home_main_scroll'),
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 104),
              children: [
                LogCalendar(
                  logState: logState,
                  profile: profile,
                  selectedDate: selectedDate,
                  today: today,
                  onDateSelected: ref
                      .read(selectedLogDateProvider.notifier)
                      .select,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CalorieGauge(summary: summary),
                      const SizedBox(height: 24),
                      const _SectionLabel(text: 'Nutrients'),
                      const SizedBox(height: 12),
                      _MacroGrid(summary: summary, profile: profile),
                      const SizedBox(height: 24),
                      const _SectionLabel(text: 'Meals'),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: _MealAccordions(
                          entries: selectedEntries,
                          date: selectedDate,
                        ),
                      ),
                    ],
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

// ──────────────────────────────────────────
// Top bar
// ──────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.streak,
    required this.date,
    required this.onDatePressed,
  });

  final int streak;
  final DateTime date;
  final VoidCallback onDatePressed;

  static const _months = [
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final dateLabel = '${_months[date.month - 1]} ${date.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _PillBadge(
            key: const Key('streak_badge'),
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF9500),
            label: '$streak',
          ),
          Expanded(
            child: Center(
              child: Text(
                'CalTab',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          _PillBadge(
            key: const Key('date_badge'),
            icon: Icons.calendar_today_rounded,
            iconColor: colors.primary,
            label: dateLabel,
            tooltip: 'Choose date',
            onTap: onDatePressed,
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final badge = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return badge;
    }

    return Tooltip(message: tooltip!, child: badge);
  }
}

// ──────────────────────────────────────────
// ──────────────────────────────────────────

// ──────────────────────────────────────────
// Calorie gauge
// ──────────────────────────────────────────

class _CalorieGauge extends StatelessWidget {
  const _CalorieGauge({required this.summary});

  final DailyNutritionSummary summary;

  Color _gaugeColor(BuildContext context) {
    final progress = summary.calorieProgress;
    if (progress > 1.15) return Theme.of(context).colorScheme.error;
    if (progress >= 0.85) return Theme.of(context).colorScheme.primary;
    return const Color(0xFFFF9500);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final gaugeColor = _gaugeColor(context);
    final progress = summary.calorieProgress.clamp(0.0, 1.0).toDouble();
    final percent = (summary.calorieProgress * 100).round();

    return AppCard(
      child: Center(
        child: SizedBox.square(
          dimension: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 18,
                strokeCap: StrokeCap.round,
                color: gaugeColor,
                backgroundColor: gaugeColor.withValues(alpha: 0.12),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.caloriesConsumed}',
                      key: const Key('calories_consumed_value'),
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '/${summary.calorieGoal} kcal',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PercentBadge(percent: percent, color: gaugeColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Section label
// ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// ──────────────────────────────────────────
// Macro grid
// ──────────────────────────────────────────

class _MacroGrid extends StatelessWidget {
  const _MacroGrid({required this.summary, required this.profile});

  final DailyNutritionSummary summary;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final macros = [
      (
        label: 'Protein',
        consumed: summary.proteinConsumedGrams,
        target: profile.macroTargets.proteinGrams,
        color: const Color(0xFFFF9500),
      ),
      (
        label: 'Carbs',
        consumed: summary.carbsConsumedGrams,
        target: profile.macroTargets.carbsGrams,
        color: const Color(0xFF34C759),
      ),
      (
        label: 'Fat',
        consumed: summary.fatConsumedGrams,
        target: profile.macroTargets.fatGrams,
        color: const Color(0xFFFF8E80),
      ),
      (
        label: 'Fiber',
        consumed: summary.fiberConsumedGrams,
        target: profile.macroTargets.fiberGrams,
        color: const Color(0xFF6D7B6B),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: [
        for (final m in macros)
          _MacroTile(
            label: m.label,
            consumed: m.consumed,
            target: m.target,
            color: m.color,
          ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final double consumed;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = target <= 0
        ? 0.0
        : (consumed / target).clamp(0.0, 1.0).toDouble();
    final percentage = (progress * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${consumed.round()}/${target.round()}g',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Meal accordions
// ──────────────────────────────────────────

class _MealAccordions extends StatelessWidget {
  const _MealAccordions({required this.entries, required this.date});

  final List<MealEntry> entries;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final types = MealType.values;
    return Column(
      children: [
        for (int i = 0; i < types.length; i++)
          _MealSection(
            mealType: types[i],
            entries: entries.where((e) => e.mealType == types[i]).toList(),
            date: date,
            isLast: i == types.length - 1,
          ),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealType,
    required this.entries,
    required this.date,
    required this.isLast,
  });

  final MealType mealType;
  final List<MealEntry> entries;
  final DateTime date;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalKcal = entries.fold(0, (sum, e) => sum + e.calories);
    final hasEntries = entries.isNotEmpty;

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: hasEntries,
            tilePadding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _mealIcon(mealType),
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mealType.label,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        hasEntries ? '$totalKcal kcal' : 'Add food',
                        style: textTheme.bodySmall?.copyWith(
                          color: hasEntries
                              ? colors.onSurfaceVariant
                              : colors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                _AddFoodButton(mealType: mealType, date: date),
                const SizedBox(width: 4),
              ],
            ),
            children: [
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.foodItem.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.calories} kcal',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
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

class _AddFoodButton extends StatelessWidget {
  const _AddFoodButton({required this.mealType, required this.date});

  final MealType mealType;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      key: Key('add_food_${mealType.name}_button'),
      onTap: () => context.pushNamed(
        'add-food',
        extra: FoodLogTarget(date: date, mealType: mealType),
      ),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_rounded,
          size: 18,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
