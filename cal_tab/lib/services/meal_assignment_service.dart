import 'package:cal_tab/models/meal_type.dart';

class MealAssignmentService {
  const MealAssignmentService();

  MealType assignFor(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 5 && hour < 10) {
      return MealType.breakfast;
    }
    if (hour >= 10 && hour < 12) {
      return MealType.snackMorning;
    }
    if (hour >= 12 && hour < 16) {
      return MealType.lunch;
    }
    if (hour >= 16 && hour < 18) {
      return MealType.snackAfternoon;
    }
    if (hour >= 18 && hour < 22) {
      return MealType.dinner;
    }

    return MealType.secondDinner;
  }
}
