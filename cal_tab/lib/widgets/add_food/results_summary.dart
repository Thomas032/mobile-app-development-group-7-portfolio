import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:flutter/material.dart';

class ResultsSummary extends StatelessWidget {
  const ResultsSummary(this.state, {super.key})
    : title = null,
      subtitle = null;

  const ResultsSummary.loading({super.key})
    : state = null,
      title = 'Loading products',
      subtitle = 'Fetching Open Food Facts';

  const ResultsSummary.error({super.key})
    : state = null,
      title = 'Could not load products',
      subtitle = 'Check your connection and try again';

  final FoodSearchState? state;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final searchState = state;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final resolvedTitle =
        title ??
        (searchState!.isBrowsing
            ? 'Most common items'
            : 'Results for "${searchState.query}"');
    final shownCount = searchState?.items.length ?? 0;
    final totalCount = searchState?.totalCount ?? 0;
    final resolvedSubtitle =
        subtitle ??
        '$shownCount shown${totalCount > 0 ? ' of $totalCount' : ''}';
    final showSubtitle = searchState?.isBrowsing == false || title != null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showSubtitle) ...[
                const SizedBox(height: 2),
                Text(
                  resolvedSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
