import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/widgets/add_food/empty_results_state.dart';
import 'package:cal_tab/widgets/add_food/food_search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodResultsList extends ConsumerStatefulWidget {
  const FoodResultsList({
    super.key,
    required this.state,
    required this.target,
    required this.onLoadMore,
  });

  final FoodSearchState state;
  final FoodLogTarget target;
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
    final recents = _matchingRecents(
      ref.watch(recentFoodItemsProvider),
      state.query,
    );
    final recentIds = recents.map((item) => item.id).toSet();
    final apiItems = [
      for (final item in state.items)
        if (!recentIds.contains(item.id)) item,
    ];

    if (recents.isEmpty && apiItems.isEmpty) {
      return const EmptyResultsState();
    }

    final showApiHeader = recents.isNotEmpty && apiItems.isNotEmpty;
    final apiHeaderCount = showApiHeader ? 1 : 0;
    final recentHeaderCount = recents.isNotEmpty ? 1 : 0;
    final totalCount =
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

        if (recentHeaderCount == 1) {
          if (cursor == 0) {
            return const _SectionHeader(label: 'Recent');
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
            return const _SectionHeader(label: 'All results');
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

        return _LoadMoreFooter(
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const SizedBox(height: 8);
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: onLoadMore,
        icon: const Icon(Icons.expand_more),
        label: const Text('Load more'),
      ),
    );
  }
}
