import 'dart:math' as math;

import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';

class StatsSnapshot {
  const StatsSnapshot({
    required this.profile,
    required this.days,
    required this.streakDays,
  });

  final UserProfile profile;
  final List<StatsDay> days;
  final int streakDays;

  DateTime get startDate => days.first.date;
  DateTime get endDate => days.last.date;
  int get totalCalories =>
      days.fold(0, (sum, day) => sum + day.summary.caloriesConsumed);
  int get averageCalories => (totalCalories / days.length).round();
  int get loggedDays => days.where((day) => day.hasEntries).length;
  int get targetDays => days.where((day) => day.isNearCalorieGoal).length;

  double get maxChartCalories {
    final maxLogged = days.fold<int>(
      profile.calorieGoal,
      (max, day) => math.max(max, day.summary.caloriesConsumed),
    );
    return math.max(1.0, maxLogged * 1.12);
  }

  double get averageProteinGrams =>
      _averageLoggedDayMacro((summary) => summary.proteinConsumedGrams);

  double get averageCarbsGrams =>
      _averageLoggedDayMacro((summary) => summary.carbsConsumedGrams);

  double get averageFatGrams =>
      _averageLoggedDayMacro((summary) => summary.fatConsumedGrams);

  double get averageFiberGrams =>
      _averageLoggedDayMacro((summary) => summary.fiberConsumedGrams);

  double get averageSugarGrams =>
      _averageLoggedDayMacro((summary) => summary.sugarConsumedGrams);

  double get averageSodiumMilligrams =>
      _averageLoggedDayMacro((summary) => summary.sodiumConsumedMilligrams);

  double get averageSaturatedFatGrams =>
      _averageLoggedDayMacro((summary) => summary.saturatedFatConsumedGrams);

  Map<MealType, int> get mealDaysLogged {
    return {
      for (final mealType in MealType.values)
        mealType: days
            .where(
              (day) => day.entries.any((entry) => entry.mealType == mealType),
            )
            .length,
    };
  }

  String get rangeLabel => '${shortDate(startDate)} - ${shortDate(endDate)}';

  double _averageLoggedDayMacro(
    double Function(DailyNutritionSummary summary) valueFor,
  ) {
    final logged = days.where((day) => day.hasEntries).toList();
    if (logged.isEmpty) {
      return 0;
    }

    final total = logged.fold<double>(
      0,
      (sum, day) => sum + valueFor(day.summary),
    );
    return total / logged.length;
  }
}

class StatsDay {
  const StatsDay({
    required this.date,
    required this.entries,
    required this.summary,
  });

  final DateTime date;
  final List<MealEntry> entries;
  final DailyNutritionSummary summary;

  bool get hasEntries => entries.isNotEmpty;

  bool get isNearCalorieGoal {
    if (!hasEntries) {
      return false;
    }

    final progress = summary.calorieProgress;
    return progress >= 0.85 && progress <= 1.15;
  }
}

String shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
