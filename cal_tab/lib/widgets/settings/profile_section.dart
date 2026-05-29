import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/shared/enum_dropdown.dart';
import 'package:cal_tab/widgets/shared/number_field.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  late final _ageController = TextEditingController(
    text: '${widget.profile.age}',
  );
  late final _heightController = TextEditingController(
    text: widget.profile.heightCm.toStringAsFixed(0),
  );
  late final _weightController = TextEditingController(
    text: widget.profile.weightKg.toStringAsFixed(1),
  );
  late Gender _gender = widget.profile.gender;
  late ActivityLevel _activityLevel = widget.profile.activityLevel;
  late GoalType _goalType = widget.profile.goalType;

  @override
  void didUpdateWidget(covariant ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final p = widget.profile;
    if (p == oldWidget.profile) return;

    final age = '${p.age}';
    if (_ageController.text != age) _ageController.text = age;

    final height = p.heightCm.toStringAsFixed(0);
    if (_heightController.text != height) _heightController.text = height;

    final weight = p.weightKg.toStringAsFixed(1);
    if (_weightController.text != weight) _weightController.text = weight;

    if (_gender != p.gender ||
        _activityLevel != p.activityLevel ||
        _goalType != p.goalType) {
      setState(() {
        _gender = p.gender;
        _activityLevel = p.activityLevel;
        _goalType = p.goalType;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileSetupControllerProvider, (previous, next) {
      final newWeight = next.profile?.weightKg;
      if (newWeight == null) return;
      final formatted = newWeight.toStringAsFixed(1);
      if (_weightController.text != formatted) {
        _weightController.text = formatted;
      }
    });

    return SectionCard(
      title: 'Profile (recalculates targets)',
      icon: Icons.person_outline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberField(
              fieldKey: const Key('settings_age_field'),
              controller: _ageController,
              label: 'Age',
              suffix: 'years',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('settings_height_field'),
              controller: _heightController,
              label: 'Height',
              suffix: 'cm',
            ),
            const SizedBox(height: 12),
            NumberField(
              fieldKey: const Key('settings_weight_field'),
              controller: _weightController,
              label: 'Weight',
              suffix: 'kg',
            ),
            const SizedBox(height: 12),
            EnumDropdown<Gender>(
              key: const Key('settings_gender_field'),
              label: 'Gender',
              value: _gender,
              values: Gender.values,
              labelFor: (v) => v.label,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            EnumDropdown<ActivityLevel>(
              key: const Key('settings_activity_field'),
              label: 'Activity',
              value: _activityLevel,
              values: ActivityLevel.values,
              labelFor: (v) => v.label,
              onChanged: (v) => setState(() => _activityLevel = v),
            ),
            const SizedBox(height: 12),
            EnumDropdown<GoalType>(
              key: const Key('settings_goal_field'),
              label: 'Goal',
              value: _goalType,
              values: GoalType.values,
              labelFor: (v) => v.shortLabel,
              onChanged: (v) => setState(() => _goalType = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save_profile_button'),
              onPressed: _save,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Recalculate targets'),
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
        .updateProfileInputs(
          ProfileSetupInput(
            age: int.parse(_ageController.text),
            heightCm: double.parse(_heightController.text),
            weightKg: double.parse(_weightController.text),
            gender: _gender,
            activityLevel: _activityLevel,
            goalType: _goalType,
          ),
        );
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Profile updated. Targets recalculated.')),
    );
  }
}

