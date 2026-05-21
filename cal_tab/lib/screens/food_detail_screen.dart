import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:cal_tab/widgets/meal_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _InputMode { grams, portions }

class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.foodItem,
    this.target,
    this.editingEntry,
  });

  final FoodItem? foodItem;
  final FoodLogTarget? target;
  final MealEntry? editingEntry;

  bool get isEditing => editingEntry != null;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  late final TextEditingController _quantityController;

  late MealType _mealType;
  late FoodLogTarget _target;
  late _InputMode _inputMode;
  bool _isSaving = false;
  bool _expandedNutrients = false;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingEntry;

    _target =
        (widget.target ??
                FoodLogTarget(
                  date: editing?.date ?? ref.read(selectedLogDateProvider),
                  mealType: editing?.mealType,
                ))
            .normalized();

    if (editing != null) {
      _mealType = editing.mealType;
      _inputMode = _InputMode.grams;
      _quantityController = TextEditingController(
        text: (editing.quantity * 100).toStringAsFixed(0),
      );
    } else {
      _inputMode = _InputMode.grams;
      _quantityController = TextEditingController(text: '100');
      _mealType =
          _target.mealType ??
          ref
              .read(mealAssignmentServiceProvider)
              .assignFor(_entryDate(DateTime.now()));
    }

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
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() => _expandedNutrients = !_expandedNutrients);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'More nutrients',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        Icon(
                          _expandedNutrients
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                  if (_expandedNutrients) ...[
                    const SizedBox(height: 12),
                    _NutrientRow(label: 'Fiber', value: food.fiberGrams),
                    _NutrientRow(label: 'Sugar', value: food.sugarGrams),
                    _NutrientRow(
                      label: 'Sodium',
                      value: food.sodiumMilligrams,
                      unit: 'mg',
                    ),
                    _NutrientRow(
                      label: 'Sat. Fat',
                      value: food.saturatedFatGrams,
                    ),
                  ],
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
                  _MealTargetRow(mealType: _mealType, onChanged: _pickMeal),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('add_search_food_button'),
                    onPressed: _isSaving ? null : () => _submit(food),
                    icon: Icon(
                      widget.isEditing ? Icons.save_outlined : Icons.check,
                    ),
                    label: Text(widget.isEditing ? 'Update' : 'Add to day'),
                  ),
                  if (widget.isEditing) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('delete_entry_button'),
                      onPressed: _isSaving ? null : _deleteEntry,
                      icon: Icon(Icons.delete_outline, color: colors.error),
                      label: Text(
                        'Delete entry',
                        style: TextStyle(color: colors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMeal() async {
    final next = await showMealPickerSheet(
      context,
      selected: _mealType,
      title: 'Change meal',
    );
    if (next == null || !mounted || next == _mealType) {
      return;
    }
    setState(() => _mealType = next);
  }

  Future<void> _deleteEntry() async {
    final editing = widget.editingEntry;
    if (editing == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: Text('Remove "${editing.foodItem.name}" from your log?'),
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
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSaving = true);

    final controller = ref.read(dailyLogControllerProvider.notifier);
    controller.removeEntry(editing.id);
    await controller.saveCurrentEntries();

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _submit(FoodItem food) async {
    final raw = double.tryParse(_quantityController.text);
    if (raw == null || raw <= 0) {
      return;
    }
    final quantity = _inputMode == _InputMode.grams ? raw / 100.0 : raw;
    if (quantity <= 0) {
      return;
    }

    setState(() => _isSaving = true);

    final controller = ref.read(dailyLogControllerProvider.notifier);
    final editing = widget.editingEntry;
    if (editing != null) {
      controller.updateEntry(
        entryId: editing.id,
        quantity: quantity,
        mealType: _mealType,
      );
    } else {
      final now = DateTime.now();
      controller.logFood(
        entryId: 'entry-${now.microsecondsSinceEpoch}',
        foodItem: food,
        date: _entryDate(now),
        quantity: quantity,
        mealType: _mealType,
      );
    }
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

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.label,
    required this.value,
    this.unit = 'g',
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${value.toStringAsFixed(1)} $unit'),
        ],
      ),
    );
  }
}

class _MealTargetRow extends StatelessWidget {
  const _MealTargetRow({required this.mealType, required this.onChanged});

  final MealType mealType;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('detail_meal_target'),
        borderRadius: BorderRadius.circular(18),
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      mealTypeLabel(mealType),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: colors.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
