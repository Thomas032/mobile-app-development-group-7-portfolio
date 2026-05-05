import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/add_food_screen.dart';
import 'package:cal_tab/screens/app_root_screen.dart';
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

  testWidgets('manual food entry persists a meal entry', (tester) async {
    _useTallViewport(tester);
    final mealRepository = FakeMealLogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => mealRepository),
        ],
        child: const MaterialApp(home: AddFoodScreen()),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('manual_food_name_field')),
      'Banana',
    );
    await tester.enterText(
      find.byKey(const Key('manual_calories_field')),
      '105',
    );
    await tester.enterText(
      find.byKey(const Key('manual_protein_field')),
      '1.3',
    );
    await tester.enterText(find.byKey(const Key('manual_carbs_field')), '27');
    await tester.enterText(find.byKey(const Key('manual_fat_field')), '0.4');
    await tester.enterText(find.byKey(const Key('manual_fiber_field')), '3.1');

    await tester.tap(find.byKey(const Key('save_manual_food_button')));
    await tester.pumpAndSettle();

    expect(mealRepository.entries, hasLength(1));
    expect(mealRepository.entries.single.foodItem.name, 'Banana');
    expect(mealRepository.entries.single.calories, 105);
  });
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
