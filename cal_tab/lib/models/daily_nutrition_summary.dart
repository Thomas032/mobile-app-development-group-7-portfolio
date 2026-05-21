import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/macro_targets.dart';

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.calorieGoal,
    required this.macroTargets,
    required this.caloriesConsumed,
    required this.proteinConsumedGrams,
    required this.carbsConsumedGrams,
    required this.fatConsumedGrams,
    required this.fiberConsumedGrams,
    this.sugarConsumedGrams = 0,
    this.sodiumConsumedMilligrams = 0,
    this.saturatedFatConsumedGrams = 0,
  });

  final int calorieGoal;
  final MacroTargets macroTargets;
  final int caloriesConsumed;
  final double proteinConsumedGrams;
  final double carbsConsumedGrams;
  final double fatConsumedGrams;
  final double fiberConsumedGrams;
  final double sugarConsumedGrams;
  final double sodiumConsumedMilligrams;
  final double saturatedFatConsumedGrams;

  int get caloriesLeft => calorieGoal - caloriesConsumed;
  double get calorieProgress => _progress(caloriesConsumed, calorieGoal);
  double get proteinProgress =>
      _progress(proteinConsumedGrams, macroTargets.proteinGrams);
  double get carbsProgress =>
      _progress(carbsConsumedGrams, macroTargets.carbsGrams);
  double get fatProgress => _progress(fatConsumedGrams, macroTargets.fatGrams);
  double get fiberProgress =>
      _progress(fiberConsumedGrams, macroTargets.fiberGrams);

  factory DailyNutritionSummary.fromEntries({
    required int calorieGoal,
    required MacroTargets macroTargets,
    required Iterable<MealEntry> entries,
  }) {
    var calories = 0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    var fiber = 0.0;
    var sugar = 0.0;
    var sodium = 0.0;
    var saturatedFat = 0.0;

    for (final entry in entries) {
      calories += entry.calories;
      protein += entry.proteinGrams;
      carbs += entry.carbsGrams;
      fat += entry.fatGrams;
      fiber += entry.fiberGrams;
      sugar += entry.sugarGrams;
      sodium += entry.sodiumMilligrams;
      saturatedFat += entry.saturatedFatGrams;
    }

    return DailyNutritionSummary(
      calorieGoal: calorieGoal,
      macroTargets: macroTargets,
      caloriesConsumed: calories,
      proteinConsumedGrams: protein,
      carbsConsumedGrams: carbs,
      fatConsumedGrams: fat,
      fiberConsumedGrams: fiber,
      sugarConsumedGrams: sugar,
      sodiumConsumedMilligrams: sodium,
      saturatedFatConsumedGrams: saturatedFat,
    );
  }

  static double _progress(num consumed, num target) {
    if (target <= 0) {
      return 0;
    }
    return consumed / target;
  }
}
