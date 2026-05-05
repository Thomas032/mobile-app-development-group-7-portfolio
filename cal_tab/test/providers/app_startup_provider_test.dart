import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/app_startup_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_app_settings_repository.dart';
import '../fakes/fake_meal_log_repository.dart';
import '../fakes/fake_user_profile_repository.dart';

void main() {
  test('hydrates settings, profile, and meal entries on startup', () async {
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWith(
          (ref) async => FakeAppSettingsRepository(
            initialSettings: const AppSettings(themeMode: AppThemeMode.dark),
          ),
        ),
        userProfileRepositoryProvider.overrideWith(
          (ref) async => FakeUserProfileRepository(initialProfile: _profile),
        ),
        mealLogRepositoryProvider.overrideWith(
          (ref) async => FakeMealLogRepository(initialEntries: [_entry]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appStartupProvider.future);

    expect(
      container.read(appSettingsControllerProvider).themeMode,
      AppThemeMode.dark,
    );
    expect(container.read(profileSetupControllerProvider).profile!.id, 'user');
    expect(container.read(dailyLogControllerProvider).entries, hasLength(1));
  });
}

const _profile = UserProfile(
  id: 'user',
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

final _entry = MealEntry(
  id: 'entry',
  date: DateTime(2026, 5, 5, 8),
  mealType: MealType.breakfast,
  foodItem: const FoodItem(
    id: 'banana',
    name: 'Banana',
    calories: 105,
    proteinGrams: 1.3,
    carbsGrams: 27,
    fatGrams: 0.4,
    fiberGrams: 3.1,
  ),
  quantity: 1,
);
