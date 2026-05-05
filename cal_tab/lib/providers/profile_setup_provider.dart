import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/nutrition_providers.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupState {
  const ProfileSetupState({this.profile});

  final UserProfile? profile;

  bool get isComplete => profile != null;

  ProfileSetupState copyWith({UserProfile? profile}) {
    return ProfileSetupState(profile: profile ?? this.profile);
  }
}

class ProfileSetupController extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() {
    return const ProfileSetupState();
  }

  void completeOnboarding({
    required String profileId,
    required ProfileSetupInput input,
  }) {
    final calculator = ref.read(nutritionCalculatorProvider);
    final targets = calculator.calculateTargets(
      weightKg: input.weightKg,
      heightCm: input.heightCm,
      age: input.age,
      gender: input.gender,
      activityLevel: input.activityLevel,
      goalType: input.goalType,
    );

    state = ProfileSetupState(
      profile: UserProfile(
        id: profileId,
        age: input.age,
        heightCm: input.heightCm,
        weightKg: input.weightKg,
        gender: input.gender,
        activityLevel: input.activityLevel,
        goalType: input.goalType,
        calorieGoal: targets.calorieGoal,
        macroTargets: targets.macroTargets,
      ),
    );
  }

  Future<void> loadSavedProfile() async {
    final repository = await ref.read(userProfileRepositoryProvider.future);
    final profile = await repository.loadProfile();
    state = ProfileSetupState(profile: profile);
  }

  Future<void> saveCurrentProfile() async {
    final profile = state.profile;
    if (profile == null) {
      return;
    }

    final repository = await ref.read(userProfileRepositoryProvider.future);
    await repository.saveProfile(profile);
  }

  Future<void> clearSavedProfile() async {
    final repository = await ref.read(userProfileRepositoryProvider.future);
    await repository.clearProfile();
    clear();
  }

  void clear() {
    state = const ProfileSetupState();
  }
}

final profileSetupControllerProvider =
    NotifierProvider<ProfileSetupController, ProfileSetupState>(
      ProfileSetupController.new,
    );
