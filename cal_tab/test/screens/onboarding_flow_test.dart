import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/app_root_screen.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_meal_log_repository.dart';
import '../fakes/fake_user_profile_repository.dart';

void main() {
  testWidgets('completes onboarding and saves the profile', (tester) async {
    _useTallViewport(tester);
    final profileRepository = FakeUserProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWith(
            (ref) async => profileRepository,
          ),
        ],
        child: const MaterialApp(home: AppRootScreen()),
      ),
    );

    expect(find.text('Create targets'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('age_field')), '30');
    await tester.enterText(find.byKey(const Key('height_field')), '175');
    await tester.enterText(find.byKey(const Key('weight_field')), '70');
    final finishButton = find.byKey(const Key('finish_onboarding_button'));
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(profileRepository.profile, isNotNull);
    expect(profileRepository.profile!.calorieGoal, 2556);
  });

  testWidgets('quick log updates the home summary and persists entries', (
    tester,
  ) async {
    _useTallViewport(tester);
    final mealRepository = FakeMealLogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => mealRepository),
        ],
        child: const MaterialApp(home: HomeScreen(profile: _profile)),
      ),
    );

    expect(find.text('2200'), findsOneWidget);
    expect(find.text('No food logged yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick_log_button')));
    await tester.pumpAndSettle();

    expect(find.text('2095'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(mealRepository.entries, hasLength(1));
  });
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
