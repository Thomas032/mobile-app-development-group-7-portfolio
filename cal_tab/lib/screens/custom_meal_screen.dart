import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/custom_meals_provider.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomMealScreen extends ConsumerStatefulWidget {
  const CustomMealScreen({super.key});

  @override
  ConsumerState<CustomMealScreen> createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends ConsumerState<CustomMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _fiberController = TextEditingController(text: '0');
  final _sugarController = TextEditingController(text: '0');
  final _sodiumController = TextEditingController(text: '0');
  final _saturatedFatController = TextEditingController(text: '0');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
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
                    'Create custom meal',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save a reusable food with nutrition per 100g.',
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
                    _NumberField(
                      fieldKey: const Key('custom_meal_calories_field'),
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
                          child: _NumberField(
                            fieldKey: const Key('custom_meal_protein_field'),
                            controller: _proteinController,
                            label: 'Protein',
                            suffix: 'g',
                            validator: _requiredNonNegativeDouble,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            fieldKey: const Key('custom_meal_carbs_field'),
                            controller: _carbsController,
                            label: 'Carbs',
                            suffix: 'g',
                            validator: _requiredNonNegativeDouble,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            fieldKey: const Key('custom_meal_fat_field'),
                            controller: _fatController,
                            label: 'Fat',
                            suffix: 'g',
                            validator: _requiredNonNegativeDouble,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            fieldKey: const Key('custom_meal_fiber_field'),
                            controller: _fiberController,
                            label: 'Fiber',
                            suffix: 'g',
                            validator: _requiredNonNegativeDouble,
                          ),
                        ),
                      ],
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
                        _NumberField(
                          fieldKey: const Key('custom_meal_sugar_field'),
                          controller: _sugarController,
                          label: 'Sugar',
                          suffix: 'g',
                          validator: _requiredNonNegativeDouble,
                        ),
                        const SizedBox(height: 16),
                        _NumberField(
                          fieldKey: const Key('custom_meal_sodium_field'),
                          controller: _sodiumController,
                          label: 'Sodium',
                          suffix: 'mg',
                          validator: _requiredNonNegativeDouble,
                        ),
                        const SizedBox(height: 16),
                        _NumberField(
                          fieldKey: const Key(
                            'custom_meal_saturated_fat_field',
                          ),
                          controller: _saturatedFatController,
                          label: 'Saturated fat',
                          suffix: 'g',
                          validator: _requiredNonNegativeDouble,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('save_custom_meal_button'),
                        onPressed: _isSaving ? null : _saveMeal,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(_isSaving ? 'Saving…' : 'Save custom meal'),
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

    final meal = FoodItem(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      calories: int.parse(_caloriesController.text.trim()),
      proteinGrams: double.parse(_proteinController.text.trim()),
      carbsGrams: double.parse(_carbsController.text.trim()),
      fatGrams: double.parse(_fatController.text.trim()),
      fiberGrams: double.parse(_fiberController.text.trim()),
      sugarGrams: double.parse(_sugarController.text.trim()),
      sodiumMilligrams: double.parse(_sodiumController.text.trim()),
      saturatedFatGrams: double.parse(_saturatedFatController.text.trim()),
    );

    await ref.read(customMealsControllerProvider.notifier).addMeal(meal);
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
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.validator,
    this.allowDecimal = true,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? Function(String?) validator;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      validator: validator,
    );
  }
}
