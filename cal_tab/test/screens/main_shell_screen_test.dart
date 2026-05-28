import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/in_memory_secure_key_value_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('switches between bottom navigation tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(
            InMemorySecureKeyValueStore(),
          ),
        ],
        child: const MaterialApp(home: MainShellScreen(profile: _profile)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CalTab'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stats_tab_button')));
    await tester.pumpAndSettle();
    expect(find.text('Daily calories'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai_tab_button')));
    await tester.pumpAndSettle();
    expect(find.text('Bring your own Gemini key'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings_tab_button')));
    await tester.pumpAndSettle();
    // Danger Zone is the 7th section in the settings list — scroll it into view.
    await tester.scrollUntilVisible(
      find.byKey(const Key('reset_profile_button')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('settings_scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('reset_profile_button')), findsOneWidget);
    expect(find.byKey(const Key('clear_food_logs_button')), findsOneWidget);
  });

  testWidgets(
    'tab plus opens the add-food action sheet and routes to manual search',
    (tester) async {
      Object? openedExtra;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureKeyValueStoreProvider.overrideWithValue(
              InMemorySecureKeyValueStore(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, __) =>
                      const MainShellScreen(profile: _profile),
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
      expect(find.byKey(const Key('add_food_action_snap2cal')), findsOneWidget);
      expect(find.byKey(const Key('add_food_action_barcode')), findsOneWidget);
      expect(find.byKey(const Key('add_food_action_search')), findsOneWidget);
      expect(find.byKey(const Key('add_food_route')), findsNothing);

      await tester.tap(find.byKey(const Key('add_food_action_search')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add_food_route')), findsOneWidget);
      final target = openedExtra as FoodLogTarget;
      expect(target.mealType, isA<MealType>());
    },
  );
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
