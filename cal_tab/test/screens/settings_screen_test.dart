import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_app_settings_repository.dart';
import '../fakes/fake_user_profile_repository.dart';
import '../fakes/in_memory_secure_key_value_store.dart';

void main() {
  testWidgets('theme segmented button updates the app settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settingsRepo = FakeAppSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWith((ref) async => settingsRepo),
        userProfileRepositoryProvider.overrideWith(
          (ref) async => FakeUserProfileRepository(initialProfile: _profile),
        ),
        secureKeyValueStoreProvider.overrideWithValue(
          InMemorySecureKeyValueStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(profileSetupControllerProvider.notifier)
        .loadSavedProfile();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily targets'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      container.read(appSettingsControllerProvider).themeMode,
      AppThemeMode.dark,
    );
    expect(settingsRepo.settings.themeMode, AppThemeMode.dark);
  });

  testWidgets('saving daily targets updates the profile via the controller', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profileRepo = FakeUserProfileRepository(initialProfile: _profile);
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWith(
          (ref) async => FakeAppSettingsRepository(),
        ),
        userProfileRepositoryProvider.overrideWith((ref) async => profileRepo),
        secureKeyValueStoreProvider.overrideWithValue(
          InMemorySecureKeyValueStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(profileSetupControllerProvider.notifier)
        .loadSavedProfile();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('calorie_goal_field')),
      '2500',
    );
    await tester.tap(find.byKey(const Key('save_targets_button')));
    await tester.pumpAndSettle();

    final profile = container.read(profileSetupControllerProvider).profile!;
    expect(profile.calorieGoal, 2500);
    expect(profileRepo.profile?.calorieGoal, 2500);
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
