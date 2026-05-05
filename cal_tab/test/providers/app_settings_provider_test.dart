import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_app_settings_repository.dart';

void main() {
  group('AppSettingsController', () {
    test('loads saved settings from the repository', () async {
      final repository = FakeAppSettingsRepository(
        initialSettings: const AppSettings(
          themeMode: AppThemeMode.dark,
          aiApiKey: 'saved-key',
        ),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await container
          .read(appSettingsControllerProvider.notifier)
          .loadSavedSettings();

      final settings = container.read(appSettingsControllerProvider);

      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.aiApiKey, 'saved-key');
    });

    test('updates theme mode and persists it', () async {
      final repository = FakeAppSettingsRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container
          .read(appSettingsControllerProvider.notifier)
          .updateThemeMode(AppThemeMode.light);

      expect(
        container.read(appSettingsControllerProvider).themeMode,
        AppThemeMode.light,
      );
      expect(repository.settings.themeMode, AppThemeMode.light);
    });

    test('updates and clears the AI API key', () async {
      final repository = FakeAppSettingsRepository();
      final container = _container(repository);
      addTearDown(container.dispose);
      final controller = container.read(appSettingsControllerProvider.notifier);

      await controller.updateAiApiKey('test-key');
      await controller.updateAiApiKey('');

      expect(container.read(appSettingsControllerProvider).aiApiKey, isNull);
      expect(repository.settings.aiApiKey, isNull);
    });
  });
}

ProviderContainer _container(FakeAppSettingsRepository repository) {
  return ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWith((ref) async => repository),
    ],
  );
}
