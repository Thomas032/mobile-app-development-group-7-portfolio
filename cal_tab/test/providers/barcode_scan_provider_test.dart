import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/barcode_scan_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_food_search_repository.dart';

void main() {
  group('BarcodeScanController', () {
    test('resolves a detected barcode through the repository', () async {
      final repository = FakeFoodSearchRepository(
        barcodeResults: {'737628064502': _beans},
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container
          .read(barcodeScanControllerProvider.notifier)
          .resolveBarcode(' 737628064502 ');

      final state = container.read(barcodeScanControllerProvider);
      expect(repository.lastBarcode, '737628064502');
      expect(state.status, BarcodeScanStatus.productFound);
      expect(state.foodItem, _beans);
    });

    test('ignores duplicate frames while resolving', () async {
      final repository = _CompleterFoodSearchRepository();
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final controller = container.read(barcodeScanControllerProvider.notifier);
      final firstLookup = controller.resolveBarcode('737628064502');
      await Future<void>.delayed(Duration.zero);

      await controller.resolveBarcode('737628064502');
      repository.complete(_beans);
      await firstLookup;

      expect(repository.barcodeLookupCount, 1);
      expect(
        container.read(barcodeScanControllerProvider).status,
        BarcodeScanStatus.productFound,
      );
    });

    test('surfaces product not found state', () async {
      final repository = FakeFoodSearchRepository(
        barcodeResults: {'missing': null},
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container
          .read(barcodeScanControllerProvider.notifier)
          .resolveBarcode('missing');

      final state = container.read(barcodeScanControllerProvider);
      expect(state.status, BarcodeScanStatus.productNotFound);
      expect(state.barcode, 'missing');
    });

    test('surfaces repository errors as retryable error state', () async {
      final repository = FakeFoodSearchRepository(
        barcodeError: Exception('network failed'),
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container
          .read(barcodeScanControllerProvider.notifier)
          .resolveBarcode('737628064502');

      final state = container.read(barcodeScanControllerProvider);
      expect(state.status, BarcodeScanStatus.error);
      expect(state.message, contains('Could not load product'));
    });
  });
}

ProviderContainer _containerWith(FakeFoodSearchRepository repository) {
  return ProviderContainer(
    overrides: [
      foodSearchRepositoryProvider.overrideWith((ref) async => repository),
    ],
  );
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
