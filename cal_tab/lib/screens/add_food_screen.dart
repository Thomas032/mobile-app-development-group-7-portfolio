import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/screens/barcode_scanner_screen.dart';
import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key, this.target});

  final FoodLogTarget? target;

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchControllerProvider);
    final selectedDate = ref.watch(selectedLogDateProvider);
    final target = (widget.target ?? FoodLogTarget(date: selectedDate))
        .normalized();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 14, 10),
              child: _SearchCommandBar(
                controller: _searchController,
                onChanged: _queueSearch,
                onSubmitted: (_) => _runSearch(force: true),
                onBarcode: () => _handleBarcode(target),
                onSnap2Cal: () => _handleSnap2Cal(target),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: searchState.when(
                data: _ResultsSummary.new,
                loading: () => const _ResultsSummary.loading(),
                error: (_, __) => const _ResultsSummary.error(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: searchState.when(
                data: (state) => _FoodResultsList(
                  state: state,
                  target: target,
                  onLoadMore: () async => ref
                      .read(foodSearchControllerProvider.notifier)
                      .loadMore(),
                ),
                loading: _LoadingProductList.new,
                error: (error, stackTrace) =>
                    _SearchErrorState(onRetry: () => _runSearch(force: true)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _queueSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      final query = value.trim();
      if (query.isNotEmpty && query.length < 2) {
        return;
      }
      _runSearch();
    });
  }

  Future<void> _runSearch({bool force = false}) async {
    final query = _searchController.text.trim();
    if (!force && query == _lastQuery) {
      return;
    }

    _lastQuery = query;
    await ref.read(foodSearchControllerProvider.notifier).search(query);
  }

  Future<void> _handleBarcode(FoodLogTarget target) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    final code = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || code == null || code.isEmpty) {
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _ProgressDialog(message: 'Looking up product…'),
      ),
    );

    try {
      final repo = await ref.read(foodSearchRepositoryProvider.future);
      final item = await repo.fetchByBarcode(code);
      if (!mounted) return;
      navigator.pop();

      if (item == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('No product found for $code.')),
        );
        return;
      }

      router.pushNamed(
        'food-detail',
        extra: FoodDetailRouteArgs(foodItem: item, target: target),
      );
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Barcode lookup failed: $e')),
      );
    }
  }

  Future<void> _handleSnap2Cal(FoodLogTarget target) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final apiKey = ref.read(aiApiKeyControllerProvider).value;
    if (apiKey == null || apiKey.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Add a Gemini API key in Settings to use Snap2Cal.',
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? file;
    try {
      file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        imageQuality: 80,
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Camera unavailable: $e')));
      return;
    }
    if (!mounted || file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    final navigator = Navigator.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const _ProgressDialog(message: 'Analyzing photo with Gemini…'),
      ),
    );

    try {
      final service = GeminiAiService(apiKey: apiKey);
      final estimate = await service.estimateFoodFromImage(bytes);
      if (!mounted) return;
      navigator.pop();

      final item = FoodItem(
        id: 'snap2cal-${DateTime.now().millisecondsSinceEpoch}',
        name: estimate.name,
        calories: estimate.caloriesPer100g,
        proteinGrams: estimate.proteinPer100g,
        carbsGrams: estimate.carbsPer100g,
        fatGrams: estimate.fatPer100g,
        fiberGrams: estimate.fiberPer100g,
      );

      router.pushNamed(
        'food-detail',
        extra: FoodDetailRouteArgs(foodItem: item, target: target),
      );
    } on AiServiceException catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Snap2Cal failed: $e')),
      );
    }
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _SearchCommandBar extends StatelessWidget {
  const _SearchCommandBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onBarcode,
    required this.onSnap2Cal,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBarcode;
  final VoidCallback onSnap2Cal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('food_search_field'),
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      hintText: 'Search everything',
                      contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    ),
                    minLines: 1,
                    textInputAction: TextInputAction.search,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                ),
                _CommandIconButton(
                  tooltip: 'Barcode scanner',
                  icon: Icons.qr_code_scanner,
                  onPressed: onBarcode,
                ),
                _CommandIconButton(
                  tooltip: 'Snap2Cal',
                  icon: Icons.photo_camera_outlined,
                  onPressed: onSnap2Cal,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommandIconButton extends StatelessWidget {
  const _CommandIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      color: color,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
        minimumSize: const Size.square(40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon),
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  const _ResultsSummary(this.state) : title = null, subtitle = null;

  const _ResultsSummary.loading()
    : state = null,
      title = 'Loading products',
      subtitle = 'Fetching Open Food Facts';

  const _ResultsSummary.error()
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

class _FoodResultsList extends StatefulWidget {
  const _FoodResultsList({
    required this.state,
    required this.target,
    required this.onLoadMore,
  });

  final FoodSearchState state;
  final FoodLogTarget target;
  final Future<void> Function() onLoadMore;

  @override
  State<_FoodResultsList> createState() => _FoodResultsListState();
}

class _FoodResultsListState extends State<_FoodResultsList> {
  final _scrollController = ScrollController();
  bool _loadMoreInFlight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void didUpdateWidget(covariant _FoodResultsList oldWidget) {
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
    if (state.items.isEmpty) {
      return const _EmptyResultsState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      cacheExtent: 520,
      itemCount: state.items.length + 1,
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return _LoadMoreFooter(
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore || _loadMoreInFlight,
            onLoadMore: _requestLoadMore,
          );
        }

        return _FoodSearchResultTile(
          foodItem: state.items[index],
          target: widget.target,
          isFirst: index == 0,
          isLast: index == state.items.length - 1,
        );
      },
    );
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

class _FoodSearchResultTile extends StatelessWidget {
  const _FoodSearchResultTile({
    required this.foodItem,
    required this.target,
    required this.isFirst,
    required this.isLast,
  });

  final FoodItem foodItem;
  final FoodLogTarget target;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          'food-detail',
          extra: FoodDetailRouteArgs(foodItem: foodItem, target: target),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : colors.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: Row(
              children: [
                _FoodThumbnail(imageUrl: foodItem.imageUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        foodItem.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${foodItem.calories} kcal /100g',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  tooltip: 'Add ${foodItem.name}',
                  onPressed: () => context.pushNamed(
                    'food-detail',
                    extra: FoodDetailRouteArgs(
                      foodItem: foodItem,
                      target: target,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size.square(32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: colors.surfaceContainerHigh,
        child: SizedBox.square(
          dimension: 58,
          child: imageUrl == null
              ? Icon(Icons.restaurant, color: colors.onSurfaceVariant)
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.restaurant, color: colors.onSurfaceVariant),
                ),
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

class _LoadingProductList extends StatelessWidget {
  const _LoadingProductList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      itemBuilder: (context, index) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? const Radius.circular(18) : Radius.zero,
            bottom: index == 5 ? const Radius.circular(18) : Radius.zero,
          ),
          border: Border(
            bottom: BorderSide(
              color: index == 5 ? Colors.transparent : colors.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              _SkeletonBox(width: 58, height: 58),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 180, height: 16),
                    SizedBox(height: 10),
                    _SkeletonBox(width: 96, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      itemCount: 6,
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}

class _EmptyResultsState extends StatelessWidget {
  const _EmptyResultsState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No foods found.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'Search failed. Please try again.',
              style: TextStyle(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
