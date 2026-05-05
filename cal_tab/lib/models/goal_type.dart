enum GoalType {
  cut,
  maintain,
  bulk;

  String toJson() => name;

  static GoalType fromJson(String value) {
    return GoalType.values.byName(value);
  }
}
