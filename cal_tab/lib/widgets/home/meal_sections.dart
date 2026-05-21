import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MealAccordions extends StatelessWidget {
  const MealAccordions({
    super.key,
    required this.entries,
    required this.date,
  });

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
