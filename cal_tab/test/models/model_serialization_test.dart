import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('model serialization', () {
    test('round-trips UserProfile JSON', () {
      const profile = UserProfile(
        id: 'user-1',
        age: 28,
        heightCm: 178,
        weightKg: 76,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goalType: GoalType.cut,
        calorieGoal: 2200,
        macroTargets: MacroTargets(
          proteinGrams: 136.8,
          carbsGrams: 280,
          fatGrams: 68.4,
          fiberGrams: 30.8,
        ),
      );

      final decoded = UserProfile.fromJson(profile.toJson());

      expect(decoded.id, profile.id);
      expect(decoded.age, profile.age);
      expect(decoded.heightCm, profile.heightCm);
      expect(decoded.weightKg, profile.weightKg);
      expect(decoded.gender, profile.gender);
      expect(decoded.activityLevel, profile.activityLevel);
      expect(decoded.goalType, profile.goalType);
      expect(decoded.calorieGoal, profile.calorieGoal);
      expect(decoded.macroTargets, profile.macroTargets);
    });

    test('round-trips MealEntry JSON with derived calories', () {
      final entry = MealEntry(
        id: 'entry-1',
        date: DateTime.utc(2026, 5, 5, 8, 30),
        mealType: MealType.breakfast,
        foodItem: const FoodItem(
          id: 'food-1',
          name: 'Greek yogurt',
          calories: 120,
          proteinGrams: 10,
          carbsGrams: 8,
          fatGrams: 4,
          fiberGrams: 0,
          imageUrl: 'https://example.com/yogurt.png',
        ),
        quantity: 1.5,
      );

      final json = entry.toJson();
      final decoded = MealEntry.fromJson(json);

      expect(json['calories'], 180);
      expect(decoded.id, entry.id);
      expect(decoded.date, entry.date);
      expect(decoded.mealType, entry.mealType);
      expect(decoded.foodItem.name, entry.foodItem.name);
      expect(decoded.quantity, entry.quantity);
      expect(decoded.calories, 180);
    });
  });
}
