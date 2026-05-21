import 'package:flutter/material.dart';

enum GoalType {
  cut,
  maintain,
  bulk;

  /// Short label used in settings dropdowns.
  String get shortLabel {
    return switch (this) {
      GoalType.cut => 'Cut',
      GoalType.maintain => 'Maintain',
      GoalType.bulk => 'Bulk',
    };
  }

  /// Friendlier headline used on the onboarding goal step.
  String get headline {
    return switch (this) {
      GoalType.cut => 'Lean out',
      GoalType.maintain => 'Stay on track',
      GoalType.bulk => 'Build up',
    };
  }

  String get tagline {
    return switch (this) {
      GoalType.cut => 'Create a calorie deficit with steady pacing.',
      GoalType.maintain => 'Keep your current weight and consistency.',
      GoalType.bulk => 'Support muscle gain with extra fuel.',
    };
  }

  IconData get icon {
    return switch (this) {
      GoalType.cut => Icons.trending_down_rounded,
      GoalType.maintain => Icons.balance_rounded,
      GoalType.bulk => Icons.trending_up_rounded,
    };
  }

  String toJson() => name;

  static GoalType fromJson(String value) {
    return GoalType.values.byName(value);
  }
}
