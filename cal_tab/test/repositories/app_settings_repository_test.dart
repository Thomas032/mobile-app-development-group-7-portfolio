import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/repositories/app_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_key_value_store.dart';

void main() {
  group('LocalAppSettingsRepository', () {
    test('returns default settings when nothing has been saved', () async {
      final repository = LocalAppSettingsRepository(
        store: InMemoryKeyValueStore(),
      );

      final settings = await repository.loadSettings();

      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.aiApiKey, isNull);
    });

    test('saves and loads settings', () async {
      final repository = LocalAppSettingsRepository(
        store: InMemoryKeyValueStore(),
      );
      const settings = AppSettings(
        themeMode: AppThemeMode.dark,
        aiApiKey: 'test-key',
      );

      await repository.saveSettings(settings);
      final loadedSettings = await repository.loadSettings();

      expect(loadedSettings.themeMode, AppThemeMode.dark);
      expect(loadedSettings.aiApiKey, 'test-key');
    });

    test('clears saved settings', () async {
      final repository = LocalAppSettingsRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveSettings(
        const AppSettings(themeMode: AppThemeMode.light),
      );
      await repository.clearSettings();

      expect((await repository.loadSettings()).themeMode, AppThemeMode.system);
    });
  });
}
