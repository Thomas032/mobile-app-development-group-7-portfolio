import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/screens/home_screen.dart';
import 'package:cal_tab/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRootScreen extends ConsumerWidget {
  const AppRootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileSetupControllerProvider).profile;

    if (profile == null) {
      return const OnboardingScreen();
    }

    return HomeScreen(profile: profile);
  }
}
