import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/custom_meal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_custom_meal_repository.dart';

void main() {
  testWidgets('saves a custom meal and returns it to the caller', (
    tester,
  ) async {
    _useTallViewport(tester);
    final repository = FakeCustomMealRepository();
    FoodItem? savedMeal;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  savedMeal = await context.pushNamed<FoodItem>('custom-meal');
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/custom-meal',
          name: 'custom-meal',
          builder: (_, _) => const CustomMealScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customMealRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('custom_meal_name_field')),
      'Homemade granola',
    );
    await tester.enterText(
      find.byKey(const Key('custom_meal_calories_field')),
      '450',
    );
    await tester.enterText(
      find.byKey(const Key('custom_meal_protein_field')),
      '12',
    );
    await tester.enterText(
      find.byKey(const Key('custom_meal_carbs_field')),
      '60',
    );
    await tester.enterText(
      find.byKey(const Key('custom_meal_fat_field')),
      '16',
    );
    await tester.enterText(
      find.byKey(const Key('custom_meal_fiber_field')),
      '9',
    );

    await tester.ensureVisible(
      find.byKey(const Key('save_custom_meal_button')),
    );
    await tester.tap(find.byKey(const Key('save_custom_meal_button')));
    await tester.pumpAndSettle();

    expect(repository.meals, hasLength(1));
    expect(repository.meals.single.name, 'Homemade granola');
    expect(savedMeal?.name, 'Homemade granola');
    expect(savedMeal?.calories, 450);
  });
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
