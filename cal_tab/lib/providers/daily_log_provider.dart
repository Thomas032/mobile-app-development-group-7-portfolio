import 'package:cal_tab/models/daily_nutrition_summary.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyLogState {
  const DailyLogState({this.entries = const []});

  final List<MealEntry> entries;

  DailyLogState copyWith({List<MealEntry>? entries}) {
    return DailyLogState(entries: entries ?? this.entries);
  }

  List<MealEntry> entriesForDate(DateTime date) {
    return entries.where((entry) => _isSameDay(entry.date, date)).toList();
  }

  DailyNutritionSummary summaryFor({
    required DateTime date,
    required UserProfile profile,
  }) {
    return DailyNutritionSummary.fromEntries(
      calorieGoal: profile.calorieGoal,
      macroTargets: profile.macroTargets,
      entries: entriesForDate(date),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class DailyLogController extends Notifier<DailyLogState> {
  @override
  DailyLogState build() {
    return const DailyLogState();
  }

  void logFood({
    required String entryId,
    required FoodItem foodItem,
    required DateTime date,
    required double quantity,
    MealType? mealType,
  }) {
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Must be greater than zero.',
      );
    }

    final assignmentService = ref.read(mealAssignmentServiceProvider);
    final entry = MealEntry(
      id: entryId,
      date: date,
      mealType: mealType ?? assignmentService.assignFor(date),
      foodItem: foodItem,
      quantity: quantity,
    );

    state = state.copyWith(entries: [...state.entries, entry]);
  }

  Future<void> loadSavedEntries() async {
    final repository = await ref.read(mealLogRepositoryProvider.future);
    state = state.copyWith(entries: await repository.loadEntries());
  }

  Future<void> saveCurrentEntries() async {
    final repository = await ref.read(mealLogRepositoryProvider.future);
    await repository.saveEntries(state.entries);
  }

  Future<void> clearSavedEntries() async {
    final repository = await ref.read(mealLogRepositoryProvider.future);
    await repository.clearEntries();
    clear();
  }

  void removeEntry(String entryId) {
    state = state.copyWith(
      entries: [
        for (final entry in state.entries)
          if (entry.id != entryId) entry,
      ],
    );
  }

  void clear() {
    state = const DailyLogState();
  }
}

final dailyLogControllerProvider =
    NotifierProvider<DailyLogController, DailyLogState>(DailyLogController.new);
