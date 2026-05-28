import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/repositories/custom_meal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_key_value_store.dart';

void main() {
  group('LocalCustomMealRepository', () {
    test(
      'returns an empty list when no custom meals have been saved',
      () async {
        final repository = LocalCustomMealRepository(
          store: InMemoryKeyValueStore(),
        );

        expect(await repository.loadMeals(), isEmpty);
      },
    );

    test('saves and loads custom meals', () async {
      final repository = LocalCustomMealRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveMeals([_oats]);
      final meals = await repository.loadMeals();

      expect(meals, hasLength(1));
      expect(meals.single.id, _oats.id);
      expect(meals.single.name, _oats.name);
      expect(meals.single.calories, _oats.calories);
    });

    test('adds custom meals without replacing existing items', () async {
      final repository = LocalCustomMealRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.addMeal(_oats);
      await repository.addMeal(_oats.copyWith(id: 'custom-2', name: 'Wrap'));

      final meals = await repository.loadMeals();

      expect(meals.map((meal) => meal.id), ['custom-1', 'custom-2']);
    });

    test('clears all custom meals', () async {
      final repository = LocalCustomMealRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveMeals([_oats]);
      await repository.clearMeals();

      expect(await repository.loadMeals(), isEmpty);
    });
  });
}

const _oats = FoodItem(
  id: 'custom-1',
  name: 'Protein oats',
  calories: 370,
  proteinGrams: 22,
  carbsGrams: 44,
  fatGrams: 10,
  fiberGrams: 8,
);
