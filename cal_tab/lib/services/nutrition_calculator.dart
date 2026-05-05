import 'dart:math';

import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';

class NutritionTargets {
  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.calorieGoal,
    required this.macroTargets,
  });

  final double bmr;
  final double tdee;
  final int calorieGoal;
  final MacroTargets macroTargets;
}

class NutritionCalculator {
  const NutritionCalculator();

  static const int minGoalAdjustmentKcal = 300;
  static const int defaultGoalAdjustmentKcal = 400;
  static const int maxGoalAdjustmentKcal = 500;
  static const double defaultProteinGramsPerKg = 1.8;
  static const double defaultFatGramsPerKg = 0.9;
  static const double defaultFiberGramsPer1000Kcal = 14;

  double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    _validatePositive(weightKg, 'weightKg');
    _validatePositive(heightCm, 'heightCm');
    _validatePositive(age, 'age');

    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) +
        gender.bmrConstant;
  }

  double calculateTdee({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    _validatePositive(bmr, 'bmr');
    return bmr * activityLevel.multiplier;
  }

  int calculateCalorieGoal({
    required double tdee,
    required GoalType goalType,
    int goalAdjustmentKcal = defaultGoalAdjustmentKcal,
  }) {
    _validatePositive(tdee, 'tdee');

    final adjustment = goalAdjustmentKcal.clamp(
      minGoalAdjustmentKcal,
      maxGoalAdjustmentKcal,
    );

    return switch (goalType) {
      GoalType.cut => (tdee - adjustment).round(),
      GoalType.maintain => tdee.round(),
      GoalType.bulk => (tdee + adjustment).round(),
    };
  }

  MacroTargets calculateMacroTargets({
    required double weightKg,
    required int calorieGoal,
    double proteinGramsPerKg = defaultProteinGramsPerKg,
    double fatGramsPerKg = defaultFatGramsPerKg,
  }) {
    _validatePositive(weightKg, 'weightKg');
    _validatePositive(calorieGoal, 'calorieGoal');
    _validatePositive(proteinGramsPerKg, 'proteinGramsPerKg');
    _validatePositive(fatGramsPerKg, 'fatGramsPerKg');

    final protein = weightKg * proteinGramsPerKg;
    final fat = weightKg * fatGramsPerKg;
    final caloriesFromProtein = protein * 4;
    final caloriesFromFat = fat * 9;
    final remainingCalories = max(
      0.0,
      calorieGoal - caloriesFromProtein - caloriesFromFat,
    );
    final carbs = remainingCalories / 4;
    final fiber = (calorieGoal / 1000) * defaultFiberGramsPer1000Kcal;

    return MacroTargets(
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      fiberGrams: fiber,
    );
  }

  NutritionTargets calculateTargets({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required ActivityLevel activityLevel,
    required GoalType goalType,
    int goalAdjustmentKcal = defaultGoalAdjustmentKcal,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = calculateTdee(bmr: bmr, activityLevel: activityLevel);
    final calorieGoal = calculateCalorieGoal(
      tdee: tdee,
      goalType: goalType,
      goalAdjustmentKcal: goalAdjustmentKcal,
    );
    final macroTargets = calculateMacroTargets(
      weightKg: weightKg,
      calorieGoal: calorieGoal,
    );

    return NutritionTargets(
      bmr: bmr,
      tdee: tdee,
      calorieGoal: calorieGoal,
      macroTargets: macroTargets,
    );
  }

  void _validatePositive(num value, String fieldName) {
    if (value <= 0) {
      throw ArgumentError.value(value, fieldName, 'Must be greater than zero.');
    }
  }
}
