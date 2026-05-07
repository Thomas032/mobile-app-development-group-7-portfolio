import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/food_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_meal_log_repository.dart';

void main() {
  testWidgets('adds selected search food to the daily log', (tester) async {
    final repository = FakeMealLogRepository();
    final targetDate = normalizeLogDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: MaterialApp(
          home: FoodDetailScreen(
            foodItem: _banana,
            target: FoodLogTarget(date: targetDate, mealType: MealType.lunch),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('detail_quantity_field')),
      '200',
    );
    expect(find.byKey(const Key('detail_meal_type_field')), findsNothing);
    expect(find.byKey(const Key('detail_meal_target')), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('add_search_food_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add_search_food_button')));
    await tester.pumpAndSettle();

    expect(repository.entries, hasLength(1));
    expect(repository.entries.single.foodItem.name, 'Banana');
    expect(repository.entries.single.quantity, 2);
    expect(normalizeLogDate(repository.entries.single.date), targetDate);
    expect(repository.entries.single.mealType, MealType.lunch);
    expect(repository.entries.single.calories, 210);
  });
}

const _banana = FoodItem(
  id: 'banana',
  name: 'Banana',
  calories: 105,
  proteinGrams: 1.3,
  carbsGrams: 27,
  fatGrams: 0.4,
  fiberGrams: 3.1,
);
