import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingFormState {
  const OnboardingFormState({
    this.currentPage = 0,
    this.goalType,
    this.age,
    this.ageTouched = false,
    this.height,
    this.heightTouched = false,
    this.weight,
    this.weightTouched = false,
    this.gender,
    this.activityLevel,
    this.isSaving = false,
  });

  final int currentPage;
  final GoalType? goalType;
  final double? age;
  final bool ageTouched;
  final double? height;
  final bool heightTouched;
  final double? weight;
  final bool weightTouched;
  final Gender? gender;
  final ActivityLevel? activityLevel;
  final bool isSaving;

  bool get canContinueGoals => goalType != null;
  bool get canContinueBody => ageTouched && heightTouched && weightTouched;
  bool get canContinueLifestyle => gender != null && activityLevel != null;
  bool get canFinish =>
      canContinueGoals && canContinueBody && canContinueLifestyle;

  bool canProceedFromPage(int page) => switch (page) {
    0 => canContinueGoals,
    1 => canContinueBody,
    2 => canContinueLifestyle,
    3 => canFinish,
    _ => false,
  };

  ProfileSetupInput? get currentInput {
    if (!canFinish) {
      return null;
    }

    return ProfileSetupInput(
      age: age!.round(),
      heightCm: height!,
      weightKg: weight!,
      gender: gender!,
      activityLevel: activityLevel!,
      goalType: goalType!,
    );
  }

  OnboardingFormState copyWith({
    int? currentPage,
    GoalType? goalType,
    double? age,
    bool? ageTouched,
    double? height,
    bool? heightTouched,
    double? weight,
    bool? weightTouched,
    Gender? gender,
    ActivityLevel? activityLevel,
    bool? isSaving,
  }) {
    return OnboardingFormState(
      currentPage: currentPage ?? this.currentPage,
      goalType: goalType ?? this.goalType,
      age: age ?? this.age,
      ageTouched: ageTouched ?? this.ageTouched,
      height: height ?? this.height,
      heightTouched: heightTouched ?? this.heightTouched,
      weight: weight ?? this.weight,
      weightTouched: weightTouched ?? this.weightTouched,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OnboardingFormController extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  void setPage(int page) => state = state.copyWith(currentPage: page);

  void setGoal(GoalType goal) => state = state.copyWith(goalType: goal);

  void setGender(Gender value) => state = state.copyWith(gender: value);

  void setActivityLevel(ActivityLevel value) =>
      state = state.copyWith(activityLevel: value);

  void setAge(double value) =>
      state = state.copyWith(age: value, ageTouched: true);

  void setHeight(double value) =>
      state = state.copyWith(height: value, heightTouched: true);

  void setWeight(double value) =>
      state = state.copyWith(weight: value, weightTouched: true);

  void setSaving(bool value) => state = state.copyWith(isSaving: value);
}

final onboardingFormControllerProvider =
    NotifierProvider<OnboardingFormController, OnboardingFormState>(
      OnboardingFormController.new,
    );
