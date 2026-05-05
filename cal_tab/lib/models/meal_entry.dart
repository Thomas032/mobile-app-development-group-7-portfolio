import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_type.dart';

class MealEntry {
  const MealEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodItem,
    required this.quantity,
  });

  final String id;
  final DateTime date;
  final MealType mealType;
  final FoodItem foodItem;
  final double quantity;

  int get calories => (foodItem.calories * quantity).round();
  double get proteinGrams => foodItem.proteinGrams * quantity;
  double get carbsGrams => foodItem.carbsGrams * quantity;
  double get fatGrams => foodItem.fatGrams * quantity;
  double get fiberGrams => foodItem.fiberGrams * quantity;

  MealEntry copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    FoodItem? foodItem,
    double? quantity,
  }) {
    return MealEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
    );
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: MealType.fromJson(json['mealType'] as String),
      foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.toJson(),
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'calories': calories,
    };
  }
}
