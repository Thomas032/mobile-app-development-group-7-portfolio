import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/screens/ai_screen.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:cal_tab/screens/settings_screen.dart';
import 'package:cal_tab/screens/stats_screen.dart';
import 'package:cal_tab/widgets/shell/add_food_action_sheet.dart';
import 'package:cal_tab/widgets/shell/bottom_bar.dart';
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
      StatsScreen(profile: widget.profile),
      const AiScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: MainBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onAddFood: () => _openAddFood(selectedDate),
      ),
    );
  }

  Future<void> _openAddFood(DateTime selectedDate) async {
    final mealType = ref
        .read(mealAssignmentServiceProvider)
        .assignFor(DateTime.now());
    final target = FoodLogTarget(date: selectedDate, mealType: mealType);

    final action = await showModalBottomSheet<AddFoodAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFoodActionSheet(),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case AddFoodAction.search:
        context.pushNamed('add-food', extra: target);
      case AddFoodAction.barcode:
        context.pushNamed('scan-barcode', extra: target);
      case AddFoodAction.snap2cal:
        context.pushNamed(
          'add-food',
          extra: AddFoodRouteArgs(
            target: target,
            autoAction: AddFoodAutoAction.snap2cal,
          ),
        );
    }
  }
}
