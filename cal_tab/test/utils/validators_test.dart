import 'package:cal_tab/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validatePositiveNumber', () {
    test('returns error when value is null', () {
      expect(validatePositiveNumber(null, 'Age'), 'Enter a valid Age');
    });

    test('returns error when value is empty', () {
      expect(validatePositiveNumber('', 'Age'), 'Enter a valid Age');
    });

    test('returns error when value is whitespace only', () {
      expect(validatePositiveNumber('   ', 'Age'), 'Enter a valid Age');
    });

    test('returns error when value is not a number', () {
      expect(validatePositiveNumber('abc', 'Age'), 'Enter a valid Age');
    });

    test('returns error when value is zero', () {
      expect(validatePositiveNumber('0', 'Age'), 'Enter a valid Age');
    });

    test('returns error when value is negative', () {
      expect(validatePositiveNumber('-5', 'Age'), 'Enter a valid Age');
    });

    test('returns null for a positive integer', () {
      expect(validatePositiveNumber('25', 'Age'), isNull);
    });

    test('returns null for a positive decimal', () {
      expect(validatePositiveNumber('72.5', 'Weight'), isNull);
    });

    test('trims surrounding whitespace before parsing', () {
      expect(validatePositiveNumber('  180  ', 'Height'), isNull);
    });

    test('uses the supplied label in the error message', () {
      expect(
        validatePositiveNumber('', 'Calorie target'),
        'Enter a valid Calorie target',
      );
    });
  });
}
