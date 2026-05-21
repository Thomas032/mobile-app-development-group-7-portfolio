import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_food_search_repository.dart';

void main() {
  group('FoodSearchController', () {
    test('searches foods through the repository', () async {
      final repository = FakeFoodSearchRepository(results: [_banana]);
      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(foodSearchControllerProvider.notifier)
          .search(' banana ');

      expect(repository.lastQuery, 'banana');
      expect(container.read(foodSearchControllerProvider).value?.items, [
        _banana,
      ]);
    });

    test('loads default products when query is empty', () async {
      final repository = FakeFoodSearchRepository(results: [_banana]);
      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(foodSearchControllerProvider.notifier).search('');

      expect(container.read(foodSearchControllerProvider).value?.items, [
        _banana,
      ]);
      expect(repository.lastQuery, '');
    });

    test('appends the next page when loading more results', () async {
      final repository = FakeFoodSearchRepository(
        results: [_banana],
        totalCount: 60,
      );
      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(foodSearchControllerProvider.notifier)
          .search('banana');
      await container.read(foodSearchControllerProvider.notifier).loadMore();

      final state = container.read(foodSearchControllerProvider).value;
      expect(repository.lastPage, 2);
      expect(state?.items, [_banana, _banana]);
      expect(state?.hasMore, isTrue);
    });
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
