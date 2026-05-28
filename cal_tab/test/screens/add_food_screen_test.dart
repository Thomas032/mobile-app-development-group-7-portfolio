import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/add_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_custom_meal_repository.dart';
import '../fakes/fake_food_search_repository.dart';

void main() {
  testWidgets('barcode icon opens scan route with current target', (
    tester,
  ) async {
    Object? openedExtra;
    final targetDate = DateTime(2026, 5, 16);
    final target = FoodLogTarget(date: targetDate, mealType: MealType.dinner);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodSearchRepositoryProvider.overrideWith(
            (ref) async => FakeFoodSearchRepository(),
          ),
          customMealRepositoryProvider.overrideWith(
            (ref) async => FakeCustomMealRepository(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/add-food',
            routes: [
              GoRoute(
                path: '/add-food',
                name: 'add-food',
                builder: (_, __) => AddFoodScreen(target: target),
              ),
              GoRoute(
                path: '/scan-barcode',
                name: 'scan-barcode',
                builder: (_, state) {
                  openedExtra = state.extra;
                  return const SizedBox(key: Key('scan_barcode_route'));
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Barcode scanner'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scan_barcode_route')), findsOneWidget);
    final openedTarget = openedExtra as FoodLogTarget;
    expect(openedTarget.date, targetDate);
    expect(openedTarget.mealType, MealType.dinner);
  });

  testWidgets('shows saved custom meals in the add-food results', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodSearchRepositoryProvider.overrideWith(
            (ref) async => FakeFoodSearchRepository(),
          ),
          customMealRepositoryProvider.overrideWith(
            (ref) async => FakeCustomMealRepository(
              initialMeals: const [_savedCustomMeal],
            ),
          ),
        ],
        child: const MaterialApp(home: AddFoodScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create_custom_meal_button')), findsOneWidget);
    expect(find.text('CUSTOM MEALS'), findsOneWidget);
    expect(find.text('Protein oats'), findsOneWidget);
  });
}

const _savedCustomMeal = FoodItem(
  id: 'custom-oats',
  name: 'Protein oats',
  calories: 360,
  proteinGrams: 21,
  carbsGrams: 48,
  fatGrams: 9,
  fiberGrams: 7,
);
