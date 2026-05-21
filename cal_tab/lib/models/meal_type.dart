import 'package:flutter/material.dart';

enum MealType {
  breakfast,
  snackMorning,
  lunch,
  snackAfternoon,
  dinner,
  secondDinner;

  String get label {
    return switch (this) {
      MealType.breakfast => 'Breakfast',
      MealType.snackMorning => 'Snack',
      MealType.lunch => 'Lunch',
      MealType.snackAfternoon => 'Snack',
      MealType.dinner => 'Dinner',
      MealType.secondDinner => 'Second Dinner',
    };
  }

  String get descriptiveLabel {
    return switch (this) {
      MealType.breakfast => 'Breakfast',
      MealType.snackMorning => 'Morning snack',
      MealType.lunch => 'Lunch',
      MealType.snackAfternoon => 'Afternoon snack',
      MealType.dinner => 'Dinner',
      MealType.secondDinner => 'Second dinner',
    };
  }

  IconData get icon {
    return switch (this) {
      MealType.breakfast => Icons.free_breakfast_outlined,
      MealType.snackMorning => Icons.bakery_dining_outlined,
      MealType.lunch => Icons.lunch_dining_outlined,
      MealType.snackAfternoon => Icons.cookie_outlined,
      MealType.dinner => Icons.dinner_dining_outlined,
      MealType.secondDinner => Icons.nightlight_outlined,
    };
  }

  String toJson() => name;

  static MealType fromJson(String value) {
    return MealType.values.byName(value);
  }
}
