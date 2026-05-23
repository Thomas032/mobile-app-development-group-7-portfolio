enum Gender {
  male,
  female,
  nonSpecified;

  String get label {
    return switch (this) {
      Gender.male => 'Male',
      Gender.female => 'Female',
      Gender.nonSpecified => 'Prefer not to say',
    };
  }

  int get bmrConstant {
    return switch (this) {
      Gender.male => 5,
      Gender.female => -161,
      Gender.nonSpecified => -78,
    };
  }

  String toJson() => name;

  static Gender fromJson(String value) {
    return Gender.values.byName(value);
  }
}
