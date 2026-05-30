import 'package:cal_tab/providers/onboarding_form_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/widgets/onboarding/body_step.dart';
import 'package:cal_tab/widgets/onboarding/exercise_level_step.dart';
import 'package:cal_tab/widgets/onboarding/goal_step.dart';
import 'package:cal_tab/widgets/onboarding/preview_step.dart';
import 'package:cal_tab/widgets/onboarding/step_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(onboardingFormControllerProvider);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(onboardingFormControllerProvider);

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
                    StepBadge(current: state.currentPage + 1, total: 4),
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
                            color: i <= state.currentPage
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
                    ref
                        .read(onboardingFormControllerProvider.notifier)
                        .setPage(page);
                  },
                  children: const [
                    GoalStep(),
                    BodyStep(),
                    ExerciseLevelStep(),
                    PreviewStep(),
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
                          onPressed: state.currentPage == 0 ? null : _goBack,
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
                            'onboarding_primary_button_${state.currentPage}',
                          ),
                          onPressed: state.isSaving
                              ? null
                              : state.canProceedFromPage(state.currentPage)
                              ? (state.currentPage == 3
                                    ? _finishOnboarding
                                    : _goNext)
                              : null,
                          child: state.isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  state.currentPage == 3
                                      ? 'Create my plan'
                                      : 'Next',
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
    final state = ref.read(onboardingFormControllerProvider);
    if (state.currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    final state = ref.read(onboardingFormControllerProvider);
    if (!state.canProceedFromPage(state.currentPage) ||
        state.currentPage >= 3) {
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finishOnboarding() async {
    final formController = ref.read(onboardingFormControllerProvider.notifier);
    final input = ref.read(onboardingFormControllerProvider).currentInput;
    if (input == null) return;

    formController.setSaving(true);

    final profileController = ref.read(profileSetupControllerProvider.notifier);
    profileController.completeOnboarding(
      profileId: 'local-user',
      input: input,
    );
    await profileController.saveCurrentProfile();

    if (mounted) {
      formController.setSaving(false);
    }
  }
}
