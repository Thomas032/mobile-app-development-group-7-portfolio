import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/services/nutrition_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionCalculator', () {
    const calculator = NutritionCalculator();

    test('calculates BMR using Mifflin-St Jeor inputs', () {
      final bmr = calculator.calculateBmr(
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: Gender.male,
      );

      expect(bmr, closeTo(1648.75, 0.001));
    });

    test('calculates TDEE from activity multiplier', () {
      final tdee = calculator.calculateTdee(
        bmr: 1648.75,
        activityLevel: ActivityLevel.moderatelyActive,
      );

      expect(tdee, closeTo(2555.5625, 0.001));
    });

    test('applies goal adjustment for cut, maintain, and bulk', () {
      expect(
        calculator.calculateCalorieGoal(tdee: 2500, goalType: GoalType.cut),
        2100,
      );
      expect(
        calculator.calculateCalorieGoal(
          tdee: 2500,
          goalType: GoalType.maintain,
        ),
        2500,
      );
      expect(
        calculator.calculateCalorieGoal(tdee: 2500, goalType: GoalType.bulk),
        2900,
      );
    });

    test('clamps custom goal adjustments to the recommended range', () {
      expect(
        calculator.calculateCalorieGoal(
          tdee: 2500,
          goalType: GoalType.cut,
          goalAdjustmentKcal: 100,
        ),
        2200,
      );
      expect(
        calculator.calculateCalorieGoal(
          tdee: 2500,
          goalType: GoalType.bulk,
          goalAdjustmentKcal: 900,
        ),
        3000,
      );
    });

    test('calculates default macro targets from weight and calorie goal', () {
      final macros = calculator.calculateMacroTargets(
        weightKg: 70,
        calorieGoal: 2156,
      );

      expect(macros.proteinGrams, closeTo(126, 0.001));
      expect(macros.fatGrams, closeTo(63, 0.001));
      expect(macros.carbsGrams, closeTo(271.25, 0.001));
      expect(macros.fiberGrams, closeTo(30.184, 0.001));
    });

    test('calculates a full target bundle', () {
      final targets = calculator.calculateTargets(
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goalType: GoalType.cut,
      );

      expect(targets.bmr, closeTo(1648.75, 0.001));
      expect(targets.tdee, closeTo(2555.5625, 0.001));
      expect(targets.calorieGoal, 2156);
      expect(targets.macroTargets.proteinGrams, closeTo(126, 0.001));
    });

    test('rejects non-positive inputs', () {
      expect(
        () => calculator.calculateBmr(
          weightKg: 0,
          heightCm: 175,
          age: 30,
          gender: Gender.male,
        ),
        throwsArgumentError,
      );
    });
  });
}
