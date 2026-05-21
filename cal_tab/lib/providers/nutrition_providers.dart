import 'package:cal_tab/services/meal_assignment_service.dart';
import 'package:cal_tab/services/nutrition_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nutritionCalculatorProvider = Provider<NutritionCalculator>((ref) {
  return const NutritionCalculator();
});

final mealAssignmentServiceProvider = Provider<MealAssignmentService>((ref) {
  return const MealAssignmentService();
});
