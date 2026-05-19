/// Form-field validators used across the app.
///
/// Validators here are pure functions: they take the raw text the user typed
/// (which may be null when a `TextFormField` first builds) and return either
/// `null` (valid) or an error message to display.
library;

/// Validates that [value] is a non-empty string that parses to a positive
/// number. [label] is used in the error message so the same validator can be
/// reused for age, height, weight, calorie targets, etc.
String? validatePositiveNumber(String? value, String label) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Enter a valid $label';
  }
  final parsed = num.tryParse(trimmed);
  if (parsed == null || parsed <= 0) {
    return 'Enter a valid $label';
  }
  return null;
}
