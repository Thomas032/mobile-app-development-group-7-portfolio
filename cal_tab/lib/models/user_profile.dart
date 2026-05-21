import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.activityLevel,
    required this.goalType,
    required this.calorieGoal,
    required this.macroTargets,
  });

  final String id;
  final int age;
  final double heightCm;
  final double weightKg;
  final Gender gender;
  final ActivityLevel activityLevel;
  final GoalType goalType;
  final int calorieGoal;
  final MacroTargets macroTargets;

  UserProfile copyWith({
    String? id,
    int? age,
    double? heightCm,
    double? weightKg,
    Gender? gender,
    ActivityLevel? activityLevel,
    GoalType? goalType,
    int? calorieGoal,
    MacroTargets? macroTargets,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      macroTargets: macroTargets ?? this.macroTargets,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      age: json['age'] as int,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      gender: Gender.fromJson(json['gender'] as String),
      activityLevel: ActivityLevel.fromJson(json['activityLevel'] as String),
      goalType: GoalType.fromJson(json['goalType'] as String),
      calorieGoal: json['calorieGoal'] as int,
      macroTargets: MacroTargets.fromJson(
        json['macroTargets'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'gender': gender.toJson(),
      'activityLevel': activityLevel.toJson(),
      'goalType': goalType.toJson(),
      'calorieGoal': calorieGoal,
      'macroTargets': macroTargets.toJson(),
    };
  }
}
