import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
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
                Text(
                  'Add food',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search food...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Barcode scanner',
                    onPressed: null,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Camera estimate',
                    onPressed: null,
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Manual entry',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
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
          ],
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
      setState(() => _isSaving = false);
      Navigator.of(context).maybePop();
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
