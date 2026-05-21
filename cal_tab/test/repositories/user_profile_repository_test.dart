import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/repositories/user_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_key_value_store.dart';

void main() {
  group('LocalUserProfileRepository', () {
    test('returns null when no profile has been saved', () async {
      final repository = LocalUserProfileRepository(
        store: InMemoryKeyValueStore(),
      );

      expect(await repository.loadProfile(), isNull);
    });

    test('saves and loads a user profile', () async {
      final repository = LocalUserProfileRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveProfile(_profile);
      final loadedProfile = await repository.loadProfile();

      expect(loadedProfile, isNotNull);
      expect(loadedProfile!.id, _profile.id);
      expect(loadedProfile.age, _profile.age);
      expect(loadedProfile.activityLevel, _profile.activityLevel);
      expect(loadedProfile.macroTargets, _profile.macroTargets);
    });

    test('clears a saved profile', () async {
      final repository = LocalUserProfileRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveProfile(_profile);
      await repository.clearProfile();

      expect(await repository.loadProfile(), isNull);
    });
  });
}

const _profile = UserProfile(
  id: 'local-user',
  age: 30,
  heightCm: 175,
  weightKg: 70,
  gender: Gender.male,
  activityLevel: ActivityLevel.moderatelyActive,
  goalType: GoalType.cut,
  calorieGoal: 2200,
  macroTargets: MacroTargets(
    proteinGrams: 126,
    carbsGrams: 260,
    fatGrams: 63,
    fiberGrams: 30,
  ),
);
