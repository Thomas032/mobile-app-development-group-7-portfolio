import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _InputMode { grams, portions }

class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({super.key, required this.foodItem, this.target});

  final FoodItem? foodItem;
  final FoodLogTarget? target;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  final _quantityController = TextEditingController(text: '100');

  late MealType _mealType;
  late FoodLogTarget _target;
  _InputMode _inputMode = _InputMode.grams;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _target =
        (widget.target ??
                FoodLogTarget(date: ref.read(selectedLogDateProvider)))
            .normalized();
    _mealType =
        _target.mealType ??
        ref
            .read(mealAssignmentServiceProvider)
            .assignFor(_entryDate(DateTime.now()));
    _quantityController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() => setState(() {});

  @override
  void dispose() {
    _quantityController.removeListener(_onAmountChanged);
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.foodItem;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (food == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Food not found')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (food.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: Image.network(food.imageUrl!, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${food.calories} kcal',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'per 100g',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _NutrientRow(label: 'Protein', value: food.proteinGrams),
                  _NutrientRow(label: 'Carbs', value: food.carbsGrams),
                  _NutrientRow(label: 'Fat', value: food.fatGrams),
                  _NutrientRow(label: 'Fiber', value: food.fiberGrams),
                  const SizedBox(height: 20),
                  SegmentedButton<_InputMode>(
                    segments: const [
                      ButtonSegment(
                        value: _InputMode.grams,
                        label: Text('Grams'),
                        icon: Icon(Icons.scale_outlined),
                      ),
                      ButtonSegment(
                        value: _InputMode.portions,
                        label: Text('Portion'),
                        icon: Icon(Icons.restaurant_outlined),
                      ),
                    ],
                    selected: {_inputMode},
                    onSelectionChanged: (modes) {
                      if (modes.isEmpty) return;
                      setState(() {
                        _inputMode = modes.first;
                        _quantityController.text =
                            _inputMode == _InputMode.grams ? '100' : '1';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('detail_quantity_field'),
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: _inputMode == _InputMode.grams
                          ? 'Amount'
                          : 'Portions',
                      suffixText: _inputMode == _InputMode.grams
                          ? 'g'
                          : '× 100g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionPreview(food),
                  const SizedBox(height: 16),
                  _MealTargetRow(mealType: _mealType),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('add_search_food_button'),
                    onPressed: _isSaving ? null : () => _addFood(food),
                    icon: const Icon(Icons.check),
                    label: const Text('Add to day'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _effectiveQuantity {
    final raw = double.tryParse(_quantityController.text) ?? 0;
    return _inputMode == _InputMode.grams ? raw / 100.0 : raw;
  }

  Widget _buildNutritionPreview(FoodItem food) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final q = _effectiveQuantity;
    final kcal = (food.calories * q).round();
    final p = food.proteinGrams * q;
    final c = food.carbsGrams * q;
    final f = food.fatGrams * q;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PreviewChip(
          label: '$kcal kcal',
          color: colors.primary,
          textTheme: textTheme,
        ),
        _PreviewChip(
          label: 'P ${p.toStringAsFixed(1)}g',
          color: const Color(0xFFFF9500),
          textTheme: textTheme,
        ),
        _PreviewChip(
          label: 'C ${c.toStringAsFixed(1)}g',
          color: const Color(0xFF34C759),
          textTheme: textTheme,
        ),
        _PreviewChip(
          label: 'F ${f.toStringAsFixed(1)}g',
          color: const Color(0xFFFF8E80),
          textTheme: textTheme,
        ),
      ],
    );
  }

  Future<void> _addFood(FoodItem food) async {
    final raw = double.tryParse(_quantityController.text);
    if (raw == null || raw <= 0) {
      return;
    }
    final quantity = _inputMode == _InputMode.grams ? raw / 100.0 : raw;
    if (quantity <= 0) {
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final controller = ref.read(dailyLogControllerProvider.notifier);
    controller.logFood(
      entryId: 'entry-${now.microsecondsSinceEpoch}',
      foodItem: food,
      date: _entryDate(now),
      quantity: quantity,
      mealType: _mealType,
    );
    await controller.saveCurrentEntries();

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  DateTime _entryDate(DateTime now) {
    final date = _target.date;
    return DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.label,
    required this.color,
    required this.textTheme,
  });

  final String label;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${value.toStringAsFixed(1)} g'),
        ],
      ),
    );
  }
}

class _MealTargetRow extends StatelessWidget {
  const _MealTargetRow({required this.mealType});

  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('detail_meal_target'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu_rounded, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  _mealTargetLabel(mealType),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _mealTargetLabel(MealType mealType) {
  return switch (mealType) {
    MealType.breakfast => 'Breakfast',
    MealType.snackMorning => 'Morning snack',
    MealType.lunch => 'Lunch',
    MealType.snackAfternoon => 'Afternoon snack',
    MealType.dinner => 'Dinner',
    MealType.secondDinner => 'Second dinner',
  };
}
