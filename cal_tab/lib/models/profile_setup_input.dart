import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';

class ProfileSetupInput {
  const ProfileSetupInput({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.activityLevel,
    required this.goalType,
  });

  final int age;
  final double heightCm;
  final double weightKg;
  final Gender gender;
  final ActivityLevel activityLevel;
  final GoalType goalType;
}
