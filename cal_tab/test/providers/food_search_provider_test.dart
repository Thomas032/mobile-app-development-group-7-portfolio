import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_search_page.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/repositories/food_search_repository.dart';
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

    test('preserves previous data in loading state during reload', () async {
      final repository = FakeFoodSearchRepository(results: [_banana]);
      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      // Settle on an initial result.
      await container
          .read(foodSearchControllerProvider.notifier)
          .search('banana');

      // Start a new search but do NOT await it — inspect the loading state.
      final searchFuture = container
          .read(foodSearchControllerProvider.notifier)
          .search('burger');

      final loading = container.read(foodSearchControllerProvider);
      expect(loading.isLoading, isTrue, reason: 'should be loading');
      expect(
        loading.value,
        isNotNull,
        reason: 'previous data must survive the loading transition',
      );
      expect(loading.value?.query, 'banana');

      await searchFuture;
    });

    test('preserves previous data when a search fails', () async {
      // Use a mutable repository so we can flip it to failing after the first
      // search settles — the provider caches the repo instance, so we must
      // mutate the same object rather than swapping to a new one.
      final repository = _TogglableRepository(results: [_banana]);
      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      // Settle on a successful first result.
      await container
          .read(foodSearchControllerProvider.notifier)
          .search('banana');

      // Make subsequent searches fail, then trigger a new search.
      repository.shouldFail = true;
      await container
          .read(foodSearchControllerProvider.notifier)
          .search('burger');

      final errorState = container.read(foodSearchControllerProvider);
      expect(errorState.hasError, isTrue);
      // Previous banana data must still be accessible so the UI can
      // display it via skipError: true instead of showing the error screen.
      expect(
        errorState.value,
        isNotNull,
        reason: 'previous data must be preserved on error',
      );
      expect(errorState.value?.query, 'banana');
    });

    test('stale search result does not overwrite a newer search', () async {
      // Simulate two concurrent searches where the first one resolves last.
      var callCount = 0;
      final firstCompleter = Completer<void>();

      final repository = FakeFoodSearchRepository(results: [_banana]);

      // Override searchFoods to delay the first call.
      final slowRepository = _SlowFirstRepository(
        delegate: repository,
        firstCallCompleter: firstCompleter,
      );

      final container = ProviderContainer(
        overrides: [
          foodSearchRepositoryProvider.overrideWith(
            (ref) async => slowRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      // Fire first search (will hang until completer resolves).
      final firstSearch = container
          .read(foodSearchControllerProvider.notifier)
          .search('first');

      // Fire second search immediately — this one completes first.
      await container
          .read(foodSearchControllerProvider.notifier)
          .search('second');

      expect(
        container.read(foodSearchControllerProvider).value?.query,
        'second',
        reason: 'second search should be current',
      );

      // Now let the first search finish.
      firstCompleter.complete();
      await firstSearch;

      // First search must NOT overwrite the already-settled second search.
      expect(
        container.read(foodSearchControllerProvider).value?.query,
        'second',
        reason: 'stale first search must not overwrite second',
      );
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

/// Wraps a [FoodSearchRepository] and delays the very first [searchFoods]
/// call until [firstCallCompleter] is completed.  Subsequent calls are
/// forwarded directly to the [delegate].
class _SlowFirstRepository implements FoodSearchRepository {
  _SlowFirstRepository({
    required this.delegate,
    required this.firstCallCompleter,
  });

  final FakeFoodSearchRepository delegate;
  final Completer<void> firstCallCompleter;
  bool _firstDone = false;

  @override
  Future<FoodSearchPage> searchFoods({
    String query = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!_firstDone) {
      _firstDone = true;
      await firstCallCompleter.future;
    }
    return delegate.searchFoods(query: query, page: page, pageSize: pageSize);
  }

  @override
  Future<FoodItem?> findFoodByBarcode(String barcode) =>
      delegate.findFoodByBarcode(barcode);
}

/// A repository that succeeds normally until [shouldFail] is set to `true`,
/// after which every [searchFoods] call throws.  Uses mutation so the same
/// instance works after the provider has cached it.
class _TogglableRepository implements FoodSearchRepository {
  _TogglableRepository({required this.results});

  final List<FoodItem> results;
  bool shouldFail = false;

  @override
  Future<FoodSearchPage> searchFoods({
    String query = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldFail) throw Exception('simulated failure');
    return FoodSearchPage(
      items: results,
      page: page,
      pageSize: pageSize,
      totalCount: results.length,
    );
  }

  @override
  Future<FoodItem?> findFoodByBarcode(String barcode) async => null;
}
