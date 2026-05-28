import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/custom_meals_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/widgets/add_food/empty_results_state.dart';
import 'package:cal_tab/widgets/add_food/food_results_load_more_footer.dart';
import 'package:cal_tab/widgets/add_food/food_results_section_header.dart';
import 'package:cal_tab/widgets/add_food/food_search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodResultsList extends ConsumerStatefulWidget {
  const FoodResultsList({
    super.key,
    required this.state,
    required this.target,
    required this.customMeals,
    required this.onLoadMore,
  });

  final FoodSearchState state;
  final FoodLogTarget target;
  final List<FoodItem> customMeals;
  final Future<void> Function() onLoadMore;

  @override
  ConsumerState<FoodResultsList> createState() => _FoodResultsListState();
}

class _FoodResultsListState extends ConsumerState<FoodResultsList> {
  final _scrollController = ScrollController();
  bool _loadMoreInFlight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void didUpdateWidget(covariant FoodResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.items.length != widget.state.items.length ||
        oldWidget.state.isLoadingMore != widget.state.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final customMeals = _matchingRecents(widget.customMeals, state.query);
    final recents = _matchingRecents(
      ref.watch(recentFoodItemsProvider),
      state.query,
    );
    final blockedIds = {
      ...customMeals.map((item) => item.id),
      ...recents.map((item) => item.id),
    };
    final apiItems = [
      for (final item in state.items)
        if (!blockedIds.contains(item.id)) item,
    ];

    if (customMeals.isEmpty && recents.isEmpty && apiItems.isEmpty) {
      return const EmptyResultsState();
    }

    final customHeaderCount = customMeals.isNotEmpty ? 1 : 0;
    final recentHeaderCount = recents.isNotEmpty ? 1 : 0;
    final apiHeaderCount = apiItems.isNotEmpty ? 1 : 0;
    final totalCount =
        customHeaderCount +
        customMeals.length +
        recentHeaderCount +
        recents.length +
        apiHeaderCount +
        apiItems.length +
        1;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      cacheExtent: 520,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        var cursor = index;

        if (customHeaderCount == 1) {
          if (cursor == 0) {
            return const FoodResultsSectionHeader(label: 'Custom meals');
          }
          cursor -= 1;

          if (cursor < customMeals.length) {
            final meal = customMeals[cursor];
            return _DismissibleCustomMealTile(
              meal: meal,
              target: widget.target,
              isFirst: cursor == 0,
              isLast: cursor == customMeals.length - 1,
            );
          }
          cursor -= customMeals.length;
        }

        if (recentHeaderCount == 1) {
          if (cursor == 0) {
            return const FoodResultsSectionHeader(label: 'Recent');
          }
          cursor -= 1;

          if (cursor < recents.length) {
            return FoodSearchResultTile(
              foodItem: recents[cursor],
              target: widget.target,
              isFirst: cursor == 0,
              isLast: cursor == recents.length - 1,
            );
          }
          cursor -= recents.length;
        }

        if (apiHeaderCount == 1) {
          if (cursor == 0) {
            return const FoodResultsSectionHeader(label: 'All results');
          }
          cursor -= 1;
        }

        if (cursor < apiItems.length) {
          return FoodSearchResultTile(
            foodItem: apiItems[cursor],
            target: widget.target,
            isFirst: cursor == 0,
            isLast: cursor == apiItems.length - 1,
          );
        }

        return FoodResultsLoadMoreFooter(
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore || _loadMoreInFlight,
          onLoadMore: _requestLoadMore,
        );
      },
    );
  }

  List<FoodItem> _matchingRecents(List<FoodItem> recents, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return recents;
    return [
      for (final item in recents)
        if (item.name.toLowerCase().contains(trimmed)) item,
    ];
  }

  void _maybeLoadMore() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 420) {
      _requestLoadMore();
    }
  }

  Future<void> _requestLoadMore() async {
    if (_loadMoreInFlight ||
        !widget.state.hasMore ||
        widget.state.isLoadingMore) {
      return;
    }

    setState(() => _loadMoreInFlight = true);
    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() => _loadMoreInFlight = false);
      }
    }
  }
}

class _DismissibleCustomMealTile extends ConsumerWidget {
  const _DismissibleCustomMealTile({
    required this.meal,
    required this.target,
    required this.isFirst,
    required this.isLast,
  });

  final FoodItem meal;
  final FoodLogTarget target;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('custom-meal-${meal.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _handleDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      child: FoodSearchResultTile(
        foodItem: meal,
        target: target,
        isFirst: isFirst,
        isLast: isLast,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete custom meal?'),
          content: Text(
            'Remove "${meal.name}" from your saved meals? Past log entries '
            'that already used it will stay in your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(customMealsControllerProvider.notifier);
    final removed = meal;

    await controller.removeMeal(removed.id);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed "${removed.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => controller.restoreMeal(removed),
        ),
      ),
    );
  }
}
