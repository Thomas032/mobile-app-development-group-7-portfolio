import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/food_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_meal_log_repository.dart';

void main() {
  testWidgets('adds selected search food to the daily log', (tester) async {
    final repository = FakeMealLogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealLogRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: const MaterialApp(
          home: FoodDetailScreen(foodItem: _banana),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('detail_quantity_field')), '2');
    await tester.tap(find.byKey(const Key('add_search_food_button')));
    await tester.pumpAndSettle();

    expect(repository.entries, hasLength(1));
    expect(repository.entries.single.foodItem.name, 'Banana');
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
