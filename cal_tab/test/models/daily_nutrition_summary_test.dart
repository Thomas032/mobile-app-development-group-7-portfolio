import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregates calories and macros from meal entries', () {
    final entries = [
      MealEntry(
        id: 'entry-1',
        date: DateTime.utc(2026, 5, 5, 8),
        mealType: MealType.breakfast,
        foodItem: const FoodItem(
          id: 'food-1',
          name: 'Oats',
          calories: 150,
          proteinGrams: 5,
          carbsGrams: 27,
          fatGrams: 3,
          fiberGrams: 4,
        ),
        quantity: 2,
      ),
      MealEntry(
        id: 'entry-2',
        date: DateTime.utc(2026, 5, 5, 12),
        mealType: MealType.lunch,
        foodItem: const FoodItem(
          id: 'food-2',
          name: 'Chicken bowl',
          calories: 520,
          proteinGrams: 42,
          carbsGrams: 52,
          fatGrams: 16,
          fiberGrams: 8,
        ),
        quantity: 1,
      ),
    ];

    const targets = MacroTargets(
      proteinGrams: 140,
      carbsGrams: 260,
      fatGrams: 70,
      fiberGrams: 31,
    );

    final summary = DailyNutritionSummary.fromEntries(
      calorieGoal: 2200,
      macroTargets: targets,
      entries: entries,
    );

    expect(summary.caloriesConsumed, 820);
    expect(summary.caloriesLeft, 1380);
    expect(summary.proteinConsumedGrams, 52);
    expect(summary.carbsConsumedGrams, 106);
    expect(summary.fatConsumedGrams, 22);
    expect(summary.fiberConsumedGrams, 16);
    expect(summary.calorieProgress, closeTo(0.3727, 0.0001));
  });
}
