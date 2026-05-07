import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_type.dart';

DateTime normalizeLogDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String logDateKey(DateTime date) {
  final normalized = normalizeLogDate(date);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class FoodLogTarget {
  const FoodLogTarget({required this.date, this.mealType});

  final DateTime date;
  final MealType? mealType;

  FoodLogTarget normalized() {
    return FoodLogTarget(date: normalizeLogDate(date), mealType: mealType);
  }
}

class FoodDetailRouteArgs {
  const FoodDetailRouteArgs({required this.foodItem, required this.target});

  final FoodItem? foodItem;
  final FoodLogTarget target;
}
