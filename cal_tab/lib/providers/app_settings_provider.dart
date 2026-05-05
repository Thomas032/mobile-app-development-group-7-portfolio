import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  Future<void> loadSavedSettings() async {
    final repository = await ref.read(appSettingsRepositoryProvider.future);
    state = await repository.loadSettings();
  }

  Future<void> saveCurrentSettings() async {
    final repository = await ref.read(appSettingsRepositoryProvider.future);
    await repository.saveSettings(state);
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await saveCurrentSettings();
  }

  Future<void> updateAiApiKey(String? apiKey) async {
    state = apiKey == null || apiKey.isEmpty
        ? state.copyWith(clearAiApiKey: true)
        : state.copyWith(aiApiKey: apiKey);
    await saveCurrentSettings();
  }

  Future<void> clearSavedSettings() async {
    final repository = await ref.read(appSettingsRepositoryProvider.future);
    await repository.clearSettings();
    state = const AppSettings();
  }
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );
