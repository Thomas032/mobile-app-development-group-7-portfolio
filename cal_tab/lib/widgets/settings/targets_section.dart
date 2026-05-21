import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/shared/number_field.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetsSection extends ConsumerStatefulWidget {
  const TargetsSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<TargetsSection> createState() => _TargetsSectionState();
}

class _TargetsSectionState extends ConsumerState<TargetsSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _calorieController = TextEditingController(
    text: '${widget.profile.calorieGoal}',
  );
  late final TextEditingController _proteinController = TextEditingController(
    text: _format(widget.profile.macroTargets.proteinGrams),
  );
  late final TextEditingController _carbsController = TextEditingController(
    text: _format(widget.profile.macroTargets.carbsGrams),
  );
  late final TextEditingController _fatController = TextEditingController(
    text: _format(widget.profile.macroTargets.fatGrams),
  );
  late final TextEditingController _fiberController = TextEditingController(
    text: _format(widget.profile.macroTargets.fiberGrams),
  );

  @override
  void didUpdateWidget(covariant TargetsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile == widget.profile) {
      return;
    }

    _calorieController.text = '${widget.profile.calorieGoal}';
    _proteinController.text = _format(widget.profile.macroTargets.proteinGrams);
    _carbsController.text = _format(widget.profile.macroTargets.carbsGrams);
    _fatController.text = _format(widget.profile.macroTargets.fatGrams);
    _fiberController.text = _format(widget.profile.macroTargets.fiberGrams);
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Daily targets',
      icon: Icons.flag_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberField(
              fieldKey: const Key('calorie_goal_field'),
              controller: _calorieController,
              label: 'Calorie goal',
              suffix: 'kcal',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('protein_target_field'),
              controller: _proteinController,
              label: 'Protein',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('carbs_target_field'),
              controller: _carbsController,
              label: 'Carbs',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('fat_target_field'),
              controller: _fatController,
              label: 'Fat',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('fiber_target_field'),
              controller: _fiberController,
              label: 'Fiber',
              suffix: 'g',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save_targets_button'),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save targets'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(profileSetupControllerProvider.notifier)
        .updateTargets(
          calorieGoal: int.parse(_calorieController.text),
          macroTargets: MacroTargets(
            proteinGrams: double.parse(_proteinController.text),
            carbsGrams: double.parse(_carbsController.text),
            fatGrams: double.parse(_fatController.text),
            fiberGrams: double.parse(_fiberController.text),
          ),
        );
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Targets updated.')));
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
