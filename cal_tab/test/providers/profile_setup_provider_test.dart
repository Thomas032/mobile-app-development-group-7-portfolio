import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_user_profile_repository.dart';

void main() {
  group('ProfileSetupController', () {
    test('creates a profile with calculated calorie and macro targets', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        profileSetupControllerProvider.notifier,
      );

      controller.completeOnboarding(
        profileId: 'local-user',
        input: const ProfileSetupInput(
          age: 30,
          heightCm: 175,
          weightKg: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
          goalType: GoalType.cut,
        ),
      );

      final state = container.read(profileSetupControllerProvider);
      final profile = state.profile;

      expect(state.isComplete, isTrue);
      expect(profile, isNotNull);
      expect(profile!.id, 'local-user');
      expect(profile.calorieGoal, 2156);
      expect(profile.macroTargets.proteinGrams, closeTo(126, 0.001));
    });

    test('can clear profile setup state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        profileSetupControllerProvider.notifier,
      );

      controller.completeOnboarding(
        profileId: 'local-user',
        input: const ProfileSetupInput(
          age: 30,
          heightCm: 175,
          weightKg: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.sedentary,
          goalType: GoalType.maintain,
        ),
      );
      controller.clear();

      expect(
        container.read(profileSetupControllerProvider).isComplete,
        isFalse,
      );
    });

    test('loads a saved profile from the repository', () async {
      final repository = FakeUserProfileRepository(initialProfile: _profile);
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(profileSetupControllerProvider.notifier)
          .loadSavedProfile();

      final state = container.read(profileSetupControllerProvider);

      expect(state.isComplete, isTrue);
      expect(state.profile!.id, _profile.id);
    });

    test('saves the current profile to the repository', () async {
      final repository = FakeUserProfileRepository();
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        profileSetupControllerProvider.notifier,
      );
      controller.completeOnboarding(
        profileId: 'local-user',
        input: const ProfileSetupInput(
          age: 30,
          heightCm: 175,
          weightKg: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
          goalType: GoalType.cut,
        ),
      );
      await controller.saveCurrentProfile();

      expect(repository.profile, isNotNull);
      expect(repository.profile!.id, 'local-user');
    });
  });
}

const _profile = UserProfile(
  id: 'saved-user',
  age: 29,
  heightCm: 168,
  weightKg: 62,
  gender: Gender.female,
  activityLevel: ActivityLevel.lightlyActive,
  goalType: GoalType.maintain,
  calorieGoal: 1900,
  macroTargets: MacroTargets(
    proteinGrams: 111.6,
    carbsGrams: 224.8,
    fatGrams: 55.8,
    fiberGrams: 26.6,
  ),
);
