import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_meal_log_repository.dart';

void main() {
  group('DailyLogController', () {
    test('logs food and auto-assigns meal by time', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(dailyLogControllerProvider.notifier)
          .logFood(
            entryId: 'entry-1',
            foodItem: _banana,
            date: DateTime(2026, 5, 5, 8),
            quantity: 2,
          );

      final entries = container.read(dailyLogControllerProvider).entries;

      expect(entries, hasLength(1));
      expect(entries.single.mealType, MealType.breakfast);
      expect(entries.single.calories, 210);
    });

    test('allows explicit meal override', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(dailyLogControllerProvider.notifier)
          .logFood(
            entryId: 'entry-1',
            foodItem: _banana,
            date: DateTime(2026, 5, 5, 8),
            quantity: 1,
            mealType: MealType.snackMorning,
          );

      final entries = container.read(dailyLogControllerProvider).entries;

      expect(entries.single.mealType, MealType.snackMorning);
    });

    test('summarizes entries for a selected date only', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(dailyLogControllerProvider.notifier);

      controller.logFood(
        entryId: 'entry-1',
        foodItem: _banana,
        date: DateTime(2026, 5, 5, 8),
        quantity: 1,
      );
      controller.logFood(
        entryId: 'entry-2',
        foodItem: _banana,
        date: DateTime(2026, 5, 6, 8),
        quantity: 1,
      );

      final summary = container
          .read(dailyLogControllerProvider)
          .summaryFor(date: DateTime(2026, 5, 5), profile: _profile);

      expect(summary.caloriesConsumed, 105);
      expect(summary.caloriesLeft, 2095);
      expect(summary.carbsConsumedGrams, 27);
    });

    test('removes entries by id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(dailyLogControllerProvider.notifier);

      controller.logFood(
        entryId: 'entry-1',
        foodItem: _banana,
        date: DateTime(2026, 5, 5, 8),
        quantity: 1,
      );
      controller.removeEntry('entry-1');

      expect(container.read(dailyLogControllerProvider).entries, isEmpty);
    });

    test('rejects non-positive quantities', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container
            .read(dailyLogControllerProvider.notifier)
            .logFood(
              entryId: 'entry-1',
              foodItem: _banana,
              date: DateTime(2026, 5, 5, 8),
              quantity: 0,
            ),
        throwsArgumentError,
      );
    });

    test('loads saved entries from the repository', () async {
      final repository = FakeMealLogRepository(initialEntries: [_entry]);
      final container = ProviderContainer(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dailyLogControllerProvider.notifier)
          .loadSavedEntries();

      final entries = container.read(dailyLogControllerProvider).entries;

      expect(entries, hasLength(1));
      expect(entries.single.id, _entry.id);
    });

    test('saves current entries to the repository', () async {
      final repository = FakeMealLogRepository();
      final container = ProviderContainer(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(dailyLogControllerProvider.notifier);
      controller.logFood(
        entryId: 'entry-1',
        foodItem: _banana,
        date: DateTime(2026, 5, 5, 8),
        quantity: 1,
      );
      await controller.saveCurrentEntries();

      expect(repository.entries, hasLength(1));
      expect(repository.entries.single.id, 'entry-1');
    });
  });
}

final _entry = MealEntry(
  id: 'saved-entry',
  date: DateTime(2026, 5, 5, 8),
  mealType: MealType.breakfast,
  foodItem: _banana,
  quantity: 1,
);

const _banana = FoodItem(
  id: 'banana',
  name: 'Banana',
  calories: 105,
  proteinGrams: 1.3,
  carbsGrams: 27,
  fatGrams: 0.4,
  fiberGrams: 3.1,
);

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
