enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive;

  double get multiplier {
    return switch (this) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
    };
  }

  String toJson() => name;

  static ActivityLevel fromJson(String value) {
    return ActivityLevel.values.byName(value);
  }
}
