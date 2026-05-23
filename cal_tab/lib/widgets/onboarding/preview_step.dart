import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/onboarding_form_provider.dart';
import 'package:cal_tab/services/nutrition_calculator.dart';
import 'package:cal_tab/widgets/shared/app_card.dart';
import 'package:cal_tab/widgets/onboarding/hint_banner.dart';
import 'package:cal_tab/widgets/onboarding/target_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewStep extends ConsumerWidget {
  const PreviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final input = ref.watch(
      onboardingFormControllerProvider.select((s) => s.currentInput),
    );

    final NutritionTargets? preview = input == null
        ? null
        : ref
              .read(nutritionCalculatorProvider)
              .calculateTargets(
                weightKg: input.weightKg,
                heightCm: input.heightCm,
                age: input.age,
                gender: input.gender,
                activityLevel: input.activityLevel,
                goalType: input.goalType,
              );

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
              TargetPreviewCard(preview: preview)
            else
              const HintBanner(
                text:
                    'Finish the previous steps to unlock your target preview.',
              ),
            const Spacer(),
            const HintBanner(text: 'You can change any of this later in Settings.'),
          ],
        ),
      ),
    );
  }
}
