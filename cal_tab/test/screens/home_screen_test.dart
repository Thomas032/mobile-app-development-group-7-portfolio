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
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:cal_tab/widgets/log_calendar.dart';
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
  Widget buildScreen({
    List<MealEntry> entries = const [],
    DateTime? selectedDate,
    void Function(Object?)? onAddFoodExtra,
  }) {
    return ProviderScope(
      overrides: [
        dailyLogControllerProvider.overrideWith(
          () => _SeedableLogController(entries),
        ),
        if (selectedDate != null)
          selectedLogDateProvider.overrideWith(
            () => _SeedableSelectedLogDateController(selectedDate),
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
              builder: (_, state) {
                onAddFoodExtra?.call(state.extra);
                return const SizedBox(key: Key('add_food_route'));
              },
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

  testWidgets('date badge opens date picker and jumps to selected date', (
    tester,
  ) async {
    final targetDate = _datePickerTargetDate();

    await tester.pumpWidget(
      buildScreen(
        entries: [_entryFor(date: targetDate, name: 'Pear', calories: 321)],
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('date_badge')));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(find.text('${targetDate.day}').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    expect(find.text('321'), findsOneWidget);
  });

  testWidgets('renders at least two ListViews (calendar + main scroll)', (
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

  testWidgets('switches selected calendar date and filters logged meals', (
    tester,
  ) async {
    final yesterday = _today().subtract(const Duration(days: 1));

    await tester.pumpWidget(
      buildScreen(
        entries: [_entryFor(date: yesterday, name: 'Apple')],
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(Key('calendar_day_${logDateKey(yesterday)}')));
    await tester.pump();
    expect(find.text('105'), findsOneWidget);
  });

  testWidgets('calendar colors days by calorie goal status', (tester) async {
    final yesterday = _today().subtract(const Duration(days: 1));
    final twoDaysAgo = _today().subtract(const Duration(days: 2));

    await tester.pumpWidget(
      buildScreen(
        entries: [
          _entryFor(date: yesterday, calories: 105),
          _entryFor(date: twoDaysAgo, calories: _profile.calorieGoal),
        ],
      ),
    );
    await tester.pump();

    expect(_calendarDayColor(tester, twoDaysAgo), const Color(0xFF34C759));
    expect(_calendarDayColor(tester, yesterday), const Color(0xFFFF9500));
  });

  testWidgets('horizontal calendar recenters around selected jump date', (
    tester,
  ) async {
    final jumpDate = _today().subtract(const Duration(days: 60));

    await tester.pumpWidget(buildScreen(selectedDate: jumpDate));
    await tester.pump();

    expect(
      find.byKey(Key('calendar_day_${logDateKey(jumpDate)}')),
      findsOneWidget,
    );
  });

  testWidgets('horizontal calendar syncs after selected date changes', (
    tester,
  ) async {
    final today = _today();
    final jumpDate = today.subtract(const Duration(days: 60));

    Widget buildCalendar(DateTime selectedDate) {
      return MaterialApp(
        home: LogCalendar(
          logState: const DailyLogState(),
          profile: _profile,
          selectedDate: selectedDate,
          today: today,
          onDateSelected: (_) {},
        ),
      );
    }

    await tester.pumpWidget(buildCalendar(today));
    await tester.pump();
    expect(
      find.byKey(Key('calendar_day_${logDateKey(today)}')),
      findsOneWidget,
    );

    await tester.pumpWidget(buildCalendar(jumpDate));
    await tester.pump();

    expect(
      find.byKey(Key('calendar_day_${logDateKey(jumpDate)}')),
      findsOneWidget,
    );
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

  testWidgets('meal add button carries selected date and meal type', (
    tester,
  ) async {
    final yesterday = _today().subtract(const Duration(days: 1));
    FoodLogTarget? openedTarget;

    await tester.pumpWidget(
      buildScreen(
        onAddFoodExtra: (extra) => openedTarget = extra as FoodLogTarget?,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(Key('calendar_day_${logDateKey(yesterday)}')));
    await tester.pump();
    await _scrollHomeUntilVisible(tester, find.text('Breakfast'));
    await tester.tap(find.byKey(const Key('add_food_breakfast_button')));
    await tester.pumpAndSettle();

    expect(openedTarget?.date, yesterday);
    expect(openedTarget?.mealType, MealType.breakfast);
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

class _SeedableSelectedLogDateController extends SelectedLogDateController {
  _SeedableSelectedLogDateController(this._selectedDate);

  final DateTime _selectedDate;

  @override
  DateTime build() => normalizeLogDate(_selectedDate);
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
  date: _today(),
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

DateTime _today() => normalizeLogDate(DateTime.now());

DateTime _datePickerTargetDate() {
  final today = _today();
  final targetDay = today.day == 1 ? 2 : 1;
  return DateTime(today.year, today.month, targetDay);
}

MealEntry _entryFor({
  required DateTime date,
  String name = 'Banana',
  int calories = 105,
}) {
  return MealEntry(
    id: '${logDateKey(date)}-$name',
    date: date,
    mealType: MealType.breakfast,
    foodItem: FoodItem(
      id: name.toLowerCase(),
      name: name,
      calories: calories,
      proteinGrams: 1.3,
      carbsGrams: 27,
      fatGrams: 0.4,
      fiberGrams: 3.1,
    ),
    quantity: 1,
  );
}

Color? _calendarDayColor(WidgetTester tester, DateTime date) {
  final ink = tester.widget<Ink>(
    find.byKey(Key('calendar_day_status_${logDateKey(date)}')),
  );
  final decoration = ink.decoration as BoxDecoration?;
  return decoration?.color;
}
