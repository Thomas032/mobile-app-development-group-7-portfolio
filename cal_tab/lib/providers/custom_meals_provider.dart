import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomMealsController extends AsyncNotifier<List<FoodItem>> {
  @override
  Future<List<FoodItem>> build() async {
    final repository = await ref.read(customMealRepositoryProvider.future);
    return repository.loadMeals();
  }

  Future<void> addMeal(FoodItem meal) async {
    final current = state.asData?.value ?? const <FoodItem>[];
    final nextMeals = <FoodItem>[...current, meal];
    state = AsyncData(nextMeals);

    final repository = await ref.read(customMealRepositoryProvider.future);
    await repository.saveMeals(nextMeals);
  }

  Future<void> replaceMeals(List<FoodItem> meals) async {
    state = AsyncData(meals);
    final repository = await ref.read(customMealRepositoryProvider.future);
    await repository.saveMeals(meals);
  }
}

final customMealsControllerProvider =
    AsyncNotifierProvider<CustomMealsController, List<FoodItem>>(
      CustomMealsController.new,
    );
