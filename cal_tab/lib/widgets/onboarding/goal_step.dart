import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/providers/onboarding_form_provider.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/shared/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalStep extends ConsumerWidget {
  const GoalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedGoal = ref.watch(
      onboardingFormControllerProvider.select((s) => s.goalType),
    );
    final controller = ref.read(onboardingFormControllerProvider.notifier);

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
                child: ChoiceCard<GoalType>(
                  key: Key('goal_${goal.name}_card'),
                  selected: selectedGoal == goal,
                  title: _goalTitle(goal),
                  subtitle: _goalSubtitle(goal),
                  icon: _goalIcon(goal),
                  onTap: () => controller.setGoal(goal),
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
