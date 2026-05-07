import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/screens/ai_screen.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:cal_tab/screens/settings_screen.dart';
import 'package:cal_tab/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedLogDateProvider);
    final destinations = [
      HomeScreen(profile: widget.profile),
      const StatsScreen(),
      const AiScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: _MainBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onAddFood: () => _openMealPicker(selectedDate),
      ),
    );
  }

  Future<void> _openMealPicker(DateTime selectedDate) async {
    final mealType = await showModalBottomSheet<MealType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MealPickerSheet(),
    );

    if (!mounted || mealType == null) {
      return;
    }

    context.pushNamed(
      'add-food',
      extra: FoodLogTarget(date: selectedDate, mealType: mealType),
    );
  }
}

class _MealPickerSheet extends StatelessWidget {
  const _MealPickerSheet();

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
                'Log food',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a meal before searching.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              for (final mealType in MealType.values)
                _MealPickerAction(mealType: mealType),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPickerAction extends StatelessWidget {
  const _MealPickerAction({required this.mealType});

  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surfaceContainerLow,
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
                    _mealIcon(mealType),
                    color: colors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mealActionLabel(mealType),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddFood,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 88 + bottomInset,
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              _BottomTabButton(
                key: const Key('home_tab_button'),
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                onTap: onTabSelected,
              ),
              _BottomTabButton(
                key: const Key('stats_tab_button'),
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Stats',
                onTap: onTabSelected,
              ),
              const SizedBox(width: 96),
              _BottomTabButton(
                key: const Key('ai_tab_button'),
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome,
                label: 'AI',
                onTap: onTabSelected,
              ),
              _BottomTabButton(
                key: const Key('settings_tab_button'),
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                onTap: onTabSelected,
              ),
            ],
          ),
          SizedBox.square(
            dimension: 64,
            child: FloatingActionButton(
              key: const Key('open_add_food_button'),
              tooltip: 'Add food',
              onPressed: onAddFood,
              child: const Icon(Icons.add, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

String _mealActionLabel(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => 'Breakfast',
    MealType.snackMorning => 'Morning snack',
    MealType.lunch => 'Lunch',
    MealType.snackAfternoon => 'Afternoon snack',
    MealType.dinner => 'Dinner',
    MealType.secondDinner => 'Second dinner',
  };
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

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
