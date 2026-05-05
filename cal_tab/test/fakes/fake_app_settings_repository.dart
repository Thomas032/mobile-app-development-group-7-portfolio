import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/repositories/app_settings_repository.dart';

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({AppSettings initialSettings = const AppSettings()})
    : _settings = initialSettings;

  AppSettings _settings;

  AppSettings get settings => _settings;

  @override
  Future<AppSettings> loadSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> clearSettings() async {
    _settings = const AppSettings();
  }
}
