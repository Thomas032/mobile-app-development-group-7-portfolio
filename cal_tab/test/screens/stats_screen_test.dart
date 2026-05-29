import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/body_progress_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen({
    List<MealEntry> entries = const [],
    List<BodyProgressEntry> bodyProgressEntries = const [],
  }) {
    return ProviderScope(
      overrides: [
        dailyLogControllerProvider.overrideWith(
          () => _SeedableLogController(entries),
        ),
        bodyProgressControllerProvider.overrideWith(
          () => _SeedableBodyProgressController(bodyProgressEntries),
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
    await _scrollStatsUntilVisible(
      tester,
      find.text('Macro averages'),
      tabKey: 'nutrition_stats_scroll',
    );

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

    await _scrollStatsUntilVisible(
      tester,
      find.text('Macro averages'),
      tabKey: 'nutrition_stats_scroll',
    );

    expect(find.text('Across 2 logged days'), findsOneWidget);
    expect(find.text('75/126g'), findsOneWidget);
    expect(find.text('195/260g'), findsOneWidget);
    expect(find.text('45/63g'), findsOneWidget);

    // Fiber lives in the collapsible micronutrient section; expand it and
    // assert on the MicroAverageRow format (no target shown).
    await tester.tap(find.text('Micronutrients'));
    await tester.pumpAndSettle();
    expect(find.text('22.5g'), findsOneWidget); // (30 + 15) / 2 days logged
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
      tabKey: 'nutrition_stats_scroll',
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

  testWidgets('renders current weight and progress history entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        bodyProgressEntries: [
          BodyProgressEntry(
            id: 'progress-2',
            date: DateTime(2026, 5, 21),
            weightKg: 69.8,
            waistCm: 80,
            note: 'Nice drop',
          ),
          BodyProgressEntry(
            id: 'progress-1',
            date: DateTime(2026, 5, 18),
            weightKg: 70.4,
          ),
        ],
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();

    await _scrollStatsUntilVisible(
      tester,
      find.byKey(const Key('body_progress_current_weight')),
      tabKey: 'weight_stats_scroll',
    );

    expect(find.text('Current weight'), findsOneWidget);
    expect(find.text('69.8'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Nice drop'), findsOneWidget);
  });
}

Future<void> _scrollStatsUntilVisible(
  WidgetTester tester,
  Finder finder, {
  String tabKey = 'nutrition_stats_scroll',
}) async {
  final mainScrollable = find
      .descendant(
        of: find.byKey(Key(tabKey)),
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

class _SeedableBodyProgressController extends BodyProgressController {
  _SeedableBodyProgressController(this._initialEntries);

  final List<BodyProgressEntry> _initialEntries;

  @override
  Future<List<BodyProgressEntry>> build() async => _initialEntries;
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
