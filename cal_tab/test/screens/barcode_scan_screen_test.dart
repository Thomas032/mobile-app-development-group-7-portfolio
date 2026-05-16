import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/screens/barcode_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_food_search_repository.dart';

void main() {
  testWidgets('renders scanning, resolving, and not-found states', (
    tester,
  ) async {
    final repository = _CompleterFoodSearchRepository();

    await tester.pumpWidget(
      _scannerApp(
        repository: repository,
        scannerBuilder: _fakeScannerBuilder(),
      ),
    );

    _pressFakeButton(tester, const Key('fake_scan_button'));
    await tester.pump();

    expect(find.text('Finding product...'), findsOneWidget);

    repository.complete(null);
    await tester.pumpAndSettle();

    expect(find.text('Product not found'), findsOneWidget);
    expect(find.byKey(const Key('barcode_scan_retry_button')), findsOneWidget);
    expect(find.byKey(const Key('barcode_scan_search_button')), findsOneWidget);
  });

  testWidgets('renders permission denied state', (tester) async {
    await tester.pumpWidget(
      _scannerApp(
        repository: FakeFoodSearchRepository(),
        scannerBuilder: _fakePermissionDeniedBuilder(),
      ),
    );

    _pressFakeButton(tester, const Key('fake_denied_button'));
    await tester.pumpAndSettle();

    expect(find.text('Camera access needed'), findsOneWidget);
    expect(find.text('Camera access is required to scan.'), findsOneWidget);
    expect(
      find.byKey(const Key('barcode_scan_back_to_search_button')),
      findsOneWidget,
    );
  });

  testWidgets('successful scan navigates to food detail route', (tester) async {
    Object? foodDetailExtra;
    final repository = FakeFoodSearchRepository(
      barcodeResults: {'737628064502': _beans},
    );

    await tester.pumpWidget(
      _scannerApp(
        repository: repository,
        scannerBuilder: _fakeScannerBuilder(),
        foodDetailBuilder: (_, state) {
          foodDetailExtra = state.extra;
          return const SizedBox(key: Key('food_detail_route'));
        },
      ),
    );

    _pressFakeButton(tester, const Key('fake_scan_button'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('food_detail_route')), findsOneWidget);
    final args = foodDetailExtra as FoodDetailRouteArgs;
    expect(args.foodItem, _beans);
    expect(args.target.mealType, MealType.lunch);
  });
}

void _pressFakeButton(WidgetTester tester, Key key) {
  final button = tester.widget<ElevatedButton>(find.byKey(key));
  button.onPressed?.call();
}

Widget _scannerApp({
  required FakeFoodSearchRepository repository,
  required BarcodeScannerViewBuilder scannerBuilder,
  GoRouterWidgetBuilder? foodDetailBuilder,
}) {
  return ProviderScope(
    overrides: [
      foodSearchRepositoryProvider.overrideWith((ref) async => repository),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/scan-barcode',
        routes: [
          GoRoute(
            path: '/scan-barcode',
            name: 'scan-barcode',
            builder: (_, __) => BarcodeScanScreen(
              target: FoodLogTarget(
                date: DateTime(2026, 5, 16),
                mealType: MealType.lunch,
              ),
              scannerBuilder: scannerBuilder,
            ),
          ),
          GoRoute(
            path: '/add-food',
            name: 'add-food',
            builder: (_, __) => const SizedBox(key: Key('add_food_route')),
          ),
          GoRoute(
            path: '/food-detail',
            name: 'food-detail',
            builder:
                foodDetailBuilder ??
                (_, __) => const SizedBox(key: Key('food_detail_route')),
          ),
        ],
      ),
    ),
  );
}

BarcodeScannerViewBuilder _fakeScannerBuilder() {
  return (context, callbacks) {
    return Center(
      child: ElevatedButton(
        key: const Key('fake_scan_button'),
        onPressed: () => callbacks.onBarcodeDetected('737628064502'),
        child: const Text('Scan'),
      ),
    );
  };
}

BarcodeScannerViewBuilder _fakePermissionDeniedBuilder() {
  return (context, callbacks) {
    return Center(
      child: ElevatedButton(
        key: const Key('fake_denied_button'),
        onPressed: () =>
            callbacks.onCameraDenied('Camera access is required to scan.'),
        child: const Text('Deny'),
      ),
    );
  };
}

class _CompleterFoodSearchRepository extends FakeFoodSearchRepository {
  final _completer = Completer<FoodItem?>();

  void complete(FoodItem? foodItem) => _completer.complete(foodItem);

  @override
  Future<FoodItem?> findFoodByBarcode(String barcode) async {
    lastBarcode = barcode;
    barcodeLookupCount += 1;
    return _completer.future;
  }
}

const _beans = FoodItem(
  id: '737628064502',
  name: 'Black Beans',
  calories: 90,
  proteinGrams: 6,
  carbsGrams: 16,
  fatGrams: 0.5,
  fiberGrams: 5,
);
