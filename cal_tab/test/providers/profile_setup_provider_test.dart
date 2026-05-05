import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
