import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/providers/onboarding_form_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:cal_tab/widgets/shared/choice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseLevelStep extends ConsumerWidget {
  const ExerciseLevelStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selected = ref.watch(
      onboardingFormControllerProvider.select((s) => s.activityLevel),
    );
    final controller = ref.read(onboardingFormControllerProvider.notifier);

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
                  ChoiceCard<ActivityLevel>(
                    key: Key('activity_${item.name}_card'),
                    selected: selected == item,
                    compact: true,
                    title: _activityLabel(item),
                    subtitle: _activitySubtitle(item),
                    icon: _activityIcon(item),
                    onTap: () => controller.setActivityLevel(item),
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
