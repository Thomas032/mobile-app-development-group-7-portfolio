import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/screens/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switches between bottom navigation tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MainShellScreen(profile: _profile)),
      ),
    );

    expect(find.text('Today'), findsOneWidget);

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
