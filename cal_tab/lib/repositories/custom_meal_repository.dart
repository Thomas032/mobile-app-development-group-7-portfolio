import 'dart:convert';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/services/local_key_value_store.dart';

abstract class CustomMealRepository {
  Future<List<FoodItem>> loadMeals();

  Future<void> saveMeals(List<FoodItem> meals);

  Future<void> addMeal(FoodItem meal);

  Future<void> clearMeals();
}

class LocalCustomMealRepository implements CustomMealRepository {
  const LocalCustomMealRepository({
    required LocalKeyValueStore store,
    this.storageKey = 'custom_meals_v1',
  }) : _store = store;

  final LocalKeyValueStore _store;
  final String storageKey;

  @override
  Future<List<FoodItem>> loadMeals() async {
    final encodedMeals = await _store.readString(storageKey);
    if (encodedMeals == null) {
      return const [];
    }

    final decoded = jsonDecode(encodedMeals) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(FoodItem.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveMeals(List<FoodItem> meals) {
    final encodedMeals = meals.map((meal) => meal.toJson()).toList();
    return _store.writeString(storageKey, jsonEncode(encodedMeals));
  }

  @override
  Future<void> addMeal(FoodItem meal) async {
    final meals = await loadMeals();
    await saveMeals([...meals, meal]);
  }

  @override
  Future<void> clearMeals() {
    return _store.remove(storageKey);
  }
}
