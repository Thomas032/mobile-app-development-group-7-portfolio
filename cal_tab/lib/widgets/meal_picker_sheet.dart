import 'package:cal_tab/models/meal_type.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet that lets the user pick a [MealType]. Resolves to the
/// chosen meal, or `null` if the user dismisses the sheet.
Future<MealType?> showMealPickerSheet(
  BuildContext context, {
  MealType? selected,
  String title = 'Choose meal',
}) {
  return showModalBottomSheet<MealType>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MealPickerSheet(title: title, selected: selected),
  );
}

class MealPickerSheet extends StatelessWidget {
  const MealPickerSheet({super.key, required this.title, this.selected});

  final String title;
  final MealType? selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 44, height: 5),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              for (final mealType in MealType.values)
                _MealPickerRow(
                  mealType: mealType,
                  isSelected: mealType == selected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPickerRow extends StatelessWidget {
  const _MealPickerRow({required this.mealType, required this.isSelected});

  final MealType mealType;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? colors.primaryContainer.withValues(alpha: 0.5)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          key: Key('meal_picker_${mealType.name}'),
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).pop(mealType),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mealTypeIcon(mealType),
                    color: colors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mealTypeLabel(mealType),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_rounded : Icons.chevron_right_rounded,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String mealTypeLabel(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => 'Breakfast',
    MealType.snackMorning => 'Morning snack',
    MealType.lunch => 'Lunch',
    MealType.snackAfternoon => 'Afternoon snack',
    MealType.dinner => 'Dinner',
    MealType.secondDinner => 'Second dinner',
  };
}

IconData mealTypeIcon(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => Icons.free_breakfast_outlined,
    MealType.snackMorning => Icons.bakery_dining_outlined,
    MealType.lunch => Icons.lunch_dining_outlined,
    MealType.snackAfternoon => Icons.cookie_outlined,
    MealType.dinner => Icons.dinner_dining_outlined,
    MealType.secondDinner => Icons.nightlight_outlined,
  };
}
