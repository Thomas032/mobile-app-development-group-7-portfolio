import 'package:cal_tab/models/meal_type.dart';
import 'package:cal_tab/services/meal_assignment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealAssignmentService', () {
    const service = MealAssignmentService();

    test('assigns morning food to breakfast', () {
      expect(service.assignFor(DateTime(2026, 5, 5, 8)), MealType.breakfast);
    });

    test('assigns late morning food to snack', () {
      expect(
        service.assignFor(DateTime(2026, 5, 5, 10)),
        MealType.snackMorning,
      );
    });

    test('assigns midday food to lunch', () {
      expect(service.assignFor(DateTime(2026, 5, 5, 13)), MealType.lunch);
    });

    test('assigns late afternoon food to snack', () {
      expect(
        service.assignFor(DateTime(2026, 5, 5, 16)),
        MealType.snackAfternoon,
      );
    });

    test('assigns evening food to dinner', () {
      expect(service.assignFor(DateTime(2026, 5, 5, 19)), MealType.dinner);
    });

    test('assigns late night food to second dinner', () {
      expect(
        service.assignFor(DateTime(2026, 5, 5, 23)),
        MealType.secondDinner,
      );
    });
  });
}
