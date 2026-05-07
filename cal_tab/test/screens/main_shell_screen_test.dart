import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('switches between bottom navigation tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MainShellScreen(profile: _profile)),
      ),
    );

    expect(find.text('CalTab'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stats_tab_button')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Daily history, weekly trends, macro progress, and meal consistency will appear here.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('ai_tab_button')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "The assistant will use your local profile and today's intake after you add your own API key.",
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('settings_tab_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reset_profile_button')), findsOneWidget);
    expect(find.byKey(const Key('clear_food_logs_button')), findsOneWidget);
  });

  testWidgets('tab plus opens meal picker before add-food search', (
    tester,
  ) async {
    Object? openedExtra;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const MainShellScreen(profile: _profile),
              ),
              GoRoute(
                path: '/add-food',
                name: 'add-food',
                builder: (_, state) {
                  openedExtra = state.extra;
                  return const SizedBox(key: Key('add_food_route'));
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open_add_food_button')));
    await tester.pumpAndSettle();

    expect(find.text('Log food'), findsOneWidget);
    expect(find.byKey(const Key('meal_picker_lunch')), findsOneWidget);
    expect(find.byKey(const Key('add_food_route')), findsNothing);

    await tester.tap(find.byKey(const Key('meal_picker_lunch')));
    await tester.pumpAndSettle();

    final target = openedExtra as FoodLogTarget;
    expect(target.mealType, MealType.lunch);
    expect(find.byKey(const Key('add_food_route')), findsOneWidget);
  });
}

const _profile = UserProfile(
  id: 'local-user',
  age: 30,
  heightCm: 175,
  weightKg: 70,
  gender: Gender.male,
  activityLevel: ActivityLevel.moderatelyActive,
  goalType: GoalType.maintain,
  calorieGoal: 2200,
  macroTargets: MacroTargets(
    proteinGrams: 126,
    carbsGrams: 260,
    fatGrams: 63,
    fiberGrams: 30,
  ),
);
