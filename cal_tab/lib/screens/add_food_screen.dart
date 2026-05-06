import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

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
    final textTheme = Theme.of(context).textTheme;
    final searchState = ref.watch(foodSearchControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add food',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchCommandBar(
                controller: _searchController,
                onChanged: _queueSearch,
                onSubmitted: (_) => _runSearch(force: true),
                onBarcode: () => _showUnavailable('Barcode scanning'),
                onSnap2Cal: () => _showUnavailable('Snap2Cal'),
                onManualEntry: _openManualFoodSheet,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  onLoadMore: () => ref
                      .read(foodSearchControllerProvider.notifier)
                      .loadMore(),
                ),
                loading: _LoadingProductList.new,
                error: (error, stackTrace) => _SearchErrorState(
                  onRetry: () => _runSearch(force: true),
                ),
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

  Future<void> _openManualFoodSheet() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _ManualFoodSheet(),
    );

    if (saved == true && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not wired up yet.')),
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
    required this.onManualEntry,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBarcode;
  final VoidCallback onSnap2Cal;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('food_search_field'),
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
                hintText: 'Search food, brand, barcode...',
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
          _CommandIconButton(
            key: const Key('manual_food_action_button'),
            tooltip: 'Define own meal',
            icon: Icons.edit_note,
            color: colors.primary,
            onPressed: onManualEntry,
          ),
        ],
      ),
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
      icon: Icon(icon),
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  const _ResultsSummary(this.state)
      : title = null,
        subtitle = null;

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
    final resolvedTitle = title ??
        (searchState!.isBrowsing
            ? 'All products'
            : 'Results for "${searchState.query}"');
    final shownCount = searchState?.items.length ?? 0;
    final totalCount = searchState?.totalCount ?? 0;
    final resolvedSubtitle =
        subtitle ?? '$shownCount shown${totalCount > 0 ? ' of $totalCount' : ''}';

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
              const SizedBox(height: 2),
              Text(
                resolvedSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FoodResultsList extends StatelessWidget {
  const _FoodResultsList({
    required this.state,
    required this.onLoadMore,
  });

  final FoodSearchState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const _EmptyResultsState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 320 &&
            state.hasMore &&
            !state.isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        cacheExtent: 400,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return _LoadMoreFooter(
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: onLoadMore,
            );
          }

          return _FoodSearchResultTile(foodItem: state.items[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: state.items.length + 1,
      ),
    );
  }
}

class _FoodSearchResultTile extends StatelessWidget {
  const _FoodSearchResultTile({required this.foodItem});

  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: _FoodThumbnail(imageUrl: foodItem.imageUrl),
        title: Text(
          foodItem.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'P ${foodItem.proteinGrams.toStringAsFixed(1)}g · '
            'C ${foodItem.carbsGrams.toStringAsFixed(1)}g · '
            'F ${foodItem.fatGrams.toStringAsFixed(1)}g',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${foodItem.calories}',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                Text(
                  'kcal',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
        onTap: () => context.pushNamed('food-detail', extra: foodItem),
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
          dimension: 52,
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
        padding: EdgeInsets.symmetric(vertical: 16),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemBuilder: (context, index) => AppCard(
        child: Row(
          children: [
            const _SkeletonBox(width: 52, height: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 180, height: 16),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 240, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

class _ManualFoodSheet extends ConsumerStatefulWidget {
  const _ManualFoodSheet();

  @override
  ConsumerState<_ManualFoodSheet> createState() => _ManualFoodSheetState();
}

class _ManualFoodSheetState extends ConsumerState<_ManualFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _fiberController = TextEditingController(text: '0');
  final _quantityController = TextEditingController(text: '1');

  late MealType _mealType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mealType = ref
        .read(mealAssignmentServiceProvider)
        .assignFor(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 44, height: 4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Define own meal',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('manual_food_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food name'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _NumberField(
                fieldKey: const Key('manual_calories_field'),
                controller: _caloriesController,
                label: 'Calories',
                suffix: 'kcal',
                allowZero: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      fieldKey: const Key('manual_protein_field'),
                      controller: _proteinController,
                      label: 'Protein',
                      suffix: 'g',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      fieldKey: const Key('manual_carbs_field'),
                      controller: _carbsController,
                      label: 'Carbs',
                      suffix: 'g',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      fieldKey: const Key('manual_fat_field'),
                      controller: _fatController,
                      label: 'Fat',
                      suffix: 'g',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      fieldKey: const Key('manual_fiber_field'),
                      controller: _fiberController,
                      label: 'Fiber',
                      suffix: 'g',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NumberField(
                fieldKey: const Key('manual_quantity_field'),
                controller: _quantityController,
                label: 'Quantity',
                suffix: 'servings',
                allowZero: false,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MealType>(
                key: const Key('manual_meal_type_field'),
                value: _mealType,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: [
                  for (final mealType in MealType.values)
                    DropdownMenuItem(
                      value: mealType,
                      child: Text(mealType.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mealType = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('save_manual_food_button'),
                onPressed: _isSaving ? null : _saveFood,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Add to day'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final food = FoodItem(
      id: 'manual-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      calories: double.parse(_caloriesController.text).round(),
      proteinGrams: double.parse(_proteinController.text),
      carbsGrams: double.parse(_carbsController.text),
      fatGrams: double.parse(_fatController.text),
      fiberGrams: double.parse(_fiberController.text),
    );

    final controller = ref.read(dailyLogControllerProvider.notifier);
    controller.logFood(
      entryId: 'entry-${now.microsecondsSinceEpoch}',
      foodItem: food,
      date: now,
      quantity: double.parse(_quantityController.text),
      mealType: _mealType,
    );
    await controller.saveCurrentEntries();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.suffix,
    this.allowZero = true,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool allowZero;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        final parsed = num.tryParse(value ?? '');
        final isValid =
            parsed != null && (allowZero ? parsed >= 0 : parsed > 0);
        if (!isValid) {
          return allowZero ? 'Use 0 or more' : 'Use more than 0';
        }
        return null;
      },
    );
  }
}
