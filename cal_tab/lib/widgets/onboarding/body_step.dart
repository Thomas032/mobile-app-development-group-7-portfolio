import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/providers/onboarding_form_provider.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:cal_tab/widgets/onboarding/slider_card.dart';
import 'package:cal_tab/widgets/shared/pill_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyStep extends ConsumerWidget {
  const BodyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(onboardingFormControllerProvider);
    final controller = ref.read(onboardingFormControllerProvider.notifier);

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
                    PillChoice(
                      key: Key('gender_${item.name}_pill'),
                      label: _genderLabel(item),
                      selected: state.gender == item,
                      onTap: () => controller.setGender(item),
                    ),
                    if (item != Gender.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SliderCard(
              title: 'Age',
              valueLabel: state.ageTouched
                  ? '${state.age!.round()} years'
                  : 'Choose your age',
              value: state.age ?? 30,
              min: 16,
              max: 90,
              divisions: 74,
              onChanged: controller.setAge,
            ),
            const SizedBox(height: 12),
            SliderCard(
              title: 'Height',
              valueLabel: state.heightTouched
                  ? '${state.height!.round()} cm'
                  : 'Choose your height',
              value: state.height ?? 175,
              min: 140,
              max: 220,
              divisions: 80,
              onChanged: controller.setHeight,
            ),
            const SizedBox(height: 12),
            SliderCard(
              title: 'Weight',
              valueLabel: state.weightTouched
                  ? '${state.weight!.round()} kg'
                  : 'Choose your weight',
              value: state.weight ?? 70,
              min: 40,
              max: 160,
              divisions: 120,
              onChanged: controller.setWeight,
            ),
          ],
        ),
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
