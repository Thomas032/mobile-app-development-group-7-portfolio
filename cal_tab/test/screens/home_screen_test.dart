import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _scrollHomeUntilVisible(WidgetTester tester, Finder finder) async {
  final mainScrollable = find
      .descendant(
        of: find.byKey(const Key('home_main_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;

  await tester.scrollUntilVisible(finder, 250, scrollable: mainScrollable);
  await tester.pumpAndSettle();
}

void main() {
  Widget buildScreen({List<MealEntry> entries = const []}) {
    return ProviderScope(
      overrides: [
        dailyLogControllerProvider.overrideWith(
          () => _SeedableLogController(entries),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(body: HomeScreen(profile: _profile)),
            ),
            GoRoute(
              path: '/add-food',
              name: 'add-food',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('renders top bar with CalTab title, streak and date badges', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('CalTab'), findsOneWidget);
    expect(find.byKey(const Key('streak_badge')), findsOneWidget);
    expect(find.byKey(const Key('date_badge')), findsOneWidget);
  });

  testWidgets('renders at least two ListViews (day strip + main scroll)', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(
      tester.widgetList<ListView>(find.byType(ListView)).length,
      greaterThanOrEqualTo(2),
    );
  });

  testWidgets('shows 0 consumed calories and 0% when no food is logged', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.byKey(const Key('calories_consumed_value')), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('0%'), findsWidgets);
  });

  testWidgets('shows correct consumed calories after logging food', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(entries: [_breakfastEntry]));
    await tester.pump();

    expect(find.text('210'), findsOneWidget); // 2 × 105 kcal banana
  });

  testWidgets('renders Nutrients section label', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Nutrients'), findsOneWidget);
  });

  testWidgets('renders all four macro tiles', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    expect(find.text('Fiber'), findsOneWidget);
  });

  testWidgets('renders Meals section label after scrolling', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await _scrollHomeUntilVisible(tester, find.text('Meals'));

    expect(find.text('Meals'), findsOneWidget);
  });

  testWidgets('all meal types are present in the accordion', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await _scrollHomeUntilVisible(tester, find.text('Second Dinner'));

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Snack'), findsNWidgets(2));
    expect(find.text('Lunch'), findsWidgets);
    expect(find.text('Dinner'), findsWidgets);
    expect(find.text('Second Dinner'), findsWidgets);
  });

  testWidgets('each meal type has an add-food button', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    await _scrollHomeUntilVisible(tester, find.text('Second Dinner'));

    expect(
      find.byIcon(Icons.add_rounded),
      findsNWidgets(MealType.values.length),
    );
  });

  testWidgets('logged food name appears under its meal type', (tester) async {
    await tester.pumpWidget(buildScreen(entries: [_breakfastEntry]));
    await tester.pump();

    await _scrollHomeUntilVisible(tester, find.text('Banana'));

    expect(find.text('Banana'), findsOneWidget);
  });
}

// ──────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────

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

final _breakfastEntry = MealEntry(
  id: 'e1',
  date: DateTime.now(),
  mealType: MealType.breakfast,
  foodItem: const FoodItem(
    id: 'banana',
    name: 'Banana',
    calories: 105,
    proteinGrams: 1.3,
    carbsGrams: 27,
    fatGrams: 0.4,
    fiberGrams: 3.1,
  ),
  quantity: 2,
);
