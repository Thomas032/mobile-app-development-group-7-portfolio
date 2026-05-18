import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen({List<MealEntry> entries = const []}) {
    return ProviderScope(
      overrides: [
        dailyLogControllerProvider.overrideWith(
          () => _SeedableLogController(entries),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: StatsScreen(profile: _profile)),
      ),
    );
  }

  testWidgets('renders focused weekly statistics sections', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Daily calories'), findsOneWidget);
    expect(find.text('Target 2200'), findsOneWidget);

    await _scrollStatsUntilVisible(tester, find.text('Meal rhythm'));

    expect(find.text('Macro averages'), findsOneWidget);
    expect(find.text('Meal rhythm'), findsOneWidget);
  });

  testWidgets('summarizes weekly calories and logged-day macro averages', (
    tester,
  ) async {
    final today = _today();
    final yesterday = today.subtract(const Duration(days: 1));

    await tester.pumpWidget(
      buildScreen(
        entries: [
          _entryFor(
            date: today,
            mealType: MealType.breakfast,
            calories: 2200,
            protein: 100,
            carbs: 260,
            fat: 60,
            fiber: 30,
          ),
          _entryFor(
            date: yesterday,
            mealType: MealType.lunch,
            calories: 1100,
            protein: 50,
            carbs: 130,
            fat: 30,
            fiber: 15,
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('471'), findsOneWidget);
    expect(find.text('1/7'), findsWidgets);

    await _scrollStatsUntilVisible(tester, find.text('Macro averages'));

    expect(find.text('Across 2 logged days'), findsOneWidget);
    expect(find.text('75/126g'), findsOneWidget);
    expect(find.text('195/260g'), findsOneWidget);
    expect(find.text('45/63g'), findsOneWidget);
    expect(find.text('23/30g'), findsOneWidget);
  });

  testWidgets('meal rhythm counts unique logged days per meal type', (
    tester,
  ) async {
    final today = _today();
    final yesterday = today.subtract(const Duration(days: 1));

    await tester.pumpWidget(
      buildScreen(
        entries: [
          _entryFor(date: today, mealType: MealType.breakfast),
          _entryFor(date: today, mealType: MealType.breakfast, name: 'Oats'),
          _entryFor(date: yesterday, mealType: MealType.lunch),
        ],
      ),
    );
    await tester.pump();

    await _scrollStatsUntilVisible(
      tester,
      find.byKey(const Key('stats_meal_breakfast_progress')),
    );

    final breakfastProgress = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('stats_meal_breakfast_progress')),
    );
    final lunchProgress = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('stats_meal_lunch_progress')),
    );

    expect(breakfastProgress.value, closeTo(1 / 7, 0.001));
    expect(lunchProgress.value, closeTo(1 / 7, 0.001));
  });
}

Future<void> _scrollStatsUntilVisible(WidgetTester tester, Finder finder) async {
  final mainScrollable = find
      .descendant(
        of: find.byKey(const Key('stats_main_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;

  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: mainScrollable,
    maxScrolls: 12,
  );
  await tester.pumpAndSettle();
}

class _SeedableLogController extends DailyLogController {
  _SeedableLogController(this._initialEntries);

  final List<MealEntry> _initialEntries;

  @override
  DailyLogState build() => DailyLogState(entries: _initialEntries);
}

const _profile = UserProfile(
  id: 'test-user',
  age: 30,
  heightCm: 175,
  weightKg: 70,
  gender: Gender.male,
  activityLevel: ActivityLevel.moderatelyActive,
  goalType: GoalType.maintain,
  calorieGoal: 2200,
  macroTargets: MacroTargets(
    proteinGrams: 126,
    carbsGrams: 260,
    fatGrams: 63,
    fiberGrams: 30,
  ),
);

DateTime _today() => normalizeLogDate(DateTime.now());

MealEntry _entryFor({
  required DateTime date,
  required MealType mealType,
  String name = 'Banana',
  int calories = 105,
  double protein = 1.3,
  double carbs = 27,
  double fat = 0.4,
  double fiber = 3.1,
}) {
  return MealEntry(
    id: '${logDateKey(date)}-${mealType.name}-$name',
    date: date,
    mealType: mealType,
    foodItem: FoodItem(
      id: name.toLowerCase(),
      name: name,
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      fiberGrams: fiber,
    ),
    quantity: 1,
  );
}
