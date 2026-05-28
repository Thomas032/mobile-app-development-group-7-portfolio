import 'dart:convert';

import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/user_profile.dart';

/// Service for exporting and importing user data backups
class BackupService {
  /// Backup file format version for compatibility checks
  static const String formatVersion = '1.0';

  /// Creates a backup JSON string from all user data
  static String exportBackup({
    required UserProfile? userProfile,
    required List<MealEntry> meals,
    required List<FoodItem> customMeals,
    required List<BodyProgressEntry> bodyProgressEntries,
    required AppSettings settings,
  }) {
    final backup = {
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'userProfile': userProfile?.toJson(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'customMeals': customMeals.map((meal) => meal.toJson()).toList(),
      'bodyProgressEntries': bodyProgressEntries
          .map((entry) => entry.toJson())
          .toList(),
      'settings': settings.toJson(),
    };

    return jsonEncode(backup);
  }

  /// Parses a backup JSON string and returns the extracted data
  ///
  /// Returns a map with keys:
  /// 'userProfile', 'meals', 'customMeals', 'bodyProgressEntries', 'settings'
  /// Returns null values for missing data
  static Map<String, dynamic>? importBackup(String backupJson) {
    try {
      final decoded = jsonDecode(backupJson) as Map<String, dynamic>;

      // Check version compatibility if needed
      final version = decoded['version'] as String?;
      if (version != formatVersion) {
        // You could add migration logic here for different versions
      }

      UserProfile? userProfile;
      if (decoded['userProfile'] != null) {
        userProfile = UserProfile.fromJson(
          decoded['userProfile'] as Map<String, dynamic>,
        );
      }

      List<MealEntry> meals = [];
      if (decoded['meals'] != null) {
        final mealsList = decoded['meals'] as List<dynamic>;
        meals = mealsList
            .cast<Map<String, dynamic>>()
            .map(MealEntry.fromJson)
            .toList();
      }

      List<FoodItem> customMeals = [];
      if (decoded['customMeals'] != null) {
        final customMealsList = decoded['customMeals'] as List<dynamic>;
        customMeals = customMealsList
            .cast<Map<String, dynamic>>()
            .map(FoodItem.fromJson)
            .toList();
      }

      List<BodyProgressEntry> bodyProgressEntries = [];
      if (decoded['bodyProgressEntries'] != null) {
        final bodyProgressList =
            decoded['bodyProgressEntries'] as List<dynamic>;
        bodyProgressEntries = bodyProgressList
            .cast<Map<String, dynamic>>()
            .map(BodyProgressEntry.fromJson)
            .toList();
      }

      AppSettings settings = const AppSettings();
      if (decoded['settings'] != null) {
        settings = AppSettings.fromJson(
          decoded['settings'] as Map<String, dynamic>,
        );
      }

      return {
        'userProfile': userProfile,
        'meals': meals,
        'customMeals': customMeals,
        'bodyProgressEntries': bodyProgressEntries,
        'settings': settings,
      };
    } catch (e) {
      return null;
    }
  }

  /// Gets a nicely formatted filename for the backup
  static String getBackupFileName() {
    final now = DateTime.now();
    return 'cal_tab_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
  }
}
