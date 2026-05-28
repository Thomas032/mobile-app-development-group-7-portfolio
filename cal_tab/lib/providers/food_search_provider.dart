import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_search_page.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodSearchState {
  const FoodSearchState({
    required this.query,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    this.isLoadingMore = false,
  });

  final String query;
  final List<FoodItem> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool isLoadingMore;

  bool get isBrowsing => query.isEmpty;
  bool get hasMore => page * pageSize < totalCount;

  FoodSearchState copyWith({
    String? query,
    List<FoodItem>? items,
    int? page,
    int? pageSize,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return FoodSearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FoodSearchController extends AsyncNotifier<FoodSearchState> {
  static const int _pageSize = 20;
  int _searchGeneration = 0;

  @override
  Future<FoodSearchState> build() {
    return _fetchFirstPage('');
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    final generation = ++_searchGeneration;
    // Carry previous data into the loading state so the list stays visible
    // while the request is in-flight instead of switching to a spinner.
    state = const AsyncLoading<FoodSearchState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetchFirstPage(trimmedQuery));
    // Discard results that belong to a superseded search.
    if (_searchGeneration == generation) {
      // On transient failure, preserve previous data so the UI never blanks out.
      // The error widget is only shown on first-load failures (no previous data).
      state = switch (result) {
        AsyncError() => result.copyWithPrevious(state),
        _ => result,
      };
    }
  }

  Future<void> browseAll() => search('');

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final repository = await ref.read(foodSearchRepositoryProvider.future);
      final nextPage = await repository.searchFoods(
        query: current.query,
        page: current.page + 1,
        pageSize: current.pageSize,
      );

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...nextPage.items],
          page: nextPage.page,
          pageSize: nextPage.pageSize,
          totalCount: nextPage.totalCount,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<FoodSearchState> _fetchFirstPage(String query) async {
    final repository = await ref.read(foodSearchRepositoryProvider.future);
    final page = await repository.searchFoods(
      query: query,
      page: 1,
      pageSize: _pageSize,
    );
    return _stateFromPage(query, page);
  }

  FoodSearchState _stateFromPage(String query, FoodSearchPage page) {
    return FoodSearchState(
      query: query,
      items: page.items,
      page: page.page,
      pageSize: page.pageSize,
      totalCount: page.totalCount,
    );
  }
}

final foodSearchControllerProvider =
    AsyncNotifierProvider<FoodSearchController, FoodSearchState>(
      FoodSearchController.new,
    );
