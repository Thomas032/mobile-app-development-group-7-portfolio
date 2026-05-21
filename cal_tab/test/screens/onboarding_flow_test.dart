import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/app_root_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_user_profile_repository.dart';
import '../fakes/in_memory_secure_key_value_store.dart';

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
          secureKeyValueStoreProvider.overrideWithValue(
            InMemorySecureKeyValueStore(),
          ),
        ],
        child: const MaterialApp(home: AppRootScreen()),
      ),
    );

    expect(find.text('Start with your goal'), findsOneWidget);

    await tester.tap(find.text('Stay on track'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboarding_primary_button_0')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Slider).at(0), const Offset(24, 0));
    await tester.drag(find.byType(Slider).at(1), const Offset(24, 0));
    await tester.drag(find.byType(Slider).at(2), const Offset(24, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboarding_primary_button_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Male'));
    await tester.tap(find.text('Moderately active'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboarding_primary_button_2')));
    await tester.pumpAndSettle();

    expect(find.text('Your plan is ready'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboarding_primary_button_3')));
    await tester.pumpAndSettle();

    expect(find.text('CalTab'), findsOneWidget);
    expect(profileRepository.profile, isNotNull);
    expect(profileRepository.profile!.goalType, GoalType.maintain);
    expect(profileRepository.profile!.calorieGoal, greaterThan(0));
  });
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
