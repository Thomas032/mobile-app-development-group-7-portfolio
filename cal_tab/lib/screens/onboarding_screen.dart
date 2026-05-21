import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/services/nutrition_calculator.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  GoalType? _goalType;
  double? _age;
  double? _height;
  double? _weight;
  bool _ageTouched = false;
  bool _heightTouched = false;
  bool _weightTouched = false;
  Gender? _gender;
  ActivityLevel? _activityLevel;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canContinueGoals => _goalType != null;

  bool get _canContinueBody => _ageTouched && _heightTouched && _weightTouched;

  bool get _canContinueLifestyle => _gender != null && _activityLevel != null;

  bool get _canFinish =>
      _canContinueGoals && _canContinueBody && _canContinueLifestyle;

  bool _canProceed() {
    return switch (_currentPage) {
      0 => _canContinueGoals,
      1 => _canContinueBody,
      2 => _canContinueLifestyle,
      3 => _canFinish,
      _ => false,
    };
  }

  ProfileSetupInput? get _currentInput {
    if (!_canFinish) {
      return null;
    }

    return ProfileSetupInput(
      age: _age!.round(),
      heightCm: _height!,
      weightKg: _weight!,
      gender: _gender!,
      activityLevel: _activityLevel!,
      goalType: _goalType!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final preview = _buildPreview();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.surface,
              colors.primaryContainer.withValues(alpha: 0.18),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CalTab',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set up your nutrition plan in 4 steps.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StepBadge(current: _currentPage + 1, total: 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _currentPage
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      if (i != 3) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _GoalStep(
                      selectedGoal: _goalType,
                      onChanged: (goal) => setState(() => _goalType = goal),
                    ),
                    _BodyStep(
                      age: _age,
                      ageTouched: _ageTouched,
                      height: _height,
                      heightTouched: _heightTouched,
                      weight: _weight,
                      weightTouched: _weightTouched,
                      gender: _gender,
                      onGenderChanged: (value) =>
                          setState(() => _gender = value),
                      onAgeChanged: (value) {
                        setState(() {
                          _age = value;
                          _ageTouched = true;
                        });
                      },
                      onHeightChanged: (value) {
                        setState(() {
                          _height = value;
                          _heightTouched = true;
                        });
                      },
                      onWeightChanged: (value) {
                        setState(() {
                          _weight = value;
                          _weightTouched = true;
                        });
                      },
                    ),
                    _ExerciseLevelStep(
                      activityLevel: _activityLevel,
                      onActivityChanged: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    _PreviewStep(preview: preview),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _currentPage == 0 ? null : _goBack,
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          key: ValueKey(
                            'onboarding_primary_button_$_currentPage',
                          ),
                          onPressed: _isSaving
                              ? null
                              : _canProceed()
                                  ? (_currentPage == 3
                                      ? _finishOnboarding
                                      : _goNext)
                                  : null,
                          child: _isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentPage == 3 ? 'Create my plan' : 'Next',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (_currentPage == 0) {
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    final canAdvance = switch (_currentPage) {
      0 => _canContinueGoals,
      1 => _canContinueBody,
      2 => _canContinueLifestyle,
      _ => _canFinish,
    };

    if (!canAdvance || _currentPage >= 3) {
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  NutritionTargets? _buildPreview() {
    final input = _currentInput;
    if (input == null) {
      return null;
    }

    return ref
        .read(nutritionCalculatorProvider)
        .calculateTargets(
          weightKg: input.weightKg,
          heightCm: input.heightCm,
          age: input.age,
          gender: input.gender,
          activityLevel: input.activityLevel,
          goalType: input.goalType,
        );
  }

  Future<void> _finishOnboarding() async {
    final input = _currentInput;
    if (input == null) {
      return;
    }

    setState(() => _isSaving = true);

    final controller = ref.read(profileSetupControllerProvider.notifier);
    controller.completeOnboarding(profileId: 'local-user', input: input);
    await controller.saveCurrentProfile();

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selectedGoal, required this.onChanged});

  final GoalType? selectedGoal;
  final ValueChanged<GoalType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What\'s your goal?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll help you find the right calorie intake to achieve it.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final goal in GoalType.values) ...[
              SizedBox(
                height: 112,
                child: _ChoiceCard<GoalType>(
                  key: Key('goal_${goal.name}_card'),
                  selected: selectedGoal == goal,
                  title: _goalTitle(goal),
                  subtitle: _goalSubtitle(goal),
                  icon: _goalIcon(goal),
                  onTap: () => onChanged(goal),
                ),
              ),
              if (goal != GoalType.values.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _BodyStep extends StatelessWidget {
  const _BodyStep({
    required this.age,
    required this.ageTouched,
    required this.height,
    required this.heightTouched,
    required this.weight,
    required this.weightTouched,
    required this.gender,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  final double? age;
  final bool ageTouched;
  final double? height;
  final bool heightTouched;
  final double? weight;
  final bool weightTouched;
  final Gender? gender;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<double> onAgeChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onWeightChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'About you',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will help us calculate your target calories.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gender',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final item in Gender.values) ...[
                    _PillChoice<Gender>(
                      key: Key('gender_${item.name}_pill'),
                      label: _genderLabel(item),
                      selected: gender == item,
                      onTap: () => onGenderChanged(item),
                    ),
                    if (item != Gender.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SliderCard(
              title: 'Age',
              valueLabel: ageTouched
                  ? '${age!.round()} years'
                  : 'Choose your age',
              value: age ?? 30,
              min: 16,
              max: 90,
              divisions: 74,
              onChanged: onAgeChanged,
            ),
            const SizedBox(height: 12),
            _SliderCard(
              title: 'Height',
              valueLabel: heightTouched
                  ? '${height!.round()} cm'
                  : 'Choose your height',
              value: height ?? 175,
              min: 140,
              max: 220,
              divisions: 80,
              onChanged: onHeightChanged,
            ),
            const SizedBox(height: 12),
            _SliderCard(
              title: 'Weight',
              valueLabel: weightTouched
                  ? '${weight!.round()} kg'
                  : 'Choose your weight',
              value: weight ?? 70,
              min: 40,
              max: 160,
              divisions: 120,
              onChanged: onWeightChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLevelStep extends StatelessWidget {
  const _ExerciseLevelStep({
    required this.activityLevel,
    required this.onActivityChanged,
  });

  final ActivityLevel? activityLevel;
  final ValueChanged<ActivityLevel> onActivityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exercise level',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how active your week usually looks.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Activity level',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                for (final item in ActivityLevel.values) ...[
                  _ChoiceCard<ActivityLevel>(
                    key: Key('activity_${item.name}_card'),
                    selected: activityLevel == item,
                    compact: true,
                    title: _activityLabel(item),
                    subtitle: _activitySubtitle(item),
                    icon: _activityIcon(item),
                    onTap: () => onActivityChanged(item),
                  ),
                  if (item != ActivityLevel.values.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.preview});

  final NutritionTargets? preview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your plan is ready',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This preview is based on the choices you just made. You can always fine-tune it later.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (preview != null)
              _TargetPreviewCard(preview: preview!)
            else
              _HintBanner(
                text:
                    'Finish the previous steps to unlock your target preview.',
              ),
            const Spacer(),
            _HintBanner(text: 'You can change any of this later in Settings.'),
          ],
        ),
      ),
    );
  }
}

class _TargetPreviewCard extends StatelessWidget {
  const _TargetPreviewCard({required this.preview});

  final NutritionTargets preview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${preview.calorieGoal} kcal',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          Text(
            'Daily target',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _MiniStat(
            label: 'Protein',
            value: preview.macroTargets.proteinGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Carbs',
            value: preview.macroTargets.carbsGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Fat',
            value: preview.macroTargets.fatGrams,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MiniStat(
            label: 'Fiber',
            value: preview.macroTargets.fiberGrams,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${value.round()} $unit',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ChoiceCard<T> extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.selected,
    this.compact = false,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final bool compact;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderColor = selected ? colors.primary : colors.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: compact ? 76 : 112),
          padding: EdgeInsets.all(compact ? 10 : 16),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.44)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 34 : 44,
                height: compact ? 34 : 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: colors.primary,
                  size: compact ? 18 : 24,
                ),
              ),
              SizedBox(width: compact ? 8 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: compact ? 12 : 13.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: compact ? 16 : 20,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillChoice<T> extends StatelessWidget {
  const _PillChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? colors.onPrimaryContainer : colors.onSurface,
      ),
      selectedColor: colors.primaryContainer,
      side: BorderSide(
        color: selected ? colors.primary : colors.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  valueLabel,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$current/$total',
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
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

String _activitySubtitle(ActivityLevel activityLevel) {
  return switch (activityLevel) {
    ActivityLevel.sedentary => 'Mostly seated, little exercise.',
    ActivityLevel.lightlyActive => 'A bit of movement each day.',
    ActivityLevel.moderatelyActive => 'Regular training or active work.',
    ActivityLevel.veryActive => 'High training load or physical work.',
  };
}

IconData _activityIcon(ActivityLevel activityLevel) {
  return switch (activityLevel) {
    ActivityLevel.sedentary => Icons.chair_alt_outlined,
    ActivityLevel.lightlyActive => Icons.directions_walk_rounded,
    ActivityLevel.moderatelyActive => Icons.fitness_center_rounded,
    ActivityLevel.veryActive => Icons.local_fire_department_rounded,
  };
}

String _goalTitle(GoalType goalType) {
  return switch (goalType) {
    GoalType.cut => 'Lean out',
    GoalType.maintain => 'Stay on track',
    GoalType.bulk => 'Build up',
  };
}

String _goalSubtitle(GoalType goalType) {
  return switch (goalType) {
    GoalType.cut => 'Create a calorie deficit with steady pacing.',
    GoalType.maintain => 'Keep your current weight and consistency.',
    GoalType.bulk => 'Support muscle gain with extra fuel.',
  };
}

IconData _goalIcon(GoalType goalType) {
  return switch (goalType) {
    GoalType.cut => Icons.trending_down_rounded,
    GoalType.maintain => Icons.balance_rounded,
    GoalType.bulk => Icons.trending_up_rounded,
  };
}
