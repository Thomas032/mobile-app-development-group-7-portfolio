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

  String toJson() => name;

  static MealType fromJson(String value) {
    return MealType.values.byName(value);
  }
}
