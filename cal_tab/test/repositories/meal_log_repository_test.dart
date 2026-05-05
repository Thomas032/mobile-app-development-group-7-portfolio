import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/repositories/meal_log_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_key_value_store.dart';

void main() {
  group('LocalMealLogRepository', () {
    test('returns an empty list when no entries have been saved', () async {
      final repository = LocalMealLogRepository(store: InMemoryKeyValueStore());

      expect(await repository.loadEntries(), isEmpty);
    });

    test('saves and loads meal entries', () async {
      final repository = LocalMealLogRepository(store: InMemoryKeyValueStore());

      await repository.saveEntries([_entry]);
      final entries = await repository.loadEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, _entry.id);
      expect(entries.single.date, _entry.date);
      expect(entries.single.foodItem.name, _entry.foodItem.name);
      expect(entries.single.calories, _entry.calories);
    });

    test('adds entries without replacing existing entries', () async {
      final repository = LocalMealLogRepository(store: InMemoryKeyValueStore());

      await repository.addEntry(_entry);
      await repository.addEntry(
        _entry.copyWith(id: 'entry-2', mealType: MealType.lunch),
      );

      final entries = await repository.loadEntries();

      expect(entries.map((entry) => entry.id), ['entry-1', 'entry-2']);
    });

    test('removes entries by id', () async {
      final repository = LocalMealLogRepository(store: InMemoryKeyValueStore());

      await repository.saveEntries([
        _entry,
        _entry.copyWith(id: 'entry-2', mealType: MealType.lunch),
      ]);
      await repository.removeEntry('entry-1');

      final entries = await repository.loadEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, 'entry-2');
    });

    test('clears all entries', () async {
      final repository = LocalMealLogRepository(store: InMemoryKeyValueStore());

      await repository.saveEntries([_entry]);
      await repository.clearEntries();

      expect(await repository.loadEntries(), isEmpty);
    });
  });
}

final _entry = MealEntry(
  id: 'entry-1',
  date: DateTime.utc(2026, 5, 5, 8, 30),
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
  quantity: 2,
);
