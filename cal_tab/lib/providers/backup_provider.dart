import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/services/backup_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackupState { idle, loading, success, error }

class BackupController extends Notifier<BackupState> {
  @override
  BackupState build() {
    return BackupState.idle;
  }

  /// Exports all user data to a JSON string
  Future<String?> exportData() async {
    state = BackupState.loading;

    try {
      final profiles = await ref.read(userProfileRepositoryProvider.future);
      final meals = await ref.read(mealLogRepositoryProvider.future);
      final settings = await ref.read(appSettingsRepositoryProvider.future);

      final userProfile = await profiles.loadProfile();
      final mealEntries = await meals.loadEntries();
      final appSettings = await settings.loadSettings();

      final backupJson = BackupService.exportBackup(
        userProfile: userProfile,
        meals: mealEntries,
        settings: appSettings,
      );

      state = BackupState.success;
      return backupJson;
    } catch (e) {
      state = BackupState.error;
      return null;
    }
  }

  /// Imports data from a backup JSON string
  /// Returns true if successful, false otherwise
  Future<bool> importData(String backupJson) async {
    state = BackupState.loading;

    try {
      final backupData = BackupService.importBackup(backupJson);
      if (backupData == null) {
        state = BackupState.error;
        return false;
      }

      final profiles = await ref.read(userProfileRepositoryProvider.future);
      final meals = await ref.read(mealLogRepositoryProvider.future);
      final settings = await ref.read(appSettingsRepositoryProvider.future);

      // Save imported data to repositories
      if (backupData['userProfile'] != null) {
        await profiles.saveProfile(backupData['userProfile']);
      }

      if (backupData['meals'] != null) {
        await meals.saveEntries(backupData['meals']);
      }

      if (backupData['settings'] != null) {
        await settings.saveSettings(backupData['settings']);
      }

      // Manually update controller states instead of invalidating
      // This prevents the profile from being reset to empty
      final profileController = ref.read(
        profileSetupControllerProvider.notifier,
      );
      if (backupData['userProfile'] != null) {
        // Update the profile state directly without triggering onboarding reset
        profileController.state = ProfileSetupState(
          profile: backupData['userProfile'],
        );
        // Save to ensure persistence
        await profileController.saveCurrentProfile();
      }

      // Update meals in the daily log
      final dailyLogController = ref.read(dailyLogControllerProvider.notifier);
      if (backupData['meals'] != null && backupData['meals'] is List) {
        dailyLogController.state = DailyLogState(entries: backupData['meals']);
      }

      // Update settings
      final settingsController = ref.read(
        appSettingsControllerProvider.notifier,
      );
      if (backupData['settings'] != null) {
        settingsController.state = backupData['settings'];
        await settingsController.saveCurrentSettings();
      }

      state = BackupState.success;
      return true;
    } catch (e) {
      state = BackupState.error;
      return false;
    }
  }

  /// Resets state to idle
  void reset() {
    state = BackupState.idle;
  }
}

final backupControllerProvider =
    NotifierProvider<BackupController, BackupState>(BackupController.new);
