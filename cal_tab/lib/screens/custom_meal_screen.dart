import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/custom_meals_provider.dart';
import 'package:cal_tab/widgets/custom_meal/custom_meal_number_field.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomMealScreen extends ConsumerStatefulWidget {
  const CustomMealScreen({super.key, this.existingMeal});

  final FoodItem? existingMeal;

  bool get isEditing => existingMeal != null;

  @override
  ConsumerState<CustomMealScreen> createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends ConsumerState<CustomMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mealSizeController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sugarController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _saturatedFatController;

  // Tracked so we can rebuild for the live "remaining" hint.
  late final List<TextEditingController> _liveControllers;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMeal;

    // Existing meals are stored per-100g, so default the editor size to 100.
    // The pre-filled macro values are exactly the per-100g values.
    _nameController = TextEditingController(text: existing?.name ?? '');
    _mealSizeController = TextEditingController(text: '100');
    _caloriesController = TextEditingController(
      text: existing != null ? existing.calories.toString() : '',
    );
    _proteinController = TextEditingController(
      text: _formatNumber(existing?.proteinGrams ?? 0),
    );
    _carbsController = TextEditingController(
      text: _formatNumber(existing?.carbsGrams ?? 0),
    );
    _fatController = TextEditingController(
      text: _formatNumber(existing?.fatGrams ?? 0),
    );
    _fiberController = TextEditingController(
      text: _formatNumber(existing?.fiberGrams ?? 0),
    );
    _sugarController = TextEditingController(
      text: _formatNumber(existing?.sugarGrams ?? 0),
    );
    _sodiumController = TextEditingController(
      text: _formatNumber(existing?.sodiumMilligrams ?? 0),
    );
    _saturatedFatController = TextEditingController(
      text: _formatNumber(existing?.saturatedFatGrams ?? 0),
    );

    _liveControllers = [
      _mealSizeController,
      _proteinController,
      _carbsController,
      _fatController,
      _fiberController,
      _sugarController,
      _saturatedFatController,
    ];
    for (final controller in _liveControllers) {
      controller.addListener(_onLiveChange);
    }
  }

  void _onLiveChange() => setState(() {});

  @override
  void dispose() {
    for (final controller in _liveControllers) {
      controller.removeListener(_onLiveChange);
    }
    _nameController.dispose();
    _mealSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _saturatedFatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final isEditing = widget.isEditing;

    final mealSize = _parseDouble(_mealSizeController.text);
    final protein = _parseDouble(_proteinController.text) ?? 0;
    final carbs = _parseDouble(_carbsController.text) ?? 0;
    final fat = _parseDouble(_fatController.text) ?? 0;
    final macroTotal = protein + carbs + fat;
    final remaining = (mealSize ?? 0) - macroTotal;
    final hasMealSize = mealSize != null && mealSize > 0;
    final overBudget = hasMealSize && remaining < 0;

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
                    isEditing ? 'Edit custom meal' : 'Create custom meal',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save a reusable food. Macros below are for the meal '
                      'size you enter — we store them normalized to per-100g.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('custom_meal_name_field'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Meal name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a meal name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomMealNumberField(
                      key: const Key('custom_meal_size_field'),
                      controller: _mealSizeController,
                      label: 'Meal size',
                      suffix: 'g',
                      allowDecimal: false,
                      validator: _requiredPositiveInt,
                    ),
                    const SizedBox(height: 16),
                    CustomMealNumberField(
                      key: const Key('custom_meal_calories_field'),
                      controller: _caloriesController,
                      label: 'Calories',
                      suffix: 'kcal',
                      allowDecimal: false,
                      validator: _requiredPositiveInt,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomMealNumberField(
                            key: const Key('custom_meal_protein_field'),
                            controller: _proteinController,
                            label: 'Protein',
                            suffix: 'g',
                            validator: _macroValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomMealNumberField(
                            key: const Key('custom_meal_carbs_field'),
                            controller: _carbsController,
                            label: 'Carbs',
                            suffix: 'g',
                            validator: _macroValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomMealNumberField(
                            key: const Key('custom_meal_fat_field'),
                            controller: _fatController,
                            label: 'Fat',
                            suffix: 'g',
                            validator: _fatValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomMealNumberField(
                            key: const Key('custom_meal_fiber_field'),
                            controller: _fiberController,
                            label: 'Fiber',
                            suffix: 'g',
                            validator: _fiberValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _RemainingHint(
                      mealSize: mealSize,
                      macroTotal: macroTotal,
                      remaining: remaining,
                      overBudget: overBudget,
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(
                        'Optional nutrients',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Sugar, sodium, saturated fat',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      children: [
                        CustomMealNumberField(
                          key: const Key('custom_meal_sugar_field'),
                          controller: _sugarController,
                          label: 'Sugar',
                          suffix: 'g',
                          validator: _sugarValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomMealNumberField(
                          key: const Key('custom_meal_sodium_field'),
                          controller: _sodiumController,
                          label: 'Sodium',
                          suffix: 'mg',
                          validator: _requiredNonNegativeDouble,
                        ),
                        const SizedBox(height: 16),
                        CustomMealNumberField(
                          key: const Key(
                            'custom_meal_saturated_fat_field',
                          ),
                          controller: _saturatedFatController,
                          label: 'Saturated fat',
                          suffix: 'g',
                          validator: _saturatedFatValidator,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('save_custom_meal_button'),
                        onPressed: _isSaving ? null : _saveMeal,
                        icon: Icon(
                          isEditing
                              ? Icons.save_outlined
                              : Icons.bookmark_add_outlined,
                        ),
                        label: Text(
                          _isSaving
                              ? 'Saving…'
                              : (isEditing
                                    ? 'Save changes'
                                    : 'Save custom meal'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final mealSize = double.parse(_mealSizeController.text.trim());
    final scale = 100 / mealSize;

    final scaledCalories =
        (int.parse(_caloriesController.text.trim()) * scale).round();
    double scaled(TextEditingController c) =>
        double.parse(c.text.trim()) * scale;

    final existing = widget.existingMeal;
    final meal = FoodItem(
      id: existing?.id ?? 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      calories: scaledCalories,
      proteinGrams: scaled(_proteinController),
      carbsGrams: scaled(_carbsController),
      fatGrams: scaled(_fatController),
      fiberGrams: scaled(_fiberController),
      sugarGrams: scaled(_sugarController),
      sodiumMilligrams: scaled(_sodiumController),
      saturatedFatGrams: scaled(_saturatedFatController),
      imageUrl: existing?.imageUrl,
    );

    final controller = ref.read(customMealsControllerProvider.notifier);
    if (existing != null) {
      await controller.updateMeal(meal);
    } else {
      await controller.addMeal(meal);
    }

    if (!mounted) {
      return;
    }
    context.pop(meal);
  }

  String? _requiredPositiveInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a value above 0';
    }
    return null;
  }

  String? _requiredNonNegativeDouble(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Enter 0 or more';
    }
    return null;
  }

  // Protein + carbs cannot individually exceed the meal size.
  String? _macroValidator(String? value) {
    final base = _requiredNonNegativeDouble(value);
    if (base != null) return base;
    final mealSize = _parseDouble(_mealSizeController.text);
    if (mealSize == null || mealSize <= 0) return null;
    final v = double.parse(value!.trim());
    if (v > mealSize) {
      return 'Exceeds meal size';
    }
    return null;
  }

  // Fat field carries the "sum exceeds meal size" message.
  String? _fatValidator(String? value) {
    final macroError = _macroValidator(value);
    if (macroError != null) return macroError;
    final mealSize = _parseDouble(_mealSizeController.text);
    if (mealSize == null || mealSize <= 0) return null;
    final protein = _parseDouble(_proteinController.text) ?? 0;
    final carbs = _parseDouble(_carbsController.text) ?? 0;
    final fat = _parseDouble(value) ?? 0;
    if (protein + carbs + fat > mealSize) {
      return 'P+C+F exceeds meal size';
    }
    return null;
  }

  String? _fiberValidator(String? value) {
    final base = _requiredNonNegativeDouble(value);
    if (base != null) return base;
    final fiber = double.parse(value!.trim());
    final carbs = _parseDouble(_carbsController.text);
    if (carbs != null && fiber > carbs) {
      return 'Fiber > carbs';
    }
    return null;
  }

  String? _sugarValidator(String? value) {
    final base = _requiredNonNegativeDouble(value);
    if (base != null) return base;
    final sugar = double.parse(value!.trim());
    final carbs = _parseDouble(_carbsController.text);
    if (carbs != null && sugar > carbs) {
      return 'Sugar > carbs';
    }
    return null;
  }

  String? _saturatedFatValidator(String? value) {
    final base = _requiredNonNegativeDouble(value);
    if (base != null) return base;
    final satFat = double.parse(value!.trim());
    final fat = _parseDouble(_fatController.text);
    if (fat != null && satFat > fat) {
      return 'Sat. fat > fat';
    }
    return null;
  }

  static double? _parseDouble(String? value) {
    return double.tryParse(value?.trim() ?? '');
  }

  static String _formatNumber(double value) {
    if (value == 0) return '0';
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}

class _RemainingHint extends StatelessWidget {
  const _RemainingHint({
    required this.mealSize,
    required this.macroTotal,
    required this.remaining,
    required this.overBudget,
  });

  final double? mealSize;
  final double macroTotal;
  final double remaining;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (mealSize == null || mealSize! <= 0) {
      return Text(
        'Enter a meal size to see remaining macros.',
        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      );
    }

    final color = overBudget ? colors.error : colors.onSurfaceVariant;
    final label = overBudget
        ? 'Over by ${(-remaining).toStringAsFixed(1)} g (P+C+F = '
              '${macroTotal.toStringAsFixed(1)} g / ${mealSize!.toStringAsFixed(0)} g)'
        : 'Remaining: ${remaining.toStringAsFixed(1)} g of '
              '${mealSize!.toStringAsFixed(0)} g';

    return Text(
      label,
      style: textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: overBudget ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
