import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/app_root_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    expect(find.text('CalTab'), findsOneWidget);
    expect(profileRepository.profile, isNotNull);
    expect(profileRepository.profile!.calorieGoal, 2556);
  });
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
