import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/repositories/custom_meal_repository.dart';

class FakeCustomMealRepository implements CustomMealRepository {
  FakeCustomMealRepository({List<FoodItem> initialMeals = const []})
    : _meals = [...initialMeals];

  List<FoodItem> _meals;

  List<FoodItem> get meals => List.unmodifiable(_meals);

  @override
  Future<List<FoodItem>> loadMeals() async {
    return [..._meals];
  }

  @override
  Future<void> saveMeals(List<FoodItem> meals) async {
    _meals = [...meals];
  }

  @override
  Future<void> addMeal(FoodItem meal) async {
    _meals = [..._meals, meal];
  }

  @override
  Future<void> removeMeal(String id) async {
    _meals = [
      for (final meal in _meals)
        if (meal.id != id) meal,
    ];
  }

  @override
  Future<void> updateMeal(FoodItem meal) async {
    _meals = [
      for (final existing in _meals)
        if (existing.id == meal.id) meal else existing,
    ];
  }

  @override
  Future<void> clearMeals() async {
    _meals = const [];
  }
}
