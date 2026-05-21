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
                      _SwipeableNutritionTile(
                        summary: summary,
                        profile: profile,
                      ),
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

class _SwipeableNutritionTile extends StatefulWidget {
  const _SwipeableNutritionTile({required this.summary, required this.profile});

  final DailyNutritionSummary summary;
  final UserProfile profile;

  @override
  State<_SwipeableNutritionTile> createState() =>
      _SwipeableNutritionTileState();
}

class _SwipeableNutritionTileState extends State<_SwipeableNutritionTile> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 212,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: _MacroView(
                    summary: widget.summary,
                    profile: widget.profile,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: _OtherNutrientView(summary: widget.summary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            final selected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 7,
              width: selected ? 18 : 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: 0.8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MacroView extends StatelessWidget {
  const _MacroView({required this.summary, required this.profile});

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
                      color: Colors.white,
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
              _CalorieStatusBar(progress: calorieProgress, color: barColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroMiniTile(
                label: 'Protein',
                consumed: summary.proteinConsumedGrams,
                target: profile.macroTargets.proteinGrams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroMiniTile(
                label: 'Carbs',
                consumed: summary.carbsConsumedGrams,
                target: profile.macroTargets.carbsGrams,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroMiniTile(
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

class _CalorieStatusBar extends StatelessWidget {
  const _CalorieStatusBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: normalized,
        minHeight: 10,
        backgroundColor: color.withValues(alpha: 0.20),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _MacroMiniTile extends StatelessWidget {
  const _MacroMiniTile({
    required this.label,
    required this.consumed,
    required this.target,
  });

  final String label;
  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final color = colors.primary;
    final progress = target <= 0
        ? 0.0
        : (consumed / target).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${consumed.round()}/${target.round()}g',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherNutrientView extends StatelessWidget {
  const _OtherNutrientView({required this.summary});

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
          _MicroRow(
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

class _MicroRow extends StatelessWidget {
  const _MicroRow({
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
            children: [_MealEntriesPanel(entries: entries)],
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

class _MealEntriesPanel extends StatelessWidget {
  const _MealEntriesPanel({required this.entries});

  final List<MealEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: entries.isEmpty
            ? SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No food logged yet',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    _MealEntryRow(entry: entries[i]),
                    if (i != entries.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MealEntryRow extends ConsumerWidget {
  const _MealEntryRow({required this.entry});

  final MealEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey('meal-entry-${entry.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _handleDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openEditor(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.foodItem.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.calories} kcal',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    context.pushNamed(
      'food-detail',
      extra: FoodDetailRouteArgs(
        foodItem: entry.foodItem,
        target: FoodLogTarget(date: entry.date, mealType: entry.mealType),
        editingEntry: entry,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: Text('Remove "${entry.foodItem.name}" from your log?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(dailyLogControllerProvider.notifier);
    final removed = entry;

    controller.removeEntry(removed.id);
    await controller.saveCurrentEntries();

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed "${removed.foodItem.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            controller.restoreEntry(removed);
            await controller.saveCurrentEntries();
          },
        ),
      ),
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
