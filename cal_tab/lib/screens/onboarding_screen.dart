import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController(text: '30');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');

  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  GoalType _goalType = GoalType.maintain;
  bool _isSaving = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'CalTab',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your daily target once. Everything stays local.',
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NumberField(
                      fieldKey: const Key('age_field'),
                      controller: _ageController,
                      label: 'Age',
                      suffix: 'years',
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      fieldKey: const Key('height_field'),
                      controller: _heightController,
                      label: 'Height',
                      suffix: 'cm',
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      fieldKey: const Key('weight_field'),
                      controller: _weightController,
                      label: 'Weight',
                      suffix: 'kg',
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<Gender>(
                      key: const Key('gender_field'),
                      label: 'Gender',
                      value: _gender,
                      values: Gender.values,
                      labelFor: _genderLabel,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<ActivityLevel>(
                      key: const Key('activity_field'),
                      label: 'Activity',
                      value: _activityLevel,
                      values: ActivityLevel.values,
                      labelFor: _activityLabel,
                      onChanged: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: 16),
                    _EnumDropdown<GoalType>(
                      key: const Key('goal_field'),
                      label: 'Goal',
                      value: _goalType,
                      values: GoalType.values,
                      labelFor: _goalLabel,
                      onChanged: (value) => setState(() => _goalType = value),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('finish_onboarding_button'),
                      onPressed: _isSaving ? null : _finishOnboarding,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create targets'),
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

  Future<void> _finishOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final controller = ref.read(profileSetupControllerProvider.notifier);
    controller.completeOnboarding(
      profileId: 'local-user',
      input: ProfileSetupInput(
        age: int.parse(_ageController.text),
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        gender: _gender,
        activityLevel: _activityLevel,
        goalType: _goalType,
      ),
    );
    await controller.saveCurrentProfile();

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        final parsed = num.tryParse(value ?? '');
        if (parsed == null || parsed <= 0) {
          return 'Enter a valid $label';
        }
        return null;
      },
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

String _genderLabel(Gender gender) {
  return switch (gender) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.nonSpecified => 'Prefer not to say',
  };
}

String _activityLabel(ActivityLevel activityLevel) {
  return switch (activityLevel) {
    ActivityLevel.sedentary => 'Sedentary',
    ActivityLevel.lightlyActive => 'Lightly active',
    ActivityLevel.moderatelyActive => 'Moderately active',
    ActivityLevel.veryActive => 'Very active',
  };
}

String _goalLabel(GoalType goalType) {
  return switch (goalType) {
    GoalType.cut => 'Cut',
    GoalType.maintain => 'Maintain',
    GoalType.bulk => 'Bulk',
  };
}
